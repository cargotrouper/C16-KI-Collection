@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Planung_Spalt (BSP)
//                    OHNE E_R_G
//  Info
//
//
//  16.07.2018  AH  Erstellung der Prozedur
//  17.09.2018  AH  Änderungen
//  25.09.2018  AH  Änderungen
//  27.09.2018  AH  Fixes
//  01.10.2018  AH  Erweiterungen
//  04.10.2018  AH  Umsortieren in der Planung nach "Zusatz" möglich
//  03.01.2019  AH  Pool <> Nicht-Pool wird anhand JIT-Stempel gemacht
//  07.01.2019  AH  Änderungen "Zusatz" und "Bemkergun" sofort am Server
//  08.01.2019  AH  Proj. 1912/54
//  21.01.2019  AH  Druck Entnahmezettel
//  12.02.2019  AH  Scrollbugfix
//  13.02.2019  AH  neue Spalte "Kunde"
//  20.02.2019  AH  Sortierung nach Zusatz soll zusärtzlich auch Abmessung nehmen
//  26.02.2019  AH  Filter vorblegen, AdHoc
//  02.08.2019  AH  Fixes
//  09.10.2019  AH  Fixes
//  08.11.2019  AH  neue Spalten für Termine (Proj.1994/239)
//  12.12.2019  AH  Überträge verändert laut Proj. 2042/14
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB Start();
//
//
//  lbText->wpcustom  : Abhängikeits-Text
//  gb.Tag->wpCustom  : Datum
//  lb.AZ->wpCustom   : AZ-Text
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
  cSWeNr        : 100
  cCustProc     : 101


end;

define begin
  cDebug      : (gUsername='AHxx')
  
  cModulName  : 'vonSC_BagPlanSpalten'
  cGrenzzeit  :  5:45
  
  cJIT        : '#AUTOJIT#'

  cTitle      : 'Spaltplanung'
  cMenuName   : 'BA1.Feinplanung'

//  cMDI        : gMdiPara
  cMDI  : gMdiMath
  cDLPool     : $dl.Pool
  cDLPoolName : 'dl.Pool'
  cDLPoolFilter     : $dl.PoolFilter
  cDLPoolFilterName : 'dl.PoolFilter'
  cDLPlanName : 'dl.Plan'
  cMaxPlan    : 4//8

  cKeinKal    : 'KEIN KALENDER'

  cClmRecId   : 1
  cClmFolge   : 2
  cClmStatus  : 3
  cClmTlg     : 4
  cClmDau     : 5
  cClmDau2    : 6
  cClmStart   : 7
  cClmEnde    : 8
  cClmStartShow : 9
  cClmEndeShow  : 10
  cClmZusatz  : 11
  cClmGuete   : 12
  cClmBAG     : 13
  cClmVon     : 14
  cClmBis     : 15
  cClmInputD  : 16
  cClmInputB  : 17
  cClmGew     : 18
  cClmTerminW : 19
  cClmTerminZ : 20
  cClmBem     : 21
  cClmKunde   : 22
  cClmzusatzSort  : 23
  
  cLayerOn(a) : begin WinEvtProcessSet(_WinEvtLstDataInit, false); WinLayer(_WinLayerStart, gFrmMain, 30000, a, _WinLayerDarken); end;
  cLayerOff   : begin WinEvtProcessSet(_WinEvtLstDataInit, true);  WinLayer(_WinLayerEnd); end;
  
  LogActive     : true
  Log(a)        : if (LogActive) then Lib_Soa:Dbg(CnvAd(today) + ' ' + cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+ '['+__PROC__+':'+aint(__LINE__)+']' + ':' + a);
  LogErr(a) :    begin  Log(a); Error(99,a); end;
end;

declare StartInner();
declare _702NachDl(aDL :int; aTxt : int; aIstPlan : logic);
declare Recalc(aDL : int; aDat  : date; aTim  : time) : logic
declare _Ueberschriften(aDate : date);
declare  RefreshMussSein(aDL : int);

//========================================================================
// Start
//  Call SFX_Planung_Walzen:Start
//========================================================================
sub Start();
begin

  if (cMDI<>0) then begin
    Lib_guiCom:ReOpenMDI(cMDI);
    RETURN;
  end;

  RecBufClear(998);
  Sel.BAG.Res.Gruppe  # 3;
  Sel.BAG.Res.Nummer  # 3;
  Sel.von.Datum       # today;
  Sel.bis.Datum       # today;
  Sel.Bis.Datum->vmDayModify(31*6);
  if (cDebug) then begin
    Sel.BAG.Res.Gruppe  # 1;
    Sel.BAG.Res.Nummer  # 1;
    gSelected # 1;
    StartInner();
    RETURN;
  end;

  cMDI # Lib_GuiCom:AddChildWindow(gFrmMain,'BA1.Planung.Spalten.Sel',here+':StartInner', true);
  Lib_GuiCom:RunChildWindow(cMDI);
end;


//========================================================================
//========================================================================
sub _IsFiltered(aStatus : alpha) : logic
begin

  if (StrFind(aStatus,'bereit',1)>0) then
    RETURN ($cb.Filter.Bereit->wpCheckState=_WinStateChkChecked);
  if (StrFind(aStatus,'warte',1)>0) then
    RETURN ($cb.Filter.Theo->wpCheckState=_WinStateChkChecked);
  if (StrFind(aStatus,'fertig',1)>0) then
    RETURN ($cb.Filter.Erledigt->wpCheckState=_WinStateChkChecked);

  RETURN ($cb.Filter.Zum->wpCheckState=_WinStateChkChecked);
end;



//========================================================================
//========================================================================
sub FillPlanungen(
  aStartDat   : date)
local begin
  Erx       : int;
  vTxt      : int;
  vSel      : int;
  vSelName  : alpha;
  vQ        : alpha(4000);
  vI        : int;
  vD1, vD2  : date;
  vDat      : date;
  vDlPlan   : int[cMaxPlan];
  vBisher   : int;
  vHdl      : int;
  vAZ       : float;
  vKW,vJahr : word;
  vVorher   : float[5];
end;
begin

  vHdl # Winsearch(cMDI, 'lbtext');
  vTxt # cnvia(vHdl->wpcustom);
  
  _Ueberschriften(aStartDat);

  // DL-Handler puffern...
  FOR vI # 1
  LOOP inc(vI);
  WHILE (vI<=cMaxPlan) do begin
    vDlPlan[vI] # Winsearch(cMDI, cDlPlanName+aint(vI));
    
    vHdl # Winsearch(cMDI, 'dl.Plan'+aint(vI));
    vHdl->WinLstDatLineRemove(_WinLstDatLineAll);   // alle Zeilen leeren
    vHdl->wpAutoupdate # false;

    vHdl # Winsearch(cMDI, 'gb.Tag'+aint(vI));      // Summe Nullen
    vHdl # WinSearch(vHdl, 'lb.SummeZeit');
    vHdl->wpcaption # '';

  END;

  // alle Überträge löschen
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxPlan) do begin
    vHdl # Winsearch(cMDI,'gb.Tag'+aint(vI));
    vHdl # Winsearch(vHdl,'lbUebertrag');
    vHdl->wpCaption # '0';
  END;

  vQ # '';
  vD2 # aStartDat;
  vD2->vmDayModify(cMaxPlan-1);

//  vD1->vmDayModify(-1);   // wegen ÜBERTRAG vom Vortag
  // immer am MONTAG anfangen wegen Übertrag...
  lib_Berechnungen:KW_aus_Datum(aStartDat, var vKW, var vJahr);
  Lib_Berechnungen:Mo_von_KW(vKW, vJahr, var vD1);

  Lib_Sel:QVonBisD(var vQ, 'BAG.P.Plan.StartDat', vD1, vD2);
  Lib_Sel:QAlpha( var vQ, 'BAG.P.Aktion', '=', c_BAG_Spalt);
// 03.01.2019 AH
  //Lib_Sel:QInt( var vQ, 'BAG.P.Reihenfolge', '>', 0);
  //Lib_Sel:QAlpha( var vQ, 'BAG.P.Plan.StartInfo', '!=', cJIT);   // ST 2020-09-03 Auskommentiert für Standard

  // 03.01.2019 AH:
  Lib_Sel:QInt( var vQ, 'BAG.P.Ressource.Grp', '=', Sel.BAG.Res.Gruppe );
  Lib_Sel:QInt( var vQ, 'BAG.P.Ressource', '=', Sel.BAG.Res.Nummer );

  // Selektion aufbauen...
  vSel # SelCreate(702, 8); // nach STARTTERMIN
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vSel);

  // speichern, starten und Name merken...
  vSelName # Lib_Sel:SaveRun(var vSel,0,n);

  vBisher # -5;
  FOR Erx # RecRead(702,vSel,_RecFirst)
  LOOP Erx # RecRead(702,vSel,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    vI # cnvid(BAG.P.Plan.StartDat) - cnvid(aStartDat);

    if (vBisher=-5) then vBisher # vI;

    // Tageswechsel bei Unsichtbaren?
    if (vBisher<0) and (vI<>vBisher) then begin
      vDat # aStartDat;
      vDat->vmDayModify(vBisher);
      vAZ # Rso_Kal_Data:ArbeitsZeit(Rso.Gruppe, vDat);
      vAZ # Max((vVorher[Abs(vBisher)]-vAZ),0.0);
//debugx('Überzeit bei '+aint(vBisher)+'/'+cnvad(vDat)+' : '+anum(vAZ,0));
      if (vBisher<-1) then begin
        vVorher[Abs(vBisher+1)] # vVorher[Abs(vBisher+1)] + vAZ;
//debugx('haue auf next');
       end
      // Wechsel von Unsichtbare zu Sichtbare?
       else if (vBisher=-1) then begin
        vHdl # Winsearch(cMDI,'gb.Tag'+aint(1));
        vHdl # Winsearch(vHdl,'lbUebertrag');
        vHdl->wpCaption # anum(vAZ,0);
      end;
    end;
    
    // Unsichtbare Vortage?
    if (vI>-5) and (vI<0) then begin
      vVorher[abs(vI)] # vVorher[Abs(vI)] + BAG.P.Plan.Dauer;
    end;

    if (vI>=0) then
      _702NachDl(vDlPlan[vI+1], vTxt, true);
      
    vBisher # vI;
  END; // BA-Positionen

  SelClose(vSel);
  SelDelete(702, vSelName);
  

  vHdl # Winsearch(cMDI, 'dl.Plan1');
  vHdl->WinUpdate( _winUpdOn, _winLstPosTop);
  vHdl # Winsearch(cMDI, 'dl.Plan2');
  vHdl->WinUpdate( _winUpdOn, _winLstPosTop);
  vHdl # Winsearch(cMDI, 'dl.Plan3');
  vHdl->WinUpdate( _winUpdOn, _winLstPosTop);
  vHdl # Winsearch(cMDI, 'dl.Plan4');
  vHdl->WinUpdate( _winUpdOn, _winLstPosTop);

end;


//========================================================================
// FillPool
//========================================================================
sub Fillpool();
local begin
  Erx       : int;
  vTxt      : int;
  vSel      : int;
  vSelName  : alpha;
  vQ        : alpha(4000);
  vQ2       : alpha(4000);
  vA        : alpha;
  vDlPool   : int;
  vDlFilter : int;
  vHdl      : int;
end;
begin
  vHdl # Winsearch(cMDI, 'lbtext');
  vTxt # cnvia(vHdl->wpcustom);

  vDlPool # Winsearch(cMDI, cDlPoolName);
  vDlFilter # Winsearch(cMDI, cDlPoolFilterName);
  vDLPool->WinLstDatLineRemove(_WinLstDatLineAll);   // alle Zeilen leeren
  vDlFilter->WinLstDatLineRemove(_WinLstDatLineAll);   // alle Zeilen leeren

  // POOL FÜLLEN-------------------------------------------------
  vQ # '';
  if (cDebug) then begin
    Lib_Sel:QInt( var vQ, 'BAG.P.Nummer', '<=', 1435);
    Lib_Sel:QAlpha( var vQ, 'BAG.P.Aktion', '!=', c_BAG_VSB);
    // 03.01.2019 AH
    //Lib_Sel:QInt( var vQ, 'BAG.P.Reihenfolge', '=', 0);
    //Lib_Sel:QAlpha( var vQ, 'BAG.P.Plan.StartInfo', '=', cJIT);
  end
  else begin
    if ( Sel.BAG.Res.Gruppe != 0 ) then
      Lib_Sel:QInt( var vQ, 'BAG.P.Ressource.Grp', '=', Sel.BAG.Res.Gruppe );
    if ( Sel.BAG.Res.Nummer != 0 ) then
      Lib_Sel:QInt( var vQ, 'BAG.P.Ressource', '=', Sel.BAG.Res.Nummer );
//    Lib_Sel:QDate( var vQ, 'BAG.P.Plan.StartDat', '>=', Sel.von.Datum);
//    Lib_Sel:QDate( var vQ, 'BAG.P.Plan.StartDat', '<=', Sel.bis.Datum);
    Lib_Sel:QDate( var vQ, 'BAG.P.Plan.StartDat', '=', 0.0.0); // ST 2020-09-03 Nur Bags ohne Plantermin für Pool
    Lib_Sel:QDate( var vQ, 'BAG.P.Fertig.Dat', '=', 0.0.0 );
    vQ2 # '';
    Lib_Sel:QAlpha( var vQ2, 'BAG.P.Aktion', '=', c_BAG_Spalt);
    vQ # vQ + ' AND ('+vQ2+')';
    //Lib_Sel:QInt( var vQ, 'BAG.P.Reihenfolge', '=', 0);
    //Lib_Sel:QAlpha( var vQ, 'BAG.P.Plan.StartInfo', '=', cJIT);
  end;

  vQ2 # '';
  Lib_Sel:QAlpha( var vQ2, 'BAG.Löschmarker', '=', '' );
  Lib_Sel:QLogic( var vQ2, 'BAG.VorlageYN', false);
  vQ # vQ + ' AND ( LinkCount(Kopf) > 0) ';

  // Selektion aufbauen...
  vSel # SelCreate(702, 6); // nach LEVEL

  // Verknüpfen mit BAG Kopfdaten
  vSel->SelAddLink('', 700, 702, 1, 'Kopf');

  // nach Level sortieren...
  Erx # vSel->SelDefQuery('', vQ);
  Erx # vSel->SelDefQuery('Kopf', vQ2 );
  if (Erx != 0) then Lib_Sel:QError(vSel);

  // speichern, starten und Name merken...
  vSelName # Lib_Sel:SaveRun(var vSel,0,n);

  FOR Erx # RecRead(702,vSel,_RecFirst)
  LOOP Erx # RecRead(702,vSel,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    vA # Str_Token(BA1_Planung_Subs:GetStatus(vTxt),'|',2);
    if (_IsFiltered(vA)) then
      _702NachDl(vDlFilter, vTxt, false)
    else
      _702NachDl(vDlPool, vTxt, false);
  END;
  SelClose(vSel);
  SelDelete(702, vSelName);

  // Anzeigen
  vDLPool->wpCurrentInt # 0;
end;


//========================================================================
// StartInner
//
//========================================================================
sub StartInner();
local begin
  Erx       : int;
  vHdl      : int;
  vI        : int;
  vTxt      : int;
end;
begin

  if (gSelected=0) then RETURN;
  gSelected # 0;
  if (cMDI<>0) then RETURN;

  // nur Montag bis Donnerstag sind Einstiegstage...
  vI # DateDayOfWeek(Sel.Von.Datum);
  if (vI>4) then
    Sel.Von.Datum->vmDayModify(4-vI);
  
  Rso.Gruppe # Sel.BAG.Res.Gruppe;
  Rso.Nummer # Sel.BAG.Res.Nummer;
  Erx # RecRead(160,1,0);   // Ressource holen
  if (Erx>_rLocked) then RecbufClear(160);

  // Dialog starten...
  cMDI # Lib_GuiCom:OpenMdi(gFrmMain, 'BA1.Planung.Spalten', _WinAddHidden);
  VarInstance(WindowBonus,cnvIA(cMDI->wpcustom));

  // $cb.Filter.Bereit->wpCheckState=_WinStateChkChecked);
  vHdl # Winsearch(cMDI, 'cb.Filter.Theo');
  vHdl->wpCheckState     # _WinStateChkChecked;
  vHdl # Winsearch(cMDI, 'cb.Filter.Erledigt');
  vHdl->wpCheckState     # _WinStateChkChecked;
  vHdl # Winsearch(cMDI, 'cb.Filter.Zum');
  vHdl->wpCheckState     # _WinStateChkChecked;

  vTxt # TextOpen(16);    // Abhaengikeitstext
  vHdl # Winsearch(cMDI, 'lbtext');
  vHdl->wpcustom # cnvai(vTxt);

  // PLANUNG FÜLLEN-------------------------------------------------
  FillPlanungen(Sel.Von.Datum);

  // POOL FÜLLEN-------------------------------------------------
  FillPool();
  
  // Anzeigen
  cMDI->WinUpdate(_WinUpdOn);
  cMDI->Winfocusset(true);
end;


//========================================================================
//========================================================================
sub  _AbleDrucken(aAble : logic);
local begin
  vI    : int;
  vHdl  : int;
  vHdl2 : int;
end
begin
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxPlan) do begin
    vHdl # Winsearch(gMDI, 'gb.Tag'+aint(vI));
    if (vHdl=0) then CYCLE;
    vHdl2 # Winsearch(vHdl, 'btDruck1');
    if (vHdl2<>0) then begin
      vHdl2->wpDisabled # !aAble;
      if (aAble) then vHdl2->wpStyleButton # _WinStyleButtonTBar
      else vHdl2->wpStyleButton # _WinStyleButtonNormal;
    end;
    vHdl2 # Winsearch(vHdl, 'btDruckAlle');
    if (vHdl2<>0) then begin
      vHdl2->wpDisabled # !aAble;
      if (aAble) then vHdl2->wpStyleButton # _WinStyleButtonTBar
      else vHdl2->wpStyleButton # _WinStyleButtonNormal;
    end;
    vHdl2 # Winsearch(vHdl, 'btDruckEnt');
    if (vHdl2<>0) then begin
      vHdl2->wpDisabled # !aAble;
      if (aAble) then vHdl2->wpStyleButton # _WinStyleButtonTBar
      else vHdl2->wpStyleButton # _WinStyleButtonNormal;
    end;
    vHdl2 # Winsearch(vHdl, 'btDruckAlleEnt');
    if (vHdl2<>0) then begin
      vHdl2->wpDisabled # !aAble;
      if (aAble) then vHdl2->wpStyleButton # _WinStyleButtonTBar
      else vHdl2->wpStyleButton # _WinStyleButtonNormal;
    end;
  END;
  
end;


//========================================================================
//========================================================================
sub _Ueberschriften(aDate : date)
local begin
  vHdl  : int;
  vI    : int;
  vF    : float;
  vTxt  : int;
  vDL   : int;
end
begin
  vHdl # WinSearch(cMDI, 'edDatum');
  vHdl->wpCaptionDate # aDate;

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxPlan) do begin
    vHdl # Winsearch(cMDI, 'gb.Tag'+aint(vI));
    vHdl->wpCustom # cnvad(aDate);
    vHdl->wpCaption # Lib_Berechnungen:Tag_Aus_Datum(aDate)+'., '+cnvad(aDate);
    vDL # Winsearch(cMDI, 'dl.Plan'+aint(vI));
    vDL->wpCustom # vHdl->wpCaption;

    vF    # Rso_Kal_Data:ArbeitsZeit(Rso.Gruppe, aDate);
//    vTim  # Rso_Kal_Data:Arbeitsstart(Rso.Gruppe, cnvdi(vI));
    vHdl # Winsearch(vHdl, 'lb.AZ');
    vHdl->wpCaption # anum(vF,0);
    
    // Kalender bauen...
    vTxt # TextOpen(20);
    vHdl->wpCustom # aint(vTxt);
    BA1_Planung_Subs:KTextBuild(vTxt, Rso.Gruppe, aDate);

    aDate->vmDayModify(1);
  END;

end;


//========================================================================
// Sum + Übertrag setzen
//========================================================================
sub _AddSum(
  aBoxNr  : int;
  aAnz    : int;
  aDauer  : int;
  aGew    : int;
  opt aReset  : logic;
)
local begin
  vBox    : int;
  vNr     : int;
  vDau    : int;
  vDauHdl : int;
  vHdl    : int;
  vF      : float;
  vUeber  : int;
end;
begin

  vBox # WinSearch(cMDI, 'Sums'+aint(aBoxNr));
  if (vBox=0) then begin
todo('BOX NOT FOUND: "Sums'+aint(aBoxNr)+'"');
    RETURN;
  end;
  
  vNr # cnvia(vBox->wpName);
  vDauHdl # WinSearch(vBox, 'lb.SummeZeit');
  vDau # cnvia(vDauHdl->wpcustom) + aDauer;
  if (aReset) then
    vDau # 0;
  vDauHdl->wpcustom # cnvai(vDau);

  vHdl # WinSearch(cMDI, 'gb.Tag'+aint(vNr));
  vHdl # WinSearch(vHdl, 'lbUebertrag');
  vUeber # cnvia(vHdl->wpCaption);
  if (aReset) then
    vUeber # 0;
  vDauHdl->wpcaption  # aint(vDau + vUeber);



  vHdl # WinSearch(vBox, 'lb.AZ');
  vF # Lib_Berechnungen:Prozent(cnvfi(vDau+vUeber), cnvfa(vHdl->wpCaption) );
  if (vDau>0) and ((vF>100.0) or (cnvfa(vHdl->wpCaption)=0.0)) then
    vDauHdl->wpColBkg # _WinColLightRed
  else if (vDau>0) and (vF>90.0) then
    vDauHdl->wpColBkg # _WinColLightYellow
  else
    vDauHdl->wpColBkg # _WinColParent;

  // Übertrag ändern
  if (vNr<cMaxPlan) then begin
    vUeber # Max( (vUeber+vDau) - cnvia(vHdl->wpCaption), 0);
//vUeber # 0; // 11.11.2019
    vHdl # WinSearch(cMDI, 'gb.Tag'+aint(vNr+1));
    vHdl # WinSearch(vHdl, 'lbUebertrag');
    vHdl->wpCaption # aint(vUeber);
    _Addsum(vNr+1,0,0,0);
  end;
  
end;


//========================================================================
//========================================================================
sub Recalc(
  aDl       : int;
  aDat      : date;
  aTim      : time;
) : logic
local begin
  Erx       : int;
  vPlanNr : int;
  vI    : int;
  vA,vB : alpha;
  vDat1 : date;
  vTim1 : time;
  vDat2 : date;
  vTim2 : time;
  vDau  : int;
  vDau2 : int;
  vHdl  : int;
  vTxt  : int;
  vSDau : int;
  vA2, vB2  : alpha;
  vRecId    : int;
  vDat      : date;
  vTim      : time;
  vMussDat  : date;
end;
begin
  vPlanNr # cnvia(aDL->wpname);
  if (vPlannr=0) then RETURN true;
  
  vHdl # WinSearch(cMDI, 'gb.Tag'+aint(vPlanNr));
  vHdl # WinSearch(vHdl, 'lb.AZ');
  vTxt # cnvia(vHdl->wpCustom);

  vDat1 # aDat;
  vTim1 # aTim;

  vMussDat # aDat;
//debugx('recalc '+cnvad(vDat1)+' '+cnvat(vTim1));

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(aDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(aDL, vDau , cClmDau, vI);
    WinLstCellGet(aDL, vDau2, cClmDau2, vI);

    WinLstCellGet(aDL, vA2, cClmStart, vI);
    WinLstCellGet(aDL, vB2, cClmEnde, vI);

    if (BA1_Planung_Subs:KTextFind(vTxt, var vDat1, var vTim1, vDau+vDau2, var vDat2, var vTim2)) then begin
      if (vDat1>vMussDat) then begin    // 08.10.2019
        vDat1 # vMussDat;
        vTim1 # 23:59;
        Lib_Berechnungen:TerminModify(var vDat2, var vTim2, cnvfi(vDau + vDau2));
      end;
      vA # cnvad(vDat1)+' '+cnvat(vTim1);
      vB # cnvad(vDat2)+' '+cnvat(vTim2);
    end
    else begin
      vA # cKeinKal;
      vB # cKeinKal;
      vDat2 # vDat1;
      vTim2 # vTim1;
      if (BAG.P.Plan.ManuellYN=false) then
        Lib_Berechnungen:TerminModify(var vDat2, var vTim2, cnvfi(vDau + vDau2));
    end;

    
    WinLstCellSet(aDL, vA, cClmStart, vI);
    WinLstCellSet(aDL, vB, cClmEnde, vI);
    WinLstCellSet(aDL, Str_token(vA,' ',2), cClmStartShow, vI);
    WinLstCellSet(aDL, Str_Token(vB,' ',2), cClmEndeShow, vI);

    // SATZ ÄNDERN ---------------------
    WinLstCellGet(aDL, vRecID ,  cClmRecId, vI);
    WinLstCellGet(aDL, vDau , cClmDau, vI);
    WinLstCellGet(aDL, vDau2, cClmDau2, vI);
    Erx # RecRead(702, 0,_recId,vRecID);
    If (Erx<>_rOK) then begin
      WinLstCellGet(aDL, vA,    cClmBAG, vI);
      Msg(99,'BA '+vA+' kann nicht verändert werden!',0,0,0);
      RETURN false;
    end;

    if ((vA2<>vA) or (vB2<>vB) or (BAG.P.Reihenfolge=0)) AND (BAG.P.Plan.ManuellYN=false)  then begin
//debugX('mod :'+aint(vI)+' von '+vA2+' auf '+vA);
      PtD_Main:Memorize(702);
      RecRead(702,1,_RecLock);
      vDat # cnvda(Str_Token(vA,' ',1));
      vTim # cnvta(Str_Token(vA,' ',2));
      BAG.P.Plan.StartDat   # vDat;
//Lib_Debug:Protokoll('!BSP_Log_Komisch', 'Set BA-Termin '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : '+cnvad(BAG.P.Plan.StartDat)+'   ['+__PROC__+':'+aint(__LINE__)+','+gUsername+']')
      BAG.P.Plan.StartZeit  # vTim;
      BAG.P.Plan.Dauer      # cnvfi(vDau+vDau2);
      vDat # cnvda(Str_Token(vB,' ',1));
      vTim # cnvta(Str_Token(vB,' ',2));
      BAG.P.Plan.EndDat     # vDat;
      BAG.P.Plan.EndZeit    # vTim;
      BAG.P.Reihenfolge     # vI;
      BAG.P.Plan.ManuellYN  # y;
      if (BAG.P.Plan.StartInfo=cJIT) then BAG.P.Plan.StartInfo # '';
      Erx # RekReplace(702);
      if (Erx=_rOK) then
        PtD_Main:Forget(702)
      else
        PtD_Main:Memorize(702);
      BA1_Planung_Subs:SetSonderDauer('', vDau2);
    end;

    vSDau # vSDAu + vDau + vDau2;

    // Ende vom Vorgänger ist Srart vom nächsten...
    vDat1 # vDat2;
    vTim1 # vTim2;
  END;

end;


//========================================================================
//========================================================================
sub Back2Pool(
  aName   : alpha;
  aRecId  : int) : logic
local begin
  Erx : int;
end;
begin

  // SATZ ÄNDERN....
  Erx # RecRead(702, 0,_recId,aRecID);
  If (Erx<>_rOK) then begin
    Msg(99,'BA '+aName+' kann nicht verändert werden!',0,0,0);
    RETURN false;
  end;

  PtD_Main:Memorize(702);
  RecRead(702,1,_RecLock);
//  BAG.P.Plan.StartInfo  # cJIT;
  BAG.P.Reihenfolge     # 0;
  BAG.P.Plan.ManuellYN  # n;
  Erx # RekReplace(702);
  if (Erx=_rOK) then
    PtD_Main:Forget(702)
  else
    PtD_Main:Memorize(702);
//  BA1_Planung_Subs:SetSonderDauer('', vDau2);
end;


//========================================================================
//========================================================================
sub BuildKommissionString(var aPara : alpha) : logic;
local begin
  Erx   : int;
  v702  : int;
  v701  : int;
  vOK   : logic;
  vA    : alpha;
end;
begin

  RecbufClear(401);
  
  v702 # RekSave(702);
  // Outputs loopen...
  FOR Erx # RecLink(701,702,3,_recFirst)
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.BruderID<>0) or (BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;
    if (BAG.IO.NachPosition=0) then CYCLE;

    // Weiterbearbeitungs-Fertigungs-IO gefunden...
    Erx # RecLink(702,701,4,_recFirst);   // Nach-Pos holen
    if (Erx<=_rLocked) then begin
    
      // Kunden-VSB gefunden?
      if (BAG.P.Typ.VSBYN) and (BAG.P.Auftragsnr<>0) then begin
        Erx # Auf_Data:read(BAG.P.Auftragsnr, BAG.P.AuftragsPos ,false);
        if (Erx>=400) then begin
          vA #  Auf.P.KundenSW;
          aPara # StrCut(aPara + vA+';',1,4000);
if (StrLen(aPara)>200) then begin
        RekRestore(v702);
        RETURN true;
end;
          CYCLE;
        end;
        RekRestore(v702);
        RETURN false;
      end;
      
      v701 # RekSave(701);
      vOK # BuildKommissionString(var aPara);
      RekRestore(v701);
      if (vOK) then BREAK;
    end;
    RecBufCopy(v702,702);
  END;
  
  RekRestore(v702);
  RETURN vOK;
end;


//========================================================================
//========================================================================
sub _702NachDL(
  aDL       : int;
  aTxt      : int;
  aIstPlan  : logic;
)
local begin
  Erx       : int;
  vGuete    : alpha;
  vGew      : int;
  vStich    : alpha;
  vStatus   : alpha;
  vVon      : alpha;
  vBis      : alpha;
  vInputD   : float;
  vInputB   : float;
  vOutputD  : float;
  vTlg      : int;
  vDauer    : int;
  vDauer2   : int;
  vX        : float;
  vZeile    : int;
  vI        : int;
  vJ        : int;
  vA        : alpha;
  vGes      : int;
  vVor, vNach : int;
  vStart    : alpha;
  vEnde     : alpha;
  vBem      : alpha(128);
  vW        : word;
  vKunden   : alpha(4000);
  vTerm     : date;
  vTermText : alpha;
  vTerm2     : date;
  vTerm2Text : alpha;
  vTerm3     : date;
  vKW, vJahr  : word;
  v702        : int;
end;
begin
  v702 # RekSAve(702);
  
  vStatus # Str_Token(BA1_Planung_Subs:GetStatus(aTxt),'|',2);

  vTlg # -1;

  FOR Erx # RecLink(701,702,2,_recFirst)    // Input loopen
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if ((BAG.IO.Materialtyp=c_IO_Mat) or
      (BAG.IO.Materialtyp=c_IO_Theo) or
      (BAG.IO.Materialtyp=c_IO_BAG)) and (BAG.IO.VonFertigmeld=0) then begin
      vGuete  # "BAG.IO.Güte";
      vInputD # BAG.IO.Dicke;
      vInputB # BAG.IO.Breite;

      if (vTlg=-1) then
        vTlg # BAG.IO.Teilungen;
      if (vTlg<>BAG.IO.Teilungen) then
        vTlg # -2;

      RecBufClear(200);
      BA1_Planung_Subs:Get701Mat();
      vX # 0.0;

      vGew    # vGew + cnvif(BAG.IO.Plan.Out.GewN);
    end;
  END;

  BuildKommissionString(var vKunden);


  Erx # RecLink(703,702,4,_recFirsT);   // Fertigung holen
  vOutputD  # BAG.F.Dicke;
  vDauer    # cnvif(BAG.P.Plan.Dauer);

  if (aIstPlan) then begin
    _AddSum(cnvia(aDL->wpname), 1, vDauer, vGew);
  end;
  vStart # cnvad(BAG.P.Plan.StartDat)+' '+cnvat(BAG.P.Plan.StartZeit);
  vEnde  # cnvad(BAG.P.Plan.EndDat)+' '+cnvat(BAG.P.Plan.EndZeit);

  if (BAG.P.Fenster.MinDat>0.0.0) then
    vVon # cnvad(BAG.P.Fenster.MinDat)+' '+cnvat(BAG.P.Fenster.MinZei);
// 20.12.2018 : nicht Fenster, sondern Termin laut JIT
//  if (BAG.P.Fenster.MaxDat>0.0.0) then
//    vBis # cnvad(BAG.P.Fenster.MaxDat)+' '+cnvat(BAG.P.Fenster.MaxZei);
  vBis # vStart;


  vDauer2 # BA1_Planung_Subs:GetSonderDauer();
  vDauer  # vDauer - vDauer2;

  vBem # BAG.P.Bemerkung;


  RecLink(700,702,1,_recFirst);   // Kopf holen, 20.08.2020 AH
  BA1_Planung_Subs:FindeKommissionsTermine(var vTerm, var vTerm2, var vTerm3);
  if (vTerm<>0.0.0) then begin
    Lib_Berechnungen:KW_Aus_Datum(vTerm, var vKW, var vJahr);
    vTermText # aint(vKW)+'/'+aint(vJahr);
  end;
  if (vTerm2<>0.0.0) then begin
    Lib_Berechnungen:KW_Aus_Datum(vTerm2, var vKW, var vJahr);
    vTerm2Text # aint(vKW)+'/'+aint(vJahr);
  end;


  aDL->WinLstDatLineAdd(RecInfo(702,_recId)); // NEUE ZEILE
  vZeile # _WinLstDatLineLast;

  aDL->WinLstCellSet(vStatus,          cClmStatus ,vZeile);
  aDL->WinLstCellSet(vTlg,             cClmTlg    ,vZeile);
  aDL->WinLstCellSet(vDauer,           cClmDau    ,vZeile);
  aDL->WinLstCellSet(vDauer2,          cClmDau2   ,vZeile);
  aDL->WinLstCellSet(vStart,           cClmStart  ,vZeile);
  aDL->WinLstCellSet(vEnde,            cClmEnde   ,vZeile);
  aDL->WinLstCellSet(cnvat(BAG.P.Plan.StartZeit),     cClmStartShow  ,vZeile);
  aDL->WinLstCellSet(cnvat(BAG.P.Plan.EndZeit),       cClmEndeShow   ,vZeile);
  aDL->WinLstCellSet(BAG.P.Zusatz,     cClmZusatz ,vZeile);
// wenn Zusatz numerisch sortiert werden sollte
//  Lib_Berechnungen:IntsAusAlpha(BAG.P.Zusatz, var vJ, var vW, var vW);
//  aDL->WinLstCellSet(vJ,              cClmZusatz, vZeile, _WinLstDatModeSortInfo);

  aDL->WinLstCellSet(vGuete,           cClmGuete  ,vZeile);
  aDL->WinLstCellSet(aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position), cClmBag, vZeile);
  aDL->WinLstCellSet(vVon,             cClmVon      ,vZeile);
  aDL->WinLstCellSet(vBis,             cClmBis      ,vZeile);
  aDL->WinLstCellSet(vInputD,          cClmInputD   ,vZeile);
  aDL->WinLstCellSet(vInputB,          cClmInputB   ,vZeile);

  aDL->WinLstCellSet(vGew,             cClmGew      ,vZeile);

  aDL->WinLstCellSet(vTerm2Text,       cClmTerminW  ,vZeile);
  aDL->WinLstCellSet(vTermText,        cClmTerminZ  ,vZeile);
  
  aDL->WinLstCellSet(vBem,             cClmBem      ,vZeile);
  aDL->WinLstCellSet(vKunden,          cClmKunde    ,vZeile);

  // 20.02.2019 AH: Proj. 1912/54
  vA # BAG.P.Zusatz+'|'+cnvaf(vInputD,_FmtNumLeadZero|_FmtNumNoGroup,0,3,12)+'|'+cnvaf(vInputB,_FmtNumLeadZero|_FmtNumNoGroup,0,3,12);
  aDL->WinLstCellSet(vA,     cClmZusatzSort ,vZeile);
  
  RekRestore(v702);
end;


//========================================================================
//========================================================================
sub RefreshTermine(aNr : int)
local begin
  vHdl    : int;
  vDat    : date;
  vTim    : time;
  vBox    : int;
  vDL     : int;
  vUeber  : int;
end;
begin

  cLayerOn('Berechne...');
  
  vBox    # Winsearch(cMDI, 'gb.Tag'+aint(aNr));
  vDat    # cnvda(vBox->wpcustom);

  vDL     # Winsearch(vBox, 'dl.Plan'+aint(aNr));
  vHdl    # Winsearch(vBox, 'lbUebertrag');
  vUeber  # cnvia(vHdl->wpCaption);

  vHdl    # Winsearch(vBox, 'lb.AZ');
  vTim    # 0:0;
  BA1_Planung_Subs:KTextFirstStart(cnvia(vHdl->wpcustom), var vDat, var vTim);
  
  vTim->vmSecondsModify(60 * vUeber);
  Recalc(vDL, vDat, vTim);

  cLayerOff;

end;


//========================================================================
//========================================================================
sub RefreshFilter()
local begin
  vI    : int;
  vA    : alpha;
  vOK   : logic;
end;
begin

  cLayerOn('Filterung...');
  cDLPool->wpAutoUpdate # false;

  // Pool in Ablage schieben...
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(cDLPool, _WinLstDatInfoCount)) do begin
    WinLstCellGet(cDLPool, vA , cClmStatus, vI);
    if (_IsFiltered(vA)=false) then CYCLE;
    // in ABLAGE schieben...
    Lib_DataList:Move(cDLPool, vI, cDlPoolFilter, 1);
//cDLPlan->WinLstDatLineRemove( vI);
    dec(vI);
  END;


  // Ablage in Pool schieben...
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(cDLPoolFilter, _WinLstDatInfoCount)) do begin
    WinLstCellGet(cDLPoolFilter, vA , cClmStatus, vI);
    if (_IsFiltered(vA)) then CYCLE;
    // in POOL schieben...
    Lib_DataList:Move(cDLPoolFilter, vI, cDlPool, 1);
    dec(vI);
  END;

  cDLPool->WinUpdate( _winUpdOn, _winLstPosTop);
  cLayerOff;

end;


//========================================================================
//========================================================================
sub _CopyBox(
  aWin    : int;
  aBoxNr  : int;        // 2
  aTagO   : alpha;      // 2
  aTagU   : alpha);     // 4
local begin
  vHdl, vHdl2, vPar : Int;
end;
begin
  vPar # WinSearch(aWin, 'gt.OR');
  vPar->wpGrouping # _WinGroupingNone;

  vHdl # Winsearch(aWin, 'gb.Tag1');
  vHdl2 # Lib_GuiDynamisch:CopyObject(vHdl, '', vPar, true);  // Tag 1 auf TagX
  vHdl2->wpName # aTagO;
  vHdl # Winsearch(vHdl2, 'dl.Plan1');
  vHdl->wpName # 'dl.Plan'+aint(aBoxNr);
  vHdl # Winsearch(vHdl2, 'Sums1');
  vHdl->wpName # 'Sums'+aint(aBoxNr);

  vHdl # Winsearch(aWin, 'gb.Tag3');
  vHdl2 # Lib_GuiDynamisch:CopyObject(vHdl, '', vPar, true);  // Tag3 auf TagX
  vHdl2->wpName # aTagU;
  vHdl # Winsearch(vHdl2, 'dl.Plan3');
  vHdl->wpName # 'dl.Plan'+aint(aBoxNr+2);
  vHdl # Winsearch(vHdl2, 'Sums3');
  vHdl->wpName # 'Sums'+aint(aBoxNr+2);

  vPar->wpGrouping # _WinGroupingTileVert;
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
  vHdl2 : int;
end;
begin
  gTitle        # Translate( cTitle );
  gMenuName     # cMenuName;
  gMenuEvtProc  # here+':EvtMenuCommand';
  Mode          # c_modeEdList;

  vHDl # Winsearch(aEvt:Obj, cDlPlanname+'1');
  Lib_GuiCom:RecallList(vHdl, cTitle);
  Lib_GuiCom:RecallList(cDLPool, cTitle);     // Usersettings holen
  Lib_GuiCom:RecallList(vHdl, cTitle);
  Lib_GuiCom:RecallList(cDLPool, cTitle);     // Usersettings holen

  // COPY...
  vPar # WinSearch(aEvt:Obj, 'gb.Tag3');
  vHdl # Winsearch(aEvt:obj, 'dl.Plan1');
  vHdl2 # Lib_GuiDynamisch:CopyObject(vHdl, 'x', vPar, true);
  vHdl2->wpname # 'dl.Plan3';

  _CopyBox(aEvt:obj, 2, 'gb.Tag2', 'gb.Tag4');
//  _CopyBox(aEvt:obj, 2, 'gb.Tag2', 'gb.Tag6');
//  _CopyBox(aEvt:obj, 3, 'gb.Tag3', 'gb.Tag7');
//  _CopyBox(aEvt:obj, 4, 'gb.Tag4', 'gb.Tag8');

//debugx(aint(WinSave(aEvt:Obj, _WinSaveDefault, 'ABC')));
//Lib_GuiDynamisch:CopyAdd(aEvt:Obj,

  // 08.10.2019: Listenlyout von 1 auf alle anderen 3
  vHDl # Winsearch(aEvt:Obj, cDlPlanname+'2');
  Lib_GuiCom:RecallList(vHdl, cTitle, cDlPlanname+'1');
  vHDl # Winsearch(aEvt:Obj, cDlPlanname+'3');
  Lib_GuiCom:RecallList(vHdl, cTitle, cDlPlanname+'1');
  vHDl # Winsearch(aEvt:Obj, cDlPlanname+'4');
  Lib_GuiCom:RecallList(vHdl, cTitle, cDlPlanname+'1');


  App_Main:EvtInit( aEvt );

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
  vID     : int;
  vDau    : int;
  vDau2   : int;
  vGew    : int;
  vHdl    : int;
  vItem   : int;
  vNr     : int;
end;
begin

  if (Msg(99,'Sollen die markierten Einträge wieder in den Pool gesetzt werden?',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;

  REPEAT
    vHdl # aDLPlan->wpSelData;
    if (vHdl<>0) then begin
      vHdl # vHdl->wpData(_WinSelDataCteTree);
      if (vHdl<>0) then begin
        vItem # vHdl->CteRead(_CteFirst);
        if (vItem>0) then begin
          vNr # vItem->spID;
          WinLstCellGet(aDLPlan, vID  , cClmRecId, vNr);
          WinLstCellGet(aDLPlan, vDau , cClmDau, vNr);
          WinLstCellGet(aDLPlan, vDau2, cClmDau2, vNr);
          WinLstCellGet(aDLPlan, vGew , cClmGew, vNr);
          
          _AddSum(cnvia(aDlPlan->wpName), -1, -vDau-vDau2, -vGew);

          
          Lib_DataList:Move(aDLPlan, vNr, aDLPool, 1);
          CYCLE;
        end;
      end;
    end;
    BREAK;
  UNTIL (1=1);

  RefreshMussSein(aDLPlan);

  aDLPlan->WinMsdInsert(aDLPlan->wpCurrentInt);
  aDLPlan->WinUpdate( _winUpdOn, _winLstPosTop );

end;


//========================================================================
//========================================================================
sub _Resort(
  aDL   : int;
  aClm  : int)
local begin
  vI    : int;
  vID   : int;
end;
begin

  aClm->wpClmSortFlags # _WinClmSortFlagsAutoActive|_WinClmSortFlagsAutoSelected;
  Winupdate(aDL, _Winupdon|_winupdSort, _WinLstFromFirst);
  aClm->wpClmSortFlags # 0;
  RETURN;
/**
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(aDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(aDL, vID, cClmRecID, vI);
    Erx # RecRead(702, 0, _recID, vID); // BA-Pos holen
debug('KEY702');
//    WinLstCellGet(aDL, vDau , cClmDau, vI);
//    WinLstCellGet(aDL, vDau2, cClmDau2, vI);
  END;
**/
end;


//========================================================================
//========================================================================
sub  RefreshMussSein(aDL : int);
begin
  if (aDL=cDLpool) then RETURN;
  if (aDL->wpName = cDLPlanName+'1') then RefreshTermine(1);
  if (aDL->wpName = cDLPlanName+'2') then RefreshTermine(2);
  if (aDL->wpName = cDLPlanName+'3') then RefreshTermine(3);
  if (aDL->wpName = cDLPlanName+'4') then RefreshTermine(4);

//  $btRefresh2->wpVisible # true;
end;


//========================================================================
//  EvtLstEditCommit
//
//========================================================================
sub EvtLstEditCommit (
  aEvt            : event;
  aColumn         : int;
  aKey            : int;
  aFocusObject    : int;
) : logic
local begin
  Erx   : int;
  vA    : alpha;
  vHdl  : int;
  vI,vJ : int;
  vDau  : int;
  vDau2 : int;
  vMax  : int;
  vBem  : alpha(4000);
  vInputD : float;
  vInputB : float;
end;
begin

  // 07.01.2019 AH: Sofort Editieren vom Zusatz
  if (aColumn->wpname='clmZusatz') then begin
    WinLstCellGet(aEvt:Obj, vI, cClmRecId, _WinLstDatLineCurrent);
    vHdl # Wininfo(aEvt:obj,_WinLstEditObject);
    vA # vHdl->wpcaption;
    Erx # RecRead(702, 0,_recId,vI);
    if (Erx<=_rLocked) then begin
      PtD_Main:Memorize(702);
      RecRead(702,1,_RecLock);
      BAG.P.Zusatz # StrCut(vA,1,32);
      Erx # RekReplace(702);
      if (Erx=_rOK) then
        PtD_Main:Forget(702)
      else
        PtD_Main:Memorize(702);
    end;
    Lib_Datalist:EvtLstEditCommit(aEvt, aColumn, aKey, aFocusObject);
    
    aEvt:Obj->WinLstCellGet(vInputD,          cClmInputD   ,_winLstDatLineCurrent);
    aEvt:Obj->WinLstCellGet(vInputB,          cClmInputB   ,_winLstDatLineCurrent);
    vA # BAG.P.Zusatz+'|'+cnvaf(vInputD,_FmtNumLeadZero|_FmtNumNoGroup,0,3,12)+'|'+cnvaf(vInputB,_FmtNumLeadZero|_FmtNumNoGroup,0,3,12);
    aEvt:Obj->WinLstCellSet(vA,     cClmZusatzSort ,_winLstDatLineCurrent);
//debugx(vA);
//  Winupdate(aEvt:Obj, _Winupdon|_winupdSort, _WinLstFromFirst);
    RETURN true;
  end;

  // 07.01.2019 AH: Sofort Editieren vom Bemerkung
  if (aColumn->wpname='clmBemerkung') then begin
    WinLstCellGet(aEvt:Obj, vI, cClmRecId, _WinLstDatLineCurrent);
    vHdl # Wininfo(aEvt:obj,_WinLstEditObject);
    vA # vHdl->wpcaption;
    Erx # RecRead(702, 0,_recId,vI);
    if (Erx<=_rLocked) then begin
      PtD_Main:Memorize(702);
      RecRead(702,1,_RecLock);
      BAG.P.Bemerkung # StrCut(vA,1,64);
      Erx # RekReplace(702);
      if (Erx=_rOK) then
        PtD_Main:Forget(702)
      else
        PtD_Main:Memorize(702);
    end;
    WinLstCellSet(aEvt:Obj, BAG.P.Bemerkung, cClmBem, _WinLstDatLineCurrent);
    Lib_Datalist:EvtLstEditCommit(aEvt, aColumn, aKey, aFocusObject);
    RETURN true;
  end;


  if (aColumn->wpname='clmFolge') then begin
    WinLstCellGet(aEvt:Obj, vI, cClmFolge, _WinLstDatLineCurrent);
    vHdl # Wininfo(aEvt:obj,_WinLstEditObject);
    vI # vHdl->wpcaptionInt;
    vMax # aEvt:Obj->WinLstDatLineInfo(_WinLstDatInfoCount);
    if (vI<0) then vI # 1
    else if (vI>vMax) then vI # vMax;
    vHdl->wpCaptionInt # vI;
    vJ # aEvt:Obj->wpCurrentInt;

    if (vI<>vJ) then begin
      aEvt:Obj->wpCurrentInt # 0;
      Lib_DataList:Move(aEvt:Obj, vJ, aEvt:obj, vI);
      aEvt:Obj->wpMultiselect # false;
      aEvt:Obj->wpCurrentInt # vI;
      aEvt:Obj->wpMultiselect # true;
      aEvt:Obj->WinMsdInsert(vI);
      RefreshMussSein(aEvt:obj);
      RETURN true;
    end;
  end;

  if (aColumn->wpname='clmDauer') then begin
    WinLstCellGet(aEvt:Obj, vDau, cClmDau, _WinLstDatLineCurrent);
    vHdl # Wininfo(aEvt:obj,_WinLstEditObject);
    vDau # (vHdl->wpcaptionInt) - vDau; // Delta
    _AddSum(cnvia(aEvT:obj->wpname), 0, vDau, 0);
  end;

  if (aColumn->wpname='clmDauer2') then begin
    WinLstCellGet(aEvt:Obj, vI, cClmRecId, _WinLstDatLineCurrent);
    Erx # RecRead(702, 0,_recId,vI);
    if (Erx<=_rLocked) then begin
      WinLstCellGet(aEvt:Obj, vJ, cClmDau2, _WinLstDatLineCurrent);
      vHdl # Wininfo(aEvt:obj,_WinLstEditObject);
      vDau2 # vHdl->wpcaptionint;
      BA1_Planung_Subs:SetSonderDauer('', vDau2);
      vDau2 # (vDau2 - vJ);  // DELTA
      PtD_Main:Memorize(702);
      RecRead(702,1,_recLock);
      BAG.P.Plan.Dauer      # BAG.P.Plan.Dauer + cnvfi(vDau2);
      Erx # RekReplace(702);
      if (Erx=_rOK) then
        PtD_Main:Forget(702)
      else
        PtD_Main:Memorize(702);
      
      _AddSum(cnvia(aEvT:obj->wpname), 0, vDau2, 0);
    end;
  end;

  Lib_Datalist:EvtLstEditCommit(aEvt, aColumn, aKey, aFocusObject);
  
  RefreshMussSein(aEvt:obj);

  RETURN true;
end;


//========================================================================
//========================================================================
sub Refreshall(
  aDat      : date;
  aMitPool  : logic);
local begin
  vDat  : date;
end;
begin
  cLayerOn('Refresh...');
  Appoff();
  _AddSum(1,0,0,0,y);
  _AddSum(2,0,0,0,y);
  _AddSum(3,0,0,0,y);
  _AddSum(4,0,0,0,y);
  vDat # $edDatum->wpCaptionDate;
  FillPlanungen(vDat);
  if (aMitPool) then
    FillPool();
  Appon();
  cLayerOff;
end;


//========================================================================
//========================================================================
sub EvtFocusTerm(
  aEvt                  : event;        // Ereignis
  aFocusObject          : handle;       // Objekt, das den Fokus bekommt
) : logic;
begin

  if (aEvt:Obj->wpName='edDatum') and ($edDatum->wpchanged) then begin
//    FillPlanungen(aEvt:Obj->wpCaptionDate);
    RefreshAll(aEvt:Obj->wpCaptionDate, false);
  end;
  
  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
begin

//  if (aEvt:Obj->wpname='lbUebertrag') then begin
//    RefreshMussSein(0);
//  end;
  RETURN(true);
end;


//========================================================================
//  EvtMenuCommand
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtMenuCommand (
  aEvt            : event;
  aMenuItem       : int;
) : logic
local begin
  Erx     : int;
  vHdl    : int;
  vID     : int;
end;
begin

  if (aMenuItem->wpName='Mnu.ZumBA') then begin
    vHdl # WinfocusGet();
    if (vHdl<>0) then begin
      if (Wininfo(vHdl, _wintype)=_WinTypeDataList) then begin
//    if (vHdl=cDLPlan) or (vHdl=cDLPool) then begin
        if (vHdl->wpCurrentInt>0) then begin
          WinLstCellGet(vHdl, vID, cClmRecID, vHdl->wpCurrentInt);
          Erx # RecRead(702, 0, _recID, vID); // BA-Pos holen
          if (Erx<=_rLocked) then begin
            Erx # RecLink(700,702,1,_recFirst); // BA holen
            gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung','',y);
            VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
            w_Command  # 'REPOS';
            w_Cmd_Para # AInt(vID);
            Lib_GuiCom:RunChildWindow(gMDI);
            RETURN true;
          end;
        end;
      end;
    end;
  end;
  
  if (aMenuItem->wpName='Mnu.DL.Refresh') then begin
    RETURN true;
  end;

  if (aMenuItem->wpName='Mnu.DL.Delete') then begin
    RETURN true;
  end;

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
  Erx   : int;
  vA    : alpha;
  vHdl  : int;
  vID   : int;
end;
begin
  Lib_DataList:EvtLstDatainit(aEvt, aID);
  
  // 07.01.2019 AH: Bereits Endzeit vorhanden?
  WinLstCellGet(aEvt:Obj, vID, cClmRecID, aId);
  Erx # RecRead(702,0 ,_recId, vID);
  if (Erx<=_rLocked) then begin
    if (App_Betrieb_RsoPlan:_SucheZeit(false)) then begin
      if (BAG.Z.EndDatum<>0.0.0) then begin
        Lib_GuiCom:ZLColorLine(aEvt:Obj, _WinColLightGreen);
      end;
    end;
  end;

  
  aEvt:Obj->WinLstCellSet(aId, cClmFolge, aId); // lfd. Zeilennummer

  // Status...
  vHdl # Winsearch(aEvt:obj, 'clmStatus');
  WinLstCellGet(aEvt:Obj, vA , cClmStatus, aId);
  if (StrFind(vA,'bereit',1)>0) then
    vHdl->wpClmColBkg # _WinColLightGray
  else if (StrFind(vA,'warte',1)>0) then
    vHdl->wpClmColBkg # _WinColLightYellow
  else if (StrFind(vA,'fertig',1)>0) then
    vHdl->wpClmColBkg # RGB(200,255,200)
  else
    vHdl->wpClmColBkg # RGB(200,200,255);

  // Termin...
  vHdl # Winsearch(aEvt:obj, 'clmTerminende');
  WinLstCellGet(aEvt:Obj, vA , cClmStart, aId);
  if (vA=cKeinKal) then
    vHdl->wpClmColBkg # _WinColLightRed;
  WinLstCellGet(aEvt:Obj, vA , cClmEnde, aId);
  if (vA=cKeinKal) then
    vHdl->wpClmColBkg # _WinColLightRed;
end;


//========================================================================
//
//========================================================================
sub EvtLstSelect (
  aEvt            : event;
  aRecID          : int;
) : logic
local begin
  Erx   : int;
  vID   : int;
end;
begin

  WinLstCellGet(aEvt:Obj, vID, cClmRecID, aRecId);
  Erx # RecRead(702,0 ,_recId, vID);

  $RL.BA1.Input->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);
  $RL.BA1.Fertigung->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);

end;


//========================================================================
//  Input_EvtLstRecControl
//
//========================================================================
sub Input_EvtLstRecControl(
	aEvt         : event;    // Ereignis
	aRecID       : int       // Record-ID des Datensatzes
) : logic
begin
	RETURN (BAG.IO.BruderID=0) and (BAG.P.Position<>0);
end;


//========================================================================
//  Input_EvtLstDataInit
//
//========================================================================
sub Input_EvtLstDataInit (
  aEvt            : event;
  aId             : int;
) : logic
local begin
  Erx   : int;
  vA    : alpha;
  vHdl  : int;
end;
begin
  BA1_IO_I_Main:EvtLstDataInit(aEvt, aId);

  GV.Alpha.12 # '';
  if (BAG.IO.Materialnr<>0) then begin
    Erx # Mat_Data:Read(BAG.IO.Materialnr);
    if (Erx>=200) then begin
      GV.Alpha.12 # Mat.Lagerplatz;
    end;
  end;
 
end;


//========================================================================
//  Fertigung_EvtLstDataInit
//
//========================================================================
sub Fertigung_EvtLstDataInit (
  aEvt            : event;
  aId             : int;
) : logic
local begin
  Erx   : int;
  vA    : alpha;
  vHdl  : int;
end;
begin
  BA1_F_Main:EvtLstDataInit(aEvt, aId);
  
  GV.Alpha.02 # '';
  if (BAG.F.Verpackung<>0) then begin
    Erx # RecLink(704,703,6,_RecFirst);   // Verpackung holen
    if (Erx<=_rLocked) then begin
      if (BAG.Vpg.LiegendYN) then GV.ALpha.02 # 'Liegend'
      else if (BAG.Vpg.StehendYN) then GV.ALpha.02 # 'stehend';
    end;
  end;
  
  // Inputs loopen...
  FOR Erx # RecLink(701,702,2,_RecFirst)
  LOOP Erx # RecLink(701,702,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.BruderID=0) and (BAG.P.Position<>0) then BREAK;
  END;

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
  vI          : int;
  vAnz        : int;
  v703        : int;
end;
begin

  // Aufräumen...
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxPlan) do begin
    vHdl # Winsearch(cMDI, 'gb.Tag'+aint(vI));
    vHdl # Winsearch(vHdl, 'lb.AZ');
    TextClose(cnvia(vHdl->wpCustom))
  END;

  vHdl # Winsearch(cMDI, 'lbtext');
  TextClose(cnvia(vHdl->wpCustom))

  vHDl # Winsearch(cMDI, cDlPlanname+'1');

  Lib_GuiCom:RememberList(vHdl, cTitle);
  Lib_GuiCom:RememberList(cDLPool, cTitle);
  Lib_GuiCom:RememberWindow(aEvt:obj);

  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtTerm(
  aEvt                  : event;        // Ereignis
) : logic;
begin
//  cMDI # 0;
  RETURN App_Main:EvtTerm(aEvt);
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked (
  aEvt            : event
) : logic
local begin
  vHdl  : int;
  vDat  : date;
end;
begin

  case ( aEvt:obj->wpName ) of
    'btDruck1' : begin
      vHdl # Wininfo(aEvt:Obj, _Winparent);   // Übertrag
      if (vHdl=0) then RETURN true;
      vHdl # Wininfo(vHdl, _Winparent);       // GroupBox
      if (vHdl=0) then RETURN true;
      vHdl # WinInfo(vHdl, _Winfirst, 0, _WinTypeDataList);
      BA1_Planung_Subs:Druck1(vHdl, false);
    end;
    'btDruckEnt' : begin
      vHdl # Wininfo(aEvt:Obj, _Winparent);   // Übertrag
      if (vHdl=0) then RETURN true;
      vHdl # Wininfo(vHdl, _Winparent);       // GroupBox
      if (vHdl=0) then RETURN true;
      vHdl # WinInfo(vHdl, _Winfirst, 0, _WinTypeDataList);
      BA1_Planung_Subs:Druck1(vHdl, true);
    end;
    'btDruckAlle' : begin
      vHdl # Wininfo(aEvt:Obj, _Winparent);   // Übertrag
      if (vHdl=0) then RETURN true;
      vHdl # Wininfo(vHdl, _Winparent);       // GroupBox
      if (vHdl=0) then RETURN true;
      vHdl # WinInfo(vHdl, _Winfirst, 0, _WinTypeDataList);
      BA1_Planung_Subs:DruckAll(vHdl);
    end;
    'btDruckAlleEnt' : begin
      vHdl # Wininfo(aEvt:Obj, _Winparent);   // Übertrag
      if (vHdl=0) then RETURN true;
      vHdl # Wininfo(vHdl, _Winparent);       // GroupBox
      if (vHdl=0) then RETURN true;
      vHdl # WinInfo(vHdl, _Winfirst, 0, _WinTypeDataList);
      BA1_Planung_Subs:DruckAllEnt(vHdl);
    end;
    
    'bt.Refresh' : begin
      RefreshAll($edDatum->wpCaptionDate, true);
    end;

    'bt.RefreshFilter' :
      RefreshFilter();

    'bt.Next' : begin
      vDat # $edDatum->wpCaptionDate;
      vDat->vmDayModify(1);
      // nach Donnerstag auf MONTAG springen...
      if (DateDayOfWeek(vDat)=5) then
        vDat->vmDayModify(3);
      $edDatum->wpCaptionDate # vDat;
      cLayerOn('Refresh...');
      _AddSum(1,0,0,0,y);
      _AddSum(2,0,0,0,y);
      _AddSum(3,0,0,0,y);
      _AddSum(4,0,0,0,y);
      FillPlanungen(vDat);
      cLayerOff;
    end;
    
    'bt.Prev' : begin
      vDat # $edDatum->wpCaptionDate;
      vDat->vmDayModify(-1);
      // nach Montag auf DONNERSTAG springen...
      if (DateDayOfWeek(vDat)=7) then
        vDat->vmDayModify(-3);
      $edDatum->wpCaptionDate # vDat;
      cLayerOn('Refresh...');
      _AddSum(1,0,0,0,y);
      _AddSum(2,0,0,0,y);
      _AddSum(3,0,0,0,y);
      _AddSum(4,0,0,0,y);
      FillPlanungen(vDat);
      cLayerOff;
    end;
    
  end;
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
  Erx     : int;
  vID     : int;
  vA      : alpha;
end;
begin

  // JumpTo
  if (aButton = _winMousemiddle ) and ( aHitTest = _winHitLstView ) then begin
    if (aID=0) or (aItem=0) then RETURN true;
    if (aItem->wpname='clmBAG') then begin
      WinLstCellGet(aEvt:Obj, vA, cClmBAG, aID);
      BAG.Nummer # cnvia(Str_Token(vA,'/',1));
      BAG.P.Nummer    # BAG.Nummer;
      BAG.P.Position # cnvia(Str_Token(vA,'/',2));
      Erx # RecRead(700,1,0);
      if (Erx>_rMultikey) then RETURN true;
      Erx # RecRead(702,1,0);
      if (Erx>_rMultikey) then RETURN true;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end
    RETURN true;
  end;

  
  if (aHitTest=_winHitLstHeader) and (aEvt:Obj<>0) and (aEvt:Obj<>cDLPool) and (aItem<>0) and (aItem->wpName='clmZusatz') then begin
    if (Msg(99,'Reihenfolge wirklich umsortieren?',_WinIcoQuestion, _WinDialogYesNo,2)=_WinIdYes) then begin
      vID # Winsearch(aEvt:Obj, 'clmZusatzSort');
      //_Resort(aEvt:Obj, aItem);
      _Resort(aEvt:Obj, vID);
      RefreshTermine(cnvia(aEvt:Obj->wpname));
    end;
  end;

  if (aHitTest=_winHitLstHeader) and (aEvt:Obj<>0) and (aEvt:Obj=cDLPool) and (aItem<>0) and (aItem->wpName='clmZusatz') then begin
    vID # Winsearch(aEvt:Obj, 'clmZusatzSort');
    _Resort(aEvt:Obj, vID);
  end;


//if (aHittest=_WinHitLstHeader) then
//debugx(aint(aHittest));
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

  // DELETE nur in PLanung
  if ( aKey = _WinKeyDelete) then begin
    if (aEvt:Obj<>cDLPool) then
      RecDel(aEvt:Obj, cDLPool);
  end;

  // EDIT nur in Planung...
  if (aKey = _WinKeyTab) or ( aKey = _winKeyReturn ) then begin
    if (aEvt:Obj<>cDLPool) then
      RETURN Lib_DataList:EvtKeyItem(aEvt, aKey, aID);
  end;
  
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
begin
  RETURN BA1_Planung_Subs:EvtDragInit(aEvt, aDataObject, var aEffect, aMouseBtn, aDataPlace, cModulname);
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
  vData       : int;
  vItem       : int;
  vLine       : int;
  vPlace      : int;
  vA          : alpha;
  vVon, vNach : int;
  vMin        : int;
  vI          : int;
  vID         : int;
  vRunter     : logic;
  vPre,vPost  : int;
  vAnz        : int;
  vDL1, vDL2  : int;
  vDau        : int;
  vDau2       : int;
  vGew        : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataUser)<>true) then RETURN false;
  
  if (aDataObject->wpname<>cModulname) then RETURN false;

  vDL1 # cnvia(aDataObject->wpcustom);
  vDL2 # aEvt:Obj;
  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
  vData # aDataObject->wpData(_WinDropDataUser);
  vData # vData->wpData;

  vLine   # aDataPlace->wpArgInt(0);
  vPlace  # aDataPlace->wpDropPlace;

  // Einfügeposition.
  case vPlace of
    _WinDropPlaceAppend   : begin
    inc(vLine);//vA # 'NACH';//  inc(vLine);
    end;
  end;
  if (vData=0) then RETURN false;

// if (vPlace=_WinDropPlaceThis)   => Maus AUF einem Eintrag
  vDL1->winupdate(_winupdoff);
  if (vDL1<>vDL2) then
    vDL2->winupdate(_winupdoff);
  
  vMin # 32000;
  FOR vItem # vData->CteRead(_CteFirst)
  LOOP vItem # vData->CteRead(_CteNext, vItem)
  WHILE (vItem<>0) do begin

    vVon  # vItem->spid;
    vNach # vLine;
//debugx(aint(vVon)+' nach '+aint(vNach));
    if (vDL1=vDL2) then begin
      if (vVon=vNach) then CYCLE;
      vRunter # vVon<vNach;
      if (vRunter) then begin
//          if (vPlace=_WinDropPlaceThis) then
        vVon  # vVon - vPre;
        vNach # vNach - 1;              // wegen REMOVE
      end
      else begin
        vNach # vNach + vPost;
      end;
      if (vNach=0) then CYCLE;
    end
    else begin  // Pool <-> Plan oder Plan <-> Pool oder Plan <-> Plan
      vVon # vVon - vPre;
    end;

    WinLstCellGet(vDL1, vDau , cClmDau, vVon);
    WinLstCellGet(vDL1, vDau2, cClmDau2, vVon);
    WinLstCellGet(vDL1, vGew , cClmGew, vVon);
    WinLstCellGet(vDL1, vID, cClmRecId, vVon);
    WinLstCellGet(vDL1, vA, cClmBAG, vVon);

//debugx(aint(vVon)+' nach '+aint(vNach));
    Lib_DataList:Move(vDL1, vVon, vDL2, vNach);

    if (vDL1=vDL2) then begin
      if (vRunter) then
        inc(vPre)
      else
        inc(vPost);
    end
    else begin    // Pool <-> Plan
      inc(vPre);
      if (vDL1=cDlPool) then
        _AddSum(cnvia(vDL2->wpname), 1, vDau+vDau2, vGew)
      else if (vDL2=cDlPool) then begin
        _AddSum(cnvia(vDL1->wpname), -1, -vDau-vDau2, -vGew);
        Back2Pool(vA, vID);
      end
      else begin  // Plan <-> Plan
        _AddSum(cnvia(vDL1->wpname), -1, -vDau-vDau2, -vGew);
        _AddSum(cnvia(vDL2->wpname), 1, vDau+vDau2, vGew);
      end;
    end;
    
//debugx('  '+aint(vVon)+' nach '+aint(vNach));
  END;

  RefreshMussSein(vDL1);

  vDL1->WinUpdate(_WinUpdOn, _WinLstFromTop);
  vDL1->WinUpdate(_WinUpdSort);
  if (vDL1<>vDL2) then begin
    RefreshMussSein(vDL2);
    vDL2->WinUpdate(_WinUpdOn, _WinLstFromTop);
    vDL2->WinUpdate(_WinUpdSort);
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================