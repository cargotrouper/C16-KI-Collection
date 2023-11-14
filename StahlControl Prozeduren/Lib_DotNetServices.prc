@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_DotNetServices
//                        OHNE E_R_G
//  Info
//      gNetServertyp # 2;  // bei NetCore
//      gNetServertyp # 1;  // NetFramework
//
//
//  23.11.2017  AH  Erstellung der Prozedur
//  15.06.2018  AH  "PlaneRsoResASAP"
//  26.09.2018  AH  Versionsprüfung vom ApplicationHost
//  19.06.2020  ST  getTempDok() hinzugefügt 1326/585
//  10.07.2020  AH  Remote-Befehle können auch mit Core3.1 Client
//  02.09.2020  ST  gResultJson wird bei Download benutzt
//  09.09.2020  ST  "sub Active" optionaler Parameter für Aufruf aus Orga
//  10.09.2020  ST  "_DownloadFile(...)" Fehlerfall vom Frx: 'null' -> ''
//  14.09.2020  ST  "sub _PollForMEdateda" Pollt im Fehlerfall 5 mal weiter
//  21.10.2020  AH  NetCore Anbindung
//  27.01.2021  AH  Fix für Designer
//  31.08.2021  AH  Dynamischer Remoteport
//  2023-07-05  ST  "MussCore" per Benutzergrupppe
//
//  Subprozeduren
//
//  sub Version(aURL : alpha) : alpha;
//  sub Active(aURL : alpha; opt aTimeout : int) : alpha;
//  sub PlaneRsoResJIT(aURL : alpha(1000); aResNr : int; var aRequestID : bigint) : alpha;
//  sub PlaneRsoResASAP(aURL : alpha(1000); aResNr : int; var aRequestID : bigint) : alpha;
//  sub Test(aURL : alpha; aName : alpha) : alpha;
//
//  sub Remote_Gantt(aResGrp : int; aResNr : int; aDatum : date) : alpha;
//  sub Remote_RsoKalender(aResGrp : int) : alpha;
//
//  sub UpdateSplash(aSplashHdl : int; aText : alpha)
//  sub _PollForMetaData(...)
//  sub _DownloadFile(...)
//  sub _RemoteDelete(...)
//  sub GetTempDok(...)
//
//========================================================================
@I:Def_Global

define begin
  // Mindest Version vom Print-Server
  c_MinVersion      : '1.0.8560.18520'

  c_MinVersionCore  : '1.1.8175.32981'
  
  //cMussCore     : ((gUsername='AxH') and (today<=13.4.2021)) or (gUsername='FSx') OR (gUsername = 'S T')
  cMussCore     : UseAppHost()
  
  cDarfLokal    : gUserGroup='PROGRAMMIERER'
  cKannServer   : true
//  cCoreClientPort : '7011'
  cCoreClientPort : gRemotePort + 500
  // war 5999
end;




//========================================================================
// sub isUserGroupHPA(aUsrGrp : alpha) : logic
//   Prüft ob der angemeldete User die Rechtegruppe für HPA hat
//========================================================================
sub UseAppHost() : logic
local begin
  v802  : int;
  vRet : logic;
end
begin
  v802 # RekSave(802);
  vRet # false;

  "Usr.U<>G.User" # gUsername;
  "Usr.U<>G.Gruppe"  # 'APPHOST';
  if (RecRead(802,1,0) = _rOK) then
    vRet # true;

  RekRestore(v802);
  RETURN vRet;
end;




//========================================================================
//========================================================================
sub DebugURL() : alpha;
local begin
  vURL            : alpha;
end;
begin
  RETURN 'HTTP://LOCALHOST:25001/LOCAL/';
end;


//========================================================================
//========================================================================
sub LocalURL(var aPort : int) : alpha;
local begin
  vURL            : alpha;
end;
begin

//  if (cCore) then
//    RETURN 'HTTPS://LOCALHOST:5001/API/'
//  else
  aPort # 5001;
  vUrl # 'HTTP://LOCALHOST:5001/LOCAL/';
  
  // ST 2021-08-04
  if (isTestsystem) then begin
    aPort # 5003;
    vUrl # 'HTTP://LOCALHOST:5003/LOCAL/';
  end;
  
  RETURN vUrl;
end;


//========================================================================
// ServerURL
//    Gibt die ServerUrl aus OHNE Endung "REPORT/" !!!
//    mit Endung "/"
//========================================================================
sub ServerURL(var aPort : int)   : alpha;
local begin
  vA,vB,vC  : alpha(1000);
  vI        : int;
  vURL      : alpha(1000);
end;
begin
//  if (cCore) then
//    RETURN 'HTTPS://LOCALHOST:5001/API/';

  vUrl # StrCnv(Set.SQL.PrintSrvURL,_StrUpper);
  if (isTestsystem) then begin
    if (StrCut(vURL,1,5)='HTTP:') then begin
      vA # Str_Token(vURL, ':',2);
      vB # Str_Token(vURL, ':',3);
      vI # StrFind(vB,'/',1);
      vC # StrCut(vB,vI,100);
      vB # StrCut(vB,1,vI);
      aPort # cnvia(vB)+2;            // TESTSYSTEM PORT +2
      vURL # 'HTTP:'+ vA + ':' + aint(aPort) + vC;
    end
    else begin
      vA # Str_Token(vURL, ':',1);
      vB # Str_Token(vURL, ':',2);
      aPort # cnvia(vB)+2;            // TESTSYSTEM PORT +2
      vURL # vA + ':' + aint(aPort);
    end;
  end
  else begin
    if (StrCut(vURL,1,5)='HTTP:') then begin
      vA # Str_Token(vURL, ':',2);
      vB # StrCut(Str_Token(vURL, ':',3),1,5);
      aPort # cnvia(vB);
    end
    else begin
      vA # Str_Token(vURL, ':',1);
      vB # Str_Token(vURL, ':',2);
      aPort # cnvia(vB);
    end;
  end;

  if (StrCut(vUrl,StrLen(vURL)-5,6)='REPORT') then
    vURL # StrCut(vUrl, 1, StrLen(vURL)-6);
  else if (StrCut(vUrl,StrLen(vURL)-6,7)='REPORT/') then
    vURL # StrCut(vUrl, 1, StrLen(vURL)-7);

  RETURN vURL;
end;


//========================================================================
//========================================================================
Sub BaseInit(
  var aURL      : alpha;
  aName         : alpha;
  var aSOAP     : int;
  var aSOAPBody : int;
  var aErr      : alpha) : int;
local begin
  vPort : int;
end;
begin

  // ST 2020-06-26 Reset
  aSOAP     # 0;
  aSOAPBody # 0;
  aErr      # '';

  aUrl # aUrl + aName;

  // Initialisierung: SOAP-Client-Instanz anlegen
  aSOAP # C16_SysSOAP:Init(aURL, 'http://tempuri.org/',0, 0, 0,(gUsername<>'ST'));
  if (aSoap<0) then begin
    aErr # 'service not available at location: ' + StrChar(10)+ aURL;
    RETURN -1;
  end;

  // Anfragekörper ermitteln
  aSOAPBody # aSOAP->C16_SysSOAP:RqsBody();
  if (aSOAPBody<0) then begin
    C16_SysSOAP:Term(aSOAP);
    aErr # 'SOAP-Body error!';
    RETURN -2;
  end;

  // Parameter hinzufügen
  aSOAPBody->C16_SysSOAP:ValueAddString('aSessionId', '00000000-0000-0000-0000-000000000000');

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Version(
  aURL            : alpha(1000)) : alpha;
local begin
  vSOAP           : int;
  vSOAPBody       : int;
  vSOAPEle        : int;
  vErg            : int;
  vErr            : alpha(1000);
  vA,vB,vC        : alpha(1000);
  vI              : int;
  vURL            : Alpha(1000);
  vMem            : int;
  vDB             : alpha;
end;
begin
  if (Set.SQL.PrintSrvURL='') then RETURN '';

  if (cMussCore) then gNetServerTyp # 2;

  if (gNetServerTyp=0) then begin
    vA # StrCnv(Set.SQL.PrintSrvURL,_StrUpper);
    if (StrFind(vA,'/API/',1)>0) then gNetServertyp # 2   // NetCore
    else gNetServertyp # 1;                               // NetFramework
  end;


  if (gNetServerTyp=2) then begin
    
    // ST 2022-05-20 Core Umstellung:
    gNetServerUrl # ''; // Serverurl muss erst geklärt werden, hier steht ansonsten schon Müll drin
    
    vA # Lib_HTTP.Core:Version();
    if (vA<c_MinVersionCore) then begin
      if (vA='') then begin
        vA # '[KEIN PRINTSERVER GEFUNDEN]' + StrChar(10)+gNetServerUrl;
        gNetServerTyp # -1;
      end;
      vErr # 'Version muss '+c_MinVersionCore+' sein, ist aber '+vA;
    end;
    GV.Alpha.30 # '';
    if (vErr='') then begin
      vErr # 'OK';
      GV.Alpha.30 # vA;
    end;
    RETURN (vErr);
  end;  // CORE


  // Server schon geklärt?
  if (gNetServerUrl<>'') then begin
    aUrl  # gNetServerUrl;
  end;
//debugx(aUrl+' gUrl:'+gNetServerUrl);
  // Erst LOCAL dann SERVER...
  if (aUrl='AUTO') or (aUrl='') then begin
    if (cDarfLokal) then begin
      vErr # Version(LocalURL(var gNetServerPort));
      if (vErr='OK') then begin
        gNetServerUrl   # LocalURL(var gNetServerPort);
      end;
    end;
    if (vErr<>'OK') and (cKannServer) then begin
      vErr # Version(ServerURL(var gNetServerPort));
      if (vErr='OK') then begin
        gNetServerUrl   # ServerURL(var gNetServerPort);
      end;
    end;
//debugx('SET gUrl:'+gNetServerUrl);
    RETURN vErr;
  end;


  if (BaseInit(var aUrl, 'REPORT', var vSOAP, var vSOAPBody, var vErr)<0) then
    RETURN vErr;

  // Parameter hinzufügen
  vSOAPBody->C16_SysSOAP:ValueAddString('text', 'v');

  // Anfrage versenden und Antwort empfangen
  vErg # vSOAP->C16_SysSOAP:Request('Version','"http://tempuri.org/IReportService/Version"');
  if (vErg<0) then vErr # 'SOAP-Error '+aint(__LINE__) + ' keine Antwort von ' + aUrl;

  if (vErr='') then begin
    // Antwortkörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RspBody();

    vSOAPBody->C16_SysSOAP:ValueGetString('VersionResult', var vA);
    // OK??

    // Fehler ermitteln
    vErg # ErrGet();
    // Kein Fehler aufgetreten
    if (vErg <> _ErrOK) then vErr # 'error'
    else begin
//      vI # cnvIa(vA);
//      if (vI<c_MinVersion) then vErr # 'wrong version';
  //    vErr # vA;
      vB # Str_Token(vA,'|',1);
      if (vB='') then vB # vA;
      if (vB<c_MinVersion) then begin
        if (vB='') then begin
          vA # '[KEIN PRINTSERVER GEFUNDEN]';
          gNetServerTyp # -1;
        end;
        vErr # 'Version muss '+c_MinVersion+' sein, ist aber '+vB;
      end;
      
      if (vErr='') then begin
        vB # StrCnv(Str_Token(vA,'|',2),_strUpper);
        vDB # Set.SQL.Database;
        if (isTestsystem) then
          vDB # vDB + '_TESTSYSTEM';
        if (vB<>StrCnv(vDB,_StrUpper)) then begin
          vErr # 'PrintServer hat falsche SQL:'+vB;
        end;
      end;
    end;
  end;

  // Terminierung: SOAP-Client-Instanz freigeben
  vSOAP->C16_SysSOAP:Term();

  GV.Alpha.30 # '';
  if (vErr='') then begin
    vErr # 'OK';
    GV.Alpha.30 # vA;
  end;
  RETURN (vErr);
end;


//========================================================================
//========================================================================
sub Active(
  aURL              : alpha;
  opt aTimeout : int) : alpha;
local begin
  vSOAP           : int;
  vURL            : Alpha(1000);
  vErr            : alpha(1000);
  vErg            : int;
  vMem            : int;
end;
begin

  if (Set.SQL.PrintSrvURL='') then RETURN '';

  if (gNetServerTyp<0) then RETURN '';

  if (gNetServerTyp=2) then begin
    RETURN Lib_HTTP.Core:Ping();
  end;  // CORE

  // Server schon geklärt?
  if (gNetServerUrl<>'') then begin
    aUrl  # gNetServerUrl;
  end;
  
  // Erst LOCAL dann SERVER...
  if (aUrl='AUTO') or (aUrl='') then begin
    if (cDarfLokal) then begin
      vErr # Active(LocalURL(var gNetServerPort), aTimeout);
      if (vErr='OK') then begin
        gNetServerUrl   # LocalURL(var gNetServerPort);
      end;
    end;
    if (vErr<>'OK') and (cKannServer) then begin
      vErr # Active(ServerURL(var gNetServerPort), aTimeout);
      if (vErr='OK') then begin
        gNetServerUrl   # ServerURL(var gNetServerPort);
      end;
//      vUrl # ServerURL(var gNetServerPort)
//      if (vUrl<>'') then begin
//        vErr # Active(vUrl,aTimeout);
//        if (vErr<>'OK') then begin
//          vErr # Version(vUrl);
//        end;
//      end;
    end;
    RETURN vErr;
  end;


  vUrl # aUrl + 'REPORT';

  // Initialisierung: SOAP-Client-Instanz anlegen
  vSOAP # C16_SysSOAP:Init(vURL,    'http://tempuri.org/',0,0,aTimeout, (gUsername<>'ST'));
  if (vSoap<0) then RETURN 'service not available at location: ' + StrChar(10)+ vURL;

  // Terminierung: SOAP-Client-Instanz freigeben
  if (vSOAP > 0) then
    vSOAP->C16_SysSOAP:Term();

  RETURN 'OK';
end;


//========================================================================
//========================================================================
sub PlaneRsoResJIT(
  aResNr          : int;
  aGrenze         : CalTime;
  aAntwort        : alpha;
  var aRequestID  : bigint;
  opt aUsername   : alpha) : alpha;
local begin
  Erx             : int;
  vSOAP           : int;
  vSOAPBody       : int;
  vSOAPEle        : int;
  vErg            : int;
  vErr            : alpha(1000);
  vA,vB,vC        : alpha(1000);
  vI              : int;
  vURL            : Alpha(1000);
  vCbID           : int;
  vRequestID      : bigint;
end;
begin

  if (aUsername='') then aUsername # gUsername;

  if (gNetServerUrl='') then RETURN 'kein Server';

  // Daten holen
  Rso.R.Reservierungnr # aResNr;
  Erx # RecRead(170,1,0);
  if (erx>_rLockeD) then RETURN 'kein Satz';

  // Erst alle Änderungen abwarten...
  if (Lib_SQL:WaitForSyncDatei(170)=false) then RETURN 'SYNC-Problem';
//debugx('992:'+aint(recinfo(992,_recCOunt)));

  if (gNetServerTyp=2) then begin
    RETURN Lib_HTTP.Core:PlaneRsoRes(aResNr, aGrenze, aAntwort, var aRequestID, aUsername, 'JIT');
  end;


  vURL # gNetServerUrl;
  if (BaseInit(var vUrl, 'STAHLCONTROL/RESSOURCE', var vSOAP, var vSOAPBody, var vErr)<0) then
    RETURN vErr;

  if (aRequestID=0) then
    vRequestID # Lib_Notifier:NewRequestID()

  // Parameter hinzufügen
  vSOAPBody->C16_SysSOAP:ValueAddInt('aResNr', aResNr);
  vSOAPBody->C16_SysSOAP:ValueAddDatetime('aGrenze', aGrenze);
  vSOAPBody->C16_SysSOAP:ValueAddLong('aCallbackID', aRequestID);
  vSOAPBody->C16_SysSOAP:ValueAddString('aMsgUser', aUsername);
  vSOAPBody->C16_SysSOAP:ValueAddString('aAntwortcode', aAntwort);

  // Anfrage versenden und Antwort empfangen

// -10101 / - 10201 = kein Dienst
// -2 = timeout??
  vErg # vSOAP->C16_SysSOAP:Request('PlaneReservierungJIT_C16Callback','"http://tempuri.org/IRessource/PlaneReservierungJIT_C16Callback"');
  if (vErg<0) then vErr # 'SOAP-Error '+aint(__LINE__);

  if (vErr='') then begin
    // Antwortkörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RspBody();
    vSOAPBody->C16_SysSOAP:ValueGetString('PlaneReservierungJIT_C16CallbackResult', var vA);
    // OK??

    // Fehler ermitteln
    vErg # ErrGet();
    // Kein Fehler aufgetreten
    if (vErg <> _ErrOK) then begin
      vErr # 'error';
    end
    else begin
      vErr # vA;
    end;
  end;

  // Terminierung: SOAP-Client-Instanz freigeben
  vSOAP->C16_SysSOAP:Term();

  if (vErr='OK') and (aRequestID>0) then
    Lib_Notifier:NewInfo(aUsername, 'Planung JIT '+"Rso.R.Trägertyp"+' '+aint("Rso.R.Trägernummer1")+'/'+aint("Rso.R.Trägernummer2"),'Berechnung läuft...', aRequestID);

  RETURN (vErr);
end;


//========================================================================
//========================================================================
sub PlaneRsoResASAP(
  aURL            : alpha(1000);
  aResNr          : int;
  aGrenze         : caltime;
  aAntwort        : alpha;
  var aRequestID  : bigint;
  opt aUsername   : alpha) : alpha;
local begin
  Erx             : int;
  vSOAP           : int;
  vSOAPBody       : int;
  vSOAPEle        : int;
  vErg            : int;
  vErr            : alpha(1000);
  vA,vB,vC        : alpha(1000);
  vI              : int;
  vURL            : Alpha(1000);
  vCbID           : int;
  vCT             : caltime;
end;
begin

  if (aUsername='') then aUsername # gUsername;

  if (gNetServerUrl='') then RETURN 'kein Server';

  // Daten holen
  Rso.R.Reservierungnr # aResNr;
  Erx # RecRead(170,1,0);
  if (erx>_rLockeD) then RETURN 'kein Satz';

  // Erst alle Änderungne abwarten...
  if (Lib_SQL:WaitForSyncDatei(170)=false) then RETURN 'SYNC-Problem';
//debugx('992:'+aint(recinfo(992,_recCOunt)));

  if (BaseInit(var aUrl, 'STAHLCONTROL/RESSOURCE', var vSOAP, var vSOAPBody, var vErr)<0) then
    RETURN vErr;

  if (aRequestID=0) then
    aRequestID # Lib_Notifier:NewRequestID();

 
  // Parameter hinzufügen
//debugx('ASAP res='+aint(aResNr));
  vSOAPBody->C16_SysSOAP:ValueAddInt('aResNr', aResNr);
  vSOAPBody->C16_SysSOAP:ValueAddDatetime('aGrenze', aGrenze);
  vSOAPBody->C16_SysSOAP:ValueAddLong('aCallbackID', aRequestID);
  vSOAPBody->C16_SysSOAP:ValueAddString('aMsgUser', aUsername);
  vSOAPBody->C16_SysSOAP:ValueAddString('aAntwortcode', aAntwort);

  // Anfrage versenden und Antwort empfangen

// -10101 / - 10201 = kein Dienst
// -2 = timeout??
  vErg # vSOAP->C16_SysSOAP:Request('PlaneReservierungASAP_C16Callback','"http://tempuri.org/IRessource/PlaneReservierungASAP_C16Callback"');
  if (vErg<0) then vErr # 'SOAP-Error '+aint(__LINE__);

  if (vErr='') then begin
    // Antwortkörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RspBody();
    vSOAPBody->C16_SysSOAP:ValueGetString('PlaneReservierungASAP_C16CallbackResult', var vA);
    // OK??

    // Fehler ermitteln
    vErg # ErrGet();
    // Kein Fehler aufgetreten
    if (vErg <> _ErrOK) then begin
      vErr # 'error';
    end
    else begin
      vErr # vA;
    end;
  end;

  // Terminierung: SOAP-Client-Instanz freigeben
  vSOAP->C16_SysSOAP:Term();

  if (vErr='OK') and (aRequestID>0) then
    Lib_Notifier:NewInfo(aUsername, 'Planung ASAP '+"Rso.R.Trägertyp"+' '+aint("Rso.R.Trägernummer1")+'/'+aint("Rso.R.Trägernummer2"),'Berechnung läuft...', aRequestID);

  RETURN (vErr);
end;


//========================================================================
//
//
//========================================================================
sub Test(
  aURL            : alpha(1000);
  aName           : alpha) : alpha;
local begin
  vSOAP           : int;
  vSOAPBody       : int;
  vSOAPEle        : int;
  vErg            : int;
  vErr            : alpha(1000);
  vA,vB,vC        : alpha(1000);
  vI              : int;
  vURL            : Alpha(1000);
end;
begin

  if (gNetServerUrl='') then RETURN 'kein Server';

  if (BaseInit(var aUrl, 'REPORT', var vSOAP, var vSOAPBody, var vErr)<0) then
    RETURN vErr;

  // Parameter hinzufügen
  vSOAPBody->C16_SysSOAP:ValueAddString('text', aName);

  // Anfrage versenden und Antwort empfangen
  vErg # vSOAP->C16_SysSOAP:Request('TestCall','"http://tempuri.org/IReportService/TestCall"');
  if (vErg<0) then vErr # 'SOAP-Error '+aint(__LINE__);

  if (vErr='') then begin
    // Antwortkörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RspBody();

    vSOAPBody->C16_SysSOAP:ValueGetString('TestCallResult', var vA);
    // OK??

    // Fehler ermitteln
    vErg # ErrGet();
    // Kein Fehler aufgetreten
    if (vErg <> _ErrOK) then vErr # 'error'
    else begin
      vErr # vA;
    end;
  end;

  // Terminierung: SOAP-Client-Instanz freigeben
  vSOAP->C16_SysSOAP:Term();

  RETURN (vErr);
end;


//========================================================================
//========================================================================
sub _OpenCoreClientSocket(
  var aErr      : alpha;
  opt aNoStart  : logic): int;
local begin
  vI    : int;
  vA    : alpha(500);
  vTry  : int;
  erx   : int;
end;
begin
  // Verbindung aufbauen
  vI # SckConnect('localhost', cCoreClientPort);
  if (vI<=0) then begin
    if (aNoStart) then RETURN 0;

    if (Lib_SFX:Check_AFX('DotNet.BC.GraphClient.Path')) then begin
      vA # Call(AFX.Prozedur);
    end;
    if (vA='') then begin
      vA # lib_Strings:Strings_Win2Dos(SysGetEnv('BC.ClientPath'));
    end;
    if (vA='') then begin
     aErr # 'BC-Client nicht installiert!';
      RETURN -1;
    end;

//if (gusername<>'xxxAH') then debug('starte exe');
    erx # SysExecute(vA,'-trace -c16Port:'+aint(gRemotePort),0);
//if (gusername<>'xxxAH') then debug('done');
    Winsleep(2000);
    errset(0);

    REPEAT
      inc(vTry);
      Winsleep(250)
      // Nochmal verbinden...
      vI # SckConnect('localhost', cCoreClientPort, 0, 250);
//if (gusername<>'xxxAH') then debug(aint(vTry)+' : '+aint(vI));
    UNTIL (vI>0) or (vTry>=20);    // Max 10 Sekunden
    errset(0);
    
    if (vI<=0) then begin
      aErr # 'BC-Client nicht erreichbar!';
      RETURN -1;
    end
  end;

  winsleep(50);
  errset(0);
  
  RETURN vI;
end;


//========================================================================
//
//
//========================================================================
sub Remote_Gantt(
  aResGrp         : int;
  aResNr          : int;
  aDatum          : date) : alpha;
local begin
  vSOAP           : int;
  vSOAPBody       : int;
  vSOAPEle        : int;
  vErg            : int;
  vErr            : alpha(1000);
  vA,vB,vC        : alpha(1000);
  vI              : int;
  vURL            : Alpha(1000);
end;
begin

//  if (gNetServerTyp=2) then begin
    vI # _OpenCoreClientSocket(var vA);
    if (vI<=0) then RETURN vA;
    vA # 'ShowRessourceGantt|'+aint(aResGrp)+'|'+aint(aResNr)+'|'+C16_SysSoap:DateWrite(aDatum)+'|'+StrChar(4);
    vI->SckWrite(0,vA);
    vI->sckclose();
    RETURN '';
//  end;


  vURL # 'HTTP://LOCALHOST:'+aint(cCoreClientPort)+'/BC/';
  // Verbinden...?
  vI # BaseInit(var vUrl, '', var vSOAP, var vSOAPBody, var vErr);
  if (vI=-1) then begin
    vErr # '';
    vA # lib_Strings:Strings_Win2Dos(SysGetEnv('BC.ClientPath'));
    if (vA='') then
      RETURN 'BC-Client nicht installiert!';
    SysExecute(vA,'',0);
    Winsleep(2000);
    // Nochmal verbinden...
    vI # BaseInit(var vUrl, '', var vSOAP, var vSOAPBody, var vErr);
  end;
  if (vI<0) then
    RETURN vErr;


  // Parameter hinzufügen
  vSOAPBody->C16_SysSOAP:ValueAddInt('aRessourcenGruppe', aResGrp);
  vSOAPBody->C16_SysSOAP:ValueAddInt('aRessourcenNr', aResNr);
  vSOAPBody->C16_SysSOAP:ValueAddDate('aStartDatum', aDatum);
//  vSOAPBody->C16_SysSOAP:ValueAddInt('aTage', 10);

  // Anfrage versenden und Antwort empfangen
  vErg # vSOAP->C16_SysSOAP:Request('ShowRessourceGantt','"http://tempuri.org/IRemoteControlService/ShowRessourceGantt"');
  if (vErg<0) then vErr # 'SOAP-Error '+aint(vErg)+' @'+aint(__LINE__);

  if (vErr='') then begin
    // Antwortkörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RspBody();

    vSOAPBody->C16_SysSOAP:ValueGetString('ShowRessourceGanttResult', var vA);
    // OK??

    // Fehler ermitteln
    vErg # ErrGet();
    // Kein Fehler aufgetreten
    if (vErg <> _ErrOK) then vErr # 'error'
    else begin
      vErr # vA;
    end;
  end;

  // Terminierung: SOAP-Client-Instanz freigeben
  vSOAP->C16_SysSOAP:Term();

  RETURN (vErr);
end;


//========================================================================
//
//
//========================================================================
sub Remote_RsoKalender(
  aResGrp         : int
  ) : alpha;
local begin
  vSOAP           : int;
  vSOAPBody       : int;
  vSOAPEle        : int;
  vErg            : int;
  vErr            : alpha(1000);
  vA,vB,vC        : alpha(1000);
  vI              : int;
  vURL            : Alpha(1000);
end;
begin

//  if (gNetServerTyp=2) then begin
    vI # _OpenCoreClientSocket(var vA);
    if (vI<=0) then RETURN vA;
    vA # 'ShowRessourceKalender|'+aint(aResGrp)+'|'+StrChar(4);
    vI->SckWrite(0,vA);
    vI->sckclose();
    RETURN '';
//  end;

  
  vURL # 'HTTP://LOCALHOST:'+aint(cCoreClientPort)+'+/BC/';

  // Verbinden...?
  vI # BaseInit(var vUrl, '', var vSOAP, var vSOAPBody, var vErr);
  if (vI=-1) then begin
    vErr # '';
    vA # lib_Strings:Strings_Win2Dos(SysGetEnv('BC.ClientPath'));
    if (vA='') then
      RETURN 'BC-Client nicht installiert!';
    SysExecute(vA,'',0);
    Winsleep(2000);
    // Nochmal verbinden...
    vI # BaseInit(var vUrl, '', var vSOAP, var vSOAPBody, var vErr);
  end;
  if (vI<0) then
    RETURN vErr;


  // Parameter hinzufügen
  vSOAPBody->C16_SysSOAP:ValueAddInt('aRessourcenGruppe', aResGrp);

  // Anfrage versenden und Antwort empfangen
  vErg # vSOAP->C16_SysSOAP:Request('ShowRessourceKalender','"http://tempuri.org/IRemoteControlService/ShowRessourceKalender"');
  if (vErg<0) then vErr # 'SOAP-Error '+aint(vErg)+' @'+aint(__LINE__);

  if (vErr='') then begin
    // Antwortkörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RspBody();

    vSOAPBody->C16_SysSOAP:ValueGetString('ShowRessourceKalenderResult', var vA);
    // OK??

    // Fehler ermitteln
    vErg # ErrGet();
    // Kein Fehler aufgetreten
    if (vErg <> _ErrOK) then vErr # 'error'
    else begin
      vErr # vA;
    end;
  end;

  // Terminierung: SOAP-Client-Instanz freigeben
  vSOAP->C16_SysSOAP:Term();

  RETURN (vErr);
end;


//========================================================================
//
//
//========================================================================
sub Remote_ShowBaGraph(
  aBaNr           : int
  ) : alpha;
local begin
  vA              : alpha(1000);
  vSocket         : int;
end;
begin
  try
  begin
    ErrTryCatch(_ErrAll,y);
    vSocket # _OpenCoreClientSocket(var vA);
    if (vSocket<=0) then RETURN vA;
    vA # 'ShowBaGraph|'+aint(aBaNr)+'|'+StrChar(4);
    vSocket->SckWrite(0,vA);
    vSocket->SckRead(_SckLine, vA);
    vSocket->sckclose();
//debugx(va);
winsleep(10);
    if (vA='OK') then RETURN '';
    RETURN vA;
  end;
  ErrGet();

  RETURN '';
end;


//========================================================================
//
//========================================================================
sub Remote_Quit() : alpha;
local begin
  vA              : alpha(1000);
  vSocket         : int;
end;
begin
  try
  begin
    ErrTryCatch(_ErrAll,y);
    vSocket # _OpenCoreClientSocket(var vA, true);
    if (vSocket<=0) then begin
      RETURN vA;
    end;
    vA # 'Quit|'+StrChar(4);
    vSocket->SckWrite(0,vA);
    vSocket->SckRead(_SckLine, vA);
    vSocket->sckclose();
//debugx(va);
winsleep(10);
    if (vA='OK') then RETURN '';
    RETURN vA;
  end;
  ErrGet();

  RETURN '';
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
  aParaHandle     : handle;
  opt aURL        : alpha(1000);
  ) : alpha;
local begin
  vSOAP           : int;
  vSOAPBody       : int;
  vErg            : int;
  vErr            : alpha(1000);
  vA,vB,vC        : alpha(1000);
  vI              : int;
  vURL            : Alpha(1000);
  vSettings       : alpha(4096);
  vDepth          : int;
  vPath           : alpha(1000);
  vPort           : int;
end;
begin
//debugx('url:'+aURL+'   g:'+gNetServerUrl+'   ZielFilename:'+aOutput);
  if (gNetServerTyp=2) then begin
    RETURN Lib_HTTP.Core:StartPdf(aName, aFrxFile, aOutput, aOutputTypes, aBackgroundPic, aMark, aRecipient, aParaHandle);
  end;  // CORE

  
  // DEBUGMODE???
  if (StrCut(gTmpA,1,5)='DEBUG') then begin
    vA # StrCnv(aFrxFile,_Strupper);
    vPath # Str_Token(gTmpA,'|',2);
    if (Strcut(vPath,StrLen(vPath),1)<>'\') then vPath # vPath + '\';
    vI # StrFind(vA, '\FRX\',1);
    if (vI<>0) then begin
      vA # vPath + StrCut(vA, vI+1,1000);
    end;
    vErr # StartPdf(aName, vA, aOutput, aOutputTypes, aBackgroundPic, aMark, aRecipient, aParaHandle,aURL);
    RETURN vErr;
  end;

  
  // Erst LOCAL dann SERVER...
/****
  if (aUrl='AUTO') or (aURL='') then begin
    if (gNetServerURL=LocalURL(var vPort)) then begin
//debugx('do local...'+aFrxFile+' nach '+aOutput);
      vErr # StartPdf(aName, aFrxFile, aOutput, aOutputTypes, aBackgroundPic, aMark, aRecipient, aParaHandle, LocalURL(var vPort));
//debugx('='+vErr);
      if (vErr='OK') then RETURN vErr;
    end;
    if (vErr<>'OK') and (aOutput='') then RETURN 'OK';    // am Server gibt es keinen Designer!!!
//debugx('do server...'+aFrxFile+' nach '+aOutput);
    vErr # StartPdf(aName, aFrxFile, aOutput, aOutputTypes, aBackgroundPic, aMark, aRecipient, aParaHandle, ServerURL(var vPort));
//debugx('='+vErr);
    RETURN vErr;
  end;
***/
  if (gNetServerURL<>LocalURL(var vPort)) and (aOutput='') then RETURN 'kein Designer am Server';    // am Server gibt es keinen Designer!!!26.04.2021
  if (aUrl='AUTO') or (aURL='') then begin
    if (gNetServerURL='') then
      RETURN 'kein PrintServer erreichbar';
    RETURN StartPdf(aName, aFrxFile, aOutput, aOutputTypes, aBackgroundPic, aMark, aRecipient, aParaHandle, gNetServerURL);
  end;


  vURL # aURL;
//debugx('>>>> SERVICEAUFRUF '+vURL+' '+aOutput);
  
  //if (gNetServerUrl='') then RETURN 'kein Server';
  //vURL # gNetServerURL;

  vSettings # Lib_JSON:CreatePrintServerSettings();

//debugx('call '+vUrl);
  if (BaseInit(var vUrl, 'REPORT', var vSOAP, var vSOAPBody, var vErr)<0) then
    RETURN vErr;

  // Parameter hinzufügen

  vDepth # 5;
  if Lfm.Kuerzel = 'Rso' then vDepth # 10; // 2017-08-07 TM zum Testen

  vSOAPBody->C16_SysSOAP:ValueAddInt('LinkDepth', vDepth);
  vSOAPBody->C16_SysSOAP:ValueAddInt('eigeneAdressNummer', Set.EigeneAdressnr);
  vSOAPBody->C16_SysSOAP:ValueAddString('eigenerUser', gUsername);
  vSOAPBody->C16_SysSOAP:ValueAddString('name', aName);
  vSOAPBody->C16_SysSOAP:ValueAddString('frxFile', aFrxFile);
  vSOAPBody->C16_SysSOAP:ValueAddString('outputPath', aOutput);
  vSOAPBody->C16_SysSOAP:ValueAddString('outputTypes', aOutputtypes);   // PDF,XML,DOC
  vSOAPBody->C16_SysSOAP:ValueAddString('markPic', aBackgroundPic);
  vSOAPBody->C16_SysSOAP:ValueAddString('mark', aMark);
  vSOAPBody->C16_SysSOAP:ValueAddString('recipient', aRecipient);
  //vSOAPBody->C16_SysSOAP:ValueAddString('paraObjectString', aPara);
  vSOAPBody->C16_SysSOAP:ValueAddString('paraObjectString', 'XxX_PARA_XxX');  // XxX_PARA_XxX wird später ERSETZT

  vSOAPBody->C16_SysSOAP:ValueAddString('settingsObjectString', vSettings);

  // Anfrage versenden und Antwort empfangen
  vErg # vSOAP->C16_SysSOAP:Request('StartReportToPDF','"http://tempuri.org/IReportService/StartReportToPDF"', aParaHandle);
  if (vErg<0) then vErr # 'SOAP-Error '+aint(__LINE__);

  if (vErr='') then begin
    // Antwortkörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RspBody();

    vSOAPBody->C16_SysSOAP:ValueGetString('StartReportToPDFResult', var vA);
    // OK??

    // Element ermitteln
  //    vSOAPElement # vSOAPBody->C16_SysSOAP:ElementGet('TestCall_1Resultxx');
  //    if (vSOAPElement > 0) then begin
      // Werte ermitteln
  //      vSOAPElement->C16_SysSOAP:ValueGetString('TestCall_1Result', var vA);
  //    end;

  //debug(vA);
  //  if (vA='OK') then vA # ''
  //  else debug(vA);

    // Fehler ermitteln
    vErg # ErrGet();
    // Kein Fehler aufgetreten
    if (vErg <> _ErrOK) then vErr # 'error'
    else vErr # vA;
  end;

  // Terminierung: SOAP-Client-Instanz freigeben
  vSOAP->C16_SysSOAP:Term();

  RETURN (vErr);
end;







//========================================================================
//  sub UpdateSplash(aSplashHdl : int; aText : alpha)
//  Aktualisiert den Splashscreen für den DOkumenten Download
//========================================================================
sub UpdateSplash(aSplashHdl : int; aText : alpha)
local begin
  vHdl : int;
end
begin
  if (aSplashHdl <= 0) then
    RETURN;

  vHdl # Winsearch(aSplashHdl,'lb.printstatus');
  vHdl-> wpCaption # aText;
end;



//========================================================================
//  sub  _PollForMetaData(...)
//  Prüft ob das Dokument am Printserver verfügbar ist
//========================================================================
sub  _PollForMetaData(
  aURL              : alpha(250);
  aPrintJobId       : alpha;
  var aMetaDataJsn  : alpha;
  opt aAskForAdditionaltime : logic;
  opt aSplashHandle : int;
  ) : logic;
local begin
  vURL            : alpha(250);
  Erx             : int;
  // Soap Handling
  vSOAP           : int;
  vSOAPBody       : int;
  vSOAPErr        : alpha;
  vErg            : int;
  
  // Polling
  vPoll                 : logic;
  vMaxTries,vTry        : int;
  vFirstPollAfterTries  : int;
  vErrorCnt             : int;
  vMaxErrorCnt          : int;
  vRetryDelayFactor     : float;
 
  vSleeptime            : int;
  vSleeptimeBase        : int;
  vReadyForDownload     : logic;
end
begin
  // -------------------------------------------------------------------
  // Einstellungen
  vMaxTries             # 300;  // 300 x 100 ms = 30000 ms = 30 Sekunden auf Antwort warten
  vSleeptimeBase        # 300;  // ms
  vSleeptime            # vSleeptimeBase;
  vFirstPollAfterTries  # 5; // Erster Serverkontakt nach x Pollintervallen
  vMaxErrorCnt          # 5;
  vRetryDelayFactor     # 1.5;
  // -------------------------------------------------------------------
  
  vPoll                 # true;
  vReadyForDownload     # false;
  vErrorCnt             # 0;
  WHILE vPoll DO BEGIN
    inc(vTry);
    
    if (vErrorCnt = 0) then
      UpdateSplash(aSplashHandle, 'warte auf Dokument...' + Aint(vTry) + '/' + aInt(vMaxTries));
    else
      UpdateSplash(aSplashHandle, 'warte auf Dokument...' + CnvAI(vTry,_FmtNumNoGroup) + '/' + CnvAI(vMaxTries,_FmtNumNoGroup) + '[' +CnvAI(vErrorCnt,_FmtNumNoGroup)+ ' '+ CnvAf(CnvFi(vSleeptime)/1000.0)+']');
   
    // -------------------------------------------------------------------
    //    Nicht sofort anfangen zu pollen, da der Printserver
    //    mindestens 2 Sekunden für die Bearbeitung benötigt
    // -------------------------------------------------------------------
    if (vPoll) AND (vTry < vFirstPollAfterTries) then begin
      Winsleep(vSleeptime);
      CYCLE;
    end;

    // -------------------------------------------------------------------
    //    Fehlerhandling für mehr Fehlertoleranz bei Verbindungsabbrüchen
    //      bzw. Printserverantwort
    // -------------------------------------------------------------------
    if (vPoll) AND (vErrorCnt > 0) then begin
      
      // Max Fehleranzahl erreicht -> Ende mit Pooling
      if (vErrorCnt > vMaxErrorCnt) then begin
        Error(99,'To many connection errors');
        vPoll # false;
        CYCLE;
      end;

      // Im Fehlerfall den Intervall vergrößern um den Server mehr Antwortzeit zu geben
      vSleeptime # CnvIf(CnvFi(vSleeptime) * vRetryDelayFactor);
      Winsleep(vSleeptime);
    end;
    
    if (gNetServerTyp=2) then begin // 19.10.2020 AH
      vReadyForDownload # Lib_HTTP.Core:GetReportMetadata(aPrintJobID, var aMetaDataJsn);
      vPoll # !vReadyForDownload;
    end
    else begin
      // -------------------------------------------------------------------
      //    Sende Poll Request
      // -------------------------------------------------------------------
      vURL # aUrl;  // URL Reset
      if (BaseInit(var vURL, 'REPORT', var vSOAP, var vSOAPBody, var vSOAPErr) = 1) then begin
        vSOAPBody->C16_SysSOAP:ValueAddString('printJobId', aPrintJobId);

        // Anfrage versenden und Antwort empfangen
        vErg # vSOAP->C16_SysSOAP:Request('GetReportMetadata','"http://tempuri.org/IReportService/GetReportMetadata"');
        if (vErg=0) then begin
          vSOAPBody # vSOAP->C16_SysSOAP:RspBody();
          vSOAPBody->C16_SysSOAP:ValueGetString('GetReportMetadataResult', var aMetaDataJsn);
          vErg # ErrGet();
          // Kein Fehler aufgetreten
          if (vErg <> _ErrOK) then begin
            Error(99,'SOAP Data Error');
            vPoll # false;
          end
          else begin
            // Hat Wert? Dann Start mit Download
            vReadyForDownload # (aMetaDataJsn <> '');
            vPoll # !vReadyForDownload;
          end;
        end
        else begin
          // Fehler beim Starten des Requestes
          inc(vErrorCnt);
          CYCLE;
        end;

        // Terminierung: SOAP-Client-Instanz freigeben
        vSOAP->C16_SysSOAP:Term();
      end
      else begin
        // Fehler bei Serviceaufruf
        inc(vErrorCnt);
        CYCLE;
      end;
    end;


    // nächster Versuch?
    if (vTry > vMaxTries) and (vPoll) and (vErrorCnt = 0) then begin
    
      // ggf. Fragen, wie weiterverfahren werden soll
      if (aAskForAdditionaltime) then begin
 
        // ST 2017-06-27: Bei Listenausführung vom Jobserver nicht nachfragen
        if (gUsergroup = 'JOB-SERVER') OR (gUsergroup =*^'SOA*') then begin
          vTry # 0;
          CYCLE;
        end;

        Erx # msg(002000,'', _WinIcoWarning, _WinDialogYesNoCancel,1);
        If (Erx = _WinIdYes) then begin
          // weiter warten und wieder Fragen
          vTry # 0;
          CYCLE;
        end
        else if (Erx = _WinIdNo) then begin
          // weiter warten und nicht nochmal fragen -> danach Abbruch
          aAskForAdditionaltime # false;
          vTry # 0;
          CYCLE;
        end
        else begin
          // Abbruch -> nichts machen, direkt abbrechen
        end;
      end;

      // Ende
      vPoll # false;
      BREAK;
    end;

    if (vPoll) then
      winsleep(vSleeptime);
  END;
  
  if (vReadyForDownload ) then
    Lib_Error:_Flush();

  RETURN (ErrList = 0);
end;


//========================================================================
//  sub _DownloadFile(...) : logic;
//   Lädt ein Dokument für die angegbene JobID herunter
//========================================================================
sub _DownloadFile(
  aURL        : alpha(250);
  aPrintJobId : alpha;
  aPath       : alpha(4096);
  aExtention  : alpha;
  var aSOAPDocMetaData : alpha;
  var aFax    : alpha;
  var aEma    : alpha;
  var aLang   : alpha;
  var aResultJson : alpha;  // <-- wird nicht mehr genutzt
  opt aSplashHandle : int;
  ) : logic;
local begin
  vURL            : alpha(250);
  
  // Soap Handling
  vSOAP           : int;
  vSOAPBody       : int;
  vSOAPErr        : alpha;
  vErg            : int;

  // Metadata
  vDataSize         : int;
  vCteJsnMeta       : int;
  vCteJsnMetaItem   : int;
  
  // Download
  vMemObjSoapResult : handle;
  vMemObjB64kodiert : handle;
  vMemObjBinaer     : handle;
  vFile             : handle;
  vFileOk           : logic;
   
  vReadyForDelete   : logic;
end
begin

  if (ErrList <> 0) then
    RETURN false;

  // Metadaten extrahieren
  vCteJsnMeta # Lib_Json:JsonListToCteList(aSOAPDocMetaData);
  if (vCteJsnMeta > 0) then begin
    FOR   vCteJsnMetaItem # vCteJsnMeta->CteRead(_CteFirst);
    LOOP  vCteJsnMetaItem # vCteJsnMeta->CteRead(_CteNext,vCteJsnMetaItem);
    WHILE vCteJsnMetaItem <> 0 DO BEGIN
//debug(vCteJsnMetaItem->spName);
      case vCteJsnMetaItem->spName of
        'Fax'         : aFax              #  vCteJsnMetaItem->spCustom;
        'Email'       : aEma              #  vCteJsnMetaItem->spCustom;
        'Language'    : aLang             #  vCteJsnMetaItem->spCustom;
        'Size'        : vDataSize         # CnvIa(vCteJsnMetaItem->spCustom);
        'ResultJson'  : gBCPS_ResultJson  #  vCteJsnMetaItem->spCustom;
      end;
    END;
    vCteJsnMeta->CteClose();
    
    // Im Fehlerfall sind die Jsondaten ggf. "null"
    if (aFax = 'null')  then aFax   # '';
    if (aEma = 'null')  then aEma   # '';
    if (aLang = 'null') then aLang  # '';
  end;
  
  UpdateSplash(aSplashHandle, 'Empfange Dokument...' + Anum(CnvFi(vDataSize)/1024.0/1024.0,2) + ' MB');
  vURL # aUrl;  // URL Reset

    
  // SOAP XML Strukturen aus Antwort enfernen und in neuen Base64 Codierten Memstream kopieren
  vMemObjB64kodiert # MemAllocate(_MemAutoSize);
  vMemObjB64kodiert->spLen # 0;
  vMemObjB64kodiert->spCharset # _CharSetWCP_1252;
    
  if (gNetServerTyp=2) then begin // 19.10.2020 AH
    Lib_HTTP.Core:GetReportPDF(aPrintJobID, var vMemObjB64kodiert);
  end // .netCore
  else begin
    if (BaseInit(var vURL, 'REPORT', var vSOAP, var vSOAPBody, var vSOAPErr) = 1) then begin
      vSOAPBody->C16_SysSOAP:ValueAddString('printJobId', aPrintJobId);
      // Anfrage versenden und Antwort empfangen
      vMemObjSoapResult # MemAllocate(_MemAutoSize);
      vMemObjSoapResult->spLen # 0;
            
      vErg # vSOAP->C16_SysSOAP:Request(
            'GetReportPDF',
            '"http://tempuri.org/IReportService/GetReportPDF"',
            0,   // aParaHandle --> TODO für Später???
            0,   // aObjRqsHeader     Header-Versanddaten (CteNode- oder Mem-Objekt)
            0,   // opt aObjRqsBody   Body-Versanddaten (CteNode- oder Mem-Objekt)
            0,   // opt aObjRspHeader Header-Empfangsdaten (CteNode- oder Mem-Objekt)
            vMemObjSoapResult); // Body-Empfangsdaten (CteNode- oder Mem-Objekt)

      if (vErg=0) then begin
        vSOAPBody # vSOAP->C16_SysSOAP:RspBody();
        vErg # ErrGet();
        if (vErg <> _ErrOK) then begin
          Error(99,'SOAP Error: GetReport');
        end
        else begin
          if (vDataSize <> 0) and (vMemObjSoapResult->spSize > vDataSize) then begin
            vMemObjSoapResult->MemCopy(89,vDataSize,1,vMemObjB64kodiert); // 88 Bytes sind immer "Header/XML Overhead"
          end;
        end;
      end;  // vErg=0
      // Terminierung: SOAP-Client-Instanz freigeben
      vSOAP->C16_SysSOAP:Term();
    end;    // Baseinit
  end;      // .netFramework
  
  // Dekodieren...
  if (vErg=0) then begin
    // von Base64 zurück konvertieren
    vMemObjBinaer # MemAllocate(_MemAutoSize);
    vMemObjB64kodiert->MemCnv(vMemObjBinaer,_MemDecBase64);

    // File schreiben
    vFile  # FsiOpen(aPath+'.'+aExtention, _FsiCreate | _FsiStdWrite);
    if (vFile > 0) then begin
      FsiWriteMem(vFile,vMemObjBinaer,1,vMemObjBinaer->spLen);
      vFileOk # (vFile->FsiSize() > 10);
      FSIClose(vFile);
      
      // Alles IO bis hier, dann am Server Löschen
      vReadyForDelete # true;
    end
    else begin
      vErg # 1;
      Error(99,'ODBC-Error '+Aint(__LINE__)+': Datei "'+aPath+'.'+aExtention+'"konnte nicht geschrieben werden.');
    end;
  end;
  
  // Aufräumen.........................
  if (vMemObjB64kodiert> 0) then
    vMemObjB64kodiert->MemFree();

  if (vMemObjBinaer > 0) then
    vMemObjBinaer->MemFree();

  if (vMemObjSoapResult > 0) then
    vMemObjSoapResult->MemFree();
    
/************
  if (BaseInit(var vURL, 'REPORT', var vSOAP, var vSOAPBody, var vSOAPErr) = 1) then begin
    vSOAPBody->C16_SysSOAP:ValueAddString('printJobId', aPrintJobId);

    // Anfrage versenden und Antwort empfangen
    vMemObjSoapResult # MemAllocate(_MemAutoSize);
    vMemObjSoapResult->spLen # 0;
          
    vErg # vSOAP->C16_SysSOAP:Request(
          'GetReportPDF',
          '"http://tempuri.org/IReportService/GetReportPDF"',
          0,   // aParaHandle --> TODO für Später???
          0,   // aObjRqsHeader     Header-Versanddaten (CteNode- oder Mem-Objekt)
          0,   // opt aObjRqsBody   Body-Versanddaten (CteNode- oder Mem-Objekt)
          0,   // opt aObjRspHeader Header-Empfangsdaten (CteNode- oder Mem-Objekt)
          vMemObjSoapResult); // Body-Empfangsdaten (CteNode- oder Mem-Objekt)

    if (vErg=0) then begin
      vSOAPBody # vSOAP->C16_SysSOAP:RspBody();
      vErg # ErrGet();
      if (vErg <> _ErrOK) then begin
        Error(99,'SOAP Error: GetReport');
      end
      else begin
        // Kein Fehler aufgetreten
        UpdateSplash(aSplashHandle, 'schreibe Dokument...');
      
        // SOAP XML Strukturen aus Antwort enfernen und in neuen Base64 Codierten Memstream kopieren
        vMemObjB64kodiert # MemAllocate(_MemAutoSize);
        vMemObjB64kodiert->spLen # 0;
        vMemObjB64kodiert->spCharset # _CharSetWCP_1252;
        
        if (vDataSize <> 0) and (vMemObjSoapResult->spSize > vDataSize) then begin
          vMemObjSoapResult->MemCopy(89,vDataSize,1,vMemObjB64kodiert); // 88 Bytes sind immer "Header/XML Overhead"

          // von Base64 zurück konvertieren
          vMemObjBinaer # MemAllocate(_MemAutoSize);
          vMemObjB64kodiert->MemCnv(vMemObjBinaer,_MemDecBase64);
      
          // File schreiben
          vFile  # FsiOpen(aPath+'.'+aExtention, _FsiCreate | _FsiStdWrite);
          if (vFile > 0) then begin
            FsiWriteMem(vFile,vMemObjBinaer,1,vMemObjBinaer->spLen);
            vFileOk # (vFile->FsiSize() > 10);
            FSIClose(vFile);
            
            // Alles IO bis hier, dann am Server Löschen
            vReadyForDelete # true;
          end
          else begin
            Error(99,'ODBC-Error '+Aint(__LINE__)+': Datei "'+aPath+'.'+aExtention+'"konnte nicht geschrieben werden.');
          end;
        
        end else begin
          Error(99,'SOAP Error: GetReport lieferte keine korrekte Datei');
        end;

        // Aufräumarbeiten
        if (vMemObjSoapResult > 0) then
          vMemObjSoapResult->MemFree();
          
        if (vMemObjB64kodiert> 0) then
          vMemObjB64kodiert->MemFree();

        if (vMemObjBinaer > 0) then
          vMemObjBinaer->MemFree();
      end;
      
    end
    else begin
      // Fehler beim Starteen des Requestes
      Error(99,'SOAP-Error Downloadservice Failed');
    end;

    // Terminierung: SOAP-Client-Instanz freigeben
    vSOAP->C16_SysSOAP:Term();
  end;
******/

  if (vReadyForDelete) then
    Lib_Error:_Flush();

  RETURN (ErrList = 0);
end;


//========================================================================
//  sub _RemoteDelete(...) : logic;
//   Sendet den Löschbefehl für ein Dokument an den PrintServer
//========================================================================
sub _RemoteDelete(
  aURL : alpha(250);
  aPrintJobId : alpha;
  opt aSplashHandle : int;
  ) : logic;
local begin
  vURL            : alpha(250);
  vSOAP           : int;
  vSOAPBody       : int;
  vSOAPErr        : alpha;
  vErg            : int;
  vOK             : logic;
end
begin
  if (ErrList <> 0) then
    RETURN false;
    
  UpdateSplash(aSplashHandle, 'Sende Bestätigung...');

  if (gNetServerTyp=2) then begin // 19.10.2020 AH
    Lib_HTTP.Core:ReportAcknowledge(aPrintJobID);
    RETURN true;
  end;
      
  vURL # aUrl;  // URL Reset
  if (BaseInit(var vURL, 'REPORT', var vSOAP, var vSOAPBody, var vSOAPErr) = 1) then begin
    vSOAPBody->C16_SysSOAP:ValueAddString('printJobId', aPrintJobId);

    // Anfrage versenden und Antwort empfangen
    vErg # vSOAP->C16_SysSOAP:Request('ReportAcknowledge','"http://tempuri.org/IReportService/ReportAcknowledge"');
    if (vErg=0) then begin
      // OK
      vOK # true;
    end else begin
      // Fehler beim Starteen des Requestes
      Error(99,'SOAP-Error ReportAcknowledge');
    end;

    // Terminierung: SOAP-Client-Instanz freigeben
    vSOAP->C16_SysSOAP:Term();
   
  end
  else begin
    // Fehler bei Serviceaufruf
    Error(99,vSOAPErr);
  end;

  RETURN vOK AND (ErrList = 0);
end;



//========================================================================
//  sub GetTempDok(...)
//  Lädt ein Dokument vom Server
//========================================================================
sub GetTempDok(
  aPrintJobId : alpha;
  aPath       : alpha(4096);
  aExtention  : alpha;
  var aFax    : alpha;
  var aEma    : alpha;
  var aLang   : alpha;
  var aResultJson : alpha;
  opt aAskForAdditionaltime : logic;
  opt aSplashHandle : int;
  ) : logic;
local begin
  vOK               : logic;
  vDocMetaData      : alpha(4000);
  vReadyForDownload : logic;
  vReadyForDelete   : logic;
  vFileOK           : logic;
  vErrFlush         : alpha(4000);
end;
begin

  if (gNetServerUrl='') then RETURN false;

  // Silent Servercheck
  Lib_Error:OutputToText(var vErrFLush);
  if (Active(gNetServerUrl) <> 'OK') then
    RETURN false;

  // -------------------------------------------------------------------
  //    1. Metaservice Pollen bis Dokuemnt fertig geschrieben
  vReadyForDownload # _PollForMetaData(gNetServerURL,aPrintJobId, var vDocMetaData, aAskForAdditionaltime, aSplashHandle);

  // -------------------------------------------------------------------
  //    2. Download starten
  if (vReadyForDownload) then begin
    vReadyForDelete # _DownloadFile(gNetServerURL,aPrintJobId,aPath, aExtention,
                          var vDocMetaData,var aFax, var aEma, var aLang, var aResultJson, aSplashHandle);
  end;

  // -------------------------------------------------------------------
  //    3. Download fertig und ok, dann Daten auf Server löschen und ok
  if (vReadyForDelete) then begin
    vFileOk # _RemoteDelete(gNetServerURL,aPrintJobId,aSplashHandle);
  end;
    
  if ((ErrList=0) AND (vFileOk)) then begin
    UpdateSplash(aSplashHandle, 'Anzeige...');
    RETURN true;
  end
  else begin
    UpdateSplash(aSplashHandle, 'Fehler!!!');
    RETURN false;
  end;

end;


//========================================================================
sub Remote_Lockapp() : alpha;
local begin
  vA    : alpha(1000);
  vSock : int;
end;
begin
  vSock # _OpenCoreClientSocket(var vA);
  if (vSock<=0) then RETURN vA;
  vA # 'LockApp'+StrChar(4);
  vSock->SckWrite(0,vA);
  vSock->sckclose();
  RETURN '';
end;


//========================================================================
sub Remote_Unlockapp(aError : alpha) : alpha;
local begin
  vA    : alpha(1000);
  vSock : int;
end;
begin
  vSock # _OpenCoreClientSocket(var vA);
  if (vSock<=0) then RETURN vA;
  vA # 'UnlockApp|'+aError+StrChar(4);
  vSock->SckWrite(0,vA);
  vSock->sckclose();
  RETURN '';
end;

//========================================================================