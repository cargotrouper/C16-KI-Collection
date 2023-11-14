@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Qck_Saegen_Main
//                    OHNE E_R_G
//  Info
//
//
//  15.12.2014  AH  Erstellung der Prozedur
//  10.04.2015  AH  Auftrags-SL in Kommission aktiviert
//  28.08.2015  ST  Bugfix: letzte Kommission4 wurde immer auf Komm.3 verbucht
//  23.03.2016  AH  Erweiterung auf 7 Zeilen + Bemerkung
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
//    ...
//    SUB AusKommi.7()
//    SUB AusKommiSL.1()
//    ...
//    SUB AusKommiSL.7()
//    SUB AusArtikel.1()
//    ... 7
//    SUB AusArtikel.7()

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

  cDialog         : 'BA1.Qck.Saegen'
  cMdiVar         : gMDIBAG
  cRecht          : Rgt_BAG

  cTitle          : 'Sägen'
  cMenuName       : 'Std.Bearbeiten'
//  cMenuName : 'Sel.Dialog'
  cPrefix         : 'BA1_Qck_Saegen'


  cEinsatzMat     : $lb.Material.Einsatz->wpcaption
  cEinsatzCharge  : $lbCharge.Einsatz->wpcaption
  cEinsatzArtikel : $lbArtikelnr.Einsatz->wpcaption
  cEinsatzAbm     : $lbAbm.Einsatz->wpcaption
  cEinsatzUrStk   : $lbBestand.Stk.Einsatz->wpcaption
  cEinsatzUrGew   : $lbBestand.Gew.Einsatz->wpcaption
  cEinsatzUrMe    : $lbBestand.Menge.Einsatz->wpcaption
  cEinsatzRestStk : $lbRest.Stk.Einsatz->wpcaption
  cEinsatzRestGew : $lbRest.Gew.Einsatz->wpcaption
  cEinsatzRestMe  : $lbRest.Menge.Einsatz->wpcaption
  cEinsatzGew     : $lbGew.Einsatz->wpcaption
  cEinsatzMe      : $lbMenge.Einsatz->wpcaption

  cEinsatzStk     : $edStk.Einsatz->wpcaptionint

  cKommi1         : $edKommission.1->wpcaption
  cKunde1         : $lbKunde.1 ->wpcaption
  cArtikel1       : $edArtikelnr.1->wpcaption
  cFertigStk1     : $edStk.1->wpcaptionint
  cFertigL1       : $edLaenge.1->wpcaptionfloat
  cFertigGew1     : $edGew.1->wpcaptionfloat
  cKosten1        : $cbKostentraeger.1->wpCheckState=_WinStateChkChecked
  cBem1           : $edBem.1->wpcaption

  cKommi2         : $edKommission.2->wpcaption
  cKunde2         : $lbKunde.2 ->wpcaption
  cArtikel2       : $edArtikelnr.2->wpcaption
  cFertigStk2     : $edStk.2->wpcaptionint
  cFertigL2       : $edLaenge.2->wpcaptionfloat
  cFertigGew2     : $edGew.2->wpcaptionfloat
  cKosten2        : $cbKostentraeger.2->wpCheckState=_WinStateChkChecked
  cBem2           : $edBem.2->wpcaption

  cKommi3         : $edKommission.3->wpcaption
  cKunde3         : $lbKunde.3 ->wpcaption
  cArtikel3       : $edArtikelnr.3->wpcaption
  cFertigStk3     : $edStk.3->wpcaptionint
  cFertigL3       : $edLaenge.3->wpcaptionfloat
  cFertigGew3     : $edGew.3->wpcaptionfloat
  cKosten3        : $cbKostentraeger.3->wpCheckState=_WinStateChkChecked
  cBem3           : $edBem.3->wpcaption

  cKommi4         : $edKommission.4->wpcaption
  cKunde4         : $lbKunde.4 ->wpcaption
  cArtikel4       : $edArtikelnr.4->wpcaption
  cFertigStk4     : $edStk.4->wpcaptionint
  cFertigL4       : $edLaenge.4->wpcaptionfloat
  cFertigGew4     : $edGew.4->wpcaptionfloat
  cKosten4        : $cbKostentraeger.4->wpCheckState=_WinStateChkChecked
  cBem4           : $edBem.4->wpcaption

  cKommi5         : $edKommission.5->wpcaption
  cKunde5         : $lbKunde.5->wpcaption
  cArtikel5       : $edArtikelnr.5->wpcaption
  cFertigStk5     : $edStk.5->wpcaptionint
  cFertigL5       : $edLaenge.5->wpcaptionfloat
  cFertigGew5     : $edGew.5->wpcaptionfloat
  cKosten5        : $cbKostentraeger.5->wpCheckState=_WinStateChkChecked
  cBem5           : $edBem.5->wpcaption

  cKommi6         : $edKommission.6->wpcaption
  cKunde6         : $lbKunde.6->wpcaption
  cArtikel6       : $edArtikelnr.6->wpcaption
  cFertigStk6     : $edStk.6->wpcaptionint
  cFertigL6       : $edLaenge.6->wpcaptionfloat
  cFertigGew6     : $edGew.6->wpcaptionfloat
  cKosten6        : $cbKostentraeger.6->wpCheckState=_WinStateChkChecked
  cBem6           : $edBem.6->wpcaption

  cKommi7         : $edKommission.7->wpcaption
  cKunde7         : $lbKunde.7->wpcaption
  cArtikel7       : $edArtikelnr.7->wpcaption
  cFertigStk7     : $edStk.7->wpcaptionint
  cFertigL7       : $edLaenge.7->wpcaptionfloat
  cFertigGew7     : $edGew.7->wpcaptionfloat
  cKosten7        : $cbKostentraeger.7->wpCheckState=_WinStateChkChecked
  cBem7           : $edBem.7->wpcaption

  cVerwiegungsart       : 1
end;

local begin
  vKom1, vKom2, vKom3, vKom4 : alpha;
  vKom5, vKom6, vKom7        : alpha;
end;

declare RefreshIfm(opt aName : alpha;  opt aChanged : logic)


//========================================================================
//  sub _GetKommissionen(aKommissionen : alpha)
//      Extrahiert die übergebnenen Kommissionen
//========================================================================
sub _GetKommissionen(aKommissionen : alpha)
begin
  if (aKommissionen = '') then
    RETURN;
  if (Lib_Strings:Strings_Count(aKommissionen, '/') = 0) then
    RETURN;

  vKom1 # Str_Token(aKommissionen,'|',1);
  vKom2 # Str_Token(aKommissionen,'|',2);
  vKom3 # Str_Token(aKommissionen,'|',3);
  vKom4 # Str_Token(aKommissionen,'|',4);
  vKom5 # Str_Token(aKommissionen,'|',5);
  vKom6 # Str_Token(aKommissionen,'|',6);
  vKom7 # Str_Token(aKommissionen,'|',7);
end;


//========================================================================
//  sub _getKommData(aKom : alpha; var a401 : int; var a250 : int ) : logic;
//      Liest die Daten für die angegebene Kommission
//========================================================================
sub _getKommData(aKom : alpha; var a401 : int; var a250 : int ) : logic;
local begin
  Erx : int;
end;
begin
  // Auftrag lesen
  a401->Auf.P.Nummer    # CnvIa(Str_Token(aKom,'/',1));
  a401->Auf.P.Position  # CnvIa(Str_Token(aKom,'/',2));
  if (RecRead(a401,1,0) <> _rOK) then
    RETURN false;

  // Artikel lesen
  a250->Art.Nummer # Auf.P.Artikelnr;
  Erx # RecRead(a250,1,0);     // Artikel holen
  if (Erx<=_rLocked) then
    RETURN false;

end;


//========================================================================
//  sub _SetKommissionen(aKommissionen : alpha)
//      Setzt die Maskenfelder für die hinterlegten Kommissionen
//========================================================================
sub _SetKommissionen()
local begin
  i : int;

  v401 : int;
  v250 : int;
end;
begin

  v401 # RecBufCreate(401);
  v250 # RecBufCreate(250);

  // 1. Kommission -> Basis für Copy PAste
  if (vKom1 <> '') then begin
    cKommi1 # vKom1;
    _getKommData(cKommi1, var v401, var v250);
    cKunde1       # v401->Auf.P.KundenSW;
    cArtikel1     # v401->Auf.P.Artikelnr;
    cFertigL1     # v401->"Auf.P.Länge";
    if (v401->Auf.P.MEH.Wunsch = 'Stk') then
      cFertigStk1 # CnvIf(v401->Auf.P.Menge.Wunsch);
    cFertigGew1 # Rnd( cnvfi(cFertigStk1) * cFertigL1 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
    $cbKostentraeger.1->wpCheckState # _WinStateChkChecked;
  end;

  if (vKom2 <> '') then begin
    cKommi2 # vKom2;
    _getKommData(cKommi2, var v401, var v250);
    cKunde2       # v401->Auf.P.KundenSW;
    cArtikel2     # v401->Auf.P.Artikelnr;
    cFertigL2     # v401->"Auf.P.Länge";
    if (v401->Auf.P.MEH.Wunsch = 'Stk') then
      cFertigStk2 # CnvIf(v401->Auf.P.Menge.Wunsch);
    cFertigGew2 # Rnd( cnvfi(cFertigStk2) * cFertigL2 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
    $cbKostentraeger.2->wpCheckState # _WinStateChkChecked;
  end;

  if (vKom3 <> '') then begin
    cKommi3 # vKom3;
    _getKommData(cKommi3, var v401, var v250);
    cKunde3       # v401->Auf.P.KundenSW;
    cArtikel3     # v401->Auf.P.Artikelnr;
    cFertigL3     # v401->"Auf.P.Länge";
    if (v401->Auf.P.MEH.Wunsch = 'Stk') then
      cFertigStk3 # CnvIf(v401->Auf.P.Menge.Wunsch);
    cFertigGew3 # Rnd( cnvfi(cFertigStk3) * cFertigL3 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
    $cbKostentraeger.3->wpCheckState # _WinStateChkChecked;
  end;

  if (vKom4 <> '') then begin
    cKommi4 # vKom4;
    _getKommData(cKommi4, var v401, var v250);
    cKunde4       # v401->Auf.P.KundenSW;
    cArtikel4     # v401->Auf.P.Artikelnr;
    cFertigL4     # v401->"Auf.P.Länge";
    if (v401->Auf.P.MEH.Wunsch = 'Stk') then
      cFertigStk4 # CnvIf(v401->Auf.P.Menge.Wunsch);
    cFertigGew4 # Rnd( cnvfi(cFertigStk4) * cFertigL4 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
    $cbKostentraeger.4->wpCheckState # _WinStateChkChecked;
  end;

  if (vKom5 <> '') then begin
    cKommi5 # vKom5;
    _getKommData(cKommi5, var v401, var v250);
    cKunde5       # v401->Auf.P.KundenSW;
    cArtikel5     # v401->Auf.P.Artikelnr;
    cFertigL5     # v401->"Auf.P.Länge";
    if (v401->Auf.P.MEH.Wunsch = 'Stk') then
      cFertigStk5 # CnvIf(v401->Auf.P.Menge.Wunsch);
    cFertigGew5 # Rnd( cnvfi(cFertigStk5) * cFertigL5 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
    $cbKostentraeger.5->wpCheckState # _WinStateChkChecked;
  end;

  if (vKom6 <> '') then begin
    cKommi6 # vKom6;
    _getKommData(cKommi6, var v401, var v250);
    cKunde6       # v401->Auf.P.KundenSW;
    cArtikel6     # v401->Auf.P.Artikelnr;
    cFertigL6     # v401->"Auf.P.Länge";
    if (v401->Auf.P.MEH.Wunsch = 'Stk') then
      cFertigStk6 # CnvIf(v401->Auf.P.Menge.Wunsch);
    cFertigGew6 # Rnd( cnvfi(cFertigStk6) * cFertigL6 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
    $cbKostentraeger.6->wpCheckState # _WinStateChkChecked;
  end;

  if (vKom7 <> '') then begin
    cKommi7 # vKom7;
    _getKommData(cKommi7, var v401, var v250);
    cKunde7       # v401->Auf.P.KundenSW;
    cArtikel7     # v401->Auf.P.Artikelnr;
    cFertigL7     # v401->"Auf.P.Länge";
    if (v401->Auf.P.MEH.Wunsch = 'Stk') then
      cFertigStk7 # CnvIf(v401->Auf.P.Menge.Wunsch);
    cFertigGew7 # Rnd( cnvfi(cFertigStk7) * cFertigL7 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
    $cbKostentraeger.7->wpCheckState # _WinStateChkChecked;
  end;

  RecBufDestroy(v401);
  RecBufDestroy(v250);
end;




//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  aMatNr  : int;
  opt aKommissionen : alpha) : logic;
local begin
  Erx : int;
end;
begin
  Erx # Mat_Data:Read(aMatNr);
  if (Erx<>200) then RETURN false;

  if (aKommissionen <> '') then
    _GetKommissionen(aKommissionen);

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
  SetStdAusFeld('edKommission.7'    ,'Kommi.7');
  SetStdAusFeld('edArtikelnr.1'     ,'Artikel.1');
  SetStdAusFeld('edArtikelnr.2'     ,'Artikel.2');
  SetStdAusFeld('edArtikelnr.3'     ,'Artikel.3');
  SetStdAusFeld('edArtikelnr.4'     ,'Artikel.4');
  SetStdAusFeld('edArtikelnr.5'     ,'Artikel.5');
  SetStdAusFeld('edArtikelnr.6'     ,'Artikel.6');
  SetStdAusFeld('edArtikelnr.7'     ,'Artikel.7');

  $edGew.1->wpDecimals # Set.Stellen.Gewicht;
  $edGew.2->wpDecimals # Set.Stellen.Gewicht;
  $edGew.3->wpDecimals # Set.Stellen.Gewicht;
  $edGew.4->wpDecimals # Set.Stellen.Gewicht;
  $edGew.5->wpDecimals # Set.Stellen.Gewicht;
  $edGew.6->wpDecimals # Set.Stellen.Gewicht;
  $edGew.7->wpDecimals # Set.Stellen.Gewicht;

  _SetKommissionen();

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
local begin
  Erx : int;
end;
begin
  case (aName) of
    'FertigL1' :
        if (cArtikel1<>'') then begin
          Art.Nummer # cArtikel1;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigL1 # Rnd( cFertigGew1 / Art.GewichtProm * 1000.0, "Set.Stellen.Länge");
          end;
        end;


    'FertigL2' :
        if (cArtikel2<>'') then begin
          Art.Nummer # cArtikel2;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigL2 # Rnd( cFertigGew2 / Art.GewichtProm * 1000.0, "Set.Stellen.Länge");
          end;
        end;


    'FertigL3' :
        if (cArtikel3<>'') then begin
          Art.Nummer # cArtikel3;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigL3 # Rnd( cFertigGew3 / Art.GewichtProm * 1000.0, "Set.Stellen.Länge");
          end;
        end;


    'FertigL4' :
        if (cArtikel4<>'') then begin
          Art.Nummer # cArtikel4;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigL4 # Rnd( cFertigGew4 / Art.GewichtProm * 1000.0, "Set.Stellen.Länge");
          end;
        end;


    'FertigL5' :
        if (cArtikel5<>'') then begin
          Art.Nummer # cArtikel5;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigL5 # Rnd( cFertigGew5 / Art.GewichtProm * 1000.0, "Set.Stellen.Länge");
          end;
        end;


    'FertigL6' :
        if (cArtikel6<>'') then begin
          Art.Nummer # cArtikel6;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigL6 # Rnd( cFertigGew6 / Art.GewichtProm * 1000.0, "Set.Stellen.Länge");
          end;
        end;


    'FertigL7' :
        if (cArtikel7<>'') then begin
          Art.Nummer # cArtikel7;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigL7 # Rnd( cFertigGew7 / Art.GewichtProm * 1000.0, "Set.Stellen.Länge");
          end;
        end;

  end;

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  Lib_GuiCom:Pflichtfeld($edStk.Einsatz);
  if (cKommi1<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.1);
    Lib_GuiCom:Pflichtfeld($edLaenge.1);
    Lib_GuiCom:Pflichtfeld($edGew.1);
  end;
  if (cKommi2<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.2);
    Lib_GuiCom:Pflichtfeld($edLaenge.2);
    Lib_GuiCom:Pflichtfeld($edGew.2);
  end;
  if (cKommi3<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.3);
    Lib_GuiCom:Pflichtfeld($edLaenge.3);
    Lib_GuiCom:Pflichtfeld($edGew.3);
  end;
  if (cKommi4<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.4);
    Lib_GuiCom:Pflichtfeld($edLaenge.4);
    Lib_GuiCom:Pflichtfeld($edGew.4);
  end;
  if (cKommi5<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.5);
    Lib_GuiCom:Pflichtfeld($edLaenge.5);
    Lib_GuiCom:Pflichtfeld($edGew.5);
  end;
  if (cKommi6<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.6);
    Lib_GuiCom:Pflichtfeld($edLaenge.6);
    Lib_GuiCom:Pflichtfeld($edGew.6);
  end;
  if (cKommi7<>'') then begin
    Lib_GuiCom:Pflichtfeld($edStk.7);
    Lib_GuiCom:Pflichtfeld($edLaenge.7);
    Lib_GuiCom:Pflichtfeld($edGew.7);
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

    'Kommi.7' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommi.7');
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

    'Artikel.7' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel.7');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//========================================================================
sub _RefreshFert(aNr : int);
local begin
  Erx     : int;
  vKomm   : int;
  vKunde  : int;
  vArt    : int;
  vL      : int;
  vKT     : int;
end;
begin

  vKomm   # Winsearch(gMDI, 'edKommission.'+aint(aNr));
  vArt    # Winsearch(gMDI, 'edArtikelnr.'+aint(aNr));
  vKunde  # Winsearch(gMDI, 'lbKunde.'+aint(aNr));
  vL      # Winsearch(gMDI, 'edLaenge.'+aint(aNr));
  vKT     # WinSearch(gMDI, 'cbKostentraeger.'+aint(aNr));

  if (Lib_Berechnungen:IntsAusAlpha(vKomm->wpCaption, var Auf.P.Nummer, var Auf.P.Position, var Auf.SL.lfdNr)) then
    Erx # Auf_Data:Read(Auf.P.Nummer, Auf.P.Position, true, Auf.SL.LfdNr)
  else
    Erx # 0;
  if (Erx=401) and (Auf.Vorgangstyp=c_Auf) then begin
    vKunde->wpCaption   # Auf.P.KundenSW;
    vArt->wpCaption     # Auf.P.Artikelnr;
    vL->wpCaptionFloat  # "Auf.P.Länge";
    vKT->wpCheckState   # _WinStateChkChecked;
    if (Auf.SL.LfdNr<>0) then begin
      vL->wpCaptionFloat # "Auf.SL.Länge";
    end;
    Art.Nummer # cArtikel1;
    Erx # RecRead(250,1,0);
    if (Erx<=_rLocked) then begin
      if (vL->wpCaptionFloat=0.0) then vL->wpCaptionFloat # "Art.Länge";
    end;
  end
  else begin
    vKT->wpCheckState   # _WinStateChkUnchecked;
    vKomm->wpCaption    # '';
    vKunde->wpCaption   # '';
    vArt->wpCaption     # '';
    vL->wpCaptionFloat  # 0.0;
  end;

end;


//========================================================================
// _RefreshArt
//========================================================================
sub _RefreshArt(aNr : int);
local begin
  Erx     : int;
  vArt    : int;
  vL      : int;
end;
begin
  vArt    # Winsearch(gMDI, 'edArtikelnr.'+aint(aNr));
  vL      # Winsearch(gMDI, 'edLaenge.'+aint(aNr));
  Art.Nummer # vArt->wpCaption;
  Erx # RecRead(250,1,0);
  if (Erx<=_rLocked) then begin
    vL->wpCaptionFloat # "Art.Länge";
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
      vA # anum(Mat.Breite, Set.Stellen.Breite);
    end;
    if ("Mat.Länge"<>0.0) then begin
      if (vA<>'') then vA # vA + ' x ';
      vA # anum("Mat.Länge", "Set.Stellen.Länge");
    end;
    cEinsatzAbm     # vA;
    cEinsatzUrStk   # aint(Mat.Bestand.Stk);
    cEinsatzUrGew   # anum(Mat.Bestand.Gew, Set.Stellen.Gewicht);
    if (Mat.MEH='m') then vMenge # Mat.Bestand.Menge
    else vMenge # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, 'm') , Set.Stellen.Menge);
    cEinsatzUrMe    # anum(vMenge, Set.Stellen.Menge);

    $edStk.Einsatz->wpMaxInt # Mat.Bestand.Stk;

  end;

  cEinsatzMe  # anum( rnd(Lib_Berechnungen:Dreisatz( cnvfa(cEinsatzUrMe), cnvfi(Mat.Bestand.Stk), cnvfi(cEinsatzStk)), Set.Stellen.Gewicht), Set.Stellen.Menge);
  cEinsatzGew # anum( rnd(Lib_Berechnungen:Dreisatz( cnvfa(cEinsatzUrGew), cnvfi(Mat.Bestand.Stk), cnvfi(cEinsatzStk)), Set.Stellen.Gewicht), Set.Stellen.Gewicht);;

  cEinsatzRestStk # aint(Mat.Bestand.Stk - cEinsatzStk);
  cEinsatzRestGew # anum(Mat.Bestand.Gew - cnvfa(cEinsatzGew), Set.Stellen.Gewicht);
  cEinsatzRestMe  # anum( cnvfa(cEinsatzUrMe) - cnvfa(cEinsatzMe), Set.Stellen.Menge);


  // Fertigung refreshen....
  if (aName='edKommission.1') and (($edKommission.1->wpchanged) or (aChanged)) then
    _RefreshFert(1);
  if (aName='edKommission.2') and (($edKommission.2->wpchanged) or (aChanged)) then
    _RefreshFert(2);
  if (aName='edKommission.3') and (($edKommission.3->wpchanged) or (aChanged)) then
    _RefreshFert(3);
  if (aName='edKommission.4') and (($edKommission.4->wpchanged) or (aChanged)) then
    _RefreshFert(4);
  if (aName='edKommission.5') and (($edKommission.5->wpchanged) or (aChanged)) then
    _RefreshFert(5);
  if (aName='edKommission.6') and (($edKommission.6->wpchanged) or (aChanged)) then
    _RefreshFert(6);
  if (aName='edKommission.7') and (($edKommission.7->wpchanged) or (aChanged)) then
    _RefreshFert(7);



  // Artikel refreshen...
  if (aName='edArtikelnr.1') and (($edArtikelnr.1->wpchanged) or (aChanged)) then
    _RefreshArt(1);
  if (aName='edArtikelnr.2') and (($edArtikelnr.2->wpchanged) or (aChanged)) then
    _RefreshArt(2);
  if (aName='edArtikelnr.3') and (($edArtikelnr.3->wpchanged) or (aChanged)) then
    _RefreshArt(3);
  if (aName='edArtikelnr.4') and (($edArtikelnr.4->wpchanged) or (aChanged)) then
    _RefreshArt(4);
  if (aName='edArtikelnr.5') and (($edArtikelnr.5->wpchanged) or (aChanged)) then
    _RefreshArt(5);
  if (aName='edArtikelnr.6') and (($edArtikelnr.6->wpchanged) or (aChanged)) then
    _RefreshArt(6);
  if (aName='edArtikelnr.7') and (($edArtikelnr.7->wpchanged) or (aChanged)) then
    _RefreshArt(7);

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
  if (aEvt:Obj->wpname='jump7') then begin
    vHdl # $cbKostentraeger.7;
    if (aFocusObject<>0) then begin
      if (aFocusObject->wpname='edKommission.7') and (cKommi7<>'') then vHdl # $edStk.7
      else if (aFocusObject->wpname='cbKostentraeger.7') then vHdl # $edKommission.7;
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
local begin
  Erx : int;
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  case (aEvt:Obj->wpname) of

    'edLaenge.1' : begin
//    'edStk.1' : begin
      if (cFertigGew1=0.0) then begin
        if (cArtikel1<>'') then begin
          Art.Nummer # cArtikel1;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew1 # Rnd( cnvfi(cFertigStk1) * cFertigL1 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;
    end;

    'edLaenge.2' : begin
//    'edStk.2' : begin
      if (cFertigGew2=0.0) then begin
        if (cArtikel2<>'') then begin
          Art.Nummer # cArtikel2;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew2 # Rnd( cnvfi(cFertigStk2) * cFertigL2 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;
    end;

    'edLaenge.3' : begin
//    'edStk.3' : begin
      if (cFertigGew3=0.0) then begin
        if (cArtikel3<>'') then begin
          Art.Nummer # cArtikel3;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew3 # Rnd( cnvfi(cFertigStk3) * cFertigL3 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;
    end;

    'edLaenge.4' : begin
      if (cFertigGew4=0.0) then begin
        if (cArtikel4<>'') then begin
          Art.Nummer # cArtikel4;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew4 # Rnd( cnvfi(cFertigStk4) * cFertigL4 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;
    end;

    'edLaenge.5' : begin
      if (cFertigGew5=0.0) then begin
        if (cArtikel5<>'') then begin
          Art.Nummer # cArtikel5;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew5 # Rnd( cnvfi(cFertigStk5) * cFertigL5 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;
    end;

    'edLaenge.6' : begin
      if (cFertigGew6=0.0) then begin
        if (cArtikel6<>'') then begin
          Art.Nummer # cArtikel6;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew6 # Rnd( cnvfi(cFertigStk6) * cFertigL6 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;
    end;

    'edLaenge.7' : begin
      if (cFertigGew7=0.0) then begin
        if (cArtikel7<>'') then begin
          Art.Nummer # cArtikel7;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew7 # Rnd( cnvfi(cFertigStk7) * cFertigL7 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;
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
  Erx   : int;
  vHdl  : handle;
  vHdl2 : handle;
  vA    : alpha;
end;
begin

  if (aMenuItem->wpName='Mnu.Ktx.Errechnen') then begin

    case (aEvt:Obj->wpname) of

      'edLaenge.1' :
        Calc('FertigL1');


      'edLaenge.2' :
        Calc('FertigL2');


      'edLaenge.3' :
        Calc('FertigL3');


      'edLaenge.4' :
        Calc('FertigL4');


      'edLaenge.5' :
        Calc('FertigL5');


      'edLaenge.6' :
        Calc('FertigL6');


      'edLaenge.7' :
        Calc('FertigL7');


      'edGew.1' : begin
        if (cArtikel1<>'') then begin
          Art.Nummer # cArtikel1;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew1 # Rnd( cnvfi(cFertigStk1) * cFertigL1 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;  // Gewicht1


      'edGew.2' : begin
        if (cArtikel2<>'') then begin
          Art.Nummer # cArtikel2;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew2 # Rnd( cnvfi(cFertigStk2) * cFertigL2 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;  // Gewicht2


      'edGew.3' : begin
        if (cArtikel3<>'') then begin
          Art.Nummer # cArtikel3;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew3 # Rnd( cnvfi(cFertigStk3) * cFertigL3 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;  // Gewicht3


      'edGew.4' : begin
        if (cArtikel4<>'') then begin
          Art.Nummer # cArtikel4;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew4 # Rnd( cnvfi(cFertigStk4) * cFertigL4 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;  // Gewicht

      'edGew.5' : begin
        if (cArtikel5<>'') then begin
          Art.Nummer # cArtikel5;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew5 # Rnd( cnvfi(cFertigStk5) * cFertigL5 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;  // Gewicht

      'edGew.6' : begin
        if (cArtikel6<>'') then begin
          Art.Nummer # cArtikel6;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew6 # Rnd( cnvfi(cFertigStk6) * cFertigL6 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;  // Gewicht

      'edGew.7' : begin
        if (cArtikel4<>'') then begin
          Art.Nummer # cArtikel7;
          Erx # RecRead(250,1,0);     // Artikel holen
          if (Erx<=_rLocked) then begin
            cFertigGew7 # Rnd( cnvfi(cFertigStk7) * cFertigL7 * Art.GewichtProm / 1000.0, Set.Stellen.Gewicht);
          end;
        end;
      end;  // Gewicht

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
    'btKommission.7'    : Auswahl('Kommi.7');
    'btArtikelnr.1'     : Auswahl('Artikel.1');
    'btArtikelnr.2'     : Auswahl('Artikel.2');
    'btArtikelnr.3'     : Auswahl('Artikel.3');
    'btArtikelnr.4'     : Auswahl('Artikel.4');
    'btArtikelnr.5'     : Auswahl('Artikel.5');
    'btArtikelnr.6'     : Auswahl('Artikel.6');
    'btArtikelnr.7'     : Auswahl('Artikel.7');
  end;
end;


//========================================================================
//
//========================================================================
Sub _AusKommi(aNr : int);
local begin
  vKomm   : int;
  vHdl    : int;
end;
begin
  if (gSelected=0) then RETURN

  vKomm   # Winsearch(gMDI, 'edKommission.'+aint(aNr));

  RecRead(401,0,_RecId,gSelected);
  gSelected # 0;
  vKomm->wpcaption # aint(auf.p.nummer)+'/'+aint(auf.p.position);

  // mit Stückliste?
  if (RecLinkInfo(409,401,15,_RecCount)>0) then begin
    RecBufClear(409);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.SL.Verwaltung',here+':AusKommiSL.'+aint(aNr));
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;
  end;

  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.'+aint(aNr), true);
end;


//========================================================================
//========================================================================
Sub _AusKommiSL(aNr : int);
local begin
  vKomm   : int;
  vHdl    : int;
end;
begin
  if (gSelected=0) then RETURN

  vKomm   # Winsearch(gMDI, 'edKommission.'+aint(aNr));

  RecRead(409,0,_RecId,gSelected);
  gSelected # 0;
  vKomm->wpCaption # aint(auf.SL.nummer)+'/'+aint(auf.SL.position)+'/'+aint(Auf.SL.lfdNr);
  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edKommission.'+aint(aNr), true);
end;


//========================================================================
//========================================================================
Sub _AusArt(aNr : int);
local begin
  vArt    : int;
  vHdl    : int;
end;
begin
  if (gSelected=0) then RETURN

  vArt    # Winsearch(gMDI, 'edArtikelnr.'+aint(aNr));

  RecRead(250,0,_RecId,gSelected);
  gSelected # 0;
  vArt->wpCaption # Art.Nummer;
  vHdl # WinFocusget();   // LastFocus-Feld refreshen
  if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  RefreshIfm('edArtikelnr.'+aint(aNr), true);

end;


//========================================================================
//  AusKommi.1
//========================================================================
sub AusKommi.1()
begin
  _AusKommi(1);
end;
//========================================================================
//  AusKommi.2
//========================================================================
sub AusKommi.2()
begin
  _AusKommi(2);
end;
//========================================================================
//  AusKommi.3
//========================================================================
sub AusKommi.3()
begin
  _AusKommi(3);
end;
//========================================================================
//  AusKommi.4
//========================================================================
sub AusKommi.4()
begin
  _AusKommi(4);
end;
//========================================================================
//  AusKommi.5
//========================================================================
sub AusKommi.5()
begin
  _AusKommi(5);
end;
//========================================================================
//  AusKommi.6
//========================================================================
sub AusKommi.6()
begin
  _AusKommi(6);
end;
//========================================================================
//  AusKommi.7
//========================================================================
sub AusKommi.7()
begin
  _AusKommi(7);
end;


//========================================================================
// AusKommiSL.1
//========================================================================
sub AusKommiSL.1()
begin
  _AusKommiSL(1);
end;
//========================================================================
// AusKommiSL.2
//========================================================================
sub AusKommiSL.2()
begin
  _AusKommiSL(2);
end;
//========================================================================
// AusKommiSL.3
//========================================================================
sub AusKommiSL.3()
begin
  _AusKommiSL(3);
end;
//========================================================================
// AusKommiSL.4
//========================================================================
sub AusKommiSL.4()
begin
  _AusKommiSL(4);
end;
//========================================================================
// AusKommiSL.5
//========================================================================
sub AusKommiSL.5()
begin
  _AusKommiSL(5);
end;
//========================================================================
// AusKommiSL.6
//========================================================================
sub AusKommiSL.6()
begin
  _AusKommiSL(6);
end;
//========================================================================
// AusKommiSL.7
//========================================================================
sub AusKommiSL.7()
begin
  _AusKommiSL(7);
end;


//========================================================================
//  AusArtikel.1
//========================================================================
sub AusArtikel.1()
begin
  _AusArt(1);
end;
//========================================================================
//  AusArtikel.2
//========================================================================
sub AusArtikel.2()
begin
  _AusArt(2);
end;
//========================================================================
//  AusArtikel.3
//========================================================================
sub AusArtikel.3()
begin
  _AusArt(3);
end;
//========================================================================
//  AusArtikel.4
//========================================================================
sub AusArtikel.4()
begin
  _AusArt(4);
end;
//========================================================================
//  AusArtikel.5
//========================================================================
sub AusArtikel.5()
begin
  _AusArt(5);
end;
//========================================================================
//  AusArtikel.6
//========================================================================
sub AusArtikel.6()
begin
  _AusArt(6);
end;
//========================================================================
//  AusArtikel.7
//========================================================================
sub AusArtikel.7()
begin
  _AusArt(7);
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
  vK5, vK6, vK7       : alpha;
end;
begin
    // logische Prüfung
  if (Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() = false) then
    RETURN false;

  If (cEinsatzStk=0) then begin
    Msg(001200,Translate('Stückzahl'),0,0,0);
    $edStk.Einsatz->winfocusset(true);
    RETURN false;
  end;
  if (cEinsatzStk>cnvia(cEinsatzurStk)) then begin
    Msg(001201,Translate('Stückzahl'),0,0,0);
    $edStk.Einsatz->winfocusset(true);
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
  vK5 # cKommi5;
  if (vK5='') and (cKosten5) then vK5 # 'KOSTEN';
  vK6 # cKommi6;
  if (vK6='') and (cKosten6) then vK6 # 'KOSTEN';
  vK7 # cKommi7;
  if (vK7='') and (cKosten7) then vK7 # 'KOSTEN';


  vOK # BA1_Qck_Saegen_Data:Verbuchen(cnvia(cEinsatzMat), cEinsatzStk, cnvfa(cEinsatzGew),
                                            vK1, cArtikel1, cFertigStk1, cFertigL1, cFertigGew1, cBem1,
                                            vK2, cArtikel2, cFertigStk2, cFertigL2, cFertigGew2, cBem2,
                                            vK3, cArtikel3, cFertigStk3, cFertigL3, cFertigGew3, cBem3,
                                            vK4, cArtikel4, cFertigStk4, cFertigL4, cFertigGew4, cBem4,
                                            vK5, cArtikel5, cFertigStk5, cFertigL5, cFertigGew5, cBem5,
                                            vK6, cArtikel6, cFertigStk6, cFertigL6, cFertigGew6, cBem6,
                                            vK7, cArtikel7, cFertigStk7, cFertigL7, cFertigGew7, cBem7,
                                            true);
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