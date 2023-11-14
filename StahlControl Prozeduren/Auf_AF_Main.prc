@A+
//==== Business-Control ==================================================
//
//  Prozedur    Auf_AF_Main
//                  OHNE E_R_G
//  Info
//
//
//  06.05.2004  FR  Kopie von Ein_AF_Main
//  04.04.2022  AH  ERX
//  14.07.2022  HA  Quick Jump
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
  cFile :     402
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Auf_AF'
  cZList :    $ZL.Auf.AF
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

 Lib_Guicom2:Underline($edAuf.AF.ObfNr);

  SetStdAusFeld('edAuf.AF.ObfNr' ,'Oberflaeche');

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
  vHdl  : int;
  Erx   : int;
end;
begin
  if (aName='edAuf.AF.ObfNr') and ($edAuf.AF.ObfNr->wpchanged) then begin
    Erx # RecLink(841,402,1,0);
    if (Erx<=_rLocked) then begin
      Auf.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "Auf.AF.Kürzel"     # "Obf.Kürzel";
      end
    else begin
      Auf.AF.Bezeichnung  # '';
      "Auf.AF.Kürzel"     # '';
    end;
    $edAuf.AF.Bezeichnung->winupdate(_WinUpdFld2Obj);
    $edAuf.AF.Kuerzel->winupdate(_WinUpdFld2Obj);
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
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
    Auf.AF.Nummer   # Auf.P.Nummer;
    Auf.AF.Position # Auf.P.Position;
    Auf.AF.Seite    # $NB.Main->wpcustom;
    Auf.AF.lfdNr    # 1;
//    $edAuf.AF.ObfNr->wpcustom # 'F9';
//    $edMat.AF.ObfNr->wpcustom # 'F9';
    if (StrFind(w_Command,'SETOBF:',1)<>0) then begin
//      RecRead(841,0,_RecId,cnvia(w_Command));
      RecRead(841,0,_RecId,cnvia(w_Cmd_para));
      w_Cmd_Para  # '';
      w_Command   # '';
      Auf.AF.ObfNr        # Obf.Nummer;
      Auf.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "Auf.AF.Kürzel"     # "Obf.Kürzel";
      $edAuf.AF.Zusatz->WinFocusSet(true);
      RETURN;
    end;
  end;

  // Focus setzen auf Feld:
  $edAuf.AF.ObfNr->WinFocusSet(true);
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
    WHILE (RecRead(402,1,_rectest)<=_rLocked) do
      Auf.AF.lfdNr # Auf.AF.LfdNr + 1;

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

  if (aEvt:Obj->wpname='edAuf.AF.ObfNr') then
    if (aEvt:Obj->wpcustom='F9') then begin
      aEvt:Obj->wpcustom # '';
      Auswahl('Oberflaeche');
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
  vA    : alpha;
end;

begin

  case aBereich of
    'Oberflaeche' : begin
      RecBufClear(841);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusOberflaeche');
      RunAFX('Auf.P.Obf.Filter',aint(gMDI)+'|'+Auf.AF.Seite);
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
    Auf.AF.ObfNr        # Obf.Nummer;
    Auf.AF.Bezeichnung  # Obf.Bezeichnung.L1;
    "Auf.AF.Kürzel"     # "Obf.Kürzel";
    gMDI->winupdate(_WinUpdFld2Obj);
    $edAuf.AF.Zusatz->winfocusSet(false);
    RETURN;
  end;
  // Focus auf Editfeld setzen:
  $edAuf.AF.ObfNr->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_P_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_P_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Auf_P_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Auf_P_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Auf_P_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Auf_P_Aendern]=n);

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

  if ((aName =^ 'edAuf.AF.ObfNr') AND (aBuf->Auf.AF.ObfNr<>0)) then begin
    RekLink(841,402,1,0);   // Aüsfunrungws holen
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
    
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================