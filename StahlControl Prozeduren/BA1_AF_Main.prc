@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_AF_Main
//                  OHNE E_R_G
//  Info
//
//
//  06.09.2004  AI
//  01.01.2009  MS Recht zur Neuanlage von Ausfuehrungen angepasst
//  04.04.2022  AH  ERX
//  18.07.2022  HA  Quick jump
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
  cDialog :   $BA1.AF.Verwaltung
  cTitle :    'Ausführung'
  cFile :     705
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'BA1_AF'
  cZList :    $ZL.BA1.AF
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

  Lib_Guicom2:Underline($edBAG.AF.ObfNr);

  SetStdAusFeld('edBAG.AF.ObfNr' ,'Oberflaeche');

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
  Erx   : int;
  vTmp  : int;
end;
begin
  if (aName='edBAG.AF.ObfNr') and ($edBAG.AF.ObfNr->wpchanged) then begin
    Erx # RecLink(841,705,1,0);
    if (Erx<=_rLocked) then begin
      BAG.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "BAG.AF.Kürzel"  # "Obf.Kürzel";
      end
    else begin
      BAG.AF.Bezeichnung  # '';
      "BAG.AF.Kürzel"  # '';
    end;
    $edBAG.AF.Bezeichnung->winupdate(_WinUpdFld2Obj);
    $edBAG.AF.Kuerzel->winupdate(_WinUpdFld2Obj);
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
    BAG.AF.Nummer        # cnvIA(Str_Token($NB.Main->wpcustom, '|', 1));
    BAG.AF.Position      # cnvIA(Str_Token($NB.Main->wpcustom, '|', 2));
    BAG.AF.Fertigung     # cnvIA(Str_Token($NB.Main->wpcustom, '|', 3));
    BAG.AF.Fertigmeldung # cnvIA(Str_Token($NB.Main->wpcustom, '|', 4));
    BAG.AF.Seite         # Str_Token($NB.Main->wpcustom, '|', 5);
    BAG.AF.lfdNr         # 1;
//    $edBAG.AF.ObfNr->wpcustom # 'F9';
//    $edMat.AF.ObfNr->wpcustom # 'F9';
    if (StrFind(w_Command,'SETOBF:',1)<>0) then begin
//      RecRead(841,0,_RecId,cnvia(w_Command));
      RecRead(841,0,_RecId,cnvia(w_Cmd_para));
      w_Cmd_Para  # '';
      w_Command   # '';
      BAG.AF.ObfNr        # Obf.Nummer;
      BAG.AF.Bezeichnung  # Obf.Bezeichnung.L1;
      "BAG.AF.Kürzel"     # "Obf.Kürzel";
      $edBAG.AF.Zusatz->WinFocusSet(true);
      RETURN;
    end;
  end;

  // Focus setzen auf Feld:
  $edBAG.AF.ObfNr->WinFocusSet(true);
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
    //"xxx.Änderung.Datum"  # SysDate();
  //  "xxx.Änderung.Zeit"   # Now;
//    "xxx.Änderung.User"   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));
    PtD_Main:Compare(gFile);
  end
  else begin
    WHILE (RecRead(705,1,_rectest)<=_rLocked) do
      BAG.AF.lfdNr # BAG.AF.LfdNr + 1;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    //xxx.Anlage.Datum  # SysDate();
  //  xxx.Anlage.Zeit   # Now;
//    xxx.Anlage.User   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));
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

  if (aEvt:Obj->wpname='edBAG.AF.ObfNr') then
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
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung','BA1_AF_Main:AusOberflaeche');
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
  // Zugriffliste wieder aktivieren
  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(841,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.AF.ObfNr        # Obf.Nummer;
    BAG.AF.Bezeichnung  # Obf.Bezeichnung.L1;
    "BAG.AF.Kürzel"     # "Obf.Kürzel";
    gMDI->winupdate(_WinUpdFld2Obj);
    $edBAG.AF.Zusatz->winfocusSet(false);
    RETURN;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.AF.ObfNr->Winfocusset(false);
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
  if (vHdl <> 0) then begin
    // 01.01.2009 MS Rechteprüfung angepasst das sonst ein
    // "einfacher" Betriebarbeiter keine AF anlegen kann
    //
    // cnvIA(Str_Token(cZList->wpcustom, '|', 4) (BAG.AF.Fertigmeldung)
    // <> 0 // wir befinden uns in der FM
    //  = 0 // wir befinden uns in der Fertigung

    if(cnvIA(Str_Token($NB.Main->wpcustom, '|', 4)) <> 0) then // FM
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_AF] = n)
    else if(cnvIA(Str_Token($NB.Main->wpcustom, '|', 4)) <> 0) then // Fertigung
     vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n)
  end;

  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG_Loeschen]=n);

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

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);

begin

  if ((aName =^ 'edBAG.AF.ObfNr') AND (aBuf->BAG.AF.ObfNr<>0)) then begin
    RekLink(841,705,1,0);   // Ausführung holen
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================