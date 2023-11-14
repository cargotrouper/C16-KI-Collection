@A+
//==== Business-Control ==================================================
//
//  Prozedur    HuB_Main
//                      OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  21.10.2013  AH  BugFix: Warengruppenauswahl
//  28.10.2013  ST  IstMenge wird nach Verlassen des Journals aktualisiert (1455/45)
//  28.07.2021  AH  ERX
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
//    SUB AusWarengruppe()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Hilfs- und Betriebsstoffe'
  cFile :     180
  cMenuName : 'HuB.Bearbeiten'
  cPrefix :   'HuB'
  cZList :    $ZL.HuB
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

Lib_Guicom2:Underline($edHuB.Warengruppe);

  SetStdAusFeld('edHuB.Warengruppe' ,'Warengruppe');
  SetStdAusFeld('edHuB.MEH'         ,'MEH');

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
  Lib_GuiCom:Pflichtfeld($edHuB.Artikelnr);
  Lib_GuiCom:Pflichtfeld($edHUB.MEH);
  Lib_GuiCom:Pflichtfeld($edHUB.PEH);
  Lib_GuiCom:Pflichtfeld($edHuB.Warengruppe);

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
  if (aName='') or (aName='edHuB.Warengruppe') then begin
    Erx # RecLink(819, 180, 3, _recFirst);
    if (Erx <= _rLocked) then
      $Lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1
    else
      $Lb.Warengruppe->wpcaption # '';
  end;
  if (aName='') or (aName='edHuB.MEH') then begin
    $Lb.MEH1->wpcaption # HuB.MEH;
    $Lb.MEH2->wpcaption # HuB.MEH;
    $Lb.MEH3->wpcaption # HuB.MEH;
    $Lb.MEH4->wpcaption # HuB.MEH;
  end;
  if (aName='') then begin
    $Lb.letzterEK->wpcaption # ANum(HuB.letzterEKPreis,2);
    $Lb.durchschEK->wpcaption # ANum(HuB.durchschEKPreis,2);
    $Lb.HW1->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW2->wpCaption # "Set.Hauswährung.Kurz";
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

  // dynamische Pflichtfelder einfaerben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  // Felder Disablen durch:
  Lib_GuiCom:Disable($edHuB.Menge.Bestellt);
  Lib_GuiCom:Disable($edHuB.Menge.Ist);

  If (Mode=c_ModeEdit) then begin
    Lib_GuiCom:Disable($edHuB.Artikelnr);
    Lib_GuiCom:Disable($edHuB.Stichwort);
    $edHuB.Warengruppe->WinFocusSet(true);
    end
  else begin
    $edHuB.Artikelnr->WinFocusSet(true);
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
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  if (Mode=c_ModeNew) then Hub.ArtikelNr # StrAdj(Hub.ArtikelNr, _StrEnd);


  if (HuB.Artikelnr='') then begin
    Lib_Guicom2:InhaltFehlt('Artikelnummer', 'NB.Page1', 'edHub.Artikelnr');
    RETURN false;
  end;

  If (HUB.Warengruppe=0) then begin
    Lib_Guicom2:InhaltFehlt('Warengruppe', 'NB.Page1', 'edHub.Warengruppe');
    RETURN false;
  end;
  Erx # RecLink(819,180,3,0);
  If (Erx>_rLocked) or (Wgr_Data:IstHub()=false) then begin
    Lib_Guicom2:InhaltFalsch('Warengruppe', 'NB.Page1', 'edHub.Warengruppe');
    RETURN false;
  end;

  if (HuB.MEH='') then begin
    Lib_Guicom2:InhaltFehlt('Mengeneinheit', 'NB.Page1', 'edHub.MEH');
    RETURN false;
  end;
  If (Lib_Einheiten:CheckMEH(var HUB.MEH)=false) then begin
    Lib_Guicom2:InhaltFalsch('Mengeneinheit', 'NB.Page1', 'edHub.MEH');
    RETURN false;
  end;
  if (HuB.PEH=0) then begin
    Lib_Guicom2:InhaltFehlt('Preiseinheit', 'NB.Page1', 'edHub.PEH');
    RETURN false;
  end;


  // logische Prüfung
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
    HuB.Anlage.Datum  # Today;
    HuB.Anlage.Zeit   # Now;
    HuB.Anlage.User   # gUsername;

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
local begin
  vQ    : alpha(4000);
end;

begin
  case aBereich of

    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edHuB.MEH,180,1,9);
    end;


    'Warengruppe' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, '"Wgr.Dateinummer"', '=', 180);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    HuB.Warengruppe # Wgr.Nummer;
    gSelected # 0;
  end;
  $edHuB.Warengruppe->winupdate(_WinUpdFld2Obj);
  // Focus auf Editfeld setzen:
  $edHuB.Warengruppe->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edHuB.Warengruppe');
end;


//========================================================================
//  AusJournal
//
//========================================================================
sub AusJournal()
begin
  gSelected # 0;
  RecRead(180,1,0);
  RefreshIfm('edHuB.Menge.Ist');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Preise');
  if (vHdl<>0) then
    vHdl->wpDisabled # (Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_HuB_Preise]=n);
  vHdl # gMenu->WinSearch('Mnu.Lagerjournal');
  if (vHdl<>0) then
    vHdl->wpDisabled # (Mode=c_ModeEdit) or (Mode=c_ModeNew);

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
  vFilter : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Lagerjournal' : begin
      RecBufClear(182);
      //gMDI # Lib_GuiCom:AddChildWindow(gMDI,'HuB.J.Verwaltung','',y);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'HuB.J.Verwaltung','HuB_Main:AusJournal',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(182,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,HuB.Artikelnr);
      gZLList->wpDbFilter # vFilter;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Preise' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'HuB.P.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(181);
      vFilter # RecFilterCreate(181,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,HuB.Artikelnr);
      gZLList->wpDbFilter # vFilter;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Stichwort' : begin
      WinDialog('HuB.Dlg.Stichwort',_WinDialogCenter);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, HuB.Anlage.Datum, HuB.Anlage.Zeit, HuB.Anlage.User );
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
    'bt.Warengruppe' :    Auswahl('Warengruppe');
    'bt.MEH' :            Auswahl('MEH');
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
  Refreshmode();
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
  RETURN true;
end;

sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edHuB.Warengruppe') AND (aBuf->HuB.Warengruppe<>0)) then begin
    RekLink(819,180,3,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================