@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_C_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB ChargenSumme(aArtNr : Alpha) : logic;
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
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
  cTitle :    'Chargen'
  cFile :     252
  cMenuName : 'Art.C.Bearbeiten'
  cPrefix :   'Art_C'
  cZList :    $ZL.Art.Chargen
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
  gTitle      # Translate(cTitle);
  gFile       # cFile;
  gMenuName   # cMenuName;
  gPrefix     # cPrefix;
  gZLList     # cZList;
  gKey        # cKey;

  $clmArt.C.Bestand->wpcaption # Translate('Bestand')+' '+Art.MEH;
  $clmArt.C.Bestellt->wpcaption # Translate('Bestellt')+' '+Art.MEH;
  $clmArt.C.Verfuegbar->wpcaption # Translate('Verfügbar')+' '+Art.MEH;
  $clmArt.C.reserviert->wpcaption # Translate('Reserviert')+' '+Art.MEH;

  $edArt.C.Bestand->wpDecimals # Set.Stellen.Menge;
  $edArt.C.Bestellt->wpDecimals # Set.Stellen.Menge;
  $edArt.C.Reserviert->wpDecimals # Set.Stellen.Menge;
  $edArt.C.Verfgbar->wpDecimals # Set.Stellen.Menge;

  if ("Art.ChargenführungYN"=n) then begin
    $lbArt.C.Zustand->wpvisible # false;
    $lb.Zustand->wpvisible # false;
  end;

  Filter_Art_C # y;

  RETURN App_Main:EvtInit(aEvt);
end;


//========================================================================
//  EvtMdiActivate
//                  MDI-Fenster erhält Focus
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  App_Main:EvtMdiActivate(aEvt);
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_Art;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx     : int;
  vBuf401 : int;
end;
begin

// 05.02.2020  "Art.C.Verfügbar" # Art.C.Bestand + Art.C.Bestellt - Art.C.Reserviert;
  "Art.C.Verfügbar" # Art.C.Bestand - Art.C.Reserviert;
  if (Set.Art.Vrfgb.AufRst) then begin
    "Art.C.Verfügbar.Stk"   # "Art.C.Verfügbar.Stk" - Art.C.OffeneAuf.Stk;
    "Art.C.Verfügbar"       # "Art.C.Verfügbar"     - Art.C.OffeneAuf;
  end;


  gTmp # gMdi->winsearch('edArt.C.Verfgbar');
  if (gTmp<>0) then
   gTmp->winupdate(_WinUpdFld2Obj);

  if (aName='') then begin

    $edArt.C.Bestand.Stk->wpvisible # Art.MEH<>'Stk';
    $edArt.C.Fremd.Stk->wpvisible # Art.MEH<>'Stk';
    $lb.Stk1->wpvisible # Art.MEH<>'Stk';
    $lb.Stk2->wpvisible # Art.MEH<>'Stk';

    Erx # RecLink(100,252,6,_RecFirst);   // Lieferant holen
    if (Erx=_rOK) and (Art.C.Lieferantennr<>0) then
      $Lb.Lieferant->wpcaption # Adr.Stichwort
    else
      $Lb.Lieferant->wpcaption # '';

    vBuf401 # RekSave(401);
    if (Auf_Data:Read(Art.C.Auftragsnr, Art.C.Auftragspos,n)<400) then
      RecBufClear(401);
    $Lb.Kommission->wpcaption # Auf.P.KundenSW
    RekRestore(vBuf401);

    Erx # RecLink(856,252,9,_recFirst);   // Zustand holen
    if (Erx>_rLocked) or (Art.C.Zustand=0) then
      RecBufClear(856);

    $lb.Zustand->wpcaption # Art.Zst.Name;

    $Lb.HW1->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW2->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW3->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW4->wpCaption # "Set.Hauswährung.Kurz";

//    if (Art.C.ArtikelNr<>'') then
//      RecLink(250,252,1,0);

    $Lb.MEH1->wpcaption # Art.MEH;
    $Lb.MEH2->wpcaption # Art.MEH;
    $Lb.MEH3->wpcaption # Art.MEH;
    $Lb.MEH4->wpcaption # Art.MEH;
    $Lb.MEH5->wpcaption # Art.MEH;
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    gTmp # gMdi->winsearch(aName);
    if (gTmp<>0) then
     gTmp->winupdate(_WinUpdFld2Obj);
  end;

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
  Art.C.ArtikelNr     # Art.Nummer;
  Art.C.ArtStichwort  # Art.Stichwort;

  if (Mode=c_ModeEdit) then begin
    Lib_GuiCom:Disable($edArt.C.Charge);
    $edArt.C.Bezeichnung->WinFocusSet(true);
    end
  else begin
    $edArt.C.Charge->WinFocusSet(true);
  end;

  Lib_GuiCom:Disable($edArt.C.Verfgbar);

end;


//========================================================================
// ChargenSumme
//          Summiert Chargen in Nullcharge  [=> Auslagern in Lib?]
//          !!! Achtung: Aktueller Datensatz wird im Speicher überschrieben !!!
//========================================================================
sub ChargenSumme(
    aArtNr              : Alpha;
) : logic;
local begin
  Erx : int;
end;
begin
  Art.Nummer  # aArtNr;
  RecRead(250,1,0);                 // Artikel laden

  RecBufClear(252);
  Art.C.ArtikelNr   # Art.Nummer;
//  Art_Data:BuildChargenString();
//  Art_Data:FindeCharge();

  Erx # RecRead(252,1,_recTest);
  if (Erx <> _rOk) then begin
    if (Erx >= _rNoKey) then begin     // Keine Nullcharge vorhanden, neu anlegen
      RecBufClear(252);
      Art.C.ArtikelNr     # Art.Nummer;
      Art.C.ArtStichwort  # Art.Stichwort;
      Erx # Art_Data:WriteCharge(n);
      end
    else begin
//        Debug('Kann Nullcharge nicht eindeutig lesen');
      return(false);
    end;
  end
  else begin
    RecRead(252,1,_recLock);
    Art.C.ArtikelNr     # Art.Nummer;
    Art.C.ArtStichwort  # Art.Stichwort;
    Erx # Art_Data:WriteCharge(n);
  end;

  if (Erx <> _rOK) then  RETURN(false);

  RETURN(true);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx         : int;
  vArtNr      : alpha;
  vAdresse    : int;
  vAnschrift  : int;
  vCharge     : alpha;
end
begin

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
    Art.C.Eingangsdatum   # today;
    "Art.C.Anlage.Datum"  # today;
    "Art.C.Anlage.Zeit"   # now;
    "Art.C.Anlage.User"   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  /* Working here.... */
  vArtNr      # Art.C.ArtikelNr;
  vAdresse    # Art.C.Adressnr;
  vAnschrift  # Art.C.Anschriftnr ;
  vCharge     # Art.C.Charge.Intern;

  ChargenSumme(vArtNr);

  Art.C.ArtikelNr     # vArtNr;
  Art.C.Adressnr      # vAdresse;
  Art.C.Anschriftnr   # vAnschrift;
  Art.C.Charge.Intern # vCharge;

  RecRead(252,1,0);
  /* ---------------- */


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
  vArtNr : alpha;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    vArtnr # Art.C.ArtikelNr;
    RekDelete(gFile,0,'MAN');
    ChargenSumme(vArtNr);
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

  vHdl # gMenu->WinSearch('Mnu.Journal');
  if (vHDl <> 0) then
    vHdl->wpDisabled # Art.LagerjournalYN=n;
//      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Art_Journal]=false));

// Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true; //(vHdl->wpDisabled) or (Rechte[Rgt_Art_C_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true; //(vHdl->wpDisabled) or (Rechte[Rgt_Art_C_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true; //(vHdl->wpDisabled) or (Rechte[Rgt_Art_C_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true; //(vHdl->wpDisabled) or (Rechte[Rgt_Art_C_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true ;//(vHdl->wpDisabled) or (Rechte[Rgt_Art_C_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true; //(vHdl->wpDisabled) or (Rechte[Rgt_Art_C_Loeschen]=n);

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
  vHdl      : int;
  vFilter   : int;
  vFilter2  : int;
  vMenge    : float;
  vQ        : alpha(4000);
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Filter.Geloescht' : begin
      Filter_Art_C # !Filter_Art_C;
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_Art_C;

      Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', Art.Nummer);
      Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
      Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
      if (Filter_art_C) then begin
        Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
      end;

      Lib_Sel:QRecList( 0, vQ);
      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate( _winUpdOn, _winLstRecFromRecId | _winLstRecDoSelect );
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      App_Main:Refreshmode();
      RETURN true;
    end;


    'Mnu.Dispoliste' : begin
      RecRead(gFile,0,0,gZLList->wpdbrecid);
      Art_Disposition2:Show('Dispoliste','252_404_701',y,y);
    end;


    'Mnu.Reservierungen' : begin
//      RecRead(gFile,0,0,gZLList->wpdbrecid);
//      Art_Disposition:Show('Reservierungen','404_701',n,y);
      RecBufClear( 251 );
      gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Art.R.Verwaltung', '', y );
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      //vHdl # Winsearch(gMDI,'ZL.Art.Reservierungen');
      gZLLIst->wpdbkeyno  # 10;
      gZLLIst->wpdbfileno # 252;
//      vQ # '';
//      Lib_Sel:QAlpha(var vQ, 'Art.R.Artikelnr', '=', Art.C.Artikelnr);
//      Lib_Sel:QAlpha(var vQ, 'Art.R.Charge.Intern', '=', Art.C.Charge.Intern);
//      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Journal' : begin
      RecBufClear(253);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.J.Verwaltung','');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      $ZL.Art.Journal->wpdbfileno       # 252;
      $ZL.Art.Journal->wpdblinkfileno   # 253;
      $ZL.Art.Journal->wpdbkeyno        # 5;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      $ZL.Art.Journal->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
//      vQ # '';
//      Lib_Sel:QAlpha(var vQ, 'Art.J.Artikelnr', '=', Art.C.Artikelnr);
//      Lib_Sel:QAlpha(var vQ, 'Art.J.Charge','=', Art.C.Charge.Intern);
//      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Preisaenderung' : begin
      RecRead(gFile,0,0,gZLList->wpdbrecid);
      Art_Data:ChargenPreisaenderung();
      RefreshIfm('edArt.C.EKDurchschnitt');
      RefreshIfm('edArt.C.EKLetzter');
      RefreshIfm('edArt.C.VKDurchschnitt');
      RefreshIfm('edArt.C.VKLetzter');
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
  if (Art.C.Kommission<>'') or
    ("Art.C.Verfügbar"=0.0) or
    (Art.C.Ausgangsdatum<>0.0.0) then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
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
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================