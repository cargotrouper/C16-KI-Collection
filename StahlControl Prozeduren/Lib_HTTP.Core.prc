@A+
/*
===== Business-Control =================================================

Prozedur  Lib_HTTP.Core
            OHNE E_R_G
Info
Implementiert die Funktionalität zur Kommunikation mit dem
Stahl Control ApsNetCore Server zu interagieren

26.04.2019  ST  Erstellung der Prozedur
21.10.2020  AH  NetCore Anbindung
14.01.2021  ST  JsonPara: Ersestzung "&" durch "&amp;"
07.02.2022  DS  JsonFromSocket
04.05.2022  DS  UnwrapJsonResponseContentAsString(), außerdem werden jetzt in GetResponse auch HTTP StatusCodes 201 und 202 als erfolgreich gewertet
05.05.2022  DS  RequestAPI() als Universal-Wrapper zur Abfrage (ggf. externer) APIs, GetResponseLight()
09.05.2022  DS  ApiHostAndPort() um am DotNet Server das Mapping einzelner APIs auf host:port abzufragen
20.05.2022  ST  _AppHostConnectionType() hinzugefügt um einfach zwischen HTTP und HTTPs umschalten zu klönnen.
08.06.2022  DS  SplitUrl() hinzugefügt im Zuge von Proj 2407/4
19.08.2022  DS  RequestAPI() kann nun Content beliebiger Größe in Datei umleiten (statt Rückgabe als String)
2022-09-06  DS  DeleteTempFile_on_AppHost zum Löschen von Dateien im Temp Verzeichnis auf dem AppHost
2022-10-12  DS  DecodeB64CteNode, das u.A. bei __commitBusinessLogicTransaction und UnwrapJsonResponseContentAsFile hilft;
                Subprozedurenliste aktualisiert
2022-10-14  DS  executeBusinessLogicTransaction
2023-05-24  DS  JWT support, nutze dazu JwtLoginAppHost, JwtLogoutAppHost. siehe auch im repo BCS die Datei Codinghandbuch/request_api.md
2023-06-15  DS  RequestAPI und seine dependencies nutzen jetzt unser Schema zur Fehlerbehandlung und zum Respektieren von Verbosity-Wünschen des Aufrufers

Subprozeduren

JwtLoginAppHost
JwtLogoutAppHost
_AppHostConnectionType
_Connect
SendGetRequest
SendPostRequest
GetResponse
GetResponseString
Version
Ping
PlaneRsoRes
StartPDF
GetReportMetadata
GetReportPDF
ReportAcknowledge
Test
GetResponseLight
JsonFromSocket
UnwrapJsonResponseContentAsString
DecodeB64CteNode
UnwrapJsonResponseContentAsFile
RequestAPI
ApiHostAndPort
GetTempDirectory_on_AppHost
DeleteTempFile_on_AppHost
SplitUrl
__cleanup___commitBusinessLogicTransact
__commitBusinessLogicTransaction
TestAlex
__requestBusinessLogicToTransaction
executeBusinessLogicTransaction

MAIN: Benutzungsbeispiele zum Testen
========================================================================
*/
@I:Def_global
@I:Def_EDI


define begin
  sSOAP.Charset             : _CharsetUTF8
  sSOAP.CharsetStr          : 'UTF-8'

  cDarfLokal    : gUserGroup='PROGRAMMIERER'

  cLocalUrl     : 'localhost'
  cLocalPort    : 5001
  cServerUrl    : 'xxlocalhost'
  cServerPort   : 5001
end;


declare RequestAPI(Verbosity : int; var outResponseContent : alpha; var outHttpStatusCode : int; aCteRequest : handle; opt aContentOutputFilename : alpha(512)) : int
declare SplitUrl(aUrl : alpha(512); var aProtokoll : alpha; var aServer : alpha; var aPort : int; var aRoute : alpha) : logic


/*
========================================================================
2023-05-23  DS                                               2436/407

(siehe auch im repo BCS die Datei Codinghandbuch/request_api.md unter
der Section JWT für eine detailliertere Dokumentation mit Codebeispiel)

Loggt sich auf dem AppHost ein und gibt das erhaltene JWT zurück.

Das JWT kann dann bei Aufrufen von RequestAPI genutzt werden, indem es
im Knoten 'auth' als 'jwt' übergeben wird, siehe z.B.
SFX_Kasto:_getRequestBoilerplateCte im Datenraum Holzrichter_All

Beispiel eines Cte Objekts für RequestAPI, das das aus dieser Methode
JwtLoginAppHost erhaltene JWT nutzt:
  {
      "apiName": "YOUR_API_NAME",
      "timeout": 5000,
      "auth":
      {
          "method": "jwt",
          "accessToken": "YOUR_TOKEN_FROM_ARGUMENT_outJwt"
      }
      ...
  }
========================================================================+
*/
sub JwtLoginAppHost
(
  // Pflicht-Argument:
  Verbosity   : int;
  // Eigene Argumente:...
  var outJwt  : alpha;  // JWT, Verwendung siehe Doku oben.
  aUsername   : alpha(512);
  aPassword   : alpha(512);
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx         : int;          // lokales Erx für Ausgaben anderer Funktionen und Datenoperationen, siehe Lib_Error:_complain
  Erm         : alpha(4096);  // Fehlernachricht (ErrorMessage Erm), siehe Lib_Error:_complain
  // ab hier reguläre Variablen
  vCteRequest    : handle;        // Wurzel der Json Struktur für den Request
  vCteRequestCur : handle;        // cursor auf aktuelles Element
  vContent       : alpha(8192);   // vom AppHost erhaltene Antwort
  vStatusCode    : int;           // http status code, erhalten vom AppHost
end
begin

  // Request Json Objekt zusammenbauen:
  vCteRequest # CteOpen(_CteNode);
  vCteRequest->spID # _JsonNodeObject;

  // Name der API setzen
  vCteRequest->CteInsertNode('apiName', _JsonNodeString, 'apphost');
  /*
  entsprechende Zeilen für die Section "ApiConfigs" in appsettings.json des AppHost:
    "apphost": {
      "HostAndPort": "http://localhost:5700/"
    },
    ...
  */

  // Login ist ein POST request an die entsprechende Route:
  vCteRequest->CteInsertNode('apiMethod', _JsonNodeString, 'post');
  vCteRequest->CteInsertNode('apiRoute', _JsonNodeString, 'api/SysUser/Login');
  vCteRequest->CteInsertNode('timeout', _JsonNodeNumber, 5000);

  // auth credentials werden zum Login per Post im Body übergeben.
  // entsprechendes Unterobjekt (dictionary) an Wurzel hängen...
  vCteRequestCur # vCteRequest->CteInsertNode('postBody', _JsonNodeObject, NULL);
  // ...und auth Info dort einfügen
  vCteRequestCur->CteInsertNode('Username', _JsonNodeString, aUsername);
  vCteRequestCur->CteInsertNode('Password', _JsonNodeString, aPassword);


  // DEBUG: json string serialisieren auf festplatte
  //vCteRequest->JsonSave('C:\Debug\jwtLoginAppHost_in.json');


  // --------------------------
  // Request an API
  // --------------------------

  // boilerplate der Fehlermeldungen
  Erm # 'Login auf AppHost fehlgeschlagen.' + cCrlf2 + 'Grund:' + cCrlf;

  Erx # RequestAPI(Verbosity, var vContent, var vStatusCode, vCteRequest);
  if Erx <> _ErrOK then
  begin
    Erm # Erm + 'Fehlercode ' + aint(Erx) + ' erhalten aus RequestAPI.';
    complain(Verbosity, Erm);
    return Erx;
  end

  if vStatusCode <> 200 then
  begin
    Erm # Erm + 'Aufruf endete mit unerwartetem HTTP StatusCode: ' + aint(vStatusCode) + ' und folgender Antwort/Content:' + cCrlf2 +  '"' + vContent + '"';
    complain(Verbosity, Erm);
    return cErxSFX;
  end

  //DebugM('vStatusCode: ' + aint(vStatusCode));
  //DebugM('vContent: ' + vContent);

  outJwt # vContent;
  return _ErrOK;
end



/*
========================================================================
2023-05-23  DS                                               2436/407

(siehe auch im repo BCS die Datei Codinghandbuch/request_api.md unter
der Section JWT für eine detailliertere Dokumentation mit Codebeispiel)

Loggt das übergebene JWT aus dem AppHost aus.
========================================================================+
*/
sub JwtLogoutAppHost
(
  // Pflicht-Argument:
  Verbosity   : int;
  // Eigene Argumente:...
  aJwt  : alpha(4096);  // auszuloggendes JWT
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx         : int;          // lokales Erx für Ausgaben anderer Funktionen und Datenoperationen, siehe Lib_Error:_complain
  Erm         : alpha(4096);  // Fehlernachricht (ErrorMessage Erm), siehe Lib_Error:_complain
  // ab hier reguläre Variablen
  vCteRequest    : handle;        // Wurzel der Json Struktur für den Request
  vCteRequestCur : handle;        // cursor auf aktuelles Element
  vContent       : alpha(8192);   // vom AppHost erhaltene Antwort
  vStatusCode    : int;           // http status code, erhalten vom AppHost
end
begin

  // Request Json Objekt zusammenbauen:
  vCteRequest # CteOpen(_CteNode);
  vCteRequest->spID # _JsonNodeObject;

  // Name der API setzen
  vCteRequest->CteInsertNode('apiName', _JsonNodeString, 'apphost');

  // Logout ist ein POST request an die entsprechende Route:
  vCteRequest->CteInsertNode('apiMethod', _JsonNodeString, 'post');
  vCteRequest->CteInsertNode('apiRoute', _JsonNodeString, 'api/SysUser/Logout');
  vCteRequest->CteInsertNode('timeout', _JsonNodeNumber, 5000);

  // Logout erfolgt autorisiert, auf Grundlage des per arg erhaltenen JWT:
  // auth Unterobjekt (dictionary) an Wurzel hängen...
  vCteRequestCur # vCteRequest->CteInsertNode('auth', _JsonNodeObject, NULL);
  // ...und auth Info dort einfügen
  vCteRequestCur->CteInsertNode('method', _JsonNodeString, 'jwt');
  vCteRequestCur->CteInsertNode('accessToken', _JsonNodeString, aJwt);

  // DEBUG: json string serialisieren auf festplatte
  //vCteRequest->JsonSave('C:\Debug\jwtLogoutAppHost_in.json');


  // --------------------------
  // Request an API
  // --------------------------

  // boilerplate der Fehlermeldungen
  Erm # 'Logout aus AppHost fehlgeschlagen.' + cCrlf2 + 'Grund:' + cCrlf;

  Erx # RequestAPI(Verbosity, var vContent, var vStatusCode, vCteRequest);
  if Erx <> _ErrOK then
  begin
    Erm # Erm + 'Fehlercode ' + aint(Erx) + ' erhalten aus RequestAPI.';
    complain(Verbosity, Erm);
    return Erx;
  end

  if vStatusCode <> 200 then
  begin
    Erm # Erm + 'Aufruf endete mit unerwartetem HTTP StatusCode: ' + aint(vStatusCode) + ' und folgender Antwort/Content:' + cCrlf2 +  '"' + vContent + '"';
    complain(Verbosity, Erm);
    return cErxSFX;
  end

  //DebugM('vStatusCode: ' + aint(vStatusCode));
  //DebugM('vContent: ' + vContent);

  return _ErrOK;
end



//========================================================================
//  Gibt das gewünschte Protokollformat zurück.
//
//  Die Verbindung zum Apphost im eigenen Netzwerk muss nicht per SSL
//  verschlüsselt sein. Für interne Szenarien ist http ausreichend.
//
//  Sollte dies irgendwann erforderlich sein, kann dies in dieser Funktion
//  zentral gelöst werden
//========================================================================
sub _AppHostConnectionType() : alpha
begin
  RETURN 'http://';
  //RETURN 'HTTPS://';
end


//========================================================================
//  Stellt die Socketverbindung her
//========================================================================
sub _Connect(
  aType     : alpha;           // https:// || http://
  aHost     : alpha(512);      // localhost
  opt aPort : int;             // 44371
  opt aTimeout : int;
  opt aDontUseTLS : logic;
) : int
local begin
  vHttps  : logic;
  vSocket : int;
end
begin
  if (aType <> 'http://') AND (aType <> 'https://') then
    RETURN _ErrData;

  vHttps  # (aType = 'https://');

  if (aPort = 0) then begin
    if (vHttps) then
      aPort # 443;
    else
      aPort # 80;
  end;

  // ST 2022-05-20
  if (aDontUseTLS = false) and (vHttps = false)  then
    aDontUseTLS # true;

  if (aTimeout=0) then aTimeout # 5000;
  if aDontUseTLS then begin
    vSocket # SckConnect(aHost, aPort, 0, aTimeout);
  end else begin
    vSocket # SckConnect(aHost, aPort,_SckTlsMed, aTimeout);
  end

  RETURN vSocket;
end;


//========================================================================
// Sendet eine GET Anfrage an die übergebene URL
//========================================================================
sub SendGetRequest(
  aType     : alpha;           // https:// || http://
  aHost     : alpha(512);      // localhost
  aURI      : alpha(4096);     // api/Sysuser/...
  opt aPort : int;             // 44371
  opt aTimeout : int;
) : int
local begin
  vHttps  : logic;
  vSocket : int;
  vRequest : int;
  vHeader : int;
end;
begin

  TRY begin
    // Verbindung aufbauen
    vSocket # _Connect(aType,aHost,aPort, aTimeout);

    // Anfrage erzeugen
    vRequest # HttpOpen(_HttpSendRequest,vSocket);
    vHeader  # vRequest->spHttpHeader;
    vRequest->spMethod   # 'GET';
    vRequest->spURI      # aURI;
    vRequest->spProtocol # 'HTTP/1.1';
    vHeader ->CteInsertItem('Host',0,aHost);
    vHeader ->CteInsertItem('Accept',0,'*/*');

    // Anfrage senden
    vRequest->HttpClose(_HttpCloseConnection);
    vRequest # 0;
  END;

  RETURN vSocket;
end;


//========================================================================
//  WICHTIG: übergebener json body in aBodyDataJsn wird durch diese
//           Methode gelöscht und das handle aBodyDataJsn ungültig
//
//  Versendet eine HTTP Post Anfrage mit Json Daten im Messagebody
//========================================================================
sub SendPostRequest(          // Beispiele:
  aType     : alpha;          // https:// || http://
  aHost     : alpha(512);     // localhost
  aURI      : alpha(4096);    // api/Sysuser/...
  aBodyDataJsn    : handle;   // Json Handle für Post Daten
  opt aPort       : int;
  opt aParaHandle : int;
  opt aDontUseTLS : logic;
  opt aTimeout    : int;      // timeout der Verbindung
) : int   // <=0 Fehler, sonst Socket
local begin
  vHttps  : logic;
  vSocket : int;
  vRequest : int;
  vHeader : int;
  vJsonAsMem : int;
  vTxt      : int;
  vI, vJ    : int;
  tMem      : handle;
end;
begin

  TRY begin
    // Verbindung aufbauen
    vSocket # _Connect(aType, aHost, aPort, aTimeout, aDontUseTLS);

    // Anfrage erzeugen
    vRequest # HttpOpen(_HttpSendRequest,vSocket);
    vHeader  # vRequest->spHttpHeader;

    vRequest->spMethod   # 'POST';
    vRequest->spURI      # aURI;
    vRequest->spProtocol # 'HTTP/1.1';
    vHeader->CteInsertItem('Host',0,aHost+':'+Aint(aPort));
    vHeader->CteInsertItem('Content-Type',0,'application/json');

    // Anfrage senden
    vJsonAsMem  # Lib_JSON:JSON_toMemObj(aBodyDataJsn);

    // Falls ein JSON-Parahandle vorhandne ist, diesen nun einfügen an Stelle des Platzhalters "XxX_PARA_XxX"
    if (aParaHandle<>0) then begin
      // den JSON-ParaHandle in eigenes MemObj serialisieren...
      tMem # MemAllocate(_MemAutoSize);
      tMem->spCharset # sSOAP.Charset;
      vI # aParaHandle->JSONSave('',_JsonSavePure, tMem, sSOAP.Charset);  // purEeee

      Lib_Texte:MemReplace(var tMem, '"', '\"');    // 19.10.2020 AH: besser so!
      Lib_Texte:MemReplace(var tMem, '&', '\&');    // ST 2021-01-14 2187/2

/*
  TextSearch(vTxt, 1, 1, _textSearchCI, '&', '&amp;');   // JSON nach XML-Formatierung      // ST 2021-01-14 2187/2
*/

/***
      // Problem: JSON hat Anführungszeichen, aber in XML müssen diese "&quot;" sein!
      // Also das MemObj in einen Textbuffer schieben, dort die Zeichenumwandlungen mamchen und so wieder zurück in das MemObj
      vTxt # TextOpen(16);
      Lib_Texte:ReadFromMem(vTxt, tMem, 1, _MemDataLen);
TextWrite(vTxt,'',_textclipboard);
todo('A');
//      TextSearch(vTxt, 1, 1, _textSearchCI, '"', '&quot;');   // JSON nach XML-Formatierung
//      vI # TextSearch(vTxt, 1, 1, _textSearchCI, StrChar(250), '\"');   // JSON nach XML-Formatierung
debugx('Ersetzt:'+aint(vI));
TextWrite(vTxt,'',_textclipboard);
todo('B');

      tMem->MemFree();
      tMem # MemAllocate(_MemAutoSize);
      tMem->spCharset # sSOAP.Charset;
      Lib_Texte:WriteToMem(vTxt, tMem);
      TextClose(vTxt);
***/

      // JSON-MemObj an Stelle des Platzhalter in das XML einkopieren...
      vI # MemFindStr(vJsonAsMem, 1, vJsonAsMem->spLen, 'XxX_PARA_XxX');
      vJ # vJsonAsMem->spLen;
      vJsonAsMem->MemResize(vJsonAsMem->spLen + tMem->spLen-12);        // Platz vergößern
      vJsonAsMem->MemCopy(vI+12, vJ-vI-12+1, vI+tMem->spLen);     // nach Rechts schieben (von, anzahl, ziel)
      tMem->MemCopy(1, tMem->spLen, vI, vJsonAsMem);              // einfügen
      tMem->MemFree();
    end;

//vTxt # TextOpen(16);
//Lib_Texte:ReadFromMem(vTxt, vJsonAsMem, 1, _MemDataLen);
//TextWrite(vTxt,'',_textclipboard);
//TextClose(vTxt);

    vRequest->HttpClose(_HttpCloseConnection | _HttpSkipChunked, vJsonAsMem);
    MemFree(vJsonAsMem);

    Lib_JSON:CloseJSON(var aBodyDataJsn);

    vRequest # 0;
  END;


  RETURN vSocket;
end;



//========================================================================
//  Liest die einen HTTP Response und gibt die anliegenden Daten als
//  Handle auf ein MemObjekt (Standard) oder ein Fsi FileHandler zurück
//========================================================================
sub GetResponse(
  aSocket : int;
  opt aDestFilename : alpha(4096);
  opt aMemobj : handle;
  opt aErrorMsgIfNotStatus200ish : logic;  // wenn true, wird im Falle eines StatusCode != 200 bzw. != 200-artiger Erfolg-bedeutender Codes
                                           // eine MsgBox mit Fehler und dem StatusCode geöffnet, die den body als Fehlermeldung anzeigt.
) : int
local begin
  vResponse     : int;
  vRetHdl       : int;

  vSize    : int;
  vSizeOld : int;

  vErrHdl      : handle;  // handle auf Text der Fehlermeldung, falls aErrorMsgIfNotStatus200ish==True und ein non-200ish StatusCode kommt
end
begin
  if (aSocket<=0) then RETURN -1;

  vResponse  # HttpOpen(_HttpRecvResponse,aSocket);
  if (vResponse > 0) then begin

    // Es wird eine vorsichtige Teilmenge der auf https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#successful_responses
    // als erfolgreich klassifizierten Status Codes als Erfolg akzeptiert:
    if (CnvIa(vResponse->spStatusCode) = 200) or
       (CnvIa(vResponse->spStatusCode) = 201) or
       (CnvIa(vResponse->spStatusCode) = 202)
    then
    begin
      if (aDestFilename <> '') then begin
        // ggf als Datei speichern
        vRetHdl  # FsiOpen(aDestFilename,_FsiStdWrite);
        vResponse->HttpGetData(vRetHdl);
      end
      else begin
          // ansonsten als MemObject zurückgeben
        if (aMemObj=0) then
          vRetHdl   # MemAllocate(_MemAutoSize)
        else
          vRetHdl   # aMemObj;
        REPEAT
          vSizeOld # vRetHdl->spSize;
          vResponse->HttpGetData(vRetHdl);
          vSize # vRetHdl->spSize;
        UNTIL (vSize = vSizeOld);
      end;

    end else begin
      // StatusCode ist nicht 200ish, also prüfe ob body als Fehler ausgegeben werden soll
      if (aErrorMsgIfNotStatus200ish) then begin

        // string wie oben auspacken und in neues memobj etc. speichern.
        // dann in fehlermeldung anzeigen, damit man hinweise auf fehlerursache bekommt.

        vErrHdl # MemAllocate(_MemAutoSize);

        REPEAT
          vSizeOld # vErrHdl->spSize;
          vResponse->HttpGetData(vErrHdl);
          vSize # vErrHdl->spSize;
        UNTIL (vSize = vSizeOld);

        WinDialogBox(0,
          'StatusCode ' + vResponse->spStatusCode + ' in GetResponse(). Fehlermeldung:',
          vErrHdl->MemReadStr(1, min(4096, vErrHdl->spSize)),  // der aus vErrHdl gelesene Response Body, ggf. auf seine ersten 4k Zeichen verkürzt
          _WinIcoError,
          _WinDialogOK,
          1
        );

        MemFree(vErrHdl);
        vErrHdl # -1;
      end
    end
    vResponse->HttpClose(0);
  end
  else begin
    vRetHdl # -1;
  end;

  RETURN vRetHdl;
end


//========================================================================
//  Liest die ersten 4096 Zeichen einer HTTP Antwort aus dem übergebenen
//  Socket mithilfe eines MemObjektes
//========================================================================
sub GetResponseString(
  aSocket      : int;   // Socket zur HTTP Verbindung
  opt aCharset : int;
  opt aErrorMsgIfNotStatus200ish : logic;  // siehe entsprechender Parameter von GetResponse()
) : alpha
local begin
  vRet      : alpha(4096);
  vMemObj   : int;
  vMemSize  : int;
end
begin
  vMemObj # GetResponse(aSocket, '', 0, aErrorMsgIfNotStatus200ish);

  if (vMemObj > 0) then begin
    vMemSize  # vMemObj->spSize;
    if (vMemSize > 4096) then
      vMemSize  # 4096;

    vRet # vMemObj->MemReadStr(1,vMemSize,aCharset);
  end;

  RETURN StrAdj(vRet,_StrBegin | _StrEnd);
end;


//========================================================================
//========================================================================
sub Version() : alpha;
local begin
  vX              : int;
  vA              : alpha;
end
begin

  // Server schon geklärt?
  if (gNetServerUrl<>'') then begin
    vX  # SendGetRequest(_AppHostConnectionType(), gNetServerUrl,'/api/Report/Version', gNetServerPort, 1000);
    vA  # GetResponseString(vX);
    RETURN vA;
  end;

  if (cDarfLokal) then begin
    vX  # SendGetRequest(_AppHostConnectionType(), cLocalUrl, '/api/Report/Version', cLocalPort, 1000);
    vA  # GetResponseString(vX);
    if (vA<>'') then begin
      gNetServerUrl   # cLocalUrl;
      gNetServerPort  # cLocalPort;
      RETURN vA;
    end;
  end;

  vX  # SendGetRequest(_AppHostConnectionType(), cServerUrl, '/api/Report/Version', cServerPort, 1000);
  vA  # GetResponseString(vX);
  if (vA<>'') then begin
    gNetServerUrl   # cServerUrl;
    gNetServerPort  # cServerPort;
  end;
  RETURN vA;
end;


//========================================================================
//========================================================================
sub Ping() : alpha;
local begin
  vX              : int;
  vA              : alpha;
end
begin
  // Server schon geklärt?
  if (gNetServerUrl<>'') then begin
    vX  # SendGetRequest(_AppHostConnectionType(), gNetServerUrl, '/api/Report/Ping', gNetServerPort, 100);
    vA  # GetResponseString(vX);
  end
  else begin
    if (cDarfLokal) then begin
      vX  # SendGetRequest(  _AppHostConnectionType(), cLocalUrl, '/api/Report/Ping', cLocalPort, 100);
      vA  # GetResponseString(vX);
      if (vA<>'') then begin
        gNetServerUrl   # cLocalUrl;
        gNetServerPort  # cLocalPort;
      end;
    end;

    if (gNetServerUrl='') then begin
      vX  # SendGetRequest(  _AppHostConnectionType(), cServerUrl, '/api/Report/Ping', cServerPort, 100);
      vA  # GetResponseString(vX);
      if (vA<>'') then begin
        gNetServerUrl   # cServerUrl;
        gNetServerPort  # cServerPort;
      end;
    end;
  end;

  if (vA='true') then vA # 'OK';
  RETURN vA;
end;


//========================================================================
//========================================================================
sub PlaneRsoRes(
  aResNr          : int;
  aGrenze         : CalTime;
  aAntwort        : alpha;
  var aRequestID  : bigint;
  aUsername       : alpha;
  aPlantyp        : alpha) : alpha;
local begin
  vJSON           : int;
  vX              : int;
  vA              : alpha(1000);
end;
begin

  vJSON # Lib_Json:OpenJSON();
  Lib_Json:AddJsonAlpha(vJSON,  'Planungstyp',          aPlantyp);
  Lib_Json:AddJsonInt(vJSON,    'RessourceNr',          aResNr);
  Lib_Json:AddJsonDate(vJSON,   'Grenze',               aGrenze->vpdate);
  Lib_Json:AddJsonInt(vJSON,    'CallbackID',           aRequestID);
  Lib_Json:AddJsonAlpha(vJSON,  'MsgUser',              aUsername);
  Lib_Json:AddJsonAlpha(vJSON,  'Antwortcode',          aAntwort);
  Lib_Json:AddJsonBool(vJSON,   'IsDebug',              true);

  vX  # SendPostRequest(_AppHostConnectionType(), gNetServerUrl, '/api/Ressource/PlaneReservierung/C16Callback', vJSON, gNetServerPort);
  vA # GetResponseString(vX);
//debugx(vA);
  RETURN vA;
end;


//========================================================================
//========================================================================
sub StartPDF(
  aName           : alpha;
  aFrxfile        : alpha(1000);
  aOutput         : alpha(1000);
  aOutputTypes    : alpha;
  aBackgroundPic  : alpha(1000);
  aMark           : alpha(1000);
  aRecipient      : alpha(1000);
  aParaHdl        : handle;
  ) : alpha;
local begin
  vDepth          : int;
  vJSON           : handle;
  vSettings       : alpha(4096);
  vX              : int;
  vA              : alpha(8192);
  vPath           : alpha(1000);
  vI              : int;
  vErr            : alpha(1000);
end
begin

  vDepth # 5;
  if (Lfm.Kuerzel = 'Rso') then vDepth # 10; // 2017-08-07 TM zum Testen

  vSettings # Lib_JSON:CreatePrintServerSettings();

  vJSON # Lib_Json:OpenJSON();
  Lib_Json:AddJsonInt(vJSON,    'LinkDepth',            vDepth);
  Lib_Json:AddJsonInt(vJSON,    'EigeneAdressNummer',   Set.EigeneAdressnr);
  Lib_Json:AddJsonAlpha(vJSON,  'EigenerUser',          gUsername);
  Lib_Json:AddJsonAlpha(vJSON,  'Name',                 aName);
  Lib_Json:AddJsonAlpha(vJSON,  'FrxFile',              aFrxFile);
  Lib_Json:AddJsonAlpha(vJSON,  'JobIdFromPath',        aOutput);
  Lib_Json:AddJsonAlpha(vJSON,  'OutputTypes',          aOutputtypes);   // PDF,XML,DOC
  Lib_Json:AddJsonAlpha(vJSON,  'BackgroundPic',        aBackgroundPic);
  Lib_Json:AddJsonAlpha(vJSON,  'Mark',                 aMark);
  Lib_Json:AddJsonAlpha(vJSON,  'Recipient',            aRecipient);
  Lib_Json:AddJsonAlpha(vJSON,  'ParaObjectString',     'XxX_PARA_XxX');
  Lib_Json:AddJsonAlpha(vJSON,  'SettingsObjectString', vSettings);

  vX  # SendPostRequest(_AppHostConnectionType(), gNetServerUrl, '/api/Report/StartPdf', vJSON, gNetServerPort, aParaHdl);
  vA # GetResponseString(vX);
//debugx('StartPDF '+vA);
  RETURN vA;
end;


//========================================================================
//========================================================================
sub GetReportMetadata(
  aPrintJobID : alpha;
  var aJson   : alpha) : logic;
local begin
  vX              : int;
  vJSON           : int;
end
begin

  vX # SendGetRequest(_AppHostConnectionType(), gNetServerURL, '/api/Report/GetReportMetadata/' + aPrintJobId, gNetServerPort,1000);
  aJson # GetResponseString(vX);
  RETURN (aJson<>'');
end;


//========================================================================
//========================================================================
sub GetReportPDF(
  aPrintJobID : alpha;
  var aMemobj : handle;   // für Base64kodiertes BLOB
  ) : logic
local begin
  vSock           : int;
  vA              : alpha;
end
begin
  vSock # SendGetRequest(_AppHostConnectionType(), gNetServerUrl, '/api/Report/GetReportPDF/' + aPrintJobID, gNetServerPort, 1000);
  if (vSock>0) then begin
    aMemObj # GetResponse(vSock, '', aMemObj);
    RETURN true;
  end;
  RETURN false;
end;


//========================================================================
//========================================================================
sub ReportAcknowledge(
  aPrintJobID : alpha) : handle;
local begin
  vX              : int;
  vA              : alpha;
end
begin
  vX  # SendGetRequest(_AppHostConnectionType(), gNetServerUrl,'/api/Report/ReportAcknowledge/' + aPrintJobID, gNetServerPort, 1000);
  RETURN vX;
//  vA  # GetResponseString(vX);
end;


//========================================================================
//  call Lib_http.Core:test
//  Enthält Beispiele für die Nutzung der Lib
//========================================================================
sub Test()
local begin
  vPath : alpha(1000);
  vX  : int;
  vHdl  : int;
  vA  : alpha(2000);
  vJson : handle;
end begin

  vPath # 'c:\debug\debug_http.txt';
  vX    # SendGetRequest(_AppHostConnectionType(), gNetServerUrl, '/api/Report/Ping', gNetServerPort);
  vHdl  # GetResponse(vX, vPath);


  todo('ping DONE');
  vX  # SendGetRequest('https://', gNetServerUrl, '/api/Report/Version', gNetServerPort);
  vA # GetResponseString(vX);
  todo('version DONE: ' + StrChar(10) + vA);


  vJSON # Lib_Json:OpenJSON();
  Lib_Json:AddJsonInt(vJSON,    'LinkDepth',          5);
  Lib_Json:AddJsonInt(vJSON,    'EigeneAdressNummer', 1386);
  Lib_Json:AddJsonAlpha(vJSON,  'EigenerUser', 'ST');
  Lib_Json:AddJsonAlpha(vJSON,  'Name',             'AB');
  Lib_Json:AddJsonAlpha(vJSON,  'FrxFile',          'p:\STD\FRX\STD_AufBest.frx');
  Lib_Json:AddJsonAlpha(vJSON,  'jobIdFromPath','myJObPath');   // !!
  Lib_Json:AddJsonAlpha(vJSON,  'outputTypes',      'MEMDB_PDF');
  Lib_Json:AddJsonAlpha(vJSON,  'mark','');
  Lib_Json:AddJsonAlpha(vJSON,  'recipient',        'KD+AP');
  Lib_Json:AddJsonAlpha(vJSON,  'paraObjectString','{}');
  Lib_Json:AddJsonAlpha(vJSON,  'settingsObjectString','{}');

  vX  # SendPostRequest(_AppHostConnectionType(), gNetServerUrl,'/api/Report/StartPdf',vJSON, gNetServerPort);
  vA  # GetResponseString(vX);
  todo('PrintPDF DONE: ' + StrChar(10) + vA);
end;



//========================================================================
//  Liest eine HTTP Response und gibt die anliegenden Daten als
//  Handle auf ein MemObjekt zurück.
//  Anders als bei GetResponse() werden keine HTTP StatusCodes
//  ausgewertet, sondern lediglich in var aStatusCode zurückgegeben.
//  Daher der Name ...Light().
//========================================================================
sub GetResponseLight
(
  aSocket         : int;
  var aStatusCode : int;
  opt aCharset    : int;
) : handle
local begin
  vResponse       : int;
  vRetHdl         : int;
  vSize           : int;
  vSizeOld        : int;
end
begin

  if (aSocket<=0) then RETURN -1;

  vResponse # HttpOpen(_HttpRecvResponse, aSocket);

  if (vResponse > 0) then
  begin

    aStatusCode # CnvIA(vResponse->spStatusCode);

    vRetHdl # MemAllocate(_MemAutoSize)
    if (aCharset<>0) then
      vRetHdl->spCharset # aCharSet;

    REPEAT
      vSizeOld # vRetHdl->spSize;
      vResponse->HttpGetData(vRetHdl);
      vSize # vRetHdl->spSize;
    UNTIL (vSize = vSizeOld);

    vResponse->HttpClose(0);
  end

  RETURN vRetHdl;
end


//========================================================================
//  Liest JSON Body der von der übergebenen bestehenden Socket Verbindung
//  erhalten wird als JSON CTE Objekt ein und gibt die Wurzel dieses JSON
//  Objektes zurück.
//  Kann genutzt werden zur Entgegennahme von POST Responses aus dem
//  Core3 AppHost.
//
//  Siehe SFX_Laufzeiten in BSC_Hagen für ein praktisches Beispiel.
//
//  Nimmt ein Socket (aSocket) als Eingabe, für das angenommen wird, dass
//  dessen Antwort (Ausgabe von GetResponseLight())
//  ein json string ist.
//  Die Wurzel des daraus geladenen JSON Cte-Baumes wird zurückgegeben.
//
//  Der Aufrufer ist dafür verantwortlich, den zurückgegebenen Baum
//  nach Verwendung wieder abzuräumen.
//
//========================================================================
sub JsonFromSocket(
  // Pflicht-Argument:
  Verbosity                               : int;
  // Eigene Argumente:
  var outResponseJsonCte                  : handle;       // Wurzel des Json Cte Objektes der Response, bzw. -1 bei Fehler.
  var outStatusCode                       : int;          // hierin wird der HTTP StatusCode zurückgegeben
  aSocket                                 : int;          // Socket zur HTTP Verbindung
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx     : int;
  Erm     : alpha(4096);
  // ab hier reguläre Variablen
  vResponseMemObj                         : handle;       // Response String als Memory Object, benötigt für JSONLoad damit auch Antworten > 4k verarbeitet werden können
end;
begin

  // ---------------------------------------------------------------
  // Response json aus socket holen und einlesen
  // ---------------------------------------------------------------

  // hole Response als Memory Object aus aSocket
  // (damit JSONLoad() aus dem Speicher laden kann, wird der json string in einem memory object, nicht als Alpha array, benötigt)
  //
  // alte Version:
  //vResponseMemObj # GetResponse(aSocket, '', 0, true);
  //
  // neue Version: vereinfachter Eigennachbau von GetResponse, der sich mehr aus allem raushält und bei der entsprechend die Fehlerbehandlung
  // nachher stattfinden muss.
  vResponseMemObj # GetResponseLight(aSocket, var outStatusCode);


  // DEBUG Ausgabe der Response bevor sie als Json interpretiert wird:
  /*
  WinDialogBox(0,
    'DEBUG OUTPUT',
    'StatusCode ' + aint(outStatusCode) + ' erhalten aus GetResponseLight().' + cCrlf2 +
    'Erhaltener Content:' + cCrlf +
    vResponseMemObj->MemReadStr(1, min(4096, vResponseMemObj->spSize)),  // der aus vResponseMemObj gelesene Response Body, ggf. auf seine ersten 4k Zeichen verkürzt
    _WinIcoInformation,
    _WinDialogOK,
    1
  );
  */


  // Der folgende Code lädt die vom Server erhaltene json-formatierte Response, analog zu Bsp. "JSONLoadFromFile" auf
  // der nachfolgenden Seite, allerdings wird im folgenden Code aus dem Speicher geladen statt von Festplatte.
  // https://www.vectorsoft.de/blog/2011/10/json/

  // Json Objekt für Response des API Aufrufs anlegen
  outResponseJsonCte # CteOpen(_CteNode);

  Erx # outResponseJsonCte->JSONLoad('', 0, vResponseMemObj);
  //Erx # vResponseJsonCte->JSONLoad('C:\debug\sfx_laufzeiten.json');

  if Erx <> _ErrOK then
  begin

    // Output invalidieren
    outResponseJsonCte # -1;

    if Erx > _ErrOK then
    begin
      // Fehlerposition melden (weil Erx > _ErrOK)
      Erm # __PROCFUNC__ + ': Fehler im JSON-String aus der vom Socket erhaltenen Response. Fehlerposition: ' + aint(Erx) + cCrlf2 +
        'Bei Fehlerposition 1 bitte auch prüfen, ob der Server des Sockets läuft.';
    end
    else if Erx < _ErrOK then
    begin
      // Fehlercode melden (weil Erx < _ErrOK)
      Erm # __PROCFUNC__ + ': Fehler im JSON-String aus der vom Socket erhaltenen Response. Fehlercode: ' + aint(Erx);
    end

    complain(Verbosity, Erm);
    return Erx;

  end

  //DebugM('JSON-String aus der vom Socket erhaltenen Response wurde erfolgreich geladen.');

  // Wurzel der Cte Struktur zurückgeben
  return _ErrOK;

end;



/*
========================================================================
2022-05-04  DS                                               2407/1

UnwrapJsonResponseContentAsString dekodiert den von JsonFromSocket
über AppHost's request endpoint erhaltenen Json Baum, gibt dessen
StatusCode als return Value zurück und schreibt dessen content in
die übergebene Variable aContent
========================================================================
*/
sub UnwrapJsonResponseContentAsString
(
  aCteJsonResponse        : handle;  // Wurzel eines von JsonFromSocket über AppHost's request endpoint erhaltenen Json Baums
  var aContent            : alpha;   // Content String der aus aCteJsonResponse extrahiert wurde
) : int  // HTTP Status Code der aus aCteJsonResponse extrahiert wurde
local begin
  vStatusCode : int;
  vContentB64 : alpha(4096);
end
begin

  //aCteJsonResponse->JsonSave('C:\debug\response_wrapped.json');

  vStatusCode # aCteJsonResponse->CteRead(_CteFirst | _CteSearch, 0, 'StatusCode')->spValueInt;
  vContentB64 # aCteJsonResponse->CteRead(_CteFirst | _CteSearch, 0, 'ContentB64')->spValueAlpha;
  aContent # StrCnv(vContentB64, _StrFromBase64 | _StrFromUTF8);

  //DebugM('StatusCode: ' + aint(vStatusCode));
  //DebugM('ContentB64: ' + vContentB64);
  //DebugM('DEBUG_ContentPlain: ' + aCteJsonResponse->CteRead(_CteFirst | _CteSearch, 0, 'DEBUG_ContentPlain')->spValueAlpha);
  //DebugM('aContent: ' + aContent);

  return vStatusCode;

end



/*
========================================================================
2022-10-12  DS

Dekodiert Cte Nodes die einen B64 String beinhalten und gibt den
dekodierten Inhalt als MemObj zurück
========================================================================
*/
sub DecodeB64CteNode
(
  var outMemObj : handle;   // Ausgabe-MemObj das den dekodierten CteNodeValueAlpha aus aCteB64 enthält
  aCteB64       : handle;   // Cte Node dessen Alpha Value B64-kodierte Daten enthält (z.B. Text, Json oder auch Binärdaten)
) : int  // Erx
local begin
  Erx         : int;
  vMemObjB64  : handle;
end
begin

  if outMemObj > 0 then return cErxSTD;  // kein bereits benutzes MemObj akzeptieren

  // die B64 kodierten Daten (z.B. aus Content aus Antworten von Webservern) können beliebig groß werden und insbesondere die Größen von Strings
  // sprengen, die C16 normalerweise problemlos verarbeiten kann.
  // Um dies zu umgehen, wird der Inhalt zunächst mittels der Methode CteNodeValueAlpha() (statt "->spValueAlpha") in ein MemoryObject geschrieben...
  vMemObjB64 # MemAllocate(_MemAutoSize);
  aCteB64->CteNodeValueAlpha(vMemObjB64, _CteNodeValueRead);  // Rückgabewert ist laut Doku ohnehin immer _ErrOk, Fehler fliegen ggf. als Laufzeitfehler
  //... das dann in das Ausgabe-MemoryObject dekodiert wird...
  outMemObj # MemAllocate(_MemAutoSize);
  if vMemObjB64->MemCnv(outMemObj, _MemDecBase64) <> _ErrOK then
  begin
    vMemObjB64->MemFree();
    outMemObj->MemFree();
    return cErxSTD;  // b64 konnte nicht dekodiert werden werden
  end

  // clean up
  vMemObjB64->MemFree();

  return _ErrOK;

end


/*
========================================================================
2022-08-17  DS                                               2407/7

UnwrapJsonResponseContentAsFile dekodiert den von JsonFromSocket
über AppHost's request endpoint erhaltenen Json Baum, gibt dessen
StatusCode als return Value zurück (oder einen negativen Fehlercode,
Bedeutung siehe Kommentare an den return statements im Code) und schreibt dessen
content in die Datei deren Name als aContentOutputFilename übergeben wurde.
Dies geschieht auf Basis des B64-kodierten Content Feldes 'ContentB64'
in der Antwort, das dekodiert wird.
Das funktioniert insbesondere...
* ohne Probleme der Sorte "UTF8 vs. Windows Codepages vs. C16 encoding"
* auch für Contents beliebiger Länge jenseits der 4096 bzw. 8192 Zeichen
* für Contents die kein Json sind.
========================================================================
*/
sub UnwrapJsonResponseContentAsFile
(
  aCteJsonResponse       : handle;      // Wurzel eines von JsonFromSocket über AppHost's request endpoint erhaltenen Json Baums
  aContentOutputFilename : alpha(512);  // Der Content string der aus aCteJsonResponse extrahiert wurde, wird in diese Datei geschrieben
                                        // Dieser Content muss nicht notwendigerweise .json sein und darf beliebige Länge > 4096 Zeichen haben
) : int  // HTTP Status Code der aus aCteJsonResponse extrahiert wurde
local begin
  vStatusCode       : int;
  vNodeContentB64   : handle;
  vMemObjContent    : handle;
  vFileHdl          : handle;
end
begin

  //aCteJsonResponse->JsonSave('C:\debug\response_wrapped.json');

  vStatusCode # aCteJsonResponse->CteRead(_CteFirst | _CteSearch, 0, 'StatusCode')->spValueInt;

  vNodeContentB64 # aCteJsonResponse->CteRead(_CteFirst | _CteSearch, 0, 'ContentB64');

  if DecodeB64CteNode(var vMemObjContent, vNodeContentB64) <> _ErrOK then
  begin
    return cErxSTD;  // Fehler bei DecodeB64CteNode
  end

  if Lib_FileIO:FileExists(aContentOutputFilename) then
  begin
    vMemObjContent->MemFree();
    return cErxSTD;  // Zieldatei existiert bereits
  end

  vFileHdl # FsiOpen(aContentOutputFilename,  _FsiAcsRW | _FsiDenyRW | _FsiCreate | _FsiTruncate);// | _FsiPure);
  if (vFileHdl > 0) then
  begin
    vFileHdl->FsiWriteMem(vMemObjContent, 1, vMemObjContent->spLen);
  end
  else
  begin
    vFileHdl->FsiClose();
    vMemObjContent->MemFree();
    return cErxSTD;  // Zieldatei konnte nicht geschrieben werden
  end

  vFileHdl->FsiClose();

  //DebugM('StatusCode: ' + aint(vStatusCode));
  //DebugM('ContentB64: ' + vContentB64);
  //DebugM('DEBUG_ContentPlain: ' + aCteJsonResponse->CteRead(_CteFirst | _CteSearch, 0, 'DEBUG_ContentPlain')->spValueAlpha);

  return vStatusCode;

end



/*
========================================================================
2022-05-04  DS                                               2407/1

RequestAPI kapselt den gesamten Workflow um eine (ggf. externe) API
über den ".../api/Utils/request" endpoint des AppHosts anzusprechen.

Input Args:

aCteRequest: Die Wurzel einer kanonischen Json Struktur die an AppHost
endpoint .../api/Utils/request gereicht wird, siehe docs in
DotNet5\Server\ApplicationHost\Controllers\Tech\UtilsController.cs:request()

WICHTIG für POST BODY: ein evtl im Knoten "postBody" übergebenes dict
        mit dem zu sendenden body als Json Cte Struktur wird vor dem Aufruf
        an UtilsController.cs:request() automatisch als B64 string kodiert,
        wie von der dortigen Schnittstelle vorausgesetzt. Der kodierte body
        wird automatisch als postBodyB64 weitergereicht.
        Alternativ kann er auch schon außerhalb, vom RequestAPI-Aufrufer, mittels
        vCteRequest->CteInsertNode('postBodyB64', _JsonNodeString, Lib_Json:JsonCteToB64(vCteYOUR_JSON_BODY));
        kodiert werden.

WICHTIG zur auth Information: ein evtl im Knoten "auth" übergebenes dict
        mit Anmeldeinformation wird vor dem Aufruf an UtilsController.cs:request()
        automatisch als B64 string kodiert, wie von der dortigen Schnittstelle
        vorausgesetzt.

aVerbose: Fehlermeldungen ausgeben oder nicht.

Output Args:

aResponseContent: Das Content Feld der erhaltenen Response. Kann beliebige
strings enthalten, das es b64-kodiert übertragen wird.
So lassen sich etwa json strings als Content übertragen, die der Aufrufer
danach mit Lib_Json:LoadJsonFromAlpha() dekodieren kann.

aStatusCode: der von der (ggf. externen) API erhaltene HTTP StatusCode.

Return:
interner Fehlercode, der dieselbe Information repräsentiert die bei
gesetztem aVerbose ausgegeben wird. Siehe dort für Bedeutungen dieser
internen Fehlercodes.


Details, insb. zum Aufbau von aCteRequest:
siehe docs in DotNet\Server\ApplicationHost\Controllers\Tech\UtilsController.cs:request()

Beispiele finden sich im Datenraum von BSC:
SFX_EcoDMS:uploadFile()
SFX_Laufzeiten:BerechneLaufzeit()
========================================================================
*/
sub RequestAPI
(
  // Pflicht-Argument:
  Verbosity                   : int;
  // Eigene Argumente:
  var outResponseContent      : alpha;    // Content der Antwort wird in diese String Variable geschrieben (es sei denn opt aContentOutputFilename wird übergeben)
  var outHttpStatusCode       : int;      // Http Status Code der Antwort
  aCteRequest                 : handle;   // zu sendender request
  opt aContentOutputFilename  : alpha(512);  // Wenn hier ein Dateiname übergeben wird, wird aResponseContent nicht zur Rückgabe des Contents als String genutzt,
                                            // sondern derselbe Content wird stattdessen in die von aContentOutputFilename bezeichnete Datei geschrieben.
                                            // Das ermöglicht es, Content mit mehr als 4096 Zeichen entgegenzunehmen.
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx     : int;
  Erm     : alpha(4096);
  // ab hier reguläre Variablen
  vUrl                  : alpha(512);
  vProtocol             : alpha(64);
  vHost                 : alpha(256);
  vPort                 : int;
  vRoute                : alpha(256);
  vSocket               : int;
  vCteRequestPostBody   : handle;
  vPostBodyB64          : alpha(8192);
  vCteRequestAuth       : handle;
  vAuthB64              : alpha(8192);
  vCteRequestFileValues : handle;
  vCteRequestFileValuesCur : handle;
  vCteResponse          : handle;
  vTimeout              : int;      // custom timeout der socket connection, der (wenn vorhanden) via aCteRequest an den AppHost weitergeleitet wird
                                    // (damit RestSharp für das Aufrufen der ggf. externen API denselben timeout verwendet),
                                    // und der ZUSÄTZLICH auch für die C16 Socket Connection genutzt wird (via SendPostRequest, s.u.)
  vCteRequestTimeout    : handle;
end
begin

  // --------------------------
  // Request an API
  // --------------------------

  // bestimme host und port des AppHost per AFX:
  if Lib_SFX:Check_AFX('AppHost.URL') and AFX.Prozedur <> '' then
  begin
    vUrl # Call(AFX.Prozedur);
  end
  else
  begin
    Erx # cErxSTD;
    Erm # __PROCFUNC__ + ': AppHost Konfiguration konnte nicht geladen werden, da es ein Problem mit der Ankerfunktion AppHost.URL gab.'
    complain(Verbosity, Erm);
    return Erx;
  end

  //DebugM('Ausgabe der AFX hinter AppHost.URL(): ' + vUrl);

  // Zerlege von AFX erhaltene URL in ihre Bestandteile:
  if !SplitUrl(vUrl, var vProtocol, var vHost, var vPort, var vRoute) then
  begin
    Erx # cErxSTD;
    Erm # __PROCFUNC__ + ': AppHost Konfiguration konnte nicht geladen werden, da das Ergebnis der Ankerfunktion AppHost.URL nicht erfolgreich in die Bestandteile der URL zerlegt werden konnte.';
    complain(Verbosity, Erm);
    return Erx;
  end
  /*
  DebugM('SplitUrl Protokoll: ' + vProtocol);
  DebugM('SplitUrl Server: ' + vHost);
  DebugM('SplitUrl Port: ' + aint(vPort));
  DebugM('SplitUrl Route: ' + vRoute);
  */

  // Automatische Umwandlung der postBody Information in B64 damit Umlaute etc. funktionieren
  vCteRequestPostBody # aCteRequest->CteRead(_CteFirst | _CteSearch, 0, 'postBody');
  if vCteRequestPostBody <> 0 then
  begin
      vPostBodyB64 # Lib_Json:JsonCteToB64(vCteRequestPostBody);

      // body-Knoten aus request löschen
      aCteRequest->CteDelete(vCteRequestPostBody);
      // gelöschten Knoten leeren
      vCteRequestPostBody->CteClear(true);

      // base64-kodierten vPostBodyB64 als elementaren _JsonNodeString hinzufügen:
      aCteRequest->CteInsertNode('postBodyB64', _JsonNodeString, vPostBodyB64);

  end

  // Automatische Umwandlung der auth Information in B64 damit Umlaute z.B. in Passwörtern funktionieren
  vCteRequestAuth # aCteRequest->CteRead(_CteFirst | _CteSearch, 0, 'auth');
  if vCteRequestAuth <> 0 then
  begin

    if vCteRequestAuth->CteInfo(_CteCount) <> 0 then
    begin
      // wenn auth nicht als elementarer base64 _JsonNodeString übergeben wurde, sondern als json dict,
      // wrappe das dict als elementaren base64 _JsonNodeString

      vAuthB64 # Lib_Json:JsonCteToB64(vCteRequestAuth);

      // dict-Knoten aus request löschen
      aCteRequest->CteDelete(vCteRequestAuth);
      // gelöschten Knoten leeren
      vCteRequestAuth->CteClear(true);

      // DebugM('CteInfo: ' + aint(vCteRequestAuth->CteInfo(_CteCount)));
      // DebugM('vAuthB64: ' + vAuthB64);

      // base64-kodierte auth Information als elementaren _JsonNodeString hinzufügen:
      aCteRequest->CteInsertNode('auth', _JsonNodeString, vAuthB64);

      // DebugM('CteInfo: ' + aint(vCteRequestAuth->CteInfo(_CteCount)));
    end

  end

  // Automatische Umwandlung der fileValues Information in B64 damit Umlaute in Dateinamen funktionieren
  vCteRequestFileValues # aCteRequest->CteRead(_CteFirst | _CteSearch, 0, 'fileValues');
  if vCteRequestFileValues <> 0 then
  begin
    vCteRequestFileValuesCur # vCteRequestFileValues->CteRead(_CteFirst | _CteChildList)
    while vCteRequestFileValuesCur <> 0 do
    begin

      //DebugM(vCteRequestFileValuesCur->spValueAlpha);
      vCteRequestFileValuesCur->spValueAlpha # StrCnv(StrCnv(vCteRequestFileValuesCur->spValueAlpha, _StrToUTF8), _StrToBase64);
      //DebugM(vCteRequestFileValuesCur->spValueAlpha);

      // nächste Datei
      vCteRequestFileValuesCur # vCteRequestFileValues->CteRead(_CteNext | _CteChildList, vCteRequestFileValuesCur);

    end
  end


  // Timeout entweder aus aCteRequest oder aus folgendem default nehmen:
  vTimeout # 5000;
  vCteRequestTimeout # aCteRequest->CteRead(_CteFirst | _CteSearch, 0, 'timeout');
  if vCteRequestTimeout <> 0 then
  begin
    // wenn in Cte vorhanden, default vTimeout damit überschreiben:
    vTimeout # vCteRequestTimeout->spValueInt;
  end
  else
  begin
    // wenn nicht in Cte vorhanden, default vTimeout in Cte schreiben, damit sowohl C16 als
    // auch AppHost denselben Timeout verwenden (wenn das nicht der Fall ist, kann es dazu
    // kommen, dass Anworten mit StatusCode 500 und leerem Content geliefert werden, was
    // schlecht zu debuggen ist, bzw. es schwierig macht, den Fehler zu verorten.
    aCteRequest->CteInsertNode('timeout', _JsonNodeNumber, vTimeout);
  end

  // Senden des Post Request an AppHost mit Host und Port der aus AFX erhalten wurde:
  vSocket # SendPostRequest(_AppHostConnectionType(), vHost, '/api/Utils/request', aCteRequest, vPort, 0, true, vTimeout);

  //DebugM('vSocket == ' + aint(vSocket));

  if (vSocket <= 0) then
  begin
    Erx # cErxSTD;
    Erm # __PROCFUNC__ + ': Problem bei Verbindung zum Server: Socket ' + aint(vSocket) + ' erhalten aus Lib_HTTP.Core:SendPostRequest().' + cCrlf2 +
      'Läuft der AppHost auf der Maschine ' + vHost + ' auf Port ' + aint(vPort) + '?';
    complain(Verbosity, Erm);
    return Erx;
  end

  // aCteRequest wegräumen ist nicht erforderlich, weil SendPostRequest seine Eingabeobjekte bereits selbst wegräumt

  // --------------------------
  // Response JSON lesen
  // --------------------------

  Erx # JsonFromSocket(Verbosity, var vCteResponse, var outHttpStatusCode, vSocket);
  if Erx <> _ErrOK then
  begin
    Erm # __PROCFUNC__ + ': Problem beim Einlesen der Response Json Struktur aufgetreten in Lib_HTTP.Core:JsonFromSocket()';
    complain(Verbosity, Erm);
    return Erx;
  end

  // eigentlicher Content wird extrahiert, und der StatusCode des AppHosts mit dem der gerufenen (ggf. externen) API überschrieben
  // (allerdings sollte der AppHost diesen ohnehin unverändert auch als eigenen StatusCode rausreichen)
  if aContentOutputFilename = '' then
  begin
    // ohne opt arg wird regulär in var string geschrieben
    outHttpStatusCode # UnwrapJsonResponseContentAsString(vCteResponse, var outResponseContent);
  end
  else
  begin
    // mit opt arg wird stattdessen in datei geschrieben
    outHttpStatusCode # UnwrapJsonResponseContentAsFile(vCteResponse, aContentOutputFilename);
  end

  // aufräumen
  Lib_Json:CloseJSON(var vCteResponse);

  // erfolgreich
  return _ErrOK;
end



/*
========================================================================
2022-05-09  DS                                               2407/1

Ermittelt zum übergebenen aApiName den entsprechenden host und port,
d.h. es liefert z.B. 'http://localhost:8000/' wenn die API mit dem
übergebenem apiName auf diesem host:port läuft.
Genauer: Es wird also der in appsettings.json des AppHost gesetzte
host:port am AppHost abgefragt und in das Output-Argument var aApiUrl
geschrieben.
Der zurückgegebene boolean gibt an, ob aApiUrl erfolgreich ermittelt
werden konnte.

Es wird sichergestellt dass der in aApiUrl geschriebene Wert mit '/' endet.
========================================================================
*/
sub ApiHostAndPort
(
  // Pflicht-Argument:
  Verbosity     : int;
  // Eigene Argumente:
  var outApiUrl : alpha;  // Ausgabe-Argument für URL
  aApiName      : alpha(256);
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx           : int;
  Erm           : alpha(4096);
  // ab hier reguläre Variablen
  // -------------------------------------------------
  // Variablen die mit dem INPUT der API zu tun haben
  // -------------------------------------------------
  vCteRequest                             : handle;       // Wurzel der Json Struktur für die Input-Daten des requests (bodyMeta)
  // -------------------------------------------------
  // Variablen die mit dem OUTPUT der API zu tun haben
  // -------------------------------------------------
  vContent                                : alpha(4096);  // Content String der response
  vStatusCode                             : int;
end
begin

  /*
  Vorlage des JSON Objekts:
  {
      "apiName": aApiName,
      "apiMethod": "get",
      "apiRoute": "ApiHostAndPort"
  }
  */

  // --------------------------
  // Input für API zusammenbauen
  // --------------------------

  vCteRequest # CteOpen(_CteNode);
  vCteRequest->spID # _JsonNodeObject;

  // Inhalte setzen
  vCteRequest->CteInsertNode('apiName', _JsonNodeString, aApiName);
  vCteRequest->CteInsertNode('apiMethod', _JsonNodeString, 'get');
  vCteRequest->CteInsertNode('apiRoute', _JsonNodeString, 'ApiHostAndPort');

  // DEBUG: json string serialisieren auf festplatte
  //vCteRequest->JsonSave('C:\debug\lib_http.core_ApiHostAndPort.json');


  // --------------------------
  // Request an API
  // --------------------------

  Erx # RequestAPI(Verbosity, var vContent, var vStatusCode, vCteRequest);
  if Erx <> _ErrOK then
  begin
    outApiUrl # '';
     // Fehler innerhalb von RequestAPI(), das sich um seine eigenen Fehlermeldungen kümmert, daher hier keine weitere
    return Erx;
  end

  if vStatusCode = 404 then
  begin
    outApiUrl # '';
    Erx # cErxSTD;

    Erm # __PROCFUNC__ + ': StatusCode ' + aint(vStatusCode) + ' erhalten. Unbekannter API Name.' + cCrlf2 +
      'Content:' + cCrlf +
      vContent;
    complain(Verbosity, Erm);
    return Erx;
  end

  if vStatusCode <> 200 then
  begin
    outApiUrl # '';
    Erx # cErxSTD;

    Erm # __PROCFUNC__ + ': StatusCode ungleich 200 erhalten. Mapping konnte nicht ermittelt werden.' + cCrlf2 +
      'Erhaltener StatusCode: ' + aint(vStatusCode) + cCrlf2 +
      'Erhaltener Content: ' + vContent;
    complain(Verbosity, Erm);
    return Erx;
  end


  // erfolgreich
  outApiUrl # vContent;

  // sicherstellen, dass URL in '/' endet:
  if StrCut(outApiUrl, StrLen(outApiUrl), 1) <> '/' then
  begin
    outApiUrl # outApiUrl + '/'
  end

  /*
  DebugM('vStatusCode: ' + aint(vStatusCode));
  DebugM('vContent: ' + vContent);
  DebugM('outApiUrl: ' + outApiUrl);
  */

  return _ErrOK;
end



/*
========================================================================
2022-05-09  DS                                               2407/1

Ermittelt das aktuell vom AppHost verwendete temp directory, indem dieser
danach gefragt wird. Das Ergebnis wird in das Output-Argument geschrieben.
========================================================================
*/
sub GetTempDirectory_on_AppHost
(
  // Pflicht-Argument:
  Verbosity   : int;
  // Eigene Argumente:
  var outDir : alpha;  // Ausgabe-Argument Verzeichnis Name
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx     : int;          // lokales Erx für Ausgaben anderer Funktionen und Datenoperationen, siehe Lib_Error:_complain
  Erm     : alpha(4096);  // Fehlernachricht (ErrorMessage Erm), siehe Lib_Error:_complain
  // ab hier reguläre Variablen
  // -------------------------------------------------
  // Variablen die mit dem INPUT der API zu tun haben
  // -------------------------------------------------
  vCteRequest                             : handle;       // Wurzel der Json Struktur für die Input-Daten des requests (bodyMeta)
  // -------------------------------------------------
  // Variablen die mit dem OUTPUT der API zu tun haben
  // -------------------------------------------------
  vContent                                : alpha(4096);  // Content String der response
  vStatusCode                             : int;
end
begin

  /*
  Vorlage des JSON Objekts:
  {
      "apiName": "any",
      "apiMethod": "get",
      "apiRoute": "GetTempDirectory"
  }
  */

  // --------------------------
  // Input für API zusammenbauen
  // --------------------------

  vCteRequest # CteOpen(_CteNode);
  vCteRequest->spID # _JsonNodeObject;

  // Inhalte setzen
  vCteRequest->CteInsertNode('apiName', _JsonNodeString, 'any');
  vCteRequest->CteInsertNode('apiMethod', _JsonNodeString, 'get');
  vCteRequest->CteInsertNode('apiRoute', _JsonNodeString, 'GetTempDirectory');

  // DEBUG: json string serialisieren auf festplatte
  //vCteRequest->JsonSave('C:\debug\lib_http.core_gettempdirectory.json');


  // --------------------------
  // Request an API
  // --------------------------
  Erx # RequestAPI(Verbosity, var vContent, var vStatusCode, vCteRequest);
  if Erx <> _ErrOK then
  begin
    outDir # '';
     // Fehler innerhalb von RequestAPI(), das sich um seine eigenen Fehlermeldungen kümmert, daher hier keine weitere
    return Erx;
  end

  if vStatusCode = 404 then
  begin
    outDir # '';
    Erx # cErxSTD;

    Erm # __PROCFUNC__ + ': StatusCode ' + aint(vStatusCode) + ' erhalten. Unbekannter API Name.' + cCrlf2 +
      'Content:' + cCrlf +
      vContent;
    complain(Verbosity, Erm);
    return Erx;
  end

  if vStatusCode <> 200 then
  begin
    outDir # '';
    Erx # cErxSTD;

    Erm # __PROCFUNC__ + ': StatusCode ungleich 200 erhalten. TempDirectory on AppHost konnte nicht ermittelt werden.' + cCrlf2 +
      'Erhaltener StatusCode: ' + aint(vStatusCode) + cCrlf2 +
      'Erhaltener Content: ' + vContent;
    complain(Verbosity, Erm);
    return Erx;
  end

  // erfolgreich
  outDir # vContent;

  /*
  DebugM('vStatusCode: ' + aint(vStatusCode));
  DebugM('vContent: ' + vContent);
  DebugM('outDir: ' + outDir);
  */

  return _ErrOK;
end



/*
========================================================================
2022-09-06  DS                                               2407/7

Löscht eine Datei im Temp Verzeichnis des AppHost, indem dieser
damit beauftragt wird.

Diese Funktion ist nützlich, um im Temp Verzeichnis des AppHost
aufzuräumen, siehe dazu die Verwendung in SFX_EcoDMS bei BSC.
========================================================================
*/
sub DeleteTempFile_on_AppHost
(
  // Pflicht-Argument:
  Verbosity   : int;
  // Eigene Argumente:
  aTempFilename : alpha(1000);  // zu löschende Datei im Temp Verzeichnis des AppHost 2023-04-25  AH auf 1000
  opt aIgnoreFileNotFound : logic;  // true -> zeige keinen Fehler, falls die Datei nicht existiert
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx     : int;          // lokales Erx für Ausgaben anderer Funktionen und Datenoperationen, siehe Lib_Error:_complain
  Erm     : alpha(4096);  // Fehlernachricht (ErrorMessage Erm), siehe Lib_Error:_complain
  // ab hier reguläre Variablen
  // -------------------------------------------------
  // Variablen die mit dem INPUT der API zu tun haben
  // -------------------------------------------------
  vCteRequest                             : handle;       // Wurzel der Json Struktur für die Input-Daten des requests (bodyMeta)
  // -------------------------------------------------
  // Variablen die mit dem OUTPUT der API zu tun haben
  // -------------------------------------------------
  vContent                                : alpha(4096);  // Content String der response
  vStatusCode                             : int;
end
begin

  /*
  Vorlage des JSON Objekts:
  {
      "apiName": "any",
      "apiMethod": "get",
      "apiRoute": "DeleteTempFile/FILE.NAME"
  }
  */

  // --------------------------
  // Input für API zusammenbauen
  // --------------------------

  vCteRequest # CteOpen(_CteNode);
  vCteRequest->spID # _JsonNodeObject;

  // Inhalte setzen
  vCteRequest->CteInsertNode('apiName', _JsonNodeString, 'any');
  vCteRequest->CteInsertNode('apiMethod', _JsonNodeString, 'get');
  // damit Dateinamen mit Umlauten übergeben werden können, wird zunächst UTF8- dann base64-kodiert. AppHost dekodiert entsprechend
  vCteRequest->CteInsertNode('apiRoute', _JsonNodeString, 'DeleteTempFile' + '/' + StrCnv(StrCnv(aTempFilename, _StrToUTF8), _StrToBase64));

  // DEBUG: json string serialisieren auf festplatte
  //vCteRequest->JsonSave('C:\debug\lib_http.core_deletetempfile.json');


  // --------------------------
  // Request an API
  // --------------------------
  Erx # RequestAPI(Verbosity, var vContent, var vStatusCode, vCteRequest);
  if Erx <> _ErrOK then
  begin
    // Fehler innerhalb von RequestAPI(), das sich um seine eigenen Fehlermeldungen kümmert, daher hier keine weitere
    return Erx;
  end

  if vStatusCode <> 200 then
  begin

    if vStatusCode = 404 and aIgnoreFileNotFound then
    begin
      return _ErrOK;
    end

    Erx # cErxSTD;
    Erm # __PROCFUNC__ + ': StatusCode ungleich 200 erhalten. Fehler.' + cCrlf2 +
      'Erhaltener StatusCode: ' + aint(vStatusCode) + cCrlf2 +
      'Erhaltener Content: ' + vContent;
    complain(Verbosity, Erm);
    return Erx;
  end


  // erfolgreich

  /*
  DebugM('vStatusCode: ' + aint(vStatusCode));
  DebugM('vContent: ' + vContent);
  */

  return _ErrOK;
end


/*
========================================================================
2022-06-08  DS                                               2407/4

Zerlegt übergebene aUrl (wie z.B. per ApiHostAndPort() ermittelt)
in die Bestandteile Protokoll, Server, Port, Route.

Der zurückgegebene boolean gibt an, ob aUrl erfolgreich zerlegt
werden konnte.

Die Ergebnisse enthalten an keiner Stelle ':' oder '/', mit Ausnahme von
aRoute, welche bei syntaktisch korrekt eingegebener aUrl zwar
NICHT mit '/' beginnt und endet, aber je nach Anzahl der Glieder der Route
potentiell innen '/' enthalten kann die als Separatoren dienen.
========================================================================
*/
sub SplitUrl
(
  aUrl           : alpha(512);  // Input: Servername oder IP mit Protokoll und ggf. Port, wie z.B. per ApiHostAndPort ermittelt. Es dürfen Routen nach dem Port folgen.
  var aProtokoll : alpha;       // Output: entweder http oder https
  var aServer    : alpha;       // Output: z.B. IP, localhost oder DNS-Name
  var aPort      : int;         // Output: port Nummer oder 0 falls kein Port angegeben
  var aRoute     : alpha;       // Output: Route die nach dem Port kommt, beginnend und endend OHNE '/'. Oder '' falls keine Route vorhanden.
) : logic  // erfolgreich? Ergebnis darf nur verwendet werden, wenn Rückgabewert true ist, sonst ist Ergebnis leer
local begin
  vRemainder     : alpha(512);
  vPortNumDigits : int;
  vPortString    : alpha(5);
end
begin

  // Protokoll muss...
  // * angegeben sein
  // * entweder http oder https
  // * per // abgetrennt von Servername
  if StrCnv(StrCut(aUrl, 1, 7), _StrLower) <> 'http://' and StrCnv(StrCut(aUrl, 1, 8), _StrLower) <> 'https://' then
  begin
    aProtokoll # '';
    aServer # '';
    aPort # 0;
    aRoute # '';
    return false;
  end

  aProtokoll # Lib_Strings:Strings_Token(aUrl, '://', 1);

  vRemainder # Lib_Strings:Strings_Token(aUrl, '://', 2);

  if Lib_Strings:Strings_Count(vRemainder, ':') = 0 then
  begin
    // kein Port vorhanden

    aServer # Lib_Strings:Strings_Token(vRemainder, '/', 1);
    aPort # 0;

    // Route beginnt in vRemainder nach Server und '/', also +2
    aRoute # StrCut(vRemainder, StrLen(aServer)+2, StrLen(vRemainder));

  end
  else if Lib_Strings:Strings_Count(vRemainder, ':') = 1 then
  begin
    // Port vorhanden

    aServer # Lib_Strings:Strings_Token(vRemainder, ':', 1);

    // Server absplitten, vRemainder beginnt dann mit Port und kann z.B. so aussehen: '8180/api/document/71'
    vRemainder # Lib_Strings:Strings_Token(vRemainder, ':', 2)

    // Port absplitten über ersten '/'
    vPortString # Lib_Strings:Strings_Token(vRemainder , '/', 1);
    aPort # CnvIA(vPortString);

    // Route muss wg. potentiell mehrerer '/' stattdessen über die Anzahl der Stellen des Ports abgesplittet werden
    vPortNumDigits # StrLen(vPortString);
    aRoute # StrCut(vRemainder, vPortNumDigits+1, StrLen(vRemainder));
  end
  else
  begin
    // mehr als ein ':', also syntaktisch nicht korrekt
    aProtokoll # '';
    aServer # '';
    aPort # 0;
    aRoute # '';
    return false;
  end

  // leading '/' entfernen
  WHILE StrCut(aRoute, 1, 1) = '/' DO
  BEGIN
      aRoute # StrCut(aRoute, 2, StrLen(aRoute));
  END;

  // trailing '/' entfernen
  WHILE StrCut(aRoute, StrLen(aRoute), 1) = '/' DO
  BEGIN
      aRoute # StrCut(aRoute, 1, StrLen(aRoute)-1);
  END;


  return true;

end



/*
========================================================================
2022-10-12 DS

Aufräumfunktion inkl. Fehlermeldungs-Generator für __commitBusinessLogicTransaction
========================================================================
*/
sub __cleanup___commitBusinessLogicTransact(
  aVerbose : logic;                 // Fehlermeldungen ausgeben?
  opt aCustMsg     : alpha(4096);   // Freitext (wenn nichtleer, wird AutoMsg deaktiviert)
  opt aAutoMsgOp   : alpha(1);      // Automatische Fehlermeldung: Typ der Operation bei der der Fehler auftrat
  opt aAutoMsgFunc : alpha(64);     // Automatische Fehlermeldung: Gerufene Funktion bei der Fehler auftrat
  opt aAutoMsgErx  : int;           // Automatische Fehlermeldung: Erx Code des Fehlers
)
local begin
  vMsg             : alpha(4096);
end
begin

  // Als allererstess, vor jeder GUI Interaktion: TRANSBRK:
  if aAutoMsgErx <> _ErrDeadLock then
  begin
    // TRANSBRK nur wenn kein Deadlock. Grund: Alex kennt die Details dazu.
    // Könnte sich ändern, wenn C16 erlaubt den Abbruch aller Transaktionen bei Deadlock NICHT MEHR zu machen, z.B. indem dieses "feature" per Config deaktiviert werden kann.
    TRANSBRK;
  end

  vMsg # 'Fehler in __commitBusinessLogicTransaction(): ' + cCrlf2;

  if aCustMsg <> '' then
  begin
    vMsg # vMsg + 'Fehlerbeschreibung (Freitext):' + cCrlf + aCustMsg;
  end
  else
  begin
    vMsg # vMsg + 'Fehlerbeschreibung (automatisch generiert):' + cCrlf +
    'Operations-Typ: ' + aAutoMsgOp + cCrlf +
    'Fehler aus Funkction: ' + aAutoMsgFunc + cCrlf +
    'Fehlercode: ' + aint(aAutoMsgErx);
    if aAutoMsgErx = _ErrDeadLock then vMsg # vMsg + ' (DEADLOCK)';
  end

  if aVerbose then
  begin
    MsgErr(99, vMsg);
  end

end

/*
========================================================================
2022-10-11 AH / DS

Nimmt eine Cte Struktur entgegen, die eine C16 Transaktion beschreibt,
siehe Ausgabe von __requestBusinessLogicToTransaction().
Die Transaktion wir verarbeitet und in die C16 Datenbank committed.

Alex' früherer Name für diese Funktion war:
ProcessDbOpsCte
========================================================================
*/
sub __commitBusinessLogicTransaction(
  aVerbose        : logic;
  aTransactionCte : handle;
) : int
local begin
  Erx          : int;
  vOpCte       : handle;      // Operation (eine Transaktion, siehe Input aTransactionCte, besteht aus n Transaktionen): key ist der OpCode vCode, value ist B64-encoded json mit dem Record der Operation
  vRecCte      : handle;      // Record: Ergebnis der Dekodierung des o.g. B64-encoded json. Enthält genau einen Datensatz, d.h. den Datensatz auf den sich die Operation bezieht.
  vFldCte      : handle;      // Field: das aktuell betrachtete Feld im Datensatz vRecCte
  vOp          : alpha;       // 'I'(nsert), 'U'(pdate), 'D'(elete)
  vOpsCount    : int;         // gibt die Anzahl der bisher in der Transaktion gelesenen Operationen an, bzw. gibt am Ende die Gesamtzahl der Operationen an aus denen die Transaktion besteht
  vCode        : alpha;       // key string der aktuellen Operation vOpCte
  vDatei       : int;         // Nummer der Tabelle in der die jeweils aktuelle Operation durchgeführt wird
  vRecId       : int;         // eindeutige C16 RecID die Bestandteil von vCode ist
  vTsC16       : bigint;      // timestamp aus C16
  vTsSQL       : bigint;      // timestamp aus SQL
  vTsFound     : logic;       // ist false wenn in Eingabedaten kein timestamp gefunden wurde. Dann wird die Transaktion abgebrochen, weil so keine Prüfung auf Racecondition stattfinden kann.
  vJsonMemObj  : handle;      // MemObj aus dem das json geladen wird das zu vRecCte führt
  vFldName     : alpha(128);  // C16-Name des Feldes
  vFldTypeC16  : int;         // Typ des C16-Feldes hinter vFldName
  vFldTypeJson : int;         // Typ des Json-Wertes im aktuellen Feld vFldCte
  //vCT         : caltime;  // nur in DEBUG code relevant
end
begin

  // da __cleanup___commitBusinessLogicTransact die aktuelle Transaktion beendet, sollte als allererstes,
  // und damit insb. vor jedem Aufruf an __cleanup___commitBusinessLogicTransact, die Transaktion gestartet werden:
  TRANSON;

  // Iterieren über die Ops der Transaktion
  FOR vOpCte # aTransactionCte->CteRead( _cteChildList | _cteFirst, 0)
  LOOP vOpCte # aTransactionCte->CteRead( _cteChildList | _CteNext, vOpCte)

  WHILE vOpCte<>0 DO
  BEGIN

    inc(vOpsCount);

    // Status ob TimeStamp gefunden resetten, denn jede Operation braucht einen eigenen TimeStamp
    vTsFound # false;

    vCode   # vOpCte->spName;

    // einfache Prüfung des Formats
    if StrLen(vCode) <> 37 then
    begin
      __cleanup___commitBusinessLogicTransact(aVerbose, 'Operation "' + vCode + '" (' + aint(vOpsCount) + 'te Operation der Transaktion) ist nicht exakt 37 Zeichen lang (sondern ' + aint(StrLen(vCode)) + '). Illegales Format!');
      return cErxSTD;
    end;

    vDatei  # cnvia(StrCut(vCode, 26,4));
    vRecId  # cnvia(StrCut(vCode, 26+4,8), _fmtNumHex);
    vOp     # StrCut(vCode,1,1);

    //debugm(aint(vDatei)+' RecId:'+aint(vRecID));

    if (vOp='I') then
    begin
      RecBufClear(vDatei);
    end

    else if (vOp='D') then
    begin

      Erx # RecRead(vDatei, 0, _recId|_RecLock, vRecID);
      if Erx <> _ErrOK then
      begin
        __cleanup___commitBusinessLogicTransact(aVerbose, '', vOp, 'RecRead', Erx);
        RETURN Erx;
      end

      Erx # RecDelete(vDatei, 0);
      if (Erx<>_rOK) then
      begin
        __cleanup___commitBusinessLogicTransact(aVerbose, '', vOp, 'RecDelete', Erx);
        RETURN Erx;
      end;

      CYCLE;  // DELETE endet bereits hier, restlicher Code wird nicht durchlaufen
    end

    else if (vOp='U') then
    begin
      Erx # RecRead(vDatei, 0, _recId|_RecLock, vRecID);

      if (Erx<>_rOK) then
      begin
        __cleanup___commitBusinessLogicTransact(aVerbose, '', vOp, 'RecRead', Erx);
        RETURN Erx;
      end
    end

    else
    begin
      __cleanup___commitBusinessLogicTransact(aVerbose, 'Operation "' + vCode + '" (' + aint(vOpsCount) + 'te Operation der Transaktion) hat ungültigen Operations-Code "' + vOp + '"');
      return cErxSTD;
    end

    /*
    -----------------------------------------------------------------
    Für Operationen Insert und Update, lade nun die Felder des
    Datensatzes der aktuellen Operation in den Feldpuffer der
    entsprechenden Tabelle.
    (Bei Operation Delete wird dieser Code wg. CYCLE nicht erreicht)
    -----------------------------------------------------------------
    */

    vTsC16 # RecInfo(vDatei, _RecModified);

    if DecodeB64CteNode(var vJsonMemObj, vOpCte) <> _ErrOK then
    begin
      if vJsonMemObj > 0 then MemFree(vJsonMemObj);
      vJsonMemObj # 0;
      __cleanup___commitBusinessLogicTransact(aVerbose, 'Operation "' + vCode + '" (' + aint(vOpsCount) + 'te Operation der Transaktion) wies ein Problem auf während der Ausführung von DecodeB64CteNode');
      return cErxSTD;
    end

    // der zu verarbeitende Datensatz:
    vRecCte # Lib_Json:LoadJSON('', true, vJsonMemObj);

    //Lib_Json:SaveJSON(vRecCte, 'c:\debug\vRecCte.json', _CharsetUTF8);


    // Iteriere über die Felder des Datensatzes der aktuellen Op
    FOR vFldCte # vRecCte->CteRead( _cteChildList | _cteFirst, 0)
    LOOP vFldCte # vRecCte->CteRead( _cteChildList | _CteNext, vFldCte)
    WHILE vFldCte<>0 DO
    BEGIN

      vFldName # vFldCte->spname;
      vFldTypeJson # vFldCte->sptype;

      case (StrCnv(vFldName,_StrUpper)) of

        'RECID',
        'ANLAGE_DATUM',
        'ANLAGE_USERNAME',
        'CUSTOMFELDER',
        'EXTENDEDFELDER' :
        begin
          // diese Felder werden nicht in C16 committed
          CYCLE;
        end

        'TIMESTAMP' :
        begin
          if (vFldTypeJson=_Typeint) then
            vTsSQL # vFldCte->spValueInt
          else if (vFldTypeJson=_TypeBigint) then
            vTsSQL # vFldCte->spValueBigInt;
          /* Auskommentiert nach Fix des Bugs im AppHost
          else if (vFldTypeJson=_TypeFloat) then
            // WICHTIG: Während eines Bugs im AppHost parste C16 sehr große, also 64 bit lange, Ints als float,
            //          Daher dieser absurd aussehende Sonderfall.
            //          Vorsicht vor Rundungsfehlern!
            vTsSQL # CnvBF(vFldCte->spValueFloat);
          */
          else
            vTsSQL # -11111;  // Wert aus alter Iteration so überschreiben, dass es in Fehlermeldung auffällt


//debugx(vOp+' : Sql:'+cnvab(vTsSql)+' <> c16: '+cnvab(vTsc16));

          if vTsSQL <> vTsC16 then
          begin
            __cleanup___commitBusinessLogicTransact(
              aVerbose,
              'Operation "' + vCode + '" (' + aint(vOpsCount) + 'te Operation der Transaktion) hat Timestamp Fehler: Timestamp der SQL (' + CnvAB(vTsSQL) + ') passt nicht zu dem von C16 (' + CnvAB(vTsC16) + ')' + cCrlf2 +
              'Mögliche Abhilfe:' + cCrlf +
              'In der SC Kommandozeile' + cCrlf2 +
              'SQL_SYNCONE ' + aint(vDatei) + cCrlf2 +
              'ausführen.'
            );
            return cErxSTD -111;  // NICHT ändern, wg. Sonderbehandlung in executeBusinessLogicTransaction
          end
          else
          begin
            // Vergleich wurde erfolgreich durchgeführt.
            // Protokollieren dass timestamp gefunden wurde, denn ein timestamp ist mandatory damit die vorige Prüfung
            // stattfinden kann. Wenn in dieser Operation kein Feld 'TIMESTAMP' gefunden wird, ist vTsFound am Ende
            // der Iteration über alle Felder immernoch false, was bedeutet dass es keine Prüfung gab. Dann muss die
            // Transaktion abgebrochen werden, weil ohne Prüfung eine race condition nicht ausgeschlossen werden kann.
            vTsFound # true;
          end

          // timestamp wird nur zum Vergleich herangezogen, nicht in C16 committed (dort steht er ja bereits in Form von vTsC16)
          CYCLE;

        end;

        otherwise
          // normale Feldnamen (as opposed to spezielle Feldnamen weiter oben)
        begin

          //DebugM(vFldName);

          // Existiert Feld dieses Namens in C16?
          if (FldInfoByName(vFldName, _FldExists)=0) then
          begin
            __cleanup___commitBusinessLogicTransact(
              aVerbose,
              'Operation "' + vCode + '" (' + aint(vOpsCount) + 'te Operation der Transaktion) beinhaltet unbekannten Feldnamen "' + vFldName + '"'
            );
            return cErxSTD;
          end;
//debugx(vFldName+' '+aint(vFldTypeJson));

          // Behandlung je nach Feld-Typ in C16 Zieltabelle
          vFldTypeC16 # FldInfoByName(vFldName, _FldType);

          case vFldTypeC16 of

            _TypeAlpha :
            begin
              if (vFldTypeJson=0) then
                FldDefByName(vFldName, '')
              else
                FldDefByName(vFldName, vFldCte->spValuealpha);
            end;

            _TypeBigInt :
            begin
              if (vFldTypeJson=0) then
                FldDefByName(vFldName, 0)
              else if (vFldTypeJson=_typeBigInt) then
                FldDefByName(vFldName, vFldCte->spValueBigInt)
              else if (vFldTypeJson=_typeInt) then
                FldDefByName(vFldName, vFldCte->spValueInt);
            end;

            _TypeDate:
            begin
              if (vFldTypeJson=0) then
                FldDefByName(vFldName, 0.0.0)
              else
              begin
                //FldDefByName(vFldName, cnvda(vFldCte->spValuealpha));
                FldDefByName(vFldName, cnvda(Str_Token(vFldCte->spvaluealpha, 'T', 1), _FmtDateYMD));
              end;
            end;

            _typeDecimal:
            begin
              if (vFldTypeJson=0) then
                FldDefByName(vFldName, 0\m)
              else
                FldDefByName(vFldName, vFldCte->spValuedecimal);
            end


            _TypeFloat:
            begin

              if (vFldTypeJson=0) then
                FldDefByName(vFldName, 0.0)
              else

                if vFldTypeJson = _TypeInt or vFldTypeJson = _TypeBigInt then
                begin
                  //DebugM('Wert für float-Feld "' + vFldName + '" ist int-valued: ' + aint(vFldCte->spValueInt));
                  FldDefByName(vFldName, CnvFI(vFldCte->spValueInt));
                end
                else if vFldTypeJson = _TypeFloat or vFldTypeJson = _TypeDecimal then
                begin
                  //DebugM('Wert für float-Feld "' + vFldName + '" ist real-valued: ' + CnvAF(vFldCte->spValueFloat));
                  FldDefByName(vFldName, vFldCte->spValueFloat);
                end
                else
                begin
                  //DebugM('Wert für float-Feld "' + vFldName + '" ist UNEXPECTEDLY-valued und kann daher nicht angezeigt werden.');
                  __cleanup___commitBusinessLogicTransact(
                    aVerbose,
                    'Operation "' + vCode + '" (' + aint(vOpsCount) + 'te Operation der Transaktion) hat eine Stelle im Code erreicht, die nicht erreicht werden dürfte:' + cCrlf +
                    'Der im Json erhaltene Wert für ein float Feld in C16 weist keinen der erwarteten Datentypen auf.'
                  );
                  return cErxSTD;
                end

            end;


            _TypeInt:
            begin
              if (vFldTypeJson=0) then
                FldDefByName(vFldName, 0)
              else
                FldDefByName(vFldName, vFldCte->spValueint);
            end;

            _TypeLogic:
            begin
              //DebugM(vFldName + ': ' + Lib_Auxiliaries:CnvAL(vFldCte->spValuelogic));
              if (vFldTypeJson=0) then
                FldDefByName(vFldName, false);
              else
                FldDefByName(vFldName, vFldCte->spValuelogic);
            end;

            _TypeTime:
            begin
              if (vFldTypeJson=0) then
                FldDefByName(vFldName, 0:0)
              else
              begin
//vCT # cnvca(vFldCte->spvaluealpha, _FmtCaltimeIso |  _FmtCaltimeDateBlank | _FmtCaltimeTimeHMS);
//              if (vFldCte->spvaluealpha>'1900-02') then
                FldDefByName(vFldName, cnvta(Str_Token(vFldCte->spvaluealpha, 'T', 2)));
//              else
//                FldDefByName(vFldName, 0:0);
              end;
            end;

            _TypeWord:
            begin
              if (vFldTypeJson=0) then
                FldDefByName(vFldName, 0)
              else
                FldDefByName(vFldName, vFldCte->spValueint);
            end;

          end;  // case-Block über vFldTypeC16

        end;  // otherwise-Block des case-Blocks über vFldName. Dieser behandelt normale Feldnamen (as opposed to spezielle Feldnamen weiter oben)
      end;  // case-Block über vFldName

    END;  // Loop über Felder der aktuellen Op


    if !vTsFound then
    begin
      __cleanup___commitBusinessLogicTransact(
        aVerbose,
        'Operation "' + vCode + '" (' + aint(vOpsCount) + 'te Operation der Transaktion) hat einen Datensatz ohne Timestamp geliefert.' + cCrlf +
        'Ein Timestamp ist zwingend erforderlich um auf race conditions zu prüfen. Daher muss die Transaktion abgebrochen werden.' + cCrlf2 +
        'Bitte AppHost- bzw. SQL-seitig prüfen, warum kein Timestamp geliefert wurde.'
      );
      return cErxSTD;
    end




    /*
    -----------------------------------------------------------------
    Nun ist der Datensatz mit allen Feldern in den Feldpuffer geladen
    Es kann nun, abhängig von vOp ein Insert oder Update stattfinden
    -----------------------------------------------------------------
    */

    if (vOp='I') then
    begin
      Erx # RekInsert(vDatei, 0, 'AUTO');
      if (Erx<>_rOK) then
      begin
        __cleanup___commitBusinessLogicTransact(aVerbose, '', vOp, 'RekInsert', Erx);
        RETURN Erx;
      end;
    end
    else if (vOp='U') then
    begin
      Erx # RekReplace(vDatei, 0, 'AUTO');
      if (Erx<>_rOK) then
      begin
        __cleanup___commitBusinessLogicTransact(aVerbose, '', vOp, 'RekReplace', Erx);
        RETURN Erx;
      end;
    end;
    else
    begin
      __cleanup___commitBusinessLogicTransact(
        aVerbose,
        'Operation "' + vCode + '" (' + aint(vOpsCount) + 'te Operation der Transaktion) hat eine Stelle im Code erreicht, die nicht erreicht werden dürfte, denn' + cCrlf +
        '1. für vOp="D" hätte bereits oben CYCLE gerufen werden sollen und' + cCrlf +
        '2. auf illegale Werte in vOp hätte schon weiter oben geprüft werden sollen.' + cCrlf2 +
        'Bitte Programmlogik mit Blick auf o.g. Sollzustand auf Fehler prüfen!'
      );
      return cErxSTD;
    end
  END;  // Loop über Ops der C16 Transaktion

  TRANSOFF;

  RETURN _ErrOK;
end;



/*========================================================================
2022-07-15  AH
    call Lib_http.core:TestAlex
========================================================================*/
sub TestAlex() : alpha;
local begin
  Erx             : int;
  vSock           : int;
  vA              : alpha(4000);
  vService        : alpha(1000);
  vCTE            : handle;
  vRes            : int;
  vMem, vMem2     : handle;
  vTmp            : int;
  vLen            : int;

    tCteNodeJSON       : handle;
    tCteNodeJSONItem   : handle;
    tErr               : int;
    vCT : caltime;
end
begin
//Lib_Debug:startBluemode();

  gNetServerUrl # 'localhost';
  gNetServerPort # 5700;

  vA # '1234/456';
  vService  # '/api/Betriebsauftrag/KostenUmlage/'+vA;
  vSock # SendGetRequest(_AppHostConnectionType(), gNetServerUrl, vService, gNetServerPort, 1000);
//debugx(gNetServerUrl+' '+vService);
//  vA  # GetResponseString(vSock);
//  debugx(vA);

  vMem # GetResponseLight(vSock, var vRes, _CharsetUTF8);
  if (vRes=200) then begin
    vLen # vMem->spLen;
    if (vLen>2) then begin
      // Erstes und letztes Anführungszeichen killen
      Memcopy(vMem, 2, vLen - 2, 1, vMem);
      MemResize(vMem, vLen-2);

      vMem2 # MemAllocate(_MemAutoSize);
      if (vMem->MemCnv(vMem2, _MemDecBase64) <> _ErrOK) then begin
 debugx('AU!!!');
        vMem->MemFree();
        vMem2->MemFree();
        RETURN 'AUA'; // b64 konnte nicht dekodiert werden werden
      end

      // clean up
      vMem->MemFree();
//vTMP # FSIOpen('d:\debug\mem2.txt',_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
//FsiWriteMem(vTMP, vMem2, 1,  vMem2->spLen);
//FsiCLose(vTMP);

      vCte # CteOpen(_CteNode);
      vRes # Jsonload(vCTE, '', 0, vMem2);
//debug('Jsonload:'+aint(vRes));
      vMem2->MemFree();

      if (vRes=0) then begin
        // PROCESS CTE
        Erx # __commitBusinessLogicTransaction(true, vCTE);
        if Erx <> _ErrOK then begin
          debugm(__PROCFUNC__ + ': Erx=' + aint(Erx) + ' erhalten von __commitBusinessLogicTransaction()');
        end
        else begin

        end;
      end;

//debugx('ENDE!');
      CteClear(vCte, true);
      CteClose(vCte);
    end
    else begin
      vMem->MemFree();
    end;
  end;

  RETURN vA;
end;



/*
========================================================================
2022-10-10  DS

Stellt Anfrage zur Durchführung der BusinessLogic gemäß aURI an AppHost
und liefert in outTransactionCte das handle auf die vom AppHost erhaltene
Cte Struktur mit der zu verarbeitenden C16 Transaktion.
Siehe zur Weiterverarbeitung auch __commitBusinessLogicTransaction()

Forked von TestAlex()
========================================================================
*/
sub __requestBusinessLogicToTransaction(
  aVerbose              : logic;
  var outTransactionCte : handle;
  aURI                  : alpha(512);
) : int;
local begin
  vUrl                  : alpha(512);
  vProtocol             : alpha(64);
  vHost                 : alpha(256);
  vPort                 : int;
  vRoute                : alpha(256);
  vSocket               : int;
  vStatusCode           : int;
  vMemObjContent        : handle;
  vErr                  : alpha(4096);
end
begin

  // Lib_Debug:startBluemode();

  // bestimme host und port des AppHost per AFX:
  if Lib_SFX:Check_AFX('AppHost.URL') and AFX.Prozedur <> '' then
  begin
    vUrl # Call(AFX.Prozedur);
  end
  else
  begin
    if aVerbose then
    begin
      MsgErr(99, __PROCFUNC__ + ': AppHost Konfiguration konnte nicht geladen werden, da es ein Problem mit der Ankerfunktion AppHost.URL gab.');
    end
    return cErxSTD;
  end

  //DebugM('Ausgabe der AFX hinter AppHost.URL(): ' + vUrl);

  // Zerlege von AFX erhaltene URL in ihre Bestandteile:
  if !SplitUrl(vUrl, var vProtocol, var vHost, var vPort, var vRoute) then
  begin
    if aVerbose then
    begin
      MsgErr(99, __PROCFUNC__ + ': AppHost Konfiguration konnte nicht geladen werden, da das Ergebnis der Ankerfunktion AppHost.URL nicht erfolgreich in die Bestandteile der URL zerlegt werden konnte.');
    end
    return cErxSTD;
  end
  /*
  DebugM('SplitUrl Protokoll: ' + vProtocol);
  DebugM('SplitUrl Server: ' + vHost);
  DebugM('SplitUrl Port: ' + aint(vPort));
  DebugM('SplitUrl Route: ' + vRoute);
  */


  // ### DEBUG HACKS
  /*
  vHost # 'localhost';
  vPort # 5700;
  */


  vSocket # SendGetRequest(_AppHostConnectionType(), vHost, aURI, vPort, 1000);

  if (vSocket <= 0) then begin
    if aVerbose then
    begin
      MsgErr(99, __PROCFUNC__ + ': Problem bei Verbindung zum Server (Erstellung des Sockets durch Lib_HTTP.Core:SendGetRequest)' + cCrlf2 + 'Läuft der Server auf der Maschine ' + vHost + ' auf Port ' + aint(vPort) + '?');
    end
    return -1;
  end

  // in Anlehnung an JsonFromSocket()
  vMemObjContent # GetResponseLight(vSocket, var vStatusCode, _CharsetUTF8);

  if vStatusCode <> 200 then
  begin

    if aVerbose then
    begin
      MsgErr(99, __PROCFUNC__ + ': Statuscode ' + aint(vStatusCode) + ' erhalten vom Server aus Lib_HTTP.Core:GetResponseLight. Erwartet war Statuscode 200.');
    end

    vMemObjContent->MemFree();
    return -2;
  end


  outTransactionCte # Lib_Json:LoadJSON('', true, vMemObjContent);

  // DEBUG:
  //FsiDelete('c:\debug\c16mapper.json');
  //Lib_Json:SaveJSON(outTransactionCte, 'c:\debug\c16mapper.json');


  // finales Aufräumen
  vMemObjContent->MemFree();
  // nicht schließen, weil Rückgabewert: Lib_Json:CloseJSON(var outTransactionCte);

  return _ErrOK;

end;



/*
========================================================================
2022-10-14  DS

Bündelt __requestBusinessLogicToTransaction und __commitBusinessLogicTransaction
zu einer Gesamtaktion und erlaubt automatischen Retry im Falle von
TimeStamp Differenzen.
========================================================================
*/
sub executeBusinessLogicTransaction(
  aVerbose              : logic;
  aURI                  : alpha(512);
) : int;
local begin
  Erx                   : int;
  vTransactionCte       : handle;
  vRetryCur             : int;  // Anzahl aktuell durchgeführter RE(!)tries
  vRetryMax             : int;  // Anzahl ERNEUTER Versuche nach Scheitern
  vRetryIntervalMs      : int;  // Millisekunden zu warten zwischen erneuten Versuchen
end
begin

  vRetryMax # 0;
  vRetryIntervalMs # 2500;

  FOR   vRetryCur # 0;   // erster Versuch ist kein RE(!)try, daher 0
  LOOP  Inc(vRetryCur);
  WHILE vRetryCur <= vRetryMax DO
  BEGIN

    // im letzten RE(!)try werden die Fehler ausgegeben, no matter what:
    if vRetryCur > 0 and vRetryCur = vRetryMax then
    begin
      aVerbose # true;
    end

    //DebugM('vRetryCur: ' + aint(vRetryCur) + ', verbose: ' + Lib_Auxiliaries:CnvAL(aVerbose));

    Erx # __requestBusinessLogicToTransaction(
      aVerbose,
      var vTransactionCte,
      aURI
    );
    //DebugM(__PROCFUNC__ + ': Ausgabe von __requestBusinessLogicToTransaction(): Erx=' + aint(Erx));
    if Erx <> _ErrOK then
    begin
      if aVerbose then
      begin
        MsgErr(99, __PROCFUNC__ + ': Fehlercode ' + aint(Erx) + ' erhalten aus __requestBusinessLogicToTransaction.');
      end
      Lib_Json:CloseJSON(var vTransactionCte);
      return Erx;
    end


    Erx # __commitBusinessLogicTransaction(aVerbose, vTransactionCte);
    //DebugM(__PROCFUNC__ + ': Ausgabe von __commitBusinessLogicTransaction(): Erx=' + aint(Erx));
    if Erx <> _ErrOK then
    begin
      if aVerbose then
      begin
        MsgErr(99, __PROCFUNC__ + ': Fehlercode ' + aint(Erx) + ' erhalten aus __commitBusinessLogicTransaction');
      end
      Lib_Json:CloseJSON(var vTransactionCte);
      // return Erx;  // kein return, denn für diese Funktion darf erneut probiert werden (RETRY)
    end

    // für Fehler die nicht auf TimeStamp zurückzuführen sind, NICHT erneut probieren
    if Erx <> cErxSTD -111 then
    begin
      //DebugM('Keine Retries, da Erx ' + aint(Erx) + ' nicht TimeStamp-related.');
      vRetryMax # 0;
    end
    else
    begin
      Winsleep(vRetryIntervalMs);
      //DebugM('Probiere Retry, da Erx ' + aint(Erx) + ' TimeStamp-related.');
    end

    Lib_Json:CloseJSON(var vTransactionCte);

  END;

  Lib_Json:CloseJSON(var vTransactionCte);
  return Erx;

end



/*========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================*/
MAIN()
local begin
  Erx           : int;
  vDescription  : alpha(512);
  vAlpha        : alpha(4096);
  vBeta         : alpha(4096);
  vGamma        : alpha(4096);
  vInt          : int;
  vLogic        : logic;
  vCte          : handle;
end;
begin

  // Initialisiere benötigte Bereiche die sonst durch SC initialisiert würden:
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  gNetServerUrl # 'localhost';
  gNetServerPort # 5700;

  // init ist erforderlich für standalone Ausführung, damit RequestAPI die darin verwendete AFX findet
  Lib_SFX:InitAFX();


  /*
  Erx # JwtLoginAppHost(cVerbInstant, var vAlpha, 'USERNAME', 'PASSWORD');
  DebugM('JwtLoginAppHost Erx: ' + aint(Erx) + cCrlf2 + 'JwtLoginAppHost Out: ' + vAlpha);
  Erx # JwtLogoutAppHost(cVerbInstant, vAlpha);
  DebugM('JwtLogoutAppHost Erx: ' + aint(Erx));
  */


  //vAlpha # TestAlex();

  /*
  // Beispiel für das Ausführen von BusinessLogic im AppHost und committen der Ergebnisse in C16
  vAlpha # '/api/Betriebsauftrag/KostenUmlage/1234/456';
  RecRead(903, 1, _RecFirst); // für Lib_ODBC:Init()
  Lib_ODBC:Init();  // erforderlich damit es auch in DEV STD funktioniert, denn bei uns läuft anders als bei allen Kunden der Sync ohne SOA und der SOA-lose Sync muss für STRG+T hier explizit initialisiert werden
  Erx # executeBusinessLogicTransaction(true, vAlpha);
  Lib_ODBC:Term();
  DebugM(__PROCFUNC__ + ': Ausgabe von executeBusinessLogicTransaction(): Erx=' + aint(Erx));
  */


  /*
  Erx # ApiHostAndPort(cVerbInstant, var vAlpha, 'ecodms');
  DebugM('Ausgabe von ApiHostAndPort(): ' + cCrlf + 'Erx=' + aint(Erx) + cCrlf + 'Result="' + vAlpha + '"');
  */


  /*
  Erx # GetTempDirectory_on_AppHost(cVerbInstant, var vAlpha);
  DebugM('Ausgabe von GetTempDirectory_on_AppHost(): ' + cCrlf + 'Erx=' + aint(Erx) + cCrlf + 'Result="' + vAlpha + '"');
  */


  /*
  Erx # DeleteTempFile_on_AppHost(cVerbInstant, 'loeschmich.txt', false);
  DebugM('Ausgabe von DeleteTempFile_on_AppHost(): ' + cCrlf + 'Erx=' + aint(Erx));
  */


  /*
  vLogic # SplitUrl('http://localhost:8180/', var vAlpha, var vBeta, var vInt, var vGamma);
  vLogic # SplitUrl('http://localhost/', var vAlpha, var vBeta, var vInt, var vGamma);
  vLogic # SplitUrl('http://1.2.3.4:8180', var vAlpha, var vBeta, var vInt, var vGamma);
  vLogic # SplitUrl('http://geht/eigentlich/nicht:8180', var vAlpha, var vBeta, var vInt, var vGamma);
  vLogic # SplitUrl('http://ohneport', var vAlpha, var vBeta, var vInt, var vGamma);
  //vLogic # SplitUrl('http:/explodiert_wg_fehlendem_slash:80', var vAlpha, var vBeta, var vInt, var vGamma);
  //vLogic # SplitUrl('ftp://explodiert_wg_nicht_http_oder_https:80', var vAlpha, var vBeta, var vInt, var vGamma);
  //vLogic # SplitUrl('http:/explodiert_wg_:_der_ueberzaehlig_ist:80', var vAlpha, var vBeta, var vInt, var vGamma);
  vLogic # SplitUrl('http://192.168.0.111:8180/api/document/71', var vAlpha, var vBeta, var vInt, var vGamma);
  vLogic # SplitUrl('http://192.168.0.111/api/document/71////', var vAlpha, var vBeta, var vInt, var vGamma);
  DebugM('SplitUrl Return Value: ' + Lib_Auxiliaries:CnvAL(vLogic));
  DebugM('SplitUrl Protokoll: ' + vAlpha);
  DebugM('SplitUrl Server: ' + vBeta);
  DebugM('SplitUrl Port: ' + aint(vInt));
  DebugM('SplitUrl Route: ' + vGamma);
  */



  // RequestAPI Demo am Beispiel EcoDMS
  // request json als cte anlegen:
  vCte # CteOpen(_CteNode);
  vCte->spID # _JsonNodeObject;
  vCte->CteInsertNode('apiName', _JsonNodeString, 'ecodms');
  vCte->CteInsertNode('apiMethod', _JsonNodeString, 'get');
  vCte->CteInsertNode('apiRoute', _JsonNodeString, 'api/test');
  vCte->CteInsertNode('timeout', _JsonNodeNumber, 20000);
  // der eigentliche Aufruf
  vDescription # 'Beispiel-Aufruf von RequestAPI';
  ErrorOutputWithDisclaimerPre(vDescription);
  Erx # RequestAPI(cVerbPost, var vAlpha, var vInt, vCte);
  ErrorOutputWithDisclaimerPost(vDescription);
  DebugM('Ausgabe von RequestAPI():' + cCrlf + 'Erx=' + aint(Erx) + cCrlf + 'HttpStatus: ' + aint(vInt) + cCrlf + 'Content: "' + vAlpha + '"');




  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;

end



//========================================================================
