@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_E_Mat_Main
//                OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  29.07.2009  ST  Weitereingabe mit eingegebenen Daten hinzugefügt
//  07.08.2009  AI  NEU: 1.Analyse kopieren
//  09.04.2010  AI  VSB2VersandPool
//  22.04.2010  AI  VSB auf WE füllt Bestandsbuch
//  21.10.2010  AI  NEU: Einzelgewichte
//  01.12.2011  AI  Lageradresse wird erst durch den Haken gesetzt 1323/52
//  18.01.2012  AI  atumsfelder nur bei Neueingabe editierbar, Coilnr. etc. immer editierbar
//  01.02.2012  AI  Setting für VSB2WE für automatischen Löschen
//  22.02.2012  AI  VSB2WE setzt Lageradrese auf Bestellkopf-Zielort
//  29.03.2012  MS  Datumsfelder bei Neuanlage deaktiviert Prj. 1161/395
//  20.04.2012  AI  Datumsfelder nur Disabeln, wenn KEIN Haken (Prj. 1347/79)
//  26.04.2012  AI  Datumsfelder nur Disabeln, wenn KEIN Haken (Prj. 1347/84)
//  12.06.2012  ST  Zeitl. Verzögerung beim Verbuchen von Automatischen Ausfällen hinzugefügt Prj. 1277/236
//  22.06.2012  ST  Timeout bei Verbuchen der Gegenbuchung entfernt
//  21.08.2012  AI  "RecSave": Ausfallabfrage ans Ende und nicht "zwischen" mehreren WE
//  07.11.2012  AI  Zuordnung von Status 951 Material möglich
//  10.12.2012  AI  Übernahme der Reservierungen korrigiert
//  11.04.2013  AI  MatMEH
//  14.05.2013  AI  Verwieungsart 0 erlaubt, Projekt 1395/63
//  22.08.2013  AH  Lagerplatz änderbar bei "jungfräulichen" Karten
//  14.10.2013  AH  RecSave: Weitere Eingabe, nur wenn Pos. nicht schon erfüllt ist
//  04.02.2014  AH  bereits fakturierte Mat.WE können nicht gelöscht werden! (Prj. 1326/379)
//  01.08.2014  ST  RecSave: Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  27.11.2014  AH  Ermitten von Gewicht setzt Netto+Brutto
//  28.11.2014  AH  Ein.EK.Preis wird NICHT gesetzt -> Muss "Verbuchen" machen
//  25.02.2015  AH  automatischer Ausfall bei "Rest", löscht EingangYN und Eingang_Datum
//  05.05.2015  AH  Erfüllungsprozent auf "Ein.P.Menge" NICHT "Ein.P.Menge.Wunsch"
//  02.09.2015  AH  Abschlussdatumprüfung nur bei gesetzen Haken
//  17.09.2015  AH  eingang für Konsi über bereits vorhandenes Material gefixt
//  17.12.2015  AH  Neu: Set.Ein.WE.Weitere
//  07.03.2016  AH  Edit: Löschen nur bei unverbuchter EKK
//  08.06.2016  AH  Fix: WE auf VSB mit Reservierungen hatte falsche vVSBMat-Nr.
//  08.09.2016  AH  Neu: neuer Wareneingang warnt bei Pauschalaufpreisen
//  30.05.2017  AH  Fix: WE auf VSB mit Auftragsart "Reserieren statt Kommissionieren" passt Res. an
//  07.07.2017  AH  Fix: bei Gegenbuchung werden Res. entweder gelöscht oder übernommen
//  13.09.2017  AH  Edit: MEH2 wird ggf. mit PreisMEH belegt
//  29.01.2018  AH  AnalyseErweitert
//  19.10.2018  AH  Reservierungen für BA-Einsatz übernehmen das Eingangsmaterial
//  07.11.2018  AH  Etikettendruck nur bei echtem Eingang
//  09.11.2018  AH  Anker "Ein.E.Mat.Pflichtfelder"
//  13.02.2020  AH  Neu: Wareneingang übernimmt ggf. Reservierungen
//  02.04.2020  AH  Fix: Löschen geht nur, wenn Material im Bestand ist
//  20.01.2021  AH  Neu: Set.Ein.NoDelWennRsv
//  10.02.2021  AH  CO2
//  15.04.2021  AH  Neues Setting: Set.Ein.GetPreisImWE
//  05.10.2021  ST  Anker "Ein.E.Mat.RecSave.Post"
//  27.01.2022  AH  ERX, Speichern bei mehreren Res. auf Bestellkarte fragt nach Res.Übernahmedialog
//  12.04.2022  AH  FIX, WE auf VSB übernimmt keine Res. für FAHREN (weil das separate Logik hat)
//  21.07.2022  HA  Quick Jump
//  2023-04-26  AH  "StartDel" kann per Parameter die Pos. löschen
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic;
//    SUB Pflichtfelder();
//    SUB CheckAnalyse(aObj  : int; aName : alpha; aWert : float; opt aWert2 : float; );
//    SUB CheckAbm(aObj  : int;  aAbm  : float; aTol  : Alpha; aWert : float  );
//    SUB RefreshIfm(opt aName : alpha; aChanged : logic)
//    SUB RecInit(opt aBehalten : logic);
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusAnalyse()
//    SUB AusEinzelObfOben()
//    SUB AusEinzelObfUnten()
//    SUB AusEinzelgewichte()
//    SUB AusMaterial()
//    SUB AusArtikel()
//    SUB AusLageradresse()
//    SUB AusLageranschrift()
//    SUB AusLagerplatz()
//    SUB AusGuete()
//    SUB AusGuetenstufe()
//    SUB AusWarengruppe()
//    SUB AusIntrastat()
//    SUB AusErzeuger()
//    SUB AusLand()
//    SUB AusVerwiegungsart()
//    SUB AusZwischenlage()
//    SUB AusUnterlage()
//    SUB AusUmverpackung()
//    SUB AusAFOben()
//    SUB AusAFUnten()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);

//    SUB EvtLstRecControl(opt aEvt : event; opt aRecid: int) : logic;

//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//    SUB StartReserv(aInUebernahme : logic)
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen
@I:Def_BAG

define begin
  cTitle :    'Materialeingänge'
  cFile :     506
  cMenuName : 'Ein.E.Mat.Bearbeiten'
  cPrefix :   'Ein_E_Mat'
  cZList :    $ZL.Ein.Mat.Eingang
  cKey :      1
end;

declare StartReserv(aInUebernahme : logic; aDanachPosDel : logic)


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vPar  : int;
  vHdl  : int;
end;
begin
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  Filter_Ein_E  # y;



  $lb.Nummer->wpcaption     # AInt(Ein.P.Nummer);
  $lb.Position->wpcaption   # AInt(Ein.P.Position);
  $lb.Stichwort->wpcaption  # Ein.P.LieferantenSW;

  if (Set.Installname='BSP') then begin
    $lbEin.E.CO2EinstandPT->wpvisible # true;
    $edEin.E.CO2EinstandPT->wpvisible # true;
    $lbCO2->wpvisible # true;
  end;

  // Chemietitel ggf. setzen
  if (Set.Chemie.Titel.C<>'') then begin
    $lbEin.E.Chemie.C->wpcaption # Set.Chemie.Titel.C;
  end;
  if (Set.Chemie.Titel.Si<>'') then begin
    $lbEin.E.Chemie.Si->wpcaption # Set.Chemie.Titel.Si;
  end;
  if (Set.Chemie.Titel.Mn<>'') then begin
    $lbEin.E.Chemie.Mn->wpcaption # Set.Chemie.Titel.Mn;
  end;
  if (Set.Chemie.Titel.P<>'') then begin
    $lbEin.E.Chemie.P->wpcaption # Set.Chemie.Titel.P;
  end;
  if (Set.Chemie.Titel.S<>'') then begin
    $lbEin.E.Chemie.S->wpcaption # Set.Chemie.Titel.S;
  end;
  if (Set.Chemie.Titel.Al<>'') then begin
    $lbEin.E.Chemie.Al->wpcaption # Set.Chemie.Titel.Al;
  end;
  if (Set.Chemie.Titel.Cr<>'') then begin
    $lbEin.E.Chemie.Cr->wpcaption # Set.Chemie.Titel.Cr;
  end;
  if (Set.Chemie.Titel.V<>'') then begin
    $lbEin.E.Chemie.V->wpcaption # Set.Chemie.Titel.V;
  end;
  if (Set.Chemie.Titel.Nb<>'') then begin
    $lbEin.E.Chemie.Nb->wpcaption # Set.Chemie.Titel.Nb;
  end;
  if (Set.Chemie.Titel.Ti<>'') then begin
    $lbEin.E.Chemie.Ti->wpcaption # Set.Chemie.Titel.Ti;
  end;
  if (Set.Chemie.Titel.N<>'') then begin
    $lbEin.E.Chemie.N->wpcaption # Set.Chemie.Titel.N;
  end;
  if (Set.Chemie.Titel.Cu<>'') then begin
    $lbEin.E.Chemie.Cu->wpcaption # Set.Chemie.Titel.Cu;
  end;
  if (Set.Chemie.Titel.Ni<>'') then begin
    $lbEin.E.Chemie.Ni->wpcaption # Set.Chemie.Titel.Ni;
  end;
  if (Set.Chemie.Titel.Mo<>'') then begin
    $lbEin.E.Chemie.Mo->wpcaption # Set.Chemie.Titel.Mo;
  end;
  if (Set.Chemie.Titel.B<>'') then begin
    $lbEin.E.Chemie.B->wpcaption # Set.Chemie.Titel.B;
  end;
  if (Set.Chemie.Titel.1<>'') then begin
    $lbEin.E.Chemie.Frei1->wpcaption # Set.Chemie.Titel.1;
  end;
  if ("Set.Mech.Titel.Härte"<>'') then begin
    $lbEin.E.Hrte->wpcaption # "Set.Mech.Titel.Härte";
  end;
  if ("Set.Mech.Titel.Körn"<>'') then begin
    $lbEin.E.Koernung->wpcaption # "Set.Mech.Titel.Körn";
  end;
  if ("Set.Mech.Titel.Sonst"<>'') then begin
    $lbEin.E.Mech.Sonstig->wpcaption # "Set.Mech.Titel.Sonst";
  end;
  if ("Set.Mech.Titel.Rau1"<>'') then begin
    $lbEin.E.RauigkeitA1->wpcaption # "Set.Mech.Titel.Rau1";
  end;
  if ("Set.Mech.Titel.Rau2"<>'') then begin
    $lbEin.E.RauigkeitB1->wpcaption # "Set.Mech.Titel.Rau2";
  end;


  if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
//    $lbEin.E.Artikelnr->wpcaption # Translate('Artikelnr.');
    $edEin.E.Artikelnr->wpcustom  # '_E';
    $bt.Artikel->wpcustom         # '_E';
  end
  else begin
//    $lbEin.E.Artikelnr->wpcaption # Translate('Strukturnr.');
    $edEin.E.Artikelnr->wpcustom  # '_N';
    $bt.Artikel->wpcustom # '_N';
  end;

  // 08.01.2015
  if (Ein.P.MEH<>'Stk') and (Ein.P.MEH<>'kg') and (Ein.P.MEH<>'t') then begin
    $lbEin.E.Menge->wpvisible # true;
    $edEin.E.Menge->wpvisible # true;
    $lb.MEH->wpvisible # true;
  end;
  $lb.MEH->wpcaption # Ein.P.MEH;


  if (Set.Mech.Dehnung.Wie<>1) then
    $lbEin.E.DehnungB->wpvisible # false;

  Lib_Guicom2:Underline($edEin.E.Materialnr);
  Lib_Guicom2:Underline($edEin.E.Verwiegungsart);
  Lib_Guicom2:Underline($edEin.E.Guetenstufe);
  Lib_Guicom2:Underline($edEin.E.Guete);
  Lib_Guicom2:Underline($edEin.E.AusfOben);
  Lib_Guicom2:Underline($edEin.E.AusfUnten);
  Lib_Guicom2:Underline($edEin.E.Artikelnr);
  Lib_Guicom2:Underline($edEin.E.Lageradresse);
  Lib_Guicom2:Underline($edEin.E.Lageranschrift);
  Lib_Guicom2:Underline($edEin.E.Lagerplatz);
  Lib_Guicom2:Underline($edEin.E.Intrastatnr);
  Lib_Guicom2:Underline($edEin.E.Warengruppe);
  Lib_Guicom2:Underline($edEin.E.Erzeuger);
  Lib_Guicom2:Underline($edEin.E.Ursprungsland);
  
  Lib_Guicom2:Underline($edEin.E.Zwischenlage);
  Lib_Guicom2:Underline($edEin.E.Unterlage);
  Lib_Guicom2:Underline($edEin.E.Umverpackung);
  


  SetStdAusFeld('edEin.E.Materialnr'     ,'Material');
  SetStdAusFeld('edEin.E.Artikelnr'      ,'Artikel');
  SetStdAusFeld('edEin.E.Lageradresse'   ,'Lageradresse');
  SetStdAusFeld('edEin.E.Lageranschrift' ,'Lageranschrift');
  SetStdAusFeld('edEin.E.Lagerplatz'     ,'Lagerplatz');
  SetStdAusFeld('edEin.E.Warengruppe'    ,'Warengruppe');
  SetStdAusFeld('edEin.E.Intrastatnr'    ,'Intrastat');
  SetStdAusFeld('edEin.E.Erzeuger'       ,'Erzeuger');
  SetStdAusFeld('edEin.E.Ursprungsland'  ,'Land');
  SetStdAusFeld('edEin.E.Guete'          ,'Guete');
  SetStdAusFeld('edEin.E.Guetenstufe'    ,'Guetenstufe');
  SetStdAusFeld('edEin.E.Kommission'     ,'Kommission');
  SetStdAusFeld('edEin.E.Verwiegungsart' ,'Verwiegungsart');
  SetStdAusFeld('edEin.E.Zwischenlage'   ,'Zwischenlage');
  SetStdAusFeld('edEin.E.Unterlage'      ,'Unterlage');
  SetStdAusFeld('edEin.E.Umverpackung'   ,'Umverpackung');
  SetStdAusFeld('edEin.E.AusfOben'       ,'AusfOben');
  SetStdAusFeld('edEin.E.AusfUnten'      ,'AusfUnten');

  if (Set.LyseErweitertYN) then begin
    vHdl # Winsearch(aEvt:Obj, 'lbEin.E.SbeligkeitMax');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'edEin.E.SbeligkeitMax');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'lbEin.E.SaebelProM');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'edEin.E.SaebelProM');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'lbSaebel');
    if (vHdl<>0) then vHdl->wpVisible # false;

    vPar # Winsearch(aEvt:Obj, 'NB.Page2');
    Lib_GuiCom2:Hide(vPar, 'lbAnalyseStart', 'lb.Vor.Chemie.Frei1');
    vHdl # Winsearch(vPar, 'lbEin.E.Analysenr');
    if (vHdl<>0) then vHdl->wpVisible # true;
    vHdl # Winsearch(vPar, 'edEin.E.Analysenr');
    if (vHdl<>0) then vHdl->wpVisible # true;
    vHdl # Winsearch(vPar, 'bt.Analyse');
    if (vHdl<>0) then vHdl->wpVisible # true;
    vHdl # Winsearch(vPar, 'bt.AnalyseAnzeigen');
    if (vHdl<>0) then vHdl->wpVisible # true;
    SetStdAusFeld('edEin.E.Analysenr'      ,'Analyse');
  end;

  RunAFX('Ein.E.Mat.Init',aint(aEvt:Obj));

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// EvtMdiActivate
//
//========================================================================
sub EvtMdiActivate(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  Erx     : int;
  vBuf200 : int;
  vRes    : logic;
  vHdl    : int;
end;
begin

  if (Ein.P.Materialnr<>0) then begin
    vBuf200 # RecBufCreate(200);
    Erx # RecLink(vBuf200,501,13,_recFirst);  // Bestand versuchen
    if (Erx<=_rLocked) then begin
      if (vBuf200->Mat.Reserviert.Stk>0) or (vBuf200->Mat.reserviert.Gew>0.0) then
        vRes # true;
    end;
    RecBufDestroy(vBuf200);
  end;
  $lb.Reservierungen->wpvisible # vRes;

  vHdl # Winsearch(gMenu,'Mnu.Filter.Geloescht');
  if (vHdl<>0) then vHdl->wpMenuCheck # Filter_Ein_E;

  RETURN App_Main:EvtMdiActivate(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;

  RunAFX('Ein.E.Mat.Pflichtfelder', '');

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edEin.E.Verwiegungsart);
  Lib_GuiCom:Pflichtfeld($edEin.E.Stueckzahl);
  Lib_GuiCom:Pflichtfeld($edEin.E.Gewicht);
  Lib_GuiCom:Pflichtfeld($edEin.E.Lageradresse);
  Lib_GuiCom:Pflichtfeld($edEin.E.Lageranschrift);
  Lib_GuiCom:Pflichtfeld($edEin.E.Warengruppe);
  Lib_GuiCom:Pflichtfeld($edEin.E.Ursprungsland);
  Lib_GuiCom:Pflichtfeld($edEin.E.Erzeuger);
  if (Ein.E.VSBYN) then
    Lib_GuiCom:Pflichtfeld($edEin.E.VSB.Datum);
  if (Ein.E.EingangYN) then
    Lib_GuiCom:Pflichtfeld($edEin.E.Eingang.Datum);
  if (Ein.E.AusfallYN) then
    Lib_GuiCom:Pflichtfeld($edEin.E.Ausfall.Datum);

  // 08.01.2015
  if ($edEin.E.Menge->wpvisible) then
    Lib_GuiCom:Pflichtfeld($edEin.E.Menge);

end;


//========================================================================
//  CheckAnalyse
//
//========================================================================
sub CheckAnalyse(
  aObj  : int;
  aName : alpha;
  aWert : float;
  opt aWert2 : float;
  );
local begin
  vVon, vBis  : float;
  vName       : alpha;
  vA          : alpha;
end;
begin


  vA # MQU_Data:BildeVorgabe(aName, 501, "Ein.P.Güte", Ein.P.Dicke, var vVon, var vBis);

  aObj->wpcaption # vA;
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

end;


//========================================================================
//  CheckAbm
//
//========================================================================
sub CheckAbm(
  aObj  : int;
  aAbm  : float;
  aTol  : Alpha;
  aWert : float;
  );
local begin
  vVon, vBis  : float;
end;
begin
  if (aAbm=0.0) then RETURN;

  Lib_Berechnungen:ToleranzZuWerten(aTol, var vVOn, var vBis);
  vVon # vVon + aAbm;
  vBis # vBis + aAbm;

  if ((aWert<vVon) or (aWert>vBis)) then
    aObj->wpColBkg # _WinColLightRed
  else
    aObj->wpColBkg # _WinColparent;

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
  Erx         : int;
  vVon, vBis  : float;
  vTmp        : int;
end;
begin

  if (aName='') then begin
    $RL.AFOben->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    $RL.AFUnten->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    // 01.04.2022 AH: VSB können noch ändern
    if (Ein.E.VSBYN) then begin
      $edEin.E.Lageradresse->wpcustom # '';
      $edEin.E.Lageranschrift->wpcustom # '';
      $bt.Adresse->wpcustom # '';
      $bt.Anschrift->wpcustom # '';
    end
    else begin
      $edEin.E.Lageradresse->wpcustom # '_E';
      $edEin.E.Lageranschrift->wpcustom # '_E';
      $bt.Adresse->wpcustom # '_E';
      $bt.Anschrift->wpcustom # '_E';
    end;
  end;

  if (aName='') or (aName='edEin.E.Artikelnr') then begin
    if (Ein.E.Artikelnr<>'') then begin
      RekLink(250,506,5,_RecFirst); // Artikel holen
    end
    else begin
      RecBufClear(250);
    end;
    $lb.ArtStichwort->wpcaption  # Art.Stichwort;
  end;

  // Analyse prüfen...
  if (Set.LyseErweitertYN=false) then begin
    if (aName='') or ((aName='edEin.E.Streckgrenze') and ($edEin.E.Streckgrenze->wpchanged)) or
                     ((aName='edEin.E.Streckgrenze2') and ($edEin.E.Streckgrenze2->wpchanged)) then
      CheckAnalyse($lb.Vor.Streckgrenze,'Streckgrenze',Ein.E.Streckgrenze, Ein.E.Streckgrenze2);
    if (aName='') or ((aName='edEin.E.Zugfestigkeit') and ($edEin.E.Zugfestigkeit->wpchanged)) or
                    ((aName='edEin.E.Zugfestigkeit2') and ($edEin.E.Zugfestigkeit2->wpchanged)) then
      CheckAnalyse($lb.Vor.Zugfestigkeit,'Zugfestigkeit',Ein.E.Zugfestigkeit, Ein.E.Zugfestigkeit2);

    if (Set.Mech.Dehnung.Wie=1) then begin
      if (aName='') or ((aName='edEin.E.DehnungA') and ($edEin.E.DehnungA->wpchanged)) then
        CheckAnalyse($lb.Vor.DehnungA,'DehnungA',Ein.E.DehnungA);
      if (aName='') or ((aName='edEin.E.DehnungB') and ($edEin.E.DehnungB->wpchanged)) or
                       ((aName='edEin.E.DehnungC') and ($edEin.E.DehnungC->wpchanged)) then
        CheckAnalyse($lb.Vor.DehnungB,'DehnungB', Ein.E.DehnungB, Ein.E.DehnungC);
    end;
    if (Set.Mech.Dehnung.Wie=2) then begin
      if (aName='') or ((aName='edEin.E.DehnungB') and ($edEin.E.DehnungB->wpchanged)) then
        CheckAnalyse($lb.Vor.DehnungA,'DehnungA',Ein.E.DehnungB);
      if (aName='') or ((aName='edEin.E.DehnungA') and ($edEin.E.DehnungA->wpchanged)) or
                       ((aName='edEin.E.DehnungC') and ($edEin.E.DehnungC->wpchanged)) then
        CheckAnalyse($lb.Vor.DehnungB,'DehnungB', Ein.E.DehnungA, Ein.E.DehnungC);
    end;

    if (aName='') or ((aName='edEin.E.DehngrenzeA') and ($edEin.E.DehngrenzeA->wpchanged)) or
                    ((aName='edEin.E.DehngrenzeA2') and ($edEin.E.DehngrenzeA2->wpchanged)) then
      CheckAnalyse($lb.Vor.DehngrenzeA,'DehngrenzeA',Ein.E.RP02_1, Ein.E.RP02_2);
    if (aName='') or ((aName='edEin.E.DehngrenzeB') and ($edEin.E.DehngrenzeB->wpchanged)) or
                    ((aName='edEin.E.DehngrenzeB2') and ($edEin.E.DehngrenzeB2->wpchanged)) then
      CheckAnalyse($lb.Vor.DehngrenzeB,'DehngrenzeB',Ein.E.RP10_1, Ein.E.RP10_2);
    if (aName='') or ((aName='edEin.E.Koernung') and ($edEin.E.Koernung->wpchanged)) or
                    ((aName='edEin.E.Koernung2') and ($edEin.E.Koernung2->wpchanged)) then
      CheckAnalyse($lb.Vor.Koernung,'Koernung',"Ein.E.Körnung", "Ein.E.Körnung2");
    if (aName='') or ((aName='edEin.E.RauigkeitA1') and ($edEin.E.RauigkeitA1->wpchanged)) or
                     ((aName='edEin.E.RauigkeitA2') and ($edEin.E.RauigkeitA2->wpchanged)) then
      CheckAnalyse($lb.Vor.RauigkeitA,'RauigkeitA',"Ein.E.RauigkeitA1","Ein.E.RauigkeitA2");
    if (aName='') or ((aName='edEin.E.RauigkeitB1') and ($edEin.E.RauigkeitB1->wpchanged)) or
                     ((aName='edEin.E.RauigkeitB2') and ($edEin.E.RauigkeitB2->wpchanged)) then
      CheckAnalyse($lb.Vor.RauigkeitB,'RauigkeitB',"Ein.E.RauigkeitB1","Ein.E.RauigkeitB2");
    if (aName='') or ((aName='edEin.E.Hrte') and ($edEin.E.Hrte->wpchanged)) or
                     ((aName='edEin.E.Hrte2') and ($edEin.E.Hrte2->wpchanged)) then
      CheckAnalyse($lb.Vor.Haerte,'Haerte',"Ein.E.Härte1", "Ein.E.Härte2");

    if (aName='') or ((aName='edEin.E.Chemie.C') and ($edEin.E.Chemie.C->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.C,'C',Ein.E.Chemie.C);
    if (aName='') or ((aName='edEin.E.Chemie.Si') and ($edEin.E.Chemie.Si->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Si,'Si',Ein.E.Chemie.Si);
    if (aName='') or ((aName='edEin.E.Chemie.Mn') and ($edEin.E.Chemie.Mn->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Mn,'Mn',Ein.E.Chemie.Mn);
    if (aName='') or ((aName='edEin.E.Chemie.P') and ($edEin.E.Chemie.P->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.P,'P',Ein.E.Chemie.P);
    if (aName='') or ((aName='edEin.E.Chemie.S') and ($edEin.E.Chemie.S->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.S,'S',Ein.E.Chemie.S);
    if (aName='') or ((aName='edEin.E.Chemie.Al') and ($edEin.E.Chemie.Al->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Al,'Al',Ein.E.Chemie.Al);
    if (aName='') or ((aName='edEin.E.Chemie.Cr') and ($edEin.E.Chemie.Cr->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Cr,'Cr',Ein.E.Chemie.Cr);
    if (aName='') or ((aName='edEin.E.Chemie.V') and ($edEin.E.Chemie.V->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.V,'V',Ein.E.Chemie.V);
    if (aName='') or ((aName='edEin.E.Chemie.Nb') and ($edEin.E.Chemie.Nb->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Nb,'Nb',Ein.E.Chemie.Nb);
    if (aName='') or ((aName='edEin.E.Chemie.Ti') and ($edEin.E.Chemie.Ti->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Ti,'Ti',Ein.E.Chemie.Ti);
    if (aName='') or ((aName='edEin.E.Chemie.N') and ($edEin.E.Chemie.N->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.N,'N',Ein.E.Chemie.N);
    if (aName='') or ((aName='edEin.E.Chemie.Cu') and ($edEin.E.Chemie.Cu->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Cu,'Cu',Ein.E.Chemie.Cu);
    if (aName='') or ((aName='edEin.E.Chemie.Ni') and ($edEin.E.Chemie.Ni->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Ni,'Ni',Ein.E.Chemie.Ni);
    if (aName='') or ((aName='edEin.E.Chemie.Mo') and ($edEin.E.Chemie.Mo->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Mo,'Mo',Ein.E.Chemie.Mo);
    if (aName='') or ((aName='edEin.E.Chemie.B') and ($edEin.E.Chemie.B->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.B,'B',Ein.E.Chemie.B);
    if (aName='') or ((aName='edEin.E.Chemie.Frei1') and ($edEin.E.Chemie.Frei1->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Frei1,'Frei1',Ein.E.Chemie.Frei1);
  end;  // Analysencheck

  // Abemssungen prüfen...
  if (aName='') or ((aName='edEin.E.Dicke') and ($edEin.E.Dicke->wpchanged)) then
    CheckAbm($lbEin.E.Dicke, Ein.P.Dicke, Ein.P.Dickentol, Ein.E.Dicke);
  if (aName='') or ((aName='edEin.E.Breite') and ($edEin.E.Breite->wpchanged)) then
    CheckAbm($lbEin.E.Breite, Ein.P.Breite, Ein.P.Breitentol, Ein.E.Breite);
  if (aName='') or ((aName='edEin.E.Laenge') and ($edEin.E.Laenge->wpchanged)) then
    CheckAbm($lbEin.E.Laenge, "Ein.P.Länge", "Ein.P.Längentol", "Ein.E.Länge");


  if (aName='edEin.E.Materialnr') and
    (($edEin.E.Materialnr->wpchanged) or (aChanged)) then begin
    Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
    if (Erx>_rLocked) then begin
      Ein.E.Materialnr # 0;
    end
    else begin
      Ein.E.Materialnr      # Mat.Nummer;
//      Lib_GuiCom:Enable($edEin.E.Materialnr);
//      Lib_GuiCom:Enable($bt.Material);

      Ein.E.EingangYN       # y;
      Ein.E.VSBYN           # n;
      Ein.E.AusfallYN       # n;
      Ein.E.Eingang_Datum   # Mat.Eingangsdatum;
      Ein.E.VSB_Datum       # 0.0.0;
      Ein.E.Ausfall_Datum   # 0.0.0;

      // 17.09.2015
      Erx # RekLink(835,501,5,_recFirst); // Auftragsart holen
      if (AAr.KonsiYN) and ($lb.GegenVSB->wpcustom='') then begin
        Ein.E.Eingang_Datum   # 0.0.0;
        $edEin.E.Eingang.Datum->wpCaptionDate # 0.0.0;
        Ein.E.EingangYN       # n;

        Ein.E.VSBYN           # y;
        Lib_GuiCom:Enable($edEin.E.VSB.Datum);
        Ein.E.VSB_Datum       # Mat.Eingangsdatum;

        Lib_GuiCom:Disable($cbEin.E.EingangYN);
        Lib_GuiCom:Disable($edEin.E.Eingang.Datum);
      end;


      Ein.E.Coilnummer      # Mat.Coilnummer;
      Ein.E.Ringnummer      # Mat.Ringnummer;
      Ein.E.Werksnummer     # Mat.Werksnummer;
      Ein.E.Chargennummer   # Mat.Chargennummer;
      Ein.E.Lageradresse    # Mat.Lageradresse;
      Ein.E.Lageranschrift  # Mat.Lageranschrift;

      Ein.E.Gewicht         # Mat.Bestand.Gew;
      "Ein.E.Stückzahl"     # Mat.Bestand.Stk;
      Ein.E.Gewicht.netto   # Mat.Gewicht.Netto;
      Ein.E.Gewicht.brutto  # Mat.Gewicht.Brutto;
      if (Mat.Verwiegungsart<>0) then Ein.E.Verwiegungsart  # Mat.Verwiegungsart;
      //if ("Mat.Güte"<>'') then        "Ein.E.Güte"          # "Mat.Güte";
      if ("Ein.E.Güte"='') then       "Ein.E.Güte"          # "Mat.Güte";
      if (Mat.Dicke<>0.0) then        Ein.E.Dicke           # Mat.Dicke;
      if (Mat.Dicke.von<>0.0) then    Ein.E.Dicke.von       # Mat.Dicke.von;
      if (Mat.Dicke.bis<>0.0) then    Ein.E.Dicke.bis       # Mat.Dicke.bis;
      if (Mat.Breite<>0.0) then       Ein.E.Breite          # Mat.Breite;
      if (Mat.Breite.von<>0.0) then   Ein.E.Breite.von      # Mat.Breite.von;
      if (Mat.Breite.bis<>0.0) then   Ein.E.Breite.bis      # Mat.Breite.bis;
      if ("Mat.Länge"<>0.0) then      "Ein.E.Länge"         # "Mat.Länge";
      if ("Mat.Länge.von"<>0.0) then  "Ein.E.Länge.Von"     # "Mat.Länge.von";
      if ("Mat.Länge.bis"<>0.0) then  "Ein.E.Länge.bis"     # "Mat.Länge.bis";
      if (Mat.RID<>0.0) then          Ein.E.RID             # Mat.RID;
      if (Mat.RAD<>0.0) then          Ein.E.RAD             # Mat.RAD;
      if (Mat.Lagerplatz<>'') then    Ein.E.Lagerplatz      # Mat.Lagerplatz;
      if (Mat.Bemerkung1<>'') then    Ein.E.Bemerkung       # StrCut(Mat.Bemerkung1,1,72);
      if (Mat.Bemerkung2<>'') then    Ein.E.Lieferscheinnr  # StrCut(Mat.Bemerkung2,1,20);

      // ggf. Ausführungen übernehmen...
      if (RecLinkInfo(201,200,11,_recCount)>0) then begin
        // bisherige Ausführungen löschen
        WHILE (RecLink(507,506,13,_RecFirst)=_rOK) do begin
          RekDelete(507,0,'MAN');
        END;

        Erx # RecLink(201,200,11,_RecFirst);  // Material AF loopen
        WHILE (Erx<=_rLocked) do begin
          RecBufClear(507);
          Ein.E.AF.Nummer       # Ein.E.Nummer;
          Ein.E.AF.Position     # Ein.E.Position;
          Ein.E.AF.Eingang      # Ein.E.Eingangsnr;
          Ein.E.AF.Seite        # Mat.AF.Seite;
          Ein.E.AF.lfdNr        # Mat.AF.lfdNr;
          Ein.E.AF.ObfNr        # Mat.AF.ObfNr;
          Ein.E.AF.Bezeichnung  # Mat.AF.Bezeichnung;
          Ein.E.AF.Zusatz       # Mat.AF.Zusatz;
          Ein.E.AF.Bemerkung    # Mat.AF.Bemerkung;
          "Ein.E.AF.Kürzel"     # "Mat.AF.Kürzel";
          Erx # RekInsert(507,0,'AUTO');

          Erx # RecLink(201,200,11,_RecNext);
        END;
        Ein.E.AusfOben        # "Mat.AusführungOben";
        Ein.E.AusfUnten       # "Mat.AusführungUnten";
      end;


      $cbEin.E.EingangYN->winupdate(_WinUpdFld2Obj);
      $cbEin.E.VSBYN->winupdate(_WinUpdFld2Obj);
      $cbEin.E.AusfallYN->winupdate(_WinUpdFld2Obj);
      $edEin.E.VSB.Datum->winupdate(_WinUpdFld2Obj);
      $edEin.E.Eingang.Datum->winupdate(_WinUpdFld2Obj);
      $edEin.E.Ausfall.Datum->winupdate(_WinUpdFld2Obj);

      if (Mode=c_ModeNew) then begin
        // 17.09.2015
        Erx # RekLink(835,501,5,_recFirst); // Auftragsart holen
        if (AAr.KonsiYN) and ($lb.GegenVSB->wpcustom='') then begin
          if (Ein.E.VSBYN=false) then Lib_GuiCom:Disable($edEin.E.VSB.Datum); // Datumsfelder bei Neuanlage disablen  29.03.2012 MS
          if (Ein.E.AusfallYN=false) then Lib_GuiCom:Disable($edEin.E.Ausfall.Datum);
          Lib_GuiCom:Disable($cbEin.E.EingangYN);
          Lib_GuiCom:Disable($edEin.E.Eingang.Datum);
        end
        else begin
          Lib_GuiCom:Enable($edEin.E.Eingang.Datum);
          Lib_GuiCom:Disable($edEin.E.VSB.Datum);
          Lib_GuiCom:Disable($edEin.E.Ausfall.Datum);
        end;

      end;

//    Refreshifm_page1_Mat();
      gMDI->winupdate(_WinUpdFld2Obj);
      Refreshifm('');
      RETURN;
    end;
  end;


  if (aName='') or (aName='edEin.E.Lageradresse') then begin
    Erx # RecLink(100,506,6,_recFirst);   // Lagerandresse holen
    if (Erx<=_rLocked) then
      $lb.Adresse->wpcaption # Adr.Stichwort
    else
      $lb.Adresse->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.E.Lageranschrift') then begin
    Erx # RecLink(101,506,7,_recFirst);   // Lageranschrift holen
    if (Erx<=_rLocked) then
      $lb.Anschrift->wpcaption # Adr.A.Stichwort
    else
      $lb.Anschrift->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.E.Warengruppe') then begin
    Erx # RecLink(819,506,4,_recFirst);   // Warengruppe holen
    if (Erx<=_rLocked) then
      $lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1
    else
      $lb.Warengruppe->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.E.Erzeuger') then begin
    Erx # RecLink(100,506,15,_recFirst);    // Erzeuger holen
    if (Erx<=_rLocked) then
      $lb.Erzeuger->wpcaption # Adr.Stichwort
    else
      $lb.Erzeuger->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.E.Ursprungsland') or (aName='edEin.E.Erzeuger') then begin
    Erx # RecLink(812,506,14,_recFirst);    // Land holen
    if (Erx<=_rLocked) then
      $lb.Land->wpcaption # Lnd.Name.L1
    else
      $lb.Land->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.E.Verwiegungsart') then begin
    Erx # RecLink(818,506,12,_recFirst);   // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    $lb.Verwiegungsart->wpcaption # VWa.Bezeichnung.L1

    if (Mode=c_ModeNew) then begin //or (Mode=c_ModeEdit) then begin
      if (VWa.NettoYN) then begin
        Lib_GuiCom:Disable($edEin.E.Gewicht.Netto);
        Lib_GuiCom:Enable($edEin.E.Gewicht.Brutto);
      end
      else if (VWa.BruttoYN) then begin
        Lib_GuiCom:Disable($edein.E.Gewicht.Brutto);
        Lib_GuiCom:Enable($edEin.E.Gewicht.Netto);
      end
      else begin
        Lib_GuiCom:Enable($edEin.E.Gewicht.Netto);
        Lib_GuiCom:Enable($edEin.E.Gewicht.Brutto);
      end;
    end;
    /*
    else begin
      Ein.E.Gewicht.Netto   # Ein.E.Gewicht;
      Ein.E.Gewicht.Brutto  # Ein.E.Gewicht;
      Lib_GuiCom:Disable($edEin.E.Gewicht.Netto);
      Lib_GuiCom:Disable($edEin.E.Gewicht.Brutto);
    end;
    */
  end;

  if (aName='') then begin
    $lb.Nummer1->wpcaption     # AInt(Ein.P.Nummer);
    $lb.Nummer2->wpcaption     # AInt(Ein.P.Nummer);
    $lb.Nummer3->wpcaption     # AInt(Ein.P.Nummer);
    $lb.Position1->wpcaption   # AInt(Ein.P.Position);
    $lb.Position2->wpcaption   # AInt(Ein.P.Position);
    $lb.Position3->wpcaption   # AInt(Ein.P.Position);
    if (Ein.E.Eingangsnr<>0) then begin
      $lb.lfdNr1->wpcaption      # AInt(Ein.E.Eingangsnr)
      $lb.lfdNr2->wpcaption      # AInt(Ein.E.Eingangsnr)
      $lb.lfdNr3->wpcaption      # AInt(Ein.E.Eingangsnr)
    end
    else begin
      $lb.lfdNr1->wpcaption      # '';
      $lb.lfdNr2->wpcaption      # '';
      $lb.lfdNr3->wpcaption      # '';
    end;
    $lb.Stichwort1->wpcaption  # Ein.P.LieferantenSW;
    $lb.Stichwort2->wpcaption  # Ein.P.LieferantenSW;
    $lb.Stichwort3->wpcaption  # Ein.P.LieferantenSW;
  end;

  if (Mode=c_ModeEdit) or (Mode=c_ModeNew) then begin
    if (aName='edEin.E.Guete') and ($edEin.E.Guete->wpchanged) then begin
      MQU_Data:Autokorrektur(var "Ein.P.Güte");
      Ein.P.Werkstoffnr # MQu.Werkstoffnr;
      $edEin.E.Guete->Winupdate();
    end;

    if (aName='edEin.E.DickenTol') and (Ein.E.Dicke<>0.0) then begin
      "Ein.E.Dickentol" # Lib_Berechnungen:Toleranzkorrektur("Ein.E.Dickentol",Set.Stellen.Dicke);
      $edEin.E.Dickentol->Winupdate();
    end;

    if (aName='edEin.E.BreitenTol') and (Ein.E.Breite<>0.0) then begin
      "Ein.E.Breitentol" # Lib_Berechnungen:Toleranzkorrektur("Ein.E.Breitentol",Set.Stellen.Breite);
      $edEin.E.Breitentol->Winupdate();
    end;

    if (aName='edEin.E.LaengenTol') and ("Ein.E.Länge"<>0.0) then begin
      "Ein.E.Längentol" # Lib_Berechnungen:Toleranzkorrektur("Ein.E.Längentol","Set.Stellen.Länge");
      $edEin.E.Laengentol->Winupdate();
    end;
/***
    if (aName='') or (aName='cbEin.E.DickenTolYN') then
      if (Ein.E.DickenTolYN=n) then
        Lib_GuiCom:Disable($edEin.E.DickenTol)
      else
        Lib_GuiCom:Enable($edEin.E.DickenTol);

    if (aName='') or (aName='cbEin.E.BreitenTolYN') then
      if (Ein.E.BreitenTolYN=n) then
        Lib_GuiCom:Disable($edEin.E.BreitenTol)
      else
        Lib_GuiCom:Enable($edEin.E.BreitenTol);

    if (aName='') or (aName='cbEin.E.LaengenTolYN') then
      if ("Ein.E.LängenTolYN"=n) then
        Lib_GuiCom:Disable($edEin.E.LaengenTol)
      else
        Lib_GuiCom:Enable($edEin.E.LaengenTol);
***/
  end;

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

  gMdi->WinUpdate();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit(opt aBehalten : logic);
local begin
  Erx         : int;
  vMEH        : alpha;
  vMEHString  : alpha;
  vNr         : int;
  vEingang    : int;
  vBuf507     : int;
  vI          : int;
  vBuf200     : int;
  vOK         : logic;
  vDat        : date;
end;
begin

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  // Aufpreise refreshen
  // 15.04.2021 AH: Aufpreise bestimmen Proj. 2208/4
  vDat # today;
  if (Set.Ein.GetPreisImWE=1) then begin
    if (Ein.P.TerminZusage<>0.0.0) then vDat # Ein.P.TerminZusage
    else if (Ein.P.Termin2Wunsch<>0.0.0) then vDat # Ein.P.Termin2Wunsch
    else if (Ein.P.Termin1Wunsch<>0.0.0) then vDat # Ein.P.Termin1Wunsch
    else vDat # today;
  end;
  if (FldInfoByName('Ein.P.Cust.PreisZum',_FldExists)>0) then
    vDat # FldDateByName('Ein.P.Cust.PreisZum');
  ApL_Data:Neuberechnen(500, vDat);

  Ein_Data:SumAufpreise(c_ModeView);


  if (Mode=c_ModeNew) then begin
    // 08.09.2016 AH: falls pauschaler Aufpreis existiert, warnen!
    FOR Erx # RecLink(503,500,13,_RecFirst) // Aufpreise loopen
    LOOP Erx # RecLink(503,500,13,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if (Ein.Z.Position<>0) and (Ein.Z.Position<>Ein.P.Position) then CYCLE;
      if (Ein.Z.MengenbezugYN=false) and ((Ein.Z.Menge * Ein.Z.Preis )<>0.0) then begin
        Msg(506021,'',0,0,0);
        BREAK;
      end;
    END;
  end;


 // Ankerfunktion?
  if (aBehalten) then begin
    if (RunAFX('Ein.E.RecInit', '1') < 0) then
      RETURN;
  end
  else begin
    if (RunAFX('Ein.E.RecInit', '0') < 0) then
      RETURN;
  end;

  // Neuanlage?
  if (Mode=c_ModeNew) then begin

    RecLink(500,501,3,_recFirst);       // Kopf holen
    Erx # RekLink(835,501,5,_recFirst); // Auftragsart holen
    // Konsi OHNE Gegenbuchtung?
    if (AAr.KonsiYN) and ($lb.GegenVSB->wpcustom='') then begin
      if (Ein.E.VSBYN=false) then Lib_GuiCom:Disable($edEin.E.VSB.Datum); // Datumsfelder bei Neuanlage disablen  29.03.2012 MS
      if (Ein.E.AusfallYN=false) then Lib_GuiCom:Disable($edEin.E.Ausfall.Datum);
      Lib_GuiCom:Disable($cbEin.E.EingangYN);
      Lib_GuiCom:Disable($edEin.E.Eingang.Datum);
    end
    else begin // "normal" 29.03.2012 MS
      if ($lb.GegenVSB->wpcustom<>'') or (Ein.E.VSBYN=false) then Lib_GuiCom:Disable($edEin.E.VSB.Datum); // Datumsfelder bei Neuanlage disablen  29.03.2012 MS
      if ($lb.GegenVSB->wpcustom='') and (Ein.E.EingangYN=false) then Lib_GuiCom:Disable($edEin.E.Eingang.Datum);
      if (Ein.E.AusfallYN=false) then Lib_GuiCom:Disable($edEin.E.Ausfall.Datum);
    end;


    // Gegenbuchung??
    if ($lb.GegenVSB->wpcustom<>'') then begin

      // 15.04.2021 AH: Preis neu aus Pos holen, Proj. 2208/4
      if (Set.Ein.GetPreisImWE=1) then begin
        Ein.E.Preis   # 0.0;
        Ein.E.PreisW1 # 0.0;
      end;

      vNr       # Ein.E.Nummer;
      vEingang  # Ein.E.Eingangsnr;

      // Ausführungen kopieren
      Erx # RecLink(507,506,13,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        vBuf507 # RekSave(507);
        Ein.E.AF.Nummer       # myTmpNummer;
        Ein.E.AF.Eingang      # 0;
        RekInsert(507,0,'AUTO');
        RekRestore(vBuf507);
        RecRead(507,1,0);
        Erx # RecLink(507,506,13,_recNext);
      END;

      Ein.E.Nummer          # myTmpNummer;
      Ein.E.Eingangsnr      # 0;
      Ein.E.Materialnr      # 0;

      RunAFX('Ein.E.RecInit.Post', '2');    // 29.09.2021 AH

      // Focus setzen auf Feld:
      $edEin.E.Eingang.Datum->WinFocusSet(true);
      RETURN;

    end;  // Gegenbuchung



    if (aBehalten=n) then begin
      RecBufClear(506);
  //    Ein.E.Nummer        # Ein.P.Nummer;
      Ein.E.Nummer          # myTmpNummer;
      Ein.E.Position        # Ein.P.Position;
      Ein.E.Lieferantennr   # Ein.P.Lieferantennr;
      Ein.E.Warengruppe     # Ein.P.Warengruppe;
      "Ein.E.Güte"          # "Ein.P.Güte";
      "Ein.E.Gütenstufe"    # "Ein.P.Gütenstufe";
      Ein.E.Erzeuger        # Ein.P.Erzeuger;
      Erx # RecLink(100,506,15,_recFirst);    // Erzeuger holen
      if (Erx<=_rLocked) then
        Ein.E.Ursprungsland   # Adr.LKZ
      else
        Ein.E.Ursprungsland   # '';

      Ein.E.MEH             # Ein.P.MEH; //'kg';    01.12.2014
      if (Ein.P.MEH.Preis<>Ein.P.MEH) and
        (Ein.P.MEH.Preis<>'Stk') and
        (Ein.P.MEH.Preis<>'kg') and
        (Ein.P.MEH.Preis<>'t') then begin
        Ein.E.MEH2          # Ein.P.MEH.Preis;
      end;

//Ein.E.MEH2 # Ein.P.MEH.Preis;
     // Ein.E.ArtikelID     # Ein.P.ArtikelID;
      Ein.E.Artikelnr       # Ein.P.Artikelnr;
      Ein.E.Dicke           # Ein.P.Dicke;
      Ein.E.Breite          # Ein.P.Breite;
      "Ein.E.Länge"         # "Ein.P.Länge";
      Ein.E.Dickentol       # Ein.P.DickenTol;
      Ein.E.Breitentol      # Ein.P.BreitenTol;
      "Ein.E.Längentol"     # "Ein.P.LängenTol";
      Ein.E.RID             # Ein.P.RID;
      Ein.E.RAD             # Ein.P.RAD;

      Ein.E.Kommission      # Ein.P.Kommission;   // seit 18.02.2015


//      Ein.E.Lageradresse    # Ein.Lieferadresse;
//      Ein.E.Lageranschrift  # Ein.Lieferanschrift;
      if (Mat.Nummer<>Ein.P.Materialnr) then
        Erx # RekLink(200,501,13,_recFirst);  // Bestell-Material holen
      Ein.E.Coilnummer      # Mat.Coilnummer;
      Ein.E.Ringnummer      # Mat.Ringnummer;
      Ein.E.Werksnummer     # Mat.Werksnummer;
      Ein.E.Chargennummer   # Mat.Chargennummer;


      if ("Set.Ein.WE.Stückzahl">1) then begin
        "Ein.E.Stückzahl"     # Ein.P.FM.Rest.Stk;
        Ein.E.Menge           # Ein.P.FM.Rest;
      end
      else begin
        "Ein.E.Stückzahl"     # "Set.Ein.WE.Stückzahl";
      end;
      Ein.E.Gewicht         # Mat.Bestellt.Gew; // Ein.P.FM.Rest; 08.01.2015
      if (Set.Installname='PPW') then Ein.E.Menge # Ein.P.FM.Rest;    // 2022-11-10 AH

//      Ein.E.Preis           # Ein.P.GrundPreis;
      "Ein.E.Währung"       # "Ein.Währung";
      Ein.E.Intrastatnr     # Ein.P.Intrastatnr;

      Ein.E.Verwiegungsart  # Ein.P.Verwiegungsart;
      Lib_Berechnungen:NettoBruttoAusGewicht(Ein.E.Gewicht, Ein.E.Verwiegungsart, var Ein.E.Gewicht.Netto, var Ein.E.Gewicht.Brutto);

      Ein.E.AbbindungL      # Ein.P.AbbindungL;
      Ein.E.AbbindungQ      # Ein.P.AbbindungQ;
      Ein.E.Zwischenlage    # Ein.P.Zwischenlage;
      Ein.E.Unterlage       # Ein.P.Unterlage;
      Ein.E.Umverpackung    # Ein.P.Umverpackung;
      Ein.E.Wicklung        # Ein.P.Wicklung;
      Ein.E.StehendYN       # Ein.P.StehendYN;
      Ein.E.LiegendYN       # Ein.P.LiegendYN;
      Ein.E.Nettoabzug      # Ein.P.Nettoabzug;
      "Ein.E.Stapelhöhe"    # "Ein.P.Stapelhöhe";
      "Ein.E.Stapelhöhenabz"  # "Ein.P.StapelhAbzug";

      Ein.E.AusfOben        # Ein.P.AusfOben;
      Ein.E.AusfUnten       # Ein.P.AusfUnten;
      // Ausführungen kopieren
      Erx # RecLink(502,501,12,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        Ein.E.AF.Nummer       # Ein.E.Nummer;
        Ein.E.AF.Position     # Ein.E.Position;
        Ein.E.AF.Eingang      # Ein.E.Eingangsnr;
        Ein.E.AF.Seite        # Ein.AF.Seite;
        Ein.E.AF.lfdNr        # Ein.AF.lfdNr;
        Ein.E.AF.ObfNr        # Ein.AF.ObfNr;
        Ein.E.AF.Bezeichnung  # Ein.AF.Bezeichnung;
        Ein.E.AF.Zusatz       # Ein.AF.Zusatz;
        Ein.E.AF.Bemerkung    # Ein.AF.Bemerkung;
        "Ein.E.AF.Kürzel"     # "Ein.AF.Kürzel";
        Erx # RekInsert(507,0,'AUTO');

        Erx # RecLink(502,501,12,_recNext);
      END;
      RunAFX('Ein.E.RecInit.Post', '0');

    end
    else begin  // aBehalten?
      Ein.E.Preis     # 0.0;      // 31.03.2021 AH: damit weitere WE auch Preise UND MAT.AKTIONEN/Aufpreise neu rechnet
      Ein.E.PreisW1   # 0.0;

      w_BinKopieVonDatei  # gFile;
      w_BinKopieVonRecID  # RecInfo(gFile, _recid);
      Ein.E.Materialnr    # 0;    // 08.08.2019
      // Ausführungen kopieren
      Erx # RecLink(507,506,13,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        vNr # Ein.E.AF.Nummer;
        vI  # Ein.E.AF.Eingang;
        Ein.E.AF.Nummer       # myTmpNummer;
        Ein.E.AF.Eingang      # 0;
        RekInsert(507,0,'AUTO');
        Ein.E.AF.Nummer   # vNr;
        Ein.E.AF.Eingang  # vI;
        RecRead(507,1,0);

        Erx # RecLink(507,506,13,_recNext);
      END;

      // Hier ggf. Anpassungen wenn Daten behalten werden sollen

      // Focus von den "spannenden" Feldern weg, damit diese autom. refreshen
      $cbEin.E.AusfallYN->WinFocusSet(true);

      if (Set.Installname<>'MSW') then begin
        Ein.E.Menge           # 0.0;
        "Ein.E.Stückzahl"     # 0;
        Ein.E.Gewicht         # 0.0;
        Ein.E.Gewicht.Netto   # 0.0;
        Ein.E.Gewicht.Brutto  # 0.0;
      end;
//      $edEin.E.Materialnr->winupdate(_WinUpdFld2Obj);

      Ein.E.Nummer          # myTmpNummer;
      Ein.E.Eingangsnr      # 0;

      RunAFX('Ein.E.RecInit.Post', '1');
    end;

    // Focus setzen auf Feld:
    $Nb.Main->wpcurrent # 'Nb.Page1';   // 28.10.2020 AH
    $cbEin.E.VSBYN->WinFocusSet(true);

  end //NEW
  else begin  // Edit...

    Lib_GuiCom:Disable($edEin.E.Materialnr);
    Lib_GuiCom:Disable($bt.Material);

    if (Ein.E.VSBYN) then begin
      Lib_GuiCom:Disable($edEin.E.Eingang.Datum);
      Lib_GuiCom:Disable($edEin.E.Ausfall.Datum);
    end;
    if (Ein.E.EingangYN) then begin
      Lib_GuiCom:Disable($edEin.E.VSB.Datum);
      Lib_GuiCom:Disable($edEin.E.Ausfall.Datum);
    end;
    if (Ein.E.AusfallYN) then begin
      Lib_GuiCom:Disable($edEin.E.VSB.Datum);
      Lib_GuiCom:Disable($edEin.E.Eingang.Datum);
    end;

    Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
    if ("Mat.Löschmarker"<>'') then Erx # _rLocked;
    if (Erx=_rOK) then begin
      vOK # Ein_E_Data:IstJungfrauMat();
      if (vOK) then Erx # _rOK;
    end;
    if (Erx=_rOK) then begin
      Lib_GuiCom:Enable($edEin.E.Guete);
      Lib_GuiCom:Enable($bt.Guete);
      Lib_GuiCom:Enable($edEin.E.Guetenstufe);
      Lib_GuiCom:Enable($edEin.E.AusfOben);
      Lib_GuiCom:Enable($bt.AusfOben);
      Lib_GuiCom:Enable($edEin.E.AusfUnten);
      Lib_GuiCom:Enable($bt.AusfUnten);

      Lib_GuiCom:Enable($edEin.E.Dicke);
      Lib_GuiCom:Enable($edEin.E.DickenTol);
      Lib_GuiCom:Enable($edEin.E.Dicke.Von);
      Lib_GuiCom:Enable($edEin.E.Dicke.Bis);
      Lib_GuiCom:Enable($edEin.E.Breite);
      Lib_GuiCom:Enable($edEin.E.BreitenTol);
      Lib_GuiCom:Enable($edEin.E.Breite.Von);
      Lib_GuiCom:Enable($edEin.E.Breite.Bis);
      Lib_GuiCom:Enable($edEin.E.Laenge);
      Lib_GuiCom:Enable($edEin.E.LaengenTol);
      Lib_GuiCom:Enable($edEin.E.Laenge.Von);
      Lib_GuiCom:Enable($edEin.E.Laenge.Bis);
      Lib_GuiCom:Enable($edEin.E.RID);
      Lib_GuiCom:Enable($edEin.E.RAD);

      Lib_GuiCom:Enable($edEin.E.Warengruppe);
      Lib_GuiCom:Enable($bt.Warengruppe);
      Lib_GuiCom:Enable($edEin.E.Erzeuger);
      Lib_GuiCom:Enable($bt.Erzeuger);
      Lib_GuiCom:Enable($edEin.E.Ursprungsland);
      Lib_GuiCom:Enable($bt.Land);
      Lib_GuiCom:Enable($cbEin.E.GesperrtYN);

      Lib_GuiCom:Enable($edEin.E.Lagerplatz);

      // Focus setzen auf Feld:
      //$edEin.E.Stueckzahl->WinFocusSet(true);
      $edEin.E.Lieferscheinnr->WinFocusSet(true);
    end
    else begin
      // Focus setzen auf Feld:
      $edEin.E.Lieferscheinnr->WinFocusSet(true);
      Lib_GuiCom:Disable($edEin.E.VSB.Datum);
      Lib_GuiCom:Disable($edEin.E.Eingang.Datum);
      Lib_GuiCom:Disable($edEin.E.Ausfall.Datum);
      Lib_GuiCom:Disable($edEin.E.Lagerplatz);
    end;

  end;

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx         : int;
  vStk        : int;
  vGew        : float;
  vGewN       : float;
  vGewB       : float;
  vMenge      : float;
  vlfd        : int;
  vNr         : int;
  vBuf506     : int;
  vBuf507     : int;
  vNeueKarte  : logic;
  vLyse       : alpha(4000);
  vVSBMat     : int;
  vMitRes     : logic;
  vHatRes     : logic;
  vI          : int;
  vKillVSB    : logic;
  vKillRest   : logic;
  vProz       : float;
  vDel        : logic;
  v203        : int;
  vResAnz     : int;
  vNoMore     : logic;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if ((Ein.E.VSBYN = false) and (Ein.E.EingangYN = false) and (Ein.E.AusfallYN = false)) or
    ((Ein.E.VSB_Datum = 0.0.0) and (Ein.E.Eingang_Datum = 0.0.0) and (Ein.E.Ausfall_Datum = 0.0.0)) then begin
    Msg(506002,'',0,0,0);
    $cbEin.E.VSBYN->WinFocusSet(true);
    RETURN false;
  end;
  if ((Ein.E.VSBYN = true) and (Ein.E.VSB_Datum = 0.0.0)) then begin
    Msg(001200,Translate('VSB-Datum'),0,0,0);
    $edEin.E.VSB.Datum->WinFocusSet(true);
    RETURN false;
  end;
  if ((Ein.E.EingangYN = true) and (Ein.E.Eingang_Datum = 0.0.0)) then begin
    Msg(001200,Translate('Eingangsdatum'),0,0,0);
    $edEin.E.Eingang.Datum->WinFocusSet(true);
    RETURN false;
  end;
  if ((Ein.E.AusfallYN = true) and (Ein.E.Ausfall_Datum = 0.0.0)) then begin
    Msg(001200,Translate('Ausfalldatum'),0,0,0);
    $edEin.E.Ausfall.Datum->WinFocusSet(true);
    RETURN false;
  end;

  // Prüfung auf Abschlussdatum
  if (Mode=c_ModeNew) then begin
    if (Ein.E.VSBYN) and (Ein.E.VSB_Datum <> 0.0.0) AND (Lib_Faktura:Abschlusstest(Ein.E.VSB_Datum) = false) then begin
      Msg(001400 ,Translate('VSB Datum') + '|'+ CnvAd(Ein.E.VSB_Datum),0,0,0);
      $edEin.E.VSB.Datum->WinFocusSet(true);
      RETURN false;
    end;
    if (Ein.E.EingangYN) and (Ein.E.Eingang_Datum <> 0.0.0) AND (Lib_Faktura:Abschlusstest(Ein.E.Eingang_Datum) = false) then begin
      Msg(001400 ,Translate('Eingangsdatum') + '|'+ CnvAd(Ein.E.Eingang_Datum),0,0,0);
      $edEin.E.Eingang.Datum->WinFocusSet(true);
      RETURN false;
    end;
    if (Ein.E.AusfallYN) and (Ein.E.Ausfall_Datum <> 0.0.0) AND (Lib_Faktura:Abschlusstest(Ein.E.Ausfall_Datum) = false) then begin
      Msg(001400 ,Translate('Ausfalldatum') + '|'+ CnvAd(Ein.E.Ausfall_Datum),0,0,0);
      $edEin.E.Ausfall.Datum->WinFocusSet(true);
      RETURN false;
    end;
  end;


  if ("Ein.E.Stückzahl"<=0) then begin
    if ("Ein.E.Stückzahl"=0) then
      Msg(001200,Translate('Stückzahl'),0,0,0);
    else
      Msg(001205,Translate('Stückzahl'),0,0,0); // negative Stückzahl [PW/22.09.09]
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Stueckzahl->WinFocusSet(true);
    RETURN false;
  end
  if (Ein.E.Gewicht<=0.0) then begin
    if (Ein.E.Gewicht=0.0) then
      Msg(001200,Translate('Gewicht'),0,0,0);
    else
      Msg(001205,Translate('Gewicht'),0,0,0); // negatives Gewicht [PW/22.09.09]
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Gewicht->WinFocusSet(true);
    RETURN false;
  end;

  // 08.01.2015
  if ($edEin.E.Menge->wpvisible) and (Ein.E.Menge<=0.0) then begin
    Lib_Guicom2:InhaltFehlt('Menge', 'NB.Page1', 'edEin.E.Menge');
    RETURN false;
  end;


/* 14.05.2013 Projekt 1395/63
  if (Ein.E.Verwiegungsart=0) then begin
    Msg(001200,Translate('Verwiegungsart'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Verwiegungsart->WinFocusSet(true);
    RETURN false;
  end;
*/
  Erx # RecLink(818,506,12,_RecFirst);    // Verwiegungsart prüfen
  if (Erx>_rLocked) then begin
    Msg(001201,Translate('Verwiegungsart'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Verwiegungsart->WinFocusSet(true);
    RETURN false;
  end;


  if ("Ein.E.Lageradresse"=0) then begin
    Msg(001200,Translate('Lageradresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageradresse->WinFocusSet(true);
    RETURN false;
  end;
  if (Ein.E.Lageranschrift=0) then begin
    Msg(001200,Translate('Lageranschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageranschrift->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(101,506,7,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lageradresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageradresse->WinFocusSet(true);
    RETURN false;
  end;


  Erx # RecLink(100,506,15,_recFirst);    // Erzeuger holen
  if (Erx>_rLocked) then begin
    Msg(001201,Translate('Erzeuger'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Erzeuger->WinFocusSet(true);
    RETURN false;
  end;

  if (Ein.E.Ursprungsland='') then begin
    Msg(001200,Translate('Urpsrungsland'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Ursprungsland->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(812,506,14,_recFirst);    // Land holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Ursprungsland'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Ursprungsland->WinFocusSet(true);
    RETURN false;
  end;

  // 30.11.2017 AH:
  if (Ein.E.Gewicht.Brutto<>0.0) and (Ein.E.Gewicht.Netto<>0.0) then begin
    if (Ein.E.Gewicht.Netto > Ein.E.Gewicht.Brutto) then begin
      Msg(001206,'',0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edEin.E.Gewicht.Netto->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
    Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
  end
  else if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
    Ein.E.Menge # Ein.E.Gewicht;
  end
  begin
    // 01.12.2014, 08.01.2015
    if (Ein.E.Menge=0.0) then Ein.E.Menge # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, 0.0,'', Ein.E.MEH);
  end;

  if (StrCnv(Ein.E.MEH2,_Strupper)='STK') then begin
    Ein.E.Menge2 # cnvfi("Ein.E.Stückzahl");
  end
  else if (StrCnv(Ein.E.MEH2,_Strupper)='KG') then begin
    Ein.E.Menge2 # Ein.E.Gewicht;
  end if (Ein.E.MEH2<>'') then begin
    if (Ein.E.Menge2=0.0) then Ein.E.Menge2 # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.E.MEH2);
  end;

  if (Ein.E.Gewicht.Brutto=0.0) then
    Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
  if (Ein.E.Gewicht.Netto=0.0) then
    Ein.E.Gewicht.Netto # Ein.E.Gewicht;

//  Wae_Umrechnen(Ein.E.Preis, "Ein.E.Währung", var Ein.E.PreisW1, 1);


  // Analyse prüfen...
  if (Set.Ein.WE.LyseCheck<>'') and (Set.LyseErweitertYN=false) then begin
    vLyse # Ein_E_Data:AnalyseError();
    if (vLyse<>'') then begin
      if (Set.Ein.WE.Lysecheck='STOP') then begin
        Msg(506006,vLyse,0,0,0);
        $NB.Main->wpcurrent # 'NB.Page2';
        $edEin.E.Streckgrenze->WinFocusSet(true);
        RETURN false;
      end;

      if (Set.Ein.WE.Lysecheck='WARN') then begin
        if (Msg(506005,vLyse,_WinIcoQuestion,_WinDialogYesNo,2)<>_winIDyes) then begin
          $NB.Main->wpcurrent # 'NB.Page2';
          $edEin.E.Streckgrenze->WinFocusSet(true);
          RETURN false;
        end;
      end;
    end;
  end;  // Analyse prüfen



  // vorhandene Karte übernehmen?
  if (Mode=c_ModeNew) and (Ein.E.Materialnr<>0) then begin
    Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
    if (Erx>=_rLocked) then begin
      Msg(506003,AInt(ein.e.Materialnr),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edEin.E.MaterialNr->WinFocusSet(true);
      RETURN false;
    end;

    if ("Mat.Löschmarker"<>'') or (Mat.Bestellnummer<>'') or
      ((Mat.Status>c_status_bisFrei) and (Mat.Status<>c_status_EKgesperrt) and (Mat.Status<>c_Status_EKgesperrtBetrieb)) then begin
      Msg(506004,AInt(Ein.E.Materialnr),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edEin.E.MaterialNr->WinFocusSet(true);
      RETURN false;
    end;

  end;

  //  28.09.2009  MS
  //  Beim Speichern eines veränderten WE für Material prüfen, ob es Abweichungen
  //  der Vor-Änderungs-Werte (aus Protokolldatei) gegenüber der Materialdatei gibt.
  //  (NICHT Preis, Lagerort, Stk, Gewicht)
  if (Mode=c_ModeEdit) then begin   // Editieren
    if(Ein_E_Data:CheckWE2Mat() = false) then begin
      if(Msg(506012, '', 0, _WinDialogYesNo, 1) = _WinIdNo) then
        RETURN false;
    end;
  end;

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren


  // Einzelgewicht eingeben??
  if (Set.Ein.WE.proStkYN) and
    ("Ein.E.Stückzahl">1) and ($lb.GegenVSB->wpcustom='') and (Ein.E.Materialnr=0) then
    if (Msg(506014,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin

    // Eingabetabelle aufrufen...
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.Mat.Einzelgewichte',here+':AusEinzelgewichte',y);
    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN false;
  end;  // EINGELGEWICHTE


  // Gegenbuchung?
/***
  if ($lb.GegenVSB->wpcustom<>'') then begin
    vBuf506 # RecBufCreate(506);
    vBuf506->Ein.E.Nummer    # Ein.P.Nummer;
    vBuf506->Ein.E.Position  # Ein.P.Position;
    vBuf506->Ein.E.Eingangsnr # cnvia($lb.GegenVSB->wpcustom);
    Erx # RecRead(vBuf506,1,0);
    if (Erx<>_rOK) then begin
      RecBufDestroy(vBuf506);
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    vGew # vBuf506->Ein.E.Gewicht - Ein.E.Gewicht;
      RecBufDestroy(vBuf506);
    if (vGew>=0.0) then begin
      if (Msg(506017,anum(vGew,Set.STellen.Gewicht),_WinIcoQuestion, _WinDialogYesNo,2)=_winidyes) then
        vKillVSB # y;
    end;
  end;
***/


  // Sonderfunktion:
  if (RunAFX('Ein.E.Mat.RecSave','')<>0) then begin
    if (AfxRes=999) then RETURN true;
    if (AfxRes<>_rOk) then begin
      RETURN False;
    end;
  end;


  TRANSON;

  if (Mode=c_ModeEdit) then begin   // Editieren

    if (Ein.E.Eingangsnr=0) then begin
      TRANSBRK;
      RETURN false;
    end;

    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Vorgang buchen
    if (Ein_E_Data:Verbuchen(n)=false) then begin
      TRANSBRK;
      Error(506001,'');
      ErrorOutput;
      RETURN false;
    end;

    PtD_Main:Compare(gFile);

  end
  else begin                        // Neuanlage -------------------

    Ein.E.Nummer        # Ein.P.Nummer;
    Ein.E.Anlage.User   # gUserName;

    vLfd                # Ein.E.Eingangsnr;
    REPEAT
      Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
      Ein.E.Anlage.Datum  # Today;
      Ein.E.Anlage.Zeit   # Now;
      Erx # RekInsert(gFile,0,'MAN');
    UNTIL (erx=_rOK);
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Ausführungen kopieren
    WHILE (RecLink(507,506,13,_RecFirst)=_rOK) do // alte löschen
      RekDelete(507,_recUnlock,'AUTO');

    vNr               # Ein.E.Eingangsnr;
    Ein.E.Nummer      # myTmpNummer;
    Ein.E.Eingangsnr  # vlfd;
    WHILE (RecLink(507,506,13,_RecFirst)=_rOK) do begin
      RecRead(507,1,_RecLock);
      Ein.E.AF.Nummer  # Ein.P.Nummer;
      Ein.E.AF.Eingang # vNr;
      RekReplace(507,_recUnlock,'AUTO');
    END;
    Ein.E.Nummer      # Ein.P.Nummer;
    Ein.E.Eingangsnr  # vNr;

    if (Ein.E.Materialnr=0) then vNeueKarte # y;


    if ($lb.GegenVSB->wpcustom='') then begin
      // normale Buchung----------------------------
      // Vorgang buchen
      if (Ein_E_Data:Verbuchen(y)=false) then begin
        TRANSBRK;
        Error(506001,'');
        ErrorOutput;
        RETURN false;
      end;
    end
    else begin

      vBuf506 # RecBufCreate(506);
      RecBufCopy(506,vBuf506);
      vBuf506->Ein.E.Eingangsnr # cnvia($lb.GegenVSB->wpcustom);
      Erx # RecRead(vBuf506,1,_recLock);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RecBufDestroy(vBuf506);
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
      vVSBMat # vBuf506->Ein.E.Materialnr;
      RecBufDestroy(vBuf506);


      if (Ein_E_data:Gegenbuchung(Ein.E.Eingangsnr, cnvia($lb.GegenVSB->wpcustom), var vMitRes)=false) then begin
        // TRANSBRK schon in Sub
        RETURN false;
      end;

    end; // Gegenbuchung

  end;  // Neuanlage

  TRANSOFF;

  // 13.02.2020 AH: bei normalen VSB/Eingang ggf. die EINE Reserv. aus Bestellkarte übernehmen
  if (vVSBMat=0) and (Set.Ein.WEResTransfr<>'N') then begin   // 07.10.2020 AH: per Setting
    vMitRes # false;
    Erx # RecLink(200,501,13,_recFirst);  // Bestand versuchen
    if (Erx<=_rLocked) then begin
      vI # RecLinkInfo(203,200,13,_RecCount);
      if (vI>1) then begin
        // 27.01.2022 AH: ggf. Übernahmedialog starten
        if (Msg(506023,'',_WinIcoQuestion,_WinDialogYesNo,1)=_winidyes) then begin;
          w_Command # 'RESTRANSFER';
          vMitRes # false;
          vResAnz # 0;
          vNoMore # true;
        end;
      end
      else if (vI=1) then begin
        if (Set.Ein.WEResTransfr='J') or (Msg(506024,'',_WinIcoQuestion,_WinDialogYesNo,1)=_winidyes) then begin
          Erx # RecLink(203,200,13,_RecFirst);
          if (Erx<=_rLocked) then begin
            if (Mat_Rsv_Data:Takeover(Mat.R.Reservierungnr, Ein.E.Materialnr, Min("Mat.R.Stückzahl", "Ein.E.Stückzahl") , Min(Mat.R.Gewicht, Ein.E.Gewicht), 0.0)) then begin
              //vResAnz # 1;
            end;
          end;
        end;
      end;
    end;
  end;
  
  // bei Gegenbuchung evtl. Reservierungen (wenn Auf/Allgem. oder BA-Input) übernehmen
  if (vMitRes) then begin

    // 30.05.2017 AH  : der neue WE hat dann schon Res. d.h. die bisherige mindern/löschen...
    if (AAr.Ein.E.ReservYN) and (Ein.P.Kommission<>'') then begin
      // bin auf VSB Karte
      Mat.Nummer # vVSBMat;
      Erx # RecLink(203,200,13,_RecFirst);  // Reservierungen loopen
      WHILE (Erx<=_rLocked) do begin
        if ("Mat.R.Trägernummer1"=0) then begin
          v203 # RekSave(203);
          RecRead(203,1,_RecLock);
          Mat.R.Gewicht     # Mat.Bestand.Gew
          "Mat.R.Stückzahl" # Mat.Bestand.Stk;
          Mat_Rsv_Data:Update();
          RekRestore(v203);
          if (RecRead(203,1,0)<=_rLocked) then begin
            Erx # RecLink(203,200,13,_RecNext);
          end
          else begin
            Erx # RecLink(203,200,13,_RecFirst);
          end;
          CYCLE;
        end;
        Erx # RecLink(203,200,13,_RecNext);
      END;
    end
    else begin
    
    // bei Gegenbuchung evtl. Reservierungen übernehmen
    // 07.07.2017 AH: auf jeden Fall LÖSCHEN oder ÜBERNEHMEN
      // Sonderfall. EINE BA-Einsatz-Reservierung:
      if (RecLinkInfo(203,200,13,_RecCount)=1) then begin
        Erx # RecLink(203,200,13,_RecFirst);
        if (Erx<=_rLocked) then begin
          if (Mat_Rsv_Data:Takeover(Mat.R.Reservierungnr, Ein.E.Materialnr, "Mat.R.Stückzahl", Mat.R.Gewicht, 0.0)) then begin
            vResAnz # 1;
            vMitRes # false;
          end;
        end;
      end;
    end;
  end;

  // bei Gegenbuchung...
  if (vMitRes) then begin
    // ALLE Reservierungen übernehmen?
    vMitRes # (Msg(506013,'',0,_WinDialogYesNo,1)=_winidyes);
    Mat.Nummer # vVSBMat;
    Erx # RecLink(203,200,13,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      // Alle AufRes löschen ODER ALLE wenn User sagt "KEINE Übernehmen"
      // 19.10.2018 AH: NICHT für c_Akt_BAInpup
      if (("Mat.R.Trägernummer1"<>0) and ("Mat.R.Trägertyp"<>c_Akt_BAInput)) or
        (vMitRes=false) then begin
        if (Mat_Rsv_Data:Entfernen()=false) then
          BREAK;
        Erx # RecLink(203,200,13,_RecFirst);
        CYCLE;
      end;
      inc(vResAnz);
//      if ("Mat.R.Trägernummer1"=0) then begin
      if (Mat_Rsv_Data:Takeover(Mat.R.Reservierungnr, Ein.E.Materialnr, "Mat.R.Stückzahl", Mat.R.Gewicht, 0.0)=false) then begin
        BREAK;
      end;
      Erx # RecLink(203,200,13,_RecFirst);
      CYCLE;
    END;
  end;

  
  // Etikettendruck?
  if (Ein.E.EingangYN) and
  (Ein.E.Materialnr<>0) and (vNeueKarte) and (Set.Ein.WE.Etikett<>0) then begin
    Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
    if (Set.Ein.WE.Etikett=999) then
      Mat_Etikett:Etikett(0,y,1)
    else
      Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1)
  end;


  // 19.10.2018 AH:
  if (vResAnz=1) then begin                   // wenn GENAU eine Res., könnte die zu BA gehören?
    Erx # RecLink(200,506,8,_RecFirst);       // Eingangsmaterial holen
    Erx # RecLink(203,200,13,_RecFirst);      // Res. holen
    if (Erx<=_rLocked) then begin
      if ("Mat.R.Trägertyp"=c_Akt_BAInput) then begin
        BAG.IO.Nummer # "Mat.R.TrägerNummer1";
        BAG.IO.ID     # "Mat.R.TrägerNummer2";
        Erx # RecRead(701,1,0);
        if (Erx<=_rLocked) then begin
          if (BAG.IO.Materialtyp=c_IO_Theo) then begin
            Erx # RecLink(700,701,1,_recFirst); // BA-Kopf holen
            Erx # RecLink(702,701,4,_recFirst); // nachPos holen
            Mat_Rsv_Data:Entfernen();
            BA1_IO_I_Data:TheorieWirdEcht(BAG.IO.ID, Mat.Nummer);
          end   // Theo
          else if (BAG.IO.Materialtyp=c_IO_VSB) then begin
            Erx # RecLink(700,701,1,_recFirst); // BA-Kopf holen
            Erx # RecLink(702,701,4,_recFirst); // nachPos holen
            if (BAG.P.Aktion<>c_BAG_Fahr) then begin                // 12.04.2022 AH: FAHREN mit VSB hat EIGENE LOGIK !!! Proj. 2335/12
              v203 # RekSave(203);
              Mat_Rsv_Data:Entfernen();
              if (BA1_IO_I_Data:EchtWirdTheorie(BAG.IO.ID)) then begin
                RecBufDestroy(v203);
                Erx # RecLink(200,506,8,_RecFirst);       // Eingangsmaterial holen
                if (BA1_IO_I_Data:TheorieWirdEcht(BAG.IO.ID, Mat.Nummer)) then begin
                end;
              end
              else begin  // konnte nicht Frei werden?
                RekRestore(v203);
                Mat_rsv_data:NeuAnlegen(Mat.R.Reservierungnr,'AUTO');
              end;
            end;
          end;
        end;
      end;
    end;
  end;


  RunAFX('Ein.E.Mat.RecSave.Post','');
      
  // Weitermachen mit eingeben?
  if (vNoMore=false) and (w_NoList = false) and (Mode = c_ModeNew) then begin
    if (Set.Ein.WE.Weitere='') and ("Ein.P.Löschmarker"='') then begin
      if (Msg(000005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
        RecInit(y);
        RETURN false;
      end;
    end;
  end; // Weitermachen mit eingeben?




  // 21.08.2012 AI
  // Rest als Ausfall? ...........................
  vDel # y;
  if (Mode=c_ModeNew) and ($lb.GegenVSB->wpcustom='') and (Ein.p.FM.Rest>0.0) then begin
// 05.05.2015    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.VSB + Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge.Wunsch);
    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.VSB + Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge);
//todo('das sind %:'+anum(vProz,2));
    if (vProz>="Set.Ein.WEDelEin%") then begin
      vKillRest # y;
      if (Set.Ein.WEDelEinAuto=2) then vKillRest # false;
      if (Set.Ein.WEDelEinAuto=1) then
        if (Msg(506018, anum(Ein.P.FM.Rest, Set.Stellen.Menge)+'|'+Ein.P.MEH.Wunsch,_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then begin
          vKillRest # n;
          vDel      # n;
        end;
    end
    else begin
      vDel # n;
      if (Set.Ein.WE.RstAsflYN) then
        if (Msg(506018, anum(Ein.P.FM.Rest, Set.Stellen.Menge)+'|'+Ein.P.MEH.Wunsch,_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
          vKillRest # y;
          vDel      # y;
        end;
    end;
  end;
  if (vKillRest) then begin
    vBuf506 # RekSave(506);
    RecInit(n);
    Ein.E.AusfallYN     # y;
    Ein.E.Ausfall_Datum # today;
    Ein.E.EingangYN     # n;
    Ein.E.Eingang_Datum # 0.0.0;

    "Ein.E.Stückzahl"   # Ein.P.FM.Rest.Stk;
    if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
      Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
    end;
    if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
      Ein.E.Menge # Ein.E.Gewicht;
    end;

    if (StrCnv(Ein.E.MEH2,_Strupper)='STK') then begin
      Ein.E.Menge2 # cnvfi("Ein.E.Stückzahl");
    end;
    if (StrCnv(Ein.E.MEH2,_Strupper)='KG') then begin
      Ein.E.Menge2 # Ein.E.Gewicht;
    end;

    if (Ein.E.Gewicht.Brutto=0.0) then
      Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
    if (Ein.E.Gewicht.Netto=0.0) then
      Ein.E.Gewicht.Netto # Ein.E.Gewicht;

    // Ausführungen kopieren
    vNr               # Ein.E.Eingangsnr;
    Ein.E.Nummer      # myTmpNummer;
    Ein.E.Eingangsnr  # vlfd;
    WHILE (RecLink(507,506,13,_RecFirst)=_rOK) do begin
      RecRead(507,1,_RecLock);
      Ein.E.AF.Nummer  # Ein.P.Nummer;
      Ein.E.AF.Eingang # vNr;
      RekReplace(507,_recUnlock,'AUTO');
    END;
    Ein.E.Nummer      # Ein.P.Nummer;
    Ein.E.Eingangsnr  # vNr;


    Ein.E.Nummer        # Ein.P.Nummer;
    Ein.E.Anlage.User   # gUserName;
    vLfd                # Ein.E.Eingangsnr;
    REPEAT
      Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
      Ein.E.Anlage.Datum  # Today;
      Ein.E.Anlage.Zeit   # Now;
      Erx # RekInsert(gFile,0,'MAN');
    UNTIL (erx=_rOK);

    if (Ein_E_Data:Verbuchen(y)=false) then begin
      RekRestore(vBuf506);
      Error(506001,'');
      ErrorOutput;
      RETURN true;
    end;
    RekRestore(vBuf506);
  end;    // ... Rest als Ausfall



  // Pos Löschen?
  if (vDel) and (Mode=c_ModeNew) and ("Ein.P.Löschmarker"='') then begin
    vBuf506 # RekSave(506);
    Erx # RecLink(506,501,14,_recFirst);  // WE loopen
    WHILE (Erx<=_rLocked) and (vDel) do begin
      if (Ein.E.VSBYN) and ("Ein.E.Löschmarker"='') then begin
        vDel # n;
        BREAK;
      end;
      Erx # RecLink(506,501,14,_recNext);
    END;
    RekRestore(vBuf506);
  end;

  // dürfte löschen?
  if (vDel) and (Set.Ein.NoDelWennRsv) then begin
    // 20.01.2021 AH: Wenn noch Res. vorhanden sind, dann NICHT löschen
    vI # 0;
    Erx # RecLink(200,501,13,_recFirst);  // Bestellkarte holen
    if (Erx<=_rLocked) then begin
      vI # RecLinkInfo(203,200,13,_RecCount);
    end;
    if (vI>0) then vDel # n;
  end;


  
  // dürfte löschen?
  if (vDel) then begin
// 05.05.2015    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge.Wunsch);
    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge);
    vDel # (vProz>="Set.Ein.WEDelEin%");

    // 19.07.2017 AH:
    // 08.08.2019 AH: dekativert wgeen Prj. 1326/552
/***
    if (vDel) and (vKillRest=false) and (Ein.P.Materialnr<>0) then begin
      Erx # RecLink(200,501,13,_recFirst);  // Material holen
      if (Erx<=_rLocked) then begin
        if (RecLinkInfo(203,200,13,_reccount)>0) then begin
          Msg(506022,'',0,0,0);
          vDel # false;
        end;
      end;
    end;
***/

    // ...% erreicht?
    if (vDel) and (vKillRest=false) then
      if (Set.Ein.WEDelEinAuto=1) then
        vDel # (Msg(506019,anum(vProz,2), _WinIcoQuestion, _WinDialogYesNo, 1)=_winidyes);


    // Position löschen? 23.02.2016 AH laut HB
    if (vDel) and ("Ein.P.Löschmarker"='') then begin
      // 2023-04-26 AH ERST NACH RESÜBERNAHME LÖSCHEN Proj. 2511/3
      if (w_Command='RESTRANSFER') then begin
        w_Command # 'RESTRANSFER*';
      end
      else begin
        if (Ein_P_Subs:ToggleLoeschmarker(n)) then
          if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then
            Ein_Data:UpdateMaterial();
      end;
    end;
  end;

  if (Set.Ein.WE.Weitere='X') then w_command # 'X'; // Fenster direkt schließen?

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin

  if (Mode=c_ModeNew) then begin
    // Ausführungen löschen
    WHILE (RecLink(507,506,13,_RecFirst)=_rOK) do begin
      RekDelete(507,0,'MAN');
    END;
  end;

  $lb.GegenVSB->wpcustom # '';

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx     : int;
  vOK     : logic;
  vMatDa  : logic;
end;
begin

  if ("Ein.P.Löschmarker"='*') then RETURN;

  if (Ein.E.AusfallYN) and ("Ein.E.Löschmarker"='') then  begin
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      RecRead(506,1,_recLock);
      PtD_Main:Memorize(506);
      "Ein.E.Löschmarker" # '*';
      RekReplace(506,_recUnlock,'MAN');
      if (Ein_E_Data:Verbuchen(n)=false) then begin
      end;
      PtD_Main:Compare(506);
    end;
    RETURN;
  end;


  if (Ein.E.VSBYN) and ("Ein.P.Löschmarker"='') then begin
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

      Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
      if (Erx>_rOK) then begin
        Msg(506003,AInt(ein.e.Materialnr),0,0,0);
        RETURN;
      end;
      // Reservierungen prüfen...
      if (RecLinkInfo(203,200,13,_RecCount)>0) then begin
        Msg(200203,AInt(Ein.e.Materialnr),0,0,0);
        RETURN;
      end;
      if (Ein_E_Data:StornoVSBMat()=false) then begin
        ErrorOutput;
        RETURN;
      end;
    end;
  end;


  if (Ein.E.EingangYN) and ("Ein.P.Löschmarker"='') then begin

    // ggf. auf DFKAT prü+fen...
    if (Set.Ein.OhneStreckVK=false) and (Ein.P.Kommissionnr<>0) then begin
      vOK # Auf_A_Data:LiesAktion(Ein.P.Kommissionnr, Ein.P.KommissionPos,0 ,c_Akt_DFAKT, Ein.E.Materialnr, 0,0,'',y);
/*
if (vOK) then
debug('A')
else debug('--');
RETURN;
*/
    end;


    // Prj. 1326/379:
    vMatDa # true;
    if (Ein.E.Materialnr<>0) then begin
      Erx # Mat_Data:Read(Ein.E.Materialnr);
      if (Erx<200) then begin
        Msg(200106,aint(Ein.E.materialnr),0,0,0)
        RETURN;
      end;
      vMatDa # (Erx=200) and ("Mat.Löschmarker"='');
      if (Mat.VK.Rechnr<>0) then begin
        Msg(200113,aint(Ein.E.materialnr),0,0,0)
        RETURN;
      end;
    end;
    if (vMatDa=false) then RETURN;
    

//    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    Erx # Msg(506007,'',_WinIcoQuestion,_WinDialogYesNoCancel,3);

    // zu AUSFALL MACHEN ?
    if (Erx=_WinIdYes) then begin
      TRANSON;
      RecRead(506,1,_recLock);
      PtD_Main:Memorize(506);
      //"Ein.E.Löschmarker" # '*';
      Ein.E.AusfallYN     # y;
      Ein.E.Ausfall_Datum # today;
      Ein.E.EingangYN     # n;
      Erx # RekReplace(506,_recUnlock,'MAN');
      if (erx<>_rOK) then begin
        Ptd_Main:Forget(506);
        TRANSBRK;
        RETURN;
      end;
      if (Ein_E_Data:Verbuchen(n)=false) then begin
        Ptd_Main:Forget(506);
        TRANSBRK;
        ErrorOutput;
        RETURN;
      end;
      PtD_Main:Compare(506);
      TRANSOFF;
      RETURN
    end;


    // LÖSCHEN?
    if (Erx=_WinIdNo) then begin
      TRANSON;
      RecRead(506,1,_recLock);
      PtD_Main:Memorize(506);
      "Ein.E.Löschmarker" # '*';
      Erx # RekReplace(506,_recUnlock,'MAN');
      if (erx<>_rOK) then begin
        Ptd_Main:Forget(506);
        TRANSBRK;
        RETURN;
      end;
      if (Ein_E_Data:Verbuchen(n)=false) then begin
        Ptd_Main:Forget(506);
        TRANSBRK;
        ErrorOutput;
        RETURN;
      end;
      PtD_Main:Compare(506);
      TRANSOFF;
      RETURN
    end;

  end;

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
  vA  : alpha;
end;
begin

  // Ankerfunktion
  vA # aint(aEvt:Obj)+'|'+aint(aFocusObject);
  RunAFX('Ein.E.Mat.EvtFocusInit', vA);

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
  Erx     : int;
  vFocus  : alpha;
end;
begin

  if(aFocusObject = 0) then
    RETURN false;

  vFocus # aEvt:Obj->wpname;

  if (vFocus='edEin.E.Erzeuger') and ($edEin.E.Erzeuger->wpchanged) then begin
    Erx # RecLink(100, 506, 15, _recFirst);
    if(Erx > _rLocked) then
      RecBufClear(100);
    Ein.E.Ursprungsland # Adr.LKZ;
  end;

  if (vFocus='edEin.E.Stueckzahl') and ($edEin.E.Stueckzahl->wpchanged) and
    ("Ein.E.Stückzahl"<>0) and (Ein.E.Gewicht=0.0) then begin
    Ein.P.Gewicht # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Ein.E.Stückzahl", Ein.E.Dicke, Ein.E.Breite, "Ein.E.länge", Ein.E.Warengruppe, "Ein.E.Güte", Ein.E.Artikelnr);
    $edEin.E.Gewicht->winupdate(_WinUpdFld2Obj);
  end;

  if (vFocus='edEin.E.Gewicht') and ($edEin.E.Gewicht->wpchanged) and
    ("Ein.E.Stückzahl"=0) and (Ein.E.Gewicht<>0.0) then begin
    "Ein.P.Stückzahl" # Lib_Berechnungen:STK_aus_KgDBLWgrArt(Ein.E.Gewicht, Ein.E.Dicke, Ein.E.Breite, "Ein.E.länge", Ein.E.Warengruppe, "Ein.E.Güte", Ein.E.Artikelnr);
    $edEin.E.Stueckzahl->winupdate(_WinUpdFld2Obj);
  end;

  if ((vFocus='edEin.E.Verwiegungsart') and ($edEin.E.Verwiegungsart->wpchanged)) or
    ((vFocus='edEin.E.Gewicht') and ($edEin.E.Gewicht->wpchanged)) then begin
    Erx # RecLink(818,506,12,_RecFirst);
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    if (Mode=c_ModeNew) then begin // or (Mode=c_ModeEdit) then begin 23.09.2020 AH wegen Proj. 1992/248
      if (VWa.NettoYN) then begin
        Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
        Ein.E.Gewicht.Netto # Ein.E.Gewicht;
        $edEin.E.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
        $edEin.E.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
        Lib_GuiCom:Disable($edEin.E.Gewicht.Netto);
        Lib_GuiCom:Enable($edEin.E.Gewicht.Brutto);
        if (aFocusObject->wpname='edEin.E.Gewicht.Netto') then
          $edEin.E.Gewicht.Brutto->winfocusset(false);
      end
      else if (VWa.BruttoYN) then begin
        Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
        Ein.E.Gewicht.Netto # Ein.E.Gewicht;
        $edEin.E.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
        $edEin.E.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
        Lib_GuiCom:Disable($edEin.E.Gewicht.Brutto);
        Lib_GuiCom:Enable($edEin.E.Gewicht.Netto);
        if (aFocusObject->wpname='edEin.E.Gewicht.Brutto') then
          $edEin.E.Gewicht.Netto->winfocusset(false);
      end
      else begin
        Lib_GuiCom:Enable($edEin.E.Gewicht.Netto);
        Lib_GuiCom:Enable($edEin.E.Gewicht.Brutto);
        if (aEvt:Obj->wpname='edEin.E.Gewicht') then begin
          Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
          Ein.E.Gewicht.Netto # Ein.E.Gewicht;
          $edEin.E.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
          $edEin.E.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
        end;

        if (aFocusObject->wpname='edEin.E.Gewicht.Brutto') then
          $edEin.E.Gewicht.Netto->winfocusset(false);
      end;
    end;
  end;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

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
  vA        : alpha;
  vFilter   : int;
  vQ        : alpha(4000);
  vSel      : int;
  vSelName  : alpha;
  vTmp      : int;
  vHdl      : int;
end;

begin

  case aBereich of
    'Analyse' : begin
      // 20.09.2018 AH: DIN holen?
      MQU_Data:Read("Ein.P.Güte", "Ein.P.Gütenstufe", y, Ein.P.Dicke);
    
      RecBufClear(230);
      Lys.K.Analysenr # Ein.E.Analysenummer;
      if (Set.LyseErweitertYN) then
//        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lys.K.Verwaltung2',here+':AusAnalyse')
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lys.K.Verwaltung2',here+':AusAnalyse',n,n,'ZUM_WE')
      else
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lys.K.Verwaltung',here+':AusAnalyse');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      w_Command # 'Vorgabe:501';
//gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.A.Verwaltung','',y, n, 'Ablage');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AusfOben' : begin
      vFilter # RecFilterCreate(507,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.E.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.E.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, Ein.E.Eingangsnr);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, '1');
      vTmp # RecLinkInfo(507,506,13,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfOben');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end

      RecBufClear(502);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.AF.Verwaltung','Ein_E_Mat_Main:AusAFOben');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(507,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.E.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.E.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, Ein.E.Eingangsnr);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, '1');
      gZLList->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AusfUnten' : begin
      vFilter # RecFilterCreate(507,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.E.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.E.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, Ein.E.Eingangsnr);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, '2');
      vTmp # RecLinkInfo(507,506,13,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfUnten');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end
      RecBufClear(502);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.AF.Verwaltung','Ein_E_Mat_Main:AusAFUnten');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(507,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.E.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.E.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, Ein.E.Eingangsnr);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, '2');
      gZLList->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '2';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageranschrift' : begin
      RecLink(100,506,6,0);     // Lageradresse holen
      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLageranschrift');

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


    'Lageradresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLageradresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Intrastat' : begin
      RecBufClear(220);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      // Selektion
      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'MSL.Strukturtyp', '=', 'INTRA');
      Lib_Sel:QAlpha(var vQ, 'MSL.Intrastatnr', '>', '');
      vSel # SelCreate(220, gKey);
      Erx # vSel->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vSel);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);

      gZLList->wpDbSelection # vSel;
      w_SelName # vSelName;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lagerplatz' : begin
      RecBufClear(844);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung','Ein_E_Mat_Main:AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kommission' : begin
    end;


    'Material' : begin
      RecBufClear(200);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikel' : begin
      RecBufClear(250);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Warengruppe' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Erzeuger' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusErzeuger');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Land' : begin
      RecBufClear(812);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lnd.Verwaltung',here+':AusLand');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guete' : begin
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(848);
      MQu.S.Stufe # "Ein.E.Gütenstufe";
      if (MQu.S.Stufe<>'') then begin
        vQ # ' MQu.NurStufe = '''+MQu.S.Stufe+''' OR MQu.NurStufe = '''' ';
        Lib_Sel:QRecList(0, vQ);
      end;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guetenstufe'          : begin
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenstufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Verwiegungsart' : begin
      RecBufClear(818);         // ZIELBUFFER LEEREN
      Lib_GuiCom:AddChildWindow(gMDI,'VwA.Verwaltung',here+':AusVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
     end;


    'Zwischenlage' : begin
      RecBufClear(838);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULA.Verwaltung',here+':AusZwischenlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=2';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Unterlage' : begin
      RecBufClear(838);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusUnterlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=1';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Umverpackung' : begin
      RecBufClear(838);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusUmverpackung');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=3';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


/*========================================================================
2023-04-26  AH
========================================================================*/
sub AusResDannPosDel()
begin
  if (Ein_P_Subs:ToggleLoeschmarker(n)) then
    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then
      Ein_Data:UpdateMaterial();
  RETURN;
end;


//========================================================================
//  AusAnalyse
//
//========================================================================
sub AusAnalyse()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(230,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Analysenummer # Lys.K.Analysenr;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edEin.E.Analysenr->Winfocusset(false);
end;


//========================================================================
//  AusEinzelObfOben
//
//========================================================================
sub AusEinzelObfOben()
local begin
  vFilter : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin

    RecBufClear(502);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.AF.Verwaltung','Ein_E_Mat_Main:AusAFOben');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(507,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.E.Nummer);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.E.Position);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, Ein.E.Eingangsnr);
    vFilter->RecFilterAdd(4,_FltAND,_FltEq, '1');
    gZLList->wpDbFilter # vFilter;
    vTmp # winsearch(gMDI, 'NB.Main');
    vTmp->wpcustom # '1';

    Mode # c_modeBald + c_modeNew;
    w_Command   # 'SETOBF:';
    w_cmd_para  # aint(gSelected);
    gSelected   # 0;

    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN;
  end;
end;


//========================================================================
//  AusEinzelObfUnten
//
//========================================================================
sub AusEinzelObfUnten()
local begin
  vFilter : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin

    RecBufClear(502);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.AF.Verwaltung','Ein_E_Mat_Main:AusAFUnten');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(507,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.E.Nummer);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.E.Position);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, Ein.E.Eingangsnr);
    vFilter->RecFilterAdd(4,_FltAND,_FltEq, '2');
    gZLList->wpDbFilter # vFilter;
    vTmp # winsearch(gMDI, 'NB.Main');
    vTmp->wpcustom # '2';

    Mode # c_modeBald + c_modeNew;
    w_Command   # 'SETOBF:';
    w_cmd_para  # aint(gSelected);
    gSelected   # 0;

    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN;
  end;
end;


//========================================================================
//  AusEinzelgewichte
//
//========================================================================
sub AusEinzelgewichte()
local begin
  vHdl        : int;
end
begin

  if (gSelected<>0) then begin
    gSelected # 0;
    Mode # c_ModeCancel;
    Lib_GuiCom:SetMaskState(false);
    vHdl # gMdi->winsearch('NB.List');
    if (vHdl<>0) then vHdl->wpdisabled # false;
    vHdl # gMdi->winsearch('NB.Main');
    if (vHdl<>0) then vHdl->wpCurrent # 'NB.List';
    Mode # c_ModeList;
    App_Main:RefreshMode(); // Buttons & Menues anpassen
  end;

  RETURN;
end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial()
begin
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Materialnr  # Mat.Nummer;
    $edEin.E.Materialnr->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edEin.E.Materialnr',y);
//    $edEin.E.Lageradresse->Winfocusset(false);
  end;
  // Focus setzen:
  $edEin.E.Lageradresse->Winfocusset(false);
end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    // Feldübernahme
    Ein.E.Artikelnr   # Art.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edEin.E.Artikelnr->Winfocusset(false);
end;


//========================================================================
//  AusLageradresse
//
//========================================================================
sub AusLageradresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Ein.E.Lageradresse # Adr.Nummer;
    Ein.E.Lageranschrift # 1;
    gSelected # 0;
  end;
  // Focus setzen:
  $edEin.E.Lageradresse->Winfocusset(false);
  RefreshIfm('edEin.E.Lageranschrift');
end;


//========================================================================
//  AusLageranschrift
//
//========================================================================
sub AusLageranschrift()
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    Ein.E.Lageranschrift # Adr.A.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edEin.E.Lageranschrift->Winfocusset(false);
//  RefreshIfm('edEin.Lieferanschrift');
end;


//========================================================================
//  AusLagerplatz
//
//========================================================================
sub AusLagerplatz()
begin
  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    Ein.E.Lagerplatz # Lpl.Lagerplatz;
    // Feldübernahme
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Lagerplatz->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "Ein.E.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "Ein.E.Güte" # "MQu.Güte1"
    else
      "Ein.E.Güte" # "MQu.Güte2";
    gSelected # 0;
  end;
  // Focus setzen:
  $edEin.E.Guete->Winfocusset(false);
end;


//========================================================================
//  AusGuetenstufe
//
//========================================================================
sub AusGuetenstufe()
begin
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "Ein.E.Gütenstufe" # MQu.S.Stufe;
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Guetenstufe->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Warengruppe # Wgr.Nummer;
  end;
  // Focus setzen:
  $edEin.E.Warengruppe->Winfocusset(false);
end;


//========================================================================
//  AusIntrastat
//
//========================================================================
sub AusIntrastat()
begin
  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    // Feldübernahme
    Ein.E.Intrastatnr # MSL.Intrastatnr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Intrastatnr->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusErzeuger
//
//========================================================================
sub Auserzeuger()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Ein.E.Erzeuger      # Adr.Nummer;
    Ein.E.Ursprungsland # Adr.LKZ;
    gSelected # 0;
  end;
  // Focus setzen:
  $edEin.E.Erzeuger->Winfocusset(false);
  RefreshIfm();
end;


//========================================================================
//  AusLand
//
//========================================================================
sub AusLand()
begin
  if (gSelected<>0) then begin
    RecRead(812,0,_RecId,gSelected);
    // Feldübernahme
    Ein.E.Ursprungsland # "Lnd.Kürzel";
    gSelected # 0;
  end;
  // Focus setzen:
  $edEin.E.Ursprungsland->Winfocusset(false);
//  RefreshIfm('edEin.Land');
end;


//========================================================================
//  AusVerwiegungsart
//
//========================================================================
sub AusVerwiegungsart()
begin
  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Verwiegungsart # VwA.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Verwiegungsart->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusZwischenlage
//
//========================================================================
sub AusZwischenlage()
begin
  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Zwischenlage # ULa.Bezeichnung;
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Zwischenlage->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusUnterlage
//
//========================================================================
sub AusUnterlage()
begin
  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Unterlage # ULa.Bezeichnung;
    "Ein.E.StapelhöhenAbz" # "ULa.Höhenabzug";
    $edEin.E.StapelhoehenAbz->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Unterlage->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusUmverpackung
//
//========================================================================
sub AusUmverpackung()
begin
  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Umverpackung # ULa.Bezeichnung;
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Umverpackung->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
begin
  gSelected # 0;
  Ein.E.AusfOben # Obf_Data:BildeAFString(506,'1');
  // Focus auf Editfeld setzen:
  $edEin.E.AusfOben->Winfocusset(true);
end;


//========================================================================
//  AusAFUnten
//
//========================================================================
sub AusAFUnten()
begin
  gSelected # 0;
  Ein.E.AusfUnten # Obf_Data:BildeAFString(506,'2');
  // Focus auf Editfeld setzen:
  $edEin.E.AusfUnten->Winfocusset(true);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx         : int;
  d_MenuItem  : int;
  vHdl        : int;
  vVerbucht   : logic;
  vMatDa      : logic;
  vMitDel     : logic;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  vMatDa # true;
  if (Ein.E.Materialnr<>0) then begin
    Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
    if (Erx=_rOK) then begin
      vVerbucht # EKK_Data:BereitsVerbuchtYN(506);
      vMatDa # ("Mat.Löschmarker"='');
    end
    else begin
      vVerbucht # n;
    end;
  end;

  // Ankerfunktion?
  GV.Logic.01 # vVerbucht;
  RunAFX('Ein.E.VerbuchCheck','');
  vVerbucht # GV.Logic.01;


  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMenu->WinSearch('Mnu.Bestand');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_EK_E_Aendern]=n) or (vVerbucht);

  vHdl # gMenu->WinSearch('Mnu.Versandpool');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                        (Ein.E.Materialnr=0) or (Ein.E.VSBYN=false) or
                        ("Ein.E.Löschmarker"<>'') or
                      (Rechte[Rgt_EK_E_Versandpool]=n);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Ein.P.Löschmarker"='*') or (vHdl->wpDisabled) or (Rechte[Rgt_EK_E_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Ein.P.Löschmarker"='*') or (vHdl->wpDisabled) or (Rechte[Rgt_EK_E_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_E_Aendern]=n);// or (vVerbucht);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_E_Aendern]=n);// or (vVerbucht);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Ein.P.Löschmarker"='*') or (vMatDa=false) or (vVerbucht) or (Mode<>c_ModeList) or (w_Auswahlmode) or (Rechte[Rgt_EK_E_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Ein.P.Löschmarker"='*') or (vMatDa=false) or (vVerbucht) or (Mode<>c_ModeList) or (w_Auswahlmode) or (Rechte[Rgt_EK_E_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.VSB2WE');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ("Ein.P.Löschmarker"='*') or ("Ein.E.Löschmarker"='*') or (Ein.E.VSBYN=n) or (w_Auswahlmode) or (Rechte[Rgt_EK_E_VSB2WE]=n);

  vHdl # gMenu->WinSearch('Mnu.Copy.Analyse');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) or (Rechte[Rgt_EK_E_Aendern]=n) or (Set.LyseErweitertYN);

  vHdl # gMenu->WinSearch('Mnu.LfE');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_LfErklaerungen]=false) or
        (StrFind(Set.Module,'L',0)=0) or (Ein.E.Materialnr=0) or (Ein.E.Eingang_Datum=0.0.0);


  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();


  // 27.01.2022 AH
  if (Mode=c_ModeList) and (w_Command=*'RESTRANSFER*') then begin
    vMitDel # w_Command='RESTRANSFER*';
    w_Command # '';
    StartReserv(true, vmitDel);
  end;

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
  vTmp    : int;
  vQ      : alpha(4000);
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.Mark.Sel' : begin
      Ein_E_Mark_Sel();
    end;


    'Mnu.LfE' : begin
        Ein_E_Subs:LFE();
      end;


    'Mnu.Filter.Geloescht' : begin
      Filter_Ein_E # !Filter_Ein_E;
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_Ein_E;
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      RETURN true;
    end;


    'Mnu.Copy.Analyse' : begin
      if (Mode=c_modeList) then begin
        Erx # RecRead(506,0,_recid,gZLLIst->wpDbRecId);
        if (Erx<=_rLocked) then begin
          Ein_E_Subs:CopyAnalyse();
          gZLList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect);
        end;
      end;
    end;


    'Mnu.Ktx.Errechnen' : begin
      // Ankerfunktion?
      if (RunAFX('Ein.E.Mat.Ktx.Errechnen',aEvt:Obj->wpname)<>0) then RETURN true;

//      if (Mode=c_ModeEdit) then RETURN true;    23.03.2022 AH eher so....
      if (Mode<>c_ModeEdit) and (Mode<>c_ModeNew) then RETURN true;
      
      if (aEvt:Obj->wpname='edEin.E.Menge') then begin
        Ein.E.Menge # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, 0.0, '', Ein.E.MEH);
        $edEin.E.Menge->winupdate(_WinUpdFld2Obj);
      end;

      if (aEvt:Obj->wpname='edEin.E.Gewicht') then begin
        Ein.E.Gewicht # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Ein.E.Stückzahl", Ein.E.Dicke, Ein.E.Breite, "Ein.E.länge", Ein.E.Warengruppe, "Ein.E.Güte", Ein.E.Artikelnr);
        if (Ein.E.Gewicht=0.0) then begin // 23.03.2022 AH HWN
          Ein.E.Gewicht # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", 0.0, Ein.E.Menge, Ein.E.MEH, 'kg');
        end;
        $edEin.E.Gewicht->winupdate(_WinUpdFld2Obj);
        // 27.11.2014
        Ein.E.Gewicht.Brutto  # Ein.E.Gewicht;
        Ein.E.Gewicht.Netto   # Ein.E.Gewicht;
        $edEin.E.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
        $edEin.E.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
      end;
      if (aEvt:Obj->wpname='edEin.E.Stueckzahl') then begin
        "Ein.E.Stückzahl" # Lib_Berechnungen:STK_aus_KgDBLWgrArt(Ein.E.Gewicht, Ein.E.Dicke, Ein.E.Breite, "Ein.E.länge", Ein.E.Warengruppe, "Ein.E.Güte", Ein.E.Artikelnr);
        $edEin.E.Stueckzahl->WinUpdate( _winUpdFld2Obj );
      end;
    end;


    'Mnu.Versandpool' : begin
      Ein_E_Subs:Versand();
    end;


    'Mnu.VSB2WE' : begin
      if ("Ein.P.Löschmarker"='') and ("Ein.E.Löschmarker"='') and (Ein.E.VSBYN) and (Rechte[Rgt_EK_E_VSB2WE]) then begin
        vTmp # gMDI->Winsearch('lb.GegenVSB');
        vTmp->wpcustom # AInt(Ein.E.Eingangsnr);

        w_NoClrList # y;
        APP_Main:Action(c_ModeNew);   // in NEUANLAGE wechseln
        w_NoClrList # n;

        Ein.E.VSByn       # n;        // Vorbelegen....
        Ein.E.EingangYN   # y;
        Ein.E.Eingangsnr  # 0;
        Ein.E.Eingang_Datum # today;

        Ein.E.Lageradresse    # Ein.Lieferadresse;
        Ein.E.Lageranschrift  # Ein.Lieferanschrift;
        Erx # RecLink(100,506,6,_recFirst);   // Lagerandresse holen
        if (Erx<=_rLocked) then
          $lb.Adresse->wpcaption # Adr.Stichwort
        else
          $lb.Adresse->wpcaption # '';
        Erx # RecLink(101,506,7,_recFirst);   // Lageranschrift holen
        if (Erx<=_rLocked) then
          $lb.Anschrift->wpcaption # Adr.A.Stichwort
        else
          $lb.Anschrift->wpcaption # '';


        // ST 2011-09-26: Bei Konsieingänge muss Lagerort angegeben werden
        // Auftragsart lesen
        if (RecLink(835,501,5,0) = _rOK) then begin
          if (AAr.KonsiYN) then begin
            Ein.E.Lageradresse # 0;
            Ein.E.Lageranschrift # 0;

            $edEin.E.Lageradresse->winupdate(_WinUpdFld2Obj);
            $edEin.E.Lageranschrift->winupdate(_WinUpdFld2Obj);
            $lb.Adresse->wpCaption # '';
            $lb.Anschrift->wpCaption # '';
          end
        end;

        $cbEin.E.VSBYN->winupdate(_WinUpdFld2Obj);
        $cbEin.E.EingangYN->winupdate(_WinUpdFld2Obj);
        $edEin.E.Eingang.Datum->winupdate(_WinUpdFld2Obj);


        RETURN true;
      end;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Ein.E.Anlage.Datum, Ein.E.Anlage.Zeit, Ein.E.Anlage.User);
    end;


    'Mnu.Bestand' : begin
      if ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_EK_E_Aendern]=n) then RETURN false;

      Ein_E_Data:Bestandsaenderung();

      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
      if (Mode=c_ModeView) then begin
        gMDI->Winupdate();
        Refreshifm();
      end;

      RETURN true;
    end;


    'Mnu.Aktion' : begin
      Erx # RecRead(gFile,1,0);
      if (Erx=_rOK) and (Ein.E.Materialnr<>0) then begin
        Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
        if (Erx=_rOK) then begin
          RecBufClear(203);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.A.Verwaltung','',y);
          Mat_A_Data:BuildFullAktionsliste();
          Lib_GuiCom:RunChildWindow(gMDI);
        end;
      end;
    end;


    'Mnu.Reservierungen' : begin
      StartReserv(false, false);
    end;

    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
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
begin

  if (aEvt:Obj->wpName='bt.AnalyseAnzeigen') then begin
    if (Ein.E.Analysenummer<>0) then begin
      MQU_Data:Read("Ein.P.Güte", "Ein.P.Gütenstufe", y, Ein.P.Dicke);
      Lys.K.AnalyseNr # Ein.E.AnalyseNummer;
      RecRead(230,1,0);
      RecLink(231,230,1,_recFirst);
      if (Set.LyseErweitertYN) then
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lys.K.Verwaltung2','', n,n,'ZUM_WE')
      else
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lys.K.Verwaltung','');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_modeBald + c_modeView;
      w_NoList # y;
      Lib_GuiCom:RunChildWindow(gMDI);
      RETURN true;
    end;
  end;


  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Material'       : Auswahl('Material');
    'bt.Artikel'        : Auswahl('Artikel');
    'bt.Adresse'        : Auswahl('Lageradresse');
    'bt.Anschrift'      : Auswahl('Lageranschrift');
    'bt.Lagerplatz'     : Auswahl('Lagerplatz');
    'bt.Kommission'     : Auswahl('Kommission');
    'bt.Guete'          : Auswahl('Guete');
    'bt.Guetenstufe'    : Auswahl('Guetenstufe');
    'bt.Warengruppe'    : Auswahl('Warengruppe');
    'bt.Intrastat'      : Auswahl('Intrastat');
    'bt.Erzeuger'       : Auswahl('Erzeuger');
    'bt.Land'           : Auswahl('Land');
    'bt.Verwiegungsart' : Auswahl('Verwiegungsart');
    'bt.Zwischenlage'   : Auswahl('Zwischenlage');
    'bt.Unterlage'      : Auswahl('Unterlage');
    'bt.Umverpackung'   : Auswahl('Umverpackung');
    'bt.AusfOben'       : Auswahl('AusfOben');
    'bt.AusfUnten'      : Auswahl('AusfUnten');
    'bt.Analyse'          :   Auswahl('Analyse');
    'bt.AnalyseAnzeigen1' :   Auswahl('AnalyseAnzeigen');
   end;

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

  if (aEvt:Obj->wpname='cbEin.E.VSBYN') and (Ein.E.VSBYN) then begin
    Ein.E.Materialnr  # 0;
    $edEin.E.MaterialNr->winupdate(_WinUpdFld2Obj);
    Lib_GuiCom:Disable($edEin.E.Materialnr);
    Lib_GuiCom:Disable($bt.Material);

    Ein.E.EingangYN # n;
    Ein.E.AusfallYN # n;
    Ein.E.VSB_Datum # today;
    if (Mode=c_ModeNew) then begin
      Ein.E.Eingang_Datum # 0.0.0;
      Ein.E.Ausfall_Datum # 0.0.0;
    end;
    $cbEin.E.EingangYN->winupdate(_WinUpdFld2Obj);
    $cbEin.E.AusfallYN->winupdate(_WinUpdFld2Obj);
    $edEin.E.VSB.Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Eingang.Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Ausfall.Datum->winupdate(_WinUpdFld2Obj);

    if (Mode=c_ModeNew) then begin
      Lib_GuiCom:Enable($edEin.E.VSB.Datum);
      Lib_GuiCom:Disable($edEin.E.Eingang.Datum);
      Lib_GuiCom:Disable($edEin.E.Ausfall.Datum);
    end;

/*
    // ST 2011-09-26: Bei VSB Meldungen liegt das Material noch beim Lieferanten
    // AI 2011-12-01: Projekt 1323/52
*/
    if (Ein.E.Lageradresse = 0) then begin
      // Adressnummer des Lieferanten lesen
      if (RecLink(100,500,1,0) <= _rLocked) then begin
        Ein.E.Lageradresse    # Adr.Nummer;
        Ein.E.Lageranschrift  # 1;
      end;
    end;

    App_Main:EvtFocusTerm(aEvt, $edEin.E.Lageradresse);
    $edEin.E.Lageradresse->winfocusset();
    RefreshIfm();
  end;

  if (aEvt:Obj->wpname='cbEin.E.EingangYN') and (Ein.E.EingangYN) then begin
    Lib_GuiCom:Enable($edEin.E.Materialnr);
    Lib_GuiCom:Enable($bt.Material);

    Ein.E.VSBYN # n;
    Ein.E.AusfallYN # n;
    Ein.E.Eingang_Datum # today;
    if (Mode=c_ModeNew) then begin
      Ein.E.VSB_Datum     # 0.0.0;
      Ein.E.Ausfall_Datum # 0.0.0;
    end;
    $cbEin.E.VSBYN->winupdate(_WinUpdFld2Obj);
    $cbEin.E.AusfallYN->winupdate(_WinUpdFld2Obj);
    $edEin.E.VSB.Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Eingang.Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Ausfall.Datum->winupdate(_WinUpdFld2Obj);

    if (Mode=c_ModeNew) then begin
      Lib_GuiCom:Enable($edEin.E.Eingang.Datum);
      Lib_GuiCom:Disable($edEin.E.VSB.Datum);
      Lib_GuiCom:Disable($edEin.E.Ausfall.Datum);
    end;
/*
    // ST 2011-09-26: Eingänge liegen beim Zielort
    // AI 2011-12-01: Projekt 1323/52
*/
    if (Ein.E.Lageradresse = 0) then begin
      // Adressnummer des Lieferanten lesen
      if (RecLink(100,500,1,0) <= _rLocked) then begin
        Ein.E.Lageradresse    # Ein.Lieferadresse;
        Ein.E.Lageranschrift  # Ein.Lieferanschrift;
      end;
    end;

    App_Main:EvtFocusTerm(aEvt, $edEin.E.Lageradresse);
    $edEin.E.Lageradresse->winfocusset();
    RefreshIfm();
  end;

  if (aEvt:Obj->wpname='cbEin.E.AusfallYN') and (Ein.E.AusfallYN) then begin
    Ein.E.Materialnr  # 0;
    $edEin.E.MaterialNr->winupdate(_WinUpdFld2Obj);
    Lib_GuiCom:Disable($edEin.E.Materialnr);
    Lib_GuiCom:Disable($bt.Material);

    Ein.E.EingangYN # n;
    Ein.E.VSBYN # n;
    Ein.E.Ausfall_Datum # today;
    if (Mode=c_ModeNew) then begin
      Ein.E.VSB_Datum     # 0.0.0;
      Ein.E.Eingang_Datum # 0.0.0;
    end;
    $cbEin.E.EingangYN->winupdate(_WinUpdFld2Obj);
    $cbEin.E.VSBYN->winupdate(_WinUpdFld2Obj);
    $edEin.E.VSB.Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Eingang.Datum->winupdate(_WinUpdFld2Obj);
    $edEin.E.Ausfall.Datum->winupdate(_WinUpdFld2Obj);

    if (Mode=c_ModeNew) then begin
      Lib_GuiCom:Enable($edEin.E.Ausfall.Datum);
      Lib_GuiCom:Disable($edEin.E.VSB.Datum);
      Lib_GuiCom:Disable($edEin.E.Eingang.Datum);
    end;

    App_Main:EvtFocusTerm(aEvt, $edEin.E.Lageradresse);
    $edEin.E.Lageradresse->winfocusset();
  end;

/***
  case (aEvt:Obj->wpname) of
    'cbEin.E.DickenTolYN'     : RefreshIfm(aEvt:Obj->wpname);
    'cbEin.E.BreitenTolYN'    : RefreshIfm(aEvt:Obj->wpname);
    'cbEin.E.LaengenTolYN'    : RefreshIfm(aEvt:Obj->wpname)
  end;
***/


  RETURN true;
end;


//========================================================================
// AFObenRecCtrl
//              Popuplist Auflage Oben Filter
//========================================================================
sub AFObenRecCtrl(
  aEvt : event;
  aRecId : int;
) : logic;
begin
  Ein.E.AF.Bezeichnung # StrCut(Ein.E.AF.Bezeichnung + ':'+Ein.E.AF.Zusatz, 1, 32);
  RETURN Ein.E.AF.Seite='1';
end;


//========================================================================
// AFUntenRecCtrl
//              Popuplist Auflage Unten Filter
//========================================================================
sub AFUntenRecCtrl(
  aEvt : event;
  aRecId : int;
) : logic;
begin
  Ein.E.AF.Bezeichnung # StrCut(Ein.E.AF.Bezeichnung + ':'+Ein.E.AF.Zusatz, 1, 32);;
  RETURN Ein.E.AF.Seite='2';
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

  if (aMark=n) then begin
    if ("Ein.E.Löschmarker"='*') then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
    else if (Ein.E.VSBYN) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Bestellt)
    else if (Ein.E.AusfallYN) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Reserv);
  end;

  Mat_data:Read(Ein.E.Materialnr);

  GV.Int.01   # Mat.EK.RechNr;
  if (Mat.LfENr=-1) then
    Gv.Alpha.01 # Translate('fehlt')
  else if (Mat.LfENr>0) then
    Gv.Alpha.01 # aint(Mat.LfeNr)
  else
    Gv.Alpha.01 # Translate('ohne');

//  Refreshmode();
end;


//========================================================================
//  EvtLstRecControl
//
//========================================================================
sub EvtLstRecControl(
  opt aEvt      : event;
  opt aRecid    : int;
) : logic;
begin
  if ("Ein.E.Löschmarker"='*') and (Filter_Ein_E) then RETURN false;
  RETURN true;
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
local begin
  Erx : int;
end;
begin

  RecRead(gFile,0,_recid,aRecID);

  if (Ein.E.Nummer<>0) and (Ein.E.Nummer<1000000000) then begin
    Erx # RecLink(501,506,1,_recFirst);   // Position holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(511,506,11,_recFirst);   // Positionsablage holen
      if (Erx>_rLocked) then RecBufClear(511);
      RecBufCopy(511,501);
    end;
  end;

  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
//  StartReserv
//========================================================================
sub StartReserv(
  aInUebernahme : logic;
  aDanachPosDel : logic)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  Erx # RecRead(gFile,1,0);
  if (erx<>_rOK) then RETURN;
  if (Ein.E.Materialnr<>0) and (Ein.P.KommissionNr=0) then begin
    Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
    if (Erx=_rOK) then begin
      RecBufClear(203);
      if (aDanachPosDel) then
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Rsv.Verwaltung', here+':AusResDannPosDel', y)
      else
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Rsv.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # 'MAT';
      gZLList->wpdbfileno     # 200;
      gZLList->wpdbkeyno      # 13;
      gZLList->wpdbLinkFileNo # 203;
      if (aInUebernahme) then w_Command # 'UEBERNAHME';
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;
end;


//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vQ  :  alpha(1000);
end;
begin

  if (aName = StrCnv('clmEin.E.Materialnr',_StrUpper) AND (aBuf->Ein.E.Materialnr <> 0)) then begin
    if (Mat_Data:Read(aBuf->Ein.E.Materialnr,_RecUnlock,0,true) > 0) then
      Mat_Main:Start(0, aBuf->Ein.E.Materialnr,y);
  end;
  
   if ((aName =^ 'edEin.E.Materialnr') AND (aBuf->Ein.E.Materialnr<>0)) then begin
    RekLink(200,506,8,0);   // Materialnr. holen
    Lib_Guicom2:JumpToWindow('Mat.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Verwiegungsart') AND (aBuf->Ein.E.Verwiegungsart<>0)) then begin
    RekLink(818,506,12,0);   // Verweigungsart holen
    Lib_Guicom2:JumpToWindow('VwA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Guetenstufe') AND (aBuf->"Ein.E.Gütenstufe"<>'')) then begin
    MQu.S.Stufe # "Ein.E.Gütenstufe";
    RecRead(848,1,0)
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Guete') AND (aBuf->"Ein.E.Güte"<>'')) then begin
    RekLink(200,506,8,0);   // Güte holen
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.AusfOben') AND (aBuf->Ein.E.AusfOben<>'')) then begin
    Obf.Bezeichnung.L1 # Ein.E.AusfOben;
    RecRead(841,2,0)
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.AusfUnten') AND (aBuf->Ein.E.AusfUnten<>'')) then begin
    Obf.Bezeichnung.L1 # Ein.E.AusfUnten;
    RecRead(841,2,0)
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Artikelnr') AND (aBuf->Ein.E.Artikelnr<>'')) then begin
    RekLink(250,506,5,0);   // Artikelnummer holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Lageranschrift') AND (aBuf->Ein.E.Lageranschrift<>0)) then begin
    RekLink(101,506,7,0);   // Anschrift holen
    Adr.A.Adressnr # Ein.E.Lageradresse;
    Adr.A.Nummer # Ein.E.Lageranschrift;
    RecRead(101,1,0);
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Ein.E.Lageradresse);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Lagerplatz') AND (aBuf->Ein.E.Lagerplatz<>'')) then begin
    LPl.Lagerplatz # Ein.E.Lagerplatz;
    RecRead(844,1,0)
    Lib_Guicom2:JumpToWindow('LPl.Verwaltung');
    RETURN;
  end;

  if ((aName =^ 'edEin.E.Intrastatnr') AND (aBuf->Ein.E.Intrastatnr<>'')) then begin
    MSL.Intrastatnr # Ein.E.Intrastatnr;
    RecRead(220,2,0)
    Lib_Guicom2:JumpToWindow('MSL.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Warengruppe') AND (aBuf->Ein.E.Warengruppe<>0)) then begin
    RekLink(819,506,4,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;

  if ((aName =^ 'edEin.E.Erzeuger') AND (aBuf->Ein.E.Erzeuger<>0)) then begin
    RekLink(100,506,15,0);   // Erzeuger holen
    Lib_Guicom2:JumpToWindow('MSL.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Ursprungsland') AND (aBuf->Ein.E.Ursprungsland<>'')) then begin
    RekLink(812,506,14,0);   // Ursprungsland holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Zwischenlage') AND (aBuf->Ein.E.Zwischenlage<>'')) then begin
    ULa.Bezeichnung # Ein.E.Zwischenlage;
    RecRead(838,2,0)
    Lib_Guicom2:JumpToWindow('ULA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Unterlage') AND (aBuf->Ein.E.Unterlage<>'')) then begin
    ULa.Bezeichnung # Ein.E.Unterlage;
    RecRead(838,2,0)
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.E.Umverpackung') AND (aBuf->Ein.E.Umverpackung<>'')) then begin
    ULa.Bezeichnung # Ein.E.Umverpackung ;
    RecRead(838,2,0)
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;

end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================