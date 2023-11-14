@A+
//==== Business-Control ==================================================
//
//  Prozedur    DiB_Main
//                    OHNE E_R_G
//  Info
//
//
//  04.06.2007  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
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
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtKeyItem(aEvt : event; aKey : int; aRecID : int) : logic
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
  cTitle      : 'Dispobestand'
  cFile       : 240
  cMenuName   : 'BA1.Out.Bearbeiten'
  cPrefix     : 'DiB'
  cZList      : $ZL.DiB
  cKey        : 2
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
  opt aChanged : logic;
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
  $...->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  RETURN false;
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

/*
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(gFile,0,'MAN');
  end;
*/
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
  end;

end;


//========================================================================
//  AusDetail
//
//========================================================================
sub AusDetail()
begin

  mode # c_ModeList;

  if (gSelected<>0) then begin
    gSelected # 0;
    if (cZList->wpDbSelection<>0) then begin
      SelRun(cZList->wpDbSelection,_SelDisplay| _SelServer | _SelServerAutoFld);
    end;
  end;

  // gesamtes Fenster aktivieren
//  Lib_GuiCom:SetWindowState(cDialog,true);
  // Focus setzen:
  cZList->Winfocusset(false);
  cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
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
    vHdl->wpDisabled # (y);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (y);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (y);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (y);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (y);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (y);

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
  vX    : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Kommission' : begin
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,BAG.IO.Anlage.Datum, BAG.IO.Anlage.Zeit, BAG.IO.Anlage.User);
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
//  EvtKeyItem
//            Keyboard in RecList/DataList
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aRecID                : int;          // RecID
) : logic
begin

  if (akey=_WinKeyInsert) and (Mode=c_ModeList) then begin
    RecRead(gFile,0,0,gZLList->wpdbrecid);
    Lib_Mark:MarkAdd(gFile);
  end;


  if (aKey=_WinKeyReturn) and (Mode=c_ModeList) then begin

    if (DiB.Datei=200) and (Rechte[Rgt_Material]) then begin
      Mat.Nummer # DiB.ID1;
      RecRead(200,1,0);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung','',y);
//      "GV.Fil.Mat.gelöscht" # y;
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_modeBald + c_modeView;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    if (DiB.Datei=701) and (Rechte[Rgt_BAG]) then begin
      BAG.Nummer # DiB.ID1;
      RecRead(700,1,0);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung','',y);
      Lib_guiCom:ObjSetPos(gMdi,10,0);
//      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      Mode # c_modeBald + c_modeView;
      Lib_GuiCom:RunChildWindow(gMDI,gFrmMain,_WinAddHidden);
      gMdi->WinUpdate(_WinUpdOn);
//      Lib_GuiCom:RunChildWindow(gMDI);

    end;

  end;


  RETURN true;
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
local begin
  Erx : int;
end;
begin

  if (DiB.Datei=200) then begin

    Erx # RecLink(200,240,1,_recFirst); // Material holen
    if (Erx>_rLocked) then RecBufClear(200);
    RecBufClear(701);

    BAG.IO.Dicke        # Mat.Dicke;
    BAG.IO.Breite       # Mat.Breite;
    "BAG.IO.Länge"      # "Mat.Länge";
    "BAG.IO.Güte"       # "Mat.Güte";
    BAG.IO.Plan.In.Stk  # "Mat.Verfügbar.Stk";
    BAG.IO.Plan.In.GewN # "Mat.Verfügbar.Gew";
    BAG.IO.Plan.In.GewB # "Mat.Verfügbar.Gew";

    BAG.F.Kommission    # Mat.Kommission;

    BAG.P.Plan.EndDat   # 0.0.0;


    Gv.Alpha.01 # 'MAT '+AInt(DiB.ID1);
    Gv.Alpha.02 # Mat.Werksnummer;
    end
  else begin


    Erx # RecLink(701,240,2,_recFirst); // BA-Input holen
    if (Erx>_rLocked) then RecBufClear(701);

    Gv.Alpha.01 # 'BA '+AInt(BAG.Io.VonBAG)+'/'+AInt(BAG.Io.VonPosition)+'/'+AInt(BAG.Io.VonFertigung)

    // ausFertigung holen
    Erx # RecLink(703,701,3,_recFirst);
    if (Erx>_rLocked) then RecBufClear(703);

    // ausPosition holen
    Erx # RecLink(702,701,2,_recFirst);
    if (Erx>_rLocked) then RecBufClear(702);

    Gv.Alpha.01 # Gv.Alpha.01 + ' '+BAG.P.Bezeichnung;
    Gv.Alpha.02 # '';//cnvai(Dib.id1)+'/'+cnvai(Dib.id2);

    if (BAG.F.Kommission<>'') or (BAG.IO.Ist.In.Stk<>0) or
      (BAG.IO.Ist.In.GewN<>0.0) or (BAG.IO.Ist.In.GewB<>0.0) or
      ("BAG.P.Löschmarker"<>'') then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Col.RList.Deletd);

  end;  // BA


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


//========================================================================
//========================================================================
//========================================================================
//========================================================================