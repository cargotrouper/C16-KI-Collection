@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Debug
//                  OHNE E_R_G
//  Info        Diverse Debug Routinen
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  16.03.2015  AH  BlueMode
//  26.01.2022  DS  Dbg_Debug funktioniert jetzt auch ohne laufendes SC;
//                  Dbg_Msg als shortcut für Debug Popup hinzugefügt;
//                  siehe auch Prozedur !Template_Dbg und define-shortcut DebugM() in Def_Global_Sys
//  2023-08-08  AH  Funktionen für Speedtests/Perfomance
//
//  Subprozeduren
//    SUB Dbg_Debug(aText : alpha(4000); opt aMitUser : logic)
//    SUB Dbg_Todo(aText : alpha(4000))
//    SUB Dbg_Msg(aText : alpha(4000); opt aInfoInTitle : alpha(4000))
//    SUB InitDebug()
//    SUB TermDebug()
//    SUB DebugModeEnter(aName : alpha)
//    SUB DebugModeLeave(aName : alpha)
//    SUB Protokoll(aName : alpha; aText : alpha(4096); opt aText2 : alpha; opt aText3 : alpha);
//    SUB ErrorLog();
//    SUB RunTimeErrorCatcher();
//    SUB ResetData(aImport : logic)
//    SFX StartBlueMode();
//    SFX StopBlueMode();
//    SUB Button();
//    SUB Button2();
//    SUB Dump(aDatei : int);
//
//========================================================================
@I:Def_global
@I:Def_Aktionen


define begin
  //cCheckstring : 'AufPos: KEY401'//aint(BAG.vpg.Verpackung)+' '+bag.vpg.vpgtext1
  cCheckstring : 'KEY700'
  cCheckLine : //if (gMDI<>0) then if (w_Name<>gMDI->wpname) then vA # 'XXXXX : '+aName+'  '+w_name;//if (gMDI<>0) then vA # vA + gMDi->wpname;// gzLList->wpname+' '+aint(gZLList->wpdbselection)
end;

declare Dump(aDatei : int);

/*
sub dbgTimespan(aText : alpha(4096)
local begin
begin
begin


  DebugStamp(a) : Lib_Debug:dbg_Debug(cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+' '+a)

end;
*/


//========================================================================
//  dbg_Filename
//
//========================================================================
sub dbg_Filename(opt aMitUsername : logic) : alpha;
local begin
  vUser : alpha;
  vName : alpha;
end;
begin
  vUser # UserInfo(_Username, cnvia(UserInfo(_UserCurrent)));
//  if (vUser='AH') then RETURN 'e:\debug\debug.txt';
  if (UserInfo(_UserSysName,  CnvIA(UserInfo(_UserCurrent)))='AH_2017') then vName # 'd:\debug\debug';
  else vName # 'c:\debug\debug';
  
  if (_Sys->spTerminalSession) and (_SYS->spTerminalSessionID>1) then begin
    vName # vName+'_TS'+aint(_SYS->spTerminalSessionID);
  end;
  
  if (aMitUsername) then
    vName # vName + '_'+vUser;
    
  RETURN vName + '.txt';
end;


//========================================================================
// _ParaseText
//========================================================================
Sub _ParseText(aText : alpha(4096)) : alpha;
local begin
  vX      : int;
  vDatei  : int;
  vKey    : alpha;
end;
begin
  vX # strfind(aText,'ERG',0);
  if (vX<>0) then
    aText   # StrCut(aText,1,vX-1) + ' Erg:'+cnvai(erg) + StrCut(aText,vX+3,999);

  vX # strfind(aText,'COUNT',0);
  WHILE (vX<>0) do begin
    vDatei  # cnvia(StrCut(aText, vX+5,3));
    vKey    # aint(RecInfo(vDatei,_Reccount));
    aText   # StrCut(aText,1,vX-1) + ' Count '+aint(vDatei)+':'+vKey+' '+ StrCut(aText,vX+8,999);
    vX # strfind(aText,'COUNT',0);
  END;

  vX # strfind(aText,'KEY',0);
  WHILE (vX<>0) do begin
    vDatei  # cnvia(StrCut(aText, vX+3,3));
    vKey    # Lib_rec:MakeKey(vDatei);
    vKey    # Str_ReplaceAll(vKey,StrChar(255),'/');
    vKey    # Str_ReplaceAll(vKey,'.','');
    aText   # StrCut(aText,1,vX-1) + ' Satz '+aint(vDatei)+':'+vKey +' '+ StrCut(aText,vX+6,999);
    vX # strfind(aText,'KEY',0);
  END;

  vX # strfind(aText,'RECID',0);
  WHILE (vX<>0) do begin
    vDatei  # cnvia(StrCut(aText, vX+5,3));
    vKey    # aint(recinfo(vDatei,_RecID));
    aText   # StrCut(aText,1,vX-1) + ' RecId '+aint(vDatei)+':'+vKey +' '+ StrCut(aText,vX+8,999);
    vX # strfind(aText,'RECID',0);
  END;

  RETURN aText;
end;


//========================================================================
//  Dbg_Debug
//        Schreibt in externe Debugdatei
//========================================================================
sub Dbg_Debug(
  aText         : alpha(4000);
  opt aMitUser  : logic;
)
local begin
  vFile   : int;
  vDatei  : int;
  vKey    : alpha;
end;
begin
//  WindialogBox(gFrmMain,'DEBUG',aText,_WinIcoInformation,_WinDialogOk,0)
//exit;
  aText # _ParseText(aText);
  
  // Prüfe zuerst ob namespace mit gUsername initialisiert ist, und nur dann, prüfe auf SOA user.
  // Dadurch kann diese Funktion auch ohne vollständig instanziiertes SC genutzt werden.
  if (VarInfo(VarSys) > 0) then begin
    if (StrCut(gUsername,1,3)='SOA') then begin
      Lib_Soa:Dbg(aText);
      RETURN;
    end
  end;

dbgtrace(atexT);
  //exit;
  aText # aText + strchar(13) + strchar(10);
  vFile # FSIOpen(dbg_FileName(aMitUser),_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
  if (vFile>0) then begin
    FsiWrite(vFile, aText);
    FsiClose(vFile);
  end;
end;


//========================================================================
//========================================================================
sub Dbg_Todo(aText : alpha(4000))
begin
  if (gFrmMain<>0) then
    WinDialogBox(0,'TODO','Hier kommt dann:'+_ParseText(aText),_WinIcoInformation,_WinDialogOk,0)
end;


//========================================================================
//  Dbg_Msg
//        Zeigt ein Popup mit Debug Text
//========================================================================
sub Dbg_Msg(
  aText : alpha(4000);  // auszugebender Text
  opt aInfoInTitle : alpha(4000);  // Information die im Title der MsgBox erscheinen soll, z.B. __PROC__+':'+aint(__LINE__), siehe dazu auch DebugM in Def_Global_Sys (Shortcut)
)
local begin
  vTitle : alpha;
end;
begin

  vTitle # 'DEBUG';
  
  if (aInfoInTitle <> '') then begin
    vTitle # vTitle + '   ['+aInfoInTitle+']';
  end
  
  WinDialogBox(0, vTitle, aText, _WinIcoInformation, _WinDialogOk, 1);
  
end;



//========================================================================
//  InitDebug
//            Initialisiert Debug (z.b. Debugger an, Externe Datei leeren...)
//========================================================================
sub InitDebug()
begin

//  DbgConnect('*',n,n);
//  DbgControl(_DbgEnteroff);
//  DbgControl(_DbgLeave);
  DbgTrace('*** START ***');


  Fsidelete(dbg_Filename())
end;


//========================================================================
//  TermDebug
//            Schliessen der Debugumgebung
//========================================================================
sub TermDebug(
)
begin
  DbgTrace('*** END ***');
  DbgControl(_DbgEnterOff);
  DbgControl(_DbgLeave);
  // DbgDisConnect();
end;


//========================================================================
//  DebugModeEnter
//
//========================================================================
sub DebugModeEnter(aName : alpha)
local begin
  vHdl  : int;
  vI    : int;
  vA    : alpha(500);
end;
begin
/*
  if (aName='Action') then RETURN;
  if (aName='EvtInit') then RETURN;
  if (aName='Refreshmode') then RETURN;
  if (GV.alpha.70='') then RETURN;

if (GV.alpha.70<>'') and (GV.alpha.70<>'X') then TODO('BREAK von '+gv.alpha.70+' durch '+aName);
GV.Alpha.70 # aName;
*/
  if (gDebugDepth>0) then vA # StrChar(32,gDebugDepth*2);
  vA # vA + aName;
  inc(gDebugDepth);

  if (gMdi<>0) then
    vA # vA + '   MDI:'+gMdi->wpname;//+':'+mode;
  vA # vA + cCheckSTring;
  cCheckLine

//  vA # vA + '   '+cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds);
//  vA # vA + '   LFS:'+cnvai(Lfs.Nummer);
//  vA # vA + '   A:'+anum(bag.f.breite,0);
  vI # winfocusget(); if (vI<>0) then vA # vA + ('   aktfocus:'+vI->wpname);

  Dbg_debug(vA);
RETURN;

  if (gMdi=0) then RETURN;
  vHdl # Winsearch(gMdi,'NB.Main');
  if (vHdl<>0) then begin
    Dbg_debug(aName+' CUSTOM        '+vHdl->wpcustom);
  end;
end;


//========================================================================
//  DebugModeLeave
//
//========================================================================
sub DebugModeLeave(aName : alpha)
local begin
  vHdl  : int;
  vI    : int;
  vA    : alpha(500);
end;
begin
/*  if (aName='Action') then RETURN;
  if (aName='EvtInit') then RETURN;
  if (aName='Refreshmode') then RETURN;
  if (GV.alpha.70='') then RETURN;

GV.Alpha.70 # 'X';
*/
  Dec(gDebugDepth);
  if (gDebugDepth>0) then vA # StrChar(32,gDebugDepth*2);
  vA # vA + '<<'+aName;

  if gMdi<>0 then
    vA # vA + '   MDI:'+gMdi->wpname;//+':'+mode;
  vA # vA + cCheckString;
  cCheckLine

//  vA # vA + '   '+cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds)cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds);
//  vA # vA + '   LFS:'+cnvai(Lfs.Nummer);
//  vA # vA + '   file:'+cnvai(gFile);
//  vA # vA + '   A:'+anum(bag.f.breite,0);
  vI # winfocusget(); if (vI<>0) then vA # vA + ('   aktfocus:'+vI->wpname);

  Dbg_debug(vA);
  Dbg_debug('');
RETURN;
//  debug(':'+gMdi->wpcustom+'   '+cnvai(VarInfo(WindowBonus)))

  if (gMdi=0) then RETURN;
  vHdl # Winsearch(gMdi,'NB.Main');
  if (vHdl<>0) then begin
    Dbg_debug(aName+' CUSTOM        '+vHdl->wpcustom);
  end;
end;


//========================================================================
// Protokoll
//========================================================================
sub Protokoll(
  aName       : alpha;
  aText       : alpha(4096);
  opt aText2  : alpha;
  opt aText3  : alpha);
local begin
  Erx   : int;
  vTxt  : int;
  vI    : int;
end;
begin
  aText # StrFmt(cnvad(today)+':'+cnvat(now)+' '+gUsername,40,_StrEnd) + atext;
  if (aText2<>'') then aText # aText + ' | '+aText2;
  if (aText3<>'') then aText # aText + ' | '+aText3;

  vTxt # TextOpen(20);
  if (StrCut(aName,2,1)=':') then
    Erx # TextRead(vTxt, aName, _TextLock|_TextExtern)
  else
    Erx # TextRead(vTxt, aName, _TextLock);
  if (Erx>_rLocked) then begin
    TextClear(vTxt);
    TextAddLine(vtxt, '[neuer Text}');
  end;
  WHILE (erx=_rLocked) and (vI<100) do begin
    Winsleep(50);
    Erx # TextRead(vTxt, aName, _TextLock);
    inc(vI);
    if (vI=100) then Begin
      TextClose(vTxt);
      DbaLog(_LogError, false, 'SC-Protokoll nicht schreibbar!');
      RETURN;
    end
  END;
  TextAddLine(vTxt, aText);

  if (StrCut(aName,2,1)=':') then
    TextWrite(vTxt, aName, _textUnlock|_TextExtern)
  else
    TextWrite(vTxt, aName, _textUnlock);
  TextClose(vTxt);
//debugx('writetext '+aName+': '+aText);
end;



//========================================================================
//  StrProc
//
//========================================================================
sub StrProc(
  aProc             : alpha(  61);
) : alpha
local begin
  tPosi             : int;
end;
begin
  tPosi # StrFind(aProc, ':', 1);
  if (tPosi > 0) then
    RETURN (StrCut(aProc, 1, tPosi - 1));
  RETURN (aProc);
end;


//========================================================================
//  ErrorLog
//
//========================================================================
sub ErrorLog(
  aCode             : int;
  aText             : alpha( 128);
  aProc             : alpha(  61);
  aLine             : int;
  aSource           : alpha(  20);
)
local begin
  vLine             : alpha( 250);
  vGroup            : alpha;
  vA,vB             : alpha(2000);
  vHdl              : int;
end;
begin
  vGroup # gUsergroup;
  if (vGroup='') then vGroup # gUserName;

  // Fehlercode ,-text und -prozedur ausgeben
  vLine #
    CnvAI(aCode, _FmtInternal) + ' ' +
    '(' + aText + ')' + ' ' +
    aProc;

  // Fehler in Include-Prozedur
  if (StrProc(aProc) != aSource) then begin
    // Include-Prozedur ausgeben
    vLine # vLine +
      '/' + aSource
    ;
  end;
  // Fehlerzeile ausgeben
  vLine # vLine +
    ' ' +
    '[' + CnvAI(aLine, _FmtInternal) + ']';

  // Textdateimodus
//  if (gMode & _ErrModeTxt != 0 and gFile != '') then
//    TxtLine(tLine);

  // Protokollmodus
//  if (gMode & _ErrModeLog != 0) then
  DbaLog(_LogError, N, StrCut(vLine+'|U:'+gUsername,1,250));

  if (VarInfo(Windowbonus)>0) then begin
    vA # 'I: ' +w_Name;
    vHdl # Winfocusget();
    vB # '';
    WHILE (vHdl<>0) do begin
      if (vB='') then vB # vHdl->wpname
      else vB # vHdl->wpname + '->' + vB;
      vHdl # WinInfo(vHdl,_winparent);
    END;
    if (vB<>'') then vB # '   O: '+vB;
    vA # vA + vB + StrChar(13) + StrChar(13);
  end;

  APPON();

  vB # '';
  case (gUserSprachnummer) of
    1 : vB # Set.Sprache1.Kurz;
    2 : vB # Set.Sprache2.Kurz;
    3 : vB # Set.Sprache3.Kurz;
    4 : vB # Set.Sprache4.Kurz;
    5 : vB # Set.Sprache5.Kurz;
  end;
  if (vB='D') or (vB='') then begin
    WHILE (WindialogBox(gFrmMain,'RUNTIMEERROR',vLine + StrChar(13) + StrChar(13) + vA +
      '!!! Bitte beim Hersteller MELDEN und das Programm KOMPLETT BEENDEN !!!',_WinIcoError, _WinDialogOkCancel,1)=_winidok) do
      WinSleep(100);
    end
  else begin
    WHILE (WindialogBox(gFrmMain,'RUNTIMEERROR',vLine + StrChar(13) + StrChar(13) + vA +
      '!!! Please REPORT this to the developer and CLOSE the whole program !!!',_WinIcoError, _WinDialogOkCancel,1)=_winidok) do
      WinSleep(100);
  end;

/*****
  // Transaktion noch aktiv?
  if (TransActive) then begin
    WHILE (TransActive) do
      TRANSBRK;
    Msg(001103,'',0,0,0);
  end;

  // TAPI beenden
  Lib_Tapi:TAPITerm();

  // Aufräumen
  varfree(VarSysPublic);
  Liz_Data:SystemTerm();

  // Abschalten ausser bei Programmierern
  //if (vGroup<>'PROGRAMMIERER') then
  WinHalt();
****/

end;


//========================================================================
//  RunTimeErrorCatcher
//
//========================================================================
sub RunTimeErrorCatcher();
begin
  // Fehler protokollieren
  ErrorLog(
    _Sys -> spErrCode,    // Fehlercode ermitteln
    _Sys -> spErrText,    // Fehlertext ermitteln
    _Sys -> spErrProc,    // Fehlerprozedur ermitteln
    _Sys -> spErrLine,    // Fehlerzeile ermitteln
    _Sys -> spErrSource   // Include-Prozedur ermitteln
  );
end;


//========================================================================
//  ResetData
//
//========================================================================
sub ResetData(aImport : logic)
begin
  if (WinDialogBox(gFrmMain,'Resetdata', Translate('Wirklich auf Platte NEU schreiben???'),_WinIcoWarning,_WinDialogYesNo,2)=_WinIDYes) then begin
    CallOld('old_autoTransfer',200,aImport);
    CallOld('old_autoTransfer',201,aImport);
    CallOld('old_autoTransfer',202,aImport);
    CallOld('old_autoTransfer',203,aImport);
    CallOld('old_autoTransfer',204,aImport);
    CallOld('old_autoTransfer',205,aImport);

    CallOld('old_autoTransfer',400,aImport);
    CallOld('old_autoTransfer',401,aImport);
    CallOld('old_autoTransfer',402,aImport);
    CallOld('old_autoTransfer',403,aImport);
    CallOld('old_autoTransfer',404,aImport);
    CallOld('old_autoTransfer',405,aImport);
    CallOld('old_autoTransfer',406,aImport);
    CallOld('old_autoTransfer',407,aImport);
    CallOld('old_autoTransfer',408,aImport);
    CallOld('old_autoTransfer',409,aImport);
    CallOld('old_autoTransfer',440,aImport);
    CallOld('old_autoTransfer',441,aImport);

    CallOld('old_autoTransfer',700,aImport);
    CallOld('old_autoTransfer',701,aImport);
    CallOld('old_autoTransfer',702,aImport);
    CallOld('old_autoTransfer',703,aImport);
    CallOld('old_autoTransfer',704,aImport);
    CallOld('old_autoTransfer',705,aImport);
    CallOld('old_autoTransfer',706,aImport);
    CallOld('old_autoTransfer',707,aImport);
    CallOld('old_autoTransfer',709,aImport);
  end;

end;


sub Scan(
  aPfad   : alpha;
  aFarbe  : int;
  aDPI    : float;
)
local begin
 tHdl     : int;
 vZiel    : alpha;
 vPos     : int;
end
begin

   // Bestimmt Zielpfad

   // Sucht vom Ende des Pfades nach dem ersten '\' um den Dateinamen
   // abzuschneiden
   for vPos # StrLen(aPfad) loop dec(vPos) while (vPos > 0) do
   begin
    if (StrToChar(aPfad, vPos) = 92) then
      break;
   end;

   // Kein '\', ungültiger Pfad
   if (vPos = 0) then return;

   vZiel # StrCut(aPfad, 1, vPos);

   // Pfad ist okay, beginne Scan
//todo('A');
//   tHdl # DllLoad('TWAIN\c16twain.dll');
   tHDL # DLLLoad('Z:\C16\client.55\TWAIN\c16twain.dll');
 todo('B '+cnvai(tHDL));
   DllCall(tHdl, 1, aPfad, aFarbe, aDPI);
   tHdl->DllUnload();

   // Wandle bmp in jpg um
//   SysExecute('TWAIN\PVW32Con.exe',aPfad + ' -j --o ' + vZiel, _ExecWait | _ExecMinimized);

   // Lösche bmp
   FsiDelete(aPfad);

end;


//========================================================================
//  SFX StartBlueMode
//
//========================================================================
sub StartBlueMode();
local begin
  vWinBonus     : int;
  vFocus        : int;
  vMDI          : int;
end;
begin

  if (gBlueMode) then RETURN;
  vMDI # gMDI;
  vWinBonus # Varinfo(WindowBonus);
  vFocus    # WinFocusGet();

  gBlueMode # true;
  TRANSON;
  Transcount # Transcount - 1;
  TransActive # false;  // 24.10.2018 AH

  gFrmMain->wpautoupdate # false;

  gFrmMain->wpVisible # false;


//  Set.Appli.Caption # '!!! BLAUER MODUS !!! %DB%'
  gFrmMain->wpCaption # '!!! BLAUER MODUS !!!';

  //vA # '!!! TRANSACTION OPEN !!!';
  if ( DbaInfo( _dbaReadOnly ) <= 0 ) then
    gFrmMain->wpColBkgApp # _winColLightBlue
  else
    gFrmMain->wpColBkgApp # _winColYellow;

  gFrmMain->wpautoupdate # true;
  gFrmMain->wpVisible # true;

  Winupdate(gMDIWorkbench, _Winupdon|_WinUpdActivate);
  Winupdate(gFrmMain, _Winupdon|_WinUpdActivate);

  if (vWinBonus<>0) then
    VarInstance(WindowBonus, vWinBonus);
  if (vMDI<>0) then begin
    WinFocusset(vMDI);
    WinUpdate(vMdi,_WInupdon);
    gMDI # vMDI;
  end;
  if (vFocus<>0) then
    WinFocusset(vFocus);
end;


//========================================================================
//  SFX StopBlueMode
//
//========================================================================
sub StopBlueMode();
local begin
  vA  : alpha(250);
end;
begin

  if (gBlueMode=false) then RETURN;

  if (Transcount>0) then begin
    WHILE (Transcount>0) do
      TRANSBRK;
    Msg(001103,'',0,0,0);
  end;

  gBlueMode # false;
  Transcount # Transcount + 1;
  TRANSBRK;

  gFrmMain->wpautoupdate # false;
  gFrmMain->wpVisible # false;

  if ( Set.Appli.Caption = '' ) then
    Set.Appli.Caption # 'Business Control%_%%_%%_%Datenbank: %DB%%_%%_%angemeldet als: %USER%%_%%_%am: %DATE%';

  // Bezeichnung generieren
  Set.Appli.Caption # Set.Appli.Caption + vA
  vA # StrFmt( vA, 10, _strEnd );
  vA # Str_ReplaceAll( Set.Appli.Caption, '%_%', vA );
  vA # Str_ReplaceAll( vA, '%DB%',   DbaName( _dbaAreaAlias ) );
  vA # Str_ReplaceAll( vA, '%USER%', gUserName );
  vA # Str_ReplaceAll( vA, '%DATE%', CnvAD( today ) );
  if ( StrFind( StrCut( vA, 1, 159 ), 'Business Control', 1, _strCaseIgnore ) > 0 ) then
    gFrmMain->wpCaption # vA;
  else
    gFrmMain->wpCaption # StrCut( vA, 1, 143 ) + 'Business Control';

  if ( DbaInfo( _dbaReadOnly ) > 0 ) then begin
    gFrmMain->wpColBkgApp # _winColRed;
  end
  else begin
    gFrmMain->wpColBkgApp # _WinColAppWorkSpace;
  end;

  gFrmMain->wpautoupdate # true;
  gFrmMain->wpVisible # true;

  Winupdate(gMDIWorkbench, _Winupdon|_WinUpdActivate);
  Winupdate(gFrmMain, _Winupdon|_WinUpdActivate);

end;


//========================================================================
//  Button
//
//========================================================================
sub Button();
local begin
  vX        : float;
  vI,vJ     : int;
  vHdl2     : int;
  vA,vB     : alpha;
  vRect     : rect;
  vFont     : font;
  vDia      : int;
  vMsg      : int;
  vProgress : int;
  vHdl      : int;
  vTxt      : int;
  vTree     : int;
  vCount    : int;
  vSplash   : int;
  vWinBonus : int;
  vCT       : caltime;

  /// -----
  vStart, vEnd : alpha;
  vStartTime : caltime;
  vEndTime   : caltime;

  v701 : int;
  v702 : int;
  v703 : int;
  v707 : int;
  vCmd : int;
  
  vOposnr : int;
  
  

  vM        : float;
  vGew      : float;
  vStk      : int;
  
  vErr   : int;
  
  vx2 : handle;
  vy : handle;
  
  Erx : int;
end;
begin
SFX_BSP_LFS:LfsVerbuchenJob(1005);
  //SVC_WEBAPP_Action:LfsAusNeuerVerladung(0,'[2242062]', today, 15000.0, 0,'0')
 // SFX_BSP_Job:LFS_Verbuchen(1005);
  return;
  // Ausgabe des aktuellen Dialog-Namens:
  // !!!! BITTE NACH ANDERWEITIGER NUTZUNG DES DEBUG BUTTONS IMMER WIEDER REINKOMMENTIEREN!!!!
  Lib_Auxiliaries:printCurrentDialogName();
  return;
  
  
   v701 # RecBufCreate(200);
  // v701->
  
  //SVC_WEBAPP_Action:MatDelInfo(0,2);//LfsVerbucheVldaw(0,941,'3664,3666', true);
  //L_STD_MDE_Usr:StartList();
  return
  if (gUsername='AH') then  Lib_http.core:TestAlex()
  else begin
  //Erx # SVC_Jsn_Example:execMemory(aArgs : handle; var aMem : handle; var aContentType : alpha ) : int
  end;
   
  RETURN;
  
  
  
  
  
 
  
  RETURN;
  
  Msg(99,'hallo',_WinIcoApplication,_WinDialogOk,_WinIdOk);
  
  ErrorOutput;
  
  TODO('START: ' + Aint(ErrList));
  
  
  Error(99,'EINS');
  
  TODO('MITTE: ' + Aint(ErrList));
  
  Error(99,'ZWEI');
    
  ErrorOutput;
  
  
  
  TODO('ENDE: ' + Aint(ErrList));
  
  Error(99,'Fehler vom Vorgänger');

RETURN;


Lib_PasswordMgr:Test();


/*
gUsergroup # 'SOA_SERVER';
SVC_WEBAPP_Action:DruckEtikett(0,'[4794,4810,4811,5222,3508]',51);
*/
RETURN;
  Todo(Userinfo(_UserAddress,CnvIa(UserInfo(_UserCurrent))));
  


end;


//========================================================================
//  Button2
//
//========================================================================
sub Button2();
local begin
  vHdl : int;
  vBuf  : int;
  vA  : alpha(1000);
  vSOAPDocMetaData    : alpha;
  vOK  :  logic;
end;
begin

Lib_PasswordMgr:TestInsert();

end;


//========================================================================
//  _DebugFile
//
//========================================================================
sub _DebugFile(
  aDatei  : int;
  aTds    : int);
local begin
  vMaxTds   : int;
  vMaxFld   : int;
  vTds      : int;
  vFld      : int;
  vA        : alpha(200);
end;
begin

  vMaxTds # FileInfo(aDatei,_FileSbrCount);

  Debug('----------------------------------------------------------');
  debug('File:'+aint(aDatei));
  debug('');
  /* Dateinamen schreiben */
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    if (aTds=0) or (aTds=vTds) then begin
      vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
      FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
        case FldInfo(aDatei,vTds,vFld,_KeyFldType) of
          _TypeAlpha  : vA # StrFmt(FldAlpha(aDatei,vTds,vFld),20,_StrEnd);
          _TypeWord   : vA # CnvAI(FldWord(aDatei,vTds,vFld));
          _TypeInt    : vA # CnvAI(FldInt(aDatei,vTds,vFld));
          _TypeFloat  : vA # CnvAF(FldFloat(aDatei,vTds,vFld),_FmtNumNoGroup,0,5);
          _TypeDate   : vA # CnvAD(FldDate(aDatei,vTds,vFld));
          _TypeTime   : vA # CnvAT(FldTime(aDatei,vTds,vFld));
          _TypeLogic  : if FldLogic(aDatei,vTds,vFld) then vA # 'TRUE' else vA # 'FALSE';
        end;
        vA # StrFmt(FldName(aDatei,vTds,vFld),20,_strend) + ' : '+vA;
        debug(vA);
      end;
    END;
  END;

  Debug('----------------------------------------------------------');

end;


//========================================================================
//========================================================================
sub TypeToString(aTyp : int) : alpha;
begin
  case aTyp of
    _WinTypeAnimation        : RETURN '_WinTypeAnimation';
    _WinTypeAppFrame         : RETURN '_WinTypeAppFrame';
    _WinTypeApplication      : RETURN '_WinTypeApplication';
    _WinTypeBigIntEdit       : RETURN '_WinTypeBigIntEdit';
    _WinTypeButton           : RETURN '_WinTypeButton';
    _WinTypeC16Info          : RETURN '_WinTypeC16Info';
    _WinTypeCalendar         : RETURN '_WinTypeCalendar';
    _WinTypeCheckBox         : RETURN '_WinTypeCheckBox';
    _WinTypeColorButton      : RETURN '_WinTypeColorButton';
    _WinTypeColorEdit        : RETURN '_WinTypeColorEdit';
    _WinTypeCtxAdobeReader   : RETURN '_WinTypeCtxAdobeReader';
    _WinTypeCtxDocEdit       : RETURN '_WinTypeCtxDocEdit';
    _WinTypeCtxDocEditRuler  : RETURN '_WinTypeCtxDocEditRuler';
    _WinTypeCtxDocEditTBar   : RETURN '_WinTypeCtxDocEditTBar';
    _WinTypeCtxOffice        : RETURN '_WinTypeCtxOffice';
    _WinTypeDataList         : RETURN '_WinTypeDataList';
    _WinTypeDataListPopup    : RETURN '_WinTypeDataListPopup';
    _WinTypeDateEdit         : RETURN '_WinTypeDateEdit';
    _WinTypeDecimalEdit      : RETURN '_WinTypeDecimalEdit';
    _WinTypeDialog           : RETURN '_WinTypeDialog';
    _WinTypeDivider          : RETURN '_WinTypeDivider';
    _WinTypeDocView          : RETURN '_WinTypeDocView';
    _WinTypeDragDataFormat   : RETURN '_WinTypeDragDataFormat';
    _WinTypeDragDataObject   : RETURN '_WinTypeDragDataObject';
    _WinTypeEdit             : RETURN '_WinTypeEdit';
    _WinTypeFloatEdit        : RETURN '_WinTypeFloatEdit';
    _WinTypeFontNameEdit     : RETURN '_WinTypeFontNameEdit';
    _WinTypeFontSizeEdit     : RETURN '_WinTypeFontSizeEdit';
    _WinTypeFrame            : RETURN '_WinTypeFrame';
    _WinTypeFrameClient      : RETURN '_WinTypeFrameClient';
    _WinTypeGanttAxis        : RETURN '_WinTypeGanttAxis';
    _WinTypeGanttGraph       : RETURN '_WinTypeGanttGraph';
    _WinTypeGanttView        : RETURN '_WinTypeGanttView';
    _WinTypeGroupBox         : RETURN '_WinTypeGroupBox';
    _WinTypeGroupColumn      : RETURN '_WinTypeGroupColumn';
    _WinTypeGroupSplit       : RETURN '_WinTypeGroupSplit';
    _WinTypeGroupTile        : RETURN '_WinTypeGroupTile';
    _WinTypeHyperLink        : RETURN '_WinTypeHyperLink';
    _WinTypeIcon             : RETURN '_WinTypeIcon';
    _WinTypeIntEdit          : RETURN '_WinTypeIntEdit';
    _WinTypeInterval         : RETURN '_WinTypeInterval';
    _WinTypeIvlBox           : RETURN '_WinTypeIvlBox';
    _WinTypeIvlLine          : RETURN '_WinTypeIvlLine';
    _WinTypeLabel            : RETURN '_WinTypeLabel';
    _WinTypeListColumn       : RETURN '_WinTypeListColumn';
    _WinTypeMdiFrame         : RETURN '_WinTypeMdiFrame';
    _WinTypeMenu             : RETURN '_WinTypeMenu';
    _WinTypeMenuButton       : RETURN '_WinTypeMenuButton';
    _WinTypeMenuItem         : RETURN '_WinTypeMenuItem';
    _WinTypeMetaPicture      : RETURN '_WinTypeMetaPicture';
    _WinTypeNotebook         : RETURN '_WinTypeNotebook';
    _WinTypeNotebookPage     : RETURN '_WinTypeNotebookPage';
    _WinTypePicture          : RETURN '_WinTypePicture';
    _WinTypePopupList        : RETURN '_WinTypePopupList';
    _WinTypeProgress         : RETURN '_WinTypeProgress';
    _WinTypePrtJobPreview    : RETURN '_WinTypePrtJobPreview';
    _WinTypePrtPpvControl    : RETURN '_WinTypePrtPpvControl';
    _WinTypePrtPreviewDlg    : RETURN '_WinTypePrtPreviewDlg';
    _WinTypeRadioButton      : RETURN '_WinTypeRadioButton';
    _WinTypeRecList          : RETURN '_WinTypeRecList';
    _WinTypeRecListPopup     : RETURN '_WinTypeRecListPopup';
    _WinTypeRecNavigator     : RETURN '_WinTypeRecNavigator';
    _WinTypeRecView          : RETURN '_WinTypeRecView';
    _WinTypeRTFEdit          : RETURN '_WinTypeRTFEdit';
    _WinTypeSelDataObject    : RETURN '_WinTypeSelDataObject';
    _WinTypeStatusbar        : RETURN '_WinTypeStatusbar';
    _WinTypeStatusbarButton  : RETURN '_WinTypeStatusbarButton';
    _WinTypeStoList          : RETURN '_WinTypeStoList';
    _WinTypeTextEdit         : RETURN '_WinTypeTextEdit';
    _WinTypeTimeEdit         : RETURN '_WinTypeTimeEdit';
    _WinTypeToolbar          : RETURN '_WinTypeToolbar';
    _WinTypeToolbarButton    : RETURN '_WinTypeToolbarButton';
    _WinTypeToolbarDock      : RETURN '_WinTypeToolbarDock';
    _WinTypeToolbarRTF       : RETURN '_WinTypeToolbarRTF';
    _WinTypeTrayFrame        : RETURN '_WinTypeTrayFrame';
    _WinTypeTreeNode         : RETURN '_WinTypeTreeNode';
    _WinTypeTreeView         : RETURN '_WinTypeTreeView';
    _WinTypeWebNavigator     : RETURN '_WinTypeWebNavigator';
    _WinTypeWindowbar        : RETURN '_WinTypeWindowbar';
  end;

  RETURN '??? '+aint(aTyp);
end;

//========================================================================
//========================================================================
sub TestDelay();
local begin
  Erx : int;
end;

begin
  Gv.int.01 # CteOpen(_CteList); // Liste erzeugen
  for Erx # 1 loop inc(Erx) while Erx<1500000 do begin
  Gv.int.02 # Gv.int.01->CteRead( _cteFirst );
  Gv.int.02 # Gv.int.01->CteRead( _cteFirst );
  Gv.int.02 # Gv.int.01->CteRead( _cteFirst );
  Gv.int.02 # Gv.int.01->CteRead( _cteFirst );
  FOR   Gv.int.02 # Gv.int.01->CteRead( _cteFirst )
    LOOP  Gv.int.02 # Gv.int.01->CteRead( _cteNext, gv.int.02)
    WHILE (gv.int.02 <> 0) do begin
    END;
  END;
end;


//========================================================================
//========================================================================
sub Dump(aDatei : int);
local begin
  vMaxTds   : int;
  vMaxFld   : int;
  vTds      : int;
  vFld      : int;
  vFldName  : alpha;
  vA        : alpha(255);
  vDatei    : int;
end
begin

Debug('Dump von '+aint(aDatei));

  vDatei # aDatei;
  if (aDatei>1000) then
    vDatei # HdlInfo(aDatei,_HdlSubType);


  vMaxTds # FileInfo(vDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin

    vMaxFld # SbrInfo(vDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin

      vFldName # FldName(vDatei, vTds, vFld);
      vA # '';
//if (FldInfo(aDatei, vTds, vFld,_FldType)<>_TypeFloat) then
//CYCLE;
      case FldInfo(vDatei, vTds, vFld,_FldType) of
        _TypeAlpha  : vA # FldAlpha(aDatei, vTds, vFld);
        _TypeDate   : if (FldDate(aDatei, vTds, vFld)=0.0.0) then CYCLE
                      else vA # cnvad(FldDate(aDatei, vTds, vFld));
        _Typeword   : if (FldWord(aDatei, vTds, vFld)=0) then CYCLE
                      else vA # aint(FldWord(aDatei, vTds, vFld));
        _typeint    : if (FldInt(aDatei, vTds, vFld)=0) then CYCLE
                      else vA # aint(FldInt(aDatei, vTds, vFld));
        _Typefloat  : if (FldFloat(aDatei, vTds, vFld)=0.0) then CYCLE
                      else vA # anum(FldFloat(aDatei, vTds, vFld),5);
        _typelogic  : if (FldLogic(aDatei, vTds, vFld)) then vA # 'TRUE' else vA # 'FALSE';
        _TypeTime   : vA # cnvat(FldTime(aDatei,vTds,vFld));
        _TypeBigInt : if (FldBigInt(aDatei, vTds, vFld)=0) then CYCLE
                      else vA # cnvab(FldBigInt(aDatei, vTds, vFld));
otherwise todo('XX');
      end;
      if (vA='') then CYCLE;

      debug(vFldName+' = '+vA);
    END;
  END;

end;


/*========================================================================
2023-08-07  AH
========================================================================*/
Sub InitTime()
begin
  RecbufClear(950);   // Controlling "missbrauchen"
end;


/*========================================================================
2023-08-07  AH
========================================================================*/
Sub StartTime()
begin
  Con.Sim.DB.1 # cnvfi(SysTics());
end;


/*========================================================================
2023-08-07  AH
========================================================================*/
Sub StopTime()
begin
  Con.Sim.DB.1 # cnvfi(SysTics()) - Con.Sim.DB.1;
end;


/*========================================================================
2023-08-07  AH
========================================================================*/
sub GetPerfWert(
  aNr   : int;
) : int;
begin
  RETURN cnvif(FldFloat(950,2,aNr));
end;


/*========================================================================
2023-08-07  AH
========================================================================*/
sub AddPerfWert(
  aNr   : int;
);
local begin
  vF    : float;
  vD    : float;
end;
begin
  vD # cnvfi(SysTics()) - Con.Sim.DB.1;
  vF # FldFloat(950,2,aNr) + vD;
  FldDef(950,2,aNr, vF);
  StartTime();
end;

//========================================================================