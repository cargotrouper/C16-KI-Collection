@A+
//==== Business-Control ==================================================
//
//  Prozedur    MQu2_M_Main
//                  OHNE E_R_G
//  Info
//  Steuert die Qualitästsmechenikenverwaltung
//
//  25.01.2021  AH  Erstellung der Prozedur
//  2022-06-28  AH  ERX
//  25.07.2022  HA  Quick Jump
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
  cTitle :    'Mechaniken'
  cFile :     833
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'MQu2_M'
  cZList :    $ZL.Mechanik
  cListen   : 'Mechaniken'
  cKey :      1
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  w_Listen  # cListen;
  gKey      # cKey;

  Lib_MoreBufs:Init(833);

  if ("Set.Mech.Titel.Härte"<>'') then begin
    vHdl # winsearch(aEvt:obj, 'lbMQu.M.Von.Hrte');
    if (vHdl<>0) then
      vHdl->wpcaption # "Set.Mech.Titel.Härte";
  end;
  if ("Set.Mech.Titel.Körn"<>'') then begin
    vHdl # winsearch(aEvt:obj, 'lbMQu.M.Von.Krnung');
    if (vHdl<>0) then
      vHdl->wpcaption # "Set.Mech.Titel.Körn";
  end;

  if ("Set.Mech.Titel.Rau1"<>'') then begin
    vHdl # winsearch(aEvt:obj, 'lbMQu.M.Von.RauigO');
    if (vHdl<>0) then
      vHdl->wpcaption # "Set.Mech.Titel.Rau1";
  end;
  if ("Set.Mech.Titel.Rau2"<>'') then begin
    vHdl # winsearch(aEvt:obj, 'lbMQu.M.Von.RauigU');
    if (vHdl<>0) then
      vHdl->wpcaption # "Set.Mech.Titel.Rau2";
  end;

  Lib_Guicom2:Underline($edMQu.M.BeiGuetenstufe);
  
  SetStdAusFeld('edMQu.M.BeiGuetenstufe' ,'Guetenstufe');

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

  if (mode=c_ModeView) then begin
    Lib_MoreBufs:ReadAll(833);
    Lib_MoreBufs:GetBuf(231, '');
    Recbufcopy(231, gMDi->wpDbRecBuf(231));
  end;


  if (aName='') or ((aName='Lb.Guete') or (aName='Lb.Nummer'))then begin
    $Lb.Guete  -> wpCaption # "MQu.Güte1";
    $Lb.Nummer -> wpCaption # AInt(MQu.M.lfdNr);
  end;

  if (aName='') or (aName='edMQu.M.BeiGuetenstufe') then begin
    Erx # RecLink(848,833,1,_reCFirst);   // Stufe holen
    if (Erx>=_rLocked) then RecBufClear(848);
    $lb.Guetenstufe->wpcaption # MQu.S.Name;
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
  if (Mode=c_ModeEdit) then begin
    Lib_MoreBufs:RecInit(833, false);
  end;
  if (Mode=c_ModeNew) then begin
    Lib_MoreBufs:RecInit(833, y, n);    // , new, copy
  end;
  
  Lib_MoreBufs:GetBuf(231, '');
  Recbufcopy(231, gMDi->wpDbRecBuf(231));

  // Focus setzen auf Feld:
  $edMQu.M.bisDicke->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vNr   : int;
  vBuf  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  // Nummernvergabe
  "MQu.M.GütenID" # MQu.ID;

  // Analyse setzen
  vBuf # Lib_MoreBufs:GetBuf(231, '');
  RecBufCopy(gMDI->wpDbRecBuf(231), vBuf);
  vBuf->Lys.Anlage.Datum  # Today;
  vBuf->Lys.Anlage.Zeit   # Now;
  vBuf->Lys.Anlage.User   # gUsername;

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

    vNr # 0;
    REPEAT
      vNr # vNr + 1;
      MQu.M.lfdNr # vNr;
      Erx # RekInsert(gFile,0,'MAN');
    UNTIL (Erx = _rOk);

    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  // Analyse speichern
  Erx # Lib_MoreBufs:SaveAll(833, true);
  if (erx<>_rOK) then begin
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
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
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  Erx # RekDelete(gFile,0,'MAN');
  if (Erx=_rOK) then begin
    if (Lib_MoreBufs:DeleteAll(833)<>_rOK) then begin
      RETURN;
    end;
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
    'Guetenstufe' : begin
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenstufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;


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
    "MQu.M.BeiGütenstufe" # MQu.S.Stufe;
  end;
  // Focus auf Editfeld setzen:
  $edMQu.M.BeiGuetenstufe->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_M_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_M_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_M_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_M_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_M_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MQu_M_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;

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
    'bt.Guetenstufe'      : Auswahl('Guetenstufe');
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
  if ((aName =^ 'edMQu.M.BeiGuetenstufe') AND (aBuf->"MQu.M.BeiGütenstufe"<>'')) then begin
    RekLink(848,833,1,0);   // Gütenstufe holen
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================