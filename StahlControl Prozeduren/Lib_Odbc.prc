@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Odbc
//                    OHNE E_R_G
//  Info
//
//
//  10.10.2012  AI  Erstellung der Prozedur
//  04.11.2013  AH  neu: Index RecID
//  26.09.2014  AH  Erweiterung für "SyncOne"
//  06.01.2015  ST  "Dickentoleranzen" werden jetzt nicht mehr gesynct
//  18.02.2015  ST  Printserverdruck über Datenbankergebnis Projekt 1326/415
//  15.04.2015  ST  Längere Druckausführung fragt auf "weiterwarten"
//  30.07.2015  AH  Memleak umgehen
//  12.08.2015  AH  sub "OdbcError" für Job-Server etc.
//  09.09.2015  AH  "OdbcError" mit Datei-Parameter
//  12.05.2016  AH  PtdSync
//  23.06.2016  AH  ESC ESC ESC / StrChar(27) als Seperator für 5er Texte
//  22.08.2016  ST  Base64 Konviertierung mit 128MB MemObjekt anstatt 512M
//  20.02.2017  AH  Tabelle CUSTOMFELDER
//  03.03.2017  AH  SYNC mit Datumsabfrage
//  21.04.2017  ST  TabelleCommandQueue 1003 hinzugefügt
//  17.05.2017  ST  "Tablename" ignoriert auf Jobserver Jobs
//  27.06.2017  ST  Listenerstellung per Job-Server fragt nicht nach Wartezeit
//  23.08.2017  AH  "MoveOldNew"
//  06.11.2017  AH  Fix: "Update" kann auch Buffer ohne SoaSync
//  23.02.2018  AH  Codepage für Türksich beim Textwandeln
//  10.04.2018  AH  Neu: Inhaltkoverter für Art_Preise
//  (26.09.2018  AH  Neu: "ReflectTable"-Updates nutzen "OUTPUT 'OK'")
//  02.10.2018  AH  FIX: vom 26.09. wieder deaktiviert
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  05.03.2019  AH  Fix: 837
//  09.01.2020  AH  "GetTempDok" liefert ResultJson
//  03.07.2020  ST  GetTempDok per DownloadService hinzugefügt P1326/585
//  03.07.2020  AH  wenn der SYNC per SOA läuft, darf NUR der zur SQL connecten
//  14.07.2020  AH  Userdatei 800 wird auch in die NET-Benutzer gesynct
//  09.02.2021  ST  Anlageuser für 702 gesycnt
//  15.07.2021  AH  Float nur im Bereich -100000000000 bis 100000000000
//  27.07.2021  AH  ERX
//  21.09.2021  ST  Protokolldaten für Dateibeirech 700 - 711 ergänzt
//  2022-07-14  AH  Timestamp
//  2022-10-26  AH  ALTERTABLE legt neue Tabellen auch direkt an
//  2023-05-17  AH  Bedarfsablage 545 eingebaut
//  2023-06-01  AH  Alpha von 4096 auf 8096 erweitert
//
//  Subprozeduren
//  Sub OdbcError
//  sub GUID(aDatei : int; aRecID : int; aQuotes : logic) : alpha;
//  sub TextGUID(aName : alpha) : alpha;
//  sub FieldName(aDatei : int; aTds : int; aFld : int) : alpha;
//  sub _InitCon() : alpha;
//  sub TermCmds();
//  Sub HandleMemLeak() : alpha
//  sub IsKeyField(aFile : int; aTds : int; aFld : int) : logic;
//  sub TableName(aDatei : int) : alpha;
//  Sub Init() : alpha
//  sub Term() : alpha;
//  sub ReflectTable(aDatei : int; aMode  : alpha) : int;
//  sub FillRecIntoCommand(aDatei : int; aCmd : int; aMode : alpha) : logic;
//  sub Execute(aDatei : int; aCmd : int; opt aCheckOK) : int
//  sub Insert(aDatei : int; opt aRecID : int) : logic;
//  sub Update(aDatei    : int) : logic;
//  sub Delete( aDatei : int; aRecId : int) : logic;
//  sub DeleteAll(aDatei : int) : logic;
//  sub TransferStamp() : logic;
//  sub IsStampOK() : logic;
//  sub ExecuteScript(aTxt : int; aName : alpha) : logic
//  sub InsertText(aName : alpha; opt aName2 : alpha) : logic;
//  sub CreateText(aName : alpha) : logic;
//  sub DeleteText(aName : alpha) : logic;
//  sub RenameText(aName : alpha; aName2 : alpha) : logic;
//  sub InsertAll(aDatei : int; aDat : date; opt aHdl : int) : logic;
//  sub CreateTable(aDatei : int) : alpha;
//  sub FirstScript(opt aSilent : logic) : logic;
//  sub FirstSync(opt aSilent : logic) : logic;
//  sub ScriptOneTable(aDatei : int; opt aSilent : logic) : logic;
//  sub SyncOneTable(aDatei : int; opt aSilent : logic) : logic;
//  sub GetTempDok(aPrintJobId : alpha; aPath : alpha; aExtention : alpha; var aFax : alpha; var aEma : alpha; var aLang : alpha; opt aAskForAdditionaltime : logic) : logic;
//  sub ClearTempDoks(aAuchAusgabeverzeichnis : logic) : logic;
//
//  sub MoveOldNew(aDatei : int) : logic
//
//
//========================================================================
@I:Def_Global

//@Define LogCalls
//@Define DebugCmd

local begin
  gCmd    : handle[999];
end;

define begin
//  cInstance     : 'arcflow2011\sqlexpress'
//  cDB           : '' // 'SYNC_BCS'
//  cUser         : 'xx'
//  cPW           : '123'
  cNurDatei       : 401
  cMaxMem         : 409600
  SQLTimeStamp  : Lib_SQL:SQLTimeStamp
  cMemLeakCount   : 51000//200

  cGrenze         : 100 // Anzahl der CREATE_TABLE Felder pro Command

  cPtdSync        : Set.SQL.SoaYN
  //[Adresse]
end;


declare ClearTempDoks(aAuchAusgabeverzeichnis : logic) : logic;

//========================================================================
//========================================================================
Sub OdbcError(
  aLine   : alpha(1000);
  aText   : alpha(8096);
  aDatei  : int) : logic
local begin
  vText   : alpha(250);
  vA      : alphA(8095);
end;
begin

  // 10.01.2019 AH:
  if (StrFind(aText,'Verletzung der PRIMARY KEY-Einschr',0)>0) then begin
    vA # Str_Token(aText,'Schlüsselwert ist ',2);
    aText # 'Verletzung der PRIMARY KEY-Einschr.:'+vA;
  end;
  

  if (gUsergroup =*^'SOA*') OR (gUserGroup = 'JOB-SERVER') then begin
    vText # StrCut('ODBC|'+aint(aDatei)+'|'+aLine+'|'+aText+'|U:'+gUsername,1,250);
    if (gOdbcLastError=vText) then begin
      RETURN true;
    end;
    gOdbcLastError # vText;
    DbaLog(_LogError, N, vText);
  end
  else begin
//  aText # Lib_Strings:Strings_ReplaceAll(aText, 'KEY','XXX');
    // 24.08.2018 AH
    if (StrFind(aText,'Verletzung der PRIMARY KEY-Einschr',0)>0) then begin
      RETURN false; // KEIN Fehler
    end
    else begin
      Msg(99,'ODBC-Error: ('+aint(aDatei)+')'+aText,0,0,0);
    end;
  end;

  RETURN true;
end;


//========================================================================
//  GUID
//
//========================================================================
sub GUID(
  aDatei  : int;
  aRecID  : int;
  aQuotes : logic) : alpha;
local begin
  vA      : alpha;
  vDatei  : int;
end;
begin
//        123456789012345678901234567890123456
//        0822174F-539B-4967-9684-465AB37CA671 = 36

//  vA # '''0822174F-539B-4967-9684-465A'+cnvai( cnvif(random()*99999999.0) ,_FmtNumLeadZero|_FmtNumNoGroup,0,8)+'''';
//  if (gGuidDLL<>0) then
//    gGuidDll->DllCall(var vA);
//debug(aint(aRecID));
  if (aDatei>10000) then
    aDatei # HdlInfo(aDatei,_HdlSubType);

  vA # '00000000-0C16-0C16-0C16-'+
        cnvai(aDatei,_FmtNumLeadZero|_FmtNumNoGroup|_FmtNumleadzero,0,4)+
        cnvai(aRecID,_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
//        cnvai(RecInfo(aDatei, _RecId),_FmtNumHex,0,8);
//debug(aint(aRecID)+' GUID : '+va);
  if (aQuotes) then RETURN ''''+vA+''''
  else RETURN vA;
end;


//========================================================================
//  Text_GUID
//
//========================================================================
sub TextGUID(
  aName   : alpha) : alpha;
local begin
  vA,vB : alpha;
  vI    : int;
  vBig  : bigint;
end;
begin

//      0822174F-539B-4967-9684-465AB37CA671 = 36

  vBig->vmServerTime();
  vB # Cnvab(vBig, _FmtNumLeadZero | _FmtNumHex, 0, 16);
  vA # '00000000-0C16-'+
      cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadzero,0,4)+'-'+
      StrCut(vB,1,4)+'-'+
      StrCut(vB,5,12);
RETURN vA;


  vA # '00000000-0C16-0C16-'+
    cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadzero,0,4)+'-'+
    cnvai( cnvif(random()*64535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadzero,0,4)+
    cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadzero,0,4)+
    cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadzero,0,4);

//  vA # Str_ReplaceAll(vA,' ','0');
/***
  FOR vI # 1 loop inc(vI) while (vI<=StrLen(aName)) and (StrLen(vB)<8) do begin
    vA # StrCut(aName,vI,1);
    if (vA>='0') and (vA<='9') then vB # vB + vA;
  END;

  vA # '00000000-0C16-0C16-0C16-'+
        cnvai(1000,_FmtNumLeadZero|_FmtNumNoGroup,0,4)+ vB;
***/
//debug('textguid:'+vA);
  RETURN vA;
//  RETURN ''''+vA+'''';
end;


//========================================================================
//  FieldName
//
//========================================================================
sub FieldName(
  aDatei  : int;
  aTds    : int;
  aFld    : int) : alpha;
local begin
  vI    : int;
  vText : alpha;
  vFrom : int;
  vSpez : logic;
end;
begin

//  if ((aDatei=401) or (aDatei=411)) and (aTds=6) and (aFld=8) then RETURN '';
//  if ((aDatei=501) or (aDatei=511)) and (aTds=6) and (aFld=7) then RETURN '';

  if (aDatei>10000) then
    aDatei # HdlInfo(aDatei,_HdlSubType);

  // über ERSTEN Feldnamen prüfen...
  vText # FldName(aDatei, 1, 1);
  vFrom # 1;
  if (aDatei=210) then vFrom # 3+1;
  if (aDatei=410) then vFrom # 3+1;
  if (aDatei=411) then vFrom # 5+1;
  if (aDatei=470) then vFrom # 3+1;
  if (aDatei=510) then vFrom # 3+1;
  if (aDatei=511) then vFrom # 5+1;

//call repair_mat:Mehaktivieren
  FOR vI # vFrom+1 loop inc(vI) WHILE (vI<=StrLen(vText)) do begin
    if (StrCut(vText, vI,1)='.') then vFrom # vI;
  END;

  if (aDatei=892) then vFrom # 5+1;

  // echten Feldnamen nun bestimmen
  vText # FldName(aDatei, aTds, aFld);
//  vSpez # (vText='Prj.P.Anlage.Datum');

  if (vFrom>1) then
    vText # StrCut(vText, vFrom+1, 20);

  // blabla.Anlage.Zeit = 7
/***
  vI # 0;
//  vI # StrFind(vText,'.Anlage.Zei',0);
//  if (vI>0) then
//    vText # StrCut(vText, 1, vI-1) + '_Anlage_Zeit';
  if (vI=0) then begin
    vI # StrFind(vText,'.Anlage.Dat',0);
    if (vI>0) then
      vText # StrCut(vText, 1, vI-1) + '_Anlage_Datum';
  end;
  if (vI=0) then begin
    vI # StrFind(vText,'.Anlage.Use',0);
    if (vI>0) then
      vText # StrCut(vText, 1, vI-1) + '_Anlage_Username';
  end;
***/
  //    (StrFind(vText,'Anlage.Use',0)>0) or
  //    (StrFind(vText,'Anlage.Dat',0)>0) or

  if (vSpez=false) and (
      (StrFind(vText,'Anlage.Zei',0)>0) or
      (StrFind(vText,'Anlage.Use',0)>0) or
      (StrFind(vText,'Anlage.Usr',0)>0) or
      (StrFind(vText,'Anlage.Dat',0)>0) or
      (StrFind(vText,'Änderung.Zeit',0)>0) or
      (StrFind(vText,'Änderung.User',0)>0) or
      (StrFind(vText,'Änderung.Datum',0)>0) or
      (StrFind(vText,'Lösch.Zeit',0)>0) or
//      (StrFind(vText,'Lösch.Grund',0)>0) or
      (StrFind(vText,'Lösch.User',0)>0) or
      (StrFind(vText,'Lösch.Datum',0)>0)) then RETURN '';

  vText # Str_ReplaceAll(vText, '$', 'Dollar');
  vText # Str_ReplaceAll(vText, '%', 'Prozent');
  vText # Str_ReplaceAll(vText, '\', 'Pro');

  vText # Str_ReplaceAll(vText, 'Username', 'Superhorst');
  vText # Str_ReplaceAll(vText, 'User', 'Superhorst');
  vText # Str_ReplaceAll(vText, 'Superhorst', 'Username');

  vText # Str_ReplaceAll(vText, 'ä', 'ae');
  vText # Str_ReplaceAll(vText, 'ö', 'oe');
  vText # Str_ReplaceAll(vText, 'ü', 'ue');
  vText # Str_ReplaceAll(vText, 'Ä', 'Ae');
  vText # Str_ReplaceAll(vText, 'Ö', 'Oe');
  vText # Str_ReplaceAll(vText, 'Ü', 'Ue');
  vText # Str_ReplaceAll(vText, 'ß', 'ss');

  vText # Str_ReplaceAll(vText, '.', '_');
  vText # Str_ReplaceAll(vText, '-', '_');
  vText # Str_ReplaceAll(vText, '!', 'Nicht');

  RETURN '"'+vText+'"';
end;


//========================================================================
//========================================================================
sub _InitCon() : alpha;
local begin
  vDB : alpha(100);
end;
begin


  vDB # Set.SQL.Database;
  //if ( StrFind(StrCnv( DbaName( _dbaAreaAlias ), _strUpper ),'TESTSYSTEM',1) > 0) then begin
  if (isTestsystem) then begin
    vDB # vDB + '_TESTSYSTEM';
  end;

//tDlg->wpConnectionString # 'DSN=CodeLibrary;UID=user;DBQ=c:\db\codelibrary';
//Der Befehl "OdbcConnectDriver" nimmt einen Connect-String entgegen, in dem alle nötigen Informationen übergeben werden können,
// z.B.: OdbcApi->OdbcConnectDriver('driver={SQL Server};server=SERVER\INSTANZ;database=DB_NAME;uid=DB_USER;pwd=PASSWORD').
  if (gOdbcCon=0) then begin
//    gOdbcCON # gOdbcAPI->OdbcConnect(cDB, cUser, cPW);
    gOdbcCon # gOdbcApi->OdbcConnectDriver('driver={SQL Server};server='+Set.SQL.Instance+';database='+vDB+';uid='+Set.SQL.User+';pwd='+Set.SQL.Password);
    //Trusted_Connection=Yes;
//    gOdbcCon # gOdbcApi->OdbcConnectDriver('driver={SQL Native Client};server='+Set.SQL.Instance+';database='+vDB+';uid='+Set.SQL.User+';pwd='+Set.SQL.Password);
    if (gOdbcCON<=0) then begin
      gOdbcCon # 0;
      RETURN 'Unable to connect to database '+vDB+'!'
    end;
  end;

  RETURN '';
end;


//========================================================================
//========================================================================
sub TermCmds();
local begin
  vI  : int;
end;
begin
  // Alte Commands ggf. entfernen...
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=1000) do begin
    if (gOdbcCmdInsert[vI]<>0) then begin
      gOdbcCmdInsert[vI]->OdbcClose();
      gOdbcCmdInsert[vI] # 0;
    end;
  END;

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=1000) do begin
    if (gOdbcCmdUpdate[vI]<>0) then begin
      gOdbcCmdUpdate[vI]->OdbcClose();
      gOdbcCmdUpdate[vI] # 0;
    end;
  END;
end;


//========================================================================
//
//========================================================================
Sub HandleMemLeak(opt aReset : logic) : alpha
local begin
  vErr  : alpha;
end;
begin
  // Memleak umgehen
  inc(gOdbcCounter);

  if (aReset=false) and (gOdbcCounter<cMemLeakCount) then RETURN '';

  gOdbcCounter # 0;

  TermCmds();

  Syssleep(25);
  gOdbcCon->OdbcClose();
  Syssleep(25);

  gOdbcCon # 0;

  vErr # _InitCon();
  RETURN vErr;
//    if (vErr<>'') then begin
//      OdbcError(ThisLine,vErr,aDatei);
//      RETURN false;
//    end;
end;


//========================================================================
//========================================================================
/***
sub Key(aDatei : int) : alpha;
local begin
  vn    : int;
  vX    : int;
  vY    : int;
  vKey  : alpha(3000);
  vName : alpha;
end;
begin


RETURN GUID(aDatei, Recinfo(aDatei,_recID));




  if (aDatei=0) then RETURN '';
  if (FileInfo(aDatei,_FldExists)<1) then RETURN '';

  vKey # '';
  vN # KeyInfo(aDatei, 1, _KeyFldCount);
  FOR vY # 1 loop inc(vY) while (vY<=vN) do begin
    vX # KeyFldInfo(aDatei,1,vY,_KeyFldNumber);

    vName # FieldName(aDatei, 1, vX);

    if (vY>1) then vKey # vKey + ' AND ';
    vKey # vKey + vName + '=';

    case FldInfo(aDatei,1,vX,_KeyFldType) of
      _TypeAlpha  : vKey # vKey + '"' + FldAlpha(aDatei,1,vX)+ '"';
      _TypeWord   : vKey # vKey + CnvAI(FldWord(aDatei,1,vX),_FmtNumNoGroup);
      _TypeInt    : vKey # vKey + CnvAI(FldInt(aDatei,1,vX),_FmtNumNoGroup);
      _TypeFloat  : vKey # vKey + CnvAF(FldFloat(aDatei,1,vX),_FmtNumNoGroup);
      _TypeDate   : vKey # vKey + CnvAD(FldDate(aDatei,1,vX));
      _TypeTime   : vKey # vKey + CnvAT(FldTime(aDatei,1,vX));
      _TypeLogic  : if FldLogic(aDatei,1,vX) then vKey # vKey + '1'
                    else                          vKey # vKey + '0';
    end;

  END;

  RETURN vKey;
end;
***/

//========================================================================
//  IsKeyField
//
//========================================================================
sub IsKeyField(
  aFile   : int;
  aTds    : int;
  aFld    : int) : logic;
local begin
  vN    : int;
  vX,vY : int;
end;
begin

  vN # KeyInfo(aFile, 1, _KeyFldCount);
  FOR vY # 1 loop inc(vY) while (vY<=vN) do begin
    vX # KeyFldInfo(aFile,1,vY,_KeyFldNumber);
    if (aTds=1) and (aFld=vX) then RETURN true;
  END;

  RETURN false;
end;


//========================================================================
//  TableName
//
//========================================================================
sub TableName(aDatei : int) : alpha;
begin

  if (aDatei=1000) then RETURN 'Text';
  if (aDatei=1001) then RETURN 'c16_Version';
  if (aDatei=1002) then RETURN 'TempDokumente';
  if (aDatei=1003) then RETURN 'CommandQueue';

  if (aDatei>10000) then begin
    if (HdlInfo(aDatei,_HdlSubType) = 905) then RETURN '';
aDatei # HdlInfo(aDatei,_HdlSubType);
//    Todo('ODBC_Link for Buffer!['+Aint(aDatei)+'] Dat:'+ Aint(HdlInfo(aDatei,_HdlSubType)) );
//    RETURN '';
  end;

  if (aDatei<=0) or (aDatei>999) then begin
    Todo('ODBC_Link for Buffer!['+Aint(aDatei)+']');
    RETURN '';
  end;


  case aDatei of
    100   : RETURN 'Adresse';
    101   : RETURN 'Adr_Anschrift';
    102   : RETURN 'Adr_Ansprechpartner';
    103   : RETURN 'Adr_Kreditlimit';
    105   : RETURN 'Adr_Verpackung';
    106   : RETURN 'Adr_Vpg_Ausfuehrung';
    107   : RETURN 'Kontaktdaten';
    //109   |Adr_Scripte
    110   : RETURN 'Vertreter';
    111   : RETURN 'Ver_Provision';
    120   : RETURN 'Projekt';
    130   : RETURN 'Lieferantenerklaerung';
    131   : RETURN 'LfE_Struktur';
    121   : RETURN 'Proj_Stueckliste';
    122   : RETURN 'Proj_Position';
    123   : RETURN 'Proj_Zeit';
    160   : RETURN 'Ressource';
    161   : RETURN 'Rso_Zusatztabelle';
    163   : RETURN 'Rso_Kalender';
    164   : RETURN 'Rso_Kal_Tag';
    165   : RETURN 'Rso_Instandhaltung';
    166   : RETURN 'Rso_IHA_Ursache';
    167   : RETURN 'Rso_IHA_Massnahme';
    168   : RETURN 'Rso_IHA_Ersatzteil';
    169   : RETURN 'Rso_IHA_Ressource';
    170   : RETURN 'Rso_Reservierung';
    171   : RETURN 'Rso_R_Verbindung';
    180   : RETURN 'Hilfsstoff';
    181   : RETURN 'HuB_Preis';
    182   : RETURN 'HuB_Journal';
    190   : RETURN 'HuB_Einkauf';
    191   : RETURN 'HuB_EK_Position';
    192   : RETURN 'HuB_EK_Wareneingang';
    200   : RETURN 'Material';
    201   : RETURN 'Mat_Ausfuehrung';
    202   : RETURN 'Mat_Bestandsbuch';
    203   : RETURN 'Mat_Reservierung';
    204   : RETURN 'Mat_Aktion';
    //205 : RETURN ' |Mat.Lagerprotokoll         |Mat.
    210   : RETURN 'Material';//'Materialablage';
    220   : RETURN 'Materialstruktur';
    221   : RETURN 'MSL_Ausfuehrung';
    230   : RETURN 'Analyse';
    231   : RETURN 'Analyse_Position';
    //240   : RETURN 'Dispobestand';    Probleme beim Replace/Insert etc. z.B: bei BAG.IO.Löschen
    250   : RETURN 'Artikel';
    251   : RETURN 'Art_Reservierung';
    252   : RETURN 'Art_Charge';
    253   : RETURN 'Art_Lagerjournal';
    254   : RETURN 'Art_Preis';
    255   : RETURN 'Art_Stueckliste';
    256   : RETURN 'Art_SL_Position';
    257   : RETURN 'Art_Ausfuehrung';
    259   : RETURN 'Art_Inventur';
    280   : RETURN 'Paket';
    281   : RETURN 'Pak_Position';
    300   : RETURN 'Reklamation';
    301   : RETURN 'Rek_Position';
    302   : RETURN 'Rek_Aktion';
    303   : RETURN 'Rek_Charge';
    310   : RETURN 'Rek_8_Text';
    400   : RETURN 'Auftrag';
    401   : RETURN 'Auf_Position';
    402   : RETURN 'Auf_Ausfuehrung';
    403   : RETURN 'Auf_Aufpreis';
    404   : RETURN 'Auf_Aktion';
    404   : RETURN 'Auf_Aktion';
    821   : RETURN 'Abteilung';

    405   : RETURN 'Auf_Kalkulation';
    //406 : RETURN' |Auf_Einteilung
    //407 : RETURN' |Auf_Verpackung
    //408 : RETURN' |Auf_Feinabrufe
    409   : RETURN 'Auf_Stueckliste';
    410   : RETURN 'Auftrag';//'Auftragsablage';
    411   : RETURN 'Auf_Position';//'Auf_Positionsablage';
    440   : RETURN 'Lieferschein';
    441   : RETURN 'Lfs_Position';
    450   : RETURN 'Erloes';
    451   : RETURN 'Erl_Konto';
    460   : RETURN 'OffenerPosten';
    461   : RETURN 'OfP_Zahlung';
    465   : RETURN 'Zahlungseingang';
    470   : RETURN 'OffenerPosten';//|OfP~OffenePosten
    500   : RETURN 'Einkauf';
    501   : RETURN 'Ein_Position';
    502   : RETURN 'Ein_Ausfuehrung';
    503   : RETURN 'Ein_Aufpreis';
    504   : RETURN 'Ein_Aktion';
    505   : RETURN 'Ein_Kalkulation';
    506   : RETURN 'Ein_Wareneingang';
    507   : RETURN 'Ein_E_Ausfuehrung';
    510   : RETURN 'Einkauf';//'Einkaufsablage';
    511   : RETURN 'Ein_Position';//'Ein_Positionsablage';
    540   : RETURN 'Bedarf';
    541   : RETURN 'Bdf_Aktion';
    545   : RETURN' Bedarf';
    550   : RETURN 'Verbindlichkeit';
    551   : RETURN 'Vbk_Konto';
    555   : RETURN 'Einkaufkontrolle';
    558   : RETURN 'Fixkosten';
    560   : RETURN 'Eingangsrechnung';
    561   : RETURN 'ERe_Zahlung';
    565   : RETURN 'Zahlungsausgang';

    570   : RETURN 'Kasse';
    571   : RETURN 'Kassenbuch';
    572   : RETURN 'Kassenbuchposition';

    580   : RETURN 'Kostenkopf';
    581   : RETURN 'Kosten';

    600   : RETURN 'Grobplanung';
    601   : RETURN 'GPl_Position';
    620   : RETURN 'Sammelwareneingang';
    621   : RETURN 'SWe_Position';
    622   : RETURN 'SWe_Pos_Ausfuehrung';
    650   : RETURN 'Versand';
    651   : RETURN 'Vsd_Position';
    655   : RETURN 'Versandpooleintrag';
    //656 : RETURN' |VsP~Versandpool            |
    700   : RETURN 'Betriebsauftrag';
    701   : RETURN 'BAG_InputOutput';
    702   : RETURN 'BAG_Position';
    703   : RETURN 'BAG_Fertigung';
    704   : RETURN 'BAG_Verpackung';
    705   : RETURN 'BAG_Ausfuehrung';
    706   : RETURN 'BAG_Arbeitsschritt';
    707   : RETURN 'BAG_Fertigmeldung';
    708   : RETURN 'BAG_FM_Beistellung';
    709   : RETURN 'BAG_Zeit';
    710   : RETURN 'BAG_FM_Fehler';
    711   : RETURN 'BAG_Positionszusatz';
    800   : RETURN 'c16_Benutzer';
    //801   : RETURN 'Benutzergruppe';
    //802 : RETURN ' |Usr_User<>Gruppen':
    //803 : RETURN ' |Usr_Favorit':
    810   : RETURN 'Gruppe';
    811   : RETURN 'Anrede';
    812   : RETURN 'Land';
    813   : RETURN 'Steuerschluessel';
    814   : RETURN 'Waehrung';
    815   : RETURN 'Lieferbedingung';
    816   : RETURN 'Zahlungsbedingung';
    817   : RETURN 'Versandart';
    818   : RETURN 'Verwiegungsart';
    819   : RETURN 'Warengruppe';
    820   : RETURN 'Materialstatus';
    821   : RETURN 'Abteilung';
    822   : RETURN 'Ressourcengruppe';
    823   : RETURN 'IHA_Meldung';
    824   : RETURN 'IHA_Ursache';
    825   : RETURN 'IHA_Massnahme';
    826   : RETURN 'Artikelgruppe';
    //827 : RETURN ' |Math.Alphabet';
    828   : RETURN 'Arbeitsgang';
    829   : RETURN 'Skizze';
    830   : RETURN 'Kalkulation';
    831   : RETURN 'Kal_Position';
    832   : RETURN 'Guete';
    833   : RETURN 'Guetenmechanik';
    834   : RETURN 'Abmessungstoleranz';
    835   : RETURN 'Auftragsart';
    836   : RETURN 'BDSNummer';
    837   : RETURN 'Textbausteine';
    838   : RETURN 'Unterlage';
    839   : RETURN 'Zeugnis';
    840   : RETURN 'Etikett';
    841   : RETURN 'Oberflaeche';
    842   : RETURN 'Aufpreis';
    843   : RETURN 'Aufpreis_Position';
    844   : RETURN 'Stellplatz';
    //845   : RETURN 'Dickentoleranz';
    846   : RETURN 'Kostenstelle';
    847   : RETURN 'Ort';
    848   : RETURN 'Guetenstufe';
    849   : RETURN 'Reklamationsart';
    850   : RETURN 'Projektstatus';
    851   : RETURN 'Fehlercode';
    852   : RETURN 'Zahlungsart';
    853   : RETURN 'Rechnungstyp';
    854   : RETURN 'Gegenkonto';
    855   : RETURN 'Zeittyp';
    856   : RETURN 'Artikelzustand';
    890   : RETURN 'OnlineStatistik';
    //891 : RETURN ' |OSt_Stack':
    892   : if (DbaLicense(_DbaSrvLicense)='CA150837MN') then RETURN '' // POERSCHKE RAUS
            else RETURN 'OSt_Extended';
    899   : RETURN 'Statistik';
    //900 : RETURN ''
    //901 : RETURN ' |Prg.Keys                   |
    //902 : RETURN ' |Prg.Nummernkreise          |
    //903 : RETURN ' |Prg.Settings               |
    //904 : RETURN ' |Prg.-bersetzung            |
    //905 : RETURN ' |Job.Jobserver              |
    //906 : RETURN ' |Dia.Dialoge                |
    //907 : RETURN ' |Dia.Pflichtfelder          |
    //908 : RETURN ' |Job.Fehlermeldungen        |
    //909 : RETURN ' |FSP.Filescanpfade          |
    //910 : RETURN ' |Lfm.Listenformate          |
    //911 : RETURN ' |Lfm.UserAllowed            |
    //912 : RETURN ' |Frm.Formulare              |
    913   : RETURN 'Druckzonen';
    //915 : RETURN ' |Dok.Dokumente              |
    //916 : RETURN ' |Anh.Anhang                |
    //920 : RETURN ' |Scr.Scripte                |
    //921 : RETURN ' |Scr.Befehle                |
    //922 : RETURN ' |SFX.Sonderfunktion         |
    //923 : RETURN ' |AFX.Ankerfunktion          |
    //924 : RETURN ' |SFX.UserAllowed            |
    //930 : RETURN ' |CUS.Felderpool             |
    931 : RETURN 'Customfeld';
    //932 : RETURN ' |CUS.Auswahlfelder          |
    935 : RETURN 'c16_Dictionary';
    //940 : RETURN ' |WoF.Schema                 |
    //941 : RETURN ' |WoF.Aktivit¦ten            |
    //942 : RETURN ' |WoF.Bedingungen            |
    //950 : RETURN ' |Con.Controlling            |
    //960 : RETURN ' |SOA.Serviceinventar        |
    //961 : RETURN ' |SOA.UsersAllowed           |
    //965 : RETURN ' |SOA.Protokoll              |
    //980 : RETURN ' |TeM.Termine                |
    //981 : RETURN ' |TeM.Anker                  |
    //982 : RETURN ' |TeM.Bericht                |
    //989 : RETURN ' |TeM.Events                 |
    //990 : RETURN ' |PtD.Protokolldatei         |
    //991 : RETURN ' |PtD.Loeschung              |
    //992 : RETURN ' |PtD.Jobserver              |
    //995 : RETURN ' |Log.Changelog              |
    //998 : RETURN ' |Sel.Selektion              |
    //999 : RETURN ' |GV.Global                  |
  end;
  
  RETURN '';
end;


//========================================================================
//========================================================================
sub  _GetAnlage(
  aDatei        : int;
  var aAnlageD  : alpha;
  var aAnlageU  : alpha);
local begin
  vDat          : date;
  vZeit         : time;
end;
begin
  aAnlageD    # 'null';
  aAnlageU    # '';

  case aDatei of
    100 : begin
      vDat      # Adr.Anlage.Datum;
      vZeit     # Adr.Anlage.Zeit;
      aAnlageU  # Adr.Anlage.User;
    end;
    120 : begin
      vDat      # Prj.Anlage.Datum;
      vZeit     # Prj.Anlage.Zeit;
      aAnlageU  # Prj.Anlage.User;
    end;
    122 : begin
      vDat      # Prj.P.Anlage.Datum;
      vZeit     # Prj.P.Anlage.Zeit;
      aAnlageU  # Prj.P.Anlage.User;
    end;
    200 : begin
      vDat      # Mat.Anlage.Datum;
      vZeit     # Mat.Anlage.Zeit;
      aAnlageU  # Mat.Anlage.User;
    end;
    250 : begin
      vDat      # Art.Anlage.Datum;
      vZeit     # Art.Anlage.Zeit;
      aAnlageU  # Art.Anlage.User;
    end;
    280 : begin
      vDat      # Pak.Anlage.Datum;
      vZeit     # Pak.Anlage.Zeit;
      aAnlageU  # Pak.Anlage.User;
    end;
    404 : begin
      vDat      # Auf.A.Anlage.Datum;
      vZeit     # Auf.A.Anlage.Zeit;
      aAnlageU  # Auf.A.Anlage.User;
    end;
    450 : begin
      vDat      # Erl.Anlage.Datum;
      vZeit     # Erl.Anlage.Zeit;
      aAnlageU  # Erl.Anlage.User;
    end;
    // MUSTER auch in "Old_LibTransfers"
    700 : begin
      vDat      # BAG.Anlage.Datum
      vZeit     # BAG.Anlage.Zeit;
      aAnlageU  # BAG.Anlage.User;
    end;
    701 : begin
      vDat      # BAG.IO.Anlage.Datum;
      vZeit     # BAG.IO.Anlage.Zeit;
      aAnlageU  # BAG.IO.Anlage.User;
    end;
    702 : begin
      vDat      # BAG.P.Anlage.Datum;
      vZeit     # BAG.P.Anlage.Zeit;
      aAnlageU  # BAG.P.Anlage.User;
    end;
    703 : begin
      vDat      # BAG.F.Anlage.Datum;
      vZeit     # BAG.F.Anlage.Zeit;
      aAnlageU  # BAG.F.Anlage.User;
    end;
    707 : begin
      vDat      # BAG.FM.Anlage.Datum;
      vZeit     # BAG.FM.Anlage.Zeit;
      aAnlageU  # BAG.FM.Anlage.User;
    end;
    709 : begin
      vDat      # BAG.Z.Anlage.Datum;
      vZeit     # BAG.Z.Anlage.Zeit;
      aAnlageU  # BAG.Z.Anlage.User;
    end;
    710 : begin
      vDat      # BAG.FM.Fh.Anlage.Dat;
      vZeit     # BAG.FM.Fh.Anlage.Zei;
      aAnlageU  # BAG.FM.Fh.Anlage.Usr;
    end;
    711 : begin
      vDat      # BAG.PZ.Anlage.Datum;
      vZeit     # BAG.PZ.Anlage.Zeit;
      aAnlageU  # BAG.PZ.Anlage.User;
    end;
    892 : begin
      vDat      # OSt.E.Anlage.Datum;
      vZeit     # OSt.E.Anlage.Zeit;
      aAnlageU  # Ost.E.Anlage.User;
    end;
    otherwise RETURN;
  end;

  if (vDat<>0.0.0) then
  aAnlageD  # SQLTimeStamp(vDat, vZeit);
    //aAnlageD  # ''''+SQLTimeStamp(vDat,0:0)+'''';
  //aAnlageU    # ''''+aAnlageU+'''';
  aAnlageU    # aAnlageU;

end;


//========================================================================
//  Init
//
//========================================================================
Sub Init(opt aForce : logic) : alpha
local begin
  vErr  : alpha(100);
  vA    : alpha(1000);
  vI    : int;
end;
begin

@ifdef LogCalls
debug('ODBC_INIT');
@endif

  if (Set.SQL.Instance='') or (Set.SQL.Database='') or (Set.SQL.User='') then RETURN '';
  if ( DbaInfo( _dbaReadOnly ) > 0 ) then RETURN '';
  if (aForce=false) then begin
    // 03.07.2020 : wenn der SYNC per SOA läuft, darf NUR der connecten!!!
    if (Set.SQL.SoaYN) and ((gUsername=*^'*SOA_SYNC*')=false) then RETURN '';
  end;
  
  // interne Lizenzen BCS
  if (dbalicense(_DbaSrvLicense)='CE101448MU') or
    (dbalicense(_DbaSrvLicense)='CE101446MU') then begin
    //(dbalicense(_DbaSrvLicense)='CD152667MN/H') then begin

    vA # StrCnv(Set.SQL.instance,_StrUpper);
    if (StrFind(vA,'LOCALHOST',0)=0) and (StrFind(vA,'127.0.0.1',0)=0) then begin
      REPEAT
        vI # WindialogBox(0,'SQL-LINK','ACHTUNG!'+StrChar(13)+'Die SQL-Settings sind NICHT für den lokalen Betrieb gesetzt. Automatisch ändern?',_WinIcoWarning,_WinDialogYesNoCancel,3);
      UNTIL (vI<>_winidcancel);
      if (vI=_Winidyes) then begin
        // Ändern...
        RecRead(903,1,_RecLock);
        Set.SQL.Instance      # 'LOCALHOST\SQLEXPRESS';
        Set.SQL.User          # 'sa';
        Set.SQL.PrintSrvUrl   # 'http://localhost:9999/egal/egal';
        RecReplace(903,_recunlock);
      end;
    end;
  end;


  // pasende Lizenz?
//  if (StrFind(cLics, DbaLicense(_DbaSrvLicense),0)=0) then RETURN '';

  if (gOdbcApi=0) then begin
    gOdbcAPI # ODBCOpen();
    if (gOdbcAPI<=0) then begin
      gOdbcApi # 0;
      RETURN 'Unable to load ODBC-API!';
    end;
  end;


  vErr # _InitCon();
  if (vErr<>'') then RETURN vErr;

/*
  if (gGuidDLL=0) then begin
    gGuidDLL # DllLoad( FsiPath() + '\dlls\' + 'C16GuidGenerator.dll' );
    if (gGuidDLL<=0) then begin
      gOdbcCon # 0;
      RETURN 'Unable to load Guid-DLL!'
    end;
  end;
*/
//todo('OK');

  // ST 2015-04-15: Dokumente leeren, wenn sich erster User anmeldet
  if (DbaInfo(_DbaUserCount) = 1) then
    ClearTempDoks(true);


  gScopeList # CteOpen(_CteList);

  RETURN '';
end


//========================================================================
//  Term
//
//========================================================================
sub Term() : alpha;
begin

  // ST 2015-04-15: Dokumente leeren, wenn sich erster User anmeldet
  if (DbaInfo(_DbaUserCount) = 1) then
    ClearTempDoks(true);


  if (gGuidDLL<>0) then begin
    gGuidDll->DllUnload();
    gGuidDLL # 0;
  end;

  TermCmds();

  if (gOdbcCon<>0) then begin
    gOdbcCon->OdbcClose();
    gOdbcCon # 0;
  end;

  if (gOdbcApi<>0) then begin
    gOdbcApi->OdbcClose();
    gOdbcApi # 0;
  end;

  if (gScopeList<>0) then begin
    CteClear(gScopelist,y);
    CteClose(gScopeList);
    gScopeList # 0;
  end;

  RETURN '';
end;

/***
//========================================================================
//  CreateTableScript
//
//========================================================================
sub CreateTableScript(
  aDatei    : int;
  aFilename : alpha(8096));
local begin
  vKey      : alpha(8096);
  vTabName  : alpha;
  vA        : alpha(8096);
  vMaxTds   : int;
  vTds      : int;
  vMaxFld   : int;
  vFld      : int;
  vFldName  : alpha;
  vFCount   : int;
  vKeyCount : int;
  vI,vJ,vK  : int;
  vStream   : int;
end;
begin

  if (aDatei=210) then RETURN;
  if (aDatei=410) or (aDatei=411) then RETURN;
  if (aDatei=510) or (aDatei=511) then RETURN;
  if (aDatei=470) then RETURN;

  // TEXTE???
  if (aDatei=1000) then begin
    vStream # FSIOpen(aFilename,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
    if (vStream>0) then
      FsiWrite(vStream, 'CREATE TABLE Text (RecID uniqueidentifier NOT NULL, Name nvarchar(32), Inhalt nvarchar(max), PRIMARY KEY (Name) )');
    if (vStream<>0) then
      FsiClose(vStream);
    RETURN;
  end;


  vTabName # TableName(aDatei);
  if (vTabName='') then RETURN;

  // reflect primary key...
  vK # KeyInfo(aDatei, 1, _KeyFldCount);
  FOR vI # 1 loop inc(vI) while (vI<=vK) do begin
    vJ # KeyFldInfo(aDatei,1,vI,_KeyFldNumber);
    vFldName # FieldName(aDatei, 1, vJ);
    if (vKey='') then
      vKey # vKey + vFldName
    else
      vKey # vKey + ','+vFldName;
  END;


  vStream # FSIOpen(aFilename,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
  if (vStream>0) then
    FsiWrite(vStream, 'CREATE TABLE '+vTabName+' (RecID uniqueidentifier NOT NULL');

//  vCmd # gOdbcCON->OdbcPrepare('CREATE TABLE '+vTabName+' ('+vA+', PRIMARY KEY ('+vKey+'))');

  // reflect object...
  vA # '';
  vFCount # 0;
  vMaxTds # FileInfo(aDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      vFldName # FieldName(aDatei, vTds, vFld);
      if (vFldName='') then CYCLE;
      inc(vFCount);

      vA # ','+vFldName;
      case FldInfo(aDatei, vTds, vFld,_FldType) of
        _TypeAlpha  : vA # vA + ' nvarchar('+aint(FldInfo(aDatei, vTds, vFld, _FldLen))+')';
        _TypeDate   : vA # vA + ' datetime';
        _Typeword   : vA # vA + ' int';
        _typeint    : vA # vA + ' int';
        _Typefloat  : vA # vA + ' float';
//        _typelogic  : vA # vA + ' tinyint';
        _typelogic  : vA # vA + ' bit';
        _TypeTime   : vA # vA + ' datetime';
otherwise todo('XX');
      end;

      // Primary key??
      If (IsKeyField(aDatei, vTds, vFld)) then vA # vA + ' NOT NULL';

      if (vStream<>0) then FsiWrite(vStream, vA);
    END;
  END;


  if (vStream<>0) then begin
    FsiWrite(vStream, ', PRIMARY KEY ('+vKey+'))');
    FsiWrite(vStream, StrChar(13)+StrChar(10));
  end;
  if (vStream<>0) then
    FsiClose(vStream);

  RETURN;
end;
***/

/*========================================================================
2022-10-26  AH
========================================================================*/
sub Table.Exists(aName : alpha) : logic;
local begin
  Erx       : int;
  vCmd      : int;
  vA        : alpha(1000);
  vRes      : logic;
end;
begin

  // Execute GETCOLUMS...
  vA # 'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '''+aName+'''';
  vCmd # gOdbcCON->OdbcExecuteDirect(vA);
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    Msg(99,'ODBC: SELECT TABLE_NAMES failed!',_WinIcoError,_WinDialogOK,1);
    RETURN false;
  end
  else begin
    // create statement + parameter...
    WHILE (vCMD->OdbcFetch() = _ErrOk) do begin
      Erx # vCmd->OdbcClmData(1, vA);
      vRes # true;
    END;
    vCMD->OdbcClose();
  end;

  RETURN vRes;
end;


//========================================================================
//  ReflectTable    - durch SOA oder InsertAll
//
//========================================================================
sub ReflectTable(
  aDatei  : int;
  aMode   : alpha) : int;
local begin
  vNullOK   : logic;
  vA        : alpha(8096);
  vCount    : int;
  vPTyp     : int[1000];
  vPLen     : int[1000];
  vMaxTds   : int;
  vTds      : int;
  vMaxFld   : int;
  vFld      : int;
  vFldName  : alpha;
  vErr      : alpha;
  vCmd      : handle;
  vTabName  : alpha;
  vI        : int;
  vErg      : int;
  vPlugin   : alpha;
end;
begin

  // SPEZI
  if (aDatei=931) then begin
    if (aMode='I') then begin
      vPlugin # ',?,?,?';
      vA # 'INSERT INTO Customfeld VALUES (?'+vPlugin+',?,?,?,?)';
      vCmd # gOdbcCON->OdbcPrepare(vA);
      vCmd->OdbcParamAdd(_TypeAlpha, 36,y);
      if (vPlugin<>'') then begin
        vCmd->OdbcParamAdd(_TypeAlpha, 23,y); // Anlage-Datum
        vCmd->OdbcParamAdd(_TypeAlpha, 32,y); // Anlage-Username
        vCmd->OdbcParamAdd(_Typebigint);      // TimeStamp
      end;
      vCmd->OdbcParamAdd(_TypeAlpha, 36,y);
      vCmd->OdbcParamAdd(_TypeInt);
      vCmd->OdbcParamAdd(_TypeAlpha, 32,y);
      vCmd->OdbcParamAdd(_TypeAlpha, 128,y);
    end
    else begin
// 02.10.2018     vA # 'UPDATE Customfeld SET ZuRecID=?, lfdNr=?, Name=?, Inhalt=? OUTPUT ''OK'' WHERE RecID=?';
      vA # 'UPDATE Customfeld SET ZuRecID=?, lfdNr=?, Name=?, Inhalt=? WHERE RecID=?';
      vCmd # gOdbcCON->OdbcPrepare(vA);
      vCmd->OdbcParamAdd(_TypeAlpha, 36,y);
      vCmd->OdbcParamAdd(_TypeInt);
      vCmd->OdbcParamAdd(_TypeAlpha, 32,y);
      vCmd->OdbcParamAdd(_TypeAlpha, 128,y);
      vCmd->OdbcParamAdd(_TypeAlpha, 36,y);
    end;
    RETURN vCMD;
  end
  else if (aDatei=1800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
    if (aMode='I') then begin
      vA # 'INSERT INTO Benutzer (Username, Passwort, Hauptuser, RecID) VALUES (?,?,?,?)';
      vCmd # gOdbcCON->OdbcPrepare(vA);
      vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
      vCmd->OdbcParamAdd(_TypeAlpha, 128,y);
      vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
      vCmd->OdbcParamAdd(_TypeAlpha, 36,y);
    end
    else begin
      vA # 'UPDATE Benutzer SET Username=?, Passwort=?, Hauptuser=? WHERE RecID=?';
      vCmd # gOdbcCON->OdbcPrepare(vA);
      vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
      vCmd->OdbcParamAdd(_TypeAlpha, 128,y);
      vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
      vCmd->OdbcParamAdd(_TypeAlpha, 36,y);
    end;
    RETURN vCMD;
  end;



  vTabName # TableName(aDatei);
  if (vTabName='') then RETURN 0;

//  vNullOK # cnvai(DbaInfo(_DbaClnRelMaj))+'.'+cnvai(DbaInfo(_DbaClnRelMin))+'.'+cnvai(DbaInfo(_DbaClnRelrev),_FmtNumLeadZero,0,2)>'5.7.02';

  // reflect object...
  if (aMode='I') then begin
    vA            # '?,?,?,?';
    vCount        # 1+2+1;
    vPTyp[1]      # _TypeAlpha;   // GUID
    vPLen[1]      # 36;
    vPTyp[2]      # _TypeAlpha;   // Datum
    vPLen[2]      # 23;
    vPTyp[3]      # _TypeAlpha;   // Username
    vPLen[3]      # 32;
    vPTyp[4]      # _TypeBigint;  // TimeStamp
  end
  else begin
    vA            # 'TimeStamp=?';
    vCount        # 1;
    vPTyp[vCount]      # _TypeBigint;  // TimeStamp
  end;

  vMaxTds # FileInfo(aDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin

      vFldName # FieldName(aDatei, vTds, vFld);
      if (vFldName='') then CYCLE;
      inc(vCount);

      if (aMode='I') then begin
        vA # vA + ',?'
      end
      else begin
        if (vA='') then
          vA # vA + vFldName + '=?'
        else
          vA # vA + ','+vFldName + '=?';
      end;


      case FldInfo(aDatei, vTds, vFld,_FldType) of
        _TypeAlpha  : begin
          vPTyp[vCount] # _TypeAlpha;
          vPLen[vCount] # FldInfo(aDatei, vTds, vFld, _FldLen);
        end;
        //_TypeDate   : vPTyp[vCount] # _TypeDate;
        _TypeDate   : begin
          vPTyp[vCount] # _TypeAlpha;
          vPLen[vCount] # 23;
        end;
        _Typeword   : vPTyp[vCount] # _TypeInt;
        _typeint    : vPTyp[vCount] # _TypeInt;
        _Typefloat  : vPTyp[vCount] # _TypeFloat;
//        _typelogic  : vPTyp[vCount] # _Typebyte;
        _typelogic  : vPTyp[vCount] # _TypeBool;
//        _TypeTime   : vPTyp[vCount] # _Typebyte
        _TypeTime   : begin
          vPTyp[vCount] # _TypeAlpha;
          vPLen[vCount] # 23;
        end;

otherwise todo('XX');
      end;

    END;
  END;

  // 18.01.2019 AH
  if (aMode='I') and (aDatei=837) then begin
    vA # vA +',?,?,?,?,?';
    inc(vCount);
    vPTyp[vCount] # _TypeAlpha;
    vPLen[vCount] # 1;
    inc(vCount);
    vPTyp[vCount] # _TypeAlpha;
    vPLen[vCount] # 1;
    inc(vCount);
    vPTyp[vCount] # _TypeAlpha;
    vPLen[vCount] # 1;
    inc(vCount);
    vPTyp[vCount] # _TypeAlpha;
    vPLen[vCount] # 1;
    inc(vCount);
    vPTyp[vCount] # _TypeAlpha;
    vPLen[vCount] # 1;
  end;

  // create statement + parameter...
  if (aMode='I') then begin
    vCmd # gOdbcCON->OdbcPrepare('INSERT INTO '+vTabName+' VALUES ('+vA+')');
@ifdef DebugCMD
debugx('CMD : INSERT INTO '+vTabName+' VALUES ('+vA+')');
@endif
  end
  else begin
//    vCmd # gOdbcCON->OdbcPrepare('UPDATE '+vTabName+' SET '+vA+' WHERE RecID='+GUID(aDatei, RecInfo(aDatei, _RecID), true));
//if (Random()<0.7) then vTabName # vTabname+ 'x';
//debugx(vtabname + ' '+gUserGroup);
// 02.10.2018    vCmd # gOdbcCON->OdbcPrepare('UPDATE '+vTabName+' SET '+vA+' OUTPUT ''OK'' WHERE RecID=?');
    vCmd # gOdbcCON->OdbcPrepare('UPDATE '+vTabName+' SET '+vA+' WHERE RecID=?');
/***
vErg # TextOpen(10);
TextLineWrite(vERg, 1, 'UPDATE '+vTabName+' SET vA WHERE RecID=?', _TextLineInsert);
TextLineWrite(vErg, 2, vA, _TextLineInsert);
TextWrite(vErg, '!!!SOA_'+aint(mat.nummer),0);
Textclose(vErg)
***/
    // GUID anhängen...
    inc(vCount);
    vPTyp[vCount] # _TypeAlpha;
    vPLen[vCount] # 36;
  end;



  FOR vI # 1 loop inc(vI) WHILE (vI<=vCount) do begin
    if (vPTyp[vI]=_typeAlpha) then begin
@ifdef DebugCMD
debugx('AddPara '+aint(vI)+'. ALPHA');
@endif
      vErg # OdbcParamAdd(vCmd, vPTyp[vI],vPLen[vI], true);
      if (vErg<>_ErrOK) then begin
        OdbcError(ThisLine,'addpara'+aint(vI)+' :'+vCmd->spOdbcErrSqlMessage,aDatei);
        RETURN 0;
      end;
    end
    else begin
@ifdef DebugCMD
debugx('AddPara '+aint(vI)+'. Sonst');
@endif
      vErg # OdbcParamAdd(vCmd, vPTyp[vI]);
      if (vErg<>_ErrOK) then begin
        OdbcError(ThisLine,'addparA'+aint(vI)+' :'+vCmd->spOdbcErrSqlMessage,aDatei);
        RETURN 0;
      end;
    end;
  END;

  RETURN vCmd;
end;


//========================================================================
//  FillRecIntoCommand
//
//========================================================================
sub FillRecIntoCommand(
  aDatei  : int;
  aCmd    : int;
  aMode   : alpha) : logic;
local begin
  vCount      : int;
  vMaxTds     : int;
  vTds        : int;
  vMaxFld     : int;
  vFld        : int;
  vFldName    : alpha;
  v930        : int;
  vGUID, vGUID2 : alpha;
  vAnlageD    : alpha;
  vAnlageU    : alpha;
  vA          : alpha;
  vF          : float;
  vBig        : bigint;
end;
begin

  // SPEZI
  if (aDatei=931) then begin
    v930 # RecBufCreate(930);
    v930->CUS.FP.Nummer # CUS.FeldNummer;
    RecRead(v930,1,0);
    vGuid2  # GUID(CUS.Datei, CUS.RecID,n);             // von Aufhängerdatei
    vGuid   # GUID(aDatei, RecInfo(aDatei, _RecID),n);  // eigener Key
    if (aMode='I') then begin
      OdbcParamSet(aCmd, 1, vGuid);

      OdbcParamSet(aCmd, 2, vAnlageD); // Datum
      OdbcParamSet(aCmd, 3, vAnlageU); // Username
      OdbcParamSet(aCmd, 4, vBig);     // TimeStamp

      OdbcParamSet(aCmd, 2+3, vGuid2);
      vFld # CUS.LfdNr;
      OdbcParamSet(aCmd, 3+3, vFld);
      vFldName # v930->CUS.FP.Name;
      OdbcParamSet(aCmd, 4+3, vFldName);
      OdbcParamSet(aCmd, 5+3, CUS.Inhalt);
    end
    else begin
      OdbcParamSet(aCmd, 1, vGuid2);
      vFld # CUS.LfdNr;
      OdbcParamSet(aCmd, 2, vFld);
      vFldName # v930->CUS.FP.Name;
      OdbcParamSet(aCmd, 3, vFldName);
      OdbcParamSet(aCmd, 4, CUS.Inhalt);
      OdbcParamSet(aCmd, 5, vGuid);
    end;
    RecBufDestroy(v930);
    RETURN true;
  end
  else if (aDatei=1800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
    vGUID # GUID(800, RecInfo(800, _RecID), false);
    OdbcParamSet(aCmd, 1, Usr.Username);
    OdbcParamSet(aCmd, 2, Usr.Passwort);
    OdbcParamSet(aCmd, 3, Usr.Typ);
    OdbcParamSet(aCmd, 4, vGuid);
    RETURN true;
  end;
  

  // fill parameter...
  if (aMode='I') then begin
    vCount # 1+2+1;
    OdbcParamSet(aCmd, 1, GUID(aDatei, RecInfo(aDatei, _RecID),false));
@ifdef DebugCMD
debugx('Set adau');
@endif
    _GetAnlage(aDatei, var vAnlageD, var vAnlageU);
    if (vAnlageD='null') then
      OdbcParamSet(aCmd, 2, null)
    else
      OdbcParamSet(aCmd, 2, vAnlageD);  // Anlage-Datum
    OdbcParamSet(aCmd, 3, vAnlageU);  // Anlage-Username
    vBig # RecInfo(aDatei, _RecModified);
    OdbcParamSet(aCmd, 4, vBig);     // TimeStamp
  end
  else begin
    vCount  # 1;
    vBig # RecInfo(aDatei, _RecModified);
    OdbcParamSet(aCmd, vCount, vBig);     // TimeStamp
  end;

  vMaxTds # FileInfo(aDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin

      // NULLs?
//        if (aDatei=100) and (vTds=1) and (vFld=2) and (Adr.Kundennr=0) then vNull # y;
//        if (aDatei=100) and (vTds=1) and (vFld=4) and (Adr.Lieferantennr=0) then vNull # y;
//        if (vNull) then begin
//          inc(vCount);
//          if (vNullOK) then
//            OdbcParamSet(vCmd, vCount, null)  //-1);
//          else
//            OdbcParamSet(vCmd, vCount, -1);
//          vNull # n;
//          CYCLE;
//        end;

      vFldName # FieldName(aDatei, vTds, vFld);
      if (vFldName='') then CYCLE;
      inc(vCount);

@ifdef DebugCMD
debugx('Set '+aint(vCount)+'.'+vFldname);
@endif

      // SPEZIAL Konvertierung
      if (aDatei=254) and (vTds=1) and (vFld=7) then begin
        vA # FldAlpha(aDatei, vTds, vFld);
        vA # Lib_strings:Strings_ReplaceAll(vA, 'Ø', strchar(235));
        OdbcParamSet(aCmd, vCount, vA);
        CYCLE;
      end;
//debugx('SqlParaAdd '+aint(vCount)+':'+FldName(aDatei, vTds, vFld));
      case FldInfo(aDatei, vTds, vFld, _FldType) of
        _TypeAlpha  : OdbcParamSet(aCmd, vCount, FldAlpha(aDatei, vTds, vFld));
        _TypeDate   : if (FldDate(aDatei, vTds, vFld)=0.0.0) then
                      OdbcParamSet(aCmd, vCount, null)
                    else
                      OdbcParamSet(aCmd, vCount, SQLTimeStamp(FldDate(aDatei, vTds, vFld),0:0));
        _Typeword   : OdbcParamSet(aCmd, vCount, FldWord(aDatei, vTds, vFld));
        _typeint    : OdbcParamSet(aCmd, vCount, FldInt(aDatei, vTds, vFld));
        _Typefloat  : begin
//          OdbcParamSet(aCmd, vCount, FldFloat(aDatei, vTds, vFld)); 15.07.2021
          vF # FldFloat(aDatei, vTds, vFld);
          if vF>0.0 then vF # Min(vF, 100000000000.0)
          else vF # Max(vF, -100000000000.0);
          OdbcParamSet(aCmd, vCount, vF);
          end;
        _typelogic  : OdbcParamSet(aCmd, vCount, FldLogic(aDatei, vTds, vFld));
//          _TypeTime   : OdbcParamSet(vCmd, vCount, FldTime(aDatei, vTds, vFld));
        _TypeTime   : OdbcParamSet(aCmd, vCount, SQLTimeStamp(0.0.0,FldTime(aDatei,vTds,vFld)));
otherwise TODO('Y');
      end;
    END;
  END;

  // 18.01.2019 AH
  if (aMode='I') and (aDatei=837) then begin
    inc(vCount);
    OdbcParamSet(aCmd, vCount, '');
    inc(vCount);
    OdbcParamSet(aCmd, vCount, '');
    inc(vCount);
    OdbcParamSet(aCmd, vCount, '');
    inc(vCount);
    OdbcParamSet(aCmd, vCount, '');
    inc(vCount);
    OdbcParamSet(aCmd, vCount, '');
  end;
  
  
  if (aMode='U') then begin
    // GUID anhängen...
    inc(vCount);
    OdbcParamSet(aCmd, vCount, GUID(aDatei, RecInfo(aDatei, _RecID),false));
  end;

  RETURN true;
end;



//========================================================================
//  Execute
//      führt einen CMD aus
//      26.09.2018 AH: wird z.B. bei REPLACE mit OUTPUT gearbeitet, kann man das OK prüfen bzw. wenn kein OK das als FEHLER ansehen!!
//========================================================================
sub Execute(
  aDatei        : int;
  aCmd          : int;
  opt aCheckOK  : logic
  ) : int
local begin
  vErg      : int;
  vErr      : alpha(1000);
end;
begin
aCheckOK # false;

  // Execute...
  vErg # OdbcExecute(aCmd);
  if (vErg<>_ErrOK) then begin
    vErr # aCmd->spOdbcErrSqlMessage;
    HandleMemLeak();
    OdbcError(ThisLine,vErr, aDatei);
    //  OdbcError(ThisLine,aCmd->spOdbcErrSqlMessage, aDatei);
    RETURN _rDeadlock;
  end;
  
  
  vErg # _rOK;
  if (aCheckOK) then begin
    // auf OK testen
    WHILE (aCmd->OdbcFetch() = _ErrOk) do begin
      aCmd->OdbcClmData(1, vErr);
    END;
    if (vErr<>'OK') then vErg # _rNoRec;
  end;

  vErr # HandleMemLeak();
  if (vErr<>'') then begin
    OdbcError(ThisLine,vErr,aDatei);
    RETURN _rDeadLock;
  end;

  RETURN vErg;
end;


//========================================================================
//========================================================================
sub ExecuteDirect(
  aQ        : Alpha(8000)) : logic;
local begin
  vCMD      : int;
  vErg      : int;
  vErr      : alpha(1000);
end;
begin

  if (gOdbcCon=0) then RETURN true;

  vCmd # gOdbcCON->OdbcExecuteDirect(aQ);
  if (vCMD=_ErrOdbcError) or (vCMD=_ErrOdbcFunctionFailed) then begin
    OdbcError(ThisLine,gOdbcCON->spOdbcErrSqlMessage, 0);
    RETURN false;
  end;

  vCmd->OdbcClose();

  RETURN true;
end;


//========================================================================
//  Insert    - ADHOC am Client
//
//========================================================================
sub Insert(
  aDatei      : int;
  opt aRecID  : int) : logic;
local begin
  vErr      : alpha;
  vGUID     : alpha;
  vGUID2    : alpha;
  vCmd      : handle;
  vTabName  : alpha;
  vA        : alpha(8096);
  vMaxTds   : int;
  vTds      : int;
  vMaxFld   : int;
  vFld      : int;
  vFldName  : alpha;
  vCount    : int;
  vPTyp     : int[1000];
  vPLen     : int[1000];
  vI        : int;
  vErg      : int;
  vNull     : logic;
  vNullOK   : logic;
  v930      : int;
  vPlugin   : alpha;
  vAnlageD  : alpha;
  vAnlageU  : alpha;
  vF        : float;
  vBig      : bigint;
end;
begin

@ifdef LogCalls
debug('ODBC_Insert:'+aint(aDatei));
@endif

  if (gOdbcCon=0) then RETURN true;


  // SPEZI
  if (aDatei=931) then begin
    v930 # RecBufCreate(930);
    v930->CUS.FP.Nummer # CUS.FeldNummer;
    RecRead(v930,1,0);
    vGuid2  # GUID(CUS.Datei, CUS.RecID,y);             // von Aufhängerdatei
    vGuid   # GUID(aDatei, RecInfo(aDatei, _RecID),y);  // eigener Key

    vPlugin # ','''+''','''+''',''''';  // Datum + Username = leer    fix 2022-11-14  AH
    vA # 'INSERT INTO Customfeld VALUES ('+vGuid+vPlugin+','+vGuid2+','+aint(CUS.lfdNr)+','''+v930->CUS.FP.Name+''','''+CUS.Inhalt+''')';
    RecBufDestroy(v930);
    vCmd # gOdbcCON->OdbcExecuteDirect(vA);
    if (vCMD=_ErrOdbcError) or (vCMD=_ErrOdbcFunctionFailed) then begin
      OdbcError(ThisLine,gOdbcCON->spOdbcErrSqlMessage, 0);
      RETURN false;
    end;

    vCmd->OdbcClose();
    RETURN true;
  end;


  vTabName # TableName(aDatei);
  if (vTabName='') then RETURN true;

  vNullOK # cnvai(DbaInfo(_DbaClnRelMaj))+'.'+cnvai(DbaInfo(_DbaClnRelMin))+'.'+cnvai(DbaInfo(_DbaClnRelrev),_FmtNumLeadZero,0,2)>'5.7.02';

  if (aRecID=0) then aRecID # RecInfo(aDatei, _RecID);


//  if (_INIT()<>'') then RETURN;

  // Memleak umgehen
  vErr # HandleMemLeak();
  if (vErr<>'') then begin
    OdbcError(ThisLine,vErr,aDatei);
    RETURN false;
  end;

  // reflect object...
  vCount # 0+2+1;
  vPTyp[1]      # _TypeAlpha;   // Datum
  vPLen[1]      # 23;
  vPTyp[2]      # _TypeAlpha;   // Username
  vPLen[2]      # 32;
  vPTyp[3]      # _TypeBigInt;  // TimeStamp
  vA # ',?,?,?';

  vMaxTds # FileInfo(aDatei,_FileSbrCount);
//if (vMaxTDS>1) then vMaxTds # 1;
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
//if (vMaxFld>3) then vMaxFld # 3;
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin

      vFldName # FieldName(aDatei, vTds, vFld);
      if (vFldName='') then CYCLE;
      inc(vCount);
      vA # vA + ',?';
//debug(aint(vCount)+';'+vFldName);

      case FldInfo(aDatei, vTds, vFld,_FldType) of
        _TypeAlpha  : begin
          vPTyp[vCount] # _TypeAlpha;
          vPLen[vCount] # FldInfo(aDatei, vTds, vFld, _FldLen);
        end;
        //_TypeDate   : vPTyp[vCount] # _TypeDate;
        _TypeDate   : begin
          vPTyp[vCount] # _TypeAlpha;
          vPLen[vCount] # 23;
        end;
        _Typeword   : vPTyp[vCount] # _TypeInt;
        _typeint    : vPTyp[vCount] # _TypeInt;
        _Typefloat  : vPTyp[vCount] # _TypeFloat;
//        _typelogic  : vPTyp[vCount] # _Typebyte;
        _typelogic  : vPTyp[vCount] # _TypeBool;
//        _TypeTime   : vPTyp[vCount] # _Typebyte
        _TypeTime   : begin
          vPTyp[vCount] # _TypeAlpha;
          vPLen[vCount] # 23;
        end;
otherwise todo('XX');
      end;

    END;
  END;


  // create statement + parameter...
  vGUID # GUID(aDatei, aRecID,y);
//  vA # ','+vAnlageD+','+vAnlageU+vA;
//debugx('INSERT INTO '+vTabName+' VALUES ('+vGUID+vA+')');
  vCmd # gOdbcCON->OdbcPrepare('INSERT INTO '+vTabName+' VALUES ('+vGUID+vA+')');

//debugx('mem:'+aint(_Sys->spProcessMemory));
  FOR vI # 1 loop inc(vI) WHILE (vI<=vCount) do begin
//debug('add Para:'+aint(vI)+'   Len:'+aint(vPLen[vI]));
    if (vPTyp[vI]=_typeAlpha) then begin
      vErg # OdbcParamAdd(vCmd, vPTyp[vI],vPLen[vI], true);
      if (vErg<>_ErrOK) then
        OdbcError(ThisLine,'addpara'+aint(vI)+' :'+vCmd->spOdbcErrSqlMessage, aDatei);
    end
    else begin
      vErg # OdbcParamAdd(vCmd, vPTyp[vI]);
      if (vErg<>_ErrOK) then
        OdbcError(ThisLine,'addpara'+aint(vI)+' :'+vCmd->spOdbcErrSqlMessage, aDatei);
    end;
  END;
//debugx('mem:'+aint(_Sys->spProcessMemory));


  // fill parameter...
  vCount # 0+2+1;
  _GetAnlage(aDatei, var vAnlageD, var vAnlageU);
  if (vAnlageD='null') then
    OdbcParamSet(vCmd, 1, null)
  else
    OdbcParamSet(vCmd, 1, vAnlageD);  // Anlage-Datum
  OdbcParamSet(vCmd, 2, vAnlageU);    // Anlage-Username
  vBig # RecInfo(aDatei, _RecModified);
  OdbcParamSet(vCmd, 3, vBig);        // TimeStamp
@ifdef DebugCMD
debugx('Set adau');
@endif

  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
//if (vMaxFld>3) then vMaxFld # 3;
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      // NULLs?
//      if (aDatei=100) and (vTds=1) and (vFld=2) and (Adr.Kundennr=0) then vNull # y;
//      if (aDatei=100) and (vTds=1) and (vFld=4) and (Adr.Lieferantennr=0) then vNull # y;
//      if (vNull) then begin
//        inc(vCount);
//        if (vNullOK) then
//          OdbcParamSet(vCmd, vCount, null)  //-1);
//        else
//          OdbcParamSet(vCmd, vCount, -1);
//        vNull # n;
//        CYCLE;
//      end;

      vFldName # FieldName(aDatei, vTds, vFld);
      if (vFldName='') then CYCLE;
      inc(vCount);

@ifdef DebugCMD
debugx('set para '+aint(vCount)+' '+vFldName+': '+aint(adatei)+'/'+aint(vTds)+'/'+aint(vFld));
@endif

      // SPEZIAL Konvertierung
      if (aDatei=254) and (vTds=1) and (vFld=7) then begin
        vA # FldAlpha(aDatei, vTds, vFld);
        vA # Lib_strings:Strings_ReplaceAll(vA, 'Ø', strchar(235));
        OdbcParamSet(vCmd, vCount, vA);
        CYCLE;
      end;
  
      case FldInfo(aDatei, vTds, vFld, _FldType) of
        _TypeAlpha  : OdbcParamSet(vCmd, vCount, FldAlpha(aDatei, vTds, vFld));
        _TypeDate   : if (FldDate(aDatei, vTds, vFld)=0.0.0) then
                        OdbcParamSet(vCmd, vCount, null)
                      else
                        OdbcParamSet(vCmd, vCount, SQLTimeStamp(FldDate(aDatei, vTds, vFld),0:0));
        _Typeword   : OdbcParamSet(vCmd, vCount, FldWord(aDatei, vTds, vFld));
        _typeint    : OdbcParamSet(vCmd, vCount, FldInt(aDatei, vTds, vFld));
        _Typefloat  : begin
//         OdbcParamSet(vCmd, vCount, FldFloat(aDatei, vTds, vFld));15.07.2021
          vF # FldFloat(aDatei, vTds, vFld);
          if vF>0.0 then vF # Min(vF, 100000000000.0)
          else vF # Max(vF, -100000000000.0);
          OdbcParamSet(vCmd, vCount, vF);
        end;
        _typelogic  : OdbcParamSet(vCmd, vCount, FldLogic(aDatei, vTds, vFld));
//        _TypeTime   : OdbcParamSet(vCmd, vCount, FldTime(aDatei, vTds, vFld));
        _TypeTime   : //if (FldTime(aDatei, vTds, vFld)=24:00) then
                      //  OdbcParamSet(vCmd, vCount, null)
                      //else
                        OdbcParamSet(vCmd, vCount, SQLTimeStamp(0.0.0,FldTime(aDatei,vTds,vFld)));

otherwise TODO('Y');
      end;

    END;
  END;


//debugx('mem:'+aint(_Sys->spProcessMemory));
  // Execute...
  if (OdbcExecute(vCmd)<>_ErrOK) then begin
    OdbcError(ThisLine,vCmd->spOdbcErrSqlMessage, aDatei);
  end
  else begin
//debugx('Err  '+aint(ErrGet()));
//    vI # vCmd->spOdbcResCountClm;
//debugx('mem:'+aint(_Sys->spProcessMemory));
//    WHILE (vCmd->OdbcFetch() = _ErrOK) do begin
//    END;
//debug('OK');
//winsleep(1000);
  end;


//debugx('mem:'+aint(_Sys->spProcessMemory));
  if (aDatei=800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
    vGUID # GUID(aDatei, aRecID,n);
    vA # 'INSERT INTO Benutzer (Username, Passwort, Hauptuser, RecID) VALUES (?,?,?,?)';
    vCmd # gOdbcCON->OdbcPrepare(vA);
    vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
    vCmd->OdbcParamAdd(_TypeAlpha, 128,y);
    vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
    vCmd->OdbcParamAdd(_TypeAlpha, 36,y);
    OdbcParamSet(vCmd, 1, Usr.Username);
    OdbcParamSet(vCmd, 2, Usr.Passwort);
    OdbcParamSet(vCmd, 3, Usr.Typ);
    OdbcParamSet(vCmd, 4, vGUID);
    if (OdbcExecute(vCmd)<>_ErrOK) then begin
      OdbcError(ThisLine,vCmd->spOdbcErrSqlMessage, aDatei);
    end
  end;

  // cleanup...
  vCmd->OdbcClose();


//debugx('mem:'+aint(_Sys->spProcessMemory));

  RETURN true;
end;


//========================================================================
//  Update
//
//========================================================================
sub Update(aDatei    : int) : logic;
local begin
  vErr        : alpha;
  vCmd        : handle;
  vTabName    : alpha;
  vKey,vKey2  : alpha(1000);
  vA          : alpha(8096);
  vMaxTds     : int;
  vTds        : int;
  vMaxFld     : int;
  vFld        : int;
  vFldName    : alpha;
  vCount      : int;
  vPTyp       : int[1000];
  vPLen       : int[1000];
  vErg        : int;
  vI          : int;
  vNull       : logic;
  vNullOK     : logic;
  v930        : int;
  vDatei      : int;
  vF          : float;
  vBig        : bigint;
end;
begin

@ifdef LogCalls
debug('ODBC_Update:'+aint(aDatei));
@endif

  if (gOdbcCon=0) then RETURN true;

  // SPEZI
  if (aDatei=931) then begin
    v930 # RecBufCreate(930);
    v930->CUS.FP.Nummer # CUS.FeldNummer;
    RecRead(v930,1,0);
    vKey2 # GUID(CUS.Datei, CUS.RecID,y);           // von Aufhängerdatei
    vKey # GUID(aDatei, RecInfo(aDatei, _RecID),y); // eigener Key

    vA # 'UPDATE Customfeld SET ZuRecID= '+vKey2+', lfdNr='+aint(CUS.lfdNr)+', Name='''+v930->CUS.FP.Name+''', Inhalt='''+CUS.Inhalt+'''';
    vA # vA + ' WHERE RecID='+vKey;
    vCmd # gOdbcCON->OdbcExecuteDirect(vA);
    if (vCMD=_ErrOdbcError) or (vCMD=_ErrOdbcFunctionFailed) then begin
      OdbcError(ThisLine,gOdbcCON->spOdbcErrSqlMessage, 0);
      RETURN false;
    end;
    vCmd->OdbcClose();
    RETURN true;
  end;


  vTabName # TableName(aDatei);
  if (vTabName='') then RETURN true;
//  vKey # Key(aDatei);

  vKey # GUID(aDatei, RecInfo(aDatei, _RecID),y);
  if (vKey='') then RETURN true;

  vNullOK # cnvai(DbaInfo(_DbaClnRelMaj))+'.'+cnvai(DbaInfo(_DbaClnRelMin))+'.'+cnvai(DbaInfo(_DbaClnRelrev),_FmtNumLeadZero,0,2)>'5.7.02';

//  if (_INIT()<>'') then RETURN;


  // Memleak umgehen
  vErr # HandleMemLeak();
  if (vErr<>'') then begin
    OdbcError(ThisLine,vErr,aDatei);
    RETURN false;
  end;


  // Reflect object...
  vA      # 'TimeStamp=?';
  vCount  # 1;
  vPTyp[vCount] # _TypeBigInt;  // TimeStamp
  
  vDatei # aDatei;
  if (vDatei>10000) then
    vDatei # HdlInfo(vDatei,_HdlSubType);

  vMaxTds # FileInfo(vDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(vDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin

      vFldName # FieldName(aDatei, vTds, vFld);
      if (vFldName='') then CYCLE;
      inc(vCount);

      if (vA='') then
        vA # vA + vFldName + '=?'
      else
        vA # vA + ','+vFldName + '=?';

      case FldInfo(vDatei, vTds, vFld,_FldType) of
        _TypeAlpha  : begin
          vPTyp[vCount] # _TypeAlpha;
          vPLen[vCount] # FldInfo(vDatei, vTds, vFld, _FldLen);
//debug('setpara:'+aint(vCOunt)+' auf L'+aint(vPLen[vCount]));
        end;
//        _TypeDate   : vPTyp[vCount] # _TypeDate;
        _TypeDate   : begin
          vPTyp[vCount] # _TypeAlpha;
          vPLen[vCount] # 23;
        end;
        _Typeword   : vPTyp[vCount] # _TypeInt;
        _typeint    : vPTyp[vCount] # _TypeInt;
        _Typefloat  : vPTyp[vCount] # _TypeFloat;
//        _typelogic  : vPTyp[vCount] # _Typebyte;
        _typelogic  : vPTyp[vCount] # _Typebool;
//        _TypeTime   : vPTyp[vCount] # _Typebyte
        _TypeTime   : begin
          vPTyp[vCount] # _TypeAlpha;
          vPLen[vCount] # 23;
        end;

otherwise todo('XX');
      end;

    END;
  END;

  // create statement + parameter...
  vCmd # gOdbcCON->OdbcPrepare('UPDATE '+vTabName+' SET '+vA+' WHERE RecID='+vKey);
//debug('UPDATE '+vTabName+' SET ('+vA+' WHERE RecID='+vKey);

  FOR vI # 1 loop inc(vI) WHILE (vI<=vCount) do begin
//debug('set para '+aint(vI)+' '+aint(vPTyp[vI])+' err:'+aint(ErrGet()));
    if (vPTyp[vI]=_typeAlpha) then begin
      vErg # OdbcParamAdd(vCmd, vPTyp[vI],vPLen[vI], true);
      if (vErg<>_ErrOK) then
        OdbcError(ThisLine,'addpara'+aint(vI)+' :'+vCmd->spOdbcErrSqlMessage, aDatei);
    end
    else begin
      vErg # OdbcParamAdd(vCmd, vPTyp[vI]);
      if (vErg<>_ErrOK) then
        OdbcError(ThisLine,'addpara'+aint(vI)+' :'+vCmd->spOdbcErrSqlMessage, aDatei);
    end;
  END;

  // fill parameter...
  vCount # 1;
  vBig # RecInfo(vDatei, _RecModified);
  OdbcParamSet(vCmd, vCount, vBig);        // TimeStamp
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(vDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin

      // NULLs?
//      if (aDatei=100) and (vTds=1) and (vFld=2) and (Adr.Kundennr=0) then vNull # y;
//      if (aDatei=100) and (vTds=1) and (vFld=4) and (Adr.Lieferantennr=0) then vNull # y;
      if (vNull) then begin
        inc(vCount);
        if (vNullOK) then
          OdbcParamSet(vCmd, vCount, null)  //-1);
        else
          OdbcParamSet(vCmd, vCount, -1);
        vNull # n;
        CYCLE;
      end;

      vFldName # FieldName(vDatei, vTds, vFld);
      if (vFldName='') then CYCLE;
//debug('Feld: '+vFldName+' err:'+aint(ErrGet()));
      inc(vCount);

      // SPEZIAL Konvertierung
      if (aDatei=254) and (vTds=1) and (vFld=7) then begin
        vA # FldAlpha(aDatei, vTds, vFld);
        vA # Lib_strings:Strings_ReplaceAll(vA, 'Ø', strchar(235));
        OdbcParamSet(vCmd, vCount, vA);
        CYCLE;
      end;


      case FldInfo(vDatei, vTds, vFld, _FldType) of
        _TypeAlpha  : OdbcParamSet(vCmd, vCount, FldAlpha(aDatei, vTds, vFld));
        _TypeDate   : if (FldDate(aDatei, vTds, vFld)=0.0.0) then
                        OdbcParamSet(vCmd, vCount, null)
                      else
                        OdbcParamSet(vCmd, vCount, SQLTimeStamp(FldDate(aDatei, vTds, vFld),0:0));
        _Typeword   : OdbcParamSet(vCmd, vCount, FldWord(aDatei, vTds, vFld));
        _typeint    : OdbcParamSet(vCmd, vCount, FldInt(aDatei, vTds, vFld));
        _Typefloat  : begin
          //OdbcParamSet(vCmd, vCount, FldFloat(aDatei, vTds, vFld)); 15.07.2021
          vF # FldFloat(aDatei, vTds, vFld);
          if vF>0.0 then vF # Min(vF, 100000000000.0)
          else vF # Max(vF, -100000000000.0);
          OdbcParamSet(vCmd, vCount, vF);
        end;
        _typelogic  : OdbcParamSet(vCmd, vCount, FldLogic(aDatei, vTds, vFld));
//        _TypeTime   : OdbcParamSet(vCmd, vCount, FldTime(aDatei, vTds, vFld))
        _TypeTime   : OdbcParamSet(vCmd, vCount, SQLTimeStamp(0.0.0,FldTime(aDatei,vTds,vFld)));

otherwise TODO('Y');
      end;
    END;
  END;


  // Execute...
  if (OdbcExecute(vCmd)<>_ErrOK) then begin
    OdbcError(ThisLine,vCmd->spOdbcErrSqlMessage, aDatei);
//  end
//  else begin
//debug('OK');
  end;

  if (aDatei=800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
    vKey # GUID(aDatei, RecInfo(aDatei, _RecID),n);
    vA # 'UPDATE Benutzer SET Username=?, Passwort=?, Hauptuser=? WHERE RecID=?';
    vCmd # gOdbcCON->OdbcPrepare(vA);
    vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
    vCmd->OdbcParamAdd(_TypeAlpha, 128,y);
    vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
    vCmd->OdbcParamAdd(_TypeAlpha, 36,y);
    OdbcParamSet(vCmd, 1, Usr.Username);
    OdbcParamSet(vCmd, 2, Usr.Passwort);
    OdbcParamSet(vCmd, 3, Usr.Typ);
    OdbcParamSet(vCmd, 4, vKey);
    if (OdbcExecute(vCmd)<>_ErrOK) then begin
      OdbcError(ThisLine,vCmd->spOdbcErrSqlMessage, aDatei);
    end
  end;

  // cleanup...
  vCmd->OdbcClose();

  RETURN true;
end;


//========================================================================
//  Delete
//
//========================================================================
sub Delete(
  aDatei      : int;
  aRecId      : int;
  ) : logic;
local begin
  vCmd      : handle;
  vTabName  : alpha;
  vKey      : alpha(1000);
  vErr      : alpha;
end;
begin

@ifdef LogCalls
debug('ODBC_Delete:'+aint(aDatei));
@endif

  if (gOdbcCon=0) then RETURN true;
  vTabName # TableName(aDatei);
  if (vTabName='') then RETURN true;


  // Memleak umgehen
  vErr # HandleMemLeak();
  if (vErr<>'') then begin
    OdbcError(ThisLine,vErr,aDatei);
    RETURN false;
  end;

//  vKey # Key(aDatei);
//  if (vKey='') then RETURN;
  vKey # GUID(aDatei, aRecID,y);

//  if (_INIT()<>'') then RETURN;
  // Execute...
//debugx('DELETE FROM '+vTabName+' WHERE RecID='+vKey);
  vCmd # gOdbcCON->OdbcExecuteDirect('DELETE FROM '+vTabName+' WHERE RecID='+vKey);
//Debugx('CMD:'+aint(vCmd));
//+' : '+vCmd->spOdbcErrSqlMessage);
//debugx(vCmd->spOdbcErrSqlMessage+'|'+vCmd->spOdbcErrSqlState+'|'+aint(vCmd->spOdbcErrSqlResult));
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    OdbcError(ThisLine,'Delete failed', aDatei);
    RETURN false;
  end;

  if (aDatei=800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
    vCmd # gOdbcCON->OdbcExecuteDirect('DELETE FROM Benutzer WHERE RecID='+vKey);
    if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
      OdbcError(ThisLine,'Delete failed', aDatei);
      RETURN false;
    end;
  end;

  // cleanup...
  vCmd->OdbcClose();

  RETURN true;
end;


//========================================================================
//  DeletaAll
//
//========================================================================
sub DeleteAll(aDatei : int) : logic;
local begin
  vCmd      : handle;
  vTabName  : alpha;
end;
begin

@ifdef LogCalls
debug('ODBC_DeleteAll '+aint(aDatei));
@endif

  if (gOdbcCon=0) then RETURN true;
  vTabName # TableName(aDatei);
  if (vTabName='') then RETURN true;

  // Execute...
  vCmd # gOdbcCON->OdbcExecuteDirect('TRUNCATE TABLE '+vTabName);
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    OdbcError(ThisLine,'DeleteAll failed', aDatei);
    RETURN false;
  end;

  if (aDatei=800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
    vCmd # gOdbcCON->OdbcExecuteDirect('TRUNCATE TABLE Benutzer');
    if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
      OdbcError(ThisLine,'DeleteAll failed', aDatei);
      RETURN false;
    end;
  end;

  // cleanup...
  vCmd->OdbcClose();

  RETURN true;
end;


//========================================================================
//========================================================================
sub TransferStamp() : logic;
local begin
  vCmd      : handle;
end;
begin
//debug('transfer '+cnvab(version.stamp));
@ifdef LogCalls
debug('ODBC_Transferstamp');
@endif

  if (gBlueMode) or (gOdbcCon=0) then RETURN true;

  // Execute...
  vCmd # gOdbcCON->OdbcExecuteDirect('UPDATE C16_Version SET lfdNr='+aint(Version.lfdnr)+', Stamp='''+cnvab(Version.Stamp, _FmtNumNoGroup)+''' WHERE RecID=''00000000-0C16-0C16-0C16-099700000001''');
  if (vCMD=_ErrOdbcError) or (vCMD=_ErrOdbcFunctionFailed) then begin
    OdbcError(ThisLine,gOdbcCON->spOdbcErrSqlMessage, 0);
    RETURN false;
  end;
  vCmd->OdbcClose();

  RETURN true;
end;


//========================================================================
//========================================================================
sub IsStampOK() : logic;
local begin
  vCmd      : handle;
  vBig      : bigint;
  vErg      : int;
end;
begin
@ifdef LogCalls
debug('ODBC_IsStampOK?');
@endif

  if (gOdbcCon=0) then RETURN true;

  // wenn über PtD gesynct wird ist immer alls ok
  if (cPtdSync) then RETURN true;


  vCMD # gODBCCon->OdbcExecuteDirect('SELECT Stamp FROM c16_Version WHERE RecID=''00000000-0C16-0C16-0C16-099700000001''');
  if (vCMD=_ErrOdbcError) or (vCMD=_ErrOdbcFunctionFailed) then begin
    OdbcError(ThisLine,gODBCCon->spOdbcErrSqlMessage, 0);
    RETURN false;
  end;
  // create statement + parameter...
  if (vCMD->OdbcFetch() = _ErrOk) then begin
    vErg # vCmd->OdbcClmData(1, vBig);
    vCMD->OdbcClose();
  end;

  vErg # RecRead(997,1,_recFirst);

//debug('Read '+cnvab(vBig)+ ' zu '+cnvab(Version.Stamp));
  RETURN (Version.Stamp = vBig) and (vErg<=_rLocked);
end;


//========================================================================
//  ExecuteScript
//
//========================================================================
sub ExecuteScript(
  aTxt  : int;
  aName : alpha) : logic
local begin
  vCmd      : handle;
  vA,vB     : alpha(8096);
  vPre      : alpha(500);
  vI,vJ     : int;
  vTxt      : int;
  vMem      : handle;
  vPos      : int;
  vMax      : int;
end;
begin

  if (gOdbcCon=0) then RETURN true;

  vMem # MemAllocate(_MemAutoSize);
  vMem->spCharset # _CharSetWCP_1252;
/*
  // Copy text to memory...
  if (aTxt=0) then begin
    vTxt # TextOpen(20);
//    Erx # Textread(vTxt, aName, _Textextern);  // Text lesen
TextAddLine(vTxt, 'RecID uniqueidentifier NOT NULL, Name nvarchar(32), Inhalt nvarchar(max), PRIMARY KEY (Name)');
  end
  else begin
    vTxt # aTxt;
  end;
  FOR vI # 1 loop inc(vI) while (vi<=TextInfo(vTxt, _textLines)) do begin
    vA # TextLineRead(vTxt, vI, 0);
    // add Softbreak???
    if (Textinfo(vTxt,_TextNoLineFeed)=0) then
      vA # vA + StrChar(10);
debug(vA);
    vMem->memWriteStr(vPos + 1, vA, _CharsetC16_1252);
    vPos # vPos + StrLen(vA);
  END;
  if (aTxt=0) then TextClose(vTxt);

  if (vMem->spLen=0) then begin
    MemFree(vMem);
    RETURN true;
  end;
*/
//  vCmd # gOdbcCON->OdbcPrepare('?');
  vCmd # gOdbcCON->OdbcPrepare('xxxCREATE TABLE Text (?,?,?,?)');
//  vCmd->OdbcParamAdd(_TypeHandle, (vMem->spLen),y);
//  vCmd->OdbcParamSet(1, vMem);
  vCmd->OdbcParamAdd(_TypeAlpha,100);
  vCmd->OdbcParamAdd(_TypeAlpha,100);
  vCmd->OdbcParamAdd(_TypeAlpha,100);
  vCmd->OdbcParamAdd(_TypeAlpha,100);
  vCmd->OdbcParamSet(1, 'RecID uniqueidentifier NOT NULL');
  vCmd->OdbcParamSet(2, 'Name nvarchar(32)');
  vCmd->OdbcParamSet(3, 'Inhalt nvarchar(max)');
  vCmd->OdbcParamSet(4, 'PRIMARY KEY (Name)');

  // Execute...
  if (OdbcExecute(vCmd)<>_ErrOK) then begin
    OdbcError(ThisLine,vCmd->spOdbcErrSqlMessage, 0);
  end;
  vCMD->OdbcClose();

//debug('write:'+aint(vMem->splen));

  // cleanup...
  MemFree(vMem);

  RETURN true;
end;



//========================================================================
//  InsertText
//
//========================================================================
sub InsertText(
  aName       : alpha;
  opt aName2  : alpha;
  opt aSilent : logic;
  ) : logic;
local begin
  Erx       : int;
  vErr      : alpha;
  vCmd      : handle;
  vA,vB     : alpha(8096);
  vPre      : alpha(500);
  vI,vJ     : int;
  vTxt      : int;
  vMem      : handle;
  vPos      : int;
  vMax      : int;
end;
begin

@ifdef LogCalls
debug('ODBC_InsertText:'+aName);
@endif

  if (gOdbcCon=0) then RETURN true;

  if (aName2='') then aName2 # aName;

  vErr # HandleMemLeak();
  if (vErr<>'') then begin
    if (aSilent=false) then OdbcError(ThisLine,vErr,1000);
    RETURN false;
  end;


//  vMem # MemAllocate(_MemAutoSize);
  vMem # MemAllocate(_Mem16M);
  if (gCodepage=1254) then
    vMem->spCharset # _CharSetWCP_1254    // TÜRKISCH
  else
    vMem->spCharset # _CharSetWCP_1252;

  // Copy text to memory...
  vTxt # TextOpen(20);
  Erx # Textread(vTxt, aName, 0);  // Text lesen

  // 23.06.2016 AH: von altem Format dirket konvertieren:
  if (TextSearch(vTxt, 1, 1, 0, StrChar(254,3))>0) then begin
    TextSearch(vTxt, 1, 1, 0, StrChar(254,3), StrChar(27,3));
    TextWrite(vTxt, aName, 0);
  end;

  FOR vI # 1 loop inc(vI) while (vi<=TextInfo(vTxt, _textLines)) do begin
    vA # TextLineRead(vTxt, vI, 0);
    // add Softbreak???
    if (Textinfo(vTxt,_TextNoLineFeed)=0) then
      vA # vA + StrChar(10);

    // 12.11.2019 Wandlungen
    vA # Lib_Strings:Strings_ReplaceAll(vA, 'ð', strchar(248));

    if (gCodepage=1254) then
      vMem->memWriteStr(vPos + 1, vA, _CharsetC16_1254)     // TÜRKISCH
    else
      vMem->memWriteStr(vPos + 1, vA, _CharsetC16_1252);
    vPos # vPos + StrLen(vA);
  END;
  TextClose(vTxt);

  // 400k Limit !!!
  if (vMem->splen>cMaxMem) then vMem->splen # cMaxMem;
//debug('pos:'+aint(vPos)+'   mem:'+aint(vMem->spLen));

  if (vMem->spLen=0) then begin
    MemFree(vMem);
    RETURN true;
  end;

  // test for existence...
  vA # 'SELECT 1 FROM Text WHERE Name='''+aName2+'''';
  vCMD # gODBCCon->OdbcExecuteDirect(vA);
  if (vCMD=_ErrOdbcError) or (vCMD=_ErrOdbcFunctionFailed) then begin
    if (aSilent=false) then OdbcError(ThisLine,'Text not found',0);
  end

  if (vCMD <= 0) then begin
    if (aSilent=false) then OdbcError(ThisLine,'??', 0);
    MemFree(vMem);
    vCMD->OdbcClose();
    RETURN false;
//    (99,'ODBC-Error !! Erx=' +Aint(erx)+ StrChar(10)+'gOdbcCon='+Aint(gOdbcCon)+StrChar(10) + 'vCMD='+Aint(vCMD)+StrChar(10)+'vA='+vA,0,0,0);//+vCmd->spOdbcErrSqlMessage,0,0,0);
  end
  else begin
    // create statement + parameter...
    if (vCMD->OdbcFetch() = _ErrOk) then begin
      Erx # vCmd->OdbcClmData(1, vI);
      vCMD->OdbcClose();
      vCmd # gOdbcCON->OdbcPrepare('UPDATE Text SET Inhalt=? WHERE Name='''+aName2+'''');
      vCmd->OdbcParamAdd(_TypeHandle, (vMem->spLen),y);
      vCmd->OdbcParamSet(1, vMem);
    end
    else begin
      vCMD->OdbcClose();
      vCmd # gOdbcCON->OdbcPrepare('INSERT INTO Text (RecId, Name, Inhalt) VALUES ('''+TextGUID(aName)+''',?,?)');
//debug(aName2+': INSERT INTO Text (RecId, Name, Inhalt) VALUES ('''+TextGUID(aName)+''',?,?)');
      vCmd->OdbcParamAdd(_TypeAlpha, 32,y);
      vCmd->OdbcParamAdd(_TypeHandle, (vMem->spLen),y);
      vCmd->OdbcParamSet(1, aName2);
      vCmd->OdbcParamSet(2, vMem);
    end;
  end;

  // Execute...
  if  (vCMD > 0) then begin
    if (OdbcExecute(vCmd)<>_ErrOK) then begin
      if (aSilent=false) then OdbcError(ThisLine,vCmd->spOdbcErrSqlMessage,0);
      MemFree(vMem);
      vCMD->OdbcClose();
      RETURN false;
    end;
    vCMD->OdbcClose();
  end;

  // cleanup...
  MemFree(vMem);

  RETURN true;
end;


//========================================================================
//  CreateText
//
//========================================================================
sub CreateText(
  aName     : alpha;
  ) : logic;
local begin
  Erx       : int;
  vErr      : alpha;
  vCmd      : handle;
  vA,vB     : alpha(8096);
  vPre      : alpha(500);
  vI,vJ     : int;
  vTxt      : int;
  vPos      : int;
  vMax      : int;
end;
begin

@ifdef LogCalls
debug('ODBC_CreateText:'+aName);
@endif

  if (gOdbcCon=0) then RETURN true;


  vErr # HandleMemLeak();
  if (vErr<>'') then begin
    OdbcError(ThisLine,vErr,1000);
    RETURN false;
  end;

  // test for existence...
  vA # 'SELECT 1 FROM Text WHERE Name='''+aName+'''';
  vCMD # gODBCCon->OdbcExecuteDirect(vA);
  if (vCMD=_ErrOdbcError) or (vCMD=_ErrOdbcFunctionFailed) then begin
    OdbcError(ThisLine,vCmd->spOdbcErrSqlMessage,0);
  end
  else begin
    // create statement + parameter...
    if (vCMD->OdbcFetch() = _ErrOk) then begin
      Erx # vCmd->OdbcClmData(1, vI);
      vCMD->OdbcClose();
      vCmd # gOdbcCON->OdbcPrepare('UPDATE Text SET Inhalt=? WHERE Name='''+aName+'''');
      vCmd->OdbcParamAdd(_TypeAlpha, 32,y);
      vCmd->OdbcParamSet(1, '');
    end
    else begin
      vCMD->OdbcClose();
      vCmd # gOdbcCON->OdbcPrepare('INSERT INTO Text (RecId, Name, Inhalt) VALUES ('''+TextGUID(aName)+''',?, '''')');
      vCmd->OdbcParamAdd(_TypeAlpha, 32,y);
      vCmd->OdbcParamSet(1, aName);
    end;
  end;

  // Execute...
  if (OdbcExecute(vCmd)<>_ErrOK) then begin
    OdbcError(ThisLine,vCmd->spOdbcErrSqlMessage,0);
  end;
  vCMD->OdbcClose();

  RETURN true;
end;


//========================================================================
//  DeleteText
//
//========================================================================
sub DeleteText(
  aName     : alpha;
  ) : logic;
local begin
  vCmd      : handle;
  vErr      : alpha;
end;
begin

@ifdef LogCalls
debug('ODBC_DeleteText:'+aName);
@endif

  if (gOdbcCon=0) then RETURN true;

  vErr # HandleMemLeak();
  if (vErr<>'') then begin
    OdbcError(ThisLine,vErr,1000);
    RETURN false;
  end;

  // Execute...
  vCmd # gOdbcCON->OdbcExecuteDirect('DELETE FROM Text WHERE Name='''+aName+'''');
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    OdbcError(ThisLine,'Delete Text failed',0);
    RETURN false;
  end;

  // cleanup...
  vCMD->OdbcClose();

  RETURN true;
end;


//========================================================================
//  RenamceText
//
//========================================================================
sub RenameText(
  aName   : alpha;
  aName2  : alpha;
  ) : logic;
local begin
  vErr      : alpha;
  vCmd      : handle;
  vA,vB     : alpha(8096);
  vPre      : alpha(500);
  vI,vJ     : int;
  vTxt      : int;
  vPos      : int;
  vMax      : int;
end;
begin

@ifdef LogCalls
debug('ODBC_RenameText:'+aName+'->'+aName2);
@endif

  if (gOdbcCon=0) then RETURN true;

  // Memleak umgehen
  vErr # HandleMemLeak();
  if (vErr<>'') then begin
    OdbcError(ThisLine,vErr,1000);
    RETURN false;
  end;

  // create statement + parameter...
  vCmd # gOdbcCON->OdbcPrepare('UPDATE Text SET Name=? WHERE Name='''+aName+'''');
  vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
  vCmd->OdbcParamSet(1, aName2);

  // Execute...
  if (OdbcExecute(vCmd)<>_ErrOK) then begin
    OdbcError(ThisLine,vCmd->spOdbcErrSqlMessage,0);
  end;
  vCMD->OdbcClose();

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
sub InsertAll(
  aDatei    : int;
  aDat      : date;
  opt aHdl  : int;
  opt aSilent : logic) : logic;
local begin
  Erx       : int;
  vCmd      : handle;
  vCmd2     : handle;
  vMaxTds   : int;
  vTds      : int;
  vMaxFld   : int;
  vFld      : int;
  vFldName  : alpha;
  vCount    : int;
  vErr      : alpha;
  vFirst    : logic;
end;
begin

@ifdef LogCalls
debug('ODBC_Insertall '+aint(aDatei));
@endif

  // Kommando zusammenbauen
  if (gOdbcCon=0) then RETURN true;
  vErr # HandleMemLeak();
  if (vErr<>'') then begin
    if (aSilent=false) then OdbcError(ThisLine,vErr,aDatei);
    RETURN false;
  end;
  vCmd # ReflectTable(aDatei,'I');
  if (aDatei=800) then  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
    vCmd2 # ReflectTable(1800,'I');


  FOR Erx # RecRead(aDatei,1,_recFirst)
  LOOP Erx # RecRead(aDatei,1,_recNext)
  WHILE (erx<=_rLocked) do begin

    if (aHdl<>0) then aHdl->Lib_Progress:Step()

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

    if (FillRecIntoCommand(aDatei, vCmd, 'I')=false) then begin
      BREAK;
    end;

/***
    // fill parameter...
    vCount # 1;
    OdbcParamSet(vCmd, vCount, GUID(aDatei, RecInfo(aDatei, _RecID),false));

    FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
      vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
      FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin

        // NULLs?
//        if (aDatei=100) and (vTds=1) and (vFld=2) and (Adr.Kundennr=0) then vNull # y;
//        if (aDatei=100) and (vTds=1) and (vFld=4) and (Adr.Lieferantennr=0) then vNull # y;
//        if (vNull) then begin
//          inc(vCount);
//          if (vNullOK) then
//            OdbcParamSet(vCmd, vCount, null)  //-1);
//          else
//            OdbcParamSet(vCmd, vCount, -1);
//          vNull # n;
//          CYCLE;
//        end;

        vFldName # FieldName(aDatei, vTds, vFld);
        if (vFldName='') then CYCLE;
        inc(vCount);
        case FldInfo(aDatei, vTds, vFld, _FldType) of
          _TypeAlpha  : OdbcParamSet(vCmd, vCount, FldAlpha(aDatei, vTds, vFld));
        _TypeDate   : if (FldDate(aDatei, vTds, vFld)=0.0.0) then
                        OdbcParamSet(vCmd, vCount, null)
                      else
                        OdbcParamSet(vCmd, vCount, SQLTimeStamp(FldDate(aDatei, vTds, vFld),0:0));
          _Typeword   : OdbcParamSet(vCmd, vCount, FldWord(aDatei, vTds, vFld));
          _typeint    : OdbcParamSet(vCmd, vCount, FldInt(aDatei, vTds, vFld));
          _Typefloat  : OdbcParamSet(vCmd, vCount, FldFloat(aDatei, vTds, vFld));
          _typelogic  : OdbcParamSet(vCmd, vCount, FldLogic(aDatei, vTds, vFld));
//          _TypeTime   : OdbcParamSet(vCmd, vCount, FldTime(aDatei, vTds, vFld));
        _TypeTime   : OdbcParamSet(vCmd, vCount, SQLTimeStamp(0.0.0,FldTime(aDatei,vTds,vFld)));

  otherwise TODO('Y');
        end;

      END;
    END;
***/

    // Execute...
    if (OdbcExecute(vCmd)<>_ErrOK) then begin
      if (aSilent=false) then if (OdbcError(ThisLine, 'Datei '+aint(aDatei)+' : '+vCmd->spOdbcErrSqlMessage,aDatei)) then BREAK;
    end;

    if (aDatei=800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
      if (FillRecIntoCommand(1800, vCmd2, 'I')=false) then begin
        BREAK;
      end;
      // Execute...
      if (OdbcExecute(vCmd2)<>_ErrOK) then begin
        if (aSilent=false) then if (OdbcError(ThisLine, 'Datei 1800 : '+vCmd2->spOdbcErrSqlMessage,1800)) then BREAK;
      end;
    end;

  END;  // Loop records

  // cleanup...
  vCmd->OdbcClose();

  RETURN true;
end;


//========================================================================
//  CreateTable
//
//========================================================================
sub CreateTable(
  aDatei        : int;
  opt aPostfix  : alpha) : alpha;
local begin
  vKey        : alpha(8096);
  vTabName    : alpha;
  vA          : alpha(8096);
  vMaxTds     : int;
  vTds        : int;
  vMaxFld     : int;
  vFld        : int;
  vFldName    : alpha;
  vFCount     : int;
  vKeyCount   : int;
  vI,vJ,vK    : int;

  vCMD1,vCMD2 : alpha(8096);
  vCMD3       : alpha(8096);
  vTxt,vTxt2  : int;
  vCmd        : handle;
  vPlugin     : alpha;
  vDebug      : logic;
end;
begin


  if (aDatei=210) then RETURN '';
  if (aDatei=410) or (aDatei=411) then RETURN '';
  if (aDatei=510) or (aDatei=511) then RETURN '';
  if (aDatei=545) then RETURN '';
  if (aDatei=470) then RETURN '';

  vPlugin # ', Anlage_Datum datetime, Anlage_Username nvarchar(32), TimeStamp bigint';

  // CUSTOMFELDER???
  if (aDatei=931) then begin
    vTabName # 'Customfeld'+aPostFix;
    vCMD1 # 'CREATE Table '+vTabName+' (RecID uniqueidentifier NOT NULL'+vPlugin+', ZuRecID uniqueidentifier, lfdNr int, Name nvarchar(32), Inhalt nvarchar(128), PRIMARY KEY (ZuRecID, lfdNr) )';
    vCMD2 # 'CREATE UNIQUE INDEX RecID on '+vTabName+' (RecID)';
  end
  // TEXTE???
  else if (aDatei=1000) then begin
    vTabName # 'Text'+aPostFix;
    vCMD1 # 'CREATE TABLE '+vTabName+' (RecID uniqueidentifier NOT NULL'+vPlugin+', Name nvarchar(32), Inhalt nvarchar(max), RtfInhalt nvarChar(max) PRIMARY KEY (Name) )';
    vCMD2 # 'CREATE UNIQUE INDEX RecID on '+vTabName+' (RecID)';
  end
  else if (aDatei=1001) then begin
    vTabName # 'c16_Version'+aPostFix;
    vCMD1 # 'CREATE Table '+vTabName+' (RecID uniqueidentifier NOT NULL'+vPlugin+', lfdNr int, Stamp bigint, PRIMARY KEY (lfdNr) )';
    vCMD2 # 'CREATE UNIQUE INDEX RecID on '+vTabName+' (RecID)';
  end
  else if (aDatei=1002) then begin
    // Tabelle für Temporäre Druckdokumente
    vTabName # 'TempDokumente'+aPostFix;
    vCMD1 # 'CREATE TABLE '+vTabName+' (RecID uniqueidentifier NOT NULL'+vPlugin;;
    vCMD1 # vCMD1 + ', JobID nvarchar(20), Data nvarchar(max), Done bit, Size int, Title nvarchar(128), Adr int, Email nvarchar(128), Fax nvarchar(32), Language nvarchar(10), ResultJson nvarchar(max), PRIMARY KEY (JobID) )';
    vCMD2 # 'CREATE UNIQUE INDEX RecID on '+vTabName+' (RecID)';
  end
  else if (aDatei=1003) then begin
    // Tabelle für Temporäre CommandQueue
    vTabName # 'CommandQueue'+aPostFix;
    vCMD1 # 'CREATE TABLE '+vTabName+' (RecID uniqueidentifier NOT NULL'+vPlugin+', Command nvarchar(64), Arguments nvarchar(4000), Queued datetime, UserId uniqueidentifier, Executed datetime,' +
                'Done bit, Failed bit, Errortext nvarchar(250) PRIMARY KEY (RecID))';
    vCMD2 # 'CREATE UNIQUE INDEX RecID on '+vTabName+' (RecID)';
  end
  else begin
    vTabName # TableName(aDatei);
    if (vTabName='') then RETURN '';
    vTabName # vTabName + aPostFix;

    // reflect primary key...
    vK # KeyInfo(aDatei, 1, _KeyFldCount);
    FOR vI # 1 loop inc(vI) while (vI<=vK) do begin
      vJ # KeyFldInfo(aDatei,1,vI,_KeyFldNumber);
      vFldName # FieldName(aDatei, 1, vJ);
      if (vKey='') then
        vKey # vKey + vFldName
      else
        vKey # vKey + ','+vFldName;
//debugx(vKey);
    END;

    vCMD1 # 'CREATE TABLE '+vTabName+' (RecID uniqueidentifier NOT NULL'+vPlugin;

    // reflect object...
    vA # '';
    vFCount # 0;
    vMaxTds # FileInfo(aDatei,_FileSbrCount);
    FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
      vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
      FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
        vFldName # FieldName(aDatei, vTds, vFld);
        if (vFldName='') then CYCLE;
        if (StrFind(vFldName,'Anlage_Datum',0)>0) then CYCLE;
        if (StrFind(vFldName,'Anlage_Username',0)>0) then CYCLE;

        inc(vFCount);

        vA # vFldName;

        case FldInfo(aDatei, vTds, vFld,_FldType) of
          _TypeAlpha  : vA # vA + ' nvarchar('+aint(FldInfo(aDatei, vTds, vFld, _FldLen))+') DEFAULT ''''';
          _TypeDate   : vA # vA + ' datetime';
          _Typeword   : vA # vA + ' int';
          _typeint    : vA # vA + ' int';
          _Typefloat  : vA # vA + ' float';
  //        _typelogic  : vA # vA + ' tinyint';
          _typelogic  : vA # vA + ' bit';
          _TypeTime   : vA # vA + ' datetime';
  otherwise todo('XX');
        end;

        // Primary key??
        If (IsKeyField(aDatei, vTds, vFld)) then vA # vA + ' NOT NULL';

        if (vFCount<cGrenze) then begin
          vCMD1 # vCMD1 + ','+vA;
        end
        else begin
          if (vFCount=cGrenze) then begin
            vCMD3 # 'ALTER TABLE '+vTabName+' ADD '+vA;
          end
          else begin
            vCMD3 # vCMD3 + ','+vA;
          end;
        end;
      END;
    END;

    // 18.01.2019 AH
    if (aDatei=837) then begin
      vCMD1 # vCMD1 + ', Text_L1 nvarchar(max) DEFAULT ''''';
      vCMD1 # vCMD1 + ', Text_L2 nvarchar(max) DEFAULT ''''';
      vCMD1 # vCMD1 + ', Text_L3 nvarchar(max) DEFAULT ''''';
      vCMD1 # vCMD1 + ', Text_L4 nvarchar(max) DEFAULT ''''';
      vCMD1 # vCMD1 + ', Text_L5 nvarchar(max) DEFAULT ''''';
    end;
    

    vCMD1 # vCMD1 + ', PRIMARY KEY ('+vKey+'))';
    vCMD2 # 'CREATE UNIQUE INDEX RecID on '+vTabName+' (RecID)';
    vCMD3 # vCMD3 + '';
  end;

//debugx('1:'+vCmd1);
//debugx('2:'+vCmd2);
//debugx('3:'+vCmd3);

  vCmd # gOdbcCON->OdbcExecuteDirect(vCMD1);
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then
    RETURN 'ODBC FAILED: '+vCMD1;
  vCmd->OdbcClose();

  if (vCMD2<>'') then begin
    vCmd # gOdbcCON->OdbcExecuteDirect(vCMD2);
    if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then
      RETURN 'ODBC FAILED: '+vCMD2;
    vCmd->OdbcClose();
  end;

  if (vCMD3<>'') then begin
    vCmd # gOdbcCON->OdbcExecuteDirect(vCMD3);
    if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then
      RETURN 'ODBC FAILED: '+vCMD3;
    vCmd->OdbcClose();
  end;


  // 28.07.2015
  if (aDatei=1001) then begin
    vCmd # gOdbcCON->OdbcExecuteDirect('INSERT INTO c16_Version (RecId, lfdNr, Stamp) VALUES (''00000000-0C16-0C16-0C16-099700000001'','+aint(Version.lfdnr)+','+cnvab(Version.Stamp, _FmtNumNoGroup)+')');
    if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then
      RETURN 'ODBC FAILED: c16_version';
    vCmd->OdbcClose();
  end;
  
  if (aDatei=800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
// 'CREATE TABLE vTabName (RecID uniqueidentifier NOT NULL'+vPlugin+', Name nvarchar(32), Inhalt nvarchar(max), RtfInhalt nvarChar(max) PRIMARY KEY (Name) )';
    vTabName # 'Benutzer'+aPostFix;
    vCMD1 # 'CREATE Table '+vTabName+' (RecID uniqueidentifier NOT NULL';
    vCMD1 # vCMD1 + ', Username nvarchar(20) NOT NULL';
    vCMD1 # vCMD1 + ', Passwort nvarchar(128) NULL';
    vCMD1 # vCMD1 + ', LoginGesperrt bit NULL';
    vCMD1 # vCMD1 + ', Hauptuser nvarchar(20) NULL';
	  vCMD1 # vCMD1 + ', LetzterLogin datetime NULL';
	  vCMD1 # vCMD1 + ', LetzterLogout datetime NULL';
	  vCMD1 # vCMD1 + ', Adressnr int NULL';
	  vCMD1 # vCMD1 + ', Ansprechpartnernr int NULL';
	  vCMD1 # vCMD1 + ', Sprachnummer int NULL';
	  vCMD1 # vCMD1 + ', PersonalID int NULL';
	  vCMD1 # vCMD1 + ', TapiYN bit NULL';
	  vCMD1 # vCMD1 + ', NotifierYN bit NULL';
	  vCMD1 # vCMD1 + ', TapiIncPopUpYN bit NULL';
	  vCMD1 # vCMD1 + ', TapiIncMsgYN bit NULL';
	  vCMD1 # vCMD1 + ', OutlookCalendar nvarchar(100) NULL';
	  vCMD1 # vCMD1 + ', OutlookYN bit NULL';
	  vCMD1 # vCMD1 + ', Zoomfaktor int NULL';
	  vCMD1 # vCMD1 + ', Font_Size int NULL';
	  vCMD1 # vCMD1 + ', Anlage_Datum datetime NULL';
	  vCMD1 # vCMD1 + ', Anlage_Username nvarchar(32) NULL';
   vCMD1 # vCMD1 + ', TimeStamp bigint NULL'; // 2023-03-07 MR Löst timestamp Probelmatik für AppHost
    vCMD1 # vCMD1 + ' PRIMARY KEY (Username) )';
    vCmd # gOdbcCON->OdbcExecuteDirect(vCMD1);
    if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then
      RETURN 'ODBC FAILED: '+vCMD1;
    vCmd->OdbcClose();

    vCMD1 # 'CREATE UNIQUE INDEX RecID on '+vTabName+' (RecID)';
    vCmd # gOdbcCON->OdbcExecuteDirect(vCMD1);
    if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then
      RETURN 'ODBC FAILED: '+vCMD1;
    vCmd->OdbcClose();
  end;  // User800

  RETURN '';
end;


//========================================================================
//  FIRSTSCRIPT
//  Call Lib_ODBC:FirstScript
//========================================================================
sub FirstScript(opt aSilent : logic) : logic;
local begin
  vI    : int;
  vA    : alpha(8000);
  vHdl  : int;
  vCmd  : handle;
  vDB   : alpha;

  vDia  : int;
  vMsg  : int;
end;
begin
/**/
  if (gODBCAPI=0) then begin
    gOdbcAPI # ODBCOpen();
    if (gOdbcAPI<=0) then begin
      gOdbcApi # 0;
      if (aSilent=false) then
        Msg(99,'Unable to load ODBC-API!',0,0,0);
      RETURN false;
    end;
  end;

  vDB # Set.SQL.Database;
  //if ( StrFind(StrCnv( DbaName( _dbaAreaAlias ), _strUpper ),'TESTSYSTEM',1) > 0) then begin
  if (isTestsystem) then begin
    vDB # vDB + '_TESTSYSTEM';
  end;

  if (gODBCCon<>0) then begin
    gOdbcCon->OdbcClose();
    gOdbcCon # 0;
  end;

  gOdbcCon # gOdbcApi->OdbcConnectDriver('driver={SQL Server};server='+Set.SQL.Instance+';database=master;uid='+Set.SQL.User+';pwd='+Set.SQL.Password);
  if (gOdbcCON<=0) then begin
    gOdbcCon # 0;
    if (aSilent=false) then
      Msg(99,'Unable to connect to database [master]',_WinIcoError,_WinDialogOK,1);
    RETURN false;
  end;

  // Execute DROP DATABASE...
  vCmd # gOdbcCON->OdbcExecuteDirect('DROP DATABASE ['+vDB+']');
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin

      // Execute ALTER DATABASE...
    vCmd # gOdbcCON->OdbcExecuteDirect('ALTER DATABASE '+vDB+' SET SINGLE_USER WITH ROLLBACK IMMEDIATE');
    if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    end;

    vCmd # gOdbcCON->OdbcExecuteDirect('DROP DATABASE ['+vDB+']');
    if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
      Msg(99,'ODBC: DROP DATABASE failed!',_WinIcoError,_WinDialogOK,1);
    end;
  end;

  // Execute...
  vA # Lib_GuiCom:GetAlternativeName('SQL.Sprache');
  if (vA='SQL.Sprache') then vA # ''
  else vA # ' collate '+vA;
  vCmd # gOdbcCON->OdbcExecuteDirect('CREATE DATABASE ['+vDB+']'+vA); // collate Turkish_CI_AS');
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    if (aSilent=false) then
      Msg(99,'ODBC: CREATE DATABASE failed!',_WinIcoError,_WinDialogOK,1);
    Term();
    RETURN false;
  end;
  Term();

  if (aSilent=false) then
    Msg(99,'ODBC: New database successfully created...',_WinIcoInformation, _windialogok,1);

  // neu initialisieren
  Init(TRUE);

  vDia # WinOpen('Dlg.Pause',_WinOpenDialog);
  vMsg # Winsearch(vDia,'Label1');
  vMsg->wpcaption # 'synchronizing structure...';
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenterScreen);//, gFrmMain);

  // ALLE TABELLEN ANLEGEN...
  FOR vI # 1 LOOP inc(vI) WHILE (vI<=1000+1+1+1) do begin
    // 1000 für texte
//    createtableScript(vI,'C:\SQL_SCRIPT.TXT');

// 1002 = TemporäreDokumente
// 1003 = Commandqueue
    vA # CreateTable(vI);
    if (vA<>'') then begin
      Winclose(vDia);
      Msg(99,vA,_WinIcoError,_WinDialogOK,1);
      RETURN false;
    end;
  END;

  Winclose(vDia);


  if (aSilent=false) then
    Msg(99,'All tables created SUCCESSUFULLY !!!',0,0,0);

  RETURN true;
end;


//========================================================================
//  FIRSTSYNC
//  Call Lib_ODBC:FirstSync
//========================================================================
sub FirstSync(opt aSilent : logic) : logic;
local begin
  Erx     : int;
  vTxt    : int;
  vI      : int;
  vA      : alpha;
  vHdl    : int;
  vM1     : int;
  vM2     : int;

  vDia    : int;
  vMsg    : int;

  vDat    : date;
end;
begin

  if (aSilent=false) then begin
    if (Dlg_Standard:Datum('Ab Datum',var vDat, vDat)=false) then RETURN false;
  end;


  vDia # WinOpen('Dlg.Pause',_WinOpenDialog);
  vMsg # Winsearch(vDia,'Label1');
  vMsg->wpcaption # 'synchronizing data...';
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenterScreen);//, gFrmMain);

//  Msg(99, 'Next: Execute Script...',0,0,0);
//  ExecuteScript('E:\script.txt');

  FOR vI # 1 LOOP inc(vI) WHILE (vI<=999) do begin
    vA # TableName(vI);
    if (vA='') then CYCLE;
    vMsg->wpcaption # 'cleaning up '+vA+'...';
    if (DeleteAll(vI)=false) then begin
      Winclose(vDia);
      RETURN falsE;
    end;
  END;


  FOR vI # 1 LOOP inc(vI) WHILE (vI<=999) do begin

//if (vI<900) then CYCLE
    vA # TableName(vI);
    if (vA='') then CYCLE;
    vMsg->wpcaption # 'synchronizing '+vA+'...';
    if (InsertAll(vI, vDat)=false) then begin
      Winclose(vDia);
      RETURN falsE;
    end;
  END;


  vTxt  # TextOpen(10);
  FOR Erx # Textread(vTxt,'', _TextFirst|_TextNoContents)
  LOOP Erx # Textread(vTxt,vA, _TextNext|_TextNoContents)
  WHILE (Erx<>_rNoRec) do begin
    vA # TextInfoalpha(vTxt, _textName);
    
    if (Strcut(vA,1,1)<>'~') then CYCLE;      // 31.03.2020 AH
    if (Strcut(vA,1,4)='~980') then CYCLE;    // 31.03.2020 AH
    
    vMsg->wpcaption # 'synchronizing text '+vA+'...';
    if (InsertText(vA)=false) then begin
//      Winclose(vDia);
//      TextClose(vTxt);
//      RETURN false;
    end;
  END;
  TextClose(vTxt);


  Winclose(vDia);


  if (aSilent=false) then begin
    Msg(99,'COPY CONTENT DONE!',0,0,0);
  end;

  RETURN true;
end;


//========================================================================
//  ScriptOneTable
//
//========================================================================
sub ScriptOneTable(
  aDatei        : int;
  opt aSilent   : logic;
  opt aPostFix  : alpha) : logic;
local begin
  vA        : alpha(8000);
  vHdl      : int;
  vTabName  : alpha;
  vDia      : int;
  vMsg      : int;
  vCmd      : handle;
end;
begin
/**/
  // 2023-08-10 AH : Ablagen interessieren NICHT
  if (aDatei=210) then RETURN true;
  if (aDatei=410) or (aDatei=411) then RETURN true;
  if (aDatei=510) or (aDatei=511) then RETURN true;
  if (aDatei=470) then RETURN true;

  if (gOdbcApi=0) then begin
    Lib_odbc:Init(TRUE);
  end;

  if (gOdbcCon=0) then RETURN true;
  vTabName # TableName(aDatei);
  if (vTabName='') then RETURN true;
  vTabName # vTabName + aPostFix;

  // Execute DROP ...
  vCmd # gOdbcCON->OdbcExecuteDirect('DROP TABLE ['+vTabName+']');
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    if (aSilent=false) then Msg(99,'ODBC: DROP TABLE failed!',_WinIcoError,_WinDialogOK,1);
  end;
  if (aDatei=800) then begin  // 14.07.2020 AH: NET-Benutzer=C16-Benutzer
    vCmd # gOdbcCON->OdbcExecuteDirect('DROP TABLE [Benutzer'+aPostfix+']');
  end;
  vDia # WinOpen('Dlg.Pause',_WinOpenDialog);
  vMsg # Winsearch(vDia,'Label1');
  vMsg->wpcaption # 'synchronizing structure : '+aint(aDatei);
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenterScreen);//, gFrmMain);

  vA # CreateTable(aDatei, aPostfix);
  if (vA<>'') then begin
    Winclose(vDia);
    Msg(99,vA,_WinIcoError,_WinDialogOK,1);
    RETURN false;
  end;

  Winclose(vDia);

  if (aSilent=false) then
    Msg(99,'Table '+aint(aDatei)+' created SUCCESSUFULLY !!!',0,0,0);
  RETURN true;
end;


//========================================================================
//  SyncOneTable
//
//========================================================================
sub SyncOneTable(
  aDatei      : int;
  opt aSilent : logic;
  opt aDat    : date) : logic;
local begin
  Erx     : int;
  vA      : alpha;
  vHdl    : int;
  vTxt    : int;
  vDia    : int;
  vMsg    : int;
end;
begin

  if (gOdbcApi=0) then begin
    Lib_odbc:Init(TRUE);
  end;

  if (gOdbcCon=0) then RETURN true;

  if (aDatei<1000) then begin

    if (aSilent=false) then begin
      if (Dlg_Standard:Datum('Ab Datum',var aDat, aDat)=false) then RETURN false;
    end
    else begin
      Winsleep(500);    // 2023-08-21 AH Latzen, da sonst ein vorheriger Drop-Tabel "zu schnell" wäre
    end;

    vA # TableName(aDatei);
    vHdl # Lib_Progress:Init( 'Syncing '+vA+'...', RecInfo( aDatei, _recCount ) , y);
    if (vA<>'') then begin
      if (InsertAll(aDatei, aDat, vHdl)=false) then begin
        Winclose(vHdl);
        RETURN false;
      end;
    end;
    vHdl->Lib_Progress:Term();
    if (aDatei=200) then SyncOneTable(210, true);
    if (aDatei=400) then SyncOneTable(410, true);
    if (aDatei=401) then SyncOneTable(411, true);
    if (aDatei=500) then SyncOneTable(510, true);
    if (aDatei=501) then SyncOneTable(511, true);
    if (aDatei=540) then SyncOneTable(545, true);
    if (aDatei=460) then SyncOneTable(470, true);
  end;


  if (aDatei=1000) then begin
    vDia # WinOpen('Dlg.Pause',_WinOpenDialog);
    vMsg # Winsearch(vDia,'Label1');
    vMsg->wpcaption # 'synchronizing data : '+aint(aDatei);
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenterScreen);//, gFrmMain);

    vTxt  # TextOpen(10);
    FOR Erx # Textread(vTxt,'', _TextFirst|_TextNoContents)
    LOOP Erx # Textread(vTxt,vA, _TextNext|_TextNoContents)
    WHILE (Erx<>_rNoRec) do begin
      vA # TextInfoalpha(vTxt, _textName);
      vMsg->wpcaption # 'synchronizing text '+vA+'...';
      if (InsertText(vA)=false) then begin
        Winclose(vDia);
        TextClose(vTxt);
        RETURN false;
      end;
    END;
    TextClose(vTxt);

    Winclose(vDia);
  end;


  if (aSilent=false) then begin
    Msg(99,'COPY CONTENT DONE!',0,0,0);
  end;

  RETURN true;
end;


//========================================================================
//  sub GetTempDok(...) : logic;
//========================================================================
sub GetTempDok(
  aPrintJobId : alpha;
  aPath       : alpha(8096);
  aExtention  : alpha;
  var aFax    : alpha;
  var aEma    : alpha;
  var aLang   : alpha;
  var aResultJson : alpha;
  opt aAskForAdditionaltime : logic;
  opt aSplashHdl : int;
  ) : logic;
local begin
  Erx               : int;
  vSql              : alpha(8000);    //  SQL Statement
  vCmd              : handle;         //  SQL Command Descr.
  vPrintJobDone     : int;            //  Printjob fertig?
  vMaxTries,vTry    : int;
  vSleeptime        : int;

  vMemObjB64kodiert : handle;
  vMemObjBinaer     : handle;
  vFile             : int;
  vOK               : logic;

end;
begin

  // ST Druckausgabe
//  if (gUsername = 'ST')  AND (App_Main:Entwicklerversion()) then begin
    RETURN Lib_DotNetServices:GetTempDok(aPrintJobId,aPath,aExtention,var aFax,var aEma,var aLang,var aResultJson,aAskForAdditionaltime,aSplashHdl);
//  end;

@ifdef LogCalls
debug('ODBC_GetTempDok');
@endif

  vMaxTries   # 300;  // 300 x 100 ms = 30000 ms = 30 Sekunden auf Antwort warten
  vSleeptime  # 100;  // ms

  if (gOdbcCon=0) then RETURN false;

  // Auf Fertigmeldung vom Druckjob warten
  //                 1      2    3    4     5   6     7    8         9
  vSql   # 'SELECT Done,JobID,Size,Title,Adr,Email,Fax,Language,ResultJson FROM TempDokumente WHERE JobID=' + StrChar(39) + aPrintJobId + StrChar(39);
  vOK # false;
  WHILE vOK = false  DO BEGIN
    inc(vTry);

    // SQL-Command absetzen

    vCmd   # gODBCCon->OdbcExecuteDirect(vSql);
    if (vCmd = _ErrOdbcError) or (vCmd =_ErrOdbcFunctionFailed) then begin
      Error(99,'ODBC-Error '+Aint(__LINE__)+': '+vCmd->spOdbcErrSqlMessage);
      RETURN false;
    end;

    // Ergennis lesen
    if (vCmd->OdbcFetch() = _ErrOk) then begin

      // Datensatz in DB gefüllt, schreiben fertig?
      Erx # vCmd->OdbcClmData(1, vPrintJobDone);

      if (Erx <> _rOK) then begin
        Error(99,'ODBC-Error '+Aint(__LINE__)+': '+vCmd->spOdbcErrSqlMessage);
        BREAK;
      end;

      if (vPrintJobDone = 1) then begin
        // Datensatz ist in Datenbank angekommen, jetzt Metadaten extrahieren und Binärdaten separat lesen
        vCmd->OdbcClmData(6, aEma);
        vCmd->OdbcClmData(7, aFax);
        vCmd->OdbcClmData(8, aLang);
        vCmd->OdbcClmData(9, gBCPS_ResultJson);
        
        vCmd->OdbcClose();

        // Daten lesen
        vSql   # 'SELECT Data, ResultJson FROM TempDokumente WHERE JobID=' + StrChar(39)+ aPrintJobId + StrChar(39);
        vCmd   # gODBCCon->OdbcExecuteDirect(vSql);
        if (vCmd = _ErrOdbcError) or (vCmd =_ErrOdbcFunctionFailed) then begin
          Error(99,'ODBC-Error '+Aint(__LINE__)+': '+vCmd->spOdbcErrSqlMessage);
          BREAK;
        end;
        // Daten lesen
        if (vCmd->OdbcFetch() <> _ErrOk) then begin
          Error(99,'ODBC-Error '+Aint(__LINE__)+': '+vCmd->spOdbcErrSqlMessage);
          BREAK;
        end;

        // Binäre Daten lesen
        vMemObjB64kodiert # MemAllocate(_Mem512M);    // 11.06.2016 AH: war 16M
        vMemObjB64kodiert->spLen # 0;
        Erx # vCmd->OdbcClmData(1, vMemObjB64kodiert);
        if (Erx<>_rOK) then begin
          Error(99,'ODBC-Error '+Aint(__LINE__)+': '+vCmd->spOdbcErrSqlMessage);
          BREAK;
        end;

        // 09.01.2020 AH: mit Resultdictionary
        Erx # vCmd->OdbcClmData(2, aResultJson);
        if (Erx<>_rOK) then begin
          Error(99,'ODBC-Error '+Aint(__LINE__)+': '+vCmd->spOdbcErrSqlMessage);
          BREAK;
        end;

//debug('vMemObjB64kodiert->spLen = ' + Aint(vMemObjB64kodiert->spLen));
        vCmd->OdbcClose();

        // von Base64 zurück konvertieren
        vMemObjBinaer # MemAllocate(_Mem128M);      // 11.06.2016 AH: war 16M
                                                    // 22.08.2016 ST: von 512M auf 128M,
                                                    //  da es einige Rechner überforderte

        vMemObjB64kodiert->MemCnv(vMemObjBinaer,_MemDecBase64);

        // File schreiben
        vFile # FsiOpen(aPath+'.'+aExtention, _FsiCreate | _FsiStdWrite);
        if (vFile > 0) then begin
          FsiWriteMem(vFile,vMemObjBinaer,1,vMemObjBinaer->spLen);
          FSIClose(vFile);
        end
        else begin
          Error(99,'ODBC-Error '+Aint(__LINE__)+': Datei "'+aPath+'.'+aExtention+'"konnte nicht geschrieben werden.');
        end;

        // Aufräumarbeiten
        if (vMemObjB64kodiert> 0) then  vMemObjB64kodiert->MemFree();
        if (vMemObjBinaer > 0) then  vMemObjBinaer->MemFree();

        // Datensatz löschen
        vSql   # 'DELETE FROM TempDokumente WHERE JobID=' + StrChar(39)+ aPrintJobId + StrChar(39);
        vCmd   # gODBCCon->OdbcExecuteDirect(vSql);
        if (vCmd = _ErrOdbcError) or (vCmd =_ErrOdbcFunctionFailed) then begin
          Error(99,'ODBC-Error '+Aint(__LINE__)+': '+vCmd->spOdbcErrSqlMessage);
          BREAK;
        end;
        vCmd->OdbcClose();

        vOK # true;   // Alles IO
        BREAK;
      end; //  EO if (vPrintJobDone = 1) then begin

    end;


    // nächster Versuch?
    if (vTry > vMaxTries) then begin

      // ggf. Fragen, wie weiterverfahren werden soll
      if (aAskForAdditionaltime) then begin

        // ST 2017-06-27: Bei Listenausführung vom Jobserver nicht nachfragen
        if (gUsergroup = 'JOB-SERVER') OR (gUsergroup =*^'SOA*') then begin
          vTry # 0;
          CYCLE;
        end;

        Erx # msg(002000,'', _WinIcoWarning, _WinDialogYesNoCancel,1);
        If (Erx = _WinIdYes) then begin
          // weiter warten und wieder Fragen
          vTry # 0;
          CYCLE;
        end else if (Erx = _WinIdNo) then begin
          // weiter warten und nicht nochmal fragen -> danach Abbruch
          aAskForAdditionaltime # false;
          vTry # 0;
          CYCLE;
        end else begin
          // Abbruch -> nichts machen, direkt abbrechen
        end;
      end;

      // Ende
      BREAK;
    end;

    winsleep(vSleeptime);
  END;


  RETURN vOK;
end;


//========================================================================
//  sub ClearTempDoks() : logic;
//  Entfernt alle Einträge aus den temporären Druckdokumenten
//========================================================================
sub ClearTempDoks(aAuchAusgabeverzeichnis : logic) : logic;
local begin
  Erx               : int;
  vSql              : alpha(8000);    //  SQL Statement
  vCmd              : handle;         //  SQL Command Descr.

  // Für Löschen der Ausgabedaten
  vOutputpath       : alpha(8000);
  vDirOutputDir     : int;
  vFileName         : alpha(8000);
end;
begin

@ifdef LogCalls
debug('ClearTempDoks');
@endif

  if (gOdbcCon=0) then RETURN false;

  vSql   # 'TRUNCATE TABLE TempDokumente;';
  vCmd # gOdbcCON->OdbcExecuteDirect(vSql);
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    OdbcError(ThisLine,'ClearTempDoks failed',0);
    RETURN false;
  end;

  if (aAuchAusgabeverzeichnis) then begin

//    if ( StrFind(StrCnv( DbaName( _dbaAreaAlias ), _strUpper ),'TESTSYSTEM',1) > 0) then
    if (isTestsystem) then
      vOutputpath # Set.SQL.PrintSRVPath+'_TESTSYSTEM\PDF\'
    else
      vOutputpath # Set.SQL.PrintSRVPath+'\PDF\';

    vDirOutPutDir # FsiDirOpen(vOutputpath,0);
    FOR   vFileName # vDirOutPutDir->FsiDirRead();
    LOOP  vFileName # vDirOutPutDir->FsiDirRead();
    WHILE vFilename != '' DO BEGIN
      Erx # FsiDelete(vOutputpath + vFilename);
    END;

  end;


  RETURN true;
end;



//========================================================================
//
//
//========================================================================
sub RandomizeGUID() : alpha;
local begin
  vA,vB : alpha;
  vI    : int;
end;
begin

//      12345678-1234-1234-1234-123456789012
//      0822174F-539B-4967-9684-465AB37CA671 = 36

  vA # cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadZero,0,4)+
        cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadZero,0,4)+ '-'+
        cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadZero,0,4)+ '-'+
        cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadZero,0,4)+ '-'+
        cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadZero,0,4)+ '-'+
        cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadZero,0,4)+
        cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadZero,0,4)+
        cnvai( cnvif(random()*65535.0) ,_FmtNumHex|_FmtNumNoGroup|_FmtNumleadZero,0,4);
//  vA # Str_ReplaceAll(vA,' ','0');
  RETURN vA;
end;


//========================================================================
//========================================================================
sub RandomizeString(aAnz : int) : alpha;
local begin
  vI  : int;
  vA  : alpha;
end;
begin

  vA  # '';
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=aAnz) do begin
    if (vI<>1) and (Random()>0.8) then
      vA # vA + ' '
    else
      vA # vA + StrChar(65 + cnvif(random()*25.0));
  END;

  RETURN vA;
end;



//========================================================================
//  Testdaten200
//  call lib_ODBC:Testdaten200
//========================================================================
sub Testdaten200()
local begin
  vCMD    : int;
  vAnz    : int;
  vS      : alpha[100];
  vI,vJ   : int;
  vGUID   : alpha;
end;
begin

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=100) do begin
    vS[vI] # RandomizeString(cnvif(Random()*15.0)+5);
  END;

  vCmd # gOdbcCON->OdbcPrepare('INSERT INTO Material (RecId, Nummer, Guete, EigenmaterialYN, Dicke, Breite, Laenge) VALUES (?,?,?,?,?,?,?)');
//debugx('INSERT INTO Material (RecId, Nummer, Guete, EigenmaterialYN, Dicke, Breite, Laenge) VALUES ('+vGUID+',?,?,?,?,?,?)');

  vCmd->OdbcParamAdd(_TypeAlpha, 36,y);
  vCmd->OdbcParamAdd(_TypeInt);
  vCmd->OdbcParamAdd(_TypeAlpha, 20,y);
  vCmd->OdbcParamAdd(_TypeBool);
  vCmd->OdbcParamAdd(_TypeFloat);
  vCmd->OdbcParamAdd(_TypeFloat);
  vCmd->OdbcParamAdd(_TypeFloat);



  RecRead(200,1,_recLast);

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=500) do begin    // 500.000

    // 1000er Pakete
    FOR vJ # 1
    LOOP inc(vJ)
    WHILE (vJ<=1000) do begin
      inc(vAnz);
      Mat.Nummer          # 1000000+vAnz;

      Mat.Dicke           # Rnd(Random()*100.0,2);
      Mat.Breite          # Rnd(Random()*1000.0,2);
      "Mat.Länge"         # Rnd(Random()*10000.0,2);
      Mat.Anlage.Datum    # cnvdi(31000 + cnvif(Random()*365.0*30.0));
      Mat.Anlage.Zeit     # cnvti(cnvif(Random()*1000.0 * 60.0 * 60.0 * 24.0));
      Mat.EigenmaterialYN # Random()>0.5;
      "Mat.Güte"          # vS[1+cnvif(Random()*99.0)];

      vGUID # RandomizeGuid();

      vCmd->OdbcParamSet(1, vGUID);
      vCmd->OdbcParamSet(2, Mat.Nummer);
      vCmd->OdbcParamSet(3, "Mat.Güte");
      vCmd->OdbcParamSet(4, Mat.Dicke);
      vCmd->OdbcParamSet(5, Mat.Breite);
      vCmd->OdbcParamSet(6, "Mat.Länge");

      // Execute...
      if (OdbcExecute(vCmd)<>_ErrOK) then begin
Msg(99,'ODBC-Error : '+vCmd->spOdbcErrSqlMessage,0,0,0);
        BREAK;
      end;

    END;
debug('created : '+aint(vAnz)+'    Processmem:'+aint(_Sys->spProcessMemoryKB));
if (Msg(99,'Hab '+aint(vAnz)+'   Weiter?',_WinIcoQuestion,_WinDialogYesNo,1)<>_winidyes) then BREAK;
/**
    if (gOdbcCon<>0) then begin
      gOdbcCon->OdbcClose();
      gOdbcCon # 0;
    end;
    Init();
**/
  END;

  vCmd->OdbcClose();

end;


//========================================================================
//  MoveOldNew
//          Erzeugt neue Tabelle mit Postfix "_NEW"
//          Kopiert Inhalte von alter Tabelle rüber
//          löscht alte Tabelle und benennt die neue in die alte um
//========================================================================
sub MoveOldNew(
  aDatei      : int;
  opt aSilent : logic) : logic
local begin
  Erx       : int;
  vA,vB     : alpha(8096);
  vHdl      : int;
  vTabName  : alpha;
  vDia      : int;
  vMsg      : int;
  vCmd      : handle;
end;
begin

  if (gOdbcApi=0) then begin
    Lib_odbc:Init(TRUE);
  end;

  // ALL???
  if (aDatei=9999) then begin
    FOR aDatei # 1
    LOOP inc(aDatei)
    WHILE (aDatei<1000) do begin
      if (aDatei=210) then CYCLE;
      if (aDatei=410) then CYCLE;
      if (aDatei=411) then CYCLE;
      if (aDatei=510) then CYCLE;
      if (aDatei=511) then CYCLE;
      if (aDatei=545) then CYCLE;
      if (aDatei=470) then CYCLE;
      
      // 2022-10-26 AH
      vTabName # TableName(aDatei);
      if (vTabName='') then CYCLE;
      
      if (Table.Exists(vTabName)=false) then begin
//debugx('newtable '+aint(aDatei));
        if (ScriptOneTable(aDatei)=false) then begin
          OdbcError(ThisLine,'SCRIPT TABLE failed', aDatei);
          RETURN false;
        end;
        if (SyncOneTable(aDatei, true)=false) then begin
          OdbcError(ThisLine,'FILL TABLE failed', aDatei);
          RETURN false;
        end;
      end
      else begin
//debugx('altertable '+aint(aDatei));
        if (MoveOldNew(aDatei, true)=false) then begin
          OdbcError(ThisLine,'ALTERTABLE failed', aDatei);
          RETURN false;
        end;
      end;
    END;
    RETURN true;
  end;


  if (gOdbcCon=0) then RETURN true;
  vTabName # TableName(aDatei);
  if (vTabName='') then RETURN true;

  if (ScriptOneTable(aDatei, aSilent, '_NEW')=false) then begin
    Msg(99,'ODBC: CREATE _NEW TABLE failed!',_WinIcoError,_WinDialogOK,1);
    RETURN false
  end;


  vDia # WinOpen('Dlg.Pause',_WinOpenDialog);
  vMsg # Winsearch(vDia,'Label1');
  vMsg->wpcaption # 'Moving values : '+aint(aDatei);
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenterScreen);//, gFrmMain);

  // Execute GETCOLUMS...
  vCmd # gOdbcCON->OdbcExecuteDirect('SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '''+vTabName+'''');
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    Winclose(vDia);
    Msg(99,'ODBC: SELECT COLUMN_NAMES failed!',_WinIcoError,_WinDialogOK,1);
    RETURN false;
  end
  else begin
    // create statement + parameter...
    WHILE (vCMD->OdbcFetch() = _ErrOk) do begin
      Erx # vCmd->OdbcClmData(1, vA);
      if (vB<>'') then
        vB # vB + ',';
//      if (vA=^'KEY') then vA # '"'+vA+'"';    // 2022-10-26 AH
      vA # '"'+vA+'"';                  // 2023-03-09 AH
      vB # vB + vA;
    END;
    vCMD->OdbcClose();
  end;


  // Execute COPY...
  
  vCmd # gOdbcCON->OdbcExecuteDirect('INSERT INTO '+vTabName+'_NEW ('+vB+') SELECT '+vB+' FROM '+vTabName);
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    Winclose(vDia);
    OdbcError(ThisLine,'COPY CONTENT failed', aDatei);
    RETURN false;
  end;
  vCMD->OdbcClose();

  // Execute DROP ...
  vCmd # gOdbcCON->OdbcExecuteDirect('DROP TABLE ['+vTabName+']');
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    Winclose(vDia);
    if (aSilent=false) then Msg(99,'ODBC: DROP TABLE failed!',_WinIcoError,_WinDialogOK,1);
    RETURN false;
  end;
  vCMD->OdbcClose();


  // Execute RENAME...
  vCmd # gOdbcCON->OdbcExecuteDirect('exec sp_rename '''+vTabName+'_NEW'', '''+vTabName+'''');
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    Winclose(vDia);
    Msg(99,'ODBC: RENAME TABLE failed!',_WinIcoError,_WinDialogOK,1);
    RETURN false;
  end;
  vCMD->OdbcClose();

  Winclose(vDia);
  if (aSilent=false) then
    Msg(99,'Table '+aint(aDatei)+' altered SUCCESSUFULLY !!!',0,0,0);

  RETURN true;
end;


//========================================================================
//========================================================================
// call lib_ODBC:Test
//========================================================================
sub Test();
local begin
  Erx       : int;
  vI        : int;
  vCmd      : handle;
  vTabName  : alpha;
  vA,vB     : alpha(8000);
  vErg      : int;
end;
begin

vTabName # 'Anrede';

  // Execute GETCOLUNS
  vCmd # gOdbcCON->OdbcExecuteDirect('SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '''+vTabName+'''');
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    Msg(99,'ODBC: SELECT COLUMN_NAMES failed!',_WinIcoError,_WinDialogOK,1);
  end
  else begin
    // create statement + parameter...
    WHILE (vCMD->OdbcFetch() = _ErrOk) do begin
      Erx # vCmd->OdbcClmData(1, vA);
      if (vB<>'') then
        vB # vB + ',';
      vB # vB + vA;
    END;
    vCMD->OdbcClose();
  end;

  // Execute COPY
  vCmd # gOdbcCON->OdbcExecuteDirect('INSERT INTO '+vTabName+'_NEW ('+vB+') SELECT '+vB+' FROM '+vTabName);
debugx('INSERT INTO '+vTabName+'_NEW ('+vB+') SELECT '+vB+' FROM '+vTabName);
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
    OdbcError(ThisLine,'COPY CONTENT failed', 123);
    RETURN;
  end;

  vCMD->OdbcClose();
end;


//========================================================================
//  BulkImport
//
//========================================================================
sub BulkImport(
  aDatei  : int;
  aFilename : alpha(8000)) : logic;
local begin
  vTabName  : alpha;
  vA        : alpha(8000);
end;
begin

@ifdef LogCalls
debug('ODBC_BulkImport '+aint(aDatei)+' from '+aFilename);
@endif

  if (gOdbcCon=0) then RETURN true;
  vTabName # TableName(aDatei);
  if (vTabName='') then RETURN true;

  vA # 'BULK INSERT '+vTabNAme+' FROM '''+aFilename+'''';
  vA # vA +' WITH (';
  vA # vA +' FIELDTERMINATOR =''\r'',';
  vA # vA +' RowTerminator = ''\r\n'',';
  vA # vA + ' Codepage = ''1252'',';        // ANSI
  vA # vA + ' datafiletype = ''char''';
  vA # vA +');';
debug(vA);
  if (Lib_Odbc:ExecuteDirect(vA)=false) then begin
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================