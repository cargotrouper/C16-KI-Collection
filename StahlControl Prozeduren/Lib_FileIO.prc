@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_FileIO
//                    OHNE E_R_G
//  Info
//
//
//  21.01.2005  AI  Erstellung der Prozedur
//  11.01.2012  AI  Pfade werden aus dem Filename gesetzt
//  25.01.2012  AI  NEU: FileExists
//  04.06.2012  AI  NEU: CorrectPath
//  14.06.2012  ST  CorrectPath verändert keine Leerstrings mehr
//  01.08.2013  AH  FileIO merkt sich den User-Path
//  07.10.2013  TM  aPath grundsätzlich auf 4096 Zeichen gesetzt
//  06.03.2014  AH  NEU: "IsNetworkDrive" und "CreateFullPath(aPath"
//  01.09.2020  ST  CreateFullPath kann auch jetzt Netzwerkpfade "\\server\ordner1\ordner2"
//  27.07.2021  AH  ERX
//  01.03.2022  ST  GetTempPath(...) hinzugefügt
//  04.05.2022  DS  TempFilename(), readFullFileAsAlpha(), writeAlphaAsFile() hinzugefügt
//  2022-09-15  DS  TempDirname() hinzugefügt
//  2022-09-29  DS  FsiCopyCmd() hinzugefügt, aber wieder rauskommentiert, da doch nicht benötigt
//  2023-03-09  ST  Fix: "sub StampFile" nutzt jetzt FsiSplitname für Extraktion der Dateinamensbesstandteile
//  2023-03-22  DS  GetAppDataLocalSc() als Verzeichnis für lokale persistente SC Daten
//
//  Subprozeduren
//    SUB NormalizedFilename(aName : alpha) : alpha;
//    SUB FileExists(aName : alpha) :logic;
//    SUB PathExists(aPath : alpha(4096)) : logic;
//    SUB FileIO(aMode : alpha; optaHdl : int; optaPath : alpha(4096); opt aFilter : alpha; aFilename : alpha) : alpha
//    SUB FsiCopy(aSrcName : alpha; aDstName : alphaM; aMove : logic) : int
//    SUB FsiCopyCmd
//    SUB EmptyDir(aPath : alpha(4096); aRekursiv : logic);
//    SUB StampFilename(aName : alpha(250)) : alpha
//    SUB CorrectPath(aPath : alpha(4096)) : alpha
//    SUB IsNetworkDrive(aName : alpha) : logic
//    SUB CreateFullPath(aPath : alpha(4096));
//    SUB Regasm(aPara : alpha(500)) : logic;
//    SUB FindInstalledApp(aName : alpha(4000)) : alpha
//    SUB GetTempPath(aPath : alpha) : alpha
//    SUB TempFilename(aExt : alpha) : alpha
//    SUB TempDirname() : alpha
//    SUB readTxtFile
//    SUB writeTxtFile
//
//========================================================================
@I:Def_global
define begin
end;

//========================================================================
//  NormalizedFilename
//
//========================================================================
sub NormalizedFilename(aName : alpha(4000)) : alpha;
local begin
  vFile : int;
end;
begin
  // keine \/*?<>|":
  aName # Str_ReplaceAll(aName, '*', '');
  aName # Str_ReplaceAll(aName, '/', '');
  aName # Str_ReplaceAll(aName, '\', '');
  aName # Str_ReplaceAll(aName, '?', '');
  aName # Str_ReplaceAll(aName, '|', '');
  aName # Str_ReplaceAll(aName, '<', '');
  aName # Str_ReplaceAll(aName, '>', '');
  aName # Str_ReplaceAll(aName, ':', '');
  aName # Str_ReplaceAll(aName, '"', '');
  RETURN aName;
end;


//========================================================================
//  FileExists
//
//========================================================================
sub FileExists(aName : alpha(4000)) : logic;
local begin
  vFile : int;
end;
begin
  vFile # FSIOpen(aName, _FsiStdRead );
  if (vFile<=0) then RETURN false;
  FSIClose(vFile);
  RETURN true;
end;


//========================================================================
//  PathExists
//
//========================================================================
Sub PathExists(aPath :     alpha(4096)) : logic;
local begin
  vOK : logic;
end;
begin

  try begin
    vOK # (FsiAttributes(aPath) & _FsiAttrDir = _FsiAttrDir);
  end;
  if (errGet()!=_erROK) then begin
    ErrSet(_ErROK);
    vOK # false;
  end;

  RETURN vOk;
end;


//========================================================================
//  FileIO
//    Startet Systemdialoge und gibt Ergebnis zurück
//========================================================================
sub FileIO(
      aMode       : alpha;
  opt aHdl        : int;
  opt aPath       : alpha(4096);
  opt aFilter     : alpha;
  opt aFilename   : alpha(1000);
) : alpha
local begin
  tReturn : alpha(255);
  tHdl    : int;
  tErg    : int;
  voldF   : int;

  vINI    : alpha;
  vBuf    : int;
  vX,vY   : int;
end;
begin

  // 01.09.2013 AH Standard User-Path
  if (aPath='') then begin
    vINI # 'INI.'+Username(_UserCurrent);
    // Text anlegen, falls bisher nicht vorhanden
    TxtCreate(vINI, 0);

    //Text laden
    vBuf # Textopen(10);
    vBuf->TextRead(vINI, 0);

    // Block suchen
    vX # TextSearch(vBuf, 1, 1, _TextSearchtoken, '<IOPath>');
    if (vX>0) then begin
      aPath # TextLineRead(vBuf, vX+1, 0);
    end;

  end;

  vOldF # WinFocusGet();

  if (aFilter='') then aFilter # '*.*|*.*';
  if (aHdl = 0) then aHdl # gFrmMain;


  tHdl # WinOpen(aMode);
  if( tHdl > 0) then begin
    if (aPath<>'') then
      tHdl->wpPathName # aPath
    else
      tHdl->wpPathName # _Sys->spPathMyDocuments;// 'C:\';
    case (StrCnv(aMode,_StrUpper)) of

      _WINCOMFILESAVE : begin
        tHdl->wpCaption    # Translate('Datei speichern');
        tHdl->wpFlags      # tHdl->wpFlags | _WinComCreatePrompt;
        tHdl->wpFileFilter # aFilter;
        tHdl->wpFilename   # aFilename;
        if (aFilename<>'') then
          tHdl->wpPathname   # FsiSplitName(aFilename,_FsiNameP);
        tErg # tHdl->WinDialogRun(_WinDialogCenter, aHdl);
        tReturn # tHdl->wpPathName + tHdl->wpFileName;
      end;

      _WINCOMFILEOPEN : begin
        tHdl->wpFileFilter # aFilter;
        tHdl->wpCaption    # Translate('Datei öffnen');
        tHdl->wpFlags      # tHdl->wpFlags | _WinComCreatePrompt;
        tHdl->wpFileFilter # aFilter;
        if (aFilename<>'') then
          tHdl->wpPathname   # FsiSplitName(aFilename,_FsiNameP);
        tErg # tHdl->WinDialogRun(_WinDialogCenter, aHdl);
        tReturn # tHdl->wpPathName + tHdl->wpFileName;
      end;

      _WINCOMPATH : begin
        tHdl->wpCaption    # Translate('Pfad wählen');
        tHdl->wpFlags      # tHdl->wpFlags | _WinComCreatePrompt;
        if (aFilename<>'') then
          tHdl->wpPathname   # FsiSplitName(aFilename,_FsiNameP);
        tErg # tHdl->WinDialogRun(_WinDialogCenter, aHdl);
        tReturn # tHdl->wpPathName+'\';
      end;
    end;
  end;

  aPath # tHdl->wpPathName;

  tHdl->WinClose();

  if (vOldF<>0) then vOldF->winfocusset();

  if (aHDL<>0) then begin
    if (cnvia(aHDL->wpcustom)<>0) then begin
      VarInstance(WindowBonus,cnvIA(aHDL->wpcustom));
    end;
  end;

  if (tErg <> _rOK) then begin
    if (vBuf<>0) then TextClose(vBuf);
    RETURN '';
  end;

  // 01.09.2013 AH Standard-USer-Path merken...
  if (vBuf<>0) then begin
    // 27.01.2022 AH: Fix für falsche TAGS mit \ statt /
    TextSearch(vBuf, 1, 1, _TextSearchtoken, '<\IOPath>','</IOPath>',99);

    vX # TextSearch(vBuf, 1, 1, _TextSearchtoken, '<IOPath>');
    if (vX<>0) then begin
//      WHILE (vX<=vBuf->TextInfo(_TextLines)) and ((TextLineRead(vBuf, vX, _TextLineDelete)<>'</IOPath>')) do begin
      // 27.01.2022 AH: REFACTORED
      vY # TextSearch(vBuf, vX, 1, _TextSearchtoken, '</IOPath>');
      WHILE (vX<=vY) do begin
        TextLineRead(vBuf, vX, _TextLineDelete);
        DEC(vY);
      END;
    end;

    //neuen Block anlegen
    TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, '<IOPath>', _TextLineInsert);
    TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, aPath, _TextLineInsert);
    TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, '</IOPath>', _TextLineInsert);

    TxtWrite(vBuf, vINI, _TextUnlock);

    TextClose(vBuf);
  end;


  RETURN (tReturn)
end;


//========================================================================
//  FsiCopy
//
//========================================================================
sub FsiCopy(
  aSrcName      : alpha(4000);    // Name der Ausgangsdatei
  aDstName      : alpha(4000);    // Name der Zieldatei
  aMove         : logic;          // Originaldatei löschen
) : int;                          // Fehlercode
local begin
    tSrcHdl     : int;            // Handle der Ausgangsdatei
    tDstHdl     : int;            // Handle der Zieldatei
    tSize       : int;            // Größe der Originaldatei
    tBlockSize  : int;            // Blockgröße
    tBuffer     : byte[8192];     // Datenpuffer
    tResult     : int;            // Funktionsresultat
end;

begin

//  DbaLog(_LogInfo,n,'Copy '+aSrcName+' '+aDstName);
  aSrcName # StrCnv(aSrcName,_Strupper);
  aDstName # StrCnv(aDstName,_Strupper);
  try begin

    // Dateien öffnen und Größe ermitteln
    tSrcHdl # FsiOpen(aSrcName,_FsiStdRead);
    tDstHdl # FsiOpen(aDstName,_FsiStdWrite);
    tSize   # FsiSize(tSrcHdl);

    // kopieren
    WHILE (tSize > 0) do begin
      tBlockSize # min(tSize,8192);         // maximale Blockgröße setzen
      FsiRead(tSrcHdl,tBuffer,tBlockSize);  // Daten lesen
      FsiWrite(tDstHdl,tBuffer,tBlockSize); // Daten schreiben
      dec(tSize,tBlockSize);                // Restgröße vermindern
    ENd;

    // Datum & Uhrzeit wiederherstellen
    FsiDate(tDstHdl,_FsiDtModified,FsiDate(tSrcHdl,_FsiDtModified));
    FsiTime(tDstHdl,_FsiDtModified,FsiTime(tSrcHdl,_FsiDtModified));
  end;

  // Fehler aufgetreten ?
  tResult # ErrGet();
  ErrSet(0);

  // Dateien schließen, wenn Handles belegt
  if (tDstHdl > 0) then
    FsiClose(tDstHdl);
  if (tSrcHdl > 0) then
    FsiClose(tSrcHdl);

  // Originaldatei löschen
  if (aMove) then
    tResult # FsiDelete(aSrcName);

  RETURN(tResult);
end;



/*
edit: im Nachhinein doch nicht benötigt
//========================================================================
//  wie FsiCopy, aber per copy-Befehl der Windows Kommandozeile
//
//========================================================================
sub FsiCopyCmd(
  aSrcName      : alpha(4000);    // Name der Ausgangsdatei
  aDstName      : alpha(4000);    // Name der Zieldatei
  aMove         : logic;          // Originaldatei löschen
) : int;                          // Fehlercode
local begin
    Erx : int;
end;
begin

  // Zieldatei vorher löschen
  FsiDelete(aDstName);

  // anders als FsiCopy und die darin verwendeten C16 Methoden, mogelt sich
  // der Windows-interne copy Befehl nicht an modernen Filesystem-Monitoren vorbei:
  Erx # SysExecute('cmd', '/c copy "' + aSrcName + '" "' + aDstName + '"', _ExecWait);
  
  if (aMove) then
  begin
    // Quelldatei löschen
    FsiDelete(aSrcName);
  end
  
  return Erx;

end;
*/



//========================================================================
//  EmptyDir
//
//========================================================================
sub EmptyDir(
  aPath         : alpha(4096);
  opt aRekursiv : logic);
local begin
  vDirHdl : int;
  vName   : alpha;
end;
begin

  // Loop alle Dateien im Verzeichnis...
  vDirHdl # FsiDirOpen(aPath+'\*.*',_FsiAttrHidden);
  vName   # FsiDirRead(vDirHdl); // erste Datei
  WHILE (vName != '') do begin
    FsiDelete(aPath+'\'+vName);
    vName # FsiDirRead(vDirHdl);
  END;
  FsiDirClose(vDirHdl);

  if (aRekursiv) then begin
    // Loop alle UnterDirs im Verzeichnis...
    vDirHdl # FsiDirOpen(aPath+'\*.*',_FsiAttrDir);
    vName   # FsiDirRead(vDirHdl); // erstes Dir
    WHILE (vName != '') do begin
      if (vName<>'.') and (vName<>'..') then
        EmptyDir(aPath+'\'+vName, true);
      vName # FsiDirRead(vDirHdl);
    END;
    FsiDirClose(vDirHdl);
  end;

end;




//========================================================================
//  StampFilename
//
//========================================================================
sub StampFilename(aName : alpha(1000)) : alpha
local begin
  vA,vB,vC  : alpha(250);
  vDate     : date;
  vTime     : time;
end;
begin
  vDate # today;
  vTime # now;

  //vA # Str_Token(aName,'.',1);
  vA # FsiSplitName(aName,_FsiNamePN);
  vB # '_'+cnvai(vDate->vpYear - 2000, _Fmtnumleadzero,0,2)+
        cnvai(vDate->vpMonth, _Fmtnumleadzero,0,2)+
        cnvai(vDate->vpday, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpHours, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpMinutes, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpSeconds, _Fmtnumleadzero,0,2);
  //vC # '.'+Str_Token(aName,'.',2);
  vC # '.' + FsiSplitName(aName,_FsiNameE);

  RETURN vA+vB+vC;
end;

//========================================================================
//  CorrectPath
//
//========================================================================
sub CorrectPath(aPath : alpha(4096)) : alpha
begin
  // ST 2012-06-14: Pfadkorrektur nur bei nicht leerem Argument
  if (aPath <> '') then begin
    if (StrCut(aPath, StrLen(aPath),1)<>'\') then aPath # aPath + '\';
  end;
  RETURN aPath
//  RETURN PathExists(aPath);
end;


//========================================================================
//  IsNetworkDrive
//========================================================================
sub IsNetworkDrive(aName : alpha) : logic;
local begin
  vApp    : handle;
  vDrives : handle;
  vCount  : int;
  vI      : int;
  vName   : alpha(1000);
end;
begin
  aName # StrCnv(aName,_StrUpper);

  vApp    # ComOpen('WScript.Network',_ComAppCreate);
  if (vApp=0) then RETURN false;

  vDrives # vApp->ComCall('EnumNetworkDrives');
  vCount  # vDrives->ComCall('Count');

  FOR vI # 0
  LOOP vI # vI + 2
  WHILE (vI < vCount) do begin
    vName # vDrives->cpaItem(vI);     // Laufwerk "Z:"
    if (StrLen(vName)=2) then
      if (StrCnv(StrCut(vName,1,1),_strUpper)=aName) then begin
        vApp->ComClose();
        RETURN true;
      end;
//debugx(vName);
//    vName # vDrives->cpaItem(vI +1);  // URL "\\192.168.0.2\c16"
//debugx(vName);
  END;

  vApp->ComClose();
  RETURN false;
end;


//========================================================================
//  CreateFullPath
//    c:\temp\horst\123
//    \\temp\horst\123
//========================================================================
sub CreateFullPath(aPath : alpha(4096));
local begin
  vI,vJ : int;
  vPath : alpha(4096);
  vA    : alpha(200);
end;
begin

  if (StrCut(aPath,1,2) = '\\') then begin
    vPath # '\\'+Str_Token(aPath,'\',3);
    aPath # StrCut(aPath,StrLen(vPath)+2,StrLen(aPath));
  end else begin
    vPath # Str_Token(aPath,':',1)+ ':';
    aPath # Str_Token(aPath,':',2);
  end;
  
  vJ  # Lib_strings:Strings_Count(aPath, '\') + 1;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vJ) do begin
    vA # Str_token(aPath,'\',vI);
    if (vA='') then CYCLE;

    vPath # vPath + '\'+vA;
    FsiPathCreate(vPath);
  END;

  FsiPathCreate(vPath);
end;


//========================================================================
//========================================================================
SUB StartRegasm(aPara : alpha(500)) : logic;
local begin
  vOK : logic;
  vA  : alpha(4096);
end;
begin

  vOK # n;
  vA  # _sys->sppathWindows+'\Microsoft.NET\Framework\v4.0.30319';
  vOK # PathExists(vA);
  if (vOK=false) then begin
    // andere Versionen...
  end;
//
  if (vOK) then begin
    if (FileExists(vA+'\Regasm.exe')) then begin
//todo('start :'+vA+'\Regasm.exe '+aPara);
      SysExecute(vA+'\Regasm.exe', aPara, _ExecWait);
    end;
  end;

  RETURN false;
end;


//========================================================================
// sucht installierte Datei (d.h. in den Windows-Installationspfaden für Programme = meistens "c:\programme"
//========================================================================
sub FindInstalledApp(aName : alpha(4000)): alpha;
local begin
  vPath : alpha(4096);
  vRes  : alpha(4096);
  vA    : alpha;
end;
begin
  if (StrCut(aName,1,1)<>'\') then aName # '\' + aName;
  
  vPath # lib_Strings:Strings_Win2Dos(SysGetEnv('PROGRAMFILES'))+aName;
  vA # FsiFileInfo(vPath, _FsiFileVersion);
  if (vA<>'') then RETURN vPath;
  
  vPath # lib_Strings:Strings_Win2Dos(SysGetEnv('PROGRAMFILES(x86)'))+aName;
  vA # FsiFileInfo(vPath, _FsiFileVersion);
  if (vA<>'') then RETURN vPath;

  vPath # lib_Strings:Strings_Win2Dos(SysGetEnv('PROGRAMW6432'))+aName
  vA # FsiFileInfo(vPath, _FsiFileVersion);
  if (vA<>'') then RETURN vPath;

  vPath # 'C:\Program Files'+aName;
  vA # FsiFileInfo(vPath, _FsiFileVersion);
  if (vA<>'') then RETURN vPath;

  vPath # 'C:\Program Files (x86)'+aName;
  vA # FsiFileInfo(vPath, _FsiFileVersion);
  if (vA<>'') then RETURN vPath;
 
  RETURN '';
end;


//========================================================================
//  sub GetTempPath(opt aPath : alpha) : alpha
//
//  Gibt den Stahl Control Temp Ordner zurück
//========================================================================
sub GetTempPath(opt aPath : alpha) : alpha
local begin
  vTmp : alpha(1000);
end;
begin
  vTmp  # SysGetEnv('TEMP')+ '\StahlControl\';
  Lib_FileIO:CreateFullPath(vTmp + aPath);
  RETURN  vTmp;
end;



/*
========================================================================
2023-03-22  DS                                               intern

Gibt den lokalen Appdata-Pfad für StahlControl zurück, und erstellt
diesen vorher, falls nötig.
Falls der Appdata-Pfad in C16 nicht bekannt ist, wird der leere
string zurückgegeben.

Der Ordner soll genutzt werden für lokale persistente SC Daten.
========================================================================
*/
sub GetAppDataLocalSc() : alpha
local begin
  vRetVal : alpha(4096)
end
begin

  vRetVal # _Sys->spPathAppData;
  
  if vRetVal <> '' then
  begin
    vRetVal # vRetVal + '\..\Local\StahlControl';
    Lib_FileIO:CreateFullPath(vRetVal);
  end
  
  return vRetVal;
end



/*
========================================================================
2022-05-04  DS                                               2298/27

Gibt einen random Dateinamen im StahlControl temp Ordner zurück.
aExt ist die Dateinamenerweiterung ohne führenden "."
========================================================================
*/
sub TempFilename(aExt : alpha) : alpha
begin
  return GetTempPath() + 'temp_' + CnvAF(Random() * 1000000000.0, _FmtNumNoGroup, 0, 0) + '.' + aExt;
end


/*
========================================================================
2022-09-15  DS                                               2407/05

Gibt einen random Verzeichnisnamen im StahlControl temp Ordner zurück.
========================================================================
*/
sub TempDirname() : alpha
begin
  return GetTempPath() + 'temp_' + CnvAF(Random() * 1000000000.0, _FmtNumNoGroup, 0, 0);
end



/*
========================================================================
2022-05-04  DS                                               2298/27

Liest eine (kleine) Textdatei vollständig ein und gibt sie als
String zurück
========================================================================
*/
sub readTxtFile
(
  aFilename   : alpha(512);   // Name der zu lesenden Text-Datei
  var aText   : alpha;        // String in den geschrieben wird
  opt pure    : logic;        // einlesen ohne Zeichenwandlung (wenn true, wird _FsiPure beim Öffnen verwendet, nützlich z.B. damit UTF8-Texte nicht by automatisch nach ANSI kodiert werden)
  opt verbose : logic         // Fehlermeldungen anzeigen oder nicht
) : int                       // return/error code von FsiOpen()
local begin
  vMode       : int;
  vFileHdl    : handle;       // auf Text Datei
  vLine       : alpha(8192);  // Inhalt der aktuellen Zeile
  vReturn     : int;
end
begin

  if pure then
  begin
    vMode # _FsiStdRead | _FsiPure;
  end
  else
  begin
    vMode # _FsiStdRead;
  end

  vFileHdl # FsiOpen(aFilename, vMode);
  
  if (vFileHdl <= 0) then
  begin
    if verbose then
    begin
      Msg(99, 'Datei nicht lesbar (Existiert sie und liegt Leseberechtigung vor?): ' + aFilename, _WinIcoError, _WinDialogOk, _WinIdOk);
    end
    // remember error code:
    vReturn # vFileHdl;
  end
  else
  begin

    aText # '';
    WHILE vFileHdl->FsiRead(vLine) > 0 DO
    BEGIN
      aText # aText + vLine;
    END
  
  end;

  vFileHdl->FsiClose();
  return vReturn;
  
end


/*
========================================================================
2022-05-04  DS                                               2298/27

Schreibt einen String als Textdatei auf Festplatte
========================================================================
*/
sub writeTxtFile
(
  aFilename   : alpha(512);   // Name der zu schreibenden Text-Datei
  aText       : alpha(4096);  // String der geschrieben wird
  opt pure    : logic;        // schreiben ohne Zeichenwandlung (wenn true, wird _FsiPure beim Öffnen verwendet, nützlich z.B. damit UTF8-Texte nicht by automatisch nach ANSI kodiert werden)
  opt verbose : logic         // Fehlermeldungen anzeigen oder nicht
) : int                       // return/error code von FsiOpen()
local begin
  vMode       : int;
  vFileHdl    : handle;       // auf Text Datei
  vLine       : alpha(8192);  // Inhalt der aktuellen Zeile
  vReturn     : int;
end
begin

  if pure then
  begin
    vMode # _FsiAcsRW | _FsiDenyRW | _FsiCreate | _FsiPure;
  end
  else
  begin
    vMode # _FsiAcsRW | _FsiDenyRW | _FsiCreate;
  end

  vFileHdl # FsiOpen(aFilename, vMode);
  
  if (vFileHdl <= 0) then
  begin
    if verbose then
    begin
      Msg(99, 'Datei nicht schreibbar (Existiert Verzechnis und liegt Schreibrecht vor?): ' + aFilename, _WinIcoError, _WinDialogOk, _WinIdOk);
    end
    // remember error code:
    vReturn # vFileHdl;
  end
  else
  begin
    FsiWrite(vFileHdl, aText);
    
  end;

  vFileHdl->FsiClose();
  return vReturn;
end


//========================================================================