@A+
//==== Business-Control ==================================================
//
//  Prozedur    HuB_EK_P_Main
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  28.10.2013  ST  Keine Änderung/Neuanlage bei gelöschter Bestellung (Projekt 1455/45)
//                  Keine Änderung bei gelöschter Position
//  06.02.2017  ST  BugFix Artikelauswahl
//  28.07.2021  AH  ERX, Kostenstelle
//  22.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    sub EvtInit(aEvt  : event): logic
//    sub RefreshIfm (aName : alpha);
//    sub RecInit()
//    sub RecSave() : logic
//    sub RecCleanup() : logic
//    sub RecDel()
//    sub EvtFocusInit (aEvt : event; aFocusObject : int) : logic
//    sub EvtFocusTerm (aEvt : event; aFocusObject : int) : logic
//    sub Auswahl(aBereich : alpha;)
//    sub AusArtikel()
//    sub AusWareneingang()
//    sub RefreshMode()
//    sub EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    sub EvtClicked (aEvt : event;) : logic
//    sub EvtClose(aEvt : event;): logic
//    sub EvtLstSelect(aEvt : event; aRecID : int;) : logic
//    sub EvtLstDataInit(aEvt : Event; aRecId : int;);
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Einkauf: Hilfs- und Betriebsstoffe'
  cFile :     191
  cMenuName : 'HuB.EK.P.Bearbeiten'
  cPrefix :   'HuB_EK_P'
  cZList :    $ZL.HuB.EK.P
  cKey :      1
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edHuB.EK.P.Artikelnr);
Lib_Guicom2:Underline($edHuB.EK.P.Kostenstell);

  SetStdAusFeld('edHuB.EK.P.Artikelnr'    ,'Artikel');
  SetStdAusFeld('edHuB.EK.P.Kostenstell'  ,'Kostenstelle');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edHuB.EK.P.Artikelnr);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  erx     : int;
  vTmp    : int;
  vArtnr  : alpha;
  vOK     : logic;
end;
begin
  if (aName='') or (aName='edHuB.EK.P.Artikelnr') then begin
    if (HuB.EK.P.Artikelnr<>'') then begin
      Erx # RecLink(180,191,2,0);
      if (Erx<=_rLocked) then begin
        if ($edHuB.EK.P.Artikelnr->wpchanged) then begin
          HuB.EK.P.ArtikelSW # HuB.Stichwort;
          HuB.EK.P.MEH # HuB.MEH;
          HuB_Data:FindePreis(HuB.Ek.P.Artikelnr,HuB.EK.P.Lieferant,"HuB.EK.Währung", var HuB.EK.P.PEH,var HuB.EK.P.Preis, var HuB.EK.P.LieferArtNr);
          gMDI->winupdate(_WinUpdFld2Obj);
        end;
        $Lb.MEH1->wpcaption # HuB.MEH;
        $Lb.MEH2->wpcaption # HuB.MEH;
        $Lb.MEH3->wpcaption # HuB.MEH;
        vOK # true;
      end;
    end;
    if (vOK=false) then begin
      HuB.EK.P.ArtikelSW # '';
      HuB.EK.P.MEH # '';
      RecBufClear(180);
    end;
    $Lb.Bezeichnung1->wpcaption # HuB.Bezeichnung1;
    $Lb.Bezeichnung2->wpcaption # HuB.Bezeichnung2;
  end;

  if (aName='') or (aName='edHuB.EK.P.Menge.Best') then begin
    $Lb.Menge.Rest->wpcaption   # ANum(HuB.EK.P.Menge.Best-HuB.EK.P.Menge.WE,Set.Stellen.Menge);
  end;


  if (aName='') or (aName='edHuB.EK.P.Kostenstell') then begin
    Erx # RekLink(846,191,4,0); // Kostenstelle holen
    $Lb.Kostenstelle->wpcaption # KSt.Bezeichnung;
  end;


  if (aName='') then begin
    $Lb.Nummer->wpcaption # AInt(HuB.EK.P.EKNr);
    $Lb.Position->wpcaption # AInt(HuB.EK.P.Nummer);
    $Lb.Lieferant->wpcaption # AInt(HuB.EK.P.Lieferant);
    $Lb.LieferSWort->wpcaption # HuB.EK.P.LieferSW;
    $Lb.Menge.WE->wpcaption   # ANum(HuB.EK.P.Menge.WE,Set.Stellen.Menge);
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  Erx : int;
  vNr : int;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);


  if (Mode=c_ModeNew) then begin
    Erx # RecLink(191,190,1,_RecLast);
    If (Erx=_rNoRec) then
      vNr # 1
    else
      vNr # HuB.EK.P.Nummer + 1;

    RecBufClear(191);
    HuB.EK.P.EkNr # HuB.EK.Nummer;
    HuB.EK.P.Nummer # vNr;
    HuB.EK.P.Lieferant # HuB.EK.Lieferant;
    HuB.Ek.P.LieferSW # HuB.EK.LieferStichW;
  end;

  // Focus setzen auf Feld:
  $edHuB.EK.P.Artikelnr->WinFocusSet(true)
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vVorher : float;
  vDiff   : float;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  Erx # RecLink(180,191,2,_RecLock);
  if (Erx=_rnoRec) then begin
    Msg(191000,HuB.EK.P.Artikelnr,0,0,0);
    RETURN false;
  end;
  if (Erx=_rLocked) then begin
    Msg(191001,HuB.EK.P.Artikelnr,0,0,0);
    RETURN false;
  end;

  if (HuB.EK.P.Kostenstell<>0) then begin
    Erx # RekLink(846,191,4,0); // Kostenstelle holen
    if (erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Kostenstelle', 'NB.Page1', 'edHub.EK.P.Kostenstell');
      RETURN false;
    end;
  end;


  TRANSON;

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin

    // HuB-Artikel updaten
    vVorher # FldFloat(ProtokollBuffer[cFile],1,12);
    if (HuB.EK.P.Menge.WE<vVorher) then begin
      HuB.Menge.Bestellt # HuB.Menge.Bestellt - (vVorher - HuB.EK.P.Menge.WE);
      if (HuB.EK.P.Menge.Best>HuB.EK.P.Menge.WE) then
        HuB.Menge.Bestellt # HuB.Menge.Bestellt + (HuB.EK.P.Menge.Best - HuB.EK.P.Menge.WE);
      end
    else begin
      if (HuB.EK.P.Menge.WE<HuB.EK.P.Menge.Best) then begin
        HuB.Menge.Bestellt # HuB.Menge.Bestellt + (HuB.EK.P.Menge.Best - HuB.EK.P.Menge.WE);
      end;
    end;
    Erx # RekReplace(180,_recUnlock,'AUTO');

    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
    end
  else begin
    // HuB-Artikel updaten
    HuB.Menge.Bestellt # HuB.Menge.Bestellt + HuB.EK.P.Menge.Best;
    RekReplace(180,_recUnlock,'AUTO');

    HuB.EK.P.Anlage.Dat    # Today;
    HuB.EK.P.Anlage.Zeit   # Now;
    HuB.EK.P.Anlage.User   # gUsername;

    REPEAT
      Erx # RekInsert(gFile,0,'MAN');
      if (erx<>_rOk) then
        HuB.EK.P.Nummer # HuB.Ek.P.Nummer + 1;
    UNTIL (Erx=_rOk);
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  TRANSOFF;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx   : int;
  vPos  : word;
  vOk   : logic;
end;
begin

  if ("HuB.EK.P.Löschmarker"='') then begin

    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      TRANSON;
      if (HuB.EK.P.Menge.WE<HuB.EK.P.Menge.Best) then begin
        RecLink(180,191,2,_RecLock);     // Artikel holen
        HuB.Menge.Bestellt # HuB.Menge.Bestellt - (HuB.EK.P.Menge.Best - HuB.EK.P.Menge.WE);
        Erx # Rekreplace(180,_RecUnlock,'MAN');
        if (erx<>_rOk) then begin
          TRANSBRK;
          Msg(001000+Erx,Translate('Hilfs- und Betriebsstoffe'),0,0,0);
          RETURN;
        end;
      end;
      RecRead(191,1,_recLock);
      "HuB.EK.P.Löschmarker" # '*'
      Erx # RekReplace(191,_recUnlock,'MAN');
      if (erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,Translate(gTitle),0,0,0);
        RETURN;
      end;
      TRANSOFF;
    end;

    end
  else begin

    if (Msg(000007,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      TRANSON;
      if (HuB.EK.P.Menge.WE<HuB.EK.P.Menge.Best) then begin
        RecLink(180,191,2,_RecLock);     // Artikel holen
        HuB.Menge.Bestellt # HuB.Menge.Bestellt + (HuB.EK.P.Menge.Best - HuB.EK.P.Menge.WE);
        Erx # Rekreplace(180,_RecUnlock,'MAN');
        if (erx<>_rOk) then begin
          TRANSBRK;
          Msg(001000+Erx,Translate('Hilfs- und Betriebsstoffe'),0,0,0);
          RETURN;
        end;
      end;
      RecRead(191,1,_recLock);
      "HuB.EK.P.Löschmarker" # '';
      Erx # RekReplace(191,_recUnlock,'MAN');
      if (erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,Translate(gTitle),0,0,0);
        RETURN;
      end;
      TRANSOFF;
    end;

  end;

  vOk # y;
  vPos # HuB.EK.P.Nummer;
  RecLink(190,191,3,_RecFirst);         // Kopf holen
  Erx # RecLink(191,190,1,_RecFirst);   // Posten durchlaufen
  WHILE (Erx<=_rLockeD) and (vOk) do begin
    if ("HuB.Ek.P.Löschmarker"<>'*') then vOk # n;
    Erx # RecLink(191,190,1,_RecNext);
  END;
  RecRead(190,1,_RecLock);
  if (vOk) then "HuB.EK.Löschmarker" # '*'
  else "HuB.EK.Löschmarker" # '';
  Rekreplace(190,_recUnlock,'MAN');

  HuB.EK.P.Nummer # vPos;         // Restore
  RecRead(191,1,0);

  //RekDelete(gFile,0,'MAN');
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin

  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj)
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // neu zu fokusierendes Objekt
) : logic
local begin
  vDat  : date;
  vKW   : word;
  vJahr : word;
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  if (aFocusObject=0) then RETURN false;
  
  if (aEvt:Obj->wpname='edHuB.EK.P.WTermin') then begin
    if (HuB.EK.P.WTermin<>0.0.0) then begin
      vKW # HuB.EK.P.WTerminKW;
      vJahr # HuB.EK.P.WTerminJahr;
      Lib_Berechnungen:KW_aus_Datum(HuB.EK.P.WTermin, var vKW, var vJahr);
      HuB.EK.P.WTerminKW # vKW;
      HuB.EK.P.WTerminJahr # vJahr;
      RefreshIfm('edHuB.EK.P.WTerminKW');
      RefreshIfm('edHuB.EK.P.WTerminJahr');
    end;

    if (HuB.EK.P.WTermin=0.0.0) then begin
      Lib_GuiCom:Enable($edHuB.EK.P.WTerminKW);
      Lib_GuiCom:Enable($edHuB.EK.P.WTerminJahr);
      if (aFocusObject->wpname='edHuB.EK.P.Bemerkung') then begin
        $edHub.EK.P.WTerminKW->winfocusset(true);
      end;
      end
    else begin
      Lib_GuiCom:Disable($edHuB.EK.P.WTerminKW);
      Lib_GuiCom:Disable($edHuB.EK.P.WTerminJahr);
      if (aFocusObject->wpname='edHuB.EK.P.WTerminKW') or
        (aFocusObject->wpname='edHuB.EK.P.WTerminKW') then begin
        $edHub.EK.P.Bemerkung->winfocusset(true);
      end;
    end
  end;

  RETURN true;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  vA    : alpha;
end;

begin

  case aBereich of
    'Artikel' : begin
      RecBufClear(180);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'HuB.Verwaltung','HuB_EK_P_Main:AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kostenstelle' : begin
      RecBufClear(846);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Kst.Verwaltung',here+':AusKostenstelle');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(180,0,_RecId,gSelected);
    // Feldübernahme
    HuB.EK.P.Artikelnr # HuB.Artikelnr;
    HuB.EK.P.ArtikelSW # HuB.Stichwort;
    HuB.EK.P.MEH # HuB.MEH;
    gSelected # 0;
    HuB_Data:FindePreis(HuB.Ek.P.Artikelnr,HuB.EK.P.Lieferant,"HuB.EK.Währung", var HuB.EK.P.PEH,var HuB.EK.P.Preis, var HuB.EK.P.LieferArtNr);
    vTmp # WinFocusGet();
    if ( vTmp != 0 ) then
      vTmp->WinUpdate( _winUpdFld2Obj );

    $HuB.EK.P.Verwaltung->WinUpdate();
  end;
  // Focus auf Editfeld setzen:
  $edHuB.EK.P.Artikelnr->Winfocusset(false);
  // ggf. Labels refreshen
  //RefreshIfm('edHuB.EK.P.Artikelnr');
end;


//========================================================================
//  AusWareneingang
//
//========================================================================
sub AusWareneingang()
begin
  gSelected # 0;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  if ("HuB.EK.P.Löschmarker"='') and (HuB.EK.P.Menge.WE>=HuB.EK.P.Menge.Best) then begin
    if (WinDialogBox(gMdi,
      Translate('Hilfs- und Betriebstoffe - Einkauf'),
      Translate('Soll die Position als gelöscht markiert werden?'),
      _WinIcoQuestion,
      _WinDialogYesNo,1)=_winidyes) then begin
      RecDel();
    end;
  end;
end;


//========================================================================
//  AusKostenstelle
//
//========================================================================
sub AusKostenstelle()
begin

  if (gSelected<>0) then begin
    RecRead(846,0,_RecId,gSelected);
    gSelected # 0;
    HuB.EK.P.Kostenstell # Kst.Nummer;
  end;
  $edHub.EK.P.Kostenstell->Winfocusset(false);
  Refreshifm();
end;



//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx         : int;
  d_MenuItem  : int;
  vHdl        : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_P_Anlegen]=n) or
      ("HuB.EK.Löschmarker" = '*');
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_P_Anlegen]=n) or
    ("HuB.EK.Löschmarker" = '*');


  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_HuB_EK_P_Aendern]=n) or
                          ("HuB.EK.Löschmarker" = '*') OR ("HuB.EK.P.Löschmarker" = '*');
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_HuB_EK_P_Aendern]=n) or
                          ("HuB.EK.Löschmarker" = '*') OR ("HuB.EK.P.Löschmarker" = '*');


  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_HuB_EK_P_Aendern]=n) or
                        ("HuB.EK.Löschmarker" = '*');
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_HuB_EK_P_Aendern]=n) or
                        ("HuB.EK.Löschmarker" = '*');


  vHdl # gMenu->WinSearch('Mnu.Wareneingang');
  if (vHdl <> 0) then begin
    Erx # RecRead(191,1,_RecTest);
    vHdl->wpDisabled # (Mode=C_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_HuB_EK_Eingaenge]=n) or (Erx<>_rOk);
  end;

  RefreshIfm();

end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Wareneingang' : begin
      RecBufClear(192);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'HuB.EK.E.Verwaltung','HuB_EK_P_Main:AusWareneingang');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, HuB.EK.P.Anlage.Dat, HuB.EK.P.Anlage.Zeit, HuB.EK.P.Anlage.User );
    end;

  end; // case

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Artikelnr':       Auswahl('Artikel');
    'bt.Kostenstelle' :   Auswahl('Kostenstelle');
  end;

end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
                   );
begin
  if ("HuB.EK.P.Löschmarker"='*') then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);

  Refreshmode();
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
begin
  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edHuB.EK.P.Artikelnr') AND (aBuf->HuB.EK.P.Artikelnr<>'')) then begin
    RekLink(180,191,2,0);   // Artikelnummer holen
    Lib_Guicom2:JumpToWindow('HuB.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edHuB.EK.P.Kostenstell') AND (aBuf->HuB.EK.P.Kostenstell<>0)) then begin
    RekLink(846,191,4,0);   // Kostenstelle holen
    Lib_Guicom2:JumpToWindow('Kst.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================