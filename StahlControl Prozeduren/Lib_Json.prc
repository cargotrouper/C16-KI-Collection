@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Json
//                OHNE E_R_G
//  Info
//    Enthält Funktionen zum Verarbeiten JSON Datenstrukturen
//
//  31.07.2013  ST  Erstellung der Prozedur
//  17.03.2015  AH  "JSONtoPara" konvertiert keine Zeichensätze mehr
//  18.11.2015  AH  Umbau auf JSON als Handle statt Alpha
//  02.05.2019  ST  "sub JSON_toMemObj(...)" hinzugefügt
//  17.01.2020  ST  "sub JsonListToCteList(...)" hinzugefügt
//  17.02.2020  ST  Bugfix: JsonListToCteList
//  26.06.2020  ST  Bugfix: JsonListToCteList
//  09.02.2022  DS  LoadJSON
//  04.05.2022  DS  SaveJSON, LoadJsonFromAlpha, JsonCteToB64
//  2022-08-30  DS  JsonCteToB64 auf UTF8 als internes encoding des json string umgestellt, dann in b64 einwickeln
//  2022-08-31  DS  LoadJSON kann nun per boolean auch aus UTF8-encoded json files laden
//  2022-10-10  DS  LoadJSON kann nun per C16-style "Überladung" auch aus MemObj laden
//  2022-10-11  DS  C16-style "Unit Tests" in MAIN für LoadJSON hinzugefügt, quasi als Regressionstests bzgl. der letzten Änderungen
//  2023-01-20  DS  cteToFormattedJsonString, formatJsonString zum Formatieren von Json Daten hinzugefügt
//
//  Subprozeduren
//    sub OpenJSON() : handle;
//    sub LoadJSON(aFilename : alpha(256); opt isUTF8 : logic; opt aMemObj : handle) : handle;
//    sub SaveJSON(aCte : handle; aFilename : alpha(256)) : int;
//    sub LoadJsonFromAlpha(aJsonString : alpha(4096)) : handle;
//    cteToFormattedJsonString
//    formatJsonString
//    sub JsonCteToB64(aCte : handle) : alpha;
//    sub AddJSONInt(aJSON   : int; aName   : alpha; aWert   : int);
//    sub AddJSONFloat(aJSON   : int; aName   : alpha;  aWert   : float);
//    sub AddJSONAlpha(aJSON   : int;  aName   : alpha;  aWert   : alpha);
//    sub AddJSONDate(aJSON   : int;  aName   : alpha;  aWert   : date);
//    sub AddJSONBool(aJSON   : int;  aName   : alpha;  aWert   : bool);
//    sub CloseJSON(var aJSON : handle);
//    sub CreatePrintServerSettings() : alpha;
//    sub JsonListToCteList(aPara : alpha(4096)) : int
//
//    MAIN: Benutzungsbeispiele zum Testen
//
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
// OpenJSON()
//  Erstellt ein Json Objekt und gibt den Handle darauf zurück
//========================================================================
sub OpenJSON(opt aSQL : logic; opt aPure : logic) : handle;
local begin
  vJSON   : handle;
end;
begin
  // XML-Dokument als Cte-Knoten anlegen
  vJSON # CteOpen(_CteNode);
  vJSON->spID # _JSONNodeObject;
  if (aSQL) then
    vJSON->spCustom # 'SQL';
  RETURN vJSON;
end;

//========================================================================
// LoadJSON()
//  Lädt ein Json Objekt und gibt den Handle darauf zurück.
//  Das Laden geschieht entweder aus einer der Datei in aFilename oder dem
//  optionalen MemoryObject in aMemObj.
//  Wenn aFilename nichtleer ist, wird aMemObj ignoriert.
//========================================================================
sub LoadJSON(aFilename : alpha(256); opt isUTF8 : logic; opt aMemObj : handle) : handle;
local begin
  vCte : handle;
  vErr : int;
  // nur relevant falls isUTF8 = true:
  vUtf8File      : handle;  // um aFilename für Dekodierung in MemObj zu lesen
  vUtf8MemObj    : handle;  // MemObj für UTF8-kodierten Json String
  vUtf8MemObjDec : handle;  // MemObj für dekodierten (ANSI) Json String
end
begin

  if aFilename <> '' and aMemObj > 0 then
  begin
    DebugM(__PROCFUNC__ + ': Es kann nur ENTWEDER aFilename ODER aMemObj übergeben werden.' + cCrlf2 + 'ABBRUCH');
    return 0;
  end

  vCte # CteOpen(_CteNode);
  
  if isUTF8 then
  begin
  
    // Aufräumable
    vUtf8MemObjDec # Memallocate(_MemAutoSize);
  
    if aFilename <> '' then
    begin
      // Aufräumables für Dateibasierten Input:
      vUtf8File # FsiOpen(aFilename, _FsiStdRead | _FsiPure);
      vUtf8MemObj # Memallocate(_MemAutoSize);
      vUtf8MemObj->spcharset # _CharSetUTF8;
      FsiReadMem(vUtf8File, vUtf8MemObj, 1, FsiSize(vUtf8File));
      
      // Konversion des Datei-Inhalts von UTF8 zu C16
      vUtf8MemObj->MemCnv(vUtf8MemObjDec, _CharsetC16_1252);
    
    end
    else
    begin
      // Konversion des Memory-Objekts von UTF8 zu C16
      aMemObj->MemCnv(vUtf8MemObjDec, _CharsetC16_1252);
    end
    
    // Laden
    vErr # vCte->JsonLoad('', 0, vUtf8MemObjDec);
    
    // Aufräumen
    MemFree(vUtf8MemObjDec);
    if aFilename <> '' then
    begin
      FsiClose(vUtf8File);
      MemFree(vUtf8MemObj);
    end
    
  end
  else
  begin
    // Laden ohne Konversion
    if aFilename <> '' then
    begin
      vErr # vCte->JsonLoad(aFilename);
    end
    else
    begin
      vErr # vCte->JsonLoad('', 0, aMemObj);
    end
  end
  
  if (vErr = _ErrOK) then
  begin
    // Rückgabewert bleibt vCte, also Wurzel der Cte Struktur
  end else if (vErr > _ErrOK) then begin
    // Fehlerposition melden (weil > _ErrOK)
    WinDialogBox(0,
      'Fehler in LoadJSON()',
      'Fehler im JSON-String in der Datei "' + aFilename + '" oder Memory-Objekt "' + CnvAI(aMemObj) + '". FehlerPOSITION: ' + CnvAI(vErr) + '.',
      _WinIcoError,
      _WinDialogOK,
      1
    );
    vCte # -1;
  end else begin
    // Fehlercode melden (weil < _ErrOK)
    WinDialogBox(0,
      'Fehler in LoadJSON()',
      'Fehler beim Lesen von JSON-Datei "' + aFilename + '" oder Memory-Objekt "' + CnvAI(aMemObj) + '". FehlerCODE: ' + CnvAI(vErr) + '.',
      _WinIcoError,
      _WinDialogOK,
      1
    );
    vCte # -1;
  end
  
  // Wurzel der Cte Struktur zurückgeben, bzw. -1 bei Fehler, s.o.
  return vCte
  
end



//========================================================================
// SaveJSON()
//  Speichert Json Objekt aCte in Datei aFilename (in der optional in
//  aCharset angegebenen Kodierung) und gibt den von JsonSave erhaltenen
//  Fehlerwert zurück
//========================================================================
sub SaveJSON
(
  aCte         : handle;
  aFilename    : alpha(256);
  opt aCharset : int;
) : int;
local begin
  vReturn : int;
end
begin
  vReturn # aCte->JsonSave(aFilename, _JsonSaveDefault, 0, aCharset);
  return vReturn;
end



/*
========================================================================
2022-05-04  DS                                               2407/1

Nimmt json string in Form eines alphas entgegen und gibt handle auf
Wurzel einer Json Cte Struktur zurück
========================================================================
*/
sub LoadJsonFromAlpha
(
  aJsonString : alpha(4096);
) : handle
local begin
  vMemObj     : handle;  // zum Laden wird der String zunächst in ein MemObj kopiert
  vCte        : handle;  // Rückgabewert, Wurzel der geladenen Cte Json Struktur
end
begin

  //DebugM(aJsonString);
  
  vMemObj # MemAllocate(_MemAutoSize);
  vMemObj->MemWriteStr(1, aJsonString);
  
  vCte # CteOpen(_CteNode);
  vCte->JsonLoad('', 0, vMemObj);
  
  //SaveJSON(vCte, 'c:\debug\json_utf8.json', _CharsetUTF8);
     
  return vCte;
  
end



/*
========================================================================
2023-01-20  DS                                               2429/406

Nimmt handle auf Cte Json Struktur entgegen und gibt die darin enthaltenen
Daten als lesbar formatierten string zurück
========================================================================
*/
sub cteToFormattedJsonString(
  vCte : handle;
) : alpha
local begin
  vTempFilename         : alpha(512);
  vFormattedJsonString  : alpha(8192);
end
begin

  vTempFilename # Lib_FileIO:TempFilename('json');
  Lib_Json:SaveJSON(vCte, vTempFilename);
  Lib_FileIO:readTxtFile(vTempFilename, var vFormattedJsonString);
  FsiDelete(vTempFilename);
  
  return vFormattedJsonString;
end


/*
========================================================================
2023-01-20  DS                                               2429/406

Nimmt ggf. unformatierten one-liner Json String entgegen und gibt ihn
als lesbar formatierten string zurück.
========================================================================
*/
sub formatJsonString(
  vJsonString : alpha(8192);
) : alpha
local begin
  vCte                  : handle;
  vFormattedJsonString  : alpha(8192);
end
begin

  vCte # Lib_Json:LoadJsonFromAlpha(vJsonString);
  vFormattedJsonString # cteToFormattedJsonString(vCte);
  Lib_Json:CloseJSON(var vCte);
  
  return vFormattedJsonString;
end



/*
========================================================================
2022-05-04  DS                                               2407/1

Nimmt handle auf Wurzel einer Json Cte Struktur und konvertiert
sie in einen Base64 String, so dass dieser problemlos in weiteren
Jsons verschickt werden kann, z.B. für AppServer's request endpoint.

Der B64 String enthält den Json String in UTF8 encoding (!), da die
meisten WebAPIs das unterstützen.
========================================================================
*/
sub JsonCteToB64
(
  aCte : handle;  // Wurzel einer Cte Json Struktur
) : alpha
local begin
  vTempFileName : alpha(256);
  vTempFileText : alpha(4096);
  vB64          : alpha(4096);  // Rückgabewert
end
begin

  // Umweg über tempfile erforderlich:
  vTempFileName # Lib_FileIO:TempFilename('json');
  SaveJSON(aCte, vTempFileName, _CharsetUTF8);  // als UTF8 speichern
  Lib_FileIO:readTxtFile(vTempFileName, var vTempFileText, true);  // in pure mode einlesen, damit UTF8 erhalten bleibt
  
  //DebugM('in pure mode gelesenes UTF8 ohne Konversion für C16 (daher Umlaute etc. nicht zu ernst nehmen:' + cCrlf2 + vTempFileText);
  
  FsiDelete(vTempFileName);
  
  // Konversion:
  vB64 # StrCnv(vTempFileText, _StrToBase64);
    
  return vB64;
  
end


//========================================================================
//  AddJSONInt(...)
//    Fügt ein Wertpaar für Integer in die übergebene Json Struktur ein
//========================================================================
sub AddJSONInt(
  aJSON   : int;
  aName   : alpha;
  aWert   : int);
begin
//debugx('JSON_Add: '+aName+' : '+aint(aWert));
  if (aJSON->spCustom='SQL') then aName # aName + ';Int';
  aJSON->CteInsertNode(aName, _JsonNodeNumber , aWert);
//if (gUsername='AH') then debugx(aName+'='+aint(aWert));
end;


//========================================================================
//  AddJSONFloat(...)
//    Fügt ein Wertpaar für Floats in die übergebene Json Struktur ein
//========================================================================
sub AddJSONFloat(
  aJSON   : int;
  aName   : alpha;
  aWert   : float);
begin
//debugx('JSON_Add: '+aName+' : '+anum(aWert,2));
  if (aJSON->spCustom='SQL') then aName # aName + ';Float';
  aJSON->CteInsertNode(aName, _JsonNodeNumber , aWert);
//if (gUsername='AH') then debugx(aName+'='+aNum(aWert,2));
end;


//========================================================================
//  AddJSONAlpha(...)
//    Fügt ein Wertpaar für Floats in die übergebene Json Struktur ein
//========================================================================
sub AddJSONAlpha(
  aJSON   : int;
  aName   : alpha;
  aWert   : alpha(4096));
begin
//debugx(aint(aJSON)+' JsonAdd: '+aName+' : '+aWert);
  if (aJSON->spCustom='SQL') then aName # aName + ';String';
  aJSON->CteInsertNode(aName, _JsonNodeString , aWert);
//if (gUsername='AH') then debugx(aName+'='+aWert);
end;


//========================================================================
//  AddJSONBool(...)
//    Fügt ein Wertpaar für Floats in die übergebene Json Struktur ein
//========================================================================
sub AddJSONBool(
  aJSON   : int;
  aName   : alpha;
  aWert   : logic);
begin
  if (aJSON->spCustom='SQL') then aName # aName + ';Bool';
  aJSON->CteInsertNode(aName, _JsonNodeBoolean , aWert);
//if (gUsername='AH') then debugx(aName+'=true');
end;


//========================================================================
//  AddJSONDate(...)
//    Fügt ein Wertpaar für Floats in die übergebene Json Struktur ein
//========================================================================
sub AddJSONDate(
  aJSON   : int;
  aName   : alpha;
  aWert   : date);
local begin
  vName   : alpha;
end;
begin
/*
  if (aJSON->spCustom='SQL') then begin
    //aName # aName + ';Datetime';    2023-02-24  AH aus Kompatibiliät zu "nicht-Dirket-SQL"
    aName # aName + 'String;String';
    if (aWert=0.0.0) then begin
      aJSON->CteInsertNode(aName, _JsonNodeString , '');
    end
    else begin
      aJSON->CteInsertNode(aName, _JsonNodeString , cnvad(aWert,_Fmtinternal));
    end;
    RETURN
  end;

  if (aWert=0.0.0) then begin
    aJSON->CteInsertNode(aName+'String', _JsonNodeString , '');
//if (gUsername='AH') then debugx(aName+'=');
  end
  else begin
    aJSON->CteInsertNode(aName+'String', _JsonNodeString , cnvad(aWert,_Fmtinternal));
//if (gUsername='AH') then debugx(aName+'='+cnvad(aWert,_Fmtinternal));
  end;
*/
  if (aJSON->spCustom='SQL') then begin
    vName # aName + ';Datetime';
    if (aWert=0.0.0) then begin
      aJSON->CteInsertNode(vName, _JsonNodeString , '');
    end
    else begin
      aJSON->CteInsertNode(vName, _JsonNodeString , cnvad(aWert,_Fmtinternal));
    end;

    vName # aName + 'String;String';
    if (aWert=0.0.0) then begin
      aJSON->CteInsertNode(vName, _JsonNodeString , '');
    end
    else begin
      aJSON->CteInsertNode(vName, _JsonNodeString , cnvad(aWert,_Fmtinternal));
    end;
    RETURN
  end;


  if (aWert=0.0.0) then begin
    aJSON->CteInsertNode(aName+'String', _JsonNodeString , '');
  end
  else begin
    aJSON->CteInsertNode(aName+'String', _JsonNodeString , cnvad(aWert,_Fmtinternal));
  end;

end;


//========================================================================
//  _JSONtoPara(...) : alpha    NUR NOCH PRIVATE !!!
//  Wandelt das Json Objekt in einen Parameterstring für die Nutzung in
/// Serviceabfragen um und terminiert das Json Objekt
//========================================================================
sub _JSONtoPara(aJSON : handle) : alpha
local begin
  vMem  : handle;
  vErr  : int;
  vPara : alpha(4096);
end;
begin
  if (aJSON=0) then RETURN '';

  vMem # MemAllocate(_Mem1K);
//  17.03.2015 vMem->spcharset # _CharsetUTF8;

  vErr # aJSON->JSONSave('ignore',_JsonSaveDefault, vMem);  //  17.03.2015 _CharsetUTF8
  vPara # MemReadStr(vMem, 1, vMem->SpLen);
//debugx('JSON:'+vPara);
  // aufräumen..,
  MemFree(vMem);
// neu als extra Funktion:
//  aJSON->CteClear(true);
//  aJSON->CteClose();
//  aJSON # 0;

  RETURN vPara;
end;


//========================================================================
//  sub JSON_toMemObj(aJSON : handle) : int
//  Gibt das übergebene Json Objekt als Mem objekt zurück.
//========================================================================
sub JSON_toMemObj(aJSON : handle) : int
local begin
  vMem  : handle;
  vErr  : int;
  vPara : alpha(4096);
end;
begin
  if (aJSON=0) then RETURN -1;

  vMem # MemAllocate(_MemAutoSize);
//  17.03.2015 vMem->spcharset # _CharsetUTF8;

  vErr # aJSON->JSONSave('ignore',_JsonSaveDefault, vMem);  //  17.03.2015 _CharsetUTF8
  RETURN vMem;
end;


//========================================================================
//  CloseJSON
//========================================================================
sub CloseJSON(var aJSON : handle);
begin
  if (aJSON=0) then RETURN;
  aJSON->CteClear(true);
  aJSON->CteClose();
  aJSON # 0;
end;




//========================================================================
//========================================================================
sub CreatePrintServerSettings() : alpha;
local begin
  vJSON   : handle;
  vA      : alpha(4096);
end;
begin
  vJSON # OpenJSON();

  AddJsonAlpha(vJSON, 'Installname', Set.Installname);    // 2022-12-09 AH
  if ("Set.Hauswährung.Kurz"='€') then
    AddJsonAlpha(vJSON, 'Hauswaehrung', 'EUROSYMBOL')
  else
    AddJsonAlpha(vJSON, 'Hauswaehrung', "Set.Hauswährung.Kurz");
  AddJsonInt(   vJSON, 'Nachkommastellen_Gewicht',  Set.Stellen.Gewicht);
  AddJsonInt(   vJSON, 'Nachkommastellen_Menge',    Set.Stellen.Menge);
  AddJsonInt(   vJSON, 'Nachkommastellen_RAD',      Set.Stellen.Radien);
  AddJsonInt(   vJSON, 'Nachkommastellen_Dicke',    Set.Stellen.Dicke);
  AddJsonInt(   vJSON, 'Nachkommastellen_Breite',   Set.Stellen.Breite);
  AddJsonInt(   vJSON, 'Nachkommastellen_Laenge',   "Set.Stellen.Länge");

  AddJsonAlpha(   vJSON, 'SpracheKurz1',   Set.Sprache1.Kurz);
  AddJsonAlpha(   vJSON, 'SpracheKurz2',   Set.Sprache2.Kurz);
  AddJsonAlpha(   vJSON, 'SpracheKurz3',   Set.Sprache3.Kurz);
  AddJsonAlpha(   vJSON, 'SpracheKurz4',   Set.Sprache4.Kurz);
  AddJsonAlpha(   vJSON, 'SpracheKurz5',   Set.Sprache5.Kurz);
  vA # _JSONtoPara(vJSON);

  CloseJSON(var vJSON);
  RETURN vA;
end;



//========================================================================
//  sub JsonToCteList(aPara : alpha) : int        ST 2020-01-1 2042/21
//  Zerteilt eine Json Liste in eine C16 CteListe
//
//  {"1001":"3000" ,   "Farbe":"Rot","Endsumme":"42"}
//  {   "KgVormat":"1231231",    "1001":"12312,48"}
//
//========================================================================
sub JsonListToCteList(aPara : alpha(4096)) : int
local begin
  vCteList      : int;

  vKeyValue     : alpha(4096);
  vKeyValueCnt  : int;
  vKey          : alpha(2048);
  vValue        : alpha(2048);
  vI            : int;
  
  vX    : int;
  vY    : int;
  
  vEscapePart : alpha(2048);
  vEscapeInnerList : alpha;
  vNoQuot : logic;
 
  
end
begin

  if (aPara = '') then
    RETURN -1;

  
  //aPara   # Lib_Strings:Strings_ReplaceEachToken(aPara,'{}','');
  if (StrCut(aPara,1,1) = '{') then
    aPara # StrCut(aPara,2,StrLen(aPara)-2);
  
  // Fix für EINE unterliste vgl. ResultJson:
  vEscapeInnerList # StrChar(14);
  vX  # StrFind(aPara,'{',1);
  if (vX > 1) then begin
    vY  # StrFind(aPAra,'}',vX);
    vEscapePart # StrCut(aPara,vX,vY-vX+1);
    vEscapePart # Lib_Strings:Strings_ReplaceAll(vEscapePart,':',vEscapeInnerList);
    vEscapePart # Lib_Strings:Strings_ReplaceEachToken(vEscapePart ,'{}','');
    aPara # StrCut(aPara,1,vX) + vEscapePart + StrCut(aPara,vY,StrLen(aPara));
  end;
    
  
  REPEAT
    aPara # Lib_Strings:Strings_ReplaceAll(aPara,'  ',' ');
  UNTIL StrFind(aPara,'  ',1) = 0;
  aPara   # StrAdj(aPAra,_StrBegin | _StrEnd);

  //  '{"JobID":"24662_12_5_58","Data":"","Done":true,"Size":258844,"Title":"AB 100825","Adr":1,"Email":"mk@stahl-control.de"}
  //           1                      2         3           4              5                 6         7
  
  vNoQuot # (StrFind(aPara,'"',1) = 0);
  if (vNoQuot) then
    vKeyValueCnt  # Lib_Strings:Strings_Count(aPara,':');
  else
    vKeyValueCnt  # Lib_Strings:Strings_Count(aPara,'":');
  
  vCteList      # CteOpen(_CteList);
  FOR   vI # 1
  LOOP  inc(vI)
  WHILE vI <= vKeyValueCnt DO BEGIN

    vKey # Str_Token(aPara,':',vI);    // {"JobID"   oder   ","Done"  oder "24662_12_5_58","Data"
    if (vI = vKeyValueCnt) then begin
      // Letztes Token? "rückwärts" lesen
      vValue  # Str_Token(aPara,':',vI+1);
      if (vNoQuot) then begin
        vX      # StrFind(vKey,',',1,_StrFindReverse);
        vY      # StrLen(vKey);
        vKey    # StrCut(vKey,vX+1,vY);
      end else begin
        vKey    # StrCut(vKey,1,StrLen(vKey)-1);
        vX      # StrFind(vKey,'"',1,_StrFindReverse);
        vY      # StrLen(vKey);
        vKey    # StrCut(vKey,vX+1,vY);
      end

    end else begin
      if (vI > 1) then begin
        if (vNoQuot) then begin
          vY    # StrLen(vKey);
          vX    # StrFind(vKey,',',1,_StrFindReverse);
        end else begin
          vKey  # StrCut(vKey,2,StrLen(vKey)-2);
          vX    # StrFind(vKey,'"',1,_StrFindReverse);
        end
        vY    # StrLen(vKey);
        vKey  # StrCut(vKey,vX+1,vY);
      end;

      vValue # Str_Token(aPara,':',vI+1);    //     "24662_12_5_58","Data"   oder true,"Size"    oder     "123,12","Email"
      vX     # 1;
      vY     # StrFind(vValue,',',1,_StrFindReverse);
      vValue # StrCut(vValue,vX,vY-1);
    end;

    vKey # Lib_Strings:Strings_ReplaceAll(vKey,'"','');
    
    
    vValue # Lib_Strings:Strings_ReplaceAll(vValue,'\"','');
    vValue # Lib_Strings:Strings_ReplaceAll(vValue,'"','');
    vValue # Lib_Strings:Strings_ReplaceAll(vValue,vEscapeInnerList,':');    // Trennzeichen für geschachtelte Listen
    
    vCteList->CteInsertItem(vKey,vI,vValue,_CteLast);
  END;

  RETURN vCteList;
end;


//========================================================================
//  sub ToJsonList(ajsn : int) : alpha        ST 2020-01-1 2042/21
//========================================================================
sub ToJsonList(ajsn : int) : alpha
begin
  RETURN _JSONtoPara(aJsn);
end;


/*========================================================================
ST 2022-08-22

ermittelt den Json-Datentyp für das Übergebene C16 Feld
========================================================================*/
sub GetJsonNodeTypeFromFld(aFile : int; aTds : int; aFld : int) : int;
begin
  
  case FldInfo(aFile, aTds, aFld, _FldType) of
    _TypeAlpha ,
    _typeDate,
    _typeTime   : RETURN _JsonNodeString;

    _typeWord,
    _typeInt,
    _typeFloat,
    _typeBigInt,
    _TypeDecimal : RETURN _JsonNodeNumber;
    
    _typeLogic   : RETURN _JsonNodeBoolean;
  end;
  
  RETURN NULL;
end;


/*========================================================================
ST 2022-08-22

Fügt ein Feld anhand der übergebenen Feldinformationen (File/TDS/Fld) in
in das Übergebene CteNote ein
========================================================================*/
sub CteInsertNodeVar(
  aNodeArg  : handle; // Ziel CteJson Node
  aFile     : int;    // Tabellennummer
  aTds      : int;    // Teildatensatz
  aFld      : int)    // Feldnummer
local begin
  vFldName  : alpha;
  vFldTyp   : int;
end
begin
  vFldName  # Fldname(aFile, aTds, aFld);
  vFldTyp   # GetJsonNodeTypeFromFld(aFile, aTds, aFld);
  
  
  if (vFldName = 'Set.SQL.Password') then begin
    aNodeArg->CteInsertNode(vFldName, vFldTyp, 'ätschibätsch');
    RETURN;
  end;
  
  case FldInfo(aFile, aTds, aFld, _FldType) of
    _TypeAlpha    : aNodeArg->CteInsertNode(vFldName, vFldTyp, FldAlpha(  aFile, aTds, aFld));
    _typeDate     : aNodeArg->CteInsertNode(vFldName, vFldTyp, FldDate(   aFile, aTds, aFld));
    _typeTime     : aNodeArg->CteInsertNode(vFldName, vFldTyp, FldTime(   aFile, aTds, aFld));
    _typeWord     : aNodeArg->CteInsertNode(vFldName, vFldTyp, FldWord(   aFile, aTds, aFld));
    _typeInt      : aNodeArg->CteInsertNode(vFldName, vFldTyp, FldInt(    aFile, aTds, aFld));
    _typeFloat    : aNodeArg->CteInsertNode(vFldName, vFldTyp, FldFloat(  aFile, aTds, aFld));
    _typeBigInt   : aNodeArg->CteInsertNode(vFldName, vFldTyp, FldBigInt( aFile, aTds, aFld));
    _TypeDecimal  : aNodeArg->CteInsertNode(vFldName, vFldTyp, FldDecimal(aFile, aTds, aFld));
    _typeLogic    : aNodeArg->CteInsertNode(vFldName, vFldTyp, FldLogic(  aFile, aTds, aFld));
  end;
end;


/*========================================================================
ST 2022-08-22

Fügt ein Feld anhand der übergebenen Feldinformationen (Feldnamewn) in
in das Übergebene CteNote ein
========================================================================*/
sub CteInsertNodeVarByName(
  aNodeArg  : handle; // Ziel CteJson Node
  aFldName  : alpha;
)
begin
  RETURN CteInsertNodeVar(aNodeArg,
            FldInfoByName(aFldName,_FldFileNumber),
            FldInfoByName(aFldName,_FldSbrNumber),
            FldInfoByName(aFldName,_FldNumber));
end;


/*========================================================================
ST 2022-08-22

Exportiert einen Kompletten Datensatz Json Format
========================================================================*/
sub RecToJson(
  var aJsnHdl : handle;    // Offener Json Handle
  aFileNo     : int;    // Tabellennummer
  opt aTitle : alpha)   // Titel für Feldsammlung
local begin
  vTds    : int;
  vTdsMax : int;
  vFld    : int;
  vFldMax : int;
  
  vCteRec     : handle;
  vCteFldCur  : handle;
end
begin
  if (FileInfo(aFileNo,_FileExists) = 0) then
    RETURN;
    
  vCteRec # aJsnHdl->CteInsertNode(aTitle, _JSONNodeArray, NULL);
  
  // Tabelle einfügen
  vCteRec # vCteRec->CteInsertNode('', _JsonNodeObject, NULL);
  
  // Daten der Tabelle
  vTdsMax # FileInfo(aFileNo, _FileSbrCount)
  FOR vTds # 1
  LOOP inc(vTds)
  WHILE vTds <= vTdsMax DO BEGIN

    vFldMax # SbrInfo(aFileNo,vTds, _SbrFldCount);
    FOR vFld # 1
    LOOP inc(vFld)
    WHILE vFld <= vFldMax DO BEGIN
      vCteRec->CteInsertNodeVar(aFileNo,vTds ,vFld);
    END;
    
  END;

end;



/*
========================================================================
DS 2022-10-11

Hilfsfunktion / Auswerter für Unittest für LoadJSON. Gibt Ergebnis aus.
========================================================================
*/
sub __MAIN_unittesthelper_LoadJSON(
  aCte : handle
) : logic
local begin
  vSollwert : alpha;
  vErhalten : alpha;
  vKorrekt  : logic;
end
begin

  vSollwert # 'AttributTest ÄäÜüÖöß';
  vErhalten # aCte->CteRead(_CteFirst | _CteSearch, 0, 'dyn_0_1661877135360')->spValueAlpha;
  vKorrekt # vSollwert = vErhalten;
  DebugM('Sollwert:' + StrChar(9) + '"' + vSollwert + '"' + cCrlf + 'Erhalten:' + StrChar(9) + '"' + vErhalten + '"' + cCrlf2 + 'Korrekt:' + StrChar(9) + Lib_Auxiliaries:CnvAL(vKorrekt));
  
  return vKorrekt;
end



/*
========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================
*/
MAIN()
local begin
  // hier ausnahmsweise generische Variablennamen die in Beispielen wiederverwendet werden
  vAlpha  : alpha;
  vBeta   : alpha;
  vInt    : int;
  vLogic  : logic;
  vCte    : handle;
  vFile   : handle;
  vMemObj : handle;
  vMemObj2 : handle;
end;
begin

  // ggf. benötigte globals allokieren für Standalone-Ausführung (CTRL + T)...
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  VarAllocate(WindowBonus);
  // ...und setzen
  gUserName # 'ME';
  
  // Erforderlich damit Lib_SFX:* Funktionen bei standalone Ausführung (STRG+T) funktionieren (nicht nötig innerhalb von laufendem SC (STRG+R))
  Lib_SFX:InitAFX();
  

  /*
  ========================================================================
  "Unit Tests" für LoadJSON
  ========================================================================
  
  vorausgesetzt wird, dass der folgende Inhalt in die zwei Dateien
  c:\debug\json_ansi.json
  und
  c:\debug\json_utf8.json
  kopiert wird, mit dem jeweils angegebenen encoding. In Windows reicht
  zum Konvertieren schon das normale Notepad aus:
  ("Datei" -> "Speichern unter...", encoding wählen)
  
  {
    "docart":"Dokumentenart",
    "dyn_0_1660293743861":"Einpflegung",
    "docid":"DocID",
    "dyn_0_1653407121274":"SC Dok.Nummer",
    "defdate":"Wiedervorlage ab",
    "dyn_0_1660720372920":"Lieferant",
    "dyn_5_1653410507121":"SC Adr.Stichwort",
    "changeid":"Bearbeitet von",
    "revision":"Revision",
    "rechte":"Berechtigung",
    "dyn_0_1655453410609":"Auftragsnummer",
    "dyn_4_1653410507121":"SC Adr.KundenNr",
    "folder":"Ordner",
    "cdate":"Datum",
    "dyn_3_1653410507121":"SC Dok.FormularName",
    "bemerkung":"Bemerkung",
    "dyn_2_1653410507121":"SC Frm.Bereich",
    "dyn_0_1653410507121":"SC 916 Key1",
    "dyn_0_1653413876368":"SC Frm.Kürzel",
    "ctimestamp":"Letzte Änderung",
    "dyn_0_1661877135360":"AttributTest ÄäÜüÖöß",
    "mainfolder":"Hauptordner",
    "status":"Status",
    "dyn_1_1653410507121":"SC Frm.Name"
  }
  */
  
  // Es gibt 4 Fälle zu testen: {File, MemObj} x {ANSI, UTF8}

  // Fall 1: ANSI aus File
  vCte # LoadJSON('c:\debug\json_ansi.json');
  __MAIN_unittesthelper_LoadJSON(vCte);
  
  // Fall 2: UTF8 aus File
  vCte # LoadJSON('c:\debug\json_utf8.json', true);
  __MAIN_unittesthelper_LoadJSON(vCte);
  
  // Fall 3: ANSI aus MemObj
  // nicht getestet, da dieser Fall hoffentlich nicht vorkommt.
  // Das Problem ist dass eine ANSI Datei auf dem Wege wie man es
  // erwarten würde in ein Memory-Objekt zu lesen, scheinbar nicht
  // möglich ist:
  // Dasselbe pattern wie bei UTF8 funktioniert nicht und auch
  // _FsiANSI statt _FsiPure beim FsiOpen zu verwenden funktioniert
  // nicht.
  // Vermutlich würde LoadJSON in der aktuellen Version mit ANSI jsons
  // memory objects funktionieren; der bottleneck ist, dass zum Beweis
  // jemand es schaffen müsste, ein ANSI json erfolgreich in ein MemObj
  // zu lesen.
  
  // Fall 4: UTF8 aus MemObj
  vFile # FsiOpen('c:\debug\json_utf8.json', _FsiStdRead | _FsiPure);
  vMemObj  # Memallocate(_MemAutoSize);
  vMemObj2 # Memallocate(_MemAutoSize);
  vMemObj->spcharset # _CharSetUTF8;
  FsiReadMem(vFile, vMemObj, 1, FsiSize(vFile));
  vMemObj->MemCnv(vMemObj2, _CharsetC16_1252);
  vCte # LoadJSON('', true, vMemObj2);
  __MAIN_unittesthelper_LoadJSON(vCte);
  
  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;
  
end


//========================================================================

