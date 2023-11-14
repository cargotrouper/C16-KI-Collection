@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_Maske_Main
//                    OHNE E_R_G
//  Info
//
//
//  15.09.2005  AI  Erstellung der Prozedur
//  28.07.2009  ST  Ansprungreihenfolge angepasst
//  22.12.2010  MS  Eigenes Menue
//  08.11.2011  AI  Ablängen errechnet über Artikeldaten
//  29.06.2012  AI  Analyse eingebaut
//  11.07.2012  ST  Fehlerkorrektur Sprunglogik + alternative Betriebsmaske
//  16.07.2012  ST  Fehlerkorrektur: Maskenlabels Wgr und Kommission
//  21.11.2012  AI  Beistellungen nur bei INTERNEN BAs
//  30.11.2012  ST  Gewichtsberechnung bei FocusTerm "edGewichtBruttoOderNetto" für FMMaske2 hinzhugefügt
//  10.12.2012  ST  Neue Rechte für Reiter und weitere Felder laut 1433/15
//  02.01.2013  ST  AFX für FocusTerm hinzugefügt BAG.FM.MaskEvtFocusTerm  (1406/34)
//  22.03.2013  AI  Neu: Set.BA.FM.Beist.Chk
//  01.08.2014  ST  "RecSave" Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  20.05.2015  AH  Ausführungen wurden nicht angezeigt (wegen myTmpNummer)
//  18.11.2015  ST  Kontextmenü für Berechnungen hinzugefügt
//  04.12.2017  ST  Ankerfunktionen "BA1.FM.Maske.Init.Pre" und "BA1.FM.Maske.Init" hinzugefügt P1777/12
//  10.07.2018  AH  Analysemaske DYNAMSICH ggf. AnalyseErweitert
//  20.09.2018  AH  Analysenprüfung
//  09.12.2019  AH  AFX "BA1.FM.Maske.EvtChanged.Post"
//  19.03.2020  ST  Bugfix: AnalyseMaskenCopy: Härtetitel für unterschiedliche Masken
//  22.05.2020  AH  Neu: bei angegebener Analysenummer, wird die Maske damit vorbelegt
//  16.06.2021  ST  Bugfix: AnalyseMaskenCopy: Rauhigkeitentitel für unterschiedliche Masken
//  01.10.2021  ST  Edit: RunAFX('BAG.FM.Verbuchen.Post','') -> nach gSelected
//  28.02.2022  ST  Bugfix: FM RecSave  Stückzahl als Pflichtfeld P2329/31
//  05.04.2022  AH  ERX
//  20.07.2022  HA  Quick Jump
//  2023-03-24  AH  BAG.FM.Menge bei Bereitstellen (HWN "Stryker")
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusArtikel()
//    SUB AusStruktur()
//    SUB Wiegedaten()
//    SUB AusVerwiegungsart()
//    SUB AusLagerplatz()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic;) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG
@I:Def_Aktionen

define begin
  cDialog :   $BA1.FM.Maske
  cTitle :    'Fertigmeldung'
  cFile :     707
  cMenuName : 'BA1.FM.Maske.Bearbeiten'
  cPrefix :   'BA1_FM_Maske'
//  cZList :    0
  cKey :      1

end;

declare RefreshIfm(opt aName : alpha)
declare Wiegedaten()

//========================================================================
//========================================================================
sub _CopyAnalyseMaske(aDest : int)
local begin
  vPar    : int;
  vNext   : int;
end;
begin

  // DYNAMISCH
  vPar  # Winsearch(aDest, 'NB.Page3');
//  if (Bag.F.Fertigung % 2=1) then begin
  if (Set.LyseErweitertYN) then begin
    Lib_GuiDynamisch:CopyTemplate('Lys.K.Verwaltung2', 'lbMaterialpruefungen', 'lbLys.StreckgrenzeTyp' , 8, 140, vPar, vNext);
    
// 12.11.2018 AH:
    $lbBAG.FM.Rechtwinklig->wpVisible # false;
    $edBAG.FM.Rechtwinklig->wpVisible # false;
    $lbBAG.FM.Ebenheit->wpVisible # false;
    $edBAG.FM.Ebenheit->wpVisible # false;
    $lbBAG.FM.Sbeligkeit->wpVisible # false;
    $edBAG.FM.Sbeligkeit->wpVisible # false;
    $lbBAG.FM.SaebelProM->wpVisible # false;
    $edBAG.FM.SaebelProM->wpVisible # false;
    $lbSaebelMEH->wpVisible # false;
  end
  else begin
    Lib_GuiDynamisch:CopyTemplate('Lys.Maske', 'lbLys.K.Bemerkung', 'lbLys.Mech.Sonstiges' , 8, 140, vPar, vNext);
  end;
  
    // Chemietitel ggf. setzen
  if (Set.Chemie.Titel.C<>'') then begin
    $lbLys.Chemie.C->wpcaption # Set.Chemie.Titel.C;
  end;
  if (Set.Chemie.Titel.Si<>'') then begin
    $lbLys.Chemie.Si->wpcaption # Set.Chemie.Titel.Si;
  end;
  if (Set.Chemie.Titel.Mn<>'') then begin
    $lbLys.Chemie.Mn->wpcaption # Set.Chemie.Titel.Mn;
  end;
  if (Set.Chemie.Titel.P<>'') then begin
    $lbLys.Chemie.P->wpcaption # Set.Chemie.Titel.P;
  end;
  if (Set.Chemie.Titel.S<>'') then begin
    $lbLys.Chemie.S->wpcaption # Set.Chemie.Titel.S;
  end;
  if (Set.Chemie.Titel.Al<>'') then begin
    $lbLys.Chemie.Al->wpcaption # Set.Chemie.Titel.Al;
  end;
  if (Set.Chemie.Titel.Cr<>'') then begin
    $lbLys.Chemie.Cr->wpcaption # Set.Chemie.Titel.Cr;
  end;
  if (Set.Chemie.Titel.V<>'') then begin
    $lbLys.Chemie.V->wpcaption # Set.Chemie.Titel.V;
  end;
  if (Set.Chemie.Titel.Nb<>'') then begin
    $lbLys.Chemie.Nb->wpcaption # Set.Chemie.Titel.Nb;
  end;
  if (Set.Chemie.Titel.Ti<>'') then begin
    $lbLys.Chemie.Ti->wpcaption # Set.Chemie.Titel.Ti;
  end;
  if (Set.Chemie.Titel.N<>'') then begin
    $lbLys.Chemie.N->wpcaption # Set.Chemie.Titel.N;
  end;
  if (Set.Chemie.Titel.Cu<>'') then begin
    $lbLys.Chemie.Cu->wpcaption # Set.Chemie.Titel.Cu;
  end;
  if (Set.Chemie.Titel.Ni<>'') then begin
    $lbLys.Chemie.Ni->wpcaption # Set.Chemie.Titel.Ni;
  end;
  if (Set.Chemie.Titel.Mo<>'') then begin
    $lbLys.Chemie.Mo->wpcaption # Set.Chemie.Titel.Mo;
  end;
  if (Set.Chemie.Titel.B<>'') then begin
    $lbLys.Chemie.B->wpcaption # Set.Chemie.Titel.B;
  end;
  if (Set.Chemie.Titel.1<>'') then begin
    $lbLys.Chemie.Frei1->wpcaption # Set.Chemie.Titel.1;
  end;
  if ("Set.Mech.Titel.Härte"<>'') then begin
    if (Set.LyseErweitertYN) then
      $lbLys.HaerteTyp->wpcaption # "Set.Mech.Titel.Härte";
    else
      $lbLys.Haerte->wpcaption # "Set.Mech.Titel.Härte";
  end;
  if ("Set.Mech.Titel.Körn"<>'') then begin
    $lbLys.Koernung->wpcaption # "Set.Mech.Titel.Körn";
  end;
  if ("Set.Mech.Titel.Sonst"<>'') then begin
    $lbLys.Mech.Sonstiges->wpcaption # "Set.Mech.Titel.Sonst";
  end;
  
  if ("Set.Mech.Titel.Rau1"<>'') then begin
    if (Set.LyseErweitertYN) then
      $lbLys.RauigkeitATyp->wpcaption # "Set.Mech.Titel.Rau1";
    else
      $lbLys.RauigkeitA1->wpcaption # "Set.Mech.Titel.Rau1";
  end;
  if ("Set.Mech.Titel.Rau2"<>'') then begin
    if (Set.LyseErweitertYN) then
      $lbLys.RauigkeitBTyp->wpcaption # "Set.Mech.Titel.Rau2";
    else
      $lbLys.RauigkeitB1->wpcaption # "Set.Mech.Titel.Rau2";
  end;

  if (Set.Mech.Dehnung.Wie<>1) then
    $lbLys.DehnungB->wpvisible # false;

end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # 0;//cZList;
  gKey      # cKey;

  // extern: keine Beistellungen
  if (BAG.P.ExternYN) then
    $NB.Page5->wpdisabled # true;

  Lib_Guicom2:Underline($edBAG.FM.Artikelnr);
  Lib_Guicom2:Underline($edBAG.FM.Verwiegungart);
  Lib_Guicom2:Underline($edBAG.FM.Lagerplatz);

  SetStdAusFeld('edBAG.FM.Verwiegungart'  ,'Verwiegungsart');
  SetStdAusFeld('edBAG.FM.Lagerplatz'     ,'Lagerplatz');
  SetStdAusFeld('edBAG.FM.Artikelnr'      ,'Struktur');
  SetStdAusFeld('edBAG.FM.AusfOben'       ,'AF.Oben');
  SetStdAusFeld('edBAG.FM.AusfUnten'      ,'AF.Unten');

  // Analyse leeren
  RecBufClear(230);
  RecBufClear(231);
  
  _CopyAnalyseMaske(aEvt:Obj);

  //App_Main:EvtInit(aEvt);
  RunAFX('BA1.FM.Maske.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('BA1.FM.Maske.Init',aint(aEvt:Obj));
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin

  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;
  // Pflichtfelder
  
  //    $edBAG.FM.Dicke.1 edBAG.FM.Breite.1
//  Lib_GuiCom:Pflichtfeld($edBAG.FM.Breite.1);
  Lib_GuiCom:Pflichtfeld($edBAG.FM.Stck);

  //Lib_GuiCom:Pflichtfeld($);
end;


/*========================================================================
2023-03-24  AH
========================================================================*/
sub _CalcMenge()
local begin
  Erx   : int;
  vL    : float;
end;
begin

  vL # "BAG.FM.Länge";
  if (vL=0.0) then begin
//      RecLink(819,701,7,_recFirst);   // Warengruppe holen
    Erx # RecLink(819,703,5,0);   // Warengruppe holen
    vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Netto, "BAG.FM.Stück", BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKGproQM");
    if(BAG.FM.Gewicht.Netto = 0.0) then // MS 28.12.2009
      vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Brutt, "BAG.FM.Stück", BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKGproQM");
  end;

  if (Set.Installname='HWN') and (BAG.P.Aktion<>c_BAG_Saegen) and (BAG.IO.MEH.In=BAG.FM.MEH) and (BAG.FM.MEH='m') then begin  // 2023-05-04 AH
    BAG.FM.Menge # Rnd(Lib_Berechnungen:Dreisatz(BAG.IO.Plan.In.Menge, BAG.IO.Plan.In.GewN, BAG.FM.Gewicht.Netto) ,Set.Stellen.Menge);
  end
  else begin
    if (BAG.FM.MEH='qm') then
      BAG.FM.Menge # BAG.FM.Breite * Cnvfi("BAG.FM.Stück") * vL / 1000000.0;
    if (BAG.FM.MEH='Stk') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück");
    if (BAG.FM.MEH='kg') then
      BAG.FM.Menge # Bag.FM.Gewicht.Netto;
    if (BAG.FM.MEH='t') then
      BAG.FM.Menge # Bag.FM.Gewicht.Netto / 1000.0;
    if (BAG.FM.MEH='m') or (BAG.FM.MEH='lfdm') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück") * vL / 1000.0;
  end;
end;


//========================================================================
//  CheckAnalyse
//
//========================================================================
sub CheckAnalyse(
  aObj        : int;
  aName       : alpha;
  aWert       : float;
  opt aWert2  : float;
  );
local begin
  vVon, vBis  : float;
  vName       : alpha;
  vA          : alpha;
end;
begin
RETURN;/***
  if (BAG.F.Auftragsnummer<>0) then begin
    if (Auf.P.nummer<>BAG.F.Auftragsnummer) or (Auf.P.Position<>BAG.F.AuftragsPos) then begin
      Auf_data:Read(BAG.F.Auftragsnummer, BAG.F.AuftragsPos, false);
    end;
  end;

  if (BAG.F.Auftragsnummer<>0) then
    vA # MQU_Data:BildeVorgabe(aName, 401, "BAG.F.Güte", BAG.F.Dicke, var vVon, var vBis)
  else
    vA # MQU_Data:BildeVorgabe(aName, 0, "BAG.F.Güte", BAG.F.Dicke, var vVon, var vBis);

//  aObj->wpcaption # vA;
  aObj->wpHelpTipSysFont # true;
  aObj->wpHelpTip        # vA;

  if (aWert2=0.0) then begin
    if ((aWert < vVon) and (vVon<>0.0)) or ((aWert>vBis) and (vBis<>0.0)) then
      aObj->wpColBkg # _WinColLightRed
    else
      aObj->wpColBkg # _WinColparent;
  end
  else begin
    if ((aWert<vVon) or (aWert>vBis) or (aWert2<vVon) or (aWert2>vBis)) and
      ((vVon<>0.0) or (vBis<>0.0)) then
      aObj->wpColBkg # _WinColLightRed
    else
      aObj->wpColBkg # _WinColparent;
  end;
***/
end;


//========================================================================
//========================================================================
sub CheckErweitertAnalyse(aName : alpha);
local begin
  vHdl    : int;
  vD      : float;
  vGuete  : alpha;
  vGS     : alpha;
end
begin
  // 20.09.2018 AH: DIN holen
  vD      # BAG.F.Dicke;
  vGuete  # "BAG.F.Güte";
  vGS  # "BAG.F.Gütenstufe";
  vHdl # winSearch(gMDI, 'Lb.Dicke.F');
  if (vHdl<>0) then vD # cnvfa(vHdl->wpCaption);
  vHdl # winSearch(gMDI, 'Lb.Guete.F');
  if (vHdl<>0) then vGuete # vHdl->wpCaption;
  MQU_Data:Read(vGuete, vGS, y, vD);
  
  if (BAG.F.Auftragsnummer<>0) then begin
    if (Auf.P.nummer<>BAG.F.Auftragsnummer) or (Auf.P.Position<>BAG.F.AuftragsPos) then begin
      Auf_data:Read(BAG.F.Auftragsnummer, BAG.F.AuftragsPos, false);
    end;
  end;

  if (BAG.F.Auftragsnummer<>0) then
    Lys_Msk_Main:CheckVorgaben(aName, 401)
  else
    Lys_Msk_Main:CheckVorgaben(aName, 0);

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx   : int;
  va    : alphA;
  vX    : int;
  vTmp  : int;

  vBB   : float;
  vBL   : float;
  vBGew : float;
  vBM   : float;
  vL    : float;
  vGew  : float;
  vM    : float;

  vInGew  : float;
  vInME   : float;
  vOutME  : float;
  vBuf701 : int;
  vBuf707 : int;
  vOK     : logic;
  v230    : int;
  v231    : int;
end;
begin

//  if (aName='') or ((aName='edLys.Chemie.C') and ($edLys.Chemie.C->wpchanged)) then
//    CheckAnalyse($lbLys.Chemie.C,'C',Lys.Chemie.C);

  // ist eine Analyse schon vorgegeben??? -> ja: Werte kopieren
  if (BAG.FM.Analysenummer<>0) then begin
    v230 # 230;
    v231 # 231;
    if (gMDI->wpDbRecBuf(230)<>0) then v230 # gMDI->wpDbRecBuf(230);
    if (gMDI->wpDbRecBuf(231)<>0) then v231 # gMDI->wpDbRecBuf(231);
    Erx # RecLink(v230,707,15,_recFirst);      // Analysekopf holen
    if (Erx>_rLocked) then RecBufClear(v230)
    else RecLink(v231,v230,1,_recFirst);       // Analyse holen
    BAG.FM.Analysenummer # 0;
    $cb.Analyse->wpCheckState # _WinStateChkChecked;
  end;


  if (aName='') or (aName='cb.Analyse') then begin
    vOK # $cb.Analyse->wpCheckState=_WinStateChkChecked;
//      $edLys.K.Bemerkung->wpcustom # '';
    Lib_GuiCom:Able($edLys.K.Bemerkung, vOK);
    Lib_GuiCom:Able($edLys.Streckgrenze, vOK);
    Lib_GuiCom:Able($edLys.Streckgrenze2, vOK);
    Lib_GuiCom:Able($edLys.Zugfestigkeit, vOK);
    Lib_GuiCom:Able($edLys.Zugfestigkeit2, vOK);
    Lib_GuiCom:Able($edLys.DehnungA, vOK);
    Lib_GuiCom:Able($edLys.DehnungB, vOK);
    Lib_GuiCom:Able($edLys.DehnungC, vOK);
    Lib_GuiCom:Able($edLys.DehnungsgrenzeA, vOK);
    Lib_GuiCom:Able($edLys.RP02_2, vOK);
    Lib_GuiCom:Able($edLys.DehnungsgrenzeB, vOK);
    Lib_GuiCom:Able($edLys.RP10_2, vOK);
    Lib_GuiCom:Able($edLys.Koernung, vOK);
    Lib_GuiCom:Able($edLys.Koernung2, vOK);
    Lib_GuiCom:Able($edLys.Hrte, vOK);
    Lib_GuiCom:Able($edLys.Hrte2, vOK);
    Lib_GuiCom:Able($edLys.RauigkeitA1, vOK);
    Lib_GuiCom:Able($edLys.RauigkeitA2, vOK);
    Lib_GuiCom:Able($edLys.RauigkeitB1, vOK);
    Lib_GuiCom:Able($edLys.RauigkeitB2, vOK);
    Lib_GuiCom:Able($edLys.Chemie.C, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Si, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Mn, vOK);
    Lib_GuiCom:Able($edLys.Chemie.P, vOK);
    Lib_GuiCom:Able($edLys.Chemie.S, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Al, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Cr, vOK);
    Lib_GuiCom:Able($edLys.Chemie.V, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Nb, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Ti, vOK);
    Lib_GuiCom:Able($edLys.Chemie.N, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Cu, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Ni, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Mo, vOK);
    Lib_GuiCom:Able($edLys.Chemie.B, vOK);
    Lib_GuiCom:Able($edLys.Chemie.Frei1, vOK);
    Lib_GuiCom:Able($edLys.Mech.Sonstiges, vOK);
    
    if (Set.LyseErweitertYN) then begin
      Lib_GuiCom:Able($edLys.Bemerkung          ,vOK);
      Lib_GuiCom:Able($edLys.StreckgrenzeTyp    ,vOK);
      Lib_GuiCom:Able($edLys.StreckgrenzeQTyp   ,vOK);
      Lib_GuiCom:Able($edLys.StreckgrenzeQ1     ,vOK);
      Lib_GuiCom:Able($edLys.StreckgrenzeQ2     ,vOK);
      Lib_GuiCom:Able($edLys.ZugfestigkeitQ1    ,vOK);
      Lib_GuiCom:Able($edLys.ZugfestigkeitQ2    ,vOK);
      Lib_GuiCom:Able($edLys.DehnungQA          ,vOK);
      Lib_GuiCom:Able($edLys.DehnungQB          ,vOK);
      Lib_GuiCom:Able($edLys.DehnungQC          ,vOK);
      Lib_GuiCom:Able($edLys.HaerteTyp          ,vOK);
      Lib_GuiCom:Able($edLys.SGVerhaeltnis1     ,vOK);
      Lib_GuiCom:Able($edLys.SGVerhaeltnis2     ,vOK);
      Lib_GuiCom:Able($edLys.RauigkeitATyp      ,vOK);
      Lib_GuiCom:Able($edLys.RauigkeitBTyp      ,vOK);
      Lib_GuiCom:Able($edLys.RauigkeitCTyp      ,vOK);
      Lib_GuiCom:Able($edLys.RauigkeitC1        ,vOK);
      Lib_GuiCom:Able($edLys.RauigkeitC2        ,vOK);
      Lib_GuiCom:Able($edLys.CG1                ,vOK);
      Lib_GuiCom:Able($edLys.CG2                ,vOK);
      Lib_GuiCom:Able($edLys.FA1                ,vOK);
      Lib_GuiCom:Able($edLys.FA2                ,vOK);
      Lib_GuiCom:Able($edLys.PA1                ,vOK);
      Lib_GuiCom:Able($edLys.PA2                ,vOK);
      Lib_GuiCom:Able($edLys.CN1                ,vOK);
      Lib_GuiCom:Able($edLys.CN2                ,vOK);
      Lib_GuiCom:Able($edLys.CZ1                ,vOK);
      Lib_GuiCom:Able($edLys.CZ2                ,vOK);
      Lib_GuiCom:Able($edLys.ZE1                ,vOK);
      Lib_GuiCom:Able($edLys.ZE2                ,vOK);
      Lib_GuiCom:Able($edLys.HC                 ,vOK);
      Lib_GuiCom:Able($edLys.SS                 ,vOK);
      Lib_GuiCom:Able($edLys.OA                 ,vOK);
      Lib_GuiCom:Able($edLys.OS                 ,vOK);
      Lib_GuiCom:Able($edLys.OG                 ,vOK);
      Lib_GuiCom:Able($edLys.Parallelitaet      ,vOK);
      Lib_GuiCom:Able($edLys.Planlage           ,vOK);
      Lib_GuiCom:Able($edLys.Ebenheit           ,vOK);
      Lib_GuiCom:Able($edLys.Saebeligkeit       ,vOK);
      Lib_GuiCom:Able($edLys.SaebelProM         ,vOK);
    end;
    if (vOK) then begin
      CheckErweitertAnalyse('');
    end;
  end;


  if (aName='') or (aName='edBAG.FM.Verwiegungart') then begin
    Erx # RecLink(818,707,6,_recfirst);
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;
    $lb.Verwiegungsart->wpcaption # VWa.Bezeichnung.L1;
  end;


  if (aName='') then begin

    // Einsatz anzeigen
    $Lb.Guete.E->wpcaption      # "BAG.IO.Güte";
    $Lb.GuetenStufe.E->wpcaption # "BAG.IO.GütenStufe";
    $Lb.AusfOben.E->wpcaption   # BAG.IO.AusfOben;
    $Lb.AusfUnten.E->wpcaption  # BAG.IO.AusfUnten;
    $Lb.Struktur.E->wpcaption   # Mat.Strukturnr;
    $Lb.Dicke.E->wpcaption      # ANum(BAG.IO.Dicke,"Set.Stellen.Dicke");
    $Lb.Breite.E->wpcaption     # ANum(BAG.IO.Breite,"Set.Stellen.Breite");
    if (Abs("BAG.IO.Länge")>9999.99) then begin
      $lb.LenMEH_E->wpcaption    # 'm';
      $lb.LenMEH_FM_GEM->wpcaption # 'm';
      $Lb.Laenge.E->wpcaption   # ANum("BAG.IO.Länge"/1000.0,"Set.Stellen.Länge");
    end
    else begin
      $lb.LenMEH_E->wpcaption    # 'mm';
      $lb.LenMEH_FM_GEM->wpcaption # 'mm';
      $Lb.Laenge.E->wpcaption   # ANum("BAG.IO.Länge","Set.Stellen.Länge");
    end;
    $Lb.Dickentol.E->wpcaption  # BAG.IO.Dickentol;
    $Lb.Breitentol.E->wpcaption # BAG.IO.Breitentol;
    $Lb.Laengentol.E->wpcaption # "BAG.IO.Längentol";

    $Lb.Stueck.E->wpcaption     # AInt(BAG.IO.Plan.Out.Stk);
    vInGew  # BAG.IO.Plan.Out.GewB;

// LFA-Update vInMeng # BAG.IO.Plan.Out.Meng;
    vBuf701 # RekSave(701);
    BA1_F_Data:SumInput(BAG.F.MEH);
    vInME # BAG.IO.Plan.Out.Meng;
    RekRestore(vBuf701);

    if (BAG.IO.MEH.Out=BAG.F.MEH) then begin
      vOutME # BAG.IO.Ist.Out.Menge;
    end
    else begin
      vBuf707 # RekSave(707);
      Erx # RecLink(707,703,10,_RecFirst);    // Fertigmeldungen loopen
      WHILE (Erx<=_rLocked) do begin
        vOutME # vOutME + BAG.FM.Menge;
        Erx # RecLink(707,703,10,_recNext);
      END;
      RekRestore(vBuf707);
    end;

    $Lb.Gewicht.EIst->wpcaption # ANum(vInGew - BAG.IO.Ist.Out.GewB,"Set.Stellen.Gewicht");
    $Lb.Menge.EIst->wpcaption   # ANum(vInME  - vOutME,"Set.Stellen.Menge");

    // SCHOPF??
    if (BAG.F.AutomatischYN) and (BAG.F.Fertigung=999) then begin
      $Lb.Gewicht.EIst->wpcaption # ANum(BAG.IO.Plan.In.GewB   - BAG.IO.Ist.Out.GewB,"Set.Stellen.Gewicht");
//LFA-Update TODO  $Lb.Menge.EIst->wpcaption   # Cnvaf(BAg.IO.Plan.In.Menge  - BAG.IO.Ist.Out.Menge,0,0,"Set.Stellen.Menge");
      vInGew  # BAG.IO.Plan.In.GewB   - BAG.IO.Plan.Out.GewB;
      vInME   # BAG.IO.Plan.In.Menge  - BAG.IO.Plan.Out.Meng;
    end;
    $Lb.Gewicht.E->wpcaption    # ANum(vInGew,"Set.Stellen.Gewicht");
    $Lb.Menge.E->wpcaption      # ANum(vInME,"Set.Stellen.Menge");


    // geplant anzeigen
    $Lb.Guete.F->wpcaption      # "BAG.F.Güte";
    $Lb.GuetenStufe.F->wpcaption # "BAG.F.Gütenstufe";
    $Lb.AusfOben.F->wpcaption   # BAG.F.AusfOben;
    $Lb.AusfUnten.F->wpcaption  # BAG.F.AusfUnten;
    $Lb.Struktur.F->wpcaption   # BAG.F.ARtikelnummer;
    $Lb.Dicke.F->wpcaption      # ANum(BAG.F.Dicke,"Set.Stellen.Dicke");
    $Lb.Breite.F->wpcaption     # ANum(BAG.F.Breite,"Set.Stellen.Breite");
    if (Abs("BAG.F.Länge")>9999.99) then begin
      $lb.LenMEH_F->wpcaption    # 'm';
      $Lb.Laenge.F->wpcaption   # ANum("BAG.F.Länge"/1000.0,"Set.Stellen.Länge");
    end
    else begin
      $lb.LenMEH_F->wpcaption    # 'mm';
      $Lb.Laenge.F->wpcaption   # ANum("BAG.F.Länge","Set.Stellen.Länge");
    end;
    $Lb.Dickentol.F->wpcaption  # BAG.F.Dickentol;
    $Lb.Breitentol.F->wpcaption # BAG.F.Breitentol;
    $Lb.Laengentol.F->wpcaption # "BAG.F.Längentol";
    $Lb.Stueck.F->wpcaption     # AInt("BAG.F.Stückzahl");
    $Lb.Gewicht.F->wpcaption    # ANum(BAG.F.Gewicht,"Set.Stellen.Gewicht");
    $Lb.Menge.F->wpcaption      # ANum(BAG.F.Menge,"Set.Stellen.Menge");

    $lb.MEH_E->wpcaption    # BAG.F.MEH;
    $lb.MEH_F->wpcaption    # BAG.F.MEH;
    $lb.MEH_FM->wpcaption   # BAG.F.MEH;
    $lb.MEH_FIst->wpcaption # BAG.F.MEH;
    $lb.MEH_EIst->wpcaption # BAG.F.MEH;

    $Lb.Stueck.FIst->wpcaption   # AInt("BAG.F.Fertig.Stk");
    $Lb.Gewicht.FIst->wpcaption  # ANum(BAG.F.Fertig.Gew,"Set.Stellen.Gewicht");
    $Lb.Menge.FIst->wpcaption    # ANum(BAG.F.Fertig.Menge,"Set.Stellen.Menge");

    if (BAG.F.AuftragsNummer<>0) then begin
      $lb.Kommission->wpcaption # BAG.F.Kommission;
      $lb.Kommission2->wpcaption # BAG.F.Kommission;
      $lb.Kommission3->wpcaption # BAG.F.Kommission;
    end;

    // Warengruppe anzeigen
    $lb.Warengruppe->wpcaption # AInt(BAG.F.Warengruppe);
    $lb.Warengruppe2->wpcaption # AInt(BAG.F.Warengruppe);
    $lb.Warengruppe3->wpcaption # AInt(BAG.F.Warengruppe);
    Erx # RecLink(819,703,5,0);
    if (Erx<=_rLocked) then begin
      $Lb.WgrText->wpcaption # Wgr.Bezeichnung.L1
      $Lb.WgrText2->wpcaption # Wgr.Bezeichnung.L1
      $Lb.WgrText3->wpcaption # Wgr.Bezeichnung.L1
    end
    else begin
      $Lb.WgrText->wpcaption # '';
      $Lb.WgrText2->wpcaption # '';
      $Lb.WgrText3->wpcaption # '';
    end;

    // Kunde anzeigen
    Erx # _rOK;
    if ("BAG.F.ReservFürKunde"<>0) then
      Erx # RecLink(100,703,7,0);
    else
      RecBufClear(100);
    if (Erx<=_rLocked) then begin
      $Lb.Kunde->wpcaption # Adr.Stichwort
      $Lb.Kunde2->wpcaption # Adr.Stichwort
      $Lb.Kunde3->wpcaption # Adr.Stichwort
    end
    else begin
      $Lb.Kunde->wpcaption # '';
      $Lb.Kunde2->wpcaption # '';
      $Lb.Kunde3->wpcaption # '';
    end;

  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if ($cb.Analyse->wpCheckState=_WinStateChkChecked) then
    CheckErweitertAnalyse(aName);


  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  Erx     : int;
  vA      : alpha;
  vFM     : int;
  vBuf707 : int;
  vSeite  : alpha;
  vFilter : int;
  vNummer : int;
  vBuf705 : int;
  vHdl    : int;
  vTmp : int;

end;
begin

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  RunAFX('BA1_FM_Maske_Main_RecInit','');

  // ********************  Rechtecheck *********************************
  // Je nach Berechtigung können z.B. die Abmessungen eingegeben werden
  // oder nicht.
  begin
    if (Rechte[Rgt_BAG_FM_Brutto]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Gewicht.Brutt);

    if (Rechte[Rgt_BAG_FM_Netto]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Gewicht.Netto);

    if (Rechte[Rgt_BAG_FM_AF]=n) then begin
      Lib_GuiCom:Disable($edBAG.FM.AusfOben);
      Lib_GuiCom:Disable($edBAG.FM.AusfUnten);
    end;

    if (Rechte[Rgt_BAG_FM_ABM_D]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Dicke);

    if (Rechte[Rgt_BAG_FM_ABM_B]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Breite);

    if (Rechte[Rgt_BAG_FM_ABM_L]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Laenge);

    if(Rechte[Rgt_BAG_FM_Tara] = false) then
      Lib_GuiCom:Disable($edTara);

    if (Rechte[Rgt_Lys_Anlegen]=n) then
      Lib_GuiCom:Disable($cb.Analyse);

    // ST 2012-12-10: Neue Rechte für Reiter und weitere Felder laut 1433/15
    if (Rechte[Rgt_BAG_FM_Struktur]=n) then begin
      Lib_GuiCom:Disable($edBAG.FM.Artikelnr);
      Lib_GuiCom:Disable($bt.Struktur);
    end;

    if (Rechte[Rgt_BAG_FM_VerwiegArt]=n) then begin
      Lib_GuiCom:Disable($edBAG.FM.Verwiegungart);
      Lib_GuiCom:Disable($bt.Verwiegungsart);
    end;

    if (Rechte[Rgt_BAG_FM_NB_Mess]=n) then
      Lib_GuiCom:Disable($NB.Page2);

    if (Rechte[Rgt_BAG_FM_NB_Analyse]=n) then
      Lib_GuiCom:Disable($NB.Page3);

    if (Rechte[Rgt_BAG_FM_NB_Fehler]=n) then
      Lib_GuiCom:Disable($NB.Page4);

    if (Rechte[Rgt_BAG_FM_NB_Beistell]=n) then
      Lib_GuiCom:Disable($NB.Page5);

  end; // Rechtecheck


  // mit Analyse?
  if (BAG.P.Aktion=c_BAG_Check) and (Rechte[Rgt_Lys_Anlegen]) then begin
    $cb.Analyse->wpCheckState # _WinStateChkChecked;
    Refreshifm('cb.Analyse');
  end;


  // je nach Aktion Felder freischalten
  if (Mode=c_ModeNew) then begin
    BA1_FM_Data:Vorbelegen();
  end;


    // 2023-03-24 AH
  If (BAG.P.Aktion <> c_BAG_AbLaeng) and
    (BAG.P.Aktion<>c_BAG_Bereit) then begin
    Lib_GuiCom:disable($edBAG.FM.Menge);
  end;
  if (BAG.P.Aktion=c_BAG_Bereit) then begin
    Lib_GuiCom:able($edBAG.FM.Menge, (BAG.FM.MEH<>'Stk') and (BAG.FM.MEH<>'kg'));
  End;

  // ST 2012-11-30: Eingabefelder für GEwicht sperren,
  //                falls durch Betriebsmaske2 die automatische Berechnung aktiv ist
  vHdl # gMdi->winsearch('edGewichtBruttoOderNetto');
  if (vHdl > 0) then begin
    Lib_GuiCom:disable($edBAG.FM.Gewicht.Brutt);
    Lib_GuiCom:disable($edTara);
    Lib_GuiCom:disable($edBAG.FM.Gewicht.Netto);
  end;

  // Nachkommastellen setzen

  $edBAG.FM.Dicke.1->wpDecimals # "Set.Stellen.Dicke";
  $edBAG.FM.Dicke.2->wpDecimals # "Set.Stellen.Dicke";
  $edBAG.FM.Dicke.3->wpDecimals # "Set.Stellen.Dicke";
  $edBAG.FM.Breite.1->wpDecimals # "Set.Stellen.Breite";
  $edBAG.FM.Breite.2->wpDecimals # "Set.Stellen.Breite";
  $edBAG.FM.Breite.3->wpDecimals # "Set.Stellen.Breite";
  $edBAG.FM.Lnge.1->wpDecimals # "Set.Stellen.Länge";
  $edBAG.FM.Lnge.2->wpDecimals # "Set.Stellen.Länge";
  $edBAG.FM.Lnge.3->wpDecimals # "Set.Stellen.Länge";
/* Unbekannte Dezimalstellen
  $edBAG.FM.Rechtwinklig->wpDecimals # ;
  $edBAG.FM.Ebenheit->wpDecimals # ;
  $edBAG.FM.Sbeligkeit->wpDecimals # ;
*/


  // Focus setzen auf Feld:
  if (BAG.P.Aktion=c_BAG_Check) then begin
    vHdl # gMdi->Winsearch('NB.Main');
    vHdl->wpcurrent # 'NB.Page2';
    vTmp # gMdi->winsearch('edBAG.FM.Dicke.1');
  end
  else if (BAG.P.Aktion=c_BAG_Bereit) then begin
    vTmp # gMdi->winsearch('edBAG.FM.Lagerplatz');
  end
  else begin
    vTmp # gMdi->winsearch('edBAG.FM.Stck');
  end;

  vTmp->WinFocusSet(true);
  w_LastFocus # vTmp;
  Erx # gMdi->winsearch('DUMMYNEW');
  Erx->wpcustom # cnvai(vTmp);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vBuf703 : int;
  vErx    : int;
  vF      : float;
  vI      : int;
  vOK     : logic;

  vHdl    : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  if (Lib_Faktura:Abschlusstest(BAG.FM.Datum) = false) then begin
    Msg(001400 ,Translate('Fertigmeldungsdatum') + '|'+ CnvAd(BAG.FM.Datum),0,0,0);
    vHdl # gMdi->winsearch('edBAG.FM.Datum');
    if (vHdl > 0) then begin
      $NB.Main->wpcurrent # 'NB.Page1';
      vHdl->WinFocusSet(true);
    end;
    RETURN false;
  end;


  // ST 2022-02-28 2329/31: Stückzahl als Pflichtfeld
  if ($edBAG.FM.Stck <> 0) AND ("BAG.FM.Stück" <= 0) then begin
    Msg(001200,Translate('Stückzahl'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBAG.FM.Stck->WinFocusSet(true);
    RETURN false;
  end;

  // 30.11.2017 AH:
  if (BAG.FM.Gewicht.Brutt<>0.0) and (BAG.FM.Gewicht.Netto<>0.0) then begin
    if (BAG.FM.Gewicht.Netto > BAG.FM.Gewicht.Brutt) then begin
      Msg(001206,'',0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      vHdl # Winsearch(gMDI, 'edBAG.FM.Gewicht.Brutt');
      if (vHdl<>0) then vHdl->WinFocusSet(true);
      RETURN false;
    end;
  end;

  // logische Prüfung
  if (BAG.FM.Menge<=0.0) then begin
    Msg(001200,Translate('Menge'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBAG.FM.Menge->WinFocusSet(true);
    RETURN false;
  end;

  // Messwerterfassung prüfen
  case (Set.BA.FM.MWert.Chk) of
    // Bestimmte Felder müssen ausgefüllt sein
    'PFLICHT': begin
  //    todo('Pflichtfelder für die Überprüfung müssen noch irgendwo definiert werden können');
    end;

    // Die Maske der MEsserwerte muss zumindest angesehen worden sein
    'INFO':  begin
      if ($NB.Page2->wpCustom <> 'SEEN') then begin
        Msg(707006,'',0,0,0);
        RETURN false;
      end;
    end;

    // Keine Behandlung bei leerem Setting
    '': begin
    end
  end;


  // Messwerterfassung prüfen
  case (Set.BA.FM.Beist.Chk) of
    // Bestimmte Felder müssen ausgefüllt sein
    'PFLICHT': begin
  //    todo('Pflichtfelder für die Überprüfung müssen noch irgendwo definiert werden können');
    end;

    // Die Maske der MEsserwerte muss zumindest angesehen worden sein
    'INFO':  begin
      if ($NB.Page5->wpCustom <> 'SEEN') then begin
        Msg(707017,'',0,0,0);
        $NB.Main->wpcurrent # 'NB.Page5';
        $ZL.BA1.FM.Verbrauch->WinFocusSet(true);
        RETURN false;
      end;
    end;

    // Keine Behandlung bei leerem Setting
    '': begin
    end
  end;


  if ($cb.Analyse->wpcheckstate =_WinStateChkChecked) then begin
    vOK # (Lys.K.Bemerkung<>'') or (Lys.Mech.Sonstiges<>'');
    if (vOK=false) then begin
      FOR vI # 4 loop inc (vI) while (vI<=38) do begin
        if (vI<>28) then
          vF # vF + Fldfloat(231,1,vI);
      END;
      if (vF<>0.0) then vOK # y;
    end;
    if (vOk=false) then begin
      Msg(001200,Translate('Analyse'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page3';
      vHdl # Winsearch(gMdi, 'edLys.K.Bemerkung');
      if (vHdl=0) then
        vHdl # Winsearch(gMdi, 'edLys.Bemerkung');
      if (vHdl<>0) then vHdl->WinFocusSet(true);
      RETURN false;
    end;
  end;


  // fehlende Gewichte errechnen
  if ("Set.BA.FM.!CalcGewYN"=false) then begin
    if (BAG.FM.Gewicht.Brutt = 0.0) AND (BAG.FM.Gewicht.Netto <> 0.0) then
      BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto;

    if (BAG.FM.Gewicht.Brutt <> 0.0) AND (BAG.FM.Gewicht.Netto = 0.0) then
      BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt;
  end;

  If (BAG.P.Aktion = c_BAG_AbLaeng) then begin
    "BAG.F.Länge" # ((BAG.FM.Menge * 1000.0) / cnvFI("BAG.FM.Stück"));
  End;

  // Ankerfunktion
  if (RunAFX('BAG.FM.Recsave','')<>0) then begin
    if (AfxRes=111) then RETURN true;
    if (AfxRes<>_rOK) then RETURN false;
  end;


  // Nummernvergabe...
  // Fertigmeldung verbuchen
  if (BA1_Fertigmelden:Verbuchen(true, $cb.Analyse->wpCheckState=_WinStateChkChecked)=false) then begin
    Error(707002,'');
    ErrorOutput;
    RETURN false;
  end;

  Msg(707001,'',0,0,0);

/*
  ST 2021-10-01: AFx Aufruf jetzt nach "gSelected", damit im Anker
                ggf. entschieden werden  kann, ob nach der Fertigmeldung zurücl
                in die Betriebsmaske gesprungen werden soll
                 

  // Ankerfunktion für z.B. Prüfung ob ein Arbeitsgang "fertig" ist und dann
  // abgeschlossen werden kann
  RunAFX('BAG.FM.Verbuchen.Post','');
*/

  // sofort alles beenden!
  gSelected # 1;
  
  // Ankerfunktion für z.B. Prüfung ob ein Arbeitsgang "fertig" ist und dann
  // abgeschlossen werden kann
  RunAFX('BAG.FM.Verbuchen.Post','');
  
  if (BAG.P.Aktion=c_BAG_Bereit) then begin
    BA1_Fertigmelden:AbschlussPos(BAG.P.Nummer, BAG.P.Position, today, now, true);  // Silent !
    ErrorOutput;
    RETURN true;
  end;
  
  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
local begin
  Erx : int;
end;
begin

  Erx # RecLink(710,707,10,_recFirst);    // Fehler loopen
  WHILE (Erx<=_rLocked) do begin
    RekDelete(710,0,'MAN');
    Erx # RecLink(710,707,10,_recFirst);
  END;

  Erx # RecLink(708,707,12,_recFirst);    // Bewegungen loopen
  WHILE (Erx<=_rLocked) do begin
    RekDelete(708,0,'MAN');
    Erx # RecLink(708,707,12,_recFirst);
  END;

  Erx # RecLink(705,707,13,_recFirst);    // Ausführungen loopen
  WHILE (Erx<=_rLocked) do begin
    RekDelete(705,0,'MAN');
    Erx # RecLink(705,707,13,_recFirst);
  END;

  // ALLE Positionen verwerfen
  RETURN true;
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  vHdl : int;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  if (aEvt:obj->wpname='jump') then begin

    case (aEvt:Obj->wpcustom) of

      'Start' : begin

        vHdl # gMdi->winsearch('edBAG.FM.Datum');
        if (vHdl > 0) then
          $edBAG.FM.Datum->winfocusset(false);
        else begin
          // Falls abgespeckte Maske benutzt wird (*_Betrieb1),
          // dann auf Stückzahl springen, da es kein Datumsfeld gibt
          vHdl # gMdi->winsearch('edBAG.FM.Stck');
          if (vHdl > 0) then
            $edBAG.FM.Stck->winfocusset(false);
        end;

      end;

      'Ende' : begin
        $edBAG.FM.Bemerkung->winfocusset(false);
      end;

    end;

    RETURN true;
  end;


  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // neu zu fokusierendes Objekt
) : logic
local begin
  Erx   : int;
  vS    : int;
  vHdl : int;
  vTmp : alpha;
end;
begin

  // Ankerfunktion
  if (RunAFX('BAG.FM.MaskEvtFocusTerm',Aint(aEvt:Obj) + '|' + Aint(aFocusObject)) <>0) then begin
    if (AfxRes<>_rOK) then
      RETURN false;
    else
      RETURN true;
  end;


  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);


  if (aEvt:Obj=0) then RETURN true;

  vS # WinInfo(aEvt:Obj,_Wintype);
  if ((vS=_WinTypeEdit) or (vS=_WinTypeFloatEdit) or (vS=_WinTypeIntEdit)) then

    if (aEvt:obj->wpchanged) then begin
      Erx # RecLink(818,707,6,_recfirst);     // Verwiegungsart holen
      if (Erx>_rLocked) then begin
        RecBufClear(818);
        VWa.NettoYN # Y;
      end;


      // ST 2012-11-30: Spezialfall, wenn das Gewichtsfeld für "Netto oder Brutto" vorhanden ist,
      //                dann werden die Gewicht anhand der Verwieungsart berechnet und in die
      //                deaktivierten Gewichts Felder geschrieben
      vHdl # gMdi->winsearch('edGewichtBruttoOderNetto');
      if (aEvt:Obj->wpname = 'edGewichtBruttoOderNetto') and (vHDL > 0) then begin

        BAG.FM.Gewicht.Netto # $edGewichtBruttoOderNetto->wpcaptionfloat;
        BAG.FM.Gewicht.Brutt # $edGewichtBruttoOderNetto->wpcaptionfloat;

        // Verpackung für Tara lesen
        // Fertigung ist gelesen
        RekLink(704,703,6,0);   // Verpackung lesen
        if (VWa.BruttoYN) then
          BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt - BAG.Vpg.Nettoabzug;

        if (VWa.NettoYN) then
          BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto + BAG.Vpg.Nettoabzug;

        $edBAG.FM.Gewicht.Brutt->winupdate(_WinUpdFld2Obj);
        $edBAG.FM.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
        $edTara->wpcaptionfloat # BAG.FM.Gewicht.Brutt - BAG.FM.Gewicht.Netto;

      end
      else begin

        // ST 2010-04-16: 1269/7 Korrektur der Gewichtseingabe

        // Verwiegungsart Brutto
        if (VWa.BruttoYN) then begin
          // Änderung bei Bruttogewicht oder Tara: Netto neuberechnen
          if (aEvt:Obj->wpname = 'edBAG.FM.Gewicht.Brutt') or (aEvt:Obj->wpname = 'edTara') or
           (aEvt:Obj->wpname = 'edBAG.FM.Stck') then
            BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt - $edTara->wpcaptionfloat;

          // Tara errechnen
          if (aEvt:Obj->wpname = 'edBAG.FM.Gewicht.Netto') or
           (aEvt:Obj->wpname = 'edBAG.FM.Stck') then
            $edTara->wpcaptionfloat # BAG.FM.Gewicht.Brutt - BAG.FM.Gewicht.Netto;
        end; // VWA Brutto?

        // Verwiegungsart Netto
        if (VWa.NettoYN) then begin
          // Änderung bei Netto oder Tara: Brutto neuberechnen
          if (aEvt:Obj->wpname = 'edBAG.FM.Gewicht.Netto') or (aEvt:Obj->wpname = 'edTara') or
           (aEvt:Obj->wpname = 'edBAG.FM.Stck') then
            BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto + $edTara->wpcaptionfloat;

          // Tara errechnen
          if (aEvt:Obj->wpname = 'edBAG.FM.Gewicht.Brutt') or (aEvt:Obj->wpname = 'edBAG.FM.Stck') then
            $edTara->wpcaptionfloat # BAG.FM.Gewicht.Brutt - BAG.FM.Gewicht.Netto;
        end; // VWA Netto?

        // Gewichtswerte refreshen
        $edBAG.FM.Gewicht.Brutt->winupdate(_WinUpdFld2Obj);
        $edBAG.FM.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
      end; // Ende ST 2010-04-16: 1269/7 Korrektur der Gewichtseingabe


      case (aEvt:Obj->wpname) of

        'edBAG.FM.Gewicht.Netto' : begin
          if ("BAG.FM.Stück"=0) then begin
            RecLink(819,703,5,_recFirst);   // Warengruppe holen
            "BAG.FM.Stück" # Lib_Berechnungen:Stk_aus_kgDBLDichte2(BAG.FM.Gewicht.Netto, BAG.FM.Dicke, BAG.FM.Breite, "BAG.FM.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 707), "Wgr.TränenKgProQM");
            vS # "BAG.FM.Stück";
            $edBAG.FM.Stck->winupdate(_WinUpdFld2Obj);
          end;
        end;


        'edBAG.FM.Gewicht.Brutt' : begin
          if ("BAG.FM.Stück"=0) then begin
            RecLink(819,703,5,_recFirst);   // Warengruppe holen
            "BAG.FM.Stück" # Lib_Berechnungen:Stk_aus_kgDBLDichte2(BAG.FM.Gewicht.Netto, BAG.FM.Dicke, BAG.FM.Breite, "BAG.FM.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 707), "Wgr.TränenKgProQM");
            vS # "BAG.FM.Stück";
            $edBAG.FM.Stck->winupdate(_WinUpdFld2Obj);
          end;
        end;


        'edBAG.FM.Stck' : begin
          Erx # RecLink(818,707,6,_recfirst);
          if (Erx>_rLocked) then begin
            RecBufClear(818);
            VWa.NettoYN # Y;
          end;
          RecLink(819,703,5,_recFirst);   // Warengruppe holen
          if ("Set.BA.FM.!CalcGewYN"=false) then begin
            if (BAG.FM.Gewicht.Netto=0.0) and (VWa.BruttoYN=false) then begin

              // Ablängen über ARtikel rechnen...
              if (BAG.F.Artikelnummer<>'') and (BAG.P.Aktion=c_BAG_Ablaeng) then begin
                Erx # RecLink(250,703,13,_recFirst);    // Artikel holen
                if (Erx<=_rLocked) and ("Art.GewichtProm"<>0.0) then begin
                  BAG.FM.Gewicht.Netto # "Art.GewichtProm" / 1000.0 * "BAG.FM.Länge" * cnvfi("BAG.FM.Stück");
                end;
              end;

              if (BAG.FM.Gewicht.Netto=0.0) then
                BAG.FM.Gewicht.Netto # Lib_Berechnungen:kg_aus_StkDBLDichte2("BAG.FM.Stück", BAG.FM.Dicke, BAG.FM.Breite, "BAG.FM.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 707), "Wgr.TränenKgProQM");

              // oder Artikelstammdaten?
              if (BAG.FM.Gewicht.Netto=0.0) and (BAG.F.Artikelnummer<>'') then begin
                Erx # RecLink(250,703,13,_recFirst);    // Artikel holen
                if (Erx<=_rLocked) and ("Art.GewichtProm"<>0.0) then begin
                  BAG.FM.Gewicht.Netto # "Art.GewichtProm" / 1000.0 * "BAG.FM.Länge" * cnvfi("BAG.FM.Stück");
                end;
              end;


              BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto + $edTara->wpcaptionfloat;
              $edBAG.FM.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
              $edBAG.FM.Gewicht.Brutt->winupdate(_WinUpdFld2Obj);
            end;
            if (BAG.FM.Gewicht.Brutt=0.0) and (VWa.NettoYN=false) then begin

              // Ablängen über ARtikel rechnen...
              if (BAG.F.Artikelnummer<>'') and (BAG.P.Aktion=c_BAG_Ablaeng) then begin
                Erx # RecLink(250,703,13,_recFirst);    // Artikel holen
                if (Erx<=_rLocked) and ("Art.GewichtProm"<>0.0) then begin
                  BAG.FM.Gewicht.Brutt # "Art.GewichtProm" / 1000.0 * "BAG.FM.Länge" * cnvfi("BAG.FM.Stück");
                end;
              end;

              if (BAG.FM.Gewicht.Brutt=0.0) then
                BAG.FM.Gewicht.Brutt # Lib_Berechnungen:kg_aus_StkDBLDichte2("BAG.FM.Stück", BAG.FM.Dicke, BAG.FM.Breite, "BAG.FM.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 707), "Wgr.TränenKgProQM");

              // oder Artikelstammdaten?
              if (BAG.FM.Gewicht.Brutt=0.0) and (BAG.F.Artikelnummer<>'') then begin
                Erx # RecLink(250,703,13,_recFirst);    // Artikel holen
                if (Erx<=_rLocked) and ("Art.GewichtProm"<>0.0) then begin
                  BAG.FM.Gewicht.Brutt # "Art.GewichtProm" / 1000.0 * "BAG.FM.Länge" * cnvfi("BAG.FM.Stück");
                end;
              end;
              BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt - $edTara->wpcaptionfloat;
              $edBAG.FM.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
              $edBAG.FM.Gewicht.Brutt->winupdate(_WinUpdFld2Obj);
            end;
          end;
        end;
      end;  // case

      vHdl # $edBAG.FM.Menge;
      if (vHdl<>0) and (vHdl->wpreadonly) then
        _CalcMenge();
      If ((BAG.P.Aktion <> c_BAG_AbLaeng) and (BAG.P.Aktion <> c_BAG_Bereit))
        or (BAG.FM.Menge =0.0) then begin
        _CalcMenge();
      End
      else begin
//        $edBAG.F.Laenge->wpcaptionfloat # ((BAG.FM.Menge * 1000.0) / cnvFI("BAG.FM.Stück"));
      end;

      $edBAG.FM.Menge->winupdate(_WinUpdFld2Obj);

  end; // Ende Changed

  RETURN true;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  Erx     : int;
  vA      : alpha;
  vFilter : int;
  vTmp    : int;
  vQ      : alpha(4000);
  vSel    : int;
end;

begin

  case aBereich of


    'AF.Oben'        : begin
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung','BA1_FM_Maske_Main:AusAFOben');
/**
      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, myTmpNummer);// BAG.FM.Nummer); 20.05.2015
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.FM.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.FM.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, BAG.FM.Fertigmeldung);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '1');
      $ZL.BA1.AF->wpDbFilter # vFilter;
**/
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, 'BAG.AF.Nummer'  , '=', BAG.FM.Nummer);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Position'  , '=', BAG.FM.Position);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Fertigung'  , '=', BAG.FM.Fertigung);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Fertigmeldung'  , '=', BAG.FM.Fertigmeldung);
      Lib_Sel:QAlpha(var vQ, 'BAG.AF.Seite'  , '=', '1');
      vTmp # SelCreate(705, gkey);
      Erx # vTmp->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vTmp);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vTmp,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vTmp;


      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.Position)+'|'+
        AInt(BAG.FM.Fertigung) + '|' + AInt(BAG.FM.Fertigmeldung) + '|1';

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AF.Unten'       : begin
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung','BA1_FM_Maske_Main:AusAFUnten');
/**
      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, myTmpNummer);//BAG.FM.Nummer); 20.05.2015
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.FM.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.FM.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, BAG.FM.Fertigmeldung);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '2');
**/
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, 'BAG.AF.Nummer'  , '=', BAG.FM.Nummer);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Position'  , '=', BAG.FM.Position);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Fertigung'  , '=', BAG.FM.Fertigung);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Fertigmeldung'  , '=', BAG.FM.Fertigmeldung);
      Lib_Sel:QAlpha(var vQ, 'BAG.AF.Seite'  , '=', '2');
      vTmp # SelCreate(705, gkey);
      Erx # vTmp->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vTmp);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vTmp,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vTmp;


      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.Position)+'|'+
        AInt(BAG.FM.Fertigung) + '|' + AInt(BAG.FM.Fertigmeldung) + '|2';

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Struktur' : begin
      Erx # RecLink(819,703,5,0);   // Warengruppe holen
      if (Erx>_rLocked) then RecBufClear(819);
      if (Wgr_Data:IstMix()) then begin
        RecBufClear(250);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
        Lib_GuiCom:RunChildWindow(gMDI);
      end
      else begin
        RecBufClear(220);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusStruktur');
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Verwiegungsart' : begin
      RecBufClear(818);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VwA.Verwaltung',Here+':AusVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lagerplatz' : begin
      RecBufClear(844);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',Here+':AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
begin

  // gesamtes Fenster aktivieren
  //Lib_GuiCom:SetWindowState(cDialog,true);
  gSelected # 0;

  BAG.FM.AusfOben # Obf_Data:BildeAFString(707,'1');

  // Focus auf Editfeld setzen:
  $edBAG.FM.AusfOben->Winfocusset(true);
end;


//========================================================================
//  AusAFUnten
//
//========================================================================
sub AusAFUnten()
begin
  // gesamtes Fenster aktivieren
  //Lib_GuiCom:SetWindowState(cDialog,true);
  gSelected # 0;

  BAG.FM.AusfUnten # Obf_Data:BildeAFString(707,'2');

  // Focus auf Editfeld setzen:
  $edBAG.FM.AusfUnten->Winfocusset(true);
end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.FM.Artikelnr       # Art.Nummer;
  end;
  // Focus setzen:
  $edBAG.FM.Artikelnr->Winfocusset(false);
end;


//========================================================================
//  AusStruktur
//
//========================================================================
sub AusStruktur()
begin
  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.FM.Artikelnr # MSL.Strukturnr;
  end;
  // Focus setzen:
  $edBAG.FM.Artikelnr->Winfocusset(false);
end;


//========================================================================
//  AusVerwiegungsart
//
//========================================================================
sub AusVerwiegungsart()
begin

  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);

  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    gSelected # 0;
    BAG.FM.Verwiegungart # VWA.Nummer;
  end;

  // Focus auf Editfeld setzen:
  $edBAG.FM.Verwiegungart->Winfocusset(true);
end;


//========================================================================
//  AusLagerplatz
//
//========================================================================
sub AusLagerplatz()
begin

  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);

  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    gSelected # 0;
    BAG.FM.Lagerplatz # Lpl.Lagerplatz;
  end;

  // Focus auf Editfeld setzen:
  $edBAG.FM.Lagerplatz->Winfocusset(true);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);


  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

  vHdl # gMdi->WinSearch('bt.AusfOben');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_AF]=n);

  vHdl # gMdi->WinSearch('bt.AusfUnten');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_AF]=n);

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vHdl : int;
  vTmp : int;

  vTxt : alpha(1000);
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Waage'       :   Wiegedaten();

    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edBAG.FM.Stck') then begin
        "BAG.FM.Stück" # Lib_Berechnungen:STK_aus_KgDBLWgrArt(BAG.FM.Gewicht.Netto, BAG.FM.Dicke, BAg.FM.Breite, "BAG.FM.länge", Bag.F.Warengruppe, "BAG.F.Güte", Bag.F.Artikelnummer);
        $edBAG.FM.Stck->winupdate(_WinUpdFld2Obj);
      end;
    end;


  end; // case

end;


//========================================================================
// IsPageActive
//========================================================================
Sub IsPageActive(aName : alpha) : logic;
begin
  RETURN aName<>'NB.Page4' and  aName<>'NB.Page5';
end


//========================================================================
//  Wiegedaten
//          Liest Wiegedaten aus Datei ein
//========================================================================
sub Wiegedaten()
local begin
end;
begin
  RunAFX('BAG.Waage','');
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Verwiegungsart' :   Auswahl('Verwiegungsart');
    'bt.Lagerplatz'     :   Auswahl('Lagerplatz');
    'bt.Struktur'       :   Auswahl('Struktur');
    'bt.AusfOben'       :   Auswahl('AF.Oben');
    'bt.AusfUnten'      :   Auswahl('AF.Unten');
    'bt.Waage'          :   Wiegedaten();
  end;

end;

//========================================================================
//  EvtPageSelect
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin
  // Merken, dass Page 2 angesehen wurde
  if (aPage->wpname='NB.Page2' ) then
    $NB.Page2->wpCustom # 'SEEN';
  if (aPage->wpname='NB.Page5' ) then
    $NB.Page5->wpCustom # 'SEEN';
  RETURN true;
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cb.gesperrt') and ($cb.gesperrt->wpCheckState=_WinStateChkChecked) then begin
    $cb.Ausfall->wpCheckState # _WinStateChkunChecked;
    BAG.FM.Status # c_Status_BAGfertSperre;
  end;
  if (aEvt:Obj->wpname='cb.Ausfall') and ($cb.Ausfall->wpCheckState=_WinStateChkChecked) then begin
    $cb.gesperrt->wpCheckState # _WinStateChkunChecked;
    BAG.FM.Status # c_Status_BAGAusfall;
  end;
  if ($cb.gesperrt->wpCheckState=_WinStateChkUnChecked) and
    ($cb.Ausfall->wpCheckState=_WinStateChkUnChecked) then begin
    BAG.FM.Status # c_Status_Frei;
  end;

  if (aEvt:Obj->wpname='cb.Analyse') then begin
    if ($cb.Analyse->wpCheckState<>_WinStateChkChecked) then begin
      RecBufClear(230);
      RecBufClear(231);
      gMDI->winupdate();
    end;
    RefreshifM(aEvt:Obj->wpname);
  end;

  RunAFX('BA1.FM.Maske.EvtChanged.Post',aint(aEvt:Obj));

  RETURN true;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
begin
//  Refreshmode(y);
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
begin
  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin
  
  if ((aName =^ 'edBAG.FM.Artikelnr') AND (aBuf->BAG.FM.Artikelnr<>'')) then begin
    Art.Nummer # BAG.FM.Artikelnr;
    RecRead(250,1,0);
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.FM.Verwiegungart') AND (aBuf->BAG.FM.Verwiegungart<>0)) then begin
    RekLink(818,707,6,0);   // Verwigungsart holen
    Lib_Guicom2:JumpToWindow('VwA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.FM.Lagerplatz') AND (aBuf->BAG.FM.Lagerplatz<>'')) then begin
    LPl.Lagerplatz # BAG.FM.Lagerplatz;
    RecRead(844,1,0);
    Lib_Guicom2:JumpToWindow('LPl.Verwaltung');
    RETURN;
  end;
  
  
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================