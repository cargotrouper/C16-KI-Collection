@A+
//===== Business-Control =================================================
//
//  Prozedur    Auf_P_SMain
//                  OHNE E_R_G
//  Info
//
//
//  18.05.2005  AI  Erstellung der Prozedur
//  11.02.2010  AI  Textladen beim Maskenrefresh
//  16.01.2012  AI  CopyRahmen2Abruf
//  30.05.2012  AI  AFX bei CopyRahmen2Abruf
//  30.05.2012  AI  NEU: Rechnungsanschrift
//  10.08.2012  ST  Rahmen->Abruf: Text immer in Individualtext kopieren Prj. 1332/66
//  04.12.2012  AI  Feld: Rechnungsnr importieren nut bei Gut/Bel (Prj. 1395/52)
//  31.07.2014  AH  Feldlsperre Abruf, Liefervertrag, Gültigkeit korrigiert
//  11.02.2015  AH  Edit: std. Lieferanschriften aus Adresse
//  23.07.2015  AH  Neu: Artikelgruppe von Artikel anzeigen
//  21.08.2015  AH  Neu: Gut/Bel kopiert auch bei Artikeln Vogänger-Auftragsdaten UND Vorkalkulation
//  27.10.2015  AH  Fix: bei REKOR Erlösdatenübernahme bei manueller Eingabe der Rechnungsnummer
//  17.05.2016  AH  Sprungreihenfolge Artikelmaske
//  12.10.2016  AH  "CopyRahmen2Abruf" übernimmt Bestellnummer NICHT mehr
//  09.11.2016  AH  PAbruf
//  26.01.2018  AH  AnalyseErweitert
//  24.02.2022  AH  ERX, Art.Ausführungen
//  2022-07-18  AH  Fix: Ändern vom Kunden im Kopf, ändert alle Positionen
//
//  Subprozeduren
//    SUB Switchmask(aMitFocus : logic) : logic;
//
//    SUB GetArtikel_Mat();
//    SUB GetArtikel();
//
//    SUB RefreshIfm_Kopf(optaName : alpha; optaChanged : logic)
//    SUB RefreshIfm_Page1_Art(opt aName : alpha; opt aChanged : logic)
//    SUB RefreshIfm_Page1_Mat(opt aName : alpha; opt aChanged : logic)
//    SUB RefreshIfm_Page2(opt aName : alpha; opt aChanged : logic)
//    SUB RefreshIfm_Page3(opt aName : alpha; opt aChanged : logic)
//    SUB Calc_Stk() : int
//    SUB Calc_Gew() : float;
//    SUB EvtDropEnter(aEvt : event; aDataObject : int; aEffect : int) : logic;
//    SUB EvtDrop(aEvt : event; aDataObject : int;  aDataPlace : int; aEffect : int; aMouseBtn  : int) : logic;
//
//    SUB CopyRahmen2Abruf(aAuf : int; aPos : int);
//
//========================================================================
@I:Def_Global
@I:Def_aktionen
@I:Def_Rights

define begin
//  cDialog :   $Auf.P.Verwaltung
  cTitle :    'Auftragspositionen'
  cFile :     401
  cMenuName : 'Auf.P.Bearbeiten'
  cPrefix :   'Auf_P'
  cZList :    $ZL.AufPositionen
  cKey :      1
end;

declare RefreshIfm_Page1_Art(opt aName : alpha; opt aChanged : logic)
declare RefreshIfm_Page1_Mat(opt aName : alpha; opt aChanged : logic)
declare RefreshIfm_Page2(opt aName : alpha; opt aChanged : logic)
declare RefreshIfm_Page3(opt aName : alpha; opt aChanged : logic)


//========================================================================
//  Switchmask
//
//========================================================================
sub Switchmask(aMitFocus : logic) : logic;
local begin
  Erx       : int;
  vCurrent  : alpha;
  vWohin    : alpha;
end;
begin

  if (gMDI=0) then RETURN false;
  if (StrFind(gMDI->wpname,'Auf.',0)=0) then RETURN false;

  // Materialtyp unterscheiden...
  if (mode=c_ModeEdit) or (Mode=c_modeNew) then begin
    Erx # RecLink(819,401,1,0);   // Warengruppe holen
    if (Erx>_rLocked) then RecBufClear(819);
    if (Wgr_Data:WertBlockenBeiTyp(401, 'RID')) then begin
      Lib_GuiCom:Disable($edAuf.P.RID_Mat);
      Lib_GuiCom:Disable($edAuf.P.RIDMax_Mat);
    end;
    if (Wgr_Data:WertBlockenBeiTyp(401, 'RAD')) then begin
      Lib_GuiCom:Disable($edAuf.P.RAD_Mat);
      Lib_GuiCom:Disable($edAuf.P.RADMax_Mat);
    end;
    if (Wgr_Data:WertBlockenBeiTyp(401, 'D')) then begin
      Lib_GuiCom:Disable($edAuf.P.Dicke_Mat);
      Lib_GuiCom:Disable($edAuf.P.Dickentol_Mat);
    end;
    if (Wgr_Data:WertBlockenBeiTyp(401, 'B')) then begin
      Lib_GuiCom:Disable($edAuf.P.Breite_Mat);
      Lib_GuiCom:Disable($edAuf.P.Breitentol_Mat);
    end;
    if (Wgr_Data:WertBlockenBeiTyp(401, 'L')) then begin
      Lib_GuiCom:Disable($edAuf.P.Laenge_Mat);
      Lib_GuiCom:Disable($edAuf.P.Laengentol_Mat);
    end;
  end;


  gMdi->wpautoupdate # false;
  vCurrent # $NB.Main->wpcurrent;

  if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) or
    (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then begin
    $lbAuf.P.AbrufAufNr_Mat->wpcaption  # Translate('Rechnungsnr.');
    $edAuf.P.AbrufAufNr_Mat->wpcustom   # '_E';

    $edAuf.P.AbrufAufPos_Mat->wpcustom # '_N';

    $lbAuf.P.AbrufAufNr->wpcaption  # Translate('Rechnungsnr.');
    $edAuf.P.AbrufAufNr->wpcustom   # '_E';
    //$lbAuf.P.AbrufAufPos
    $edAuf.P.AbrufAufPos->wpcustom # '_N';
  end
  else begin  // Auftrag?
    $lbAuf.P.AbrufAufNr_Mat->wpcaption  # Translate('Abruf-Best.&Nr.');
    $edAuf.P.AbrufAufNr_Mat->wpcustom   # '_E';
    $edAuf.P.AbrufAufPos_Mat->wpcustom  # '_E';

    $lbAuf.P.AbrufAufNr->wpcaption  # Translate('Abruf-Best.&Nr.');
    $edAuf.P.AbrufAufNr->wpcustom   # '_E';
    $edAuf.P.AbrufAufPos->wpcustom  # '_E';
  end;

  if (Auf.P.Wgr.Dateinr=0) then //Auf.P.Wgr.Dateinr # Wgr_Data:WertMaterial();
    Auf.P.Wgr.Dateinr # Set.Auf.Dateinr;

  if (Wgr_Data:IstMixMat(Auf.P.Wgr.Dateinr)) then begin
    $lbAuf.P.Artikelnr_Mat->wpcaption # Translate('Artikelnr.');
    $edAuf.P.Artikelnr_Mat->wpLengthMax # 25;
    $lb.EH_Mat->wpvisible         # (Auf.P.MEH.Einsatz<>'Stk') and (Auf.P.MEH.Einsatz<>'kg');
    $lbAuf.P.Menge_Mat->wpvisible # (Auf.P.MEH.Einsatz<>'Stk') and (Auf.P.MEH.Einsatz<>'kg');
    $edAuf.P.Menge_Mat->wpvisible # (Auf.P.MEH.Einsatz<>'Stk') and (Auf.P.MEH.Einsatz<>'kg');
    if (mode=c_ModeEdit) or (Mode=c_modeNew) or
      (mode=c_ModeEdit2) or (Mode=c_modeNew2) then Lib_GuiCom:Enable($bt.Preis_Mat);
  end
  else begin
    $lbAuf.P.Artikelnr_Mat->wpcaption # Translate('Strukturnr.');
    $edAuf.P.Artikelnr_Mat->wpLengthMax # 20;
    $lb.EH_Mat->wpvisible         # false;
    $lbAuf.P.Menge_Mat->wpvisible # false;
    $edAuf.P.Menge_Mat->wpvisible # false;
    Lib_GuiCom:Disable($bt.Preis_Mat);
  end;

  if ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMixMat(Auf.P.Wgr.Dateinr))) then vWohin # 'MAT'
  else vWohin # 'ART';

  // zu Matmaske wechseln??
  if (vWohin='MAT') and ($NB.Page1->wpcustom<>'NB.Page1_Mat') then begin
    $NB.Main->wpautoupdate    # n;
    $NB.Page1->wpname         # 'NB.Page1_Art';
    // Sicherheitsprüfung...
    if (Winsearch(gMDI,'NB.Page1_Mat')=0) then RETURN false;
    $NB.Page1_Mat->wpvisible  # y;
    $NB.Page1_Mat->wpdisabled # (mode=c_modenew);   // war N
    $NB.Page1_Mat->wpname     # 'NB.Page1';
//    if (aMitFocus) then $NB.Main->wpcurrent # 'NB.Page1';
    $NB.Page1->wpvisible  # n;
    $NB.Page1->wpdisabled # y;

    $Nb.Page3->wpvisible  # y;
    $Nb.Page4->wpvisible  # y;
    $Nb.Page3->wpdisabled # (mode=c_modenew);   // war N
    $Nb.Page4->wpdisabled # (mode=c_modenew);   // war N

    $NB.Main->wpautoupdate # y;
    if (vCurrent<>'NB.List') then $NB.Main->wpcurrent # vCurrent;
    RETURN true;
  end;

  // in Artmakse Wechseln?
  if (vWohin='ART') and ($NB.Page1->wpcustom<>'NB.Page1_Art') then begin
    $NB.Main->wpautoupdate    # n;
    $NB.Page1->wpname         # 'NB.Page1_Mat';
    // Sicherheitsprüfung...
    if (Winsearch(gMDI,'NB.Page1_Art')=0) then RETURN false;
    $NB.Page1_Art->wpvisible  # y;
    $NB.Page1_Art->wpdisabled # (mode=c_modenew);   // war N
    $NB.Page1_Art->wpname     # 'NB.Page1';
//    if (aMitFocus) then $NB.Main->wpcurrent # 'NB.Page1';
    $NB.Page1->wpvisible  # n;
    $NB.Page1->wpdisabled # y;
    $Nb.Page3->wpvisible  # n;
    $Nb.Page3->wpdisabled # y;
    $Nb.Page4->wpvisible  # n;
    $Nb.Page4->wpdisabled # y;

    $NB.Main->wpautoupdate # y;
    if (vCurrent<>'NB.List') then $NB.Main->wpcurrent # vCurrent;

    RETURN true;
  end;

  if (vWohin='MAT') and (Mode<>c_ModeNew) then begin
    $Nb.Page1->wpdisabled # n;
    $Nb.Page2->wpdisabled # n;

    $Nb.Page3->wpvisible  # y;
    $Nb.Page3->wpdisabled # n;
    $Nb.Page4->wpvisible  # y;
    $Nb.Page4->wpdisabled # n;
    RETURN false;
  end;

  if (vWohin='ART') and (Mode<>c_ModeNew) then begin
    $Nb.Page1->wpdisabled # n;
    $Nb.Page2->wpdisabled # n;

    $Nb.Page3->wpvisible  # n;
    $Nb.Page3->wpdisabled # y;
    $Nb.Page4->wpvisible  # n;
    $Nb.Page4->wpdisabled # y;
    RETURN false;
  end;

  RETURN false;
end;


//========================================================================
//  GetArtikel_Mat
//
//========================================================================
sub GetArtikel_Mat();
local begin
  Erx       : int;
  vTxtHdl   : int;
  vName     : alpha;
end;
begin

  if (RunAFX('Auf.P.GetArtikel_Mat','')<0) then RETURN;

  Erx # RecLink(250,401,2,_recfirst);   // Artikel holen
  if (Erx>_rLocked) then RETURN;

  // Feldübernahme
  Auf.P.ArtikelSW     # Art.Stichwort;
  Auf.P.ArtikelTyp    # Art.Typ;
  Auf.P.Sachnummer    # Art.Sachnummer;
  Auf.P.Dicke         # Art.Dicke;
  Auf.P.Breite        # Art.Breite;
  "Auf.P.Länge"       # "Art.Länge";
  Auf.P.Dickentol     # Art.Dickentol;
  Auf.P.Breitentol    # Art.Breitentol;
  "Auf.P.Längentol"   # "Art.Längentol";
  Auf.P.RID           # Art.Innendmesser;
  Auf.P.RAD           # Art.Aussendmesser;
  Auf.P.Intrastatnr   # Art.Intrastatnr;
  Auf.P.AbmessString  # Art.AbmessungString;
  Auf.P.Warengruppe # Art.Warengruppe;    // 04.12.2014

  Auf.P.Menge.Wunsch  # 0.0;
  Auf.P.MEH.Einsatz   # Art.MEH;
  Auf.P.MEH.Wunsch    # Art.MEH;
  Auf.P.MEH.Preis     # Art.MEH;
  Auf.P.Menge         # 0.0;
  Auf.P.PEH           # Art.PEH;
  "Auf.P.Güte"        # "Art.Güte";
  Auf.P.Werkstoffnr   # Art.Werkstoffnr;
  Auf.P.AusfOben      # "Art.AusführungOben";
  Auf.P.AusfUnten     # "Art.AusführungUnten";

  $edAuf.P.Artikelnr_Mat->wpcaption # Auf.P.Artikelnr;

  RecLink(819,250,10,_recfirst);    // Warengruppe holen
  Auf.P.Warengruppe   # Wgr.Nummer;
  Auf_Data:SetWgrDateinr(Wgr.Dateinummer);

  // Text übernehmen...
  Auf.P.TextNr1 # 401;
  Auf.P.TextNr2 # 0;
  vTxtHdl # $Auf.P.TextEditPos->wpdbTextBuf;
  if (Auf.P.Nummer=0) or (Auf.P.Nummer>1000000000) then
    vName # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
  else
    vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    // 23.02.2016 AH: immer USERSprache anzeigen:
  Lib_Texte:TxtLoadLangBuf('~250.VK.'+CnvAI(ART.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, Auf.Sprache);
// 27.03.2018 AH : RÜCKGÄNGIG Lib_Texte:TxtLoadLangBuf('~250.VK.'+CnvAI(ART.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, gUserSprache);
  $Auf.P.TextEditPos->wpcustom # vName;
  $Auf.P.TextEditPos->WinUpdate(_WinUpdBuf2Obj);


  // Ausführugen löschen & kopieren aus Artikel
  WHILE (RecLink(402,401,11,_recFirst)=_rOK) do
    RekDelete(402,0,'MAN');

  if ("Art.Oberfläche"<>0) then begin
    RecBufClear(402);
    Auf.AF.Nummer   # Auf.P.Nummer;
    Auf.AF.Position # Auf.P.Position;
    Auf.AF.Seite    # '1';
    Auf.AF.lfdNr    # 1;
    Auf.AF.ObfNr    # "Art.Oberfläche";

    Erx # RecLink(841,402,1,0); // OBerfläche holen
    if (Erx<=_rLocked) then begin
      Auf.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "Auf.AF.Kürzel"     # "Obf.Kürzel";
      RekInsert(402,0,'AUTO');
      Auf.P.Ausfoben # "Auf.AF.Bezeichnung"+ Auf.AF.Zusatz;;
    end;
  end;
  // Ausführungen kopieren
  FOR Erx # RecLink(257,250,27,_recFirst)
  LOOP Erx # RecLink(257,250,27,_recNext)
  WHILE (Erx<=_rLocked) do begin
    Auf.AF.Nummer         # Auf.P.Nummer;
    Auf.AF.Position       # Auf.P.Position;
    Auf.AF.Seite          # Art.AF.Seite;
    Auf.AF.lfdNr          # Art.AF.lfdNr;
    Auf.AF.ObfNr          # Art.AF.ObfNr;
    Auf.AF.Bezeichnung    # Art.AF.Bezeichnung;
    Auf.AF.Zusatz         # Art.AF.Zusatz;
    Auf.AF.Bemerkung      # Art.AF.Bemerkung;
    "Auf.AF.Kürzel"       # "Art.AF.Kürzel";
    RekInsert(402,0,'AUTO');
    Auf.P.AusfOben        # "Art.AusführungOben";
    Auf.P.AusfUnten       # "Art.AusführungUnten";
  END;

  RecLink(100,400,1,_RecFirst);             // Kunde holen
  if (Art_P_Data:FindePreis('VK', Adr.Nummer, 1.0, '', 1)) then begin
    Auf.P.MEH.Preis      # Art.P.MEH;
    Auf.P.PEH            # Art.P.PEH;
    Auf.P.Grundpreis     # Art.P.PreisW1;
  end;

  Winupdate(gMDI,_WinUpdFld2Obj); // 25.08.2016
  $edAuf.P.GrundPreis->Winupdate(_WinUpdFld2Obj);
  $edAuf.P.Artikelnr_Mat->wpcaption # Auf.P.Artikelnr;
end;


//========================================================================
//  GetArtikel
//
//========================================================================
sub GetArtikel();
local begin
  Erx : int;
end;
begin
  if (RunAFX('Auf.P.GetArtikel','')<0) then RETURN;

  Erx # RecLink(250,401,2,_recfirst);   // Artikel holen
  if (Erx>_rLocked) then RETURN;

  // Feldübernahme...
  Auf.P.ArtikelSW   # Art.Stichwort;
  Auf.P.Warengruppe   # Art.Warengruppe;
  Refreshifm_Page1_Art('edAuf.P.Warengruppe',y);
  Auf.P.Sachnummer  # Art.Sachnummer;
  Auf.P.ArtikelTyp  # Art.Typ;
  Auf.P.Dicke       # Art.Dicke;
  Auf.P.Breite      # Art.Breite;
  "Auf.P.Länge"     # "Art.Länge";
  Auf.P.Dickentol   # Art.Dickentol;
  Auf.P.Breitentol  # Art.Breitentol;
  "Auf.P.Längentol" # "Art.Längentol";
  Auf.P.RID         # Art.Innendmesser;
  Auf.P.RAD         # Art.Aussendmesser;
  Auf.P.Intrastatnr # Art.Intrastatnr;
  Auf.P.AbmessString # Art.AbmessungString;
  Auf.P.Warengruppe # Art.Warengruppe;    // 04.12.2014

  "Auf.P.Güte"        # "Art.Güte";
  Auf.P.Werkstoffnr   # Art.Werkstoffnr;

  Auf.P.PEH         # Art.PEH;
  Auf.P.MEH.Preis   # Art.MEH;
  RecLink(100,400,1,_RecFirst);             // Kunde holen
  Auf.P.KundenArtNr # '';
  if (Art_P_Data:FindePreis('VK', Adr.Nummer, 1.0, '', 1)) then begin
    Auf.P.MEH.Preis       # Art.P.MEH;
    Auf.P.PEH             # Art.P.PEH;
    Auf.P.Grundpreis      # Art.P.PreisW1;
    Auf.P.KundenArtNr     # Art.P.AdressArtNr;
  end;
  Auf.P.MEH.Einsatz   # Art.MEH;
  Auf.P.MEH.Wunsch    # Auf.P.MEH.Einsatz;
  $edAuf.P.GrundPreis->Winupdate(_WinUpdFld2Obj);
  $edAuf.P.PEH->Winupdate(_WinUpdFld2Obj);
  $edAuf.P.MEH.Preis->Winupdate(_WinUpdFld2Obj);

  Winupdate(gMDI,_WinUpdFld2Obj); // 25.08.2016
  Auf_K_Data:Sync2Pos();
  Auf_K_Data:SumKalkulation();
end;


//========================================================================
//  RefreshIfm_Kopf
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm_Kopf(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx         : int;
  vTxtHdl     : int;
  vArtChanged : logic;
  iTemp       : int;
  vRab1,vRab2 : float;
  vBuf100     : int;
  vAllesGeht  : logic;
  v401        : int;
end;
begin

  if (aName='') then begin
    if (Auf.P.Nummer<1000000000) and (Auf.P.Nummer<>0) then begin
      $lb.Nummer0->wpcaption # AInt(Auf.P.Nummer);
    end
    else begin
      $lb.Nummer0->wpcaption # '';
    end;
  end;

  if (aName='') or ((aName='edAuf.Kundennr') and (
    ($edAuf.Kundennr->wpchanged) or (aChanged))) then begin
    Erx # RecLink(100,400,1,_RecFirst);
    if (Erx<=_rLocked) and (Auf.Kundennr<>0) then begin
      $Lb.Kunde1->wpcaption # Adr.Stichwort+', '+Adr.LKZ+', '+Adr.Ort;
      $Lb.Kunde2->wpcaption # Adr.Name+', '+"Adr.Straße";
      if (aName<>'') then begin
        Auf.KundenStichwort   # Adr.Stichwort;
        Auf.P.Kundennr        # Auf.Kundennr;
        Auf.P.KundenSW        # Auf.KundenStichwort;
        Auf.Lieferadresse     # Adr.Nummer;
        if(Set.Auf.LiefAnLeerYN = true) then
          Auf.Lieferanschrift # 0;
        else begin
//          Auf.Lieferanschrift   # 99;
//          Erx # RecLink(101, 400, 2, _recFirst);  // Lieferanschrift testen
//          if (Erx>_rLocked) then
          Auf.Lieferanschrift # 1;
          Erx # RekLink(101,100,76,_recFirst);  // Lieferanschrift holen
          if (Erx<=_rLocked) then begin
            Auf.Lieferadresse   # Adr.A.Adressnr;
            Auf.Lieferanschrift # Adr.A.Nummer;
          end;
        end;
        Auf.RechnungsEmpf     # Auf.Kundennr;
        Auf.Rechnungsanschr   # 1;
        if ("Adr.VK.ReEmpfänger"<>0) then begin
          Auf.RechnungsEmpf   # "Adr.VK.ReEmpfänger";
          Auf.RechnungsAnschr # Adr.VK.ReAnschrift;
        end;
        "Auf.Währung"         # "Adr.VK.Währung";
        Auf.Lieferbed         # Adr.VK.Lieferbed;
        Auf.Zahlungsbed       # Adr.VK.ZAhlungsbed;
        Auf.Versandart        # Adr.VK.Versandart;
        if (Auf.Vorgangstyp=c_GUT) or (Auf.Vorgangstyp=c_Bel_LF) then begin
          "Auf.Währung"         # "Adr.EK.Währung";
          Auf.Lieferbed         # Adr.EK.Lieferbed;
          Auf.Zahlungsbed       # Adr.EK.ZAhlungsbed;
          Auf.Versandart        # Adr.EK.Versandart;
        end;

        // 2022-07-18 AH    vorhandene Sätze anpassen
        v401 # RekSave(501);
        FOR Erx # RecLink(401,400,9,_recFirst)
        LOOP Erx # RecLink(401,400,9,_recNext)
        WHILE (Erx<=_rLocked) do begin
          Erx # RecRead(401,1,_recLock);
          Auf.P.Kundennr        # Auf.Kundennr;
          Auf.P.KundenSW        # Auf.KundenStichwort;
          Erx # Rekreplace(401);
        END;
        RekRestore(v401);
        RecRead(401,1,_recLock|_recNoLoad);


        // Neu 24.06.2014 AH:
        if (Mode = c_ModeNew) and (Adr.Sachbearbeiter<>'') then
          Auf.Sachbearbeiter # Adr.Sachbearbeiter;

        Auf.Sprache           # Adr.Sprache;
        Auf.AbmessungsEH      # Adr.AbmessungEH;
        Auf.GewichtsEH        # Adr.GewichtEH;
        if (Set.Auf.STSvomKdYN) then
          "Auf.Steuerschlüssel" # "Adr.Steuerschlüssel";
        Auf.Vertreter         # Adr.Vertreter;
        Auf.Vertreter2        # Adr.Verband;
        // 20.02.2018 AH:
        Auf.Vertreter.Prov # 0.0;
        Auf.Vertreter.ProT # 0.0;
        if (Auf.Vertreter<>0) then begin
          Erx # RekLink(110,400,20,_RecFirst);
          if (Erx<=_rLocked) then begin
            if (Ver.ProvisionProTJN) then
              Auf.Vertreter.ProT # Ver.ProvisionProz
            else
              Auf.Vertreter.Prov # Ver.ProvisionProz;
          end;
        end;
      end;
    end
    else begin
      $Lb.Kunde1->wpcaption # '';
      $Lb.Kunde2->wpcaption # '';
      Auf.KundenStichwort # '';
    end;
    Auf_P_Main:RefreshIfm('edAuf.Lieferadresse');
    Auf_P_Main:RefreshIfm('edAuf.Lieferanschrift',y);
    Auf_P_Main:RefreshIfm('edAuf.Rechnungsempf', aName <> '');
    Auf_P_Main:RefreshIfm('edAuf.Rechnungsanschr', aName <> '');
    Auf_P_Main:RefreshIfm('edAuf.Waehrung');
    Auf_P_Main:RefreshIfm('edAuf.Lieferbed');
    Auf_P_Main:RefreshIfm('edAuf.Zahlungsbed');
    Auf_P_Main:RefreshIfm('edAuf.Versandart');
    Auf_P_Main:RefreshIfm('edAuf.Sprache');
    Auf_P_Main:RefreshIfm('edAuf.AbmessungsEH');
    Auf_P_Main:RefreshIfm('edAuf.GewichtsEH');
    Auf_P_Main:RefreshIfm('edAuf.Steuerschluessel');
    Auf_P_Main:RefreshIfm('edAuf.Vertreter1');
    Auf_P_Main:RefreshIfm('edAuf.Sachbearbeiter');

    // Ankerfunktion?
    if (Auf.KundenStichwort<>'') then begin
      RunAFX('Auf.P.Auswahl.Kunde',aName);
    end;
  end;

  if (aName='') or (aName='edAuf.Lieferadresse') or (aName='edAuf.Lieferanschrift') then begin
    Erx # RecLink(101,400,2,_RecFirst);
    if (Erx<=_rLocked) and (Auf.Lieferadresse<>0) then begin
      $Lb.Lieferadresse1->wpcaption # Adr.A.Stichwort+', '+Adr.A.LKZ+', '+Adr.A.Ort;
      $Lb.Lieferadresse2->wpcaption # Adr.A.Name+', '+"Adr.A.Straße";
      if (($edAuf.Lieferanschrift->wpchanged) or ($edAuf.Lieferadresse->wpchanged) or (aChanged)) then begin
        // Ankerfunktion?
        RunAFX('Auf.P.Auswahl.Lieferadresse',aName);
      end;
    end
    else begin
      $Lb.Lieferadresse1->wpcaption # '';
      $Lb.Lieferadresse2->wpcaption # '';
    end;
  end;


  if (aName='') or (aName='edAuf.Verbraucher') then begin
    Erx # RecLink(100,400,3,_RecFirst);
    if (Erx<=_rLocked) and (Auf.Verbraucher<>0) then begin
      $Lb.Verbraucher->wpcaption # Adr.Stichwort+', '+Adr.LKZ+', '+Adr.Ort;
    end
    else begin
      $Lb.Verbraucher->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edAuf.Rechnungsempf') or (aName='edAuf.Rechnungsanschr') then begin
    Erx # RecLink(100,400,4,_RecFirst);   // Rechnungsempfänger holen
    if (Erx<=_rLocked) and (Auf.Rechnungsempf<>0) then begin
      vBuf100 # Adr_Data:HoleBufferAdrOderAnschrift(Auf.Rechnungsempf, Auf.Rechnungsanschr);
      if (vBuf100<>0) then begin
        $Lb.RechEmpf->wpcaption   # vBuf100->Adr.Stichwort+', '+vBuf100->Adr.LKZ+', '+vBuf100->Adr.Ort;
        $Lb.RechEmpf2->wpcaption  # vBuf100->Adr.Name+', '+vBuf100->"Adr.Straße"+', '+vBuf100->Adr.USIdentNr;
        RecBufDestroy(vBuf100);
      end
      else begin
        $Lb.RechEmpf->wpcaption # '';
        $Lb.RechEmpf2->wpcaption # '';
      end;
    end
    else begin
      RecBufclear(100);
      $Lb.RechEmpf->wpcaption # '';
      $Lb.RechEmpf2->wpcaption # '';
    end;
    if ($edAuf.Rechnungsempf->wpchanged) or ($edAuf.Rechnungsanschr->wpchanged) or (aChanged) then begin
      if (Set.Auf.STSvomKdYN=n) then begin

      if (Auf.Rechnungsanschr<>0) then
        vBuf100 # Adr_Data:HoleBufferAdrOderAnschrift(Auf.Rechnungsempf, Auf.Rechnungsanschr);
        if (vBuf100<>0) then begin
          "Auf.Steuerschlüssel" # vBuf100->"Adr.Steuerschlüssel";
          RecBufDestroy(vBuf100);
        end
        else begin
          "Auf.Steuerschlüssel" # "Adr.Steuerschlüssel";
        end;
      end;
      Auf.Zahlungsbed       # Adr.VK.ZAhlungsbed;
      "Auf.Währung"         # "Adr.VK.Währung";
      if (Auf.Vorgangstyp=c_GUT) or (Auf.Vorgangstyp=c_Bel_LF) then begin
        Auf.Zahlungsbed       # Adr.EK.ZAhlungsbed;
        "Auf.Währung"         # "Adr.EK.Währung";
      end;
    end;
    Auf_P_Main:RefreshIfm('edAuf.Waehrung');
    Auf_P_Main:RefreshIfm('edAuf.Zahlungsbed');
    Auf_P_Main:RefreshIfm('edAuf.Steuerschluessel');

    // Ankerfunktion?
    if (Auf.Rechnungsempf<>0) then begin
      RunAFX('Auf.P.Auswahl.ReEmpf',aName);
    end;
  end;

  if (aName='') or (aName='edAuf.BDSNummer') then begin
    Erx # RecLink(836,400,11,_RecFirst);
    if (Erx<=_rLocked) then
      $Lb.BDS->wpcaption # BDS.Bezeichnung
    else
      $Lb.BDS->wpcaption # '';
  end;

  if (aName='') or (aName='edAuf.Land') then begin
    Erx # RecLink(812,400,10,_RecFirst);
    if (Erx<=_rLocked) then
      $Lb.Land->wpcaption # Lnd.Name.L1
    else
      $Lb.Land->wpcaption # '';
  end;

  if (aName='') or (aName='edAuf.Waehrung') then begin
    Erx # RecLink(814,400,8,_RecFirst);
    if (Erx<=_rLocked) then
      $Lb.Waehrung->wpcaption # Wae.Bezeichnung
    else
      $Lb.Waehrung->wpcaption # '';
  end;

  if (aName='') or (aName='edAuf.Lieferbed') then begin
    Erx # RecLink(815,400,5,_RecFirst);
    if (Erx<=_rLocked) then
      $Lb.Lieferbed->wpcaption # LIb.Bezeichnung.L1
    else
      $Lb.Lieferbed->wpcaption # '';

    if (aChanged) or ($edAuf.Lieferbed->wpchanged) then
      RunAFX('Auf.P.Auswahl.Lieferbed','');
  end;

  if (aName='') or (aName='edAuf.Zahlungsbed') then begin
    Erx # RecLink(816,400,6,_RecFirst);
    if (Erx<=_rLocked) then
      $Lb.Zahlungsbed->wpcaption # ZaB.Kurzbezeichnung
    else
      $Lb.Zahlungsbed->wpcaption # '';
  end;

  if (aName='') or (aName='edAuf.Steuerschluessel') then begin
    Erx # RecLink(813,400,19,_RecFirst);
    if (Erx<=_rLocked) then
      $Lb.Steuerschluessel->wpcaption # StS.Bezeichnung
    else
      $Lb.Steuerschluessel->wpcaption # '';
  end;

  if (aName='') or (aName='edAuf.Versandart') then begin
    Erx # RecLink(817,400,7,_RecFirst);
    if (Erx>_rLocked) then RecBufClear(817);
    $lb.Versandart->wpcaption # VsA.Bezeichnung.L1

    if (aChanged) or ($edAuf.Versandart->wpchanged) then
      RunAFX('Auf.P.Auswahl.Versandart','');
  end;

  if (aName='') or (aName='edAuf.Vertreter1') then begin
    Erx # RecLink(110,400,20,_RecFirst);
    if (Erx<=_rLocked) and (Auf.Vertreter<>0) then
      $Lb.Vertreter1->wpcaption # Ver.Stichwort
    else
      $Lb.Vertreter1->wpcaption # '';
  end;

  if (aName='') or (aName='edAuf.Vertreter2') then begin
    Erx # RecLink(110,400,21,_RecFirst);
    if (Erx<=_rLocked) and (Auf.Vertreter2<>0) then
      $Lb.Vertreter2->wpcaption # Ver.Stichwort
    else
      $Lb.Vertreter2->wpcaption # '';
  end;

  if (Mode<>c_ModeView) and (
    (aName='') or (aName='edAuf.Vorgangstyp')) then begin
    if (Auf.Vorgangstyp<>c_ANG) and (Auf.Vorgangstyp<>c_AUF) then begin
      Auf.AbrufYN         # n;
      Auf.PAbrufYN        # n;
      Auf.LiefervertragYN # n;
      $cbAuf.LiefervertragYN->winupdate(_WinUpdFld2Obj);
      $cbAuf.AbrufYN->winupdate(_WinUpdFld2Obj);
      $cbAuf.PAbrufYN->winupdate(_WinUpdFld2Obj);
    end;
    vAllesGeht # ((Auf.Vorgangstyp=c_AUF) and ((Mode=c_ModeNew) or ((Mode=c_ModeNew2) and (Auf.P.Position=1))));
    Lib_GuiCom:Able($cbAuf.LiefervertragYN, ((Auf.Vorgangstyp=c_ANG) or (vAllesGeht)));
    Lib_GuiCom:Able($cbAuf.AbrufYN,         vAllesGeht);
    Lib_GuiCom:Able($cbAuf.PAbrufYN,        vAllesGeht);
    Lib_guiCom:Able($edAuf.GltigkeitVom,    ((Auf.Vorgangstyp=c_ANG) or (Auf.LiefervertragYN)));
    Lib_guiCom:Able($edAuf.Gltigkeitbis,    ((Auf.Vorgangstyp=c_ANG) or (Auf.LiefervertragYN)));
  end;

end;

//========================================================================
//  RefreshIfm_Page1_Art
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm_Page1_Art(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx         : int;
  vTxtHdl     : int;
  vArtChanged : logic;
  iTemp       : int;
  vRab1,vRab2 : float;
end;
begin
//debug('Page art:'+cnvai(Auf.p.nummer)+'/'+cnvai(auf.p.position)+'   '+aname);

  // 04.12.2012 AI: nut bei Gut/Bel...
  if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) or
    (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then begin
    if ((aName='edAuf.P.AbrufAufPos_Mat') and ((aChanged) or ($edAuf.P.AbrufAufPos_Mat->wpchanged))) or
      ((aName='edAuf.P.AbrufAufPos') and ((aChanged) or ($edAuf.P.AbrufAufPos->wpchanged))) then begin

      if (Auf_P_Subs:CopyAuf2GutBel(Auf.P.AbrufAufNr, Auf.P.AbrufAufPos)) then begin
        if (aName='edAuf.P.AbrufAufPos') then
          Refreshifm_Page1_Art('edAuf.P.Warengruppe')
        else
          Refreshifm_Page1_Art('edAuf.P.Warengruppe_Mat');
        Refreshifm_Page1_Mat('');
        gMDI->winupdate();
      end;
    end;
  end;  // Gut/Bel


  if (aName='') then begin
    if (Mode=c_ModeView) then begin
      vRab1 # 0.0;
      vRab2 # 0.0;
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) and ((vRab1=0.0) or (vRab2=0.0)) do begin
        if ("Auf.Z.Schlüssel"='*RAB1') then vRab1 # (-1.0) * Auf.Z.Menge;
        if ("Auf.Z.Schlüssel"='*RAB2') then vRab2 # (-1.0) * Auf.Z.Menge;
        Erx # RecLink(403,401,6,_RecNext);
      END;
      $edRabatt1->wpcaptionfloat # vRab1;
    end;
    Erx # RekLink(814,400,8,_RecFirst);
    $lb.WAE1->wpcaption # "Wae.Kürzel";
    $lb.WAE2->wpcaption # "Wae.Kürzel";
    $lb.WAE3->wpcaption # "Wae.Kürzel";
    $lb.WAE4->wpcaption # "Wae.Kürzel";
    $lb.WAE5->wpcaption # "Wae.Kürzel";

    if (RecLinkInfo(405,401,7,_RecCount)=0) then begin
      $cb.Kalkulation_Art->wpCheckState # _WinStateChkUnChecked;
    end
    else begin
      $cb.Kalkulation_Art->wpCheckState # _WinStateChkChecked;
    end;

  end;

  $lb.Kalkuliert->wpcaption # ANum(Auf.P.Kalkuliert,2);
  $lb.Poswert->wpcaption    # ANum(Auf.P.Gesamtpreis,2);
  $lb.Rohgewinn->wpcaption  # ANum(Auf.P.Gesamtpreis - "Auf.P.GesamtwertEKW1",2);
  $lb.Aufpreise->wpcaption  # ANum(Auf.P.Aufpreis,2);


  if (Mode=c_Modeview) and (Auf.P.Nummer<>0) and (Auf.P.Nummer<1000000000) then begin
    RecLink(400,401,3,_RecFirst);  // Kopf holen
  end;

  if (aName='') then begin
    $RL.Aufpreise->winupdate(_winupdon,_WinLstFromFirst);
  end;

  if (aName='') then begin
    if (Auf.P.Nummer<1000000000) and (Auf.P.Nummer<>0) then begin
      $lb.Nummer1->wpcaption # AInt(Auf.P.Nummer);
    end
    else begin
      $lb.Nummer1->wpcaption # '';
    end;
    $lb.Position1->wpcaption # AInt(Auf.P.Position);
    $lb.P.Kunde1->wpcaption # Auf.P.KundenSW;
    $lb.Auf.P.Prd.Rest->wpcaption # ANum(Auf.P.Prd.Rest,Set.Stellen.Menge);
  end;

  if (aName='') or (aName='edAuf.P.Projektnummer') then begin
    Erx # RecLink(120,401,14,_RecFirst);
    if (Erx<=_rLocked) then
      $lb.Projekt->wpcaption # Prj.Stichwort
    else
      $lb.Projekt->wpcaption # '';
  end;

  if ((aName='') or (aName='edAuf.P.Warengruppe')) then begin
    Erx # RecLink(819,401,1,_RecFirst);   // Warengruppe holen
    if (Erx<=_rlocked) then begin
      if (mode=c_modenew) or (mode=c_Modenew2) then Auf_Data:SetWgrDateinr(Wgr.Dateinummer);
      $lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1;
      if (Mode=c_ModeEdit) then begin   // 08.10.2020 AH: Proj. 2101/38
        Auf.P.MEH.Einsatz  # ProtokollBuffer[401]->Auf.P.Meh.Einsatz;
        Auf.P.MEH.Wunsch   # ProtokollBuffer[401]->Auf.P.Meh.Wunsch;
      end;
    end
    else begin
      Auf.P.Wgr.Dateinr # Set.Auf.Dateinr;    // 2023-04-25 AH war 0;
      $lb.Warengruppe->wpcaption # '???';
    end;
    if (Erx>_rLocked) then RecBufClear(819);
  end;

  if (aName='edAuf.P.Artikelnr') and (($edAuf.P.Artikelnr->wpchanged) or (aChanged)) then begin
    Auf.P.Sachnummer  # '';
    Auf.P.ArtikelSW   # '';
    Auf.P.ArtikelTyp  # '';
    Art.Nummer # $edAuf.P.Artikelnr->wpcaption; // Verkn∑pfung arbeitet nur ∑ber Art.ID
    Erx # RecRead(250,1,0);                     // daher manuell lesen.
    if (Erx <= _rLocked) then begin             // Stichw. etc. aktualisieren
      Auf.P.Artikelnr   # Art.Nummer;           // Felder f∑llen
      vArtChanged # y;
    end;
  end;

  if (aName='edAuf.P.Guete') then begin
    MQU_Data:Autokorrektur(var "Auf.P.Güte");
    Auf.P.Werkstoffnr # MQU.Werkstoffnr;
  end;


  if (vArtChanged) then begin
    GetArtikel();
  end;


  if (aName='') or (vArtChanged) then begin

    Erx # RecLink(250,401,2,_RecFirst); // Artikel holen
    if (Erx<=_rLocked) then begin
      RecBufClear(252);
      Art.C.ArtikelNr     # Auf.P.ArtikelNr;
      Art_Data:ReadCharge();
    end
    else begin
      RecBufClear(252);
      RecBufClear(250);
    end;

    $lb.P.Bez1->wpcaption # Art.Bezeichnung1;
    $lb.P.Bez2->wpcaption # Art.Bezeichnung2;
    $lb.P.Bez3->wpcaption # Art.Bezeichnung3;

    if (Art.Artikelgruppe=0) then
      $lb.Art.ArtGrp->wpcaption   # ''
    else
      $lb.Art.ArtGrp->wpcaption   # aint(Art.Artikelgruppe);
    Erx # RekLink(826,250,11,_recFirst);    // Artikelgruppe holen
    $lb.Art.ArtGrpText->wpcaption # AGr.Bezeichnung.L1;
    $Picture1->wpcaption # '*'+Art.Bilddatei;

    Winupdate($edAuf.P.Artikelnr,_WinUpdFld2Obj);
    Winupdate($edAuf.P.KundenArtNr,_WinUpdFld2Obj);
    WinUpdate($edAuf.P.MEH.Wunsch,_WinUpdFld2Obj);
    $edAuf.P.Warengruppe->winupdate(_WinUpdFld2Obj);
    $lb.Art.IstBestand->wpcaption # ANum(Art.C.Bestand,2);
    $lb.Art.Reserviert->wpcaption # ANum(Art.C.Reserviert+Art.C.OffeneAuf,2);
    $lb.Art.Bestellt->wpcaption   # ANum(Art.C.Bestellt,2);
    $lb.Art.Verfuegbar->wpcaption # ANum("Art.C.Verfügbar",2);
    $lb.Art.MEH1->wpcaption       # Auf.P.MEH.Einsatz;
    $lb.Art.MEH2->wpcaption       # Auf.P.MEH.Einsatz;
    $lb.Art.MEH3->wpcaption       # Auf.P.MEH.Einsatz;
    $lb.Art.MEH4->wpcaption       # Auf.P.MEH.Einsatz;
    $lb.Art.MEH5->wpcaption       # Auf.P.MEH.Einsatz;
    $lb.Art.MEH6->wpcaption       # Auf.P.MEH.Einsatz;
    Auf_P_Main:Refreshmode(y);

    if (vArtChanged) then
      // 17.05.2016 AH:
      $edAuf.P.Bemerkung2->Winfocusset(true);
//      $edAuf.P.MEH.Wunsch->Winfocusset(true)
  end;

  if (aName='') or (aName='edAuf.P.Auftragsart') then begin
    Erx # RecLink(835,401,5,_RecFirst);
    if (Erx<=_rLocked) then
      $lb.AuftragsArt->wpcaption # AAr.Bezeichnung
    else
      $lb.AuftragsArt->wpcaption # '';

    if (aChanged) or ($edAuf.P.Auftragsart->wpchanged) then
      RunAFX('Auf.P.Auswahl.Auftragsart','');
  end;

end;


//========================================================================
//  RefreshIfm_Page1_Mat
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm_Page1_Mat(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx         : int;
  vTxtHdl     : int;
  vArtChanged : logic;
  iTemp       : int;
  vRab1,vRab2 : float;
  vBuf401     : int;
  vBuf411     : int;
end;
begin
//debug('Page mat:'+cnvai(Auf.p.nummer)+'/'+cnvai(auf.p.position)+'   '+aname+'   '+auf.p.artikelnr);

  if (aName='') then begin

    if (Wgr_Data:IstMixMat(Auf.P.Wgr.Dateinr)) then begin
      $edAuf.P.Artikelnr_Mat->wpcaption # Auf.P.Artikelnr;
      $lb.EH_Mat->wpvisible         # (Auf.P.MEH.Einsatz<>'Stk') and (Auf.P.MEH.Einsatz<>'kg')
      $lbAuf.P.Menge_Mat->wpvisible # (Auf.P.MEH.Einsatz<>'Stk') and (Auf.P.MEH.Einsatz<>'kg')
      $edAuf.P.Menge_Mat->wpvisible # (Auf.P.MEH.Einsatz<>'Stk') and (Auf.P.MEH.Einsatz<>'kg')
    end
    else begin
      $edAuf.P.Artikelnr_Mat->wpcaption # Auf.P.Strukturnr;
      $lb.EH_Mat->wpvisible         # false;
      $lbAuf.P.Menge_Mat->wpvisible # false;
      $edAuf.P.Menge_Mat->wpvisible # false;
    end;

    $RL.AFOben->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    $RL.AFUnten->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    $lb.Aufpreise_Mat->wpcaption  # ANum(Auf.P.Aufpreis,2);
    $lb.Aufpreise->wpcaption      # ANum(Auf.P.Aufpreis,2);

    Erx # RekLink(814,400,8,_RecFirst);
    $lb.WAE1_Mat->wpcaption # "Wae.Kürzel";
    $lb.WAE2_Mat->wpcaption # "Wae.Kürzel";
    $lb.WAE3_Mat->wpcaption # "Wae.Kürzel";
    $lb.WAE4_Mat->wpcaption # "Wae.Kürzel";

    if (RecLinkInfo(405,401,7,_RecCount)=0) then begin
      $cb.Kalkulation_Mat->wpCheckState # _WinStateChkUnChecked;
    end
    else begin
      $cb.Kalkulation_Mat->wpCheckState # _WinStateChkChecked;
    end;
  end;

  $lb.P.Einzelpreis_Mat->wpcaption  # ANum(Auf.P.Einzelpreis,2);
  $lb.Poswert_Mat->wpcaption        # ANum(Auf.P.Gesamtpreis,2);

  if (Mode=c_Modeview) and (Auf.P.Nummer<>0) and (Auf.P.Nummer<1000000000) then begin
    RecLink(400,401,3,_RecFirst);  // Kopf holen
  end;

  if (aName='') then begin
    $RL.Aufpreise_Mat->winupdate(_winupdon,_WinLstFromFirst);
  end;

  if (aName='') then begin
    if (Auf.P.Nummer<1000000000) and (Auf.P.Nummer<>0) then begin
      $lb.Nummer1_Mat->wpcaption # AInt(Auf.P.Nummer);
    end
    else begin
      $lb.Nummer1_Mat->wpcaption # '';
    end;
    $lb.Position1_Mat->wpcaption # AInt(Auf.P.Position);
    $lb.P.Kunde1_Mat->wpcaption # Auf.P.KundenSW;
  end;

  if (aName='') or (aName='edAuf.P.Projektnummer_Mat') then begin
    Erx # RecLink(120,401,14,_RecFirst);
    if (Erx<=_rLocked) then
      $lb.Projekt_Mat->wpcaption # Prj.Stichwort
    else
      $lb.Projekt_Mat->wpcaption # '';
  end;

  if (aName='edAuf.P.Artikelnr_Mat') and (($edAuf.P.Artikelnr_Mat->wpchanged) or (achanged)) then begin
    if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
      Auf.P.Artikelnr # $edAuf.P.Artikelnr_Mat->wpcaption;
      GetArtikel_Mat();
      gMDI->Winupdate();
      Refreshifm_Page1_Mat('');
    end
    else begin
      Auf.P.Strukturnr # $edAuf.P.Artikelnr_Mat->wpcaption;
      Erx # RecLink(220,401,21,_recFirst);   // Mat.Struktur holen
      if (Erx <= _rLocked) then begin
        if (Auf.P.Grundpreis=0.0) then begin
          Wae_Umrechnen(MSL.PreisW1,1,var Auf.P.Grundpreis, "Auf.Währung");
          $edAuf.P.Grundpreis_Mat->Winupdate(_WinUpdFld2Obj);
        end;
        $edAuf.P.GrundPreis->Winupdate(_WinUpdFld2Obj);
        // Ankerfunktion
        RunAFX('Auf.P.Auswahl.Strukt','');
      end
    end;
  end;


  if (aName='edAuf.P.Dickentol_Mat') and (Auf.P.Dicke<>0.0) then begin
    "Auf.P.Dickentol" # Lib_Berechnungen:Toleranzkorrektur("Auf.P.Dickentol",Set.Stellen.Dicke);
  end;

  if (aName='edAuf.P.Breitentol_Mat') and (Auf.P.Breite<>0.0) then begin
    "Auf.P.Breitentol" # Lib_Berechnungen:Toleranzkorrektur("Auf.P.Breitentol",Set.Stellen.Breite);
  end;

  if (aName='edAuf.P.Laengentol_Mat') and ("Auf.P.Länge"<>0.0) then begin
    "Auf.P.Längentol" # Lib_Berechnungen:Toleranzkorrektur("Auf.P.Längentol","Set.Stellen.Länge");
  end;

  if ((aName='') or (aName='edAuf.P.Warengruppe_Mat')) then begin
    Erx # RecLink(819,401,1,_RecFirst);   // Warengruppe holen
    if (Erx<=_rlocked) then begin
      if (mode=c_modenew) or (mode=c_Modenew2) then Auf_Data:SetWgrDateinr(Wgr.Dateinummer);
      $lb.Warengruppe_Mat->wpcaption # Wgr.Bezeichnung.L1;
    end
    else begin
      Auf.P.Wgr.Dateinr # Set.Auf.Dateinr;    // 2023-04-25 AH war 0;
      $lb.Warengruppe_Mat->wpcaption # '???';
    end;
    if (Erx>_rLocked) then RecBufClear(819);
  end;
  if (aName='') or (aName='edAuf.P.Auftragsart_Mat') then begin
    Erx # RecLink(835,401,5,_RecFirst);
    if (Erx<=_rLocked) then
      $lb.AuftragsArt_Mat->wpcaption # AAr.Bezeichnung
    else
      $lb.AuftragsArt_Mat->wpcaption # '';
    if (aChanged) or ($edAuf.P.Auftragsart_Mat->wpchanged) then
      RunAFX('Auf.P.Auswahl.Auftragsart','');
  end;

  // 04.12.2012 AI: nut bei Gut/Bel...
  if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) or
    (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then begin
    if ((aName='edAuf.P.AbrufAufPos_Mat') and ((aChanged) or ($edAuf.P.AbrufAufPos_Mat->wpchanged))) or
      ((aName='edAuf.P.AbrufAufPos') and ((aChanged) or ($edAuf.P.AbrufAufPos->wpchanged))) then begin

      if (Auf_P_Subs:CopyAuf2GutBel(Auf.P.AbrufAufNr, Auf.P.AbrufAufPos)) then begin
        if (aName='edAuf.P.AbrufAufPos') then
          Refreshifm_Page1_Mat('edAuf.P.Warengruppe')
        else
          Refreshifm_Page1_Mat('edAuf.P.Warengruppe_Mat');
        Refreshifm_Page1_Mat('');
        gMDI->winupdate();
      end;
    end;
  end;  // Gut/Bel


  if (aName='edAuf.P.Guete_Mat') then begin
    MQU_Data:Autokorrektur(var "Auf.P.Güte");
    Auf.P.Werkstoffnr # MQU.Werkstoffnr;
  end;

  if (aName='') or (aName='edAuf.P.Erzeuger_Mat') then begin
    Erx # RecLink(100,401,10,_RecFirst);
    if (Erx<=_rLocked) then
      $lb.Erzeuger_Mat->wpcaption # Adr.Stichwort
    else
      $lb.Erzeuger_Mat->wpcaption # '';
  end;


  if (aName='edauf.P.Verpacknr') and ($edAuf.P.Verpacknr->wpchanged) then begin
    Erx # RecLink(100,400,1,0); // Kunde holen
    If (Erx>=_rLocked) then RecBufClear(100);
    RecBufClear(105);
    Adr.V.Adressnr        # Adr.Nummer;
    Adr.V.lfdNr           # Auf.P.Verpacknr;
    Erx # RecRead(105,1,0);
    if (Erx<=_rLocked) then begin
      Auf.P.Verpacknr       # Adr.V.lfdNr;
      Auf.P.AbbindungL      # Adr.V.AbbindungL;
      Auf.P.AbbindungQ      # Adr.V.AbbindungQ;
      Auf.P.Zwischenlage    # Adr.V.Zwischenlage;
      Auf.P.Unterlage       # Adr.V.Unterlage;
      Auf.P.Umverpackung    # Adr.V.Umverpackung;
      Auf.P.Wicklung        # Adr.V.Wicklung;
      Auf.P.MitLfEYN        # Adr.V.MitLfEYN;
      Auf.P.StehendYN       # Adr.V.StehendYN;
      Auf.P.LiegendYN       # Adr.V.LiegendYN;
      Auf.P.Nettoabzug      # Adr.V.Nettoabzug;
      "Auf.P.Stapelhöhe"    # "Adr.V.Stapelhöhe";
      Auf.P.StapelhAbzug    # Adr.V.StapelhAbzug;
      Auf.P.RingKgVon       # Adr.V.RingKgVon;
      Auf.P.RingKgBis       # Adr.V.RingKgBis;
      Auf.P.KgmmVon         # Adr.V.KgmmVon;
      Auf.P.KgmmBis         # Adr.V.KgmmBis;
      "Auf.P.StückProVE"      # "Adr.V.StückProVE";
      Auf.P.VEkgMax         # Adr.V.VEkgMax;
      Auf.P.RechtwinkMax    # Adr.V.RechtwinkMax;
      Auf.P.EbenheitMax     # Adr.V.EbenheitMax;
      "Auf.P.SäbeligkeitMax" # "Adr.V.SäbeligkeitMax";
      "Auf.P.SäbelProM"     # "Adr.V.SäbelProM";
      Auf.P.Etikettentyp    # Adr.V.Etikettentyp;
      Auf.P.Verwiegungsart  # Adr.V.Verwiegungsart;
    end;
  end;

end;


//========================================================================
//  RefreshIfm_Page2
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm_Page2(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx         : int;
  vTxtHdl     : int;
  vArtChanged : logic;
  iTemp       : int;
  vRab1,vRab2 : float;
  vOK         : logic;
  vName       : alpha;
  vFont       : font;
end;
begin

  if (Mode=c_Modeview) and (Auf.P.Nummer<>0) and (Auf.P.Nummer<1000000000) then begin
    RecLink(400,401,3,_RecFirst);  // Kopf holen
  end;

  if (aName='') then begin

// 20.02.2018 AH: TEXT:
    vTxtHdl # TextOpen( 16 );
    vFont   # $bt.InternerText->wpFont;
    if (Auf.P.Nummer=0) or (Auf.P.Nummer>1000000000) then
      vName # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01'
    else
      vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
    if (vTxtHdl->TextRead( vName, _textNoContents ) <= _rLocked ) then
      vFont:Attributes # _winFontAttrBold;
    else
      vFont:Attributes # _winFontAttrNormal;
    $bt.InternerText->wpFont  # vFont;
    TextClose(vTxtHdl);


    if (Auf.P.Nummer<1000000000) and (Auf.P.Nummer<>0) then begin
      $lb.Nummer2->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer2b->wpcaption # AInt(Auf.P.Nummer);
    end
    else begin
      $lb.Nummer2->wpcaption # '';
      $lb.Nummer2b->wpcaption # '';
    end;
    $lb.Position2->wpcaption # AInt(Auf.P.Position);
    $lb.P.Kunde2->wpcaption # Auf.P.KundenSW;

    vOk # n;
    vTxtHdl # $Auf.P.TextStammdaten->wpdbTextBuf;
    if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) and
      (Auf.P.Artikelnr<>'') then begin
      vOK # y;
      Erx # RecLink(250,401,2,_RecFirst); // Artikel holen
      if (Erx<=_rLocked) then begin
        $Picture1->wpcaption # '*'+Art.Bilddatei;
        // 23.02.2016 AH: immer USERSprache anzeigen:
        //if (Lib_texte:TxtLoadLangBuf('~250.VK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,Auf.Sprache)=false) then vOK # n;
        if (Lib_texte:TxtLoadLangBuf('~250.VK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, gUserSprache)=false) then vOK # n;
      end
      else begin
        $Picture1->wpcaption # '';
        vOK # n;
      end;
    end
    else if (Auf.P.KundenArtNr<>'') and (Auf.P.VerpackAdrNr<>0) then begin
      Erx # RecLink(105,401,22,_RecFirst);
      if (Erx<=_rLocked) then begin
        vOK # y;
        if (Adr.V.TextNr1=0) then begin // Standardtext
          vName # '~837.'+CnvAI(Adr.V.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
          Lib_Texte:TxtLoad5Buf(vName, vTxtHdl,0,0,0,0);
        end
        else if (Adr.V.TextNr1=105) then begin // Idividuell
          vName # '~105.'+CnvAI(Adr.V.AdressNr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+'.'+CnvAI(Adr.V.LfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4)+'.01';
          if (TextRead(vTxtHdl,vName, _TextUnlock)>_rLocked) then begin
            TextClear(vTxtHdl);
          end;
        end;
      end;
    end;
    if (vOK=n) then TextClear(vTxtHdl);
    $Auf.P.TextStammdaten->WinUpdate(_WinUpdBuf2Obj);
  end;


  // Textvorlage
  if (Auf.P.TextNr1=0) then begin
    $edAuf.P.TextNr2b->wpcaptionint # Auf.P.TextNr2;
    $cb.Text2->wpCheckState # _WinStateChkChecked;
  end
  else
    $edAuf.P.TextNr2b->wpcaptionint # 0;

  // Andere Position
  if (Auf.P.TextNr1=400) then begin
    $edAuf.P.TextNr2->wpcaptionint # Auf.P.TextNr2
    $cb.Text1->wpCheckState # _WinStateChkChecked;
  end
  else
    $edAuf.P.TextNr2->wpcaptionint # 0;

  // Individuell
  if (Auf.P.TextNr1= 401) then
    $cb.Text3->wpCheckState # _WinStateChkChecked;


  // ST 2009-08-10
  // Standardtext immer neu laden
  begin
    // Standardtext
    if (Auf.P.Textnr2<> 0) then begin

      // Puffer erstellen
      vTxtHdl # $Auf.P.TextEditPos->wpdbTextBuf;
      if (vTxtHdl = 0) then begin
        vTxtHdl # TextOpen(32);
        $Auf.P.TextEditPos->wpdbTextBuf # vTxtHdl;
      end;
      Auf_P_Main:AufPTextLoad();
    end;

  end; // Standardtext immer neu laden


  if (aName='') or (aName='edAuf.P.TextNr2') or (aName='edAuf.P.TextNr2b') then begin
    Auf_P_Main:AufPTextLoad();
  end;

  if (aName='') or (aName='Text') then begin
    if (Auf.P.TextNr1=401) then begin
      if (Mode<>c_ModeView) then begin
        Lib_GuiCom:Enable($Auf.P.TextEditPos);
        Lib_GuiCom:Disable($edAuf.P.TextNr2);
        Lib_GuiCom:Disable($edAuf.P.TextNr2b);
      end;
      $cb.Text1->wpCheckState # _WinStateChkUnChecked;
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkChecked;
    end
    else if (Auf.P.TextNr1=400) then begin
      if (Mode<>c_ModeView) then begin
        Lib_GuiCom:Disable($Auf.P.TextEditPos);
        Lib_GuiCom:Enable($edAuf.P.TextNr2);
        Lib_GuiCom:Disable($edAuf.P.TextNr2b);
      end;
      $cb.Text1->wpCheckState # _WinStateChkChecked;
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkUnChecked;
    end
    else if (Auf.P.TextNr1=0) then begin
      if (Mode<>c_ModeView) then begin
        Lib_GuiCom:Disable($Auf.P.TextEditPos);
        Lib_GuiCom:Disable($edAuf.P.TextNr2);
        Lib_GuiCom:Enable($edAuf.P.TextNr2b);
      end;
      $cb.Text1->wpCheckState # _WinStateChkUnChecked;
      $cb.Text2->wpCheckState # _WinStateChkChecked;
      $cb.Text3->wpCheckState # _WinStateChkUnChecked;
    end;
  end;

end;


//========================================================================
//  RefreshIfm_Page3
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm_Page3(
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx         : int;
  vTxtHdl     : int;
  vArtChanged : logic;
  iTemp       : int;
  vRab1,vRab2 : float;
end;
begin

  if (Mode=c_Modeview) and (Auf.P.Nummer<>0) and (Auf.P.Nummer<1000000000) then begin
    RecLink(400,401,3,_RecFirst);  // Kopf holen
  end;

  if (aName='') then begin
    if (Auf.P.Nummer<1000000000) and (Auf.P.Nummer<>0) then begin
      $lb.Nummer3->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer4->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer5->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer6->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer7->wpcaption # AInt(Auf.P.Nummer);
    end
    else begin
      $lb.Nummer3->wpcaption # '';
      $lb.Nummer4->wpcaption # '';
      $lb.Nummer5->wpcaption # '';
      $lb.Nummer6->wpcaption # '';
      $lb.Nummer7->wpcaption # '';
    end;
    $lb.Position3->wpcaption # AInt(Auf.P.Position);
    $lb.Position4->wpcaption # AInt(Auf.P.Position);
    $lb.Position5->wpcaption # AInt(Auf.P.Position);
    $lb.Position6->wpcaption # AInt(Auf.P.Position);
    $lb.Position7->wpcaption # AInt(Auf.P.Position);
    $lb.P.Kunde3->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde4->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde5->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde6->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde7->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde8->wpcaption # Auf.KundenStichwort;
  end;

  if (aName='') or
    ((aName='edAuf.P.Skizzennummer') and ($edAuf.P.Skizzennummer->wpchanged)) then begin
    Erx # RecLink(829,401,16,_recFirst);          // Skizze holen
    if (Erx<>_rOK) then begin
      $Picture2->wpcaption # '';
    end;
    else begin
      $Picture2->wpcaption # '*'+Skz.Dateiname;
    end;
  end;


  Auf_P_Main:AufPTextLoad();


  if (aName='') or (aName='edAuf.P.Verwiegungsart') then begin
    Erx # RecLink(818,401,9,_RecFirst);
    if (Erx<=_rLocked) then
      $lb.Verwiegungsart->wpcaption # VWa.Bezeichnung.L1
    else
      $lb.Verwiegungsart->wpcaption # '';
  end;

  if (aName='') or (aName='edAuf.P.Etikettentyp') then begin
    Erx # RecLink(840,401,8,_RecFirst);
    if (Erx<=_rLocked) then begin
      $lb.Etikettentyp->wpcaption # Eti.Bezeichnung;
      $lb.Etikettentyp2->wpcaption # Eti.Bezeichnung;
    end
    else begin
      $lb.Etikettentyp->wpcaption # '';
      $lb.Etikettentyp2->wpcaption # '';
    end;
  end;
  if (aName='') or (aName='edAuf.P.Etikettentyp2') then begin
    $edAuf.P.Etikettentyp->winupdate(_WinUpdFld2Obj);
    $edAuf.P.Etikettentyp2->winupdate(_WinUpdFld2Obj);
    Erx # RecLink(840,401,8,_RecFirst);
    if (Erx>_rLocked) then RecBufClear(840);
    $lb.Etikettentyp->wpcaption # Eti.Bezeichnung;
    $lb.Etikettentyp2->wpcaption # Eti.Bezeichnung;

    $lbAuf.P.Etk.Feld.1->wpcaption # Eti.Feld.1;
    $lbAuf.P.Etk.Feld.2->wpcaption # Eti.Feld.2;
    $lbAuf.P.Etk.Feld.3->wpcaption # Eti.Feld.3;
    $lbAuf.P.Etk.Feld.4->wpcaption # Eti.Feld.4;
    $lbAuf.P.Etk.Feld.5->wpcaption # Eti.Feld.5;

  end;

//end; // nicht Kopf?

  if (aName='') then begin
    if (Auf.P.Nummer<1000000000) and (Auf.P.Nummer<>0) then begin
      $lb.Nummer0->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer1->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer1_Mat->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer2->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer2b->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer3->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer4->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer5->wpcaption # AInt(Auf.P.Nummer);
      $lb.Nummer6->wpcaption # AInt(Auf.P.Nummer);
    end
    else begin
      $lb.Nummer0->wpcaption # '';
      $lb.Nummer1->wpcaption # '';
      $lb.Nummer1_Mat->wpcaption # '';
      $lb.Nummer2->wpcaption # '';
      $lb.Nummer2b->wpcaption # '';
      $lb.Nummer3->wpcaption # '';
      $lb.Nummer4->wpcaption # '';
      $lb.Nummer5->wpcaption # '';
      $lb.Nummer6->wpcaption # '';
    end;
    $lb.Position1->wpcaption # AInt(Auf.P.Position);
    $lb.Position1_Mat->wpcaption # AInt(Auf.P.Position);
    $lb.Position2->wpcaption # AInt(Auf.P.Position);
    $lb.Position3->wpcaption # AInt(Auf.P.Position);
    $lb.Position4->wpcaption # AInt(Auf.P.Position);
    $lb.Position5->wpcaption # AInt(Auf.P.Position);
    $lb.Position6->wpcaption # AInt(Auf.P.Position);
    $lb.P.Kunde1->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde1_mat->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde2->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde3->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde4->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde5->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde6->wpcaption # Auf.P.KundenSW;
    $lb.P.Kunde7->wpcaption # Auf.P.KundenSW;
    $lb.Auf.P.Prd.Rest->wpcaption # ANum(Auf.P.Prd.Rest,Set.Stellen.Menge);
  end;

end;


//========================================================================
//  EvtDropEnter
//
//========================================================================
sub EvtDropEnter(
  aEvt                 : event;    // Ereignis
  aDataObject          : int;      // Drag-Datenobjekt
  aEffect              : int;      // Rückgabe der erlaubten Effekte
) : logic;
local begin
  vA      : alpha;
  vFile   : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    if ((vFile=200)) then begin// and (aEvt:Obj=cZListMat)) then begin
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN (true);
    end;
	end;

  RETURN false;
end;


//========================================================================
//  EvtDrop
//
//========================================================================
sub EvtDrop(
  aEvt                 : event;    // Ereignis
  aDataObject          : int;      // Drag-Datenobjekt
  aDataPlace           : int;      // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
) : logic;
local begin
  vA      : alpha;
  vFile   : int;
  vID     : int;
  vMDI    : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    if (vID=0) then RETURN false;

    if (vFile=200) then begin
      vMDI # Lib_GuiCom:FindMDI(aEvt:Obj);
      if (vMDI<>0) then begin
        WinUpdate(vMDI, _winupdactivate);
        Winfocusset(vMDI, true);
        VarInstance(WindowBonus,cnvIA(vMDI->wpcustom));
        gSelected # vID;
        w_Command # 'AusMaterial';
        App_Main:Action(c_ModeNew);
        RETURN true;
      end;
    end;
  end;

  RETURN false;
end;


//========================================================================
//  CopyRahmen2Abruf
//
//========================================================================
sub CopyRahmen2Abruf(
  aAuf  : int;
  aPos  : int;
  opt aNichtinMaske : logic);
local begin
  Erx     : int;
  vTxtHdl : int;
  vName   : alpha;
  vBuf401 : int;
  vBuf400 : int;
  vA      : alpha;
end;
begin

  if (aAuf=0) then RETURN;

  // 2022-09-13 AH : alles erst mal löschen:
  // Ausführungen leeren...
  FOR Erx # RecLink(402,401,11,_recFirst)
  LOOP Erx # RecLink(402,401,11,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(402);
    if (erx<>_rOK) then RETURN;
  END;
  if (Erx=_rDeadLock) then RETURN;
  FOR Erx # RecLink(403,401,6,_recFirst)
  LOOP Erx # RecLink(403,401,6,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(403);
    if (erx<>_rOK) then RETURN;
  END;
  if (Erx=_rDeadLock) then RETURN;
  FOR Erx # RecLink(405,401,7,_recFirst)
  LOOP Erx # RecLink(405,401,7,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(405);
    if (erx<>_rOK) then RETURN;
  END;
  if (Erx=_rDeadLock) then RETURN;

  
  vBuf401 # RekSave(401);
  vBuf400 # RekSave(400);
  Auf.Nummer      # aAuf;
  RecRead(400,1,0);

  Auf.P.Nummer    # aAuf;
  Auf.P.Position  # aPos;
  RecRead(401,1,0);

  // AI 30.05.2012
  vA # aint(vBuf400)+'|'+aint(vBuf401);
  if (aNichtInMaske) then vA # VA + '|'+'Y'
  else vA # VA + '|'+'N'
  RunAFX('Auf.P.Auswahl.Rahmen',vA);


  // Ausführungen kopieren...
  Erx # RecLink(402,401,11,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Auf.Af.Nummer   # vBuf401->Auf.P.Nummer;
    Auf.AF.Position # vBuf401->Auf.P.Position;
    RekInsert(402,0,'MAN');
    Auf.AF.Nummer   # Auf.P.Nummer;
    Auf.AF.Position # Auf.P.Position;
    RecRead(402,1,0);
    Erx # RecLink(402,401,11,_recNext);
  END;

  // Aufpreisen kopieren...
  Erx # RecLink(403,401,6,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Auf.Z.Nummer   # vBuf401->Auf.P.Nummer;
    Auf.Z.Position # vBuf401->Auf.P.Position;
    RekInsert(403,0,'MAN');
    Auf.Z.Nummer   # Auf.P.Nummer;
    Auf.Z.Position # Auf.P.Position;
    RecRead(403,1,0);
    Erx # RecLink(403,401,6,_recNext);
  END;

  // Kalkulation kopieren...
  Erx # RecLink(405,401,7,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Auf.K.Nummer   # vBuf401->Auf.P.Nummer;
    Auf.K.Position # vBuf401->Auf.P.Position;
    RekInsert(405,0,'MAN');
    Auf.K.Nummer   # Auf.P.Nummer;
    Auf.K.Position # Auf.P.Position;
    RecRead(405,1,0);
    Erx # RecLink(405,401,7,_recNext);
  END;

  // Text kopieren...
  vName # '';
  if (Auf.P.TextNr1=400) then // anderer Psoitionstext
    vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  if (Auf.P.TextNr1=401) then // Idividuell
    vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  if (vName<>'') and (aNichtInMaske=false) then begin
    vTxtHdl # $Auf.P.TextEditPos->wpdbTextBuf;
    Erx # TextRead(vTxtHdl, vName , 0);
    $Auf.P.TextEditPos->wpcustom # myTmpText+'.401.'+CnvAI(vBuf401->Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    $Auf.P.TextEditPos->WinUpdate(_WinUpdBuf2Obj);

    // ST 2012-08-10: Projekt 1332/66
    //  Vorbelegung/Kopie als indi. Text, da AufPosition zu Auf.P.TextNr2 noch nicht abgerufen sein kann.
    Auf.P.TextNr1 # 401;
    Auf.P.TextNr2 # 0;
  end;
  // Internen Text umkopieren
  TxtCopy('~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero| _FmtNumNogroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero| _FmtNumNogroup,0,3)+'.01',myTmpText+ '.401.'+CnvAI(vBuf401->Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01',0);

  // Kopf anpassen...
  Auf.Nummer            # vBuf400->Auf.Nummer;
  Auf.Datum             # vBuf400->Auf.Datum;
  Auf.Vorgangstyp       # vBuf400->Auf.Vorgangstyp;
  Auf.LiefervertragYN   # vBuf400->Auf.LiefervertragYN;
  Auf.AbrufYN           # vBuf400->Auf.AbrufYN;
  Auf.PAbrufYN          # vBuf400->Auf.PAbrufYN;
  "Auf.GültigkeitVom"   # vBuf400->"Auf.GültigkeitVom";
  "Auf.GültigkeitBis"   # vBuf400->"Auf.GültigkeitBis";
  Auf.Kundennr          # vBuf400->Auf.Kundennr;
  Auf.KundenStichwort   # vBuf400->Auf.Kundenstichwort;

// 12.10.2016 AH s.u.  if (vBuf400->Auf.Best.Nummer<>'') then
// 12.10.2016 AH s.u.   Auf.Best.Nummer       # vBuf400->Auf.Best.Nummer;
  // 17.01.2018 AH:
  if (vBuf400->Auf.Best.Nummer<>'') then
    Auf.Best.Nummer     # vBuf400->Auf.Best.Nummer;

  Auf.Best.Datum        # vBuf400->Auf.Best.Datum;
  Auf.Best.Bearbeiter   # vBuf400->Auf.Best.Bearbeiter;

  // 17.01.2018 AH:
  if (vBuf400->Auf.Best.Nummer<>'') then
    Auf.P.Best.Nummer   # vBuf400->Auf.Best.Nummer;

  RecBufDestroy(vBuf400);

  if (aNichtInMaske=false) then
      Lib_MoreBufs:RecInit(401, y, y);

  // Position anpassen...
  Auf.P.Nummer      # vBuf401->Auf.P.Nummer;
  Auf.P.Position    # vBuf401->Auf.P.Position;
// 12.10.2016 s.u.  if (vBuf401->Auf.P.Best.Nummer<>'') then
// 12.10.2016    Auf.P.Best.Nummer # vBuf401->Auf.P.Best.Nummer;
  Auf.P.Gewicht     # Auf.P.Prd.Rest.Gew;
  "Auf.P.Stückzahl" # Auf.P.Prd.Rest.Stk;
  if (Auf.P.MEH.Einsatz='kg') then Auf.P.Menge # Rnd(Auf.P.Gewicht,Set.Stellen.Menge);
  else if (Auf.P.MEH.Einsatz='Stk') then Auf.P.Menge # cnvfi("Auf.P.Stückzahl")
  else  Auf.P.Menge # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, 0.0, '', Auf.P.MEH.Einsatz);
  RecBufDestroy(vBuf401);

  // 12.10.2016:
  // 17.01.2018 Auf.P.Best.Nummer # Auf.Best.Nummer;

  Auf.P.AbrufAufNr        # aAuf;
  Auf.P.AbrufAufPos       # aPos;
  Auf.P.Prd.Reserv      # 0.0;
  Auf.P.Prd.Reserv.Gew  # 0.0;
  Auf.P.Prd.Reserv.Stk  # 0;
  Auf.P.Prd.Plan          # 0.0;
  Auf.P.Prd.Plan.Stk      # 0;
  Auf.P.Prd.Plan.Gew      # 0.0;
  Auf.P.Prd.VSB           # 0.0;
  Auf.P.Prd.VSB.Stk       # 0;
  Auf.P.Prd.VSB.Gew       # 0.0;
  Auf.P.Prd.VSAuf         # 0.0;
  Auf.P.Prd.VSAuf.Stk     # 0;
  Auf.P.Prd.VSAuf.Gew     # 0.0;
  Auf.P.Prd.LFS           # 0.0;
  Auf.P.Prd.LFS.Stk       # 0;
  Auf.P.Prd.LFS.Gew       # 0.0;
  Auf.P.Prd.Rech          # 0.0;
  Auf.P.Prd.Rech.Stk      # 0;
  Auf.P.Prd.Rech.Gew      # 0.0;
  Auf.P.Prd.zuBere        # 0.0;
  Auf.P.Prd.zuBere.Stk    # 0;
  Auf.P.Prd.zuBere.Gew    # 0.0;
  Auf.P.GPL.Plan          # 0.0;
  Auf.P.GPL.Plan.Stk      # 0;
  Auf.P.GPL.Plan.Gew      # 0.0;
end;

//========================================================================