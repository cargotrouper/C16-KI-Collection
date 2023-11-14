@A+
//                    OHNE E_R_G
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER
// ALLES OBSOLETE - SIEHE LIB_TRANSFER

//===== Business-Control =================================================
//
//  Prozedur  Lib_Odbc2
//
//  Info
//
//
//  06.03.2017  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

/***
define begin
  cGrenze       : 1
  cBulkPfad     : 'c:\debug\'
  cQualifier    : '"'//'ðð'
  cDebugDatei   : 811
  SQLTimeStamp  : Lib_SQL:SQLTimeStamp
end;

declare BulkOneTable(aDatei : int; aFile : int; aDia : int) : logic;
declare WriteAllRecs(aDatei : int; aDat : date; aTxt : int; aDia : int) : logic;
declare WriteRec(aDatei : int; aTxt : int) : logic;
declare WriteText(aName : alpha; aFile : int) : logic;
declare WriteHeader(aDatei  : int;  aFile   : int);

//========================================================================
//  FIRSTSYNC
//  Call Lib_ODBC2:FirstSync
//========================================================================
sub FirstSync() : logic;
local begin
  vTxt    : int;
  vI      : int;
  vA      : alpha;
  vDia    : int;
  vDat    : date;
  vFile   : int;
  vCount  : int;
end;
begin

//  if (Dlg_Standard:Datum('Ab Datum',var vDat, vDat)=false) then RETURN false;

  vDia # Lib_Progress:Init('cleaning up...', 999, true);

  // ALLES LÖSCHEN ---------------------------------------
  FOR vI # 1 LOOP inc(vI) WHILE (vI<=999) do begin
if (cDebugdatei<>0) and (vI<>cDebugDatei) then CYCLE;
    Lib_Progress:Step(vDia);

    vA # Lib_Odbc:TableName(vI);
    if (vA='') then CYCLE;
    if (Lib_Odbc:DeleteAll(vI)=false) then begin
      Lib_Progress:Term(vDia);
      RETURN falsE;
    end;
  END;


  // FÜLLEN -----------------------------------------------
  FOR vI # 1 LOOP inc(vI) WHILE (vI<=999) do begin

if (cDebugdatei<>0) and (vI<>cDebugDatei) then CYCLE;

    vA # Lib_Odbc:TableName(vI);
    if (vA='') then CYCLE;

    vCount # RecInfo(vI,_recCount);
    if (vI=200) then vCount # vCount + RecInfo(210,_recCount);
    if (vI=400) then vCount # vCount + RecInfo(410,_recCount);
    if (vI=401) then vCount # vCount + RecInfo(411,_recCount);
    if (vI=500) then vCount # vCount + RecInfo(510,_recCount);
    if (vI=501) then vCount # vCount + RecInfo(511,_recCount);
    if (vI=460) then vCount # vCount + RecInfo(470,_recCount);

    // Ablagen sind schon in Bestand exportiert...
    if (vI=210) then CYCLE;
    if (vI=410) then CYCLE;
    if (vI=411) then CYCLE;
    if (vI=510) then CYCLE;
    if (vI=511) then CYCLE;
    if (vI=470) then CYCLE;

    Lib_Progress:Reset(vDia, vA, 999);

    // keine Daten? -> nächste Datei
    if (vCount=0) then
      CYCLE;

    // dirket transferieren...
    if (vCount<cGrenze) then begin
      Lib_Progress:Reset(vDia, 'Sync '+vA, vCount);
      if (Lib_ODBC:InsertAll(vI, vDat, vDia)=false) then begin
        Lib_Progress:Term(vDia);
        RETURN falsE;
      end;
    end
    // BULK-File
    else begin

//  vPerTxt # FSIOpen(cBulkPfad+aint(aDatei)+'.txt', _FsiAcsRW | _FsiCreate | _FsiTruncate | _FsiPure); // ü=E8=232
      vFile # FSIOpen(cBulkPfad+vA+'.txt', _FsiAcsRW | _FsiCreate | _FsiTruncate | _FsiANSI); // ü=FC=252

      Lib_Progress:Reset(vDia, 'Bulk '+vA, vCount);

      WriteHeader(vI, vFile);

      if (BulkOneTable(vI, vFile, vDia)=false) then begin
        Lib_Progress:Term(vDia);
        RETURN false;
      end;

      FsiClose(vFile);

      Lib_Odbc:BulkImport(vI, cBulkPfad+vA+'.txt');
    end;

  END;


  // TEXTE FÜLLEN -----------------------------------------------
if (cDebugdatei=0) then begin
  vFile # FSIOpen(cBulkPfad+'Text.txt', _FsiAcsRW | _FsiCreate | _FsiTruncate | _FsiANSI); // ü=FC=252
  vTxt  # TextOpen(10);
  FOR Erx # Textread(vTxt,'', _TextFirst|_TextNoContents)
  LOOP Erx # Textread(vTxt,vA, _TextNext|_TextNoContents)
  WHILE (Erx<>_rNoRec) do begin
    vA # TextInfoalpha(vTxt, _textName);
    Lib_Progress:Reset(vDia, 'Text : '+vA,0);

    if (WriteText(vA, vFile)=false) then begin
      FsiClose(vFile);
      Lib_Progress:Term(vDia);
      TextClose(vTxt);
      RETURN false;
    end;
    FsiWrite(vFile, Strchar(13)+Strchar(10));
  END;
  TextClose(vTxt);

  FsiClose(vFile);
end;

  Lib_Progress:Term(vDia);

  Msg(99,'COPY CONTENT DONE!',0,0,0);

  RETURN true;
end;


//========================================================================
//  BulkOneTable
//
//========================================================================
sub BulkOneTable(
  aDatei      : int;
  aFile       : int;
  aDia        : int) : logic;
local begin
  vName     : alpha;
  vTabName  : alpha;
  vTxt      : int;
end;
begin

  vName # Lib_odbc:TableName(aDatei);

  if (vName<>'') then begin
    if (WriteAllRecs(aDatei, 0.0.0, aFile, aDia)=false) then begin
      RETURN false;
    end;
  end;

  if (aDatei=200) then begin
    if (WriteAllRecs(210, 0.0.0, aFile, aDia)=false) then begin
      RETURN false;
    end;
  end;
  if (aDatei=400) then begin
    if (WriteAllRecs(400, 0.0.0, aFile, aDia)=false) then begin
      RETURN false;
    end;
  end;
  if (aDatei=401) then begin
    if (WriteAllRecs(411, 0.0.0, aFile, aDia)=false) then begin
      RETURN false;
    end;
  end;
  if (aDatei=500) then begin
    if (WriteAllRecs(510, 0.0.0, aFile, aDia)=false) then begin
      RETURN false;
    end;
  end;
  if (aDatei=501) then begin
    if (WriteAllRecs(511, 0.0.0, aFile, aDia)=false) then begin
      RETURN false;
    end;
  end;
  if (aDatei=460) then begin
    if (WriteAllRecs(470, 0.0.0, aFile, aDia)=false) then begin
      RETURN false;
    end;
  end;

  RETURN true;
end;


//========================================================================
sub WriteHeader(
  aDatei  : int;
  aFile   : int;);
local begin
  vNullOK   : logic;
  vA        : alpha(4096);
  vMaxTds   : int;
  vTds      : int;
  vMaxFld   : int;
  vFld      : int;
  vFldName  : alpha;
  vErr      : alpha;
  vTabName  : alpha;
  vI        : int;
end;
begin

  // SPEZI
  if (aDatei=931) then begin
    FsiWrite(aFile, cQualifier+'ZuRecID'+cQualifier+';'+cQualifier+'lfdNr'+cQualifier+';'+cQualifier+'Name'+cQualifier+';'+cQualifier+'Inhalt'+cQualifier);
    RETURN;
  end;

  vTabName # Lib_ODBC:TableName(aDatei);
  if (vTabName='') then RETURN;

  FsiWrite(aFile, cQualifier+'RecID'+cQualifier);

  vMaxTds # FileInfo(aDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin

      vFldName # Lib_ODBC:FieldName(aDatei, vTds, vFld);
      if (vFldName='') then CYCLE;

      FsiWrite(aFile, ';'+vFldName);

    END;
  END;

  FsiWrite(aFile, Strchar(13)+strchar(10));
end;



//========================================================================
//========================================================================
sub WriteAllRecs(
  aDatei    : int;
  aDat      : date;
  aTxt      : int;
  aDia      : int) : logic;
local begin
  vMaxTds   : int;
  vTds      : int;
  vMaxFld   : int;
  vFld      : int;
  vFldName  : alpha;
  vErr      : alpha;
  vFirst    : logic;
end;
begin

  if (RecInfo(aDatei,_recCount)=0) then RETURN true;

  FOR Erx # RecRead(aDatei,1,_recFirst)
  LOOP Erx # RecRead(aDatei,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (aDia<>0) then adia->Lib_Progress:Step()

    // 03.03.2017 AH: ab Datum
    if (aDat>0.0.0) then begin
      case aDatei of
        200 : if (Mat.Anlage.Datum<aDat) then CYCLE;
//        201 : if (Mat.AF.Datum<aDat) then CYCLE;
        202 : if (Mat.B.Anlage.Datum<aDat) then CYCLE;
        203 : if (Mat.R.Anlage.Datum<aDat) then CYCLE;
        204 : if (Mat.A.Anlage.Datum<aDat) then CYCLE;
//        205 : if (Mat.Anlage.Datum<aDat) then CYCLE;
        210 : if ("Mat~Anlage.Datum"<aDat) then CYCLE;

        400 : if (Auf.Anlage.Datum<aDat) then CYCLE;
        401 : if (Auf.P.Anlage.Datum<aDat) then CYCLE;
//      402 : if (Auf.AF.Anlage.Datum<aDat) then CYCLE;
        403 : if (Auf.Z.Anlage.Datum<aDat) then CYCLE;
        404 : if (Auf.A.Anlage.Datum<aDat) then CYCLE;
        405 : if (Auf.K.Anlage.Datum<aDat) then CYCLE;
        410 : if ("Auf~Anlage.Datum"<aDat) then CYCLE;
        411 : if ("Auf~P.Anlage.Datum"<aDat) then CYCLE;

        440 : if (Lfs.Anlage.Datum<aDat) then CYCLE;
        441 : if (Lfs.P.Anlage.Datum<aDat) then CYCLE;

        500 : if (Ein.Anlage.Datum<aDat) then CYCLE;
        501 : if (Ein.P.Anlage.Datum<aDat) then CYCLE;
//        502 : if (Ein.AF.Anlage.Datum<aDat) then CYCLE;
        503 : if (Ein.Z.Anlage.Datum<aDat) then CYCLE;
        504 : if (Ein.A.Anlage.Datum<aDat) then CYCLE;
        505 : if (Ein.K.Anlage.Datum<aDat) then CYCLE;
        506 : if (Ein.E.Anlage.Datum<aDat) then CYCLE;
//        507 : if (Ein.AF.E.Anlage.Datum<aDat) then CYCLE;
        510 : if ("Ein~Anlage.Datum"<aDat) then CYCLE;
        511 : if ("Ein~P.Anlage.Datum"<aDat) then CYCLE;

        700 : if (BAG.Anlage.Datum<aDat) then CYCLE;
        701 : if (BAG.IO.Anlage.Datum<aDat) then CYCLE;
        702 : if (BAG.P.Anlage.Datum<aDat) then CYCLE;
        703 : if (BAG.F.Anlage.Datum<aDat) then CYCLE;
//        704 : if (BAG.Vpg.Anlage.Datum<aDat) then CYCLE;
//        705 : if (BAG.AF.Anlage.Datum<aDat) then CYCLE;
//        706 : if (BAG.AS.Anlage.Datum<aDat) then CYCLE;
        707 : if (BAG.FM.Anlage.Datum<aDat) then CYCLE;
//        708 : if (BAG.FM.B.Anlage.Datum<aDat) then CYCLE;
        709 : if (BAG.Z.Anlage.Datum<aDat) then CYCLE;
        710 : if (BAG.FM.FH.Anlage.Dat<aDat) then CYCLE;
//        711 : if (BAG.PZ.Anlage.Datum<aDat) then CYCLE;
      end;
    end;

    if (WriteRec(aDatei, aTxt)=false) then begin
      BREAK;
    end;
  END;  // Loop records

  RETURN true;
end;


//========================================================================
//  WriteRec
//
//========================================================================
sub WriteRec(
  aDatei      : int;
  aTxt        : int) : logic;
local begin
  vCount      : int;
  vMaxTds     : int;
  vTds        : int;
  vMaxFld     : int;
  vFld        : int;
  vFldName    : alpha;
  v930        : int;
  vGUID, vGUID2 : alpha;
  vA,vB       : alpha(4000);
end;
begin

  // SPEZI
  if (aDatei=931) then begin
    v930 # RecBufCreate(930);
    v930->CUS.FP.Nummer # CUS.FeldNummer;
    RecRead(v930,1,0);
    vGuid2  # Lib_ODBC:GUID(CUS.Datei, CUS.RecID,n);             // von Aufhängerdatei
    vGuid   # Lib_ODBC:GUID(aDatei, RecInfo(aDatei, _RecID),n);  // eigener Key
    vFld # CUS.LfdNr;
    vFldName # v930->CUS.FP.Name;

    FsiWrite(aTxt, '('+vGuid+','+vGuid2+','+aint(vFld)+','+vFldName+','+CUS.Inhalt+')');

    RecBufDestroy(v930);
    RETURN true;
  end;



  vA # cQualifier+'{'+Lib_ODBC:GUID(aDatei, RecInfo(aDatei, _RecID),false)+'}'+cQualifier;

  vMaxTds # FileInfo(aDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin

      vFldName # Lib_ODBC:FieldName(aDatei, vTds, vFld);
      if (vFldName='') then CYCLE;
      inc(vCount);

      vA # vA + ';'+cQualifier;
      case FldInfo(aDatei, vTds, vFld, _FldType) of
        //_TypeAlpha  : vA # vA + Lib_Strings:Strings_DOS2WIN(FldAlpha(aDatei, vTds, vFld));
        _TypeAlpha  : begin
            vB # FldAlpha(aDatei, vTds, vFld);
            if (StrFind(vB, cQualifier,0)>0) then begin
              vB # Lib_strings:Strings_replaceAll(vB, cqualifier,StrChar(254));
              vB # Lib_strings:Strings_replaceAll(vB,StrChar(254), cQualifier+cQualifier);
            end;
            vA # vA + vB;
          end;
        _TypeDate   : if (FldDate(aDatei, vTds, vFld)=0.0.0) then
                      vA # vA + 'null'
                    else
                      vA # vA + SQLTimeStamp(FldDate(aDatei, vTds, vFld),0:0);
        _Typeword   : vA # vA + aint(FldWord(aDatei, vTds, vFld));
        _typeint    : vA # vA + aint(FldInt(aDatei, vTds, vFld));
        _Typefloat  : vA # vA + cnvaf(FldFloat(aDatei, vTds, vFld),_FmtNumnoGroup|_FmtNumpoint, 0, 6);
        _typelogic  : if (FldLogic(aDatei, vTds, vFld)) then vA # vA + 'true' else vA # vA + 'false';
        _TypeTime   : vA # vA + SQLTimeStamp(0.0.0,FldTime(aDatei,vTds,vFld));
otherwise TODO('Y');
      end;
      vA # vA + cQualifier;
      FsiWrite(aTxt, vA);
      vA # '';
    END;
  END;

  vA # StrChar(13)+StrChar(10);
  FsiWrite(aTxt, vA);

  RETURN true;
end;


//========================================================================
//  WriteText
//
//========================================================================
sub WriteText(
  aName       : alpha;
  aFile       : int) : logic;
local begin
  vErr      : alpha;
  vA,vB     : alpha(4096);
  vPre      : alpha(500);
  vI,vJ     : int;
  vTxt      : int;
  vPos      : int;
  vMax      : int;
end;
begin

  // Copy text to memory...
  vTxt # TextOpen(20);
  Erx # Textread(vTxt, aName, 0);  // Text lesen

  if (TextSearch(vTxt, 1, 1, 0, StrChar(254,3))>0) then begin
    TextSearch(vTxt, 1, 1, 0, StrChar(254,3), StrChar(27,3));
    TextWrite(vTxt, aName, 0);
  end;

  FsiWrite(aFile, cQualifier+'{'+Lib_ODBC:TextGUID(aName)+'}'+cQualifier);
  FsiWrite(aFile, ';'+cQualifier+aName+cQualifier);
  FsiWrite(aFile, ';'+cQualifier);

  FOR vI # 1 loop inc(vI) while (vi<=TextInfo(vTxt, _textLines)) do begin
    vA # TextLineRead(vTxt, vI, 0);
    // add Softbreak???
    if (Textinfo(vTxt,_TextNoLineFeed)=0) then
      vA # vA + StrChar(10);
    FsiWrite(aFile, vA);

    vPos # vPos + StrLen(vA);
  END;


  FsiWrite(aFile, cQualifier);

  TextClose(vTxt);

  RETURN true;
end;


//========================================================================
//========================================================================
Sub Sql_Init();
begin

  if ( Lib_Odbc:FirstScript()) then begin
    FirstSync();
  end;

end;


//========================================================================

***/
