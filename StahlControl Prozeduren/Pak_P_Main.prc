@A+
//==== Business-Control ==================================================
//
//  Prozedur    Pak_P_Main
//                      OHNE E_R_G
//  Info
//
//
//  15.11.2007  MS  Erstellung der Prozedur
//  15.02.2012  ST  Löschen von Paketzuordnung entfernt die Paketnummer am Material
//  16.03.2022  AH  ERX
//  27.04.2022  AH  Paketversand
//  26.07.2022  HA  Quick Jump
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
//    SUB AusLEER()
//    SUB AusMaterialNr()
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
  cTitle      : 'Paket - Positionen'
  cFile       :  281
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'Pak_P'
  cZList      : $ZL.Pak.P
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
  App_Main:EvtInit(aEvt);

Lib_Guicom2:Underline($edPak.P.MaterialNr);

  SetStdAusFeld('edPak.P.MaterialNr', 'MaterialNr');
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
  opt aChanged : logic;
)
local begin
  vTmp : int;
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
local begin
  Erx   : int;
  vPos  : int;
end;
begin

  // Neuanlage?
  if (Mode=c_ModeNew) then begin
   Erx # RecLink(281,280,1,_recLast); // letzte Position holen
   if (Erx>_rLocked) then vPos # 1    // keine gefunden, dann mit 1 starten
   else vPos # Pak.P.Position + 1;    // sonst um 1 erhöhen

   RecBufClear(281);
   Pak.P.Nummer        # Pak.Nummer;
   Pak.P.Position      # vPos;
  end;
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edPak.P.MaterialNr->WinFocusSet(true);
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
    /*
    "xxx.Änderung.Datum"  # Today;
    "xxx.Änderung.Zeit"   # Now;
    "xxx.Änderung.User"   # gUserName;
    */
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    /*
    Pak.P.Anlage.Datum  # Today;
    Pak.P.Anlage.Zeit   # Now;
    Pak.P.Anlage.User   # gUserName;
    */
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  // Material Updaten
  Erx # Pak_P_Data:UpdateMaterial(Pak.P.MaterialNr, Pak.P.Nummer);
  if (Erx <> _rOK) then begin
    Msg(280001,gTitle,0,0,0);
    RETURN False;
  end;

  // Kopfdaten neu gerechnen
  Pak_Data:Refresh();

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
    Pak_P_Data:Delete(0,'MAN');
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
    //'...' : begin
    //  RecBufClear(xxx);         // ZIELBUFFER LEEREN
    //  gMDI # Lib_GuiCom:AddChildWindow(gMDI, xxx.Verwaltung',here+':Aus...');
    //  ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    //  Lib_GuiCom:RunChildWindow(gMDI);
    //end;

    'MaterialNr' : begin
    RecBufClear(200);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterialNr');
    Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  Aus...
//
//========================================================================
/*
sub AusLEER()
begin
  if (gSelected<>0) then begin
    RecRead(xxx,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
  end;
  // Focus auf Editfeld setzen:
  $edxxx.xxxxx->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;
*/


//========================================================================
//  AusMaterialNr
//
//========================================================================
sub AusMaterialNr()
begin
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Pak.P.MaterialNr # Mat.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edPak.P.MaterialNr->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
  vVersand    : logic;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // 27.04.2022 AH: Versand??
  vVersand # VsP_Data:ExistsPaket(Pak.Nummer);
  
  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_P_Anlegen]=n) or (vVersand);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_P_Anlegen]=n) or (vVersand);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_P_Aendern]=n) or (vVersand);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_P_Aendern]=n) or (vVersand);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_P_Loeschen]=n) or (vVersand);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_P_Loeschen]=n) or (vVersand);

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
      PtD_Main:View( gFile );
      //PtD_Main:View(gFile,xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
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
    'bt.MaterialNr' :   Auswahl('MaterialNr');
    'bt.xxxxx'      :   Auswahl('...');
    'bt.xxxxx'      :   Auswahl('...');
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
  Refreshmode();

  Gv.Int.01 # 0;
  Gv.Num.02 # 0.0;
  Gv.Num.03 # 0.0;
  Gv.Num.04 # 0.0;
  Gv.Num.05 # 0.0;
  Gv.Alpha.01 # '';
  Gv.Alpha.02 # '';

  if (Pak.P.MaterialNr <> 0) then begin
    Mat_Data:Read(Pak.P.MaterialNr);
    Gv.Int.01 # "Mat.Bestand.Stk";
    Gv.Num.02 # "Mat.Bestand.Gew";
    Gv.Num.03 # "Mat.Dicke";
    Gv.Num.04 # "Mat.Breite";
    Gv.Num.05 # "Mat.Länge";
    Gv.Alpha.01 # "Mat.Güte";
    Gv.Alpha.02 # "Mat.Löschmarker";
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
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);

begin

  if ((aName =^ 'edPak.P.MaterialNr') AND (aBuf->Pak.P.MaterialNr<>0)) then begin
    Mat.Nummer # Pak.P.MaterialNr;
    RecRead(200,1,0);
    Lib_Guicom2:JumpToWindow('Mat.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================

