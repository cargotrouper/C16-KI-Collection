@A+
//===== Business-Control =================================================
//
//  Prozedur  Def_Form
//                    OHNE E_R_G
//  Info
//
//
//  24.10.2012  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  ADD_VERP(a,b)   : begin if (vA<>'') then vA # vA + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vA # vA + a + StrAdj(b,_StrBegin | _StrEnd); end;

  AddLIZ              : Form_parse:_AddLiz
  AlphaMinMax         : Form_parse:_AlphaMinMax
  ParseAllgemein      : Form_Parse:_ParseAllgemein
  ParseAllgemeinMulti : Form_Parse:_ParseAllgemeinMulti

  StartPrint  : Lib_Form:StartPrint
  EndPrint    : Lib_Print:LfPrint(pls_Prt, true)
  FreeElement : Lib_Form:FreeElement

  PrintText   : Lib_Form:PrintText
  SetLine     : Lib_Form:SetLine

  CRLF        : Lib_Form:CRLF()
  SetA        : Lib_Form:SetA
  SetD        : Lib_Form:SetD
  SetI        : Lib_Form:SetI
  SetF        : Lib_Form:SetF

  VarA        : Lib_Form:VarA
  VarD        : Lib_Form:VarD
  VarI        : Lib_Form:VarI
  VarF        : Lib_Form:VarF

  DynA        : Lib_Form:DynA
  DynBC       : Lib_Form:DynBarcode
  DynA_R      : Lib_Form:DynA_R
  FillDynA    : Lib_Form:FillDynA
  FillDynBC   : Lib_Form:FillDynBarcode

  SetBox        : Lib_Form:SetBox

  CreatePL      : Lib_PrintLine2:Create

  SetVLineStartY(a) : if (Form_VLine[a]:x>-1) then Form_VLine[a]:Y # form_Page->ppBoundAdd:y
  PrintVLinie(a)    : if (Form_vLine[a]:y>-1) then begin Lib_PrintLine2:DrawVLine(Form_vLine[a]:x, Form_vLine[a]:y) form_Vline[a]:y # -1; end;
  SetVLineX         : Lib_Form:SetVLineX


  AddA          : Lib_Form:AddOptA
  AddD          : Lib_Form:AddOptD
  AddI          : Lib_Form:AddOptI
  AddF          : Lib_Form:AddOptF
  AddLine(a,b) : a # a + b + StrChar(10)

  LoadStyleDef(a)       : Lib_Form:LoadStyleDef(a)
  LoadSubStyleDef(a)    : Lib_Form:LoadSubStyleDef(a)
  UnLoadStyleDef(a)     : Lib_Form:UnLoadStyleDef(a)
  UnLoadSubStyleDef(a)  : Lib_Form:UnLoadSubStyleDef(a)
  UseStyle              : Lib_Form:UseStyle
  GetCaption            : Lib_Form:GetCaption
  IsVisible             : Lib_Form:IsVisible
  GetObj                : Lib_Form:GetObj
end;

//========================================================================