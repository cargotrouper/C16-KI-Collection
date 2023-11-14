@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_XML
//                OHNE E_R_G
//  Info
//
//
//  08.04.2008  AI  Erstellung der Prozedur
//  10.08.2009  ST  Umstellung auf cteXML Baum
//
//  Subprozeduren
//    SUB NewNode(aRoot : handle; aName : alpha; aValue : Alpha) : handle;
//    SUB NewNodeB(aRoot : handle; aName : alpha; aValue : Logic) : handle;
//    SUB NewNodeD(aRoot : handle; aName : alpha; aValue : Date) : handle;
//    SUB GetType(aY : int) : alpha
//    SUB SetDepth(aParent : handle; var aMaxLvl : int; var aElemCnt : int) : int;
//    SUB ImportXML(aPathToFile : alpha(1000); var vLevel : int; var vElems : int) : handle
//    SUB HasValueNode(aParent : handle) : logic
//    SUB FillDLFromXML(aDL : int; aXMLobj : handle;  var aVal : alpha; var aMapping : int[]; ) : logic;
//    SUB arraySet(aY : int; aX : int; var aMapping : int[]; aVal : int) : int;
//    SUB arrayGet(aY : int; aX : int; var aMapping : int[]) : int
//    SUB DebugBindingPrint(  var aMapping : int[];  aRowCnt : int;)
//========================================================================
@I:Def_Global

local begin
  gI        : int;
end;
define begin
  cMaxWidth : 100
end;


// Prototypen
declare SetDepth(aParent : handle; var aMaxLvl : int; var aElemCnt : int) : int;
declare ImportXML(aPathToFile : alpha(1000); var vLevel : int; var vElems : int) : handle
declare HasValueNode(aParent : handle) : logic
declare FillDLFromXML(aDL : int; aXMLobj : handle;  var aVal : alpha; var aMapping : int[]; ) : logic;
declare arraySet(aY : int; aX : int; var aMapping : int[]; aVal : int) : int;
declare arrayGet(aY : int; aX : int; var aMapping : int[]) : int
declare DebugBindingPrint(  var aMapping : int[];  aRowCnt : int;)



//========================================================================
//  NewNode
//
//========================================================================
sub NewNode(aRoot : handle; aName : alpha; aValue : alpha) : handle;
local begin
  vNode : handle;
end;
begin
  aName   # StrCnv(aName, _StrToANSI);
  aValue  # StrCnv(aValue, _StrToANSI);

  vNode # aRoot->CteInsertNode(aName, _XmlNodeElement, NULL);
  if (aValue<>'') then vNode # vNode->CteInsertNode(aName, _XmlNodeText, aValue);
  RETURN vNode;
end;


//========================================================================
//  NewNodeB
//
//========================================================================
sub NewNodeB(aRoot : handle; aName : alpha; aValue : logic) : handle;
local begin
  vNode : handle;
end;
begin
  if (aValue) then RETURN NewNode(aRoot, aName,'Y')
  else RETURN NewNode(aRoot, aName, 'N')
end;


//========================================================================
//  NewNodeD
//
//========================================================================
sub NewNodeD(aRoot : handle; aName : alpha; aValue : Date) : handle;
local begin
  vNode : handle;
end;
begin
  if (aValue<>0.0.0) then RETURN NewNode(aRoot,aName,cnvad(aValue,_FmtDateLongYear))
  else RETURN NewNode(aRoot, aName, '');
end;


//========================================================================
//  VERALTET   VERALTET  VERALTET  VERALTET  VERALTET  VERALTET  VERALTET
//  GetType(aY : int)
//  VERALTET   VERALTET  VERALTET  VERALTET  VERALTET  VERALTET  VERALTET
//========================================================================
sub GetType(aY : int) : alpha
local begin
  vHDL  : int;
  vCol  : int;
  vI    : int;
  vA    : alpha;
end;
begin
  vHDL # $DL.XML;
  vCol # vHDL->WinInfo(_WinFirst);
  WHILE (vCol<>0) do begin
    vI # vI + 1;
    if (vCol->wpFontAttr=_WinFontAttrB) then begin
      vHDL->WinLstCellGet(vA, vI, aY);
      if (vA=vCol->wpcaption) then BREAK;
    end;
    vCol # WinInfo(vCol , _WinNext);
  END;

  if (vCol=0) then RETURN '';

  vHDL->WinLstCellGet(vA, vI, aY);
  RETURN vA;
end;


//========================================================================
//  sub GetNodeType(aNode : handle) : alpha
//    Gibt den Namen eines NodeElementes zurück
//========================================================================
sub GetNodeType(aNode : handle) : alpha
local begin
  vRet  : alpha;
end;
begin

  vRet # '';
  if (aNode <> 0) AND (aNode->spID = _XmlNodeElement) then
    vRet # StrCnv(aNode->spName,_StrFromUTF8);

  RETURN (vRet);
end;


//========================================================================
//  sub GetValue(aNode : handle; var aFld : alpha) : logic
//    Gibt den Wert eines XML Elements zurück
//========================================================================
sub GetValue(aNode : handle; var aFld : alpha) : logic
local begin
  vNode : handle;
end;
begin
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      aFld #  StrCnv(vNode->spValueAlpha,_StrFromUTF8);
      return true;
    end;
  end;
  return false;
end;

//========================================================================
//  sub GetValueI(aNode : handle; var aFld : alpha) : logic
//    Gibt den Wert eines XML Elements zurück
//========================================================================
sub GetValueI(aNode : handle; var aFld : int) : logic
local begin
  vNode : handle;
end;
begin
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      aFld #  CnvIa(StrCnv(vNode->spValueAlpha,_StrFromUTF8));
      return true;
    end;
  end;
  return false;
end;

//========================================================================
//  sub GetValueI16(aNode : handle; var aFld : alpha) : logic
//    Gibt den Wert eines XML Elements zurück
//========================================================================
sub GetValueI16(aNode : handle; var aFld : word) : logic
local begin
  vNode : handle;
end;
begin
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      aFld #  CnvIa(StrCnv(vNode->spValueAlpha,_StrFromUTF8));
      return true;
    end;
  end;
  return false;
end;

//========================================================================
//  sub GetValueF(aNode : handle; var aFld : alpha) : logic
//    Gibt den Wert eines XML Elements zurück
//========================================================================
sub GetValueF(aNode : handle; var aFld : float) : logic
local begin
  vNode : handle;
  vVal  : alpha;
end;
begin
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      vVal # (StrCnv(vNode->spValueAlpha,_StrFromUTF8));
      // Punkt wird zu Komma
      vVal # Str_ReplaceAll(vVal,'.',',');

      aFld #  CnvFa(vVal);
      return true;
    end;
  end;
  return false;
end;


//========================================================================
//  sub GetValueB(aNode : handle; var aFld : alpha) : logic
//    Gibt den Wert eines XML Elements zurück
//========================================================================
sub GetValueB(aNode : handle; var aFld : logic) : logic
local begin
  vNode : handle;
end;
begin
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      aFld # false;
      aFld #  ((StrCnv(vNode->spValueAlpha,_StrFromUTF8) = 'Y'));
      return true;
    end;
  end;
  return false;
end;


//========================================================================
//  sub GetValueD(aNode : handle; var aFld : alpha) : logic
//    Gibt den Wert eines XML Elements zurück
//========================================================================
sub GetValueD(aNode : handle; var aFld : date) : logic
local begin
  vNode : handle;
end;
begin
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      aFld #  CnvDa(StrCnv(vNode->spValueAlpha,_StrFromUTF8));
      return true;
    end;
  end;
  return false;
end;


//========================================================================
//  sub GetValueT(aNode : handle; var aFld : alpha) : logic
//    Gibt den Wert eines XML Elements zurück
//========================================================================
sub GetValueT(aNode : handle; var aFld : time) : logic
local begin
  vNode : handle;
end;
begin
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      aFld #  CnvTa(StrCnv(vNode->spValueAlpha,_StrFromUTF8));
      return true;
    end;
  end;
  return false;
end;


//========================================================================
//  sub SetDepth(aParent : handle)
//    Durchläuft den XML Baum und setzt die Tiefeninformation für die
//    Färbung der Liste. Zusätzlich wird die Anzahl der XML Elemente
//    ermittelt und zurückgegeben.
//========================================================================
sub SetDepth(aParent : handle; var aMaxLvl : int; var aElemCnt : int) : int;
local begin
  vNode : handle;
end
begin

  FOR  vNode # aParent->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aParent->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) DO BEGIN

    inc(aElemCnt);  // Elemente zählen

    if (vNode->spID = _XmlNodeElement) then begin
      vNode->spCustom # CnvAi(CnvIa(aParent->spCustom)+1);
      aMaxLvl # CnvIa(vNode->spCustom);
    end;

    // Rekursiv die Tiefe bestimmen
    SetDepth(vNode, var aMaxLvl, var aElemCnt);
  END;

end;

//========================================================================
//  sub ImportXML(aPathToFile : alpha(1000); var vLevel : int; var vElems : int) : handle
//    Importiert eine XML Datei und gibt das komplette Node zurück,
//========================================================================
sub ImportXML(aPathToFile : alpha(1000); var vLevel : int; var vElems : int) : handle
local begin
  vNode     : handle;
  vMaxLevel : int;
end begin

  // Node erstellen um XML Dokument laden zu können
  vNode # CteOpen(_cteNode);

  // Einlesen und im Fehlerfall Note leeren schließen und löschen
  if (vNode->XMLLoad(aPathToFile) != _ErrOk) then begin
    vNode->CteClear(true);
    vNode->CteClose();
    RETURN 0;
  end;

  // Tiefen ermitteln
  SetDepth(vNode,var vMaxLevel, var vElems);

  // Maximales Level zurückgeben
  vLevel # vMaxLevel;

  // Zähler für die DL Füllung initialisiern
  gI # 1;
  RETURN vNode;
end;


//========================================================================
//  sub HasValueNode(aParent : handle) : logic
//    Prüft ob das Aktuelle Node ein Eintrag mit nur einem Kind, als
//    Texthinhalt besitzt
//========================================================================
sub HasValueNode(aParent : handle) : logic
local begin
  vNode : handle;
  i     : int;
  vOK   : logic;
  vVal  : alpha;
end
begin

  vOK # false;
  FOR  vNode # aParent->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aParent->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) DO BEGIN

    inc(i);
    if (vNode->spID = _XmlNodeText) then begin
      vOK # true;
      break;
    end;
  END;

  // vOK und i=1 -> Der Knoten hat ein Element und es ist ein Textelement
  // i = 0 -> Der Knoten ist ein leeres XML Element <xxx/>
  if ((vOK) AND (i = 1)) OR (i = 0) then
    RETURN true;
  else
    RETURN false;

end;



//========================================================================
//  FillDLFromXML
//    Füllt eine Liste anhand eines XML Objektes
//========================================================================
sub FillDLFromXML(
  aDL     : int;
  aXMLobj : handle;
  var aVal : alpha;
  var aMapping : int[];
  ) : logic;
local begin
  vError  : alpha;
  vBreak  : logic;

  vHdl    : handle;

  vA      : alpha(4000);
  vB      : alpha(4000);
  vC      : alpha(4000);
  vMode   : alpha;

  vNode   : handle;
  vValue  : alpha;
  vColumn : int;
  vDepth : int;
  vElement : alpha;
  vLine   : int;
end;
begin

  FOR  vNode # aXMLObj->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aXMLObj->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin

    // Kommentare nicht beachten
    case (vNode->spID) of
      _XmlNodeElement : begin
         vElement     # StrCnv(vNode->spName,_StrFromUTF8);
      end;
      _XmlNodeText    : begin
        aVal # StrCnv(vNode->spValueAlpha,_StrFromUTF8);
        return false;
      end;
      otherwise
        cycle;
    end;

    // --------------------------------------------------
    // Knoten gefunden
    if (vNode->spID = _XmlNodeElement) then begin

      // ------------------------------
      // Spaltenüberschriften anlegen
      begin
        vA # StrCnv(vElement,_strLetter);
        vHdl # Winsearch(aDL, vA);
        if (vHdl=0) then begin
          if (gI = 0) then gI # 1;
          vHdl # Winsearch(aDL, 'col'+cnvai(gI));
          gI # gI + 1;
        end;
        // ggf. Spalte "anlegen"
        if (vHdl<>0) then begin
          vHdl->wpname    # vA;
          vHdl->wpCaption # vElement;
          vHdl->wpVisible # y;
          vDepth # 30+255 - (CnvIa(vNode->spCustom) * 30);
          vHdl->wpClmColBkg # ((((vDepth<<8)+ vDepth)<<8)+ vDepth);
          if (vHdl->wpcustom='') then vHdl->wpcustom # cnvai(gI-1);

          vColumn  # cnvia(vHdl->wpcustom);
          vHdl->wpClmWidth # 80;
          if (strlen(vElement)>8) then
            vHdl->wpClmWidth # StrLen(vElement) * 10;
        end;

      end; // Spaltenüberschriften anlegen

      vValue # '';
      // Hat dieser Eintrag nur ein Werteelement? Dann einfache Darstellung
      if (HasValueNode(vNode)) then begin

        // Unterknotenrekursion für Value Elemente
        FillDLFromXML(aDL , vNode, var vValue, var aMapping);
        aDL->WinLstCellSet(vValue, vColumn,_WinLstDatLineLast);

        // Datamapping füllen
        vLine # aDL->WinLstDatLineInfo(_WinLstDatInfoCount);
        if (vLine = 0) then vLine # 1;
        arraySet(vLine, vColumn, var aMapping, vNode);

      end else begin
        aDL->WinLstDatLineAdd('');
        aDL->WinLstCellSet(vElement, vColumn,_WinLstDatLineLast);
        if (vHdl<>0) then vHdl->wpFontAttr # _winFontAttrB;

        // Datamapping füllen
        vLine # aDL->WinLstDatLineInfo(_WinLstDatInfoCount);
        if (vLine = 0) then vLine # 1;
        arraySet(vLine, vColumn, var aMapping, vNode);

        // Unterknotenrekursion nach Knotenelementen
        FillDLFromXML(aDL , vNode, var vValue, var aMapping);
      end;

    end; // if (vNode->spID = _XmlNodeElement)

  END; // Itemloop

  // Custom Wert der Liste mit der ersten Node binden
  aDL->wpCustom # CnvAi(aXMLobj);
end; // sub FillDLFromXML




//========================================================================
//  sub arrayGet(aY : int; aX : int; var aMapping : int[]) : int
//    gibt den Wert einer Zelle zurück
//========================================================================
sub arrayGet(aY : int; aX : int; var aMapping : int[]) : int
begin
  return aMapping[(aY-1) * cMaxWidth + aX];
end;



//========================================================================
//  sub arraySet(aY : int; aX : int; var aMapping : int[]; aVal : int) : int
//    Setzt den Wert einer Zelle
//========================================================================
sub arraySet(aY : int; aX : int; var aMapping : int[]; aVal : int) : int
begin
  aMapping[(aY-1) * cMaxWidth + aX] # aVal;
end;



//========================================================================
//  sub DebugNode(aNode : handle)
//    gibt den Inhalt und Typ eines XML Nodes aus
//========================================================================
sub DebugBindingPrint
(
  var aMapping : int[];
  aRowCnt : int;
)
local begin
  vRow  : int;
  vCol  : int;
  i     : int;
  vLine : alpha(4000);
end;
begin

  FOR vRow # 1 loop inc(vRow) WHILE (vRow <= aRowCnt) DO BEGIN
    FOR vCol # 1 loop inc(vCol) WHILE (vCol <= cMaxWidth) DO BEGIN
      vLine # vLine + CnvAi(arrayGet(vRow,vCol,var aMapping),_FmtInternal,0,10);
    END;
    debug(vLine);
    vLine # '';
  END;

end; // sub DebugBinding




//========================================================================
//  sub DebugNode(aNode : handle)
//    gibt den Inhalt und Typ eines XML Nodes aus
//========================================================================
sub DebugNode(aNode : handle)
begin
  debug('  ------------------------------------------------------------------');
  debug('  Node Handle:' + CnvAi(aNode));
  if (aNode = 0) then
    return;

  case (aNode->spID) of
    _XmlNodeElement : begin
       debug('  spID = _XmlNodeElement');
       debug('  spName = ' + StrCnv(aNode->spName,_StrFromUTF8));
    end;
    _XmlNodeText    : begin
       debug('  spID = _XmlNodetext');
       debug('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
    end;

    _XmlNodeDocument : begin
       debug('  spID = _XmlNodeDocument');
    end;

    _XmlNodeAttribute : begin
       debug('  spID = _XmlNodeAttribute');
       debug('  spName = ' + StrCnv(aNode->spName,_StrFromUTF8));
       debug('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
    end;

    _XmlNodeComment : begin
       debug('  spID = _XmlNodeComment');
       debug('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
    end;

    otherwise begin
      debug('  umbekannter Notetyp');
    end;

  end;
  debug('  ------------------------------------------------------------------');

end;



//=========================================================================
// Erweiterte Subprozeduren [07.01.2010/PW]
//=========================================================================

//=========================================================================
// AppendNode
//        Append generic XML Node element, with optional text node
//=========================================================================
sub AppendNode ( aParent : handle; aName : alpha; opt aText : alpha(250); ) : handle
local begin
  vNode : handle;
end
begin
  if ( aParent->spId != _xmlNodeElement ) and ( aParent->spId != _xmlNodeDocument ) then
    RETURN 0;

  aName # StrCnv( aName, _strToANSI );
  aText # StrCnv( aText, _strToANSI );
  vNode # aParent->CteInsertNode( aName, _xmlNodeElement, null );

  if ( aText != '' ) then
    vNode->CteInsertNode( null, _xmlNodeText, aText );

  RETURN vNode;
end;


//=========================================================================
// AppendTextNode
//        Append text node
//=========================================================================
sub AppendTextNode ( aParent : handle; aText : alpha(250); ) : handle
begin
  if ( aParent->spId != _xmlNodeElement ) then
    RETURN 0;

  aText # StrCnv( aText, _strToANSI );
  RETURN aParent->CteInsertNode( null, _xmlNodeText, aText );
end;


//=========================================================================
// AppendAttributeNode
//        Append attribute node
//=========================================================================
sub AppendAttributeNode ( aParent : handle; aName : alpha; aText : alpha(250); ) : handle
begin
  if ( aParent->spId != _xmlNodeElement ) then
    RETURN 0;

  aName # StrCnv( aName, _strToANSI );
  aText # StrCnv( aText, _strToANSI );
  RETURN aParent->CteInsertNode( aName, _xmlNodeAttribute, aText, _cteAttrib );
end;


//=========================================================================
// GetChildNode
//        Get element's child node
//=========================================================================
sub GetChildNode ( aParent : handle; aName : alpha; ) : handle
begin
  if ( aParent->spId != _xmlNodeElement ) then
    RETURN 0;

  aName # StrCnv( aName, _strToUTF8 );
  RETURN aParent->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, aName  );
end;


//=========================================================================
// GetTextValue
//        Get element's text value
//=========================================================================
sub GetTextValue ( aParent : handle; opt aName : alpha; ) : alpha
begin
  if ( aParent->spId = _xmlNodeElement ) then begin
    if ( aName != '' ) then // child node
      RETURN GetTextValue( aParent->GetChildNode( aName ) );

    aParent # aParent->CteRead( _cteChildList | _cteFirst );
    if ( aParent = 0 ) or ( aParent->spId != _xmlNodeText ) then
      RETURN '';

    RETURN StrCnv( aParent->spValueAlpha, _strFromUTF8 );
  end
  else if ( aParent->spId = _xmlNodeText ) then
    RETURN StrCnv( aParent->spValueAlpha, _strFromUTF8 );
  else
    RETURN '';
end;


//=========================================================================
// GetAttributeValue
//        Get element's attribute value
//=========================================================================
sub GetAttributeValue ( aParent : handle; aName : alpha; ) : alpha
local begin
  vNode : handle;
end
begin
  if ( aParent->spId != _xmlNodeElement ) then
    RETURN '';

  aName # StrCnv( aName, _strToUTF8 );
  vNode # aParent->CteRead( _cteAttribList | _cteSearch | _cteFirst, 0, aName  );

  if ( vNode = 0 ) then
    RETURN ''

  RETURN StrCnv( vNode->spValueAlpha, _strFromUTF8 );
end;

//=========================================================================
//=========================================================================
//=========================================================================