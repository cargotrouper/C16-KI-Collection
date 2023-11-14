@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_F_WalzED_Main
//                    OHNE E_R_G
//  Info
//
//
//  04.07.2012  AI  Erstellung der Prozedur
//  15.11.2012  AI  Dickentoleranz eingebaut
//  23.04.2018  AH  BugFix: Buttonscommands
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit ( aEvt : event ) : logic
//    SUB RecDel();
//    SUB RefreshIfm ( opt aName : alpha; opt aChanged : logic )
//    SUB EvtFocusInit ( aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm ( aEvt : event; aFocusObject : int) : logic
//    SUB EvtMenuCommand ( aEvt : event; aMenuItem : int ) : logic
//    SUB RefreshMode ( opt aNoRefresh : logic )
//    SUB EvtLstDataInit
//    SUB EvtLstEditCommit
//    SUB EvtLstSelect
//    SUB EvtClose
//    SUB EvtClicked
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle          : 'Walzschritte'
  cMenuName       : 'Std.DL.Bearbeiten'
//  cMenuName : 'Std.Bearbeiten'
  cPrefix         : 'BA1_F_WalzED'
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit (
  aEvt      : event;
): logic
begin
/**
  gTitle    # Translate( cTitle );
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  Mode      # c_modeEdList;
  $clmDicke->wpFmtPostComma # Set.Stellen.Dicke;
  App_Main:EvtInit( aEvt );
**/
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # 0;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # 0;//cZList;
  gKey      # 0;//cKey;

  $clmDicke->wpFmtPostComma # Set.Stellen.Dicke;

  App_Main:EvtInit(aEvt);
  Mode # c_modeEdList;

end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  vHdl  : int;
  vID   : int;
end;
begin

  vHdl # Winsearch(gMDI, 'DL.List');
  if (vHdl=0) then RETURN;
  if (vHdl->wpCurrentInt=0) then RETURN

  vHdl->WinLstDatLineRemove( _WinLstDatLineCurrent );
  vHdl->WinUpdate( _winUpdOn, _winLstPosTop );
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm (
  opt aName     : alpha;
  opt aChanged  : logic)
begin
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt          : event;
  aFocusObject  : int;
) : logic
begin
  RETURN true;
end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt          : event;
  aFocusObject  : int;
) : logic
begin
  RETURN true;
end;


//========================================================================
//  EvtMenuCommand
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtMenuCommand (
  aEvt            : event;
  aMenuItem       : int;
) : logic
begin
//  if (aMenuItem->wpName='Mnu.DL.Delete') then RecDel();
  RETURN Lib_Datalist:EvtMenuCommand( aEvt, aMenuItem );
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode (
  opt aNoRefresh : logic;
)
local begin
  vHdl           : int;
end
begin
  gMenu # gFrmMain->WinInfo( _winMenu );

  // Buttons und Menüs sperren
  vHdl # gMdi->WinSearch( 'Mark' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch( 'Search' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # true;
end;


//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged (
	aEvt             : event;
	aRect            : rect;
	aClientSize      : point;
	aFlags           : int;
) : logic
local begin
  vRect     : rect;
end
begin
  if ( aFlags & _winPosSized != 0 ) then begin
    vRect            # $DL.List->wpArea;
    vRect:right      # aRect:right  - aRect:left - 4;
    vRect:bottom     # aRect:bottom - aRect:top  - 28;
    $DL.List->wpArea # vRect;
  end;
  RETURN true;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit (
  aEvt            : event;
  aId             : int;
) : logic
local begin
  vOk             : logic;
  vEinsatzmatNr   : int;
  vCoilNr         : alpha;
end;
begin
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
  vA    : alpha;
  vHdl  : int;
end;
begin
  // <<< MUSTER >>>
  if (aColumn->wpname='clmDickentol') then begin
    vHdl # Wininfo(aEvt:obj,_WinLstEditObject);
    vA # vHdl->wpcaption;
    vA # Lib_Berechnungen:Toleranzkorrektur(vA,Set.Stellen.Dicke);
    vHdl->wpcaption # vA;
  end;
  RETURN Lib_Datalist:EvtLstEditCommit(aEvt, aColumn, aKey, aFocusObject);
end;


//========================================================================
// EvtClose
//              Schliessen eines Fensters
//========================================================================
sub EvtClose (
  aEvt            : event;
) : logic
local begin
  Erx         : int;
  vI          : int;
  vAnz        : int;
  v703        : int;
end;
begin

  vAnz # WinLstDatLineInfo($DL.List, _WinLstDatInfoCount);

  // kein Einträge?
  if (vAnz = 0) then RETURN true;

  Erx # Msg(506016,aint(vAnz),_WinIcoQuestion, _WinDialogYesNoCancel,2);
  if (Erx=_WinIdNo) then RETURN false;
  if (Erx=_WinIdCancel) then RETURN true;


  gSelected # CteOpen(_ctelist);
  RecBufClear(703);
  BAG.F.Nummer            # BAG.P.Nummer;
  BAG.F.Fertigung         # 1;
  BAG.F.AutomatischYN     # y;
  "BAG.F.KostenträgerYN"  # y;
  BAG.F.MEH               # 'kg';
  BAG.F.Streifenanzahl    # 1;

//BAG.F.Dicke # 10.0;
//  v703 # RekSave(703);
//  vItem # CteInsertItem(v703List, aint(v703), v703, '', _CteLast);

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo($DL.List, _WinLstDatInfoCount)) do begin
    WinLstCellGet($DL.List, BAG.F.Dicke , 1, vI);
    WinLstCellGet($DL.List, BAG.F.Dickentol , 2, vI);
    WinLstCellGet($DL.List, BAG.F.Bemerkung , 3, vI);

    v703 # RekSave(703);
    CteInsertItem(gSelected, aint(v703), v703, '', _CteLast);
  END;  // ...For Einzelkarte

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
    'Delete' :
      RecDel();
  end;
end;


//========================================================================
//========================================================================
sub StartEdit()
begin
  Lib_DataList:StartListEdit($DL.List, c_ModeEdListEdit, 0, _winLstEditClearChanged );
end;


//========================================================================