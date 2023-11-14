@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_PrintLine
//                    OHNE E_R_G
//  Info
//
//
//  02.03.2006  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================

define begin

  PL_Create(a)      : a # lib_PrintLine:Create()
  PL_Destroy(a)     : lib_PrintLine:Destroy(a)

  PL_Print          : Lib_PrintLine:Print
  PL_Print_R        : Lib_PrintLine:Print_R
  PL_PrintI         : Lib_PrintLine:PrintI
  PL_PrintI_L       : Lib_PrintLine:PrintI_L
  PL_PrintF         : Lib_PrintLine:PrintF
  PL_PrintF_L       : Lib_PrintLine:PrintF_L
  PL_PrintD         : Lib_PrintLine:PrintD
  PL_PrintD_L       : Lib_PrintLine:PrintD_L

  PL_PrintLine      : Lib_PrintLine:PrintLine()

  PL_DrawLine       : Lib_PrintLine:DrawLine
  PL_DrawBox        : Lib_PrintLine:DrawBox

  SpaceORFF(a)  : if (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y -form_RandUnten< PrtUnitLog(a, _prtUnitMillimetres)) then Lib_Print:Print_FF();
end;

//========================================================================