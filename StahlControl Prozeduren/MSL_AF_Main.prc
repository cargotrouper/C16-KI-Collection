@A+
//==== Business-Control ==================================================
//
//  Prozedur    MSL_AF_Main
//                  OHNE E_R_G
//  Info
//
//
//  01.09.2008  AI  Erstellung der Prozedur (Vorlage: Mat_AF_Main)
//  06.05.2011  TM  neue Auswahlmethode 1326/75
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
  cTitle    : 'Ausführung'
  cFile     : 221
  cMenuName : 'Std.Bearbeiten'
  cPrefix   : 'MSL_AF'
  cZList    : $ZL.MSL.AF
  cKey      : 1
end;

declare Auswahl(aBereich : alpha)

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit( aEvt  : event; ) : logic
begin
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edMSL.AF.ObfNr);

  SetStdAusFeld('edMSL.AF.ObfNr','Oberflaeche');

  App_Main:EvtInit( aEvt );
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
  if ( aName='edMSL.AF.ObfNr' ) and ( $edMSL.AF.ObfNr->wpChanged ) then begin
    if ( RecLink( 841, 221, 1, 0 ) <= _rLocked ) then
      $lbMSL.AF.Bezeichnung->wpCaption # Obf.Bezeichnung.L1;
    else
      $lbMSL.AF.Bezeichnung->wpCaption # '';
  end;

  // veränderte Felder in Objekte schreiben
  if ( aName != '' ) then begin
    vTmp # gMdi->WinSearch( aName );
    if ( vTmp != 0 ) then
     vTmp->WinUpdate( _winUpdFld2Obj );
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
  if ( Mode = c_ModeNew ) then begin
    MSL.AF.Nummer # MSL.Nummer;
    MSL.AF.Seite  # $NB.Main->wpCustom;
    $edMSL.AF.ObfNr->wpcustom # 'F9';
  end;

  // Focus setzen auf Feld:
  $edMSL.AF.ObfNr->WinFocusSet( true );
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
  if ( Mode = c_ModeEdit ) then begin
    Erx # RekReplace( gFile, _recUnlock, 'MAN' );
    if ( Erx != _rOk ) then begin
      Msg( 001000 + Erx, gTitle, 0, 0, 0 );
      RETURN false;
    end;
    PtD_Main:Compare( gFile );
  end
  else begin
    Erx # RekInsert( gFile, 0, 'MAN' );
    if ( Erx != _rOk ) then begin
      Msg( 001000 + Erx, gTitle, 0, 0, 0 );
      RETURN false;
    end;
  end;

  RETURN true; // Speichern erfolgreich
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
  if ( Msg( 000001, '', _winIcoQuestion, _winDialogYesNo, 2 ) = _winIdNo ) then
    RETURN;

  RekDelete( gFile, 0, 'MAN' );
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

  if (aEvt:Obj->wpname='edMSL.AF.ObfNr') then
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
  RefreshIfm( aEvt:Obj->wpName );

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
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung','MSL_AF_Main:AusOberflaeche');
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
  if (gSelected != 0) then begin
    RecRead( 841, 0, _recId, gSelected );
    gSelected # 0;
    MSL.AF.ObfNr # Obf.Nummer;
    gMDI->winupdate(_WinUpdFld2Obj);
    $edMSL.AF.Zusatz.Von->winfocusSet(false);
    RefreshIfm('edMSL.AF.ObfNr');
    RETURN;
  end;
  // Focus auf Editfeld setzen:
  $edMSL.AF.ObfNr->WinFocusSet( false );
//  RefreshIfm('edMSL.AF.ObfNr');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_P_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_P_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_EK_P_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_EK_P_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_EK_P_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_EK_P_Loeschen]=n);

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
    'bt.ObfNr' : Auswahl('Oberflaeche');
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
  if ( RecLink( 841, 221, 1, 0 ) <= _rLocked ) then
    Gv.Alpha.01 # Obf.Bezeichnung.L1;
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

  if ((aName =^ 'edMSL.AF.ObfNr') AND (aBuf->MSL.AF.ObfNr<>0)) then begin
    RekLink(841,221,1,0);   // Ausührung holen
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================