@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Transfers
//                        OHNE E_R_G
//  Info
//
/***

BULK INSERT xxx FROM 'c:\debug\106txt'
WITH (
 FIELDTERMINATOR ='\r',
 RowTerminator = '\n',
 Codepage = '1252',
 datafiletype = 'char'
);

***/
//
//
//
//  08.03.2017  AH  Erstellung der Prozedur
//  16.04.2018  AH  Fix
//  30.08.2018  AH  Fix für Zeilenende
//  27.07.2021  AH  ERX
//  21.02.2022  ST  Edit: SYNC(...) Aufruf mit Silent
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  cGrenze       : 10
  cPath         : 'c:\debug\'
  cProto        : '!SYNC_PROTOKOLL'

  Guid(a)       : '{'+Lib_ODBC:GUID(a, RecInfo(a, _RecID),false)+'}';
  Datum(a)      : SQLTimeStamp(a, 0:0,  y);
  Zeit(a)       : SQLTimeStamp(0.0.0,a, n);
  Proto(a,b)    : TextAddLine(vProto, cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+' | '+b)
end;

declare DeleteTransfer(aDatei : int; aPath : alpha(250));
declare BuildTransfer(aDatei : int; aProc   : alpha);
declare ExportTransfer(aDatei : int; aPath : alpha(250));
declare ConvertFile(aSrcName : alpha(4000); aDstName : alpha(4000); opt aAppend : logic);
declare DoIt(aDatei : int; aDatei2 : int; aPath : alpha(4000));



//========================================================================
//  SYNC
//
//
//  Call Lib_Transfers:SYNC
//
//  oder
//    auch per Prozedur  "Lib_Transfers:Sync(848,true);" Silent für viele Dateien aufrufbar
//
//========================================================================
sub SYNC(opt vOnly : int; opt aSilent : logic) : logic;
local begin
  Erx       : int;
  vTxt      : int;
  vTxt2     : int;
  vProto    : int;
  vTabName  : alpha;
  vCount    : int;
  vI,vJ     : int;
  vDatei    : int;
  vA        : alpha(250);
  vDia      : int;
  vErrCount : int;
end;
begin
  
  if (gOdbcApi=0) then begin
    Lib_odbc:Init(TRUE);
  end;

  if (!aSilent) then begin
    if (vONLY<>0) then begin
      if (Msg(99,'Nur Datei '+aint(vONLY)+'neu syncen?',_WinIcoQuestion, _WinDialogYesNo, 2)<>_Winidyes) then RETURN false;
    end
    else begin
      if (Msg(99,'NEUE SQL-Datenbank erstellen?',_WinIcoQuestion, _WinDialogYesNo, 2)<>_Winidyes) then RETURN false;
    end;
  end;

  vProto  # TextOpen(20);
  Proto(vProto, '*** SYNC START ***');

  // SQL-Datenbank erstellen -------------------------------------
  if (vONLY=0) then begin
    if ( Lib_Odbc:FirstScript(true)=false) then begin
      Proto(vProto, '*** FATAL : SQL-Datenbank nicht erstellbar ***');
      TextWrite(vProto, cProto, 0);
      TextClose(vProto);
      Msg(99,'SQL-Datenbank nicht erstellbar!',0,0,0);
      RETURN false;
    end;
  end
  else begin
    Lib_Odbc:ScriptOneTable(vONLY, aSilent);
  end;


  vDia # Lib_Progress:Init('Init Sync...', 999, true);

  vTxt  # TextOpen(20);
  vTxt2 # TextOpen(20);

  Proto(vProto, 'Prepare Transfers');

  TextRead(vTxt, 'Lib_Transfers2', _TextProc);
  vI # Textsearch(vTxt, 1, 1, 0, '// AUTOMATISCHER PROZEDURTEXT:');
  if (vI=0) then begin
    Lib_Progress:Term(vDia);
    Proto(vProto, '*** FATAL : Autoprozedur Fehler 1 ***');
    TextWrite(vProto, cProto, 0);
    TextClose(vProto);
    TextClose(vTxt);
    TextClose(vTxt2);
    Msg(99,'Autoprozedur Fehler 1',0,0,0);
    RETURN false;
  end;
  // alle AUTO-Zeilen löschen...
  WHILE (TextInfo(vTxt, _TextLines)>vI) do begin
    TextLineRead(vTxt, vI+1, _TextLineDelete);
  END;


  Proto(vProto, 'build Transfers');
  // TANSFERS + PROC BAUEN ------------------------------
  FOR vDatei # 1 LOOP inc(vDatei) WHILE (vDatei<=999) do begin

    vTabName # Lib_ODBC:TableName(vDatei);
    if (vTabName='') then CYCLE;

    vCount # RecInfo(vDatei,_recCount);

    if (vDatei<>vONLY) and (vONLY<>0) then CYCLE;

    if (vONLY=0) and ((vCount<cGrenze) or (vDatei=931)) then
      CYCLE;

    Lib_Progress:Reset(vDia, 'build Transfer '+aint(vDatei)+'...', 999);

    // Transfer aufbauen...
    //DeleteTransfer(vDatei, 'EX'+aint(vDatei));
    DeleteTransfer(vDatei, 'AUTO_SQL');
    
    BuildTransfer(vDatei, 'EX'+aint(vDatei));//, 'c:\debug\'+vTabName);

    TextAddLine(vTxt, '// -------------------------------------------------');
    TextRead(vTxt2, '!AutoTransferProc',0);
    // Zeilen umkopieren
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=TextInfo(vTxt2,_textLines)) do begin
      vA # TextLineRead(vTxt2, vI, 0);
      TextAddLine(vTxt, vA);
    END;
    TextAddLine(vTxt, '');
  END;
  TextWrite(vTxt, 'Lib_Transfers2', _TextProc);
  TextClose(vTxt);
  TextClose(vTxt2);

  if (ProcCompile('Lib_Transfers2')<>_errOK) then begin
    Proto(vProto, '*** FATAL : Compilerfehler der Autoprozedur ***');
    TextWrite(vProto, cProto, 0);
    TextClose(vProto);
    Lib_Progress:Term(vDia);
    Msg(99,'Compilerfehler der Autoprozedur!',0,0,0);
    RETURN false;
  end;


  Lib_Progress:Reset(vDia, 'Bulk Export + Import...', 999);
  // BULK EXPORTIEREN ----------------------------------------
  FOR vDatei # 1 LOOP inc(vDatei) WHILE (vDatei<=999) do begin

    vTabName # Lib_ODBC:TableName(vDatei);
    if (vTabName='') then CYCLE;

    vCount # RecInfo(vDatei,_recCount);
    Lib_Progress:Reset(vDia, vTabName, 999);
    // keine Daten? -> nächste Datei
    if (vCount=0) then
      CYCLE;

    if (vONLY=0) then begin
      // dirket per ODBC transferieren...
      if (vCount<cGrenze) or (vDatei=931) then
        CYCLE;
    end
    else begin
      if (vDatei<>vONLY) then CYCLE;
    end;

    // Daten exportieren...
    Proto(vProto, 'BULK-Export '+aint(vDatei)+' ('+aint(vCount)+' Saetze)');
    Lib_Progress:Reset(vDia, 'Bulk Export '+aint(vDatei)+'...', 100);
    ExportTransfer(vDatei, cPath+aint(vDatei)+'.txt');

    // Daten importieren...
    Proto(vProto, 'BULK-Import '+aint(vDatei)+' ('+aint(vCount)+' Saetze)');
    Lib_Progress:Reset(vDia, 'Bulk Import '+aint(vDatei)+'...', 100);
    vA # 'BULK INSERT '+vTabNAme+' FROM '''+cPath+aint(vDatei)+'.txt''';
    vA # vA +' WITH (';
    vA # vA +' FIELDTERMINATOR =''\r'',';
    vA # vA +' RowTerminator = ''\n'',';    // 30.08.2018 AH: KEIN "\r\n" sondern nur "\n" als Zeilenende
    vA # vA + ' Codepage = ''1252'',';        // ANSI
    vA # vA + ' datafiletype = ''char''';
    vA # vA +');';
    if (Lib_Odbc:ExecuteDirect(vA)=false) then begin
      Proto(vProto, '*** Error : '+vA);
      inc(vErrCount);
    end;

  END;


  Lib_Progress:Reset(vDia, 'Odbc sync ...', 999);
  // PER ODBC TRANSFERIEREN ----------------------------------
  FOR vDatei # 1 LOOP inc(vDatei) WHILE (vDatei<=999) and (vONLY=0) do begin

    vTabName # Lib_ODBC:TableName(vDatei);
    if (vTabName='') then CYCLE;

    vCount # RecInfo(vDatei,_recCount);
    Lib_Progress:Reset(vDia, vTabName, 999);
    // keine Daten? -> nächste Datei
    if (vCount=0) then
      CYCLE;

    // dirket per ODBC transferieren...
    if (vCount<cGrenze) or (vDatei=931) then begin
      Proto(vProto, 'ODBC-Export '+aint(vDatei)+' ('+aint(vCount)+' Saetze)');
      Lib_Progress:Reset(vDia, 'ODBC-Sync '+vTabName, vCount);
      if (Lib_ODBC:InsertAll(vDatei, 0.0.0, vDia, TRUE)=false) then begin   // SILENT
        Proto(vProto, '*** Error !!!');
        inc(vErrCount);

      end;
    end;
  END;


  if (vONLY=0) then begin
    Proto(vProto, 'ODBC-Export Texte');
    // TEXTE PER ODBC ---------------------------------------
    vTxt  # TextOpen(10);
    FOR Erx # Textread(vTxt,'', _TextFirst|_TextNoContents)
    LOOP Erx # Textread(vTxt,vA, _TextNext|_TextNoContents)
    WHILE (Erx<>_rNoRec) do begin
      vA # TextInfoalpha(vTxt, _textName);
      Lib_Progress:Reset(vDia, 'ODBC-SYNC Text '+vA, 999);
      if (Lib_ODBC:InsertText(vA,'',TRUE)=false) then begin // SILENT
        Proto(vProto, '*** Error !!!');
        inc(vErrCount);

      end;
    END;
    TextClose(vTxt);
  end;

  Proto(vProto, '*** ERRORS : '+aint(vErrCount)+' ***');
  Proto(vProto, '*** SYNC END ***');
  TextWrite(vProto, cProto, 0);
  TextClose(vProto);

  Lib_Progress:Term(vDia);

  if (!aSilent) then begin

    if (vErrCount=0) then
      Msg(999998,'',0,0,0)
    else
      Msg(99,'Erfolgreich MIT '+aint(vErrCount)+' Fehlern! Siehe Protokoll: '+cProto,0,0,0);

    Msg(99,'Protokoll in Text '+cProto,0,0,0);
    
  end;
end;



//========================================================================
/*
sub DoIt(aDatei : int; aDatei2 : int; aPath : alpha(4000));
begin

  BuildTransfer(aDatei, 'EX'+aint(aDatei), aPath);
  ExportTransfer(aDatei, aPath+'.Txt');

  if (aDatei2<>0) then begin
    BuildTransfer(aDatei2, 'EX'+aint(aDatei2), aPath);
    ExportTransfer(aDatei2, aPath+'2.Txt');
  end;
***/
/***
RETURN;

  ConvertFile(aPath+'_tmp.Txt', aPath+'.Txt');
  FsiDelete(aPath+'_tmp.Txt');

  if (aDatei2<>0) then begin
    ConvertFile(aPath+'2_tmp.Txt', aPath+'.Txt', true);
    FsiDelete(aPath+'2_tmp.Txt');
  end;
***/
//end;

/***
//========================================================================
//========================================================================
sub ConvertFile(
  aSrcName    : alpha(4000);
  aDstName    : alpha(4000);
  opt aAppend : logic;
);
local begin
  vSrc  : int;
  vDst  : int;
  vA    : alpha(4096);
  vS    : int;
end;
begin
  vSrc # FsiOpen(aSrcName,_FsiStdRead | _FsiPure);

  if (aAppend) then
    vDst # FsiOpen(aDstName, _FsiAcsRW | _FsiCreate | _FsiAppend | _FsiPure)
  else
    vDst # FsiOpen(aDstName, _FsiAcsRW | _FsiCreate | _FsiTruncate | _FsiPure);
//  vS   # FsiSize(vSrc);

  FsiMark(vSrc, 13);
  FsiRead(vSrc, vA);
  WHILE (vA<>'') do begin
//    vA # Str_ReplaceAll(vA,'"',Strchar(254));
    vA # Str_ReplaceAll(vA,Strchar(254),'""');
    vA # Str_ReplaceAll(vA,StrChar(253),'"');

    vA # vA + StrChar(13)+Strchar(10);
    FsiWrite(vDst, vA);

    FsiRead(vSrc, vA);
  END;

  FsiClose(vDst);
  FsiClose(vSrc);
end;
***/

//========================================================================
//========================================================================
sub BuildTransfer(
  aDatei  : int;
  aProc   : alpha;
  );
begin
  GV.int.01   # aDatei;
  GV.Alpha.01 # aProc;
//  GV.Alpha.02 # aFPath;
  CallOld('old_LibTransfers','CREATE');
end;


//========================================================================
//========================================================================
sub ExportTransfer(
  aDatei  : int;
  aPath   : alpha(250));
begin
  GV.int.01   # aDatei;
  GV.Alpha.01 # aPath;
  CallOld('old_LibTransfers','EXPORT');
end;


//========================================================================
//========================================================================
sub DeleteTransfer(
  aDatei  : int;
  aPath   : alpha(250));
begin
  GV.int.01   # aDatei;
  GV.Alpha.01 # aPath;
  CallOld('old_LibTransfers','DELETE');
end;


//========================================================================
Sub SQLTimeStamp(
  aDat    : date;
  aTim    : time;
  aAlsDat : logic) : alpha;
local begin
  vA  : alpha;
  vL  : int;
end;
begin

  if (aTim->vpHours=24) then aTim->vphours # 0;

  vL # LocaleLoad(_LclLangGerman, _LclSublangGerman);
//  vL # LocaleLoad(_LclLangEnglish, _LclSublangEnglishUK);
  vL->SysPropSet(_SysPropLclDateLFormat, 'yyyy-MM-dd');
//vL->SysPropSet(_SysPropLclDateLFormat, 'MM-dd-yyyy');
  vL->SysPropSet(_SysPropLclDateSep, '-');
  vL->SysPropSet(_SysPropLclDateLOrder, 2);

  // Führende Nullen bei 24-Stunden-Anzeige aktivieren
  vL->SysPropSet(_SysPropLclTimeHourMode, 1);
  vL->SysPropSet(_SysPropLclTimeLZero, 1);
/***
  if (aDat=0.0.0) then
    vA # cnvat(aTim,_FmtTime24Hours|_FmtTimeSeconds,vL)
  else
    vA # cnvad(aDat, _FmtDateLong, vL)+' '+cnvat(aTim,_FmtTime24Hours|_FmtTimeSeconds,vL);
***/
  if (aAlsDat=false) then begin
    vA # cnvat(aTim,_FmtTime24Hours|_FmtTimeSeconds,vL);
  end
  else begin
    if (aDat=0.0.0) then
      vA # ''
    else
      vA # cnvad(aDat, _FmtDateLong, vL)+' '+cnvat(aTim,_FmtTime24Hours|_FmtTimeSeconds,vL);
  end;
  LocaleUnload(vL);

  RETURN vA;

end;


//========================================================================
sub Bool(aWert : logic) : alpha
begin
//  if (aWert) then RETURN 'true'
//  else RETURN 'false';
  if (aWert) then RETURN '1'
  else RETURN '0';
end;

//========================================================================
sub FieldName(
  aDatei  : int;
  aTds    : int;
  aFld    : int);
begin
  GV.Alpha.01 # Lib_ODBC:FieldName(aDatei, aTds, aFld);
end;


//========================================================================
sub CheckFloatsInDatei(aDatei : int)
local begin
  Erx     : int;
  vMaxTds : int;
  vMaxFld : int;
  vTds    : int;
  vFld    : int;
  vTxt    : int;
  vI      : int;
  vA      : alpha;
  vF      : float;
end;
begin
  vTxt # TextOpen(20);
  vMaxTds # FileInfo(aDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      if (FldInfo(aDatei, vTds, vFld, _FldType)<>_TypeFloat) then CYCLE;
      TextAddLine(vTxt, aint(vTds)+'     '+aint(vFld));
//debugx(aint(vTds)+'     '+aint(vFld));
    END;
  END;
  
  // nur wenn FLOAT vorhanden...
  if (TextInfo(vTxt,_TextLines)>0) then begin
debugx('Datei '+aint(aDatei));
    FOR Erx # RecRead(aDatei,1,_recFirst)
    LOOP Erx # RecRead(aDatei,1,_recNext)
    WHILE (erx<=_rLocked) do begin
      FOR vI # TextInfo(vTxt,_TextLines)
      LOOP dec(vI)
      WHILE (vI>0) do begin
        vA # TextLineRead(vTxt, vI, 0);
        vTds  # cnvia(StrCut(vA,1,5));
        vFld  # cnvia(StrCut(vA,5,5));
        vF # FldFloat(aDatei, vTds, vFld);
        if (vF<-100000000000.0)  or (vF>100000000000.0) then
          debug('Wertproblem bei '+Fldname(aDatei, vTds, vFld)+' KEY'+aint(aDatei));
      END;
    END;
  end;

  TextClose(vTxt);
end;


//========================================================================
//  call Lib_transfers:CheckFloats
//========================================================================
sub CheckFloats()
local begin
  vDatei  : int;
end;
begin
debugx('START prüfe floats...');

  FOR vDatei # 1
  LOOP inc(vDatei)
  WHILE (vDatei<999) do begin
    if (FileInfo(vDatei, _FileExists)=0) then CYCLE;
    if (FileInfo(vDatei, _FileKeyCOunt)=0) then CYCLE;
    CheckFloatsInDatei(vDatei);
  END;
debugx('ENDE!');
end;


//========================================================================
//========================================================================