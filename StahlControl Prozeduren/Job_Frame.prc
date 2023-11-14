@A+
//===== Business-Control =================================================
//
//  Prozedur    Job_Frame
//                  OHNE E_R_G
//  Info        Anzeige des "Job-Server"-Frames samt Abarbeitung der Jobs
//
//
//  28.03.2004  AI  Erstellung der Prozedur
//  25.10.2013  AH  Timer startet 3 mal (Workaround für manchmal abbrechender Timer)
//  20.01.2014  AH  Resheduling "x" eingebaut
//  15.10.2014  AH  BugFix beim Interieren der Jobs
//  19.08.2016  AH  Job-Interation mit eigenem Buffer
//  26.06.2017  ST  "sub PrintList(...opt aFrxListBereich : alpha)" hinzugefügt
//  27.09.2017  ST  Bugfix: "PrintList" gegen "Alphawert zu lang"
//  05.12.2018  AH  Bugfix: Resheduling vom Monat ergab Endlosschleife, wenn letzter Lauf lange her war
//  14.03.2022  AH  ERX, Job.Gruppe
//
//  Subprozeduren
//    SUB Test(aPara : alpha) : logic;
//    SUB PrintList(aPara : alpha) : logic;
//    SUB BAG_Import_Bag(aPara : alpha) : logic;
//    SUB WoF_Timeout(aPara : alpha) : logic
//    SUB Proto(aText : alpha);
//
//    SUB EvtTimer(aEvt : event; aTimerID : int) : logic;
//========================================================================
@I:Def_Global

local begin
  vTimer  : int;
  vAktion : alpha;
end;


//============================================================
// CopyExterneDatei
//          Kopiert eine Externe Datei von nach
//
//===========================================================
sub CopyExterneDatei(
  aSrcName : alpha(4096);
  aDstName : alpha(4096);
) : int;
local begin
  vSrcHdl     : int;            // Handle der Ausgangsdatei
  vDstHdl     : int;            // Handle der Zieldatei
  vSize       : int;            // Größe der Originaldatei
  vBlockSize  : int;            // Blockgröße
  vBuffer     : byte[8192];     // Datenpuffer
  vResult     : int;            // Funktionsresultat
  vProgress   : int;
  vBalken     : int;
  vAnz        : int;
end;
begin
  try begin
    // Dateien öffnen und Größe ermitteln
    vSrcHdl # FsiOpen(aSrcName,_FsiStdRead);
    vDstHdl # FsiOpen(aDstName,_FsiStdWrite);
    vSize   # FsiSize(vSrcHdl);

    // Dialog laden
    if (StrLen(aSrcName) > 30) then
      vProgress # Lib_Progress:Init( 'Kopiere ...' + StrCut(aSrcName,StrLen(aSrcName)-29,30), vSize )
    else
      vProgress # Lib_Progress:Init( 'Kopiere ' + aSrcName, vSize );

    // kopieren
    while (vSize > 0) do begin

      inc(vAnz);
      if (vAnz>100) then begin
        vAnz # 0;
        Winsleep(1);
      end;

      vBlockSize # min(vSize,8192);         // maximale Blockgröße setzen
      FsiRead(vSrcHdl,vBuffer,vBlockSize);  // Daten lesen
      FsiWrite(vDstHdl,vBuffer,vBlockSize); // Daten schreiben
      dec(vSize,vBlockSize);                // Restgröße vermindern
      inc(vBalken, vBlockSize);

      // Copy Abbruch
      if (vProgress->Lib_Progress:Stepto(vBalken) = false) then begin
        FsiClose(vDstHdl);
        FsiDelete(aDstName);
        vDstHdl # 0;
        ErrSet(-1);
      end;

    end;

    // Datum & Uhrzeit wiederherstellen
    FsiDate(vDstHdl,_FsiDtModified,FsiDate(vSrcHdl,_FsiDtModified));
    FsiTime(vDstHdl,_FsiDtModified,FsiTime(vSrcHdl,_FsiDtModified));
  end;

  // Fehler aufgetreten ?
  vResult # ErrGet();
  ErrSet(0);

  // Prozessbalken beenden
  vProgress->Lib_Progress:Term();

  // Dateien schließen, wenn Handles belegt
  if (vDstHdl > 0) then
    FsiClose(vDstHdl);
  if (vSrcHdl > 0) then
    FsiClose(vSrcHdl);

  RETURN vResult;
end;


//========================================================================
// Test
//
//========================================================================
sub Test(aPara : alpha) : logic;
local begin
  vI        : int;
  vProgress : int;
end;
begin
//  WindialogBox(gFrmMain,'aaa',aPara,0,0,0);
/*
  vProgress # Lib_Progress:Init( 'Test...', 100);
  FOR vI # 1 loop inc(vI) while (vI<100) do begin
    winsleep(100);
    vProgress->Lib_Progress:Step();
  END;
  vProgress->Lib_Progress:Term();
*/
//  CopyExterneDatei('W:\future.ca1', 'd:\futurexxx.ca1');
//Auf.Nummer    # 100801;
//RecRead(400,1,0);
//RecLink(401,400,9,_RecFirst);
//Lib_Dokumente:Printform(400,'Auftragsbest', false);
  winsleep(10000);
  RETURN true;
end;


//========================================================================
// Reorg
//
//========================================================================
sub Reorg(aPara : alpha) : logic;
begin
  aPara # StrCnv(aPara,_strUpper);

  if (aPara=*'*OFP*') then begin
    if (OfP_Abl_Data:Reorganisation(y)=false) then RETURN false;
  end;

  if (aPara=*'*AUF*') then begin
    if (Auf_Abl_Data:Reorganisation(y)=false) then RETURN false;
  end;

  if (aPara=*'*EIN*') then begin
    if (Ein_Abl_Data:Reorganisation(y)=false) then RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// PrintList
//
//========================================================================
sub PrintList(aPara : alpha(1000); opt aFrxListBereich : alpha) : logic;
local begin
  vList     : alpha(1000);
  vPrinter  : alpha(1000);
  vXML      : alpha(1000);
end;
begin
  vList     # Str_Token(aPara,'|',1);
  vPrinter  # Str_Token(aPara,'|',2);
  vXML      # Str_Token(aPara,'|',3);
  Frm.Name      # '';
  Frm.Drucker   # vPrinter;
  Job.Parameter # StrCut(vXML,1,64);
  Lfm_Ausgabe:Starten(aFrxListBereich , cnvia(vList));
  RETURN true;
end;


//========================================================================
// BAG_Import
//
//========================================================================
sub BAG_Import(aPara : alpha) : logic;
begin

//  RETURN SFX_Std_XML_Import:BAG_Import_Batch();
end;


//========================================================================
// WoF_Timeout
//    JOB Job_Frame:WoF_TimeOut
//========================================================================
sub WoF_Timeout(aPara : alpha) : logic;
begin
  RETURN WoF_Data:Job_Timeout();
end;


//========================================================================
//  Proto
//
//========================================================================
SUB Proto(aText : alpha(250));
local begin
  vTxt  : int;
end;
begin
RETURN;
  vTxt # TextOpen(16);
  TextRead(vTxt,'!JOB-PROTOKOLL',0);
  aText # cnvad(today)+' '+cnvat(now)+': '+aText
//  aText # cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+': '+aText;
  TextLineWrite(vTxt, 1, aText,_TextLineInsert);
  TxtWrite(vTxt,'!JOB-PROTOKOLL',0);
  TextClose(vTxt);
end;


//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer(
  aEvt      : event;
  aTimerID  : int;
) : logic;
local begin
  vGrp    : int;
  Erx     : int;
  vWert   : int;
  vZeit   : int;
  vDatum  : int;
  vDat    : date;
  vPara   : alpha(250);
  vTrans  : int;
  vCT     : caltime;
  v905    : int;
end;
begin

  if (vAktion='...waiting...') then
    vAktion # '...WAITING...'
  else
    vAktion # '...waiting...';

  $lb.User->wpcaption # gUserName;
  $lb.Zeit->wpcaption # CnvAT(now,_FmtTimeSeconds);
  $lb.Datum->wpcaption # CnvAD(today);
  $lb.Aktion->wpcaption # vAktion;
  $RL.Jobs->WinUpdate(_WinUpdOn, _WinLstFromFirst);
  gFrmMain->wpcaption # Translate('Datenbank')+': '+DbaName(_DbaAreaAlias);

  Org_Data:KeepAlive('','JOBSERVER');

  $lb.Error->wpvisible # (RecInfo(908,_recCount)>0);

  // TeM.Anker prüfen -----------------------------------------------------------
  if (Set.TimerYN) then begin
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
      //Lib_Notifier:NewEvent( TeM.A.Code, '980', 'AKT '+AInt(TeM.Nummer)+' '+TeM.Bezeichnung, Tem.Nummer );
      // 02.06.2020 AH: Neu + Tem.Nummer
      // 02.06.2020 AH: besser so...
      TeM_A_Data:Update(true);


      TeM.A.EventErzeugtYN # n;
      Erx # RecRead(981,3,0);
    END;

  end;    // TeM.Anker



  Crit_Prozedur:Manage();


  // JOBS loopen ------------------------------------------------------------
  try begin
    ErrTryCatch(_ErrCnv,y);
    ErrTryCatch(_ErrValueOverflow,y);
    vGrp # Abs(Cnvia(gUsername));
  end;
  if (ErrGet() != _ErrOk) then ErrSet(_rOK);

  v905 # RecBufCreate(905);
  Erx # RecRead(v905,2,_RecFirst);
  WHILE (Erx<=_rMultikey) do begin

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

    RecRead(903,1,_RecFirst);   // 16.05.2022 AH, Settings neu holen

    $lb.Aktion->wpcaption       # v905->Job.Aktion;

    v905->Job.letzterLaufDatum  # today;
    v905->Job.LetzterLaufZeit   # now;
    vPara                       # v905->Job.Parameter;

    Proto('starte : '+v905->Job.Aktion);

    vTrans # TransCount;

    RecBufCopy(v905,905);   // zur "Sicherheit" für alte Prozeduren
    v905->Job.letzterLaufOKYN   # Call(v905->Job.Aktion, vPara);

    if (TransCount>vTrans) then begin
      RecBufClear(908);
      Job_STD:JobError(v905->Job.Aktion, 'NEUE TRANSAKTION OFFEN');
      Proto(Job.Err.Text);
      DbaLog(_LogError, N,Job.Err.Text+'|U:Jobserver');
    end;
    if (v905->Job.letzterLaufOKYN) then
      Proto('Job erfolgreich : '+v905->Job.Aktion)
    else
      Proto('Job meldet Fehler: '+v905->Job.Aktion);

    v905->Job.Parameter    # vPara;

    if (v905->Job.Resheduling='') then begin
      RekDelete(v905,0,'MAN');
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
//        RekReplace(v905,_RecUnlock,'AUTO');
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
            //v905->Job.Start.Datum->vmmonthmodify(vWert);
            //vDat  # v905->Job.Start.Datum;
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
//        RekReplace(v905,_RecUnlock,'AUTO');

//        RekReplace(v905,_RecUnlock,'AUTO');
      end;
    end;

    Erx # RecRead(v905,2,_RecFirst); // Wieder VORNE anfangen

    $RL.Jobs->WinUpdate(_WinUpdOn, _WinLstFromFirst);
  END;

  RecBufDestroy(v905);

  SysTimerClose(aTimerID);
  vTimer # SysTimerCreate(Set.JobSrv.Intervall,3);    // eigentlich nur 1 Start, aber Workaround für manchmal abbrechender Timer

  RETURN true;
end;


//========================================================================
// MAIN
//
//========================================================================
MAIN
local begin
  vGrp    : int;
  vFilter : int;
  vRL     : int;
end;
begin

  if (Set.JobSrv.Intervall=0) then
    Set.JobSrv.Intervall # 5000;

  VarAllocate(WindowBonus);
  vTimer # SysTimerCreate(1000,1);

  Proto('');
  Proto('*** JOB-SERVER LOGIN ***');

  gFrmMain  # WinOpen('Frame.Jobserver',_WinOpendialog);
  gMDI      # gFrmMain;

  // TAPi starten
  Lib_Tapi:TapiInitialize();

  vGrp # Abs(cnvia(gUsername));
  if (vGrp>0) then begin
    vFilter # RecFilterCreate(905,2);
    vFilter->RecFilterAdd(3,_fltAnd,_FltEq, vGrp);
    vRL # Winsearch(gMDI, 'RL.Jobs');
    vRL->wpDbFilter # vFilter;
  end;
  // Dialog starten
  WinDialogRun(gFrmMain, _Windialogcenter | _WindialogApp);

  Winclose(gFrmMain);
  if (vFilter>0) then
    vFilter->RecFilterDestroy();

  // TAPi beenden
  Lib_Tapi:TapiTerm();

  Proto('*** JOB-SERVER LOGOUT ***');
  Proto('');

  Org_Data:Killme();
  SysTimerClose(vTimer);
  VarFree(WindowBonus);
end;


//========================================================================