@A+
//==== Business-Control ==================================================
//
//  Prozedur    Kal_P_Main
//                    OHNE E_R_G
//  Info
//
//
//  31.07.2007  AI  Erstellung der Prozedur
//  05.05.2011  TM  neue Auswahlmethode 1326/75
//  09.06.2022  AH  ERX
//  22.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLieferant()
//    SUB AusVertreter()
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
  cTitle      : 'Kalkulations - Positionen'
  cFile       :  831
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'Kal_P'
  cZList      : $ZL.Kal.P
  cKey        : 1
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

Lib_Guicom2:Underline($edKal.P.LieferantenNr);
Lib_Guicom2:Underline($edKal.P.VertreterNr);


  // Auswahlfelder setzen...
  SetStdAusFeld('edKal.P.LieferantenNr','Lieferant');
  SetStdAusFeld('edKal.P.Termin.Art'   ,'Termin');
  SetStdAusFeld('edKal.P.MEH'          ,'MEH');
  SetStdAusFeld('edKal.P.VertreterNr'  ,'Vertreter');

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
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin

  if (aName='') or (aName='edKal.P.LieferantenNr') then begin
    Erx # RecLink(100,831,1,0);   // hole Lieferant zu Kal.Position
    if (Erx<=_rLocked) and (Adr.Lieferantennr<>0) then
      $lb.LieferantKalk->wpcaption # Adr.Stichwort
    else
      $lb.LieferantKalk->wpcaption # '';
  end;

  if (aName='') or (aName='edKal.P.VertreterNr') then begin
    Erx # RecLink(110,831,2,0);   // hole Vertreter zu Kal.Position
    if (Erx<=_rLocked) and (Ver.Nummer<>0) then
      $lb.VertreterKalk->wpcaption # Ver.Stichwort
    else
      $lb.VertreterKalk->wpcaption # '';
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

  // Neuanlage?
  if (Mode=c_ModeNew) then begin
    Kal.P.Nummer        # Kal.Nummer;
    Kal.P.LfdNr         # 1;
    Kal.P.MEH           # 'kg';
    Kal.P.PEH           # 1000;
    Kal.P.Termin.Art    # 'KW';
    Kal.P.MengenbezugYN # n;
  end;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edKal.P.Bezeichnung->WinFocusSet(true);
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
  Erx # RecLink(100,831,1,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lieferant'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edKal.P.LieferantenNr->WinFocusSet(true);
    RETURN false;
  end;

  Erx # RecLink(100,831,1,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Vertreter'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edKal.P.VertreterNr->WinFocusSet(true);
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
    Kal.P.Anlage.Datum  # Today;
    Kal.P.Anlage.Zeit   # Now;
    Kal.P.Anlage.User   # gUserName;

    // eindeutigkeit prüfen
    WHILE (RecRead(gFile,1,_RecTest,0)<=_Rlocked) do
      Kal.P.LfdNr # Kal.P.Lfdnr + 1;

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

/***
  if (aEvt:Obj->wpname='jump') then begin
    case (aEvt:Obj->wpcustom) of
      'Page1Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false)
        end;
      'Page1E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false);
        end;
    end;
    RETURN true;
  end;
***/

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

  if ((aEvt:Obj->wpname='edKal.P.Termin.Zahl') or (aEvt:Obj->wpname='edKal.P.Termin.Jahr')) and
    (($edKal.P.Termin.Zahl->wpchanged) or ($edKal.P.Termin.Jahr->wpchanged)) then begin
    Lib_Berechnungen:Datum_aus_ZahlJahr(Kal.P.Termin.Art, var Kal.P.Termin.Zahl, var Kal.P.Termin.Jahr, var Kal.P.Termin);
    $edKal.P.Termin->winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpname='edKal.P.Termin') and
    ($edKal.P.Termin->wpchanged) then begin
    Lib_Berechnungen:ZahlJahr_aus_Datum( Kal.P.Termin, Kal.P.Termin.Art, var Kal.P.Termin.Zahl,var Kal.P.Termin.Jahr);
    $edKal.P.Termin.Zahl->winupdate(_WinUpdFld2Obj);
    $edKal.P.Termin.Jahr->winupdate(_WinUpdFld2Obj);
  end;

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

    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusLieferant');
    //  ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Vertreter' : begin
      RecBufClear(110);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ver.Verwaltung',here+':AusVertreter');
    //  ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edKal.P.MEH, 831,1,10);
    end;

    'Termin' : begin
      Lib_Einheiten:Popup('Datumstyp',$edKal.P.Termin.Art, 831,1,5);
    end;

  end;

end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
begin

  if (gSelected<>0) then begin

    RecRead(100, 0,_RecId, gSelected);
    gSelected # 0;
    // Feldübernahme
    Kal.P.Lieferantennr # Adr.Lieferantennr;
  end;

  // Focus auf Editfeld setzen:
  $edKal.P.LieferantenNr->Winfocusset(false);

  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;



//========================================================================
//  AusVertreter
//
//========================================================================
sub AusVertreter()
begin

  if (gSelected<>0) then begin

    RecRead(110, 0,_RecId, gSelected);
    gSelected # 0;
    // Feldübernahme
    Kal.P.Vertreternr # Ver.Nummer;
  end;

  // Focus auf Editfeld setzen:
  $edKal.P.VertreterNr->Winfocusset(false);

  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kal_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kal_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kal_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kal_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kal_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kal_Loeschen]=n);

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
  vHdl : int;
  vTmp : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Kal.P.Anlage.Datum, Kal.P.Anlage.Zeit, Kal.P.Anlage.User);
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
    'bt.Lieferant' :   Auswahl('Lieferant');
    'bt.Terminart' :   Auswahl('Termin');
    'bt.MEH'       :   Auswahl('MEH');
    'bt.Vertreter' :   Auswahl('Vertreter');
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

  if ((aName =^ 'edKal.P.LieferantenNr') AND (aBuf->Kal.P.LieferantenNr<>0)) then begin
    RekLink(100,831,1,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edKal.P.VertreterNr') AND (aBuf->Kal.P.VertreterNr<>0)) then begin
    RekLink(110,831,2,0);   // Vertreter holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
