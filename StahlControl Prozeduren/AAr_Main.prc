@A+
//==== Business-Control ==================================================
//
//  Prozedur    AAr_Main
//                    OHNE E_R_G
//  Info
//
//  11.11.2003  ST  Erstellung der Prozedur
//  24.09.2012  AI  Statistik eingebaut
//  02.08.2016  AH  AFX "AAr.Init"
//  15.11.2017  ST  Aufruf der Customfelder hinzugefügt
//  01.02.2022  ST  E r g --> Erx
//  11.07.2022  HA  Quick Jump

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
//    SUB AusArbeitsgang()
//    SUB AusRessource()
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
  cTitle :    'Auftragsarten'
  cFile :     835
  cMenuName : 'AAr.Bearbeiten'
  cPrefix :   'AAR'
  cZList :    $ZL.Auftragsarten
  cKey :      1
  cListen :   'Auftragsarten'
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vMdi  : int;
end;
begin
  vMDI      # gMDI;

  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen  # cListen;

 // Underline setzen...
  Lib_Guicom2:Underline($edAAr.Lohn.Aktion);
  Lib_Guicom2:Underline($edAAr.Lohn.Ressource);
  
  SetStdAusFeld('edAAr.Lohn.Aktion'     ,'Arbeitsgang');
  SetStdAusFeld('edAAr.Lohn.Ressource'  ,'Ressource');
  SetStdAusFeld('edAAr.Lohn.Res.Gruppe' ,'Ressource');

  App_Main:EvtInit(aEvt);

  RunAFX('AAr.Init',aint(aEvt:Obj)+'|'+aint(vMDI));

  RETURN true;
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;
  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edAAr.Berechnungsart);
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
  vTmp  : int;
end;
begin

  if (Mode=c_modeedit) or (Mode=c_ModeNew) then begin
    if (AAr.Berechnungsart<700) or (AAr.Berechnungsart>799) then begin
      AAr.Lohn.Ressource  # 0;
      AAr.Lohn.Res.Gruppe # 0;
      AAr.Lohn.Aktion     # '';
      Lib_Guicom:Disable($edAAr.Lohn.Ressource);
      Lib_Guicom:Disable($edAAr.Lohn.Res.Gruppe);
      Lib_Guicom:Disable($edAAr.Lohn.Aktion);
      end
    else begin
      Lib_Guicom:Enable($edAAr.Lohn.Ressource);
      Lib_Guicom:Enable($edAAr.Lohn.Res.Gruppe);
      Lib_Guicom:Enable($edAAr.Lohn.Aktion);
    end;
  end;

  Erx # RecLink(828,835,1,_recFirst);   // Arbeitsgang holen
  if (Erx>_rLocked) then RecBufClear(828);
  $lb.Arbeitsgang->wpcaption # ArG.Bezeichnung;

  Erx # RecLink(160,835,2,_RecFirst);   // Ressource holen
  if (Erx>_rLocked) then RecBufClear(160);
  $lb.Ressource->wpcaption # Rso.Stichwort;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

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
  if (Mode=c_ModeNew) then
    AAr.ReservierePosYN # y;

  // Focus setzen auf Feld:
  $edAAr.Nummer->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
end
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if (AAr.Berechnungsart<>250) and
    (AAr.Berechnungsart<>700) and
    (AAr.Berechnungsart<>710) and
    (AAr.Berechnungsart<>180) and
    (AAr.Berechnungsart<>100) and
    (AAr.Berechnungsart<>200) then begin
    Msg(001201,Translate('Berechnungsart'),0,0,0);
    $edAAr.Berechnungsart->WinFocusSet(true);
    RETURN false;
  end;

  // NummernvErxabe

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
    'Ressource' : begin
      RecBufClear(160);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Verwaltung',here+':AusRessource');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Arbeitsgang' : begin
      RecBufClear(828);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Arg.Verwaltung',here+':AusArbeitsgang');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusArbeitsgang
//
//========================================================================
sub AusArbeitsgang()
begin
  if (gSelected<>0) then begin
    RecRead(828,0,_RecId,gSelected);
    // Feldübernahme
    AAr.Lohn.Aktion  # ArG.Aktion2;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edAAr.Lohn.Aktion->Winfocusset(false);
end;


//========================================================================
//  AusRessource
//
//========================================================================
sub AusRessource()
begin
  if (gSelected<>0) then begin
    RecRead(160,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    AAr.Lohn.Res.Gruppe # Rso.Gruppe;
    AAr.Lohn.Ressource  # Rso.Nummer;
    $edAAr.Lohn.Ressource->WinUpdate();
    $edAAr.Lohn.Res.Gruppe->WinUpdate();
  end;
  $edAAr.Lohn.Ressource->Winfocusset(false);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_AAr_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_AAr_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_AAr_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_AAr_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_AAr_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_AAr_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) then RefreshIfm();

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
  vHdl      : int;
  vMode     : alpha;
  vTmp      : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

   'Mnu.OSt' : begin
      if (Rechte[Rgt_OSt_AAr]=n) then begin
        Msg(890000,'',0,0,0);
        RETURN true;
      end;
      Lib_COM:DisplayOSt( 'AUFART:' + CnvAI( AAr.Nummer ), -1, 'Auftragsart ' + AInt( AAr.Nummer ) + ', ' + AAr.Bezeichnung );
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;

    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
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
    'bt.Arbeitsgang':   Auswahl('Arbeitsgang');
    'bt.Ressource'  :   Auswahl('Ressource');
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


//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  
  if ((aName =^ 'edAAr.Lohn.Aktion') AND (aBuf->AAr.Lohn.Aktion<>'')) then begin
    RekLink(828,835,1,0);   //  Arbeitsgang holen
    Lib_Guicom2:JumpToWindow('Arg.Verwaltung');
    RETURN;
  end;
  
 
  if ((aName =^ 'edAAr.Lohn.Ressource') AND (aBuf->AAr.Lohn.Ressource<>0)) then begin
    RekLink(160,835,2,0);   //  Ressource holen
    Lib_Guicom2:JumpToWindow('Rso.Verwaltung');
    RETURN;
  end;
  
end;
//========================================================================
//========================================================================
//========================================================================
//========================================================================