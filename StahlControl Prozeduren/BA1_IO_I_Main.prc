@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_IO_I_Main
//                OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  03.06.2009  TM  Gütenstufen eingefügt
//  28.09.2009  TM  Neuberechnung der Einsatzfertigungsmenge per Kontextmenü
//  07.10.2009  MS  bei Einsatz Weiterbearbeitung direkt die Auswahl der Weiterbearbeitungen anzeigen
//  15.10.2009  AI  Spulen
//  27.01.2010  AI  Autoteilung rechnet nach Neuanlage/Ändern vom Input
//  17.02.2010  AI  Reservierungübernahme Einsatz->Verwiegung
//  18.03.2010  MS  Funktionalitaet der RecDel in Funktionen ausgelagert (BA1_IO_I_Data)
//  15.06.2011  ST  Button für Zusatztext hinzugefügt
//  16.11.2011  AI  Lageradresse bei Weiterbearbeitung vererben
//  13.02.2012  AI  bei Drag&Drop werden gleiche Materialbedingungen geprüft wie bei Neuanlage
//  14.03.2012  AI  Materialstatusprüfung bei Drag&Drop
//  16.03.2012  AI  Einsatz in VK-Fahren MUSS kommissioniert sein + Mat.Auftragsnr wird in IO übernommen
//  22.03.2012  AI  Einsatz in VK-Fahren MUSS gleichen Kunden haben wie andere Einsätze
//  22.05.2012  AI  Löschen von Weiterberarbeitungen-Einsatz sperrt ggf. vorherige Verwiegungen
//  09.07.2012  AI  Ringlänge anhand der Feritung ermitteln bei 1zu1 Prj 1326/258
//  30.07.2012  ST  Einsatztyp "Weiterbearb." Vorgänger darf nur aus eigenem BA sein, Feldsperrung (Prj. 1334/133)
//  16.08.2012  AI  "RecSave" bei Weiterbearbeitung addier Planmengen
//  18.02.2013  AI  in der Combo.RecList RL.BA1.Input Flag entfernt: _WinLstRecFocusTermReset
//  13.03.2013  AI  Bugfix: RecSave errechnet Planmengen selber nicht, da wo anderes gerechnet wird (Proj.1326/334)
//  19.04.2013  AI  FM.I.Auswahl zeigt INPUT an, nicht mehr Output
//  02.07.2013  AH  "RecDel" Bugfix
//  02.07.2013  AH  Eingabefeld/Barcode beim Auswahl vom Einsatzmaterial
//  25.11.2013  AH  "Switchmask": bei Einsatzartikel Verfügbarmengen korrigieren, wenn BA.Pos schon gelöscht ist
//  22.05.2014  AH  Fahren nimmt Mat.MEH als MEH und NICHT über ErmittleMEH
//  10.03.2015  AH  AFX "BAG.IO.IN.RecSave" aus Drag&Drop entfernt!!! -> neue Anker in BA1_F_Data:Replace/Insert
//  01.03.2016  ST  Kontextmenü "Berechnen" für Theoretische Einsatzstück Projekt 1594/10 WSB
//  19.10.2016  AH  "AuswahlEvtInit", "AuswahlEvtClose" zum Merken der Zugrifflsite
//  17.01.2018  ST  Arbeitsgang "Umlagern" hinzugefügt
//  30.05.2018  AH  AFX "BAG.IO.In.Auswahl"
//  29.06.2018  AH  Neu: bei Lohn: Filter auf Lieferant/Kunde bei Materialauswahl
//  24.10.2018  AH  Neu: Menü "markiertes Mat. einfügen"
//  09.12.2019  AH  AFX "BAG.IO.I.AuswahlEvtInit.Pre"
//  21.07.2020  ST  AFX: "BA1.IO.I.AW.LstDInit"
//  11.10.2021  AH  ERX
//  02.05.2022  AH  Multieinsatz kann auch Stück aus Gewicht errechnen
//  2022-12-19  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB getRinglRad(aMaxRID : float);
//    SUB SwitchMask();
//    SUB Pflichtfelder();
//    SUB RefreshIfm(opt aName : alpha; opt aChanged : logic);
//    SUB RecInit();
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusMaterial()
//    SUB AusMaterialVSB
//    SUB AusMarkMaterial()
//    SUB AusArtikel_Art()
//    SUB AusCharge()
//    SUB AusArtikel_Theo()
//    SUB AusZustand()
//    SUB AusWgr()
//    SUB AusGuete()
//    SUB AusGuetenStufe()
//    SUB AusLager()
//    SUB AusAnschrift()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    sub AuswahlEvtInit...
//    sub AuswahlEvtClose...
//    SUB AuswahlEvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB AuswahlEvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstRecControl(aEvt : event; aRecID : int) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtDropEnter(aEvt : event; aDataObject : int; aEffect : int) : logic
//    SUB EvtDrop(aEvt : event;	aDataObject : int; aDataPlace : int; aEffect : int; aMouseBtn : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtLstEditFinished(aEvt : event; aColumn : int; aKey : int; aRecID : int; aChanged : logic) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen
@I:Def_BAG

define begin
//  cDialog :   $BA1.IO.I.Verwaltung
//  cDialog :   $BA1.Combo.Verwaltung 19.05.2022 AH wird ja auch von Custom Combos benutzt!!!
  cTitle :    'Einsatzmaterial'
  cFile :     701
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'BA1_IO_I'
  cZList :    $RL.BA1.Input
  cKey :      1
  cZList1 :   $RL.BA1.Pos
  cZList2 :   $RL.BA1.Input
  cZList3 :   $RL.BA1.Fertigung
  cZList4 :   $RL.BA1.Output
end;

declare Auswahl(aBereich : alpha)

//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
end;
begin

  if (w_Child=0) then begin
    // Datei spezifische Vorgaben
    gTitle  # Translate(cTitle);
    gFile   # cFile;
    gFrmMain->wpMenuname # cMenuName;    // Menü setzen
    gPrefix # cPrefix;
    gZLList # cZList;
    gKey    # cKey;
    gMenu # gFrmMain->WinInfo(_WinMenu);

  end;

  Call('App_Main:EvtMdiActivate',aEvt);

end;


//========================================================================
// getRinglRad
// MS (02.07.2009) errechnet Ringlänge und RAD und setzt die Labels
//                 + sucht min/max RAD und setzt die Labels
//========================================================================
sub getRinglRad();
local begin
  Erx               : int;
  vD,vB,vL          : float;
  vRAD              : float;
  vMaxRAD           : float;
  vMinRAD           : float;
  vMaxFertigungsRID : float;
end;
begin

  $lb.IO.RADInfo_Mat ->wpcaption # '';
  $lb.IO.RADInfo_BAG ->wpcaption # '';
  $lb.IO.RADInfo_VSB ->wpcaption # '';
  $lb.IO.RADInfo_Theo->wpcaption # '';

  // RID anzeigen
  vMaxFertigungsRID # BA1_IO_Data:MaxFertigungsRID();
  if (vMaxFertigungsRID <> 0.0) then begin

    vRAD # Lib_berechnungen:RAD_aus_KgStkBDichteRIDTlg(BAG.IO.Plan.Out.GewN, BAG.IO.Plan.Out.Stk, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), vMaxFertigungsRID, BAG.IO.Teilungen)
    $lbRAD_Mat ->wpcaption # ANum(vRAD, Set.Stellen.Radien);
    $lbRAD_BAG ->wpcaption # ANum(vRAD, Set.Stellen.Radien);
    $lbRAD_VSB ->wpcaption # ANum(vRAD, Set.Stellen.Radien);
    $lbRAD_Theo->wpcaption # ANum(vRAD, Set.Stellen.Radien);
    if((vRAD < vMinRad) or ((vRAD > vMaxRad) and (vMaxRad > 0.0))) and ((vMinRAD <> 0.0) or (vMaxRAD <> 0.0)) then begin
      $lbRAD_Mat ->wpColBkg # _WinColLightRed;
      $lbRAD_BAG ->wpColBkg # _WinColLightRed;
      $lbRAD_VSB ->wpColBkg # _WinColLightRed;
      $lbRAD_Theo->wpColBkg # _WinColLightRed;
    end
    else begin
      $lbRAD_Mat ->wpColBkg # _WinColParent;
      $lbRAD_BAG ->wpColBkg # _WinColParent;
      $lbRAD_VSB ->wpColBkg # _WinColParent;
      $lbRAD_Theo->wpColBkg # _WinColParent;
    end;
  end
  else begin
    $lbRAD_Mat ->wpcaption # '0.0';
    $lbRAD_BAG ->wpcaption # '0.0';
    $lbRAD_VSB ->wpcaption # '0.0';
    $lbRAD_Theo->wpcaption # '0.0';

    $lb.IO.RADInfo_Mat->wpcaption # 'Kein RID in Fertigung definiert!';
    $lb.IO.RADInfo_Mat->wpColFg # _WinColLightRed;
    $lb.IO.RADInfo_BAG->wpcaption # 'Kein RID in Fertigung definiert!';
    $lb.IO.RADInfo_BAG->wpColFg # _WinColLightRed;
    $lb.IO.RADInfo_VSB->wpcaption # 'Kein RID in Fertigung definiert!';
    $lb.IO.RADInfo_VSB->wpColFg # _WinColLightRed;
    $lb.IO.RADInfo_Theo->wpcaption # 'Kein RID in Fertigung definiert!';
    $lb.IO.RADInfo_Theo->wpColFg # _WinColLightRed;
  end;


  // RAD anzeigen
  BA1_IO_Data:MinMaxFertigungsRAD(var vMinRAD, var vMaxRAD, vMaxFertigungsRID);
  if(vMinRAD <> 0.0)  then begin
    $lbRADmin_Mat ->wpcaption # ANum(vMinRAD,-1);
    $lbRADmin_BAG ->wpcaption # ANum(vMinRAD,-1);
    $lbRADmin_VSB ->wpcaption # ANum(vMinRAD,-1);
    $lbRADmin_Theo->wpcaption # ANum(vMinRAD,-1);
  end
  else begin
    $lbRADmin_Mat ->wpcaption # '0,00';
    $lbRADmin_BAG ->wpcaption # '0,00';
    $lbRADmin_VSB ->wpcaption # '0,00';
    $lbRADmin_Theo->wpcaption # '0,00';
  end;

  if(vMaxRAD <> 0.0) then begin
    $lbRADmax_Mat ->wpcaption # ANum(vMaxRAD,-1);
    $lbRADmax_BAG ->wpcaption # ANum(vMaxRAD,-1);
    $lbRADmax_VSB ->wpcaption # ANum(vMaxRAD,-1);
    $lbRADmax_Theo->wpcaption # ANum(vMaxRAD,-1);
  end
  else begin
    $lbRADmax_Mat ->wpcaption # '0,00';
    $lbRADmax_BAG ->wpcaption # '0,00';
    $lbRADmax_VSB ->wpcaption # '0,00';
    $lbRADmax_Theo->wpcaption # '0,00';
  end;

  // 09.07.2012 AI
  if ("BAG.P.Typ.1In-1OutYN") then begin
    Erx # RecLink(703,702,4,_RecFirst); // 1. FErtigung holen
    if (Erx<=_rLocked) then begin
      vD # BAG.F.Dicke;
      vB # BAG.F.Breite;
      vL # "BAG.F.Länge";
    end;
  end;
  if (vD=0.0) then vD # BAG.IO.Dicke;
  if (vB=0.0) then vB # BAG.IO.Breite;
  if (vL=0.0) then begin
    vL # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, BAG.IO.PLan.Out.Stk, vD, vB, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM") / 1000.0;
  end;
  $lbRinglaenge_Mat ->wpcaption  # ANum(vL / (cnvFI(BAG.IO.Teilungen) + 1.0) , 1);
  $lbRinglaenge_BAG ->wpcaption  # ANum(vL / (cnvFI(BAG.IO.Teilungen) + 1.0) , 1);
  $lbRinglaenge_VSB ->wpcaption  # ANum(vL / (cnvFI(BAG.IO.Teilungen) + 1.0) , 1);
  $lbRinglaenge_Theo->wpcaption  # ANum(vL / (cnvFI(BAG.IO.Teilungen) + 1.0) , 1);

end;


//========================================================================
// sub IstUmlagerEinsatzDoppelt() : logic
//  Prüft ob zu dem aktuellen BA Einsatz schon Einsätze mit der gleichen
//  Materialnummer hinterlegt sind
//========================================================================
sub IstUmlagerEinsatzDoppelt(aMatNr : int) : logic
local begin
  Erx             : int;
  vBuf701         : int;
  vEinsatzDoppelt : logic;
end
begin
  vBuf701 # RecBufCreate(701);
  vEinsatzDoppelt  # false;
  FOR   Erx # RecLink(vBuf701,702,2,_RecFirst)
  LOOP  Erx # RecLink(vBuf701,702,2,_RecNext)
  WHILE (Erx <= _rLocked) DO BEGIN
    if (vBuf701->Bag.IO.Materialnr = aMatNr) then begin
      vEinsatzDoppelt # true;
      BREAK;
    end;
  END;
  vBuf701->RecBufDestroy();
  RETURN vEinsatzDoppelt;
end;


/*========================================================================
2023-01-27  AH
========================================================================*/
sub ToggleLine(
  aDL   : int;
  aID   : int)
local begin
  vStk    : int;
  vGew    : float;
  Erx     : int;
end;
begin
  // nur 1 Stück möglich...
  aDL->WinLstCellGet(vStk, 12, aID);
  if (vStk>0) then vStk # 0
  else begin
    aDL->WinLstCellGet(vStk, 9, aID);
  end;
  aDL->WinLstCellSet(vStk, 12, aID);

  // Gewicht errechnen...
  aDL->WinLstCellGet(BAG.IO.ID,1, aID);
  BAG.IO.Nummer # BAG.P.Nummer;
  Erx # RecRead(701,1,0);   // Einsatz holen
  if (Erx<=_rLocked) then begin
    if (BAG.IO.Plan.Out.Stk<>0) then begin
      vGew # BAG.IO.Plan.Out.GewN * cnvfi(vStk) / cnvfi(BAG.IO.Plan.Out.Stk);
      aDL->WinLstCellSet(vGew,13,  aID);
      vGew # BAG.IO.Plan.Out.GewB * cnvfi(vStk) / cnvfi(BAG.IO.Plan.Out.Stk);
      aDL->WinLstCellSet(vGew,14,  aID);
    end;
  end;
end;


//========================================================================
// SwitchMask
//
//========================================================================
SUB SwitchMask();
local begin
  Erx     : int;
  vPage   : alpha;
  vOK     : logic;
  vGew    : float;
  vResYN  : logic;
  vTmp    : int;
end;
begin

  vPage # 'nb.Page0';

  // Material...
  if (BAG.IO.MaterialTyp=c_IO_Mat) then begin

    vPage # 'nb.Page200';

    Mat_Data:Read(BAG.IO.Materialnr); // Einsatzmaterial holen

    if (RecLinkInfo(203,200,13,_recCount)>0) then vResYN # y;

    $lb.IO.Chargennummer_Mat->wpCaption # Mat.Chargennummer;
    $lb.IO.Ringnummer_Mat->wpCaption    # Mat.Ringnummer
    $lb.IO.Wgr_Mat->wpcaption           # AInt(BAG.IO.Warengruppe);
    $lb.IO.Guete_Mat->wpcaption         # "BAG.IO.Güte";
    $lb.IO.GuetenStufe_Mat->wpcaption   # "BAG.IO.GütenStufe";
    $lb.IO.Dicke_Mat->wpcaption         # ANum(BAG.IO.Dicke, Set.Stellen.Dicke);
    $lb.IO.Breite_Mat->wpcaption        # ANum(BAG.IO.Breite, Set.Stellen.Breite);
    $lb.IO.Laenge_Mat->wpcaption        # ANum("BAG.IO.Länge", "Set.Stellen.Länge");
    $lb.IO.DickeTol_Mat->wpcaption      # BAG.IO.DickenTol;
    $lb.IO.BreiteTol_Mat->wpcaption     # BAG.IO.BreitenTol;
    $lb.IO.LaengeTol_Mat->wpcaption     # "BAG.IO.LängenTol";
    $lb.IO.Adresse_Mat->wpcaption       # AInt(BAG.IO.Lageradresse);
    $Lb.IO.Anschrift_Mat->wpcaption     # AInt(BAG.IO.Lageranschr);
    $lb.IO.IstStk_Mat->wpcaption        # AInt(BAG.IO.Ist.In.Stk);
    $lb.IO.IstNetto_Mat->wpcaption      # ANum(BAG.IO.Ist.In.GewN, Set.Stellen.Gewicht);
    $lb.IO.IstBrutto_Mat->wpcaption     # ANum(BAG.IO.Ist.In.GewB, Set.Stellen.Gewicht);
    $lb.IO.IstMenge_Mat->wpcaption      # ANum(BAG.IO.Ist.In.Menge, Set.Stellen.Menge);

    $lb.IO.OutStk_Mat->wpcaption        # AInt(BAG.IO.Ist.Out.Stk);
    $lb.IO.OutNetto_Mat->wpcaption      # ANum(BAG.IO.Ist.Out.GewN, Set.Stellen.Gewicht);
    $lb.IO.OutBrutto_Mat->wpcaption     # ANum(BAG.IO.Ist.Out.GewB, Set.Stellen.Gewicht);
    $lb.IO.OutMenge_Mat->wpcaption      # ANum(BAG.IO.Ist.Out.Menge, Set.Stellen.Menge);
    $lb.IO.MEH.IN_Mat->wpcaption        # BAG.IO.MEH.In;
    $lb.IO.MEH_Mat->wpcaption           # BAG.IO.MEH.Out;
  end
  // VSB-Material...
  else if (BAG.IO.MaterialTyp=c_IO_VSB) then begin

    vPage # 'nb.Page506';

    Mat_Data:Read(BAG.IO.Materialnr); // Einsatzmaterial holen
    $lb.IO.Chargennummer_VSB->wpCaption # Mat.Chargennummer;
    $lb.IO.Ringnummer_VSB->wpCaption    # Mat.Ringnummer
    $Lb.IO.Bestellung->wpcaption # translate('von Bestellung')+' '+Mat.Bestellnummer+' '+Mat.LieferStichwort
    $lb.IO.Wgr_VSB->wpcaption           # AInt(BAG.IO.Warengruppe);
    $lb.IO.Guete_VSB->wpcaption         # "BAG.IO.Güte";
    $lb.IO.GuetenStufe_VSB->wpcaption   # "BAG.IO.GütenStufe";
    $lb.IO.Dicke_VSB->wpcaption         # ANum(BAG.IO.Dicke, Set.Stellen.Dicke);
    $lb.IO.Breite_VSB->wpcaption        # ANum(BAG.IO.Breite, Set.Stellen.Breite);
    $lb.IO.Laenge_VSB->wpcaption        # ANum("BAG.IO.Länge", "Set.Stellen.Länge");
    $lb.IO.DickeTol_VSB->wpcaption      # BAG.IO.DickenTol;
    $lb.IO.BreiteTol_VSB->wpcaption     # BAG.IO.BreitenTol;
    $lb.IO.LaengeTol_VSB->wpcaption     # "BAG.IO.LängenTol";
    $lb.IO.Adresse_VSB->wpcaption       # AInt(BAG.IO.Lageradresse);
    $Lb.IO.Anschrift_VSB->wpcaption     # AInt(BAG.IO.Lageranschr);
    $lb.IO.IstStk_VSB->wpcaption        # AInt(BAG.IO.Ist.In.Stk);
    $lb.IO.IstNetto_VSB->wpcaption      # ANum(BAG.IO.Ist.In.GewN, Set.Stellen.Gewicht);
    $lb.IO.IstBrutto_VSB->wpcaption     # ANum(BAG.IO.Ist.In.GewB, Set.Stellen.Gewicht);
    $lb.IO.IstMenge_VSB->wpcaption      # ANum(BAG.IO.Ist.In.Menge, Set.Stellen.Menge);

    $lb.IO.OutStk_VSB->wpcaption        # AInt(BAG.IO.Ist.Out.Stk);
    $lb.IO.OutNetto_VSB->wpcaption      # ANum(BAG.IO.Ist.Out.GewN, Set.Stellen.Gewicht);
    $lb.IO.OutBrutto_VSB->wpcaption     # ANum(BAG.IO.Ist.Out.GewB, Set.Stellen.Gewicht);
    $lb.IO.OutMenge_VSB->wpcaption      # ANum(BAG.IO.Ist.Out.Menge, Set.Stellen.Menge);

    $lb.IO.MEH.IN_VSB->wpcaption        # BAG.IO.MEH.In;
    $lb.IO.MEH_VSB->wpcaption           # BAG.IO.MEH.Out;

  end
  // Weiterbearbeitung...
  else if (BAG.IO.MaterialTyp=c_IO_BAG) then begin

    vPage # 'nb.Page703';

    $lb.IO.Wgr_BAG->wpcaption           # AInt(BAG.IO.Warengruppe);
    $lb.IO.Guete_BAG->wpcaption         # "BAG.IO.Güte";
    $lb.IO.GuetenStufe_BAG->wpcaption   # "BAG.IO.GütenStufe";
    $lb.IO.Dicke_BAG->wpcaption         # ANum(BAG.IO.Dicke, Set.Stellen.Dicke);
    $lb.IO.Breite_BAG->wpcaption        # ANum(BAG.IO.Breite, Set.Stellen.Breite);
    $lb.IO.Laenge_BAG->wpcaption        # ANum("BAG.IO.Länge", "Set.Stellen.Länge");
    $lb.IO.DickeTol_BAG->wpcaption      # BAG.IO.DickenTol;
    $lb.IO.BreiteTol_BAG->wpcaption     # BAG.IO.BreitenTol;
    $lb.IO.LaengeTol_BAG->wpcaption     # "BAG.IO.LängenTol";
    $lb.IO.Adresse_BAG->wpcaption       # AInt(BAG.IO.Lageradresse);
    $Lb.IO.Anschrift_BAG->wpcaption     # AInt(BAG.IO.Lageranschr);
    $lb.IO.IstStk_BAG->wpcaption        # AInt(BAG.IO.Plan.In.Stk);
    $lb.IO.IstNetto_BAG->wpcaption      # ANum(BAG.IO.Plan.In.GewN, Set.Stellen.Gewicht);
    $lb.IO.IstBrutto_BAG->wpcaption     # ANum(BAG.IO.Plan.In.GewB, Set.Stellen.Gewicht);
    $lb.IO.IstMenge_BAG->wpcaption      # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);

    $lb.IO.OutStk_BAG->wpcaption        # AInt(BAG.IO.Ist.Out.Stk);
    $lb.IO.OutNetto_BAG->wpcaption      # ANum(BAG.IO.Ist.Out.GewN, Set.Stellen.Gewicht);
    $lb.IO.OutBrutto_BAG->wpcaption     # ANum(BAG.IO.Ist.Out.GewB, Set.Stellen.Gewicht);
    $lb.IO.OutMenge_BAG->wpcaption      # ANum(BAG.IO.Ist.Out.Menge, Set.Stellen.Menge);

    $lb.IO.MEH.IN_BAG->wpcaption        # BAG.IO.MEH.In;
    $lb.IO.MEH_BAG->wpcaption           # BAG.IO.MEH.Out;


    // Vorgänger darf nur aus eigenem BA sein (Prj. 1334/133)
    vTmp # gMdi->winsearch('edBAG.IO.VonBAG');
    if (vTmp > 0) then
      Lib_GuiCom:Disable($edBAG.IO.VonBAG);


  end
  // theoretisches Material...
  else if (BAG.IO.MaterialTyp=c_IO_Theo) then begin

    vPage # 'nb.Page1200';

    if (BAG.IO.Artikelnr<>'') then begin
      Erx # RecLink(250,701,8,_recFirsT);     // Artikel holen
      if (Erx>_rLocked) then RecbufClear(250);
    end
    else begin
      RecbufClear(250);
    end;
    $lb.IO.Stichwort_Theo->wpcaption   # Art.Stichwort;

  end
  // ARTIKEL....
  else if (BAG.IO.MaterialTyp=c_IO_Art) or (BAG.IO.MaterialTyp=c_IO_Beistell) then begin
    vPage # 'nb.Page250';

    Erx # RecLink(250,701,8,_recFirsT);     // Artikel holen
    if (Erx>_rLocked) then RecbufClear(250);

    RecBufClear(252);
    if (BAG.IO.ArtikelNr<>'') and (BAG.IO.Charge<>'') then begin
      Erx # RecLink(252,701,17,_recFirsT);    // ArtikelCharge holen
      if (Erx<=_rLocked) then vOK # y
      else RecbufClear(252);
    end
    else if (Art.Nummer<>'') then begin
//      Art.C.ArtikelNr     # Art.Nummer;
//      Art_Data:ReadCharge();
//      vOK # y;
    end;

    $lb.IO.Stichwort_Art->wpcaption   # Art.Stichwort;
    $lb.IO.Text1_Art->wpcaption       # Art.Bezeichnung1;
    $lb.IO.Text2_Art->wpcaption       # Art.Bezeichnung2;
    $lb.IO.Text3_Art->wpcaption       # Art.Bezeichnung3;
    $lb.IO.Wgr_Art->wpcaption         # AInt(BAG.IO.Warengruppe);
    $lb.IO.Charge_Art->wpcaption      # BAG.IO.Charge;
//    $lb.IO.Adresse_Art->wpcaption     # AInt(BAG.IO.Lageradresse);
//    $Lb.IO.Anschrift_Art->wpcaption   # AInt(BAG.IO.Lageranschr);

    if (vOK) then begin
      if (Mode<>c_ModeNew) and ("BAG.P.Löschmarker"='') then begin
        "Art.C.Verfügbar.Stk" # "ARt.C.Verfügbar.Stk" + BAG.IO.Plan.In.Stk;
        "Art.C.Verfügbar"     # "ARt.C.Verfügbar"     + BAG.IO.Plan.In.Menge;
      end;
    end;
    $lb.IO.IstStk_Art->wpcaption      # AInt("Art.C.Verfügbar.Stk");
    vGew # Lib_Einheiten:WandleMEH(252, "Art.C.Verfügbar.Stk", 0.0, "Art.C.Verfügbar", Art.MEH, 'kg');
    $lb.IO.IstGewicht_Art->wpcaption  # ANum(vGew,Set.Stellen.Gewicht);
    $lb.IO.IstMenge_Art->wpcaption    # ANum("Art.C.Verfügbar",Set.Stellen.Menge);
  end;


  if (vResYN=falsE) and (BAG.IO.MaterialRstNr<>0) then begin
    vTmp # Mat.Nummer;
    Mat.Nummer # BAG.IO.MaterialRstNr;
    if (RecLinkInfo(203,200,13,_recCount)>0) then vResYN # y;
    Mat.Nummer # vTmp;
  end;
  $lb.Reservierungen->wpvisible # vResYN;

// 18.01.2019 AH
//  if (BAG.IO.AutoTeilungYN) then
//    Lib_GuiCom:Disable($edBAG.IO.Teilungen_Mat)
//  else if(Mode <> c_ModeView) then
//    Lib_GuiCom:Enable($edBAG.IO.Teilungen_Mat);
    Lib_GuiCom:able($edBAG.IO.Teilungen_Mat, (BAG.IO.AutoTeilungYN=false) and (Mode<>c_ModeView));
    Lib_GuiCom:able($edBAG.IO.Teilungen_BAG, (BAG.IO.AutoTeilungYN=false) and (Mode<>c_ModeView));
    Lib_GuiCom:able($edBAG.IO.Teilungen_VSB, (BAG.IO.AutoTeilungYN=false) and (Mode<>c_ModeView));
    Lib_GuiCom:able($edBAG.IO.Teilungen_Theo, (BAG.IO.AutoTeilungYN=false) and (Mode<>c_ModeView));


  if ($nb.Typ->wpcurrent<>vPage) and (mode<>c_ModeCancel) then begin
    $nb.Typ->wpcurrent(_WinFlagNoFocusSet) # vPage;
  end;


  // Ankerfunktion?
  RunAFX('BAG.IO.I.Switchmask.Post','');

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder
  // Pflichtfelder
  //Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx     : int;
  vOK     : Logic;
  vGew    : float;
  vTmp    : int;
end;
begin

  if (aName='') then begin

    if (BAG.IO.Materialtyp=c_IO_Mat) then begin
      $edEinsatzTyp->wpcaption # Translate('Material');
    end;

    if (BAG.IO.Materialtyp=c_IO_Art) then begin
      $edEinsatzTyp->wpcaption # Translate('Artikel');
    end;

    if (BAG.IO.Materialtyp=c_IO_Beistell) then begin
      $edEinsatzTyp->wpcaption # Translate('Beistellartikel');
    end;

    if (BAG.IO.Materialtyp=c_IO_VSB) then begin
      $edEinsatzTyp->wpcaption # Translate('VSB-Material');
    end;

    if (BAG.IO.Materialtyp=c_IO_BAG) then begin
      $edEinsatzTyp->wpcaption # Translate('Weiterbearbeitung');
    end;

    if (BAG.IO.Materialtyp=c_IO_Theo) then begin
      $edEinsatzTyp->wpcaption # Translate('theor.Material');
    end;

    SwitchMask();
  end;


  // Lageradresse
  Erx # RecLink(101,701,6,0);
  if (Erx>_rLocked) then RecbufClear(101);
  $Lb.IO.Lager_Mat->wpcaption # Adr.A.Stichwort;
  $Lb.IO.Lager_VSB->wpcaption # Adr.A.Stichwort;
  $Lb.IO.Lager_BAG->wpcaption # Adr.A.Stichwort;
  $Lb.IO.Lager_Theo->wpcaption # Adr.A.Stichwort;
  $Lb.IO.Lager_Art->wpcaption # Adr.A.Stichwort;

  vOK # y;
  if (BAG.P.Aktion<>c_BAG_Fahr) and (BAG.P.Aktion<>c_BAG_Versand) AND
       (Bag.P.Aktion <> c_BAG_Umlager) and (BAG.P.ExternYN) and (BAG.P.ExterneLiefNr<>0) and
    (BAG.IO.Lageradresse<>0) then begin
    Erx # RecLink(100,101,1,_recFirst);   // Adresse holen
    if (Erx>_rLocked) or (BAG.P.ExterneLiefNr<>Adr.Lieferantennr) then vOK # n;
  end;
  if (vOK) then vTmp # _WinColParent
  else vTmp # _WinColLightRed;
  $lbBAG.IO.Lageradresse_Mat->wpColBkg  # vTmp;
  $lbBAG.IO.Lageradresse_VSB->wpColBkg  # vTmp;
  $lbBAG.IO.Lageradresse_Theo->wpColBkg # vTmp;
  $lbBAG.IO.Lageradresse_Art->wpColBkg  # vTmp;
  $lbBAG.IO.Lageradresse_BAG->wpColBkg  # vTmp;


  // Warengruppenauswahl
  if (aName='') or (aName='edBAG.IO.Warengruppe') or
    (aName='edBAG.IO.Warengruppe_Theo') then begin
    Erx # RecLink(819,701,7,0);
    if (Erx>=_rLocked) then RecBufClear(819);
    $Lb.IO.WgrText_Mat->wpcaption # Wgr.Bezeichnung.L1;
    $Lb.IO.WgrText_VSB->wpcaption # Wgr.Bezeichnung.L1;
    $Lb.IO.WgrText_BAG->wpcaption # Wgr.Bezeichnung.L1;
    $Lb.IO.WgrText_Art->wpcaption # Wgr.Bezeichnung.L1;
    $Lb.IO.WgrText_Theo->wpcaption # Wgr.Bezeichnung.L1;
  end;


  // Materialauswahl VSB
  if (aName='edBAG.IO.MaterialnrVSB') and (($edBAG.IO.MaterialnrVSB->wpchanged) or (aChanged)) then begin
//    BAG.IO.Materialnr # $edBAG.IO.MaterialnrVSB->wpcaptionint;
    Erx # Mat_Data:Read(BAG.IO.Materialnr); // Einsatzmaterial holen
    if (Erx<200) or ((Mat.Status<>c_Status_EKVSB) and (Mat.Status<>c_Status_EK_Konsi)) then begin  // 26.07.2021 AH: EK-Konsi
      RecbufClear(200);
      BAG.IO.Materialnr # 0;
    end;
    $Lb.IO.Bestellung->wpcaption # translate('von Bestellung')+' '+Mat.Bestellnummer+' '+Mat.LieferStichwort

    BAG.IO.Materialtyp    # c_IO_VSB;

    BA1_IO_I_Data:MatFelderInsInput(); // 03.11.2021 AH

    SwitchMask();
    //cDialog->winupdate(); 19.05.2022 AH
    gMDI->winupdate();
    RefreshIfm('edBAG.IO.Warengruppe');
  end;


  // Materialauswahl
  if (aName='edBAG.IO.Materialnr') and (($edBAG.IO.Materialnr->wpchanged) or (aChanged)) then begin
//    BAG.IO.Materialnr # $edBAG.IO.Materialnr->wpcaptionint;
    Erx # Mat_Data:Read(BAG.IO.Materialnr); // Einsatzmaterial holen
    if (Erx<200) then begin
      RecbufClear(200);
      BAG.IO.Materialnr # 0;
    end;

    BAG.IO.Materialtyp    # c_IO_Mat;

    BA1_IO_I_Data:MatFelderInsInput(); // 03.11.2021 AH

    // Ankerfunktion?
    RunAFX('BAG.IO.Auswahl.Mat','');

    SwitchMask();
    //cDialog->winupdate(); 19.05.2022 AH
    gMDI->winupdate();
    RefreshIfm('edBAG.IO.Warengruppe');
  end;


  // THEORETISCH...
  if (aName='edBAG.IO.Artikelnr_Theo') and
      (($edBAG.IO.ARtikelnr_Theo->wpchanged) or (aChanged)) then begin

    Erx # RecLink(250,701,8,_recFirsT);   // Artikel holen
    if (Erx>_rLocked) then RecBufClear(250);

    BAG.IO.Artikelnr      # Art.Nummer;
    BAG.IO.Materialnr     # 0;

    BAG.IO.Auftragsnr     # 0;
    BAG.IO.AuftragsPos    # 0;
    BAG.IO.AuftragsFert   # 0;

    BAG.IO.Charge         # '';
    BAG.IO.Lageradresse   # 0;
    BAG.IO.Lageranschr    # 0;
    BAG.IO.MEH.In         # Art.MEH;
    BAG.IO.MEH.Out        # Art.MEH;; // 2022-12-19 AH  BA1_P_Data:ErmittleMEH();
    BAG.IO.Warengruppe    # Art.Warengruppe;

    BAG.IO.Dicke          # Art.Dicke;
    BAG.IO.Breite         # Art.Breite;
    "BAG.IO.Länge"        # "Art.Länge";
    BAG.IO.Dickentol      # Art.Dickentol;
    BAG.IO.Breitentol     # Art.Breitentol;
    "BAG.IO.Längentol"    # "Art.Längentol";

    Erx # RecLink(841,250,16,_recfirst);    // Oberfläche holen
    if (Erx>_rLocked) then RecBufClear(841);
    BAG.IO.AusfOben       # "Obf.Kürzel";
    BAG.IO.AusfUnten      # '';
    "BAG.IO.Güte"         # "Art.Güte";

    $lb.IO.MEH.Out.FM_Mat->WinUpdate(_WinUpdFld2Obj);
    $lb.IO.MEH.Out.FM_BAG->WinUpdate(_WinUpdFld2Obj);
    $lb.IO.MEH.Out.FM_VSB->WinUpdate(_WinUpdFld2Obj);
    $lb.IO.MEH.Out.FM_Theo->WinUpdate(_WinUpdFld2Obj);
    gMDI->Winupdate(_WinUpdFld2Obj);

    SwitchMask();
    RefreshIfm('edBAG.IO.Warengruppe');

  end;  // ...Theoretisch


  // ARTIKEL...
  if (aName='edBAG.IO.Artikelnr_Art') and
      (($edBAG.IO.ARtikelnr_Art->wpchanged) or (aChanged)) then begin

    Erx # RecLink(250,701,8,_recFirsT);   // Artikel holen
    if (Erx>_rLocked) then RecBufClear(250);

    BAG.IO.Artikelnr      # Art.Nummer;
    BAG.IO.Materialnr     # 0;

    BAG.IO.Auftragsnr     # 0;
    BAG.IO.AuftragsPos    # 0;
    BAG.IO.AuftragsFert   # 0;

    BAG.IO.Charge         # '';
    BAG.IO.Lageradresse   # 0;
    BAG.IO.Lageranschr    # 0;
    BAG.IO.MEH.In         # Art.MEH;
    BAG.IO.MEH.Out        # BAG.IO.MEH.In;

    BAG.IO.Dicke          # Art.Dicke;
    BAG.IO.Breite         # Art.Breite;
    "BAG.IO.Länge"        # "Art.Länge";

    BAG.IO.Plan.In.Stk    # 0;
    BAG.IO.Plan.In.GewN   # 0.0;
    BAG.IO.Plan.In.GewB   # 0.0;
    BAG.IO.Plan.In.Menge  # 0.0;

    BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
    BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
    BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
    BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;

    BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.In.Menge;
    BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
    BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
    BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
    BAG.IO.Warengruppe    # Art.Warengruppe;
    //BAG.IO.Materialtyp    # c_IO_Art;

    $lb.IO.MEH.Out.FM_Mat->WinUpdate(_WinUpdFld2Obj);
    $lb.IO.MEH.Out.FM_BAG->WinUpdate(_WinUpdFld2Obj);
    $lb.IO.MEH.Out.FM_VSB->WinUpdate(_WinUpdFld2Obj);
    $lb.IO.MEH.Out.FM_Theo->WinUpdate(_WinUpdFld2Obj);

    SwitchMask();

    RefreshIfm('edBAG.IO.Warengruppe');

//    if ("Art.ChargenführungYN") then begin
      Auswahl('Charge');
      RETURN;
//    end;

  end;  // ...Artikel


  // Charge...
  if (aName='edBAG.IO.Charge') and (aChanged) then begin

    Erx # RecLink(252,701,17,_recFirsT);    // Charge holen
    if (Erx>_rLocked) then RecBufClear(252);
    Erx # RecLink(250,252,1,_recFirst);     // Artikel holen
    if (Erx>_rLocked) then RecBufClear(250);

    BAG.IO.Artikelnr      # Art.C.Artikelnr;
    BAG.IO.Materialnr     # 0;

    BAG.IO.Auftragsnr     # Art.C.Auftragsnr;
    BAG.IO.AuftragsPos    # Art.C.AuftragsPos;
    BAG.IO.AuftragsFert   # Art.C.AuftragsFertig;

    BAG.IO.MEH.In         # Art.MEH;
    BAG.IO.MEH.Out        # BAG.IO.MEH.In;

    BAG.IO.Dicke          # Art.C.Dicke;
    BAG.IO.Breite         # Art.C.Breite;
    "BAG.IO.Länge"        # "Art.C.Länge";

    // LFA-Update war alles NULL
    BAG.IO.Plan.In.Stk    # Art.C.Bestand.Stk;
    vGew # Lib_Einheiten:WandleMEH(252, "Art.C.Bestand.Stk", 0.0, "Art.C.Bestand", Art.MEH, 'kg');
    BAG.IO.Plan.In.GewN   # vGew;
    BAG.IO.Plan.In.GewB   # vGew;
    BAG.IO.Plan.In.Menge  # Art.C.Bestand;

    BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
    BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
    BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
    BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;

    vGew # Lib_Einheiten:WandleMEH(252, "Art.C.Verfügbar.Stk", 0.0, "Art.C.Verfügbar", Art.MEH, 'kg');
    BAG.IO.Plan.Out.Meng  # 0.0;//"Art.C.Verfügbar";
    BAG.IO.Plan.Out.Stk   # 0;//"Art.C.Verfügbar.Stk";
    BAG.IO.Plan.Out.GewN  # 0.0;//vGew;
    BAG.IO.Plan.Out.GewB  # 0.0;//vGew;
    BAG.IO.Warengruppe    # Art.Warengruppe;
    //BAG.IO.Materialtyp    # c_IO_Art;

    $lb.IO.MEH.Out.FM_Mat->WinUpdate(_WinUpdFld2Obj);
    $lb.IO.MEH.Out.FM_BAG->WinUpdate(_WinUpdFld2Obj);
    $lb.IO.MEH.Out.FM_VSB->WinUpdate(_WinUpdFld2Obj);
    $lb.IO.MEH.Out.FM_Theo->WinUpdate(_WinUpdFld2Obj);

    SwitchMask();
    if (BAG.IO.Charge<>'') then begin
      lib_guicom:Disable($edBAG.IO.Lageradresse_Art);
      lib_guicom:Disable($bt.Lageradresse_Art);
      lib_guicom:Disable($edBAG.IO.Lageranschr_Art);
      lib_guicom:Disable($bt.Lageranschr_Art);
      lib_guicom:Disable($edBAG.IO.Art.Zustand);
      lib_guicom:Disable($bt.Zustand_Art);
    end;

    RefreshIfm('edBAG.IO.Warengruppe');
  end;  //..Charge


  if (BAG.IO.MaterialTyp=c_IO_Art) or (BAG.IO.Materialtyp=c_IO_Beistell) then begin
    Erx # RecLink(856,701,19,_recFirst);  // Zustand holen
    if (Erx>_rLocked) then RecBufClear(856);
    $Lb.IO.Zustand_Art->wpcaption     # Art.Zst.Name;
  end;

  if (aName='edBAG.IO.Guete') and ($edBAG.IO.Guete->wpchanged) then begin
    MQu_Data:Autokorrektur(var "BAG.IO.Güte");
    $edBAG.IO.Guete->Winupdate();
  end;

  if (aName='edBAG.IO.GuetenStufe') and ($edBAG.IO.GuetenStufe->wpchanged) then begin
    MQu_Data:Autokorrektur(var "BAG.IO.GütenStufe");
    $edBAG.IO.GuetenStufe->Winupdate();
  end;


  if (Mode=c_ModeEdit) or (Mode=c_ModeNew) then begin
    if (BAG.IO.MEH.Out='Stk') or (BAG.IO.MEH.Out='kg') or ($edBAG.IO.Plan.Out.Stk_Mat->wpreadonly) then begin
      lib_guicom:Disable($edBAG.IO.Plan.Out.Meng_Mat);
      lib_guicom:Disable($edBAG.IO.Plan.Out.Meng_BAG);
      lib_guicom:Disable($edBAG.IO.Plan.Out.Meng_VSB);
      lib_guicom:Disable($edBAG.IO.Plan.Out.Meng_Theo);
    end
    else begin
      lib_guicom:Enable($edBAG.IO.Plan.Out.Meng_Mat);
      lib_guicom:Enable($edBAG.IO.Plan.Out.Meng_BAG);
      lib_guicom:Enable($edBAG.IO.Plan.Out.Meng_VSB);
      lib_guicom:Enable($edBAG.IO.Plan.Out.Meng_Theo);
    end;
  end;

  getRinglRad();

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

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
sub RecInit();
local begin
  Erx   : int;
  vNr   : int;
  vTmp  : int;
end;
begin

  vTmp # gMdi->winsearch('NB.Main');
  vTmp->wpCurrent(_WinFlagNoFocusSet) # 'NB.Input';

  if (BAG.P.Aktion=c_BAG_Versand) or (BAG.P.Aktion=c_BAG_Umlager) then begin
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.Stk_Mat);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.GewN_Mat);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.GewB_Mat);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.Meng_Mat);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.Stk_BAG);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.GewN_BAG);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.GewB_BAG);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.Meng_BAG);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.Stk_VSB);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.GewN_Mat);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.GewB_Mat);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.Meng_VSB);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.Stk_Theo);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.GewN_Theo);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.GewB_Theo);
    Lib_GuiCom:Disable($edBAG.IO.Plan.Out.Meng_Theo);
  end
  else begin
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.Stk_Mat);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.GewN_Mat);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.GewB_Mat);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.Meng_Mat);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.Stk_BAG);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.GewN_BAG);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.GewB_BAG);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.Meng_BAG);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.Stk_VSB);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.GewN_Mat);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.GewB_Mat);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.Meng_VSB);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.Stk_Theo);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.GewN_Theo);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.GewB_Theo);
    Lib_GuiCom:Enable($edBAG.IO.Plan.Out.Meng_Theo);
  end;


  // Focus setzen auf Feld:
  if (Mode=c_ModeNew) then begin

    $edEinsatztyp->wpcustom # '';
    $edBAG.IO.VonID->wpcustom # '_E';

    $nb.Typ->wpcurrent(_WinFlagNoFocusSet) # 'nb.Page0';
    $edEinsatztyp->wpcaption # '';
//debug('set f9');
    Erx # RecLink(701,700,3,_recLast);  // letzten IO holen
    if (Erx<=_rLocked) then vNr # 1
    else vNr # BAG.IO.ID + 1;

    RecBufClear(701);
    BAG.IO.ID # vNr;
    BAG.IO.Nummer         # BAG.P.Nummer;
    BAG.IO.NachBAG        # BAG.P.Nummer;
    BAG.IO.NachPosition   # BAG.P.Position;
    BAG.IO.AutoTeilungYN  # Set.BA.AutoteilungYN;

//11.10.2021    if ("BAG.P.Typ.1in-1outYN") and
//      (((BAG.P.Aktion<>c_BAG_Fahr09) AND (Bag.P.Aktion <> c_BAG_Umlager)) or (BAG.P.ZielVerkaufYN=n)) then    // 1zu1 Arbeitsgang?
    if (BA1_P_Data:Muss1AutoFertigungHaben()) then
      BAG.IO.NachFertigung # 1;

    BAG.IO.NachBAG      # BAG.Nummer;
    BAG.IO.NachPosition # BAG.P.Position;
    BAG.IO.MEH.Out      # 'kg'; //  2022-12-19  AH  BA1_P_Data:ErmittleMEH();
    BAG.IO.MEH.In       # BAG.IO.MEH.Out;

    SwitchMask();

    $edEinsatztyp->WinFocusSet(true);

    RETURN;

  end   // New
  else begin  // Modus: EDIT

    SwitchMask();
    if (BAG.P.Aktion=c_BAG_Versand) then begin
      if (BAG.IO.Materialtyp=c_IO_Mat) then
        $edBAG.IO.Bemerkung_Mat->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_Art) then
        $edBAG.IO.Bemerkung_Art->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_Beistell) then
        $edBAG.IO.Bemerkung_Art->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_VSB) then
        $edBAG.IO.Bemerkung_VSB->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_BAG) then
        $edBAG.IO.Bemerkung_BAG->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_Theo) then
        $edBAG.IO.Bemerkung_Theo->WinFocusSet(true);
    end
    else begin
      if (BAG.IO.Materialtyp=c_IO_Mat) then
        $edBAG.IO.Plan.Out.Stk_Mat->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_Art) then
        $edBAG.IO.Plan.Out.Stk_Art->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_Beistell) then
        $edBAG.IO.Plan.Out.Stk_Art->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_VSB) then
        $edBAG.IO.Plan.Out.Stk_VSB->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_BAG) then
        $edBAG.IO.Plan.Out.Stk_BAG->WinFocusSet(true)
      else if (BAG.IO.Materialtyp=c_IO_Theo) then
        $edBAG.IO.Plan.Out.Stk_Theo->WinFocusSet(true);
    end;

  end;    // Edit

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vStk      : int;
  vGewN     : float;
  vGewB     : float;
  vM        : float;
  vBem      : alpha;
  vBuf701   : int;
  vBuf701b  : int;
  vBuf702   : int;
  vVonID    : int;
  vVonBAG   : int;
  vAdr      : int;
  vAns      : int;
  vMEH      : alpha;
  vTlg      : int;
  vAutoT    : logic;
  vErr      : int;
  vKGMM1    : float;
  vKGMM2    : float;
  vKGMM_Kaputt  : logic;
  vTlgErr   : int;
  vBuf401   : int;
  vKunde    : int;
  vEinsatzDoppelt : logic;
  vOhneRest : logic;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  // AFX
  if (RunAFX('BAG.IO.In.RecSave','')<>0) then begin
    if (AfxRes<>_rOk) then RETURN False;
  end;


  // logische Prüfung
  if ($edEinsatztyp->wpcaption = '') then begin
    Msg(001200,Translate('Einsatztyp'),0,0,0);
    $edEinsatztyp->WinFocusSet(true);
    RETURN false;
  end;
  if (BAG.P.Aktion=c_BAG_VSB) and ((BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Materialtyp=c_IO_VSB)) then begin
    Lib_Guicom2:InhaltFalsch('Einsatztyp', 'NB.Page1', 'edEinsatztyp');
    RETURN false;
  end;


  // Da beim Umlagern keine Statusveränderung am Material vorgenommen wird, muss vorab geprüft werden,
  // ob die Materialnummer doppelt eingesetzt wird
  if (Bag.P.Aktion = c_BAG_Umlager) then begin
    if (IstUmlagerEinsatzDoppelt(Bag.IO.Materialnr))  then begin
      Msg(701025,'',0,0,0);     //  Einsatz ungültig
      RETURN false;
    end;
  end;


  if (Mode=c_ModeNew) then begin
    BAG.IO.NachFertigung # 0;
//11.10.2021    if ("BAG.P.Typ.1in-1outYN") and
//      (((BAG.P.Aktion<>c_BAG_Fahr09) AND (Bag.P.Aktion<>c_BAG_Umlager)) or (BAG.P.ZielVerkaufYN=n)) then    // 1zu1 Arbeitsgang?
    if (BA1_P_Data:Muss1AutoFertigungHaben()) then
      BAG.IO.NachFertigung # 1;

    // beim Klonen ggf. Kommission kopieren...
    if (w_AppendNr<>0) then begin
      vBuf701 # RecBufCreate(701);
      vBuf701->BAG.IO.Nummer #  BAG.IO.Nummer;
      vBuf701->BAG.IO.iD     #  w_AppendNr;
      Erx # RecRead(vBuf701,1,0);
      if (BAG.IO.Auftragsnr=0) then begin
        BAG.IO.Auftragsnr   # vBuf701->BAG.IO.Auftragsnr;
        BAG.IO.AuftragsPos  # vBuf701->BAG.IO.Auftragspos;
        BAG.IO.AuftragsFert # vBuf701->BAG.IO.AuftragsFert;
      end;
      RecbufDestroy(vBuf701);
    end;

  end;


  // Einsatz prüfen ================================================
  if (BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Materialtyp=c_IO_VSB) then begin
    if (BAG.VorlageYN) then RETURN false; // 30.09.2021
    Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
    if (Erx<200) then begin
      Msg(001201,Translate('Material'),0,0,0);
      if (BAG.IO.Materialtyp=c_IO_Mat) then $edBAG.IO.Materialnr->WinFocusSet(true)
      else $edBAG.IO.MaterialnrVSB->WinFocusSet(true);
      RETURN false;
    end;

    if (Mode=c_ModeNew) then begin
      // 2023-06-01 AH    Proj. 2528/15
      if (BAG.IO.Plan.Out.GewB>BAG.IO.Plan.In.GewB) then begin
        if (Msg(701043,Translate('Bruttogewicht'),_WinIcoQuestion, _WinDialogYesNo,2)=_Winidno) then RETURN false;
      end;
      if (BAG.IO.Plan.Out.GewN>BAG.IO.Plan.In.GewN) then begin
        if (Msg(701043,Translate('Nettogewicht'),_WinIcoQuestion, _WinDialogYesNo,2)=_Winidno) then RETURN false;
      end;
      if (BAG.IO.Plan.Out.Stk>BAG.IO.Plan.In.Stk) then begin
        if (Msg(701043,Translate('Stück'),_WinIcoQuestion, _WinDialogYesNo,2)=_Winidno) then RETURN false;
      end;
      if (BAG.IO.Plan.Out.Meng>BAG.IO.Plan.In.Menge) then begin
        if (Msg(701043,BAG.IO.MEH.In,_WinIcoQuestion, _WinDialogYesNo,2)=_Winidno) then RETURN false;
      end;

      vErr # BA1_IO_I_Data:PruefeMoeglichesEinsatzMat();

      // 16.03.2012 AI: Einsatz in VK-Fahren MUSS kommissioniert sein!!!
      // 09.12.2021 AH
      if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.P.ZielVerkaufYN) and (BAG.VorlageYN=false) then begin
        if (BAG.IO.Auftragsnr=0) then vErr # 441015;
        if (vErr=0) then begin
          vBuf701 # RecBufCreate(701);
          vBuf701b # RecBufCreate(701);
          vBuf401 # RecBufCreate(401);
          FOR Erx # RecLink(vBuf701,702,2,_recFirst)  // Input loopen
          LOOP Erx # RecLink(vBuf701,702,2,_recNext)
          WHILE (Erx<=_rLocked) and (vKunde=0) do begin
            if (vBuf701->BAG.IO.NachID=0) then CYCLE;
            // OUTPUT dazu holen...
            vBuf701b->BAG.IO.Nummer # vBuf701->BAG.IO.NachBAG;
            vBuf701b->BAG.IO.ID # vBuf701->BAG.IO.NachID;
            Erx # RecRead(vBuf701b,1,0);
            if (Erx>_rLocked) or (vBuf701b->BAG.IO.Auftragsnr=0) then CYCLE;
            Erx # RecLink(vBuf401,vBuf701b,16,_recFirst);  // Aufpos holen
            if (Erx>_rLocked) then begin
              RecBufClear(401);
              CYCLE;
            end;
            vKunde # vBuf401->Auf.P.Kundennr;
            BREAK;
          END;
          if (vKunde<>0) then begin
            Erx # RecLink(vBuf401,701,16,_recFirst);  // Aufpos holen
            if (vBuf401->Auf.P.Kundennr<>vKunde) then vErr # 441016;
          end;
          RecBufDestroy(vBuf701);
          RecBufDestroy(vBuf701b);
          RecBufDestroy(vBuf401);
        end;
      end;

      if (vErr<>0) then begin
        if (vErr<>-1) then Msg(vErr,'',0,0,0);
        if (BAG.IO.Materialtyp=c_IO_Mat) then $edBAG.IO.Materialnr->WinFocusSet(true)
        else $edBAG.IO.MaterialnrVSB->WinFocusSet(true);
        RETURN false;
      end;

    end;

    // Lagerorte prüfen...
    if (RecLinkInfo(701,702,2,_recCount)>0) then begin
      vBuf701 # RecBufCreate(701);
      Erx # RecLink(vBuf701,702,2,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        if (vBuf701->BAG.IO.Materialtyp=c_IO_Mat) or (vBuf701->BAG.IO.Materialtyp=c_IO_VSB) then begin
          Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
          if (Erx>=200) then begin
            vAdr # Mat.Lageradresse;
            vAns # Mat.Lageranschrift;
            BREAK;
          end;
        end;
        Erx # RecLink(vBuf701,702,2,_recNext);
      END;
      RecBufDestroy(vBuf701);
      if (vAdr<>0) then begin
        Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
        if (vAdr<>Mat.Lageradresse) or (vAns<>Mat.Lageranschrift) then begin
          if (Msg(441003,'',_WinIcoWarning,_WinDialogYesNo,2)<>_WinIdYes) then begin
            if (BAG.IO.Materialtyp=c_IO_Mat) then $edBAG.IO.Materialnr->WinFocusSet(true)
            else $edBAG.IO.MaterialnrVSB->WinFocusSet(true);
            RETURN false;
          end;
        end;
      end;
    end;  // Lagerortsprüfung

  end;


  // Weiterverarbeitung?? ==========================================
  if (BAG.IO.Materialtyp=c_IO_BAG) then begin

    vStk    # BAG.IO.Plan.Out.Stk;
    vGewN   # BAG.IO.Plan.Out.GewN;
    vGewB   # BAG.IO.Plan.Out.GewB;
    vM      # BAG.IO.Plan.Out.Meng;
    vMEH    # BAG.IO.MEH.Out;
    vBem    # BAG.IO.Bemerkung;
    vTlg    # BAG.IO.Teilungen;
    vAutoT    # BAG.IO.AutoTeilungYN;
    vOhneRest # BAG.IO.OhneRestYN;
    if (Mode=c_ModeEdit) then begin
      vVonID  # BAG.IO.ID;
    end;

    if (Mode=c_ModeNew) then begin    // Neuanlage?
      vVonBAG # BAG.IO.VonBAG;
      vVonID  # BAG.IO.VonID;
      vBuf701 # RekSave(701);

      BAG.IO.Nummer # vVonBAG;
      BAG.IO.ID # vVonID;
      Erx # RecRead(701,1,_RecTest);

      if (Erx<=_rMultikey) then begin     // Einsatz gefunden !
        Erx # RecRead(701,1,0)
        if (BAG.IO.NachBAG<>0) then begin // ist bereits Einsatz??
          RekRestore(vBuf701);
          Msg(701002,gTitle,0,0,0);
          $edBAG.IO.VonID->WinFocusSet(true);
          RETURN false;
        end;
        // Vorgänger prüfen auf "nicht-gelöscht"
        vBuf702 # RecBufCreate(702);
        Erx # RecLink(vBuf702,701,2,_recFirst); // Vor-Position holen
        if (Erx>_rLocked) or (vBuf702->"BAG.P.Löschmarker"<>'') then begin
          RecBufDestroy(vBuf702);
          RekRestore(vBuf701);
          Msg(701033,gTitle,0,0,0);
          $edBAG.IO.VonID->WinFocusSet(true);
          RETURN false;
        end;
        RecBufDestroy(vBuf702);

        // Verkaufs-Fahren dürfen nicht Weiterbearbeitet werden...
        // 11.2.2011
        if (BAG.P.Aktion<>c_BAG_VSB) then begin
          vBuf702 # RecBufCreate(702);
          Erx # RecLink(vBuf702,701,2,_recFirst); // Vor-Position holen
          if (Erx>_rLocked) or
            ((vBuf702->BAG.P.Aktion=c_BAG_Fahr09) and (vBuf702->BAG.P.ZielVerkaufYN)) or
            (vBuf702->BAG.P.Aktion=c_BAG_Umlager) then begin
            RecBufDestroy(vBuf702);
            RekRestore(vBuf701);
            Msg(701029,gTitle,0,0,0);
            $edBAG.IO.VonID->WinFocusSet(true);
            RETURN false;
          end;
          RecBufDestroy(vBuf702);
        end;


        // Auf Kreislauf prüfen
        if (BA1_IO_Data:Loopcheck(0,'')=false) then begin
          RekRestore(vBuf701);
          Msg(701004,gTitle,0,0,0);
          $edBAG.IO.VonID->WinFocusSet(true);
          RETURN false;
        end;

        RecBufDestroy(vBuf701);
      end
      else begin                      // Einsatz NICHT gefunden
        Msg(701001,gTitle,0,0,0);
        $edBAG.IO.VonID->WinFocusSet(true);
        RETURN false;
      end;

    end; // ... NEW

    BAG.IO.ID # vVonID;
    Erx # RecRead(701,1,0);        // alles ok!
    BAG.IO.NachBag        # BAG.P.Nummer;
    BAG.IO.NachPosition   # BAG.P.Position;
    if (Mode=c_ModeNew) then begin
      BAG.IO.NachFertigung # 0;
      // 11.2.2011
// 11.10.2021      if ("BAG.P.Typ.1in-1outYN") and
//        ((BAG.P.Aktion<>c_BAG_Fahr09) or (BAG.P.ZielVerkaufYN=n)) then    // 1zu1 Arbeitsgang?
      if (BA1_P_Data:Muss1AutoFertigungHaben()) then
        BAG.IO.NachFertigung # 1;
    end;

    BAG.IO.AutoTeilungYN  # vAutoT;
    BAG.IO.Teilungen      # vTLg;
    BAG.IO.Plan.Out.Meng  # vM;
    BAG.IO.Plan.Out.Stk   # vStk;
    BAG.IO.Plan.Out.GewN  # vGewN;
    BAG.IO.Plan.Out.GewB  # vGewB;
    BAG.IO.MEH.Out        # vMEH;
    BAG.IO.Bemerkung      # vBem;
    BAG.IO.OhneRestYN     # vOhneRest;
    "BAG.IO.LöschenYN"    # N;

    TRANSON;

    Erx # RecRead(701,1,_RecLock | _RecNoLoad);
    Erx # BA1_IO_Data:Replace(_recUnlock,'MAN');

    // Input: Weiterbearbeitung oder Material...
    if (BAG.IO.Materialtyp=c_IO_BAG) or
      ((BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.VonBAG=0)) then begin

      if (BA1_IO_data:Autoteilung(var vKGMM_Kaputt)=false) then begin
        if (Set.BA.AutoT.NurWarn=false) then begin
          TRANSBRK;
          ErrorOutPut;
          RETURN false;
        end
        else begin
          vTlgErr # 1;
        end;
      end;
    end;

    // Output aktualisieren
    if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      TRANSBRK;
      Error(701010,'');
      ErrorOutput;
      RETURN false;
    end;


    // KLONEN ???
    if (w_AppendNr<>0) then begin
      BA1_IO_I_Data:KlonenVon(w_AppendNr);
      w_AppendNr # 0;
    end;


    TRANSOFF;

    if (Mode=c_ModeEdit) then
      PtD_Main:Compare(gFile);

    vBuf701 # RekSave(701);
    BA1_P_Data:UpdateSort();
    cZList1->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    cZList3->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    RekRestore(vBuf701);

    // AFX
    RunAFX('BAG.IO.InRecSavePost','');

    if (vKGMM_Kaputt) then begin
      Msg(703006,aint(BAG.P.Position),_WinIcoWarning, _WinDialogOk, 0);
    end;

    ErrorOutput;

    // alle Fertigungen neu errechnen
    // 16.08.2012 AI: NUR bei 1zu1 oder 1zuX (Spalten) - NIEMALS beim Tafeln etc.
// 14.04.2020 AH    if ("BAG.P.Typ.1In-1OutYN") or
//        ("BAG.P.Typ.1In-yOutYN") then
//      BA1_P_Data:ErrechnePlanmengen();
    cZList3->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

    // AFX?
    RunAFX('BAG.Output.Check','');

    RETURN true;
  end;  // ... Weiterbeabeiteung




  // Artikel =============================================================
 if (BAG.IO.Materialtyp=c_IO_Art) or (BAG.IO.Materialtyp=c_IO_Beistell) then begin
    BAG.IO.Plan.In.Menge    # BAG.IO.Plan.Out.Meng;
    BAG.IO.Plan.In.Stk      # BAG.IO.Plan.Out.Stk;
    BAG.IO.Plan.In.GewN     # BAG.IO.Plan.Out.GewN;
    BAG.IO.Plan.In.GewB     # BAG.IO.Plan.Out.GewB;
// 24.07.2017 AH:
    BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
    BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
    BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
    BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;
  end;





  // Nummernvergabe
  // Satz zurückspeichern & protokollieren
  if (Mode=c_ModeEdit) then begin

    TRANSON;

    // VSB-Material auf diesen Einsatz hin anpassen
    if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
      if (BA1_Mat_Data:VSBFreigeben()=false) then begin
        TRANSBRK;
        Msg(701005,'',0,0,0);
        RETURN false;
      end;
      if (BA1_Mat_Data:VSBEinsetzen()=false) then begin
        TRANSBRK;
        Msg(701005,'',0,0,0);
        RETURN false;
      end;
    end;

    Erx # BA1_IO_Data:Replace(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (BAG.P.Aktion=c_BAG_SpaltSpulen) then begin
      BA1_P_Data:ErrechnePlanmengen();
    end;

    // DOPPELT MACHEN WEGEN AUTOTEILUNGEN UND PLANMENGEN!!!!

    // Input: Weiterbearbeitung oder Material...
    if (BAG.IO.Materialtyp=c_IO_BAG) or
      ((BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.VonBAG=0)) then begin
      if (BA1_IO_data:Autoteilung(var vKGMM_Kaputt)=false) then begin

        if (Set.BA.AutoT.NurWarn=false) then begin
          TRANSBRK;
          ErrorOutPut;
          Erx # RecRead(701,1,_RecLock);
          RETURN false;
        end
        else begin
          vTlgErr # 1;
        end;
      end;
    end;

    // Output aktualisieren
    if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      TRANSBRK;
      Error(701010,'');
      ErrorOutput;
      Erx # RecRead(701,1,_RecLock);
      RETURN false;
    end;
/*** 25.03.2019 AH:
    // Input: Weiterbearbeitung oder Material...
    if (vTlgErr=0) then
    if (BAG.IO.Materialtyp=c_IO_BAG) or
      ((BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.VonBAG=0)) then begin
      if (BA1_IO_data:Autoteilung(var vKGMM_Kaputt)=false) then begin
        if (Set.BA.AutoT.NurWarn=false) then begin
          TRANSBRK;
          ErrorOutPut;
          Erx # RecRead(701,1,_RecLock);
          RETURN false;
        end
        else begin
          vTlgErr # 1;
        end;
      end;
    end;

    // Output aktualisieren
    if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      TRANSBRK;
      Error(701010,'');
      ErrorOutput;
      Erx # RecRead(701,1,_RecLock);
      RETURN false;
    end;
***/

    TRANSOFF;

    PtD_Main:Compare(gFile);

    if (vKGMM_Kaputt) then begin
      Msg(703006,aint(BAG.P.Position),_WinIcoWarning, _WinDialogOk, 0);
    end;

    ErrorOutput;

    // AFX?
    RunAFX('BAG.Output.Check','');

  end // EDIT
  else begin  // Neuanlage

    // ID vergeben
    WHILE (RecRead(701,1,_recTest)<=_rLocked) do
      BAG.IO.ID # BAG.IO.ID + 1;

    BAG.IO.UrsprungsID    # BAG.IO.ID;
    BAG.IO.Anlage.Datum   # Today;
    BAG.IO.Anlage.Zeit    # Now;
    BAG.IO.Anlage.User    # gUserName;

    TRANSON;

    // VSB-Material auf diesen neuen Einsatz hin anpassen
    if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
      if (BA1_Mat_Data:VSBEinsetzen()=false) then begin
        TRANSBRK;
        Msg(701005,'',0,0,0);
        RETURN false;
      end;
    end;

    // Material auf diesen neuen Einsatz hin anpassen
    if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
      if (BA1_Mat_Data:MatEinsetzen()=false) then begin
        TRANSBRK;
        Msg(701005,'',0,0,0);
        RETURN false;
      end;
    end;

    // Artikel reservieren...
    Erx # BA1_IO_Data:Insert(0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (BAG.IO.Materialtyp<>c_IO_Beistell) then begin // 26.02.2020 AH wegen VBS
      if (BAG.P.Aktion=c_BAG_SpaltSpulen) then begin
        BA1_P_Data:ErrechnePlanmengen();
      end;

      // Output aktualisieren
      if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
        TRANSBRK;
        ErrorOutput;
        RETURN false;
      end;


      // Input: Weiterbearbeitung oder Material...
      if (BAG.IO.Materialtyp=c_IO_BAG) or
        ((BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.VonBAG=0)) then begin

        if (BA1_IO_data:Autoteilung(var vKGMM_Kaputt)=false) then begin
          TRANSBRK;
          ErrorOutPut;
          RETURN false;
        end;

      end;
    end;
    

    // KLONEN ???
    if (w_AppendNr<>0) then begin
      BA1_IO_I_Data:KlonenVon(w_AppendNr);
      w_AppendNr # 0;
    end;

    TRANSOFF;

    if (vKGMM_Kaputt) then begin
      Msg(703006,aint(BAG.P.Position),_WinIcoWarning, _WinDialogOk, 0);
    end;

    // AFX?
    RunAFX('BAG.Output.Check','');

  end;

  // nächste Pos. holen
  RecLink(702,701,4,_recFirst);

  // alle Fertigungen neu errechnen
  // 13.03.2013 AI: dekativert, da wo anderes gerechnet wird
  // 22.08.2011 AI: NUR bei 1zu1 oder 1zuX (Spalten) - NIEMALS beim Tafeln etc.
  if ("BAG.P.Typ.1In-1OutYN") or (BAG.P.Aktion=c_BAG_SpaltSPulen) then begin
//      ("BAG.P.Typ.1In-yOutYN") then begin
    BA1_P_Data:ErrechnePlanmengen();
  end;
//  cZList3->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  cZList3->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

  // AFX
  RunAFX('BAG.IO.InRecSavePost','');

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx       : int;
  vBuf701   : int;
  vBuf707   : int;
  vKill707  : logic;
end;
begin

  // hierauf bereits verwogen?
  if (BA1_IO_I_Data:BereitsVerwogen() = true) then begin
    Msg(701007,'',0,0,0);
    RETURN;
  end;

  // MS 18.03.2010
  if (BAG.P.Aktion = c_BAG_VSB) then begin
    if(BA1_P_Data:BereitsVerwiegung(BAG.P.Aktion) = true) then begin
      Msg(701026, '', 0, 0, 0);
      RETURN;
    end;
  end;

  // Weiterbearbeitung?
  if (BAG.IO.Materialtyp=c_IO_BAG) then begin
    vBuf701 # RecBufCreate(701);
    vBuf707 # RecBufCreate(707);
    vKill707 # n;
    FOR Erx # RecLink(vBuf707,701,20,_recFirst)   // Brüder durchlaufen
    LOOP Erx # RecLink(vBuf707,701,20,_recNext)
    WHILE (Erx<=_rLocked) and (vKill707=n) do begin
      Erx # RecLink(vBuf701,vBuf707,8,_recFirst);
      if (Erx<=_rLocked) then begin
        if (vBuf701->BAG.IO.NachBAG<>0) then
          vKill707 # y;
      end;
    END;
    RecBufDestroy(vBuf707);
    RecBufDestroy(vBuf701);
  end;


  Mode # c_ModeDelete;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then begin
    Mode # c_ModeList;
    RETURN;
  end;

  if (vKill707) then begin
    if (Msg(701035,'?',_WinIcoWarning,_WinDialogOkCancel, 1)<>_winidok) then begin
      Mode # c_ModeList;
      RETURN;
    end;
  end;

  TRANSON;

  if (vKill707) then begin
    vBuf701 # RekSave(701);
    FOR Erx # RecLink(707,701,20,_recFirst)   // Brüder loopen
    LOOP Erx # RecLink(707,701,20,_recNext)
    WHILE (Erx<=_rLocked) do begin

      vBuf707 # RekSave(707);
      Erx # RecLink(701,707,8,_recFirst);   // Output holen
      if (Erx<=_rLocked) then begin
        if (BAG.IO.NachBAG<>0) then begin
          if (BA1_FM_Data:SetSperre()<>true) then begin
            TRANSBRK;
            Mode # c_ModeList;
            ErrorOutput;
            RekRestore(vBuf707);
            RekRestore(vBuf701);
            RETURN;
          end;
          ErrorOutput;
        end;
      end;
      RecBufCopy(vBuf701, 701);
      RekRestore(vBuf707);
    END;

    RekRestore(vBuf701);
  end;

  Mode # c_ModeList;

  if (BA1_IO_I_Data:DeleteInput(false) = false) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN;
  end;

  TRANSOFF;

  BA1_P_Data:UpdateSort();
  cZList1->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
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
  vHdl  : int;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

/*
  debug(Aint(Bag.IO.Nummer) + ' Nach: ' + aFocusObject->wpName  + '  zu:' + aEvt:Obj->wpname);
  if (Bag.IO.Nummer = 0) then theore('BA Zuordnung verloren Fieldinit: nach: ' +aFocusObject->wpName + '  zu:' + aEvt:Obj->wpname);
*/
  if (aEvt:Obj->wpname='jump') then begin
    case (aEvt:Obj->wpcustom) of

      'nachDetail','nachTyp' : begin
        case (BAG.IO.Materialtyp) of
          c_IO_Mat : begin
            if (mode=c_ModeNew) then $edBAG.IO.Materialnr->winfocusset(true)
            else $edBAG.IO.Plan.Out.Stk_Mat->winfocusset(true);
          end;

          c_IO_VSB : begin
            if (mode=c_ModeNew) then $edBAG.IO.MaterialnrVSB->winfocusset(true)
            else $edBAG.IO.Plan.Out.Stk_VSB->winfocusset(true);
          end;

          c_IO_BAG : begin
            if (mode=c_ModeNew) then $edBAG.IO.VonID->winfocusset(true)
            else $edBAG.IO.Plan.Out.Stk_BAG->winfocusset(true);
          end;

          c_IO_Art, c_IO_Beistell : begin
            if (mode=c_ModeNew) then $edBAG.IO.Artikelnr_Art->winfocusset(true)
            else $edBAG.IO.Bemerkung_Art->winfocusset(true);
          end;

          c_IO_Theo : begin
           $edBAG.IO.Artikelnr_Theo->winfocusset(true);
          end;

          otherwise begin
            $edEinsatzTyp->Winfocusset(true);
          end;

        end;
      end;

    end;
    RETURN true;
  end;  // ...jump


  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);


  if (aEvt:Obj->wpname='edEinsatztyp') or (aEvt:Obj->wpname='edBAG.IO.VonID') then
    aEvt:Obj->wpreadonly # y;


  // automatisch "F9" drücken
  // 2023-07-04 MR 2396/161
  if (Mode<>c_Modecancel and Mode <> c_ModeEdit) and (aEvt:Obj->wpname='edBAG.IO.VonID') then begin
    if (aEvt:Obj->wpcustom<>'') then begin
      aEvt:Obj->wpcustom # '';
      Auswahl('Vorgaenger');
      RETURN true;
    end;
  end;

  // automatisch "F9" drücken
  if (Mode<>c_Modecancel) and (aEvt:Obj->wpname='edEinsatztyp') then begin

    if (aEvt:obj->wpcustom<>'') then begin
      vHdl # cnvia(aEvt:obj->wpcustom);
      aEvt:obj->wpcustom # '';
      Winfocusset(vHdl, true);
      RETURN true;
    end;

    aEvt:Obj->wpcustom # '';
    App_Main:Refreshmode();
    Auswahl('Einsatztyp');
    RETURN true;
/*
    if (gTimer2=0) then begin
      gTimer2 # SysTimerCreate(100,1,gMDI);
      w_TimerVar # 'Einsatztyp';
    end;
*/
    end;

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
  erx       : int;
  vID       : int;
  vX        : float;
  vName     : alpha;
  vMenge    : float;
  vCalcIn   : logic;
  vCalcOut  : logic;
  vL        : float;

  vaNr      : alpha;
  vNR       : int;
  v701      : int;
  vWin      : int;
  vI        : int;
  vHdl      : int;
  vStk      : int;
  vGew      : float;
end;
begin

  if (aEvt:Obj->wpname='bt.Einsatztyp') then RETURN true;


  // 16.09.2021 AH: manuelle Eingabe der Einsatz-Materialnr.
  if (aEvt:Obj->wpName='edMatEingabe') then begin
    if (WinInfo(aEvt:Obj, _WinFocusKey)=_WinKeyReturn) then begin
      Lib_berechnungen:Int1AusAlpha(aEvt:obj->wpcaption, var vID);
      aEvt:Obj->wpcaption # '';
      Winfocusset(aEvt:obj);
      vHdl # winsearch(Wininfo(aEvT:obj, _winParent), 'dl.Input');
      if (vID>0) and (vHdl>0) then begin
        FOR vI # 1 loop inc(vI) while (vI<=WinLstDatLineInfo(vHdl, _WinLstDatInfoCount)) do begin
          vHdl->WinLstCellGet(vNr,   2, vI);

          if (vNr<>vID) then CYCLE;       // richtige Materialnr?
          
          vHdl->WinLstCellGet(vStk, 9, vI);
          if (vStk<>1) then RETURN true;
          // nur 1 Stück möglich...
          vHdl->WinLstCellGet(vStk, 12, vI);
          if (vStk=1) then vStk # 0
          else vStk # 1;
          vHdl->WinLstCellSet(vStk, 12, vI);
        
          vHdl->WinLstCellGet(BAG.IO.ID,   1, vI);
          if (BAG.IO.ID>0) then begin
            BAG.IO.Nummer # BAG.P.Nummer;
            Erx # RecRead(701,1,0);   // Einsatz holen
            if (erx<=_rLocked) then begin
              if (BAG.IO.Plan.Out.Stk<>0) then begin
                vGew # BAG.IO.Plan.Out.GewN * cnvfi(vStk) / cnvfi(BAG.IO.Plan.Out.Stk);
                vHdl->WinLstCellSet(vGew,13,  _WinLstDatLineCurrent);
                vGew # BAG.IO.Plan.Out.GewB * cnvfi(vStk) / cnvfi(BAG.IO.Plan.Out.Stk);
                vHdl->WinLstCellSet(vGew,14,  _WinLstDatLineCurrent);
              end;
            end;
            BREAK;
          end;
        END;
      end;
    end;
    RETURN true;
  end;


  // direkte Eingabe?
  if (aEvt:Obj->wpname='edMaterialnr') then begin
    vWin # Wininfo(aEvt:obj, _winparent);
    if (vWin=0) then vWin # Winsearch(gFrmMain,Lib_Guicom:GetAlternativeName('BA1.FM.I.Auswahl'));
    if (vWin=0) then RETURN true;

    if (WinInfo(vWin,_WinFocusKey)=0) then
      if (aFocusObject<>0) then
        if (aFocusObject->wpname<>'Bt.OK') then RETURN true;


    vaNr # aEvt:Obj->wpcaption;

    if (vaNr='') then RETURN true;

    try begin
      ErrTryIgnore(_ErrCnv);
      vNr # cnvia(vaNr);
    end;
    ErrSet(_ErrOK);

    if (vNr=0) then RETURN false;

    v701 # RecBufCreate(701);
    FOR Erx # RecLink(v701, 702, 2, _recFirst);   // Input loopen
    LOOP Erx # RecLink(v701, 702, 2, _recNext);
    WHILE (Erx<=_rLocked) do begin
//      if (v701->BAG.IO.BruderID<>0) or (v701->BAG.P.Position=0) then CYCLE;
      if (v701->BAG.IO.Materialnr=vNr) then BREAK;
    END;
    if (Erx<=_rLocked) then begin
      RecBufCopy(v701,701);
      RecBufDestroy(v701);
      RefreshList($ZL.BAG.IO.Auswahl_IN, _WinLstRecFromRecid | _WinLstRecDoSelect);
      gSelected # $ZL.BAG.IO.Auswahl_IN->wpDbRecId;

      if (vWin=0) then RETURN false;
      vWin->winclose();
//      Msg(99,'FOUND!',0,0,0);
      RETURN true;
    end;
    RecBufDestroy(v701);

    Dlg_Standard:InfoBetrieb(Translate('FEHLER'),Translate('Materialnummer ist nicht als Einsatz bekannt!'),true);

    RETURN false;
  end;


  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  vName # aEvt:Obj->wpname;

  if (vName='edBAG.IO.Dickentol_Theo') and (BAG.IO.Dicke<>0.0) then begin
    "BAG.IO.Dickentol" # Lib_Berechnungen:Toleranzkorrektur("BAG.IO.Dickentol",Set.Stellen.Dicke);
    $edBAG.IO.Dickentol_Theo->Winupdate();
  end;
  if (vName='edBAG.IO.Breitentol_Theo') and (BAG.IO.Breite<>0.0) then begin
    "BAG.IO.Breitentol" # Lib_Berechnungen:Toleranzkorrektur("BAG.IO.Breitentol",Set.Stellen.Breite);
    $edBAG.IO.Breitentol_Theo->Winupdate();
  end;
  if (vName='edBAG.IO.Laengentol_Theo') and ("BAG.IO.Länge"<>0.0) then begin
    "BAG.IO.Längentol" # Lib_Berechnungen:Toleranzkorrektur("BAG.IO.Längentol","Set.Stellen.Länge");
    $edBAG.IO.Laengentol_Theo->Winupdate();
  end;

  if (vName='edBAG.IO.Plan.In.Stk_Theo') and (aEvt:Obj->wpchanged) then begin
    if (BAG.IO.Plan.Out.Stk=0) then begin
      BAG.IO.Plan.Out.Stk # aEvt:Obj->wpcaptionint;
      $edBAG.IO.Plan.Out.Stk_Theo->winupdate(_WinUpdFld2Obj);
    end;
    vCalcIn # y;
  end;

  if (vName='edBAG.IO.Plan.In.GewN_Theo') and (aEvt:Obj->wpchanged) then begin
    if (BAG.IO.Plan.Out.GewN=0.0) then begin
      BAG.IO.Plan.Out.GewN # aEvt:Obj->wpcaptionfloat;
      $edBAG.IO.Plan.Out.GewN_Theo->winupdate(_WinUpdFld2Obj);
    end;
    vCalcIn # y;
  end;

  if (vName='edBAG.IO.Plan.In.GewB_Theo') and (aEvt:Obj->wpchanged) then begin
    if (BAG.IO.Plan.Out.GewB=0.0) then begin
      BAG.IO.Plan.Out.GewB # aEvt:Obj->wpcaptionfloat;
      $edBAG.IO.Plan.Out.GewB_Theo->winupdate(_WinUpdFld2Obj);
    end;
    vCalcIn # y;
  end;

  if (vName='edBAG.IO.Guete_Theo') and (aEvt:Obj->wpchanged) then begin
    MQu_Data:Autokorrektur(var "BAG.IO.Güte");
    $edBAG.IO.Guete_Theo->Winupdate();
  end;

/* xxx
  if (vName='edBAG.IO.VonID') and (BAG.IO.Materialtyp=c_IO_BAG) then begin
    vID # BAG.IO.ID;
    // Einsatzfertigung prüfen
    BAG.IO.ID # BAG.IO.ID;
    Erx # RecRead(701,1,_RecTest);
    BAG.IO.ID # vID;
    if (Erx<>_rok) then begin
      RETURN false;
    end;
  end;
*/

  if ((vName='edBAG.IO.Plan.Out.Stk_Mat') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.Stk_Art') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.Stk_VSB') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.Stk_Theo') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.Stk_BAG') and (aEvt:Obj->wpchanged)) then begin
    if (BAG.IO.Plan.In.Stk<>0) then vX # BAG.IO.Plan.In.GewN / cnvfi(BAG.IO.Plan.In.Stk)
    else vX # 0.0;
    if (BAG.IO.PLan.Out.GewN=0.0) then
      BAG.IO.Plan.Out.GewN # Rnd(vX * cnvfi(BAG.IO.Plan.Out.Stk),0);

    if (BAG.IO.Plan.In.Stk<>0) then vX # BAG.IO.Plan.In.GewB / cnvfi(BAG.IO.Plan.In.Stk)
    else vX # 0.0;
    if (BAG.IO.PLan.Out.GewB=0.0) then
      BAG.IO.Plan.Out.GewB # Rnd(vX * cnvfi(BAG.IO.Plan.Out.Stk),0);

    if (BAG.IO.Plan.In.Stk<>0) then vX # BAG.IO.Plan.In.Menge / cnvfi(BAG.IO.Plan.In.Stk)
    else vX # 0.0;
    if (BAG.IO.PLan.Out.Meng=0.0) then
      BAG.IO.Plan.Out.Meng # Rnd(vX * cnvfi(BAG.IO.Plan.Out.Stk), Set.Stellen.Menge);

    $edBAG.IO.Plan.Out.GewN_Mat->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.GewB_Mat->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_Mat->Winupdate(_WinUpdFld2Obj);

    $edBAG.IO.Plan.Out.GewN_VSB->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.GewB_VSB->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_VSB->Winupdate(_WinUpdFld2Obj);

    $edBAG.IO.Plan.Out.GewN_BAG->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.GewB_BAG->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_BAG->Winupdate(_WinUpdFld2Obj);

    $edBAG.IO.Plan.Out.GewN_Theo->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.GewB_Theo->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_Theo->Winupdate(_WinUpdFld2Obj);

    $edBAG.IO.Plan.Out.GewN_Art->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_Art->Winupdate(_WinUpdFld2Obj);

    vCalcOut # Y;
  end;

  if ((vName='edBAG.IO.Plan.Out.GewB_Mat') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.GewB_BAG') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.GewB_VSB') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.GewB_Theo') and (aEvt:Obj->wpchanged)) then begin
    vCalcOut # y;
  end;

  if ((vName='edBAG.IO.Plan.Out.GewN_Mat') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.GewN_Art') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.GewN_VSB') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.GewN_BAG') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.GewN_Theo') and (aEvt:Obj->wpchanged)) then begin
    if (BAG.IO.Plan.In.GewN<>0.0) then vX # BAG.IO.Plan.Out.GewN / BAG.IO.PLan.In.GewN
    else vX # 0.0;
    if (vX<>0.0) and (BAG.IO.Plan.Out.Meng=0.0) then
      BAG.IO.Plan.Out.Meng # Rnd(vX * BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
    $edBAG.IO.Plan.Out.Meng_Mat->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_VSB->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_BAG->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_Theo->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_Art->Winupdate(_WinUpdFld2Obj);
    vCalcOut # y;
  end;

  if ((vName='edBAG.IO.Plan.Out.Meng_Mat') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.Meng_Art') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.Meng_VSB') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.Meng_BAG') and (aEvt:Obj->wpchanged)) or
    ((vName='edBAG.IO.Plan.Out.Meng_Theo') and (aEvt:Obj->wpchanged)) then begin
    if (BAG.IO.PLan.In.Menge<>0.0) then vX # BAG.IO.Plan.Out.Meng / BAG.IO.Plan.In.Menge
    else vX # 0.0;
    if (vX<>0.0) and (BAG.IO.PLan.Out.GewN=0.0) then
      BAG.IO.Plan.Out.GewN # Rnd(vX * BAG.IO.Plan.In.GewN, Set.Stellen.Gewicht);
    $edBAG.IO.Plan.Out.GewN_Mat->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.GewN_Art->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.GewN_VSB->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.GewN_BAG->Winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.GewN_Theo->Winupdate(_WinUpdFld2Obj);
  end;



  if (vCalcIN) then begin
    if (BAG.IO.Plan.In.Menge=0.0) then begin
      vMenge # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.IN.Stk, BAG.IO.Plan.IN.GewN, BAG.IO.PLan.In.GewN, 'kg', BAG.IO.MEH.In);
      BAG.IO.Plan.In.Menge # Rnd(vMenge, Set.Stellen.Menge);
      $lb.IO.IstMenge_Mat->wpcaption # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
      $lb.IO.IstMenge_BAG->wpcaption # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
      $lb.IO.IstMenge_VSB->wpcaption # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
      $edBAG.IO.Plan.In.Menge_Theo->Winupdate(_WinUpdFld2Obj);
    end;
  end;

  if (vCalcOut) then begin
    if (BAG.IO.Plan.Out.Meng=0.0) then begin
      vMenge # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.OUT.GewN, BAG.IO.PLan.OUT.GewN, 'kg', BAG.IO.MEH.Out);
      BAG.IO.Plan.Out.Meng # Rnd(vMenge, Set.Stellen.Menge);
      $edBAG.IO.Plan.Out.Meng_Mat->winupdate(_WinupdFld2Obj);
      $edBAG.IO.Plan.Out.Meng_Art->winupdate(_WinUpdFld2Obj);
      $edBAG.IO.Plan.Out.Meng_BAG->winupdate(_WinupdFld2Obj);
      $edBAG.IO.Plan.Out.Meng_VSB->winupdate(_WinupdFld2Obj);
      $edBAG.IO.Plan.Out.Meng_Theo->Winupdate(_WinUpdFld2Obj);
    end;
  end;

  if (vCalcIn) or
    ((vName='edBAG.IO.Plan.In.Menge_Theo') and (aEvt:Obj->wpchanged)) then begin
    if (BAG.IO.Plan.Out.Meng=0.0) then begin
      BAG.IO.Plan.Out.Meng # BAG.IO.Plan.IN.Menge;//aEvt:Obj->wpcaptionfloat;
      $edBAG.IO.Plan.Out.Meng_Mat->winupdate(_WinUpdFld2Obj);
      $edBAG.IO.Plan.Out.Meng_Art->winupdate(_WinUpdFld2Obj);
      $edBAG.IO.Plan.Out.Meng_BAG->winupdate(_WinUpdFld2Obj);
      $edBAG.IO.Plan.Out.Meng_VSB->winupdate(_WinUpdFld2Obj);
      $edBAG.IO.Plan.Out.Meng_Theo->winupdate(_WinUpdFld2Obj);
    end;
  end;


  if (BAG.IO.MEH.Out='kg') then begin
    BAG.IO.Plan.Out.Meng # BAG.IO.Plan.Out.GewN;
    $edBAG.IO.Plan.Out.Meng_Mat->winupdate(_WinupdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_Art->winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_VSB->winupdate(_WinupdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_BAG->winupdate(_WinupdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_Theo->winupdate(_WinupdFld2Obj);
  end;
  if (BAG.IO.MEH.Out='Stk') then begin
    BAG.IO.Plan.Out.Meng # cnvfI(BAG.IO.Plan.Out.Stk);
    $edBAG.IO.Plan.Out.Meng_Mat->winupdate(_WinupdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_Art->winupdate(_WinUpdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_VSB->winupdate(_WinupdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_BAG->winupdate(_WinupdFld2Obj);
    $edBAG.IO.Plan.Out.Meng_Theo->winupdate(_WinupdFld2Obj);
  end;

  if (BAG.IO.MEH.In='kg') then begin
    BAG.IO.Plan.In.Menge # BAG.IO.Plan.In.GewN;
    $lb.IO.IstMenge_Mat->wpcaption # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
    $lb.IO.IstMenge_BAG->wpcaption # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
    $lb.IO.IstMenge_VSB->wpcaption # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
    $edBAG.IO.Plan.In.Menge_Theo->winupdate(_WinupdFld2Obj);
  end
  else if (BAG.IO.MEH.In='Stk') then begin
    BAG.IO.Plan.In.Menge # cnvfI(BAG.IO.Plan.In.Stk);
    $lb.IO.IstMenge_Mat->wpcaption # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
    $lb.IO.IstMenge_BAG->wpcaption # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
    $lb.IO.IstMenge_VSB->wpcaption # ANum(BAG.IO.Plan.In.Menge, Set.Stellen.Menge);
    $edBAG.IO.Plan.In.Menge_Theo->winupdate(_WinupdFld2Obj);
  end;


  if (aEvt:Obj->wpname='edEinsatztyp') or (aEvt:Obj->wpname='edBAG.IO.VonID') then
    aEvt:Obj->wpreadonly # n;

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
  Erx       : int;
  vHdl      : int;
  vA        : alpha;
  vBAG      : int;
  vVonBAG   : int;
  vPos      : int;
  vFert     : int;
  vID       : int;
  vBuf701   : handle;
  vBuf702   : handle;
  vBem      : alpha;
  vGew      : float;
  vStk      : int;
  vMenge    : float;
  vLen      : float;
  vfilter   : int;
  vSel      : handle;
  vSelName  : alpha;
  vQ        : alpha(4000);
  v400, v100  : int;
end;
begin

  // AFX
  if (RunAFX('BAG.IO.In.Auswahl',aBereich)<0) then RETURN;

  case aBereich of

    'Einsatztyp' : begin
      Lib_Einheiten:Popup('BAG-EINSATZ',$edEinsatztyp,701,1,11);
      if (BAG.IO.Materialtyp=0) then RETURN;

      BAG.IO.VonBAG         # 0;
      BAG.IO.VonPosition    # 0;
      BAG.IO.VonFertigung   # 0;
      BAG.IO.VonID          # 0;
      BAG.IO.Artikelnr      # '';
      BAG.IO.Charge         # '';
      BAG.IO.Lageradresse   # 0;
      BAG.IO.Lageranschr    # 0;
      BAG.IO.Materialnr     # 0;

      SwitchMask();

      // 07.10.2009 MS bei Weiterbearbeitung direkt die Auswahl der Weiterbearbeitungen anzeigen
      case BAG.IO.Materialtyp of
        c_IO_Mat      : $edBAG.IO.Materialnr->winfocusset(true);
        c_IO_VSB      : $edBAG.IO.MaterialnrVSB->winfocusset(true);
        c_IO_Art      : $edBAG.IO.Artikelnr_Art->winfocusset(true);
        c_IO_Beistell : $edBAG.IO.Artikelnr_Art->winfocusset(true);
        c_IO_Theo     : $edBAG.IO.Warengruppe_Theo->winfocusset(true);
        c_IO_BAG      : $edBAG.IO.VonID->winfocusset(true);
//        otherwise       $edEinsatztyp->winfocusset(true);
      end;

      vHdl # Winfocusget();
      $edEinsatztyp->wpcustom # aint(vHdl);
    end;


    'Material' : begin
      RecBufClear(200);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');

      // LOHN? Dann Filtern   29.06.2018 AH
      if (BAG.P.Auftragsnr<>0) then begin
        v400 # RecBufCreate(400);
        v400->Auf.Nummer # BAG.P.Auftragsnr;
        Erx # RecRead(v400,1,0);                  // Auftrag holen
        if (Erx<=_rLocked) then begin
          v100 # RecBufCreate(100);
          Erx # RecLink(v100,v400,1,_recFirst);   // Kunde holen
          if (Erx<=_rLocked) then begin
            VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
            vQ # '';
            Lib_Sel:QAlpha(var vQ, '"Mat.Löschmarker"', '=', '');
            Lib_Sel:QInt(var vQ, 'Mat.Lieferant', '=', v100->Adr.LieferantenNr);
            Lib_Sel:QVonBisI(var vQ, 'Mat.Status', c_Status_Frei, c_Status_BisFrei);
            Lib_Sel:QRecList(0,vQ);
          end;
          RecBufDestroy(v100);
        end;
        RecBufDestroy(v400);
      end;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MaterialVSB' : begin
      RecBufClear(200);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterialVSB');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Mat.Status'  , '=', c_Status_EKVSB);
      Lib_Sel:QInt(var vQ, 'Mat.Status'  , '=', c_Status_EK_Konsi, 'OR');
      vHdl # SelCreate(200, gKey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikel_Art' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      Art.Nummer  # BAG.IO.Artikelnr;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel_Art');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikel_Theo' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      Art.Nummer  # BAG.IO.Artikelnr;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel_Theo');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Charge' : begin
      Erx # RecLink(250,701,8,_recFirsT);   // Artikel holen
      if (Erx>_rLocked) then RETURN;
      
      // 15.11.2021 AH
      if (Wgr_data:IstMix()) then begin
        RecBufClear(200);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        RecBufClear(998);
        Sel.Art.von.ArtNr # Art.Nummer;
        vQ # '';
        Lib_Sel:QAlpha( var vQ, 'Mat.Strukturnr', '=', Sel.Art.von.ArtNr);
        Lib_Sel:QRecList(0,vQ);
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end;

      RecBufClear(252);         // ZIELBUFFER LEEREN
//debug('----------------starte aus '+gMDI->wpname);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Art.C.Verwaltung',here+':AusCharge');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
/*
      vFilter # RecFilterCreate(252,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,BAG.IO.Artikelnr);
      vFilter->RecFilterAdd(2,_FltAND,_FltAbove,0);
      vFilter->RecFilterAdd(4,_FltAND,_FltAbove,'');
      gZLList->wpDbFilter # vFilter;
      gKey # 1;
*/
      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', BAG.IO.Artikelnr);
      Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
      Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
      Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
      vHdl # SelCreate(252, gKey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zustand' : begin
      RecBufClear(856);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Zst.Verwaltung',here+':AusZustand');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Vorgaenger','Vorgaenger2' : begin
      vBAG # BAG.Nummer;

      gSelected # 0;

      // andere Position auswählen
      vBuf702 # RekSave(702);
      if (BAG.IO.VonBAG<>0) then
        BAG.Nummer # BAG.IO.VonBAG;
      RecRead(700,1,0);
      vHdl # WinOpen('BA1.P.Auswahl',_WinOpenDialog);

      vSel # SelCreate(702,1);
      vSelName # Lib_Sel:Save(vSel,'');
      vSel # SelOpen();
      SelRead(vSel,702,_SelLock,vSelName);

      vBuf701 # RecBufCreate(701);
      Erx # RecLink(702,700,1,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        if (BAG.P.Nummer<>vBuf702->BAG.P.Nummer) or
          (BAG.P.Position<>vBuf702->BAG.P.Position) then begin
          Erx # RecLink(vBuf701,702,3,_RecFirst);
          WHILE (Erx<=_rLocked) do begin
            if (vBuf701->BAG.IO.NachBAG=0) then begin
              Erx # SelRecInsert(vSel,702);
              BREAK;
            end;
            Erx # RecLink(vBuf701,702,3,_RecNext);
          END;
        end;
        Erx # RecLink(702,700,1,_recNext);
      END;
      RecBufDestroy(vBuf701);

      $ZL.BAG.P.Auswahl->wpDbLinkFileNo # 0;
      $ZL.BAG.P.Auswahl->wpDbFileno     # 702;
      $ZL.BAG.P.Auswahl->wpDbSelection  # vSel;

      vHdl->WinDialogRun(_WinDialogCenter,gMDI);
      WinClose(vHdl);
      vSel->Selclose();
      Erx # SelDelete(702,vSelName);

      BAG.Nummer # vBAG;
      RecRead(700,1,0);

      if (gSelected=0) then begin
        RekRestore(vBuf702);
        RETURN;
      end;


      RecRead(702,0,_RecId,gSelected);
      gSelected # 0;
      vPos # BAG.P.Position;

      // Output auswählen
      vBuf701 # RekSave(701);
      vHdl # WinOpen('BA1.IO.Auswahl',_WinOpenDialog);
      vHdl->WinDialogRun(_WinDialogCenter,gMDI);
      WinClose(vHdl);
      if (gSelected=0) then begin
        RekRestore(vBuf701);
        RekRestore(vBuf702);
        RETURN;
      end;

      RecRead(701,0,_RecId,gSelected);
      gSelected # 0;
      vFert   # BAG.IO.VonFertigung;
      vID     # BAG.IO.ID;
      vVonBAG # BAG.IO.Nummer;

      vBuf701->BAG.IO.VonID         # vID;
      vBuf701->BAG.IO.VonBAG        # vVOnBAG;
      vBuf701->BAG.IO.VonPosition   # vPos
      vBuf701->BAG.IO.VonFertigung  # vFert;

      vBuf701->BAG.IO.Auftragsnr     # BAG.IO.Auftragsnr;
      vBuf701->BAG.IO.AuftragsPos    # BAG.IO.AuftragsPos;
      vBuf701->BAG.IO.AuftragsPos    # BAG.IO.AuftragsFert;

      vBuf701->BAG.IO.Bemerkung     # BAG.IO.Bemerkung;
      vBuf701->BAG.IO.Plan.In.GewN  # BAG.IO.Plan.In.GewN;
      vBuf701->BAG.IO.Plan.In.GewB  # BAG.IO.Plan.In.GewB;
      vBuf701->BAG.IO.Plan.In.Stk   # BAG.IO.Plan.In.Stk;

      vBuf701->BAG.IO.Lageradresse  # BAG.IO.Lageradresse;
      vBuf701->BAG.IO.Lageranschr   # BAG.IO.Lageranschr;

      vBuf701->"BAG.IO.Güte"        # "BAG.IO.Güte";
      vBuf701->"BAG.IO.GütenStufe"  # "BAG.IO.Gütenstufe";
      vBuf701->BAG.IO.Dicke         # BAG.IO.Dicke;
      vBuf701->BAG.IO.Breite        # BAG.IO.Breite
      vBuf701->BAG.IO.SpulBreite    # BAG.IO.SpulBreite
      vBuf701->"BAG.IO.Länge"       # "BAG.IO.Länge";
      vBuf701->BAG.IO.Dickentol     # BAG.IO.DickenTol;
      vBuf701->BAG.IO.Breitentol    # BAG.IO.Breitentol;
      vBuf701->"BAG.IO.Längentol"   # "BAG.IO.Längentol";
      vBuf701->BAG.IO.Warengruppe   # BAG.IO.Warengruppe;
      vBuf701->BAG.IO.MEH.IN        # BAG.IO.MEH.IN;
      vBuf701->BAG.IO.Plan.In.Menge # BAG.IO.Plan.In.Menge;

      RekRestore(vBuf701);
      RekRestore(vBuf702);

      // 22.05.2014
//      BAG.IO.MEH.Out         # BA1_P_Data:ErmittleMEH();
// 10.11.2016 AH
      BAG.IO.MEH.Out # BAG.IO.MEH.In;
//BAG.IO.MEH.Out         # BA1_P_Data:ErmittleMEH();


      BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
      BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
      BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
      // 22.05.2014
//      BAG.IO.PLan.Out.Meng  # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.Out.GewN, BAG.IO.PLan.Out.GewN, 'kg', BAG.IO.MEH.Out);
      BAG.IO.PLan.Out.Meng  # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.Out.GewN, BAG.IO.PLan.in.Menge, BAG.IO.MEH.IN, BAG.IO.MEH.Out);

      $lb.IO.MEH.Out.FM_Mat->WinUpdate(_WinUpdFld2Obj);
      $lb.IO.MEH.Out.FM_BAG->WinUpdate(_WinUpdFld2Obj);
      $lb.IO.MEH.Out.FM_VSB->WinUpdate(_WinUpdFld2Obj);
      $lb.IO.MEH.Out.FM_Theo->WinUpdate(_WinUpdFld2Obj);
      $edBAG.IO.Plan.Out.Stk_BAG->winupdate(_WinupdFld2Obj);
      $edBAG.IO.Plan.Out.GewN_BAG->winupdate(_WinupdFld2Obj);
      $edBAG.IO.Plan.Out.GewB_BAG->winupdate(_WinupdFld2Obj);
      $edBAG.IO.Plan.Out.Meng_BAG->winupdate(_WinupdFld2Obj);
      $edBAG.IO.VonBAG->winupdate(_WinupdFld2Obj);
      $edBAG.IO.VonID->wpcaptionint # vID;

      //SwitchMask();
      //cDialog->Winupdate();
      RefreshIfm('');
      // auf Stückzahl positionieren
      $edBAG.IO.Plan.Out.Stk_BAG->WinFocusset(true);
// f9
    end;  // ...Vorgaenger


    'WGR' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWgr');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guete' : begin
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'GuetenStufe' : begin
      RecBufClear(848);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenStufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageradresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLager');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageranschrift' : begin
      RecLink(100,701,5,0);     // Lageradresse holen
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusAnschrift');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
      vHdl # SelCreate(101, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial()
local begin
  vTmp : int;
end;
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);     // 19.05.2022 AH: war cDialog auch bei Folgenden
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;

    // Feldübernahme
    BAG.IO.Materialnr     # Mat.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edBAG.IO.Materialnr',y);
  end;

  getRinglRad();

  // Focus auf Editfeld setzen:
  $edBAG.IO.Materialnr->Winfocusset(false);
end;


//========================================================================
//  AusMaterialVSB
//
//========================================================================
sub AusMaterialVSB()
local begin
  vTmp : int;
end;
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;

    // NUR VSB erlauben!!!
    if (Mat.Status=c_Status_EKVSB) or (Mat.Status=c_Status_EK_Konsi) then begin
      BAG.IO.Materialnr     # Mat.Nummer;
    end;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edBAG.IO.MaterialnrVSB',y);
  end;

  // Focus auf Editfeld setzen:
  $edBAG.IO.MaterialnrVSB->Winfocusset(false);
end;


//========================================================================
//========================================================================
sub AusMarkMaterial()
local begin
  vOK : logic;
end;
begin
  if (gSelected=0) then RETURN;
  gSelected # 0;
  
  vOK # BA1_IO_I_Data:InsertMarkedMat();
  ErrorOutput;
  gZLList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect | _WinLstPosSelected);
  if (vOK) then Msg(999998,'',0,0,0);
end;


//========================================================================
//  AusArtikel_Art
//
//========================================================================
sub AusArtikel_art()
local begin
  vTmp : int;
end;
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;

    // Feldübernahme
    BAG.IO.Artikelnr      # Art.Nummer;
    BAG.IO.MEH.In         # Art.MEH;
    BAG.IO.MEH.Out        # Art.MEH;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edBAG.IO.Artikelnr_Art',y);
  end;

  // Focus auf Editfeld setzen:
  $edBAG.IO.Artikelnr_Art->Winfocusset(true);
end;


//========================================================================
//  AusCharge
//
//========================================================================
sub AusCharge()
local begin
  vTmp : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(252,0,_RecId,gSelected);
    gSelected # 0;

    // Feldübernahme
    BAG.IO.Artikelnr    # Art.C.Artikelnr;
    BAG.IO.Charge       # Art.C.Charge.intern;
    BAG.IO.Lageradresse # Art.C.Adressnr;
    BAG.IO.Lageranschr  # Art.C.Anschriftnr;
    BAG.IO.Art.Zustand  # Art.C.Zustand;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);

    RefreshIfm('edBAG.IO.Charge',y);
    gMDI->WinUpdate(_WinUpdFld2Obj);
  end;

  // Focus auf Editfeld setzen:
  $edBAG.IO.Artikelnr_Art->Winfocusset(true);
end;


//========================================================================
//  AusArtikel_Theo
//
//========================================================================
sub AusArtikel_Theo()
local begin
  vTmp : int;
end;
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;

    // Feldübernahme
    BAG.IO.Artikelnr      # Art.Nummer;
    BAG.IO.MEH.In         # Art.MEH;    // 2022-12-19 AH
    BAG.IO.MEH.Out        # Art.MEH;    // 2022-12-19 AH

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edBAG.IO.Artikelnr_Theo',y);
  end;

  // Focus auf Editfeld setzen:
  $edBAG.IO.Artikelnr_Theo->Winfocusset(false);
end;


//========================================================================
//  AusZustand
//
//========================================================================
sub AusZustand()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(856,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.IO.ARt.Zustand # Art.Zst.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edBAG.IO.Art.Zustand->Winfocusset(false);
end;


//========================================================================
//  AusWgr
//
//========================================================================
sub AusWgr()
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    BAG.IO.Warengruppe  # Wgr.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.IO.Warengruppe_Theo->Winfocusset(false);
end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
local begin
  vTmp : int;
end;
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "BAG.IO.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "BAG.IO.Güte" # "MQu.Güte1"
    else
      "BAG.IO.Güte" # "MQu.Güte2";
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edBAG.IO.Guete_Theo->Winfocusset(false);
end;

//========================================================================
//  AusGuetenStufe
//
//========================================================================
sub AusGuetenStufe()
local begin
  vTmp : int;
end;
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    // Feldübernahme
    "BAG.IO.GütenStufe" # MQu.S.Stufe;

    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edBAG.IO.GuetenStufe_Theo->Winfocusset(false);
end;


//========================================================================
//  AusLager
//
//========================================================================
sub AusLager()
local begin
  vTmp : int;
end;
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    BAG.IO.Lageradresse # Adr.Nummer;
    BAG.IO.Lageranschr  # 1;
    gSelected # 0;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  if (BAG.IO.MaterialTyp=c_IO_Theo) then
    $edBAG.IO.Lageradresse_Theo->Winfocusset(false);
  if (BAG.IO.MaterialTyp=c_IO_Art) then
    $edBAG.IO.Lageradresse_Art->Winfocusset(false);
end;


//========================================================================
//  AusAnschrift
//
//========================================================================
sub AusAnschrift()
local begin
  vTmp : int;
end;
begin
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    BAG.IO.Lageradresse # Adr.A.Adressnr;
    BAG.IO.Lageranschr  # Adr.A.Nummer;
    gSelected # 0;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  if (BAG.IO.MaterialTyp=c_IO_Theo) then
    $edBAG.IO.Lageranschr_Theo->Winfocusset(false);
  if (BAG.IO.MaterialTyp=c_IO_Art) then
    $edBAG.IO.Lageranschr_Art->Winfocusset(false);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl        : int;
  vHdl2       : int;
  vOK         : logic;
end
begin
  // 29.08.2021 AH
  //Ba1_Combo_Main:Refreshmode();
  Call(Lib_Guicom:GetAlternativeMain(gMDI, 'BA1_Combo_Main')+':RefreshMode');

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Graphnotebook richtig setzen
  vHdl # gMdi->WinSearch('NB.Graph');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_modeEdit) or (Mode=c_modeNew);

  vOK # (RecLinkInfo(701,702,2,_recCount)=0) or (BA1_P_Data:DarfNur1EinsatzHaben(BAG.P.Aktion)=false);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or (vOK=false);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or (vOK=false);
  vHdl2 # gMenu->WinSearch('Mnu.Input.Klonen');
  if (vHdl2 <> 0) then
    vHdl2->wpDisabled # vHdl->wpDisabled;
  vHdl2 # gMenu->WinSearch('Mnu.Input.AusMatMark');
  if (vHdl2 <> 0) then
    vHdl2->wpDisabled # vHdl->wpDisabled;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);    // 16.06.2020 AH: Recht DOCH nutzen !
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

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
  Erx     : int;
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vQ      : alpha(4000);
  vBuf701 : handle;
  vTmp    : int;
  vOK     : logic;
end;
begin

  if (Mode=c_ModeList) then begin
    Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
    if (Erx>_rLocked) then RecBufClear(gFile);
  end;
  case (aMenuItem->wpName) of

    'Mnu.Edit.Menge' : begin
      BA1_I_Subs:Mengenkorrektur();
      cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      cZList3->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
      cZList4->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    end;


    'Mnu.Input.InsMatMark' : begin  // 24.10.2018 AH
      RecBufClear(200);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMarkMaterial');
      Lib_GuiCom:RunChildWindow(gMDI);
      RETURN true;
    end;
    
    
    'Mnu.Input.WirdTheo' : begin
      if (BAG.IO.Materialtyp=c_IO_Mat) or (BAg.IO.Materialtyp=c_IO_VSB) then begin
        BA1_IO_I_Data:EchtWirdTheorie(BAG.IO.ID);
        ErrorOutput;
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect | _WinLstPosSelected);
        RETURN true;
      end;
    end;


    'Mnu.Input.WirdMat' : begin
      if (BAG.IO.Materialtyp=c_IO_Theo) then begin
        BA1_IO_I_Data:TheorieWirdEcht(BAG.IO.ID);
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect | _WinLstPosSelected);
        RETURN true;
      end;
    end;


    'Mnu.Input.Klonen' : begin
      if (BAG.IO.ID<>0) then begin
/**
if (gUsernamE='AH') then begin
if (BAG.IO.Materialtyp=c_IO_Mat) then begin
todo('aus echt wird theorie!');
  BA1_IO_I_Data:EchtWirdTheorie(BAG.IO.ID);
  end
  else if (BAG.IO.Materialtyp=c_IO_Theo) then begin
todo('aus THEO wird echt');
  BA1_IO_I_Data:TheorieWirdEcht(BAG.IO.ID);
//w_Command # 'TheorieWirdEcht';
//        w_AppendNr # BAG.IO.ID;
//        App_Main:Action(c_ModeNew);
        RETURN true;
  end;

  gZLList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect | _WinLstPosSelected);
  RETURN true;
end;
**/

        w_AppendNr # BAG.IO.ID;
        App_Main:Action(c_ModeNew);
      end;
      RETURN true;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(701,BAG.IO.Anlage.Datum, BAG.IO.Anlage.Zeit, BAG.IO.Anlage.User);
    end;


    'Mnu.Reservierungen' : begin
      if (BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Materialtyp=c_IO_VSB) then begin
        Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
        if (Erx>=200) then begin
          RecBufClear(203);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Rsv.Verwaltung','',y);
          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
          vTmp # winsearch(gMDI, 'NB.Main');
          vTmp->wpcustom # 'MAT';
          gZLList->wpdbfileno     # 200;
          gZLList->wpdbkeyno      # 13;
          gZLList->wpdbLinkFileNo # 203;
          // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
          gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
          Lib_GuiCom:RunChildWindow(gMDI);
        end;
      end;
    end;


    'Mnu.Verwiegungen' : begin
      if (Rechte[Rgt_BAG_FM]=false) then RETURN false;
      BA1_FM_Main:Start(BAG.IO.Nummer, BAG.IO.NachPosition, 0, BAG.IO.ID, '', y);
/***
      RecBufClear(707);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.FM.Verwaltung','',y);

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      $ZL.BA1.FM->wpDbFileNo      # 707;
      $ZL.BA1.FM->wpDbKeyNo       # 1;
      gKey # 1;
      $ZL.BA1.FM->wpDbLinkFileNo  # 0;

      // Selektion aufbauen...
      if (BAG.IO.Materialtyp<>c_IO_BAG) then begin
        vQ # '';
        vQ # vQ + 'BAG.FM.InputBAG = '+AInt(BAG.IO.Nummer)+' AND';
        vQ # vQ + ' BAG.FM.InputID = '+AInt(BAG.IO.ID)
        //vQ # vQ + ' (BAG.FM.InputID = '+AInt(BAG.IO.ID)+' OR BAG.FM.BruderID = '+AInt(BAG.IO.ID)+')';
        vHdl # SelCreate(707, gKey);
        Erx # vHdl->SelDefQuery('', vQ);
        if (Erx != 0) then Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      end
      else begin
        vBuf701 # RekSave(701);
        // Selektion aufbauenn...
        vHdl # SelCreate(707, gKey);
        w_SelName # Lib_Sel:Save(vHdl);         // speichern mit temp. Namen
        vHdl # SelOpen();                       // Selektion öffnen
        Erx # vHdl->selRead(707,_SelLock,w_SelName);  // Selektion laden
        Erx # RecLink(707,702,5,_recfirst);     // Fertigmeldungen loopen
        WHIlE (Erx<=_rLocked) do begin
          Erx # RecLink(701,707,9,_recFirst);  // BruderOutput holen
          if (Erx<=_rLocked) then begin
            BAG.IO.ID # BAG.IO.BruderID;
            Erx # RecRead(701,1,0);
            if (Erx<=_rLocked) and (BAG.IO.ID=vBuf701->BAG.IO.ID) then
              SelRecInsert(vHdl,707);
           end;
          Erx # RecLink(707,702,5,_recNext);
        END;
        RekRestore(vBuf701);
      end;

      // Liste selektieren...
      $ZL.BA1.FM->wpDbSelection # vHdl;

      $lb.BAG->wpCaption # AInt( BAG.IO.NachBAG) + '/' + aInt( BAG.IO.NachPosition );
      Lib_GuiCom:RunChildWindow(gMDI);
***/
    end;


    'Mnu.Verpackungen' : begin
      RecBufClear(704);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.V.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end


    'Mnu.Graph' : RETURN BA1_Combo_Main:EvtMenuCommand(aEvt, aMenuItem);


    'Mnu.Ktx.Errechnen' : begin

      // ST 2016-03-01 Projekt 1594/10 WSB
      if (aEvt:Obj->wpname='edBAG.IO.Plan.In.Stk_Theo') then begin
        BAG.IO.Plan.In.Stk # Lib_Berechnungen:STK_aus_KgDBLWgrArt(
            BAG.IO.Plan.In.GewN,
            BAG.IO.Dicke,
            BAG.IO.Breite,
            "BAG.IO.Länge",
            BAG.IO.Warengruppe, "BAG.IO.Güte",
            BAG.IO.Artikelnr);
        $edBAG.IO.Plan.In.Stk_Theo->winupdate(_WinUpdFld2Obj);
      end;


    end;

  end; // case

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vA  : alpha;
  vDL : int;
  Erx : int;
  vI  : int;
end;
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Alles'              : begin   // 2023-01-26 AH
      vDL # $dl.Input;
      if (vDL<>0) then begin
        FOR vI # 1 loop inc(vI) while (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
          //vHdl->WinLstCellGet(vNr,   2, vI);
          ToggleLine(vDL, vI);
        END;

      end;
    end;
    'bt.Einsatztyp'         :   Auswahl('Einsatztyp');
    'bt.Material'           :   Auswahl('Material');
    'bt.Artikel_Art'        :   Auswahl('Artikel_Art');
    'bt.Charge'             :   Auswahl('Charge');
    'bt.MaterialVSB'        :   Auswahl('MaterialVSB');
    'bt.Vorgaenger'         :   Auswahl('Vorgaenger');
    'bt.WGR_Theo'           :   Auswahl('WGR');
    'bt.Guete_Theo'         :   Auswahl('Guete');
    'bt.GuetenStufe_Theo'   :   Auswahl('GuetenStufe');
    'bt.Lageradresse_Theo'  :   Auswahl('Lageradresse');
    'bt.Lageranschr_Theo'   :   Auswahl('Lageranschrift');
    'bt.Zustand_Art'        :   Auswahl('Zustand');
    'bt.Lageradresse_Art'   :   Auswahl('Lageradresse');
    'bt.Lageranschr_Art'    :   Auswahl('Lageranschrift');
  end;

  if (aEvt:Obj->wpname='bt.InternerText') then begin
    // 04.06.2021 AH: Fix für >999
    if (BAG.IO.ID<999) then
      vA # '~701.'+CnvAI(BAG.IO.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+
            CnvAI(BAG.IO.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
    else
      vA # '~701.'+CnvAI(BAG.IO.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+
            CnvAI(BAG.IO.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,5);
    Mdi_TxtEditor_Main:Start(vA, Rechte[Rgt_BAG_Aendern], Translate('Bemerkung'));
  end;


end;


//========================================================================
//  EvtChanged
//              Feldinhalt verändert
//========================================================================
sub EvtChanged (
  aEvt                  : event;        // Ereignis
) : logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  aEvt:Obj->winupdate(_WinUpdObj2Fld);

  case aEvt:obj->wpname of

    'cbBAG.IO.AutoTeilungYN_Mat',
    'cbBAG.IO.AutoTeilungYN_VSB',
    'cbBAG.IO.AutoTeilungYN_BAG',
    'cbBAG.IO.AutoTeilungYN_Theo' : begin
      if (BAG.IO.AutoTeilungYN) then begin
        Lib_GuiCom:Disable($edBAG.IO.Teilungen_Mat);
        Lib_GuiCom:Disable($edBAG.IO.Teilungen_BAG);
        Lib_GuiCom:Disable($edBAG.IO.Teilungen_VSB);
        Lib_GuiCom:Disable($edBAG.IO.Teilungen_Theo);
      end
      else begin
        Lib_GuiCom:Enable($edBAG.IO.Teilungen_Mat);
        Lib_GuiCom:Enable($edBAG.IO.Teilungen_BAG);
        Lib_GuiCom:Enable($edBAG.IO.Teilungen_VSB);
        Lib_GuiCom:Enable($edBAG.IO.Teilungen_Theo);
      end;
    end;

   'edBAG.IO.Teilungen_Mat' : begin
     getRinglRad();
   end;

  end;  // case


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
  RETURN BA1_Combo_Main:EvtPageSelect(aEvt, aPage, aSelecting);
end;


//========================================================================
//========================================================================
sub AuswahlEvtInit(
  aEvt                  : event;
) : logic;
begin
  RunAFX('BAG.IO.I.AuswahlEvtInit.Pre',aint(aEvt:obj));

  Lib_GuiCom:RecallList($ZL.BAG.IO.Auswahl_IN);     // Usersettings holen
  RETURN(true);
end;


//========================================================================
//========================================================================
sub AuswahlEvtClose(
  aEvt                  : event;
): logic
begin
  Lib_GuiCom:RememberList($ZL.BAG.IO.Auswahl_IN);
  RETURN true;
end;


//========================================================================
//  AuswahlEvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub AuswahlEvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
local begin
  vTmp : int;
end;
begin

  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;

    vTmp # Wininfo(aEvt:obj, _winparent);
    if (vTmp=0) then vTmp # Winsearch(gFrmMain,'BA1.IO.Auswahl');
    if (vTmp=0) then vTmp # Winsearch(gFrmMain,Lib_Guicom:GetAlternativeName('BA1.FM.I.Auswahl'));
    if (vTmp=0) then vTmp # Winsearch(gFrmMain,'BA1.FM.O.Auswahl');
    if (vTmp<>0) then vTmp->Winclose();
  end;

end;


//========================================================================
//  AuswahlEvtLstDataInit
//
//========================================================================
sub AuswahlEvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
begin

  if (RunAFX('BA1.IO.I.AW.LstDInit','')<>0) then RETURN;


  Gv.Alpha.01 # AInt(BAG.IO.Materialnr);
  Gv.Alpha.02 # ANum(BAG.IO.Plan.In.Menge,Set.Stellen.Menge)+' '+BAG.IO.MEH.Out;
  Gv.Alpha.03 # ANum(BAG.IO.Plan.In.Menge-BAG.IO.Ist.Out.Menge,Set.Stellen.Menge)+' '+BAG.IO.MEH.Out;
  Gv.Alpha.04 # ANum(BAG.IO.Plan.In.GewN,Set.Stellen.Menge)+' kg';
  Gv.Alpha.05 # ANum(BAG.IO.Plan.In.GewN-BAG.IO.Ist.Out.GewN,Set.Stellen.Menge)+' kg';

  GV.Alpha.06 # '';
  GV.Alpha.07 # '';
  GV.Alpha.08 # '';
  GV.Alpha.09 # '';

  if (BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Materialtyp=c_IO_VSB) then begin
    if  (Mat_Data:Read(BAG.IO.Materialnr)>=200) then begin // Einsatzmaterial holen
    // 18.01.2010 MS
      // - RecBufClear eingebaut
      // - Chargen-/Ringnummer hinzugefuegt
      // - Werksnummer gefixt (falsche GV)

      GV.Alpha.06 # Mat.Werksnummer;
      GV.Alpha.07 # Mat.Chargennummer;
      GV.Alpha.08 # Mat.Ringnummer;
      GV.Alpha.09 # Mat.Coilnummer;
    end;
  end;

  // kein Rest mehr vorhanden?
  if (aMark=n) then begin
// 19.04.2013   if (BAG.IO.Plan.Out.GewN-BAG.IO.Ist.Out.GewN<=1.0) then
    if (BAG.IO.Plan.IN.GewN-BAG.IO.Ist.Out.GewN<=1.0) then
      Lib_GuiCom:ZLColorLine($ZL.BAG.IO.Auswahl_IN, Set.Col.RList.Deletd)
  end;

end;


//========================================================================
//  EvtLstRecControl
//
//========================================================================
sub EvtLstRecControl(
	aEvt         : event;    // Ereignis
	aRecID       : int       // Record-ID des Datensatzes
) : logic
begin
//RETURN true;
	RETURN (BAG.IO.BruderID=0) and (BAG.P.Position<>0);
end;


//========================================================================
//  AuswahlEvtLstRecControl
//
//========================================================================
sub AuswahlEvLstRecControl(
  aEvt  : event;
  aID   : int;
) : logic;
local begin
  Erx     : int;
  vOK     : logic;
  vID     : int;
  vBuf707 : int;
end;
begin
  // 15.11.2021 Ah
//  if (BA1_IO_I_Data:IstMatBeistellung()) then RETURN false;

  // nur echten Input anzeigen?
  vOk # (BAG.IO.Materialtyp=c_IO_Mat) or
    //(BAG.IO.Materialtyp=c_IO_BAG) or
    (BAG.IO.MaterialTyp=c_IO_VSB);

  // Weiterbearbeitung?
  // KEINE Sotrnierten anbieten
  if (BAG.IO.VonFertigmeld>0) then begin
    vBuf707 # RecBufCreate(707);
    Erx # RecLink(vBuf707,701,18,_recFirst);
    if (Erx<=_rLocked) and (vBuf707->BAG.FM.Status<>1) then vOk # false;
    RecBufDestroy(vBuf707);
  end;

  RETURN vOK;
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
local begin
  Erx : int;
end;
begin

  if (RunAFX('BA1.IO.I.EvtLstDataInit','')<0) then RETURN;

  // Lagerort holen
  if (BAG.IO.Lageradresse<>0) then
    RecLink(101,701,6,_RecFirst)
  else
    RecBufClear(101);

  // 1zu1 Arbeitsgang?
/* neue 1zu1
  if ("BAG.P.Typ.1In-1OutYN") and
    ((BAG.IO.NachFertigung=0) or (BAG.IO.NachFertigung=999)) and
    (WinFocusget()=cZList1) then begin
    Lib_GuiCom:ZLColorLine(cZList2, RGB(255,196,196));
  end;
*/

  Gv.Alpha.01 # '???';
  Gv.Alpha.02 # Translate('NICHT GEFUNDEN');
  Gv.Alpha.03 # Translate('NICHT GEFUNDEN');
  Gv.Alpha.04 # ANum(BAG.IO.Plan.Out.Meng, set.Stellen.Menge)+' '+BAG.IO.MEH.Out;
  GV.Alpha.05 # ANum(BAG.IO.Ist.In.Menge , set.Stellen.Menge)+' '+BAG.IO.MEH.In;
  GV.Alpha.06 # '';
  GV.Alpha.07 # '';
  GV.Alpha.08 # '';
  GV.Alpha.09 # '';
  GV.Alpha.10 # '';
  GV.Alpha.11 # '';
  case (BAG.IO.Materialtyp) of

    c_IO_Mat, c_IO_VSB : begin     // echtes Material
      if (BAG.IO.Materialtyp=c_IO_Mat) then
        Gv.Alpha.01 # Translate('Mat.')+AInt(BAG.IO.Materialnr);
      if (BAG.IO.Materialtyp=c_IO_VSB) then
        Gv.Alpha.01 # Translate('VSB-Mat.')+AInt(BAG.IO.Materialnr);
      Erx # Mat_Data:Read(BAG.IO.Materialnr); // Einsatzmaterial holen
      if (Erx>=200) then begin
        Gv.Alpha.02 # "Mat.Güte";
        Gv.Alpha.03 # ANum(Mat.Dicke,"Set.Stellen.Dicke")+' x '+ANum(Mat.Breite,"Set.Stellen.Breite");
        if ("Mat.Länge"<>0.0) then Gv.Alpha.03 # Gv.Alpha.03 + ' x '+ANum("Mat.Länge","Set.Stellen.Länge");

        GV.Alpha.06 # "Mat.Gütenstufe";
        GV.Alpha.07 # Mat.Ringnummer;
        GV.Alpha.08 # Mat.Chargennummer;
        GV.Alpha.09 # "Mat.AusführungOben";
        GV.Alpha.10 # "Mat.AusführungUnten";
        GV.Alpha.11 # Mat.Coilnummer;
// GV.Alpha.07 # Mat.Coilnummer;
      end;
    end;

    c_IO_Art, c_IO_Beistell : begin     // Artikel
      Gv.Alpha.01 # Translate('Art.')+BAG.IO.Artikelnr;
      Erx # RecLink(250,701,8,_recFirst); // Artikel holen
      if (Erx<=_rLocked) then begin
        Gv.Alpha.02 # Art.Stichwort;
        Gv.Alpha.03 # Art.Bezeichnung1;
      end;
    end;


    c_IO_Theo : begin    // theoretisches Material
      Gv.Alpha.01 # Translate('theor. Material');
      Gv.Alpha.02 # "BAG.IO.Güte";
      Gv.Alpha.03 # ANum(BAG.IO.Dicke,"Set.Stellen.Dicke")+' x '+ANum(BAG.IO.Breite,"Set.Stellen.Breite");
      if ("BAG.IO.Länge"<>0.0) then Gv.Alpha.03 # Gv.Alpha.03 + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
      GV.Alpha.06 # "BAG.IO.Gütenstufe";
    end;


    c_IO_BAG : begin     // Weiterbearbeitung
      if (BAG.IO.VonBAG=BAG.IO.Nummer) then
//        if (BAG.IO.VonID<>0) then
//          Gv.Alpha.01 # Translate('Teil Pos.')+' '+AInt(BAG.IO.VonPosition)
//        else
          Gv.Alpha.01 # Translate('Fertigung')+' '+AInt(BAG.IO.VonPosition)+'/'+AInt(BAG.IO.VonFertigung)
      else
        if (BAG.IO.VonID<>0) then
          Gv.Alpha.01 # Translate('Teil BA')+' '+AInt(BAG.IO.VonBAG)+'/'+AInt(BAG.IO.VonPosition)
        else
          Gv.Alpha.01 # c_AKt_BA+' '+AInt(BAG.IO.VonBAG)+'/'+AInt(BAG.IO.VonPosition)+'/'+AInt(BAG.IO.VonFertigung);

      if (BAG.IO.VonID<>0) then begin
        Gv.Alpha.02 # "BAG.IO.Güte";
        Gv.Alpha.03 # ANum(BAG.IO.Dicke,"Set.Stellen.Dicke")+' x '+ANum(BAG.IO.Breite,"Set.Stellen.Breite");
        if ("BAG.IO.Länge"<>0.0) then Gv.Alpha.03 # Gv.Alpha.03 + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
        GV.Alpha.06 # "BAG.IO.Gütenstufe";
      end
      else begin
        BAG.F.Nummer    # BAG.IO.VonBAG;
        BAG.F.Position  # BAG.IO.VonPosition;
        BAG.F.Fertigung # BAG.IO.VonFertigung;
        Erx # RecRead(703,1,0);
        if (Erx<=_rLocked) then begin
          Gv.Alpha.02 # "BAG.F.Güte";
          Gv.Alpha.03 # ANum(BAG.F.Dicke,"Set.Stellen.Dicke")+' x '+ANum(BAG.F.Breite,"Set.Stellen.Breite");
          if ("BAG.F.Länge"<>0.0) then Gv.Alpha.03 # Gv.Alpha.03 + ' x '+ANum("BAG.F.Länge","Set.Stellen.Länge");
        end;
      end;
    end;

  end;
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
end;


//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vA      : alpha;
  vFile   : int;
end;
begin

  if (RecLinkInfo(701,702,2,_recCount)>0) and (BA1_P_Data:DarfNur1EinsatzHaben(BAG.P.Aktion)) then begin
    aEffect # _WinDropEffectNone;
    RETURN false;
  end;
  

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    if (vFile=200) then begin
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN (true);
    end;
	end;
	
  RETURN false;
end;


//========================================================================
//  EvtDrop
//            komplettes D&D durchführen
//========================================================================
sub EvtDrop(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aDataPlace   : int;      // DropPlace-Objekt
	aEffect      : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  Erx       : int;
  vA        : alpha;
  vFile     : int;
  vID       : int;
  vPos      : int;
  vNr       : int;
//  vOK       : logic;
  vBuf401   : int;
  vBUf701   : int;
  vBuf701b  : int;
  vKunde    : int;
  vErr      : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);

    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    if (vID=0) then RETURN false;

    case vFile of

      200 : begin
        // <<< MUSTER
        // für Drag&Drop und Focuswechsel
        WinUpdate(WinInfo(aEvt:obj, _WinFrame), _WinUpdActivate );
        if (gMDI<>0) then VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        // ENDE MUSTER >>>

        Erx # RecRead(200,0,_RecId,vID);    // Satz holen
        if (Erx<>_rOK) then begin
        	RETURN (false);
        end;

        if (Mat.Status=c_Status_EKVSB) or (Mat.Status=c_Status_EK_Konsi) then
          vErr # BA1_IO_I_Data:PruefeMoeglichesEinsatzMat(c_IO_VSB)
        else
          vErr # BA1_IO_I_Data:PruefeMoeglichesEinsatzMat(c_IO_Mat);
        if (vErr=0) then begin
          // Da beim Umlagern keine Statusveränderung am Material vorgenommen wird, muss vorab geprüft werden,
          // ob die Materialnummer doppelt eingesetzt wird
          if (BAG.P.Aktion = c_BAG_Umlager) then begin
            if (IstUmlagerEinsatzDoppelt(Mat.Nummer))  then
              RETURN false;
          end;

          // 16.03.2012 AI: Einsatz in VK-Fahren MUSS kommissioniert sein!!!
          //if (vOK) and
          if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.P.ZielVerkaufYN) then begin
            //if (Mat.Auftragsnr=0) then vOK # false;
            if (Mat.Auftragsnr=0) then vErr # 1;
//            if (vOK) then begin

            if (vErr=0) then begin
              vBuf701 # RecBufCreate(701);
              vBuf701b # RecBufCreate(701);
              vBuf401 # RecBufCreate(401);
              FOR Erx # RecLink(vBuf701,702,2,_recFirst)  // Input loopen
              LOOP Erx # RecLink(vBuf701,702,2,_recNext)
              WHILE (Erx<=_rLocked) and (vKunde=0) do begin
                if (vBuf701->BAG.IO.NachID=0) then CYCLE;
                // OUTPUT dazu holen...
                vBuf701b->BAG.IO.Nummer # vBuf701->BAG.IO.NachBAG;
                vBuf701b->BAG.IO.ID # vBuf701->BAG.IO.NachID;

                Erx # RecRead(vBuf701b,1,0);
                if (Erx>_rLocked) or (vBuf701b->BAG.IO.Auftragsnr=0) then CYCLE;
                Erx # RecLink(vBuf401,vBuf701b,16,_recFirst);  // Aufpos holen
                if (Erx>_rLocked) then begin
                  RecBufClear(401);
                  CYCLE;
                end;

                vKunde # vBuf401->Auf.P.Kundennr;
                BREAK;
              END;
              if (vKunde<>0) then begin
                Erx # RecLink(vBuf401,200,16,_recFirst);  // Aufpos holen
                //if (vBuf401->Auf.P.Kundennr<>vKunde) then vOK # false;
                if (vBuf401->Auf.P.Kundennr<>vKunde) then vErr # 2;
              end;

              RecBufDestroy(vBuf701);
              RecBufDestroy(vBuf701b);
              RecBufDestroy(vBuf401);
            end;
          end;

        end;

        //if (vOK=false) then begin
        if (vErr<>0) then begin
        	RETURN (false);
        end;
        if ("Mat.Löschmarker"='*') then begin
        	RETURN (false);
        end;

        // MATERIAL AUFNEHMEN...
        RecRead( 702, 0, 0, cZList1->wpDbRecId );
        //RecLink(702,701,4,_recFirst);       // Pos holen

        Erx # RecLink(701,700,3,_recLast);  // letzten IO holen
        if (Erx<=_rLocked) then vNr # 1
        else vNr # BAG.IO.ID + 1;

        RecBufClear(701);
        BAG.IO.ID # vNr;
        BAG.IO.Nummer       # BAG.P.Nummer;
        BAG.IO.NachBAG      # BAG.P.Nummer;
        BAG.IO.NachPosition # BAG.P.Position;
//11.10.2021        if ("BAG.P.Typ.1in-1outYN") and
//          (((BAG.P.Aktion<>c_BAG_Fahr09) AND (Bag.P.Aktion <> c_BAG_Umlager)) or (BAG.P.ZielVerkaufYN=n)) then    // 1zu1 Arbeitsgang?
        if (BA1_P_Data:Muss1AutoFertigungHaben()) then
          BAG.IO.NachFertigung # 1;

        BAG.IO.NachBAG        # BAG.Nummer;
        BAG.IO.NachPosition   # BAG.P.Position;

        BAG.IO.Materialtyp # c_IO_Mat;
        if (Mat.Status=c_Status_EKVSB) or (Mat.Status=c_Status_EK_Konsi) then BAG.IO.Materialtyp # c_IO_VSB
        BAG.IO.AutoTeilungYN  # Set.BA.AutoteilungYN;

        BA1_IO_I_Data:MatFelderInsInput(); // 03.11.2021 AH

        BAG.IO.VonBAG         # 0;
        BAG.IO.VonPosition    # 0;
        BAG.IO.VonFertigung   # 0;
        BAG.IO.VonID          # 0;

        BAG.IO.NachFertigung # 0;
//11.10.2021        if ("BAG.P.Typ.1in-1outYN") and
//          (((BAG.P.Aktion<>c_BAG_Fahr09) AND (BAG.P.Aktion <> c_BAG_Umlager) ) or (BAG.P.ZielVerkaufYN=n)) then    // 1zu1 Arbeitsgang?
        if (BA1_P_Data:Muss1AutoFertigungHaben()) then
          BAG.IO.NachFertigung # 1;

        // ID vergeben
        WHILE (RecRead(701,1,_recTest)<=_rLocked) do
          BAG.IO.ID # BAG.IO.ID + 1;

        BAG.IO.UrsprungsID    # BAG.IO.ID;
        BAG.IO.Anlage.Datum   # Today;
        BAG.IO.Anlage.Zeit    # Now;
        BAG.IO.Anlage.User    # gUserName;

// 10.03.2015 in BA1_IO_Data:INSERT drin
// 01.12.2015 AH: NEIN, ist anderes!!!
        // AFX
        if (RunAFX('BAG.IO.In.RecSave','')<>0) then begin
          if (AfxRes<>_rOk) then RETURN False;
        end;

        TRANSON;

        // VSB-Material auf diesen neuen Einsatz hin anpassen
        if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
          if (BA1_Mat_Data:VSBEinsetzen()=false) then begin
            TRANSBRK;
            Msg(701005,'',0,0,0);
            RETURN false;
          end;
        end;

        // Material auf diesen neuen Einsatz hin anpassen
        if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
          if (BA1_Mat_Data:MatEinsetzen()=false) then begin
            TRANSBRK;
            Msg(701005,'',0,0,0);
            RETURN false;
          end;
        end;

        Erx # BA1_IO_Data:Insert(0,'MAN');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN False;
        end;

        // Output aktualisieren
        if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
          TRANSBRK;
          ErrorOutput;
          RETURN false;
        end;

        TRANSOFF;

        // AFX
        RunAFX('BAG.IO.InRecSavePost','');

        // nächste Pos. holen
        RecLink(702,701,4,_recFirst);
        // alle Fertigungen neu errechnen
        BA1_P_Data:ErrechnePlanmengen();

        cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
        cZList4->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      end;

    end;

  end;

	RETURN (false);
end

/**
//========================================================================
//  DropAllMarked
//
//========================================================================
sub DropAllMarked() : logic;
local begin
  vHDL  : int;
  vDL   : int;
  vItem : int;
  vA    : alpha;
  vFile : int;
  vI    : int;
  vID   : int;
  vOK   : logic;
end;
begin
  vDL  # gMdiWorkbench->WinSearch('DL.Workbench');
  if (vDL=0) then RETURN false;

  vHDL # vDL->wpSelData;
  if (vHdl=0) then RETURN false;

  vHDL # vHDL->wpData(_WinSelDataCteList);

  TRANSON;

  vOK # y;
  vItem # vHDL->CteRead(_CteFirst);
  WHILE (vOK) and (vItem<>0) do begin
    vI # vItem->spId;
//    vA # vA + cnvai(vFile,0,0,3)+'|'+Cnvai(vID,_FmtNumNoGroup,0,15);
    vDL->WinLstCellGet(vA,1,vI);
    vDL->WinLstCellGet(vFile,2,vI);
    vDL->WinLstCellGet(vID,3,vI);

    if (vFile=200) then begin
     Erx # RecRead(vFile,0,0,vID);
      if (Erx<=_rLocked) then begin
        vOk # BA1_IO_Data:einsatzRein(BAG.P.Nummer, BAG.P.Position, cnvia(vA));
      end;
    end;

    vItem # vHDL->CteRead(_CteNext, vItem);
  END;

  if (vOK) then begin
    TRANSOFF;
    Msg(999998,'',0,0,0)
    end
  else begin
    TRANSBRK;
    Msg(99,'Material nicht einfügbar!',_WinIcoError,_WinDialogOk,0);
  end;

end;
***/


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vI  : int;
end;
begin
//  RETURN Call( Lib_Guicom:GetAlternativeMain(aEvt:Obj, 'BA1_Combo_Main')+':Refreshall', aEvt);    14.09.2021 AH
  Call(Lib_Guicom:GetAlternativeMain(aEvt:Obj, 'BA1_Combo_Main')+':Refreshall', vI);
  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aID                   : bigint;       // RecID bei RecList, Node-Deskriptor bei TreeView, Focus-Objekt bei Frame und AppFrame
) : logic;
local begin
  Erx     : int;
  vStk    : int;
  vGew    : float;
end;
begin
  if (aKey<>_WinKeyReturn) then RETURN Lib_DataList:EvtKeyItem(aEvt, aKey, aID);
  aEvt:Obj->WinLstCellGet(vStk, 9, aID);
  if (vStk<>1) then RETURN Lib_DataList:EvtKeyItem(aEvt, aKey, aID);
  ToggleLine(aEvt:Obj, aID);
  RETURN(true);
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
  vStk    : int;
  vGew    : float;
end;
begin
  if ( aId <= 0 ) or ( aItem <= 0 ) or ( (aButton = _winMouseLeft | _winMouseDouble )=false) then
    RETURN Lib_DataList:EvtMouseItem(aEvt, aButton, aHitTest, aItem, aID);

  aEvt:Obj->WinLstCellGet(vStk, 9, aID);
  if (vStk<>1) then RETURN Lib_DataList:EvtMouseItem(aEvt, aButton, aHitTest, aItem, aID);
  ToggleLine(aEvT:Obj, aID);
  RETURN(true);
end;


//========================================================================
// EvtLstEditFinished             AI 15.10.2009
//
//========================================================================
sub EvtLstEditFinished(
  aEvt                 : event;    // Ereignis
  aColumn              : int;      // Spalte
  aKey                 : int;      // Taste
  aRecID               : int;      // Datensatz-ID
  aChanged             : logic;    // true, wenn eine Änderung vorgenommen wurde
) : logic;
local begin
  Erx     : int;
  vStk    : int;
  vGew    : float;
end;
begin
  aEvt:Obj->WinLstCellGet(vStk,12, _WinLstDatLineCurrent);
  aEvt:Obj->WinLstCellGet(BAG.IO.ID,1, _WinLstDatLineCurrent);
  aEvt:Obj->WinLstCellGet(vGew,13, _WinLstDatLineCurrent);

  BAG.IO.Nummer # BAG.P.Nummer;
  Erx # RecRead(701,1,0);   // Einsatz holen
  if (Erx<=_rLocked) then begin
    if (BAG.IO.Plan.Out.Stk-BAG.IO.Ist.Out.Stk-vStk<0) then begin
      Msg(99,'Zuviel Stücke!!',0,0,0);
      aEvt:Obj->WinLstCellSet(0,12,  _WinLstDatLineCurrent);
    end;
  end;

  aEvt:Obj->WinLstCellGet(vStk,12, _WinLstDatLineCurrent);
  aEvt:Obj->WinLstCellGet(BAG.IO.ID,1, _WinLstDatLineCurrent);
  BAG.IO.Nummer # BAG.P.Nummer;
  Erx # RecRead(701,1,0);   // Einsatz holen
//debugX(aColumn->wpname+' '+aint(vStk)+' '+anum(vGew,0)+' '+aint(BAG.Io.Plan.out.Stk)+' '+abool(aChanged));
  if (Erx<=_rLocked) and (aChanged) then begin
    if (aColumn->wpname='clm.Stueck.Einsatz') and (BAG.IO.Plan.Out.Stk<>0) and (vStk<>0) then begin
//    if (BAG.IO.Plan.Out.Stk<>0) then begin
      vGew # Rnd(BAG.IO.Plan.Out.GewN * cnvfi(vStk) / cnvfi(BAG.IO.Plan.Out.Stk), Set.Stellen.Gewicht); // 2022-12-20 AH
// Zeile 2010 in BA1_Fertigmelden
      aEvt:Obj->WinLstCellSet(vGew,13,  _WinLstDatLineCurrent);
      vGew # Rnd(BAG.IO.Plan.Out.GewB * cnvfi(vStk) / cnvfi(BAG.IO.Plan.Out.Stk), Set.Stellen.Gewicht); // 2022-12-20 AH
      aEvt:Obj->WinLstCellSet(vGew,14,  _WinLstDatLineCurrent);
    end
    else if (aColumn->wpname='clm.Gewicht.Einsatz') and (vGew<>0.0) and (BAG.Io.Plan.Out.GewN<>0.0) then begin    // 02.05.2022 AH
    // 10 Stk = 100kg
    // Was sind 40kg?
      vStk # Max(cnvif(cnvfi(BAG.IO.Plan.Out.Stk) * vGew / BAG.IO.Plan.Out.GewN),1);
      aEvt:Obj->WinLstCellSet(vStk,12,  _WinLstDatLineCurrent);
    end;
  end;

  Lib_DataList:EvtLstEditFinished(aEvt, aColumn, aKey, aRecid, aChanged);

  RETURN true;
end


//========================================================================
//========================================================================
//========================================================================
//========================================================================