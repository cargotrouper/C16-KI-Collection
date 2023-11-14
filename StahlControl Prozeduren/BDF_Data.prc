@A+
//===== Business-Control =================================================
//
//  Prozedur    Bdf_Data
//                OHNE E_R_G
//
//  Info
//
//
//  28.03.2004  AI  Erstellung der Prozedur
//  25.06.2012  TM  Bedarfsträgertypen AUF und ANG hinzugefügt
//  26.06.2012  AI  Preise & Währungne eingebaut
//  10.07.2012  TM  Bestellung aus BDF - Währung aus ADR
//  11.07.2012  TM  Bestellung aus BDF - Steuerschlüssel aus ADR
//  11.07.2012  TM  Bestellung aus BDF - Wunschtermin errechnen wenn leer
//  11.07.2012  TM  Bestellung aus BDF - AutoDruck wenn Setting gesetzt
//  16.10.2013  AH  Anfragenx
//  06.07.2015  ST  Bugfix: Bedarfanlage; Warengruppenlink korrigiert
//  28.06.2017  AH  Belegung der Bestell-Lieferadresse wie bei normalen Bestellungen
//  13.02.2018  AH  Bugfix für Bestell-Gewicht aus Bedarf
//  13.02.2018  AH  Bestellung aus BDF - Mindestbestellmenge beachten
//  06.01.2022  AH  ERX
//  06.01.2022  AH  MarkKummulieren();
//  11.08.2023  TM  Bestellung aus BDF - TerminArt aus EK-Setting beachten
//
//  Subprozeduren
//    sub TraegerString() : alpha;
//    sub BlankoAnlegen
//    sub Anfragen
//    sub AnfrageDrucken
//    sub AusLieferant()
//    sub Bestellen
//    Sub ArtikelAutodispo() : logic;
//    sub MarkKummulieren()
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

//========================================================================
//  TraegerString
//
//========================================================================
sub TraegerString() : alpha;
begin
  case "Bdf.Trägertyp" of
    'AUDIS' : begin
      RETURN Translate('automatische Disposition');
    end;
    'ART' : begin
      RETURN Translate('Reservierung');
    end;
    'BAG','BA',c_Akt_BA : begin
      RETURN c_AKt_BA+' '+AInt("Bdf.Trägernummer1")+'/'+AInt("Bdf.Trägernummer2")+'/'+AInt("Bdf.Trägernummer3");
    end;
    c_AUF : begin
      RETURN 'AUF ' + AInt("Bdf.Trägernummer1")+'/'+AInt("Bdf.Trägernummer2");
    end;
    c_ANG : begin
      RETURN 'ANG ' + AInt("Bdf.Trägernummer1")+'/'+AInt("Bdf.Trägernummer2");
    end
    otherwise begin
      RETURN Translate('MANU');
    end;
  end;
end;


//========================================================================
// BlankoAnlegen
//
//========================================================================
sub BlankoAnlegen() : logic;
begin
  RecBufClear(540);

  Bdf.Nummer # Lib_Nummern:ReadNummer('Bedarf');
  if (Bdf.Nummer<>0) then Lib_Nummern:SaveNummer()
  else RETURN false;

  Bdf.Anlage.User   # gUsername;
  Bdf.Anlage.DAtum  # today;
  Bdf.Anlage.Zeit   # now;
  RekInsert(540,0,'AUTO');

  RETURN true;
end;


//========================================================================
// Anfragen
//
//========================================================================
sub Anfragen();
begin
  if (Rechte[Rgt_Bdf_Anfragen]=n) then begin
    RETURN;
  end;

  // Kopf und Fusstexte Dialog
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BDF.AnfKFT.Dialog.Sel','');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
// AnfrageDrucken
//
//========================================================================
sub AnfrageDrucken();
local begin
  vNr   : int;
  vBdf  : int;
  vBdf2 : int;

  vPos  : int;
  vOk   : logic;

  vArtikelNr : alpha;
  vMEH : alpha;
  Erx   : int;
end;

begin

  vPos # 0;
  Erx # RecRead(540,1,_recFirst);
  WHILE (Erx<=_rLocked) and (vPos=0) do begin
    if (Lib_Mark:IstMarkiert(540,RecInfo(540,_RecID))=y) then Inc(vPos);
    Erx # RecRead(540,1,_recNext);
  END;
  if (vPos=0) then begin
    Msg(540006,'',0,0,0);
    RETURN;
  end;

  RecBufClear(541);
  vNr # Lib_Nummern:ReadNummer('Anfrage');
  if (vNr<>0) then
    Lib_Nummern:SaveNummer()
  else
    RETURN;

  vPos # 1;
  // Markierte suchen
  Erx # RecRead(540,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Lib_Mark:IstMarkiert(540,RecInfo(540,_RecID))=n) then begin
      Erx # RecRead(540,1,_recNext);
      CYCLE;
    end;

    vBdf # Bdf.Nummer;

    // Pos. bereits im Angebot enthalten?
    vOk # n;
    Erx # RecLink(541,540,1,_RecFirst);
    WHILE (Erx<=_rLocked) do begin          // Aktionen durchlaufen
      if (Bdf.A.Anfragenr=vNr) then vOk # y;
      Erx # RecLink(541,540,1,_RecNext);
    END;
    Bdf.Nummer # vBdf;
    Recread(540,1,0);
    if (vOK) then begin // schon enthalten! -> CYCLE
      Erx # RecRead(540,1,_recNext);
      CYCLE;
    end;

    vArtikelNr # Bdf.ArtikelNr;
    vMEH # Bdf.MEH;
    Erx # RecRead(540,1,0);
    WHILE (Erx<=_rLocked) do begin
      if (Lib_Mark:IstMarkiert(540,RecInfo(540,_RecID))=n) then begin
        Erx # RecRead(540,1,_recNext);
        CYCLE;
      end;

      vBdf2 # Bdf.Nummer;
      // gleiche Typen kummulieren
      if (vArtikelNr=Bdf.ArtikelNr) and (vMEH=Bdf.MEH) and
        ((Bdf.KummulierbarYN) or (vBdf=vBdf2)) then begin

        // Aktion vermerken
        RecBufClear(541);
        Bdf.A.Nummer          # Bdf.Nummer;
        Bdf.A.Anfragenr       # vNr;
        Bdf.A.AnfragePos      # vPos;
        Bdf.A.Lieferant       # Adr.Lieferantennr;
        Bdf.A.PreisW1         # 0.0;
        Bdf.A.Anlage.Datum    # today;
        Bdf.A.Anlage.Zeit     # now;
        Bdf.A.Anlage.User     # gUserName;

        Bdf.A.lfdNr           # 0;
        REPEAT
          Bdf.A.lfdNr         # Bdf.A.lfdNr + 1;
          Erx # RekInsert(541,0,'AUTO');
        UNTIL (Erx=_rOK);
      end;

      Erx # RecRead(540,1,_recNext);
    END;

    vPos # vPos + 1;

    Bdf.Nummer # vBdf;
    RecRead(540,1,0);
    Erx # RecRead(540,1,_recNext);
  END;


  // DRUCK
  Lib_Dokumente:Printform(540,'Anfrage',false)
  // DRUCK


  // Erfolg
  Msg(540004,cnvai(vNr),0,0,0);

//  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

end;


//========================================================================
// Bestellen
//
//========================================================================
sub Bestellen();
local begin
  Erx         : int;
  vNr         : int;
  vBdf        : int;
  vPos        : int;
  vLastPos    : int;
  vLf         : int;
  vWae        : int;
  vChaos      : logic;
  vPreisNull  : logic;
  vMat        : int;
end;
begin
  if (Rechte[Rgt_Bdf_Bestellen]=n) then begin
    RETURN;
  end;

  vPos # 1;
  vWae # 0;
  vPreisNull # false;
  vChaos     # false;
  FOR Erx # RecRead(540, 1, _recFirst);
  LOOP Erx # RecRead(540,1,_recNext);
  WHILE (Erx<=_rLocked) do begin
    if (Lib_Mark:IstMarkiert(540,RecInfo(540,_RecID))=n) then
      CYCLE;
    if(Bdf.Preis = 0.0) then
      vPreisNull # true;
    if (Bdf.Lieferant.Wunsch<>0) then begin
      if (vLf=0) then
        vLf # Bdf.Lieferant.Wunsch;
      else if (vLf<>Bdf.Lieferant.Wunsch) then
        vChaos # y;
    end;
    if ("Bdf.Währung"<>0) then begin
      if (vWae=0) then vWae # "Bdf.Währung"
      else if (vWae<>"Bdf.Währung") then vWae # -1;
    end;
  END;

  if (vChaos) then
    Msg(540002, '', 0, 0, 0);
  if (vLf = 0) then begin
    Msg(540003, '', 0, 0, 0);
    RETURN;
  end;
  if (vWae < 0) then begin
    Msg(540007, '', 0, 0, 0);
    RETURN;
  end;
  if(vPreisNull) then begin
    Msg(540008, '', 0, 0, 0);
    RETURN;
  end;

  // Lieferant holen
  Adr.LieferantenNr # vLF;
  RecRead(100, 3, 0);

  if (Msg(540100, Adr.Stichwort, _WinIcoQuestion, _WinDialogYesNo, 2) = _WinIdNo) then
    RETURN;

  // los gehts
  TRANSON;

  vNr # Lib_Nummern:ReadNummer('Einkauf');
  if (vNr<>0) then Lib_Nummern:SaveNummer()
  else begin
    TransBrk;
    Msg(540099,'',0,0,0);
    RETURN;
  end;

  // Bestellkopf anlegen
  RecBufClear(500);
  Ein.Vorgangstyp       # c_Bestellung;
  Ein.Nummer            # vNr;
  Ein.Datum             # today;
  Ein.Sachbearbeiter    # gUserName;

  Ein.Lieferantennr     # vLf;
  Ein.LieferantenSW     # Adr.Stichwort;

  Ein.Lieferadresse     # Adr.Nummer;
  Ein.LieferAnschrift   # 1;

  // 28.06.2017 AH:
  if (Set.Ein.Lieferadress=-1) then begin
    Erx # RecLink(100,500,1,_recfirst);   // Lieferant holen
    if (Erx<=_rLocked) and (Ein.Lieferantennr<>0) then begin
      Ein.Lieferadresse   # Adr.Nummer;
      Ein.Lieferanschrift # Set.Ein.Lieferanschr;
    end;
  end
  else begin
    Ein.Lieferadresse   # Set.Ein.Lieferadress;
    Ein.Lieferanschrift # Set.Ein.Lieferanschr;
  end;
  Erx # RecLink(100,500,12,_recFirst);    // Lieferadresse holen
  if (Erx<=_rLocked) then Ein.Rechnungsempf   # Adr.Lieferantennr;
//  Ein.RechnungsEmpf     # Ein.Lieferantennr;

  "Ein.Währung"         # "Adr.EK.Währung";

  if (vWae<>0) then
    "Ein.Währung"       # vWae;

  Ein.Lieferbed         # Adr.EK.Lieferbed;
  Ein.Zahlungsbed       # Adr.EK.ZAhlungsbed;
  Ein.Versandart        # Adr.EK.Versandart;
  Ein.Sprache           # Adr.Sprache;
  Ein.AbmessungsEH      # Adr.AbmessungEH;
  Ein.GewichtsEH        # Adr.GewichtEH;
  "Ein.Steuerschlüssel" # "Adr.Steuerschlüssel";


//  "Ein.Währungskurs"  # 1.0;
  Ein.Anlage.Datum  # today;
  Ein.Anlage.User   # gUsername;
  Ein.Anlage.Zeit   # now;
  Erx # RekInsert(500,0,'AUTO');
  if (erx<>_rOk) then begin
    TransBrk;
    Msg(540099,'',0,0,0);
    RETURN;
  end;

  vLastPos # 1;

  Erx # RecRead(540,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Lib_Mark:IstMarkiert(540,RecInfo(540,_RecID))=n) then begin
      Erx # RecRead(540,1,_recNext);
      CYCLE;
    end;

      vPos # 0;
      if (Bdf.KummulierbarYN) then begin
        Erx # RecLink(510,500,9,_RecFirst);
        WHILE (Erx=_rOK) and (vPos=0) do begin
          if (Ein.P.ArtikelNr=Bdf.ArtikelNr) and (StrFind(Ein.P.Bemerkung,'SAMMEL',0)<>0) and
            (Ein.P.MEH=Bdf.MEH) then begin
            vPos # Ein.P.Position;
            CYCLE;
          end;
          Erx # RecLink(510,500,9,_RecNext);
        END;
      end;

      RecLink(250,540,7,_RecFirst);   // Artikel holen

      // Kummulieren??
      if (vPos<>0) then begin
        Ein.P.Nummer # Ein.Nummer;
        Ein.P.Position # vPos;
        RecRead(501,1,_recLock);
        "Ein.P.Stückzahl"   # "Ein.P.Stückzahl" + "Bdf.Stückzahl";
        Ein.P.Menge.Wunsch  # Ein.P.Menge.Wunsch  + Bdf.Menge;
        Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.Ausfall;
        Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.Ausfall.Stk;
        if (Bdf.TerminWunsch<>0.0.0) then begin
          if (Ein.P.Termin1Wunsch=0.0.0) or (Ein.P.Termin1Wunsch>Bdf.Datum.Von) then
            Ein.P.Termin1Wunsch # Bdf.Datum.Von;
          end
        else begin
          if (Ein.P.Termin1Wunsch=0.0.0) or (Ein.P.Termin1Wunsch>Bdf.TerminWunsch) then
            Ein.P.Termin1Wunsch # Bdf.TerminWunsch;
        end;
        Erx # Ein_Data:PosReplace(_recUnlock,'AUTO');
        if (erx<>_rOk) then begin
          TransBrk;
          Msg(540099,'',0,0,0);
          RETURN;
        end;
      end
      else begin  // Neuanlage!

        RecBufClear(501);
        Ein.P.Nummer        # Ein.Nummer;
        Ein.P.Position      # vLastPos;
        vLastPos # vLastPos + 1;

        Ein.P.MEH.Preis     # Set.Ein.MEH.PEH;
        Ein.P.PEH           # Set.Ein.PEH;
        if (Bdf.PEH<>0) or (Bdf.Preis<>0.0) then begin
          Ein.P.PEH         # Bdf.PEH;
          Ein.P.GrundPreis  # Bdf.Preis;
          Ein.P.MEH.Preis   # Bdf.MEH;    // 24.07.2017 AH
        end;
        "Ein.P.Güte"        # "Art.Güte"; // 24.07.2017 AH
        Ein.P.Dicke         # Art.Dicke;
        Ein.P.Breite        # Art.Breite;
        "Ein.P.Länge"       # "Art.Länge";
        Ein.P.Rid           # Art.Innendmesser;
        Ein.P.Rad           # Art.AussendMesser;
        Ein.P.Dickentol     # Art.Dickentol;
        Ein.P.BreitenTol    # Art.Breitentol;
        "Ein.P.LängenTol"   # "Art.LängenTol";
        if (Bdf.MEH='kg') then
          Ein.P.Gewicht     # Bdf.Menge
        else if (Bdf.MEH='t') then
          Ein.P.Gewicht     # Rnd(Bdf.Menge / 1000.0, Set.Stellen.Gewicht)
        else
          Ein.P.Gewicht     # Rnd(Art.GewichtProStk * cnvfi("Bdf.Stückzahl"), Set.Stellen.Gewicht);

        Ein.P.Auftragsart   # Set.Ein.Auftragsart;
        Ein.P.Termin1W.Art  # Set.Ein.TerminArt;

        Ein.P.Lieferantennr # Ein.Lieferantennr;
        Ein.P.LieferantenSW # Ein.LieferantenSW;
        Ein.P.Warengruppe   # Bdf.Warengruppe;
        Ein.P.Wgr.Dateinr   # Bdf.Wgr.Dateinr;
        Ein.P.Artikelnr     # Bdf.Artikelnr;
        Ein.P.ArtikelSW     # Bdf.ArtikelStichwort;
        "Ein.P.Stückzahl"   # "Bdf.Stückzahl";
        Ein.P.Menge.Wunsch  # Bdf.Menge;
        Ein.P.Menge         # Bdf.Menge;
        Ein.P.MEH.Wunsch    # Bdf.MEH;
        Ein.P.MEH           # Bdf.MEH;

        Ein.P.MEH.Wunsch    # Bdf.MEH;
        Ein.P.FM.Rest     # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.Ausfall;
        Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.Ausfall.Stk;

        if (Bdf.TerminWunsch<>0.0.0) then
          Ein.P.Termin1Wunsch # Bdf.TerminWunsch
        else
          //Ein.P.Termin1Wunsch # Bdf.Datum.Von;
          Ein.P.Termin1Wunsch # cnvDI(cnvID(today) + Art.Bestelltage);

        vMat                # Ein.P.Materialnr;

        Ein.P.Anlage.Datum  # today;
        Ein.P.Anlage.User   # gUsername;
        Ein.P.Anlage.Zeit   # now;

        if (Bdf.KummulierbarYN) then Ein.P.Bemerkung # 'SAMMEL' + "BDF.Trägertyp"+Cnvai("Bdf.Trägernummer1")+Cnvai("Bdf.Trägernummer2")
        else Ein.P.Bemerkung     # "BDF.Trägertyp"+Cnvai("Bdf.Trägernummer1")+AInt("Bdf.Trägernummer2");//;Bdf.Bemerkung;

        if Ein.P.Termin1W.Art != 'DA' then
          Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.P.Termin1Wunsch, Ein.P.Termin1W.Art, var Ein.P.Termin1W.Zahl,var Ein.P.Termin1W.Jahr);

        Erx # Ein_Data:PosInsert(_recLock,'AUTO');
        if (Erx<>_rOk) then begin
          TransBrk;
          Msg(540099,'',0,0,0);
          RETURN;
        end;

        if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
          // Materialkarten anlegen
          if (Ein_Data:UpdateMaterial(n)=false) then begin
            TRANSBRK;
            Msg(540099,'',0,0,0);
            RETURN;
          end;

          if (RunAFX('Ein.P.RecSave.MitMat',aint(vMat))<>0) then begin
            if (AfxRes<>_rOK) then begin
              // TRANSBRK in AFX !!!
              RETURN;
            end;
          end;
        end;

        Erx # Ein_Data:PosReplace(_recUnlock,'AUTO');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          Msg(540099,'',0,0,0);
          RETURN;
        end;
      end;

      // Bestellnummern im Bedarf merken und ABLEGEN!!!
      RecRead(540,1,0);
      Bdf.Einkaufsnummer    # Ein.P.Nummer;
      Bdf.Einkaufsposition  # Ein.P.Position;
      "Bdf.Löschmarker"     # '*';
      "Bdf.Lösch.Datum"     # today;
      "Bdf.Lösch.Zeit"      # now;
      "Bdf.Lösch.User"      # gUsername;
      RecBufCopy(540,545);
      Erx # RekDelete(540,0,'AUTO');
      if (Erx<>_rOk) then begin
        TransBrk;
        Msg(540099,'',0,0,0);
        RETURN;
      end;
      Erx # RekInsert(545,0,'AUTO');
      if (erx<>_rOk) then begin
        TransBrk;
        Msg(540099,'',0,0,0);
        RETURN;
      end;

    if (CUS_Data:MoveAll(540,545)=false) then begin
      APPON();
      TransBrk;
      Msg(540099,'',0,0,0);
      RETURN;
    end;
    if (Anh_Data:CopyAll(540,545,y, n)=false) then begin
      APPON();
      TransBrk;
      Msg(540099,'',0,0,0);
      RETURN;
    end;

      // Maker entfernen
      Lib_Mark:MarkAdd(540,n,y);

      Erx # RecRead(540,1,_recFirst);

  END;


  // neue Bestellung nochmals durchlaufen
  Erx # RecLink(501,500,9,_RecFirst);
  WHILE (Erx=_rOK) and (vPos=0) do begin

    if (Wgr_data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_data:IstMix(Ein.P.Wgr.Dateinr))) then begin
      // Materialkarten anlegen
      if (Ein_Data:UpdateMaterial()=false) then begin
        TransBrk;
        Msg(540099,'',0,0,0);
        RETURN;
      end;
    end
    else if (Wgr_data:IstArt(Ein.P.Wgr.Dateinr)) then begin
      // Preise ermitteln
      RecRead(501,1,_RecLock);
      Ein_Data:FindeEKPreis();
      Ein_Data:PosReplace(_recUnlock,'AUTO');

      // Artikelbestellung anlegen
      if (Ein_Data:UpdateArtikel(0.0)=false) then begin
        TransBrk;
        Msg(540099,'',0,0,0);
        RETURN;
      end;

    end;

    Erx # RecLink(501,500,9,_RecNext);
  END;

  TRANSOFF;

  // Erfolg
  Msg(540001,AInt(vNr),0,0,0);

  if (Set.Ein.SofortDBstYN = true) then begin
    if Ein_Subs:DruckBest() <> true then begin

    end;
  end;


  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

end;


//========================================================================
// Autodispo
//
//========================================================================
Sub ArtikelAutodispo(aTage : int) : logic;
local begin
  Erx     : int;
  vDat    : date;
  vMenge  : float;
  vStk    : int;
end;
begin

  // ggf. bisherigen Bedarf löschen
  RecBufClear(540);
  "Bdf.Trägertyp"     # 'AUDIS';
  "Bdf.Trägernummer1" # Art.ID;
  Erx # RecRead(540,2,0);
  if (Erx<=_rMultiKey) and ("Bdf.Trägertyp"='AUDIS') and ("Bdf.Trägernummer1"=Art.ID) then begin
    RekDelete(540,0,'AUTO');
  end;

  RecBufClear(540);
  vDat # 0.0.0;
  vMenge # 0.0;
  vStk # 0;
  Art_Disposition2:BerechneEinenArtikel(aTage, var vDat, var vMenge, var vStk);

  // besteht Bedarf???
  if (vMenge<>0.0) then begin
    if (vDat=0.0.0) then vDat # today;
    if (BlankoAnlegen()=false) then begin
      Msg(250540,Art.Nummer,0,0,0);
      RETURN false;
    end;

    // 05.01.2022 AH: K-EK suchen als 1. Lieferant
    if (Art_P_Data:FindePreis('K-EK', 0, vMenge, Art.MEH, 0)=false) or (Art.P.Adressnr=0) then begin
      // Lieferant suchen
      if (Art_P_Data:FindePreis('EK', 0, vMenge, Art.MEH, 0)=false) then
        RecBufClear(254);
    end;

    RecRead(540,1,_recLock);
    "Bdf.Trägertyp"       # 'AUDIS';
    "Bdf.Trägernummer1"   # Art.ID;
    Bdf.Artikelnr         # Art.Nummer;
    Bdf.ArtikelStichwort  # Art.Stichwort;
    Bdf.Charge            # '';
    Bdf.Warengruppe       # Art.Warengruppe;
    Erx # Reklink(819,540,6,_recFirst);   // Warengruppe holen
    Bdf.Wgr.Dateinr       # Wgr.Dateinummer;
    if ("Art.ChargenführungYN") then Bdf.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Bdf.Wgr.Dateinr);

    Bdf.MEH               # Art.MEH;
    Bdf.Menge             # vMenge;
    "Bdf.Stückzahl"       # vStk;
    Bdf.Datum.Von         # vDat;
    Bdf.Datum.Bis         # vDat;

    if (Art.P.Adressnr<>0) then begin
      Erx # Reclink(100,254,1,_recFirst);   // Lieferant holen
      Bdf.Lieferant.Wunsch  # Adr.Lieferantennr;
      Bdf.LieferSW.Wunsch   # Adr.Stichwort;
      Bdf.Preis             # Art.P.PreisW1;
      Bdf.PEH               # Art.P.PEH;
      "Bdf.Währung"         # "Art.P.Währung";

      // 13.02.2018 AH: Mindestbestellmenge beachten
      if (Art.P.abMenge>0.0) then begin
        if (Bdf.MEH=Art.P.MEH) then begin
          if (Bdf.Menge<Art.P.MindestAbnahme) then begin
            Bdf.Menge # Art.P.MindestAbnahme;
          end;
        end;
      end;
    end;

    RekReplace(540,_recUnlock,'AUTO');
  end;

  RETURN true;

end;


//========================================================================
// MarkKummulieren
//      mit Msg
//========================================================================
sub MarkKummulieren();
local begin
  Erx   : int;
  vLf   : int;
  vDat  : date;
  vArt  : alpha;
  v540  : int;
  vM    : float;
  vStk  : int;

  vNr   : int;
  vBdf  : int;
  vBdf2 : int;
  vPos  : int;
  vOk   : logic;
  vArtikelNr : alpha;
  vMEH : alpha;
end;
begin

  if (Msg(540100,'',0,0,0)<>_Winidyes) then RETURN;
  
  APPOFF();
  
  vPos # 0;
  Erx # RecRead(540,1,_recFirst);
  
  WHILE (Erx<=_rLocked) do begin
    if (Lib_Mark:IstMarkiert(540,RecInfo(540,_RecID))=y) then begin
      Inc(vPos);
      if (Bdf.KummulierbarYN=false) then begin
        APPON();
        Msg(99,'Es sind nicht kummulierbare Einträge markiert!',0,0,0);
        RETURN;
      end;

      if (Bdf.Lieferant.Wunsch<>0) then begin
        if (vLf=0) then begin
          vLF # Bdf.Lieferant.Wunsch;
        end
        else begin
          if (vLf<>Bdf.Lieferant.Wunsch) then begin
            vLf # -1;
            BREAK;
          end;
        end;
      end;
      if (Bdf.Datum.Von<>0.0.0) then begin
        if (vDat=0.0.0) then vDat # Bdf.Datum.Von
        else vDat # Min(vDat, Bdf.Datum.Von);
      end;
    end;
    
    Erx # RecRead(540,1,_recNext);
  END;
  if (vPos=0) then begin
    APPON();
    Msg(540006,'',0,0,0);
    RETURN;
  end;
  if (vLf<0) then begin
    APPON();
    Msg(540002,'',0,0,0);
    RETURN;
  end;


  vPos # 1;
  // Markierte suchen
  FOR Erx # RecRead(540,1,_recFirst)
  LOOP Erx # RecRead(540,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Bdf.KummulierbarYN=false) then CYCLE;
    if (Lib_Mark:IstMarkiert(540,RecInfo(540,_RecID))=n) then CYCLE;
    Lib_Mark:MarkAdd(540);
    
    vArt  # Bdf.ArtikelNr;
    vM    # Bdf.Menge;
    vStk  # "Bdf.Stückzahl";
    vMEH  # Bdf.MEH;
    v540  # RekSave(540);
    // weitere dieses Artikel sammeln!
    Erx # RecRead(540,5,_recNext)
    WHILE (erx<=_rLocked) and (vArt=Bdf.ArtikelNr) do begin
      if (Bdf.KummulierbarYN) and (Bdf.MEH=vMEH) and (Lib_Mark:IstMarkiert(540,RecInfo(540,_RecID))) then begin
        Lib_Mark:MarkAdd(540);
        vM # vM + Bdf.Menge;
        vStk # vStk + "Bdf.Stückzahl";
        Erx # RekDelete(540);
        Erx # RecRead(540,5,0);
        Erx # RecRead(540,5,0);
        CYCLE;
      end;
      Erx # RecRead(540,5,_recNext);
    END;
    RekRestore(v540);
    Erx # RecRead(540,1,_recLock);
    Bdf.Menge       # vM;
    "Bdf.Stückzahl" # vStk;
    RekReplace(540);
  END;
  
  APPON();
  RefreshList(gZllist, _WinLstRecFromRecid | _WinLstRecDoSelect);
  Msg(999998,'',0,0,0);
  
end;


//========================================================================