@A+
//==== Business-Control ===================================================
//
//  Prozedur    Lib_List2
//                    OHNE E_R_G
//  Info
//        Routinen für die Ausgabe von Listen als Druck oder (Excel-)XML.
//        Sollten per Def_List2 angesteuert werden.
//
//  24.02.2010  AI  Erstellung der Prozedur
//  22.03.2010  PW  Anpassungen
//  19.10.2010  AI  Kursic/Italic eingebaut
//  16.02.2012  TM  XML Erfolgsmeldung für Job-Server Listen deaktiviert
//  20.03.2012  MS  Individuellen Listenfuss hinzugefuegt _Init(...aListFooter)
//  01.06.2012  AI  PDF-Ausgabe möglich
//  06.06.2012  AI  Lfm.Name als PDF-Titel
//  06.02.2014  AH  Excel-Export kappt Floats bei 999999999999.0
//
//  Subprozeduren
//    sub _Init ( aLandscape : logic; opt aPapersize : alpha ) : logic;
//    sub _Term () : logic;
//    sub _WriteTitel ( opt vSuffix : alpha );
//    sub _NewLine ( aName : alpha ) : handle;
//    sub _FreeLine ( aHdl : handle );
//    sub _SetField_Line ( aBottom : logic; aLeftIndex : int; aRightIndex : int );
//    sub _SetField ( aNr : int; aText : alpha(300); aRight : logic; aFormat : int; opt aComma : int );
//    sub _Text ( aNr : int; aText : alpha );
//    sub _Print ( aHdl : handle );
//    sub _ZahlF ( aZahl : float; aStellen : int ) : alpha;
//    sub ConvertWidthsToSpacings ( opt aMaxIndex : int; opt aMaxPosition : float; );
//=========================================================================
@I:Def_Global
//@I:Lib_Print
@I:Def_PrintLine
@I:Def_List2


//=========================================================================
// _Init
//        Liste initialisieren
//=========================================================================
sub _Init (
  aLandscape      : logic;
  opt aPaperSize  : alpha;
  opt aListFooter : alpha
) : logic;
local begin
  vHdl    : int;
  vSplash : int;
  vName   : alpha;
  vI      : int;
  vTmp    : int;
end;
begin
  if ( Varinfo( class_List ) = 0 ) then
    RETURN false;

  // Splash-Screen laden
  if (false) and (gUsergroup != 'PROGRAMMIERER' ) then begin
    vSplash # WinOpen( 'Frame.Printing', _winOpenDialog );
    vTmp # WinSearch( vSplash, 'lb.printstatus' );
    vTmp->wpCaption # 'Liste wird aufgebaut...';
    vSplash -> WinDialogRun( _winDialogAsync | _winDialogCenter, gMdi );
  end;

  // XML Ausgabe
  if ( list_XML ) then begin
    FsiDelete( list_Filename );

    // Grundlegende XML Daten übernehmen (Styles...)
    vHdl # TextOpen( 16 );
    TextRead( vHdl, 'XML.Table.Start', 0 );
    TxtWrite( vHdl, list_Filename, _textExtern );
    vHdl->TextClose();

    // Worksheet-Kopf schreiben
    list_FileHdl # FsiOpen( list_FileName, _fsiAcsRW | _fsiDenyRW | _fsiCreate | _fsiAppend);

    if ( list_FileHdl <= 0 ) then begin
      list_XML # false
      Msg( 910005, list_Filename, 0, 0, 0 );
      end
    else begin
      vName # StrCnv( Lfm.Name, _strUmlaut );
      FsiWrite( list_FileHdl, '<Worksheet ss:Name="' + StrCut( StrCnv(vName,_StrLetter), 1, 31 ) + '">' + cCRLF );
      FsiWrite( list_FileHdl, '<Table>' + cCRLF);

      FOR  vI # 1
      LOOP vI # vI + 1;
      WHILE ( vI < 99 ) DO
        FsiWrite( list_FileHdl, '<Column ss:Index="' + CnvAI( vI ) + '" ss:AutoFitWidth="1" ss:Width="100.00" />' + cCRLF );

      Call( Lfm.Prozedur + ':Seitenkopf', 1 );
    end;
  end;

  _app->wpWaitcursor # true;
  APPOFF();

  // Druckausgabe
  if ( !list_XML ) then begin
    PL_Create( list_PL );

    if(aListFooter = '') then begin // MS 20.03.2012
      if (aLandscape) then
        aListFooter # 'LST.UnterschriftQ';
      else
        aListFooter # 'LST.Unterschrift';
    end;
    /*
    if ( aLandscape ) then
      vHdl # PrtFormOpen( _prtTypePrintForm, 'LST.UnterschriftQ' )
    else
      vHdl # PrtFormOpen( _prtTypePrintForm, 'LST.Unterschrift' );
    */
    vHdl # PrtFormOpen( _prtTypePrintForm, aListFooter);

    // Printjob öffnen & Seite erstellen
//    Lib_Print:FrmJobOpen( '', 0, vHdl, false, false, aLandscape, aPapersize );
    Lib_Print:FrmJobOpen(n, 0, vHdl, false, false, aLandscape, aPapersize );

    form_randOben  # Rnd( Lib_Einheiten:LaengenKonv( 'mm', 'LE', 10.0 ) );
    form_randUnten # 0;

    // Dokumentendialog initialisieren
    Lib_Print:FrmPrintDialog( Lfm.Name, aLandscape );
    pls_FontSize # 9;

    // Seitenkopf drucken
    Lib_Print:Print_Seitenkopf(0);
  end;

  RETURN true;
end;


//=========================================================================
// _Term
//        Liste terminieren
//=========================================================================
sub _Term () : logic;
local begin
  vSel    : int;
  vSplash : int;
end;
begin

  APPON();
  _app->wpWaitCursor # false;

  if ( Varinfo( class_List ) = 0 ) then
    RETURN false;

  if ( !list_XML ) then begin
    // Druckausgabe: letzte Seite & Druckjob beenden
    form_Footer->PrtFormClose();
    form_Footer # 0;

    if (List_PDFPath='') then
      Lib_Print:FrmJobClose( (gUserGroup != 'JOB-SERVER') and ((gUsername=*^'SOA*')=false) ,y );
    else
      // APPLE
      Lib_Print:FrmJobClosePDF(n, List_PDFPath, n,n, Lfm.Name);

    if ( list_PL != 0 ) then
      PL_Destroy( list_PL );
  end
  else begin
    // XML Ausgabe: offene Tags schließen & Datei beenden
    FsiWrite( list_FileHdl, '</Table>' + cCRLF );
    FsiWrite( list_FileHdl, '</Worksheet>' + cCRLF );
    FsiWrite( list_FileHdl, '</Workbook>' + cCRLF );
    FsiClose( list_FileHdl );

    // Splash-Screen anpassen
    vSplash # $Frame.Printing;
    if ( vSplash != 0 ) then begin
      vSplash->WinClose();
    end;


    // XML Erfolgsmeldung
    if (list_XML) and (gUserGroup<>'JOB-SERVER') and ((gUsername=*^'SOA*')=false) then begin
      Msg( 910003, list_Filename, 0, 0, 0 );
    end;

  end;

  // Struktur freigeben
  VarFree( class_List );

  RETURN true;
end;


//=========================================================================
// _WriteTitel
//        Listentitel ausgeben (Name, Datum, Seite etc.)
//=========================================================================
sub _WriteTitel ( opt vSuffix : alpha );
local begin
  vAttr : int;
end;
begin
  if ( !list_XML ) then begin
    // Druckausgabe
    Lib_List:_StartLine();
    vAttr # pls_FontAttr;

    pls_FontSize # 20;
    if ( vSuffix != '' ) then
      PL_Print( Lfm.Name + vSuffix, 0.0 );
    else
      PL_Print( Lfm.Name, 0.0 );

    pls_FontSize # 9;
    if ( !form_Landscape ) then begin
      PL_Print( Translate('Datum') + ':',                           150.0 );
      PL_Print( CnvAD( today ),                                     165.0 );
      PL_Print( Translate('Seite') + ':',                           150.0, 165.0, 2 );
      PL_Print( cnvAI( form_Job->prtInfo( _prtJobPageCount ) + 1 ), 165.0, 190.0, 2 );

      PL_Print('/'     ,175.0,180.0,2)
      pls_Hdl->ppStyleCaption # _PrtStyleCapPageCount;
      PL_Print('_', 180.0, 190.0,2);

      end
    else begin
      PL_Print( Translate('Datum') + ':',                           90.0 + 150.0 );
      PL_Print( CnvAD( today ),                                     90.0 + 165.0 );
      PL_Print( Translate('Seite') + ':',                           90.0 + 150.0, 90.0 + 165.0, 2 );
      PL_Print( cnvAI( form_Job->prtInfo( _prtJobPageCount ) + 1 ), 90.0 + 165.0, 90.0 + 190.0, 2 );

      PL_Print('/'     ,90.0 + 175.0, 90.0 + 180.0,2)
      pls_Hdl->ppStyleCaption # _PrtStyleCapPageCount;
      PL_Print('_', 90.0 + 180.0, 90.0 + 190.0,2);
    end;

    pls_FontAttr # vAttr;
    Lib_List:_EndLine();
    Lib_Print:Print_TextAbsolut( '(Liste: ' + CnvAI( Lfm.Nummer ) + ')', 0.0, 2.8, 7 );
  end
  else begin
    // XML Ausgabe
    FsiWrite( list_FileHdl, '<Row ss:StyleID="Mainheader">' + cCRLF );
    FsiWrite( list_FileHdl, '<Cell><Data ss:Type="String">' );
    if ( vSuffix != '' ) then
      FsiWrite( list_FileHdl, Lib_Strings:Strings_DOS2XML( Lfm.Name + vSuffix ) );
    else
      FsiWrite( list_FileHdl, Lib_Strings:Strings_DOS2XML( Lfm.Name ) );
    FsiWrite( list_FileHdl, '</Data></Cell>' + cCRLF );
    FsiWrite( list_FileHdl, '</Row>' + cCRLF );

    FsiWrite(list_FileHdl, '<Row>'+cCRLF);
    FsiWrite(list_FileHdl, '<Cell><Data ss:Type="String">('+cnvai(Lfm.Nummer)+')</Data></Cell>'+cCRLF);
    FsiWrite(list_FileHdl, '</Row>'+cCRLF);

    FsiWrite( list_FileHdl, '<Row>' + cCRLF );
    FsiWrite( list_FileHdl, '<Cell><Data ss:Type="String">Datum ' + CnvAD( today ) + '</Data></Cell>' + cCRLF );
    FsiWrite( list_FileHdl, '</Row>' + cCRLF );
    FsiWrite( list_FileHdl, '<Row>' + cCRLF );
    FsiWrite( list_FileHdl, '</Row>' + cCRLF );
  end;
end;


//=========================================================================
// _NewLine
//        Druckelement initialisieren
//=========================================================================
sub _NewLine ( aName : alpha ) : handle;
local begin
  vHdl : int;
end;
begin
  if ( !list_XML ) then begin
    // Druckausgabe
    vHdl # Lib_PrintLine:Create();
  end
  else begin
    // XML Ausgabe
    vHdl # VarAllocate( class_PrintLine );
    pls_Prt # 0;
    pls_Hdl # CteOpen( _cteList );
    pls_current # 1;
  end;

  pls_Name # aName;
  Call( Lfm.Prozedur + ':Element', pls_Name, false );

  RETURN vHdl;
end;


//=========================================================================
// _FreeLine
//        Druckelement zerstören
//=========================================================================
sub _FreeLine ( aHdl : handle );
begin
  if ( aHdl = 0 ) then
    RETURN;

  if ( Varinfo( class_PrintLine ) != aHdl ) then
    VarInstance( class_PrintLine, aHdl );

  if ( pls_Prt != 0) then begin
    // Druckausgabe
    Lib_PrintLine:Destroy( aHdl );
  end
  else begin
    // XML Ausgabe
    CteClear( pls_Hdl, true );
    CteClose( pls_Hdl );
    pls_Hdl # 0;
    VarFree( class_PrintLine );
  end;
end;


//=========================================================================
// _SetField_Line
//        Sonderzellenelement Linie initialisieren
//=========================================================================
sub _SetField_Line ( aBottom : logic; aLeftIndex : int; aRightIndex : int );
local begin
  vLeftX  : float;
  vRightX : float;
  vHeight : int;
  vI      : int;
end;
begin
  if ( aLeftIndex > 0 ) then
    vLeftX  # list_Spacing[ aLeftIndex ];
  else
    vLeftX  # 0.0;

  if ( aRightIndex > 0 ) then
    vRightX # list_Spacing[ aRightIndex ];
  else begin
    vI # 100;
    WHILE ( list_Spacing[vI] = 0.0 ) and ( vI > 0 ) DO
      vI # vI - 1;
    vRightX # list_Spacing[vI];
  end;

  if ( pls_Hdl != 0 ) then
    vHeight # pls_Hdl->ppAreaBottom - pls_Hdl->ppAreaTop;
  else
    vHeight # 23400; // 9pt text

  // Linie anzeigen
  pls_Hdl # PrtSearch( pls_Prt, 'PrtDivider0' );
  pls_Hdl->ppVisiblePrint # _prtVisiblePrintJob | _prtVisiblePrintPreview;
  pls_Hdl->ppAreaLeft     # PrtUnitLog( vLeftX, _prtUnitMillimetres );
  pls_Hdl->ppAreaRight    # PrtUnitLog( vRightX, _prtUnitMillimetres );

  if ( !aBottom ) then begin
    pls_Hdl->ppAreaTop    # PrtUnitLog( 0.0, _prtUnitMillimetres );
    pls_Hdl->ppAreaBottom # PrtUnitLog( 1.0, _prtUnitMillimetres );
  end
  else begin
    pls_Hdl->ppAreaTop    # vHeight
    pls_Hdl->ppAreaBottom # vHeight + PrtUnitLog( 1.0, _prtUnitMillimetres );
  end;
end;


//=========================================================================
// _SetField
//        Zellenelement initialisieren
//=========================================================================
sub _SetField ( aNr : int; aText : alpha(300); aAlign : logic; opt aFormat : int; opt aComma : int );
local begin
  vFont   : font;
  vLeftX  : float;
  vRightX : float;
  vComma  : int;
  vItem   : int;
end;
begin
  if ( aNr = 0 ) then begin // Sonderfelder
    if ( !list_XML ) and ( aText = '##LINE##' ) then
      _SetField_Line( aAlign, aFormat, aComma );

    RETURN;
  end;

  if ( !list_XML ) then begin
    // Druckausgabe
    pls_Hdl # PrtSearch( pls_Prt, 'tx.Combo' + CnvAI( aNr ) );
    aFormat # aFormat | pls_Format;

    // Zelleninhalt
    if ( aText != '' ) then begin
      if ( StrCut( aText, 1, 1 ) = '@' ) then begin // Feldinhalt
        pls_Hdl->ppDbFieldName # StrCut( aText, 2, 20 );

        // Alpha Felder leeren um Zeilenumbruch zu vermeiden
        if ( FldInfoByName( pls_Hdl->ppDbFieldName, _fldType ) = _typeAlpha ) then
          FldDefByName( pls_Hdl->ppDbFieldName, '' );

        if ( FldInfoByName( pls_Hdl->ppDbFieldName, _fldType ) = _typeDate ) then begin
          pls_Hdl->ppFmtDateStyle # _WinFmtDateString;
          pls_Hdl->ppFmtDateString # 'dd.MM.yy';
        end;
      end
      else if ( StrCut( aText, 1, 1 ) = '#' ) then // Kommentar
        aText # '';
      else if ( Set.TranslateYN ) then // statischer Text
        aText # Translate( aText );
    end;

    // Schriftausprägung
    vFont            # pls_Hdl->ppFont;
    vFont:attributes # pls_fontAttr;

    if ( aFormat & _LF_Bold != 0 ) then begin
      aFormat # aFormat ^ _LF_Bold;
      vFont:attributes # vFont:attributes | _winFontAttrBold;
    end;
    if ( aFormat & _LF_Italic != 0 ) then begin
      aFormat # aFormat ^ _LF_Italic;
      vFont:attributes # vFont:attributes | _WinFontAttrItalic;
    end;

    if ( pls_fontName != '' ) then
      vFont:name # pls_fontName;

    if ( list_FontSize != 0 ) then
      vFont:size # list_FontSize * 10;
    else
      vFont:size # 90;

    pls_Hdl->ppFont # vFont;

    // Zellenformat
    vComma # -1;
    if ( aFormat & _LF_IntNG != 0 ) then begin
      vComma # 0;
      pls_Hdl->ppFmtIntFlags # _fmtNumNoGroup;
    end
    else if ( aFormat & _LF_Int != 0 ) then
      vComma # 0;
    else if ( aFormat & _LF_Wae != 0 ) then
      vComma # 2;
    else if ( aFormat & _LF_Num != 0 ) then
      vComma # aComma;
    else if ( aFormat & _LF_Num0 != 0 ) then
      vComma # aComma;
    else if ( aFormat & _LF_Num3 != 0 ) then
      vComma # aComma;

    if ( vComma > -1 ) then
      pls_Hdl->ppFmtPostComma # vComma;

    // Ausgabe
    vLeftX  # list_Spacing[ aNr ] + 1.0;
    vRightX # list_Spacing[ aNr + 1 ] - 1.0;

    if ( vLeftX <= 0.0 ) then
      vLeftX  # 0.0;
/*
    else if ( vLeftX >= 297.0 ) then
      vLeftX  # 297.0;
    if ( vRightX <= 0.0 ) or ( vRightX >= 297.0 ) then
      vRightX # 297.0;
*/

    pls_Hdl->ppCaption      # aText;
    pls_Hdl->ppColBkg       # _winColTransparent;
//pls_Hdl->ppColBkg       # _winColblue;
    pls_Hdl->ppVisiblePrint # _prtVisiblePrintJob | _prtVisiblePrintPreview;
    pls_Hdl->ppAreaLeft     # PrtUnitLog( vLeftX, _prtUnitMillimetres );
    pls_Hdl->ppAreaRight    # PrtUnitLog( vRightX, _prtUnitMillimetres );
    pls_Hdl->ppWordBreak    # true;
    pls_Hdl->ppAutoSize     # true;

    if ( aAlign ) then begin
      if ( aFormat & _LF_Centered != 0 ) then
        pls_Hdl->ppJustify  # _winJustCenter;
      else
        pls_Hdl->ppJustify  # _winJustRight;
    end;
  end
  else begin
    // XML Ausgabe
    vItem # CteOpen( _cteItem );
    vItem->spName   # aText;
    vItem->spID     # aNr;
    vItem->spCustom # CnvAI( aFormat );
    CteInsert( pls_Hdl, vItem );
  end;
end;


//=========================================================================
// _Text
//        Zelleninhalt anpassen
//=========================================================================
sub _Text ( aNr : int; aText : alpha(300) );
local begin
  vItem : int;
  vTmp  : int;
end;
begin
  if ( !list_XML ) then begin
    // Druckausgabe
    vTmp # PrtSearch( pls_Prt, 'tx.Combo' + CnvAI( aNr ) );
    vTmp->ppCaption # aText;
  end
  else begin
    // XML Ausgabe
    FOR  vItem # CteRead( pls_Hdl, _cteFirst );
    LOOP vItem # CteRead( pls_Hdl, _cteNext, vItem );
    WHILE ( vItem != 0 ) DO BEGIN
      if ( vItem->spID = aNr ) then begin
        vItem->spName # aText;
        BREAK;
      end;
    END;
  end;
end;


//=========================================================================
// _Print
//        Druckelement ausgeben
//=========================================================================
sub _Print ( aHdl : handle );
local begin
  vItem     : int;
  vNr       : int;
  vText     : alpha(300);
  vFormat   : int;
  vStyle    : alpha;
  vStyle2   : alpha;
  vType     : alpha;
  vFormula  : alpha;
  vF        : float;
end;
begin
  if ( aHdl = 0 ) then
    RETURN;

  if ( Varinfo( class_PrintLine ) != aHdl ) then
    VarInstance( class_PrintLine, aHdl );

  // dynamische Inhalte laden
  Call( Lfm.Prozedur + ':Element', pls_Name, true );

  if ( !list_XML ) then begin
    // Druckausgabe
    if ( pls_Format & _LF_OverLine = _LF_OverLine ) then begin
      if ( form_Landscape ) then
        Lib_Print:Print_LinieEinzeln( 0.0, 427.0 ); //350.0 277
      else
        Lib_Print:Print_LinieEinzeln( 0.0, 190.0 ); //195.0
    end;

    Lib_Print:LfPrint( pls_Prt, true ); // andrucken, aber handle behalten

    if ( pls_Format & _LF_Underline = _LF_Underline ) then begin
      if ( form_Landscape ) then
        Lib_Print:Print_LinieEinzeln( 0.0, 427.0 ); //350.0 277
      else
        Lib_Print:Print_LinieEinzeln( 0.0, 190.0 ); //195.0
    end;

    end
  else begin
    // XML Ausgabe
    if ( pls_Format = _LF_Underline ) then
      FsiWrite( list_FileHdl, '<Row ss:Height="13.5" ss:StyleID="UL">' + cCRLF );
    else if ( pls_Format = _LF_Overline ) then
      FsiWrite( list_FileHdl, '<Row ss:Height="13.5" ss:StyleID="OL">' + cCRLF );
    else
      FsiWrite( list_FileHdl, '<Row>' + cCRLF);

    // Felder loopen.....
    FOR  vItem # pls_Hdl->CteRead( _cteFirst );
    LOOP vItem # pls_Hdl->CteRead( _cteNext, vItem );
    WHILE ( vItem > 0 ) DO BEGIN
      // Zelleninhalt schreiben...
      vNr     # vItem->spID;
      vText   # vItem->spName;
      vFormat # CnvIA( vItem->spCustom );

      // Formel extrahieren
      if ( vFormat & _LF_Formula = _LF_Formula ) then begin
        vFormat  # vFormat ^ _LF_Formula;
        vFormula # ' ss:Formula="' + vText + '"';
        vText    # ''
      end;

      if ( vText != '' ) then begin
        // Feldinhalt
        if ( StrCut( vText, 1, 1 ) = '@' ) then begin
          vText # StrCut( vText, 2, 20 );
          case FldInfoByName( vText, _fldType ) of
            _typeAlpha : vText # FldAlphaByName( vText );
            _typeWord  : vText # CnvAI( FldWordByName( vText ), _fmtNumNoGroup );
            _typeInt   : vText # CnvAI( FldIntByName( vText ), _fmtNumNoGroup );
            _typeFloat : vText # CnvAF( FldFloatByName( vText ), _fmtNumNoGroup,0,5 );  // 02.05.2018 AH: immer 5 Nackommastellen
            _typeDate  : vText # CnvAD( FldDateByName( vText ) );
            _typeTime  : vText # CnvAT( FldTimeByName( vText ) );
            _typeLogic : vText # CnvAI( CnvIL( FldLogicByName( vText ) ) );
          end;
        end;
      end;

      // Zellenformat mit Zeilenformat kombinieren
      vFormat # vFormat | pls_Format;
      if ( vFormat & ( _LF_Bold + _LF_Underline ) = (_LF_Bold + _LF_Underline)) then
        vStyle2 # 'UL+B'
      else if ( vFormat & ( _LF_Bold + _LF_Overline ) = (_LF_Bold + _LF_Overline)) then
        vStyle2 # 'OL+B'
      else if ( vFormat & _LF_Overline = _LF_Overline ) then
        vStyle2 # 'OL'
      else if ( vFormat & _LF_Underline = _LF_Underline  ) then
        vStyle2 # 'UL'
      else if ( vFormat & _LF_Bold = _LF_Bold ) then
        vStyle2 # 'B'

      // Datentyp bestimmen
      vFormat # vFormat & ( _LF_String | _LF_IntNG | _LF_Int | _LF_Wae | _LF_Num | _LF_Num0 | _LF_Num3 | _LF_Date );
      case vFormat of
        _LF_String : begin
          vStyle # '';
          vType  # 'String';
        end;

        _LF_WAE : begin
          vStyle # 'c16_wae';
          vType  # 'Number';
          vText  # Str_ReplaceAll( vText, '.', '' );
          vText  # Str_ReplaceAll( vText, ',', '.' );
        end;

        _LF_Date : begin
          vStyle # 'c16_date';
          vType  # 'DateTime';
        end;

        _LF_INT, _LF_IntNG : begin
          vStyle # '';
          vType  # 'Number';
          vText  # Str_ReplaceAll( vText, '.', '' );
          vText  # Str_ReplaceAll( vText, ',', '.' );
        end;

        _LF_NUM : begin
          vStyle # 'c16_num';
          vType  # 'Number';
          vF # cnvfa(vText);
          if (vF<-999999999999.0) then vText # CnvAF( -999999999999.0, _fmtNumNoGroup);
          else if (vF>999999999999.0) then vText # CnvAF( 999999999999.0, _fmtNumNoGroup);
          vText  # Str_ReplaceAll( vText, '.', '' );
          vText  # Str_ReplaceAll( vText, ',', '.' );
        end;

        _LF_NUM0 : begin
          vStyle # 'c16_num0';
          vType  # 'Number';
          vF # cnvfa(vText);
          if (vF<-999999999999.0) then vText # CnvAF( -999999999999.0, _fmtNumNoGroup);
          else if (vF>999999999999.0) then vText # CnvAF( 999999999999.0, _fmtNumNoGroup);
          vText  # Str_ReplaceAll( vText, '.', '' );
          vText  # Str_ReplaceAll( vText, ',', '.' );
        end;

        _LF_NUM3 : begin
          vStyle # 'c16_num3';
          vType  # 'Number';
          vF # cnvfa(vText);
          if (vF<-999999999999.0) then vText # CnvAF( -999999999999.0, _fmtNumNoGroup);
          else if (vF>999999999999.0) then vText # CnvAF( 999999999999.0, _fmtNumNoGroup);
          vText  # Str_ReplaceAll( vText, '.', '' );
          vText  # Str_ReplaceAll( vText, ',', '.' );
        end;
      end;

      if ( vStyle2 != '' ) then begin
        if ( vStyle != '' ) then
          vStyle # vStyle + '+' + vStyle2;
        else
          vStyle # vStyle2;
      end;

      if ( vStyle != '' ) then
        vStyle # ' ss:StyleID="' + vStyle + '"';

      FsiWrite( list_FileHdl, '<Cell ss:Index="' + CnvAI( vNr ) + '"' + vStyle + vFormula + '>' );
      FsiWrite( list_FileHdl, '<Data ss:Type="' + vType + '">' );
      vText # Lib_Strings:Strings_DOS2XML( vText );
      FsiWrite( list_FileHdl, vText);
      FsiWrite( list_FileHdl, '</Data>' );
      FsiWrite( list_FileHdl, '</Cell>' + cCRLF );
    END;
    FsiWrite( list_FileHdl, '</Row>' + cCRLF );
  end; // XML Ausgabe
end;


//=========================================================================
// _ZahlF
//        Umwandlung von Float in Alpha
//=========================================================================
sub _ZahlF ( aZahl : float; aStellen : int ) : alpha;
begin
  if ( list_XML ) then
    RETURN ANum( aZahl, aStellen );
  else
    RETURN CnvAF( aZahl, 0, 0, aStellen );
end;


//=========================================================================
// ConvertWidthsToSpacings
//        Automatische Umwandlung von Spaltenbreiten in Spaltenspacings
//        DIN A4 aMaxPosition: 277 (Querformat), 190 (Hochformat)
//=========================================================================
sub ConvertWidthsToSpacings ( opt aMaxIndex : int; opt aMaxPosition : float; );
local begin
  vI        : int;
  vPosition : float;
  vWidth    : float;
end;
begin
  if ( aMaxIndex <= 0 ) or ( aMaxIndex >= 100 ) then
    aMaxIndex # 99;

  FOR  vI # 1;
  LOOP vI # vI + 1;
  WHILE ( vI <= aMaxIndex ) DO BEGIN
    vWidth           # list_Spacing[vI];
    list_Spacing[vI] # vPosition;
    vPosition        # vPosition + vWidth;
  END;

  list_Spacing[aMaxIndex + 1] # aMaxPosition;
end;

//=========================================================================
//=========================================================================