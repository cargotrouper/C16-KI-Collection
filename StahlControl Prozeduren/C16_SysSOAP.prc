@A++
//===== Business-Control =================================================
//
//  Prozedur  C16_SysSOAP
//                    OHNE E_R_G
//
//  06.02.2013  AI  Installation
//  18.11.2015  AH  Umbau "RqsSend" mit ParaHandle
//  13.08.2019  ST  SOAP Verbindungen per IPV6 priorisiert
//  14.01.2021  ST  JsonPara: Ersestzung "&" durch "&amp;"
//  06.05.2022  ST  Temporäre Sonderlocke HWE wegen Netzwerkproblemen 2343/41/1
//
// sub Init // public
// sub Term // public
// sub RqsHeader // public
// sub RqsBody // public
// sub RspHeader // public
// sub RspBody // public
// sub ElementAdd // public
// sub RqsHeaderElementAdd // public
// sub RqsHeaderClear // public
// sub RqsBodyElementAdd // public
// sub RspHeaderElementGet
// sub RspBodyElementGet
// sub RqsSend // public
// sub RspRecv // public
// sub Request // public
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// +                                                                                                    +
// + SOAP (Simple Object Access Protocol)                                                               +
// +                                                                                                    +
// + Dokumentation                                                                                      +
// +                                                                                                    +
// +   SOAP 1.1 : <: http://www.w3.org/TR/2000/NOTE-SOAP-20000508/ :>                                   +
// +   SOAP 1.2 : <: http://www.w3.org/TR/2007/REC-soap12-part1-20070427/ :>                            +
// +   XML-Schema : <: http://www.w3.org/TR/xmlschema-2/ :>                                             +
// +   SOAP-Style & -Use : <: http://www.ibm.com/developerworks/webservices/library/ws-whichwsdl/ :>    +
// +                                                                                                    +
// + Änderungshistorie                                                                                  +
// +                                                                                                    +
// +   v1.3 - 30.01.13 - vectorsoft                                                                     +
// +     - Client                                                                                       +
// +        - RqsBody(), RqsHeader(), RspBody() und RspHeader() hinzugefügt.                            +
// +        - RqsSend(), RspRecv() und Request() dokumentiert.                                          +
// +        - ValueAddTime(), ValueGetTime(), ValueAddDateTime(), ValueGetDateTime(): Verarbeitung von  +
// +          Hunderstsel- bzw. Millisekunden korrigiert.                                               +
// +                                                                                                    +
// +   v1.2 - 25.01.13 - vectorsoft                                                                     +
// +     - Client                                                                                       +
// +        - _SOAP.Style-Optionen entfernt.                                                            +
// +                                                                                                    +
// +   v1.1 - 24.01.13 - vectorsoft                                                                     +
// +     - Client                                                                                       +
// +        - RspRecv() - Datentyp "application/xml" als gültig hinzugefügt.                            +
// +        - ValueAdd...() und ValueGet()... für Float, Double, Byte, Short, Long, Date, Time und      +
// +          DateTime hinzugefügt.                                                                     +
// +                                                                                                    +
// +   v1.0 - 19.12.12 - vectorsoft                                                                     +
// +     - Client: Erstimplementierung                                                                  +
// +       - Init() - _SOAP.Style-Optionen werden nicht berücksichtigt                                  +
// +       - RspRecv() - Weiterleitungen wird nicht gefolgt. Fehler _SOAP.ErrHTTPStatus wird            +
// +         zurückgegeben.                                                                             +
// +                                                                                                    +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

@A+
@C+
@I:C16_SysSOAPInc

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Konfigurationen und Definitionen                               +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

define // private
{
  // Speichergrößenallokierung
  sSOAP.MemSizeAlloc        : _MemAutoSize
  // Speichergrößenlimit [Byte]
  sSOAP.MemSizeLimit        : 1024 * 1024 * 4 // 4 MB
  // Zeichensatz
  sSOAP.Charset             : _CharsetUTF8
  sSOAP.CharsetStr          : 'UTF-8'
  // Namensräume
  sSOAP.Namespace1.1        : 'http://schemas.xmlsoap.org/soap/envelope/'
  sSOAP.Namespace1.2        : 'http://www.w3.org/2003/05/soap-envelope'
  sSOAP.NamespaceEnc1.1     : 'http://schemas.xmlsoap.org/soap/encoding/'
  sSOAP.NamespaceEnc1.2     : 'http://www.w3.org/2001/12/soap-encoding'
  sSOAP.NamespaceXSD        : 'http://www.w3.org/2001/XMLSchema'
  sSOAP.NamespaceXSI        : 'http://www.w3.org/2001/XMLSchema-instance'
  // Content-Type
  sSOAP.ContentType1.1      : 'text/xml'
  sSOAP.ContentType1.2      : 'application/soap+xml'
  // Datentypen
  sSOAP.TypeString          : 'string'
  sSOAP.TypeBoolean         : 'boolean'
  sSOAP.TypeFloat           : 'float'         // 32-Bit
  sSOAP.TypeDouble          : 'double'        // 64-Bit
  sSOAP.TypeByte            : 'byte'          //  8-Bit signed
  sSOAP.TypeUnsignedByte    : 'unsignedByte'  //  8-Bit unsigned
  sSOAP.TypeShort           : 'short'         // 16-Bit signed
  sSOAP.TypeUnsignedShort   : 'unsignedShort' // 16-Bit unsigned
  sSOAP.TypeInt             : 'int'           // 32-Bit signed
  sSOAP.TypeLong            : 'long'          // 64-Bit signed
  sSOAP.TypeDate            : 'date'
  sSOAP.TypeTime            : 'time'
  sSOAP.TypeDateTime        : 'dateTime'


  Debug(a)    : Lib_Debug:Dbg_Debug(a)
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Instanzdaten                                                   +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

global SOAP
{
  gHost                 : alpha;        // Host
  gPort                 : word;         // Port
  gResource             : alpha(1024);  // Ressource

  gNamespace            : alpha;        // Namensraum

  gOptionsSocket        : int;          // Optionen für SckConnect()
  gTimeoutSocket        : int;          // Timeout für SckConnect()

  gSOAPVersion          : int;          // Protokollversion (_SOAP.Version...)
  gSOAPUse              : int;          // Nachrichtentypisierung (_SOAP.Use...)

  gSOAPNamespace        : alpha;        // SOAP-Namensraum
  gSOAPNamespacePrefix  : alpha;        // SOAP-Namensraumprefix
  gSOAPNamespaceEnc     : alpha;        // SOAP-Encoding-Namensraum
  gSOAPContentType      : alpha;        // SOAP-Datentyp

  gSck                  : handle;       // Socket-Verbindung
  gMem                  : handle;       // Speicherblock für Nachricht

  gFault                : logic;        // Fehler

  gCteNodeRqsHeader     : handle;       // Anfrage-Header
  gCteNodeRqsBody       : handle;       // Anfrage-Body

  gCteNodeRspHeader     : handle;       // Antwort-Header
  gCteNodeRspBody       : handle;       // Antwort-Body
  gCteNodeRspFault      : handle;       // Antwort-Fehler
}



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub ADD2MEM(vA : alpha(1000); var vPos : int);
begin
  vA # vA + StrChar(10);
  gMem->memWriteStr(vPos + 1, vA, _CharsetC16_1252);
  vPos # vPos + StrLen(vA);
end;


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub MYDEBUG();
local begin
  vPos  : int;
  vFile : int;
end;
begin

vFile # FSIOpen('e:\debug\debug.txt',_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
FsiWriteMem(vFile,gMem,1,gMem->spSize);
FSIClose(vFile);
Lib_debug:dbg_debug('ENDE');

if (2=1) {
  vPos # 0;
ADD2MEM('<?xml version="1.0" encoding="utf-8"?>', var vPos);
ADD2MEM('<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">', var vPos);
ADD2MEM('<s:Body>', var vPos);
ADD2MEM('<TestCall_1 xmlns="http://tempuri.org/">', var vPos);
ADD2MEM('<aArgtext>hallo</aArgtext>', var vPos);
ADD2MEM('</TestCall_1>', var vPos);
ADD2MEM('</s:Body>', var vPos);
ADD2MEM('</s:Envelope>', var vPos);

gMem->MemResize(vPos);

vFile # FSIOpen('e:\debug\debug.txt',_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
FsiWriteMem(vFile,gMem,1,gMem->spSize);
FSIClose(vFile);
Lib_debug:dbg_debug('ENDE');
}

end;


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + URI zerlegen                                                   +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub HTTP.URISplit // private
(
  aURI                  : alpha(4096);  // URI
  var vScheme           : alpha;        // Schema
  var vHost             : alpha;        // Host
  var vPort             : word;         // Port
  var vResource         : alpha;        // Ressource
  opt aDefault          : logic;        // Standardwerte verwenden
) : logic
local
{
    tPosBegin           ,
    tPosEnd             : int;
    tHost               : alpha(4096);
}
{
  if (StrFind(aURI, '\', 1)>0)
    RETURN false;

  vScheme # '';
  vHost # '';
  vPort # 0;
  vResource # '';

  tPosBegin # 1;

  // Schema suchen
  tPosEnd # StrFind(aURI, '//', tPosBegin);
  // Schema gefunden
  if (tPosEnd > 0)
  {
    // Schema übernehmen
    vScheme # StrCnv(StrCut(aURI, tPosBegin, tPosEnd - tPosBegin - 1), _StrLower);

    tPosBegin # tPosEnd + 2;
  }
  else
  {
    if (aDefault)
      vScheme # 'http';
  }

  // Ressource suchen
  tPosEnd # StrFind(aURI, '/', tPosBegin);
  // Ressource gefunden
  if (tPosEnd > 0)
  {
    // Host ermitteln
    tHost # StrCut(aURI, tPosBegin, tPosEnd - tPosBegin);
    // Resource ermitteln
    vResource # StrCut(aURI, tPosEnd, 4096);
  }
  else
  {
    // Host ermitteln
    tHost # StrCut(aURI, tPosBegin, 4096);
    // Resource ermitteln
    if (aDefault)
      vResource # '/';
  }

  // Port suchen
  tPosBegin # StrFind(tHost, ':', 1);
  // Port gefunden
  if (tPosBegin > 0)
  {
    // Host ermitteln
    vHost # StrCut(tHost, 1, tPosBegin - 1);
    // Port ermitteln
    vPort # CnvIA(StrCut(tHost, tPosBegin + 1, 80));
  }
  else
  {
    // Host ermitteln
    vHost # tHost;
    // Port ermitteln
    if (aDefault)
    {
      switch (vScheme)
      {
        // Standardport für HTTP
        case 'http'  : vPort # 80;
        // Standardport für HTTPS
        case 'https' : vPort # 443;
      }
    }
  }
  
  RETURN true;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Konstruktor                                                    +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub Init // public
(
  aURILocation          : alpha(1024);  // Adresse
  aNamespace            : alpha;        // Namensraum
  opt aOptions          : int;          /* Optionen (_SOAP....)
                                           _SOAP.Version1.1    - Protokollversion 1.1 verwenden (Standard)
                                           _SOAP.Version1.2    - Protokollversion 1.2 verwenden
                                           _SOAP.UseLiteral    - Nachrichtentypisierung "Literal" verwenden (Standard)
                                           _SOAP.UseEncoded    - Nachrichtentypisierung "Encoded" verwenden
                                        */
  opt aOptionsSocket    : int;          // Socket-Optionen (_Sck...)
  opt aTimeoutSocket    : int;          // Socket-Timeout [ms]
  opt aIP4Only          : logic;
)
: handle;                               /* Instanz (> 0) /
                                           Fehler (< 0)
                                             _Err.Sck...
                                        */
  local
  {
    tScheme             : alpha;
    tHost               : alpha;
    tPort               : word;
    tResource           : alpha(1024);
    tSck                : handle;
    tSOAP               : handle;
    tErr                : int;
  }

{

  // Adresse zerlegen
  if (HTTP.URISplit(aURILocation, var tScheme, var tHost, var tPort, var tResource, true)=false)
    RETURN -1;

  // HTTPS und keine Socket-Verschlüsselungsoption gesetzt
  if (tScheme = 'https' and aOptionsSocket & (_SckSSLv2 | _SckSSLv3 | _SckTLSv1) = 0)
    // Socket-Verschlüsselungsoptionen setzen
    aOptionsSocket # _SckTLSv1 | _SckSSLv3;

  // Kein Socket-Timeout gesetzt
  if (aTimeoutSocket = 0)
  {
    // Standard-Socket-Timeout setzen
    aTimeoutSocket # 5000;
    
    // ST 2022-05-06 2343/41/1
    // Handtke Wiros braucht längere Timeouts, da aktuell Netzwerkprobleme vorliegen
    if (Set.Installname = 'HWE')
      aTimeoutSocket # 10000;
  }


  // Socket-Verbindung herstellen
  if (aIP4Only)
    tSck # SckConnect('ip4:' + tHost, tPort, aOptionsSocket, aTimeoutSocket)
  else
    tSck # SckConnect('ip6f:' + tHost, tPort, aOptionsSocket, aTimeoutSocket);
  // Socket-Verbindung hergestellt
  if (tSck > 0)
  {
    tSOAP # VarAllocate(SOAP);

    gHost # tHost;
    gPort # tPort;
    gResource # tResource;

    gNamespace # aNamespace;

    gOptionsSocket # aOptionsSocket;
    gTimeoutSocket # aTimeoutSocket;

    switch (aOptions & (_SOAP.Version1.1 | _SOAP.Version1.2))
    {
      case _SOAP.Version1.2 : gSOAPVersion # _SOAP.Version1.2;
      default               : gSOAPVersion # _SOAP.Version1.1;
    }

    switch (aOptions & (_SOAP.UseLiteral | _SOAP.UseEncoded))
    {
      case _SOAP.UseEncoded : gSOAPUse # _SOAP.UseEncoded;
      default               : gSOAPUse # _SOAP.UseLiteral;
    }

    switch (gSOAPVersion)
    {
      case _SOAP.Version1.1 :
      {
        gSOAPNamespace # sSOAP.Namespace1.1;
        gSOAPNamespaceEnc # sSOAP.NamespaceEnc1.1;
        gSOAPContentType # sSOAP.ContentType1.1;
      }
      case _SOAP.Version1.2 :
      {
        gSOAPNamespace # sSOAP.Namespace1.2;
        gSOAPNamespaceEnc # sSOAP.NamespaceEnc1.2;
        gSOAPContentType # sSOAP.ContentType1.2;
      }
    }

    gSck # tSck;

    gMem # MemAllocate(sSOAP.MemSizeAlloc);
    gMem->spCharset # sSOAP.Charset;

    gFault # false;

    gCteNodeRqsHeader # CteOpen(_CteNode, _CteChildList | _CteChildTreeCI);
    gCteNodeRqsBody   # CteOpen(_CteNode, _CteChildList | _CteChildTreeCI);
    gCteNodeRspHeader # CteOpen(_CteNode, _CteChildList | _CteChildTreeCI);
    gCteNodeRspBody   # CteOpen(_CteNode, _CteChildList | _CteChildTreeCI);
  }
  // Fehler beim Herstellen der Socket-Verbindung
  else
    tErr # tSck;

  ErrSet(tErr);

  if (tErr = _ErrOK)
    return(tSOAP);
  else
    return(tErr);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Instanzieren                                                   +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Inst // private
(
  aSOAP                 : handle;       // Instanz
)
{
  VarInstance(SOAP, aSOAP);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Destruktor                                                     +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Term // public
(
  aSOAP                 : handle;       // Instanz
)
{
  aSOAP->Inst();

  if (gCteNodeRspFault > 0)
  {
    gCteNodeRspFault->CteClear(true);
    gCteNodeRspFault->CteClose();
  }

  gCteNodeRspBody->CteClear(true);
  gCteNodeRspBody->CteClose();
  gCteNodeRspHeader->CteClear(true);
  gCteNodeRspHeader->CteClose();
  gCteNodeRqsBody->CteClear(true);
  gCteNodeRqsBody->CteClose();
  gCteNodeRqsHeader->CteClear(true);
  gCteNodeRqsHeader->CteClose();

  gMem->MemFree();
  // Socket schließen
  gSck->SckClose();

  VarFree(SOAP);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Anfrage-Header ermitteln                                       +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RqsHeader // public
(
  aSOAP                 : handle;       // Instanz
)
: handle;                               // Element (> 0)
{
  aSOAP->Inst();

  return(gCteNodeRqsHeader);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Anfrage-Body ermitteln                                         +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RqsBody // public
(
  aSOAP                 : handle;       // Instanz
)
: handle;                               // Element (> 0)
{
  aSOAP->Inst();

  return(gCteNodeRqsBody);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Antwort-Header ermitteln                                       +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspHeader // public
(
  aSOAP                 : handle;       // Instanz
)
: handle;                               // Element (> 0)
{
  aSOAP->Inst();

  return(gCteNodeRspHeader);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Antwort-Body ermitteln                                         +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspBody // public
(
  aSOAP                 : handle;       // Instanz
)
: handle;                               // Element (> 0)
{
  aSOAP->Inst();

  return(gCteNodeRspBody);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Element hinzufügen                                             +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ElementAdd // public
(
  aSOAPElement          : handle;       // Elternelement
  aName                 : alpha;        // Name
)
: handle;                               /* Element (> 0) /
                                           Fehler (< 0)
                                           _ErrExists
                                           _ErrNameInvalid
                                        */

  local
  {
    tSOAPElement        : handle;
  }

{
  if (aName = '')
  {
    ErrSet(_ErrNameInvalid);
    return(_ErrNameInvalid);
  }

  tSOAPElement # aSOAPElement->CteInsertNode(aName, _XMLNodeElement, NULL);
  if (tSOAPElement > 0)
  {
    tSOAPElement->spFlags # _CteChildList | _CteAttribList | _CteAttribTree;

    ErrSet(_ErrOK);
  }
  else
    ErrSet(tSOAPElement);

  return(tSOAPElement);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Anfrage-Header-Element hinzufügen                              +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RqsHeaderElementAdd // public
(
  aSOAP                 : handle;       // Instanz
  aName                 : alpha;        // Elementname
)
: handle;                               /* Element (> 0) /
                                           Fehler (< 0)
                                           _ErrExists
                                           _ErrNameInvalid
                                        */
{
  aSOAP->Inst();

  return(gCteNodeRqsHeader->ElementAdd(aName));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Anfrage-Header-Elemente leeren                                 +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RqsHeaderClear // public
(
  aSOAP                 : handle;       // Instanz
)
{
  aSOAP->Inst();

  gCteNodeRqsHeader->CteClear(true);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Anfrage-Body-Element hinzufügen                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RqsBodyElementAdd // public
(
  aSOAP                 : handle;       // Instanz
  aName                 : alpha;        // Elementname
)
: handle;                               // Element (> 0) / Fehler (< 0)
{
  aSOAP->Inst();

  return (gCteNodeRqsBody->ElementAdd(aName));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Antwort-Header-Element ermitteln                               +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspHeaderElementGet
(
  aSOAP                 : handle;       // Instanz
  aName                 : alpha;        // Elementname
)
: handle;                               // Element (> 0) / 0
{
  aSOAP->Inst();

  return(gCteNodeRspHeader->CteRead(_CteChildTree | _CteCmpE, 0, aName));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Antwort-Body-Element ermitteln                                 +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspBodyElementGet
(
  aSOAP                 : handle;       // Instanz
  aName                 : alpha;        // Elementname
)
: handle;                               // Element (> 0) / 0
{
  aSOAP->Inst();

  return(gCteNodeRspBody->CteRead(_CteChildTree | _CteCmpE, 0, aName));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Boolean-Wert schreiben                                         +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub BooleanWrite // private
(
  aValue                : logic;        // Wert
)
: alpha;                                // Text
{
  if (aValue)
    return('true');
  else
    return('false');
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Boolean-Wert lesen                                             +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub BooleanRead // private
(
  aText                 : alpha(4096);  // Text
  var vValue            : logic;        // Wert
)
: logic;                                // Erfolg
{
  switch (aText)
  {
    case 'true' , '1' : vValue # true;
    case 'false', '0' : vValue # false;
    default :
    {
      vValue # NULL;
      ErrSet(_ErrValueInvalid);
      return(false);
    }
  }

  ErrSet(_ErrOK);
  return(true);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Float-Wert schreiben                                           +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub FloatWrite // private
(
  aValue                : float;        // Wert
)
: alpha;                                // Text
{
  return(CnvAF(aValue, _FmtNumPoint | _FmtNumNoGroup, 0, -2));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Float-Wert lesen                                               +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub FloatRead // private
(
  aText                 : alpha(4096);  // Text
  var vValue            : float;        // Wert
)
: logic;                                // Erfolg
{
  if (StrFindRegEx(aText, '^[+-]?[0-9]+\.?[0-9]+([eE][-+]?[0-9]+)?$', 1) = 1)
  {
    ErrSet(_ErrOK);
    ErrIgnore(_ErrCnv, true);
    vValue # CnvFA(aText, _FmtNumPoint);
    ErrIgnore(_ErrCnv, false);
    if (ErrGet() = _ErrOK)
      return(true);
  }

  vValue # NULL;
  ErrSet(_ErrValueInvalid);
  return(false);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Byte-Wert lesen                                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ByteRead // private
(
  aText                 : alpha(4096);  // Text
  var vValue            : int;          // Wert
)
: logic;                                // Erfolg
{
  if (StrFindRegEx(aText, '^[+-]?[0-9]+$', 1) = 1)
  {
    ErrSet(_ErrOK);
    ErrIgnore(_ErrCnv, true);
    vValue # CnvIA(aText);
    ErrIgnore(_ErrCnv, false);
    if (ErrGet() = _ErrOK and vValue >= -128 and vValue <= 127)
      return(true);
  }

  vValue # NULL;
  ErrSet(_ErrValueInvalid);
  return(false);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Short-Wert lesen                                               +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ShortRead // private
(
  aText                 : alpha(4096);  // Text
  var vValue            : int;          // Wert
)
: logic;                                // Erfolg
{
  if (StrFindRegEx(aText, '^[+-]?[0-9]+$', 1) = 1)
  {
    ErrSet(_ErrOK);
    ErrIgnore(_ErrCnv, true);
    vValue # CnvIA(aText);
    ErrIgnore(_ErrCnv, false);
    if (ErrGet() = _ErrOK and vValue >= -32768 and vValue <= 32767)
      return(true);
  }

  vValue # NULL;
  ErrSet(_ErrValueInvalid);
  return(false);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Int-Wert schreiben                                             +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub IntWrite // private
(
  aValue                : int;          // Wert
)
: alpha;                                // Text
{
  return(CnvAI(aValue, _FmtInternal));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Int-Wert lesen                                                 +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub IntRead // private
(
  aText                 : alpha(4096);  // Text
  var vValue            : int;          // Wert
)
: logic;                                // Erfolg
{
  if (StrFindRegEx(aText, '^[+-]?[0-9]+$', 1) = 1)
  {
    ErrSet(_ErrOK);
    ErrIgnore(_ErrCnv, true);
    vValue # CnvIA(aText);
    ErrIgnore(_ErrCnv, false);
    if (ErrGet() = _ErrOK)
      return(true);
  }

  vValue # NULL;
  ErrSet(_ErrValueInvalid);
  return(false);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Long-Wert schreiben                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub LongWrite // private
(
  aValue                : bigint;       // Wert
)
: alpha;                                // Text
{
  return(CnvAB(aValue, _FmtInternal));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Long-Wert lesen                                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub LongRead // private
(
  aText                 : alpha(4096);  // Text
  var vValue            : bigint;       // Wert
)
: logic;                                // Erfolg
{
  if (StrFindRegEx(aText, '^[+-]?[0-9]+$', 1) = 1)
  {
    ErrSet(_ErrOK);
    ErrIgnore(_ErrCnv, true);
    vValue # CnvBA(aText);
    ErrIgnore(_ErrCnv, false);
    if (ErrGet() = _ErrOK)
      return(true);
  }

  vValue # NULL;
  ErrSet(_ErrValueInvalid);
  return(false);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Date-Wert schreiben                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub DateWrite // private
(
  aValue                : date;         // Wert
)
: alpha;                                // Text
{
  return(
    CnvAI(aValue->vpYear, _FmtNumLeadZero | _FmtNumNoGroup, 0, 4) +
    '-' +
    CnvAI(aValue->vpMonth, _FmtNumLeadZero, 0, 2) +
    '-' +
    CnvAI(aValue->vpDay, _FmtNumLeadZero, 0, 2)
  );
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Date-Wert lesen                                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub DateRead // private
(
  aText                 : alpha(4096);  // Text
  var vValue            : date;         // Wert
)
: logic;                                // Erfolg
{
  if (StrFind(aText, '^[0-9]{4}' + '-' + '[0-9]{2}' + '-' + '[0-9]{2}$', 1) = 1)
  {
    ErrSet(_ErrOK);
    ErrIgnore(_ErrCnv, true);
    vValue # CnvDA(aText, _FmtDateYMD);
    ErrIgnore(_ErrCnv, false);
    if (ErrGet() = _ErrOK)
      return(true);
  }

  vValue # NULL;
  ErrSet(_ErrValueInvalid);
  return(false);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Time-Wert schreiben                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub TimeWrite // private
(
  aValue                : time;         // Wert
)
: alpha;                                // Text

  local
  {
    tValue              : alpha;
  }

{
  tValue #
    CnvAI(aValue->vpHours, _FmtNumLeadZero | _FmtNumNoGroup, 0, 2) +
    ':' +
    CnvAI(aValue->vpMinutes, _FmtNumLeadZero | _FmtNumNoGroup, 0, 2) +
    ':' +
    CnvAI(aValue->vpSeconds, _FmtNumLeadZero | _FmtNumNoGroup, 0, 2)
  ;

  if (aValue->vpMilliseconds != 0)
    tValue # tValue + StrDel(CnvAF(CnvFI(aValue->vpMilliseconds) / 1000.0, _FmtNumPoint, 0, -2), 1, 1);

  return(tValue);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Time-Wert lesen                                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub TimeRead // private
(
  aText                 : alpha(4096);  // Text
  var vValue            : time;         // Wert
)
: logic;                                // Erfolg
{
  if (StrFindRegEx(aText, '^[0-9]{2}' + ':' + '[0-9]{2}' + ':' + '[0-9]{2}' + '(\.[0-9]{1,3})?$', 1) = 1)
  {
    ErrSet(_ErrOK);
    ErrIgnore(_ErrCnv, true);
    vValue # CnvTA(StrCut(aText, 1, 8));
    if (StrCut(aText, 9, 1) = '.')
      vValue->vpMilliseconds # CnvIA(StrDel(aText, 1, 9));
    ErrIgnore(_ErrCnv, false);
    if (ErrGet() = _ErrOK)
      return(true);
  }

  vValue # NULL;
  ErrSet(_ErrValueInvalid);
  return(false);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + DateTime-Wert schreiben                                        +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub DateTimeWrite // private
(
  aValue                : caltime;      // Wert
  aTimezoned            : logic;        // Zeitzonen-behaftet
)
: alpha;                                // Repräsentation

  local
  {
    tValue              : alpha;
    tBias               : int;
    tBiasTime           : time;
  }

{
  tValue #
    CnvAI(aValue->vpYear, _FmtNumLeadZero | _FmtNumNoGroup, 0, 4) +
    '-' +
    CnvAI(aValue->vpMonth, _FmtNumLeadZero | _FmtNumNoGroup, 0, 2) +
    '-' +
    CnvAI(aValue->vpDay, _FmtNumLeadZero | _FmtNumNoGroup, 0, 2) +
    'T' +
    CnvAI(aValue->vpHours, _FmtNumLeadZero | _FmtNumNoGroup, 0, 2) +
    ':' +
    CnvAI(aValue->vpMinutes, _FmtNumLeadZero | _FmtNumNoGroup, 0, 2) +
    ':' +
    CnvAI(aValue->vpSeconds, _FmtNumLeadZero | _FmtNumNoGroup, 0, 2)
  ;

  if (aValue->vpMilliseconds != 0)
    tValue # tValue + StrDel(CnvAF(CnvFI(aValue->vpMilliseconds) / 1000.0, _FmtNumPoint, 0, -2), 1, 1);

  if (aTimezoned)
  {
    tBias # aValue->vpBiasMinutes;
    if (tBias = 0)
      tValue # tValue + 'Z';
    else
    {
      tBiasTime # CnvTI(Abs(tBias) * 60000);

      if (tBias > 0)
        tValue # tValue + '+';
      else
        tValue # tValue + '-';

      tValue # tValue +
        CnvAI(tBiasTime->vpHours, _FmtNumLeadZero, 0, 2) +
        ':' +
        CnvAI(tBiasTime->vpMinutes, _FmtNumLeadZero, 0, 2)
      ;
    }
  }

  return(tValue);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + DateTime-Wert lesen                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub DateTimeRead // private
(
  aText                 : alpha(4096);  // Text
  var vValue            : caltime;      // Wert
)
: logic;                                // Erfolg

  local
  {
    tPos                : int;
    tLen                : int;
    tValid              : logic;
  }

{
  tPos # StrFindRegEx(aText, '^' +
    '[0-9]{4}' + '-' + '[0-9]{2}' + '-' + '[0-9]{2}' + 'T' +
    '[0-9]{2}' + ':' + '[0-9]{2}' + ':' + '[0-9]{2}' + '(\.[0-9]{1,3})?',
    1, 0, var tLen
  );

  if (tPos = 1)
  {
    ErrSet(_ErrOK);
    ErrIgnore(_ErrCnv, true);

    vValue->vpDate # CnvDA(StrCut(aText, 1, 10), _FmtDateYMD);
    vValue->vpTime # CnvTA(StrCut(aText, 12, 8));
    if (StrCut(aText, 20, 1) = '.')
      vValue->vpMilliseconds # CnvIA(StrCut(aText, 21, tLen - 20));

    if (ErrGet() = _ErrOK)
    {
      aText # StrDel(aText, 1, tLen);

      tPos # StrFindRegEx(aText, '^(' +
        'Z' + '|' + '(' +
          '[+-]' + '[0-9]{2}' + ':' + '[0-9]{2}' +
        ')' + ')?' + '$',
        1, 0, var tLen
      );

      if (tPos = 1)
      {
        if (tLen > 0)
        {
          switch (StrCut(aText, 1, 1))
          {
            case 'Z' : vValue->vpBiasMinutes # 0;
            case '+' : vValue->vpBiasMinutes #   CnvIT(CnvTA(StrCut(aText, 2, 5))) / 60000;
            case '-' : vValue->vpBiasMinutes # - CnvIT(CnvTA(StrCut(aText, 2, 5))) / 60000;
          }
        }

        if (ErrGet() = _ErrOK)
          tValid # true;
      }
    }

    ErrIgnore(_ErrCnv, false);
  }

  if (tValid)
    ErrSet(_ErrOK);
  else
  {
    vValue # NULL;
    ErrSet(_ErrValueInvalid);
  }

  return(tValid);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Werte typisieren                                               +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ElementTypify // private
(
  aSOAPElement          : handle;       // Element
)

  local
  {
    tSOAPElement        : handle;
    tSOAPAttrib         : handle;
    tType               : alpha;
  }

{
  for   tSOAPElement # aSOAPElement->CteRead(_CteChildList | _CteFirst);
  loop  tSOAPElement # aSOAPElement->CteRead(_CteChildList | _CteNext, tSOAPElement);
  while (tSOAPElement > 0)
  {
    tType # tSOAPElement->spCustom;
    // Element
    if (tType = '')
      tSOAPElement->ElementTypify();
    // Wert
    else
    {
      tSOAPAttrib # tSOAPElement->CteRead(_CteAttribTree | _CteCmpE, 0, 'xsi:type');

      if (gSOAPUse = _SOAP.UseEncoded)
      {
        if (tSOAPAttrib > 0)
          tSOAPAttrib->spValueAlpha # 'xsd:' + tType;
        else
          tSOAPAttrib # tSOAPElement->CteInsertNode('xsi:type', _XMLNodeAttribute, 'xsd:' + tType, _CteAttrib);
      }
      else
      {
        if (tSOAPAttrib > 0)
          tSOAPAttrib->CteClose();
      }
    }
  }
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Anfrage versenden                                              +
// +                                                                +
// + Versendet eine Nachricht. Wird in [Method] eine Methode        +
// + angegeben, wird der Nachrichtenkörper in ein Methodenaufruf    +
// + (RPC) geschachtelt.                                            +
// + In [Action] kann ein SOAPAction-Wert übergeben werden.         +
// + Wird in [ObjHeader] oder [ObjBody] ein Objekt für den          +
// + Nachrichtenkopf bzw. -körper übergeben, wird die Nachricht aus +
// + diesen Objekten übernommen und nicht aus den hinzugefügten     +
// + Elementen und Werten zusammengesetzt.                          +
// +                                                                +
// + Tritt beim Versenden der Nachricht ein Socket-Fehler auf,      +
// + beispielsweise weil der Server die Verbindung getrennt hat,    +
// + wird versucht eine neue Verbindung herzustellen und die        +
// + Nachricht erneut zu versenden.                                 +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RqsSend // public
(
  aSOAP                 : handle;       // Instanz
  aMethod               : alpha(256);   // Methode
  opt aAction           : alpha(1024);  // SOAPAction-Wert
  opt aObjHeader        : handle;       // Header-Objekt (CteNode-XML- oder Mem-Objekt)
  opt aObjBody          : handle;       // Body-Objekt (CteNode-XML- oder Mem-Objekt)
  opt aParaHandle       : handle;       // JSON-Node
)
: int;                                  /* Erfolg (= 0 = _ErrOK) /
                                           Fehler (< 0)
                                           _ErrSck...
                                           _Err.SOAPFault
                                           _Err.SOAPHTTPStatus
                                           _Err.SOAPHTTPContentLength
                                           _Err.SOAPHTTPContentType
                                           _ErrXML...
                                        */
  local
  {
    tErr                : int;
    tMem                : handle;
    tCteNodeXMLElement  : handle;
    tHTTP               : handle;
    tCteListHTTPHeader  : handle;
    tRetry              : logic;

    vI, vJ, vTmp, vtmp2 : int;
    vTxt                : handle;
  }

{
  aSOAP->Inst();

  gMem->spLen # 0;

  gMem->MemWriteStr(_MemAppend,
    '<?xml version="1.0" encoding="' + sSOAP.CharsetStr + '"?>' +
    '<s:Envelope xmlns:s="' + gSOAPNamespace + '"'
  );

  if (gSOAPUse = _SOAP.UseEncoded)
    gMem->MemWriteStr(_MemAppend,
      ' s:encodingStyle="' + gSOAPNamespaceEnc + '"' +
      ' xmlns:xsd="' + sSOAP.NamespaceXSD + '"' +
      ' xmlns:xsi="' + sSOAP.NamespaceXSI + '"'
    );

  gMem->MemWriteStr(_MemAppend, ' xmlns="' + gNamespace + '">');

  // Kein Header-Objekt übergeben
  if (aObjHeader = 0)
  {
    // Header-Elemente vorhanden
    if (gCteNodeRqsHeader->spChildCount > 0)
    {
      gMem->MemWriteStr(_MemAppend, '<s:Header>');

      // Werte typisieren
      gCteNodeRqsHeader->ElementTypify();
      gCteNodeRqsHeader->spID # _XMLNodeElement;
      tMem # MemAllocate(_MemAutoSize);
      tMem->spCharset # sSOAP.Charset;
      gCteNodeRqsHeader->XMLSave('', _XMLSavePure, tMem, sSOAP.Charset);

      // Leere öffnende und schließende Elemente ("<>" und "</>") entfernen
      tMem->MemCopy(1 + 2, tMem->spLen - 2 - 3, _MemAppend, gMem);

      tMem->MemFree();
      gMem->MemWriteStr(_MemAppend, '</s:Header>');
    }
  }
  // Header-Objekt übergeben
  else
  {
    switch (aObjHeader->HdlInfo(_HdlType))
    {
      case _HdlMem     :
      {
        if (aObjHeader->spLen > 0)
        {
          gMem->MemWriteStr(_MemAppend, '<s:Header>');
          aObjHeader->MemCopy(1, _MemDataLen, _MemAppend, gMem);
          gMem->MemWriteStr(_MemAppend, '</s:Header>');
        }
      }
      case _HdlCteNode :
      {
        if (aObjBody->spChildCount > 0)
        {
          gMem->MemWriteStr(_MemAppend, '<s:Header>');
          tMem # MemAllocate(_MemAutoSize);
          tMem->spCharset # sSOAP.Charset;

          for   tCteNodeXMLElement # aObjHeader->CteRead(_CteChildList | _CteFirst);
          loop  tCteNodeXMLElement # aObjHeader->CteRead(_CteChildList | _CteNext, tCteNodeXMLElement);
          while (tCteNodeXMLElement > 0)
          {
            tCteNodeXMLElement->XMLSave('', _XMLSavePure, tMem, sSOAP.Charset);
            tMem->MemCopy(1, _MemDataLen, _MemAppend, gMem);
            tMem->spLen # 0;
          }

          tMem->MemFree();
          gMem->MemWriteStr(_MemAppend, '</s:Header>');
        }
      }
    }
  }


  // Body-Element öffnen
  gMem->MemWriteStr(_MemAppend, '<s:Body');


  // Kein Body-Objekt übergeben
  if (aObjBody = 0)
  {
    // Keine Body-Elemente vorhanden
    if (gCteNodeRqsBody->spChildCount = 0 and aMethod = '')
    {
      // Body-Element schließen
      gMem->MemWriteStr(_MemAppend, '/>');
    }
    // Body-Elemente vorhanden
    else
    {
      gMem->MemWriteStr(_MemAppend, '>');

      // Werte typisieren
      gCteNodeRqsBody->ElementTypify();

      gCteNodeRqsBody->spID # _XMLNodeElement;
      gCteNodeRqsBody->spName # aMethod;

      tMem # MemAllocate(_MemAutoSize);
      tMem->spCharset # sSOAP.Charset;
      gCteNodeRqsBody->XMLSave('', _XMLSavePure, tMem, sSOAP.Charset);
      if (aMethod != '')
        tMem->MemCopy(1, _MemDataLen, _MemAppend, gMem);
      else
        // Leere öffnende und schließende Elemente ("<>" und "</>") entfernen
        tMem->MemCopy(1 + 2, tMem->spLen - 2 - 3, _MemAppend, gMem);
      tMem->MemFree();


      // Falls ein JSON-Parahandle vorhandne ist, diesen nun einfügen an Stelle des Platzhalters "XxX_PARA_XxX"
      if (aParaHandle<>0)
      {
        // den JSON-ParaHandle in eigenes MemObj serialisieren...
        tMem # MemAllocate(_MemAutoSize);
        tMem->spCharset # sSOAP.Charset;
        vI # aParaHandle->JSONSave('',_JsonSavePure, tMem, sSOAP.Charset);  // purEeee

        // Problem: JSON hat Anführungszeichen, aber in XML müssen diese "&quot;" sein!
        // Also das MemObj n einen Textbuffer schieben, dort die Zeichenumwandlungen mamchen und so wieder zurück in das MemObj
        vTxt # TextOpen(16);
        Lib_Texte:ReadFromMem(vTxt, tMem, 1, _MemDataLen);
        TextSearch(vTxt, 1, 1, _textSearchCI, '&', '&amp;');   // JSON nach XML-Formatierung      // ST 2021-01-14 2187/2
        TextSearch(vTxt, 1, 1, _textSearchCI, '"', '&quot;');   // JSON nach XML-Formatierung
       
        tMem->MemFree();
        tMem # MemAllocate(_MemAutoSize);
        tMem->spCharset # sSOAP.Charset;
        Lib_Texte:WriteToMem(vTxt, tMem);
        TextClose(vTxt);

        // JSON-MemObj an Stelle des Platzhalter in das XML einkopieren...
        vI # MemFindStr(gMem, 1, gMem->spLen, 'XxX_PARA_XxX');
        vJ # gMem->spLen;
        gMem->MemResize(gMem->spLen + tMem->spLen-12);        // Platz vergößern
        gMem->MemCopy(vI+12, vJ-vI-12+1, vI+tMem->spLen);     // nach Rechts schieben (von, anzahl, ziel)
        tMem->MemCopy(1, tMem->spLen, vI, gMem);              // einfügen

        tMem->MemFree();
      }

      gMem->MemWriteStr(_MemAppend, '</s:Body>');
    }
  }
  // Body-Objekt übergeben -------------------------------------
  else
  {
    switch (aObjBody->HdlInfo(_HdlType))
    {
      case _HdlMem     :
      {
        if (aObjBody->spLen = 0)
          // Body-Element schließen
          gMem->MemWriteStr(_MemAppend, '/>');
        else
        {
          gMem->MemWriteStr(_MemAppend, '>');
          aObjBody->MemCopy(1, _MemDataLen, _MemAppend, gMem);
          gMem->MemWriteStr(_MemAppend, '</s:Body>');
        }
      }
      case _HdlCteNode :
      {
        if (aObjBody->spChildCount = 0)
        {
          // Body-Element schließen
          gMem->MemWriteStr(_MemAppend, '/>');
        }
        else
        {
          gMem->MemWriteStr(_MemAppend, '>');
          tMem # MemAllocate(_MemAutoSize);
          tMem->spCharset # sSOAP.Charset;

          for   tCteNodeXMLElement # aObjBody->CteRead(_CteChildList | _CteFirst);
          loop  tCteNodeXMLElement # aObjBody->CteRead(_CteChildList | _CteNext, tCteNodeXMLElement);
          while (tCteNodeXMLElement > 0)
          {
            tCteNodeXMLElement->XMLSave('', _XMLSavePure, tMem, sSOAP.Charset);
            tMem->MemCopy(1, _MemDataLen, _MemAppend, gMem);
            tMem->spLen # 0;
          }

          tMem->MemFree();
          gMem->MemWriteStr(_MemAppend, '</s:Body>');
        }
      }
    }
  }


  gMem->MemWriteStr(_MemAppend, '</s:Envelope>');

//MYDEBUG();


  do
  {
    // HTTP-Objekt öffnen
    tHTTP # HTTPOpen(_HTTPSendRequest, gSck);
    // HTTP-Objekt geöffnet
    if (tHTTP > 0)
    {
      // URI übernehmen
      tHTTP->spURI # gResource;
      // Methode übernehmen
      tHTTP->spMethod # 'POST';
      // Host übernehmen
      tHTTP->spHostName # gHost;

      tCteListHTTPHeader # tHTTP->spHttpHeader;

      if (aAction != '' and !(aAction =* '"*"'))
        aAction # '"' + aAction + '"';

      // Content-Type setzen
      if (gSOAPVersion = _SOAP.Version1.1 or aAction = '')
        tCteListHTTPHeader->CteInsertItem('Content-Type', 0, gSOAPContentType + '; charset=' + sSOAP.CharsetStr);
      else
        tCteListHTTPHeader->CteInsertItem('Content-Type', 0, gSOAPContentType + '; charset=' + sSOAP.CharsetStr + '; action=' + aAction);

      // SOAPAction setzen
      if (aAction != '' and gSOAPVersion = _SOAP.Version1.1)
        tCteListHTTPHeader->CteInsertItem('SOAPAction', 0, aAction);

//vTMP # FSIOpen('C:\wurst.txt',_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
//FsiWriteMem(vTMP, gMem, 1,  gMem->spLen);
//FsiCLose(vTMP);

      // BODY ÜBERGEBEN <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      // BODY ÜBERGEBEN <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      // BODY ÜBERGEBEN <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      tErr # tHTTP->HTTPClose(0, gMem);
      // Socket-Fehler
      if (tRetry = false and tErr < -700 and tErr > -800)
      {
        tRetry # true;
        // Socket schließen
        gSck->SckClose();
        // Socket-Verbindung herstellen
        gSck # SckConnect(gHost, gPort, gOptionsSocket, gTimeoutSocket);
        // Socket-Verbindung hergestellt
        if (gSck > 0)
          cycle;
        // Fehler beim Herstellen der Socket-Verbindung
        else
        {
          tErr # gSck;
          gSck # 0;
        }
      }
    }
    // Fehler beim Öffnen des HTTP-Objekts
    else
      tErr # tHTTP;
  }
  while (false)

  gMem->spLen # 0;

  // Speicherblockgröße begrenzen
  if (gMem->spSize > sSOAP.MemSizeLimit)
    gMem->MemResize(sSOAP.MemSizeLimit);

  // Versand-Body-Daten leeren
  gCteNodeRqsBody->CteClear(true);

  ErrSet(tErr);

  return(tErr);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + XML-Namensraum-Prefix entfernen                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub XML.NamespacePrefixRemove // private
(
  aCteNodeElement       : handle;       // CteNode-Element
  aNamespace            : alpha(1000);  // Namensraum oder
  opt aPrefix           : alpha;        // Prefix
)

  local
  {
    tCteNodeAttrib      : handle;
    tCteNodeAttribNext  : handle;
    tCteNodeElement     : handle;
    tCteNodeElementNext : handle;
    tPrefix             : alpha;
  }

{
  if (aPrefix = '')
  {
    tCteNodeAttrib # aCteNodeElement->CteRead(_CteAttribList | _CteSearch | _CteFirst, 0, 'xmlns:*');
    while (tCteNodeAttrib > 0)
    {
      tCteNodeAttribNext # aCteNodeElement->CteRead(_CteAttribList | _CteSearch | _CteNext , tCteNodeAttrib, 'xmlns:*');

      if (tCteNodeAttrib->spValueAlpha = aNamespace)
      {
        tPrefix # StrDel(tCteNodeAttrib->spName, 1, 6);

        aCteNodeElement->CteDelete(tCteNodeAttrib, _CteAttrib);

        tCteNodeAttrib->spName # StrCut(tCteNodeAttrib->spName, 1, 5);

        if (tCteNodeAttribNext = 0)
          aCteNodeElement->CteInsert(tCteNodeAttrib, _CteAttrib | _CteLast);
        else
          aCteNodeElement->CteInsert(tCteNodeAttrib, _CteAttrib | _CteBefore, tCteNodeAttribNext);

        break;
      }

      tCteNodeAttrib # tCteNodeAttribNext;
    }
  }
  else
    tPrefix # aPrefix;

  if (tPrefix = '')
  {
    for   tCteNodeElement # aCteNodeElement->CteRead(_CteChildList | _CteFirst);
    loop  tCteNodeElement # aCteNodeElement->CteRead(_CteChildList | _CteNext, tCteNodeElement);
    while (tCteNodeElement > 0)
    {
      if (tCteNodeElement->spID = _XMLNodeElement)
      {
        tCteNodeElement->XML.NameSpacePrefixRemove(aNamespace);
      }
    }
  }
  else
  {
    if (aCteNodeElement->spName =* tPrefix + ':*')
      aCteNodeElement->spName # StrDel(aCteNodeElement->spName, 1, StrLen(tPrefix) + 1);

    tCteNodeElement # aCteNodeElement->CteRead(_CteChildList | _CteFirst);
    while (tCteNodeElement > 0)
    {
      tCteNodeElementNext # aCteNodeElement->CteRead(_CteChildList | _CteNext, tCteNodeElement);

      if (tCteNodeElement->spID = _XMLNodeElement)
      {
        aCteNodeElement->CteDelete(tCteNodeElement);

        tCteNodeElement->XML.NameSpacePrefixRemove('', tPrefix);

        if (tCteNodeElementNext = 0)
          aCteNodeElement->CteInsert(tCteNodeElement, _CteLast);
        else
          aCteNodeElement->CteInsert(tCteNodeElement, _CteBefore, tCteNodeElementNext);
      }

      tCteNodeElement # tCteNodeElementNext;
    }
  }
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Antwort empfangen                                              +
// +                                                                +
// + Empfängt eine Nachricht. Wird in [Result] eine Rückgabe einer  +
// + Methode angegeben, wird der Nachrichtenkörper aus der Rückgabe +
// + des Methodenaufrufs (RPC) entnommen.                           +
// + Wird in [ObjHeader] oder [ObjBody] ein Objekt für den          +
// + Nachrichtenkopf bzw. -körper übergeben, wird die Nachricht in  +
// + diese Objekte übernommen und nicht in Elemente und Werte       +
// + zerlegt.                                                       +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspRecv // public
(
  aSOAP                 : handle;       // Instanz
  aResult               : alpha(256);   // Resultat
  opt aObjHeader        : handle;       // Header-Objekt (CteNode-XML- oder Mem-Objekt)
  opt aObjBody          : handle;       // Body-Objekt (CteNode-XML- oder Mem-Objekt)
)
: int;                                  /* Erfolg (= 0 = _ErrOK) /
                                           Fehler (< 0)
                                           _Err.SOAPFault
                                           _Err.SOAPHTTPStatus
                                           _Err.SOAPHTTPContentLength
                                           _Err.SOAPHTTPContentType
                                           _ErrXML...
                                           _ErrSck...
                                        */
  local
  {
    tHTTP                 : handle;
    tErr                  : int;
    tCteListHTTPHeader    : handle;
    tCteItemHTTPHeader    : handle;
    tSOAPContentType      : alpha(4096);
    tSOAPNamespacePrefix  : alpha;
    tCteNodeXML           : handle;
    tCteNodeXMLRoot       : handle;
    tCteNodeXMLItem       : handle;
    tCteNodeXMLItemHeader : handle;
    tCteNodeXMLItemBody   : handle;
    tCteNodeXMLItemResult : handle;
  }

{
  aSOAP->Inst();

  // Antwortdaten leeren
  gCteNodeRspHeader->CteClear(true);
  gCteNodeRspBody->CteClear(true);
  if (gCteNodeRspFault > 0)
  {
    gCteNodeRspFault->CteClear(true);
    gCteNodeRspFault->CteClose();
    gCteNodeRspFault # 0;
  }

  gSOAPNamespacePrefix # '';

  tHTTP # HTTPOpen(_HttpRecvResponse, gSck);
  if (tHTTP > 0)
  {
    switch (CnvIA(StrCut(tHTTP->spStatusCode, 1, 3)))
    {
      // OK
      case 200 ,
      // Accecpted
           202 : gFault # false;
      // Internal Server Error
      case 500 : {
        gFault # true;
      }
      // Temporary Redirect (NYI)
      case 307 : tErr # _Err.SOAPHTTPStatus;
      // ...
      default  : tErr # _Err.SOAPHTTPStatus;
    }
    if (tErr = _ErrOK)
    {
      // Datengröße gültig
      if (tHTTP->spContentLength != -1)
      {
        tCteListHTTPHeader # tHTTP->spHttpHeader;

        tCteItemHTTPHeader # tCteListHTTPHeader->CteRead(_CteSearchCI | _CteFirst, 0, 'Content-Type');
        if (tCteItemHTTPHeader > 0)
          tSOAPContentType # tCteItemHTTPHeader->spCustom;

        // Datentyp gültig
        if (
          tSOAPContentType =^  gSOAPContentType or
          tSOAPContentType =*^ gSOAPContentType + ';*' or
          tSOAPContentType =^  'application/xml' or
          tSOAPContentType =*^ 'application/xml;*'
        )
        {
          gMem->spLen # 0;

          // Daten empfangen
          tErr # tHTTP->HTTPGetData(gMem);
          if (tErr = _ErrOK)
          {
            tCteNodeXML # CteOpen(_CteNode, _CteChildList | _CteAttribList);

            tErr # tCteNodeXML->XMLLoad('', _XmlLoadHugeTextNode, gMem);      // ST 2020-06-30: _XmlLoadHugeTextNode hinzugefügt
            if (tErr = _ErrOK)
            {
              tCteNodeXMLRoot # tCteNodeXML->CteRead(_CteChildList | _CteFirst);
              if (tCteNodeXMLRoot > 0)
              {
                tCteNodeXMLRoot->XML.NamespacePrefixRemove(gNamespace);

                for   tCteNodeXMLItem # tCteNodeXMLRoot->CteRead(_CteAttribList | _CteSearch | _CteFirst, 0              , 'xmlns:*');
                loop  tCteNodeXMLItem # tCteNodeXMLRoot->CteRead(_CteAttribList | _CteSearch | _CteNext , tCteNodeXMLItem, 'xmlns:*');
                while (tCteNodeXMLItem > 0)
                {
                  if (tCteNodeXMLItem->spValueAlpha = gSOAPNamespace)
                  {
                    tSOAPNamespacePrefix # StrDel(tCteNodeXMLItem->spName, 1, 6) + ':';
                    break;
                  }
                }

                gSOAPNamespacePrefix # tSOAPNamespacePrefix;

                tCteNodeXMLItemHeader # tCteNodeXMLRoot->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, tSOAPNamespacePrefix + 'Header');
                if (tCteNodeXMLItemHeader > 0)
                {
                  // Kein Header-Objekt übergeben
                  if (aObjHeader = 0)
                  {
                    do
                    {
                      tCteNodeXMLItem # tCteNodeXMLItemHeader->CteRead(_CteChildList | _CteFirst);
                      if (tCteNodeXMLItem > 0)
                      {
                        tCteNodeXMLItemHeader->CteDelete(tCteNodeXMLItem, _CteChild);
                        if (!gCteNodeRspHeader->CteInsert(tCteNodeXMLItem, _CteChild))
                        {
                          tCteNodeXMLItem->CteClear(true);
                          tCteNodeXMLItem->CteClose();
                        }
                      }
                      else
                        break;
                    }
                    while (true)
                  }
                  // Header-Objekt übergeben
                  else
                  {
                    switch (aObjHeader->HdlInfo(_HdlType))
                    {
                      case _HdlMem :
                      {
                        tCteNodeXMLItemHeader->XMLSave('', 0, aObjHeader);
                      }
                      case _HdlCteNode :
                      {
                        aObjHeader->spID # _XMLNodeElement;

                        if (aObjHeader->spFlags & (_CteChildList | _CteChildTree) != 0)
                        {
                          do
                          {
                            tCteNodeXMLItem # tCteNodeXMLItemHeader->CteRead(_CteChildList | _CteFirst);
                            if (tCteNodeXMLItem > 0)
                            {
                              tCteNodeXMLItemHeader->CteDelete(tCteNodeXMLItem, _CteChild);
                              if (!aObjHeader->CteInsert(tCteNodeXMLItem, _CteChild))
                              {
                                tCteNodeXMLItem->CteClear(true);
                                tCteNodeXMLItem->CteClose();
                              }
                            }
                            else
                              break;
                          }
                          while (true)
                        }
                      }
                    }
                  }
                }

                tCteNodeXMLItemBody # tCteNodeXMLRoot->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, tSOAPNamespacePrefix + 'Body');
                if (tCteNodeXMLItemBody > 0)
                {
                  tCteNodeXMLItem # tCteNodeXMLItemBody->CteRead(_CteChildList | _CteFirst);
                  if (tCteNodeXMLItem > 0 and tCteNodeXMLItem->spName = tSOAPNamespacePrefix + 'Fault')
                  {
                    gFault # true;

                    gCteNodeRspFault # tCteNodeXMLItem;

                    tCteNodeXMLItemBody->CteDelete(tCteNodeXMLItem);
                  }
                  else
                    gFault # false;

                  if (aResult = '')
                    tCteNodeXMLItemResult # tCteNodeXMLItemBody;
                  else
                    tCteNodeXMLItemResult # tCteNodeXMLItemBody->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, aResult);

                  if (tCteNodeXMLItemResult > 0)
                  {
                    // Kein Body-Objekt übergeben
                    if (aObjBody = 0)
                    {
                      do
                      {
                        tCteNodeXMLItem # tCteNodeXMLItemResult->CteRead(_CteChildList | _CteFirst);
                        if (tCteNodeXMLItem > 0)
                        {
                          tCteNodeXMLItemResult->CteDelete(tCteNodeXMLItem, _CteChild);
                          if (!gCteNodeRspBody->CteInsert(tCteNodeXMLItem, _CteChild))
                          {
                            tCteNodeXMLItem->CteClear(true);
                            tCteNodeXMLItem->CteClose();
                          }
                        }
                        else
                          break;
                      }
                      while (true)
                    }
                    // Body-Objekt übergeben
                    else
                    {
                      switch (aObjBody->HdlInfo(_HdlType))
                      {
                        case _HdlMem     :
                        {
                          tCteNodeXMLItemBody->XMLSave('', 0, aObjBody);
                        }
                        case _HdlCteNode :
                        {
                          aObjBody->spID # _XMLNodeElement;

                          if (aObjBody->spFlags & (_CteChildList | _CteChildTree) != 0)
                          {
                            do
                            {
                              tCteNodeXMLItem # tCteNodeXMLItemBody->CteRead(_CteChildList | _CteFirst);
                              if (tCteNodeXMLItem > 0)
                              {
                                tCteNodeXMLItemResult->CteDelete(tCteNodeXMLItem, _CteChild);
                                if (!aObjBody->CteInsert(tCteNodeXMLItem, _CteChild))
                                {
                                  tCteNodeXMLItem->CteClear(true);
                                  tCteNodeXMLItem->CteClose();
                                }
                              }
                              else
                                break;
                            }
                            while (true)
                          }
                        }
                      }
                    }
                  }
                }
              }
            }

            tCteNodeXML->CteClear(true);
            tCteNodeXML->CteClose();
          }

          // Speicherblockgröße begrenzen
          if (gMem->spSize > sSOAP.MemSizeLimit)
            gMem->MemResize(sSOAP.MemSizeLimit);

          gMem->spLen # 0;
        }
        // Datentyp ungültig
        else
        {
          tErr # _Err.SOAPHTTPContentType;
        }
      }
      // Datengröße ungültig
      else
        tErr # _Err.SOAPHTTPContentLength;
    }

    if (tErr = _ErrOK)
    {
      tErr # tHTTP->HTTPClose(0);
    }
    else
    {
      tHTTP->HTTPClose(0);
    }
  }
  else
    tErr # tHTTP;

  if (tErr = _ErrOK and gFault)
  {
    tErr # _Err.SOAPFault;
  }

  ErrSet(tErr);

  return(tErr);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Anfrage versenden und Antwort empfangen                        +
// +                                                                +
// + Versendet und empfängt eine Nachricht. Wird in [Method] eine   +
// + Methode angegeben, wird der Nachrichtenkörper der Anfrage in   +
// + ein Methodenaufruf (RPC) geschachtelt und der                  +
// + Nachrichtenkörper der Antwort aus der Rückgabe                 +
// + (Methode + "Response") entnommen.                              +
// + In [Action] kann ein SOAPAction-Wert übergeben werden.         +
// + Wird in [ObjRqsHeader] oder [ObjRqsBody] ein Objekt für den    +
// + Nachrichtenkopf bzw. -körper der Anfrage übergeben, wird die   +
// + Nachricht aus diesen Objekten übernommen und nicht aus den     +
// + hinzugefügten Elementen und Werten zusammengesetzt.            +
// + Wird in [ObjRspHeader] oder [ObjRspBody] ein Objekt für den    +
// + Nachrichtenkopf bzw. -körper der Antwort übergeben, wird die   +
// + Nachricht in diese Objekte übernommen und nicht in Elemente    +
// + und Werte zerlegt.                                             +
// +                                                                +
// + Tritt beim Versenden der Nachricht ein Socket-Fehler auf,      +
// + beispielsweise weil der Server die Verbindung getrennt hat,    +
// + wird versucht eine neue Verbindung herzustellen und die        +
// + Nachricht erneut zu versenden.                                 +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Request // public
(
  aSOAP                 : handle;       // Instanz
  aMethod               : alpha(256);   // Methode
  opt aAction           : alpha(1024);  // SOAPAction-Wert
opt aParaHandle : handle;
  opt aObjRqsHeader     : handle;       // Header-Versanddaten (CteNode- oder Mem-Objekt)
  opt aObjRqsBody       : handle;       // Body-Versanddaten (CteNode- oder Mem-Objekt)
  opt aObjRspHeader     : handle;       // Header-Empfangsdaten (CteNode- oder Mem-Objekt)
  opt aObjRspBody       : handle;       // Body-Empfangsdaten (CteNode- oder Mem-Objekt)
)
: int;                                  /* Erfolg (= 0 = _ErrOK) /
                                           Fehler (< 0)
                                        */

  local
  {
    tResult             : alpha(256);
  }

{
  if (aMethod != '')
    tResult # aMethod + 'Response';

  try
  {
    // Anfrage versenden
    aSOAP->RqsSend(aMethod, aAction, aObjRqsHeader, aObjRqsBody, aParaHandle);
  
    // Antwort empfangen
    aSOAP->RspRecv(tResult, aObjRspHeader, aObjRspBody);
  }

  return(ErrGet());
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + SOAP-Fehler aufgetreten?                                       +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspFault // public
(
  aSOAP                 : handle;       // Instanz
)
: logic;                                // SOAP-Fehler aufgetreten
{
  aSOAP->Inst();

  return(gFault);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + SOAP-Fehlertyp ermitteln                                       +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspFaultCode // public
(
  aSOAP                 : handle;       // Instanz
)
: alpha;                                // SOAP-Fehlertyp

  local
  {
    tCteNodeFaultCode   : handle;
  }

{
  aSOAP->Inst();

  if (gCteNodeRspFault > 0)
  {
    if (gSOAPVersion = _SOAP.Version1.1)
      tCteNodeFaultCode # gCteNodeRspFault->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, 'faultcode');
    else
    {
      tCteNodeFaultCode # gCteNodeRspFault->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, gSOAPNamespacePrefix + 'Code');
      if (tCteNodeFaultCode > 0 and tCteNodeFaultCode->spID = _XMLNodeElement)
        tCteNodeFaultCode # gCteNodeRspFault->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, gSOAPNamespacePrefix + 'Value');
    }

    if (tCteNodeFaultCode > 0 and tCteNodeFaultCode->spID = _XMLNodeElement)
    {
      tCteNodeFaultCode # tCteNodeFaultCode->CteRead(_CteChildList | _CteFirst);
      if (tCteNodeFaultCode > 0 and tCteNodeFaultCode->spType = _TypeAlpha)
        return(StrCnv(tCteNodeFaultCode->spValueAlpha, _StrFromUTF8));
    }
  }

  return('');
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + SOAP-Fehlerbeschreibung ermitteln                              +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspFaultReason // public
(
  aSOAP                 : handle;       // Instanz
)
: alpha;                                // SOAP-Fehlerbeschreibung

  local
  {
    tCteNodeFaultReason : handle;
  }

{
  aSOAP->Inst();

  if (gCteNodeRspFault > 0)
  {
    if (gSOAPVersion = _SOAP.Version1.1)
      tCteNodeFaultReason # gCteNodeRspFault->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, 'faultstring');
    else
      tCteNodeFaultReason # gCteNodeRspFault->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, gSOAPNamespacePrefix + 'Reason');

    if (tCteNodeFaultReason > 0 and tCteNodeFaultReason->spID = _XMLNodeElement)
    {
      tCteNodeFaultReason # tCteNodeFaultReason->CteRead(_CteChildList | _CteFirst);
      if (tCteNodeFaultReason > 0 and tCteNodeFaultReason->spType = _TypeAlpha)
        return(StrCnv(tCteNodeFaultReason->spValueAlpha, _StrFromUTF8));
    }
  }

  return('');
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + SOAP-Fehlerdetails ermitteln                                   +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspFaultDetail // public
(
  aSOAP                 : handle;       // Instanz
)
: alpha;                                // SOAP-Fehlerdetails

  local
  {
    tCteNodeFaultDetail : handle;
  }

{
  aSOAP->Inst();

  if (gCteNodeRspFault > 0)
  {
    if (gSOAPVersion = _SOAP.Version1.1)
      tCteNodeFaultDetail # gCteNodeRspFault->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, 'faultdetail');
    else
      tCteNodeFaultDetail # gCteNodeRspFault->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, gSOAPNamespacePrefix + 'Detail');

    if (tCteNodeFaultDetail > 0 and tCteNodeFaultDetail->spID = _XMLNodeElement)
    {
      tCteNodeFaultDetail # tCteNodeFaultDetail->CteRead(_CteChildList | _CteFirst);
      if (tCteNodeFaultDetail > 0 and tCteNodeFaultDetail->spType = _TypeAlpha)
        return(StrCnv(tCteNodeFaultDetail->spValueAlpha, _StrFromUTF8));
    }
  }

  return('');
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Wert hinzufügen                                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub ValueAdd // private
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aType                 : alpha;        // Typ
  aValue                : alpha(4096);  // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
  local
  {
    tType               : alpha;
    tSOAPValue          : handle;
  }

{
  if (aName = '')
  {
    ErrSet(_ErrNameInvalid);
    return;
  }

//lib_Debug:Dbg_Debug(aName+':'+aValue);

  tSOAPValue # aSOAPElement->CteInsertNode(aName, _XMLNodeElement, NULL, 0, 0, aType);
  if (tSOAPValue > 0)
  {
    tSOAPValue->spFlags # _CteChildList | _CteAttribList | _CteAttribTree;

    tSOAPValue # tSOAPValue->CteInsertNode('', _XMLNodeText, aValue);

    tSOAPValue->spFlags # 0;

    ErrSet(_ErrOK);
  }
  else
    ErrSet(tSOAPValue);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Spezialwert hinzufügen                                         +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddCustom // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : alpha(4096);  // Wert
  aType                 : alpha;        // Typ
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, aType, aValue);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + String-Wert hinzufügen                                         +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddString // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : alpha(4096);  // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeString, aValue);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Boolean-Wert hinzufügen                                        +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddBoolean // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : logic;        // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeBoolean, BooleanWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Float-Wert hinzufügen                                          +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddFloat // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : float;        // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeFloat, FloatWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Double-Wert hinzufügen                                         +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddDouble // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : float;        // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeDouble, FloatWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Short-Wert hinzufügen                                          +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddByte // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : int;          // Wert [-128; 127]
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeByte, IntWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Vorzeichenlosen Byte-Wert hinzufügen                           +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddByteU // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : byte;         // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeUnsignedByte, IntWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Short-Wert hinzufügen                                          +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddShort // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : int;          // Wert [-32.768; 32.767]
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeShort, IntWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Vorzeichenlosen Short-Wert hinzufügen                          +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddShortU // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : word;         // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeUnsignedShort, IntWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Int-Wert hinzufügen                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddInt // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : int;          // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeInt, IntWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Long-Wert hinzufügen                                           +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddLong // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : bigint;       // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeLong, LongWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Date-Wert hinzufügen                                           +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddDate // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : date;         // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeDate, DateWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Time-Wert hinzufügen                                           +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddTime // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : time;         // Wert
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeDate, TimeWrite(aValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + DateTime-Wert hinzufügen                                       +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueAddDateTime // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  aValue                : caltime;      // Wert
  opt aTimezoned        : logic;        // Zeitzonen-behaftet
)
                                        /*
                                          _ErrExists
                                          _ErrNameInvalid
                                        */
{
  aSOAPElement->ValueAdd(aName, sSOAP.TypeDateTime, DateTimeWrite(aValue, aTimezoned));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Element ermitteln                                              +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ElementGet // public
(
  aSOAPElement          : handle;       // Elternelement
  aName                 : alpha;        // Elementname
)
: handle;                               // Element (> 0) / 0
{
  if (aSOAPElement->spFlags & _CteChildTree != 0)
    return(aSOAPElement->CteRead(_CteChildTree | _CteCmpE, 0, aName));
  else
    return(aSOAPElement->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, aName));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Element leeren                                                 +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ElementClear // public
(
  aSOAPElement          : handle;       // Elternelement
)
{
  aSOAPElement->CteClear(true);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Element lesen                                                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ElementRead // public
(
  aSOAPElement          : handle;       // Elternelement
  opt aNodeRef          : handle;       // Referenzelement
  opt aBackwards        : logic;        // Rückwärts lesen
  opt aName             : alpha;        // Elementname
)
: handle;                               // Element (> 0) / 0

  local
  {
    tSOAPElement        : handle;
  }

{
  if (aNodeRef = 0)
  {
    if (aBackwards)
      tSOAPElement # aSOAPElement->CteRead(_CteChildList | _CteSearch | _CteLast, 0, aName);
    else
      tSOAPElement # aSOAPElement->CteRead(_CteChildList | _CteSearch | _CteFirst, 0, aName);
  }
  else
  {
    if (aBackwards)
      tSOAPElement # aSOAPElement->CteRead(_CteChildList | _CteSearch | _CtePrev, aNodeRef, aName);
    else
      tSOAPElement # aSOAPElement->CteRead(_CteChildList | _CteSearch | _CteNext, aNodeRef, aName);
  }

  return(tSOAPElement);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Wert ermitteln                                                 +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueGet // private
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  var vValue            : alpha;        // Wert
)
: logic;                                // Erfolg

  local
  {
    tSOAPElement        : handle;
  }

{
  tSOAPElement # aSOAPElement->ElementGet(aName);
  if (tSOAPElement > 0)
  {
    tSOAPElement # tSOAPElement->CteRead(_CteChildList | _CteFirst);
    if (tSOAPElement > 0 and tSOAPElement->spID = _XMLNodeText and tSOAPElement->spType = _TypeAlpha)
    {
      vValue # tSOAPElement->spValueAlpha;
      return(true);
    }
  }

  vValue # '';
  return(false);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + String-Wert ermitteln                                          +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueGetString // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  var vValue            : alpha;        // Wert
)
: logic;                                // Erfolg
{
  return(aSOAPElement->ValueGet(aName, var vValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Boolean-Wert ermitteln                                         +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueGetBoolean // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  var vValue            : logic;        // Wert
)
: logic;                                /* Erfolg
                                           _ErrValueInvalid
                                        */
  local
  {
    tValue              : alpha(4096);
  }

{
  return(aSOAPElement->ValueGet(aName, var tValue) and BooleanRead(tValue, var vValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Double-Wert ermitteln                                          +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueGetDouble // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  var vValue            : float;        // Wert
)
: logic;                                /* Erfolg
                                           _ErrValueInvalid
                                        */
  local
  {
    tValue              : alpha(4096);
  }

{
  return(aSOAPElement->ValueGet(aName, var tValue) and FloatRead(tValue, var vValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Int-Wert ermitteln                                             +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueGetInt // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  var vValue            : int;          // Wert
)
: logic;                                /* Erfolg
                                           _ErrValueInvalid
                                        */
  local
  {
    tValue              : alpha(4096);
  }

{
  return(aSOAPElement->ValueGet(aName, var tValue) and IntRead(tValue, var vValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Long-Wert ermitteln                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueGetLong // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  var vValue            : bigint;       // Wert
)
: logic;                                /* Erfolg
                                           _ErrValueInvalid
                                        */
  local
  {
    tValue              : alpha(4096);
  }

{
  return(aSOAPElement->ValueGet(aName, var tValue) and LongRead(tValue, var vValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Date-Wert ermitteln                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueGetDate // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  var vValue            : date;         // Wert
)
: logic;                                /* Erfolg
                                           _ErrValueInvalid
                                        */
  local
  {
    tValue              : alpha(4096);
  }

{
  return(aSOAPElement->ValueGet(aName, var tValue) and DateRead(tValue, var vValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Time-Wert ermitteln                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueGetTime // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  var vValue            : time;         // Wert
)
: logic;                                /* Erfolg
                                           _ErrValueInvalid
                                        */
  local
  {
    tValue              : alpha(4096);
  }

{
  return(aSOAPElement->ValueGet(aName, var tValue) and TimeRead(tValue, var vValue));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + DateTime-Wert ermitteln                                        +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub ValueGetDateTime // public
(
  aSOAPElement          : handle;       // Element
  aName                 : alpha;        // Name
  var vValue            : caltime;      // Wert
)
: logic;                                /* Erfolg
                                           _ErrValueInvalid
                                        */
  local
  {
    tValue              : alpha(4096);
  }

{
  return(aSOAPElement->ValueGet(aName, var tValue) and DateTimeRead(tValue, var vValue));
}

//===== Business-Control =================================================
