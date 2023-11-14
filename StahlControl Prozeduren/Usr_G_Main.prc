@A+
//==== Business-Control ==================================================
//
//  Prozedur    Usr_G_Main
//                  OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB RefreshIfm(optaName : alpha)
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB Auswahl_EvtInit(aEvt : event) : logic
//    SUB Auswahl_EvtMdiActivate(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB Auswahl_EvtTerm(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Usergruppen'
  cFile :     801
  cMenuName : 'Usr.G.Bearbeiten'
  cPrefix :   'Usr_G'
  cZList :    $ZL.Gruppen
  cKey :      1
  cListen : 'Usergruppen'
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
  w_Listen # cListen;

  // Auswahlfelder setzen...
  //SetStdAusFeld('', '');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  if (Mode=c_modeNew) then begin
    if (w_AppendNr<>0) then begin
      RecRead(gFile, 0, _RecId, w_AppendNr);
      w_AppendNr       # 0;
    end;
  end;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edUsr.Grp.Gruppenname->WinFocusSet(true);
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
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
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
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
begin

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
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

  vHdl # gMdi->WinSearch('Rechte');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_Rechte]=n);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_G_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_G_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Usr_G_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_G_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_G_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_G_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_G_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Usr_G_Anlegen]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Usr_G_Anlegen]=false;

end;


//========================================================================
//  EvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
begin
  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    $Usr.G.Auswahl->Winclose();
  end;
end;


//========================================================================
//  EvtMouseItem
//                Mausclick in Auswahlliste
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin

  if (aItem=0) or (aID=0) then RETURN false;

  if ((aButton & _WinMouseLeft)<>0) and ((aButton & _WinMouseDouble)<>0) then begin
    gSelected # aID;
    $Usr.G.Auswahl->Winclose();
  end;

end;


//========================================================================
//  MenuCommand
//              Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vMode : alpha;
  vA    : alpha(cMaxRights);
  Erx   : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Grp.Cancel' : begin
      $Usr.G.Auswahl->winclose();
    end;


    'Mnu.Copy' : begin
      w_AppendNr # gZLList->wpdbrecid;
      App_Main:Action(c_ModeNew);
      RETURN true;
    end;


    'Rechte' : begin
      vMode # Mode;
      Mode # c_ModeOther;
      App_Main:RefreshMode();
      gZLList->wpdisabled # true;
    //if RecRead(801,0, _RecLock,gZLList->wpDbRecId)<>_rOk then begin
      if RecRead(801,1, _RecLock)<>_rOk then begin
        Msg(801001,'',0,0,0);
        RETURN false;
      end;
                                        // Rechtevergabe
      vA # Usr_R_Main:ManageRights('',Usr.Grp.Rights1+Usr.Grp.Rights2+Usr.Grp.Rights3+Usr.Grp.Rights4,n);

      Usr.Grp.Rights1 # StrCut(vA,1,250);
      Usr.Grp.Rights2 # StrCut(vA,251,250);
      Usr.Grp.Rights3 # StrCut(vA,501,250);
      Usr.Grp.Rights4 # StrCut(vA,751,250);

      Erx # RekReplace(801,_RecUnlock,'MAN');
      if (Erx<>_rOk) then begin
        Msg(8001002,'',0,0,0);
        RETURN false;
      end;

      gZLList->wpdisabled # false;
      Mode # vMode;
      App_Main:RefreshMode();
//      gZLList->Winfocusset(true);
    end;
    
    'CustomRechte' : begin
      vMode # Mode;
      Mode # c_ModeOther;
      App_Main:RefreshMode();
      gZLList->wpdisabled # true;
      if RecRead(801,1, _RecLock)<>_rOk then begin
        Msg(801001,'',0,0,0);
        RETURN false;
      end;
                                        // Rechtevergabe
      vA # Usr_R_Main:ManageCustomRights('',Usr.Grp.Customright1,n);
      Usr.Grp.Customright1 # StrCut(vA,1,1000);
      Erx # RekReplace(801,_RecUnlock,'MAN');
      if (Erx<>_rOk) then begin
        Msg(8001002,'',0,0,0);
        RETURN false;
      end;

      gZLList->wpdisabled # false;
      Mode # vMode;
      App_Main:RefreshMode();
    end;
    
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
// Auswahl_EvtInit
//          Initialisieren der Applikation
//========================================================================
sub Auswahl_EvtInit(
  aEvt                  : event;        // Ereignis
): logic
begin
  aEvt:Obj->wpcustom # cnvai(VarInfo(WindowBonus));
  Lib_GuiCom:TranslateObject(aEvt:Obj);
  RETURN true;
end;


//========================================================================
//  Auswahl_EvtMdiActivate
//                          Fenster aktivieren
//========================================================================
sub Auswahl_EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  gTitle  # 'Usergruppen';
  gPrefix # 'Usr_G';
  gFrmMain->wpMenuname # 'Usr.G.Auswahl';
  Call('App_Main:EvtMdiActivate',aEvt);
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
// Auswahl_EvtTerm
//          Terminieren eines Fensters
//Usr_G_Main:Auswahl_EvtTerm
//========================================================================
sub Auswahl_EvtTerm(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTermProc : alpha;
  vHdl      : int;
end;
begin
  // AusAuswahlprozedur starten?
  If (w_TermProc<>'') then begin
    vTermPRoc # w_TermProc;
    vHdl # VarInfo(WindowBonus);
    WinSearchPath(w_Parent);
    VarInstance(Windowbonus,cnvia(w_Parent->wpcustom));
    if (gSelected<>0) then Call(vTermProc);
    VarInstance(Windowbonus,vHdl);
  end;

  RETURN true;
end;


//========================================================================