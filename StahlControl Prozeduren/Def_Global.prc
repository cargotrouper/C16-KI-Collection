@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_Global
//                    OHNE E_R_G
//  Info        globale Variabeln/Makrodefinition
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  10.02.2020  AH  Neu: gKeyID
//  2022-08-11  DS  Neu: Konstanten für Zeilenvorschübe
//  2023-03-28  DS  Neu: Konstanten Log-Levels und Verbosities
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global_Sys     // geschützte Systembereiche einbinden


define begin

  // Das Anzeigen des detaillierten ErrorTrace beim Kunden soll deaktiviert sein.
  // Für Notfälle beim Kunden kann man es hier jedoch temporär aktivieren.
  // UNBEDINGT DANACH WIEDER false SETZEN!
  DEBUG_showErrorTrace_beim_Kunden : false

  // Zeilenvorschübe
  cCrlf        : StrChar(13) + StrChar(10)
  cCrlf2       : StrChar(13) + StrChar(10) + StrChar(10)
  // Tabulatorzeichen
  cTab         : StrChar(9)
  
  /*
  siehe auch: http://vm_tfs:8080/tfs/DefaultCollection/Dokumente/_git/BCS?path=%2FCodinghandbuch%2Ffehlerbehandlung.md&version=GBmaster&_a=preview
  * cErxSTD und cErxSFX sind SC-weite Codes für SC-custom Errors.
  * cErxSTD steht für "Fehler im STD Code".
  * cErxSFX steht für "Fehler in AFX/SFX Code".
  * cErxNA steht für "N/A: Kein Erx im lokalen Kontext verfügbar" und wird an Stellen als Erx genutzt, wo die Existenz eines echten Erx-Wertes
    nicht garantiert werden kann.
  * Diese Werte dienen also dazu, von C16 erzeugte Erx Werte von diesen beiden (einzigen) in SC generierten Erx Werten zu unterscheiden.
  * Eine Unterscheidung nach Fehlertyp und eine Möglichkeit zur Lokalisierung der Fehler-Orte liefert das Makro complain(), s.u.
  * Daher kommt SC mit diesen zwei Erx Werten aus.
  * Beispiel 1:
    * Meine SC Funktion im STD erhält einen illegalen Wert als Argument
    * Dann: "return cErxSTD"
    * Detailliertes Beispiel der Fehlerbehandlung: !Template2022:fTemplate
    * (analog für AFX/SFX mit cErxSFX)
  * Beispiel 2:
    * Eine Datenoperation (z.B. RecRead) liefert einen Erx Wert <> _ErrOK
    * Dann "return Erx" (C16 Fehlerwerte unverändert rausreichen)
    * Detailliertes Beispiel der Fehlerbehandlung: !Template2022:fTemplate
  Aufgrund der Werte kann der Caller unterscheiden ob er einen C16-Fehler oder einen SC-Fehler erhalten hat, und in letzterem Fall
  auch, ob es ein Fehler in einer STD Funktion oder AFX/SFX ist. Bei der Fehlerdiagnose hilft das Makro showErrorTrace, s.u. bzw.
  die MAIN Funktion in !Template2022
  */
  cErxSTD : -2000000
  cErxSFX : -3000000
  cErxNA :  -4000000
  
  // Konstanten für Log-Levels
  cLogInfo : 0
  cLogWarn : 1
  cLogErr  : 2
  
  // Konstanten für Verbosities:
  // (für eine genaue Erläuterung des Verhaltens, siehe Doku des Parameters Verbosity von Lib_Error:_complain())
  cVerbSilent   : 0
  cVerbPost     : 1
  cVerbInstant  : 2
  
end


define begin
//  Appoff          : if (gUsername<>'FILESCANNER') then gFrmMain->wpdisabled # y;
//  AppOn           : if (gUsername<>'FILESCANNER') then gFrmMain->wpdisabled # n;
  ErxError(a,b)   : Lib_Error:_ErxError(Erx, ThisLine, a, b);
  Wupdate(a)      : if (a<>0) then Winupdate(a)
  WinUnload(a)    : Lib_Auxiliaries:_WinUnload(a)
  Appoff(a)       : Lib_GuiCom2:DoAppOff(a)
  AppOn           : Lib_GuiCom2:DoAppOn
  RunAFX(a,b)     : Lib_SFX:Run_AFX(a,b)
  SpeziAFX(a,b,c) : if (Set.Installname=a) then Lib_SFX:Run_AFX(b,c)
  ABool(a)        : CnvAi(cnvil(a))
  ANum(a,b)       : CnvAf(a,_FmtNumNoGroup,0,b)
  AInt(a)         : CnvAI(a,_FmtNumNoGroup)
  ADatReverse(a)  : cnvai(a->vpYear,_FmtNumleadzero|_FmtNumNoGroup,0,4)+cnvai(a->vpMonth,_FmtNumleadzero,0,2)+cnvai(a->vpDay,_FmtNumleadzero,0,2)
  TextAddLine(a,b):  TextLineWrite(a,TextInfo(a,_TextLines)+1,b,_TextLineInsert)
  DebugUser(a)  : Lib_Debug:Dbg_Debug(a,true)
  DoLogProc       :
  //if (gUsername='PW') then debug(_Sys->spProcCurrentFull)
  TOX : todox('')
  ThisLine : __PROC__+':'+aint(__LINE__)

  Str_Replaceall(a,b,c) : Lib_Strings:Strings_ReplaceAll(a,b,c)
  Str_Count(a,b)        : Lib_Strings:Strings_Count(a,b)
  Str_Contains(a,b)     : (Lib_Strings:Strings_Count(a,b) > 0)
  Str_StartsWith(a,b)   : Lib_Strings:StartsWith(a,b)
  Str_EndsWith(a,b)     : Lib_Strings:EndsWith(a,b)

  assert(a)   : Lib_Auxiliaries:_assert(a, __PROC__+':'+aint(__LINE__))
  ErrorOutputWithDisclaimerPre(aDescriptionOfNextOperation)  : Lib_Error:_ErrorOutputWithDisclaimerPre(aDescriptionOfNextOperation)
  ErrorOutputWithDisclaimerPost(aDescriptionOfNextOperation) : Lib_Error:_ErrorOutputWithDisclaimerPost(aDescriptionOfNextOperation)
  // Aktuell ist Log Lvl 2 (Error) fest im Makro von complain verdrahtet, siehe letztes Argument:
  complain(Verbosity, Erm) : Lib_Error:_complain(__PROCFUNC__, __LINE__, Erx, Verbosity, Erm, cLogErr)
  showErrorTrace : Lib_Error:_showErrorTrace

  DebugM(a)   : Lib_Debug:Dbg_Msg(a,__PROC__+':'+aint(__LINE__))
  DebugFile(a,b)  : Lib_Debug:_DebugFile(a,b)
  SetStdAusFeld(a,b)    : Lib_Pflichtfelder:SetStdAuswahlFeld(a,b);
  SetSpeziAusFeld(a,b)  : Lib_Pflichtfelder:SetStdAuswahlFeld(a,b,y);
  c_ColInactive   : ((((225<<8)+225)<<8)+225)
  STD_Protokoll(a)    : if (gProtokollText<>0) { TextLineWrite(gProtokollText, 1, a, _TextLineInsert); if (gProtokollGUIText<>0) gProtokollGUIText->WinUpdate(_WinUpdBuf2Obj) }

  RekLinkB(a,b,c,d) : Lib_Rec:LinkBuf(var a,b,c,d)
  RekLink(a,b,c,d)  : Lib_Rec:LinkConst(a,b,c,d)

  RekBufKill(a)     : Lib_Rec:BufKill(var a)
  RefreshList(a,b)  : Lib_GuiCom2:Refresh_list(a,b)
  SetFocus(a,b)     : Lib_Guicom2:DoSetFocus(a,b)

  TxtWrite(a,b,c)   : Lib_Texte:Text_Write(a,b,c)
  TxtDelete(a,b)    : Lib_Texte:Text_Delete(a,b)
  TxtRename(a,b,c)  : Lib_Texte:Text_Rename(a,b,c)
  TxtCopy(a,b,c)    : Lib_Texte:Text_Copy(a,b,c)
  TxtCreate(a,b)    : Lib_Texte:Text_Create(a,b)

  DivOrNull(a,b,c,d)  : if (c=0.0) then a # 0.0 else a # Rnd(b / c,d)
  IsTestsystem        : ( StrFind(StrCnv( DbaName( _dbaAreaAlias ), _strUpper ),'TESTSYSTEM',1) > 0)
  
  MsgInfo(a,b) : Msg(a,b,_WinIcoInformation,_WinDialogOk,1)
  MsgWarn(a,b)  : Msg(a,b,_WinIcoWarning,_WinDialogOk,1)
  MsgErr(a,b)  : Msg(a,b,_WinIcoError,_WinDialogOk,1)
  
  MsgJaNein(a,b,c)  : Msg(a,b,_WinIcoQuestion,_WinDialogYesNo,c)
end;

// Dateinummern für Warengruppe *************************************
define begin
//  c_Wgr_Material      : 200
//  c_Wgr_bisMaterial   : 205   // 209
//  c_Wgr_Artikel       : 250
//  c_Wgr_bisArtikel    : 255   // 259
//  c_Wgr_Charge        : 252
//  c_Wgr_ArtMatMix     : 209
//  c_Wgr_MixArt        : 259
//  c_Wgr_MixMat        : 209
//  c_Wgr_Hilfsstoffe   : 180

  // Auftragsarten ****************************************************
  c_VorlageAuf        : 'VOR'
  c_Ang               : 'ANG'
  c_Auf               : 'AUF'
  c_REKOR             : 'REKOR' //'GUT-KD'
  c_GUT               : 'GUT'   //'GUT-LF'
  c_Bel_KD            : 'BEL-KD'
  c_Bel_LF            : 'BEL-LF'
  c_Bestellung        : 'BEST'
  c_Anfrage           : 'ANF'
  c_BoGut             : 'BOGUT'

  // Erlöstypen *******************************************************
  c_Erl_VK            : 400
  c_Erl_SammelVK      : 401
  c_Erl_StornoVK      : 409
  c_Erl_REKOR         : 410
  c_Erl_StornoREKOR   : 419
  c_Erl_Bel_KD        : 420
  c_Erl_StornoBel_KD  : 429
  c_Erl_Gut           : 415
  c_Erl_StornoGut     : 418
  c_Erl_Bel_LF        : 425
  c_Erl_StornoBel_LF  : 428
  c_Erl_BoGut         : 416
  c_erl_StornoBoGut   : 417
end;

// für jedes Fenster ************************************************
global WindowBonus begin
  w_MDI                 : int;
  w_Mode                : alpha(16);
  w_BaldPage            : alpha(32);
  w_Parent              : int;
  w_Child               : int;
  w_AuswahlMode         : logic;
  w_TermProc            : alpha;
  w_TermProcPara        : alpha;
  w_LastFocus           : int;
  w_NoList              : logic;
  w_NoClrView           : logic;
  w_NoClrList           : logic;
  w_Name                : alpha(32);
  w_SelName             : alpha(20);
  w_Sel2Name            : alpha(20);
  w_SelVorherName       : alpha(20);
  w_SelVorherHdl        : int;
  w_SelKeyProc          : alpha;
  w_SelKeyPara          : alpha;
  w_Objects             : int;
  w_AppendNr            : int;
  w_BinKopieVonRecID    : int;
  w_BinKopieVonDatei    : int;
  w_TimerVar            : alpha(32);
  w_Context             : alpha(32);
  w_Command             : alpha(32);
  w_Cmd_Para            : alpha(16);
  w_ListQuickEdit       : logic;
  w_Pflichtfeld         : int; // MS 23.03.2010
  w_Obj2Scale           : int;
  w_ZoomX               : float;
  w_ZoomY               : float;
  w_Obj4Auswahl         : int;
  w_noView              : logic;
  w_Listen              : alpha;
  w_SfxInfo             : alpha;
  w_AktiverFilter       : alpha;

  // quickbar
  w_QBButton            : int;
  w_QBHeight            : int;

  gFormParaHdl          : int;
  gTitle                : alpha(100);
  gPrefix               : alpha(20);
  gFile                 : int;
  gKey                  : int;
  gSuchProc             : alpha(100);
  gKeyID                : int;
  gZLList               : int;
  gDataList             : int;
  gMenuname             : alpha(32);
  gMenuEvtProc          : alpha(50);

  gZonelist             : int;

  w_AufruferMDI         : int;

  w_MoreBufs            : int;
  w_CopyToBuf           : int;
end;


// für einen Formulardruck *****************************************
global class_Form begin
  form_Job        : int;
  form_Page       : int;
  form_Header     : int;
  form_Footer     : int;
  form_Landscape  : logic;
  form_OutType    : alpha;
  form_Background : alpha(200);
  form_RandOben   : float;
  form_RandUnten  : int;
  form_printer    : int;
  form_useStdHead : logic;
  form_useStdFoot : logic;
  form_Betreff    : alpha(128);
  form_Faxnummer  : alpha(32);
  form_EMA        : alpha(128);
  form_Mode       : alpha(32);
  form_Lang       : alpha(3);
  Form_DokName    : alpha(32);
  form_DokSprache : alpha(1);
  form_DokAdr     : int;
  form_IsForm     : logic;

  form_FooterH    : int;
  form_StyleDef   : int;
  form_StyleDef2  : int;
  form_StyleY     : int;
  Form_StyleYY    : int;
  form_StyleX     : int;
  Form_StyleXX    : int;
  form_StyleFont  : font;
  form_styleJustX : int;
  form_StyleBkg   : int;
  form_StyleCol   : int;
  form_StyleWordBreak : logic;
  Form_VLine      : point[20]
end;

// für einen Listendruck *****************************************
global class_List begin
  list_PL         : int;
  list_XML        : logic;
  list_LineFormat : int;
  list_Spacing    : float[200];
  list_Sum        : float[200];
  list_FileHdl    : int;
  list_FileName   : alpha(250);
  list_Mode       : alpha(32);
  list_FontSize   : int;
  list_MDI        : int;
  list_PDFPath    : alpha(4096);
  List_ComboName  : alpha;  // 2023-05-10 AH
end;

// public globals: *********************************************************
global VarSysPublic begin
//  ErrMsg                : int;
  Filter_Mat            : logic;
  Filter_EKK            : logic;
  Filter_Prj            : logic;
  Filter_ERe            : logic;
  Filter_ZEi            : logic;
  Filter_ZAu            : logic;
  Filter_Art            : logic;
  Filter_Art_C          : logic;
  Filter_BAG            : logic;
  Filter_VSD            : logic;
  Filter_REK            : logic;
  Filter_SWE            : logic;
  Filter_Ein_E          : logic;
  Filter_Auf            : logic;
  Filter_Ein            : logic;
  Filter_Afx            : logic; // [+] SR/Mr 1326/631
  gUserSprachnummer     : word;
  gUserSprache          : alpha(5);

  
  AfxRes                : int;
  //xErgA                 : alpha(1000);
  ErrList               : int;
  LastPrinter           : alpha;
  Context               : alpha(32);
  gNotifierCounter      : int;
  gUserGroup            : alpha;
  gSelectedColumn       : handle;
  gSelectedRowID        : int;
  gProtokollText        : handle;
  gProtokollGUIText     : handle;
  gSQLBuffer            : int;
  gDlgTAPI              : int;
  gAFXText              : int;
  gUserINI              : int;
  gCodePage             : int;
  gMdeNavigationsPfad   : alpha(1000);

  // PDFcreator
  gPDFName              : alpha(1000);
  gPDFTitel             : alpha(1000);
  gPDFDMS               : alpha;
  gPDFDMSPath           : alpha(1000);

  // Printserver
  gBCPS_Outputfile      : alpha(1000);
  gBCPS_Outputtype      : alpha;
  gBCPS_ResultJson      : alpha(4096);
  gLastDruckerID        : int;

  // SCOPE
  gScopeList            : int;
  gScopeActual          : int;
  gScopeTic             : int;
  gTransList            : int;

  gDragList             : handle;
  gOdbcApi              : handle;
  gGuidDll              : handle;
  gOdbcCon              : handle;
  gOdbcCmdInsert        : handle[1000];
  gOdbcCmdUpdate        : handle[1000];
  gTableCache           : handle[1000];
  
  gDBAConnect           : handle;
  gOdbcCounter          : int;
  gBagFmBackProc        : alpha;
  gOdbcLastError        : alpha(250);

  gTAPICalls            : int;
  gBCSDLL               : handle;
  gJobController        : handle;
  gJobWriter            : handle;
  gJobReader            : handle;
  gJobEvtProc           : alpha;
  
  gNetServerUrl         : alpha(1000);
  gNetServerPort        : int;
  gNetServerTyp         : int;
  gRemotePort           : int;

  gPause                : int;
  gBlueMode             : logic;

end;


// Logging-Variablen
// Initialisierung in App_Main:EvtCreated(), Nutzung in Lib_Logging
global VarLogging begin

  gLoggingEnabled  : logic;
  
  // Log wird in diese Datei geschrieben (gesamtes Log seit Lib_Logging:InitLogging())
  gLoggingFilename : alpha(1024);
  
  // Lokaler (!) ErrorTrace wird in dieser CteList gesammelt.
  // Sie funktioniert analog zu ErrList, enthält aber mehr Information,
  // die strukturell dieselbe ist wie das Log, sich aber nicht über die
  // gesamte Session erstreckt, sondern nur über die Klammer zwischen
  // ErrorOutputWithDisclaimerPre() und ErrorOutputWithDisclaimerPost()
  ErrTrace              : int;
  
end;


// für einen Formulardruck, der asynchron zurück kommt**********************
global Class_PrintOrder begin
  clPO_Filename   : alpha(4000);
  clPO_912        : int;
  clPO_DMSName    : alpha(4000);
  clPO_OutputFile : alpha(4000);
  clPO_OnlyCreate : logic;
end;

// WORKFLOW *****************************************************************
define begin
  _WOF_KTX_NEU  : 'NEU'
  _WOF_KTX_DEL  : 'LÖSCHEN'
  _WOF_KTX_EDIT : 'EDITIEREN'
  _WOF_KTX_TIMO : 'TIMEOUT'
end
//========================================================================
//========================================================================
//========================================================================