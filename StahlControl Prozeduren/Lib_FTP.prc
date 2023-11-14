@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_FTP
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//  SUB Connect(aIPAdress : alpha; opt aIpPort : word) : int
//  SUB Disconnect(aSck : int)
//  SUB GetFileSize(aSocket : int; aFile : alpha) : int;
//  SUB Display(aSck : int; aTitle : alpha(80))
//  SUB Command(aSck : int; aCommand : alpha)
//  SUB GetIP(aLine : alpha) : alpha
//  SUB GetPort(aLine : alpha) : int
//  SUB SaveFile(aSck : int; aFilename : alpha; aSize : int; aDia : int) : logic
//  SUB ProcessUpdate(aSckCmd : int; aSize : int; aDia : int; var aRes : alpha) : logic;
//  SUB CheckUpdate(aUser : alpha; aPass : alpha) : logic
//
//========================================================================
@I:Def_global

//========================================================================
define begin
  mTimeout    : 2000
  mMaxBuffer  : 8192
  cSite       : '217.86.132.27'//'www.stahl-Control.eu'
  cUpdateFile : 'update.txt'
  cPath       : '.\update\'
end;

//========================================================================
//  Connect
//    Verbindung zu einem FTP-Server herstellen
//========================================================================
sub Connect(
  aIpAdress   : alpha; // IP-Adresse oder Name des FTP-Servers
  opt aIpPort : word;  // Port des FTP-Servers
) : int
local begin
  Erx : int;
end;
begin
//debug('open...'+aipadress+' '+cnvai(aipport));
  if (aIpPort = 0) then aIpPort # 21;


  if (Set.Proxy<>'') then begin
    if (Set.Proxy.Port=0) then Set.Proxy.Port # 1080;

    Erx # SckConnect(aIpAdress,aIpPort, _SckProxySOCKSv5, 5000, Set.Proxy, Set.Proxy.Port);
    if (erx=0) then RETURN Erx;
Msg(019999,'using SOCKS5-Proxy error: '+cnvai(ERx),_WinIcoError,_WinDialogOk,0);
    Erx # SckConnect(aIpAdress,aIpPort, _SckProxySOCKSv4a, 5000, Set.Proxy, Set.Proxy.Port);
    if (erx=0) then RETURN Erx;
Msg(019999,'using SOCKS4a-Proxy error: '+cnvai(ERx),_WinIcoError,_WinDialogOk,0);
    Erx # SckConnect(aIpAdress,aIpPort, _SckProxySOCKSv4, 5000, Set.Proxy, Set.Proxy.Port);
    if (erx=0) then RETURN Erx;
Msg(019999,'using SOCKS4-Proxy error: '+cnvai(ERx),_WinIcoError,_WinDialogOk,0);

    Erx # SckConnect(aIpAdress,aIpPort, 0, 5000, Set.Proxy, Set.Proxy.Port);
    if (erx=0) then RETURN Erx;
Msg(019999,'using std.Proxy error: '+cnvai(ERx),_WinIcoError,_WinDialogOk,0);
    Erx # SckConnect(aIpAdress,aIpPort);
    if (erx=0) then RETURN Erx;
Msg(019999,'using noProxy error: '+cnvai(ERx),_WinIcoError,_WinDialogOk,0);

    RETURN erx;
  end;

  RETURN(SckConnect(aIpAdress,aIpPort));
end;


//========================================================================
//  Disconnect
//    Verbindung von einem FTP-Server trennen
//========================================================================
sub Disconnect(
  aSck : int;
)
begin
//debug('...close!'+cnvai(aSck));
  aSck->SckClose();
  winsleep(500);
end;


//========================================================================
//  GetFileSize
//
//========================================================================
sub GetFileSize(
  aSocket : int;
  aFile   : alpha
) : int;
local begin
  vCommand  : alpha;
end;
begin

  vCommand # 'SIZE '+aFile;
  SckWrite(aSocket,_SckLine,vCommand);
  // Verbindungsinformationen lesen
  SckRead(aSocket,_SckLine,vCommand);
//debug('_size:'+vCommand);
  if (StrLen(vCommand)>3) then begin
    if (StrCut(vCommand,1,3)='213') then
      RETURN cnvia(StrCut(vCommand,4,30));
  end;

  RETURN 0;
end;


//========================================================================
//  Display
//    Auslesen des Sockets und Darstellen des Rückgabetextes
//========================================================================
sub Display(
  aSck   : int;       // Deskriptor des Sockets
  aTitle : alpha(80); // Titel des Frame-Objektes
)
local begin
  tFrame    : int;         // Deskriptor des Frame-Objektes
  tTextEdit : int;         // Deskriptor des TextEdit-Objektes
  tChars    : alpha(4096); // Eingelesene Zeichen
  tErg      : int;         // Anzahl der gelesenen Zeichen
end;

begin
  // Laden des Dialoges
//  tFrame # WinOpen('ftp',_WinOpenDialog);
  // Titel des Dialoges setzen
//  tFrame->wpCaption # aTitle;
  // Deskriptor des TextEdit-Objektes ermitteln
//  tTextEdit # $TextEdit;
  tErg # 1;
//debug('DISPLAY:');
  // Informationen lesen solange welche vorhanden sind oder ein Fehler auftritt
  WHILE ((SckInfo(aSck,_SckReadyRead,mTimeout) = '0') AND (tErg >= 0)) do begin
    // Eine Zeichen vom Socket lesen
    tErg # SckRead(aSck,_SckReadMax,tChars);
    // Die Zeile an das TextEdit-Objekt anhängen
//debug('_'+tchars);
//    tTextEdit->wpCaption # tTextEdit->wpCaption + StrCut(tChars,1,tErg);
  END;
  // Dialog anzeigen
//  tFrame->WinDialogRun();
  // Dialog schließen
//  tFrame->WinClose();
  return;
end;


//========================================================================
//  Command
//    Kommando übertragen und Resultat anzeigen
//========================================================================
sub Command(
  aSck : int;
  aCommand : alpha;
)
begin
  SckWrite(aSck,_SckLine,aCommand);
  WinSleep(1000);
  Display(aSck,aCommand);
  WinSleep(1000);
  Display(aSck,aCommand);
end;


//========================================================================
//  GetIP
//    Aus Rückgabewert die IP-Adresse ermitteln
//========================================================================
sub GetIP(
  aLine : alpha;
) : alpha
local begin
  tIP : alpha;
  tPosStart : int;
  tPosEnd   : int;
end;

begin
  // Anfang der IP-Adresse ermitteln
  tPosStart # StrFind(aLine,'(',1);
  tPosEnd   # StrFind(aLine,',',tPosStart);
  tIP # StrCut(aLine,tPosStart+1,tPosEnd-tPosStart-1) + '.';

  // zweites Byte ermitteln
  tPosStart # tPosEnd;
  tPosEnd   # StrFind(aLine,',',tPosStart+1);
  tIP # tIP + StrCut(aLine,tPosStart+1,tPosEnd-tPosStart-1) + '.';

  // drittes Byte ermitteln
  tPosStart # tPosEnd;
  tPosEnd   # StrFind(aLine,',',tPosStart+1);
  tIP # tIP + StrCut(aLine,tPosStart+1,tPosEnd-tPosStart-1) + '.';

  // viertes Byte ermitteln
  tPosStart # tPosEnd;
  tPosEnd   # StrFind(aLine,',',tPosStart+1);
  tIP # tIP + StrCut(aLine,tPosStart+1,tPosEnd-tPosStart-1);
  return(tIP);
end;


//========================================================================
//  GetPort
//    Aus Rückgabewert IP-Port ermitteln
//========================================================================
sub GetPort(
  aLine : alpha;
) : int
local begin
  tPort : int;
  tPosStart : int;
  tPosEnd   : int;
end;
begin
  // Anfang der IP-Adresse ermitteln und diese überspringen
  tPosStart # StrFind(aLine,',',1);
  tPosStart # StrFind(aLine,',',tPosStart+1);
  tPosStart # StrFind(aLine,',',tPosStart+1);
  tPosStart # StrFind(aLine,',',tPosStart+1);

  // High-Byte der Portnummer
  tPosEnd   # StrFind(aLine,',',tPosStart+1);
  tPort # CnvIA(StrCut(aLine,tPosStart+1,tPosEnd-tPosStart-1)) * 256;

  // Low-Byte der Portnummer
  tPosStart # tPosEnd;
  tPosEnd   # StrFind(aLine,')',tPosStart+1);
  tPort # tPort + CnvIA(StrCut(aLine,tPosStart+1,tPosEnd-tPosStart-1));

  return(tPort);
end;


//========================================================================
//  SaveFile
//    Inhalt eines Sockets in eine externe Datei speichern
//========================================================================
sub SaveFile(
  aSck      : int;   // Deskriptor des Sockets
  aFilename : alpha; // Pfad- und Dateiname
  aSize     : int;
  aDia      : int;
) : logic
local begin
  tBuffer     : byte[mMaxBuffer]; // Puffer zum Lesen der Datei
  tFile       : int;              // Dateideskriptor
  tReadBytes  : int;              // Anzahl der gelesenen Zeichen
  vGesamt     : int;
  vSize       : int;
  vProgress   : int;
end;
begin

  if (aDia<>0) then begin
    vProgress # Winsearch(aDia,'Progress');
    vProgress->wpProgressPos # 0;
    vProgress->wpProgressMax # aSize;
  end;

  // Externe Datei anlegen
  tFile # FsiOpen(aFileName,_FsiCreate | _FsiAcsRW);
  if (tFile > 0) then begin
    tReadBytes # 1;
    // Inhalt der Datei von Sockel lesen bis keine Daten mehr vorhanden sind
    // oder ein Fehler aufgetreten ist.
    WHILE ((SckInfo(aSck,_SckReadyRead,mTimeout) = '0') AND (tReadBytes > 0)) do begin

      if (aDia<>0) then begin
        vProgress->wpProgressPos # vGesamt;
        if (aDia->WinDialogResult() = _WinIdCancel) then begin
          tFile->FSIclose();
          RETURN false;
        end;
      end;

      // Einlesen in eine Puffer-Variable
      tReadBytes # SckRead(aSck,_SckReadMax,tBuffer);
      // Wurden Zeichen vom Socket gelesen?
      if (tReadBytes > 0) then begin
        // Schreiben der Daten in die externe Datei
        FsiWrite(tFile,tBuffer,tReadBytes);
        vGesamt # vGesamt + tReadBytes;
        end
      else begin
//debug('saveerr:'+cnvai(tReadBytes));
      end;
    END;
    // Externe Datei schließen
    tFile->FsiClose();
    end
  else begin
    // Datei konnte nicht angelegt werden
//    WindialogBox(gFrmMain,'FTP','Fehler beim Anlegen der externen Datei.',
//                 _WinIcoWarning,_WinDialogOk,1);
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  ProcessUpdate
//
//========================================================================
sub ProcessUpdate(
  aSckCmd     : int;
  aSize       : int;
  aDia        : int;
  var aRes    : alpha
) : logic;
local begin
  Erx         : int;
  vIPData     : alpha;
  vTxt        : alpha(4000);
  vReadBytes  : int;              // Anzahl der gelesenen Zeichen
  vGesamt     : int;
  vX,vY       : int;
  vA          : alpha(4000);
  vInfo       : alpha(4000);
  vVersion    : alpha;
  vTxtHdl     : int;
  vUpdate     : logic;
  vFile       : alpha[5];
  vTodo       : int;
  vLen        : int;
  vSckData    : int;

  vLabel      : int;
end;
begin
  vLabel # Winsearch(aDia,'Label1');

  // aktuelle Version ermitteln...
  vTxtHdl # TextOpen(16);
  Erx # TextRead(vTxtHdl, '!VERSION',0);
  if (Erx<=_rLocked) then begin
    vVERSION # TextLineRead(vTxtHdl,1,0);
  end;
  TextClose(vTxtHdl);

  // Verbindungsinformationen lesen...
  vIPData # 'PASV';
  SckWrite(aSckCmd,_SckLine,vIPData);
  SckRead(aSckCmd,_SckLine,vIPData);

  // Datenkanal öffnen...
  vSckData # Connect(GetIP(vIPData),GetPort(vIPData));
  if (vSckData <= 0) then RETURN false;

  // Receive File...
  Command(aSckCmd,'RETR '+cUpdateFile);
  vReadBytes # 1;
  // Inhalt der Datei von Sockel lesen bis keine Daten mehr vorhanden sind
  // oder ein Fehler aufgetreten ist.
  WHILE ((SckInfo(vSckData,_SckReadyRead,mTimeout) = '0') AND (vReadBytes > 0)) do begin
    // Einlesen in eine Puffer-Variable
    vReadBytes # SckRead(vSckData,_SckReadMax,vTxt);
  END;

  // Datenkanal schliessen...
  DisConnect(vSckData);
  Display(aSckCmd,'xx');


  // Parse Updatefile...
  vX # 0;
  REPEAT
    vY # StrFind(vTxt,strchar(13)+StrChar(10),vX);
    if (vY=0) then BREAK;

    vA # StrCut(vTxt,vX,vY-vX);
//debug('>'+vA);

    // Versioncheck...
    if (StrFind(StrCnv(vA,_StrUpper) ,'VERSION:',0)>0) then begin
      vA # StrAdj(StrCut(vA,10,100),_StrBegin|_StrEnd);
      if (vA>vVersion) then vUpdate # y;
//debug('v:'+vVersion+'   '+vA);
      end
    else if (StrFind(StrCnv(vA,_StrUpper) ,'FILE:',0)>0) then begin
      vA # StrAdj(StrCut(vA,6,100),_StrBegin|_StrEnd);
      vTodo # vTodo + 1;
      vFile[vTodo] # vA;
      end
    else begin
      vInfo # vInfo + StrCut(vTxt,vX,vY-vX+2);
    end;

    vX # vY + 2;
  UNTIL (vY=0);


  // Update vorhanden???
  if (vUpdate) and (vTodo>0) then begin
    FOR vX # 1 loop inc(vX) WHILE (vX<=vTodo) do begin
      vLen # GetFileSize(aSckCmd, vFile[vX]);
      if (vLen>0) then begin

        vLabel->wpcaption # 'Downloading : '+vFile[vX];

        // Verbindungsinformationen lesen...
        vIPData # 'PASV';
        SckWrite(aSckCmd,_SckLine,vIPData);
        SckRead(aSckCmd,_SckLine,vIPData);

        // Datenkanal öffnen...
        vSckData # Connect(GetIP(vIPData),GetPort(vIPData));
        if (vSckData > 0) then begin
          Command(aSckCmd,'RETR '+vFile[vX]);
          if (SaveFile(vSckData, cPath+vFile[vX], vLen, aDia)= false) then begin
            Display(aSckCmd,'xx');
            DisConnect(vSckData);
            RETURN false;
          end;
          Display(aSckCmd,'xx');
          DisConnect(vSckData);
        end;
      end;

    END;
  end;


  // alles ok?
  if (vUpdate) then begin
    aRes # 'Info:'+vInfo;
    RETURN true;
  end;

  // aber nichts zu machen...
  aRes # 'Kein neues Update verfügbar!';
  RETURN true;
end;


//========================================================================
//  CheckUpdate
//
//========================================================================
sub CheckUpdate(
  aUser : alpha;
  aPass : alpha;
) : logic

local begin
  vSckCommand : int;       // Deskriptor der Kommando-Verbindung
  vSckData    : int;       // Deskriptor der Daten-Verbindung
  vCommand    : alpha(80); // Befehlsvariable
  vDia        : int;
  vHdl,vHdl2  : int;
  vLen        : int;
  vInfo       : alpha(4000);
end;

begin

  vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (vDia=0) then RETURN false;

  vHdl  # Winsearch(vDia,'Label1');
  vHdl2 # Winsearch(vDia,'Progress');
  vHdl2->wpProgressPos # 0;
  vHdl2->wpProgressMax # 100;

  // Verbindung zum FTP-Server aufnehmen
  vHdl->wpcaption # 'Connecting to : '+cSite;
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);
  vSckCommand # Connect(cSite);
  if (vSckCommand < 0) then begin
    vDia->WinClose();
    RETURN false;
  end;

  // Benutzer anmelden
  vHdl->wpcaption # 'Logging in as : '+aUser;
  Command(vSckCommand,'USER '+aUser);
  vHdl->wpcaption # 'Sending password...';
  Command(vSckCommand,'PASS '+aPass);

  // Datenverbindung aufbauen
  vHdl->wpcaption # 'Searching for update...';
  vLen # GetFileSize(vSckCommand, cUpdateFile);
  if (vLen>0) then begin
    if (ProcessUpdate(vSckCommand, vLen, vDia, var vInfo)=false) then begin
      vInfo # '';
    end;
    end
  else begin
    vHdl->wpcaption # 'ERROR : No update found!';
    Winsleep(2000);
  end;

  // Benutzer abmelden
  vHdl->wpcaption # 'Logging out...';
  Command(vSckCommand,'QUIT');

  // Verbindung zum FTP-Server trennen
  vHdl->wpcaption # 'Disconnecting...';
  DisConnect(vSckCommand);

  vDia->WinClose();


  if (vInfo<>'') then begin
    WindialogBox(gFrmMain,'Update',vInfo, _WinIcoWarning,_WinDialogOk,1);
    end
  else begin
    WindialogBox(gFrmMain,'Update','Update abgebrochen!', _WinIcoError,_WinDialogOk,1);
  end;

end;


//******************
main
begin

  if (Set.Update.User<>'') then
    CheckUpdate(Set.Update.User,Set.Update.Pass);

end;


//========================================================================