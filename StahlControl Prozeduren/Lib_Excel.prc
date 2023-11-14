@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Excel
//                        OHNE E_R_G
//  Info        Datei Dump
//
//
//  21.05.2005  AI  Erstellung der Prozedur
//  31.07.2012  MS  Dateinamen auf 4096 Zeichen erweitert
//  09.08.2012  ST  SchreibDaten: Bei Markierung, Max = # Markierungen
//  20.11.2012  AI  Komma statt Punkt als Dezimaltrennung bei Floats
//  07.12.2012  AI  "LiesDatei" leert den Buffer pro Datensatz
//  13.09.2016  AH  "SchreibeDatei" gibt immer 5 Nachkommastellen an
//  28.02.2017  ST  Dateinamenverlängerung beim Einlesen
//  03.04.2019  AH  "DataListToXML"
//  18.02.2021  AH  Kombilisten
//  18.05.2021  AH  "LiesDatei" von Datei 100 setzt Abhängikeiten
//  27.07.2021  AH  ERX
//  26.10.2021  AH  "KombiListTds"
//  06.05.2022  AH  Alphas auf 8000
//  2022-08-22  AH  Edit: für Datei 833/231
//  2022-08-30  AH  "ModKombiListFeld"
//  2023-04-28  AH  Kombilist kann auch Alias/Headernamen für Felder
//  2023-08-22  AH  "SplitteFeld" refactured
//
//  Subprozeduren
//    SUB SplitteFeld(varaA : alpha) : alpha;
//    SUB MainKeyisGood(aDatei : int) : logic;
//    SUB LiesDatei(aDatei : int; aName : alpha; aNeuanlage : logic) : logic;
//    SUB SchreibeDatei(aDatei : int; aName : alpha; aNurMarke : logic; opt aMax : int; opt aAppend : logic) : logic;
//    SUB SchreibeAuszug(aDatei : int; aName : alpha; aNurMarke : logic; aList : int) : logic;
//    SUB AddFld(aList : int; aName : alpha)
//    SUB DataListToXML()
//    SUB KombiListTds(var aList : int; aDatei : int; aTds : int)
//    SUB ModKombiListFeld
//
//========================================================================
@I:Def_global
define begin
  cSatzEnde   : Strchar(13)+Strchar(10)
  cFeldEnde   : ';'
  cTrans      : '"'
  Write(a)    : begin vOut # Lib_Strings:Strings_Dos2Win(a,y);  FsiWrite(vFile,vOut); end
  
  Write_Text(a)     : FSIWrite(vFile, '' + StrAdj(Lib_Strings:Strings_DOS2WIN(a),_StrBegin | _StrEnd) + '' + cFeldEnde)
  Write_Int(a)      : FSIWrite(vFile, StrAdj(Aint(a),_StrBegin | _StrEnd)+ cFeldEnde)
  Write_Date(a)     : FSIWrite(vFile, Cnvai(DateYear(a)+1900,_FmtNumLeadZero|_FmtNumnogroup,0,4) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) + Cnvai(DateDay(a),_FmtNumLeadZero,0,2) + cFeldEnde)
  Write_Time(a)     : FSIWrite(vFile, Cnvai(TimeHour(a),_FmtNumLeadZero,0,2)+Cnvai(TimeMin(a),_FmtNumLeadZero,0,2) + cFeldEnde)
  Write_Num(a,b)    : FSIWrite(vFile, Cnvaf(a,_FmtNumnogroup|_FmtNumpoint, 0, b) + cFeldEnde)
  Write_EOL(a)      : FSIWrite(vFile, cSatzEnde);
end;

local begin
  vErg : int;
  vFileArr  :  int[300];
  vTdsArr   :  int[300];
  vFldArr   :  int[300]
end;

/**** 2023-08-22  AH ALT - BUGGY
//========================================================================
//  SplitteFeld
//
//========================================================================
sub SplitteFeld(var aA : alpha) : alpha;
local begin
  vX,vY   : int;
  vL      : int;
  vFeld   : alpha(8000);
end;
begin
  vL # StrLen(aA);
  vX # StrFind(aA,'"',0);
  vY # StrFind(aA,';',0);
  if (vX=0) and (vY=0) then begin // keine Trennzeichen da?
    vFeld # aA;
    aA # '';
    end
  else begin
    if (vx=0) then vX # 99999;
    if (vY<vX) and (vy<>0) then begin   // Semikolon gefunden
      vFeld # StrCut(aA,1,vY-1);
        aA # StrCut(aA,vY+1,vL-vY)
      end
    else begin              // Anführungszeichen gefunden
      vY # StrFind(aA,'";',vX);
      if (vY<>0) then begin
        vFeld # StrCut(aA,vX+1,vY-vX-1);
        aA # StrCut(aA,vY+2,vL-vY);
        end
      else begin
        vY # StrFind(aA,'"',vX+1);
        if (vY<>0) then begin
          vFeld # StrCut(aA,vX+1,vY-vX-1);
          aA # '';
          end
        else begin
          vFeld # '';
          aA # '';
        end;
      end;
    end;
  end;

  if (StrToChar(vFeld,vL)=13) then vFeld # StrCut(vFeld,1,vL-1);
  vFeld # Lib_Strings:STRINGS_Win2Dos(vFeld);

  RETURN vFeld;
end;
***/


/*========================================================================
2023-08-21  AH
========================================================================*/
sub SplitteFeld(var aA : alpha) : alpha;
local begin
  vX,vY         : int;
  vL            : int;
  vFeld         : alpha(8000);
  vPos          : int;
  vInQuote      : logic;
  vKillNextSep  : logic;
  vDoppel       : logic;
end;
begin

  if (StrCut(aA,1,1)='"') then begin
    vInQuote # true;
    aA # StrCut(aA,2,5000);
  end;
  
  vL # StrLen(aA);
  FOR vPos # 1
  LOOP inc(vPos)
  WHILE (vPos<=vL) do begin

    if (vPos=vL) then begin   // ENDE erreicht
      // ENDE OHNE ""
      if (vInQuote=false) then begin
        vFeld # StrCut(aA,1,vPos);
        aA    # '';
        BREAK;
      end
      // ENDE in ""
      else begin
        if (StrCut(aA,vPos,1)='"') then begin
          vFeld # StrCut(aA,1,vPos-1);
          aA    # '';
        end
        else begin
          vFeld # StrCut(aA,1,vPos);    // unordenliches Ende
          aA    # '';
        end;
        BREAK;
      end;
    end;

    if (StrCut(aA,vPos,1)=';') then begin
      // Semikolon OHNE ""
      if (vInQuote=false) then begin
        vFeld # StrCut(aA,1,vPos-1);
        aA    # StrCut(aA,vPos+1,vL-vPos)
        BREAK;
      end
      // Semikolon in ""
      else begin
        CYCLE;
      end;
    end;

    if (StrCut(aA,vPos,1)='"') then begin
      // " OHNE ""
      if (vInQuote=false) then CYCLE;
      
      // " im ""
// "bla""Zoll"
      // DOPPEL "?
      if (StrCut(aA,vPos+1,1)='"') then begin
        vDoppel # true;
        vPos # vPos + 1;
        CYCLE;
      end;
      
      vFeld # StrCut(aA,1,vPos-1);
      aA    # StrCut(aA,vPos+1,vL-vPos);
      vKillNextSep # true;
      BREAK;
    end;
  END;

  if (vKillNextSep) then begin
    vPos # StrFind(aA,';',1);
    if (vPos>0) then begin
      aA # StrCut(aA,vPos+1,5000);
    end;
  end;
  
  if (vDoppel) then begin
    vFeld # Str_Replaceall(vFeld, '""', '"');
  end;
  
  if (StrToChar(vFeld,vL)=13) then vFeld # StrCut(vFeld,1,StrLen(vFeld)-1);
  vFeld # Lib_Strings:STRINGS_Win2Dos(vFeld);

  RETURN vFeld;
end;


//========================================================================
//  MainKeyIsGood
//
//========================================================================
sub MainKeyisGood(aDatei : int) : logic;
local begin
  vX,vY : int;
  vFld : int;
  vTds : int;
  vOk : logic;
end;
begin
  FOR vX # 1 LOOP inc(vX) WHILE (vX<=keyinfo(aDatei,1,_KeyFldCount)) do begin
    vFld # KeyFldInfo(aDatei,1,vX,_KeyFldNumber);
    vTds # KeyFldInfo(aDatei,1,vX,_KeyFldSbrNumber);
    vY # 1;
    vOk # n;
//debug('key:'+cnvai(vfld)+'/'+cnvai(vTds));
    WHILE (vFileArr[vY]<>0) and (vOk=n) do begin
      if (vFileArr[vY]=aDatei) and
          (vTdsArr[vY]=vTds) and
          (vFldArr[vY]=vFld) then vOk # y;
      inc(vy);
    END;
    if (vOK=n) then RETURN false;
  END;

  RETURN true;
end;


//========================================================================
//  LiesDatei
//
//========================================================================
sub LiesDatei(aDatei : int; aName : alpha(4000); aNeuanlage : logic) : logic;
local begin
  Erx     : int;
  vMaxTds :   int;
  vMaxFld :   int;
  vFile   :   int;
  vTds    :   int;
  vFld    :   int;
  vDatei  :   int;
  vFirst  :   logic;
  vHdl    :   int;

  vOut    :   alpha;
  vAnz    :   int;
  vX      :   int;
  vA      :   alpha(8096);
  vB      :   alphA(8096);
  vBuf    :   int;
  vID     :   int;

  vMax    :   int;
  vDia    :   int;
  vBreak  :   logic;
  vALen   :   int;
  vNeu    :   logic;
end;
begin
  // Ankerfunktion
  if ( RunAFX( 'Excel.Import.' + CnvAI( aDatei ), CnvAI( CnvIL( aNeuanlage ) ) + aName ) != 0 ) then
    RETURN true;

  GV.Alpha.01     # '';
  Gv.Alpha.02     # '';
  GV.Int.01       # 0;
  Gv.Int.02       # 0;

  // 2022-08-22 AH
  if (aDatei=833) and (Set.LyseErweitertYN) then
    aDatei # 231;

  vFile # FSIOpen(aName, _FsiStdRead );
  if (vFile<=0) then begin
    Gv.Alpha.01     # Translate('Datei nicht lesbar:')+' '+aName;
    RETURN false;
  end;

  vMax # FsiSize(vFile);

  // Öffnen des Dialoges
  if (gUsergroup<>'SOA_SERVER') then
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (vDia != 0) then begin
    vHdl # Winsearch(vDia,'Label1');
    vHdl->wpcaption # Translate('Lese aus Exceldatei')+' '+aName;
    $Progress->wpProgressPos # 0;
    $Progress->wpProgressMax # vMax;
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);
  end;



  vBuf # RecBufCreate(aDatei);

  /* Dateinamen lesen */
  FSIMark(vFile, 10);
  FSIRead(vFile, vA);
//debug(vA);

  /* Überschrift lesen */
  FSIRead(vFile, vA);
  vA # Str_ReplaceAll(vA,'""',strchar(254));
  vA # Str_ReplaceAll(vA,strchar(254),'"');
//debug('übers:'+vA);

  vX # 1;
  WHILE (vA<>'') do begin
    vB # SplitteFeld(var vA);
//    Debug(vB+'<>'+vA);
    if (FldInfoByName(vB,_FldExists)=0) then begin
      FSIClose(vFile);
      Gv.Alpha.01     # StrCut(Translate('Feldname unbekannt:')+' '+vB, 1, 250);
      if (vDia<>0) then vDia->WinClose();
      RETURN false;
    end;
    vDatei # FldInfoByName(vB,_FldFilenumber);
    vTds   # FldInfoByName(vB,_FldSbrnumber);
    vFld   # FldInfoByName(vB,_Fldnumber);
    vFileArr[vX]  # vDatei;
    vTdsArr[vX]   # vTds;
    vFldArr[vX]   # vFld;
    inc(vX);
  END;

  // eindeutiger Schlüssel vorhanden?
  if (MainKeyIsGood(aDatei)=false) then begin
    FSIClose(vFile);
    // Rückgabe für alte Prozeduren
    Gv.Alpha.01     # Translate('SatzID fehlt!');
    if (vDia<>0) then vDia->WinClose();
    RETURN false;
  end;

  /* 2.Überschrift lesen */
  FSIRead(vFile, vA);

//  DTABegin();
  TRANSON;

  /* Satz lesen */
  vAnz # 0;
  FSIRead(vFile, vA);
  WHILE (vA<>'') and (vBreak=n) do begin

    if (vDia<>0) then begin
      $Progress->wpProgressPos # FsiSeek(vFile);
      vBreak # vDia->WinDialogResult() = _WinIdCancel;
    end;

    // 07.12.2012 AI
    RecBufClear(aDatei);

    vX # 1;
    vA # Str_ReplaceAll(vA,'""',strchar(254));
    vA # Str_ReplaceAll(vA,strchar(254),'"');
    inc(vAnz);
    WHILE (vA<>'') do begin

      vB # SplitteFeld(var vA);
//debug(cnvai(vFileArr[vX])+'/'+cnvai(vTdsArr[vX])+'/'+cnvai(vFldArr[vX]));
//debug(cnvai(vx)+':'+vB+'<>'+vA);
      if (FldInfo(vFileArr[vX], vTdsArr[vX],vFldArr[vX],_FldType)=_TypeAlpha) then begin
        vALen # FldInfo(vFileArr[vX], vTdsArr[vX],vFldArr[vX],_FldLen);
        FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX], StrCut(vB,1,vALen));
        end
      else if (vB<>'') then begin
        case FldInfo(vFileArr[vX], vTdsArr[vX],vFldArr[vX],_FldType) of
          _TypeDate   : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvda(vB));
          _Typeword   : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvia(vB));
          _typeint    : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvia(vB));
//          _Typefloat  : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvfa(vB,_fmtnumpoint));
          _Typefloat  : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvfa(vB));
          _typelogic  : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],(vB='Y'));
          _TypeTime   : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvta(vB));
        end;
      end;
      inc(vX);    // nächstes Feld
    END;


    // Datensatz anlegen/replacen
    RecBufCopy(aDatei,vBuf);

    Erx # _rOK;
    if (aNeuAnlage=n) then begin
      Erx # RecRead(aDatei,1,_recTest);
    end;

    if (aNeuAnlage) or (Erx>=_rNoKey) then begin
      vNeu # true;
      // Ankerfunktion
      if (RunAFX( 'Excel.Import.Inner.' + CnvAI( aDatei ), '')<>0) then begin
        if (AfxRes<>_rOK) then begin
//          DtaRollback(n);
          TRANSBRK;
          FSIClose(vFile);
          if (vDia<>0) then vDia->WinClose();
          RETURN false;
        end;
      end;

      vErg # RekInsert(aDatei,0,'AUTO');
      if (vErg<>_rOK) then begin
        //DtaRollback(n);
        TRANSBRK;
        FSIClose(vFile);
        // Rückgabe für alte Prozeduren
        Gv.Alpha.01     # Translate('Satz existiert bereits!');
        if (vDia<>0) then vDia->WinClose();
        RETURN false;
      end;
    end
    else begin
      vNeu # false;
      vErg # RecRead(aDatei,1,_recLock);
      vID # RecInfo(aDatei,_RecID);
      RecBufCopy(vBuf,aDatei);
      RecInfo(aDatei,_RecSetID,vID);

      // Ankerfunktion
      if (RunAFX( 'Excel.Import.Inner.' + CnvAI( aDatei ), '')<>0) then begin
        if (AfxRes<>_rOK) then begin
          //DtaRollback(n);
          TRANSBRK;
          FSIClose(vFile);
          if (vDia<>0) then vDia->WinClose();
          RETURN false;
        end;
      end;

      vErg # RekReplace(aDatei,_RecUnlock,'AUTO');
      if (vErg<>_rOK) then begin
        //DtaRollback(n);
        TRANSBRK;
        FSIClose(vFile);
        // Rückgabe für alte Prozeduren
        Gv.Alpha.01     # Translate('Satz existiert bereits!');
        if (vDia<>0) then vDia->WinClose();
        RETURN false;
      end;
    end;
    
    // 18.05.2021 AH
    if (aDatei=100) then begin
      // allen verbundenen Daten anlegen:
      Erx # Adr_Data:RecSave(false, true);  //  ÄNDERN + IMPORT
      /*
      if (vErg<>_rOK) then begin
        //DtaRollback(n);
        TRANSBRK;
        FSIClose(vFile);
        // Rückgabe für alte Prozeduren
        Gv.Alpha.01     # Translate('Adressebhängigkeiten nicht speicherbar!');
        if (vDia<>0) then vDia->WinClose();
        RETURN false;
      end;
      */
    end;

    FSIRead(vFile, vA);   // nächste Zeile
  END;

  //DTACommit();
  TRANSOFF;
  RecBufDestroy(vBuf);
  FSIClose(vFile);

  if (vDia<>0) then vDia->WinClose();

  // alles wunderbar...
  GV.Alpha.01     # '';
  Gv.Int.01 # vAnz;
  RETURN true;
end;


//========================================================================
//  sub RemoveSpecialChars(var aText : alpha)
//      Entfernt nicht gewünschte Zeichen aus dem zu exportierenden
//      alphanumerischen Wert
//========================================================================
sub RemoveSpecialChars(var aText : alpha)
begin
  aText # Str_ReplaceAll(aText, Strchar(10), '');
  aText # Str_ReplaceAll(aText, Strchar(13), '');
end;

//========================================================================
sub KombiListText(
  var aList   : int;
  aName       : alpha;
  aTextname   : alpha;
  ) : logic;
local begin
  vTyp  : int;
  vA    : alpha;
end;
begin
  if (aList=0) then aList # CteOpen(_cteList);
  vTyp # _typealpha;
  aList->CteInsertItem(aName, 999999, aTextName);
  RETURN true;
end;


//========================================================================
sub KombiListFeld(
  var aList   : int;
  aName       : alpha;
  opt aDatei  : int;
  opt aTds    : int;
  opt aFld    : int;
  opt aHeader : alpha;    // 2023-04-28 AH
  ) : logic;
local begin
  vTyp  : int;
  vA    : alpha;
end;
begin
  if (aName<>'') then begin
    if (FldInfoByName(aName, _FldExists)<=0) then RETURN false;
    aDatei # FldInfoByName(aName, _FldFileNumber);
    aTds # FldInfoByName(aName, _FldSbrNumber);
    aFld # FldInfoByName(aName, _FldNumber);
  end
  else begin
    if (FldInfo(aDatei, aTds, aFld, _FldExists)<=0) then RETURN false;
    aName # FldName(aDatei, aTds, aFld);
  end;

  if (aList=0) then aList # CteOpen(_cteList);
  
  vTyp # FldInfo(aDatei, aTds, aFld, _FldType);

  if (vTyp=_Typealpha) then vA # aint(FldInfo(aDatei, aTds, aFld, _FldLen));

  if (aHeader<>'') then aName # aName+'|'+aHeader;
  aList->CteInsertItem(aName, vTyp, vA);
  
  RETURN true;
end;


//========================================================================
sub KombiListClose(var aList   : int);
begin
  if (aList=0) then RETURN;
  Cteclear(aList, y);
  Cteclose(aList);;
  aList # 0;
end;


//========================================================================
sub KombiListDatei(
  var aList   : int;
  aDatei      : int;
  opt aTds    : int;
  ) : logic;
local begin
  vTds    : int;
  vFld    : int;
  vMaxTds : int;
  vMaxFld : int;
end;
begin

  vMaxTds # FileInfo(aDatei,_FileSbrCount);
  FOR vTds # 1
  LOOP inc(vTds)
  WHILE (vTds<=vMaxTds) do begin
    if (aTds<>0) and (aTds<>vTds) then CYCLE;
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1
    LOOP inc(vFld)
    WHILE (vFld<=vMaxFld) do begin
      KombiListFeld(var aList, '', aDatei, vTds, vFld);
    END;
  END;
  
  RETURN true;
end;


//========================================================================
//
//========================================================================
Sub SchreibeKombi(
  aName     : alpha(1000);
  aList     : int;
  aFileName : alpha(8096);
  aMax      : int;
  aProc     : alpha;
) : Alpha;;
local begin
  Erx     : int;
  vFile   : int;
  vFirst  : logic;
  vItem   : int;
  vOut    : alpha(254);
  vA      : alpha(254);
  vDia    : int;
  vHdl    : int;
  vMaxCol : int;
  vCol    : int;
  vAnz    : int;
  vBreak  : logic;
  vTxt    : int;
  vTxtRtf : int;
  vMem    : handle;
  vName   : alpha;
  vLF     : alpha;
end;
begin
  // Öffnen des Dialoges
  if (gUsergroup<>'SOA_SERVER') then
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (vDia != 0) then begin
    vHdl # Winsearch(vDia,'Label1');
    vHdl->wpcaption # Translate('Schreibe in Exceldatei')+' '+aName;
    $Progress->wpProgressPos # 0;
    $Progress->wpProgressMax # aMax;
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);
  end;

  vFile # FSIOpen(aFileName, _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    if (vDia<>0) then vDia->WinClose();
    RETURN Translate('Datei nicht beschreibbar:')+' '+aFileName;
  end;

  vMaxCol # aList->CteInfo(_CteCount);
  
  // Dateinamen schreiben
  FOR vCol # 1
  LOOP inc(vCol)
  WHILE (vCol<=vMaxCol) do begin
    if (vCol=1) then begin
      vOut # '"'; FSIWrite(vFile,vOut);
      Write(aName);
      vOut # '"'; FSIWrite(vFile,vOut);
    end
    else begin
      Write('');
    end;
  END;
  Write(cSatzEnde);


  // Überschrift schreiben
  vFirst # y;
  FOR vItem # aList->CteRead(_CteFirst);
  LOOP vItem # aList->CteRead(_CteNext, vItem);
  WHILE (vItem > 0) do begin
    if (vFirst=n) then Write(cFeldEnde)
    else vFirst # n;
    vA # vItem->spName;
    if (StrFind(vA,'|',0)>0) then vA # Str_token(vA,'|',2);
    vOut # '"'; FSIWrite(vFile,vOut);
    Write(vA);
    vOut # '"'; FSIWrite(vFile,vOut);
  END;
  Write(cSatzEnde);


  // 2.Überschrift schreiben
  vFirst # y;
  FOR vItem # aList->CteRead(_CteFirst);
  LOOP vItem # aList->CteRead(_CteNext, vItem);
  WHILE (vItem > 0) do begin
    if (vFirst=n) then Write(cFeldEnde)
    else vFirst # n;
    case vItem->spID of
      999999      : Write(Translate('Text'));
      _TypeAlpha  : Write(Translate('Alpha')+' '+vItem->spCustom);
      _TypeDate   : Write(Translate('Datum'));
      _Typeword   : Write(Translate('Ganzzahl kurz'));
      _typeint    : Write(Translate('Ganzzahl lang'));
      _Typefloat  : Write(Translate('Numerisch'));
      _typelogic  : Write(Translate('Logisch'));
      _TypeTime   : Write(Translate('Zeit'));
    end;
  END;
  Write(cSatzEnde);


  // Daten loopen...
  vAnz # 0;

  FOR Erx # Call(aProc, _recFirst)
  LOOP Erx # Call(aProc, _recNext)
  // Daten loopen...
  WHILE (Erx<=_rLocked) and (vBreak=n) do begin
    vAnz # vAnz + 1;
    if (vDia<>0) then begin
      $Progress->wpProgressPos # vAnz;
      vBreak # vDia->WinDialogResult() = _WinIdCancel;
    end;

    vFirst # y;
    // Inhalte schreiben
    FOR vItem # aList->CteRead(_CteFirst);
    LOOP vItem # aList->CteRead(_CteNext, vItem);
    WHILE (vItem > 0) do begin
      if (vFirst=n) then Write(cFeldEnde)
      else vFirst # n;
//debugx(vItem->spname);

      vName # vItem->spname;
      if (StrFind(vName,'|',0)>0) then vName # Str_token(vName,'|',1);

      case (vItem->spID) of
        999999 : begin
          vA # Call(vItem->spcustom);
          if (vA<>'') then begin
            vTxt # TextOpen(160);    // Ascitextpuffer
            if (StrCut(vA,1,4)=^'RTF:') then begin
              vTxtRtf # TextOpen(160);
              vA    # StrCut(vA,5,55);
              Erx # Textread(vTxtRtf, vA, 0);
              if (erx<=_rLocked) then begin
                Lib_Texte:Rtf2Txt(vTxtRtf,vTxt);
              end;
              TextClose(vTxtRtf);
            end
            else begin
              ERX # Textread(vTxt, vA, 0);
              if (erx>_rLocked) then TextClear(vTxt);
            end;
            TextSearch(vTxt, 1,1,_TextSearchCI, '"' , '""');
//            TextSearch(vTxt, 1,1,_TextSearchCI, StrChar(10) , 'xxx');
//textwrite(vTxt, 'd:\debug\aaa.txt', _textExtern);
//            TextSearch(vTxt, 1,1,_TextSearchCI, StrChar(1) , StrChar(10));
            vOut # '"'; FSIWrite(vFile,vOut);
            vMem # MemAllocate(_MemAutoSize);
            vMem->spCharset # _CharsetWCP_1252;
            vLF # strchar(10);
            if (Set.Installname='BSC') then vLF # '/';
            Lib_texte:WriteToMem(vTxt, vMem, vLF);
            FsiWriteMem(vFile, vMem, 1, vMem->spLen);
            vMem->memfree();
//          RemoveSpecialChars(var vA);    // ST 2013-07-10: "weichen" Umbrüche herausfiltern
            //Write(vA);)
            vOut # '"'; FSIWrite(vFile,vOut);
          end;
        end;

        _TypeAlpha : begin
          vA # FldAlphaByName(vName);
          vOut # '"'; FSIWrite(vFile,vOut);
          RemoveSpecialChars(var vA);    // ST 2013-07-10: "weichen" Umbrüche herausfiltern
          Write(va);
          vOut # '"'; FSIWrite(vFile,vOut);
          end;

        _TypeDate : Write(cnvad(FldDateByName(vname)));

        _TypeWord : Write(cnvai(FldwordByName(vName)));

        _Typeint :  Write(cnvai(FldIntByName(vName)));

        _TypeFloat : begin
//                      Write(cnvaf(fldfloat(aDatei,vTds,vFld),_FmtNumPoint|_FmtNumNoGroup));
                    Write(cnvaf(fldfloatByName(vName),_FmtNumNoGroup,0,5));    // 13.09.2016 AH: IMMER 5 NACHKOMMASTELLEN
                  end;

        _typelogic : if (fldlogicByName(vName)) then
                      Write('Y')
                    else
                      Write('N');

        _typetime : Write(cnvat(FldtimeByName(vName),_fmttimeseconds));
      end;

    END;  // Columns
    Write(cSatzEnde);

  END;  // Daten
  Write(cSatzEnde);

  FSIClose(vFile);

  if (vDia<>0) then vDia->WinClose();

  // alles wunderbar...
  RETURN '';

end;


//========================================================================
//  LiesDatei
//
//========================================================================
sub LiesKombi(
  aName     : alpha;
  aFileName : alpha(4000);
  aProc     : alpha;
  opt aReadEmpty  : logic) : Alpha;
local begin
  vMaxTds :   int;
  vMaxFld :   int;
  vFile   :   int;
  vTds    :   int;
  vFld    :   int;
  vDatei  :   int;
  vFirst  :   logic;
  vHdl    :   int;

  vOut    :   alpha;
  vAnz    :   int;
  vX      :   int;
  vA      :   alpha(8096);
  vB      :   alphA(8096);
  vID     :   int;

  vMax    :   int;
  vDia    :   int;
  vBreak  :   logic;
  vALen   :   int;
end;
begin

  vFile # FSIOpen(aFileName, _FsiStdRead );
  if (vFile<=0) then begin
    RETURN Translate('Datei nicht lesbar:')+' '+aFileName;
  end;

  vMax # FsiSize(vFile);

  // Öffnen des Dialoges
  if (gUsergroup<>'SOA_SERVER') then
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (vDia != 0) then begin
    vHdl # Winsearch(vDia,'Label1');
    vHdl->wpcaption # Translate('Lese aus Exceldatei')+' '+aFileName;
    $Progress->wpProgressPos # 0;
    $Progress->wpProgressMax # vMax;
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);
  end;


  // Dateinamen lesen
  FSIMark(vFile, 10);
  FSIRead(vFile, vA);
  vA # Str_ReplaceAll(vA,'""',strchar(254));
  vA # Str_ReplaceAll(vA,strchar(254),'"');
  vB # SplitteFeld(var vA);
  if (vB<>aName) then begin
    FSIClose(vFile);
    if (vDia<>0) then vDia->WinClose();
    RETURN Translate('Falscher Dateiinhalt');
  end;

//debugx(vA);

  // Überschrift lesen
  FSIRead(vFile, vA);
  vA # Str_ReplaceAll(vA,'""',strchar(254));
  vA # Str_ReplaceAll(vA,strchar(254),'"');
//debugx('übers:'+vA);

  vX # 1;
  WHILE (vA<>'') do begin
    vB # SplitteFeld(var vA);
//    Debug(vB+'<>'+vA);
    if (FldInfoByName(vB,_FldExists)=0) then begin
      FSIClose(vFile);
      if (vDia<>0) then vDia->WinClose();
      RETURN StrCut(Translate('Feldname unbekannt:')+' '+vB, 1, 250);
    end;
    vDatei # FldInfoByName(vB,_FldFilenumber);
    vTds   # FldInfoByName(vB,_FldSbrnumber);
    vFld   # FldInfoByName(vB,_Fldnumber);
    vFileArr[vX]  # vDatei;
    vTdsArr[vX]   # vTds;
    vFldArr[vX]   # vFld;
    inc(vX);
  END;

  // 2.Überschrift lesen
  FSIRead(vFile, vA);

  //DTABegin();
  TRANSON;

  // Satz lesen
  vAnz # 0;
  FSIRead(vFile, vA);
  WHILE (vA<>'') and (vBreak=n) do begin

    if (vDia<>0) then begin
      $Progress->wpProgressPos # FsiSeek(vFile);
      vBreak # vDia->WinDialogResult() = _WinIdCancel;
    end;

    vX # 1;
    vA # Str_ReplaceAll(vA,'""',strchar(254));
    vA # Str_ReplaceAll(vA,strchar(254),'"');
    inc(vAnz);
    WHILE (vA<>'') do begin

      vB # SplitteFeld(var vA);
//debug(cnvai(vFileArr[vX])+'/'+cnvai(vTdsArr[vX])+'/'+cnvai(vFldArr[vX]));
//debug(cnvai(vx)+':'+vB+'<>'+vA);
      if (FldInfo(vFileArr[vX], vTdsArr[vX],vFldArr[vX],_FldType)=_TypeAlpha) then begin
        vALen # FldInfo(vFileArr[vX], vTdsArr[vX],vFldArr[vX],_FldLen);
        FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX], StrCut(vB,1,vALen));
        end
      else if (vB<>'') or (aReadEmpty) then begin
        case FldInfo(vFileArr[vX], vTdsArr[vX],vFldArr[vX],_FldType) of
          _TypeDate   : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvda(vB));
          _Typeword   : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvia(vB));
          _typeint    : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvia(vB));
//          _Typefloat  : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvfa(vB,_fmtnumpoint));
          _Typefloat  : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvfa(vB));
          _typelogic  : FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],(vB='Y'));
          _TypeTime   : if (vB<>'') then
              FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],cnvta(vB));
            else
              FldDef(vFileArr[vX], vTdsArr[vX],vFldArr[vX],0:0);
        end;
      end;
      inc(vX);    // nächstes Feld
    END;


    if (Call(aProc)=false) then begin
      //DtaRollback(n);
      TRANSBRK;
      FSIClose(vFile);
      if (vDia<>0) then vDia->WinClose();
      RETURN GV.Alpha.01;
    end;

    FSIRead(vFile, vA);   // nächste Zeile
  END;

  //DTACommit();
  TRANSOFF;
  FSIClose(vFile);

  if (vDia<>0) then vDia->WinClose();

  // alles wunderbar...
  RETURN '';
end;


//========================================================================
//  SchreibeDatei
//
//========================================================================
sub SchreibeDatei(
  aDatei      : int;
  aName       : alpha(8096);
  aNurMarke   : logic;
  opt aMax    : int;
  opt aAppend : logic;
  opt aNur1er : logic;
  opt aSel    : int) : logic;
local begin
  Erx     : int;
  vMaxTds :   int;
  vMaxFld :   int;
  vFile   :   int;
  vTds    :   int;
  vFld    :   int;
  vFirst  :   logic;
  vHdl    :   int;

  vOut    :   alpha(1254);
  vAnz    :   int;
  vX      :   int;
  vA      :   alpha(1254);

  vSel    :   int;
  vMax    :   int;
  vDia    :   int;
  vBreak  :   logic;

  vItem   :   int;
  vMFile  :   int;
  vMID    :   int;
end;
begin
  // Ankerfunktion
  if ( RunAFX( 'Excel.Export.' + CnvAI( aDatei ), CnvAI( CnvIL( aNurMarke ) ) + aName ) != 0 ) then
    RETURN true;

  vMax # RecInfo(aDatei,_recCount);
/*
  if (aDatei=459) then begin
    vSel # gZLList->wpdbselection;
    if (vSel<>0) then begin
      vMax # RecInfo(aDatei, _RecCount,vSel);
    end;
  end;
*/
  vSel # aSel;

  if (aNurMarke) then
    vMax # Lib_Mark:Count(aDatei);

  // Öffnen des Dialoges
  if (gUsergroup<>'SOA_SERVER') then
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (vDia != 0) then begin
    vHdl # Winsearch(vDia,'Label1');
    vHdl->wpcaption # Translate('Schreibe in Exceldatei')+' '+aName;
    $Progress->wpProgressPos # 0;
    $Progress->wpProgressMax # vMax;
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);
  end;


  Gv.Alpha.01 # '';
  Gv.Alpha.02 # '';
  Gv.Int.01 # 0;
  Gv.Int.02 # 0;

  if (aAppend) then
    vFile # FSIOpen(aName, _FsiAcsRW | _FsiCreate | _FsiAppend);
  else
    vFile # FSIOpen(aName, _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    if (vDia<>0) then vDia->WinClose();
    Gv.Alpha.01     # Translate('Datei nicht beschreibbar:')+' '+aName;
    RETURN false;
  end;

  vMaxTds # FileInfo(aDatei,_FileSbrCount);

  vAnz # 0;

  /* Dateinamen schreiben */
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      inc(vAnz);
      if (vAnz=1) then begin
        vOut # '"'; FSIWrite(vFile,vOut);
        Write(Translate('Datei')+' '+cnvai(aDatei)+' '+Filename(aDatei));
        vOut # '"'; FSIWrite(vFile,vOut);
        end
      else begin
        Write('');
      end;
    END;
  END;

  Write(cSatzEnde);


  /* Überschrift schreiben */
  vFirst # y;
  vMaxTds # FileInfo(aDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      if (vFirst=n) then Write(cFeldEnde);
        vFirst # n;
        vA # FldName(aDatei,vTds,vFld);
        vOut # '"'; FSIWrite(vFile,vOut);
        Write(vA);
        vOut # '"'; FSIWrite(vFile,vOut);

    END;
  END;
  Write(cSatzEnde);


  /* 2.Überschrift schreiben */
  vFirst # y;
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      if (vFirst=n) then Write(cFeldEnde);
      vFirst # n;
      case FldInfo(aDatei,vTds,vFld,_FldType) of
        _TypeAlpha  : Write(Translate('Alpha')+' '+cnvai(FldInfo(aDatei,vTds,vFld,_FldLen)) );
        _TypeDate   : Write(Translate('Datum'));
        _Typeword   : Write(Translate('Ganzzahl kurz'));
        _typeint    : Write(Translate('Ganzzahl lang'));
        _Typefloat  : Write(Translate('Numerisch'));
        _typelogic  : Write(Translate('Logisch'));
        _TypeTime   : Write(Translate('Zeit'));
        end;
    END;
  END;
  Write(cSatzEnde);


  vAnz # 0;

  if (aNur1er) then begin
    Erx # RecRead(aDatei,1,0);
  end
  if (aNurMarke=false) then begin
    if (vSel<>0) then Erx # RecRead(aDatei,vSel,_recFirst)
    else Erx # RecRead(aDatei,1,_recFirst);
    vItem # 1;

    // 2022-09-26 AH    Proj. 2434/12
    if (aDatei=860) then begin
      if (gZLList<>0) then begin
        vSel # gZLList->wpdbselection;
        if (vSel<>0) then Erx # RecRead(aDatei,vSel,_recFirst)
      end;
    end;

  end
  else begin
    // 1. Markierung finden...
    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile<>aDatei) then begin
        vItem # gMarkList->CteRead(_CteNext,vItem);
        CYCLE;
      end;
      Erx # RecRead(aDatei,0,0,vMID);          // Satz holen
      BREAK;
    END;
  end;


  // Daten loopen...
  WHILE (vItem>0) and (Erx=_rOK) and (vBreak=n) and ((aMax=0) or (vAnz<=aMax)) do begin

    vAnz # vAnz + 1;

    if (vDia<>0) then begin
      $Progress->wpProgressPos # vAnz;
      vBreak # vDia->WinDialogResult() = _WinIdCancel;
    end;

    vFirst # y;
    /* Inhalte schreiben */
    vMaxTds # FileInfo(aDatei,_FileSbrCount);
    FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
      vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
      FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
        if (vFirst=n) then Write(cFeldEnde);
        vFirst # n;

        case FldInfo(aDatei,vTds,vFld,_FldType) of

          _TypeAlpha : begin
            vA # FldAlpha(adatei,vTds,vFld);
            vOut # '"'; FSIWrite(vFile,vOut);

            RemoveSpecialChars(var vA);    // ST 2013-07-10: "weichen" Umbrüche herausfiltern
            Write(va);
            vOut # '"'; FSIWrite(vFile,vOut);
            end;

          _TypeDate : Write(cnvad(FldDate(aDatei,vTds,vFld)));

          _TypeWord : Write(cnvai(Fldword(aDatei,vTds,vFld)));

          _Typeint :  Write(cnvai(FldInt(aDatei,vTds,vFld)));

          _TypeFloat : begin
//                      Write(cnvaf(fldfloat(aDatei,vTds,vFld),_FmtNumPoint|_FmtNumNoGroup));
                      Write(cnvaf(fldfloat(aDatei,vTds,vFld),_FmtNumNoGroup,0,5));    // 13.09.2016 AH: IMMER 5 NACHKOMMASTELLEN
                    end;

          _typelogic : if (fldlogic(aDatei,vTds,vFld)) then
                        Write('Y')
                      else
                        Write('N');

          _typetime : Write(cnvat(Fldtime(aDatei,vTds,vFld),_fmttimeseconds));
        end;

      END;
    END;
    Write(cSatzEnde);

    if (aNurMarke=false) then begin
      if (vSel<>0) then Erx # RecRead(aDatei,vSel,_recNext)
      else Erx # RecRead(aDatei,1,_recNext);
    end
    else begin
      // nächste Markierung
      vItem # gMarkList->CteRead(_CteNext,vItem);
      WHILE (vItem > 0) do begin
        Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
        if (vMFile<>aDatei) then begin
          vItem # gMarkList->CteRead(_CteNext,vItem);
          CYCLE;
        end;
        Erx # RecRead(aDatei,0,0,vMID);          // Satz holen
        BREAK;
      END;
    end;

    if (aNur1Er) then BREAK;
  END;  // Daten loopen...

  FSIClose(vFile);

  if (vDia<>0) then vDia->WinClose();

  // alles wunderbar...
  GV.Alpha.01     # '';
  Gv.Int.01       # vAnz;
  RETURN true;

end;


//========================================================================
//  SchreibeAuszug
//
//========================================================================
sub SchreibeAuszug(aDatei : int; aName : alpha; aNurMarke : logic; aList : int) : logic;
local begin
  Erx     : int;
  vFile   :   int;
  vFirst  :   logic;
  vHdl    :   int;

  vOut    :   alpha(254);
  vAnz    :   int;
  vX      :   int;
  vA      :   alpha(254);

  vSel    :   int;
  vMax    :   int;
  vDia    :   int;
  vBreak  :   logic;

  vItem   :   int;
  vMFile  :   int;
  vMID    :   int;

  vLItem  :   int;
end;
begin
  // Ankerfunktion
  if ( RunAFX( 'Excel.Export.' + CnvAI( aDatei ), CnvAI( CnvIL( aNurMarke ) ) + aName ) != 0 ) then
    RETURN true;

  vMax # RecInfo(aDatei,_recCount);

  // Öffnen des Dialoges
  if (gUsergroup<>'SOA_SERVER') then
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (vDia != 0) then begin
    vHdl # Winsearch(vDia,'Label1');
    vHdl->wpcaption # Translate('Schreibe in Exceldatei')+' '+aName;
    $Progress->wpProgressPos # 0;
    $Progress->wpProgressMax # vMax;
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);
  end;


  Gv.Alpha.01 # '';
  Gv.Alpha.02 # '';
  Gv.Int.01 # 0;
  Gv.Int.02 # 0;

  vFile # FSIOpen(aName, _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    if (vDia<>0) then vDia->WinClose();
    Gv.Alpha.01     # Translate('Datei nicht beschreibbar:')+' '+aName;
    RETURN false;
  end;

  vAnz # 0;

  /* Dateinamen schreiben */

  vLItem # aList->CteRead(_CteFirst);
  WHILE (vLItem > 0) do begin
    inc(vAnz);
    if (vAnz=1) then begin
      vOut # '"'; FSIWrite(vFile,vOut);
      Write(Translate('Datei')+' '+cnvai(aDatei)+' '+Filename(aDatei));
      vOut # '"'; FSIWrite(vFile,vOut);
      end
    else begin
      Write('');
    end;
    vLItem # aList->CteRead(_CteNext, vLItem);
  END;


  Write(cSatzEnde);


  /* Überschrift schreiben */
  vFirst # y;
  vLItem # aList->CteRead(_CteFirst);
  WHILE (vLItem > 0) do begin

    if (vFirst=n) then Write(cFeldEnde);
    vFirst # n;
    vA # vLItem->spcustom;
    vOut # '"'; FSIWrite(vFile,vOut);
    Write(vA);
    vOut # '"'; FSIWrite(vFile,vOut);

    vLItem # aList->CteRead(_CteNext, vLItem);
  END;
  Write(cSatzEnde);


  /* 2.Überschrift schreiben */
  vFirst # y;
  vLItem # aList->CteRead(_CteFirst);
  WHILE (vLItem > 0) do begin

    vA # vLItem->spcustom;

    if (vFirst=n) then Write(cFeldEnde);
    vFirst # n;
    //case FldInfo(aDatei,vTds,vFld,_FldType) of
    case FldInfoByName(vA,_FldType) of
      _TypeAlpha  : Write(Translate('Alpha')+' '+cnvai(FldInfobyname(vA ,_FldLen)) );
      _TypeDate   : Write(Translate('Datum'));
      _Typeword   : Write(Translate('Ganzzahl kurz'));
      _typeint    : Write(Translate('Ganzzahl lang'));
      _Typefloat  : Write(Translate('Numerisch'));
      _typelogic  : Write(Translate('Logisch'));
      _TypeTime   : Write(Translate('Zeit'));
    end;

    vLItem # aList->CteRead(_CteNext, vLItem);
  END;
  Write(cSatzEnde);


  vAnz # 0;

  if (aNurMarke=false) then begin
    if (vSel<>0) then Erx # RecRead(aDatei,vSel,_recFirst)
    else Erx # RecRead(aDatei,1,_recFirst);
    vItem # 1;
    end
  else begin
    // 1. Markierung finden...
    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile<>aDatei) then begin
        vItem # gMarkList->CteRead(_CteNext,vItem);
        CYCLE;
      end;
      Erx # RecRead(aDatei,0,0,vMID);          // Satz holen
      BREAK;
    END;
  end;


  // Daten loopen...
  WHILE (vItem>0) and (Erx=_rOK) and (vBreak=n) do begin

    vAnz # vAnz + 1;

    if (vDia<>0) then begin
      $Progress->wpProgressPos # vAnz;
      vBreak # vDia->WinDialogResult() = _WinIdCancel;
    end;

    vFirst # y;
    /* Inhalte schreiben */
    vLItem # aList->CteRead(_CteFirst);
    WHILE (vLItem > 0) do begin

      vA # vLItem->spcustom;

        if (vFirst=n) then Write(cFeldEnde);
        vFirst # n;

        case FldInfoByName(vA,_FldType) of

          _TypeAlpha : begin
            vA # FldAlphabyName(vA);
            vOut # '"'; FSIWrite(vFile,vOut);
            Write(va);
            vOut # '"'; FSIWrite(vFile,vOut);
            end;

          _TypeDate : Write(cnvad(FldDateByName(vA)));

          _TypeWord : Write(cnvai(FldwordByName(vA)));

          _Typeint :  Write(cnvai(FldIntByName(vA)));

          _TypeFloat : begin
//                      Write(cnvaf(fldfloatByName(vA),_FmtNumPoint|_FmtNumNoGroup));
                      Write(cnvaf(fldfloatByName(vA),_FmtNumNoGroup));
                    end;

          _typelogic : if (fldlogicByName(vA)) then
                        Write('Y')
                      else
                        Write('N');

          _typetime : Write(cnvat(FldtimeByName(vA),_fmttimeseconds));
        end;

      vLItem # aList->CteRead(_CteNext, vLItem);
    END;
    Write(cSatzEnde);

    if (aNurMarke=false) then begin
      if (vSel<>0) then Erx # RecRead(aDatei,vSel,_recNext)
      else Erx # RecRead(aDatei,1,_recNext);
      end
    else begin
      // nächste Markierung
      vItem # gMarkList->CteRead(_CteNext,vItem);
      WHILE (vItem > 0) do begin
        Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
        if (vMFile<>aDatei) then begin
          vItem # gMarkList->CteRead(_CteNext,vItem);
          CYCLE;
        end;
        Erx # RecRead(aDatei,0,0,vMID);          // Satz holen
        BREAK;
      END;
    end;
  END;  // Daten loopen...

  FSIClose(vFile);

  if (vDia<>0) then vDia->WinClose();

  // alles wunderbar...
  aList->CteClear(true);
  aList->CteClose();
  GV.Alpha.01     # '';
  Gv.Int.01       # vAnz;
  RETURN true;

end;


//========================================================================
//  AddFld
//
//========================================================================
sub AddFld(aList : int; aName : alpha)
local begin
  vItem : int;
end;
begin
  vItem # CteOpen(_cteItem);
  vItem->spname   # cnvai( CteInfo(aList,_CTeCount));
  vItem->spcustom # aName;
  aList->CteInsert(vItem);
end;


//========================================================================
//  DataListToXML
//========================================================================
sub DataListToXML(
  aDL         : int;
  aName       : alpha(8096);
  aTitel      : alpha(8095);
) : logic
local begin
  vMax    : int;
  vFile   : int;
  vDia    : int;
  vAnz    : int;
  vCell   : int;
  vCol    : int;
  vHdl    : int;
  vMaxCol : int;
  vTyps   : int[200];
  vDecis  : int[200];
  vColHdl : int[200];
  vA      : alpha(4000);
  vI      : int;
  vF      : float;
  vTxt    : int;
  vStyle  : alpha;
  vType   : alpha;
end;
begin

  vMax # WinLstDatLineInfo(aDL, _WinLstDatInfoCount);

  vFile # FSIOpen(aName, _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    Gv.Alpha.01     # Translate('Datei nicht beschreibbar:')+' '+aName;
    RETURN false;
  end;
  FsiClose(vFile);

  // Grundlegende XML Daten übernehmen (Styles...)
  vHdl # TextOpen( 16 );
  TextRead( vHdl, 'XML.Table.Start.DL', 0 );
  TxtWrite( vHdl, aName, _textExtern );
  vHdl->TextClose();


  vFile # FSIOpen(aName, _FsiAcsRW | _FsiCreate | _FsiAppend);
  if (vFile<=0) then begin
    Gv.Alpha.01     # Translate('Datei nicht beschreibbar:')+' '+aName;
    RETURN false;
  end;
  
  aTitel # StrCnv(aTitel, _strUmlaut );
  FsiWrite( vFile, '<Worksheet ss:Name="' + StrCut( StrCnv(aTitel,_StrLetter), 1, 31 ) + '">' + cCRLF );
  FsiWrite( vFile, '<Table>' + cCRLF);

  FOR  vI # 1
  LOOP vI # vI + 1;
  WHILE ( vI < 99) DO
    FsiWrite(vFile, '<Column ss:Index="' + CnvAI( vI ) + '" ss:AutoFitWidth="1" ss:Width="100.00" />' + cCRLF );

  FsiWrite(vFile, '<Row>' + cCRLF);

  vI # 0;
  vStyle # '';
  vType  # 'String';
//vOP # aDL->wpOrderPass;
//aDL->wpOrderPass # _WinOrderCreate;
  vHdl # WinInfo(aDL,_Winfirst)
  FOR  vHdl # aDl->WinInfo(_WinFirst, 1)
  LOOP vHdl # vHdl->WinInfo(_WinNext, 1)
  WHILE (vHdl > 0) do begin
    inc(vMaxCol);
    if (vHdl->wpvisible=false) then CYCLE;

    vA # vHdl->wpCaption;
    vTyps[vMaxCol] # vHdl->wpClmType;
    if (vHdl->wpClmType=_TypeFloat) then
      vDecis[vMaxCol] # vHdl->wpFmtPostComma;

    vColHdl[vMaxCol] # Lib_guicom2:FindColumn(aDL, vHdl->wpname);
//debugx(vHdl->wpname+' '+aint(vMaxCol)+' : '+aint(vColHdl[vMaxCol]));
    
    inc(vI);
    FsiWrite(vFile, '<Cell ss:Index="' + CnvAI( vI ) + '"' + vStyle + '>' );
    FsiWrite(vFile, '<Data ss:Type="' + vType + '">' );
    vA # Lib_Strings:Strings_DOS2XML(vA);
    FsiWrite(vFile, vA);
    FsiWrite(vFile, '</Data>' );
    FsiWrite(vFile, '</Cell>' + cCRLF );
  END;
  FsiWrite(vFile, '</Row>' + cCRLF );

  // Positionen loopen...
  FOR vAnz # 1
  LOOP inc(vAnz)
  WHILE (vAnz<=vMax) do begin
    FsiWrite(vFile, '<Row>' + cCRLF);

    // Columns loopen...
    vCell # 0;
    FOR vCol # 1
    LOOP inc(vCol)
    WHILE (vCol<=vMaxCol) do begin
      if (vTyps[vCol]=0) then CYCLE;

      if (vColHdl[vCol]=0) then CYCLE;
      
      if (vTyps[vCol]=_Typeint) then begin
        WinLstCellGet(aDL, vI, vColHdl[vCol], vAnz);
        vType  # 'Number';
        if (vI<-999999999) then vI # -999999999
        else if (vI>999999999) then vI # 999999999;
        vA # aint(vI);
//        vText  # Str_ReplaceAll( vText, '.', '' );
//        vText  # Str_ReplaceAll( vText, ',', '.' );
        vStyle # '';
        vType  # 'Number';
      end
      else if (vTyps[vCol]=_Typefloat) then begin
        WinLstCellGet(aDL, vF, vColHdl[vCol], vAnz);
        vI # vDecis[vCol];
        if (vF<-999999999999.0) then vF # -999999999999.0
        else if (vF>999999999999.0) then vF # 999999999999.0;
        vA # anum(vF, vI);
        vA  # Str_ReplaceAll(vA, ',', '.' );
        if (vI=0) then
          vStyle # 'c16_num0'
        else if (vI=1) then
          vStyle # 'c16_num1'
        else if (vI=2) then
          vStyle # 'c16_num2'
        else
          vStyle # 'c16_num3';
        vType  # 'Number';
      end
      else begin
        WinLstCellGet(aDL, vA, vColHdl[vCol], vAnz);
        vStyle # '';
        vType  # 'String';
      end;

      if ( vStyle != '' ) then
        vStyle # ' ss:StyleID="' + vStyle + '"';

      inc(vCell);
      FsiWrite(vFile, '<Cell ss:Index="' + CnvAI( vCell ) + '"' + vStyle + '>' );
      FsiWrite(vFile, '<Data ss:Type="' + vType + '">' );
      vA # Lib_Strings:Strings_DOS2XML(vA);
      FsiWrite(vFile, vA);
      FsiWrite(vFile, '</Data>' );
      FsiWrite(vFile, '</Cell>' + cCRLF );

    END;
    FsiWrite(vFile, '</Row>' + cCRLF );
  END;


/***
  // Write header
  vHdl # WinInfo(aDL,_Winfirst)
  FOR  vHdl # aDl->WinInfo(_WinFirst, 1)//, _WinTypecol;
  LOOP vHdl # vHdl->WinInfo(_WinNext, 1)//, _WinTypeEdit)
  WHILE (vHdl > 0) do begin
    inc(vMaxCol);
    if (vHdl->wpvisible=false) then CYCLE;
    
    vTyps[vMaxCol] # vHdl->wpClmType;
    WRITE_TEXT(vHdl->wpCaption);
  END;
  WRITE_EOL();

  // Positionen loopen...
  FOR vAnz # 1
  LOOP inc(vAnz)
  WHILE (vAnz<=vMax) do begin

    // Columns loopen...
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=vMaxCol) do begin
      if (vTyps[vI]=0) then CYCLE;
      WinLstCellGet(aDL, vA, vI, vAnz);
      vA # '"'+vA+'"';
      WRITE_TEXT(vA);
    END;
    WRITE_EOL();
  END;
***/

  // XML Ausgabe: offene Tags schließen & Datei beenden
  FsiWrite(vFile, '</Table>' + cCRLF );
  FsiWrite(vFile, '</Worksheet>' + cCRLF );
  FsiWrite(vFile, '</Workbook>' + cCRLF );
  FsiClose(vFile);

  if (vDia<>0) then vDia->WinClose();

  // alles wunderbar...
  GV.Alpha.01     # '';
  Gv.Int.01       # vAnz;
  RETURN true;
  
end;


//========================================================================
//  KombiListTds
//========================================================================

//========================================================================
//  KombiListTds
//========================================================================
sub KombiListTds(
  var aList   : int;
  aDatei      : int;
  aTds        : int;
  opt aMaxFld : int)
local begin
  vMaxFld     : int;
  vFld        : int;
end;
begin
  vMaxFld # SbrInfo(aDatei,aTds,_SbrFldCount);
  if (aMaxFld>0) then vMaxFld # min(vMaxFld,aMaxFld);   // 2023-07-17 AH
  
  FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
    KombiListFeld(var aList, FldName(aDatei, aTds, vFld));
  END;
end;


/*========================================================================
2022-08-29  AH
========================================================================*/
sub ModKombiListFeld(
  var aList   : int;
  aName       : alpha;
  aName2      : alpha;
  ) : logic;
local begin
  vItem   : int;
  vDatei  : int;
  vTds    : int;
  vFld    : int;
  vTyp    : int;
  vA      : alpha;
end;
begin
  if (FldInfoByName(aName2, _FldExists)<=0) then RETURN false;

  vItem # aList->CteRead(_CteFirst | _CteSearchCI,0, aName);
  if (vItem=0) then begin
    RETURN false;
  end;
//    aList->CteDelete(vItem);

  vDatei # FldInfoByName(aName2, _FldFileNumber);
  vTds # FldInfoByName(aName2, _FldSbrNumber);
  vFld # FldInfoByName(aName2, _FldNumber);

  vTyp # FldInfo(vDatei, vTds, vFld, _FldType);
  if (vTyp=_Typealpha) then vA # aint(FldInfo(vDatei, vTds, vFld, _FldLen));

//  aList->CteInsertItem(aName, vTyp, vA);
  vItem->spname   # aName2;
  vItem->spid     # vTyp;
  vItem->spcustom # vA;

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================