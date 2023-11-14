@A+
//==== Business-Control ==================================================
//
//  Prozedur    LPl_Main
//                        OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  15.02.2008  ST  Einlesen von Inventurdateien hinzugefügt
//  29.06.2009  TM  Löschen aller Inventurdateien eingefügt
//  29.06.2009  TM  Einlesen  mehrerer Lagerplätze eingefügt
//  30.06.2009  TM  Verbuchen mehrerer Lagerplätze eingefügt
//  03.09.2009  TM  Scanner-Umlagerung verknüpft (Funktion wie aus Betriebsmenü)
//  25.06.2012  ST  Erweiterung Inventurfunktionen laut Projekt 1326/246 und Auftrennung
//                  in Lpl_Main und Lpl_Data
//  20.09.2012  ST  @I:Lib_Strings entfernt
//  18.03.2022  AH  Excel Export/Import, ERX
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
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Lagerplätze'
  cFile :     844
  cMenuName : 'Lpl.Bearbeiten'
  cPrefix :   'LPl'
  cZList :    $ZL.Lagerplaetze
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
  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder
  // Pflichtfelder
  //Lib_GuiCom:Pflichtfeld($);
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
  // Focus setzen auf Feld:
  $edLPl.Lagerplatz->WinFocusSet(true);
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

  // ST 2012-06-25,1326/246: Info bei zu langem Text für Inventur
  if (StrLen(Lpl.Lagerplatz) > 15) then begin
    // Meldung: Lagerplatz zulang für Standardinventur, aber nur zur Info
    Msg(844023,'',_WinIcoError,_WinDialogOk,1);
  end;


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

  // Auswahlfelder aktivieren
  if (aEvt:Obj->wpname='xxxxx') or
    (aEvt:Obj->wpname='xxxxx') or
    (aEvt:Obj->wpname='xxxxx') then
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LPl_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LPl_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_LPl_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_LPl_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_LPl_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_LPl_Loeschen]=n);


  vHdl # gMdi->WinSearch('Mnu.InventurLpl');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LPl_InvTransfer]=n);

  vHdl # gMdi->WinSearch('Mnu.InventurEinlesen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LPl_InvImport]=n);

  vHdl # gMdi->WinSearch('Mnu.InventurEinlesenAll');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LPl_InvImport]=n);

  vHdl # gMdi->WinSearch('Mnu.InventurDeleteAll');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LPl_InvDelete]=n);

  vHdl # gMdi->WinSearch('Mnu.InventurUebernehmen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LPl_InvVerbuchen]=n);

  vHdl # gMdi->WinSearch('Mnu.InventurUebernehmenAll');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LPl_InvVerbuchen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);

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
  Erx       : int;
  vHdl      : int;
  vMode     : alpha;
  vParent   : int;
  vTextinfo : alpha;
  vPath     : alpha;
  vTmp      : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Druck.Lagerplaetze' : begin
      Lib_Dokumente:Printform(844,'Lagerplaetze',true);
    end;
    
     'Mnu.Druck.LagerplaetzeList' : begin
      Lib_Dokumente:Printform(844,'LagerplaetzeBarcode_List',true);
    end;


    'Mnu.Druck.LagerplatzetikettKlein' : begin
      Lib_Dokumente:Printform(844,'LagerplatzetikettK',true);
    end;


    'Mnu.Druck.Lagerplatzetikett' : begin
      Lib_Dokumente:Printform(844,'Lagerplatzetikett',true);
    end;


    'Mnu.Auswahl' : begin
      vHdl # WinFocusGet();
      if (vHdl<>0) then begin
        case (vHdl->wpname) of
           'edxxx.xxxxxx' :   Auswahl('...');
        end;
      end;
    end;


    'Mnu.InventurEinlesen': begin

      // Einlesen einer Inventurdatei...
      Erx # Lpl_Data:InvFileCheck(Lpl.Lagerplatz);
      if (Erx = 0) then begin
        // Inventurdatei ist noch nicht vorhanden

        // Datei Einlesen
        if ( Lpl_Data:InvFileLoad(Lpl.Lagerplatz)) then
          Msg(844001 ,'',_WinIcoInformation,_WinDialogOk,1);
        else
          Msg(844002 ,'',_WinIcoError,_WinDialogOk,1);

      end
      else if (Erx = 1) then begin
        // Inventurdatei ist schon vorhanden

        vTextinfo #  Lpl_Data:InvGetInfoFromText(Lpl.Lagerplatz);

        // ggf. Text löschen und dann einlesen
        if (Msg(844000 ,vTextinfo,_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

          // Zuerst die vorhandene Datei löschen
          if ( Lpl_Data:InvFileDelete(Lpl.Lagerplatz)) then begin

            if ( Lpl_Data:InvFileLoad(Lpl.Lagerplatz)) then begin
              // Lagerplatz markieren
              Lib_Mark:MarkAdd(844,true);

              // Erfolgsmeldung
              Msg(844001 ,'',_WinIcoInformation,_WinDialogOk,1);
            end else
              // Fehler beim Einlesen
              Msg(844002 ,'',_WinIcoError,_WinDialogOk,1);

          end else
            //Fehler beim Löschen
            Msg(844004 ,'',_WinIcoError,_WinDialogOk,1);

        end;

      end
      else if (Erx = 2) then begin
        // FEHLER: Zu langer Lagerplatzname
        Msg(844003 ,'',_WinIcoError,_WinDialogOk,1);
      end;

    end; // EO Inventur


    'Mnu.InventurUebernehmen': begin
       Lpl_Data:InvVerbuchen();
    end;


    // Gesteuerte Inventur für diesen Lagerplatz
    'Mnu.InventurLpl': begin

      // Einscannen
      Msg(844008 ,'',_WinIcoInformation,_WinDialogOk,1);
      // Daten vom Scanner auslesen
      vPath #  Lpl_Data:InvLoadDataCPT711();
      if (vPath = '') then begin
        Msg(844009 ,'',0,_WinDialogOk,1);
        return false;
      end;

      // Daten in Text lesen
      if (! Lpl_Data:InvFileLoad(Lpl.Lagerplatz,vPath)) then begin
        Msg(844010 ,'',_WinIcoInformation,_WinDialogOk,1);
        return false;
      end;


      // Text aufbereiten
      // Nach ILP_ Eintrag suchen -> Prüfen ob dieser mit Lpl.Name übereinstimmt
      // Alle Einträge die nicht mit IMT_ anfangen entfernen
      // alle IMT_ Prefixe entfernen
      if ( Lpl_Data:InvPrepare( Lpl_Data:InvGetTextName(Lpl.Lagerplatz),'ILP_','IMT_',Lpl.Lagerplatz)) then begin
        // Lagerplatz markieren
        Lib_Mark:MarkAdd(844, true);

        // Listen Anzeigen
        Lfm_Ausgabe:Starten('',844002);      // a) Material am richtigen Lagerplatz
        Lfm_Ausgabe:Starten('',844003);      // b) Material am falschen Lagerplatz
        Lfm_Ausgabe:Starten('',844004);      // c) in Inventur fehlendes Material an diesem LPL
        Lfm_Ausgabe:Starten('',844005);      // d) eingescanntes Material nicht gefunden

        // Verbuchen mit Frage
         Lpl_Data:InvVerbuchen();
      end else begin
        Msg(844011 ,'',_WinIcoInformation,_WinDialogOk,1);
      end;

    end;


    'Mnu.InventurAll' : begin

      // Einscannen
      Msg(844019 ,'',_WinIcoInformation,_WinDialogOk,1);

      // Daten vom Scanner auslesen
      vPath #  Lpl_Data:InvLoadDataCPT711();
      if (vPath = '') then begin
        Msg(844009 ,'',0,_WinDialogOk,1);
        return false;
      end;

      // Daten in Text lesen
      if (! Lpl_Data:InvFileLoadAll(Lpl.Lagerplatz,vPath)) then begin
        Msg(844010 ,'',_WinIcoInformation,_WinDialogOk,1);
        return false;
      end;
    end;

    'Mnu.InventurEinlesenAll' : begin
       Lpl_Data:InvFileLoadAll(Lpl.Lagerplatz);
    end;


    'Mnu.InventurDeleteAll' : begin
      // Sind Sie sicher dass alle temporären Inventurdaten gelöscht werden sollen?
      if (Msg(844021 ,vTextinfo,_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then
        Lpl_Data:InvFileDeleteAll();
    end;


    'Mnu.InventurUebernehmenAll' : begin
       Lpl_Data:InvVerbuchenAll();
    end;


    'Mnu.UmlagerungEinlesen': begin

      // ---- Umlagerungsfunktion wie in Mdi.Betrieb -----
      Msg(844012 ,'',_WinIcoInformation,_WinDialogOk,1);
      if (Mat_Subs:UmlagernScanner()) then
        // alles IO
        Msg(844013 ,'',_WinIcoInformation,_WinDialogOk,1);
      else
        // Fehler
        Msg(844014 ,'',_WinIcoInformation,_WinDialogOk,1);
      // -------------------------------------------------

    end;

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
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
  end;

end;


//========================================================================
//  EvtPageSelect
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin
  RETURN true;
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
// EvtChanged
//   MS 22.10.2009
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
)
: logic;
local begin
  vRange    : range;
  vRangeEnd : range;
end;
begin

  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  RETURN false; // MS 30.11.2009 freie eingabe wieder möglich, hinweistext in maske hinzugefuegt

  vRangeEnd:min # -1;
  vRangeEnd:max # -1;

  // letzte Cursorposition merken
  vRange # aEvt:Obj->wpRange;

  // Zeichen wandeln

  aEvt:Obj->wpCaption # StrCnv(aEvt:Obj->wpCaption,_StrLetter);

  //if(vRange <> vRangeEnd) then begin
    // Cursor an die letzte bekannte Position setzen
    //aEvt:Obj->wpRange # vRange;
  //end
  //else begin
    // Cursor hinter das letzte Zeichen setzen
  if (gKey != _WinKeyDelete) then aEvt:Obj->wpRange # RangeMake(-1,-1);
  //aEvt:Obj->wpRange # vRange;
  //end;

  return(true);
end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================