@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_P_Plan_Main
//                          OHNE E_R_G
//  Info
//
//
//  04.02.2008  AI  Erstellung der Prozedur
//  07.06.2016  AH  Directory auf %temp%
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB Start();
//    SUB AusSel();
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB SaveAll() : logic;
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle      : 'BA-Positionen'
  cFile       :  702
  cMenuName   : 'BA1.Plan.Bearbeiten'
  cPrefix     : 'BA1_P_Plan'
  cZList      : $ZL.BA1.Plan
  cKey        : 1

/*
  cPlanDat    : Gv.Datum.01
  cPlanZeit   : Gv.Zeit.01
  cPlanDauer  : Gv.Num.01
  cPlanRes1   : Gv.Int.01
  cPlanRes2   : Gv.Int.02
*/
end;

declare RefreshMode(opt aNoRefresh : logic);

//========================================================================
// Start
//
//========================================================================
sub Start();
begin
  RecBufClear(998);
  Sel.bis.Datum # DateMake(31,12,dateyear(today));
//Sel.BAG.Nummer # 1;
//Sel.BAG.Res.Nummer # 2;
  gMDIBAG # Lib_GuiCom:AddChildWindow(gMDI,'Sel.BA1.Planung',here+':AusSel');
  Lib_GuiCom:RunChildWindow(gMDIBAG);
end;


//========================================================================
// AusSel
//
//========================================================================
sub AusSel();
local begin
  Erx       : int;
  vSel      : int;
  vSel2     : int;
  vSel3     : alpha;
  vSelName  : alpha;
  vQ        : alpha(4000);
  vQ2       : alpha(4000);
  tErx      : int;
  vHdl      : int;
end;
begin
  if (gSelected<>0) then begin
    gSelected # 0;
    gMdiBAG # Lib_GuiCom:OpenMdi(gFrmMain, 'BA1.P.Feinplanung', _WinAddHidden);
    VarInstance(WindowBonus,cnvIA(gMDIBAG->wpcustom));

    // ehemals Selektion 702 'BA1_Planung'
    vQ # '';
    if ( Sel.BAG.Nummer != 0 ) then
      Lib_Sel:QInt( var vQ, 'BAG.P.Nummer', '=', Sel.BAG.Nummer );
    if ( Sel.BAG.Res.Gruppe != 0 ) then
      Lib_Sel:QInt( var vQ, 'BAG.P.Ressource.Grp', '=', Sel.BAG.Res.Gruppe );
    if ( Sel.BAG.Res.Nummer != 0 ) then
      Lib_Sel:QInt( var vQ, 'BAG.P.Ressource', '=', Sel.BAG.Res.Nummer );
    /*if ( Sel.BAG.Level != 0 ) then
      Lib_Sel:QInt( var vQ, 'BAG.P.Level', '<=', Sel.BAG.Level );*/
    Lib_Sel:QAlpha( var vQ, 'BAG.P.Aktion', '!=', c_Akt_VSB );
    Lib_Sel:QDate( var vQ, 'BAG.P.Fertig.Dat', '=', 0.0.0 );
    vQ # vQ + ' AND ( ( BAG.P.Plan.StartDat >= Sel.von.Datum AND BAG.P.Plan.StartDat <= Sel.bis.Datum ) ';
    vQ # vQ + '  OR   ( Sel.BAG.mitUngeplant AND BAG.P.Plan.StartDat = 0.0.0 ) ) ';
    vQ # vQ + ' AND !BAG.P.ExternYN  ';


    Lib_Sel:QAlpha( var vQ2, 'BAG.Löschmarker', '=', '' );
    vQ # vQ + ' AND ( LinkCount(Kopf) > 0) ';

    // Selektion aufbauen...
    vHdl # SelCreate(702, 0);

    // Verknüpfen mit BAG Kopfdaten
    vHdl->SelAddLink('', 700, 702, 1, 'Kopf');

    // nach Level sortieren...
    vHdl->SelAddSortFld(1, 17, _KeyFldAttrUpperCase | _KeyFldAttrReverse );
    tErx # vHdl->SelDefQuery('', vQ);
    tErx # vHdl->SelDefQuery('Kopf', vQ2 );
    if (tErx != 0) then Lib_Sel:QError(vHdl);

    // speichern, starten und Name merken...
    w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);

    // Liste selektieren...
    gZLList->wpDbSelection # vHdl;


    // ggf. VSB-Schritte selektieren
    if (Sel.Auf.von.ZTermin<>0.0.0) then begin

      // ehemals Selektion 700 BA1_PLANUNG
      vQ  # ' LinkCount(Pos) > 0 ';
      vQ2 # ' BAG.P.Typ.VSBYN ';
      Lib_Sel:QVonBisD( var vQ2, 'BAG.P.Plan.StartDat', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );

      // Selektion bauen, speichern und öffnen
      vSel # SelCreate( 700, 1 );
      vSel->SelAddLink('', 702, 700, 1, 'Pos');
      tErx # vSel->SelDefQuery('', vQ );
      tErx # vSel->SelDefQuery('Pos', vQ2 );
      vSelName # Lib_Sel:SaveRun( var vSel, 0);

      vSel2 # $ZL.BA1.Plan->wpDbSelection;
      Erx # RecRead(702,vSel2,_recfirst);
      WHILE (Erx<=_rMultikey) do begin

        BAG.Nummer # BAG.P.Nummer;
        Erx # RecRead(700,vSel,0);
        if (Erx>_rMultiKey) then begin
          SelRecDelete(vSel2,702);
          Erx # RecRead(702,vSel2,0);
          Erx # RecRead(702,vSel2,0);
          CYCLE;
        end;

        Erx # RecRead(702,vSel2,_recNext);
      END;

      SelClose(vSel);             // Selektion schliessen
      SelDelete(700,vSelName);    // temp. Selektion löschen
      vSel  # 0;

    end;

    // Positionen mit Planungslock versehen...
    vSel # cZList->wpDbSelection;
    Erx # RecRead(702,vSel,_RecFirst);
    WHILE (Erx<=_rLocked) do begin

      RecRead(702,1,_recLock);
      BAG.P.PLanLock.UsrID # gUserID;
      BA1_P_Data:Replace(_recUnlock,'MAN');

      Erx # RecRead(702,vSel,_RecNext);
    END;

    gMdiBAG->WinUpdate(_WinUpdOn);
    gMdiWorkbench->Winfocusset(false);
    gMdiBAG->Winfocusset(true);
  end;
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  App_Main:EvtInit(aEvt);
  Mode      # c_modeEdList;
end;


//========================================================================
//  EvtMdiActivate
//                  MDI-Fenster erhält Focus
//========================================================================
sub EvtMdiActivate(
  aEvt  : event;        // Ereignis
) : logic
local begin
  Erx     : int;
  vHdl    : int;
  vTree   : int;
end;
begin

  // 10.11.2014 (war am Ende)
  APP_Main:EvtMdiActivate(aevt);

  if (gzlList->wpDbSelection<>0) then begin
    vTree # CteOpen(_CteTreeCI);
    If (vTree = 0) then RETURN true;

    FOR  Erx # RecRead( 702, gZLList->wpDbSelection, _recFirst );
    LOOP Erx # RecRead( 702, gZLList->wpDbSelection, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      BA1_Plan_Data:BAGNachTree(BAG.P.Nummer, vTree);
    END;

    vHdl # gMDI->WinSearch('lb.BA1.P.Plantree');
    vHdl->wpcustom # cnvai(vTree);
  end;

  RETURN true;
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
  //Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  vTmp : int;
end;
begin

  if (aName='') then gZLList->WinFocusSet(false);

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
sub RecInit() : logic;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
//  ...->WinFocusSet(true);
  RETURN true;
end;


//========================================================================
//  SaveAll
//          Speichert ALLE Positionen am Server
//========================================================================
sub SaveAll() : logic;
local begin
  Erx     : int;
  vSel    : int;
  vOK     : logic;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  if ($Save2->wpcustom='') then RETURN true;

  vSel # cZList->wpDbSelection;

  // Sicherheitscheck...
  vOK # y;
  Erx # RecRead(702,vSel,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (BAG.P.PlanLock.UsrID<>gUserID) then vOK # n;
    Erx # RecRead(702,vSel,_RecNext);
  END;

  If (vOK=n) then
    if (Msg(702015,'',0,0,0)<>_WinIdYes) then RETURN false;


  TRANSON;
  Erx # RecRead(702,vSel,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    RecRead(702,1,_recLock);
    BA1_Plan_Data:HoleTreeDaten($lb.BA1.P.Plantree);
    Erx # BA1_P_Data:Replace(_recUnlock,'MAN');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Msg(999999,'',0,0,0);
      RETURN false;
    end;

    Erx # RecRead(702,vSel,_RecNext);
  END;
  TRANSOFF;

  $Save2->wpcustom # '';

  RefreshMode();

  Msg(999998,'',0,0,0);
  RETURN true;
end;

//========================================================================
//  Refresh
//          Refresht die BA-Uebersicht
//========================================================================
sub Refresh() : logic;
local begin
  Erx     : int;
  vHdl    : int;
  vTree   : int;
  vSel      : int;
  vSel2     : int;
  vSel3     : alpha;
  vSelName  : alpha;
  vQ        : alpha(4000);
  vQ2       : alpha(4000);
  tErx      : int;
end;
begin

  // ---- 2009-08-03 TM> Dialogbox "Bisherige Änderungen Speichern? Ja/Nein/Abbruch ----
  Erx # (Windialogbox(gMdi, 'Refresh', 'Bisherige Änderungen übernehmen?', _WinIcoInformation, _WinDialogYesNoCancel, 2))
  If Erx = _WinIDCancel then begin
    // ---- 2009-08-03 TM> Refresh-Abbruch



    return false;
  end
  else if Erx = _WinIDNo then begin
    // ---- 2009-08-03 TM> Refresh ohne Datenübernahme

  end;

  else if Erx = _WinIDYes then begin
    // ---- 2009-08-03 TM> Refresh ohne Datenübernahme

    SaveAll();
  end;

  // ---- 2009-08-03 TM> Alte Meldung entfernt
  // if(Windialogbox(gMdi, 'Refresh', 'Bei einem Refresh gehen alle momentanen Änderungen verloren!', _WinIcoInformation, _WinDialogOkCancel, 2) = _WinIdCancel) then
  //   return false;

  // ehemals Selektion 702 'BA1_Planung'
  vQ # '';
  if ( Sel.BAG.Nummer != 0 ) then
    Lib_Sel:QInt( var vQ, 'BAG.P.Nummer', '=', Sel.BAG.Nummer );
  if ( Sel.BAG.Res.Gruppe != 0 ) then
    Lib_Sel:QInt( var vQ, 'BAG.P.Ressource.Grp', '=', Sel.BAG.Res.Gruppe );
  if ( Sel.BAG.Res.Nummer != 0 ) then
    Lib_Sel:QInt( var vQ, 'BAG.P.Ressource', '=', Sel.BAG.Res.Nummer );
  if ( Sel.BAG.Level != 0 ) then
      Lib_Sel:QInt( var vQ, 'BAG.P.Level', '<=', Sel.BAG.Level );
  Lib_Sel:QAlpha( var vQ, 'BAG.P.Aktion', '!=', c_Akt_VSB );
  vQ # vQ + ' AND ( ( BAG.P.Plan.StartDat >= Sel.von.Datum AND BAG.P.Plan.StartDat <= Sel.bis.Datum ) ';
  vQ # vQ + '  OR   ( Sel.BAG.mitUngeplant AND BAG.P.Plan.StartDat = 0.0.0 ) ) ';
  vQ # vQ + ' AND !BAG.P.ExternYN  ';
  Lib_Sel:QDate( var vQ, 'BAG.P.Fertig.Dat', '=', 0.0.0 );

  Lib_Sel:QAlpha( var vQ2, 'BAG.Löschmarker', '=', '' );
  vQ # vQ + ' AND ( LinkCount(Kopf) > 0) ';

  // Selektion aufbauen...
  vHdl # SelCreate(702, 0);

  // Verknüpfen mit BAG Kopfdaten
  vHdl->SelAddLink('', 700, 702, 1, 'Kopf');

  // nach Level sortieren...
  vHdl->SelAddSortFld(1, 17, _KeyFldAttrUpperCase | _KeyFldAttrReverse );
  tErx # vHdl->SelDefQuery('', vQ);
  tErx # vHdl->SelDefQuery('Kopf', vQ2 );
  if (tErx != 0) then Lib_Sel:QError(vHdl);

  // speichern, starten und Name merken...
  w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
  // Liste selektieren...
  gZLList->wpDbSelection # vHdl;


  // ggf. VSB-Schritte selektieren
  if (Sel.Auf.von.ZTermin<>0.0.0) then begin

    // ehemals Selektion 700 BA1_PLANUNG
    vQ  # ' LinkCount(Pos) > 0 ';
    vQ2 # ' BAG.P.Typ.VSBYN ';
    Lib_Sel:QVonBisD( var vQ2, 'BAG.P.Plan.StartDat', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );

    // Selektion bauen, speichern und öffnen
    vSel # SelCreate( 700, 1 );
    vSel->SelAddLink('', 702, 700, 1, 'Pos');
    tErx # vSel->SelDefQuery('', vQ );
    tErx # vSel->SelDefQuery('Pos', vQ2 );
    vSelName # Lib_Sel:SaveRun( var vSel, 0);

    vSel2 # $ZL.BA1.Plan->wpDbSelection;
    Erx # RecRead(702,vSel2,_recfirst);
    WHILE (Erx<=_rMultikey) do begin

      BAG.Nummer # BAG.P.Nummer;
      Erx # RecRead(700,vSel,0);
      if (Erx > _rMultiKey) then begin
        SelRecDelete(vSel2,702);
        Erx # RecRead(702,vSel2,0);
        Erx # RecRead(702,vSel2,0);
        CYCLE;
      end;

      Erx # RecRead(702,vSel2,_recNext);
    END;

    SelClose(vSel);             // Selektion schliessen
    SelDelete(700,vSelName);    // temp. Selektion löschen
    vSel  # 0;
  end;


  if (gzlList->wpDbSelection<>0) then begin
    vTree # CteOpen(_CteTreeCI);
    If (vTree = 0) then RETURN true;

    Erx # RecRead(702,gZLList->wpDbSelection,_RecFirst);
    WHILE (Erx<=_rLocked) do begin

      BA1_Plan_Data:BAGNachTree(BAG.P.Nummer, vTree);

      Erx # RecRead(702,gZLList->wpDbSelection,_RecNext);
    END;

    vHdl # gMDI->WinSearch('lb.BA1.P.Plantree');
    vHdl->wpcustom # cnvai(vTree);
    gZLList->WinUpdate(_winupdOn,
                      _WinLstFromFirst | _WinLstRecDoSelect);
    cZList->winfocusset(true);

    $Save2->wpcustom # '';
  end;


end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
end;
begin

  BA1_Plan_Data:RecSave($lb.BA1.P.Plantree);

  Erx # RecRead(702,1,_recunlock);

  mode # c_ModeCancel;
  gZLList->WinUpdate(_winupdOn,
                      _WinLstFromFirst | _WinLstRecDoSelect);
  cZList->winfocusset(true);

  $Save2->wpcustom # 'changed';
  RETURN false;
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
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(gFile,0,'MAN');
  end;
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

/***
  if (aEvt:Obj->wpname='jump') then begin
    case (aEvt:Obj->wpcustom) of
      'Page1Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false)
        end;
      'Page1E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false);
        end;
    end;
    RETURN true;
  end;
***/

  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
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
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

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
    //'...' : begin
    //  RecBufClear(xxx);         // ZIELBUFFER LEEREN
    //  gMDI # Lib_GuiCom:AddChildWindow(gMDI, xxx.Verwaltung',here+':Aus...');
    //  ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    //  Lib_GuiCom:RunChildWindow(gMDI);
    //end;
  end;

end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('Save2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # $Save2->wpcustom='';
  vHdl # gMenu->WinSearch('Mnu.Save2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # $Save2->wpcustom='';

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

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
  vHdl : int;
  vTmp : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Save2' : begin
      SaveAll();
    end;

    'Mnu.Refresh2' : begin
      Refresh();
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);//,xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
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
    'Save2'      : SaveAll();
    'Refresh2'   : Refresh();
    'bt.Refresh' : Refresh();
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
  end;

end;


//========================================================================
//  EvtPageSelect
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
local begin
  vFile     : int;
  vTextName : alpha(200);
  vBildName : alpha(200);
end;
begin

  if (aPage->wpname='NB.Graph') and (aSelecting) then begin

    RecLink(700,702,1,_recFirst);   // Kopf holen

    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
    vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
    vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';

    Mode # c_modeview;

    // Graph deaktivieren
    $Graph->wpcaption # '';
//    BA1_Graph:BuildText(vTextName);

    BA1_Graph:BuildText2(vTextName, $lb.BA1.P.Plantree);

    //SysExecute(set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
    SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);

    $Graph->wpcaption # '*'+vBildName;
  end;

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
local begin
  vTmp : int;
end;
begin

  if (aEvt:obj=gZLList) then begin
  //  RecRead(gFile,0,_recid,aRecID);
    BA1_Plan_Data:HoleTreeDaten($lb.BA1.P.Plantree);

    GV.Alpha.01 # cnvai(BAG.P.Nummer)+'/'+cnvai(BAG.P.Position);
    GV.Alpha.04 # BAG.P.Bezeichnung;
    if (BAG.P.Level>1) then
      Gv.Alpha.04 # StrChar(32,(BAG.P.Level*3)-3)+BAG.P.Bezeichnung;

/*
    if (s_BA_Plan_MinDat<>0.0.0) then begin
      BAG.P.Fenster.MinDat # s_BA_Plan_MinDat;
      BAG.P.Fenster.MinZei # s_BA_Plan_MinZeit;
    end;
    if (s_BA_Plan_MaxDat<>0.0.0) then begin
      BAG.P.Fenster.MaxDat # s_BA_Plan_MaxDat;
      BAG.P.Fenster.MaxZei # s_BA_Plan_MaxZeit;
    end;
*/
    if (BAG.P.Fenster.MinDat<>0.0.0) then
      GV.Alpha.02 # cnvad(BAG.P.Fenster.MinDat) + ' ' + cnvat(BAG.P.Fenster.MinZei)
    else
      GV.alpha.02 # '';

    if (BAG.P.Fenster.MaxDat<>0.0.0) then
      GV.Alpha.03 # cnvad(BAG.P.Fenster.MaxDat) + ' ' + cnvat(BAG.P.Fenster.MaxZei)
    else
      GV.alpha.03 # '';

    vTmp # BA1_Plan_data:PlanTerminOK();
    if (vTmp<>0) then begin
      $clmBAG.P.Plan.StartDat->wpClmColBkg      # _WinColLightRed;
      $clmBAG.P.Plan.StartDat->wpClmColFocusBkg # _WinColLightRed;
      end
    else begin
      $clmBAG.P.Plan.StartDat->wpClmColBkg      # _WinColLightYellow;
      $clmBAG.P.Plan.StartDat->wpClmColFocusBkg # _WinColLightYellow;
    end;

    RETURN;
  end;

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

  BA1_Plan_Data:HoleTreeDaten($lb.BA1.P.Plantree);

  $RL.BA1.Plan.In->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);
  $RL.BA1.Plan.Fert->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);

//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx   : int;
  vSel  : int;
  vX    : int;
end;
begin

  // Sicherheitsabfrage...
  if ($Save2->wpcustom<>'') then begin
    vX # Msg(702016,'',_WinIcoQuestion,_WinDialogYesNoCancel,3);
    if (vX=_WinIdCancel) then RETURN false;
    if (vX=_WinIdYes) then begin
      if (SaveALL()=false) then RETURN false;
    end;
  end;


  // Baum löschen?
  BA1_Plan_Data:CleanUp($lb.BA1.P.Plantree);

  vSel # cZList->wpDbSelection;
  Erx # RecRead(702,vSel,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.PlanLock.UsrID=gUserID) then begin
      RecRead(702,1,_recLock);
      BAG.P.PLanLock.UsrID # 0;
      BA1_P_Data:Replace(_recUnlock,'MAN');
    end;

    Erx # RecRead(702,vSel,_RecNext);
  END;

  RETURN true;
end;
/*
//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect     : rect;
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  if (aFlags & _WinPosSized != 0) then begin
    vRect           # gZLList->wpArea;
    vRect:right     # (aRect:right-aRect:left-4 - 60) / 2;
    vRect:bottom    # (aRect:bottom-aRect:Top-28);
    gZLList->wparea # vRect;
    /*
    // Überschrift setzen
    Lib_GUiCom:ObjSetPos($LB.List1, (aRect:right-aRect:left-50) / 2, 50);

    RecRead(gFile,0,0,gZLList->wpdbrecid);


    vRect           # cZList2->wpArea;
    vRect:left      # (aRect:right-aRect:left-50) / 2;
    vRect:right     # (aRect:right-aRect:left-4);
    vRect:bottom    # (aRect:bottom-aRect:Top-28);
    cZList2->wparea # vRect;

    // MS 16.02.2010 Auto-Anpassung des Infosfensters "List3"
    vRect           # cZList3->wpArea;
    vRect:right     # (aRect:right-aRect:left-4);
    vRect:bottom    # (aRect:bottom-aRect:Top-28);
    cZList3->wparea # vRect;

    vTmp # WinSearch(gMDI,'RL.Info.Pos');
    vTmp->Winupdate(_WinUpdOn, _WinLstFromFirst);


//    Lib_GUiCom:ObjSetPos($lb.Mat.Info2, 0, vRect:bottom+8+28);
  */
    vTmp->Winupdate(_WinUpdOn, _WinLstFromFirst);

  end;



	RETURN (true);
end;
*/


//========================================================================
//========================================================================
//========================================================================
//========================================================================