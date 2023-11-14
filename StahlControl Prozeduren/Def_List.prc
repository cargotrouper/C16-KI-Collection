@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_List
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
  _LF_String    : 0
  _LF_Int       : 1
  _LF_Wae       : 2
  _LF_Num       : 4
  _LF_Num0      : 512
  _LF_Num3      : 8
  _LF_Date      : 0 //16

  _LF_Underline : 32
  _LF_Overline  : 64
  _LF_Bold      : 128
  _LF_Formula   : 256 // für Formeln via Excel XML
  _LF_Italic    : 1024

  ListInit      : Lib_List:_Init
  ListTerm      : Lib_List:_Term
  WriteTitel    : Lib_List:_WriteTitel

  Write         : Lib_List:_Write
  StartLine     : Lib_List:_StartLine
  EndLine       : Lib_List:_EndLine

  AddSum(a,b)   : List_Sum[a] # List_Sum[a] + b
  ResetSum(a)   : List_Sum[a] # 0.0
  GetSum(a)     : list_Sum[a]
  SetSum(a,b)   : list_Sum[a] # b

  ZahlI(a)      : cnvai(a,_FmtNumNoGroup)
  ZahlF(a,b)    : Lib_List:_ZahlF(a,b)
  DatS(a)       : Lib_Berechnungen:KurzDatum_aus_Datum(a)
  //cnvai(DateDay(a),_FmtNumLeadZero,0,2)+'.'+Cnvai(dateMonth(a),_FmtNumLeadZero,0,2)+'.'+cnvai(DateYear(a)-100,_fmtNumleadzero,0,2)
//  Datum(a)      : '2007-12-12'
end;

//========================================================================