@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_SQL
//                    OHNE E_R_G
//  18.04.2012  AI  Erstellung der Prozedur
//  05.09.2012  AI  SQLTimeStamp
//  15.11.2013  AH  Printserver für PDF, Word, Excel aktiviert
//  13.03.2014  AH  "CreateShowPDF" mit Setting-Parameter
//  04.07.2014  AH  Service braucht "eigeneAdressNummer"
//  17.09.2014  ST  Meldung "service not available" erweitert; URL wird mit ausgegeben
//  18.02.2015  ST  Printserverdruck über Datenbankergebnis Projekt 1326/415
//  17.03.2015  AH  "DeletePringFiles" mit TRY
//  24.06.2015  AH  neuer Parameter: "EigenerUser"
//  04.08.2015  ST  Das Speichern des Dokumentes löscht das Orignal PDF File nicht mehr
//  27.08.2015  AH  "LinkDepth" wird für PrintServer überheben
//  18.11.2015  AH  Edit: "UseService_StartPDF" übergibt nun ein JSON-Node statt ein JSON-Alpha
//  19.05.2016  AH  Neu: "UseService_Alive"
//  03.06.2016  ST  "CreateShowPDF" neues Argument "aSubject" für Umbennenung des Formulars
//  06.06.2016  AH  Umbau: alles über MemDB
//  18.07.2016  AH  Umbau: "CreateShowPdf" resultiert mit temp. Filenamen statt "OK"
//  28.02.2017  ST  Bugfix: "TimeStamp" Uhrzeit immer mit führenden nullen
//  01.06.2017  ST  "CreateShowPDF" neues optionales Argument "aNoDel"
//  09.06.2017  ST  Umbau: Kein Splashscreen für User SOA
//  21.12.2017  ST  Edit: Druckvorschau liest Drucker aus Formulareinstellung, anstatt Standarddrucker
//  04.04.2018  AH  Redo "_WaitForSync"
//  23.10.2018  AH  Edit: CreateShowPDF mit aMustEMA
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  16.06.2020  AH  User "SOA_SYNC"
//  03.07.2020  ST  GetTempDok Aufruf ereitert (Splashscreen) P1326/585
//  04.09.2020  ST  Bugfix: _WaitForSync(...) Prüfung auf SOA User korrigiert 2117/10
//  21.10.2020  AH  NetCore Anbindung
//  28.04.2021  AH  "Connectionstring"
//  27.07.2021  AH  ERX
//  23.05.2022  ST  Edit: "Connecitonstring" prüft ggf. auf Testsystem
//  09.06.2022  ST  Neu:; "CreatePDF" hinzugefügt um Reports als PDF vom Printserveranzufordern
//  10.08.2023  TM  WinSleep(500) in CreateXML vor Öffnen der XML; notwendig bei Custom-SQL-Listen
//
//
//  Subprozeduren
//  SUB SQLTimeStamp(aDat : date; aTim : time) : alpha;
//...
//  SUB Fld2SQLName();
//
//  SUB UseService_StartPDF(aName : string; aPara : alpha) : logic;
//
//  SUB CreateShowPDF(aName : alpha;aPara : alpha) : logic;
//
//========================================================================
@I:Def_Global
@I:SFX_Std_XML_Def

//@define Log

define begin
//  Log(a)      :  Lib_Soa:Dbg(cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+ '['+__PROC__+':'+aint(__LINE__)+']' + ':' + a);

  // Mindest Version vom Print-Server
  c_MinVersion  : 1633

  c_KlammerA  : ''
  c_KlammerZ  : ''
  c_Start     : StrChar(254)
  c_Ende      : '"'

  c_Timeout   : 30
  c_Path      : 'Z:\C16\ReportGenerator'
  c_PathPDF   : 'E:\PDF\'
  c_ConString : 'DSN=Kasselmann_Ori;UID=su;PWD=VIB'

  c_Programmer  :  (gUserGroup='PROGRAMMIERER') and (gUserName<>'FS') and (gUsername<>'TJ') then if (Msg(99,'Designer?',_WinIcoQuestion,_WinDialogYesNo,_WinIdYes)=_Winidyes)

  c_PerJobber   : false//true
end;

//========================================================================
//  ConnectionString
//========================================================================
sub Connectionstring() : alpha
local begin
  vDB  : alpha(100);
  vRet : alpha(1000);
end
begin
  vDB # Set.SQL.Database;

  if (isTestsystem) AND (Str_Contains(vDB,'TESTSYSTEM')=false) then
    vDB # vDb + '_testsystem';

  vRet # 'Data Source='+Set.SQL.Instance+';Initial Catalog='+vDB+';Integrated Security=False;Persist Security Info=True;User ID='+Set.SQL.User+';Password='+Set.SQL.Password;
  RETURN vRet;
end;


//========================================================================
//
//
//========================================================================
sub SQLDate(aDat : date) : alpha;
begin
  if (aDat=0.0.0) then RETURN 'IS NOT NULL';
  RETURN ''''+cnvai( DateYear(aDat)+1900,_FmtNumLeadZero|_FmtNumNoGroup,0,4)+'-'+
          cnvai( DateMonth(aDat),_FmtNumLeadZero,0,2)+'-'+
          cnvai( Dateday(aDat),_FmtNumLeadZero,0,2) + '''';
end;

//========================================================================
//  SQLTimeStamp
//
//========================================================================
Sub SQLTimeStamp(
  aDat  : date;
  aTim  : time) : alpha;
local begin
  vA  : alpha;
  vL  : int;
end;
begin

  if (aTim->vpHours=24) then aTim->vphours # 0;

  vL # LocaleLoad(_LclLangGerman, _LclSublangGerman);
  vL->SysPropSet(_SysPropLclDateLFormat, 'yyyy-MM-dd');
  vL->SysPropSet(_SysPropLclDateSep, '-');
  vL->SysPropSet(_SysPropLclDateLOrder, 2);

  // Führende Nullen bei 24-Stunden-Anzeige aktivieren
  vL->SysPropSet(_SysPropLclTimeHourMode, 1);
  vL->SysPropSet(_SysPropLclTimeLZero, 1);

  if (aDat=0.0.0) then
    vA # cnvat(aTim,_FmtTime24Hours|_FmtTimeSeconds,vL)+'.000'
  else
    vA # cnvad(aDat, _FmtDateLong, vL)+'T'+cnvat(aTim,_FmtTime24Hours|_FmtTimeSeconds,vL)+'.000';
  LocaleUnload(vL);

  RETURN vA;

end;

//========================================================================
//
//
//========================================================================
sub NameConvert(var aName : alpha);
begin
  aName # Str_ReplaceAll(aName, '.', '_');
  aName # Str_ReplaceAll(aName, '-', '_');
end;


//========================================================================
//  FldName2SQL
//
//========================================================================
Sub FldName2SQL(
  aFldName  : alpha) : alpha
local begin
  vA  : alpha(200);
  vB  : alpha(200);
end;
begin
  if (StrCut(aFldName,1,1)='"') then aFldName # Strcut(aFldName,2, StrLen(aFldName)-2);
//  vA # Filename(FldInfoByName(aFldName,_Filenumber));
//  NameConvert(var vA);
  NameConvert(var aFldName);
//  RETURN '"'+vA+'"."'+aFldName+'"';
  RETURN c_Start+aFldName+c_Ende;
end;


//========================================================================
//  QInt
//
//========================================================================
sub QInt (
  var aQ   : alpha;   // RückgabeQueryvar
  aFld     : alpha;   // Abfragefeld
  aOp      : alpha;   // Vergleichsoperator (=,>,=>,<,<=,*)
  aW1      : int;     // Vergleichswert
  opt aLog : alpha );
begin
  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' ' + aOp + ' ' + AInt( aW1 )+c_KlammerZ;
end;


//========================================================================
//  QFloat
//
//========================================================================
sub QFloat (
  var aQ   : alpha;
  aFld     : alpha;
  aOp      : alpha;
  aW1      : float;
  opt aLog : alpha );
begin

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if ( aW1 != 0.0 ) then
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' ' + aOp + ' ' + CnvAF( aW1, _fmtNumNoGroup | _fmtNumPoint )+c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' ' + aOp + ' 0.0'+c_KlammerZ;
end;


//========================================================================
//  QenthaeltA
//
//========================================================================
sub QenthaeltA (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : alpha;
  opt aLog : alpha );
begin
  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;
  // % ist wildcard
  aQ # Str_ReplaceAll(aQ,'*','%');

  aQ # aQ + c_KlammerA+ FldName2SQL(aFld) + ' LIKE ''%' + aW1 + '%'''+c_KlammerZ;
end;


//========================================================================
//  QAlpha
//
//========================================================================
sub QAlpha (
  var aQ   : alpha;
  aFld     : alpha;
  aOp      : alpha;
  aW1      : alpha;
  opt aLog : alpha );
begin

  if (aOP='=*') then begin
    QenthaeltA(var aQ, aFld, aW1, aLog);
    RETURN;
  end;

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  aQ # aQ + c_KlammerA+ FldName2SQL(aFld) + ' ' + aOp + ' ''' + aW1 + ''''+c_KlammerZ;
end;


//========================================================================
//  QDate
//
//========================================================================
sub QDate (
  var aQ   : alpha;
  aFld     : alpha;
  aOp      : alpha;
  aW1      : date;
  opt aLog : alpha );
begin

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if ( aW1 != 0.0.0 ) then
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' ' + aOp + ' ' + SQLDate(aW1) +c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' IS NULL';
end;


//========================================================================
//  QLogic
//
//========================================================================
sub QLogic (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : logic;
  opt aLog : alpha );
begin
  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if ( aW1 ) then
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + '=1' +c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) +'=0'+c_KlammerZ;
end;


//========================================================================
//  QTime
//
//========================================================================
sub QTime (
  var aQ   : alpha;
  aFld     : alpha;
  aOp      : alpha;
  aW1      : time;
  opt aLog : alpha );
begin
  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' ' + aOp + ' ''' + CnvAT( aW1 )+''''+c_KlammerZ;
end;


//========================================================================
//  QVonBisI
//
//========================================================================
sub QVonBisI (
//  aAttach   : logic;
  var aQ    : alpha;
  aFld      : alpha;
  aW1       : int;
  aW2       : int;
  opt aLog  : alpha);
local begin
//  vQ        : alpha;
//  vFileName : alpha;
end;
begin

  // bisheriges Querey laden
//  vTxt # TextOpen(10);
//  if (aAttach=n) then TxtDelete('!SQL_'+gSQLWhere, 0)
//  else vTxt->TextRead('!SQL_'+gSQLWhere, 0);
//  vFileName # '"'+Filename(FldInfoByName(aFld,_Filenumber))+'"';
//  if ( aAttach ) then begin
//    if ( aLog = '' ) then vQ # vQ + ' AND ';
//    else vQ # vQ + ' ' + aLog + ' ';
//  end;

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if ( aW1 != aW2 ) then
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' BETWEEN ' + AInt( aW1 ) + ' AND ' + AInt( aW2 ) + c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' = ' + AInt( aW1 )+c_KlammerZ;

//  TextAddLine(vTxt, vQ);
//  TextLineWrite(vTxt,TextInfo(vTxt,_TextLines)+1,vQ,_TextLineInsert)
//  TxtDelete('!SQL_'+gSQLWhere, 0);
//  vTxt->TxtWrite('!SQL_'+gSQLWhere, 0);
//  TextClose(vTxt);

end;


//========================================================================
//  QVonBisF
//
//========================================================================
sub QVonBisF (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : float;
  aW2      : float;
  opt aLog : alpha );
begin
  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if ( aW1 != aW2 ) then
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' BETWEEN ' + CnvAF( aW1, _fmtNumNoGroup | _fmtNumPoint ) + ' AND  ' + CnvAF( aW2, _fmtNumNoGroup | _fmtNumPoint ) + c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' = ' + CnvAF( aW1, _fmtNumNoGroup | _fmtNumPoint )+c_KlammerZ;
end;


//========================================================================
//  QVonBisD
//
//========================================================================
sub QVonBisD (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : date;
  aW2      : date;
  opt aLog : alpha );
begin

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if ( aW1 = 0.0.0 ) and (aW2>0.0.0) then
    aQ # aQ +c_KlammerA + FldName2SQL(aFld) + ' <= ' + SQLDate(aW2) +c_KlammerZ
  else if (aW1>0.0.0) and (aW2=0.0.0) then
    aQ # aQ +c_KlammerA + FldName2SQL(aFld) + ' >= ' + SQLDate(aW1) +c_KlammerZ
  else if ( aW1 = aW2 ) then
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' = ' + SQLDate(aW1) +c_KlammerZ
  else
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' BETWEEN ' +  SQLDate(aW1) + ' AND ' +  SQLDate(aW2) + c_KlammerZ;
end;


//========================================================================
//  QVonBisA
//
//========================================================================
sub QVonBisA (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : alpha;
  aW2      : alpha;
  opt aLog : alpha );
begin

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if ( aW1 != aW2 ) then
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' BETWEEN ''' + aW1 + ''' AND ''' + aW2 + ''''+c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' = ''' + aW1 + ''''+c_KlammerZ;
end;


//========================================================================
//  QVonBisT
//
//========================================================================
sub QVonBisT (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : time;
  aW2      : time;
  opt aLog : alpha );
local begin
  vW1      : alpha;
  vW2      : alpha;
end;
begin
  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  vW1 # CnvAT( aW1 );
  vW2 # CnvAT( aW2 );

  if ( aW1 != aW2 ) then
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' BETWEEN ' + vW1 + ' AND ' + vW2 + c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ FldName2SQL(aFld) + ' = ' + vW1+c_KlammerZ;
end;


//========================================================================
//  GetLinkString
//
//========================================================================
sub GetLinkString(
  aDatei  : int;
  aLink   : int;
  opt aText : alpha(4096)) : alpha;
local begin
  vLink   : alpha(4096);
  v2Datei : int;
  vI      : int;
  vTds    : int;
  vFld    : int;
  vFName  : alpha;
  v2Tds   : int;
  v2Fld   : int;
  v2FName : alpha;
  v2Key   : int;
  v2TName : alpha;
  vAlias  : alpha;
end;
begin
  // Zieldatei ermitteln...
  v2Datei # LinkInfo(aDatei, aLink,_LinkDestFileNumber);
  // ZielKey ermitteln...
  v2Key # LinkInfo(aDatei, aLink, _LinkDestKeyNumber);
  v2TName # FileName(v2Datei);
  NameConvert(var v2TName);
  vAlias # 'x'+aint(v2Datei)+aint(aDatei);

  vLink # 'EXISTS (SELECT ';
  FOR vI # 1 loop inc(vI) while (vI<=LinkInfo(aDatei, aLink, _LinkFldCount)) do begin
    vTds # LinkFldInfo(aDatei, aLink, vI, _LinkFldSbrNumber);
    vFld # LinkFldInfo(aDatei, aLink, vI, _LinkFldNumber);
    vFName # FldName(aDatei, vTds, vFld);

    v2Tds # KeyFldInfo(v2Datei, v2Key, vI, _KeyFldSbrNumber);
    v2Fld # KeyFldInfo(v2Datei, v2Key, vI, _KeyFldNumber);
    v2FName # FldName(v2Datei, v2Tds, v2Fld);
    NameConvert(var v2FName);
    NameConvert(var vFName);
    //vFTyp   # FldInfo(v2Datei, vK, vJ, _FldType);

    if (vI=1) then begin
      vLink # vLink + vAlias+'."'+v2FName+'" FROM "'+v2TName+'" '+vAlias+' WHERE ';
    end;
    if (vI>1) then vLink # vLink + ' AND ';

    vLink # vLink + vAlias+'."'+v2FName+'"="' +vFName+'"';
  END;

  if (aText<>'') then begin
    vI # 1;
    vI # StrFind(aText,c_Start,vI);
    WHILE (vI>0) do begin
      aText # StrDel(aText, vI, 1);
      aText # StrIns(aText, vAlias+'."', vI);
      vI # vI + StrLen(vAlias) + 1 + 1;
      vI # StrFind(aText,c_Ende,vI);
      if (vI=0) then RETURN 'error in Link';
      vI # vI + 1;
      vI # StrFind(aText,c_Start,vI);
    END;
    vLink # vLink + ' AND ' +aText;
  end;

  RETURN vLink;
end;


//========================================================================
//
//
//========================================================================
sub _SaveListParameter(
  aFilename   : alpha(4096);
  aName       : alpha;
  aConnection : alpha;
  aReport     : alpha;
  aOut        : alpha;
  aParaList   : int;
  aSQLBuffer  : int;
  ) : logic;
local begin
  vDoc          : handle;
  vRoot, vNo    : handle;
  vNo2,vNo3     : handle;
  vErg          : int;
  vWhere, vA    : alphA(4096);
  vSort         : alpha(1000);
  vI            : int;
end
begin

  vI # CteRead(gSQLBuffer, _CteFirst | _CteSearch,0, 'SORT');
  if (vI>0) then vSort # vI->spCustom;


  // ermittle die SubTables aus dem SQL-Buffer
  vWhere # MemReadStr(aSQLBuffer,1, aSQLBuffer->spLen);
/***
  vI # StrFind(vWhere, '#',vI+1);
  WHILE (vI>0) do begin
    vA # StrCut(vWhere, vI,4);
    vWhere # StrDel(vWhere, vI,4);

    vA # FileName(cnvia(vA));
    NameConvert(var vA);
    if (vSubtables<>'') then vSubtables # vSubtables + ',';
    vSubtables # vSubtables + '"'+vA+'"';

    vI # StrFind(vWhere, '#',vI+1-4);
  END;
***/
//  vFilename # aPath + '\test.xml';

 // Create document node
  vDoc # CteOpen(_CteNode);

  vDoc->spID # _XmlNodeDocument;

  // insert comment
  vDoc->CteInsertNode('', _XmlNodeComment, 'Stahl-Control');

  // insert root
  vRoot   # XML_NodeA(vDoc,   'ListParameter',   '');
  vNo     # XML_NodeA(vRoot,  'Name',             aName);
  vNo     # XML_NodeA(vRoot,  'ConnectionString', aConnection);
  vNo     # XML_NodeA(vRoot,  'Report',           aReport);
  vNo     # XML_NodeA(vRoot,  'Output',           aOut);
  vNo     # XML_NodeA(vRoot,  'Sorting',          vSort);
  FOR vI # CteRead(aParaList, _CteFirst)
  LOOP vI # CteRead(aParaList, _CteNext, vI)
  WHILE (vI>0) do begin
    if (StrCut(vI->spname,1,2)='S:') then begin
      vNo2    # XML_NodeA(vNo,    'TableSorting','');
      vA # Lib_Strings:Strings_Token(vI->spcustom,'|',1);
      vNo3    # XML_NodeA(vNo2,   'Expression',             vA);
      vA # Lib_Strings:Strings_Token(vI->spcustom,'|',2);
      vNo3    # XML_NodeA(vNo2,   'Direction',              vA);
    end;
  END;
  vNo     # XML_NodeA(vRoot,  'Where',            vWhere);
  //  vNode   # XML_NodeA(vRoot,  'SubTables',        vSubTables);
  vNo     # XML_NodeA(vRoot,  'Selections',       '');
/**
  for vI # 1 loop inc(vI) while (vI<3) do begin
    vNo2    # XML_NodeA(vNo,    'ListParameterSelection','');
    vNo3    # XML_NodeA(vNo2,   'Name',             'Nummer');
    vNo3    # XML_NodeA(vNo2,   'Min',              '1');
    vNo3    # XML_NodeA(vNo2,   'Max',              '1234123');
    vNo3    # XML_NodeA(vNo2,   'Value',            'gaga');
  end;
**/
  FOR vI # CteRead(aParaList, _CteFirst)
  LOOP vI # CteRead(aParaList, _CteNext, vI)
  WHILE (vI>0) do begin
    if (StrCut(vI->spname,1,2)='P:') then begin
      vNo2    # XML_NodeA(vNo,    'ListParameterSelection','');
      vA # Lib_Strings:Strings_Token(vI->spcustom,'|',1);
      vNo3    # XML_NodeA(vNo2,   'Name',             vA);
      vA # Lib_Strings:Strings_Token(vI->spcustom,'|',3);
      vNo3    # XML_NodeA(vNo2,   'Min',              vA);
      vA # Lib_Strings:Strings_Token(vI->spcustom,'|',4);
      vNo3    # XML_NodeA(vNo2,   'Max',              vA);
      vA # Lib_Strings:Strings_Token(vI->spcustom,'|',2);
      vNo3    # XML_NodeA(vNo2,   'Value',            vA);
    end;
  END;
//  vErg # vDoc->XmlSave(vFilename+'_CharsetUTF8.xml',_XmlSaveDefault,0,_CharsetUTF8);
  vErg # vDoc->XmlSave(aFilename,_XmlSaveDefault,0, _CharsetUTF8);

  vDoc->CteClear(true);
  vDoc->CteClose();

  RETURN true;
end;


//========================================================================
//
//
//========================================================================
sub AddSQL(
  aText           : alpha(4096);
  opt aDatei      : int;
  opt aLink       : int);
local begin
  vI      : int;
  vLink   : alpha(4000);
  vAppend : logic;
  v2Datei : int;
  v2Key   : int;
  vTds    : int;
  vFld    : int;
  vFName  : alpha;
  v2Tds   : int;
  v2Fld   : int;
  v2FName : alpha;
  v2TName : alpha;
  vAlias  : alpha;
  vA      : alpha(4096);
end;
begin

  if (aText<>'') then
    aText # ' '+aText+' ';//StrCnv(aText,_Strlower)+' ';
//  if (StrCut(aText,1,3)='AND') or (StrCut(aText,1,2)='OR') then aText # ' '+aText;

  vAppend # y;
  if (gSQLBuffer=0) then begin
    gSQLBuffer # MemAllocate(_Mem8k);
    vAppend # n;
  end;

  // Link analysieren?
  if (aDatei<>0) then begin

    // Zieldatei ermitteln...
    v2Datei # LinkInfo(aDatei, aLink,_LinkDestFileNumber);
    // ZielKey ermitteln...
    v2Key # LinkInfo(aDatei, aLink, _LinkDestKeyNumber);
    v2TName # FileName(v2Datei);
    NameConvert(var v2TName);
    vAlias # 'x'+aint(v2Datei)+aint(aDatei);


    // Alias als Prefix
    if (aText<>'') then begin
      vI # 1;
      vI # StrFind(aText,c_Start,vI);
      WHILE (vI>0) do begin
        aText # StrDel(aText, vI, 1);
        aText # StrIns(aText, vAlias+'."', vI);
        vI # vI + StrLen(vAlias) + 1 + 1;
        vI # StrFind(aText,c_Ende,vI);
        if (vI=0) then RETURN;  // FALSCH!!!
        vI # vI + 1;
        vI # StrFind(aText,c_Start,vI);
      END;
    end;


    vLink # GetLinkString(aDatei, aLink);

    if (aText<>'') then
      vLink # vLink + ' AND ';

    MemWriteStr(gSQLBuffer, gSQLBuffer->spLen+1, vLink);
//debug(Lib_Strings:Strings_DOS2WIN(vLink));
  end
  else begin
    if (aText<>'') then begin
      if (c_Start<>'"') then
        aText # Str_ReplaceAll(aText,c_Start,'"');
      if (c_ende<>'"') then
        aText # Str_ReplaceAll(aText,c_Ende,'"');
    end;
  end;

  if (aText='') then RETURN;

  MemWriteStr(gSQLBuffer, gSQLBuffer->spLen+1, aText);
//debug(Lib_Strings:Strings_DOS2WIN(aText));
end;


//========================================================================
//
//
//========================================================================
/*
sub SaveSQL()
begin

  SaveListParameter('E:\', 'Coole C16-Liste', 'DSN=sc_32;UID=su;PWD=VIB', 'List899001', 'out', 'sort', gSQLBuffer);

//  FsiClose(gSQLBuffer);
//  vFileHdl # FSIOpen('e:\test.txt',_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
//  FsiWritemem(vFileHdl, gSQLBuffer, 1,  gSQLBuffer->spLen);
//  FsiClose(vFileHdl);

  if (gSQLBuffer=0) then RETURN;
  MemFree(gSQLBuffer);
  gSQLBuffer # 0;

  Msg(999998,'',0,0,0);
end;
*/

//========================================================================
//  SetPara
//
//========================================================================
sub SetPara(
  aName         : alpha(500);
  aW1           : alpha(500);
  opt aW2       : alpha(500));
local begin
  vA    : alpha(2000);
  vI    : int;
end;
begin
  if (gSQLBuffer=0) then
    gSQLBuffer # CteOpen(_CteTreeCI);

  // nur EIN Parameter?
  if (aW2='') then
    vA # aName+'|'+aW1+'||'
  else
    vA # aName+'||'+aW1+'|'+aW2;
  vI # CteInfo(gSQLBuffer, _CteCount);
  CteInsertItem(gSQLBuffer, 'P:'+aint(vI+1), 0, vA, _cteLast);
end;


//========================================================================
//  SetSort
//
//========================================================================
sub SetSort(
  aSortExpression  : alpha(500);
  aSortDirection    : alpha(500));
local begin
  vA    : alpha(2000);
  vI    : int;
end;
begin
  /*
  if (gSQLBuffer=0) then
    gSQLBuffer # CteOpen(_CteTreeCI);
  */
  if (gSQLBuffer=0) then
    gSQLBuffer # CteOpen(_CteTreeCI);

  vA # aSortExpression+'|'+StrCnv(aSortDirection, _StrUpper)+'||'

  vI # CteInfo(gSQLBuffer, _CteCount);
  CteInsertItem(gSQLBuffer, 'S:' + AInt(vI + 1), 0, vA, _cteLast);
end;


//========================================================================
//  SetSubSQL
//
//========================================================================
sub SetSubSQL(
  aName         : alpha;
  aText         : alpha(4096);
  opt aDatei    : int;
  opt aLink     : int);
begin
  if (gSQLBuffer=0) then
    gSQLBuffer # CteOpen(_CteTreeCI);

  if (aDatei<>0) then begin
//    if (aText='') then aText # 'AND 1=1';
    aText # GetLinkString(aDatei, aLink, aText);
  end
  else begin
    aText # Str_ReplaceAll(aText, c_Start, '"');
  end;

  CteInsertItem(gSQLBuffer, StrCnv(aName,_strupper), (aDatei * 100) + aLink, aText, _cteLast);
end;


//========================================================================
//
//
//========================================================================
sub _GetSubSQL(var aName : alpha) : int;
local begin
  vItem : int;
end;
begin
  vItem # CteRead(gSQLBuffer, _CteFirst | _CteSearch,0, aName);
  if (vItem<=0) then RETURN -1;
  aName # vItem->spcustom;
  if (vItem->spid=0) then RETURN 0;
  RETURN 1;
end;


//========================================================================
//  ParseSQL
//
//========================================================================
sub ParseSQL(aSQL : alpha(4096));
local begin
  vA      : alpha(4096);
  vI,vJ   : int;
  vBuf    : int;
  vFile   : int;
  vTiefe  : int;
  vT      : int;
end;
begin

  if (gSQLBuffer=0) then
    gSQLBuffer # CteOpen(_CteTreeCI);

  vBuf # MemAllocate(_Mem8k);
//MemWriteStr(vBuf, vBuf->spLen+1, 'SELECT * FROM Auf_Aktionen WHERE ');


  aSQL # StrCnv(aSql, _StrUpper);

  FOR vI # 1 loop inc(vI) while (vI<=strLen(aSQL)) do begin

    vA # Strcut(aSql, vI ,1);
    if (vA='\') then begin
      vA # StrChar(41, vTiefe);
      vTiefe # 0;
    end;
    if (vA=')') or (vA='\') and (vTiefe>0) then begin
      vA # vA + StrChar(41, vTiefe);
      vTiefe # 0;
    end;


    if (vA='Q') then begin
      // Ende suchen...
      vJ # vI;
      REPEAT
        inc (vJ);
        vA # StrCut(aSql,vJ,1);
      UNTIL ((vA=')') or (vA=' ') or (vA='\') or (vJ>StrLen(aSQL)));
      vA # StrCut(aSql, vI, vJ-vI);
      vT # _GetSubSQL(var vA);
      if (vT<0) then begin
        vA # '<'+vA+'>NOTFOUND!';
      end
      else begin
        vTiefe # vTiefe + vT;
//        if (vA='') then vA # '1=1';
      end;

      vI # vJ - 1;
    end;

    if (vI>=StrLen(aSQL)) and (vTiefe>0) then begin
      vA # vA + StrChar(41, vTiefe);
      vTiefe # 0;
    end;


    MemWriteStr(vBuf, vBuf->spLen+1, vA);
  END;

  // WRITE
//  vFile # FSIOpen('e:\debug\debug.txt',_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
//  FsiWriteMem(vFile, vBuf, 1,  vBuf->spLen);
//  FsiCLose(vFile);

//  SaveListParameter('E:\', 'Coole C16-Liste', 'DSN=sc_32;UID=su;PWD=VIB', 'List899001', 'out', 'sort', gSQLBuffer, vBuf);

  // Aufräumen
//  CteClear(gSQLBuffer, y);
//  CteClose(gSQLBuffer);
//  gSQLBuffer # 0;
//  MemFree(vBuf);

//  Msg(999998,'',0,0,0);

  CteInsertItem(gSQLBuffer, 'SCRIPT', vBuf, '', _cteLast);
end;


//========================================================================
//  SaveSQL
//
//========================================================================
//sub SaveSQL(aFilename : alpha(4096); aName : alpha; aReport : alpha;) : logic;
sub SaveSQL(aName : alpha; aReport : alpha;) : logic;
local begin
  vI        : int;
  vBuf      : int;
  vXMLName  : alpha(4096);
  vPDFName  : alpha(4096);
end;
begin
  if (gSQLBuffer=0) then
    gSQLBuffer # CteOpen(_CteTreeCI);

  vI # CteRead(gSQLBuffer, _CteFirst | _CteSearch,0, 'SCRIPT');
  if (vI<=0) then begin
    CteClear(gSQLBuffer, y);
    CteClose(gSQLBuffer);
    gSQLBuffer # 0;
    RETURN false;
  end;

  vBuf # vI->spID;


  vXMLname # c_Path+'\'+gUsername+'\todo\test.xml';
  vPDFname # c_Path+'\'+gUsername+'\test\'+aName+'.pdf';
  FsiDelete(vXMLName);
  FsiDelete(vPDFName);

  //_SaveListParameter(aFilename, 'Coole C16-Liste', 'DSN=sc_32;UID=su;PWD=VIB', 'List899001', 'out', gSQLBuffer, vBuf);
//  _SaveListParameter(Set.Druckerpfad, aName, 'DSN=sc_32;UID=su;PWD=VIB', aReport, '', gSQLBuffer, vBuf);
  _SaveListParameter(vXMLname, aName, c_ConString, aReport, '', gSQLBuffer, vBuf);

  // Aufräumen
  CteClear(gSQLBuffer, y);
  CteClose(gSQLBuffer);
  gSQLBuffer # 0;
  MemFree(vBuf);


  // auf PDF warten...
  vI # 0;
  WHILE (Lib_FileIO:FileExists(vPDFName)=false) and (vI<c_Timeout*2) do begin
    Winsleep(500);
    inc(vI);
  END;

  if (vI>=c_Timeout*2) then begin
    Msg(99,'Dauert komisch lange!',0,0,0);
    RETURN true;
  end;

  SysExecute('*'+vPDFName,'',_ExecMaximized);
//  Msg(999998,'',0,0,0);

end;
/*
//========================================================================
//  RunList
//
//========================================================================
sub RunList(aPara : alpha(4096);) : logic;
local begin
  vErg  : int;
end;
begin
  //FsiPathChange('C:\Repository\FormTest\FormTestViewer\bin\Debug\');
  FsiPathChange(Set.FormViewer.Pfad);
  vErg # SysExecute(Set.FormViewer.Pfad + Set.FormViewer.Exe, Set.FormViewer.Xml + aPara, _ExecWait | _ExecMaximized);
  if(vErg <> _rOK) then begin
    Msg(99, 'Programm ' + Set.FormViewer.Pfad + Set.FormViewer.Exe + ' ' + Set.FormViewer.Xml + aPara + ' kann nicht gefunden/gestartet werden.', _WinIcoError, _WinDialogOK, 0);
  end;

  //todo('Erg ' + AInt(vErg));
end;
*/

//========================================================================
//========================================================================
sub DeletePrintFiles(aFilename : alpha);
begin
  if (StrCut(aFilename,StrLen(aFilename)-3,1)='.') then aFilename # Strcut(aFilename,1,StrLen(aFilename)-4);

  try begin // 17.03.2015
    ErrTryIgnore( _ErrFsiNoFile );
    FSIDelete(aFilename+'.XML');
    FSIDelete(aFilename+'.DOC');
    FSIDelete(aFilename+'.DOCX');
    FSIDelete(aFilename+'.TXT');
    FSIDelete(aFilename+'.PDF');
  end;

end;


//========================================================================
//========================================================================
sub _WaitForSync() : logic;
local begin
  vBI   : bigint;
  vC    : int;
  vA    : alpha;
  vErg  : int;
end;
begin
  // 04.04.2018: AH REDDO
  // erst STATUS vom SOA prüfen (OK oder Error)
  // wenn STATUS OK, dann prüfen, dass keine PTD aus VERGANGENHEIT offen sind

  if (RmtDataRead('SOA_SYNC_STATUS', _recunlock, var vA)<>_rOK) or (vA<>'OK') then begin
    if (gUsergroup<>'JOB-SERVER') AND ((gUsergroup =*^'SOA*')=false) then
      Msg(99,'Druck konnte NICHT gestartet werden!'+StrChar(13)+'Result: Sync läuft nicht!',0,0,0);
    RETURN false;
  end;

  vBI->vmServerTime();    // JETZT merken

  vErg # RecRead(992,1,_recFirst);
  if (verg>_rLocked) then RETURN true;

  vC # 0;
  WHILE (Ptd.Sync.TimeStamp<vBI) do begin
    inc(vC);
    Winsleep(250);
    vErg # RecRead(992,1,_recFirst);
    if (verg>_rLocked) then RETURN true;

    if (vC>4*10) then begin
      if (gUsergroup='JOB-SERVER') OR (gUsergroup =*^'SOA*') then RETURN false;
      if (Msg(99,'Die Synchronisation steht noch aus. Weiter warten?',_WinIcoQuestion,_WinDialogYesNo, 1)<>_WinIdyes) then RETURN false;
      vC # 0;
    end;
  END;

  RETURN true;
/***
  GV.Sys.UserID # gUserID;
  WHILE (RecLinkInfo(992,999,10,_recCount)<>0) do begin

    vBI # Org_Data:GetAliveDelta('SYNC');
    if (vBI<0) or (vBI>5) then begin                  // 2 Sekunden Timeout beim SOA
      if (gUsergroup='JOB-SERVER') then RETURN false;
      Msg(99,'Druck konnte NICHT gestartet werden!'+StrChar(13)+'Result: Sync fehlt',0,0,0);
      RETURN false;
    end;

    inc(vC);
    if (vC>4*10) then begin
      if (gUsergroup='JOB-SERVER') then RETURN false;
      if (Msg(99,'Die Synchronisation steht noch aus. Weiter warten?',_WinIcoQuestion,_WinDialogYesNo, 1)<>_WinIdyes) then RETURN false;
      vC # 0;
    end;

    Winsleep(250);
  END;

  RETURN true;
***/
end;


//========================================================================
//========================================================================
sub WaitForSyncDatei(aDatei : int) : logic;
local begin
  vBI   : bigint;
  vC    : int;
  vMax  : int;
end;
begin

  vMax # 4*10;
  if (gUsergroup='JOB-SERVER') or (gUsergroup =*^'SOA*') then vMax # 10*10;

  RecBufClear(992);
  Ptd.Sync.Datei # aDatei;
  WHILE (RecRead(992,3,_recTest)<=_rMultikey) do begin
//debug('warte...');
    vBI # Org_Data:GetAliveDelta('SYNC');
    if (vBI<0) or (vBI>5) then begin                  // 5 Sekunden Timeout beim SOA
      RETURN false;
    end;

    inc(vC);
    if (vC>vMax) then begin
      RETURN false;
    end;

    Winsleep(250);
  END;

  RETURN true;
end;


//========================================================================
//========================================================================
sub CreateShowPDF(
  aName           : alpha;
  aForm           : alpha(1000);
  aBackgroundPic  : alpha(1000);
  aMark           : alpha(1000);
  aRecipient      : alpha(1000);
//  aPara           : alpha(4000);
  aParaHandle     : handle;
  aDMSName        : alpha(4000);
  opt aOnlyCreate : logic;
  opt aSubject    : alpha(1000);
  opt aNoDel      : logic;
  opt aMustEMA    : alpha(4000);
  ) : alpha;
local begin
  vFilename       : alpha(1000);
  vEMA            : alpha(4000);
  vFAX            : alpha(1000);
  vSprache        : alpha(1000);
  vResults        : alpha(4000);
  vFile           : int;
  vA              : alpha;
  vI              : int;
  vArc            : logic;
  vErr            : alpha(1000);
  vDesignmode     : logic;
  vHdl            : int;
  vSplash         : int;
  vWinBonus       : int;
  vOutputtype     : alpha;
  vWaitFor        : alpha;
  vTim            : time;
  v912            : int;

  // Für Umstellung Ablage auf lokaler Platte
  vIsMemDb        : logic;
  vLocalFilename  : alpha(4096);
  vPrintId        : alpha;

  vIsForm       : logic;
  vPrinter      :  int;
end;
begin

//Log('gUsergroup: ' + gUsergroup);

  vTim # now;

  vIsForm # (StrFind(StrCnv(aForm,_StrLower),'reports\',1) = 0);
  //vFilename # Userinfo(_UserCurrent)+'_'+cnvat(vTim, _FmtTimeNoMinutes)+'_'+cnvat(vTim, _FmtTimeNoHOurs)+'_'+cnvat(vtim, _FmtTimeNoMinutes|_FmtTimeNoHOurs|_FmtTimeSeconds);
  vFilename # Userinfo(_UserCurrent)+'_'+cnvai(vTim->vpHours)+'_'+cnvai(vTim->vpMinutes)+'_'+cnvai(vTim->vpSeconds);
  vPrintId   # vFilename; // ID für MemDB Serviceaufruf

/* 06.06.2016 AH: kein Filesystem mehr
  if (Set.SQL.PrintSRVPath='') then begin
    vFilename # c_PathPDF+vFilename;
  end
  else begin
    if ( StrFind(StrCnv( DbaName( _dbaAreaAlias ), _strUpper ),'TESTSYSTEM',1) > 0) then
      vFilename # Set.SQL.PrintSRVPath+'_TESTSYSTEM\PDF\'+vFilename
    else
      vFilename # Set.SQL.PrintSRVPath+'\PDF\'+vFilename;
  end;
*/

//    vFilename # Set.SQL.PrintSRVPath+Userinfo(_UserCurrent);
  aForm # Set.SQL.PrintSRVPath+'\FRX\'+aForm;
  if (aBackgroundpic<>'') then
    aBackgroundPic  # Set.SQL.PrintSRVPath+'\FRX\'+aBackgroundPic;

// 06.06.2016  DeletePrintFiles(vFilename);

  // Standardvorbelegung
  vOutputtype # 'MEMDB_PDF';
  // MEMBM_*  kann genutzt werden um das Dateisystem zu umgehen
  if (gBCPS_Outputtype<>'') then
    vOutputtype # gBCPS_Outputtype;
  if      (vOutputType='PDF')  OR (vOutputType='MEMDB_PDF')  then vWaitFor # 'PDF';
  else if (vOutputType='DOC1') OR (vOutputType='MEMDB_DOC1') then vWaitFor # 'DOCX';
  else if (vOutputType='DOC2') OR (vOutputType='MEMDB_DOC2') then vWaitFor # 'DOCX';
  else if (vOutputType='XML')  OR (vOutputType='MEMDB_XML')  then vWaitFor # 'XML';

  if (StrFind(StrCnv(vOutputtype,_StrUpper),'MEMDB',1) > 0) then
    vIsMemDb    # true;
//  Log('C');
  // 19.05.2016 AH: Druck erst starten wenn EIGENER Sync erledigt ist
  if (Set.SQL.SoaYN) then begin
    if (_WaitForSync()=false) then RETURN '';
  end;
  //Log('C');

  vErr # 'X';
  // Erst Designer LOKAL?
  if c_programmer then begin
    vDesignmode # y;
    vFilename   # '';
//    vErr # Lib_DotNetServices:StartPDF('AUTO', aName, aForm, '', vOutputtype, aBackgroundPic, aMark, aRecipient, aParaHandle);
  end
  // dann Druck LOKAL?
  else begin
    vDesignmode # n;
//    vErr # Lib_DotNetServices:StartPDF('AUTO', aName, aForm, vFileName, vOutputtype, aBackgroundPic, aMark, aRecipient, aParaHandle);
  end;
  vErr # Lib_DotNetServices:StartPDF(aName, aForm, vFileName, vOutputtype, aBackgroundPic, aMark, aRecipient, aParaHandle);

  // sonst Druck auf Server...
//  if (vErr<>'OK') then begin
//    vDesignmode # n;
//    vServerUrlForDocDownload  # Lib_DotNetServices:ServerURL();
//    vErr # Lib_DotNetServices:StartPDF(Lib_DotNetServices:ServerURL() , aName, aForm, vFilename, vOutputtype, aBackgroundPic, aMark, aRecipient, aParaHandle);
//  end;
  if (vErr<>'OK') then begin
    //if (Lib_SQL:StartPDF('AUFBEST',aint(Auf.nummer))=false) then begin
//Log('C ERR');
    if (gUserGroup <> 'JOB-SERVER') AND (gUsergroup =*^'SOA*') then
      Msg(99,'Druck konnte NICHT gestartet werden!'+StrChar(13)+'Result: '+vErr,0,0,0);
    else
      Error(99,'Druck konnte NICHT gestartet werden!'+StrChar(13)+'Result: '+vErr);
    RETURN '';
  end;


  // während Design keie Weiterbearbeitung
  if (vDesignmode) then RETURN 'OK';

//Log('C');
  if (c_PerJobber=false) AND (gUsergroup <> 'JOB-SERVER') AND (gUsergroup <> 'SOA_SERVER') then
    vSplash # WinOpen('Frame.Printing',_WinOpenDialog);

@ifdef Log
debugstamp('start splash');
@endif

  if (vSplash<>0) then begin
//Log('C');
    // Splash-Screen anpassen
    vHdl # Winsearch(vSplash,'lb.printstatus');
    // Fensterdaten sichern
    vWinBonus # Varinfo(WindowBonus);
    vHdl-> wpCustom  # Aint(vWinBonus);
    vHdl-> wpCaption # 'Druck wird aufgebaut...';
    // Splash-Screen anzeigen
    // 06.03.2019 mit TRY
    try begin
      ErrTryCatch(_ErrValueInvalid,y);
      vSplash -> WinDialogRun(_WinDialogAsync | _WinDialogCenter, gFrmMain);
    end;
    if (ErrGet() != _ErrOk) then begin
      ErrSet(_rOK);
      vSplash # 0;
    end;
  end;

  if (c_PerJobber) then begin
    v912 # RekSave(912);
    Lib_Jobber:PrintOrder(vFileName, vWaitfor, v912, aDMSName, gBCPS_Outputfile, aOnlycreate);
    gBCPS_OutputType # '';
    gBCPS_Outputfile # '';

    if (vSplash != 0) then begin
      vSplash->WinClose();
      // Fensterdaten Restore
      VarInstance(WindowBonus,vWinBonus);
    end;
    DbaLog(_LogInfo, N, ThisLine);
    RETURN 'OK';
  end;

@ifdef Log
debugstamp('start waitfor');
@endif

  if (vIsMemDb) then begin
    vFilename # lib_Strings:Strings_Win2Dos(SysGetEnv('TEMP'))+ '\'+vPrintId;    // Zielpfad für Speicherung der Daten
//Log('C');

    if (Lib_ODBC:GetTempDok(vPrintID,vFilename,vWaitfor, var vFax, var vEma, var vSprache, var vResults, true, vSplash) = false) then begin
//Log('C');
      if (vSplash > 0) then
        vSplash->WinClose();

      // Timeout oder Fehler
      if (ErrList<>0) then
        ErrorOutput;
      else
        msg(002001,'Keine Datei erhalten',_WinIcoWarning,1,1);

      RETURN vFilename+'.'+vWaitFor;
    end;
  end
  else begin
    // Wait for file...
    vI # 0;
    REPEAT
      vFile # FsiOpen(vFilename+'.'+vWaitFor, _FSISTdRead);//_FsiAcsR|_FSiDenynone);
      if (vFile<0) then begin
        inc(vI);
        Winsleep(100);
      end;
    UNTIl (vFile>0) or (vI>=c_TimeOut*10);
    FsiCLose(vFile);
  end;

@ifdef Log
debugstamp('stop waitfor');
@endif

  if (vSplash != 0) then begin
    vSplash->WinClose();
    // Fensterdaten Restore
    VarInstance(WindowBonus,vWinBonus);
  end;

  if (aOnlyCreate) then begin
    vArc # Frm.SpeichernYN;
    if (vSprache='') then vSprache  # 'D';
  //  if (aArcFrage) then begin
  //    if (Msg(912008,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdyes) then vArc # y;
  //  end;

    // Archivieren
    if (vArc) and (vWaitFor='PDF') then begin
      // ST 2015-08-04: Alte Version -> löscht Importdaten
      //Lib_Dokumente:ImportPDF(vFilename+'.'+vWaitFor, Frm.Bereich, Frm.Name, aDMSName, vSprache, vFAX, vEMA, false);
      // Neue Version: Löscht die Daten nicht
      Lib_Dokumente:ImportPDF(vFilename+'.'+vWaitFor, Frm.Bereich, Frm.Name, aDMSName, vSprache, vFAX, vEMA, true);
    end;

    gBCPS_OutputType # '';
    gBCPS_Outputfile # '';

    RETURN (vFilename+'.PDF');
  end;

  // Read Metadata...

@ifdef Log
debugstamp('isMemDb');
@endif
//Log('C');

  if (vIsMemDb = false) then begin

    vFile # FsiOpen(vFilename+'.TXT', _FSISTdRead);//_FsiAcsR|_FSiDenynone);
    if (vFile>0) then begin
      FSIMark(vFile, 10);
      FSIRead(vFile, vA);
      WHILE (vA<>'') do begin
        vA # Str_Token(vA,StrChar(13),1);
  //      if (StrCut(vA,1,5)='C16NAME:') then   vName # Str_Token(vA, ':', 2);
        if (StrCut(vA,1,4)='FAX:') then       vFAX # Str_Token(vA, ':', 2);
        if (StrCut(vA,1,6)='EMAIL:') then     vEMA # Str_Token(vA, ':', 2);
        if (StrCut(vA,1,9)='LANGUAGE:') then  vSprache # Str_Token(vA, ':', 2);
        FSIRead(vFile, vA);
      END;
      FSIClose(vFile);
    end;

  end;

//Log('C');

  // KOPIEREN
  if (gBCPS_Outputfile<>'') then begin
@ifdef Log
debugstamp('FSIcopy');
@endif
    Lib_FileIO:FSICopy(vFilename+'.'+vWaitFor, gBCPS_Outputfile, false);
    Sysexecute('*'+gBCPS_Outputfile, '', _ExecMaximized);
  end;

  if (aMustEMA<>'') then vEMA # aMustEMA; // 23.10.2018 AH
  if (StrLen(vEMA)<3) then vEMA # '';     // 23.02.2021 AH

  vArc # Frm.SpeichernYN;
  if (vSprache='') then vSprache  # 'D';
  if (vWaitFor='PDF') then begin

    // ST 2017-12-21: Hier ggf. eingestellten Drucker lesen?
    vPrinter # -1; // -1 = Standarddrucker
    if (Frm.Drucker <> '') then begin
      vPrinter # PrtDeviceOpen(Frm.Drucker,_PrtDeviceSystem);
      if (vPrinter <= 0) then
        vPrinter # -1; // Im Fehlerfall Standarddrucker nutzen
    end;

//Log('C');
@ifdef Log
debugstamp('start preview');
@endif
    Dlg_PDFPreview:ShowPDF(vFilename+'.'+vWaitFor,vIsForm,vEMA, vFAX, vPrinter , 1, aSubject);
  end;


//  if (aArcFrage) then begin
//    if (Msg(912008,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdyes) then vArc # y;
//  end;

//Log('C');
// Archivieren
  if (vArc) and (vWaitFor='PDF') then begin
//Log('C1');
//    Lib_Dokumente:InsertDok_NEW(Frm.Bereich, Frm.Name, vFilename+'.PDF', vSprache, vFAX, vEMA);
    Lib_Dokumente:ImportPDF(vFilename+'.'+vWaitFor, Frm.Bereich, Frm.Name, aDMSName, vSprache, vFAX, vEMA, aNoDel);
  end;
//Log('C');
  // alles löschen
// 06.06.2016  DeletePrintFiles(vFilename);
  RETURN vFilename+'.'+vWaitFor;
end;


//========================================================================
//
//========================================================================
sub CreateXML(
  aName           : alpha;
  aForm           : alpha(1000);
//  aPara           : alpha(4000);
  aParaHandle     : handle;
  aXMLFile        : alpha(4000)) : logic;

local begin
  vFilename       : alpha(1000);
  vEMA            : alpha(1000);
  vFAX            : alpha(1000);
  vSprache        : alpha(1000);
  vResults        : alpha(4000);
  vFile           : int;
  vA              : alpha;
  vI              : int;
  vArc            : logic;
  vErr            : alpha(1000);
  vDesignmode     : logic;
  vHdl            : int;
  vSplash         : int;
  vWinBonus       : int;
  vWaitFor        : alpha;
  vPrintID        : alpha;
  vTim            : time;
end;
begin

  vTim # now;
//  vFilename # Userinfo(_UserCurrent)+'_'+cnvat(vTim, _FmtTimeNoMinutes)+'_'+cnvat(vTim, _FmtTimeNoHOurs)+'_'+cnvat(vtim, _FmtTimeNoMinutes|_FmtTimeNoHOurs|_FmtTimeSeconds);
  vFilename # Userinfo(_UserCurrent)+'_'+cnvai(vTim->vpHours)+'_'+cnvai(vTim->vpMinutes)+'_'+cnvai(vTim->vpSeconds);

  vPrintID # vFileName;

  aForm # Set.SQL.PrintSRVPath+'\FRX\'+aForm;

  // 19.05.2016 AH: Druck erst starten wenn EIGENER Sync erledigt ist
  if (Set.SQL.SoaYN) then begin
    if (_WaitForSync()=false) then RETURN true;
  end;


  vErr # 'X';
  // Erst Designer LOKAL?
  if c_programmer then begin
    vDesignmode # y;
    vFilename   # '';
//    vErr # Lib_DotNetServices:StartPDF(Lib_DotNetServices:LocalURL(), aName, aForm, '', 'MEMDB_XML', '', '', '', aParaHandle);
  end
  // dann Druck LOKAL?
  else begin
    vDesignmode # n;
//    vErr # Lib_DotNetServices:StartPDF(Lib_DotNetServices:LocalURL(), aName, aForm, vFilename, 'MEMDB_XML', '', '', '', aParaHandle);
  end;
  // sonst Druck auf Server...
//  if (vErr<>'OK') then begin
//    vDesignmode # n;
//    vErr # Lib_DotNetServices:StartPDF(Lib_DotNetServices:ServerURL() , aName, aForm, vFilename, 'MEMDB_XML', '', '','', aParaHandle)
//  end;
  vErr # Lib_DotNetServices:StartPDF(aName, aForm, vFilename, 'MEMDB_XML', '', '','', aParaHandle)

  if (vErr<>'OK') then begin
    Msg(99,'Druck konnte NICHT gestartet werden!'+StrChar(13)+'Result: '+vErr,0,0,0);
    RETURN false;
  end;


  // während Design keie Weiterbearbeitung
  if (vDesignmode) then RETURN true;


  if (c_PerJobber=false) AND ( (gUsergroup <> 'SOA_SERVER') AND ((gUsergroup <> 'JOB-SERVER')) )then
    vSplash # WinOpen('Frame.Printing',_WinOpenDialog);
  if (vSplash<>0) then begin
    // Splash-Screen anpassen
    vHdl # Winsearch(vSplash,'lb.printstatus');
    // Fensterdaten sichern
    vWinBonus # Varinfo(WindowBonus);
    vHdl-> wpCustom  # Aint(vWinBonus);
    vHdl-> wpCaption # 'Druck wird aufgebaut...';
    // Splash-Screen anzeigen
    vSplash -> WinDialogRun(
      _WinDialogAsync |
      _WinDialogCenter,
      gFrmMain);
  end;


  vWaitFor  # 'XML';
  vFilename # FsiSplitName(aXMLFile,_FSINamePn);

// ST Umstellung auf Download
//  if (Lib_ODBC:GetTempDok(vPrintID, vFilename, vWaitfor, var vFax, var vEma, var vSprache, var vResults, true) = false) then begin
  winsleep(500);
  
  if (Lib_ODBC:GetTempDok(vPrintID, vFilename, vWaitfor, var vFax, var vEma, var vSprache, var vResults, true, vSplash) = false) then begin
    vSplash->WinClose();

    // Timeout oder Fehler
    if (ErrList<>0) then
      ErrorOutput;
    else
      msg(002001,'Keine Datei erhalten',_WinIcoWarning,1,1);
    RETURN true;
  end;


  if (vSplash != 0) then begin
    vSplash->WinClose();
    // Fensterdaten Restore
    VarInstance(WindowBonus,vWinBonus);
  end;

end;



//========================================================================
//
//========================================================================
sub CreatePDF(
  aName           : alpha;
  aForm           : alpha(1000);
  aParaHandle     : handle;
  aPdfFile        : alpha(4000)) : logic;

local begin
  vFilename       : alpha(1000);
  vEMA            : alpha(1000);
  vFAX            : alpha(1000);
  vSprache        : alpha(1000);
  vResults        : alpha(4000);
  vFile           : int;
  vA              : alpha;
  vI              : int;
  vArc            : logic;
  vErr            : alpha(1000);
  vDesignmode     : logic;
  vHdl            : int;
  vSplash         : int;
  vWinBonus       : int;
  vWaitFor        : alpha;
  vPrintID        : alpha;
  vTim            : time;
end;
begin

  vTim # now;
  vFilename # Userinfo(_UserCurrent)+'_'+cnvai(vTim->vpHours)+'_'+cnvai(vTim->vpMinutes)+'_'+cnvai(vTim->vpSeconds);

  vPrintID # vFileName;

  aForm # Set.SQL.PrintSRVPath+'\FRX\'+aForm;

  // 19.05.2016 AH: Druck erst starten wenn EIGENER Sync erledigt ist
  if (Set.SQL.SoaYN) then begin
    if (_WaitForSync()=false) then RETURN true;
  end;

  vErr # 'X';
  // Erst Designer LOKAL?
  if c_programmer then begin
    vDesignmode # y;
    vFilename   # '';
  end
  // dann Druck LOKAL?
  else begin
    vDesignmode # n;
  end;
  // sonst Druck auf Server...
  vErr # Lib_DotNetServices:StartPDF(aName, aForm, vFilename, 'MEMDB_PDF', '', '','', aParaHandle)

  if (vErr<>'OK') then begin
    Msg(99,'Druck konnte NICHT gestartet werden!'+StrChar(13)+'Result: '+vErr,0,0,0);
    RETURN false;
  end;


  // während Design keie Weiterbearbeitung
  if (vDesignmode) then RETURN true;


  if (c_PerJobber=false) AND ( (gUsergroup <> 'SOA_SERVER') AND ((gUsergroup <> 'JOB-SERVER')) )then
    vSplash # WinOpen('Frame.Printing',_WinOpenDialog);
  if (vSplash<>0) then begin
    // Splash-Screen anpassen
    vHdl # Winsearch(vSplash,'lb.printstatus');
    // Fensterdaten sichern
    vWinBonus # Varinfo(WindowBonus);
    vHdl-> wpCustom  # Aint(vWinBonus);
    vHdl-> wpCaption # 'Druck wird aufgebaut...';
    // Splash-Screen anzeigen
    vSplash -> WinDialogRun(
      _WinDialogAsync |
      _WinDialogCenter,
      gFrmMain);
  end;

  vWaitFor  # 'PDF';
  vFilename # FsiSplitName(aPdfFile,_FSINamePn);

// ST Umstellung auf Download
//  if (Lib_ODBC:GetTempDok(vPrintID, vFilename, vWaitfor, var vFax, var vEma, var vSprache, var vResults, true) = false) then begin
  if (Lib_ODBC:GetTempDok(vPrintID, vFilename, vWaitfor, var vFax, var vEma, var vSprache, var vResults, true, vSplash) = false) then begin
    vSplash->WinClose();

    // Timeout oder Fehler
    if (ErrList<>0) then
      ErrorOutput;
    else
      msg(002001,'Keine Datei erhalten',_WinIcoWarning,1,1);
    RETURN true;
  end;


  if (vSplash != 0) then begin
    vSplash->WinClose();
    // Fensterdaten Restore
    VarInstance(WindowBonus,vWinBonus);
  end;

end;


/***
//========================================================================
//
//========================================================================
sub CreateXML(
  aName           : alpha;
  aForm           : alpha(1000);
//  aPara           : alpha(4000);
  aParaHandle     : handle;
  aXMLFile        : alpha(4000)) : logic;
local begin
  vFilename       : alpha(1000);
  vEMA            : alpha(1000);
  vFAX            : alpha(1000);
  vSprache        : alpha(1000);
  vFile           : int;
  vA              : alpha;
  vI              : int;
  vArc            : logic;
  vErr            : alpha(1000);
  vDesignmode     : logic;
  vHdl            : int;
  vSplash         : int;
  vWinBonus       : int;
  vWaitFor        : alpha;
  vPrintID        : alpha;
end;
begin

  vPrintID # Userinfo(_UserCurrent);

  if (Set.SQL.PrintSRVPath='') then
    vFilename # c_PathPDF+Userinfo(_UserCurrent)
  else begin
    vFilename # Set.SQL.PrintSRVPath+'\PDF\'+Userinfo(_UserCurrent);
    if ( StrFind(StrCnv( DbaName( _dbaAreaAlias ), _strUpper ),'TESTSYSTEM',1) > 0) then
      vFilename # Set.SQL.PrintSRVPath+'_TESTSYSTEM\PDF\'+Userinfo(_UserCurrent);
  end;

//    vFilename # Set.SQL.PrintSRVPath+Userinfo(_UserCurrent);
  aForm # Set.SQL.PrintSRVPath+'\FRX\'+aForm;

  DeletePrintFiles(vFilename);

  // 19.05.2016 AH: Druck erst starten wenn EIGENER Sync erledigt ist
  if (Set.SQL.SoaYN) then begin
    if (_WaitForSync()=false) then RETURN true;
  end;


  vErr # 'X';
  // Erst Designer LOKAL?
  if c_programmer then begin
    vDesignmode # y;
    vErr # UseService_StartPDF(LocalURL(), aName, aForm, '', 'PDF,MEMDB_XML', '', '', '', aParaHandle);
  end
  // dann Druck LOKAL?
  else begin
    vDesignmode # n;
    vErr # UseService_StartPDF(LocalURL(), aName, aForm, vFilename, 'PDF,MEMDB_XML', '', '', '', aParaHandle);
  end;
  // sonst Druck auf Server...
  if (vErr<>'OK') then begin
    vDesignmode # n;
    vErr # UseService_StartPDF(Set.SQL.PrintSrvURL , aName, aForm, vFilename, 'PDF,MEMDB_XML', '', '','', aParaHandle)
  end;
  if (vErr<>'OK') then begin
    //if (Lib_SQL:StartPDF('AUFBEST',aint(Auf.nummer))=false) then begin
    Msg(99,'Druck konnte NICHT gestartet werden!'+StrChar(13)+'Result: '+vErr,0,0,0);
    RETURN false;
  end;



  // während Design keie Weiterbearbeitung
  if (vDesignmode) then RETURN true;


  vSplash # WinOpen('Frame.Printing',_WinOpenDialog);
  // Splash-Screen anpassen
  vHdl # Winsearch(vSplash,'lb.printstatus');

  // Fensterdaten sichern
  vWinBonus # Varinfo(WindowBonus);
  vHdl-> wpCustom  # Aint(vWinBonus);
  vHdl-> wpCaption # 'Druck wird aufgebaut...';
//    vHDL->wpCaption # 'Druckvorschau wird angezeigt...';

  // Splash-Screen anzeigen
  vSplash -> WinDialogRun(
    _WinDialogAsync |
    _WinDialogCenter,
    gFrmMain);



//  vFilename # lib_Strings:Strings_Win2Dos(SysGetEnv('TEMP')+ '\'+vPrintId;    // Zielpfad für Speicherung der Daten
  vWaitFor # 'XML';
  vFilename # FsiSplitName(aXMLFile,_FSINamePn);
  if (Lib_ODBC:GetTempDok(vPrintID,vFilename,vWaitfor, var vFax, var vEma, var vSprache, true) = false) then begin
    vSplash->WinClose();
    // Timeout oder Fehler
    if (ErrList<>0) then
      ErrorOutput;
    else
      msg(002001,'Keine Datei erhalten',_WinIcoWarning,1,1);
    RETURN true;
  end;

/***
  // Read Metadata...
  REPEAT
    vFile # FsiOpen(vFilename+'.XML', _FSISTdRead);//_FsiAcsR|_FSiDenynone);
    if (vFile<0) then begin
      inc(vI);
      Winsleep(100);
    end;
  UNTIl (vFile>0) or (vI>=c_Timeout*10);
  FSIclose(vFile);
***/


  if (vSplash != 0) then begin
    vSplash->WinClose();
    // Fensterdaten Restore
    VarInstance(WindowBonus,vWinBonus);
  end;
/***
  // KOPIEREN
  Lib_FileIO:FSICopy(vFilename+'.XML', aXMLFile, false);


  // alles löschen
  DeletePrintFiles(vFilename);
***/
  RETURN true;
end;
***/


/** obsolete
//========================================================================
//========================================================================
sub DesignPDF(
  aName           : alpha;
  aForm           : alpha(1000);
  aBackgroundPic  : alpha(1000);
  aMark           : alpha(1000);
  aRecipient      : alpha(1000);
//  aPara           : alpha(4000);
  aParaHandle     : handle;
  ) : logic;
local begin
  vErr            : alpha(1000);
end;
begin

  if (gUserGroup='PROGRAMMIERER') then
    vErr # UseService_StartPDF(LocalURL(), aName, aForm, '', 'PDF', aBackgroundPic, aMark, aRecipient, aParaHandle);
  if (vErr<>'OK') then begin
    vErr # UseService_StartPDF(Set.SQL.PrintSrvURL, aName, aForm, '', 'PDF', aBackgroundPic, aMark, aRecipient, aParahandle);
    if (vErr<>'OK') then begin
      Msg(99,'Druck konnte NICHT gestartet werden!'+vErr,0,0,0);
      RETURN false;
    end;
  end;

  RETURN true;
end;
**/


//========================================================================
// Call Lib_SQL:TEST
//========================================================================
sub Test()
local begin
  vErr  : alpha;
end;
begin

//  vErr # CallService_EDI(LocalURL(), 'Wasser');
//  if (vErr<>'OK') then begin
//    vErr # UseService_StartPDF(ServerURL() , aName, aForm, vFilename, vOutputtype, aBackgroundPic, aMark, aRecipient, aParaHandle)
//  end;

todo(vErr);
end;

//========================================================================
