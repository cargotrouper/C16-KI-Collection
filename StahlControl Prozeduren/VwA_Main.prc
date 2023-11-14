@A+
//==== Business-Control ==================================================
//
//  Prozedur    VwA_Main
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  17.07.2012  ST  Nur ein Haken (Brutto oder Netto) Projekt 1326/266
//  28.06.2013  AH  Korrektur der Buttonchanged
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RefreshIfm(optaName : alpha)
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
//    SUB EvtChanged(  aEvt: event;) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Verwiegungsarten'
  cFile :     818
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'VwA'
  cZList :    $ZL.Verwiegungsarten
  cKey :      1
  cListen : 'Verwiegungsarten'
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

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  // Focus setzen auf Feld:
  $edVwA.Nummer->WinFocusSet(true);

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
  if (VwA.NettoYN=n) and (VwA.BruttoYN=n) then begin
    Msg(001200,Translate('Bestandsführung'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $cbVwA.NettoYN->WinFocusSet(true);
    RETURN false;
  end;

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
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  RETURN true;  // Speichern erfolgreich
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
    Lib_GuiCom:AuswahlEnable( aEvt:obj );
  else
    Lib_GuiCom:AuswahlDisable( aEvt:obj );
end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // zu verlassendes Objekt
) : logic
begin

  // logische Prüfung von Verknüpfungen
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

  // Button sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_VwA_Anlegen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_VwA_Anlegen]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_VwA_aendern]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_VwA_aendern]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_VwA_loeschen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_VwA_loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


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
  vMode : alpha;
  vParent : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'NextPage' : begin
          //vHdl # gMdi->Winsearch('NB.Main');
          // durch Seiten cyclen
          //if vHdl->wpcurrent='NB.Page1' then vHdl->wpcurrent # 'NB.Page2'
          //else
          //if vHdl->wpcurrent='NB.Page2' then vHdl->wpcurrent # 'NB.Page3'
          //else
          //if vHdl->wpcurrent='NB.Page3' then vHdl->wpcurrent # 'NB.Page1';
      end;

    'PrevPage' : begin
          //vHdl # gMdi->Winsearch('NB.Main');
          // durch Seiten cyclen
          //if vHdl->wpcurrent='NB.Page3' then vHdl->wpcurrent # 'NB.Page2'
          //else
          //if vHdl->wpcurrent='NB.Page1' then vHdl->wpcurrent # 'NB.Page3'
          //else
          //if vHdl->wpcurrent='NB.Page2' then vHdl->wpcurrent # 'NB.Page1';
      end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;

  end;
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  if Mode=c_ModeView then RETURN true;

  case (aEvt:Obj->wpName) of

    //'...' :   Auswahl('...');

    //'...' : begin // simuliere Menücommand
    //  EvtMenuCommand(null,aEvt:Obj);
    //end;

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
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURn true;
end;


//========================================================================
//  EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbVwA.NettoYN') AND
        ($cbVwA.NettoYN->wpCheckstate  = _WinStateChkChecked) then
    VwA.BruttoYN # n;

  if (aEvt:Obj->wpname='cbVwA.BruttoYN') AND
        ($cbVwA.BruttoYN->wpCheckstate  = _WinStateChkChecked) then
    VwA.NettoYN # n;

  $cbVwA.NettoYN->winupdate(_WinUpdFld2Obj);
  $cbVwA.BruttoYN->winupdate(_WinUpdFld2Obj);

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================

//========================================================================