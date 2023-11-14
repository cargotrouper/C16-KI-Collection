@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_F_Spalt_Main
//                    OHNE E_R_G
//  Info
//
//
//  15.03.2004  AI  Erstellung der Prozedur
//  26.05.2008  ST  Etikettierungsfelder hinzugefügt
//  03.06.2009  TM  Gütenstufen eingefügt
//  05.01.2016  AH  "AusKommission" und Änderung der Kommission nutzen "BA1_F_Data:AusKommission" (in ALLEN Arbeitsgängen)
//  29.11.2019  AH  Funktionen zentralisiert in BA1_F_Main
//  05.04.2022  AH  ERX
//  19.07.2022  HA  Quick Jump
//  2022-12-21  AH  neue BA-MEH-Logik
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
//    SUB AusKommission()
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
  cDialog :   $BA1.F.Spalt.Maske
  cTitle :    'Spalten-Fertigung'
  cFile :     703
  cMenuName : 'BA1.F.Bearbeiten'
  cPrefix :   'BA1_F_Spalt'
//  cZList :    0
  cKey :      1

//  cZList1 :   $RL.BA1.Pos
//  cZList2 :   $RL.BA1.Input
//  cZList3 :   $RL.BA1.Fertigung
end;

declare RefreshIfm(opt aName : alpha; opt aChanged : logic)
declare RecalcRest(var aB : float;var aGew : float);

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
  Lib_Guicom2:Underline($edBAG.F.Verpackung)

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

  App_Main:EvtInit(aEvt);

  // gesamtes Einsatzmaterial in einen Input summieren
  BA1_F_Data:SumInput('kg');
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
  Lib_GuiCom:Pflichtfeld($edBAG.F.Streifenanzahl);
  Lib_GuiCom:Pflichtfeld($edBAG.F.Breite);
  if (BAG.F.ReservierenYN) then
    Lib_GuiCom:Pflichtfeld($edBAG.F.ReservFuerKunde);
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
  Erx   : int;
  va    : alphA;
  vX    : int;
  vTmp  : int;

  vBB   : float;
  vBGew : float;
  vOk : logic;
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

  // RID kann nur in 1. Fertigung editiert werden
  if (BAG.F.Fertigung=1) and ((Mode=c_modeNew) or (Mode=c_modeEdit)) then begin
    Lib_GuiCom:Enable($edBAG.F.RID);
  end;

  if((Mode=c_modeNew) or (Mode=c_modeEdit)) then begin
    Lib_GuiCom:Enable($edBAG.F.RAD);
    Lib_GuiCom:Enable($edBAG.F.RADmax);
  end;

  if (aName='edBAG.F.Dickentol') then begin
    BAG.F.Dickentol # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Dickentol",Set.Stellen.Dicke);
  end;

  if (aName='edBAG.F.Breitentol') then begin
    BAG.F.Breitentol # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Breitentol",Set.Stellen.Breite);
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

  if ((aName='edBAG.F.Kommission') and (($edBAG.F.Kommission->wpchanged) or (aChanged))) then begin
    // Kommission angegeben?
    BA1_F_Data:AusKommission(0 ,0, 0);
    BA1_F_Main:RefreshIfm(); // ETK Daten übernehmeb
    Refreshifm('edBAG.F.ReservFuerKunde');
    Refreshifm('edBAG.F.Warengruppe');
    Refreshifm('edBAG.F.Verpackung');
/*** 05.01.2016
    BAG.F.Auftragsnummer  # 0;
    BAG.F.AuftragsPos     # 0;
    if (BAG.F.Kommission<>'') and (StrCut(BAG.F.Kommission,1,1)<>'#') then begin
      vA # StrCut(BAG.F.Kommission,1,1);
      vX # StrFind(BAG.F.Kommission,'/',0);
      if (vA>='0') and (vA<='9') and (vx<>0) then begin
        vA # Str_Token(BAG.F.Kommission,'/',1);
        BAG.F.Auftragsnummer # CnvIa(va);
        vA # Str_Token(BAG.F.Kommission,'/',2);
        BAG.F.Auftragspos # CnvIa(va);
      end;
    end;
    BA1_F_Data:AusKommission(BAG.F.Auftragsnummer, BAG.F.Auftragspos, 0);
    BA1_F_Main:RefreshIfm(); // ETK Daten übernehmeb
    Refreshifm('edBAG.F.ReservFuerKunde');
    Refreshifm('edBAG.F.Verpackung');
    gMDI->winupdate();
//    gMDI->winupdate(_WinUpdFld2Obj);
*/
  end;

  if (aName='') or (aName='edBAG.F.Kommission') then begin
    $Lb.Guete.A->wpcaption        # '';
    $Lb.GuetenStufe.A->wpcaption  # '';
    $Lb.AusfOben.A->wpcaption   # '';
    $Lb.AusfUnten.A->wpcaption  # '';
    $Lb.Artikel.A->wpcaption    # '';
    $Lb.Dicke.A->wpcaption      # '';
    $Lb.Breite.A->wpcaption     # '';
    $Lb.Stueck.A->wpcaption     # '';
    $Lb.Gewicht.A->wpcaption    # '';
    $Lb.Dickentol.A->wpcaption  # '';
    $Lb.Breitentol.A->wpcaption # '';
    $Lb.RID.A->wpcaption        # '';
    $Lb.RIDmax.A->wpcaption     # '';
    $Lb.RAD.A->wpcaption        # '';
    $Lb.RADmax.A->wpcaption     # '';
    if (BAG.F.AuftragsNummer<>0) then begin
      Erx # Auf_Data:Read(BAG.F.Auftragsnummer, BAG.F.AuftragsPos, y);
      $Lb.Guete.A->wpcaption      # "Auf.P.Güte";
      $Lb.GuetenStufe.A->wpcaption      # "Auf.P.GütenStufe";
      $Lb.AusfOben.A->wpcaption   # Auf.P.AusfOben;
      $Lb.AusfUnten.A->wpcaption  # Auf.P.AusfUnten;
      $Lb.Artikel.A->wpcaption    # Auf.P.Artikelnr;
      $Lb.Dickentol.A->wpcaption  # Auf.P.Dickentol;
      $Lb.Breitentol.A->wpcaption # Auf.P.Breitentol;
      if (Auf.P.Dicke<>0.0) then
        $Lb.Dicke.A->wpcaption      # ANum(Auf.P.Dicke,"Set.Stellen.Dicke");
      if (Auf.P.Breite<>0.0) then
        $Lb.Breite.A->wpcaption     # ANum(Auf.P.Breite,"Set.Stellen.Breite");
      if ("Auf.P.Stückzahl"-Auf.P.Prd.Plan.Stk>0) then
        $Lb.Stueck.A->wpcaption     # AInt("Auf.P.Stückzahl"-Auf.P.Prd.PLan.Stk);
      if (Auf.P.Gewicht-Auf.P.Prd.Plan.Gew>0.0) then
        $Lb.Gewicht.A->wpcaption    # ANum(Auf.P.Gewicht-Auf.P.Prd.Plan.Gew,"Set.Stellen.Gewicht");

      if (Auf.P.RID<>0.0) then
        $Lb.RID.A->wpcaption    # ANum(Auf.P.RID,"Set.Stellen.Radien");
      if (Auf.P.RIDmax<>0.0) then
        $Lb.RIDmax.A->wpcaption # ANum(Auf.P.RIDmax,"Set.Stellen.Radien");
      if (Auf.P.RAD<>0.0) then
        $Lb.RAD.A->wpcaption    # ANum(Auf.P.RAD,"Set.Stellen.Radien");
      if (Auf.P.RADmax<>0.0) then
        $Lb.RADmax.A->wpcaption # ANum(Auf.P.RADmax,"Set.Stellen.Radien");
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
//   BAG.F.Kommission  # Translate('RESTCOIL');
    "BAG.F.Länge"     # 0.0;
  end;


  if (aName='') or (y) then begin

    vBGew # BAG.F.Gewicht;
    vBB   # BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl);
    RecalcRest(var vBB, var vBGew);
    if (BAG.F.AutomatischYN) then begin
      vBGew # 0.0;
      vBB   # 0.0;
    end;

    $Lb.Stueck->wpcaption       # AInt("BAG.F.Stückzahl");
    $Lb.Gewicht->wpcaption      # ANum(BAG.F.Gewicht,"Set.Stellen.Gewicht");

    // Einsatz anzeigen
    $Lb.Guete.E->wpcaption      # "BAG.IO.Güte";
    $Lb.GuetenStufe.E->wpcaption # "BAG.IO.GütenStufe";;
    $Lb.AusfOben.E->wpcaption   # BAG.IO.AusfOben;
    $Lb.AusfUnten.E->wpcaption  # BAG.IO.AusfUnten;
    $Lb.Artikel.E->wpcaption    # BAG.IO.Artikelnr;
    $Lb.Dicke.E->wpcaption      # Cnvaf(BAG.IO.Dicke,_FmtNumNoGroup|_FmtNumNoZero ,0,"Set.Stellen.Dicke");
    $Lb.Breite.E->wpcaption     # ANum(BAG.IO.Breite,"Set.Stellen.Breite");
    $Lb.Dickentol.E->wpcaption  # BAG.IO.Dickentol;
    $Lb.Breitentol.E->wpcaption # BAG.IO.Breitentol;
    $Lb.Stueck.E->wpcaption     # AInt(BAG.IO.Plan.Out.Stk);
    $Lb.Gewicht.E->wpcaption    # ANum(BAG.IO.Plan.Out.GewN,"Set.Stellen.Gewicht");
    Erx # gMdi -> WinSearch('LB.RAD.E');
    if(Erx <> 0) then begin
      $LB.RAD.E->wpCaption # BA1_F_Data:BildeRADString();
    end;

    // Reste anzeigen
    $Lb.Breite.R->wpcaption     # ANum(BAG.IO.Breite - vBB,"Set.Stellen.Breite");
    $Lb.Gewicht.R->wpcaption    # ANum(BAG.IO.Plan.Out.GewN - vBGew,"Set.Stellen.Gewicht");
    if (BAG.IO.Breite-vBB<0.0) then $lb.Breite.R->wpColBkg # _WinColLightRed
    else $lb.Breite.R->wpColBkg # _WinColParent;
    if (BAG.IO.Plan.Out.GewN - vBGew<0.0) then $lb.Gewicht.R->wpColBkg # _WinColLightRed
    else $lb.Gewicht.R->wpColBkg # _WinColParent;


    // Prüfungen
    if (BAG.F.Kommission<>'') and (StrCut(BAG.F.Kommission,1,1)<>'#') then begin
      // Abmessungstest...
      if (BAG.F.Dicke<>0.0) and (Auf.P.Dicke<>0.0) and (Auf.P.Dicke<>BAG.F.Dicke) then begin
        $lbBAG.F.Dicke->wpColBkg # _WinColLightRed;
        end
      else begin
        $lbBAG.F.Dicke->wpColBkg # _WinColParent;
      end;

      if ("BAG.F.Gütenstufe"<>"Auf.P.GütenStufe") then $lb.GuetenStufe.A->wpColBkg # _WinColLightRed
      else $lb.GuetenStufe.A->wpColBkg # _WinColParent;
      if ("BAG.F.Güte"<>"Auf.P.Güte") then $lb.Guete.A->wpColBkg # _WinColLightRed
      else $lb.Guete.A->wpColBkg # _WinColParent;
      if (BAG.F.AusfOben<>Auf.P.AusfOben) then $lb.AusfOben.A->wpColBkg # _WinColLightRed
      else $lb.AusfOben.A->wpColBkg # _WinColParent;
      if (BAG.F.AusfUnten<>Auf.P.AusfUnten) then $lb.AusfUnten.A->wpColBkg # _WinColLightRed
      else $lb.AusfUnten.A->wpColBkg # _WinColParent;
      if (BAG.F.Breite<>Auf.P.Breite) then $lb.Breite.A->wpColBkg # _WinColLightRed
      else $lb.Breite.A->wpColBkg # _WinColParent;
      if (BAG.F.RID<>Auf.P.RID) then $lb.RID.A->wpColBkg # _WinColLightRed
      else $lb.RID.A->wpColBkg # _WinColParent;
      if (BAG.F.RIDmax<>Auf.P.RIDmax) then $lb.RIDmax.A->wpColBkg # _WinColLightRed
      else $lb.RIDmax.A->wpColBkg # _WinColParent;
      if (BAG.F.RAD<>Auf.P.RAD) then $lb.RAD.A->wpColBkg # _WinColLightRed
      else $lb.RAD.A->wpColBkg # _WinColParent;
      if (BAG.F.RADmax<>Auf.P.RADmax) then $lb.RADmax.A->wpColBkg # _WinColLightRed
      else $lb.RADmax.A->wpColBkg # _WinColParent;
    end;
  end;


  $Lb2.Guete.F->wpcaption      # "BAG.F.Güte";
  $Lb2.Dicke.F->wpcaption      # cnvaf(BAG.F.Dicke,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Dicke);
  $Lb2.Breite.F->wpcaption     # cnvaf(BAG.F.Breite,_FmtNumNoGroup|_FmtNumNoZero,0,Set.Stellen.Breite);
  $Lb2.Dickentol.F->wpcaption  # BAG.F.Dickentol;
  $Lb2.Breitentol.F->wpcaption # BAG.F.Breitentol;
  $Lb2.Guete.A->wpcaption      # $lb.Guete.A->wpcaption;;
  $Lb2.Dicke.A->wpcaption      # $lb.Dicke.A->wpcaption;
  $Lb2.Breite.A->wpcaption     # $lb.Breite.A->wpcaption;
  $Lb2.Dickentol.A->wpcaption  # $lb.Dickentol.A->wpcaption;
  $Lb2.Breitentol.A->wpcaption # $lb.Breitentol.A->wpcaption;
  $Lb2.Guete.E->wpcaption      # $lb.Guete.E->wpcaption;;
  $Lb2.Dicke.E->wpcaption      # $lb.Dicke.E->wpcaption;
  $Lb2.Breite.E->wpcaption     # $lb.Breite.E->wpcaption;
  $Lb2.Dickentol.E->wpcaption  # $lb.Dickentol.E->wpcaption;
  $Lb2.Breitentol.E->wpcaption # $lb.Breitentol.E->wpcaption;

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

/**
sub qwe()
begin
    BAG.F.Warengruppe # 100;
    BAG.F.Artikelnummer # 'qweeq';
    gMDi->winupdate();
end;
sub myinit()
begin
WinEvtProcNameSet(gMdi, _WinEvtTimer,here+':EvtTimer');
  w_Command # '';
  w_TimerVar # 'qwe';
  gTimer2 # SysTimerCreate(200,-1,gMdi);
end;

sub EvtTimer(
  aEvt                  : event;        // Ereignis
  aTimerID              : int;          // Timer-ID
): logic;
begin
  if (gTimer2=aTimerId) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
  RecBufClear(250);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung', here+':qwe');
  Lib_GuiCom:RunChildWindow(gMDI);
  end;
  RETURN true;
end;
***/

//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit();
local begin
  Erx       : int;
  vGegenID  : int;
  vTmp      : int;
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
//    Lib_GuiCom:Disable($edBAG.F.Artikelnummer); TEST PROJEKT 1332/67
//    Lib_GuiCom:Disable($bt.Artikel);
    Lib_GuiCom:Disable($edBAG.F.Streifenanzahl);
    Lib_GuiCom:Disable($edBAG.F.Dicke);
    Lib_GuiCom:Disable($edBAG.F.Dickentol);
    Lib_GuiCom:Disable($edBAG.F.Breite);
    Lib_GuiCom:Disable($edBAG.F.Breitentol);
    Lib_GuiCom:Disable($edBAG.F.RID);
    Lib_GuiCom:Disable($edBAG.F.RAD);
    Lib_GuiCom:Disable($edBAG.F.RADMax);
  end;


  // Gegenbuchung?
  if ($lb.GegenID->wpcustom<>'') then vGegenID # cnvia($lb.GegenID->wpCustom);

  if (Mode=c_ModeNew) then begin

//    Lib_GuiCom:Disable($bt.InternerText);

    if (vGegenID=0) then begin
      RecBufClear(703);
      BAG.F.Nummer    # BAG.P.Nummer;
      BAG.F.Position  # BAG.P.Position;
    end;

    if (w_AppendNr != 0) then begin
      BAG.F.Fertigung # w_AppendNr;
      RecRead( 703, 1, 0 );
      w_AppendNr # 0;
    end
    else begin
      BAG.F.Warengruppe     # BAG.IO.Warengruppe;
      BAG.F.MEH             # 'kg';
      "BAG.F.Güte"          # "BAG.IO.Güte";
      "BAG.F.KostenträgerYN"  # Set.BA.F.KostenTrgYN;
      Erx # RecLink(828,702,8,_RecFirst);   // Arbeitsgang holen
      if (Erx<=_rLocked) and (ArG.BAG.Warengruppe<>0) then
        BAG.F.Warengruppe     # ArG.BAG.Warengruppe;
    end;

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
  Erx         : int;
  vBuf703     : int;

  vBuf701In   : int;
  vBuf701Out  : int;
  vTmp        : int;

  vX          : float;
  vRID        : float;
  vMin,vMax   : float;
  vStk        : int;
  vGew        : float;
  vUnpassend  : int;
  vTlg        : Int;
  vGesStk     : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  vTmp # gMdi->Winsearch('NB.Main');

  // logische Prüfung...
  If (BAG.F.Warengruppe=0) then begin
    Msg(001200,Translate('Warengruppe'),0,0,0);
    vTmp->wpcurrent # 'NB.Page1';
    $edBAG.F.Warengruppe->WinFocusSet(true);
    RETURN false;
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

  if (BAG.F.AutomatischYN=n) then begin
    If (BAG.F.Streifenanzahl=0) then begin
      Msg(001200,Translate('Anzahl'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      $edBAG.F.Streifenanzahl->WinFocusSet(true);
      RETURN false;
    end;
    If (BAG.F.Breite=0.0) then begin
      Msg(001200,Translate('Breite'),0,0,0);
      vTmp->wpcurrent # 'NB.Page1';
      $edBAG.F.Breite->WinFocusSet(true);
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
  if (RunAFX('BAG.F.Spalt.RecSave','')<>0) then begin
    if (AfxRes<>_rOK) then RETURN false;
  end;


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
  BA1_F_Main:RecCleanup();
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
  vS    : int;
  vCalc : logic;
  vA    : alpha;
  vX    : int;
end;
begin

  if (aEvt:obj->wpname='edBAG.F.AusfOben') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|1');
  if (aEvt:obj->wpname='edBAG.F.AusfUnten') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|2');


  case (aEvt:Obj->wpname) of

    'xedBAG.F.Breitentol' : begin
      BAG.F.Breitentol # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Breitentol",Set.Stellen.Breite);
    end;


    'edBAG.F.Breite' : begin
      vCalc # y;
    end;


    'edBAG.F.Streifenanzahl' : begin
      vCalc # y;
    end;

  end;
/***
    if (BAG.IO.Breite<>0.0) then
      BAG.F.Gewicht # BAG.IO.Plan.In.GewN / BAG.IO.Breite * (BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl))
    else
      BAG.F.Gewicht # 0.0;

    "BAG.F.Stückzahl" # BAG.F.Streifenanzahl * BAG.IO.Plan.In.Stk * (BAG.IO.Teilungen+1);
***/
  if (vCalc) then begin
    BA1_F_Data:ErrechnePlanmengen(y,y,y);
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
  vA      : alpha;
  vFilter : int;
  vQ      : alpha(4000);
  vTmp    : int;
end;
begin

  case aBereich of
    'Kommission'  : begin
      BA1_F_Main:Auswahl(aBereich, here+':AusKommission');
    end;
    otherwise begin
      BA1_F_Main:Auswahl(aBereich);
    end;
  end;

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
//  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
//    gSelected # 0;
//    Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
//    if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then RETURN;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    "BAG.F.KostenträgerYN"  # y;
    //BA1_F_Data:AusKommission(Auf.P.Nummer, Auf.P.Position);
    BA1_F_Data:AusKommission(0,0,gSelected);
    gSelected # 0;
    BA1_F_Main:RefreshIfm(); // ETK Daten übernehmeb
    BA1_F_Data:ErrechnePlanmengen(y,y,y);
    gMDI->winUpdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edBAG.F.Streifenanzahl->Winfocusset(false);
  Refreshifm('edBAG.F.Kommission',y);
//$edBAG.F.Kommission->Winfocusset(false);
//  Refreshifm('edBAG.F.ReservFuerKunde');

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

  // ST 2012-08-30: Edit für 999 aktiviert 1326/284
  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

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
sub EvtClose(
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
  var aB    : float;
  var aGew  : float;
);
local begin
  Erx       : int;
  vBuf703   : int;

  vmyFert   : int;
  vX        : int;
  vA        : alpha;

  vHdl      : int;
  vBar      : int;
  vBarPos   : int;
  vBarFak   : float;
  vF        : float;
  vOK       : logic;

  vGegenID  : int;
end;

begin
  vBuf703 # RecBufCreate(703);
  RecBufCopy(703,vBuf703);
  vmyFert     # BAG.F.Fertigung;

  // Gegenbuchung?
  if ($lb.GegenID->wpcustom<>'') then vGegenID # cnvia($lb.GegenID->wpCustom);

  if (BAG.IO.Breite<>0.0) then
    vBarFak # 930.0 / BAG.IO.Breite;
  vBarPos # 8;

  vBar # 1;
  // bisherige Fertigungen DAZU addieren
  Erx # RecLink(703,702,4,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    // Restcoils überspringen
    if (BAG.F.Fertigung=999) then begin
      Erx # RecLink(703,702,4,_recNext);
      CYCLE;
    end;

    vHdl # 0;
    if (BAG.F.Fertigung<>vmyFert) then begin

      // Gegenbuchung???
      if (RecInfo(703,_recid)=vGegenID) then begin
        if (BAG.P.Aktion=c_BAG_Spalt) and (BAG.F.StreifenAnzahl=1) then
          BAG.F.Breite          # BAG.F.Breite  - (vBuf703->BAG.F.Breite * cnvfi(vBuf703->BAG.F.Streifenanzahl))
        else
          BAG.F.Streifenanzahl  # BAG.F.Streifenanzahl  - (vBuf703->BAG.F.Streifenanzahl);
        BAG.F.Gewicht         # BAG.F.Gewicht         - (vBuf703->BAG.F.Gewicht);
      end;

      aB    # aB   + (BAG.F.Breite * cnvfi(BAG.F.Streifenanzahl));
      aGew  # aGew + BAG.F.Gewicht;
      vHdl # Winsearch(gMdi,'bar.E'+cnvai(vBar));
      vBar # vBar + 1;
      end
    else begin
      vOK # y;
      BAG.F.Breite          # vBuf703->BAG.F.Breite;
      BAG.F.Streifenanzahl  # vBuf703->BAG.F.Streifenanzahl;
      vHdl # Winsearch(gMdi,'bar.Plan');
    end;

    if (vHdl<>0) then begin
      vHdl->wparealeft  # vBarPos;
      vX # cnvif( cnvfi(BAG.F.Streifenanzahl) * BAG.F.Breite * vBarFak );
      vHdl->wparearight # vBarPos + vX;
      vHdl->wpcaption # AInt(BAG.F.Streifenanzahl)+' * '+ANum(BAG.F.Breite,"Set.Stellen.Breite");
      vHdl->wpvisible # true;
      vBarPos # vBarPos + vX;
    end;

    Erx # RecLink(703,702,4,_recNext);
  END;

  if (vOK=n) then begin
    vHdl # Winsearch(gMdi,'bar.Plan');
    vHdl->wparealeft  # vBarPos;
    vX # cnvif( cnvfi(vBuf703->BAG.F.Streifenanzahl) * vBuf703->BAG.F.Breite * vBarFak );
    vHdl->wparearight # vBarPos + vX;
    vHdl->wpcaption # AInt(vBuf703->BAG.F.Streifenanzahl)+' * '+ANum(vBuf703->BAG.F.Breite,"Set.Stellen.Breite");
    vHdl->wpvisible # true;
    vBarPos # vBarPos + vX;
  end;

  vHdl # Winsearch(gMdi,'bar.frei');
  vHdl->wparealeft  # vBarPos;
  vHdl->wparearight # 930+8;
  vHdl->wpcaption   # ANum(BAG.IO.Breite - aB,"Set.Stellen.Breite");
  vHdl->wpvisible   # true;
  if (BAG.IO.Breite - aB<0.0) then $bar.Plan->wpColBkg # _wincollightred
  else $bar.Plan->wpColBkg # _WinColLightYellow;

  $bar.all->wpcaption # 'gesamt '+ANum(BAG.IO.Breite,"Set.Stellen.Breite");



  RecBufCopy(vBuf703,703);    // RESTORE
  RecBufDestroy(vBuf703);

  aGew  # Rnd(aGew,0);
  aB    # Rnd(aB,2);

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
    RecRead(843,2,0);
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
    todo('Kundenartnr')
    //RekLink(100,703,7,0);   // Kundenartikel holen
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