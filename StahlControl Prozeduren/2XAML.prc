@A+
//===== Business-Control =================================================
//
//  Prozedur  2XAML
//                OHNE E_R_G
//  Info
//
//
//  21.06.2014  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  Text(a)   : TextLineWrite(gBuf,TextInfo(gBuf,_TextLines)+1,a,_TextLineInsert)
  Tab(a)    : StrChar(32,a*4)

  cPath             : 'd:\C16_Export'

  // RASTER 10 x 12
  cBorderTop  : 8
  cBorderLeft : 10

  cWOffset    : 0 //-2
end;

local begin
  gPad        : alpha;
  gBuf        : int;
  gZeile      : alpha(4000);
  gObj        : int;
  gOffset     : int;
  gProc       : alpha;
  gNamePrefix : alpha;
  gNameFile   : int;
  gName       : alpha;
end;

//========================================================================
sub _ScaleX(var aWert : int);
begin
//  aWert # cnvif( cnvfi(aWert) * (0.9));
  aWert # cnvif( cnvfi(aWert) * (198.0 / 222.0));   // 0.9
  // gültige Werte: 198, 188, 178
//  aWert # (aWert / 10 * 10);
end;

sub _RasterX(var aWert : int);
local begin
  vWert : int;
end;
begin
  if ((aWert % 10)>0) then vWert # 10;
  aWert # (aWert / 10 * 10) + vWert;
end;

//========================================================================
sub _ScaleY(var aWert : int);
begin
  aWert # cnvif( cnvfi(aWert) * (24.0/28.0));
  aWert # (aWert / 12) * 12;
end;


//========================================================================
sub _Label(aName : alpha) : alpha;
begin
  RETURN Call('Test+Sql:C16toCSharp', aName,'');
//  Lib_Strings:Strings_Dos2XML(aName);
end;

//========================================================================
sub _CopyBuf(
  aVon    : int;
  aNach   : int;
  aHeader : alpha);
local begin
  vI      : int;
  vFirst  : logic;
end
begin
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=TextInfo(aVon, _TextLines)) do begin
    if (vFirst=false) then begin
      TextLineWrite(aNach, TextInfo(aNach, _textLines)+1, aHeader, _TextLineInsert);
      vFirst # true;
    end;
    TextLineWrite(aNach, TextInfo(aNach, _textLines)+1, TextLineRead(aVon, vI, 0), _TextLineInsert);
  END;
end;

//========================================================================
//========================================================================
sub Open(
  aObj          : int;
  aText         : alpha(4095);
  opt aNoName   : logic);
local begin
  vName     : alpha;
  vTabName  : alpha;
  vI      : int;
end;
begin
  gOffset # 0;
  gObj    # aObj;
  gZeile  # aText;
  if (aNoName=false) then begin
    vName # aObj->wpname;
    if (StrCut(vName,1,2)='ed') then vName # StrCut(vName,3,100);
    if (StrCut(vName,1,2)='cb') then vName # StrCut(vName,3,100);

    vName # Call('Test+Sql:C16toCSharp', vName, gNamePrefix);
//    vI # Lib_Strings:Strings_Count(vName, '.');
//    if (vI>0) then vName # Lib_Strings:Strings_Token(vName,'.',vI+1);
//    vName # Lib_Strings:Strings_ReplaceAll(vName,'.','_');

    gZeile  # gZeile+' Name="'+vName+'"';

    if (aObj->wpDbFieldName<>'') then begin
      vName # aObj->wpDbFieldName;
      if (vTabName='') and (FldInfoByName(vName, _fldExists)=1) then begin
        vI # FldInfoByName(vName, _FldFileNumber);
        if (vI<>0) then
          vTabName # Lib_Odbc:TableName(vI);
      end;
      vName # Call('Test+Sql:C16toCSharp', vName, gNamePrefix);

      gZeile  # gZeile+' Value="{Binding Data.'+vTabName+'Obj.'+vName+', Mode=TwoWay}"';
    end;
  end;

end;


//========================================================================
//========================================================================
sub Close()
begin
  if (gObj=0) then RETURN;

  if (gZeile<>'') then begin
    gZeile # gZeile + '/>';
    if (StrLen(gZeile)>250) then begin
      textLineWrite(gBuf,TextInfo(gBuf,_TextLines)+1,StrCut(gZeile,1,250),_TextLineInsert | _TextNoLineFeed);
      textLineWrite(gBuf,TextInfo(gBuf,_TextLines)+1,StrCut(gZeile,251,250),_TextLineInsert);
    end
    else begin
      textLineWrite(gBuf,TextInfo(gBuf,_TextLines)+1,gZeile,_TextLineInsert);
    end;
  end;

  gObj # 0;
end;

//========================================================================
//========================================================================
sub AddBold() : logic;
local begin
  vFont : font;
end
begin

  vFont # gObj->wpFont;
  if (vFont:Attributes & _WinFontAttrBold>0) then begin
    gZeile # gZeile + ' FontWeight="Bold"';
    RETURN true;
  end;

  RETURN false;
end;

//========================================================================
sub AddHAlignment();
begin
  if (gObj->wpJustify=_WinJustRight) then
    gZeile # gZeile + ' HorizontalContentAlignment="Right"';
end;

//========================================================================
sub AddPos(
  opt aOffX   : int;
  opt aOffY   : int;
  opt aDebug  : logic);
local begin
  vX :  int;
  vY :  int;
end;
begin
  //gZeile # gZeile + ' Canvas.Left="'+aint(gObj->wpareaLeft-gOffset)+'" Canvas.Top="'+aint(gObj->wpAreaTop)+'"';

  // SCALE
if (aDebug) then
debug('X = '+aint(gObj->wpAreaLeft) + ' - 16 - '+aint(gOffset));
  vX # gObj->wpAreaLeft - 16 - gOffset;
  vY # gObj->wpAreaTop - 14;
  _ScaleX(var vX);
  _ScaleY(var vY);
if (aDebug) then
debug('ScaleX = '+aint(vX));

if (aDebug) then
debug('X = '+aint(vX)+' + '+aint(cBorderLeft)+' + '+aint(aOffX)+' = '+aint(vX + cBorderLeft + aOffX));
  vX # vX + cBorderLeft + aOffX;

  _RasterX(var vX);
if (aDebug) then
debug('RasterX = '+aint(vX));
  vY # vY + cBorderTop + aOffY;


  gZeile # gZeile + ' Canvas.Left="'+aint(vX)+'" Canvas.Top="'+aint(vY)+'"';
end;

//========================================================================
sub AddWidth(
  opt aOffset : int;
  opt aDebug  : logic);
local begin
  vW  : int;
end;
begin
/**
  vW # gObj->wpAreaRight-gObj->wpAreaLeft+gOffset+aOffset;  // 10.08.2016 war gOffset
  if (vW<20) then vW # vW + 16 + aOffset;
if (aDebug) then
debug('W: '+aint(vW));
  _ScaleX(var vW);
if (aDebug) then
debug('ScaleW: '+aint(vW));
  _RasterX(var vW);
if (aDebug) then
debug('RasterW: '+aint(vW));
if (aDebug) then
debug('FinaleW = '+aint(vW)+' + '+aint(cWOffSet)+' = '+aint(vW + cWOffset));
**/
aOffset # aOffset + cWOffset;
  vW # gObj->wpAreaRight-gObj->wpAreaLeft+gOffset;
  if (vW<20) then vW # 20;//vW # vW + 16;

if (aDebug) then
debug('W: '+aint(vW));
  _ScaleX(var vW);
if (aDebug) then
debug('ScaleW: '+aint(vW));
  _RasterX(var vW);
if (aDebug) then
debug('RasterW: '+aint(vW));
if (aDebug) then
debug('FinaleW = '+aint(vW)+' + '+aint(aOffSet)+' = '+aint(vW + aOffset));

  vW # vW + aOffset;
  gZeile # gZeile + ' Width="'+aint(vW)+'"'

//  if (gOffset>0+10) and (gOffSet<>118+10) then
//    gZeile # gZeile + ' LabelWidth="'+aint(gOffset-5)+'"';
//  if (gOffset>4) and (gOffSet<>106) then
//    gZeile # gZeile + ' LabelWidth="'+aint(gOffset)+'"';    // war 5
  if (gOffset>0) and (gOffset<>128) then
    gZeile # gZeile + ' LabelWidth="'+aint(gOffset)+'"';    // war 5

end;

//========================================================================
sub AddX2();
local begin
  vW  : int;
end;
begin
  vW # gObj->wpAreaRight-gObj->wpAreaLeft;
  _ScaleX(var vW);
  gZeile # gZeile + ' X2="'+aint(vW)+'"'
end;

//========================================================================
sub AddY2();
local begin
  vW  : int;
end;
begin
  vW # gObj->wpAreaBottom-gObj->wpAreaTop;
  _ScaleY(var vW);
  gZeile # gZeile + ' Y2="'+aint(vW)+'"'
end;

//========================================================================
sub AddContent();
begin
  if (gObj->wpCaption='') then gOBj->wpcaption # 'blabla';
  gZeile # gZeile + ' Content="'+Lib_Strings:Strings_Dos2XML(gObj->wpCaption)+'"'
end

//========================================================================
sub AddFeldInFront();
begin
  if (gObj->wpCaption='') then RETURN;
  gZeile # gZeile + ' FeldInFront="True" Label="'+ Lib_Strings:Strings_Dos2XML(gObj->wpCaption) +'"';
end

//========================================================================
sub FindLabel(
  aObj        : int
);
local begin
  vObj  : int;
  vName : alpha;
end;
begin
  vName # StrCnv(gObj->wpname,_Strupper);

  FOR  vObj # aObj->WinInfo( _winFirst,0,_winTypeLabel );
  LOOP vObj # vObj->WinInfo( _winNext,0,_winTypeLabel );
  WHILE ( vObj > 0 ) DO BEGIN
    if (vObj->wpObjLink<>'') then begin
      if (Strcnv(vObj->wpObjLink,_StrUpper)=vName) then begin
//debug('FOUND!!! '+vObj->wpname);
        gZeile  # gZeile + ' Label="'+Lib_Strings:Strings_Dos2XML(vObj->wpCaption)+'"';
        gOffset # vObj->wpareaRight - vObj->wpAreaLeft + 10;    // 10 = Zwischenraum Label zu Editfeld in C16
//debugx('Obj, Offset:'+vObj->wpname+' '+aint(gOffset));
        RETURN
      end;
    end;
  END;

//  gZeile # gZeile + '';
end


//========================================================================
sub AddAuswahl();
local begin
  vTxt  : int;
  vA    : alpha(200);
  vI    : int;
end;
begin

  if (gProc='') then RETURN;

  vTxt # TextOpen(20);
  TextRead(vTxt, gProc, _TextProc);

  vA # 'SetStdAusFeld('''+gObj->wpName+'''';
  vI # TextSearch(vTxt, 1, 1, _textSearchCI, vA);
  if (vI<>0) then begin
    gZeile  # gZeile + ' IsAuswahl="True"';
    gObj->wpAreaRight # gObj->wpAreaRight + 24;//18?
  end;

  TextClose(vTxt);
end;


//========================================================================
sub _ParseList(
  aObj    : int;
  aDatei  : int;
  aName   : alpha;) : logic;
local begin
  vErg  : int;
  vObj  : int;
  vTyp  : alpha;
  vA,vB : alpha(1000);
  vName : alpha;
  vI,vJ : int;
  vTDS  : int;
  vFld  : int;
  vTxtIndex  : int;
end;
begin
  if (aObj=0) then RETURN false;


  Text('using System;');
  Text('');
  Text('namespace BC.Core.Data');
  Text('{');

  Text(Tab(1)+'[UseCore("'+aName+'")]');
  Text('');

  vTxtIndex # Textopen(20);
  // KEYS analysieren ---------------------------------------------------------------------
  RecBufClear(901);
  Prg.Key.File # aDatei;
  FOR vErg # RecRead(901,1,0)
  LOOP vErg # RecRead(901,1,_recNext)
  WHILE (verg<=_rNoKey) and (Prg.Key.File=aDatei) do begin

    vA # '';
    vJ # KeyInfo(aDatei, Prg.Key.Key, _KeyFldCount);
    FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
      vFld # KeyFldInfo(aDatei, Prg.Key.Key, vI,_KeyFldNumber);
      vTds # KeyFldInfo(aDatei, Prg.Key.Key, vI, _KeyFldSbrNumber);
      if (vA<>'') then vA # vA + ',';
      vName # FldName(aDatei, vTds, vFld);
      vB # Call('Test+SQL:C16toCSharp', vName, gNamePrefix);
      vA # vA + vB;
      // Key-Felder merken für Klasse:
      TextAddline(vTxtIndex,'|'+vB+':'+vName);
    END;

    Text(Tab(1)+'[Index("'+vA+'", "'+Lib_Strings:Strings_Dos2Win(Prg.Key.Name)+'")]');
  END;
  Text('');

  // COLUMN analysieren ---------------------------------------------------------------------
  Text(Tab(1)+'public partial class '+aName+'GridRow : DbRecord');
  Text(Tab(1)+'{');

  FOR  vObj # aObj->WinInfo( _winFirst );
  LOOP vObj # vObj->WinInfo( _winNext );
  WHILE ( vObj > 0 ) DO BEGIN
//debug( vPad + '[Obj] ' + vObj->wpName );
    if (vObj->WinInfo( _winType)<>_WinTypeListColumn) then CYCLE;
    if (vObj->wpVisible=false) then CYCLE;

    vA # vObj->wpDbFieldName;
    if (vA='') then CYCLE;

    case FldInfoByName(vA, _FldType) of
      _TypeAlpha  : begin
//        WriteLN(cTab+cTab+'[DbMaxLength('+cnvai(FldInfo(aDatei,vTds,vFld,_FldLen))+')]');
        vTyp # 'string';
        end;
      _typeWord   : vTyp # 'int';   // war int16
      _typeInt    : vTyp # 'int';
      _typeFloat  : vTyp # 'double'; // float??
      _typeLogic  : vTyp # 'bool';
      _typeDate   : vTyp # 'DateTime';
      _typeTime   : vTyp # 'DateTime';
      otherwise vTyp # 'ERROR';
    end;
    if (FldInfoByName(vA, _FldFileNumber)<>aDatei) then vA # 'KONVERT_FEHLER '+vA;

    Text(Tab(2)+'[IsStd]');
    vA # Call('Test+Sql:C16toCSharp', vA, gNamePrefix);
    if (vA<>vObj->wpcaption) then
      Text(Tab(2)+'[Caption("'+ Lib_Strings:Strings_Dos2Win(vObj->wpCaption, n)+'")]');

    // ist das ein Indexfeld?
    vI # TextSearch(vTxtIndex, 1, 1, 0, '|'+vA+':');
    if (vI<>0) then begin
      TextLineRead(vTxtIndex, vI, _TextLineDelete);
    end;

    if (StrFind(vTyp,'Anlage_Datum',1)>0) or(StrFind(vTyp,'Anlage_User',1)>0) or (StrFind(vTyp,'Anlage_Zeit',1)>0) then vTyp # 'KONVERT_FEHLER '+vTyp;
    Text(Tab(2)+'public virtual '+vTyp+' '+vA+' { get; set; }');

  END;

  // restliche Indexfelder aufnehmen...
  WHILE (TextInfo(vTxtIndex,_TextLines)>0) do begin
    vA # TextLineRead(vTxtIndex, 1, _TextLineDelete);
    vA # Lib_Strings:Strings_Token(vA,':',2);

    case FldInfoByName(vA, _FldType) of
      _TypeAlpha  : begin
        vTyp # 'string';
        end;
      _typeWord   : vTyp # 'int';   // war int16
      _typeInt    : vTyp # 'int';
      _typeFloat  : vTyp # 'double'; // float??
      _typeLogic  : vTyp # 'bool';
      _typeDate   : vTyp # 'DateTime';
      _typeTime   : vTyp # 'DateTime';
      otherwise vTyp # 'ERROR';
    end;
    if (FldInfoByName(vA, _FldFileNumber)<>aDatei) then vA # 'KONVERT_FEHLER '+vA;

    vA # Call('Test+Sql:C16toCSharp', vA, gNamePrefix);


    if (StrFind(vTyp,'Anlage_Datum',1)>0) or (StrFind(vTyp,'Anlage_User',1)>0) or (StrFind(vTyp,'Anlage_Zeit',1)>0) then vTyp # 'KONVERT_FEHLER '+vTyp;
    vB # Tab(2)+'public virtual '+vTyp+' '+vA+' { get; set; }';
    if (TextSearch(gBuf, 1, 1, _TextSearchCI, vB)<=0) then begin
      Text(Tab(2)+'[IsHidden]');
      Text(vB);
    end;
//      if (StrFind(vTyp,'Anlage_Datum',1)>0) or(StrFind(vTyp,'Anlage_User',1)>0) or (StrFind(vTyp,'Anlage_Zeit',1)>0) then vTyp # 'KONVERT_FEHLER '+vTyp;
//    Text(Tab(2)+'public virtual '+vTyp+' '+vA+' { get; set; }');
  END;

  TextClose(vTxtIndex);
  Text(Tab(1)+'}');

  Text('}');

  RETURN true;
end;


//========================================================================
//========================================================================
sub _ParsePageToBuf(
  aObj  : int;
  aBuf  : int);
local begin
  vObj    : int;
  vHdl    : int;
  vType   : int;
  vName   : alpha;
  vTxt    : int;
  vCount  : int;

  vBufFeld    : int;
  vBufLabel   : int;
  vBufBox     : int;
  vBufRest    : int;
  vI          : int;

  vDebug      : logic;
end;
begin

  vBufFeld    # TextOpen(20);
  vBufLabel   # TextOpen(20);
  vBufBox     # TextOpen(20);
  vBufRest    # TextOpen(20);

  vTxt # TextOpen(20);
  // alle Edit-Objekt-Namen holen
  FOR  vObj # aObj->WinInfo( _winFirst );
  LOOP vObj # vObj->WinInfo( _winNext );
  WHILE ( vObj > 0 ) DO BEGIN
/**
    if (vObj->wpAreaLeft=16) then begin
      vObj->wpAreaLeft # 0;
      vObj->wpAreaRight # vObj->wpAreaRight - 16;
    end;
    if (vObj->wpAreaLeft=8) then begin
      vObj->wpAreaLeft # 0;
      vObj->wpAreaRight # vObj->wpAreaRight - 8;
    end;
**/
    vType # vObj->WinInfo( _winType );
    case (vType) of
      _WinTypeEdit, _WinTypeIntEdit, _wintypefloatedit, _WinTypeDateEdit, _WinTypeTimeEdit : begin
        TextAddLine(vTxt, '|'+vObj->wpName+'|');
      end;
    end;
  END;


  // alles durchlaufen....
  FOR  vObj # aObj->WinInfo( _winFirst );
  LOOP vObj # vObj->WinInfo( _winNext );
  WHILE ( vObj > 0 ) and (vCount<=21230) DO BEGIN

    vName # StrCnv(vObj->wpname,_Strupper);

    case (vName) of
      'JUMP'      : CYCLE;
      'DUMMYNEW'  : CYCLE;
    end;

    inc(vCount);

    vType # vObj->WinInfo( _winType );
/**
case (vObj->wpname) of
  'lbMat.Warengruppe', 'edMat.Warengruppe', 'bt.Warengruppe', 'Lb.Warengruppe',
  'lbMat.Chargennummer', 'edMat.Chargennummer',
  'lbMat.Werksnummer', 'edMat.Werksnummer',
  'lbMat.Intrastatnr', 'edMat.Intrastatnr', 'bt.Intrastat',
  'lbMat.Dicke', 'edMat.Dicke', 'edMat.DickenTol', 'edMat.Dicke.Von', 'edMat.Dicke.Bis',
  'lbMat.Bemerkung1', 'edMat.Bemerkung1', 'edMat.Bemerkung2'
   : begin end;
  otherwise CYCLE;
end;
**/

/**
if (vType=_WinTypeEdit) or (vType=_WinTypeIntEdit) or  (vType=_WinTypeDateEdit) or (vType=_WinTypeFloatEdit) or (vType=_WinTypeLabel) or (vType=_WinTypeCheckbox) then begin
  vDebug # (vObj->wpname='Lb.Mat.Warengruppe2') or
            (vObj->wpname='edMat.Guete') or (vObj->wpname='edMat.Guetenstufe') or
            (vObj->wpname='edMat.Warengruppe');
  vDebug # (vObj->wpname='edMat.Status');
  vDebug # (vObj->wpname='edMat.Bemerkung1') or (vObj->wpname='edMat.Bemerkung2');
end;
**/

if (vDebug) then
debug(vObj->wpname+' ----------');


    case (vType) of

      //<Line Canvas.Top="53" Canvas.Left="20" X1="0" Y1="0" X2="1000" Y2="0" Stroke="Black" StrokeThickness="0.5"/>
      _WinTypeDivider : begin
        gBuf # vBufRest;
        if (vObj->wpShapeType=_WinShapeLine3dVer) or (vObj->wpShapeType=_WinShapeLineVer) then begin
          Open(vObj, Tab(4)+'<Line Stroke="Gray"', y)
          AddY2();
          AddPos();
        end
        else begin
          Open(vObj, Tab(4)+'<Line Stroke="Gray"', y);
          AddX2();
          AddPos(0, 5);
        end;
        Close();
      end;


      _WinTypeLabel : begin

        gBuf # vBufBox;
        // Infofeld?
        if (vObj->wpStyleBorder=_WinBorSunken) then begin
          //Open(vObj, Tab(4)+'<TextBox Text="1234" IsReadOnly="True" Background="#dddddd"', y);
          Open(vObj, Tab(4)+'<compo:InfoFeld Name="'+_Label(vObj->wpName)+'" Value="'+vObj->wpCaption+'"', y);
          if (vObj->wpJustifyVert=_WinJustLeft) then
            gZeile # gZeile + ' Alignment="Left"'
//          AddHAlignment();
//          AddBold();
          AddWidth(0,vDebug);
          AddPos(0,0,vDebug);
          Close();
          CYCLE;
        end;

        // Feldtitel??
        if (vObj->wpObjLink<>'') then begin
          if (TextSearch(vTxt, 1, 1, _TextSearchCI, '|'+vObj->wpObjLink+'|')>0) then CYCLE;
        end;

        gBuf # vBufLabel;
        Open(vObj, Tab(4)+'<compo:LabelFeld', y);
        AddContent();
        AddHAlignment();
        AddBold();
        AddWidth(8);
        AddPos();
        Close();
      end;  // LABEL


    //	<compo:AuswahlFeld Label="Warengruppe" IsAuswahl="True" FormatType="Integer" IsMadatory="True" Content="{Binding Dicke, Mode=TwoWay}" Width="180"/>
      _WinTypeEdit : begin
        gBuf # vBufFeld;
        Open(vObj, Tab(4)+'<compo:StringFeld');
        FindLabel(aObj);
        AddAuswahl();
        AddWidth(0, vDebug);
        AddPos(0,0,vDebug);
        Close();
      end;


      _WinTypeIntEdit : begin
        gBuf # vBufFeld;
        Open(vObj, Tab(4)+'<compo:IntegerFeld')
        if ((vObj->wpFmtIntFlags & _FmtNumnoZero)=0) then begin
          gZeile # gZeile + ' FormatType="IntegerShowZero"';
        end;
        FindLabel(aObj);
        AddAuswahl();   // ggf. W+24
        AddWidth(0, vDebug);
        AddPos(0, 0, vDebug);
        Close();
      end;


      _WinTypeFloatEdit : begin
        gBuf # vBufFeld;
        Open(vObj, Tab(4)+'<compo:DoubleFeld');
        case vObj->wpDecimals of
          0 : gZeile # gZeile + ' FormatType="Double0';
          1 : gZeile # gZeile + ' FormatType="Double1';
          2 : gZeile # gZeile + ' FormatType="Double2';
          3 : gZeile # gZeile + ' FormatType="Double3';
          4 : gZeile # gZeile + ' FormatType="Double4';
          5 : gZeile # gZeile + ' FormatType="Double5';
        end;
        if (vObj->wpDecimals>=0) and (vObj->wpDecimals<=5) and
          ((vObj->wpFmtFloatFlags & _FmtNumnoZero)=0) then
          gZeile # gZeile + 'SZ"'
        else
          gZeile # gZeile + '"';
        FindLabel(aObj);
        AddAuswahl();
        AddWidth();
        AddPos();
        Close();
      end;


      _WinTypeDateEdit : begin
        gBuf # vBufFeld;
        Open(vObj, Tab(4)+'<compo:DateFeld');
        FindLabel(aObj);
        AddAuswahl();
        AddWidth();
        AddPos();
        Close();
      end;

      _WinTypeTimeEdit : begin
        gBuf # vBufFeld;
        Open(vObj, Tab(4)+'<compo:TimeFeld');
        FindLabel(aObj);
        AddAuswahl();
        AddWidth();
        AddPos();
        Close();
      end;

      _WinTypeCheckbox : begin
        gBuf # vBufFeld;
        Open(vObj, Tab(4)+'<compo:BooleanFeld');
        FindLabel(aObj);
        if (vObj->wpcaption<>'') then begin
          AddFeldInFront();
          end
        else begin
//          AddAuswahl();
          vObj->wparearight # vObj->wparealeft + 16;
        end;
        AddWidth();
        AddPos();
        Close();
      end;

    end;

//    _ParsePage(vObj);
  END; // Objekte

  TextClose(vTxt);

  _CopyBuf(vBufFeld, aBuf,  '<!-- Felder -->');
  _CopyBuf(vBufLabel, aBuf, '<!-- Labels -->');
  _CopyBuf(vBufBox, aBuf,   '<!-- Info -->');
  _CopyBuf(vBufRest, aBuf,  '<!-- Rest -->');

  vBufFeld->TextClose();
  vBufLabel->TextClose();
  vBufBox->TextClose();
  vBufRest->TextClose();
end;


//========================================================================
//========================================================================
sub _ParseNotebookToBuf(
  aObj  : int;
  aBuf  : int )
local begin
  vObj  : int;
  vType : int;
  vName : alpha;
end;
begin
  gBuf # aBuf;

  gPad # gPad + ' ';

  FOR  vObj # aObj->WinInfo( _winFirst );
  LOOP vObj # vObj->WinInfo( _winNext );
  WHILE ( vObj > 0 ) DO BEGIN
//debug( vPad + '[Obj] ' + vObj->wpName );
    vType # vObj->WinInfo( _winType );
    if (vType<>_WinTypeNotebookPage) then CYCLE;

    vName # vObj->wpname;
    if (vName='NB.List') then CYCLE;

    if (StrCut(vName,1,3)='NB.') then vName # StrCut(vName, 4, 100);
    Text(Tab(2)+'<TabItem Name="'+vName+'">');// Header="'+vObj->wpCaption+'>');//" FontSize="15" FontFamily="Segoe UI">');

    Text(Tab(3)+'<TabItem.Header>');
    Text(Tab(4)+'<TextBlock Text="'+vObj->wpCaption+'" FontSize="16"/>');
    Text(Tab(3)+'</TabItem.Header>');
	  Text(Tab(3)+'<Canvas>');

    _ParsePageToBuf(vObj, aBuf);

    gBuf # aBuf;
	  Text(Tab(3)+'</Canvas>');
		Text(Tab(2)+'</TabItem>');

  END;

  gPad # StrCut( gPad, 0, StrLen( gPad ) - 1 );
end;


//========================================================================
//
//
//========================================================================
sub _ParseDialogToBuf(
  aObj  : int;
  aBuf  : int ) : logic;
local begin
  vObj  : int;
end;
begin
  gPad # gPad + ' ';

  FOR  vObj # aObj->WinInfo( _winFirst );
  LOOP vObj # vObj->WinInfo( _winNext );
  WHILE ( vObj > 0 ) DO BEGIN
//debug( gPad + '[Obj] ' + vObj->wpName );

    if (vObj->wpname='NB.List') then CYCLE;

    _ParseNoteBookToBuf(vObj, aBuf);

    _ParseDialogToBuf(vObj, aBuf);
  END;

  gPad # StrCut( gPad, 0, StrLen( gPad ) - 1 );

  RETURN true;
end;


//========================================================================
//========================================================================
sub AnalysePrimeKey(
  aDatei  : int;
  aPrefix : alpha;
  var aP1 : alpha;
  var aP2 : alpha;
  var aP3 : alpha);
local begin
  vA,vB   : alpha;
  vI, vJ  : int;
  vFld    : int;
  vTds    : int;
  vTyp    : alpha;
end;
begin

  aP1 # '';
  aP2 # '';
  aP3 # '';

  // PRIMARY KEY ***************************************************
  vA # '';
  vJ # KeyInfo(aDatei, 1, _KeyFldCount);
  FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
    vFld # KeyFldInfo(aDatei,1,vI,_KeyFldNumber);
    vTds # KeyFldInfo(aDatei,1, vI, _KeyFldSbrNumber);

    case FldInfo(aDatei,vTds,vFld,_FldType) of
      _TypeAlpha  : vTyp # 'string';
      _typeWord   : vTyp # 'int';   // war int16
      _typeInt    : vTyp # 'int';
      _typeFloat  : vTyp # 'double'; // float??
      _typeLogic  : vTyp # 'bool';
      _typeDate   : vTyp # 'DateTime';
      _typeTime   : vTyp # 'DateTime';
      otherwise vTyp # 'ERROR';
    end;

    vA # FldName(aDatei, vTds, vFld);
    vA # Call('Test+SQL:C16toCSharp',vA, aPrefix);

    if (aP1<>'') then aP1 # aP1 + StrChar(13)+StrChar(10);
    if (aP2<>'') then aP2 # aP2 + ', ';
    if (aP3<>'') then aP3 # aP3 + ', ';

    aP1 # aP1 + Tab(2)+'/// <param name="a'+vA+'"></param>';
    aP2 # aP2 + vTyp+' a'+vA;
    aP3 # aP3 + 'a'+vA;
  END;


end;


//========================================================================
//
//
//========================================================================
sub DoIt()
local begin
  vBuf    : int;

  vDlg    : int;
  vHdl    : int;
  vStoDir : int;
  vStoObj : alpha;
  vList   : int;
  vConfig : int;
  vI,vJ   : int;
  vA      : alpha(4000);
  vDatei  : int;
  vPrefix : alpha;
  vName   : alpha;

  vTemplate   : int;
  vNameSpace  : alpha;
  vP1,vP2,vP3 : alpha(1000);
end;
begin

  Lib_FileIO:EmptyDir(cPath+'\Core\Data', true);    // BLOs
  Lib_FileIO:EmptyDir(cPath+'\Server\BusinessLogic\BOC', true);
  Lib_FileIO:EmptyDir(cPath+'\Server\Services_SC', true);
  Lib_FileIO:EmptyDir(cPath+'\Client\ViewModels', true);
  Lib_FileIO:EmptyDir(cPath+'\Client\Views', true);

  Lib_FileIO:CreateFullpath(cPath+'\Core\Data');
  Lib_FileIO:CreateFullPath(cPath+'\Server\BusinessLogic\BOC');
  Lib_FileIO:CreateFullPath(cPath+'\Server\Services_SC');
  Lib_FileIO:CreateFullPath(cPath+'\Client\ViewModels');
  Lib_FileIO:CreateFullPath(cPath+'\Client\Views');


  vBuf    # TextOpen(20);
  vConfig # Call('Test+Sql:LoadConfig');

  WinEvtProcessSet(_WinEvtAll, false);

  // Translations: Dialog **********************************************************
  vStoDir # StoDirOpen( 0, 'Dialog' );
  FOR  vStoObj # vStoDir->StoDirRead( _stoFirst );
  LOOP vStoObj # vStoDir->StoDirRead( _stoNext, vStoObj );
  WHILE ( vStoObj != '' ) DO BEGIN

    if ( StrCut( vStoObj, 0, 8 ) = 'AppFrame' ) or ( StrCut( vStoObj, 0, 4 ) = 'Math' ) or
       ( StrCut( vStoObj, 0, 6 ) = 'AF_Frm' ) or ( StrCut( vStoObj, 0, 12 ) = Lib_GuiCom:GetAlternativeName('Mdi.Tastatur')) then begin
//debug( '[Dialog|Skip] ' + vStoObj );
      CYCLE;
    end;


//if (vStoObj<>'ZaB.Verwaltung') then CYCLE;
if (vStoObj<>'BA1.Verwaltung') then CYCLE;
//if (vStoObj<>'Mat.A.Verwaltung') then CYCLE;

if (vStoObj='Mat.Rohr.Verwaltung') then CYCLE;

if (StrFind(vStoObj,'_BAK',1)<>0) then CYCLE;
if (StrFind(vStoObj,'Verwaltung',1)=0) then CYCLE;
//if (vStoObj<>'MSt.Verwaltung') and (vStoObj<>'Wgr.Verwaltung') then CYCLE;
//if (StrCut(vStoObj,1,3)>'Adz') then CYCLE;
//if (vStoObj='Lnd.Verwaltung') then CYCLE;   // LAND ist PROTOTYP und NICHT erstellbar


    vDlg # WinOpen( vStoObj, _winOpenDialog );
    if ( vDlg = 0 ) then begin
      vDlg # WinOpen( vStoObj );
      if ( vDlg = 0 ) then begin
//debug( '[Dialog|Skip] ' + vStoObj );
        CYCLE;
      end;
    end;

//debug( '[Dialog|Open ' + vStoObj + ' (' + CnvAI( vDlg ) + ')' );
    gProc # WinEvtProcNameGet(vDlg, _WinEvtInit);
    if (gProc<>'') then gProc # Lib_Strings:Strings_Token(gProc,':',1);

    gNamePrefix # '';
    gNameFile   # 0;
    vNameSpace  # '';

    // Dateinummer rekonstruieren...
    vList # Winsearch(vDlg, 'NB.List');
    if (vList<>0) then begin
      vList # Wininfo(vList, _Winfirst, 0, _WinTypeRecList);

      if (vList<>0) then begin
        if (vList->wpDbLinkFileNo<>0) then gNameFile # vList->wpDbLinkFileno
        else if (vList->wpDbFileNo<>0) then gNameFile # vList->wpDbFileno;

        // Namensprefix rekonstruieren...
        if (gNameFile<>0) then begin
          FOR vI # 1 loop inc(vI) while (vI<=TextInfo(vConfig,_TextLines)) do begin
            vA # StrAdj( TextLineRead(vConfig, vI, 0) , _StrBegin|_StrEnd);
            if (vA='') then CYCLE;
            if (StrCut(vA,1,2)='//') then CYCLE;
            if (vA='QUIT') then BREAK;

            Call('Test+SQL:TokenLine',vA, var vDatei, var vName, var vPrefix);
//Lib_debug:Dbg_Debug(vA+' : '+cnvai(vDatei)+' ' +vName+' ' +vPRefix);
            if (vDatei=gNameFile) then begin
              gNamePrefix # vPrefix;
              gName       # vName;

              // Namespace finden...
              FOR vJ # vI loop dec(vJ) while (vJ>0) do begin
                vA # StrAdj( TextLineRead(vConfig, vJ, 0) , _StrBegin|_StrEnd);
                if (StrCut(vA,1,10)='Namespace:') then begin
                  vNamespace # StrCut(vA, 11,100)+'';
                  BREAK;
                end;
              END;
              BREAK;
            end;
          END;

        end;

      end;
    end;

//if (gNameFile<847) or (gNameFile>849) then begin
//  vDlg->WinClose();
//  CYCLE;
//end;

if (vNameSpace='') then begin
  vDlg->WinClose();
  CYCLE;
end;
debug( '[PARSE] ' + vStoObj );


    // XAML ===================================================================================
    TextClear(vBuf);
    if (_ParseDialogToBuf(vDlg, vBuf)) then begin
      vTemplate # TextOpen(20);
      TextRead(vTemplate, 'Template.XAML',0);

      TextLineWrite(vTemplate, 1, StrChar(0xef)+StrChar(0xbb)+StrChar(0xbf), _TextLineInsert);    // AUF UTF8 CODIEREN
      TextLineWrite(vTemplate, 2, '<!-- autogenerated by C16 on '+cnvad(Sysdate())+' -->', _TextLineInsert);
//      TextLineWrite(vTemplate, 3, Lib_Strings:Strings_Dos2XML('²²² ³³³'), _TextLineInsert);
//TextWrite(vBuf, '', _TextClipBoard);
      // Namen eintragen
      vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###NAME###', gName)
      vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###TABCONTROL###');
      if (vI<>0) then begin
        TextLineRead(vTemplate, vI, _TextLineDelete);
        FOR vJ # 1
        LOOP inc(vJ)
        WHILE (vJ<=TextInfo(vBuf, _TextLines)) do begin
          vA # TextLineRead(vBuf, vJ, 0);
          if (TextInfo(vBuf,_TextNoLineFeed)=1) then begin  // SOFT?
            TextLineWrite(vTemplate, vI + vJ - 1, vA, _TextLineInsert | _TextNoLineFeed);
          end
          else begin
            TextLineWrite(vTemplate, vI + vJ - 1, vA, _TextLineInsert);
          end;
        END;
      end;
//TextWrite(vTemplate, '', _TextClipBoard);

      if (vNameSpace<>'') then FsiPathCreate(cPath+'\Client\Views\'+vNameSpace);
      TextWrite(vTemplate, cPath+'\Client\Views\'+vNameSpace+'\'+gName+'.xaml', _TextExtern);

      TextRead(vTemplate, 'Template.XAML.cs',0);
      TextLineWrite(vTemplate, 1, '// autogenerated by C16 on '+cnvad(Sysdate()), _TextLineInsert);
      // Namen eintragen
      vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###NAME###', gName)
      TextWrite(vTemplate, cPath+'\Client\Views\'+vNameSpace+'\'+gName+'.xaml.cs', _TextExtern);

      vTemplate->TextClose();
    end;


    // GRIDROW ================================================================================
    TextClear(vBuf);
    if (_ParseList(vList, gNameFile, gName)) then begin
      TextLineWrite(vBuf, 1, '// autogenerated by C16 on '+cnvad(Sysdate()), _TextLineInsert);
      if (vNameSpace<>'') then begin
        FsiPathCreate(cPath+'\Core\Data\'+vNameSpace);   // BLOs
      end;
      TextWrite(vBuf, cPath+'\Core\Data\'+vNameSpace+'\'+gName+'GridRow.cs', _TextExtern);  // BLOs
    end;


    // VIEWMODEL ==============================================================================
    vTemplate # TextOpen(20);
    TextRead(vTemplate, 'Template.VM',0);
    TextLineWrite(vTemplate, 1, '// autogenerated by C16 on '+cnvad(Sysdate()), _TextLineInsert);
    // Namen eintragen
    vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###NAME###', gName)
    if (vNameSpace<>'') then FsiPathCreate(cPath+'\Client\ViewModels\'+vNameSpace);
    TextWrite(vTemplate, cPath+'\Client\ViewModels\'+vNameSpace+'\'+gName+'.cs', _TextExtern);
    vTemplate->TextClose();


    // BOC ====================================================================================
    vTemplate # TextOpen(20);
    TextRead(vTemplate, 'Template.BOC',0);
    TextLineWrite(vTemplate, 1, '// autogenerated by C16 on '+cnvad(Sysdate()), _TextLineInsert);
    // Namen eintragen
    vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###NAME###', gName)
    if (vNameSpace<>'') then FsiPathCreate(cPath+'\Server\BusinessLogic\BOC\'+vNameSpace);
    TextWrite(vTemplate, cPath+'\Server\BusinessLogic\BOC\'+vNameSpace+'\'+gName+'.cs', _TextExtern);
    vTemplate->TextClose();


    // SERVICE ================================================================================
    vTemplate # TextOpen(20);
    TextRead(vTemplate, 'Template.SVC',0);
    TextLineWrite(vTemplate, 1, '// autogenerated by C16 on '+cnvad(Sysdate()), _TextLineInsert);
    // Namen eintragen
    vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###NAME###', gName)
    if (vNameSpace<>'') then FsiPathCreate(cPath+'\Server\Services_SC\'+vNameSpace);
    TextWrite(vTemplate, cPath+'\Server\Services_SC\'+vNameSpace+'\'+gName+'GridRow.cs', _TextExtern);

    AnalysePrimeKey(gNameFile, gNamePrefix, var vP1, var vP2, var vP3);

    TextRead(vTemplate, 'Template.SVC2',0);
    TextLineWrite(vTemplate, 1, '// autogenerated by C16 on '+cnvad(Sysdate()), _TextLineInsert);
    // Namen eintragen
    vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###PARAMS1###', vP1)
    vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###PARAMS2###', vP2)
    vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###PARAMS3###', vP3)
    vI # TextSearch(vTemplate, 1, 1, _TextSearchCI, '###NAME###', gName)
    if (vNameSpace<>'') then FsiPathCreate(cPath+'\Server\Services_SC\'+vNameSpace);
    TextWrite(vTemplate, cPath+'\Server\Services_SC\'+vNameSpace+'\'+gName+'.cs', _TextExtern);
    vTemplate->TextClose();



//debug( '[Dialog|Closing] ' + vStoObj );
    vDlg->WinClose();

  END;    // DIALOGE loopen...
  vStoDir->StoClose();


  WinEvtProcessSet(_WinEvtAll, true);

  vBuf->TextClose();
  vCOnfig->textClose();

end;


//========================================================================
//========================================================================
main
begin

  lib_debug:initdebug();

  DoIT();

  lib_debug:Termdebug();

end;

//  1. Run
//  2. Paste in XAML
//  3. CO, BO, IService
//  4.

//========================================================================