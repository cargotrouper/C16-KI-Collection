@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_AF_Main
//                  OHNE E_R_G
//  Info
//
//
//  23.02.2022  AH  Kopie von Mat_AF_Main
//  13.07.2022  HA  Quick Jump
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
//    SUB AusOberflaeche()
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
  cTitle :    'Ausführung'
  cFile :     257
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Art_AF'
  cZList :    $ZL.Art.AF
  cKey :      1
end;

declare Auswahl(aBereich : alpha)

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  Lib_Guicom2:Underline($edArt.AF.ObfNr);

  SetStdAusFeld('edArt.AF.ObfNr'  ,'Oberflaeche');

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
  vTmp  : int;
  Erx   : int;
end;
begin
  if (aName='edArt.AF.ObfNr') and ($edArt.AF.ObfNr->wpchanged) then begin
    Erx # RecLink(841,257,1,0);
    if (Erx<=_rLocked) then begin
      Art.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "Art.AF.Kürzel"     # "Obf.Kürzel";
      end
    else begin
      Art.AF.Bezeichnung  # '';
      "Art.AF.Kürzel"     # '';
    end;
    $edArt.AF.Bezeichnung->winupdate(_WinUpdFld2Obj);
    $edArt.AF.Kuerzel->winupdate(_WinUpdFld2Obj);
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
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  if (Mode=c_ModeNew) then begin
    Art.AF.ArtikelID  # Art.ID;
    Art.AF.Seite      # $NB.Main->wpcustom;
    Art.AF.lfdNr      # 1;
    if (StrFind(w_Command,'SETOBF:',1)<>0) then begin
      RecRead(841,0,_RecId,cnvia(w_Cmd_para));
      w_Cmd_Para  # '';
      w_Command   # '';
      Art.AF.ObfNr        # Obf.Nummer;
      Art.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "Art.AF.Kürzel"     # "Obf.Kürzel";
      $edArt.AF.Zusatz->WinFocusSet(true);
      RETURN;
    end;

  end;

  // Focus setzen auf Feld:
  $edArt.AF.ObfNr->WinFocusSet(true);
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
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
    end
  else begin
    WHILE (RecRead(257,1,_rectest)<=_rLocked) do
      Art.AF.lfdNr # Art.AF.LfdNr + 1;

    Art.AF.Anlage.Datum  # SysDate();
    Art.AF.Anlage.Zeit   # Now;
    Art.AF.Anlage.User   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));

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

  if (aEvt:Obj->wpname='edArt.AF.ObfNr') then
    if (aEvt:Obj->wpcustom='F9') then begin
      aEvt:Obj->wpcustom # '';
      app_Main:Refreshmode();
      Auswahl('Oberflaeche');
      RETURN true;
    end;

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
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;

begin

  case aBereich of
    'Oberflaeche' : begin
      RecBufClear(841);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusOberflaeche');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusOberflaeche
//
//========================================================================
sub AusOberflaeche()
begin
  if (gSelected<>0) then begin
    RecRead(841,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.AF.ObfNr        # Obf.Nummer;
    Art.AF.Bezeichnung  # Obf.Bezeichnung.L1;
    "Art.AF.Kürzel"     # "Obf.Kürzel";
    gMDI->winupdate(_WinUpdFld2Obj);
    $edArt.AF.Zusatz->Winfocusset(false);
    RETURN;
  end;
  // Focus auf Editfeld setzen:
  $edArt.AF.ObfNr->Winfocusset(false);

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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_Aendern]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Art_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Art_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Art_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Art_Aendern]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Art_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Art_Excel_Import]=false;

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
    'bt.ObfNr' :   Auswahl('Oberflaeche');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
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

  if ((aName =^ 'edArt.AF.ObfNr') AND (aBuf->Art.AF.ObfNr<>0)) then begin
    RekLink(841,257,1,0);   // Ausführung holen
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
  end;

  
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================