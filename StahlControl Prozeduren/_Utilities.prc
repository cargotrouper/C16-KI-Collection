@A+
//==== Business-Control ===================================================
//
//  Prozedur    _Utilities
//                      OHNE E_R_G
//  Info
//        Interne Funktionen zur Sofortausführung
//
//  02.11.2009  PW  EditStorageObjects
//
//  Subprozeduren
//    sub CreateStructureList ()
//    sub CreateProcedureList ()
//    sub CreateProcedureBackup ()
//    sub EditStorageObjects ()
//    sub EditStorageObjects_Dialog ( aHdl : handle )
//    sub ModifyWindow(aHdl : int) : logic;
//    sub SearchEvents();
//
//=========================================================================
@I:Def_Global
define begin
  cDbgDirectory : 'd:\debug\'
  cDbgFileName  : 'd:\debug\debug.txt'
  cDbgRN        : StrChar( 13 ) + StrChar( 10 )
  cDbgT         : StrChar( 9 )
end;

declare ModifyAllWindows();

//=========================================================================
// MAIN
//        MAIN Einstiegspunkt der Prozedur
//=========================================================================
MAIN
begin
  //EditStorageObjects()
  //CreateProcedureBackup()
  //CreateStructureList()
  ModifyAllWindows();
end;


//=========================================================================
// debug
//        Debug
//=========================================================================
sub mydebug ( aText : alpha(2000) )
local begin
  vDbgFile : handle;
end
begin
  DbgTrace( aText );
  vDbgFile # FsiOpen( cDbgFileName, _fsiAcsW | _fsiDenyRW | _fsiCreate | _fsiAppend );
  if ( vDbgFile > 0 ) then begin
    vDbgFile->FsiWrite( StrCnv( aText + cDbgRN, _strToANSI ) );
    vDbgFile->FsiClose();
  end;
end;
//=========================================================================
// debugInit
//        Debug
//=========================================================================
sub debugInit;
local begin
  vDbgFile : handle;
end
begin
  Fsidelete(cdbgFilename);
end;


//=========================================================================
// CreateStructureList
//        Liste der gesamten Dateistruktur per debug schreiben
//=========================================================================
/***
sub CreateStructureList ()
local begin
  vFile : int;
  vSbr  : int;
  vSbrC : int;
  vFld  : int;
  vFldC : int;
  vKey  : int;
  vKeyC : int;
  vLnk  : int;
  vLnkC : int;
  vA    : alpha;
end
begin
  FOR  vFile # 1;
  LOOP vFile # vFile + 1;
  WHILE ( vFile < 1000 ) DO BEGIN
    if ( FileInfo( vFile, _fileExists ) = 0 ) then
      CYCLE;
    debug( '# ' + FileName( vFile ) + ' (' + CnvAI( vFile ) + ')' );

    vSbrC # FileInfo( vFile, _fileSbrCount );
    FOR  vSbr # 1;
    LOOP vSbr # vSbr + 1;
    WHILE ( vSbr <= vSbrC ) DO BEGIN
      debug( '### ' + CnvAI( vSbr ) + '. ' + SbrName( vFile, vSbr ) );

      vFldC # SbrInfo( vFile, vSbr, _sbrFldCount );
      FOR  vFld # 1;
      LOOP vFld # vFld + 1;
      WHILE ( vFld <= vFldC ) DO BEGIN
        case FldInfo( vFile, vSbr, vFld, _fldType ) of
          _typeLogic   : vA # 'Boolean';
          _typeByte    : vA # 'Byte';
          _typeWord    : vA # 'Int16';
          _typeInt     : vA # 'Int32';
          _typeBigInt  : vA # 'Int64';
          _typeFloat   : vA # 'Double';
          _typeDecimal : vA # 'Decimal';
          _typeDate    : vA # 'Date';
          _typeTime    : vA # 'Time';
          _typeAlpha   : vA # 'String[' + CnvAI( FldInfo( vFile, vSbr, vFld, _fldLen ) ) + ']';
        end;

        debug( StrFmt( CnvAI( vFld ) + '.', 4, _strEnd ) + '`' + vA + '` ' + FldName( vFile, vSbr, vFld ) );
      END;
    END;

    debug( '## Keys' );
    vKeyC # FileInfo( vFile, _fileKeyCount );
    FOR  vKey # 1;
    LOOP vKey # vKey + 1;
    WHILE ( vKey <= vKeyC ) DO BEGIN
      case KeyInfo( vFile, vKey, _keyIsUnique ) of
        1 : vA # ' (Unique)';
        0 : vA # '';
      end;
      debug( StrFmt( CnvAI( vKey ) + '.', 4, _strEnd ) + KeyName( vFile, vKey ) + vA );

      vFldC # KeyInfo( vFile, vKey, _keyFldCount );
      FOR  vFld # 1;
      LOOP vFld # vFld + 1;
      WHILE ( vFld <= vFldC ) DO BEGIN
        case KeyFldInfo( vFile, vKey, vFld, _keyFldType ) of
          _typeLogic   : vA # 'Boolean';
          _typeByte    : vA # 'Byte';
          _typeWord    : vA # 'Int16';
          _typeInt     : vA # 'Int32';
          _typeBigInt  : vA # 'Int64';
          _typeFloat   : vA # 'Double';
          _typeDecimal : vA # 'Decimal';
          _typeDate    : vA # 'Date';
          _typeTime    : vA # 'Time';
          _typeAlpha   : begin
            vA # 'String';
            if ( KeyFldInfo( vFile, vKey, vFld, _keyFldMaxLen ) != 0 ) then
              vA # vA + '[' + CnvAI( KeyFldInfo( vFile, vKey, vFld, _keyFldMaxLen ) ) + ']';
          end;
        end;

        debug( '    ' + StrFmt( CnvAI( vFld ) + '.', 4, _strEnd ) + '`' + vA + '` ' + CnvAI( KeyFldInfo( vFile, vKey, vFld, _keyFldFileNumber ) ) +
          '/' + CnvAI( KeyFldInfo( vFile, vKey, vFld, _keyFldSbrNumber ) ) + '/' + CnvAI( KeyFldInfo( vFile, vKey, vFld, _keyFldNumber ) ) );

        case KeyFldInfo( vFile, vKey, vFld, _keyFldAttributes ) of
          _keyFldAttrReverse      : vA # 'Absteigende Sortierung';
          _keyFldAttrSoundex1     : vA # 'Umwandlung in Soundex Stufe 1';
          _keyFldAttrSoundex2     : vA # 'Umwandlung in Soundex Stufe 2';
          _keyFldAttrSpecialChars : vA # 'Sortierung ohne Sonderzeichen';
          _keyFldAttrUmlaut       : vA # 'Umlaute in alphabetischer Sortierung';
          _keyFldAttrUpperCase    : vA # 'Groß-/Kleinwandlung';
          otherwise vA # '';
        end;
        if ( vA != '' ) then
          debug( '        ' + vA );
      END;
    END;

    debug( '## Links' );
    vLnkC # FileInfo( vFile, _fileLinkCount );
    FOR  vLnk # 1;
    LOOP vLnk # vLnk + 1;
    WHILE ( vLnk <= vLnkC ) DO BEGIN
      debug( StrFmt( CnvAI( vLnk ) + '.', 4, _strEnd ) + LinkName( vFile, vLnk ) + vA );
      debug( '    --> ' + CnvAI( LinkInfo( vFile, vLnk, _linkDestFileNumber ) ) + '/' + CnvAI( LinkInfo( vFile, vLnk, _linkDestKeyNumber ) ) )

      vFldC # LinkInfo( vFile, vLnk, _linkFldCount );
      FOR  vFld # 1;
      LOOP vFld # vFld + 1;
      WHILE ( vFld <= vFldC ) DO BEGIN
        case LinkFldInfo( vFile, vLnk, vFld, _linkFldType ) of
          _typeLogic   : vA # 'Boolean';
          _typeByte    : vA # 'Byte';
          _typeWord    : vA # 'Int16';
          _typeInt     : vA # 'Int32';
          _typeBigInt  : vA # 'Int64';
          _typeFloat   : vA # 'Double';
          _typeDecimal : vA # 'Decimal';
          _typeDate    : vA # 'Date';
          _typeTime    : vA # 'Time';
          _typeAlpha   : begin
            vA # 'String';
            if ( LinkFldInfo( vFile, vLnk, vFld, _linkFldMaxLen ) != 0 ) then
              vA # vA + '[' + CnvAI( LinkFldInfo( vFile, vLnk, vFld, _linkFldMaxLen ) ) + ']';
          end;
        end;

        debug( '    ' + StrFmt( CnvAI( vFld ) + '.', 4, _strEnd ) + '`' + vA + '` ' + CnvAI( LinkFldInfo( vFile, vLnk, vFld, _linkFldFileNumber ) ) +
          '/' + CnvAI( LinkFldInfo( vFile, vLnk, vFld, _linkFldSbrNumber ) ) + '/' + CnvAI( LinkFldInfo( vFile, vLnk, vFld, _linkFldNumber ) ) );
      END;
    END;

    debug( '' )
  END;
end;
***/

//=========================================================================
// CreateProcedureList
//        Liste von allen Prozeduren per debug schreiben
//=========================================================================
sub CreateProcedureList ()
local begin
  vErg : int;
  vHdl : handle;
end
begin
  vHdl # TextOpen( 16 );
  FOR  vErg # vHdl->TextRead( '', _textFirst | _textNoContents | _textProc );
  LOOP vErg # vHdl->TextRead( vHdl->TextInfoAlpha( _textName ), _textNext | _textNoContents | _textProc );
  WHILE ( vErg <=_rLocked ) DO BEGIN
    debug( vHdl->TextInfoAlpha( _textName ) );
  END;
  vHdl->TextClose();
end;


//=========================================================================
// CreateProcedureBackup
//        Erstellt Backups von allen Prozeduren
//=========================================================================
sub CreateProcedureBackup ()
local begin
  vErg      : int;
  vTextHdl  : handle;
  vFileHdl  : handle;
  vProcName : alpha;
  vLine     : int;
  vLines    : int;
end
begin
  vTextHdl # TextOpen( 16 );
  FsiPathCreate( cDbgDirectory + 'procedures\' );

  FOR  vErg # vTextHdl->TextRead( '', _textFirst | _textProc );
  LOOP vErg # vTextHdl->TextRead( vProcName, _textNext | _textProc );
  WHILE ( vErg <=_rLocked ) DO BEGIN
    vProcName # vTextHdl->TextInfoAlpha( _textName );
    vFileHdl  # FsiOpen( cDbgDirectory + 'procedures\' + vProcName + '.c16', _fsiStdWrite );
    if ( vFileHdl <= 0 ) then begin
      debug( 'FEHLER: ' + vProcName + ' (' + CnvAI( vFileHdl ) + ')' );
      CYCLE;
    end;

    vLines # vTextHdl->TextInfo( _textLines );
    FOR  vLine # 1;
    LOOP vLine # vLine + 1;
    WHILE ( vLine <= vLines ) DO BEGIN
      vFileHdl->FsiWrite( StrCnv( vTextHdl->TextLineRead( vLine, 0 ) + cDbgRN, _strToANSI ) );
    end;

    vFileHdl->FsiDate( _fsiDtCreated,  vTextHdl->TextInfoDate( _textCreated ) );
    vFileHdl->FsiTime( _fsiDtCreated,  vTextHdl->TextInfoTime( _textCreated ) );
    vFileHdl->FsiDate( _fsiDtModified, vTextHdl->TextInfoDate( _textModified ) );
    vFileHdl->FsiTime( _fsiDtModified, vTextHdl->TextInfoTime( _textModified ) );
    vFileHdl->FsiClose();
    debug( 'Prozedur ' + vProcName + ' gespeichert.' );
  END;

  vTextHdl->TextClose();
end;


//=========================================================================
// EditStorageObjects_Dialog
//        Dialog bearbeiten
//=========================================================================
sub EditStorageObjects_Dialog ( aHdl : handle ) : logic
local begin
  vObj  : handle;
  vType : int;
  vOK   : logic;
end;
begin
  FOR  vObj # aHdl->WinInfo( _winFirst );
  LOOP vObj # vObj->WinInfo( _winNext );
  WHILE ( vObj > 0 ) DO BEGIN
    vType # vObj->WinInfo( _winType );

/***
    // Tausendertrennung bei Int & FloatEdits deaktivieren
    if ( vType = _winTypeIntEdit ) then begin
      debug( '  [Int] ' + vObj->wpName );
      vObj->wpFmtIntFlags   # vObj->wpFmtIntFlags | _fmtNumNoGroup;
      vObj->wpFmtOutput     # true;
    end
    else if ( vType = _winTypeFloatEdit ) then begin
      debug( '  [Float] ' + vObj->wpName );
      vObj->wpFmtFloatFlags # vObj->wpFmtFloatFlags | _fmtNumNoGroup;
      vObj->wpFmtOutput     # true;
    end;
***/
    if ( vType = _winTypeButton ) then begin
      if ( vObj->wpName = 'Mark' ) then begin
        vObj->wpCaption # 'Mark';
        RETURN true;
      end;
    end;

    vOK # vObj->EditStorageObjects_Dialog();
  END;

  RETURN vOK;
end;


//=========================================================================
// EditStorageObjects
//        Storage Objekte automatisiert bearbeiten und speichern
//=========================================================================
sub EditStorageObjects ()
local begin
  vHdl        : handle;
  vStoDir     : int;
  vStoObjName : alpha;
  vStoObj     : handle;
end;
begin
  /* Storage: Dialog */
  vStoDir # StoDirOpen( 0, 'Dialog' );
  FOR  vStoObjName # vStoDir->StoDirRead( _stoFirst );
  LOOP vStoObjName # vStoDir->StoDirRead( _stoNext, vStoObjName );
  WHILE ( vStoObjName != '' ) DO BEGIN
    if ( StrCut( vStoObjName, 0, 8 ) = 'AppFrame' ) or ( StrCut( vStoObjName, 0, 4 ) = 'Math' ) or
       ( StrCut( vStoObjName, 0, 6 ) = 'AF_Frm' ) or ( StrCut( vStoObjName, 0, 12 ) = Lib_GuiCom:GetAlternativeName('Mdi.Tastatur')) or
       ( vStoObjName = 'xxxMat.Verwaltung' ) then begin
      CYCLE; // skip
    end;

    /* open object */
    debug( '[Dialog] Öffne ' + vStoObjName + ' als MDI...');
    vHdl # WinOpen( vStoObjName, _winOpenLock );
    if ( vHdl<= 0 ) then begin
      debug( '[Dialog] Öffne ' + vStoObjName + ' als Dialog...' );
      vHdl # WinOpen( vStoObjName, _winOpenDialog | _winOpenLock );
      if ( vHdl<= 0 ) then begin
        debug( '[Dialog] ***** Fehler beim Öffnen von ' + vStoObjName + ' (' + CnvAI( ErrGet() ) + ')' );
        CYCLE;
      end;
    end;

/*** HIER HIER HIER
    vStoObj # StoOpen(vStoDir, vStoObjName);
    if (vStoObj->spType=_StoTypeMdiFrame) then begin
      StoClose(vStoObj);
      debug( '[Dialog] Öffne ' + vStoObjName + ' als MDI...');
      vHdl # WinOpen( vStoObjName, _winOpenLock );
      if ( vHdl<= 0 ) then begin
        debug( '[Dialog] Fehler beim Öffnen von ' + vStoObjName + ' (' + CnvAI( ErrGet() ) + ')' );
        CYCLE;
      end;
      end
    else if (vStoObj->spType=_StoTypeFrame) then begin
      StoClose(vStoObj);
      debug( '[Dialog] Öffne ' + vStoObjName + ' als Dialog...' );
      vHdl # WinOpen( vStoObjName, _winOpenDialog | _winOpenLock );
      if ( vHdl<= 0 ) then begin
        debug( '[Dialog] Fehler beim Öffnen von ' + vStoObjName + ' (' + CnvAI( ErrGet() ) + ')' );
        CYCLE;
      end;
      end
    else begin
      debug('UNKNOWN TYPE!!!');
      CYCLE;
    end;
***/

    /* edit object */
    if (vHdl->EditStorageObjects_Dialog()=false) then
      debug('***** OBJEKT NOT FOUND!!!');


    /* save object */
//    if ( vHdl->WinSave( _winSaveOverwrite ) != _errOk ) then
//      debug( '[Dialog] Fehler beim Speichern von ' + vStoObjName );
    vHdl->WinClose();
  END;
  vStoDir->StoClose();
end;


//========================================================================
//========================================================================
sub _Rek(aObj : int);
local begin
  vObj  : int;
end;
begin

  // alle F9-Buttons anpassen
  FOR vObj # aObj->WinInfo( _winFirst)
  LOOP vObj # vObj->WinInfo( _winNext)
  WHILE ( vObj > 0 ) DO BEGIN

    case WinInfo(vObj,_Wintype) of

      _WinTypeButton : begin
        if (vObj->wpImageTile=_WinImgExport) then begin
//debug('button:'+vObj->wpname);
          vObj->wpImageTileUser # 170;
        end;
        CYCLE;
      end;

      _WinTypeToolbar, _WinTypeToolbarDock, _WinTypeToolbarButton, _WinTypeToolbarRtf :
        CYCLE;
     end;

    _Rek(vObj);
  END;

  RETURN
end;


//========================================================================
//========================================================================
sub _ModWin_Tiles(aHdl : int) : logic;
local begin
  vObj    : int;
  vObj2   : int;
  vObj3   : int;
  vType   : int;
end;
begin

  if (aHdl=0) then RETURN false;

  if (WinInfo(aHdl,_wintype)=_WinTypeTrayFrame) then RETURN true;

//debug('Analyse Window: '+aHdl->wpname);

  vObj # aHdl->WinInfo( _winFirst,0 ,_WinTypeFrameClient);
  if (vObj=0) then begin
    debug('kein FrameClient in '+aHdl->wpname);
    end
  else begin
    if (vObj->wpname<>'fc.Main') then vObj->wpname # 'fc.Main';
  end;
RETURN true;

  // Tiles anpassen...
  if (aHdl->wpTileNameNormal<>'') or
    (aHdl->wpTileNameSelected<>'') or
    (aHdl->wpTileNamePressed<>'') then begin
//debug(aHdl->wpname+' hat bereits UserTiles !!');
    end
  else begin
    aHdl->wpTileNameNormal    # 'Custom_24';
    aHdl->wpTileNameSelected  # 'Custom_24';
    aHdl->wpTileNamePressed   # 'Custom_24';
  end;


  // Toolbar anpassen...
  FOR vObj # aHdl->WinInfo( _winFirst,0 ,_WinTypeToolbarDock)
  LOOP vObj # vObj->WinInfo( _winNext,0 ,_WinTypeToolbarDock)
  WHILE ( vObj > 0 ) DO BEGIN
    vType # vObj->WinInfo(_winType);
//debug('ToolbarDock: '+vObj->wpname);
//    vObj2 # vObj->WinInfo( _winFirst,0 ,_WinTypeWindowbar);

    // Style anpassen
    vObj->wpStyleBorder # _WinBorStandard;

    // Windowsbarr anpassen...
    vObj2 # Winsearch(vObj, 'Std.Windowsbar');
    if (vObj2=0) then begin
debug(aHdl->wpname+' KEINE Windowsbar!!!');
      end
    else begin

      // Größen anpassen
      vObj2->wpArearight  # 32;
      vObj2->wpAreaBottom # 2048;

      // Sperator(Labels) finden...
      if (vObj2->WinInfo( _winFirst,0 ,_WinTypeLabel)>0) then begin
debug(aHdl->wpname+' hat TRENNLABELS bei den Buttons!');
      end;

      // Menü-Buttons anpassen...
      FOR vObj3 # vObj2->WinInfo( _winFirst,0 ,_WinTypeButton)
      LOOP vObj3 # vObj3->WinInfo( _winNext,0 ,_WinTypeButton)
      WHILE ( vObj3 > 0 ) DO BEGIN

        vObj3->wpStyleBorder  # _WinBorStandard;
        vObj3->wparealeft     # -1;
        vObj3->wparearight    # 29;
        case StrCnv(vObj3->wpname,_Strupper) of
          'NEW','NEW2','NEWX' :
                        vObj3->wpImageTileUser # 1;
          'SEARCH'      :
                        vObj3->wpImageTileUser # 15;
          'MARK'        :
                        vObj3->wpImageTileUser # 102;
          'REFRESH','REFRESH2' :
                        vObj3->wpImageTileUser # 17;
          'RECPREV'     :
                        vObj3->wpImageTileUser # 92;
          'EDIT'        :
                        vObj3->wpImageTileUser # 2;
          'EDITERSATZ'  :
                        vObj3->wpImageTileUser # 2;
          'RECNEXT'     :
                        vObj3->wpImageTileUser # 93;
          'DELETE'      :
                        vObj3->wpImageTileUser # 174;
          'CANCEL'      :
                        vObj3->wpImageTileUser # 42;
          'SAVE','SAVE2' :
                        vObj3->wpImageTileUser # 41;
          'ATTACHMENT'  :
                        vObj3->wpImageTileUser # 185;
          otherwise begin
debug('unbekannter button:'+vObj3->wpname);
          end;
        end
      END;
    end;

  END;


  _Rek(aHdl);


  RETURN true;
end;


//========================================================================
//========================================================================
sub _ModWin_Help(aHdl : int) : logic;
local begin
  vObj  : int;
  vType : int;
end;
begin

//vType # aHdl->WinInfo(_winType);
//debug('checke: '+aHdl->wpname+'  '+lib_debug:TypetoString(vType));

  TRY begin
    ErrTryIgnore(_ErrPropInvalid);
    if (aHdl->wpHelp<>'') then      aHdl->wpHelp # '';
    if (aHdl->wpHelpFile<>'') then  aHdl->wpHelpFile # '';
  end;

  // alles loopen
  FOR vObj # aHdl->WinInfo( _winFirst)
  LOOP vObj # vObj->WinInfo( _winNext)
  WHILE ( vObj > 0 ) DO BEGIN
    _Modwin_Help(vObj);
//    vType # vObj->WinInfo(_winType);
  END;

  RETURN true;
end;



//========================================================================
//========================================================================
sub _ModWin_AddButtonAttachement(aHdl : int) : logic;
local begin
  Erx   : int;
  vObj  : int;
  vType : int;
  vNew  : int;
  vRect : rect;
  vBar  : int;
end;
begin

  vBar # Winsearch(aHdl, 'Std.Windowsbar');
  if (vBar=0) then RETURN true;

  vObj # Winsearch(vBar, 'Attachment');
  if (vObj=0) then RETURN true;
  if (Wininfo(vObj,_Wintype)<>_WinTypeButton) then RETURN true;
  
//debug('Modde !');

//vNew # Lib_GuiDynamisch:CopyObject(vObj, 'xxxxxx', vBar, false);
  vNew # WinCopy(vObj);
  vRect # vNew->wparea;
  vRect:bottom # vRect:Bottom + 34;
  vRect:Top # vRect:Top + 34;
  vNew->wpArea # vRect;
  vNew->wpname # 'Aktivitaeten';
  vNew->wpHelpTip # 'Aktivitäten anzeigen';
  vNew->wpImageTileUser # 63;
  erx # vBar->winadd(vNew, 0, vObj);
//debug('ERX');

  RETURN true;
end;


//========================================================================
//========================================================================
sub _ModWin_Underlines(aHdl : int) : logic;
local begin
  vObj  : int;
  vType : int;
  vA    : alpha(100);
end;
begin
  // Toolbar anpassen...
  FOR vObj # aHdl->WinInfo( _winFirst)
  LOOP vObj # vObj->WinInfo( _winNext)
  WHILE ( vObj > 0 ) DO BEGIN
    vType # vObj->WinInfo(_winType);
    if (vType=_WinTypeLabel) or (vType=_WinTypeButton) then begin
      vA # vObj->wpcaption;
      if (vA<>'&OK') and (vA<>'A&bbruch') then begin
        if (StrFind(vA, '&', 1)>0) then begin
debug('     Modify Obj:'+vObj->wpname+' '+vA);
          vObj->wpcaption # Lib_Strings:Strings_ReplaceAll(vA,'&','');
        end;
      end;
    end;

    if (_ModWin_Underlines(vObj)=false) then RETURN false;
  END;


  RETURN true;
end;


//========================================================================
//========================================================================
sub _ModWin_SetEdSuche(aHdl : int) : logic;
local begin
  vObj  : int;
  vType : int;
  vA    : alpha(100);
end;
begin
  vObj # Winsearch(aHdl,'ed.Suche');
  if (vObj=0) then RETURN true;

  vA # vObj->WinEvtProcNameGet(_WinEvtFocusTerm);
//if (vA<>'') then debug(vA);
  if (vA='') then
    vObj->WinEvtProcNameSet(_WinEvtFocusTerm,'App_Main:SucheEvtFocusTerm');

  RETURN true;
end;


//========================================================================
sub _AufCalibri(aStartObj : int) : logic;
local begin
  vObj  : int;
  vFont : font;
end;
begin

  FOR   vObj # aStartObj->WinInfo(_WinFirst);
  LOOP  vObj # vObj->WinInfo(_WinNext);
  WHILE (vObj > 0) do begin
//debug('do:'+vObj->wpname);
    try begin
      ErrTryIgnore(_ErrPropInvalid);
      vFont # vObj->wpFont;
      if (vFont:Name='MS Sans Serif') then begin
        vFont:Name # 'Calibri';
        //vFont:Name # 'DK Uncle Edward';
        vFont:Size # vFont:Size + 10;
        vObj->wpFont # vFont;
      end;
    end;
    ErrGet();
    if (_AufCalibri(vObj)=false) then RETURN false;
  END;

  RETURN true;
end;


//========================================================================
// call _Utilities:ModifyAllWindows
//========================================================================
sub ModifyAllWindows();
local begin
  vStoDir   : int;
  vStoName  : alpha;
  vHdl      : int;
  vTEST     : logic;
end;
begin


  vTest # WinDialogBox(0,'ModifyAllWindows','NUR LAUFTEST?',_WinIcoQuestion,_WinDialogYesNo,1)=_Winidyes;

  DebugInit();

if (vTest) then begin
  debug('NUR TEST!!!');
  debug('NUR TEST!!!');
  debug('NUR TEST!!!');
end
else begin
  debug('ECHTLAUF!!');
  debug('ECHTLAUF!!');
  debug('ECHTLAUF!!');
end;


  // ALLES AUS
  WinEvtProcessSet(_WinEvtAll,n);

debug('START');
  // Translations: Dialog **********************************************************
  vStoDir # StoDirOpen( 0, 'Dialog' );
  FOR  vStoName # vStoDir->StoDirRead( _stoFirst )
  LOOP vStoName # vStoDir->StoDirRead( _stoNext, vStoName )
  WHILE ( vStoName != '' ) and (StrCnv(vStoName,_StrUpper)<'ZZZZZ') DO BEGIN

//    if ( StrCut( vStoName, 0, 8 ) = 'AppFrame' ) or ( StrCut( vStoName, 0, 4 ) = 'Math' ) then
//      CYCLE;
//    if ( vStoName <>'Mat.Verwaltung.Rohr') then CYCLE;

debug( 'Process ' + vStoName );
    // nur testen...
    if (vTest) then begin
      vHdl # WinOpen( vStoName, _winOpenDialog | _WinOpenEventsOff);
      if ( vHdl = 0 ) then begin
        vHdl # WinOpen( vStoName, _WinOpenEventsOff);
        if ( vHdl = 0 ) then begin
debug( 'SKIP ' + vStoName );
          CYCLE;
        end;
      end;
      end
    // ECHT...
    else begin
      vHdl # WinOpen( vStoName, _winOpenLock|_winOpenDialog | _WinOpenEventsOff);
      if ( vHdl = 0 ) then begin
        vHdl # WinOpen( vStoName,_winOpenLock| _WinOpenEventsOff);
        if ( vHdl = 0 ) then begin
debug( 'SKIP ' + vStoName );
          CYCLE;
        end;
      end;
    end;


    // modify window
//    if (_ModWin_Tiles(vHdl)=false) then begin
//    if (_ModWin_Help(vHdl)=false) then begin
//    if (_ModWin_Underlines(vHdl)=false) then begin
//    if (_ModWin_SetEdSuche(vHdl)=false) then begin
//    if (_AufCalibri(vHdl)=false) then begin
    if (_ModWin_AddButtonAttachement(vHdl)=false) then begin
debug('ERROR bei '+vHdl->wpname);
    end;


    if (vTest=false) then begin
      if ( vHdl->WinSave( _winSaveOverwrite ) != _errOk ) then
debug( '[Dialog] Fehler beim Speichern von ' + vStoName );
    end;

    vHdl->WinClose();
  END;
  vStoDir->StoClose();

  // ALLES AN
  WinEvtProcessSet(_WinEvtAll,y);
end;


//========================================================================
//  ModSFX
//========================================================================
sub ModSFX(aProc : alpha);
local begin
  vStoDir   : int;
  vStoName  : alpha;
  vHdl      : int;
  vTEST     : logic;
end;
begin

  // ALLES AUS
  WinEvtProcessSet(_WinEvtAll,n);

  // Translations: Dialog **********************************************************
  vStoDir # StoDirOpen( 0, 'Dialog' );
  vStoName # 'SFX';
  FOR  vStoName # vStoDir->StoDirRead( _stoNext, vStoName )
  LOOP vStoName # vStoDir->StoDirRead( _stoNext, vStoName )
  WHILE ( vStoName != '' ) and (StrCnv(StrCut(vStoName,1,3),_StrUpper)='SFX') DO BEGIN

    if (vStoName='SFX.Verwaltung') or
      (vStoName='SFX.Auswahl') or
      (vStoName='SFX.User') then
      CYCLE;

    vHdl # WinOpen( vStoName, _winOpenLock|_winOpenDialog | _WinOpenEventsOff);
    if ( vHdl = 0 ) then begin
      vHdl # WinOpen( vStoName,_winOpenLock| _WinOpenEventsOff);
      if ( vHdl = 0 ) then begin
debug( 'SKIP ' + vStoName );
        CYCLE;
      end;
    end;

    if (Call(aProc, vHdl)=false) then begin
//    if (_AufCalibri(vHdl)=false) then begin
debug('ERROR bei '+vHdl->wpname);
    end;

    if (vTest=false) then
      if ( vHdl->WinSave( _winSaveOverwrite ) != _errOk ) then
debug( '[Dialog] Fehler beim Speichern von ' + vStoName );

    vHdl->WinClose();
  END;

  vStoDir->StoClose();

  // ALLES AN
  WinEvtProcessSet(_WinEvtAll,y);
end;


//========================================================================
//========================================================================
sub _SearchEvents(
  aHdl    : int;
  aEvent  : int;
  aName   : alpha ) : logic;
local begin
  vObj  : int;
  vType : int;
  vA    : alpha(100);
end;
begin

  vA # WinEvtProcNameGet(aHdl, aEvent);
  if (vA<>'') then
    if (StrCnv(vA,_strUpper)<>aName) then debug(vA);

  // Alle Unterobjekte loopen...
  FOR vObj # aHdl->WinInfo( _winFirst)
  LOOP vObj # vObj->WinInfo( _winNext)
  WHILE ( vObj > 0 ) DO BEGIN
    vType # vObj->WinInfo(_winType);

//    if (vType=_WinTypeLabel) or (vType=_WinTypeButton) then begin

    if (_SearchEvents(vObj, aEvent, aName)=false) then RETURN false;
  END;


  RETURN true;
end;


//========================================================================
// call _Utilities:SearchEvents
//========================================================================
sub SearchEvents();
local begin
  vStoDir   : int;
  vStoName  : alpha;
  vHdl      : int;
  vName     : alpha;
  vEvent    : int;
  vType     : int;
end;
begin

  vEvent  #  _WinEvtFocusInit;
  vName   # 'APP_MAIN:EVTFOCUSINIT';


  DebugInit();

  // ALLES AUS
  WinEvtProcessSet(_WinEvtAll,n);

debug('START');
  // Translations: Dialog **********************************************************
  vStoDir # StoDirOpen( 0, 'Dialog' );
  FOR  vStoName # vStoDir->StoDirRead( _stoFirst )
  LOOP vStoName # vStoDir->StoDirRead( _stoNext, vStoName )
  WHILE ( vStoName != '' ) and (StrCnv(vStoName,_StrUpper)<'ZZZZZ') DO BEGIN

//    if ( StrCut( vStoName, 0, 8 ) = 'AppFrame' ) or ( StrCut( vStoName, 0, 4 ) = 'Math' ) then
//      CYCLE;
//    if ( vStoName <>'Adr.Verwaltung') then CYCLE;
//debug( 'Process ' + vStoName );

    vHdl # WinOpen( vStoName, _winOpenDialog | _WinOpenEventsOff);
    if ( vHdl = 0 ) then begin
      vHdl # WinOpen( vStoName, _WinOpenEventsOff);
      if ( vHdl = 0 ) then begin
debug( 'SKIP ' + vStoName );
        CYCLE;
      end;
    end;

    vType # vHdl->WinInfo(_winType);

    // loop objects...
    if (vType=_WinTypeMdiFrame) then begin
      if (_SearchEvents(vHdl, vEvent, vName)=false) then begin
debug('ERROR bei '+vHdl->wpname);
      end;
    end;

    vHdl->WinClose();
  END;
  vStoDir->StoClose();

  // ALLES AN
  WinEvtProcessSet(_WinEvtAll,y);
end;


//========================================================================
//  call _Utilities:ModSFX_1.802
//========================================================================
sub ModSFX_1.802();
begin
  ModSFX('_Utilities:_AufCalibri');
end;


//========================================================================
//========================================================================