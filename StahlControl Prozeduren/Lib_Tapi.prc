@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Tapi
//                           OHNE E_R_G
//  Info
//
//
//  19.07.2004  AI  Erstellung der Prozedur
//  05.06.2012  AI  komplett neue TAPI
//  20.01.2015  ST  Tapi Tel Ankererzeugung legt keinen Event mehr an (wäre doppelt)
//  13.09.2016  ST  Integration Snom Tapi
//  30.09.2016  AH  "RememberCall" prüft auf MEldungsfenster
//  14.12.2016  ST  Umbau Benachrichtigungstypen Projekt 1621/75
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//    sub IdentifyNumber(aNummer : alpha;var aName1 : alpha; var aName2 : alpha; var aAkt : alpha; var aNoti : alpha; var aRecID : int; var aIntern : logic; var aNew : logic) : logic;
//    SUB Telefonnummer(aNr : alpha) : alpha;
//    SUB TapiErrorText(aError : int)
//    SUB TapiInitialize();
//    SUB TapiTerm();
//    SUB TapiDialNumber(aNummer : alpha)
//    SUB TapiIncomingMeldung (aText : alpha; opt aData : alpha; opt aDataNr : int; opt aInfo : alpha)
//    SUB TapiIncoming(aType : int; aNummer : alpha);
//
/*
OUTGOING
nix:
ID:66474  state:4   caller:16   called:				        proc
ID:66474  state:10   caller:16   called:			        idle

ich/gegen legt früh auf:
ID:66406  state:4   caller:16   called:				        proc
ID:66406  state:5   caller:16   called:01738938552		ring	bzw busy
ID:66406  state:10   caller:16   called:01738938552		idle

Telefonat + gegen legt auf
ID:66338  state:4   caller:16   called:01738938552		proc
ID:66338  state:5   caller:16   called:01738938552		ring
ID:66338  state:7   caller:16   called:01738938552		connect
ID:66338  state:1   caller:16   called:01738938552		info
ID:66338  state:8   caller:16   called:01738938552		disconnect
ID:66338  state:10   caller:16   called:01738938552		idle

Telefonat + ich lege auf
ID:66304  state:4   caller:16   called:01738938552		proc    (Outb)
ID:66304  state:5   caller:16   called:01738938552		ring    "
ID:66304  state:7   caller:16   called:01738938552		connect "
ID:66304  state:1   caller:16   called:01738938552		info    "
ID:66304  state:10   caller:16   called:01738938552		idle    (-1819)

-------------------------------------------
INCOMING
gegen legt vorher auf.
ID:66286  state:2   caller:01738938552   called:16		offer
ID:66286  state:8   caller:01738938552   called:16		disconnect
ID:66286  state:10   caller:01738938552   called:16		idle

Telefonat + ich lege auf
ID:66184  state:2   caller:01738938552   called:16		offer     (InbX)
ID:66184  state:7   caller:01738938552   called:16		connect   "
ID:66184  state:1   caller:01738938552   called:16		info      "
ID:66184  state:10   caller:01738938552   called:16		idle      "

Telefonat + gegen legt auf
ID:66150  state:2   caller:01738938552   called:16		offer
ID:66150  state:7   caller:01738938552   called:16		connect
ID:66150  state:1   caller:01738938552   called:16		info
ID:66150  state:8   caller:01738938552   called:16		disconnect
ID:66150  state:10   caller:01738938552   called:16		idle

halten:
ID:66474  state:4   caller:16   called:14	proc st
ID:66474  state:5   caller:16   called:14	ring st
ID:66474  state:7   caller:16   called:14	con st
ID:66474  state:1   caller:16   called:14	info st
ID:66474  state:9   caller:16   called:14	HOLD st

	ID:66440  state:4   caller:16   called:		proc
	ID:66440  state:8   caller:16   called:		dis
	ID:66440  state:10   caller:16   called:	idle

	ID:66406  state:4   caller:16   called:12	proc ub
	ID:66406  state:5   caller:16   called:12	ring ub
	ID:66406  state:7   caller:16   called:12	con ub
	ID:66406  state:1   caller:16   called:12	info ub

ID:66474  state:8   caller:16   called:14	dis ST
ID:66474  state:10   caller:16   called:14	idle ST

	ID:66406  state:10   caller:16   called:12	idle ub





_TapiCallOriginInbound          = 1
_TapiCallOriginInboundExternal  = 2
_TapiCallOriginInboundInternal  = 3
_TapiCallOriginOutbound         = 4
_TapiCallOriginUnavail          = 7
_TapiCallOriginUnavailNow       = 6
                                = -1819


*/
//========================================================================
@I:def_Global

declare
  Telefonnummer(aNr : alpha) : alpha;


//========================================================================
//  IdentifiyNumber
//
//========================================================================
sub IdentifyNumber(
  aNummer     : alpha;
  var aName1  : alpha;
  var aName2  : alpha;
//  var aAkt    : alpha;
  var aNoti   : alpha;
  var aDatei  : int;
  var aRecID  : int;
  var aIntern : logic;
  var aNew    : logic) : logic;
local begin
  erx     : int;
  vNummer : alpha;
  vBuf100 : int;
  vBuf102 : int;
  vBuf    : int;
end;
begin

//  vNummer # StrAdj(StrCnv(aNummer,_StrLetter),_strall);
  vNummer # Telefonnummer(aNummer);
  vNummer # StrAdj(StrCnv(vNummer,_StrLetter),_StrAll); // 13.11.2017 AH

  // keine Nummer?
  if (vNummer='') then begin
    aName1  # Translate('unbekannter Anrufer');
    aName2  # Translate('Rufnummer unterdrückt');
    aNoti   # aName2;
    RETURN false;
  end;


  // Intern?
  if (StrLen(vNummer)<=-22) then begin
    aName1  # vNummer;
    aName2  # Translate('interner Anruf');
//    aAkt    # '/999/'+aNummer;
    aDatei  # 999;
    aNoti   # aName2+' '+aName1;
    aIntern # true;
    RETURN false;
  end;


  // zunächst mal unbekannt...
  aName1  # vNummer;
  aName2  # Translate('unbekannter Anrufer');
//    aAkt    # '/999/'+aNummer;
  aDatei  # 999;
  aNoti   # aName2+' ' +aName1;

  RecBufClear(107);
  Adr.Ktd.Daten # vNummer;
  Erx # RecRead(107,7,0);
  if (Erx<>_rNoRec) and (StrAdj(StrCnv(Adr.Ktd.Daten,_StrLetter),_StrAll)=vNummer) then begin
    Erx # Adr_Ktd_Data:ReadLinkedBuf(var aDatei, var vBuf);

    if (Erx<>_rOK) or (aDatei=0) then begin
      // 13.06.2016 AH:
      aNew    # true;
      RecBufDestroy(vBuf);
      RETURN false;
    end;

    // Adresse?
    if (aDatei=100) then begin
      aName1  # vBuf->Adr.Stichwort;
      aName2  # vNummer;
//    aAkt    # '/100/'+aNummer;
      aNoti   # Translate('Anruf')+' '+aName1;
      aRecID  # RecInfo(vBuf,_recId);
    end
    // Ansprechpartner?
    else if (aDatei=102) then begin
      vBuf100 # RecBufCreate(100);
      Erx # RecLink(vBuf100, vBuf,1,0); // Adresse holen

      aName1 # vBuf->Adr.P.Vorname;
      if (aName1<>'') then aName1 # aName1 + ' ';
      aName1  # aName1 + vBuf->Adr.P.Name;
      aName2  # vBuf100->Adr.Stichwort;
//      vName2  # aNummer;
//      aAkt    # '/102/';+aNummer;//+aint(vBuf->Adr.P.Nummer)+'|'+vBuf100->Adr.Stichwort+': '+vBuf->Adr.P.Stichwort;
      aNoti   # Translate('Anruf')+' '+aName2+' '+aName1;
      aRecID  # RecInfo(vBuf,_recId);
      RecBufDestroy(vBuf100);
    end
    // User?
    else if (aDatei=800) then begin
      aName1  # vBuf->Usr.Username;
      aName2  # Translate('interner Anruf');
//    aAkt    # '/999/'+aNummer;
      aNoti   # aName2+' '+aName1;
      aIntern # true;
      aRecID  # RecInfo(vBuf,_recId);
    end
    // Vertreter?
    else if (aDatei=110) then begin
      aName1  # vBuf->Ver.Stichwort;
      aName2  # vNummer;
//    aAkt    # '/110/'+aNummer;
      aNoti   # Translate('Anruf')+' '+aName1;
      aIntern # true;
      aRecID  # RecInfo(vBuf,_recId);
    end
    // Anschrift?
    else if (aDatei=101) then begin
      vBuf100 # RecBufCreate(100);
      Erx # RecLink(vBuf100, vBuf,1,0); // Adresse holen
      aName1 # vBuf->Adr.A.Anrede;
      if (aName1<>'') then aName1 # aName1 + ' ';
      aName1  # aName1 + vBuf->Adr.A.Name;
      aName2  # vBuf100->Adr.Stichwort;
//      aAkt    # '/101/';+aNummer;//+aint(vBuf->Adr.P.Nummer)+'|'+vBuf100->Adr.Stichwort+': '+vBuf->Adr.P.Stichwort;
      aNoti   # Translate('Anruf')+' '+aName2+' '+aName1;
      aIntern # true;
      aRecID  # RecInfo(vBuf,_recId);
      RecBufDestroy(vBuf100);
    end
    RecBufDestroy(vBuf);


    RETURN true;
  end;

  // 13.06.2016 AH:
  aNew # false;

  RETURN false;
end;


/*** ALT

  // Adrese prüfen...
  vBuf100 # RecBufCreate(100);
  vBuf100->Adr.Telefon1 # vNummer;
  Erx # RecRead(vBuf100,7,0);
  if (Erx<>_rNoRec) and (StrCnv(vBuf100->Adr.Telefon1,_StrLetter)=vNummer) then begin
    aDatei  # 100;
    //aRecID  # RecInfo(vBuf100,_recid);
    aBuf # vBuf100;
    RETURN true;
  end;
  vBuf100->Adr.Telefon2 # vNummer;
  Erx # RecRead(vBuf100,8,0);
  if (Erx<>_rNoRec) and (StrCnv(vBuf100->Adr.Telefon2,_StrLetter)=vNummer) then begin
    aDatei  # 100;
    //aRecID  # RecInfo(vBuf100,_recid);
    aBuf # vBuf100;
    RETURN true;
  end;
  RecBufDestroy(vBuf100);


  // Ansprechpartner prüfen...
  vBuf102 # RecBufCreate(102);
  vBuf102->Adr.P.Telefon # vNummer;
  Erx # RecRead(vBuf102,2,0);
  if (Erx<>_rNoRec) and (StrCnv(vBuf102->Adr.P.Telefon,_StrLetter)=vNummer) then begin
    aDatei  # 102;
    //aRecID  # RecInfo(vBuf102,_recid);
    aBuf # vBuf102;
    RETURN true;
  end;
  vBuf102->Adr.P.Mobil # vNummer;
  Erx # RecRead(vBuf102,3,0);
  if (Erx<>_rNoRec) and (StrCnv(vBuf102->Adr.P.Mobil,_StrLetter)=vNummer) then begin
    aDatei  # 102;
    //aRecID  # RecInfo(vBuf102,_recid);
    aBuf # vBuf102;
    RETURN true;
  end;

  RecBufDestroy(vBuf102);
***/

/*x
  // Fenster bereits öffnen?
  if (gDlgTAPI<>0) then begin
    // in Notifier schieben...
    Lib_Notifier:NewEvent( gUserName, vAkt, vNoti, vRecID ); // User, Aktion, Text, Int
    RETURN;
  end;
e
*/


//========================================================================
//========================================================================
sub RememberCall(
  aID     : int;
  aCaller : alpha;
  aCalled : alpha;
  aState  : int;
  aStamp  : Caltime;
);
local begin
  vNr       : alpha;

  vItem     : int;
  vA        : alpha;
  vStartDT  : caltime;

  vWB       : int;
  vHdl      : int;
  vText     : alpha;

  vName1  : alpha;
  vName2  : alpha;
  vNoti   : alpha;
  vDatei  : int;
  vRecID  : int;
  vIntern : logic;
  vNew    : logic;
  vState  : int;
  vOut    : alpha;
end;
begin

  // KEIN Meldungsfesnter?
  if (gMDINotifier=0) then RETURN;


  if (gTAPICalls=0) then
    gTAPICalls # CteOpen(_CteList);

//  if (aCaller='') then RETURN;

  // arbeite?
  if (aState=_TapiCallStateProceeding) then begin
//debug('addcall OUT:'+aCaller+' '+aint(aID));
//    gTAPICalls->CteInsertItem(aint(aID), aState, aCalled+'|'+cnvac( aStamp, _FmtCaltimeRFC));
    RETURN;
  end;

//debug('state:'+aint(aState)+'  caller:'+acaller+'  called:'+aCalled + '   Org:'+aint(TapiCall(aID, _TapiCallOpOrigin))+'   id:'+aint(aID));

  // eingehend neu?
  if (aState=_TapiCallStateOffer) then begin
//debug('addcall IN:'+aCaller+' '+aint(aID));
    gTAPICalls->CteInsertItem(aint(aID), aState, aCaller+'|'+cnvac( aStamp, _FmtCaltimeRFC)+'|N');
    RETURN;
  end;

  // ausgehend neu?
  if (aState=_TapiCallStateRingback) then begin
//debug('addcall OUT:'+aCallED+' '+aint(aID));
    gTAPICalls->CteInsertItem(aint(aID), aState, aCalled+'|'+cnvac( aStamp, _FmtCaltimeRFC)+'|Y');
    RETURN;
  end;



  // Anruf bisher suchen
  vItem # CteRead(gTAPICalls, _cteFirst | _CteSearch , 0, aint(aID));
  if (vItem=0) then begin
//debug('connet, aber kein bisheriges offer!??:'+aCaller+' '+aint(aID));
    if (aState=_TapiCallStateConnected) then begin
//      aState # _TapiCallStateOffer;
      vItem # gTAPICalls->CteInsertItem(aint(aID), aState, aCaller+'|'+cnvac( aStamp, _FmtCaltimeRFC)+'|N');
    end;
    RETURN;
  end;


//debug('found:'+vItem->spcustom);

  vNr     # Str_Token(vItem->spcustom, '|',1);
  vA      # Str_Token(vItem->spcustom, '|',2);
  vOut    # Str_Token(vItem->spcustom, '|',3);
  vState  # vItem->spID;
  vStartDT # cnvca(vA, _FmtCaltimeRFC);


  // Coennected?  -> Startzeit merkken
  if (aState=_TapiCallStateConnected) then begin
    vItem->spcustom # vNr+'|'+cnvac( aStamp, _FmtCaltimeRFC)+'|'+vOut;
    vItem->spid     # aState;
//debug('connect');
    RETURN;
  end;


  // Tel. noch nicht beendet? -> Ende
  if (aState<>_TapiCallStateIdle) then RETURN;


//debug('beendet');


  // Telefonat auswerten
  gTAPICalls->CteDelete(vItem);


//  if (aState=_TapiCallStateRingback) then begin
//  if (vState=_TapiCallStateOffer) or
//     (vState=_TapiCallStateConnected) then begin

    if (IdentifyNumber(vNr, var vName1, var vName2, var vNoti, var vDatei, var vRecid, var vIntern, var vNew)) then begin
      vText # vName1 + ',' + vName2;
    end
    else begin
      vText # 'unbekannt '+vNr;//aCaller;
    end;

    if (vOut='Y') then
      vName1 # 'Out:'+vName1
    else
      vName1 # 'In:'+vName1;

//if (gUsernamE='AH') then  debug(aint(vState)+' '+vName1);
//  end;
// 2->10

  // ausgehnd, nicht erreicht?
  if (vState=_TapiCallStateRingback) then RETURN;


  // verpasster Anruf?
  if (vState<>_TapiCallStateConnected) then begin
    vText # vText + ' um '+aint(vStartDT->vphours)+':'+aint(vStartDT->vpminutes)+':'+aint(vStartDT->vpseconds)+' am '+aint(vStartDT->vpday)+'.'+aint(vStartDT->vpmonth);
    Mdi_Cockpit:AddTapi(vText, today, now);

//    vWB  # VarInfo(WindowBonus);
//    VarInstance(WindowBonus,cnvIA(gMDINotifier->wpcustom));
//    vHdl # gZonelist;
//    VarInstance(WindowBonus, vWB);
//    if (vHdl<>0) then begin
// neues Cockpit      MDI_Cockpit:AddTAPIToZoneList(vHdl, ' Anruf verpasst', vText);
//      MDI_Cockpit:ReBuildZones(gMDINotifier, vHdl);
//      Mdi_Cockpit:AddTapi(vText, today, now);
//    end;
  end
  else begin
  // Anruf ordentlich beendet?
//debug('telefonat geführt:'+vItem->spcustom+' bis '+cnvac(aStamp, _FmtCaltimeRFC));
//debug(vName1+'_'+vname2+'_'+aint(vDatei)+'_'+vNoti);
    Lib_Notifier:NewTermin('TEL', vName1, vName2, true, vStartDT, aStamp);

    // Add User to TEM
    Usr_data:RecReadThisUser();
//    TeM_A_Data:New(800,'MAN', 0, true);
//    if (vDatei=100) then TeM_A_Data:New(vDatei,'MAN', vRecID);
//    if (vDatei=102) then TeM_A_Data:New(vDatei,'MAN', vRecID);
//    if (vDatei=110) then TeM_A_Data:New(vDatei,'MAN', vRecID);
//    if (vDatei=101) then TeM_A_Data:New(vDatei,'MAN', vRecID);

    TeM_A_Data:Anker(800, 'MAN',true); // ST 2015-01-20: neu "true" -> Nicht für den Anker einen Event generieren

    if (vDatei=100) then TeM_A_Data:Anker(vDatei, 'MAN', true, vRecID);
    if (vDatei=102) then TeM_A_Data:Anker(vDatei, 'MAN', true, vRecID);
    if (vDatei=110) then TeM_A_Data:Anker(vDatei, 'MAN', true, vRecID);
    if (vDatei=101) then TeM_A_Data:Anker(vDatei, 'MAN', true, vRecID);

    Lib_Notifier:NewEvent(gUsername, '980', vName1+' '+anum(Tem.Dauer,0)+' min', TeM.Nummer ,today, now, 0);
//    Lib_Notifier:NewEvent( gUserName, 'TAPI'+vAkt, vNoti, vRecID ); // User, Aktion, Text, Int
  end;

  CteClose(vItem);

end;


//========================================================================
//  Telefonnummer
//                korregiert eine Telefonnummer
//========================================================================
sub Telefonnummer(aNr : alpha) : alpha;
local begin
  vA : alpha;
  vAusland : logic;
  vX,vY : int;
end;
begin
  if (StrLen(aNr)<4) then RETURN aNr;

  // Ausland?
  vA # StrCut(aNr,1,2);
  if (vA='00') or (vA='++') then begin
    vAusland # y;
    aNr # StrCut(aNr,3,40);
  end
  else begin
    vA # StrCut(aNr,1,1);
    if (vA='+') then begin
      vAusland # y;
      aNr # StrCut(aNr,2,40);
    end;
  end;

  // geklammerte Vorwahl?
  vx # StrFind(aNr,'(',0);
  vy # StrFind(aNr,')',0);
  if (vX<>0) then begin
    aNr # StrCut(aNr,1,vX-1) + ' ' + StrCut(aNr,vY+1,40);
  end;

  // doppelte Leerzeichen killen
  aNr # Lib_Strings:Strings_ReplaceAll(aNr, '  ', ' ');

  if (vAusland) then
    RETURN '00'+aNr
  else
    RETURN aNr;

end;


//========================================================================
//  TapiErrorText
//            Numerischen Fehlercode in Text umwandeln
//========================================================================
sub TapiErrorText
(
  aError      : int
)
: alpha
begin
  Case (aError) of
    _ErrOk              : return 'Ok';
    _ErrTapiVersion     : return 'Falsche Tapi-Version';
    _ErrTapiDevName     : return 'Ungültiges Tapi-Device';
    _ErrTapiInUse       : return 'Tapi-Device in Benutzung';
    _ErrTapiDialString  : return 'Keine wählbare Nummer';
    _ErrTapiDialTimeout : return 'Keine Antwort von der Tapi-Device';
    _ErrTapiReinit      : return 'Tapi-Konfiguration wurde verändert';
    _ErrTapiMemory      : return 'Kein Speicher';
    _ErrTapiFailed      : return 'Operation nicht erfolgreich';
    _ErrTapiUnavail     : return 'Operation oder Verbingung nicht verfügbar';
    _ErrTapiMediaMode   : return 'Nicht unterstützter Medienmodus';
    _ErrTapiBusy        : return 'Besetzt';
    _ErrTapiBadAddr     : return 'Zieladresse ungültig';
    _ErrTapiNoConnect   : return 'Nicht verbunden';
    _ErrTapiUnknown     : return 'Unbekannter / interner Fehler';
    otherwise             return 'Error (' + CnvAI(aError) + ')';
  end;
end;


//========================================================================
//  TapiInitialize
//                  TAPI starten
//========================================================================
sub TapiInitialize();
begin
  if (Lib_Tapi_Snom:Isdev()) then
    RETURN;

  if (Usr.TapiYN = false) then RETURN;

  TRY begin
    gTAPI # TapiOpen();
  END;

  if (Errget()<>0) then RETURN;

  if (gTAPI<=0) then RETURN;

  FOR gTAPIDev # gTAPI->CteRead(_CteFirst) LOOP gTAPIDev # gTAPI->CteRead(_CteNext, gTAPIDev) WHILE (gTAPIDev>0) do begin
    if ((gTAPIDev->spname)=Set.TAPI.Name) then begin
//        vTmp # gTAPIDev->TapiListen(TRUE,aEvt:obj->WinInfo(_WinFrame));
//      gTAPIDev->TapiListen(true,gFrmMain);
      gTAPIDev->TapiListen(true,gFrmMain);
      RETURN;
    end;
  END;

  gTAPI->TapiClose();
  gTAPIDev  # 0;
  gTAPI     # 0;
end;


//========================================================================
//  TapiTerm
//            Terminiere TAPI
//========================================================================
sub TapiTerm();
begin
  if (Lib_Tapi_Snom:Isdev()) then
    RETURN;


  if (gTAPICalls<>0) then begin
    CteClear(gTAPICalls, y);
    CteClose(gTAPICalls);
    gTAPICalls # 0;
  end;

  if (gTAPI<>0) then gTAPI->TapiClose();
  gTAPI # 0;
end;


//========================================================================
//  TapiDialNumber
//                  wählt eine Telefonnummer
//========================================================================
sub TapiDialNumber(
  aNummer  : alpha
)
: int
begin

  if (Lib_Tapi_Snom:Isdev() = false) AND (gTAPIDev=0) then RETURN 0;

  WHILE (StrCut(aNummer,1,1)='+') do begin
    aNummer # '00'+StrCut(aNummer,2,40);
  END;

  if (Strlen(aNummer)>3) then
    aNummer # Set.TAPI.Prefix+''+aNummer

  aNummer # StrCnv(aNummer,_strLetter);
  aNummer # Lib_Strings:Strings_ReplaceAll(aNummer,' ','');

  if (Lib_Tapi_Snom:Isdev()) then
    RETURN Lib_Tapi_Snom:TapiDialNumber(aNummer);
  else
    RETURN gTAPIDev->TapiDial(aNummer, _TapiAsyncDial, 30000);

end;



//========================================================================
//  TapiIncomingMeldung
//              Anrufsmeldung
//========================================================================
sub TapiIncomingMeldung (
  aCallingNo  : alpha;
)
local begin
  vBuf800     : int;
  vA          : alpha;
  vNr         : int;
  vWB         : int;
  vMitCockpit : logic;

  //
  vName1  : alpha(200);
  vName2  : alpha(200);
  vNoti   : alpha(200);
  vRecId  : int;
  vDatei  : int;
  vNew    : logic;
  vIntern : logic;


end;
begin

  vBuf800               # RecBufCreate( 800 );
  vBuf800->Usr.Username # gUsername;

  if ( RecRead( vBuf800, 1, 0 ) >= _rLocked or !Usr.TapiYN ) then begin
    RecBufDestroy(vBuf800);
    RETURN;
  end;
  RecBufDestroy(vBuf800);


  if (gMDINotifier<>0) then begin
    vWB  # VarInfo(WindowBonus);
    VarInstance(WindowBonus,cnvIA(gMDINotifier->wpcustom));
    vMitCockpit # (gZonelist<>0);
    VarInstance(WindowBonus, vWB);
  end;

  // ST 2016-12-14 Umstellung "Incomming Call" laut Projekt 1621/75
  Lib_Tapi:IdentifyNumber(aCallingNo, var vName1, var vName2, var vNoti, var vDatei, var vRecid, var vIntern, var vNew);

  if (Usr.TapiIncPopUpYN = true) then begin
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

  if (Usr.TapiIncMsgYN) then begin
    // b) Haken "als Meldung" kein "großer" Dailog, sondern Notifier
    // c)  beide Haken, dann MSgBox und Notifier
    if ( vIntern) then
      Lib_Notifier:NewEvent( gUserName, 'TAPI', 'Anruf intern: ' + vName1 );
    else
      Lib_Notifier:NewEvent( gUserName, 'TAPI/' + aCallingNo, 'Anruf: ' + vName1); // 23.11.2017 AH ???? , CnvIa(aCallingNo) );
  end;

  if (Usr.TapiIncPopUpYN = false) AND (Usr.TapiIncMsgYN = false) then begin
    // d)  kein Haken, "großer" Dialog
    // Realisiert in Lib_Tapi:TapiIncoming(...)
  end;
end;


//========================================================================
//  TapiIncoming
//              Anruf annehmen
//========================================================================
sub TapiIncoming(
  aType     : int;
  aCallID   : int;
  aCaller   : alpha;
  aCalled   : alpha;
  aStamp    : caltime);
local begin
  vBuf100 : int;
  vBuf102 : int;
  vInfo   : alpha(200);
  vHdl    : int;
  vDlg    : int;
  vTime   : time;
  vDatei  : int;
  vRecID  : int;
  vBuf800 : int;

end;
begin

/***
15:12:17,90 01738938552  2  offer
15:12:24,50 01738938552  8	disco
15:12:24,70 01738938552  10	idle
aufgegeben
-------------------
15:12:50,88 01738938552  2  offer
15:12:56,38 01738938552  7	connected
15:12:56,38 01738938552  1	info
15:13:06,17 01738938552  10	idle
ich lege auf
---------------------
15:13:32,35 01738938552  2  offer
15:13:33,95 01738938552  7  connected
15:13:33,95 01738938552  1  info
15:13:36,45 01738938552  8  disco
15:13:37,65 01738938552  10	idle
er legt auf
anruf, per button abheben
2 7 1 (10)
***/

// NEUE TAPI?
if (1=1) then begin

  RememberCall(aCallID, aCaller, aCalled, aType, aStamp);

  // neu Eingehend?
  if (aType=_TapiCallStateOffer) then begin
    // 30.11.2016 / Projekt 1621/75 d)
    if ( Usr.TapiIncMsgYN=false ) and (Usr.TapiIncPopUpYN=false) then
      Dlg_TAPI_Incoming:Start(aCaller, aCallID, aStamp);
    else
      TapiIncomingMeldung( aCaller);

    RETURN;
  end
    // Aufgelegt?
  else if (aType=_TapiCallStateDisconnected) or (aType=_TapiCallStateIdle) then begin
    // ggf. Fenster schliessen
    if (gDlgTAPI<>0) then begin
      Dlg_TAPI_Incoming:AnrufToNotifier();
      winclose(gDLGTapi);
      gDlgTAPI # 0;
    end;
    RETURN;
  end
  else if (aType=_TapiCallStateConnected) then begin
    // ggf. Fenster schliessen
    if (gDlgTAPI<>0) then begin
      winclose(gDLGTapi);
      gDlgTAPI # 0;
    end;
  end;
  RETURN;
end;


/**
  switch (aCallState)
  {
    // Anruf-Informationen haben sich geändert
    case _TapiCallStateInfo :
    {
    }

    // regulärer einkommender anruf
    case _TapiCallStateOffer :
      aDataList->WinLstCellSet('Offering'  , 6, tLine);

    case _TapiCallStateProceeding :
      aDataList->WinLstCellSet('Proceeding', 6, tLine);

    case _TapiCallStateRingback :
      aDataList->WinLstCellSet('Ringback', 6, tLine);

    case _TapiCallStateBusy :
      aDataList->WinLstCellSet('Busy', 6, tLine);

    case _TapiCallStateConnected :
      aDataList->WinLstCellSet('Connected', 6, tLine);

    case _TapiCallStateDisconnected :
      aDataList->WinLstCellSet('Disconnected', 6, tLine);

    case _TapiCallStateOnHold :
      aDataList->WinLstCellSet('OnHold', 6, tLine);
  }

  aDataList->wpCurrentInt # tLine;
}
**/


/*** ALT
  if (aType<>_tapicallstateoffer) then RETURN;

  if (StrLen(aNummer)<1) then begin
    TapiIncomingMeldung( aNummer, '*' );
    end
  else if (aNummer='') then begin
    TapiIncomingMeldung( '???' );
    end
  else begin

    vBuf100 # RecBufCreate(100);
    vBuf102 # RecBufCreate(102);

//    if (StrCut(aNummer,1,1)='0') then aNummer # StrCut(aNummer,2,40);

    aNummer                # StrCnv(aNummer,_StrLetter);

    // Adrese prüfen...
    vBuf100->Adr.Telefon1 # aNummer;
    Erx # RecRead(vBuf100,7,0);
    if (Erx<>_rNoRec) and (StrCnv(vBuf100->Adr.Telefon1,_StrLetter)=aNummer) then begin
      vInfo # vBuf100->Adr.Sperrvermerk;
      if (vBuf100->Adr.SperrKundeYN) or (vBuf100->Adr.SperrLieferantYN) then vInfo # Translate('Adresse GESPERRT!')+' '+vInfo;
      TapiIncomingMeldung( vBuf100->Adr.Stichwort, '100', vBuf100->Adr.Nummer, vInfo );
      end
    else begin
      vBuf100->Adr.Telefon2 # aNummer;
      Erx # RecRead(vBuf100,8,0);
      if (Erx<>_rNoRec) and (StrCnv(vBuf100->Adr.Telefon2,_StrLetter)=aNummer) then begin
        vInfo # vBuf100->Adr.Sperrvermerk;
        if (vBuf100->Adr.SperrKundeYN) or (vBuf100->Adr.SperrLieferantYN) then vInfo # Translate('Adresse GESPERRT!')+' '+vInfo;
        TapiIncomingMeldung( vBuf100->Adr.Stichwort, '100', vBuf100->Adr.Nummer,vInfo);
        end
      // Ansprechpartner prüfen...
      else begin
        vBuf102->Adr.P.Telefon # aNummer;
        Erx # RecRead(vBuf102,2,0);
        if (Erx<>_rNoRec) and (StrCnv(vBuf102->Adr.P.Telefon,_StrLetter)=aNummer) then begin
          RecLink(vBuf100,vBuf102,1,_recFirst);   // Adresse holen
          vInfo # vBuf100->Adr.Sperrvermerk;
          if (vBuf100->Adr.SperrKundeYN) or (vBuf100->Adr.SperrLieferantYN) then vInfo # Translate('Adresse GESPERRT!')+' '+vInfo;
          TapiIncomingMeldung(vBuf100->Adr.Stichwort+': '+vBuf102->Adr.P.Stichwort, '102/' + CnvAI( vBuf102->Adr.P.Nummer ), vBuf102->Adr.P.Adressnr, vInfo );
          end
        else begin
          vBuf102->Adr.P.Mobil # aNummer;
          Erx # RecRead(vBuf102,3,0);
          if (Erx<>_rNoRec) and (StrCnv(vBuf102->Adr.P.Mobil,_StrLetter)=aNummer) then begin
            RecLink(vBuf100,vBuf102,1,_recFirst);   // Adresse holen
            vInfo # vBuf100->Adr.Sperrvermerk;
            if (vBuf100->Adr.SperrKundeYN) or (vBuf100->Adr.SperrLieferantYN) then vInfo # Translate('Adresse GESPERRT!')+' '+vInfo;
            TapiIncomingMeldung(vBuf100->Adr.Stichwort+': '+vBuf102->Adr.P.Stichwort, '102/' + CnvAI( vBuf102->Adr.P.Nummer ), vBuf102->Adr.P.Adressnr, vInfo);
            end
          else begin
            TapiIncomingMeldung( aNummer );
          end
        end;
      end;
    end;

    RecBufDestroy(vBuf100);
    RecBufDestroy(vBuf102);
  end;
***/
end;

//========================================================================