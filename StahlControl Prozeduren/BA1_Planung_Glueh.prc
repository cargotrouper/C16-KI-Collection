@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Planung_Glueh
//                    OHNE E_R_G
//  Info
//
//
//  14.08.2018  AH  Erstellung der Prozedur
//  26.09.2018  AH  Erweiterungen
//  10.10.2018  AH  Fixes
//  11.10.2018  AH  Umbau auf EINEN Nummerkreis pro Ofen
//  17.10.2018  AH  Fixes
//  16.01.2019  AH  Fix: zwei gleiche LfdNr auf unterschiedlichen Rso überschreiben sich
//  08.11.2019  AH  neue Spalten für Termine (Proj.1994/239)
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
//   BAG.P.Cust.Sort  # 'GLPLAN'+aint(vLfd);  BAG.P.Aktion2 # 'GLPLAN';
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cDebug      : (Sel.BAG.Res.Gruppe=123) and (Sel.BAG.Res.Nummer=123)
//  cDebug : (gUsername='AH')

  cFaktor     : 4 // von ÖFEN auf OFEN
  cModulName  : 'vonSC_BagPlanGluehen'
  cAS_Stichwort : 'GLÜHFEINPLANUNG'

  cTitle      : 'Glühplanung'
  cMenuName   : 'BA1.Feinplanung'

  cMDI        : gMdiMath
  cDLPool     : $dl.Pool
  cDLPoolName : 'dl.Pool'
  cDLPoolFilter : $dl.PoolFilter
  cDLPlanName : 'dl.Plan'

  cKonvektorBreite  : 100.0
  cKeinKal    : 'KEIN KALENDER'

  cClmRecId   : 1
  cClmFolge   : 2
  cClmStatus  : 3
  cClmTerminW : 4
  cClmTerminZ : 5
  cClmBAG     : 6
  cClmZusatz  : 7
  cClmGuete   : 8
  cClmInputB  : 9
  cClmGew     : 10
  cClmGewEin  : 11
  cClmStk     : 12
  cClmDauer   : 13
  cClmVon     : 14
  cClmBis     : 15
  
  cModeStart  : 'START'   // alles offen
  cModeLfd    : 'LFD'     // beim Tippen von LFD
  cModeEdit   : 'EDIT'
end;

declare StartInner(opt aSock : int; opt aLfd : int);
declare _702NachDl(aDL :int; aTxt : int; aIstPlan : logic; opt aStk : int);
declare _Recalc(aDL : int; aDat  : date; aTim  : time)
declare _Ueberschriften(aDate : date);
declare _AbleDrucken(aAble : logic);
declare LoadLfd(aBox  : int; aLfd  : int; aSock : int;) : logic;

//========================================================================
// Start
//  Call SFX_Planung_Glueh:Start
//========================================================================
sub Start();
begin
//Lib_Debug:StartBluemode();

  if (cMDI<>0) then begin
    Lib_guiCom:ReOpenMDI(cMDI);
    RETURN;
  end;

  RecBufClear(998);
  Sel.BAG.Res.Gruppe  # 4;
  Sel.BAG.Res.Nummer  # 99;
  Sel.von.Datum       # today;
  Sel.bis.Datum       # today;
  Sel.Bis.Datum->vmDayModify(31*6);
  if (cDebug) then begin
    Sel.BAG.Res.Gruppe  # 4;
    Sel.BAG.Res.Nummer  # 4;
    gSelected # 1;
    StartInner();
    RETURN;
  end;

  cMDI # Lib_GuiCom:AddChildWindow(gFrmMain,'BA1.Planung.Gluehen.Sel',here+':StartInner', true);
  Lib_GuiCom:RunChildWindow(cMDI);
//  cMdi # Lib_GuiCom:OpenMdi(gFrmMain, aName, _WinAddHidden);
//  cMdi->WinUpdate(_WinUpdOn);
end;


//========================================================================
sub GetMode() : alpha
local begin
  aBox    : int;
end;
begin
//debugx('get '+aBox->wpname+' '+aBox->wpCustom);
  aBox # Winsearch(gMDI, 'bt.Abbruch');
  RETURN aBox->wpCustom;
end;


//========================================================================
//========================================================================
sub _setSockel(
  aBox  : int;
  aDL   : int;
  aMode : alpha)
local begin
  vOK   : logic;
  vHdl  : int;
  vNr   : int;
end;
begin
  Lib_Guicom:Able(Winsearch(aBox, 'edLfd'), (aMode=cModeStart or aMode=cModeLfd));
  vNr # Winsearch(aBox, 'edLfd')
  vNr # vNr->wpCaptionInt;
  Lib_Guicom:Able(Winsearch(aBox, 'btLoad'), aMode=cModeLfd);

  vOK # (aMode=cModeEdit or aMode=cModeStart);

  Lib_Guicom:Able(Winsearch(aBox, 'edDatum'),     vOk);
  Lib_Guicom:Able(Winsearch(aBox, 'edZeit'),      vOk);
  Lib_Guicom:Able(Winsearch(aBox, 'edDauer'),     vOk);
  Lib_Guicom:Able(Winsearch(aBox, 'edProgramm'),  vOk);
  Lib_Guicom:Able(Winsearch(aBox, 'edHalteZeit'), vOk);
  Lib_Guicom:Able(Winsearch(aBox, 'edKonvektor'), vOk);
  Lib_Guicom:Able(Winsearch(aBox, 'edTemp'),      vOk);
  Lib_Guicom:Able(Winsearch(aBox, 'edC1'),        vOk);
  Lib_Guicom:Able(Winsearch(aBox, 'edC2'),        vOk);

  aDL->wpDisabled # !vOK;

  vHdl # Winsearch(aBox, 'btReset');
  vHdl->wpvisible # (aMode=cModeStart) or (aMode=cModeLfd);

//  vHdl # Winsearch(aBox, 'btDruck');
//  vHdl->wpDisabled # !((vNr>0) and (aMode=cModeStart))
  _AbleDrucken(((vNr>0) and (aMode=cModeStart)));

end;


//========================================================================
//========================================================================
sub _SucheBAzuLfd(
  aLfd  : int;
  aSock : int;) : logic
local begin
  Erx : int;
end;
begin
  BAG.P.Cust.Sort         # 'GLPLAN'+aint(aLfd);
  Erx # RecRead(702,11,0);
  WHILE (Erx<=_rMultikey) and
    (BAG.P.Cust.Sort='GLPLAN'+aint(aLfd)) and
    ((BAG.P.Ressource<>Rso.Nummer) or (BAG.P.Ressource.Grp<>Rso.Gruppe)) do begin
    Erx # RecRead(702,11,_recNext);
  END;
  
  if (Erx>_rMultikey) or
      (BAG.P.Bemerkung<>'Sockel '+aint(aSock)+', LfdNr.'+aint(aLfd)) or
      (BAG.P.Cust.Sort<>'GLPLAN'+aint(aLfd)) or
      (BAG.P.Ressource<>Rso.Nummer) or
      (BAG.P.Ressource.Grp<>Rso.Gruppe) then begin
      RecBufClear(702);
     RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub SetMode(
  aMode     : alpha)
local begin
  vHdl  : int;
  vMode : alpha;
  vOk   : logic;
  aBox  : int;
end;
begin
//debugx('Set mode:'+aMode);
//  if (aBox=0) then begin
//    SetMode(aMode, Winsearch(gMDI,'gb.Sockel1'));
//    SetMode(aMode, Winsearch(gMDI,'gb.Sockel2'));
//    RETURN;
//  end;
//debugx('set '+aBox->wpname+' '+vMode);
 // aBox # Winsearch(gMDI,'gb.Sockel1');
  vHdl # Winsearch(gMDI, 'bt.Abbruch');
  vMode # vHdl->wpCustom;
  vHdl->wpCustom # aMode;

  _SetSockel(Winsearch(gMDI, 'gb.Sockel1'), Winsearch(gMDI, 'DL.Plan1'), aMode);
  _SetSockel(Winsearch(gMDI, 'gb.Sockel2'), Winsearch(gMDI, 'DL.Plan2'), aMode);

  if (vMode=aMode) then RETURN;

  // Umfokusieren...
  if ((vMode=cModeStart) and (aMode=cModeEdit)) or
      ((vMode=cModeLfd) and (aMode=cModeEdit)) then
    Winfocusset($edDatum, true)

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

  vHdl # Winsearch(gMDI, 'gb.Sockel1');
  vHdl2 # Winsearch(vHdl, 'btDruck');
  if (vHdl2<>0) then begin
    vHdl2->wpDisabled # !aAble;
    if (aAble) then vHdl2->wpStyleButton # _WinStyleButtonTBar
    else vHdl2->wpStyleButton # _WinStyleButtonNormal;
  end;
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

  vHdl # Winsearch(gMDI, 'gb.Sockel2');
  vHdl2 # Winsearch(vHdl, 'btDruck');
  if (vHdl2<>0) then begin
    vHdl2->wpDisabled # !aAble;
    if (aAble) then vHdl2->wpStyleButton # _WinStyleButtonTBar
    else vHdl2->wpStyleButton # _WinStyleButtonNormal;
  end;
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
end;


//========================================================================
//  Druckt das "Excel-Sheet"
//========================================================================
sub Druck(
  aLfd  : int;
  aSock : int;)
begin

  if (_SucheBAzuLfd(aLfd, aSock)) then begin
    Lib_Dokumente:Printform(700,'Gluehplanung',false);
  end;
  
end;


//========================================================================
// StartInner
//
//========================================================================
sub StartInner(opt aSock : int; opt aLfd : int);
local begin
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vQ        : alpha(4000);
  vQ2       : alpha(4000);
  vDlPool   : int;
  vHdl      : int;
  vI,vJ,vK  : int;
  vDat      : date;
  vTim      : time;
  vA        : alpha(1000);
  vTxt      : int;
end;
begin

  if (gSelected=0) then RETURN;
  gSelected # 0;
  if (cMDI<>0) then RETURN;
    
  Rso.Gruppe # Sel.BAG.Res.Gruppe;
  Rso.Nummer # Sel.BAG.Res.Nummer;
  Erx # RecRead(160,1,0);   // Ressource holen
  if (Erx>_rLocked) then ReCbufClear(160);

  // Dialog starten...
  cMDI # Lib_GuiCom:OpenMdi(gFrmMain, 'BA1.Planung.Gluehen', _WinAddHidden);
  VarInstance(WindowBonus,cnvIA(cMDI->wpcustom));
  vDlPool # Winsearch(cMDI, cDlPoolName);

  vTxt # TextOpen(16);    // Abhaengikeitstext
  vHdl # Winsearch(cMDI, 'lbtext');
  vHdl->wpcustom # cnvai(vTxt);

  // POOL FÜLLEN-------------------------------------------------
  vQ # '';
//  if ( Sel.BAG.Res.Gruppe != 0 ) then
if (cDebug=false) then begin
  Lib_Sel:QInt( var vQ, 'BAG.P.Ressource.Grp', '=', 4 );
//  if ( Sel.BAG.Res.Nummer != 0 ) then
  Lib_Sel:QInt( var vQ, 'BAG.P.Ressource', '=', 0 );
end;

  Lib_Sel:QDate( var vQ, 'BAG.P.Plan.StartDat', '<=', Sel.bis.Datum);
  Lib_Sel:QDate( var vQ, 'BAG.P.Fertig.Dat', '=', 0.0.0 );
  vQ2 # '';
  Lib_Sel:QAlpha( var vQ2, 'BAG.P.Aktion', '=', c_BAG_Obf); // 2023-03-22 AH SOLLTE c_BAG_Gluehen
  vQ # vQ + ' AND ('+vQ2+')';
  Lib_Sel:QInt( var vQ, 'BAG.P.Reihenfolge', '=', 0);

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
    _702NachDl(vDlPool, vTxt, false);
  END;
  SelClose(vSel);
  SelDelete(702, vSelName);

  // Vorbelegungen
//  SetMode(Winsearch(cMDI, 'gb.Sockel1'), cModeStart);
//  SetMode(Winsearch(cMDI, 'gb.Sockel2'), cModeStart);
  SetMode(cModeStart);

  if (aSock=1) then begin
    vHdl # Winsearch($gb.Sockel1, 'edLfd');
    vHdl->wpCaptionint # aLfd;
    LoadLfd($gb.Sockel1, aLfd, 1);
  end;
  if (aSock=2) then begin
    vHdl # Winsearch($gb.Sockel2, 'edLfd');
    vHdl->wpCaptionint # aLfd;
    LoadLfd($gb.Sockel2, aLfd, 2);
  end;

  // Anzeigen
  vDLPool->wpCurrentInt # 0;
  cMDI->WinUpdate(_WinUpdOn);
  cMDI->Winfocusset(true);
end;


//========================================================================
// Sum + Übertrag setzen
//========================================================================
sub _AddSum(
  aBoxNr      : int;
  aStk        : int;
  aHoehe      : float;
  aKG         : int;
  opt aReset  : logic;
)
local begin
  vBox    : int;
  vHdl    : int;
  vF      : float;
  vI      : int;
end;
begin
  vBox # WinSearch(cMDI, 'gb.Sockel'+aint(aBoxNr));

  vHdl # WinSearch(vBox, 'lb.SummeH');
  if (aReset) then
    vF # 0.0
  else
    vF   # cnvfa(vHdl->wpcaption) + aHoehe;
  vHdl->wpcaption  # anum(vF, 0);
  
  vHdl # WinSearch(vBox, 'lb.SummeKG');
  if (aReset) then
    vI # 0
  else
    vI # cnvia(vHdl->wpcaption) + aKG;
  vHdl->wpcaption  # aint(vI);

  vHdl # WinSearch(vBox, 'lb.SummeStk');
  if (aReset) then
    vI # 0
  else
    vI # cnvia(vHdl->wpcaption) + aStk;
  vHdl->wpcaption  # aint(vI);
end;


//========================================================================
//========================================================================
sub _702NachDL(
  aDL       : int;
  aTxt      : int;
  aIstPlan  : logic;
  opt aStk  : int;
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
  vStk      : int;
  vX        : float;
  vZeile    : int;
  vI        : int;
  vA        : alpha;
  vGes      : int;
  vVor, vNach : int;
  vDauer    : int;
  vTerm     : date;
  vTermText : alpha;
  vTerm2      : date;
  vTerm2Text  : alpha;
  vTerm3      : date;
  vKW, vJahr  : word;
  vGesStk   : int;
  vGewEin   : int;
end;
begin

  vStatus # Str_Token(BA1_Planung_Subs:GetStatus(aTxt),'|',2);

  FOR Erx # RecLink(701,702,2,_recFirst)    // Input loopen
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if ((BAG.IO.Materialtyp=c_IO_Mat) or
      (BAG.IO.Materialtyp=c_IO_Theo) or
      (BAG.IO.Materialtyp=c_IO_BAG)) and (BAG.IO.VonFertigmeld=0) then begin
      vGuete  # "BAG.IO.Güte";
      vInputD # BAG.IO.Dicke;
      vInputB # BAG.IO.Breite;

      RecBufClear(200);
      BA1_Planung_Subs:Get701Mat();
      vX # 0.0;

      vGew    # vGew + cnvif(BAG.IO.Plan.Out.GewN);
      vGesStk # vGesStk + BAG.IO.Plan.Out.Stk
    end;
  END;
//  if (vStk<>0) then
//    vGew # vGew / vStk;

  vStk  # vGesStk;
  // exisitierende Unterteilungen abziehen:
  if (aIstPlan=false) then begin
    FOR Erx # RecLink(706,702,9,_RecFirst)
    LOOP Erx # RecLink(706,702,9,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.AS.Stichwort=cAS_Stichwort) then begin
        vStk  # vStk - cnvia(Str_Token(BAG.AS.Bemerkung,';',3));
      end;
    END;
    if (vStk<=0) then RETURN;
  end
  else begin
    vStk  # aStk;
  end;

  vGewEin # cnvif(Lib_Berechnungen:Dreisatz(cnvfi(vGew), cnvfi(vGesStk), 1.0));



  Erx # RecLink(703,702,4,_recFirsT);   // Fertigung holen
  vOutputD  # BAG.F.Dicke;
  vDauer    # Cnvif(BAG.P.Plan.Dauer) * cFaktor;

  if (aIstPlan) then begin
    _AddSum(cnvia(aDL->wpname), vStk, vInputB * cnvfi(vStk), vGewEin * vStk);
  end;

  // 15.10.2018 AH:
  //vTermin # BA1_Planung_Subs:FindeKommissionsTermine();
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

  if (BAG.P.Fenster.MinDat>0.0.0) then
    vVon # cnvad(BAG.P.Fenster.MinDat)+' '+cnvat(BAG.P.Fenster.MinZei);
// 20.12.2018 : nicht Fenster, sondern Termin laut JIT
//  if (BAG.P.Fenster.MaxDat>0.0.0) then
//    vBis # cnvad(BAG.P.Fenster.MaxDat)+' '+cnvat(BAG.P.Fenster.MaxZei);
  vBis # cnvad(BAG.P.Plan.StartDat)+' '+cnvat(BAG.P.Plan.StartZeit);
  

  aDL->WinLstDatLineAdd(RecInfo(702,_recId)); // NEUE ZEILE
  vZeile # _WinLstDatLineLast;

  aDL->WinLstCellSet(vStatus,          cClmStatus   ,vZeile);
  aDL->WinLstCellSet(vTerm2Text,       cClmTerminW  ,vZeile);
  aDL->WinLstCellSet(vTermText,        cClmTerminZ  ,vZeile);
  aDL->WinLstCellSet(aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position), cClmBag, vZeile);
  aDL->WinLstCellSet(BAG.P.Zusatz,     cClmZusatz   ,vZeile);
  aDL->WinLstCellSet(vGuete,           cClmGuete    ,vZeile);
  aDL->WinLstCellSet(vInputB,          cClmInputB   ,vZeile);
  aDL->WinLstCellSet(vGewEin * vStk,   cClmGew      ,vZeile);
  aDL->WinLstCellSet(vGewEin,          cClmGewEin   ,vZeile);
  aDL->WinLstCellSet(vStk,             cClmStk      ,vZeile);
  aDL->WinLstCellSet(vDauer,           cClmDauer    ,vZeile);
  aDL->WinLstCellSet(vVon,             cClmVon      ,vZeile);
  aDL->WinLstCellSet(vBis,             cClmBis      ,vZeile);
end;


//========================================================================
//========================================================================
sub _SetGluehText(
  aTxt  : int;
  aKon  : int;
  aC1   : int;
  aC2   : int;
  aHalt : int;
  aTemp : int;
) : logic;
begin
  TextClear(aTxt);
  TextAddLine(aTxt, 'Konvektoren : '+aint(aKon));
  TextAddLine(aTxt, 'C° innen    : '+aint(aC1));
  TextAddLine(aTxt, 'C° außen    : '+aint(aC2));
  TextAddLine(aTxt, 'Haltezeit   : '+aint(aHalt));
  TextAddLine(aTxt, 'Temp.zurück : '+aint(aTemp));
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub _GetGluehText(
  aTxt      : int;
  var aKon  : int;
  var aC1   : int;
  var aC2   : int;
  var aHalt : int;
  var aTemp : int;
) : logic;
local begin
  vI  : int;
  vA  : alpha;
end;
begin
  vI # TextSearch(aTxt, 1, 1, 0, 'Konvektoren');
  if (vI<>0) then begin
    vA # TextLineRead(aTxt, vI, 0);
    aKon # cnvia(Str_Token(vA,':',2));
  end;
  vI # TextSearch(aTxt, 1, 1, 0, 'C° innen');
  if (vI<>0) then begin
    vA # TextLineRead(aTxt, vI, 0);
    aC1 # cnvia(Str_Token(vA,':',2));
  end;
  vI # TextSearch(aTxt, 1, 1, 0, 'C° außen');
  if (vI<>0) then begin
    vA # TextLineRead(aTxt, vI, 0);
    aC2 # cnvia(Str_Token(vA,':',2));
  end;
  vI # TextSearch(aTxt, 1, 1, 0, 'Haltezeit');
  if (vI<>0) then begin
    vA # TextLineRead(aTxt, vI, 0);
    aHalt # cnvia(Str_Token(vA,':',2));
  end;
  vI # TextSearch(aTxt, 1, 1, 0, 'Temp.zurück');
  if (vI<>0) then begin
    vA # TextLineRead(aTxt, vI, 0);
    aTemp # cnvia(Str_Token(vA,':',2));
  end;
  RETURN true;
end;


//========================================================================
//========================================================================
sub _GetLfdNr() : int
local begin
  vNr   : int;
  vName : alpha;
end;
begin

  vName # 'Gluehen_'+aint(Rso.Gruppe)+'/'+aint(Rso.Nummer);
  Prg.Nr.Name       # vName;
  if (RecRead(902,1,0)>_rLocked) then begin
    RecBufClear(902);
    Prg.Nr.Name         # vName;
    Prg.Nr.Nummer       # 2;
    Prg.Nr.Bezeichnung  # 'Glühplanung Rso_'+aint(Rso.Gruppe)+'/'+aint(Rso.Nummer);
    if (RekInsert(902,_reclock,'AUTO')<>_rOK) then RETURN -1;
    RETURN 1;
  end;

  vNr # Lib_Nummern:ReadNummer(vName);
  if (vNr<>0) then Lib_Nummern:SaveNummer()
  else RETURN -1;
  
  RETURN vNr;
end;


//========================================================================
//========================================================================
sub LoadLfd(
  aBox  : int;
  aLfd  : int;
  aSock : int;
) : logic;
local begin
  Erx   : int;
  vBox  : int;
  vSock : int;
  vDL   : int;
  vHdl  : int;
  vTxt  : int;
  v702  : int;
  vStk  : int;
  vName : alpha;
  vPrg  : int;
  vKon  : int;
  vTim  : time;
  vDat  : date;
  vC1   : int;
  vC2   : int;
  vDau  : int;
  vHalt : int;
  vTemp : int;
end
begin
 
  vSock # cnvia(aBox->wpName);

  if (aLfd>0) then begin
    LoadLfd(aBox, 0, 0);
    //SetMode(aBox, cModeStart);
    SetMode(cModeStart);
  end;

  vDL   # Winsearch(cMDI, cDLPlanName+aint(vSock))

  RecBufClear(702);
  if (aLfd<>0) then begin
    //BAG.P.Cust.Sort         # 'S'+aint(vSock)+'|NR'+aint(aLfd);
    if (_SucheBAzuLfd(aLfd, aSock)=false) then begin
      Msg(99,'Keine LfdNr '+aint(aLfd)+' auf Sockel '+aint(vSock)+' gefunden!',0,0,0);
      RETURN false;
    end;
  end;

  vPrg # cnvia(BAG.P.Zusatz);
  vDat # BAG.P.Plan.StartDat;
  vTim # BAG.P.Plan.StartZeit;
  vDau # cnvif(BAG.P.Plan.Dauer);

  // Text lesen...
  vTxt # TextOpen(20);
  vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
  TextRead(vTxt, vName, 0);
  _GetGluehText(vTxt, var vKon, var vC1, var vC2, var vHalt, var vTemp);
  TextClose(vTxt);

  // Eingaben setzen...
  vHdl # Winsearch(aBox,'edProgramm');
  vHdl->wpCaptionInt # vPrg;
  vHdl # Winsearch(aBox,'edKonvektor');
  vHdl->wpCaptionInt # vKon;
  vHdl # Winsearch(aBox,'edDatum');
  vHdl->wpCaptionDate # vDat;
  vHdl # Winsearch(aBox,'edZeit');
  vHdl->wpCaptionTime # vTim;
  vHdl # Winsearch(aBox,'edC1');
  vHdl->wpCaptionInt # vC1;
  vHdl # Winsearch(aBox,'edC2');
  vHdl->wpCaptionInt # vC2;
  vHdl # Winsearch(aBox,'edDauer');
  vHdl->wpCaptionInt # vDau;
  vHdl # Winsearch(aBox,'edHaltezeit');
  vHdl->wpCaptionInt # vHalt;
  vHdl # Winsearch(aBox,'edTemp');
  vHdl->wpCaptionInt # vTemp;

  vHdl  # Winsearch(cMDI, 'lbtext');
  vTxt  # cnvia(vHdl->wpcustom);

  if (aLfd=0) then begin
    vDL->WinLstDatLineRemove(_WinLstDatLineall);
    _AddSum(vSock,0,0.0,0,y);
  end
  else begin
    _AddSum(vSock, 0, cnvfi(vKon)*cKonvektorbreite, 0);
    v702 # RekSave(702);
    // Unterteilungen loopen...
    FOR Erx # RecLink(706,v702,9,_RecFirst)
    LOOP Erx # RecLink(706,v702,9,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.AS.Stichwort<>cAS_Stichwort) then CYCLE;

    // Zusatz     "BA4711/5"
    // Bemerkung  "5 Stück"
      BAG.P.Nummer    # cnvia(Str_Token(BAG.AS.Zusatz,'/',1));
      BAG.P.Position  # cnvia(Str_Token(BAG.AS.Zusatz,'/',2));
      vStk            # cnvia(BAG.AS.Bemerkung);
      Erx # RecRead(702,1,0);
      if (Erx<=_rLocked) then begin
         _702NachDl(vDL, vTxt, true, vStk);
      end;
    END;
    RekRestore(v702);
  end;
  vDL->wpCurrentInt # 0;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _NeuerGluehBag(
  aSock : int;
  aPrg  : int;
  aDat  : date;
  aTim  : time;
  aDau  : int;
  aKon  : int;
  aC1   : int;
  aC2   : int;
  aHalt : int;
  aTemp : int;
) : int;
local begin
  Erx   : int;
  vLfd  : int;
  v702  : int;
  vPos  : int;
  vTxt  : int;
  vName : alpha;
  vBAG  : int;
end;
begin
  vLfd # _GetLfdNr();
  if (vLfd<0) then RETURN -1;
  
  v702 # RekSave(702);

  // nächste freie Position finden...
  FOR BAG.P.Position # 100
  LOOP inc(BAG.P.Position)
  WHILE (RecRead(702,1,_recTest)<=_rOK) do begin
  END;
  vBAG # BAG.P.Nummer;
  vPos # BAG.P.Position;
  RecBufClear(702);
  BAG.P.Nummer    # v702->BAG.P.Nummer;
  BAG.P.Position  # vPos;
  
  BAG.P.Aktion2           # 'GLPLAN';
  BAG.P.ExternYN          # n;
  BAG.P.Ressource.Grp     # Rso.Gruppe;
  BAG.P.Ressource         # Rso.Nummer;
  BAG.P.Reihenfolge       # 0;
  BAG.P.Kosten.Wae        # 1;
  BAG.P.Kosten.PEH        # 1000;
  BAG.P.Kosten.MEH        # 'kg';
  BAG.P.Bemerkung         # 'Sockel '+aint(aSock)+', LfdNr.'+aint(vLfd);
//  BAG.P.Cust.Sort         # 'S'+aint(aSock)+'|NR'+aint(vLfd);
  BAG.P.Cust.Sort         # 'GLPLAN'+aint(vLfd);

  Erx # RecLink(828,702,8,_recFirst);   // Arbeitsgang holen
  if (Erx>_rLocked) then RETURN -1;
  BAG.P.Aktion            # ArG.Aktion;
  BAG.P.Aktion2           # ArG.Aktion2;
  "BAG.P.Typ.1In-1OutYN"  # "ArG.Typ.1In-1OutYN";
  "BAG.P.Typ.1In-yOutYN"  # "ArG.Typ.1In-yOutYN";
  "BAG.P.Typ.xIn-yOutYN"  # "ArG.Typ.xIn-yOutYN";
  "BAG.P.Typ.VSBYN"       # "ArG.Typ.VSBYN";
  BAG.P.Bezeichnung       # ArG.Bezeichnung

  BAG.P.Zusatz            # aint(aPrg);
  BAG.P.Plan.StartDat     # aDat;
//Lib_Debug:Protokoll('!BSP_Log_Komisch', 'Set BA-Termin '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : '+cnvad(BAG.P.Plan.StartDat)+'   ['+__PROC__+':'+aint(__LINE__)+','+gUsername+']')
  BAG.P.Plan.StartZeit    # aTim;
  BAG.P.Plan.Dauer        # cnvfi(aDau);

  BA1_Data:SetStatus(c_BagStatus_Offen);
  if (BA1_P_Data:Insert(0,'MAN')<>_rOK) then RETURN -1;

  // Texte füllen...
  vTxt # TextOpen(20);
  _SetGluehText(vTxt, aKon, aC1, aC2, aHalt, aTemp);
  vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
  TxtWrite(vTxt,vName, _TextUnlock);
  TextClear(vTxt);
  vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
  TxtWrite(vTxt,vName, _TextUnlock);
  TextClose(vTxt);

  RecBufClear(v702);
  RETURN vLfd;
end;


//========================================================================
//========================================================================
sub _UpdateGluehBag(
  aGrp  : int;
  aRso  : int;
  aSock : int;
  aLfd  : int;
  aPrg  : int;
  aDat  : date;
  aTim  : time;
  aDau  : int;
  aKon  : int;
  aC1   : int;
  aC2   : int;
  aHalt : int;
  aTemp : int;
) : logic;
local begin
  vTxt  : int;
  vName : alpha;
end;
begin

  PtD_Main:Memorize(702);
  RecRead(702,1,_recLock);

  BAG.P.Zusatz            # aint(aPrg);
  BAG.P.Plan.StartDat     # aDat;
//Lib_Debug:Protokoll('!BSP_Log_Komisch', 'Set BA-Termin '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : '+cnvad(BAG.P.Plan.StartDat)+'   ['+__PROC__+':'+aint(__LINE__)+','+gUsername+']')

  BAG.P.Plan.StartZeit    # aTim;
  BAG.P.Plan.Dauer        # cnvfi(aDau);
  if (aGrp<>0) then begin
    BAG.P.Ressource.Grp     # aGrp;
    BAG.P.Ressource         # aRso;
  end;
  BA1_Data:SetStatus(c_BagStatus_Offen);
  if (BA1_P_Data:Replace(0,'MAN')<>_rOK) then begin
    PtD_Main:Forget(702)
    RETURN false;
  end;
  PtD_Main:Memorize(702);

  // Texte füllen...
  vTxt # TextOpen(20);
  _SetGluehText(vTxt, aKon, aC1, aC2, aHalt, aTemp);
  vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
  TxtWrite(vTxt,vName, _TextUnlock);
  TextClear(vTxt);
  vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
  TxtWrite(vTxt,vName, _TextUnlock);
  TextClose(vTxt);
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub _ModGluehBag(
  aSock : int;
  aPrg  : int;
  aDat  : date;
  aTim  : time;
  aDau  : int;
  aKon  : int;
  aC1   : int;
  aC2   : int;
  aHalt : int;
  aTemp : int;
) : int;
begin

end;


//========================================================================
sub _Insert706()
local begin
  Erx : int;
end;
begin
  REPEAT
    inc(BAG.AS.lfdNr);
    Erx # RekInsert(706);
  UNTIL (Erx=_rOK);
end;


//========================================================================
//========================================================================
sub _DLtoTxt(
  aWer  : int;
  aDL   : int;
  aTxt  : int) : logic;
local begin
  Erx     : int;
  vName   : alpha;
  vI,vJ   : int;
  vID     : int;
  vStk    : int;
  vA      : alpha;
  vS1, vS2  : int;
  vS0       : int;
end;
begin

  // Datalist loopen...
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(aDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(aDL, vID    ,cClmRecId  ,vI);
    WinLstCellGet(aDL, vStk   ,cClmStk    ,vI);

    Erx # RecRead(702, 0,_recId,vID);
    If (Erx<>_rOK) then RETURN false;

    vName # 'BA'+aint(BAG.P.nummer)+'|'+aint(BAG.P.Position)+'|';
    vJ # TextSearch(aTxt,1,1, 0, vName);
    // BA1234|1|3|4|0
    // BAnr|pos|stka|stkb|stkpool
    if (vJ>0) then
      vA # TextLineRead(aTxt, vJ, _TextLineDelete)
    else
      vA # '0|0|0|0|0';
    vS1 # Cnvia(Str_Token(vA,'|',3));
    vS2 # Cnvia(Str_Token(vA,'|',4));
    vS0 # Cnvia(Str_Token(vA,'|',5));
    if (aWer=1) then
      vS1 # vS1 + vStk
    else if (aWer=2) then
      vS2 # vS2 + vStk
    else
      vS0 # vS0 + vStk;
    TextAddLine(aTxt, vName + aint(vS1)+'|'+ aint(vS2)+'|'+aint(vS0));
  END;
  
  RETURN true;
end;


//========================================================================
sub _SetUT(
  aSock : int;
  aLfd  : int;
  aBAG  : int;
  aPos  : int;
  aStk  : int;
) : logic
local begin
  Erx   : int;
  vName : alpha;
  vStk  : int;
end
begin

  // ABBUCHUNG:
  // Zusatz     "BA4711/100"
  // Bemerkung  "Nach S1; Lfd1234; 5 Stück"

  // ZUBUCHUNG:
  // Zusatz     "BA4711/5"
  // Bemerkung  "5 Stück"

  vName # 'BA'+aint(aBag)+'/'+aint(aPos);
  RecBufClear(706);
  BAG.AS.Nummer   # BAG.P.Nummer;
  BAG.AS.Position # BAG.P.Position;
  BAG.AS.Zusatz   # vName;

  Erx # RecRead(706,2,0);
  if (Erx<=_rMultikey) then begin
    // VERÄNDERN...
    vStk  # cnvia(Str_Token(BAG.AS.Bemerkung, ';',3));
    if (vStk=aStk) then RETURN true;

    aBAG # cnvia(Str_token(BAG.AS.Zusatz,'/',1));
    aPos # cnvia(Str_token(BAG.AS.Zusatz,'/',2));
    vName # 'BA'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position);

// Löschen?
    if (aStk=0) then begin
//debugx('del KEY706');
      if (RekDelete(706)<>_rOK) then RETURN false;
      // Gegenbuchung...
      RecBufClear(706);
      BAG.AS.Nummer   # aBAG;
      BAG.AS.Position # aPos;
      BAG.AS.Zusatz   # vName;
      Erx # RecRead(706,2,0);
      if (Erx<=_rMultikey) then begin
        if (RekDelete(706)<>_rOK) then RETURN false;
      end;
      RETURN true;
    end;
    // Stk verändern...
//debugx('edit KEY706');
    RecRead(706,1,_recLock);
    BAG.AS.Bemerkung # 'nach S'+aint(aSock)+'; Lfd'+aint(aLfd)+'; '+aint(aStk)+' Stück';
    if (RekReplace(706)<>_rOK) then RETURN false;

    // Gegenbuchung...
    RecBufClear(706);
    BAG.AS.Nummer   # aBAG;
    BAG.AS.Position # aPos;
    BAG.AS.Zusatz   # vName;
    Erx # RecRead(706,2,0);
    if (Erx<=_rMultikey) then begin
      RecRead(706,1,_recLock);
      BAG.AS.Bemerkung  # aint(aStk)+' Stück';
      if (RekReplace(706)<>_rOK) then RETURN false;
    end;

    RETURN true;
  end;


  // NEUANLAGE...
  if (aStk<>0) and (aBag<>0) then begin
//debugx('neu');
    RecBufClear(706);
    BAG.AS.Nummer     # BAG.P.Nummer;
    BAG.AS.Position   # BAG.P.Position;
    BAG.AS.Stichwort  # cAS_Stichwort;
    BAG.AS.Bemerkung  # 'nach S'+aint(aSock)+'; Lfd'+aint(aLfd)+'; '+aint(aStk)+' Stück';
    BAG.AS.Zusatz     # vName;
    _Insert706();

    vName # 'BA'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position);
    RecBufClear(706);
    BAG.AS.Nummer     # aBAG;
    BAG.AS.Position   # aPos;
    BAG.AS.Stichwort  # cAS_Stichwort;
    BAG.AS.Bemerkung  # aint(aStk)+' Stück';
    BAG.AS.Zusatz     # vName;
    _Insert706();
  end;
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub _BildeUnterteilungen(
  aLfd1 : int;
  aBag1 : int;
  aPos1 : int;
  aLfd2 : int;
  aBag2 : int;
  aPos2 : int;
  aTxt  : int) : logic;
local begin
  Erx       : int;
  vA        : alpha;
  vI        : int;
  vS1, vS2  : int;
  vS0       : int;
  vLfd      : int;
  vStk      : int;
  vSock     : int;
  vName     : alpha;
end;
begin

  // BA1234|1|3|4|0
  // BAnr|pos|stka|stkb|stkpool
  FOR vA # TextLineRead(aTxt, 1, _TextLineDelete)
  LOOP vA # TextLineRead(aTxt, 1, _TextLineDelete)
  WHILE (vA<>'') do begin
    vS1             # cnvia(Str_Token(vA,'|',3));
    vS2             # cnvia(Str_Token(vA,'|',4));
    vS0             # cnvia(Str_Token(vA,'|',5));
   
    BAG.P.Nummer    # cnvia(Str_Token(vA,'|',1));
    BAG.P.Position  # cnvia(Str_Token(vA,'|',2));
    Erx # RecRead(702, 1, 0);
    If (Erx<>_rOK) then RETURN false;
    // Arbeitsschritte suchen...
//    if (_SetUT(0, vS0)=false) then RETURN false;
    if (aBag1<>0) then
      if (_SetUT(1, aLfd1, aBag1, aPos1, vS1)=false) then RETURN false;
    if (aBag2<>0) then
      if (_SetUT(2, aLfd2, aBag2, aPos2, vS2)=false) then RETURN false;
  END;
    
  RETURN true;
end;


//========================================================================
//========================================================================
sub SaveGluehen(
  aSock       : int;
  aDL1        : int;
  aDL2        : int;
) : int;
local begin
  Erx   : int;
  vHdl  : int;
  vLfd  : int;
  vBAG  : int;
  vPos  : int;
  vPrg  : int;
  vKon  : int;
  vDat  : date;
  vTim  : time;
  vC1   : int;
  vC2   : int;
  vDau  : int;
  vHalt : int;
  vTemp : int;
 
  vI    : int;
  vID   : int;
  vStk  : int;
  vA    : alpha;
end
begin

  RecBufClear(702);
  //if (GetMode(Winsearch(gMDI, 'gb.Sockel'+aint(aSock)))<>cModeEdit) then RETURN 0;
  if (GetMode()<>cModeEdit) then RETURN 0;

  // Eingaben holen...
  vLfd  # $edLfd->wpCaptionint;
  vPrg  # $edProgramm->wpCaptionint;
  vKon  # $edKonvektor->wpCaptionint;
  vDat  # $edDatum->wpCaptionDate;
  vTim  # $edZeit->wpCaptionTime;
  vC1   # $edC1->wpCaptionint;
  vC2   # $edC2->wpCaptionint;
  vDau  # $edDauer->wpCaptionint;
  vHalt # $edHaltezeit->wpCaptionint;
  vTemp # $edTemp->wpCaptionint;
  
  // neuer Unter-BAG?
  if (vLfd=0) then begin
    // 1. Zeile holen...
    vI # 1;
    ReCbufClear(702);
    if (WinLstDatLineInfo(aDL1, _WinLstDatInfoCount)>=1) then begin
      WinLstCellGet(aDL1, vID    ,cClmRecId  ,vI);
      Erx # RecRead(702, 0,_recId,vID);
      If (Erx<>_rOK) then begin
        TRANSBRK;
        WinLstCellGet(aDL1, vA,    cClmBAG, vI);
        Msg(99,'BA '+vA+' kann nicht verändert werden!',0,0,0);
        RETURN -1;
      end;
    end;
    if (BAG.P.Nummer=0) then begin
      if (WinLstDatLineInfo(aDL2, _WinLstDatInfoCount)>=1) then begin
        WinLstCellGet(aDL2, vID    ,cClmRecId  ,vI);
        Erx # RecRead(702, 0,_recId,vID);
        If (Erx<>_rOK) then begin
          TRANSBRK;
          WinLstCellGet(aDL1, vA,    cClmBAG, vI);
          Msg(99,'BA '+vA+' kann nicht verändert werden!',0,0,0);
          RETURN -1;
        end;
      end;
    end;


    vLfd # _NeuerGluehBag(aSock, vPrg, vDat, vTim, vDau, vKon, vC1, vC2, vHalt, vTemp);
    if (vLfd<=0) then begin
      TRANSBRK;
      Msg(99,'Unter-GlühBA kann nicht erzeugt werden!',0,0,0);
      RETURN -1;
    end;
    
  end
  else begin  // alter Unter-BAG...
  
    RecBufClear(702);
    //BAG.P.Cust.Sort         # 'S'+aint(aSock)+'|NR'+aint(vLfd);

// 16.01.2019
/***
    BAG.P.Cust.Sort         # 'GLPLAN'+aint(vLfd);
    Erx # RecRead(702,11,0);  // Position suchen
    if (Erx>_rMultikey) then begin
      TRANSBRK;
      Msg(99,'Unter-GlühBA kann nicht gefunden werden!',0,0,0);
      RETURN -1;
    end;
end
else
***/
   if (_sucheBAZuLfd(vLfd, aSock)=false) then begin
    TRANSBRK;
    Msg(99,'Unter-GlühBA kann nicht gefunden werden!',0,0,0);
    RETURN -1;
   end;
    
    if (_UpdateGluehBag(Rso.Gruppe, Rso.Nummer, aSock, vLfd, vPrg, vDat, vTim, vDau, vKon, vC1, vC2, vHalt, vTemp)=false) then begin
      TRANSBRK;
      Msg(99,'Unter-GlühBA kann nicht verändert werden!',0,0,0);
      RETURN -1;
    end;
  end;
  
  // Ausgaben zurück...
  $edLfd->wpCaptionint # vLFD;

  RETURN vLfd;
end;


//========================================================================
//========================================================================
sub SaveAll() : logic;
local begin
  Erx     : int;
  vHdl    : int;
  vPlanNr : int;
  vDL     : int;
  vI      : int;
  vID     : int;
  vStk    : int;
  vFolge  : int;
  vA,vB   : alpha;
  vTxt    : int;
  vRTF    : int;
  vCT1    : caltime;
  vCT2    : caltime;
  vLfd1   : int;
  vLfd2   : int;
  vBag1   : int;
  vBag2   : int;
  vPos1   : int;
  vPos2   : int;
  vOK     : logic;
  vDL1, vDL2  : int;
  vBAG    : int;
end;
begin

  vOK # true;
  vHdl # WinSearch($gb.Sockel1,'edDatum');
  if (vHdl->wpCaptionDate=0.0.0) then begin
    Msg(99,'Datum 1 muss ausgefüllt werden!',0,0,0);
    RETURN false;
  end;
  vHdl # WinSearch($gb.Sockel2,'edDatum');
  if (vHdl->wpCaptionDate=0.0.0) then begin
    Msg(99,'Datum 2 muss ausgefüllt werden!',0,0,0);
    RETURN false;
  end;

  vTxt # TextOpen(16);

  // ABHÄNGIGKEITEN PRÜFEN ------------------------------------------------------
  WinSearchPath(gMDI);
//  if (GetMode($gb.Sockel1)=cModeEdit) then begin
  if (WinLstDatLineInfo($DL.Plan1, _WinLstDatInfoCount)>0) then begin
    WinLstCellGet($DL.Plan1, vID    ,cClmRecId  ,1);
    Erx # RecRead(702, 0,_recId,vID);
    if (Erx<=_rLocked) then vBAG # BAG.P.Nummer;

    WinSearchPath($gb.Sockel1);
    vA # cnvad($edDatum->wpCaptionDate)+' '+cnvat($edZeit->wpCaptionTime);
    vCT1->vpDate # $edDatum->wpCaptionDate;
    vCT1->vpTime # $edZeit->wpCaptionTime;
    vCT1->vmSecondsModify(60 * $edDauer->wpCaptionInt);
    vB # cnvad(vCT1->vpDate)+' '+cnvat(vCT1->vpTime);
    if (BA1_Planung_Subs:CheckAbhaenigkeiten(cMDI, cDLPlanName, vTxt, 0 ,0, cClmBAG, vA, vB)=false) then begin
      WinSearchPath(gMDI);
      TextClose(vTxt);
      RETURN false;
    end;
    WinSearchPath(gMDI);
  end;

  WinSearchPath(gMDI);
//  if (GetMode($gb.Sockel2)=cModeEdit) then begin
  if (WinLstDatLineInfo($DL.Plan2, _WinLstDatInfoCount)>0) then begin
    if (vBAG=0) then begin
      WinLstCellGet($DL.Plan2, vID    ,cClmRecId  ,1);
      Erx # RecRead(702, 0,_recId,vID);
      if (Erx<=_rLocked) then vBAG # BAG.P.Nummer;
    end;

    WinSearchPath($gb.Sockel2);
//    vA # cnvad($edDatum->wpCaptionDate)+' '+cnvat($edZeit->wpCaptionTime);
    vHdl # Winsearch($gb.Sockel2,'edDatum');
    vA # cnvad(vHdl->wpCaptionDate);
    vCT1->vpDate # vHdl->wpCaptionDate;
    vHdl # Winsearch($gb.Sockel2,'edZeit');
    vA # vA + ' ' + cnvat(vHdl->wpCaptionTime);
    vCT1->vpTime # vHdl->wpCaptionTime;
    vHdl # Winsearch($gb.Sockel2,'edDauer');
    vCT1->vmSecondsModify(60 * vHdl->wpCaptionInt);
    vB # cnvad(vCT1->vpDate)+' '+cnvat(vCT1->vpTime);

    if (BA1_Planung_Subs:CheckAbhaenigkeiten(cMDI, cDLPlanName, vTxt, 0 ,0, cClmBAG, vA, vB)=false) then begin
      WinSearchPath(gMDI);
      TextClose(vTxt);
      RETURN false;
    end;
    WinSearchPath(gMDI);
  end;

/***
  // KONFLIKTE FINDEN -----------------------------------------------------------
  if (BA1_Planung_Subs:CheckKonflikte(cMDI, cDLPlanName, vTxt, cClmStart, cClmEnde, cClmBAG)=false) then begin
    TextClose(vTxt);
    RETURN false;
  end;
***/
  TextClose(vTxt);


  if (vBAG=0) then begin
    Msg(99,'Es muss mindestens ein BA auch eingefügt werden!',0,0,0);
    RETURN false;
  end;


  // VERBUCHEN ------------------------------------------------------------------
  TRANSON;

  WinSearchPath($gb.Sockel2);
  vDL2 # $DL.Plan2;
  WinSearchPath($gb.Sockel1);
  vDL1 # $DL.Plan1;
  vLfd1 # SaveGluehen(1, vDL1, vDL2);
  if (vLfd1>=0) then begin
    vBag1 # BAG.P.Nummer;
    vPos1 # BAG.P.Position;
    WinSearchPath($gb.Sockel2);
    vLfd2 # SaveGluehen(2, vDL2, vDL1);
    if (vLfd2>=0) then begin
      vBag2 # BAG.P.Nummer;
      vPos2 # BAG.P.Position;
    end;
  end;
  WinSearchPath(gMDI);
  if (vLfd1<0) or (vLfd2<0) then begin
    RETURN false;
  end;

  vTxt # TextOpen(16);
  if (_DLtoTxt(1, $DL.Plan1, vTxt)=false) then begin
    TextClose(vTxt);
    TRANSBRK;
    Msg(99,'Verbuchungsfehler A!',0,0,0);
    RETURN false;
  end;
  if (_DLtoTxt(2, $DL.Plan2, vTxt)=false) then begin
    TextClose(vTxt);
    TRANSBRK;
    Msg(99,'Verbuchungsfehler B!',0,0,0);
    RETURN false;
  end;
  if (_DLtoTxt(0, cDLPool, vTxt)=false) then begin
    TextClose(vTxt);
    TRANSBRK;
    Msg(99,'Verbuchungsfehler C!',0,0,0);
    RETURN false;
  end;
  if (_BildeUnterteilungen(vLfd1, vBag1, vPos1, vLfd2, vBag2, vPos2, vTxt)=false) then begin
    TextClose(vTxt);
    TRANSBRK;
    Msg(99,'Verbuchungsfehler D!',0,0,0);
    RETURN false;
  end;
  TextClose(vTxt);

  TRANSOFF;
//TRANSBRK;


  $bt.Save->wpcustom    # '';    // Änderung vermerken
  $bt.Save->wpColBkg    # _WinColParent;
  $bt.Save->wpDisabled  # true;
  

//  SetMode($gb.Sockel1, cModeStart);
//  SetMode($gb.Sockel2, cModeStart);
  SetMode(cModeStart);

  _AbleDrucken(true);
  Msg(99,'Erfolgreich gespeichert als '+aint(vLfd1)+' und '+aint(vLfd2),0,0,0);
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub _SavenMussSein()
local begin
  vBox  : int;
  vHdl  : int;
end;
begin
  $bt.Save->wpcustom    # 'change';    // Änderung vermerken
  $bt.Save->wpColBkg    # _WinColLightRed;
  $bt.Save->wpDisabled  # false;
  _AbleDrucken(false);
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
sub RefreshFilter()
local begin
  vI    : int;
  vA    : alpha;
  vOK   : logic;
end;
begin

  WinLayer(_WinLayerStart, gFrmMain, 20000, 'Filterung...', _WinLayerDarken);
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
  WinLayer(_WinLayerEnd);

end;


//========================================================================
// _FindRow
//    sucht die RecID in der DL
//========================================================================
sub _FindRow(
  aDL : int;
  aID : int;
  var aRow  : int) : logic
local begin
  vI  : int;
  vID : int;
end;
begin

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(aDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(aDL, vID , cClmRecId, vI);
    if (vID=aID) then begin
      aRow # vI;
      RETURN true;
    end;
  END;

  RETURN false;
end;


//========================================================================
//========================================================================
sub _MyMove(
  aGew      : int;
  aStk      : int;
  aDL1      : int;
  aVon      : int;
  aDL2      : int;
  aNach     : int;
  aCopy     : logic;
) : logic   // ergab neue Zeile?
local begin
  vID   : int;
  vStk  : int;
  vGew  : int;
end;
begin
  WinLstCellGet(aDL1, vID   ,cClmRecId, aVon);

  if (_FindRow(aDL2, vID, var aNach)) then begin
    // Target ändern
    WinLstCellGet(aDL2, vStk      ,cClmStk, aNach);
    WinLstCellGet(aDL2, vGew      ,cClmGew, aNach);
//debugx('mod Z'+aint(aNach)+' auf '+aint(aStk+vStk));
    WinLstCellSet(aDL2, aStk+vStk ,cClmStk, aNach);
    WinLstCellSet(aDL2, aGew+vGew ,cClmGew, aNach);
    if (aCopy=false) then
      aDL1->WinLstDatLineRemove(aVon);
    RETURN false;
  end;
  
  Lib_DataList:Move(aDL1, aVon, aDL2, aNach, aCopy);

  if (aCopy) then begin
    if (aNach=0) then
      aNach # _WinLstDatLineLast;
//debugx('mod Z'+aint(aNach)+' auf '+aint(aStk));
    // Target ändern
    WinLstCellSet(aDL2, aStk      ,cClmStk, aNach);
    WinLstCellSet(aDL2, aGew      ,cClmGew, aNach);
  end;

  RETURN true;
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit (
  aEvt      : event;
): logic
local begin
  vPar    : int;
  vDL     : int;
  vUeber  : int;
  vSum    : int;
  vHdl2   : int;
  vHdl    : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle        # Translate( cTitle );
  gMenuName     # cMenuName;
  gMenuEvtProc  # here+':EvtMenuCommand';
  Mode          # c_modeEdList;

  vHdl2 # Winsearch(aEvt:Obj, cDlPlanname+'1');
  Lib_GuiCom:RecallList(vHdl2, cTitle);
  Lib_GuiCom:RecallList(cDLPool, cTitle);     // Usersettings holen
  Lib_GuiCom:RecallList(vHdl2, cTitle);
  Lib_GuiCom:RecallList(cDLPool, cTitle);     // Usersettings holen

  vHdl # Winsearch(aEvt:Obj, 'gb.Sockel1');
  vHdl->wpCaption # Rso.Stichwort+', Sockel 1';
  vHdl # Winsearch(aEvt:obj, 'gb.Sockel2');
  vHdl->wpCaption # Rso.Stichwort+', Sockel 2';
 
  // COPY oben nach unten...
  vPar # WinSearch(aEvt:Obj, 'gb.Sockel2');
  
  vDL # Winsearch(aEvt:obj, 'dl.Plan1');
  vHdl2 # Lib_GuiDynamisch:CopyObject(vDL, '', vPar, true);
  vHdl2->wpname # 'dl.Plan2';

  vUeber # Winsearch(aEvt:obj, 'Uebertrag1');
  vHdl2 # Lib_GuiDynamisch:CopyObject(vUeber, '', vPar, true);
  vHdl2->wpname # 'Uebertrag2';

  vSum # Winsearch(aEvt:obj, 'Sums1');
  vHdl2 # Lib_GuiDynamisch:CopyObject(vSum, '', vPar, true);
  vHdl2->wpname # 'Sums2';

//  vSum->wpname    # vSum->wpname + 'A';
//  vDL->wpname     # vDL->wpname + 'A';
//  vUeber->wpname  # vUeber->wpname + 'A';
  
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
  vStk    : int;
  vGew    : int;
  vB      : float;

  vHdl    : int;
  vItem   : int;
  vNr     : int;
end;
begin

  if (Msg(99,'Sollen der markierten Eintrag wieder in den Pool gesetzt werden?',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;

  WinLstCellGet(aDLPlan, vID  , cClmRecId, aDLPlan->wpCurrentint);
  WinLstCellGet(aDLPlan, vStk , cClmStk, aDLPlan->wpCurrentint);
  WinLstCellGet(aDLPlan, vGew , cClmGew, aDLPlan->wpCurrentint);
  WinLstCellGet(aDLPlan, vB   , cClmInputB, aDLPlan->wpCurrentint);

  _AddSum(cnvia(aDlPlan->wpName), -vStk, vB * cnvfi(-vStk), -vGew);
    
  _MyMove(vGew, vStk, aDLPlan, aDLPlan->wpcurrentInt, aDLPool, 0, false);

  _SavenMussSein();

  aDLPlan->WinUpdate( _winUpdOn, _winLstPosTop );
end;


//========================================================================
//========================================================================
sub EvtFocusTerm(
  aEvt                  : event;        // Ereignis
  aFocusObject          : handle;       // Objekt, das den Fokus bekommt
) : logic;
begin
  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vBox  : int;
  vI    : int;
end;
begin
  vBox # Wininfo(aEvt:obj, _WinParent); // ÜbertragGruppe
  vBox # Wininfo(vBox, _WinParent);     // GroupBox
  
  if (aEvt:Obj->wpname='edLfd') then begin
//    SetMode(vBox, cModeLfd);
    SetMode(cModeLfd);
  end;

  if (aEvt:Obj->wpname='edKonvektor') then begin
    vI # cnvia(aEvt:Obj->wpStatusItemText);
    vI # aEvt:Obj->wpCaptionInt - vI;
    aEvt:Obj->wpStatusItemText # cnvai(aEvt:Obj->wpCaptionInt);
    if (vI<>0) then begin
      _AddSum(cnvia(vBox->wpname), 0, cnvfi(vI)*cKonvektorbreite, 0);
    end;
  end;


  if (aEvt:Obj->wpname='edDatum') or
    (aEvt:Obj->wpname='edZeit') or
    (aEvt:Obj->wpname='edDauer') or
    (aEvt:Obj->wpname='edProgramm') or
    (aEvt:Obj->wpname='edC1') or
    (aEvt:Obj->wpname='edC2') or
    (aEvt:Obj->wpname='edHaltezeit') or
    (aEvt:Obj->wpname='edKonvektor') or
    (aEvt:Obj->wpname='edTemp')
    then begin
    //if (GetMode(vBox)=cModeStart) then
//      SetMode(vBox, cModeEdit);
    if (GetMode()=cModeStart) then
      SetMode(cModeEdit);

     _SavenMussSein();
  end;

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
  Erx   : int;
  vHdl  : int;
  vID   : int;
end;
begin

  if (aMenuItem->wpName='Mnu.ZumBA') then begin
    vHdl # WinfocusGet();
    if (vHdl<>0) then begin
      if (Wininfo(vHdl, _wintype)=_WinTypeDataList) then begin
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
  vA    : alpha;
  vHdl  : int;
end;
begin
  Lib_DataList:EvtLstDatainit(aEvt, aID);
  
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
  vHdl2       : int;
  vI          : int;
  vAnz        : int;
  v703        : int;
end;
begin

  if ($bt.Save->wpcustom<>'') then begin
    if (Msg(99,'Alle Änderungen verwerfen?',_WinIcoQuestion,_WinDialogOkCancel,2) <> _Winidok) then RETURN false;
  end;

  vHDl # Winsearch(cMDI, cDlPlanname+'1');
  Lib_GuiCom:RememberList(vHdl, cTitle);
  Lib_GuiCom:RememberList(cDLPool, cTitle);
  Lib_GuiCom:RememberWindow(aEvt:obj);

  RETURN true;
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked (
  aEvt            : event
) : logic
local begin
  vBox  : int;
  vDat  : date;
  vHdl  : int;
  vNr   : int;
  vEvt  : event;
end;
begin

  case ( aEvt:obj->wpName ) of
  
    'btDruck' : begin
      vBox  # Wininfo(aEvt:obj, _WinParent);
      vBox  # Wininfo(vBox, _WinParent);   // GroupBox
      vNr   # Winsearch(vBox, 'edLfd');
      vNr   # vNr->wpCaptionint;
      Druck(vNR, cnvia(vBox->wpName));
    end;
    'btDruck1' : begin
      vBox  # Wininfo(aEvt:obj, _WinParent);
      vBox  # Wininfo(vBox, _WinParent);   // GroupBox
      vNr # cnvia(vBox->wpname);
      vHdl  # Winsearch(gMDI, cDLPlanName+aint(vNr));
      BA1_Planung_Subs:Druck1(vHdl);
    end;
    'btDruckAlle' : begin
      vBox  # Wininfo(aEvt:obj, _WinParent);
      vBox  # Wininfo(vBox, _WinParent);   // GroupBox
      vNr # cnvia(vBox->wpname);
      vHdl  # Winsearch(gMDI, cDLPlanName+aint(vNr));
      BA1_Planung_Subs:DruckAll(vHdl);
    end;
  
  
    'btReset' : begin
      vBox # Winsearch(gMDI,'gb.Sockel1');
      vHdl # Winsearch(vBox, 'edLfd');
      vHdl->wpCaptionint # 0;
      LoadLfd(vBox, 0, 0);
      
      vBox # Winsearch(gMDI,'gb.Sockel2');
      vHdl # Winsearch(vBox, 'edLfd');
      vHdl->wpCaptionint # 0;
      LoadLfd(vBox, 0, 0);
      //SetMode(vBox, cModeStart);
      SetMode(cModeStart);
    end;
  
    'bt.Save' : begin
      SaveAll();
    end;

    'btLoad' : begin
      vBox # Wininfo(aEvt:obj, _WinParent);
      vBox # Wininfo(vBox, _WinParent);   // GroupBox
      //if (GetMode(vBox)=cModeLfd) then begin
      if (GetMode()=cModeLfd) then begin
        vHdl # Winsearch(vBox, 'edLfd');
        vNr # vHdl->wpCaptionint;
        if (LoadLfd(vBox, vNr, cnvia(vBox->wpname))=false) then begin
          vEvt:Obj # $btReset;
          EvtClicked(vEvt);
          RETURN true;
        end;
        
        if (vBox->wpname='gb.Sockel1') then begin
          vHdl # Winsearch($gb.Sockel2, 'edLfd');
          vHdl->wpCaptionint # vNr + 1;
          LoadLfd($gb.Sockel2, vHdl->wpCaptionint, 2);
        end
        else begin
          vHdl # Winsearch($gb.Sockel1, 'edLfd');
          vHdl->wpCaptionint # vNr - 1;
          LoadLfd($gb.Sockel1, vHdl->wpCaptionint, 1);
        end;
        //SetMode(vBox, cModeStart);
        SetMode(cModeStart);

      end;
    end;
    
    'bt.RefreshFilter' :
      RefreshFilter();
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
//if (aHittest=_WinHitLstHeader) then
//debugx(aint(aHittest));
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
  vRunter     : logic;
  vPre,vPost  : int;
  vAnz        : int;
  vDL1, vDL2  : int;
  vGew        : int;
  vStk        : int;
  vSubStk     : int;
  vB          : float;
  vOK         : logic;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataUser)<>true) then RETURN false;
  
  if (aDataObject->wpname<>cModulname) then RETURN false;

  vDL1 # cnvia(aDataObject->wpcustom);
  vDL2 # aEvt:Obj;
  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
  vData # aDataObject->wpData(_WinDropDataUser);
  vData # vData->wpData;
  if (vData=0) then RETURN false;

  vLine   # aDataPlace->wpArgInt(0);
  vPlace  # aDataPlace->wpDropPlace;

  // Einfügeposition.
  case vPlace of
    _WinDropPlaceAppend   : begin
    inc(vLine);//vA # 'NACH';//  inc(vLine);
    end;
  end;


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

    WinLstCellGet(vDL1, vGew  ,cClmGewEin, vVon);
    WinLstCellGet(vDL1, vB    ,cClmInputB, vVon);
    WinLstCellGet(vDL1, vStk  ,cClmStk, vVon);
    vSubStk # vStk;

//debugx(aint(vVon)+' nach '+aint(vNach));
    if (vDL1<>vDL2) and (vStk>1) then begin
      REPEAT
        vOK # Dlg_Standard:Anzahl('Anzahl',var vSubStk, vStk);
      UNTIL (vOK=false) or ((vSubStk<=vStk) and (vStk>=1))
      if (vOK=false) then CYCLE;
    end;

    // Teilen?
    if (vStk<>vSubStk) then begin
//      Lib_DataList:Move(vDL1, vVon, vDL2, vNach, true);
      if (_MyMove(vGew * vSubStk, vSubStk, vDL1, vVon, vDL2, vNach, true)) then begin
        // Target ändern
//debugx('mod Z'+aint(vNach)+' auf '+aint(vSubStk));
        WinLstCellSet(vDL2, vSubStk       ,cClmStk, vNach);// + 1);
        WinLstCellSet(vDL2, vSubStk*vGew  ,cClmGew, vNach);
      end;
      // Source ändern
      WinLstCellSet(vDL1, vStk-vSubStk        ,cClmStk, vVon);
      WinLstCellSet(vDL1, (vStk-vSubStk)*vGew ,cClmGew, vVon);
    end
    else begin
//      Lib_DataList:Move(vDL1, vVon, vDL2, vNach);
      _MyMove(vGew * vStk, vStk, vDL1, vVon, vDL2, vNach, false);
    end;
    
    
    if (vDL1=vDL2) then begin
      if (vRunter) then
        inc(vPre)
      else
        inc(vPost);
    end
    else begin    // Pool <-> Plan
      inc(vPre);
      if (vDL1=cDlPool) then
        _AddSum(cnvia(vDL2->wpname), vSubStk, vB * cnvfi(vSubStk), vGew * vSubStk)
      else if (vDL2=cDlPool) then
        _AddSum(cnvia(vDL1->wpname), -vSubStk, vB * cnvfi(-vSubStk), vGew * (-vSubStk))
      else begin  // Plan <-> Plan
        _AddSum(cnvia(vDL1->wpname), -vSubStk, vB * cnvfi(-vSubStk), vGew * (-vSubStk));
        _AddSum(cnvia(vDL2->wpname), vSubStk, vB * cnvfi(vSubStk), vGew * vSubStk);
      end;
    end;

  END;

  if (vDL1<>cDLPool) then begin
    //SetMode(Wininfo(vDL1, _WinParent), cModeEdit);
    SetMode(cModeEdit);
    _SavenMussSein();
  end;
  if (vDL2<>cDLPool) then begin
    //SetMode(Wininfo(vDL2, _WinParent), cModeEdit);
    SetMode(cModeEdit);
    _SavenMussSein();
  end;
  

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
//========================================================================
//========================================================================