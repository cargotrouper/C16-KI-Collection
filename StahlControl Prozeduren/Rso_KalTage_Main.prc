@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_KalTage_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  04.02.2022  AH  ERX
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
  cTitle :    'Kalendertage'
  cFile :     164
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Rso_KalTage'
  cListen   : 'KALTAGE'
  cZList :    $ZL.RsoKalenderTage
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
  w_Listen  # cListen
  gZLList   # cZList;
  gKey      # cKey;

  // Auswahlfelder setzen...
  //SetStdAusFeld('edXXXXXXX'       ,'');

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

//  if (Mode=c_ModeView) then begin
//    StrCheck();
//  end;

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

//  StrCheck();
  if (mode=c_Modenew) then begin
    Rso.Kal.Tag.Von1Zeit  # 24:00;
    Rso.Kal.Tag.Von2Zeit  # 24:00;
    Rso.Kal.Tag.Von3Zeit  # 24:00;
    Rso.Kal.Tag.Von4Zeit  # 24:00;
    Rso.Kal.Tag.Von5Zeit  # 24:00;
    Rso.Kal.Tag.Von6Zeit  # 24:00;
    Rso.Kal.Tag.Von7Zeit  # 24:00;
    Rso.Kal.Tag.Von8Zeit  # 24:00;
    Rso.Kal.Tag.Von9Zeit  # 24:00;

    Rso.Kal.Tag.Bis1Zeit  # 24:00;
    Rso.Kal.Tag.Bis2Zeit  # 24:00;
    Rso.Kal.Tag.Bis3Zeit  # 24:00;
    Rso.Kal.Tag.Bis4Zeit  # 24:00;
    Rso.Kal.Tag.Bis5Zeit  # 24:00;
    Rso.Kal.Tag.Bis6Zeit  # 24:00;
    Rso.Kal.Tag.Bis7Zeit  # 24:00;
    Rso.Kal.Tag.Bis8Zeit  # 24:00;
    Rso.Kal.Tag.Bis9Zeit  # 24:00;
  end;

  // Focus setzen auf Feld:
  $edRso.Kal.Tag.Typ->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vI    : int;
  vHdl  : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
//  CheckStr();
  FOR vI # 0 loop inc(vI) while (vI<=8) do begin
    if (FldTime(164,1,4+(vI * 2))<>24:00) and (FldTime(164,1,5+ (vI * 2))=24:00) then begin
      Msg(001200,Translate('Zeit'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      vHdl # Winsearch(gMDI, 'edRso.Kal.Tag.Bis'+aint(vI+1)+'Zeit');
      if (vHdl<>0) then vHdl->WinFocusSet(true);
      RETURN false;
    end;
    if (FldTime(164,1,4+(vI * 2))=24:00) and (FldTime(164,1,5+ (vI * 2))<>24:00) then begin
      Msg(001200,Translate('Zeit'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      vHdl # Winsearch(gMDI, 'edRso.Kal.Tag.Von'+aint(vI+1)+'Zeit');
      if (vHdl<>0) then vHdl->WinFocusSet(true);
      RETURN false;
    end;
    if (FldTime(164,1,4+(vI * 2))) > (FldTime(164,1,5+ (vI * 2))) and (FldTime(164,1,5+ (vI * 2))<>0:0)  then begin
      Msg(001200,Translate('Zeit'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      vHdl # Winsearch(gMDI, 'edRso.Kal.Tag.Von'+aint(vI+1)+'Zeit');
      if (vHdl<>0) then vHdl->WinFocusSet(true);
      RETURN false;
    end;
  END;

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
local begin
  vTim  : time;
  vI,vJ : int;
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  if (StrFind(aEvt:Obj->wpname,'edRso.Kal.Tag.Bis',1)>0) then begin
    vTim # aEvt:Obj->wpcaptiontime;
    if (vTim=24:00) then RETURN true;
  end;

  if (StrFind(aEvt:Obj->wpname,'edRso.Kal.Tag.Von',1)>0) or
    (StrFind(aEvt:Obj->wpname,'edRso.Kal.Tag.Bis',1)>0) then begin
    vTim # aEvt:Obj->wpcaptiontime;
    vI # cnvit(vTim) / 60000;   // volle Minuten
    vJ # vI div 15;
    if (vI % 15>0) then vJ # vJ + 1;
    vJ # vJ * 15;
    vJ # vJ * 60000;
    vTim # cnvti(vJ);
    aEvt:Obj->wpcaptiontime # vTim;
    aEvt:obj->winupdate(_WinUpdObj2Fld);
  end;

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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_KalTag_Loeschen]=n);

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
      PtD_Main:View(gFile);//,xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
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
