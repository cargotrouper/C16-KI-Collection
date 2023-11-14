@A+
//==== Business-Control ==================================================
//
//  Prozedur    SWe_P_Main
//                OHNE E_R_G
//  Info
//
//
//  18.09.2007  AI  Erstellung der Prozedur
//  24.08.2008  ST  Bei Sicherung eines Einganges wird jetzt die
//                  Materialkarte angelegt und das Etikett gedruckt
//  04.11.2010  PW  Serienmarkierung
//  23.08.2011  ST  "Eingänge" auch änderbar, wenn keine Aktionen hinterlegt sind
//  14.03.2012  AI  SWe.Position änderbar solange kein MAterial vergeben bzw. keine Mat.Aktionsliste
//  04.05.2012  AI  BUG: beim Löschen/Ändern (Prj 1134/241)
//  11.10.2012  ST  BUG: Bei Cleanup Ausführungen bei Edit nicht Löschen 1388/11
//  22.08.2013  AH  Neu: Warengruppe wird beim RecSave geprüft
//  16.09.2013  AH  BUG: "RecDel" setzt Ausgangsdatum nicht
//  29.01.2018  AH  AnalyseErweitert
//  16.08.2018  ST  AFX "SWe.P.Init" % "SWe.P.Init.Pre" Hinzugefügt Projekt 1864/210
//  04.02.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//  2022-08-16  ST  Neu: Avisierungserledigung nach Eingangsmelöduing  2430/4
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB CheckAnalyse(aObj  : int; aName : alpha; aWert : float; );
//    SUB RefreshIfm(optaName : alpha)
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
//    SIB AusEinzelgewichte();
//    SUB AusLageradresse()
//    SUB AusLageranschrift()
//    SUB AusLagerplatz()
//    SUB AusGuete()
//    SUB AusGuetenstufe()
//    SUB AusWarengruppe()
//    SUB AusArtikel()
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
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    sub AusSerienMark ()
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Sammelwareneingänge'
  cFile :     621
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'SWe_P'
  cZList :    $ZL.SWe.Positionen
  cKey :      1
  cListen   : '';
end;

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
  w_Listen  # cListen;

  $lb.Nummer->wpcaption     # AInt(SWe.Nummer);
  $lb.Stichwort->wpcaption  # SWe.LieferantenSW;

  if (Set.Installname='BSP') then begin
    $lbSWE.P.CO2EinstandPT->wpvisible # true;
    $edSWE.P.CO2EinstandPT->wpvisible # true;
    $lbCO2->wpvisible # true;
  end;


  // Chemietitel ggf. setzen
  if (Set.Chemie.Titel.C<>'') then begin
    $lbSWe.P.Chemie.C->wpcaption # Set.Chemie.Titel.C;
  end;
  if (Set.Chemie.Titel.Si<>'') then begin
    $lbSWe.P.Chemie.Si->wpcaption # Set.Chemie.Titel.Si;
  end;
  if (Set.Chemie.Titel.Mn<>'') then begin
    $lbSWe.P.Chemie.Mn->wpcaption # Set.Chemie.Titel.Mn;
  end;
  if (Set.Chemie.Titel.P<>'') then begin
    $lbSWe.P.Chemie.P->wpcaption # Set.Chemie.Titel.P;
  end;
  if (Set.Chemie.Titel.S<>'') then begin
    $lbSWe.P.Chemie.S->wpcaption # Set.Chemie.Titel.S;
  end;
  if (Set.Chemie.Titel.Al<>'') then begin
    $lbSWe.P.Chemie.Al->wpcaption # Set.Chemie.Titel.Al;
  end;
  if (Set.Chemie.Titel.Cr<>'') then begin
    $lbSWe.P.Chemie.Cr->wpcaption # Set.Chemie.Titel.Cr;
  end;
  if (Set.Chemie.Titel.V<>'') then begin
    $lbSWe.P.Chemie.V->wpcaption # Set.Chemie.Titel.V;
  end;
  if (Set.Chemie.Titel.Nb<>'') then begin
    $lbSWe.P.Chemie.Nb->wpcaption # Set.Chemie.Titel.Nb;
  end;
  if (Set.Chemie.Titel.Ti<>'') then begin
    $lbSWe.P.Chemie.Ti->wpcaption # Set.Chemie.Titel.Ti;
  end;
  if (Set.Chemie.Titel.N<>'') then begin
    $lbSWe.P.Chemie.N->wpcaption # Set.Chemie.Titel.N;
  end;
  if (Set.Chemie.Titel.Cu<>'') then begin
    $lbSWe.P.Chemie.Cu->wpcaption # Set.Chemie.Titel.Cu;
  end;
  if (Set.Chemie.Titel.Ni<>'') then begin
    $lbSWe.P.Chemie.Ni->wpcaption # Set.Chemie.Titel.Ni;
  end;
  if (Set.Chemie.Titel.Mo<>'') then begin
    $lbSWe.P.Chemie.Mo->wpcaption # Set.Chemie.Titel.Mo;
  end;
  if (Set.Chemie.Titel.B<>'') then begin
    $lbSWe.P.Chemie.B->wpcaption # Set.Chemie.Titel.B;
  end;
  if (Set.Chemie.Titel.1<>'') then begin
    $lbSWe.P.Chemie.Frei1->wpcaption # Set.Chemie.Titel.1;
  end;
  if ("Set.Mech.Titel.Härte"<>'') then begin
    $lbSWe.P.Haerte->wpcaption # "Set.Mech.Titel.Härte";
  end;
  if ("Set.Mech.Titel.Körn"<>'') then begin
    $lbSWe.P.Koernung->wpcaption # "Set.Mech.Titel.Körn";
  end;
  if ("Set.Mech.Titel.Sonst"<>'') then begin
    $lbSWe.P.Mech.Sonstiges->wpcaption # "Set.Mech.Titel.Sonst";
  end;
  if ("Set.Mech.Titel.Rau1"<>'') then begin
    $lbSWe.P.RauigkeitA1->wpcaption # "Set.Mech.Titel.Rau1";
  end;
  if ("Set.Mech.Titel.Rau2"<>'') then begin
    $lbSwe.P.RauigkeitB1->wpcaption # "Set.Mech.Titel.Rau2";
  end;

  if (Set.Mech.Dehnung.Wie<>1) then
    $lbSWe.P.DehnungB->wpvisible # false;

Lib_Guicom2:Underline($edSWe.P.Verwiegungsart);
Lib_Guicom2:Underline($edSWe.P.Guetenstufe);
Lib_Guicom2:Underline($edSWe.P.Guete);
Lib_Guicom2:Underline($edSWe.P.AusfOben);
Lib_Guicom2:Underline($edSWe.P.AusfUnten);
Lib_Guicom2:Underline($edSWe.P.Artikelnr);
Lib_Guicom2:Underline($edSWe.P.Lageradresse);
Lib_Guicom2:Underline($edSWe.P.Lageranschrift);
Lib_Guicom2:Underline($edSWe.P.Lagerplatz);
Lib_Guicom2:Underline($edSWe.P.Intrastatnr);
Lib_Guicom2:Underline($edSWe.P.Warengruppe);
Lib_Guicom2:Underline($edSWe.P.Erzeuger);
Lib_Guicom2:Underline($edSWe.P.Ursprungsland);
Lib_Guicom2:Underline($edSWe.P.Zwischenlage);
Lib_Guicom2:Underline($edSWe.P.Unterlage);
Lib_Guicom2:Underline($edSWe.P.Umverpackung);


 // Auswahlfelder setzen...
  SetStdAusFeld('edSWe.P.Lageradresse'   ,'Lageradresse');
  SetStdAusFeld('edSWe.P.Lageranschrift' ,'Lageranschrift');
  SetStdAusFeld('edSWe.P.Lagerplatz'     ,'Lagerplatz');
  SetStdAusFeld('edSWe.P.Warengruppe'    ,'Warengruppe');
  SetStdAusFeld('edSWe.P.Artikelnr'      ,'Artikel');
  SetStdAusFeld('edSWe.P.Intrastatnr'    ,'Intrastat');
  SetStdAusFeld('edSWe.P.Erzeuger'       ,'Erzeuger');
  SetStdAusFeld('edSWe.P.Ursprungsland'  ,'Land');
  SetStdAusFeld('edSWe.P.Guete'          ,'Guete');
  SetStdAusFeld('edSWe.P.Guetenstufe'    ,'Guetenstufe');
  SetStdAusFeld('edSWe.P.Kommission'     ,'Kommission');
  SetStdAusFeld('edSWe.P.Verwiegungsart' ,'Verwiegungsart');
  SetStdAusFeld('edSWe.P.Zwischenlage'   ,'Zwischenlage');
  SetStdAusFeld('edSWe.P.Unterlage'      ,'Unterlage');
  SetStdAusFeld('edSWe.P.Umverpackung'   ,'Umverpackung');
  SetStdAusFeld('edSWe.P.AusfOben'       ,'AusfOben');
  SetStdAusFeld('edSWe.P.AusfUnten'      ,'AusfUnten');

  if (Set.LyseErweitertYN) then begin
    vHdl # Winsearch(aEvt:Obj, 'lbSWe.P.Saebeligkeit');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'edSWe.P.Saebeligkeit');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'lbSWe.P.SaebelProM');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'edSWe.P.SaebelProM');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'lbSaebel');
    if (vHdl<>0) then vHdl->wpVisible # false;

    vPar # Winsearch(aEvt:Obj, 'NB.Page2');
    Lib_GuiCom2:Hide(vPar, 'lbAnalyseStart', 'lb.Vor.Chemie.Frei1');
    vHdl # Winsearch(vPar, 'lbSWe.P.Analysenr');
    if (vHdl<>0) then vHdl->wpVisible # true;
    vHdl # Winsearch(vPar, 'edSWe.P.Analysenr');
    if (vHdl<>0) then vHdl->wpVisible # true;
    vHdl # Winsearch(vPar, 'bt.Analyse');
    if (vHdl<>0) then vHdl->wpVisible # true;
    vHdl # Winsearch(vPar, 'bt.AnalyseAnzeigen');
    if (vHdl<>0) then vHdl->wpVisible # true;
    SetStdAusFeld('edSWe.P.Analysenr'      ,'Analyse');
  end;

  RunAFX('SWe.P.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('SWe.P.Init',aint(aEvt:Obj));
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edSWe.P.Stueckzahl);
  Lib_GuiCom:Pflichtfeld($edSWe.P.Gewicht);
  Lib_GuiCom:Pflichtfeld($edSWe.P.Lageradresse);
  Lib_GuiCom:Pflichtfeld($edSWe.P.Lageranschrift);
  Lib_GuiCom:Pflichtfeld($edSWe.P.Warengruppe);
  Lib_GuiCom:Pflichtfeld($edSWe.P.Ursprungsland);
  Lib_GuiCom:Pflichtfeld($edSWe.P.Erzeuger);
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
/*
  aObj->wpcaption # MQU_Data:BildeVorgabe(aName, 621, "SWe.P.Güte", SWe.P.Dicke, var vVon, var vBis);

  if ((aWert<vVon) or (aWert>vBis)) and ((vVon<>0.0) or (vBis<>0.0)) then
    aObj->wpColBkg # _WinColLightRed
  else
    aObj->wpColBkg # _WinColparent;
*/
  vA # MQU_Data:BildeVorgabe(aName, 621, "SWe.P.Güte", SWe.P.Dicke, var vVon, var vBis);

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
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
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
  end;

  if (Set.LyseErweitertYN=false) then begin
    if (aName='') or ((aName='edSWe.P.Streckgrenze') and ($edSWe.P.Streckgrenze->wpchanged)) then
      CheckAnalyse($lb.Vor.Streckgrenze,'Streckgrenze',SWe.P.Streckgrenze);
    if (aName='') or ((aName='edSWe.P.Zugfestigkeit') and ($edSWe.P.Zugfestigkeit->wpchanged)) then
      CheckAnalyse($lb.Vor.Zugfestigkeit,'Zugfestigkeit',SWe.P.Zugfestigkeit);

    if (Set.Mech.Dehnung.Wie=1) then begin
      if (aName='') or ((aName='edSWe.P.DehnungA') and ($edSWe.P.DehnungA->wpchanged)) then
        CheckAnalyse($lb.Vor.DehnungA,'DehnungA',SWe.P.DehnungA);
      if (aName='') or ((aName='edSWe.P.DehnungB') and ($edSWe.P.DehnungB->wpchanged)) or
                       ((aName='edSWe.P.DehnungC') and ($edSWe.p.DehnungC->wpchanged)) then
        CheckAnalyse($lb.Vor.DehnungB,'DehnungB', SWe.P.DehnungB, SWe.P.DehnungC);
    end;
    if (Set.Mech.Dehnung.Wie=2) then begin
      if (aName='') or ((aName='edSWe.P.DehnungB') and ($edSWe.P.DehnungB->wpchanged)) then
        CheckAnalyse($lb.Vor.DehnungA,'DehnungA',SWe.P.DehnungB);
      if (aName='') or ((aName='edSWe.P.DehnungA') and ($edSWe.P.DehnungA->wpchanged)) or
                       ((aName='edSWe.P.DehnungC') and ($edSWe.P.DehnungC->wpchanged)) then
        CheckAnalyse($lb.Vor.DehnungB,'DehnungB', SWe.P.DehnungA, SWe.P.DehnungC);
    end;


    if (aName='') or ((aName='edSWe.P.DehngrenzeA') and ($edSWe.P.DehngrenzeA->wpchanged)) then
      CheckAnalyse($lb.Vor.DehngrenzeA,'DehngrenzeA',SWe.P.RP02_1);
    if (aName='') or ((aName='edSWe.P.DehngrenzeB') and ($edSWe.P.DehngrenzeB->wpchanged)) then
      CheckAnalyse($lb.Vor.DehngrenzeB,'DehngrenzeB',SWe.P.RP10_1);

  //  if (aName='') or ((aName='edSWe.P.Koernung') and ($edSWe.P.Koernung->wpchanged)) then
  //    CheckAnalyse($lb.Vor.Koernung,'DehngrenzeB',"SWe.P.Körnung");
  //  if (aName='') or ((aName='edSWe.P.Haerte') and ($edSWe.P.Haerte->wpchanged)) then
  //    CheckAnalyse($lb.Vor.Haerte,'Härte',"SWe.P.Härte");

    if (aName='') or ((aName='edSWe.P.Chemie.C') and ($edSWe.P.Chemie.C->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.C,'C',SWe.P.Chemie.C);
    if (aName='') or ((aName='edSWe.P.Chemie.Si') and ($edSWe.P.Chemie.Si->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Si,'Si',SWe.P.Chemie.Si);
    if (aName='') or ((aName='edSWe.P.Chemie.Mn') and ($edSWe.P.Chemie.Mn->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Mn,'Mn',SWe.P.Chemie.Mn);
    if (aName='') or ((aName='edSWe.P.Chemie.P') and ($edSWe.P.Chemie.P->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.P,'P',SWe.P.Chemie.P);
    if (aName='') or ((aName='edSWe.P.Chemie.S') and ($edSWe.P.Chemie.S->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.S,'S',SWe.P.Chemie.S);
    if (aName='') or ((aName='edSWe.P.Chemie.Al') and ($edSWe.P.Chemie.Al->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Al,'Al',SWe.P.Chemie.Al);
    if (aName='') or ((aName='edSWe.P.Chemie.Cr') and ($edSWe.P.Chemie.Cr->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Cr,'Cr',SWe.P.Chemie.Cr);
    if (aName='') or ((aName='edSWe.P.Chemie.V') and ($edSWe.P.Chemie.V->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.V,'V',SWe.P.Chemie.V);
    if (aName='') or ((aName='edSWe.P.Chemie.Nb') and ($edSWe.P.Chemie.Nb->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Nb,'Nb',SWe.P.Chemie.Nb);
    if (aName='') or ((aName='edSWe.P.Chemie.Ti') and ($edSWe.P.Chemie.Ti->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Ti,'Ti',SWe.P.Chemie.Ti);
    if (aName='') or ((aName='edSWe.P.Chemie.N') and ($edSWe.P.Chemie.N->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.N,'N',SWe.P.Chemie.N);
    if (aName='') or ((aName='edSWe.P.Chemie.Cu') and ($edSWe.P.Chemie.Cu->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Cu,'Cu',SWe.P.Chemie.Cu);
    if (aName='') or ((aName='edSWe.P.Chemie.Ni') and ($edSWe.P.Chemie.Ni->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Ni,'Ni',SWe.P.Chemie.Ni);
    if (aName='') or ((aName='edSWe.P.Chemie.Mo') and ($edSWe.P.Chemie.Mo->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.Mo,'Mo',SWe.P.Chemie.Mo);
    if (aName='') or ((aName='edSWe.P.Chemie.B') and ($edSWe.P.Chemie.B->wpchanged)) then
      CheckAnalyse($lb.Vor.Chemie.B,'B',SWe.P.Chemie.B);
    end;  // analysecheck

  if (aName='') or (aName='edSWe.P.Lageradresse') then begin
    Erx # RecLink(100,621,4,_recFirst);   // Lagerandresse holen
    if (Erx<=_rLocked) then
      $lb.Adresse->wpcaption # Adr.Stichwort
    else
      $lb.Adresse->wpcaption # '';
  end;

  if (aName='') or (aName='edSWe.P.Lageranschrift') then begin
    Erx # RecLink(101,621,5,_recFirst);   // Lageranschrift holen
    if (Erx<=_rLocked) then
      $lb.Anschrift->wpcaption # Adr.A.Stichwort
    else
      $lb.Anschrift->wpcaption # '';
  end;

  if (aName='') or (aName='edSWe.P.Warengruppe') then begin
    Erx # RecLink(819,621,3,_recFirst);   // Warengruppe holen
    if (Erx<=_rLocked) then
      $lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1
    else
      $lb.Warengruppe->wpcaption # '';
  end;

  if (aName='') or (aName='edSWe.P.Erzeuger') then begin
    Erx # RecLink(100,621,8,_recFirst);    // Erzeuger holen
    if (Erx<=_rLocked) then
      $lb.Erzeuger->wpcaption # Adr.Stichwort
    else
      $lb.Erzeuger->wpcaption # '';
  end;

  if (aName='') or (aName='edSWe.P.Ursprungsland') or (aName='edSWe.P.Erzeuger') then begin
    Erx # RecLink(812,621,9,_recFirst);    // Land holen
    if (Erx<=_rLocked) then
      $lb.Land->wpcaption # Lnd.Name.L1
    else
      $lb.Land->wpcaption # '';
  end;

  if (aName='') or (aName='edSWe.P.Verwiegungsart') then begin
    Erx # RecLink(818,621,11,_recFirst);   // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    $lb.Verwiegungsart->wpcaption # VWa.Bezeichnung.L1

    if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then begin
      if (Erx<=_rLocked) then begin
        if (VWa.NettoYN) then begin
          Lib_GuiCom:Disable($edSWe.P.Gewicht.Netto);
          Lib_GuiCom:Enable($edSWe.P.Gewicht.Brutto);
          end
        else if (VWa.BruttoYN) then begin
          Lib_GuiCom:Disable($edSWe.P.Gewicht.Brutto);
          Lib_GuiCom:Enable($edSWe.P.Gewicht.Netto);
          end
        else begin
          Lib_GuiCom:Enable($edSWe.P.Gewicht.Netto);
          Lib_GuiCom:Enable($edSWe.P.Gewicht.Brutto);
        end;
      end;
/*
      else begin
        SWe.P.Gewicht.Netto   # SWe.P.Gewicht;
        SWe.P.Gewicht.Brutto  # SWe.P.Gewicht;
        Lib_GuiCom:Disable($edSWe.P.Gewicht.Netto);
        Lib_GuiCom:Disable($edSWe.P.Gewicht.Brutto);
      end;
*/
    end;
  end;

  if (aName='') then begin
    $lb.Nummer1->wpcaption     # AInt(SWe.Nummer);
    $lb.Nummer2->wpcaption     # AInt(SWe.Nummer);
    $lb.Nummer3->wpcaption     # AInt(SWe.Nummer);
    $lb.Position1->wpcaption   # AInt(SWe.P.Position);
    $lb.Position2->wpcaption   # AInt(SWe.P.Position);
    $lb.Position3->wpcaption   # AInt(SWe.P.Position);
    if (SWe.P.Eingangsnr<>0) then begin
      $lb.lfdNr1->wpcaption      # AInt(SWe.P.Eingangsnr)
      $lb.lfdNr2->wpcaption      # AInt(SWe.P.Eingangsnr)
      $lb.lfdNr3->wpcaption      # AInt(SWe.P.Eingangsnr)
      end
    else begin
      $lb.lfdNr1->wpcaption      # '';
      $lb.lfdNr2->wpcaption      # '';
      $lb.lfdNr3->wpcaption      # '';
    end;
    $lb.Stichwort1->wpcaption  # SWe.LieferantenSW;
    $lb.Stichwort2->wpcaption  # SWe.LieferantenSW;
    $lb.Stichwort3->wpcaption  # SWe.LieferantenSW;
  end;

  if (Mode=c_ModeEdit) or (Mode=c_ModeNew) then begin
    if (aName='edSWe.P.Guete') and ($edSWe.P.Guete->wpchanged) then begin
      MQu_Data:Autokorrektur(var "SWe.P.Güte");
      $edSWe.P.Guete->Winupdate();
    end;

    if (aName='edSWe.P.DickenTol') and (SWe.P.Dicke<>0.0) then begin
      "SWe.P.Dickentol" # Lib_Berechnungen:Toleranzkorrektur("SWe.P.Dickentol",Set.Stellen.Dicke);
      $edSWe.P.Dickentol->Winupdate();
    end;

    if (aName='edSWe.P.BreitenTol') and (SWe.P.Breite<>0.0) then begin
      "SWe.P.Breitentol" # Lib_Berechnungen:Toleranzkorrektur("SWe.P.Breitentol",Set.Stellen.Breite);
      $edSWe.P.Breitentol->Winupdate();
    end;

    if (aName='edSWe.P.LaengenTol') and ("SWe.P.Länge"<>0.0) then begin
      "SWe.P.Längentol" # Lib_Berechnungen:Toleranzkorrektur("SWe.P.Längentol","Set.Stellen.Länge");
      $edSWe.P.Laengentol->Winupdate();
    end;
/***
    if (aName='') or (aName='cbSWe.P.DickenTolYN') then
      if (SWe.P.DickenTolYN=n) then
        Lib_GuiCom:Disable($edSWe.P.DickenTol)
      else
        Lib_GuiCom:Enable($edSWe.P.DickenTol);

    if (aName='') or (aName='cbSWe.P.BreitenTolYN') then
      if (SWe.P.BreitenTolYN=n) then
        Lib_GuiCom:Disable($edSWe.P.BreitenTol)
      else
        Lib_GuiCom:Enable($edSWe.P.BreitenTol);

    if (aName='') or (aName='cbSWe.P.LaengenTolYN') then
      if ("SWe.P.LängenTolYN"=n) then
        Lib_GuiCom:Disable($edSWe.P.LaengenTol)
      else
        Lib_GuiCom:Enable($edSWe.P.LaengenTol);
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
end;
begin

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  // Neuanlage?
  if (Mode=c_ModeNew) then begin

    if (aBehalten=n) then begin
      Erx # RecLink(621,620,1,_recLast);  // letzte Pos. holen
      if (Erx<=_rLocked) then vNr # SWe.P.Position + 1
      else vNr # 1;

      RecBufClear(621);
      SWe.P.Nummer          # SWe.Nummer;
      SWe.P.Position        # vNr;
      SWe.P.Eingangsnr      # 1;
      SWe.P.Lieferantennr   # SWe.Lieferant;
      SWe.P.MEH             # 'kg';
      SWe.P.Erzeuger        # SWe.Erzeuger;

      if (Set.Ein.Lieferadress=-1) then begin
        Erx # RecLink(100,620,2,_recfirst);   // Lieferant holen
        if (Erx<=_rLocked) then begin
          SWe.P.Lageradresse   # Adr.Nummer;
          SWe.P.Lageranschrift # Set.Ein.Lieferanschr;
        end;
        end
      else begin
        SWe.P.Lageradresse    # Set.Ein.Lieferadress;
        SWe.P.Lageranschrift  # Set.Ein.Lieferanschr;
      end;
      Erx # RecLink(100,621,8,_recFirst);    // Erzeuger holen
      if (Erx<=_rLocked) then
        SWe.P.Ursprungsland   # Adr.LKZ
      else
        SWe.P.Ursprungsland   # '';
      end

    else begin  // neu + Übernahme

      w_BinKopieVonDatei  # gFile;
      w_BinKopieVonRecID  # RecInfo(gFile, _recid);

      // Ausführungen kopieren...
      Erx # RecLink(622,621,10,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        SWe.P.AF.Position # SWe.P.Position + 1;
        RekInsert(622,0,'MAN');
        SWe.P.AF.Position # SWe.P.Position;
        RecRead(622,1,0);
        Erx # RecLink(622,621,10,_recNext);
      END;

      SWe.P.Position    # SWe.P.Position + 1;
      SWe.P.Materialnr  # 0;
      Refreshifm();;
    end;

  end;  //NEW

  // Focus setzen auf Feld:
  $cbSWe.P.AvisYN->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vStk    : int;
  vGew    : float;
  vMenge  : float;
  vlfd    : int;
  vNr     : int;
  
  v621  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if ((SWe.P.AvisYN=n) and (SWe.P.EingangYN=n) and (SWe.P.AusfallYN=n)) or
    ((SWe.P.Avis_Datum=0.0.0) and (SWe.P.Eingang_Datum=0.0.0) and (SWe.P.Ausfall_Datum=0.0.0)) then begin
    Msg(621001,'',0,0,0);
    $cbSWe.P.AvisYN->WinFocusSet(true);
    RETURN false;
  end;

  if ("SWe.P.Stückzahl"=0) then begin
    Msg(001200,Translate('Stückzahl'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Stueckzahl->WinFocusSet(true);
    RETURN false;
  end;
  if (SWe.P.Gewicht=0.0) then begin
    Msg(001200,Translate('Gewicht'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Gewicht->WinFocusSet(true);
    RETURN false;
  end;
  if ("SWe.P.Lageradresse"=0) then begin
    Msg(001200,Translate('Lageradresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Lageradresse->WinFocusSet(true);
    RETURN false;
  end;
  if (SWe.P.Lageranschrift=0) then begin
    Msg(001200,Translate('Lageranschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Lageranschrift->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(101,621,5,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lageradresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Lageradresse->WinFocusSet(true);
    RETURN false;
  end;


  if (SWE.P.Warengruppe=0) then begin
    Msg(001200,Translate('Warengruppe'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Warengruppe->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(819,621,3,_recFirst);   // Warengruppe holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Warengruppe'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Warengruppe->WinFocusSet(true);
    RETURN false;
  end;


  Erx # RecLink(100,621,8,_recFirst);    // Erzeuger holen
  if (Erx>_rLocked) then begin
    Msg(001201,Translate('Erzeuger'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Erzeuger->WinFocusSet(true);
    RETURN false;
  end;

  if (SWe.P.Ursprungsland='') then begin
    Msg(001200,Translate('Ursprungsland'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Ursprungsland->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(812,621,9,_recFirst);    // Land holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Ursprungsland'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.P.Ursprungsland->WinFocusSet(true);
    RETURN false;
  end;

  if (StrCnv(SWe.P.MEH,_Strupper)='STK') then begin
    SWe.P.Menge # cnvfi("SWe.P.Stückzahl");
  end;
  if (StrCnv(SWe.P.MEH,_Strupper)='KG') then begin
    SWe.P.Menge # SWe.P.Gewicht;
  end;

  // Ankerfunktion
  if (RunAFX('SWe.P.RecSave','')<>0) then begin
    if (AfxRes<>_rOk) then begin
      RETURN False;
    end;
  end;

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren

  // Einzelgewicht eingeben??
  if (Set.Ein.WE.proStkYN) and
    ("SWe.P.Stückzahl">1) and (SWe.P.Materialnr=0) then
    if (Msg(506014,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin

    // Eingabetabelle aufrufen...
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'SWe.P.Mat.Einzelgewichte',here+':AusEinzelgewichte',y);
    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN false;
  end;  // EINGELGEWICHTE


  if (Mode=c_ModeEdit) then begin   // Editieren

    // Aus AVIS->Eingang machen?
    if (ProtokollBuffer[621]->SWe.P.AvisYN) and (SWe.P.EingangYN) then begin

      vNr # SWe.P.Eingangsnr;

      PtD_Main:Forget(gFile);
      RecRead(gFile,1,_recUnlock | _recNoLoad);

      TRANSON;

      SWe.P.Anlage.User   # gUserName;
      REPEAT
        SWe.P.Eingangsnr # SWe.P.Eingangsnr + 1;
        SWe.P.Anlage.Datum  # Today;
        SWe.P.Anlage.Zeit   # Now;
        Erx # RekInsert(gFile,0,'MAN');
      UNTIl (erx=_rOK);

      if (SWe_P_Data:Verbuchen(y)=false) then begin
        TRANSBRK;
        SWe.P.Eingangsnr # vNr;
        RecRead(gFile,1,_recLock);
        PtD_Main:Memorize(gFile);

        Msg(506001,'',0,0,0);
        RETURN false;
      end;

      TRANSOFF;

      // Etikettendruck?
      if (Set.Ein.WE.Etikett<>0) then begin
        Erx # RecLink(200,621,6,_RecFirst);  // Material holen
        if (Erx<=_rLocked) then begin
          if (Set.Ein.WE.Etikett=999) then
            Mat_Etikett:Etikett(0,y,1)
          else
            Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1)
        end;
      end;

      
      // Avisierung erledigt?
      v621 # RecBufCreate(621);
      RecBufCopy(621,v621);
        
      v621->SWe.P.Eingangsnr # 1;
      Erx # RecRead(v621,1,0);
      if (Erx = _rOK) AND (v621->SWe.P.AvisYN) AND (v621->"SWe.P.Löschmarker" = '') then begin
        if (Msg(506025 ,'',_WinIcoQuestion,_WinDialogYesNo,0) = _WinIdYes) then begin
          Erx # RecRead(v621,1,_RecLock);
          if (Erx <> _rOK) then begin
            Msg(621005,'',0,0,0);
            RETURN false;
          end;

          v621->"SWe.P.Lösch.Grund" # 'ERLEDIGT';
          v621->"SWe.P.Lösch.Zeit"  # now;
          v621->"SWe.P.Lösch.Datum" # today;
          v621->"SWe.P.Lösch.User"  # gUserName;
          v621->"SWe.P.Löschmarker"   # '*';

          Erx # RekReplace(v621,_RecUnlock,'MAN');
          if (Erx <> _rOK) then
            Msg(621005,'',0,0,0);
        end;
      end;
      
      RecBufDestroy(v621);



      RETURN true;
    end;
    // Änderung an einem Eingang?
    if (SWe.P.EingangYN) and (SWe.P.Materialnr <> 0) then begin
      // Material Updaten
      if (SWe_P_Data:UpdateMaterial(true)=false) then begin
        TRANSBRK;
        Msg(506001,'',0,0,0);
        RETURN false;
      end;
    end;



    Erx # RekReplace(gFile,_RecUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    PtD_Main:Compare(gFile);

  end
  else begin                        // Neuanlage -------------------

    TRANSON;

    SWe.P.Anlage.User   # gUserName;
    SWe.P.Anlage.Datum  # Today;
    SWe.P.Anlage.Zeit   # Now;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;


    //ggf. Hier Material anlegen und Etikett drucken
    if (SWe.P.EingangYN) AND (!SWe.P.AvisYN) AND (!SWe.P.AusfallYN) then begin

      // Material anlegen
      if (SWe_P_Data:Verbuchen(true)=false) then begin
        TRANSBRK;
        Msg(506001,'',0,0,0);
        RETURN false;
      end;

      // Material Updaten
      if (SWe_P_Data:UpdateMaterial(true)=false) then begin
        TRANSBRK;
        Msg(506001,'',0,0,0);
        RETURN false;
      end;

      TRANSOFF;
      // Etikettendruck?
      if (Set.Ein.WE.Etikett<>0) then begin
        Erx # RecLink(200,621,6,_RecFirst);  // Material holen
        if (Erx<=_rLocked) then begin
          if (Set.Ein.WE.Etikett=999) then
            Mat_Etikett:Etikett(0,y,1)
          else
            Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1)
        end;
      end;
      end

    else begin
      TRANSOFF;
    end;


    if (Msg(000005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
      RecInit(y);
      RETURN false;
      end
    else begin
      gZLList->Winupdate(_winupdon, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      RETURN true;
    end;

  end;  // Neuanlage

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin

  // ST 2012-10-11: nur Löschen bei Abbruch neuanlage
  if (Mode = c_ModeEdit) OR (Mode = c_ModeEdit2) then
    RETURN true;

  // Ausführungen löschen
  WHILE (RecLink(622,621,10,_RecFirst)=_rOK) do begin
    RekDelete(622,0,'MAN');
  END;


  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx         : int;
  vOk         : logic;
  vAktCnt     : int;
  vGrund      : alpha;
  vLoeschmark : alpha;
end
begin

  // RETURN; // ST 2011-09-28: erst Löschbarmachen wenn Projekt 1161/366

  vLoeschmark # "SWe.P.Löschmarker";

  TRANSON;

  vOK # (SWe.P.Materialnr<>0);
  if (vOK) then begin  // Wenn kein Material da ist, dann auch kein Material löschen
    // Material ist noch nicht "angefasst" worden, dann Material und dann
    // den Eingang löschen

    Mat.Nummer # SWe.P.Materialnr;
    if (RecRead(200,1,_RecLock) <> _rOK) then begin
      TRANSBRK;
      Msg(621002,'',0,0,0);
      RETURN;
    end;

    if (SWe.P.EingangYN) AND (SWe.P.Materialnr<>0) then begin
      vAktCnt # RecLinkInfo(204,200,14,_RecCount);
      if (vAktCnt > 0) then
        vOK # false;
    end;

    if (vOK = false ) then begin
      TRANSBRK;
      // todo('Das Material zu diesem Einsatz enthält bereits Aktionen. Position kann nicht gelöscht werden.');
      Msg(621003,'',0,0,0);
      RETURN;
    end;

    if (vLoeschmark = '') then begin
      if (Dlg_Standard:Standard(Translate('Grund'),var vGrund,n,32)=false) then begin
        TRANSBRK;
        RETURN;
      end;
      vLoeschmark # '*';
    end else begin
      vLoeschmark # '';
    end;


    // Material löschen
    Mat_Data:SetLoeschmarker(vLoeschmark);
    if (vLoeschmark='*') then   // Neu: 16.09.2013 AH
      Mat.Ausgangsdatum # today
    else
      Mat.Ausgangsdatum # 0.0.0;
    Erx # Mat_Data:Replace(0,'MAN');
    if (Erx <> _rOK) then begin
      TRANSBRK;
      //todo('Das Material zu diesem Einsatz konnte nicht gelöscht werden. Position kann nicht gelöscht werden.');
      Msg(621004,'',0,0,0);
      RETURN;
    end;

  end;

  // SWE Pos Löschmarker setzen

  Erx # RecRead(621,1,_RecLock);
  if (Erx <> _rOK) then begin
    TRANSBRK;
    // todo('Die Position konnte nicht gelöscht werden.');
    Msg(621005,'',0,0,0);
    RETURN;
  end;

  if (vLoeschmark = '*') then begin
    "SWe.P.Lösch.Grund" # vGrund;
    "SWe.P.Lösch.Zeit"  # now;
    "SWe.P.Lösch.Datum" # today;
    "SWe.P.Lösch.User"  # gUserName;
  end else begin
    "SWe.P.Lösch.Grund" # '';
    "SWe.P.Lösch.Zeit"  # 0:0:0;
    "SWe.P.Lösch.Datum" # 00.00.0000;
    "SWe.P.Lösch.User"  # '';
  end;
  "SWe.P.Löschmarker"   # vLoeschmark;

  Erx # RekReplace(621,_RecUnlock,'MAN');
  if (Erx <> _rOK) then begin
    TRANSBRK;
    // todo('Die Position konnte nicht gelöscht werden.');
    Msg(621005,'',0,0,0);
    RETURN;
  end;

  TRANSOFF;
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin

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
  Erx : int;
end;
begin

  if ((aEvt:Obj->wpname='edSWe.P.Verwiegungsart') and ($edSWe.P.Verwiegungsart->wpchanged)) or
    (aEvt:Obj->wpname='edSWe.P.Gewicht') and ($edSWe.P.Gewicht->wpchanged) then begin
    Erx # RecLink(818,621,11,_RecFirst);    // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then begin
      if (VWa.NettoYN) then begin
        SWe.P.Gewicht.Brutto # SWe.P.Gewicht;
        SWe.P.Gewicht.Netto # SWe.P.Gewicht;
        $edSWe.P.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
        $edSWe.P.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
        Lib_GuiCom:Disable($edSWe.P.Gewicht.Netto);
        Lib_GuiCom:Enable($edSWe.P.Gewicht.Brutto);
        if (aFocusObject->wpname='edSWe.P.Gewicht.Netto') then begin
          $edSWe.P.Gewicht.Brutto->winfocusset(false);
        end;
        end
      else if (VWa.BruttoYN) then begin
        SWe.P.Gewicht.Brutto # SWe.P.Gewicht;
        SWe.P.Gewicht.Netto # SWe.P.Gewicht;
        $edSWe.P.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
        $edSWe.P.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
        Lib_GuiCom:Disable($edSWe.P.Gewicht.Brutto);
        Lib_GuiCom:Enable($edSWe.P.Gewicht.Netto);
        if (aFocusObject->wpname='edSWe.P.Gewicht.Brutto') then begin
          $edSWe.P.Gewicht.Netto->winfocusset(false);
        end;
        end
      else begin
        Lib_GuiCom:Enable($edSWe.P.Gewicht.Netto);
        Lib_GuiCom:Enable($edSWe.P.Gewicht.Brutto);
        if (aEvt:Obj->wpname='edSWe.P.Gewicht') then begin
          SWe.P.Gewicht.Brutto # SWe.P.Gewicht;
          SWe.P.Gewicht.Netto # SWe.P.Gewicht;
          $edSWe.P.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
          $edSWe.P.Gewicht.Brutto->winupdate(_WinUpdFld2Obj);
        end;

        if (aFocusObject->wpname='edSWe.P.Gewicht.Brutto') then
          $edSWe.P.Gewicht.Netto->winfocusset(false);
/*
        Lib_GuiCom:Enable($edSWe.P.Gewicht.Netto);
        Lib_GuiCom:Enable($edSWe.P.Gewicht.Brutto);
        if (aFocusObject->wpname='edSWe.P.Gewicht.Brutto') then
          $edSWe.P.Gewicht.Netto->winfocusset(false);
*/
      end;
    end;
//    else begin
//      Lib_GuiCom:Enable($edSWe.P.Gewicht.Netto);
//      Lib_GuiCom:Enable($edSWe.P.Gewicht.Brutto);
//    end;
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
  Erx     : int;
  vA      : alpha;
  vFilter : int;
  vQ      : alpha(4000);
  vTmp    : int;
  vHdl    : int;
end;
begin

  case aBereich of

    'Analyse' : begin
      // 20.09.2018 AH: DIN holen?
      MQU_Data:Read("SWe.P.Güte", "SWe.P.Gütenstufe", y, Swe.P.Dicke);
      RecBufClear(230);
      if (Set.LyseErweitertYN) then
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lys.K.Verwaltung2',here+':AusAnalyse')
      else
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lys.K.Verwaltung',here+':AusAnalyse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AusfOben' : begin
      vFilter # RecFilterCreate(622,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, SWe.P.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, SWe.P.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, SWe.P.Eingangsnr);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, '1');
      vTmp # RecLinkInfo(622,621,10,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfOben');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end
      RecBufClear(622);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'SWe.P.AF.Verwaltung',here+':AusAFOben');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(622,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, SWe.P.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, SWe.P.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, SWe.P.Eingangsnr);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, '1');
      gZLList->wpDbFilter # vFilter;
      vTMP # winsearch(gMDI, 'NB.Main');
      vTMP->wpcustom # '1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AusfUnten' : begin
      vFilter # RecFilterCreate(622,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, SWe.P.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, SWe.P.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, SWe.P.Eingangsnr);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, '2');
      vTmp # RecLinkInfo(622,621,10,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfUnten');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end
      RecBufClear(622);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'SWe.P.AF.Verwaltung',here+':AusAFUnten');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(622,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, SWe.P.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, SWe.P.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, SWe.P.Eingangsnr);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, '2');
      gZLList->wpDbFilter # vFilter;
      vTMP # winsearch(gMDI, 'NB.Main');
      vTMP->wpcustom # '2';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageranschrift' : begin
      //RecLink(100,621,5,0);     // Lageradresse holen
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
/*
      if (Msg(220001,'',0,_WinDialogYesNo,1)=_WinIdYes) then begin
        vSelName # Sel_Build(vSel2, 220, 'INTRASTAT_BESTELLUNG',y,0);
        RecBufClear(220);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        gZLList->wpDbSelection # vSel2;
        w_SelName # vSelName;
        end
      else begin
*/
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
//      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lagerplatz' : begin
      RecBufClear(844);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',here+':AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kommission' : begin
    end;


    'Warengruppe' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikel' : begin
      RecBufClear(250);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
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
      MQu.S.Stufe # "SWe.P.Gütenstufe";
      if (MQu.S.Stufe<>'') then begin
        vQ # ' MQu.NurStufe = '''+MQu.S.Stufe+''' OR MQu.NurStufe = '''' ';
        Lib_Sel:QRecList(0, vQ);
      end;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guetenstufe' : begin
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
      vQ # ' ULa.Typ=0 OR ULa.Typ=2';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

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
    SWe.P.Analysenummer # Lys.K.Analysenr;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edSWE.P.Analysenr->Winfocusset(false);
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

    RecBufClear(622);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'SWe.P.AF.Verwaltung',here+':AusAFOben');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(622,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, SWe.P.Nummer);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, SWe.P.Position);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, SWe.P.Eingangsnr);
    vFilter->RecFilterAdd(4,_FltAND,_FltEq, '1');
    gZLList->wpDbFilter # vFilter;
    vTMP # winsearch(gMDI, 'NB.Main');
    vTMP->wpcustom # '1';

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

    RecBufClear(622);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'SWe.P.AF.Verwaltung',here+':AusAFUnten');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(622,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, SWe.P.Nummer);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, SWe.P.Position);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, SWe.P.Eingangsnr);
    vFilter->RecFilterAdd(4,_FltAND,_FltEq, '2');
    gZLList->wpDbFilter # vFilter;
    vTMP # winsearch(gMDI, 'NB.Main');
    vTMP->wpcustom # '2';

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
//  AusLageradresse
//
//========================================================================
sub AusLageradresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    SWe.P.Lageradresse # Adr.Nummer;
    SWe.P.Lageranschrift # 1;
    gSelected # 0;
  end;
  // Focus setzen:
  $edSWe.P.Lageradresse->Winfocusset(false);
  RefreshIfm('edSWe.P.Lageranschrift');
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
    SWe.P.Lageranschrift # Adr.A.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edSWe.P.Lageranschrift->Winfocusset(false);
end;


//========================================================================
//  AusLagerplatz
//
//========================================================================
sub AusLagerplatz()
begin
  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    SWe.P.Lagerplatz # Lpl.Lagerplatz;
    SWe.P.Lageranschrift # 1;
    // Feldübernahme
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.P.Lagerplatz->Winfocusset(false);
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
      "SWe.P.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "SWe.P.Güte" # "MQu.Güte1"
    else
      "SWe.P.Güte" # "MQu.Güte2";
    gSelected # 0;
  end;
  // Focus setzen:
  $edSWe.P.Guete->Winfocusset(false);
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
    "SWe.P.Gütenstufe" # MQu.S.Stufe;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.P.Guetenstufe->Winfocusset(false);
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
    SWe.P.Warengruppe # Wgr.Nummer;
  end;
  // Focus setzen:
  $edSWe.P.Warengruppe->Winfocusset(false);
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
    SWe.P.Artikelnr   # Art.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edSWe.P.Artikelnr->Winfocusset(false);
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
    SWe.P.Intrastatnr # MSL.Intrastatnr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.P.Intrastatnr->Winfocusset(false);
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
    SWe.P.Erzeuger      # Adr.Nummer;
    SWe.P.Ursprungsland # Adr.LKZ;
    $edSWe.P.Ursprungsland->winupdate(_WinUpdFld2Obj);
    gSelected # 0;
  end;
  // Focus setzen:
  $edSWe.P.Erzeuger->Winfocusset(false);
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
    SWe.P.Ursprungsland # "Lnd.Kürzel";
    gSelected # 0;
  end;
  // Focus setzen:
  $edSWe.P.Ursprungsland->Winfocusset(false);
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
    SWe.P.Verwiegungsart # VwA.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.P.Verwiegungsart->Winfocusset(false);
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
    SWe.P.Zwischenlage # ULa.Bezeichnung;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.P.Zwischenlage->Winfocusset(false);
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
    SWe.P.Unterlage # ULa.Bezeichnung;
    "SWe.P.StapelhöhenAbz" # "ULa.Höhenabzug";
    $edSWe.P.StapelhoehenAbz->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edSWe.P.Unterlage->Winfocusset(false);
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
    SWe.P.Umverpackung # ULa.Bezeichnung;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.P.Umverpackung->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
begin
  gSelected # 0;
  SWe.P.AusfOben # Obf_Data:BildeAFString(621,'1');
  // Focus auf Editfeld setzen:
  $edSWe.P.AusfOben->Winfocusset(true);
end;


//========================================================================
//  AusAFUnten
//
//========================================================================
sub AusAFUnten()
begin
  gSelected # 0;
  SWe.P.AusfUnten # Obf_Data:BildeAFString(621,'2');
  // Focus auf Editfeld setzen:
  $edSWe.P.AusfUnten->Winfocusset(true);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl        : int;
  vOK         : logic;
end
begin


  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SWe_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SWe_Anlegen]=n);


  vOK # y;//(SWe.P.Materialnr=0);
  // ST 2011-08-23: Auch Eingänge können geändert werden, insofern noch nichts
  //                auf dem Material passiert ist.
  if (SWe.P.EingangYN) AND (SWe.P.Materialnr<>0) then begin
    Mat.Nummer # SWe.P.Materialnr;
    if (RecRead(200,1,0) = _rOK) then begin
      vOK # (RecLinkInfo(204,200,14,_RecCount) = 0);
      end
    else begin
      vOK # false;
    end;
  end;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or (w_Auswahlmode) or (Rechte[Rgt_SWe_Aendern]=n) or (!vOK) or ("SWe.P.Löschmarker"='*');
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_modeView)) or (w_Auswahlmode) or (Rechte[Rgt_SWe_Aendern]=n) or (!vOK) or ("SWe.P.Löschmarker"='*');
  // ST 2011-09-28: Eingänge können gelöscht werden, insofern noch nichts
  //                auf dem Material passiert ist.

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_modeEdit) or (w_Auswahlmode) or (Rechte[Rgt_SWe_Loeschen]=n) or (!vOK);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_modeEdit) or (w_Auswahlmode) or (Rechte[Rgt_SWe_Loeschen]=n) or (!vOK);

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
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,SWe.P.Anlage.Datum, SWe.P.Anlage.Zeit, SWe.P.Anlage.User, "SWe.P.LÖsch.Datum", "SWe.P.LÖsch.Zeit", "SWe.P.LÖsch.User", "SWe.P.LÖsch.Grund");
    end;


    'Mnu.Mark.Sel' : begin
      // Serienmarkierung; Selektionsdialog [04.11.2010/PW]
      Gv.Int.10   # 0;     // Warengruppe
      Gv.Logic.01 # false; // Avisiert
      Gv.Logic.02 # false; // Eingang
      Gv.Datum.01 # 0.0.0; // Datum von
      Gv.Datum.02 # today; // Datum bis

      gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.Mark.SWeP', here + ':AusSerienMark' );
      Lib_GuiCom:RunChildWindow( gMDI );
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
    if (SWe.P.Analysenummer<>0) then begin
      Lys.K.AnalyseNr # SWe.P.AnalyseNummer;
      if (Set.LyseErweitertYN) then
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lys.K.Verwaltung2','',true);
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
    'bt.Adresse'        : Auswahl('Lageradresse');
    'bt.Anschrift'      : Auswahl('Lageranschrift');
    'bt.Lagerplatz'     : Auswahl('Lagerplatz');
    'bt.Kommission'     : Auswahl('Kommission');
    'bt.Guete'          : Auswahl('Guete');
    'bt.Guetenstufe'    : Auswahl('Guetenstufe');
    'bt.Warengruppe'    : Auswahl('Warengruppe');
    'bt.Artikel'        : Auswahl('Artikel');
    'bt.Intrastat'      : Auswahl('Intrastat');
    'bt.Erzeuger'       : Auswahl('Erzeuger');
    'bt.Land'           : Auswahl('Land');
    'bt.Verwiegungsart' : Auswahl('Verwiegungsart');
    'bt.Zwischenlage'   : Auswahl('Zwischenlage');
    'bt.Unterlage'      : Auswahl('Unterlage');
    'bt.Umverpackung'   : Auswahl('Umverpackung');
    'bt.AusfOben'       : Auswahl('AusfOben');
    'bt.AusfUnten'      : Auswahl('AusfUnten');
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

  if (aEvt:Obj->wpname='cbSWe.P.AvisYN') and (SWe.P.AvisYN) then begin
    SWe.P.EingangYN # n;
    SWe.P.AusfallYN # n;
    SWe.P.Avis_Datum # today;
    $cbSWe.P.EingangYN->winupdate(_WinUpdFld2Obj);
    $cbSWe.P.AusfallYN->winupdate(_WinUpdFld2Obj);
    $edSWe.P.Avis.Datum->winupdate(_WinUpdFld2Obj);

    App_Main:EvtFocusTerm(aEvt, $edSWe.P.Lageradresse);
    $edSWe.P.Lageradresse->winfocusset();
  end;

  if (aEvt:Obj->wpname='cbSWe.P.EingangYN') and (SWe.P.EingangYN) then begin
    SWe.P.AvisYN # n;
    SWe.P.AusfallYN # n;
    SWe.P.Eingang_Datum # today;
    $cbSWe.P.AvisYN->winupdate(_WinUpdFld2Obj);
    $cbSWe.P.AusfallYN->winupdate(_WinUpdFld2Obj);
    $edSWe.P.Eingang.Datum->winupdate(_WinUpdFld2Obj);

    App_Main:EvtFocusTerm(aEvt, $edSWe.P.Lageradresse);
    $edSWe.P.Lageradresse->winfocusset();
  end;

  if (aEvt:Obj->wpname='cbSWe.P.AusfallYN') and (SWe.P.AusfallYN) then begin
    SWe.P.EingangYN # n;
    SWe.P.AvisYN # n;
    SWe.P.Ausfall_Datum # today;
    $cbSWe.P.EingangYN->winupdate(_WinUpdFld2Obj);
    $cbSWe.P.AvisYN->winupdate(_WinUpdFld2Obj);
    $edSWe.P.Ausfall.Datum->winupdate(_WinUpdFld2Obj);

    App_Main:EvtFocusTerm(aEvt, $edSWe.P.Lageradresse);
    $edSWe.P.Lageradresse->winfocusset();
  end;

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
  SWe.P.AF.Bezeichnung # StrCut(SWe.P.AF.Bezeichnung + ':'+SWe.P.AF.Zusatz, 1, 32);
  RETURN SWe.P.AF.Seite='1';
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
  SWe.P.AF.Bezeichnung # StrCut(SWe.P.AF.Bezeichnung + ':'+SWe.P.AF.Zusatz, 1, 32);
  RETURN SWe.P.AF.Seite='2';
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
  // Sonderfunktion:
  if (aMark) then begin
    if (RunAFX('SWe.P.EvtLstDataInit','y')<0) then RETURN;
  end
    else if (RunAFX('SWe.P.EvtLstDataInit','n')<0) then RETURN;

  if (aMark=n) then begin
    if ("SWe.P.Löschmarker" = '*') then
        Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
    else if (SWe.P.AvisYN) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Bestellt)
    else if (SWe.P.AusfallYN) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Gesperrt);

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
//  AusSerienMark [04.11.2010/PW]
//
//========================================================================
sub AusSerienMark ()
local begin
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vSelQ     : alpha(500);
  vListHdl  : handle;
end;
begin
  vListHdl # gZlList;
  vListHdl->wpDisabled # false;
  Lib_GuiCom:SetWindowState( gMDI, true );

  /* Selektion */
  Lib_Sel:QInt( var vSelQ, 'SWe.P.Nummer', '=', SWe.Nummer );
  if ( GV.Int.10 != 0 ) then // Warengruppe
    Lib_Sel:QInt( var vSelQ, 'SWe.P.Warengruppe', '=', GV.Int.10 );
  if ( Gv.Logic.01 ) then begin // Avisiert
    Lib_Sel:QLogic( var vSelQ, 'SWe.P.AvisYN', true );
    if ( Gv.Datum.01 != 0.0.0 ) or ( Gv.Datum.02 != 0.0.0 ) then
      Lib_Sel:QVonBisD( var vSelQ, 'SWe.P.Avis_Datum', GV.Datum.01, GV.Datum.02 );
  end;
  if ( Gv.Logic.02 ) then begin // Eingang
    Lib_Sel:QLogic( var vSelQ, 'SWe.P.EingangYN', true );
    if ( Gv.Datum.01 != 0.0.0 ) or ( Gv.Datum.02 != 0.0.0 ) then
      Lib_Sel:QVonBisD( var vSelQ, 'SWe.P.Eingang_Datum', GV.Datum.01, GV.Datum.02 );
  end;

  // Selektion durchführen
  vSel # SelCreate( 621, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  // Ergebnisse markieren
  FOR  Erx # RecRead( 621, vSel, _recFirst );
  LOOP Erx # RecRead( 621, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    Lib_Mark:MarkAdd( 621, true, true );
  END;

  // Selektion entfernen
  SelClose( vSel );
  SelDelete( 621, vSelName );

  vListHdl->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect );
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vQ    :  alpha(1000);
end
begin

  if ((aName =^ 'edSWe.P.Verwiegungsart') AND (aBuf->SWe.P.Verwiegungsart<>0)) then begin
    RekLink(818,621,11,0);   // Verweigungsart holen
    Lib_Guicom2:JumpToWindow('VwA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Guetenstufe') AND (aBuf->"SWe.P.Gütenstufe"<>'')) then begin
    MQu.S.Stufe # "SWe.P.Gütenstufe";
    RecRead(848,1,0);
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Guete') AND (aBuf->"SWe.P.Güte"<>'')) then begin
    "MQu.Güte1" # "SWe.P.Güte";
    RecRead(832,2,0);
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Artikelnr') AND (aBuf->SWe.P.Artikelnr<>'')) then begin
    Art.Nummer # SWe.P.Artikelnr;
    RecRead(250,1,0);
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Lageradresse') AND (aBuf->SWe.P.Lageradresse<>0)) then begin
    RekLink(100,621,4,0);   // Lageradresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Lageranschrift') AND (aBuf->SWe.P.Lageranschrift<>0)) then begin
    RekLink(101,621,5,0);   // Anschrift holen
    Adr.A.Adressnr # SWe.P.Lageradresse;
    Adr.A.Nummer # SWe.P.Lageranschrift;
    RecRead(101,1,0);
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', SWe.P.Lageradresse);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung',vQ);
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Lagerplatz') AND (aBuf->SWe.P.Lagerplatz<>'')) then begin
    LPl.Lagerplatz # SWe.P.Lagerplatz;
    RecRead(844,1,0);
    Lib_Guicom2:JumpToWindow('LPl.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Intrastatnr') AND (aBuf->SWe.P.Intrastatnr<>'')) then begin
    MSL.Intrastatnr # SWe.P.Intrastatnr;
    RecRead(220,2,0);
    Lib_Guicom2:JumpToWindow('MSL.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Warengruppe') AND (aBuf->SWe.P.Warengruppe<>0)) then begin
    RekLink(819,621,3,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Erzeuger') AND (aBuf->SWe.P.Erzeuger<>0)) then begin
    RekLink(100,621,8,0);   // Erzeuger holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Ursprungsland') AND (aBuf->SWe.P.Ursprungsland<>'')) then begin
    RekLink(812,621,9,0);   // Ursprungsland holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Zwischenlage') AND (aBuf->SWe.P.Zwischenlage<>'')) then begin
    ULa.Bezeichnung # SWe.P.Zwischenlage;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Unterlage') AND (aBuf->SWe.P.Unterlage<>'')) then begin
    ULa.Bezeichnung # SWe.P.Unterlage;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.P.Umverpackung') AND (aBuf->SWe.P.Umverpackung<>'')) then begin
    ULa.Bezeichnung # SWe.P.Umverpackung;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
 
end;
//========================================================================
//========================================================================
//========================================================================
//========================================================================