@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_F_Ablaeng_Main
//                  OHNE E_R_G
//  Info
//
//
//  27.04.2009  AI  Erstellung der Prozedur
//  03.06.2009  TM  Gütenstufen eingefügt
//  27.07.2021  AH  ERX
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
  cDialog :   $BA1.F.Ablaeng.Maske
  cTitle :    'Ablängen-Fertigung'
  cFile :     703
  cMenuName : 'BA1.F.Bearbeiten'
  cPrefix :   'BA1_F_Ablaeng'
//  cZList :    0
  cKey :      1

//  cZList1 :   $RL.BA1.Pos
//  cZList2 :   $RL.BA1.Input
//  cZList3 :   $RL.BA1.Fertigung
end;

declare RefreshIfm(opt aName : alpha; opt aChanged : logic)
//declare RecalcRest(var aBB : float;var aBLR : float;var aBGewR : float;var aBMR : float;var aL : float;var aGew : float;var aM : float; aMitRest : logic);
declare RecalcRest(var aL : float;var aGew : float;var aM : float; aMitRest : logic);

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

  SetStdAusFeld('edBAG.F.Kommission'     ,'Kommission');
  SetStdAusFeld('edBAG.F.KundenArtNr'    ,'Kundenartnr');
  SetStdAusFeld('edBAG.F.ReservFuerKunde','Kunde');
  SetStdAusFeld('edBAG.F.Warengruppe'    ,'Wgr');
//  SetStdAusFeld('edBAG.F.Artikelnummer'  ,'Struktur');
  SetStdAusFeld('edBAG.F.Verpackung'     ,'Verpackung');
  SetStdAusFeld('edBAG.F.Guete'          ,'Guete');
  SetStdAusFeld('edBAG.F.Guetenstufe'    ,'Guetenstufe');
  SetStdAusFeld('edBAG.F.AusfOben'       ,'AF.Oben');
  SetStdAusFeld('edBAG.F.AusfUnten'      ,'AF.Unten');

  $edMeter->wpDecimals # Set.Stellen.Menge;

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
local begin
  Erx : int;
end;
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edBAG.F.Warengruppe);
  if (BAG.F.ReservierenYN) then
    Lib_GuiCom:Pflichtfeld($edBAG.F.ReservFuerKunde);

  Erx # RekLink(819,703,5,_recFirst); // Warengruppe holen
  if (Erx<=_rLocked) and (Wgr_Data:IstMix()) then
    Lib_GuiCom:PflichtFeld($edBAG.F.Artikelnummer)
  else
    Lib_GuiCom:PflichtFeld($edBAG.F.Artikelnummer,y);
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
  Erx : int;
  va  : alphA;
  vX  : int;
  vTmp : int;
  vL    : float;
  vGew  : float;
  vM    : float;
  vOk : logic;
  vInMeter  : float;
  vMeter    : float;
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
  vMeter # Lib_Einheiten:WandleMEH(703, "BAG.F.Stückzahl" , BAG.F.Gewicht, BAG.F.Menge, BAG.F.MEH, 'm');
  $edMeter->wpcaptionfloat # vMeter;
  

  if (aName='edBAG.F.Laengentol') then begin
    "BAG.F.Längentol" # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Längentol","Set.Stellen.Länge");
  end;

  // Vorgabenüberprüfung [22.09.2009/PW]
  if (aName = 'edBAG.F.Dicke' or aName = 'edBAG.F.Breite' or aName = 'edBAG.F.Laenge' or
        aName = 'edBAG.F.Dickentol' or aName = 'edBAG.F.Breitentol' or aName = 'edBAG.F.Laengentol' or
        aName = 'edBAG.F.AusfOben' or aName = 'edBAG.F.AusfUnten') then begin
    vTmp # gMdi->winSearch(aName);
    if (vTmp != 0) then begin
      case (aName) of
        'edBAG.F.Dicke'      : vOk # ($Lb.Dicke.A->wpCaption != '') and (vTmp->wpCaptionFloat != 0.0) and ($Lb.Dicke.A->wpCaption != ANum(vTmp->wpCaptionFloat, "Set.Stellen.Dicke"));
        'edBAG.F.Breite'     : vOk # ($Lb.Breite.A->wpCaption != '') and (vTmp->wpCaptionFloat != 0.0) and ($Lb.Breite.A->wpCaption != ANum(vTmp->wpCaptionFloat, "Set.Stellen.Breite"));
        'edBAG.F.Laenge'     : vOk # ($Lb.Laenge.A->wpCaption != '') and (vTmp->wpCaptionFloat != 0.0) and ($Lb.Laenge.A->wpCaption != ANum(vTmp->wpCaptionFloat, "Set.Stellen.Länge"));
        'edBAG.F.Dickentol'  : vOk # ($Lb.Dickentol.A->wpCaption != '') and (vTmp->wpCaption != '') and ($Lb.Dickentol.A->wpCaption  != vTmp->wpCaption);
        'edBAG.F.Breitentol' : vOk # ($Lb.Breitentol.A->wpCaption != '') and (vTmp->wpCaption != '') and ($Lb.Breitentol.A->wpCaption != vTmp->wpCaption);
        'edBAG.F.Laengentol' : vOk # ($Lb.Laengentol.A->wpCaption != '') and (vTmp->wpCaption != '') and ($Lb.Laengentol.A->wpCaption != vTmp->wpCaption);
        'edBAG.F.AusfOben'   : vOk # ($Lb.AusfOben.A->wpCaption != '') and (vTmp->wpCaption != '') and ($Lb.AusfOben.A->wpCaption   != vTmp->wpCaption);
        'edBAG.F.AusfUnten'  : vOk # ($Lb.AusfUnten.A->wpCaption != '') and (vTmp->wpCaption != '') and ($Lb.AusfUnten.A->wpCaption  != vTmp->wpCaption);
      end;
      if (vOk) then
        vTmp->wpColBkg # _winColLightRed;
      else
        vTmp->wpColBkg # _winColWhite;
    end;
  end;

  if (aName='') or (y) then begin

    //RecalcRest(var vBB,var vBL,var vBGew,var vBM,var vL,var vGew,var vM, true);
    RecalcRest(var vL,var vGew,var vM, true);
    if (BAG.IO.MEH.Out='m') then
      vInMeter # BAG.IO.Plan.Out.Meng
    else
      vInMeter # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.Out.GewN, BAG.io.plan.out.Meng, BAG.io.MEH.out, 'm');

    // Einsatz anzeigen
    $Lb.Guete.E->wpcaption      # "BAG.IO.Güte";
    $Lb.GuetenStufe.E->wpcaption # "BAG.IO.GütenStufe";
    $Lb.AusfOben.E->wpcaption   # BAG.IO.AusfOben;
    $Lb.AusfUnten.E->wpcaption  # BAG.IO.AusfUnten;
    $Lb.Artikel.E->wpcaption    # BAG.IO.Artikelnr;
    $Lb2.Dicke.E->wpcaption      # ANum(BAG.IO.Dicke,"Set.Stellen.Dicke");
    $Lb2.Breite.E->wpcaption     # ANum(BAG.IO.Breite,"Set.Stellen.Breite");
    if (Abs("BAG.IO.Länge")>9999.99) then begin
      $lb.LenMEH_E->wpcaption    # 'm';
      $Lb.Laenge.E->wpcaption   # ANum("BAG.IO.Länge"/1000.0,"Set.Stellen.Länge");
      end
    else begin
      $lb.LenMEH_E->wpcaption    # 'mm';
      $Lb.Laenge.E->wpcaption   # ANum("BAG.IO.Länge","Set.Stellen.Länge");
    end;
    $Lb2.Dickentol.E->wpcaption  # BAG.IO.Dickentol;
    $Lb2.Breitentol.E->wpcaption # BAG.IO.Breitentol;
    $Lb.Laengentol.E->wpcaption # "BAG.IO.Längentol";
    $Lb.Stueck.E->wpcaption     # CnvaI(BAG.IO.Plan.Out.Stk,_FmtNumNoGroup);
    $Lb.Gewicht.E->wpcaption    # ANum(BAG.IO.Plan.Out.GewN,"Set.Stellen.Gewicht");
    $Lb.Meter.E->wpcaption      # ANum(vInMeter,"Set.Stellen.Menge");


    // Reste anzeigen
    if (Abs("BAG.IO.Länge"-vL)>9999.99) then begin
      $lb.LenMEH_R->wpcaption   # 'm';
      $Lb.Laenge.R->wpcaption   # ANum(("BAG.IO.Länge"-vL)/1000.0,"Set.Stellen.Länge");
      end
    else begin
      $lb.LenMEH_R->wpcaption   # 'mm';
      $Lb.Laenge.R->wpcaption   # ANum("BAG.IO.Länge"-vL,"Set.Stellen.Länge");
    end;
    $Lb.Gewicht.R->wpcaption    # ANum(BAG.IO.Plan.Out.GewN - vGew, "Set.Stellen.Gewicht");
    $Lb.Meter.R->wpcaption      # ANum(vInMeter - vMeter, "Set.Stellen.Menge");
    if ("BAG.IO.Länge"-vL<0.0) then $lb.Laenge.R->wpColBkg # _WinColLightRed
    else $lb.Laenge.R->wpColBkg # _WinColParent;
    if (BAG.IO.PLan.Out.GewN - vGew<0.0) then $lb.Gewicht.R->wpColBkg # _WinColLightRed
    else $lb.Gewicht.R->wpColBkg # _WinColParent;
    if (vInMeter-vMeter<0.0) then $lb.Meter.R->wpColBkg # _WinColLightRed
    else $lb.Meter.R->wpColBkg # _WinColParent;


    // Etikettierung
    $Lb2.Guete.F->wpcaption      # "BAG.F.Güte";
    //$Lb2.Dicke.F->wpcaption      # cnvaf(BAG.F.Dicke,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Dicke);
    $Lb2.Breite.F->wpcaption     # cnvaf(BAG.F.Breite,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Breite);
    $Lb2.Laenge.F->wpcaption     # cnvaf("BAG.F.Länge",_FmtNumNoGroup|_FmtNumNoZero,0,"Set.Stellen.Länge");
    $Lb2.Dickentol.F->wpcaption  # BAG.F.Dickentol;
    $Lb2.Breitentol.F->wpcaption # BAG.F.Breitentol;
    $Lb2.Laengentol.F->wpcaption # "BAG.F.Längentol";
    $Lb2.Guete.A->wpcaption      # $lb.Guete.A->wpcaption;;
    //$Lb2.Dicke.A->wpcaption      # $lb.Dicke.A->wpcaption;
    //$Lb2.Breite.A->wpcaption     # x$lb.Breite.A->wpcaption;
    $Lb2.Laenge.A->wpcaption     # $lb.Laenge.A->wpcaption;
    //$Lb2.Dickentol.A->wpcaption  # $lb.Dickentol.A->wpcaption;
    //$Lb2.Breitentol.A->wpcaption # $lb.Breitentol.A->wpcaption;
    $Lb2.Laengentol.A->wpcaption # $lb.Laengentol.A->wpcaption;
    $Lb2.Guete.E->wpcaption      # $lb.Guete.E->wpcaption;;
    //$Lb2.Dicke.E->wpcaption      # $lb.Dicke.E->wpcaption;
    //$Lb2.Breite.E->wpcaption     # $lb.Breite.E->wpcaption;
    $Lb2.Laenge.E->wpcaption     # $lb.Laenge.E->wpcaption;
    //$Lb2.Dickentol.E->wpcaption  # $lb.Dickentol.E->wpcaption;
    //$Lb2.Breitentol.E->wpcaption # $lb.Breitentol.E->wpcaption;
    $Lb2.Laengentol.E->wpcaption # $lb.Laengentol.E->wpcaption;
  end;

  if (
    (aName='edBAG.F.Kommission') and (($edBAG.F.Kommission->wpchanged) or (aChanged))) then begin
    // Kommission angegeben?
    BA1_F_Data:AusKommission(0 ,0, 0);
    BA1_F_Main:RefreshIfm();
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
    $Lb2.Dicke.A->wpcaption     # '';
    $Lb2.Breite.A->wpcaption    # '';
    $Lb.Laenge.A->wpcaption     # '';
    $Lb.Stueck.A->wpcaption     # '';
    $Lb.Gewicht.A->wpcaption    # '';
    $Lb.Meter.A->wpcaption      # '';
    $Lb2.Dickentol.A->wpcaption  # '';
    $Lb2.Breitentol.A->wpcaption # '';
    $Lb.Laengentol.A->wpcaption # '';
    if (BAG.F.AuftragsNummer<>0) then begin
      Erx # Auf_Data:Read(BAG.F.Auftragsnummer, BAG.F.AuftragsPos, y);
      $Lb.Guete.A->wpcaption      # "Auf.P.Güte";
      $Lb.GuetenStufe.A->wpcaption      # "Auf.P.GütenStufe";
      $Lb.AusfOben.A->wpcaption   # Auf.P.AusfOben;
      $Lb.AusfUnten.A->wpcaption  # Auf.P.AusfUnten;
      $Lb.Artikel.A->wpcaption    # Auf.P.Artikelnr;
      $Lb2.Dickentol.A->wpcaption  # Auf.P.Dickentol;
      $Lb2.Breitentol.A->wpcaption # Auf.P.Breitentol;
      $Lb.Laengentol.A->wpcaption # "Auf.P.Längentol";

      if (Auf.P.Dicke<>0.0) then
        $Lb2.Dicke.A->wpcaption      # ANum(Auf.P.Dicke,"Set.Stellen.Dicke");
      if (Auf.P.Breite<>0.0) then
        $Lb2.Breite.A->wpcaption     # ANum(Auf.P.Breite,"Set.Stellen.Breite");
      if ("Auf.P.Länge"<>0.0) then
        $Lb.Laenge.A->wpcaption     # ANum("Auf.P.Länge","Set.Stellen.Länge");
      if ("Auf.P.Stückzahl"-Auf.P.Prd.PLan.Stk>0) then
        $Lb.Stueck.A->wpcaption     # cnvai("Auf.P.Stückzahl"-Auf.P.Prd.PLan.Stk,_FmtNumNoGroup);
      if (Auf.P.Gewicht-Auf.P.Prd.Plan.Gew>0.0) then
        $Lb.Gewicht.A->wpcaption    # ANum(Auf.P.Gewicht-Auf.P.Prd.Plan.Gew,"Set.Stellen.Gewicht");

      if ("Auf.P.Stückzahl"-Auf.P.Prd.Plan.Stk>0) then begin
        $Lb.Meter.A->wpcaption    # ANum(Auf.P.Breite * "Auf.P.Länge" / 1000000.0 * Cnvfi(("Auf.P.Stückzahl"-Auf.P.Prd.Plan.Stk)) ,2);
      end
      else begin
        $lb.Meter.A->wpcaption    # '0,00';
      end;
    end;
  end;


  if (aName='edBAG.F.Guete') and ($edBAG.F.Guete->wpchanged) then begin
    MQu_Data:Autokorrektur(var "BAG.F.Güte");
    $edBAG.F.Guete->Winupdate();
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
//    BAG.F.Kommission  # Translate('RESTCOIL');
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
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
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

    if (w_AppendNr != 0) then begin
      BAG.F.Fertigung # w_AppendNr;
      RecRead(703, 1, 0);
      w_AppendNr # 0;
    end
    else begin
      BAG.F.Warengruppe     # BAG.IO.Warengruppe;
      BAG.F.MEH             # 'm';
      "BAG.F.Güte"          # "BAG.IO.Güte";
      BAG.F.Streifenanzahl  # 1;
      "BAG.F.KostenträgerYN"  # Set.BA.F.KostenTrgYN;
      Erx # RecLink(828,702,8,_RecFirst);   // Arbeitsgang holen
      if (Erx<=_rLocked) and (ArG.BAG.Warengruppe<>0) then
        BAG.F.Warengruppe     # ArG.BAG.Warengruppe;
    end;
    if (vA='') then
      BAG.F.Block         # 'A'
    else
      BAG.F.Block         # StrChar(StrToChar(vA,1)+1);

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
  Erx->wpcustom # cnvai(vTmp);

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

  if (BAG.F.Kommission <> '') then begin
    Erx # RecLinkInfo(401, 703, 9, _recCount);
    if(Erx = 0) then begin
      Msg(001201,BAG.F.Kommission  + ' ' + Translate('Kommission'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      $edBAG.F.Kommission->WinFocusSet(true);
      RETURN false;
    end;
    // 16.08.2018 AH:
    Erx # RecLink(401,703,9,_recFirst);  // AufPos holen
    if (Erx>_rLocked) or ("Auf.P.Löschmarker"<>'') then begin
      if (mode=c_modeNew) or ((Mode=c_ModeEdit) and (ProtokollBuffer[703]->BAG.F.Kommission<>BAG.F.Kommission)) then begin
        Msg(404101, BAG.F.Kommission,_WinIcoError, _WinDialogOk, 1);
        vTmp->wpcurrent # 'NB.Page1';
        $edBAG.F.Kommission->WinFocusSet(true);
        RETURN false;
      end;
    end;
  end;


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

  TRANSON;

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # BA1_F_Data:Replace(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    BAG.F.Anlage.Datum  # Today;
    BAG.F.Anlage.Zeit   # Now;
    BAG.F.Anlage.User   # gUserName;

    // XzuY Arbeitsgang ==========================================
    BAG.F.Fertigung # 1;
    WHILE (RecRead(703,1,_RecTest)<=_rLocked) do
      BAG.F.Fertigung # BAG.F.Fertigung + 1;

    Erx # BA1_F_Data:Insert(0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

  end;

  // Fertigmaterial updaten
  if (BA1_F_Data:UpdateOutput(703,n)=false) then begin
    TRANSBRK;
    ERROROUTPUT;  // 01.07.2019
    Msg(701010,gTitle,0,0,0);
    RETURN true;
  end;

  TRANSOFF;

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

      'edBAG.F.Laenge': begin
        "BAG.F.Stückzahl"   # 0;
        BAG.F.Menge         # 0.0;
        BAG.F.Gewicht       # 0.0;
        $edMeter->wpcaptionfloat # Lib_Einheiten:WandleMEH(703, "BAG.F.Stückzahl" , BAG.F.Gewicht, BAG.F.Menge, BAG.F.MEH, 'm');
        $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        RefreshIfm();
      end;


      'edBAG.F.Stueckzahl' : begin
        BA1_F_Data:ErrechnePlanmengen(n,BAG.F.Gewicht=0.0, BAG.F.Menge=0.0);
        $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        $edMeter->wpcaptionfloat # Lib_Einheiten:WandleMEH(703, "BAG.F.Stückzahl" , BAG.F.Gewicht, BAG.F.Menge, BAG.F.MEH, 'm');
        RefreshIfm();
      end;


      'edBAG.F.Gewicht' : begin
        BA1_F_Data:ErrechnePlanmengen("BAG.F.Stückzahl"=0,n , BAG.F.Menge=0.0);
        $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        $edMeter->wpcaptionfloat # Lib_Einheiten:WandleMEH(703, "BAG.F.Stückzahl" , BAG.F.Gewicht, BAG.F.Menge, BAG.F.MEH, 'm');
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


    'Kunde' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
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


    'Wgr' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWgr');
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
  // RefreshIfm('edxxx.xxxxxxx');
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
//    BAG.F.Kommission        # CnvAI(Auf.P.Nummer, _FmtNumNoGroup) + '/' + CnvAI(Auf.P.Position, _FmtNumNoGroup);
    BA1_F_Data:AusKommission(0,0,gSelected);
    gSelected # 0;
    BA1_F_Main:RefreshIfm(); // ETK Daten übernehmeb
    BA1_F_Data:ErrechnePlanmengen(y,y,y);

    "BAG.F.KostenträgerYN"  # y;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  //$edBAG.F.Kommission->Winfocusset(false);
  $edBAG.F.Stueckzahl->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');

  Refreshifm('edBAG.F.Kommission',y);

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
//  AusWgr
//
//========================================================================
sub AusWgr()
begin
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
    vHdl->wpDisabled # (BAG.F.Fertigung=999) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.Fertigung=999) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

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
  var aL      : float;
  var aGew    : float;
  var aM      : float;
  aMitRest    : logic;
);
local begin
  Erx       : int;
  vStk      : int;
  vGew      : float;
  vMe       : float;
  vLen      : float;
  vBuf703   : int;

  vmyFert   : int;
  vX        : float;
  vI        : int;
  vJ        : int;

  vHdl      : int;
  vBarPos   : int;
  vBar      : int;
  vBarFak   : float;
  vAnz      : int;
end;

begin

  vBuf703 # RekSave(703);

  vmyFert     # BAG.F.Fertigung;

  vLen # 0.0;
  // Einsatz addieren
  Erx # RecLink(701,702,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.vonFertigmeld=0) and (BAG.IO.Materialtyp<>c_IO_ARt) and (BAG.IO.Materialtyp<>c_IO_Beistell) then begin
      if ("BAG.IO.Länge"=0.0) then begin
        RecLink(819,701,7,_recFirst);   // Warengruppe holen
        "BAG.IO.Länge" # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, 1, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM");
      end;
      if ("BAG.IO.Länge"<>0.0) then begin
        if ("BAG.IO.Länge"<vLen) then vLen # "BAG.IO.Länge";
        if (vLen=0.0) then vLen # "BAG.IO.Länge";
      end;
      //vLen  # vLen + "BAG.IO.Länge";

      vStk  # vStk + BAG.IO.Plan.Out.Stk;
      vGew  # vGew + BAG.IO.Plan.Out.GewN;
      if (BAG.IO.MEH.Out='m') then begin
        vMe   # vMe  + BAG.IO.Plan.Out.Meng;
        end
      else begin
        vX # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.Out.GewN, BAG.IO.Plan.Out.Meng, BAG.IO.MEH.Out, 'm');
        vMe   # vMe  + vX;
      end;
    end;

    Erx # RecLink(701,702,2,_recNext);
  END;

  BAG.IO.Plan.Out.Stk   # vStk;
  BAG.IO.Plan.Out.GewN  # vGew;
  BAG.IO.Plan.Out.Meng  # vMe;
  "BAG.IO.Länge"        # vLen;
  if (BAG.IO.Plan.Out.Stk=0) then BAG.IO.Plan.Out.Stk # 1;


  if ("BAG.IO.Länge"<>0.0) then
    vBarFak # 930.0 / "BAG.IO.Länge";
  vBarPos # 8;
  vBar    # 1;


  // bisherige Fertigungen addieren
  aL    # 0.0;
  aGew  # 0.0;
  aM    # 0.0;
  vBarPos # 8;

  Erx # RecLink(703,702,4,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    // Restfertigungen überspringen?
    if ((BAG.F.Block='') and (BAG.F.AutomatischYN)) or
      (BAG.F.Fertigung=vMyFert) then begin
      Erx # RecLink(703,702,4,_recNext);
      CYCLE;
    end;

    vAnz # 0;
    if (BAG.IO.Plan.Out.Stk<>0) then
      vAnz # "BAG.F.Stückzahl" div BAG.IO.Plan.Out.Stk;

    aL # aL + ("BAG.F.Länge" * cnvfi(vAnz));
    aGew # aGew + BAG.F.Gewicht;
    aM # aM + BAG.F.Menge;


    FOR vI # 1 loop inc (vI) while vI<=vAnz do begin
      vHdl # Winsearch(gMdi,'bar.E'+cnvai(vBar));
      vBar # vBar + 1;
      if (vHdl<>0) then begin
        vHdl->wparealeft  # vBarPos;
        vJ # cnvif("BAG.F.Länge" * vBarFak);
        vHdl->wparearight # vBarPos + vj;
        vHdl->wpcaption # ANum("BAG.F.Länge","Set.Stellen.Länge");
        vHdl->wpvisible # true;
        vBarPos # vBarPos + vJ;
      end;
    END;

    Erx # RecLink(703,702,4,_recNext);
  END;
  RekRestore(vBuf703);


  // Diesen Block einrechnen
  vAnz # 0;
  if (BAG.IO.Plan.Out.Stk<>0) then
    vAnz # "BAG.F.Stückzahl" div BAG.IO.Plan.Out.Stk;

  aL # aL + ("BAG.F.Länge" * cnvfi(vAnz));
  aGew # aGew + BAG.F.Gewicht;
  aM # aM + BAG.F.Menge;

  FOR vI # 1 loop inc (vI) while vI<=vAnz do begin
    vHdl # Winsearch(gMdi,'bar.E'+cnvai(vBar));
    vBar # vBar + 1;
    if (vHdl<>0) then begin
      vHdl->wparealeft  # vBarPos;
      vJ # cnvif("BAG.F.Länge" * vBarFak);
      vHdl->wparearight # vBarPos + vJ;
      vHdl->wpcaption # ANum("BAG.F.Länge","Set.Stellen.Länge");
      vHdl->wpvisible # true;

      if (aL>"BAG.IO.Länge") then vHdl->wpColBkg # _wincollightred
      else vHdl->wpColBkg # _WinColLightYellow;

      vBarPos # vBarPos + vJ;
    end;
  END;


  vHdl # Winsearch(gMdi,'bar.frei');
  vHdl->wparealeft  # vBarPos;
  vHdl->wparearight # 930+8;
  vHdl->wpcaption   # ANum("BAG.IO.LÄnge" - aL,"Set.Stellen.Länge");
  vHdl->wpvisible   # true;

  $bar.all->wpcaption # 'gesamt '+ANum("BAG.IO.Länge","Set.Stellen.Länge");


  aL    # Rnd(aL,2);
  aGew  # Rnd(aGew,0);
  aM    # Rnd(aM,2);
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
    todo('Guete')
    // RekLink(819,200,1,0);   // Güte holen
    "MQu.Güte1" # "BAG.F.Güte";
    RecRead(832,2,0);
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