@A+
//==== Business-Control ==================================================
//
//  Prozedur    Adr_V_Z_Main
//                  OHNE E_R_G
//  Info
//
//
//  20.01.2020  AH  Erstellung der Prozedur (Aus Ein_Z_Main)
//  04.04.2022  AH  ERX
//  12.07.2022  HA  Quick Jump
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
//    SUB AusSchluessel()
//    SUB AusSchluessel2()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked
//    SUN EvtChanged
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Aufpreise'
  cFile :     104
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Adr_V_Z'
  cZList :    $ZL.Adr.V.Aufpreise
  cKey :      1
end;

declare Auswahl(aBereich : alpha);

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle)
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  Lib_Guicom2:Underline($edAdr.V.Z.Schluessel);

  SetStdAusFeld('edAdr.V.Z.Schluessel'     ,'Schluessel');
  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edAuf.Z.PEH);
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
end;
begin

  if (Apl_data:HoleAufpreis("Adr.V.Z.Schlüssel", today)=_rNoRec) then begin
    ApL.L.Bezeichnung.L1 # '???';
  end;
  $lbBezeichnung->wpcaption # ApL.L.Bezeichnung.L1;

  if (aName='') then begin
    $lbKunde->wpcaption # Adr.Stichwort;
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
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then begin
    Adr.V.Z.Adressnr  # Adr.V.Adressnr;
    Adr.V.Z.VpgNr     # Adr.V.lfdNr;
  end;

  $edAdr.V.Z.Schluessel->WinFocusSet(true);
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
    Adr.V.Z.lfdNr # 1;
    REPEAT
      Erx # RekInsert(gFile,0,'MAN');
      if (Erx<>_rOK) then inc(Adr.V.Z.lfdNr);
    UNTIL (Erx = _rOk);
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
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
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
local begin
  Erx   : int;
  vA    : alpha;
  vSel  : alpha;
  vHdl  : int;
  vQ    : alpha(4000);
end;
begin

  case aBereich of
    'Schluessel' : begin

      // Ankerfunktion
      if (RunAFX('APL.Auswahl','104')<0) then RETURN;

      if (RecInfo(842,_recCount)=1) then begin
        Erx # RecRead(842,1,_recFirst);
        Auswahl('Schluessel2');
        RETURN;
      end;

      RecBufClear(842);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Apl.Verwaltung',here+':AusSchluessel');

      // Selektion
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList( 0, 'ApL.VerkaufYN' );

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Schluessel2' : begin
      RecBufClear(843);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Apl.L.Verwaltung',here+':AusSchluessel2');
      // Selektion
      VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
      vQ # 'ApL.L.Key1 = ' + cnvAI(ApL.Key1);
      vQ # vQ + ' AND ApL.L.Key2 = ' + cnvAI(ApL.Key2) ;
      vQ # vQ + ' AND ApL.L.Key3 = ' + cnvAI(ApL.Key3);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusSchluessel
//
//========================================================================
sub AusSchluessel()
begin
  if (gSelected<>0) then begin
    RecRead(842,0,_RecId,gSelected);
    $edAdr.V.Z.Schluessel->wpCustom # 'xx';
    // Event für Anschriftsauswahl starten
    Auswahl('Schluessel2');
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Z.Schluessel->Winfocusset(true);
end;


//========================================================================
//  AusSchluessel2
//
//========================================================================
sub AusSchluessel2()
begin
  // Zugriffliste wieder aktivieren
  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(843,0,_RecId,gSelected);
    //Auf.Z.Schluessel #
    gSelected # 0;
    "Adr.V.Z.Schlüssel" # '#'+Cnvai(ApL.L.Key2,_fmtnumleadzero,0,4)+'.'+CnvAI(ApL.L.Key3,_fmtnumleadzero,0,4)+'.'+cnvai(ApL.L.Key4,_fmtnumleadzero,0,4);
    RefreshIfm();
    gMDI->winupdate();
  end;
  // Focus auf Editfeld setzen:
  $edAdr.V.Z.Schluessel->Winfocusset(true);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_V_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_V_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_V_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_V_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Import]=false;

  RefreshIfm();

end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // MenüAuftrag
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
    'bt.Schluessel'   :   Auswahl('Schluessel');
  end;

end;


//========================================================================
//  EvtChanged
//              Feldinhalt verändert
//========================================================================
sub EvtChanged (
  aEvt                  : event;        // Ereignis
) : logic
begin
  if (aEvt:Obj->wpchanged=false) then RETURN true;
  if (Mode=c_ModeView) then RETURN true;
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
  if (Apl_data:HoleAufpreis("Adr.V.Z.Schlüssel", today)=_rNoRec) then begin
    ApL.L.Bezeichnung.L1 # '???';
  end;
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
end;


//========================================================================
// EvtClose
//          Schliessen Aufes Fensters
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


  if ((aName =^ 'edAdr.V.Z.Schluessel') AND (aBuf->"Adr.V.Z.Schlüssel"<>'')) then begin
    RekLink(0,104,1,0);   // Schlüssel holen
    Lib_Guicom2:JumpToWindow('Apl.Verwaltung');
    RETURN;
  end;
  
  
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================