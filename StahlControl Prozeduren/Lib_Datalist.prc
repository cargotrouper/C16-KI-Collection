@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Datalist
//                    OHNE E_R_G
//  Info
//      Library zum Verwenden der DataList.
//      Erlaubt eine Funktion EvtLstLineEdited mit der Signatur
//        SUB EvtLstLineEdited ( aDataList : int; aColumn : int; aRow : int; )
//      die beim Abschluss der Bearbeitung einer Zeile in der _Main Prozedur
//      ausgeführt wird.
//
//  21.06.2004  AI  Erstellung der Prozedur
//  20.10.2008  PW  Überarbeitung
//  25.01.2011  AI  Edit nur möglich, wenn Button "EDIT" aktiv ist
//  07.11.2011  AI  NewDLRow
//  05.07.2012  AI  Komplett überarbeitet
//  19.07.2012  AI  Anpassungen für Mode<>edList (Propipes SFX für OBFAnlage)
//  23.01.2015  AH  Neue Modi für EdLists, die per Menü/Maus gespeichert werden
//  16.11.2015  AH  Neu: F4/Neuanlage imemr als UNTERSTE Zeile
//  14.12.2015  AH  Edit: AFX "NewDLRow" an anderer Stelle
//  27.06.2018  AH  "RemoveDlRow" ruft ggf. "_Man:RecDel" auf
//  28.06.2018  AH  Sub "Move" (ORDERPASS muss CREATED sein!!!!)
//  04.10.2018  AH  "Move" übernimmt auch SortValues
//  27.05.2019  AH  "_SKIP" kann auch "P:prozedurname" sein
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//    SUB StartListEdit ( aList : int; optaColumn : int; optaFlags : int; aEditPossible : logic)
//    SUB EvtKeyItem ( aEvt : event; aKey : int; aRecID : int ) : logic
//    SUB EvtMouseItem ( aEvt : event; aButton : int; aHitTest : int; aItem : int; aID : int ) : logic
//    SUB EvtLstEditStart ( aEvt : event; aColumn : int; aEdit : int; aList : int ) : logic
//    SUB EvtLstEditCommit ( aEvt : event; aColumn : int; aKey : int; aFocusObject : int ) : logic
//    SUB EvtLstEditFinished ( aEvt : event; aColumn : int; aKey : int; aRecId : int; aChanged : logic ) : logic
//    SUB NewDLRow() : logic;
///   SUB RemoveDLRow() : logic;
//    SUB EvtClicked (aEvt : event) : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem  : int) : logic
//    SUB Move(aDL : int; aVon : int; aNach : int)
//
//========================================================================
@I:Def_Global

declare RemoveDLRow() : logic;

//========================================================================
sub _IsItemEditable(
  aDL   : int;
  aItem : int) : logic
local begin
  vOK   : logic;
end
begin
  // per Prozedur?
  if (StrCut(aItem->wpCustom,1,2)='P:') then begin
    vOK # call(StrCut(aItem->wpCustom,3,100), aDL, aItem);
    RETURN vOK;
  end;
    
  RETURN (aItem->wpCustom != '_SKIP') and (aItem->wpVisible);
end;


//========================================================================
//  StartListEdit
//
//========================================================================
sub StartListEdit (
  aList             : int;
  aMode             : alpha;
  opt aColumn       : int;
  opt aFlags        : int;
  opt aEditPossible : logic;
)
local begin
  vHdl  : int;
  vEdit : int;
end
begin

  if ( aList = 0 ) then RETURN
  if (aList->wpcurrentint=0) then RETURN;


//  vHdl # gMdi->WinSearch('Edit' );
//  if (vHdl<>0) and (aEditpossible=n) then begin
//    if (vHdl->wpdisabled) then begin
//      RETURN;
//    end;
//  end;


  // keine Spalte angegeben -> erste mögliche Spalte markieren
  if ( aColumn = 0 ) then begin
    FOR  aColumn # aList->WinInfo( _winFirst );
    LOOP aColumn # aColumn->WinInfo( _winNext );
    WHILE ( aColumn != 0 ) DO BEGIN
      if ( _IsItemEditable(aList, aColumn) ) then
        BREAK;
    END;
    if ( aColumn = 0 ) then begin
      RETURN;
    end;

//    aColumn->wpCustom # '_FIRST'; 27.05.2019 WARUM???
  end;

  if (aMode<>'') then begin
    Mode # aMode;//c_ModeEdListNew;
    App_Main:refreshmode();
  end;

// 21.10.2015 warum???  aFlags # aFlags | _winLstEditLst;
//  aList->WinLstEdit( aColumn, aFlags );
  vEdit # aList->WinLstEdit( aColumn, aFlags );
  // 08.03.2022 AH
  if (vEdit<>0) and (aColumn->wpClmType=_typeBool) then begin
    vEdit->wpReadOnly # false;  
    vEdit->wpCaption # '';
  end;

end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit (
  aEvt            : event;
  aRecId          : int;
) : logic
begin

  aEvt:obj->wpColFocusBkg    # "Set.Col.RList.Cursor";
  aEvt:obj->wpColFocusOffBkg # "Set.Col.RList.CurOff";

  if ( gPrefix != '' ) then begin
    try begin
      ErrTryIgnore( _rLocked, _rNoRec );
      ErrTryCatch( _errNoProcInfo, true );
      ErrTryCatch( _errNoSub, true );
      Call( gPrefix + '_Main:EvtLstDataInit', aEvt, aRecId )
    end;
  end;

  RETURN true;
end;


//========================================================================
//  EvtLstSelect
//
//========================================================================
sub EvtLstSelect (
  aEvt            : event;
  aRecID          : int;
) : logic
local begin
  vParent         : int;
  vA              : alpha;
end;
begin
return true;
  if ( gPrefix != '' ) then begin
    try begin
      ErrTryIgnore( _rLocked, _rNoRec );
      ErrTryCatch( _errNoProcInfo, true );
      ErrTryCatch( _errNoSub, true );
      Call( gPrefix + '_Main:EvtLstSelect', aEvt, aRecId )
    end;
  end;

  RETURN true;
end;


//========================================================================
//  EvtKeyItem
//
//========================================================================
sub EvtKeyItem (
  aEvt            : event;
  aKey            : int;
  aRecID          : int;
  opt aForceEdit  : logic;
) : logic
local begin
  vTmp  : int;
end;
begin

  // Delete
  if ( aKey = _WinKeyDelete) then begin
    RemoveDLRow();
  end;

  // Return = Edit
  if (aKey = _WinKeyTab) or ( aKey = _winKeyReturn ) then begin

    if (aForceEdit=false) then begin
      vTmp # WinSearch( gMDI, 'Edit' );
      if ( vTmp != 0 ) and ( vTmp->wpDisabled ) then
        RETURN false;

      if ( aEvt:obj->WinLstDatLineInfo( _winLstDatInfoCount ) = 0 ) then
        RETURN false;
    end;
    
    if ( aEvt:obj->wpCurrentInt = 0 ) then
      aEvt:obj->wpCurrentInt # 1;

    if (mode=c_ModeEdList) then
      StartListEdit( aEvt:obj, c_ModeEdListEdit, 0, _winLstEditClearChanged )
    else
      StartListEdit( aEvt:obj, '', 0, _winLstEditClearChanged );

  end;

  RETURN true;
end;


//========================================================================
//  EvtMouseItem
//
//========================================================================
sub EvtMouseItem (
  aEvt            : event;
  aButton         : int;
  aHitTest        : int;
  aItem           : int;
  aId             : int;
) : logic
begin

  // Doppelklick auf Feld = Edit
  if ( aId > 0 ) and ( aItem > 0 ) and ( aButton = _winMouseLeft | _winMouseDouble ) then begin
    if ( _IsItemEditable(aEvt:Obj, aItem) ) then begin

      if (mode=c_ModeEdList) then
        StartListEdit( aEvt:obj, c_ModeEdListEdit, aItem, _winLstEditClearChanged )
      else
        StartListEdit( aEvt:obj, '', aItem, _winLstEditClearChanged );
    end;
  end;

  RETURN true;
end;


//========================================================================
//  EvtLstEditStart
//
//========================================================================
sub EvtLstEditStart (
  aEvt            : event;
  aColumn         : int;
  aEdit           : int;
  aList           : int;
) : logic
begin
  if ( aEdit > 0 ) then
    aEdit->wpColFocusBkg # Set.Col.Field.Cursor;

  if ( aList > 0 ) then
    aList->wpComboStyle # _winComboSingleClick;
end;


//========================================================================
//  EvtLstEditCommit
//
//========================================================================
sub EvtLstEditCommit (
  aEvt            : event;
  aColumn         : int;
  aKey            : int;
  aFocusObject    : int;
) : logic
local begin
  vA              : alpha;
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
      RETURN true;
    end;
  end;



  // Return speichert
  if (aKey=_WinKeyTab) or (aKey=_WinKeyReturn) then RETURN true;

  // alle anderen Tasten = Abbruch
  if (aKey<>0) then RETURN false;


  // Save button?
  if (aFocusObject<>0) then begin
    if (aFocusObject->wpname='Save') then RETURN true;
  end;

  // Abbruch? -> Zeile entfernen
  if (mode=c_modeEdListNew) then begin
    aEvt:Obj->WinLstDatLineRemove(_WinLstDatLineCurrent);
    aEvt:Obj->wpcurrentint # 0;
  end;

  RETURN false;
end;


//========================================================================
//  EvtLstEditFinished
//
//========================================================================
sub EvtLstEditFinished (
  aEvt            : event;
  aColumn         : int;
  aKey            : int;
  aRecID          : int;
  aChanged        : logic;
) : logic
local begin
  vKey            : int;   // unmaskiert
  vMoveBack       : logic; // Fokussierung
  vColumn         : int;   // Deskriptor der Spalte
  vRestart        : logic; // Spaltensprung über Ende oder Anfang
  vHdl            : int;
end;
begin

//  mode # c_ModeEdList;
//  App_Main:refreshmode();

  vKey # aKey & _winKeyMask;

  // Abbruch?
  if ( aKey & _winKeyEsc > 0 ) then begin
    if ( gPrefix != '' ) then begin
      try begin
        ErrTryIgnore( _rLocked, _rNoRec );
        ErrTryCatch( _errNoProcInfo, true );
        ErrTryCatch( _errNoSub, true );
        Call( gPrefix + '_Main:EvtLstLineEdited', aEvt:obj, aColumn, aEvt:obj->wpCurrentInt );
      end;
    end;

    // Zeile entfernen
    if (Mode=c_ModeEdListNew) and (aRecID<>0) then aEvt:Obj->WinLstDatLineRemove(aRecID);

    if (mode=c_modeedlistedit) or (mode=c_modeedlistNew) then begin
      mode # c_ModeEdList;
      App_Main:refreshmode();
    end;
//    RETURN true; 08.03.2022 AH : ESC soll ABBRECHEN
    RETURN false;
  end;


  vColumn # aColumn;
  if ( vKey & ( _winKeySelect | _winKeyTab | _winKeyReturn ) > 0 ) then begin
    if ( aKey & _winKeyShift > 0 ) then
      vMoveBack # true;
    else
      vMoveBack # false;

    if ( vMoveBack ) then begin
      REPEAT
        vColumn # vColumn->WinInfo( _winPrev );
        if ( vColumn = 0 ) then begin
          vColumn  # aEvt:obj->WinInfo( _winLast );
          vRestart # true;
        end;

        if _IsItemEditable(aEvt:obj, vColumn) then
          BREAK;
      UNTIL ( vColumn = aColumn );

    end
    else begin
      REPEAT
        vColumn # vColumn->WinInfo( _winNext );
        if ( vColumn = 0 ) then begin
          vColumn  # aEvt:obj->WinInfo( _winFirst );
          vRestart # true;
        end;
        if _IsItemEditable(aEvt:Obj, vColumn) then
          BREAK;
      UNTIL ( vColumn = aColumn );
    end;
  end;


  // keine andere Spalte vorgemerkt, edit modus abbrechen
  if ( vColumn = aColumn ) or ( vRestart ) then begin
    if ( gPrefix != '' ) then begin
      try begin
        ErrTryIgnore( _rLocked, _rNoRec );
        ErrTryCatch( _errNoProcInfo, true );
        ErrTryCatch( _errNoSub, true );
        Call( gPrefix + '_Main:EvtLstLineEdited', aEvt:obj, aColumn, aEvt:obj->wpCurrentInt )
      end;
    end;

    if (mode=c_Modeedlistedit) or (mode=c_modeEdListnew) then begin
      mode # c_ModeEdList;
      App_Main:refreshmode();
    end;
  end
  else begin
    // zum nächsten Feld
    StartListEdit( aEvt:obj, Mode, vColumn,0,y );
  end;

end;


//========================================================================
//  NewDLRow
//
//========================================================================
sub NewDLRow() : logic;
local begin
  vColumn         : int;
  vColType        : int;
  vI              : int;
end;
begin

/*** 14.12.2015 AH "nach unten" geschoben
  try begin
    ErrTryIgnore( _rLocked, _rNoRec );
    ErrTryCatch( _errNoProcInfo, true );
    ErrTryCatch( _errNoSub, true );
    Call( gPrefix + '_Main:NewDLRow')
    if (Erx<>_rOK) then RETURN false;
  end;
***/
  vColumn # $DL.List->WinInfo( _winFirst );
  if ( vColumn = 0 ) then
    RETURN false;

// 16.11.2015 vI # $DL.List->wpcurrentint + 1;
  vI # WinLstDatLineInfo($DL.List, _WinLstDatInfoCount) + 1;

  case ( vColumn->wpClmType ) of
    _TypeAlpha   : $DL.List->WinLstDatLineAdd( '',         vI);
    _TypeBool    : $DL.List->WinLstDatLineAdd( false,      vI);
    _TypeByte    : $DL.List->WinLstDatLineAdd( 0,          vI);
    _TypeInt     : $DL.List->WinLstDatLineAdd( 0,          vI);
    _TypeBigInt  : $DL.List->WinLstDatLineAdd( 0\b,        vI);
    _TypeFloat   : $DL.List->WinLstDatLineAdd( 0\f,        vI);
    _TypeDecimal : $DL.List->WinLstDatLineAdd( 0\m,        vI);
    _TypeDate    : $DL.List->WinLstDatLineAdd( 0.0.0,      vI);
    _TypeTime    : $DL.List->WinLstDatLineAdd( 00:00:00.0, vI);
    _TypeWord    : $DL.List->WinLstDatLineAdd( 0,          vI);
  end;
  $DL.List->wpCurrentInt # vI;


  // 14.12.2015 AH
  try begin
    ErrTryIgnore( _rLocked, _rNoRec );
    ErrTryCatch( _errNoProcInfo, true );
    ErrTryCatch( _errNoSub, true );
    Call( gPrefix + '_Main:NewDLRow')
  end;


  // neue Eingabe starten
  if (Mode=c_ModeEdList) then
    StartListEdit( $DL.List, c_ModeEdListNew, 0,0,y )
  else
    StartListEdit( $DL.List, '', 0,0,y );
end;


//========================================================================
//  RemoveDLRow
//
//========================================================================
sub RemoveDLRow() : logic;
local begin
  vHdl  : int;
end;
begin
  if ($DL.List->wpcurrentint=0) then RETURN false;
  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    if (vHdl->wpDisabled) then RETURN false;

    if (gPrefix<>'') then begin
      try begin
        ErrTryIgnore(_rlocked,_rNoRec);
        ErrTryCatch(_ErrNoSub,y);
        Call(gPrefix+'_Main:RecDel');
      end;
      if (errGet()=0) then RETURN true;
    end;

  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;

  $DL.List->WinLstDatLineRemove( _WinLstDatLineCurrent );

  RETURN true;
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked (
  aEvt            : event
) : logic
local begin
  vColumn         : int;
  vColType        : int;
end;
begin

  case ( aEvt:obj->wpName ) of

    'New' : begin
      if (Mode=c_ModeEdList) then RETURN NewDLRow();
    end;


    'Mark' : begin
    end;


    'RecPrev' :
      $DL.List->wpCurrentInt # $DL.List->wpCurrentInt - 1;


    'Edit' : begin
      if (Mode=c_ModeEdList) then
        StartListEdit( $DL.List, c_ModeEdListEdit)
      else
        StartListEdit( $DL.List, '');
    end;

    'RecNext' :
      $DL.List->wpCurrentInt # $DL.List->wpCurrentInt + 1;


    'Search' : begin
    end;


    'Delete' : begin
      RemoveDLRow();
    end;


    'Cancel' : begin
    end;


    'Save' : begin
    end;

  end;
end;


//========================================================================
//  EvtMenuCommand
//
//========================================================================
sub EvtMenuCommand (
  aEvt            : event;
  aMenuItem       : int;
) : logic
local begin
  vColumn         : int;
  vColType        : int;
end;
begin

  case ( aMenuItem->wpName ) of

    'Mnu.DL.New' : begin
      if (Mode=c_modeEdList) then RETURN NewDLRow();
    end;


    'Mnu.DL.Edit' : begin
      if (Mode=c_Modeedlist) then
        StartListEdit( $DL.List, c_ModeEdListEdit )
      else
        StartListEdit( $DL.List, '' );
    end;


    'Mnu.DL.RecPrev' :
      $DL.List->wpCurrentInt # $DL.List->wpCurrentInt - 1;


    'Mnu.DL.RecNext' :
      $DL.List->wpCurrentInt # $DL.List->wpCurrentInt + 1;


    'Mnu.DL.RecFirst' :
      $DL.List->wpCurrentInt # 1;


    'Mnu.DL.RecLast' :
      $DL.List->wpCurrentInt # $DL.List->WinLstDatLineInfo( _winLstDatInfoCount );


    'Mnu.DL.Delete' : begin
      RemoveDLRow();
    end;


    'Mnu.DL.Save' : begin
      mode # mode+'2SAVE';
      $Save->Winfocusset(y);
//      if (mode=c_ModeEdlistedit) or (mode=c_ModeEdlistnew) then begin
//        mode # c_ModeEdList;
//        App_Main:refreshmode();
//      end;
    end;

  end;
end;


//========================================================================
//========================================================================
sub Move(
  aVonDL      : int;
  aVon        : int;
  aNachDL     : int;
  aNach       : int;
  opt aCopy   : logic)
local begin
  vList       : int;
  vList2      : int;
  vItem       : int;
  vI          : int;
  vA,vB       : alpha(1000);
  vBool       : logic;
  vByte       : byte;
  vBig        : bigint;
  vTim        : time;
  vDat        : date;
  vWord       : word;
  vInt        : int;
  vF          : float;
  vDec        : decimal;
  vOPVon      : int;
  vOPNach     : int;
end;
begin

  if (aNach=0) then aNach # _WinLstDatLineLast;
  
  vList # CteOpen(_CteList);
  vList2 # CteOpen(_CteList);

  // 31.07.2019:
  vOPVon  # aVonDL->wpOrderPass;
  vOPNach # aNachDL->wpOrderPass;
  aVonDL->wpOrderPass # _WinOrderCreate;
  aNachDL->wpOrderPass # _WinOrderCreate;

  vI # 0;
  FOR vItem # aVonDL->WinInfo(_WinFirst);
  LOOP vItem # vItem->WinInfo(_WinNext)
  WHILE (vItem > 0) do begin
    inc(vI);

    // CAPTION...
    case (vItem->wpClmType) of
      _TypeAlpha  : begin
        WinLstCellGet(aVonDL, vA, vI, aVon);
      end;
      _TypeBool   : begin
        WinLstCellGet(aVonDL, vBool, vI, aVon);
        if (vBool) then vA # '1' else vA # '0';
      end;
      _TypeByte   : begin
        WinLstCellGet(aVonDL, vByte, vI, aVon);
        vA # cnvai(vByte);
      end;
      _TypeInt    : begin
        WinLstCellGet(aVonDL, vint, vI, aVon);
        vA # cnvai(vInt);
      end;
      _TypeBigInt :  begin
        WinLstCellGet(aVonDL, vBig, vI, aVon);
        vA # cnvab(vBig);
      end;
      _TypeFloat  : begin
        WinLstCellGet(aVonDL, vF, vI, aVon);
        vA # cnvaf(vF);
      end;
      _TypeDecimal  : begin
        WinLstCellGet(aVonDL, vDec, vI, aVon);
        vA # cnvam(vDec);
      end;
      _TypeDate   : begin
        WinLstCellGet(aVonDL, vDat, vI, aVon);
        vA # cnvad(vDat);
      end;
      _TypeTime   : begin
        WinLstCellGet(aVonDL, vTim, vI, aVon);
        vA # cnvat(vTim);
      end;
      _TypeWord   : begin
        WinLstCellGet(aVonDL, vWord, vI, aVon);
        vA # cnvai(vword);
      end;
    end;

    // SORTVALUE...
    vB # '';
    case (vItem->wpClmTypeSort) of
      _TypeAlpha  : begin
        WinLstCellGet(aVonDL, vB, vI, aVon, _WinLstDatModeSortInfo);
      end;
      _TypeBool   : begin
        WinLstCellGet(aVonDL, vBool, vI, aVon, _WinLstDatModeSortInfo);
        if (vBool) then vB # '1' else vB # '0';
      end;
      _TypeByte   : begin
        WinLstCellGet(aVonDL, vByte, vI, aVon, _WinLstDatModeSortInfo);
        vB # cnvai(vByte);
      end;
      _TypeInt    : begin
        WinLstCellGet(aVonDL, vint, vI, aVon, _WinLstDatModeSortInfo);
        vB # cnvai(vInt);
      end;
      _TypeBigInt :  begin
        WinLstCellGet(aVonDL, vBig, vI, aVon, _WinLstDatModeSortInfo);
        vB # cnvab(vBig);
      end;
      _TypeFloat  : begin
        WinLstCellGet(aVonDL, vF, vI, aVon, _WinLstDatModeSortInfo);
        vB # cnvaf(vF);
      end;
      _TypeDecimal  : begin
        WinLstCellGet(aVonDL, vDec, vI, aVon, _WinLstDatModeSortInfo);
        vB # cnvam(vDec);
      end;
      _TypeDate   : begin
        WinLstCellGet(aVonDL, vDat, vI, aVon, _WinLstDatModeSortInfo);
        vB # cnvad(vDat);
      end;
      _TypeTime   : begin
        WinLstCellGet(aVonDL, vTim, vI, aVon, _WinLstDatModeSortInfo);
        vB # cnvat(vTim);
      end;
      _TypeWord   : begin
        WinLstCellGet(aVonDL, vWord, vI, aVon, _WinLstDatModeSortInfo);
        vB # cnvai(vword);
      end;
     end;

//debug(vItem->wpCaption+':'+vA);
    CteInsertItem(vList, aint(vI), vItem->wpClmType, vA);
    CteInsertItem(vList2, aint(vI), vItem->wpClmTypeSort, vB);
  END;
  
  // alte Zeile löschen
  if (aCopy=false) then
    aVonDL->WinLstDatLineRemove(aVon);

  // CAPTION setzen....
  vI # 0;
  FOR vItem # vList->CteRead(_CteFirst)
  LOOP vItem # vList->CteRead(_CteNExt, vItem)
  WHILE (vItem > 0) do begin
    inc(vI);

    if (vI=1) then begin
      case (vItem->spID) of
        _TypeAlpha    : WinLstDatLineAdd(aNachDL, vItem->spCustom, aNach);
        _TypeBool     : WinLstDatLineAdd(aNachDL, vItem->spCustom='1', aNach);
        _TypeByte     : WinLstDatLineAdd(aNachDL, cnvia(vItem->spCustom), aNach);
        _TypeInt      : WinLstDatLineAdd(aNachDL, cnvia(vItem->spCustom), aNach);
        _TypeBigInt   : WinLstDatLineAdd(aNachDL, cnvba(vItem->spCustom), aNach);
        _TypeFloat    : WinLstDatLineAdd(aNachDL, cnvfa(vItem->spCustom), aNach);
        _TypeDecimal  : WinLstDatLineAdd(aNachDL, cnvma(vItem->spCustom), aNach);
        _TypeDate     : WinLstDatLineAdd(aNachDL, cnvda(vItem->spCustom), aNach);
        _TypeTime     : WinLstDatLineAdd(aNachDL, cnvta(vItem->spCustom), aNach);
        _TypeWord     : WinLstDatLineAdd(aNachDL, cnvia(vItem->spCustom), aNach);
      end;
    end
    else begin
      case (vItem->spID) of
        _TypeAlpha    : WinLstCellSet(aNachDL, vItem->spCustom,           vI, aNach);
        _TypeBool     : WinLstCellSet(aNachDL, vItem->spCustom='1',       vI, aNach);
        _TypeByte     : WinLstCellSet(aNachDL, cnvia(vItem->spCustom),    vI, aNach);
        _TypeInt      : WinLstCellSet(aNachDL, cnvia(vItem->spCustom),    vI, aNach);
        _TypeBigInt   : WinLstCellSet(aNachDL, cnvba(vItem->spCustom),    vI, aNach);
        _TypeFloat    : WinLstCellSet(aNachDL, cnvfa(vItem->spCustom),    vI, aNach);
        _TypeDecimal  : WinLstCellSet(aNachDL, cnvma(vItem->spCustom),    vI, aNach);
        _TypeDate     : WinLstCellSet(aNachDL, cnvda(vItem->spCustom),    vI, aNach);
        _TypeTime     : WinLstCellSet(aNachDL, cnvta(vItem->spCustom),    vI, aNach);
        _TypeWord     : WinLstCellSet(aNachDL, cnvia(vItem->spCustom),    vI, aNach);
      end;
    end;
  END;

  // SORTVALUE setzen....
  vI # 0;
  FOR vItem # vList2->CteRead(_CteFirst)
  LOOP vItem # vList2->CteRead(_CteNExt, vItem)
  WHILE (vItem > 0) do begin
    inc(vI);

    case (vItem->spID) of
      _TypeAlpha    : WinLstCellSet(aNachDL, vItem->spCustom,           vI, aNach, _WinLstDatModeSortInfo);
      _TypeBool     : WinLstCellSet(aNachDL, vItem->spCustom='1',       vI, aNach, _WinLstDatModeSortInfo);
      _TypeByte     : WinLstCellSet(aNachDL, cnvia(vItem->spCustom),    vI, aNach, _WinLstDatModeSortInfo);
      _TypeInt      : WinLstCellSet(aNachDL, cnvia(vItem->spCustom),    vI, aNach, _WinLstDatModeSortInfo);
      _TypeBigInt   : WinLstCellSet(aNachDL, cnvba(vItem->spCustom),    vI, aNach, _WinLstDatModeSortInfo);
      _TypeFloat    : WinLstCellSet(aNachDL, cnvfa(vItem->spCustom),    vI, aNach, _WinLstDatModeSortInfo);
      _TypeDecimal  : WinLstCellSet(aNachDL, cnvma(vItem->spCustom),    vI, aNach, _WinLstDatModeSortInfo);
      _TypeDate     : WinLstCellSet(aNachDL, cnvda(vItem->spCustom),    vI, aNach, _WinLstDatModeSortInfo);
      _TypeTime     : WinLstCellSet(aNachDL, cnvta(vItem->spCustom),    vI, aNach, _WinLstDatModeSortInfo);
      _TypeWord     : WinLstCellSet(aNachDL, cnvia(vItem->spCustom),    vI, aNach, _WinLstDatModeSortInfo);
    end;
  END;

  aVonDL->wpOrderPass # vOPVon;
  aNachDL->wpOrderPass # vOPNach;

  vList->cteClear(true);
  vList->cteclose();
  vList2->cteClear(true);
  vList2->cteclose();
end;


//========================================================================
//========================================================================
//========================================================================