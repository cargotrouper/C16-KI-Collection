@A+
//==== Business-Control ===================================================
//
//  Prozedur    SOA_SVL_Servicelayer
//                      OHNE E_R_G
//  Info
//        Implementerung des Servicelayers für die Webserviceintegration
//
//  02.09.2010  ST  Erstellung der Prozedur
//  15.11.2012  ST  Bugfix: SOA Allocate hibnzugefügt
//  14.11.2017  AH  Erweiterung für "DotNet_Callbacks"
//  21.11.2017  AH  Init passiert nur, wenn bisher noch nicht geschehen - so performanter bei Usersharing
//                  Dadurch KEIN TERM mehr!!!
//  15.11.2018  ST  "SendingUser" für PostRequests eingebaut
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    sub handleRequest ( aTsk : handle; aEvtType : int )
//    sub parseRequest(aRequest : handle) : handle
//
//
//=========================================================================
@I:Def_Global
@I:Lib_SOA
@I:SOA_SVL_Protokoll

define begin
//  Log(a)      :  Lib_Soa:Dbg(cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+ '['+__PROC__+':'+aint(__LINE__)+']' + ':' + a);
  Log(a)      :  Lib_Soa:Dbg(cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+ '['+Userinfo(_Usercurrent)+']' + ':' + a);
  cProto  : true
  
  // Quelle: C16 Hilfe, berücksichtigt Eigenheiten bei Überlauf
  Sys.TicsDiff(aTicsBegin, aTicsEnd) : Abs(aTicsBegin - aTicsEnd + CnvIL(aTicsBegin >= 0 and aTicsEnd < 0))
end;

declare parseRequest(aRequest : handle) : handle

//=========================================================================
//  sub handleRequest(...)
//
//  Verarbeitet die Serviceanfrage, Protokolliert
//
//  @Param
//    aTsk     : handle;    // Handle des C16 SOA Services
//    aEvtType : int        // Typ des Handles
//
//  @Return
//    - kein Rückgabewert
//
//=========================================================================
sub handleRequest ( aTsk : handle; aEvtType : int )
local begin
  // Verbindungs  -, Anfrage- & Antwortvariablen
  vSocket         : handle; // Socket der Verbindung
  vRequest        : handle; // Handle für das Requestobjekt
  vRequestData    : handle; // Daten der Anfrage
  vResponse       : handle; // Handle für Responseobjekt
  vResponseData   : handle; // Antwortdaten-Container
  vResponseRoot   : handle; // Einstiegsknoten für Antwort
  vResponseAnswer : handle; // Objekt für Daten der Ausführung
  vResponseMem    : handle; // Speicherobjekt für Antwortdaten
  vResponseLength : int;    // Länge der Antwort
  vErrNode        : handle; // Node für Fehlerrückgabe

  // Protokolldaten
  vProtokId     : int;    // ID des entsprechenden Protokolleintrages
  vSvcErr       : int;    //  Fehlercode der Serviceausführung
  vSceTime      : int;    //  Ausführungszeit gesamt
  vSceTimeStart : int;    //  Ausführung Start
  vSceTimeEnd   : int;    //  Ausführung Ende
  vErg  : int;
  vResponseMemTest : handle;

  vNoXmlOutput : logic;
  vContentType : alpha;
  vStatusCode : int;
end;
begin


  // Settings laden
//  RecRead(903,1,_recFirst);

//__HttpServer(aTsk, aEvtType);


  // Socket der übergeben Verbindung/Task lesen
  vSocket # aTsk->spSvcSckHandle;

  // aEvtTyp unterstützt folgende Zustände:
  //  _SckEvtConnect    -> Tritt bei einem neuen Request ein
  //  _SckEvtDisconnect -> Verbindungsabbruch bei "StayAlive" Kommunikation
  //  _SckEvtData       -> Datenempfang bei "StayAlive" Kommunikation
  //  _SckEvtTimeout    -> Timeout bei "StayAlive" Kommunikation

  // DESIGNENTSCHEIDUNG:
  // Da wir keine StayAlive Kommunikation behandeln, kommt für das Abarbeiten
  // der Requests nur der _SckEvtConnect zum Tragen.
  // Alle anderen Zustände werden ignoriert.

  case (aEvtType) of

    // Nicht benutzte Events abfangen
    _SckEvtData : begin
//Log('-> _SckEvtData');
    end;
    
    
    _SckEvtDisconnect : begin
      vSocket->SckClose();
//Log('-> _SckEvtDisconnect');
      RETURN;
    end;
    
    
    _SckEvtTimeout : begin
//Log('-> _SckEvtTimeout');
    end;


    // Connectionanfrage ist der einzig ausschlaggebende Event
    _SckEvtConnect : begin
//Log('-> _SckEvtConnect');
      // Zeitmessung starten
      vSceTimeStart # SysTics();
      if (VarInfo(VarSysPublic)<=0) then begin
        if (Lib_Soa:Init()<>'') then begin
          WINHALT();
          RETURN;
        end;
      end;

      // HTTPRequestObjekt erstellen
      vRequest      # HttpOpen(_HttpRecvRequest, vSocket);
      if (vRequest <= 0) then begin
        vSocket->SckClose();
        RETURN;
      end;

      // Anfrage parsen -> in eigenes XML Format lesen
      vRequestData  # parseRequest(vRequest);

      //HTTP Response & AntwortobjektDatenobjekt erstellen
      vResponse       # HttpOpen(_httpSendResponse, vSocket);
      vResponseData   # CteOpen(_cteNode);
      vResponseData->spId # _xmlNodeDocument;
      vResponseRoot   # vResponseData->Lib_XML:AppendNode('SC_RESPONSE');

      // Fehlernode und Antwortnode anhängen,
      // wird vom Manager und Service beschrieben
      vErrNode        # vResponseRoot->Lib_XML:AppendNode('ERRORS');
      vResponseAnswer # vResponseRoot->Lib_XML:AppendNode('DATA');

      // --------------------------------------------
      // Anfrage ausführen & auswerten
      // Request protokollieren
      if (cProto) then vProtokId # prtRequest(vRequestData, vSocket, aTsk);

      // Request an Manager weiterleiten
      vSvcErr # SOA_SVM_Manager:process(vRequestData,var vResponseRoot);

      // Speicher für die Antwort allokieren
      vResponseMem # MemAllocate( _memAutoSize );

      // Anfrage auswerten
      if ( vSvcErr = errSVL_ExecMemory ) then begin
        // Spezieller Fehler, der die Ausführung der `execMemory` Prozedur
        // des Services bewirkt. Diese liefert direkt die Serviceantwort als
        // Binärdaten in einem Memory-Objekt.
        vStatusCode # SOA_SVM_Manager:execMemory( vRequestData, var vResponseMem, var vContentType );

        setParam( vResponse->spHttpHeader, 'Content-Type', vContentType );
        vResponse->spStatusCode # getHttpStatus( vStatusCode );
        vNoXmlOutput # true;
      end
      else if (vSvcErr <> 0) then begin // Standardfehler

        // ggf. Fehler anhängen; negative Fehlercodes generieren
        // keine globale Fehlermeldung, da diese schon vorher
        // an die Fehlerausgabe angehängt wurden
        if (vSvcErr > 0) then
          vResponseRoot->addErrNode(vSvcErr);

        // Daten entfernen
        vResponseAnswer # vResponseRoot->getNode('DATA');
        if (vResponseAnswer <> 0) then begin
          vResponseAnswer->CteClear(true);
          vResponseRoot->CteDelete(vResponseAnswer);
        end;

        // HTTP Fehler zurückgeben
        //vResponse->spStatusCode # getHttpStatus( 500 );
        vResponse->spStatusCode # getHttpStatus( 200 );
      end
      else begin // Normale Ausgabe
//Log('Normale ausgabe');
        // Keine Fehler aufgetreten, dann Fehlerknoten entfernen
        vErrNode # vResponseRoot->getNode('ERRORS');
        if (vErrNode <> 0) then begin
          vErrNode->CteClear(true);
          vResponseRoot->CteDelete(vErrNode);
        end;

        // HTTP Response Status setzen
        vResponse->spStatusCode # getHttpStatus( 200 );
//Log('Status 200 IO');
      end;

      if ( !vNoXmlOutput ) then begin
        // Antwortdaten als XML für HTTP Antwort konvertieren
        vErg # vResponseData->XmlSave( null, _xmlSaveDefault, vResponseMem, _charsetUtf8, _charsetUtf8 );
        setParam( vResponse->spHttpHeader, 'Content-Type', 'text/xml' );
      end;


//Log('Closing');

      // Standard Header-Informationen
      vResponseLength # vResponseMem->spLen;
      setParam( vResponse->spHttpHeader, 'Content-Length', CnvAI( vResponseLength, _fmtNumNoGroup ) );

      // Antwort schreiben
      vResponse->HttpClose( _HttpCloseConnection, vResponseMem );
//      vResponse->HttpClose( 0, vResponseMem );

      // Zeitmessung beenden
      vSceTimeEnd # SysTics();
      vSceTime    # Sys.TicsDiff( vSceTimeStart, vSceTimeEnd ) / 32;

      // Response protokollieren, nicht-XML Ausgabe berücksichtigen
      if (cProto) then prtResponse( vProtokId, vResponseData, vResponseLength, vSvcErr, vSceTime, vNoXmlOutput );

      // Speicher freigeben
      vResponseData->CteClose();
      MemFree(vResponseMem);

      // Verbindungen schließen
//      vSocket->SckClose();
    end; // _SckEvtConnect : begin


    otherwise begin
      dbg( '-->unbehandelter SocketEvent: '+ CnvAi(aEvtType)); // für Debugzwecke
    end;

  end;  // Ende


    if (vSocket->SckInfo(_SckKeepAlive) <> '0') then begin
//mydebug('lass offen...');
//Log('-> keep open');
      RETURN;
    end;

  // Verbindung trennen
    vSocket->SckClose();
//Log('-> CLOSE');

end; // sub handleRequest (...)



//=========================================================================
//  sub parseRequest(...) : handle
//
//  Liest die Daten des Requests aus und erstellt ein internes Speicherobjekt
//
//  @Param
//    aRequest : handle     // Handle des Requestobjektes
//
//  @Return
//    handle                // Handle der Requestdaten
//
//=========================================================================
sub parseRequest(aRequest : handle) : handle
local begin
  Erx       : int;
  // Knotenhandles
  vDoc      : handle;   // Handle für XML Document
  vRoot     : handle;   // Handle für XML Root
  vHeader   : handle;   // Handle für Headerknoten
  vArgs     : handle;   // Handle für Argumentenknoten

  // Bearbeitungsvariablen
  vPostXml  : handle;   // Handle für übergebene XML Struktur
  vPostData : handle;   // Handle für de Postdaten
  vPostArg  : handle;   // Knoten für übersendete ArgumentDaten
  vItem     : handle;   // Iterationsnode
  vName     : alpha(1000);    // Name des Knotenelementes


  vPostFromWebApp   : logic;
  vPostFromCallback : logic;
  vTempItem         : handle;
  vErg              : int;

  vActionToken      : alpha;

  vParams           : alpha(500);
  vTok              : alpha;
  vKey              : alpha;
  vI,vMax           : int;

  vSenderToken      : alpha;
  vSendingUserToken : alpha;
end
begin

  // interne XML Struktur erstellen
  vDoc        # CteOpen(_cteNode);
  vDoc->spId  # _xmlNodeDocument;
  vRoot       # vDoc->Lib_XML:AppendNode('REQUEST');

  // Header auslesen
  vHeader # vRoot->Lib_XML:AppendNode(toUpper('header'));
  vHeader->Lib_XML:AppendNode( toUpper('Method'),    aRequest->spMethod);
  vHeader->Lib_XML:AppendNode( toUpper('RequestURL'),aRequest->getRequestUrl());
  vHeader->Lib_XML:AppendNode( toUpper('FullURL'),   aRequest->spURI);


  FOR  vItem # aRequest->spHttpHeader->CteRead(_cteFirst);
  LOOP vItem # aRequest->spHttpHeader->CteRead(_cteNext, vItem);
  WHILE (vItem != 0) DO BEGIN
    vHeader->Lib_XML:AppendNode( toUpper(vItem->spName), vItem->spCustom);
  END;

  // Argumente extrahieren
  if (aRequest->spMethod = 'GET') then begin

    vArgs # vRoot->Lib_XML:AppendNode(toUpper('Args'));

    // Argumente über GET Parameter auslesen
    FOR  vItem # aRequest->spHttpParameters->CteRead(_cteFirst);
    LOOP vItem # aRequest->spHttpParameters->CteRead(_cteNext, vItem);
    WHILE (vItem != 0) DO BEGIN
      // Knotennamen für internen Gebrauch anpassen
      vName # toUpper(strCnv(vItem->spName,_StrFromUTF8));
      vArgs->Lib_XML:AppendNode(vName, vItem->spCustom);
    END;
  end
  else if (aRequest->spMethod = 'POST') then begin

    vPostFromWebApp   # (StrFind(aRequest->spURI, 'WEBAPP_ACTION',1) > 0);
    vPostFromCallback # (StrFind(aRequest->spURI, 'DOTNET_CALLBACKS',1) > 0);

    if (aRequest->spURI = '/XML') or (vPostFromWebApp) or (vPostFromCallback) then begin
      // Header enthält URI, dann müssen die ankommenden Daten als
      // File gelesen werden
      vPostData # MemAllocate(_memAutoSize);
      aRequest->HttpGetData(vPostData);

      // Argumente in interne Struktur anhängen
      vPostXml # CteOpen(_CteNode);
      Erx # vPostXml->XmlLoad('',0,vPostData);
      if (Erx < 0) then
        Lib_Soa:Dbg('ERG XML Load:' + XmlError(_XmlErrorText) + ' (Fehler ' + XmlError(_XmlErrorCode) +') Zeile: ' + XmlError(_XmlErrorLine) + ' Spalte: ' + XmlError(_XmlErrorColumn));

      // Argumentknoten Extrahieren und Anhängen (ohne xml Doctype etc. )
      if (vPostFromWebApp = false) and (vPostFromCallback = false) then begin
        vPostArg # vPostXml->getNode('ARGS');
        vRoot->CteInsert(vPostArg, _CteChild);
      end else begin
        vPostArg # vRoot->Lib_XML:AppendNode( 'ARGS');

        // Service und Action aus Url lesen
        if (vPostFromCallBack) then
          vPostArg->Lib_XML:AppendNode('SERVICE','DOTNET_CALLBACKS')
        else
          vPostArg->Lib_XML:AppendNode('SERVICE','WEBAPP_ACTION');
        vActionToken # Str_Token(aRequest->getRequestUrl(),'/',3);
        vPostArg ->Lib_XML:AppendNode('ACTION',toUpper(vActionToken));

/*
        //  Sender Extrahieren
        vSenderToken #  Str_Token(aRequest->spURI,'sender',2);
        vSenderToken #  StrCut(vSenderToken,2,StrLen(vSenderToken)-1);
        vPostArg->Lib_XML:AppendNode('SENDER',toUpper(vSenderToken));

        // SendingUser
        vSendingUserToken #  Str_Token(aRequest->spURI,'sendinguser',2);
        vSendingUserToken #  StrCut(vSendingUserToken,2,StrLen(vSendingUserToken)-1);
        vPostArg->Lib_XML:AppendNode('SENDINGUSER',toUpper(vSendingUserToken));
*/
        //  weitere Parameter extrahieren
        vParams # Str_Token(aRequest->spURI,'?',2);
        vParams # Lib_Strings:Strings_ReplaceAll(vParams,'&amp;','&');

        vMax # Lib_Strings:Strings_Count(vParams,'&') + 1;
        FOR  vI # 1;
        LOOP inc(vI);
        WHILE (vI <= vMax)  DO BEGIN
          vTok # Str_Token(vParams,'&',vI);
          vKey # Str_Token(vTok,'=',1);
          vPostArg->Lib_XML:AppendNode(toUpper(vKey),toUpper(Str_Token(vTok,'=',2)));
        END;

        // Gesendete XML Daten lesen
        vPostXml->spId # _XmlNodeElement;
        vPostXml->spName # 'POSTDATA';

        vPostArg->CteInsert(vPostXml,_CteChild | _CteLast);
      end;
      MemFree(vPostData);

    end else begin
      // Postdaten als Liste von Schlüssel und Werten einlesen
      vArgs # vRoot->Lib_XML:AppendNode(toUpper('Args'));

      // Argumente über POST Daten auslesen
      vPostData # CteOpen(_cteList);
      aRequest->HttpGetData(vPostData);
      FOR  vItem # vPostData->CteRead(_cteFirst);
      LOOP vItem # vPostData->CteRead(_cteNext, vItem);
      WHILE (vItem != 0) DO BEGIN
        // Knotennamen für internen Gebrauch anpassen
        vName # toUpper(strCnv(vItem->spName,_StrUmlaut));
        vArgs->Lib_XML:AppendNode(vName, vItem->spCustom);
      END;
      vPostData->CteClose();

    end;

  end;

  // XML Dokument zurückgeben
  RETURN vDoc;

end; // sub parseRequest(...)


//=========================================================================
//=========================================================================
//=========================================================================
