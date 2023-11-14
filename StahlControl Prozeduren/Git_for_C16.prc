@A+
@C+
//                    OHNE E_R_G

@I:Def_Global


declare Plugin.SetStatus(aStatus : alpha(4096));
declare Plugin.SetResult(aResPath : alpha(256); opt aIsText : logic; opt aNoNewBlock : logic);


//---------------------------------------------------------------------------------------
// Defines
//---------------------------------------------------------------------------------------
define
{
  // repository location, i.e. first part of gWorkspacePath
  sRepoLocation     : 'C:\Workspaces\Repos\C16'

   // repository name, i.e. last part of gWorkspacePath
  sRepoName         : 'SC16'

  // comma-separated list of strings indicating files that will not be exported
  sExportBlacklist  : 'Liz_Checker', 'Liz_Data'

  // URL of git to be used by function gitForCreateUpdate()
  gitRepoRemote : 'https://stahlcontrol@dev.azure.com/stahlcontrol/C16/_git/SC16'

  // from Plugin.Git.prc
  sGitFileOutputTag     : '2>&1 &'      // Tell command line to write git output into text file
}


//---------------------------------------------------------------------------------------
// Plugin global data
//---------------------------------------------------------------------------------------
global globals_git
{
  gWorkspacePath            : alpha(256);   // External path of Git workspace
  gPluginResultText         : handle;       // TextEdit for Git result output
  gTxtBufResult             : handle;       // Buffer for TextEdit
  gTxtBuf                   : handle;       // Buffer for im/exporting procedures
  gMemBuf                   : handle;       // Memory for correct line splitting on im/export
  gProcCheckBufRoot         : handle;       // List to check for new imported procedures

  gImportProtocolFilename   : alpha(256);   // Import function will write its protocol here
}


//---------------------------------------------------------------------------------------
// Message Popups:
//---------------------------------------------------------------------------------------
sub __debug_popup
(
  aMsg               : alpha(4096);        // message text
)
{
  WinDialogBox(0, 'DEBUG', aMsg, _WinIcoInformation, _WinDialogOk, 1);
}


sub MsgGitInfo
(
  aText : alpha(4096);
)
begin
  WinDialogBox(0, 'Git-Info', aText, _WinIcoInformation, _WinDialogOk, 0);
end


sub MsgGitError
(
  aText : alpha(4096);
)
begin
  WinDialogBox(0, 'Git-Error', aText, _WinIcoError, _WinDialogOk, 0);
end


//---------------------------------------------------------------------------------------
// Ermitteln, ob ein Verzeichnis vorhanden ist
//---------------------------------------------------------------------------------------
sub FsiDirExists
(
  aPath : alpha(4096);
) : logic;
{
  return(FsiAttributes(aPath) & _FsiAttrDir = _FsiAttrDir);
}

//---------------------------------------------------------------------------------------
// Check if path is valid git directory
//---------------------------------------------------------------------------------------
sub CheckValidPath
: logic;                                // Path is valid or not
{
  return (gWorkspacePath != '' and FsiDirExists(gWorkspacePath + '\.git\refs\'));
}


//---------------------------------------------------------------------------------------
// Deletes all procedures.
// This should (only) be called before a new export. That way, files that were deleted
// from the database will also be deleted in the git.
//---------------------------------------------------------------------------------------
sub ClearAllProcedures()
{
  SysExecute('cmd.exe', '/c "del ' + gWorkspacePath + '\procedures\*.prc', _ExecHidden | _ExecWait);
}

//---------------------------------------------------------------------------------------
// Create list of all procedures in database
//---------------------------------------------------------------------------------------
sub CreateProcCheckList
()

  local
  {
    tTxtBuf             : handle;
    tTxtName            : alpha;
    tErg                : int;
    tID                 : int;
  }

{
  gProcCheckBufRoot->CteClear(true);
  tTxtBuf # TextOpen(_Mem512K);
  if (gProcCheckBufRoot > 0 and tTxtBuf > 0)
  {
    tID # 1;

    for   tErg # tTxtBuf->TextRead('', _TextFirst | _TextProc | _TextNoContents);
    loop  tErg # tTxtBuf->TextRead(tTxtName, _TextNext | _TextProc | _TextNoContents);
    while (tErg = _rOk)
    {
      tTxtName # tTxtBuf->TextInfoAlpha(_TextName);
      if (gProcCheckBufRoot->CteInsertItem(tTxtName, tID, tTxtName, _CteLast) > 0)
        Inc(tID);
    }

    tTxtBuf->TextClose();
  }
}

//---------------------------------------------------------------------------------------
// Check if a procedure is in list and remove it
//---------------------------------------------------------------------------------------
sub CheckProcCheckList
(
  aName                 : alpha;        // Proc name to check
)
: logic;                                // Proc is in list or not

  local
  {
    tNode               : handle;
    tRes                : logic;
  }

{
  tNode # gProcCheckBufRoot->CteRead(_CteFirst | _CteSearch, 0, aName);
  if (tNode > 0)
    tRes # gProcCheckBufRoot->CteDelete(tNode, _CteChild);

  return tRes;
}

//---------------------------------------------------------------------------------------
// Output the actual list of procedures, which were not removed by CheckProcCheckList()
//---------------------------------------------------------------------------------------
sub ScanProcCheckList
()
: logic;                                // There is at least 1 entry or not

  local
  {
    tNode               : handle;
    tRes                : logic;
  }

{
  tNode # gProcCheckBufRoot->CteRead(_CteFirst);
  tRes  # tNode > 0;
  if (tRes)
  {
    Plugin.SetResult('Folgende Prozeduren sind in der Datenbank, aber nicht in ' + gWorkspacePath + '\procedures vorhanden.', true, true);
    Plugin.SetResult('Um diese Prozeduren ins git zu exportieren kann die Export-Funktion von Git_for_C16 genutzt werden.', true, true);
    Plugin.SetResult('', true, true);
    Plugin.SetResult('HINWEIS: Die Prozeduren die zu Beginn der Prozedur Git_for_C16 in sExportBlacklist gelistet werden, werden absichtlich weder exportiert,', true, true);
    Plugin.SetResult('         noch importiert und sollen nicht ins git. Sie werden hier deswegen nicht gelistet. Das gilt z.B. fuer Lizenz-relevante Prozeduren.', true, true);
    Plugin.SetResult('', true, true);
    Plugin.SetResult('Liste der Prozeduren in der Datenbank die nicht im git Export existieren:', true, true);
    Plugin.SetResult('-------------------------------------------------------------------------', true, true);
    Plugin.SetResult('', true, true);

    while (tNode > 0)
    {
      switch (tNode->spName)
      {
        case sExportBlacklist :
        {
          // do nothing for file names that are in the blacklist
        }
        default :
        {
          // if file name is not in blacklist, list it as missing in git
          Plugin.SetResult(tNode->spName, true, true);
        }
      }

      tNode # gProcCheckBufRoot->CteRead(_CteNext, tNode);
    }

    gProcCheckBufRoot->CteClear(true);
  }

  return tRes;
}

//---------------------------------------------------------------------------------------
// Import a procedure in UTF-8 from given gath
//---------------------------------------------------------------------------------------
sub Plugin.ImportProcedure
(
  aTxtName              : alpha(30);    // Proc name
  aSrcPath              : alpha(256);   // External path of proc
)

  local
  {
    tFsi                : handle;
    tResult             : int;
    tPosCR              : int;
    tPosStart           : int;
    tSize               : int;
    tVal                : alpha(4096);
  }

{
  tFsi # FsiOpen(aSrcPath + '\' + aTxtName, _FsiStdRead);
  if (tFsi > 0)
  {
    tSize # tFsi->FsiSize();
    gMemBuf->spLen # 0;
    gTxtBuf->TextClear();
    if (tFsi->FsiReadMem(gMemBuf, 1, tSize) > 0)
    {
      tPosStart # 1;
      // Split text on line feed or maximum line length for text buffer
      for   tPosCR # gMemBuf->MemFindByte(tPosStart, Min(250, tSize-tPosStart), 13);
      loop  tPosCR # gMemBuf->MemFindByte(tPosStart, Min(250, tSize-tPosStart), 13);
      while (true)
      {
        if (tPosCR = 0)
          tVal # gMemBuf->MemReadStr(tPosStart, tSize-tPosStart + 1, _CharsetC16_1252);
        else
          tVal # gMemBuf->MemReadStr(tPosStart, tPosCR-tPosStart, _CharsetC16_1252);

        gTxtBuf->TextLineWrite(gTxtBuf->TextInfo(_TextLines) + 1, tVal, _TextLineInsert);

        if (tPosCR = 0)
          break;

        tPosStart # tPosCR + 1;
        if (gMemBuf->MemReadByte(tPosStart) = 10)
          Inc(tPosStart);
      }

      tResult # gTxtBuf->TextWrite(FsiSplitName(aTxtName, _FsiNameN), _TextProc);
    }

    tFsi->FsiClose();
  }
}

//---------------------------------------------------------------------------------------
// Import all procedures in UTF-8
//---------------------------------------------------------------------------------------
sub Plugin.ImportAllProcedures

  local
  {
    tFsiDir             : handle;
    tProcName           : alpha(256);
    tProcSize           : int;
    tOverwritePlugin    : logic;
  }

{
  if (CheckValidPath())
  {
    CreateProcCheckList();

    Plugin.SetStatus('Import startet...');

    if (FsiAttributes(gWorkspacePath + '\procedures') & _FsiAttrDir = _FsiAttrDir)
    {
      tOverwritePlugin # SysGetArg('C16OverwritePlugin') = 'true';

      tFsiDir # FsiDirOpen(gWorkspacePath + '\procedures\*.prc', 0);
      if (tFsiDir > 0)
      {
        gTxtBuf # TextOpen(_Mem512K);
        gMemBuf # MemAllocate(_Mem1M);
        if (gTxtBuf > 0 and gMemBuf > 0)
        {
          gMemBuf->spCharset # _CharsetUTF8;

          for   tProcName # tFsiDir->FsiDirRead();
          loop  tProcName # tFsiDir->FsiDirRead();
          while (tProcName != '')
          {
            if (tOverwritePlugin or !(tProcName =* 'Plugin.*'))
            {
              CheckProcCheckList(StrDel(tProcName, StrLen(tProcName) - 3, 4));
              Plugin.ImportProcedure(tProcName, gWorkspacePath + '\procedures');
            }
          }

          gTxtBuf->TextClose();
         }

        // Wenn einkommentiert, wirft das Schließen eine Fehlermeldungen darüber dass der Deskriptor ungültig sei.
        // Annahmne: ist schon geschlossen. Daher rauskommentiert.
        //tFsiDir->FsiClose();
      }
    }

    ScanProcCheckList();

    Plugin.SetStatus('Import abgeschlossen. Details siehe Protokoll: ' + gImportProtocolFilename);
  }
}

//---------------------------------------------------------------------------------------
// Export a procedure in UTF-8 to given path
//---------------------------------------------------------------------------------------
sub Plugin.ExportProcedure
(
  aTxtName              : alpha;        // Proc name
  aDstPath              : alpha(256);   // External path to export
)

  local
  {
    tRes                : int;
    tCnt                : int;
    tLineCnt            : int;
    tLineVal            : alpha(250);
    tFsi                : handle;
  }

{
  gMemBuf->spLen # 0;
  tCnt     # 1;
  tLineCnt # gTxtBuf->TextInfo(_TextLines);

  for   tLineVal # gTxtBuf->TextLineRead(tCnt, 0);
  loop  tLineVal # gTxtBuf->TextLineRead(tCnt, 0);
  while (tCnt <= tLineCnt)
  {
    gMemBuf->MemWriteStr(gMemBuf->spLen + 1, tLineVal, _CharsetC16_1252);
    if (tCnt < tLineCnt)
      gMemBuf->MemWriteStr(gMemBuf->spLen + 1, StrChar(13) + StrChar(10), _CharsetC16_1252);

    Inc(tCnt);
  }

  tFsi # FsiOpen(aDstPath + '\' + aTxtName + '.prc', _FsiCreate | _FsiStdWrite);
  if (tFsi > 0)
  {
    tRes # tFsi->FsiWriteMem(gMemBuf, 1, gMemBuf->spLen);
    if (tRes < 1)
      WinDialogBox(0, 'Fehler beim Export', 'Fehler beim Exportieren von "' + aTxtName + '".', _WinIcoError, _WinDialogOK,0);

    tFsi->FsiClose();
  }
}

//---------------------------------------------------------------------------------------
// Export all procedures in UTF-8
//---------------------------------------------------------------------------------------
sub Plugin.ExportAllProcedures
(
  opt aOnlyWithThisUserLast : alpha;   // if not '', only procedures last modified by the indicated user will be exported (cf. TextInfoAlpha(_TextUserLast)).
                                       // note that any value <> '' disables export of file deletions.
)

  local
  {
    tTxtName            : alpha;       // Text name
    tErg                : int;         // Result of reading operation
  }

{
  if (CheckValidPath())
  {

    Plugin.SetStatus(
    'git Export:' + StrChar(10) + StrChar(10) +
    'Zum Starten des git Exports, bitte OK klicken.' + StrChar(10) + StrChar(10) +
    'Dann bitte warten bis Export abgeschlossen...'
    );

    FsiPathCreate(gWorkspacePath + '\procedures');

    // damit auch Löschungen von Dateien innerhalb von C16 ins git committed werden:
    if (aOnlyWithThisUserLast = '')
    {
      // Clearing (==Deletions "exportieren"), sollte nur dann geschehen, wenn danach ein vollständiger
      // Export folgt, also wenn aOnlyWithThisUserLast = ''
      ClearAllProcedures();
    }

    gTxtBuf # TextOpen(_Mem512K);
    gMemBuf # MemAllocate(_Mem1M);

    if (gTxtBuf > 0 and gMemBuf > 0)
    {
      tTxtName # '';
      gMemBuf->spCharset # _CharsetUTF8;

      for   tErg # TextRead(gTxtBuf, tTxtName, _TextFirst | _TextProc)
      loop  tErg # TextRead(gTxtBuf, tTxtName, _TextNext | _TextProc)
      while (tErg = _rOk)
      {
        tTxtName # gTxtBuf->TextInfoAlpha(_TextName);

        switch (tTxtName)
        {
          case sExportBlacklist :
          {
            // do nothing for file names that are in the blacklist
          }
          default :
          {
            // if file name is not in the blacklist, export when checked positively against aOnlyWithThisUserLast
            if (aOnlyWithThisUserLast = '' or StrCnv(aOnlyWithThisUserLast, _StrUpper) = StrCnv(gTxtBuf->TextInfoAlpha(_TextUserLast), _StrUpper))
            {
              //call the file export
              Plugin.ExportProcedure(tTxtName, gWorkspacePath + '\procedures');
            }
          }
        }

      }

      gTxtBuf->TextClose();
      gMemBuf->MemFree();
    }

    Plugin.SetStatus('git Export abgeschlossen');
  }

  return;
}
//---------------------------------------------------------------------------------------
// Show status in status label
//---------------------------------------------------------------------------------------
sub Plugin.SetStatus
(
  aStatus               : alpha(4096);        // Status text
)
{
  WinDialogBox(0, 'Status', aStatus, _WinIcoInformation, _WinDialogOk, 1);
}

//---------------------------------------------------------------------------------------
// Set result text
//---------------------------------------------------------------------------------------
sub Plugin.SetResult
(
  aResPath              : alpha(256);   // Path of git response files
  opt aIsText           : logic;        // Path is text to show
  opt aNoNewBlock       : logic;        // No new block marker
)

  local
  {
    tRes                : handle;
    tBuf                : handle;
    tCnt                : int;
    tLines, tTmp              : int;
    tVar : alpha(256);
  }

{
  if (!aNoNewBlock and gTxtBufResult->TextInfo(_TextLines) > 0)
  {
    gTxtBufResult->TextLineWrite(gTxtBufResult->TextInfo(_TextLines) + 1, '===========================', _TextLineInsert);
    gTxtBufResult->TextLineWrite(gTxtBufResult->TextInfo(_TextLines) + 1, '', _TextLineInsert);
  }

  if (aIsText)
    gTxtBufResult->TextLineWrite(gTxtBufResult->TextInfo(_TextLines) + 1, aResPath, _TextLineInsert);
  else
  {
    tBuf # TextOpen(20);
    if (tBuf > 0)
    {
      tRes # tBuf->TextRead(aResPath, _TextExtern | _TextAnsi);
      if (tRes = _ErrOK)
      {
        tLines # tBuf->TextInfo(_TextLines);
        do
        {
          Inc(tCnt);

          gTxtBufResult->TextLineWrite(gTxtBufResult->TextInfo(_TextLines) + 1 , tBuf->TextLineRead(tCnt, 0), _TextLineInsert);
        }
        while (tCnt < tLines)
      }

      tBuf->TextClose();
    }
  }

  // gPluginResultText zu initialisieren setzt auf weiteren facilities des VectorSoft Plugin Interface auf.
  // Um den Aufwand gering zu halten wird stattdessen in eine Protokolldatei geschrieben.
  //gPluginResultText->WinUpdate(_WinUpdBuf2Obj);
  TextWrite(gTxtBufResult, gImportProtocolFilename, _TextExtern);
}


//---------------------------------------------------------------------------------------------------------------------------------------------
// Plugin.Git.prc: Additional Methods from Plugin.Git.prc:
//---------------------------------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
// Call Git status
//---------------------------------------------------------------------------------------
sub Status
(
  aRepositoryPath       : alpha(256);   // Path of repository
  opt aOutputFile       : alpha(256);   // Path for result file
)
: int;

  local
  {
    tFsiPath            : alpha(256);
    tRes                : int;
  }

{
  if (aOutputFile != '')
    aOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  tRes # SysExecute('cmd.exe', '/c "git status"' + aOutputFile, _ExecHidden | _ExecWait);

  FsiPathChange(tFsiPath);

  return(tRes);
}

//---------------------------------------------------------------------------------------
// Call Git fetch
//---------------------------------------------------------------------------------------
sub Fetch
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aFetchSource          : alpha;        // Source to fetch from
  opt aOutputFile       : alpha(256);   // Path for result file
)
: int;

  local
  {
    tFsiPath            : alpha(256);
    tRes                : int;
  }

{
  if (aOutputFile != '')
    aOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  tRes # SysExecute('cmd.exe', '/c "git fetch -v --progress ' + aFetchSource + '"' + aOutputFile, _ExecHidden | _ExecWait);

  FsiPathChange(tFsiPath);

  return(tRes);
}

//---------------------------------------------------------------------------------------
// Call Git pull
//---------------------------------------------------------------------------------------
sub Pull
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aRepository           : alpha;        // Name of repository
  aBranch               : alpha;        // Branch name
  opt aOutputFile       : alpha(256);   // Path for result file
)

  local
  {
    tFsiPath            : alpha(256);
  }

{
  if (aOutputFile != '')
    aOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  SysExecute('cmd.exe', '/c "git pull --progress --no-rebase -v "' + aRepository + '" ' + aBranch + '"' + aOutputFile, _ExecHidden | _ExecWait);

  FsiPathChange(tFsiPath);
}

//---------------------------------------------------------------------------------------
// Call Git push
//---------------------------------------------------------------------------------------
sub Push
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aRepository           : alpha;        // Name of repository
  aBranch               : alpha;        // Branch name
  opt aOutputFile       : alpha(256);   // Path for result file
)

  local
  {
    tFsiPath            : alpha(256);
  }

{
  if (aOutputFile != '')
    aOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  SysExecute('cmd.exe', '/c "git push --set-upstream --progress "' + aRepository + '" ' + aBranch + '"' + aOutputFile, _ExecHidden | _ExecWait);

  FsiPathChange(tFsiPath);
}

//---------------------------------------------------------------------------------------
// Call Git checkout
//---------------------------------------------------------------------------------------
sub Checkout
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aBranch               : alpha;        // Branch name to checkout from
  aNewBranchName        : alpha;        // New local branch name
  opt aOutputFile       : alpha(256);   // Path for result file
)

  local
  {
    tFsiPath            : alpha(256);
  }

{
  if (aOutputFile != '')
    aOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  if (aNewBranchName != '')
    aNewBranchName # '-B ' + aNewBranchName + ' ';

  SysExecute('cmd.exe', '/c "git checkout ' + aNewBranchName + ' -f ' + aBranch + ' --"' + aOutputFile, _ExecHidden | _ExecWait);

  FsiPathChange(tFsiPath);
}

//---------------------------------------------------------------------------------------
// Call Git commit
//---------------------------------------------------------------------------------------
sub Commit
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aMessage              : alpha(4096);  // Commit message
  opt aOutputFile       : alpha(256);   // Path for result file
)

  local
  {
    tFsiPath            : alpha(256);
  }

{
  if (aOutputFile != '')
    aOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  SysExecute('cmd.exe', '/c "git add -A"', _ExecHidden | _ExecWait);
  SysExecute('cmd.exe', '/c "git commit -m "' + aMessage + '" -a"' + aOutputFile, _ExecHidden | _ExecWait);

  FsiPathChange(tFsiPath);
}

//---------------------------------------------------------------------------------------------------------------------------------------------
// /Plugin.Git.prc: Additional Methods from Plugin.Git.prc
//---------------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------------
// BCS customized functions, partially building on those in Plugin.Git.prc
//---------------------------------------------------------------------------------------------------------------------------------------------

sub ExistsLocalBranch
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aBranch               : alpha;        // branch to fetch
  opt aOutputFile       : alpha(256);   // Path for result file
)
: logic;

  local
  {
    tGitSuffixForOutputFile : alpha(256);
    tFsiPath                : alpha(256);
    tRes                    : int;
    tFileHandle             : handle;
    tFileSize               : int;
    tReturnValue            : logic;
  }

{
  if (aOutputFile = '')  // if nothing is passed, set a proper default:
    aOutputFile # 'git_out_ExistsLocalBranch.txt'

  tGitSuffixForOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  // Leider schleift der Rückgabewert von SysExecute() nicht den Rückgabewert des aufgerufenen Programms durch, sondern liefert nur einen internen Wert
  // darüber ob Funktion SysExecute() die gerufene Funktion finden konnte...
  tRes # SysExecute('cmd.exe', '/c "git branch --list ' + gitRepoRemote + ' ' + aBranch + '"' + tGitSuffixForOutputFile, _ExecHidden | _ExecWait);
  //...weswegen der folgende Umweg über aOutputFile erforderlich ist:
  tFileHandle # FsiOpen(aOutputFile, _FsiStdRead);
  tFileSize # FsiSize(tFileHandle);
  tFileHandle->FsiClose()

  FsiPathChange(tFsiPath);

  if (tFileSize < 0)
  {
    WinDialogBox(0, 'ERROR', 'Gemeldete Größe der Datei "' + aOutputFile + '" ist ' + CnvAI(tFileSize) + '. Es muss ein Fehler vorliegen. Beende alle Prozeduren (exit).', _WinIcoError, _WinDialogOk, 0);
    exit;
  }else{
    tReturnValue # tFileSize > 0;
  }
  return(tReturnValue);
}

sub ExistsRemoteBranch
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aBranch               : alpha;        // branch to fetch
  opt aOutputFile       : alpha(256);   // Path for result file
)
: logic;

  local
  {
    tGitSuffixForOutputFile : alpha(256);
    tFsiPath                : alpha(256);
    tRes                    : int;
    tFileHandle             : handle;
    tFileSize               : int;
    tReturnValue            : logic;
  }

{
  if (aOutputFile = '')  // if nothing is passed, set a proper default:
    aOutputFile # 'git_out_ExistsRemoteBranch.txt'

  tGitSuffixForOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  // Leider schleift der Rückgabewert von SysExecute() nicht den Rückgabewert des aufgerufenen Programms durch, sondern liefert nur einen internen Wert
  // darüber ob Funktion SysExecute() die gerufene Funktion finden konnte...
  tRes # SysExecute('cmd.exe', '/c "git ls-remote --exit-code --heads ' + gitRepoRemote + ' ' + aBranch + '"' + tGitSuffixForOutputFile, _ExecHidden | _ExecWait);
  //...weswegen der folgende Umweg über aOutputFile erforderlich ist:
  tFileHandle # FsiOpen(aOutputFile, _FsiStdRead);
  tFileSize # FsiSize(tFileHandle);
  tFileHandle->FsiClose()

  FsiPathChange(tFsiPath);

  if (tFileSize < 0)
  {
    WinDialogBox(0, 'ERROR', 'Gemeldete Größe der Datei "' + aOutputFile + '" ist ' + CnvAI(tFileSize) + '. Es muss ein Fehler vorliegen. Beende alle Prozeduren (exit).', _WinIcoError, _WinDialogOk, 0);
    exit;
  }else{
    tReturnValue # tFileSize > 0;
  }
  return(tReturnValue);
}

sub Fetch_BCS
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aBranch               : alpha;        // branch to fetch
  opt aOutputFile       : alpha(256);   // Path for result file
)
: int;

  local
  {
    tFsiPath            : alpha(256);
    tRes                : int;
  }

{
  if (aOutputFile != '')
    aOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  // Kombination aus Fetch_BCS und Checkout_BCS sorgt dafür dass branches wenn erforderlich lokal AUS DEM REPO neu angelegt werden (nicht von lokalem HEAD)
  tRes # SysExecute('cmd.exe', '/c "git fetch origin ' + aBranch + '"' + aOutputFile, _ExecHidden | _ExecWait);

  FsiPathChange(tFsiPath);

  return(tRes);
}


sub Checkout_BCS
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aBranch               : alpha;        // Branch name to checkout from
  opt aOutputFile       : alpha(256);   // Path for result file
)

  local
  {
    tFsiPath            : alpha(256);
    tBranchOption       : alpha(2);     // c.f. where it is assigned
  }

{

  if (ExistsLocalBranch(aRepositoryPath, aBranch))
  {
    tBranchOption # '';  // einfach auf bestehenden branch wechseln, daher leer
  }
  else
  {
    tBranchOption # '-b';  // branch muss neu erstellt werden, daher kleines -b. NIRGENDS großes -B nutzen, denn das resettet branch, falls er existiert.
  }

  if (aOutputFile != '')
    aOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  //SysExecute('cmd.exe', '/c "git checkout ' + tBranchOption + ' ' + aBranch + ' origin/' + aBranch + '"' + aOutputFile, _ExecHidden | _ExecWait);
  SysExecute('cmd.exe', '/c "git checkout ' + tBranchOption + ' ' + aBranch + '"' + aOutputFile, _ExecHidden | _ExecWait);

  FsiPathChange(tFsiPath);
}


sub Push_BCS
(
  aRepositoryPath       : alpha(256);   // Path of repository
  aRemoteBranch         : alpha;        // Branch name to push into
  opt aOutputFile       : alpha(256);   // Path for result file
)

  local
  {
    tFsiPath            : alpha(256);
  }

{
  if (aOutputFile != '')
    aOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  // ohne Angabe von repo URL und branch Name erkennen IDE Integrationen von git, dass in denselben branch gepusht wurde
  // und aktualisieren angezeigte Infos. Es ist dann kein extra (already-up-to-date-)push innerhalb der IDE mehr nötig.
  SysExecute('cmd.exe', '/c "git push --set-upstream origin ' + aRemoteBranch + '"' + aOutputFile, _ExecHidden | _ExecWait);

  FsiPathChange(tFsiPath);
}



//---------------------------------------------------------------------------------------------------------------------------------------------
// BCS customized functions, building on those in Plugin.Git.prc
//---------------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------------
// Custom Methods:
//---------------------------------------------------------------------------------------------------------------------------------------------

sub checkPrerequisites
()
: int;

  local
  {
    tInstructions : alpha(4096);
    tReturnValue : int;
  }

{

  tInstructions # 'Bitte repository "' + sRepoName + '" so klonen, dass dessen Wurzelverzeichnis "' + sRepoName + '" in "' + sRepoLocation + '" liegt.'

  if (!FsiDirExists(gWorkspacePath))
  {
    tReturnValue # _ErrFsiNoPath;
    Plugin.SetStatus('Verzeichnis "' + gWorkspacePath + '" existiert nicht. ' + tInstructions + ' Export abgebrochen.')
  }
  else
  {
    if (!CheckValidPath())
    {
      tReturnValue # _ErrFsiNoPath;
      Plugin.SetStatus('Verzeichnis "' + gWorkspacePath + '" existiert, aber enthält kein git repository. ' + tInstructions + ' Export abgebrochen.');
    }
    else
    {
      tReturnValue # _ErrOK;
    }
  }

  ErrSet(tReturnValue);
  return tReturnValue;

}


sub initiate
()
{
  VarAllocate(globals_git);
  gWorkspacePath # sRepoLocation + '\' + sRepoName;
  gImportProtocolFilename # gWorkspacePath + '\import_protokoll.txt';

  // more globals used by the plugin code, init here:
  gTxtBufResult # TextOpen(128);
  gProcCheckBufRoot # CteOpen(_CteList);
}

sub terminate
()
{
  VarFree(globals_git);
}


sub getRepoFullPath
() : alpha;
{
  return gWorkspacePath;
}


/*
returns the name of the current local branch in the repository
*/
sub getCurrentBranchName
(
  aRepositoryPath       : alpha(256);   // Path of repository
  opt aOutputFile       : alpha(256);   // Path for result file
)
: alpha;

  local
  {
    tGitSuffixForOutputFile : alpha(256);
    tFsiPath                : alpha(256);
    tRes                    : int;
    tFileHandle             : handle;
    tFileErr                : int;
    tReturnValue            : alpha(4096);
  }

{
  if (aOutputFile = '')  // if nothing is passed, set a proper default:
    aOutputFile # 'git_out_getCurrentBranchName.txt'

  tGitSuffixForOutputFile # ' > ' + aOutputFile + ' ' + sGitFileOutputTag;

  tFsiPath # FsiPath();
  FsiPathChange(aRepositoryPath);

  // Leider schleift der Rückgabewert von SysExecute() nicht den Rückgabewert des aufgerufenen Programms durch, sondern liefert nur einen internen Wert
  // darüber ob Funktion SysExecute() die gerufene Funktion finden konnte...
  tRes # SysExecute('cmd.exe', '/c "git rev-parse --abbrev-ref HEAD"' + tGitSuffixForOutputFile, _ExecHidden | _ExecWait);
  //...weswegen der folgende Umweg über aOutputFile erforderlich ist:
  tFileHandle # FsiOpen(aOutputFile, _FsiStdRead);
  tFileErr # tFileHandle->FsiRead(tReturnValue);
  tFileHandle->FsiClose()

  FsiPathChange(tFsiPath);

  if (tFileErr < 0)
  {
    WinDialogBox
    (
      0,
      'ERROR',
      'Kann aktuellen Branch des Repositories "' + aRepositoryPath + '" nicht ermitteln, da die Datei "' + aOutputFile +
      '" nicht eingelesen werden kann. Fehlerwert von FsiRead(): "' + CnvAI(tFileErr) +
      '". Es muss ein Fehler vorliegen. Beende alle Prozeduren (exit).',
      _WinIcoError,
      _WinDialogOk,
      0
    );
    exit;
  }

  tReturnValue # Lib_Strings:Strings_ReplaceEachToken(tReturnValue, StrChar(10) + StrChar(13), '');

  return(tReturnValue);
}


/*
checks whether the current local branch in the repository matches the customer (or STD) of the C16 dataspace
*/
sub repoIsOnCorrectBranch(opt aExitOnError : logic) : logic;
  local
  {
    vCorrectGitBranchName : alpha(256);
    vCurrentGitBranchName : alpha(256);
    vRetVal               : logic;
  }
{

  RecRead(903,1,0);   // Lies Settings, damit Zugriff auf Set.Installname funktioniert

  if (Set.Installname='STD')
  {
    // Quell-Datenraum ist STD, dies beeinflusst z.B. den Namen des branch in den committed wird
    vCorrectGitBranchName # 'standard/master';
  }
  else
  {
    // Quell-Datenraum ist DEV (also BCS-seitiger, kundenspezifischer DEV Datenraum)
    vCorrectGitBranchName # StrCnv(Set.Installname, _StrLower) + '/master';
  }

  vCurrentGitBranchName # getCurrentBranchName(getRepoFullPath());
  vRetVal # vCurrentGitBranchName = vCorrectGitBranchName;

  if (aExitOnError and !vRetVal)
  {
    MsgGitError
    (
      'Git-Export wurde aus Datenraum "' + Set.Installname + '" aufgerufen. Daraus soll nur auf den entsprechenden Git-Branch "' + vCorrectGitBranchName +
      '" exportiert werden. Aktuell befindet sich das lokale Repository auf Branch "' + vCurrentGitBranchName + '".' + StrChar(10) + StrChar(10) +
      'Deswegen ABBRUCH / EXIT' + StrChar(10) + StrChar(10) +
      'Bitte auf korrekten Branch "' + vCorrectGitBranchName + '" wechseln und Export neu starten.'
    );
    exit;
  }

  return vRetVal;

}


sub wrapperExport
(
  opt doNotTerminate                : logic;  // pass true to disable deallocation, e.g. when further calls to git functions follow (cf. gitForCreateUpdate())
  opt doNotAskForUserspecificExport : logic;  // pass true to skip dialog about exporting only files of current user, and always do full export (with deletions)
)
: int;

  local
  {
    tOnlyWithThisUserLast : alpha;            // cf. docs of aOnlyWithThisUserLast in Plugin.ExportAllProcedures
    tPathDatastructure    : alpha;
    vCteDatastructureJson : handle;
    tReturnValue          : int;
  }
{
  initiate();
  tReturnValue # checkPrerequisites();

  // passing true means, the following check will show error dialog and completely exit if branch is not correct:
  repoIsOnCorrectBranch(true);

  if(tReturnValue = _ErrOK)
  {

    if (doNotAskForUserspecificExport)
    {
      tOnlyWithThisUserLast # '';  // '' means: full export
    }
    else
    {
      UserInfo(_UserCurrent);
      tOnlyWithThisUserLast # UserInfo(_UserName);
      if (_WinIdNo = WinDialogBox(0, 'Git für C16', 'Soll Git-Export auf aktuellen User "' + tOnlyWithThisUserLast + '" beschränkt werden?' + StrChar(10) + '(Löschungen in C16 werden dann nicht im git gelöscht)', _WinIcoQuestion, _WinDialogYesNo, 0))
      {
        tOnlyWithThisUserLast # '';
      }
    }

    // Prozeduren ins git exportieren:
    Plugin.ExportAllProcedures(tOnlyWithThisUserLast);

    // Datenstruktur als json im git ablegen:
    tPathDatastructure # gWorkspacePath + '\datastructure'
    FsiPathCreate(tPathDatastructure);
    vCteDatastructureJson # C16_DatenstrukturDif:DatastructureToJson();
    vCteDatastructureJson->JsonSave(tPathDatastructure + '\datastructure.json', _JsonSaveDefault, 0, _CharsetUTF8);
    Lib_Json:CloseJSON(var vCteDatastructureJson);

  }

  if (!doNotTerminate)
  {
    terminate();
  }

  return tReturnValue;
}


sub wrapperImport
(
  opt doNotTerminate : logic;  // pass true to disable deallocation, e.g. when further calls to git functions follow (cf. gitForCreateUpdate())
)
: int;

  local
  {
    tReturnValue : int;
  }
{
  initiate();
  tReturnValue # checkPrerequisites();
  if(tReturnValue = _ErrOK)
  {
    Plugin.ImportAllProcedures();
  }

  if (!doNotTerminate)
  {
    terminate();
  }

  return tReturnValue;
}


sub gitForCreateUpdate
(
  aVersionString : alpha(20);
)
  local
  {
    vGitBranchName          : alpha(4096);
    vGitCommitMsgCustomPart : alpha(4096);
    vKuerzel                : alpha(20);
    vDoAutoGit              : logic;
    vDetailedDialogs        : logic;
    vVorbelegung            : int;
  }
{

  RecRead(903,1,0);   // Lies Settings, damit Zugriff auf Set.Installname funktioniert

  if (Set.Installname='')
  {
    MsgGitError(
    'Fehler in gitForCreateUpdate():' + StrChar(10) + StrChar(10) +
    'Set.Installname in Tabelle 903 ist leer. Um zu vermeiden dass Code dem falschen Kunden/branch zugeordnet wird, wird deswegen nun vollständig abgebrochen.' + StrChar(10) + StrChar(10) +
    'Bitte Set.Installname in Tabelle 903 mit dem passenden Kunden-Kürzel befüllen und erneut starten.'  + StrChar(10) + StrChar(10) +
    'ABBRUCH (exit).'
    )
    exit;
  }

  if (Set.Installname='STD')
  {
    // Quell-Datenraum ist STD, dies beeinflusst z.B. den Namen des branch in den committed wird
    vKuerzel # 'STD';
    vGitBranchName # 'standard/master';
    vDoAutoGit # true;  // automatische Git Nutzung für STD ist aktiviert
  }
  else
  {
    // Quell-Datenraum ist DEV (also BCS-seitiger, kundenspezifischer DEV Datenraum)
    vKuerzel # StrCnv(Set.Installname, _StrUpper);
    vGitBranchName # StrCnv(Set.Installname, _StrLower) + '/master';
    vDoAutoGit # true;  // automatische Git Nutzung aktuell nur für STD aktiviert, nicht für DEV Datenraeume der Kunden
  }

  if (vDoAutoGit)
  {

    // Initialisierung der Git-relevanten C16-Variablen etc.
    initiate();
    if (gUsername='AH') vVorbelegung # 2;
    if (_WinIdYes = WinDialogBox(0, 'Git für C16', 'Detaillierte Git-Dialoge für Developer anzeigen?', _WinIcoQuestion, _WinDialogYesNo, vVorbelegung))
    {
      vDetailedDialogs # true;
    }
    else
    {
      vDetailedDialogs # false;
    }

    if (vDetailedDialogs)
    {
      MsgGitInfo(
        'Auto-Git: Änderungen für "' + vKuerzel + '" werden im Folgenden im git protokolliert. Unabhängig davon wird zunächst IMMER auf branch' + StrChar(10) +
        'standard/master' + StrChar(10) +
        'gewechselt. Details in den folgenden Meldungen.'
      )
    }

    // GIT FETCH & CHECKOUT: hole und wechsle zunächst immer erst auf standard/master branch.
    // Das dient dazu, dass auf jeden Fall alle ggf. neu angelegten Kunden-spezifischen branches von
    // standard/master abgebrancht sind, und nicht vom zufälligerweise zuletzt ausgewählten branch.
    if (vDetailedDialogs)
    {
      MsgGitInfo(
        'Für Nicht-Entwickler:innen: Bitte einfach OK klicken.' + StrChar(10) + StrChar(10) +
        'Für Entwickler:innen: Bitte im Repository/Projekt in ' + StrChar(10) +
        getRepoFullPath() + StrChar(10) +
        'alle nicht-committeten Änderungen COMMITTEN UND PUSHEN (!) und auf den branch' + StrChar(10) +
        'standard/master' + StrChar(10) +
        'wechseln.' + StrChar(10) + StrChar(10) +
        'Es wird grundsätzlich zuerst auf standard/master gewechselt mit dem Ziel dass alle ggf. neu angelegten branches davon abgebrancht sind. ' +
        'Außerdem ist es essentiell dass das Repository/Projekt frei von noch zu committenden Änderungen ist, denn diese können den Wechsel der branches verhindern oder würden sonst Teil automatischer commits.'
      );
    }
    Fetch_BCS
    (
      getRepoFullPath(),
      'standard/master',
      'git_out_standardmaster_01_fetch.txt'
    )
    Checkout_BCS
    (
      getRepoFullPath(),
      'standard/master',
      'git_out_standardmaster_02_checkout.txt'
    );
    // GIT PULL: aktuellsten Stand vom Server holen
    if (vDetailedDialogs)
    {
      MsgGitInfo(
        'git pull von standard/master startet nach Klick auf OK...'
      );
    }
    Pull
    (
      getRepoFullPath(),
      gitRepoRemote,
      'standard/master',
      'git_out_standardmaster_03_pull.txt'
    )

    // Ab hier geht es um den eigentlichen Ziel-Branch.
    if (vDetailedDialogs)
    {
      MsgGitInfo(
        'Auto-Git: Nun wird auf den Ziel-Branch für "' + vKuerzel + '" gewechselt. Dessen name lautet' + StrChar(10) +
        '"' + vGitBranchName + '"' + StrChar(10) +
        'Dies geschieht auch dann, wenn der Ziel-Branch standard/master ist und dorthin bereits im vorigen Schritt gewechselt wurde.'  // Nicht zuletzt damit gesamtes Log "git_out_*" immer vollständig überschrieben wird.
      )
    }

    // GIT FETCH & CHECKOUT: hole und wechsle auf entsprechenden remote branch
    Fetch_BCS
    (
      getRepoFullPath(),
      vGitBranchName,
      'git_out_01_fetch.txt'
    )
    Checkout_BCS
    (
      getRepoFullPath(),
      vGitBranchName,
      'git_out_02_checkout.txt'
    );

    // GIT PULL: aktuellsten Stand vom Server holen
    if (vDetailedDialogs)
    {
      MsgGitInfo(
        'git pull von "' + vGitBranchName + '" startet nach Klick auf OK...'
      );
    }
    Pull
    (
      getRepoFullPath(),
      gitRepoRemote,
      vGitBranchName,
      'git_out_03_pull.txt'
    )

    // Export der Prozeduren aus C16 in das Repository
    wrapperExport(true, true);

    // Nutzer nach einem custom Anteil der commit message fragen:
    // Dialog funktioniert nur nur wenn Applikation geladen:
    if (VarInfo(WindowBonus) > 0)  // pruefe ob SC Applikation geladen
    {
      Dlg_Standard:Standard('Anlass des Updates:', var vGitCommitMsgCustomPart);
    }
    else
    {
      vGitCommitMsgCustomPart # 'Keine manuelle Anlass-Nachricht, da gitForCreateUpdate() ausserhalb der SC Applikation verwendet wurde.';
    }


    // GIT COMMIT: Änderungen in lokales git bringen
    if (vDetailedDialogs)
    {
      MsgGitInfo(
        'git commit startet nach Klick auf OK...'
      );
    }
    Commit
    (
      getRepoFullPath(),
      'Auto-Commit aus CreateUpdate: ' + vKuerzel + ' Version ' + aVersionString + ', Anlass: ' + vGitCommitMsgCustomPart,
      'git_out_04_commit.txt'
    )


    // GIT PUSH: Änderungen zum Server transferieren
    if (vDetailedDialogs)
    {
      MsgGitInfo(
        'git push startet nach Klick auf OK...'
      );
    }
    /*// bei dieser Variante bekommen die IDEs den Push nicht mit, da das repo voll qualifiziert wird (siehe git_out_04_push.txt)
    Push
    (
      getRepoFullPath(),
      gitRepoRemote,
      vGitBranchName,
      'git_out_05_push.txt'
    )
    */
    Push_BCS
    (
      getRepoFullPath(),
      vGitBranchName,
      'git_out_05_push.txt'
    )


    // Abschließender reminder an Entwickler:innen die evtl auch außerhalb des Update Prozesses git nutzen
    if (vDetailedDialogs)
    {
      MsgGitInfo(
        'Für Nicht-Entwickler:innen: Bitte nochmal einfach OK klicken.' + StrChar(10) + StrChar(10) +
        'Für Entwickler:innen: Bitte daran denken dass im Repository/Projekt in ' + StrChar(10) +
        getRepoFullPath() + StrChar(10) +
        'noch immer der branch' + StrChar(10) +
        '"' + vGitBranchName + '"' + StrChar(10) +
        'ausgecheckt ist.' + StrChar(10) + StrChar(10) +
        'Bitte den branch bei Bedarf nun manuell zurückwechseln.'
      );
    }

  }

}


//---------------------------------------------------------------------------------------------------------------------------------------------
// MAIN with usage examples
//---------------------------------------------------------------------------------------------------------------------------------------------

main
(
)
  local
  {
  }
{

  wrapperExport();
  //wrapperImport();
  //gitForCreateUpdate('1.2.3');  // Versionsnummer, kommt eigentlich aus App_Update_Data
  //initiate(); __debug_popup('Ergebnis von ExistsLocalBranch: ' + CnvAI(CnvIL(ExistsLocalBranch(getRepoFullPath(), 'standard/master'))));
  //initiate(); __debug_popup('Ergebnis von ExistsRemoteBranch: ' + CnvAI(CnvIL(ExistsRemoteBranch(getRepoFullPath(), 'standard/master'))));

  /*
  initiate();
  //__debug_popup(ABool(getCurrentBranchName(getRepoFullPath()) = 'standard/master'));
  __debug_popup(ABool(repoIsOnCorrectBranch(true)));
  terminate();
  */

  __debug_popup('main Methode von Git_for_C16 wurde erfolgreich aufgerufen. Beenden durch Klick auf OK.');

}
