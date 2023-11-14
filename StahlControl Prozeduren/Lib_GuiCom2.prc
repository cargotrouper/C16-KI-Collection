@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_GuiCom2
//                                OHNE E_R_G
//  Info
//
//  02.07.2012  AI  Erstellung der Prozedur
//  02.04.2013  AI  NEW: CreateObjFrom
//  19.09.2013  AH  NEU: InhaltFalsch, InhaltFehlt
//  31.10.2014  AH  Neu: InvertCheck
//  09.06.2017  ST  Edit: AppOn/Off nicht für SOA
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  02.03.2020  AH  Appoff/On deaktiviert die Bindung der zugriffslisten
//  27.07.2021  AH  ERX
//  2022-07-04  AH  "Underline", "JumpToWindow"
//
//  Subprozeduren
//    SUB OpenMultiMDI(aPar : int; aName : alpha; aMode : int) : int;
//    SUB TryCloseMdi(aMDI : int) : logic
//    SUB CloseAll();
//    SUB RefreshList(aList : int; aOpt : int);
//    SUB CreateObjFrom(aSource : int; aParent : int; aName : alpha; aCapt : alpha; aJust : int; opt aLeft : int; opt aWidth : int; opt aTop : int; opt aHeight : int) : int;
//    SUB InhaltFehlt(aName : alpha; aPage : alpha; aFeld : alpha);
//    SUB InhaltFalsch(aName : alpha; aPage : alpha; aFeld : alpha);
//    SUB GetDbVarHandle(aMDI : int; opt aName : alpha) : int;
//    SUB DoAppOn()
//    SUB DoAppOn()
//    SUB DoSetFocus(aObj : int; aFlag : logic) : logic;
//    SUB SetCheckBox(aHdl : int; aChecked  : logic);
//    SUB Hide(aPar : int; aVon : alpha; opt aBis : alpha);
//    SUB FindMdiByName(aName : alpha) : int
//    SUB Underline
//    SUB JumpToWindow
//
//========================================================================
@I:Def_Global

define begin
//  cLayerOn(a) : begin WinEvtProcessSet(_WinEvtLstDataInit, false); WinLayer(_WinLayerStart, gFrmMain, 30000, a, _WinLayerDarken); end;
//  cLayerOff   : begin WinEvtProcessSet(_WinEvtLstDataInit, true);  WinLayer(_WinLayerEnd); end;
end;

declare GetDbVarHandle(aMDI : int; opt aName : alpha) : int;


//========================================================================
//  OpenMultiMDI
//========================================================================
Sub OpenMultiMDI(
  aPar  : int;
  aName : alpha;
  aMode : int) : int;
local begin
  vMdi    : int;
  vVar    : int;
  vHdl    : int;
  vHdl2   : int;
  vName   : alpha;
  vActMDI : int;
end;
begin
  vActMDI # gMDI;
  vVar # VarInfo(WindowBonus);

  WinEvtProcessSet(_winevtall,n);
  WinEvtProcessSet(_WinEvtInit,y);
  WinEvtProcessSet(_WinEvtMdiActivate,y);
  WinEvtProcessSet(_WinEvtCreated,y);
  WinEvtProcessSet(_WinEvtFocusInit,y);

  // ggf. anderes Objekt benutzen
  vName # Lib_Guicom:GetAlternativeName(aName);

  vMdi # WinAddByName(gFrmMain, vName, aMode);
  if (vMDI<=0) then begin
    vMdi # WinAddByName(gFrmMain, aName, aMode);
    if (vMDI<=0) then begin
      TODO('DIALOG '+aName+' NICHT GEFUNDEN!');
      WinHalt();
    end;
  end;

  Help_Main:AddButton(aName, vMDI);

  if (vMdi->winsearch('*Windowsbar') > 0) then begin
    vHdl # vMdi->winsearch('*Windowsbar');
    vHdl->wpFloatable # false;
  end;
  // --------

  vHdl # vMdi->winsearch('NB.Main');
  if (vHdl<>0) then begin
    vHdl2 # vMdi->winsearch('NB.List');
    if (vHdl2<>0) then vHdl->wpcurrent # 'NB.List';
  end;
  WinEvtProcessSet(_winevtall,y);

  if (aPar<>0) and (aPar<>gFrmMain) then w_Parent # vMdi;

  // Aufrufer merken
  if (vActMDI<>gMdiMenu) and
    (vActMDI<>gMdiNotifier) and
    (vActMDI<>gMdiWorkbench) then w_AufruferMDI # vActMDI;

  Lib_GuiCom:RecallWindow(vMdi); // Usersettings wiederherstellen

  varInstance(WindowBonus, vVar);
  if (aPar<>0) and (aPar<>gFrmMain) then w_Child # vMdi;

  CteInsertItem(gMDIList, aint(vMDI), 0, aName);

  RETURN vMdi;
end;



//========================================================================
//========================================================================
sub FindLastChild() : int;
local begin
  vFocus : int;
end;
begin
  if (VarInfo(Windowbonus)=0) then RETURN 0;
  
  WHILE (w_child<>0) do begin
    if (HdlInfo(w_child,_hdlExists)=0) then BREAK;

    if (cnvia(w_Child->wpcustom)=0) then BREAK;
    vFocus # w_Child;
    VarInstance(Windowbonus, cnvia(w_child->wpcustom));
    if (VarInfo(Windowbonus)=0) then BREAK;
  END;
  RETURN vFocus;
end;


//========================================================================
//  TryCloseMdi
//
//========================================================================
sub TryCloseMdi(
  aName : alpha;
  aMDI  : int;
  aTest : logic) : logic
local begin
  vTmp    : int;
  vFocus  : int;
  vHdl    : int;
end;
begin

  if (aMDI=0) then RETURN true;
//if (aTest=false) then debugx('tryclose '+aName);
  if (HdlInfo(aMDI, _HdlExists)=0) then begin
//debugx('err');
DbaLog(_LogError, N, 'aMDI hat alten Inhalt bei '+here);
    RETURN true;
  end;


  vHdl # cnvia(aMDI->wpcustom);
  if (vHdl=0) then begin
    vHdl # getDbVarHandle(aMDI);
    if (vHdl=0) then begin
//debugx('err');
Lib_Debug:Protokoll('!!!DEBUG_ENDE',aName,'=0');
      RETURN false;
    end;
  end;

  vTmp # VarInfo(Windowbonus);
  VarInstance(Windowbonus, vHdl);

  // Dieses Fenster hat falschen Modus
  if (mode<>c_ModeClose) and (mode<>c_ModeList) and (mode<>c_ModeEdList) and (Mode<>c_ModeView) and (Mode<>'') then begin
    vFocus # aMDI;
    if (vTmp<>0) and (HdlInfo(vTmp,_HdlExists)>0) then VarInstance(Windowbonus, vTmp);    // 03.03.2021
    if (vFocus<>0) then vFocus->WinUpdate(_WinUpdActivate);
//    if (aTest=false) then Msg(99,'komischer Modus :'+mode,0,0,0); 24.03.2021 AH, Schließen NICHT erlauben aber keine MEldung
    RETURN false;
  end;

  if (w_child<>0) then begin
    vFocus # FindLastChild();
    if (vTmp<>0) and (HdlInfo(vTmp,_HdlExists)>0) then VarInstance(Windowbonus, vTmp);  // 03.03.2021
    if (vFocus<>0) then
      vFocus->WinUpdate(_WinUpdActivate);
    Msg(998014,'',0,0,0);
    RETURN false;
  end;
  
  if (aTest) then begin // soweit OK
    if (vTmp<>0) and (HdlInfo(vTmp,_HdlExists)>0) then VarInstance(Windowbonus, vTmp);    // 03.03.2021
    RETURN true;
  end;

  
  // in Übersichtsliste und keine Kinder? -> Schliessen
    Mode # c_ModeClose; // 25.11.2015
//if (aTest=false) then debugx('bonus '+w_name+' '+aMdi->wpname);
    aMDI->WinClose();
//    if (aMDI->WinClose()) then
//debug('closing '+aName+' = true');
//else
//debug('closing '+aName+' = FALSE');
    if (vTmp<>0) and (HdlInfo(vTmp,_HdlExists)>0) then  // 23.02.2021 AH
      VarInstance(Windowbonus, vTmp);
    RETURN true;

end;
//Lib_Debug:Protokoll('!!!DEBUG_ENDE',aName,'Child active');



//========================================================================
//  CloseAll
//
//========================================================================
sub CloseAll(aTest : logic) : logic
local begin
  vOK     : logic;
  vTmp    : int;
  vFocus  : int;
end;
begin
//  gMdiMenu
//  gMdiWorkbench
  if (TryCloseMdi('Adr',gMdiAdr           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Mat',gMdiMat           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Auf',gMdiAuf           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Ein',gMdiEin           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Bdf',gMdiBdf           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('LFS',gMdiLFS           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('VsP',gMdiVsP           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Prj',gMdiPrj           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('BAG',gMdiBAG           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Gantt',gMdiGantt       ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Msl',gMdiMsl           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('QS',gMdiQS             ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Erl',gMdiErl           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('EKK',gMDIEKK           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Ofp',gMDIOfp           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Ere',gMDIERe           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Usr',gFrmUsr           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Para',gMdiPara         ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Kal',gMdiRsoKalender   ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Rso',gMdiRso           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Art',gMdiArt           ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Math',gMdiMathCalculator,aTest)=false) then RETURN false;
  if (TryCloseMdi('Math1',gMdiMath          ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Math2',gMdiMathVar       ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Math3',gMdiMathAlphabet  ,aTest)=false) then RETURN false;
  if (TryCloseMdi('Math4',gMdiMathVarMiniPrg,aTest)=false) then RETURN false;
  if (TryCloseMdi('Not',gMdiNotifier      ,aTest)=false) then RETURN false;

  RETURN true;
end;


//========================================================================
//  RefreshList
//
//========================================================================
sub Refresh_List(aList : int; aOpt : int);
begin
  if (aList=0) then RETURN;
  TRY begin
    ErrTryCatch(_ErrHdlInvalid,y);
    aList->winupdate(_winupdon, aOpt);
  end;
end;


//========================================================================
//  sub CreateObjFrom
//========================================================================
SUB CreateObjFrom(
  aSource     : int;
  aTyp        : int;
  aParent     : int;
  aName       : alpha;
  aCapt       : alpha;
  aJust       : int;
  opt aLeft   : int;
  opt aWidth  : int;
  opt aTop    : int;
  opt aHeight : int;
  opt aNext   : int;
  ) : int;
local begin
  vNew  : int;
  vTyp  : int;
end;
begin

  if (aTyp=0) then
    aTyp  # Wininfo(aSource, _wintype);

  case (aTyp) of
    _wintypeEdit, _wintypeFloatedit, _wintypeIntEdit, _wintypeDateEdit, _wintypeTimeEdit : vTyp # _WinTypeEdit;
    otherwise
      vTyp # aTyp;
  end;


  vNew # WinCreate(aTyp, aName, aCapt, aParent, aNext);
  vNew->wpfont        # aSource->wpfont;
  if (aJust<>0) then begin
    if (vTyp=_WinTypeLabel) then
      vNew->wpJustify     # aJust;
    if (vTyp=_WinTypeButton) or (vTyp=_WinTypeEdit) then
      vNew->wpJustifyView # aJust;
  end;

  if (vTyp=_wintypeEdit) then begin
    vNew->WinEvtProcNameSet(_WinEvtFocusInit, aSource->winEvtProcNameget(_WinEvtFocusInit));
    vNew->WinEvtProcNameSet(_WinEvtFocusTerm, aSource->winEvtProcNameget(_WinEvtFocusterm));
    vNew->wpInputMode # aSource->wpInputMode;
    vNew->wpFmtOutput # aSource->wpFmtOutput;
    if (aTyp=_WintypeIntEdit) then
      vNew->wpFmtIntFlags  # aSource->wpFmtIntFlags
    else if (aTyp=_WintypeFloatEdit) then
      vNew->wpFmtFloatFlags  # aSource->wpFmtFloatFlags;
  end;
  if (vTyp=_wintypeButton) then begin
    vNew->WinEvtProcNameSet(_WinEvtClicked, aSource->winEvtProcNameget(_WinEvtClicked));
    vNew->wpImageTile       # aSource->wpImageTile;
    vNew->wpImageTileUser   # aSource->wpImageTileUser;
    vNew->wpImageOption     # aSource->wpImageOption;
    vNew->wpIcon            # aSource->wpIcon;
    vNew->wpTileSize        # aSource->wpTileSize;
    vNew->wpTabStop         # aSource->wpTabStop;
  end;

  if (vTyp<>_winTypeButton) then
    vNew->wpJustifyVert # aSource->wpJustifyVert;
//  vNew->wpStyleBorder # _WinBorSunken;

  vNew->wparea        # aSource->wparea;
  if (aLeft<>0) or (aWidth<>0) then begin
    vNew->wpareaLeft    # aLeft;
    vNew->wparearight   # aLeft+aWidth;
  end;
  if (aTop<>0) or (aHeight<>0) then begin
    vNew->wpareaTop     # aTop;
    vNew->wpareaBottom  # aTop+aHeight;
  end;

  RETURN vNew;
end;


//========================================================================
//========================================================================
sub InhaltFehlt(
  aName : alpha;
  aPage : alpha;
  aFeld : alpha);
local begin
  vNB   : int;
  vPage : int;
  vHdl  : int;
end;
begin

  vNB # gMdi->Winsearch('NB.Main');

  Msg(001200,Translate(aName),0,0,0);

  vPage # Winsearch(vNB, aPage);
  if (vPage<>0) then begin
    vNB->wpcurrent # aPage;
    vHdl # Winsearch(vPage, aFeld);
    if (vHdl<>0) then begin
      vHdl->WinFocusSet(true);
      RETURN;
    end;
    if (gFile=401) or (gFile=411) then begin
      vHdl # Winsearch(vPage, aFeld+'_Mat');
      if (vHdl<>0) then begin
        vHdl->WinFocusSet(true);
        RETURN;
      end;
    end;
  end;

end;


//========================================================================
//========================================================================
sub InhaltFalsch(
  aName : alpha;
  aPage : alpha;
  aFeld : alpha);
local begin
  vNB   : int;
  vPage : int;
  vHdl  : int;
end;
begin

  vNB # gMdi->Winsearch('NB.Main');

  Msg(001201,Translate(aName),0,0,0);

  vPage # Winsearch(vNB, aPage);
  if (vPage<>0) then begin
    vNB->wpcurrent # aPage;
    vHdl # Winsearch(vPage, aFeld);
    if (vHdl<>0) then begin
      vHdl->WinFocusSet(true);
      RETURN;
    end;
    if (gFile=401) or (gFile=411) then begin
      vHdl # Winsearch(vPage, aFeld+'_Mat');
      if (vHdl<>0) then begin
        vHdl->WinFocusSet(true);
        RETURN;
      end;
    end;
  end;

end;


//========================================================================
//========================================================================
sub TryWinFocusSet(
  aObj      : int;
  opt aAct  : logic);
begin
  if (aObj=0) then RETURN;

  TRY begin
    ErrTryIgnore(_ErrHdlInvalid);
    aObj->winFocusset(aAct);
  END;
  Errget();

  RETURN;
end;


//========================================================================
//  GetDbVarHandle
//      Holt den Handle eines MDIs für einen globalen Datenbereich - bei LEER, den Windowbonus
//========================================================================
sub GetDbVarHandle(
  aMDI      : int;
  opt aName : alpha) : int;
local begin
  vI    : int;
end;
begin

  if (aName='') then
    aName # 'Def_Global:WindowBonus';
  aName # StrCnv(aName, _StrUpper);

  vI # aMDI + 1;
  WHILE (vI <= aMDI + 100) do begin

    // Prüfen, ob es sich um einen Variablenbereichsdeskriptor handelt
    if (HdlInfo(vI,_HdlType) = _HdlDataSpace) then begin
      if (StrCnv(VarName(vI),_strupper)=aName) then RETURN vI;
    end;

    Inc(vI);
  END;

  RETURN 0;
end;


//========================================================================
//========================================================================
sub DoAppOff(opt aWait : logic)
local begin
  vMsg  : int;
end;
begin
  if (gUsername='FILESCANNER') then RETURN;
  if (gUsergroup='SOA_SERVER') then RETURN;
  if (StrCut(gUsername,1,3)='SOA') then RETURN;
  if (gFrmMain=0) then RETURN;

  if (gPause=0) and (aWait) then begin
    gPause # WinOpen('Dlg.Pause',_WinOpenDialog);
    vMsg # Winsearch(gPause,'icon1');
    vMsg->wpvisible # false;
//    vMsg->wpcustom # aint(WinFocusGet(Windowbonus));

    vMsg # Winsearch(gPause,'Label1');
    vMsg->wpcaption # Translate('berechne...');
    vMsg->wpcustom  # aint(gMDI);

    gPause->WinDialogRun(_WinDialogAsync | _WinDialogCenterScreen, gMDI);//, gFrmMain);
  end
  else begin
//    cLayerOn('Berechne...');
    // Flag setzen
    _App->wpFlags # _App->wpFlags | _WinAppRecFocusTermResetOff;
    // Flag entfernen
//    _App->wpFlags # _App->wpFlags & ~_WinAppRecFocusTermResetOff;
  end;

  
  WinEvtProcessSet(_WinEvtTimer, false);    // 15.04.2021 AH
  gFrmMain->wpdisabled # y;
end;


//========================================================================
//========================================================================
sub DoAppOn()
local begin
  vMDI  : int;
  vHdl  : int;
end;
begin
  if (gUsername='FILESCANNER') then RETURN;
  if (gUsergroup='SOA_SERVER') then RETURN;
  if (StrCut(gUsername,1,3)='SOA') then RETURN;
  if (gFrmMain=0) then RETURN;

  if (gPause<>0) then begin
    vHdl # VarInfo(Windowbonus);
    vMdi # Winsearch(gPause,'label1');
    vMdi # cnvia(vMdi->wpcustom);

    if (vMDI<>0) then vMDI->WinUpdate(_WinUpdFld2Buf);

//_App->wpFlags # _App->wpFlags | _WinAppFld2BufOff;
    gPause->winclose();
//_App->wpFlags # _App->wpFlags & ~_WinAppFld2BufOff;
    gPause # 0;
  end
  else begin
//    cLayerOff;
    _App->wpFlags # _App->wpFlags & ~_WinAppRecFocusTermResetOff;
  end;

  gFrmMain->wpdisabled # n;
  WinEvtProcessSet(_WinEvtTimer, true);   // 15.04.2021 AH

    if (vHdl<>0) then
      VarInstance(WindowBonus, vHdl);
    if (vMdi<>0) then begin
      Winupdate(vMdi, _winUpdActivate);
//debug('fix');
//      RecBufCopy(vMDI->wpDbRecBuf(702), 702);
    end;

end;


//========================================================================
// DoSetFocus
//
//========================================================================
sub DoSetFocus(
  aObj          : int;
  aFlag         : logic) : logic;
local begin
  vType         : int;
end;
begin
  if (aObj=0) then RETURN false;
  aObj->WinFocusSet(aFlag);
  vType # Wininfo(aObj,_Wintype);
  if (vType=_WintypeEdit) or (vType=_WinTypeFloatEdit) or
      (vType=_WinTypeIntEdit) or (vType=_WinTypeTimeEdit) or (vType=_WinTypeBigIntEdit) or
      (vType=_WinTypeTextEdit) or (vType=_WinTypeDateEdit)  then begin
    aObj->wprange # RangeMake(0,-1);
  end;
  RETURN true;
end;


//========================================================================
//========================================================================
sub  _SwitchEvent(
  aObj  : int;
  aEvt  : int;
  aVon  : alpha;
  aNAch : alpha);
local begin
  vA    : alpha;
end;
begin

//debug(aObj->wpname+' : '+aint(aEvt));
  vA # WinEvtProcNameGet(aObj, aEvt);
  if (vA='') then RETURN;

  if (StrCnv( StrCut(vA, 1, StrLen(aVon)) , _StrUpper) = aVon) then begin
    vA # StrCut(vA, StrLen(aVon)+1, 100);
    vA # aNach + vA;
    WInEvtProcNameSet(aObj, aEvt, vA);
  end;
end;


//========================================================================
//========================================================================
Sub SwitchAllEvents(
  aObj  : int;
  aVon  : alpha;
  aNach : alpha);
local begin
  vI    : int;
  vObj  : int;
end;
begin
  aVon # StrCnv(aVon, _strUpper);

  _SwitchEvent(aObj,_WinEvtAdviseDDE         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtAttachState       , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtChanged           , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtChangedActive     , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtChangedChild      , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtChangedDesign     , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtClicked           , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtClose             , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtCreated           , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtCtxEvent          , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtDbFldUpdate       , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtDragInit          , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtDragTerm          , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtDrop              , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtDropEnter         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtDropLeave         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtFocusCancel       , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtFocusInit         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtFocusTerm         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtFsiMonitor        , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtHyphenate         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtInit              , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtIvlDropItem       , aVon, aNach);    // 20
//  _SwitchEvent(aObj,_WinEvtIvlDropItemOverlap, aVon, aNach);  // -20
  _SwitchEvent(aObj,_WinEvtJob               , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtKeyItem           , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstDataInit       , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstEditActivate   , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstEditCommit     , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstEditEndGroup   , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstEditEndItem    , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstEditFinished   , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstEditStart      , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstEditStartGroup , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstEditStartItem  , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstGroupArrange   , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstGroupInit      , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstRecControl     , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstSelect         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstSelectRange    , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtLstViewInit       , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtMdiActivate       , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtMenuCommand       , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtMenuContext       , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtMenuInitPopup     , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtMenuPopup         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtMouse             , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtMouseItem         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtMouseMove         , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtNodeExpand        , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtNodeSearch        , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtNodeSelect        , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtPageSelect        , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtPosChanged        , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtSocket            , aVon, aNach);  // 33
//  _SwitchEvent(aObj,_WinEvtSystem            , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtTapi              , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtTerm              , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtTimer             , aVon, aNach);
  _SwitchEvent(aObj,_WinEvtUser              , aVon, aNach);

  FOR vObj # Wininfo(aObj, _WinFirst)
  LOOP vObj # Wininfo(vObj, _WinNext)
  WHILE (vObj<>0) do begin
    SwitchAllEvents(vObj, aVon, aNach);
  END;

end;


//========================================================================
//  SetChechBox
//========================================================================
sub SetCheckBox(
  aHdl      : int;
  aChecked  : logic);
begin
  if (aHdl=0) then RETURN;
  if (aChecked) then aHdl->wpCheckState # _WinStateChkChecked
  else aHdl->wpCheckState # _WinStateChkUnChecked;
end;


//========================================================================
//========================================================================
sub Hide(
  aPar      : int;
  aVon      : alpha;
  opt aBis  : alpha;
  opt aShow : logic);
local begin
  vHdl  : int;
end;
begin
  vHdl # Winsearch(aPar, aVon);
  if (vHdl=0) then RETURN;

  if (aBis<>'') then begin
    WHILE (vHdl<>0) and (vHdl->wpName<>aBis) do begin
      vHdl->wpVisible # aShow;
      vHdl # Wininfo(vHdl, _winNext);
    END;
  end;

  if (vHdl<>0) then
    vHdl->wpVisible # aShow;

end;


//========================================================================
//========================================================================
sub JumpPageObj(
  aPage         : alpha;
  opt aRichtung : int;
  opt aObj      : int);
local begin
  vHdl        : int;
  vHdl2       : int;
  vTyp        : int;
  vNB         : int;
end;
begin
  if (aObj=0) then aObj # gMDI;

  vHdl # WinSearch(aObj, aPage);
  if (vHdl=0) then RETURN;
  if (aRichtung=0) then aRichtung # 1;

  vNB # WinSearch(gMDI, 'NB.Main');

  if (aRichtung<0) then
    vHdl2 # WinInfo(vHdl, _WinLast)
  else
    vHdl2 # WinInfo(vHdl, _WinFirst);

  WHILE (vHdl2<>0) do begin
    vTyp # WinInfo(vHdl2,_wintype);

    if (vTyp=_WinTypeEdit) or (vTyp=_WinTypeIntEdit) or (vTyp=_WinTypeDateEdit) or (vTyp=_WinTypeTimeEdit) or
      (vTyp=_WinTypeFloatEdit) or (vTyp=_WinTypeCheckBox) or (vTyp=_WinTypeBigIntEdit) then begin
      if (vHdl2->wpname<>'jump') and
        (vHdl2->wpVisible) and (vHdl2->wpDisabled=false) then begin
        // Seitenwechsel?
        if (vNB<>0) and (vNB->wpCurrent<>aPage) then begin
          JumpPageObj(vNB->wpCurrent, -aRichtung);
          vNB->wpCurrent # aPage;
        end;
        vHdl2->winFocusSet(false);
        RETURN;
      end;

    end;

    if (aRichtung<0) then
      vHdl2 # WinInfo(vHdl2, _WinPrev)
    else
      vHdl2 # WinInfo(vHdl2, _WinNext);
  END;

end;


//========================================================================
//========================================================================
sub FindColumn(
  aDL   : int;
  aName : alpha) : int;
local begin
  vCol  : int;
  vI    : int;
  vOP   : int;
end;
begin

  vOP # aDL->wpOrderPass;
  aDL->wpOrderPass # _WinOrderCreate;
  FOR vCol # aDL->WinInfo(_WinFirst)
  LOOP  vCol # vCol->WinInfo(_WinNext)
  WHILE (vCol>0) do begin
    vI # vI + 1;
    if (vCol->wpName=^aName) then begin
      aDL->wpOrderPass # vOP;   // 19.07.2019
      RETURN vI;
    end;
  END;

  aDL->wpOrderPass # vOP;       // 19.07.2019
  RETURN 0;
end;


//========================================================================
//========================================================================
sub SetMdiAsChild(
  aMdi  : int;
  aPar  : int);
local begin
  vHdl  : int;
  vHdl2 : int;
end;
begin
  vHdl # VarInfo(Windowbonus);
  vHdl2 # lib_Guicom2:GetDbVarHandle(aMdi);
  VarInstance(WindowBonus,vHdl2);
  w_AufruferMdi # aPar;
  VarInstance(WindowBonus,vHdl);
end;


//========================================================================
//========================================================================
sub CloseAllChilds(aMdi : int)
local begin
  vHdl  : int;
  vMdi  : int;
  vNext : int;
  vHdl2 : int;
end;
begin
  vHdl # VarInfo(Windowbonus);
  vMdi # Wininfo(gFrmMain,_Winfirst,1,_WinTypeMdiFrame)
  WHILE (vMdi>0) do begin
    vNext # Wininfo(vMdi,_WinNext,1,_WinTypeMdiFrame)
    vHdl2 # lib_Guicom2:GetDbVarHandle(vMdi);
    VarInstance(WindowBonus,vHdl2);
    if (w_AufruferMdi=aMDI) then begin
      vMDi->wpStyleCloseBox # true;
      vMdi->winclose();
    end;
    vMdi # vNext;
  END;
  VarInstance(WindowBonus,vHdl);
end;


//========================================================================
sub GetQBMenuItem(
  aMenu : int;
  aName : alpha) : int
local begin
  vTmp  : int;
end
begin
  if (aMenu=0) then RETURN 0;
  vTmp # aMenu->WinSearch(aName);
  if (vTmp <> 0) then begin
    if (vTmp->wpdisabled=false) then RETURN vTmp;
  end;
  if (aName='Mnu.Edit2') then begin
    vTmp # aMenu->WinSearch('Mnu.Edit');
    if (vTmp <> 0) then begin
      if (vTmp->wpdisabled=false) then RETURN vTmp;
    end;
  end
  else if (aName='Mnu.Edit') then begin
    vTmp # aMenu->WinSearch('Mnu.Edit2');
    if (vTmp <> 0) then begin
      if (vTmp->wpdisabled=false) then RETURN vTmp;
    end;
  end
  else if (aName='Mnu.New2') then begin
    vTmp # aMenu->WinSearch('Mnu.New');
    if (vTmp <> 0) then begin
      if (vTmp->wpdisabled=false) then RETURN vTmp;
    end;
  end
  else if (aName='Mnu.New') then begin
    vTmp # aMenu->WinSearch('Mnu.New2');
    if (vTmp <> 0) then begin
      if (vTmp->wpdisabled=false) then RETURN vTmp;
    end;
  end;

  RETURN 0;
end;


//========================================================================
sub RefreshQB(opt aMenu : int)
local begin
  vI    : int;
  vHdl  : int;
  vHdl2 : int;
end;
begin
  if (aMenu=0) then aMenu # gMenu;
  
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=10) do begin
    vHdl # Winsearch(gMDi, 'bt.Quick'+aint(vI));
    if (vHdl<>0) and (vHdl->wpVisible) then begin
      vHdl2 # GetQBMenuItem(aMenu, vHdl->wpcustom);
//debugx(vHdl->wpName+':'+vHdl->wpcustom+':'+aint(vHdl2));
      if (vHdl2<>0) then begin
        vHdl->wpdisabled # vHdl2->wpDisabled;
      end
      else begin
//        vHdl->wpcaption # 'nix'
        vHdl->wpdisabled # true;
      end;
    end;
  END;
end;


//========================================================================
// FindMdiByName
//========================================================================
sub FindMdiByName(aName : alpha) : int
local begin
  Erx   : int;
  vHdl  : int;
end;
begin
  aName # StrCnv(Lib_GuiCom:GetAlternativeName(aName),_strUpper);

  FOR  vHdl # gFrmMain->WinInfo(_WinFirst, 1, _WinTypeMdiFrame);
  LOOP vHdl # vHdl->WinInfo(_WinNext, 1, _WinTypeMdiFrame)
  WHILE (vHdl > 0) do begin
    if (StrCnv(vHdl->wpname,_StrUpper)=aName) then RETURN vHdL;
  END;
  
  RETURN 0;
end;


/*========================================================================
2022-07-04  AH
        Setzt den Font eines Gui-Objekt auf Underline
========================================================================*/
SUB Underline(aObj : int)
local begin
  vFont : font;
end;
begin
  if (aObj=0) then RETURN;
  vFont # aObj->wpFont;
  vFont:Attributes # vFont:Attributes | _WinFontAttrUnderline;
  aObj->wpFont # vFont;
end;


/*========================================================================
2022-07-04  AH
      Startet ein Kindfenster
========================================================================*/
sub JumpToWindow(aName : alpha; opt aQ : alpha(1000))
begin
  gMDI # Lib_GuiCom:AddChildWindow(gMDI, aName,'',y);
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  if (aQ <> '') then
    Lib_Sel:QRecList(0, aQ);
   
  Lib_GuiCom:RunChildWindow(gMDI);
end;

    
/*========================================================================
2022-09-14  AH
      Positioniert ALLE MDIs im sichtbaren AppFrame
========================================================================*/
sub Mdis.Reset();
local begin
  vMaxX   : int;
  vMaxY   : int;
  vMDI    : int;
  vW,vH   : int;
  vRect   : rect;
  vRePos  : logic;
end;
begin

  if (HdlInfo(gFrmMain,_HdlExists)=0) then RETURN;
  vMaxX # gFrmMain->wpareaWidth;
  vMaxY # gFrmMain->wpareaHeight;
  
  FOR vMdi # Wininfo(gFrmMain, _Winfirst, 1, _WinTypeMdiFrame )
  LOOP vMdi # Wininfo(vMDI, _WinNext, 1, _WintypeMdiFrame)
  WHILE (vMDI<>0) do begin
    vRect # vMDI->wpArea;

    vW # vRect:Right - vRect:Left;
    vH # vRect:Bottom - vRect:Top;
    vRepos # false;
//debugx(aint(vRect:Right)+'>'+aint(vMaxX));
    if (vRect:Right>vMaxX) then begin
      vRect:Left # vMaxX - vW;
      vRepos # true;
    end;
//debugx(aint(vRect:Bottom)+'>'+aint(vMaxY));
    if (vRect:bottom>vMaxY) then begin
      vRect:Top # vMaxY - vH;
      vRepos # true;
    end;

    if (vRePos=false) then begin
      if (vRect:Left<0) then begin
        vRect:Left # 0;
        vRePos # true;
      end;
      if (vRect:top<0) then begin
        vRect:top # 0;
        vRePos # true;
      end;
    end;
    if (vRePos) then begin
      vRect:Bottom # vRect:Top + vH;
      vRect:right  # vRect:left + vW;
      vMDI->wparea # vRect;
    end;
  END;
  
end;


/*========================================================================
2023-04-26  AH
========================================================================*/
sub AbleMenu(
  aName   : alpha;
  aEnable : logic;
)
local begin
  vHdl  : int;
end;
begin
  vHdl # gMenu->WinSearch(aName);
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # !aEnable;
  end;
end;


//========================================================================