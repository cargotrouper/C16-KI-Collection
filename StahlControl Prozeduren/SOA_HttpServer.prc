// ******************************************************************
//                  OHNE E_R_G
// *                                                                *
// * HTTP-Server                                                    *
// *                                                                *
// * SOA-Service vom Typ "Socket" als HTTP-Server.                  *
// *                                                                *
// * Mit einem HTTP-Client können vom HTTP-Server verschiedene      *
// * Informationen abgefragt werden werden.                         *
// *                                                                *
// ******************************************************************

@A+ // A+-Befehle verwenden
@C+ // C-Stil verwenden

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Globale Daten                                                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

global HTTPServer
{
  gSvc                  : handle;       // Service
  gSck                  : handle;       // Socket

  gMem                  : handle;       // Speicher

  gReq                  : handle;       // HTTP-Anfrage
  gRsp                  : handle;       // HTTP-Antwort

  gReqHeader            : handle;       // Header-Liste der HTTP-Anfrage
  gReqParams            : handle;       // Parameter-Liste der HTTP-Anfrage
  gRspHeader            : handle;       // Header-Liste der HTTP-Antwort
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Methode ermitteln                                              +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub MethodGet
()
: alpha;
{
  return(gReq->spMethod);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Status setzen                                                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub StatusSet
(
  aStatus               : int;          // Status-Code
)

  local
  {
    tStatus             : alpha;
  }

{
  switch (aStatus)
  {
    case 200 : tStatus # 'OK';
    case 204 : tStatus # 'No Content';
    case 400 : tStatus # 'Bad Request';
    case 404 : tStatus # 'Not Found';
    case 405 : tStatus # 'Method Not Allowed';
    case 500 : tStatus # 'Internal Server Error';
  }

  if (tStatus != '')
  {
    tStatus # CnvAI(aStatus) + ' ' + tStatus;
  }

  // Status setzen
  gRsp->spStatusCode # tStatus;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Header setzen                                                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub RspHeaderSet
(
  aName                 : alpha;
  aValue                : alpha;
)
: logic;

  local
  {
    tRspHeader          : handle;
  }

{
  tRspHeader # gRspHeader->CteInsertItem(aName, 0, aValue);

  return(tRspHeader != 0);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Daten schreiben                                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Write
(
  aLine                 : alpha(1024);  // Zeichenkette
  opt aNoBreak          : logic;        // Kein Zeilenumbruch
)
: int;                                  // Resultat
{
  // Zeichenkette an Speicher anhängen
  gMem->MemWriteStr(_MemAppend, aLine);
  if (!aNoBreak)
  {
    gMem->MemWriteStr(_MemAppend, StrChar(13) + StrChar(10));
  }
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + URL erzeugen                                                   +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Link
(
  aURL                  : alpha(4096);
)
: alpha;

  local
  {
    tPos                : int;
  }

{
  // Session aktiv
  if (gSvc->spSvcSessionID != 0)
  {
    // Parameter angehängt?
    tPos # StrFind(aURL, '?', 1);
    // Keine Parameter angehängt
    if (tPos = 0)
    {
      // Parameterseparator anhängen
      aURL # aURL + '?';

      tPos # StrLen(aURL);
    }
    else
    {
      // Parameterseparator einfügen
      aURL # StrIns(aURL, '&', tPos);
    }

    // Session-ID einfügen
    aURL # StrIns(aURL, 'SID=' + CnvAI(gSvc->spSvcSessionID, _FmtInternal), tPos + 1);
  }

  return(aURL);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Session-Daten                                                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

global SessionData
{
  gData : alpha(4096);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Anfrage durchführen                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Exec
(
  aResource             : alpha(4096);  // Ressource
)

  local
  {
    tStatus             : int;
    tMethod             : alpha(  10);

    tReqParams          : handle;
    tCal                : caltime;
    tSvcSessionID       : int;
    tErr                : int;
  }

{
  tStatus # 200;

  tMethod # MethodGet();

  switch (tMethod)
  {
    case 'GET', 'POST', 'HEAD' :
    {
      Write('<html>');
      Write('<head><title>CONZEPT 16-CodeLibrary - HTTP-Server</title></head>');
      Write('<body>');

      // HTTP-Parameter mit Session-ID ermitteln
      tReqParams # gReqParams->CteRead(_CteSearch | _CteFirst, 0, 'SID');
      // HTTP-Parameter mit Session-ID vorhanden
      if (tReqParams > 0)
      {
//////////////////////////////////////////////////////////////////
        // Session-ID ermitteln
        tSvcSessionID # CnvIA(tReqParams->spCustom, _FmtInternal);

        // Session laden
        tErr # SvcSessionControl(_SvcSessionLoad, tSvcSessionID);
        // Session geladen
        if (tErr = _ErrOK)
        {
          Write('Session successfully loaded.<br/>');
          Write('  ID: ' + CnvAI(tSvcSessionID, _FmtInternal) + '<br/>');

          if (gData != '')
          {
            Write('  Data: ' + gData + '<br/>');
          }
//////////////////////////////////////////////////////////////////
        }
        // Session nicht geladen
        else
        {
          switch (tErr)
          {
            case _ErrUnknown     : Write('Session unknown (ID: ' + CnvAI(tSvcSessionID, _FmtInternal) + ').');
            case _ErrUnavailable : Write('Session already activated (ID: ' + CnvAI(tSvcSessionID, _FmtInternal) + ').');
          }

          Write('<br/>');
        }

        Write('<br/>');
      }

      if (aResource = '')
      {
        Write('The following resources are available:');

        Write('<ul>');

        Write('<li><a href="' + Link('Date') + '">Date</a href> - current date</li>');
        Write('<li><a href="' + Link('Mem')  + '">Mem</a href> - current memory usage</li>');
        Write('<li><a href="' + Link('PID')  + '">PID</a href> - process id</li>');
        Write('<li><a href="' + Link('Thr')  + '">Thr</a href> - number of threads</li>');
        Write('<li><a href="' + Link('Time') + '">Time</a href> - current time</li>');
        Write('<li><a href="' + Link('Ver')  + '">Ver</a href> - programm version</li>');
        if (gSvc->spSvcSessionID = 0)
        {
          Write('<li><a href="' + Link('SessionCreate') + '">SessionCreate</a href> - creates a session</li>');
        }
        else
        {
          Write('<li><a href="' + Link('SessionDataSet') + '">SessionDataSet</a href> - sets data for current session</li>');
          Write('<li><a href="' + Link('SessionDelete') + '">SessionDelete</a href> - deletes current session</li>');
        }

        Write('</ul>');
      }
      else
      {
        switch (StrCnv(aResource, _StrUpper))
        {
          case 'DATE' :
          {
            tCal->vmSystemTime();
            Write('Local date: ' + CnvAD(tCal->vpDate,_FmtDateLong));
          }
          case 'MEM' :
          {
            Write('Memory in use: ' + CnvAI(_Sys->spProcessMemoryKB) + ' KB');
          }
          case 'PID' :
          {
            Write('Local process ID: ' + CnvAI(_Sys->spProcessID,_FmtNumNoGroup));
          }
          case 'THR' :
          {
            Write('Worker threads: ' + CnvAI(gSvc->spJobThreads));
          }
          case 'TIME' :
          {
            tCal->vmSystemTime();
            Write('Local time: ' + CnvAT(tCal->vpTime,_FmtTimeSeconds));
          }
          case 'VER' :
          {
            Write('Actual release: ' + CnvAI(DbaInfo(_DbaClnRelMaj)) + '.' +
                                       CnvAI(DbaInfo(_DbaClnRelMin)) + '.' +
                                       CnvAI(DbaInfo(_DbaClnRelRev),_FmtNumLeadZero,0,2)
            );
          }
//////////////////////////////////////////////////////////////////
          case 'SESSIONCREATE' :
          {
            // Session erzeugen
            tSvcSessionID # SvcSessionControl(_SvcSessionCreate);
            // Session erzeugt
            if (tSvcSessionID > 0)
            {
              // Session-Daten allokieren
              VarAllocate(SessionData);

              Write('Session successfully created (ID: ' + CnvAI(tSvcSessionID, _FmtInternal) + ').');
            }
            // Session nicht erzeugt
            else
            {
              tErr # tSvcSessionID;

              switch (tErr)
              {
                case _ErrSvcSessionState : Write('Session already active.');
                case _ErrLimitExceeded   : Write('Sessionlimit exceeded.');
              }
            }
          }
          case 'SESSIONDELETE' :
          {
            // Session löschen
            tErr # SvcSessionControl(_SvcSessionDelete);
            // Session gelöscht
            if (tErr = _ErrOK)
            {
              Write('Session successfully deleted.');

              // Session-Daten freigeben
              VarFree(SessionData);
            }
            // Session nicht gelöscht
            else
            {
              switch (tErr)
              {
                case _ErrSvcSessionState : Write('No active Session.');
              }
            }
          }
          case 'SESSIONDATASET' :
          {
            // Session nicht geladen
            if (gSvc->spSvcSessionID = 0)
            {
              Write('No active Session.');
            }
            // Session geladen
            else
            {
              tReqParams # gReqParams->CteRead(_CteSearch | _CteFirst, 0, 'data');
              if (tReqParams = 0)
              {
                Write('Session data: ');
                Write('<form method="GET">');
                Write('<input type="hidden" name="SID" value="' + CnvAI(gSvc->spSvcSessionID, _FmtInternal) + '"/>');
                Write('<input type="text" name="data" value="' + gData + '">');
                Write('<input type="submit"/>');
                Write('</form>');
              }
              else
              {
                // Session-Daten setzen
                gData # tReqParams->spCustom;

                Write('Session data successfully set (Data: "' + gData + '").');
              }
            }
          }
//////////////////////////////////////////////////////////////////
          default :
          {
            tStatus # 404;

            Write('Unknown resource [' + aResource + '].');
          }
        }

        Write('<br/>');
        Write('<br/>');

        Write('<a href="' + Link('..') + '">Menu</a>');
      }

      Write('</body>');
      Write('</html>');

      // Datentyp setzen
      RspHeaderSet('Content-Type', 'text/html');
    }
    default :
    {
      tStatus # 405;
    }
  }

  StatusSet(tStatus);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Daten empfangen                                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Recv
(
  var vResource         : alpha;        // Ressource
)
: int;

  local
  {
    tErr                : int;
    tPos                : int;
  }

{
  vResource # '';

  // HTTP-Anfrage empfangen
  gReq # HttpOpen(_HttpRecvRequest, gSck);
  if (gReq > 0)
  {
    // HTTP-Antwort starten
    gRsp # HttpOpen(_HttpSendResponse, gSck);
    if (gRsp > 0)
    {
      gReqHeader # gReq->spHttpHeader;
      gReqParams # gReq->spHttpParameters;
      gRspHeader # gRsp->spHttpHeader;

      // Ressource ermitteln
      vResource # gReq->spURI;

      // Paramater an Resource angehängt?
      tPos # StrFind(vResource, '?', 1);
      if (tPos > 0)
      {
        // Parameter aus Resource entfernen
        vResource # StrCut(vResource, 1, tPos - 1);
      }
    }
    else
    {
      tErr # gRsp;
      gRsp # 0;
    }
  }
  else
  {
    tErr # gReq;
    gReq # 0;
  }

  return(tErr);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Daten versenden                                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Send
()

  local
  {
    tMethodHead         : logic;
  }

{
  if (gReq > 0)
  {
    // Nur Header-Informationen angefragt
    tMethodHead # gReq->spMethod = 'HEAD';

    // HTTP-Anfrage beenden
    gReq->HttpClose(0);
  }

  if (gRsp > 0)
  {
    // Nur Header-Informationen angefragt
    if (tMethodHead)
    {
      // HTTP-Antwort OHNE Body versenden
      gRsp->HttpClose(0);
    }
    else
    {
      // HTTP-Antwort versenden
      gRsp->HttpClose(0, gMem);
    }
  }
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Verbindung initialisieren                                      +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Init
(
  aSvc                  : handle;
  aKeepAlive            : int;
  aTimeout              : int;
  var vResource         : alpha;
)
: int;

  local
  {
    tErr                : int;
  }

{
  VarAllocate(HTTPServer);

  gSvc # aSvc;
  gSck # aSvc->spSvcSckHandle;

  if (aKeepAlive != 0)
  {
    gSck->SckInfo(_SckKeepAlive, aKeepAlive);
  }

  if (aTimeout != 0)
  {
    gSck->SckInfo(_SckTimeout, aTimeout);
  }

  // Speicher reservieren
  gMem # MemAllocate(16 * 1024);

  // Daten empfangen
  tErr # Recv(var vResource);

  return(tErr);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Verbindung terminieren                                         +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub Term
()
{
  // Daten versenden
  Send();

  // Speicher freigeben
  gMem->MemFree();

  // Kein KeepAlive
  if (gSck->SckInfo(_SckKeepAlive) = '0')
  {
    // Verbindung trennen
    gSck->SckClose();
  }

  VarFree(HTTPServer);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + SOA-Einstiegsfunktion                                          +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub entry
(
  aSvc                  : handle;       // Service
  aEvt                  : int;          // Ereignis
)

  local
  {
    tErr                : int;
    tResource           : alpha(4096);
  }

{
  // Initialisieren (KeepAlive: 30 Sekunden, Timeout: 10 Sekunden)
  tErr # Init(aSvc, 30000, 10000, var tResource);

  if (tErr = _ErrOK)
  {
    // Anfrage beantworten
    Exec(StrDel(tResource, 1, 1));
  }

  // Terminieren
  Term();
}