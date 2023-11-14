@A+
//==== Business-Control ==================================================
//
//  Prozedur    ArG_Main
//                  OHNE E_R_G
//  Info
//
//
//  25.08.2004  AI  Erstellung der Prozedur
//  07.03.2008  ST  Kostenstelle hinzugefügt
//  08.10.2013  AH  neues Feld MEH
//  17.03.2016  AH  neues Feld "Auftragsart"
//  07.11.2018  AH  neues Feld "TauscheInOutYN"
//  04.04.2022  AH  ERX
//  13.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusAuftragsart()
//    SUB AusKostenstelle()
//    SUB AusWarengruppe()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Arbeitsgänge'
  cFile :     828
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'ArG'
  cZList :    $ZL.Arbeitsgaenge
  cKey :      1
  cListen :   'Arbeitsgänge'
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
  w_Listen  # cListen;

Lib_Guicom2:Underline($edArG.Kostenstelle);
Lib_Guicom2:Underline($edArG.BAG.Warengruppe);
Lib_Guicom2:Underline($edArG.Auftragsart);

  setStdAusFeld('edArG.Aktion'          ,'BATyp');
  setStdAusFeld('edArG.BAG.Warengruppe' ,'Warengruppe');
  setStdAusFeld('edArG.Kostenstelle'    ,'Kostenstelle');
  SetStdAusFeld('edArG.MEH'             ,'MEH');
  SetStdAusFeld('edArG.Auftragsart'     ,'Auftragsart');

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

  Lib_GuiCom:Pflichtfeld($edArG.MEH);
end;


//========================================================================
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
begin
    if ("ArG.Typ.1in-1outYN"=false) then begin
      ArG.TauscheInOutYN # false;
      $cbTausche->wpCheckState # _WinStateChkUnchecked;
    end;
    Lib_GuiCom:Able($cbTausche,("ArG.Typ.1in-1outYN"));
  RETURN(true);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin

  // 07.11.2018
  if (Mode=c_ModeEdit) or (mode=c_modeNew) then begin
    if ("ArG.Typ.1in-1outYN"=false) then ArG.TauscheInOutYN # false;
    Winupdate($cbTausche, _WinUpdOn);
    Winsleep(1);
    Lib_GuiCom:Able($cbTausche,("ArG.Typ.1in-1outYN"));
  end;
  
  if (aName='') or (aName='edArG.Kostenstelle') then begin
    Erx # RecLink(846,828,1,0);
    if (Erx<=_rLocked) then
      $Lb.Kostenstelle->wpcaption # KsT.Bezeichnung
    else
      $Lb.Kostenstelle->wpcaption # '';
  end;

  if (aName='') or (aName='edArG.BAG.Warengruppe') then begin
    Erx # RecLink(819,828,2,_recfirst); // Wgr holen
    if (Erx<=_rLocked) then
      $Lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1
    else
      $Lb.Warengruppe->wpcaption # '';
  end;

  if (aName='') or (aName='edArG.Auftragsart') then begin
    Erx # RekLink(835,828,3,_recfirst); // AAr holen
    $Lb.Auftragsart->wpcaption # AAr.Bezeichnung;
  end;


  if (aName='') and (Mode=c_ModeView) then begin
    if ("Arg.Typ.1In-1OutYN") then $cb.1zu1->wpCheckState # _WinStateChkChecked;
    if ("Arg.Typ.1In-yOutYN") then $cb.1zuN->wpCheckState # _WinStateChkChecked;
    if ("Arg.Typ.xIn-yOutYN") then $cb.MzuN->wpCheckState # _WinStateChkChecked;
    if ("Arg.Typ.VSBYN")      then $cb.VSB->wpCheckState # _WinStateChkChecked;
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
begin
  // Focus setzen auf Feld:
  $edArG.Aktion2->WinFocusSet(true);

  if (Mode=c_ModeNEW) then begin
    "Arg.Typ.1In-1OutYN" # y;
    $cb.1zu1->wpCheckState # _WinStateChkChecked;
    $cb.1zuN->wpCheckState # _WinStateChkUnChecked;
    $cb.MzuN->wpCheckState # _WinStateChkUnChecked;
    $cb.VSB->wpCheckState # _WinStateChkUnChecked;
  end;
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
  if ("ArG.Typ.1in-1outYN"=false) and (ArG.TauscheInOutYN) then begin
    Msg(99,'Tausch kann nur bei 1zu1 genutzt werden!',0,0,0);
    RETURN false;
  end;
   

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  If (ArG.MEH='') then begin
    Msg(001200,Translate('Mengeneinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArG.MEH->WinFocusSet(true);
    RETURN false;
  end;
  If (Lib_Einheiten:CheckMEH(var ArG.MEH)=false) then begin
    Msg(001201,Translate('Mengeineinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArG.MEH->WinFocusSet(true);
    RETURN false;
  end;

  if (Arg.Auftragsart<>0) then begin
    Erx # RecLink(835,828,3,0);    // Auftrgsart holen
    if (Erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Auftragsart', 'NB.Page1', 'edArG.Auftragsart');
      RETURN false;
    end;
  end;


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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(gFile,0,'MAN');
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
  $edArG.Aktion -> wpreadonly # true;

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

    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edArG.MEH,828,1,11);
    end;


    'BATyp' : begin
      Lib_Einheiten:Popup('BAAktion',$edArG.Aktion,828,1,1);
      $edArG.Aktion->winfocusset(false);
    end;


    'Auftragsart' : begin
      RecBufClear(835);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'AAr.Verwaltung',here+':AusAuftragsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kostenstelle' : begin
      RecBufClear(846);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'KsT.Verwaltung',here+':AusKostenstelle');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Warengruppe' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'WGr.Verwaltung',here+':AusWarengruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusAuftragsart
//
//========================================================================
sub AusAuftragsart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(835,0,_RecId,gSelected);
    Arg.Auftragsart # AAr.Nummer;
    // Feldübernahme
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArG.Auftragsart->Winfocusset(false);
  // ggf. Labels refreshen
//RefreshIfm('edArG.Kostenstelle');
end;


//========================================================================
//  AusKostenstelle
//
//========================================================================
sub AusKostenstelle()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(846,0,_RecId,gSelected);
    ArG.Kostenstelle # Kst.Nummer;
    // Feldübernahme
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArG.Kostenstelle->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArG.Kostenstelle');
end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    ArG.BAG.Warengruppe # WGr.Nummer;
    // Feldübernahme
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArG.BAG.Warengruppe->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArG.BAG.Warengruppe');
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ArG_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ArG_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_AuswahlMode) or (Rechte[Rgt_ArG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_AuswahlMode) or (Rechte[Rgt_ArG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_AuswahlMode) or (Rechte[Rgt_ArG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_ArG_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


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

  $cb.1zu1->wpCheckState # _WinStateChkUnChecked;
  $cb.1zuN->wpCheckState # _WinStateChkUnChecked;
  $cb.MzuN->wpCheckState # _WinStateChkUnChecked;
  $cb.VSB->wpCheckState  # _WinStateChkUnChecked;

  case (aEvt:Obj->wpName) of
    'bt.BATyp'        :   Auswahl('BATyp');
    'bt.Kostenstelle' :   Auswahl('Kostenstelle');
    'bt.AAr'          :   Auswahl('Auftragsart');
    'bt.WGr'          :   Auswahl('Warengruppe');
    'bt.MEH'          :   Auswahl('MEH');

    'cb.1zu1'     : begin
      "ArG.Typ.1In-1OutYN"  # y;
      "Arg.Typ.1In-yOutYN"  # n;
      "Arg.Typ.xIn-yOutYN"  # n;
      "Arg.Typ.VSBYN"       # n;
    end;

    'cb.1zuN'     : begin
      "ArG.Typ.1In-1OutYN"  # n;
      "Arg.Typ.1In-yOutYN"  # y;
      "Arg.Typ.xIn-yOutYN"  # n;
      "Arg.Typ.VSBYN"       # n;
      $cb.1zuN->Winfocusset(false);
    end;

    'cb.MzuN'     : begin
      "ArG.Typ.1In-1OutYN"  # n;
      "Arg.Typ.1In-yOutYN"  # n;
      "Arg.Typ.xIn-yOutYN"  # y;
      "Arg.Typ.VSBYN"       # n;
      $cb.MzuN->Winfocusset(false);
    end;

    'cb.VSB'      : begin
      "ArG.Typ.1In-1OutYN"  # n;
      "Arg.Typ.1In-yOutYN"  # n;
      "Arg.Typ.xIn-yOutYN"  # n;
      "Arg.Typ.VSBYN"       # y;
      $cb.VSB->Winfocusset(false);
    end;
  end;  // Case

  WinUpdate(aEvt:Obj);

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
  
  if ((aName =^ 'edArG.Kostenstelle') AND (aBuf->ArG.Kostenstelle<>0)) then begin
    RekLink(846,828,1,0);   // Kostenstelle holen
    Lib_Guicom2:JumpToWindow('KsT.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArG.BAG.Warengruppe') AND (aBuf->ArG.BAG.Warengruppe<>0)) then begin
    RekLink(819,828,2,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('WGr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArG.Auftragsart') AND (aBuf->ArG.Auftragsart<>0)) then begin
    RekLink(835,828,3,0);   // Auftragsart holen
    Lib_Guicom2:JumpToWindow('AAr.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================