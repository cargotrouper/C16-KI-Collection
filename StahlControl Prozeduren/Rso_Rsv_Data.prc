@A+
//===== Business-Control =================================================
//
//  Prozedur  Rso_Rsv_Data
//                          OHNE E_R_G
//  Info      Von Vorgänger betrachtet:   MINSTART - MinEnde
//            von Nachfolger betrachtet:  MaxStart - MAXENDE
//
//            StartVererben: 	LOOP Parent->RecalcMaxEnde (sucht MIN child)
//            EndeVererben: 	LOOP Child->RecalcMinStart (sucht MAX parent)
//
//            > von Parent (MinDat)
//            < von Child (MaxDat)
//
//            Vorgabe von Parent:
//                 >_____>_____>_____>    Min
//            OK:
//                    <-----<-----<-----< Max
//                 <-----<-----<-----<    Max
//            FAIL:
//               <-----<-----<-----<
//
//  Maske zeigt an : Start  Rso.R.MinDat.Start - Rso.R.MaxDat.Start
//                   Ende   Rso.R.MinDat.Ende  - Rso.R.MaxDat.Ende
//
//
//  09.02.2015  AH  Erstellung der Prozedur
//  10.07.2017  AH  Refactoring
//  10.11.2017  AH  Umbau für VSB-Datum in Vorgänger
//  27.11.2017  AH  Buffix
//  07.06.2018  AH  + DauerPost
//  13.06.2018  AH  Fix
//  18.12.2018  AH  Fix für Min/Max-Fenster
//  13.02.2019  AH  Fix: Endtermin nur errechnen, wenn leer oder Dauer gefüllt
//  19.03.2019  AH  "RepairBAG"
//  10.12.2019  AH  Es werden auch VSB-BAs terminlich upgedated
//  01.04.2021  AH  Neu: Setting "Set.BA.OhneRsoPlanYN" zum Abschalten
//  04.02.2022  AH  ERX
//
//
//  04.02.2022 AH ALT(WARNUNG : Prozeduren ändern ERG !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)
//
//
//  Subprozeduren
//  sub Insert702() : int;
//  sub Update702(a702Alt : int) : int;
//  sub Delete702(opt aNr   : int; opt aPos  : int) : int;
//
//  sub Insert701() : int;
//  sub Update701(opt a701Alt : int) : int;
//  sub Delete701(opt aVon : int; opt aNach : int) : int;
//
//  sub RepairBAG()
//
//========================================================================
@I:Def_Global
@I:Def_BAG

define begin
  cDeaktiviert  : Set.BA.OhneRsoPlanYN
  cMinDauer     : 60
  dt(a,b) : cnvad(a)+' '+cnvat(b)
  
  cDebugTraeger : aint("Rso.R.Trägernummer1")+'/'+aint("Rso.R.Trägernummer2")
end;

declare UpdateTraeger(opt aZusatz : alpha) : logic;
declare VererbeEndeNachHinten();
declare VererbeStartNachVorne();
declare FindMaxEnde();
declare FindMinStart();
declare _702GehtNachVSB(aBA : int; aPos : int) : logic;

//========================================================================
// in Minuten
//========================================================================
sub GetTS(
  aDat  : date;
  aTim  : time) : int;
local begin
  vI    : int;
end;
begin
  if (aDat<1.1.1900) then RETURN 0;
  vI # cnvid(aDat); // 1.1.1900 = Tag 1
  RETURN (vI * 24 * 60) + (cnvit(aTim) / 60000);
end;


//========================================================================
// in Minuten
//========================================================================
sub SetTS(
  aI        : int;
  var aDat  : date;
  var aTim  : time);
local begin
  vI    : int;
end;
begin
//  if (aDat>1.1.1900) then begin
  if (aI>0) then begin
    aDat  # cnvdi(aI div (24 * 60));
    vI    # aI % (24 * 60);
    aTim  # cnvti(vI * 60000);
  end;
end;



//========================================================================
//========================================================================
sub _SchiebeVonBisInKalender(
  aGrp      : int;
  var aDat1 : date;
  var aTim1 : time;
  aDauer    : int;
  var aDat2 : date;
  var aTim2 : time;
  aRichtung : alpha;
);
begin

  if (aRichtung='>') or
    ((aRichtung='') and (aDat1<>0.0.0)) then begin
    if (aDauer=0) then begin  // 18.12.2018
      aDat2 # aDat1;
      aTim2 # aTim1;
      RETURN;
    end;
    Rso_Kal_Data:PasstRechtsInKalender(aGrp, var aDat1, var aTim1, var aDauer, var aDat2, var aTim2);
  end
  else if (aRichtung='<') or
    ((aRichtung='') and (aDat2<>0.0.0)) then begin
    if (aDauer=0) then begin  // 18.12.2018
      aDat1 # aDat2;
      aTim1 # aTim2;
      RETURN;
    end;
    Rso_Kal_Data:PasstLinksInKalender(aGrp, var aDat1, var aTim1, var aDauer, var aDat2, var aTim2);
  end;

  if (aDat1<>0.0.0) and (aTim1=24:00) then begin
    aDat1->vmDayModify(1);
    aTim1 # 00:00;
  end;
  if (aDat2<>0.0.0) and (aTim2=24:00) then begin
    aDat2->vmDayModify(1);
    aTim2 # 00:00;
  end;

end;


//========================================================================
//========================================================================
sub _SchiebeInAZ(
  aGrp      : int;
  var aDat  : date;
  var aTim  : time;
  aRichtung : alpha;
)
local begin
  vDat    : date;
  vTim    : time;
  vDauer  : int;
  vCT     : caltime;
end;
begin
  vDauer # 1;
  vDat # aDat;
  vTim # aTim;

  if (aRichtung='>') then begin
  // Start + Dauer, => Ende
    Rso_Kal_Data:PasstRechtsInKalender(aGrp, var aDat, var aTim, var vDauer, var vDat, var vTim);
/**
    vCT->vpdate # aDat;
    vCT->vptime # aTim;
    vCT->vmSecondsModify(-60);
    aDat # vCT->vpdate;
    aTim # vCT->vptime;
***/
  end
  else begin
    Rso_Kal_Data:PasstLinksInKalender(aGrp, var vDat, var vTim, var vDauer, var aDat, var aTim);
/***
    vCT->vpdate # aDat;
    vCT->vptime # aTim;
    vCT->vmSecondsModify(60);
    aDat # vCT->vpdate;
    aTim # vCT->vptime;
**/
  end;
end;


//========================================================================
//========================================================================
sub _CalcPlanFenster();
begin

  if (Rso.R.Plan.EndDat<>0.0.0) and (Rso.R.Dauer=0) then RETURN;               // 13.02.2019

//  vDauer    # Rso.R.Dauer;
//  if (Rso.R.Plan.StartDat<>0.0.0) then
//    Rso_Kal_Data:GetPlantermin(Rso.R.Ressource.Grp, var vStartDat, var vStartTim, Rso.R.Dauer, var Rso.R.Plan.EndDat, var Rso.R.Plan.EndZeit)
//    Rso_Kal_Data:PasstRechtsInKalender(Rso.R.Ressource.Grp, var vStartDat, var vStartTim, var vDauer, var Rso.R.Plan.EndDat, var Rso.R.Plan.EndZeit)
//    Rso_Kal_Data:PasstRechtsInKalender(Rso.R.Ressource.Grp, var Rso.R.Plan.StartDat, var Rso.R.PLan.StartZEit, var vDauer, var Rso.R.Plan.EndDat, var Rso.R.Plan.EndZeit)
//  else if (Rso.R.Plan.EndDat<>0.0.0) then
//    Rso_Kal_Data:GetPlantermin(Rso.R.Ressource.Grp, var Rso.R.Plan.StartDat, var Rso.R.Plan.StartZeit, -Rso.R.Dauer, var vEndDat, var vEndTim);
//    Rso_Kal_Data:PasstLinksInKalender(Rso.R.Ressource.Grp, var Rso.R.Plan.StartDat, var Rso.R.Plan.StartZeit, var vDauer, var vEndDat, var vEndTim);
//    Rso_Kal_Data:PasstLinksInKalender(Rso.R.Ressource.Grp, var Rso.R.Plan.StartDat, var Rso.R.PLan.StartZEit, var vDauer, var Rso.R.Plan.EndDat, var Rso.R.Plan.EndZeit)
  _SchiebeVonBisInKalender(Rso.R.Ressource.Grp, var Rso.R.Plan.StartDat, var Rso.R.PLan.StartZeit, Rso.R.Dauer, var Rso.R.Plan.EndDat, var Rso.R.Plan.EndZeit, '');
end;

//========================================================================
sub _CalcMinEnde();
local begin
  vDat  : date;
  vTim  : time;
end;
begin
  vDat # Rso.R.MinDat.Start;
  vTim # Rso.R.MinZeit.Start;
//  _CalcVonBis(Rso.R.Ressource.Grp, var Rso.R.MinDat.Start, var Rso.R.MinZeit.Start, Rso.R.Dauer, var Rso.R.MinDat.Ende, var Rso.R.MinZeit.Ende, '>');
//  _CalcVonBis(Rso.R.Ressource.Grp, var Rso.R.MinDat.Start, var Rso.R.MinZeit.Start, 1, var Rso.R.MinDat.Ende, var Rso.R.MinZeit.Ende, '>');
//debug(DT(vDat,vTim)+' nach MinEnde');
  _SchiebeVonBisInKalender(Rso.R.Ressource.Grp, var vDat, var vTim, Rso.R.Dauer, var Rso.R.MinDat.Ende, var Rso.R.MinZeit.Ende, '>');
//debug('bekomme '+dt(Rso.R.MinDat.Ende, Rso.R.MinZeit.Ende));
end;

//========================================================================
sub _CalcMaxStart();
local begin
  vDat  : date;
  vTim  : time;
end;
begin
  vDat # Rso.R.MaxDat.Ende;
  vTim # Rso.R.MaxZeit.Ende;
//  _CalcVonBis(Rso.R.Ressource.Grp, var Rso.R.MaxDat.Start, var Rso.R.MaxZeit.Start, Rso.R.Dauer, var Rso.R.MaxDat.Ende, var Rso.R.MaxZeit.Ende, '<');
  _SchiebeVonBisInKalender(Rso.R.Ressource.Grp, var Rso.R.MaxDat.Start, var Rso.R.MaxZeit.Start, Rso.R.Dauer, var vDat, var vTim, '<');
//  _CalcVonBis(Rso.R.Ressource.Grp, var Rso.R.MaxDat.Start, var Rso.R.MaxZeit.Start, 1, var Rso.R.MaxDat.Ende, var Rso.R.MaxZeit.Ende, '<');
end;

//========================================================================
//========================================================================
sub Replace(
  aLock         : int;
  aGrund        : alpha;
  opt aRichtung : alpha;
  opt aZusatz   : alpha;
) : int;
local begin
  Erx       : int;
  v170      : int;    // alter Inhalt
  vEndeMod  : logic;
  vStartMod : logic;
end;
begin

//debug(cnvad(Rso.R.Plan.StartDat)+':'+cnvat(Rso.R.Plan.StartZeit)+' '+cnvad(Rso.R.Plan.EndDat)+':'+cnvat(Rso.R.Plan.EndZeit));
if (Rso.R.MaxDat.Ende<>0.0.0) then begin //and (Rso.R.MaxDat.Start=0.0.0) then begin
//debug('bestimme StartMax aus MaxEnde');
//Rso.R.MaxDat.Start  # Rso.R.maxDat.Ende;
//Rso.R.MaxZeit.Start # Rso.R.maxZeit.Ende;
//Lib_Berechnungen:TermInModify(var Rso.R.MaxDat.Start, var Rso.R.MaxZeit.Start, cnvfi(-Rso.R.Dauer))
_CalcMaxStart();
end;
if (Rso.R.MinDat.Start<>0.0.0) then begin//and (Rso.R.MinDat.Ende=0.0.0) then begin
//debug('bestimme EndeMin aus MinStart');
//Rso.R.MInDat.Ende  # Rso.R.MinDat.Start;
//Rso.R.MInZeit.Ende # Rso.R.MinZeit.Start;
//Lib_Berechnungen:TermInModify(var Rso.R.MinDat.Ende, var Rso.R.MinZeit.Ende, cnvfi(Rso.R.Dauer))
_CalcMinEnde();
end;

// Rso.R.MinDat.Start - Rso.R.MaxDat.Start
// Rso.R.MinDat.Ende  - Rso.R.MaxDat.Ende


  if (aRichtung='') then begin
    _CalcPlanFenster();
  end;

//debug(cnvad(Rso.R.Plan.StartDat)+':'+cnvat(Rso.R.Plan.StartZeit)+' '+cnvad(Rso.R.Plan.EndDat)+':'+cnvat(Rso.R.Plan.EndZeit));

  // alten Inhalt holen
  v170 # RecBufCreate(170);
  RecRead(v170, 0, _recId, RecInfo(170,_recID));
  Erx # RekReplace(170, aLock, aGrund);
  if (Erx<>_rok) then begin
    RecBufDestroy(v170);
    RETURN Erx;
  end;

  UpdateTraeger(aZusatz);

//debug('MinStart '+cnvat(v170Alt->Rso.R.MinZeit.Start)+' wird '+cnvat(Rso.R.MinZeit.Start));
//debug('MaxEnd '+cnvat(v170Alt->Rso.R.MaxZeit.Ende)+' wird '+cnvat(Rso.R.MaxZeit.Ende));
/***
  vEndeMod  # (v170->Rso.R.Plan.EndDat <> Rso.R.Plan.EndDat) or
              (v170->Rso.R.Plan.EndZeit <> Rso.R.Plan.EndZeit) or
              (v170->Rso.R.MaxDat.Ende <> Rso.R.MaxDat.Ende) or
              (v170->Rso.R.MaxZeit.Ende <> Rso.R.MaxZeit.Ende);

  vStartMod # (v170->Rso.R.Plan.StartDat <> Rso.R.Plan.StartDat) or
              (v170->Rso.R.Plan.StartZeit <> Rso.R.Plan.StartZeit) or
              (v170->Rso.R.MinDat.Start <> Rso.R.MinDat.Start) or
              (v170->Rso.R.MinZeit.Start <> Rso.R.MinZeit.Start);
***/
// über KREUZ???
  vEndeMod  # (v170->Rso.R.Plan.EndDat <> Rso.R.Plan.EndDat) or
              (v170->Rso.R.Plan.EndZeit <> Rso.R.Plan.EndZeit) or
              (v170->Rso.R.MinDat.Ende <> Rso.R.MinDat.Ende) or
              (v170->Rso.R.MinZeit.Ende <> Rso.R.MinZeit.Ende) or
              (v170->Rso.R.MinDat.Start <> Rso.R.MinDat.Start) or
              (v170->Rso.R.MinZeit.Start <> Rso.R.MinZeit.Start);

  vStartMod # (v170->Rso.R.Plan.StartDat <> Rso.R.Plan.StartDat) or
              (v170->Rso.R.Plan.StartZeit <> Rso.R.Plan.StartZeit) or
              (v170->Rso.R.MaxDat.Start <> Rso.R.MaxDat.Start) or
              (v170->Rso.R.MaxZeit.Start <> Rso.R.MaxZeit.Start) or
              (v170->Rso.R.MaxDat.Ende <> Rso.R.MaxDat.Ende) or
              (v170->Rso.R.MaxZeit.Ende <> Rso.R.MaxZeit.Ende);

  // 14.06.2018 AH: Änderungen von Dauer/DauerPost betreffen VORGÄNGER
  if (v170->Rso.R.DauerPost <> Rso.R.DauerPost) or
     (v170->Rso.R.Dauer <> Rso.R.Dauer) then vStartMod # y;
  RecBufDestroy(v170);

  if (vEndeMod) and (aRichtung<>'<') then begin
//debugx('>>>');
    VererbeEndeNachHinten();
  end;

  if (vStartMod) and (aRichtung<>'>') then begin
//debugx('<<<');
    VererbeStartNachVorne();
  end;


  RETURN _rOK;
end;




//========================================================================
//  GetTraegerNummern
//      füllt die Nummernparameter
//========================================================================
sub GetTraegerNummern(
  aTyp      : alpha;
  var aNr1  : int;
  var aNr2  : int;
  var aNr3  : int) : logic;
begin
  if (aTyp='BAG') then begin
    aNr1 # BAG.P.Nummer;
    aNr2 # BAG.P.Position;
    RETURN true;
  end
//  if (aTyp='WART') then begin
//    vNr1 # Rso.IHA.Nummer;
//    vNr2 # Rso.IHA.Gruppe;
//    vNr3 # Rso.IHA.Ressource;
//    RETURN true;
//  end

  RETURN false;
end;


//========================================================================
//========================================================================
sub Delete171() : int;
local begin
  Erx   : int;
  v170  : int;
end;
begin

  Erx # RekDelete(171);

  if (Erx=_rOK) then begin
    v170 # RekSave(170);
    Erx # RecLink(170,171,1,_Recfirst); // Vorgänger holen
    if (Erx<=_rLocked) then begin
      FindMaxEnde();
      VererbeEndeNachHinten();
    end;
    Erx # RecLink(170,171,2,_Recfirst); // Nachfolger holen
    if (Erx<=_rLocked) then begin
      FindMinStart();
      VererbeStartNachVorne();
    end;
    RekRestore(v170);
    Erx # _rOK;
  end;

  RETURN Erx;
end;


//========================================================================
// Delete170
//
//========================================================================
sub Delete170() : int;
local begin
  Erx   : int;
  v170  : int;
end;
begin

  TRANSON;

  Erx # RekDelete(170);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN Erx;
  end;

  // mich als Vorgänger löschen...
  // d.h. Nachfolger loopen
  WHILE (RecLink(171,170,3,_RecFirst)<=_rLocked) do begin
    Erx # Delete171();
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RETURN Erx;
    end;

    v170 # RekSave(170);
    Erx # RecLink(170,171,2,_Recfirst); // Nachfolger holen
    if (Erx<=_rLocked) then
      VererbeStartNachVorne();
    RekRestore(v170);

  END;

  // mich als Nachfolger löschen...
  // d.h. Vorgänger loopen
  WHILE (RecLink(171,170,2,_RecFirst)<=_rLocked) do begin
    Erx # Delete171();
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RETURN Erx;
    end;

    v170 # RekSave(170);
    Erx # RecLink(170,171,1,_Recfirst); // Vorgänger holen
    if (Erx<=_rLocked) then
      VererbeEndeNachHinten();
    RekRestore(v170);

  END;

  TRANSOFF;

  RETURN _rOK;
end;


//========================================================================
// Read
//
//========================================================================
sub Read(
  aTyp        : alpha;
  opt aNr1    : int;
  opt aNr2    : int;
  opt aNr3    : int;
) : int;
local begin
  vNr1    : int;
  vNr2    : int;
  vNr3    : int;
  vErg    : int;
end;
begin

  if (aNr1<>0) then begin
    aTyp  # aTyp;
    vNr1  # aNr1;
    vNr2  # aNr2;
    vNr3  # aNr3;
  end
  else begin
    if (GetTraegerNummern(aTyp, var vNr1, var vNr2, var vNr3)=false) then RETURN -2;
  end;

  RecBufClear(170);
  "Rso.R.Trägertyp"     # aTyp;
  "Rso.R.TrägerNummer1" # vNr1;
  "Rso.R.TrägerNummer2" # vNr2;
  "Rso.R.TrägerNummer3" # vNr3;
//debugx('Suche: '+aTyp+'/'+aint(vNr1)+'/'+aint(vNr2)+'/'+aint(vNr3));
  vErg # RecRead(170,3,0);
//debugx(aint(vERG));
  // bisher unbkeannt?
  if (vErg>_rMultikey) then RETURN -1;

  RETURN Rso.R.Reservierungnr;
end;


//========================================================================
// Verbinde
//
//========================================================================
sub Verbinde(
  aVon  : int;
  aNach : int;
) : int;
begin

  RecBufClear(171);
  "Rso.R.V.Vorgänger" # aVon
  Rso.R.V.Nachfolger  # aNach;
  RETURN Rekinsert(171);
end;


//========================================================================
//  UpdateTraeger
//
//========================================================================
sub UpdateTraeger(opt aZusatz : alpha) : logic;
local begin
  Erx   : int;
  vNeu  : logic;
  vBuf  : int;
  vVorherDauer  : float;
  vVorherDat    : date;
end;
begin

  if ("Rso.R.Trägertyp"='BAG') then begin
//    if (RecLinkInfo(171,170,3,_RecCount)>0) then begin  //  Abhänigkeiten??
if (1=1) then begin // 21.11.2017 WARUM wie oben???
      vBuf # RekSave(702);
      BAG.P.Nummer    # "Rso.R.Trägernummer1";
      BAG.P.Position  # "Rso.R.Trägernummer2";
      Erx # RecRead(702,1,_recLock);
      if (Erx<>_rOK) then begin
        RekRestore(vBuf);
        RETURN false;
      end;

      // Daten syncen...
      BAG.P.Ressource.Grp   # Rso.R.Ressource.Grp;
      BAG.P.Ressource       # Rso.R.Ressource.Nr;
vVorherDauer  # BAG.P.Plan.Dauer;
vVorherDat    # BAG.P.Plan.StartDat;
      BAG.P.Plan.Dauer      # cnvfi(Rso.R.Dauer);
      BAG.P.Plan.DauerPost  # cnvfi(Rso.R.DauerPost);
      BAG.P.Fenster.MinDat  # Rso.R.MinDat.Start
      BAG.P.Fenster.MinZei  # Rso.R.MinZeit.Start;
//debugx('Rsv -> 702   min'+cnvat(Rso.R.MinZeit.Ende));
      BAG.P.Fenster.MaxDat  # Rso.R.MaxDat.Ende;
      BAG.P.Fenster.MaxZei  # Rso.R.MaxZeit.Ende;

      BAG.P.Plan.StartDat   # Rso.R.Plan.StartDat;
//if (Set.Installname='BSP') then
//Lib_Debug:Protokoll('!BSP_Log_Komisch', 'Set BA-Termin '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : '+cnvad(BAG.P.Plan.StartDat)+'   ['+__PROC__+':'+aint(__LINE__)+','+gUsername+']')
      BAG.P.Plan.StartZeit  # Rso.R.Plan.StartZeit;
  //    BAG.P.Plan.StartInfo  # Rso.R.Plan.StartInfo;
//debugX('Rso->Bag :'+cnvad(Rso.R.Plan.EndDat));
      BAG.P.Plan.EndDat     # Rso.R.Plan.EndDat;
      BAG.P.Plan.EndZeit    # Rso.R.Plan.EndZeit;
  //    BAG.P.Plan.EndInfo    # Rso.R.Plan.EndInfo;
  //    BAG.P.Reihenfolge     # Rso.R.Reihenfolge;

if (Set.Installname='BSP') and ((vVorherDat<>BAG.P.Plan.StartDat) or (vVorherDauer<>BAG.P.Plan.Dauer)) then begin   // 2022-11-14 AH    Proj. 2329/63
Lib_Debug:Protokoll('!BSP_Log_Komisch', 'BA '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : '+cnvad(BAG.P.Plan.StartDat)+' '+anum(BAG.P.Plan.Dauer,0)+' ['+__PROC__+':'+aint(__LINE__)+','+gUsername+']')
end;

      if (aZusatz<>'') then begin
        BAG.P.Plan.StartInfo  # aZusatz;
        BAG.P.Reihenfolge     # 0;    // 13.11.2019
      end;

      //Erx # BA1_P_Data:Replace(_recunlock,'AUTO');
      Erx # RekReplace(702, _recunlock,'AUTO');
      RekRestore(vBuf);
    end;
  end
  else if ("Rso.R.Trägertyp"='WART') then begin
//    Rso.IHA.WartungYN     # true;
//    Rso.IHA.Nummer        # "Rso.R.Trägernummer1";
//    Rso.IHA.Gruppe        # "Rso.R.Trägernummer2";
//    Rso.IHA.Ressource     # "Rso.R.Trägernummer3";
//    Erx # RecRead(165,1,_recLock);
//    if (Erx<>_rOK) then RETURN false;
//    Rso.IHA.Termin;
//    RekReplace(165);
  end
  else begin
    RETURN true;
  end;

  RETURN (Erx=_rOK);
end;


//========================================================================
//========================================================================
sub _SetDataAus702();
local begin
  Erx       : int;
  vNetto    : float;
  vBrutto   : float;
  vStk      : int;
  vStarter  : logic;
  vTim      : time;
  v701      : int;
end;
begin

//debugx('702 -> Rsv');
  // Daten syncen...
  Rso.R.Ressource.Grp   # BAG.P.Ressource.Grp;
  Rso.R.Ressource.Nr    # BAG.P.Ressource;
  Rso.R.Dauer           # cnvif(BAG.P.Plan.Dauer);
  Rso.R.DauerPost       # cnvif(BAG.P.Plan.DauerPost);

  Rso.R.MEH             # '';
  if (Rso.R.Ressource.Grp<>0) then begin
    Erx # RecLink(160,170,1,_recFirst); // Ressource holen
    if (Erx<=_rLocked) then Rso.R.MEH # Rso.MEHproH;
  end;

  v701 # RekSave(701);

  vStarter # y;
  // Einsatz loopen
  FOR Erx # RekLink(701,702,2,_recFirst)
  LOOP Erx # RekLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.BruderId<>0) then CYCLE; // nur nicht-verwogene addieren
    vNetto  # vNetto + BAG.IO.Plan.In.GewN;
    vBrutto # vBrutto + BAG.IO.Plan.In.GewB;
    vStk    # vStk + BAG.IO.Plan.In.Stk;
    if (BAG.IO.Materialtyp=c_IO_BAG) then vStarter  # false;
  END;
  if (Rso.R.MEH='kg') then
    Rso.R.Menge         # Rnd(vNetto, Set.Stellen.Gewicht)
  else if (Rso.R.MEH='t') then
    Rso.R.Menge         # Rnd(vNetto / 1000.0, Set.Stellen.Menge);
  else if (Rso.R.MEH='Stk') then
    Rso.R.Menge         # cnvfi(vStk)
  else if (Rso.R.MEH='min') then
    Rso.R.Menge         # cnvfi(Rso.R.Dauer)
  else if (Rso.R.MEH='h') then
    Rso.R.Menge         # Rnd(cnvfi(Rso.R.Dauer) / 60.0, 2);

//  if (RecLinkInfo(171,170,3,_RecCount)=0) then begin  // keine Abhänigkeiten??
if (1=1) then begin // 21.11.2017 WARUM wie oben?
//debug('702 -> Rsv? KEY170');
    Rso.R.MinDat.Start    # BAG.P.Fenster.MinDat;
    Rso.R.MinZeit.Start   # BAG.P.Fenster.MinZei;
    Rso.R.MaxDat.Ende     # BAG.P.Fenster.MaxDat;
    Rso.R.MaxZeit.Ende    # BAG.P.Fenster.MaxZei;
//debugx('JA!!! auf '+cnvad(rso.r.maxdat.ende));
  end;

/**
  if (vStarter) and (Rso.R.MinDat.Start=0.0.0) then begin
    Rso.R.MinDat.Start  # today;
    vTim # now;
    if (vTim->vpMinutes>0) then       // Volle Stunden!
      vTim->vmSecondsModify(60 * 60);
    vTim->vpMinutes # 0;
    vTim->vpSeconds # 0;
    Rso.R.MinZeit.Start # vTim;
//      Rso_Kal_Data:GetPlantermin(Rso.R.Ressource.Grp, var Rso.R.Fenster.MinDat, var Rso.R.Fenster.MinZei, cnvif(Rso.R.Dauer), var vDat, var vTim);
  end;
**/

//debugx('702 -> Rsv   min'+cnvat(BAG.P.Fenster.MinZei));
  Rso.R.Plan.StartDat   # BAG.P.Plan.StartDat;
  Rso.R.Plan.StartZeit  # BAG.P.Plan.StartZeit;
//    Rso.R.Plan.StartInfo  # BAG.P.Plan.StartInfo;
  Rso.R.Plan.EndDat     # BAG.P.Plan.EndDat;
//debugX('BAG->RSO :'+cnvad(Rso.R.Plan.EndDat));
  Rso.R.Plan.EndZeit    # BAG.P.Plan.EndZeit;
//    Rso.R.Plan.EndInfo    # BAG.P.Plan.EndInfo;
  "Rso.R.Löschmarker"   # "BAG.P.Löschmarker";
//    Rso.R.Reihenfolge     # BAG.P.Reihenfolge;

  Rso.R.Level           # BAG.P.Level;

  // 03.06.2020 AH: offene, mit Datum versehene Pos., die NICHT automatisch geplant wurden, als FIXED ansehen
  if ("Rso.R.Löschmarker"='') and (BAG.P.Plan.StartInfo<>'#AUTOJIT#') and (BAG.P.Plan.StartDat<>0.0.0) then "Rso.R.Löschmarker" # 'F';

  RekRestore(v701);
end;


//========================================================================
// Delete702
//
//========================================================================
sub Delete702(
  opt aNr   : int;
  opt aPos  : int;
) : int;
local begin
  Erg2  : int;
end;
begin
  if (cDeaktiviert) then RETURN 0;
//debugx('DEL KEY702');

  Erg2 # Read('BAG', aNr, aPos);
  if (Erg2>0) then begin
    Erg2 # Delete170();
  end;

end;


//========================================================================
// Insert702
//
//========================================================================
sub Insert702() : int;
local begin
  Erg2  : int;
end;
begin
  if (cDeaktiviert) then RETURN 0;
  if (BAG.VorlageYN) then RETURN 0; // 24.07.2017 AH
  if (BAG.P.Typ.VSBYN) then RETURN 0;
  if ("BAG.P.Löschmarker"='*') and (BAG.P.Fertig.Dat=0.0.0) then RETURN 0;  // 19.03.2019 AH : neu mit Datum?
  
  RecBufClear(170);
  "Rso.R.Trägertyp"     # 'BAG';
  "Rso.R.Trägernummer1" # BAG.P.Nummer;
  "Rso.R.Trägernummer2" # BAG.P.Position;

  _SetDataAus702();

  _CalcPlanFenster();

  // Speichern...
  Rso.R.Reservierungnr # Lib_Nummern:ReadNummer('Ressource-Reservierung');
  if (Rso.R.ReservierungNr<>0) then begin
    Lib_Nummern:SaveNummer();
    Erg2 # RekInsert(170);
    if (erg2<>_rOK) then todox('RSO.RSV.INSERT');
  end
  else begin
    Erg2 # _rNoLock;
  end;

//Lib_Sound:Play( 'Hupe LKW.wav' )

  RETURN Erg2;
end;


//========================================================================
// Update702
//
//========================================================================
sub Update702(a702Alt : int) : int;
local begin
  Erx       : int;
  Erg2      : int;
  vDel      : logic;
  v701      : int;
  v170      : int;
  vStartMod : logic;
  vEndeMod  : logic;
  vTS       : int;
end;
begin

  if (cDeaktiviert) then RETURN 0;

  if (BAG.VorlageYN) then RETURN 0; // 03.05.2018 AH

// alten Inhalt holen
//  vAlt # RecBufCreate(702);
//  RecRead(vAlt, 0, _recId, RecInfo(702,_recID));
//debugx('update KEY702');

  // 24.07.2017 AH:
  vDel # (("BAG.P.Löschmarker"='*') and (BAG.P.Fertig.Dat=0.0.0)) or  // 19.03.2019 AH : neu mit Datum?
        (BAG.P.Typ.VSBYN) or (BAG.VorlageYN);
  if (vDel) then begin
    Delete702(a702Alt->BAG.P.Nummer, a702Alt->BAG.P.Position);

    // VSB-Datum updaten
    if (BAG.P.Typ.VSBYN) then begin
      v701 # RecBufcreate(701);
      // Inputs loopen...
      FOR Erx # RecLink(v701,702,2,_recFirst)
      LOOP Erx # RecLink(v701,702,2,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (v701->BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;
        if (v701->BAG.IO.VonBAG=0) then CYCLE;
        _702GehtNachVSB(v701->BAG.IO.VonBAG, v701->BAG.IO.VonPosition);
      END;
      RecBufDestroy(v701);
    end;
    RETURN 0;
  end;

//debug('check  BA' +aint(a702Alt->BAG.P.Nummer)+'/'+aint(a702Alt->BAG.P.Position))
  Erx # Read('BAG', a702Alt->BAG.P.Nummer, a702Alt->BAG.P.Position);
  // gibts nicht mehr?
  if (Erx<0) then begin
    Insert702();
  end;

  // einfaches Update
  RecRead(170,1,_RecLock);
  v170 # RekSave(170);
  "Rso.R.Trägernummer1" # BAG.P.Nummer;
  "Rso.R.Trägernummer2" # BAG.P.Position;
  _SetDataAus702();
  
  // 14.06.2018 AH Plandauer verschiebt Fenster ENDE
  if (Rso.R.MaxDat.Ende<>0.0.0) then begin
    vTS # GetTS(Rso.R.MaxDat.Ende, Rso.R.MaxZeit.Ende);
    vTS # vTS + (v170->Rso.R.DauerPost);    // 5 Pause vor 13:55 ergibt 14:00
    vTS # vTS - Rso.R.DauerPost;            // 20 Pause um 14:00 ergibt 13:40
    SetTS(vTS, var Rso.R.MaxDat.Ende, var Rso.R.MaxZeit.Ende);
  end;
  if (Rso.R.MinDat.Ende<>0.0.0) then begin
    vTS # GetTS(Rso.R.MinDat.Ende, Rso.R.MinZeit.Ende);
    vTS # vTS + (v170->Rso.R.DauerPost);    // 5 Pause vor 13:55 ergibt 14:00
    vTS # vTS - Rso.R.DauerPost;            // 20 Pause um 14:00 ergibt 13:40
    SetTS(vTS, var Rso.R.MinDat.Ende, var Rso.R.MinZeit.Ende);
  end;
  
  Erg2 # Replace(_recunlock, 'AUTO');
  if (erg2<>_rOK) then begin
    todox('RSO.RSV.REPLACE')
    RecBufDestroy(v170);
    RETURN Erg2;
  end;
/*** 10.12.2019 muss das? ist schon in REPLACE?
  // ÜBER KREUZ???
  vEndeMod  # (v170->Rso.R.Plan.EndDat <> Rso.R.Plan.EndDat) or
              (v170->Rso.R.Plan.EndZeit <> Rso.R.Plan.EndZeit) or
              (v170->Rso.R.MinDat.Ende <> Rso.R.MinDat.Ende) or
              (v170->Rso.R.MinZeit.Ende <> Rso.R.MinZeit.Ende) or
              (v170->Rso.R.MinDat.Start <> Rso.R.MinDat.Start) or
              (v170->Rso.R.MinZeit.Start <> Rso.R.MinZeit.Start);

  vStartMod # (v170->Rso.R.Plan.StartDat <> Rso.R.Plan.StartDat) or
              (v170->Rso.R.Plan.StartZeit <> Rso.R.Plan.StartZeit) or
              (v170->Rso.R.MaxDat.Start <> Rso.R.MaxDat.Start) or
              (v170->Rso.R.MaxZeit.Start <> Rso.R.MaxZeit.Start) or
              (v170->Rso.R.MaxDat.Ende <> Rso.R.MaxDat.Ende) or
              (v170->Rso.R.MaxZeit.Ende <> Rso.R.MaxZeit.Ende);

  // 14.06.2018 AH: Änderungen von Dauer/DauerPost betreffen VORGÄNGER
  if (v170->Rso.R.DauerPost <> Rso.R.DauerPost) or
     (v170->Rso.R.Dauer <> Rso.R.Dauer) then vStartMod # y;

  RecBufDestroy(v170);

  if (vEndeMod) then begin
debugX('>>>');
    VererbeEndeNachHinten();
  end;

  if (vStartMod) then begin
//debugX('<<<');
    VererbeStartNachVorne();
  end;

//  if  (v170->Rso.R.Dauer<>Rso.R.Dauer) or
//      (v170->Rso.R.DauerPost<>Rso.R.DauerPost) or
//      (v170->Rso.R.Plan.EndZeit<>Rso.R.Plan.EndZeit) or
//      (v170->Rso.R.Plan.EndDat<>Rso.R.Plan.EndDat) then begin
//  if  (v170->Rso.R.Plan.StartZeit<>Rso.R.Plan.StartZeit) or
//      (v170->Rso.R.Plan.StartDat<>Rso.R.Plan.StartDat) then begin
//    VererbeStartNachVorne();
//  end;
 **/
  RETURN Erg2;
end;




//========================================================================
//========================================================================
sub  _Prepare701(
  aVonBag   : int;
  aVonPos   : int;
  aNachBag  : int;
  aNachPos  : int;
  var aVon  : int;
  var aNach : int;) : logic;
begin
  if (BAG.IO.MaterialTyp<>c_IO_BAG) then RETURN false;
  if (aVonBAG=0) then RETURN false;
  if (aVonPos=0) then RETURN false;

  aVon  # Read('BAG', aVonBAG, aVonPos);
  if (aVon<=0) then RETURN false;


  if (aNachBAG=0) then RETURN false;
  if (aNachPos=0) then RETURN false;

  aNach # Read('BAG', aNachBAG, aNachPos);
//debug('nach '+aint(aNach));
  if (aNach<=0) then RETURN false;    // 07.11.2017 AH "=0" wird "<=0"
//if (aNach<0) then aNach # 0;

  RETURN true;
end;


//========================================================================
// Insert701
//
//========================================================================
sub Insert701() : int;
local begin
  Erx   : int;
  v170  : int;
  vVon  : int;
  vNach : int;
  Erg2  : int;
end;
begin

  if (cDeaktiviert) then RETURN 0;

  if (_Prepare701(BAG.IO.VonBAG, BAG.IO.VonPosition, BAG.IO.NachBAG, BAG.IO.NachPosition, var vVon, var vNach)=false) then begin
    // nur Nachfolger fehlt?
    if (vVon<>0) and (vNach>-2) and (BAG.IO.NachBAG<>0) and (BAG.IO.NachPosition<>0) then begin
      // Nachfolger könnte VSB sein...prüfen
      _702GehtNachVSB(BAG.IO.VonBAG, BAG.IO.VonPosition);
    end;

    RETURN 0;
  end;

  "Rso.R.V.Vorgänger"     # vVon;
  "Rso.R.V.Nachfolger"    # vNach;
  Erx # RecRead(171,1,_recLock);
  // gibt's schon? -> Zähler erhöhen
  if (Erx<=_rOK) then begin
    Rso.R.V.Anzahl # Rso.R.V.Anzahl + 1;
    Erg2 # RekReplace(171);
    RETURN Erg2;
  end;

  // neuer Satz!
  "Rso.R.V.Vorgänger"     # vVon;
  "Rso.R.V.Nachfolger"    # vNach;
  Rso.R.V.Anzahl          # 1;
  Erg2 # RekInsert(171);

  if (erg2=_rOK) then begin
    v170 # RekSave(170);
    Erx # RecLink(170,171,1,_Recfirst); // Vorgänger holen
    if (Erx<=_rLocked) then begin
      VererbeEndeNachHinten();
    end;

    Erx # RecLink(170,171,2,_Recfirst); // Nachfolger holen
    if (Erx<=_rLocked) then begin
      VererbeStartNachVorne();
    end;

    RekRestore(v170);
  end;

  RETURN Erg2;
end;


//========================================================================
// Delete701
//
//========================================================================
sub Delete701(opt aVon : int; opt aNach : int) : int;
local begin
  Erx   : int;
  Erg2  : int;
end;
begin
  if (cDeaktiviert) then RETURN 0;
//debugx('Del701');
  if (aVon=0) and (aNach=0) then begin
    if (_Prepare701(BAG.IO.VonBAG, BAG.IO.VonPosition, BAG.IO.NachBAG, BAG.IO.NachPosition, var aVon, var aNach)=false) then
      RETURN 0;
  end;

  "Rso.R.V.Vorgänger"     # aVon;
  "Rso.R.V.Nachfolger"    # aNach;

  Erx # RecRead(171,1,_recLock);
  // gibt'S nicht? -> komscih, aber ENDE
  if (Erx>_rLocked) then begin
    RETURN 0;
  end;

  // gibt's schon? -> Zähler mindern
  if (Rso.R.V.Anzahl>1) then begin
    Rso.R.V.Anzahl # Rso.R.V.Anzahl - 1;
    Erg2 # RekReplace(171);
    RETURN Erg2;
  end;

  // letzte Verbindung (Anzahl=1) ? -> LÖSCHEN
  RecRead(171,1,_recUnlock);
  Erg2 # Delete171();
  RETURN Erg2;
end;


//========================================================================
// Update701
//
//========================================================================
sub Update701(opt a701Alt : int) : int;
local begin
  vVon    : int;
  vNach   : int;
  vLocal  : logic;
end;
begin

  if (cDeaktiviert) then RETURN 0;

  // Verbindung bleibt gleich? -> Ende
  if (a701Alt<>0) then begin
    if (a701Alt->BAG.IO.VonBAG = BAG.IO.VonBAG) and
      (a701Alt->BAG.IO.VonPosition = BAG.IO.VonPosition) and
      (a701Alt->BAG.IO.NachBAG = BAG.IO.NachBAG) and
      (a701Alt->BAG.IO.NachPosition = BAG.IO.NachPosition) then begin
      RETURN 0;
    end;
  end
  else begin
    vLocal # y;
    a701Alt # RecBufCreate(701);
    RecBufCopy(701, a701Alt);
  end;
  
//debugx('UPdate '+aint(a701Alt->BAG.IO.VonBAG)+'/'+aint(a701Alt->BAG.IO.VonPosition)+' > '+aint(a701Alt->BAG.IO.NachBAG)+'/'+aint(a701Alt->BAG.IO.NachPosition));

  // Alte Verbindung holen...
  if (_Prepare701(a701Alt->BAG.IO.VonBAG, a701Alt->BAG.IO.VonPosition, a701Alt->BAG.IO.NachBAG, a701Alt->BAG.IO.NachPosition, var vVon, var vNach)) then begin
    Delete701(vVon, vNach);
  end
  else begin
    // nur Nachfolger fehlt?
    if (vVon<>0) and (vNach>-2) and (BAG.IO.NachBAG<>0) and (BAG.IO.NachPosition<>0) then begin
      // Nachfolger könnte VSB sein...prüfen
      _702GehtNachVSB(BAG.IO.VonBAG, BAG.IO.VonPosition);
    end;
    if (vVon<>0) and (vNach>-2) and (a701Alt->BAG.IO.NachBAG<>0) and (a701Alt->BAG.IO.NachPosition<>0) then begin
      // Nachfolger könnte VSB sein...prüfen
      _702GehtNachVSB(a701Alt->BAG.IO.VonBAG, a701Alt->BAG.IO.VonPosition);
    end;
//    RETURN 0;
  end;

  if (vLocal) then
    RecbufDestroy(a701Alt);
  
  // Neue Verbindung setzen...
  RETURN Insert701();
end




//========================================================================
//========================================================================
sub GetStartPlanOderFenster() : int;
local begin
  vDauer  : int;
  vTS     : int;
end
begin
  vTS # -1;
//  vDauer # cnvif(Rso.R.Dauer);
//  if (vDauer<cMinDauer) then
//    vDauer # cMinDauer;
  // verplant?
  if (Rso.R.Plan.StartDat<>0.0.0) then begin
//    if (Rso.R.Plan.EndDat<>0.0.0) then begin
//      vB # BigDat(Rso.R.Plan.EndDat, Rso.R.Plan.EndZeit);
//    end
//    else begin
    vTS # GetTS(Rso.R.Plan.StartDat, Rso.R.Plan.StartZeit);
//    vB # vB + vDauer;
//    end;
  end
  // noch "Fenster"?
  else begin
//    if (Rso.R.Fenster.MaxDat<>0.0.0) then begin
//      vB # BigDat(Rso.R.Fenster.MaxDat, Rso.R.Fenster.MaxZei);
//    end
//    else begin
      if (Rso.R.MaxDat.Start<>0.0.0) then
        vTS # GetTS(Rso.R.MaxDat.Start, Rso.R.MaxZeit.Start);
//      vB # vB + vDauer;
//    end;
  end;

  RETURN vTS;
end;


//========================================================================
//========================================================================
sub GetEndePlanOderFensterMitPause() : int;
local begin
  vDauer  : int;
  vTS     : int;
end
begin

  vTS # -1;

//  vDauer # Rso.R.Dauer + Rso.R.DauerPost;
//  if (vDauer<cMinDauer) then
//    vDauer # cMinDauer;
//debugx('KEY170   '+cDebugTraeger+' d:'+aint(Rso.R.DauerPost));

  if (Rso.R.Plan.EndDat<>0.0.0) then begin
    vTS # GetTS(Rso.R.Plan.EndDat, Rso.R.Plan.EndZeit);
    vTS # vTS + Rso.R.DauerPost; // 14.06.2018
  end
  else if (Rso.R.MinDat.Ende<>0.0.0) then begin
    vTS # GetTS(Rso.R.MinDat.Ende, Rso.R.MinZeit.Ende);
    vTS # vTS + Rso.R.DauerPost; // 14.06.2018
  end;


  RETURN vTS;
end;


//========================================================================
// MAXENDE wird kleinster Nachfolger START
//========================================================================
sub FindMaxEnde();
local begin
  Erx   : int;
  v170    : int;
  v171    : int;
  vMin    : int;
  vTS     : int;
  vDauer  : int;
end;
begin

  v170 # RekSave(170);
  v171 # RekSave(171);

  // 14.06.2018 AH
  vDauer # Rso.R.DauerPost;

  vMin # 1234567890;
  // Nachfolger loopen...
  FOR Erx # RecLink(171,v170,3,_RecFirst)
  LOOP Erx # RecLink(171,v170,3,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(170,171,2,_Recfirst); // Nachfolger holen
    if (Erx>_rLocked) then CYCLE;
    vTS # GetStartPlanOderFenster();
    if (vTS<>-1) then begin
      vMin # Min(vMin, vTS - vDauer);
    end;
  END;
  RekRestore(v170);
  RekRestore(v171);

  // keine sinnigen Nachfolger?? -> dann KEIN begrenztes Ende
  if (vMin=1234567890) then begin
    if (Rso.R.MaxDat.Ende<>0.0.0) then begin
//debugx('nulle MaxEnde');
      RecRead(170,1,_recLock);
      Rso.R.maxDat.Ende   # 0.0.0;
      Rso.R.MaxZeit.Ende  # 0:0;
      Rso.R.MaxDat.Start  # 0.0.0;
      Rso.R.MaxZeit.Start # 0:0;
      Erx # RekReplace(170);
      if (Erx=_rOK) then begin
        UpdateTraeger();
        VererbeStartNachVorne();
      end;
    end;
    RETURN;
  end;
  
  
  // es gibt eine Grenze...
  vTS # GetTS(Rso.R.MaxDat.Ende, Rso.R.MaxZeit.Ende);

//debug('VORHER:' +cnvad(Rso.R.MaxDat.Start)+'-'+cnvad(Rso.R.MaxDat.Ende)+'   '+aint(vTS)+' auf '+aint(vMin));
//SetTS(vMin, var Adr.Anlage.DAtum, var Adr.Anlage.Zeit);
//debugx('NEUESmin='+cnvad(adr.anlage.datum)+' '+cnvat(adr.anlage.Zeit));
// Veränderung?
  if (vMin<>vTS) then begin
    RecRead(170,1,_recLock);
    SetTS(vMin, var Rso.R.MaxDat.Ende, var Rso.R.MaxZeit.Ende);
//  18.12.2018  _SchiebeInAZ(var Rso.R.MaxDat.Start, var Rso.R.MaxZeit.Start,'<');
    _SchiebeInAZ(Rso.R.Ressource.Grp, var Rso.R.MaxDat.Ende, var Rso.R.MaxZeit.Ende,'<');
// 13.06.2018 AH: War deaktiviert???
    _CalcMaxStart();
//debug('MAX bei KEY170 auf: '+cnvad(Rso.R.MaxDat.Start)+' - '+cnvad(Rso.R.MaxDat.Ende));
    Erx # RekReplace(170);
    if (Erx<>_rOK) then debugx('AUA!!!!!!!!!!!!!')
    else begin
      UpdateTraeger();
      VererbeStartNachVorne();
    end;
  end;

end;


//========================================================================
// MINSTART wird größter Vorgänger ENDE
//========================================================================
sub FindMinStart();
local begin
  Erx     : int;
  v171    : int;
  v170    : int;
  vMax    : int;
  vTS     : int;
end;
begin
//debugx('recalcMinStart KEY170');

  v171 # RekSave(171);
  v170 # RekSave(170);

  // Vorgänger loopen...
  FOR Erx # RecLink(171,v170,2,_RecFirst)
  LOOP Erx # RecLink(171,v170,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(170,171,1,_Recfirst); // Vorgänger holen
    if (Erx>_rLocked) then CYCLE;
    vTS # GetEndePlanOderFensterMitPause();

    if (vTS<>-1) then begin
      vMax # Max(vMax, vTS);
    end;
  END;
  RekRestore(v170);
  RekRestore(v171);
  
  // keine sinnigen Vorhänger? -> dann KEIN begrenzter Start
  if (vMax=0) then begin
    if (Rso.R.MaxDat.Ende<>0.0.0) then begin
      RecRead(170,1,_recLock);
      Rso.R.minDat.Start  # 0.0.0;
      Rso.R.MinZeit.Start # 0:0;
      Rso.R.MinDat.Ende   # 0.0.0;
      Rso.R.MinZeit.Ende  # 0:0;
      Erx # RekReplace(170);
      if (Erx=_rOK) then begin
        UpdateTraeger();
        VererbeStartNachVorne();
      end;
    end;
    RETURN;
  end;

  // es gibt eine Grenze...
  vTS # GetTS(Rso.R.MinDat.Start, Rso.R.MinZeit.Start);
  // Veränderung?
  if (vMax<>vTS) then begin
    RecRead(170,1,_recLock);
    SetTS(vMax, var Rso.R.MinDat.Start, var Rso.R.MinZeit.Start);

    _SchiebeInAZ(Rso.R.Ressource.Grp, var Rso.R.MinDat.Start, var Rso.R.MinZeit.Start,'>');
// 07.06.2018 AH WAR DEKATIVIERT???
    _CalcMinEnde();
//debug('MIN bei KEY170 auf: '+cnvad(Rso.R.MinDat.Start)+' - '+cnvad(Rso.R.MinDat.Ende));
    Erx # RekReplace(170);
    if (Erx=_rOK) then begin
      UpdateTraeger();
      VererbeEndeNachHinten();    // 15.06.2018
    end;
  end;

end;


//========================================================================
//  von HIER mein ENDE an Nachfolger als START updaten
//========================================================================
sub VererbeEndeNachHinten()
local begin
  Erx         : int;
  v170        : int;
  v171        : int;
  vOK         : logic;
  v701        : int;
  v702        : int;
end;
begin

//debugx('VererbeEndeNachHinten ab KEY170 '+"Rso.R.Trägertyp"+aint("Rso.R.Trägernummer1")+'/'+aint("Rso.R.Trägernummer2"));

  v170 # RekSave(170);
  v171 # RekSave(171);
  // Nachfolger loopen...
  FOR Erx # RecLink(171,v170,3,_RecFirst)
  LOOP Erx # RecLink(171,v170,3,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    vOK # true;
    Erx # RecLink(170,171,2,_Recfirst); // Nachfolger holen
    if (Erx>_rLocked) then CYCLE;
    FindMinStart();
// 11.12.2019 AH    VererbeEndeNachHinten();    // 15.06.2018
  END;
  
  // evtl. BA-VSB-Schritte? 10.12.2019
  if (vOK=false) and ("Rso.R.Trägertyp"='BAG') then begin
    v701 # RekSave(701);
    v702 # RekSave(702);
    BAG.IO.VonBAG       # "Rso.R.Trägernummer1";
    BAG.IO.VonPosition  # "Rso.R.Trägernummer2";
    Erx # RecRead(701,3,0);
    WHILE (Erx<_rNoRec) and (BAG.IO.VonBAG="Rso.R.Trägernummer1") and
      (BAG.IO.VonPosition="Rso.R.Trägernummer2") do begin
      if (BAG.IO.NachBAG<>0) then begin
        Erx # RecLink(702,701,4,_recFirst);   // nach Position holen
        if (Erx<=_rLocked) and (BAG.P.Typ.VSBYN) then begin
          BA1_P_Data:UpdateMinVSB();
        end;
      end;
      Erx # RecRead(701,3,_recNext);
    END;
    
    RekRestore(v702);
    RekRestore(v701);
  end;
  
  RekRestore(v170);
  RekRestore(v171);
end;


//========================================================================
// von HIER mein START an Vorgänger als ENDE updaten
//========================================================================
sub VererbeStartNachVorne()
local begin
  Erx         : int;
  v170        : int;
  v171        : int;
end;
begin
//debugx('StartVererben von KEY170');

  v170 # RekSave(170);
  v171 # RekSave(171);
  // Vorgänger loopen...
  FOR Erx # RecLink(171,v170,2,_RecFirst)
  LOOP Erx # RecLink(171,v170,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin
  
    Erx # RecLink(170,171,1,_Recfirst); // Vorgänger holen
    if (Erx>_rLocked) then CYCLE;

    FindMaxEnde();
    VererbeStartNachVorne();
  END;
  RekRestore(v170);
  RekRestore(v171);

end;


//========================================================================
// aktueller 702 = VSB-Schritt
//========================================================================
sub _702GehtNachVSB(
  aBA   : int;            // Vorgänger Pos.
  aPos  : int) : logic;
local begin
  Erx   : int;
  vMod  : logic;
  v702  : int;
end;
begin

  v702 # RekSave(702);

  BAG.P.Nummer    # aBA;
  BAG.P.Position  # aPos;
  Erx # RecRead(702,1,0);
  if (Erx<=_rLocked) then begin   // Vorgänger Pos. holen
    // Änderung???
    vMod # BA1_P_Data:ModifyFensterMax();
  end;

  RekRestore(v702);

  RETURN true;
end;


//========================================================================
// call Rso_rsv_data:init
//========================================================================
sub INIT();
local begin
  Erx : int;
end;
begin
  if (cDeaktiviert) then RETURN;

  Prg.Nr.Name # 'Ressource-Reservierung';
  RecRead(902,1,_recLock)
  Prg.Nr.Nummer # 1;
  RekReplace(902);

  RekDeleteAll(170);
  RekDeleteAll(171);

  // BA-Positionen loopen...
  FOR Erx # RecRead(702,1,_recFirst)
  LOOP Erx # RecRead(702,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(700,702,1,0); // BA-Kopf holen
    Insert702();
  END;

  // BA-IO loopen...
  FOR Erx # RecRead(701,1,_recFirst)
  LOOP Erx # RecRead(701,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(700,701,1,0); // BA-Kopf holen
    Insert701();
  END;

RETURN;

  Rso.R.ReservierungNr # 2;
  RecRead(170,1,_RecLock);
  if (Rso.R.Plan.StartZeit=8:00) then
    Rso.R.Plan.StartZeit # 10:00
  else
    Rso.R.Plan.StartZeit # 8:0;
  Replace(_recunlock,'AUTO');

end;


//========================================================================
//  Call Rso_Rsv_Data:RepairBAG
//========================================================================
sub RepairBAG(
  opt aNurCheck : logic;
  opt aNr       : int)
local begin
  Erx     : int;
  vTxt    : int;
  Erg2    : int;
  vA, vB  : alpha;
  vI      : int;
  v700    : int;
  vOK     : logic;
end;
begin

//aNr # 3080;
//aNr # 2790;
//Lib_debug:StartBluemode();
  if (aNr=0) then aNr # BAG.Nummer;
  if (cDeaktiviert) then RETURN;

  v700 # Reksave(700);
  if (aNurCheck=false) then begin
    if (Msg(99,'Jetzt die Abhängigkeiten von BA '+aint(aNr)+' prüfen bzw. reparieren?',_WinIcoQuestion,_WinDialogYesNo,2)<>_winidyes) then begin
      RekRestore(v700);
      RETURN;
    end;
  end;
  
  vTxt # TextOpen(20);
  vOK # true;

  FOR begin
    BAG.Nummer # aNr;
    if (aNr=0) then Erx # RecRead(700,1,_recFirst)
    else Erx # RecRead(700,1,0);
  end;
  LOOP Erx # RecRead(700,1,_recNext)
  WHILE (Erx<=_rLocked) and ((aNr=0) or (BAG.Nummer=aNr)) do begin
    if (aNr<>0) and (BAG.Nummer<>aNr) then CYCLE;
    if (BAG.VorlageYN) then CYCLE;

    TextClear(vTxt);

    // BA-Positionen loopen...
    FOR Erx # RecLink(702,700,1,_recFirst)
    LOOP Erx # RecLink(702,700,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.P.Typ.VSBYN) then CYCLE;
      if ("BAG.P.Löschmarker"='*') and (BAG.P.Fertig.Dat=0.0.0) then CYCLE;

      Erx # Read('BAG', BAG.P.Nummer, BAG.P.Position);
      // gibts?
      if (Erx>0) then begin
        TextAddLine(vTxt, 'P'+aint(BAG.P.Position)+'|R'+aint(Rso.R.Reservierungnr)+'|');
//debug('P'+aint(BAG.P.Position)+'|R'+aint(Rso.R.Reservierungnr)+'|');
        CYCLE;
      end;

      // FEHLT !!!!!!!!!!!!
//debug('RSORES fehlt bei KEY702');
      RecBufClear(170);
      "Rso.R.Trägertyp"     # 'BAG';
      "Rso.R.Trägernummer1" # BAG.P.Nummer;
      "Rso.R.Trägernummer2" # BAG.P.Position;
      _SetDataAus702();
      _CalcPlanFenster();

      // NEU Speichern...
      Rso.R.Reservierungnr # Lib_Nummern:ReadNummer('Ressource-Reservierung');
      if (Rso.R.ReservierungNr<>0) then begin
        Lib_Nummern:SaveNummer();
        Erg2 # RekInsert(170);
        if (erg2<>_rOK) then todox('RSO.RSV.INSERT');
      end;
      TextAddLine(vTxt, 'P'+aint(BAG.P.Position)+'|R'+aint(Rso.R.Reservierungnr)+'|');
      vOK # false;
//debug('NEU P'+aint(BAG.P.Position)+'|R'+aint(Rso.R.Reservierungnr)+'|');
    END; // Positionen

    
    if (aNurCheck) then begin
      TextClose(vTxt);
      RekRestore(v700);
      if (vOK=false) then Msg(99,'Die BA-Abhängigkeiten sind nicht mehr i.O.!!!'+StrChar(13)+'Bitte Vorgang "merken" und melden!',0,0,0)
      RETURN;
    end;

    
    // alle Verbindungen erst mal Nullen...
    vI # 1;
    WHILE (vI<=TextInfo(vTxt, _textlines)) do begin
      vA # TextLineRead(vTxt, vI, 0);
      inc(vI);
      if (Strcut(vA,1,1)<>'P') then CYCLE;
      vB # Str_token(vA,'|',2);
      Rso.R.Reservierungnr # cnvia(vB);
      Erx # RecRead(170,1,0);
      if (Erx>_rLocked) then todo('CHAOS '+aint(__LINE__)+':'+vA);

      // Vorgänger nullen...
      FOR Erx # RecLink(171,170,2,_recFirst)
      LOOP Erx # RecLink(171,170,2,_recNext)
      WHILE (Erx<=_rLocked) do begin
        RecRead(171,1,_recLock);
        Rso.R.V.Anzahl # 0;
        RekReplace(171);
      END;
      // Nachfolger nullen...
      FOR Erx # RecLink(171,170,3,_recFirst)
      LOOP Erx # RecLink(171,170,3,_recNext)
      WHILE (Erx<=_rLocked) do begin
        RecRead(171,1,_recLock);
        Rso.R.V.Anzahl # 0;
        RekReplace(171);
      END;
    END;
    

    // BA-IOs loopen...
    FOR Erx # RecLink(701,700,3,_recFirst)
    LOOP Erx # RecLink(701,700,3,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.MaterialTyp<>c_IO_BAG) then CYCLE;
      if (BAG.IO.VonBAG=0) or (BAG.IO.NachBAG=0) then CYCLE;

//debug(aint(BAG.IO.VonPosition)+'>'+aint(BAG.IO.NachPosition));
      // Verbindung herstellen
      Update701();
    END;


    // alle leeren Verbindungen verwerfen
    vI # 1;
    WHILE (vI<=TextInfo(vTxt, _textlines)) do begin
      vA # TextLineRead(vTxt, vI, 0);
      inc(vI);
      if (Strcut(vA,1,1)<>'P') then CYCLE;
      vB # Str_token(vA,'|',2);
      Rso.R.Reservierungnr # cnvia(vB);
      Erx # RecRead(170,1,0);
      if (Erx>_rLocked) then todo('CHAOS '+aint(__LINE__)+':'+vA);

      // Vorgänger nullen...
      Erx # RecLink(171,170,2,_recFirst)
      WHILE (Erx<=_rLocked) do begin
        if (Rso.R.V.Anzahl<>0) then begin
//debugx(aint("Rso.R.V.Vorgänger")+'>'+aint(Rso.R.V.Nachfolger)+':'+aint(Rso.R.V.Anzahl));
          Erx # RecLink(171,170,2,_recNext)
          CYCLE;
        end;
        Rekdelete(171);
//debug('empty kill KEY171');
        Erx # RecLink(171,170,2,0);
        Erx # RecLink(171,170,2,0);
      END;

    END;

  END;

  TextClose(vTxt);

  RekRestore(v700);

  Msg(999998,'',0,0,0);
  
end;


//========================================================================