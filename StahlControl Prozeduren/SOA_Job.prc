@A+
//===== Business-Control =================================================
//
//  Prozedur  SOA_Job
//                OHNE E_R_G
//  Info      Kann JOBSERVER oder FILESCANNER als SOA ersetzen
//            Errors werden in die Job-Fehlertabelle geschrieben wobei Filescanner-Fehler nicht mehrfach aufgenommen
//            werden! (pro Directory nur ein Fehler)
//
//
//  30.10.2019  AH  Erstellung der Prozedur
//  10.09.2020  ST  Startinfo in Datenbanklog inkl. PID zum Identifizierung im Taskmanager
//  04.02.2022  AH  ERX
//  22.03.2022  ST  Bugfix: MemLeak bei "DoJobs": RecBufDestroy hinzugefügt 2349/2
//  2022-11-29  AH  Job.Gruppe
//
//  Subprozeduren
//    sub JobServer
//    sub Filescanner
//
//========================================================================
@I:Def_Global
define begin
  cMaxJobs  : 10
end;


//=========================================================================
sub _StatusError(aMode : alpha);
begin
  RmtDataWrite('SOA_'+aMode+'_STATUS', _recunlock | _RmtDataTemp, 'ERROR');
end;


//=========================================================================
sub _StatusOK(aMode : alpha);
begin
  RmtDataWrite('SOA_'+aMode+'_STATUS', _recunlock | _RmtDataTemp, 'OK');
end;


//========================================================================
sub _CheckFileScannerError(
  aKey    : alpha(250)) : alpha;
local begin
  vA      : alpha(1000);
end;
begin
  if (RmtDataRead(aKey, _recunlock, var vA)<=_rLocked) then begin
  end;
  RETURN vA;
end


//========================================================================
sub _SetFileScannerError(
  aKey    : alpha(250);
  aValue  : alpha)
begin
  RmtDataWrite(aKey, _recunlock | _RmtDataTemp, aValue);
end;


//========================================================================
// sub Init() : alpha
//  Allokiert alle Globalen Datenbereiche, die für Verbuchungen etc.
//  benötigt werden
//========================================================================
sub Init() : alpha
begin

  // ALLE EVENTS ERLAUBEN:
  WinEvtProcessSet(_WinEvtAll,true);

  // Uhrzeit vom Server holen
  DbaControl(_DbaTimeSync);

  VarAllocate(VarSysPublic);   // public Variable allokieren
  gCodepage # _Sys->spCodepageOS;

  // Initialisieren
  Liz_Data:InitSoa();

  VarAllocate(WindowBonus);

  gUserGroup # 'JOB-SERVER';    // Globale Daten Vorbelegen
  gUserName  # 'SOA-JOB';
  
  Lib_SFX:InitAFX();            // AFX initialisieren
  
  RETURN Lib_ODBC:Init();       // ODBC initalizieren
end; // sub Init


//=========================================================================
//=========================================================================
sub DoTerminAnker();
local begin
  Erx : int;
end;
begin
  // TeM.Anker prüfen -----------------------------------------------------------
  if (Set.TimerYN=false) then RETURN;
  RecBufClear(981);
  TeM.A.Datei           # 800;
  TeM.A.Start.Datum     # today;
  TeM.A.Start.Zeit      # now;
  TeM.A.EventErzeugtYN  # n;
  Erx # RecRead(981,3,0);

//debug('Read Erx : '+aint(Tem.A.Nummer)+' '+TeM.A.Code+' am '+cnvad(tem.a.start.datum)+':'+cnvat(tem.a.start.zeit));

  WHILE (Erx<=_rNoKey) do begin
    if (TeM.A.Datei<>800) or (TeM.A.Start.Datum=0.0.0) or
      (TeM.A.Start.Datum>today) or (TeM.A.EventErzeugtYN=y) or
      ((TeM.A.Start.Datum=today) and (TeM.A.Start.Zeit>now)) then BREAK;
//debug('msg:'+TeM.A.Code+' am '+cnvad(tem.a.start.datum)+':'+cnvat(tem.a.start.zeit));

    if (TeM.A.Code='') then begin
      Erx # RecRead(981,3,_recNext);
      CYCLE;
    end;

    RecRead(981,1,_recLock);
    TeM.A.EventErzeugtYN # y;
    Erx # RekReplace(981,0,'AUTO');
    if (Erx<>_rOK) then begin
      Erx # RecRead(981,3,_recNext);
      CYCLE;
    end;

    Erx # RecLink(980,981,1,_recFirst);   // Termin holen

    // interner Notifier...
    Lib_Notifier:NewEvent( TeM.A.Code, '980', 'AKT '+AInt(TeM.Nummer)+' '+TeM.Bezeichnung );

    TeM.A.EventErzeugtYN # n;
    Erx # RecRead(981,3,0);
  END;

  Crit_Prozedur:Manage();
end;


//=========================================================================
//=========================================================================
sub DoFileScanner() : logic
local begin
  Erx       : int;
  vDirHdl   : int;
  vName     : alpha(2000);
  vOK       : logic;
  vKey      : alpha(250);
end;
begin

  FOR Erx # RecRead(909,1,_recFirst)    // Alle Ordner loopen
  LOOP Erx # RecRead(909,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    //vDirHdl # FsiDirOpen(cImportDir+'\'+cDateischema,_FsiAttrHidden);
    vDirHdl # FsiDirOpen(FSP.Pfad+'\'+FSP.Dateityp,_FsiAttrHidden);
    vName   # vDirHdl->FsiDirRead(); // erste Datei

    WHILE (vName != '') do begin

      vKey # 'SOA_FILESCANNER_ERROR_DIR_'+aint(FSP.Nummer);
      vName # FSP.Pfad+'\'+vName;

      vOK # Call(FSP.Prozedur, vName);

      if (vOK=false) then begin
        if (_CheckFileScannerError(vKey)='') then begin
          _SetFileScannerError(vKey, 'ERROR');
          Job_STD:JobError('Filescanner', vName);
        end
        else begin
          // selber Fehler noch mal!
        end;
        BREAK;
      end
      else begin
        if (_CheckFileScannerError(vKey)<>'') then begin
          _SetFileScannerError(vKey, '');
        end;
      end;

      Fsidelete(vName);

      vName # vDirHdl->FsiDirRead();
    END;

    vDirHdl->FsiDirClose();
  END;

  RETURN true;
end;


//=========================================================================
//=========================================================================
sub DoJobs()
local begin
  Erx     : int;
  vAnz    : int;
  v905    : int;
  vPara   : alpha(250);
  vTrans  : int;
  vWert   : int;
  vZeit   : int;
  vDatum  : int;
  vCT     : caltime;
  vDat    : date;
  vGrp    : int;
end;
begin

  vAnz # 0;
  // JOBS loopen ------------------------------------------------------------
  try begin
    ErrTryCatch(_ErrCnv,y);
    ErrTryCatch(_ErrValueOverflow,y);
    vGrp # Abs(Cnvia(gUsername));
  end;
  if (ErrGet() != _ErrOk) then ErrSet(_rOK);

  v905 # RecBufCreate(905);
  Erx # RecRead(v905,2,_RecFirst);
  WHILE (Erx<=_rMultikey) and (vAnz<cMaxJobs) do begin
    inc(vAnz);

    // Job soll später laufen?-> ENDE
    if (v905->Job.Start.Datum>today) then BREAK;
    if (v905->Job.Start.Datum=today) and
      (v905->Job.Start.Zeit>now) then BREAK;

    if (vGrp<>0) and (vGrp<>v905->Job.Gruppe) then begin
      Erx # RecRead(v905,2,_RecNext);
      CYCLE;
    end;

    Erx # RecRead(v905,1,_RecLock);
    if (Erx=_rLocked) then begin
      Erx # RecRead(v905,2,_RecNext);
      CYCLE;
    end;

    v905->Job.letzterLaufDatum  # today;
    v905->Job.LetzterLaufZeit   # now;
    vPara                       # v905->Job.Parameter;

    Job_Frame:Proto('starte : '+v905->Job.Aktion);

    RecRead(903,1,_RecFirst);   // 16.05.2022 AH, Settings neu holen

    vTrans # TransCount;

    RecBufCopy(v905,905);   // zur "Sicherheit" für alte Prozeduren
    v905->Job.letzterLaufOKYN   # Call(v905->Job.Aktion, vPara);

    if (TransCount>vTrans) then begin
      Job_STD:JobError(v905->Job.Aktion, 'NEUE TRANSAKTION OFFEN');
      Job_Frame:Proto(Job.Err.Text);
      DbaLog(_LogError, N,Job.Err.Text+'|U:Jobserver');
    end;
    if (v905->Job.letzterLaufOKYN) then begin
      Job_Frame:Proto('Job erfolgreich : '+v905->Job.Aktion);
    end
    else begin
      Job_STD:JobError(v905->Job.Aktion, 'nicht i.O.');
      Job_Frame:Proto('Job meldet Fehler: '+v905->Job.Aktion);
    end;

    v905->Job.Parameter    # vPara;

    if (v905->Job.Resheduling='') then begin
      Erx # RekDelete(v905,0,'MAN');
    end
    else begin

      vWert # CnvIA(v905->Job.Resheduling);
      vZeit # CnvIT(v905->Job.Start.Zeit)/60000;
      vDatum # CnvID(v905->Job.Start.Datum);

      if (StrFind(v905->Job.Resheduling,'X',0)<>0) then begin
        vCT->vmSystemTime();
        vCT->vmSecondsModify(1);
        v905->Job.Start.Zeit  # vCT->vpTime;
        v905->Job.Start.Datum # vCT->vpDate;

        RecBufCopy(v905, 905);
        RekReplace(905,_RecUnlock,'AUTO');
      end
      else begin
        REPEAT
          if (StrFind(v905->Job.Resheduling,'M',0)<>0) then begin
            vZeit # vZeit + (vWert);
            if (vZeit>(24 * 60 )) then begin
              vZeit # vZeit - (24 * 60);
              vDatum # vDatum + 1;
            end;
          end
          else if (StrFind(v905->Job.Resheduling,'T',0)<>0) then begin
            vDatum # vDatum + vWert;
          end
          else if (StrFind(v905->Job.Resheduling,'O',0)<>0) then begin
            vDat # cnvdi(vDatum);
            vDat->vmmonthmodify(vWert);
            vDatum # CnvID(vDat);
          end
          else if (StrFind(v905->Job.Resheduling,'W',0)<>0) then begin
            REPEAT
              vDatum # vDatum + 1;
            UNTIL (DateDayOfWeek(cnvdi(vDatum))<=5);
          end
          else begin
            v905->Job.Start.Datum # 1.1.2099;
          end;

        UNTIL (vDatum>CnvID(Today)) or
          ((vDatum=CnvID(today)) and (vZeit*60000>cnvit(Now)));

        v905->Job.Start.Zeit # CnvTI(vZeit*60000);
        v905->Job.Start.Datum # CnvDI(vDatum);

        RecBufCopy(v905, 905);
        if (RekReplace(905,_RecUnlock,'AUTO')<>_rOK) then begin
          Erx # RecRead(v905,2,_RecNext);
          CYCLE;
        end;
      end;
    end;

    Erx # RecRead(v905,2,_RecFirst); // Wieder VORNE anfangen
  END;
  
  if (v905 > 0) then
    RecBufDestroy(v905);
end;


//=========================================================================
//  Worker
//=========================================================================
sub Worker(
  aObjHdl   : handle;    // Task-object
  aMode     : alpha;
);
local begin
  vError      : logic;
  vLastErr    : alpha(250);
  vTryErr     : int;
end;
begin

  // ST 2020-09-10:
  // Loginfo für PID zum Identifizieren eines gechrashtem Dienst
  DbaLog(_LogInfo, N, 'SOA-JOBSERVER ' + aMode +  ': Started...PID: ' + Aint(_Sys->spProcessId));
  
  
  // problem beim druck: Lib_ODBC:GetTempDok macht nicht!

  if (Init() <> '') then begin
    DbaLog(_LogError, false, StrCut('SOA-Server: Initialization failed: ' + vLastErr,1,250));
    RETURN;
  end;

  _StatusOK(aMode);

  GV.Sys.UserID # gUserID;
  WHILE (!aObjHdl->spStopRequest) do begin

    trysub begin
      ErrTryIgnore(_ErrAll);
      ErrTryCatch(_ErrHdlInvalid,true);

      // "Normale" Fehler versuchen über
      if (vError) then begin
        SysSleep(250);
        CYCLE;
      end;

      Org_Data:KeepAlive('',aMode);

      if (StrFind(aMode,'JOBSERVER',0)>0) then begin
        DoTerminAnker();
        DoJobs();
      end;

      if (StrFind(aMode,'FILESCANNER',0)>0) then begin
        DoFileScanner();
      end;
     
      Winsleep(2000);   // WIEDERHOLUNG
    end; // Try
    
    vTryErr # ErrGet();
    ErrSet(_ErrOK);
    if (vTryErr<> _rOK) then begin
//      DbaLog(_LogError, false, StrCut('SOA-Sync: HandledException: (' + Aint(vTryErr) + ') ' +ErrMapText(vTryErr),1,250));
//      DbaLog(_LogError, false, StrCut('SOA-Sync: HandledException in: ' + ErrThrowProc(),1,250));
      // Neustart von SOA laut Verbindungstimeout
      BREAK;
    end;

  END;

  Lib_SOA:Terminate();

//  DbaLog(_LogInfo, N, 'SOA-Sync: ...Ended');

end;


//=========================================================================
//  JobServer
//=========================================================================
sub JobServer(
  aObjHdl  : handle;    // Task-object
  aEvtType : int;       // Event-type
)
begin
  Worker(aObjHdl, 'JOBSERVER');
end;


//=========================================================================
//  OnlyFilescanner
//=========================================================================
sub Filescanner(
  aObjHdl  : handle;    // Task-object
  aEvtType : int;       // Event-type
)
begin
  Worker(aObjHdl, 'FILESCANNER');
end;



//========================================================================