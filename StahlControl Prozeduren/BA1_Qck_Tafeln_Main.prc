@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Qck_Tafeln_Main
//                    OHNE E_R_G
//  Info
//
//
//  09.06.2015  AH  Erstellung der Prozedur
//  01.07.2015  AH  für 4 Fertigungen
//  26.07.2016  AH  für 6 Fertigungen
//  22.08.2016  ST  Titel von "Sägen" auf "Tafeln" geändert
//  02.11.2016  AH  Haken für Etiketten
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB Start(aMatNr : int) : logic;
//    SUB EvtInit...
//    SUB EvtClose...
//    SUB Pflichtfelder();
//    SUB Auswahl(aBereich : alpha)
//    SUB RefreshIfm(opt aName : alpha; opt aChanged : logic)
//    SUB EvtFocusInit...
//    SUB EvtFocusTerm...
//    SUB EvtMenuCommand...
//    SUB RefreshMode( opt aNoRefresh : logic)
//    SUB EvtClicked...
//    SUB AusKommi.1()
//    SUB AusKommiSL.1()
//    SUB AusKommi.2()
//    SUB AusKommiSL.2()
//    SUB AusKommi.3()
//    SUB AusKommiSL.3()
//    SUB AusKommi.4()
//    SUB AusKommiSL.4()
//    SUB AusKommi.5()
//    SUB AusKommiSL.5()
//    SUB AusKommi.6()
//    SUB AusKommiSL.6()
//    SUB RecCleanup() : logic
//    SUB RecSave() : logic;
//
//    sub Verbuchen() : alpha;
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin

  cDialog         : 'BA1.Qck.Tafeln'
  cMdiVar         : gMDIBAG
  cRecht          : Rgt_BAG

  cTitle          : 'Tafeln'
  cMenuName       : 'Std.Bearbeiten'
//  cMenuName : 'Sel.Dialog'
  cPrefix         : 'BA1_Qck_Tafeln'


  cEinsatzMat     : $lb.Material.Einsatz->wpcaption
  cEinsatzCharge  : $lbCharge.Einsatz->wpcaption
  cEinsatzArtikel : $lbArtikelnr.Einsatz->wpcaption
  cEinsatzAbm     : $lbAbm.Einsatz->wpcaption
  cEinsatzUrStk   : $lbBestand.Stk.Einsatz->wpcaption
  cEinsatzUrGew   : $lbBestand.Gew.Einsatz->wpcaption
  cEinsatzRestStk : $lbRest.Stk.Einsatz->wpcaption
  cEinsatzRestGew : $lbRest.Gew.Einsatz->wpcaption

  cEinsatzGew     : $lbGew.Einsatz->wpcaption
  cEinsatzStk     : $lbStk.Einsatz->wpcaption
  cEntnahmeStk    : $edStk.Entnahme->wpcaptionint
  cEntnahmeGew    : $edGew.Entnahme->wpcaptionfloat
  cZurueckStk     : $edStk.Zurueck->wpcaptionint
  cZurueckGew     : $edGew.Zurueck->wpcaptionFloat

  cKommi1         : $edKommission.1->wpcaption
  cKunde1         : $lbKunde.1 ->wpcaption
  cArtikel1       : $edArtikelnr.1->wpcaption
  cFertigStk1     : $edStk.1->wpcaptionint
  cFertigD1       : $edDicke.1->wpcaptionfloat
  cFertigB1       : $edBreite.1->wpcaptionfloat
  cFertigL1       : $edLaenge.1->wpcaptionfloat
  cFertigGew1     : $edGew.1->wpcaptionfloat
  cKosten1        : $cbKostentraeger.1->wpCheckState=_WinStateChkChecked

  cKommi2         : $edKommission.2->wpcaption
  cKunde2         : $lbKunde.2 ->wpcaption
  cArtikel2       : $edArtikelnr.2->wpcaption
  cFertigStk2     : $edStk.2->wpcaptionint
  cFertigD2       : $edDicke.2->wpcaptionfloat
  cFertigB2       : $edBreite.2->wpcaptionfloat
  cFertigL2       : $edLaenge.2->wpcaptionfloat
  cFertigGew2     : $edGew.2->wpcaptionfloat
  cKosten2        : $cbKostentraeger.2->wpCheckState=_WinStateChkChecked

  cKommi3         : $edKommission.3->wpcaption
  cKunde3         : $lbKunde.3 ->wpcaption
  cArtikel3       : $edArtikelnr.3->wpcaption
  cFertigStk3     : $edStk.3->wpcaptionint
  cFertigD3       : $edDicke.3->wpcaptionfloat
  cFertigB3       : $edBreite.3->wpcaptionfloat
  cFertigL3       : $edLaenge.3->wpcaptionfloat
  cFertigGew3     : $edGew.3->wpcaptionfloat
  cKosten3        : $cbKostentraeger.3->wpCheckState=_WinStateChkChecked

  cKommi4         : $edKommission.4->wpcaption
  cKunde4         : $lbKunde.4 ->wpcaption
  cArtikel4       : $edArtikelnr.4->wpcaption
  cFertigStk4     : $edStk.4->wpcaptionint
  cFertigD4       : $edDicke.4->wpcaptionfloat
  cFertigB4       : $edBreite.4->wpcaptionfloat
  cFertigL4       : $edLaenge.4->wpcaptionfloat
  cFertigGew4     : $edGew.4->wpcaptionfloat
  cKosten4        : $cbKostentraeger.4->wpCheckState=_WinStateChkChecked

  cKommi5         : $edKommission.5->wpcaption
  cKunde5         : $lbKunde.5 ->wpcaption
  cArtikel5       : $edArtikelnr.5->wpcaption
  cFertigStk5     : $edStk.5->wpcaptionint
  cFertigD5       : $edDicke.5->wpcaptionfloat
  cFertigB5       : $edBreite.5->wpcaptionfloat
  cFertigL5       : $edLaenge.5->wpcaptionfloat
  cFertigGew5     : $edGew.5->wpcaptionfloat
  cKosten5        : $cbKostentraeger.5->wpCheckState=_WinStateChkChecked

  cKommi6         : $edKommission.6->wpcaption
  cKunde6         : $lbKunde.6 ->wpcaption
  cArtikel6       : $edArtikelnr.6->wpcaption
  cFertigStk6     : $edStk.6->wpcaptionint
  cFertigD6       : $edDicke.6->wpcaptionfloat
  cFertigB6       : $edBreite.6->wpcaptionfloat
  cFertigL6       : $edLaenge.6->wpcaptionfloat
  cFertigGew6     : $edGew.6->wpcaptionfloat
  cKosten6        : $cbKostentraeger.6->wpCheckState=_WinStateChkChecked

  cEtiketten      : $cbEtiketten->wpCheckState=_WinStateChkChecked
  cVerwiegungsart       : 1
//  cFertigungRest        : 500
//  cFertigungRestSchrott : 501
end;

declare RefreshIfm(opt aName : alpha;  opt aChanged : logic)

//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  aMatNr  : int) : logic;
local begin
  Erx : int;
end;
begin
  Erx # Mat_Data:Read(aMatNr);
  if (Erx<>200) then RETURN false;

  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, 0, false);

  RETURN true;
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vA  : alpha;
end;
begin

  WinSearchPath(aEvt:Obj);
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gFile     # 700;

  Mode      # c_Modenew;
  w_NoList  # true;
  gSelected # 0;

  // Auswahlfelder setzen...
  SetStdAusFeld('edKommission.1'    ,'Kommi.1');
  SetStdAusFeld('edKommission.2'    ,'Kommi.2');
  SetStdAusFeld('edKommission.3'    ,'Kommi.3');
  SetStdAusFeld('edKommission.4'    ,'Kommi.4');
  SetStdAusFeld('edKommission.5'    ,'Kommi.5');
  SetStdAusFeld('edKommission.6'    ,'Kommi.6');
  SetStdAusFeld('edArtikelnr.1'     ,'Artikel.1');
  SetStdAusFeld('edArtikelnr.2'     ,'Artikel.2');
  SetStdAusFeld('edArtikelnr.3'     ,'Artikel.3');
  SetStdAusFeld('edArtikelnr.4'     ,'Artikel.4');
  SetStdAusFeld('edArtikelnr.5'     ,'Artikel.5');
  SetStdAusFeld('edArtikelnr.6'     ,'Artikel.6');

  $edGew.1->wpDecimals # Set.Stellen.Gewicht;
  $edGew.2->wpDecimals # Set.Stellen.Gewicht;
  $edGew.3->wpDecimals # Set.Stellen.Gewicht;
  $edGew.4->wpDecimals # Set.Stellen.Gewicht;
  $edGew.5->wpDecimals # Set.Stellen.Gewicht;
  $edGew.6->wpDecimals # Set.Stellen.Gewicht;

  App_Main:EvtInit(aEvt);

  RefreshIfm();

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
//  Calc
//========================================================================
sub Calc(aName : alpha);
begin
  case (aName) of
    'GewEntnahme' :
      cEntnahmeGew # rnd(Lib_Berechnungen:Dreisatz( cnvfa(cEinsatzUrGew), cnvfi(Mat.Bestand.Stk), cnvfi(cEntnahmeStk)), Set.Stellen.Gewicht);

    'GewZurueck' :
      cZurueckGew # rnd(Lib_Berechnungen:Dreisatz( cnvfa(cEinsatzUrGew), cnvfi(Mat.Bestand.Stk), cnvfi(cZurueckStk)), Set.Stellen.Gewicht);

    'Gew1' :
      cFertigGew1 # Lib_Berechnungen:KG_aus_StkDBLWgrArt(cFertigStk1, cFertigD1, cFertigB1, cFertigL1, Mat.Warengruppe, "Mat.Güte", cArtikel1);

    'Gew2' :
      cFertigGew2 # Lib_Berechnungen:KG_aus_StkDBLWgrArt(cFertigStk2, cFertigD2, cFertigB2, cFertigL2, Mat.Warengruppe, "Mat.Güte", cArtikel2);

    'Gew3' :
      cFertigGew3 # Lib_Berechnungen:KG_aus_StkDBLWgrArt(cFertigStk3, cFertigD3, cFertigB3, cFertigL3, Mat.Warengruppe, "Mat.Güte", cArtikel3);

    'Gew4' :
      cFertigGew4 # Lib_Berechnungen:KG_aus_StkDBLWgrArt(cFertigStk4, cFertigD4, cFertigB4, cFertigL4, Mat.Warengruppe, "Mat.Güte", cArtikel4);

    'Gew5' :
      cFertigGew5 # Lib_Berechnungen:KG_aus_StkDBLWgrArt(cFertigStk5, cFertigD5, cFertigB5, cFertigL5, Mat.Warengruppe, "Mat.Güte", cArtikel5);

    'Gew6' :
      cFertigGew6 # Lib_Berechnungen:KG_aus_StkDBLWgrArt(cFertigStk6, cFertigD6, cFertigB6, cFertigL6, Mat.Warengruppe, "Mat.Güte", cArtikel6);

  end;

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  Lib_GuiCom:Pflichtfeld($edStk.Entnahme);
  Lib_GuiCom:Pflichtfeld($edGew.Entnahme);
  if (cKommi1<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.1);
    Lib_GuiCom:Pflichtfeld($edDicke.1);
    Lib_GuiCom:Pflichtfeld($edBreite.1);
    Lib_GuiCom:Pflichtfeld($edLaenge.1);
    Lib_GuiCom:Pflichtfeld($edGew.1);
  end;
  if (cKommi2<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.2);
    Lib_GuiCom:Pflichtfeld($edDicke.2);
    Lib_GuiCom:Pflichtfeld($edBreite.2);
    Lib_GuiCom:Pflichtfeld($edLaenge.2);
    Lib_GuiCom:Pflichtfeld($edGew.2);
  end;
  if (cKommi3<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.3);
    Lib_GuiCom:Pflichtfeld($edDicke.3);
    Lib_GuiCom:Pflichtfeld($edBreite.3);
    Lib_GuiCom:Pflichtfeld($edLaenge.3);
    Lib_GuiCom:Pflichtfeld($edGew.3);
  end;
  if (cKommi4<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.4);
    Lib_GuiCom:Pflichtfeld($edDicke.4);
    Lib_GuiCom:Pflichtfeld($edBreite.4);
    Lib_GuiCom:Pflichtfeld($edLaenge.4);
    Lib_GuiCom:Pflichtfeld($edGew.4);
  end;
  if (cKommi5<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.5);
    Lib_GuiCom:Pflichtfeld($edDicke.5);
    Lib_GuiCom:Pflichtfeld($edBreite.5);
    Lib_GuiCom:Pflichtfeld($edLaenge.5);
    Lib_GuiCom:Pflichtfeld($edGew.5);
  end;
  if (cKommi6<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.6);
    Lib_GuiCom:Pflichtfeld($edDicke.6);
    Lib_GuiCom:Pflichtfeld($edBreite.6);
    Lib_GuiCom:Pflichtfeld($edLaenge.6);
    Lib_GuiCom:Pflichtfeld($edGew.6);
  end;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich  : alpha;
)
local begin
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
  vFilter : int;
  vSel    : alpha;
  vName   : alpha(500);
  vQ      : alpha(4000);
end;

begin

  vHdl # w_lastFocus;

  case aBereich of

    'Kommi.1' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommi.1');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kommi.2' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommi.2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kommi.3' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommi.3');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kommi.4' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommi.4');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kommi.5' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommi.5');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kommi.6' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommi.6');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Artikel.1' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel.1');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Artikel.2' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel.2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Artikel.3' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel.3');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Artikel.4' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel.4');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Artikel.5' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel.5');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Artikel.6' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel.6');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//========================================================================
sub _RefZeile(
  aName : alpha;
  aWas  : alpha;);
local begin
  Erx       : int;
  vKomObj   : int;
  vKdObj    : int;
  vArtObj   : int;
  vDObj     : int;
  vBObj     : int;
  vLObj     : int;
  vKostObj  : int;
end;
begin
  vKomObj # Winsearch(gMDI, 'edKommission.'+aName);
  vKdObj  # WinSearch(gMDI, 'lbKunde.'+aName);
  vArtObj # WinSearch(gMDI, 'edArtikelnr.'+aName);
  vDObj   # WinSearch(gMDI, 'edDicke.'+aName);
  vBObj   # WinSearch(gMdi, 'edBreite.'+aName);
  vLObj   # WinSearch(gMDI, 'edLaenge.'+aName);
  vKostObj # WinSearch(gMDI, 'cbKostentraeger.'+aName);

  if (aWas='FERT') then begin
    if (Lib_Berechnungen:IntsAusAlpha(vKomObj->wpcaption, var Auf.P.Nummer, var Auf.P.Position, var Auf.SL.lfdNr)) then
      Erx # Auf_Data:Read(Auf.P.Nummer, Auf.P.Position, true, Auf.SL.LfdNr)
    else
      Erx # 0;
    if (Erx=401) and (Auf.Vorgangstyp=c_Auf) then begin
      vKdObj->wpCaption     # Auf.P.KundenSW;
      vArtObj->wpCaption    # Auf.P.Artikelnr;
      vDObj->wpcaptionfloat # Auf.P.Dicke;
      vBObj->wpcaptionfloat # Auf.P.Breite;
      vLObj->wpcaptionfloat # "Auf.P.Länge";
      vKostObj->wpCheckState # _WinStateChkChecked;
      if (Auf.SL.LfdNr<>0) then begin
        vDObj->wpcaptionfloat # Auf.SL.Dicke;
        vBObj->wpcaptionfloat # Auf.SL.Breite;
        vLObj->wpcaptionfloat # "Auf.SL.Länge";
      end;
      Art.Nummer # cArtikel1;
      Erx # RecRead(250,1,0);
      if (Erx<=_rLocked) then begin
        if (vDObj->wpcaptionfloat=0.0) then vDObj->wpcaptionfloat # Art.Dicke;
        if (vBObj->wpcaptionfloat=0.0) then vBObj->wpcaptionfloat # Art.Breite
        if (vLObj->wpcaptionfloat=0.0) then vLObj->wpcaptionfloat # "Art.Länge";
      end;
    end
    else begin
      vKostObj->wpCheckState # _WinStateChkUnchecked;
      vKomObj->wpcaption   # '';
      vKdObj->wpcaption     # '';
      vArtObj->wpcaption    # '';
      vDObj->wpcaptionfloat # 0.0;
      vBObj->wpcaptionfloat # 0.0;
      vLObj->wpcaptionfloat # 0.0;
    end;
  end;


  if (aWas='ART') then begin
    Art.Nummer # vArtObj->wpcaption;
    Erx # RecRead(250,1,0);
    if (Erx<=_rLocked) then begin
      vDObj->wpcaptionfloat # Art.Dicke;
      vBObj->wpcaptionfloat # Art.Breite;
      vLObj->wpcaptionfloat # "Art.Länge";
    end;
  end;

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic)
local begin
  vA      : alpha(200);
  vMenge  : float;
end;
begin

  if (Mode=c_modeOther) then RETURN;

  // Einsatz
  if (aName='') then begin
    cEinsatzMat     # aint(Mat.Nummer);
    cEinsatzCharge  # Mat.Chargennummer;
    cEinsatzArtikel # Mat.Strukturnr;
    if (Mat.Dicke<>0.0) then vA # anum(Mat.Dicke, Set.Stellen.Dicke);
    if (Mat.Breite<>0.0) then begin
      if (vA<>'') then vA # vA + ' x ';
      vA # vA + anum(Mat.Breite, Set.Stellen.Breite);
    end;
    if ("Mat.Länge"<>0.0) then begin
      if (vA<>'') then vA # vA + ' x ';
      vA # vA + anum("Mat.Länge", "Set.Stellen.Länge");
    end;
    cEinsatzAbm     # vA;
    cEinsatzUrStk   # aint(Mat.Bestand.Stk);
    cEinsatzUrGew   # anum(Mat.Bestand.Gew, Set.Stellen.Gewicht);
    if (Mat.MEH='m') then vMenge # Mat.Bestand.Menge
    else vMenge # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, 'm') , Set.Stellen.Menge);

    $edStk.Entnahme->wpMaxInt   # Mat.Bestand.Stk;
    $edGew.Entnahme->wpMaxFloat # Mat.Bestand.Gew;
  end;

  cEinsatzStk # aint(cEntnahmeStk - cZurueckStk);
  cEinsatzGew # anum(cEntnahmeGew - cZurueckGew, Set.Stellen.Gewicht);

  if (cnvfa(cEinsatzGew)<0.0) then begin
    cEinsatzGew   # '';
    cZurueckGew   # 0.0;
    cEntnahmeGew  # 0.0;
    WinFocusSet($edGew.Entnahme, true);
    RETURN;
  end;

  cEinsatzRestStk # aint(Mat.Bestand.Stk - cnvia(cEinsatzStk));
  cEinsatzRestGew # anum(Mat.Bestand.Gew - cnvfa(cEinsatzGew), Set.Stellen.Gewicht);


  // 1. Fertigung
  if (aName='edKommission.1') and (($edKommission.1->wpchanged) or (aChanged)) then
    _RefZeile('1','FERT');
  // 2. Fertigung
  if (aName='edKommission.2') and (($edKommission.2->wpchanged) or (aChanged)) then
    _RefZeile('2','FERT');
  // 3. Fertigung
  if (aName='edKommission.3') and (($edKommission.3->wpchanged) or (aChanged)) then
    _RefZeile('3','FERT');
  // 4. Fertigung
  if (aName='edKommission.4') and (($edKommission.4->wpchanged) or (aChanged)) then
    _RefZeile('4','FERT');
  // 5. Fertigung
  if (aName='edKommission.5') and (($edKommission.5->wpchanged) or (aChanged)) then
    _RefZeile('5','FERT');
  // 6. Fertigung
  if (aName='edKommission.6') and (($edKommission.6->wpchanged) or (aChanged)) then
    _RefZeile('6','FERT');
/***
  // 1. Fertigung
  if (aName='edKommission.1') and (($edKommission.1->wpchanged) or (aChanged)) then begin
    if (Lib_Berechnungen:IntsAusAlpha(cKommi1, var Auf.P.Nummer, var Auf.P.Position, var Auf.SL.lfdNr)) then
     Erx # Auf_Data:Read(Auf.P.Nummer, Auf.P.Position, true, Auf.SL.LfdNr)
    else
      Erx # 0;
    if (Erx=401) and (Auf.Vorgangstyp=c_Auf) then begin
      cKunde1   # Auf.P.KundenSW;
      cArtikel1 # Auf.P.Artikelnr;
      cFertigD1 # Auf.P.Dicke;
      cFertigB1 # Auf.P.Breite;
      cFertigL1 # "Auf.P.Länge";
      $cbKostentraeger.1->wpCheckState # _WinStateChkChecked;
      if (Auf.SL.LfdNr<>0) then begin
        cFertigD1 # Auf.SL.Dicke;
        cFertigB1 # Auf.SL.Breite;
        cFertigL1 # "Auf.SL.Länge";
      end;
      Art.Nummer # cArtikel1;
      Erx # RecRead(250,1,0);
      if (Erx<=_rLocked) then begin
        if (cFertigD1=0.0) then cFertigD1 # Art.Dicke;
        if (cFertigB1=0.0) then cFertigB1 # Art.Breite
        if (cFertigL1=0.0) then cFertigL1 # "Art.Länge";
      end;
    end
    else begin
      $cbKostentraeger.1->wpCheckState # _WinStateChkUnchecked;
      cKommi1   # '';
      cKunde1   # '';
      cArtikel1 # '';
      cFertigD1 # 0.0;
      cFertigB1 # 0.0;
      cFertigL1 # 0.0;
    end;
  end;
***/


  // 1. Artikel
  if (aName='edArtikelnr.1') and (($edArtikelnr.1->wpchanged) or (aChanged)) then
    _RefZeile('1','ART');
  // 2. Artikel
  if (aName='edArtikelnr.2') and (($edArtikelnr.2->wpchanged) or (aChanged)) then
    _RefZeile('2','ART');
  // 3. Artikel
  if (aName='edArtikelnr.3') and (($edArtikelnr.3->wpchanged) or (aChanged)) then
    _RefZeile('3','ART');
  // 4. Artikel
  if (aName='edArtikelnr.4') and (($edArtikelnr.4->wpchanged) or (aChanged)) then
    _RefZeile('4','ART');
  // 5. Artikel
  if (aName='edArtikelnr.5') and (($edArtikelnr.5->wpchanged) or (aChanged)) then
    _RefZeile('5','ART');
  // 6. Artikel
  if (aName='edArtikelnr.6') and (($edArtikelnr.6->wpchanged) or (aChanged)) then
    _RefZeile('6','ART');


  // einfärben der Pflichtfelder
  Pflichtfelder();

end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt          : event;
  aFocusObject  : int;
) : logic
local begin
  vHdl          : int;
end;
begin
debug(aEvt:Obj->wpname);
  if (aEvt:Obj->wpname='jump1') then begin
    vHdl # $cbKostentraeger.1;
    if (aFocusObject<>0) then begin
      if (aFocusObject->wpname='edKommission.1') and (cKommi1<>'') then vHdl # $edStk.1
      else if (aFocusObject->wpname='cbKostentraeger.1') then vHdl # $edKommission.1;
    end
    WinFocusSet(vHdl, true);
    RETURN false;
  end;
  if (aEvt:Obj->wpname='jump2') then begin
    vHdl # $cbKostentraeger.2;
    if (aFocusObject<>0) then begin
      if (aFocusObject->wpname='edKommission.2') and (cKommi2<>'') then vHdl # $edStk.2
      else if (aFocusObject->wpname='cbKostentraeger.2') then vHdl # $edKommission.2;
    end
    WinFocusSet(vHdl, true);
    RETURN false;
  end;
  if (aEvt:Obj->wpname='jump3') then begin
    vHdl # $cbKostentraeger.3;
    if (aFocusObject<>0) then begin
      if (aFocusObject->wpname='edKommission.3') and (cKommi3<>'') then vHdl # $edStk.3
      else if (aFocusObject->wpname='cbKostentraeger.3') then vHdl # $edKommission.3;
    end
    WinFocusSet(vHdl, true);
    RETURN false;
  end;
  if (aEvt:Obj->wpname='jump4') then begin
    vHdl # $cbKostentraeger.4;
    if (aFocusObject<>0) then begin
      if (aFocusObject->wpname='edKommission.4') and (cKommi4<>'') then vHdl # $edStk.4
      else if (aFocusObject->wpname='cbKostentraeger.4') then vHdl # $edKommission.4;
    end
    WinFocusSet(vHdl, true);
    RETURN false;
  end;
  if (aEvt:Obj->wpname='jump5') then begin
    vHdl # $cbKostentraeger.5;
    if (aFocusObject<>0) then begin
      if (aFocusObject->wpname='edKommission.5') and (cKommi5<>'') then vHdl # $edStk.5
      else if (aFocusObject->wpname='cbKostentraeger.5') then vHdl # $edKommission.5;
    end
    WinFocusSet(vHdl, true);
    RETURN false;
  end;
  if (aEvt:Obj->wpname='jump6') then begin
    vHdl # $cbKostentraeger.6;
    if (aFocusObject<>0) then begin
      if (aFocusObject->wpname='edKommission.6') and (cKommi6<>'') then vHdl # $edStk.6
      else if (aFocusObject->wpname='cbKostentraeger.6') then vHdl # $edKommission.6;
    end
    WinFocusSet(vHdl, true);
    RETURN false;
  end;

  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

  RETURN true;
end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt          : event;
  aFocusObject  : int;
) : logic
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  case (aEvt:Obj->wpname) of

    'edStk.Entnahme' : begin
      if ($edStk.Entnahme->wpchanged) and (cEntnahmeGew=0.0) then
        Calc('GewEntnahme');
    end;


    'edStk.Zurueck' : begin
      if ($edStk.Zurueck->wpchanged) and (cZurueckGew=0.0) then
        Calc('GewZurueck');
    end;

    'edStk.1' : begin
      if (cFertigGew1=0.0) then Calc('Gew1');
    end;

    'edStk.2' : begin
      if (cFertigGew2=0.0) then Calc('Gew2');
    end;

    'edStk.3' : begin
      if (cFertigGew3=0.0) then Calc('Gew3');
    end;

    'edStk.4' : begin
      if (cFertigGew4=0.0) then Calc('Gew4');
    end;

    'edStk.5' : begin
      if (cFertigGew5=0.0) then Calc('Gew5');
    end;

    'edStk.6' : begin
      if (cFertigGew6=0.0) then Calc('Gew6');
    end;

  end;


  RETURN true;
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
  vHdl  : handle;
  vHdl2 : handle;
  vA    : alpha;
end;
begin
  if (aMenuItem->wpName='Mnu.Ktx.Errechnen') then begin

    case (aEvt:Obj->wpname) of

      'edGew.Entnahme' :
        Calc('GewEntnahme');


      'edGew.Zurueck' :
        Calc('GewZurueck');


      'edGew.1' :
        Calc('Gew1');

      'edGew.2' :
        Calc('Gew2');

      'edGew.3' :
        Calc('Gew3');

      'edGew.4' :
        Calc('Gew4');

      'edGew.5' :
        Calc('Gew5');

      'edGew.6' :
        Calc('Gew6');

    end;

  end;  // 'Menü

end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode (
  opt aNoRefresh : logic;
)
local begin
  vHdl           : int;
end
begin
  gMenu # gFrmMain->WinInfo( _winMenu );

  // Buttons und Menüs sperren
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked (
  aEvt            : event
) : logic
local begin
  vI  : int;
end;
begin
  case (aEvt:obj->wpname) of
    'btKommission.1'    : Auswahl('Kommi.1');
    'btKommission.2'    : Auswahl('Kommi.2');
    'btKommission.3'    : Auswahl('Kommi.3');
    'btKommission.4'    : Auswahl('Kommi.4');
    'btKommission.5'    : Auswahl('Kommi.5');
    'btKommission.6'    : Auswahl('Kommi.6');
    'btArtikelnr.1'     : Auswahl('Artikel.1');
    'btArtikelnr.2'     : Auswahl('Artikel.2');
    'btArtikelnr.3'     : Auswahl('Artikel.3');
    'btArtikelnr.4'     : Auswahl('Artikel.4');
    'btArtikelnr.5'     : Auswahl('Artikel.5');
    'btArtikelnr.6'     : Auswahl('Artikel.6');
  end;
end;


//========================================================================
//  AusKommi.1
//
//========================================================================
sub AusKommi.1()
local begin
  vHdl  : int;
end;
begin

  if (gSelected=0) then RETURN

  RecRead(401,0,_RecId,gSelected);
  gSelected # 0;
  cKommi1 # aint(auf.p.nummer)+'/'+aint(auf.p.position);

  // mit Stückliste?
  if (RecLinkInfo(409,401,15,_RecCount)>0) then begin
    RecBufClear(409);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.SL.Verwaltung',here+':AusKommiSL.1');
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;
  end;

  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.1', true);

end;


//========================================================================
// AusKommiSL.1
//========================================================================
sub AusKommiSL.1()
local begin
  vHdl  : int;
end;
begin

  if (gSelected=0) then RETURN

  RecRead(409,0,_RecId,gSelected);
  gSelected # 0;
  cKommi1 # aint(auf.SL.nummer)+'/'+aint(auf.SL.position)+'/'+aint(Auf.SL.lfdNr);
  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.1', true);
end;


//========================================================================
//  AusKommi.2
//
//========================================================================
sub AusKommi.2()
local begin
  vHdl  : int;
end;
begin

  if (gSelected=0) then RETURN;
  RecRead(401,0,_RecId,gSelected);
  gSelected # 0;
  cKommi2 # aint(auf.p.nummer)+'/'+aint(auf.p.position);

  // mit Stückliste?
  if (RecLinkInfo(409,401,15,_RecCount)>0) then begin
    RecBufClear(409);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.SL.Verwaltung',here+':AusKommiSL.2');
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;
  end;

  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.2', true);

end;


//========================================================================
// AusKommiSL.2
//========================================================================
sub AusKommiSL.2()
local begin
  vHdl  : int;
end;
begin

  if (gSelected=0) then RETURN

  RecRead(409,0,_RecId,gSelected);
  gSelected # 0;
  cKommi2 # aint(auf.SL.nummer)+'/'+aint(auf.SL.position)+'/'+aint(Auf.SL.lfdNr);
  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.2', true);
end;


//========================================================================
//  AusKommi.3
//
//========================================================================
sub AusKommi.3()
local begin
  vHdl : int;
end;
begin

  if (gSelected=0) then RETURN;

  RecRead(401,0,_RecId,gSelected);
  gSelected # 0;
  cKommi3 # aint(auf.p.nummer)+'/'+aint(auf.p.position);

  // mit Stückliste?
  if (RecLinkInfo(409,401,15,_RecCount)>0) then begin
    RecBufClear(409);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.SL.Verwaltung',here+':AusKommiSL.3');
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;
  end;

  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.3', true);

end;


//========================================================================
// AusKommiSL.3
//========================================================================
sub AusKommiSL.3()
local begin
  vHdl  : int;
end;
begin

  if (gSelected=0) then RETURN

  RecRead(409,0,_RecId,gSelected);
  gSelected # 0;
  cKommi3 # aint(auf.SL.nummer)+'/'+aint(auf.SL.position)+'/'+aint(Auf.SL.lfdNr);
  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.3', true);
end;


//========================================================================
//  AusKommi.4
//
//========================================================================
sub AusKommi.4()
local begin
  vHdl : int;
end;
begin

  if (gSelected=0) then RETURN;

  RecRead(401,0,_RecId,gSelected);
  gSelected # 0;
  cKommi4 # aint(auf.p.nummer)+'/'+aint(auf.p.position);

  // mit Stückliste?
  if (RecLinkInfo(409,401,15,_RecCount)>0) then begin
    RecBufClear(409);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.SL.Verwaltung',here+':AusKommiSL.4');
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;
  end;

  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.4', true);

end;


//========================================================================
// AusKommiSL.4
//========================================================================
sub AusKommiSL.4()
local begin
  vHdl  : int;
end;
begin

  if (gSelected=0) then RETURN

  RecRead(409,0,_RecId,gSelected);
  gSelected # 0;
  cKommi4 # aint(auf.SL.nummer)+'/'+aint(auf.SL.position)+'/'+aint(Auf.SL.lfdNr);
  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.4', true);
end;


//========================================================================
//  AusKommi.5
//
//========================================================================
sub AusKommi.5()
local begin
  vHdl : int;
end;
begin

  if (gSelected=0) then RETURN;

  RecRead(401,0,_RecId,gSelected);
  gSelected # 0;
  cKommi5 # aint(auf.p.nummer)+'/'+aint(auf.p.position);

  // mit Stückliste?
  if (RecLinkInfo(409,401,15,_RecCount)>0) then begin
    RecBufClear(409);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.SL.Verwaltung',here+':AusKommiSL.5');
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;
  end;

  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.5', true);

end;


//========================================================================
// AusKommiSL.5
//========================================================================
sub AusKommiSL.5()
local begin
  vHdl  : int;
end;
begin

  if (gSelected=0) then RETURN

  RecRead(409,0,_RecId,gSelected);
  gSelected # 0;
  cKommi5 # aint(auf.SL.nummer)+'/'+aint(auf.SL.position)+'/'+aint(Auf.SL.lfdNr);
  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.5', true);
end;


//========================================================================
//  AusKommi.6
//
//========================================================================
sub AusKommi.6()
local begin
  vHdl : int;
end;
begin

  if (gSelected=0) then RETURN;

  RecRead(401,0,_RecId,gSelected);
  gSelected # 0;
  cKommi6 # aint(auf.p.nummer)+'/'+aint(auf.p.position);

  // mit Stückliste?
  if (RecLinkInfo(409,401,15,_RecCount)>0) then begin
    RecBufClear(409);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.SL.Verwaltung',here+':AusKommiSL.6');
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;
  end;

  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.6', true);

end;


//========================================================================
// AusKommiSL.6
//========================================================================
sub AusKommiSL.6()
local begin
  vHdl  : int;
end;
begin

  if (gSelected=0) then RETURN

  RecRead(409,0,_RecId,gSelected);
  gSelected # 0;
  cKommi6 # aint(auf.SL.nummer)+'/'+aint(auf.SL.position)+'/'+aint(Auf.SL.lfdNr);
  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.6', true);
end;

//========================================================================
//  AusArtikel.1
//
//========================================================================
sub AusArtikel.1()
local begin
  vHdl  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    cArtikel1 # Art.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edArtikelnr.1', true);
  end;

end;


//========================================================================
//  AusArtikel.2
//
//========================================================================
sub AusArtikel.2()
local begin
  vHdl  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    cArtikel2 # Art.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edArtikelnr.2', true);
  end;

end;


//========================================================================
//  AusArtikel.3
//
//========================================================================
sub AusArtikel.3()
local begin
  vHdl  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    cArtikel3 # Art.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edArtikelnr.3', true);
  end;

end;


//========================================================================
//  AusArtikel.4
//
//========================================================================
sub AusArtikel.4()
local begin
  vHdl  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    cArtikel4 # Art.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edArtikelnr.4', true);
  end;

end;


//========================================================================
//  AusArtikel.5
//
//========================================================================
sub AusArtikel.5()
local begin
  vHdl  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    cArtikel5 # Art.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edArtikelnr.5', true);
  end;

end;


//========================================================================
//  AusArtikel.6
//
//========================================================================
sub AusArtikel.6()
local begin
  vHdl  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    cArtikel6 # Art.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
    RefreshIfm('edArtikelnr.6', true);
  end;

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
//========================================================================
sub RecSave() : logic;
local begin
  vOK                 : logic;
  vK1, vK2, vK3, vK4  : alpha;
  vK5, vK6            : alpha;
end;
begin
    // logische Prüfung
  if (Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() = false) then
    RETURN false;

  If (cnvia(cEinsatzGew)=0) then begin
    Msg(001200,Translate('Gewicht'),0,0,0);
    $edGew.Entnahme->winfocusset(true);
    RETURN false;
  end;
  if (cnvia(cEinsatzGew)>cnvia(cEinsatzurGew)) then begin
    Msg(001201,Translate('Gewicht'),0,0,0);
    $edGew.Entnahme->winfocusset(true);
    RETURN false;
  end;

  if (cFertigGew1+cFertigGew2+cFertigGew3+cFertigGew4 > cnvfa(cEinsatzGew)) then begin
    if (Msg(707018,'',_WinIcoWarning,_WinDialogYesNo, 1)<>_WinIdYes) then RETURN false;
  end;


  Mode # c_ModeOther;
  vK1 # cKommi1;
  if (vK1='') and (cKosten1) then vK1 # 'KOSTEN';
  vK2 # cKommi2;
  if (vK2='') and (cKosten2) then vK2 # 'KOSTEN';
  vK3 # cKommi3;
  if (vK3='') and (cKosten3) then vK3 # 'KOSTEN';
  vK4 # cKommi4;
  if (vK4='') and (cKosten4) then vK4 # 'KOSTEN';
  vK5  # cKommi5;
  if (vK5='') and (cKosten5) then vK5 # 'KOSTEN';
  vK6 # cKommi6;
  if (vK6='') and (cKosten6) then vK6 # 'KOSTEN';


  vOK # BA1_Qck_Tafeln_Data:Verbuchen(cnvia(cEinsatzMat), cnvia(cEinsatzStk), cnvfa(cEinsatzGew),
                                            vK1, cArtikel1, cFertigStk1, cFertigD1, cFertigB1, cFertigL1, cFertigGew1,
                                            vK2, cArtikel2, cFertigStk2, cFertigD2, cFertigB2, cFertigL2, cFertigGew2,
                                            vK3, cArtikel3, cFertigStk3, cFertigD3, cFertigB3, cFertigL3, cFertigGew3,
                                            vK4, cArtikel4, cFertigStk4, cFertigD4, cFertigB4, cFertigL4, cFertigGew4,
                                            vK5, cArtikel5, cFertigStk5, cFertigD5, cFertigB5, cFertigL5, cFertigGew5,
                                            vK6, cArtikel6, cFertigStk6, cFertigD6, cFertigB6, cFertigL6, cFertigGew6, cEtiketten);
  Mode # c_ModeNew;

  if (vOK) then begin
    Msg(999998, '', 0, 0, 0);
    RETURN true;
  end;

  ErrorOutput;

  Msg(999998,'',0,0,0);

  RETURN true;
end;



//========================================================================