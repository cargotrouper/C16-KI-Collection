@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_FTP2
//                OHNE E_R_G
//  Info      sysFTP von Vectorsoft
//
//
//  26.09.2011  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//    sub FTPDelete(aSckt : handle; aFilename : alpha(1250)) : int;

//    sub FTPInit(
//    sub FTPTerm(
//    sub FTPCtrlRead(
//    sub FTPCtrlSend(
//    sub FTPDataRead(
//    sub FTPDataSend(
//    sub FTPAddrRead(
//    sub FTPUser(
//    sub FTPQuit(
//    sub FTPTermQuit(
//    sub FTPInitUser(
//    sub FTPRetr(
//    sub FTPStor(
//    sub FTPDelete(
//
//========================================================================
@I:Def_Global

declare FTPDelete(aSckt : handle; aFilename : alpha(1250)) : int;

// ******************************************************************
// *                                                                *
// * FTP nach RFC 959 <: http://www.faqs.org/rfcs/rfc959.html :>    *
// *                                                                *
// ******************************************************************
@A+
@C+
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Einstellungen                                                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
define
{
  sFTPPort              :   21          // Steuer-Port (Server)
  sFTPTimeConnect       : 2000          // Verbindungs-Timeout
  sFTPTimeRequest       : 1000          // Abfrage-Timeout
  sFTPTimeExchange      : 2000          // Schreib/Lese-Timeout
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Verbindung aufbauen                                            +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPInit(
  aHost                 : alpha;        // Host
  opt aPort             : word;         // Port (0 = Standardport)
  opt aPara             : int;          // Parameter
  opt aTime             : int;          // Timeout
)
: handle;                               // Verbindung oder Fehler

  local
  {
    tSckt               : handle;
  }

{
  // Standardport
  if (aPort = 0)
  {
    aPort # sFTPPort;
  }

  // Standardtimeout
  if (aTime = 0)
  {
    aTime # sFTPTimeConnect;
  }

  // Verbindung herstellen
  tSckt # SckConnect(aHost, aPort, aPara | _SckOptDontLinger, aTime)
  // Verbindung hergestellt
  if (tSckt > 0)
  {
    // Schreib/Lese-Timeout definieren
    tSckt->SckInfo(_SckTimeout, sFTPTimeExchange);
  }

  return(tSckt);
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Verbindung abbauen                                             +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPTerm(
  aSckt                 : handle;       // Verbindung
)
{
  // Verbindung trennen
  aSckt->SckClose();
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Steuerverbindung auslesen                                      +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPCtrlRead(
  aSckt                 : handle;       // Steuerverbindung
  var vCode             : int;          // Code
  var vMssg             : alpha;        // Nachricht
)
: int;                                  // Resultat

  local
  {
    tRslt               : int;
    tCode               : alpha(   3);
    tMssg               : alpha(4096);
  }

{
  // Daten zurücksetzen
  vCode # 0;
  vMssg # '';

  // Daten vorhanden
  if (aSckt->SckInfo(_SckReadyRead, sFTPTimeRequest) = '0')
  {
    // Daten lesen
    tRslt # aSckt->SckRead(_SckLine, tMssg);
    // Lesen erfolgreich
    if (tRslt >= 0)
    {
      // Protokolltext angegeben
      STD_Protokoll('<' + ' ' + tMssg);

      // Code ermitteln
      vCode # CnvIA(StrCut(tMssg, 1, 3));
      // Nachricht ermitteln
      vMssg # StrDel(tMssg, 1, 4);

      // Mehrzeilige Antwort
      if (StrCut(tMssg, 4, 1) = '-')
      {
        // Daten verarbeiten
        do
        {
          // Keine Daten mehr vorhanden: Abbruch
          if (aSckt->SckInfo(_SckReadyRead, sFTPTimeRequest) != '0')
            break;

          // Daten lesen
          tRslt # aSckt->SckRead(_SckLine, tMssg);
          // Lesen erfolgreich
          if (tRslt >= 0)
          {
            // Protokolltext angegeben
            STD_Protokoll('<' + ' ' + tMssg);

            // Code ermitteln
            tCode # StrCut(tMssg, 1, 3);
            // Nachricht ermitteln
            vMssg # vMssg + StrChar(13) + StrChar(10) + StrDel(tMssg, 1, 4);

            // Letzte Zeile?
            if (tRslt >= 3 and tCode != '   ' and CnvIA(tCode) = vCode)
            {
              // Abbruch
              break;
            }
          }
        }
        while (tRslt >= 0);
      }
    }

    // Daten übertragen
    if (tRslt > 0)
    {
      tRslt # _ErrOK;
    }
  }

  // Fehlercode setzen
  ErrSet(tRslt);

  // Fehler aufgetreten and Protokolltext angegeben
  if (tRslt != _ErrOK)
  {
    // Protokoll schreiben
    STD_Protokoll('#' + ' ' + CnvAI(tRslt));
    if (gUSERgroup='JOB-SERVER')
      Job_Frame:Proto('FTP-ERROR: '+CnvAI(tRslt));
  }

  return(tRslt);
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Steuerverbindung beschreiben                                   +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPCtrlSend(
  aSckt                 : handle;       // Steuerverbindung
  aCmmd                 : alpha;        // Befehl
)
: int;                                  // Resultat

  local
  {
    tRslt               : int;
  }

{
  // Protokolltext angegeben
  STD_Protokoll('>' + ' ' + aCmmd);

  // Daten schreiben
  try
  {
    ErrTryCatch(_ErrAll,y);
    tRslt # aSckt->SckWrite(_SckLine, aCmmd);
  }
  if (errget() <> _ErrOK)
  {
    tRslt # _ErrSckWrite;
    // Protokoll schreiben
    STD_Protokoll('#' + ' Descriptor error:' + CnvAI(tRslt));
    if (gUSERgroup='JOB-SERVER')
      Job_Frame:Proto('FTP-ERROR: descriptor error: '+CnvAI(tRslt));
    RETURN (tRslt);
  }



  // Daten übertragen
  if (tRslt > 0)
  {
    tRslt # _ErrOK;
  }

  // Fehlercode setzen
  ErrSet(tRslt);

  // Fehler aufgetreten and Protokolltext angegeben
  if (tRslt != _ErrOK)
  {
    // Protokoll schreiben
    STD_Protokoll('#' + ' ' + CnvAI(tRslt));
    if (gUSERgroup='JOB-SERVER')
      Job_Frame:Proto('FTP-ERROR: '+CnvAI(tRslt));
  }

  return(tRslt);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Datenverbindung auslesen                                       +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPDataRead(
  aSckt                 : handle;       // Datenverbindung
  aHndl                 : handle;       // Handle
  opt aSize             : bigint;       // Dateigröße
)
: int;                                  // Resultat

  local
  {
    tRslt               : int;
    tNmbr               : int;
    tLine               : alpha(4096);
    tArea               : byte[4096];
    tSize               : bigint;
  }

{
  // Dateigröße übernehmen
  tSize # aSize;

  // Unterscheidung über Handle-Typ
  switch (aHndl->HdlInfo(_HdlType))
  {
    // Text
    case _HdlText :
    {
      // Zeilenanzahl ermitteln
      tNmbr # aHndl->TextInfo(_TextLines);

      // Daten verarbeiten
      do
      {
        // Keine Daten mehr vorhanden: Abbruch
        if (aSckt->SckInfo(_SckReadyRead, sFTPTimeRequest) != '0')
          break;

        // Daten lesen (Zeilenweise)
        tRslt # aSckt->SckRead(_SckLine, tLine);
        // Lesen erfolgreich
        if (tRslt >= 0)
        {
          // Zeilenumbruch mitrechnen
          inc (tRslt, 2);
          // Dateigröße angegeben
          if (aSize != 0\b)
          {
            // Dateigröße erreicht
            if (tSize < CnvBI(tRslt))
            {
              // Zeilenlänge korrigieren
              tLine # StrCut(tLine, 1, CnvIB(tSize));
            }

            // Verbleibenden Dateigröße berechnen
            dec (tSize, tRslt);
          }

          // Zeilennummer bestimmen
          inc (tNmbr);

          // Zeile schreiben
          aHndl->TextLineWrite(tNmbr, tLine, _TextLineInsert);
        }
      }
      // Daten gelesen und Dateigröße nicht angegeben oder noch nicht erreicht
      while (tRslt >= 0 and (aSize = 0\b or tSize > 0\b));
    }
    // Datei
    case _HdlFile :
    {
      // Daten verarbeiten
      do
      {
        // Keine Daten mehr vorhanden: Abbruch
        if (aSckt->SckInfo(_SckReadyRead, sFTPTimeRequest) != '0')
          break;

        // Daten lesen (Blockweise)
        tRslt # aSckt->SckRead(_SckReadMax, tArea);
        // Lesen erfolgreich
        if (tRslt > 0)
        {
          // Dateigröße angegeben
          if (aSize != 0\b)
          {
            // Verbleibenden Dateigröße berechnen
            dec (tSize, tRslt);
          }

          // Block schreiben
          tRslt # aHndl->FsiWrite(tArea, tRslt);
        }
      }
      // Daten gelesen und Dateigröße nicht angegeben oder noch nicht erreicht
      while (tRslt >= 0 and (aSize = 0\b or tSize > 0\b));
    }
  }

  // Daten übertragen
  if (tRslt > 0)
  {
    tRslt # _ErrOK;
  }

  // Dateigröße nicht angegeben: Lesen bis zum Verbindungsabbruch
  if (aSize = 0\b and tRslt = _ErrSckRead)
  {
    // Kein Fehler
    tRslt # _ErrOK;
  }

  // Fehlercode setzen
  ErrSet(tRslt);

  return(tRslt);
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Datenverbindung beschreiben                                    +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPDataSend(
  aSckt                 : handle;       // Datenverbindung
  aHndl                 : handle;       // Handle
)
: int;                                  // Resultat

  local
  {
    tRslt               : int;
    tNmbr               : int;
    tPosi               : int;
    tLine               : alpha(4096);
    tArea               : byte[4096];
  }

{
  // Unterscheidung über Handle-Typ
  switch (aHndl->HdlInfo(_HdlType))
  {
    // Text
    case _HdlText :
    {
      // Zeilenanzahl ermitteln
      tNmbr # aHndl->TextInfo(_TextLines);

      // Daten verarbeiten
      for   tPosi # 1;
      loop  inc (tPosi);
      while (tPosi <= tNmbr and tRslt >= 0)
      {
        // Zeile lesen
        tLine # aHndl->TextLineRead(tPosi, 0);

        // Zeilenumbruch?
        if (aHndl->TextInfo(_TextNoLineFeed) = 0)
        {
          tLine # tLine + StrChar(13) + StrChar(10);
        }

        // Daten schreiben (Zeilenweise)
        tRslt # aSckt->SckWrite(0, tLine);

      }
    }
    // Datei
    case _HdlFile :
    {
      // Dateizeiger zurücksetzen
      aHndl->FsiSeek(0);

      // Daten verarbeiten
      do
      {
        // Block lesen
        tRslt # aHndl->FsiRead(tArea);
        // Lesen erfolgreich
        if (tRslt > 0)
        {
          // Daten schreiben (Blockweise)
          tRslt # aSckt->SckWrite(0, tArea, tRslt);
        }
      }
      while (tRslt > 0);
    }
  }

  // Daten übertragen
  if (tRslt > 0)
  {
    tRslt # _ErrOK;
  }

  // Fehlercode setzen
  ErrSet(tRslt);

  return(tRslt);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Verbindungsparameter lesen                                     +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPAddrRead(
  aMssg                 : alpha;        // Nachricht
  var vHost             : alpha;        // Host (IP-Adresse)
  var vPort             : word;         // Port
)
: logic;                                // Erfolg

  local
  {
    tPosE               : int;
    tPosB               : int;
    tPara               : alpha( 400);
    tPosS               : int;
    tItem               : alpha;
    tCntr               : int;
  }

{
  // Verbindungsparameter zurücksetzen
  vHost # '';
  vPort # 0;

  // Segmentende suchen
  tPosE # StrFind(aMssg, ')', 1, _StrFindReverse);
  if (tPosE != 0)
  {
    // Segmentanfang suchen
    tPosB # StrFind(StrCut(aMssg, 1, tPosE), '(', 1, _StrFindReverse);
    if (tPosB != 0)
    {
      // Datensegment ausschneiden
      tPara # StrCut(aMssg, tPosB + 1, tPosE - tPosB - 1);

      // Segmentposition setzen
      tPosB # 1;

      // Segment verarbeiten
      do
      {
        // Separator suchen
        tPosE # StrFind(tPara, ',', tPosB);
        // Kein Separator vorhanden
        if (tPosE = 0)
        {
          // Letztes Element
          tItem # StrCut(tPara, tPosB, 4096);
        }
        else
        {
          // Nächstes Element
          tItem # StrCut(tPara, tPosB, tPosE - tPosB);

          // Segmentposition setzen
          tPosB # tPosE + 1;
        }

        // Leerzeichen entfernen
        tItem # StrAdj(tItem, _StrBegin | _StrEnd);

        // Segmentzähler inkrementieren
        inc (tCntr);

        // Unterscheidung über Segmentzähler
        switch (tCntr)
        {
          // Host
          case 1, 2, 3, 4 :
          {
            // Separator einfügen
            if (vHost != '')
            {
              vHost # vHost + '.';
            }

            // Host zusammensetzen
            vHost # vHost + tItem;
          }
          // Port (High-Byte)
          case 5 :
          {
            vPort # 0x100 * CnvIA(tItem);
          }
          // Port (Low-Byte)
          case 6 :
          {
            vPort # vPort + CnvIA(tItem);
          }
        }
      }
      while (tPosE != 0);

      // Erfolg bei 6 Elementen
      return(tCntr = 6);
    }
  }

  return(N);
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Benutzer anmelden                                              +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPUser(
  aSckt                 : handle;       // Steuerverbindung
  aUser                 : alpha;        // Benutzername
  aPass                 : alpha;        // Passwort
)
: int;                                  // Resultat

  local
  {
    tRslt               : int;
    tCode               : int;
    tMssg               : alpha(4096);
  }

{
  try
  {
    // Befehl senden: Anmelden (Benutername)
    aSckt->FTPCtrlSend('USER' + ' ' + aUser);
    // Bestätigung lesen
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antwort:
    // 331 User name okay, need password.
    if (tCode != 331)
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }

    // Befehl senden: Anmelden (Passwort)
    aSckt->FTPCtrlSend('PASS' + ' ' + aPass);
    // Bestätigung lesen
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antwort:
    // 230 User logged in, proceed.
    if (tCode != 230)
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }
  }

  // Fehlercode ermitteln
  tRslt # ErrGet();

  // Fehler aufgetreten and Protokolltext angegeben
  if (tRslt != _ErrOK)
  {
    // Protokoll schreiben
    STD_Protokoll('#' + ' ' + CnvAI(tRslt));
    if (gUSERgroup='JOB-SERVER')
      Job_Frame:Proto('FTP-ERROR: '+CnvAI(tRslt));
  }

  return(tRslt);
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Sitzung beenden                                                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPQuit(
  aSckt                 : handle;       // Steuerverbindung
)
: int;                                  // Resultat

  local
  {
    tRslt               : int;
    tCode               : int;
    tMssg               : alpha(4096);
  }

{
  try
  {
    // Beenden
    aSckt->FTPCtrlSend('QUIT');
    // Bestätigung lesen: Verabschiedung
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antwort:
    // 221 Service closing control connection.
    if (tCode != 221)
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }
  }

  // Fehlercode ermitteln
  tRslt # ErrGet();

  // Fehler aufgetreten and Protokolltext angegeben
  if (tRslt != _ErrOK)
  {
    // Protokoll schreiben
    STD_Protokoll('#' + ' ' + CnvAI(tRslt));
    if (gUSERgroup='JOB-SERVER')
      Job_Frame:Proto('FTP-ERROR: '+CnvAI(tRslt));
  }

  return(tRslt);
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Steuerverbindung abbauen und Sitzung beenden                   +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPTermQuit(
  aSckt                 : handle;       // Steuerverbindung
)
: int;                                  // Resultat

  local
  {
    tRslt               : int;
  }

{
  // Sitzung beenden
  tRslt # aSckt->FTPQuit();
  // Steuerverbindung trennen
  aSckt->FTPTerm();

  return(tRslt);
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Steuerverbindung aufbauen und Benutzer anmelden                +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPInitUser(
  aHost                 : alpha;        // Host
  aPort                 : word;         // Port (0 = Standardport)
  aUser                 : alpha;        // Benutzername
  aPass                 : alpha;        // Passwort
  opt aPara             : int;          // Parameter
  opt aTime             : int;          // Timeout
  opt aText             : handle;
  opt aGUIText          : handle;
)
: handle;                               // Steuerverbindung oder Fehler

  local
  {
    tSckt               : handle;
    tCode               : int;
    tMssg               : alpha(4096);
    tRslt               : int;
  }

{

  gProtokollText     # aText;
  gProtokollGUIText  # aGUIText;

  STD_Protokoll('Connecting to: '+aHost);

  try
  {
    // Steuerverbindung aufbauen
    tSckt # FTPInit(aHost, aPort, aPara, aTime);
    // Fehler
    if (tSckt < 0)
    {
      tRslt # tSckt;
      tSckt # 0;

      ErrSet(tRslt);
    }

    // Bestätigung lesen: Willkommen
    tSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antwort:
    // 220 Service ready for new user.
    if (tCode != 220)
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }

    // Benutzer anmelden
    STD_Protokoll('Login as: '+aUser);
    tSckt->FTPUser(aUser, aPass);
  }

  // Fehlercode ermitteln
  tRslt # ErrGet();

  if (tRslt = _ErrOK)
  {
    return(tSckt);
  }
  else
  {
    // Steuerverbindung offen
    if (tSckt != 0)
    {
      // Steuerverbindung abbauen und Sitzung beenden
      tSckt->FTPTermQuit();
    }

    return(tRslt);
  }
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Datei vom Host laden (passiv)                                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPRetr(
  aSckt                 : handle;       // Steuerverbindung
  aFrmt                 : logic;        // Übertragungsformat (Y = Text (ASCII), N = Datei (binär))
  aFileRmt              : alpha( 250);  // Datei (remote)
  aFileLcl              : alpha(1250);  // Datei (lokal)
)
: int;                                  // Resultat

  local
  {
    tRslt               : int;
    tCode               : int;
    tMssg               : alpha(4096);
    tHost               : alpha;
    tPort               : word;
    tType               : alpha(   1);
    tSckt               : handle;
    tHndl               : handle;
    tSize               : bigint;
  }

{

  STD_Protokoll('Receive file: '+aFileRmt);
  if (gUSERgroup='JOB-SERVER')
    Job_Frame:Proto('FTP-Status: Receive file '+afileRmt);

  try
  {
    // Befehl senden: Passiver Übertragungsmodus
    aSckt->FTPCtrlSend('PASV');
    // Bestätigung lesen: Verbinungsparameter
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Verbindungsparameter unvollständig
    if (!FTPAddrRead(tMssg, var tHost, var tPort))
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }

    // Datenverbindung aufbauen
    tSckt # FTPInit(tHost, tPort);
    // Fehler
    if (tSckt < 0)
    {
      tRslt # tSckt;
      tSckt # 0;

      ErrSet(tRslt);
    }

    // Befehl senden: Dateigröße ermitteln (NICHT STANDARDISIERT)
    aSckt->FTPCtrlSend('SIZE' + ' ' + aFileRmt);
    // Bestätigung lesen: Dateigröße
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antwort:
    // 213 File status.
    if (tCode = 213)
    {
      // Dateigröße erfassen
      tSize # CnvBA(tMssg);
    }

    // Übertragungsmodus = Text
    if (aFrmt)
    {
      // Übertragungstyp = ASCII
      tType # 'A';
    }
    // Übertragungsmodus = Datei
    else
    {
      // Übertragungstyp = Image (binär)
      tType # 'I';
    }

    // Befehl senden: Übertragungstyp
    aSckt->FTPCtrlSend('TYPE' + ' ' + tType);
    // Bestätigung lesen
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antwort:
    // 200 Type set to A/I.
    if (tCode != 200)
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }

    // Befehl senden: Datei zurückgeben
    aSckt->FTPCtrlSend('RETR' + ' ' + aFileRmt);
    // Bestätigung lesen
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antworten:
    // 125 Data connection already open; transfer starting.
    // 150 About to open data connection.
    if (tCode != 125 and tCode != 150)
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }
  }

  // Fehlercode ermitteln
  tRslt # ErrGet();

  // Kein Fehler
  if (tRslt = _ErrOK)
  {
    // Übertragungsmodus = Text
    if (aFrmt)
    {
      // Text öffnen
      tHndl # TextOpen(16);
    }
    // Übertragungsmodus = Datei
    else
    {
      // Datei öffnen
      tHndl # FsiOpen(aFileLcl, _FsiStdWrite);
    }

    // Öffnen erfolgreich
    if (tHndl > 0)
    {
      // Daten lesen
      tRslt # tSckt->FTPDataRead(tHndl, tSize);

      // Übertragungsmodus = Text
      if (aFrmt)
      {
        if (tRslt = _ErrOK)
        {
          // Text speichern
          tRslt # TxtWrite(tHndl, aFileLcl, _TextExtern);
        }

        // Text schließen
        tHndl->TextClose();
      }
      else
      {
        // Datei schließen
        tHndl->FsiClose();
      }
    }
    // Fehler
    else
    {
      tRslt # tHndl;
    }

    // Fehlercode setzen
    ErrSet(tRslt);
  }

  // Datenverbindung offen
  if (tSckt != 0)
  {
    // Datenverbindung abbauen
    tSckt->FTPTerm();
  }

  // Kein Fehler
  if (tRslt = _ErrOK)
  {
    // Bestätigung lesen
    tRslt # aSckt->FTPCtrlRead(var tCode, var tMssg);
  }

  // Fehler aufgetreten and Protokolltext angegeben
  if (tRslt != _ErrOK)
  {
    // Protokoll schreiben
    STD_Protokoll('#' + ' ' + CnvAI(tRslt));
    if (gUSERgroup='JOB-SERVER')
      Job_Frame:Proto('FTP-ERROR: '+CnvAI(tRslt));
  }

  return(tRslt);
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Datei auf Host schreiben                                       +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPStor(
  aSckt                 : handle;       // Steuerverbindung
  aFrmt                 : logic;        // Übertragungsformat (Y = Text (ASCII), N = Datei (binär))
  aFileRmt              : alpha( 250);  // Datei (remote)
  aFileLcl              : alpha(1250);  // Datei (lokal)
)
: int;                                  // Resultat

  local
  {
    tRslt               : int;
    tCode               : int;
    tMssg               : alpha(4096);
    tHost               : alpha;
    tPort               : word;
    tType               : alpha(   1);
    tSckt               : handle;
    tHndl               : handle;
  }

{
  // exisiterit die Datei?
  ErrTryIgnore(-20,-39);
  tHndl # FsiOpen(aFileLcl,_FsiStdRead);
  if (tHndl<=0)
  {
    STD_Protokoll('File not found: '+aFileLcl);
    if (gUSERgroup='JOB-SERVER')
      Job_Frame:Proto('FTP-ERROR: file not found '+aFileLcl);
    RETURN 0;//_ErrFileInvalid;
  }
  tHndl->FsiClose();


  // Zieldatei vorher löschen...
  aSckt->FTPDelete(aFileRmt);


  STD_Protokoll('Send file: '+aFileRmt);
  if (gUSERgroup='JOB-SERVER')
    Job_Frame:Proto('FTP-status: send file '+aFileRmt);

  try
  {
    // Befehl senden: Passiver Übertragungsmodus
    aSckt->FTPCtrlSend('PASV');
    // Bestätigung lesen: Verbinungsparameter
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Verbindungsparameter unvollständig
    if (!FTPAddrRead(tMssg, var tHost, var tPort))
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }

    // Datenverbindung aufbauen
    tSckt # FTPInit(tHost, tPort);
    // Fehler
    if (tSckt < 0)
    {
      tRslt # tSckt;
      tSckt # 0;

      ErrSet(tRslt);
    }

    // Übertragungsmodus = Text
    if (aFrmt)
    {
      // Übertragungstyp = ASCII
      tType # 'A';
    }
    // Übertragungsmodus = Datei
    else
    {
      // Übertragungstyp = Image (binär)
      tType # 'I';
    }

    // Befehl senden: Übertragungstyp
    aSckt->FTPCtrlSend('TYPE' + ' ' + tType);
    // Bestätigung lesen
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antwort:
    // 200 Type set to A/I.
    if (tCode != 200)
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }

    // Befehl senden: Datei übergeben
    aSckt->FTPCtrlSend('STOR' + ' ' + aFileRmt);
    // Bestätigung lesen
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antworten:
    // 125 Data connection already open; transfer starting.
    // 150 About to open data connection.
    if (tCode != 125 and tCode != 150)
    {
      // Fehler
      ErrSet(_ErrGeneric);
    }
  }

  // Fehlercode ermitteln
  tRslt # ErrGet();

  // Kein Fehler
  if (tRslt = _ErrOK)
  {
    // Übertragungsmodus = Text
    if (aFrmt)
    {
      // Text öffnen
      tHndl # TextOpen(16);
      // Öffnen erfolgreich
      if (tHndl > 0)
      {
        // Text lesen
        tRslt # tHndl->TextRead(aFileLcl, _TextExtern);
      }
    }
    // Übertragungsmodus = Datei
    else
    {
      // Datei öffnen
      tHndl # FsiOpen(aFileLcl, _FsiStdRead);
    }

    // Öffnen erfolgreich
    if (tHndl > 0)
    {
      if (tRslt = _ErrOK)
      {
        // Daten schreiben
        tRslt # tSckt->FTPDataSend(tHndl);
      }

      // Übertragungsmodus = Text
      if (aFrmt)
      {
        // Text schließen
        tHndl->TextClose();
      }
      else
      {
        // Datei schließen
        tHndl->FsiClose();
      }
    }
    // Fehler
    else
    {
      tRslt # tHndl;
    }

    // Fehlercode setzen
    ErrSet(tRslt);
  }

  // Datenverbindung offen
  if (tSckt != 0)
  {
    // Datenverbindung abbauen
    tSckt->FTPTerm();
  }

  // Kein Fehler
  if (tRslt = _ErrOK)
  {
    // Bestätigung lesen
    tRslt # aSckt->FTPCtrlRead(var tCode, var tMssg);
  }

  // Fehler aufgetreten and Protokolltext angegeben
  if (tRslt != _ErrOK)
  {
    // Protokoll schreiben
    STD_Protokoll('#' + ' ' + CnvAI(tRslt));
    if (gUSERgroup='JOB-SERVER')
      Job_Frame:Proto('FTP-ERROR: '+CnvAI(tRslt));
  }

  return(tRslt);
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Datei löschen                                                  +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub FTPDelete(
  aSckt                 : handle;       // Steuerverbindung
  aFilename             : alpha(1250);  // Dateiname
)
: int;                                  // Resultat
  local
  {
    tRslt               : int;
    tCode               : int;
    tMssg               : alpha(4096);
  }

{
  try
  {
    // Befehl senden: Anmelden (Benutername)
    aSckt->FTPCtrlSend('DELE' + ' ' + aFilename);
    // Bestätigung lesen
    aSckt->FTPCtrlRead(var tCode, var tMssg);
    // Erwartete Antwort:
    // 331 User name okay, need password.
    if (tCode != 331)
    {
      // Fehler
//      ErrSet(_ErrGeneric);
    }
  }

  // Fehlercode ermitteln
  tRslt # ErrGet();

  // Fehler aufgetreten and Protokolltext angegeben
  if (tRslt != _ErrOK)
  {
    // Protokoll schreiben
    STD_Protokoll('#' + ' ' + CnvAI(tRslt));
    if (gUSERgroup='JOB-SERVER')
      Job_Frame:Proto('FTP-ERROR: '+CnvAI(tRslt));
  }

  return(tRslt);
}

//========================================================================
//========================================================================
//========================================================================