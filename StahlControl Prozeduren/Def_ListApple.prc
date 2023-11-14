@A+
//==== Business-Control ===================================================
//
//  Prozedur    Def_ListApple
//                    OHNE E_R_G
//  Info
//        Routinen für die Ausgabe von Listen als Apple Ipod App XML.
//        Wird in Kopien von Listen anstatt Lib_ListApple eingebunden
//
//  27.06.2011  ST  Erstellung der Prozedur
//
//=========================================================================

define begin

  _LF_String    : 0
  _LF_Int       : 1
  _LF_Wae       : 2
  _LF_Num       : 4
  _LF_Num0      : 2048
  _LF_Num3      : 8
  _LF_Date      : 0 //16
  _LF_IntNG     : 16

  _LF_Underline : 32
  _LF_Overline  : 64
  _LF_Bold      : 128
  _LF_Formula   : 256 // für Formeln via Excel XML
  _LF_Centered  : 512
  _LF_Italic    : 1024



  // Subprozeduren
  LF_Init       : Lib_ListApple:_Init
  LF_Term       : Lib_ListApple:_Term
  WriteTitel    : Lib_ListApple:_WriteTitel

  LF_NewLine(a) : Lib_ListApple:_NewLine( a )
  LF_FreeLine   : Lib_ListApple:_FreeLine
  LF_Print      : Lib_ListApple:_Print

  LF_Format(a)  : pls_Format # a
  LF_Set        : Lib_ListApple:_SetField
  LF_Text(a,b)  : Lib_ListApple:_Text( a, b )
  LF_Sum(a,b,c) : Lib_ListApple:_Text( a, CnvAF( list_Sum[b], 0, 0, c ) )

  // Summenfunktionen
  AddSum(a,b)   : list_Sum[a] # List_Sum[a] + b
  ResetSum(a)   : list_Sum[a] # 0.0
  GetSum(a)     : list_Sum[a]
  SetSum(a,b)   : list_Sum[a] # b

  // Umwandlungsfunktionen
  ZahlI(a)      : AInt( a )
  ZahlF(a,b)    : Lib_ListApple:_ZahlF( a, b )
  DatS(a)       : Lib_Berechnungen:KurzDatum_aus_Datum( a )

  BEGIN_BLOCK   : REPEAT BEGIN
  END_BLOCK     : END UNTIL ( true )
end;

//=========================================================================
//=========================================================================