@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Reclist
//                  OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  14.03.2013  AI  Änderungen beim StartListEdit (für RecInit)
//  23.01.2015  AH  Neue Modi für EdLists, die per Menü/Maus gespeichert werden
//  21.05.2021  AH  Erweiterungen für BAG.FM.Main als EdList
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//    SUB StartListEdit(aList : int; optaNew : logic; optaColumn : int; optaFlags : int)
//    SUB EvtKeyItem(aEvt : event; aKey : int; aRecID : int) : logic
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHitTest : int; aItem : int; aID : int) : logic
//    SUB EvtLstEditStart(aEvt : event; aColumn : int; aEdit : int; aList : int) : logic
//    SUB EvtLstEditCommit(aEvt : event; aColumn : int; aKey : int; aFocusObject : int) : logic
//    SUB Save(aEvt : event) : logic;
//    SUB EvtLstEditFinished(aEvt : event; aColumn : int; aKey : int; aRecId : int; aChanged : logic) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB RecDel()
//
//========================================================================
@I:def_global


declare Save(aEvt : event) : logic;

//========================================================================
//  StartListEdit
//
//========================================================================
sub StartListEdit(
  aList       : int; // Liste
  opt aNew    : logic;
  opt aColumn : int; // Spalte
  opt aFlags  : int;
)
local begin
  erx     : int;
  tFlags  : int;   // Spalten-Flags
  tStr    : alpha;
end;
begin

  // 13.03.2013: nur bei Neuanlage
  if (gPrefix<>'') and (Mode=c_ModeEdList) then begin
    RecBufClear(gFile);
    if (Call(gPrefix+'_Main:RecInit')=false) then RETURN;
  end;
  // Keine Liste vorhanden? -> Ende
  if (aList = 0) then RETURN;
  // Editieren von leerer Liste? -> Ende
  if (aNew=false) and (aList->wpDbRecID=0) then RETURN;

  // Keine Spalte vorhanden -> Ermittle die 1. Spalte.
  if (aColumn = 0) then begin
    aColumn # aList->WinInfo(_WinFirst);
    REPEAT
      if (aColumn<>0) then begin
        if (aColumn->wpcustom='_SKIP') then begin
          aColumn # aColumn->WinInfo(_WinNext);
          CYCLE;
        end
      end;
    UNTIL (1=1);
    aColumn->wpcustom # '_FIRST';
  end;

  // Fehler: Liste hat keine Spalten.
  if (aColumn = 0) then RETURN;

  // Listenerstellung für Eingabefeld.
  tFlags # aFlags;

  case (aColumn->wpCaption) of
    // Liste mit 2 Spalten (int, alpha).
    'Art.INummer'      : tFlags # aFlags | _WinLstEditLstAlpha;
    // List mit 1 Spalte (alpha).
    'ART.aBezeichnung' : tFlags # aFlags | _WinLstEditLst;
  end;

  if (aNew) then begin
// 14.03.2013: schon am Anfang
//    RecBufClear(gFile);
//    if (gPrefix<>'') then call(gPrefix+'_Main:RecInit');
    Erx # RekInsert(gFile,_RecLock,'MAN');
    if (Erx<>_ROK) then begin
      Msg(99,'nix gut!',0,0,0);
      RETURN;
    end;
    Mode # c_ModeEdListNew;
    App_Main:refreshmode();
//  14.03.2013 aList->WinUpdate(_WinUpdOn, _WinLstFromFirst| _WinLstPosSelected | _WinLstRecDoSelect);
    aList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID| _WinLstPosSelected | _WinLstRecDoSelect);
  end
  else begin
    // Zu editierenden Datensatz sperren.

    if (Mode=c_ModeEdList) or (mode=c_modeList) then begin
      Erx # RecRead(gFile,0,_RecID | _RecSingleLock | _RecNoLoad, aList->wpDbRecID);
//      if (Erx=_rLocked) and (UserID(_UserLocked)<>UserID(_UserCurrent)) then RETURN;
      if (Erx <> _rOK) then RETURN;

      Mode # c_ModeEdListEdit;
      App_Main:refreshmode();
// 14.03.2013    Erx # RecRead(gFile,0,_RecID | _RecSingleLock,aList->wpDbRecID);
      Erx # RecRead(gFile, 0, _RecID | _RecLock, aList->wpDbRecID);

      PtD_Main:Memorize(gFile);
    end;
  end;

  // Editiermodus starten.
  aList->WinLstEdit(aColumn,tFlags);

end;


//========================================================================
//  EvtKeyItem
//
//========================================================================
sub EvtKeyItem(
  aEvt       : event; // Ereignis
  aKey       : int;   // Taste
  aRecID     : int;   // RecID nur bei RecListstart

) : logic
local begin
  vHdl  : int;
  vTmp  : int;
end;
begin

  // Bei Return Editiermodus starten und Änderungsflag zurücksetzen.

/*
if (aKey=_WinKeyInsert) then begin
    StartListEdit(aEvt:Obj,y,0,_WinLstEditClearChanged);
    RETURN FALSE;
  end;
*/

/*
  if (aKey=_WinKeydelete) and (aRecId<>0) then begin
    If (RecRead(gFile,0,_recId,aRecId)=_rOk) then begin
      RekDelete(gFile,0,'MAN');
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;
  end;
*/
  if (akey=_WinKeyInsert) and (Mode=c_ModeedList) and (gFile<>0) then begin
    RecRead(gFile,0,0,gZLList->wpdbrecid);
    Lib_Mark:MarkAdd(gFile);
  end;
  if (akey=_WinKeyDelete) and (Mode=c_ModeedList) then begin
    if (gMenu<>0) then begin
      vHdl # gMenu->WinSearch('Mnu.Delete');
      if (vHdl<>0) then begin
        if (vHdl->wpdisabled=false) then begin
          if (gFile<>0) and (gZLList->wpdbrecid<>0) then begin
            RecRead(gFile,0,0,gZLList->wpdbrecid);
            App_Main:Action(c_ModeDelete);
          end;
        end;
      end;
    end;
  end;

// EDEDLIST
  if (w_ListQuickEdit) and (aKey = _WinKeyReturn) then begin
    RETURN App_Main:EvtKeyItem(aEvt, aKey, aRecID);
  end;

  if ((w_ListQuickEdit) and (aKey = _WinKeyReturn|_WinKeyCtrl)) or
    (aKey = _WinKeyReturn) then begin

    if (w_Auswahlmode) then begin
//      Erx # gZLList->wpdbRecId
      gSelected # aRecID;
      gMDI->Winclose();
      RETURN true;
    end;

    vTmp # Winsearch(gMDI,'Edit');
    if (vTmp<>0) then
      if (vTmp->wpdisabled) then RETURN false;

    StartListEdit(aEvt:Obj,n,0,_WinLstEditClearChanged);
  end;

  RETURN TRUE;
end;


//========================================================================
//  EvtMouseItem
//
//========================================================================
sub EvtMouseItem(
  aEvt      : event; // Ereignis
  aButton   : int;   // Maustaste
  aHitTest  : int;   // Hittest-Code
  aItem     : int;   // Spalte oder Gantt-Intervall
  aID       : int;   // RecID bei RecList / Zeile bei GanttGraph
) : logic
begin
  // Bei Doppelklick Editiermodus starten und Änderungsflag zurücksetzen.
  if (aID <> 0 AND aItem <> 0 AND
      aButton & (_WinMouseLeft | _WinMouseDouble) =
      (_WinMouseLeft | _WinMouseDouble)) then begin

      if (aItem->wpcustom<>'_SKIP') then
        StartListEdit(aEvt:obj,n,aItem,_WinLstEditClearChanged);
  end;

  RETURN TRUE;
end;


//========================================================================
//  EvtLstEditStart
//
//========================================================================
sub EvtLstEditStart(
  aEvt         : event; // Ereignis
  aColumn      : int;   // Spalte
  aEdit        : int;   // Eingabefeld
  aList        : int;   // Datalist
) : logic
local begin
  tStr     : alpha(250);  // Caption
  tRect    : rect;        // Popup-Area
  tItem    : int;         // Spaltenindex
  tBoolStr : alpha;       // Temp. Variable
  tBoolVal : logic;       // Temp. Variable
  tBool    : logic;       // Temp. Variable
end;
begin

  if (aEdit > 0) then begin
//    aEdit->wpInputCtrl    # false;
    aEdit->wpColFocusBkg  # Set.Col.Field.Cursor;
    if (aColumn->wpClmStretchWidth<>0) then aEdit->wpLengthMax # aColumn->wpClmStretchWidth;
  end;

  if (aList > 0) then begin

    aList->wpComboStyle # _WinComboSingleClick;

    if ($chkLstEditClose<>0) then begin
      if ($chkLstEditClose->wpCheckState = _WinStateChkChecked) then
        aList->wpLstFlags # _WinLstEditClose;
    end;

    case (aColumn->wpCaption) of

      // Liste mit Alpha-Werten erstellen und einen Logic-Wert zuordnen.
      'ART.aBezeichnung' : begin
        // alpha-Werte zur Liste hinzufügen.
        aList->WinLstDatLineAdd('Eintrag 1');
        // usw.
        aEdit->wpReadOnly # TRUE;
      end;

      'Art.INummer' : begin
        // Anzeige einer Liste von Zeichenketten, denen ein
        // eindeutiger Wert zugeordnet ist.

        // 'wenig' -> 1
        aList->WinLstDatLineAdd(1);
        aList->WinLstCellSet('wenig',2);
        // usw.

        aList->wpColGrid # _WinColBtnFace;

        // Liste etwas vergrößern.
        tItem # aList->WinInfo(_WinParent);
        if (tItem > 0) then begin
          tRect # tItem->wpArea;
          tRect:right # tRect:left + 200;
          tItem->wpArea # tRect;
        end;

        // Erste Spalte auch anzeigen.
        tItem # aList->WinInfo(_WinFirst);
        if (tItem > 0) then begin
          tItem->wpClmWidth # 40;
          tItem->wpVisible # TRUE;
        end;
      end;

    end; // CASE

  end;
end;


//========================================================================
//  EvtLstEditCommit
//
//========================================================================
sub EvtLstEditCommit(
  aEvt         : event; // Ereignis
  aColumn      : int;   // Spalte
  aKey         : int;   // Taste
  aFocusObject : int;
) : logic
local begin
  vA            : alpha;
end;
begin

  if (aKey=0) then begin
    if (aFocusObject<>0) then begin
      vA # aFocusObject->wpname;
    end
    else begin
      if (mode=c_ModeEdListNew2Save) then begin
        Mode # c_ModeEdListNew;
        vA # 'Save';
      end
      else if (mode=c_ModeEdListEdit2Save) then begin
        Mode # c_ModeEdListEdit;
        vA # 'Save';
      end;
    end;
    if (vA='Save') then begin
      Save(aEvt);
      RETURN true;
    end;
  end;

/*
  $edCommitFocus->wpCaptionInt # aFocusObject;
  $edCommitKey->wpCaptionInt   # aKey & _WinKeyMask;
  CheckBoxFlag($chkCommitShift,aKey & _WinKeyShift = _WinKeyShift);
  CheckBoxFlag($chkCommitCtrl ,aKey & _WinKeyCtrl  = _WinKeyCtrl );
*/

  RETURN (aKey != _WinKeyEsc);
end;


//========================================================================
//  Save
//
//========================================================================
sub Save(aEvt : event) : logic;
local begin
  Erx     : int;
  vOK     : logic;
  tColumn : int;
end;
begin
    vOk # y;
    if (gPrefix<>'') then begin
      vOk # Call(gPrefix+'_Main:RecSave');
    end;
    if (vOK=n) then begin
      if (Mode=c_ModeCancel) then begin
// EDEDLIST
        if (ProtokollBuffer[gFile]<>0) then PtD_Main:Forget(gFile);
        aEvt:Obj->WinUpdate(_WinUpdOn,
                          _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
// EDEDLIST
        if (w_ListQuickEdit=false) then mode # c_ModeEdList
        else mode # c_modeList;
        App_Main:refreshmode();
        RETURN true;
      end
      else begin
        Msg(001204,'',0,0,0);
      end;
    end
    else begin    // alles ok
      // 21.05.2021 AH: hat "Main_RecSave" alles schon erledigt?
      if (Mode=c_ModeSave) then begin
        Erx # _rOK;
      end
      else begin
        Erx # RekReplace(gFile,_RecUnLock,'MAN');
      end;
      if (Erx=_rOK) then begin
// EDEDLIST
        if (ProtokollBuffer[gFile]<>0) then PtD_Main:Compare(gFile);
        aEvt:Obj->WinUpdate(_WinUpdOn,
                          _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
// EDEDLIST
        if (w_ListQuickEdit=false) then mode # c_ModeEdList
        else mode # c_modeList;
        App_Main:refreshmode();
//debug('--savemode :' +mode);
        RETURN TRUE;
      end;
// EDEDLIST

      if (ProtokollBuffer[gFile]<>0) then PtD_Main:Forget(gFile);

      // FEHLER: Satz exisitiert schon
      Msg(001204,'',0,0,0);

      if (w_ListQuickEdit=false) then mode # c_ModeEdList
      else mode # c_modeList;
      App_Main:refreshmode();
      RETURN false;
    end; // alles ok

//    tColumn # aColumn;
end;


//========================================================================
//  EvtLstEditFinished
//
//========================================================================
sub EvtLstEditFinished
(
  aEvt       : event; // Ereignis
  aColumn    : int;   // Spalte
  aKey       : int;   // Taste
  aRecId     : int;   // RecID
  aChanged   : logic;
) : logic
local begin
  Erx         : int;
  tKey        : int;   // Taste ohne shift und ctrl
  tFrame      : int;   // Frame-Deskriptor
  tColumn     : int;   // Spalten-Deskriptor
  tDirection  : int;   // Fokussierung
  tStr        : alpha; // Temp. Variable
  vOk         : logic;
  vTmp        : int;
end;
begin

  // Frame-Deskriptor.
  tFrame # aEvt:Obj->WinInfo(_WinFrame);

  // fremdes Fenster aktiviert????
  if (tFrame->wpname<>w_name) then
    VarInstance(WindowBonus,cnvIA(tFrame->wpcustom));

  // Initialisierung.
  tKey       # aKey & _WinKeyMask;
  tFrame     # aEvt:Obj->WinInfo(_WinFrame);
  tColumn    # 0;
  tDirection # 0;

/*
  $edFinishRecId->wpCaptionInt # aRecId;
  $edFinishKey->wpCaptionInt   # tKey;
  CheckBoxFlag($chkFinishShift,aKey & _WinKeyShift = _WinKeyShift);
  CheckBoxFlag($chkFinishCtrl ,aKey & _WinKeyCtrl  = _WinKeyCtrl );
  CheckBoxFlag($chkFinishChanged,aChanged);
*/
  // Änderungen durch einen Stern sichtbar machen.
  if (aChanged) then
    tStr # ' * '
  else
    tStr # '   ';

  // Tastatursteuerung zum Navigieren zw. Spalten.
  if (tKey = _WinKeyTab) or (tKey = _WinKeySelect) or (tKey=_Winkeyreturn) then begin
    // Shift-Tab -> eine Spalte zurück.
    if (aKey & _WinKeyShift = _WinKeyShift) then
      tDirection # -1
    // Tab -> eine Spalte weiter.
    else
      tDirection # 1;
  end
    // Return -> Datensatz in der Datenbank ändern und entsperren.
/*
  else if (tKey = _WinKeyReturn) then begin
    vOk # y;
    if (gPrefix<>'') then begin
      vOk # Call(gPrefix+'_Main:RecSave');
    end;
    if (vOK=n) then begin
      if (Mode=c_ModeCancel) then begin
        aEvt:Obj->WinUpdate(_WinUpdOn,
                          _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
        mode # c_ModeEdList;
        App_Main:refreshmode();
        RETURN true;
      end
      else begin
        Msg(161000,'',0,0,0);
      end;
    end
    else begin    // alles ok
      Erx # RekReplace(gFile,_RecUnLock,'MAN');
      if (Erx=_rOK) then begin
        aEvt:Obj->WinUpdate(_WinUpdOn,
                          _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
        mode # c_ModeEdList;
        App_Main:refreshmode();
        RETURN TRUE;
      end;

      // FEHLER: Satz exisitiert schon
      Msg(161001,'',0,0,0);
    end;
    tColumn # aColumn;
  end
***/
  // Datensatz nicht ändern, jedoch entsperren!
  else begin
// EDEDLIST

    if (gPrefix<>'') then begin
      try begin
        ErrTryIgnore(_rlocked,_rNoRec);
        ErrTryCatch(_ErrNoProcInfo,y);
        Call(gPrefix+'_Main:RecCleanUp');
      end;
    end;

    if (ProtokollBuffer[gFile]<>0) then PtD_Main:Forget(gFile);
    Erx # RecRead(gFile,0,_RecID | _RecUnLock,aRecID);
    if (Mode=c_ModeEdListNew) then begin
      RekDelete(gFile,0,'MAN');
    end;
//25.05.2021 AH: später    aEvt:Obj->WinUpdate(_WinUpdOn,
//                        _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);

    // fremdes Fenster aktiviert????
    if (tFrame->wpname<>w_name) then begin
      vTMP # VarInfo(Windowbonus);
      VarInstance(WindowBonus,cnvIA(tFrame->wpcustom));
      if (w_ListQuickEdit=false) then mode # c_ModeEdList
      else mode # c_modeList;
      App_Main:refreshmode();
      VarInstance(WindowBonus,vTMP);
    end
    else begin
      if (w_ListQuickEdit=false) then mode # c_ModeEdList
      else mode # c_modeList;
      App_Main:refreshmode();
    end;

    aEvt:Obj->WinUpdate(_WinUpdOn,_WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect); // 25.05.2021 von oben

    RETURN TRUE;
  end;

  // Tastatursteuerung vornehmen.
  tColumn # aColumn;
  REPEAT
    case (tDirection) of
      // Ermittle die vorhergehende oder letzte Spalte.
      -1 : begin
        tColumn # tColumn->WinInfo(_WinPrev);
        if (tColumn = 0) then
          tColumn # aEvt:Obj->WinInfo(_WinLast);
      end;

      // Ermittle die nachfolgende oder 1. Spalte.
      1 : begin
        tColumn # tColumn->WinInfo(_WinNext);
        if (tColumn = 0) then
          tColumn # aEvt:Obj->WinInfo(_WinFirst);
      end;
    end;
    if (tColumn->wpcustom='_SKIP') then CYCLE;
    if (tColumn->wpcustom='_FIRST') then RETURN SAVE(aEvt);
  UNTIL (1=1);

  // Jetzt braucht nur noch der Editiervorgang mit der ermittelten
  // Spalte gestartet werden.
  if (tColumn > 0) then
    StartListEdit(aEvt:obj,n,tColumn);
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin
  StartListEdit(aEvt:Obj,y,0,_WinLstEditClearChanged);
end;


//========================================================================
//  RecDel
//              Datensatz löschen
//========================================================================
sub RecDel();
local begin
  vHDL  : int;
end;
begin
  if (RecRead(gFile,0,0,gZLList->wpdbrecid)=_rOK) then begin
    try begin
      ErrTryIgnore(_rlocked,_rNoRec);
      ErrTryCatch(_ErrNoProcInfo,y);
      ErrTryCatch(_ErrNoSub,y);
      if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecDel',_strupper));
      Mode # c_ModeEdList;
    end;
    if (gPrefix='') or (ErrGet() =_ErrNoProcInfo) or (ErrGet()=_ErrNoSub) then begin
      Msg(001999,gPrefix+'_Main:RecDel',0,0,0);
    end;
//        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
    App_Main:RefreshMode(); // Buttons & Menues anpassen
    vHdl # gMdi->winsearch('NB.Main');
    vHdl->wpCurrent # 'NB.List';
    $NB.List->WinFocusSet(false);
  end;
end;

//========================================================================