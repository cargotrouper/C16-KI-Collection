@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_XML
//                      OHNE E_R_G
//  Info
//
//
//  08.04.2008  AI  Erstellung der Prozedur
//  10.08.2009  ST  Umstellung auf cteXML Baum
//  28.05.2021  ST  AppendNode subs, aText von 1000 auf 4000 und 300 auf 1000  geändert
//  21.04.2022  ST  Infobereich aktualisiert
//  2023-03-08  DS  CloseXml, DebugXmlLoad
//  2023-05-30  DB  Bei allen GetValue Funktionen wird der var aFld Wert nun initial auf NULL gesetzt. GetValueB kann 'y', 'Y' und '1' als true erkennen.
//
//  Subprozeduren
//    SUB CloseXml(var aCte : handle);
//    SUB NewNode(aRoot : handle; aName : alpha; aValue : Alpha) : handle;
//    SUB NewNodeB(aRoot : handle; aName : alpha; aValue : Logic) : handle;
//    SUB NewNodeD(aRoot : handle; aName : alpha; aValue : Date) : handle;
//    SUB GetType(aY : int) : alpha   /// VERALTET
//    SUB GetNodeType(aNode : handle) : alpha
//    SUB GetValue(aNode : handle; var aFld : alpha) : logic
//    SUB GetValueI(aNode : handle; var aFld : int) : logic
//    SUB GetValueLong(aNode : handle; var aFld : bigint) : logic
//    SUB GetValueC(aNode : handle; var aFld : Caltime) : logic
//    SUB GetValueI16(aNode : handle; var aFld : word) : logic
//    SUB GetValueF(aNode : handle; var aFld : float) : logic
//    SUB GetValueB(aNode : handle; var aFld : logic) : logic
//    SUB GetValueD(aNode : handle; var aFld : date) : logic
//    SUB GetValueT(aNode : handle; var aFld : time) : logic
//    SUB SetDepth(aParent : handle; var aMaxLvl : int; var aElemCnt : int) : int;
//    SUB ImportXML(aPathToFile : alpha(1000); var vLevel : int; var vElems : int) : handle
//    SUB HasValueNode(aParent : handle) : logic
//    SUB FillDLFromXML(aDL : int; aXMLobj : handle;  var aVal : alpha; var aMapping : int[]; ) : logic;
//    SUB arraySet(aY : int; aX : int; var aMapping : int[]; aVal : int) : int;
//    SUB arrayGet(aY : int; aX : int; var aMapping : int[]) : int
//    SUB DebugXmlLoad(aXmlLoadResult : int;) : alpha;
//    SUB DebugBindingPrint(  var aMapping : int[];  aRowCnt : int;)
//    SUB DebugPuffer(aFile : int)
//
//    sub CreateNode ( aName : alpha; opt aText : alpha(300) ) : handle
//    sub Append ( aParent : handle; aNode : handle ) : handle
//    sub AppendComment ( aParent : handle; aText : alpha(300) ) : handle
//    sub AppendNode ( aParent : handle; aName : alpha; opt aText : alpha(250) ) : handle
//    sub AppendTextNode ( aParent : handle; aText : alpha(250) ) : handle
//    sub AppendAttributeNode ( aParent : handle; aName : alpha; aText : alpha(250) ) : handle
//    sub GetChildNode ( aParent : handle; aName : alpha ) : handle
//    sub GetTextValue ( aParent : handle; opt aName : alpha ) : alpha
//    sub GetAttributeValue ( aParent : handle; aName : alpha ) : alpha
//    sub GetAttributeValueOrBreak( aParent : handle; aName : alpha; var aValue : alpha) : logic
//========================================================================
@I:Def_Global

local begin
  gI        : int;
end;
define begin
  cMaxWidth : 300
end;


// Prototypen
declare SetDepth(aParent : handle; var aMaxLvl : int; var aElemCnt : int) : int;
declare ImportXML(aPathToFile : alpha(1000); var vLevel : int; var vElems : int) : handle
declare HasValueNode(aParent : handle) : logic
declare FillDLFromXML(aDL : int; aXMLobj : handle;  var aVal : alpha; var aMapping : int[]; ) : logic;
declare arraySet(aY : int; aX : int; var aMapping : int[]; aVal : int) : int;
declare arrayGet(aY : int; aX : int; var aMapping : int[]) : int
declare DebugBindingPrint(  var aMapping : int[];  aRowCnt : int;)
declare DebugPuffer(aFile : int)



/*
========================================================================
2023-03-08  DS                                               2327/15

Schließt ein XML Dokument und gibt Speicher wieder frei.
========================================================================
*/
sub CloseXml(var aCte : handle);
begin
  if (aCte=0) then RETURN;
  aCte->CteClear(true);
  aCte->CteClose();
  aCte # 0;
end;



//========================================================================
//  NewNode
//
//========================================================================
sub NewNode(aRoot : handle; aName : alpha; aValue : alpha(4000)) : handle;
local begin
  vNode : handle;
end;
begin


  /* // ST 2010-09-21: Alte Version zu Ansi raus
  aName   # StrCnv(aName, _StrToANSI);
  aValue  # StrCnv(aValue, _StrToANSI);
  */

/*
  // ST 2010-09-21: Alte Version zu UTF8 rein
  aName   # StrCnv(aName, _StrToUTF8);
  aValue  # StrCnv(aValue, _StrToUTF8);
*/

  // ST 2011-08-02: Alte Version zu UTF8 rein raus, ohne
  //                Konvertierung, da die Konvertierung beim Speichern jetzt funktioniert
  aName   # aName;
  aValue  # aValue;


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
  aFld # NULL;
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
//  sub GetValueI(aNode : handle; var aFld : int) : logic
//    Gibt den Wert eines XML Elements zurück
//========================================================================
sub GetValueI(aNode : handle; var aFld : int) : logic
local begin
  vNode : handle;
end;
begin
  aFld # NULL;
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
//  sub GetValueLong(aNode : handle; var aFld : bigint) : logic
//    Gibt den Wert eines XML Elements zurück
//========================================================================
sub GetValueLong(aNode : handle; var aFld : bigint) : logic
local begin
  vNode : handle;
end;
begin
  aFld # NULL;
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      aFld #  Cnvba(StrCnv(vNode->spValueAlpha,_StrFromUTF8));
      return true;
    end;
  end;
  return false;
end;


//========================================================================
//  sub GetValueC(aNode : handle; var aFld : alpha) : logic
//    Gibt den Wert eines XML Elements zurück für CALTIME
//========================================================================
sub GetValueC(aNode : handle; var aFld : Caltime) : logic
local begin
  vNode       : handle;
  vA          : alpha;
  vY, vMo, vD : int;
  vH, vMi, vS : int;
end;
begin
  aFld # NULL;
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      // 12345678901234567890
      // 2017-12-24T20:00:00
      vA # StrCnv(vNode->spValueAlpha,_StrFromUTF8);
      vY  # cnvia(StrCut(vA,1,4));
      vMo # cnvia(StrCut(vA,6,2));
      vD  # cnvia(StrCut(vA,9,2));
      vH  # cnvia(StrCut(vA,12,2));
      vMi # cnvia(StrCut(vA,15,2));
      vS  # cnvia(StrCut(vA,18,2));
      aFld->vpDate  # DateMake(vD, vMo, vY);
      aFld->vpTime  # TimeMake(vH, vMi, vS, 00);
//      aFld #  Cnvca(StrCnv(vNode->spValueAlpha,_StrFromUTF8), _FmtCalTimeRFC);
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
  aFld # NULL;
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
  aFld # NULL;
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
  aFld # NULL;
  if (aNode <> 0) then begin
    vNode # aNode->CteRead(_CteFirst  | _CteChildList)
    if (vNode <> 0) AND (vNode->spID = _XmlNodeText) then begin
      aFld # (StrCnv(vNode->spValueAlpha,_StrFromUTF8 | _StrLower) = 'y') or (StrCnv(vNode->spValueAlpha,_StrFromUTF8) = '1');
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
  aFld # NULL;
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
  aFld # NULL;
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


    if (vNode->spID = _XmlNodeElement) then begin
      vNode->spCustom # CnvAi(CnvIa(aParent->spCustom)+1);
      aMaxLvl # CnvIa(vNode->spCustom);
      //aElemCnt # aMaxLvl+1;
      inc(aElemCnt);
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
  vValue  : alpha(4000);
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
        // Namen des Elternelements beachten, da so die Namensgebung der
        // Felder Namensraum übergreigend sind
        vA # StrCnv(vElement + ' ('+ vNode->spParent->spName+ ')',_StrLetter);
        vHdl # Winsearch(aDL, vA);
        if (vHdl=0) then begin
          if (gI = 0) then gI # 1;
          vHdl # Winsearch(aDL, 'col'+cnvai(gI));
          gI # gI + 1;
        end;
        // ggf. Spalte "anlegen"
        if (vHdl<>0) then begin
          vHdl->wpname    # StrCut(vA,1,20);
          vHdl->wpCaption # vElement + ' ('+ vNode->spParent->spName+')';
          vHdl->wpVisible # y;
          vDepth # 30+255 - (CnvIa(vNode->spCustom) * 30);
          vHdl->wpClmColBkg # ((((vDepth<<8)+ vDepth)<<8)+ vDepth);
          if (vHdl->wpcustom='') then begin
            vHdl->wpcustom # cnvai(gI-1);
          end;

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
local begin
end;
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



/*
========================================================================
2023-03-08  DS                                               2327/15

Hilfsfunktion um Fehler beim Laden von XML Dokumenten zu debuggen.

Doku in C16 zu dem Thema scheint komplett unbrauchbar, weil falsch oder
veraltet.
Besser hieran orientieren (auch Quelle dieses Codes):

https://www.vectorsoft.de/blog/2011/07/XML-Verarbeitung/
========================================================================
*/
sub DebugXmlLoad(
  aXmlLoadResult : int;
) : alpha;
local begin
  vLocal : int;
  vRetVal : alpha(4096);
end
begin
  
  if (aXmlLoadResult <> _ErrOK) then
  begin
    // Fehler bei XmlLoad() aufgetreten
  
    if aXmlLoadResult <= _ErrXMLWarning and aXmlLoadResult >= _ErrXMLFatal then
    begin
      // wenn es ein XML-Fehler ist, kann Funktion XMLError() Information zum Fehler liefern
      vRetVal #
        'Fehler beim Laden von XML-Daten:' + cCrlf2 +
        '_XMLErrorText: ' + XMLError(_XMLErrorText) + cCrlf +
        '_XMLErrorCode: ' + XMLError(_XMLErrorCode) + cCrlf +
        '_XMLErrorLine: ' + XMLError(_XMLErrorLine) + cCrlf +
        '_XMLErrorColumn: ' + XMLError(_XMLErrorColumn)
      ;
    end
    else
    begin
      // wenn es kein XML Fehler ist:
      vRetVal #
        'Erhaltener Wert ' + aint(aXmlLoadResult) + ' beim Aufruf von DebugXmlLoad() ist kein bekannter Fehlercode von XmlLoad().' + cCrlf2 +
        'Daher kann hier keine DebugInformation geliefert werden.'
      ;
    end
  end
  
  return vRetVal;
  
end



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
       debug('  spCustom = ' + StrCnv(aNode->spCustom,_StrFromUTF8));
    end;
    _XmlNodeText    : begin
       debug('  spID = _XmlNodetext');
       debug('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
       debug('  spCustom = ' + StrCnv(aNode->spCustom,_StrFromUTF8));
    end;

    _XmlNodeDocument : begin
       debug('  spID = _XmlNodeDocument');
    end;

    _XmlNodeAttribute : begin
       debug('  spID = _XmlNodeAttribute');
       debug('  spName = ' + StrCnv(aNode->spName,_StrFromUTF8));
       debug('  spValueAlpha = ' + StrCnv(aNode->spValueAlpha,_StrFromUTF8));
       debug('  spCustom = ' + StrCnv(aNode->spCustom,_StrFromUTF8));
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


//========================================================================
//  sub DebugPuffer(aFile : int)
//      gibt alle Feldpuffer als Debugtext aus
//========================================================================
sub DebugPuffer(aFile : int)
local begin
  vTds,vTdsCnt : int;
  vFld : int;
  vLine : alpha(4000);
end;
begin

  vTdsCnt # FileInfo(aFile,_FileSbrCount);

  debug('------PUFFER VON '+ Aint(aFile)+ '----------------------------------------');
  FOR vTds # 1; loop inc(vTds) while (vTds<=vTdsCnt) DO BEGIN

    vFld # 1;
    WHILE (FldInfo(aFile,vTds,vFld,_FldExists) = 1) DO BEGIN

      vLine # '   ' + FldName(aFile,vTds,vFld) + ' : ';

      CASE FldInfo(aFile,vTds,vFld,_FldType) OF
        _TypeAlpha    : vLine # vLine + FldAlpha(aFile,vTds,vFld);
        _TypeBigInt   : vLine # vLine + CnvAb(FldBigint(aFile,vTds,vFld)  );
        _TypeByte     : vLine # vLine + CnvAi(FldInt(aFile,vTds,vFld)  );
        _TypeDate     : vLine # vLine + CnvAd(FldDate(aFile,vTds,vFld)  );
        _TypeDecimal  : vLine # vLine + CnvAM(FldDecimal(aFile,vTds,vFld)  );
        _TypeFloat    : vLine # vLine + CnvAf(FldFloat(aFile,vTds,vFld)  );
        _TypeInt      : vLine # vLine + CnvAi(Fldint(aFile,vTds,vFld)  );
        _TypeLogic    : vLine # vLine + CnvAi(CnvIl(FldLogic(aFile,vTds,vFld))  );
        _TypeTime     : vLine # vLine + CnvAT(FldTime(aFile,vTds,vFld)  );
        _TypeWord     : vLine # vLine + CnvAi(FldWord(aFile,vTds,vFld)  );
      END;
      debug(vLine);
      vFld # vFld + 1;
    END;

  END;

end;


//========================================================================

//=========================================================================
// Erweiterte Subprozeduren [07.01.2010/PW]
//=========================================================================

//=========================================================================
// CreateNode
//        Create generic XML Node element, with optional text node
//=========================================================================
sub CreateNode ( aName : alpha; opt aText : alpha(300) ) : handle
local begin
  vNode : handle;
end
begin
  aName # StrCnv( aName, _strToUTF8 );
  aText # StrCnv( aText, _strToUTF8 );
  vNode # CteOpen( _cteNode ); // _cteChildList | _cteAttribList | _cteAttribTree
  vNode->spId # _xmlNodeElement;
  vNode->spName # aName;

  if ( aText != '' ) then
    vNode->CteInsertNode( null, _xmlNodeText, aText );

  RETURN vNode;
end;


//=========================================================================
// Append
//        Append XML Node element
//=========================================================================
sub Append ( aParent : handle; aNode : handle ) : handle
begin
  aParent->CteInsert( aNode, _cteLast );
  RETURN aNode;
end;


//=========================================================================
// AppendComment
//        Append comment XML Node element
//=========================================================================
sub AppendComment ( aParent : handle; aText : alpha(300) ) : handle
local begin
  vNode : handle;
end
begin
  if ( aParent->spId != _xmlNodeElement ) and ( aParent->spId != _xmlNodeDocument ) then
    RETURN 0;

//  aText # StrCnv( aText, _strToUTF8 );
//  vNode # aParent->CteInsertNode( aText, _XmlNodeComment, null );
  vNode # aParent->CteInsertNode( '', _XmlNodeComment, aText );   // 16.08.2018 AH : Fix

  RETURN vNode;
end;


//=========================================================================
// AppendNode
//        Append generic XML Node element, with optional text node
//=========================================================================
sub AppendNode ( aParent : handle; aName : alpha; opt aText : alpha(4000) ) : handle
local begin
  vNode : handle;
end
begin
  if ( aParent->spId != _xmlNodeElement ) and ( aParent->spId != _xmlNodeDocument ) then
    RETURN 0;

//  aName # StrCnv( aName, _strToUTF8 );
//  aText # StrCnv( aText, _strToUTF8 );
  vNode # aParent->CteInsertNode( aName, _xmlNodeElement, null );

  if ( aText != '' ) then
    vNode->CteInsertNode( null, _xmlNodeText, aText );

  RETURN vNode;
end;


//=========================================================================
// AppendTextNode
//        Append text node
//=========================================================================
sub AppendTextNode ( aParent : handle; aText : alpha(1000) ) : handle
begin
  if ( aParent->spId != _xmlNodeElement ) then
    RETURN 0;

//  aText # StrCnv( aText, _strToUTF8 );

  RETURN aParent->CteInsertNode( null, _xmlNodeText, aText );
end;


//=========================================================================
// AppendAttributeNode
//        Append attribute node
//=========================================================================
sub AppendAttributeNode ( aParent : handle; aName : alpha; aText : alpha(1000) ) : handle
begin
  if ( aParent->spId != _xmlNodeElement ) then
    RETURN 0;

//  aName # StrCnv( aName, _strToUTF8 );
//  aText # StrCnv( aText, _strToUTF8 );
  RETURN aParent->CteInsertNode( aName, _xmlNodeAttribute, aText, _cteAttrib );
end;


//=========================================================================
// GetChildNode
//        Get element's child node
//=========================================================================
sub GetChildNode ( aParent : handle; aName : alpha ) : handle
begin
  if ( aParent->spId != _xmlNodeElement ) and ( aParent->spId != _xmlNodeDocument ) then
    RETURN 0;

  aName # StrCnv( aName, _strToUTF8 );
  RETURN aParent->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, aName  );
end;


//=========================================================================
// GetTextValue
//        Get element's text value
//=========================================================================
sub GetTextValue ( aParent : handle; opt aName : alpha ) : alpha
begin
  if (aParent <= 0) then RETURN '';
  
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
sub GetAttributeValue ( aParent : handle; aName : alpha ) : alpha
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
// GetAttributeValueOrBreak
//        Get element's attribute value
//=========================================================================
sub GetAttributeValueOrBreak( aParent : handle; aName : alpha; var aValue : alpha) : logic
local begin
  vNode : handle;
end
begin
  if ( aParent->spId != _xmlNodeElement ) then
    RETURN false;

  aName # StrCnv( aName, _strToUTF8 );
  vNode # aParent->CteRead( _cteAttribList | _cteSearch | _cteFirst, 0, aName  );

  if ( vNode = 0 ) then
    RETURN false;

  aValue # StrCnv( vNode->spValueAlpha, _strFromUTF8 );

  RETURN true;
end;


//=========================================================================
//=========================================================================
//=========================================================================