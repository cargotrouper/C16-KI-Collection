@A+
//===== Business-Control =================================================
//
//  Prozedur  SOA_Sync
//                  OHNE E_R_G
//  Info
//
//
//  19.05.2016  AH  Erstellung der Prozedur
//  04.07.2016  AH  Umbau, damit Fehler im Log nicht "spammen"
//  01.12.2016  ST
//  08.03.2017  AH  INSERT ignoriert "Violation of" Primary-Key
//  21.04.2017  ST  Command Import "_ProcessCommandQueue()" hinzugefügt
//  26.09.2017  ST  HandleMemLeak für "ProccessCommandQueue() eingebaut
//  27.11.2016  AH  "_ProcessCommandQueue" deaktiviert !!!
//  (26.09.2018  AH)  Edit: Updates mit einem _NoRec versuchen es als Insert erneut
//  02.10.2018  AH  FIX: 26.09. erst mal wieder deaktiviert
//  15.11.2018  AH  FIX, Connection-Reset bei MULTI-Error
//  14.07.2020  AH  Userdatei 800 wird auch in die NET-Benutzer gesynct
//  22.03.2021  ST  Fix: Datei = 0 verstopft Queuenicht mehr
//  09.07.2021  AH  Neuer Vorgang "X" für X-Link = Insert, sonst Update
//
//  Subprozeduren
//    sub testfehler()
//    sub SyncSql(aObjHdl : handle; aEvtType : int;);
//    sub _ProcessPtD()   : logic;
//    sub _ProcessCommandQueue()  : logic;
//
//========================================================================
@I:Def_Global

define begin
  xSetTimeStamp  : PtD.Sync.TimeStamp->vmServerTime()
  xSetUser       : PtD.Sync.UserId # gUserID
end;

declare _ProcessPtD() : logic;
declare _ProcessCommandQueue() : logic;



//=========================================================================
//  sub testfehler()
//=========================================================================
sub testfehler()
local begin
  i : int;
end;
begin
  if (today = 01.12.2016) AND (now > 10:45) then
    i->wpCaption # 'Horst';
    //i # 1/0;
end;


//=========================================================================
sub _StatusError();
begin
  RmtDataWrite('SOA_SYNC_STATUS', _recunlock | _RmtDataTemp, 'ERROR');
end;


//=========================================================================
sub _StatusOK();
begin
  RmtDataWrite('SOA_SYNC_STATUS', _recunlock | _RmtDataTemp, 'OK');
end;


//=========================================================================
//  SyncSql
//=========================================================================
sub SyncSql(
  aObjHdl  : handle;    // Task-object
  aEvtType : int;       // Event-type
);
local begin
  vTim        : time;
  vError      : logic;
  vMultiError : logic;
  vLastErr    : alpha(250);
  vTryErr     : int;
  I  : int;
end;
begin

  // ReadOnly??? -> ENDE
  if ( DbaInfo( _dbaReadOnly ) > 0 ) then RETURN;

  // Settings lesen
  RecRead(903,1,0);
  if (Set.SQL.Instance='') or (Set.SQL.Database='') or (Set.SQL.User='') then RETURN;

  DbaLog(_LogInfo, N, 'SOA-Sync: Started...');

//  vLastErr # Lib_SOA:Init();
  if (Lib_SOA:Init() <> '') then begin
    DbaLog(_LogError, false, StrCut('SOA-Sync: Initialization failed: ' + vLastErr,1,250));
    RETURN;
  end;

  _StatusOK();

  GV.Sys.UserID # gUserID;
  vTim->vmServerTime();
  WHILE (!aObjHdl->spStopRequest) do begin

    trysub begin
      ErrTryIgnore(_ErrAll);
      ErrTryCatch(_ErrHdlInvalid,true);

      // "Normale" Fehler versuchen über
      if (vError) then begin
        SysSleep(250);
        CYCLE;
      end;

      Org_Data:KeepAlive('','SYNC');

 //     TestFehler2();

//      _ProcessCommandQueue(); // Sync SQL->C16

      // Sync C16->SQL
      if (RecRead(992,1,_recFirst)<>_rOK) then begin
        SysSleep(250);
        CYCLE;
      end;

      // an SQL übertragen...
      if (_ProcessPtD()=false) then begin

        // PROBLEME !!!
        if (vLastErr = gOdbcLastError) then begin
          if (vMultiError=false) then begin
            vMultiError # true;
            DbaLog(_LogError, N, 'SOA-Sync: same error multiple times !!!');
            _StatusError();
            // 15.11.2018 AH:
            DbaLog(_LogError, N, 'SOA-Sync: Reset Connection...');
          end;
          SysSleep(3000);
          Lib_ODBC:HandleMemLeak(true);
          CYCLE;
        end;
        vLastErr # gOdbcLastError;
        Syssleep(1000);
        CYCLE;
      end;
      
      // ALLES GUT!
      gOdbcLastError  # '';
      vLastErr        # '';
      if (vMultiError) then begin
        vMultiError # false;
        DbaLog(_LogError, N, 'SOA-Sync: ...running normal again...');
        _StatusOK();
      end;
      
      // Satz löschen
      RecDelete(992,_RecEarlyCommit);   // 07.07.2021 AH EARLY
      
    end; // EO Try
    
    vTryErr # ErrGet();
    ErrSet(_ErrOK);
    if (vTryErr<> _rOK) then begin
      DbaLog(_LogError, false, StrCut('SOA-Sync: HandledException: (' + Aint(vTryErr) + ') ' +ErrMapText(vTryErr),1,250));
      DbaLog(_LogError, false, StrCut('SOA-Sync: HandledException in: ' + ErrThrowProc(),1,250));
      // Neustart von SOA laut Verbindungstimeout
      RETURN;
    end;

  END;

  Lib_SOA:Terminate();

  DbaLog(_LogInfo, N, 'SOA-Sync: ...Ended');

end;


//========================================================================
//
//========================================================================
sub _ProcessPtD() : logic;
local begin
  vErr  : alpha(250);
  i     : int;
  vOK   : logic;
  vErg  : int;
  vCMD  : int;
end;
begin


//  if (Lib_Odbc:HandleMemLeak()<>'') then RETURN false;

//DbaLog(_LogInfo, N, 'SOA-JOB: PTD '+cnvai(PtD.Sync.Datei)+PTd.Sync.Operation);
//debugx('PTD '+cnvai(PtD.Sync.Datei)+PTd.Sync.Operation);

  // TEXTE ----------------------------------------------------------------------------------------------------------------------
  if (PtD.Sync.Datei=1000) then begin
    case (Ptd.Sync.Operation) of
      'I' : begin
        vOK # Lib_ODBC:InsertText(PtD.Sync.Para1, PtD.Sync.Para2);
        if (gOdbcLastError<>'') then begin
          if (StrFind(gOdbcLastError,'Violation of',0)>0) or
            (StrFind(gOdbcLastError,'Verletzung der PRIM',0)>0) then begin
            gOdbcLastError # '';
            vOK # true;
          end;
        end;
        RETURN vOK;
      end;
      'N' : begin
        vOK # Lib_ODBC:CreateText(PtD.Sync.Para1);
        if (gOdbcLastError<>'') then begin
          if (StrFind(gOdbcLastError,'Violation of',0)>0) or
            (StrFind(gOdbcLastError,'Verletzung der PRIM',0)>0) then begin
            gOdbcLastError # '';
            vOK # true;
          end;
        end;
        RETURN vOK;
      end;
      'D' : RETURN Lib_ODBC:DeleteText(PtD.Sync.Para1);
      'R' : RETURN Lib_ODBC:RenameText(PtD.Sync.Para1, PtD.Sync.Para2);
    end;
    RETURN false;
  end

  if (PtD.Sync.Datei>0) and (PtD.Sync.Datei<1000) then begin
    // RECORD ----------------------------------------------------------------------------------------------------------------------
    case (Ptd.Sync.Operation) of

      // CLEAR --------------------------------------------------------
      'C' : begin
        RETURN Lib_ODBC:DeleteAll(PtD.Sync.Datei);
      end;


      // DELETE -------------------------------------------------------
      'D' : begin
        vOK # Lib_ODBC:Delete(PtD.Sync.Datei, PtD.Sync.RecId);
        // KEIN Satz zum Löschen vorhanden bringt KEINEN Fehler!!!
//        if (gOdbcLastError<>'') then begin
//debug(gOdbcLastError);
//          if (StrFind(gOdbcLastError,'Violation of',0)>0) then begin
//            gOdbcLastError # '';
//            vOK # true;
//          end;
//        end;
        RETURN vOK;
      end;


      // INSERT -------------------------------------------------------
      'I' : begin
        //  Satz lesen falls NOCH vorhanden
        if (RecRead(PtD.Sync.Datei, 0, _recId, PtD.Sync.RecID)>_rLocked) then RETURN true;

        // Neuer Command?
        if (gOdbcCmdInsert[Ptd.Sync.Datei]=0) then begin
  //DbaLog(_LogInfo, N, 'SOA-JOB: ReflectDatei '+cnvai(PtD.Sync.Datei));
          gOdbcCmdInsert[Ptd.Sync.Datei] # Lib_Odbc:ReflectTable(PtD.Sync.Datei, 'I');
          if (gOdbcCmdInsert[Ptd.Sync.Datei]=0) then RETURN true;
        end;

        // Daten einfüllen
        if (Lib_ODBC:FillRecIntoCommand(PtD.Sync.Datei, gOdbcCmdInsert[Ptd.Sync.Datei], 'I')=false) then begin
  DbaLog(_LogError, N, 'SOA-Sync: I_ERROR_2 '+cnvai(PtD.Sync.Datei));
          RETURN false;
        end;

        vErg # Lib_ODBC:Execute(PtD.Sync.Datei, gOdbcCmdInsert[Ptd.Sync.Datei]);
        if (gOdbcLastError<>'') then begin
//debug(gOdbcLastError);
          if (StrFind(gOdbcLastError,'Violation of',0)>0) or
            (StrFind(gOdbcLastError,'Verletzung der PRIM',0)>0) then begin
            gOdbcLastError # '';
            vErg # _rOK;
          end;
        end;

        if (Ptd.Sync.Datei=800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
          Ptd.Sync.Datei # 1800;
          // Neuer Command!
          vCMD # Lib_Odbc:ReflectTable(PtD.Sync.Datei, 'I');

          // Daten einfüllen
          if (Lib_ODBC:FillRecIntoCommand(PtD.Sync.Datei, vCMD, 'I')=false) then begin
DbaLog(_LogError, N, 'SOA-Sync: I_ERROR_2 '+cnvai(PtD.Sync.Datei));
            RETURN false;
          end;

          vErg # Lib_ODBC:Execute(PtD.Sync.Datei, vCMD);
          if (gOdbcLastError<>'') then begin
            if (StrFind(gOdbcLastError,'Violation of',0)>0) or
              (StrFind(gOdbcLastError,'Verletzung der PRIM',0)>0) then begin
              gOdbcLastError # '';
              vErg # _rOK;
            end;
          end;
        end; // 800

        RETURN (vErg=_rOK);
      end;


      // UPDATE --------------------------------------------------------
      'U' : begin
        //  Satz lesen falls NOCH vorhanden
        if (RecRead(PtD.Sync.Datei, 0, _recId, PtD.Sync.RecID)>_rLocked) then RETURN true;

        // Neuer Command?
        if (gOdbcCmdUpdate[Ptd.Sync.Datei]=0) then begin
  //DbaLog(_LogInfo, N, 'SOA-JOB: ReflectDatei '+cnvai(PtD.Sync.Datei));
          gOdbcCmdUpdate[Ptd.Sync.Datei] # Lib_Odbc:ReflectTable(PtD.Sync.Datei, 'U');
          if (gOdbcCmdUpdate[Ptd.Sync.Datei]=0) then RETURN true;
        end;

        // Daten einfüllen
        if (Lib_ODBC:FillRecIntoCommand(PtD.Sync.Datei, gOdbcCmdUpdate[Ptd.Sync.Datei], 'U')=false) then begin
  DbaLog(_LogError, N, 'SOA-Sync: U_ERROR_2 '+cnvai(PtD.Sync.Datei));
          RETURN false;
        end;

  //DbaLog(_LogInfo, N, 'SOA-JOB: execute');
        vErg # Lib_ODBC:Execute(PtD.Sync.Datei, gOdbcCmdUpdate[Ptd.Sync.Datei], true);
        vOK # (vErg=_rOK);
        // 26.09.2018 AH: nochmal als INSERT versuchen...
//02.10.2018        if (vErg=_rNoRec) then begin
//          PtD.Sync.Operation # 'I';
//          RETURN _ProcessPtD();
//        end;
        // KEIN Satz zum Updaten vorhanden bringt KEINEN Fehler!!!
//        if (gOdbcLastError<>'') then begin
//debug(gOdbcLastError);
//          if (StrFind(gOdbcLastError,'Violation of',0)>0) then begin
//            gOdbcLastError # '';
//            vOK # true;
//          end;
//        end;

        if (Ptd.Sync.Datei=800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
          Ptd.Sync.Datei # 1800;
          // Neuer Command!
          vCMD # Lib_Odbc:ReflectTable(PtD.Sync.Datei, 'U');

          // Daten einfüllen
          if (Lib_ODBC:FillRecIntoCommand(PtD.Sync.Datei, vCMD, 'U')=false) then begin
DbaLog(_LogError, N, 'SOA-Sync: U_ERROR_2 '+cnvai(PtD.Sync.Datei));
            RETURN false;
          end;

          vErg # Lib_ODBC:Execute(PtD.Sync.Datei, vCMD, true);
        end;  // 800

        RETURN vOK;

      end;  // U
      
      
      // SYNC = erst Insert, SONST Update --------------------------------------------------------
      'X' : begin
        Ptd.Sync.Operation # '';
        //  Satz lesen falls NOCH vorhanden
        if (RecRead(PtD.Sync.Datei, 0, _recId, PtD.Sync.RecID)>_rLocked) then RETURN true;

        // Neuer Command?
        if (gOdbcCmdInsert[Ptd.Sync.Datei]=0) then begin
          gOdbcCmdInsert[Ptd.Sync.Datei] # Lib_Odbc:ReflectTable(PtD.Sync.Datei, 'I');
          if (gOdbcCmdInsert[Ptd.Sync.Datei]=0) then RETURN true;
        end;

        // Daten einfüllen
        if (Lib_ODBC:FillRecIntoCommand(PtD.Sync.Datei, gOdbcCmdInsert[Ptd.Sync.Datei], 'I')=false) then begin
DbaLog(_LogError, N, 'SOA-Sync: I_ERROR_2 '+cnvai(PtD.Sync.Datei));
          RETURN false;
        end;

        vErg # Lib_ODBC:Execute(PtD.Sync.Datei, gOdbcCmdInsert[Ptd.Sync.Datei]);
        if (gOdbcLastError<>'') then begin
          if (StrFind(gOdbcLastError,'Violation of',0)>0) or
            (StrFind(gOdbcLastError,'Verletzung der PRIM',0)>0) then begin
            gOdbcLastError # '';
            vErg # _rOK;
            Ptd.Sync.Operation # 'U';
          end;
        end;

        // INSERT failed -> UPDATE? --------------------------------------------------------
        if (Ptd.Sync.Operation='U') then begin

          // Neuer Command?
          if (gOdbcCmdUpdate[Ptd.Sync.Datei]=0) then begin
            gOdbcCmdUpdate[Ptd.Sync.Datei] # Lib_Odbc:ReflectTable(PtD.Sync.Datei, 'U');
            if (gOdbcCmdUpdate[Ptd.Sync.Datei]=0) then RETURN true;
          end;

          // Daten einfüllen
          if (Lib_ODBC:FillRecIntoCommand(PtD.Sync.Datei, gOdbcCmdUpdate[Ptd.Sync.Datei], 'U')=false) then begin
DbaLog(_LogError, N, 'SOA-Sync: U_ERROR_2 '+cnvai(PtD.Sync.Datei));
            RETURN false;
          end;

          vErg # Lib_ODBC:Execute(PtD.Sync.Datei, gOdbcCmdUpdate[Ptd.Sync.Datei], true);
          vOK # (vErg=_rOK);

          RETURN vOK;
        end;  // Update von X
        
        RETURN true;
      end;  // X
    end;
  end;

  // ST 2021-03-22 Fix, da Datei = 0 die Queue verstopfen
  if (PtD.Sync.Datei=0) then
    RETURN true;

DbaLog(_LogWarning, N, 'SOA-Sync: Unknow command');

  RETURN false;
end;


//========================================================================
//  sub _ProcessCommandQueue() : logic;      ST 2017-04-21
//  Arbeitet den ersten Command in der Queue ab
//========================================================================
sub _ProcessCommandQueue() : logic;
local begin
  vCmd      : int;    // ODBC CommandHandle

  // Daten aus SQL Abfrage
  vSqlRecId : alpha;
  vCommand  : alpha;
  vArgs     : alpha(4000);

  // Interne Verabeitung
  vErr  : alpha(250);
  vQ    : alpha(250)
end;
begin
  Lib_ODBC:HandleMemLeak();

  vCmd   # gODBCCon->OdbcExecuteDirect('SELECT TOP (1) RecID, Command, Arguments FROM CommandQueue WHERE Done=0 ORDER BY Queued');
  if (vCmd = _ErrOdbcError) or (vCmd =_ErrOdbcFunctionFailed) then begin
    Lib_ODBC:OdbcError(ThisLine,gOdbcCON->spOdbcErrSqlMessage, 0);
    RETURN false;
  end;

    // Ergenis lesen
  if (vCmd->OdbcFetch() = _ErrOk) then begin

    // Datensatz gelesen...
    vCmd->OdbcClmData(1, vSqlRecId);
    vCmd->OdbcClmData(2, vCommand);
    vCmd->OdbcClmData(3, vArgs);
    vCmd->OdbcClose();

    // ...Command ausführen
    try begin
      ErrTryIgnore(_rlocked,_rNoRec);
      ErrTryCatch(_ErrNoProcInfo,y);
      ErrTryCatch(_ErrNoSub,y);
      Call('SOA_Sync_CmdActions:'+vCommand, vArgs, var vErr);
    end;
    if (ErrGet()<>_ErrOK) then begin
      Lib_ODBC:OdbcError(ThisLine,'Error in Command: '+vCommand, 0);
      RETURN false;
    end;

    // ...Ergebnis eintragen
    vQ # 'UPDATE CommandQueue SET ' +
            'Executed=''' + Lib_SQL:SQLTimeStamp(today,now) + '''' +
            ',Done='       + '1'  +
            ',Failed='     + CnvAi(CnvIl((vErr <> ''))) +
            ',Errortext=''' + vErr + ''''+
          'WHERE RecID='''+vSqlRecId+'''';
    vCmd # gOdbcCON->OdbcExecuteDirect(vQ);
    if (vCMD=_ErrOdbcError) or (vCMD=_ErrOdbcFunctionFailed) then begin
      Lib_ODBC:OdbcError(ThisLine,gOdbcCON->spOdbcErrSqlMessage, 0);
      RETURN false;
    end;
    vCmd->OdbcClose();
  end;

  RETURN true;
end;




//========================================================================