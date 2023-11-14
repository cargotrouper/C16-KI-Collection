@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Kontakte
//                      OHNE E_R_G
//  Info
//      Library zum Verwenden der DataList.
//      Erlaubt eine Funktion EvtLstLineEdited mit der Signatur
//        SUB EvtLstLineEdited ( aDataList : int; aColumn : int; aRow : int; )
//      die beim Abschluss der Bearbeitung einer Zeile in der _Main Prozedur
//      ausgeführt wird.
//
//  11.06.2012  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB StartListEdit ( aList : int; optaColumn : int; optaFlags : int; aEditPossible : logic)
//    SUB EvtLstDataInit
//    SUB EvtKeyItem
//    SUB EvtLstEditStart
//    SUB EvtLstEditCommit
//    SUB EvtLstEditFinished
//    SUB EvtLstSelectPopup
//    SUB EvtMouseItem
//
//========================================================================
@I:Def_Global
@I:Def_Kontakte

//========================================================================
//  _TypInPopupList
//
//========================================================================
sub _TypInPopupList(
  aDL         : int;
  aString     : alpha(4096);
  aName       : alpha)
begin
//debug('suche '+aname+' in '+aString);
  if (StrFind(aString,'|'+aName+'|',0)=0) then begin
    aDL->WinLstDatLineAdd(Translate(aName));
    aDL->WinLstCellSet(aName,2);
  end;
end;


//========================================================================
//  _Killempty
//
//========================================================================
sub _KillEmpty(aDL :int );
local begin
  vA    : alpha(4096);
  vName : alpha;
end;
begin
return;
  // leere Zeile???
  aDL->WinLstCellGet(vA,3,_WinLstDatLineCurrent);
  if (vA='') then begin
    aDL->WinLstCellGet(vName,5,_WinLstDatLineCurrent);
    // aus String entfernen
    aDL->wpcustom # Str_ReplaceAll(aDL->wpcustom, '|'+vName+'|', '');

    aDL->WinLstDatLineRemove( _WinLstDatLineCurrent );
  end;

end;


//========================================================================
//  _SetDataForName
//
//========================================================================
sub _SetDataForName(
  aDL   : int;
  aZ    : int;
  aName : alpha(4096)) : logic
local begin
  vTyp  : alpha;
  vIcon : int;
end;
begin
  case aName of
    c_KTD_TEL, c_KTD_TEL2, c_KTD_MOBIL, c_KTD_INTERN,
    c_KTD_TEL_PRIV, c_KTD_TEL2_PRIV, c_KTD_MOBIL_PRIV :
                  vTyp  # c_KTD_TYP_TEL;
    c_KTD_FAX, c_KTD_FAX_PRIV :
                  vTyp  # c_KTD_TYP_FAX;
    c_KTD_EMAIL, c_KTD_EMAIL_PRIV :
                  vTyp  # c_KTD_TYP_EMAIL;
    c_KTD_HOMEPAGE :
                  vTyp  # c_KTD_TYP_URL;
    // manuelle...
    c_KTD_SONST_TEL :
                  vTyp  # c_KTD_TYP_TEL_SONST;
    c_KTD_SONST_FAX :
                  vTyp  # c_KTD_TYP_FAX_SONST;
    c_KTD_SONST_EMAIL :
                  vTyp  # c_KTD_TYP_EMAIL_SONST;
    c_KTD_SONST_URL :
                  vTyp  # c_KTD_TYP_URL_SONST;
  end;

  vIcon # _WinImgNone;
  case (vTyp) of
    c_KTD_TYP_TEL, c_KTD_TYP_TEL_SONST      : vIcon # _WinImgPhone;
    c_KTD_TYP_FAX, c_KTD_TYP_FAX_SONST      : vIcon # _WinImgFax;
    c_KTD_TYP_EMAIL, c_KTD_TYP_EMAIL_SONST  : vIcon # _WinImgeMail;
    c_KTD_TYP_URL, c_KTD_TYP_URL_SONST      : vIcon # _WinImgInternet;
  end;

  aDL->WinLstCellSet(vIcon,1, aZ);
  aDL->WinLstCellSet(Translate(aName),2, aZ);
  aDL->WinLstCellSet(vTyp,4, aZ);
  aDL->WinLstCellSet(aName,5, aZ);

  // bei "Sonstige" freie Eingabe
  if (vTyp=c_KTD_TYP_TEL_SONST) or
    (vTyp=c_KTD_TYP_EMAIL_SONST) or
    (vTyp=c_KTD_TYP_FAX_SONST) or
    (vTyp=c_KTD_TYP_URL_SONST) then
    RETURN true;

  RETURN false;
end;


//========================================================================
//  StartListEdit
//
//========================================================================
sub StartListEdit (
  aList             : int;
  aColumn           : int;
  opt aFlags        : int)
local begin
  vHdl  : int;
  vTyp  : alpha;
end
begin

  if (aList = 0) then RETURN
  if (mode<>c_ModeEdit) and (mode<>c_ModeNew) then RETURN;
  if (aList->wpcurrentint=0) then RETURN;

  $clmName->wpcustom # '';

  aList->WinLstCellGet(vTyp,2,_WinLstDatLineCurrent);

  if (aColumn<>0) then begin
    if (aColumn->wpname='clmName') and (vTyp<>'') then
      aColumn # $clmdaten;
  end;

  // keine Spalte angegeben -> erste mögliche Spalte markieren
  if ( aColumn = 0 ) then begin
    FOR  aColumn # aList->WinInfo( _winFirst );
    LOOP aColumn # aColumn->WinInfo( _winNext );
    WHILE ( aColumn != 0 ) DO BEGIN
      if (aColumn->wpname='clmName') and (vTyp<>'') then begin
        CYCLE;
      end;
      if ( aColumn->wpCustom != '_SKIP' ) then
        BREAK;
    END;
    if ( aColumn = 0 ) then begin
      RETURN;
    end;

    aColumn->wpCustom # '_FIRST';
  end;

//  aFlags # aFlags | _winLstEditLst;   // Popup anbieten
  if (aColumn->wpname='clmName') then
    aFlags # aFlags | _WinLstEditLstAlpha;   // immer Popup anbieten
  aList->WinLstEdit( aColumn, aFlags );
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
) : logic
local begin
  vTmp  : int;
  vA    : alpha(4096);
end;
begin

  if (mode<>c_modeNew) and (mode<>c_modeEdit) then RETURN false;

  // Löschen?
  if ( aKey = _WinKeyDelete) then begin
    if (aEvt:obj->wpcurrentint=0) then RETURN false;

//    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;
    aEvt:obj->WinLstCellGet(vA,5,_WinLstDatLineCurrent);
    aEvt:obj->wpcustom # Str_ReplaceAll(aEvt:obj->wpcustom, '|'+vA+'|', '');

    aEvt:obj->WinLstDatLineRemove( _WinLstDatLineCurrent );
    RETURN true;
  end;


  // Neu?
  if ( aKey = _winKeyf4 ) then begin
    aEvt:Obj->WinLstDatLineAdd(0, _WinLstDatLineLast);
    aEvt:obj->wpcurrentint # aEvt:Obj->WinLstDatLineInfo(_WinLstDatInfoCount);
    StartListEdit( aEvt:obj, 0, _winLstEditClearChanged );
    RETURN true;
  end;


  // Return = Edit
  //if (aKey = _WinKeyTab) or
  if ( aKey = _winKeyReturn ) then begin

    if ( aEvt:obj->WinLstDatLineInfo( _winLstDatInfoCount ) = 0 ) then
      RETURN false;

    if ( aEvt:obj->wpCurrentInt = 0 ) then
      aEvt:obj->wpCurrentInt # 1;

    StartListEdit( aEvt:obj, 0, _winLstEditClearChanged );
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
local begin
  vA    : alpha;
  vZ    : int;
  vTyp  : alpha;
  vI    : int;
  vDL   : int;
  vMax  : int;
end;
begin

  vMax # 32;
  if (aColumn->wpname='clmDaten') then vMax # 160;
  aEdit->wpLengthMax  # vMax;
  aEdit->wpcustom     # aint(Wininfo(aColumn,_winitem));
  aEdit->wpname       # 'edEditList';

  if ( aEdit > 0 ) then
    aEdit->wpColFocusBkg  # Set.Col.Field.Cursor;

  if ( aList > 0 ) then
    aList->wpComboStyle # _winComboSingleClick;

/***/
  if (aColumn->wpname='clmName') then begin

    vDL # aEvt:obj;

    _TypInPopupList(aList, vDL->wpcustom, c_KTD_TEL);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_TEL2);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_MOBIL);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_INTERN);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_FAX);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_EMAIL);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_HOMEPAGE);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_TEL_PRIV);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_TEL2_PRIV);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_MOBIL_PRIV);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_FAX_PRIV);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_EMAIL_PRIV);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_SONST_TEL);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_SONST_FAX);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_SONST_EMAIL);
    _TypInPopupList(aList, vDL->wpcustom, c_KTD_SONST_URL);

//    aList->WinLstCellSet('angezeigt',2);
    aEdit->wpReadOnly   # TRUE;
    aEdit->wpPopupType  # _WinPopupListAuto;

    // Popuplist bei Selektion direkt öffnen
    aList->wpComboStyle # _WinComboTrackNoSelect;
    aList->wpcurrentint # 1;
    aEdit->wpPopupOpen  # true;

    // Der Popuplist das ein EvtLstSelect hinterlegen
    aList->WinEvtProcNameSet(_WinEvtLstSelect, __PROC__ + ':EvtLstSelectPopup');
//debug(Lib_Debug:TypeToString(wininfo(aList,_Wintype)));// _WinTypeDataListPopup
//    aList->WinEvtProcNameSet(_WinEvtTerm, __PROC__ + ':EvtLstTermPopup');

    vI # WinInfo(aList,_winfirst);
    vI # WinInfo(aList,_winParent);
    vI->wpfontparent # n;
    vI # WinInfo(aList,_winfirst);
    if (vI<>0) then begin   // 1.column
      vI->wpvisible # true;
      vI->wpClmStretch # y;
      vI # WinInfo(vI,_winNext);
      if (vI<>0) then begin // 2.column
        vI->wpvisible # false;
        vI->wpClmStretch # n;
      end;
    end;

  end;

  RETURN true;
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
  vName : alpha;
  vTyp  : alpha;
end;
begin

  if (aColumn<>0) then
    if (aColumn->wpname='clmName') then begin
    aEvt:obj->WinLstCellGet(vTyp,4,_WinLstDatLineCurrent);
    aEvt:obj->WinLstCellGet(vName,5,_WinLstDatLineCurrent);
    if (vTyp='') then begin
      aEvt:obj->winfocusset(true);
      RETURN false;
    end;
    if (vTyp<'A') then begin
      RETURN true;
    end;
  end;

  // Return speichert
  if (aKey=_WinKeyTab) or (aKey=_WinKeyReturn) then RETURN true;

  // alle anderen Tasen = Abbruch
  if (aKey<>0) then RETURN false;

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
  vCap            : alpha;
  vKey            : int;   // unmaskiert
  vMoveBack       : logic; // Fokussierung
  vColumn         : int;   // Deskriptor der Spalte
  vRestart        : logic; // Spaltensprung über Ende oder Anfang
  vHdl            : int;
  vA              : alphA(500);
end;
begin

  vKey # aKey & _winKeyMask;

  // Leere Caption?
  if (aColumn<>0) then
    if (aColumn->wpname='clmName') then begin
    aEvt:obj->WinLstCellGet(vCap,2,_WinLstDatLineCurrent);
    if (vCap='') then begin
      aEvt:obj->WinLstDatLineRemove( _WinLstDatLineCurrent );
      RETURN true;
    end;
  end;

  // Abbruch?
  if ( aKey & _winKeyEsc > 0 ) then begin
    _KillEmpty(aEvt:obj);
    RETURN true;
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

        if ( vColumn->wpCustom != '_SKIP' ) then
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

        if ( vColumn->wpCustom != '_SKIP' ) then
          BREAK;
      UNTIL ( vColumn = aColumn );
    end;
  end;


  // keine andere Spalte vorgemerkt? -> Edit beenden
  if ( vColumn = aColumn ) or ( vRestart ) then begin
    _KillEmpty(aEvt:obj);
    RETURN true;
    end

  else begin
    // zum nächsten Feld
    StartListEdit( aEvt:obj, vColumn,0);
  end;

end;


//========================================================================
// Event wird ausgelöst wenn in der Popuplist ein Eintrag ausgewählt wurde
//
//========================================================================
sub EvtLstSelectPopup(
  aEvt                 : event;    // Ereignis
  aID                  : int;      // Record-ID des Datensatzes oder Zeilennummer
) : logic;
local begin
  vName   : alpha(4096);
  vCap    : alpha(4096);
  vDL     : int;
  vIcon   : int;
  vTyp    : alpha;
  vEdit   : int;
  vSonst  : logic;
end;
begin

  aEvt:obj->WinLstCellGet(vName,2,_WinLstDatLineCurrent);
  aEvt:obj->WinLstCellGet(vCap,1,_WinLstDatLineCurrent);

//debug('c:'+vCap + '   a:'+vA);
  vDL  # Wininfo(aEvt:obj, _Winparent); // Edit
  vDL  # Wininfo(vDL, _Winparent);      // Popup
  vDL  # Wininfo(vDL, _Winparent);      // Datalist

  vSonst # _SetDataForName(vDL, _WinLstDatLineCurrent, vName);

  vDL->WinLstCellGet(vIcon,1,_WinLstDatLineCurrent);
  vDL->WinLstCellGet(vCap,3,_WinLstDatLineCurrent);
  vDL->WinLstCellGet(vTyp,4,_WinLstDatLineCurrent);

  if (vSonst) then begin
    vEdit # WinInfo(aEvt:obj,_WinLstEditObject);
    vEdit->wpreadonly   # false;
    vEdit->wpcaption    # '';
    vEdit->wpPopupType  # _WinPopupNone;
    RETURN true;
  end;

  // bei Konstanten direkt auf Inhalt weiterleiten
  // Merken
  vDL->wpcustom # vDL->wpcustom + '|'+vName+'|';
  vDL->winfocusset(true);
  StartListEdit(vDL, $clmDaten,0);
  RETURN true;
end;


//========================================================================
//  EvtMouseItem
//
//========================================================================
sub EvtMouseItem(
  aEvt                 : event;    // Ereignis
  aButton              : int;      // Maustaste
  aHitTest             : int;      // Hittest-Code
  aItem                : handle;   // Spalte oder Gantt-Intervall
  aID                  : int;      // RecID bei RecList / Zelle bei GanttGraph / Druckobjekt bei PrtJobPreview
) : logic;
local begin
  vA    : alpha(4096);
  vIcon : int;
end;
begin

  // Icon geklickt?
  if (aButton=_Winmouseleft) and (aHitTest=_WinHitLstView) and (aItem<>0) then begin
    if (aItem->wpname='clmIcon') then begin
      aEvt:obj->WinLstCellGet(vIcon,1,_WinLstDatLineCurrent);
      aEvt:obj->WinLstCellGet(vA,3,_WinLstDatLineCurrent);
      case (vIcon) of
        _WinImgPhone    : Lib_Tapi:TapiDialNumber(vA);
//        _WinImgFAX      : todo('fax');
        _WinImgemail    : SysExecute('*mailto:'+vA,'',0);
        _WinImginternet : SysExecute('*http://'+vA,'',0);
      end;
      RETURN true;
    end;
  end;


  // Doppelklick auf Feld = Edit
  if ( aId > 0 ) and ( aItem > 0 ) and ( aButton = _winMouseLeft | _winMouseDouble ) then begin
    StartListEdit( aEvt:obj, $clmName, _winLstEditClearChanged );
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
//========================================================================