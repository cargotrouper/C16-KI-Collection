@A+
//===== Business-Control =================================================
//
//  Prozedur    Ein_P_SMain
//                    OHNE E_R_G
//  Info
//
//
//  18.05.2005  AI  Erstellung der Prozedur
//  10.05.2012  AI  BUG: Übernahme der Wunschmengen aus Kommission Prj.1371/103
//  21.12.2012  AI  Kommission prüft auf Rahmenvertrag (Projekt 1327/324)
//  16.10.2013  AH  Anfragen
//  06.02.2015  AH  Art.AbmessString Übernnahme
//  11.02.2015  AH  Bugfix: ArtMix : Mengen aus Kommission
//  09.07.2015  AH  Fix: Lifervertag oder Rahmen kann nicht im Nachhinein geändert werden
//  24.07.2015  AH  Neu: Artikelgruppe von Artikel anzeigen
//  07.04.2016  AH  Neu: Drag&Drop von Material
//  27.10.2016  AH  Kommissionsdaten werden nur bei Neuanlage übernommen
//  28.11.2017  AH  Fix: Text bei Artikel
//  26.01.2018  AH  AnalyseErweitert
//  24.02.2022  AH  ERX, Art.Ausführungen
//  2022-07-18  AH  Fix: Lieferant im Kopf ändern, refreshed alle Positionen
//  2023-02-07  AH  Ein.Verband
//
//  Subprozeduren
//    SUB Switchmask(aMitFocus : logic) : logic;
//    SUB GetArtikel();
//    SUB GetArtikel_Mat();
//    SUB RefreshIfm_Kopf(optaName : alpha; optaChanged : logic)
//    SUB RefreshIfm_Page1_Art(optaName : alpha; optaChanged : logic)
//    SUB RefreshIfm_Page1_Mat(optaName : alpha; optaChanged : logic)
//    SUB RefreshIfm_Page2(optaName : alpha; optaChanged : logic)
//    SUB RefreshIfm_Page3(optaName : alpha; optaChanged : logic)
//    SUB EvtDropEnter(...
//    SUB EvtDrop(...
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
  cTitle :    'Bestellpositionen'
  cFile :     501
  cMenuName : 'Ein.P.Bearbeiten'
  cPrefix :   'Ein_P'
  cZList :    $ZL.EKPositionen
  cKey :      1
end;

declare RefreshIfm_Page1_Art(opt aName : alpha; opt aChanged : logic)

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
  if (StrFind(gMDI->wpname,'Ein.',0)=0) then RETURN false;

  // Materialtyp unterscheiden...
  if (mode=c_ModeEdit) or (Mode=c_modeNew) then begin
    Erx # RecLink(819,501,1,0);   // Warengruppe holen
    if (Erx>_rLocked) then RecBufClear(819);
    if (Wgr_Data:WertBlockenBeiTyp(501, 'RID')) then begin
      Lib_GuiCom:Disable($edEin.P.RID_Mat);
      Lib_GuiCom:Disable($edEin.P.RIDMax_Mat);
    end;
    if (Wgr_Data:WertBlockenBeiTyp(501, 'RAD')) then begin
      Lib_GuiCom:Disable($edEin.P.RAD_Mat);
      Lib_GuiCom:Disable($edEin.P.RADMax_Mat);
    end;
    if (Wgr_Data:WertBlockenBeiTyp(501, 'D')) then begin
      Lib_GuiCom:Disable($edEin.P.Dicke_Mat);
      Lib_GuiCom:Disable($edEin.P.Dickentol_Mat);
    end;
    if (Wgr_Data:WertBlockenBeiTyp(501, 'B')) then begin
      Lib_GuiCom:Disable($edEin.P.Breite_Mat);
      Lib_GuiCom:Disable($edEin.P.Breitentol_Mat);
    end;
    if (Wgr_Data:WertBlockenBeiTyp(501, 'L')) then begin
      Lib_GuiCom:Disable($edEin.P.Laenge_Mat);
      Lib_GuiCom:Disable($edEin.P.Laengentol_Mat);
    end;
  end;

  gMdi->wpautoupdate # false;
  vCurrent # $NB.Main->wpcurrent;

  if (Ein.P.Wgr.Dateinr=0) then
    Ein.P.Wgr.Dateinr # Set.Ein.Dateinr;

  if (Wgr_Data:IstMixMat(Ein.P.Wgr.Dateinr)) then begin
    $lbEin.P.Artikelnr_Mat->wpcaption # Translate('Artikelnr.');
    $edEin.P.Artikelnr_Mat->wpLengthMax # 32;
    $lb.EH_Mat->wpvisible         # (Ein.P.MEH<>'Stk') and (Ein.P.MEH<>'kg');  // 20.07.2021 AH: Menge editierbar
    $lbEin.P.Menge_Mat->wpvisible # (Ein.P.MEH<>'Stk') and (Ein.P.MEH<>'kg');
    $edEin.P.Menge_Mat->wpvisible # (Ein.P.MEH<>'Stk') and (Ein.P.MEH<>'kg');
  end
  else begin
    $lbEin.P.Artikelnr_Mat->wpcaption # Translate('Strukturnr.');
    $edEin.P.Artikelnr_Mat->wpLengthMax # 20;
    $lb.EH_Mat->wpvisible         # false;    // 20.07.2021 AH: Menge editierbar
    $lbEin.P.Menge_Mat->wpvisible # false;
    $edEin.P.Menge_Mat->wpvisible # false;
    
  end;

  if ((Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMixMat(Ein.P.Wgr.Dateinr))) then vWohin # 'MAT'
  else vWohin # 'ART';

  // zu Matmaske wechseln??
  if (vWohin='MAT') and ($NB.Page1->wpcustom<>'NB.Page1_Mat') then begin
    $NB.Main->wpautoupdate    # n;
    $NB.Page1->wpname         # 'NB.Page1_Art';
    $NB.Page1_Mat->wpvisible  # y;
    $NB.Page1_Mat->wpdisabled # (mode=c_modeNew);
    $NB.Page1_Mat->wpname     # 'NB.Page1';
    //if (aMitFocus) then $NB.Main->wpcurrent # 'NB.Page1';
    $NB.Page1->wpvisible  # n;
    $NB.Page1->wpdisabled # y;

    $Nb.Page3->wpvisible  # Y;
    $Nb.Page3->wpdisabled # (mode=c_modeNew);
    $Nb.Page4->wpvisible  # y;
    $Nb.Page4->wpdisabled # (mode=c_modenew);
    Ein.P.MEH.Wunsch  # 'kg';

    $NB.Main->wpautoupdate    # y;
    if (vCurrent<>'NB.List') then $NB.Main->wpcurrent # vCurrent;
    RETURN true;
  end;

  // in Artmakse Wechseln?
  if (vWohin='ART') and ($NB.Page1->wpcustom<>'NB.Page1_Art') then begin
    $NB.Main->wpautoupdate    # n;

    $NB.Page1->wpname         # 'NB.Page1_Mat';
    $NB.Page1_Art->wpvisible  # y;
    $NB.Page1_Art->wpdisabled # (mode=c_modenew); // WAR "N" - wie oben!
    $NB.Page1_Art->wpname     # 'NB.Page1';
    //if (aMitFocus) then $NB.Main->wpcurrent       # 'NB.Page1';
    $NB.Page1->wpvisible  # n;
    $NB.Page1->wpdisabled # y;
    $Nb.Page3->wpvisible  # n;
    $Nb.Page3->wpdisabled # y;
    $Nb.Page4->wpvisible  # n;
    $Nb.Page4->wpdisabled # y;

    $NB.Main->wpautoupdate    # y;
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
  Erx     : int;
  vTxtHdl : int;
  vName   : alpha;
end;
begin

  if (RunAFX('Ein.P.GetArtikel_Mat','')<0) then RETURN;

  Erx # RecLink(250,501,2,_recfirst);   // Artikel holen
  if (Erx>_rLocked) then RETURN;

  // Feldübernahme
  Ein.P.ArtikelSW     # Art.Stichwort;
//  Ein.P.ArtikelTyp    # Art.Typ;
  Ein.P.Sachnummer    # Art.Sachnummer;
  Ein.P.Dicke         # Art.Dicke;
  Ein.P.Breite        # Art.Breite;
  "Ein.P.Länge"       # "Art.Länge";
  Ein.P.Dickentol     # Art.Dickentol;
  Ein.P.Breitentol    # Art.Breitentol;
  "Ein.P.Längentol"   # "Art.Längentol";
  Ein.P.RID           # Art.Innendmesser;
  Ein.P.RAD           # Art.Aussendmesser;
  Ein.P.Intrastatnr   # Art.Intrastatnr;
  Ein.P.AbmessString  # Art.AbmessungString;
  Ein.P.Warengruppe # Art.Warengruppe;    // 04.12.2014

  Ein.P.Menge.Wunsch  # 0.0;
//  Ein.P.MEH.Einsatz   # Art.MEH;
  Ein.P.MEH.Wunsch    # Art.MEH;
  Ein.P.MEH.Preis     # Art.MEH;
  Ein.P.Menge         # 0.0;
  Ein.P.PEH           # Art.PEH;
  "Ein.P.Güte"        # "Art.Güte";
  Ein.P.Werkstoffnr   # Art.Werkstoffnr;

  $edEin.P.Artikelnr_Mat->wpcaption # Ein.P.Artikelnr;

  RecLink(819,250,10,_recfirst);    // Warengruppe holen
  Ein.P.Warengruppe   # Wgr.Nummer;
  Ein_Data:SetWgrDateinr(Wgr.Dateinummer);

  // Text übernehmen...
  Ein.P.TextNr1 # 501;
  Ein.P.TextNr2 # 0;
  vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
  if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
    vName # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
  else
    vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
// 27.03.2018 AH: immer in LFSPRACHE Lib_Texte:TxtLoadLangBuf('~250.EK.'+CnvAI(ART.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, gUserSprache);
  Lib_Texte:TxtLoadLangBuf('~250.EK.'+CnvAI(ART.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, Ein.Sprache);
  $Ein.P.TextEdit1->wpcustom # vName;
  $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);


  // Ausführugen löschen & kopieren aus Artikel
  WHILE (RecLink(502,501,12,_recFirst)=_rOK) do
    RekDelete(502,0,'MAN');

  if ("Art.Oberfläche"<>0) then begin
    RecBufClear(502);
    Ein.AF.Nummer   # Ein.P.Nummer;
    Ein.AF.Position # Ein.P.Position;
    Ein.AF.Seite    # '1';
    Ein.AF.lfdNr    # 1;
    Ein.AF.ObfNr    # "Art.Oberfläche";

    Erx # RecLink(841,502,1,0); // OBerfläche holen
    if (Erx<=_rLocked) then begin
      Ein.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "Ein.AF.Kürzel"     # "Obf.Kürzel";
      RekInsert(502,0,'AUTO');
      Ein.P.Ausfoben # "Ein.AF.Bezeichnung"+ Ein.AF.Zusatz;;
    end;
  end;

  // Ausführungen kopieren
  FOR Erx # RecLink(257,250,27,_recFirst)
  LOOP Erx # RecLink(257,250,27,_recNext)
  WHILE (Erx<=_rLocked) do begin
    Ein.AF.Nummer         # Ein.P.Nummer;
    Ein.AF.Position       # Ein.P.Position;
    Ein.AF.Seite          # Art.AF.Seite;
    Ein.AF.lfdNr          # Art.AF.lfdNr;
    Ein.AF.ObfNr          # Art.AF.ObfNr;
    ein.AF.Bezeichnung    # Art.AF.Bezeichnung;
    Ein.AF.Zusatz         # Art.AF.Zusatz;
    Ein.AF.Bemerkung      # Art.AF.Bemerkung;
    "Ein.AF.Kürzel"       # "Art.AF.Kürzel";
    RekInsert(502,0,'AUTO');
    Ein.P.AusfOben        # "Art.AusführungOben";
    Ein.P.AusfUnten       # "Art.AusführungUnten";
  END;

  RecLink(100,500,1,_RecFirst);             // Lieferant holen
  if (Art_P_Data:FindePreis('EK', Adr.Nummer, 1.0, '', 1)) then begin
    Ein.P.MEH.Preis      # Art.P.MEH;
    Ein.P.PEH            # Art.P.PEH;
    Ein.P.Grundpreis     # Art.P.PreisW1;
  end;

//  $edEin.P.GrundPreis->Winupdate(_WinUpdFld2Obj);
//  $edEin.P.Artikelnr_Mat->wpcaption # Ein.P.Artikelnr;
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
  if (RunAFX('Ein.P.GetArtikel','')<0) then RETURN;

  Ein.P.Sachnummer # '';
  Ein.P.ArtikelSW # '';

  Erx # RecLink(250,501,2,_recfirst);   // Artikel holen
  if (Erx>_rLocked) then RETURN;

  Ein.P.Artikelnr   # Art.Nummer;           // Felder f_llen
  Ein.P.ArtikelSW   # Art.Stichwort;

  Ein.P.Dicke       # Art.Dicke;
  Ein.P.Breite      # Art.Breite;
  "Ein.P.Länge"     # "Art.Länge";
  Ein.P.Dickentol   # Art.Dickentol;
  Ein.P.Breitentol  # Art.Breitentol;
  "Ein.P.Längentol" # "Art.Längentol";
  Ein.P.RID         # Art.Innendmesser;
  Ein.P.RAD         # Art.Aussendmesser;
  Ein.P.Sachnummer  # Art.Sachnummer;
  Ein.P.Intrastatnr   # Art.Intrastatnr;
  Ein.P.MEH           # Art.MEH;
  Ein.P.MEH.Wunsch    # Ein.P.MEH;
  Ein.P.MEH.Preis     # Art.MEH;
  Ein.P.PEH           # Art.PEH;
  Ein.P.AbmessString  # Art.Abmessungstring;
  "Ein.P.Güte"        # "Art.Güte";
  Ein.P.Werkstoffnr   # Art.Werkstoffnr;

/** s.u.
  Art.P.ArtikelNr     # Art.Nummer;
  Art.P.AdrStichwort  # Adr.Stichwort;
  Erx # RecRead(254,2,0);
  if (Erx <= _rMultikey) then                    // Schlüssel ist wegen Staffelung der Preise nicht
    Ein.P.LieferArtNr # Art.P.AdressArtNr;       // eindeutig, LieferArtNr sollte jedoch in einer
  else                                           // Staffelung gleich sein.
    Ein.P.LieferArtNr # '';
***/
  RecLink(819,250,10,_recfirst);    // Warengruppe holen
  Ein.P.Warengruppe   # Wgr.Nummer;
  Ein_Data:SetWgrDateinr(Wgr.Dateinummer);
  gMDI->winupdate(_WinUpdFld2Obj);
  $edEin.P.Warengruppe->winupdate(_WinUpdFld2Obj);
  Refreshifm_Page1_Art('edEin.P.Warengruppe',y);

  Ein.P.PEH         # Art.PEH;
  Ein.P.MEH.Preis   # Art.MEH;
  RecLink(100,500,1,_RecFirst);             // Lieferant holen
  Ein.P.LieferArtNr # '';
  if (Art_P_Data:FindePreis('EK', Adr.Nummer, 1.0, '', 1)) then begin
    Ein.P.MEH.Preis       # Art.P.MEH;
    Ein.P.PEH             # Art.P.PEH;
    Ein.P.Grundpreis      # Art.P.PreisW1;
    Ein.P.LieferArtNr     # Art.P.AdressArtNr;
  end;
//  Ein.P.MEH.Einsatz   # Art.MEH;
//  Ein.P.MEH.Wunsch    # Ein.P.MEH.Einsatz;

//  $edEin.P.GrundPreis->Winupdate(_WinUpdFld2Obj);
//  $edEin.P.PEH->Winupdate(_WinUpdFld2Obj);
//  $edEin.P.MEH.Preis->Winupdate(_WinUpdFld2Obj);

//  Ein_K_Data:Sync2Pos();
//  Ein_K_Data:SumKalkulation();
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
  vAllesGeht  : logic;
  v501        : int;
end;
begin

  if (aName='') and (Mode<>c_Modeview) then begin
    vAllesGeht # ((Ein.Vorgangstyp=c_Bestellung) and ((Mode=c_ModeNew) or ((Mode=c_ModeNew2) and (Ein.P.Position=1))));
    Lib_GuiCom:Able($edEin.GltigkeitVom, Ein.LiefervertragYN or (Ein.Vorgangstyp=c_Anfrage));
    Lib_GuiCom:Able($edEin.GltigkeitBis, Ein.LiefervertragYN or (Ein.Vorgangstyp=c_Anfrage));
    Lib_GuiCom:Able($cbEin.AbrufYN, vAllesGeht);
    Lib_GuiCom:Able($cbEin.LiefervertragYN, (vAllesGeht) or (Ein.Vorgangstyp=c_Anfrage));
  end;

  if (aName='edEin.Vorgangstyp') then begin
    if (($edEin.Vorgangstyp->wpchanged) or (aChanged)) and
      (Ein.Vorgangstyp=c_Anfrage) then begin
      Ein.LiefervertragYN # n;
      Ein.AbrufYN         # n;
      $cbEin.AbrufYN->winupdate(_WinUpdFld2Obj);
      $cbEin.LiefervertragYN->winupdate(_WinUpdFld2Obj);
    end;
  end;


  if (aName='') or ((aName='edEin.Lieferantennr') and
    (($edEin.Lieferantennr->wpchanged) or (aChanged) )) then begin

    Erx # RecLink(100,500,1,0);
    if (Erx<=_rLocked) and (Ein.Lieferantennr<>0) then begin
      $Lb.Lieferant1->wpcaption # Adr.Stichwort+', '+Adr.LKZ+', '+Adr.Ort;
      $Lb.Lieferant2->wpcaption # Adr.Name+', '+"Adr.Straße";
      if (aName<>'') then begin
        Ein.LieferantenSW     # Adr.Stichwort;
        Ein.P.Lieferantennr   # Ein.Lieferantennr;
        Ein.P.LieferantenSW   # Ein.LieferantenSW;
        Ein.P.Erzeuger        # Adr.Nummer;
        Ein.P.Verwiegungsart  # Adr.EK.Verwiegeart;
        // Ein.Lieferadresse # Adr.Nummer;
        // Ein.LieferAnschrift # 1;
        //Ein.RechnungsEmpf # Ein.Lieferantennr;
        "Ein.Währung"         # "Adr.EK.Währung";
        Ein.Lieferbed         # Adr.EK.Lieferbed;
        Ein.Zahlungsbed       # Adr.EK.ZAhlungsbed;
        Ein.Versandart        # Adr.EK.Versandart;
        Ein.Sprache           # Adr.Sprache;
        Ein.AbmessungsEH      # Adr.AbmessungEH;
        Ein.GewichtsEH        # Adr.GewichtEH;
        "Ein.Steuerschlüssel" # "Adr.Steuerschlüssel";

        if (Set.Ein.Lieferadress=-1) then begin
          Erx # RecLink(100,500,1,_recfirst);   // Lieferant holen
          if (Erx<=_rLocked) and (Ein.Lieferantennr<>0) then begin
            Ein.Lieferadresse   # Adr.Nummer;
            Ein.Lieferanschrift # Set.Ein.Lieferanschr;
          end;
        end;

        // 2022-07-18 AH    vorhandene Sätze anpassen
        v501 # RekSave(501);
        FOR Erx # RecLink(501,500,9,_recFirst)
        LOOP Erx # RecLink(501,500,9,_recNext)
        WHILE (Erx<=_rLocked) do begin
          Erx # RecRead(501,1,_recLock);
          Ein.P.Lieferantennr   # Ein.Lieferantennr;
          Ein.P.LieferantenSW   # Ein.LieferantenSW;
          Ein.P.Erzeuger        # Adr.Nummer;
          Ein.P.Verwiegungsart  # Adr.EK.Verwiegeart;
          Erx # Rekreplace(501);
        END;
        RekRestore(v501);
        RecRead(501,1,_recLock|_recNoLoad);

      end;
    end
    else begin
      $Lb.Lieferant1->wpcaption # '';
      $Lb.Lieferant2->wpcaption # '';
      Ein.LieferantenSW # '';
    end;
    Ein_P_Main:RefreshIfm('edEin.Lieferadresse');
    Ein_P_Main:RefreshIfm('edEin.Lieferanschrift');
    Ein_P_Main:RefreshIfm('edEin.Rechnungsempf');
    Ein_P_Main:RefreshIfm('edEin.Waehrung');
    Ein_P_Main:RefreshIfm('edEin.Lieferbed');
    Ein_P_Main:RefreshIfm('edEin.Zahlungsbed');
    Ein_P_Main:RefreshIfm('edEin.Versandart');
    Ein_P_Main:RefreshIfm('edEin.Sprache');
    Ein_P_Main:RefreshIfm('edEin.AbmessungsEH');
    Ein_P_Main:RefreshIfm('edEin.GewichtsEH');

    Ein_P_Main:RefreshIfm('edEin.Steuerschluessel');

    // Ankerfunktion?
    if (Ein.LieferantenSW<>'') then begin
      RunAFX('Ein.P.Auswahl.Lief','');
    end;

/***
    if (Adr.Lieferantennr<>0) and (Adr.SperrLieferantYN) and (Mode<>c_ModeView) then begin
      $edEin.Lieferantennr->WinUpdate(_WinUpdFld2Obj);
      Msg(100006,'',0,0,0);
    end;
***/
  end;

  if (aName='') or (aName='edEin.Lieferadresse') or (aName='edEin.Lieferanschrift') then begin
    Erx # RecLink(101,500,2,0);
    if (Erx<=_rLocked) and (Ein.Lieferadresse<>0) then begin
      $Lb.Lieferadresse1->wpcaption # Adr.A.Stichwort+', '+Adr.A.LKZ+', '+Adr.A.Ort;
      $Lb.Lieferadresse2->wpcaption # Adr.A.Name+', '+"Adr.A.Straße";
    end
    else begin
      $Lb.Lieferadresse1->wpcaption # '';
      $Lb.Lieferadresse2->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edEin.Verbraucher') then begin
    Erx # RecLink(100,500,3,0);
    if (Erx<=_rLocked) and (Ein.Verbraucher<>0) then begin
      $Lb.Verbraucher->wpcaption # Adr.Stichwort+', '+Adr.LKZ+', '+Adr.Ort;
    end
    else begin
      $Lb.Verbraucher->wpcaption # '';
    end;
  end;


  if (aName='') or (aName='edEin.Rechnungsempf') then begin
    Erx # RecLink(100,500,4,_recfirst);     // Rechnungsempfänger holen
    if (Erx<=_rLocked) and (Ein.Rechnungsempf<>0) then begin
      $Lb.RechEmpf->wpcaption # Adr.Stichwort+', '+Adr.LKZ+', '+Adr.Ort;
    end
    else begin
      $Lb.RechEmpf->wpcaption # '';
    end;

  end;


  if (aName='') or (aName='edEin.Rechnungsempf')
  and (($edEin.Rechnungsempf->wpchanged) or (aChanged)) then begin

    Erx # RecLink(100,500,4,0);
    if (Erx>=_rLocked) then begin
    "Ein.Steuerschlüssel" # "Adr.Steuerschlüssel";
    Ein_P_Main:RefreshIfm('edEin.Steuerschluessel');
    end;

  end;

  if (aName='') or (aName='edEin.BDSNummer') then begin
    Erx # RecLink(836,500,11,0);
    if (Erx<=_rLocked) then
      $Lb.BDS->wpcaption # BDS.Bezeichnung
    else
      $Lb.BDS->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.Land') then begin
    Erx # RecLink(812,500,10,0);    // Land holen
    if (Erx<=_rLocked) then
      $Lb.Land->wpcaption # Lnd.Name.L1
    else
      $Lb.Land->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.Waehrung') then begin
    Erx # RecLink(814,500,8,0);
    if (Erx<=_rLocked) then
      $Lb.Waehrung->wpcaption # Wae.Bezeichnung
    else
      $Lb.Waehrung->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.Lieferbed') then begin
    Erx # RecLink(815,500,5,0);
    if (Erx<=_rLocked) then
      $Lb.Lieferbed->wpcaption # LIb.Bezeichnung.L1
    else
      $Lb.Lieferbed->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.Zahlungsbed') then begin
    Erx # RecLink(816,500,6,0);
    if (Erx<=_rLocked) then
      $Lb.Zahlungsbed->wpcaption # ZaB.Kurzbezeichnung
    else
      $Lb.Zahlungsbed->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.Versandart') then begin
    Erx # RecLink(817,500,7,0);   // Versandart holen
    if (Erx<=_rLocked) then
      $lb.Versandart->wpcaption # VsA.Bezeichnung.L1
    else
      $lb.Versandart->wpcaption # '';
  end;

   if (aName='') or (aName='edEin.Steuerschluessel') then begin
    Erx # RecLink(813,500,17,0);    //Steuerschlüssel  holen
    if (Erx<=_rLocked) then
      $Lb.Steuerschluessel->wpcaption # StS.Bezeichnung
    else
      $Lb.Steuerschluessel->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.Verband') then begin
    Erx # RecLink(110,500,20,_RecFirst);
    if (Erx<=_rLocked) and (Ein.Verband<>0) then
      $Lb.Verband->wpcaption # Ver.Stichwort
    else
      $Lb.Verband->wpcaption # '';
  end;

end;

/***
//========================================================================
// RefreshArtikel
//
//========================================================================
Sub RefreshArtikel();
begin
  Ein.P.Sachnummer # '';
  Ein.P.ArtikelSW # '';
  Art.Nummer # Ein.p.Artikelnr;//$edEin.P.Artikelnr->wpcaption; // Verkn_pfung arbeitet nur _ber Art.ID
  Erx # RecRead(250,1,0);                     // daher manuell lesen.
  if (Erx <= _rLocked) then begin             // Stichw. etc. aktualisieren
    Ein.P.Artikelnr   # Art.Nummer;           // Felder f_llen
    Ein.P.ArtikelSW   # Art.Stichwort;

    Ein.P.Dicke       # Art.Dicke;
    Ein.P.Breite      # Art.Breite;
    "Ein.P.Länge"     # "Art.Länge";
    Ein.P.RID         # Art.Innendmesser;
    Ein.P.RAD         # Art.Aussendmesser;
    Ein.P.Sachnummer  # Art.Sachnummer;
    Ein.P.Intrastatnr   # Art.Intrastatnr;
    Ein.P.MEH           # Art.MEH;
    Ein.P.MEH.Wunsch    # Ein.P.MEH;
    Ein.P.MEH.Preis     # Art.MEH;
    Ein.P.PEH           # Art.PEH;
    Ein.P.AbmessString  # Art.Abmessungstring;

    Art.P.ArtikelNr     # Art.Nummer;
    Art.P.AdrStichwort  # Adr.Stichwort;
    Erx # RecRead(254,2,0);
    if (Erx <= _rMultikey) then                    // Schl_ssel ist wegen Staffelung der Preise nicht
      Ein.P.LieferArtNr # Art.P.AdressArtNr;       // eindeutig, LieferArtNr sollte jedoch in einer
    else                                           // Staffelung gleich sein.
      Ein.P.LieferArtNr # '';

    // 24.04.2015...
    RecLink(819,250,10,_recfirst);    // Warengruppe holen
    Ein.P.Warengruppe   # Wgr.Nummer;
    Ein_Data:SetWgrDateinr(Wgr.Dateinummer);
    gMDI->winupdate(_WinUpdFld2Obj);  // 05.05.2015
    $edEin.P.Warengruppe->winupdate(_WinUpdFld2Obj);
    Refreshifm_Page1_Art('edEin.P.Warengruppe',y);
  end;
end;
***/

//========================================================================
//  RefreshIfm_Page1_Art
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm_Page1_Art(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx           : int;
  vArtChanged   : logic;
  vA            : alpha;
  vTxtHdl       : int;
  vName         : alpha;
  vName2        : alpha;
  vI            : int;
end;
begin

  if (aName='') then begin
    Erx # RecLink(814,500,8,0);
    if (Erx<=_rLocked) then begin
      $lb.WAE1->wpcaption # "Wae.Kürzel";
      $lb.WAE2->wpcaption # "Wae.Kürzel";
      $lb.WAE3->wpcaption # "Wae.Kürzel";
      $lb.WAE4->wpcaption # "Wae.Kürzel";
    end
    else begin
      $lb.WAE1->wpcaption # '???';
      $lb.WAE2->wpcaption # '???';
      $lb.WAE3->wpcaption # '???';
      $lb.WAE4->wpcaption # '???';
    end;
    if (RecLinkInfo(505,501,8,_RecCount)=0) then begin
      $cb.Kalkulation_Art->wpCheckState # _WinStateChkUnChecked;
    end
    else begin
      $cb.Kalkulation_Art->wpCheckState # _WinStateChkChecked;
    end;
  end;


  if (aName='') then begin
    $RL.Aufpreise->winupdate(_winupdon,_WinLstFromFirst);
    $lb.Aufpreise->wpcaption # ANum(Ein.P.Aufpreis,2);
  end;

  if ((aName='') or (aName='edEin.P.Warengruppe')) then begin
    Erx # RecLink(819,501,1,0);   // Warengruppe holen
    if (Erx<=_rlocked) then begin
      if (mode=c_modenew) or (mode=c_Modenew2) then Ein_Data:SetWgrDateinr(Wgr.Dateinummer);
      $lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1;
    end
    else begin
      $lb.Warengruppe->wpcaption # '???';
      Ein.P.Wgr.Dateinr # Set.Ein.Dateinr;    // 2023-04-25 AH war 0;
    end;
    if (Erx>_rLocked) then RecBufClear(819);
  end;

  if (aName='') or (aName='edEin.P.Auftragsart') then begin
    Erx # RecLink(835,501,5,0);
    if (Erx<=_rLocked) then
      $lb.AuftragsArt->wpcaption # AAr.Bezeichnung
    else
      $lb.AuftragsArt->wpcaption # '';
  end;

  vArtChanged # n;

  // Anzeige des richtigen Kunden der Kommission [PW/05.08.09]
  if ( aName = '' or aName = 'edEin.P.Kommission' ) then begin
    if ( Ein.P.Kommissionnr != 0 and RecLink( 401, 501, 18, _recFirst ) = _rOk ) then
      $lb.Kommi->wpCaption # Auf.P.KundenSW;
    else
      $lb.Kommi->wpCaption # '';
  end;

  // Auftrag in Einkauf kopieren?
  if (aName='edEin.P.Kommission') and
    (($edEin.P.Kommission->wpchanged) or (aChanged)) then begin
    vA # Str_Token(Ein.P.Kommission,'/',1);
    Ein.P.Kommissionnr  # Cnvia(vA);
    vA # Str_Token(Ein.P.Kommission,'/',2);
    Ein.P.Kommissionpos # Cnvia(vA);
    Erx # RecLink(401,501,18,_RecFirst);
    if (Erx<>_rOK) then begin
      Ein.P.Kommissionnr  # 0;
      Ein.P.Kommissionpos # 0;
      Ein.P.Kommission    # '';
      Ein.P.KommiKunde    # 0;
      $lb.Kommi->wpcaption  # '';
      RETURN;
    end;
    $lb.Kommi->wpcaption  # Auf.P.kundenSW;
    Ein.P.Kommissionnr  # Auf.P.Nummer;
    Ein.P.Kommissionpos # Auf.P.Position;
    Ein.P.Kommission # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position)
    Ein.P.KommiKunde    # Auf.P.Kundennr;
    // Sonderfunktion:
    if (aChanged) then vA # '1|' + aName;
    else vA # '0|' + aName;
    if (RunAFX('Ein.P.Auswahl.Kommission',vA)<0) then begin
      RETURN;
    end;

    // 27.10.2016 AH: nur bei Anlage
    if (Mode=c_ModeNew2) or (Mode=c_ModeEdit2) then begin
      Ein.P.Artikelnr     # Auf.P.Artikelnr;
      Ein.P.ArtikelSW     # Auf.P.ArtikelSW;
      Ein.P.Sachnummer    # Auf.P.Sachnummer;
      //RefreshArtikel();
      GetArtikel();

      "Ein.P.Güte"        # "Auf.P.Güte";
      "Ein.P.Gütenstufe"  # "Auf.P.Gütenstufe";
      Ein.P.Werkstoffnr   # Auf.P.Werkstoffnr;
      Ein.P.AusfOben      # Auf.P.AusfOben;
      Ein.P.AusfUnten     # Auf.P.AusfUnten;
      // bisherige Ausführung löschen
      WHILE (RecLink(502,501,12,_recFirst)<=_rLocked) do begin
        Erx # RekDelete(502,0,'MAN');
        if (Erx<>_rOK) then BREAK;
      END;
      // Ausführung kopieren
      Erx # RecLink(402,401,11,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        Ein.AF.Nummer       # Ein.P.Nummer;
        Ein.AF.Position     # Ein.P.Position;
        Ein.AF.Seite        # Auf.AF.Seite;
        Ein.AF.lfdNr        # Auf.AF.lfdNr;
        Ein.AF.ObfNr        # Auf.AF.ObfNr;
        Ein.AF.Bezeichnung  # Auf.AF.Bezeichnung;
        Ein.AF.Zusatz       # Auf.AF.Zusatz;
        Ein.AF.Bemerkung    # Auf.AF.Bemerkung;
        "Ein.AF.Kürzel"     # "Auf.AF.Kürzel";
        Erx # RekInsert(502,_recunlock,'AUTO')
        if (erx<>_rOK) then BREAK;
        Erx # RecLink(402,401,11,_recNext);
      END;


      Ein.P.Warengruppe   # Auf.P.Warengruppe;
      Ein.P.AbmessString  # Auf.P.AbmessString;
      Ein.P.Bemerkung     # Auf.P.Bemerkung;
      Ein.P.Strukturnr    # Auf.P.Strukturnr;

      if (Auf.P.Erzeuger<>0) then Ein.P.Erzeuger      # Auf.P.Erzeuger;
      Ein.P.Zeugnisart    # Auf.P.Zeugnisart;
      Ein.P.Intrastatnr   # Auf.P.Intrastatnr;
      Ein.P.Dicke         # Auf.P.Dicke;
      Ein.P.DickenTol     # Auf.P.DickenTol;
      Ein.P.Breite        # Auf.P.Breite;
      Ein.P.BreitenTol    # Auf.P.BreitenTol;
      "Ein.P.LängenTol"   # "Auf.P.LängenTol";
      "Ein.P.Länge"       # "Auf.P.Länge";
      Ein.P.RID           # Auf.P.RID;
      Ein.P.RIDmax        # Auf.P.RIDmax;
      Ein.P.RAD           # Auf.P.RAD;
      Ein.P.RADmax        # Auf.P.RADmax;
      "Ein.P.Stückzahl"   # "Auf.P.Stückzahl";
      Ein.P.Gewicht       # Auf.P.Gewicht;
      Ein.P.Menge.Wunsch  # Auf.P.Menge.Wunsch;
      Ein.P.MEH.Wunsch    # Auf.P.MEH.Wunsch;
  //x    Ein.P.Menge         # Ein.P.Menge.Wunsch;
  //debugx(anum(ein.p.menge.wunsch,0)+ein.p.meh.wunsch);
      // Mengen und MEH beachten
      if (Ein.P.MEH.Wunsch=Ein.P.MEH) then begin
        Ein.P.Menge # Ein.P.Menge.Wunsch;
        Lib_GuiCom:Disable($edEin.P.Menge);
        $edEin.P.Menge->WinUpdate(_WinUpdFld2Obj);
      end
      else begin
        Lib_GuiCom:Enable($edEin.P.Menge);
        if (Auf.P.MEH.Einsatz=Ein.P.MEH) then
          Ein.P.Menge       # Auf.P.Menge;
      end;

      SbrCopy(401,3,501,3); // Analysen kopieren
      Lib_MoreBufs:RecInit(401, y, y);

      FOR vI # 1 loop inc(vI) WHILE (vI<=26) do begin
        FldCopy(401,4,vI, 501,4,vI);
      END;
      Ein.P.Verpacknr       # Auf.P.Verpacknr;
      Ein.P.VerpackAdrNr    # Auf.P.VerpackAdrNr;
      Ein.P.VpgText6        # Auf.P.VpgText6;
      Ein.P.Umverpackung    # Auf.P.Umverpackung;
      Ein.P.Wicklung        # Auf.P.Wicklung;
      "Ein.P.SäbelProM"     # "Auf.P.SäbelProM";
      Ein.P.Skizzennummer   # Auf.P.Skizzennummer;


      // Text kopieren...
      if (Auf.P.TextNr1=0) then begin
        Ein.P.TextNr1 # 0;
        Ein.P.TextNr2 # Auf.P.TextNr2;
      end;
      if (Auf.P.TextNr1=401) then begin
        Ein.P.TextNr1 # 501;
        Ein.P.TextNr2 # 0;
        Lib_GuiCom:Enable($Ein.P.TextEdit1);
        vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
        vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
        vName2 # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
        Lib_Texte:TxtLoadLangBuf(vName, vTxtHdl, Ein.Sprache);
        $Ein.P.TextEdit1->wpcustom # vName2;
        $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
      end;
      if (Auf.P.TextNr1=400) then begin
        Ein.P.TextNr1 # 501;
        Ein.P.TextNr2 # 0;
        Lib_GuiCom:Enable($Ein.P.TextEdit1);
        vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
        vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
        vName2 # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
        Lib_Texte:TxtLoadLangBuf(vName, vTxtHdl, Ein.Sprache);
        $Ein.P.TextEdit1->wpcustom # vName2;
        $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
      end;

      Refreshifm_page1_Art();
    end;  // Anlagemode

    gMDI->winupdate(_WinUpdFld2Obj);
//    aName # 'edEin.P.Artikelnr';
//    aChanged # Y;
  end;


  if (aName='edEin.P.Guete') then begin
    MQU_Data:Autokorrektur(var "Ein.P.Güte");
    Ein.P.Werkstoffnr # MQU.Werkstoffnr;
  end;

  if (aName='edEin.P.Artikelnr') and (($edEin.P.Artikelnr->wpchanged) or (aChanged)) then begin
    //RefreshArtikel();
    GetArtikel();
    vArtChanged # y;
  end;


  if (aName='') or (aName='edEin.P.Menge') then begin
    Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.Ausfall;
    Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.Ausfall.Stk;
    if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
    if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
    $lb.Ein.P.FM.Rest->wpcaption # ANum(Ein.P.FM.Rest,Set.Stellen.Menge);
  end;

  if (aName='') or (aName='edEin.P.Projektnummer') then begin
    Erx # RecLink(120,501,16,0);
    if (Erx<=_rLocked) then
      $lb.Projekt->wpcaption # Prj.Stichwort
    else
      $lb.Projekt->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.P.Kostenstelle') then begin
    Erx # RecLink(846,501,17,0);
    if (Erx<=_rLocked) then
      $lb.Kostenstelle->wpcaption # KSt.Bezeichnung
    else
      $lb.Kostenstelle->wpcaption # '';
  end;

  // Artikel refreshen?
  if (ein.P.Wgr.DateiNr=0) or (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMixArt(Ein.P.Wgr.Dateinr)) and
    ((aName='') or (vArtChanged)) then begin
    Erx # RecLink(250,501,2,_RecFirst); // Artikel holen
    if (Erx<=_rLocked) then begin
      RecBufClear(252);
      Art.C.ArtikelNr # Ein.P.ArtikelNr;
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

    Winupdate($edEin.P.Artikelnr,_WinUpdFld2Obj);
    Winupdate($edEin.P.LieferArtNr,_WinUpdFld2Obj);
    WinUpdate($edEin.P.MEH.Wunsch,_WinUpdFld2Obj);
    $lb.Art.IstBestand->wpcaption # ANum(Art.C.Bestand, Set.Stellen.Menge);
    $lb.Art.Reserviert->wpcaption # ANum(Art.C.Reserviert,Set.Stellen.Menge);
    $lb.Art.Bestellt->wpcaption   # ANum(Art.C.Bestellt,Set.Stellen.Menge);
    $lb.Art.Verfuegbar->wpcaption # ANum("Art.C.Verfügbar",Set.Stellen.Menge);
    $lb.Art.MEH1->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH2->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH3->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH4->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH5->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH6->wpcaption       # Ein.P.MEH;
    $edEin.P.PEH->Winupdate(_WinUpdFld2Obj);
    $edEin.P.Preis.MEH->Winupdate(_WinUpdFld2Obj);
  end;

  if (aName='') or (aName='edEin.P.Grundpreis') then begin
    Ein.p.Einzelpreis # Ein.P.Grundpreis + Ein.P.Aufpreis;
    $lb.P.Einzelpreis->wpcaption # ANum(Ein.P.Einzelpreis,2);
    Ein.P.Gesamtpreis # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
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
  Erx     : int;
  vA      : alpha;
  vName   : alpha;
  vName2  : alpha;
  vTxtHdl : int;
  vI      : int;
end;
begin

  if (aName='') then begin
    if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
      $edEin.P.Artikelnr_Mat->wpcaption # Ein.P.Artikelnr;
      $lb.EH_Mat->wpvisible         # (Ein.P.MEH<>'Stk') and (Ein.P.MEH<>'kg');   // 20.07.2021 AH: Menge editierbar
      $lbEin.P.Menge_Mat->wpvisible # (Ein.P.MEH<>'Stk') and (Ein.P.MEH<>'kg');
      $edEin.P.Menge_Mat->wpvisible # (Ein.P.MEH<>'Stk') and (Ein.P.MEH<>'kg');
    end
    else begin
      $edEin.P.Artikelnr_Mat->wpcaption # Ein.P.Strukturnr;
      $lb.EH_Mat->wpvisible         # false;         // 20.07.2021 AH: Menge editierbar
      $lbEin.P.Menge_Mat->wpvisible # false;
      $edEin.P.Menge_Mat->wpvisible # false;
    end;


    $RL.AFOben->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    $RL.AFUnten->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    $lb.Aufpreise_Mat->wpcaption # ANum(Ein.P.Aufpreis,2);

    Erx # RecLink(814,500,8,0);
    if (Erx<=_rLocked) then begin
      $lb.WAE1_Mat->wpcaption # "Wae.Kürzel";
      $lb.WAE2_Mat->wpcaption # "Wae.Kürzel";
      $lb.WAE3_Mat->wpcaption # "Wae.Kürzel";
      $lb.WAE4_Mat->wpcaption # "Wae.Kürzel";
    end
    else begin
      $lb.WAE1_Mat->wpcaption # '???';
      $lb.WAE2_Mat->wpcaption # '???';
      $lb.WAE3_Mat->wpcaption # '???';
      $lb.WAE4_Mat->wpcaption # '???';
    end;
    if (RecLinkInfo(505,501,8,_RecCount)=0) then begin
      $cb.Kalkulation_Mat->wpCheckState # _WinStateChkUnChecked;
    end
    else begin
      $cb.Kalkulation_Mat->wpCheckState # _WinStateChkChecked;
    end;
  end;

  if (aName='') then begin
    $RL.Aufpreise_Mat->winupdate(_winupdon,_WinLstFromFirst);
  end;

  if ((aName='') or (aName='edEin.P.Warengruppe_Mat')) then begin

    if (Mode=c_ModeEdit) then begin
      RecLink(819,501,1,_RecFirst);
      if (Ein.P.Wgr.Dateinr<>Wgr.Dateinummer) then begin
        Ein.P.Warengruppe # Fldword(ProtokollBuffer[cFile],1,8);
        Msg(401001,'',0,0,0);
      end;
    end;

    Erx # RecLink(819,501,1,0);   // Warengruppe holen
    if (Erx<=_rlocked) then begin
      if (mode=c_modenew) or (mode=c_Modenew2) then Ein_Data:SetWgrDateinr(Wgr.Dateinummer);
      $lb.Warengruppe_Mat->wpcaption # Wgr.Bezeichnung.L1;
    end
    else begin
      $lb.Warengruppe_Mat->wpcaption # '';
      Ein.P.Wgr.Dateinr # Set.Ein.Dateinr;    // 2023-04-25 AH war 0
    end;
    if (Erx>_rLocked) then RecBufClear(819);
/**
    if (SwitchMask(y)=y) then begin
      Ein_P_SMain:RefreshIfm_Page1_Art('',Y);
      $edEin.P.Warengruppe->Winfocusset(true);
      RETURN;
    end;
***/
  end;

  if (aName='') or (aName='edEin.P.Auftragsart_Mat') then begin
    Erx # RecLink(835,501,5,0);
    if (Erx<=_rLocked) then
      $lb.AuftragsArt_Mat->wpcaption # AAr.Bezeichnung
    else
      $lb.AuftragsArt_Mat->wpcaption # '';
  end;

  if (aName='edEin.P.Guete_Mat') then begin
    MQU_Data:Autokorrektur(var "Ein.P.Güte");
    Ein.P.Werkstoffnr # MQU.Werkstoffnr;
  end;

  if (aName='') or (aName='edEin.P.Erzeuger_Mat') then begin
    Erx # RecLink(100,501,11,0);
    if (Erx<=_rLocked) then
      $lb.Erzeuger_Mat->wpcaption # Adr.Stichwort
    else
      $lb.Erzeuger_Mat->wpcaption # '';
  end;


  if (aName='edEin.P.Artikelnr_Mat') and (($edEin.P.Artikelnr_Mat->wpchanged) or (achanged)) then begin
    if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
      Ein.P.Artikelnr # $edEin.P.Artikelnr_Mat->wpcaption;
      GetArtikel_Mat();
      gMDI->Winupdate();
      Refreshifm_Page1_Mat('');
    end
    else begin
      Ein.P.Strukturnr # $edEin.P.Artikelnr_Mat->wpcaption;
      Erx # RecLink(220,501,21,_recFirst);   // Mat.Struktur holen
      if (Erx <= _rLocked) then begin
        // Ankerfunktion
        RunAFX('Ein.P.Auswahl.Strukt','');
      end
    end;
  end;

  // Anzeige des richtigen Kunden der Kommission [PW/05.08.09]
  if ( aName = '' or aName = 'edEin.P.Kommission_Mat' ) then begin
    if ( Ein.P.Kommissionnr != 0 and RecLink( 401, 501, 18, _recFirst ) = _rOk ) then
      $lb.Kommi_Mat->wpCaption # Auf.P.KundenSW;
    else
      $lb.Kommi_Mat->wpCaption # '';
  end;

  // Auftrag in Einkauf kopieren?
  if (aName='edEin.P.Kommission_Mat') and
    (($edEin.P.Kommission_Mat->wpchanged) or (aChanged)) then begin
    vA # Str_Token(Ein.P.Kommission,'/',1);
    Ein.P.Kommissionnr  # Cnvia(vA);
    vA # Str_Token(Ein.P.Kommission,'/',2);
    Ein.P.Kommissionpos # Cnvia(vA);
    Erx # RecLink(401,501,18,_RecFirst);
    if (Erx<>_rOK) then begin
      Ein.P.Kommissionnr  # 0;
      Ein.P.Kommissionpos # 0;
      Ein.P.Kommission    # '';
      Ein.P.KommiKunde    # 0;
      $lb.Kommi_Mat->wpcaption  # '';
      RETURN;
    end;
    $lb.Kommi_Mat->wpcaption  # Auf.P.kundenSW;
    Ein.P.Kommissionnr  # Auf.P.Nummer;
    Ein.P.Kommissionpos # Auf.P.Position;
    Ein.P.Kommission # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position)
    Ein.P.KommiKunde    # Auf.P.Kundennr;

    // Sonderfunktion:
    if (aChanged) then vA # '1|' + aName;
    else vA # '0|' + aName;
    if (RunAFX('Ein.P.Auswahl.Kommission',vA)<0) then begin
      RETURN;
    end;

    // 21.12.2012 AI: Projekt 1327/324
    Erx # RecLink(400,401,3,_RecFirst);
    if (Auf.LiefervertragYN) then begin
      Msg(501005,'',0,0,0);
    end;


    // 27.10.2016 AH: nur bei Anlage
    if (Mode=c_ModeNew2) or (Mode=c_ModeEdit2) then begin
      Ein.P.Artikelnr     # Auf.P.Artikelnr;
      Ein.P.ArtikelSW     # Auf.P.ArtikelSW;
      Ein.P.Sachnummer    # Auf.P.Sachnummer;

      "Ein.P.Güte"        # "Auf.P.Güte";
      "Ein.P.Gütenstufe"  # "Auf.P.Gütenstufe";
      Ein.P.Werkstoffnr   # Auf.P.Werkstoffnr;
      Ein.P.AusfOben      # Auf.P.AusfOben;
      Ein.P.AusfUnten     # Auf.P.AusfUnten;
      // bisherige Ausführung löschen
      WHILE (RecLink(502,501,12,_recFirst)<=_rLocked) do begin
        Erx # RekDelete(502,0,'MAN');
        if (Erx<>_rOK) then BREAK;
      END;
      // Ausführung kopieren
      Erx # RecLink(402,401,11,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        Ein.AF.Nummer       # Ein.P.Nummer;
        Ein.AF.Position     # Ein.P.Position;
        Ein.AF.Seite        # Auf.AF.Seite;
        Ein.AF.lfdNr        # Auf.AF.lfdNr;
        Ein.AF.ObfNr        # Auf.AF.ObfNr;
        Ein.AF.Bezeichnung  # Auf.AF.Bezeichnung;
        Ein.AF.Zusatz       # Auf.AF.Zusatz;
        Ein.AF.Bemerkung    # Auf.AF.Bemerkung;
        "Ein.AF.Kürzel"     # "Auf.AF.Kürzel";
        Erx # RekInsert(502,_recunlock,'AUTO')
        if (erx<>_rOK) then BREAK;
        Erx # RecLink(402,401,11,_recNext);
      END;

      Ein.P.Warengruppe   # Auf.P.Warengruppe;
      Ein.P.AbmessString  # Auf.P.AbmessString;
      Ein.P.Bemerkung     # Auf.P.Bemerkung;
      Ein.P.Strukturnr    # Auf.P.Strukturnr;

      if (Auf.P.Erzeuger<>0) then Ein.P.Erzeuger      # Auf.P.Erzeuger;
      Ein.P.Zeugnisart    # Auf.P.Zeugnisart;
      Ein.P.Intrastatnr   # Auf.P.Intrastatnr;
      Ein.P.Dicke         # Auf.P.Dicke;
      Ein.P.DickenTol     # Auf.P.DickenTol;
      Ein.P.Breite        # Auf.P.Breite;
      Ein.P.BreitenTol    # Auf.P.BreitenTol;
      "Ein.P.LängenTol"   # "Auf.P.LängenTol";
      "Ein.P.Länge"       # "Auf.P.Länge";
      Ein.P.RID           # Auf.P.RID;
      Ein.P.RIDmax        # Auf.P.RIDmax;
      Ein.P.RAD           # Auf.P.RAD;
      Ein.P.RADmax        # Auf.P.RADmax;
      "Ein.P.Stückzahl"   # "Auf.P.Stückzahl";
      Ein.P.Gewicht       # Auf.P.Gewicht;
  //      Ein.P.Menge.Wunsch  # Auf.P.Menge.Wunsch
  //    Ein.P.MEH.Wunsch    # Auf.P.MEH.Wunsch;
      if (Ein.P.MEH.Wunsch=Auf.P.MEH.Wunsch) then
        Ein.P.Menge.Wunsch  # Auf.P.Menge.Wunsch
      else if (Ein.P.MEH.Wunsch='kg') then
        Ein.P.Menge.Wunsch  # Ein.P.Gewicht
      else if (Ein.P.MEH.Wunsch='t') then
        Ein.P.Menge.Wunsch  # Ein.P.Gewicht / 1000.0
      else if (Ein.P.MEH.Wunsch='StK') then
        Ein.P.Menge.Wunsch  # cnvfi("Ein.P.Stückzahl");

      /*
      // Text kopieren?
      if (Ein.P.TextNr1=501) then begin
      vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      vName2 # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      TxtCopy(vName,vName2,0);
      end;
      */
      SbrCopy(401,3,501,3); // Analysen kopieren
      Lib_MoreBufs:RecInit(401, y, y);

  //    SbrCopy(401,4,501,4); // Verpackung kopieren
      FOR vI # 1 loop inc(vI) WHILE (vI<=26) do begin
        FldCopy(401,4,vI, 501,4,vI);
      END;
      Ein.P.Verpacknr       # Auf.P.Verpacknr;
      Ein.P.VerpackAdrNr    # Auf.P.VerpackAdrNr;
      Ein.P.VpgText6        # Auf.P.VpgText6;
      Ein.P.Umverpackung    # Auf.P.Umverpackung;
      Ein.P.Wicklung        # Auf.P.Wicklung;
      "Ein.P.SäbelProM"     # "Auf.P.SäbelProM";
      Ein.P.Skizzennummer   # Auf.P.Skizzennummer;

      // Text kopieren...
      if (Auf.P.TextNr1=0) then begin
        Ein.P.TextNr1 # 0;
        Ein.P.TextNr2 # Auf.P.TextNr2;
      end;
      if (Auf.P.TextNr1=401) then begin
        Ein.P.TextNr1 # 501;
        Ein.P.TextNr2 # 0;
        Lib_GuiCom:Enable($Ein.P.TextEdit1);
        vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
        vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
        vName2 # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
        Lib_Texte:TxtLoadLangBuf(vName, vTxtHdl, Ein.Sprache);
        $Ein.P.TextEdit1->wpcustom # vName2;
        $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
      end;
      if (Auf.P.TextNr1=400) then begin
        Ein.P.TextNr1 # 501;
        Ein.P.TextNr2 # 0;
        Lib_GuiCom:Enable($Ein.P.TextEdit1);
        vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
        vName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
        vName2 # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
        Lib_Texte:TxtLoadLangBuf(vName, vTxtHdl, Ein.Sprache);
        $Ein.P.TextEdit1->wpcustom # vName2;
        $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
      end;
      Refreshifm_page1_Mat();
    end;  // anlagemode

    gMDI->winupdate(_WinUpdFld2Obj);
    RETURN;
  end;

  if (aName='edEin.P.Dickentol_Mat')  and (Ein.P.Dicke<>0.0) then begin
    "Ein.P.Dickentol" # Lib_Berechnungen:Toleranzkorrektur("Ein.P.Dickentol",Set.Stellen.Dicke);
  end;

  if (aName='edEin.P.Breitentol_Mat') and (Ein.P.Breite<>0.0) then begin
    "Ein.P.Breitentol" # Lib_Berechnungen:Toleranzkorrektur("Ein.P.Breitentol",Set.Stellen.Breite);
  end;

  if (aName='edEin.P.Laengentol_Mat') and ("Ein.P.Länge"<>0.0) then begin
    "Ein.P.Längentol" # Lib_Berechnungen:Toleranzkorrektur("Ein.P.Längentol","Set.Stellen.Länge");
  end;

  if (aName='') or (aName='edEin.P.Grundpreis_Mat') or
    (aName='edEin.P.PEH_Mat') or (aName='edEin.P.Preis.MEH_Mat') then begin
    Ein.p.Einzelpreis # Ein.P.Grundpreis + Ein.P.Aufpreis;
    Ein.P.Gesamtpreis # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
    $lb.Poswert_Mat->wpcaption # ANum(Ein.P.Gesamtpreis,2);
    $lb.P.Einzelpreis_Mat->wpcaption # ANum(Ein.P.Einzelpreis,2);
  end;


  if (aName='edEin.P.Verpacknr') and ($edEin.P.Verpacknr->wpchanged) then begin
    Erx # RecLink(100,500,1,0); // Lieferant holen
    If (Erx>=_rLocked) then RecBufClear(100);
    RecBufClear(105);
    Adr.V.Adressnr        # Adr.Nummer;
    Adr.V.lfdNr           # Ein.P.Verpacknr;
    Erx # RecRead(105,1,0);
    if (Erx<=_rLocked) then begin
      Ein.p.Verpacknr       # Adr.V.lfdNr;
      Ein.P.AbbindungL      # Adr.V.AbbindungL;
      EIn.P.AbbindungQ      # Adr.V.AbbindungQ;
      Ein.P.Zwischenlage    # Adr.V.Zwischenlage;
      Ein.P.Unterlage       # Adr.V.Unterlage;
      Ein.P.Umverpackung    # Adr.V.Umverpackung;
      Ein.P.Wicklung        # Adr.V.Wicklung;
      Ein.P.MitLfEYN        # Adr.V.MitLfEYN;
      Ein.P.StehendYN       # Adr.V.StehendYN;
      Ein.P.LiegendYN       # Adr.V.LiegendYN;
      EIn.P.Nettoabzug      # Adr.V.Nettoabzug;
      "Ein.P.Stapelhöhe"    # "Adr.V.Stapelhöhe";
      EIn.P.StapelhAbzug    # Adr.V.StapelhAbzug;
      EIn.P.RingKgVon       # Adr.V.RingKgVon;
      Ein.P.RingKgBis       # Adr.V.RingKgBis;
      Ein.P.KgmmVon         # Adr.V.KgmmVon;
      Ein.P.KgmmBis         # Adr.V.KgmmBis;
      "Ein.P.StückProVE"      # "Adr.V.StückProVE";
      Ein.P.VEkgMax         # Adr.V.VEkgMax;
      EIn.P.RechtwinkMax    # Adr.V.RechtwinkMax;
      EIn.P.EbenheitMax     # Adr.V.EbenheitMax;
      "EIn.P.SäbeligkeitMax" # "Adr.V.SäbeligkeitMax";
      "EIn.P.SäbelProM"     # "Adr.V.SäbelProM";
      Ein.P.Etikettentyp    # Adr.V.Etikettentyp;
      Ein.P.Verwiegungsart  # Adr.V.Verwiegungsart;
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
  vOK         : logic;
end;
begin

  if (Mode=c_Modeview) and (Ein.P.Nummer<>0) and (Ein.P.Nummer<1000000000) then begin
    RecLink(500,501,3,_RecFirst);  // Kopf holen
  end;

  if (aName='') then begin
    if (Ein.P.Nummer<1000000000) and (Ein.P.Nummer<>0) then begin
      $lb.Nummer2->wpcaption # AInt(Ein.P.Nummer);
      $lb.Nummer2b->wpcaption # AInt(Ein.P.Nummer);
    end
    else begin
      $lb.Nummer2->wpcaption # '';
      $lb.Nummer2b->wpcaption # '';
    end;
    $lb.Position2->wpcaption # AInt(Ein.P.Position);
    $lb.P.Lieferant2->wpcaption # Ein.P.LieferantenSW;

    vOk # n;
    vTxtHdl # $Ein.P.TextStammdaten->wpdbTextBuf;
    if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) and
      (Ein.P.Artikelnr<>'') then begin
      vOK # y;
      Erx # RecLink(250,501,2,_RecFirst); // Artikel holen
      if (Erx<=_rLocked) then begin
      // 23.02.2016 AH: immer USERSprache anzeigen:
//        if (Lib_texte:TxtLoadLangBuf('~250.EK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,Ein.Sprache)=false) then vOK # n;
        if (Lib_texte:TxtLoadLangBuf('~250.EK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, gUserSprache)=false) then vOK # n;
      end
      else begin
        vOK # n;
      end;
    end;
    if (vOK=n) and (vTxtHdl<>0) then TextClear(vTxtHdl);
    $Ein.P.TextStammdaten->WinUpdate(_WinUpdBuf2Obj);
  end;


  if (Ein.P.TextNr1=0) then begin
    $edein.P.TextNr2b->wpcaptionint # Ein.P.TextNr2;
    $cb.Text2->wpCheckState # _WinStateChkChecked;
  end
  else begin
    $edEin.P.TextNr2b->wpcaptionint # 0;
  end;

  if (Ein.P.TextNr1=500) then begin
    $edEin.P.TextNr2->wpcaptionint # Ein.P.TextNr2
    $cb.Text1->wpCheckState # _WinStateChkChecked;
  end
  else begin
    $edEin.P.TextNr2->wpcaptionint # 0;
  end;

  if (Ein.P.TextNr1= 501) then begin
    $cb.Text3->wpCheckState # _WinStateChkChecked;
  end;

  if (aName='') or (aName='edEin.P.TextNr2') or (aName='edEin.P.TextNr2b') then begin
    Ein_P_Main:EinPTextRead();
  end;

  if (aName='') or (aName='Text') then begin
//debug('text:'+aname+'  mode:'+mode+'    nr:'+cnvai(ein.p.nummer)+'/'+cnvai(ein.p.position)+'/'+cnvai(ein.p.textnr1));
    if (Ein.P.TextNr1=501) then begin
      if (Mode<>c_ModeView) then begin
        Lib_GuiCom:Enable($Ein.P.TextEdit1);
        Lib_GuiCom:Disable($edEin.P.TextNr2);
        Lib_GuiCom:Disable($edEin.P.TextNr2b);
      end;
      $cb.Text1->wpCheckState # _WinStateChkUnChecked;
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkChecked;
    end
    else if (Ein.P.TextNr1=500) then begin
      if (Mode<>c_ModeView) then begin
        Lib_GuiCom:Disable($Ein.P.TextEdit1);
        Lib_GuiCom:Enable($edEin.P.TextNr2);
        Lib_GuiCom:Disable($edEin.P.TextNr2b);
      end;
      $cb.Text1->wpCheckState # _WinStateChkChecked;
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkUnChecked;
    end
    else if (Ein.P.TextNr1=0) then begin
      if (Mode<>c_ModeView) then begin
        Lib_GuiCom:Disable($Ein.P.TextEdit1);
        Lib_GuiCom:Disable($edEin.P.TextNr2);
        Lib_GuiCom:Enable($edEin.P.TextNr2b);
      end;
      $cb.Text1->wpCheckState # _WinStateChkUnChecked;
      $cb.Text2->wpCheckState # _WinStateChkChecked;
      $cb.Text3->wpCheckState # _WinStateChkUnChecked;
    end;
  end;


/*
//---------------------------------------
//   Alte Version aus der Bestellung
//
  if ((aName='') or (aName='Text')) and
    ((Mode=c_ModeEdit) or (Mode=c_ModeEdit2) or (Mode=c_ModeNew) or (Mode=c_ModeNew2)) then begin
    if (Ein.P.TextNr1=501) then begin
      Lib_GuiCom:Enable($Ein.P.TextEdit1);
      Lib_GuiCom:Disable($edEin.P.TextNr2);
      Lib_GuiCom:Disable($edEin.P.TextNr2b);
      Lib_GuiCom:Disable($bt.Standardtext);
      Lib_GuiCom:Disable($bt.Standardtext2);
      $cb.Text1->wpCheckState # _WinStateChkUnChecked;
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkChecked;
    end
    else if (Ein.P.TextNr1=500) then begin
      Lib_GuiCom:Disable($Ein.P.TextEdit1);
      Lib_GuiCom:Enable($edEin.P.TextNr2);
      Lib_GuiCom:Disable($edEin.P.TextNr2b);
      Lib_GuiCom:Enable($bt.Standardtext);
      Lib_GuiCom:Disable($bt.Standardtext2);
      $cb.Text1->wpCheckState # _WinStateChkChecked;
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkUnChecked;
    end
    else if (Ein.P.TextNr1=0) then begin
      Lib_GuiCom:Disable($Ein.P.TextEdit1);
      Lib_GuiCom:Disable($edEin.P.TextNr2);
      Lib_GuiCom:Enable($edEin.P.TextNr2b);
      Lib_GuiCom:Disable($bt.Standardtext);
      Lib_GuiCom:Enable($bt.Standardtext2);
      $cb.Text1->wpCheckState # _WinStateChkUnChecked;
      $cb.Text2->wpCheckState # _WinStateChkChecked;
      $cb.Text3->wpCheckState # _WinStateChkUnChecked;
    end;
  end;

  if (aName='') then begin
    if (Ein.P.TextNr1=0) then
      $edEin.P.TextNr2b->wpcaptionint # Ein.P.TextNr2;
    else
      $edEin.P.TextNr2b->wpcaptionint # 0;

    if (Ein.P.TextNr1=500) then
      $edEin.P.TextNr2->wpcaptionint # Ein.P.TextNr2
    else
      $edEin.P.TextNr2->wpcaptionint # 0;
  end;

  if (aName='') or (aName='edEin.P.TextNr2') or (aName='edEin.P.TextNr2b') then begin
    if (Ein.P.TextNr1=500) then
      Ein.P.TextNr2 # $edEin.P.TextNr2->wpcaptionint;
    if (Ein.P.TextNr1=0) then
      Ein.P.TextNr2 # $edEin.P.TextNr2b->wpcaptionint;
    Ein_P_Main:EinPTextRead();
  end;
*/


end;


//========================================================================
//  RefreshIfm_Page3
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm_Page3(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx : int;
end;
begin

  if (aName='') or
    ((aName='edEin.P.Skizzennummer') and ($edEin.P.Skizzennummer->wpchanged)) then begin
    Erx # RecLink(829,501,22,_recFirst);          // Skizze holen
    if (Erx<>_rOK) then begin
      $pic.Skizze->wpcaption # '';
    end
    else begin
      $pic.Skizze->wpcaption # '*'+Skz.Dateiname;
    end;
  end;

  if (aName='') or (aName='edEin.P.Verwiegungsart') then begin
    Erx # RecLink(818,501,10,0);
    if (Erx<=_rLocked) then
      $lb.Verwiegungsart->wpcaption # VWa.Bezeichnung.L1
    else
      $lb.Verwiegungsart->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.P.Etikettentyp') then begin
    $edEin.P.Etikettentyp->winupdate(_WinUpdFld2Obj);
    $edEin.P.Etikettentyp2->winupdate(_WinUpdFld2Obj);
    Erx # RecLink(840,501,9,0);
    if (Erx<=_rLocked) then begin
      $lb.Etikettentyp->wpcaption # Eti.Bezeichnung;
      $lb.Etikettentyp2->wpcaption # Eti.Bezeichnung;
    end
    else begin
      $lb.Etikettentyp->wpcaption # '';
      $lb.Etikettentyp2->wpcaption # '';
    end;
    end;

  if (aName='') or (aName='edEin.P.Etikettentyp2') then begin
    Erx # RecLink(840,501,9,_RecFirst);
    if (Erx>_rLocked) then RecBufClear(840);
    $lb.Etikettentyp->wpcaption # Eti.Bezeichnung;
    $lb.Etikettentyp2->wpcaption # Eti.Bezeichnung;
  end;

  Ein_P_Main:EinPTextRead();

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
    if (vFile=200) then begin
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

    vMDI # Lib_GuiCom:FindMDI(aEvt:Obj);

    if (vFile=200) then begin
      WinUpdate(vMDI, _winupdactivate);
      Winfocusset(vMDI, true);
      VarInstance(WindowBonus,cnvIA(vMDI->wpcustom));

      gSelected # vID;
      w_Command # 'AusMaterial';
      App_Main:Action(c_ModeNew);

      RETURN true;
    end;
  end;

  RETURN false;
end;


//========================================================================