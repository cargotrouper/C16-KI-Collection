@A+
//==== Business-Control ===================================================
//
//  Prozedur    Job_Err_Main
//                    OHNE E_R_G
//  Info
//        Job-Server Fehlermeldungen
//
//  13.10.2010  PW  Erstellung der Prozedur
//  14.03.2022  AH  ERX
//
//  Subprozeduren
//    sub EvtInit( aEvt : event; ) : logic
//    sub RecInit()
//    sub RecSave() : logic;
//    sub RecCleanup() : logic
//    sub RecDel()
//    sub RefreshIfm( opt aName : alpha; )
//    sub EvtFocusInit( aEvt : event; aFocusObject : int ) : logic
//    sub EvtFocusTerm( aEvt : event; aFocusObject : int ) : logic
//    sub RefreshMode( opt aNoRefresh : logic );
//    sub EvtMenuCommand( aEvt : event; aMenuItem : int ) : logic
//    sub EvtClicked( aEvt : event; ) : logic
//    sub EvtLstDataInit( aEvt : Event; aRecId : int; opt aMark : logic; );
//    sub EvtLstSelect( aEvt : event; aRecID : int; ) : logic
//    sub EvtClose( aEvt : event; ) : logic
//========================================================================
@I:Def_Global

define begin
  cTitle    : 'Job-Server Fehlermeldungen'
  cMenuName : 'Job.Err.Bearbeiten'
  cPrefix   : 'Job_Err'
  cZList    : $ZL.Job.Err
  cFile     : 908
  cKey      : 1
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

  App_Main:EvtInit( aEvt );
  mode # c_modeEdList;
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

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
  vHdl : int;
end
begin
  gMenu # gFrmMain->WinInfo( _winMenu );

  /* Zugriff sperren */
  vHdl # gMDI->WinSearch( 'New' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # true;

  vHdl # gMenu->WinSearch( 'Mnu.New' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # true;

  vHdl # gMDI->WinSearch( 'Edit' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # true;

  vHdl # gMenu->WinSearch( 'Mnu.Edit' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # true;

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

    'Mnu.DeleteAll' : begin
      if(Msg(908000, AInt(RecInfo(908, _RecCount)), 0, _WinDialogYesNo, 2) = _WinIdYes) then
        Lib_Rec:ClearFile(908); // Job-Server Fehlermeldungen

      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
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