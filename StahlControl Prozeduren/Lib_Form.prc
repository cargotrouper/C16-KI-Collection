@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Form
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

//=========================================================================
//=========================================================================
sub FreeElement(var aHdl  : int) : logic;
begin
  if (aHdl=0) then RETURN true;

  Lib_PrintLine:Destroy(aHdl)

  aHdl # 0;
  RETURN true;
end;


//=======================================================================
//=======================================================================
sub AddOptA(
  aText     : alpha(4096);
  var aA    : alpha;
  aPre  : alpha;
  aPost : alpha) : logic
begin
  if (aText='') then RETURN false;
  aA # aA + aPre + aText + aPost + StrChar(10);
  RETURN true;
end;
//=======================================================================
//=======================================================================
sub AddOptD(
  aDat      : date;
  var aA    : alpha;
  aPre  : alpha;
  aPost : alpha) : logic
begin
  if (aDat=0.0.0) then RETURN false;
  aA # aA + aPre + Cnvad(aDat,_FmtDateLongYear) + aPost + StrChar(10);
  RETURN true;
end;
//=======================================================================
//=======================================================================
sub AddOptI(
  aI        : int;
  var aA    : alpha;
  aPre  : alpha;
  aPost : alpha) : logic
begin
  if (aI=0) then RETURN false;
  aA # aA + aPre + Cnvai(aI,_FmtNumnogroup) + aPost + StrChar(10);
  RETURN true;
end;
//=======================================================================
//=======================================================================
sub AddOptF(
  aF        : float;
  aDec      : int;
  var aA    : alpha;
  aPre  : alpha;
  aPost : alpha) : logic
begin
  if (aF=0.0) then RETURN false;
  aA # aA + aPre + anum(aF, aDec) + aPost + StrChar(10);
  RETURN true;
end;


//=======================================================================
//=======================================================================
sub UnLoadStyleDef() : logic;
begin
  if (form_StyleDef=0) then RETURN true;

  PrtFormClose(Form_StyleDef);
  Form_StyleDef # 0;
end;


//=======================================================================
//=======================================================================
sub UnLoadSubStyleDef() : logic;
begin
  if (form_StyleDef2=0) then RETURN true;

  PrtFormClose(Form_StyleDef2);
  Form_StyleDef2 # 0;
end;


//=======================================================================
//=======================================================================
sub IsVisible(aName : alpha) : logic;
local begin
  vObj  : int;
  vTyp  : int;
end;
begin

  // kein Style geladen?
  if (Form_styleDef=0) then RETURN false;
  vObj # Prtsearch(Form_StyleDef, aName);

  // Substyle?
  if (vObj=0) and (Form_styleDef2<>0) then begin
    vObj # Prtsearch(Form_StyleDef2, aName);
  end;

  // keinen Style mit diesem Namen gefunden?
  if (vObj=0) then begin
//todo('style missing:'+aName);
    RETURN false;
  end;

  // invisible?
  RETURN (vObj->ppVisiblePrint & _PrtVisiblePrintJob)<>0;
end;


//=======================================================================
//=======================================================================
sub LoadStyleDef(aName : alpha) : logic;
begin

  // alten Style löschen?
  if (form_styleDef<>0) then
    UnloadStyleDef();

  // Vorlage öffnen
  Form_StyleDef # PrtFormOpen(_PrtTypePrintForm, aName);

  RETURN true;
end;


//=======================================================================
//=======================================================================
sub LoadSubStyleDef(aName : alpha) : logic;
begin

  // alten Style löschen?
  if (form_styleDef2<>0) then
    UnloadSubStyleDef();

  // Vorlage öffnen
  Form_StyleDef2 # PrtFormOpen(_PrtTypePrintForm, aName);

  RETURN true;
end;


//=======================================================================
//=======================================================================
sub UseStyle(aName : alpha) : logic;
local begin
  vObj  : int;
  vA    : alpha(4096);
  vTyp  : int;
end;
begin

  // kein Style geladen?
  if (Form_styleDef=0) then RETURN true;

  vObj # Prtsearch(Form_StyleDef, aName);

  // Substyle?
  if (vObj=0) and (Form_styleDef2<>0) then begin
    vObj # Prtsearch(Form_StyleDef2, aName);
  end;

  // keinen Style mit diesem Namen gefunden?
  if (vObj=0) then begin
todo('style missing:'+aName);
    RETURN true;
  end;

  // invisible?
  if ((vObj->ppVisiblePrint & _PrtVisiblePrintJob)=0) then RETURN false;

  vTyp # Prtinfo(vObj,_Wintype);

  if (vTyp=_prtTypePrtText) then begin
    Form_StyleFont  # vObj->ppFont;
    Form_StyleJustX # vObj->ppJustify;
    Form_StyleBkg   # vObj->ppColBkg;
    Form_StyleCol   # vObj->ppColFg;
    if (Form_styleBkg=_WinColParent) then
      Form_StyleBkg   # _WinColTransparent;
    Form_StyleWordBreak  # vObj->ppWordBreak;
  end;

  Form_StyleX   # vObj->ppArealeft;
  Form_StyleXX  # vObj->ppArearight;
  Form_StyleY   # vObj->ppAreaTop;
  Form_StyleYY  # vObj->ppAreaBottom;
//    Form_StyleInv  # False;

  RETURN true;
end;


//=======================================================================
//=======================================================================
sub GetCaption(
  aName       : alpha) : alpha;
local begin
  vObj  : int;
  vInv  : logic;
  vA    : alpha(4096);
  vTyp  : int;
end;
begin

  // kein Style geladen?
  if (Form_styleDef=0) then RETURN '';

  vObj # Prtsearch(Form_StyleDef, aName);

  // Substyle?
  if (vObj=0) and (Form_styleDef2<>0) then begin
    vObj # Prtsearch(Form_StyleDef2, aName);
  end;

  // keinen Style mit diesem Namen gefunden?
  if (vObj=0) then begin
todo('style missing:'+aName);
    RETURN '';
  end;

  if ((vObj->ppVisiblePrint & _PrtVisiblePrintJob)=0) then RETURN '';

  RETURN vObj->ppCaption;
end;


//=======================================================================
//=======================================================================
sub GetObj(
  aName       : alpha) : int;
local begin
  vObj  : int;
  vInv  : logic;
  vA    : alpha(4096);
  vTyp  : int;
end;
begin

  // kein Style geladen?
  if (Form_styleDef=0) then RETURN 0;

  vObj # Prtsearch(Form_StyleDef, aName);

  // Substyle?
  if (vObj=0) and (Form_styleDef2<>0) then begin
    vObj # Prtsearch(Form_StyleDef2, aName);
  end;

  // keinen Style mit diesem Namen gefunden?
  if (vObj=0) then begin
todo('style missing:'+aName);
    RETURN 0;
  end;

  if ((vObj->ppVisiblePrint & _PrtVisiblePrintJob)=0) then RETURN 0;

  RETURN vObj;
end;


//=======================================================================
//=======================================================================
Sub StartPrint(aHdl : int) : logic;
begin
  VarInstance(class_PrintLine, aHdl);;
  if ("Set.Druck.Zeilenhöhe"<>0.0) then
    if (pls_current=1) then begin
      Lib_Printline2:print(' ',0,0);
      RETURN true;
  end;

  RETURN false;
end;


//=======================================================================
//=======================================================================
sub PrintText(
  aName       : alpha(4096);
  opt aLang   : int;
  opt aX      : int;
  opt aXX     : int);
local begin
//  vHdl  : int;
end;
begin
  if (aX=0)   then aX   # form_StyleX;
  if (aXX=0)  then aXX  # form_StyleXX;
  pls_FontName  # Form_StyleFont:Name;
  pls_FontSize  # Form_StyleFont:Size / 10;
  pls_FontAttr  # Form_StyleFont:Attributes;
  Lib_Print:Print_Text(aName, aLang, 0.0, 0.0, aX, aXX);
end;


//=======================================================================
//=======================================================================
SUB FillDynA(
  aName : alpha;
  aText : alpha(4096));
local begin
  vTmp  : int;
  vFont : font;
  vAlt : logic;
  vNeu : logic;
end;
begin
  vTmp # PrtSearch( pls_Prt, aName);

  if (vTmp<>0) then begin

    // BOLD?
    vNeu # strFind(aText,'<b>',1)>0;
    vAlt # StrFind(vTmp->ppHelptip,'<b>',1)>0;
    if (vNeu=vAlt) then begin
      end
    else if (vAlt) and (vNeu=false) then begin
      vFont # vTmp->ppFont;
      vFont:Attributes # 0;
      vTmp->ppFont # vFont;
      vTmp->ppHelptip # Str_ReplaceAll(vTmp->ppHelpTip, '<b>', '');
      end
    else begin
      vFont # vTmp->ppFont;
      vFont:Attributes # _WinFontAttrB
      //else vFont:Attributes # 0;
      vTmp->ppFont # vFont;
      vTmp->ppHelptip # vTmp->ppHelptip + '<b>';
    end;
    if (vNeu) then
      aText # Str_ReplaceAll(aText, '<b>', '');
//      aText # StrCut(aText, 4, 4096);// StrLen(aText)-2);

    // LEFT?
    vNeu # strFind(aText,'<l>',1)>0;
    vAlt # StrFind(vTmp->ppHelptip,'<l>',1)>0;
    if (vNeu=vAlt) then begin
      end
    else if (vAlt) and (vNeu=false) then begin
      vTmp->ppJustify # _WinJustright;
      vTmp->ppHelptip # Str_ReplaceAll(vTmp->ppHelpTip, '<l>', '');
      end
    else begin
      vTmp->ppJustify # _WinJustleft;
      vTmp->ppHelptip # vTmp->ppHelptip + '<l>';
    end;
    if (vNeu) then
      aText # Str_ReplaceAll(aText, '<l>', '');

    // RIGHT?
    vNeu # strFind(aText,'<r>',1)>0;
    vAlt # StrFind(vTmp->ppHelptip,'<r>',1)>0;
    if (vNeu=vAlt) then begin
      end
    else if (vAlt) and (vNeu=false) then begin
      vTmp->ppJustify # _WinJustleft;
      vTmp->ppHelptip # Str_ReplaceAll(vTmp->ppHelpTip, '<r>', '');
      end
    else begin
      vTmp->ppJustify # _WinJustright;
      vTmp->ppHelptip # vTmp->ppHelptip + '<r>';
    end;
    if (vNeu) then
      aText # Str_ReplaceAll(aText, '<r>', '');


    vTmp->ppCaption # aText;
    // AUTOSIZE der Höhe:
    pls_prt->ppFormHeight # 1;
    end

  else
    todo('dynLabel missing :'+aName);

end;


//=======================================================================
//=======================================================================
SUB SetA(
  aName     : alpha(4000);
  opt aX    : int;
  opt aXX   : int;
  opt aY    : int);
begin
  if (aY=0) then aY # Pls_PosY;

  // BOLD?
  if (strFind(aName,'<b>',1)>0) then begin
    Form_StyleFont:Attributes # _WinFontAttrB;
    aName # Str_ReplaceAll(aName, '<b>', '');
  end;

  // LEFT?
  if (strFind(aName,'<l>',1)>0) then begin
    form_styleJustX # _WinJustleft;
    aName # Str_ReplaceAll(aName, '<l>', '');
  end;

  // RIGHT?
  if (strFind(aName,'<r>',1)>0) then begin
    form_styleJustX # _WinJustright;
    aName # Str_ReplaceAll(aName, '<r>', '');
  end;

  pls_TmpPosY # Max(Lib_PrintLine2:Print(aName, aX, aXX, aY), pls_TmpPosY);
end;


//=======================================================================
//=======================================================================
SUB DynA(
  aName     : alpha;
  opt aX    : int;
  opt aXX   : int;
  opt aY    : int);
begin
  if (aY=0) then aY # Pls_PosY;
  pls_Hdl->ppName # aName;

//debug('--------- DYNA --------' +  aName);
//debugx('vorher  aY = ' + Aint(aY) + ' / Pls_TmpPosY = '  + aint(Pls_TmpPosY));
  pls_TmpPosY # Max(Lib_PrintLine2:Print(' ', aX, aXX, aY), Pls_TmpPosY);
//debugx('nachher aY = ' + Aint(aY)+ ' / Pls_TmpPosY = '  + aint(Pls_TmpPosY));
end;


//=======================================================================
//=======================================================================
SUB DynBarcode(
  aName     : alpha;
  opt aX    : int;
  opt aXX   : int;
  opt aY    : int);
local begin
  vHdl  : int;
end;
begin
  if (aY=0) then aY # Pls_PosY;
  vHdl # PrtSearch(pls_Prt, 'PrtBarcode0');
  if (vHdl=0) then RETURN;

//debug('dyn BC '+aint(vHdl));
//aX # PrtUnitLog(110.0, _PrtUnitMillimetres);
//aXX # PrtUnitLog(160.0, _PrtUnitMillimetres);

//  pls_TmpPosY # Max(Lib_PrintLine2:Barcode_C39_Style(vHdl, '123', aX, aXX, aY), Pls_TmpPosY);
  pls_TmpPosY # Max(Lib_PrintLine2:Barcode_C39_Style(' ', aX, aXX, aY), Pls_TmpPosY);

  vHdl->ppName # aName;
//  vHdl->ppTypeBarCode # _WinBarcode39;

end;


//=======================================================================
//=======================================================================
SUB FillDynBarcode(
  aName     : alpha;
  aCode     : alpha);
local begin
  vHdl  : int;
end;
begin
//acode # '744';
//debug(aCode+' '+aint(strlen(aCode)));
  vHdl # PrtSearch( pls_Prt, aName);
  if (vHdl<>0) then begin
//    vHdl->ppTypeBarcode   # _WinBarcode39;
    vHdl->ppcaption # aCode;
//    vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;

//debug('set BC '+aint(vHdl)+' >'+aCode+'<');
  end;
end;


//=======================================================================
//=======================================================================
SUB VarA(
  aName       : alpha(1000);
  opt aField  : alpha(20);
  opt aX      : int;
  opt aXX     : int;
  opt aY      : int);
local begin
  vTmp        : int;
end;
begin
  if (aY=0) then aY # Pls_PosY;
  if (aField<>'') then begin
    pls_Hdl->ppDbFieldName # aField;
    end
  else begin
    // kein Style geladen?
    if (Form_styleDef=0) then RETURN;
    vTmp # Prtsearch(Form_StyleDef, aName);

    // Substyle?
    if (vTmp=0) and (Form_styleDef2<>0) then begin
      vTmp # Prtsearch(Form_StyleDef2, aName);
    end;

    if (vTmp=0) then RETURN;
    pls_Hdl->ppDbFieldName # vTmp->ppDbFieldName;
  end;

  pls_TmpPosY # Max(Lib_PrintLine2:Print(aName, aX, aXX, aY), pls_TmpPosY);
end;


//=======================================================================
//=======================================================================
SUB SetD(
  aDat      : Date;
  opt aX    : int;
  opt aXX   : int;
  opt aY    : int);
begin
  if (aY=0) then aY # Pls_PosY;
  if (aDat<>0.0.0) then
    pls_TmpPosY # Max(Lib_PrintLine2:Print(cnvad(aDat,_FmtDateLongYear), aX,aXX, aY), pls_TmpPosY)
  else
    pls_TmpPosY # Max(Lib_PrintLine2:Print(' ', aX,aXX, aY), pls_TmpPosY);
end;


//=======================================================================
//=======================================================================
SUB VarF(
  aVarName  : alpha;
  aDec      : int;
  opt aX    : int;
  opt aXX   : int;
  opt aY    : int);
begin
  if (aY=0) then aY # Pls_PosY;
  pls_Hdl->ppFmtPostComma  # aDec;
  pls_TmpPosY # Max(Lib_PrintLine2:Print(aVarName, aX, aXX, aY), pls_TmpPosY);
end;


//=======================================================================
//=======================================================================
SUB VarI(
  aVarName  : alpha;
  opt aX    : int;
  opt aXX   : int;
  opt aY    : int);
begin
  if (aY=0) then aY # Pls_PosY;
  pls_TmpPosY # Max(Lib_PrintLine2:Print(aVarName,aX,aXX, aY), pls_TmpPosY);
end;

//=======================================================================
//=======================================================================
//SUB DrawLine(aX : float; aXX : float; aY : float);

//=======================================================================
//=======================================================================
SUB SetBox(
  aX    : int;
  aXX   : int;
  aCol  : int;
  aH    : int);
begin
  Lib_PrintLine2:Drawbox(aX, aXX, aCol, aH);
end;

//=======================================================================
//=======================================================================
SUB SetPic(
  aX          : float;
  aXX         : float;
  aYY         : float;
  aName       : alpha;
  opt aRatio  : logic);
begin
  Lib_PrintLine2:PrintPic(aX, aXX, aYY, aName, aRatio);
end;

//=======================================================================
//=======================================================================
SUB SetPicAbsolut(
  aX          : float;
  aXX         : float;
  aY          : float;
  aYY         : float;
  aName       : alpha;
  opt aRatio  : logic);
begin
  Lib_PrintLine2:PrintPicAbsolut(aX, aXX, aY, aYY, aName, aRatio);
end;


//=======================================================================
//=======================================================================
SUB Barcode_C39(
  aData     : alpha;
  opt aX    : int;
  opt aXX   : int;
  opt aH    : int;
  opt aText : Logic);
local begin
  vTmp  : int;
end;
begin

  if (aX=0)   then aX   # form_StyleX;
  if (aXX=0)  then aXX  # form_StyleXX;
  if (aH=0)   then aH   # form_StyleYY - Form_StyleY;

  // kein Style geladen?
//  if (Form_styleDef=0) then RETURN;
//  vTmp # Prtsearch(Form_StyleDef, aName);

  // Substyle?
//  if (vTmp=0) and (Form_styleDef2<>0) then begin
//    vTmp # Prtsearch(Form_StyleDef2, aName);
//  end;

//  if (vTmp=0) then RETURN;
//  pls_Hdl->ppDbFieldName # vTmp->ppDbFieldName;
//  pls_TmpPosY # Max(Lib_PrintLine2:Print(aName, aX, aXX, aY), pls_TmpPosY);

  pls_TmpPosY # Max(pls_TmpPosY, Lib_PrintLine2:Barcode_C39(aData, aX, aXX,  aH, aText));

end;


//=======================================================================
//=======================================================================
SUB FillBarcode(
  aData     : alpha);
local begin
  vTmp  : int;
end;
begin

  vTmp # PrtSearch( pls_Prt, 'PrtBarcode0');
  if (vTmp<>0) then begin
    vtmp->wpcaption       # aData;
  end;

end;


//SUB PrintPageCount(aX : float; optaZeile : int);
//SUB Barcode(aData : int; aX : float; aW : float; aH : float; opt aText : Logic);

//=======================================================================
//=======================================================================
sub CRLF();
begin

  // Leerzeile?
  if (pls_TmpPosY=0) then begin
    SetA('.',1,10);
  end;

  Pls_PosY # pls_TmpPosY;
  Pls_TmpPosY # 0;
end;

//========================================================================
//========================================================================
SUB SetLine(
  aNr       : int;
  opt aX    : int;
  opt aXX   : int;
  opt aY    : int);
begin
  if (aX=0)   then aX   # form_StyleX;
  if (aXX=0)  then aXX  # form_StyleXX;
  if (aY=0) then aY # Pls_PosY;
  pls_TmpPosY # Max(Lib_PrintLine2:DrawLine(aNr, aX, aXX, aY), pls_TmpPosY);
  Pls_PosY # pls_TmpPosY;
  Pls_TmpPosY # 0;
end;

//========================================================================
//========================================================================
SUB SetVLineX(
  aNr   : int;
  aName : alpha) : logic;
local begin
  vObj  : int;
end;
begin

  Form_VLine[aNr]:X # -1;

  // kein Style geladen?
  if (Form_styleDef<>0) then begin
    vObj # Prtsearch(Form_StyleDef, aName);
    if (vObj<>0) then begin
      if ((vObj->ppVisiblePrint & _PrtVisiblePrintJob)<>0) then begin
        Form_VLine[aNr]:X # vObj->ppArealeft;
      end;
    end;
  end;

end;

//========================================================================