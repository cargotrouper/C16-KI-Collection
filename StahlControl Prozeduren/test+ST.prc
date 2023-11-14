@A+
//===== Business-Control =================================================
//
//  Prozedur
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_global
@I:Def_Aktionen
@I:Struct_PartSel
@I:Def_Kontakte
@I:Lib_Json

define begin
  cSatzEnde   : Strchar(13)+Strchar(10)
  cTrans      : '"'
  Write(a)    : begin vOut # Lib_Strings:Strings_Dos2Win(a,n);  FsiWrite(aFile,vOut); end
end;

local begin
  gX  : int[5];
  gA  : alpha[5]
end;


//========================================================================
//  sub DownloadFile( aURI : alpha(512);  aDestFile : alpha;): int;
//    Lädt eine Datei anhand einer URL und einem Pfad herunter.
//
//    Kopie aus Beispiel aus der C16 Hilfe
//========================================================================
sub DownloadResponseBody(
  aHost     : alpha(512);
  aURI      : alpha(4096);
  aDestFile : alpha;
  opt aPort : int;): int;
local begin
  tHost               : alpha(128);     // Hostname
  tPath               : alpha(4096);     // Path
  tPos                : int;
  tError              : int;            // Errorcode

  tSck                : handle;         // Socket
  tReq                : handle;         // Request-Object
  tRsp                : handle;         // Response-Object
  tLst                : handle;         // HTTP-Header-List
  tFsi                : handle;         // File

  vHTTPS              : logic;
end
begin



  if (!(aHost =* 'http://*')) AND (!(aHost =* 'https://*'))  then
    return(_ErrData);

  vHTTPS  # (aHost =* 'https://*');

//  'https://localhost:44371/api/SysUser/Ping/?....'

  if (aPort=0) then aPort # 80;

  tHost # aHost;
  if (vHTTPS) then
    tHost # Lib_Strings:Strings_ReplaceAll(tHost,'https://','');
  else
    tHost # Lib_Strings:Strings_ReplaceAll(tHost,'http://','');
  
  tPath # aUri;

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
debugx('tRsp->spProtocol:'       + tRsp->spProtocol);
debugx('tRsp->spStatusCode:'     + tRsp->spStatusCode);
debugx('tRsp->spContentLength:'  + Aint(tRsp->spContentLength));
debugx('tRsp->spHttpHeader:'     + Aint(tRsp->spHttpHeader));
    if (CnvIa(tRsp->spStatusCode) = 200) then begin
      tFsi # FsiOpen(aDestFile,_FsiStdWrite);
      tRsp->HttpGetData(tFsi);
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

  return(tError);
end;



//========================================================================
//========================================================================
MAIN
local begin

  vDLL            : handle;

  vRetVal : alpha;

  vPath : alpha(1000);
  vInstanz : int;
  vFormname : alpha;
  
  
  vStart, vEnd : alpha;
  vStartTime : caltime;
  vEndTime   : caltime;

  vX  : int;
  vMem  : int;
  vURL : alpha(4000);
  vHdl  : int;
  vA  : alpha(2000);
  
  vJson : handle;
  
  // -------------------------------------------------------------------
  Erx   : int;
  v401a : int;
  v401b : int;
end;
begin

  
  debugx('TEST');


RETURN;

    v401a # RecBufCreate(401);
    v401a->Auf.P.Nummer   # 123456;
    v401a->Auf.P.Position # 1;
    Erx # RecRead(v401a,1,0);

    
    v401a->Auf.P.Position # v401a->Auf.P.Position + 1;
    RecInsert(v401a,1);
    
    RecBufDestroy(v401a);
  
  RETURN;
  
  


  Anh_Filescanner:ImportFileDialog();
  RETURN;



  vPath # 'c:\debug\debug_http.txt';
  vX  # Lib_HTTP.Core:SendGetRequest('https://','localhost','/api/Report/Ping',44371);
  vHdl # Lib_HTTP.Core:GetResponse(vX, vPath);


  todo('ping DONE');
  vX  # Lib_HTTP.Core:SendGetRequest('https://','localhost','/api/Report/Version',44371);
  vA # Lib_HTTP.Core:GetResponseString(vX);
  todo('version DONE: ' + StrChar(10) + vA);


  vJSON # OpenJSON();
  AddJsonInt(vJSON, 'LinkDepth',          5);
  AddJsonInt(vJSON, 'EigeneAdressNummer', 1386);
  AddJsonAlpha(vJSON, 'EigenerUser', 'ST');
  AddJsonAlpha(vJSON, 'Name',             'AB');
  AddJsonAlpha(vJSON, 'FrxFile',          'p:\STD\FRX\STD_AufBest.frx');
  AddJsonAlpha(vJSON, 'jobIdFromPath','myJObPath');   // !!
  AddJsonAlpha(vJSON, 'outputTypes',      'MEMDB_PDF');
  AddJsonAlpha(vJSON, 'mark','');
  AddJsonAlpha(vJSON, 'recipient',        'KD+AP');
  AddJsonAlpha(vJSON, 'paraObjectString','{}');
  AddJsonAlpha(vJSON, 'settingsObjectString','{}');

  vX  # Lib_HTTP.Core:SendPostRequest('https://','localhost','/api/Report/StartPdf',vJSON,44371);
  vA # Lib_HTTP.Core:GetResponseString(vX);
  todo('PrintPDF DONE: ' + StrChar(10) + vA);
  



/*

todo('version DONE');



vURL # 'linkDepth=3&eigeneAdressNummer=0&eigenerUser=ich';
vURL # vURL + '&name=myname&frxFile=STD_TEST.FRX&jobIdFromPath=myjob';
vURL # vURL + '&outputTypes=PDF';
//vURL # vURL + '&paraObjectString=mypara';
vURL # vURL + '&mark=mark';
vURL # vURL + '&recipient=reci';
vURL # vURL + '&paraObjectString=%7B%20%7D';
vURL # vURL + '&settingsObjectString=%7B%20%20%20%22Hauswaehrung%22%3A%22EUROSYMBOL%22%2C%20%20%20%22Nachkommastellen_Gewicht%22%3A0%2C%20%20%20%22Nachkommastellen_Menge%22%3A3%2C%20%20%20%22';
vURL # vURL + 'Nachkommastellen_RAD%22%3A0%2C%20%20%20%22Nachkommastellen_Dicke%22%3A3%2C%20%20%20%22Nachkommastellen_Breite%22%3A3%2C%20%20%20%22Nachkommastellen_Laenge%22%3A0%20%7D';
vX  # DownloadResponseBody('https://localhost','/api/Report/StartPdf?'+vURL, vPath,44371);
todo('pdf DONE');
*/

/***
https://localhost:44371/api/Report/StartPdf?
linkDepth=3&eigeneAdressNummer=123&eigenerUser=myuser&name=myname&frxFile=myfrx&jobIdFromPath=myjob&outputTypes=mytyp&backgroundPic=mypic&mark=mymark&
recipient=myrec&paraObjectString=mypara&settingsObjectString=%7B%20%20%20%22Hauswaehrung%22%3A%22
EUROSYMBOL%22%2C%20%20%20%22Nachkommastellen_Gewicht%22%3A0%2C%20%20%20%22Nachkommastellen_Menge%22%3A3%2C%20%20%20%22Nachkommastellen_RAD%22%3A0%2C%20%20%20%22Nachkommastellen_Dicke%22%3A3%2C%20%20%20%22Nachkommastellen_Breite
%22%3A3%2C%20%20%20%22Nachkommastellen_Laenge%22%3A0%20%7D
***/
RETURN;


end;


//========================================================================
//========================================================================
//========================================================================
