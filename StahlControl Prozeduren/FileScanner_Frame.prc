@A+
//===== Business-Control =================================================
//
//  Prozedur    FileScanner_Frame
//                    OHNE E_R_G
//  Info        Anzeige des "FileScanner"-Frames samt Scanning
//
//
//  04.07.2011  AI  Erstellung der Prozedur
//  26.07.2018  ST  Bugfix: "EvtFsiMonitor" prüft auf korrekten Pfad
//  14.08.2018  ST  Anzeige des aktuellen Datenbanknamens in Titelzeile
//  29.08.2018  ST  Fehlermeldung in Protokoll bei Startfehler
//  30.08.2018  ST  Erweiterung der Dateinamenlänge
//  02.07.2019  ST  Fehlerausgabe bei nicht vorhandenem Pfad
//  25.03.2020  ST  FileMonitor für Testsystem muss TEST im Pfad haben
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB Protokoll(aName : alpha(200));
//    SUB ProcessFile(aName : alpha(1000); aProc : alpha(200)) : logic;
//    SUB ScanAllFiles();
//    SUB EvtFsiMonitor(aEvt : event;aAction : int;aFileName : alpha;aFileAttrib : int;aFileSize : bigint;aFileCT : caltime;aFileNameOld : alpha) : logic;
//    SUB EvtMenuCommand(aEvt : event;aMenuItem : handle) : logic;
//    SUB EvtSocket(aEvt : event; aHandle : handle;aSubType : int) : logic;
//
//    MAIN
//
//========================================================================
@I:Def_Global

local begin
  vText   : int;
end;

define begin
//  cImportDir    : 'C:\SC_Import'
//  cDateiSchema  : '*.txt'
end;


//========================================================================
//  Protokoll
//
//========================================================================
sub Protokoll(
  aName : alpha(2000));
begin
  aName # cnvad(today)+' '+cnvat(now)+':'+aName;
  TextLineWrite(vText,1,aName,_TextLineInsert)
//  TextAddLine(vText,aName);
  if (gMDIpara<>0) then
    $ed.Text->winupdate(_WinUpdBuf2Obj);
end;


//========================================================================
//  Processfile
//
//========================================================================
sub ProcessFile(
  aName : alpha(2000);
  aProc : alpha(200)) : logic;
local begin
  vOK : logic;
end;
begin
  //vSize # vDirHdl->FsiSize(); // Dateigröße
  Protokoll('Read file:'+aName);

//todo('call '+aProc);
//  vOK # y;
  vOK # Call(aProc, aName);

  if (vOK=false) then begin
    Protokoll('ERROR');
    RETURN false
  end;

  Fsidelete(aName);
  Protokoll('OK');
  RETURN true;
end;


//========================================================================
//  ScanAllFiles
//
//========================================================================
sub ScanAllFiles();
local begin
  Erx       : int;
  vDirHdl   : int;
  vName     : alpha(2000);
  vTestSysFail : logic;
end;
begin

  Erx # RecRead(909,1,_recFirst);   // Alle Ordner loopen
  WHILE (Erx<=_rLocked) do begin

    if (isTestsystem AND (StrFind(StrCnv(FSP.Pfad,_StrUpper),'TEST',1) = 0)) then begin
      Erx # RecRead(909,1,_recNext);
      CYCLE;
    end;
    
    vDirHdl # FsiDirOpen(FSP.Pfad+'\'+FSP.Dateityp,_FsiAttrHidden);
    vName   # vDirHdl->FsiDirRead(); // erste Datei

    WHILE (vName != '') do begin
      //ProcessFile(cImportDir+'\'+vName);
      if (ProcessFile(FSP.Pfad+'\'+vName, FSP.Prozedur)=false) then begin
        BREAK;
      end;

      vName # vDirHdl->FsiDirRead();
    END;
    vDirHdl->FsiDirClose();

    Erx # RecRead(909,1,_recNext);
  END;

end;


//========================================================================
//  EvtFsiMonitor
//
//========================================================================
sub EvtFsiMonitor(
  aEvt                 : event;       // Ereignis
  aAction              : int;         // Dateioperation
  aFileName            : alpha(2000); // Dateiname
  aFileAttrib          : int;         // Dateiattribute
  aFileSize            : bigint;      // Dateigröße
  aFileCT              : caltime;     // Datum-/Uhrzeit der Änderung
  aFileNameOld         : alpha;       // Alter Dateiname beim Umbenennen
) : logic;
local begin
  Erx : int;
end;
begin

  if (aAction=_FsiMonActionDelete) then RETURN falsE;

  Erx # RecRead(909,1,_recFirst);   // Alle Ordner loopen
  WHILE (Erx<=_rLocked) do begin
    if (StrCnv(FsiSplitName(aFilename, _FsiNameP),_StrUpper) = StrCnv(FSP.Pfad,_StrUpper)) AND
       (StrCnv(FsiSplitName(aFilename, _FsiNameNE),_StrUpper) =*^StrCnv(FSP.Dateityp,_StrUpper)) then begin
       
      // File abarbeiten
      Processfile(aFilename, FSP.Prozedur);
    end;
    
    Erx # RecRead(909,1,_recNext);
  END;

  RETURN(true);
end;


//========================================================================
//  EvtMenuCommand
//
//========================================================================
sub EvtMenuCommand(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüpunkt / Toolbar-Button
) : logic;
begin

  if (aMenuItem->wpname='Mnu.Beenden') then begin
    WinClose(gMDI);
    RETURN true;
  end;

  if (aMenuItem->wpname='Mnu.Info') then begin
    if (gMDIPara=0) then begin
      gMDIPara  # WinOpen('Frame.FileScan',_WinOpendialog);
      WinDialogRun(gMDIPAra, _Windialogcenter | _WindialogApp);
      Winclose(gMDIPara);
      gMDIPara # 0;
    end;
  end;


  RETURN(true);
end;


//========================================================================
//  EvtInit
//
//========================================================================
sub EvtInit(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  $ed.Text->wpdbtextbuf # vText;
  $Frame.Filescan->wpCaption # 'Stahl Control - Filescanner: ' + DbaName(_DbaAreaAlias);
  RETURN(true);
end;


//========================================================================
//  EvtSocket
//
//========================================================================
sub EvtSocket(
  aEvt                 : event;    // Ereignis
  aHandle              : handle;   // Socket-Deskriptor
  aSubType             : int;      // Untertyp des Ereignisses
) : logic;
local begin
  Erx     : int;
  vMyIP   : alpha;
  vMyPort : int;
  vProc   : alpha;
end;
begin

  vMyIP   # SckInfo(aHandle,_SckAddrLocal);
  vMyPort # cnvia(SckInfo(aHandle,_SckPortLocal));

  Erx # RecRead(909,1,_recFirst);   // Alle Ordner loopen
  WHILE (Erx<=_rLocked) do begin
    if (FSP.Port<>0) then begin
      if (FSP.Port=vMyPort) and (FSP.IP=vMyIP) then begin
        vProc # FSP.Prozedur;
        BREAK;
      end;
    end;

    Erx # RecRead(909,1,_recNext);
  END;

  if (vProc<>'') then  begin
    Protokoll('Socket :'+vMyIP+':'+aint(vMyPorT));
    Call(vProc, aHandle, aSubType);
  end;

  RETURN(true);
end;


//========================================================================
// MAIN
//
//========================================================================
MAIN
local begin
  Erx       : int;
  vMonitor  : int;
  vSockets  : int[10];
  vSock     : int;
  vTestSysFail : logic;
end;
begin
   
  if (RecInfo(909,_recCount)=0) then RETURN;
  vTestSysFail  # false;

  VarAllocate(WindowBonus);

  gFrmMain  # WinOpen('Frame.Tray',_WinOpendialog);
  gFrmMain->wpCaption # 'Stahl Control - Filescanner: ' + DbaName(_DbaAreaAlias);
  gMDI      # gFrmMain;

  vMonitor # gFrmMain->FSIMonitorOpen(1000,1000);
  vText   # TexTOpen(20);
  Erx # RecRead(909,1,_recFirst);   // Alle Ordner loopen
  WHILE (Erx<=_rLocked) do begin
         
    vTestSysFail # isTestsystem AND (StrFind(StrCnv(FSP.Pfad,_StrUpper),'TEST',1) = 0);
    
    if (Lib_FileIO:PathExists(FSP.Pfad) AND (!vTestSysFail)) then begin
      if (FSP.Dateityp<>'') AND (FSP.Pfad<>'') then begin
        Protokoll('Pfad:  ' + FSP.Pfad + FSP.Dateityp);
        FSIMonitorAdd(vMonitor, FSP.Pfad, 0, '', FSP.Dateityp);
      end;
    end else
      Protokoll('Pfadfehler:  ' + FSP.Pfad);
      
    if (FSP.Port<>0) then begin
      inc(vSock);
      vSockets[vSock] # SckListen(FSP.IP, FSP.Port, gMDI);
    end;

    Erx # RecRead(909,1,_recNext);
  END;

  // Aufräumen...
  
  Erx # FsiMonitorControl(vMonitor,_FsiMonitorStart);
  if (Erx <> _rOK) then begin
    Protokoll('Fehler bei Scannerstart: ' + Aint(Erx));
  end else
    Protokoll('Filescanner gestartet...');
    
  ScanAllFiles();

  // Ausführen...
  WinDialogRun(gFrmMain, _Windialogcenter | _WindialogApp);
  WHILE (vSock>0) do begin
    SckClose(vSockets[vSock]);
    Dec(vSock);
  END;

  Winclose(gFrmMain);

  TextClose(vText);

  VarFree(WindowBonus);
end;


//========================================================================