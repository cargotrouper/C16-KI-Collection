@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Sync_Outlook
//                          OHNE E_R_G
//  Info        Syncroutinen für Outlook
//
//
//  09.01.2014  AH  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_COM_Outlook

define begin
  cKeyProp        : 'StahlControlKey'
  cWofStatusProp  : 'StahlControlWoFStatus'
  cSyncDatumProp  : 'StahlControlSyncDatum'
end

local begin
  gHdlNS  : handle;
  gHdlOL  : handle;
end;

//=========================================================================
//=========================================================================
sub NewCaltime(
  aDat  : date;
  aTim  : time) : caltime;
local begin
  vCT   : caltime;
end;
begin
  if (aDat<>0.0.0) then vCT->vpDate # aDat;
  vCT->vpTime # aTim;
  RETURN vCT;
end;


//=========================================================================
//=========================================================================
sub NewDateTime(
  aCT       : caltime;
  var aDat  : date;
  var aTim  : time);
begin
  aDat # aCT->vpDate;
  aTim # aCT->vpTime;
end;



//========================================================================
//========================================================================
Sub _ReadSyncRec(
  aDatei  : int;
  aKey    : alpha) : logic;
local begin
  vErg    : int;
end;
begin
  Sync.Datei      # aDatei;
  Sync.Key        # aKey;
  Sync.Extern.App # cApplication;
  vErg # RecRead(993,1,0);
  RETURN (vErg<=_rLocked);
end;


//========================================================================
//========================================================================
sub GetUserCalendarID(
  aUser       : alpha;
  var aStore  : alpha) : alpha;
local begin
  vErg    : int;
  v800    : int;
  vFDId   : alpha(500);
end;
begin
  if (aUser=Usr.Username) then begin
    if (Usr.OutlookYN) then begin
      aStore # Usr.OutlookStore1 + Usr.Outlookstore2;
      RETURN Usr.Outlookcalendar;
    end;
    RETURN '';
  end;

  v800 # RecBufCreate(800);
  v800->Usr.Username # aUser;
  vErg # RecRead(v800,1,0)
  if (vErg>_rLocked) or (v800->Usr.OutlookYN=False) or (v800->Usr.Outlookcalendar='') then begin
    RecBufDestroy(v800);
    RETURN '';
  end;
  vFDID # v800->Usr.Outlookcalendar;
  aStore # v800->Usr.OutlookStore1 + v800->Usr.Outlookstore2;
  RecBufDestroy(v800);


  RETURN vFDId;

end;


//=========================================================================
//=========================================================================
sub SetPropAlpha(
  aApp    : int;
  aName   : alpha;
  aValue  : alpha);
local begin
  vProp   : int;
end;
begin
  //  Neues UserProp prophylaktisch anlegen...
  ErrTryCatch(_ErrPropInvalid,y);
  Try begin
    vProp # aApp->ComCall( 'UserProperties.Add', aName, olText, true);
  end;
  ErrTryCatch(_ErrHdlInvalid,n);

  // Prop suchen...
  vProp # aApp->ComCall('UserProperties.Find', aName);
  if (vProp<>0) then  vProp->Comcall('Value', aValue);
end;


//=========================================================================
sub SetPropDT(
  aApp    : int;
  aName   : alpha;
  aValue  : caltime);
local begin
  vProp   : int;
end;
begin
  //  Neues UserProp prophylaktisch anlegen...
  ErrTryCatch(_ErrPropInvalid,y);
  Try begin
    vProp # aApp->ComCall( 'UserProperties.Add', aName, olDatetime, true);
  end;
  ErrTryCatch(_ErrHdlInvalid,n);

  // Prop suchen...
  vProp # aApp->ComCall('UserProperties.Find', aName);
  if (vProp<>0) then  vProp->Comcall('Value', aValue);
end;


//=========================================================================
//=========================================================================
//=========================================================================

//=========================================================================
sub COMopenNSMapi(
) : alpha;
begin

  gHdlOL  # ComOpen( 'Outlook.Application', _comAppCreate );
  if ( gHdlOL = 0 ) then RETURN 'Outlook not found';

  gHdlNS # gHdlOL->ComCall( 'GetNamespace', 'MAPI' );
  if ( gHdlNs = 0 ) then begin
    gHdlNS # 0;
    gHdlOL->ComClose();
    RETURN 'MAPI not found';
  end;

  RETURN '';
end;


//=========================================================================
sub COMOpenFolder(
  aID     : alpha(200);
  aStore  : alpha(500);
  var aFD : handle) : alpha;
local begin
  vErr  : int;
  vA    : alpha(500)
end;
begin
  
  ErrTryCatch(_ErrPropInvalid,y);
  Try begin
    if (aID='') or (aStore='') then
      aFD # gHdlNS->ComCall('GetDefaultFolder', 9)
    else
      aFD # gHdlNS->ComCall( 'GetFolderFromId', aID, aStore );
  end;
  vErr # ErrGet();
  ErrTryCatch(_ErrHdlInvalid,n);
  if (vErr=0) then RETURN '';

  RETURN 'Folder not readable';
end;


//=========================================================================
sub COMAddAppToFolder(
  aFD       : handle;
  var aApp  : handle) : alpha;
local begin
  vErr  : int;
end;
begin
  ErrTryCatch(_ErrPropInvalid,y);
  Try begin
    //aApp   # aFD->cphItems->ComCall( 'Add', 'BCS_Kalender' );
//    aApp   # aFD->cphItems->ComCall( 'Add', 'IPM.Appointment.BCS_Kalender' );
    aApp   # aFD->cphItems->ComCall( 'Add', 'IPM.Appointment.SC_WOF' );
  end;
  vErr # ErrGet();
  ErrTryCatch(_ErrHdlInvalid,n);
  if (vErr>0) then RETURN 'Folder not writeable';
  RETURN '';
end;


//=========================================================================
sub COMGetItemByID(
  aNS       : handle;
  aEntryID  : alpha(500);
  aStoreID  : alpha(500);
  var aItem : handle) : logic;
local begin
  vErr      : int;
end;
begin
  ErrTryCatch(_ErrPropInvalid,y);
  Try begin
    if (aStoreID<>'') then aItem  # aNS->ComCall( 'GetItemFromID', aEntryID, aStoreID )
    else aItem  # aNS->ComCall( 'GetItemFromID', aEntryID);
  end;
  vErr # ErrGet();
  ErrTryCatch(_ErrHdlInvalid,n);
  RETURN vErr=0;
end;


//=========================================================================
sub COMGetItemByBCSKey(
  aNS       : handle;
  aFD       : handle;
  aBCSKey   : alpha;
  var aItem : handle) : alpha;
local begin
  vProp     : handle;
  vItemList : handle;
  vErr      : alpha;
  vI        : int;
  vA        : alpha(200);
end;
begin

  //vItemList # vProp->comCall('Restrict','['+cKeyProp+'] =  "'+aBCSKey+'"')
  //vA # '@SQL="http://schemas.microsoft.com/mapi/string/{00020329-0000-0000-C000-000000000046}/BcsKey/0000001f" = '''+aBCSKey+'''';
  vA # '@SQL="http://schemas.microsoft.com/mapi/string/{00020329-0000-0000-C000-000000000046}/'+cKeyProp+'/0000001f" = '''+aBCSKey+'''';

  vProp # aFd->ComCall( 'Items' );
  
  vItemList # vProp->comCall('Restrict', vA);
  
  if (vItemList=0) then RETURN '';
  if (vItemList->cpiCount=0) then RETURN '';

  aItem # vItemList->ComCall('Item', 1);
end;


//=========================================================================
//=========================================================================
sub COMGetMyEMA() : alpha;
local begin
  vS    : handle;
  vA    : alpha;
end;
begin

  ErrTryCatch(_ErrPropInvalid,y);
  Try begin
    vS # gHdlOL->ComCall( 'Session.CurrentUser.AddressEntry.GetExchangeUser');
    vA # vS->cpaPrimarySmtpAddress;
  end;

  if (vA='') then begin
    ErrTryCatch(_ErrPropInvalid,y);
    Try begin
      vS # gHdlOL->ComCall( 'Session.CurrentUser.AddressEntry');
      vA # vS->cpaAddress;
    end;
  end;

  RETURN strcnv(vA,_Strupper);
end;


//=========================================================================
//=========================================================================
//=========================================================================

//=========================================================================
//=========================================================================
Sub _Push981(
  aFDid       : alpha(500);
  aStore      : alpha(500);
  aKey        : alpha;
  aDel        : logic) : alpha;
local begin
  vNew    : logic;
  vErr    : alpha(500);
  vFD     : handle;
  vApp    : handle;
  vProp   : handle;
  vCT     : caltime;
  vXCT    : caltime;
end;
begin

  if (Sync.Extern.Key='') then vNew # y;
//debugx('open FD:'+aFDid);
  vErr # COMOpenFolder(aFDid, aStore, var vFD);
  if (vErr<>'') then RETURN vErr;
  if (vFD=0) then RETURN 'no folder';

  if (vNew=false) or (aDel) then begin
//debugx('suche:'+sync.extern.key);
    COMGetItemByID(gHdlNS, Sync.Extern.Key, vFD->cpaStoreID, var vApp);
    if (vApp=0) then
      RETURN 'Item in Outlook to sync not found! / Deleted?';
  end;

  if (aDel) then begin
    if (vNew) then RETURN '';
    vApp->ComCall('Delete');
    RETURN '';
  end;


  if (vNew) then begin
    vErr # COMAddAppToFolder(vFD, var vApp);
    if (vErr<>'') then RETURN vErr;
  end;


  vApp->cpaSubject    # Lib_Termine:GetTypeName( TeM.Typ ) + ': ' + TeM.Bezeichnung;
  vApp->cpaBody       # Tem.Bemerkung + Tem.A.Code;
  vApp->cpiBusyStatus # olBusy;
  if (Tem.PrivatYN) then
    vApp->cpiSensitivity  # OlPrivate;

  _ComPropSet(vApp, 'Start',NewCaltime(TeM.Start.Von.Datum, TeM.Start.Von.Zeit));
  if ( TeM.Erledigt.Datum != 0.0.0 ) then
    _ComPropSet(vApp, 'End', NewCaltime(TeM.Erledigt.Datum, TeM.Erledigt.Zeit))
  else if ( TeM.Ende.Von.Datum != 0.0.0 ) then
    _ComPropSet(vApp, 'End', NewCaltime(TeM.Ende.Von.Datum, TeM.Ende.Von.Zeit));


  if (vNew) then begin
    //  Neues UserProp prophylaktisch anlegen...
    ErrTryCatch(_ErrPropInvalid,y);
    Try begin
      vProp # vApp->ComCall( 'UserProperties.Add', cKeyProp, olText, true);
    end;
    ErrTryCatch(_ErrHdlInvalid,n);

    // Prop suchen...
    vProp # vApp->ComCall('UserProperties.Find', cKeyProp);
    if (vProp<>0) then  vProp->Comcall('Value', aKey);
  end;

  vApp->ComCall( 'Save' );
//debug('a) '+cnvac(vApp->cpcLastModificationTime, _FmtCaltimeRFC));

  if (vNew) then Sync.Extern.Key # vApp->cpaEntryID;

  // Reload
  vApp    # 0;
  COMGetItemByID(gHdlNS, Sync.Extern.Key, vFD->cpaStoreID, var vApp);
  vApp->ComCall( 'Save' );
  NewDateTime(vApp->cpcLastModificationTime, var Sync.Datum, var Sync.Zeit);
  vFD # 0;

/***
  if (vApp<>0) then begin
    vApp->cpaSubject    # 'New2';
    vApp->ComCall( 'Save' );

debug('b) '+cnvac(vApp->cpcLastModificationTime, _FmtCaltimeRFC));

vFD     # 0;
vApp    # 0;
gHdlNS  # 0;
gHdlOL->ComClose();
    Winsleep(100);
COMOpenNSMapi();
COMOpenFolder(aFDKey, var vFD);

    COMGetItemByID(gHdlNS, Sync.Extern.Key, vFD->cpaStoreID, var vApp);
    vApp->cpaSubject    # Lib_Termine:GetTypeName( TeM.Typ ) + ': ' + TeM.Bezeichnung;
//    vApp->cpaNormalizedSubject    # Lib_Termine:GetTypeName( TeM.Typ ) + ': ' + TeM.Bezeichnung;
//    _ComPropSet(vApp, 'LastModificationTime' ,NewCaltime(today, now));
vApp->cpaSubject    # vApp->cpaEntryID;
    vApp->ComCall( 'Save' );

vFD     # 0;
vApp    # 0;
gHdlNS  # 0;
gHdlOL->ComClose();
    Winsleep(100);
COMOpenNSMapi();
COMOpenFolder(aFDKey, var vFD);

    COMGetItemByID(gHdlNS, Sync.Extern.Key, vFD->cpaStoreID, var vApp);
    DateTimeFromCaltime(vApp->cpcLastModificationTime, var Sync.Datum, var Sync.Zeit);
vCT # NewCaltime(Sync.datum, sync.Zeit);
//debug('SAVE in '+tem.a.code+'   neue CT:'+cnvac(vCT,_FmtCaltimeRFC));
debug('c) '+cnvac(vApp->cpcLastModificationTime, _FmtCaltimeRFC));

  end;
***/

//  DateTimeFromCaltime(vApp->cpcLastModificationTime, var Sync.Datum, var Sync.Zeit);
//  vFD # 0;

  RETURN '';
end;


//=========================================================================
//=========================================================================
sub Push981(
  aKey    : alpha;
  aFDid   : alpha(500);
  aStore  : alphA(500);
  aDel    : logic) : alpha;
local begin
  vErr  : alpha(500);
end;
begin

  vErr # COMOpenNSMapi();
  if (vErr<>'') then RETURN vErr;

  vErr # _Push981(aFDid, aStore, aKey, aDel);

  gHdlNS  # 0;
  gHdlOL->ComClose();

  RETURN vErr;

end;

//========================================================================
Sub _Pull981(
  aFDID       : alpha(250);
  aStore      : alphA(500);
  var aMod    : logic;
  var aDel    : logic) : alpha;
local begin
  vErr      : alpha(500);
  vFD       : handle;
  vApp      : handle;
  vProp     : handle;
  vA        : alpha(4000);
  vXCT      : caltime;
  vCT       : caltime;
end;
begin

  vErr # COMOpenFolder(aFDid, aStore, var vFD);
  if (vErr<>'') then RETURN vErr;
  if (vFD=0) then RETURN 'no folder';

debugx('A '+sync.extern.key);
  COMGetItemByID(gHdlNS, Sync.Extern.Key, vFD->cpaStoreID, var vApp);
  if (vApp=0) then begin
debugx('B');
    COMGetItemByBCSKey(gHdlNS, vFD, aint(Sync.Datei)+'/'+Sync.Key, var vApp);
    if (vApp=0) then begin
debugx('not found');
      aDel # y;
      RETURN '';
    end;
    Sync.Extern.Key # vApp->cpaEntryID;
    aMod # y;
  end;
debugx('found???');


  vCT   # NewCaltime(Sync.Datum, Sync.Zeit);
  vXCT  # vApp->cpcLastModificationTime;
/*
debug('Pull....');
debug('bcs:'+cnvac(vCT,_FmtCaltimeRFC));
debug(' OL:'+cnvac(vXCT,_FmtCaltimeRFC));
*/

  // Zeiten synchron? -> gut & Ende
  if (aMod=false) and (vCT=vXCT) then RETURN '';


  // Zeit HIER neuer???
  if (vCT>vXCT) then begin
//debugx('CT fehler!!!');
    RETURN 'TimeStamp chaos';
  end;


  vA # vApp->cpaSubject;
  Tem.Bezeichnung # StrAdj(StrCut(Str_Token(vA, ':',2),1,64), _StrBegin|_StrEnd);
  vA # vApp->cpaBody
  Tem.Bemerkung   # StrAdj(StrCut(vA,1,192), _StrBegin|_StrEnd);


  _ComPropGet(vApp, 'Start', vXCT);
   NewDateTime(vXCT, var TeM.Start.Von.Datum, var TeM.Start.Von.Zeit);
  _ComPropGet(vApp, 'End', vXCT);

//  if ( TeM.Erledigt.Datum != 0.0.0 ) then
//    DateTimeFromCaltime(vXCT, var TeM.Erledigt.Datum, var TeM.Erledigt.Zeit)
//  else if ( TeM.Ende.Von.Datum != 0.0.0 ) then
  NewDateTime(vXCT, var TeM.Ende.Von.Datum, var TeM.Ende.Von.Zeit);

/*
  vApp->cpaBody       # Tem.Bemerkung;
  vApp->cpiBusyStatus # olBusy;
//    vHdl->cpiSensitivity  # OlPrivate;
  _ComPropSet(vApp, 'Start',NewCaltime(TeM.Start.Von.Datum, TeM.Start.Von.Zeit));
  if ( TeM.Erledigt.Datum != 0.0.0 ) then
    _ComPropSet(vApp, 'End', NewCaltime(TeM.Erledigt.Datum, TeM.Erledigt.Zeit))
  else if ( TeM.Ende.Von.Datum != 0.0.0 ) then
    _ComPropSet(vApp, 'End', NewCaltime(TeM.Ende.Von.Datum, TeM.Ende.Von.Zeit));


  if (vNew) then begin
    //  Neues UserProp prophylaktisch anlegen...
    ErrTryCatch(_ErrPropInvalid,y);
    Try begin
      vProp # vApp->ComCall( 'UserProperties.Add', cKeyProp, olText, true);
    end;
    ErrTryCatch(_ErrHdlInvalid,n);

    // Prop suchen...
    vProp # vApp->ComCall('UserProperties.Find', cKeyProp);
    if (vProp<>0) then  vProp->Comcall('Value', aBCSKey);
  end;
***/

  NewDateTime(vApp->cpcLastModificationTime, var Sync.Datum, var Sync.Zeit);

  aMod # y;

  RETURN '';
end;


//========================================================================
sub Pull981(
  aFDid     : alpha(250);
  aStore    : alphA(500);
  aKey      : alpha;
  var aMod  : logic;
  var aDel  : logic) : alpha;
local begin
  vErr  : alpha(500);
end;
begin
  aMod # false;
  aDel # false;

  vErr # COMOpenNSMapi();
  if (vErr<>'') then RETURN vErr;

  vErr # _Pull981(aFDid, aStore, var aMod, var aDel);

  gHdlNS  # 0;
  gHdlOL->ComClose();

  RETURN vErr;
end;


//=========================================================================
//=========================================================================
//========================================================================
//========================================================================
Sub Delete981() : logic;
local begin
  vErg    : int;
  vKey    : alpha;
  vErr    : alpha(1000);
  v800    : int;
  vFDid   : alpha(250);
  vStore  : alpha(500);
end;
begin

  if (TeM.A.Datei<>800) then RETURN true;

  vFDid # GetUserCalendarId(TeM.A.Code, var vStore);
  if (vFDid='') then RETURN true;

  vKey  # Lib_Rec:MakeKey(981);

  if (_ReadSyncRec(981, vKey)=false) then RETURN true;
  vErr # Push981(aint(981)+'/'+vKey, vFDid, vStore, true);
  if (vErr<>'') then begin
    Msg(99,vErr,0,0,0);
    RETURN false;
  end;

  RETURN (RecDelete(993,0)=_rOK);

end;


//========================================================================
//========================================================================
Sub Delete980() : logic;
local begin
  vErg    : int;
end;
begin

  // Anker loopen
  FOR vErg # RecLink(981,980,1,_recFirst)
  LOOP vErg # RecLink(981,980,1,_recNext)
  WHILE (verg<=_rLocked) do begin
    if (TeM.A.Datei<>800) then CYCLE; // only USER
    if (Delete981()=false) then RETURN false;
  END;

  RETURN true;
end;


//=========================================================================
sub Sync981(
  aNew        : logic;
  opt aSilent : logic;
  ) : logic;
local begin
  vKey    : alpha;
  vErg    : int;
  vErr    : alpha(1000);
  vFDid   : alpha(500);
  vStore  : alphA(500);
end;
begin

  if (Lib_Termine:GetBasisTyp(TeM.Typ)<>'TER') then RETURN true;
  if (TeM.A.Datei<>800) then RETURN true;

  vFDid # GetUserCalendarID(TeM.A.Code, var vStore);
  if (vFDid='') then RETURN true;

  vKey  # Lib_Rec:MakeKey(981);

  if (aNew=false) then begin
    // gibt keinen aktiven Sync?
    if (_ReadSyncRec(981, vKey)=false) then begin
      aNew # true;
    end
    else begin
      vErg # RecRead(993,1,_recLock);
    end;
  end;

  if (aNew) then begin
    // gibt schon aktiven Sync?
    if (_ReadSyncRec(981, vKey)) then RETURN false;
    RecBufClear(993);
    Sync.Datei      # 981;
    Sync.Key        # vKey;
    Sync.Extern.App # cApplication;
    vErg # RecInsert(993, _recLock);
    if (vErg<>_rOK) then RETURN false;
  end;

//debugx('push nach '+tem.a.code);

  vErr # Push981(aint(981)+'/'+vKey, vFDid, vStore, false);
  if (vErr<>'') then begin
    if (aNew) then RecDelete(993,0);
    if (aSilent=false) then Msg(99,vErr,0,0,0)
    else debugx(vErr);
    RETURN false;
  end;

  vErg # RecReplace(993,_recunlock);
//debugx('replace '+sync.key+' '+cnvat(sync.zeit,_FmtTimeHSeconds)+'    ERG');
  RETURN vErg=_rOK;
end;


//=========================================================================
//=========================================================================
sub Sync980(
  aNew        : logic;
  opt aReSync : logic;
) : logic;
local begin
  Erx : int;
end;
begin
  if (Lib_Termine:GetBasisTyp(TeM.Typ)<>'TER') then RETURN true;

  // Anker loopen
  FOR Erx # RecLink(981,980,1,_recFirst)
  LOOP Erx # RecLink(981,980,1,_recNext)
  WHILE (erx<=_rLocked) do begin
    if (TeM.A.Datei<>800) then CYCLE; // only USER

//debugx('sync '+tem.a.code);
    if (aReSync) then begin
      Sync981(aNew, true);  // SILENT
      end
    else begin
      if (Sync981(aNew, false)=false) then RETURN false;
    end;
  END;

  RETURN true;
end;


//========================================================================
//========================================================================
sub StartSyncJob(
  aDatei  : int;
  aNew    : logic;
  aDel    : logic);
local begin
  Erx     : int;
  vRecID  : int;
  vMode   : alpha;
  vKey    : alpha;
end;
begin

  // ST 2014-09-03: Deaktiviert
  RETURN;

  if (aDatei=980) then vRecID # RecInfo(980,_recID);
  if (aDatei=981) then vRecID # RecInfo(981,_recID);
  if (vRecId=0) then RETURN;

  vMode # 'UPDATE';
  if (aNew) then vMode # 'NEW'
  else if (aDel) then begin

    if (aDatei=980) then begin
        // Anker loopen
      FOR Erx # RecLink(981,980,1,_recFirst)
      LOOP Erx # RecLink(981,980,1,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (TeM.A.Datei<>800) then CYCLE; // only USER
        StartSyncJob(981, aNew, aDel);
      END;

      RETURN;
    end;

    if (aDatei=981) then begin
      vKey  # Lib_Rec:MakeKey(aDatei);
      if (_ReadSyncRec(aDatei, vKey)=false) then RETURN;
      vRecID # RecInfo(993,_recID);
      vMode # 'DELETE|'+TeM.A.Code;
      aDatei  # 993;
    end;
  end;

  RecBufClear(905);
  Job.Aktion        # 'Lib_Sync_Outlook:Job_Sync';
  Job.Parameter   # aint(aDatei)+'|'+aint(vRecID)+'|'+vMode;
  Job.Beschreibung  # 'Aktivität -> Outook';

  Job.Nummer # 10;
  REPEAT
    Job.Start.Datum   # today;
    Job.Start.Zeit    # now;
    Job.Nummer # Job.Nummer + 1;
    Erx # RekInsert(905,0,'AUTO');
  UNTIL (Erx<=_rLocked);

end;


//========================================================================
//========================================================================
sub Job_Sync(aPara : alpha) : logic;
local begin
  Erx     : int;
  vA,vB   : alpha;
  vKey    : alpha;
  vFDid   : alpha(250);
  vErr    : alpha(500);
  vStore  : alpha(500);
end;
begin

  vA # Str_Token(aPara, '|', 1);

  case vA of

    '980' : begin
      vA  # Str_Token(aPara, '|', 2);
      vB  # Str_Token(aPara, '|', 3);
      Erx # RecRead(980,0,_recID, cnvia(vA));
      if (Erx<=_rLocked) then begin
        if (vB='UPDATE') then Sync980(false);
        if (vB='NEW') then Sync980(true);
      end;
    end;


    '981' : begin
      vA  # Str_Token(aPara, '|', 2);
      vB  # Str_Token(aPara, '|', 3);
      Erx # RecRead(981,0,_recID, cnvia(vA));
      if (Erx<=_rLocked) then begin
        Erx # RekLink(980,981,1,_recFirst);   // Termin holen
        if (vB='UPDATE') then Sync981(false);
        if (vB='NEW') then Sync981(true);
      end;
    end;


    '993' : begin
      vA  # Str_Token(aPara, '|', 2);
      vB  # Str_Token(aPara, '|', 3);
      Erx # RecRead(993,0,_recID, cnvia(vA));
      if (Erx<=_rLocked) then begin
        if (vB='DELETE') then begin
          vA  # Str_Token(aPara, '|', 4);
          vFDid # GetUserCalendarId(vA, var vStore);
          if (vFDid='') then RETURN true;

          vErr # Push981(aint(Sync.Datei)+'/'+Sync.Key, vFDid, vStore, true);
          if (vErr<>'') then begin
debugx(vErr);
            RETURN false;
          end;
          RETURN (RecDelete(993,0)=_rOK);
        end;
      end;
    end;

  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub Job_ReSync(aPara : alpha) : logic;
local begin
  Erx       : int;
  vFDId     : alpha(500);
  vKey      : alpha;
  vMod      : logic;
  vDel      : logic;
  vErr      : alpha(1000);
  v993      : int;
  v980      : int;
  vDat      : date;
  vLastCT   : Caltime;
  vLastBuf  : int;
  vBufCount : int;
  vStore    : alpha(500);
end;
begin

//debug('');

  vDat # today;
  vDat->vmDayModify(-7);

  // nach gelöschten suchen...
  RecBufClear(980);
  TeM.Start.Von.Datum # vDat;
  FOR Erx # RecRead(980,3,0)
  LOOP Erx # RecRead(980,3,_recNext)
  WHILE (Erx<_rNorec) and (TeM.Start.Von.Datum>=vDat) do begin

    if (Lib_Termine:GetBasisTyp(TeM.Typ)<>'TER') then CYCLE;


    vBufCount # 0;

    // Anker loopen
    FOR Erx # RecLink(981,980,1,_recFirst)
    LOOP Erx # RecLink(981,980,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (TeM.A.Datei<>800) then CYCLE; // only USER

      vFDId # GetUserCalendarID(TeM.A.Code, var vStore);
      if (vFDId='') then CYCLE;

      vKey  # Lib_Rec:MakeKey(981);

debugx('check sync fuer '+Tem.A.Code);
      // kein Sync aktiv?
      if (_ReadSyncRec(981, vKey)=false) then CYCLE;
debugx('sync eigentlich aktiv...');
//debug('ID:'+vFDid);
      inc(vBufCount);
      vMod # n;
      vDel # n;
      vErr # Pull981(vFDId, vStore, aint(981)+'/'+vKey, var vMod, var vDel);
      if (vErr<>'') then begin
debugx(verr);
        CYCLE;
      end;

      if (vMod) then begin

        if (vLastBuf=0) then begin
          vLastBuf # RekSave(980);
          vLastCT  # NewCalTime(Sync.Datum, Sync.Zeit);
        end
        else begin
          if (vLastCT<NewCalTime(Sync.Datum, Sync.Zeit)) then begin
            RecBufCopy(980, vLastBuf);
            vLastCT  # NewCalTime(Sync.Datum, Sync.Zeit);
          end;
        end;

//debugx('a KEY993');
        Erx # RecRead(993,1,_recLock | _RecNoload);
//debugx('b KEY993');
if (Erx<>_rOK) then debugx('*** fehler Erx');
        Erx # RecReplace(993,_recunlock);
if (Erx<>_rOK) then debugx('**** fehler Erx');
//debug('save sync '+tem.a.code);
//debugx('replace '+sync.key+' '+cnvat(sync.zeit,_FmtTimeHSeconds)+'    Erx');
      end
      else if (vDel) then begin
debug('DELETE ANKER !!!');
        TeM_A_Data:Delete(_recunlock ,'JOB');
      end

    END;  // Anker



    if (vLastBuf<>0) then begin
      RecBufCopy(vLastBuf, 980);
      RecRead(980,1,_recLock | _RecNoload);
      // Dauer errechnen
      TeM_Data:CalcDauer();
      Erx # RekReplace(980,_recunlock,'JOB');
if (Erx<>_rOK) then debugx('*** fehler Erx');

      vLastCT # null;
      RecbufDestroy(vLastbuf)
      vLastBuf # 0;
//debug('RESYNC anzahl:'+aint(vBufCount));
      if (vBufCount>1) then begin
        Sync980(false, true);
      end;
    end;


  END;

  RETURN true;
end;


//=========================================================================
sub _NeuerTermin(
  aUser       : alpha;
  aDat        : date;
  aTim        : time;
  aMins       : float;

  aSubj       : alpha(4000);
  aBody       : alpha(4000);
  aBusy       : int;
  aSens       : int;

  aFolder     : alpha(500);
  aStore      : alphA(500);

  opt aBCSKey : alpha;
  opt aTxt    : int;) : alpha;
local begin
  vErr    : alpha(500);
  vFD     : handle;
  vApp    : handle;
  vProp   : handle;
  vID     : alpha(4000);
  vUpdate : logic;
  vForm   : handle;
  vI      : handle;
  vDT     : caltime;
  vMem    : handle;
  vLen    : int;
end;
begin

  if (aUser<>'') and (aStore='') then begin
    aFolder # GetUserCalendarID(aUser, var aStore); // bekomme STORE1+2
    if (aFolder='') then RETURN 'nixgut';
  end;
  
  
  vErr # COMOpenFolder(aFolder, aStore, var vFD);
  if (vErr<>'') then RETURN vErr;
  if (vFD=0) then RETURN 'no folder';



// 02.07.2019 : EXISTIERT???
  if (aBCSKey<>'') then begin
    COMGetItemByBCSKey(gHdlNS, vFD, aBCSKey, var vApp);
    if (vApp=0) then begin
    end;
  end;
  // sonst NEU
  if (vApp=0) then begin
    vErr # COMAddAppToFolder(vFD, var vApp);
    if (vErr<>'') then RETURN vErr;
  end;



  vApp->cpaSubject    # aSubj;

  if (aTxt<>0) then begin
    vMem # MemAllocate(_Mem64K);
    vLen # Lib_Texte:WriteToMem(aTxt, vMem);
    vApp->cpaHTMLBody       # MemReadStr(vMem, 1, vLen);
    MemFree(vMem);
  end
  else begin
    vApp->cpaBody       # aBody;
    vApp->cpiBodyFormat # 3; // rich text format
  end;
  
  vApp->cpiBusyStatus # aBusy;
  vApp->cpiSensitivity  # aSens;

  _ComPropSet(vApp, 'Start',NewCaltime(aDat, aTim));
  if (aMins>0.0) then begin
    Lib_berechnungen:TerminModify(var aDat, var aTim, aMins);
    _ComPropSet(vApp, 'End', NewCaltime(aDat, aTim));
  end;


  if (aBCSKey<>'') then begin
    SetPropAlpha(vApp, cKeyProp, aBCSKey);
  end;
  SetPropAlpha(vApp, cWofStatusProp, 'offen');
//  SetPropDT(vApp, cSyncDatumProp, vDT);
  
/***17.07.2019
vForm # vApp->cphFormDescription;
if (vForm<>0) then begin
debug('formhdl:'+aint(vForm));
//  vForm->cpaName # 'BCS_Kalender';
vForm->cpaName # 'SC_WOF';
end;
***/


  vApp->ComCall( 'Save' );

  vID # vApp->cpaEntryID;

  // Reload
  vApp    # 0;
  COMGetItemByID(gHdlNS, vID, vFD->cpaStoreID, var vApp);
/***17.07.2019
  vForm # vApp->cphFormDescription;
//vForm->cpaName # 'BCS_Kalender';
vForm->cpaName # 'SC_WOF';
debug('formhdl:'+aint(vForm));
debug('name:'+vForm->cpaName);
debug('cat:'+vForm->cpaCategory);
***/
  NewDateTime(vApp->cpcLastModificationTime, var Sync.Datum, var Sync.Zeit);
  Sync.Extern.Key # StrCut(vID, 1, 250);
  vFD # 0;

  RETURN '';

end;


//=========================================================================
//=========================================================================
sub NeuerTermin(
  aUser       : alpha;
  aDat        : date;
  aTim        : time;
  aMins       : float;

  aSubj       : alpha(4000);
  aBody       : alpha(4000);
  aBusy       : int;
  aSens       : int;

  aFolder     : alpha(500);
  aStore      : alphA(500);

  opt aBCSKey : alpha;
  opt aTxt    : int) : alpha;
local begin
  vErr  : alpha(500);
end;
begin

  vErr # COMOpenNSMapi();
  if (vErr<>'') then RETURN vErr;

  vErr # _NeuerTermin(aUser, aDat, aTim, aMins, aSubj, aBody, aBusy, aSens, aFolder, aStore, aBCSKey, aTxt);

  gHdlNS  # 0;
  gHdlOL->ComClose();

  RETURN vErr;

end;



//=========================================================================
sub _NeueAufgabe(
  aSubj       : alpha(4000);
  aBody       : alpha(4000);
  aRecipent   : alpha;
  opt aBCSKey : alpha) : alpha;
local begin
  vErr    : alpha(500);
//  vFD     : handle;
  vTask   : handle;
  vProp   : handle;
  vDele   : handle;
  vID     : alpha(4000);
  vMyEMA  : alpha;
end;
begin

  vMyEMA # COMGetMyEMA();

  vTask # gHdlOL->ComCall( 'CreateItem', olTaskItem );

  vTask->cpaSubject    # aSubj;
  vTask->cpaBody       # aBody;

  // Enddatum
  vTask->cpcDueDate # NewCalTime(today, now);

  // Status
//  vTask->cpcDateCompleted # vDate;
//  vTask->cpiStatus        # olTaskComplete;
//  vTask->cpiStatus        # olTaskInProgress;
//  vTask->cpiStatus        # olTaskNotStarted;

  _ComPropSet( vTask, 'UnRead', true )



  if (aBCSKey<>'') then begin
    //  Neues UserProp prophylaktisch anlegen...
    ErrTryCatch(_ErrPropInvalid,y);
    Try begin
      vProp # vTask->ComCall( 'UserProperties.Add', cKeyProp, olText, true);
    end;
    ErrTryCatch(_ErrHdlInvalid,n);

    // Prop suchen...
    vProp # vTask->ComCall('UserProperties.Find', cKeyProp);
    if (vProp<>0) then  vProp->Comcall('Value', aBCSKey);
  end;


//  vTask->ComCall( 'Save' );

  vTask->cpaStatusOnCompletionRecipients # '';
  vTask->cplReminderSet # false;
  //.ReminderPlaySound = True
  //.ReminderSoundFile = "C:\Windows\Media\Ding.wav"

  vTask->ComCall('Assign');
  vTask->cpaOwner # aRecipent;
  vDele # vTask->ComCall( 'Recipients.Add', aRecipent);
  vDele->ComCall('Resolve');
  if (vDele->cplResolved=false) then RETURN 'Empfänger '+aRecipent+' unbekannt';

  // an mich selber? -> dann nur speichern OHNE senden!
  if (StrCnv(aRecipent,_Strupper)=vMyEMA) then begin
    vTask->ComCall('Save');
  end
  else begin
    vTask->ComCall('Send');
    // bei MIR löschen
    vTask->ComCall('Delete')
  end;


//  vID   # vTask->cpaEntryID;
//debug('ID:'+vID);
  // Reload
  vTask    # 0;
//  COMGetItemByID(gHdlNS, vID, vSID, var vTask);
//  vTask->ComCall( 'Save' );
//  NewDateTime(vTask->cpcLastModificationTime, var Sync.Datum, var Sync.Zeit);
   Sync.Extern.Key # StrCut(vID, 1, 250);

  RETURN '';

end;

//=========================================================================
//=========================================================================
sub NeueAufgabe(
  aSubj       : alpha(4000);
  aBody       : alpha(4000);
  aRecipent   : alpha;

  opt aBCSKey : alpha) : alpha;
local begin
  vErr  : alpha(500);
end;
begin

  vErr # COMOpenNSMapi();
  if (vErr<>'') then RETURN vErr;

  vErr # _NeueAufgabe(aSubj, aBody, aRecipent, aBCSKey);

  gHdlNS  # 0;
  gHdlOL->ComClose();

  RETURN vErr;

end;

//========================================================================