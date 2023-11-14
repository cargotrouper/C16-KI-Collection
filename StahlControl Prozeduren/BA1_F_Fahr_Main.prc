@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_F_Fahr_Main
//                  OHNE E_R_G
//  Info
//
//
//  15.03.2004  AI  Erstellung der Prozedur
//  27.07.2021  AH  ERX
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
  cDialog :   $BA1.F.Fahr.Maske
  cTitle :    'Fahrauftrag Fertigung'
  cFile :     703
  cMenuName : 'BA1.F.Bearbeiten'
  cPrefix :   'BA1_F_Fahr'
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
  SetStdAusFeld('edBAG.F.Verpackung'      ,'Verpackung');
  SetStdAusFeld('edBAG.F.Guete'           ,'Guete');
  SetStdAusFeld('edBAG.F.Guetenstufe'     ,'Guetenstufe');
  SetStdAusFeld('edBAG.F.AusfOben'        ,'AF.Oben');
  SetStdAusFeld('edBAG.F.AusfUnten'       ,'AF.Unten');

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
  va : alphA;
  vX : int;

  vBB   : float;
  vBL   : float;
  vL    : float;
  vGew  : float;
  vM    : float;
  vOk : logic;
  vTmp : int;
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
    $Lb.Dicke.E->wpcaption      # ANum(BAG.IO.Dicke, Set.Stellen.Dicke);
    $Lb.Breite.E->wpcaption     # ANum(BAG.IO.Breite, Set.Stellen.Breite);
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
    $Lb.AusfOben.A->wpcaption   # '';
    $Lb.AusfUnten.A->wpcaption  # '';
    $Lb.Dicke.A->wpcaption      # '';
    $Lb.Breite.A->wpcaption     # '';
    $Lb.Laenge.A->wpcaption     # '';
    $Lb.Stueck.A->wpcaption     # '';
    $Lb.Gewicht.A->wpcaption    # '';
//    $Lb.Menge.A->wpcaption      # '';
    $Lb.Dickentol.A->wpcaption  # '';
    $Lb.Breitentol.A->wpcaption # '';
    $Lb.Laengentol.A->wpcaption # '';
    if (BAG.F.AuftragsNummer<>0) then begin
      Erx # Auf_Data:Read(BAG.F.Auftragsnummer, BAG.F.AuftragsPos, y);
      $Lb.Guete.A->wpcaption      # "Auf.P.Güte";
      $Lb.AusfOben.A->wpcaption   # Auf.P.AusfOben;
      $Lb.AusfUnten.A->wpcaption  # Auf.P.AusfUnten;
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
    BAG.F.Kommission  # Translate('RESTCOIL');
    "BAG.F.Länge"     # 0.0;
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
      BAG.F.Streifenanzahl  # 0;
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
  vKLim   : float;
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
  end;


  // logische Prüfung
  if (BAG.F.Kommission <> '') then begin
    Erx # RecLinkInfo(401, 703, 9, _recCount);
    if(Erx = 0) then begin
      Msg(001200,BAG.F.Kommission  + ' ' + Translate('Kommission'),0,0,0);
      vTmp->wpcurrent # 'NB.Main';
      $edBAG.F.Kommission->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(400,401,3,_recFirst);   // AufKopf holen
    if (Auf.PAbrufYN) then begin
      Msg(400042,'',0,0,0);
      vTmp->wpcurrent # 'NB.Main';
      $edBAG.F.Kommission->WinFocusSet(true);
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


  // Kreditlimit prüfen...
  if (Mode=c_ModeNew) and ("Set.KLP.LFA-Druck"<>'') then begin
    Erx # RecLink(401,703,9,_RecFirst);     // Auftragspos holen
    if (Erx<=_rLockeD) then begin
      Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
      if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then Erx # _rNoRec;
    end;
    if (Erx<=_rLocked) then begin
      Erx # RecLink(400,401,3,0);           // Auftragskopf holen
      if (Erx<=_rLocked) then
        if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.LFA-Druck",n, var vKLim,0, Auf.Nummer)=false) then RETURN false;
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


    // 1zu1 Arbeitsgang? ========================================
    if ("BAG.P.Typ.1In-1OutYN") then begin
      if (BAG.F.Fertigung<>3999) then begin    // allgem. Fertigung
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

  if (aEvt:obj->wpchanged) then begin
    case (aEvt:Obj->wpname) of

      'edBAG.F.Dicke' : begin
        "BAG.F.Stückzahl"   # 0;
        BAG.F.Menge         # 0.0;
        BAG.F.Gewicht       # 0.0;
        $edBAG.F.Menge->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        RefreshIfm();
      end;

      'edBAG.F.Breite' : begin
        "BAG.F.Stückzahl"   # 0;
        BAG.F.Menge         # 0.0;
        BAG.F.Gewicht       # 0.0;
        $edBAG.F.Menge->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        RefreshIfm();
      end;

      'edBAG.F.Laenge': begin
        "BAG.F.Stückzahl"   # 0;
        BAG.F.Menge         # 0.0;
        BAG.F.Gewicht       # 0.0;
        $edBAG.F.Menge->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        RefreshIfm();
      end;


      'edBAG.F.Stueckzahl' : begin
        if (BAG.F.Gewicht=0.0) then begin
          RecLink(819,703,5,_recFirst);   // Warengruppe holen
          BAG.F.Gewicht # Lib_Berechnungen:kg_aus_StkDBLDichte2("BAG.F.Stückzahl", BAG.F.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 703), "Wgr.TränenKgProQM");
          $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        end;

        if (BAG.F.Menge=0.0) then begin
//          BAG.F.Menge # BAG.F.Breite * Cnvfi("BAG.F.Stückzahl") * "BAG.F.Länge" / 1000000.0;
//          $edBAG.F.Menge->winupdate(_WinUpdFld2Obj);
        end;

        RefreshIfm();
      end;


      'edBAG.F.Gewicht' : begin
        if ("BAG.F.Stückzahl"=0) then begin
          RecLink(819,703,5,_recFirst);   // Warengruppe holen
          "BAG.F.Stückzahl" # Lib_Berechnungen:Stk_aus_kgDBLDichte2(BAG.F.Gewicht, BAG.F.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 703), "Wgr.TränenKgProQM");
          vS # "BAG.F.Stückzahl";
          $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        end;

        if (BAG.F.Menge=0.0) then begin
//          BAG.F.Menge # BAG.F.Breite * Cnvfi(vS) * "BAG.F.Länge" / 1000000.0;
//          $edBAG.F.Menge->winupdate(_WinUpdFld2Obj);
        end;

        RefreshIfm();
      end;


      'edBAG.F.Menge' : begin
      end;

    end;

    if (StrCnv(BAG.F.MEH,_StrUpper)='KG') then  BAG.F.Menge # BAG.F.Gewicht;
    if (StrCnv(BAG.F.MEH,_StrUpper)='T') then   BAG.F.Menge # BAG.F.Gewicht / 1000.0;
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
  vA      : alpha;
  vFilter : int;
  vQ      : alpha(4000);
  vTmp    : int;
end;

begin

  case aBereich of

    'Kommission'  : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
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

    'Verpackung'  : begin
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
  $edBAG.F.Kommission->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  Refreshifm('edBAG.F.Kommission',y);

end;


//========================================================================
//  AusWgr
//
//========================================================================
sub AusWgr()
begin
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
//  AusGuete
//
//========================================================================
sub AusGuete()
begin
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
    vHdl->wpDisabled # y;
    //(vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
    //                    (BAG.P.Typ.VSBYN);
  vHdl # gMenu->WinSearch('Mnu.New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
    //(vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
    //                    (BAG.P.Typ.VSBYN);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Edit2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
    //(BAG.F.AutomatischYN) or
    //  (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
    //(BAG.F.AutomatischYN) or
    //  (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

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
    todo('Guetenstufe')
    // RekLink(819,200,1,0);   // Güte holen
    MQu.S.Stufe # "BAG.F.Gütenstufe";
    RecRead(848,1,0);
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edBAG.F.Guete') AND (aBuf->"BAG.F.Güte"<>'')) then begin
    todo('Guete')
    // RekLink(819,200,1,0);   // Güte holen
    "MQu.Güte1" # "BAG.F.Güte";
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
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
    RecRead(105,2,20);
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