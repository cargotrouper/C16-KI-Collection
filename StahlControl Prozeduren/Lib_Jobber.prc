@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Jobber
//                OHNE E_R_G
//  Info
//
//
//  04.04.2014  AH  Erstellung der Prozedur
//  08.04.2014  AH  WatchDogFiles implementiert
//  17.06.2014  AH  Jobber startet nur für Serialport oder Blob-DB
//  15.08.2016  ST  Aufruf "ShowPDF" als Form oder Report erweitert
//
//  Subprozeduren
//  SUB WatchFile( aName : alpha(4000); aPath : alpha(4000));
//  SUB Init()
//  SUB Term()
//  SUB EvtJob...
//
//========================================================================
@I:Def_Global

define begin
  cDBA        : _BinDBA3
  cCR         : Strchar(13)
  cESC        : Strchar(27)

  cMsgInitScanner   : 100
  cMsgScanned       : 101
  cMsgScannedResult : 102

  cMsgWatchfile     : 200
  cMsgWDFileChanged : 201
  cMsgWDReportReady : 202
end;


//========================================================================
//  _SendCmd
//========================================================================
sub _SendCmd(
  aChannel  : int;
  aMsg      : int;
  aString   : alpha(4000);
)
begin
  aChannel->MsxWrite(_MsxMessage, aMsg);
  aChannel->MsxWrite(_MsxItem, 1);
  aChannel->MsxWrite(_MsxData, aString);
  aChannel->MsxWrite(_MsxEnd, 0);
end;


//========================================================================
//  _ReadCmd
//========================================================================
sub _ReadCmd(
  aChannel    : int;
  var aMsg    : int;
  var aString : alpha;
)
local begin
  vMxI    : int;
  vMxEnd  : int;
end;
begin
  aChannel->MsxRead(_MsxMessage, aMsg);
  aChannel->MsxRead(_MsxItem, vMxI);
  aChannel->MsxRead(_MsxData, aString);
  aChannel->MsxRead(_MsxData, vMxEnd);
end;


//========================================================================
// _GetStamp
//
//========================================================================
sub _GetStamp(
  aName   : alpha(4000);
  ) : bigint;
local begin
  vI      : int;
  vFile   : int;
  vStamp  : bigint;
end;
begin

//debugx('get stamp:'+aName);

  vI # FsiAttributes(aName);
  if (vI=_ErrFsiNoFile) then RETURN 0\b;

  vFile # FsiOpen(aName, _FSIDenyRW);
  if (vFile>0) then begin
    vStamp # FsiStamp(vFile, _FsiDtModified);
    FsiClose(vFile);
  end;

  RETURN vStamp;
end;


//========================================================================
//  _AddWDFile
//========================================================================
sub _AddWDFile(
  aList     : int;
  aFile     : alpha(4000);
  aPath     : alpha(4000);
  aIsReport : logic);
local begin
  vItem : int;
end;
begin
//debugx('Watch file '+aFile+' : '+aPath);
  vItem # CteOpen(_cteItem);
  vItem->spname # aFile;
  if (aIsReport) then
    vItem->spcustom # aPath+'|'+cnvab(_GetStamp(aFile))+'|-1'
  else
    vItem->spcustom # aPath+'|'+cnvab(_GetStamp(aFile))+'|60';    // Wartezeit * 4
  CteInsert(alist, vItem);
end;


//========================================================================
//  _CheckFile
//========================================================================
sub _CheckFile(
  aName   : alpha(4000);
  aStamp  : bigint;
  ) : int;
local begin
  vI      : int;
  vFile   : int;
  vStamp  : bigint;
end;
begin

//debugx('check:'+aName);

  vI # FsiAttributes(aName);
  if (vI=_ErrFsiNoFile) then RETURN -100; // NO FILE = NO CHANGE

//  vFile # FsiRename(aName, aName+'X');
//  if (vFile<>0) then RETURN 0;          // 0 = keep trying
//  vFile # FsiRename(aName+'X', aName);
  vI # FsiOpen(aName, _FsiStdRead);
  if (vI<0) then RETURN 0;
  FsiClose(vI);

  vStamp # _GetStamp(aName);
  if (vStamp=0\b) then RETURN 0;

//debug('neu:'+cnvac(cnvcb(vStamp), _FmtCaltimeRFC));
//debug('alt:'+cnvac(cnvcb(aStamp), _FmtCaltimeRFC));

  if (vStamp=aStamp) then RETURN -1;    // NO CHANGE

  RETURN 1; // CHANGE !!!
end;


//========================================================================
//  _WDFiles
//========================================================================
sub _WDFiles(
  aList   : int;
  aWriter : int) : logic;
local begin
  vA,vB     : alpha(4000);
  vItem     : int;
  vItem2    : int;
  vI        : int;
  vCount    : int;
  vStamp    : bigint;
  vOK       : logic;
end;
begin

  FOR vItem # CteRead(aList, _CteFirst)
  LOOP vItem # CteRead(aList, _CteNext, vItem)
  WHILE (vItem<>0) do begin

    if (vItem2<>0) then begin
      CteDelete(aList, vItem2);
      vItem2 # 0;
    end;

//    vI # cnvia(vItem->spcustom);
//    if (vI=1) then begin

    vA # Str_token(vItem->spcustom, '|',1);
    vB # Str_token(vItem->spcustom, '|',2);

    vCount # cnvia(Str_token(vItem->spcustom,'|',3));
    if (vCount>0) then dec(vCount);
//if (vCount=0) then debugx('watching...');

    if (vCount>0) then begin
     dec(vCount);
     vItem->spcustom # vA+'|'+vB+'|'+aint(vCount);
   end;



  vStamp # cnvba(vB);

  // -100 = no file, 0 = readonly, -1 = no Change, 1 = CHANGE
  vI # _CheckFile(vItem->spname, vStamp);
//mydebug('Check :'+aint(vI));

  // is Report?
  if (vCount<0) then begin
    if (vI=-100) then begin // Datei fehlt noch
      CYCLE;
    end
    else begin
      _SendCmd(aWriter, cMsgWDReportReady, vItem->spname+'|'+vA);
//mydebug('SEND REPORT FOUND');
      vI # -1;    // vergiss das Item
      vOK # true;
    end;
  end
  else begin
    if (vI=-100) then CYCLE;  // kein File -> weiter
    // nix? Nach abwarten?
    if (vI=0) then begin
      if (vCount>0) then begin
        CYCLE;
      end;
    end;
    if (vI>0) then begin
//mydebug('verändert '+vItem->spname);
      // Info versenden...
      _SendCmd(aWriter, cMsgWDFileChanged, vItem->spname+'|'+vA);
//mydebug('send :'+vItem->spname+'|'+vB);
      vOK # true;
    end;
  end;

//  if (vI<>0) then begin
    if ((vCount<1) and (vI<0)) or (vI>0) then begin
//mydebug('vergiss '+vItem->spname);
      vItem2 # vItem;
    end;

  END;



  if (vItem2<>0) then begin
    CteDelete(aList, vItem2);
    vItem2 # 0;
  end;

  RETURN vOK;
end;


//========================================================================
//  WatchFile
//========================================================================
sub WatchFile(
  aName         : alpha(4000);
  aPath         : alpha(4000);
  opt aIsReport : logic);
begin
  if (aIsReport) then
    _SendCmd(gJobWriter, cMsgWatchFile, aName+'|'+aPath+'|Y')
  else
    _SendCmd(gJobWriter, cMsgWatchFile, aName+'|'+aPath+'|N');
end;


//========================================================================
//========================================================================
sub PrintOrder(
  aFilename     : alpha(4000);
  aExtension    : alpha;
  a912          : int;
  aDMSName      : alpha(4000);
  aOutputFile   : alpha(4000);
  aOnlyCreate   : logic;
);
local begin
  vItem       : int;
  vPrintOrder : int;
end;
begin

  vPrintOrder # VarAllocate(class_PrintOrder);
  clPO_Filename   # aFilename+'.'+aExtension;
  clPO_912        # a912;
  clPO_DMSName    # aDMSName;
  clPO_OutputFile # aOutPutFile;
  clPO_OnlyCreate # aOnlyCreate;

  vItem # CteOpen(_cteItem);
  vItem->spName   # aint(vItem);
  vItem->spcustom # aint(vPrintOrder);

  gPrintOrders->CteInsert(vItem);

  WatchFile(aFileName+'.'+aExtension, aint(vItem), true);
end;


//========================================================================
//  Init
//
//========================================================================
sub Init()
local begin
  vJob        : handle;
  vFileName   : alpha(1000);
  vMitSerial  : logic;
end;
begin

  if (DbaLicense(_DbaSrvLicense)='CE150588MN') then RETURN; // SSW

  vFilename # 'c:\wacon\serialportScanner.xml';
  vMitSerial # Lib_FileIO:FileExists(vFilename);

  if (Set.ExtArchiev.Path<>'CA1') and (Set.DokumentePfad<>'CA1') and (vMitSerial=false) then RETURN;


  gFrmMain->WinEvtProcNameSet(_WinEvtJob, 'Lib_Jobber:EvtJob');

  vJob # JobStart(_JobThread | _JobWinPrt, 0, 'Lib_Jobber:_Jobber', vFilename, 'StahlControl Thread TWO' );
  gJobController # JobOpen(vJob, gFrmMain);
if (gJobController<=0) then begin
  gJobController # 0;
  rETURN;
end;

  // Sendekanal öffnen
  gJobWriter # MsxOpen(_MsxThread | _MsxWrite, gJobController);
  // Empfangskanal öffnen
  gJobReader # MsxOpen(_MsxThread | _MsxRead, gJobController);


  // Scanner-Settings existieren? -> Scanner starten
  if (vMitSerial) then begin
    // Scannerdaten versenden...
    _SendCmd(gJobWriter, cMsgInitScanner, vFilename);
  end;

end;


//========================================================================
//  Term
//
//========================================================================
sub Term()
begin

  if (gJobWriter<>0) then begin
    MsxClose(gJobWriter);
    gJobWriter # 0;
  end;

  if (gJobReader<>0) then begin
    MsxClose(gJobReader);
    gJobReader # 0;
  end;

  if (gJobController<>0) then begin
    JobControl(gJobController, _JobTerminate);
    JobClose(gJobController);
    gJobController # 0;
  end;

  if (gBCSDLL<>0) then lib_BcsCom:SerialTerm();
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================
//========================================================================
sub _ShowReport(
  aID : int;
): alpha
//  aFilename : alpha(4000)) : alpha;
local begin
  vItem       : int;
  vFilename   : alpha(4000);
  vWaitFor    : alpha;

  vArc        : logic;
  vSprache    : alpha;
  aDMSName    : alpha;
  vFax        : alpha;
  vEMA        : alpha;
  vFile       : int;
  vA          : alpha(4000);
end;
begin

  vItem # aID;
//debug('hole id '+aint(aID));
  VarInstance(class_PrintOrder, cnvia(vItem->spcustom));
//debug(clPO_DMSName);

  vWaitFor  # StrCnv(FsiSplitName(clPO_Filename, _FsiNameE),_StrUpper);
  vFilename # FsiSplitName(clPO_Filename, _FsiNamePN);
//debugx('show '+vFilename+'   '+vWaitfor)

  if (clPO_OnlyCreate) then begin
    vArc # clPO_912->Frm.SpeichernYN;
    if (vSprache='') then vSprache  # 'D';
  //  if (aArcFrage) then begin
  //    if (Msg(912008,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdyes) then vArc # y;
  //  end;

    // Archivieren
    if (vArc) and (vWaitFor='PDF') then begin
      Lib_Dokumente:ImportPDF(vFilename+'.'+vWaitFor, clPO_912->Frm.Bereich, clPO_912->Frm.Name, clPO_DMSName, vSprache, vFAX, vEMA, false);
    end;

    gBCPS_OutputType # '';
    gBCPS_Outputfile # '';

    // Cleanup
    RecBufDestroy(clPO_912);
    gPrintOrders->CteDelete(vItem);
    VarFree(class_PrintOrder);
    CteClose(vItem);

    RETURN (vFilename+'.PDF');
  end;


  // Read Metadata...
  vFile # FsiOpen(vFilename+'.TXT', _FSISTdRead);//_FsiAcsR|_FSiDenynone);
  if (vFile>0) then begin
    FSIMark(vFile, 10);
    FSIRead(vFile, vA);
    WHILE (vA<>'') do begin
      vA # Str_Token(vA,StrChar(13),1);
//      if (StrCut(vA,1,5)='C16NAME:') then   vName # Str_Token(vA, ':', 2);
      if (StrCut(vA,1,4)='FAX:') then       vFAX # Str_Token(vA, ':', 2);
      if (StrCut(vA,1,6)='EMAIL:') then     vEMA # Str_Token(vA, ':', 2);
      if (StrCut(vA,1,9)='LANGUAGE:') then  vSprache # Str_Token(vA, ':', 2);
      FSIRead(vFile, vA);
    END;
    FSIClose(vFile);
  end;



  if (vWaitFor='DOCX') and (gBCPS_Outputfile<>'') then begin
    // KOPIEREN
    Lib_FileIO:FSICopy(vFilename+'.DOCX', gBCPS_Outputfile, false);
    Sysexecute('*'+gBCPS_Outputfile, '', _ExecMaximized);
  end
  else if (vWaitFor='XML') and (gBCPS_Outputfile<>'') then begin
    // KOPIEREN
    Lib_FileIO:FSICopy(vFilename+'.XML', gBCPS_Outputfile, false);
    Sysexecute('*'+gBCPS_Outputfile, '', _ExecMaximized);
  end;

//FSIOnitor
  vArc # clPO_912->Frm.SpeichernYN;
  if (vSprache='') then vSprache  # 'D';
  if (vWaitFor='PDF') then begin
//debugx('SHOW PDF '+aFilename+'.'+vWaitFor);
    Dlg_PDFPreview:ShowPDF(vFilename+'.'+vWaitFor,false,vEMA, vFAX, -1, 1);
  end;

//  if (aArcFrage) then begin
//    if (Msg(912008,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdyes) then vArc # y;
//  end;

  // Archivieren
  if (vArc) and (vWaitFor='PDF') then begin
//    Lib_Dokumente:InsertDok_NEW(Frm.Bereich, Frm.Name, vFilename+'.PDF', vSprache, vFAX, vEMA);
    Lib_Dokumente:ImportPDF(vFilename+'.'+vWaitFor, Frm.Bereich, Frm.Name, aDMSName, vSprache, vFAX, vEMA, false);
  end;

  // alles löschen
  lib_SQL:DeletePrintFiles(vFilename);

  // Cleanup
  RecBufDestroy(clPO_912);
  gPrintOrders->CteDelete(vItem);
  VarFree(class_PrintOrder);
  CteClose(vItem);

  RETURN 'OK';
end;


//========================================================================
//  _Jobber
//      Prozedur für weiten Thread
//========================================================================
sub _Jobber(
  aJob        : handle;
  aEvtType    : int);
local begin
  vA ,vB      : alpha(4000);
  vReader     : int;
  vWriter     : int;
  vMsg        : int;
  vScanner    : logic;

  vI,vJ       : int;
  vWDFilelist : int;
  vOK         : logic;
end;
begin

//liz_Data:mydebug('...jobber...');
  Liz_Data:StartThread();

  VarAllocate(VarSysPublic);   // public Variable allokieren
  gCodepage # _Sys->spCodepageOS;

  vA # aJob->spJobData;
//  if (vA<>'') then vScanner # Lib_BcsCom:Init_Datalogic(vA);


  // Empfangskanal öffnen
  vReader # MsxOpen(_MsxThread | _MsxRead, aJob);
  // Sendekanal öffnen
  vWriter # MsxOpen(_MsxThread | _MsxWrite, aJob);


  vWDFilelist # CteOpen(_Ctelist);

  WHILE (!aJob->spStopRequest) do begin

    // incoming Message?
    if (aJob->spJobMsxReadQ<>0) then begin
      _ReadCmd(vReader, var vMsg, var vA);
      case vMsg of

        cMsgInitScanner : begin
          vScanner # Lib_BcsCom:Init_Datalogic(vA);
        end;

        cMsgWatchfile   : begin
          vOK # (Str_token(vA,'|',3)='Y');
          vB # Str_token(vA,'|',2);
          vA # Str_token(vA,'|',1);
          _AddWDFile(vWDFilelist, vA, vB, vOK);
        end;

      end;  // case

    end;

    JobSleep(500);  // war 250 (nach VB HB)

    // Watchdog für Files
    if (_WDFiles(vWDFilelist, vWriter)) then begin
      aJob->JobEvent(100);    // Client informieren !!
    end;


    if (vScanner) then begin
      vA # '';
      Lib_BcsCom:SerialRead(var vA);
      if (vA<>'') then begin

        // CR am Ende entfernen
        if (StrTochar(vA,StrLen(vA))=13) then vA # StrCut(vA, 1, StrLen(vA)-1)

        // Scannerdaten versenden...
        _SendCmd(vWriter, cMsgScanned, vA);
        aJob->JobEvent(100);

        // warte auf Feedback...
        _ReadCmd(vReader, var vMsg, var vA);

        // an Scanner weiterleiten
        Lib_BcsCom:SerialWrite(vA);
      end;
    end;

  END;


  CteClear(vWDFilelist, y);
  CteClose(vWDFilelist);

  vReader->MsxClose();
  vWriter->MsxClose();

  if (gBCSDLL<>0) then lib_BcsCom:SerialTerm();

  VarFree(VarSysPublic);

  Liz_Data:StopThread();
end;


//========================================================================
//  EvtJob
//
//========================================================================
sub EvtJob(
  aEvt                 : event;    // Ereignis
  aJobCtrlHdl          : handle;   // Job-Kontroll-Objekt
) : logic;
local begin
  vA,vB   : alpha(4000);
  vHdl    : int;
  vMxID   : int;
  vMxI    : int;
  vI      : int;
  vDBACon : int;
end;
begin

  REPEAT
    if (aJobCtrlHdl->spJobMsxReadQ=0) then RETURN true;

    // read MSX
    if (gJobReader->MsxRead(_MsxMessage, vMxID)=_rOK) then begin
      gJobReader->MsxRead(_MsxItem, vMxI);
      gJobReader->MsxRead(_MsxData, vA);
      gJobReader->MsxRead(_MsxEnd, vMxI);
    end;


    // Message unterscheiden...
    case (vMxID) of

      // BARCODESCANNER
      cMsgScanned : begin
        if (gJobEvtProc<>'') then begin
          Call(gJobEvtProc, vA, var vB);
        end
        else begin
          vB # cESC+'[4q'+cESC+'[2J'+'kein Eingabefeld' + cESC + '[6q' + cESC + '[5q' + cESC +'[7q' + cCR

          vHdl # WinFocusget();
          if (vHdl<>0) then begin

            TRY begin
              ErrTryIgnore(_ErrAll);
              if (vHdl->wininfo(_Wintype)=_WinTypeIntEdit) then begin
                vHdl->wpcaptionint # cnvia(vA);
                vB # cESC+'[3q'+cESC+'[2J'+'ok'+cESC+'[8q' + cESC + '[5q' + cESC + '[9q' + cCR;
              end
              else if (vHdl->wininfo(_Wintype)=_WinTypeFloatEdit) then begin
                vHdl->wpcaptionfloat # cnvfa(vA);
                vB # cESC+'[3q'+cESC+'[2J'+'ok'+cESC+'[8q' + cESC + '[5q' + cESC + '[9q' + cCR;
              end
              else    if (vHdl->wininfo(_Wintype)=_WinTypeEdit) then begin
                vHdl->wpcaption # vA;
                vB # cESC+'[3q'+cESC+'[2J'+'ok'+cESC+'[8q' + cESC + '[5q' + cESC + '[9q' + cCR;
              end;
            END;
          end;
        end;
        // Feedback geben...
        if (vB<>'') then begin
          _SendCmd(gJobWriter, cMsgScannedResult, vB);
        end;
      end;


      cMsgWDFileChanged : begin

        if (RunAFX('Jobber.Filechanged',vA)<>0) then CYCLE;

        vB # Str_Token(vA, '|',2);
        vA # Str_Token(vA, '|',1);
        if (Msg(916002,FsiSplitName(vA, _FSiNameNE),_WinIcoQuestion, _WinDialogYesNo, 1)=_winidyes) then begin
          vB # FsiSplitName(vB, _fsinamePP);
          if (gDBAConnect=0) then begin
            if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBACon # 3
            else RETURN false;
          end;
          if (Lib_Blob:Import(vA, vB, cDBA, 0, true, var vI)<>_ErrOK) then begin
            Msg(99,'Error @ '+vA,0,0,0);
          end;
          if (vDBACon<>0) then DbaDisconnect(vDBACon);
        end;
      end;


      cMsgWDReportReady : begin
//debugx('got REPORTREADY : '+vA);
        vB # Str_Token(vA, '|',2);
        vA # Str_Token(vA, '|',1);
        _ShowReport(cnvia(vB));
      end;

    end;  // parse

  UNTIL (1=2);

  RETURN(true);
end;


//========================================================================