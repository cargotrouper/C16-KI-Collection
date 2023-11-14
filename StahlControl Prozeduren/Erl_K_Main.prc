@A+
//==== Business-Control ==================================================
//
//  Prozedur    Erl_K_Main
//                      OHNE E_R_G
//  Info
//
//
//  11.11.2003  ST  Erstellung der Prozedur
//  15.08.2016  AH  Erlöskorrektur beachten
//  10.05.2022  AH  ERX
//  22.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusAufart()
//    SUB AusWgr()
//    SUB AusWaehrung()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Erlöskonten'
  cFile :     451
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Erl_K'
  cZList :    $ZL.Erloeskonten
  cKey :      1
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

Lib_Guicom2:Underline($edErl.K.Auftragsart);
Lib_Guicom2:Underline($edErl.K.Warengruppe);
Lib_Guicom2:Underline($edErl.K.Whrung);


  SetStdAusFeld('edErl.K.Auftragsart' ,'Aufart');
  SetStdAusFeld('edErl.K.Warengruppe' ,'Wgr');
  SetStdAusFeld('edErl.K.Whrung'      ,'Waehrung');
  SetStdAusFeld('edErl.K.MEH'         ,'Meh');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx     : int;
  vTmp    : int;
end;
begin

  if (aName = '') then begin
    $edErl.K.Rechnungsnr    -> wpCaptionint   # Ofp.Rechnungsnr;
    $edErl.K.Rechnungsdatum -> wpCaptiondate  # Erl.K.Rechnungsdatum;
    $edErl.K.Kundennummer   -> wpCaptionint   # Erl.K.Kundennummer;
    $edErl.K.Whrung         -> wpCaptionint   # "Erl.K.Währung";
    $edErl.K.Whrungskurs    -> wpCaptionFloat # "Erl.K.Währungskurs";
  end;


  if (aName='') or (aName='edErl.K.Steuerschl') then begin
    Erx # RekLink(813,451,10,_recFirsT);
    $lb.Steuerschluessel->wpcaption # Sts.Bezeichnung;
  end;


  if (aName='') or (aName='edErl.K.Whrung') then begin
    Erx # RecLink(814,451,3,0);
    if (Erx<=_rLocked) then begin
      $lb.Wae1->wpcaption # "Wae.Kürzel";
      $lb.Wae2->wpcaption # "Wae.Kürzel";
      $lb.Wae3->wpcaption # "Wae.Kürzel";
    end
    else begin
      $lb.Wae1->wpcaption # '';
      $lb.Wae2->wpcaption # '';
      $lb.Wae3->wpcaption # '';
    end;
    if (Erl.K.Betrag <> 0.0) AND ("Erl.K.Währungskurs" <> 0.0) then begin
      Erl.K.BetragW1 # Erl.K.Betrag /  "Erl.K.Währungskurs";
      $edErl.K.BetragW1 -> wpCaptionFloat # Erl.K.BEtragW1;
    end;
    if (Erl.K.Korrektur <> 0.0) AND ("Erl.K.Währungskurs" <> 0.0) then begin
      Erl.K.KorrekturW1 # Erl.K.Korrektur /  "Erl.K.Währungskurs";
      $edErl.K.KorrekturW1 -> wpCaptionFloat # Erl.K.KorrekturW1;
    end;
  end;


  if (aName='') or (aName='edErl.K.Betrag') then begin
    if (Erl.K.Betrag <> 0.0) AND ("Erl.K.Währungskurs" <> 0.0) then begin
      Erl.K.BetragW1 # Erl.K.Betrag /  "Erl.K.Währungskurs";
      $edErl.K.BetragW1 -> wpCaptionFloat # Erl.K.BEtragW1;
    end;
  end;

  if (aName='') or (aName='edErl.K.Korrektur') then begin
    if (Erl.K.Korrektur <> 0.0) AND ("Erl.K.Währungskurs" <> 0.0) then begin
      Erl.K.KorrekturW1 # Erl.K.Korrektur /  "Erl.K.Währungskurs";
      $edErl.K.KorrekturW1 -> wpCaptionFloat # Erl.K.KorrekturW1;
    end;
  end;

  if (aName='') or (aName='edErl.K.Auftragsart') then begin
    Erx # RecLink(835,451,5,0);
    if (Erx<=_rLocked) then
      $LB.Aufart->wpcaption # "AAr.Bezeichnung"
    else
      $LB.Aufart->wpcaption # '';
  end;


  if (aName='') or (aName='edErl.K.Warengruppe') then begin
    Erx # RecLink(819,451,4,0);
    if (Erx<=_rLocked) then
      $LB.Wgr->wpcaption # "Wgr.Bezeichnung.L1"
    else
      $LB.Wgr->wpcaption # '';
  end;


  if (aName='') or (aName='lb.HW1') then begin

    Erx # RecLink(100,451,6,0);
    if (Erx<=_rLocked) then begin

      Erx # RecLink(814,100,5,0);
      if (Erx<=_rLocked) then
        $lb.HW1 -> wpCaption # "Wae.Kürzel"
      else
        $lb.HW1 -> wpCaption # '';

    end else
      $lb.HW1 -> wpCaption # '';

  end;


  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  if (Mode=c_ModeNew) then begin
    "Erl.K.Rechnungsnr"     # "Ofp.Rechnungsnr";
    $edErl.K.Rechnungsnr    -> wpCaptionint   # Ofp.Rechnungsnr;
    "Erl.K.Rechnungsdatum"  # "Ofp.Rechnungsdatum";
    "Erl.K.Kundennummer"    # "Ofp.Kundennummer";
    "Erl.K.Währung"         # "Ofp.Währung";
    "Erl.K.Währungskurs"    # "Ofp.Währungskurs";
  end;

  RefreshIfm('lb.HW1');

  // Felder Disablen durch:
  Lib_GuiCom:Disable($edErl.K.Rechnungsnr);

  Lib_GuiCom:Disable($edErl.K.Rechnungsdatum);
  Lib_GuiCom:Disable($edErl.K.Kundennummer);
  Lib_GuiCom:Disable($edErl.K.BetragW1);
  Lib_GuiCom:Disable($edErl.K.KorrekturW1);

  // Focus setzen auf Feld:
  $edErl.K.Auftragsart->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung

  if (Erl.K.Rechnungsnr = 0) then begin
    Msg(001200,Translate('Rechnungsnummer'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    RETURN false;
  end;

  if (Erl.K.Auftragsart = 0) then begin
    Msg(001200,Translate('Auftragsart'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edErl.K.Auftragsart->WinFocusSet(true);
    RETURN false;
  end;

  if (Erl.K.Auftragsart<>0) then begin
    Erx # RecLink(835,451,5,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Auftragsart'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edErl.K.Auftragsart->WinFocusSet(true);
      RETURN false;
    end;
  end;


  if (Erl.K.Warengruppe = 0) then begin
    Msg(001200,Translate('Warengruppe'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edErl.K.Warengruppe->WinFocusSet(true);
    RETURN false;
  end;


  if (Erl.K.Warengruppe<>0) then begin
    Erx # RecLink(819,451,4,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Warengruppe'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edErl.K.Warengruppe->WinFocusSet(true);
      RETURN false;
    end;
  end;


  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    PtD_Main:Compare(gFile);
  end
  else begin

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  RETURN true;  // Speichern erfolgreich
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
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  RekDelete(gFile,0,'MAN');

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
begin

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
begin

  case aBereich of

    'Aufart' : begin
      RecBufClear(835);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'AAr.Verwaltung',here+':AusAufart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Wgr' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWgr');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Waehrung' : begin
      RecBufClear(814);         // ZIELBUFFER LEEREN
      Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung',here+':AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Meh' : begin
      Lib_Einheiten:Popup('MEH',$edErl.K.MEH,451,1,14);
/***
      vHdl2->WinLstDatLineAdd('kg');
      vHdl2->WinLstDatLineAdd('l');
      vHdl2->WinLstDatLineAdd('m');
      vHdl2->WinLstDatLineAdd('Stk');
      vHdl2->WinLstDatLineAdd('t');
***/
      $edErl.K.MEH->wpCaption # Erl.K.MEH;
      $edErl.K.MEH->WinUpdate(_WinUpdFld2Obj);
      $edErl.K.MEH->winFocusSet(true);
    end;
  end;

end;


//========================================================================
//  AusAufart
//
//========================================================================
sub AusAufart()
begin
  if (gSelected<>0) then begin
    RecRead(835,0,_RecId,gSelected);
    // Feldübernahme
    Erl.K.Auftragsart # AAr.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edErl.K.Auftragsart->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edErl.K.Aufrtagsart');
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
    Erl.K.Warengruppe # Wgr.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edErl.K.Warengruppe->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edErl.K.Warengruppe');
end;


//========================================================================
//  AusWaehrung
//
//========================================================================
sub AusWaehrung()
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    "Erl.K.Währung"      # Wae.Nummer;
    "Erl.K.Währungskurs" # Wae.VK.Kurs;
    gSelected # 0;
  end;
  $edErl.K.Whrung->Winfocusset(false);
  RefreshIfm('edErl.K.Whrung');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Erl_K_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Erl_K_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Erl_K_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Erl_K_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Erl_K_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Erl_K_Loeschen]=n);

  RefreshIfm();

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
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
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
    'bt.Aufart'   :   Auswahl('Aufart');
    'bt.Wgr'      :   Auswahl('Wgr');
    'bt.Waehrung' :   Auswahl('Waehrung');
    'bt.Meh'      :   Auswahl('Meh');
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
//  Refreshmode();
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
  RETURN true;
end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edErl.K.Auftragsart') AND (aBuf->Erl.K.Auftragsart<>0)) then begin
    RekLink(835,451,5,0);   // Auftragsart holen
    Lib_Guicom2:JumpToWindow('AAr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edErl.K.Warengruppe') AND (aBuf->Erl.K.Warengruppe<>0)) then begin
    RekLink(819,451,4,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edErl.K.Whrung') AND (aBuf->"Erl.K.Währung"<>0)) then begin
    RekLink(814,451,3,0);   // Währung holen
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================