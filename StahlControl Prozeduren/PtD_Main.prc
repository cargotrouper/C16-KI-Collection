@A+
//==== Business-Control ==================================================
//
//  Prozedur    PtD_Main
//                    OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  22.06.2012  ST  Mehrfaches einfügen durch Delay in "sub Compare" Prj. 1326/247
//  25.06.2013  AH  Deleted nimmt Grund auf
//  10.11.2017  TM  Alle Protokolle ein/aus per Button Prj. 1326/541
//  17.09.2019  AH  Neu: "Compare" kann Protokoll auch an ANDERER Datei hängen
//  05.10.2020  AH  Deleted: Temporäre Sätze nicht protokollieren
//  16.03.2022  AH  ERX
//  2022-07-04  AH  "IsInUse"
//  2022-11-24  AH  primär wird "gUserName" genutzt
//  2023-01-09  AH  BugFix für alle/keiner
//
//  Subprozeduren
//    SUB ProtokollAktiv(aDatei : int) : logic;
//    SUB IsInUse
//    SUB Memorize(aDatei : int);
//    SUB Forget(aDatei : int);
//    SUB Compare(aDatei : int);
//    SUB View(aDatei : int; opt aDatum : date; opt aZeit : time; opt aUser : alpha;opt aDelDatum : date; opt aDelZeit : time; opt aDelUser : alpha; opr aGrund: alpha);
//    SUB Deleted(aDatei : int; opt aGrund  : alpha);
//    SUB EvtClicked(aEvt : event);
//    SUB ManageStatus();
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB AlleAktiv()
//    SUB AlleInAktiv()
//========================================================================
@I:Def_Global
@I:Def_Rights

LOCAL begin
end;

//========================================================================
// ProtkollAktiv(Datei)
//                      sagt ja/nein, ob diese Datei protokolliert werden soll
//========================================================================
sub ProtokollAktiv(
  aDatei : int
): logic;
begin
  if (aDatei>=1) and (aDatei<=250) then
    RETURN (StrCut(Set.PtD.Status1,aDatei,1)='+');
  if (aDatei>=251) and (aDatei<=500) then
    RETURN (StrCut(Set.PtD.Status2,aDatei-250,1)='+');
  if (aDatei>=501) and (aDatei<=750) then
    RETURN (StrCut(Set.PtD.Status3,aDatei-500,1)='+');
  if (aDatei>=751) and (aDatei<=999) then
    RETURN (StrCut(Set.PtD.Status4,aDatei-750,1)='+');
end;


//========================================================================
// ProtkollDelAktiv(Datei)
//                      sagt ja/nein, ob diese Datei protokolliert werden soll
//========================================================================
sub ProtokollDelAktiv(
  aDatei : int
): logic;
begin
  if (aDatei>=1) and (aDatei<=250) then
    RETURN (StrCut(Set.PtD.Status1,aDatei,1)<>'-');
  if (aDatei>=251) and (aDatei<=500) then
    RETURN (StrCut(Set.PtD.Status2,aDatei-250,1)<>'-');
  if (aDatei>=501) and (aDatei<=750) then
    RETURN (StrCut(Set.PtD.Status3,aDatei-500,1)<>'-');
  if (aDatei>=751) and (aDatei<=999) then
    RETURN (StrCut(Set.PtD.Status4,aDatei-750,1)<>'-');
end;


/*========================================================================
2022-07-04  AH
      ISt der Puffer schon "besetzt"?
========================================================================*/
sub IsInUse(aDatei : int) : logic
begin
  RETURN ProtokollBuffer[aDatei]<>0;
end;


//========================================================================
// Memorize
//        merkt sich den momentanen Inhalt einer Datei
//========================================================================
sub Memorize(
  aDatei : int
);
begin
//  if ProtokollAktiv(aDatei)=n then RETURN;
  if (ProtokollBuffer[aDatei]<>0) then begin
    Msg(990001,'',0,0,0);
    RETURN;
  end;
  ProtokollBuffer[aDatei] # RecBufCreate(aDatei);
  RecBufCopy(aDatei,ProtokollBuffer[aDatei]);
end;


//========================================================================
// Forget
//        entfernt den ProtokollPuffer
//========================================================================
sub Forget(
  aDatei : int
);
begin
//  if ProtokollAktiv(aDatei)=n then RETURN;
  if (ProtokollBuffer[aDatei]=0) then begin
    Msg(990002,'',0,0,0);
    RETURN;
  end;
  RecBufDestroy(ProtokollBuffer[aDatei]);
  ProtokollBuffer[aDatei] # 0;
end;


//========================================================================
// Compare
//        vergleicht die Buffer und schreibt das Protokoll
//========================================================================
sub Compare(
  aDatei          : int;
  opt aKopfdatei  : int;
);
local begin
  Erx     : int;
  vBuf    : int;
  vSbr    : int;
  vSbrMax : int;
  vFld    : int;
  vFldMax : int;

  vErg    : int;
  vInsCnt : int;
end;
begin
  if (aKopfDatei=0) then aKopfdatei # aDatei;
  
  if (ProtokollAktiv(aKopfDatei)=n) then begin
    Forget(aDatei);
    RETURN;
  end;

  if (ProtokollBuffer[aDatei]=0) then begin
    Msg(990003,'',0,0,0);
    RETURN;
  end;

  vErg # Erg;   // TODOERX

  vBuf # ProtokollBuffer[aDatei];

  RecBufClear(990);
  PtD.Datei # aKopfDatei;
  PtD.User  # gUsername;
  if (gUsername='') then Ptd.User # Username(_Usercurrent)    // 2022-11-24 AH
  else PtD.User  # gUsername;
  PtD.Datum # sysdate();
  PtD.Zeit  # Now;
  PtD.Key   # Lib_Rec:MakeKey(aKopfDatei);

  vSbrMax # Fileinfo(aDatei,_FileSbrCount);
  FOR vSbr # 1 loop inc(vSbr) while vSbr<=vSbrMax do begin
    vFldMax # Sbrinfo(aDatei,vSbr,_SbrFldCount);
    FOR vFld # 1 loop inc(vFld) while vFld<=vFldMax do begin
      if RecBufCompareFld(vBuf,vSbr,vFld)<>true then begin

        PtD.FeldID        # (vSbr*1000)+vFld;
        PtD.Feldname      # Fldname(aDatei,vSbr,vFld);

        if (PtD.Feldname=*'*.Lösch.User') then CYCLE;
        if (PtD.Feldname=*'*.Lösch.Datum') then CYCLE;
        if (PtD.Feldname=*'*.Lösch.Zeit') then CYCLE;
        if (PtD.Feldname=*'*.Lösch.Grund') then CYCLE;

        if (PtD.Feldname=*'*.Änderung.User') then CYCLE;
        if (PtD.Feldname=*'*.Änderung.Datum') then CYCLE;
        if (PtD.Feldname=*'*.Änderung.Zeit') then CYCLE;

        case FldInfo(aDatei,vSbr,vFld,_KeyFldType) of
          _TypeAlpha  : begin
                      PtD.InhaltVorher  # StrFmt(FldAlpha(vBuf,vSbr,vFld),20,_StrEnd);
                      PtD.InhaltNachher # StrFmt(FldAlpha(aDatei,vSbr,vFld),20,_StrEnd);
                        end;
          _TypeWord   : begin
                      PtD.InhaltVorher  # CnvAI(FldWord(vBuf,vSbr,vFld));
                      PtD.InhaltNachher # CnvAI(FldWord(aDatei,vSbr,vFld));
                        end;
          _TypeInt    : begin
                      PtD.InhaltVorher  # CnvAI(FldInt(vBuf,vSbr,vFld));
                      PtD.InhaltNachher # CnvAI(FldInt(aDatei,vSbr,vFld));
                        end;
          _TypeFloat  : begin
                      PtD.InhaltVorher  # CnvAF(FldFloat(vBuf,vSbr,vFld),_FmtNumNoGroup,0,5);
                      PtD.InhaltNachher # CnvAF(FldFloat(aDatei,vSbr,vFld),_FmtNumNoGroup,0,5);
                        end;
          _TypeDate   : begin
                      PtD.InhaltVorher  # CnvAD(FldDate(vBuf,vSbr,vFld));
                      PtD.InhaltNachher # CnvAD(FldDate(aDatei,vSbr,vFld));
                        end;
          _TypeTime   : begin
                      PtD.InhaltVorher  # CnvAT(FldTime(vBuf,vSbr,vFld));
                      PtD.InhaltNachher # CnvAT(FldTime(aDatei,vSbr,vFld));
                        end;
          _TypeLogic  : begin
                      if FldLogic(aDatei,vSbr,vFld) then PtD.InhaltNachher  # 'y'
                      else                               PtD.InhaltNachher  # 'n';
                      if FldLogic(vBuf,vSbr,vFld) then   PtD.InhaltVorher   # 'y'
                      else                               PtD.InhaltVorher   # 'n';
                        end;
        end;

        // ST 2012-06-22: Einfügen mehrfach probieren, mit anderer Zeit Prj. 1326/247
        // Alte   Version:
        vInsCnt # 0;
        REPEAT
          inc(vInsCnt);
          PtD.Datum # sysdate();
          PtD.Zeit  # Now;
          Erx # RekInsert(990,0,'AUTO');
//debugx(PtD.FeldName+' '+ptd.key);
          if (Erx <> _rOK) then        // Delay wenn fehlerhaft,  dann nochmal
            WinSleep(100);
        UNTIL (Erx = _rOK) or (vInsCnt > 10);

        if (Erx <> _rOK) AND (vInsCnt > 10) then
          Msg(990010,'',0,0,0);
        // ST 2012-06-22 ENDE

      end;

    END;
  END;

  Forget(aDatei);

  Erg # vErg;   // TODOERX
end;


//========================================================================
// View
//        Zeigt das Protokoll an
//========================================================================
sub View(
  aDatei        : int;
  opt aDatum    : date;
  opt aZeit     : time;
  opt aUser     : alpha;
  opt aDelDatum : date;
  opt aDelZeit  : time;
  opt aDelUser  : alpha;
  opt aGrund    : alpha;
  opt aZusatz   : alpha(200);
  opt aDatei2   : int;
);
local begin
  Erx       : int;
  vHdl      : int;
  vHdl2     : int;
//  vFilter : int;
  vQ        : alpha(500);
  vQ2       : alpha(500);
  vSel      : int;
  vSelName  : alpha;
end;
begin
  RecBufClear(990);
  vHdl # WinOpen('PtD.Anzeige',_WinOpenDialog);
  vHdl2 # Winsearch(vHdl,'lb.Zusatz');
  if (vHdl2<>0) and (aZusatz<>'') then begin
    vHdl2->wpcaption # aZusatz;
    vHdl2->wpvisible # true;
  end;
/***
  vFilter # RecFilterCreate(990,2);
  vFilter->RecFilterAdd(1,_FltAND,_FltEq,aDatei);
  vFilter->RecFilterAdd(2,_FltAND,_FltEq,Lib_Rec:MakeKey(aDatei));
***/
  // Selektion aufbauen...
  vQ # '';
  Lib_Sel:QInt(var vQ, 'PtD.Datei'  , '=', aDatei);
  Lib_Sel:QAlpha(var vQ, 'PtD.Key' , '=', Lib_Rec:MakeKey(aDatei));
  if (aDatei2<>0) then begin
    Lib_Sel:QInt(var vQ2, 'PtD.Datei'  , '=', aDatei2, 'OR');
    Lib_Sel:QAlpha(var vQ2, 'PtD.Key' , '=', Lib_Rec:MakeKey(aDatei2));
    vQ # '('+vQ+') OR ('+vQ2+')';
  end;
  vSel # SelCreate(990, 2);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  // speichern, starten und Name merken...
  vSelName # Lib_Sel:SaveRun(var vSel,0,n);
//debugx(vQ);
  vHdl2 # vHdl->Winsearch('ZL.Protokoll');
//  vHdl2->wpDbFilter # vFilter;
  vHdl2->wpDbSelection # vSel;

  vHdl2 # vHdl->Winsearch('lb.Datum');
  vHdl2->wpCaption # CnvAD(aDatum);
  vHdl2 # vHdl->Winsearch('lb.Zeit');
  vHdl2->wpCaption # CnvAT(aZeit,_FmtTimeSeconds);
  vHdl2 # vHdl->Winsearch('lb.User');
  vHdl2->wpCaption # aUser;


  if (aDelDatum<>0.0.0) then begin
    vHdl2 # vHdl->Winsearch('lb.Datum.Del');
    vHdl2->wpCaption # CnvAD(aDelDatum);
    vHdl2 # vHdl->Winsearch('lb.Zeit.Del');
    vHdl2->wpCaption # CnvAT(aDelZeit,_FmtTimeSeconds);
    vHdl2 # vHdl->Winsearch('lb.User.Del');
    vHdl2->wpCaption # aDelUser;
    vHdl2 # vHdl->winSearch('lb.Grund.Del');
    vHdl2->wpCaption # aGrund;
  end;

  vHdl->WindialogRun(_WindialogCenter,gMDI);
//  RecFilterDestroy(vFilter);
  SelClose(vSel);
  SelDelete(990, vSelName);

  WinClose(vHdl);
end;


//========================================================================
//  Deleted
//                protokoliert Datensatzlöschungen in der 991
//========================================================================
sub Deleted(
  aDatei      : int;
  opt aGrund  : alpha;
);
local begin
  vErg        :  int;
end;
begin

  if (aDatei<>200) and (ProtokollDelAktiv(aDatei)=n) then RETURN;

  // 05.10.2020 AH: temporäre Sätze ignorieren
  if (aDatei=401) and (Auf.P.Nummer>1000000000) then RETURN;
  if (aDatei=501) and (Ein.P.Nummer>1000000000) then RETURN;
  if (aDatei=441) and (Lfs.P.Nummer>1000000000) then RETURN;
  if (aDatei=301) and (Rek.P.Nummer>1000000000) then RETURN;
  if (aDatei=651) and (Vsd.P.Nummer>1000000000) then RETURN;

  if (RecRead(991,1,_recLast)=_rNoRec) then RecBufClear(991);

  vErg # Erg;   // TODOERX
  PtD.L.Datei # aDatei;
  // "technischen" Namen (Primärkey) erzeugen
  PtD.L.Name  # StrCut(Lib_Rec:MakeKey(aDatei),1,20);
  PtD.L.Datum # today;
  PtD.L.Zeit  # now;
  if (gUsername='') then Ptd.L.User # Username(_Usercurrent)    // 2022-11-24 AH
  else PtD.L.User  # gUsername;
  PtD.L.Grund # aGrund;
  REPEAT
    PtD.L.Nummer # PtD.L.Nummer + 1;
  UNTIL (RekInsert(991,0,'AUTO')=_rOK);

  Erg # vErg;   // TODOERX
end;


//========================================================================
// EvtClicked
//
//========================================================================
sub EvtClicked(aEvt : event);
local begin
  vName : alpha
end;
begin
//   ComExcelMain:ProtokollExcelMake(aEvt, 0);
  vName # Lib_FileIO:FileIO(_WinComFileSave,gMDI, '', 'CSV-Dateien|*.csv');
  if (vName='') then RETURN;
  if (StrCnv(StrCut(vName,strlen(vName)-3,4),_StrUpper) <>'.CSV') then vName # vName + '.csv';

  If (Msg(998003,vName,_WinIcoQuestion,_WinDialogYesNo,2)=_WinidYes) then begin
    if (Lib_Excel:SchreibeDatei(990,vName,n)=true) then
      Msg(998004,vName+'|'+cnvai(Gv.int.01),_WinIcoInformation,0,0)
    else
      Msg(999999,gv.alpha.01,_WinIcoError,0,0);
    RETURN;
  end;

end;


//========================================================================
// ManageStatus
//
//========================================================================
sub ManageStatus();
local begin
  vHdl    : int;
  vHdl2   : int;
  vX      : int;
  vAnz    : int;
  vDatei  : int;
  vStatus : int;
  vA      : alpha;
  vModule : alpha;
end;
begin

  if (Rechte[Rgt_Protokoll]=n) then RETURN;

  vHdl # WinOpen('PtD.Dateien',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('DL.Dateien');

  FOR vDatei # 1 loop inc(vDatei) while (vDatei<990) do begin
    if (Fileinfo(vDatei,_FileExists)=0) then CYCLE;

    inc(vAnz);

    vHdl2->WinLstDatLineAdd(Filename(vDatei));
    vHdl2->WinLstCellSet(vDatei,2,_WinLstDatLineLast);

    if (ProtokollAktiv(vDatei)) then
      vHdl2->WinLstCellSet(41,3,_WinLstDatLineLast)
    else if (ProtokollDelAktiv(vDatei)) then
      vHdl2->WinLstCellSet(3,3,_WinLstDatLineLast)
    else
      vHdl2->WinLstCellSet(42,3,_WinLstDatLineLast)
  END;

  // darstellen
  if ((vHdl->WinDialogRun(_WinDialogCenter,gFrmMain))<>2) then begin
    vHdl->WinClose();
    RETURN;
  end;

  // Status übernehmen
  vModule # Set.Module;
  RecRead(903,1,_RecLock);
  Set.PtD.Status1 # StrChar(StrToChar('-',1),250);
  Set.PtD.Status2 # StrChar(StrToChar('-',1),250);
  Set.PtD.Status3 # StrChar(StrToChar('-',1),250);
  Set.PtD.Status4 # StrChar(StrToChar('-',1),250);
  FOR vX # 1 loop inc(vX) while (vX<=vAnz) do begin
    vHdl2->WinLstCellGet(vDatei, 2, vX);
    vHdl2->WinLstCellGet(vStatus, 3, vX);

    if (vStatus=41) then vA # '+'
    //else if (vStatus=3) then vA # 'D'
    else vA # '-';
    if (vDatei>=1) and (vDatei<=250) then begin
      Set.PtD.Status1 # StrDel(Set.PtD.Status1,vDatei,1);
      Set.PtD.Status1 # StrIns(Set.PtD.Status1,vA,vDatei);
    end;
    if (vDatei>=251) and (vDatei<=500) then begin
      Set.PtD.Status2 # StrDel(Set.PtD.Status2,vDatei-250,1);
      Set.PtD.Status2 # StrIns(Set.PtD.Status2,vA,vDatei-250);
    end;
    if (vDatei>=501) and (vDatei<=750) then begin
      Set.PtD.Status3 # StrDel(Set.PtD.Status3,vDatei-500,1);
      Set.PtD.Status3 # StrIns(Set.PtD.Status3,vA,vDatei-500);
    end;
    if (vDatei>=751) and (vDatei<=999) then begin
      Set.PtD.Status4 # StrDel(Set.PtD.Status4,vDatei-750,1);
      Set.PtD.Status4 # StrIns(Set.PtD.Status4,vA,vDatei-750);
    end;
  END;
  RekReplace(903,_recUnlock,'AUTO');
  Set.Module # vModule;

  Lib_Initialize:ReadIni();
  vHdl->WinClose();
end;


//========================================================================
//  EvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
local begin
  vstatus : int;
end;begin
  if (aKey=_WinKeyReturn) then begin
    $DL.Dateien->WinLstCellGet(vStatus, 3, aId);

    if (vStatus=41) then vStatus # 42 //41,42 / 102,102
//    else if (vStatus=42) then vStatus # 3 //41,42 / 102,102
    else vStatus # 41;

    $DL.Dateien->WinLstCellSet(vStatus, 3, aID);
  end;
end;


//========================================================================
//  EvtMouseItem
//                Mausclick in Auswahlliste
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
local begin
  vstatus : int;
end;
begin

  if (aItem=0) or (aID=0) then RETURN false;

  if ((aButton & _WinMouseLeft)<>0) and ((aButton & _WinMouseDouble)<>0) then begin
    $DL.Dateien->WinLstCellGet(vStatus, 3, aId);

    if (vStatus=41) then vStatus # 42 //41,42 / 102,102
    //else if (vStatus=42) then vStatus # 3 //41,42 / 102,102
    else vStatus # 41;

    $DL.Dateien->WinLstCellSet(vStatus, 3, aID);
  end;

end;


//========================================================================
// AlleAktiv
//
//========================================================================
sub AlleAktiv(aEvt : event):logic;
local begin
  vHdl    : int;
  vHdl2   : int;
  vX      : int;
  vAnz    : int;
  vDatei  : int;
  vStatus : int;
  vA      : alpha;
  vModule : alpha;
  vDL, vI : int;
end;
begin
  if (Rechte[Rgt_Protokoll]=n) then RETURN false;

  FOR vDatei # 1 loop inc(vDatei)
  while (vDatei<990) do begin
    if (Fileinfo(vDatei,_FileExists)=0) then CYCLE;
    ProtokollAktiv(vDatei);
  END;

  vDL # $DL.Dateien;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
    vDL->WinLstCellSet(41,3,vI);
  END;

end;


//========================================================================
// AlleInAktiv
//
//========================================================================
sub AlleInAktiv(aEvt : event):logic;
local begin
  vHdl    : int;
  vHdl2   : int;
  vX      : int;
  vAnz    : int;
  vDatei  : int;
  vStatus : int;
  vA      : alpha;
  vModule : alpha;
  vI      : int;
  vDL     : int;
end;
begin

  if (Rechte[Rgt_Protokoll]=n) then RETURN false;

  // vHdl # WinOpen('PtD.Dateien',_WinOpenDialog);
  // vHdl2 # vHdl->WinSearch('DL.Dateien');

  FOR vDatei # 1 loop inc(vDatei) while (vDatei<990) do begin
    if (Fileinfo(vDatei,_FileExists)=0) then CYCLE;
    ProtokollDelAktiv(vDatei);
  END;

  vDL # $DL.Dateien;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
    vDL->WinLstCellSet(42,3,vI);
  END;
  
end;



//========================================================================
//========================================================================