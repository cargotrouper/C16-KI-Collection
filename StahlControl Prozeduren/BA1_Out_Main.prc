@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Out_Main
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
  cTitle      : 'Ausbringungen'
  cFile       : 701
  cMenuName   : 'BA1.Out.Bearbeiten'
  cPrefix     : 'BA1_Out'
  cZList      : $ZL.BA1.Output
  cKey        : 8
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub XEvtInit(
  aEvt  : event;        // Ereignis
): logic
begin

todo('XXXXXXXXXXXXXX');
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  App_Main:EvtInit(aEvt);

  Lib_Misc:SelRecList(0,'LETZTE_KANTEN');         //!QRecList
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub XPflichtfelder();
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
sub XRefreshIfm(
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
    XPflichtfelder();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub XRecInit()
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
sub XRecSave() : logic;
local begin
  Erx : int;
end;
begin
  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    ERx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    BAG.IO.Anlage.Datum  # Today;
    BAG.IO.Anlage.Zeit   # Now;
    BAG.IO.Anlage.User   # gUserName;
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
sub XRecCleanup() : logic
begin
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub XRecDel()
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
sub XEvtFocusInit (
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
sub XEvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // neu zu fokusierendes Objekt
) : logic
begin

  // logische Prüfung von Verknüpfungen
  XRefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub XAuswahl(
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
sub XAusDetail()
begin

  mode # c_ModeList;

  if (gSelected<>0) then begin
    gSelected # 0;
    if (cZList->wpDbSelection<>0) then begin
      SelRun(cZList->wpDbSelection,_SelDisplay | _SelServer | _SelServerAutoFld);
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
sub XRefreshMode(opt aNoRefresh : logic);
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

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then XRefreshIfm();

end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub XEvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  Erx   : int;
  vHdl  : int;
  vX    : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Kommission' : begin
      // BA-Kopf holen
      Erx # RecLink(700,701,1,_recFirst);
      if (Erx>_rLocked) then RETURN false;

      // Abstammungs Fertigung holen
      Erx # RecLink(703,701,3,_recFirst);
      if (Erx>_rLocked) then RETURN false;

      // Abstammungs Position holen
      Erx # RecLink(702,701,2,_recFirst);
      if (Erx>_rLocked) then RETURN false;

      // Dialog starten
//      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.F.Split.Maske','BA1_F_Split:AusSplit',y);
//      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.F.Split.Maske','',y);
//      Lib_GuiCom:RunChildWindow(gMDI);

      Mode # c_Modeother;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.F.Spalt.Maske', here+':AusDetail',y,y);
      Lib_guiCom:ObjSetPos(gMdi,10,0);
      vX # gZLList;
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_modeBald + c_modeNew;
      w_Appendnr # cZList->wpdbRecId; // Satz-ID merken für allgemeine Fertigung (999)

      vHDL # Winsearch(gMDI,'lb.GegenID');
      vHDl->wpcustom # cnvai(RecInfo(703,_recid));

      gZLList # vX;
      Lib_GuiCom:RunChildWindow(gMDI);

    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,BAG.IO.Anlage.Datum, BAG.IO.Anlage.Zeit, BAG.IO.Anlage.User);
    end;


    'Mnu.Auswahl' : begin
      vHdl # WinFocusGet();
      if (vHdl<>0) then begin
        case (vHdl->wpname) of
           'edxxx.xxxxxx' :   XAuswahl('...');
        end;
      end;
    end;

  end; // case


end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub XEvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.xxxxx' :   XAuswahl('...');
  end;

end;


//========================================================================
//  EvtKeyItem
//            Keyboard in RecList/DataList
//========================================================================
sub XEvtKeyItem(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aRecID                : int;          // RecID
) : logic
begin
  if (akey=_WinKeyInsert) and (Mode=c_ModeList) then begin
    RecRead(gFile,0,0,gZLList->wpdbrecid);
    Lib_Mark:MarkAdd(gFile);
  end;
  RETURN true;
end;


//========================================================================
//  EvtPageSelect
//                Seitenauswahl von Notebooks
//========================================================================
sub XEvtPageSelect(
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
sub XEvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
local begin
  Erx : int;
end;
begin
  Gv.Alpha.01 # AInt(BAG.Io.VonBAG)+'/'+AInt(BAG.Io.VonPosition)+'/'+AInt(BAG.Io.VonFertigung);
  // ausFertigung holen
  Erx # RecLink(703,701,3,_recFirst);
  if (Erx>_rLocked) then RecBufClear(703);

  // ausPosition holen
  Erx # RecLink(702,701,2,_recFirst);
  if (Erx>_rLocked) then RecBufClear(702);

  Gv.Alpha.01 # Gv.Alpha.01 + ' '+BAG.P.Bezeichnung;

  if (BAG.F.Kommission<>'') or (BAG.IO.Ist.In.Stk<>0) or
    (BAG.IO.Ist.In.GewN<>0.0) or (BAG.IO.Ist.In.GewB<>0.0) or
    ("BAG.P.Löschmarker"<>'') then
    Lib_GuiCom:ZLColorLine(gZLList, Set.Col.RList.Deletd);

//  Refreshmode();
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub XEvtLstSelect(
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
sub XEvtClose
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
