//==== Business-Control ===================================================
//
//  Prozedur    Lib_ListApple
//                OHNE E_R_G
//  Info
//        Routinen für die Ausgabe von Listen als Apple Ipod App XML.
//        Wird in Kopien von Listen anstatt Lib_List2 eingebunden
//
//  27.06.2011  ST  Erstellung der Prozedur
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
@I:Def_ListApple
@I:Lib_ListApple

//=========================================================================
// _Init
//        Liste initialisieren
//=========================================================================
sub _Init (
  aLandscape      : logic;
  opt aPaperSize  : alpha) : logic;
local begin
  vHdl    : int;
  vSplash : int;
  vName   : alpha;
  vI      : int;
  vTmp    : int;

  vXml : handle;

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
  vName # StrCnv( Lfm.Name, _strUmlaut );

  list_FileHdl # list_FileHdl->Lib_XML:AppendNode('report');
  list_FileHdl->Lib_XML:AppendAttributeNode('xmlns', 'http://stahl-control.de/xml/report');
  list_FileHdl->Lib_XML:AppendNode('title',vName);
  list_FileHdl->Lib_XML:AppendNode('date',CnvAD( today ));

  list_FileHdl # list_FileHdl->Lib_XML:AppendNode('tableData');

  Call( Lfm.Prozedur + ':Seitenkopf', 1 );

  _app->wpWaitcursor # true;
  APPOFF();

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

  // Splash-Screen anpassen
  vSplash # $Frame.Printing;
  if ( vSplash != 0 ) then begin
    vSplash->WinClose();
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
begin
  //list_FileHdl->Lib_XML:AppendNode('date',CnvAD( today ));
end;


//=========================================================================
// _NewLine
//        Druckelement initialisieren
//=========================================================================
sub _NewLine ( aName : alpha ) : handle;
begin
  RETURN Lib_List2:_NewLine(aName);
end;


//=========================================================================
// _FreeLine
//        Druckelement zerstören
//=========================================================================
sub _FreeLine ( aHdl : handle );
begin
  Lib_List2:_FreeLine(aHdl);
end;


//=========================================================================
// _SetField_Line
//        Sonderzellenelement Linie initialisieren
//=========================================================================
sub _SetField_Line ( aBottom : logic; aLeftIndex : int; aRightIndex : int );
begin
  RETURN;   // geht nicht, da keine Formatierung
end;


//=========================================================================
// _SetField
//        Zellenelement initialisieren
//=========================================================================
sub _SetField ( aNr : int; aText : alpha(300); aAlign : logic; opt aFormat : int; opt aComma : int );
begin
  Lib_List2:_SetField(aNr,aText,aAlign,aFormat,aComma);
end;


//=========================================================================
// _Text
//        Zelleninhalt anpassen
//=========================================================================
sub _Text ( aNr : int; aText : alpha(300) );
local begin
  vItem : handle;
end
begin
  FOR  vItem # CteRead( pls_Hdl, _cteFirst );
  LOOP vItem # CteRead( pls_Hdl, _cteNext, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    if ( vItem->spID = aNr ) then begin
      vItem->spName # aText;
      vItem->spCustom # '##TEXT##';
      BREAK;
    end;
  END;
end;


//=========================================================================
// _Print
//        Druckelement ausgeben
//=========================================================================
sub _Print ( aHdl : handle );
local begin
  vItem         : int;
  vNr           : int;
  vText         : alpha(300);
  vFormat       : int;
  vStyle        : alpha;
  vXmlRow       : handle;
  vXmlRowCell   : handle;
  vIsHeader     : logic;
  vCellElemTyp  : alpha;
  vIndex        : int;
  vIndexMax     : int;
  vCnt          : int;
end;
begin
  if ( aHdl = 0 ) then
    RETURN;

  if ( Varinfo( class_PrintLine ) != aHdl ) then
    VarInstance( class_PrintLine, aHdl );

  // dynamische Inhalte laden
  Call( Lfm.Prozedur + ':Element', pls_Name, true );

  // Felder loopen.....
  vIsHeader # true;     // False == Spaltenüberschrift
  vXmlRow  # 0;
  vCnt # 0;
  FOR  vItem # pls_Hdl->CteRead( _cteFirst );
  LOOP vItem # pls_Hdl->CteRead( _cteNext, vItem );
  WHILE ( vItem > 0 ) DO BEGIN
    inc(vCnt);

    // Zelleninhalt schreiben...
    vNr     # vItem->spID;
    vText   # vItem->spName;
    if (vItem->spCustom = '##TEXT##') then begin
      vIsHeader # false;
      vFormat # 0;
    end
    else
      vFormat # CnvIA( vItem->spCustom );
    vIndex # vNr;

    // Wenn keine @,# oder am Anfang steht, Column
    if (StrCut(vText,1,1) = '#') OR
       (StrCut(vText,1,1) = '@') then begin

      // Daten
      //if (vCnt > vIndexMax) then
        vIsHeader # false;     // False == Spaltenüberschrift
    end
    else begin
      // Spaltenüberschrift
      if (vIndex >= vIndexMax) then
        vIndexMax # vIndex;
    end;

    if ( vText != '' ) then begin
      // Feldinhalt
      if ( StrCut( vText, 1, 1 ) = '@' ) then begin
        vText # StrCut( vText, 2, 20 );
        case FldInfoByName( vText, _fldType ) of
          _typeAlpha : begin
            vText # FldAlphaByName( vText );
            vCellElemTyp # 'stringCell';
          end;
          _typeWord  : begin
            vText # CnvAI( FldWordByName( vText ), _fmtNumNoGroup );
            vCellElemTyp # 'integerCell';
          end;
          _typeInt   : begin
            vText # CnvAI( FldIntByName( vText ), _fmtNumNoGroup );
            vCellElemTyp # 'integerCell';
          end;
          _typeFloat : begin
            vText # CnvAF( FldFloatByName( vText ), _fmtNumNoGroup );
            vCellElemTyp  # 'decimalCell';
          end;
          _typeDate  : begin
            vText # CnvAD( FldDateByName( vText ) );
            vCellElemTyp # 'dateCell';
          end;
          _typeTime  : begin
            vText # CnvAT( FldTimeByName( vText ) );
            vCellElemTyp # 'stringCell';
          end;
          _typeLogic : begin
            vText # CnvAI( CnvIL( FldLogicByName( vText ) ) );
            vCellElemTyp # 'booleanCell';
          end;
        end;
      end;
    end;

    // Zellenformat mit Zeilenformat kombinieren
    vFormat # vFormat | pls_Format;
    if ( vFormat & ( _LF_Bold + _LF_Underline ) = (_LF_Bold + _LF_Underline)) then
      vStyle # 'bold' // vStyle # 'UL+B'
    else if ( vFormat & ( _LF_Bold + _LF_Overline ) = (_LF_Bold + _LF_Overline)) then
      vStyle # 'bold' // vStyle # 'OL+B'
    else if ( vFormat & _LF_Overline = _LF_Overline ) then
      vStyle # '' // vStyle # 'OL'
    else if ( vFormat & _LF_Underline = _LF_Underline  ) then
      vStyle # '' //vStyle # 'UL'
    else if ( vFormat & _LF_Bold = _LF_Bold ) then
      vStyle # 'bold' //vStyle # 'B'

    // Datentyp bestimmen
    vFormat # vFormat & ( _LF_String | _LF_IntNG | _LF_Int | _LF_Wae | _LF_Num | _LF_Num0 | _LF_Num3 | _LF_Date );
    case vFormat of
      _LF_String : begin
        vCellElemTyp # 'stringCell';
      end;

      _LF_WAE : begin
        vCellElemTyp # 'currencyCell';
        vText  # Str_ReplaceAll( vText, '.', '' );
        vText  # Str_ReplaceAll( vText, ',', '.' );
      end;

      _LF_Date : begin
        vCellElemTyp # 'dateCell';
      end;

      _LF_INT, _LF_IntNG : begin
        vCellElemTyp # 'integerCell';
        vText  # Str_ReplaceAll( vText, '.', '' );
        vText  # Str_ReplaceAll( vText, ',', '.' );
      end;

      _LF_NUM : begin
        vCellElemTyp # 'decimalCell';
        vText  # Str_ReplaceAll( vText, '.', '' );
        vText  # Str_ReplaceAll( vText, ',', '.' );
      end;

      _LF_NUM0 : begin
        vCellElemTyp # 'decimalCell';
        vText  # Str_ReplaceAll( vText, '.', '' );
        vText  # Str_ReplaceAll( vText, ',', '.' );
      end;

      _LF_NUM3 : begin
        vCellElemTyp # 'decimalCell';
        vText  # Str_ReplaceAll( vText, '.', '' );
        vText  # Str_ReplaceAll( vText, ',', '.' );
      end;
    end;


    if (vIsHeader) then begin
      // Column schreiben
      vXmlRow # list_FileHdl->Lib_XML:AppendNode('column',vText);
      vXmlRow->Lib_XML:AppendAttributeNode('index',Aint(vIndex));
      if (vStyle <> '') then
         vXmlRow->Lib_XML:AppendAttributeNode('style',vStyle);

    end
    else begin
      // Row schreiben

      //if (vIndex = 1) then
      if (vCnt = 1 or vXmlRow = 0) then
        vXmlRow # list_FileHdl->Lib_XML:AppendNode('row');

      vXmlRowCell # vXmlRow->Lib_XML:AppendNode(vCellElemTyp,vText);
      vXmlRowCell->Lib_XML:AppendAttributeNode('index',Aint(vIndex));
      if (vStyle <> '') then
         vXmlRow->Lib_XML:AppendAttributeNode('style',vStyle);
    end;


  END;

end;


//=========================================================================
// _ZahlF
//        Umwandlung von Float in Alpha
//=========================================================================
sub _ZahlF ( aZahl : float; aStellen : int ) : alpha;
begin
  RETURN Lib_List2:_ZahlF(aZahl,aStellen);
end;


//=========================================================================
// ConvertWidthsToSpacings
//        Automatische Umwandlung von Spaltenbreiten in Spaltenspacings
//        DIN A4 aMaxPosition: 277 (Querformat), 190 (Hochformat)
//=========================================================================
sub ConvertWidthsToSpacings ( opt aMaxIndex : int; opt aMaxPosition : float; );
begin
  RETURN;
end;

//=========================================================================
//=========================================================================