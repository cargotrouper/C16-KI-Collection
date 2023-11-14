@A+
//==== Business-Control ==================================================
//
//  Prozedur    Log_Main
//                    OHNE E_R_G
//  Info
//
//
//  05.09.2008  PW  Erstellung der Prozedur
//  28.08.2012  ST  Umstellung auf Standardmenü
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//  sub EvtInit( aEvt : event; ) : logic
//  sub RecInit()
//  sub RecSave() : logic;
//  sub RecCleanup() : logic
//  sub RecDel()
//  sub RefreshIfm( opt aName : alpha; )
//  sub EvtFocusInit( aEvt : event; aFocusObject : int ) : logic
//  sub EvtFocusTerm( aEvt : event; aFocusObject : int ) : logic
//  sub RefreshMode( opt aNoRefresh : logic );
//  sub EvtMenuCommand( aEvt : event; aMenuItem : int ) : logic
//  sub EvtClicked( aEvt : event; ) : logic
//  sub EvtLstDataInit( aEvt : Event; aRecId : int; opt aMark : logic; );
//  sub EvtLstSelect( aEvt : event; aRecID : int; ) : logic
//  sub EvtClose( aEvt : event; ) : logic
//  sub ExportHistory()
//
//========================================================================
@I:Def_Global
@I:Def_Rights

declare ExportHistory(opt aDat : date)
declare ImportHistory()

define begin
  cTitle    : 'Versionshistorie'
  cMenuName : 'Std.Bearbeiten'
  cPrefix   : 'Log'
  cZList    : $ZL.Log
  cFile     : 995
  cKey      : 1
  cListen     : 'Log'

  // Server Lizenz
  cSrvLicense : 'CD152667MN/H'
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit( aEvt : event; ) : logic
begin
  gTitle    # Translate( cTitle );
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gFile     # cFile;
  gKey      # cKey;
  w_Listen  # cListen;
  App_Main:EvtInit( aEvt );
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
  if ( Log.Datum = 0.0.0 ) and ( Log.Zeit = 00:00 ) then begin
    Log.Datum # today;
    Log.Zeit  # now;
  end;

  $edLog.StandardYN->WinFocusSet( true );
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
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  if ( DbaLicense( _dbaSrvLicense ) != cSrvLicense ) then
    RETURN false;

  if ( Mode = c_ModeEdit ) then begin
    Erx # RekReplace( gFile, _recUnlock, 'MAN' );
    if ( Erx != _rOk ) then begin
      Msg( 001000 + Erx, gTitle, 0, 0, 0 );
      RETURN false;
    end;
    PtD_Main:Compare( gFile );
  end;
  else begin
    Log.Installationsdat # Log.Datum;

    Erx # RekInsert( gFile, 0, 'MAN' );
    if ( Erx != _rOk ) then begin
      Msg( 001000 + Erx, gTitle, 0, 0, 0 );
      RETURN false;
    end;
  end;

  RETURN true;
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
  if ( DbaLicense( _dbaSrvLicense ) != cSrvLicense ) then
    RETURN;

  if ( Msg( 000001, '', _winIcoQuestion, _winDialogYesNo, 2 ) = _winIdNo ) then
    RETURN;

  RekDelete( gFile, 0, 'MAN' );
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm( opt aName : alpha; )
begin
  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit( aEvt : event; aFocusObject : int ) : logic
begin
end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm( aEvt : event; aFocusObject : int ) : logic
begin
  RefreshIfm( aEvt:Obj->wpName );

  RETURN true;
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode( opt aNoRefresh : logic );
local begin
  vHdl        : int;
  vDisableAll : logic;
end
begin
  gMenu       # gFrmMain->WinInfo( _winMenu );
  vDisableAll # ( DbaLicense( _dbaSrvLicense ) != cSrvLicense );

  /* Zugriff sperren */
  vHdl # gMDI->WinSearch( 'New' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # vHdl->wpDisabled or vDisableAll;

  vHdl # gMenu->WinSearch( 'Mnu.New' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # vHdl->wpDisabled or vDisableAll;

  vHdl # gMDI->WinSearch( 'Edit' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # vHdl->wpDisabled or vDisableAll;

  vHdl # gMenu->WinSearch( 'Mnu.Edit' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # vHdl->wpDisabled or vDisableAll;

  vHdl # gMDI->WinSearch( 'Delete' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # vHdl->wpDisabled or vDisableAll;

  vHdl # gMenu->WinSearch( 'Mnu.Delete' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # vHdl->wpDisabled or vDisableAll;

  RefreshIfm();
end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand( aEvt : event; aMenuItem : int ) : logic
local begin
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
end;
begin
  if ( Mode = c_ModeList ) then
    RecRead( gFile, 0, 0, gZLList->wpDbRecId );

  case ( aMenuItem->wpName ) of
    'NextPage' : begin
    end;

    'PrevPage' : begin
    end;

    'Mnu.Auswahl' : begin
      vHdl # WinFocusGet();
      if ( vHdl != 0 ) then begin
        case ( vHdl->wpName ) of
          // '...' :   Auswahl('...');
        end;
      end;
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;
  end;
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked( aEvt : event; ) : logic
begin
  if Mode = c_ModeView then
    RETURN true;

  case ( aEvt:Obj->wpName ) of
  end;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit( aEvt : Event; aRecId : int; opt aMark : logic; );
begin
  RefreshMode();
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect( aEvt : event; aRecID : int; ) : logic
begin
  RecRead( gFile, 0, _recId, aRecID );
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose( aEvt : event; ) : logic
begin
  RETURN true;
end;


//========================================================================
// ExportHistory
//          History in Text !AUTO:CHANGELOG exportieren
//========================================================================
sub ExportHistory(opt aDat : date)
local begin
  Erx       : int;
  vStartDate : date;
  vTxt       : int;
  vI         : int;
  vLine      : alpha(250);
  vSel       : int;
  vSelName   : alpha;
end;
begin
  if ( DbaLicense( _dbaSrvLicense ) != cSrvLicense ) then
    RETURN;

  // Datumsabfrage für Startdatum des Exports
  vStartDate # aDat;
  if (aDat=0.0.0) then begin
    vStartDate # today;
    vStartDate->vmMonthModify( -2 );
    Dlg_Standard:Datum( 'Versionshistorie speichern ab:', var vStartDate, vStartDate );
  end;
  
  // Selektion
  vSel # SelCreate( 995, 0 );
  vSel->SelDefQuery( '', 'Log.Datum >= ' + CnvAD( vStartDate, _fmtInternal ) );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  // Texthandle
  vTxt # TextOpen( 512 );
  vI   # 1;

  FOR  Erx # RecRead( 995, vSel, _recFirst );
  LOOP Erx # RecRead( 995, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( Log.Bereich = '!UPDATE!' ) then
      CYCLE;

    vLine # CnvAD( Log.Datum, _fmtInternal ) + CnvAT( Log.Zeit, _fmtInternal ) + CnvAI( CnvIL( Log.StandardYN ) ) + Log.Bereich + '|||' + Log.Bemerkung;
    vTxt->TextLineWrite( vI, vLine, _textLineInsert );
    vI # vI + 1;
  END;

  TxtWrite(vTxt, '!AUTO:CHANGELOG', 0 );
  vTxt->TextClose();
  vSel->SelClose();
  SelDelete( 995, vSelName );
end;


//========================================================================