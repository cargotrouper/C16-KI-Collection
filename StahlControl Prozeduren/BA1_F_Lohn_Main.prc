@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_F_Lohn_Main
//                    OHNE E_R_G
//  Info
//
//
//  21.05.2010  AI  Erstellung der Prozedur
//  21.03.2011  ST  Restbreitenberechnung für SPaltaufträge
//  10.10.2012  AI  Haken "WirdEigen" steuert Kommission
//  22.11.2012  ST  Längenberechnung für "Abtafeln" Projekt 1357/103
//  23.05.2016  ST  Leerung der Kundenartikelvorgabe bei "WirdEigenMat" abgestellt
//  16.02.2021  AH  Neu AFX "BA1.F.Init.Pre"
//  27.07.2021  AH  ERX
//  19.07.2022  HA  Quick Jump
//  2022-12-20  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusKundenArtNr()
//    SUB AusKundenArtNr2()
//    SUB AusWgr()
//    SUB AusVerpackung()
//    SUB AusGuete()
//    SUB AusGuetenstufe()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB SummiereEinsatz();
//    SUB SummiereFertigungen();
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle      : 'Fertigungen'
  cFile       :  703
  cMenuName   : 'BA1.F.Lohn.Bearbeiten'
  cPrefix     : 'BA1_F_Lohn'
  cZList      : $ZL.BA1.F.Lohn
  cKey        : 1
end;

global Restdaten begin
  gEinsatzGewicht : float;
  gEinsatzBreite  : float;
  gEinsatzLaenge  : float;
  gFertigungGewicht : float;
  gFertigungBreite  : float;
  gFertigungLaenge  : float;

end;

declare SummiereEinsatz();      // momentan nicht benutzt
declare SummiereFertigungen(opt aOhneBaFert : int)

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin

  begin // ST 2010-06-30: Anzeige der Restwerte
    // Restdaten aus Einsätzen und Fertigungen berechnen
    VarAllocate(Restdaten);
    SummiereEinsatz();
//    SummiereFertigungen();
  end;

  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edBAG.F.Warengruppe);
Lib_Guicom2:Underline($edBAG.F.KundenArtNr);
Lib_Guicom2:Underline($edBAG.F.Verpackung);
Lib_Guicom2:Underline($edBAG.F.Guete);

  SetStdAusFeld('edBAG.F.KundenArtNr'    ,'Kundenartnr');
  SetStdAusFeld('edBAG.F.Warengruppe'    ,'Wgr');
  SetStdAusFeld('edBAG.F.Verpackung'     ,'Verpackung');
  SetStdAusFeld('edBAG.F.Guete'          ,'Guete');
  SetStdAusFeld('edBAG.F.Guetenstufe'    ,'Guetenstufe');
  SetStdAusFeld('edBAG.F.AusfOben'       ,'AF.Oben');
  SetStdAusFeld('edBAG.F.AusfUnten'      ,'AF.Unten');

  RunAFX('BAG.F.Lohn.Init.Pre',aint(aEvt:Obj)); // 16.02.2021 AH
  App_Main:EvtInit(aEvt);

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
  //Lib_GuiCom:Pflichtfeld($);
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
  vRest : float;
  vTmp  : int;
end;
begin

//  if (aName='') then
//    Lib_GuiCom:able($bt.InternerText, (Mode<>c_ModeNew) and (Mode<>c_ModeEdit));


  if (aName='') then begin
    vA # Auf.P.MEH.Einsatz;   // 2022-12-19 AH     BA1_P_Data:ErmittleMEH();
    $lb.MEH->wpcaption # vA;
    if ((Mode=c_ModeNew) or (Mode=c_ModeEdit)) then begin
      if (vA='Stk') or (vA='kg') or (vA='t') then
        Lib_GuiCom:Disable($edBAG.F.Menge)
      else
        Lib_GuiCom:Enable($edBAG.F.Menge);
    end;
  end;

  if (aName='edBAG.F.Dickentol') then begin
    BAG.F.Dickentol # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Dickentol",Set.Stellen.Dicke);
  end;

  if (aName='edBAG.F.Breitentol') then begin
    BAG.F.Breitentol # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Breitentol",Set.Stellen.Breite);
  end;

  if (aName='edBAG.F.Laengentol') then begin
    "BAG.F.Längentol" # Lib_Berechnungen:Toleranzkorrektur("BAG.F.Längentol","Set.Stellen.Länge");
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

  if (aName='') or (aName='edBAG.F.Verpackung') then begin
    Erx # RecLink(704,703,6,0);
    if (Erx<=_rLocked) then
      $Lb.Verpackung->wpcaption # BAG.Vpg.VpgText1
    else
      $Lb.Verpackung->wpcaption # '';

    // ETK Felder Aktuallisieren
    BA1_F_Main:RefreshIfm('edBAG.F.Verpackung');
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;


  // Gesamtbreite beim Spalten errechnen
  // Bei "Spalten" ist die Stückzahl nicht relevant
  if (BAG.P.Aktion = c_BAG_Spalt) then begin
    Lib_GuiCom:Disable($edBAG.F.Stueckzahl);

    // Momentan vorhandene Restdaten errechnen
    SummiereEinsatz();
    SummiereFertigungen(Bag.F.Fertigung);
    vA # Translate('Einsatzbreite: ') + ANum(gEinsatzbreite,Set.Stellen.Breite);
    vRest # gEinsatzbreite - gFertigungbreite - (CnvFI(BAG.F.Streifenanzahl) * BAG.F.Breite);
    vA # vA + ' '+ Translate('Rest : ') + ANum(vRest,Set.Stellen.Breite);
    $Lb.Einsatzdaten->wpCaption #  vA;

  end;


  // Gesamtlängen beim Abcoilen errechnen
  if (BAG.P.Aktion = c_BAG_AbCoil) then begin
    // Momentan vorhandene Restdaten errechnen
    SummiereEinsatz();
    SummiereFertigungen(Bag.F.Fertigung);

    vA # Translate('Einsatzlänge: ');
    if (Abs(gEinsatzlaenge) > 1000.0) then
      vA # vA +  ANum(gEinsatzlaenge/1000.0,"Set.Stellen.Länge") +' '+ Translate('m');
    else
      vA # vA +  ANum(gEinsatzlaenge,"Set.Stellen.Länge") +' '+ Translate('mm');

    vRest # gEinsatzlaenge - gFertigungLaenge - (CnvFI("BAG.F.Stückzahl") * "BAG.F.Länge");
    vA # vA + '  ' + Translate('Rest : ');

    if (Abs(vRest) > 1000.0) then
      vA # vA + ANum(vRest/1000.0,"Set.Stellen.Länge") +' '+ Translate('m');
    else
      vA # vA + ANum(vRest,"Set.Stellen.Länge") +' '+  Translate('mm');

    $Lb.Einsatzdaten->wpCaption #  vA;
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
  vRest : float;
end
begin

  if (RunAFX('BAG.F.Lohn.RecInit','')<0) then RETURN;

  if (mode=c_ModeNew) then begin
    RecBufClear(703);
    BAG.F.Nummer            # BAG.P.Nummer;
    BAG.F.Position          # BAG.P.Position;
    BAG.F.Warengruppe       # BAG.IO.Warengruppe;
    BAG.F.MEH               # Auf.P.MEH.Einsatz;    // 2022-12-19 AH   BA1_P_Data:ErmittleMEH();
    "BAG.F.Güte"            # "BAG.IO.Güte";
    BAG.F.Streifenanzahl    # 1;
    BAG.F.Block             # ''

    BAG.F.Kommission        # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position);
    BAG.F.Auftragsnummer    # Auf.P.Nummer;
    BAG.F.Auftragspos       # Auf.P.Position;
    "BAG.F.ReservFürKunde"  # Auf.P.Kundennr;
    BAG.F.KundenArtNr       # Auf.P.KundenArtNr;
    "BAG.F.KostenträgerYN"  # y;
    Erx # RecLink(828,702,8,_RecFirst);   // Arbeitsgang holen
    if (Erx<=_rLocked) and (ArG.BAG.Warengruppe<>0) then
      BAG.F.Warengruppe     # ArG.BAG.Warengruppe;

    BAG.F.Fertigung # 1;
    WHILE (RecRead(703,1,_RecTest)<=_rLocked) do
      BAG.F.Fertigung # BAG.F.Fertigung + 1;
  end;
/*** 06.07.2017 AH
  if (Mode=c_ModeEdit) then begin
    if (BA1_P_Data:DelAllVSB() = false) then begin
      ErrorOutput;
      RETURN;
    end;
  end;
***/

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

/*
  // Bei "Spalten" ist die Stückzahl nicht relevant
  if (BAG.P.Aktion = c_BAG_Spalt) then begin
    Lib_GuiCom:Disable($edBAG.F.Stueckzahl);

    // Momentan vorhandene Restdaten errechnen
    SummiereEinsatz();
    SummiereFertigungen();
    vA # 'Einsatzbreite: ' + ANum(gEinsatzbreite,Set.Stellen.Breite);
    vRest # gEinsatzbreite - gFertigungbreite;
    vA # vA + ' Rest : ' + ANum(vRest,Set.Stellen.Breite);
    $Lb.Einsatzdaten->wpCaption #  vA;

  end;
*/
  RefreshIfm();

  // Focus setzen auf Feld:
  $edBAG.F.Warengruppe->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vBuf702 : int;
  vBuf703 : int;
  vBuf401 : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  // 10.10.2012 AI
  if (BAG.F.WirdEigenYN=false) then begin
    BAG.F.Kommission        # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position);
    BAG.F.Auftragsnummer    # Auf.P.Nummer;
    BAG.F.Auftragspos       # Auf.P.Position;
    "BAG.F.ReservFürKunde"  # Auf.P.Kundennr;
    //  BAG.F.KundenArtNr       # Auf.P.KundenArtNr;    // ST 2016-05-23: Deaktiviert, KndArtNr über Fertigung
    "BAG.F.KostenträgerYN"  # y;
    end
  else begin
    BAG.F.Kommission        # ''
    BAG.F.Auftragsnummer    # 0;
    BAG.F.Auftragspos       # 0;
    "BAG.F.ReservFürKunde"  # 0;
    // BAG.F.KundenArtNr       # '';  // ST 2016-05-23: Deaktiviert, KndArtNr kann eigene Verpackung sein
    "BAG.F.KostenträgerYN"  # y;
  end;


  vBuf702 # Reksave(702);
  vBuf703 # Reksave(703);
  vBuf401 # Reksave(401);

  TRANSON;

  if (BA1_F_Main:RecSave(Mode)=false) then begin
    TRANSBRK;
    RekRestore(vBuf702);
    RecRead(702, 1, 0);
    RekRestore(vBuf703);
    RecRead(703, 1, 0);
    RekRestore(vBuf401);
    RecRead(401, 1, 0);
    RETURN false;
  end;

  if (BA1_Lohn_Subs:AutoVSB(BAG.F.Nummer, BAG.F.Position)=false) then begin
    TRANSBRK;
    ErrorOutput;
    RekRestore(vBuf702);
    RecRead(702, 1, 0);
    RekRestore(vBuf703);
    RecRead(703, 1, 0);
    RekRestore(vBuf401);
    RecRead(401, 1, 0);
    RETURN false;
  end;

  TRANSOFF;

  RekRestore(vBuf702);
  RecRead(702,1,0);
  RekRestore(vBuf703);
  RecRead(703,1,0);
  RekRestore(vBuf401);
  RecRead(401, 1, 0);

  //Mode # c_modeCancel;  // sofort alles beenden!
  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin

  if (Mode=c_ModeNew) then begin
    BA1_F_Main:RecCleanUp();
  end;

  if (Mode=c_ModeEdit) then begin
    if (BA1_Lohn_Subs:AutoVSB(BAG.F.Nummer, BAG.F.Position)=false) then begin
      ErrorOutput;
      RETURN false;
    end;
  end;

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx     : int;
  vBuf702 : int;
  vBuf703 : int;
  vBuf401 : int;
end;
begin

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    vBuf702 # Reksave(702);
    vBuf703 # RekSave(703);
    vBuf401 # RekSave(401);

    TRANSON;

    if (BA1_Lohn_Subs:DeleteAutoVSB(BAG.F.Nummer, BAG.F.Position)=false) then begin
//debug('Fehler beim Löschen von AutoVSB');
      TRANSBRK;
      RekRestore(vBuf702);
      RecRead(702, 1, 0);
      RekRestore(vBuf703);
      RecRead(703, 1, 0);
      RekRestore(vBuf401);
      RecRead(401, 1, 0);
      ErrorOutput;
      RETURN;
    end;


    // Fertigmaterial löschen
    if (BA1_F_Data:UpdateOutput(703,true)=false) then begin
//debug('Fehler beim Löschen von Fertigmaterial');
      TRANSBRK;
      ERROROUTPUT;  // 01.07.2019
      RekRestore(vBuf702);
      Recread(702, 1, 0);
      RekRestore(vBuf703);
      Recread(703, 1, 0);
      RekRestore(vBuf401);
      RecRead(401, 1, 0);
      RETURN;
    end;

    // Ausführungen löschen...
    Erx # RecLink(705,703,8,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(705,0,'MAN');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RekRestore(vBuf702);
        Recread(702, 1, 0);
        RekRestore(vBuf703);
        Recread(703, 1, 0);
        RekRestore(vBuf401);
        RecRead(401, 1, 0);
        RETURN;
      end;
      Erx # RecLink(705,703,8,_recFirst);
    END;

    if (RekDelete(703,0,'MAN')<>_rOK) then begin
//debug('Fehler beim Löschen von 703');
      TRANSBRK;
      RekRestore(vBuf702);
      Recread(702, 1, 0);
      RekRestore(vBuf703);
      Recread(703, 1, 0);
      RekRestore(vBuf401);
      RecRead(401, 1, 0);
      RETURN;
    end;

    if (BA1_Lohn_Subs:AutoVSB(BAG.F.Nummer, BAG.F.Position)=false) then begin
//debug('Fehler bei Autovsb');
      TRANSBRK;

      RekRestore(vBuf702);
      Recread(702, 1, 0);
      RekRestore(vBuf703);
      Recread(703, 1, 0);
      RekRestore(vBuf401);
      RecRead(401, 1, 0);
      ErrorOutput;
      RETURN;
    end;

    TRANSOFF;

    RekRestore(vBuf702);
    Recread(702, 1, 0);
    RekRestore(vBuf703);
    Recread(703, 1, 0);
    RekRestore(vBuf401);
    RecRead(401, 1, 0);
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

  RunAFX('BAG.F.Lohn.FocusTerm',aEvt:obj->wpname);

  if (aEvt:obj->wpname='edBAG.F.AusfOben') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|1');
  if (aEvt:obj->wpname='edBAG.F.AusfUnten') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|2');

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  case (aEvt:Obj->wpname) of
    'edBAG.F.Stueckzahl' :
      if (aEvt:obj->wpchanged) then begin
        if (BAG.F.Gewicht=0.0) then begin
          RecLink(819,703,5,_recFirst);   // Warengruppe holen
          BAG.F.Gewicht # Lib_Berechnungen:kg_aus_StkDBLDichte2("BAG.F.Stückzahl", BAG.F.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 703), "Wgr.TränenKgProQM");
          $edBAG.F.Gewicht->winupdate(_WinUpdFld2Obj);
        end;

        if (BAG.F.Menge=0.0) then begin
          if (BAG.F.MEH='qm') then begin
            BAG.F.Menge # BAG.F.Breite * Cnvfi("BAG.F.Stückzahl") * "BAG.F.Länge" / 1000000.0;
          end;
          $edBAG.F.Menge->winupdate(_WinUpdFld2Obj);
        end;
//        RefreshIfm();
      end;


    'edBAG.F.Gewicht' :
      if (aEvt:obj->wpchanged) then begin
        if ("BAG.F.Stückzahl"=0) then begin
          RecLink(819,703,5,_recFirst);   // Warengruppe holen
          "BAG.F.Stückzahl" # Lib_Berechnungen:Stk_aus_kgDBLDichte2(BAG.F.Gewicht, BAG.F.Dicke, BAG.F.Breite, "BAG.F.Länge", Wgr_Data:GetDichte(Wgr.Nummer, 703), "Wgr.TränenKgProQM");
          vS # "BAG.F.Stückzahl";
          $edBAG.F.Stueckzahl->winupdate(_WinUpdFld2Obj);
        end;

        if (BAG.F.Menge=0.0) then begin
          if (BAG.F.MEH='qm') then begin
            BAG.F.Menge # BAG.F.Breite * Cnvfi("BAG.F.Stückzahl") * "BAG.F.Länge" / 1000000.0;
  //          BAG.F.Menge # BAG.F.Breite * Cnvfi(vS) * "BAG.F.Länge" / 1000000.0;
          end;
          $edBAG.F.Menge->winupdate(_WinUpdFld2Obj);
        end;
//        RefreshIfm();
      end;


    'edBAG.F.Menge' :
      if (aEvt:obj->wpchanged) then begin
      end;

  end;  // case
//debug(bag.f.meh);
  if (StrCnv(BAG.F.MEH,_StrUpper)='KG') then  BAG.F.Menge # BAG.F.Gewicht;
  if (StrCnv(BAG.F.MEH,_StrUpper)='T') then   BAG.F.Menge # BAG.F.Gewicht / 1000.0;
  if (StrCnv(BAG.F.MEH,_StrUpper)='STK') then BAG.F.Menge # CnvFI("BAG.F.Stückzahl");
  $edBAG.F.Menge->winupdate(_WinUpdFld2Obj);

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
  vQ      : alpha(4000);
  vFilter : int;
  vA      : alpha;
  vTmp    : int;
end;

begin

  case aBereich of
    'Wgr' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWgr');
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

  end;  // ...case

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
    "BAG.F.ReservFürKunde"  # Auf.P.Kundennr;
    // Feldübernahme
    BA1_F_Data:AusKundenArtNr(TRUE);
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
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.F.Warengruppe # Wgr.Nummer;
  end;
  // Focus setzen:
  $edBAG.F.Warengruppe->Winfocusset(false);
end;


//========================================================================
//  AusVerpackung
//
//========================================================================
sub AusVerpackung()
begin
  if (gSelected<>0) then begin
    RecRead(704,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.F.Verpackung # BAG.Vpg.Verpackung;
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
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "BAG.F.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "BAG.F.Güte" # "MQu.Güte1"
    else
      "BAG.F.Güte" # "MQu.Güte2";
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
  vHdl    : int;
  vOK     : logic;
  vBAnr, vBApos : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n);

  vOK # y;
  if (BA1_Lohn_Subs:HoleBAPoszuAuf(var vBAnr, var vBApos)=1) then begin
    vOK # BA1_Lohn_Subs:BAschonverwogen(BAG.P.Nummer, BAG.P.Position);
  end;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n) or (VOK);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n) or (VOK);

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

    'Mnu.Verpackungen' : begin
      RecBufClear(704);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.V.Verwaltung', '', true);
      Lib_GuiCom:RunChildWindow(gMDI);
    end


    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edBAG.F.Dickentol') then
        MTo_Data:BildeVorgabe(703,'Dicke');
      if (aEvt:Obj->wpname='edBAG.F.Breitentol') then
        MTo_Data:BildeVorgabe(703,'Breite');
      if (aEvt:Obj->wpname='edBAG.F.Laengentol') then
        MTo_Data:BildeVorgabe(703,'Länge');
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,BAG.F.Anlage.Datum, BAG.F.Anlage.Zeit, BAG.F.Anlage.User);
    end;

  end; // ...case

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vA  : alpha;
end;
begin

  if (aEvt:Obj->wpname='bt.InternerText') then begin
    if (mode=c_modeNew) then
      vA # mytmpText+'.703'
    else
      vA # '~703.'+CnvAI(BAG.F.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+
        CnvAI(BAG.F.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+
        CnvAI(BAG.F.Fertigung,_FmtNumLeadZero | _FmtNumNoGroup,0,4);
    Mdi_RtfEditor_Main:Start(vA, Rechte[Rgt_BAG_Aendern], Translate('Bemerkung'));
    RETURN true;
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Kundenartnr'  :   Auswahl('Kundenartnr');
    'bt.Wgr'          :   Auswahl('Wgr');
    'bt.Verpackung'   :   Auswahl('Verpackung');
    'bt.Guete'        :   Auswahl('Guete');
    'bt.Guetenstufe'  :   Auswahl('Guetenstufe');
    'bt.AusfOben'     :   Auswahl('AF.Oben');
    'bt.AusfUnten'    :   Auswahl('AF.Unten');
  end;  // ...case

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
begin

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

  VarFree(Restdaten);
  RETURN true;
end;


//========================================================================
// SummiereEinsatz
//      Summiert die Einsatzmaterialien für Darstellung während der
//      Fertigungseingabe
//========================================================================
sub SummiereEinsatz()
local begin
  Erx           : int;
  v701          : handle;
  vBANr, vBApos : int;
end;
begin

  v701 # RekSave(701);

  // Einsatzdaten summieren
  gEinsatzBreite # 0.0;
  gEinsatzGewicht # 0.0;
  gEinsatzLaenge # 0.0;
  if (BA1_Lohn_Subs:HoleBAPoszuAuf(var vBAnr, var vBApos)=1) then begin
    Erx # RecLink(701,702,2,_RecFirst);
    WHILE (Erx <=_rLocked) DO BEGIN
      gEinsatzGewicht # gEinsatzgewicht + BAG.IO.Plan.In.Menge;

      if (BAG.P.Aktion = c_BAG_Spalt) then begin    // 08.11.2017 AH
        if (BAG.IO.Breite < gEinsatzBreite) OR (gEinsatzBreite = 0.0) then
          gEinsatzBreite # BAG.IO.Breite;
      end
      else begin
        if (BAG.IO.Breite < gEinsatzBreite) OR (gEinsatzBreite = 0.0) then
          gEinsatzBreite # BAG.IO.Breite + gEinsatzBreite;
      end;


      if ("Bag.IO.Länge" = 0.0) then begin
        Erx # RekLink(819,701,7,0);
        // ggf. Länge des Einsatzcoils errechnen
        "Bag.IO.Länge" # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.In.GewN,
                                  BAG.IO.Plan.In.Stk, BAG.IO.Dicke,  BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKGproQM");
      end;

      gEinsatzLaenge # gEinsatzLaenge + "Bag.IO.Länge";

      Erx # RecLink(701,702,2,_RecNext);
    END;
  end;

  RekRestore(v701);
end;


//========================================================================
// SummiereFertigungen
//      Summiert die vorhandenen Fertigungen für Darstellung während der
//      Fertigungseingabe
//========================================================================
sub SummiereFertigungen(opt aOhneBaFert : int)
local begin
  Erx     : int;
  v703    : handle;
  vBANr, vBApos : int;
end;
begin

  v703 # RekSave(703);

  // Fertigungen summieren
  gFertigungBreite # 0.0;
  gFertigungGewicht # 0.0;
  gFertigungLaenge # 0.0;
  if (BA1_Lohn_Subs:HoleBAPoszuAuf(var vBAnr, var vBApos)=1) then begin
    Erx # RecLink(703,702,4,_RecFirst);
    WHILE (Erx <=_rLocked) DO BEGIN
      if (aOhneBaFert <> 0) and (Bag.F.Fertigung = aOhneBaFert) then begin
        Erx # RecLink(703,702,4,_RecNext);
        CYCLE;
      end;

      gFertigungGewicht # gFertigungGewicht + BAG.F.Gewicht;
      gFertigungBreite # gFertigungBreite + BAG.F.Breite * CnvFI(Bag.F.Streifenanzahl);
      gFertigungLaenge # gFertigungLaenge + ( "BAG.F.Länge" * CnvFI("BAG.F.Stückzahl"));
      Erx # RecLink(703,702,4,_RecNext);
    END;
  end;

  RekRestore(v703);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

    if ((aName =^ 'edBAG.F.Warengruppe') AND (aBuf->BAG.F.Warengruppe<>0)) then begin
    RekLink(819,703,5,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
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