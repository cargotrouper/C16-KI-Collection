@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Tapi_Snom
//                  OHNE E_R_G
//  Info    Enthält Funktionen für die IP Telefonie mit Snom Telefonen
//
//
//  13.09.2016  ST  Erstellung der Prozedur
//  14.12.2016  ST  Umbau Benachrichtigungstypen Projekt 1621/75
//
//  Subprozeduren
//    sub isDev() : logic
//    sub getPhoneIP(aUsername : alpha) : alpha
//    sub getPhoneAccessData(aUsername : alpha) : alpha
//    sub SendGetHttpRequest(aHost: alpha;  aUri: alpha(4096); aAuth : alpha(4096)) : int
//    sub TapiDialNumber(aNummer : alpha)
//
//    sub _GetActionForUser(aEvt : alpha; aUsrIp : alpha; var aData : alpha) : logic
//    sub _GetCall(aCallId : alpha ; var aData : alpha) : logic
//    sub _AppendCallInfo(aCallId : alpha ; aDataToAppend : alpha) : logic
//    sub _GetValFromRmtTapiData(aTyp : alpha; aData : alpha(1000)) : alpha
//    sub CloseTapiDlg()
//    sub ServerActionlistDebugItems()
//    sub Protokolliere(aType : alpha; aCallData : alpha(1000); )
//    sub ClientPollTapiActions()
//    sub ServerActionlistAddItem(aEvent: alpha;aCallId : alpha;aFor : alpha;aFrom: alpha; aStamp : caltime; opt aKey : alpha) : logic
//    sub ServerActionlistDelete(aKey : alpha) : logic
//
//
//    Befehle:          http://wiki.snom.com/FAQ/Can_I_control_my_snom_phone_remotely
//    Events mit Args:  http://wiki.snom.com/Category:HowTo:Action_URL
//========================================================================
@I:def_Global

define begin
  cIsDev : (DbaLicense(_DbaSrvLicense)='CD152667MN/H')
  CRLF   : strchar(13)+strchar(10)

  cIncomingCall     : 'IncomingCall'
  cOnConnected      : 'OnConnected'
  cOnDisconnected   : 'OnDisconnected'
  cMissedCall       : 'MissedCall'

  cCalTimeConverterOptions : _FmtCaltimeIso |  _FmtCaltimeDateBlank | _FmtCaltimeTimeHMS
end;


declare ServerActionlistDelete(aKey : alpha) : logic

//========================================================================
//  sub isDev() : logic
//
//========================================================================
sub isDev() : logic
begin
  return cIsDev;
end;


//========================================================================
//  sub getPhoneIP(aUsername) : alpha
//
//    Ermittelt die IP des Telefons
//========================================================================
sub getPhoneIP(aUsername : alpha) : alpha
local begin
  vRet  : alpha;
end;
begin
  vRet # '';

  if (cIsDev) then begin
    case aUsername of
      'AH' : vRet # '192.168.0.200';  //  x
      'UB' : vRet # '192.168.0.201';  //  x
      'TJ' : vRet # '192.168.0.202';  //  x
      'ST' : vRet # '192.168.0.203';  //  x
      'TM' : vRet # '192.168.0.204';  //  x
      'MR' : vRet # '192.168.0.205';  //  x
      //                       210   // Zentrale
    end;
  end else begin
    todo('Telefon IP über Benutzernamen lesen');
  end;

  RETURN vRet;
end;

//========================================================================
//  sub getPhoneAccessData(aUsername : alpha) : alpha
//
//    Gibt die Benuterdaten für die HTTP Telefonie zurück
//========================================================================
sub getPhoneAccessData(aUsername : alpha) : alpha
local begin
  vRet  : alpha;
end;
begin
  if (cIsDev) then
    vRet # 'admin:Ares3Ares';
  else
    todo('Benutzername und Passwort für IP Telefon lesen');

  RETURN vRet;
end;



//========================================================================
//  sub getPhoneUserAuth(aUsername : alpha) : alpha
//
//    Gibt Username und Passwort als Base64 codierten String zurück
//========================================================================
sub getPhoneUserAuth(aUsername : alpha) : alpha
local begin
  vRet  : alpha;
end;
begin
  vRet # '';

  if (cIsDev) then begin
    vRet # Lib_Http:CnvUserPass('admin','Ares3Ares');
  end else begin
    todo('Telefon IP über Benutzernamen lesen');
  end;

  RETURN vRet;
end;



//========================================================================
//  SendGetHttpRequest
//    Sendet einen HTTP Request an den angegebenen Server, gibt den
//    HTTP Request Code zurück und ändert die per Referenz übergebenen
//    Werte
//========================================================================
sub SendGetHttpRequest(
  aHost       : alpha;
  aUri        : alpha(4096);
  aAuth       : alpha(4096)
) : int
local begin
  Erx         : int;
  vConn      : int;
  vHeader    : alpha(4096);
  vReadBytes : int;
  vLine      : alpha;
  vStatus    : int;
  vLength    : int;
end;
begin

  // Verbindung zum Server aufnehmen
  vConn # Lib_HTTP:Connect(aHost);
  if (vConn < 0) then
    RETURN -500;

  // Header aufbauen
  vHeader # 'GET '+ aUri + ' HTTP/1.1'  + CRLF +
            'Host: '+aHost              + CRLF +
            'Connection: keep-alive'    + CRLF;
  // ggf. Authorisierung beachten
  if (aAuth <> '') then
    vHeader # vHeader + 'Authorization: Basic '+ aAuth + CRLF;

  // WICHTIG!!!! Leerzeile mitsenden, Trennt Header vom Body
  vHeader # vHeader +  CRLF+CRLF;

  // Header zum Server schicken
  Erx # SckWrite(vConn,_SckLine,vHeader);
  SckClose(vConn);

  if (Erx < 0) then
    RETURN Erx
  else
    RETURN 0;
end; // SendGetHttpRequest


//========================================================================
//  TapiDialNumber
//                  wählt eine Telefonnummer
//========================================================================
sub TapiDialNumber(aNummer  : alpha) : int
local begin
  Erx       : int;
  vPhoneIP  : alpha;
  vHTTPConn : int;
  vReqLen   : int;
  vCommandUrl : alpha;
end
begin

  vPhoneIP  #  getPhoneIP(gUsername);
  if (vPhoneIP = '') then begin
    todo('Kein IP Telefon zugeordnet');
    RETURN 0;
  end;

  vCommandUrl # '/command.htm?number=' + aNummer;
  Erx # SendGetHttpRequest(vPhoneIP, vCommandUrl, getPhoneUserAuth(gUsername));
  if (Erx < 0) then
    todo('ERROR ' + Aint(Erx));
end;


//========================================================================
//  TapiAnnehmen
//    Nimmt ein ankommendes Gespräch an
//========================================================================
sub TapiAnnehmen() : int
local begin
  Erx       : int;
  vPhoneIP  :  alpha;
  vHTTPConn :  int;
  vReqLen   :  int;
  vCommandUrl : alpha;
end
begin

  vPhoneIP  #  getPhoneIP(gUsername);
  if (vPhoneIP = '') then begin
    todo('Kein IP Telefon zugeordnet');
    RETURN 0;
  end;

  vCommandUrl # '/command.htm?key=OFFHOOK';
  Erx # SendGetHttpRequest(vPhoneIP, vCommandUrl, getPhoneUserAuth(gUsername));
  if (Erx < 0) then
    todo('ERROR ' + Aint(Erx));
end;




//========================================================================
//  sub _GetActionForUser(aEvt : alpha; aUsrIp : alpha; var aData : alpha) : logic
//        Liest einen CallEvent Eintrag für einen User
//========================================================================
sub _GetActionForUser(aEvt : alpha; aUsrIp : alpha; var aData : alpha) : logic
local begin
  Erx : int;
end;
begin
  Erx # RmtDataRead(aEvt+':'+aUsrIp,0, var aData);
  ServerActionlistDelete(aEvt+':'+aUsrIp);
  RETURN (Erx = _rOK);
end;

//========================================================================
//  sub _GetCall(aCallId : alpha ; var aData : alpha) : logic
//        Liest einen Call Eintrag
//========================================================================
sub _GetCall(aCallId : alpha ; var aData : alpha) : logic
local begin
  Erx     : int;
  vRmtKey : alpha(1000);
  vRmtVal : alpha(1000);
end begin

/*
  // Funktioniert nicht
  Erx # RmtDataRead(aCallId,0, var aData);
*/
  // Manuell suchen
  aData  # '';
  FOR   vRmtKey # RmtDataSearch('', _RecFirst)
  LOOP  vRmtKey # RmtDataSearch(vRmtKey,_RecNext)
  WHILE vRmtKey <> '' DO BEGIN

    Erx # RmtDataRead(vRmtKey, 0, var vRmtVal);
    if (vRmtKEy = aCallId) then begin
      aData # vRmtVal;
      BREAK;
    end;
  END;


  RETURN (aData = '');
end;


//========================================================================
//  sub _AppendCallInfo(aCallId : alpha ; aDataToAppend : alpha) : logic
//        Hängt einem CallEintrag ein weiteres Token an
//========================================================================
sub _AppendCallInfo(aCallId : alpha ; aDataToAppend : alpha) : logic
local begin
  Erx   : int;
  vData : alpha(1000);
end
begin

  Erx # RmtDataRead(aCallId,0, var vData);
  if (Erx <> _rOK) then
    debug('Fehler beim sperren');

  Erx # RmtDataWrite(aCallId, 0, vData+'|'+aDataToAppend);
  if (Erx <> _rOK) then
    debug('Fehler beim Speichern');

  RETURN (Erx = _rOK);
end;



//========================================================================
//  sub _GetValFromRmtTapiData(aTyp : alpha; aData : alpha(1000)) : alpha
//        Extahiert den gewünschten Token aus dem RemoteDatenObjekt
//========================================================================
sub _GetValFromRmtTapiData(aTyp : alpha; aData : alpha(1000)) : alpha
local begin
  vPos : int;
  vRet  : alpha;
end;
begin
  case aTyp of
    'action'    : vPos # 1;
    'call_id'   : vPos # 2;
    'phone_ip'  : vPos # 3;
    'remote'    : vPos # 4;
    'stamp'     : vPos # 5;
    'start'     : vPos # 6;
    'end'       : vPos # 7;
  end

  vRet # Str_Token(aData,'|',vPos);
  vRet # Lib_Strings:Strings_ReplaceAll(vRet,'START:','');
  vRet # Lib_Strings:Strings_ReplaceAll(vRet,'END:','');

  RETURN vRet;
end;


//========================================================================
//  sub CloseTapiDlg()
//        Schließt die Tapimaske
//========================================================================
sub CloseTapiDlg() begin
  if (gDlgTAPI<>0) then begin
    winclose(gDLGTapi);
    gDlgTAPI # 0;
  end;
end;


//========================================================================
//  sub Protokolliere(aType : alpha; aCallData : alpha(1000); )
//    Nimmt die angefallenen Telefondaten und verarbeitet diese
//    in Stahl Control weiter z.B. Notfiert aktualisieren, Cockpit etc.
//========================================================================
sub Protokolliere(aType : alpha; aCallData : alpha(1000); )
local begin
  // Missed Call -> Cockpit
  vWinBonus : int;
  vHdl      : int;

  // Disconnect ->
  vAnrufernr  : alpha;
  vName1  : alpha;
  vName2  : alpha;
  vNoti   : alpha;
  vDatei  : int;
  vRecID  : int;
  vIntern : logic;
  vNew    : logic;
  vText   : alpha;

  vStart, vEnd : alpha;
  vStartTime : caltime;
  vEndTime   : caltime;
end
begin

  if (aType= cOnConnected) then begin
    Dlg_TAPI_Incoming:AnrufToNotifier();
  end;



  if (aType = cMissedCall) then begin
    // Nachricht ins Cockpit
    vWinBonus   # VarInfo(WindowBonus);
    VarInstance(WindowBonus,cnvIA(gMDINotifier->wpcustom));
    vHdl # gZonelist;
    VarInstance(WindowBonus, vWinBonus );
    if (vHdl<>0) then
      Mdi_Cockpit:AddTapi('Anruf Verpasst', today, now);
  end;


  if (aType= cOnDisconnected) then begin

    vAnrufernr  # _GetValFromRmtTapiData('remote', aCallData);

    if (Lib_Tapi:IdentifyNumber(vAnrufernr,var vName1, var vName2, var vNoti, var vDatei, var vRecid, var vIntern, var vNew)) then
      vText # vName1 + ',' + vName2;
    else
      vText # 'unbekannt '+vAnrufernr;

    vStart # _GetValFromRmtTapiData('start', aCallData);
    vEnd  # _GetValFromRmtTapiData('end', aCallData);

    if (vStart <> '') AND (vEnd <> '')then begin
      vStartTime->vpDate # CnvDa(Str_Token(vStart,' ',1),_FmtDateYMD);
      vStartTime->vpTime # CnvTa(Str_Token(vStart,' ',2),_FmtNone);

      vEndTime->vpDate # CnvDa(Str_Token(vEnd,' ',1),_FmtDateYMD);
      vEndTime->vpTime # CnvTa(Str_Token(vEnd,' ',2),_FmtNone);
      
      // ST 2018-08-10: Wenn ein Gespräch unter einer Minute ist, dann
      //                 "künstlich" um eine Minute verlängern.
      if (vEndTime->vpDate    = vStartTime->vpDate)   AND
         (vEndTime->vpHours   = vStartTime->vpHours)  AND
         (vEndTime->vpMinutes = vStartTime->vpMinutes) then begin
          
          vEndTime->vmSecondsModify(60);
      end;
      
    end;
    Lib_Notifier:NewTermin('TEL',vName1, vName2, true, vStartTime, vEndTime);

    // Add User to TEM
    Usr_data:RecReadThisUser();
    TeM_A_Data:Anker(800, 'MAN',true);

    if (vDatei=100) then TeM_A_Data:Anker(vDatei, 'MAN', true, vRecID);
    if (vDatei=102) then TeM_A_Data:Anker(vDatei, 'MAN', true, vRecID);
    if (vDatei=110) then TeM_A_Data:Anker(vDatei, 'MAN', true, vRecID);
    if (vDatei=101) then TeM_A_Data:Anker(vDatei, 'MAN', true, vRecID);

    Lib_Notifier:NewEvent(gUsername, '980', vName1+' '+anum(Tem.Dauer,0)+' min', TeM.Nummer ,today, now, 0);
  end;

end;



//========================================================================
//  sub ClientPollTapiActions()
//      Pollt aus der App_Main Timer gegen den Server
//========================================================================
sub ClientPollTapiActions()
local begin
  vUserIP : alpha;
  vRmtData : alpha(1000);

  vCallId : alpha;
  vStamp  : alpha;
  vCaller : alpha;

  // ---------
    //
  vName1  : alpha(200);
  vName2  : alpha(200);
  vNoti   : alpha(200);
  vRecId  : int;
  vDatei  : int;
  vNew    : logic;
  vIntern : logic;
  vNR     : int;

end
begin

  vUserIP # getPhoneIP(gUsername);

  // ------------------------------------------------------------------
  // Eingehendes Telefonat:
  if (_GetActionForUser(cIncomingCall,vUserIp, var vRmtData)) then begin


    if ( Usr.TapiIncMsgYN=false ) and (Usr.TapiIncPopUpYN=false) then begin
       // Tapi Maske anzeigen
      Dlg_TAPI_Incoming:StartSnom(_GetValFromRmtTapiData('remote',      vRmtData),
                                  _GetValFromRmtTapiData('call_id',     vRmtData),
                                  CnvCa(_GetValFromRmtTapiData('stamp', vRmtData),cCalTimeConverterOptions));

      RETURN;
    end;

    if (Usr.TapiIncPopUpYN = true) then begin
      Lib_Tapi:IdentifyNumber(_GetValFromRmtTapiData('remote', vRmtData),var vName1, var vName2, var vNoti, var vDatei, var vRecid, var vIntern, var vNew);
      // a)  Haken "als Popup", kein "großer" Dialog (wie BCS), sondern MsgBox
      // c)  beide Haken, dann MSgBox und Notifier
      if (vIntern) then
        vNr # 998001
      else
        vNr # 998002;

      if (vName2='') then
        Msg(vNr, vName1, 0, 0, 0 )
      else
        Msg(vNr, vName1+StrChar(13)+vName2, 0, 0, 0 )

    end;


  end;


  // ------------------------------------------------------------------
  // Telefonat angenommen
  if (_GetActionForUser(cOnConnected,vUserIp, var vRmtData)) then begin

    // ---------------------------------------------------------------
    // Eindeutigen Call suchen und echte, abgehobene Startzeit
    //  an Call anhängen

    // Daten extrahieren
    vCallId # _GetValFromRmtTapiData('call_id', vRmtData);
    vStamp  # _GetValFromRmtTapiData('stamp', vRmtData);

    _AppendCallInfo(vCallId,'START:'+vStamp);
    _GetCall(vCallId, var vRmtData);  // Geänderten Call erneut lesen

    CloseTapiDlg();

    Protokolliere(cOnConnected, vRmtData);
  end;


  // ------------------------------------------------------------------
  // Telefonat Verpasst
  if (_GetActionForUser(cMissedCall,vUserIp, var vRmtData)) then begin
    Protokolliere(cMissedCall,vRmtData);
  end;


  // ------------------------------------------------------------------
  //  Telefonat beendet
  if (_GetActionForUser(cOnDisconnected,vUserIp, var vRmtData)) then begin
    CloseTapiDlg();

    // Daten aus der Beendigung des Telefonates extrahieren
    vCallId # _GetValFromRmtTapiData('call_id', vRmtData);  // CallId Auslesen
    vStamp  # _GetValFromRmtTapiData('stamp', vRmtData);

    // Telefonat suchen und Daten für Notifier, Tems, etc. Aktualisieren
    vRmtData # '';
    _AppendCallInfo(vCallId,'END:'+vStamp);

    vRmtData # '';
    _GetCall(vCallId, var vRmtData);

    // Telefonat aus der Serverliste entfernen
    ServerActionlistDelete(vCallId);

    // vRmtData hat jetzt alle Relevanten Daten:
    //  - Ursprünglicher Anrufer    "remote"
    //  - Ursprüngliche Anrufnummer "phone_ip"
    //  - Startzeit                 "start"
    //  - Endzeit                   "end"
    Protokolliere(cOnDisconnected,vRmtData);

  end;


end;



//========================================================================
//  sub ServerActionlistAddItem(...)
//
//    Fügt eine neue Aktion in die ServerActionlist ein
//========================================================================
sub ServerActionlistAddItem(
  aEvent  : alpha;
  aCallId : alpha;
  aFor    : alpha;
  aFrom   : alpha;
  aStamp  : caltime;
  opt aKey : alpha) : logic
local begin
  vKey    : alpha;
  vValue  : alpha(1000);
end
begin
  // Die Serveraktionsliste
  if (aKey = '') then
    vKey    # aEvent + ':' + aFor;
  else
    vKey   # aKey;

  vValue  # aEvent + '|'  +
            aCallID + '|' +
            aFor    + '|' +
            aFrom   + '|' +
            CnvAc(aStamp, cCalTimeConverterOptions);

  if (RmtDataWrite(vKey,_RecUnlock, vValue) <> _rOK) then
    RETURN false
  else
    RETURN true;
end;


//========================================================================
//  sub ServerActionlistAddItem2(...)
//
//    Fügt eine neue Aktion in die ServerActionlist ein
//========================================================================
sub ServerActionlistAddItem2(
  aKey : alpha;
  aData : alpha) : logic
local begin
  vKey    : alpha;
  vValue  : alpha(1000);
end
begin
  // Die Serveraktionsliste
  if (RmtDataWrite(aKey,_RecUnlock, aData) <> _rOK) then
    RETURN false
  else
    RETURN true;
end;


//========================================================================
//  sub ServerActionlistDelete(aKey : alpha) : logic
//
//    Löscht einen Eintrag aus der Serverliste
//========================================================================
sub ServerActionlistDelete(aKey : alpha) : logic
begin
  if (RmtDataWrite(aKey,_RecUnlock, '') <> _rOK) then
    RETURN false
  else
    RETURN true;
end;



//========================================================================
//  sub ServerActionlistDebugItems()
//        Gibt den Inhalt der Remotedaten ins Debugfile aus
//========================================================================
sub ServerActionlistDebugItems()
local begin
  Erx     : int;
  vRmtKey : alpha(1000);
  vRmtVal : alpha(1000);
end;
begin
  debug('----------------------------------------------------');
  lib_soa:dbg('----------------------------------------------------');

  FOR   vRmtKey # RmtDataSearch('', _RecFirst)
  LOOP  vRmtKey # RmtDataSearch(vRmtKey,_RecNext)
  WHILE vRmtKey <> '' DO BEGIN
    Erx # RmtDataRead(vRmtKey, 0, var vRmtVal);
    debug(vRmtKey + ' = "' + vRmtVal+'"');
    lib_soa:dbg(vRmtKey + ' = "' + vRmtVal+'"');
  END;

end;



//========================================================================
//  sub ServerActionlistClear()
//        Löscht alle SNOM Calls im Serverspeicher
//========================================================================
sub ServerActionlistClear()
local begin
  Erx     : int;
  vRmtKey : alpha(1000);
  vRmtVal : alpha(1000);
end;
begin
  FOR   vRmtKey # RmtDataSearch('', _RecFirst)
  LOOP  vRmtKey # RmtDataSearch(vRmtKey,_RecNext)
  WHILE vRmtKey <> '' DO BEGIN

    Erx # RmtDataRead(vRmtKey, 0, var vRmtVal);
    if (StrFind(vRmtVal,'|',1) > 0) then begin
      if (RmtDataWrite(vRmtKey,_RecUnlock, '') = _rOK) then
        lib_soa:dbg(vRmtKey + ' deleted');
      else
        lib_soa:dbg(vRmtKey + ' FAILED TO DELETE');
    end;

  END;

end;




//========================================================================
