@A+
//==== Business-Control ==================================================
//
//  Prozedur    CUS_Main
//                            OHNE E_R_G
//  Info
//
//
//  12.03.2009  AI  Erstellung der Prozedur
//  27.02.2017  ST  Export/Import hinzugefügt
//  05.06.2019  AH  "Cus.FP.UserSperreYN"
//  01.07.2019  AH  BugFix
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit() : logic;
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLEER()
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
  cTitle      : 'Sonderfelder'
  cFile       : 931
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'CUS'
  cZList      : $ZL.CUS
  cKey        : 1
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub Start(aDatei : int; aRecID : int);
begin
  GV.Ints.01  # aDatei;
  GV.Int.01   # aRecID;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'CUS.Verwaltung','',y);
  Lib_GuiCom:RunChildWindow(gMDI);
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

  
  SetStdAusFeld('edCUS.FeldNummer' ,'Feldname');

  App_Main:EvtInit(aEvt);
//  Mode      # c_modeEdList;
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
  Erx     : int;
  vTmp    : int;
end;
begin

  if (aName='') or (aName='edCUS.FeldNummer') then begin
    Erx # RecLink(930,931,1,_RecFirst);
    if (Erx<=_rLocked) then
      $Lb.Feldname->wpcaption # CUS.FP.Name
    else
      $Lb.Feldname->wpcaption # '';
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
sub RecInit() : logic;
local begin
  Erx   : int;
  vNr   : int;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  if (mode=c_ModeNew) then begin
    Erx # RecLink(931,999,5,_recLast);
    if (Erx>_rLocked) then vNr # 1
    else vNr # CUS.LfdNr + 1;

    RecbufCleaR(931);
    CUS.lfdNr # vNr
    CUS.Datei # GV.Ints.01;
    CUS.RecID # GV.Int.01;
    $edCUS.lfdNr->wpcaptionint # vNR;

    // Focus setzen auf Feld:
  //  $edCUS.Inhalt->WinFocusSet(true);
  //  $lbCUS.lfdNr->WinFocusSet(true);
    $edCUS.FeldNummer->WinFocusSet(true);
  end
  else begin
    $edCUS.Inhalt->WinFocusSet(true);   // 2022-06-24 AH
  end;


  RETURN true;
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
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeNew) then begin
    
    Erx # RecLink(930,931,1,_recFIrst);   // Felderpool holen
    if (Erx<=_rLocked) and (CUS.FP.UsersperreYN) then begin
      Msg(99,'Das ist ein Systemfeld!',0,0,0);
      RETURN False;
    end;

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end
  else if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
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
local begin
  Erx : int;
end;
begin
  
  Erx # RecLink(930,931,1,_recFIrst);   // FelderPool holen
  if (Erx<=_rLocked) and (CUS.FP.UsersperreYN) then RETURN;
  
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

/***
  if (aEvt:Obj->wpname='jump') then begin
    case (aEvt:Obj->wpcustom) of
      'Page1Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false)
        end;
      'Page1E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false);
        end;
    end;
    RETURN true;
  end;
***/

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
  vA    : alpha;
end;

begin

  case aBereich of
    'Feldname' : begin
      RecBufClear(930);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'CUS.FP.Verwaltung',here+':AusFeldname');
      //ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusFeldname
//
//========================================================================
sub AusFeldname()
begin
  if (gSelected<>0) then begin
    RecRead(930,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    CUS.FeldNummer # CUS.FP.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edCUS.FeldNummer->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx         : int;
  d_MenuItem  : int;
  vHdl        : int;
  vSperre     : logic
end
begin

//  if (mode=c_ModeList) then mode # c_ModeEdList;
  if (mode=c_ModeEdList) then mode # c_ModeList;

  Erx # RecLink(930,931,1,_recFIrst);   // FelderPool holen
  if (Erx<=_rLocked) and (CUS.FP.UsersperreYN) then vSperre # true;

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (vSperre);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (vSperre);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (vSperre);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (vSperre);

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
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
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
    'bt.Feld'   :   Auswahl('Feldname');
  end;

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
local begin
  Erx : int;
end;
begin
  Erx # RecLink(930,931,1,_recFirst);   // Feld holen
  if (Erx>_rLocked) then RecbufClear(930);
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



//========================================================================
//========================================================================
//========================================================================
//========================================================================