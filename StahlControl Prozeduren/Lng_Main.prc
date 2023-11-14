@A+
//===== Business-Control =================================================
//
//  Prozedur    Lng_Main
//                        OHNE E_R_G
//  Info        Initialisiert die Übersetzungstabelle mit allen zur
//              Übersetzung verfügbaren Begriffen. Debug-Ausgabe gibt
//              genauere Details wo welcher Text herkommt.
//
//  12.11.2008  PW  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB InsertTranslation  ( aText : alpha )
//    SUB AddObjectTranslations ( aObj : int )
//    SUB InitObjectTranslations ()
//    SUB InitProcedureTranslations ()
//
//========================================================================
@I:Def_Global

local begin
  vPad : alpha;
end;

//========================================================================
//  InsertTranslation
//
//========================================================================
sub InsertTranslation ( aText : alpha )
begin
  if ( StrCnv( aText, _strUpper ) = StrCnv( aText, _strLower ) ) then
    RETURN;

  debug( vPad + '- ' + aText );
  RecBufClear( 904 );
  "Prg.ÜSe.Deutsch"  # aText;
  //"Prg.ÜSe.Sprache1" # '_LNG_' + aText;
  RekInsert( 904, 0, 'MAN' );
end;


//========================================================================
//  AddObjectTranslations
//
//========================================================================
sub AddObjectTranslations ( aObj : int )
local begin
  vObj  : int;
  vType : int;
end;
begin
  vPad # vPad + ' ';
  FOR  vObj # aObj->WinInfo( _winFirst );
  LOOP vObj # vObj->WinInfo( _winNext );
  WHILE ( vObj > 0 ) DO BEGIN
    //debug( vPad + '[Obj] ' + vObj->wpName );
    vType # vObj->WinInfo( _winType );

    if ( vObj->wpCustom = '_NO_TRANSLATE' ) then
      CYCLE;

    if ( vType = _winTypeLabel       or vType = _winTypeGroupBox     or vType = _winTypeButton     or
         vType = _winTypeCheckBox    or vType = _winTypeRadioButton  or vType = _winTypeCheckBox   or
         vType = _winTypeRadioButton or vType = _winTypeNotebookPage or vType = _winTypeListColumn or
         vType = _winTypeTreeNode    or vType = _winTypeToolbarButton ) then begin
      if ( vObj->wpCaption != '' ) then
        InsertTranslation( vObj->wpCaption );
      if ( vObj->wpHelpTip != '' ) then
        InsertTranslation( vObj->wpHelpTip );
    end;
    if ( vType = _winTypeEdit     or vType = _winTypeIntEdit  or vType = _winTypeFloatEdit or
         vType = _winTypeTimeEdit or vType = _winTypeDateEdit or vType = _winTypeColorEdit or
         vType = _winTypeTextEdit or vType = _winTypeRTFEdit ) then begin
      if ( vObj->wpHelpTip != '' ) then
        InsertTranslation( vObj->wpHelpTip );
    end;
    if ( vType = _winTypeMenuItem or vType = _winTypeMdiFrame ) then begin
      if ( vObj->wpCaption != '' ) then
        InsertTranslation( vObj->wpCaption );
    end;

    AddObjectTranslations( vObj );
  END;
  vPad # StrCut( vPad, 0, StrLen( vPad ) - 1 );
end;


//========================================================================
//  InitObjectTranslations
//
//========================================================================
sub InitObjectTranslations ()
local begin
  vHdl    : int;
  vStoDir : int;
  vStoObj : alpha;
end;
begin
  /** Translations: Custom **/
  vHdl # gFrmMain;
  if ( vHdl = 0 ) then
    debug( '[Dialog|Skip] ' + vHdl->wpName );
  else begin
    debug( '[Dialog|Opening] ' + vHdl->wpName + ' (' + CnvAI( vHdl ) + ')' );
    AddObjectTranslations( vHdl );
    debug( '[Dialog|Closing] ' + vHdl->wpName );
  end;

  vHdl # gToolBar;
  if ( vHdl = 0 ) then
    debug( '[Dialog|Skip] ' + vHdl->wpName );
  else begin
    debug( '[Dialog|Opening] ' + vHdl->wpName + ' (' + CnvAI( vHdl ) + ')' );
    AddObjectTranslations( vHdl );
    debug( '[Dialog|Closing] ' + vHdl->wpName );
  end;


  /** Translations: Dialog **/
  vStoDir # StoDirOpen( 0, 'Dialog' );
  FOR  vStoObj # vStoDir->StoDirRead( _stoFirst );
  LOOP vStoObj # vStoDir->StoDirRead( _stoNext, vStoObj );
  WHILE ( vStoObj != '' ) DO BEGIN
    if ( StrCut( vStoObj, 0, 8 ) = 'AppFrame' ) or ( StrCut( vStoObj, 0, 4 ) = 'Math' ) or
       ( StrCut( vStoObj, 0, 6 ) = 'AF_Frm' ) or ( StrCut( vStoObj, 0, 12 ) = 'Mdi.Tastatur' ) then begin
      debug( '[Dialog|Skip] ' + vStoObj );
      CYCLE;
    end;

    vHdl # WinOpen( vStoObj, _winOpenDialog );
    if ( vHdl = 0 ) then begin
      vHdl # WinOpen( vStoObj );
      if ( vHdl = 0 ) then begin
        debug( '[Dialog|Skip] ' + vStoObj );
        CYCLE;
      end;
    end;

    debug( '[Dialog|Opening] ' + vStoObj + ' (' + CnvAI( vHdl ) + ')' );
    AddObjectTranslations( vHdl );
    debug( '[Dialog|Closing] ' + vStoObj );
    vHdl->WinClose();
  END;
  vStoDir->StoClose();


  /** Translations: Menu **/
  vStoDir # StoDirOpen( 0, 'Menu' );
  FOR  vStoObj # vStoDir->StoDirRead( _stoFirst );
  LOOP vStoObj # vStoDir->StoDirRead( _stoNext, vStoObj );
  WHILE ( vStoObj != '' ) DO BEGIN
    gFrmMain->wpMenuName # vStoObj;
    vHdl # gFrmMain->WinInfo( _winMenu );
    if ( vHdl = 0 ) then begin
      debug( '[Menu|Skip] ' + vStoObj );
      CYCLE;
    end;

    debug( '[Menu|Opening] ' + vStoObj + ' (' + CnvAI( vHdl ) + ')' );
    AddObjectTranslations( vHdl );
    debug( '[Menu|Closing] ' + vStoObj );
  END;
  vStoDir->StoClose();
end;


//========================================================================
//  InitProcedureTranslations
//
//========================================================================
sub InitProcedureTranslations ()
local begin
  Erx       : int;
  vHdl     : int;
  vLine    : int;
  vLines   : int;
  vName    : alpha;
  vText    : alpha(250);
  vTextAdj : alpha(250);
  vTextWrd : alpha;
end;
begin
  vHdl # TextOpen( 0 );
  FOR  Erx # vHdl->TextRead( '',   _textFirst | _textProc );
  LOOP Erx # vHdl->TextRead( vName, _textNext | _textProc );
  WHILE ( Erx < _rLocked ) DO BEGIN
    vName  # vHdl->TextInfoAlpha( _textName );
    vLines # vHdl->TextInfo( _textLines );

    if ( vName = 'Lng_Main' ) then
      CYCLE;

    debug( '[Procedure|Opening] ' + vName + ' (' + CnvAI( vLines ) + ')' );
    vPad # vPad + ' ';

    FOR  vLine # 1;
    LOOP vLine # vLine + 1;
    WHILE ( vLine <= vLines ) DO BEGIN
      vText    # vHdl->TextLineRead( vLine, 0 );
      vTextAdj # StrAdj( StrCnv( vText, _strLower ), _strAll );
      if ( StrFind( vTextAdj, 'translate(''', 1 ) > 0 ) and ( StrFind( vTextAdj, '//', 1 ) != 1 ) then begin
        vText    # StrCut( vText, StrFind( StrCnv( vText, _strLower ), 'translate(', 1 ), StrLen( vText ) );
        vText    # StrCut( vText, StrFind( vText, '''', 1 ) + 1, StrLen( vText ) );
        vTextWrd # StrCut( vText, 1, StrFind( vText, '''', 1 ) - 1 );
        vText    # StrCut( vText, StrFind( vText, '''', 1 ) + 1, StrLen( vText ) );
        InsertTranslation( vTextWrd );

        WHILE ( StrFind( StrAdj( StrCnv( vText, _strLower ), _strAll ), 'translate(''', 1 ) > 0 ) DO BEGIN
          vText    # StrCut( vText, StrFind( StrCnv( vText, _strLower ), 'translate(', 1 ), StrLen( vText ) );
          vText    # StrCut( vText, StrFind( vText, '''', 1 ) + 1, StrLen( vText ) );
          vTextWrd # StrCut( vText, 1, StrFind( vText, '''', 1 ) - 1 );
          vText    # StrCut( vText, StrFind( vText, '''', 1 ) + 1, StrLen( vText ) );
          InsertTranslation( vTextWrd );
        END;
      end;
    END;

    debug( '[Procedure|Closing] ' + vName + ' (' + CnvAI( vLines ) + ')' );
    vPad # StrCut( vPad, 0, StrLen( vPad ) - 1 );
  END;
  vHdl->TextClose();
end;


//========================================================================
//  MAIN
//
//========================================================================
MAIN
begin
  WinEvtProcessSet( _winEvtAll, false );
  InitProcedureTranslations();
  InitObjectTranslations();
  WinEvtProcessSet( _winEvtAll, true );

  // reset
  gFrmMain->wpMenuName # 'Main';
  Lib_GuiCom:TranslateObject( gToolBar );
  Lib_GuiCom:TranslateObject( gFrmMain->WinInfo( _winMenu ) );
  Lib_GuiCom:TranslateObject( gFrmMain );
end;