@A+
//==== Business-Control ==================================================
//
//  Prozedur    ZaB_Main
//                      OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  03.11.2008  PW  Neue Datenstruktur; Überarbeitung & Import
//
//  Subprozeduren
//    SUB EvtInit ( aEvt : event ) : logic
//    SUB RefreshIfm ( opt aName : alpha )
//    SUB RecInit ()
//    SUB RecSave () : logic;
//    SUB EvtFocusInit ( aEvt : event; aFocusObject : int ) : logic
//    SUB RecCleanup() : logic
//    SUB RecDel ()
//    SUB EvtFocusTerm ( aEvt : event; aFocusObject : int ) : logic
//    SUB RefreshMode ( opt aNoRefresh : logic )
//    SUB EvtChanged ( aEvt : event ) : logic
//    SUB EvtMenuCommand ( aEvt : event; aMenuItem : int ) : logic
//    SUB EvtClicked ( aEvt : event ) : logic
//    SUB EvtLstDataInit( aEvt : event; aRecId : int; opt aMark : logic )
//    SUB EvtLstSelect ( aEvt : event; aRecID : int ) : logic
//    SUB EvtClose ( aEvt : event ): logic
//    SUB ImportAlt () : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle    : 'Zahlungsbedingungen'
  cFile     : 816
  cMenuName : 'Std.Bearbeiten'
  cPrefix   : 'ZaB'
  cZList    : $ZL.Zahlungsbedingungen
  cKey      : 1
  cListen   : 'Zahlungsbedingungen'
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit ( aEvt : event ) : logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen  # cListen;

// Auswahlfelder setzen...
  //SetStdAusFeld('', '');

  App_Main:EvtInit( aEvt );
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm ( opt aName : alpha; )
begin
  if ( aName = '' ) then begin
    $lbZaB.Bezeichnung1.L1->wpCaption # Set.Sprache1;
    $lbZaB.Bezeichnung1.L1B->wpCaption # Set.Sprache1;
    $lbZaB.Bezeichnung1.L2->wpCaption # Set.Sprache2;
    $lbZaB.Bezeichnung1.L3->wpCaption # Set.Sprache3;
    $lbZaB.Bezeichnung1.L4->wpCaption # Set.Sprache4;
    $lbZaB.Bezeichnung1.L5->wpCaption # Set.Sprache5;
  end;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit ()
begin
  $edZaB.Nummer->WinFocusSet( true );
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave () : logic
local begin
  Erx : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // Skonto Überprüfung
  if ( ZaB.Sknt1.VonTag = 0 ) or ( ZaB.Sknt1.BisTag = 0 ) then begin
    ZaB.Sknt1.VonTag # 0;
    ZaB.Sknt1.BisTag # 0;
  end
  else if ( ZaB.Sknt1.VonTag > ZaB.Sknt1.BisTag ) then begin
    Msg( 816002, '', 0, 0, 0 );
    RETURN false;
  end;

  if ( ZaB.Sknt2.VonTag = 0 ) or ( ZaB.Sknt2.BisTag = 0 ) then begin
    ZaB.Sknt2.VonTag # 0;
    ZaB.Sknt2.BisTag # 0;
  end
  else if ( ZaB.Sknt2.VonTag > ZaB.Sknt2.BisTag ) then begin
    Msg( 816002, '', 0, 0, 0 );
    RETURN false;
  end;

  if ( ZaB.Sknt1.VonTag != 0 ) and ( ZaB.Sknt2.VonTag != 0 ) and
    ( ZaB.Sknt1.BisTag >= ZaB.Sknt2.VonTag ) and ( ZaB.Sknt2.BisTag >= ZaB.Sknt1.VonTag ) then begin
    Msg( 816001, '', 0, 0, 0 );
    RETURN false;
  end;

  // Speicherung
  if ( Mode = c_ModeEdit ) then begin
    Erx # RekReplace( gFile, _recUnlock, 'MAN' );
    if ( Erx != _rOk ) then begin
      Msg( 001000 + Erx, gTitle, 0, 0, 0 );
      RETURN false;
    end;
    PtD_Main:Compare( gFile );
  end
  else begin
    Erx # RekInsert( gFile, 0, 'MAN' );
    if ( Erx != _rOk ) then begin
      Msg( 001000 + Erx, gTitle, 0, 0, 0 );
      RETURN false;
    end;
  end;

  RETURN true;
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit ( aEvt : event; aFocusObject : int ) : logic
begin
  RETURN true;
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup () : logic
begin
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel ()
begin
  if ( Msg( 000001, '', _winIcoQuestion, _winDialogYesNo, 2 ) = _winIdNo ) then
    RETURN;

  RekDelete( gFile, 0, 'MAN' );
end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm ( aEvt : event; aFocusObject : int ) : logic
begin
  RefreshIfm( aEvt:obj->wpName );
  $lb.VonTag1->winupdate(_WinUpdFld2Obj);
  $lb.VonTag2->winupdate(_WinUpdFld2Obj);
  $lb.BisTag1->winupdate(_WinUpdFld2Obj);
  $lb.BisTag2->winupdate(_WinUpdFld2Obj);

  if (aEvt:Obj->wpname='edZaB.Bezeichnung1.L1') then
    $edZaB.Bezeichnung1.L1B->wpcaption # aEvT:Obj->wpcaption;
  if (aEvt:Obj->wpname='edZaB.Bezeichnung1.L1B') then
    $edZaB.Bezeichnung1.L1->wpcaption # aEvT:Obj->wpcaption;
  if (aEvt:Obj->wpname='edZaB.Bezeichnung2.L1') then
    $edZaB.Bezeichnung2.L1B->wpcaption # aEvT:Obj->wpcaption;
  if (aEvt:Obj->wpname='edZaB.Bezeichnung2.L1B') then
    $edZaB.Bezeichnung2.L1->wpcaption # aEvT:Obj->wpcaption;

  RETURN true;
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode ( opt aNoRefresh : logic )
local begin
  vHdl : int;
end
begin
  gMenu # gFrmMain->WinInfo( _winMenu );

  vHdl # gMdi->WinSearch( 'New' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # ( vHdl->wpDisabled ) or ( Rechte[Rgt_ZaB_Anlegen] = false );
  vHdl # gMenu->WinSearch( 'Mnu.New' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # ( vHdl->wpDisabled ) or ( Rechte[Rgt_ZaB_Anlegen] = false );

  vHdl # gMdi->WinSearch( 'Edit' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # ( vHdl->wpDisabled ) or ( Rechte[Rgt_ZaB_aendern] = false );
  vHdl # gMenu->WinSearch( 'Mnu.Edit' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # ( vHdl->wpDisabled ) or ( Rechte[Rgt_ZaB_aendern] = false );

  vHdl # gMdi->WinSearch( 'Delete' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # ( vHdl->wpDisabled ) or ( Rechte[Rgt_ZaB_loeschen] = false );
  vHdl # gMenu->WinSearch( 'Mnu.Delete' );
  if ( vHdl != 0 ) then
    vHdl->wpDisabled # ( vHdl->wpDisabled ) or ( Rechte[Rgt_ZaB_loeschen] = false );

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


  if ( Mode != c_ModeOther ) and ( Mode != c_ModeList ) then
    RefreshIfm();
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged ( aEvt : event ) : logic
local begin
  vName   : alpha;
  vTxtHdl : int;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if ( Mode = c_ModeView ) then RETURN true;

  case ( aEvt:Obj->wpName ) of
    'cbZaB.abRechDatumYN'  : begin
      "ZaB.abRechDatumYN" # ( aEvt:Obj->wpCheckState  = _winStateChkChecked );
      "ZaB.abLFSDatumYN"  # ( aEvt:Obj->wpCheckState != _winStateChkChecked );

      $cbZaB.abRechDatumYN->winUpdate( _winUpdFld2Obj );
      $cbZaB.abLFSDatumYN->winUpdate( _winUpdFld2Obj );
    end;
    'cbZaB.abLFSDatumYN' : begin
      "ZaB.abRechDatumYN" # ( aEvt:Obj->wpCheckState != _winStateChkChecked );
      "ZaB.abLFSDatumYN"  # ( aEvt:Obj->wpCheckState  = _winStateChkChecked );

      $cbZaB.abRechDatumYN->winUpdate( _winUpdFld2Obj );
      $cbZaB.abLFSDatumYN->winUpdate( _winUpdFld2Obj );
    end;
  end;
end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand ( aEvt : event; aMenuItem : int ) : logic
local begin
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
    end;

  end;  // case

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked ( aEvt : event ) : logic
begin
  if ( Mode = c_ModeView ) then
    RETURN true;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit( aEvt : event; aRecId : int; opt aMark : logic )
begin
//  Refreshmode();
  if (ZaB.SperreNeuYN) then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect ( aEvt : event; aRecID : int ) : logic
begin
  RecRead( gFile, 0, _recId, aRecID );
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose ( aEvt : event ) : logic
begin
  RETURN true;
end;


//========================================================================
// ImportAlt
//          Alte Daten importieren
//========================================================================
sub ImportAlt () : logic
local begin
  Erx         : int;
  vFileName  : alpha;
  vFileHdl   : int;
  vFileSize  : int;
  vFilePos   : int;
  vDialog    : int;
  vDialogHdl : int;

  vError     : alpha(250);
  vBreak     : logic;

  vReadData  : alpha(500);
  vCurPos    : int;
  vNextPos   : int;
  vA         : alpha;

  vOldZieltage         : int;
  vOldFesterTag_Monat1 : int;
  vOldFesterTag_Monat2 : int;
  vOldFesterTag_nachLf : int;
  vOldZieltage_nachLfm : int;
end;
begin
  // Dateiwahl
  vFileName # Lib_FileIO:FileIO( _winComFileOpen, gMDI, '', 'C16-Dateien|*.C16' );

  if ( vFileName = '' ) then
    RETURN true;
  if ( strCnv( strCut( vFileName, strLen( vFileName ) - 3, 4 ), _strUpper ) != '.C16' ) then
    vFileName # vFileName + '.C16';

  vFileHdl # FsiOpen( vFileName, _fsiStdRead );
  if ( vFileHdl <= 0 ) then begin
    Msg( 19999, 'Datei nicht lesbar ' + vFileName, _winIcoError, _winDialogOk, 1 );
    RETURN true;
  end;

  vFileSize # FsiSize( vFileHdl );
  vDialog   # WinOpen( 'Dlg.Process', _winOpenDialog );
  if ( vDialog != 0 ) then begin
    vDialogHdl # vDialog->WinSearch( 'Label1' );
    vDialogHdl->wpCaption # 'Lese aus Datei ' + vFileName;
    vDialogHdl # vDialog->WinSearch( 'Progress' );
    vDialogHdl->wpProgressPos # 0;
    vDialogHdl->wpProgressMax # vFileSize;
    vDialog->WinDialogRun( _winDialogAsync, _winDialogCenter );
  end;

  /** Einträge lesen **/
  FOR  vFilePos # 0
  LOOP vFilePos # FsiSeek( vFileHdl )
  WHILE ( vError = '' ) and ( vBreak = false ) and ( vFilePos < vFileSize ) DO BEGIn
    if ( vDialogHdl != 0 ) then
      vDialogHdl->wpProgressPos # vFilePos;
    if ( vDialog != 0 ) then
      vBreak # ( vDialog->WinDialogResult() = _winIdCancel );

    FsiMark( vFileHdl, 10 );
    FsiRead( vFileHdl, vReadData );
    RecBufClear( 816 );

    // ZaB.Nummer
    vCurPos                # 1;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Nummer"           # CnvIA( strCut( vReadData, vCurPos, vNextPos - vCurPos ) );

    // ZaB.Skontoprozent
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    //"ZaB.Sknt1.Prozent"    # CnvFA( strCut( vReadData, vCurPos, vNextPos - vCurPos ) );
    vA                     # strCut( vReadData, vCurPos, vNextPos - vCurPos );
//    SUB Strings_ReplaceAll(aString : alpha(4096); aSuchString : alpha(250); aErsetzString : alpha(250)) : alpha;
    vA # Str_ReplaceAll(vA, ',', '.');
    Zab.Sknt1.Prozent     # cnvfa(vA,_FmtNumPoint);


    // ZaB.Skontotage
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Sknt1.Tage"       # CnvIA( strCut( vReadData, vCurPos, vNextPos - vCurPos ) );

    // ZaB.SkonVorZielDatYN
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Sknt1.VorZielYN"  # strCut( vReadData, vCurPos, vNextPos - vCurPos ) != 'N';

    // ZaB.Zieltage
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    vOldZieltage           # CnvIA( strCut( vReadData, vCurPos, vNextPos - vCurPos ) );

    // ZaB.FesterTag_Monat1
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    vOldFesterTag_Monat1   # CnvIA( strCut( vReadData, vCurPos, vNextPos - vCurPos ) );

    // ZaB.FesterTag_Monat2
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    vOldFesterTag_Monat2   # CnvIA( strCut( vReadData, vCurPos, vNextPos - vCurPos ) );

    // ZaB.FesterTag_nachLf
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    vOldFesterTag_nachLf   # CnvIA( strCut( vReadData, vCurPos, vNextPos - vCurPos ) );

    // ZaB.IndividuellYN
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.IndividuellYN"    # strCut( vReadData, vCurPos, vNextPos - vCurPos ) != 'N';

    // ZaB.Bezeichnung1.L1
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung1.L1"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Bezeichnung2.L1
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung2.L1"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Bezeichnung1.L2
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung1.L2"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Bezeichnung2.L2
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung2.L2"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Bezeichnung1.L3
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung1.L3"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Bezeichnung2.L3
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung2.L3"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Bezeichnung1.L4
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung1.L4"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Bezeichnung2.L4
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung2.L4"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Bezeichnung1.L5
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung1.L5"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Bezeichnung2.L5
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    "ZaB.Bezeichnung2.L5"  # strCut( vReadData, vCurPos, vNextPos - vCurPos );

    // ZaB.Zieltage_nachLfM
    vCurPos                # vNextPos + 3;
    vNextPos               # strFind( vReadData, '|||', vCurPos );
    vOldZieltage_nachLfm   # CnvIA( strCut( vReadData, vCurPos, vNextPos - vCurPos ) );

    // ZaB.SperreYN
    vCurPos                # vNextPos + 3;
    vNextPos               # strLen( vReadData ) + 1;
    "ZaB.SperreYN"         # strCut( vReadData, vCurPos, vNextPos - vCurPos ) != 'N';

    // Evaluierung der alten Werte
    "ZaB.Sknt1.VonTag"     # 1;
    "ZaB.Sknt1.BisTag"     # 31;

    if ( vOldZieltage != 0 ) then begin
      "ZaB.abRechDatumYN"    # true;
      "ZaB.Fällig1.Zieltage"  # vOldZieltage;
    end;
    else if ( vOldFesterTag_Monat1 != 0 ) then begin
      "ZaB.abRechDatumYN"    # true;
      "ZaB.Fällig1.FixTag"    # vOldFesterTag_Monat1;
      "ZaB.Fällig1.FixMonat" # 1;
    end;
    else if ( vOldFesterTag_Monat2 != 0 ) then begin
      "ZaB.abRechDatumYN"    # true;
      "ZaB.Fällig1.FixTag"    # vOldFesterTag_Monat2;
      "ZaB.Fällig1.FixMonat" # 2;
    end;
    else if ( vOldFesterTag_nachLf != 0 ) then begin
      "ZaB.abLFSDatumYN"     # true;
      "ZaB.Fällig1.FixTag"    # vOldFesterTag_nachLf;
      "ZaB.Fällig1.FixMonat" # 1;
      "ZAb.Bezeichnung1.L5"  # '*** BITTE PRÜFEN ***';
    end;
    else if ( vOldZieltage_nachLfm != 0 ) then begin
      "ZaB.abLFSDatumYN"     # true;
      "ZaB.Fällig1.Zieltage"  # vOldZieltage_nachLfm;
      "ZAb.Bezeichnung1.L5"  # '*** BITTE PRÜFEN ***';
    end;
    else
      "ZaB.abRechDatumYN"    # true;

    Erx # RekInsert( 816, 0, 'MAN' );
    if ( Erx != _rOk ) then begin
      vError # 'Zahlungsbedingung konnte nicht angelegt werden!';
      BREAK;
    end;
  END;

  // beenden
  FsiClose( vFileHdl );

  if ( vDialog != 0 ) then
    vDialog->WinClose();

  if ( gZLList != 0 ) then
    gZLList->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect );

  if ( vBreak ) then begin
    Msg( 19999, 'Abbruch durch den Benutzer!', _winIcoError, _winDialogOk, 1 );
    RETURN false;
  end;

  if ( vError != '' ) then begin
    Msg( 19999, vError, _winIcoError, _winDialogOk, 1 );
    RETURN false;
  end;

  Msg( 999998, '', 0, 0, 0 );
  RETURN true;
end;

//========================================================================
//========================================================================