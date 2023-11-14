@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_P_Main
//                      OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  13.03.2009  TM  Intrastat-Auswahl wahlweise selektiert oder komplett
//  08.04.2009  TM  Anzeige der Reservierungen auf Bestellkarte (Info->Reservierungen)
//  27.07.2009  ST  Fehlerkorrektur: Positionsanlage sperrte RID und RAD
//  03.09.2009  MS  Beim Anhängen einer Abrufpos ist das Feld Abruf-Best.Nr. nun verfuegbar
//  24.11.2009  MS  Nach der Auswahl der Lieferadresse poppt bei Anschriften > 1 das Anschriftsfenster auf
//  22.06.2010  AI  Abrufsnummer Pflichtfeld
//  04.01.2011  TM  SUB AusLiefMatArtNr: Preisübernahme aus "Kunden"artikel wenn Bestellung in Hauswährung
//  07.03.2012  ST  Anker für DataListInit hinzugefügt
//  22.03.2012  AI  NEU: Adr-VPG mit Erzeuger
//  25.04.2012  MS  Protokollrecht hinzugefuegt
//  21.06.2012  AI  Projekt 1337/151 ALLE Materialien updaten
//  05.07.2012  TM  Korrektur MEH als Pflichtfeld
//  25.09.2012  AI  Kommissionsänderungen im "RefreshIfm" testen
//  22.10.2012  AI  Temporäre Warnmeldung für Einzelpreis = 0 (Projekt 1337/176)
//  21.01.2013  AI  RekSave replaced beim Finalem Speichern die 401 und hält sie locked
//  22.05.2013  AI  beim Kommissionsänderung Maske switchen anhand Dateinr. (aber nicht bei ArtMatMix zu Mat)
//  16.10.2013  AH  Anfragen
//  21.10.2013  ST  Ändern der Artikelnummer auch ohne vorheriger Artikelnummer möglich
//  10.02.2015  AH  Bug: MatMix: Mengen aus Kommission
//  21.05.2015  AH  ZL.Erfassung nur refreshen, wenn mind. ein Pos.Satz existiert
//  18.09.2015  ST  Erweiterung "Sub Start"
//  23.02.2016  AH  Erweiterung Artikelmaske
//  21.03.2016  AH  Lohnanfrage
//  07.04.2016  AH  Neu: "AusMaterial"
//  08.06.2016  AH  neues Feld "Güte" bei Artikel
//  14.07.2016  AH  Kopfrabatte werden mit in Position gerechnet
//  19.10.2016  AH  Pos-Vorbelegung übernimmt AB.Nummer
//  19.10.2016  AH  Rahmenübernahme übernimmt AB.Nummer nicht
//  28.10.2016  ST  Serienänderung für Markierte Sätze aktiviert
//  18.05.2017  ST  Customfelderaufruf hinzugefügt
//  26.01.2018  AH  AnalyseErweitert
//  30.05.2018  AH  Speichern zeigt ggf. Warnmeldungen
//  26.11.2018  AH  AFX "Ein.P.Auswahl.Pre"
//  26.07.2019  AH  Fix: Statistikverbuchung
//  31.07.2019  AH  Neu: Verpackung aus Bestellpos. erzeugbar
//  06.12.2019  AH  Fix: Wenn Artikeltyp 209 aber nicht KG
//  09.02.2021  AH  Neu: VorlageAuf
//  24.02.2022  AH  Art.Ausführungen
//  03.05.2022  MR  Änderung des Vorgangstypen führt zu Fehlern (2228/67)
//  10.05.2022  AH  ERX
//  23.05.2022  TM  Sicherheitsabfrage vor Wandlung in Liefervertrag
//  21.07.2022  HA  Quick Jump
//  2023-01-03  ST  "Import ausExcel" ausgebaut
//  2023-01-24  AH  Kalkulationen in Hauswährung; Rückstelungen kommen in Mat.Aktionen als KOSTEN
//  2023-02-07  AH  Ein.Verband
//  2023-08-14  AH  "LiB.SperreNeuYN"
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Skizzendaten();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit(opt aBehalten : logic; opt aMitAufp : logic; opt aMitKalk : logic)
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic;
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusEinzelObfOben()
//    SUB AusEinzelObfUnten()
//    SUB AusEingaenge()
//    SUB AusReserv()
//    SUB AusLieferant()
//    SUB AusLieferadresse()
//    SUB AusLieferanschrift()
//    SUB AusVerbraucher()
//    SUB AusRechnungsempf()
//    SUB AusAnsprechpartner()
//    SUB AusBDS()
//    SUB AusLand()
//    SUB AusWaehrung()
//    SUB AusLieferbed()
//    SUB AusZahlungsbed()
//    SUB AusVersandart()
//    SUB AusSteuerschluessel()
//    SUB AusSachbearbeiter()
//    SUB AusVerband
//    SUB AusAuftragsArt()
//    SUB AusText2();
//    SUB AusVerpackung();
//    SUB AusKopftext();
//    SUB AusFusstext();
//    SUB AusKopftextAdd();
//    SUB AusFusstextAdd();
//    SUB AusTextAdd();
//    SUB AusWarengruppe()
//    SUB AusKommission()
//    SUB AusGuete()
//    SUB AusGuetenstufe()
//    SUB AusAFOben()
//    SUB AusAFUnten()
//    SUB AusArtNr()
//    SUB AusArtNr_Mat()
//    SUB AusStruktur()
//    SUB AusLiefArtNr()
//    SUB AusProjekt()
//    SUB AusIntrastat()
//    SUB AusKostenstelle()
//    SUB AusZeugnis()
//    SUB AusErzeuger()
//    SUB AusVerwiegungsart()
//    SUB AusZwischenlage()
//    SUB AusUnterlage()
//    SUB AusUmverpackung()
//    SUB AusEtikettentyp()
//    SUB AusEtikettentyp2()
//    SUB AusSkizze()
//    SUB AusKopfaufpreise()
//    SUB AusAufpreise()
//    SUB AusKalkulation()
//    SUB AusAbruf()
//    SUB AusPreis()
//    SUB AusMaterial()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EinPTextSave()
//    SUB EinPTextRead()
//    SUB AFObenRecCtrl(aEvt : event; aRecId : int) : logic;
//    SUB AFUntenRecCtrl(aEvt : event; aRecId : int) : logic;
//    SUB Pflichtfelder();
//    sub EvtTimer...
//    sub EvtPosChanged ( aEvt : event; aRect : rect; aClientSize : point; aFlags : int ) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle :    'Bestellpositionen'
  cFile :     501
  cMenuName : 'Ein.P.Bearbeiten'
  cPrefix :   'Ein_P'
  cZList :    'ZL.EKPositionen'
  cKey :      1


  cDialog     : 'Ein.P.Verwaltung'
  cRecht      : Rgt_Einkauf
  cMdiVar     : gMDIEin

end;

declare EinPTextRead();
declare EinPTextSave();
declare Pflichtfelder();
declare RefreshMode(opt aNoRefresh : logic);
declare AusMaterial()


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aNr     : int;
  opt aPos    : int;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end;
begin
  if (aRecId=0) and (aNr<>0)and (aPos<>0) then begin
    Ein.P.Nummer    # aNr;
    Ein.P.Position  # aPos;
    Erx # RecRead(501,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(501,_recID);
  end;

  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView);
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vTmp  : int;
  vPar  : int;
  vHdl  : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # winsearch(aEvt:Obj,cZList); // cZList;
  gKey      # cKey;

  vTmp # Winsearch(aEvt:Obj, 'ZL.Erfassung');
  Lib_GuiCom:RecallList(vTmp,'EIN.');


  if (Set.Ein.AnfragenYN=false) then begin
    $edEin.Vorgangstyp->wpcustom # '_N';
    $bt.Vorgangstyp->wpcustom # '_N';
  end;


  // Chemietitel ggf. setzen
  if (Set.Chemie.Titel.C<>'') then begin
    $lbEin.P.Chemie.C1->wpcaption # Set.Chemie.Titel.C;
  end;
  if (Set.Chemie.Titel.Si<>'') then begin
    $lbEin.P.Chemie.Si1->wpcaption # Set.Chemie.Titel.Si;
  end;
  if (Set.Chemie.Titel.Mn<>'') then begin
    $lbEin.P.Chemie.Mn1->wpcaption # Set.Chemie.Titel.Mn;
  end;
  if (Set.Chemie.Titel.P<>'') then begin
    $lbEin.P.Chemie.P1->wpcaption # Set.Chemie.Titel.P;
  end;
  if (Set.Chemie.Titel.S<>'') then begin
    $lbEin.P.Chemie.S1->wpcaption # Set.Chemie.Titel.S;
  end;
  if (Set.Chemie.Titel.Al<>'') then begin
    $lbEin.P.Chemie.Al1->wpcaption # Set.Chemie.Titel.Al;
  end;
  if (Set.Chemie.Titel.Cr<>'') then begin
    $lbEin.P.Chemie.Cr1->wpcaption # Set.Chemie.Titel.Cr;
  end;
  if (Set.Chemie.Titel.V<>'') then begin
    $lbEin.P.Chemie.V1->wpcaption # Set.Chemie.Titel.V;
  end;
  if (Set.Chemie.Titel.Nb<>'') then begin
    $lbEin.P.Chemie.Nb1->wpcaption # Set.Chemie.Titel.Nb;
  end;
  if (Set.Chemie.Titel.Ti<>'') then begin
    $lbEin.P.Chemie.Ti1->wpcaption # Set.Chemie.Titel.Ti;
  end;
  if (Set.Chemie.Titel.N<>'') then begin
    $lbEin.P.Chemie.N1->wpcaption # Set.Chemie.Titel.N;
  end;
  if (Set.Chemie.Titel.Cu<>'') then begin
    $lbEin.P.Chemie.Cu1->wpcaption # Set.Chemie.Titel.Cu;
  end;
  if (Set.Chemie.Titel.Ni<>'') then begin
    $lbEin.P.Chemie.Ni1->wpcaption # Set.Chemie.Titel.Ni;
  end;
  if (Set.Chemie.Titel.Mo<>'') then begin
    $lbEin.P.Chemie.Mo1->wpcaption # Set.Chemie.Titel.Mo;
  end;
  if (Set.Chemie.Titel.B<>'') then begin
    $lbEin.P.Chemie.B1->wpcaption # Set.Chemie.Titel.B;
  end;
  if (Set.Chemie.Titel.1<>'') then begin
    $lbEin.P.Chemie.Frei1.1->wpcaption # Set.Chemie.Titel.1;
  end;
  if ("Set.Mech.Titel.Härte"<>'') then begin
    $lbEin.P.Haerte1->wpcaption # "Set.Mech.Titel.Härte";
  end;
  if ("Set.Mech.Titel.Körn"<>'') then begin
    $lbEin.P.Koernung1->wpcaption # "Set.Mech.Titel.Körn";
  end;
  if ("Set.Mech.Titel.Sonst"<>'') then begin
    $lbEin.P.Mech.Sonstig1->wpcaption # "Set.Mech.Titel.Sonst";
  end;
  if ("Set.Mech.Titel.Rau1"<>'') then begin
    $lbEin.P.RauigkeitA1->wpcaption # "Set.Mech.Titel.Rau1";
  end;
  if ("Set.Mech.Titel.Rau2"<>'') then begin
    $lbEin.P.RauigkeitB1->wpcaption # "Set.Mech.Titel.Rau2";
  end;

  // Verpackungstitel setzen
  if(Set.Vpg1.Titel <> '') then
    $lbEin.P.VpgText1 -> wpcaption  # Set.Vpg1.Titel;
  if(Set.Vpg2.Titel <> '') then
    $lbEin.P.VpgText2 -> wpcaption  # Set.Vpg2.Titel;
  if(Set.Vpg3.Titel <> '') then
    $lbEin.P.VpgText3 -> wpcaption  # Set.Vpg3.Titel;
  if(Set.Vpg4.Titel <> '') then
    $lbEin.P.VpgText4 -> wpcaption  # Set.Vpg4.Titel;
  if(Set.Vpg5.Titel <> '') then
    $lbEin.P.VpgText5 -> wpcaption  # Set.Vpg5.Titel;
  if(Set.Vpg6.Titel <> '') then
    $lbEin.P.VpgText6 -> wpcaption  # Set.Vpg6.Titel;

  if (Set.Mech.Dehnung.Wie=1) then
    $edEin.P.DehnungA2->wpcustom # '_N';
  if (Set.Mech.Dehnung.Wie=2) then
    $edEin.P.DehnungB2->wpcustom # '_N';
//  if (Mode=c_ModeList) then
//    cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

  // Feldberechtigungen...
  if (Rechte[Rgt_Ein_Preise]) then begin
    $clmGV.Num.01->wpvisible # true;   // Restwert
    $clmEin.P.Grundpreis->wpvisible # true;
    $edEin.P.Kalkuliert->wpvisible # true;
    $edEin.P.Grundpreis->wpvisible # true;
    $lb.Aufpreise->wpvisible # true;
    $lb.P.Einzelpreis->wpvisible # true;
    $edEin.P.Kalkuliert_Mat->wpvisible # true;
    $edEin.P.Grundpreis_Mat->wpvisible # true;
    $lb.Aufpreise_Mat->wpvisible # true;
    $lb.P.Einzelpreis_Mat->wpvisible # true;
    $lb.Poswert_Mat->wpvisible # true;
    $clmEin.P.Grundpreisx->wpvisible # true;
  end;
  if (Rechte[Rgt_Ein_P_PEH_Edit]=false) then begin
    $edEin.P.PEH->wpcustom # '_N';
    $edEin.P.Preis.MEH->wpcustom # '_N';
    $bt.PreisMEH->wpcustom # '_N';
    $edEin.P.PEH_Mat->wpcustom # '_N';
    $edEin.P.Preis.MEH_Mat->wpcustom # '_N';
    $bt.PreisMEH_Mat->wpcustom # '_N';
  end;
  
  
  Lib_Guicom2:Underline($edEin.Vorgangstyp);
  Lib_Guicom2:Underline($edEin.Lieferantennr);
  Lib_Guicom2:Underline($edEin.Lieferadresse);
  Lib_Guicom2:Underline($edEin.Lieferanschrift);
  Lib_Guicom2:Underline($edEin.Verbraucher);
  Lib_Guicom2:Underline($edEin.Rechnungsempf);
  Lib_Guicom2:Underline($edEin.AB.Bearbeiter);
  Lib_Guicom2:Underline($edEin.BDSNummer);
  Lib_Guicom2:Underline($edEin.Waehrung);
  Lib_Guicom2:Underline($edEin.Lieferbed);
  Lib_Guicom2:Underline($edEin.Zahlungsbed);
  Lib_Guicom2:Underline($edEin.Versandart);
  Lib_Guicom2:Underline($edEin.Sprache);
  Lib_Guicom2:Underline($edEin.AbmessungsEH);
  Lib_Guicom2:Underline($edEin.GewichtsEH);
  Lib_Guicom2:Underline($edEin.Land);
  Lib_Guicom2:Underline($edEin.Steuerschluessel);
  Lib_Guicom2:Underline($edEin.Sachbearbeiter);
  Lib_Guicom2:Underline($edEin.Verband);
  
  
  Lib_Guicom2:Underline($edEin.P.Auftragsart);
  Lib_Guicom2:Underline($edEin.P.Warengruppe);
  Lib_Guicom2:Underline($edEin.P.Projektnummer);
  Lib_Guicom2:Underline($edEin.P.Kommission);
  Lib_Guicom2:Underline($edEin.P.Guete);
  Lib_Guicom2:Underline($edEin.P.Zeugnisart);
  Lib_Guicom2:Underline($edEin.P.AbrufAufPos);
  Lib_Guicom2:Underline($edEin.P.Kostenstelle);
  Lib_Guicom2:Underline($edEin.P.Artikelnr);
  Lib_Guicom2:Underline($edEin.P.LieferArtNr);
  Lib_Guicom2:Underline($edEin.P.Intrastatnr);
  Lib_Guicom2:Underline($edEin.P.MEH.Wunsch);
  Lib_Guicom2:Underline($edEin.P.Preis.MEH);
  
  Lib_Guicom2:Underline($edEin.P.Auftragsart_Mat);
  Lib_Guicom2:Underline($edEin.P.Warengruppe_Mat);
  Lib_Guicom2:Underline($edEin.P.Projektnummer_Mat);
  Lib_Guicom2:Underline($edEin.P.Kommission_Mat);
  Lib_Guicom2:Underline($edEin.P.Guetenstufe_Mat);
  Lib_Guicom2:Underline($edEin.P.Guete_Mat);
  Lib_Guicom2:Underline($edEin.P.AusfOben_Mat);
  Lib_Guicom2:Underline($edEin.P.AusfUnten_Mat);
  Lib_Guicom2:Underline($edEin.P.Zeugnisart_Mat);
  Lib_Guicom2:Underline($edEin.P.AbrufAufPos_Mat);
  Lib_Guicom2:Underline($edEin.P.LieferMatArtNr_Mat);
  Lib_Guicom2:Underline($edEin.P.Artikelnr_Mat);
  Lib_Guicom2:Underline($edEin.P.Intrastatnr_Mat);
  Lib_Guicom2:Underline($edEin.P.Erzeuger_Mat);
  Lib_Guicom2:Underline($edEin.P.Preis.MEH_Mat);
  
  Lib_Guicom2:Underline($edEin.P.TextNr2b);
  
  Lib_Guicom2:Underline($edEin.P.Verpacknr);
  Lib_Guicom2:Underline($edEin.P.Verwiegungsart);
  Lib_Guicom2:Underline($edEin.P.Etikettentyp);
  Lib_Guicom2:Underline($edEin.P.Zwischenlage);
  Lib_Guicom2:Underline($edEin.P.Unterlage);
  Lib_Guicom2:Underline($edEin.P.Umverpackung);
  
  Lib_Guicom2:Underline($edEin.P.Etikettentyp2);
  Lib_Guicom2:Underline($edEin.P.Skizzennummer);
  
  // Auswahlfelder...
  SetStdAusFeld('edEin.Vorgangstyp'           ,'Vorgangstyp');
  SetStdAusFeld('edEin.Lieferantennr'         ,'Lieferant');
  SetStdAusFeld('edEin.Lieferadresse'         ,'Lieferadresse');
  SetStdAusFeld('edEin.Lieferanschrift'       ,'Lieferanschrift');
  SetStdAusFeld('edEin.Verbraucher'           ,'Verbraucher');
  SetStdAusFeld('edEin.Rechnungsempf'         ,'Rechnungsempf');
  SetStdAusFeld('edEin.AB.Bearbeiter'         ,'Ansprechpartner');
  SetStdAusFeld('edEin.BDSNummer'             ,'BDS');
  SetStdAusFeld('edEin.Land'                  ,'Land');
  SetStdAusFeld('edEin.Waehrung'              ,'Waehrung');
  SetStdAusFeld('edEin.Lieferbed'             ,'Lieferbed');
  SetStdAusFeld('edEin.Zahlungsbed'           ,'Zahlungsbed');
  SetStdAusFeld('edEin.Versandart'            ,'Versandart');
  SetStdAusFeld('edEin.Steuerschluessel'      ,'Steuerschluessel');
  SetStdAusFeld('edEin.Sprache'               ,'Sprache');
  SetStdAusFeld('edEin.AbmessungsEH'          ,'AbmessungsEH');
  SetStdAusFeld('edEin.GewichtsEH'            ,'GewichtsEH');
  SetStdAusFeld('edEin.Sachbearbeiter'        ,'Sachbearbeiter');
  SetStdAusFeld('edEin.Verband'               ,'Verband');
  SetStdAusFeld('edEin.P.Auftragsart'         ,'Auftragsart');
  SetStdAusFeld('edEin.P.AbrufAufNr'          ,'Abruf');
  SetStdAusFeld('edEin.P.Warengruppe'         ,'Warengruppe');
  SetStdAusFeld('edEin.P.LieferArtNr'         ,'LiefArtNr');
  SetStdAusFeld('edEin.P.Artikelnr'           ,'Artikelnummer');
  SetStdAusFeld('edEin.P.Projektnummer'       ,'Projekt');
  SetStdAusFeld('edEin.P.Kommission'          ,'Kommission');
  SetStdAusFeld('edEin.P.Kostenstelle'        ,'Kostenstelle');
  SetStdAusFeld('edEin.P.Termin1W.Art'        ,'Terminart');
  SetStdAusFeld('edEin.P.MEH.Wunsch'          ,'WunschMEH');
  SetStdAusFeld('edEin.P.Preis.MEH'           ,'PreisMEH');
  SetStdAusFeld('edEin.P.Kalkuliert'          ,'Kalkulation');
  SetSpeziAusFeld('edEin.P.Grundpreis'          ,'Preis');
  SetStdAusFeld('edEin.P.Auftragsart_Mat'     ,'Auftragsart');
  SetStdAusFeld('edEin.P.AbrufAufNr_Mat'      ,'Abruf');
  SetStdAusFeld('edEin.P.Warengruppe_Mat'     ,'Warengruppe');
  SetStdAusFeld('edEin.P.Projektnummer_Mat'   ,'Projekt');
  SetStdAusFeld('edEin.P.Artikelnr_Mat'       ,'Artikelnummer_Mat');
  SetStdAusFeld('edEin.P.Guete_Mat'           ,'Guete');
  SetStdAusFeld('edEin.P.Guete'                ,'Guete');
  SetStdAusFeld('edEin.P.Guetenstufe_Mat'     ,'Guetenstufe');
  SetStdAusFeld('edEin.P.AusfOben_Mat'        ,'AusfOben');
  SetStdAusFeld('edEin.P.AusfUnten_Mat'       ,'AusfUnten');
  SetStdAusFeld('edEin.P.LieferMatArtNr_Mat'  ,'LiefArtNr');
  SetStdAusFeld('edEin.P.Zeugnisart_Mat'      ,'Zeugnis');
  SetStdAusFeld('edEin.P.Zeugnisart'          ,'Zeugnis');
  SetStdAusFeld('edEin.P.Kommission_Mat'      ,'Kommission');
  SetStdAusFeld('edEin.P.Erzeuger_Mat'        ,'Erzeuger');
  SetStdAusFeld('edEin.P.Intrastatnr_Mat'     ,'Intrastat');
  SetStdAusFeld('edEin.P.Intrastatnr'         ,'Intrastat');
  SetStdAusFeld('edEin.P.Termin1W.Art_Mat'    ,'Terminart');
  SetStdAusFeld('edEin.P.Preis.MEH_Mat'       ,'PreisMEH');
  SetStdAusFeld('edEin.P.Kalkuliert_Mat'      ,'Kalkulation');
  SetStdAusFeld('edEin.P.Skizzennummer'       ,'Skizze');
  SetStdAusFeld('edEin.P.TextNr2'             ,'Text');
  SetStdAusFeld('edEin.P.TextNr2b'            ,'Text2');
  SetStdAusFeld('edEin.P.Zwischenlage'        ,'Zwischenlage');
  SetStdAusFeld('edEin.P.Unterlage'           ,'Unterlage');
  SetStdAusFeld('edEin.P.Umverpackung'        ,'Umverpackung');
  SetStdAusFeld('edEin.P.Verwiegungsart'      ,'Verwiegungsart');
  SetStdAusFeld('edEin.P.Etikettentyp'        ,'Etikett');
  SetStdAusFeld('edEin.P.Etikettentyp2'       ,'Etikett2');
  SetStdAusFeld('edEin.P.Verpacknr'           ,'Verpackung');

  if (Set.LyseErweitertYN) then begin
    vHdl # Winsearch(aEvt:Obj, 'lbEin.P.SbeligkeitMax');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'edEin.P.SbeligkeitMax');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'lbEin.P.SaebelProM');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'edEin.P.SaebelProM');
    if (vHdl<>0) then vHdl->wpVisible # false;
    vHdl # Winsearch(aEvt:Obj, 'lbSaebel');
    if (vHdl<>0) then vHdl->wpVisible # false;

    vPar # Winsearch(aEvt:Obj, 'NB.Page4');
    vHdl # Winsearch(aEvt:Obj, 'bt.InternerText');
    vHdl # Lib_GuiCom2:CreateObjFrom(vHdl, _WinTypeButton, vPar, 'bt.AnalyseErweitert', 'erweiterte Analyse anzeigen', _WinJustCenter, 144, 270, 70,25);
    vHdl->wpCustom  # '_I';
    Lib_GuiCom2:Hide(vPar, 'lbAnalyseStart', 'lbAnalyseEnde');
    Lib_MoreBufs:Init(501);
  end;

  // Ankerfunktion?
  RunAFX('Ein.P.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Ein.P.Init',aint(aEvt:Obj));
  RETURN true;
end;


//========================================================================
//  Skizzendaten
//
//========================================================================
sub Skizzendaten();
local begin
  vZ          : int;
  vA          : alpha;
  vWert       : alpha;
  vX          : int;
  vA3,vA4,vA5 : alpha(1000);
end;
begin

  // SPEZI
  gMDI->wpdisabled # y;
  FOR vX # 1 loop inc(vX) WHILE (vX<=Skz.Anzahl.Variablen) do begin
    vA # StrChar(64+vX);

    if (false) then begin
      Dlg_Standard:Anzahl('Variable '+vA,var vZ,0,300,400);
      case (vX%3) of
        0 : if (vA5='') then
              vA5 # vA + '='+cnvai(vZ)
            else
              vA5 # vA5 +',  '+ vA + '='+cnvai(vZ);
        1 : if (vA3='') then
              vA3 # vA + '='+cnvai(vZ)
            else
              vA3 # vA3 +',  '+ vA + '='+cnvai(vZ);
        2 : if (vA4='') then
              vA4 # vA + '='+cnvai(vZ)
            else
              vA4 # vA4 +',  '+ vA + '='+cnvai(vZ);
      end;  // case
    end;

    if (true) then begin
      Dlg_Standard:Standard('Variable '+vA,var vWert);
      case (vX%3) of
        0 : if (vA5='') then
              vA5 # vA + '='+vWert;
            else
              vA5 # vA5 +';  '+ vA + '='+vWert;
        1 : if (vA3='') then
              vA3 # vA + '='+vWert;
            else
              vA3 # vA3 +';  '+ vA + '='+vWert;
        2 : if (vA4='') then
              vA4 # vA + '='+vWert;
            else
              vA4 # vA4 +';  '+ vA + '='+vWert;
      end;  // case
    end;

  END;

  gMDI->wpdisabled # n;
  $edEin.P.Skizzennummer->Winfocusset(false);
  Ein.P.VpgText4 # StrCut(vA3,1,64);
  Ein.P.VpgText5 # StrCut(vA4,1,64)
  Ein.P.VpgText6 # StrCut(vA5,1,64)
  $edEin.P.VpgText42->winupdate(_WinUpdFld2Obj);
  $edEin.P.VpgText52->winupdate(_WinUpdFld2Obj);
  $edEin.P.VpgText62->winupdate(_WinUpdFld2Obj);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic);
local begin
  Erx       : int;
  vTxtHdl   : int;
  vPageName : alpha;
  vA        : alpha;
  vTmp      : int;
end;
begin

  if (Mode=c_ModeList) then RETURN;
  if (mode=c_ModeList2) then begin
    if (RecLinkInfo(501,500,9,_RecCount)>0) then  // 21.05.2015
      $ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
  end;

  // Ankerfunktion?
  if (aChanged) then vA # '1'+aName
  else vA # '0' + aName;
  if (RunAFX('Ein.P.RefreshIfm',vA)<0) then RETURN;

  RecBufClear(502);

  //if (aName='') then begin
  $RL.AFOben->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $RL.AFUnten->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  //end;

  if (Mode=c_Modeview) and (Ein.P.Nummer<1000000000) then begin
    RecLink(500,501,3,0);  // Kopf holen
  end;

  vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;    // Textpuffer ggf. anlegen
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $Ein.P.TextEdit1->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $Ein.P.TextStammdaten->wpdbTextBuf; // Textpuffer ggf. anlegen
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $Ein.P.TextStammdaten->wpdbTextBuf # vTxtHdl;
  end;

  vTxtHdl # $Ein.P.TextEditKopf->wpdbTextBuf;    // Textpuffer ggf. anlegen
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $Ein.P.TextEditKopf->wpdbTextBuf # vTxtHdl;
  end;
  vTxtHdl # $Ein.P.TextEditFuss->wpdbTextBuf;    // Textpuffer ggf. anlegen
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $Ein.P.TextEditFuss->wpdbTextBuf # vTxtHdl;
  end;

  // Ausgelagerte Refresh-Prozeduren aufrufen

  // ganze Seite refreshen?
  vPageName # $NB.Main->wpcurrent;
  if (StrLen(aName)>3) then
    if (StrCut(aName,1,3)='NB.') then begin
    vPageName # aName;
    aName # '';
  end;

  // Kommission hier prüfen, falls sich die Warengruppe verändert hat:  25.09.2012 AI Projekt 1371/122
  if ((aName='edEin.P.Kommission') and (($edEin.P.Kommission->wpchanged) or (aChanged)) ) or
      ((aName='edEin.P.Kommission_Mat') and (($edEin.P.Kommission_Mat->wpchanged) or (aChanged))) then begin
    vA # Str_Token(Ein.P.Kommission,'/',1);
    Ein.P.Kommissionnr  # Cnvia(vA);
    vA # Str_Token(Ein.P.Kommission,'/',2);
    Ein.P.Kommissionpos # Cnvia(vA);

    // 27.10.2016 AH: nur bei Anlage
    if (Mode=c_ModeNew2) or (Mode=c_ModeEdit2) then begin
      Erx # RecLink(401,501,18,_RecFirst);
      if (Erx<=_rLocked) then begin
        Ein.P.Warengruppe   # Auf.P.Warengruppe;

        if ((Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) <> Wgr_Data:IstMat(Auf.P.Wgr.Dateinr))) then begin
          Ein.P.WGr.Dateinr   # Auf.P.Wgr.Dateinr;
          Ein_P_SMain:Switchmask(n);
          aChanged # y;
          if (aName='edEin.P.Kommission') then
            aName # 'edEin.P.Kommission_Mat'
          else
            aName # 'edEin.P.Kommission';
        end
        else begin
          Ein.P.WGr.Dateinr   # Auf.P.Wgr.Dateinr;
          Ein_P_SMain:Switchmask(n);
        end;
      end;
    end;
  end;

  if (vPageName='NB.Kopf') then
    Ein_P_SMain:RefreshIfm_Kopf(aName, aChanged)
  else if (vPageName='NB.Page1') and ($NB.Page1->wpcustom='NB.Page1_Art') then
    Ein_P_SMain:RefreshIfm_Page1_Art(aName, aChanged)
  else if (vPageName='NB.Page1') and ($NB.Page1->wpcustom='NB.Page1_Mat') then
    Ein_P_SMain:RefreshIfm_Page1_Mat(aName, aChanged)
  else if (vPageName='NB.Page2') then
    Ein_P_SMain:RefreshIfm_Page2(aName, aChanged)
  else
    Ein_P_SMain:RefreshIfm_Page3(aName, aChanged);


  // Kopfzeile refreshen

  if (aName='') then begin
    if (Ein.Nummer<1000000000) then begin
      $lb.Nummer0->wpcaption # AInt(Ein.Nummer);
      $lb.Nummer1->wpcaption # AInt(Ein.Nummer);
      $lb.Nummer1_Mat->wpcaption # AInt(Ein.Nummer);
      $lb.Nummer2->wpcaption # AInt(Ein.Nummer);
      $lb.Nummer2b->wpcaption # AInt(Ein.Nummer);
      $lb.Nummer3->wpcaption # AInt(Ein.Nummer);
      $lb.Nummer4->wpcaption # AInt(Ein.Nummer);
      $lb.Nummer5->wpcaption # AInt(Ein.Nummer);
      $lb.Nummer6->wpcaption # AInt(Ein.Nummer);
      $lb.Nummer7->wpcaption # AInt(Ein.Nummer);
    end
    else begin
      $lb.Nummer0->wpcaption     # '';
      $lb.Nummer1->wpcaption     # '';
      $lb.Nummer1_Mat->wpcaption # '';
      $lb.Nummer2->wpcaption     # '';
      $lb.Nummer2b->wpcaption    # '';
      $lb.Nummer3->wpcaption     # '';
      $lb.Nummer4->wpcaption     # '';
      $lb.Nummer5->wpcaption     # '';
      $lb.Nummer6->wpcaption     # '';
      $lb.Nummer7->wpcaption     # '';
    end;
    $lb.Position1->wpcaption # AInt(Ein.P.Position);
    $lb.Position1_Mat->wpcaption # AInt(Ein.P.Position);
    $lb.Position2->wpcaption # AInt(Ein.P.Position);
    $lb.Position3->wpcaption # AInt(Ein.P.Position);
    $lb.Position4->wpcaption # AInt(Ein.P.Position);
    $lb.Position5->wpcaption # AInt(Ein.P.Position);
    $lb.Position6->wpcaption # AInt(Ein.P.Position);
    $lb.Position7->wpcaption # AInt(Ein.P.Position);
    $lb.P.Lieferant1->wpcaption # Ein.LieferantenSW;
    $lb.P.Lieferant1_Mat->wpcaption # Ein.LieferantenSW;
    $lb.P.Lieferant2->wpcaption # Ein.LieferantenSW;
    $lb.P.Lieferant3->wpcaption # Ein.LieferantenSW;
    $lb.P.Lieferant4->wpcaption # Ein.LieferantenSW;
    $lb.P.Lieferant5->wpcaption # Ein.LieferantenSW;
    $lb.P.Lieferant6->wpcaption # Ein.LieferantenSW;
    $lb.P.Lieferant7->wpcaption # Ein.LieferantenSW;
    $lb.P.Lieferant8->wpcaption # Ein.LieferantenSW;
    $lb.P.Einzelpreis->wpcaption # ANum(Ein.P.Einzelpreis,2);
    if (Ein.P.Materialnr=0) then begin
      $lb.P.Materialnr->wpcaption # '';
      $lb.P.Materialnr_Mat->wpcaption # '';
    end
    else begin
      $lb.P.Materialnr->wpcaption # aint(Ein.P.Materialnr);
      $lb.P.Materialnr_Mat->wpcaption # aint(Ein.P.Materialnr);
    end;
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfaerben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit(
  opt aBehalten   : logic;
  opt aMitAufp    : logic;
  opt aMitKalk    : logic;
)
local begin
  Erx     : int;
  vHdl    : int;
  vPos    : int;
  vTxt    : int;
  vErz    : int;
  vVW     : int;
end;
begin

  if ("Ein.WährungFixYN") then begin
    Lib_GuiCom:Enable($edEin.Waehrungskurs);
  end
  else begin
    Lib_GuiCom:Disable($edEin.Waehrungskurs);
  end;

  if (Mode=c_ModeEdit) and (Ein.P.Kommission<>'') then begin
    Lib_GuiCom:Disable($edEin.P.Kommission_Mat);
    Lib_GuiCom:Disable($bt.Kommission_Mat);
    Lib_GuiCom:Disable($edEin.P.Kommission);
    Lib_GuiCom:Disable($bt.Kommission);
  end;

  // Felder Disablen durch:
  if (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then begin // Edit?

    Lib_MoreBufs:RecInit(501, false);;

    if (Ein.Nummer<>0) and (Ein.Nummer<1000000000) then begin
      Lib_GuiCom:Disable($edEin.Datum);
      Lib_GuiCom:Disable($cbEin.LiefervertragYN);
      Lib_GuiCom:Disable($cbEin.AbrufYN);
      Lib_GuiCom:Disable($edEin.Lieferantennr);
      Lib_GuiCom:Disable($bt.Lieferant);
      Lib_GuiCom:Disable($edEin.P.AbrufAufNr);
      Lib_GuiCom:Disable($edEin.P.AbrufAufPos);
      Lib_GuiCom:Disable($bt.Abruf);
//      Lib_GuiCom:Disable($edEin.P.Warengruppe);
//      Lib_GuiCom:Disable($bt.Warengruppe);
      Lib_GuiCom:Disable($edEin.P.Artikelnr);
      Lib_GuiCom:Disable($bt.Artikelnummer);
      Lib_GuiCom:Disable($edEin.P.LieferArtNr);
      Lib_GuiCom:Disable($bt.LieferArtNr);
//      Lib_GuiCom:Disable($edEin.P.Termin1W.Art);
//      Lib_GuiCom:Disable($edEin.P.MEH.Wunsch);
//      Lib_GuiCom:Disable($bt.MEH);

      if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
        Lib_GuiCom:Disable($edEin.P.Artikelnr_Mat);
        Lib_GuiCom:Disable($bt.Artikelnummer_Mat);
      end
      else begin
        Lib_GuiCom:Enable($edEin.P.Artikelnr_Mat);
        Lib_GuiCom:Enable($bt.Artikelnummer_Mat);
      end;

      Lib_GuiCom:Disable($edEin.P.AbrufAufNr_Mat);
      Lib_GuiCom:Disable($edEin.P.AbrufAufPos_Mat);
      Lib_GuiCom:Disable($bt.Abruf_Mat);
//      Lib_GuiCom:Disable($edEin.P.Warengruppe_Mat);
//      Lib_GuiCom:Disable($bt.Warengruppe_Mat);
//      Lib_GuiCom:Disable($edEin.P.Termin1W.Art_Mat);
    end;  // echte Pos.

    if (Ein.P.TextNr1=501) then begin
      Lib_GuiCom:Enable($Ein.P.TextEdit1);
      Lib_GuiCom:Disable($edEin.P.TextNr2);
      Lib_GuiCom:Disable($edEin.P.TextNr2b);
      $cb.Text1->wpCheckState # _WinStateChkUnChecked;
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkChecked;
    end
    else if (Ein.P.TextNr1=500) then begin
      Lib_GuiCom:Disable($Ein.P.TextEdit1);
      Lib_GuiCom:Enable($edEin.P.TextNr2);
      Lib_GuiCom:Disable($edEin.P.TextNr2b);
      $cb.Text1->wpCheckState # _WinStateChkChecked;
      $cb.Text2->wpCheckState # _WinStateChkUnChecked;
      $cb.Text3->wpCheckState # _WinStateChkUnChecked;
    end
    else if (Ein.P.TextNr1=0) then begin
      Lib_GuiCom:Disable($Ein.P.TextEdit1);
      Lib_GuiCom:Disable($edEin.P.TextNr2);
      Lib_GuiCom:Enable($edEin.P.TextNr2b);
      $cb.Text1->wpCheckState # _WinStateChkUnChecked;
      $cb.Text2->wpCheckState # _WinStateChkChecked;
      $cb.Text3->wpCheckState # _WinStateChkUnChecked;
    end;
    
    //[+] 03.05.2022 MR Änderung des Vorgangstypen führt zu Fehlern (2228/67)
    Lib_GuiCom:Disable($edEin.Vorgangstyp);
    Lib_GuiCom:Disable($bt.Vorgangstyp);
  end;  // Edit

  if (Ein.AbrufYN=n) then begin
    Lib_GuiCom:Disable($edEin.P.AbrufAufNr);
    Lib_GuiCom:Disable($edEin.P.AbrufAufPos);
    Lib_GuiCom:Disable($bt.Abruf);
    Lib_GuiCom:Disable($edEin.P.AbrufAufNr_Mat);
    Lib_GuiCom:Disable($edEin.P.AbrufAufPos_Mat);
    Lib_GuiCom:Disable($bt.Abruf_Mat);
  end
  else begin
    Lib_GuiCom:Disable($edEin.P.Artikelnr);
    Lib_GuiCom:Disable($bt.Artikelnummer);
    Lib_GuiCom:Disable($edEin.P.LieferArtNr);
    Lib_GuiCom:Disable($bt.LieferArtNr);
    Lib_GuiCom:Disable($edEin.P.MEH.Wunsch);
    Lib_GuiCom:Disable($bt.MEH);
 end;



  // Mengen und MEH beachten
  if (Ein.P.MEH.Wunsch=Ein.P.MEH) then begin
    Ein.P.Menge # Ein.P.Menge.Wunsch;
    Lib_GuiCom:Disable($edEin.P.Menge);
    $edEin.P.Menge->WinUpdate(_WinUpdFld2Obj);
  end
  else begin
    Lib_GuiCom:Enable($edEin.P.Menge);
  end;

  // Focus setzen auf Feld:

  if (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then begin // Edit?
    if (Ein.P.Nummer<1000000000) then begin
      RecLink(500,501,3,_RecLock);  // Kopf holen
      PtD_Main:Memorize(500);
      if ($NB.Page1->wpcustom='NB.Page1_Art') then
        $edEin.P.Auftragsart->WinFocusSet(true)
      else
        $edEin.P.Auftragsart_Mat->WinFocusSet(true);
    end;
  end;

  if (Mode=c_ModeNew2) then begin // neue Position anlegen
    $NB.Page1->wpdisabled # false;
    if ($NB.Page1->wpcustom='NB.Page1_Art') then begin
      vHdl # gMdi->Winsearch('NB.Main');
      vHdl->wpcurrent # 'NB.Page1';
      $edEin.P.Auftragsart->WinFocusSet(true)
    end
    else begin
      vHdl # gMdi->Winsearch('NB.Main');
      vHdl->wpcurrent # 'NB.Page1';
      $edEin.P.Auftragsart_Mat->WinFocusSet(true);
    end;
    $NB.Erfassung->wpvisible # false;

    if (aBehalten) then begin
      if (w_AppendNr<>0) then begin   // 2023-01-26 AH
        Erx # RecLink(501,500,9,_RecLast);
        vPos # Ein.P.Position + 1;
        Erx # RecRead(501,0,0,w_AppendNr);
// 2023-04-20 AH Proj. 2465/81/1       w_AppendNr  # 0;
      end
      else begin
        Erx # RecLink(501,500,9,_RecLast);
        if (Erx<=_rLocked) then
        vPos # Ein.P.Position + 1;
      end;

      if (vPos>0) then begin
        Lib_MoreBufs:RecInit(501, y, y);

        w_BinKopieVonDatei  # gFile;
        w_BinKopieVonRecID  # RecInfo(gFile, _recid);

        // internen Text kopieren 29.10.2021 AH
        TxtCopy(myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01', myTmpText+'.501.'+CnvAI(vPos,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01',0);

        // Aufpreise kopieren?
        if (aMitAufp) then begin
          Erx # RecLink(503,501,7,_recFirst);
          WHILE (Erx<=_rLocked) do begin
            Ein.Z.Position # vPos;
            RekInsert(503,0,'MAN');
            Ein.Z.Position # Ein.P.Position;
            Recread(503,1,0);
            Erx # RecLink(503,501,7,_recNext);
          END;
        end
        else begin
          Ein.P.Aufpreis      # 0.0;
        end;
        // Kalkulation kopieren?
        if (aMitKalk) then begin
          Erx # RecLink(505,501,8,_recFirst);
          WHILE (Erx<=_rLocked) do begin
            Ein.K.Position # vPos;
            RekInsert(505,0,'MAN');
            Ein.K.Position # Ein.P.Position;
            Recread(505,1,0);
            Erx # RecLink(505,501,8,_recNext);
          END;
        end
        else begin
          Ein.P.Kalkuliert    # 0.0;
        end;
        Ein.p.Einzelpreis # Ein.P.Grundpreis + Ein.P.Aufpreis;


        // Ausführungen kopieren...
        Erx # RecLink(502,501,12,_recFirst);
        WHILE (Erx<=_rLocked) do begin
          Ein.AF.Position # vPos;
          RekInsert(502,0,'MAN');
          Ein.AF.Position # Ein.P.Position;
          Recread(502,1,0);
          Erx # RecLink(502,501,12,_recNext);
        END;

      end
      else begin
        vPos # 1;
      end;
    end
    else begin                  // leere Position erzeugen --------
      Erx # RecLink(501,500,9,_RecLast);
      if (Erx<>_rOk) then vPos # 1
      else vPos # Ein.P.Position + 1;
    end;
    vErz  # Ein.P.Erzeuger;
    vVW   # Ein.P.Verwiegungsart;
    if (aBehalten=n) then begin
      Lib_MoreBufs:RecInit(501, y);
      RecBufClear(501);
      Ein.P.MEH             # 'kg';   // 13.06.2022 AH
      $edEin.P.Artikelnr_Mat->wpcaption # '';
    end;

    Ein.P.Nummer # Ein.Nummer;
    Ein.P.Position # vPos;
    Ein.P.Lieferantennr   # Ein.Lieferantennr;
    Ein.P.LieferantenSW   # Ein.LieferantenSW;
    Ein.P.Erzeuger        # vErz;
    Ein.P.Verwiegungsart  # vVW;
    Ein.P.AB.Nummer       # Ein.AB.Nummer;    // 19.10.2016
    Ein.P.ErfuellGrad     # 0.0;

    if (Ein.P.TextNr1=501) then
      $Ein.P.TextEdit1->wpcustom # myTmpText+'.501.'+CnvAI(ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);

    if (aBehalten=n) then begin

      Ein.P.MEH.Preis     # Set.Ein.MEH.PEH;
      Ein.P.PEH           # Set.Ein.PEH;
      Ein.P.MEH.Wunsch    # Ein.P.MEH.Preis;
      Ein.P.Warengruppe   # Set.Ein.Warengruppe;
      Ein.P.Wgr.Dateinr   # Set.Ein.Dateinr;    // 2023-04-25 AH ff.
      Erx # RecLink(819,501,1,_RecFirst);   // Warengruppe holen
      if (Erx>_rLocked) then RecBufClear(819)
      else Ein.P.Wgr.Dateinr   # Wgr.Dateinummer;
      Ein.P.Auftragsart   # Set.Ein.Auftragsart;
      Ein.P.Termin1W.Art  # Set.Ein.TerminArt;

      if (Set.Ein.PosText=999) then begin
        $cb.Text1->wpcheckstate # _WinStateChkUnchecked;
        $cb.Text2->wpcheckstate # _WinStateChkUnchecked;
        $cb.Text3->wpcheckstate # _WinStateChkchecked;
        Ein.P.TextNr1 # 501;
        Ein.P.TextNr2 # 0;
        $edEin.P.TextNr2->wpCaptionInt # 0;
        $edEin.P.TextNr2b->wpCaptionInt # 0;
      end
      else begin
        $cb.Text1->wpcheckstate # _WinStateChkUnchecked;
        $cb.Text2->wpcheckstate # _WinStateChkchecked;
        $cb.Text3->wpcheckstate # _WinStateChkUnchecked;
        Ein.P.TextNr1 # 0;
        Ein.P.TextNr2 # 0;
        $edEin.P.TextNr2->wpCaptionInt # 0;
        $edEin.P.TextNr2b->wpCaptionInt # Set.Ein.Postext;
      end;
    end;

    Erx # RecLink(814,500,8,0);
    if (Erx<=_rLocked) then begin
      $lb.WAE1->wpcaption # "Wae.Kürzel";
      $lb.WAE2->wpcaption # "Wae.Kürzel";
      $lb.WAE3->wpcaption # "Wae.Kürzel";
      $lb.WAE4->wpcaption # "Wae.Kürzel";
      $lb.WAE1_Mat->wpcaption # "Wae.Kürzel";
      $lb.WAE2_Mat->wpcaption # "Wae.Kürzel";
      $lb.WAE3_Mat->wpcaption # "Wae.Kürzel";
      $lb.WAE4_Mat->wpcaption # "Wae.Kürzel";
    end
    else begin
      $lb.WAE1->wpcaption # '???';
      $lb.WAE2->wpcaption # '???';
      $lb.WAE3->wpcaption # '???';
      $lb.WAE4->wpcaption # '???';
      $lb.WAE1_Mat->wpcaption # '???';
      $lb.WAE2_Mat->wpcaption # '???';
      $lb.WAE3_Mat->wpcaption # '???';
      $lb.WAE4_Mat->wpcaption # '???';
    end;

    // Material per Drag&Drop eingefügt??
    if (w_Command='AusMaterial') then begin
      w_Command # '';
      AusMaterial();
    end;

    // Sonderfunktion:
    RunAFX('Ein.P.RecInit.Post','');

    gMDI->winupdate();
    RETURN;
  end;

  // neuen Kopf&Pos. anlegen ***********************************************
  // neuen Kopf&Pos. anlegen ***********************************************
  // neuen Kopf&Pos. anlegen ***********************************************
//debugx(mode+' '+aint(w_appendnr));
  if (Mode=c_ModeNew) then begin
    // Anhängen???
    if (w_AppendNr<>0) then begin
      Ein.Nummer # w_AppendNr;
      RecRead(500,1,0);
      Erx # RecLink(501,500,9,_RecLast);
      if (Erx<>_rOk) then vPos # 1
      else vPos # ein.P.Position + 1;
      RecBufClear(501);
      $edEin.P.Artikelnr_Mat->wpcaption # '';
      RecLink(100,500,1,0);   // Lieferant holen
      Ein.P.Lieferantennr # Ein.Lieferantennr;
      Ein.P.LieferantenSW # Ein.LieferantenSW;
      Ein.P.Erzeuger      # Adr.Nummer;
      Mode # c_modeNew2;
      if (Ein.AbrufYN = true) then begin
        Lib_GuiCom:Enable($edEin.P.AbrufAufNr);
        Lib_GuiCom:Enable($edEin.P.AbrufAufPos);
        Lib_GuiCom:Enable($bt.Abruf);
        Lib_GuiCom:Enable($edEin.P.AbrufAufNr_Mat);
        Lib_GuiCom:Enable($edEin.P.AbrufAufPos_Mat);
        Lib_GuiCom:Enable($bt.Abruf_Mat);
      end;
      Lib_MoreBufs:RecInit(501, y, y);
    end
    else begin
      RecBufClear(500);
      vPos # 1;
    end;

    Lib_guiCom:Disable($edEin.GltigkeitVom);
    Lib_guiCom:Disable($edEin.GltigkeitBis);
    Lib_GuiCom:Enable($cbEin.LiefervertragYN);
    Lib_GuiCom:Enable($cbEin.AbrufYN);

    $edEin.Lieferantennr->wpcaptionint # -1;    // für 1. Eingabe - WinKrampf
    vHdl # gMdi->Winsearch('NB.Main');
    vHdl->wpcurrent # 'NB.Kopf';
    $edEin.Lieferantennr->WinFocusSet(true);
    $NB.Erfassung->wpvisible # false;

    Ein.Nummer          # myTmpNummer;
    if (w_AppendNr=0) then begin
      Ein.Datum           # today;
      Ein.Vorgangstyp     # c_Bestellung;
      Ein.Sachbearbeiter  # gUserName;
      if (Set.Ein.Lieferadress=-1) then begin
        Erx # RecLink(100,500,1,_recfirst);   // Lieferant holen
        if (Erx<=_rLocked) and (Ein.Lieferantennr<>0) then begin
          Ein.Lieferadresse   # Adr.Nummer;
          Ein.Lieferanschrift # Set.Ein.Lieferanschr;
        end;
      end
      else begin
        Ein.Lieferadresse   # Set.Ein.Lieferadress;
        Ein.Lieferanschrift # Set.Ein.Lieferanschr;
      end;
      Erx # RecLink(100,500,12,_recFirst);    // Lieferadresse holen
      if (Erx<=_rLocked) then Ein.Rechnungsempf   # Adr.Lieferantennr;
    end;

    Ein.P.Nummer    # Ein.Nummer;
    Ein.P.Position  # vPos;

    Ein.P.MEH.Preis     # Set.Ein.MEH.PEH;
    Ein.P.PEH           # Set.Ein.PEH;
    Ein.P.MEH.Wunsch    # 'kg';
    Ein.P.MEH           # 'kg';
    Ein.P.Warengruppe   # Set.Ein.Warengruppe;
    Ein.P.Wgr.Dateinr   # Set.Ein.Dateinr;    // 2023-04-25 AH ff.
    Erx # RecLink(819,501,1,_RecFirst);   // Warengruppe holen
    if (erx>_rLocked) then RecBufClear(819)
    else Ein.P.Wgr.Dateinr   # Wgr.Dateinummer;
    Ein.P.Auftragsart   # Set.Ein.Auftragsart;
    Ein.P.Termin1W.Art  # Set.Ein.TerminArt;

    // Texte leeren/Vorbelegen
    if (Set.Ein.PosText=999) then begin
      $cb.Text1->wpcheckstate # _WinStateChkUnchecked;
      $cb.Text2->wpcheckstate # _WinStateChkUnchecked;
      $cb.Text3->wpcheckstate # _WinStateChkchecked;
      Ein.P.TextNr1 # 501;
      Ein.P.TextNr2 # 0;
      $edEin.P.TextNr2->wpCaptionInt # 0;
      $edEin.P.TextNr2b->wpCaptionInt # 0;
    end
    else begin
      $cb.Text1->wpcheckstate # _WinStateChkUnchecked;
      $cb.Text2->wpcheckstate # _WinStateChkchecked;
      $cb.Text3->wpcheckstate # _WinStateChkUnchecked;
      Ein.P.TextNr1 # 0;
      Ein.P.TextNr2 # 0;
      $edEin.P.TextNr2->wpCaptionInt # 0;
      $edEin.P.TextNr2b->wpCaptionInt # Set.Ein.Postext;
    end;
    vTxt # $Ein.P.TextEditKopf->wpdbTextBuf;
    if (vTxt<>0) then TextClear(vTxt);
    $Ein.P.TextEditKopf->WinUpdate(_WinUpdBuf2Obj);
    vTxt # $Ein.P.TextEditFuss->wpdbTextBuf;
    if (vTxt<>0) then TextClear(vTxt);
    $Ein.P.TextEditFuss->WinUpdate(_WinUpdBuf2Obj);


    Erx # RecLink(814,500,8,_recfirst);
    if (Erx<=_rLocked) then begin
      $lb.WAE1->wpcaption # "Wae.Kürzel";
      $lb.WAE2->wpcaption # "Wae.Kürzel";
      $lb.WAE3->wpcaption # "Wae.Kürzel";
      $lb.WAE4->wpcaption # "Wae.Kürzel";
      $lb.WAE1_Mat->wpcaption # "Wae.Kürzel";
      $lb.WAE2_Mat->wpcaption # "Wae.Kürzel";
      $lb.WAE3_Mat->wpcaption # "Wae.Kürzel";
      $lb.WAE4_Mat->wpcaption # "Wae.Kürzel";
    end
    else begin
      $lb.WAE1->wpcaption # '???';
      $lb.WAE2->wpcaption # '???';
      $lb.WAE3->wpcaption # '???';
      $lb.WAE4->wpcaption # '???';
      $lb.WAE1_Mat->wpcaption # '???';
      $lb.WAE2_Mat->wpcaption # '???';
      $lb.WAE3_Mat->wpcaption # '???';
      $lb.WAE4_Mat->wpcaption # '???';
    end;

    $NB.Page1->wpdisabled # y;
    $NB.Page2->wpdisabled # y;
    $NB.Page3->wpdisabled # y;
    $NB.Page4->wpdisabled # y;
    $NB.Page5->wpdisabled # y;

    if (w_AppendNr<>0) then begin
      Mode # c_ModeNew2;
      $NB.Page1->wpdisabled # n;
      $NB.Page2->wpdisabled # n;
      $NB.Page3->wpdisabled # n;
      $NB.Page4->wpdisabled # n;
      $NB.Page5->wpdisabled # n;
      vHdl # gMdi->Winsearch('NB.Main');
      vHdl->wpcurrent # 'NB.Page1';
    end;

  end;

  // Sonderfunktion:
  RunAFX('Ein.P.RecInit.Post','');

  RETURN
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vNummer : int;
  vPos    : int;
  vPreis  : float;
  vHdl    : int;
  vTxt    : int;
  vOK     : logic;
  vTmp    : int;
  vBuf501 : int;
  vMatUpd : logic;
  vL      : float;
  vMatNr  : int;
end;
begin

  vTmp # gMdi->Winsearch('NB.Main');

  // logische Prüfung
  if(Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() = false) then
    RETURN false;


  if ((Mode=c_ModeEdit) or (Mode=c_ModeEdit2) or (Mode=c_ModeNew2)) and
    (Set.LyseErweitertYN) then begin
    if(Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern('Lys.Maske2') = false) then
      RETURN false;
  end;
 
  If (Ein.Lieferantennr=0) then begin
    Msg(001200,Translate('Lieferant'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Lieferantennr->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(100,500,1,_recfirst);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lieferant'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Lieferantennr->WinFocusSet(true);
    RETURN false;
  end;
  if (Adr.SperrLieferantYN) then begin
    Msg(100006,Adr.Stichwort,0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Lieferantennr->WinFocusSet(true);
    RETURN false;
  end;

  If (Ein.Lieferadresse=0) then begin
    Msg(001200,Translate('Lieferadresse'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Lieferadresse->WinFocusSet(true);
    RETURN false;
  end;
  If (Ein.Lieferanschrift=0) then begin
    Msg(001200,Translate('Lieferanschrift'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Lieferanschrift->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(101,500,2,_recTest);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lieferanschrift'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Lieferadresse->WinFocusSet(true);
    RETURN false;
  end;
   If (Ein.Verbraucher<>0) then begin
    Erx # RecLink(100,500,3,_recTest);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Verbraucher'),0,0,0);
      vTmp->wpcurrent # 'NB.Kopf';
      $edEin.Verbraucher->WinFocusSet(true);
      RETURN false;
    end;
  end;

  If (Ein.Rechnungsempf<>0) then begin
    Erx # RecLink(100,500,4,_recTest);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Besitzer'),0,0,0);
      vTmp->wpcurrent # 'NB.Kopf';
      $edEin.Rechnungsempf->WinFocusSet(true);
      RETURN false;
    end;
  end;

  If ("Ein.Währung"=0) then begin
    Msg(001200,Translate('Währung'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Waehrung->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(814,500,8,_recTest);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Währung'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Waehrung->WinFocusSet(true);
    RETURN false;
  end;

  If (Ein.Lieferbed=0) then begin
    Msg(001200,Translate('Lieferbedingung'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Lieferbed->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(815,500,5,_recTest);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lieferbedingung'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Lieferbed->WinFocusSet(true);
    RETURN false;
  end;
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) then begin   // 2023-08-14 AH
    If (Lib.SperreNeuYN) then begin
      Msg(815001,'',0,0,0);
      vTmp->wpcurrent # 'NB.Kopf';
      $edEin.Lieferbed->WinFocusSet(true);
      RETURN false;
    end;
  end;

  If (Ein.Zahlungsbed=0) then begin
    Msg(001200,Translate('Zahlungsbedingung'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Zahlungsbed->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(816,500,6,_recTest);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Zahlungsbedingung'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Zahlungsbed->WinFocusSet(true);
    RETURN false;
  end;
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) then begin
    If (ZaB.SperreNeuYN) then begin
      Msg(816003,'',0,0,0);
      vTmp->wpcurrent # 'NB.Kopf';
      $edEin.Zahlungsbed->WinFocusSet(true);
      RETURN false;
    end;
  end;

  If (Ein.Versandart=0) then begin
    Msg(001200,Translate('Versandart'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Versandart->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(817,500,7,_recTest);    // Versandart holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Versandart'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Versandart->WinFocusSet(true);
    RETURN false;
  end;

  If ("Ein.Steuerschlüssel"=0) then begin
    Msg(001200,Translate('Steuerschlüssel'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Steuerschluessel->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(813,500,17,_recTest);    // Steuerschlüssel holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Steuerschlüssel'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Steuerschluessel->WinFocusSet(true);
    RETURN false;
  end;

  If (Ein.Datum=0.0.0) then begin
    Msg(001200,Translate('Bestelldatum'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Datum->WinFocusSet(true);
    RETURN false;
  end;

  If (Ein.Vorgangstyp='') then begin
    Lib_Guicom2:InhaltFehlt('Vorgangstyp', 'NB.Page1', 'edEin.Vorgangstyp');
    RETURN false;
  end;
  if (Ein.Vorgangstyp<>c_Bestellung) and (Ein.Vorgangstyp<>c_Anfrage) and (Ein.Vorgangstyp<>c_VorlageAuf) then begin
    Lib_Guicom2:InhaltFalsch('Vorgangstyp', 'NB.Page1', 'edEin.Vorgangstyp');
    RETURN false;
  end;

  If (Ein.Sprache='') then begin
    Msg(001200,Translate('Sprache'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Sprache->WinFocusSet(true);
    RETURN false;
  end;

  If (Ein.AbmessungsEH='') then begin
    Msg(001200,Translate('Abmessungseinheit'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.AbmessungsEH->WinFocusSet(true);
    RETURN false;
  end;

  If (Ein.GewichtsEH='') then begin
    Msg(001200,Translate('Gewichtseinheit'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.GewichtsEH->WinFocusSet(true);
    RETURN false;
  end;

  If (Ein.Sachbearbeiter='') then begin
    Msg(001200,Translate('Sachbearbeiter'),0,0,0);
    vTmp->wpcurrent # 'NB.Kopf';
    $edEin.Sachbearbeiter->WinFocusSet(true);
    RETURN false;
  end;

  // Verband
  if (Ein.Verband<>0) then begin
    Erx # RekLink(110,500,20,_RecFirst);
    if (Erx>_rLocked) then begin
      Msg(001201,Translate('Verband'),0,0,0);
      vTmp->wpcurrent # 'NB.Kopf';
      $edEin.Verband->WinFocusSet(true);
      RETURN false;
    end;
    if (Ver.SperreYN) then begin
      Msg(110000,Ver.Stichwort,0,0,0);
      vTmp->wpcurrent # 'NB.Kopf';
      $edEin.Verband->WinFocusSet(true);
      RETURN false;
    end;
  end;


  if (Wgr_Data:IstMixMat(Ein.P.Wgr.Dateinr)) then begin
    Ein.P.Artikelnr # $edEin.P.Artikelnr_Mat->wpcaption;
  end
  else begin
    Ein.P.Strukturnr # StrCut($edEin.P.Artikelnr_Mat->wpcaption,1,20);
  end;

  // Positions Logik
  if (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) or (Mode=c_ModeNew2) then begin
    If (Ein.P.Auftragsart=0) then begin
      Msg(001200,Translate('Vorgangsart'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      if ($NB.Page1->wpcustom='NB.Page1_Art') then
        $edEin.P.Auftragsart->WinFocusSet(true)
      else
        $edEin.P.Auftragsart_Mat->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(835,501,5,_RecTest);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Vorgangsart'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      if ($NB.Page1->wpcustom='NB.Page1_Art') then
        $edEin.P.Auftragsart->WinFocusSet(true)
      else
        $edEin.P.Auftragsart_Mat->WinFocusSet(true)
      RETURN false;
    end;

    If (Ein.P.Warengruppe=0) then begin
      Msg(001200,Translate('Warengruppe'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      if ($NB.Page1->wpcustom='NB.Page1_Art') then
        $edEin.P.Warengruppe->WinFocusSet(true)
      else
        $edEin.P.Warengruppe_Mat->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(819,501,1,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Warengruppe'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      if ($NB.Page1->wpcustom='NB.Page1_Art') then
        $edEin.P.Warengruppe->WinFocusSet(true)
      else
        $edEin.P.Warengruppe_Mat->WinFocusSet(true);
      RETURN false;
    end;


    if (Ein.AbrufYN) and (Ein.P.AbrufAufnr=0) then begin
      Msg(001200,Translate('Abruf'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      if ($NB.Page1->wpcustom='NB.Page1_Art') then
        $edEin.P.AbrufAufNr->WinFocusSet(true)
      else
        $edEin.P.AbrufAufNr_Mat->WinFocusSet(true);
      RETURN false;
    end;

    // 01.06.2022 AH:
    if (Ein.P.KommissionNr<>0) then begin
      Erx # Auf_Data:Read(Ein.P.KommissionNr, Ein.P.KommissionPos,y);
      if (Erx<400) or (Auf.Vorgangstyp<>c_AUF)then begin
        if ($NB.Page1->wpcustom='NB.Page1_Art') then
          Lib_Guicom2:InhaltFalsch('Kommission', 'NB.Page1', 'edEin.P.Kommission')
        else
          Lib_Guicom2:InhaltFalsch('Kommission', 'NB.Page1', 'edEin.P.Kommission_Mat');
        RETURN false;
      end;
    end;

    // Artikeldatei?
    if ($NB.Page1->wpcustom='NB.Page1_Art') then begin
      If (Ein.P.Artikelnr='') then begin
        Msg(001200,Translate('Artikelnummer'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.Artikelnr->WinFocusSet(true);
        RETURN false;
      end;
      Erx # RecLink(250,501,2,_RecTest);
      If (Erx>_rLocked) then begin
        Msg(001201,Translate('Artikelnummer'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.Artikelnr->WinFocusSet(true);
        RETURN false;
      end;


      if (Wgr_Data:IstMixArt(Ein.P.Wgr.Dateinr)) and ("Ein.P.Güte"='') then begin
        Msg(001200,Translate('Güte'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.Guete->WinFocusSet(true);
        RETURN false;
      end;


      If (Lib_Einheiten:CheckMEH(var Ein.P.MEH.Wunsch)=false) then begin
        Lib_Guicom2:InhaltFalsch('Mengeneinheit', 'NB.Page1', 'edEin.P.MEH.Wunsch');
        RETURN false;
      end;
      If (Lib_Einheiten:CheckMEH(var Ein.P.MEH.Preis)=false) then begin
        Lib_Guicom2:InhaltFalsch('Mengeneinheit', 'NB.Page1', 'edEin.P.Preis.MEH');
        RETURN false;
      end;


      If (Ein.P.Termin1Wunsch=0.0.0) then begin
        Msg(001200,Translate('Wunschtermin'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.Termin1Wunsch->WinFocusSet(true);
        RETURN false;
      end;

      if (Ein.P.Menge=0.0) then begin
        Msg(001200,Translate('Menge'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.Menge->WinFocusSet(true);
        RETURN false;
      end;

     end; // Artikeldatei


    // Materialdatei?
    if ($NB.Page1->wpcustom='NB.Page1_Mat') then begin
      If ("Ein.P.Güte"='') then begin
        Msg(001200,Translate('Güte'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.Guete_Mat->WinFocusSet(true);
        RETURN false;
      end;

      if (Ein.P.Artikelnr<>'') then begin
        Erx # RecLink(250,501,2,_RecTest);
        If (Erx>_rLocked) then begin
          Msg(001201,Translate('Artikelnummer'),0,0,0);
          vTmp->wpcurrent # 'NB.Page1';
          $edEin.P.Artikelnr->WinFocusSet(true);
          RETURN false;
        end;
      end;

      If (Ein.P.Erzeuger<>0) then begin
        Erx # RecLink(100,501,11,_recTest);
        If (Erx>_rLocked) then begin
          Msg(001201,Translate('Erzeuger'),0,0,0);
          vTmp->wpcurrent # 'NB.Page1';
          $edEin.P.Erzeuger_Mat->WinFocusSet(true);
          RETURN false;
        end;
      end;

      If (Ein.P.Gewicht=0.0) then begin
        Msg(001200,Translate('Gewicht'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.Gewicht_Mat->WinFocusSet(true);
        RETURN false;
      end;

      If (Ein.P.MEH.Preis='') then begin
        Msg(001200,Translate('Mengeneinheit'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.Preis.MEH_Mat->WinFocusSet(true);
        RETURN false;
      end;
      If (Lib_Einheiten:CheckMEH(var Ein.P.MEH.Preis)=false) then begin
        Lib_Guicom2:InhaltFalsch('Mengeneinheit', 'NB.Page1', 'edEin.P.Preis.MEH_Mat');
        RETURN false;
      end;

      If (Ein.P.PEH=0) then begin
        Msg(001200,Translate('Preiseinheit'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.PEH_Mat->WinFocusSet(true);
        RETURN false;
      end;

      If (Ein.P.Termin1Wunsch=0.0.0) then begin
        Msg(001200,Translate('Wunschtermin'),0,0,0);
        vTmp->wpcurrent # 'NB.Page1';
        $edEin.P.Termin1Wunsch_Mat->WinFocusSet(true);
        RETURN false;
      end;

      If (Ein.P.Verwiegungsart<>0) then begin
        Erx # RecLink(818,501,10,_recTest);
        If (Erx>_rLocked) then begin
          Msg(001201,Translate('Verwiegungsart'),0,0,0);
          vTmp->wpcurrent # 'NB.Page3';
          $edEin.P.Verwiegungsart->WinFocusSet(true);
          RETURN false;
        end;
      end;

      If (Ein.P.Etikettentyp<>0) then begin
        Erx # RecLink(840,501,9,_recTest);
        If (Erx>_rLocked) then begin
          Msg(001201,Translate('Etikettentyp'),0,0,0);
          vTmp->wpcurrent # 'NB.Page3';
          $edEin.P.Etikettentyp->WinFocusSet(true);
          RETURN false;
        end;
      end;

    end; // Material
  end;


  if (RunAFX('Ein.P.RecSave.Pre','')<>0) then begin
    if (AfxRes<>_rOk) then begin   // 17.11.2020 AH: Abbruch, wenn z.B. Pflichtfeldverletzung
      RETURN False;
    end;
  end;


  // neuer Kopf? -> merken und in Position springen ***********************
  if (Mode=c_ModeNew) then begin
    if (vTmp->wpcurrent='NB.Kopf') then begin
      Mode # c_ModeNew2;

      // Text vorbelegen?
      if (Set.Ein.Kopftext<>0) then begin
        Txt.Nummer # Set.Ein.Kopftext;
        Erx # RecRead(837,1,0);
        if (Erx<_rLocked) then begin
          vHdl # $Ein.P.TextEditKopf->wpdbTextBuf;
          Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vHdl,Ein.Sprache);
          $Ein.P.TextEditKopf->WinUpdate(_WinUpdBuf2Obj);
          $Ein.P.TextEditKopf->wpcustom # myTmpText+'.501.K';
        end;
      end;

      vTxt # 0;
      RecLink(100,500,1,0);   // Lieferant holen
      vTxt # Adr.EK.Fusstext;
      if (vTxt=0) then vTxt # Set.Ein.Fusstext;
      if (vTxt<>0) then begin
        Txt.Nummer # vTxt;
        Erx # RecRead(837,1,0);
        if (Erx<_rLocked) then begin
          vHdl # $Ein.P.TextEditFuss->wpdbTextBuf;
          Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vHdl,Ein.Sprache);
          $Ein.P.TextEditFuss->WinUpdate(_WinUpdBuf2Obj);
          $Ein.P.TextEditFuss->wpcustom # myTmpText+'.501.F';
        end;
      end;

      $NB.Page1->wpdisabled # n;
      $NB.Page2->wpdisabled # n;
      $NB.Page3->wpdisabled # n;
      $NB.Page4->wpdisabled # n;
      $NB.Page5->wpdisabled # n;
      vTmp->wpcurrent # 'NB.Page1';
      Refreshifm();
      Refreshmode();
      if ($NB.Page1->wpcustom='NB.Page1_Art') then
        $edEin.P.Auftragsart->WinFocusSet(true)
      else
        $edEin.P.Auftragsart_Mat->WinFocusSet(true);
      RecInit(n); // neue Position belegen
      RETURN false;
    end;
  end;  // Kopf gesichert

  if (Mode=c_ModeNew2) or (Mode=c_ModeEdit) or (Mode=c_ModeEdit) then begin
    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_data:IstMixMat(Ein.p.Wgr.Dateinr)) then begin
      Ein.P.Menge.Wunsch  # Ein.P.Gewicht;
      Ein.P.MEH.Wunsch    # 'kg';
//      if (Wgr_data:IstMix(Ein.p.Wgr.Dateinr)=false) then begin  // 20.07.2021 AH: Menge editierbar
      if (Ein.P.MEH='kg') then
        Ein.P.Menge         # Ein.P.Gewicht
      else if (Ein.P.MEH='Stk') then
        Ein.P.Menge         # cnvfi("Ein.P.Stückzahl");
//        Ein.P.Menge         # Ein.P.Gewicht; 10.03.2022 AH
//        Ein.P.MEH           # 'kg';
//      end;
    end
    else begin
      "Ein.P.Stückzahl"   # 0;
      Ein.P.Gewicht       # 0.0;
      if (Ein.P.MEH.Wunsch='Stk') then  "Ein.P.Stückzahl" # cnvif(Ein.P.Menge.Wunsch);
      if (Ein.P.MEH.Wunsch='kg') then   Ein.P.Gewicht     # Ein.P.Menge.Wunsch;
      if (Ein.P.MEH.Wunsch='t') then    Ein.P.Gewicht     # Ein.P.Menge.Wunsch * 1000.0;
      if (Ein.P.Gewicht=0.0) then begin // 08.01.2015
        Ein.P.Gewicht # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", 0.0, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, 'kg');
      end;
      if (Ein.P.Gewicht=0.0) then begin
        Ein.P.Gewicht   # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Ein.P.Stückzahl", Ein.P.Dicke, Ein.P.Breite, "Ein.P.länge", Ein.P.Warengruppe, "Ein.P.Güte", Ein.P.Artikelnr);
      end;
      if ("Ein.P.Stückzahl"=0) then
        "Ein.P.Stückzahl" # Lib_Berechnungen:STK_aus_KgDBLWgrArt(Ein.P.Gewicht, Ein.P.Dicke, Ein.P.Breite, "Ein.P.länge", Ein.P.Warengruppe, "Ein.P.Güte", Ein.P.Artikelnr);
    end;
  end;

  if (Mode=c_ModeNew2) then begin
    // neue Position? -> temporär sichern **********************************

    Ein_Data:SumAufpreise(Mode);

    Erx # Ein_Data:PosInsert(0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      ErrorOutput;
      RETURN False;
    end;
    EinPTextSave();

    Erx # Lib_MoreBufs:SaveAll(501);
    if (Erx<>_rOK) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;


    // Materialdatei und Kundenartikelnr?
    if (Set.Ein.LfArtAnlegen='A') and (Ein.P.LieferArtNr<>'') and
      ((Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr))) then begin
      Erx # RecLink(100,500,1,_recFirst);  // Lieferant holen
      Adr.V.Adressnr      # Adr.Nummer;
      Adr.V.KundenArtNr   # Ein.P.LieferArtNr;
      Erx # RecRead(105,2,0);     // Verpackung testen
      if (Erx>=_rNoKey) then begin
        if (Msg(501006, '', _WinIcoQuestion, _WinDialogYesNo, 2) =_WinIdYes) then
          Ein_Data:Ein2Verpackung(y);
      end;
    end;


    // auf 1. Seite 1. Feld positionieren
    $NB.Main->wpcurrent # 'NB.Page1';
    if ($NB.Page1->wpcustom='NB.Page1_Art') then
      $edEin.P.Auftragsart->winfocusset(true)
    else
      $edEin.P.Auftragsart_Mat->winfocusset(true);

    if (Msg(000005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin

      vTmp # Dlg_Standard:PosErfassung(Set.Ein.Copy.AufprYN, Set.Ein.Copy.KalkYN);
      case (vTmp) of
        0     : RecInit(n);
        1     : RecInit(y);
        1+2   : RecInit(y,y,n);
        1+4   : RecInit(y,n,y);
        1+2+4 : RecInit(y,y,y);
      end;

      $RL.Aufpreise->winupdate(_winupdon,_WinLstFromFirst);
      $RL.Aufpreise_Mat->winupdate(_winupdon,_WinLstFromFirst);
      $lb.Position1->wpcaption # AInt(Ein.P.Position);
      $lb.Position1_Mat->wpcaption # AInt(Ein.P.Position);
      RETURN false;
    end
    else begin
      RETURN true;
    end;

    RETURN false;
  end;

  if (Mode=c_ModeList2) then begin
    // ganzen NEUEN Auftrag sichern *************************************

    TRANSON;        // Transaktionsstart

    // Anhängen??
    if (w_AppendNr<>0) then begin
      Ein.P.Nummer # w_AppendNr+1;
      Ein.P.Position # 1;
      Recread(501,1,0);
      RecRead(501,1,_recPrev);
      if (Ein.P.Nummer<>w_AppendNr) then begin
        TRANSBRK;
        RETURN false;
      end;
      vNummer # w_AppendNr;
      vPos # Ein.P.Position + 1;
    end
    else begin
      // Nummernvergabe
      vPos # 1;
      if (Ein.Vorgangstyp=c_Anfrage) then
        vNummer # Lib_Nummern:ReadNummer('Anfrage')
      else if (Ein.Vorgangstyp=c_VorlageAuf) then
        vNummer # Lib_Nummern:ReadNummer('Vorlageeinkauf')
      else
        vNummer # Lib_Nummern:ReadNummer('Einkauf');
        
      if (vNummer<>0) then Lib_Nummern:SaveNummer()
      else begin
        TRANSBRK;
        RETURN false;
      end;
    end;



    // Kopftexte kopieren
    TxtRename(myTmpText+'.501.K','~501.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K',0);
    TxtRename(myTmpText+'.501.F','~501.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F',0);


    Erx # RecLink(501,500,9,_RecFirst | _Reclock);
    WHILE (Erx=_ROk) do begin   // Positionen umnummerieren

      // ggf. neue VPG umbennen 25.03.2021
      if (Ein.Vorgangstyp=c_VorlageAuf) and (Ein.P.VerpackNr<>0) then begin
        RecBufClear(105);
        Adr.V.Adressnr        # Ein.P.VerpackAdrNr;
        Adr.V.lfdNr           # Ein.P.Verpacknr;
        Erx # RecRead(105,1,0);
        if (Erx<=_rLocked) then begin
          if (Adr.V.EinkaufYN) and (Adr.V.VorlageAuf=Ein.P.Nummer) and (Adr.V.VorlageAufPos=Ein.P.Position) then begin
            RecRead(105,1,_RecLock);
            Adr.V.VorlageAuf        # vNummer;
            RekReplace(105);
          end;
        end;
      end;

      // Texte ggf. umbenennen
      if (Ein.P.TextNr1=501) then begin // Idividuell
        TxtRename(myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3),'~501.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(vPos,_FmtNumLeadZero | _FmtNumNoGroup,0,3),0);
      end
      else begin
        TxtDelete('~501.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(vPos,_FmtNumLeadZero | _FmtNumNoGroup,0,3),0);
      end;

      // Internen Text umbenennen
      TxtRename(myTmpText+ '.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01','~501.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(vPos,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01',0);

                                // Kalkulation ggf. umnummerieren
      WHILE (RecLink(505,501,8,_recFirst)=_rOk) do begin
        RecRead(505,1,_Reclock);
        Ein.K.Nummer    # vNummer;
        Ein.K.Position  # vPos;
        Erx # Rekreplace(505,_recUnlock,'MAN');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          Msg(501505,gTitle,0,0,0);
          RETURN False;
        end;
      END;

                                // Aufpreise ggf. umnummerieren
      WHILE (RecLink(503,501,7,_recFirst)=_rOk) do begin
        RecRead(503,1,_Reclock);
        Ein.Z.Nummer    # vNummer;
        Ein.Z.Position  # vPos;
        Erx # Rekreplace(503,_recUnlock,'MAN');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          Msg(501503,gTitle,0,0,0);
          RETURN False;
        end;
      END;

                                // Ausführungen ggf. umnummerieren
      WHILE (RecLink(502,501,12,_recFirst)=_rOk) do begin
        RecRead(502,1,_Reclock);
        Ein.AF.Nummer   # vNummer;
        Ein.AF.Position # vPos;
        Erx # Rekreplace(502,_recUnlock,'MAN');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          Msg(501502,gTitle,0,0,0);
          RETURN False;
        end;
      END;


      Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
      Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
      if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
      if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
      Ein.P.Anlage.Datum  # today;
      Ein.P.Anlage.Zeit   # now;
      Ein.P.Anlage.User   # gUsername;

      Lib_MoreBufs:ReadAll(501);
      Lib_MoreBufs:Lock();

      Ein.P.Nummer # vNummer;     // Positionen umnummerieren
      Ein.P.Position # vPos;
      vPos # vPos + 1;
      Ein.P.Aktionsmarker # 'N';

      // ggf. Vorlage-Materialnr (Drag&Drop) merken, aber Feld leeren
      if (Ein.P.Materialnr>=0) then begin
        vMatNr # Ein.P.Materialnr;
        Ein.P.Materialnr # 0;
      end
      else begin
        Ein.P.Materialnr # -Ein.P.Materialnr; //04.03.2021 HACK SFX BFS
      end;

      Erx # Ein_Data:PosReplace(_reclock,'MAN');
      if (Erx<>_rOk) then begin
        Lib_MoreBufs:Unlock();
        TRANSBRK;
        ErrorOutput;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;

      Erx # Lib_MoreBufs:SaveAll(501);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;

      // Lohnbestellung...
      if (AAr.Nummer<>Ein.P.Auftragsart) then
        Erx # RekLink(835,501,5,_recFirst);   // Auftragsart holen
      if (AAr.Berechnungsart>=700) and (AAr.Berechnungsart<=799) then begin
        Ein_Data:UpdateBAG();
      end;


      if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
        // Materialkarten anlegen
        if (Ein_Data:UpdateMaterial(n)=false) then begin
          TRANSBRK;
          Msg(501200,gTitle,0,0,0);
          RETURN False;
        end;

        if (vMatNr<>0) then begin
          if (RunAFX('Ein.P.RecSave.MitMat',aint(vMatNr))<>0) then begin
            if (AfxRes<>_rOK) then begin
              // TRANSBRK in AFX !!!
              RETURN False;
            end;
          end;
        end;

      end
      else if ((Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr))) then begin

        // Artikelbestellung anlegen
        if (Ein_Data:UpdateArtikel(0.0)=false) then begin
          TRANSBRK;
          Msg(501250,gTitle,0,0,0);
          RETURN False;
        end;

        // Preisdatei ggf. anlegen
        if (Ein.Vorgangstyp=c_Bestellung) then begin
          RecLink(100,500,1,0);       // Lieferant holen
          if (Art_P_Data:LiesPreis('EK',Adr.Nummer)=false) then begin
            // neu anlegen
            Wae_Umrechnen(Ein.P.Grundpreis,"Ein.Währung",var vPreis, 1);
            Art_P_Data:SetzePreis('EK', vPreis, Adr.Nummer, Ein.P.PEH, Ein.P.MEH.Preis);
          end;
        end;

      end;


      Erx # Ein_Data:PosReplace(_recUnlock,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        ErrorOutput;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;


      // 22.10.2012 AI:
      if (Ein.Vorgangstyp<>c_Anfrage) and (Ein.Vorgangstyp<>c_Vorlageauf) and (Ein.P.Einzelpreis=0.0) then begin
Msg(99,'Einzelpreis ist NULL !!!',0,0,0);
      end;

      Ein.Nummer # myTmpNummer;
      Erx # RecLink(501,500,9,_RecFirst | _RecLock);
    END;  // Pos loopen


    // Kopfaufpreise kopieren
    Erx # RecLink(503,500,13,_RecFirst);
    WHILE (Erx=_rOK) do begin
      RecRead(503,1,_RecLock);
      Ein.Z.Nummer # vNummer;
      Erx # RekReplace(503,_recUnlock,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(501503,gTitle,0,0,0);
        RETURN False;
      end;
      Erx # RecLink(503,500,13,_RecFirst);
    END;


    // nicht anhängen? dann Kopf anlegen
    if (w_AppendNr=0) then begin
      Ein.Anlage.Datum # Today;
      Ein.Anlage.Zeit # now;
      Ein.Anlage.User # gUsername;
      Ein.Nummer # vNummer;         // Kopf sichern
      Erx # RekInsert(500,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;

    end
    else begin
      RecLink(500,501,3,_recFirst); // Kopf holen
      $NB.Kopf->wpdisabled # n;
    end;
    w_AppendNr # 0;



    // Fertige Positionen nochmals durchlaufen!
    FOR Erx # RecLink(501,500,9,_RecFirst)
    LOOP Erx # RecLink(501,500,9,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (Ein.P.Aktionsmarker<>'N') then CYCLE;

      // nur NEUE Positionen
      RecRead(501,1,_recLock);
      Ein.P.Aktionsmarker # '';
      Erx # Ein_Data:PosReplace(_Recunlock,'AUTO');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Ein.Nummer # myTmpNummer;
        if (Erx<999) then Msg(001000+Erx,gTitle,0,0,0);
        ErrorOutput;
        RETURN False;
      end;

      // Sonderfunktion:
      if (RunAFX('Ein.P.RecSave','')<>0) then begin
        if (AfxRes<>_rOk) then begin
          TRANSBRK;
          Ein.Nummer # myTmpNummer;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN False;
        end;
      end;

      Lib_Workflow:Trigger(501, 501, _WOF_KTX_NEU);
      // Abruf??
      if (Ein.AbrufYN) and (Ein.P.AbrufAufNr<>0) then begin
        vOk # Ein_Data:VerbucheAbruf(y);
        if (vOK=false) then begin
          TRANSBRK;
          Ein.Nummer # myTmpNummer;
          ErrorOutput;
          Msg(401401,AInt(Ein.P.Position),0,0,0);
          RETURN false;
        end;
      end;  // Abruf

    END;

    TRANSOFF;                 // Transaktionsende

    // Sperren prüfen...
    Ein_Data:SperrPruefung(0);

    // Sonderfunktion:
    RunAFX('Ein.P.RecSave.Post','');
    Lib_Workflow:Trigger(500, 500, _WOF_KTX_NEU);

    WarningOutput;      // 30.05.2018 AH: ggf. Warnmeldungen bringen
    
    // sofort drucken?
    if (Set.Ein.SofortDBstYN) then begin
      Ein_Subs:DruckBest();
    end;

    RETURN true;

  end;  // SAVE KOMPLETTEN AUFTRAG ****



  // temp.Position editieren ? -> temp. zurückspeichern *******************
  if (Mode=c_ModeEdit2) then begin

    Ein_Data:SumAufpreise(Mode);

    Erx # Ein_Data:PosReplace(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      ErrorOutput;
      RETURN False;
    end;

    Erx # Lib_MoreBufs:SaveAll(501);
    if (Erx<>_rOK) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    EinPTextSave();

  end;


  // Position editiert? -> zurückspeichern & protokolieren ****************
  if (Mode=c_ModeEdit) then begin
    if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) then begin
//  06.12.2019 AH: nicht immer KG!
//      Ein.P.Menge.Wunsch  # Ein.P.Gewicht;
//      Ein.P.Menge         # Ein.P.Gewicht;
      Ein.P.Menge.Wunsch # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, 0.0, '', Ein.P.MEH.Wunsch);
      Ein.P.Menge        # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, 0.0, '', Ein.P.MEH);
    end;

    Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
    Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
    if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
    if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;

    TRANSON;

    Ein_Data:SumAufpreise(c_Modesave);    // 23.07.2019 früher MODE

    // Projekt 1337/151
/*
    if (Ein.P.Wgr.Dateinr>=c_Wgr_Material) and (Ein.P.Wgr.Dateinr<=c_Wgr_bisMaterial) then begin
      // Materialkarten anlegen
      if (Ein_Data:UpdateMaterial()=false) then begin
        TRANSBRK;
        ErrorOutput;
        Msg(501200,gTitle,0,0,0);
        RETURN False;
      end;
    end
    else **/

    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then begin
      // Artikelbestellung anlegen
      if (Ein_Data:UpdateArtikel(FldFloat(ProtokollBuffer[501],2,7))=false) then begin
        TRANSBRK;
        Msg(501250,gTitle,0,0,0);
        RETURN False;
      end;
    end;

    // Lohnbestellung...
    if (AAr.Nummer<>Ein.P.Auftragsart) then
      Erx # RekLink(835,501,5,_recFirst);   // Auftragsart holen
    if (AAr.Berechnungsart>=700) and (AAr.Berechnungsart<=799) then begin
      Ein_Data:UpdateBAG();
    end;

    Erx # Ein_Data:PosReplace(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      if (Erx<999) then Msg(001000+Erx,gTitle,0,0,0);
      ErrorOutput;
      RETURN False;
    end;


    Erx # Lib_MoreBufs:SaveAll(501, true);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    vBuf501 # RecBufCreate(501);
    RecBufCopy(ProtokollBuffer[501],vBuf501);

    // 22.10.2012 AI:
    if (Ein.P.Einzelpreis=0.0) then begin
Msg(99,'Einzelpreis ist NULL !!!',0,0,0);
    end;

    Erx # RekReplace(500,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // 09.09.2016
    Ein_Data:VererbeKopfReferenzInPos(ProtokollBuffer[500]->Ein.AB.Nummer, Ein.AB.Nummer);

    // Müssen ALLE Karten refreshed werden?
    vMatUpd # (ProtokollBuffer[500]->Ein.Lieferadresse<>Ein.Lieferadresse) or
              (ProtokollBuffer[500]->Ein.Lieferanschrift<>Ein.Lieferanschrift);
    PtD_Main:Compare(501);
    PtD_Main:Compare(500);

    // Text speichern
    if (Ein.P.TextNr1<>501) then begin // NICHT Individuell ?
      TxtDelete('~501.'+CnvAI(vNummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3),0);
    end;
    EinPTextSave();


    // 21.06.2012 AI: Projekt 1337/151 ALLE Materialien updaten
    if (vMatUpd) then begin
      Erx # RecLink(501,500,9,_recFirst);
      WHILE (Erx<=_rLocked) do begin

        if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
          // Materialkarten anlegen
          if (Ein_Data:UpdateMaterial(n)=false) then begin
            TRANSBRK;
            ErrorOutput;
            Msg(501200,gTitle,0,0,0);
            RETURN False;
          end;
        end;

        Erx # RecLink(501,500,9,_recNext);
      END;
      RecBufCopy(vBuf501,501);
      Recread(501,1,0);
    end
    else begin
      if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
        // Materialkarten anlegen
        if (Ein_Data:UpdateMaterial(n)=false) then begin
          TRANSBRK;
          ErrorOutput;
          Msg(501200,gTitle,0,0,0);
          RETURN False;
        end;
      end;
    end;


    // Sonderfunktion:
    if (RunAFX('Ein.P.RecSave','')<>0) then begin
      if (AfxRes<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
    end;

    // Abruf??
    if (Ein.AbrufYN) and (Ein.P.AbrufAufNr<>0) then begin
      vOk # Ein_Data:VerbucheAbruf(n);
      if (vOK=false) then begin
        TRANSBRK;
        ErrorOutput;
        Msg(401401,CnvAI(Ein.P.Position),0,0,0);
        RETURN false;
      end;
    end;  // Abruf

    TRANSOFF;

    // Seprre prüfen...
    Ein_Data:SperrPruefung(vBuf501);
    RecBufDestroy(vBuf501);

    // Sonderfunktion:
    RunAFX('Ein.P.RecSave.Post','');

    WarningOutput;      // 30.05.2018 AH: ggf. Warnmeldungen bringen

  end;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei Abbruch der Erfassung
//========================================================================
sub RecCleanup() : logic;
local begin
  Erx : int;
end;
begin

  if (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then begin
    Lib_MoreBufs:Unlock();
    // diese veränderte Position verwerfen
    PtD_Main:Forget(500);
    RecRead(500,1,_RecUnlock);
  end
  else if (Ein.Nummer>1000000000) and (mode=c_ModeList2) then begin
    TRANSON;
    // kompletten Auftrag verwerfen
    Erx # RecLink(501,500,9,_RecFirst | _Reclock);
    WHILE (Erx=_ROk) do begin   // Positionen entfernen
      TxtDelete(myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3),0);
      TxtDelete(myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01',0);
      RekDelete(501,0,'MAN');

      if (Lib_MoreBufs:DeleteAll(501)<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;

      Erx # RecLink(501,500,9,_RecFirst | _Reclock);
    END;
    TxtDelete(myTmpText+'.501.K',0);
    TxtDelete(myTmpText+'.501.F',0);
                                // Ausführungen löschen
    WHILE (RecLink(502,500,16,_recFirst)=_rOk) do begin
      RekDelete(502,0,'MAN');
    END;
                                // Aufpreise löschen
    WHILE (RecLink(503,500,13,_recFirst)=_rOk) do begin
      RekDelete(503,0,'MAN');
    END;
                                // Aktionen löschen
    WHILE (RecLink(504,500,15,_recFirst)=_rOk) do begin
      RekDelete(504,0,'MAN');
    END;
                                // Kalkulation löschen
    WHILE (RecLink(505,500,14,_recFirst)=_rOk) do begin
      RekDelete(505,0,'MAN');
    END;

    TRANSOFF;

    $NB.Page1->wpdisabled # n;
    $NB.Page2->wpdisabled # n;
    $NB.Page3->wpdisabled # n;
    $NB.Page4->wpdisabled # n;
    $NB.Page5->wpdisabled # n;
    //1212 $NB.KopfText->wpdisabled # n;
    //1212 $NB.Fusstext->wpdisabled # n;

    if (w_appendNr<>0) then begin
      $NB.Kopf->wpdisabled # n;
      w_AppendNr # 0;
    end;

  end
  else if (Ein.Nummer>1000000000) and (mode=c_ModeNew2) then begin

    TxtDelete(myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3),0);
    TxtDelete(myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01',0);

                                // Ausführungen löschen
    WHILE (RecLink(502,501,12,_recFirst)=_rOk) do begin
      RekDelete(502,0,'MAN');
    END;
                                // Aufpreise löschen
    WHILE (RecLink(503,501,7,_recFirst)=_rOk) do begin
      RekDelete(503,0,'MAN');
    END;
                                // Aktionen löschen
    WHILE (RecLink(504,501,15,_recFirst)=_rOk) do begin
      RekDelete(504,0,'MAN');
    END;
                                // Kalkulation löschen
    WHILE (RecLink(505,501,8,_recFirst)=_rOk) do begin
      RekDelete(505,0,'MAN');
    END;
    $NB.Page1->wpdisabled # n;
    $NB.Page2->wpdisabled # n;
    $NB.Page3->wpdisabled # n;
    $NB.Page4->wpdisabled # n;
    $NB.Page5->wpdisabled # n;
    //1212 $NB.KopfText->wpdisabled # n;
    //1212 $NB.Fusstext->wpdisabled # n;
  end;

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  vTmp  : int;
end;
begin

  // AFX
  if (RunAFX('Ein.P.RecDel.Pre','')<>0) then begin
    if (AfxRes<>_rOK) then RETURN;
  end;


  vTmp # gMdi->Winsearch('NB.Main');      // während Erfassung löschen?
  if (vTmp->wpcurrent='NB.Erfassung') then begin
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

      TRANSON;
                                // Ausführungen löschen
      WHILE (RecLink(502,501,12,_recFirst)=_rOk) do begin
        RekDelete(502,0,'MAN');
      END;
                                // Aufpreise löschen
      WHILE (RecLink(503,501,7,_recFirst)=_rOk) do begin
        RekDelete(503,0,'MAN');
      END;
                                // Aktionen löschen
      WHILE (RecLink(504,501,15,_recFirst)=_rOk) do begin
        RekDelete(504,0,'MAN');
      END;
                                // Kalkulation löschen
      WHILE (RecLink(505,501,8,_recFirst)=_rOk) do begin
        RekDelete(505,0,'MAN');
      END;
      RekDelete(501,0,'MAN');   // Position löschen

      if (Lib_MoreBufs:DeleteAll(501)<>_rOK) then begin
        TRANSBRK;
        RETURN;
      end;

      TRANSOFF;

      $ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
    end;
    RETURN;
  end;


  if (Ein_P_Subs:ToggleLoeschmarker(y)=n) then begin
    if (AfxRes<999) and (AfxRes<>0) then Msg(401000,cnvai(AfxRes),0,0,0);
    ErrorOutput;
    RETURN;
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
  vFocus  : alpha;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  vFocus # aEvt:Obj->wpname;

  if (vFocus='jump') then begin

    case (aEvt:Obj->wpcustom) of
      'MainStart' : begin
        if ($NB.Page1->wpcustom='NB.Page1_Art') then
          $edEin.P.Auftragsart->winfocusset(true)
        else
          $edEin.P.Auftragsart_Mat->winfocusset(true);
      end;
      'vorMain' : begin
        if ($NB.Page1->wpcustom='NB.Page1_Art') then
          $edEin.P.Auftragsart->winfocusset(true)
        else
          $edEin.P.Auftragsart_Mat->winfocusset(true);
        if ($NB.Page1->wpcustom='NB.Page1_Art') then begin
          $NB.Main->wpcurrent # 'NB.Page2';
          $cb.Text3->winfocusset(true);
        end
        else begin
          $NB.Main->wpcurrent # 'NB.Page5';
          $edEin.P.VpgText62->winfocusset(false);
//          $edEin.P.Chemie.B2->winfocusset(true);
        end;
//          Refreshifm();
      end;
      'nachMain' : begin
        if ($NB.Page1->wpcustom='NB.Page1_Art') then
          $edEin.P.Termin.Zusatz->winfocusset(true)
        else
          $edEin.P.Termin.Zusatz_Mat->winfocusset(true);
        $NB.Main->wpcurrent # 'NB.Page2';
        $cb.Text1->winfocusset(true);
      end;


      'TextStart' : begin
        $cb.Text1->winfocusset(True);
      end;
      'vorText' : begin
        $cb.Text1->winfocusset(true);
        $NB.Main->wpcurrent # 'NB.Page1';
        if ($NB.Page1->wpcustom='NB.Page1_Art') then
          $edEin.P.Termin.Zusatz->winfocusset(true)
        else
          $edEin.P.Termin.Zusatz_Mat->winfocusset(true);
      end;
      'nachText' : begin
        $cb.Text3->winfocusset(true);
        if ($NB.Page1->wpcustom='NB.Page1_Art') then begin
          $NB.Main->wpcurrent # 'NB.Page1';
          $edEin.P.Auftragsart->Winfocusset(true)
        end
        else begin
          $NB.Main->wpcurrent # 'NB.Page3';
          $edEin.P.Verpacknr->winfocusset();
        end;
      end;

      'VerpackungStart' : begin
        $edEin.P.Verpacknr->WinFocusset(true);
      end;
      'vorVerpackung' : begin
        $edEin.P.Verpacknr->WinFocusset(true);
        $NB.Main->wpcurrent # 'NB.Page2';
        $cb.Text3->WinFocusset(true);
      end;
      'nachVerpackung' : begin
        $edEin.P.VpgText6->WinFocusset(true);
        $NB.Main->wpcurrent # 'NB.Page4';
        $edEin.P.Streckgrenze1->WinFocusset(true);
      end;

      'AnalyseStart' : begin
        $edEin.P.Streckgrenze1->WinFocusset(true);
      end;
      'vorAnaylse' : begin
        $edEin.P.Streckgrenze1->WinFocusset(true);
        $NB.Main->wpcurrent # 'NB.Page3';
        $edEin.P.VpgText6->WinFocusset(true);
      end;
      'nachAnalyse' : begin
        $edEin.P.Chemie.B2->WinFocusset(true);
        $NB.Main->wpcurrent # 'NB.Page5';
        $edEin.P.Etikettentyp2->winfocusset(false);
      end;

      'EtikettierungStart' : begin
        $edEin.P.Etikettentyp2->winfocusset(false);
       end;
      'vorEtikettierung' : begin
        $edEin.P.Etikettentyp2->winfocusset(false);
        if ($NB.Page1->wpcustom='NB.Page1_Art') then begin
          $NB.Main->wpcurrent # 'NB.Page2';
          $cb.Text3->winfocusset(true);
        end
        else begin
          $NB.Main->wpcurrent # 'NB.Page4';
          $edEin.P.Chemie.Frei1.2->winfocusset(false);
        end;
//        Refreshifm();
      end;
      'nachEtikettierung' : begin
        $edEin.P.VpgText62->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        if ($NB.Page1->wpcustom='NB.Page1_Art') then
          $edEin.P.Auftragsart->WinFocusset(true)
        else
          $edEin.P.Auftragsart_Mat->WinFocusset(true);
      end;

    end;

    RETURN true;
  end;

  // Auswahlfelder aktivieren
  if ((vFocus='edEin.P.Grundpreis') and (Ein.P.ArtikelNr<>'')) or
    (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj, y)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj)
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
  vFocus  : alpha;
  vGew    : float;
  vStk    : int;
  vM      : float;
  vOK     : logic;
end;
begin
  vFocus # aEvt:Obj->wpname;

  // Ankerfunktion
  RunAFX('Ein.P.EvtFocusTerm',vFocus);

  if (aEvt:obj->wpname='edEin.P.AusfOben_Mat') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','501|1|'+aint(aEvt:obj));
  if (aEvt:obj->wpname='edEin.P.AusfUnten_Mat') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','501|2|'+aint(aEvt:obj));

  if ((aEvt:obj->wpname=^'cbEin.AbrufYN') or
    (aEvt:obj->wpname=^'cbEin.PAbrufYN')) and (aEvt:Obj->wpchanged) then begin
    vOK # aEvt:Obj->wpCheckState=_WinStateChkChecked;
    if (vOK=false) then begin
      Ein.P.AbrufAufNr  # 0;
      Ein.P.AbrufAufPos # 0;
    end;
    Lib_GuiCom:Able($edEin.P.AbrufAufNr, vOK);
    Lib_GuiCom:Able($edEin.P.AbrufAufPos, vOK);
    Lib_GuiCom:Able($bt.Abruf, vOK);
    Lib_GuiCom:Able($edEin.P.AbrufAufNr_Mat, vOK);
    Lib_GuiCom:Able($edEin.P.AbrufAufPos_Mat, vOK);
    Lib_GuiCom:Able($bt.Abruf_Mat, vOK);
  end;

  
  if (vFocus='edEin.P.TextNr2') or (vFocus='edEin.P.TextNr2b') then begin
    if (Ein.P.TextNr1=500) then
      Ein.P.TextNr2 # $edEin.P.TextNr2->wpcaptionint;
    if (Ein.P.TextNr1=0) then
      Ein.P.TextNr2 # $edEin.P.TextNr2b->wpcaptionint;
  end;
  // logische Prüfung von Verknüpfungen
  RefreshIfm(vFocus);

  if (vFocus='edEin.Vorgangstyp') then begin
    Lib_GuiCom:Able($edEin.GltigkeitVom, Ein.LiefervertragYN or (Ein.Vorgangstyp=c_Anfrage));
    Lib_GuiCom:Able($edEin.GltigkeitBis, Ein.LiefervertragYN or (Ein.Vorgangstyp=c_Anfrage));
    Lib_GuiCom:Able($cbEin.AbrufYN, Ein.Vorgangstyp=c_Bestellung and Mode=c_ModeNew);
    Lib_GuiCom:Able($cbEin.LiefervertragYN, Ein.Vorgangstyp=c_Bestellung and Mode=c_ModeNew);
    Lib_GuiCom:Able($edEin.P.Kommission,  Ein.Vorgangstyp<>c_Vorlageauf and Mode=c_ModeNew);
    Lib_GuiCom:Able($edEin.P.Kommission_Mat,  Ein.Vorgangstyp<>c_Vorlageauf and Mode=c_ModeNew);
    Lib_GuiCom:Able($bt.Kommission,       Ein.Vorgangstyp<>c_Vorlageauf and Mode=c_ModeNew);
    Lib_GuiCom:Able($bt.Kommission_Mat,   Ein.Vorgangstyp<>c_Vorlageauf and Mode=c_ModeNew);
    if (Ein.Vorgangstyp=c_Anfrage) then begin
      if ((aFocusObject=$cbEinAbrufYN) or (aFocusObject=$cbEin.LiefervertragYN)) then
        WinFocusSet($edEin.GltigkeitVom,y)
    end
    else begin
      if ((aFocusObject=$edEin.GltigkeitVom) or (aFocusObject=$edEin.GltigkeitBis)) and
        (Ein.LiefervertragYN=false) then
        Winfocusset($cbEin.AbrufYN, true);
    end;
  end


  if (vFocus='cbEin.AbrufYN') then begin
    if (Ein.AbrufYN=n) then begin
      Lib_GuiCom:Enable($edEin.P.Warengruppe);
      Lib_GuiCom:Enable($bt.Warengruppe);

//      Lib_GuiCom:Disable($edEin.P.AbrufAufNr);
//      Lib_GuiCom:Disable($edEin.P.AbrufAufPos);
//      Lib_GuiCom:Disable($bt.Abruf);
//      Lib_GuiCom:Disable($edEin.P.AbrufAufNr_Mat);
//      Lib_GuiCom:Disable($edEin.P.AbrufAufPos_Mat);
//      Lib_GuiCom:Disable($bt.Abruf_Mat);

      Lib_GuiCom:Enable($edEin.P.Artikelnr);
      Lib_GuiCom:Enable($bt.Artikelnummer);
      Lib_GuiCom:Enable($edEin.P.LieferArtNr);
      Lib_GuiCom:Enable($bt.LieferArtNr);
      Lib_GuiCom:Enable($edEin.P.MEH.Wunsch);
      Lib_GuiCom:Enable($bt.MEH);

      Lib_GuiCom:Enable($edEin.P.Warengruppe_Mat);
      Lib_GuiCom:Enable($bt.Warengruppe_Mat);
    end
    else begin
      Lib_GuiCom:Disable($edEin.P.Warengruppe);
      Lib_GuiCom:Disable($bt.Warengruppe);

//      Lib_GuiCom:Enable($edEin.P.AbrufAufNr);
//      Lib_GuiCom:Enable($edEin.P.AbrufAufPos);
//      Lib_GuiCom:Enable($bt.Abruf);
//      Lib_GuiCom:Enable($edEin.P.AbrufAufNr_Mat);
//      Lib_GuiCom:Enable($edEin.P.AbrufAufPos_Mat);
//      Lib_GuiCom:Enable($bt.Abruf_Mat);

      Lib_GuiCom:Disable($edEin.P.Artikelnr);
      Lib_GuiCom:Disable($bt.Artikelnummer);
      Lib_GuiCom:Disable($edEin.P.LieferArtNr);
      Lib_GuiCom:Disable($bt.LieferArtNr);
      Lib_GuiCom:Disable($edEin.P.MEH.Wunsch);
      Lib_GuiCom:Disable($bt.MEH);

      Lib_GuiCom:Disable($edEin.P.Warengruppe_Mat);
      Lib_GuiCom:Disable($bt.Warengruppe_Mat);

    end;
  end;

  if (vFocus='cbEin.WaehrungFixYN') then begin
    if ("Ein.WährungFixYN"=n) then begin
      "Ein.Währungskurs" # 0.0;
      Refreshifm('edEin.Waehrungskurs')
    end;
  end;

  if (vFocus='edEin.P.Warengruppe') then begin//and ($edEin.P.Warengruppe->wpchanged) then begin
    if (Ein_P_SMain:Switchmask(y)) then begin
      $edEin.P.Warengruppe_Mat->winfocusset(true);
      RETURN false;
    end;
  end;
  if (vFocus='edEin.P.Warengruppe_Mat') then begin //and ($edEin.P.warengruppe_Mat->wpchanged) then begin
    if (Ein_P_SMain:Switchmask(y)) then begin
      $edEin.P.Warengruppe->winfocusset(true);
      RETURN false;
    end;
  end;

  if (vFocus='edEin.AB.Nummer') and (Ein.AB.Nummer <> '') and
    ($edEin.AB.Nummer->wpchanged) and (Ein.AB.Datum=0.0.0) then begin
    Ein.AB.Datum # today;
  end;

  if (vFocus='edEin.P.Laenge_Mat') and ($edEin.P.Laenge_Mat->wpchanged) then begin
    if ("Ein.P.Länge"<>0.0) then begin
//      Ein.P.RID     # 0.0;
//      Ein.P.RIDmax  # 0.0;
//      Ein.P.RAD     # 0.0;
//      Ein.P.RADmax  # 0.0;
//      $edEin.P.RID_Mat->winupdate(_WinUpdFld2Obj);
//      $edEin.P.RIDmax_Mat->winupdate(_WinUpdFld2Obj);
//      $edEin.P.RAD_Mat->winupdate(_WinUpdFld2Obj);
//      $edEin.P.RADmax_Mat->winupdate(_WinUpdFld2Obj);
//      Lib_GuiCom:Disable($edEin.P.RID_Mat);
//      Lib_GuiCom:Disable($edEin.P.RIDMax_Mat);
//      Lib_GuiCom:Disable($edEin.P.RAD_Mat);
//      Lib_GuiCom:Disable($edEin.P.RADMax_Mat);
    end
    else begin
//      Lib_GuiCom:Enable($edEin.P.RID_Mat);
//      Lib_GuiCom:Enable($edEin.P.RIDMax_Mat);
//      Lib_GuiCom:Enable($edEin.P.RAD_Mat);
//      Lib_GuiCom:Enable($edEin.P.RADMax_Mat);
    end;
  end;

  if ((vFocus='edEin.P.Termin1W.Zahl') or (vFocus='edEin.P.Termin1W.Jahr')) and
    (($edEin.P.Termin1W.Zahl->wpchanged) or ($edEin.P.Termin1W.Jahr->wpchanged)) then begin
    Lib_Berechnungen:Datum_aus_ZahlJahr(Ein.P.Termin1W.Art, var Ein.P.Termin1W.Zahl, var Ein.P.Termin1W.Jahr, var Ein.P.Termin1Wunsch);
    Ein.P.Termin1Wunsch->vmdaymodify(Set.Ein.Term.AutoTag);
    $edEin.P.Termin1W.Zahl->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin1W.Jahr->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin1Wunsch->winupdate(_WinUpdFld2Obj);
  end;
  if (vFocus='edEin.P.Termin1Wunsch') and
    ($edEin.P.Termin1Wunsch->wpchanged) then begin
    Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.P.Termin1Wunsch, Ein.P.Termin1W.Art, var Ein.P.Termin1W.Zahl,var Ein.P.Termin1W.Jahr);
    $edEin.P.Termin1W.Zahl->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin1W.Jahr->winupdate(_WinUpdFld2Obj);
  end;

  if ((vFocus='edEin.P.Termin2W.Zahl') or (vFocus='edEin.P.Termin2W.Jahr')) and
    (($edEin.P.Termin2W.Zahl->wpchanged) or ($edEin.P.Termin2W.Jahr->wpchanged)) then begin
    Lib_Berechnungen:Datum_aus_ZahlJahr(Ein.P.Termin1W.Art,  var Ein.P.Termin2W.Zahl, var Ein.P.Termin2W.Jahr, var Ein.P.Termin2Wunsch);
    Ein.P.Termin2Wunsch->vmdaymodify(Set.Ein.Term.AutoTag);
    $edEin.P.Termin2W.Zahl->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin2W.Jahr->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin2Wunsch->winupdate(_WinUpdFld2Obj);
  end;
  if (vFocus='edEin.P.Termin2Wunsch') and
    ($edEin.P.Termin2Wunsch->wpchanged) then begin
    Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.P.Termin2Wunsch, Ein.P.Termin1W.Art, var Ein.P.Termin2W.Zahl,var Ein.P.Termin2W.Jahr);
    $edEin.P.Termin2W.Zahl->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin2W.Jahr->winupdate(_WinUpdFld2Obj);
  end;

  if ((vFocus='edEin.P.TerminZ.Zahl') or (vFocus='edEin.P.TerminZ.Jahr')) and
    (($edEin.P.TerminZ.Zahl->wpchanged) or ($edEin.P.TerminZ.Jahr->wpchanged)) then begin
    Lib_Berechnungen:Datum_aus_ZahlJahr(Ein.P.Termin1W.Art, var Ein.P.TerminZ.Zahl, var Ein.P.TerminZ.Jahr, var Ein.P.TerminZusage);
    Ein.P.TerminZusage->vmdaymodify(Set.Ein.Term.AutoTag);
    $edEin.P.TerminZ.Zahl->winupdate(_WinUpdFld2Obj);
    $edEin.P.TerminZ.Jahr->winupdate(_WinUpdFld2Obj);
    $edEin.P.TerminZusage->winupdate(_WinUpdFld2Obj);
  end;
  if (vFocus='edEin.P.TerminZusage') and
    ($edEin.P.TerminZusage->wpchanged) then begin
    Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.P.TerminZusage, Ein.P.Termin1W.Art, var Ein.P.TerminZ.Zahl,var Ein.P.TerminZ.Jahr);
    $edEin.P.TerminZ.Zahl->winupdate(_WinUpdFld2Obj);
    $edEin.P.TerminZ.Jahr->winupdate(_WinUpdFld2Obj);
  end;

  if ((vFocus='edEin.P.Termin1W.Zahl_Mat') or (vFocus='edEin.P.Termin1W.Jahr_Mat')) and
    (($edEin.P.Termin1W.Zahl_Mat->wpchanged) or ($edEin.P.Termin1W.Jahr_Mat->wpchanged)) then begin
    Lib_Berechnungen:Datum_aus_ZahlJahr(Ein.P.Termin1W.Art,  var Ein.P.Termin1W.Zahl,var  Ein.P.Termin1W.Jahr, var Ein.P.Termin1Wunsch);
    Ein.P.Termin1Wunsch->vmdaymodify(Set.Ein.Term.AutoTag);
    $edEin.P.Termin1W.Zahl_Mat->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin1W.Jahr_Mat->Winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin1Wunsch_Mat->winupdate(_WinUpdFld2Obj);
  end;
  if (vFocus='edEin.P.Termin1Wunsch_Mat') and
    ($edEin.P.Termin1Wunsch_Mat->wpchanged) then begin
    Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.P.Termin1Wunsch, Ein.P.Termin1W.Art, var Ein.P.Termin1W.Zahl,var Ein.P.Termin1W.Jahr);
    $edEin.P.Termin1W.Zahl_Mat->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin1W.Jahr_Mat->winupdate(_WinUpdFld2Obj);
  end;

  if ((vFocus='edEin.P.Termin2W.Zahl_Mat') or (vFocus='edEin.P.Termin2W.Jahr_Mat')) and
    (($edEin.P.Termin2W.Zahl_Mat->wpchanged) or ($edEin.P.Termin2W.Jahr_Mat->wpchanged)) then begin
    Lib_Berechnungen:Datum_aus_ZahlJahr(Ein.P.Termin1W.Art,  var Ein.P.Termin2W.Zahl, var Ein.P.Termin2W.Jahr, var Ein.P.Termin2Wunsch);
    Ein.P.Termin2Wunsch->vmdaymodify(Set.Ein.Term.AutoTag);
    $edEin.P.Termin2W.Zahl_Mat->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin2W.Jahr_Mat->Winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin2Wunsch_Mat->winupdate(_WinUpdFld2Obj);
  end;
  if (vFocus='edEin.P.Termin2Wunsch_Mat') and
    ($edEin.P.Termin2Wunsch_Mat->wpchanged) then begin
    Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.P.Termin2Wunsch, Ein.P.Termin1W.Art, var Ein.P.Termin2W.Zahl,var Ein.P.Termin2W.Jahr);
    $edEin.P.Termin2W.Zahl_Mat->winupdate(_WinUpdFld2Obj);
    $edEin.P.Termin2W.Jahr_Mat->winupdate(_WinUpdFld2Obj);
  end;

  if ((vFocus='edEin.P.TerminZ.Zahl_Mat') or (vFocus='edEin.P.TerminZ.Jahr_Mat')) and
    (($edEin.P.TerminZ.Zahl_Mat->wpchanged) or ($edEin.P.TerminZ.Jahr_Mat->wpchanged)) then begin
    Lib_Berechnungen:Datum_aus_ZahlJahr(Ein.P.Termin1W.Art, var Ein.P.TerminZ.Zahl, var Ein.P.TerminZ.Jahr, var Ein.P.TerminZusage);
    Ein.P.TerminZusage->vmdaymodify(Set.Ein.Term.AutoTag);
    $edEin.P.TerminZ.Zahl_Mat->winupdate(_WinUpdFld2Obj);
    $edEin.P.TerminZ.Jahr_Mat->Winupdate(_WinUpdFld2Obj);
    $edEin.P.TerminZusage_Mat->winupdate(_WinUpdFld2Obj);
  end;
  if (vFocus='edEin.P.TerminZusage_Mat') and
    ($edEin.P.TerminZusage_Mat->wpchanged) then begin
    Lib_Berechnungen:ZahlJahr_aus_Datum( Ein.P.TerminZusage, Ein.P.Termin1W.Art, var Ein.P.TerminZ.Zahl,var Ein.P.TerminZ.Jahr);
    $edEin.P.TerminZ.Zahl_Mat->winupdate(_WinUpdFld2Obj);
    $edEin.P.TerminZ.Jahr_Mat->winupdate(_WinUpdFld2Obj);
  end;

  if (vFocus='edEin.P.Preis.MEH_Mat') and ($edEin.P.Preis.MEH_Mat->wpchanged) then begin
    Lib_Einheiten:CheckMEH(var Ein.P.MEH.Preis);
    $edEin.P.Preis.MEH_Mat->winupdate(_WinUpdFld2Obj);
  end;
  if (vFocus='edEin.P.MEH.Preis') and ($edEin.P.MEH.Preis->wpchanged) then begin
    Lib_Einheiten:CheckMEH(var Ein.P.MEH.Preis);
    $edEin.P.MEH.Preis->winupdate(_WinUpdFld2Obj);
  end;
  if (vFocus='edEin.P.MEH.Wunsch') and ($edEin.P.MEH.Wunsch->wpchanged) then begin
    Lib_Einheiten:CheckMEH(var Ein.P.MEH.Wunsch);
    $edEin.P.MEH.Wunsch->winupdate(_WinUpdFld2Obj);
    Ein.P.Menge # Lib_Einheiten:WandleMEH(501, 0, 0.0, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Ein.P.MEH);
    Refreshifm('edEin.P.Menge');
  end;

  if (vFocus='edEin.P.Stueckzahl_Mat') and ($edEin.P.Stueckzahl_Mat->wpchanged) then begin
   if (StrFind(Set.Ein.Calc.Menge,'K',1)>0) or
      (("Ein.P.Stückzahl"<>0) and (Ein.P.Gewicht=0.0) and (StrFind(Set.Ein.Calc.Menge,'G',1)>0)) then begin
      //vGew # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Ein.P.Stückzahl", Ein.P.Dicke, Ein.P.Breite, "Ein.P.länge", Ein.P.Warengruppe, "Ein.P.Güte", Ein.P.Artikelnr);
      vGew # Ein_P_Subs:CalcGewicht();  // 22.06.2022 AH
      if (vGew<>0.0) then begin
        Ein.P.Gewicht # Rnd(vGew, Set.Stellen.Gewicht);
        $edEin.P.Gewicht_Mat->winupdate(_WinUpdFld2Obj);
      end;
    end;
    if ("Ein.P.Stückzahl"<>0) and (Ein.P.Menge=0.0) then begin    // 22.07.2021 AH: Menge editierbar
      vM # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", 0.0, 0.0, '', Ein.P.MEH);
      if (vM<>0.0) then begin
        Ein.P.Menge # vM;
        $edEin.P.Menge_Mat->winupdate(_WinUpdFld2Obj);
      end;
    end;
  end;

  if (vFocus='edEin.P.Gewicht_Mat') and ($edEin.P.Gewicht_Mat->wpchanged) then begin
    if (StrFind(Set.Ein.Calc.Menge,'K',1)>0) or
      (("Ein.P.Stückzahl"=0) and (Ein.P.Gewicht<>0.0) and (StrFind(Set.Ein.Calc.Menge,'S',1)>0)) then begin
      vStk # Lib_Berechnungen:STK_aus_KgDBLWgrArt(Ein.P.Gewicht, Ein.P.Dicke, Ein.P.Breite, "Ein.P.länge", Ein.P.Warengruppe, "Ein.P.Güte", Ein.P.Artikelnr);
      if (vStk<>0) then begin
        "Ein.P.Stückzahl" # vStk;
        $edEin.P.Stueckzahl_Mat->winupdate(_WinUpdFld2Obj);
      end;
    end;
    if ("Ein.P.Gewicht"<>0.0) and (Ein.P.Menge=0.0) then begin
      vM # Lib_Einheiten:WandleMEH(501, 0, Ein.P.Gewicht, 0.0, '', Ein.P.MEH);
      if (vM<>0.0) then begin
        Ein.P.Menge # vM;
        $edEin.P.Menge_Mat->winupdate(_WinUpdFld2Obj);
      end;
    end;
  end;


  if (vFocus='edEin.P.Menge_Mat') and ($edEin.P.Menge_Mat->wpchanged) and (Ein.P.Menge<>0.0) then begin
    if ("Ein.P.Stückzahl"=0)  then begin
      vStk # cnvif(Lib_Einheiten:WandleMEH(501, 0, 0.0, Ein.P.Menge, Ein.P.MEH, 'Stk'));
      if (vStk<>0) then begin
        "Ein.P.Stückzahl" # vStk;
        $edEin.P.Stueckzahl_Mat->winupdate(_WinUpdFld2Obj);
      end;
    end;
    if ("Ein.P.Gewicht"=0.0) then begin
      vGew # Lib_Einheiten:WandleMEH(501, 0, 0.0, Ein.P.Menge, Ein.P.MEH, 'kg');
      if (vGew<>0.0) then begin
        Ein.P.Gewicht # Rnd(vGew, Set.Stellen.Gewicht);
        $edEin.P.Gewicht_Mat->winupdate(_WinUpdFld2Obj);
      end;
    end;
  end;


  if (vFocus='edEin.P.Menge.Wunsch') and (Ein.P.Menge=0.0) then begin
    Ein.P.Menge # Lib_Einheiten:WandleMEH(501, 0, 0.0, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Ein.P.MEH);
    Refreshifm('edEin.P.Menge');
  end;

  if (vFocus='edEin.P.Menge.Wunsch') or (vFocus='edEin.P.MEH.Wunsch') or (vFocus='edEin.P.MEH.Wunsch_Mat') then begin
    if (Ein.P.MEH.Wunsch=Ein.P.MEH) then begin
      Ein.P.Menge # Ein.P.Menge.Wunsch;
      Lib_GuiCom:Disable($edEin.P.Menge);
      //$edEin.P.Menge->WinUpdate(_WinUpdFld2Obj);
      Refreshifm('edEin.P.Menge');
    end
    else begin
      Lib_GuiCom:Enable($edEin.P.Menge);
    end;
  end;

  if (vFocus='edEin.P.Gewicht_Mat') then begin
// 06.12.2019 AH: nicht immer Kg!
//    Ein.P.Menge.Wunsch # Ein.P.Gewicht;
//    Ein.P.Menge # Ein.P.Gewicht;
    Ein.P.Menge.Wunsch # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, 0.0, '', Ein.P.MEH.Wunsch);
    Ein.P.Menge        # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, 0.0, '', Ein.P.MEH);
  end;

  // Toleranzfelder zurücksetzen
  if ( vFocus = 'edEin.P.Dicke_Mat') then
    if (aEvt:Obj->wpChanged) and (Set.Wie.ClrTolBeiEdt) then begin
    "Ein.P.Dickentol" # '';
    $edEin.P.Dickentol_Mat->WinUpdate( _winUpdFld2Obj );
  end;
  if ( vFocus = 'edEin.P.Breite_Mat') then
    if (aEvt:Obj->wpChanged ) and (Set.Wie.ClrTolBeiEdt) then begin
    "Ein.P.Breitentol" # '';
    $edEin.P.Breitentol_Mat->WinUpdate( _winUpdFld2Obj );
  end;
  if ( vFocus = 'edEin.P.Laenge_Mat') then
    if (aEvt:Obj->wpChanged ) and (Set.Wie.ClrTolBeiEdt) then begin
    "Ein.P.Längentol" # '';
    $edEin.P.Laengentol_Mat->WinUpdate( _winUpdFld2Obj );
  end;


  if (vFocus='edEin.P.Grundpreis_Mat') or (vFocus='edEin.P.Grundpreis') then begin
    Ein.p.Einzelpreis # Ein.P.Grundpreis + Ein.P.Aufpreis;
    Ein.P.Gesamtpreis # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH,"Ein.P.Stückzahl" , Ein.P.Gewicht);
  end;


  if ((vFocus='edEin.P.Skizzennummer') and ($edEin.P.Skizzennummer->wpchanged)) then begin
    Skizzendaten();
    RETURN false;
  end;


  RETURN true;
end;


//========================================================================
//  Auswahl
//          Auswahliste "ffnen
//========================================================================
 sub Auswahl(
  aBereich : alpha;
)
local begin
  Erx     : int;
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
  vFilter : int;
  vSel    : alpha;
  vSelName  : alpha;
  vSel2     : int;
  vQ        : alpha(4000);
  vQ2       : alpha(4000);
  tErx      : int;
  vI        : int;
  vTmp      : int;
end;

begin

  if (RunAFX('Ein.P.Auswahl.Pre',aBereich)<0) then RETURN;

  case aBereich of
    'AnalyseErweitert' : begin
      if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or (Mode=c_ModeEdit2) then
        Lys_Msk_Main:Start('', y, 'neue Bestellposition '+Ein.P.LieferantenSW, "Ein.P.Güte", "Ein.P.Gütenstufe", Ein.P.Dicke)
      else
        Lys_Msk_Main:Start('', Mode=c_ModeEdit, 'Bestellung '+aint(Ein.P.Nummer)+'/'+aint(Ein.P.Position)+' '+Ein.P.LieferantenSW, "Ein.P.Güte", "Ein.P.Gütenstufe", Ein.P.Dicke);
      RETURN;
    end;

    'Vorgangstyp' : begin
      Lib_Einheiten:Popup('Vorgangstyp-EK',$edEin.Vorgangstyp,500,1,33);
    end;


    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferadresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferadresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferanschrift' : begin
      RecLink(100,500,12,0);     // Lieferadresse holen
      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLieferanschrift');

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


    'Verbraucher' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusVerbraucher');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Rechnungsempf' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusRechnungsempf');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Ansprechpartner' : begin
      RecLink(100,500,1,0);       // Lieferant holen
      RecBufClear(102);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.P.Verwaltung',here+':AusAnsprechpartner');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.P.Adressnr'  , '=', Adr.Nummer);
      vHdl # SelCreate(102, gKey);
      Erx  # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'BDS' : begin
      RecBufClear(836);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BDS.Verwaltung',here+':AusBDS');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Land' : begin
      RecBufClear(812);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lnd.Verwaltung',here+':AusLand');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Waehrung' : begin
      RecBufClear(814);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung',here+':AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferbed' : begin
      RecBufClear(815);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LiB.Verwaltung',here+':AusLieferbed');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # 'Lib.SperreNeuYN=false';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zahlungsbed' : begin
      RecBufClear(816);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Zab.Verwaltung',here+':AusZahlungsbed');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # 'ZaB.SperreNeuYN=false';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Versandart' : begin
      RecBufClear(817);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VsA.Verwaltung',here+':AusVersandart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Steuerschluessel' : begin
      RecBufClear(813);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'StS.Verwaltung',here+':AusSteuerschluessel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Sachbearbeiter' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AusSachbearbeiter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Sprache' : begin
      Lib_Einheiten:Popup('Sprache',$edEin.Sprache,500,1,21);
    end;


    'AbmessungsEH' : begin
      Lib_Einheiten:Popup('AbmessungsEH',$edEin.AbmessungsEH,500,1,19);
    end;


    'Verband' : begin
      RecBufClear(110);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ver.Verwaltung',here+':AusVerband');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'GewichtsEH' : begin
      Lib_Einheiten:Popup('GewichtsEH',$edEin.GewichtsEH,500,1,20);
    end;


    'Auftragsart' : begin
      RecBufClear(835);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'AAr.Verwaltung',here+':AusAuftragsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    // ---- 2009-04-08 TM ----
    'Reservierungen' : begin
      RecLink(200,501,13,0);
      RecBufClear(203);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Rsv.Verwaltung',here+':AusReserv',y);
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


    'Aktionen' : begin
      RecBufClear(504);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.A.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QInt(var vQ, 'Ein.A.Nummer'  , '=', Ein.P.Nummer);
      vQ # vQ +' AND (';
      Lib_Sel:QInt(var vQ, 'Ein.A.Position' , '=', 0, ' ');
      Lib_Sel:QInt(var vQ, 'Ein.A.Position' , '=', Ein.P.Position, 'OR');
      vQ # vQ + ')';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Abruf' : begin
      if (mode<>c_ModeEdit) then begin
        ProtokollBuffer[500] # RecBufCreate(500);
        RecBufCopy(500,ProtokollBuffer[500]);
        ProtokollBuffer[501] # RecBufCreate(501);
        RecBufCopy(501,ProtokollBuffer[501]);
      end;

      // Lieferant holen
      RecLink(100,501,4,_RecFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung',here+':AusAbruf');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      // Selektion 'ABRUFE' in 501
      vQ # '';
      Lib_Sel:QInt( var vQ, 'Ein.P.Nummer', '<', 1000000000);
      Lib_Sel:QInt( var vQ, 'Ein.P.Lieferantennr', '=', Ein.LieferantenNr); // 24.08.2016 AH : war Ein.Lieferantennr
      vQ # vQ + ' AND LinkCount(EinKopf) > 0 ';
      vQ2 # ' Ein.LiefervertragYN ';

      // Selektion aufbauen...
      vHdl # SelCreate(501, gKey);
      vHdl->SelAddLink('',500, 501, 3, 'EinKopf');
      tErx # vHdl->SelDefQuery('', vQ);
      tErx # vHdl->SelDefQuery('EinKopf', vQ2);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      RecBufClear(501);
      $edEin.P.Artikelnr_Mat->wpcaption # '';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Verpackung' : begin
      Erx # RecLink(100,501,4,_RecFirst); // Lieferant holen
      if (Erx<>_rOK) then RecBufClear(100);
      RecBufClear(105);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung',here+':AusVerpackung');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
      Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Set.eigeneAdressnr, 'OR');
      vQ # 'Adr.V.EinkaufYN AND ('+vQ+')'; // 21.07.2015
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kopftext' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusKopftext');
      Gv.Alpha.01 # 'E';
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Fusstext' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusFusstext');
      Gv.Alpha.01 # 'E';
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Warengruppe' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guete' : begin
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(848);
      MQu.S.Stufe # "Ein.P.Gütenstufe";
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


    'AusfOben' : begin
      vFilter # RecFilterCreate(502,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.P.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.P.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, '1');
      vTmp # RecLinkInfo(502,501,12,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfOben');
        RunAFX('Ein.P.Obf.Filter',aint(gMDI)+'|1');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end

      RecBufClear(502);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.AF.Verwaltung',here+':AusAFOben');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(502,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.P.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.P.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, '1');
      gZLList->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AusfUnten' : begin
      vFilter # RecFilterCreate(502,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.P.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.P.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, '2');
      vTmp # RecLinkInfo(502,501,12,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfUnten');
        RunAFX('Ein.P.Obf.Filter',aint(gMDI)+'|2');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end

      RecBufClear(502);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.AF.Verwaltung',here+':AusAFUnten');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(502,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.P.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.P.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, '2');
      gZLList->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '2';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'WunschMEH' : begin
      Lib_Einheiten:Popup('MEH',$edEin.P.MEH.Wunsch,501,1,42);
    end;


    'Artikelnummer' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtNr');
      RecRead(250,1,0);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // <<< MUSTER für UMSORTIERN
//      gKey # 1;     //nach Nummer sortieren
      // ENDE MUSTER >>>

      // Selektion aufbauen...
      if (Set.Ein.Artfilter=819) and (Ein.p.Wgr.Dateinr<>0) then begin
        vQ # 'LinkCount(WGR) > 0 AND NOT(Art.GesperrtYN)';
// 15.09.2016         vI # Wgr_Data:WennArtDannCharge(Ein.P.Wgr.Dateinr);
          vI # Ein.P.Wgr.Dateinr;
//        if (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then vI # Wgr_Data:WertHuB();

        Lib_Sel:QInt( var vQ2, 'Wgr.Dateinummer'  , '=', vI);
        vHdl # SelCreate(250, gKey);
        vHdl->SelAddLink('',819, 250, 10, 'WGR');
        tErx # vHdl->SelDefQuery('', vQ);
        if (tErx != 0) then Lib_Sel:QError(vHdl);
        tErx # vHdl->SelDefQuery('WGR', vQ2);
        if (tErx != 0) then Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl,1,n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;
      end
      else if (Set.Auf.Artfilter=250) and (Ein.P.Warengruppe<>0) then begin
         vHdl # Winsearch(gMDI,'ZL.Artikel');
         Lib_Sel:QRecList(vHdl,'Art.Warengruppe='+aint(Ein.P.Warengruppe)+' AND NOT(Art.GesperrtYN)');
      end
      else begin
        vHdl # Winsearch(gMDI,'ZL.Artikel');
        Lib_Sel:QRecList(vHdl,'Art.Nummer>'''' AND NOT(Art.GesperrtYN)');
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikelnummer_Mat' : begin
      if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtNr_Mat');
        RecRead(250,1,0);
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        gKey # 1;       //nach Nummer sortieren
        // Selektion aufbauen...
        if (Set.Ein.Artfilter=819) then begin
          vQ # 'LinkCount(WGR) > 0 AND NOT(Art.GesperrtYN)';
// 15.09.2016         vI # Wgr_Data:WennArtDannCharge(Ein.P.Wgr.Dateinr);
          vI # Ein.P.Wgr.Dateinr;

          Lib_Sel:QInt( var vQ2, 'Wgr.Dateinummer'  , '=', vI);
          vHdl # SelCreate(250, gKey);
          vHdl->SelAddLink('',819, 250, 10, 'WGR');
          tErx # vHdl->SelDefQuery('', vQ);
          if (tErx != 0) then Lib_Sel:QError(vHdl);
          tErx # vHdl->SelDefQuery('WGR', vQ2);
          if (tErx != 0) then Lib_Sel:QError(vHdl);
          // speichern, starten und Name merken...
          w_SelName # Lib_Sel:SaveRun(var vHdl,1,n);
          // Liste selektieren...
          gZLList->wpDbSelection # vHdl;
        end
        else if (Set.Auf.Artfilter=250) and (Ein.P.Warengruppe<>0) then begin
           vHdl # Winsearch(gMDI,'ZL.Artikel');
           Lib_Sel:QRecList(vHdl,'Art.Warengruppe='+aint(Ein.P.Warengruppe)+' AND NOT(Art.GesperrtYN)');
        end
        else begin
          vHdl # Winsearch(gMDI,'ZL.Artikel');
          Lib_Sel:QRecList(vHdl,'Art.Nummer>'''' AND NOT(Art.GesperrtYN)');
        end;
        Lib_GuiCom:RunChildWindow(gMDI);
      end
      else begin
        RecBufClear(220);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusStruktur_Mat');
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'LiefArtNr' : begin
     if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr))) then begin    // 28.08.2020 AH, Proj. 2152/12
        Auswahl('LiefMatArtNr');
        RETURN;
      end;
/***
      if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Ein.P.Wgr.Dateinr=0) then begin
        Erx # RecLink(100,500,1,_RecFirst);         // Lieferant holen
        if (Erx<>_rOK) then RecBufClear(100);
        RecBufClear(105);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung',here+':AusLiefMatArtNr');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        vQ # '';
        Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
        Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Set.eigeneAdressnr, 'OR');
        vQ # 'Adr.V.EinkaufYN AND ('+vQ+')'; // 21.07.2015
        Lib_Sel:QRecList(0, vQ);
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end;
***/
      RecBufClear(254);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.P.Verwaltung',here+':AusLiefArtNr');
      RekLink(100,501,4,0);           // Adresse holen
      Art_P_Main:Selektieren(gMDI, '', Adr.Nummer);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LiefMatArtNr' : begin
      Erx # RecLink(100,500,1,_RecFirst);         // Lieferant holen
      if (Erx<>_rOK) then RecBufClear(100);
      RecBufClear(105);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung',here+':AusLiefMatArtNr');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
      Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Set.eigeneAdressnr, 'OR');
      vQ # 'Adr.V.EinkaufYN AND ('+vQ+')'; // 21.07.2015
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
      RETURN;
    end;


    'Zeugnis' : begin
      RecBufClear(839);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Zeu.Verwaltung',here+':AusZeugnis');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kommission' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommission');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Erzeuger' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusErzeuger');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Projekt' : begin
      RecBufClear(120);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusProjekt');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kostenstelle' : begin
      RecBufClear(846);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'KSt.Verwaltung',here+':AusKostenstelle');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Intrastat' : begin
      if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)=false) then begin
        if (Msg(220001,'',0,_WinDialogYesNo,1)=_WinIdYes) then begin
          // Selektion
          vQ # '';
          Lib_Sel:QAlpha( var vQ, 'MSL.Strukturtyp', '=', 'INTRA' );
          Lib_Sel:QAlpha( var vQ, 'MSL.Intrastatnr', '>', '' );
          Lib_Sel:QInt( var vQ, 'MSL.von.Warengruppe', '<=', Ein.P.Warengruppe );
          Lib_Sel:QInt( var vQ, 'MSL.bis.Warengruppe', '>=', Ein.P.Warengruppe );
          vQ # vQ + ' AND ( "MSL.Güte" = "Ein.P.Güte" OR "MSL.Güte" = '''' OR "Ein.P.Güte" = '''' ) ';
          vQ # vQ + ' AND ( "MSL.Gütenstufe" = "Ein.P.Gütenstufe" OR "MSL.Gütenstufe" = '''' OR "Ein.P.Gütenstufe" = '''' ) ';
          vQ # vQ + ' AND ( Ein.P.Dicke = 0.0 OR ( MSL.von.Dicke <= Ein.P.Dicke AND MSL.bis.Dicke >= Ein.P.Dicke ) ) ';
          vQ # vQ + ' AND ( Ein.P.Breite = 0.0 OR ( MSL.von.Breite <= Ein.P.Breite AND MSL.bis.Breite >= Ein.P.Breite ) ) ';
          vQ # vQ + ' AND ( "Ein.P.Länge" = 0.0 OR ( "MSL.von.Länge" <= "Ein.P.Länge" AND "MSL.bis.Länge" >= "Ein.P.Länge" ) ) ';

          vSel2 # SelCreate(220, 2);
          tErx # vSel2->SelDefQuery( '', vQ );
          if (tErx != 0) then Lib_Sel:QError(vSel2);
          vSelName # Lib_Sel:SaveRun( var vSel2, 0 );

          //vSelName # Sel_Build(vSel, 220, 'INTRASTAT_MATERIAL',y,0);
          RecBufClear(220);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
          gZLList->wpDbSelection # vSel2;
          w_SelName # vSelName;
          Lib_GuiCom:RunChildWindow(gMDI);
          RETURN;
        end;
      end;

      RecBufClear(220);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
      Lib_GuiCom:RunChildWindow(gMDI);

    end;


    'PreisMEH' : begin
      if ($NB.Page1->wpcustom='NB.Page1_Art') then begin
        Lib_Einheiten:Popup('MEH',$edEin.P.Preis.MEH,501,1,62);
      end
      else begin
        Lib_Einheiten:Popup('MEH',$edEin.P.Preis.MEH_Mat,501,1,62);
      end;
    end;


    'Terminart' : begin
      if ($NB.Page1->wpcustom='NB.Page1_Art') then
        Lib_Einheiten:Popup('Datumstyp',$edEin.P.Termin1W.Art,501,1,50)
      else
        Lib_Einheiten:Popup('Datumstyp',$edEin.P.Termin1W.Art_Mat,501,1,50);
    end;


    'KopfAufpreise' : begin
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # cnvai(Ein.P.Position,_FmtNumNoGroup,0,5)+CnvAI(Winfocusget(),_FmtNumNogroup,0,10);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.Z.Verwaltung',here+':AusKopfAufpreise',y);
      RecBufClear(503);
      Lib_GuiCom:RunChildWindow(gMDI);
      Ein.P.Position # 0;
    end;


    'Aufpreise' : begin
      if (Mode=c_ModeNew) or (Mode=c_ModeNew2) then begin
        if (Msg(842000,gTitle,_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
        if (FldInfoByName('Ein.P.Cust.PreisZum',_FldExists)>0) then
          ApL_Data:AutoGenerieren(501,n ,0, FldDateByName('Ein.P.Cust.PreisZum'))
        else
          ApL_Data:AutoGenerieren(501);
        end;
      end;

      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # cnvai(Ein.P.Position,_FmtNumNoGroup,0,5)+CnvAI(Winfocusget(),_FmtNumNogroup,0,10);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.Z.Verwaltung',here+':AusAufpreise',y);
      RecBufClear(503);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kalkulation' : begin
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # cnvai(Ein.P.Position,_FmtNumNoGroup,0,5)+CnvAI(Winfocusget(),_FmtNumNogroup,0,10);
      RecBufClear(505);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.K.Verwaltung',here+':AusKalkulation',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Preis' : begin
      if (Ein.P.ArtikelNr='') then RETURN;
      Erx # RekLink(250,501,2,_RecFirst); // Artikel holen
      RecBufClear(254);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.P.Verwaltung',here+':AusPreis');
      Art_P_Main:Selektieren(gMDI, Art.Nummer, 0);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Text2' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusText2');
      RecBufClear(837);         // ZIELBUFFER LEEREN
      Gv.Alpha.01 # 'E';
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zwischenlage' : begin
      RecBufClear(838);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusZwischenlage');
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


    'Verwiegungsart' : begin
      RecBufClear(818);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VwA.Verwaltung',here+':AusVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
     end;


    'Etikett' : begin
      RecBufClear(840);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Eti.Verwaltung',here+':AusEtikettentyp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Etikett2' : begin
      RecBufClear(840);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Eti.Verwaltung',here+':AusEtikettentyp2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Skizze' : begin
      RecBufClear(829);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Skz.Verwaltung',here+':AusSkizze');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

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
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.AF.Verwaltung',here+':AusAFOben');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(502,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.P.Nummer);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.P.Position);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, '1');
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
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.AF.Verwaltung',here+':AusAFUnten');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(502,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Ein.P.Nummer);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, Ein.P.Position);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, '2');
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
//  AusEingaenge
//
//========================================================================
sub AusEingaenge()
begin
  gSelected # 0;

  Ein_E_Data:RecalcPosition();

  gZLList->WinFocusset(true);
end;


//========================================================================
//  AusReserv
//
//========================================================================
sub AusReserv()
begin
 gSelected # 0;

  Ein_E_Data:RecalcPosition();

  gZLList->WinFocusset(true);
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Ein.Lieferantennr # Adr.Lieferantennr;
    Ein.LieferantenSW # Adr.Stichwort;
    //Ein.Rechnungsempf # Adr.Lieferantennr;
    // Ein.Lieferadresse # Adr.Nummer;
    // Ein.Lieferanschrift # 1;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.Lieferantennr->Winfocusset(TRUE);
  // ggf. Labels refreshen
  RefreshIfm('edEin.Lieferantennr',y);
end;


//========================================================================
//  AusLieferadresse
//
//========================================================================
sub AusLieferadresse()
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.Lieferadresse   # Adr.Nummer;
    Ein.Lieferanschrift # 1;
    $edEin.Lieferanschrift->WinUpdate(_WinUpdFld2Obj);

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edEin.Lieferadresse->WinFocusset(true);
//  RefreshIfm('edEin.Lieferadresse');

  Erx # RecLinkInfo(101,100,12,_recCount); // Mehr als eine Anschrift vorhanden?
  if(Erx > 1) then begin
    Auswahl('Lieferanschrift');
  end
  else begin
    Erx # RecLink(101,100,12,_recFirst); // Wenn nur 1, diese holen
    if(Erx > _rLocked) then
      RecBufClear(101);
    Ein.Lieferanschrift # Adr.A.Nummer;
    $edEin.Lieferanschrift->Winupdate(_WinUpdFld2Obj);
  end;
end;


//========================================================================
//  AusLieferanschrift
//
//========================================================================
sub AusLieferanschrift()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    Ein.Lieferanschrift # Adr.A.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edEin.Lieferanschrift->WinFocusset(true);
//  RefreshIfm('edEin.Lieferanschrift');
end;


//========================================================================
//  AusVerbraucher
//
//========================================================================
sub AusVerbraucher()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Ein.Verbraucher # Adr.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.Verbraucher->WinFocusset(true);
  // ggf. Labels refreshen
  RefreshIfm('edEin.Verbraucher');
end;


//========================================================================
//  AusRechnungsempf
//
//========================================================================
sub AusRechnungsempf()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Ein.RechnungsEmpf # Adr.Lieferantennr;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.RechnungsEmpf->WinFocusset(true);
  // ggf. Labels refreshen
  RefreshIfm('edEin.Rechnungsempf',y);
end;


//========================================================================
//  AusAnsprechpartner
//
//========================================================================
sub AusAnsprechpartner()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(102,0,_RecId,gSelected);
    // Feldübernahme
    if(StrLen('#'+cnvAI(Adr.P.Nummer)+':'+StrAdj(Adr.P.Titel+' '+Adr.P.Vorname+' '+Adr.P.Name,_Strbegin)) < 32) then
      Ein.AB.Bearbeiter # '#'+cnvAI(Adr.P.Nummer)+':'+StrAdj(Adr.P.Titel+' '+Adr.P.Vorname+' '+Adr.P.Name,_Strbegin);
    else if(StrLen('#'+cnvAI(Adr.P.Nummer)+':'+StrAdj(Adr.P.Vorname+' '+Adr.P.Name,_Strbegin)) < 32) then
      Ein.AB.Bearbeiter # '#'+cnvAI(Adr.P.Nummer)+':'+StrAdj(Adr.P.Vorname+' '+Adr.P.Name,_Strbegin);
    else if(StrLen('#'+cnvAI(Adr.P.Nummer)+':'+StrAdj(Adr.P.Name,_Strbegin)) < 32) then
      Ein.AB.Bearbeiter # '#'+cnvAI(Adr.P.Nummer)+':'+StrAdj(Adr.P.Name,_Strbegin);
    else
      Ein.AB.Bearbeiter # 'Name zu lang';
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.AB.Bearbeiter->WinFocusset(true);
  // ggf. Labels refreshen
//  RefreshIfm('edEin.AB.Bearbeiter');
end;


//========================================================================
//  AusBDS
//
//========================================================================
sub AusBDS()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
   RecRead(836,0,_RecId,gSelected);
    // Feldübernahme
    Ein.BDSNummer # BDS.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edEin.BDSNummer->WinFocusset(true);
//  RefreshIfm('edEin.Land');
end;


//========================================================================
//  AusLand
//
//========================================================================
sub AusLand()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(812,0,_RecId,gSelected);
    // Feldübernahme
    Ein.Land # "Lnd.Kürzel";
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edEin.Land->WinFocusset(true);
//  RefreshIfm('edEin.Land');
end;


//========================================================================
//  AusWaehrung
//
//========================================================================
sub AusWaehrung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    // Feldübernahme
    "Ein.Währung" # Wae.Nummer;
//    "HuB.EK.Währungskurs" # Wae.EK.Kurs;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.Waehrung->WinFocusset(true);
  // ggf. Labels refreshen
//  RefreshIfm('edEin.Waehrung');
end;


//========================================================================
//  AusLieferbed
//
//========================================================================
sub AusLieferbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(815,0,_RecId,gSelected);
    // Feldübernahme
    Ein.Lieferbed # LiB.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.Lieferbed->WinFocusset(true);
  // ggf. Labels refreshen
//  RefreshIfm('edEin.Lieferbed');
end;


//========================================================================
//  AusZahlungsbed
//
//========================================================================
sub AusZahlungsbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(816,0,_RecId,gSelected);
    // Feldübernahme
    Ein.Zahlungsbed # ZaB.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.Zahlungsbed->WinFocusset(true);
  // ggf. Labels refreshen
//  RefreshIfm('edEin.Zahlungsbed');
end;


//========================================================================
//  AusVersandart
//
//========================================================================
sub AusVersandart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(817,0,_RecId,gSelected);
    // Feldübernahme
    Ein.Versandart # Vsa.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.Versandart->WinFocusset(true);
  // ggf. Labels refreshen
//  RefreshIfm('edEin.Versandart');
end;


//========================================================================
//  AusSteuerschluessel
//
//========================================================================
sub AusSteuerschluessel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(813,0,_RecId,gSelected);
    // Feldübernahme
    "Ein.Steuerschlüssel" # StS.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.Steuerschluessel->WinFocusset(true);
  // ggf. Labels refreshen
//  RefreshIfm('edEin.Steuerschluessel');
end;


//========================================================================
//  AusSachbearbeiter
//
//========================================================================
sub AusSachbearbeiter()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    // Feldübernahme
    Ein.Sachbearbeiter # Usr.Username;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  Usr_data:RecReadThisUser();
  // Focus auf Editfeld setzen:
  $edEin.Sachbearbeiter->WinFocusset(true);
  // ggf. Labels refreshen
//  RefreshIfm('edEin.Sachbearbeiter');
end;


//========================================================================
//  AusVerband
//
//========================================================================
sub AusVerband()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(110,0,_RecId,gSelected);
    // Feldübernahme
    Ein.Verband # Ver.Nummer;
    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edEin.Verband->Winfocusset(false);
  RefreshIfm('edEin.Verband');
end;


//========================================================================
//  AusAuftragsart
//
//========================================================================
sub AusAuftragsArt()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(835,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Auftragsart # AAr.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  if ($NB.Page1->wpcustom='NB.Page1_Art') then
    $edEin.P.Auftragsart->WinFocusset(true)
  else
    $edEin.P.Auftragsart_Mat->WinFocusset(true);

end;


//========================================================================
//  AusText2
//
//========================================================================
sub AusText2();
local begin
  vTxtHdl : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;

    vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,Ein.Sprache);
    $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);

    // Ausgewählten Text in das Feld eintragen
    Ein.P.TextNr1 # 0;
    Ein.P.TextNr2 # 0;
    $edEin.P.TextNr2->wpCaptionint # 0;
    $edEin.P.TextNr2->Winupdate(_WinUpdFld2Obj);
    Lib_GuiCOM:Disable($edEin.P.TextNr2);

    Lib_GuiCOM:Enable($edEin.P.TextNr2b);
    Ein.P.TextNr2 # Txt.Nummer;
    $edEin.P.TextNr2b->wpCaptionint # Txt.Nummer;
    $edEin.P.TextNr2b->Winupdate(_WinUpdFld2Obj);

    // ggf. Labels refreshen
    $cb.Text1->wpCheckState # _WinStateChkUnchecked;
    $cb.Text2->wpCheckState # _WinStateChkChecked;
    $cb.Text3->wpCheckState # _WinStateChkUnchecked;


    // Focus auf Editfeld setzen:
    $cb.Text2->Winfocusset(true);

  end;

end;


//========================================================================
//  AusVerpackung
//
//========================================================================
sub AusVerpackung();
local begin
  vTmp  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(105,0,_RecId,gSelected);
    Ein.p.Verpacknr       # Adr.V.lfdNr;
    Ein.P.VerpackAdrNr    # Adr.V.Adressnr;
    Ein.P.AbbindungL      # Adr.V.AbbindungL;
    EIn.P.AbbindungQ      # Adr.V.AbbindungQ;
    Ein.P.Zwischenlage    # Adr.V.Zwischenlage;
    Ein.P.Unterlage       # Adr.V.Unterlage;
    Ein.P.Umverpackung    # Adr.V.Umverpackung;
    Ein.P.Wicklung        # Adr.V.Wicklung;
    Ein.P.MitLfEYN        # Adr.V.MitLfEYN;
    Ein.P.StehendYN       # Adr.V.StehendYN;
    Ein.P.LiegendYN       # Adr.V.LiegendYN;
    EIn.P.Nettoabzug      # Adr.V.Nettoabzug;
    "Ein.P.Stapelhöhe"    # "Adr.V.Stapelhöhe";
    EIn.P.StapelhAbzug    # Adr.V.StapelhAbzug;
    EIn.P.RingKgVon       # Adr.V.RingKgVon;
    Ein.P.RingKgBis       # Adr.V.RingKgBis;
    Ein.P.KgmmVon         # Adr.V.KgmmVon;
    Ein.P.KgmmBis         # Adr.V.KgmmBis;
    "Ein.P.StückProVE"      # "Adr.V.StückProVE";
    Ein.P.VEkgMax         # Adr.V.VEkgMax;
    EIn.P.RechtwinkMax    # Adr.V.RechtwinkMax;
    EIn.P.EbenheitMax     # Adr.V.EbenheitMax;
    "EIn.P.SäbeligkeitMax" # "Adr.V.SäbeligkeitMax";
    "EIn.P.SäbelProM"     # "Adr.V.SäbelProM";
    Ein.P.Etikettentyp    # Adr.V.Etikettentyp;
    Ein.P.Verwiegungsart  # Adr.V.Verwiegungsart;
    Ein.P.VpgText1  # Adr.V.VpgText1;
    Ein.P.VpgText2  # Adr.V.VpgText2;
    Ein.P.VpgText3  # Adr.V.VpgText3;
    Ein.P.VpgText4  # Adr.V.VpgText4;
    Ein.P.VpgText5  # Adr.V.VpgText5;
    Ein.P.VpgText6  # Adr.V.VpgText6;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    $NB.Page3->WinUpdate(_winUpdFld2Obj);
  end;
  gSelected # 0;
  // Focus auf Editfeld setzen:
  $edEin.P.Verpacknr->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusKopftext
//
//========================================================================
sub AusKopftext();
local begin
  vTxtHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl # $Ein.P.TextEditKopf->wpdbTextBuf;
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,Ein.Sprache);
    $Ein.P.TextEditKopf->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $Ein.P.TextEditKopf->Winfocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusFusstext
//
//========================================================================
sub AusFusstext();
local begin
  vTxtHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl # $Ein.P.TextEditFuss->wpdbTextBuf;
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl,Ein.Sprache);
    $Ein.P.TextEditFuss->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $Ein.P.TextEditFuss->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusKopftextAdd
//
//========================================================================
sub AusKopftextAdd();
local begin
  vTxtHdl   : int;
  vTxtHdl2  : int;
  vI        : int;
  vA        : alpha(250);
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    $Ein.P.TextEditKopf->WinUpdate(_WinUpdObj2Buf);
    vTxtHdl # $Ein.P.TextEditKopf->wpdbTextBuf;
    vTxtHdl2 # TextOpen(16);
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl2, Ein.Sprache);
    FOR vI # 1 loop inc(vI) WHILE (vI<=Textinfo(vTxtHdl2,_TextLines)) do begin
      TextLineWrite(vTxtHdl, TextInfo(vTxtHdl,_textLines)+1, TextLineRead(vTxtHdl2,vI,0), _TextLineInsert);
    END;
    TextClose(vTxtHdl2);
    $Ein.P.TextEditKopf->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $Ein.P.TextEditKopf->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusFusstextAdd
//
//========================================================================
sub AusFusstextAdd();
local begin
  vTxtHdl   : int;
  vTxtHdl2  : int;
  vI        : int;
  vA        : alpha(250);
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    $Ein.P.TextEditFuss->WinUpdate(_WinUpdObj2Buf);
    vTxtHdl # $Ein.P.TextEditFuss->wpdbTextBuf;
    vTxtHdl2 # TextOpen(16);
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl2, Ein.Sprache);
    FOR vI # 1 loop inc(vI) WHILE (vI<=Textinfo(vTxtHdl2,_TextLines)) do begin
      TextLineWrite(vTxtHdl, TextInfo(vTxtHdl,_textLines)+1, TextLineRead(vTxtHdl2,vI,0), _TextLineInsert);
    END;
    TextClose(vTxtHdl2);
    $Ein.P.TextEditFuss->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $Ein.P.TextEditFuss->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusTextAdd
//
//========================================================================
sub AusTextAdd();
local begin
  vTxtHdl   : int;
  vTxtHdl2  : int;
  vI        : int;
  vA        : alpha(250);
  vName     : alpha;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;

    $cb.Text1->wpcheckstate(_WinFlagNoFocusSet) # _WinStateChkUnchecked;
    $cb.Text1->wpColBkg # _WinColParent;
    $cb.Text2->wpcheckstate(_WinFlagNoFocusSet) # _WinStateChkUnchecked;
    $cb.Text2->wpColBkg # _WinColParent;
    $cb.Text3->wpcheckstate(_WinFlagNoFocusSet) # _WinStateChkchecked;
    $cb.Text3->wpColBkg # _WinColParent;

    if (Ein.P.Textnr1<>501) then begin
      vName # '~837.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);

      Ein.P.TextNr1 # 501;
      Ein.P.TextNr2 # 0;
      $edEin.P.TextNr2b->wpCaptionInt # 0;

      vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
      Lib_Texte:TxtLoadLangBuf(vName,vTxtHdl, Ein.Sprache);

      if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
        vName # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
      else
        vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      $Ein.P.TextEdit1->wpcustom # vName;
      $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
      RefreshIfm('Text');
    end;


    $Ein.P.TextEdit1->WinUpdate(_WinUpdObj2Buf);
    vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
    vTxtHdl2 # TextOpen(16);
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl2, Ein.Sprache);
    FOR vI # 1 loop inc(vI) WHILE (vI<=Textinfo(vTxtHdl2,_TextLines)) do begin
      TextLineWrite(vTxtHdl, TextInfo(vTxtHdl,_textLines)+1, TextLineRead(vTxtHdl2,vI,0), _TextLineInsert);
    END;
    TextClose(vTxtHdl2);
    $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $Ein.P.TextEdit1->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
local begin
  Erx     : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.P.Warengruppe # Wgr.Nummer;
    Ein.P.Wgr.Dateinr # Wgr.Dateinummer;
    if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) then begin
      if (Ein.P.Artikelnr<>'') then begin
        Erx # RecLink(250,501,2,_RecFirst); // Artikel holen
        if (Erx=_rOK) and ("Art.ChargenführungYN") then Ein.P.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Ein.P.Wgr.Dateinr);
      end;
    end;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;


  $edEin.P.Warengruppe->Winupdate(_WinUpdFld2Obj);
  $edEin.P.Warengruppe_Mat->Winupdate(_WinUpdFld2Obj);

  Ein_P_SMain:SwitchMask(y);
  // Focus auf Editfeld setzen:
  if ($NB.Page1->wpcustom='NB.Page1_Art') then
    $edEin.P.Warengruppe->Winfocusset(true)
  else
    $edEin.P.Warengruppe_Mat->Winfocusset(true);

end;


//========================================================================
//  AusKommission
//
//========================================================================
sub AusKommission()
begin

  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
//  Ein.P.Kommissionnr  # Auf.P.Nummer;
//  Ein.P.Kommissionpos # Auf.P.Position;

    Ein.P.Kommission # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position);
    $edEin.P.Kommission->Winupdate(_WinUpdFld2Obj);
    $edEin.P.Kommission_Mat->Winupdate(_WinUpdFld2Obj);
    /*
    Ein.P.Warengruppe
    Ein.P.Bemerkung
    */

  end;
  // Focus auf Editfeld setzen:
  if ($NB.Page1->wpcustom='NB.Page1_Art') then begin
//    $edEin.P.Kommission->WinFocusset(true);
    RefreshIfm('edEin.P.Kommission',y);
    $edEin.P.Dicke->Winfocusset(true);    // 16.08.2017 AH: Workaround für "Leer->F9->Auswahl->manuell leeren"
    $edEin.P.Kommission->Winfocusset(true);
  end
  else begin
//    $edEin.P.Kommission_Mat->WinFocusset(true);
    RefreshIfm('edEin.P.Kommission_Mat',y);
    $edEin.P.Dicke_Mat->Winfocusset(true);  // 16.08.2017 AH: Workaround für "Leer->F9->Auswahl->manuell leeren"
    $edEin.P.Kommission_Mat->Winfocusset(true);
  end;

  gMdi->WinUpdate(_WinUpdFld2Obj);

end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "Ein.P.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "Ein.P.Güte" # "MQu.Güte1"
    else
      "Ein.P.Güte" # "MQu.Güte2";
    Ein.P.Werkstoffnr # MQU.Werkstoffnr;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  if ($NB.Page1->wpcustom='NB.Page1_Art') then
    $edEin.P.Guete->Winfocusset(true)
  else
    $edEin.P.Guete_Mat->Winfocusset(true);
end;


//========================================================================
//  AusGuetenstufe
//
//========================================================================
sub AusGuetenstufe()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "Ein.P.Gütenstufe" # MQu.S.Stufe;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Guetenstufe_Mat->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
begin
  gSelected # 0;

  Ein.P.AusfOben # Obf_Data:BildeAFString(501,'1');

  // Focus auf Editfeld setzen:
  $edEin.P.AusfOben_Mat->Winfocusset(true);
end;


//========================================================================
//  AusAF
//
//========================================================================
sub AusAFUnten()
begin
  gSelected # 0;

  Ein.P.AusfUnten # Obf_Data:BildeAFString(501,'2');

  // Focus auf Editfeld setzen:
  $edEin.P.AusfUnten_Mat->Winfocusset(true);
end;


//========================================================================
//  AusArtNr
//
//========================================================================
sub AusArtNr()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    Ein.P.Artikelnr   # Art.Nummer;
    //Ein_P_SMain:RefreshIfm_Page1_Art('edEin.P.Artikelnr', true);
    Ein_P_SMain:GetArtikel();

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  gMDI->winupdate();
  // Focus auf Editfeld setzen:
  $edEin.P.Artikelnr->Winfocusset(true);

    // ggf. Labels refreshen
  Refreshifm();
end;


//========================================================================
//  AusArtNr_Mat
//
//========================================================================
sub AusArtNr_Mat()
local begin
  Erx     : int;
  vTxtHdl : int;
  vName   : alpha;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    Ein.P.Artikelnr   # Art.Nummer;
    Ein.P.ArtikelSW   # Art.Stichwort;
    $edEin.P.Artikelnr_Mat->wpcaption # Ein.P.Artikelnr;

    RecLink(819,250,10,_recfirst);    // Warengruppe holen
    Ein.P.Warengruppe   # Wgr.Nummer;
    Ein.P.Wgr.Dateinr   # Wgr.Dateinummer;

    // Text übernehmen...
    Ein.P.TextNr1 # 501;
    Ein.P.TextNr2 # 0;
    vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
    if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
      vName # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
    else
      vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    Lib_Texte:TxtLoadLangBuf('~250.EK.'+CnvAI(ART.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, Ein.Sprache);
    $Ein.P.TextEdit1->wpcustom # vName;
    $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);

    // Ausführugen löschen & kopieren aus Artikel
    WHILE (RecLink(502,501,12,_recFirst)=_rOK) do
      RekDelete(502,0,'MAN');

    if ("Art.Oberfläche"<>0) then begin
      RecBufClear(502);
      Ein.AF.Nummer   # Ein.P.Nummer;
      Ein.AF.Position # Ein.P.Position;
      Ein.AF.Seite    # '1';
      Ein.AF.lfdNr    # 1;
      Ein.AF.ObfNr    # "Art.Oberfläche";

      Erx # RecLink(841,502,1,0); // OBerfläche holen
      if (Erx<=_rLocked) then begin
        Ein.AF.Bezeichnung  # Obf.Bezeichnung.L1;
        "Ein.AF.Kürzel"     # "Obf.Kürzel";
        RekInsert(502,0,'AUTO');
        Ein.P.Ausfoben # "Ein.AF.Bezeichnung" + Ein.AF.Zusatz;
      end;
    end;
    // Ausführungen kopieren
    FOR Erx # RecLink(257,250,27,_recFirst)
    LOOP Erx # RecLink(257,250,27,_recNext)
    WHILE (Erx<=_rLocked) do begin
      Ein.AF.Nummer         # Ein.P.Nummer;
      Ein.AF.Position       # Ein.P.Position;
      Ein.AF.Seite          # Art.AF.Seite;
      Ein.AF.lfdNr          # Art.AF.lfdNr;
      Ein.AF.ObfNr          # Art.AF.ObfNr;
      ein.AF.Bezeichnung    # Art.AF.Bezeichnung;
      Ein.AF.Zusatz         # Art.AF.Zusatz;
      Ein.AF.Bemerkung      # Art.AF.Bemerkung;
      "Ein.AF.Kürzel"       # "Art.AF.Kürzel";
      RekInsert(502,0,'AUTO');
      Ein.P.AusfOben        # "Art.AusführungOben";
      Ein.P.AusfUnten       # "Art.AusführungUnten";
    END;

    //Ein.P.ArtikelTyp  # Art.Typ;
    if ("Art.ChargenführungYN") then Ein.P.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Ein.P.Wgr.Dateinr);
    Ein.P.Sachnummer  # Art.Sachnummer;
    Ein.P.Menge.Wunsch # 0.0;
    Ein.P.MEH.Wunsch  # Art.MEH;
    Ein.P.MEH         # Art.MEH;
Ein.P.MEH.Preis # Art.MEH;
    Ein.P.Menge       # 0.0;
    Ein.P.PEH         # Art.PEH;
    Ein.P.Dicke       # Art.Dicke;
    Ein.P.Breite      # Art.Breite;
    "Ein.P.Länge"     # "Art.Länge";
    Ein.P.Dickentol   # Art.Dickentol;
    Ein.P.Breitentol  # Art.Breitentol;
    "Ein.P.Längentol" # "Art.Längentol";
    Ein.P.RID         # Art.Innendmesser;
    Ein.P.RAD         # Art.Aussendmesser;
    Ein.P.Intrastatnr  # Art.Intrastatnr;
    Ein.P.AbmessString # Art.AbmessungString;
    "Ein.P.Güte"      # "Art.Güte";
    Ein.P.Werkstoffnr # Art.Werkstoffnr;
    Ein.P.Warengruppe # Art.Warengruppe;    // 04.12.2014

    $lb.Art.MEH1->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH2->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH3->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH4->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH5->wpcaption       # Ein.P.MEH;
    $lb.Art.MEH6->wpcaption       # Ein.P.MEH;
    gSelected # 0;

    if (RecLink(100,501,4,0) <= _rLocked) then begin // Lieferant für Lieferantenartikelnummer holen
      Art.P.ArtikelNr     # Art.Nummer;
      Art.P.AdrStichwort  # Adr.Stichwort;
      Erx # RecRead(254,2,0);
      if (Erx <= _rMultikey) then                    // Schlüssel ist wegen Staffelung der Preise nicht
        Ein.P.LieferArtNr # Art.P.AdressArtNr;       // eindeutig, LieferArtNr sollte jedoch in einer
      else                                           // Staffelung gleich sein.
        Ein.P.LieferArtNr # '';
      $edEin.P.LieferArtNr->Winupdate(_WinUpdFld2Obj);
    end;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  gMDI->winupdate();
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  Refreshifm();

  $edEin.P.Artikelnr_Mat->Winfocusset(true);
  $edEin.P.Artikelnr_Mat->wpcaption # Ein.P.Artikelnr;
//  Refreshifm('edEin.P.Artikelnr');
end;


//========================================================================
//  AusStruktur_Mat
//
//========================================================================
sub AusStruktur_Mat()
local begin
  vTmp  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.P.Strukturnr  # MSL.StrukturNR;
    $edEin.P.Artikelnr_Mat->wpcaption # Ein.P.Strukturnr;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  // Focus auf Editfeld setzen:
  $edEin.P.Artikelnr_Mat->Winfocusset(true);
  // ggf. Labels refreshen
  Refreshifm('edEin.P.Artikelnr_Mat',y);
end;


//========================================================================
//  AusLiefArtNr
//
//========================================================================
sub AusLiefArtNr()
local begin
  Erx     : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(254,0,_RecId,gSelected);
    Erx # RecLink(250,254,2,0);
    if (Erx <= _rLocked) then begin
      Ein.P.Sachnummer  # Art.Sachnummer;
      Ein.P.ArtikelSW   # Art.Stichwort;
      Ein.P.Artikelnr   # Art.Nummer;

      Ein.P.Menge.Wunsch # 0.0;
      Ein.P.MEH.Wunsch  # Art.MEH;
      Ein.P.MEH         # Art.MEH;
      Ein.P.Menge       # 0.0;
      Ein.P.PEH         # Art.PEH;

      Ein.P.Dicke       # Art.Dicke;
      Ein.P.Breite      # Art.Breite;
      "Ein.P.Länge"     # "Art.Länge";
      Ein.P.Intrastatnr # Art.Intrastatnr;
      Ein.P.AbmessString # Art.AbmessungString;
      Ein.P.Warengruppe # Art.Warengruppe;    // 04.12.2014
//      Ein.P.RID         # Art.RadiusInnen;
//      Ein.P.RAD         # Art.Radius;
      $lb.Art.MEH1->wpcaption       # Ein.P.MEH;
      $lb.Art.MEH2->wpcaption       # Ein.P.MEH;
      $lb.Art.MEH3->wpcaption       # Ein.P.MEH;
      $lb.Art.MEH4->wpcaption       # Ein.P.MEH;
      $lb.Art.MEH5->wpcaption       # Ein.P.MEH;
      $lb.Art.MEH6->wpcaption       # Ein.P.MEH;

      Ein.P.LieferArtNr # Art.P.AdressArtNr;
      vTmp # WinFocusget();   // LastFocus-Feld refreshen
      if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    end;

    gSelected # 0;
  end;

  // Focus auf Editfeld setzen:
  $edEin.P.LieferArtNr->Winfocusset(true);
end;


//========================================================================
//  AusLiefMatArtNr
//
//========================================================================
sub AusLiefMatArtNr()
local begin
  vTxtName    : alpha;
  vTxtHdlAsc  : handle;
  vTxtHdlRtf  : handle;
  vTxtName2   : alpha;
  vTmp        : int;
end
begin
  if (gSelected<>0) then begin
    RecRead(105,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme

    Ein_Data:Verpackung2Ein(true);
    RefreshIfm('edEin.P.Erzeuger_Mat',y);
    RefreshIfm('Text');

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.LieferMatArtNr_Mat->Winfocusset(true);
  gMDI->Winupdate(_WinUpdFld2Obj);
end;


//========================================================================
//  AusProjekt
//
//========================================================================
sub AusProjekt()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Projektnummer # Prj.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  if ($NB.Page1->wpcustom='NB.Page1_Art') then
    $edEin.P.Projektnummer->WinFocusset(true);
  else
    $edEin.P.Projektnummer_Mat->WinFocusset(true);
  // ggf. Labels refreshen
//  RefreshIfm('edEin.Lieferantennr');
end;


//========================================================================
//  AusIntrastat
//
//========================================================================
sub AusIntrastat()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Intrastatnr # MSL.Intrastatnr;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  if ($NB.Page1->wpcustom='NB.Page1_Art') then
    $edEin.P.Intrastatnr->WinFocusset(true)
  else
    $edEin.P.Intrastatnr_Mat->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusKostenstelle
//
//========================================================================
sub AusKostenstelle()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(846,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Kostenstelle # KSt.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Kostenstelle->WinFocusset(true);
  // ggf. Labels refreshen
//  RefreshIfm('edEin.Lieferantennr');
end;


//========================================================================
//  AusZeugnis
//
//========================================================================
sub AusZeugnis()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(839,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Zeugnisart # Zeu.Bezeichnung;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  if ($NB.Page1->wpcustom='NB.Page1_Art') then
    $edEin.P.Zeugnisart->Winfocusset(true)
  else
    $edEin.P.Zeugnisart_Mat->Winfocusset(true);
end;


//========================================================================
//  AusErzeuger
//
//========================================================================
sub AusErzeuger()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Erzeuger # Adr.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Erzeuger_Mat->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusVerwiegungsart
//
//========================================================================
sub AusVerwiegungsart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Verwiegungsart # VwA.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Verwiegungsart->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusZwischenlage
//
//========================================================================
sub AusZwischenlage()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Zwischenlage # ULa.Bezeichnung;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Zwischenlage->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusUnterlage
//
//========================================================================
sub AusUnterlage()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Unterlage # ULa.Bezeichnung;
    Ein.P.StapelhAbzug # "ULa.Höhenabzug";
    gSelected # 0;
    $edEin.P.StapelhAbzug->winupdate(_WinUpdFld2Obj);
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Unterlage->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusUmverpackung
//
//========================================================================
sub AusUmverpackung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Umverpackung # ULa.Bezeichnung;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Umverpackung->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusEtikettentyp
//
//========================================================================
sub AusEtikettentyp()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(840,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Etikettentyp # Eti.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    $edEin.P.Etikettentyp2->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Etikettentyp->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusEtikettentyp2
//
//========================================================================
sub AusEtikettentyp2()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(840,0,_RecId,gSelected);
    // Feldübernahme
    Ein.P.Etikettentyp # Eti.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    $edEin.P.Etikettentyp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Etikettentyp2->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusSkizze
//
//========================================================================
sub AusSkizze();
local begin
  vTxtHdl : int;
  vDoIt   : logic;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(829,0,_RecId,gSelected);
    Ein.P.Skizzennummer # Skz.Nummer;
//    $Picture1->wpcaption # '*'+Skz.Dateiname;
    $pic.Skizze->wpcaption # '*'+Skz.Dateiname;
    vDoIt # y;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  gSelected # 0;
  // Focus auf Editfeld setzen:
  $edEin.P.Skizzennummer->Winfocusset(false);
  // ggf. Labels refreshen
//  RefreshIfm('edAuf.P.Skizzennummer');
  if (vDoIt) then Skizzendaten();
end;


//========================================================================
//  AusKopfAufpreise
//
//========================================================================
sub AusKopfaufpreise()
local begin
  Erx     : int;
  vBuf501 : int;
  vHdl    : int;
  vTmp    : int;
end;
begin

  // gesamtes Fenster aktivieren
  vHDL # winsearch(gMDI, 'NB.Main');
  Ein.P.Position # CnvIA(StrCut(vHDL->wpcustom,1,5));
//  if (mode=c_modeView) then Refreshifm();
  vTmp # CnvIA(StrCut(vHDL->wpcustom,6,10));
  if (vTmp<>0) then begin
    vTmp->WinFocusset(true);
  end
  else if (Mode=c_ModeView) then begin
    vTmp # gMDI->WinSearch('Edit');
    vTmp->wpdisabled # false;
    vTmp->WinFocusset(true);
  end;

  vHDL->wpcustom # '';

  // ALLE Positionen refreshen?
//  if (Ein.P.Nummer<1000000000) then begin
  //  if (Mode = c_ModeList) then
  //    Erx # RecRead(501,0,_RecID | _RecLock,gZLList->wpDbRecID);

    APPOFF();
    vBuf501 # RekSave(501);
    FOR Erx # RecLink(501,500,9,_recFirst)
    LOOP Erx # RecLink(501,500,9,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (Mode=c_ModeList) then begin
        Ein_Data:SumAufpreise(c_ModeView);
      end
      else begin
        RecRead(501,1,_recLock);
        Ein_Data:SumAufpreise(Mode);
        RekReplace(501);
      end;

      if (vBuf501->Ein.P.Position=Ein.P.Position) then begin
        vBuf501->Ein.P.Aufpreis     # Ein.P.Aufpreis;
        vBuf501->Ein.P.Einzelpreis  # Ein.P.Einzelpreis;
        vBuf501->Ein.P.Gesamtpreis  # Ein.P.Gesamtpreis;
      end;
    END;
    RekRestore(vBuf501);

    if (Mode=c_ModeEdit) then
      Erx # RecRead(501,1,_recLock | _recNoLoad);

    if (Mode<>c_modeList) then begin
      $RL.Aufpreise->winupdate(_winupdon,_WinLstFromFirst);
      $RL.Aufpreise_Mat->winupdate(_winupdon,_WinLstFromFirst);

      $lb.Aufpreise->wpcaption # ANum(Ein.P.Aufpreis,2);
      $lb.Aufpreise_Mat->wpcaption # ANum(Ein.P.Aufpreis,2);
      $lb.P.Einzelpreis->wpcaption # ANum(Ein.P.Einzelpreis,2);
      $lb.P.Einzelpreis_Mat->wpcaption # ANum(Ein.P.Einzelpreis,2);
      $lb.Poswert_Mat->wpcaption # ANum(Ein.P.Gesamtpreis,2);
    end;

    APPON();

    if (Mode=c_ModeList) then
      RefreshList(gZLList, _WinLstRecFromRecID | _WinLstRecDoSelect);
//  end;

end;


//========================================================================
//  AusAufpreise
//
//========================================================================
sub AusAufpreise()
local begin
  vAufpreis : float;
  vMenge    : float;
  vHDL      : int;
  vTmp      : int;
end
begin

  vHDL # winsearch(gMDI, 'NB.Main');
  // gesamtes Fenster aktivieren
  Ein.P.Position # CnvIA(StrCut(vHDL->wpcustom,1,5));
  vTmp # CnvIA(StrCut(vHDL->wpcustom,6,10));
  if (vTmp<>0) then begin
    vTmp->WinFocusset(true);
  end
  else if (Mode=c_ModeView) then begin
    vTmp # gMDI->WinSearch('Edit');
    vTmp->wpdisabled # false;
    vTmp->WinFocusset(true);
  end;

  Ein_Data:SumAufpreise(Mode);
//  Ein.P.Gesamtpreis # Ein_data:SumGesamtpreis(Ein.P.Menge, "Ein.P.Stückzahl" , Ein.P.Gewicht);

  if (Mode<>c_modeList) then begin
    $RL.Aufpreise->winupdate(_winupdon,_WinLstFromFirst);
    $RL.Aufpreise_Mat->winupdate(_winupdon,_WinLstFromFirst);

    $lb.Aufpreise->wpcaption # ANum(Ein.P.Aufpreis,2);
    $lb.Aufpreise_Mat->wpcaption # ANum(Ein.P.Aufpreis,2);
    $lb.P.Einzelpreis->wpcaption # ANum(Ein.P.Einzelpreis,2);
    $lb.P.Einzelpreis_Mat->wpcaption # ANum(Ein.P.Einzelpreis,2);
    $lb.Poswert_Mat->wpcaption # ANum(Ein.P.Gesamtpreis,2);
  end;

  vHDL->wpcustom # '';
end;


//========================================================================
//  AusKalkulation
//
//========================================================================
sub AusKalkulation()
local begin
  vHDL  : int;
  vTmp  : int;
end;
begin

  vHDL # winsearch(gMDI, 'NB.Main');
  Ein.P.Position # CnvIA(StrCut(vHDL->wpcustom,1,5));
  vTmp # CnvIA(StrCut(vHDL->wpcustom,6,10));
  if (vTmp<>0) then begin
    vTmp->WinFocusset(true);
  end
  else if (Mode=c_ModeView) then begin
    vTmp # gMDI->WinSearch('Edit');
    vTmp->wpdisabled # false;
    vTmp->WinFocusset(true);
  end;

  Ein_K_Data:SumKalkulation();  // 18.12.2018
  Ein_Data:SumAufpreise(Mode);  // 2023-02-06 AH
  
  if (RecLinkInfo(505,501,8,_RecCount)=0) then begin
    $cb.Kalkulation_Art->wpCheckState # _WinStateChkUnChecked;
    $cb.Kalkulation_Mat->wpCheckState # _WinStateChkUnChecked;
  end
  else begin
    $cb.Kalkulation_Art->wpCheckState # _WinStateChkChecked;
    $cb.Kalkulation_Mat->wpCheckState # _WinStateChkChecked;
  end;

  vHDL->wpcustom # '';
end;


//========================================================================
//  AusAbruf
//
//========================================================================
sub AusAbruf()
local begin
  Erx   : int;
  vAuf  : int;
  vPos  : int;
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    // 2022-09-13 AH : alles erst mal löschen:
    Erx # RecLink(502,501,12,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(502);
      if (Erx<>_rOK) then RETURN;
      Erx # RecLink(502,501,12,_recNext);
    END;
    if (Erx=_rDeadlock) then RETURN;
    Erx # RecLink(503,501,7,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(503);
      if (Erx<>_rOK) then RETURN;
      Erx # RecLink(503,501,7,_recNext);
    END;
    if (Erx=_rDeadlock) then RETURN;
    Erx # RecLink(505,501,8,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(505);
      if (Erx<>_rOK) then RETURN;
      Erx # RecLink(505,501,8,_recNext);
    END;
    if (Erx=_rDeadlock) then RETURN;

    Erx # RecRead(501,0,_RecId,gSelected);

    // Feldübernahme
    vAuf # Ein.P.Nummer;
    vPos # Ein.P.Position;
    
    // Ausführungen kopieren...
    Erx # RecLink(502,501,12,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Ein.AF.Nummer   # ProtokollBuffer[501]->Ein.P.Nummer;
      Ein.AF.Position # ProtokollBuffer[501]->Ein.P.Position;
      RekInsert(502,0,'MAN');
      Ein.AF.Nummer   # Ein.P.Nummer;
      Ein.AF.Position # Ein.P.Position;
      RecRead(502,1,0);
      Erx # RecLink(502,501,12,_recNext);
    END;

    // Aufpreisen kopieren...
    Erx # RecLink(503,501,7,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Ein.Z.Nummer   # ProtokollBuffer[501]->Ein.P.Nummer;
      Ein.Z.Position # ProtokollBuffer[501]->Ein.P.Position;
      RekInsert(503,0,'MAN');
      Ein.Z.Nummer   # Ein.P.Nummer;
      Ein.Z.Position # Ein.P.Position;
      RecRead(503,1,0);
      Erx # RecLink(503,501,7,_recNext);
    END;

    // Kalkulation kopieren...
    Erx # RecLink(505,501,8,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Ein.K.Nummer   # ProtokollBuffer[501]->Ein.P.Nummer;
      Ein.K.Position # ProtokollBuffer[501]->Ein.P.Position;
      RekInsert(505,0,'MAN');
      Ein.K.Nummer   # Ein.P.Nummer;
      Ein.K.Position # Ein.P.Position;
      RecRead(505,1,0);
      Erx # RecLink(505,501,8,_recNext);
    END;

    RecBufCopy(ProtokollBuffer[500],500);
    if (mode<>c_ModeEdit) then begin
      RecBufDestroy(ProtokollBuffer[500]);
      ProtokollBuffer[500]    # 0;
    end;

    Lib_MoreBufs:RecInit(501, y, y);

    Ein.P.Nummer      # FldInt(ProtokollBuffer[501],1,1);
    Ein.P.Position    # FldWord(ProtokollBuffer[501],1,2);
    Ein.P.AB.Nummer # FldAlpha(ProtokollBuffer[501],1,67);  // 19.10.2016

    Ein.P.Materialnr      # 0;
    "Ein.P.Stückzahl"     # Ein.P.FM.Rest.Stk;
    Ein.P.Gewicht         # Ein.P.FM.Rest;
    Ein.P.FM.VSB          # 0.0;
    Ein.P.FM.Eingang      # 0.0;
    Ein.P.FM.Ausfall      # 0.0;
    Ein.P.FM.Rest         # Ein.P.FM.Rest;
    Ein.P.FM.VSB.Stk      # 0;
    Ein.P.FM.Eingang.Stk  # 0;
    Ein.P.FM.Ausfall.Stk  # 0;
    Ein.P.FM.Rest.Stk     # Ein.P.FM.Rest.Stk;

    if (Ein.P.MEH='kg') then Ein.P.Menge # Rnd(Ein.P.Gewicht,Set.Stellen.Menge);
    else if (Ein.P.MEH='Stk') then Ein.P.Menge # cnvfi("Ein.P.Stückzahl")
    else  Ein.P.Menge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, 0.0, '', Ein.P.MEH);

    if (mode<>c_ModeEdit) then begin
      RecBufDestroy(ProtokollBuffer[501]);
      ProtokollBuffer[501]    # 0;
    end;
    Ein.P.AbrufAufNr        # vAuf;
    Ein.P.AbrufAufPos       # vPos;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end
  else begin
    if (mode<>c_ModeEdit) then begin
      RecBufCopy(ProtokollBuffer[500],500);
      RecBufDestroy(ProtokollBuffer[500]);
      ProtokollBuffer[500]    # 0;
      RecBufCopy(ProtokollBuffer[501],501);
      RecBufDestroy(ProtokollBuffer[501]);
      ProtokollBuffer[501]    # 0;
    end;
  end;

  Ein_P_SMain:Switchmask(n);    // 21.06.2021 AH Proj. 2208/15
  
  // Focus auf Editfeld setzen:
  if ($NB.Page1->wpcustom='NB.Page1_Art') then
    $edEin.P.AbrufAufNr->Winfocusset(true);
  else
    $edEin.P.AbrufAufNr_Mat->Winfocusset(true);

  RefreshIfm('');
  gMDI->WinUpdate(_WinUpdFld2Obj);
end;


//========================================================================
//  AusPreis
//
//========================================================================
sub AusPreis()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(254,0,_RecId,gSelected);
    if (Art.P.Preistyp<>'VK') then begin
      // Feldübernahme
      Ein.P.MEH.Preis   # Art.P.MEH;
      Ein.P.PEH         # Art.P.PEH;
      Wae_Umrechnen(Art.P.Preis,"Art.P.Währung",var ein.P.Grundpreis, "Ein.Währung");
      $edEin.P.PEH->Winupdate(_WinUpdFld2Obj);
      $edEin.P.Preis.MEH->Winupdate(_WinUpdFld2Obj);
    end;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Grundpreis->WinFocusset(true);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial()
local begin
  vStk      : int;
  vProzent  : float;
  vMenge    : float;
  vHdl      : int;
  vI        : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;

    Ein_P_Subs:CopyMatToPos();

    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);

  end;
  // Focus auf Editfeld setzen:
  $edEin.P.Guete_Mat->Winfocusset(true);

  Refreshifm();

  // ggf. Labels refreshen
  gMdi -> WinUpdate(_WinUpdFld2Obj);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl      : int;
  vNurKopf  : logic;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);


  if (mode<>c_ModeList2) then
    Ein_P_SMain:SwitchMask($NB.Main->wpcurrent='NB.Page1')
  else if ($ZL.Erfassung->wpdbrecid<>0) then
    Ein_P_SMain:SwitchMask($NB.Main->wpcurrent='NB.Page1');


  if (Ein.P.Nummer<>0) and (Ein.P.Nummer<1000000000) and
    (mode<>c_ModeList2) and (Mode<>c_ModeNew) and (mode<>c_ModeNew2) and (mode<>c_ModeEdit2) and (Mode<>c_modeedit) then begin
      RecLink(500,501,3,_RecFirst);
  end;

  // Button & Menüs sperren
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_P_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_P_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_P_Aendern]=n) or
                      ("Ein.P.Löschmarker"='*');
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_P_Aendern]=n) or
                      ("Ein.P.Löschmarker"='*');

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_P_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');

  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_EK_P_Loeschen]=n);

  // ---- 2009-04-08 TM ----
  vHdl # gMenu->WinSearch('Mnu.Reserv');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Mat_Reservierung]=n) or // 2022-09-30  AH Proj. 2314/31 (Ein.LiefervertragYN) or
                    (Ein.Vorgangstyp<>c_Bestellung) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  vHdl # gMenu->WinSearch('Mnu.Aktionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_EK_Aktion]=n) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  vHdl # gMenu->WinSearch('Mnu.Eingaenge');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_EK_Wareneingang]=n) or (Ein.LiefervertragYN) or
                    (Ein.Vorgangstyp<>c_Bestellung) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  vHdl # gMenu->WinSearch('Mnu.KopfAufpreise');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_EK_Aufpreise]=n);
  vHdl # gMenu->WinSearch('Mnu.PosAufpreise');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_EK_Aufpreise]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.Bestellung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
        or (Ein.Vorgangstyp<>c_Bestellung)
        or (Ein.Freigabe.Datum=0.0.0)
        or (w_Auswahlmode) or (Rechte[Rgt_EK_Druck_Best]=n);
  vHdl # gMenu->WinSearch('Mnu.Druck.Anfrage');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
        or (Ein.Vorgangstyp<>c_Anfrage)
        or (w_Auswahlmode) or (Rechte[Rgt_EK_Druck_Best]=n);

  vHdl # gMenu->WinSearch('Mnu.Anf2Best');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeList)) or
        (w_Auswahlmode) or (Rechte[Rgt_EK_P_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.AnfCopy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeList)) or
        (w_Auswahlmode) or (Rechte[Rgt_EK_P_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.Restore');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Abl_Ein_Restore]=n) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  vHdl # gMenu->WinSearch('Mnu.Artikel');
  if (vHdl <> 0) then
    vHdl->wpdisabled # (Rechte[Rgt_Ein_P_Change_Artikel]=n) or
      ((Mode<>c_ModeList) and (Mode<>c_ModeView));

  vHdl # gMenu->WinSearch('Mnu.Append');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_EK_P_Anlegen]=n) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  vHdl # gMenu->WinSearch('Mnu.Edit.LfArtNr');
  if (vHdl != 0) then
    vHdl->wpDisabled # ((Mode = c_ModeEdit) or (Mode = c_ModeNew) or (Rechte[Rgt_EK_P_Aendern] = false));

  vHdl # gMenu->WinSearch('Mnu.Edit.Lieferant');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeList)) or
      (Rechte[Rgt_EK_LiefTauschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Liefervertrag');
  if (vHdl != 0) then
    vHdl->wpDisabled # ((Mode = c_ModeEdit) or (Mode = c_ModeNew) or (Ein.LiefervertragYN));


// ST 2023-01-03 Feature obsolet
/*
  vHdl # gMenu->WinSearch('Mnu.ausExcel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeNew2)) or
      (w_Auswahlmode) or (Rechte[Rgt_EK_ausExcel]=n);
*/

  vHdl # gMenu->WinSearch('Mnu.DMS');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) and (Mode<>c_ModeView);

  vHdl # gMenu->WinSearch('Mnu.Kommission');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Ein_Kommission] = false) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  vHdl # gMenu->WinSearch('Mnu.Ein2Verpackung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Ein_Ein2Verpackung] = false) or
                    (Ein.Vorgangstyp<>c_Bestellung) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  vHdl # gMenu->WinSearch('Mnu.Protokoll');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Ein_Protokoll]=n);
  vHdl # gMenu->WinSearch('Mnu.Protokoll.Kopf');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Ein_Protokoll]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Ein_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Ein_Excel_Import]=false;


  if (Mode=c_ModeList2) then begin
    vNurKopf # RecLinkInfo(501,500,9,_recCount)=0;
    if (vNurKopf) then begin
      $NB.Page1->wpdisabled # y;
      $NB.Page2->wpdisabled # y;
      $NB.Page3->wpdisabled # y;
      $NB.Page4->wpdisabled # y;
      $NB.Page5->wpdisabled # y;
    end;
  end
  else if (Mode<>c_ModeNew) then begin
    $NB.Page1->wpdisabled # n;
    $NB.Page2->wpdisabled # n;
    $NB.Page3->wpdisabled # n;
    $NB.Page4->wpdisabled # n;
    $NB.Page5->wpdisabled # n;
  end;
  $NB.KopfText->wpdisabled # (Mode=c_ModeNew) or (vNurKopf);
  $NB.Fusstext->wpdisabled # (Mode=c_ModeNew) or (vNurKopf);

  // Position anhängen?
  if (w_AppendNr<>0) then $NB.Kopf->wpdisabled # y;

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
  Erx   : int;
  vHdl  : handle;
  vQ    : alpha(4000);
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.Edit.LfArtNr' : begin
      Ein_Subs:ChangeLieferantenArtnr();
    end;


    'Mnu.Filter.EinNr' : begin
      Ein_P_subs:SelEinNr();
      RETURN true;
    end;


    'Mnu.Filter.Abruf' : begin
      Ein_P_subs:SelAbruf();
      RETURN true;
    end;

    
    'Mnu.Anf2Best'  : begin
      Ein_Subs:Anf2Best();
      Refreshlist(gZLList,_WinLstRecFromRecID | _WinLstRecDoSelect);
/*
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      if (gMDI=cDialog2) then begin
        vNr # Auf.Nummer;
        cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
        Auf.Nummer # vNr;
        RecRead(400,1,0);
      end;
*/
    end;


    'Mnu.AnfCopy'   : Ein_Subs:Anf2Anf();


    'Mnu.Auswahl' : begin
      vHdl # WinFocusGet();
      if (vHdl<>0) then begin
        case (vHdl->wpname) of
          'edEin.P.Grundpreis'        :   Auswahl('Preis');
         end;
      end;
    end;


    'Mnu.Kommission' : begin
      if(Rechte[Rgt_Ein_Kommission]) then begin
        if(Ein_Data:DeleteKommission() = true) then
          Msg(200401, '', 0, 0, 0);
        else
          ErrorOutput;
      end;
    end;


    'Mnu.Filter.Start' : begin
      Ein_P_Mark_Sel('501.xml');
      RETURN true;
    end;


    'Mnu.Aktivitaeten' : begin
      TeM_Subs:Start(501);
    end;


    'Mnu.Mark.Sel' : begin
      Ein_P_Mark_Sel();
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(501,Ein.P.Anlage.Datum, Ein.P.Anlage.Zeit, Ein.P.Anlage.User, "Ein.P.Lösch.Datum", "Ein.P.Lösch.Zeit", "Ein.P.Lösch.User");
    end;


    'Mnu.Protokoll.Kopf' : begin
      PtD_Main:View(500,Ein.Anlage.Datum, Ein.Anlage.Zeit, Ein.Anlage.User);
    end;


    'Mnu.Neu.AusAuftrag' : begin
      Ein_Subs:CopyAuftragAuswahl();
    end;


    'Mnu.Neu.AusAufNr' : begin
      Ein_Subs:CopyAuftrag(0,0);
    end;


    'Mnu.Neu.AusBestellung' : begin
      Ein_Subs:CopyBestellungAuswahl();
    end;


    'Mnu.Neu.AusBestellungAblage' : begin
      Ein_Subs:CopyBestellungAuswahl('ABLAGE');
    end;


    'Mnu.Neu.AusBestellnr' : begin
      Ein_Subs:CopyBestellung();
    end;


    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edEin.P.Grundpreis') then begin
        RecLink(100,501,4,0);             // Lieferant holen
        if (Art_P_Data:FindePreis('EK', Adr.Nummer, Ein.P.Menge, Ein.P.MEH.Preis, 1)) then begin
          Ein.P.Grundpreis     # Art.P.PreisW1;
          $edEin.P.GrundPreis->Winupdate(_WinUpdFld2Obj);
          Refreshifm();
        end;
      end;
      if (aEvt:Obj->wpname='edEin.P.Grundpreis_Mat') and (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
        RecLink(100,501,4,0);             // Lieferant holen
        if (Art_P_Data:FindePreis('EK', Adr.Nummer, Ein.P.Menge, Ein.P.MEH.Preis, 1)) then begin
          Ein.P.Grundpreis     # Art.P.PreisW1;
          $edEin.P.Grundpreis_Mat->Winupdate(_WinUpdFld2Obj);
          Refreshifm();
        end;
      end;
      if (aEvt:Obj->wpname='edEin.P.Dickentol_Mat') then  MTo_Data:BildeVorgabe(501,'Dicke');
      if (aEvt:Obj->wpname='edEin.P.Breitentol_Mat') then MTo_Data:BildeVorgabe(501,'Breite');
      if (aEvt:Obj->wpname='edEin.P.Laengentol_Mat') then MTo_Data:BildeVorgabe(501,'Länge');

      if (aEvt:Obj->wpname='edEin.P.Menge') then begin
        Ein.P.Menge # Lib_Einheiten:WandleMEH(501, 0, 0.0, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Ein.P.MEH);
        $edEin.P.Menge->winupdate(_WinUpdFld2Obj);
        $edEin.P.Menge->winFocusset(true);
//        EvtChanged(aEvt);
      end;
      if (aEvt:Obj->wpname='edEin.P.Gewicht_Mat') then begin
        Ein.P.Gewicht   # Ein_P_Subs:CalcGewicht(); // 22.06.2022 AH
        $edEin.P.Gewicht_Mat->winupdate(_WinUpdFld2Obj);
      end;
      if (aEvt:Obj->wpname='edEin.P.Stueckzahl_Mat') then begin
        "Ein.P.Stückzahl" # Lib_Berechnungen:STK_aus_KgDBLWgrArt(Ein.P.Gewicht, Ein.P.Dicke, Ein.P.Breite, "Ein.P.länge", Ein.P.Warengruppe, "Ein.P.Güte", Ein.P.Artikelnr);
        $edEin.P.Stueckzahl_Mat->WinUpdate( _winUpdFld2Obj );
      end;
      if (aEvt:Obj->wpname='edEin.P.Dickentol_Mat') then  MTo_Data:BildeVorgabe(501,'Dicke');
      if (aEvt:Obj->wpname='edEin.P.Breitentol_Mat') then MTo_Data:BildeVorgabe(501,'Breite');
      if (aEvt:Obj->wpname='edEin.P.Laengentol_Mat') then MTo_Data:BildeVorgabe(501,'Länge');
      if (aEvt:Obj->wpname='edEin.P.TextNr2b') then begin
        RecLink(100,500,1,_RecFirst);   // Lieferant holen
        Ein.P.TextNr2 # Txt_Data:Automatisch(501, "Ein.P.Gütenstufe", "Ein.P.Güte", Ein.P.Warengruppe, Adr.Nummer);
        $edEin.P.TextNr2b->wpcaptionint # Ein.P.TextNr2;
        //Refreshifm('edEin.P.TextNr2b',y);
        vHDL # $Ein.P.TextEdit1->wpdbTextBuf;
        Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vHdl, Ein.Sprache);
        $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
      end;
    end;

    
    'Mnu.Edit.Lieferant' : begin
      Ein_Data:TauscheLieferant();
    end;


    'Mnu.Liefervertrag' : begin
      if ( Ein.LiefervertragYN ) or (Ein.AbrufYN) then
        RETURN true;

      if (msg(500013,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      
        if ( RecLinkInfo( 506, 500, 19, _recCount ) > 0 ) then begin
          Msg( 500012, '', 0, 0, 0 );
        end
        else begin
          RecRead( 500, 1, _recLock );
          Ein.LiefervertragYN # true;
          Ein.AbrufYN   # false;
          if ( RekReplace( 500, _recUnlock,'AUTO') != _rOk ) then
            Msg( 999999, 'Änderungen können nicht vorgenommen werden.', 0, 0, 0 );
          else
            Msg( 999998, '', 0, 0, 0 );
        end;
      end;
    end;


// ST 2023-01-03 Feature obsolet
/*
    'Mnu.ausExcel' : begin
      if (Ein_Data:AusExcel()=true) then begin
        vTmp # gMdi->winsearch('NB.Erfassung');
        vTmp->wpdisabled # false;
        vTmp->wpvisible # true;
        vTmp # gMdi->winsearch('NB.Main');
        vTmp->wpCurrent # 'NB.Erfassung';
        $ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
      end;
    end;
*/

    'Mnu.Artikel' : begin
// ST 2013-10-21: Artikelnummer auch "einfügbar" machen Prj. 1304/215
//      if (Ein.P.Artikelnr='') then RETURN true;
      if (Rechte[Rgt_Ein_P_Change_Artikel]) then
        Ein_Data:ModifyArtikel();
    end;


    'Mnu.Append' : begin
      w_AppendNr # Ein.P.Nummer;
      App_Main:Action(c_ModeNew);
      end;


    'Mnu.DMS' : begin
      RecLink(100,500,1,_Recfirst);   // Lieferant holen
      DMS_ArcFlow:ShowAbm('EIN', Ein.Nummer, Adr.Nummer);
    end;

    'Mnu.Druck.DmsDeckblatt'  : begin
      Lib_Dokumente:Printform(500,'DMS Deckblatt',false);
    end;


    'Mnu.Restore' : begin
      Ein_Abl_Data:RestoreAusAblage();
      RecRead(501,1,0);
      RefreshList(gZLList, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    // ---- 2009-04-08 TM ----
    'Mnu.Reserv' : begin
      Auswahl('Reservierungen');
    end;


    'Mnu.Aktionen' : begin
      Auswahl('Aktionen');
    end;


    'Mnu.Eingaenge' : begin

      // Lohnbestellung?
      if (AAr.Nummer<>Ein.P.Auftragsart) then
        Erx # RekLink(835,501,5,_recFirst);   // Auftragsart holen
      if (AAr.Berechnungsart>=700) and (AAr.Berechnungsart<=799) then begin
        FOR Erx # RecLink(504,501,15,_recFirst)   // Aktionen loopen...
        LOOP Erx # RecLink(504,501,15,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (Ein.A.Aktionstyp<>c_Akt_BA) then CYCLE;
          if ("Ein.A.Löschmarker"='*') then CYCLE;

          BAG.P.Nummer    # Ein.A.Aktionsnr;
          BAG.P.Position  # Ein.A.Aktionspos;
          Erx # RecRead(702,1,0);               // BAG-Position holen
          if (Erx<=_rLocked) then begin
            BA1_FM_Main:Start(BAG.P.Nummer, BAG.P.Position, 0, 0, '', y);
          end;
        END;

        RETURN true;
      end;

      RecLink(819,501,1,_RecFirst);     // Warengruppe holen
      if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
        RecBufClear(506);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.Mat.Verwaltung',here+':AusEingaenge',y);
        Filter_Ein_E # y;
/**
VarInstance( WindowBonus, CnvIA( gMDI->wpCustom ) );
gZLList->wpdbLinkFileno  # 0;
gZLList->wpdbKeyno       # 1;
gZLList->wpdbfileno      # 506;
Lib_Sel:QInt(var vQ, 'Ein.E.Nummer', '=', Ein.P.Nummer);
Lib_Sel:QInt(var vQ, 'Ein.E.Position', '=', Ein.P.Position);
Lib_Sel:QAlpha(var vQ, 'Ein.E.Löschmarker', '=' ,'');
Lib_Sel:QRecList( 0, VQ);
**/
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
      if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then begin
        RecBufClear(506);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.Verwaltung',here+':AusEingaenge',y);
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.Kalkulation' : begin
      Auswahl('Kalkulation');
    end;


    'Mnu.PosAufpreise' : begin
      Auswahl('Aufpreise');
    end;


    'Mnu.KopfAufpreise' : begin
      Auswahl('KopfAufpreise');
    end;


    'Mnu.Druck.Bestellung' : begin
      Ein_Subs:DruckBest();
    end;


    'Mnu.Copy.Bestellung' : begin   // 2022-07-18 AH
      Ein_Data:CopyGesamteBestellung();
      RETURN true;
    end;


    'Mnu.Druck.Anfrage' : begin
      Ein_Subs:DruckAnfrage();
    end;

    'Mnu.Mark.SetField' : begin
      Lib_Mark:SetField(gFile);
    end;
    
    'Mnu.Ein2Verpackung' : begin
      Ein_Data:Ein2Verpackung();
    end;


  end; // case

end;


//========================================================================
//  IsPageActive
//========================================================================
Sub IsPageActive(aName : alpha) : logic;
begin
  RETURN aName<>'NB.Kopftext' and aName<>'NB.Fusstext';
end


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vName   : alpha;
  vQ      : alpha(4096);
end;
begin

  if (aEvt:Obj->wpname='bt.AnalyseErweitert') then Auswahl('AnalyseErweitert');

  if (aEvt:Obj->wpName='bt.InternerText') then begin
    if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
      vName # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01'
    else
      vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
    Mdi_RtfEditor_Main:Start(vName, Rechte[Rgt_EK_P_Aendern], Translate('interner Text'));
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of

    'bt.Vorgangstyp'      :   Auswahl('Vorgangstyp');
    'bt.Lieferant'        :   Auswahl('Lieferant');
    'bt.Lieferadresse'    :   Auswahl('Lieferadresse');
    'bt.Lieferanschrift'  :   Auswahl('Lieferanschrift');
    'bt.Verbraucher'      :   Auswahl('Verbraucher');
    'bt.RechEmpf'         :   Auswahl('Rechnungsempf');
    'bt.ABBearbeiter'     :   Auswahl('Ansprechpartner');
    'bt.BDS'              :   Auswahl('BDS');
    'bt.Land'             :   Auswahl('Land');
    'bt.Waehrung'         :   Auswahl('Waehrung');
    'bt.Lieferbed'        :   Auswahl('Lieferbed');
    'bt.Zahlungsbed'      :   Auswahl('Zahlungsbed');
    'bt.Versandart'       :   Auswahl('Versandart');

    'bt.Steuerschluessel' :   Auswahl('Steuerschluessel');

    'bt.Sprache'          :   Auswahl('Sprache');
    'bt.AbmEH'            :   Auswahl('AbmessungsEH');
    'bt.GewEH'            :   Auswahl('GewichtsEH');
    'bt.Sachbearbeiter'   :   Auswahl('Sachbearbeiter');
    'bt.Verband'          :   Auswahl('Verband');

    'bt.Kopftext'         :   Auswahl('Kopftext');
    'bt.Fusstext'         :   Auswahl('Fusstext');

    'bt.Auftragsart'      :   Auswahl('Auftragsart');
    'bt.Abruf'            :   Auswahl('Abruf');
    'bt.Warengruppe'      :   Auswahl('Warengruppe');
    'bt.LiefArtNr'        :   Auswahl('LiefArtNr');
    'bt.Artikelnummer'    :   Auswahl('Artikelnummer');
    'bt.Kommission'       :   Auswahl('Kommission');
    'bt.Projekt'          :   Auswahl('Projekt');
    'bt.Kostenstelle'     :   Auswahl('Kostenstelle');
    'bt.MEH'              :   Auswahl('WunschMEH');
    'bt.PreisMEH'         :   Auswahl('PreisMEH');
    'bt.Kalkulation'      :   Auswahl('Kalkulation');
    'bt.Aufpreise'        :   Auswahl('Aufpreise');
    'bt.Preis'            :   Auswahl('Preis');
    'bt.Autoaufpreis'     :   begin
      if (FldInfoByName('Ein.P.Cust.PreisZum',_FldExists)>0) then
        ApL_Data:AutoGenerieren(501,n ,0, FldDateByName('Ein.P.Cust.PreisZum'))
      else
        ApL_Data:AutoGenerieren(501);
      Ein_Data:SumAufpreise(Mode);
      Ein.P.Gesamtpreis # Auf_data:SumGesamtpreis(Ein.P.Menge, "Ein.P.Stückzahl" , Ein.P.Gewicht);
      $lb.Aufpreise->wpcaption # ANum(Ein.P.Aufpreis,2);
      $RL.Aufpreise->winupdate(_winupdon,_WinLstFromFirst);
    end;

    'bt.Auftragsart_Mat'    :   Auswahl('Auftragsart');
    'bt.Abruf_Mat'          :   Auswahl('Abruf');
    'bt.Warengruppe_Mat'    :   Auswahl('Warengruppe');
    'bt.Projekt_Mat'        :   Auswahl('Projekt');
    'bt.Artikelnummer_Mat'  :   Auswahl('Artikelnummer_Mat');
    'bt.Guete_Mat'          :   Auswahl('Guete');
    'bt.Guete'              :   Auswahl('Guete');
    'bt.Guetenstufe_Mat'    :   Auswahl('Guetenstufe');
    'bt.AusfOben_Mat'       :   Auswahl('AusfOben');
    'bt.AusfUnten_Mat'    :   Auswahl('AusfUnten');
    'bt.LiefArtNr_Mat'    :   Auswahl('LiefArtNr');
    'bt.Zeugnis_Mat'      :   Auswahl('Zeugnis');
    'bt.Zeugnis'          :   Auswahl('Zeugnis');
    'bt.Kommission_Mat'   :   Auswahl('Kommission');
    'bt.Erzeuger_Mat'     :   Auswahl('Erzeuger');
    'bt.Intrastat_Mat'    :   Auswahl('Intrastat');
    'bt.Intrastat'        :   Auswahl('Intrastat');
    'bt.PreisMEH_Mat'     :   Auswahl('PreisMEH');
    'bt.Kalkulation_Mat'  :   Auswahl('Kalkulation');
    'bt.Aufpreise_Mat'    :   Auswahl('Aufpreise');
    'bt.Autoaufpreis_Mat' :   begin
      if (FldInfoByName('Ein.P.Cust.PreisZum',_FldExists)>0) then
        ApL_Data:AutoGenerieren(501,n ,0, FldDateByName('Ein.P.Cust.PreisZum'))
      else
        ApL_Data:AutoGenerieren(501);
      Ein_Data:SumAufpreise(Mode);
      Ein.P.Gesamtpreis # Auf_data:SumGesamtpreis(Ein.P.Menge, "Ein.P.Stückzahl" , Ein.P.Gewicht);
      $lb.Aufpreise_Mat->wpcaption # ANum(Ein.P.Aufpreis,2);
      $RL.Aufpreise_Mat->winupdate(_winupdon,_WinLstFromFirst);
    end;

    'bt.StandardText'     :   Auswahl('Text');
    'bt.Standardtext2'    :   Auswahl('Text2');
    'bt.Zwischenlage'     :   Auswahl('Zwischenlage');
    'bt.Unterlage'        :   Auswahl('Unterlage');
    'bt.Umverpackung'     :   Auswahl('Umverpackung');
    'bt.Verwiegungsart'   :   Auswahl('Verwiegungsart');
    'bt.Etikett'          :   Auswahl('Etikett');
    'bt.Etikett2'         :   Auswahl('Etikett2');
    'bt.Verpackung'       :   Auswahl('Verpackung');
    'bt.Skizze'           :   Auswahl('Skizze');

    'bt.LieferMatArtNr_Mat' : Auswahl('LiefArtNr');

    'bt.Standardtext2.Add' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusTextAdd');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'E'
      vQ # '';
      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'bt.Kopftext.Add' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusKopfTextAdd');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'E'
      vQ # '';
      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'bt.Fusstext.Add' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusFusstextAdd');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'E'
      vQ # '';
      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

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
  Erx     : int;
  vCol    : int;
  vW      : word;
end;
begin
  if (aMark) then begin
    if (RunAFX('Ein.P.EvtLstDataInit','y' + aEvt:obj->wpName)<0) then RETURN;
  end
  else if (RunAFX('Ein.P.EvtLstDataInit','n' + aEvt:obj->wpName)<0) then RETURN;


  if (aEvt:obj->wpname='ZL.Erfassung') then begin
    RETURN;
  end;
  if (Mode=c_ModeList) then RecLink(500,501,3,_RecFirst);  // Kopf holen

  if (aMark) then begin
    vCol # Set.Col.RList.Marke;
  end
  else begin
    vCol # RGB(255,255,255);
  end;

  // Zeilenfarbe anpassen
  if (Ein.Vorgangstyp=c_Anfrage) then vCol # Set.Auf.Col.Ang;
  if (Ein.Vorgangstyp=c_Bestellung) and
    (Ein.Freigabe.Datum=0.0.0) and (Ein.LiefervertragYN=n) then vCol # Set.Auf.Col.Sperre;
  if (Ein.LiefervertragYN) then vCol # Set.Auf.Col.LVertrag;
  if ("Ein.P.Löschmarker"='*') then vCol # Set.Col.RList.Deletd;
  if (aMark=n) then Lib_GuiCom:ZLColorLine(gZLList,vCol);

  // 05.05.2022 AH
  RecBufClear(200);
  if (Ein.P.Materialnr<>0) then Mat_data:Read(Ein.P.Materialnr);


  Erx # RecLink(504,500,15,_RecFirst);  // Aktionen druchlaufen
  WHILE (Erx<=_rLocked) and (Ein.P.Aktionsmarker<>'D') do begin
    if (Ein.A.Aktionstyp=c_Akt_Druck) and ((Ein.A.Bemerkung=c_AktBem_Bestell) or (Ein.A.Bemerkung=c_AktBem_Anfrage) or (Ein.A.Bemerkung='Bestellung')) then
      Ein.P.Aktionsmarker # 'D';
    Erx # RecLink(504,500,15,_RecNext);
  END;

  if (Ein.P.Termin1W.Art='KW') then begin
    GV.Ints.01 # Ein.P.Termin1W.Zahl;
  end
  else begin
    Lib_Berechnungen:KW_aus_Datum(Ein.P.Termin1Wunsch, VAR GV.Ints.01, VAR vW);
  end;

  //Gv.Num.01 # Ein.P.FM.Rest * Ein.P.GrundPreis / CnvFI(Ein.P.PEH);
  Gv.Num.01 # Ein_data:SumGesamtpreis(Ein.P.FM.Rest, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);

  Erx # RecLink(100, 501, 11, _recFirst); // Erzeuger holen
  if(Erx > _rLocked) then
    RecBufClear(100);
  GV.Alpha.10 # Adr.Stichwort;

  // Aufpreis vorhanden?
  if (RecLinkInfo(503,501,7,_Reccount)<>0) then
    $clmGV.Num.01->wpClmColBkg # _WinColLightRed;;



  /// ---------------------------------
  // Jumplogik kennzeichnen
  if (Ein.P.Kommission <> '') then
    Lib_GuiCom:ZLQuickJumpInfo($clmEin.P.Kommission);

  if (Ein.P.Artikelnr <> '') then
    Lib_GuiCom:ZLQuickJumpInfo($clmEin.P.Artikelnr);

//  Refreshmode();


end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect ( aEvt : event; aRecID : int; ) : logic
begin
  if ( aRecId = 0 ) then
    RETURN true;
  RecRead( gFile, 0, _recId, aRecID );

  if ( RunAFX( 'Ein.P.EvtLstSelect', aEvt:obj->wpName ) < 0 ) then
    RETURN true;

  if ( aEvt:obj->wpName = 'ZL.EKPositionen' ) then begin
    Ein_P_SMain:SwitchMask( false );
  end;

  RefreshMode( true );
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged
(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx     : int;
  vName   : alpha;
  vTxtHdl : int;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbEin.LiefervertragYN') then begin
    if (Ein.LiefervertragYN) then begin
      Lib_guiCom:Enable($edEin.GltigkeitVom);
      Lib_guiCom:Enable($edEin.GltigkeitBis);
      Ein.AbrufYN # n;
      $cbEin.AbrufYN->winupdate(_WinUpdFld2Obj);
    end
    else begin
      Lib_guiCom:Disable($edEin.GltigkeitVom);
      Lib_guiCom:Disable($edEin.GltigkeitBis);
    end;
  end;
  if (aEvt:Obj->wpname='cbEin.AbrufYN') and (Ein.AbrufYN) then begin
    Lib_guiCom:Disable($edEin.GltigkeitVom);
    Lib_guiCom:Disable($edEin.GltigkeitBis);
    Ein.LiefervertragYN # n;
    $cbEin.LiefervertragYN->winupdate(_WinUpdFld2Obj);
  end;


  if (aEvt:Obj->wpname='cbEin.P.StehendYN') and (Ein.P.StehendYN) then begin
    Ein.P.LiegendYN # n;
    $cbEin.P.LiegendYN->winupdate(_WinUpdFld2Obj);
  end;
  if (aEvt:Obj->wpname='cbEin.P.LiegendYN') and (Ein.P.LiegendYN) then begin
    Ein.P.StehendYN # n;
    $cbEin.P.StehendYN->winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpname='cbEin.WaehrungFixYN') then begin
    if ("Ein.WährungFixYN") then begin
      Lib_GuiCom:Enable($edEin.Waehrungskurs);
    end
    else begin
      Lib_GuiCom:Disable($edEin.Waehrungskurs);
    end;
    Erx # RecLink(814,500,8,0);   // Währung holen
    if (Erx<=_rLocked) and ("Ein.WährungFixYN"=y) then
      "Ein.Währungskurs" # Wae.EK.Kurs;
    else
      "Ein.Währungskurs" # 0.0;
    $edEin.Waehrungskurs->winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpName='cb.Text1') then begin
    if ($cb.Text1->wpCheckState=_WinStateChkChecked) then begin
      $cb.Text2->wpcheckstate # _WinStateChkUnchecked;
      $cb.Text3->wpcheckstate # _WinStateChkUnchecked;
      Ein.P.TextNr1 # 500;
      Ein.P.TextNr2 # 0;
      $edEin.P.TextNr2b->wpCaptionInt # 0;
      EinPTextRead();
      RefreshIfm('Text');
    end;
  end;
  if (aEvt:Obj->wpName='cb.Text2') then begin
    if ($cb.Text2->wpCheckState=_WinStateChkChecked) then begin
      $cb.Text1->wpcheckstate # _WinStateChkUnchecked;
      $cb.Text3->wpcheckstate # _WinStateChkUnchecked;
      Ein.P.TextNr1 # 0;
      Ein.P.TextNr2 # 0;
      $edEin.P.TextNr2b->wpCaptionInt # 0;
      EinPTextRead();
      RefreshIfm('Text');
    end;
  end;
  if (aEvt:Obj->wpName='cb.Text3') then begin
    if ($cb.Text3->wpCheckState=_WinStateChkChecked) then begin
      $cb.Text1->wpcheckstate # _WinStateChkUnchecked;
      $cb.Text2->wpcheckstate # _WinStateChkUnchecked;

      vName # '~837.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);

      Ein.P.TextNr1 # 501;
      Ein.P.TextNr2 # 0;
      $edEin.P.TextNr2b->wpCaptionInt # 0;

      vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
      Lib_Texte:TxtLoadLangBuf(vName,vTxtHdl, Ein.Sprache);

      if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then
        vName # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
      else
        vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      $Ein.P.TextEdit1->wpcustom # vName;
      $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);


//      EinPTextRead();
      RefreshIfm('Text');
    end;
  end;

  RETURN true;
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTxtHdl : int;
end;
begin

  vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
  if (vTxtHdl<>0) then begin
    TextClose(vTxtHdl);
    $Ein.P.TextEdit1->wpdbTextBuf # 0;
  end;
  vTxtHdl # $Ein.P.TextStammdaten->wpdbTextBuf;
  if (vTxtHdl<>0) then begin
    TextClose(vTxtHdl);
  end;

  vTxtHdl # $Ein.P.TextEditKopf->wpdbTextBuf;
  if (vTxtHdl<>0) then begin
    TextClose(vTxtHdl);
    $Ein.P.TextEdit1->wpdbTextBuf # 0;
  end;
  vTxtHdl # $Ein.P.TextEditFuss->wpdbTextBuf;
  if (vTxtHdl<>0) then begin
    TextClose(vTxtHdl);
    $Ein.P.TextEdit1->wpdbTextBuf # 0;
  end;

  if ((w_AuswahlMode=n) or (w_Context<>'')) then Lib_GuiCom:RememberList($ZL.Erfassung,'EIN.');

  RETURN true;
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

  if (aPage<>0) then begin
    RefreshIfm(aPage->wpName);
  end;

  // AnalyseErweitert
  if (aSelecting) and (aPage->wpName='NB.Page4') and (Set.LyseErweitertYN) then begin
    w_TimerVar # 'AnalyseErweitert';
    gTimer2 # SysTimerCreate(300,1,gMdi);
  end;

  RETURN true;
end;


//========================================================================
// EinPTextSave
//              Text abspeichern
//========================================================================
sub EinPTextSave()
local begin
  vTxtHdl     : int;          // Handle des Textes
  vName       : alpha;
end;
begin

  vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;
  $Ein.P.TextEdit1->WinUpdate(_WinUpdObj2Buf);
  if (Ein.P.TextNr1=501) then begin   // individueller Text??
    if (Ein.Nummer=0) or (Ein.Nummer>1000000000) then begin
      vName # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    end
    else begin
      vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    end;
  end
  else begin
    vName # '';
    TxtDelete(myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3),0)
  end;

  // PosText speichern
  if ($Ein.P.TextEdit1->wpcustom=vName) and (vName<>'') then begin
    if ((TextInfo(vTxtHdl,_TextSize)+TextInfo(vTxtHdl,_TextLines))=0) then
      TxtDelete(vName,0)
    else
      TxtWrite(vTxtHdl,vName, _TextUnlock);
  end;


  // KopfTextBuffer holen
  vTxtHdl # $Ein.P.TextEditKopf->wpdbTextBuf;
  $Ein.P.TextEditKopf->WinUpdate(_WinUpdObj2Buf);
  if (Ein.Nummer=0) or (Ein.Nummer>1000000000) then
    vName # myTmpText+'.501.K'
  else
    vName # '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K';
  // Kopftext speichern
  if ($Ein.P.TextEditKopf->wpcustom=vName) then begin
    if ((TextInfo(vTxtHdl,_TextSize)+TextInfo(vTxtHdl,_TextLines))=0) then
      TxtDelete(vName,0)
    else
      TxtWrite(vTxtHdl,vName, _TextUnlock);
  end;


  // FussTextBuffer holen
  vTxtHdl # $Ein.P.TextEditFuss->wpdbTextBuf;
  $Ein.P.TextEditFuss->WinUpdate(_WinUpdObj2Buf);
  if (Ein.Nummer=0) or (Ein.Nummer>1000000000) then
    vName # myTmpText+'.501.F'
  else
    vName # '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F';
  // Kopftext speichern
  if ($Ein.P.TextEditFuss->wpcustom=vName) then begin
    if ((TextInfo(vTxtHdl,_TextSize)+TextInfo(vTxtHdl,_TextLines))=0) then
      TxtDelete(vName,0)
    else
      TxtWrite(vTxtHdl,vName, _TextUnlock);
  end;

END;


//========================================================================
// EinPTextRead
//              Text einlsesen
//========================================================================
sub EinPTextRead()
local begin
  vTxtHdl     : int;          // Handle des Textes
  vName       : alpha;
end
begin
   if (Ein.P.TextNr2 = 0) then
    RecBufClear(837);


  // PosText laden
  vTxtHdl # $Ein.P.TextEdit1->wpdbTextBuf;

  if (Ein.P.Nummer=0) or (Ein.P.Nummer>1000000000) then begin // temporär???
    vName # myTmpText+'.501.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (Ein.P.TextNr1=500) then   // anderer PosText?
      vName # myTmpText+'.501.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (Ein.P.TextNr1=0) then     // Standard Text?
      vName # '~837.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  end
  else begin  // echt...
    if (Ein.P.TextNr1=501) then   // individuelker Text?
      vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      //vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (Ein.P.TextNr1=500) then   // anderer PosText?
      vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      //vName # '~501.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (Ein.P.TextNr1=0) then     // Standard Text?
      vName # '~837.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  end;


  if ($Ein.P.TextEdit1->wpcustom<>vName) or (Mode=c_ModeView) then begin
    if (StrFind(vName,'~837',0)<>0) then begin
      Lib_Texte:TxtLoadLangBuf(vName,vTxtHdl, Ein.Sprache);
    end
    else begin
      if (TextRead(vTxtHdl,vName, _TextUnlock)>_rLocked) then begin
        TextClear(vTxtHdl);
//        vName # '';
      end;
    end;
    $Ein.P.TextEdit1->wpcustom # vName;
    $Ein.P.TextEdit1->WinUpdate(_WinUpdBuf2Obj);
  end;

  // KopfText laden
  vTxtHdl # $Ein.P.TextEditKopf->wpdbTextBuf;
  if (Ein.Nummer=0) or (Ein.Nummer>1000000000) then
    vName # myTmpText+'.501.K';
  else
    vName # '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K';
  if ($Ein.P.TextEditKopf->wpcustom<>vName) or (Mode=c_ModeView) then begin
    if (TextRead(vTxtHdl,vName, _TextUnlock)>_rLocked) then
      TextClear(vTxtHdl);
    $Ein.P.TextEditKopf->wpcustom # vName;
    $Ein.P.TextEditKopf->WinUpdate(_WinUpdBuf2Obj);
  end;

  // FussText laden
  vTxtHdl # $Ein.P.TextEditFuss->wpdbTextBuf;
  if (Ein.Nummer=0) or (Ein.Nummer>1000000000) then
    vName # myTmpText+'.501.F'
  else
    vName # '~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F';
  if ($Ein.P.TextEditFuss->wpcustom<>vName) or (Mode=c_ModeView) then begin
    if (TextRead(vTxtHdl,vName, _TextUnlock)>_rLocked) then
      TextClear(vTxtHdl);
    $Ein.P.TextEditFuss->wpcustom # vName;
    $Ein.P.TextEditFuss->WinUpdate(_WinUpdBuf2Obj);
  end;

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
  Ein.AF.Bezeichnung # StrCut(Ein.AF.Bezeichnung + ':'+Ein.AF.Zusatz, 1, 32);
  RETURN Ein.AF.Seite='1';
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
  Ein.AF.Bezeichnung # StrCut(Ein.AF.Bezeichnung + ':'+Ein.AF.Zusatz, 1, 32);
  RETURN Ein.AF.Seite='2';
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
  Lib_GuiCom:Pflichtfeld($edEin.Lieferantennr);
  Lib_GuiCom:Pflichtfeld($edEin.Lieferadresse);
  Lib_GuiCom:Pflichtfeld($edEin.lieferanschrift);
  //Lib_GuiCom:Pflichtfeld($edEin.Rechnungsempf);
  Lib_GuiCom:Pflichtfeld($edEin.Waehrung);
  Lib_GuiCom:Pflichtfeld($edEin.Lieferbed);
  Lib_GuiCom:Pflichtfeld($edEin.Zahlungsbed);
  Lib_GuiCom:Pflichtfeld($edEin.Versandart);

  Lib_GuiCom:Pflichtfeld($edEin.Steuerschluessel);

  Lib_GuiCom:Pflichtfeld($edEin.Sprache);
  Lib_GuiCom:Pflichtfeld($edEin.AbmessungsEH);
  Lib_GuiCom:Pflichtfeld($edEin.GewichtsEH);

                              // Artikellogik
  if ($NB.Page1->wpcustom='NB.Page1_Art') then begin
    Lib_GuiCom:Pflichtfeld($edEin.P.Auftragsart);
    Lib_GuiCom:Pflichtfeld($edEin.P.Warengruppe);
    Lib_GuiCom:Pflichtfeld($edEin.P.Termin1Wunsch);
    Lib_GuiCom:Pflichtfeld($edEin.P.Artikelnr);
    Lib_GuiCom:Pflichtfeld($edEin.P.Menge);
    Lib_GuiCom:Pflichtfeld($edEin.P.Menge.Wunsch);
    Lib_GuiCom:Pflichtfeld($edEin.P.MEH.Wunsch);
    Lib_GuiCom:Pflichtfeld($edEin.P.PEH);
    Lib_GuiCom:Pflichtfeld($edEin.P.Preis.MEH);
    //Lib_GuiCom:Pflichtfeld($edEin.P.Grundpreis);
    if (Ein.AbrufYN) then
      Lib_GuiCom:Pflichtfeld($edEin.P.AbrufAufNr);

    if (Wgr_Data:IstMixArt(Ein.P.Wgr.Dateinr)) then
      Lib_GuiCom:Pflichtfeld($edEin.P.Guete);

  end
  else begin
    Lib_GuiCom:Pflichtfeld($edEin.P.Guete_Mat);
    Lib_GuiCom:Pflichtfeld($edEin.P.Auftragsart_Mat);
    Lib_GuiCom:Pflichtfeld($edEin.P.Warengruppe_Mat);
    Lib_GuiCom:Pflichtfeld($edEin.P.Termin1Wunsch_Mat);
    Lib_GuiCom:Pflichtfeld($edEin.P.Gewicht_Mat);
    Lib_GuiCom:Pflichtfeld($edEin.P.PEH_Mat);
    Lib_GuiCom:Pflichtfeld($edEin.P.Preis.MEH_Mat);
    //Lib_GuiCom:Pflichtfeld($edEin.P.Grundpreis_Mat);
    if (Ein.AbrufYN) then
      Lib_GuiCom:Pflichtfeld($edEin.P.AbrufAufNr_Mat);
  end;

end;


//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer(
  aEvt                  : event;        // Ereignis
  aTimerId              : int;
): logic
local begin
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (gTimer2=aTimerId) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;

    if (w_TimerVar='AnalyseErweitert') then begin
      w_TimerVar # '';
      Auswahl('AnalyseErweitert');
    end;
  end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
  end;

  RETURN true;
end;


//========================================================================
// EvtPosChanged [15.03.2010/PW]
//
//========================================================================
sub EvtPosChanged ( aEvt : event; aRect : rect; aClientSize : point; aFlags : int ) : logic
local begin
  vRect : rect;
  vHdl  : int;
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  // Quickbar
  vHdl # Winsearch(gMDI,'gs.Main');
  if (vHdl<>0) then begin
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left+2;
    vRect:bottom    # aRect:bottom-aRect:Top+5;
    vHdl->wparea    # vRect;
  end;

  if ( aFlags & _winPosSized != 0 ) then begin
    vRect           # gZLList->wpArea;
    vRect:right     # aRect:right  - aRect:left - 4;
    vRect:bottom    # aRect:bottom - aRect:top - 28 - 64;
    gZLList->wpArea # vRect;

    Lib_GuiCom:ObjSetPos( $lbEin.P.Info1, 0, vRect:bottom + 8  );
    Lib_GuiCom:ObjSetPos( $lbEin.P.Info2, 0, vRect:bottom + 8 + 28 );

    // RecList:
    vHdl # Winsearch(aEvt:Obj, 'ZL.Erfassung');
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28-w_QBHeight;
    vHdl->wparea # vRect;
  end;

	RETURN true;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vBuf,vBuf2  : int;
  vQ    :  alpha(1000);
end;
begin
  if (aName = StrCnv('clmEin.P.Kommission',_StrUpper) AND (aBuf->Ein.P.Kommission <>'')) then
    Auf_P_Main:Start(0,CnvIa(Str_Token(aBuf->Ein.P.Kommission,'/',1)),CnvIa(Str_Token(aBuf->Ein.P.Kommission,'/',2)),y);

  if (aName = StrCnv('clmEin.P.Artikelnr',_StrUpper) AND (aBuf->Ein.P.Artikelnr<>'')) then
    Art_Main:Start(0, aBuf->Ein.P.Artikelnr,y);
  
   if ((aName =^ 'edEin.Lieferantennr') AND (Ein.Lieferantennr<>0)) then begin
    RekLink(100,500,1,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edEin.Lieferadresse') AND (Ein.Lieferadresse<>0)) then begin
    RekLink(100,500,12,0);   // Lieferadresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edEin.Lieferanschrift') AND (Ein.Lieferanschrift<>0)) then begin
    RekLink(101,500,2,0);   // Lieferanschrit holen
    Adr.A.Adressnr # Ein.Lieferadresse;
    Adr.A.Nummer # Ein.Lieferanschrift;
    RecRead(101,1,0);
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Ein.Lieferadresse);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;
  
   if ((aName =^ 'edEin.Verbraucher') AND (Ein.Verbraucher<>0)) then begin
    RekLink(100,500,3,0);   // Verbraucher holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edEin.Rechnungsempf') AND (Ein.Rechnungsempf<>0)) then begin
    RekLink(100,500,4,0);   // Besitzer holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.AB.Bearbeiter') AND (Ein.AB.Bearbeiter<>'')) then begin
    Adr.P.Name # Ein.AB.Bearbeiter;
    RecRead(102,5,0)
    Lib_Guicom2:JumpToWindow('Adr.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.BDSNummer') AND (Ein.BDSNummer<>0)) then begin
    RekLink(836,500,11,0);   // BDS-Nummer holen
    Lib_Guicom2:JumpToWindow('BDS.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.Waehrung') AND ("Ein.Währung"<>0)) then begin
    RekLink(814,500,8,0);   // Währug holen
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.Lieferbed') AND (Ein.Lieferbed<>0)) then begin
    RekLink(815,500,5,0);   // Lieferbed holen
    Lib_Guicom2:JumpToWindow('LiB.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.Zahlungsbed') AND (Ein.Zahlungsbed<>0)) then begin
    RekLink(816,500,6,0);   // Zahlungsbed holen
    Lib_Guicom2:JumpToWindow('Zab.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.Versandart') AND (Ein.Versandart<>0)) then begin
    RekLink(817,500,7,0);   // Versandart holen
    Lib_Guicom2:JumpToWindow('VsA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.Land') AND (Ein.Land<>'')) then begin
    RekLink(812,500,10,0);   // Eintrittsland holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.Steuerschluessel') AND ("Ein.Steuerschlüssel"<>0)) then begin
    RekLink(813,500,17,0);   // Steuerschlüssel holen
    Lib_Guicom2:JumpToWindow('StS.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edEin.Sachbearbeiter') AND (Ein.Sachbearbeiter<>'')) then begin
    RekLink(813,500,17,0);   // Sacharbeiter holen
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;

  if ((aName =^ 'edEin.Verband') AND (Ein.Verband<>0)) then begin
    RekLink(110,500,20,0);   // Verband holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;

  if ((aName =^ 'edEin.P.Auftragsart') AND (Ein.P.Auftragsart<>0)) then begin
    RekLink(835,501,5,0);   // Auftragsart holen
    Lib_Guicom2:JumpToWindow('AAr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Warengruppe') AND (Ein.P.Warengruppe<>0)) then begin
    RekLink(819,501,1,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Projektnummer') AND (Ein.P.Projektnummer<>0)) then begin
    RekLink(120,501,16,0);   // Projektnummer holen
    Lib_Guicom2:JumpToWindow('Prj.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Kommission') AND (Ein.P.Kommission<>'')) then begin
    Auf.P.Nummer # Ein.P.KommissionNr;
    Auf.P.Position # Ein.P.KommissionPos;
    RecRead(401,1,0);
    Lib_Guicom2:JumpToWindow('Auf.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Guete') AND ("Ein.P.Güte"<>'')) then begin
    "MQu.Güte1" # "Ein.P.Güte";
    RecRead(832,2,0)
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Zeugnisart') AND (Ein.P.Zeugnisart<>'')) then begin
    Zeu.Bezeichnung # Ein.P.Zeugnisart;
    RecRead(839,2,0)
    Lib_Guicom2:JumpToWindow('Zeu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Kostenstelle') AND (Ein.P.Kostenstelle<>0)) then begin
    KSt.Nummer # Ein.P.Kostenstelle;
    recRead(846,2,0)
    Lib_Guicom2:JumpToWindow('KSt.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Artikelnr') AND (Ein.P.Artikelnr<>'')) then begin
    RekLink(250,501,2,0);   // Artikelnumer holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.LieferArtNr') AND (Ein.P.LieferArtNr<>'')) then begin
    Adr.V.KundenArtnr # Ein.P.LieferArtNr;
    RecRead(105,2,0)
    Lib_Guicom2:JumpToWindow('Art.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Intrastatnr') AND (Ein.P.Intrastatnr<>'')) then begin
    MSL.Intrastatnr # Ein.P.Intrastatnr ;
    RecRead(220,2,0)
    Lib_Guicom2:JumpToWindow('MSL.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Auftragsart_Mat') AND (Ein.P.Auftragsart<>0)) then begin
    RekLink(835,501,5,0);   // Auftragsart holen
    Lib_Guicom2:JumpToWindow('AAr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Warengruppe_Mat') AND (Ein.P.Warengruppe<>0)) then begin
    RekLink(819,501,1,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Projektnummer_Mat') AND (Ein.P.Projektnummer<>0)) then begin
    RekLink(120,501,16,0);   // Projektnummer holen
    Lib_Guicom2:JumpToWindow('Prj.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Kommission_Mat') AND (Ein.P.Kommission<>'')) then begin
    Auf.P.Nummer # Ein.P.KommissionNr;
    Auf.P.Position # Ein.P.KommissionPos;
    RecRead(401,1,0);
  
   // RekLink(835,501,5,0);   // Komission holen
    Lib_Guicom2:JumpToWindow('Auf.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Guetenstufe_Mat') AND ("Ein.P.Gütenstufe"<>'')) then begin
    MQu.S.Stufe # "Ein.P.Gütenstufe";
    RecRead(848,1,0);
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edEin.P.Guete_Mat') AND ("Ein.P.Güte"<>'')) then begin
    "MQu.Güte1" # "Ein.P.Güte";
    RecRead(832,2,0);
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Zeugnisart_Mat') AND (Ein.P.Zeugnisart<>'')) then begin
    Zeu.Bezeichnung # Ein.P.Zeugnisart;
    Recread(839,2,0);
    Lib_Guicom2:JumpToWindow('Zeu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.LieferMatArtNr_Mat') AND (Ein.P.LieferArtNr<>'')) then begin
    Art.P.ArtikelNr # Ein.P.LieferArtNr;
    RecRead(254,1,0);
    Lib_Guicom2:JumpToWindow('Art.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Artikelnr_Mat') AND (aBuf<>0)) then begin
    todo('Artikelnummer_Mat')
    //RekLink(250,501,2,0);   // Artikelnumer holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edEin.P.Intrastatnr_Mat') AND (Ein.P.Intrastatnr<>'')) then begin
    MSl.Intrastatnr # Ein.P.Intrastatnr;
    RecRead(220,2,0);
    Lib_Guicom2:JumpToWindow('MSL.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Erzeuger_Mat') AND (Ein.P.Erzeuger<>0)) then begin
    RekLink(100,501,11,0);   // Erzeuger holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.TextNr2b') AND (aBuf<>0)) then begin
   todo('Text2')
    //RekLink(100,501,11,0);   // Standardtext holen
    Lib_Guicom2:JumpToWindow('Txt.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Verpacknr') AND (Ein.P.Verpacknr<>0)) then begin
     Adr.V.EinsatzVPG.Nr # Ein.P.Verpacknr;
     RecRead(105,5,0);
    Lib_Guicom2:JumpToWindow('Adr.V.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Verwiegungsart') AND (Ein.P.Verwiegungsart<>0)) then begin
    RekLink(818,501,10,0);   // Verweigungsart holen
    Lib_Guicom2:JumpToWindow('VwA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Etikettentyp') AND (Ein.P.Etikettentyp<>0)) then begin
    RekLink(840,501,9,0);   // Etikettentyp holen
    Lib_Guicom2:JumpToWindow('Eti.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Zwischenlage') AND (Ein.P.Zwischenlage<>'')) then begin
    ULa.Bezeichnung # Ein.P.Zwischenlage;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Unterlage') AND (Ein.P.Unterlage<>'')) then begin
    ULa.Bezeichnung # Ein.P.Unterlage;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Umverpackung') AND (Ein.P.Umverpackung<>'')) then begin
    ULa.Bezeichnung # Ein.P.Umverpackung;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Etikettentyp2') AND (Ein.P.Etikettentyp<>0)) then begin
    RekLink(840,501,9,0);   // Etikettentyp holen
    Lib_Guicom2:JumpToWindow('Eti.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.P.Skizzennummer') AND (Ein.P.Skizzennummer<>0)) then begin
    RekLink(829,501,22,0);   // Skizze holen
    Lib_Guicom2:JumpToWindow('Skz.Verwaltung');
    RETURN;
  end;
  

end;



//========================================================================
//========================================================================
//========================================================================