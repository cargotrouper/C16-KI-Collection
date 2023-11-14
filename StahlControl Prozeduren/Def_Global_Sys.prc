@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_Global_Sys
//                    OHNE E_R_G
//  Info        globale Variabeln/Makrodefinition
//
//  !!! GESCHÜTZT DURCH LIZENZ !!! NICHT MANIPULIEREN !!!
//  !!! GESCHÜTZT DURCH LIZENZ !!! NICHT MANIPULIEREN !!!
//  !!! GESCHÜTZT DURCH LIZENZ !!! NICHT MANIPULIEREN !!!
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
define begin

  TODO(a)     : Lib_Debug:Dbg_Todo(a)
  TODOX(a)    : Lib_Debug:Dbg_Todo(__PROC__+':'+aint(__LINE__)+' '+a)
  Debug(a)    : Lib_Debug:Dbg_Debug(a)//;WinDialogBox(0,'DEBUG',a,_WinIcoInformation,_WinDialogOk,0)
  DebugX(a)   : Lib_Debug:Dbg_Debug(a+'   ['+__PROC__+':'+aint(__LINE__)+']')
  DebugStamp(a) : Lib_Debug:dbg_Debug(cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+' '+a)
  Trace(a)    : DbgTrace(a)
  DebugStop   : DbgTrace('***STOP***'); DbgControl(_DbgStop)

  //*************************************************
  Error(a,b)  : Lib_Error:_Error_WrapperWithLog(here, a, b, __PROCFUNC__, __LINE__);
  ErrorOutput : Lib_Error:_Output();
  Warning(a,b)  : Lib_Error:_Warning_WrapperWithLog(a, b, __PROCFUNC__, __LINE__);
  WarningOutput : Lib_Error:_WarningOutput();

  //*************************************************
  RGB( r, g, b ) : ( r + ( g << 8 ) + ( b << 16 ) )

  Translate(a) : Lib_GuiCom:Gui_Translate(a)
  GetDialogName(a) : Lib_GuiCom:GetAlternativeName(a)

  Msg(a,b,c,d,e) : Lib_Messages:Messages_Msg_WrapperWithLog(a,b,c,d,e,  __PROCFUNC__, __LINE__)

  Wae_Umrechnen(a,b,c,d) : Lib_Berechnungen:Waehrung_Umrechnen(a,b,c,d)

  Str_Token(a,b,c)      : Lib_Strings:Strings_Token(a,b,c)
  Str_PosNum(a,b,c)     : Lib_Strings:Strings_PosNum(a,b,c)

  Sort_ItemAdd(a,b,c,d) : Lib_RamSort:ItemAdd(a,b,c,d)
  Sort_ItemFirst(a)     : Lib_RamSort:ItemFirst(a)
  Sort_ItemLast(a)      : Lib_RamSort:ItemLast(a)
  Sort_ItemNext(a,b)    : Lib_RamSort:ItemNext(a,b)
  Sort_ItemPrev(a,b)    : Lib_RamSort:ItemPrev(a,b)
  Sort_KillList(a)      : Lib_RamSort:KillList(a)

  RekInsert         : Lib_Rec:Insert
  RekReplace        : Lib_Rec:Replace
  RekDelete         : Lib_Rec:Delete
  RekDeleteAll(a)   : Lib_Rec:DeleteAll(a)
  TransOn           : Lib_Rec:RekTransOn();
  TransOff          : Lib_Rec:RekTransOff();
  TransBrk          : Lib_Rec:RekTransBrk();

  Sel_Build(a,b,c,d,e)  : Lib_Misc:BuildSel(var a, b, c, d, e);

  RekSave(a)        : Lib_Rec:_RekSave(a);
  RekRestore(a)     : Lib_Rec:_RekRestore(a);

  here              : _Sys->spProcCurrent
  Now               : Systime(_TimeSec | _TimeServer)
  Today             : SysDate()
  Lockedby          : UserInfo(_UserName, CnvIA(userinfo(_UserLocked)))+'('+UserInfo(_UserSysName, CnvIA(userinfo(_UserLocked)))+')'



  Mode              :   w_Mode//gMdi->wpCustom

  MyTmpNummer           : 1000000000+gUserId
  MyTmpText             : 'Tmp.'+cnvai(gUserId,_FmtNumNoGroup)
  MyTmpSel              : 'Tmp.'+cnvai(gUserId,_FmtNumNoGroup)
  cPrgName              : 'BUSINESS CONTROL'

  // maximale Anzahl der Rechte
  cMaxRights            : 1000
  cMaxCustomRights      : 1000

  sDayTime              : 8
  // Parameter für die Funktionen von Gui_Com
  sModeRlsView          : 1
  sModeRlsKey           : 2
  sModeTBar             : 3
  sModeSBar             : 4

  c_ModeBald            : '>'
  c_ModeList            : 'LIST'
  c_ModeList2           : 'LIST2'
  c_ModeView            : 'VIEW'
  c_ModeEdit            : 'EDIT'
  c_ModeEdit2           : 'EDIT2'
  c_ModeNew             : 'NEW'
  c_ModeNew2            : 'NEW2'
  c_ModeSave            : 'SAVE'
  c_ModeCancel          : 'ESC'
  c_ModeClose           : 'CLOSE'
  c_ModeDelete          : 'DEL'
  c_ModeRecNext         : 'RECNEXT'
  c_ModeRecPrev         : 'RECPREV'
  c_ModeRecFirst        : 'RECFIRST'
  c_ModeRecLast         : 'RECLAST'
  c_ModeSearch          : 'SEARCH'
  c_ModeOther           : '---'

  c_ModeEdList          : 'EDLIST'
  c_ModeEdListNew       : 'EDLISTNEW'
  c_ModeEdListEdit      : 'EDLISTEDIT'
  c_ModeEdListNew2Save  : 'EDLISTNEW2SAVE'
  c_ModeEdListEdit2Save : 'EDLISTEDIT2SAVE'

//  ColInactive : ((((235<<8)+235)<<8)+235);
//  ColInactive : ((((216<<8)+233)<<8)+236);
//  ColInactive : _WinColScrollbar;//((((225<<8)+225)<<8)+225);
//  ColInactive : _WinColInactiveCaptionText;//((((225<<8)+225)<<8)+225);
//  ColFocus    : _WinColBlack;//((((000<<8)+240)<<8)+240);
    ColFocus : (((175<<8)+177)<<8)+087;
    //aEvt:Obj->wpColFocusBkg # (((175<<8)+177)<<8)+100;
    //aEvt:Obj->wpColFocusBkg # (((90<<8)+160)<<8)+190;
end;

// für ein dynamische Druckzeile
global class_PrintLine begin
  pls_Prt       : int;
  pls_Hdl       : int;
  pls_Current   : int;
  pls_FontSize  : int;
  pls_FontAttr  : int;
  pls_Inverted  : logic;
  pls_FontName  : alpha;
  pls_Format    : int;
  pls_Name      : alpha(32);

  pls_PosY      : int;
  pls_TmpPosY   : int;
end;


// GESCHÜTZTE globals: *****************************************************
// GESCHÜTZTE globals: *****************************************************
// GESCHÜTZTE globals: *****************************************************
global VarSys begin
  gUserSettings         : int;
  Rechte                : logic[cmaxrights];
  CustomRechte          : logic[cmaxCustomrights];
  ProtokollBuffer       : int[999];
  gMarkList             : int;
  Erg                   : int;
  TransActive           : logic;
  TransCount            : int;
  gTempMode             : alpha;         // Variable zum Zwischenspeichern des Verarbeitungsmodus
                                         // beim Dialog BAG.FertMeld.User in der Prozedur BAGPosFertUser_main
  gWindowRefreshYN      : logic;
  gDebugDepth           : int;          // Zähler für "Tiefe" der Verschachtelung von Prozeduren

  // System Variablen
  gUserID               : int;          // ID des aktuellen Users
  gUserName             : alpha(20);
  gUserNameBAGFert      : alpha(20);    // Username des BAG-Users bei Fertigmeldungen

  // Deskriptoren von Objekten
  gTAPI                 : int;
  gTAPIDev              : int;

  // eingeladene DLLs...
  gDLL_Sound            : handle;

  gTmp                  : int;
  gTmpA                 : Alpha;
  gTimer                : int;
  gTimer2               : int;

  gFrmMain              : int;          // Deskr. vom Hauptfenster

  gMdiAdr               : int;          // Deskr. vom MDI-Fenster Adressen
  gMdiMat               : int;          // Deskr. vom MDI-Fenster Material
  gMdiAuf               : int;          // Deskr. vom MDI-Fenster Aufträge
  gMdiEin               : int;          // Deskr. vom MDI-Fenster Einkäufe
  gMdiBdf               : int;          // Deskr. vom MDI-Fenster Bedarfsdatei
  gMdiLFS               : int;          // Deskr. vom MDI-Fenster Lieferscheine
  gMdiVsP               : int;          // Deskr. vom MDI-Fenster Versandpool
  gMdiPrj               : int;          // Deskr. vom MDI-Fenster Projekte
  gMdiBAG               : int;          // Deskr. vom MDI-Fenster Betriebsaufträge
  gMdiGantt             : int;          // Deskr. vom MDI-Fenster Gantt-Graph
  gMdiMsl               : int;          // Deskr. vom MDI-Fenster Materialstruktur
  gMdiQS                : int;          // Deskr. vom MDI-Fenster Reklakationen/QS

  gMdiErl               : int;          // Erlöse
  gMDIEKK               : int;          // EKK
  gMDIOfp               : int;          // Offene Posten
  gMDIERe               : int;          // Eingangsrechnungen

  gMdiMenu              : int;          // Deskr. vom Menuebaum
  gMdiWorkbench         : int;          // Desk.  vom temp.Arbeitstisch
  gMdiNotifier          : int;          // Deskr. vom Notifier
  gFrmUsr               : int;          // Deskr. vom Benutzerfenster (Login)
  gMdiPara              : int;          // Deskr. vom MDI-Parameter
  gMdiDashboard         : int;          // Deskr. vom MDI-Dashboard

  gMdiTermine           : int;          // Deskr. vom MDI-Fenster Aktivitäten

  gMdiRsoKalender       : int;          // Deskr. vom MDI Fenster Rso Kalender
  gMdiRso               : int;          // Deskr. vom MDI-Fenster Ressourcen

  gMdiArt               : int;          // Deskr. vom MDI-Artikelfenster

  gMdiMathCalculator    : int;          // Deskriptor Technischer Kalkulator
  gMdiMath              : int;          // Deskr. vom Mdi-Mathematik/Formelfenster
  gMdiMathVar           : int;          // Deskr. vom Mdi-Mathematikvariablenfenster
  gMdiMathAlphabet      : int;          // Deskripror Mdi-Mathematikalphabet , 827
  gMdiMathVarMiniPrg    : int;          // Deskriptor Mathematikminiprogeamme für Makrovariablen
  gMDIList              : handle;       // Deskriptor für alle MultiFenster

  // globale Verwaltung
  gMdi                  : int;
  gMenu                 : int;
  gToolbar              : int;
  g_sSelected            : alpha(100);  // Globale Übergabevariable aus dem Dialog Math.Alphabet.MiniPrg
  gSelected             : int;
  gPrintOrders          : int;
  gRemoteSocket         : int;

  // externe Daten
  gFsiClientPath        : alpha;        // Pfadangabe des Clients

  // Dokumentenablage
  gDokTyp               : alpha(5);     // Typ des Dokuments

  // Word
  gWordDefPath          : alpha(128);
  gWordJN               : logic;

  //Excel
  gExcelDefPath          : alpha(128);
  gExcelJN              : logic;
end

//========================================================================
