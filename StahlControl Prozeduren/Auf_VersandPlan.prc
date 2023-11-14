@A+
//==== Business-Control ==================================================
//
//  Prozedur    Auf_VersandPlan
//                OHNE E_R_G
//  Info
//
//
//  11.11.2019  AH  Erstellung der Prozedur
//  26.11.2019  AH  Erweiterungen
//  09.12.2019  AH  Erweiterungen u.A. auf 3 Fuhren
//  06.04.2020  AH  Erweiterungen
//
//  Subprozeduren
//    SUB Start();
//
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG
@I:Def_Aktionen

define begin

cDEBUG : (gusername='AH')

  cModulName  : 'vonSC_Auf_Versandplan'

  cTitle      : 'Auftrags-Versandplanung'
  cMenuName   : 'BA1.Feinplanung'

  cMDI          : gMdiPara
  
  cDlAuf        : 'dlAuftrag'
  cDlVersand    : 'dlVersand'

  cClmAufNr     : 1
  cClmAufCustom : 2
  cClmAufKunde  : 3
  cClmAufZiel   : 4
  cClmAufInfo   : 5
  cClmAufSoll   : 6
  cClmAufInVSD  : 7
  cClmAufTermin : 8
  cClmAufVSB    : 9
  cClmAufAlt    : 10
  cClmAufHeute  : 11
  cClmAufTag1   : 12
  cClmAufTag2   : 13
  cClmAufTag3   : 14
  cClmAufTag4   : 15
  cClmAufTag5   : 16
  cClmAufKW1    : 17
  cClmAufKW2    : 18
  cClmAufKW3    : 19
  cClmAufKW4    : 20
  cClmAufKW5    : 21
  cClmAufMonat  : 22
  cClmAufSpaeter  : 23

  cClmMatAufNr  : 1
  cClmMatKunde  : 2
  cClmMatZiel   : 3
  cClmMatNr     : 4
  cClmMatNetto  : 5
  cClmMatBrutto : 6
  cClmMatAkt    : 7
  cClmMatWert   : 8
end;

declare StartInner(aKdNr : int);
declare Insert_Auf(aDL : int);
declare  Refresh();

//========================================================================
// Start
//  Call Auf_VersandPlan:Start
//========================================================================
sub Start(opt aKdNr : int);
begin
  gSelected # 1;
//aKdNr # 1234;
  StartInner(aKdNr);
end;


//========================================================================
//========================================================================
sub _AddSum(
  aGruppe     : int;
  aNetto      : float;
  aBrutto     : float;
  aWert       : float;
  opt aReEmpf : int;
)
local begin
  vHdl    : int;
  vF      : float;
end;
begin

  vHdl  # WinSearch(cMDI, 'lbSumNetto'+aint(aGruppe));
  vF    # cnvfa(vHdl->wpcaption) + aNetto;
  vHdl->wpCaption # anum(vF,0);

  vHdl  # WinSearch(cMDI, 'lbSumBrutto'+aint(aGruppe));
  vF    # cnvfa(vHdl->wpcaption) + aBrutto;
  vHdl->wpCaption # anum(vF,0);

  vHdl  # WinSearch(cMDI, 'lbWert'+aint(aGruppe));
  vF    # cnvfa(vHdl->wpcaption) + aWert;
  vHdl->wpCustom # anum(vF,0);

  if (aReEmpf<>0) then begin
    vHdl  # WinSearch(cMDI, 'lbReEmpf'+aint(aGruppe));
    vHdl->wpCustom # aint(aReEmpf);
  end;

end;


//========================================================================
//========================================================================
sub _CleanUp(
  aGruppe     : int;
)
local begin
  vHdl    : int;
  vF      : float;
end;
begin

  vHdl  # WinSearch(cMDI, 'lbSumNetto'+aint(aGruppe));
  vHdl->wpCaption # anum(0.0 ,0);

  vHdl  # WinSearch(cMDI, 'lbSumBrutto'+aint(aGruppe));
  vHdl->wpCaption # anum(0.0 ,0);

  vHdl  # WinSearch(cMDI, 'lbWert'+aint(aGruppe));
  vHdl->wpCustom # '';
 
  vHdl  # WinSearch(cMDI, 'lbReEmpf'+aint(aGruppe));
  vHdl->wpCustom # '';
 
  vHdl  # WinSearch(cMDI, cDlVersand+aint(aGruppe));
  WinLstDatLineRemove(vHdl, _WinLstDatLineAll);

end;


//========================================================================
//  Merge
//            Fügt in einen BA Fahrauftrag - Fertiges Material von dem Auftrag X ein
//========================================================================
sub Merge(aGruppe : int) : logic;
local begin
  Erx       : int;
  vDL       : int;
  vMax      : int;
  vI        : int;
  vQ        : alpha(4000);
  vSelname  : alpha;
  vSel      : int;
  vA        : alpha;
end;
begin
  vDl # Winsearch(gMDI, cDlVersand+aint(aGruppe));
  if (vDL=0) then RETURN false;

  vMax # WinLstDatLineInfo(vDL, _WinLstDatInfoCount);
  if (vMax=0) then RETURN false;

  // 1. Position holen
  WinLstCellGet(vDL, vA ,    cClmMatAufNr  ,1);
  if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then RETURN false;
  Erx # recRead(401,1,0);
  if (Erx>_rLocked) then RETURN false;
  Erx # RecLink(400,401,3,_RecFirst);   // AufKopf holen
  if (Erx>_rLocked) then RETURN false;
 
  ArG.Aktion2           # c_BAG_Fahr;
  Erx # RecRead(828,1,0);
  if (Erx>_rLocked) then RecBufClear(828);

  RecBufClear(700);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.P.Verwaltung',here+':AusBAG');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  vQ # '';
  Lib_Sel:QAlpha(var vQ, 'BAG.P.Löschmarker', '=', '');
  Lib_Sel:QDate(var vQ, 'BAG.P.Fertig.Dat', '=', 0.0.0);
  Lib_Sel:QInt(var vQ, 'BAG.P.Zieladresse', '=', Auf.Lieferadresse);
  Lib_Sel:QInt(var vQ, 'BAG.P.Zielanschrift', '=', Auf.Lieferanschrift);
  Lib_Sel:QAlpha(var vQ, 'BAG.P.Aktion', '=', ArG.Aktion);
  Lib_Sel:QLogic( var vQ, 'BAG.P.ExternYN', true);
  Lib_Sel:QRecList(0,vQ);

  Lib_RmtData:UserWrite('Versandplan',aint(aGruppe));

  Lib_GuiCom:RunChildWindow(gMDI);

//    if (Auf.Lieferadresse <> Lfs.Zieladresse) or (Auf.Lieferanschrift <> Lfs.Zielanschrift) or
//     (Auf.Kundennr <> Lfs.Kundennummer) then begin
//          if (Auf_Data:VLDAW_Pos_Einfuegen_Mat(Lfs.Nummer, var vPos, 0)=false) then TODO('ERROR!!!!')
//          else Rekdelete(441,0,'AUTO');
//          REPEAT
//            BAG.F.Nummer    # BAG.P.Nummer;
//            BAG.F.Position  # BAG.P.Position;
//            BAG.F.Fertigung # Lfs.P.Position;
//            Erx # RecRead(703,1,_recTest);
//            if (Erx<=_rLocked) then
//              Lfs.P.Position # Lfs.P.Position + 1;
//          UNTIL (Erx>_rLocked);
//          if (BA1_P_Data:_ErzeugeBAGausLFS(BAG.P.Nummer, BAG.P.Position)=false) then begin
  // automatischer Abschluss eintragen
//  if (BA1_P_Data:AutoVSB()=false) then begin
//  BA1_P_Data:UpdateSort();
end;


//========================================================================
//========================================================================
sub AusBAG()
local begin
  Erx       : int;
  vGruppe : int;
  vDL     : int;
  vMax    : int;
  vI      : int;
  vMat    : int;
end;
begin
  if (gSelected=0) then RETURN;
  RecRead(702,0,_RecId,gSelected);
  gSelected # 0;

  vGruppe # cnvia(Lib_RmtData:UserRead('Versandplan',true));
  
  vDl # Winsearch(gMDI, cDlVersand+aint(vGruppe));
  if (vDL=0) then RETURN;

  vMax # WinLstDatLineInfo(vDL, _WinLstDatInfoCount);
  if (vMax=0) then RETURN;

  TRANSON;

  vI # 1;
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin

    // Material holen
    WinLstCellGet(vDL, vMat ,  cClmMatNr     ,vI);
    Mat.Nummer # vMat;
    Erx # RecRead(200,1,0);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Error(440700,'');
      Erroroutput;
      RETURN;
    end;

    // als Einsatz aufnehmen
    if (BA1_IO_Data:EinsatzRein(BAG.P.Nummer, BAG.P.Position, Mat.Nummer)=false) then begin
      TRANSBRK;
      Error(999999,'Mat. '+aint(vMat)+' konnte nicht eingesetzt werden!');
      Erroroutput;
      RETURN;
    end;

    inc(vI);
  END;

  if (BA1_P_Data:AutoVSB()=false) then begin
    TRANSBRK;
    Error(010034,AInt(BAG.P.Nummer));
    Erroroutput;
    RETURN;
  end;
  
  _Cleanup(vGruppe);

  TRANSOFF;

  Refresh();
  Msg(999998,'',0,0,0);
 
  RETURN;
end;


//========================================================================
//========================================================================
sub BaueLFS(
  aDL         : int;
  aNurAuf     : int;
  aBuchen     : logic) : logic;
local begin
  Erx       : int;
  vPos  : int;
  vI    : int;
  vA    : alpha;
  vMat  : int;
end;
begin

  vPos # 1;
  vI # 1;
  WHILE (vI<=WinLstDatLineInfo(aDL, _WinLstDatInfoCount)) do begin

    WinLstCellGet(aDL, vA ,    cClmMatAufNr  ,vI);
    if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then RETURN false;
    
    // falsche Auftragnr? -> nächste Zeile!
    if (aNurAuf<>0) and (Auf.P.Nummer<>aNurAuf) then begin
      inc(vI);
      CYCLE;
    end;

    Erx # RecRead( 401, 1, 0 );
    if (Erx>_rLocked) then RETURN false;
    Erx # RecLink(400,401,3,_RecFirst);   // AufKopf holen
    if (Erx>_rLocked) then RETURN false;

    // Material holen
    WinLstCellGet(aDL, vMat ,  cClmMatNr     ,vI);
    Mat.Nummer # vMat;
    Erx # RecRead(200,1,0);
    if (Erx<>_rOK) then begin
      Error(440700,'');
      RETURN false;
    end;
    
    if (Lfs.Nummer=0) then begin
      Lfs.Nummer          # myTmpNummer;
      Lfs.Anlage.Datum    # today;
      Lfs.Kundennummer    # Auf.P.Kundennr;
      Lfs.Kundenstichwort # Auf.P.KundenSW;
      Lfs.Zieladresse     # Auf.Lieferadresse;
      Lfs.Zielanschrift   # Auf.Lieferanschrift;
    end;
  
    if (Auf_Data:VLDAW_Pos_Einfuegen_Mat( myTmpNummer, var vPos, 0, false )=false) then begin
      Error(99,'Material '+aint(vMat));
      Error(440700,'');
      RETURN false;
    end;
    
    // Zeile ist erledigt
    WinLstDatLineRemove(aDL, vI);
    
  END;
  
  if (aBuchen) then begin
    if (Lfs_Data:SaveLFS()=false) then begin
      RETURN false;
    end;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub AusLFS(
  aGruppe : int;
  aLfs    : int;)
local begin
  vAuf  : int;
  vDL   : int;
  vA    : alpha;
end;
begin

  if (aLfs<>0) then begin
    Lfs.Nummer # aLfs;
    RecRead(440,1,0);
    Lfs.Nummer # 0;
  end
  else begin
    RecBufClear(440);
    Lfs.Kosten.PEH      # 1000;
    Lfs.Kosten.MEH      # 'kg';
    Lfs.Lieferdatum     # today;
  end;
 
  vDl # Winsearch(gMDI, cDlVersand+aint(aGruppe));
  if (vDL=0) then RETURN;

  vAuf # 0;
  WHILE (WinLstDatLineInfo(vDL, _WinLstDatInfoCount)>0) do begin
    WinLstCellGet(vDL, vA ,    cClmMatAufNr  ,1);
    if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then begin
      APPON();
      TRANSBRK;
      Error(440700,'');
      ErrorOutput;
      RETURN;
    end;
    vAuf # Auf.P.Nummer;
    if (BaueLFS(vDL, vAuf, true)=false) then begin
      APPON();
      TRANSBRK;
      Error(999999,'');
      ErrorOutput;
      RETURN;
    end;
  END;
  
  _CleanUp(aGruppe);

end;


//========================================================================
//========================================================================
sub AusLFS1()
begin
  if (gSelected=0) then RETURN;
  Lfs.Nummer # gSelected;
  gSelected # 0;
  AusLFS(1, Lfs.Nummer);
end;


//========================================================================
//========================================================================
sub AusLFS2()
begin
  if (gSelected=0) then RETURN;
  Lfs.Nummer # gSelected;
  gSelected # 0;
  AusLFS(2, Lfs.Nummer);
end;


//========================================================================
//========================================================================
sub AusLFS3()
begin
  if (gSelected=0) then RETURN;
  Lfs.Nummer # gSelected;
  gSelected # 0;
  AusLFS(3, Lfs.Nummer);
end;


//========================================================================
//========================================================================
sub ausLFA1()
begin
  if (gSelected=0) then RETURN;

  // CLEANUP
  _Cleanup(1);
  
  ErrorOutput;
end;


//========================================================================
//========================================================================
sub ausLFA2()
begin
  if (gSelected=0) then RETURN;

  // CLEANUP
  _Cleanup(2);
  
  ErrorOutput;
end;


//========================================================================
//========================================================================
sub ausLFA3()
begin
  if (gSelected=0) then RETURN;

  // CLEANUP
  _Cleanup(3);
  
  ErrorOutput;
end;


//========================================================================
//========================================================================
sub Save(aGruppe  : int) : logic
local begin
  Erx       : int;
  vI      : int;
  vDL     : int;
  vMax    : int;
  vA      : alpha;
  vMat    : int;
  vPos    : int;
  vLFA    : logic;
  vAuf    : int;
  vFirst  : logic;
end;
begin
  vDl # Winsearch(gMDI, cDlVersand+aint(aGruppe));
  if (vDL=0) then RETURN false;

  vMax # WinLstDatLineInfo(vDL, _WinLstDatInfoCount);
  if (vMax=0) then RETURN false;

  vI # Msg(440702,'',_WinIcoQuestion, _WinDialogYesNoCancel,3);
  if (vI=_WinIdCancel) then RETURN false;
  vLFA # vI=_WinIdYes;
  
  // als Fahrauftrag -----------------------------------------------------------
  if (vLFA) then begin
    ArG.Aktion2           # c_BAG_Fahr;
    Erx # RecRead(828,1,0);
    if (Erx>_rLocked) then RecBufClear(828);

    RecBufClear(702);         // BA-Position anlegen
    BAG.P.Nummer            # myTmpNummer;
    BAG.P.Position          # 1;
    BAG.P.Aktion            # ArG.Aktion;
    BAG.P.Aktion2           # ArG.Aktion2;
    "BAG.P.Typ.1In-1OutYN"  # "ArG.Typ.1In-1OutYN";
    "BAG.P.Typ.1In-yOutYN"  # "ArG.Typ.1In-yOutYN";
    "BAG.P.Typ.xIn-yOutYN"  # "ArG.Typ.xIn-yOutYN";
    "BAG.P.Typ.VSBYN"       # "ArG.Typ.VSBYN";
    BAG.P.Bezeichnung       # ArG.Bezeichnung
    BAG.P.ExternYN          # y;
    BAG.P.ExterneLiefNr     # 0;
    BAG.P.Zieladresse       # Auf.Lieferadresse;
    BAG.P.Zielanschrift     # Auf.Lieferanschrift;
    Erx # RecLink(101,702,13,_RecFirst);  // Zielanschrift holen
    if (Erx>_rLocked) then RecBufClear(101);
    BAG.P.Zielstichwort     # Adr.A.Stichwort;
    BAG.P.ZielVerkaufYN     # y;

    BAG.P.Kosten.Wae        # 1;
    BAG.P.Kosten.PEH        # 1000;
    BAG.P.Kosten.MEH        # 'kg';

    BAG.P.Anlage.Datum      # Today;
    BAG.P.Anlage.Zeit       # Now;
    BAG.P.Anlage.User       # gUserName;

    TRANSON;
    APPOFF(true);

    RecBufClear(440);
    Lfs.Kosten.PEH      # 1000;
    Lfs.Kosten.MEH      # 'kg';
    Lfs.Lieferdatum     # today;

    vPos # 1;
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=vMax) do begin
      WinLstCellGet(vDL, vA ,    cClmMatAufNr  ,vI);
      WinLstCellGet(vDL, vMat ,  cClmMatNr     ,vI);
      
      Mat.Nummer # vMat;
      Erx # RecRead(200,1,0);
      if (Erx<>_rOK) then begin
        APPON();
        TRANSBRK;
        Error(440700,'');
        ErrorOutput;
        RETURN false;
      end;

      if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then CYCLE;

      Erx # RecRead( 401, 1, 0 );
      if (Erx>_rLocked) then CYCLE;
      Erx # RecLink(400,401,3,_RecFirst);   // AufKopf holen
      if (Erx>_rLocked) then CYCLE;
      
      if (Lfs.Nummer=0) then begin
        Lfs.Nummer          # myTmpNummer;
        Lfs.Anlage.Datum    # today;
        Lfs.Kundennummer    # Auf.P.Kundennr;
        Lfs.Kundenstichwort # Auf.P.KundenSW;
        Lfs.Zieladresse     # Auf.Lieferadresse;
        Lfs.Zielanschrift   # Auf.Lieferanschrift;
      end;
    
      if (Auf_Data:VLDAW_Pos_Einfuegen_Mat( myTmpNummer, var vPos, 0, false )=false) then begin
        APPON();
        TRANSBRK;
        Error(99,'Material '+aint(vMat));
        Error(440700,'');
        ErrorOutput;
        RETURN false;
      end;
    END;

    APPON();
    TRANSOFF;

    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.P.LFA.Maske',here+':AusLFA'+aint(aGruppe));
    // gleich in Neuanlage....
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    Mode # c_ModeNew;
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN false;
  end // LFA
  else begin  // als LIEFERSCHEIN ---------------------------------------------------------------

    RecBufClear(440);
    Lfs.Kosten.PEH      # 1000;
    Lfs.Kosten.MEH      # 'kg';
    Lfs.Lieferdatum     # today;

    // pro Kommission einzelner LFS?
//    if (Set.Installname='VBS') then begin
    if (Set.LFS.proKommissYN) then begin
      vAuf # 0;
      if (WinLstDatLineInfo(vDL, _WinLstDatInfoCount)>0) then begin
        WinLstCellGet(vDL, vA ,    cClmMatAufNr  ,1);
        if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then begin
          Error(440700,'');
          ErrorOutput;
          RETURN false;
        end;
        vAuf # Auf.P.Nummer;
       
        if (BaueLFS(vDL, vAuf, false)=false) then begin
          Error(999999,'');
          ErrorOutput;
          RETURN false;
        end;
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.Maske',here+':AusLFS'+aint(aGruppe));
        // gleich in Neuanlage....
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        Mode # c_ModeNew;
//    w_Command # '->POS';
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
      RETURN false;
    end;
    
    TRANSON;
    APPOFF(true);

    if (BaueLFS(vDL, 0, true)=false) then begin
      APPON();
      TRANSBRK;
      Error(999999,'');
      ErrorOutput;
      RETURN false;
    end;
  end;  // LFS
  
  APPON();
  TRANSOFF;
//      Lfs_VLDAW_Data:Druck_LFA();

  _CleanUp(aGruppe);

  Msg(999998,'',0,0,0);
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub GetDate(aText : alpha) : date;
local begin
  vDat  : date;
end;
begin
  try begin
    ErrTryCatch(_ErrCnv,y);
    vDat # Cnvda(aText);
  end;
  if (ErrGet() != _ErrOk) then RETURN 0.0.0;

  RETURN vDat;
end;


//========================================================================
sub _SetTagHeader(
  aHdl      : int;
  aVon      : date;
  aBis      : date);
begin
  aHdl->wpcaption # Lib_Berechnungen:Tag_aus_datum(aBis)+', '+cnvad(aBis);
  aHdl->wpCustom # cnvad(aVon)+'|'+cnvad(aBis);
//vHdl->wpCaption # aHdl->wpCustom;
//debug('set '+aHdl->wpCustom);
end;


//========================================================================
sub _SetKWHeader(
  aDl       : int;
  aKWObj    : alpha;
  aMonatObj : alpha;
  aDat1     : date;
  aDat2     : date)
local begin
  vHdl      : int;
  vMHdl     : int;
  vLetzter  : date;
  vErster   : date;
  vKW       : word;
  vJahr     : word;
end;
begin
  Lib_Berechnungen:KW_aus_Datum(aDat2, VAR vKW, var vJahr);

  vMHdl # Winsearch(aDL, aMonatObj);
  vHdl # Winsearch(aDL, aKWObj);
  vHdl->wpcaption # 'KW '+aint(vKW);

  vErster  # aDat1;
  vErster  # DateMake(1,vErster->vpMonth, vErster->vpYear);     // 1. des Monat
  vErster->vmMonthModify(1);                                    // 1. nächsten Monat
  vLetzter # vErster;
  vLetzter->vmDayModify(-1);                                    // letzter diesen Monat

//debug(cnvad(aDat1)+'-'+cnvad(aDat2)+' < '+cnvad(vLetzter));
  if (aDat2<=vLetzter) then begin
    vHdl->wpCustom # cnvad(aDat1)+'|'+cnvad(aDat2);
//vHdl->wpCaption # vHdl->wpCaption + ':' + vHdl->wpCustom;
//debug('set '+vHdl->wpCustom);
    RETURN;
  end;

//  if (vI>=5) then       // wenn bisher schon bis Freitag, dann eine KW weiter
//    vBis->vmDayModify(7);

  // zu KW zählen nur Tage DIESES Monats!
  vMHdl->wpcustom # cnvad(vErster)+'|'+cnvad(aDat2);
  vMHdl->wpcaption # 'Rest KW '+aint(vKW)+' anderer Monat';
//vMHdl->wpCaption # vMHdl->wpCaption + ':'+vMHdl->wpCustom;
//debug('set '+vMHdl->wpCustom);

  aDat2 # vErster;
  vHdl->wpClmColBkg # _WinColLightYellow;
//debug('monatsrest : '+cnvad(aDat1)+'-'+cnvad(vLetzter));
//debug('neuer Monat:'+cnvad(vErster)+'-'+cnvad(aDat2));
  vMHdl->wpClmOrder # vHdl->wpClmOrder + 1;
  vMHdl->wpClmColBkg # _WinColLightYellow;
  
  vHdl->wpCustom # cnvad(aDat1)+'|'+cnvad(vLetzter);
//vHdl->wpCaption # vHdl->wpCaption + ':'+vHdl->wpCustom;

end;


//========================================================================
sub SetHeader(aDL : int);
local begin
  vHdl  : int;
  vI    : int;
  vVon  : date;
  vBis  : date;
  vMo   : date;
end;
begin
  vBis # today;
//vBis # 11.10.2019;  // 16. 11

  // Gestern...
  vHdl # Winsearch(aDl, 'clmAlt');
  vBis->vmDayModify(-1);
  vHdl->wpcustom # '0.0.0|'+cnvad(vBis);

  // Heute...
  vBis->vmDayModify(1);
  _SetTagHeader(Winsearch(aDl, 'clmHeute'), vBis, vBis);

  // +1 Tag
  vVon  # vBis;
  vVon->vmDayModify(1);
  vBis # Lib_Berechnungen:AddWerktage(vBis, 1, false);
  _SetTagHeader(Winsearch(aDl, 'clmTag1'), vVon, vBis);

  // +2 Tag
  vVon # vBis;
  vVon->vmDayModify(1);
  vBis # Lib_Berechnungen:AddWerktage(vBis, 1, false);
  _SetTagHeader(Winsearch(aDl, 'clmTag2'), vVon, vBis);
  
  // +3 Tag
  vVon # vBis;
  vVon->vmDayModify(1);
  vBis # Lib_Berechnungen:AddWerktage(vBis, 1, false);
  _SetTagHeader(Winsearch(aDl, 'clmTag3'), vVon, vBis);

  // +4 Tag
  vVon # vBis;
  vVon->vmDayModify(1);
  vBis # Lib_Berechnungen:AddWerktage(vBis, 1, false);
  _SetTagHeader(Winsearch(aDl, 'clmTag4'), vVon, vBis);

  // +5 Tag
  vVon # vBis;
  vVon->vmDayModify(1);
  vBis # Lib_Berechnungen:AddWerktage(vBis, 1, false);
  _SetTagHeader(Winsearch(aDl, 'clmTag5'), vVon, vBis);   // 18,18

  // nächster Tag                     19
  vVon # vBis;
  vVon->vmDayModify(1);

  // auf Montag dieses Tages
  vI # DateDayOfWeek(vVon);  // MO=1                      // 21
  vMo # vVon;
  vMo->vmDayModify(-vI+1);

  vBis # vMo;
  vBis->vmDayModify(4);     // bis Freitag
  if (vBis<vVon) then begin // wenn VON am WE liegt,
    vBis->vmDayModify(7);   // eine Woche weiter
    vMo->vmDayModify(7);
  end;
  _SetKWHeader(aDl, 'clmKW1', 'clmMonatsRest', vVon ,vBis);    // 24, 25
  
  vVon # vMo;
  vVon->vmDayModify(5); // nächsten Samstag
  vBis->vmDayModify(7);
  _SetKWHeader(aDl, 'clmKW2', 'clmMonatsRest', vVon, vBis);

  vVon->vmDayModify(7);
  vBis->vmDayModify(7);
  _SetKWHeader(aDl, 'clmKW3', 'clmMonatsRest', vVon, vBis);

  vVon->vmDayModify(7);
  vBis->vmDayModify(7);
  _SetKWHeader(aDl, 'clmKW4', 'clmMonatsRest', vVon, vBis);

  vVon->vmDayModify(7);
  vBis->vmDayModify(7);
  _SetKWHeader(aDl, 'clmKW5', 'clmMonatsRest', vVon, vBis);

  vBis->vmDayModify(1);
  vHdl # Winsearch(aDl, 'clmSpaeter');
  vHdl->wpcustom # cnvad(vBis)+'|'+cnvad(31.12.2099);

end;


//========================================================================
//========================================================================
sub Fill(aKdNr : int)
local begin
  Erx       : int;
  vSel        : int;
  vSelName    : alpha;
  vQ          : alpha(4000);
  vDat        : date;
  vDlAuf      : int;
  vDlVersand  : int;
  vA,vB       : alpha;
  v931        : int;
  vGew        : float;
  vProgress   : int;
end;
begin

  vDlAuf # Winsearch(gMDI, cDlAuf);
  vDlAuf->wpautoupdate # false;
  vDlAuf->WinLstDatLineRemove(_WinLstDatLineAll);   // alle Zeilen leeren
 
  SetHeader(vDlAuf);

  vDlAuf->wpColFocusBkg    # Set.Col.RList.Cursor;
  vDlAuf->wpColFocusOffBkg # "Set.Col.RList.CurOff";
  vDlVersand # Winsearch(gMDI, cDlVersand+'1');
  vDlVersand->wpColFocusBkg    # Set.Col.RList.Cursor;
  vDlVersand->wpColFocusOffBkg # "Set.Col.RList.CurOff";
  vDlVersand # Winsearch(gMDI, cDlVersand+'2');
  vDlVersand->wpColFocusBkg    # Set.Col.RList.Cursor;
  vDlVersand->wpColFocusOffBkg # "Set.Col.RList.CurOff";
  vDlVersand # Winsearch(gMDI, cDlVersand+'3');
  vDlVersand->wpColFocusBkg    # Set.Col.RList.Cursor;
  vDlVersand->wpColFocusOffBkg # "Set.Col.RList.CurOff";

  // FÜLLEN-------------------------------------------------
  vQ # '';
  Lib_Sel:QInt(var vQ, 'Auf.Nummer', '<', 1000000000);
  if (aKdNr<>0) then
    Lib_Sel:QInt(var vQ, 'Auf.Kundennr', '=', aKdNr);
  Lib_Sel:QAlpha(var vQ, 'Auf.Löschmarker', '=', '');
//vQ # vQ + 'AND Auf.Nummer=100789';
if (cDEBUG) then begin
if (Msg(99,'DEMO: Nur der Testkunde?',_WinIcoQuestion, _WinDialogYesNo, 2)=_Winidyes) then begin
vQ # vQ + 'AND Auf.Kundennr=1957';
Set.Installname # 'VBS';
end;
end;
  Lib_Sel:QAlpha(var vQ, 'Auf.Vorgangstyp', '=', c_Auf);
  vQ # vQ + ' AND "Auf.LiefervertragYN"=false AND "Auf.PAbrufYN"=false';

  vSel # SelCreate(400, 0);
  vSel->SelAddSortFld(1, FldInfoByName('Auf.KundenStichwort', _FldNumber));
  vSel->SelAddSortFld(1, FldInfoByName('Auf.Lieferadresse', _FldNumber));
  vSel->SelAddSortFld(1, FldInfoByName('Auf.Lieferanschrift', _FldNumber));
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);

  // speichern, starten und Name merken...
  vSelName # Lib_Sel:SaveRun(var vSel,0,n);

  vProgress # Lib_Progress:Init('Baue Tabelle auf...',RecInfo(400,_RecCount, vSel));
  FOR Erx # RecRead(400,vSel,_RecFirst)
  LOOP Erx # RecRead(400,vSel,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    vProgress->Lib_Progress:Step();

    // Positionen loopen...
    FOR Erx # RecLink(401,400,9,_recFirst)
    LOOP Erx # RecLink(401,400,9,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if ("Auf.P.Löschmarker"<>'') then CYCLE;
      
      Insert_Auf(vDlAuf);
    END;
  END;
  vProgress->Lib_Progress:Term();

  SelClose(vSel);
  SelDelete(400, vSelName);

  vDlAuf->wpautoupdate # true;

end;


//========================================================================
//========================================================================
sub Refresh()
local begin
  vHdl  : int;
end;
begin
  cMDI->wpautoupdate # false;
  
  vHdl # Winsearch(cMDI, 'btRefresh');
  if (vHdl<>0) then vHdl # cnvia(vHdl->wpCustom);

  Fill(vHdl);

  // Anzeigen
  cMDI->WinUpdate(_WinUpdOn);
  cMDI->Winfocusset(true);
end;


//========================================================================
// StartInner
//
//========================================================================
sub StartInner(aKdNr : int);
local begin
  vHdl  : int;
end;
begin

  if (gSelected=0) then RETURN;
  gSelected # 0;
  if (cMDI<>0) then RETURN;

  // Dialog starten...
  cMDI # Lib_GuiCom:OpenMdi(gFrmMain, 'Auf.Versandplan', _WinAddHidden);
  VarInstance(WindowBonus,cnvIA(cMDI->wpcustom));

  vHdl # Winsearch(cMDI, 'btRefresh');
  if (vHdl<>0) then vHdl->wpCustom # aint(aKdNr);
  
  Fill(aKdNr);

  // Anzeigen
  cMDI->WinUpdate(_WinUpdOn);
  cMDI->Winfocusset(true);
end;


//========================================================================
//========================================================================
sub _VerteileLautDatum(
  aDL         : int;
  aDat        : date;
  aGew        : float;
  var aWerte  : float[]);
local begin
  vA            : alpha;
  vDat1, vDat2  : date;
  vI            : int;
  vClm          : int;
end;
begin

  vI # 0;
  FOR vClm # WinInfo(aDL, _Winfirst, _WinTypeDataListColumn)
  LOOP vClm # WinInfo(vClm, _WinNext, _WinTypeDataListColumn)
  WHILE (vClm>0) do begin
    if (vClm->wpcustom='_SKIP') then CYCLE;
    inc(vI);

    vA # vClm->wpcustom;
    if (vA='') then CYCLE;

    vDat1 # cnvda(Str_Token(vClm->wpCustom,'|',1));
    vDat2 # cnvda(Str_Token(vClm->wpCustom,'|',2));
    if (aDat>=vDat1) and (aDat<=vDat2) then begin
//debug(anum(aGew,0)+' nach '+aint(vI)+' weil '+cnvad(aDat)+'>='+cnvad(vDat1)+' and '+cnvad(aDat)+'<='+cnvad(vDat2));
      aWerte[vI] # aWerte[vI] + aGew;
      RETURN;
    end;
  END;

end;


//========================================================================
//========================================================================
sub _AufMengeInFuhre(aGruppe : int) : float
local begin
  vDL   : int;
  vI    : int;
  vM    : float;
  vA    : alpha;
  vAuf  : int;
  vPos  : word;
end;
begin

  vDl # Winsearch(gMDI, cDlVersand+aint(aGruppe));
  if (vDL=0) then RETURN 0.0;

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(vDL, vA                 ,cClmMatAufNr , vI);
    WinLstCellGet(vDL, Mat.Gewicht.Netto  ,cClmMatNetto , vI);
    WinLstCellGet(vDL, Mat.Gewicht.Brutto ,cClmMatBrutto, vI);
    if (Lib_Berechnungen:Int2AusAlpha(vA, var vAuf, var vPos)) then begin
      if (vAuf=Auf.P.Nummer) and (vPos=Auf.P.Position) then begin
        vM # vM + Mat.Bestand.Gew;
      end;
    end;
  END;
//debugx('KEY401 alt '+anum(vM,0));
  RETURN vM;
end;


//========================================================================
//========================================================================
sub Insert_Auf(aDL : int);
local begin
  Erx       : int;
  vZiel     : alpha(1000);
  vVSB      : float;
  vAlt      : float;
  vI        : int;
  vGew      : float;
  vClm      : int;
  vWerte    : float[20];
  vDat      : date;
  vInfo     : alpha;
  vTermin   : date;
  vM        : float;
  vP        : float;
end;
begin
  Erx # RecLink(101,400,2,_recFirst);   // Lieferanschr. holen
  if (Erx<=_rLocked) then begin
    vZiel # Adr.A.Stichwort+', '+Adr.A.Ort;
  end;
  
  vVSB # Auf.P.Prd.VSB.Gew;

  vGew  # Auf.P.Gewicht - vVSB - Auf.P.Prd.LFS ;
    
  vVSB # vVSB - _AufMengeInFuhre(1) - _AufMengeInFuhre(2) - _AufMengeInFuhre(3);

  // Aktionen loopen...
  FOR Erx # RecLink(404,401,12,_recFirst)
  LOOP Erx # RecLink(404,401,12,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if ("Auf.A.Löschmarker"<>'') then CYCLE;
    if (Auf.A.Aktionstyp<>c_Akt_BA_Plan) then CYCLE;
    if (Auf.A.TerminStart=0.0.0) then CYCLE;
    if (Auf.A.Gewicht<=0.0) then CYCLE;
    if (Auf.A.TerminStart=0.0.0) then Auf.A.TerminStart # 31.12.2099;
    _VerteileLautDatum(aDL, Auf.A.TerminStart, Auf.A.Gewicht, var vWerte);
    
    vGew # vGew - Auf.A.Gewicht;
  END;

  // unverplante Auftragsmenge auch anzeigen
  
  if (vGew>0.0) then begin
//    vDat # today;
//    vDat->vmDayModify(Auf.P.Nummer % 10);
//    _VerteileLautDatum(aDL, vDat, vGew, var vWerte);
    if (Auf.P.TerminZusage<>0.0.0) then begin
      _VerteileLautDatum(aDL, Auf.P.TerminZusage, vGew, var vWerte);
    end
    else if (Auf.P.Termin1Wunsch<>0.0.0) then begin
      _VerteileLautDatum(aDL, Auf.P.Termin1Wunsch, vGew, var vWerte);
    end
    else if (Auf.P.Termin2Wunsch<>0.0.0) then begin
      _VerteileLautDatum(aDL, Auf.P.Termin2Wunsch, vGew, var vWerte);
    end
    else begin
      _VerteileLautDatum(aDL, 1.1.2099, vGew, var vWerte);
    end;
  end;

  // Rest oder Teillieferung?
  vM # Auf.P.Prd.LFS.Gew + vVSB + Auf.P.Prd.Plan.Gew;
  vP # Lib_Berechnungen:Prozent(vM, Auf.P.Gewicht);   // Teil von Ges
  if (vP=0.0) then vInfo # ''
  else if (vP<90.0) then vInfo # 'T'
  else vInfo # 'R';

//debug('P='+anum(vP,2));
//  vM # Auf.P.Gewicht - Auf.P.Prd.LFS.Gew - Auf.P.Prd.VSB.Gew;
//debug(anum(Auf.P.Gewicht,0)+' - '+anum(Auf.P.Prd.LFS.Gew,0)+' - '+anum(Auf.P.Prd.VSB.Gew,0));
//debug(anum(Auf.P.Prd.LFS.Gew,0)+' + '+anum(vVSB,0)+' von '+anum(Auf.P.Gewicht,0));
  
  if (Auf.P.TerminZusage<>0.0.0) then vTermin # Auf.P.TerminZusage
  else if (Auf.P.Termin2Wunsch<>0.0.0) then vTermin # Auf.P.Termin2Wunsch
  else if (Auf.P.Termin1Wunsch<>0.0.0) then vTermin # Auf.P.Termin1Wunsch;

  aDL->WinLstDatLineAdd(aint(Auf.P.Nummer)+'/'+aint(Auf.P.Position)); // NEUE ZEILE
  if (Set.Installname='VBS') then
    aDL->winLstCellSet(aint(Auf.Lieferbed)    ,cClmAufCustom,_WinLstDatLineLast);
  aDL->winLstCellSet(Auf.P.KundenSW         ,cClmAufKunde ,_WinLstDatLineLast);
  aDL->winLstCellSet(Auf.P.KundenSW         ,cClmAufKunde ,_WinLstDatLineLast);
  aDL->winLstCellSet(vZiel                  ,cClmAufZiel  ,_WinLstDatLineLast);
  aDL->winLstCellSet(vVSB                   ,cClmAufVSB   ,_WinLstDatLineLast);
  aDL->winLstCellSet(vInfo                  ,cClmAufInfo  ,_WinLstDatLineLast);
  aDL->winLstCellSet(Auf.P.Gewicht          ,cClmAufSoll  ,_WinLstDatLineLast);
  aDL->winLstCellSet(Auf.P.Prd.VSAuf        ,cClmAufInVSD ,_WinLstDatLineLast);
  aDL->winLstCellSet(vTermin                ,cClmAufTermin,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[1]              ,cClmAufAlt   ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[2]              ,cClmAufHeute ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[3]              ,cClmAufTag1  ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[4]              ,cClmAufTag2  ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[5]              ,cClmAufTag3  ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[6]              ,cClmAufTag4  ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[7]              ,cClmAufTag5  ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[8]              ,cClmAufKW1   ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[9]              ,cClmAufKW2   ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[10]             ,cClmAufKW3   ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[11]             ,cClmAufKW4   ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[12]             ,cClmAufKW5   ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[13]             ,cClmAufMonat ,_WinLstDatLineLast);
  aDL->winLstCellSet(vWerte[14]             ,cClmAufSpaeter  ,_WinLstDatLineLast);

end;


//========================================================================
//========================================================================
sub Insert_Mat(
  aDL   : int;
  aWert : float;) : logic
local begin
  Erx       : int;
  vZiel     : alpha(1000);
  vI        : int;
  vMat      : int;
end;
begin

  Erx # Mat_Data:Read(Auf.A.materialnr);
  if (Erx<200) then RETURN false;

  // Prüfen, ob schon vorhanden...
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(aDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(aDL, vMat , cClmMatNr, vI);
    if (vMat=Mat.Nummer) then RETURN false;
  END;


  Erx # RecLink(101,400,2,_recFirst);   // Lieferanschr. holen
  if (Erx<=_rLocked) then begin
    vZiel # Adr.A.Stichwort+', '+Adr.A.Ort;
  end;
  
  aDL->WinLstDatLineAdd(aint(Auf.P.Nummer)+'/'+aint(Auf.P.Position)); // NEUE ZEILE
  aDL->winLstCellSet(Auf.P.KundenSW         ,cClmMatKunde ,_WinLstDatLineLast);
  aDL->winLstCellSet(vZIEL                  ,cClmMatZiel  ,_WinLstDatLineLast);
  aDL->winLstCellSet(Mat.Nummer             ,cClmMatNr    ,_WinLstDatLineLast);
  aDL->winLstCellSet(Mat.Gewicht.Netto      ,cClmMatNetto ,_WinLstDatLineLast);
  aDL->winLstCellSet(Mat.Gewicht.Brutto     ,cClmMatBrutto,_WinLstDatLineLast);
  aDL->winLstCellSet(Auf.A.Aktion           ,cClmMatAkt   ,_WinLstDatLineLast);
  aDL->winLstCellSet(aWert                  ,cClmMatWert  ,_WinLstDatLineLast);
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub FaerbeZuSpaet(aClm : int)
local begin
  vIst  : date;
  vSoll : date;
  vI    : int;
end;
begin

  if (Auf.P.TerminZusage<>0.0.0) then
    vSoll # Auf.P.TerminZusage
  else if (Auf.P.Termin1Wunsch<>0.0.0) then
    vSoll # Auf.P.Termin1Wunsch
  else
    vSoll # Auf.P.Termin2Wunsch;

  if (Set.Installname='VBS') then begin
    case (StrCut(Adr.A.PLZ,1,1)) of
      '1','2','3','6' : vI # 2;
      '4','5'         : vI # 1;
      '7','8'         : vI # 3;
    end;
    vSoll # Lib_Berechnungen:AddWerktage(vSoll, -vI, false);
  end;
  
  vIst # cnvda(Str_Token(aClm->wpCustom,'|',1));
  if (vIst>vSoll) then begin
    aClm->wpClmColBkg # _WincolLightRed;
  end;

end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel(
  aDLPlan : int;
  aDLPool : int;
)
local begin
  vHdl    : int;
  vItem   : int;
  vMat    : int;
end;
begin

  if (Msg(99,'Soll der gewählte Einträge wieder in den Pool gesetzt werden?',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;

  //WinLstCellGet(aDLPlan, vMat, cClmMat, _WinLstDatLineCurrent);
  //_Move(aDLPlan, aDLPool, vMat);

end;


//========================================================================
//========================================================================
sub SchoninTour(
  aName : alpha;
  aMat  : int) : logic;
local begin
  vDL   : int;
  vMat  : int;
  vI    : int;
end;
begin
  vDL # Winsearch(cMDI, aName);
  if (vDL=0) then RETURN false;

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(vDL, vMat, cClmMatNr, vI);
//debugx(aint(vMat)+' = '+aint(aMat)+'?');
    if (vMat=aMat) then RETURN true;
  END;

  RETURN false;
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit (
  aEvt      : event;
): logic
local begin
  vPar  : int;
  vHdl  : int;
end;
begin
  gTitle        # Translate( cTitle );
  gMenuName     # cMenuName;
  gMenuEvtProc  # here+':EvtMenuCommand';
  Mode          # c_modeEdList;

  vHDl # Winsearch(aEvt:Obj, cDlAuf);
  Lib_GuiCom:RecallList(vHdl, cTitle);      // Usersettings holen

  App_Main:EvtInit( aEvt );
end;


//========================================================================
// EvtClose
//              Schliessen eines Fensters
//========================================================================
sub EvtClose (
  aEvt            : event;
) : logic
local begin
  vHdl        : int;
end;
begin

  vHDl # Winsearch(cMDI, cDlAuf);
  Lib_GuiCom:RememberList(vHdl, cTitle);
  Lib_GuiCom:RememberWindow(aEvt:obj);

  RETURN true;
end;


//========================================================================
//  EvtMenuCommand
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtMenuCommand (
  aEvt            : event;
  aMenuItem       : int;
) : logic
begin
  RETURN Lib_Datalist:EvtMenuCommand( aEvt, aMenuItem );
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit (
  aEvt            : event;
  aId             : int;
) : logic
local begin
  Erx       : int;
  vA    : alpha;
  vCol  : int;
  vI    : int;
end;
begin

  if (Set.Installname='VBS') then begin
    WinLstCellGet(aEvt:Obj, vA                 ,cClmaufCustom , aID);
    if (cnvia(vA)=3) then begin           // ABHOLER?
      $clmAuf->wpClmColBkg # _WinColLightRed;
    end;
  end;
  

  WinLstCellGet(aEvt:Obj, vA                 ,cClmaufNr , aID);
  if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)) then begin
    Erx # RecRead(401,1,0);                 // Auftragspos holen
    if (Erx<=_rLocked) then begin
      Erx # RecLink(100,401,4,_RecFirst);   // Kunden holen
      if (Erx<=_rLocked) then begin
        if (Adr.SperrKundeYN) then begin
          $clmKunde->wpClmColBkg # _WinColLightRed;
        end;
      end;
    end;

    Erx # RecLink(400,401,3,_RecFirst);   // AufKopf holen
    Erx # RecLink(101,400,2,_RecFirst);   // Lieferanschrift holen
    FaerbeZuSpaet($ClmHeute);
    FaerbeZuSpaet($ClmTag1);
    FaerbeZuSpaet($ClmTag2);
    FaerbeZuSpaet($ClmTag3);
    FaerbeZuSpaet($ClmTag4);
    FaerbeZuSpaet($ClmTag5);
    FaerbeZuSpaet($ClmKW1);
    FaerbeZuSpaet($ClmKW2);
    FaerbeZuSpaet($ClmKW3);
    FaerbeZuSpaet($ClmKW4);
    FaerbeZuSpaet($ClmKW5);
  end;

  $clmAuf->wpFontAttr # _WinFontAttrU;
  
  RETURN true;
//  Lib_DataList:EvtLstDatainit(aEvt, aID);
//  vCol # _WinColParent;
//  WinLstCellGet(aEvt:Obj, vA, cClmGewicht, aId);
//  if (vA=cSieheOben) then
//    vCol # _WinColLightGray;
//  Lib_GuiCom:ZLColorLine(aEvt:Obj, vCol);
end;


//========================================================================
//
//========================================================================
sub EvtLstSelect (
  aEvt            : event;
  aRecID          : int;
) : logic
begin
end;


//========================================================================
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Maustaste
  aHitTest              : int;          // Hittest-Code
  aItem                 : handle;       // Spalte oder Gantt-Intervall
  aID                   : bigint;       // RecID bei RecList / Zelle bei GanttGraph / Druckobjekt bei PrtJobPreview
) : logic;
local begin
  Erx       : int;
  vA  : alpha;
  vQ  : alpha;
end;
begin

  if (aButton = _winMousemiddle ) and ( aHitTest = _winHitLstView ) and (aEvt:obj <>0) and (aID<>0) then begin
    if (aItem->wpname='clmAuf') then begin
      aEvt:obj->winLstCellGet(vA, cClmAufNr, aID);
      if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then RETURN false;

      Erx # RecRead(401,1,0);
      if (Erx>_rLocked) then RETURN false;
      
      RecBufClear(404);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.A.Verwaltung','');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QInt(var vQ, 'Auf.A.Nummer'  , '=', Auf.P.Nummer);
      Lib_Sel:QInt(var vQ, 'Auf.A.Position' , '=', Auf.P.Position);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;


/**
  if (aHitTest=_winHitLstHeader) and (aEvt:Obj<>0) and (aEvt:Obj=cDLPool) and (aItem<>0) then begin
    if (aItem->wpName='clmBagTermin') or
    (aItem->wpName='clmBest') or
    (aItem->wpName='clmLiegedauer') or
    (aItem->wpName='clmKW') or
    (aItem->wpName='clmLieferant') or
    (aItem->wpName='clmAufGuete') or
    (aItem->wpName='clmKunde') then begin
      vID # aItem;//Winsearch(aEvt:Obj, 'clmZusatzSort');
      _Resort(aEvt:Obj, vID);
    end;
  end;
***/
  RETURN Lib_Datalist:EvtMouseItem(aEvt, aButton, aHitTest, aItem, aID);
end;


//========================================================================
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aID                   : bigint;       // RecID bei RecList, Node-Deskriptor bei TreeView, Focus-Objekt bei Frame und AppFrame
) : logic;
begin

  // DELETE nur in Versand
//  if ( aKey = _WinKeyDelete) then begin
//    if (aEvt:Obj->wpName=cDlVersand) then begin
//      RecDel(aEvt:Obj, cDLPool);
//    end;
//  end;

  // EDIT nur in Planung...
//  if (aKey = _WinKeyTab) or ( aKey = _winKeyReturn ) then begin
//      RETURN Lib_DataList:EvtKeyItem(aEvt, aKey, aID);
//  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtDragInit(
  aEvt                  : event;        // Ereignis
  aDataObject           : handle;       // Drag-Datenobjekt
  aEffect               : int;          // Rückgabe der erlaubten Effekte (_WinDropEffectNone = Cancel)
  aMouseBtn             : int;          // Verwendete Maustasten (optional)
  aDataPlace            : handle;
) : logic;
local begin
  Erx       : int;
  vA        : alpha;
  vCTE      : int;
  vI        : int;
  vKey      : alpha;
  vItem     : int;
  vFormat   : int;
  vDragList : int;
end;
begin

  vCTE  # aEvt:Obj->wpSelData;
  vI # aDataPlace->wpArgInt;

  // nur Aufträge mit VSB-Mengen draggen...
  aEvt:obj->winLstCellGet(vA, cClmAufNr, vI);
  if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then RETURN false;
  Erx # RecRead(401,1,0);
  if (Erx>_rLocked) then RETURN false;
  if (Auf.P.Prd.VSB.Gew<=0.0) then RETURN false;
  
  Erx # RecLink(100,401,4,_RecFIrst);   // Kunden holen
  if (Erx>_rLocked) or (Adr.SperrKundeYN) then RETURN false;
  
  aEffect # _WinDropEffectCopy | _WinDropEffectMove | _WinDropEffectLink;

  // SINGLE
  vDragList # CteOpen(_CteList);
  vDragList->CteInsertItem(aint(vI), vI, vKey);

  // Setzen der Informationen im Data-Objekt
  // Format aktivieren
  aDataObject->wpFormatEnum(_WinDropDataUser) # true;
  aDataObject->wpName   # cModulname;
  aDataObject->wpcustom # aint(aEvt:obj);

  // Format-Objekt ermittel und Daten anhängen
  vFormat # aDataObject->wpData(_WinDropDataUser);
  vFormat->wpData # vDragList;

  RETURN(true);

end;


//========================================================================
//  EvtDragTerm
//
//========================================================================
sub EvtDragTerm(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aEffect              : int;      // Durchgeführte Dragoperation (_WinDropEffectNone = abgebrochen)
) : logic;
local begin
  vData : int;
end;
begin

  vData # aDataObject->wpData(_WinDropDataUser);
  vData # vData->wpData;
  if (vData<>0) then begin
    CteClear(vData, y);
    CteClose(vData);
  end;

  RETURN(true);
end;


//========================================================================
//  EvtDropEnter
//========================================================================
sub EvtDropEnter(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aEffect              : int;      // Rückgabe der erlaubten Effekte
) : logic;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectLink | _WinDropEffectMove
  RETURN(true);
end;


//========================================================================
//  EvtDropLeave
//========================================================================
sub EvtDropLeave(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  RETURN(true);
end;


//========================================================================
//  EvtDrop
//========================================================================
sub EvtDrop(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aDataPlace           : handle;   // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
) : logic;
local begin
  Erx         : int;
  vData       : int;
  vItem       : int;
  vLine       : int;
  vPlace      : int;
  vA,vB       : alpha;
  vVon, vNach : int;
  vMin        : int;
  vI          : int;
  vPre,vPost  : int;
  vDL1, vDL2  : int;
  vAkt        : int;
  vVSB        : float;
  vZiel       : alpha;
  vKd         : int;
  vReEmpf     : int;
  vGruppe     : int;
  vGruppe2    : int;
  vWert       : float;
  vM          : float;
  vKLimit     : float;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataUser)<>true) then RETURN false;

  if (aDataObject->wpname<>cModulname) then RETURN false;
 
  vDL1 # cnvia(aDataObject->wpcustom);
  vDL2 # aEvt:Obj;

  // Start-Ziel gleich? -> Dann nix
  if (vDL1=vDL2) then RETURN true;

  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
  vData # aDataObject->wpData(_WinDropDataUser);
  vData # vData->wpData;

  vLine   # aDataPlace->wpArgInt(0);
  vPlace  # aDataPlace->wpDropPlace;

  // Einfügeposition...
  case vPlace of
    _WinDropPlaceAppend   : begin
    inc(vLine);
    end;
  end;
  if (vData=0) then RETURN false;

  vDL1->winupdate(_winupdoff);
  if (vDL1<>vDL2) then
    vDL2->winupdate(_winupdoff);

  vMin # 32000;
  FOR vItem # vData->CteRead(_CteFirst)
  LOOP vItem # vData->CteRead(_CteNext, vItem)
  WHILE (vItem<>0) do begin

    vVon  # vItem->spid;
    vNach # vLine;
    vVon # vVon - vPre;

    // Auftrag in Versand ---------------------------
    if (vDL1->wpname=cDLAuf) then begin

      vGruppe # cnvia(aEvt:Obj->wpname);

      // bisheriges Ziel bestimmen...
      if (WinLstDatLineInfo(vDL2, _WinLstDatInfoCount)>0) then begin
        WinLstCellGet(vDL2, vA , cClmMatAufNr, 1);
        if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then CYCLE;
        Erx # RecRead(401,1,0);
        if (Erx>_rLocked) then CYCLE;
        Erx # RecLink(400,401,3,_RecFirst);   // AufKopf holen
        if (Erx>_rLocked) then CYCLE;
        vZiel # aint(Auf.Lieferadresse)+'/'+aint(Auf.Lieferanschrift);
        vKd     # Auf.Kundennr;
        vReEmpf # Auf.Rechnungsempf;
      end;

      WinLstCellGet(vDL1, vA , cClmAufNr, vVon);
      if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then CYCLE;
      Erx # RecRead(401,1,0);
      if (Erx>_rLocked) then CYCLE;
      Erx # RecLink(400,401,3,_RecFirst);   // AufKopf holen
      if (Erx>_rLocked) then CYCLE;
      if (vZiel<>'') and (vZiel<>aint(Auf.Lieferadresse)+'/'+aint(Auf.Lieferanschrift)) then begin
        Msg(440701,'',0,0,0);
        BREAK;
      end;
      if (vKd<>0) and (vKd<>Auf.Kundennr) then begin
        Msg(440701,'',0,0,0);
        BREAK;
      end;
      if (vReEmpf<>0) and (vReEmpf<>Auf.Rechnungsempf) then begin
        Msg(440701,'',0,0,0);
        BREAK;
      end;
      vZiel   # aint(Auf.Lieferadresse)+'/'+aint(Auf.Lieferanschrift);
      vKd     # Auf.Kundennr;
      vReEmpf # Auf.Rechnungsempf;

      // aktuelles Kreditlimit holen...
      Adr_K_Data:Kreditlimit(vReEmpf, "Set.KLP.LFS-Druck", true, var vKLimit,0, 0);
      if ($lbReEmpf1->wpCustom=aint(vReEmpf)) then vKLimit # vKLimit - cnvfa($lbWert1->wpcustom);
      if ($lbReEmpf2->wpCustom=aint(vReEmpf)) then vKLimit # vKLimit - cnvfa($lbWert2->wpcustom);
      if ($lbReEmpf3->wpCustom=aint(vReEmpf)) then vKLimit # vKLimit - cnvfa($lbWert3->wpcustom);

      // Aktionen loopen...
      FOR Erx # RecLink(404,401,12,_recFirst)
      LOOP Erx # RecLink(404,401,12,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if ("Auf.A.Löschmarker"<>'') then CYCLE;
        if (Auf.A.Aktionstyp<>c_Akt_VSB) then CYCLE;
        if (Auf.A.Materialnr=0) then CYCLE;

        if (SchoninTour(cDlVersand+'1', Auf.A.MaterialNr)) then CYCLE;
        if (SchoninTour(cDlVersand+'2', Auf.A.MaterialNr)) then CYCLE;
        if (SchoninTour(cDlVersand+'3', Auf.A.MaterialNr)) then CYCLE;
       
        // Kreditlimit prüfen ------------------------------
        RecLink(814,400,8,_recfirst); // Währung holen
        if ("Auf.WährungFixYN") then
          Wae.VK.Kurs       # "Auf.Währungskurs";
        if (Wae.VK.Kurs<>0.0) then
          Auf.P.Einzelpreis   # Rnd(Auf.P.einzelpreis / "Wae.VK.Kurs",2)

        vM # Auf.A.Menge.Preis;
        if (vM=0.0) then begin
          if (Auf.A.MEH='kg') then vM # Auf.A.Menge
          else if (Auf.A.MEH='t') then vM # Auf.A.Menge * 1000.0;
          else vM # Auf.A.Gewicht;
        end;
        vWert # Lib_Einheiten:WandleMEH(401, "Auf.A.Stückzahl", vM, Auf.A.Menge, Auf.A.MEH, Auf.P.MEH.Preis);
        vWert # (Auf.P.Einzelpreis * vWert / cnvfi(Auf.P.PEH));

        if (Set.KLP.BruttoYN) then begin
          RekLink(819,401,1,_recFirst); // Warengruppe holen
          StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
          Erx # RecRead(813,1,0);
          if (Erx>_rLocked) then RecBufClear(813);
          vWert # Rnd(vWert * ((100.0 + Sts.Prozent) / 100.0), 2);
        end;
        
        if (vWert>vKLimit) then begin
          Erx # RecLink(100,400,4,_recFirst);   // Rechnungsempfänger holen
          Msg(103001,'|'+Adr.Stichwort,0,0,0);
          BREAK;
        end;

        if (Insert_Mat(vDL2, vWert)=false) then CYCLE;
        
        // VSB reduzieren...
        WinLstCellGet(vDL1, vVSB , cClmAufVSB, vVon);
        vVSB # vVSB - Mat.Bestand.Gew;
        WinLstCellSet(vDL1, vVSB, cClmAufVSB, vVon);
        
        _AddSum(vGruppe, Mat.Gewicht.Netto, Mat.Gewicht.Brutto, vWert, vReEmpf);
      END; // Aktionen
    end
    else if (vDL1->wpname<>cDLAuf) and (vDL2->wpname<>cDLAuf) then begin
      // Material in andere Tour ----------------------------
      vGruppe   # cnvia(vDL1->wpname);
      vGruppe2  # cnvia(vDL2->wpname);
      WinLstCellGet(vDL1, vA ,    cClmMatAufNr  ,vVon);
      WinLstCellGet(vDL1, vAkt ,  cClmMatAkt    ,vVon);
      WinLstCellGet(vDL1, vWert,  cClmMatWert   ,vVon);
      if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then CYCLE;

      Erx # RecRead(401,1,0);
      if (Erx>_rLocked) then CYCLE;

      RecbufClear(404);
      Auf.A.Nummer    # Auf.P.Nummer;
      Auf.A.Position  # Auf.P.Position;
      Auf.A.Aktion    # vAkt;
      Erx # RecRead(404,1,0);
      if (Erx<=_rLocked) then begin
        WinLstDatLineRemove(vDL1, vVon);
        
        Erx # Mat_Data:Read(Auf.A.materialnr);
        if (Erx<200) then CYCLE;

        if (Insert_Mat(vDL2, vWert)=false) then CYCLE;

        _AddSum(vGruppe, -Mat.Gewicht.Netto, -Mat.Gewicht.Brutto, -vWert, vReEmpf);
        _AddSum(vGruppe2, Mat.Gewicht.Netto, Mat.Gewicht.Brutto, vWert, vReEmpf);
      end;

    end // Tour->Tour
    else if (vDL2->wpname=cDLAuf) then begin
      // Material zurück in Auftrag -------------------------
 
      vGruppe # cnvia(vDL1->wpname);

      WinLstCellGet(vDL1, vA ,    cClmMatAufNr  ,vVon);
      WinLstCellGet(vDL1, vAkt ,  cClmMatAkt    ,vVon);
      WinLstCellGet(vDL1, vWert,  cClmMatWert   ,vVon);
      if (Lib_Berechnungen:Int2AusAlpha(vA, var Auf.P.Nummer, var Auf.P.Position)=false) then CYCLE;

      Erx # RecRead(401,1,0);
      if (Erx>_rLocked) then CYCLE;

      RecbufClear(404);
      Auf.A.Nummer    # Auf.P.Nummer;
      Auf.A.Position  # Auf.P.Position;
      Auf.A.Aktion    # vAkt;
      Erx # RecRead(404,1,0);
      if (Erx<=_rLocked) then begin
        WinLstDatLineRemove(vDL1, vVon);
        
        Erx # Mat_Data:Read(Auf.A.materialnr);
        if (Erx<200) then CYCLE;

        // VSB Erhöhen...
        vNach # 0;
        FOR vI # 1
        LOOP inc(vI)
        WHILE (vI<=WinLstDatLineInfo(vDL2, _WinLstDatInfoCount)) do begin
          WinLstCellGet(vDL2, vB , cClmAufNr, vI);
          if (vB=vA) then begin
            vNach # vI;
            BREAK;
          end;
        END;
        if (vNach<>0) then begin
          WinLstCellGet(vDL2, vVSB , cClmAufVSB, vNach);
          vVSB # vVSB + Mat.Bestand.Gew;
          WinLstCellSet(vDL2, vVSB, cClmAufVSB, vNach);
        end;
        _AddSum(vGruppe, -Mat.Gewicht.Netto, -Mat.Gewicht.Brutto, -vWert);
      end;
      
      if (WinLstDatLineInfo(vDL2, _WinLstDatInfoCount)=0) then begin
        _Cleanup(vGruppe);
      end;

    end; // Tour->Auf

  END;

  vDL1->WinUpdate(_WinUpdOn, _WinLstFromTop);
  vDL1->WinUpdate(_WinUpdSort);
  if (vDL1<>vDL2) then begin
    vDL2->WinUpdate(_WinUpdOn, _WinLstFromTop);
    vDL2->WinUpdate(_WinUpdSort);
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtClicked(
  aEvt                  : event;        // Ereignis
) : logic;
begin

  if (aEvt:Obj->wpname='btRefresh') then begin
    Refresh();
    RETURN true;
  end;

  if (aEvt:Obj->wpname='btSave1') then begin
    if (SAVE(1)) then begin
    end;
  end;

    if (aEvt:Obj->wpname='btSave2') then begin
    if (SAVE(2)) then begin
    end;
  end;

  if (aEvt:Obj->wpname='btSave3') then begin
    if (SAVE(3)) then begin
    end;
  end;

  if (aEvt:Obj->wpname='btMerge1') then begin
    if (Merge(1)) then begin
    end;
  end;

  if (aEvt:Obj->wpname='btMerge2') then begin
    if (Merge(2)) then begin
    end;
  end;

  if (aEvt:Obj->wpname='btMerge3') then begin
    if (Merge(3)) then begin
    end;
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================