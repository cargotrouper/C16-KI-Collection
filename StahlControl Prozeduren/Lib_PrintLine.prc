@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_PrintLine
//                      OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  17.05.2010  AI  Leerzeilen bekommen gleiche Höhe wie gefüllte Zeilen
//  07.09.2010  TM  Code39 erweitert um optionale Klartextanzeige
//  22.06.2012  AI  Ratio bei Bilddruck
//  18.04.2016  ST  Optionale DPI Angabe bei Bilddruck
//  2023-05-10  AH  Andere Combolines möglich
//
//  Subprozeduren
//    SUB Create() : int
//    SUB Destroy(aPL : int)
//    SUB Print(aName : alpha(1000); aX : float; optaXX : float; optaZeile : int);
//    SUB Print_R(aName : alpha(1000); aX : float; optaXX : float; optaZeile : int);
//    SUB PrintPic(aX : float; aXX : float; aYY : float; aName : alpha; opt aRatio : logic);
//    SUB PrintPicAbsolut(aX : float; aXX : float;  aY : float;  aYY : float; aName : alpha;opt aRatio : logic);
//    SUB PrintI(aWert : int; aX : float; optaXX : float; optaZeile : int);
//    SUB PrintI_L(aWert : int; aX : float; optaXX : float; optaZeile : int);
//    SUB PrintF(aWert : float; aDec : int; aX : float; optaXX : float; optaZeile : int);
//    SUB PrintF_L(aWert : float; aDec : int; aX : float; optaXX : float; optaZeile : int);
//    SUB PrintD(aDat : Date; aX : float; optaXX : float; optaZeile : int);
//    SUB PrintD_L(aDat : Date; aX : float; optaXX : float; optaZeile : int);
//    SUB DrawLine(aX : float; aXX : float; aY : float);
//    SUB DrawBox(aX : float; aXX : float; aCol : int);
//    SUB Barcode(aData : int; aX : float; aW : float; aH : float; opt aText : Logic);
//    SUB Barcode_C39(aData : alpha; aX : float; aW : float; aH : float; opt aText : Logic);
//    SUB PrintPageCount(aX : float; optaZeile : int);
//    SUB PrintLine();
//========================================================================
@I:Def_Global

define begin
  cZeilenhoehe  : 3.8
//  cZeilenhoehe  : 4.287   // font 10
end


//========================================================================
// Create
//
//========================================================================
sub Create() : int
local begin
  vHdl : int;
  vListComboName : alpha;
end;
begin
  vHdl # VarAllocate(class_PrintLine);
  
  // 2023-05-10 AH
  vListComboName  # 'Combo';
  if (Varinfo(class_list) > 0) then begin
    if (List_ComboName<>'') then
      vListComboName # List_ComboName;
  end;
    
  pls_Prt # PrtFormOpen(_PrtTypePrintForm,vListComboName);
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
  aName       : alpha(1000);
  aX          : float;
  opt aXX     : float;
  opt aZeile  : int) : int
local begin
  vFont : font;
  vH    : int;
end;
begin
  if (aX<=0.0) then   aX  # 0.0;
  if (aX>=300.0) then aX  # 300.0;

  if (aZeile>1) then begin
    pls_hdl->ppareabottom # PrtUnitLog(cZeilenhoehe*cnvfi(aZeile),_PrtUnitMillimetres);
    pls_hdl->ppareatop    # PrtUnitLog(cZeilenhoehe*cnvfi(aZeile-1),_PrtUnitMillimetres);
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
  if ( StrCut( aName, 1, 1 ) = '@' ) then   // Feldinhalt
    pls_Hdl->ppDbFieldName # StrCut( aName, 2, 20 )
  else
    pls_Hdl->ppcaption    # aName;



  vFont # pls_hdl->ppFont;
  if (pls_fontSize<>0) then   vFont:size  # pls_FontSize*10;
  vFont:Attributes  # pls_Fontattr;
  if (pls_fontName<>'') then  vFont:Name  # pls_FontName;
  pls_hdl->ppFont # vFont;

  if (Pls_Inverted) then begin
    pls_Hdl->ppColBkg # _WinColBlack;
    pls_Hdl->ppColFg # _WinColWhite;
  end;
  pls_Hdl->ppVisiblePrint # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;


  pls_Hdl->pparealeft   # PrtUnitLog(aX,_PrtUnitMillimetres);
  if (aXX=0.0) then begin
    pls_hdl->ppautoSize   # true;
    end
  else begin
    pls_Hdl->pparearight  # PrtUnitLog(aXX,_PrtUnitMillimetres);
    pls_hdl->ppwordbreak  # true;
    pls_hdl->ppautoSize   # true;
  end;

//  vH # pls_hdl->ppareabottom - pls_hdl->ppareatop;
  vH # pls_hdl->ppareabottom;

  pls_current # pls_current+1;
  pls_Hdl # PrtSearch(pls_Prt, 'tx.Combo'+cnvai(pls_current));

  RETURN vH;
end;


//========================================================================
//  Print_R - rechtsbündig
//
//========================================================================
sub Print_R(
  aName       : alpha(1000);
  aX          : float;
  opt aXX     : float;
  opt aZeile  : int) : int;
local begin
  vFont : font;
  vSize : int;
  vH    : int;
end;
begin
  if (aX<=0.0) then   aX  # 0.0;
  if (aX>=300.0) then aX  # 300.0;

  if (aZeile>1) then begin
    pls_hdl->ppareabottom # PrtUnitLog(cZeilenhoehe*cnvfi(aZeile),_PrtUnitMillimetres);
    pls_hdl->ppareatop    # PrtUnitLog(cZeilenhoehe*cnvfi(aZeile-1),_PrtUnitMillimetres);
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
  if ( StrCut( aName, 1, 1 ) = '@' ) then   // Feldinhalt
    pls_Hdl->ppDbFieldName # StrCut( aName, 2, 20 )
  else
    pls_Hdl->ppcaption    # aName;


  pls_Hdl->ppcaption    # aName;
  vFont # pls_hdl->ppFont;
  if (pls_fontSize<>0) then   vFont:size  # pls_FontSize*10;
  vFont:Attributes  # pls_Fontattr;
  if (pls_fontName<>'') then  vFont:Name  # pls_FontName;
  pls_hdl->ppFont # vFont;
  pls_Hdl->ppJustify    # _WinJustRight;

  if (Pls_Inverted) then begin
    pls_Hdl->ppColBkg # _WinColBlack;
    pls_Hdl->ppColFg # _WinColWhite;
  end;
  pls_Hdl->ppVisiblePrint # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;

  if (aXX=0.0) then begin
    pls_Hdl->ppAreaLeft   # 0;
    pls_hdl->ppAutoSize   # true;
    vSize # pls_Hdl->ppAreaRight - pls_Hdl->ppAreaLeft;
    pls_Hdl->ppJustify    # _WinJustRight;
    pls_Hdl->ppAreaRight  # PrtUnitLog(aX,_PrtUnitMillimetres);
    pls_Hdl->ppAreaLeft   # PrtUnitLog(aX,_PrtUnitMillimetres) - vSize;
    end
  else begin
    pls_Hdl->ppAreaRight  # PrtUnitLog(aX,_PrtUnitMillimetres);
    pls_Hdl->ppAreaLeft   # PrtUnitLog(aXX,_PrtUnitMillimetres);
    pls_hdl->ppWordBreak  # true;
    pls_hdl->ppAutoSize   # true;
    pls_Hdl->ppAreaRight  # PrtUnitLog(aX,_PrtUnitMillimetres);
  end;


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
  opt aDpi    : int;
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

  if (aDpi <> 0) then begin
    vHdl->ppPicDpiX  # aDpi;
    vHdl->ppPicDpiY  # vHdl->ppPicDpiX;
  end;


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
  opt aDpi    : int;
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

  if (aDpi <> 0) then begin
    vHdl->ppPicDpiX  # aDpi;
    vHdl->ppPicDpiY  # vHdl->ppPicDpiX;
  end;



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
sub PrintI(aWert : int; aX : float; opt aXX : float; opt aZeile : int) : int;
begin
  RETURN Print_R(cnvai(aWert,_Fmtnumnogroup),aX,aXX,aZeile);
end;

//========================================================================
//
//
//========================================================================
sub PrintI_L(aWert : int; aX : float; opt aXX : float; opt aZeile : int) : int;
begin
  RETURN Print(cnvai(aWert,_Fmtnumnogroup),aX,aXX,aZeile);
end;

//========================================================================
//
//
//========================================================================
sub PrintF(aWert : float; aDec : int; aX : float; opt aXX : float; opt aZeile : int) : int;
begin
  RETURN Print_R(cnvAF(aWert, 0, 0,aDec),aX,aXX,aZeile);
end;

//========================================================================
//
//
//========================================================================
sub PrintF_L(aWert : float; aDec : int; aX : float; opt aXX : float; opt aZeile : int) : int;
begin
  RETURN Print(cnvAF(aWert, 0, 0,aDec),aX,aXX,aZeile);
end;

//========================================================================
//
//
//========================================================================
sub PrintD(aDat : Date; aX : float; opt aXX : float; opt aZeile : int) : int;
begin
  if (aDat<>0.0.0) then
    RETURN Print_R(cnvai(DateDay(aDat),_FmtNumLeadZero,0,2)+'.'+cnvai(datemonth(aDat),_FmtNumLeadZero,0,2)+'.'+cnvai(dateyear(aDat)-100,_FmtNumLeadZero,0,2), aX,aXX,aZeile)
  else
    RETURN Print_R(' ', aX,aXX,aZeile);
end;

//========================================================================
//
//
//========================================================================
sub PrintD_L(aDat : Date; aX : float; opt aXX : float; opt aZeile : int) : int;
begin
  if (aDat<>0.0.0) then
    RETURN Print(cnvai(DateDay(aDat),_FmtNumLeadZero,0,2)+'.'+cnvai(datemonth(aDat),_FmtNumLeadZero,0,2)+'.'+cnvai(dateyear(aDat)-100,_FmtNumLeadZero,0,2), aX,aXX,aZeile)
  else
    RETURN Print(' ', aX,aXX,aZeile);
end;

//========================================================================
//
//
//========================================================================
sub DrawLine(
  aX  : float;
  aXX : float;
  aY  : float;
);
local begin
  vHdl : int;
end;
begin
  vHdl # PrtSearch(pls_Prt, 'PrtDivider0');
  vHdl->pparealeft    # PrtUnitLog(aX,_PrtUnitMillimetres);
  vHdl->ppareaRight   # PrtUnitLog(aXX,_PrtUnitMillimetres);
  vHdl->ppareaBottom  # PrtUnitLog(aY+1.0,_PrtUnitMillimetres);
  vHdl->ppareaTop     # PrtUnitLog(aY,_PrtUnitMillimetres);
  vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;
end;

//========================================================================
//
//
//========================================================================
sub DrawBox(
  aX    : float;
  aXX   : float;
  aCol  : int;
  aH    : float;
  opt aL  : int;    // 2023-05-10 AH
);
local begin
  vHdl : int;
end;
begin
  vHdl # PrtSearch(pls_Prt, 'PrtGroupbox'+aint(aL));    // 2023-05-10 AH
  if (vHdl=0) then RETURN;
  vHdl->pparealeft      # PrtUnitLog(aX,_PrtUnitMillimetres);
  vHdl->ppareaRight     # PrtUnitLog(aXX,_PrtUnitMillimetres);
  vHdl->ppareaBottom    # PrtUnitLog(aH,_PrtUnitMillimetres);
  vHdl->ppcolBkg        # aCol;
  vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;
end;


//========================================================================
//  Barcode_C39
//
//========================================================================
sub Barcode_C39(
  aData : alpha(4000);
  aX    : float;
  aW    : float;
  aH    : float;
  opt aText : Logic;
  opt aTyp  : int;
);
local begin
  vHdl : int;
end;
begin
  vHdl # PrtSearch(pls_Prt, 'PrtBarcode0');

  if (aTyp<>0) then vHdl->ppTypeBarcode # aTyp;
  
  vHdl->pparealeft      # PrtUnitLog(aX,_PrtUnitMillimetres);
  vHdl->ppareaRight     # PrtUnitLog(aX+aW,_PrtUnitMillimetres);
  vHdl->ppareaBottom    # PrtUnitLog(aH,_PrtUnitMillimetres);
  vHdl->ppVisiblePrint  # _PrtVisiblePrintJob | _PrtVisiblePrintPreview;

  vHdl->ppshowtext      # false;

  If (aText = true) then
    vHdl->ppshowtext    # true;

  vHdl->wpcaption # aData;

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
//
//
//========================================================================
sub PrintPageCount(aX : float; opt aZeile : int);
begin
  pls_hdl->ppname # 'ptSeite';
  Print_R('<seite>',aX,0.0,aZeile);
end;


//========================================================================
//  PrintLine
//    druckt die Combozeile aus und resettet sie
//========================================================================
sub PrintLine()
local begin
  vHdl : int;
  vListComboName : alpha;
end;
begin

  // Leerzeilen gleiche Höhe wie gefüllte Zeilen vom 17.05.2010
  if ("Set.Druck.Zeilenhöhe"<>0.0) then
    if (pls_current=1) then print(' ',0.0);

  Lib_Print:LfPrint(pls_Prt);

  // 2023-05-10 AH
  vListComboName  # 'Combo';
  if (Varinfo(class_list) > 0) then begin
    if (List_ComboName<>'') then
      vListComboName # vListComboName;
  end;
  pls_Prt # PrtFormOpen(_PrtTypePrintForm,vListComboName);


  pls_current # 1;
  pls_Hdl # PrtSearch(pls_Prt, 'tx.Combo'+cnvai(pls_current));
end;


//========================================================================