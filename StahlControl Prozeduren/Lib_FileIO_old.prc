@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_FileIO
//
//  Info
//
//
//  21.01.2005  AI  Erstellung der Prozedur
//  11.01.2012  AI  Pfade werden aus dem Filename gesetzt
//  25.01.2012  AI  NEU: FileExists
//  04.06.2012  AI  NEU: CorrectPath
//  14.06.2012  ST  CorrectPath verändert keine Leerstrings mehr
//  01.08.2013  AH  FileIO merkt sich den User-Path
//
//  Subprozeduren
//    SUB FileExists(aName : alpha) :logic;
//    SUB PathExists(aPath :     alpha(4096)) : logic;
//    SUB FileIO(aMode : alpha; optaHdl : int; optaPath : alpha; opt aFilter : alpha; aFilename : alpha) : alpha
//    SUB FsiCopy(aSrcName : alpha; aDstName : alphaM; aMove : logic) : int
//    SUB EmptyDir(aPath) : int;
//    SUB StampFilename(aName : alpha(250)) : alpha
//    SUB CorrectPath(aPath : alpha) : alpha
//
//========================================================================
@I:Def_global
define begin
end;

//========================================================================
//  FileExists
//
//========================================================================
sub FileExists(aName : alpha) : logic;
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
begin
  RETURN(FsiAttributes(aPath) & _FsiAttrDir = _FsiAttrDir);
end;


//========================================================================
//  FileIO
//    Startet Systemdialoge und gibt Ergebnis zurück
//========================================================================
sub FileIO(
      aMode       : alpha;
  opt aHdl        : int;
  opt aPath       : alpha;
  opt aFilter     : alpha;
  opt aFilename   : alpha;
) : alpha
local begin
  tReturn : alpha(255);
  tHdl    : int;
  tErg    : int;
  voldF   : int;

  vINI    : alpha;
  vBuf    : int;
  vX      : int;
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
        tHdl->wpFlags      # _WinComCreatePrompt;
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
        tHdl->wpFlags      # _WinComCreatePrompt;
        tHdl->wpFileFilter # aFilter;
        if (aFilename<>'') then
          tHdl->wpPathname   # FsiSplitName(aFilename,_FsiNameP);
        tErg # tHdl->WinDialogRun(_WinDialogCenter, aHdl);
        tReturn # tHdl->wpPathName + tHdl->wpFileName;
      end;

      _WINCOMPATH : begin
        tHdl->wpCaption    # Translate('Pfad wählen');
        tHdl->wpFlags      # _WinComCreatePrompt;
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
    vX # TextSearch(vBuf, 1, 1, _TextSearchtoken, '<IOPath>');
    if (vX<>0) then begin
      WHILE (vX<=vBuf->TextInfo(_TextLines)) and (TextLineRead(vBuf, vX, _TextLineDelete)<>'</IOPath>') do begin
      END;
    end;

    //neuen Block anlegen
    TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, '<IOPath>', _TextLineInsert);
    TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, aPath, _TextLineInsert);
    TextLineWrite(vBuf, vBuf->TextInfo(_TextLines)+1, '<\IOPath>', _TextLineInsert);

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
  aSrcName      : alpha;          // Name der Ausgangsdatei
  aDstName      : alpha;          // Name der Zieldatei
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


//========================================================================
//  EmptyDir
//
//========================================================================
sub EmptyDir(aPath : alpha);
local begin
  vDirHdl : int;
  vName   : alpha;
end;
begin

  // Lesen aller .dat-Dateien im aktuellen Verzeichnis
  vDirHdl # FsiDirOpen(aPath+'\*.*',_FsiAttrHidden);
  vName   # FsiDirRead(vDirHdl); // erste Datei

  WHILE (vName != '') do begin
    FsiDelete(aPath+'\'+vName);
    vName # FsiDirRead(vDirHdl);
  END;

  FsiDirClose(vDirHdl);

end;


//========================================================================
//  StampFilename
//
//========================================================================
sub StampFilename(aName : alpha(250)) : alpha
local begin
  vA,vB,vC  : alpha;
  vDate     : date;
  vTime     : time;
end;
begin
  vDate # today;
  vTime # now;

  vA # Str_Token(aName,'.',1);
  vB # '_'+cnvai(vDate->vpYear - 2000, _Fmtnumleadzero,0,2)+
        cnvai(vDate->vpMonth, _Fmtnumleadzero,0,2)+
        cnvai(vDate->vpday, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpHours, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpMinutes, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpSeconds, _Fmtnumleadzero,0,2);
  vC # '.'+Str_Token(aName,'.',2);

  RETURN vA+vB+vC;
end;


//========================================================================
//  CorrectPath
//
//========================================================================
sub CorrectPath(aPath : alpha) : alpha
begin
  // ST 2012-06-14: Pfadkorrektur nur bei nicht leerem Argument
  if (aPath <> '') then begin
    if (StrCut(aPath, StrLen(aPath),1)<>'\') then aPath # aPath + '\';
  end;
  RETURN aPath
//  RETURN PathExists(aPath);
end;


//========================================================================