@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_MatPrd_Data
//                    OHNE E_R_G
//  Info
//
//
//  01.09.2017  AH  Erstellung der Prozedur
//  22.02.2019  AH  neuer AFX "BAG.FM.Set.MatABemerkung"
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB Abschluss();
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG
@I:Def_Aktionen

//========================================================================
//  Abschluss   +ERR
//
//========================================================================
sub Abschluss(
  aDatum  : date;
  aTime   : time;
  aSilent : logic) : logic;
local begin
  Erx             : int;
  vA              : alpha;
  vGew            : float;
  vBuf703         : int;
  vBuf702         : int;
  vOK             : logic;
  vM              : float;
  vStk            : int;
  vBuf440         : int;
  vBuf441         : int;
  vMatDel         : logic;
  vSchrottGew     : float;
  vSchrottStk     : int;
  vSchrottAnzahl  : int;
  vNr             : int;
  vHdlInput       : int;
//  vHdlFert        : int;
  vHdlOutput      : int;
end;
begin

  // Einsatz loopen...
  FOR Erx # recLink(701,702,2,_RecFirst)
  LOOP Erx # recLink(701,702,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    // Artikel mit ECHTEN Chargen?
    if (BAG.IO.Materialtyp=c_IO_Beistell) or
      ((BAG.P.Aktion<>c_BAG_ArtPrd) and (BAG.IO.Materialtyp=c_IO_Art)) then begin
      if (BAG.IO.Charge='') then begin
        Error(702037,'');
        RETURN false;
      end;
    end;
  END;


  if (aSilent=n) then begin
    if (Msg(702046,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;;

    if (aDatum=0.0.0) then begin
      REPEAT
        if (Dlg_Standard:Datum(translate('Abschlussdatum'),var aDatum, today)=false) then
          RETURN false;
      UNTIL (aDatum<>0.0.0);
    end;
  end;
  if (aDatum=0.0.0) then aDatum # today;

  if (Lib_Faktura:Abschlusstest(aDatum) = false) then begin
    Error(001400 ,Translate('Abschlussdatum') + '|'+ CnvAd(aDatum));
    RETURN false;
  end;

  // Ankerfunktion?
  if (aSilent) then vA # 'Y' else vA # '';
  if (RunAFX('BAG.P.Abschluss.Pre',vA)<>0) then begin
    if (AfxRes<>_rOk) then RETURN false;
  end;


  TRANSON;

  // Arbeitsgang-Position löschen
  Erx # RecRead(702,1,_recLock);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(702020,AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position));  // ST 2009-02-02
    RETURN false;
  end;
  "BAG.P.Löschmarker" # '*';
  BAG.P.Fertig.Dat    # aDatum;
  BA1_Data:SetStatus(c_BagStatus_Fertig);
  if (aDatum=today) then begin
    BAG.P.Fertig.Zeit   # now;
    BAG.P.FErtig.User   # gUsername;
  end;
  Erx # BA1_P_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    Error(702012,'689');
    RETURN false;
  end;

  // Auftragsaktionen updaten...
  BA1_P_Data:UpdateAufAktion(n);


  // INPUT LOOPEN *************************************************
  FOR Erx # recLink(701,702,2,_RecFirst)
  LOOP Erx # RecLink(701,702,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    // Artikel? -> Reservierungen aufheben ---------------------------------------------
    if (BAG.IO.MaterialTyp=c_IO_Art) then begin
      // Reservierung aufheben...
      if (BA1_Art_Data:ArtFreigeben()=false) then begin
      end;
    end;

    // BestelleArtikel? -> Abgang buchen und Kosten summieren -------------------------
    if (BAG.IO.MaterialTyp=c_IO_Beistell) then begin
      Erx # RecLink(250,701,8,_recFirst);     // Artikel holen
      if (Erx<=_rLocked) then begin
        Erx # RecLink(252,701,17,_recFirst);  // Charge holen
        if (Erx<=_rLocked) then begin

          // Ankerfunktion starten
          if (RunAFX('BAG.FM.BeistellKost','')<>0) then begin
            if (AfxRes<>_rOK) then begin
              TRANSBRK;
              Error(702012,'899');
              RETURN false;
            end;
          end
          else begin  // STANDARD
            // Gesamtkosen des ARtikel errechnen und in IO speicehrn...
            RecbufClear(254);
            if (Art.C.EKDurchschnitt<>0.0) then begin
              Art.P.MEH # Art.MEH;
              Art.P.PEH # Art.PEH;
              Art.P.PreisW1 # Art.C.EKDurchschnitt;
            end
            else if (Art.C.EKLetzter<>0.0) then begin
              Art.P.MEH # Art.MEH;
              Art.P.PEH # Art.PEH;
              Art.P.PreisW1 # Art.C.EKLetzter;
            end
            else begin
              Art_P_Data:LiesPreis(c_art_PRD,0);
              if (Art.P.PreisW1=0.0) then
                Art_P_Data:LiesPreis('Ø-EK',0);
              if (Art.P.PreisW1=0.0) then
                Art_P_Data:LiesPreis('L-EK',0);
              if (Art.P.PreisW1=0.0) then
                Art_P_Data:LiesPreis('L-EK',-1);
              if (Art.P.PreisW1=0.0) then
                Art_P_Data:LiesPreis('EK',0);
            end;
            if (BAG.IO.Meh.In<>Art.P.MEH) and (Art.P.MEH<>'') then begin
              TRANSBRK;
              Error(702012,'899');
              RETURN false;
            end;
            RecRead(701,1,_recLock);
            BAG.IO.GesamtKostW1 # Art.P.PreisW1 * BAG.IO.Plan.In.Menge / CnvfI(Art.P.PEH);
            RekReplace(701,_recUnlock,'AUTO');
          end;

          // Reservierung aufheben...
          if (BA1_Art_Data:ArtFreigeben()=false) then begin
            TRANSBRK;
            Error(701006,'');
            RETURN false;
          end;

          // Bewegung buchen...
          RecBufClear(253);
          Art.J.Datum           # aDatum;
          Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
          "Art.J.Stückzahl"     # (-1) * BAG.IO.PLan.In.Stk;
          Art.J.Menge           # (-1.0) * BAG.IO.Plan.In.Menge;
          "Art.J.Trägertyp"     # c_Akt_BA;
          "Art.J.Trägernummer1" # BAG.P.Nummer;
          "Art.J.Trägernummer2" # BAG.P.Position;
          "Art.J.Trägernummer3" # BAG.IO.ID;
          vOK # Art_Data:Bewegung(0.0, 0.0);
          if (vOK=false) then begin
            TRANSBRK;
            Error(702012,'881');
            RETURN false;
          end;
        end;
      end;
    end;

  END;


  // REST-FERTIGUNG anlegen...
  if (BA1_IO_Data:CreateBIS(true)=false) then begin
    TRANSBRK;
    RETURN false;
  end;
  BAG.F.Nummer    # BAG.P.Nummer;
  BAG.F.Position  # BAG.P.Position;
  BAG.F.Fertigung # 999;
  Erx # RecRead(703,1,0);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(702012,'Fertigung 999 nicht gefunden!');
    RETURN false;
  end;
  // Fertigung geladen
//  vHdlFert # RekSave(703);


  // INPUT LOOPEN.2 *************************************************
  FOR Erx # recLink(701,702,2,_RecFirst)
  LOOP Erx # RecLink(701,702,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    // echtes Material? --------------------------------------------------
    if (BAG.IO.MaterialTyp=c_IO_Mat) then begin

      // AUTO-REST-FERTIGMELDEN -----------------------------------------
      vHdlInput # RekSave(701);     // Aktuellen Einsatz merken

      // Verpackung lesen
      Erx # RecLink(704,703,6,_recfirst);
      if (Erx>_rLockeD) then RecBufClear(704);

      // Jeden Output durchlaufen...
      FOR Erx # RecLink(701,703,4,_RecFirst)
      LOOP Erx # RecLink(701,703,4,_RecNext)
      WHILE (Erx<=_rLocked) DO BEGIN

        // nur Echte Outputs anlegen
        if (BAG.IO.Materialtyp <> c_IO_BAG) then
          CYCLE;

        if (BAG.IO.VonID <> vHdlInput->BAG.IO.ID) and (BAG.IO.VonID<>0) and (BAG.IO.VonID<>vHdlInput->BAG.IO.BruderID) then
          CYCLE;

        vHdlOutput # RekSave(701);      // Output merken

        // -----------------------------------
        // FM Daten vorbelegen
        RecBufClear(707);
        // Hauptdaten
        BAG.FM.Nummer           # myTmpNummer;
        BAG.FM.Fertigmeldung    # 999;
        BAG.FM.Position         # BAG.F.Position;
        BAG.FM.Fertigung        # BAG.F.Fertigung;
        BAG.FM.Fertigmeldung    # 0;                // laufende Nummer kommt beim Verbuchen
        BAG.FM.InputBAG         # vHdlInput->BAG.IO.Nummer
        BAG.FM.InputID          # vHdlInput->BAG.IO.ID;
        BAG.FM.OutPutID         # vHdlOutput->BAG.IO.ID;
        BAG.FM.BruderID         # vHdlOutput->Bag.IO.ID;

//        BAG.FM.MEH              # BAG.F.MEH;
        BAG.FM.MEH              # vHdlInput->BAG.IO.MEH.Out;
        BAG.FM.Menge            # vHdlInput->BAG.IO.Plan.Out.Meng - vHdlInput->BAG.IO.Ist.Out.Menge;
        "BAG.FM.Stück"          # vHdlInput->BAG.IO.Plan.Out.Stk - vHdlInput->BAG.IO.Ist.Out.Stk;
        BAG.FM.Gewicht.Netto    # vHdlInput->BAG.IO.Plan.Out.GewN - vHdlInput->BAG.IO.Ist.Out.GewN;
        BAG.FM.Gewicht.Brutt    # vHdlInput->BAG.IO.Plan.Out.GewB - vHdlInput->BAG.IO.Ist.Out.GewB;

        BAG.FM.Verwiegungart    # BAG.Vpg.Verwiegart;
        BAG.FM.Materialtyp      # vHdlInput->BAG.IO.Materialtyp;
        BAG.FM.Status           # 1;
        BAG.FM.Bemerkung        # vHdlOutput->BAG.IO.Bemerkung;
        BAG.FM.Lagerplatz       # '';               // ???
        BAG.FM.Datum            # aDatum;

        // Materialdaten
        BAG.FM.Materialnr       # 0;                // sollte vom Verbuchen kommen
        BAG.FM.Dicke            # vHdlOutput->BAG.IO.Dicke;
        BAG.FM.Breite           # vHdlOutput->BAG.IO.Breite;
        "BAG.FM.Länge"          # vHdlOutput->"BAG.IO.Länge";
        BAG.FM.AusfOben         # vHdlOutput->BAG.IO.AusfOben;
        BAG.FM.AusfUnten        # vHdlOutput->BAG.IO.AusfUnten;

        // Einsatzmengen nochmal als Beistellung eintragen...
        RecbufClear(708);
        BAG.FM.B.LfdNr        # 1;
//debugX('rest von KEY701   von:'+aint(bag.io.vonid)+'  ur:'+aint(BAG.IO.UrsprungsID)+' b:'+aint(Bag.io.bruderID));
        BAG.FM.B.VonID        # BAG.IO.vonID;
        BAG.FM.B.Menge        # BAG.FM.Menge;
        BAG.FM.B.MEH          # BAG.FM.MEH;
        "BAG.FM.B.Stück"      # "BAG.FM.Stück";
        BAG.FM.B.Gew.Netto    # BAG.FM.Gewicht.Netto;
        BAG.FM.B.Gew.Brutto   # BAG.FM.Gewicht.Brutt;
        BA1_FM_B_Data:Insert();

        // Artikeldaten
  //            BAG.FM.Artikelnr #  vHdlOutput->BAG.IO.Artikelnr;

        // FM Anlegen, ohne Etk
        if (!BA1_Fertigmelden:Verbuchen(false)) then begin
          TRANSBRK;
          RETURN false;
        end;

        RekRestore(vHdlOutput);
      END; //Jeden Output durchlaufen

      RekRestore(vHdlInput);


      // Rest-Einsatz verschrotten ---------------------------------------------
      Erx # RecLink(200,701,11,_recFirst);    // Restkarte holen
      if (Erx<>_rOK) or
        ("Mat.Löschmarker"<>'') or (Mat.Ausgangsdatum<>0.0.0) then begin
        TRANSBRK;
        Error(702012,'753');
        RETURN false;
      end;
      RecRead(200,1,_recLock);
      Mat.Kommission    # '';
      Mat.Auftragsnr    # 0;
      Mat.Auftragspos   # 0;
      Mat.Auftragspos2  # 0;
      Mat.KommKundennr  # 0;

      // "Mat.Löschmarker" # '*';
      Mat_Data:SetLoeschmarker('*');

      Mat.Ausgangsdatum # aDatum;

      Mat_Data:SetStatus(c_Status_BAGverschnitt); // auf "Verschnitt" setzen

      // Schrottartikel ggf. buchen...
      Erx # RekLink(819,200,1,_recFirst);   // Warengruppe holen
      RunAFX('BAG.FM.FindSchrottArtikel','');
      if (Wgr.Schrottartikel<>'') and (Mat.Bestand.Gew>0.0) then begin
        Erx # RecLink(250,819,2,_recFirst); // Artikel holen
        if (Erx>_rLocked) then begin
          TRANSBRK;
          Error(702040,Wgr.Schrottartikel);
          RETURN false;
        end;

        RecBufClear(252);
        Art.C.ArtikelNr   # Art.Nummer;
        Art.C.Adressnr    # Set.EigeneAdressnr;
        Art.C.Anschriftnr # 1;

        // Bewegung buchen...
        vStk # Mat.Bestand.Stk;
        if (vStk=0) then vStk # 1;
        vM # Lib_Einheiten:WandleMEH(250, Mat.Bestand.Stk, Mat.Bestand.Gew, 0.0, '', Art.MEH);

        RecBufClear(253);
        Art.J.Datum           # aDatum;
        Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
        "Art.J.Stückzahl"     # vStk;
        Art.J.Menge           # vM;
        "Art.J.Trägertyp"     # c_Akt_BA;
        "Art.J.Trägernummer1" # BAG.P.Nummer;
        "Art.J.Trägernummer2" # BAG.P.Position;
        "Art.J.Trägernummer3" # 0;
        vOK # Art_Data:Bewegung(0.0, 0.0,0, true);
        if (vOK=false) then begin
          TRANSBRK;
          Error(702012,'1188');
          RETURN false;
        end;

        // 30.11.2012 AI: Schrottcharge merken !!!
        RecRead(701,1,_recLock);
        BAG.IO.Artikelnr  # Art.C.Artikelnr;
        BAG.IO.Charge     # Art.C.Charge.Intern;
        RekReplace(701,_recUnlock,'AUTO');

      end;  // Schrottartikel

      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Error(702012,'908');
        RETURN false;
      end;

      // alle Reservierungen entfernen auf der Schrottkarte
      WHILE (RecLink(203,200,13,_recFirst)<=_rLocked) do begin
        if (Mat_Rsv_data:Entfernen()=false) then begin
          TRANSBRK;
          Error(702012,'1191');
          RETURN false;
        end;
      END;
    end; // echtes Material

  END;


  // Geplante Mengen aus Aufträgen entfernen -----------------------------
  vBuf702 # RekSave(702);
  Erx # RecLink(701,702,3,_recFirst);       // OUTPUT loopen
  WHILE (Erx<=_rLocked) do begin

    // nur Weiterbearbeitungen prüfen
    if (BAG.IO.MaterialTyp=c_IO_BAG) then begin
      Erx # RecLink(702,701,4,_recFirst);   // Nachfolger holen

      // theoretischen Versand löschen?
      if (BAG.P.Aktion=c_BAG_Versand) then begin
        VsP_data:BaGInput2Ablage();
      end;

      if (BAG.P.Typ.VSBYN) or (BAG.P.Aktion=c_BAG_Versand) then begin
        Auf.P.Nummer      # BAG.P.Auftragsnr;
        Auf.P.Position    # BAG.P.Auftragspos;
        Erx # RecRead(401,1,0);       // Auftrag holen
        if (Erx<=_rLocked) then begin
          Auf.A.Aktionsnr   # BAG.IO.VonBAG;
          Auf.A.Aktionspos  # BAG.IO.VonPosition;
          Auf.A.Aktionspos2 # BAG.IO.ID;
          Auf.A.Aktionstyp  # c_Akt_BA_Plan;

          Erx # RecRead(404,2,0);
          if (Erx>_rMultikey) then begin  // NICHT GEFUNDEN??? -> weitermachen...
          end
          else begin
            if (Auf_A_Data:Entfernen(y)=false) then begin
              TRANSBRK;
              RekRestore(vBuf702);
              Error(010039,AInt(BAG.IO.VonBAG)+'/'+AInt(BAG.IO.VonPosition)+'|'+AInt(Auf.A.Nummer)+'/'+AInt(auf.A.Position)+'/'+AInt(Auf.a.Aktion));
              RETURN false;
            end;
          end;

        end;
      end; // ist VSB/Versand

      RecBufCopy(vBuf702,702);

    end; // Weiterbearbeitung

    Erx # RecLink(701,702,3,_recNext);
  END;
  RecBufDestroy(vBuf702);


  // Kosten errechnen
  vBuf702 # RekSave(702);
  if (BA1_Kosten:UpdatePosition(BAG.P.Nummer, BAG.P.Position)=false) then begin
    TRANSBRK;
    RekRestore(vBuf702);
    Error(702025,'');
    RETURN false;
  end;

  RekRestore(vBuf702);

  // Gesamten BA prüfen...
  RecLink(700,702,1,_recFirst);   // Kopf holen
  if (BA1_Data:BerechneMarker()=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  // 09.01.2013 AI Projekt 1347/96 : LFS nicht refreshen, da sonst Versprung?!?!
  if (gZLList<>0) and (gFile<>440) then begin
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
  end;


  // Ankerfunktion?
  if (RunAFX('BAG.P.AbschlussPost',Aint(BAG.P.Nummer)+'/'+Aint(BAG.P.Position))<>0) then begin
    if (AfxRes<>_rOk) then RETURN false;
  end;

  if (aSilent=n) then begin
    Error(702011,'');   // Erfolg!
  end;

  RETURN true;
end;


//========================================================================
//  InputList2Beistellung +ERR
//
//========================================================================
sub InputList2Beistellung(
  aInputList  : handle) : logic;
local begin
  Erx           : int;
  vItem         : handle;
  vLfd          : int;
  vMenge        : float;
  vI,vJ         : int;
  vA,vB         : alpha(1000);
  vStk          : int;
  vGewN,vGewB   : float;
  vM            : float;
end;
begin

  TRANSON;

  // Einsatzliste in Beistellungen wandeln --------------------------------
  vLfd # 1;
  FOR vItem # aInputList->CteRead(_CteFirst)
  LOOP vItem # aInputList->CteRead(_CteNext, vItem)
  WHILE (vItem > 0) do begin
    BAG.IO.Nummer # BAG.F.Nummer;
    BAG.IO.ID     # cnvia(vItem->spName);
    Erx # RecRead(701,1,0);   // Einsatz holen
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;

    vA        # vItem->spcustom;
    vB        # Str_Token(vA, '|', 1);
    vStk      # cnvia(vB);
    vB        # Str_Token(vA, '|', 2);
    vGewN     # cnvfa(vB);
    vB        # Str_Token(vA, '|', 3);
    vGewB     # cnvfa(vB);
    vB        # Str_Token(vA, '|', 4);
    vM        # cnvfa(vB);

    RecbufClear(708);
    BAG.FM.B.VonID        # BAG.IO.ID;
    BAG.FM.B.Menge        # vM;
    BAG.FM.B.MEH          # BAG.IO.MEH.Out;
    "BAG.FM.B.Stück"      # vStk;
    BAG.FM.B.Gew.Netto    # vGewN;
    BAG.FM.B.Gew.Brutto   # vGewB;
    BAG.FM.B.lfdNr        # vLfd;
    BA1_FM_B_Data:Insert();
    vLfd # BAG.FM.B.LfdNr + 1;
  END;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  FertigMatAnlegen
//
//========================================================================
sub FertigMatAnlegen(aBeistellKosten : float) : logic;
local begin
  vNeueNr     : int;
  v200        : int;
  vStatus     : int;
  vBuf100     : int;
  vBuf702     : int;
  vNeuID      : int;
  vAktID      : int;
  vNextAktion : alpha;
  vPool       : int;
  vVSBAktBuf  : int;
  vVSDAdr     : int;
  vVSDAnschr  : int;
  vM          : float;
  vVorNr      : int;
  vNur1Beist  : logic;

  vGew        : float;
  vX          : float;
  vKosten     : float;
  vWertNeu    : float;
  vKombiTxt   : int;
  vA          : alpha(100);
  vKostenNeu  : float;
  Erx         : int;
end;
begin DoLogProc;

  vAktID # BAG.IO.ID;

  // Bruder-Ausbringung ansehen
  BAG.IO.Nummer # BAG.FM.Nummer;
  BAG.IO.ID     # BAG.FM.BruderID;
//debug('read IO A:'+cnvai(bag.io.nummer)+'/'+cnvai(bag.io.ID))
  Erx # RecRead(701,1,0);
  if (Erx<>_rOK) then begin
    Error(010027,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.BruderID));
    RETURN false;
  end;

  // Ursprung holen
  BAG.IO.Nummer # BAG.IO.Nummer;
  BAG.IO.ID     # BAG.IO.UrsprungsID;
//debug('read IO B:'+cnvai(bag.io.nummer)+'/'+cnvai(bag.io.ID));
  Erx # RecRead(701,1,0);
  if (Erx<>_rOK) then begin
    Error(707101,AInt(BAG.IO.UrsprungsID)); // ST 2009-02-03
    RETURN false;
  end;

  // Restore Bruder
  BAG.IO.Nummer # BAG.FM.Nummer;
  BAG.IO.ID     # BAG.FM.BruderID;
  Erx # RecRead(701,1,0);

  vStatus # c_Status_BAGOutput;
  if (BAG.IO.NachBAG<>0) then begin     // Weiterbearbeitung?
    vBuf702 # RekSave(702);

    Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin
      vNextAktion # BAG.P.Aktion;
      vNextAktion # BAG.P.Aktion;
      // TODO ArG.Typ.ReservInput; : if (ArG.Aktion2<>BAG.P.Aktion2) then Erx # RecLink(828,702,8,_recFirst);
      //vNextAktRes # ArG.Typ.ReservInput;

      if (BAG.P.Aktion=c_BAG_Versand) then begin
        vVSDAdr     # BAG.P.Zieladresse;
        vVSDAnschr  # BAG.P.Zielanschrift;
      end;
      vStatus # BA1_Mat_Data:StatusLautEinsatz(BAG.P.Aktion,BAG.P.Auftragsnr);
    end;

    RekRestore(vBuf702);
  end;

  // neue Nummer bestimmen
  vNeueNr # Lib_Nummern:ReadNummer('Material');
  if (vNeueNr<>0) then begin
    Lib_Nummern:SaveNummer()
  end
  else begin
    Error(902001,'Material|'+LockedBy);     // ST 2009-02-03
    RETURN false;
  end;


  // Mat-Aktionsliste füllen -----------------------------------------------
  vKombiTxt # TextOpen(20);
  vNur1Beist # (RecLinkInfo(708,707,12,_recCount)=1);

  v200        # RecBufCreate(200);
  RecBufClear(200);
  FOR Erx # RecLink(708,707,12,_recFirst) // BAG-Bewegungen loopen
  LOOP Erx # RecLink(708,707,12,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.FM.B.VonID=0) then CYCLE;

    Erx # RecLink(701,708,5,_recFirst);   // VonID holen
    if (Erx<>_rOK) then begin
      RecBufDestroy(v200);
      TextClose(vKombiTxt);
      RETURN false;
    end;

    if (vNur1Beist) then begin
      // Restkarte holen...
      Erx # RecLink(200,701,11,_RecFirst);
      if (Erx>_rLocked) then begin
        // Einsatzkarte holen...
        Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
        if (Erx<200) then begin
          TextClose(vKombiTxt);
          Error(010040,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.IO.Materialnr));
          RETURN false;
        end;
      end;
//debugx('copy KEY200 als Vorlage');
    end;


    if (BAG.IO.BruderID=0) then
      vVorNr              # BAG.IO.Materialnr
    else
      vVorNr              # "Mat.Vorgänger";
//debugx('KEY701   bruder:'+aint(bag.io.bruderid)+'  vorg:'+aint(vVorNr));
    // Aktion anlegen...
    if (vVorNr<>Mat.Nummer) then begin
      Erx # Mat_Data:Read(vVorNr);
      if (Erx<200) then begin
        Error(707101,AInt(vVorNr));
        RecBufDestroy(v200);
        TextClose(vKombiTxt);
        RETURN false;
      end;
    end;


    // KOSTEN ADDIEREN -------
    if (Mat.MEH='kg') or (Mat.MEH='t') then begin
      if (VwA.Nummer<>Mat.Verwiegungsart) then begin
        Erx # RekLink(818,200,10,_recfirst);     // Verwiegungsart holen
        if (Erx>_rLocked) then VwA.NettoYN # y;
      end;
      if (VWa.NettoYN) then
        vGew  # BAG.FM.B.Gew.Netto;
      else
        vGew    # BAG.FM.B.Gew.Brutto;
      vKosten   # Rnd(vGew * Mat.Kosten / 1000.0,2);
      vX        # Rnd(vGew * Mat.EK.Preis / 1000.0,2);
      vWertNeu  # vWertNeu + vX;
//debugx(anum(vGew,2)+'kg * '+anum(Mat.EK.Preis,2) +'EK = '+anum(vX,2) +'   (kosten:'+anum(vKosten,2));
    end
    else begin
      vM        # Lib_Einheiten:WandleMEH2(200, "BAG.FM.B.Stück", vGew, BAG.FM.B.Menge, BAG.FM.B.MEH, 0.0, '', Mat.MEH);
      vKosten   # Rnd(vM * Mat.KostenProMEH, 2);
      vX        # Rnd(vM * Mat.EK.PreisProMEH, 2);
      vWertNeu  # vWertNeu + vX;
//debugx(anum(vM,2)+Mat.MEH+' * '+anum(Mat.EK.PreisProMEH,2) +'EK = '+anum(vX,2));
    end;
    vKostenNeu # vKostenNeu + vKosten;

    // Einsatzmat-Aktion...
    RecBufClear(204);
    Mat.A.Aktionsmat    # vVorNr;
    Mat.A.Entstanden    # vNeueNr;
    if (vNur1Beist) then
      Mat.A.Aktionstyp  # c_Akt_BA_Fertig
    else
    Mat.A.Aktionstyp    # c_Akt_Mat_Kombi;

    Mat.A.Aktionsnr     # BAG.FM.Nummer;
    Mat.A.Aktionspos    # BAG.FM.Position;
    Mat.A.Aktionspos2   # BAG.FM.Fertigung;
    Mat.A.Aktionspos3   # BAG.FM.Fertigmeldung;
    Mat.A.Aktionsdatum  # BAG.FM.Datum;
    Mat.A.TerminStart   # BAG.FM.Datum;
    Mat.A.TerminStart   # BAG.FM.Datum;

    Mat.A.Bemerkung     # c_AktBem_BA_fertig;
    if (RunAFX('BAG.FM.Set.MatABemerkung','')=0) then
      Mat.A.Bemerkung # Mat.A.Bemerkung +' '+BAG.P.Aktion2;

    if (VwA.Nummer<>BAG.FM.Verwiegungart) then begin
      Erx # RekLink(818,707,6,_recfirst);     // Verwiegungsart holen
      if (Erx>_rLocked) then VwA.NettoYN # y;
    end;
    if (VWa.NettoYN) then
      Mat.A.Gewicht     # BAG.FM.B.Gew.Netto;
    else
      Mat.A.Gewicht     # BAG.FM.B.Gew.Brutto;

    "Mat.A.Stückzahl"   # "BAG.FM.B.Stück";

    Mat.A.Menge # Lib_Einheiten:WandleMEH2(200, Mat.Bestand.Stk, Mat.Bestand.Gew, BAG.FM.B.Menge, BAG.FM.B.MEH, 0.0, '', Mat.MEH);

    Erx # Mat_A_Data:Insert(0,'AUTO');
    if (Erx<>_rOK) then begin
      RecBufDestroy(v200);
      RecBufClear(200);
      Error(707102,''); // ST 2009-02-03
      TextClose(vKombiTxt);
      RETURN false;
    end;
    RecBufCopy(200,v200);

    vA # cnvai(Mat.A.Materialnr, _FmtNumNoGroup|_FmtNumLeadZero, 0, 15);
    vA # vA + cnvai(Mat.A.Aktion, _FmtNumNoGroup|_FmtNumLeadZero, 0, 15);
    vA # vA + cnvaf(vKosten, _FmtNumNoGroup|_FmtNumLeadZero, 0, 2, 15);
    TextAddLine(vKombiTxt,  vA);
/*** SPÄTER
    // Feritgmat Aktion...
    if (vNur1Beist=false) then begin
      Mat.Nummer          # vNeueNr;
  //    Mat.A.Aktionsmat    # Mat.Nummer;
      Mat.A.Entstanden    # 0;

    if (Mat.A.Menge<>0.0) then
      Mat.A.KostenW1ProMEH  # Rnd(vKosten / vM * 1000.0,2);
    if (Mat.Bestand.Gew<>0.0) then
      Mat.A.KostenW1        # Rnd(vKosten / Mat.Bestand.Gew * 1000.0,2);
debugx('+++ kosten:'+anum(Mat.A.KOstenW1,2)+' bei KEY200 '+anum(Mat.Bestand.Gew,0));
      Erx Mat_A_Data:Insert(0,'AUTO');
      if (Erx<>_rOK) then begin
        RecBufDestroy(v200);
        RecBufClear(200);
        Error(707102,''); // ST 2009-02-03
        TextClose(vKombiTxt);
        RETURN false;
      end;
    end;
***/
  END;


  // Verpackung holen
  Erx # RecLink(704,703,6,_recfirst);
  if (Erx>_rLocked) then RecBufClear(704);

  // WERTE SETZEN --------------------------------------------------
  if (vNur1Beist) then begin
  end
  else begin
    RecBufClear(200);
  end;

  Erx # RecLink(819,703,5,_recFirst);   // Warengruppe holen
  if (Wgr_Data:IstMix()) and (BAG.F.Artikelnummer<>'') then begin
    Erx # RecLink(250,703,13,_recFirsT);    // Artikel holen
    if (Erx>_rLocked) then begin
      RecBufClear(200);
      RecBufDestroy(v200);
      Error(999999,'Artikel nicht gefunden!');
      TextClose(vKombiTxt);
      RETURN false;
    end;

    Mat.Strukturnr      # Art.Nummer;
    Mat.MEH             # Art.MEH;
    Mat.Warengruppe     # Art.Warengruppe;
    "Mat.Güte"          # "Art.Güte";
    Mat.Dicke           # Art.Dicke;
    Mat.Breite          # Art.Breite;
    "Mat.Länge"         # "Art.Länge";
    Mat.Dickentol       # Art.DickenTol;
    Mat.Breitentol      # Art.BreitenTol;
    "Mat.Längentol"     # "Art.LängenTol";
    Mat.RID             # Art.Innendmesser;
    Mat.RAD             # Art.Aussendmesser;
    Mat.Lagerplatz      # BAG.FM.Lagerplatz;
    Mat.Verwiegungsart  # BAG.FM.Verwiegungart;
    Mat.Werksnummer     # BAG.FM.Werksnummer;
    Mat.EigenmaterialYN # v200->Mat.EigenmaterialYN;
    "Mat.Übernahmedatum"# v200->"Mat.Übernahmedatum";
    Mat.Lageradresse    # v200->Mat.Lageradresse;
    Mat.Lageranschrift  # v200->Mat.Lageranschrift;
    Mat.Lagerstichwort  # v200->Mat.Lagerstichwort;
    Mat.Erzeuger        # Mat.Lageradresse;
  end;  // Artikeldaten kopieren
  RecBufDestroy(v200);



  // nur Kommission umsetzen, wenn gefüllt...sont BEHALTEN
  if (BAG.F.Kommission<>'') then begin
    Mat.Kommission        # BAG.F.Kommission;
    Mat.Auftragsnr        # BAG.F.Auftragsnummer;
    Mat.Auftragspos       # BAG.F.Auftragspos;
    Mat.Auftragspos2      # BAG.F.AuftragsFertig;
  end;

  if (Mat.Etikettentyp = 0) AND (BAG.FM.Fertigung > 900) then
    Mat.Etikettentyp # Set.Ein.WE.Etikett;
  if (Mat.Etikettentyp = 0) then
    Mat.Etikettentyp # Set.BA.FM.Frei.Etk;

  // GRUNDLEGENDES SETZEN ------------------------
  Mat.Nummer            # vNeueNr;
  if (vNur1Beist) then begin
    "Mat.Vorgänger"     # vVorNr;
  end
  else begin
    "Mat.Vorgänger"       # 0;
    Mat.Ursprung          # 0;
  end;
  Mat_Data:SetLoeschmarker('');
  Mat.Ausgangsdatum     # 0.0.0;


  // MENGEN SETZEN ---------------------------
  Mat.Bestand.Stk       # "BAG.FM.Stück";;
  if (Mat.MEH=BAG.FM.MEH) then
    Mat.Bestand.Menge   # BAG.FM.Menge
  else if (Mat.MEH=BAG.FM.MEH2) then
    Mat.Bestand.Menge   # BAG.FM.Menge2
  else
    Mat.Bestand.Menge   # 0.0;

  Mat.Reserviert.Stk    # 0;
  Mat.Reserviert2.Stk   # 0;
  Mat.Reserviert.Gew    # 0.0;
  Mat.Reserviert2.Gew   # 0.0;
  Mat.Reserviert.Menge  # 0.0;
  Mat.Reserviert2.Meng  # 0.0;
  Mat.Gewicht.Netto     # BAG.FM.Gewicht.Netto;
  Mat.Gewicht.Brutto    # BAG.FM.Gewicht.Brutt;
  Mat.Bestand.Gew       # -1.0;        // freimachen zur Berechnung

  if (BAG.FM.Status=1) then begin     // "Gut"-Verwiegung
    Mat_Data:SetStatus(vStatus);      // auf fertig setzen
    // ST 2009-08-13    Projekt: 1161/95
    // Fertigmeldung von geplanten Schrottkarten
    // Material bekommt Status "SCHROTT" und wird nicht gelöscht
    if (Bag.F.PlanSchrottYN) then begin
      Mat_Data:SetLoeschmarker('');             // Nicht löschen
      Mat_Data:SetStatus(c_Status_BAGSchrott);  // Status Schrott
    end;
  end
  else begin                      // "schlechte"-Verwiegungen
    Mat_Data:SetStatus(BAG.FM.Status);
  end;


  // RINGNUMMER ERZEUGEN...
  RunAFX('BAG.FM.NeuesMat','');

  Mat.Nummer            # vNeueNr;

  // Mengen vorab setzen...
  Mat_Data:_SetInternals(y);

  // PREISE SETZEN....
  if (Mat.Bestand.Gew<>0.0) then begin
    Mat.EK.Preis        # Rnd(vWertNeu / (Mat.Bestand.Gew / 1000.0),2);
    Mat.Kosten          # Rnd(vKostenNeu / (Mat.Bestand.Gew / 1000.0),2);
    if (Mat.Bestand.Menge<>0.0) then begin
      if (Mat.MEH='kg') then begin
        Mat.EK.PreisProMEH  # Rnd(vWertNeu / Mat.Bestand.Gew,2);
        Mat.KostenProMEH    # Rnd(vKostenNeu / Mat.Bestand.Gew,2);
      end
      else begin
        Mat.EK.PreisProMEH  # Rnd(vWertNeu / Mat.Bestand.Menge,2);
        Mat.KostenProMEH    # Rnd(vKostenNeu / Mat.Bestand.Menge,2);
      end;
    end
    else begin
      Mat.EK.PreisProMEH  # 0.0;
      Mat.KostenProMEH    # 0.0;
    end;
  end
  else begin
    Mat.EK.Preis        # 0.0;
    Mat.EK.PreisProMEH  # 0.0;
    Mat.Kosten          # 0.0;
    Mat.KostenProMEH    # 0.0;
  end;

  Erx # Mat_Data:Insert(0,'AUTO',BAG.FM.Datum);
  if (Erx<>_rOK) then begin
    RecBufClear(200);
    Error(707103,''); // ST 2009-02-03
    TextClose(vKombiTxt);
    RETURN false;
  end;


  // Ankerfunktion starten
  RunAFX('BAG.FM.NeuesMat.Post','');

  // Ausfall löschen...
  if (BAG.FM.Status=c_Status_BAGAusfall) then begin
    RecRead(200,1,_recLock);
    Mat.Ausgangsdatum   # BAG.FM.Datum
    Mat_Data:SetLoeschmarker('*');
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      Error(707103,'');
      TextClose(vKombiTxt);
      RETURN false;
    end;
  end;
  if (Mat.Status=c_Status_VSB) then begin
    vVSBAktBuf # RekSave(404);
  end;


   // Feritgmat Aktion anlegen...
  if (vNur1Beist=false) then begin
    FOR vA # TextLineRead(vKombiTxt, 1, _TextLineDelete)
    LOOP vA # TextLineRead(vKombiTxt, 1, _TextLineDelete)
    WHILE (vA<>'') do begin
      Mat.A.Materialnr  # cnvia(Strcut(vA,1,15));
      Mat.A.Aktion      # cnvia(Strcut(vA,16,15));
      vKosten           # cnvfa(Strcut(vA,31,15));
      Erx # RecRead(204,1,0);
      if (Erx<=_rLocked) then begin
        Mat.Nummer          # vNeueNr;
        Mat.A.Entstanden    # 0;
        if (Mat.Bestand.Menge<>0.0) then
          Mat.A.KostenW1ProMEH  # Rnd(vKosten / Mat.Bestand.Menge * 1000.0,2);
        if (Mat.Bestand.Gew<>0.0) then
          Mat.A.KostenW1        # Rnd(vKosten / Mat.Bestand.Gew * 1000.0,2);
//debugx('+++ kosten:'+anum(Mat.A.KOstenW1,2)+' bei KEY200 '+anum(Mat.Bestand.Gew,0));
        Erx # Mat_A_Data:Insert(0,'AUTO');
        if (erx<>_rOK) then begin
          RecBufClear(200);
          Error(707102,''); // ST 2009-02-03
          TextClose(vKombiTxt);
          RETURN false;
        end;
      end;
    END;
  end;


  // Aktion für Beistellungskosten?
  if (aBeistellKosten<>0.0) then begin
    RecBufClear(204);
    Mat.A.Aktionsmat    # vNeueNr;
    Mat.A.Entstanden    # 0;
    Mat.A.Aktionstyp    # c_Akt_BA_Beistell;
    Mat.A.Aktionsnr     # BAG.FM.Nummer;
    Mat.A.Aktionspos    # BAG.FM.Position;
    Mat.A.Aktionspos2   # BAG.FM.Fertigung;
    Mat.A.Aktionspos3   # BAG.FM.Fertigmeldung;
    Mat.A.Aktionsdatum  # BAG.FM.Datum;
    Mat.A.Bemerkung     # c_AktBem_BABeistell;
    if (Mat.Bestand.Gew<>0.0) then
      Mat.A.KostenW1    # aBeistellKosten / Mat.Bestand.Gew * 1000.0;
    Erx # Mat_A_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      Error(707102,'');
      TextClose(vKombiTxt);
      RETURN false;
    end;
    if (Mat_A_Data:Vererben()=false) then begin
      Error(707102,'');
      TextClose(vKombiTxt);
      RETURN false;
    end;
  end;

  // Vorgängerkosten dieses BAs in die neue Karte kopieren...
  BA1_Kosten:HoleVorgaengerKosten();

  // evtl. Material reservieren?
  // TODO ArG.Typ.ReservInput : or vNextAktRes
  if (vNextAktion=c_BAG_Fahr09) then begin
    // Reservieruen für FAHREN NACH Anlage weiter unten....
  end
  else if (BAG.F.ReservierenYN) and (BAG.F.Auftragsnummer=0) and (BAG.P.Aktion<>c_BAG_Fahr09) then begin
    RecBufClear(203);
    Mat.R.Materialnr      # Mat.Nummer;
    "Mat.R.Stückzahl"     # Mat.Bestand.Stk;
    Mat.R.Gewicht         # Mat.Bestand.Gew;
    "Mat.R.Trägertyp"     # '';
    "Mat.R.TrägerNummer1" # 0;
    "Mat.R.TrägerNummer2" # 0;
    Mat.R.Kundennummer    # "BAG.F.ReservFürKunde";
    vBuf100 # RecBufCreate(100);
    RecLink(vBuf100,203,3,_recFirst); // Kunde holen
    Mat.R.KundenSW        # vBuf100->Adr.Stichwort;
    RecBufDestroy(vBuf100);
    Mat.R.Auftragsnr      # BAG.F.Auftragsnummer;
    Mat.R.AuftragsPos     # BAG.F.AuftragsPos;
    if (Mat_Rsv_Data:Neuanlegen()=false) then begin
      Error(707104,AInt(Mat.Nummer));
      TextClose(vKombiTxt);
      RETURN false;
   end;
  end;

  // theoretischen Output ändern -------------------------------------------
  RecBufClear(701);
  BAG.IO.Nummer         # BAG.FM.Nummer;
  BAG.IO.ID             # BAG.FM.BruderID;

  Erx # RecRead(701,1,_recLock);
  if (Erx<>_rOK) then begin
    Error(010027,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.BruderID));
    TextClose(vKombiTxt);
    RETURN false;
  end;
  if (BAG.P.Aktion<>c_BAG_Spulen) then
    BAG.IO.Ist.In.Stk  # BAG.IO.Ist.In.Stk   + "BAG.FM.Stück";
  BAG.IO.Ist.In.GewN # BAG.IO.Ist.In.GewN  + BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.In.GewB # BAG.IO.Ist.In.GewB  + BAG.FM.Gewicht.Brutt;
  if (BAG.FM.Meh=BAG.IO.MEH.In) then
    BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge + BAG.FM.Menge;
  Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    Error(707105,'');
    TextClose(vKombiTxt);
    RETURN false;
  end;


  // neuen IO-Posten anlegen -----------------------------------------------
  BAG.IO.VonID # vAktID;

  BAG.IO.VonBAG         # BAG.FM.Nummer;
  BAG.IO.VonPosition    # BAG.FM.Position;
  BAG.IO.VonFertigung   # BAG.FM.Fertigung;
  BAG.IO.VonFertigmeld  # BAG.FM.Fertigmeldung;

  // SPERRE?
  if (BAG.FM.Status<>1) then begin
    BAG.IO.NachBAG        # 0;
    BAG.IO.NachPosition   # 0;
    BAG.IO.NachFertigung  # 0;
    BAG.IO.NachID         # 0;
  end;

  BAG.IO.ID             # 1;
  BAG.IO.Materialtyp    # c_IO_Mat;
  BAG.IO.Materialnr     # vNeueNr;
  BAG.IO.MaterialRstnr  # vNeueNr;
  BAG.IO.BruderID       # BAG.FM.BruderID;

  BAG.IO.Ist.IN.Stk     # "BAG.FM.Stück";
  BAG.IO.Ist.IN.GewN    # BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.IN.GewB    # BAG.FM.Gewicht.Brutt;
  if (BAG.FM.Meh=BAG.IO.MEH.IN) then
    BAG.IO.Ist.IN.Menge # BAG.FM.Menge
  else if (BAG.FM.Meh2=BAG.IO.MEH.IN) and (BAG.FM.MEH2<>'') then
    BAG.IO.Ist.IN.Menge # BAG.FM.Menge2
  else
    BAG.IO.Ist.IN.Menge # 0.0;

  BAG.IO.Plan.IN.Stk    # BAG.IO.Ist.IN.Stk;
  BAG.IO.Plan.IN.GewN   # BAG.IO.Ist.IN.GewN;
  BAG.IO.Plan.IN.GewB   # BAG.IO.Ist.IN.GewB;
  BAG.IO.Plan.IN.Menge  # BAG.IO.Ist.IN.Menge;

  BAG.IO.Plan.Out.Stk   # BAG.IO.Ist.IN.Stk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.Ist.IN.GewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.Ist.IN.GewB;
  if (BAG.FM.Meh=BAG.IO.MEH.Out) then
    BAG.IO.Plan.Out.Meng # BAG.FM.Menge
  else if (BAG.FM.MEH2=BAG.IO.MEH.Out) and (BAG.FM.MEH2<>'') then
    BAG.IO.Plan.Out.Meng # BAG.FM.Menge2
  else
    BAG.IO.Plan.Out.Meng # Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);

  // 2009
  BAG.IO.Ist.Out.Stk    # 0;
  BAG.IO.Ist.Out.GewN   # 0.0;
  BAG.IO.Ist.Out.GewB   # 0.0;
  BAG.IO.Ist.Out.Menge  # 0.0;

  WHILE (BA1_IO_Data:Insert(0,'AUTO')<>_rOK) do
    BAG.IO.ID # BAG.IO.ID + 1;

// TODO ArG.Typ.ReservInput : or vNextAktRes
  if (vNextAktion=c_BAG_Fahr09) then begin
    // FAHR-Reservierung neu anlegen ---------------------------------------
    RecBufClear(203);
    Mat.R.Materialnr      # Mat.Nummer;
    "Mat.R.Stückzahl"     # Mat.Bestand.Stk;
    Mat.R.Gewicht         # Mat.Bestand.Gew;
    // für MATMEH
    Mat.R.Menge           # Mat.Bestand.Menge;

    Mat.R.Bemerkung       # vNextAktion;
    "Mat.R.Trägertyp"     # c_Akt_BAInput;
    "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
    "Mat.R.TrägerNummer2" # BAG.IO.ID;
    if (Mat_Rsv_Data:Neuanlegen()=false) then begin
      Error(707106,''); // ST 2009-02-03
      TextClose(vKombiTxt);
      RETURN false;
    end;
  end;

  vNeuID # BAG.IO.ID;

  // Fertigungsmengen erhöhen ----------------------------------------------
  Recread(703,1,_RecLock);
  BAG.F.Fertig.Gew    # BAG.F.Fertig.Gew    + BAG.FM.Gewicht.Netto;
  BAG.F.Fertig.Stk    # BAG.F.Fertig.Stk    + "BAG.FM.Stück";

  // für MATMEH
  vM # Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.F.MEH);
  BAG.F.Fertig.Menge  # BAG.F.Fertig.Menge  + vM;

  Erx # BA1_F_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    Error(707107,'');   // ST 2009-02-03
    TextClose(vKombiTxt);
    RETURN false;
  end;

  // BA-Daten setzen -------------------------------------------------------
  RecRead(707,1,_recLock);
  BAG.FM.Materialnr # vNeueNr;
  BAG.FM.OutputID   # vNeuID;
  Erx # Rekreplace(707,_recUnlock,'AUTO');
  if (Erx<>_rOK) then begin
    Error(707108,'');  // ST 2009-02-03
    TextClose(vKombiTxt);
    RETURN false;
  end;

  // Auftragsaktion anlegen ------------------------------------------------
  if (vStatus=c_Status_BAGOutKunde) then begin      // VSB für Auftrag!!!
    if (BAG.P.ZielVerkaufYN=n) or (BAG.P.Aktion<>c_BAG_Fahr) then begin
      if (BA1_Fertigmelden:AufVSBAktion(BAG.FM.Datum)=n) then begin
        Error(10041,AInt(BAG.F.Nummer)+'/'+AInt(BAg.F.Position)+'/'+AInt(BAG.F.Fertigung)+'|'+AInt(BAG.F.Auftragsnummer)+'/'+AInt(BAG.F.Auftragspos));
        TextClose(vKombiTxt);
        RETURN false;
      end;
    end;
  end;


  // Lohnfahrauftrag?? dann evtl. LFS refreshen
  if (BAG.P.Aktion=c_BAG_Fahr) then begin
    // zugehörigen Lohnlieferschein generieren...
    if (Lfs_LFA_Data:Fertigmeldung(BAG.Nummer, vNeuID, BAG.FM.Datum, BAG.FM.Zeit)=false) then begin
      TextClose(vKombiTxt);
      RETURN false;
    end;
  end;

  // nachfolgender LFA? dann LFS updaten,,,
  // bzw. VERSAND? dann VSP updaten...
  if (BAG.IO.NachBAG<>0) then begin
    vBuf702 # RekSave(702);

    Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin

      if (BAG.P.Aktion=c_BAG_Fahr) then begin
        // Output aktualisieren
        if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
          Error(707109,AInt(Bag.P.Nummer)+'/'+AInt(Bag.P.Position));
          TextClose(vKombiTxt);
          RETURN false;
        end;
      end;

    end;

    RekRestore(vBuf702);
  end;


  // evtl. Material in Versandpool -----------------------------------------
  if (vVSDAdr<>0) then begin
    // nur tatsächlich vorhandenes MAterial
    RecBufClear(655);
    VsP.Vorgangstyp       # c_VSPTyp_BAG;
    VsP.Vorgangsnr        # BAG.FM.Nummer;
    VsP.Vorgangspos1      # BAG.FM.OutputID;
    VsP.Vorgangspos2      # 0;
    VsP.Materialnr        # Mat.Nummer;
    VsP.Ziel.Adresse      # vVSDAdr;
    VsP.Ziel.Anschrift    # vVSDAnschr;
    VsP.Ziel.Lagerplatz   # '';
    VsP.Ziel.Tour         # '';
    if (VsP_Data:SavePool()=0) then begin
      TextClose(vKombiTxt);
      RETURN false;
    end;

    vBuf702 # RekSave(702);
   Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin
      VsP_Data:ErzeugePoolZumVersand();
    end;
    RekRestore(vBuf702);
  end;

  // ERFOLG!
  RETURN true;
end;



//========================================================================
//========================================================================
sub RestorePos()  : logic;
local begin
  Erx : int;
end;
begin

  // SCHROTTFERTIGUNG HOLEN:
  BAG.F.Nummer    # BAG.P.Nummer;
  BAG.F.Position  # BAG.P.Position;
  BAG.F.Fertigung # 999;
  Erx # RecRead(703,1,0);
  if (Erx>_rLocked) then RETURN true;

  // VERWIEGUNGEN LOOPEN ***********************************************
  FOR Erx # recLink(707,703,10,_RecFirst)
  LOOP Erx # RecLink(707,703,10,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (BA1_FM_data:Entfernen()=false) then begin
      RETURN false;
    end;
  END;

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================