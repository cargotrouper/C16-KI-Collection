@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_F_QTeil_Main
//                    OHNE E_R_G
//  Info
//
//
//  18.08.2015  AH  Erstellung der Prozedur
//  29.11.2019  AH  Funktionen zentralisiert in BA1_F_Main
//  05.04.2022  AH  ERX
//  19.07.2022  HA  Quick Jump
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
//    SUB AusVerpackung()
//    SUB AusArtikel()
//    SUB AusStruktur()
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
  cDialog :   $BA1.F.QTeil.Maske
  cTitle :    'Querteil-Fertigung'
  cFile :     703
  cMenuName : 'BA1.F.Bearbeiten'
  cPrefix :   'BA1_F_QTeil'
  cKey :      1

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
  Erx : int;
  va  : alphA;
  vX  : int;

  vBB   : float;
  vBL   : float;
  vL    : float;
  vGew  : float;
  vM    : float;
  vOk   : logic;
  vTmp  : int;
end;
begin

  if (aName='edBAG.F.Dickentol') then begin
    BAG.F.Dickentol # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Dickentol",Set.Stellen.Dicke);
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

    // Einsatz anzeigen
    $Lb.Guete.E->wpcaption      # "BAG.IO.Güte";
    $Lb.GuetenStufe.E->wpcaption # "BAG.IO.GütenStufe";
    $Lb.AusfOben.E->wpcaption   # BAG.IO.AusfOben;
    $Lb.AusfUnten.E->wpcaption  # BAG.IO.AusfUnten;
    $Lb.Artikel.E->wpcaption    # BAG.IO.Artikelnr;
    $Lb.Dicke.E->wpcaption      # ANum(BAG.IO.Dicke,Set.Stellen.Dicke);
    $Lb.Breite.E->wpcaption     # ANum(BAG.IO.Breite,Set.Stellen.Breite);
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
    $Lb.Gewicht.E->wpcaption    # ANum(BAG.IO.Plan.Out.GewN,Set.Stellen.Gewicht);
//    $Lb.Menge.E->wpcaption      # Cnvaf(BAG.IO.Plan.In.Menge,_FmtNumNoGroup);
    Erx # gMdi -> WinSearch('LB.RAD.E');
    if(Erx <> 0) then begin
        $LB.RAD.E->wpCaption # BA1_F_Data:BildeRADString();
    end;
  end;


  if ((aName='edBAG.F.Kommission') and (($edBAG.F.Kommission->wpchanged) or (aChanged))) then begin
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
    $Lb.Dicke.A->wpcaption      # '';
    $Lb.Breite.A->wpcaption     # '';
    $Lb.Laenge.A->wpcaption     # '';
    $Lb.Stueck.A->wpcaption     # '';
    $Lb.Gewicht.A->wpcaption    # '';
//    $Lb.Menge.A->wpcaption      # '';
    $Lb.Dickentol.A->wpcaption  # '';
    $Lb.Breitentol.A->wpcaption # '';
    $Lb.Laengentol.A->wpcaption # '';

    // 15.03.2013:
    if (BAG.F.AuftragsNummer<>0) then begin
      Erx # Auf_data:Read(BAG.F.Auftragsnummer, BAG.F.Auftragspos,n);
      if (Erx<400) then RecBufClear(401);
      // Stücklistenfertigung???
      if (BAG.F.Auftragsfertig<>0) then begin
        Auf.SL.Nummer   # BAG.F.AuftragsNummer;
        Auf.SL.Position # BAG.F.AuftragsPos;
        Auf.SL.LfdNr    # BAG.F.Auftragsfertig;
        Erx # RecRead(409,1,0);
        if (Erx<=_rLocked) then begin
          Auf.P.Dicke         # Auf.SL.Dicke;
          Auf.P.Breite        # Auf.SL.Breite;
          "Auf.P.Länge"       # "Auf.SL.Länge"
          "Auf.P.Stückzahl"   # "Auf.SL.Stückzahl";
          Auf.P.Gewicht       # Auf.SL.Gewicht;
          Auf.P.Prd.Plan.Gew  # Auf.SL.Prd.Plan.Gew;
        end;
      end;

      $Lb.Guete.A->wpcaption      # "Auf.P.Güte";
      $Lb.GuetenStufe.A->wpcaption      # "Auf.P.GütenStufe";
      $Lb.AusfOben.A->wpcaption   # Auf.P.AusfOben;
      $Lb.AusfUnten.A->wpcaption  # Auf.P.AusfUnten;
      $Lb.Artikel.A->wpcaption    # Auf.P.Artikelnr;
      $Lb.Dickentol.A->wpcaption  # Auf.P.Dickentol;
      $Lb.Breitentol.A->wpcaption # Auf.P.Breitentol;
      $Lb.Laengentol.A->wpcaption # "Auf.P.Längentol";
      if (Auf.P.Dicke<>0.0) then
        $Lb.Dicke.A->wpcaption      # ANum(Auf.P.Dicke,Set.Stellen.Dicke);
      if (Auf.P.Breite<>0.0) then
        $Lb.Breite.A->wpcaption     # ANum(Auf.P.Breite,Set.Stellen.Breite);
      if ("Auf.P.Länge"<>0.0) then
        $Lb.Laenge.A->wpcaption     # ANum("Auf.P.Länge","Set.Stellen.Länge");
      if ("Auf.P.Stückzahl"-Auf.P.Prd.PLan.Stk>0) then
        $Lb.Stueck.A->wpcaption     # AInt("Auf.P.Stückzahl"-Auf.P.Prd.PLan.Stk);
      if (Auf.P.Gewicht-Auf.P.Prd.Plan.Gew>0.0) then
        $Lb.Gewicht.A->wpcaption    # ANum(Auf.P.Gewicht-Auf.P.Prd.Plan.Gew,Set.Stellen.Gewicht);

/*
      if ("Auf.P.Stückzahl"-Auf.P.Prd.Plan.Stk>0) then begin
        $Lb.Menge.A->wpcaption    # cnvaf(Auf.P.Breite * "Auf.P.Länge" / 1000000.0 * Cnvfi(("Auf.P.Stückzahl"-Auf.P.Prd.Plan.Stk)) ,_FmtNumNoGroup);
        end
      else begin
        $lb.Menge.A->wpcaption    # '0,00';
      end;
*/
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


  RunAFX('BAG.F.Div.RefreshIfm.Post',aName);
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

  // ST 2012-08-30: Bei Änderung von Restcoilbearbeitungen/oder Autoanlage
  if (mode=c_ModeEdit) and ((BAG.F.AutomatischYN) and (Bag.F.Fertigung=999)) then begin
    Lib_GuiCom:Disable($cbBAG.F.PlanSchrottYN);
    Lib_GuiCom:Disable($edBAG.F.Guetenstufe);
    Lib_GuiCom:Disable($bt.Guetenstufe);
    Lib_GuiCom:Disable($edBAG.F.Guete);
    Lib_GuiCom:Disable($bt.Guete);
    Lib_GuiCom:Disable($edBAG.F.AusfOben);
    Lib_GuiCom:Disable($bt.AusfOben);
    Lib_GuiCom:Disable($edBAG.F.AusfUnten);
    Lib_GuiCom:Disable($bt.AusfUnten);
    Lib_GuiCom:Disable($edBAG.F.Dicke);
    Lib_GuiCom:Disable($edBAG.F.Dickentol);
    Lib_GuiCom:Disable($edBAG.F.Breite);
    Lib_GuiCom:Disable($edBAG.F.Breitentol);
    Lib_GuiCom:Disable($edBAG.F.Laenge);
    Lib_GuiCom:Disable($edBAG.F.Laengentol);
    Lib_GuiCom:Disable($edBAG.F.RID);
    Lib_GuiCom:Disable($edBAG.F.RIDMax);
    /*
    Lib_GuiCom:Disable($edBAG.F.RAD);
    Lib_GuiCom:Disable($edBAG.F.RADMax);
    */
  end;


  if (Mode=c_ModeNew) then begin
    RecBufClear(703);
    BAG.F.Nummer    # BAG.P.Nummer;
    BAG.F.Position  # BAG.P.Position;

    if (w_AppendNr != 0) then begin
      BAG.F.Fertigung # w_AppendNr;
      RecRead( 703, 1, 0 );
      w_AppendNr # 0;
    end
    else begin
      BAG.F.Warengruppe     # BAG.IO.Warengruppe;
      BAG.F.MEH             # 'kg';
      "BAG.F.Güte"          # "BAG.IO.Güte";
      BAG.F.Streifenanzahl  # 1;
      BAG.F.Block           # ''
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
  Erx     : int;
  vBuf703 : int;
  vTmp    : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  vTmp # gMdi->Winsearch('NB.Main');

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

  if (BA1_F_Main:RecSave(Mode)=false) then RETURN false;
//  Mode # c_modeCancel;  // sofort alles beenden!
  RETURN true;  // Speichern erfolgreich

/*** 29.11.2019 AH: in BA1_F_Main:RecSave
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


    // 1zu1 Arbeitsgang? ========================================
    if ("BAG.P.Typ.1In-1OutYN") then begin
      if (BAG.F.Fertigung<>1999) then begin    // allgem. Fertigung
        end
      else begin                              // spez. Fertigung
        BAG.F.Fertigung # 1;
        WHILE (RecRead(703,1,_RecTest)<=_rLocked) do
          BAG.F.Fertigung # BAG.F.Fertigung + 1;

        // Einsatz auf diese Fertigung umbiegen
        RecRead(701,0,0,w_AppendNr);
        vBuf703 # RecBufcreate(703);
        RecBufCopy(703,vBuf703);
        RecLink(703,701,10,_recFirst);
        if (BA1_F_Data:UpdateOutput(701,y)=false) then begin // erstmal löschen!!!
          TRANSBRK;
          ERROROUTPUT;  // 01.07.2019
          Msg(701003,gTitle,0,0,0);
          RETURN False;
        end;
        RecBufCopy(vBuf703, 703);
        RecbufDestroy(vBuf703);

        RecRead(701,0,_RecLock,w_AppendNr);
        BAG.IO.NachFertigung # BAG.F.Fertigung;
        Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          Msg(701003,gTitle,0,0,0);
          RETURN False;
        end;
      end;

    end
    // XzuY Arbeitsgang ==========================================
    else begin
      BAG.F.Fertigung # 1;
      WHILE (RecRead(703,1,_RecTest)<=_rLocked) do
        BAG.F.Fertigung # BAG.F.Fertigung + 1;
    end;

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
***/
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

  case (aEvt:Obj->wpname) of
  end;  // case

  if (StrCnv(BAG.F.MEH,_StrUpper)='KG') then  BAG.F.Menge # Rnd(BAG.F.Gewicht,Set.Stellen.Menge);
  if (StrCnv(BAG.F.MEH,_StrUpper)='T') then   BAG.F.Menge # Rnd(BAG.F.Gewicht / 1000.0,Set.Stellen.Menge);
  if (StrCnv(BAG.F.MEH,_StrUpper)='STK') then BAG.F.Menge # CnvFI("BAG.F.Stückzahl");

//    RecalcRest();

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

  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  Refreshifm('edBAG.F.Kommission',y);

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
    vHdl->wpDisabled # (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
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


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, BAG.F.Anlage.Datum, BAG.F.Anlage.Zeit, BAG.F.Anlage.User );
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
    todo('Kundenartnr')
    //RekLink(100,703,7,0);   // Kundenartikel holen
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