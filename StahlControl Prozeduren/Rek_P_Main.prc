@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rek_P_Main
//                  OHNE E_R_G
//  Info
//
//
//  03.06.2008  DS  Erstellung der Prozedur
//  17.12.2009  MS  MEH-Unterscheidung bei der Berechnung des Wertes (ob Stk, kg usw.) fuer $lb.Wert_Mat
//  07.01.2010  AI  Reklamationswerte stammen aus Materialdatei
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  11.06.2014  AH  diverse Korrekturen/Umbauten
//  16.06.2014  AH  Erweiterung für Lohn-BA-Fertigung
//  23.06.2014  AH  Erweiterung für Lohn-BA-Einsatz
//  11.07.2014  AH  Neugestaltung
//  01.02.2016  AH  Neu: Protokoll-Kopf
//  15.08.2016  AH  Erlöskorrektur beahten
//  04.02.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//  2023-04-21  AH  Fix für Kd/Lfnr Proj. 2466/17
//
// Todo: Auftragsart prüfen, EK-Rechnung anzeigen
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate( aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; opt aChanged : logic)
//    SUB RecInit(opt aWeiterePos : logic)
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtChanged(aEvt   : event) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusSachbearbeiter()
//    SUB AusAktenuser()
//    SUB AusRekArt()
//    SUB AusStatus()
//    SUB AusStatusPos()
//    SUB AusKunde()
//    SUB AusLieferant()
//    SUB AusAuftrag()
//    SUB AusBest()
//    SUB AusBAG()
//    SUB AusAufAktion()
//    SUB AusWareneingang()
//    SUB AusBAFM()
//    SUb AusBAInput()
//    SUB AusFehlercode()
//    SUB AusVerursachernr()
//    SUB AusRessourceGrp()
//    SUB AusRessource()
//    SUB AusText();
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB TxtRead()
//    SUB TxtSave()
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle      : 'Reklamationspositionen'
  cFile       :  301
  cMenuName   : 'Rek.P.Bearbeiten'
  cPrefix     : 'Rek_P'
  cZList      : $ZL.RekPositionen
  cKey        : 1

  cDialog     : 'Rek.P.Verwaltung'
  cRecht      : Rgt_Rek_Positionen
  cMdiVar     : gMdiQS
end;

declare TxtSave();
declare TxtRead();
declare RefreshMode(opt aNoRefresh : logic);



//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aRekNr  : int;
  opt aRekPos : int;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end;
begin

  if (aRecId=0) and (aRekNr<>0) then begin
    Rek.P.Nummer      # aRekNr;
    Rek.P.Position    # aRekPos;
    Erx # RecRead(301,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(301,_recID);
  end;

  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView);
end;




//========================================================================
//========================================================================
Sub GetReferenzen(
  aAkt    : int;
  aAkt2   : int;
  aMat    : int;
  aArt    : alpha;
  aCharge : alpha;
  ) : logic;
local begin
  Erx : int;
end;
begin


// TODO Artikel
  // ARTIKEL ------------------------------------------------
  if (aMat=0) then begin
    // Auftrag?
    if (Rek.ZuDatei=400) then begin
      RecBufClear(404);
      Auf.A.Nummer    # Rek.Auftragsnr;
      Auf.A.Position  # Rek.Auftragspos;
      Auf.A.Position2 # Rek.P.Aktion;
      Auf.A.Aktion    # Rek.P.Aktion2;
      Erx # RecRead(404,1,0);
      RETURN (Erx<=_rLocked);
    end
    // Wareneingang?
    else if (Rek.ZuDatei=500) then begin
      RecBufClear(506);
      Ein.E.Nummer     # Rek.Einkaufsnr;
      Ein.E.Position   # Rek.Einkaufspos;
      Ein.E.Eingangsnr # Rek.P.Aktion;
      RETURN (RecRead(506,1,0)<=_rMultikey);
    end

    RETURN false;
  end;

  // MATERIAL -----------------------------------------------
  // Auftrag?
  if (Rek.ZuDatei=400) then begin
    RETURN (Mat_Data:Read(aMat)>=200);
  end
  // Wareneingang?
  else if (Rek.ZuDatei=500) then begin
    RecBufClear(506);
    Ein.E.Materialnr # aMat;
    RETURN (RecRead(506,2,0)<=_rMultikey);
  end
  else if (Rek.ZuDatei=701) then begin
    Erx # RekLink(702,300,12,_recFirst);    // BA-Pos holen
    FOR Erx # RecLink(701,702,2,_recFirst); // Input loopen
    LOOP Erx # RecLink(701,702,2,_recNext);
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.Materialnr=aMat) then begin
        Mat_Data:read(aMat);
        RETURN true;
      end;
    END;
    RecbufClear(200);
    RecBufClear(701);
    RETURN false;
  end
  else if (Rek.ZuDatei=707) then begin
    Erx # RekLink(702,300,12,_recFirst);    // BA-Pos holen
    FOR Erx # RecLink(707,702,5,_recFirst); // Fertigmeldungen loopen
    LOOP Erx # RecLink(707,702,5,_recNext);
    WHILE (Erx<=_rLocked) do begin
      if (BAG.FM.Materialnr=aMat) then begin
        Mat_Data:read(aMat);
        RETURN true;
      end;
    END;
    RecbufClear(200);
    RecBufClear(707);
    RETURN false;
  end;

  RETURN false;
end;


//========================================================================
//========================================================================
sub _Berechne(
  aAkt      : int;
  aAkt2     : int;
  aMat      : int;
  aArt      : alpha;
  aCharge   : alpha;
  var aStk  : int;
  var aGew  : float;
  var aM    : float;
  var aWert : float);
local begin
  vM        : float;
end;
begin

  if (GetReferenzen(aAkt, aAkt2, aMat, aArt, aCharge)=false) then RETURN;

  // Auftrag?
  if (Rek.ZuDatei=400) then begin
    // Material?
    if (aMat<>0) then begin
//('Mat Verkaufswert:' + Anum(Mat.VK.Preis,2) );
      aStk  # aStk + Mat.Bestand.Stk;
      aGew  # aGew + Rnd(Mat.Bestand.Gew, Set.Stellen.Gewicht);
      aM    # aM + Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Rek.P.MEH);
      aWert # aWert + Rnd((Mat.VK.Preis + Mat.VK.Korrektur)* Mat.Bestand.Gew / 1000.0,2);
      // Mat.VK.Preis      # Rnd(Mat.VK.Preis / Mat.Bestand.Gew *1000.0,2);
    end
    // Artikel?
    else begin
      aStk  # aStk + "Auf.A.Stückzahl";
      aGew  # aGew + Rnd(Auf.A.Gewicht, Set.Stellen.Gewicht);
      aM    # aM + Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge.Preis, Auf.A.MEH.Preis, Rek.P.MEH);
//      aWert # aWert + Rnd("Auf.A.RechPreisW1" * 1.0 / 1.0,2);
      if (Auf.A.RechPEH<>0) then
        aWert # aWert + Rnd(Auf.P.Grundpreis * "Auf.A.Menge.Preis" / cnvfi(Auf.A.RechPEH),2);
      RETURN;
    end;
  end
  // Bestellung?
  else if (Rek.ZuDatei=500) then begin
    // Material?
    if (aMat<>0) then begin
      aStk  # aStk + "Ein.E.Stückzahl";
      aGew  # aGew + Rnd(Ein.E.Gewicht, Set.Stellen.Gewicht);
      if (Rek.P.MEH=Ein.E.MEH2) then
        aM  # aM + Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge2, Ein.E.MEH2, Rek.P.MEH)
      else
        aM  # aM + Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Rek.P.MEH);
      aWert # Rnd(Mat.EK.Preis * Ein.E.Gewicht / 1000.0,2);
    end
    // Artikel?
    else begin
      aStk  # aStk + "Ein.E.Stückzahl";
      aGew  # aGew + Rnd(Ein.E.Gewicht, Set.Stellen.Gewicht);
      vM    # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Rek.P.MEH);
      aM    # aM + vM;
      aWert # aWert + Rnd(Ein.E.Preis * vM / cnvfi(1),2);
      RETURN;
    end;
  end
  // BA-Einsatz?
  else if (Rek.ZuDatei=701) then begin
    // Material?
    if (aMat<>0) then begin
      aStk  # aStk + BAG.IO.Plan.In.Stk;
      aGew  # aGew + Rnd(BAG.IO.Plan.In.GewN, Set.Stellen.Gewicht);
      aM    # aM + Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.In.Stk, BAG.IO.PLan.In.GewN, BAG.IO.Plan.In.Menge, BAG.IO.MEH.In, Rek.P.MEH);
      aWert # aWert + Rnd(Mat.EK.Effektiv * BAG.IO.PLan.In.GewN / 1000.0,2);
    end
    else begin
      RETURN;
    end;
  end
  else if (Rek.ZuDatei=707) then begin
    // Material?
    if (aMat<>0) then begin
      aStk  # aStk + "BAG.FM.Stück";
      aGew  # aGew + Rnd(BAG.FM.Gewicht.Netto, Set.Stellen.Gewicht);
      aM    # aM + Lib_Einheiten:WandleMEH(707, "BAG.FM.stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, Rek.P.MEH);
      aWert # aWert + Rnd(Mat.EK.Effektiv * BAG.FM.Gewicht.Netto / 1000.0,2);
    end
    else begin
      RETURN;
    end
  end;

  aGew # Rnd(aGew, Set.Stellen.Gewicht);
  aM   # Rnd(aM, Set.Stellen.Menge);

end;


//========================================================================
//  Sumchargen
//
//========================================================================
sub SumChargen(
  var aStk  : int;
  var aGew  : float;
  var aM    : float;
  var aWert : float);
local begin
  Erx   : int;
end;
begin

  aStk  # 0;
  aGew  # 0.0;
  aM    # 0.0;
  aWert # 0.0;
  _Berechne(Rek.P.Aktion, Rek.P.Aktion2, Rek.P.Materialnr, Rek.P.Artikel, Rek.P.Charge, var aStk, var aGew, var aM, var aWert);
  FOR Erx # RecLink(303,301,10,_recFirst);
  LOOP Erx # RecLink(303,301,10,_recNext);
  WHILE (Erx<=_rLocked) do begin
    _Berechne(Rek.P.C.Aktion, Rek.P.C.Aktion2, Rek.P.C.Materialnr, Rek.P.C.Artikelnr, Rek.P.C.Art.C.Intern, var aStk, var aGew, var aM, var aWert);
  END;

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
  gZLList   # cZList;
  gKey      # cKey;

  Lib_Guicom2:Underline($edRek.Art);
  Lib_Guicom2:Underline($edRek.Status);
  Lib_Guicom2:Underline($edRek.Lieferantennr);
  Lib_Guicom2:Underline($edRek.Kommission);
  Lib_Guicom2:Underline($edRek.Sachbearbeiter);
  Lib_Guicom2:Underline($edRek.Aktenuser);
  Lib_Guicom2:Underline($edRek.P.Status);
  Lib_Guicom2:Underline($edRek.P.Materialnr);


  SetStdAusFeld('edRek.Art'               ,'RekArt');
  SetStdAusFeld('edRek.Status'            ,'Status');
  SetStdAusFeld('edRek.Sachbearbeiter'    ,'Sachbearbeiter');
  SetStdAusFeld('edRek.Aktenuser'         ,'Aktenuser');
  SetStdAusFeld('edRek.Kundennr'          ,'Kunde');
  SetStdAusFeld('edRek.Lieferantennr'     ,'Lieferant');
  SetStdAusFeld('edRek.Lieferantennr_700' ,'Lieferant');
  SetStdAusFeld('edRek.Kommission'        ,'Kommission');
  SetStdAusFeld('edRek.Kommission_500'    ,'Kommission');
  SetStdAusFeld('edRek.Kommission_700'    ,'Kommission');
  SetStdAusFeld('edRek.P.Materialnr'      ,'Material');
  SetStdAusFeld('edRek.P.Charge'          ,'Charge');
  SetStdAusFeld('edRek.P.Fehlercode'      ,'Fehlercode');
  SetStdAusFeld('edRek.P.VerursacherGrp'  ,'RessourceGrp');
  SetStdAusFeld('edRek.P.VerursacherRes'  ,'Ressource');
  SetStdAusFeld('edRek.P.Verursachernr'   ,'Verursachernr');
  SetStdAusFeld('edRek.P.Status'          ,'StatusPos');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  EvtMdiActivate
//                  MDI-Fenster erhält Focus
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  App_Main:EvtMdiActivate(aEvt);
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_REK;
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;// Pflichtfelder

  // Pflichtfelder
  if (Rek.ZuDatei=400) then begin
    Lib_GuiCom:Pflichtfeld($edRek.Kommission);
    Lib_GuiCom:Pflichtfeld($edRek.Kundennr);
  end;
  if (Rek.ZuDatei=500) then begin
    Lib_GuiCom:Pflichtfeld($edRek.Kommission_500);
    Lib_GuiCom:Pflichtfeld($edRek.Lieferantennr);
  end;
  if (Rek.ZuDatei=701) or (Rek.ZuDatei=707) then begin
    Lib_GuiCom:Pflichtfeld($edRek.Kommission_700);
    Lib_GuiCom:Pflichtfeld($edRek.Lieferantennr_700);
  end;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx         : int;
  vHdl2       : int;
  vTxtHdl     : int;
  vGrundpreis : float;
  vPEH        : float;
  vWert       : float;
  vKosten     : float;
  vPagename   : alpha;

  vGewicht    : float;
  vStk        : int;
  vMenge      : float;
  vOK         : logic;
  vTmp        : int;
  vHdl        : int;
end;
begin

  if (mode<>c_ModeNew) and (mode<>c_ModeEdit) then begin
    Erx # RekLink(300,301,1,_RecFirst); // Kopf holen
  end;

  if (mode<>c_ModeList) then begin
    $bt.Weitere.Mat->wpcaption # Cnvai(RecLinkInfo(303,301,10,_recCount),_FmtNumnozero)+' '+Translate('weitere');
    $bt.Weitere.Art->wpcaption # Cnvai(RecLinkInfo(303,301,10,_recCount),_FmtNumnozero)+' '+Translate('weitere');
  end;

  if (aName='') or (aName='Pos'); then begin
    if (Rek.P.Nummer<1000000000) then begin
      $lb.RekNummer->wpcaption      # aint(Rek.P.Nummer);
      $lb.RekNummer2->wpcaption     # aint(Rek.P.Nummer);
    end
    else begin
      $lb.RekNummer->wpcaption      # '';
      $lb.RekNummer2->wpcaption     # '';
    end;

    $lb.RekPos->wpcaption         # aint(Rek.P.Position);
    $lb.RekPos2->wpcaption        # aint(Rek.P.Position);
    $lb.Stk_Aner->wpcaption       # cnvai(Rek.P.aner.Stk, _FmtNumNoGroup|_FmtNumNoZero);
    $lb.Gewicht_Aner->wpcaption   # cnvaf(Rek.P.aner.Gew, _FmtNumNoGroup|_FmtNumNoZero, 0, Set.Stellen.Gewicht);
    $lb.Menge_Aner->wpcaption     # cnvaf(Rek.P.aner.Menge,_FmtNumNoGroup|_FmtNumNoZero,0, Set.Stellen.Menge);
    $lb.Wert_Aner->wpcaption      # cnvaf(Rek.P.aner.Wert, _FmtNumNoGroup|_FmtNumNoZero,0, 2);

    vOK # (Rek.P.MEH<>'Stk') and (Rek.P.MEH<>'kg') and (Rek.P.MEH<>'t');
    $lb.Mengetitel->wpvisible # vOK;
    $lb.Menge->wpvisible      # vOK;
    $lb.Menge_Mat->wpvisible  # vOK;
    $edRek.P.Menge->wpvisible # vOK;
    $lb.Menge_Aner->wpvisible # vOK;

    $lb.MEH->wpvisible        # vOK;
    $lb.MEH_Mat->wpvisible    # vOK;
    $lb.Rek.P.MEH->wpvisible  # vOK;
    $lb.MEH_Aner->wpvisible   # vOK;

    $lb.MEH->wpcaption        # Rek.P.MEH;
    $lb.MEH_Mat->wpcaption    # Rek.P.MEH;
    $lb.Rek.P.MEH->wpcaption  # Rek.P.MEH;
    $lb.MEH_Aner->wpcaption   # Rek.P.MEH;
  end;


  if (aName='') or (aName='Adresse') then begin
    if (Rek.ZuDatei = 400) then begin
      Erx # RekLink(100,300,9,0);   // Kunde holen
      if (Adr.Kundennr = 0) then RecBufClear(100);
    end
    else if (Rek.ZuDatei = 500) or (Rek.ZuDatei=701) or (Rek.ZuDatei=707) then begin
      Erx # RekLink(100,300,10,0); // Lieferant holen
      if (Adr.LieferantenNr = 0) then RecBufClear(100);
    end;
    $Lb.Stichwort->wpcaption      # Adr.Stichwort;
    $Lb.Adresse->wpcaption        # Adr.Ort + ', ' + "Adr.Straße";
    $Lb.Stichwort_500->wpcaption  # Adr.Stichwort;
    $Lb.Adresse_500->wpcaption    # Adr.Ort + ', ' + "Adr.Straße";
    $Lb.Stichwort_700->wpcaption  # Adr.Stichwort;
    $Lb.Adresse_700->wpcaption    # Adr.Ort + ', ' + "Adr.Straße";

    $lb.Kunde->wpcaption        # Adr.Stichwort;
    $lb.Kunde2->wpcaption       # Adr.Stichwort;

  end;


  if (Rek.zuDatei=400) and ((aName='') or (aName='Kommission')) then begin
    Rek.Auftragsnr    # 0;
    Rek.Auftragspos   # 0;
    Rek.Einkaufsnr    # 0;
    Rek.Einkaufspos   # 0;
    Rek.BA.Nummer     # 0;
    Rek.BA.Position   # 0;
    if (lib_Strings:Strings_count(Rek.Kommission,'/')=1) then begin
      Rek.Auftragsnr  # cnvia(Str_Token(Rek.Kommission,'/',1));
      Rek.Auftragspos # cnvia(Str_Token(Rek.Kommission,'/',2));
      Erx # Auf_Data:Read(Rek.Auftragsnr, Rek.Auftragspos,y);
    end
    else begin
      RecBufClear(400);
      RecBufClear(401);
      Erx # 1;
    end;
    if (Erx<400) or (Auf.Vorgangstyp<>c_Auf) then begin
      Rek.Auftragsnr  # 0;
      Rek.Auftragspos # 0;
      Rek.Kommission  # '';
      $edRek.Kommission->WinUpdate(_WinUpdFld2Obj);
    end;

    // Auftragskopf refreshen
    $edAuf.Best.Nummer->wpcaption # Auf.Best.Nummer;
    $edAuf.Best.Datum->wpcaptiondate # Auf.Best.Datum;
    $edAuf.Best.Bearbeiter->wpcaption # Auf.Best.Bearbeiter;

//    Erx # RekLink(814,400,8,_recFirst);
//    $Lb.Waehrung->wpcaption # "Wae.Bezeichnung";
    if (Rek.ZuDatei=400) then begin
      Erx # RekLink(815,400,5,_recFirst);
      $Lb.Lieferbed->wpcaption # LiB.Bezeichnung.L1;

      Erx # RekLink(816,400,6,_recFirst);
      $lb.Zahlungsbed->wpcaption # ZaB.Kurzbezeichnung;

      Erx # RekLink(817,400,7,_recFirst);
      $lb.Versandart->wpcaption # VsA.Bezeichnung.L1;
    end;

    $edAuf.Waehrung->Winupdate(_WinUpdFld2Obj);
    $edAuf.Lieferbed->Winupdate(_WinUpdFld2Obj);
    $edAuf.Zahlungsbed->Winupdate(_WinUpdFld2Obj);
    $edAuf.Versandart->Winupdate(_WinUpdFld2Obj);

    // Auftragsposition refreshen
    $lb.AufBest->wpcaption        # Translate('Auftragsposition');
    $lb.AufBest2->wpcaption       # Translate('Auftragsposition');
    $lb.KuLi->wpcaption           # Translate('Kunde');
    $lb.KuLi2->wpcaption          # Translate('Kunde');
//    $lb.Wert->wpcaption           # Translate('VK-Wert');
//    $lbRek.P.Wert->wpcaption      # Translate('VK-Wert');
//    $lbRek.P.Aner.Wert->wpcaption # Translate('VK-Wert');
    $lbRek.P.Materialnr->wpcaption  # Translate('Material');
    $lb.Nummer->wpcaption         # AInt(Auf.P.Nummer);
    $lb.Nummer2->wpcaption        # AInt(Auf.P.Nummer);
    $lb.Position->wpcaption       # AInt(Auf.P.Position);
    $lb.Position2->wpcaption      # AInt(Auf.P.Position);
    $lb.Guete->wpcaption          # "Auf.P.Güte";
    $lb.AusFOben->wpcaption       # Auf.P.AusfOben;
    $lb.AusFUnten->wpcaption      # Auf.P.AusfUnten;
    $lb.Dicke->wpcaption          # cnvAF(Auf.P.Dicke,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Dicke);
    $lb.Breite->wpcaption         # cnvAF(Auf.P.Breite,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Breite);
    $lb.Laenge->wpcaption         # cnvAF("Auf.P.Länge",_FmtNumNoGroup|_FmtNumNoZero,0,"Set.Stellen.Länge");
    $lb.DickenTol->wpcaption      # Auf.P.Dickentol;
    $lb.BreitenTol->wpcaption     # Auf.P.Breitentol;
    $lb.LaengenTol->wpcaption     # "Auf.P.Längentol";
    Erx # RekLink(819,401,1,_recFirst);   // WGr holen
    $lb.Wgr->wpcaption            # aint(Auf.P.Warengruppe);
    $lb.Wgr2->wpcaption           # aint(Auf.P.Warengruppe);
    $lb.WgrText->wpcaption        # Wgr.Bezeichnung.L1;
    $lb.WgrText2->wpcaption       # Wgr.Bezeichnung.L1;
    $lb.Artikel->wpcaption        # Auf.P.Artikelnr;
//    $lb.RID->wpcaption            # cnvAF(Auf.P.RID,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
//    $lb.RIDMax->wpcaption         # cnvAF(Auf.P.RIDMax,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
//    $lb.RAD->wpcaption            # cnvAF(Auf.P.RAD,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
//    $lb.RADMax->wpcaption         # cnvAF(Auf.P.RADMax,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
    $lb.Stk->wpcaption            # cnvAI("Auf.P.Stückzahl",_FmtNumNoGroup|_FmtNumNoZero);
    $lb.Gewicht->wpcaption        # cnvAF(Auf.P.Gewicht,_FmtNumNoGroup|_FmtNumNoZero,0,0);
    $lb.Menge->wpcaption          # anum(Auf.P.Menge, Set.Stellen.Menge);
    $lb.Waehrung3->wpcaption      # "Wae.Kürzel";

    Erx # Mat_Data:Read(Rek.P.Materialnr);
    $lb.Preis->wpcaption # anum(Auf.P.Gesamtpreis,2);
    //cnvAF(Auf.P.Grundpreis,_FmtNumNoZero,0,2);
//                        CnvaF(Mat.VK.Preis,_FmtNumNoZero|_FmtNumNoGroup,0,2);
  end;


  if (Rek.zuDatei=500) and ((aName='') or (aName='Bestellung')) then begin
    Rek.Auftragsnr    # 0;
    Rek.Auftragspos   # 0;
    Rek.Einkaufsnr    # 0;
    Rek.Einkaufspos   # 0;
    Rek.BA.Nummer     # 0;
    Rek.BA.Position   # 0;
    if (lib_Strings:Strings_count(Rek.Kommission,'/')=1) then begin
      Rek.Einkaufsnr  # cnvia(Str_Token(Rek.Kommission,'/',1));
      Rek.Einkaufspos # cnvia(Str_Token(Rek.Kommission,'/',2));
      Erx # Ein_Data:Read(Rek.Einkaufsnr, Rek.Einkaufspos,y);
    end
    else begin
      RecBufClear(500);
      RecBufClear(501);
      Erx # 1;
    end;
    if (Erx<500) then begin
      Rek.Einkaufsnr  # 0;
      Rek.Einkaufspos # 0;
      Rek.Kommission  # '';
      $edRek.Kommission_500->WinUpdate(_WinUpdFld2Obj);
    end;

    // Bestellkopf refreshen
    $edEin.AB.Nummer->wpcaption # Ein.AB.Nummer;
    $edEin.AB.Datum->wpcaptiondate # Ein.AB.Datum;
    $edEin.AB.Bearbeiter->wpcaption # Ein.AB.Bearbeiter;

//    Erx # RekLink(814,500,8,_recFirst);
//    $Lb.Waehrung_500->wpcaption # "Wae.Bezeichnung";

    Erx # RekLink(815,500,5,_recFirst);
    $Lb.Lieferbed_500->wpcaption # LiB.Bezeichnung.L1;

    Erx # RekLink(816,500,6,_recFirst);
    $lb.Zahlungsbed_500->wpcaption # ZaB.Kurzbezeichnung;

    Erx # RekLink(817,500,7,_recFirst);
    $lb.Versandart_500->wpcaption # VsA.Bezeichnung.L1;

    $edAuf.Waehrung->Winupdate(_WinUpdFld2Obj);
    $edAuf.Lieferbed->Winupdate(_WinUpdFld2Obj);
    $edAuf.Zahlungsbed->Winupdate(_WinUpdFld2Obj);
    $edAuf.Versandart->Winupdate(_WinUpdFld2Obj);

    // Bestellposition refreshen
    $lb.AufBest->wpcaption        # Translate('Bestellposition');
    $lb.AufBest2->wpcaption       # Translate('Bestellposition');
    $lb.KuLi->wpcaption           # Translate('Lieferant');
    $lb.KuLi2->wpcaption          # Translate('Lieferant');
//    $lb.Wert->wpcaption           # Translate('EK-Wert');
//    $lbRek.P.Wert->wpcaption      # Translate('EK-Wert');
//    $lbRek.P.Aner.Wert->wpcaption # Translate('EK-Wert');
    $lbRek.P.Materialnr->wpcaption  # Translate('Material');
    $lb.Nummer->wpcaption         # AInt(Ein.P.Nummer);
    $lb.Nummer2->wpcaption        # AInt(Ein.P.Nummer);
    $lb.Position->wpcaption       # AInt(Ein.P.Position);
    $lb.Position2->wpcaption      # AInt(Ein.P.Position);
    $lb.Guete->wpcaption          # "Ein.P.Güte";
    $lb.AusfOben->wpcaption       # Ein.P.AusfOben;
    $lb.AusFUnten->wpcaption      # Ein.P.AusfUnten;
    $lb.Dicke->wpcaption          # cnvAF(Ein.P.Dicke,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Dicke);
    $lb.Breite->wpcaption         # cnvAF(Ein.P.Breite,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Breite);
    $lb.Laenge->wpcaption         # cnvAF("Ein.P.Länge",_FmtNumNoGroup|_FmtNumNoZero,0,"Set.Stellen.Länge");
    $lb.DickenTol->wpcaption      # Ein.P.Dickentol;
    $lb.BreitenTol->wpcaption     # Ein.P.Breitentol;
    $lb.LaengenTol->wpcaption     # "Ein.P.Längentol";
    Erx # RekLink(819,501,1,_recFirst);   // WGr holen
    $lb.Wgr->wpcaption            # aint(Ein.P.Warengruppe);
    $lb.Wgr2->wpcaption           # aint(Ein.P.Warengruppe);
    $lb.WgrText->wpcaption        # Wgr.Bezeichnung.L1;
    $lb.WgrText2->wpcaption       # Wgr.Bezeichnung.L1;
    $lb.Artikel->wpcaption        # Ein.P.Artikelnr;
//    $lb.RID->wpcaption            # cnvAF(Ein.P.RID,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
//    $lb.RIDMax->wpcaption         # cnvAF(Ein.P.RIDMax,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
//    $lb.RAD->wpcaption            # cnvAF(Ein.P.RAD,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
//    $lb.RADMax->wpcaption         # cnvAF(Ein.P.RADMax,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
    $lb.Stk->wpcaption            # cnvAI("Ein.P.Stückzahl",_FmtNumNoGroup|_FmtNumNoZero);
    $lb.Gewicht->wpcaption        # cnvAF(Ein.P.Gewicht,_FmtNumNoGroup|_FmtNumNoZero,0,0);
    $lb.Menge->wpcaption          # anum(Ein.P.Menge, Set.Stellen.Menge);
    $lb.Waehrung3->wpcaption      # "Wae.Kürzel";

    Erx # Mat_Data:Read(Rek.P.Materialnr);
//    $lb.Preis->wpcaption # CnvaF(Mat.EK.effektiv,_FmtNumNoZero|_FmtNumNoGroup,0,2);//cnvAF(Auf.P.Grundpreis,_FmtNumNoZero,0,2);
    $lb.Preis->wpcaption # anum(Ein.P.Gesamtpreis,2);
  end;


  if ((Rek.zuDatei=701) or (Rek.zuDatei=707)) and ((aName='') or (aName='BAG')) then begin
    Rek.Auftragsnr    # 0;
    Rek.Auftragspos   # 0;
    Rek.Einkaufsnr    # 0;
    Rek.Einkaufspos   # 0;
    Rek.BA.Nummer     # 0;
    Rek.BA.Position   # 0;
    if (lib_Strings:Strings_count(Rek.Kommission,'/')=1) then begin
      Rek.BA.Nummer   # cnvia(Str_Token(Rek.Kommission,'/',1));
      Rek.BA.Position # cnvia(Str_Token(Rek.Kommission,'/',2));
      Erx # RekLink(702,300,12,_recFirst);  // BA-Pos holen
      Erx # RekLink(703,702,4,_recFirst);   // 1. BA-Fertigung holen 08.12.2014
    end
    else begin
      Erx # _rnoRec;
      RecBufClear(702);
    end;
    if (Erx>_rLocked) then begin
      Rek.BA.Nummer     # 0;
      Rek.BA.Position   # 0;
      Rek.Kommission    # '';
      $edRek.Kommission_700->WinUpdate(_WinUpdFld2Obj);
    end;

    $lb.BAG->wpcaption # BAG.P.Aktion2;

//    Erx # RekLink(814,702,15,_recFirst);  // Währung holen
//    $Lb.Waehrung_700->wpcaption # "Wae.Bezeichnung";

    $edBAG.P.Referenznr->Winupdate(_WinUpdFld2Obj);
    $edBAG.P.Kosten.Wae->Winupdate(_WinUpdFld2Obj);
    $edBAG.P.Fertig.Dat->Winupdate(_WinUpdFld2Obj);

    $lb.AufBest->wpcaption        # Translate('BA-Position');
    $lb.AufBest2->wpcaption       # Translate('BA-Position');

    $lb.KuLi->wpcaption           # Translate('Lieferant');
    $lb.KuLi2->wpcaption          # Translate('Lieferant');
//    $lb.Wert->wpcaption           # Translate('eff.Wert');
//    $lbRek.P.Wert->wpcaption      # Translate('Wert');
//    $lbRek.P.Aner.Wert->wpcaption # Translate('Wert');
    if (Rek.zuDatei=701) then begin
      $lbRek.P.Materialnr->wpcaption  # Translate('Einsatzmaterial');
      RecbufClear(819);
    end
    else begin
      $lbRek.P.Materialnr->wpcaption  # Translate('Fertigmaterial');
      RecbufClear(819);
    end;

    Erx # RekLink(100,300,10,0); // Lieferant holen

    $lb.Nummer->wpcaption       # AInt(BAG.P.Nummer);
    $lb.Nummer2->wpcaption      # AInt(BAG.P.Nummer);
    $lb.Position->wpcaption     # AInt(BAG.P.Position);
    $lb.Position2->wpcaption    # AInt(BAG.P.Position);
    $lb.Kunde->wpcaption        # Adr.Stichwort;
    $lb.Kunde2->wpcaption       # Adr.Stichwort;
    $lb.Guete->wpcaption        # '';
    $lb.AusFOben->wpcaption     # '';
    $lb.AusFUnten->wpcaption    # '';
    $lb.Dicke->wpcaption        # '';
    $lb.Breite->wpcaption       # '';
    $lb.Laenge->wpcaption       # '';
    $lb.DickenTol->wpcaption    # '';
    $lb.BreitenTol->wpcaption   # '';
    $lb.LaengenTol->wpcaption   # '';
    $lb.Wgr->wpcaption          # cnvai(Wgr.Nummer, _FmtNumNoGroup|_FmtNumNoZero);
    $lb.Wgr2->wpcaption         # cnvai(Wgr.Nummer, _FmtNumNoGroup|_FmtNumNoZero);
    $lb.WgrText->wpcaption      # Wgr.Bezeichnung.L1;
    $lb.WgrText2->wpcaption     # Wgr.Bezeichnung.L1;
    $lb.Artikel->wpcaption      # '';
//    $lb.RID->wpcaption          # '';
//    $lb.RIDMax->wpcaption       # '';
//    $lb.RAD->wpcaption          # '';
//    $lb.RADMax->wpcaption       # '';
    $lb.Stk->wpcaption          # '';
    $lb.Gewicht->wpcaption      # '';
    $lb.Menge->wpcaption        # '';
    $lb.Waehrung3->wpcaption    # "Wae.Kürzel"; //' + BAG.P.Kosten.MEH;

    $lb.Preis->wpcaption # CnvaF(BAG.P.Kosten.Pro,_FmtNumNoZero|_FmtNumNoGroup,0,2);
  end;


  //Umsetzung der Dateinummer in Checkbox-Anzeige
  if (aName='') and (Mode=c_ModeView) then begin
    if (Rek.ZuDatei = 400) then begin
      $cb.400->wpcheckstate # _WinStateChkChecked;
      $cb.500->wpcheckstate # _WinStateChkUnChecked;
      $cb.701->wpcheckstate # _WinStateChkUnChecked;
      $cb.707->wpcheckstate # _WinStateChkUnChecked;
      $NB.400->wpdisabled   # n;
      $nb.500->wpdisabled   # y;
      $nb.700->wpdisabled   # y;
      vHdl2 # gMdi->Winsearch('NB.SubKopf');
      vHdl2->wpcurrent(_WinFlagNoFocusSet) # 'nb.400';
      $Edit->WinFocusSet(false);
      end
    else if (Rek.ZuDatei = 500) then begin
      $cb.500->wpcheckstate # _WinStateChkChecked;
      $cb.400->wpcheckstate # _WinStateChkUnChecked;
      $cb.701->wpcheckstate # _WinStateChkUnChecked;
      $cb.707->wpcheckstate # _WinStateChkUnChecked;
      $nb.500->wpdisabled   # n;
      $nb.400->wpdisabled   # y;
      $nb.700->wpdisabled   # y;
      vHdl2 # gMdi->Winsearch('NB.SubKopf');
      vHdl2->wpcurrent(_WinFlagNoFocusSet) # 'nb.500';
      $Edit->WinFocusSet(false);
    end
    else if (Rek.ZuDatei = 701) then begin
      $cb.701->wpcheckstate # _WinStateChkChecked;
      $cb.400->wpcheckstate # _WinStateChkUnChecked;
      $cb.500->wpcheckstate # _WinStateChkUnChecked;
      $cb.707->wpcheckstate # _WinStateChkUnChecked;
      $nb.700->wpdisabled   # n;
      $nb.400->wpdisabled   # y;
      $nb.500->wpdisabled   # y;
      vHdl2 # gMdi->Winsearch('NB.SubKopf');
      vHdl2->wpcurrent(_WinFlagNoFocusSet) # 'nb.700';
      $Edit->WinFocusSet(false);
    end
    else if (Rek.ZuDatei = 707) then begin
      $cb.707->wpcheckstate # _WinStateChkChecked;
      $cb.400->wpcheckstate # _WinStateChkUnChecked;
      $cb.500->wpcheckstate # _WinStateChkUnChecked;
      $cb.701->wpcheckstate # _WinStateChkUnChecked;
      $nb.700->wpdisabled   # n;
      $nb.400->wpdisabled   # y;
      $nb.500->wpdisabled   # y;
      vHdl2 # gMdi->Winsearch('NB.SubKopf');
      vHdl2->wpcurrent(_WinFlagNoFocusSet) # 'nb.700';
      $Edit->WinFocusSet(false);
    end;
  end;


  // im Edit-Modus Auftrag oder Bestellung nicht mehr änderbar
  if (mode=c_ModeEdit) then begin
    $cb.400->wpdisabled # y;
    $cb.500->wpdisabled # y;
    $cb.701->wpdisabled # y;
    $cb.707->wpdisabled # y;
  end;


  if (aName='') or (aName='edRek.Art') then begin
    Erx # RekLink(849,300,2,0);
    $Lb.RekArt->wpcaption # Rek.Art.Bezeichnung;
  end;


  if ((aName='') or (aName='edRek.Kundennr') or (aName='edRek.Lieferantennr') or (aName='edRek.Lieferantennr_700')) then begin
    RefreshIfm('Adresse');
  end;
  if (Rek.Kommission<>'') and
    (((aName='edRek.Kundennr') and ($edRek.Kundennr->wpchanged)) or
     ((aName='edRek.Lieferantennr') and ($edRek.Lieferantennr->wpchanged)) or
     ((aName='edRek.Lieferantennr_700') and ($edRek.Lieferantennr_700->wpchanged))) then begin
    Rek.Kommission # '';
    $edRek.Kommission->WinUpdate(_WinUpdFld2Obj);
    RefreshIfm('Kommission');
  end;


  if ((aName='') and (Rek.ZuDatei = 400)) or
    (aName='edRek.Kommission') then begin
    if ($edRek.Kommission->wpchanged) or (aChanged) then begin
      RefreshIfm('Kommission');
      Rek.Kundennr  # Auf.Kundennr;
      "Rek.Währung" # "Auf.Währung";
      $edRek.Kundennr->WinUpdate(_WinUpdFld2Obj);
      RefreshIfm('Adresse');
    end;
  end;


  if ((aName='') and (Rek.ZuDatei = 500)) or
    (aName='edRek.Kommission_500') then begin
    if ($edRek.Kommission_500->wpchanged) or (aChanged) then begin
      RefreshIfm('Bestellung');
      Rek.Lieferantennr # Ein.Lieferantennr;
      "Rek.Währung"     # "Ein.Währung";
      $edRek.Lieferantennr->WinUpdate(_WinUpdFld2Obj);
      RefreshIfm('Adresse');
    end;
  end;


  if ((aName='') and ((Rek.ZuDatei = 701) or (Rek.ZuDatei = 707))) or
    (aName='edRek.Kommission_700') then begin
    if ($edRek.Kommission_700->wpchanged) or (aChanged) then begin
      RefreshIfm('BAG');
      Rek.Lieferantennr # BAG.P.ExterneLiefNr;
      "Rek.Währung" # "BAG.P.Kosten.Wae";
      $edRek.Lieferantennr_700->WinUpdate(_WinUpdFld2Obj);
      RefreshIfm('Adresse');
    end;
  end;




  if (aName='') or (aName='edRek.P.Materialnr') or (aName='edRek.P.Charge') then begin
    // Auftragsrekalmation...
    if (Rek.ZuDatei = 400) then begin
      if ($edRek.P.Materialnr->wpcaptionint <> 0) then begin
        Mat_data:Read(Rek.P.Materialnr);
        $lb.Rechnr->wpcaption # cnvAI(Rek.P.Rechnungsnr,_FmtNumNoGroup|_FmtNumNoZero);
        if (Mat.Lagerplatz<>'') then
          $lb.Lagerort->wpcaption # Mat.Lagerstichwort+', '+Mat.Lagerplatz
        else
          $lb.Lagerort->wpcaption # Mat.Lagerstichwort;
        $lb.Guete_Mat->wpcaption # "Mat.Güte";
        $lb.Dicke_Mat->wpcaption # cnvAF(Mat.Dicke,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Dicke);
        $lb.Breite_Mat->wpcaption # cnvAF(Mat.Breite,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Breite);
        $lb.Laenge_Mat->wpcaption # cnvAF("Mat.Länge",_FmtNumNoGroup|_FmtNumNoZero,0,"Set.Stellen.Länge");
        $lb.DickenTol_Mat->wpcaption # Mat.DickenTol;
        $lb.BreitenTol_Mat->wpcaption # Mat.BreitenTol;
        $lb.LaengenTol_Mat->wpcaption # "Mat.LängenTol";

        SumChargen(var vStk, var vGewicht, var vMenge, var vWert);
        $lb.Stk_Mat->wpcaption      # cnvAI(vStk,_FmtNumNoGroup|_FmtNumNoZero);
        $lb.Gewicht_Mat->wpcaption  # cnvAF(vGewicht,_FmtNumNoGroup|_FmtNumNoZero,0,0);
        $lb.Menge_Mat->wpcaption    # anum(vMenge, Set.Stellen.Menge);

//      vGrundpreis # cnvFA($lb.Preis->wpcaption);
//      vWert # Rnd((vGrundpreis / 1000.0) * vGewicht,2);
        $lb.Wert_Mat->wpcaption # cnvAF(vWert,_FmtNumNoGroup|_FmtNumNoZero,0,2);
      end;
//      if (Rek.P.Charge <> '') then begin
        SumChargen(var vStk, var vGewicht, var vMenge, var vWert);
        $lb.Stk_Mat->wpcaption      # cnvAI(vStk,_FmtNumNoGroup|_FmtNumNoZero);
        $lb.Gewicht_Mat->wpcaption  # cnvAF(vGewicht,_FmtNumNoGroup|_FmtNumNoZero,0,0);
        $lb.Menge_Mat->wpcaption    # anum(vMenge, Set.Stellen.Menge);

        $lb.Wert_Mat->wpcaption # cnvAF(vWert,_FmtNumNoGroup|_FmtNumNoZero,0,2);
//      end;
    end
      // Bestellreklamation...
    else if (Rek.ZuDatei = 500) then begin
      if ($edRek.P.Materialnr->wpcaptionint <> 0) then begin
        Mat_data:Read(Rek.P.Materialnr);

        Erx # RekLink(506,301,13,0);  // Wareneingang holen
        $lb.Rechnr->wpcaption # cnvAI(Rek.P.Rechnungsnr,_FmtNumNoGroup|_FmtNumNoZero);
        if (Mat.Lagerplatz<>'') then
          $lb.Lagerort->wpcaption # Mat.Lagerstichwort+', '+Mat.Lagerplatz
        else
          $lb.Lagerort->wpcaption # Mat.Lagerstichwort;
        $lb.Guete_Mat->wpcaption # "Ein.E.Güte";
        $lb.Dicke_Mat->wpcaption # cnvAF(Ein.E.Dicke,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Dicke);
        $lb.Breite_Mat->wpcaption # cnvAF(Ein.E.Breite,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Breite);
        $lb.Laenge_Mat->wpcaption # cnvAF("Ein.E.Länge",_FmtNumNoGroup|_FmtNumNoZero,0,"Set.Stellen.Länge");
        $lb.DickenTol_Mat->wpcaption # Ein.E.DickenTol;
        $lb.BreitenTol_Mat->wpcaption # Ein.E.BreitenTol;
        $lb.LaengenTol_Mat->wpcaption # "Ein.E.LängenTol";
      end;

      SumChargen(var vStk, var vGewicht, var vMenge, var vWert);
      $lb.Stk_Mat->wpcaption # cnvAI(vStk,_FmtNumNoGroup|_FmtNumNoZero);
      $lb.Gewicht_Mat->wpcaption # cnvAF(vGewicht,_FmtNumNoGroup|_FmtNumNoZero,0,0);
      $lb.Menge_Mat->wpcaption    # anum(vMenge, Set.Stellen.Menge);
//      vGrundpreis # cnvFA($lb.Preis->wpcaption);
//      vWert # Rnd((vGrundpreis / 1000.0) * vGewicht,2);
      $lb.Wert_Mat->wpcaption # cnvAF(vWert,_FmtNumNoGroup|_FmtNumNoZero,0,2);
    end
    else if ((Rek.ZuDatei = 701) or (Rek.ZuDatei = 707)) then begin
      // Lohn-BA...
      if ($edRek.P.Materialnr->wpcaptionint <> 0) then begin

        Mat_data:Read(Rek.P.Materialnr);

        $lb.Rechnr->wpcaption # cnvAI(Rek.P.Rechnungsnr,_FmtNumNoGroup|_FmtNumNoZero);
        if (Mat.Lagerplatz<>'') then
          $lb.Lagerort->wpcaption # Mat.Lagerstichwort+', '+Mat.Lagerplatz
        else
          $lb.Lagerort->wpcaption # Mat.Lagerstichwort;
        $lb.Guete_Mat->wpcaption      # "Mat.Güte";
        $lb.Dicke_Mat->wpcaption      # cnvAF(Mat.Dicke,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Dicke);
        $lb.Breite_Mat->wpcaption     # cnvAF(Mat.Breite,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Breite);
        $lb.Laenge_Mat->wpcaption     # cnvAF("Mat.Länge",_FmtNumNoGroup|_FmtNumNoZero,0,"Set.Stellen.Länge");
        $lb.DickenTol_Mat->wpcaption  # Mat.DickenTol;
        $lb.BreitenTol_Mat->wpcaption # Mat.BreitenTol;
        $lb.LaengenTol_Mat->wpcaption # "Mat.LängenTol";
      end;

      SumChargen(var vStk, var vGewicht, var vMenge, var vWert);
      $lb.Stk_Mat->wpcaption      # cnvAI(vStk,_FmtNumNoGroup|_FmtNumNoZero);
      $lb.Gewicht_Mat->wpcaption  # cnvAF(vGewicht,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Gewicht);
      $lb.Menge_Mat->wpcaption    # anum(vMenge, Set.Stellen.Menge);

//      vGrundpreis # cnvFA($lb.Preis->wpcaption);
//      vWert       # Rnd(Mat.EK.Effektiv * vGewicht / 1000.0,2);
      $lb.Wert_Mat->wpcaption # cnvAF(vWert,_FmtNumNoGroup|_FmtNumNoZero,0,2);

      GetReferenzen(Rek.P.Aktion, Rek.P.Aktion2, Rek.P.Materialnr, Rek.P.Artikel, Rek.P.Charge);

/*
      RecbufClear(703)
      if (Rek.ZuDatei = 707) and (Mat.Nummer<>0) then begin
        RecBufClear(707);
        BAG.FM.Materialnr # Mat.Nummer;
        Erx # RecRead(707,3,0);
        WHILE (Erx<_rNoRec) and (BAG.FM.Materialnr=Mat.Nummer) do begin
          if (BAG.FM.Nummer=Rek.BA.Nummer) and (BAG.FM.Position=Rek.BA.Position) then begin
            Erx # RekLink(703,707,3,0);    // Fertigung holen
            BREAK;
          end;
          Erx # RecRead(707,3,_recNext);
        END;
      end
      else
*/
      if (Rek.ZuDatei = 701) then "BAG.F.Güte" # Translate('Einsatzcoil');

      $lb.Guete->wpcaption        # "BAG.F.Güte";
      $lb.AusFOben->wpcaption     # '';
      $lb.AusFUnten->wpcaption    # '';
      $lb.Dicke->wpcaption        # cnvAF(BAG.F.Dicke,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Dicke);
      $lb.Breite->wpcaption       # cnvAF(BAG.F.Breite,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Breite);
      $lb.Laenge->wpcaption       # cnvAF("BAG.F.Länge",_FmtNumNoGroup|_FmtNumNoZero,0,"Set.Stellen.Länge");
      $lb.DickenTol->wpcaption    # BAG.F.Dickentol;
      $lb.BreitenTol->wpcaption   # BAG.F.Breitentol;
      $lb.LaengenTol->wpcaption   # "BAG.F.Längentol";
      $lb.Wgr->wpcaption          # aint(BAG.F.Warengruppe);
      $lb.Wgr2->wpcaption         # aint(BAG.F.Warengruppe);
      Erx # RekLink(819,703,5,_recFirst);   // WGr holen
      $lb.WgrText->wpcaption      # Wgr.Bezeichnung.L1;
      $lb.WgrText2->wpcaption     # Wgr.Bezeichnung.L1;

//      $lb.RID->wpcaption          # cnvAF(BAG.F.RID,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
//      $lb.RIDMax->wpcaption       # cnvAF(BAG.F.RIDmax,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
//      $lb.RAD->wpcaption          # cnvAF(BAG.F.RAD,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
//      $lb.RADMax->wpcaption       # cnvAF(BAG.F.RADmax,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Radien);
      $lb.Stk->wpcaption          # cnvAI("BAG.F.Stückzahl",_FmtNumNoGroup|_FmtNumNoZero);
      $lb.Gewicht->wpcaption      # cnvAF(BAG.F.Gewicht,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Gewicht);
    end
    else begin
      $lb.Rechnr->wpcaption         # '';
      $lb.Lagerort->wpcaption       # '';
      $lb.Guete_Mat->wpcaption      # '';
      $lb.Dicke_Mat->wpcaption      # '';
      $lb.Breite_Mat->wpcaption     # '';
      $lb.Laenge_Mat->wpcaption     # '';
      $lb.DickenTol_Mat->wpcaption  # '';
      $lb.BreitenTol_Mat->wpcaption # '';
      $lb.LaengenTol_Mat->wpcaption # '';
      $lb.Stk_Mat->wpcaption        # '';
      $lb.Gewicht_Mat->wpcaption    # '';
      $lb.Wert_Mat->wpcaption       # '';
    end;

    $lb.Waehrung4->wpcaption # "Wae.Kürzel";
    $lb.Waehrung5->wpcaption # "Wae.Kürzel";
    $lb.Waehrung6->wpcaption # "Wae.Kürzel";
    $lb.Waehrung7->wpcaption # "Wae.Kürzel";

  end;


  if (aName='') or (aName='edRek.Status') then begin
    Erx # RekLink(850,300,3,0);
    $Lb.Status->wpcaption # Stt.Bezeichnung;
  end;


  if (aName='') or (aName='edRek.P.Status') then begin
    Erx # RekLink(850,301,7,0);
    $Lb.StatusPos->wpcaption # Stt.Bezeichnung;
  end;


  if (aName='') or (aName='edRek.P.Fehlercode') then begin
    Erx # RekLink(851,301,8,0);
    $Lb.Fehlercode->wpcaption # FhC.Bezeichnung;
  end;


  if (aName='') or (aName='edRek.P.VerursacherGrp') then begin
    Erx # RekLink(822,301,12,0);
    $lb.RessourceGrp->wpcaption # Rso.Grp.Bezeichnung;
  end;


  if (aName='') or (aName='edRek.P.VerursacherRes') then begin
    Erx # RekLink(160,301,9,0);
    $lb.Ressource->wpcaption # Rso.Stichwort;
    Erx # RekLink(822,301,12,0);
    $lb.RessourceGrp->wpcaption # Rso.Grp.Bezeichnung;
  end;


  if (aName='') or (aName='edRek.P.Verursachernr') then begin
    Erx # RekLink(100,301,11,0);
    $lb.VerursacherNr->wpcaption # Adr.Stichwort;
  end;


  //Umsetzung der internen Nummer in Checkbox-Anzeige
  if (aName='') then begin
    if (Rek.P.Verursacher = 1) then begin
      $cb.VerLieferant->wpcheckstate # _WinStateChkChecked;
      $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
      $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
      $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    end
    else if (Rek.P.Verursacher = 2) then begin
      $cb.VerLieferant->wpcheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpcheckstate # _WinStateChkChecked;
      $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
      $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    end
    else if (Rek.P.Verursacher = 3) then begin
      $cb.VerLieferant->wpcheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
      $cb.Person->wpcheckstate    # _WinStateChkChecked;
      $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    end
    else if (Rek.P.Verursacher = 4) then  begin
      $cb.VerLieferant->wpcheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
      $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
      $cb.Unbekannt->wpcheckstate # _WinStateChkChecked;
    end
  end;

  // Berechnung Gesamtkosten ( nur, wenn Page Position aktiv
  vPageName # $NB.Main->wpcurrent;
  if (StrLen(aName)>3) then
    if (StrCut(aName,1,3)='NB.') then begin
    vPageName # aName;
    aName # '';
  end;


  if (vPageName='NB.Page1') then begin

    vKosten # 0.0;
    FOR Erx # RecLink(302,301,2,_recFirst)
    LOOP Erx # RecLink(302,301,2,_recnext)
    WHILE (Erx<=_rLocked) do begin
      if (Rek.A.AnerkennungYN) then begin           // Anerkannte Werte nicht in Gesamtkosten
        CYCLE;
      end;
      vKosten # vKosten + ((Rek.A.Menge * Rek.A.Kosten) / cnvFI(Rek.A.PEH));
    END;
    $lb.Gesamtkosten->wpcaption # cnvAF(vKosten,_FmtNumNoGroup|_FmtNumNoZero,0,2);
  end;



  if (aName='Pos') or (mode=c_modeview) then begin
//    if (Mode=c_modeview) then begin
      if (Wgr.Dateinummer=250) then
        $NB.MatArt->wpcurrent # 'NB.250'
      else
        $NB.MatArt->wpcurrent # 'NB.200';
//    end;
  end;


  if (aName='') then begin
    vTxtHdl # $Rek.P.Text1->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Rek.P.Text1->wpdbTextBuf # vTxtHdl;
    end;
    TxtRead();
  end;


  // MS 17.12.2009 momentante Loesung
  vGewicht # cnvFA($lb.Gewicht_Mat->wpcaption);
  vWert    # cnvFA($lb.Wert_Mat->wpcaption);
  vStk     # cnvIA($lb.Stk_Mat->wpcaption);
/*
  if (vGewicht <> 0.0) then
    Rek.P.Wert # Rnd(((Rek.P.Gewicht * vWert)/vGewicht),2);
  else
    $edRek.P.Wert->winupdate(_WinUpdFld2Obj);
*/

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit(opt aWeiterePos : logic)
local begin
  Erx   : int;
  vHdl  : int;
  vHdl2 : int;
  vPos  : int;
  vTxt  : int;
  vMEH  : alpha;
end;
begin

  // Felder Disablen durch:
  $edRek.P.Materialnr->wpreadonly # true;
  $edRek.P.Charge->Wpreadonly     # true;

  if (Mode=c_ModeEdit) then begin // Edit?
    Erx # RecLink(300,301,1,_RecFirst | _RecLock);
    if (Erx > _rLocked) then RecBufClear(300)
    else PtD_Main:Memorize(300);

    if (Rek.ZuDatei = 400) then begin
      $cb.500->wpcheckstate # _WinStateChkUnChecked;
      $cb.701->wpcheckstate # _WinStateChkUnChecked;
      $cb.707->wpcheckstate # _WinStateChkUnChecked;
      $NB.500->wpdisabled   # true;
      $NB.700->wpdisabled   # true;
    end
    else if (Rek.ZuDatei = 500) then begin
      $cb.400->wpcheckstate # _WinStateChkUnChecked;
      $cb.701->wpcheckstate # _WinStateChkUnChecked;
      $cb.707->wpcheckstate # _WinStateChkUnChecked;
      $NB.400->wpdisabled   # true;
      $NB.700->wpdisabled   # true;
    end
    else if (Rek.ZuDatei = 701) then begin
      $cb.400->wpcheckstate # _WinStateChkUnChecked;
      $cb.500->wpcheckstate # _WinStateChkUnChecked;
      $cb.707->wpcheckstate # _WinStateChkUnChecked;
      $NB.400->wpdisabled   # true;
      $NB.500->wpdisabled   # true;
    end
    else if (Rek.ZuDatei = 707) then begin
      $cb.400->wpcheckstate # _WinStateChkUnChecked;
      $cb.500->wpcheckstate # _WinStateChkUnChecked;
      $cb.701->wpcheckstate # _WinStateChkUnChecked;
      $NB.400->wpdisabled   # true;
      $NB.500->wpdisabled   # true;
    end;

    $edRek.P.Fehlercode->WinFocusSet(true);
  end;  // Edit

  // neuen Kopf&Pos. anlegen ***********************************************
  if (Mode=c_ModeNew) then begin

    if (w_AppendNr<>0) then begin
      aWeiterePos # y;
      Rek.Nummer # w_AppendNr;
      Erx # RecRead(300,1,0);
      w_AppendNr  # 0;
      Erx # RekLink(301,300,1,_recLast);
      RefreshIfm('');
    end;
    // komplett neuer Kopf + Pos...
    if (aWeiterePos=n) then begin
      $NB.Page2->wpdisabled # y;

      RecBufClear(300);
      RecBufClear(301);
      RecBufClear(400);
      $lb.Waehrung->wpcaption    # '';
      $lb.Lieferbed->wpcaption   # '';
      $lb.Zahlungsbed->wpcaption # '';
      $lb.Versandart->wpcaption  # '';
      RecBufClear(500);
      $lb.Waehrung_500->wpcaption    # '';
      $lb.Lieferbed_500->wpcaption   # '';
      $lb.Zahlungsbed_500->wpcaption # '';
      $lb.Versandart_500->wpcaption  # '';

      vHdl # gMdi->Winsearch('NB.Main');
      vHdl->wpcurrent(_WinFlagNoFocusSet) # 'NB.Kopf';
      Rek.Nummer              # 0;
      $NB.Page1->wpdisabled   # y;
      $cb.400->wpcheckstate # _WinStateChkChecked;
      Rek.ZuDatei             # 400;
      Rek.Sachbearbeiter      # gUsername;
      Rek.Aktenuser           # gUsername;

      $cb.500->wpcheckstate # _WinStateChkUnChecked;
      $cb.701->wpcheckstate # _WinStateChkUnChecked;
      $cb.707->wpcheckstate # _WinStateChkUnChecked;
      $nb.400->wpdisabled   # n;
      $nb.500->wpdisabled   # y;
      $nb.700->wpdisabled   # y;
      vHdl2 # gMdi->Winsearch('NB.SubKopf');
      vHdl2->wpcurrent(_WinFlagNoFocusSet) # 'nb.400';
      Rek.P.Position        # 1;
      Rek.P.Kundennr        # Rek.Kundennr;
      Rek.P.Lieferantennr   # Rek.Lieferantennr;
      Rek.P.Stichwort       # Rek.Stichwort;
      Rek.Datum             # today;
      Rek.P.Datum           # Rek.Datum;
      // Focus setzen auf Feld:
      $edRek.Art->WinFocusSet(false);
    end
    else begin    // nur neue Position...
      vMEH # Rek.P.MEH;
      vPos # Rek.P.Position + 1;
      RecBufClear(301);
      RecBufClear(302);
      Rek.P.Nummer          # Rek.Nummer;
      Rek.P.Position        # vPos;
      Rek.P.Kundennr        # Rek.Kundennr;
      Rek.P.Lieferantennr   # Rek.Lieferantennr;
      Rek.P.Stichwort       # Rek.Stichwort;
      Rek.P.Datum           # Rek.Datum;
      Rek.P.MEH             # vMEH;
      gMDI->WinUpdate(_WinUpdFld2Obj);
      if (Wgr.Dateinummer=250) then begin
        $edRek.P.Charge->Winfocusset(false);
      end
      else begin
        $edRek.P.Materialnr->Winfocusset(false);
      end;

      RefReshIfm();
    end;

    // Vorbelegung bei Neuanlage
    $cb.VerLieferant->wpcheckstate # _WinStateChkChecked;
    $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
    $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
    $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    Lib_GuiCom:Disable($edRek.P.VerursacherGrp);
    Lib_GuiCom:Disable($bt.RessourceGrp);
    Lib_GuiCom:Disable($edRek.P.VerursacherRes);
    Lib_GuiCom:Disable($bt.Ressource);
    Lib_GuiCom:Enable($edRek.P.Verursachernr);
    Lib_GuiCom:Enable($bt.Verursachernr);
  end
    // im Ändern-Modus
  else if (Mode=c_ModeEdit) then begin
    if ($cb.VerLieferant->wpcheckstate = _WinStateChkChecked) then begin
      Lib_GuiCom:Disable($edRek.P.VerursacherGrp);
      Lib_GuiCom:Disable($bt.RessourceGrp);
      Lib_GuiCom:Disable($edRek.P.VerursacherRes);
      Lib_GuiCom:Disable($bt.Ressource);
      Lib_GuiCom:Enable($edRek.P.Verursachernr);
      Lib_GuiCom:Enable($bt.Verursachernr);
    end
    else if ($cb.Ressource->wpcheckstate = _WinStateChkChecked) then begin
      Lib_GuiCom:Enable($edRek.P.VerursacherGrp);
      Lib_GuiCom:Enable($bt.RessourceGrp);
      Lib_GuiCom:Enable($edRek.P.VerursacherRes);
      Lib_GuiCom:Enable($bt.Ressource);
      Lib_GuiCom:Disable($edRek.P.Verursachernr);
      Lib_GuiCom:Disable($bt.Verursachernr);
    end
    else if ($cb.Person->wpcheckstate = _WinStateChkChecked) then begin
      Lib_GuiCom:Disable($edRek.P.VerursacherGrp);
      Lib_GuiCom:Disable($bt.RessourceGrp);
      Lib_GuiCom:Disable($edRek.P.VerursacherRes);
      Lib_GuiCom:Disable($bt.Ressource);
      Lib_GuiCom:Enable($edRek.P.Verursachernr);
      Lib_GuiCom:Disable($bt.Verursachernr);
    end
    else if ($cb.Unbekannt->wpcheckstate = _WinStateChkChecked)then begin
      Lib_GuiCom:Disable($edRek.P.VerursacherGrp);
      Lib_GuiCom:Disable($bt.RessourceGrp);
      Lib_GuiCom:Disable($edRek.P.VerursacherRes);
      Lib_GuiCom:Disable($bt.Ressource);
      Lib_GuiCom:Disable($edRek.P.Verursachernr);
      Lib_GuiCom:Disable($bt.Verursachernr);
    end;
  end;

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
  vHdl    : int;
  vTmp    : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  vTmp # gMdi->Winsearch('NB.Main');

  // logische Prüfung
  if (Rek.zuDatei=400) then begin
    If (Rek.Kundennr=0) then begin
      Lib_Guicom2:InhaltFehlt('Kunde', 'NB.Page1', 'edRek.Kundennr');
      RETURN false;
    end;
    If (Rek.Kommission='') then begin
      Lib_Guicom2:InhaltFehlt('Kommission', 'NB.Page1', 'edRek.Kommission');
      RETURN false;
    end;
  end;

  if (Rek.zuDatei=500) then begin
    If (Rek.Lieferantennr=0) then begin
      Lib_Guicom2:InhaltFehlt('Lieferant', 'NB.Page1', 'edRek.Lieferantennr');
      RETURN false;
    end;
    If (Rek.Kommission='') then begin
      Lib_Guicom2:InhaltFehlt('Bestellung', 'NB.Page1', 'edRek.Kommission_500');
      RETURN false;
    end;
  end;

  if (Rek.zuDatei=701) or (Rek.zuDatei=707) then begin
    If (Rek.Lieferantennr=0) then begin
      Lib_Guicom2:InhaltFehlt('Lieferant', 'NB.Page1', 'edRek.Lieferantennr_700');
      RETURN false;
    end;
    If (Rek.Kommission='') then begin
      Lib_Guicom2:InhaltFehlt('BA-Position', 'NB.Page1', 'edRek.Kommission_700');
      RETURN false;
    end;
  end;


  // Umsetzung der Checkboxes in interne Nummer
  if ($cb.VerLieferant->wpcheckstate   = _WinStateChkChecked) then begin
    Rek.P.Verursacher # 1;
    Rek.P.VerursacherSW # ($lb.VerursacherNr->wpCaption);
  end;
  else if ($cb.Ressource->wpcheckstate = _WinStateChkChecked) then begin
    Rek.P.Verursacher # 2;
    Rek.P.VerursacherSW # ($lb.Ressource->wpcaption);
  end;
  else if ($cb.Person->wpcheckstate    = _WinStateChkChecked) then begin
    Rek.P.Verursacher # 3;
    Rek.P.VerursacherSW # '';
  end;
  else if ($cb.Unbekannt->wpcheckstate = _WinStateChkChecked) then begin
    Rek.P.Verursacher # 4;
    Rek.P.VerursacherSW # '';
  end;

  Wae_Umrechnen(Rek.P.Wert,"Rek.Währung",var Rek.P.Wert.W1,1);

  Rek.Stichwort # ($lb.Stichwort->wpcaption);
  Rek.P.Stichwort # ($lb.Stichwort->wpcaption);

  // Ändern ******************************************
  If (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(300);
    PtD_Main:Compare(301);

    TxtSave();

    Erx # RekReplace(300,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    RETURN true;
  end;  // Ändern


  // Neuanlage ***************************************
  if (Mode=c_ModeNew) then begin

    // neuer Kopf? -> dann Pos. erfassen
    if (Rek.Nummer = 0) then begin
      if (Rek.ZuDatei = 400) then begin
        Auf_Data:Read(Rek.Auftragsnr, Rek.Auftragspos, true);
        Rek.P.MEH # Auf.P.MEH.Preis;
      end
      else if (Rek.ZuDatei = 500) then begin
        Erx # Ein_Data:Read(Rek.Einkaufsnr, Rek.Einkaufspos,y);
        Rek.P.MEH # Ein.P.MEH.Preis;
      end
      else if (Rek.ZuDatei = 701) then begin
        Erx # RekLink(702,300,12,_recFirst);  // BAG-Position holen
        Rek.P.MEH # BAG.P.Kosten.MEH;;
      end
      else if (Rek.ZuDatei = 707) then begin
        Erx # RekLink(702,300,12,_recFirst);  // BAG-Position holen
        Erx # RekLink(703,702,4,_recFirst);   // erste BAG-Fertigung holen
        Rek.P.MEH # BAG.F.MEH;
      end;
      Refreshifm('Pos');

      // 2023-04-21 AH  Proj. 2466/17
      Rek.P.Kundennr # Rek.Kundennr;
      Rek.P.Lieferantennr # Rek.Lieferantennr;
      Rek.P.Stichwort # Rek.Stichwort;
      
      // Kopffelder sperren:
      Lib_GuiCom:Disable($cb.400);
      Lib_GuiCom:Disable($cb.500);
      Lib_GuiCom:Disable($cb.701);
      Lib_GuiCom:Disable($cb.707);
      Lib_GuiCom:Disable($edRek.Kundennr);
      Lib_GuiCom:Disable($edRek.Kommission);
      Lib_GuiCom:Disable($bt.Kunde);
      Lib_GuiCom:Disable($bt.Kommission);
      Lib_GuiCom:Disable($edRek.Lieferantennr);
      Lib_GuiCom:Disable($edRek.Kommission_500);
      Lib_GuiCom:Disable($bt.Lieferant);
      Lib_GuiCom:Disable($bt.Kommission_500);
      Lib_GuiCom:Disable($edRek.Lieferantennr_700);
      Lib_GuiCom:Disable($edRek.Kommission_700);
      Lib_GuiCom:Disable($bt.Lieferant);
      Lib_GuiCom:Disable($bt.Kommission_700);


      Rek.Nummer # myTmpNummer;
      Rek.P.Nummer # Rek.Nummer;
      $NB.Page1->wpdisabled # n;
      $NB.Page2->wpdisabled # n;
      vTmp->wpcurrent # 'NB.Page1';

      if (Wgr.Dateinummer=250) then begin
        $edRek.P.Charge->Winfocusset(true);
      end
      else begin
        $edRek.P.Materialnr->Winfocusset(true);
      end;

      RETURN false;
    end;

    // Kopf und Position sichern

    if (Wgr.Dateinummer=250) then begin
      If (Rek.P.Charge='') then begin
        Lib_Guicom2:InhaltFehlt('Charge', 'NB.Page1', 'edRek.P.Charge');
        RETURN false;
      end;
    end
    else begin
      If (Rek.P.Materialnr=0) then begin
        Lib_Guicom2:InhaltFehlt('Materialnr.', 'NB.Page1', 'edRek.P.Materialnr');
        RETURN false;
      end;
    end;


    // tmp. Nummer? -> dann kompletten Kopf + 1. Pos sichern
    if (Rek.Nummer>1000000000) then begin

      TRANSON;

      //Nummernvergabe
      vNummer # Lib_Nummern:ReadNummer('Reklamation');
      if (vNummer<>0) then Lib_Nummern:SaveNummer()
      else begin
        TRANSBRK;
        RETURN false;
      end;

      // Chargen loopen und übernehmen
      Rek.P.Nummer # Rek.Nummer;
      FOR Erx # RecLink(303,301,10,_recFirst);
      LOOP Erx # RecLink(303,301,10,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        RecRead(303,1,_RecLock);
        Rek.P.C.Nummer # vNummer;
        Erx # RekReplace(303,_recunlock,'MAN');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN False;
        end;
      END;

      Rek.P.Nummer        # vNummer;
      Rek.P.Anlage.Datum  # Today;
      Rek.P.Anlage.Zeit   # Now;
      Rek.P.Anlage.User   # gUserName;
      Erx # RekInsert(gFile,0,'MAN');           // Position sichern
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
      TxtSave();

      Rek.Anlage.Datum # Today;
      Rek.Anlage.Zeit  # now;
      Rek.Anlage.User  # gUsername;
      Rek.Nummer       # vNummer;         // Kopf sichern
      Erx # RekInsert(300,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;

      /* 14.04.2011 MS Auftragsaktion anlegen Prj. 1304/48*/
      if (Rek.Auftragsnr <> 0) then begin
        RecBufClear(404);
        Auf_Data:Read(Rek.Auftragsnr, Rek.Auftragspos, true);
        Auf.A.Nummer        # Rek.Auftragsnr;
        Auf.A.Position      # Rek.Auftragspos;
        Auf.A.Aktionstyp    # c_Akt_Reklamation;
        Auf.A.Bemerkung     # c_AktBem_Reklamation;
        Auf.A.Aktionsnr     # Rek.Nummer;
        Auf.A.Aktionspos    # 0;
        Auf.A.Aktionsdatum  # today;
        if(Auf_A_Data:NeuAnlegen() <>_rOK) then begin
          TRANSBRK;
          Msg(010010, AInt(Rek.Auftragspos)+'|'+AInt(Rek.Auftragsnr)+'/'+AInt(Rek.Auftragspos), _WinIcoError, _WinDialogOK, 0);
          RETURN false;
        end;
      end;
      /****************************************/

      TRANSOFF;
    end
    else begin  // eine weitere Position sichern...
      Rek.P.Anlage.Datum  # Today;
      Rek.P.Anlage.Zeit   # Now;
      Rek.P.Anlage.User   # gUserName;
      Erx # RekInsert(gFile,0,'MAN');           // Position sichern
      if (Erx<>_rOk) then begin
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
      TxtSave();
    end;

    if (gZLList<>0) then
      if (gZLList->wpDbSelection<>0) then
        SelRecInsert(gZLList->wpDbSelection,gfile);

    // Weitere Positionen?
    if (Msg(000005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
      RecInit(y);
      RETURN false;
      end
    else begin
      RETURN true;
    end;

  end;          // Neuanlage

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

  if (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then begin
    Ptd_Main:Forget(300);
  end
  else begin
    TRANSON;

    // alle Chargen löschen
    WHILE (RecLink(303,301,10,_recFirst)<=_rLocked) do begin
      Erx # RekDelete(303,_recunlock,'MAN');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
    END;

    TRANSOFF;
  end;

  $NB.Page1->wpdisabled # n;
  RecRead(300,1,0 | _recUnlock);

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx : int;
end;
begin

  if ("Rek.P.Löschmarker"='') then begin
    // Löschkennzeichen setzen
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      TRANSON;
      RecRead(301,1,_recLock);
      "Rek.P.Löschmarker" # '*';
      "Rek.P.Lösch.Datum" # today;
      "Rek.P.Lösch.Zeit"  # now;
      "Rek.P.Lösch.User"  # gUsername;
      Erx # RekReplace(301,_Recunlock,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,Translate(gTitle),0,0,0);
        RETURN;
      end;
      TRANSOFF;
    end;
  end
  // Löschkennzeichen entfernen
  else begin
    if (Msg(000007,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      TRANSON;
      RecRead(301,1,_recLock);
      "Rek.P.Löschmarker" # '';
      "Rek.P.Lösch.Datum" # 0.0.0;
      "Rek.P.Lösch.Zeit"  # 24:00:00.00;
      "Rek.P.Lösch.User"  # '';
      Erx # RekReplace(301,_Recunlock,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,Translate(gTitle),0,0,0);
        RETURN;
      end;
      TRANSOFF;
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
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

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
  vFocus  : alpha;
  vAufNr  : alpha;
  vAufPos : alpha;
  vKommission : alpha;
  vGewicht    : float;
  vStk        : int;
  vWert       : float;
end;
begin

  vFocus # aEvt:Obj->wpname;

  // Berechnung des Reklamationswertes
  if (vFocus='edRek.P.Gewicht') and ($edRek.P.Gewicht->wpchanged) then begin
    vGewicht # cnvFA($lb.Gewicht_Mat->wpcaption);
    vWert    # cnvFA($lb.Wert_Mat->wpcaption);
    vStk     # cnvIA($lb.Stk_Mat->wpcaption);
    /*
    if (vGewicht <> 0.0) and ($lb.MEH.Preis->wpCaption <> 'Stk') then
      Rek.P.Wert # Rnd(((Rek.P.Gewicht * vWert)/vGewicht),2);
    else if (vStk <> 0) and ($lb.MEH.Preis->wpCaption = 'Stk') then
      Rek.P.Wert # Rnd(((cnvFI("Rek.P.Stückzahl") * vWert) / cnvFI(vStk)),2);
    else
      Rek.P.Wert # 0.0;
    $edRek.P.Wert->winupdate(_WinUpdFld2Obj);
    */

    if(vGewicht <> 0.0) then
      Rek.P.Wert # Rnd(((Rek.P.Gewicht * vWert)/vGewicht),2);
    else
      $edRek.P.Wert->winupdate(_WinUpdFld2Obj);
  end;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);


  RETURN true;
end;


//========================================================================
//  EvtChanged
//              Feldinhalt verändert
//========================================================================
sub EvtChanged (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vHdl2 : int;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (Mode=c_ModeView) then RETURN true;

  // Kopf
  if (aEvt:Obj->wpname='cb.400') and ($cb.400->wpcheckstate = _WinStateChkChecked) then begin
    Rek.ZuDatei # 400;
    $cb.500->wpcheckstate # _WinStateChkUnChecked;
    $cb.701->wpcheckstate # _WinStateChkUnChecked;
    $cb.707->wpcheckstate # _WinStateChkUnChecked;
    Rek.Lieferantennr     # 0;
    Rek.P.Lieferantennr   # 0;
    $edRek.Lieferantennr->wpcaptionint # 0;
    $lb.Stichwort->wpcaption # '';
    $lb.Adresse->wpcaption # '';
    $nb.400->wpdisabled   # n;
    $nb.500->wpdisabled   # y;
    $nb.700->wpdisabled   # y;
    vHdl2 # gMdi->Winsearch('NB.SubKopf');
    vHdl2->wpcurrent # 'nb.400';
    $edRek.Kundennr->Winfocusset(true);
  end
  else if (aEvt:Obj->wpname='cb.400') and ($cb.400->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.400->wpcheckstate # _WinStateChkChecked;
  end
  else if (aEvt:Obj->wpname='cb.500') and ($cb.500->wpcheckstate = _WinStateChkChecked) then begin
    Rek.ZuDatei # 500;
    $cb.400->wpcheckstate # _WinStateChkUnChecked;
    $cb.701->wpcheckstate # _WinStateChkUnChecked;
    $cb.707->wpcheckstate # _WinStateChkUnChecked;
    Rek.Kundennr          # 0;
    Rek.P.Kundennr        # 0;
    $edRek.Kundennr->wpcaptionint # 0;
    $lb.Stichwort->wpcaption # '';
    $lb.Adresse->wpcaption  # '';
    $nb.500->wpdisabled     # n;
    $nb.400->wpdisabled     # y;
    $nb.700->wpdisabled     # y;
    vHdl2 # gMdi->Winsearch('NB.SubKopf');
    vHdl2->wpcurrent # 'nb.500';
    $edRek.Lieferantennr->Winfocusset(true);
  end
  else if (aEvt:Obj->wpname='cb.500') and ($cb.500->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.500->wpcheckstate # _WinStateChkChecked;
  end
  else if (aEvt:Obj->wpname='cb.701') and ($cb.701->wpcheckstate = _WinStateChkChecked) then begin
    Rek.ZuDatei # 701;
    $cb.400->wpcheckstate # _WinStateChkUnChecked;
    $cb.500->wpcheckstate # _WinStateChkUnChecked;
    $cb.707->wpcheckstate # _WinStateChkUnChecked;
    Rek.Kundennr    # 0;
    Rek.P.Kundennr  # 0;
    $edRek.Kundennr->wpcaptionint # 0;
    $lb.Stichwort->wpcaption # '';
    $lb.Adresse->wpcaption # '';
    $nb.700->wpdisabled     # n;
    $nb.400->wpdisabled     # y;
    $nb.500->wpdisabled     # y;
    vHdl2 # gMdi->Winsearch('NB.SubKopf');
    vHdl2->wpcurrent # 'nb.700';
    $edRek.Lieferantennr_700->Winfocusset(true);
    end
  else if (aEvt:Obj->wpname='cb.701') and ($cb.701->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.710->wpcheckstate # _WinStateChkChecked;
  end
  else if (aEvt:Obj->wpname='cb.707') and ($cb.707->wpcheckstate = _WinStateChkChecked) then begin
    Rek.ZuDatei # 707;
    $cb.400->wpcheckstate # _WinStateChkUnChecked;
    $cb.500->wpcheckstate # _WinStateChkUnChecked;
    $cb.701->wpcheckstate # _WinStateChkUnChecked;
    Rek.Kundennr    # 0;
    Rek.P.Kundennr  # 0;
    $edRek.Kundennr->wpcaptionint # 0;
    $lb.Stichwort->wpcaption # '';
    $lb.Adresse->wpcaption # '';
    $nb.700->wpdisabled     # n;
    $nb.400->wpdisabled     # y;
    $nb.500->wpdisabled     # y;
    vHdl2 # gMdi->Winsearch('NB.SubKopf');
    vHdl2->wpcurrent # 'nb.700';
    $edRek.Lieferantennr_700->Winfocusset(true);
    end
  else if (aEvt:Obj->wpname='cb.707') and ($cb.707->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.707->wpcheckstate # _WinStateChkChecked;
  end;



  // Position
  if (aEvt:Obj->wpname='cb.VerLieferant') and ($cb.VerLieferant->wpcheckstate = _WinStateChkChecked) then begin
    $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
    $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
    $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    Lib_GuiCom:Disable($edRek.P.VerursacherGrp);
    Lib_GuiCom:Disable($bt.RessourceGrp);
    Lib_GuiCom:Disable($edRek.P.VerursacherRes);
    Lib_GuiCom:Disable($bt.Ressource);
    Lib_GuiCom:Enable($edRek.P.Verursachernr);
    Lib_GuiCom:Enable($bt.Verursachernr);
    Rek.P.Verursacher     # 1;
    Rek.P.VerursacherGrp  # 0;
    Rek.P.VerursacherRes  # 0;
    RefreshIfm('edRek.P.VerursacherGrp');
    RefreshIfm('edRek.P.VerursacherRes');
  end
  else if (aEvt:Obj->wpname='cb.VerLieferant') and ($cb.VerLieferant->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.VerLieferant->wpcheckstate # _WinStateChkChecked;
  end
  else if (aEvt:Obj->wpname='cb.Ressource') and ($cb.Ressource->wpcheckstate = _WinStateChkChecked) then begin
    $cb.VerLieferant->wpcheckstate # _WinStateChkUnChecked;
    $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
    $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    Lib_GuiCom:Enable($edRek.P.VerursacherGrp);
    Lib_GuiCom:Enable($bt.RessourceGrp);
    Lib_GuiCom:Enable($edRek.P.VerursacherRes);
    Lib_GuiCom:Enable($bt.Ressource);
    Lib_GuiCom:Disable($edRek.P.Verursachernr);
    Lib_GuiCom:Disable($bt.Verursachernr);
    Rek.P.Verursacher     # 2;
    Rek.P.Verursachernr   # 0;
    RefreshIfm('edRek.P.Verursachernr');
  end
  else if (aEvt:Obj->wpname='cb.Ressource') and ($cb.Ressource->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.Ressource->wpcheckstate # _WinStateChkChecked;
  end else if (aEvt:Obj->wpname='cb.Person') and ($cb.Person->wpcheckstate = _WinStateChkChecked) then begin
    $cb.VerLieferant->wpcheckstate # _WinStateChkUnChecked;
    $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
    $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    Lib_GuiCom:Disable($edRek.P.VerursacherGrp);
    Lib_GuiCom:Disable($bt.RessourceGrp);
    Lib_GuiCom:Disable($edRek.P.VerursacherRes);
    Lib_GuiCom:Disable($bt.Ressource);
    Lib_GuiCom:Enable($edRek.P.Verursachernr);
    Lib_GuiCom:Disable($bt.Verursachernr);
    Rek.P.Verursacher     # 3;
    Rek.P.VerursacherGrp  # 0;
    Rek.P.VerursacherRes  # 0;
    RefreshIfm('edRek.P.VerursacherGrp');
    RefreshIfm('edRek.P.VerursacherRes');
    RefreshIfm('edRek.P.Verursachernr');
  end
  else if (aEvt:Obj->wpname='cb.Person') and ($cb.Person->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.Person->wpcheckstate # _WinStateChkChecked;
  end
  else if (aEvt:Obj->wpname='cb.Unbekannt') and ($cb.Unbekannt->wpcheckstate = _WinStateChkChecked) then begin
    $cb.VerLieferant->wpcheckstate # _WinStateChkUnChecked;
    $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
    $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
    Lib_GuiCom:Disable($edRek.P.VerursacherGrp);
    Lib_GuiCom:Disable($bt.RessourceGrp);
    Lib_GuiCom:Disable($edRek.P.VerursacherRes);
    Lib_GuiCom:Disable($bt.Ressource);
    Lib_GuiCom:Disable($edRek.P.Verursachernr);
    Lib_GuiCom:Disable($bt.Verursachernr);
    Rek.P.Verursacher     # 4;
    Rek.P.VerursacherGrp  # 0;
    Rek.P.VerursacherRes  # 0;
    RefreshIfm('edRek.P.VerursacherGrp');
    RefreshIfm('edRek.P.VerursacherRes');
    RefreshIfm('edRek.P.Verursachernr');
  end
  else if (aEvt:Obj->wpname='cb.Unbekannt') and ($cb.Unbekannt->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.Unbekannt->wpcheckstate # _WinStateChkChecked;
  end;

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
  vQ,vQ2  : alpha(4000);
  vHdl    : int;
  vSel    : int;
end;

begin

  case aBereich of
    'Weitere.Mat' : begin
      RecBufClear(303);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rek.P.C.Verwaltung',here+':AusWeitere',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'RekArt' : begin
      RecBufClear(849);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rek.Art.Verwaltung',here+':AusRekArt');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Status' : begin
      RecBufClear(850);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VgSt.Verwaltung',here+':AusStatus');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'StatusPos' : begin
      RecBufClear(850);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VgSt.Verwaltung',here+':AusStatusPos');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Sachbearbeiter' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AusSachbearbeiter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Aktenuser' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AusAktenuser');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kunde' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferant' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kommission' : begin
      if (Rek.ZuDatei = 701) or (Rek.ZuDatei = 707) then begin
          RecBufClear(700);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.P.Verwaltung',here+':AusBAG');
          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
          if (Rek.Lieferantennr!= 0) then begin
            vQ # '';
            Lib_Sel:QInt( var vQ, 'BAG.P.ExterneLiefNr', '=', Rek.Lieferantennr);
          end;
          Lib_Sel:QLogic( var vQ, 'BAG.P.ExternYN', true);
          Lib_Sel:QRecList(0,vQ);

          Lib_GuiCom:RunChildWindow(gMDI);
      end
      else if (Msg(300004, '', 0, _WinDialogYesNo, 2) = _WinIDNo) then begin
        if (Rek.ZuDatei = 400) then begin
          RecBufClear(401);
          RecBufClear(400);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusAuftrag');
          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

          vQ # vQ + 'LinkCount(Kopf) > 0';
          if (Rek.Kundennr != 0) then
            Lib_Sel:QInt( var vQ, 'Auf.P.Kundennr', '=', Rek.Kundennr);
          Lib_Sel:QAlpha(var vQ2, 'Auf.Vorgangstyp', '=', c_AUF);

          vSel # SelCreate( 401, 1 );
          vSel->SelAddLink('', 400, 401, 3, 'Kopf');
          Erx # vSel->SelDefQuery('', vQ );
          if (Erx <> 0) then
            Lib_Sel:QError(vSel);
          Erx # vSel->SelDefQuery('Kopf', vQ2 );
          if (Erx <> 0) then
            Lib_Sel:QError(vSel);
          // speichern, starten und Name merken...
          w_SelName # Lib_Sel:SaveRun(var vSel, 0, n);
          gZLList->wpDbSelection # vSel;
//            Lib_Sel:QRecList(0,vQ);  FRÜHER

          Lib_GuiCom:RunChildWindow(gMDI);
        end
        else begin
          RecBufClear(501);
          RecBufClear(500);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung',here+':AusBest');
          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
          if (Rek.Lieferantennr != 0) then begin
            vQ # '';
            Lib_Sel:QInt( var vQ, 'Ein.P.Lieferantennr', '=', Rek.Lieferantennr);
            Lib_Sel:QRecList(0,vQ);
          end;
          Lib_GuiCom:RunChildWindow(gMDI);
        end;
      end
      else begin
        if (Rek.ZuDatei = 400) then begin
         RecBufClear(411);
          RecBufClear(410);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Ablage',here+':AusAuftragAblage');
          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));


          vQ # vQ + 'LinkCount(Kopf) > 0';
          if (Rek.Kundennr != 0) then
            Lib_Sel:QInt( var vQ, 'Auf~P.Kundennr', '=', Rek.Kundennr);
          Lib_Sel:QAlpha(var vQ2, 'Auf~Vorgangstyp', '=', c_AUF);

          vSel # SelCreate( 411, 1 );
          vSel->SelAddLink('', 410, 411, 3, 'Kopf');
          Erx # vSel->SelDefQuery('', vQ );
          if (Erx <> 0) then
            Lib_Sel:QError(vSel);
          Erx # vSel->SelDefQuery('Kopf', vQ2 );
          if (Erx <> 0) then
            Lib_Sel:QError(vSel);
          // speichern, starten und Name merken...
          w_SelName # Lib_Sel:SaveRun(var vSel, 0, n);
          gZLList->wpDbSelection # vSel;
//          Lib_Sel:QRecList(0,vQ);

          Lib_GuiCom:RunChildWindow(gMDI);
        end
        else begin
          RecBufClear(511);
          RecBufClear(510);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Ablage',here+':AusBestAblage');
          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
          if (Rek.Lieferantennr != 0) then begin
            vQ # '';
            Lib_Sel:QInt( var vQ, 'Ein~P.Lieferantennr', '=', Rek.Lieferantennr);
            Lib_Sel:QRecList(0,vQ);
          end;
          Lib_GuiCom:RunChildWindow(gMDI);
        end;
      end;
    end;


    'Charge', 'Material' : begin
      if (Rek.ZuDatei = 400) then begin         // Aktionen
        RecBufClear(404);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.A.Verwaltung',here+':AusAufAktion');

        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        Lib_Sel:QInt(var vQ, 'Auf.A.Nummer'  , '=', Auf.P.Nummer);
        Lib_Sel:QInt(var vQ, 'Auf.A.Position' , '=', Auf.P.Position);
        Lib_Sel:QRecList(0, vQ);

        Lib_GuiCom:RunChildWindow(gMDI);
      end
      else if (Rek.ZuDatei = 500) then begin    // Wareneingänge
        Erx # Ein_Data:Read(Rek.Einkaufsnr, Rek.Einkaufspos,y);
        RecBufClear(506);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.Mat.Verwaltung',here+':AusWareneingang');
        Lib_GuiCom:RunChildWindow(gMDI);
      end
      else if (Rek.ZuDatei = 701) then begin    // Einsatz
        Erx # RekLink(702,300,12,_recFirst);    // BA-Pos holen
        if (Erx<=_rLocked) then begin
          Erx # RekLink(700,702,1,_recFirst);   // BA-Kopf holen
          RecBufClear(707);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.IO.Input.Lohn.Verwaltung',here+':AusBAInput');

          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

          vHdl # Winsearch(gMDI, 'Lb.IO.Nummer');
          if (vHdl<>0) then vHdl->wpcustom # '';

          gZLList->wpDbFileNo       # 701;
          gZLList->wpDbKeyNo        # 1;
          gKey # 1;
          gZLList->wpDbLinkFileNo   # 0;
          Lib_Sel:QInt(var vQ, 'BAG.IO.Nummer'  , '=', BAG.P.Nummer);
          Lib_Sel:QInt(var vQ, 'BAG.IO.NachPosition'  , '=', BAG.P.Position);
          Lib_Sel:QInt(var vQ, 'BAG.IO.BruderID'  , '=', 0);
          Lib_Sel:QInt(var vQ, 'BAG.IO.Materialnr'  , '>', 0);
          Lib_Sel:QRecList(0, vQ);

          Lib_GuiCom:RunChildWindow(gMDI);
        end;
      end
      else if (Rek.ZuDatei=707) then begin      // Verwiegungen
        Erx # RekLink(702,300,12,_recFirst);    // BA-Pos holen
        if (Erx<=_rLocked) then begin
          BA1_FM_Main:Start(BAG.P.Nummer, BAG.P.Position, 0, 0, here+':AusBAFM', false);
/***
          Erx # RekLink(700,702,1,_recFirst);   // BA-Kopf holen
          RecBufClear(707);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1xx.FM.Verwaltung',here+':AusBAFM');

          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

          $ZL.BA1.FM->wpDbFileNo      # 707;
          $ZL.BA1.FM->wpDbKeyNo       # 1;
          gKey # 1;
          $ZL.BA1.FM->wpDbLinkFileNo  # 0;

          // Selektion aufbauen...
          Lib_Sel:QInt(var vQ, 'BAG.FM.Nummer', '=', BAG.P.Nummer);
          Lib_Sel:QInt(var vQ, 'BAG.FM.Position', '=', BAG.P.Position);
          Lib_Sel:QRecList(0, vQ);

          Lib_GuiCom:RunChildWindow(gMDI);
***/
        end;
      end;

    end;


    'Fehlercode' : begin
      RecBufClear(851);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'FhC.Verwaltung',here+':AusFehlercode');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'RessourceGrp' : begin
      RecBufClear(822);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rso.Grp.Verwaltung',here+':AusRessourceGrp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Ressource' : begin
      RecBufClear(160);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rso.Verwaltung',here+':AusRessource');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Verursachernr' : begin
      // nur wenn Lieferant ausgewählt ist, nicht bei Person
      if ($cb.VerLieferant->wpcheckstate = _WinStateChkChecked) then begin
        RecBufClear(100);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusVerursachernr');
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Aktionen' : begin
      RecBufClear(302);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rek.A.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Text' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusText');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', 'R');
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;
end;


//========================================================================
//  AusWeitere
//
//========================================================================
sub AusWeitere()
begin
  gSelected # 0;
end;


//========================================================================
//  AusSachbearbeiter
//
//========================================================================
sub AusSachbearbeiter()
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    // Feldübernahme
    Rek.Sachbearbeiter # Usr.Username;
    gSelected # 0;
  end;
  Usr_data:RecReadThisUser();
  // Focus auf Editfeld setzen:
  $edRek.Sachbearbeiter->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.Sachbearbeiter',y);
end;


//========================================================================
//  AusAktenuser
//
//========================================================================
sub AusAktenuser()
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    // Feldübernahme
    Rek.Aktenuser # Usr.Username;
    gSelected # 0;
  end;
  Usr_data:RecReadThisUser();
  // Focus auf Editfeld setzen:
  $edRek.Aktenuser->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.Aktenuser',y);
end;


//========================================================================
//  AusRekArt
//
//========================================================================
sub AusRekArt()
begin
  if (gSelected<>0) then begin
    RecRead(849,0,_RecId,gSelected);
    Rek.Art       # Rek.Art.Nummer;
  end;
  $edRek.Art->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.Art',y);
end;


//========================================================================
//  AusStatus
//
//========================================================================
sub AusStatus()
begin
  if (gSelected<>0) then begin
    RecRead(850,0,_RecId,gSelected);
    Rek.Status       # Stt.Nummer;
  end;
  $edRek.Status->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.Status',y);
end;


//========================================================================
//  AusStatusPos
//
//========================================================================
sub AusStatusPos()
begin
  if (gSelected<>0) then begin
    RecRead(850,0,_RecId,gSelected);
    Rek.P.Status       # Stt.Nummer;
    gSelected # 0;
  end;
  $edRek.P.Status->Winfocusset(false);

  RefreshIfm('edRek.P.Status',y);
end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Rek.Kundennr      # Adr.KundenNr;
    Rek.Kommission # '';
//  RefreshIfm('edRek.Kommission',y);
    RefreshIfm('Kommission');

    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edRek.Kundennr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.Kundennr',y);
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Rek.Lieferantennr # Adr.LieferantenNr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  if (Rek.zuDatei=500) then
    $edRek.Lieferantennr->Winfocusset(false)
  else
    $edRek.Lieferantennr_700->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.Lieferantennr',y);
end;


//========================================================================
//  AusAuftrag
//
//========================================================================
sub AusAuftrag()
local begin
  Erx   : int;
  vHdl  : int;
end;
begin
  if (gSelected=0) then RETURN;

  RecRead(401,0,_RecId,gSelected);
  gSelected # 0;
  Erx # RekLink(400,401,3,_recFirst);   // Kopf holen
  if (Auf.Vorgangstyp<>c_Auf) then RETURN;

  // Feldübernahme
  Rek.Kommission    # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position);
  Rek.Auftragsnr    # Auf.P.Nummer;
  Rek.Auftragspos   # Auf.P.Position;
  Rek.Kundennr      # Auf.P.Kundennr;
  "Rek.Währung"     # "Auf.Währung";
  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);

  // Focus auf Editfeld setzen:
  $edRek.Kommission->Winfocusset(false);

  // ggf. Labels refreshen
  RefreshIfm('edRek.Kommission',y);

end;


//========================================================================
//  AusBest
//
//========================================================================
sub AusBest()
local begin
  Erx : int;
end;
begin
  if (gSelected=0) then RETURN;

  RecRead(501,0,_RecId,gSelected);
  Erx # RekLink(500,501,3,_recFirst);   // Kopf holen
  // Feldübernahme
  Rek.Kommission    # AInt(Ein.P.Nummer) + '/' + AInt(Ein.P.Position);
  Rek.Einkaufsnr    # Ein.P.Nummer;
  Rek.Einkaufspos   # Ein.P.Position;
  Rek.Lieferantennr # Ein.P.Lieferantennr;
  "Rek.Währung"     # "Ein.Währung";
  gSelected # 0;

  // Focus auf Editfeld setzen:
  $edRek.Kommission_500->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.Kommission_500',y);
//  RefreshIfm('edRek.Lieferantennr');
end;


//========================================================================
//  AusBAG
//
//========================================================================
sub AusBAG()
begin
  if (gSelected=0) then RETURN;

  RecRead(702,0,_RecId,gSelected);
  // Feldübernahme
  Rek.Kommission    # AInt(BAG.P.Nummer) + '/' + AInt(BAG.P.Position);
  Rek.BA.Nummer     # BAG.P.Nummer;
  Rek.BA.Position   # BAG.P.Position;
  "Rek.Währung"     # BAG.P.Kosten.Wae;
  Rek.Lieferantennr # BAG.P.ExterneLiefNr;
  gSelected # 0;

  // Focus auf Editfeld setzen:
  $edRek.Kommission_700->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.Kommission_700',y);
//  RefreshIfm('edRek.Lieferantennr');
end;


//========================================================================
//  AusAuftragAblage
//
//========================================================================
sub AusAuftragAblage()
local begin
  Erx : int;
end;
begin
  if (gSelected=0) then RETURN;

  RecRead(411,0,_RecId,gSelected);
  gSelected # 0;
  Erx # RekLink(410,411,3,_recFirst);   // Kopf holen
  if ("Auf~Vorgangstyp"<>c_Auf) then RETURN;

  // Feldübernahme
  Rek.Kommission    # AInt("Auf~P.Nummer") + '/' + AInt("Auf~P.Position");
  Rek.Auftragsnr    # "Auf~P.Nummer";
  Rek.Auftragspos   # "Auf~P.Position";
  Rek.Kundennr      # "Auf~P.Kundennr";
  "Rek.Währung"     # "Auf~Währung";

  // Focus auf Editfeld setzen:
  $edRek.Kommission->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.Kommission',y);
//  RefreshIfm('edRek.Kundennr');
end;


//========================================================================
//  AusBestAblage
//
//========================================================================
sub AusBestAblage()
local begin
  Erx : int;
end;
begin
  if (gSelected=0) then RETURN;

  RecRead(511,0,_RecId,gSelected);
  Erx # RekLink(510,511,3,_recFirst);   // Kopf holen
  // Feldübernahme
  Rek.Kommission    # AInt("Ein~P.Nummer") + '/' + AInt("Ein~P.Position");
  Rek.Einkaufsnr    # "Ein~P.Nummer";
  Rek.Einkaufspos   # "Ein~P.Position";
  Rek.Lieferantennr # "Ein~P.Lieferantennr";
  "Rek.Währung"     # "Ein~Währung";
  gSelected # 0;

  // Focus auf Editfeld setzen:
  $edRek.Kommission_500->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.Kommission_500',y);
//  RefreshIfm('edRek.Lieferantennr');
end;


//========================================================================
//  AusAufAktion
//
//========================================================================
sub AusAufAktion()
local begin
  Erx       : int;
  vItem     : int;
  vAnz      : int;
end;
begin

  if (gSelected=0) then RETURN;

  vAnz # Lib_Mark:Count(404);

  Erx # RecRead(404,0,_RecId,gSelected);
  gSelected # 0;
  if (Erx<=_rLocked) then begin
    // Feldübernahme
    Rek.P.Materialnr  # Auf.A.Materialnr;
    Rek.P.Artikel     # Auf.A.Artikelnr;
    Rek.P.Charge      # Auf.A.Charge;
    Rek.P.Aktion      # Auf.A.Position2;
    Rek.P.Aktion2     # Auf.A.Aktion;
    Rek.P.Rechnungsnr # Auf.A.Rechnungsnr;
    if (Auf.A.AktionsTyp=c_Akt_LFS) then begin
      Rek.P.Lfsnr     # Auf.A.Aktionsnr;
      Rek.P.LfsPos    # Auf.A.Aktionspos;
    end;
  end;

  // Focus auf Editfeld setzen:
  if (Wgr.Dateinummer=250) then begin
    $edRek.P.Charge->Winfocusset(false);
    RefreshIfm('edRek.P.Charge',y);
  end
  else begin
    $edRek.P.Materialnr->Winfocusset(false);
    RefreshIfm('edRek.P.Materialnr',y);
  end;

  if (vAnz>0) then begin
    if (Msg(99,'Die anderen Einträge als weitere Chargen übernehmen?',_WinIcoQuestion,_WinDialogYesNo,1)=_winidyes) then begin
      Recbufclear(303);
      Rek.P.C.Nummer    # Rek.Nummer;
      Rek.P.C.Position  # Rek.P.Position;

      vItem # 0;
      WHILE (Lib_Mark:Iterate(404, var vItem)<>0) do begin

        if (Rek.P.Aktion=Auf.A.Position2) and (Rek.P.Aktion2=Auf.A.Aktion) then CYCLE;

        Rek.P.C.Aktion        # Auf.A.Position2;
        Rek.P.C.Aktion2       # Auf.A.Aktion;
        Rek.P.C.Materialnr    # Auf.A.Materialnr;
        Rek.P.C.ArtikelNr     # Auf.A.Artikelnr;
        Rek.P.C.Art.C.Intern  # Auf.A.Charge;
        REPEAT
          Rek.P.C.lfdnr # Rek.P.C.lfdnr + 1;
          Erx # RekInsert(303,_Recunlock,'MAN');
        UNTIl (Erx=_rOK);
      END;
      Lib_Mark:Reset(404,y);
    end;
  end;

end;


//========================================================================
//  AusWareneingang
//
//========================================================================
sub AusWareneingang()
local begin
  Erx       : int;
  vItem     : int;
  vAnz      : int;
end;
begin

  if (gSelected=0) then RETURN;

  vAnz # Lib_Mark:Count(506);

  Erx # RecRead(506,0,_RecId,gSelected);
  if (Erx<=_rLocked) then begin
    // Feldübernahme
    Rek.P.Materialnr  # Ein.E.Materialnr;
    Rek.P.Artikel     # Ein.E.Artikelnr;
    Rek.P.Charge      # Ein.E.Charge;
    Rek.P.Aktion      # Ein.E.Eingangsnr;
    Rek.P.Aktion2     # 0;
    if (EKK_Data:BereitsVerbuchtYN(506) = true) then
      Rek.P.Rechnungsnr # EKK.EingangsreNr;
  end;
  gSelected # 0;

  // Focus auf Editfeld setzen:
  $edRek.P.Charge->Winfocusset(false);
  RefreshIfm('edRek.P.Charge',y);


  if (vAnz>0) then begin
    if (Msg(99,'Die anderen Einträge als weitere Chargen übernehmen?',_WinIcoQuestion,_WinDialogYesNo,1)=_winidyes) then begin
      Recbufclear(303);
      Rek.P.C.Nummer    # Rek.Nummer;
      Rek.P.C.Position  # Rek.P.Position;
      Rek.P.C.Aktion2   # 0;

      vItem # 0;
      WHILE (Lib_Mark:Iterate(506, var vItem)<>0) do begin

        if (Rek.P.Aktion=Ein.E.Eingangsnr) then CYCLE;

        Rek.P.C.Aktion        # Ein.E.Eingangsnr;
        Rek.P.C.Materialnr    # Ein.E.Materialnr;
        Rek.P.C.ArtikelNr     # Ein.E.Artikelnr;
        Rek.P.C.Art.C.Intern  # Ein.E.Charge;
        REPEAT
          Rek.P.C.lfdnr # Rek.P.C.lfdnr + 1;
          Erx # RekInsert(303,_Recunlock,'MAN');
        UNTIl (Erx=_rOK);
      END;
      Lib_Mark:Reset(506,y);
    end;
  end;

end;


//========================================================================
//  AusBAFM
//
//========================================================================
sub AusBAFM()
local begin
  Erx       : int;
  vItem     : int;
  vAnz      : int;
end;
begin

  if (gSelected=0) then RETURN;

  vAnz # Lib_Mark:Count(707);

  Erx # RecRead(707,0,_RecId,gSelected);
  If (Erx<_rLocked) then begin
    // Feldübernahme
    Rek.P.Materialnr  # BAG.FM.Materialnr;
// TODO    Rek.P.Artikel     # BAG.FM.Artikelnr;
//    Rek.P.Charge      # BAG.FM.Charge;
    Rek.P.Aktion      # BAG.FM.Fertigung;
    Rek.P.Aktion2     # BAG.FM.Fertigmeldung;
  end;
  gSelected # 0;

  // Focus auf Editfeld setzen:
  $edRek.P.Materialnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.P.Materialnr',y);


  if (vAnz>0) then begin
    if (Msg(99,'Die anderen Einträge als weitere Chargen übernehmen?',_WinIcoQuestion,_WinDialogYesNo,1)=_winidyes) then begin
      Recbufclear(303);
      Rek.P.C.Nummer    # Rek.Nummer;
      Rek.P.C.Position  # Rek.P.Position;

      WHILE (Lib_Mark:Iterate(707, var vItem)<>0) do begin

        if (Rek.P.Aktion=BAG.FM.Fertigung) and (Rek.P.Aktion2=BAG.FM.Fertigmeldung) then CYCLE;

        Rek.P.C.Aktion      # BAG.FM.Fertigung;
        Rek.P.C.Aktion2     # BAG.FM.Fertigmeldung;
        Rek.P.C.Materialnr  # BAG.FM.Materialnr;
        REPEAT
          Rek.P.C.lfdnr # Rek.P.C.lfdnr + 1;
          Erx # RekInsert(303,_Recunlock,'MAN');
        UNTIl (Erx=_rOK);
      END;

      Lib_Mark:Reset(707,y);
    end;
  end;

end;


//========================================================================
//  AusBAInput
//
//========================================================================
sub AusBAInput()
local begin
  Erx       : int;
  vItem     : int;
  vAnz      : int;
end;
begin

  if (gSelected=0) then RETURN;

  vAnz # Lib_Mark:Count(701);

  Erx # RecRead(701,0,_RecId,gSelected);
  If (Erx<_rLocked) then begin
    // Feldübernahme
    Rek.P.Materialnr  # BAG.IO.Materialnr;
    Rek.P.Artikel     # BAG.IO.Artikelnr;
    Rek.P.Charge      # BAG.IO.Charge;
    Rek.P.Aktion      # BAG.IO.ID;
    Rek.P.Aktion2     # 0;
  end;
  gSelected # 0;

  // Focus auf Editfeld setzen:
  $edRek.P.Materialnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edRek.P.Materialnr',y);

  if (vAnz>0) then begin
    if (Msg(99,'Die anderen Einträge als weitere Chargen übernehmen?',_WinIcoQuestion,_WinDialogYesNo,1)=_winidyes) then begin
      Recbufclear(303);
      Rek.P.C.Nummer    # Rek.Nummer;
      Rek.P.C.Position  # Rek.P.Position;

      WHILE (Lib_Mark:Iterate(701, var vItem)<>0) do begin

        if (Rek.P.Aktion=BAG.IO.ID) then CYCLE;

        Rek.P.C.Aktion        # BAG.IO.ID;
        Rek.P.C.Materialnr    # BAG.IO.Materialnr;
        Rek.P.C.ArtikelNr     # BAG.IO.Artikelnr;
        Rek.P.C.Art.C.Intern  # BAG.IO.Charge;
        REPEAT
          Rek.P.C.lfdnr # Rek.P.C.lfdnr + 1;
          Erx # RekInsert(303,_Recunlock,'MAN');
        UNTIl (Erx=_rOK);
      END;
      Lib_Mark:Reset(701,y);
    end;
  end;

end;


//========================================================================
//  AusFehlercode
//
//========================================================================
sub AusFehlercode()
begin
  if (gSelected<>0) then begin
    RecRead(851,0,_RecId,gSelected);
    Rek.P.Fehlercode       # FhC.Nummer;
  end;
  $edRek.P.Fehlercode->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.P.Fehlercode',y);
end;


//========================================================================
//  AusVerursachernr
//
//========================================================================
sub AusVerursachernr()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    Rek.P.Verursachernr  # Adr.Nummer;
  end;
  $edRek.P.Verursachernr->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.P.Verursachernr',y);
end;


//========================================================================
//  AusRessourceGrp
//
//========================================================================
sub AusRessourceGrp()
begin
  if (gSelected<>0) then begin
    RecRead(822,0,_RecId,gSelected);
    Rek.P.VerursacherGrp  # Rso.Grp.Nummer;
  end;
  $edRek.P.VerursacherGrp->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.P.VerursacherGrp',y);
end;


//========================================================================
//  AusRessource
//
//========================================================================
sub AusRessource()
begin
  if (gSelected<>0) then begin
    RecRead(160,0,_RecId,gSelected);
    Rek.P.VerursacherGrp  # Rso.Gruppe;
    Rek.P.VerursacherRes  # Rso.Nummer;
  end;
  $edRek.P.VerursacherRes->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.P.VerursacherGrp',y);
  RefreshIfm('edRek.P.VerursacherRes',y);
end;


//========================================================================
//  AusText
//
//========================================================================
sub AusText();
local begin
  vTxtHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl # $Rek.P.Text1->wpdbTextBuf;
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, '');
    $Rek.P.Text1->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $Rek.P.Text1->Winfocusset(false);
  // ggf. Labels refreshen
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
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek_P_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.EinBest');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rek.ZuDatei<>400);

  vHdl # gMenu->WinSearch('Mnu.Druck.Best');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rek.ZuDatei<>400);

  vHdl # gMenu->WinSearch('Mnu.Druck.Abl');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rek.ZuDatei<>400);
/*
  vHdl # gMenu->WinSearch('Mnu.Druck.Bericht');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rek.ZuDatei<>400);
*/

  vHdl # gMenu->WinSearch('Mnu.Druck.EinBestLf');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rek.ZuDatei<>500);
/*
  vHdl # gMenu->WinSearch('Mnu.Druck.BerichtLf');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rek.ZuDatei<>500);
*/
  vHdl # gMenu->WinSearch('Mnu.Ins.AllMat');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Rek_P_Anlegen]=n) or (Rek.ZuDatei<>400) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeNew));

  vHdl # gMenu->WinSearch('Mnu.Append');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Rek_P_Anlegen]=n) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList));

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then begin
    RefreshIfm();
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
  vQ      : alpha(4000);
  vTmp    : int;
  vLFS    : int;
  vNr     : int;
  vBuf404 : int;
  vWert   : float;
  vRef    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.Filter.Geloescht' : begin
      Filter_REK # !(Filter_REK);
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_REK;

      if (gZLList->wpdbselection<>0) then begin
        vHdl # gZLList->wpdbselection;
        if (SelInfo(vHdl, _SelCount) > 0) then
          vRef # _WinLstRecFromRecId
        else
          vRef # _WinLstFromFirst;
        gZLList->wpDbSelection # 0;
        SelClose(vHdl);
        SelDelete(gFile,w_selName);
        w_SelName # '';
        gZLList->WinUpdate(_WinUpdOn, vRef | _WinLstRecDoSelect);
        App_Main:Refreshmode();
        RETURN true;
      end;
      vQ # '';
      Lib_Sel:QAlpha( var vQ, '"Rek.P.Löschmarker"', '=', '');
      Lib_Sel:QRecList(0,vQ);

      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      App_Main:Refreshmode();
      RETURN true;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(301,Rek.P.Anlage.Datum, Rek.P.Anlage.Zeit, Rek.P.Anlage.User);
    end;


    'Mnu.Protokoll.Kopf' : begin
      Erx # RekLink(300,301,1,_RecFirst); // Kopf holen
      PtD_Main:View(300,Rek.Anlage.Datum, Rek.Anlage.Zeit, Rek.Anlage.User);
    end;


    'Mnu.Ins.AllMat' : begin

      // Auftrag holen
      Auf_Data:read(Rek.Auftragsnr, Rek.Auftragspos,y);

      vBuf404 # RecBufCreate(404);
      FOR Erx # RecLink(vBuf404,401,12,_RecFirst);    // Aktionen loopen
      LOOP Erx # RecLink(vBuf404,401,12,_RecNext);
      WHILE (Erx<=_rLocked) do begin
        if (vBuf404->Auf.A.Aktionstyp<>c_akt_LFS) or (vBuf404->Auf.A.Materialnr=0) then begin
          CYCLE;
        end;
        if (vLFS=0) then vLFS # vBuf404->Auf.A.Aktionsnr;
        if (vLFS<>vBuf404->Auf.A.Aktionsnr) then vLFS # -1;
      END;
      RecBufDestroy(vBuf404);

      if (vLFS=0) then begin
        Msg(300005,'',0,0,0);
        RETURN false;
      end;
      if (vLFS<0) then
        if (Dlg_Standard:Anzahl(Translate('Lieferschein'),var vLFS)=false) then RETURN false;

      TRANSON;

      vBuf404 # RecBufCreate(404);

      FOR Erx # RecLink(vBuf404,401,12,_RecFirst);    // Aktionen loopen
      LOOP Erx # RecLink(vBuf404,401,12,_RecNext);
      WHILE (Erx<=_rLocked) do begin

        if (vBuf404->Auf.A.Aktionstyp<>c_akt_LFS) or (vBuf404->Auf.A.Aktionsnr<>vLFS) or (vBuf404->Auf.A.Materialnr=0) then begin
          CYCLE;
        end;

        Rek.P.Materialnr  # vBuf404->Auf.A.Materialnr;
        Rek.P.Aktion      # vBuf404->Auf.A.Position2;
        Rek.P.Aktion2     # vBuf404->Auf.A.Aktion;
        Rek.P.Rechnungsnr # vBuf404->Auf.A.Rechnungsnr;
        Rek.P.Lfsnr       # vBuf404->Auf.A.Aktionsnr;
        Rek.P.LfsPos      # vBuf404->Auf.A.Aktionspos;
        "Rek.P.Stückzahl" # vBuf404->"Auf.A.Stückzahl";
        Rek.P.Gewicht     # vBuf404->"Auf.A.Gewicht";

        // Material holen
        Mat_Data:Read(Rek.P.Materialnr);

        vWert # Rnd((Mat.EK.Preis / 1000.0) * Mat.Bestand.Gew,2);
//        Rek.P.Wert # Rnd(((Rek.P.Gewicht * vWert)/ Rek.P.Gewicht),2);
//        Wae_Umrechnen(Rek.P.Wert,"Rek.Währung",var Rek.P.Wert.W1,1);


        // tmp. Nummer? -> dann kompletten Kopf + 1. Pos sichern
        if (Rek.Nummer>1000000000) then begin
          //Nummernvergabe
          vNr # Lib_Nummern:ReadNummer('Reklamation');
          if (vNr<>0) then Lib_Nummern:SaveNummer()
          else begin
            TRANSBRK;
            RecBufDestroy(vBuf404);
            RETURN false;
          end;

          Rek.P.Nummer        # vNr;
          Rek.P.Anlage.Datum  # Today;
          Rek.P.Anlage.Zeit   # Now;
          Rek.P.Anlage.User   # gUserName;
          Erx # RekInsert(gFile,0,'MAN');           // Position sichern
          if (Erx<>_rOk) then begin
            TRANSBRK;
            RecBufDestroy(vBuf404);
            Msg(001000+Erx,gTitle,0,0,0);
            RETURN False;
          end;
          TxtSave();

          Rek.Anlage.Datum # Today;
          Rek.Anlage.Zeit  # now;
          Rek.Anlage.User  # gUsername;
          Rek.Nummer       # vNr;         // Kopf sichern
          Erx # RekInsert(300,0,'MAN');
          if (Erx<>_rOk) then begin
            TRANSBRK;
            RecBufDestroy(vBuf404);
            Msg(001000+Erx,gTitle,0,0,0);
            RETURN False;
          end;

          /* 14.04.2011 MS Auftragsaktion anlegen Prj. 1304/48*/
          if (Rek.Auftragsnr <> 0) then begin
            RecBufClear(404);
            Auf_Data:Read(Rek.Auftragsnr, Rek.Auftragspos, true);
            Auf.A.Nummer        # Rek.Auftragsnr;
            Auf.A.Position      # Rek.Auftragspos;
            Auf.A.Aktionstyp    # c_Akt_Reklamation;
            Auf.A.Bemerkung     # c_AktBem_Reklamation;
            Auf.A.Aktionsnr     # Rek.Nummer;
            Auf.A.Aktionspos    # 0;
            Auf.A.Aktionsdatum  # today;
            if(Auf_A_Data:NeuAnlegen() <>_rOK) then begin
              TRANSBRK;
              RecBufDestroy(vBuf404);
              Msg(010010, AInt(Rek.Auftragspos)+'|'+AInt(Rek.Auftragsnr)+'/'+AInt(Rek.Auftragspos), _WinIcoError, _WinDialogOK, 0);
              RETURN false;
            end;
          end;
          /****************************************/
          end
        else begin  // eine weitere Position sichern...
          Rek.P.Anlage.Datum  # Today;
          Rek.P.Anlage.Zeit   # Now;
          Rek.P.Anlage.User   # gUserName;
          REPEAT
            Erx # RekInsert(gFile,0,'MAN');           // Position sichern
            if (erx<>_ROK) then inc(Rek.P.Position);
          UNTIL (Erx=_rOK);
          if (Erx<>_rOk) then begin
            TRANSBRK;
            RecBufDestroy(vBuf404);
            Msg(001000+Erx,gTitle,0,0,0);
            RETURN False;
          end;
          TxtSave();
        end;

        if (gZLList<>0) then
          if (gZLList->wpDbSelection<>0) then
            SelRecInsert(gZLList->wpDbSelection,gfile);

      END;
      RecBufDestroy(vBuf404);

      TRANSOFF;

      Mode # c_ModeList;
      Lib_GuiCom:SetMaskState(false);
      vHdl # gMdi->winsearch('NB.List');
      if (vHdl<>0) then vHdl->wpdisabled # false;
      vHdl # gMdi->winsearch('NB.Main');
      if (vHdl<>0) then vHdl->wpCurrent # 'NB.List';
      App_Main:RefreshMode(); // Buttons & Menues anpassen
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

      Msg(999998,'',0,0,0);

    end;


    'Mnu.Append' : begin
      if (Rek.P.Nummer<>0) then begin
        w_AppendNr # Rek.P.Nummer;
        App_Main:Action(c_ModeNew);
      end;
    end;


    'Mnu.Aktionen' : begin
      Auswahl('Aktionen');
    end;


    'Mnu.Druck.EinBest' : begin
      Lib_Dokumente:Printform(300,'EinBest',false);
    end;


    'Mnu.Druck.Best' : begin
      Lib_Dokumente:Printform(300,'Bestätigung',false);
    end;


    'Mnu.Druck.Abl' : begin
      Lib_Dokumente:Printform(300,'Ablehnung',false);
    end;


    'Mnu.Druck.Bericht' : begin
      if (Rek.ZuDatei=400) then
        Lib_Dokumente:Printform(300,'Bericht',false);
      if (Rek.ZuDatei=500) then
        Lib_Dokumente:Printform(300,'BerichtLief',false);
      if (Rek.ZuDatei=701) or (Rek.ZuDatei=707) then
        Lib_Dokumente:Printform(300,'BerichtBA',false);
    end;


    'Mnu.Druck.EinBestLf' : begin
      Lib_Dokumente:Printform(300,'EinBestLief',false);
    end;


//    'Mnu.Druck.BerichtLf' : begin
//      Lib_Dokumente:Printform(300,'BerichtLief',false);
//    end;


    'Mnu.Mark.Sel' : begin
      // Serienmarkierung; Selektionsdialog [27.01.2010/PW]
      GV.Ints.01  #  0;    // Status von
      GV.Ints.02  # 99;    // Status bis
      GV.Ints.03  #  0;    // Fehlercode von
      GV.Ints.04  # 99;    // Fehlercode bis
      GV.Logic.01 # false; // nur Verursacher: Lieferant
      GV.Logic.02 # false; // nur Verursacher: Ressource
      GV.Logic.03 # false; // nur Verursacher: Person
      GV.Logic.04 # false; // nur Verursacher: Unbekannt

      gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.Mark.RekP', here + ':AusSerienMark' );
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

  case (aEvt:Obj->wpName) of
    'bt.Weitere.Mat'    :   Auswahl('Weitere.Mat');
    'bt.Weitere.Art'    :   Auswahl('Weitere.Mat');
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.RekArt'         :   Auswahl('RekArt');
    'bt.Status'         :   Auswahl('Status');
    'bt.Sachbearbeiter' :   Auswahl('Sachbearbeiter');
    'bt.Aktenuser'      :   Auswahl('Aktenuser');
    'bt.Kunde'          :   Auswahl('Kunde');
    'bt.Lieferant'      :   Auswahl('Lieferant');
    'bt.Lieferant_700'  :   Auswahl('Lieferant');
    'bt.Kommission'     :   Auswahl('Kommission');
    'bt.Kommission_500' :   Auswahl('Kommission');
    'bt.Kommission_700' :   Auswahl('Kommission');
    'bt.Materialnr'     :   Auswahl('Material');
    'bt.Charge'         :   Auswahl('Charge');
    'bt.Fehlercode'     :   Auswahl('Fehlercode');
    'bt.RessourceGrp'   :   Auswahl('RessourceGrp');
    'bt.Ressource'      :   Auswahl('Ressource');
    'bt.VerursacherNr'  :   Auswahl('Verursachernr');
    'bt.StatusPos'      :   Auswahl('StatusPos');
    'bt.Text'           :   Auswahl('Text');
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

  if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then begin
    aEvt:Obj->wpCurrent  # aPage->wpname;
    if (aPage->wpName='NB.Kopf') then
      $edRek.Datum->winfocusset(true);
  end;

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
local begin
  Erx : int;
end;
begin
//  if (Mode<>c_ModeList) then RETURN;
//          Lib_Sound:Play( 'notice.wav' );

  Erx # RekLink(300,301,1,_RecFirst); // Kopf holen
  Erx # RekLink(849,300,2,_recFirst); // Reklamationsart holen
  Erx # RekLink(850,301,7,_recFirst); // Status holen

  // Kunde
  if (Rek.ZuDatei=400) then begin
    GV.Alpha.01 # 'Kd';
  end
  // Lieferant
  else if (Rek.ZuDatei=500) then begin
    GV.Alpha.01 # 'Lf';
  end
  else if (Rek.ZuDatei=701) or (Rek.ZuDatei=707) then begin
    GV.Alpha.01 # 'Lf';
  end;

  // Material
  Mat_Data:Read(Rek.P.Materialnr);

  if ("Rek.P.Lösch.Datum">0.0.0) then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);

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
  RefreshMode(y);
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
  vTxtHdl # $Rek.P.Text1->wpdbTextBuf;
  if (vTxtHdl<>0) then TextClose(vTxtHdl);

  RETURN true;
end;


//========================================================================
// TxtRead
//              Texte auslesen
//========================================================================
sub TxtRead()
local begin
  vTxtHdl_L1  : int;         // Handle des Textes
  vTxtHdl_L2  : int;         // Handle des Textes
  vTxtHdl_L3  : int;         // Handle des Textes
  vTxtHdl_L4  : int;         // Handle des Textes
  vTxtHdl_L5  : int;         // Handle des Textes
  vName       : alpha;
end;
begin

  if (Mode=c_ModeEdit) then RETURN

  // Text laden
  vTxtHdl_L1 # $Rek.P.Text1->wpdbTextBuf;
  if (Rek.P.Nummer=0) or (Rek.P.Nummer>1000000000) then
    vName # myTmpText+'.301.'+CnvAI(Rek.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.1'
  else
    vName # '~301.'+CnvAI(Rek.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Rek.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.1';

  Lib_Texte:TxtLoad5Buf(vName, vTxtHdl_L1, 0 ,0, 0, 0);

  // Textpuffer an Felderübergeben
  $Rek.P.Text1->wpdbTextBuf # vTxtHdl_L1;
  $Rek.P.Text1->WinUpdate(_WinUpdBuf2Obj);
end;


//========================================================================
// TxtSave
//              Text abspeichern
//========================================================================
sub TxtSave()
local begin
  vTxtHdl_L1  : int;         // Handle des Textes
  vTxtHdl_L2  : int;         // Handle des Textes
  vTxtHdl_L3  : int;         // Handle des Textes
  vTxtHdl_L4  : int;         // Handle des Textes
  vTxtHdl_L5  : int;         // Handle des Textes
  vName       : alpha;
end
begin

  vTxtHdl_L1 # $Rek.P.Text1->wpdbTextBuf;
  $Rek.P.Text1->WinUpdate(_WinUpdObj2Buf);
  if (Rek.P.Nummer=0) or (Rek.P.Nummer>1000000000) then
    vName # myTmpText+'.301.'+CnvAI(Rek.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.1'
  else
    vName # '~301.'+CnvAI(Rek.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Rek.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.1';

  Lib_Texte:TxtSave5Buf(vNAme, vTxtHdl_L1, 0,0,0,0);
END;


//========================================================================
//  AusSerienMark [27.01.2010/PW]
//
//========================================================================
sub AusSerienMark ()
local begin
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vQ        : alpha(500);
  vQ2       : alpha(500);
  vListHdl  : handle;
end;
begin
  vListHdl # gZlList;
  vListHdl->wpDisabled # false;
  Lib_GuiCom:SetWindowState( gMDI, true );

  /* Selektion */
  if ( GV.Logic.01 ) or ( GV.Logic.02 ) or ( GV.Logic.03 ) or ( GV.Logic.04 ) then begin // nur Verursacher: X
    if ( GV.Logic.01 ) then
      Lib_Sel:QInt( var vQ2, 'Rek.P.Verursacher', '=', 1, 'OR' );
    if ( GV.Logic.02 ) then
      Lib_Sel:QInt( var vQ2, 'Rek.P.Verursacher', '=', 2, 'OR' );
    if ( GV.Logic.03 ) then
      Lib_Sel:QInt( var vQ2, 'Rek.P.Verursacher', '=', 3, 'OR' );
    if ( GV.Logic.04 ) then
      Lib_Sel:QInt( var vQ2, 'Rek.P.Verursacher', '=', 4, 'OR' );
    vQ # '( ' + vQ2 + ' )'
  end;
  if ( GV.Ints.01 != 0 ) or ( GV.Ints.02 != 99 ) then // Status von/bis
    Lib_Sel:QVonBisI( var vQ, 'Rek.P.Status', GV.Ints.01, GV.Ints.02 );
  if ( GV.Ints.03 != 0 ) or ( GV.Ints.04 != 99 ) then // Fehlercode von/bis
    Lib_Sel:QVonBisI( var vQ, 'Rek.P.Fehlercode', GV.Ints.03, GV.Ints.04 );

  // Selektion durchführen
  vSel # SelCreate( 301, 1 );
  vSel->SelDefQuery( '', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  // Ergebnisse markieren
  FOR  Erx # RecRead( 301, vSel, _recFirst );
  LOOP Erx # RecRead( 301, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    Lib_Mark:MarkAdd( 301, true, true );
  END;

  // Selektion entfernen
  SelClose( vSel );
  SelDelete( 301, vSelName );

  vListHdl->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect );
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edRek.Art') AND (Rek.Art<>0)) then begin
    RekLink(849,300,2,0);   // Rekklamationsart holen
    Lib_Guicom2:JumpToWindow('Rek.Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRek.Status') AND (Rek.Status<>0)) then begin
    RekLink(850,300,3,0);   // Status holen
    Lib_Guicom2:JumpToWindow('VgSt.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edRek.Lieferantennr') AND (Rek.Lieferantennr<>0)) then begin
    RekLink(100,300,10,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edRek.Kommission') AND (Rek.Kommission<>'')) then begin
    Auf.P.Nummer # BAG.F.Auftragsnummer;
    Auf.P.Position # BAG.F.Auftragspos;
    RecRead(401,1,0);
    Lib_Guicom2:JumpToWindow('BA1.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRek.Sachbearbeiter') AND (Rek.Sachbearbeiter<>'')) then begin
    Usr.Name # Rek.Sachbearbeiter;
    RecRead(800,2,0);
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edRek.Aktenuser') AND (Rek.Aktenuser<>'')) then begin
    Usr.Funktion # Rek.Aktenuser;
    RecRead(800,3,0);
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRek.P.Status') AND (Rek.P.Status<>0)) then begin
    RekLink(850,301,7,0);   // Status holen
    Lib_Guicom2:JumpToWindow('VgSt.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRek.P.Materialnr') AND (Rek.P.Materialnr<>0)) then begin
    RekLink(200,301,3,0);   // MaterialNr. holen
    Lib_Guicom2:JumpToWindow('Auf.A.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================