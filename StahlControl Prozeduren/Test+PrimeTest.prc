// ******************************************************************
//                    OHNE E_R_G
// *                                                                *
// *  PrimeTest                                                     *
// *                                                                *
// *  Überprüfung des Prime-Counters der vorhandenen Tabellen zur   *
// *  Vorbereitung für den Einsatz der Datenbank in Version 5.8.    *
// *                                                                *
// *                                                                *
// *                                                                *
// *  Erstellt: 2015-09-23 / vectorsoft AG                          *
// *                                                                *
// ******************************************************************

@A+
@C+

define
{
  sMaxPrimes57     : 0xFFFFFFFF\b     // Höchster verwendbarer Prime-Wert in Version 5.7 (32-bit).
  sMaxPrimes58_red : 0xFAFFFFFF\b     // Höchster verwendbarer Prime-Wert in Version 5.8 (32-bit).
  sMaxPrimes58_yel : 0x80000000\b     // Höchster eindeutiger Prime-Wert in Version 5.8 (32-bit).

  sPrimeStateUndef  : 0
  sPrimeStateGreen  : 1
  sPrimeStateYellow : 2
  sPrimeStateRed    : 3

  sCrLf : StrChar(13) + StrChar(10)

  mCnvAI(a) : CnvAI(a,_FmtNumLeadZero | _FmtNumNoGroup,0,2)
}

global gPrimeInfo
{
  gPrimeInfoFileNo      : word;   // Dateinummer.
  gPrimeInfoFileExists  : logic;  // Datei existiert y/n.
  gPrimeInfoPrime       : int;    // Größter verwendeter Prime der Datei.
  gPrimeInfoUsed        : bigint; // Anzahl der bereits verwendeten Prime-Werte.
  gPrimeInfoAvail57     : bigint; // Anzahl der noch verfügbaren Prime-Werte (Version 5.7).
  gPrimeInfoAvail58     : bigint; // Anzahl der noch verfügbaren Prime-Werte (version 5.8).
  gPrimeInfoAvailPerc57 : int;    // Anzahl der noch verfügbaren Prime-Werte in % (Version 5.7).
  gPrimeInfoAvailPerc58 : int;    // Anzahl der noch verfügbaren Prime-Werte in % (Version 5.8).
  gPrimeInfoState       : int;    // Prime-Status (red,yellow,green).
}

// ******************************************************************
// * GetClientRelease - Client-Version als String ermitteln         *
// ******************************************************************

sub GetClientRelease : alpha
local {
  vA : alpha;
}
{
  vA # mCnvAI(DbaInfo(_DbaClnRelMaj));
  vA # vA + mCnvAI(DbaInfo(_DbaClnRelMin));
  vA # vA + mCnvAI(DbaInfo(_DbaClnRelRev));
  vA # vA + CnvAI(DbaInfo(_DbaClnRelSub));
  RETURN vA;
}

// ******************************************************************
// * GetPrimeInfo - Prime-Information zu Datei generieren           *
// ******************************************************************

sub GetPrimeInfo
(
  aFileNo : int;
)
: handle;

  local
  {
    tHdl : handle;
  }

{
  tHdl # VarAllocate(gPrimeInfo);

  gPrimeInfoFileNo # aFileNo;
  gPrimeInfoFileExists # FileInfo(gPrimeInfoFileNo,_FileExists) = 1;

  if (gPrimeInfoFileExists)
  {
    // Größter verwendeter Prime.
    ErrTryCatch(_ErrValueOverflow,true);
    try
    {
      gPrimeInfoPrime # gPrimeInfoFileNo->RecInfo(_RecGetPrime);
    }

    // Version 5.8.01 oder höher und Prime-Wert > 32-bit.
    if (ErrGet() = _ErrValueOverflow)
    {
      gPrimeInfoPrime # 1;
      gPrimeInfoUsed  # 4294967295\b;
    }

    // Version 5.8.01 oder höher : 0 ... +2.147.483.647 (0xFFFFFFFF ... 0x7FFFFFFF)
    else if (GetClientRelease() >= '05080100')
      gPrimeInfoUsed # CnvBI(gPrimeInfoPrime);

    // -1 ... -2.147.483.648 (0xFFFFFFFF ... 0x80000000)
    else if (gPrimeInfoPrime <= 0)
      gPrimeInfoUsed # -CnvBI(gPrimeInfoPrime);

    //  1 ... +2.146.483.647 (0x00000001 ... 0x7FFFFFFF)
    else
      gPrimeInfoUsed # 2147483648\b + (2147483647\b - CnvBI(gPrimeInfoPrime) + 1\b);

    // Anzahl verfügbarer Prime-Werte in Version 5.7.
    gPrimeInfoAvail57 # sMaxPrimes57 - gPrimeInfoUsed;
    gPrimeInfoAvailPerc57 # CnvIB(gPrimeInfoAvail57 * 100\b / sMaxPrimes57);

    // Anzahl verfügbarer Prime-Werte in Version 5.8.
    if (gPrimeInfoUsed <= sMaxPrimes58_red)
      gPrimeInfoAvail58 # sMaxPrimes58_red - gPrimeInfoUsed;
    else
      gPrimeInfoAvail58 # 0\b;

    gPrimeInfoAvailPerc58 # CnvIB(gPrimeInfoAvail58 * 100\b / sMaxPrimes58_red);

    // Prime-Status für Benutzung der Datei in der Version 5.8.
    if (gPrimeInfoAvail58 = 0\b)
      gPrimeInfoState # sPrimeStateRed;
    else if (gPrimeInfoUsed > sMaxPrimes58_yel)
      gPrimeInfoState # sPrimeStateYellow;
    else
      gPrimeInfoState # sPrimeStateGreen;
  }
  else
    gPrimeInfoState # sPrimeStateUndef;

  return(tHdl);
}

// ******************************************************************
// * DestroyPrimeInfo - Prime-Information freigeben                 *
// ******************************************************************

sub DestroyPrimeInfo
(
  aPrimeInfo : handle;
)
{
  if (aPrimeInfo > 0)
  {
    VarInstance(gPrimeInfo,aPrimeInfo);
    VarFree(gPrimeInfo);
  }
}

// ******************************************************************
// * GetPrimeStateAsText - Prime-Status Text ermitteln              *
// ******************************************************************

sub GetPrimeStateAsText
(
  aPrimeState : int;
)
: alpha
{

  switch (aPrimeState)
  {
    case sPrimeStateUndef  : return('undefiniert');
    case sPrimeStateGreen  : return('grün');
    case sPrimeStateYellow : return('gelb');
    case sPrimeStateRed    : return('rot');
  }

  return('');
}

// ******************************************************************
// * WritePrimeInfoToFile - Prime-Information in aufbereiteter Form *
// *                        in externe Datei schreiben              *
// ******************************************************************

sub WritePrimeInfoToFile
(
  aFile      : handle;
  aPrimeInfo : handle;
)

  local
  {
    tPrimeState : alpha;
  }

{
  if (aPrimeInfo <= 0)
    return;

  VarInstance(gPrimeInfo,aPrimeInfo);

  aFile->FsiWrite('Datei : ' + CnvAI(gPrimeInfoFileNo) + sCrLf);

  tPrimeState # GetPrimeStateAsText(gPrimeInfoState);

  if (gPrimeInfoFileExists)
  {
    aFile->FsiWrite('Prime : ' + CnvAI(gPrimeInfoPrime) + sCrLf);
    aFile->FsiWrite('Verbrauchte Prime-Werte : ' + CnvAB(gPrimeInfoUsed) + sCrLf);
    aFile->FsiWrite('Verfügbare Prime-Werte (5.7) : ' + CnvAB(gPrimeInfoAvail57) + ' (' + CnvAI(gPrimeInfoAvailPerc57) + '%)' + sCrLf);
    aFile->FsiWrite('Verfügbare Prime-Werte (5.8) : ' + CnvAB(gPrimeInfoAvail58) + ' (' + CnvAI(gPrimeInfoAvailPerc58) + '%)' + sCrLf);
    aFile->FsiWrite('Verwendung für Version 5.8 : ' + tPrimeState);
  }
  else
    aFile->FsiWrite('Eine Datei mit dieser Nummer existiert nicht.' + sCrLf);

  aFile->FsiWrite(sCrLf + sCrLf);

}

// ******************************************************************
// * WritePrimeStatisticsToFile - Prime-Statistik Ausgabe           *
// ******************************************************************

sub WritePrimeStatisticsToFile
(
  aFileName       : alpha(4096);
)
: int;

  local
  {
    tFileNo        : int;
    tPrimeInfo     : handle;
    tFile          : handle;
    tCount         : int;
    tCountState    : int[3];
    tPrimeState    : alpha;
    tLoop          : int;
  }

{
  tFile # FsiOpen(aFileName,_FsiStdWrite | _FsiAnsi);
  if (tFile < 0)
    return(tFile);

  tFile->FsiWrite('Prime-Statistik für Datenbank ' + DbaName(_DbaAreaAlias) + sCrLf + sCrLf);

  for tFileNo # 1 loop inc(tFileNo) while (tFileNo <= 999)
  {
    if (FileInfo(tFileNo,_FileExists) = 1)
    {
      tPrimeInfo # GetPrimeInfo(tFileNo);

      inc(tCount);
      inc(tCountState[gPrimeInfoState]);

      WritePrimeInfoToFile(tFile,tPrimeInfo);

      DestroyPrimeInfo(tPrimeInfo);
    }
  }

  tFile->FsiWrite('* Zusammenfassung' + sCrLf);

  if (tCount > 1)
    tFile->FsiWrite(CnvAI(tCount) + ' Dateien überprüft.' + sCrLf);
  else if (tCount = 1)
    tFile->FsiWrite('Eine Datei überprüft.' + sCrLf);
  else
    tFile->FsiWrite('Keine Dateien überprüft.' + sCrLf);

  for tLoop # 1 loop inc(tLoop) while (tLoop <= 3)
  {
    tCount # tCountState[tLoop];
    tPrimeState # GetPrimeStateAsText(tLoop);

    if (tCount > 1)
      tFile->FsiWrite(CnvAI(tCount) + ' Dateien mit Status ' + tPrimeState + '.' + sCrLf);
    else if (tCount = 1)
      tFile->FsiWrite('Eine Datei mit Status ' + tPrimeState + '.' + sCrLf);
    else
      tFile->FsiWrite('Keine Datei mit Status ' + tPrimeState + '.' + sCrLf);
  }

  tFile->FsiWrite('________________________________________________________' + sCrLf);
  tFile->FsiWrite('grün : Die Datei ist ohne Änderung in Version 5.8 verwendbar.' + sCrLf);
  tFile->FsiWrite('gelb : Die Datei ist in der Version 5.8 verwendbar. Es sollte jedoch die 64-Bit Verarbeitung aktiviert werden.' + sCrLf);
  tFile->FsiWrite('rot  : Es sind keine Prime-Werte mehr verfügbar. Zur Verwendung mit Version 5.8 müssen die Datensätze ausgespielt,' + sCrLf +
                  '       ein Recover durchgeführt und anschließend die Datensätze wieder eingespielt werden.' + sCrLf);

  tFile->FsiClose();
  return(_ErrOK);
}

// ******************************************************************
// * main - Startprozedur                                           *
// ******************************************************************

main

  local
  {
    tFileName : alpha(4096);
  }

{
  tFileName # _Sys->spPathTemp + 'prime_stat_' + DbaName(_DbaAreaAlias) + '.txt';
  WritePrimeStatisticsToFile(tFileName);
  SysExecute('*' + tFileName,'',_ExecWait);
}