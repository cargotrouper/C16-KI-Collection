@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Reclist
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//    SUB StartListEdit(aList : int; optaNew : logic; optaColumn : int; optaFlags : int)
//    SUB EvtKeyItem(aEvt : event; aKey : int; aRecID : int) : logic
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHitTest : int; aItem : int; aID : int) : logic
//    SUB EvtLstEditStart(aEvt : event; aColumn : int; aEdit : int; aList : int) : logic
//    SUB EvtLstEditCommit(aEvt : event; aColumn : int; aKey : int; aFocusObject : int) : logic
//    SUB Save(aEvt : event) : logic;
//    SUB EvtLstEditFinished(aEvt : event; aColumn : int; aKey : int; aRecId : int; aChanged : logic) : logic
//
//========================================================================
@I:def_global


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
  vFlags  : int;   // Spalten-Flags
  vErg    : int;   // Datenbank-Resultat
  vFile   : int;
  vProc   : alpha;
end;
begin

  // Keine Liste vorhanden.
  if (aList = 0) then RETURN;

  // Datei bestimmen
  if (aList->wpDbLinkFileNo<>0) then vFile # aList->wpDbLinkFileNo
  else vFile # aList->wpDbFileNo;

  // Steuerungsprozedur bestimmen
  vProc # Str_Token( WinEvtProcNameGet(aList,_WinEvtLstDataInit),':',1);

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
  vFlags # aFlags;

  if (aNew) then begin
    RecBufClear(vFile);
    if (vProc<>'') then call(vProc+':RecInit');
    vErg # RekInsert(vFile,0,'MAN');
    aList->wpcustom # c_ModeEdListNew;
//    App_Main:refreshmode();
    aList->WinUpdate(_WinUpdOn,
                        _WinLstFromFirst| _WinLstPosSelected | _WinLstRecDoSelect);
  end
  else begin
    // Zu editierenden Datensatz sperren.
    if (aList->wpcustom='') or (aList->wpcustom=c_ModeEdList) then begin
      vErg # RecRead(vFile,0,_RecID | _RecSingleLock | _RecNoLoad,aList->wpDbRecID);
      if (vErg=_rLocked) and (UserID(_UserLocked)<>UserID(_UserCurrent)) then RETURN;
      aList->wpcustom # c_ModeEdListEdit;
//      App_Main:refreshmode();
      RecRead(vFile,0,_RecID | _RecSingleLock,aList->wpDbRecID);
    end;
  end;

  // Editiermodus starten.
  aList->WinLstEdit(aColumn,vFlags);

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
  vList : int;
  vFile : int;
  vProc : alpha;
  vTmp  : int;
end;
begin

  vList # aEvt:obj;

  // Datei bestimmen
  if (vList->wpDbLinkFileNo<>0) then vFile # vList->wpDbLinkFileNo
  else vFile # vList->wpDbFileNo;

  // Steuerungsprozedur bestimmen
  vProc # Str_Token( WinEvtProcNameGet(vList,_WinEvtLstDataInit),':',1);

  // Bei Return Editiermodus starten und Änderungsflag zurücksetzen.
/*
if (aKey=_WinKeyInsert) then begin
    StartListEdit(aEvt:Obj,y,0,_WinLstEditClearChanged);
    RETURN FALSE;
  end;
*/


  if (aKey=_WinKeydelete) and (aRecId<>0) then begin
    If (RecRead(vFile,0,_recId,aRecId)=_rOk) then begin
      if (vProc<>'') then Call(vProc+':RecDel');
//      RekDelete(vFile,0,'MAN');
//      vList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      vList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect);
    end;
  end;

  if (aKey = _WinKeyReturn) then begin
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
  if (aID > 0 AND aItem > 0 AND
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
  tFrame   : int;         // Frame-Deskriptor
  tRect    : rect;        // Popup-Area
  tItem    : int;         // Spaltenindex
  tBoolStr : alpha;       // Temp. Variable
  tBoolVal : logic;       // Temp. Variable
  tBool    : logic;       // Temp. Variable
end;
begin

  // Frame-Deskriptor.
  tFrame # aEvt:Obj->WinInfo(_WinFrame);


  if (aEdit > 0) then begin
//    aEdit->wpInputCtrl    # false;
    aEdit->wpColFocusBkg  # Set.Col.Field.Cursor;
    if (aColumn->wpClmStretchWidth<>0) then aEdit->wpLengthMax # aColumn->wpClmStretchWidth;
  end;

  if (aList > 0) then begin
    aList->wpComboStyle # _WinComboSingleClick;
/*
    if ($chkLstEditClose->wpCheckState = _WinStateChkChecked) then
      aList->wpLstFlags # _WinLstEditClose;
        // alpha-Werte zur Liste hinzufügen.
        aList->WinLstDatLineAdd('Eintrag 1');
        aList->WinEvtProcNameSet(_WinEvtLstDataInit , 'Lib_RecList2:EvtLstDataInit');
        aEdit->wpReadOnly # TRUE;
*/
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
begin
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
  vList   : int;
  vOK     : logic;
  vErg    : int;
  vFile   : int;
  vProc   : alpha;
end;
begin
  vList # aEvt:obj;

  // Datei bestimmen
  if (vList->wpDbLinkFileNo<>0) then vFile # vList->wpDbLinkFileNo
  else vFile # vList->wpDbFileNo;

  // Steuerungsprozedur bestimmen
  vProc # Str_Token( WinEvtProcNameGet(vList,_WinEvtLstDataInit),':',1);

  vOk # y;
  if (vProc<>'') then begin
    vOk # Call(vProc+':RecSave',vList->wpcustom=c_ModeEdListNew);
//    vErg # Erg; 12.11.2021 AH
    if (vOK) then vErg # _rOK
    else vErg # _rNoRec;
  end
  else begin
    vErg # RekReplace(vFile,_recUnlock,'MAN');
  end;
  if (vOK=n) then begin
    if (vList->wpcustom=c_ModeCancel) then begin
      aEvt:Obj->WinUpdate(_WinUpdOn,
                        _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
      vList->wpcustom # c_ModeEdList;
//      App_Main:refreshmode();
      RETURN true;
    end
    else begin
      Msg(001204,'',0,0,0);
    end;
  end
  else begin    // alles ok
    if (vErg=_rOK) then begin
      aEvt:Obj->WinUpdate(_WinUpdOn,
                        _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
      vList->wpcustom # c_ModeEdList;
//      App_Main:refreshmode();
      RETURN TRUE;
    end;

    // FEHLER: Satz exisitiert schon
    Msg(001204,'',0,0,0);
  end;
//    tColumn # aColumn;
end;


//========================================================================
//  EvtLstEditFinished
//
//========================================================================
sub EvtLstEditFinished(
  aEvt       : event; // Ereignis
  aColumn    : int;   // Spalte
  aKey       : int;   // Taste
  aRecId     : int;   // RecID
  aChanged   : logic;
) : logic
local begin
  vKey        : int;   // Taste ohne shift und ctrl
  vFrame      : int;   // Frame-Deskriptor
  vErg        : int;   // Datenbank-Resultat
  vColumn     : int;   // Spalten-Deskriptor
  vDirection  : int;   // Fokussierung
  tStr        : alpha; // Temp. Variable
  vOk         : logic;
  vList       : int;
  vFile       : int;
  vTMP        : int;
end;
begin
  vList # aEvt:obj;

  // Frame-Deskriptor.
  vFrame # aEvt:Obj->WinInfo(_WinFrame);

  // fremdes Fenster aktiviert????
  if (vFrame->wpname<>w_name) then
    VarInstance(WindowBonus,cnvIA(vFrame->wpcustom));

  // Datei bestimmen
  if (vList->wpDbLinkFileNo<>0) then vFile # vList->wpDbLinkFileNo
  else vFile # vList->wpDbFileNo;

  // Initialisierung.
  vKey       # aKey & _WinKeyMask;
  vColumn    # 0;
  vDirection # 0;
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
  if (vKey = _WinKeyTab) or (vKey = _WinKeySelect) or (vKey=_Winkeyreturn) then begin
    // Shift-Tab -> eine Spalte zurück.
    if (aKey & _WinKeyShift = _WinKeyShift) then
      vDirection # -1
    // Tab -> eine Spalte weiter.
    else
      vDirection # 1;
    end
    // Return -> Datensatz in der Datenbank ändern und entsperren.
/*
  else if (tKey = _WinKeyReturn) then begin
    vOk # y;
AGGA    if (gPrefix<>'') then begin
      vOk # Call(gPrefix+'_Main:RecSave');
    end;
    if (vOK=n) then begin
      if (aList->wpcustom=c_ModeCancel) then begin
        aEvt:Obj->WinUpdate(_WinUpdOn,
                          _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
        aList->wpcustom # c_ModeEdList;
//        App_Main:refreshmode();
        RETURN true;
      end
      else begin
        Msg(161000,'',0,0,0);
      end;
    end
    else begin    // alles ok
      tErg # RekReplace(vFile,_RecUnLock);
      if (tErg=_rOK) then begin
        aEvt:Obj->WinUpdate(_WinUpdOn,
                          _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
        aList->wpcustom # c_ModeEdList;
//        App_Main:refreshmode();
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
    vErg # RecRead(vFile,0,_RecID | _RecUnLock,aRecID);
    if (vList->wpcustom=c_ModeEdListNew) then begin
      RekDelete(vFile,0,'MAN');
    end;
    aEvt:Obj->WinUpdate(_WinUpdOn,
                        _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);

    // fremdes Fenster aktiviert????
    if (vFrame->wpname<>w_name) then begin
      vTMP # VarInfo(Windowbonus);
      VarInstance(WindowBonus,cnvIA(vFrame->wpcustom));
      vList->wpcustom # c_ModeEdList;
      VarInstance(WindowBonus,vTMP);
    end
    else begin
      vList->wpcustom # c_ModeEdList;
    end;

    RETURN TRUE;
  end;

  // Tastatursteuerung vornehmen.
  vColumn # aColumn;
  REPEAT
    case (vDirection) of
      // Ermittle die vorhergehende oder letzte Spalte.
      -1 : begin
        vColumn # vColumn->WinInfo(_WinPrev);
        if (vColumn = 0) then
          vColumn # aEvt:Obj->WinInfo(_WinLast);
      end;

      // Ermittle die nachfolgende oder 1. Spalte.
      1 : begin
        vColumn # vColumn->WinInfo(_WinNext);
        if (vColumn = 0) then
          vColumn # aEvt:Obj->WinInfo(_WinFirst);
      end;
    end;
    if (vColumn->wpcustom='_SKIP') then CYCLE;
    if (vColumn->wpcustom='_FIRST') then RETURN SAVE(aEvt);
  UNTIL (1=1);

  // Jetzt braucht nur noch der Editiervorgang mit der ermittelten
  // Spalte gestartet werden.
  if (vColumn > 0) then
    StartListEdit(aEvt:obj,n,vColumn);
end;

//========================================================================