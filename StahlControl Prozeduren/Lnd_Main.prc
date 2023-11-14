@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lnd_Main
//                    OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//  25.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB RefreshIfm(optaName : alpha)
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusSteuerschluessel()
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
  cTitle :    'Länder'
  cFile :     812
  cMenuName : 'Lnd.Bearbeiten'
  cPrefix :   'Lnd'
  cZList :    $ZL.Laender
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

Lib_Guicom2:Underline($edLnd.Steuerschluessel);

  SetStdAusFeld('edLnd.Steuerschluessel','Steuerschluessel');

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
  $edLnd.Krzel->WinFocusSet(true);

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
  if ("Lnd.Steuerschlüssel"<>0) then begin
    Erx # RecLink(813,812,1,0);
    If (Erx>_rLocked) then begin // or ("Lnd.Steuerschlüssel">999) then begin   2022-07-08  AH
      Msg(001201,Translate('Steuerschlüssel'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page3';
      $edLnd.Steuerschluessel->WinFocusSet(true);
      RETURN false;
    end;
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
local begin
  Erx : int;
end;
begin

  if (aName='') then begin
    $lbLnd.Name.L1->wpcaption # Set.Sprache1;
    $lbLnd.Name.L2->wpcaption # Set.Sprache2;
    $lbLnd.Name.L3->wpcaption # Set.Sprache3;
    $lbLnd.Name.L4->wpcaption # Set.Sprache4;
    $lbLnd.Name.L5->wpcaption # Set.Sprache5;
  end;

  if (aName='') or (aName='edLnd.Steuerschluessel') then begin
    Erx # RecLink(813,812,1,0);
    if (Erx<=_rLocked) then
      $Lb.Steuerschluessel->wpcaption # StS.Bezeichnung
    else
      $Lb.Steuerschluessel->wpcaption # '';
  end;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
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
  aFocusObject          : int           // zu verlassendes Objekt
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
    'Steuerschluessel' : begin
      RecBufClear(813);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'StS.Verwaltung',here+':AusSteuerschluessel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusSteuerschluessel
//
//========================================================================
sub AusSteuerschluessel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(813,0,_RecId,gSelected);
    gSelected # 0;
    "Lnd.Steuerschlüssel" # StS.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edLnd.Steuerschluessel->Winfocusset(false);
//  RefreshIfm('edAdr.Steuerschluessel');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lnd_Anlegen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lnd_Anlegen]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lnd_aendern]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lnd_aendern]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lnd_loeschen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lnd_loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


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
  vHdl : int;
  vMode : alpha;
  vParent : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'NextPage' : begin
          vHdl # gMdi->Winsearch('NB.Main');
          // durch Seiten cyclen
          //if vHdl->wpcurrent='NB.Page1' then vHdl->wpcurrent # 'NB.Page2'
          //else
          //if vHdl->wpcurrent='NB.Page2' then vHdl->wpcurrent # 'NB.Page3'
          //else
          //if vHdl->wpcurrent='NB.Page3' then vHdl->wpcurrent # 'NB.Page1';
      end;

    'PrevPage' : begin
          vHdl # gMdi->Winsearch('NB.Main');
          // durch Seiten cyclen
          //if vHdl->wpcurrent='NB.Page3' then vHdl->wpcurrent # 'NB.Page2'
          //else
          //if vHdl->wpcurrent='NB.Page1' then vHdl->wpcurrent # 'NB.Page3'
          //else
          //if vHdl->wpcurrent='NB.Page2' then vHdl->wpcurrent # 'NB.Page1';
      end;

    'Mnu.Auswahl' : begin
        vHdl # WinFocusGet();
        if vHdl<>0 then begin
          case vHdl->wpname of
            // '...' :   Auswahl('...');
          end;
        end;
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
    'bt.Steuerschluessel'  : Auswahl('Steuerschluessel');
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

sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edLnd.Steuerschluessel') AND (aBuf->"Lnd.Steuerschlüssel"<>0)) then begin
    RekLink(813,812,1,0);   // Steuerschlüssel holen
    Lib_Guicom2:JumpToWindow('StS.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================