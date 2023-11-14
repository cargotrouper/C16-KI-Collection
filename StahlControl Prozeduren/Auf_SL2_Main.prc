@A+
//==== Business-Control ==================================================
//
//  Prozedur    Auf_SL2_Main
//                        OHNE E_R_G
//  Info
//
//
//  31.03.2022  AH  Erstellung der Prozedur
//  15.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB ZieheArtikel()
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusArtikelnummer()
//    SUB RefreshMode(opt aNoRefresh : logic; opt aChanged : logic,);
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
@I:Def_aktionen
@I:Def_BAG

define begin
  cTitle :    'Feinterminierung'
  cFile :     409
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Auf_SL2'
  cZList :    'ZL.Auf.Stueckliste'
  cKey :      1
end;

declare BerechneAus(aTyp : alpha);
declare RefreshIfm(opt aName : alpha; opt aChanged : logic)

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
  gZLList   # winsearch(aEvt:Obj,cZList);
  gKey      # cKey;

  if (Auf.P.Artikelnr<>'') then begin
    RekLink(250,401,2,_recfirst);   // Pos-Artikel holen
    $edAuf.SL.Artikelnummer->wpcustom # '_N';
    $bt.Artikel->wpcustom             # '_N';
  end;

  Lib_Guicom2:Underline($edAuf.SL.Artikelnummer);

  SetStdAusFeld('edAuf.SL.Artikelnummer' ,'Artikel');

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
// BerechneAus
//
//========================================================================
sub BerechneAus(aTyp : alpha);
local begin
  Erx : int;
end;
begin
//  Erx # RekLink(250,409,3,_recFirst);   // Artikel holen
//  if (Erx>_rLocked) then
//    RekLink(250,401,2,_recfirst);   // Pos-Artikel holen

  if (aTyp='GEW') then begin
    if ("Auf.SL.Stückzahl"=0) then begin
      "Auf.SL.Stückzahl"  # cnvif(Lib_Einheiten:WandleMEH(409, 0, Auf.SL.Gewicht, 0.0, '', 'Stk'));
    end;
    if (Auf.SL.MEH='Stk') or (Auf.SL.MEH='t') or (Auf.SL.MEH='kg') then
      Auf.SL.Menge        # Lib_Einheiten:WandleMEH(409, 0, Auf.SL.Gewicht, 0.0, '', Auf.SL.MEH);
  end;

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
  vTmp  : int;
  Erx   : int;
end;
begin

  if (WGr.Nummer<>Auf.P.Warengruppe) then RekLink(819,401,1,_recfirst);   // Warengruppe holen
 
  if (aName='') or
    ((aName='edAuf.SL.Artikelnummer') and ($edAuf.SL.Artikelnummer->wpchanged)) then begin
    Erx # _rnorec;
    if (Auf.Sl.Artikelnr<>'') then
      Erx # RekLink(250,409,3,_recFirst);   // Artikel holen
    if (erx>_rLocked) then Recbufclear(250);
    $lb.ArtikelSW->wpcaption # Art.Stichwort;
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
local begin
  Erx : int;
end;
begin
  if (Mode=c_ModeNew) then begin
    Auf.SL.Nummer         # Auf.P.Nummer;
    Auf.SL.Position       # Auf.P.Position;
    Auf.SL.lfdNr          # 1;
    Auf.SL.ArtikelNr      # Auf.P.Artikelnr;
    Auf.SL.MEH            # Auf.P.MEH.Einsatz;
  end;

  // Focus setzen auf Feld:
  $edAuf.SL.Termin->WinFocusSet(true)
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vMenge  : float;
  vTmp    : int;
  Erx     : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if (Auf.SL.Gewicht<=0.0) then begin
    Msg(001200,Translate('Gewicht'),0,0,0);
    vTmp # gMdi->Winsearch('NB.Main');
    vTmp->wpcurrent # 'NB.Kopf';
    $edAuf.SL.Gewicht->WinFocusSet(true);
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
    Auf.SL.lfdNr # 1;
    WHILE (RecRead(409,1,_RecTest)<=_rLocked) do
      Auf.SL.lfdNr # Auf.SL.lfdNR + 1;

    Auf.SL.Anlage.Datum  # Today;
    Auf.Sl.Anlage.Zeit   # Now;
    Auf.SL.Anlage.User   # gUserName;

    erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (Auf.P.Nummer<1000000000) then begin
      Auf_SL_Data:Reservieren(n);
    end;
  end;
  if (Auf.P.Nummer<1000000000) then begin
    Auf_data:VerteileAbrufeInSL(RecBufDefault(401));
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

    if (Auf.P.Nummer<1000000000) then begin
      Auf_SL_Data:Reservieren(y);
    end;
    
    RekDelete(gFile,0,'MAN');
 
    if (Auf.P.Nummer<1000000000) then begin
      Auf_data:VerteileAbrufeInSL(RecBufDefault(401));
    end;

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

  if (aEvt:Obj->wpname='edAuf.SL.Gewicht') and ($edAuf.SL.Gewicht->wpchanged) then begin
    BerechneAus('GEW');
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
  vHdl  : int;
  vQ    : alpha(4000);
end;

begin

  case aBereich of
    'Artikel' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikelnummer');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusArtikelnummer
//
//========================================================================
sub AusArtikelnummer()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feld∑bernahme
    Auf.SL.Artikelnr      # Art.Nummer;
    Auf.SL.Menge          # 0.0;
    "Auf.SL.Stückzahl"    # 0;
    Auf.SL.Gewicht        # 0.0;
    $lb.ArtikelSW->wpcaption # Art.Stichwort;
  end;
  // Focus auf Editfeld setzen:
  $edAuf.SL.Artikelnummer->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
  vTmp        : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_SL_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_SL_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Auf_SL_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Auf_SL_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_SL_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_SL_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Matz');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Auf_MATZ]=n) or
                    (Auf.Vorgangstyp<>c_AUF) or
                    (Auf.LiefervertragYN = true) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList) and (Mode<>c_ModeNew2));

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Auf_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Auf_Excel_Import]=false;

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
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
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
    'bt.Artikel' :    Auswahl('Artikel');
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

  if ((aName =^ 'edAuf.SL.Artikelnummer') AND (aBuf->Auf.SL.ArtikelNr<>'')) then begin
    RekLink(250,409,3,0);   // Artikelnummer holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================