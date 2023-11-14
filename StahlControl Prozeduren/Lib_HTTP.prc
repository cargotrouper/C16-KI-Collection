@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_HTTP
//                                  OHNE E_R_X
//  Info
//    Implementiert die Funktionalität um Updates von einem Webserver
//    herunterzuladen
//
//  25.02.2009  ST  Erstellung der Prozedur
//  17.06.2009  ST  Fertigstellung Version 1.0
//  18.06.2012  ST  Erweiterung um DownloadFile
//  17.01.2020  ST  sub DownloadFile(...) unterstützt jetzt HTTPS PRojhekt 1326/557
//  08.06.2022  DS  DownloadFile(...) unterstützt jetzt optionale HTTP Basic Auth; Projekt 2407/4
//  09.06.2022  DS  In DownloadFile() Länge von Argument aDestFile erhöht
//
//  Subprozeduren
//  SUB Connect(aIPAdress : alpha; opt aIpPort : word) : int
//  SUB GetResponseBody(aSck : int; aFilename : alpha; aSize: int; aDia : int) : logic
//  SUB SendHttpRequest(var aConn : int; var aLength : int; aUri : alpha; opt aAuth: alpha) : int
//  SUB CnvUserPass(aUser : alpha;  aPass : alpha;) : alpha
//  SUB StatusDialogInit(aText : alpha;  opt aMax : int;) : int
//  SUB StatusDialogUpdate(aDia  : int;  aText : alpha;  opt aPos : int;  opt aMax : int;) : int
//  SUB StatusDialogTerm(aDia : int;) : int
//  SUB GetUpdateFiles(aPfad : alpha;var aInfo : alpha;var aFile : alpha[];var aCnt : int;) : logic
//  SUB sub SendGetHttpRequest(var aConn   : int; var aLength : int; aHost : alpha; aUri: alpha(4096);) : int
//  SUB DownloadFile( aURI : alpha(512);  aDestFile : alpha;): int;
//
//========================================================================
@I:Def_global

//========================================================================
define begin
  mTimeout    : 2000
  mMaxBuffer  : 8192
  cSite       : '217.86.132.27'         // IP des Hostes
  cHTTP_Host  : 'stahl-control.eu'      // Servernamen und Domain
  cUpdateFile : 'update.txt'            // Updatedateinamen auf dem Server
  cPath       : '.\update\'             // Pfad zum Speicherort
  CRLF        : strchar(13)+strchar(10)
  
  MyDebug(a) : lib_debug:Dbg_debug(a)

  // aus C16_SysSOAP:
//  sSOAP.MemSizeAlloc        : _MemAutoSize
//  sSOAP.Charset             : _CharsetUTF8
//  sSOAP.CharsetStr          : 'UTF-8'
end;

declare StatusDialogUpdate(
  aDia  : int;
  aText : alpha;
  opt aPos : int;
  opt aMax : int;
  opt aProgCapt : alpha;
) : int


//========================================================================
// CutPort
//    schneidet die Portnummer aus einer URL
//========================================================================
sub CutPort(
  var aUri : alpha) : int;
local begin
  vI : int;
  vJ : int;
  vA : alpha;
end
begin
  // Port aus URI schneiden...
  vI # StrFind(aUri,':',1);
  if (vI>0) then begin
//lib_Debug:dbg_debug(aUri);
    vI # StrFindRegEx(aUri,'\:.*\/',vI+1);
    if (vI>0) then begin
//lib_Debug:dbg_debug(cnvai(vI));
      vJ # StrFind(aUri, '/', vI);
      if (vJ>0) then begin
//lib_Debug:dbg_debug(cnvai(vI));
        vA # StrCut(aUri,vI+1, vJ-vI-1);
        aUri # StrDel(aUri, vI, vJ-vI);
//lib_Debug:dbg_debug(vA+' aus '+aUri);
        RETURN cnvia(vA);
      end;
    end;
  end;
  
  RETURN 0;
end;


//========================================================================
//  Connect
//    Verbindung zu einem HTTP-Server herstellen
//========================================================================
sub Connect(
  aIpAdress   : alpha; // IP-Adresse oder Name des HTTP-Servers
  opt aIpPort : word;  // alternativ Port des HTTP-Servers
) : int
local begin
  Erx : int;
end;
begin

  if (aIpPort = 0) then aIpPort # 80;

  if (Set.Proxy<>'') then begin
    if (Set.Proxy.Port=0) then Set.Proxy.Port # 1080;

    Erx # SckConnect(aIpAdress,aIpPort, _SckProxySOCKSv5, 5000, Set.Proxy, Set.Proxy.Port);
    if (Erx=0) then RETURN Erx;
Msg(019999,'using SOCKS5-Proxy error: '+cnvai(Erx),_WinIcoError,_WinDialogOk,0);

    Erx # SckConnect(aIpAdress,aIpPort, _SckProxySOCKSv4a, 5000, Set.Proxy, Set.Proxy.Port);
    if (Erx=0) then RETURN Erx;
Msg(019999,'using SOCKS4a-Proxy error: '+cnvai(Erx),_WinIcoError,_WinDialogOk,0);
    Erx # SckConnect(aIpAdress,aIpPort, _SckProxySOCKSv4, 5000, Set.Proxy, Set.Proxy.Port);
    if (Erx=0) then RETURN Erx;
Msg(019999,'using SOCKS4-Proxy error: '+cnvai(Erx),_WinIcoError,_WinDialogOk,0);

    Erx # SckConnect(aIpAdress,aIpPort, 0, 5000, Set.Proxy, Set.Proxy.Port);
    if (Erx=0) then RETURN Erx;
Msg(019999,'using std.Proxy error: '+cnvai(Erx),_WinIcoError,_WinDialogOk,0);
    Erx # SckConnect(aIpAdress,aIpPort);
    if (Erx=0) then RETURN Erx;
Msg(019999,'using noProxy error: '+cnvai(Erx),_WinIcoError,_WinDialogOk,0);

    RETURN Erx;
  end;

  RETURN(SckConnect(aIpAdress,aIpPort));
end;


//========================================================================
//  GetResponseBody
//    Inhalt eines HTTP Responses in eine externe Datei speichern
//========================================================================
sub GetResponseBody(
  aSck      : int;   // Deskriptor des Sockets
  aFilename : alpha; // Pfad- und Dateiname
  aSize     : int;
  aDia      : int;
) : logic
local begin
  vBuffer     : byte[mMaxBuffer]; // Puffer zum Lesen der Datei
  vFile       : int;              // Dateideskriptor
  vReadBytes  : int;              // Anzahl der gelesenen Zeichen
  vGesamt     : int;
end;
begin
  if (aDia<>0) then
    StatusDialogUpdate(aDia,'',0,aSize/1024);


  // Externe Datei anlegen
  vFile # FsiOpen(aFileName,_FsiCreate | _FsiAcsRW);
  if (vFile > 0) then begin
    vReadBytes # 1;

    // Inhalt der Datei von Socket lesen bis keine Daten mehr vorhanden sind
    // oder ein Fehler aufgetreten ist.
    WHILE ((SckInfo(aSck,_SckReadyRead,mTimeout) = '0') AND (vReadBytes > 0)) do begin

      // Update des Statusdialogs und Abbruch ermöglichen
      if (aDia<>0) then begin
        StatusDialogUpdate(aDia,'',vGesamt/1024,0, 'KB von '+CnvAi(aSize/1024) + 'KB');
        if (aDia->WinDialogResult() = _WinIdCancel) then begin
          vFile->FSIclose();
          RETURN false;
        end;
      end;

      // Einlesen in eine Puffer-Variable
      vReadBytes # SckRead(aSck,_SckReadMax,vBuffer);

      // Wurden Zeichen vom Socket gelesen?
      if (vReadBytes > 0) then begin

        // Schreiben der Daten in die externe Datei
        FsiWrite(vFile,vBuffer,vReadBytes);
        vGesamt # vGesamt + vReadBytes;
      end

    END;
    // Externe Datei schließen
    vFile->FsiClose();

    // Prüfen ob das Update korrekt heruntergeladen wurde
    if (vGesamt < aSize) then
      RETURN false;

    end
  else
    RETURN false;

  RETURN true;
end; // SaveFile


//========================================================================
//  Send Request
//    Sendet einen HTTP Request an den angegebenen Server, gibt den
//    HTTP Request Code zurück und ändert die per Referenz übergebenen
//    Werte
//========================================================================
sub SendHttpRequest(
  var aConn   : int;
  var aLength : int;
  aUri        : alpha;
  opt aAuth   : alpha;
  opt aSite   : alpha(4096);
) : int
local begin
  vHeader    : alpha(4096);
  vReadBytes : int;
  vLine      : alpha;
  vStatus    : int;
  vLength    : int;
end;
begin

  // Verbindung zum Server aufnehmen
  if (aSite <> '') then
    aConn # Connect(aSite);    // ST 2012-06-13
  else
    aConn # Connect(cSite);

  if (aConn < 0) then
    RETURN 500;

  // Header aufbauen
  vHeader # 'GET '+ aUri + ' HTTP/1.1'  + CRLF +
            'Host: '+cHTTP_Host         + CRLF +
            'Range: bytes'              + CRLF +
            'Content-Type: multipart'   + CRLF;
  // ggf. Authorisierung beachten
  if (aAuth <> '') then
    vHeader # vHeader +
            'Authorization: Basic '+ aAuth + CRLF;

  // WICHTIG!!!! Leerzeile mitsenden, Trennt Header vom Body
  vHeader # vHeader +  CRLF+CRLF;
debug(vHeader);
  // Header zum Server schicken
  if (SckWrite(aConn,_SckLine,vHeader) < 0) then
    RETURN 500;

  // Response-Header lesen
  repeat
    //vReadBytes # SckRead(aConn,_SckLine,vBuffer,30);
    vReadBytes # SckRead(aConn,_SckLine,vLine);
    if (vLine <> '') then begin
      // Status
      if (StrFind(vLine,'HTTP/',1) > 0) then
        vStatus # CnvIa(StrCut(vLine,StrFind(vLine,' ',1),
                  Strlen(vLine) - (StrFind(vLine,' ',1)-1)));

      // Datenlänge
      if (StrFind(vLine,'Content-Length',1) >0) then
        aLength # CnvIa(StrCut(vLine,StrFind(vLine,' ',1),
                  Strlen(vLine) - (StrFind(vLine,' ',1)-1)));
    end else
      break;
  until (false);

  return vStatus;

end; // SendHttpRequest


//========================================================================
//  CnvUserPass
//      Konvertiert die angegebenen Anmeldedaten in ein HTTP Basic-Auth
//      konformes Format  (Base64)
//========================================================================
sub CnvUserPass(
  aUser : alpha;
  aPass : alpha;
) : alpha
local begin
  vAuth     : alpha;
  vMemObj   : int;
  vAuthObj  : int;
end;
begin

  // Format für HTTP-Basic Authorisierung: "username:pass"
  vAuth # Set.Update.User+':'+Set.Update.Pass;
  if (aUser <> '') OR (aPass <> '') then
    vAuth # aUser+':'+aPass;

  // --------------------------------------------------------------------------------------------
  // MemObjekt wird benutzt um Base64 konvertierung ohne Verschlüsselung zu ermöglichen
  vMemObj  # MemAllocate(_MemAutoSize);             // MemObj anlegen
  vMemObj->MemWriteStr(1,vAuth);                    // Authorisierungsstring zum Konvertieren schreiben
  vAuthObj # MemAllocate(vMemObj->spSize);          // MemObj anlegen
  vMemObj->MemCnv(vAuthObj,_MemEncBase64);          // Konvertierung
  vAuth # vAuthObj->MemReadStr(1,vAuthObj->spSize); // Übergabe an den zu benutzenden String
  vMemObj->MemFree();                               // MemObj wieder aus dem Speicher entfernen

  // Konvertierten String zurückgeben
  return vAuth;
end;  // CnvUserPass


//========================================================================
//  StatusDialogInit
//      Ruft den Statusdialog initial auf
//========================================================================
sub StatusDialogInit(
  aText : alpha;
  opt aMax : int;
) : int
local begin
  vDia        : int;
  vHdl,vHdl2  : int;
end;
begin
    vDia  # WinOpen('Dlg.Progress',_WinOpenDialog);
    vHdl  # Winsearch(vDia,'Label1');

    vHdl2 # Winsearch(vDia,'Progress');
    vHdl2->wpProgressPos # 0;

    if (aMax <> 0) then
      vHdl2->wpProgressMax # aMax;
    else
      vHdl2->wpProgressMax # 100;

    vHdl->wpcaption # aText;
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);

    return vDia;
end; // StatusDialogInit

//========================================================================
//  StatusDialogUpdate
//      Verändert die Werte des Status Dialogs
//========================================================================
sub StatusDialogUpdate(
  aDia  : int;
  aText : alpha;
  opt aPos : int;
  opt aMax : int;
  opt aProgCapt : alpha;
) : int
local begin
  vDia        : int;
  vHdl,vHdl2  : int;
end;
begin
    vHdl  # Winsearch(aDia,'Label1');
    vHdl2 # Winsearch(aDia,'Progress');

    // Caption
    if (aText <> '') then
      vHdl->wpcaption # aText;

    // Progressbar
    if (aPos <> 0) then
      vHdl2->wpProgressPos # aPos;

    if (aMax <> 0) then
      vHdl2->wpProgressMax # aMax;

    if (aProgCapt <> '') then
      vHdl2->wpCaption # aProgCapt;

    return vDia;
end; // StatusDialogUpdate


//========================================================================
//  StatusDialogTerm
//      Schließt den Statusdialog
//========================================================================
sub StatusDialogTerm(
  aDia : int;
) : int
begin
    aDia->WinClose();
end; // StatusDialogTerm



//========================================================================
//  GetUpdateFiles
//     Liest aus der Updatedatei alle Dateinamen, die heruntergeladen
//     werden müssen
//========================================================================
sub GetUpdateFiles(
  aPfad     : alpha;
  var aInfo : alpha;
  var aFile : alpha[];
  var aCnt  : int;
) : logic
local begin
  Erx         : int;
  vVersion    : alpha;
  vTxtHdl     : int;
  vX,vY       : int;
  vA          : alpha(4000);
  vTxt        : alpha(4000);
  vUpdate     : logic;
  //vTodo       : int;
  vFileHdl    : int;
end;
begin

  // aktuelle Version ermitteln...
  vTxtHdl # TextOpen(16);
  Erx # TextRead(vTxtHdl, '!VERSION',0);
  if (Erx<=_rLocked) then begin
    vVERSION # TextLineRead(vTxtHdl,1,0);
  end;

  //  Textinhalt in einen String kopieren, damit
  //  die Parsing-Methode aus der FTP Klasse benutzt
  //  werden kann
  vFileHdl # FsiOpen(aPfad,_FsiAcsR);
  if (vFileHdl > 0) then begin
    FsiRead(vFileHdl,vTxt);
    FsiClose(vFileHdl);
  end;


  // Parse Updatefile...
  vX # 0;
  REPEAT
    vY # StrFind(vTxt,strchar(13)+StrChar(10),vX);
    if (vY=0) then BREAK;

    vA # StrCut(vTxt,vX,vY-vX);

    // Versioncheck...
    if (StrFind(StrCnv(vA,_StrUpper) ,'VERSION:',0)>0) then begin
      vA # StrAdj(StrCut(vA,10,100),_StrBegin|_StrEnd);
      if (vA>vVersion) then vUpdate # y;
      end
    else if (StrFind(StrCnv(vA,_StrUpper) ,'FILE:',0)>0) then begin
      vA # StrAdj(StrCut(vA,6,100),_StrBegin|_StrEnd);
      aCnt # aCnt + 1;
      aFile[aCnt] # vA;
      end
    else begin
      aInfo # aInfo + StrCut(vTxt,vX,vY-vX+2);
    end;

    vX # vY + 2;
  UNTIL (vY=0);

  TextClose(vTxtHdl);

  return vUpdate;
end; // GetUpdateFiles




//========================================================================
//  SendGetRequest
//    Sendet einen HTTP Request an den angegebenen Server, gibt den
//    HTTP Request Code zurück und ändert die per Referenz übergebenen
//    Werte
//========================================================================
sub SendGetHttpRequest(
  var aConn   : int;
  var aLength : int;
  aHost       : alpha;
  aUri        : alpha(4096);
  opt aAuth   : alpha(4096)
) : int
local begin
  vHeader    : alpha(4096);
  vReadBytes : int;
  vLine      : alpha;
  vStatus    : int;
  vLength    : int;
end;
begin

  // Verbindung zum Server aufnehmen
  aConn # Connect(aHost);    // ST 2012-06-13

  if (aConn < 0) then
    RETURN 500;

  // Header aufbauen
  vHeader # 'GET '+ aUri + ' HTTP/1.1'  + CRLF +
            'Host: '+aHost              + CRLF +
            'Range: bytes'              + CRLF +
            'Content-Type: multipart'   + CRLF;
  // ggf. Authorisierung beachten
  if (aAuth <> '') then
    vHeader # vHeader +
            'Authorization: Basic '+ aAuth + CRLF;



  // WICHTIG!!!! Leerzeile mitsenden, Trennt Header vom Body
  vHeader # vHeader +  CRLF+CRLF;

  // Header zum Server schicken
  if (SckWrite(aConn,_SckLine,vHeader) < 0) then
    RETURN 500;

  // Response-Header lesen
  repeat
    //vReadBytes # SckRead(aConn,_SckLine,vBuffer,30);
    vReadBytes # SckRead(aConn,_SckLine,vLine);
    if (vLine <> '') then begin
      // Status
      if (StrFind(vLine,'HTTP/',1) > 0) then
        vStatus # CnvIa(StrCut(vLine,StrFind(vLine,' ',1),
                  Strlen(vLine) - (StrFind(vLine,' ',1)-1)));

      // Datenlänge
      if (StrFind(vLine,'Content-Length',1) >0) then
        aLength # CnvIa(StrCut(vLine,StrFind(vLine,' ',1),
                  Strlen(vLine) - (StrFind(vLine,' ',1)-1)));
    end else
      break;
  until (false);

  return vStatus;

end; // SendGetHttpRequest


//========================================================================
//  sub DownloadFile( aURI : alpha(512);  aDestFile : alpha;): int;
//    Lädt eine Datei anhand einer URL und einem Pfad herunter.
//
//    Kopie aus Beispiel aus der C16 Hilfe
//
//  08.06.2022  DS  DownloadFile() ünterstützt jetzt optionale HTTP Basic Auth; Projekt 2407/4
//========================================================================
sub DownloadFile
(
  aURI      : alpha(512);
  aDestFile : alpha(1024);
  opt aPort : int;
  opt aBasicAuthUser : alpha(512);
  opt aBasicAuthPass : alpha(512);
  opt aSckOptions : int;  // siehe Argument int3 von SckConnect. Bei Rückgabewert -741 könnte hier der Wert _SckTlsSNI helfen
  opt verboseOnErrors : logic; // Fehlermeldungen aktivieren
  opt aTimeout : int;  // timeout für connection in Millisekunden
) : int;
local begin
  tHost               : alpha(128);     // Hostname
  tPath               : alpha(512);     // Path
  tPos                : int;
  tError              : int;            // Errorcode

  tSck                : handle;         // Socket
  tReq                : handle;         // Request-Object
  tRsp                : handle;         // Response-Object
  tLst                : handle;         // HTTP-Header-List
  tFsi                : handle;         // File
  
  visHttps : logic;
  vUrl  : alpha(1024);
  
  vBasicAuthUse : logic;
  vBasicAuthB64 : alpha(4096);
end
begin

  if (!(aURI =*^ 'http*://*')) then
    return(_ErrData);
    
  if aSckOptions = 0 then
    aSckOptions # _SckTlsMed;
  
  visHttps # (StrCnv(StrCut(aUri,1,5),_StrLower) = 'https');
  
  if (aPort=0) then begin
    if (visHttps) then
      aPort # 443;
    else
      aPort # 80;
  end;
  
  // URI in Host und Pfad zerlegen
// ST 2020-01-17 alte Version von Vectorsoft
/*
  tPos # StrFind(aURI,'/',8);
  if (tPos = 0) then begin
    tHost # StrCut(aURI,8,StrLen(aURI)-7);
    tPath # '/';
  end else begin
    tHost # StrCut(aURI,8,tPos - 8);
    tPath # StrCut(aURI,tPos,StrLen(aURI) + 1 - tPos);
  end;
*/
  // ST 2020-01-17 1326/557: Neue Version für HTTPS und HTTP
  vUrl  # Str_Token(aUri,'//',2);                        //   https://www.google.de/suche/?x=y --> www.google.de/suche/?x=y
  tHost # Str_Token(vUrl,'/',1);                         //   www.google.de/suche/?x=y         --> www.google.de
  tPath # Lib_Strings:Strings_ReplaceAll(vUrl,tHost,''); //   www.google.de/suche/?x=y         --> /suche/?x=y
  
  vBasicAuthUse # aBasicAuthUser <> '' or aBasicAuthPass <> ''
  if vBasicAuthUse then
  begin
    vBasicAuthB64 # CnvUserPass(aBasicAuthUser, aBasicAuthPass);
  end

  if aTimeout = 0 then aTimeout # 10000;

  TRY begin
    // Verbindung aufbauen
    tSck # SckConnect(tHost, aPort, aSckOptions, aTimeout);
    // Anfrage erzeugen
    tReq # HttpOpen(_HttpSendRequest,tSck);
    
    tLst # tReq->spHttpHeader;
    tReq->spURI      # tPath;
    tReq->spProtocol # 'HTTP/1.1';
    tLst->CteInsertItem('Host',0,tHost);
    tLst->CteInsertItem('Accept',0,'*/*');
    if vBasicAuthUse then
    begin
      tLst->CteInsertItem('Authorization', 0, 'Basic ' + vBasicAuthB64);
    end

    // Anfrage senden
    tReq->HttpClose(_HttpCloseConnection);
    tReq # 0;

    // Antwort abholen
    tRsp # HttpOpen(_HttpRecvResponse,tSck);
    if (tRsp->spStatusCode =* '200*' and
        tRsp->spContentLength > 0)
    then begin
      tFsi # FsiOpen(aDestFile,_FsiStdWrite);
//      tFsi # MemAllocate(_mem1K);
      // Datei speichern
      tRsp->HttpGetData(tFsi);
    end
    else
    begin
      if verboseOnErrors then
        Msg(99, 'Fehler beim Herunterladen von "' + aURI + '" via Port ' + CnvAI(aPort) + '".' + StrChar(10) + 'Status Code: ' + tRsp->spStatusCode + ', Content-Länge: ' + CnvAI(tRsp->spContentLength), _WinIcoError, 0, 0);
    end
  END;

  tError # ErrGet();

  // angelegte Deskriptoren entfernen
  if (tReq > 0) then
    tReq->HttpClose(_HttpDiscard);
  if (tFsi > 0) then
    tFsi->FsiClose();
  if (tRsp > 0) then
    tRsp->HttpClose(0);
  if (tSck > 0) then
    tSck->SckClose();

  return(tError);
end;


//========================================================================
//  sub GetToMem( aURI : alpha(512);  aMem : int;): int;
//    sendet GET und Ergebnis ins Memory
//========================================================================
sub GetToMem(
  aURI      : alpha(512);
  var aMem  : int;
  opt aPort : int;): int;
local begin
  tHost               : alpha(128);     // Hostname
  tPath               : alpha(512);     // Path
  tPos                : int;
  tError              : int;            // Errorcode

  tSck                : handle;         // Socket
  tReq                : handle;         // Request-Object
  tRsp                : handle;         // Response-Object
  tLst                : handle;         // HTTP-Header-List
  tFsi                : handle;         // File
  
  visHttps  : logic;
  vUrl      : alpha(1024);
  vPort     : int;
end
begin

  if (!(aURI =*^ 'http*://*')) then
    return(_ErrData);
  
  visHttps # (StrCnv(StrCut(aUri,1,5),_StrLower) = 'https');

  vPort # CutPort(var aUri);
  if (aPort=0) then
    aPort # vPort;
  
//  xxxx :123456/hallo/du
  
  if (aPort=0) then begin
    if (visHttps) then
      aPort # 443;
    else
      aPort # 80;
  end;
  
  vUrl  # Str_Token(aUri,'//',2);                        //   https://www.google.de/suche/?x=y --> www.google.de/suche/?x=y
  tHost # Str_Token(vUrl,'/',1);                         //   www.google.de/suche/?x=y         --> www.google.de
  tPath # Lib_Strings:Strings_ReplaceAll(vUrl,tHost,''); //   www.google.de/suche/?x=y         --> /suche/?x=y


  TRY begin
    // Verbindung aufbauen
    tSck # SckConnect(tHost, aPort,_SckTlsMed,10000);
    // Anfrage erzeugen
    tReq # HttpOpen(_HttpSendRequest,tSck);
    
    tLst # tReq->spHttpHeader;
    tReq->spURI      # tPath;
    tReq->spProtocol # 'HTTP/1.1';
    tLst->CteInsertItem('Host',0,tHost);
    tLst->CteInsertItem('Accept',0,'*/*');

    // Anfrage senden
    tReq->HttpClose(_HttpCloseConnection);
    tReq # 0;

    // Antwort abholen
    tRsp # HttpOpen(_HttpRecvResponse,tSck);
//Lib_Debug:Dbg_Debug(tRsp->spStatusCode+' Len:'+aint(tRsp->spContentLength));
    if (tRsp->spStatusCode =* '200*' and
        tRsp->spContentLength <> 0)
    then begin
      // Datei speichern
      //tRsp->HttpGetData(tFsi);
      if (aMem=0) then aMem # MemAllocate(_MemAutoSize);
      tRsp->HttpGetData(aMem);
    end;
  END;

  tError # ErrGet();

  // angelegte Deskriptoren entfernen
  if (tReq > 0) then
    tReq->HttpClose(_HttpDiscard);
  if (tFsi > 0) then
    tFsi->FsiClose();
  if (tRsp > 0) then
    tRsp->HttpClose(0);
  if (tSck > 0) then
    tSck->SckClose();

  RETURN(tError);
end;

/**** in LIB_HTTP.Core
//========================================================================
//  sub PostToMem( aURI : alpha(512);  aMem : int;): int;
//    sendet POST und Ergebnis ins Memory
//========================================================================
sub PostToMem(
  aURI      : alpha(512);
  var aMem  : int;
  opt aPort : int;
  opt aObjBody : int): int;
local begin
  tHost               : alpha(128);     // Hostname
  tPath               : alpha(512);     // Path
  tPos                : int;
  tError              : int;            // Errorcode

  tSck                : handle;         // Socket
  tReq                : handle;         // Request-Object
  tRsp                : handle;         // Response-Object
  tLst                : handle;         // HTTP-Header-List
  tFsi                : handle;         // File
  
  visHttps  : logic;
  vUrl      : alpha(1024);
  vPort     : int;
  vBody     : int;
  tCteNodeXMLElement : handle;
  tMem  : handle;
end
begin

  if (!(aURI =*^ 'http*://*')) then
    return(_ErrData);
  
  visHttps # (StrCnv(StrCut(aUri,1,5),_StrLower) = 'https');

  vPort # CutPort(var aUri);
  if (aPort=0) then
    aPort # vPort;

  if (aPort=0) then begin
    if (visHttps) then
      aPort # 443;
    else
      aPort # 80;
  end;
  
  vUrl  # Str_Token(aUri,'//',2);                        //   https://www.google.de/suche/?x=y --> www.google.de/suche/?x=y
  tHost # Str_Token(vUrl,'/',1);                         //   www.google.de/suche/?x=y         --> www.google.de
  tPath # Lib_Strings:Strings_ReplaceAll(vUrl,tHost,''); //   www.google.de/suche/?x=y         --> /suche/?x=y

  TRY begin
    // Verbindung aufbauen
    tSck # SckConnect(tHost, aPort,_SckTlsMed,10000);
    // Anfrage erzeugen
    tReq # HttpOpen(_HttpSendRequest,tSck);
    
    tLst # tReq->spHttpHeader;
    tReq->spURI      # tPath;

    tReq->spMethod # 'POST';
    tReq->spProtocol # 'HTTP/1.1';
    tLst->CteInsertItem('Host',0,tHost);
    // Anfrage senden
    if (aObjBody<>0) then begin
    vBody # MemAllocate(sSOAP.MemSizeAlloc);
    vBody->spCharset # sSOAP.Charset;

          tMem # MemAllocate(_MemAutoSize);
          tMem->spCharset # sSOAP.Charset;
          for   tCteNodeXMLElement # aObjBody->CteRead(_CteChildList | _CteFirst)
          loop  tCteNodeXMLElement # aObjBody->CteRead(_CteChildList | _CteNext, tCteNodeXMLElement)
          while (tCteNodeXMLElement > 0) do begin
            tCteNodeXMLElement->XMLSave('', _XMLSavePure, tMem, sSOAP.Charset);
            tMem->MemCopy(1, _MemDataLen, _MemAppend, vBody);
            tMem->spLen # 0;
          end;
          tMem->MemFree();

Lib_Debug:Dbg_Debug('vBodyLen='+cnvai(vBody->splen));
Lib_Debug:Dbg_Debug(MemReadStr(vBody, 1,50));
      
      tLst->CteInsertItem('Content-Type',0,'application/json');
      tReq->HttpClose(_HttpCloseConnection, vBody);
      MemFree(vBody);
    end
    else begin
      tReq->HttpClose(_HttpCloseConnection);
    end;
    tReq # 0;

    // Antwort abholen
    tRsp # HttpOpen(_HttpRecvResponse,tSck);
Lib_Debug:Dbg_Debug(tRsp->spStatusCode+' Len:'+aint(tRsp->spContentLength));
    if (tRsp->spStatusCode =* '200*' and
        tRsp->spContentLength <> 0)
    then begin
      // Datei speichern
      //tRsp->HttpGetData(tFsi);
      if (aMem=0) then aMem # MemAllocate(_MemAutoSize);
      tRsp->HttpGetData(aMem);
    end;
  END;

  tError # ErrGet();

  // angelegte Deskriptoren entfernen
  if (tReq > 0) then
    tReq->HttpClose(_HttpDiscard);
  if (tFsi > 0) then
    tFsi->FsiClose();
  if (tRsp > 0) then
    tRsp->HttpClose(0);
  if (tSck > 0) then
    tSck->SckClose();

  RETURN(tError);
end;
**/
*/

//************************************************************************
//************************************************************************
//************************************************************************
//************************************************************************
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
local begin
    tErr                : int;
    tMem                : handle;
    tCteNodeXMLElement  : handle;
    tHTTP               : handle;
    tCteListHTTPHeader  : handle;
    tRetry              : logic;
    vI, vJ, vTmp, vtmp2 : int;
    vTxt                : handle;
    gMem : int;
end;
begin
  gMem # MemAllocate(_MemAutoSize);
/***
//TODO  aSOAP->Inst();
  gMem->spLen # 0;

  gMem->MemWriteStr(_MemAppend,
    '<?xml version="1.0" encoding="' + sSOAP.CharsetStr + '"?>' +
    '<s:Envelope xmlns:s="' + gSOAPNamespace + '"'
  );

  if (gSOAPUse = _SOAP.UseEncoded) then
    gMem->MemWriteStr(_MemAppend,
      ' s:encodingStyle="' + gSOAPNamespaceEnc + '"' +
      ' xmlns:xsd="' + sSOAP.NamespaceXSD + '"' +
      ' xmlns:xsi="' + sSOAP.NamespaceXSI + '"'
    );

  gMem->MemWriteStr(_MemAppend, ' xmlns="' + gNamespace + '">');

  // Kein Header-Objekt übergeben
  if (aObjHeader = 0) then begin
    // Header-Elemente vorhanden
    if (gCteNodeRqsHeader->spChildCount > 0) then begin
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
    end;
  end
  // Header-Objekt übergeben
  else begin
    case (aObjHeader->HdlInfo(_HdlType)) of
      _HdlMem     : begin
        if (aObjHeader->spLen > 0) then begin
          gMem->MemWriteStr(_MemAppend, '<s:Header>');
          aObjHeader->MemCopy(1, _MemDataLen, _MemAppend, gMem);
          gMem->MemWriteStr(_MemAppend, '</s:Header>');
        end;
      end;
      
      _HdlCteNode : begin
        if (aObjBody->spChildCount > 0) then begin
          gMem->MemWriteStr(_MemAppend, '<s:Header>');
          tMem # MemAllocate(_MemAutoSize);
          tMem->spCharset # sSOAP.Charset;

          for   tCteNodeXMLElement # aObjHeader->CteRead(_CteChildList | _CteFirst);
          loop  tCteNodeXMLElement # aObjHeader->CteRead(_CteChildList | _CteNext, tCteNodeXMLElement);
          while (tCteNodeXMLElement > 0) do begin
            tCteNodeXMLElement->XMLSave('', _XMLSavePure, tMem, sSOAP.Charset);
            tMem->MemCopy(1, _MemDataLen, _MemAppend, gMem);
            tMem->spLen # 0;
          end;

          tMem->MemFree();
          gMem->MemWriteStr(_MemAppend, '</s:Header>');
        end;
      end;
    end;
  end;


  // Body-Element öffnen
  gMem->MemWriteStr(_MemAppend, '<s:Body');


  // Kein Body-Objekt übergeben
  if (aObjBody = 0) then begin
    // Keine Body-Elemente vorhanden
    if (gCteNodeRqsBody->spChildCount = 0 and aMethod = '') then begin
      // Body-Element schließen
      gMem->MemWriteStr(_MemAppend, '/>');
    end
    // Body-Elemente vorhanden
    else begin
      gMem->MemWriteStr(_MemAppend, '>');

      // Werte typisieren
      gCteNodeRqsBody->ElementTypify();

      gCteNodeRqsBody->spID # _XMLNodeElement;
      gCteNodeRqsBody->spName # aMethod;

      tMem # MemAllocate(_MemAutoSize);
      tMem->spCharset # sSOAP.Charset;
      gCteNodeRqsBody->XMLSave('', _XMLSavePure, tMem, sSOAP.Charset);
      if (aMethod != '') then
        tMem->MemCopy(1, _MemDataLen, _MemAppend, gMem);
      else
        // Leere öffnende und schließende Elemente ("<>" und "</>") entfernen
        tMem->MemCopy(1 + 2, tMem->spLen - 2 - 3, _MemAppend, gMem);
      tMem->MemFree();


      // Falls ein JSON-Parahandle vorhandne ist, diesen nun einfügen an Stelle des Platzhalters "XxX_PARA_XxX"
      if (aParaHandle<>0) then begin
        // den JSON-ParaHandle in eigenes MemObj serialisieren...
        tMem # MemAllocate(_MemAutoSize);
        tMem->spCharset # sSOAP.Charset;
        vI # aParaHandle->JSONSave('',_JsonSavePure, tMem, sSOAP.Charset);  // purEeee

        // Problem: JSON hat Anführungszeichen, aber in XML müssen diese "&quot;" sein!
        // Also das MemObj n einen Textbuffer schieben, dort die Zeichenumwandlungen mamchen und so wieder zurück in das MemObj
        vTxt # TextOpen(16);
        Lib_Texte:ReadFromMem(vTxt, tMem, 1, _MemDataLen);
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
      end;

      gMem->MemWriteStr(_MemAppend, '</s:Body>');
    end
  end
  // Body-Objekt übergeben -------------------------------------
  else begin
    Case (aObjBody->HdlInfo(_HdlType)) of
      _HdlMem     : begin
        if (aObjBody->spLen = 0) then begin
          // Body-Element schließen
          gMem->MemWriteStr(_MemAppend, '/>');
        end
        else begin
          gMem->MemWriteStr(_MemAppend, '>');
          aObjBody->MemCopy(1, _MemDataLen, _MemAppend, gMem);
          gMem->MemWriteStr(_MemAppend, '</s:Body>');
        end;
      end;
      
      _HdlCteNode : begin
        if (aObjBody->spChildCount = 0) then begin
          // Body-Element schließen
          gMem->MemWriteStr(_MemAppend, '/>');
        end
        else begin
          gMem->MemWriteStr(_MemAppend, '>');
          tMem # MemAllocate(_MemAutoSize);
          tMem->spCharset # sSOAP.Charset;

          for   tCteNodeXMLElement # aObjBody->CteRead(_CteChildList | _CteFirst);
          loop  tCteNodeXMLElement # aObjBody->CteRead(_CteChildList | _CteNext, tCteNodeXMLElement);
          while (tCteNodeXMLElement > 0) do begin
            tCteNodeXMLElement->XMLSave('', _XMLSavePure, tMem, sSOAP.Charset);
            tMem->MemCopy(1, _MemDataLen, _MemAppend, gMem);
            tMem->spLen # 0;
          end

          tMem->MemFree();
          gMem->MemWriteStr(_MemAppend, '</s:Body>');
        end;
      end;
    end;
  end;


  gMem->MemWriteStr(_MemAppend, '</s:Envelope>');

//MYDEBUG();

  REPEAT
    // HTTP-Objekt öffnen
    tHTTP # HTTPOpen(_HTTPSendRequest, gSck);
    // HTTP-Objekt geöffnet
    if (tHTTP > 0) then begin
      // URI übernehmen
      tHTTP->spURI # gResource;
      // Methode übernehmen
      tHTTP->spMethod # 'POST';
      // Host übernehmen
      tHTTP->spHostName # gHost;

      tCteListHTTPHeader # tHTTP->spHttpHeader;

      if (aAction != '' and !(aAction =* '"*"')) then
        aAction # '"' + aAction + '"';

      // Content-Type setzen
      if (gSOAPVersion = _SOAP.Version1.1 or aAction = '') then
        tCteListHTTPHeader->CteInsertItem('Content-Type', 0, gSOAPContentType + '; charset=' + sSOAP.CharsetStr);
      else
        tCteListHTTPHeader->CteInsertItem('Content-Type', 0, gSOAPContentType + '; charset=' + sSOAP.CharsetStr + '; action=' + aAction);

      // SOAPAction setzen
      if (aAction != '' and gSOAPVersion = _SOAP.Version1.1) then
        tCteListHTTPHeader->CteInsertItem('SOAPAction', 0, aAction);

//vTMP # FSIOpen('C:\wurst.txt',_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
//FsiWriteMem(vTMP, gMem, 1,  gMem->spLen);
//FsiCLose(vTMP);

      // BODY ÜBERGEBEN <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      // BODY ÜBERGEBEN <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      // BODY ÜBERGEBEN <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      tErr # tHTTP->HTTPClose(0, gMem);
      // Socket-Fehler
      if (tRetry = false and tErr < -700 and tErr > -800) then begin
        tRetry # true;
        // Socket schließen
        gSck->SckClose();
        // Socket-Verbindung herstellen
        gSck # SckConnect(gHost, gPort, gOptionsSocket, gTimeoutSocket);
        // Socket-Verbindung hergestellt
        if (gSck > 0) then
          CYCLE;
        // Fehler beim Herstellen der Socket-Verbindung
        else begin
          tErr # gSck;
          gSck # 0;
        end;
      end
    end
    // Fehler beim Öffnen des HTTP-Objekts
    else
      tErr # tHTTP;
  UNTIL (false);

  gMem->spLen # 0;

  // Speicherblockgröße begrenzen
  if (gMem->spSize > sSOAP.MemSizeLimit) then
    gMem->MemResize(sSOAP.MemSizeLimit);

  // Versand-Body-Daten leeren
  gCteNodeRqsBody->CteClear(true);

  ErrSet(tErr);
***/
  RETURN(tErr);
end;



//************************************************************************
//************************************************************************
//  MAIN
//************************************************************************
//************************************************************************
main
local begin
  // Statusdialog Variablen
  vDia        : int;

  // HTTP Variablen
  vConnection     : int;
  vUserAuth       : alpha;
  vUri            : alpha(256);
  vRemotePath     : alpha(32);
  vResponseStatus : int;
  vDataLength     : int;

  // Updatedateien Varialblen
  vFiles        : alpha[5];
  vInfotext     : alpha(4000);
  i,vCnt        : int;
end;
begin

  // Anmeldung vorbereiten
  vUserAuth # CnvUserPass(Set.Update.User,Set.Update.Pass);

  // Onlineverzeichnis lesen und ggf. korrigieren
  vRemotePath # Set.Update.Subdir;
  // Backslashes in normale umwandeln
  vRemotePath # Str_ReplaceAll(vRemotePath,'\','/');
  // alle Slashes entfernen
  vRemotePath # Str_ReplaceAll(vRemotePath,'/','');

  // Datei zum prüfen einstellen
  vUri # '/'+vRemotePath+'/update.txt';

  // Prüfen ob ein Update vorhanden ist  (Status 200 = OK)
  vResponseStatus # sendHttpRequest(var vConnection,var vDataLength, vUri,vUserAuth);
  if (vResponseStatus = 200) then begin

    vDia # StatusDialogInit('Suche nach Updates...');

    // Update-Infodatei herunterladen
    if (!GetResponseBody(vConnection,cPath+cUpdateFile,vDataLength,vDia)) then begin
      // Abbruch?
      WindialogBox(gFrmMain,'Update','Update abgebrochen!', _WinIcoError,_WinDialogOk,1);
    end else

    // Alle Notwendigen Dateien herunterladen
    if (GetUpdateFiles(cPath+cUpdateFile,var vInfotext,var vFiles, var vCnt)) then begin

      StatusDialogUpdate(vDia,'Empfange Daten...');

      // Alle Datein jetzt herunterladen
      FOR i # 1 loop inc(i) WHILE (i<=vCnt) DO BEGIN

        // Pfad für die Datei zusammensetzen
        vUri # '/'+vRemotePath +'/'+ vFiles[i];

        // Falls die RemoteDatei in einer tieferen Ordnerstruktur liegt,
        // dann muss vorher der Pfad abgeschnitten werden, damit alle Dateien
        // im Updateordner liegen
        vFiles[i] # Str_ReplaceAll(vFiles[i],'/','\');
        vFiles[i] # StrCut( vFiles[i], StrFind(vFiles[i], '\', 1, _strFindReverse ), StrLen( vFiles[i]) );

        StatusDialogUpdate(vDia,'Lade Datei '+CnvAi(i) + '/'+ CnvAi(vCnt)+ ': '+vFiles[i]);

        // Datei anfragen...
        vResponseStatus # sendHttpRequest(var vConnection,var vDataLength, vUri, vUserAuth);

        // ... und bei Erfolg speichen
        if (vResponseStatus = 200) then begin

          // falls die Datei schon vorhanden ist, dann vorher löschen
          FsiDelete(cPath+vFiles[i]);

          if (!GetResponseBody(vConnection,cPath+vFiles[i],vDataLength,vDia)) then begin
            // Abbruch?
            WindialogBox(gFrmMain,'Update','Update abgebrochen!', _WinIcoError,_WinDialogOk,1);
            vInfotext # '';

            // falls das Update abgebrochen wurde, dann angefangene Datei löschen
            FsiDelete(cPath+vFiles[i]);
          end;

        end;

      END;

      // Alles fertig, dann Infotextanzeigen
      if (vInfotext <> '') then
        WindialogBox(gFrmMain,'Update',vInfotext, _WinIcoWarning,_WinDialogOk,1);


    end else begin
      // Nur updates für ältere Versionen vorhanden1
      WindialogBox(gFrmMain,'Update','Die Software ist auf dem neusten Stand!', _WinIcoWarning,_WinDialogOk,1);

    end;

    StatusDialogTerm(vDia);

  end else begin
    // Fehler bei der Kommunikation
    if (vResponseStatus = 500) then
      WindialogBox(gFrmMain,'Update','Fehler beim Verbindungsaufbau zum Updateserver!', _WinIcoError,_WinDialogOk,1);

    if (vResponseStatus = 404) then
      WindialogBox(gFrmMain,'Update','Es sind keine neuen Updates verfügbar', _WinIcoWarning,_WinDialogOk,1);
  end;

end;


//========================================================================