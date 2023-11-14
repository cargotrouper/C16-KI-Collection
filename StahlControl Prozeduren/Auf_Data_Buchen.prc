@A+
//===== Business-Control =================================================
//
//  Prozedur  Auf_Data_Buchen
//                  OHNE E_R_G
//  Info
//
//
//  21.10.2008  AI  Erstellung der Prozedur
//  14.04.2010  AI  ArtDFkat nimmt Chargen-EK
//  27.04.2010  AI  BUGFIX: ArtDFakt nimmt Chargen-EK
//  16.11.2010  AI  BUGFIX: ArtDFakt mit vorheriger VSB rechnete Rest-VSB falsch
//  04.10.2011  AI  DFAKT: KalkulationsEK nur bei NICHT Chargenführung
//  21.06.2012  AI  alle Artikelauftragsrestmengenänderungen (Art_DatA:Aufrrags) werden schon über die RecAclAll in der Aktionslsite gelöst und sind deaktiviert
//  07.04.2015  AH  Auftrags-SL in Kommission aktiviert
//  22.11.2021  AH  Edit:  "DFaktArc" mit Subfunktion für Auf.P.SL buchen
//  02.02.2022  AH  FIX: "DFaktArtC" falsche Mengen bei Art.Bewegung
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//  SUB MatzArt(aArtikel : alpha; aAdresse : int; aAnschrift : int; aCharge : alpha; aManuell : logic; aSL : logic; opt aMenge  : float) : logic;
//  SUB DFaktArtC(aArtikel : alpha; aAdresse : int; aAnschrift : word; aCharge : alpha; aManuell : logic; aMenge : float; aDatFak : date) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

//========================================================================
// MatzArt
//
//========================================================================
sub MatzArt(
  aArtikel      : alpha;
  aAdresse      : int;
  aAnschrift    : int;
  aCharge       : alpha;
  aManuell      : logic;
  aSL           : logic;
  aMenge        : float;
  aStk          : int;
  aMengeFak     : float;
) : logic;
local begin
  Erx       : int;
  vMenge    : float;
  vStk      : int;
  vGew      : float;
  vMengeFak : float;

  vAufMenge : float;
  vVSBMenge : float;
  vVSBStk   : int;
  vMaxMenge : float;

  vEdit     : logic;
  vVorgabe  : float;
  vNr       : int;
  vPos1     : int;
  vPos2     : int;
end;
begin

  RecLink(100,401,4,_recFirst);   // Kunde holen

  vNr   # Auf.P.Nummer;
  vPos1 # Auf.P.Position;
  vPos2 # 0;

  RecBufClear(252);
  if (aSL) then begin   // Stückliste?
    vAufMenge # Auf.SL.Menge;
    vVSBMenge # Auf.SL.Prd.LFS + Auf.SL.Prd.VSAuf;;
    //vStk      # "Auf.SL.Stückzahl";
    vVSBStk   # Auf.SL.Prd.LFS.Stk + Auf.SL.Prd.VSAuf.Stk;;
    vPos2     # Auf.SL.lfdNr;
  end
  else begin            // Auftragsposition?
    vAufMenge # Auf.P.Menge;
    vVSBMenge # Auf.P.Prd.LFS+Auf.P.Prd.VSAuf;
    //vStk      # "Auf.P.Stückzahl";
    vVSBStk   # Auf.P.Prd.LFS.Stk + Auf.P.Prd.VSAuf.Stk;;
  end;
  vMaxMenge # vAufMenge-vVSBMenge;

  Art.C.ArtikelNr     # aArtikel;
  Art.C.Charge.intern # aCharge;
  Art_Data:ReadCharge();


  // bisherige VSB suchen
  vEdit # n;
  Erx # RecLink(404,401,12,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Auf.A.Aktionstyp=c_Akt_VSB) then begin
      // ist für GLEICHE Charge??
      if (Auf.A.Menge<>0.0) and (Auf.A.Position2=vPos2) and
        (Auf.A.ArtikelNr=aArtikel) and (Auf.A.Charge.Adresse=aAdresse) and
        (Auf.A.Charge.Anschr=aAnschrift) and (Auf.A.Charge=aCharge) then begin
          vEdit # y;
          BREAK;
        end;
    end;

    Erx # RecLink(404,401,12,_recNext);
  END;

  if (vEdit) then vVorgabe  # Auf.A.Menge;
  if (vVorgabe=0.0) then vVorgabe # vMaxMenge;

  // Abfrage oder Vorgegeben?
  if (aManuell) then begin
    vStk # 0;
    REPEAT
      vMenge # vVorgabe;
      if (vMenge>Art.C.Bestand) then vMenge # Art.C.Bestand;

      vGew # Rnd(Lib_Einheiten:WandleMEH(252, vStk, 0.0, vMengeFak, Auf.P.MEH.Preis, 'kg'),2);
      if (Dlg_DFaktArt:MatzArt(var vMenge, var vStk, var vMengeFak, var vGew)<>true) then RETURN false;
      if (vMenge<0.0) then begin
        Msg(401256,'',_WinIcoError, _WinDialogOk,1);
        CYCLE;
      end;
      if (vMenge>vMaxMenge) then begin
        if (Msg(401257,'',_WinIcoWarning, _WinDialogYesNo,2)<>_Winidyes) then
          CYCLE;
      end;
    UNTIL (y);

  end
  else begin
    vMenge    # aMenge;
    vStk      # aStk;
    vMengeFak # aMengeFak;
  end;
  if (vMenge<0.0) then RETURN false;


  Art_Data:ReadCharge();

  if (aManuell) then TRANSON;

  Auf.P.Nummer    # vNr;        // Posten holen
  Auf.P.Position  # vPos1;
  RecRead(401,1,0);
  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  if (Erx>_rLocked) then RecBufClear(835);


  if (vEdit) then begin
    if (Auf_A_Data:Entfernen()=false) then begin
      if (aManuell) then begin
        TRANSBRK;
        Msg(999999,'1872',0,0,0);
      end;
      RETURN false;
    end;

    // alte Reservierung löschen
    Art_Data:Reservierung(aArtikel, aAdresse, aAnschrift, aCharge, 0,c_Auf, vNr, vPos1, vPos2, -vVorgabe, -vStk, 0);

    if (AAr.ReservierePosYN) then begin
      if (vVorgabe>vMAXMenge) then begin
// 21.6.2012 AI kümmert sich die AKtion drum !!!
//        Art_Data:Auftrag(vMAXMenge);
      end
      else begin
//        Art_Data:Auftrag(vVorgabe);
      end;
    end;
  end;



  Auf.P.Nummer    # vNr;        // Posten holen
  Auf.P.Position  # vPos1;
  RecRead(401,1,0);

  // Aktion neu anlegen
  RecbufClear(404);
  Auf.A.ArtikelNr       # Art.Nummer;
  Auf.A.Charge.Adresse  # aAdresse;
  Auf.A.Charge.Anschr   # aAnschrift;
  Auf.A.Charge          # aCharge;
  Erx # RecLink(252,404,4,_recfirst); // Charge holen
  if (Erx>_rLocked) then begin
    if (aManuell) then begin
      TRANSBRK;
      Msg(999999,'1872',0,0,0);
    end;
    RETURN false;
  end;

  Auf.A.Aktionsnr     # vNr;
  Auf.A.AktionsPos    # vPos1;
  Auf.A.AktionsPos2   # vPos2;
  //Aufx.A.Adressnummer  # Adr.Nummer;
  if (StrCnv(Art.MEH,_StrUppeR)='STK') then
    vStk # CnvIF(vMenge);
  if (Art.C.Dicke<>0.0) then
    Auf.A.Dicke       # Art.C.Dicke;
  Auf.A.Breite        # Art.Breite;
  if (Art.C.Breite<>0.0) then
    Auf.A.Breite      # Art.C.Breite;
  "Auf.A.Länge"       # "Art.Länge";
  if ("Art.C.Länge"<>0.0) then
    "Auf.A.Länge"     # "Art.C.Länge";
  Auf.A.Menge         # vMenge;
  "Auf.A.Stückzahl"   # vStk;
  Auf.A.MEH           # Art.MEH;
  Auf.A.Menge.Preis   # vMengeFak;
  Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
  Auf.A.Gewicht       # vGew;
//  Auf.A.Gewicht       # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", 0.0, Auf.A.Menge, Auf.A.MEH, 'kg');
  Auf.A.NettoGewicht  # Auf.A.Gewicht;
  // Umrechnen in Berechnungseinheit
  // Auf.A.Mengex.Preis   # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, vMenge, Auf.A.MEH, Auf.A.MEH.Preis);

  Auf.A.AktionsTyp    # c_Akt_VSB;
  Auf.A.Bemerkung     # c_AktBem_VSB;
  if (Art.C.Bezeichnung<>'') then Auf.A.Bemerkung # Art.C.Bezeichnung;
  Auf.A.AktionsDatum  # today;
  if (Auf_A_Data:NeuAnlegen(n,aSL)<>_rOK) then begin
    if (aManuell) then begin
      TRANSBRK;
      Msg(999999,'2451',0,0,0);
    end;
    RETURN false;
  end;

  // neue Reservierung anlegen
  Art_Data:Reservierung(aArtikel, aAdresse, aAnschrift, aCharge, 0,c_Auf, vNr, vPos1, vPos2, vMenge, vStk, 0);
  if (AAr.ReservierePosYN) then begin
    if (vMenge>vMAXMenge) then begin
//      Art_Data:Auftrag( -vMAXMenge);
    end
    else begin
//      Art_Data:Auftrag( -vMenge);
    end;
  end;
  if (aManuell) then begin
    TRANSOFF;
    Msg(401254,'',_WinIcoInformation, _windialogok,1);
  end;

  RETURN true;
end;


//========================================================================
// _DoitDFaktArtC
//        Sub für Artikel(250) direkt verkaufen
//========================================================================
sub _DoitDFaktArtC(
  aArtikel      : alpha;
  aAdresse      : int;
  aAnschrift    : word;
  aCharge       : alpha;
  aFakMenge     : float;
  aAufMenge     : float;
  aAufStk       : int;
  aAufGew       : float;
  aArtMenge     : float;
  aArtStk       : int;
  aArtGew       : float;
  aDatFak       : date;
) : logic;
local begin
  Erx         : int;
  vBem        : alpha;
  vNr         : int;
  vPos1       : int;
  vPos2       : int;

  vVsbMenge   : float;
  vVsbStk     : int;

  vOK         : logic;
  vX          : float;
  xvMAuf       : float;
  xvMoffen     : float;
  vMMax       : float;
  vMueberVSB  : float;
  vEKPreis    : float;
  vKalk       : float;
end;
begin

  Art.Nummer # aArtikel;
  Erx # RecRead(250,1,0);   // Artikel holen
  If (Erx>_rLocked) then RETURN false;

  // 01.04.2022 AH: HWE
  if (aAufStk=0) and (Auf.A.MEH='Stk') then aAufStk # cnvif(aAufMenge);
  if (aAufStk=0) and (Auf.A.MEH.Preis='Stk') then aAufStk # cnvif(aFakMenge);

  vNr     # Auf.P.Nummer;
  vPos1   # Auf.P.Position;
  vPos2   # 0;

  Art.C.ArtikelNr     # aArtikel;
  Art.C.Adressnr      # aAdresse;
  Art.C.Anschriftnr   # aAnschrift;
  Art.C.Charge.Intern # aCharge;
  Erx # RecRead(252,1,0);   // Charge holen
  If (Erx>_rLocked) then RETURN false;
  vEKPreis  # Art.C.EKDurchschnitt;

//  vMAuf   # Auf.P.Menge;
  FOR Erx # RecLink(404,401,12,_recFirst)
  LOOP Erx # RecLink(404,401,12,_recNExt)
  WHILE (erx<=_rLocked) do begin
    if (Auf.A.AktionsTyp=c_Akt_VSB) and (Auf.A.Artikelnr=Art.C.Artikelnr) and
        (Auf.A.Charge.Adresse=aAdresse) and (Auf.A.Charge.Anschr=aAnschrift) and
        (Auf.A.Charge=aCharge) then begin
      vVsbMenge   # vVsbMenge + Auf.A.Menge;
      vVsbStk # vVsbStk + "Auf.A.Stückzahl";
      BREAK;
    end;
  END;

//  vMoffen # vMAuf - Auf.P.Prd.LFS - Auf.P.Prd.VSAuf - vMVSB;
//  vMMax   # Auf.P.Prd.Rest;

  vBem    # Art.C.Bezeichnung;


  // alte VSB löschen
  if (vVsbMenge>0.0) or (vVsbStk>0) then begin
    Art_Data:Reservierung(aArtikel, aAdresse, aAnschrift, aCharge, 0,c_Auf, vNr, vPos1, vPos2, -Min(aAufMenge, vVsbMenge), -Min(aAufStk, vVsbStk), 0);

    vVsbMenge # vVsbMenge - aAufMenge;
    vVsbStk   # vVsbStk - aAufStk;

    if (vVsbMenge>=0.0) then begin    // bisherige VSB-Aktion anpassen    2023-04-19  AH auf ">="
      FOR Erx # RecLink(404,401,12,_recFirst)
      LOOP Erx # RecLink(404,401,12,_recNExt)
      WHILE (erx<=_rLocked) do begin
        if (Auf.A.AktionsTyp=c_Akt_VSB) and (Auf.A.Artikelnr=Art.C.Artikelnr) and
            (Auf.A.Charge.Adresse=aAdresse) and (Auf.A.Charge.Anschr=aAnschrift) and
            (Auf.A.Charge=aCharge) then begin
          RecRead(404,1,_recLock);
          Auf.A.Menge         # vVsbMenge;
          "Auf.A.Stückzahl"   # vVsbStk;
          if (Auf.A.MEH='kg') then
            "Auf.A.Gewicht" # Auf.A.Menge
          else if (Auf.A.MEH='t') then
            "Auf.A.Gewicht" # Auf.A.Menge * 1000.0
          else
            Auf.A.Gewicht     # aAufGew;
          Auf.A.Menge.Preis   # Auf.A.Menge.Preis - aFakMenge;
          Auf.A.Nettogewicht  # Auf.A.Gewicht;
          if ("Auf.A.Stückzahl"<0) then     "Auf.A.Stückzahl" # 0;
          if (Auf.A.Gewicht<0.0) then       Auf.A.Gewicht # 0.0;
          if (Auf.A.NettoGewicht<0.0) then  Auf.A.NettoGewicht # 0.0;
          Rekreplace(404,_recUnlock,'AUTO');
          BREAK;
        end;
      END;
    end;
  end;

  Auf.P.Nummer    # vNr;        // Posten holen
  Auf.P.Position  # vPos1;
  RecRead(401,1,_recLock);
  Auf.P.Prd.VSB # vVsbMenge;
  Auf_Data:PosReplace(_recUnlock,'AUTO');

  // Aktion neu anlegen
  RecBufClear(404);
  Auf.A.Aktionstyp    # c_Akt_DFakt;
  if (vBem='') then
    Auf.A.Bemerkung   # c_AktBem_DFakt
  else
    Auf.A.Bemerkung   # vBem;
  Auf.A.Aktionsnr     # 0;
  Auf.A.Aktionspos    # 0;
  Auf.A.TerminStart   # aDatFak;
  Auf.A.TerminEnde    # aDatFak;
  Auf.A.AktionsDatum  # aDatFak;

  Auf.A.Dicke         # Art.Dicke;
  if (Art.C.Dicke<>0.0) then
    Auf.A.Dicke       # Art.C.Dicke;
  Auf.A.Breite        # Art.Breite;
  if (Art.C.Breite<>0.0) then
    Auf.A.Breite      # Art.C.Breite;
  "Auf.A.Länge"       # "Art.Länge";
  if ("Art.C.Länge"<>0.0) then
    "Auf.A.Länge"     # "Art.C.Länge";

  Auf.A.Menge           # aAufMenge;
  Auf.A.MEH             # Auf.P.MEH.Einsatz;
  Auf.A.Menge.Preis     # aFakMenge;
  Auf.A.MEH.Preis       # Auf.P.MEH.Preis;
  "Auf.A.Stückzahl"     # aAufStk;

  Auf.A.Gewicht         # aAufGew;
  Auf.A.Nettogewicht    # Auf.A.Gewicht;

  Auf.A.ArtikelNr       # aArtikel;
  Auf.A.Charge.Adresse  # aAdresse;
  Auf.A.charge.Anschr   # aAnschrift;
  Auf.A.Charge          # aCharge;

  // Kalkulationspreis??
  vOK # n;
  if ("Art.ChargenführungYN"=false) then begin //or (Art.Typ=c_Art_PRD) then begin
    FOR Erx # RecLink(405,401,7,_RecFirst)
    LOOP Erx # RecLink(405,401,7,_RecNext)
    WHILE (erx<=_rLocked) do begin
      if (Auf.K.PEH=0) then Auf.K.PEH # 1;
      if (Auf.K.MengenbezugYN) and (Auf.K.MEH=Auf.P.MEH.Preis) and (Auf.K.Bezeichnung=aArtikel) then begin
        Auf.A.EKPreisSummeW1  # Auf.A.EKPreisSummeW1 +
                                Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * Auf.A.Menge,2);
        vOK # y;
      end;
    END;
  end;


  RecbufClear(254);   // Preise leeren

  if (vOK=n) then begin
    // evtl. Chargenpreis holen...
    if (Auf.A.Charge<>'') then begin
      Art.P.PEH     # Art.PEH;
      Art.P.MEH     # Art.MEH;
      Art.P.PreisW1 # vEKPreis;
    end;
    // sonst EK-Preis aus Tabelle holen...
    if (Art.P.MEH='') then begin
      Art_P_Data:LiesPreis('Ø-EK',0); //Ø-EK
      if (Art.P.MEH='') then
        Art_P_Data:LiesPreis('L-EK',0);
      if (Art.P.MEH='') then
        Art_P_Data:LiesPreis('L-EK',-1);
      if (Art.P.MEH='') then
        Art_P_Data:LiesPreis('EK',0);
    end;

    if (Auf.A.MEH<>Art.P.MEH) and (Art.P.MEH<>'') then begin
      vX # Lib_Einheiten:WandleMEH(250, "Auf.A.Stückzahl", Auf.A.Nettogewicht, Auf.A.Menge, Auf.A.MEH, Art.P.MEH);
      Auf.A.EKPreisSummeW1 # Rnd(Art.P.PreisW1 * vX / CnvfI(Art.P.PEH),2);
    end
    else begin
      Auf.A.EKPreisSummeW1  # Rnd(Art.P.PreisW1 * Auf.A.Menge / CnvfI(Art.P.PEH),2);
    end;
  end;


  Auf.A.InterneKostW1   # 0.0;
  Erx # Auf_A_Data:NeuAnlegen(n,n);
  if (Erx<>_rOK) then begin
    RETURN false;
  end;

  // Artikel abbuchen ------------------------------------
  RecBufClear(252);
  Art.C.ArtikelNr     # Auf.A.ArtikelNr;
  Art.C.Charge.Intern # Auf.A.Charge;

  RecBufClear(253);
  Art.J.Datum           # Auf.A.Aktionsdatum;
  Art.J.Bemerkung       # c_AKt_Dfakt+' '+AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position);
  "Art.J.Stückzahl"     # -aArtStk;
  Art.J.Menge           # -aArtMenge;
  "Art.J.Trägertyp"     # 'AUF';
  "Art.J.Trägernummer1" # Auf.A.Nummer;
  "Art.J.Trägernummer2" # Auf.A.Position;
  "Art.J.Trägernummer3" # Auf.A.Position2;
  vOK # Art_Data:Bewegung(0.0, 0.0);
  if (vOK=false) then begin
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub DFaktSL(aManuell : logic) : logic
local begin
  Erx   : int;
  vFakM : float;
  vStk  : int;
  vGew  : float;
  vAufM : float;
  vArtM : float;
  v409  : int;
end;
begin
  
  TRANSON;

  // Stückliste loopen
  FOR Erx # RecLink(409,401,15,_recFirst)
  LOOP Erx # RecLink(409,401,15,_recNext)
  WHILE (Erx<=_rLocked) do begin
  
    vFakM # Rnd(Lib_Einheiten:WandleMEH(252, "Auf.SL.Stückzahl", Auf.SL.Gewicht, Auf.SL.Menge, Auf.SL.MEH, Auf.P.MEH.Preis),Set.Stellen.Menge);
    vGew  # Rnd(Lib_Einheiten:WandleMEH(252, "Auf.SL.Stückzahl", Auf.SL.Gewicht, Auf.SL.Menge, Auf.SL.MEH, 'kg'),Set.Stellen.Gewicht);
    vStk  # cnvif(Lib_Einheiten:WandleMEH(252, "Auf.SL.Stückzahl", Auf.SL.Gewicht, Auf.SL.Menge, Auf.SL.MEH, 'Stk'));
    vAufM # Rnd(Lib_Einheiten:WandleMEH(252, "Auf.SL.Stückzahl", Auf.SL.Gewicht, Auf.SL.Menge, Auf.SL.MEH, Auf.P.MEH.Einsatz),Set.Stellen.Menge);
    vArtM # Rnd(Lib_Einheiten:WandleMEH(252, "Auf.SL.Stückzahl", Auf.SL.Gewicht, Auf.SL.Menge, Auf.SL.MEH, Art.MEH),Set.Stellen.Menge);

    v409 # RekSave(409);
    if (_DoitDFaktArtC(Auf.SL.Artikelnr, 0,0,'', vFakM, vAufM, vStk, vGew, vArtM, vStk, vGew, today)=false) then begin
      RekRestore(v409);
      TRANSBRK;
      if (aManuell) then begin
        ERROROUTPUT;
        Msg(999999,'2291',0,0,0);
      end;
      RETURN false;
    end;
    RekRestore(v409);
  END;
  
  // Marker berechnen
  RecRead(401,1,_RecNoLoad | _RecLock);
  Auf_Data:Pos_BerechneMarker();
  Auf_Data:PosReplace(_recUnlock,'AUTO');
  RecRead(400,1,_RecNoLoad | _RecLock);
  Auf_Data:BerechneMarker();
  RekReplace(400,_recUnlock,'AUTO');

  TRANSOFF;

  if (aManuell) then begin
    Msg(401251,'',_WinIcoInformation, _windialogok,1);
  end;

  RETURN true;
 
end;


//========================================================================
// DFaktArtC
//        Artikel(250) direkt verkaufen
//========================================================================
sub DFaktArtC(
  aArtikel      : alpha;
  aAdresse      : int;
  aAnschrift    : word;
  aCharge       : alpha;
  aManuell      : logic;
  aMenge        : float;
  aStk          : int;
  aMengeFak     : float;
  aDatFak       : date;
) : logic;
local begin
  Erx         : int;
  vMenge      : float;
  vStk        : int;
  vGew        : float;
  vMengeFak   : float;
  vBem        : alpha;

  vOK         : logic;
  vNr         : int;
  vPos1       : int;
  vPos2       : int;
  vMAuf       : float;
  vMVSB       : float;
  vMoffen     : float;
  vMMax       : float;
  vMueberVSB  : float;
  vMVSBneu    : float;
  vEKPreis    : float;

  vKalk       : float;
end;
begin
//debugx(anum(aMenge,0)+' '+aint(aStk)+' '+anum(aMengeFak,0));
  Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
  Erx # RecLink(100,401,4,_recFirst);   // Kunde holen
  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  if (Erx>_rLocked) then RecBufClear(835);

  Art.Nummer # aArtikel;
  Erx # RecRead(250,1,0);   // Artikel holen
  If (Erx>_rLocked) then RETURN false;

  vNr     # Auf.P.Nummer;
  vPos1   # Auf.P.Position;
  vPos2   # 0;

  Art.C.ArtikelNr     # aArtikel;
  Art.C.Adressnr      # aAdresse;
  Art.C.Anschriftnr   # aAnschrift;
  Art.C.Charge.Intern # aCharge;
  Erx # RecRead(252,1,0);   // Charge holen
  If (Erx>_rLocked) then RETURN false;
  vEKPreis  # Art.C.EKDurchschnitt;

  vMAuf   # Auf.P.Menge;
  //vMVSB   # Auf.P.Prd.VSB;
  Erx # RecLink(404,401,12,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.A.AktionsTyp=c_Akt_VSB) and (Auf.A.Artikelnr=Art.C.Artikelnr) and
        (Auf.A.Charge.Adresse=aAdresse) and (Auf.A.Charge.Anschr=aAnschrift) and
        (Auf.A.Charge=aCharge) then begin
      vMVSB # vMVSB + Auf.A.Menge;
      BREAK;
    end;
    Erx # RecLink(404,401,12,_recNExt);
  END;


  vMoffen # vMAuf - Auf.P.Prd.LFS - Auf.P.Prd.VSAuf - vMVSB;
  vMMax   # Auf.P.Prd.Rest;

  vBem    # Art.C.Bezeichnung;

  // Abfrage oder Vorgegeben?
  if (aManuell) then begin
    REPEAT
      vMenge  # vMMax;
      if (vMenge>Art.C.Bestand) and (Art.C.Charge.Intern<>'') then vMenge # Art.C.Bestand;
      if (Art.C.Charge.Intern='') then vStk # aStk;
      vGew # Rnd(Lib_Einheiten:WandleMEH(252, vStk, 0.0, vMengeFak, Auf.P.MEH.Preis, 'kg'),2);
//debugx(anum(vMenge,0)+'M '+aint(vStk)+'Stk '+anum(vMengeFak,0)+'$ '+anum(vGew,0)+'kg');
      if (Dlg_DFaktArt:DFaktArt(var vMenge, var vStk, var vMengeFak,var vGew, var aDatFak,var vBem, Art.MEH, Auf.P.MEh.Preis)<>true) then RETURN false;
      if (vMenge<0.0) then begin
        Msg(401256,'',_WinIcoError, _WinDialogOk,1);
        CYCLE;
      end;
      if (vMenge>vMMax) then begin
        if (Msg(401257,'',_WinIcoWarning, _WinDialogYesNo,2)<>_Winidyes) then
          CYCLE;
      end;
    UNTIL (y);
    if (Msg(401250,ANum(vMenge,-1)+' '+Art.MEH,_WinIcoWarning, _windialogYesNo,1)=_WinIdNo) then RETURN false;
   end
  else begin
    vMenge    # aMenge;
    vStk      # aStk;
    vMengeFak # aMengeFak;
    vGew # Rnd(Lib_Einheiten:WandleMEH(252, vStk, 0.0, vMengeFak, Auf.P.MEH.Preis, 'kg'),2);
  end;
  if (vMenge<0.0) then RETURN false;

  if (aManuell) then TRANSON;

/**** 22.11.2021
  // alte VSB löschen
  if (vMenge>vMVSB) then begin
    Art_Data:Reservierung(aArtikel, aAdresse, aAnschrift, aCharge, 0,c_Auf, vNr, vPos1, vPos2, -vMVSB, -vStk, 0);
    vMVSBNeu # 0.0;
    vMueberVSB # vMenge - vMVSB;

    if (AAr.ReservierePosYN) then begin
      if (vMueberVSB>vMoffen) then begin
//        Art_Data:Auftrag( -vMoffen);
      end
      else begin
//        Art_Data:Auftrag( -vMueberVSB);
      end;
    end;

  end
  else begin
    Art_Data:Reservierung(aArtikel, aAdresse, aAnschrift, aCharge, 0,c_Auf, vNr, vPos1, vPos2, -vMenge, -vStk, 0);
    vMVSBNeu # vMVSB - vMenge;
  end;


  if (vMVSB<>0.0) then begin    // bisherige VSB-Aktion anpassen
//    if (Auf_A_Data:LiesAktion(vNr,vPos1,vPos2, c_Akt_VSB, vNr,vPos1,vPos2)) then begin
    Erx # RecLink(404,401,12,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (Auf.A.AktionsTyp=c_Akt_VSB) and (Auf.A.Artikelnr=Art.C.Artikelnr) and
          (Auf.A.Charge.Adresse=aAdresse) and (Auf.A.Charge.Anschr=aAnschrift) and
          (Auf.A.Charge=aCharge) then begin
        RecRead(404,1,_recLock);
        Auf.A.Menge # vMVSBNeu;
        if (Auf.A.MEH='kg') then
          "Auf.A.Gewicht" # Auf.A.Menge
        else if (Auf.A.MEH='t') then
          "Auf.A.Gewicht" # Auf.A.Menge * 1000.0
        else
          Auf.A.Gewicht     # vGew;
        Auf.A.Menge.Preis   # Auf.A.Menge.Preis - vMengeFak;
        "Auf.A.Stückzahl"   # "Auf.A.Stückzahl" - vStk;
        Auf.A.Nettogewicht  # Auf.A.Gewicht;
        if ("Auf.A.Stückzahl"<0) then     "Auf.A.Stückzahl" # 0;
        if (Auf.A.Gewicht<0.0) then       Auf.A.Gewicht # 0.0;
        if (Auf.A.NettoGewicht<0.0) then  Auf.A.NettoGewicht # 0.0;
        Rekreplace(404,_recUnlock,'AUTO');
        BREAK;
      end;

      Erx # RecLink(404,401,12,_recNExt);
    END;
  end;


  Auf.P.Nummer    # vNr;        // Posten holen
  Auf.P.Position  # vPos1;
  RecRead(401,1,_recLock);
  Auf.P.Prd.VSB # vMVSBNeu;
  Auf_Data:PosReplace(_recUnlock,'AUTO');

  // Aktion neu anlegen
  RecBufClear(404);
  Auf.A.Aktionstyp    # c_Akt_DFakt;
  if (vBem='') then
    Auf.a.Bemerkung   # c_AktBem_DFakt
  else
    Auf.A.Bemerkung   # vBem;
  Auf.A.Aktionsnr     # 0;
  Auf.A.Aktionspos    # 0;
  Auf.A.TerminStart   # aDatFak;
  Auf.A.TerminEnde    # aDatFak;
  Auf.A.AktionsDatum  # aDatFak;
  //Aufx.A.Adressnummer  # Adr.Nummer;

  Auf.A.Dicke         # Art.Dicke;
  if (Art.C.Dicke<>0.0) then
    Auf.A.Dicke       # Art.C.Dicke;
  Auf.A.Breite        # Art.Breite;
  if (Art.C.Breite<>0.0) then
    Auf.A.Breite      # Art.C.Breite;
  "Auf.A.Länge"       # "Art.Länge";
  if ("Art.C.Länge"<>0.0) then
    "Auf.A.Länge"     # "Art.C.Länge";

  Auf.A.Menge           # vMenge;
  Auf.A.MEH             # Auf.P.MEH.Einsatz;
  Auf.A.Menge.Preis     # vMengeFak;
  Auf.A.MEH.Preis       # Auf.P.MEH.Preis;
  "Auf.A.Stückzahl"     # vStk;
/***
  if (Auf.A.MEH='kg') then
    "Auf.A.Gewicht" # Auf.A.Menge
  else if (Auf.A.MEH='t') then
    "Auf.A.Gewicht" # Auf.A.Menge * 1000.0
  else
    Auf.A.Gewicht # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Auf.A.Stückzahl", Auf.A.Dicke, Auf.A.Breite, "Auf.A.länge", Art.Warengruppe, Art.Nummer);
***/
  Auf.A.Gewicht         # vGew;
  Auf.A.Nettogewicht    # Auf.A.Gewicht;

  Auf.A.ArtikelNr       # aArtikel;
  Auf.A.Charge.Adresse  # aAdresse;
  Auf.A.charge.Anschr   # aAnschrift;
  Auf.A.Charge          # aCharge;


  // Kalkulationspreis??
  vOK # n;
  if ("Art.ChargenführungYN"=false) then begin //or (Art.Typ=c_Art_PRD) then begin
    Erx # RecLink(405,401,7,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      if (Auf.K.PEH=0) then Auf.K.PEH # 1;
      if (Auf.K.MengenbezugYN) and (Auf.K.MEH=Auf.P.MEH.Preis) and (Auf.K.Bezeichnung=aArtikel) then begin
        Auf.A.EKPreisSummeW1  # Auf.A.EKPreisSummeW1 +
                                Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * Auf.A.Menge,2);
//      Rnd(vKalk * Auf.A.Menge / CnvfI(Art.P.PEH),2);
        vOK # y;
      end;
      Erx # RecLink(405,401,7,_RecNext);
    END;
  end;


  RecbufClear(254);   // Preise leeren

  if (vOK=n) then begin
    // evtl. Chargenpreis holen...
    if (Auf.A.Charge<>'') then begin
      Art.P.PEH     # Art.PEH;
      Art.P.MEH     # Art.MEH;
      Art.P.PreisW1 # vEKPreis;
    end;
    // sonst EK-Preis aus Tabelle holen...
    if (Art.P.MEH='') then begin
//      if (Art.Typ=c_art_PRD) then
//        Art_P_Data:LiesPreis('PRD',0)
//      else
      Art_P_Data:LiesPreis('Ø-EK',0); //Ø-EK
      if (Art.P.MEH='') then
        Art_P_Data:LiesPreis('L-EK',0);
      if (Art.P.MEH='') then
        Art_P_Data:LiesPreis('L-EK',-1);
      if (Art.P.MEH='') then
        Art_P_Data:LiesPreis('EK',0);
    end;
//todo(anum(art.p.preisW1,2)+'    kalk:'+anum(vKalk,2));

    if (Auf.A.MEH<>Art.P.MEH) and (Art.P.MEH<>'') then begin
      vMenge # Lib_Einheiten:WandleMEH(250, "Auf.A.Stückzahl", Auf.A.Nettogewicht, Auf.A.Menge, Auf.A.MEH, Art.P.MEH);
      Auf.A.EKPreisSummeW1 # Rnd(Art.P.PreisW1 * vMenge / CnvfI(Art.P.PEH),2);
    end
    else begin
      Auf.A.EKPreisSummeW1  # Rnd(Art.P.PreisW1 * Auf.A.Menge / CnvfI(Art.P.PEH),2);
    end;
  end;


  Auf.A.InterneKostW1   # 0.0;
  vOk # (Auf_A_Data:NeuAnlegen(n,n)=_rOK);
  if (vOK=false) then begin
    if (aManuell) then TRANSBRK;
    Msg(999999,'2274',0,0,0);
    RETURN false;
  end;

  // Artikel abbuchen
  RecBufClear(252);
  Art.C.ArtikelNr     # Auf.A.ArtikelNr;
  Art.C.Charge.Intern # Auf.A.Charge;

  RecBufClear(253);
  Art.J.Datum           # Auf.A.Aktionsdatum;
  Art.J.Bemerkung       # c_AKt_Dfakt+' '+AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position);
  "Art.J.Stückzahl"     # -vStk;
  Art.J.Menge           # -vMenge;
  "Art.J.Trägertyp"     # 'AUF';
  "Art.J.Trägernummer1" # Auf.A.Nummer;
  "Art.J.Trägernummer2" # Auf.A.Position;
  "Art.J.Trägernummer3" # Auf.A.Position2;
  vOK # Art_Data:Bewegung(0.0, 0.0);
  if (vOK=false) then begin
    if (aManuell) then TRANSBRK;
    ERROROUTPUT;
    Msg(999999,'2291',0,0,0);
    RETURN false;
  end;
****/
// 02.02.2022 AH: FIX a gegen v
  if (_DoitDFaktArtC(aArtikel, aAdresse, aAnschrift, aCharge, vMengeFak, vMenge, vStk, vGew, vMenge, vStk, vGew, aDatFak)=false) then begin
//  if (_DoitDFaktArtC(aArtikel, aAdresse, aAnschrift, aCharge, aMengeFak, aMenge, aStk, vGew, aMenge, aStk, vGew, aDatFak)=false) then begin
    if (aManuell) then TRANSBRK;
    ERROROUTPUT;
    Msg(999999,'2291',0,0,0);
    RETURN false;
  end;


  // Marker berechnen
  RecRead(401,1,_RecNoLoad | _RecLock);
  Auf_Data:Pos_BerechneMarker();
  Auf_Data:PosReplace(_recUnlock,'AUTO');
  RecRead(400,1,_RecNoLoad | _RecLock);
  Auf_Data:BerechneMarker();
  RekReplace(400,_recUnlock,'AUTO');

  if (aManuell) then begin
    TRANSOFF;
    Msg(401251,'',_WinIcoInformation, _windialogok,1);
  end;

  RETURN true;
end;


//========================================================================