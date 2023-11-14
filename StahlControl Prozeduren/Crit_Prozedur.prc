@A+
//===== Business-Control =================================================
//
//  Prozedur    Crit_Procedur
//                OHNE E_R_G
//  Info
//
//
//  19.01.2012  AI  Erstellung der Prozedur
//  10.06.2016  AH  FirstSync NIEMALS bei SoaSync
//  01.03.2017  AH  AsyncDialog im TRY
//  28.08.2018  AH  "Set.Crit.AktivYN" wird hier geprüft
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//    sub _IsActive()  : alpha;
//    sub _RecalcStarTermin() : logic;
//    sub _CheckTime() : logic;
//    sub _DisplayPause(aText : alpha);
//    sub Manage();
//
//========================================================================
@I:Def_Global


//========================================================================
//  IsActive
//
//========================================================================
sub _IsActive()  : alpha;
local begin
  vID     : int;
  vErg    : int;
  vA      : alpha;
end;
begin

  if (RmtDataRead('!CRITICAL', _recunlock, var vA)>_rLocked) then RETURN '';
//  if (vA=UserInfo(_UserCurrent)) then RETURN '';
//debugx(vA);
//  if (UserInfo(_Username, cnvia(vA))='') then debugx('???');
  RETURN vA;

/*** 01.07.2016
  RecRead(903,1,_recFirst);
  // kein andere Session damit beschätigt?
  if (Set.Crit.UsedSession=0) or (Set.Crit.UsedSession=cnvia(UserInfo(_UserCurrent))) then begin
    RETURN false;
  end;
  // Ist die fremde Session noch aktiv?
  FOR   vID # CnvIa(UserInfo(_UserNextId))
  LOOP  vID # CnvIa(UserInfo(_UserNextId,vID))
  WHILE (vID > 0) DO BEGIN
    if (vID=Set.Crit.UsedSession) then begin
      RETURN true;
    end;
  END;

  // Session existiert nicht mehr? -> dann freigeben
  RecRead(903,1,_recLock);
  Set.Crit.UsedSession # 0;
  vErg # RecReplace(903,_recunlock);
  if (vErg<>_rOK) then begin
    RETURN true;
  end;

//todo('Session veraltet!');
  RETURN false;
***/
end;


//========================================================================
//========================================================================
sub _CritStarted(aMitDatum : logic) : logic;
local begin
  vErg  : int;
end;
begin
/*** 01.07.2016
  RecRead(903,1,_recLock);
  if (aMitDAtum) then begin
    Set.Crit.LetztesDat # today;
    Set.Crit.LetzteZeit # now;
  end;
//  Set.Crit.UsedSession  # cnvia(UserInfo(_UserCurrent));
  vErg # RecReplace(903,_recunlock);
***/
  // 01.07.2016
  RmtDataWrite('!CRITICAL', _recunlock | _RmtDataTemp, UserInfo(_UserCurrent));

  RETURN (vErg=_rOK)
end;


//========================================================================
//========================================================================
sub _CritStopped() : logic;
local begin
  vErg  : int;
end
begin
/*** 01.07.2016
  RecRead(903,1,_recLock);
//  Set.Crit.UsedSession  # 0;
  Set.Crit.LastError    # '';
  vErg # RecReplace(903,_recunlock);
  RETURN (vErg=_rOK);
***/

  // 01.07.2016
  RmtDataWrite('!CRITICAL', _recunlock | _RmtDataTemp, '');
  RETURN true;
end;


//========================================================================
//  _CheckTime
//
//========================================================================
sub _CheckTime() : logic;
local begin
  vErg  : int;
  vErr  : alpha;
  vOK   : logic;
  v903  : int;
end;
begin

// nur noch manuell!!!
//  if (Set.Ost.Wie<>'') then begin
//    if (RecInfo(892,_reccount)+RecInfo(891,_reccount)=0) then OSt_Data:Initialize(true);
//  end;

  // 28.08.2018 AH:
  // 01.10.2020 AH: Setting heisst "INaktiv"
  if (Set.Crit.InAktivYN) then RETURN true;


  REPEAT
    v903 # RecBufCreate(903);
    if (RecRead(v903,1,_recfirst)<=_rLocked) then begin
      Set.Crit.Start.Datum # v903->Set.Crit.Start.Datum;
      Set.Crit.Start.Zeit  # v903->Set.Crit.Start.Zeit;
    end;
    RecBufDestroy(v903);

    if (Set.Crit.Start.Datum>today) then RETURN true;
    if (Set.Crit.Start.Datum=today) and (Set.Crit.Start.Zeit>now) then RETURN true;

    if (Set.Crit.Start.Datum=0.0.0) then begin
      Set.Crit.Start.Datum  # today;
      Set.Crit.Start.Zeit   # 0:0;
      if (Call(Set.Crit.Prozedur+':RecalcStartTermin')=false) then RETURN false;
      RETURN _CheckTime();
    end;


    // START vermerken
    if (_CritStarted(true)=false) then RETURN false;

    TRANSON;

    // Prozedur starten -------------------------------------------------
    vErr # Call(Set.Crit.Prozedur+':Start');
    // Prozedur starten -------------------------------------------------
    if (vErr<>'') then begin
// 01.07.2016     RecRead(903,1,_recLock);
//      Set.Crit.LastError # vErr;
//      vErg # RecReplace(903,_recunlock);
      TRANSBRK;
      RETURN false;
    end;

    // ENDE vermerken...
    if (_CritStopped()=false) then begin
      TRANSBRK;
      RETURN false;
    end;

    // neue Startzeit ermitteln
    vOK # Call(Set.Crit.Prozedur+':RecalcStartTermin');
    if (vOK=false) then begin
      TRANSBRK;
      RETURN false;
    end;

    TRANSOFF;

  UNTIL (Set.Crit.Start.Datum>today);


  RETURN true;
end;


//========================================================================
//  DisplayPause
//
//========================================================================
sub _DisplayPause(aText : alpha);
local begin
  vDia      : int;
  vMsg      : int;
  vMDI      : int;
  vSearch   : int;
  vGlobal   : int;
  vFocus    : int;
end;
begin

  vGlobal # VarInfo(Windowbonus);
  vMDI    # gMDI;
  vSearch # WinSearchPathGet();
  vFocus  # WinFocusGet();

  vDia # WinOpen('Dlg.Pause',_WinOpenDialog);
  vMsg # Winsearch(vDia,'Label1');
  vMsg->wpcaption # aText;
  // 01.03.2017 AH
  if (vDia<>0) then begin
    try begin
      ErrTryCatch(_ErrHdlInvalid, y);
      vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenterScreen);//, gFrmMain);
      winsleep(2000);
      WHILE (_IsActive()<>'') DO BEGIN
        Winsleep(1000);
      END;
    end;
    if (errget() = _errHdlInvalid) then begin
      vDia # 0;
    end;
  end;
  if (vDia=0) then begin
    WHILE (TransCount>0) do
      TRANSBRK;
    Msg(99,'KRITISCHE WARTUNGEN ERFORDERN NEUSTART!',0,0,0);
    App_Extras:HardLogout();
    RETURN;
  end;

  Winclose(vDia);


  if (vMDI<>0) then
    WinUpdate(vMDI,_WinUpdActivate);

  if (vGlobal<>0) then
    VarInstance(WindowBonus,vGlobal);

//  if (vMDI<>0) then begin
//    if (vMDI->wpcustom<>'') and (vMDI->wpcustom<>cnvai(VarInfo(WindowBonus))) then
//      VarInstance(WindowBonus,cnvIA(vMDI->wpcustom));
//    gMDI # vMDI;
//    Winsearchpath(gMDI);
  if (vSearch<>0) then
    WinSearchPAth(vSearch);

  if (vFocus<>0) then
    WinFocusset(vFocus);

end;


//========================================================================
//========================================================================
sub PauseBeiBedarf();
local begin
  vSess : alpha;
end;
begin

  if (gUsergroup='JOB-SERVER') OR (gUsergroup='SOA_SERVER') then RETURN;

  vSess # _isActive();
  // 01.08.2016 AH : NUR WENN ICH ES NICHT SELBER BIN
  if (vSess<>'') and (vSess<>UserInfo(_UserCurrent)) then begin
    _DisplayPause(Translate('Kritische Wartungsarbeiten durch User')+': '+UserInfo(_Username, cnvia(vSess)));
  end;

end;


//========================================================================
//  Manage
//
//========================================================================
sub Manage(opt aSyncSQL : logic);
local begin
  Erx     : int;
  vErg    : int;
  vBuf903 : int;
  vUser   : alpha;
  vOK     : logic;
  vSess   : alpha;
end;
begin
  // 01.03.2017 AH
  if (TransCount>0) then RETURN;

/*** 01.07.2016
  vBuf903 # RekSave(903);
  // Crit-Einstellungen holen...
  vErg # RecRead(903,1,_recFirst);
  if (vErg>_rOK) then begin
    RekRestore(vBuf903);
    RETURN;
  end;
***/

//  vSess # _isActive();
//  if (vSess>'') then begin
//    vUser # UserInfo(_Username, Set.Crit.UsedSession);
  // 01.07.2016
//    vUser # UserInfo(_Username, cnvia(vSess));
//    _DisplayPause(Translate('Kritische Wartungsarbeiten durch User')+': '+vUser);
//  end;
  PauseBeiBedarf();


  // SYNC-Testsystem?
//debug('CRIT: teste auf testsystem...');
  if (Set.SQL.SoaYN=false) and (aSyncSQL) and (gODBCCOn<>0) and (TransActive=false) and (gBlueMode=false) then begin

    // TESTSYSTEM
    //if ( StrFind(StrCnv( DbaName( _dbaAreaAlias ), _strUpper ),'TESTSYSTEM',1) > 0) then begin
    if (isTestsystem) then begin
//debug('CRIT: bin Testsystem!');
//debug('CRIT: hab auch Link');
      Erx # RecRead(997,1,_recfirst);
      if (Erx>_rLocked) or (Version.lfdnr<100) then begin    // KEIN Datensatz, oder 1(d.h. Echtsystem) => bisher KEIN Testsystem
        if (_CritStarted(false)=false) then begin
//          RekRestore(vBuf903);
          RETURN;
        end;

        // start full-sync
//        Msg(99,'Starting sync...',0,0,0);
        if (Lib_ODBC:FirstScript(true)) then begin
          if (Lib_ODBC:FirstSync(true)) then begin
//debug('Set FLAG!');
            RecDeleteAll(997);
            RecbufClear(997);
            Version.lfdnr # 100;
            Lib_Rec:StampDB();
//            Lib_ODBC:TransferStamp();
          end;
        end;
        _CritStopped();
        if (Version.lfdnr<>100) then begin
//          RekRestore(vBuf903);
          Winhalt();
          RETURN;
        end;
      end;

    end
    else begin    // ECHTSYSTEM....

      if ((Set.SQL.SoaYN=false) and (Lib_ODBC:isStampOK()=false)) or (gUserName='SYNC') then begin

        if (gUserName='SYNC') then begin

          if (Lib_ODBC:isStampOK()=false) then begin

            if (_CritStarted(false)=false) then begin
//              RekRestore(vBuf903);
              RETURN;
            end;
            // start full-sync
            Erx # 0;

            if (Lib_ODBC:FirstScript(true)) then begin
              if (Lib_ODBC:FirstSync(true)) then begin
                RecDeleteAll(997);
                RecbufClear(997);
                Version.lfdnr # 1;
                Lib_Rec:StampDB();
//                Lib_ODBC:TransferStamp();
              end;
            end;

            _CritStopped();
          end;

//          RekRestore(vBuf903);
          Winhalt();
          RETURN;
        end;  // USER SYNC


        DbaLog(_LogError, N, 'OUT-OF-SYNC bei Stamp:'+cnvab(Version.Stamp));
        if (_CritStarted(false)=false) then begin
//          RekRestore(vBuf903);
          RETURN;
        end;
        // start full-sync
        Erx # 0;
        WHILE (Erx<>_winidcancel) do
          Erx # Msg(99,'!!! DATENBANK OUT-OF-SYNC !!!',_WinIcoError,_WinDialogOkCancel,0)

        _CritStopped();

        // ENDE wenn kein Programmierer
        if (gUserGroup<>'PROGRAMMIERER') then begin
//        if (Version.lfdnr<>1) then begin
//          RekRestore(vBuf903);
          Winhalt();
          RETURN;
//        end;
        end;
      end;
    end;
  end;



  // CRIT-Prozedur ggf. starten
  vOK # _CheckTime();

  // Fehler??
  if (vOK=false) then begin
  end;

end;


//========================================================================
