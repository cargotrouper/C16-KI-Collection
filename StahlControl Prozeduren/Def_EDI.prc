@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_EDI
//                    OHNE E_R_G
//  Info
//
//
//  04.10.2017  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================

DEFINE begin
  NewNodeA(a,b,c)     : Lib_XML:NewNode(a,b,c)
  NewNodeI(a,b,c)     : Lib_XML:NewNode(a,b, cnvai(c,_FmtNumNoGroup))
  NewNodeF(a,b,c)     : Lib_XML:NewNode(a,b, cnvaF(c,_FmtNumNoGroup|_FmtNumPoint,0,2))
  NewNodeB(a,b,c)     : Lib_XML:NewNodeB(a,b,c)
  NewNodeD(a,b,c)     : Lib_XML:NewNodeD(a,b,c)
  NewNodeT(a,b,c)     : Lib_XML:NewNode(a,b, cnvat(c,_FmtTimeSeconds))
  NewNode(a,b)        : Lib_XML:AppendNode(a,b)
  NewNodeComment(a,b)     : Lib_XML:AppendComment(a,b)

  NewNodeAttrib(a,b,c) : Lib_XML:AppendAttributeNode(a, b, c)

  EDIERROR(a,b,c) : EDI_Base:_EDIERROR(999, cWofDateiDefekt, vErr);

  StartWof(a,b,c) : EDI_Base:_StartWof(a,b,c)

  TryI(a,b) : EDI_Base:_TryI(a,b)
  TryF(a,b) : EDI_Base:_TryF(a,b)
  TryD(a,b) : EDI_Base:_TryD(a,b)

  NodeA(a,b,c,d)  : EDI_Base:_NodeA(a,b,c,d)
  NodeI(a,b,c,d)  : EDI_Base:_NodeI(a,b,c,d)
  NodeF(a,b,c,d)  : EDI_Base:_NodeF(a,b,c,d)
  NodeD(a,b,c,d)  : EDI_Base:_NodeD(a,b,c,d)

  WertMinMax(a,b,c,d,e)  : EDI_Base:_WertMInMax(a,b,c,d,e)
  WertF(a,b,c,d)  : EDI_Base:_WertF(a,b,c,d)
END;

