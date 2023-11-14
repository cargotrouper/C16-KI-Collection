@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_F_Abcoil_Main
//                    OHNE E_R_G
//  Info
//
//
//  21.01.2008  AI  Erstellung der Prozedur
//  03.06.2009  TM  Gütenstufen eingefügt
//  10.07.2017  AH  RecalcRest buffert 701
//  28.07.2017  AH  Einsatz "BAG.IO.Länge" wird für Anzeige ggf. errechnet
//  09.08.2017  ST  "RecSave" ruft allgemeine REcSave auf
//  03.04.2019  ST  Bugfix: REfreshIfm-<ReccalrRest: Einsatzmengen werden nach aktualisierung wieder in Puffer geschrieben
//  05.04.2022  AH  ERX
//  19.07.2022  HA  Quick Jump
//  2022-12-22  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusKunde()
//    SUB AusKundenArtNr()
//    SUB AusKundenArtNr2()
//    SUB AusKommission()
//    SUB AusWgr()
//    SUB AusArtikel()
//    SUB AusStruktur()
//    SUB AusVerpackung()
//    SUB AusGuete()
//    SUB AusGuetenstufe()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB RecalcRest(varaBB : float; varaBL : float; varaBGew : float; varaBM : float; varaL : float; varaGew : float; varaM : float; aMitRest : logic);
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cDialog :   $BA1.F.Abcoil.Maske
  cTitle :    'Abcoilfertigung'
  cFile :     703
  cMenuName : 'BA1.F.Bearbeiten'
  cPrefix :   'BA1_F_Abcoil'
//  cZList :    0
  cKey :      1

//  cZList1 :   $RL.BA1.Pos
//  cZList2 :   $RL.BA1.Input
//  cZList3 :   $RL.BA1.Fertigung
end;

declare RefreshIfm(opt aName : alpha; opt aChanged : logic)
declare RecalcRest(var aBB : float;var aBL : float;var aBGew : float;var aBM : float;var aL : float;var aGew : float;var aM : float; aMitRest : logic);


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
//  gZLList   # 0;//cZList;
  gKey      # cKey;

  // Lohn-BA?
  if (BAG.P.Kommission<>'') then
    $cbBAG.F.WirdEigenYN->wpvisible # true;

  Lib_Guicom2:Underline($edBAG.F.Kommission);
  Lib_Guicom2:Underline($edBAG.F.Warengruppe);
  Lib_Guicom2:Underline($edBAG.F.Guetenstufe);
  Lib_Guicom2:Underline($edBAG.F.Guete);
  Lib_Guicom2:Underline($edBAG.F.Artikelnummer);
  Lib_Guicom2:Underline($edBAG.F.ReservFuerKunde);
  Lib_Guicom2:Underline($edBAG.F.KundenArtNr);
  Lib_Guicom2:Underline($edBAG.F.Verpackung);


  SetStdAusFeld('edBAG.F.Kommission'      ,'Kommission');
  SetStdAusFeld('edBAG.F.KundenArtNr'     ,'Kundenartnr');
  SetStdAusFeld('edBAG.F.ReservFuerKunde' ,'Kunde');
  SetStdAusFeld('edBAG.F.Warengruppe'     ,'Wgr');
//  SetStdAusFeld('edBAG.F.Artikelnummer'   ,'Struktur');
  SetStdAusFeld('edBAG.F.Verpackung'      ,'Verpackung');
  SetStdAusFeld('edBAG.F.Guete'           ,'Guete');
  SetStdAusFeld('edBAG.F.Guetenstufe'     ,'Guetenstufe');
  SetStdAusFeld('edBAG.F.AusfOben'        ,'AF.Oben');
  SetStdAusFeld('edBAG.F.AusfUnten'       ,'AF.Unten');

  $edQM->wpDecimals # Set.Stellen.Menge;

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edBAG.F.Warengruppe);
  Lib_GuiCom:Pflichtfeld($edBAG.F.Laenge);
  if (BAG.F.ReservierenYN) then
    Lib_GuiCom:Pflichtfeld($edBAG.F.ReservFuerKunde);
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
  Erx   : int;
  vA    : alpha;
  vX    : float;
  vI    : int;
  vBuf  : int;

  vBB   : float;
  vBL   : float;
  vBGew : float;
  vBM   : float;
  vL    : float;
  vGew  : float;
  vM    : float;
  vOk   : logic;
  vTmp  : int;
  vInputL : float;
  vQM   : float;
  vInQM : float;
end;
begin

  // 2022-12-21 AH
  if (aName='edBAG.F.Artikelnummer') then begin
    Erx # RekLink(819,703,5,_recFirst);   // Warengruppe holen
    if (Wgr_Data:IstMix()) then begin
      Erx # RecLink(250,703,13,_recFirst);    // Artikel holen
      if (erx<=_rLocked) then begin
        BAG.F.MEH             # Art.MEH;
        BA1_F_Data:ErrechnePlanmengen(y,y,y);
      end;
    end;
  end;
  vQM # Lib_Einheiten:WandleMEH(703, "BAG.F.Stückzahl" , BAG.F.Gewicht, BAG.F.Menge, BAG.F.MEH, 'qm');
  $edQM->wpcaptionfloat # vQM;

  if (aName='edBAG.F.Dickentol') then begin
    BAG.F.Dickentol # Lib_Berechnungen:Toleranzkorrektur("BAG.F.dickentol",Set.Stellen.Dicke);
  end;

  if (aName='edBAG.F.Breitentol') then begin
    BAG.F.Breitentol # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Breitentol",Set.Stellen.Breite);
  end;

  if (aName='edBAG.F.Laengentol') then begin
    "BAG.F.Längentol" # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Längentol","Set.Stellen.Länge");
  end;

  // Vorgabenüberprüfung [22.09.2009/PW]
  if ( aName = 'edBAG.F.Dicke' or aName = 'edBAG.F.Breite' or aName = 'edBAG.F.Laenge' or
        aName = 'edBAG.F.Dickentol' or aName = 'edBAG.F.Breitentol' or aName = 'edBAG.F.Laengentol' or
        aName = 'edBAG.F.AusfOben' or aName = 'edBAG.F.AusfUnten') then begin
    vTmp # gMdi->winSearch( aName );
    if ( vTmp != 0 ) then begin
      case ( aName ) of
        'edBAG.F.Dicke'      : vOk # ( $Lb.Dicke.A->wpCaption != '' ) and ( vTmp->wpCaptionFloat != 0.0 ) and ( $Lb.Dicke.A->wpCaption != ANum( vTmp->wpCaptionFloat, "Set.Stellen.Dicke" ) );
        'edBAG.F.Breite'     : vOk # ( $Lb.Breite.A->wpCaption != '' ) and ( vTmp->wpCaptionFloat != 0.0 ) and ( $Lb.Breite.A->wpCaption != ANum( vTmp->wpCaptionFloat, "Set.Stellen.Breite" ) );
        'edBAG.F.Laenge'     : vOk # ( $Lb.Laenge.A->wpCaption != '' ) and ( vTmp->wpCaptionFloat != 0.0 ) and ( $Lb.Laenge.A->wpCaption != ANum( vTmp->wpCaptionFloat, "Set.Stellen.Länge" ) );
        'edBAG.F.Dickentol'  : vOk # ( $Lb.Dickentol.A->wpCaption != '' ) and ( vTmp->wpCaption != '' ) and ( $Lb.Dickentol.A->wpCaption  != vTmp->wpCaption );
        'edBAG.F.Breitentol' : vOk # ( $Lb.Breitentol.A->wpCaption != '' ) and ( vTmp->wpCaption != '' ) and ( $Lb.Breitentol.A->wpCaption != vTmp->wpCaption );
        'edBAG.F.Laengentol' : vOk # ( $Lb.Laengentol.A->wpCaption != '' ) and ( vTmp->wpCaption != '' ) and ( $Lb.Laengentol.A->wpCaption != vTmp->wpCaption );
        'edBAG.F.AusfOben'   : vOk # ( $Lb.AusfOben.A->wpCaption != '' ) and ( vTmp->wpCaption != '' ) and ( $Lb.AusfOben.A->wpCaption   != vTmp->wpCaption );
        'edBAG.F.AusfUnten'  : vOk # ( $Lb.AusfUnten.A->wpCaption != '' ) and ( vTmp->wpCaption != '' ) and ( $Lb.AusfUnten.A->wpCaption  != vTmp->wpCaption );
      end;
      if ( vOk ) then vTmp->wpColBkg # _winColLightRed;
      else            vTmp->wpColBkg # _winColWhite;
    end;
  end;

  if (aName='') or (y) then begin

    RecalcRest(var vBB,var vBL,var vBGew,var vBM,var vL,var vGew,var vM, true);
    if (BAG.F.AutomatischYN) then begin
      vBGew # 0.0;
      vBM   # 0.0;
    end;
    if (BAG.IO.MEH.Out='qm') then
      vInQM # BAG.IO.Plan.Out.Meng
    else
      vInQM # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.Out.GewN, BAG.io.plan.out.Meng, BAG.io.MEH.out, 'qm');


    // Einsatz anzeigen
    $Lb.Guete.E->wpcaption      # "BAG.IO.Güte";
    $Lb.GuetenStufe.E->wpcaption # "BAG.IO.GütenStufe";
    $Lb.AusfOben.E->wpcaption   # BAG.IO.AusfOben;
    $Lb.AusfUnten.E->wpcaption  # BAG.IO.AusfUnten;
    $Lb.Artikel.E->wpcaption    # BAG.IO.Artikelnr;
    $Lb.Dicke.E->wpcaption      # ANum(BAG.IO.Dicke, "Set.Stellen.Dicke");
    $Lb.Breite.E->wpcaption     # ANum(BAG.IO.Breite, "Set.Stellen.Breite");
    if (Abs("BAG.IO.Länge")>9999.99) then begin
      $lb.LenMEH_E->wpcaption    # 'm';
      $Lb.Laenge.E->wpcaption   # ANum("BAG.IO.Länge"/1000.0,"Set.Stellen.Länge");
      end
    else begin
      $lb.LenMEH_E->wpcaption    # 'mm';
      $Lb.Laenge.E->wpcaption   # ANum("BAG.IO.Länge","Set.Stellen.Länge");
    end;
    $Lb.Dickentol.E->wpcaption  # BAG.IO.Dickentol;
    $Lb.Breitentol.E->wpcaption # BAG.IO.Breitentol;
    $Lb.Laengentol.E->wpcaption # "BAG.IO.Längentol";
    $Lb.Stueck.E->wpcaption     # AInt(BAG.IO.Plan.Out.Stk);
    $Lb.Gewicht.E->wpcaption    # ANum(BAG.IO.Plan.Out.GewN,"Set.Stellen.Gewicht");
    $Lb.QM.E->wpcaption         # ANum(vInQM,"Set.Stellen.Menge");


    // Reste anzeigen
    // Maximalwerte errechnen
//    RecLink(819,701,7,_recFirst);   // Warengruppe holen
    Erx # RecLink(819,703,5,_Recfirst);   // Warengruppe holen
    if (Erx>_rLocked) then RecBufClear(819);

    // max.Stück errechnen...
    vInputL # "BAG.IO.Länge";
    if (vInputL=0.0) then begin    // 28.07.2017 AH
      vInputL # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, 1, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM");
    end;
    vX # vInputL - vL + vBL;
    if ("BAG.F.Länge"<>0.0) then
      vI # cnvif(Trn(vX / "BAG.F.Länge"))
    else
      vI # 0;
    $lb.Stueck.max->wpcaption     # AInt(vI);

    // max.Gewicht errechen...
    vX # Lib_Berechnungen:kg_aus_StkDBLDichte2(vI, BAG.IO.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 703), "Wgr.TränenKgProQM");
    $lb.Gewicht.max->wpcaption    # ANum(vX,Set.Stellen.Gewicht);

    vX # BAG.F.Breite * Cnvfi(vI) * "BAG.F.Länge" / 1000000.0;
    $lb.QM.max->wpcaption    # ANum(vX,Set.Stellen.Menge);

    if (Abs(vInputL-vL)>9999.99) then begin
      $lb.LenMEH_R->wpcaption   # 'm';
      $Lb.Laenge.R->wpcaption   # ANum((vInputL-vL)/1000.0,"Set.Stellen.Länge");
      end
    else begin
      $lb.LenMEH_R->wpcaption   # 'mm';
      $Lb.Laenge.R->wpcaption   # ANum(vInputL-vL,"Set.Stellen.Länge");
    end;
    $Lb.Gewicht.R->wpcaption    # ANum(BAG.IO.Plan.Out.GewN - vGew,"Set.Stellen.Gewicht");
    $Lb.QM.R->wpcaption      # ANum(vInQM - vQM,"Set.Stellen.Menge");
    if (vInputL-vL<0.0) then $lb.Laenge.R->wpColBkg # _WinColLightRed
    else $lb.Laenge.R->wpColBkg # _WinColParent;
    if (BAG.IO.PLan.Out.GewN - vGew<0.0) then $lb.Gewicht.R->wpColBkg # _WinColLightRed
    else $lb.Gewicht.R->wpColBkg # _WinColParent;
    if (vInQM-vQM<0.0) then $lb.QM.R->wpColBkg # _WinColLightRed
    else $lb.QM.R->wpColBkg # _WinColParent;


    // Etikettierung
    $Lb2.Guete.F->wpcaption      # "BAG.F.Güte";
    $Lb2.Dicke.F->wpcaption      # cnvaf(BAG.F.Dicke,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Dicke);
    $Lb2.Breite.F->wpcaption     # cnvaf(BAG.F.Breite,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Breite);
    $Lb2.Laenge.F->wpcaption     # cnvaf("BAG.F.Länge",_FmtNumNoGroup|_FmtNumNoZero,0,"Set.Stellen.Länge");
    $Lb2.Dickentol.F->wpcaption  # BAG.F.Dickentol;
    $Lb2.Breitentol.F->wpcaption # BAG.F.Breitentol;
    $Lb2.Laengentol.F->wpcaption # "BAG.F.Längentol";
    $Lb2.Guete.A->wpcaption      # $lb.Guete.A->wpcaption;;
    $Lb2.Dicke.A->wpcaption      # $lb.Dicke.A->wpcaption;
    $Lb2.Breite.A->wpcaption     # $lb.Breite.A->wpcaption;
    $Lb2.Laenge.A->wpcaption     # $lb.Laenge.A->wpcaption;
    $Lb2.Dickentol.A->wpcaption  # $lb.Dickentol.A->wpcaption;
    $Lb2.Breitentol.A->wpcaption # $lb.Breitentol.A->wpcaption;
    $Lb2.Laengentol.A->wpcaption # $lb.Laengentol.A->wpcaption;
    $Lb2.Guete.E->wpcaption      # $lb.Guete.E->wpcaption;;
    $Lb2.Dicke.E->wpcaption      # $lb.Dicke.E->wpcaption;
    $Lb2.Breite.E->wpcaption     # $lb.Breite.E->wpcaption;
    $Lb2.Laenge.E->wpcaption     # $lb.Laenge.E->wpcaption;
    $Lb2.Dickentol.E->wpcaption  # $lb.Dickentol.E->wpcaption;
    $Lb2.Breitentol.E->wpcaption # $lb.Breitentol.E->wpcaption;
    $Lb2.Laengentol.E->wpcaption # $lb.Laengentol.E->wpcaption;
  end;


  if ((aName='edBAG.F.Kommission') and (($edBAG.F.Kommission->wpchanged) or (aChanged))) then begin
    // Kommission angegeben?
        BA1_F_Data:AusKommission(0 ,0, 0);
        BA1_F_Main:RefreshIfm(); // ETK Daten übernehmeb
        Refreshifm('edBAG.F.ReservFuerKunde');
        Refreshifm('edBAG.F.Warengruppe');
        Refreshifm('edBAG.F.Verpackung');
  end;

  if (aName='') or (aName='edBAG.F.Kommission') then begin
    $Lb.Guete.A->wpcaption      # '';
    $Lb.GuetenStufe.A->wpcaption      # '';
    $Lb.AusfOben.A->wpcaption   # '';
    $Lb.AusfUnten.A->wpcaption  # '';
    $Lb.Artikel.A->wpcaption    # '';
    $Lb.Dicke.A->wpcaption      # '';
    $Lb.Breite.A->wpcaption     # '';
    $Lb.Laenge.A->wpcaption     # '';
    $Lb.Stueck.A->wpcaption     # '';
    $Lb.Gewicht.A->wpcaption    # '';
    $Lb.QM.A->wpcaption      # '';
    $Lb.Dickentol.A->wpcaption  # '';
    $Lb.Breitentol.A->wpcaption # '';
    $Lb.Laengentol.A->wpcaption # '';
    if (BAG.F.AuftragsNummer<>0) then begin
      Erx # Auf_Data:Read(BAG.F.Auftragsnummer, BAG.F.AuftragsPos, y);
      $Lb.Guete.A->wpcaption      # "Auf.P.Güte";
      $Lb.GuetenStufe.A->wpcaption      # "Auf.P.GütenStufe";
      $Lb.AusfOben.A->wpcaption   # Auf.P.AusfOben;
      $Lb.AusfUnten.A->wpcaption  # Auf.P.AusfUnten;
      $Lb.Artikel.A->wpcaption    # Auf.P.Artikelnr;
      $Lb.Dickentol.A->wpcaption  # Auf.P.Dickentol;
      $Lb.Breitentol.A->wpcaption # Auf.P.Breitentol;
      $Lb.Laengentol.A->wpcaption # "Auf.P.Längentol";
      if (Auf.P.Dicke<>0.0) then
        $Lb.Dicke.A->wpcaption      # ANum(Auf.P.Dicke,"Set.Stellen.Dicke");
      if (Auf.P.Breite<>0.0) then
        $Lb.Breite.A->wpcaption     # ANum(Auf.P.Breite,"Set.Stellen.Breite");
      if ("Auf.P.Länge"<>0.0) then
        $Lb.Laenge.A->wpcaption     # ANum("Auf.P.Länge","Set.Stellen.Länge");
      if ("Auf.P.Stückzahl"-Auf.P.Prd.PLan.Stk>0) then
        $Lb.Stueck.A->wpcaption     # AInt("Auf.P.Stückzahl"-Auf.P.Prd.PLan.Stk);
      if (Auf.P.Gewicht-Auf.P.Prd.Plan.Gew>0.0) then
        $Lb.Gewicht.A->wpcaption    # ANum(Auf.P.Gewicht-Auf.P.Prd.Plan.Gew,"Set.Stellen.Gewicht");

      if ("Auf.P.Stückzahl"-Auf.P.Prd.Plan.Stk>0) then begin
        $Lb.QM.A->wpcaption    # ANum(Auf.P.Breite * "Auf.P.Länge" / 1000000.0 * Cnvfi(("Auf.P.Stückzahl"-Auf.P.Prd.Plan.Stk)) ,2);
      end
      else begin
        $lb.QM.A->wpcaption    # '0,00';
      end;
    end;
  end;


  if (aName='edBAG.F.Guete') and ($edBAG.F.Guete->wpchanged) then begin
    MQu_Data:Autokorrektur(var "BAG.F.Güte");
    $edBAG.F.Guete->Winupdate();
  end;

  if (aName='edBAG.F.GuetenStufe') and ($edBAG.F.GuetenStufe->wpchanged) then begin
    MQu_Data:Autokorrektur(var "BAG.F.GütenStufe");
    $edBAG.F.GuetenStufe->Winupdate();
  end;

  if (aName='') or (aName='edBAG.F.Warengruppe') then begin
    Erx # RecLink(819,703,5,0);
    if (Erx<=_rLocked) then
      $Lb.Wgr->wpcaption # Wgr.Bezeichnung.L1
    else
      $Lb.Wgr->wpcaption # '';

    if (Wgr_Data:IstMix()) then
      $lbBAG.F.Artikelnummer->wpcaption # Translate('Artikelnr.')
    else
      $lbBAG.F.Artikelnummer->wpcaption # Translate('Strukturnr.');
  end;

  if (aName='') or (aName='edBAG.F.ReservFuerKunde') then begin
    Erx # _rOK;
    if ("BAG.F.ReservFürKunde"<>0) then
      Erx # RecLink(100,703,7,0);
    else
      RecBufClear(100);
    if (Erx<=_rLocked) then
      $Lb.Kunde->wpcaption # Adr.Stichwort
    else
      $Lb.Kunde->wpcaption # '';
  end;

  if (aName='') or (aName='edBAG.F.Verpackung') then begin
    Erx # RecLink(704,703,6,0);
    if (Erx<=_rLocked) then
      $Lb.Verpackung->wpcaption # BAG.Vpg.VpgText1
    else
      $Lb.Verpackung->wpcaption # '';

    // ETK Felder Aktuallisieren
    BA1_F_Main:RefreshIfm('edBAG.F.Verpackung');

  end;


  if (BAG.F.Fertigung=999) then begin
//    if(BAG.F.Kommission = '') then
//      BAG.F.Kommission  # Translate('RESTCOIL');
    "BAG.F.Länge"     # 0.0;
  end;

  BA1_F_Data:CheckFertigung2Einsatz(); // MS 02.02.2010

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
sub RecInit()
local begin
  Erx   : int;
  vA    : alpha;
  vTmp  : int;
end;
begin
  // je nach Aktion Felder freischalten
  if (mode=c_ModeEdit) and (BAG.F.AutomatischYN) then begin
    Lib_GuiCom:Disable($cbBAG.F.PlanSchrottYN);
    Lib_GuiCom:Disable($edBAG.F.Guetenstufe);
    Lib_GuiCom:Disable($bt.Guetenstufe);
    Lib_GuiCom:Disable($edBAG.F.Guete);
    Lib_GuiCom:Disable($bt.Guete);
    Lib_GuiCom:Disable($edBAG.F.AusfOben);
    Lib_GuiCom:Disable($bt.AusfOben);
    Lib_GuiCom:Disable($edBAG.F.AusfUnten);
    Lib_GuiCom:Disable($bt.AusfUnten);
    /*  28.08.2012 MS laut Prj. 1334/144
    Lib_GuiCom:Disable($edBAG.F.Artikelnummer);
    Lib_GuiCom:Disable($bt.Artikel);
    */
    Lib_GuiCom:Disable($edBAG.F.Dicke);
    Lib_GuiCom:Disable($edBAG.F.Dickentol);
    Lib_GuiCom:Disable($edBAG.F.Breite);
    Lib_GuiCom:Disable($edBAG.F.Breitentol);
    Lib_GuiCom:Disable($edBAG.F.Laenge);
    Lib_GuiCom:Disable($edBAG.F.Laengentol);
    Lib_GuiCom:Disable($edBAG.F.Stueckzahl);
    Lib_GuiCom:Disable($edBAG.F.Gewicht);
    Lib_GuiCom:Disable($edBAG.F.Menge);
  end;

  // je nach Aktion Felder freischalten

  if (Mode=c_ModeNew) then begin
    // letzen Block finden
    Erx # RecLink(703,702,4,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (BAG.F.Block>vA) then vA # BAG.F.Block;
      Erx # RecLink(703,702,4,_recNext);
    END;

    RecBufClear(703);
    BAG.F.Nummer    # BAG.P.Nummer;
    BAG.F.Position  # BAG.P.Position;

    if ( w_AppendNr != 0 ) then begin
      BAG.F.Fertigung # w_AppendNr;
      RecRead( 703, 1, 0 );
      w_AppendNr # 0;
    end
    else begin
      BAG.F.Warengruppe     # BAG.IO.Warengruppe;
      BAG.F.MEH             # 'qm';
      "BAG.F.Güte"          # "BAG.IO.Güte";
      BAG.F.Streifenanzahl  # 1;
      BAG.F.Breite            # BAG.IO.Breite;
      "BAG.F.KostenträgerYN"  # Set.BA.F.KostenTrgYN;
      Erx # RecLink(828,702,8,_RecFirst);   // Arbeitsgang holen
      if (Erx<=_rLocked) and (ArG.BAG.Warengruppe<>0) then
        BAG.F.Warengruppe     # ArG.BAG.Warengruppe;
    end;
    if (vA='') then
      BAG.F.Block         # 'A'
    else
      BAG.F.Block           # StrChar( StrToChar(vA,1)+1);

    BA1_F_Data:SetRidRad('Init');

    // allgem. Fertigung?
    BAG.F.Fertigung # 1;
    WHILE (RecRead(703,1,_RecTest)<=_rLocked) do
      BAG.F.Fertigung # BAG.F.Fertigung + 1;
  end;

  // Ankerfunktion?
  RunAFX('BAG.F.RecInit','');

  // Focus setzen auf Feld:
  vTmp # gMdi->winsearch('edBAG.F.Kommission');
  vTmp->WinFocusSet(true);
  w_LastFocus # vTmp;
  Erx # gMdi->winsearch('DUMMYNEW');
  Erx->wpcustom # AInt(vTmp);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vBuf703 : int;
  vTmp    : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  vTmp # gMdi->Winsearch('NB.Main');

  // logische Prüfungen...

  // ST 09-08-2017: Wird in der Zentralen RecSave erledigt
  /*
  if (BAG.F.Kommission <> '') then begin
    Erx # RecLinkInfo(401, 703, 9, _recCount);
    if(Erx = 0) then begin
      Msg(001201,BAG.F.Kommission  + ' ' + Translate('Kommission'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      $edBAG.F.Kommission->WinFocusSet(true);
      RETURN false;
    end;
  end;
*/
  Erx # RecLink(819,703,5,_recFirst);   // Warengruppe holen
  if (Erx>_rLocked) then begin
    Msg(001201,Translate('Warengruppe'),0,0,0);
    vTmp->wpcurrent # 'NB.Page1';
    $edBAG.F.Warengruppe->WinFocusSet(true);
    RETURN false;
  end;
  if (Wgr_Data:IstMix()) and (BAG.F.Artikelnummer='') and (BAG.VorlageYN=n) then begin
//    Msg(001200,Translate('Artikelnummer'),0,0,0);
//    vTmp->wpcurrent # 'NB.Page1';
//    $edBAG.F.Artikelnummer->WinFocusSet(true);
//    RETURN false;
  end;
  if (Wgr_Data:IstMix()) and (BAG.F.Artikelnummer<>'') then begin
    Erx # RekLink(250,703,13,_recFirst);    // Artikel holen
    if (Erx>_rLocked) then begin
      Msg(001201,Translate('Artikel'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      $edBAG.F.Artikelnummer->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (BAG.F.ReservierenYN) then begin
    if ("BAG.F.ReservFürKunde"=0) then begin
      Msg(001200,Translate('Kunde'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      $edBAG.F.ReservFuerKunde->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(100,703,7,_recFirsT);   // Kunde holen
    if (Erx>_rLocked) then begin
      Msg(001201,Translate('Kunde'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      $edBAG.F.ReservFuerKunde->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (BAG.F.Fertigung<999) then begin
    If ("BAG.F.Länge"=0.0) then begin
      Msg(001200,Translate('Länge'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      $edBAG.F.Laenge->WinFocusSet(true);
      RETURN false;
    end;
  end;



  // Gegenbuchung?
  if ($lb.GegenID->wpcustom<>'') then begin
    if (BA1_F_Main:Splitten()=true) then begin
      Mode # c_modeCancel;  // sofort alles beenden!
      gSelected # 1;
      RETURN true;
      end
    else begin
      RETURN false;
    end;
  end;


  // Ankerfunktion
  if (RunAFX('BAG.F.Abcoil.RecSave','')<>0) then begin
    if (AfxRes<>_rOK) then RETURN false;
  end;



  // Nutzung der allgemeinen RecSave
  BAG.F.Menge # Rnd(BAG.F.Gewicht,Set.Stellen.Menge);
  BAG.F.MEH   # 'kg';

  // AI neu am 26.03.2008
  if (BA1_F_Main:RecSave(Mode)=false) then RETURN false;

  Mode # c_modeCancel;  // sofort alles beenden!
//  gMdi->winclose();
  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  BA1_F_Main:RecCleanUp();
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
  vS  : int;
end;
begin

  // Ankerfunktion
  RunAFX('BAG.F.Aboicl.EvtFocusTerm',aEvt:Obj->wpname);

  if (aEvt:obj->wpname='edBAG.F.AusfOben') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|1');
  if (aEvt:obj->wpname='edBAG.F.AusfUnten') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|2');

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  if (aEvt:Obj=0) then RETURN true;

  vS # WinInfo(aEvt:Obj,_Wintype);
  if ((vS=_WinTypeEdit) or (vS=_WinTypeFloatEdit) or (vS=_WinTypeIntEdit)) then
    if (aEvt:obj->wpchanged) then begin

    case (aEvt:Obj->wpname) of

      'edBAG.F.Streifenanzahl' : begin
      end;

      'edBAG.F.Breite' : begin
        "BAG.F.Stückzahl"   # 0;
        BAG.F.Menge         # 0.0;
        BAG.F.Gewicht       # 0.0;
        $edQM->wpcaptionfloat # Lib_Einheiten:WandleMEH(703, "BAG.F.Stückzahl" , BAG.F.Gewicht, BAG.F.Menge, BAG.F.MEH, 'qm');
        $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        RefreshIfm();
      end;

      'edBAG.F.Laenge': begin
        "BAG.F.Stückzahl"   # 0;
        BAG.F.Menge         # 0.0;
        BAG.F.Gewicht       # 0.0;
        $edQM->wpcaptionfloat # Lib_Einheiten:WandleMEH(703, "BAG.F.Stückzahl" , BAG.F.Gewicht, BAG.F.Menge, BAG.F.MEH, 'qm');
        $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        RefreshIfm();
      end;


      'edBAG.F.Stueckzahl' : begin
        BA1_F_Data:ErrechnePlanmengen(n,BAG.F.Gewicht=0.0, BAG.F.Menge=0.0);
        $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        $edQM->wpcaptionfloat # Lib_Einheiten:WandleMEH(703, "BAG.F.Stückzahl" , BAG.F.Gewicht, BAG.F.Menge, BAG.F.MEH, 'qm');
        RefreshIfm();
      end;


      'edBAG.F.Gewicht' : begin
        BA1_F_Data:ErrechnePlanmengen("BAG.F.Stückzahl"=0,n , BAG.F.Menge=0.0);
        $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        $edQM->wpcaptionfloat # Lib_Einheiten:WandleMEH(703, "BAG.F.Stückzahl" , BAG.F.Gewicht, BAG.F.Menge, BAG.F.MEH, 'qm');
        RefreshIfm();
      end;


      'edBAG.F.Menge' : begin
        BA1_F_Data:ErrechnePlanmengen("BAG.F.Stückzahl"=0, BAG.F.Gewicht=0.0, n);
        $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        RefreshIfm();
      end;

    end;

    if (StrCnv(BAG.F.MEH,_StrUpper)='KG') then  BAG.F.Menge # Rnd(BAG.F.Gewicht,Set.Stellen.Menge);
    if (StrCnv(BAG.F.MEH,_StrUpper)='T') then   BAG.F.Menge # Rnd(BAG.F.Gewicht / 1000.0,Set.Stellen.Menge);
    if (StrCnv(BAG.F.MEH,_StrUpper)='STK') then BAG.F.Menge # CnvFI("BAG.F.Stückzahl");

//    RecalcRest();
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
  vTmp    : int;
  vFilter : int;
  vQ      : alpha(4000);
end;
begin

  case aBereich of

    'Kommission'  : begin
      //RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommission');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kundenartnr' : begin
      RecLink(100,703,7,_recFirst);   // Kunde holen
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKundenartnr');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'Kundenartnr2' : begin
      RecBufClear(105);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung',here+':AusKundenartnr2');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
      vQ # vQ + ' AND Adr.V.VerkaufYN'; // 21.07.2015
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kunde' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Wgr' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWgr');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Struktur' : begin
      Erx # RecLink(819,703,5,_Recfirst);   // Warengruppe holen
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
/*
    'Artikel' : begin
      RecBufClear(250);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
*/
    'Verpackung'  : begin
      RecBufClear(704);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.V.Verwaltung',here+':AusVerpackung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Guete' : begin
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(848);
      MQu.S.Stufe # "BAG.F.Gütenstufe";
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

    'AF.Oben'        : begin
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung','BA1_F_Main:AusAFOben');

      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, BAG.F.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.F.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.F.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, 0);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '1');
      $ZL.BA1.AF->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.F.Nummer)+'|'+AInt(BAG.F.Position)+'|'+
        AInt(BAG.F.Fertigung)+'|0|1';

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'AF.Unten'       : begin
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung','BA1_F_Main:AusAFUnten');

      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, BAG.F.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.F.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.F.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, 0);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '2');
      $ZL.BA1.AF->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.F.Nummer)+'|'+AInt(BAG.F.Position)+'|'
        +AInt(BAG.F.Fertigung)+'|0|2';

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    "BAG.F.ReservFürKunde" # Adr.Kundennr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.F.ReservFuerKunde->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusKundenArtnr
//
//========================================================================
sub AusKundenArtNr()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
//    "BAG.F.ReservFürKunde" # Adr.Kundennr;
    Auswahl('Kundenartnr2');
    end
  else begin
    // Focus auf Editfeld setzen:
    $edBAG.F.KundenArtNr->Winfocusset(false);
  end;
end;


//========================================================================
//  AusKundenArtnr2
//
//========================================================================
sub AusKundenArtNr2()
local begin
  vTmp : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(105,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BA1_F_Data:AusKundenArtNr();
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    gMDI->Winupdate();
  end;
  // Focus auf Editfeld setzen:
  $edBAG.F.KundenArtNr->Winfocusset(false);
end;


//========================================================================
//  AusKommission
//
//========================================================================
sub AusKommission()
local begin
  vTmp : int;
end;
begin
  // Zugriffliste wieder aktivieren
//  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
//    gSelected # 0;
    // Feldübernahme
//    BAG.F.Kommission        # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position);
    "BAG.F.KostenträgerYN"  # y;
    BA1_F_Data:AusKommission(0,0,gSelected);
    gSelected # 0;
    BA1_F_Main:RefreshIfm(); // ETK Daten übernehmeb
    BA1_F_Data:ErrechnePlanmengen(y,y,y);
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  //$edBAG.F.Kommission->Winfocusset(false);
  $edBAG.F.Stueckzahl->Winfocusset(false);
  // ggf. Labels refreshen
  Refreshifm('edBAG.F.Kommission',y);
end;


//========================================================================
//  AusWgr
//
//========================================================================
sub AusWgr()
begin
  // Zugriffliste wieder aktivieren
  //cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    BAG.F.Warengruppe # Wgr.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edBAG.F.Warengruppe->Winfocusset(false);
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
    // Feldübernahme
    BAG.F.Artikelnummer   # Art.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  RefreshIfm('edBAG.F.Artikelnummer');
  $edBAG.F.Artikelnummer->Winfocusset(false);
end;


//========================================================================
//  AusStruktur
//
//========================================================================
sub AusStruktur()
begin
  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    // Feldübernahme
    BAG.F.Artikelnummer # MSL.Strukturnr;
    gSelected # 0;
  end;
  // Focus setzen:
  $edBAG.F.Artikelnummer->Winfocusset(false);
end;


//========================================================================
//  AusVerpackung
//
//========================================================================
sub AusVerpackung()
begin
  if (gSelected<>0) then begin
    RecRead(704,0,_RecId,gSelected);
    // Feldübernahme
    BAG.F.Verpackung # BAG.Vpg.Verpackung;
    gSelected # 0;
  end;
  // Focus setzen:
  $edBAG.F.Verpackung->Winfocusset(false);
end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
begin
  // Zugriffliste wieder aktivieren
  //cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "BAG.F.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "BAG.F.Güte" # "MQu.Güte1"
    else
      "BAG.F.Güte" # "MQu.Güte2";
    gSelected # 0;
  end;
  // Focus setzen:
  $edBAG.F.Guete->Winfocusset(false);
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
    "BAG.F.Gütenstufe" # MQu.S.Stufe;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.F.Guetenstufe->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
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
  vHdl # gMenu->WinSearch('Mnu.New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
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
  vHdl : int;
  vTmp : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edBAG.F.Dickentol') then
        MTo_Data:BildeVorgabe(703,'Dicke');
      if (aEvt:Obj->wpname='edBAG.F.Breitentol') then
        MTo_Data:BildeVorgabe(703,'Breite');
      if (aEvt:Obj->wpname='edBAG.F.Laengentol') then
        MTo_Data:BildeVorgabe(703,'Länge');
    end;

    otherwise begin
      RETURN BA1_F_Main:EvtMenuCommand(aEvt, aMenuItem);
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

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Kommission'   :   Auswahl('Kommission');
    'bt.Kundenartnr'  :   Auswahl('Kundenartnr');
    'bt.Wgr'          :   Auswahl('Wgr');
    'bt.Artikel'      :   Auswahl('Struktur');
    'bt.Verpackung'   :   Auswahl('Verpackung');
    'bt.Guete'        :   Auswahl('Guete');
    'bt.Guetenstufe'  :   Auswahl('Guetenstufe');
    'bt.AusfOben'     :   Auswahl('AF.Oben');
    'bt.AusfUnten'    :   Auswahl('AF.Unten');
    'bt.Kunde'        :   Auswahl('Kunde');
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
  gSelected # RecInfo(gFile, _recid);
  RETURN true;
end;


//========================================================================
//  RecalcRest
//
//========================================================================
sub RecalcRest(
  var aBB   : float;
  var aBL   : float;
  var aBGew : float;
  var aBM   : float;
  var aL    : float;
  var aGew  : float;
  var aM    : float;
  aMitRest  : logic;
);
local begin
  Erx       : int;
  vStk      : int;
  vGew      : float;
  vMe       : float;
  vLen      : float;
  vBuf703   : int;

  vmyFert   : int;
  vmyBlock  : alpha;

  vI        : int;
  vX        : float;
  vA        : alpha;
  vBList    : alpha;
  vBlockLen : float;
  vBlockGew : float;
  vBlockM   : float;
  v701      : int;
end;

begin
  v701    # RekSave(701);

  vBuf703 # RecBufCreate(703);
  RecBufCopy(703,vBuf703);
  vmyBlock    # BAG.F.Block;
  if (BAG.F.Block='') and (BAG.F.AutomatischYN) then begin
    vMyBlock # '^';
  end;
  vmyFert     # BAG.F.Fertigung;
  aBB         # BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl);
  aBGew       # BAG.F.Gewicht;
  aBM         # BAG.F.Menge;

  // Einsatz addieren
  Erx # RecLink(701,702,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.vonFertigmeld=0) and (BAG.IO.Materialtyp<>c_IO_ARt) and (BAG.IO.Materialtyp<>c_IO_Beistell) then begin
      if ("BAG.IO.Länge"=0.0) then begin
//        RecLink(819,701,7,_recFirst);   // Warengruppe holen
      Erx # RecLink(819,703,5,_Recfirst);   // Warengruppe holen
      if (Erx>_rLocked) then RecBufClear(819);

        "BAG.IO.Länge" # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, 1, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM");
      end;
      vLen  # vLen + "BAG.IO.Länge";

      vStk  # vStk + BAG.IO.Plan.Out.Stk;
      vGew  # vGew + BAG.IO.Plan.Out.GewN;

      if (BAG.IO.MEH.Out='m') then begin
        vMe   # vMe  + BAG.IO.Plan.Out.Meng;
        end
      else begin
        vX # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.Out.GewN, BAG.IO.Plan.Out.Meng, BAG.IO.MEH.Out, 'qm');
        vMe   # vMe  + vX;
      end;
    end;

    Erx # RecLink(701,702,2,_recNext);
  END;

  BAG.IO.Plan.Out.Stk   # vStk;
  BAG.IO.Plan.Out.GewN  # vGew;
  BAG.IO.Plan.Out.Meng  # vMe;
  "BAG.IO.Länge"        # vLen;


  // ST 2019-04-03 Projekt 1962/15
  // Planausgang wird in MAske als Einsatz genutzt und darf nicht später durch Buffercopy wieder ersetzt werden
  v701->BAG.IO.Plan.Out.Stk   # vStk
  v701->BAG.IO.Plan.Out.GewN  # vGew;
  v701->BAG.IO.Plan.Out.Meng  # vMe;
  v701->"BAG.IO.Länge"        # vLen;

//debug('');

  // bisherige Fertigungen addieren
  aL    # 0.0;
  aGew  # 0.0;
  aM    # 0.0;
  Erx # RecLink(703,702,4,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (BAG.F.Fertigung<>vmyFert) then begin
      if (vmyBlock=BAG.F.Block) then begin
        aBB   # aBB   + (BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl));
        aBGew # aBGew + BAG.F.Gewicht;
        aBM   # aBM   + BAG.F.Menge;
      end;
    end;
    Erx # RecLink(703,702,4,_recNext);
  END;


  // Blocklängen errechnen
  Erx # RecLink(703,702,4,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    // Restfertigungen überspringen?
    if (BAG.F.Block='') and (BAG.F.AutomatischYN) then begin
      if (aMitRest=n) then begin
        Erx # RecLink(703,702,4,_recNext);
        CYCLE;
      end;
      BAG.F.Block # '^';
    end;

    if (StrFind(vBList,'_'+BAG.F.Block,0)=0) then begin
      vBList  # vBList + '_'+BAG.F.Block;
      vA      # BAG.F.Block;

//      RecLink(819,701,7,_recFirst);   // Warengruppe holen
      Erx # RecLink(819,703,5,_recFirst);   // Warengruppe holen
      if (Erx>_rLocked) then RecBufClear(819);

      vBlockLen # 0.0;

      // tmp.Fertigung beachten
      if (vmyBlock=vA) then begin
        if (vBuf703->BAG.F.Streifenanzahl<>0) then begin
          vLen # CnvfI(vBuf703->"BAG.F.Stückzahl") div cnvfi(vBuf703->BAG.F.Streifenanzahl);
          if (CnvfI(vBuf703->"BAG.F.Stückzahl") % cnvfi(vBuf703->BAG.F.Streifenanzahl) >0.0) then
            vLen # vLen + 1.0;
          vLen # Rnd(vLen * vBuf703->"BAG.F.Länge",2);
          end
        else begin
          vLen # 0.0;
        end;
        if (vLen>vBlockLen) then vBlockLen # vLen;
        aBL # vBlockLen;
      end;

      // gleiche Block-Fertigungen loopen
      vI # BAG.F.Fertigung;
      REPEAT
        if (vA=BAG.F.Block) and (vmyFert<>BAG.F.Fertigung) then begin
          if (BAG.F.Streifenanzahl<>0) then begin
            vLen # CnvfI("BAG.F.Stückzahl") div cnvfi(BAG.F.Streifenanzahl);
            if (CnvfI("BAG.F.Stückzahl") % cnvfi(BAG.F.Streifenanzahl) >0.0) then
              vLen # vLen + 1.0;
            vLen # Rnd(vLen * "BAG.F.Länge",2);
            end
          else begin
            vLen # 0.0;
          end;
          if (vLen>vBlockLen) then vBlockLen # vLen;
        end;
        Erx # RecLink(703,702,4,_recNext);
      UNTIL (Erx>_rlocked);
      BAG.F.Fertigung # vI;
      RecRead(703,1,0);

      if (vmyBlock=vA) then begin
        if (vBlockLen>aBL) then aBL # vBlockLen;
        vBlockGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(1, BAG.IO.Dicke, BAG.IO.Breite, vBlockLen, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM");
        vBlockM   # Rnd(BAG.IO.Breite * vBlockLen / 1000000.0,2);
      end;

//debug('block:'+vA+' '+cnvaf(vblocklen));
      vGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(1, BAG.IO.Dicke, BAG.IO.Breite, vBlockLen, Wgr_Data:GetDichte(Wgr.Nummer,701), "Wgr.TränenKgProQM");
      aM    # aM    + Rnd(BAG.IO.Breite * vBlockLen / 1000000.0,2);
      aGew  # aGew  + vGew;
      aL    # aL    + vBlockLen;
    end;

    Erx # RecLink(703,702,4,_recNext);
  END;


  RecBufCopy(vBuf703,703);    // RESTORE
  RecBufDestroy(vBuf703);



  // neuer Block??
  if (StrFind(vBList,'_'+vmyBlock,0)=0) then begin
//    RecLink(819,701,7,_recFirst);   // Warengruppe holen
    Erx # RecLink(819,703,5,_Recfirst);   // Warengruppe holen
    if (Erx>_rLocked) then RecBufClear(819);

    if (BAG.F.Streifenanzahl<>0) then begin
      vLen # CnvfI("BAG.F.Stückzahl") div cnvfi(BAG.F.Streifenanzahl);
      if (CnvfI("BAG.F.Stückzahl") % cnvfi(BAG.F.Streifenanzahl) >0.0) then
        vLen # vLen + 1.0;
      vBlockLen # Rnd(vLen * "BAG.F.Länge",2);
      end
    else begin
      vBlockLen # 0.0;
    end;

    if (vBlockLen>aBL) then aBL # vBlockLen;
    vBlockGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(1, BAG.IO.Dicke, BAG.IO.Breite, vBlockLen, Wgr_Data:GetDichte(Wgr.Nummer,701), "Wgr.TränenKgProQM");
    vBlockM   # Rnd(BAG.IO.Breite * vBlockLen / 1000000.0,2);

    vGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(1, BAG.IO.Dicke, BAG.IO.Breite, vBlockLen, Wgr_Data:GetDichte(Wgr.Nummer,701), "Wgr.TränenKgProQM");
    aM    # aM    + Rnd(BAG.IO.Breite * vBlockLen / 1000000.0,2);
    aGew  # aGew  + vGew;
    aL    # aL    + vBlockLen;
//debug('Newblock '+bag.f.block+':  str:'+cnvai(bag.f.streifenanzahl)+'  Stk:'+cnvai("BAG.F.Stückzahl")+' L:'+cnvaf("bag.f.länge"));
//debug('newblocklen:'+cnvaf(vBlockLen));
//debug('used:'+cnvaf(gBAG_Use_L));
  end;


  aBGew # Rnd(vBlockGew - aBGew,0);
  aBM   # Rnd(vBlockM   - aBM,2);

  aBB   # Rnd(aBB,2);
  aBL   # Rnd(aBL,2);
  aL    # Rnd(aL,2);
  aGew  # Rnd(aGew,0);
  aM    # Rnd(aM,2);

  RekRestore(v701);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edBAG.F.Kommission') AND (aBuf->BAG.F.Kommission<>'')) then begin
    Auf.P.Nummer # BAG.F.Auftragsnummer;
    Auf.P.Position # BAG.F.Auftragspos;
    RecRead(401,1,0);
    Lib_Guicom2:JumpToWindow('Auf.P.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edBAG.F.Warengruppe') AND (aBuf->BAG.F.Warengruppe<>0)) then begin
    RekLink(819,703,5,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edBAG.F.Guetenstufe') AND (aBuf->"BAG.F.Gütenstufe"<>'')) then begin
    MQu.S.Stufe # "BAG.F.Gütenstufe";
    RecRead(848,1,0);
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edBAG.F.Guete') AND (aBuf->"BAG.F.Güte"<>'')) then begin
    "MQu.Güte1" # "BAG.F.Güte";
    RecRead(832,1,0);
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.F.Artikelnummer') AND (aBuf->BAG.F.Artikelnummer<>'')) then begin
    RekLink(250,703,13,0);   // Artikelnr. holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;

  if ((aName =^ 'edBAG.F.ReservFuerKunde') AND (aBuf->"BAG.F.ReservFÜrKunde"<>0)) then begin
    RekLink(100,703,7,0);   // Reserv.für Kunde holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung')
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.F.KundenArtNr') AND (aBuf->BAG.F.KundenArtNr<>'')) then begin
    Adr.V.KundenArtNr # BAG.F.KundenArtNr;
    RecRead(105,2,0);
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.F.Verpackung') AND (aBuf->BAG.F.Verpackung<>0)) then begin
    RekLink(100,703,7,0);   // Verpackungsnr. holen
    Lib_Guicom2:JumpToWindow('BA1.V.Verwaltung');
    RETURN;
  end;


end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================