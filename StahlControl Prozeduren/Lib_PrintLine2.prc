@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_PrintLine2
//                      OHNE E_R_G
//  Info
//
//
//  24.10.2012  AI  Erstellung der Prozedur
//  07.06.2013  ST  sub Print(...) Argumenteenlänge erweitert
//
//  Subprozeduren
//    SUB Create(opt aFormName : alpha) : int
//    SUB Destroy(aPL : int)
//    SUB Print(aName : alpha(1000); aX : float; opt aXX : float; opt aY : int);
//    SUB Print_R(aName : alpha(1000); aX : float; opt aXX : float; opt aY : int);
//    SUB PrintPic(aX : float; aXX : float; aYY : float; aName : alpha; opt aRatio : logic);
//    SUB PrintPicAbsolut(aX : float; aXX : float;  aY : float;  aYY : float; aName : alpha;opt aRatio : logic);
//    SUB PrintI(aWert : int; aX : float; opt aXX : float; opt aY : int);
//    SUB PrintI_L(aWert : int; aX : float; opt aXX : float; opt aY : int);
//    SUB PrintF(aWert : float; aDec : int; aX : float; opt aXX : float; opt aY : int);
//    SUB PrintF_L(aWert : float; aDec : int; aX : float; opt aXX : float; opt aY : int);
//    SUB PrintD(aDat : Date; aX : float; opt aXX : float; opt aY : int);
//    SUB PrintD_L(aDat : Date; aX : float; opt aXX : float; opt aY : int);
//    SUB DrawLine(aX : float; aXX : float; aY : float);
//    SUB DrawBox(aX : float; aXX : float; aCol : int);
//    SUB Barcode(aData : int; aX : float; aW : float; aH : float; opt aText : Logic);
//    SUB Barcode_C39(aData : alpha; aX : float; aW : float; aH : float; opt aText : Logic);
//    SUB PrintPageCount(aX : float; opt aY : int);
//    SUB PrintLine();
//========================================================================
@I:Def_Global

define begin
//  cZeilenhoehe  : 4.287   // font 10
end

//========================================================================
// Create
//
//========================================================================
sub Create(opt aFormNAme : alpha) : int
local begin
  vHdl : int;
end;
begin
  if (aFormName='') then aFormName # 'Combo_max20';
  vHdl # VarAllocate(class_PrintLine);
  pls_Prt # PrtFormOpen(_PrtTypePrintForm,aFormName);
  pls_hdl # PrtSearch(pls_Prt, 'tx.Combo1');
  pls_current # 1;
  RETURN vHdl;
end;


//========================================================================
// Destroy
//
//========================================================================
Sub Destroy(aPL : int)
begin
  VarInstance(Class_PrintLine,aPL);
  PrtFormClose(pls_Prt);
  VarFree(Class_PrintLine);
end;


//========================================================================
//  Print - linksbündig
//
//========================================================================
sub Print(
  aName       : alpha(4096);    // ST 2013-06-07: von 1000 auf Maximalwert
  aX          : int;
  aXX         : int;
  opt aY      : int) : int
local begin
  vH          : int;
end;
begin

  if (aX=0)   then aX   # form_StyleX;
  if (aXX=0)  then aXX  # form_StyleXX;

  if (aY<>0) then begin
    pls_hdl->ppareabottom # aY + 1;
    pls_hdl->ppareatop    # aY;
  end;

  // spezieller Inhalt?
  if (aName='PrtStyleCapPageNo') then begin
    aName # '';
    pls_Hdl->ppStyleCaption # _PrtStyleCapPageNo;
  end;
  if (aName='PrtStyleCapPageCount') then begin
    aName # '';
    pls_Hdl->ppStyleCaption # _PrtStyleCapPageCount;
  end;
  if ( StrCut( aName, 1, 1 ) = '@' ) then begin  // Feldinhalt
    pls_Hdl->ppDbFieldName # StrCut( aName, 2, 20 );
    end
  else begin
    if (StrCut(aName,1,1)=' ') then
      aName # Str_ReplaceAll(aName,' ', StrChar(255));
    pls_Hdl->ppcaption    # aName;
  end;

  pls_hdl->ppFont     # Form_StyleFont;
  pls_Hdl->ppJustify  # Form_styleJustX;

  pls_Hdl->ppColBkg # form_styleBkg;
  pls_Hdl->ppColFg  # form_styleCol;
  pls_Hdl->ppVisiblePrint # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;



//debug('print '+aname);
  // LINKS?
//  if (y) or (Form_StyleJustX=_WinJustLeft) then begin
    pls_Hdl->pparealeft   # aX;
    pls_hdl->ppautoSize   # true;
    if (aXX<>0) then
      pls_Hdl->pparearight  # aXX;
//    end
//  else begin  // Rechts
//    pls_Hdl->pparealeft   # aX;
//    if (aXX<>0) then
//      pls_Hdl->pparearight  # aXX;
//    pls_hdl->ppautoSize   # true;
//    if (aXX<>0) then
//      pls_Hdl->pparearight  # aXX;
//  end;

  if (Form_StyleWordBreak) then begin
    pls_hdl->ppJustifyVert # _WinJustTop;
    pls_hdl->ppWordBreak  # true;
    pls_hdl->ppautoSize   # true;
  end;

/***
    end
  else begin    // RECHTS?
    if (aXX=0) then begin
      pls_Hdl->ppAreaLeft   # 0;
      pls_hdl->ppAutoSize   # true;
      vSize # pls_Hdl->ppAreaRight - pls_Hdl->ppAreaLeft;
      pls_Hdl->ppJustify    # _WinJustRight;
      pls_Hdl->ppAreaRight  # aX;
      pls_Hdl->ppAreaLeft   # aX - vSize;
      end
    else begin
      pls_Hdl->ppAreaRight  # aX;
      pls_Hdl->ppAreaLeft   # aXX;
//      pls_hdl->ppWordBreak  # true;
      pls_hdl->ppAutoSize   # true;
      pls_Hdl->ppAreaRight  # aX;
    end;
  end;
***/
  vH # pls_hdl->ppareabottom;

  pls_current # pls_current+1;
  pls_Hdl # PrtSearch(pls_Prt, 'tx.Combo'+cnvai(pls_current));

  RETURN vH;
end;


//========================================================================
//  PrintPic
//
//========================================================================
sub PrintPic(
  aX          : float;
  aXX         : float;
  aYY         : float;
  aName       : alpha;
  opt aRatio  : logic;
);
local begin
  vHdl : int;
end;
begin
  vHdl # PrtSearch(pls_Prt, 'PrtPicture0');
  vHdl->pparealeft    # PrtUnitLog(aX,_PrtUnitMillimetres);
  vHdl->ppareaRight   # PrtUnitLog(aXX,_PrtUnitMillimetres);
  vHdl->ppareaBottom  # PrtUnitLog(aYY,_PrtUnitMillimetres);

  if (aRatio) then
    vHdl->ppPicturemode # _WinPictRatio
  else
    vHdl->ppPicturemode # _WinPictStretch;

  vHdl->ppVisiblePrint # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;
  vHdl->wpcaption     # aName;
end;


//========================================================================
//  PrintPicAbsolut
//    !!! Druckaufruf im SEITENFUSS !!!
//========================================================================
sub PrintPicAbsolut(
  aX          : float;
  aXX         : float;
  aY          : float;
  aYY         : float;
  aName       : alpha;
  opt aRatio  : logic;
);
local begin
  vHdl : int;
  vPrt  : int;
end;
begin
    // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.Picture');
  vHdl # PrtSearch(vPrt, 'PrtPicture');

  vHdl->pparealeft      # PrtUnitLog(aX,_PrtUnitMillimetres);
  vHdl->ppareaRight     # PrtUnitLog(aX+aXX,_PrtUnitMillimetres);
  vHdl->ppAreaTop       # PrtUnitLog(aY,_PrtUnitMillimetres);
  vHdl->ppareaBottom    # PrtUnitLog(aY+aYY,_PrtUnitMillimetres);

  if (aRatio) then
    vHdl->ppPicturemode # _WinPictRatio;

  vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;

  vHdl->wpcaption       # aName;

  // Element drucken und schließen
  form_Page->PrtAdd(vPrt, _PrtAddTop,0,0);//, PrtUnitLog(aY,_PrtUnitMillimetres), PrtUnitLog(aX,_PrtUnitMillimetres));
  vPrt->PrtFormClose();
  /*
  vPrt  # PrtFormOpen(_PrtTypePrintForm, 'xFRM.Picture');     // Element anmelden

  vHdl # PrtSearch(vPrt, 'PrtPicture');

  vHdl->pparealeft      # PrtUnitLog(aX,_PrtUnitMillimetres);
  vHdl->ppareaRight     # PrtUnitLog(aXX,_PrtUnitMillimetres);
  vHdl->ppareaTop       # PrtUnitLog(aY,_PrtUnitMillimetres);
  vHdl->ppareaBottom    # PrtUnitLog(aYY,_PrtUnitMillimetres);
  vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;
  vHdl->wpcaption       # aName;


  form_Page->PrtAdd(vPrt, _PrtAddTop, cnvIF(aY), cnvIF(aX)); // Element drucken und schließen
  vPrt->PrtFormClose();
  */
end;


//========================================================================
//
//
//========================================================================
sub xxxPrintI(aWert : int; aX : float; opt aXX : float; opt aY : int) : int;
begin
//  RETURN Print_R(cnvai(aWert,_Fmtnumnogroup),aX,aXX,aY);
end;

//========================================================================
//
//
//========================================================================
sub PrintI_L(aWert : int; aX : float; opt aXX : float; opt aY : int) : int;
begin
//  RETURN Print(cnvai(aWert,_Fmtnumnogroup),aX,aXX,aY);
end;

//========================================================================
//
//
//========================================================================
sub xxxPrintF(aWert : float; aDec : int; aX : float; opt aXX : float; opt aY : int) : int;
begin
  ///RETURN Print_R(cnvAF(aWert, 0, 0,aDec),aX,aXX,aY);
end;

//========================================================================
//
//
//========================================================================
sub PrintF_L(aWert : float; aDec : int; aX : float; opt aXX : float; opt aY : int) : int;
begin
//  RETURN Print(cnvAF(aWert, 0, 0,aDec),aX,aXX,aY);
end;

//========================================================================
//
//
//========================================================================
sub xxxPrintD(aDat : Date; aX : float; opt aXX : float; opt aY : int) : int;
begin
//  if (aDat<>0.0.0) then
//    RETURN Print_R(cnvad(aDat,_FmtDateLongYear), aX,aXX,aY);
//  else
//    RETURN Print_R(' ', aX,aXX,aY);
end;

//========================================================================
//
//
//========================================================================
sub PrintD_L(aDat : Date; aX : float; opt aXX : float; opt aY : int) : int;
begin
//  if (aDat<>0.0.0) then
//    RETURN Print(cnvad(aDat,_FmtDateLongYear), aX,aXX,aY);
//  else
//    RETURN Print(' ', aX,aXX,aY);
end;

//========================================================================
//
//
//========================================================================
sub DrawLine(
  aNr : int;
  aX  : int;
  aXX : int;
  aY  : int;
) : int;
local begin
  vHdl : int;
end;
begin
  vHdl # PrtSearch(pls_Prt, 'PrtDivider'+cnvai(aNr));
  if (vHdl>0) then begin
    vHdl->pparealeft    # aX;
    vHdl->ppareaRight   # aXX;
    vHdl->ppareaBottom  # aY+3000;
    vHdl->ppareaTop     # aY;
    vHdl->ppWidthPen    # prtUnitLog(0.3, _PrtUnitMillimetres);
    vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;
    RETURN vHdl->ppareabottom;
  end;

  RETURN aY+3000;
end;


//========================================================================
//
//
//========================================================================
sub DrawBox(
  aX    : int;
  aXX   : int;
  aCol  : int;
  aH    : int;
);
local begin
  vHdl : int;
end;
begin
  vHdl # PrtSearch(pls_Prt, 'PrtGroupbox0');
vHdl->ppAreaTop # pls_Posy;
  vHdl->pparealeft      # aX;
  vHdl->ppareaRight     # aXX;
  vHdl->ppareaBottom    # Pls_Posy+aH;
  vHdl->ppcolBkg        # aCol;
  vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;
end;


//========================================================================
//  Barcode_C39
//
//========================================================================
sub Barcode_C39(
  aData     : alpha;
  aX        : int;
  aXX       : int;
  aH        : int;
  opt aText : Logic;
) : int;
local begin
  vHdl : int;
end;
begin
  vHdl # PrtSearch(pls_Prt, 'PrtBarcode0');

  vHdl->ppTypeBarcode   # _WinBarcode39;
  vHdl->ppcaption       # aData;
  vHdl->pparealeft      # aX;
  vHdl->ppareaRight     # aXX;
  vHdl->ppareaTop       # 0;
  vHdl->ppareaBottom    # aH;
  vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;
  vHdl->ppshowtext      # aText;
  vHdl->ppcaption       # aData;

  RETURN pls_hdl->ppareabottom;
end;


//========================================================================
//  Barcode_C39_Style
//
//========================================================================
sub Barcode_C39_Style(
  aCode     : alpha;
  aX        : int;
  aXX       : int;
  aY        : int;
) : int;
local begin
  vHdl  : int;
  vH          : int;
  vYY         : int;
end;
begin
  vHdl # PrtSearch(pls_Prt, 'PrtBarcode0');

  if (aX=0)   then aX   # form_StyleX;
  if (aXX=0)  then aXX  # form_StyleXX;

  if (aY<>0) then begin
    vhdl->ppareabottom # aY + 1;
    vhdl->ppareatop    # aY;
  end;

  vHdl->ppTypeBarcode   # _WinBarcode39;
  vHdl->ppcaption       # aCode;
  vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;

  // x Komponente
  vHdl->pparealeft   # aX;
  if (aXX<>0) then
    vHdl->pparearight  # aXX;


  // y Komponente
  vHdl->ppareaTop       # aY;
  vHdl->ppareaBottom    # aY + prtUnitLog(14.0, _PrtUnitMillimetres);

  RETURN vHdl->ppareabottom;
end;


//========================================================================
//  Barcode_C39Absolut
//  MS  13.01.2010
//========================================================================
sub Barcode_C39Absolut(
  aData : alpha;
  aX    : float;
  aW    : float;
  aY    : float;
  aH    : float;
  opt aText : logic;
);
local begin
  vHdl : int;
  vPrt : int;
end;
begin
  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Barcode');
  vHdl # PrtSearch(vPrt, 'PrtBarcode0');

  vHdl->pparealeft      # PrtUnitLog(aX,_PrtUnitMillimetres);
  vHdl->ppareaRight     # PrtUnitLog(aX+aW,_PrtUnitMillimetres);
  vHdl->ppAreaTop       # PrtUnitLog(aY,_PrtUnitMillimetres);
  vHdl->ppareaBottom    # PrtUnitLog(aH,_PrtUnitMillimetres);

  vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;

  vHdl->ppshowtext      # false;

  if (aText = true) then
    vHdl->ppshowtext    # true;


  vHdl->wpcaption       # aData;

  // Element drucken und schließen
  form_Page->PrtAdd(vPrt, _PrtAddTop, cnvIF(aY), cnvIF(aX));
  vPrt->PrtFormClose();
end;


//========================================================================
//  DrawVLine
//  - Druck eine VERTIKALE Trennlinie aus
//  Das muss UNTER der Position passieren, da sonst der Cursor tiefer wandert
//========================================================================
Sub DrawVLine(
  aX  : int;
  aY  : int;
  opt aYY : int;
)
local begin
  vHdl  : int;
  vPrt  : int;
  vY    : int;
end;
begin
  If (form_Job = 0) then RETURN;

  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Linie.V.Einzeln');

  vY # aY;
  if (aYY=0) then
    aYY # form_Page->ppBoundAdd:Y - 2000;
//debug('line:'+aint(vY)+' bis '+aint(aYY));

  vHdl # Winsearch(vPrt,'PrtDivider0');
  vHdl->ppareaTop     # aY;
  vHdl->ppareaBottom  # aYY;

  vHdl->ppareaLeft    # aX;
  vHdl->ppareaRight   # aX+2000;

  form_Page->PrtAdd(vPrt,_PrtAddTop,1);//, 0, aX);

  vPrt->PrtFormClose();
end;

//========================================================================