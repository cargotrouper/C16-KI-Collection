@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Rsv_Main
//                  OHNE E_R_G
//  Info
//
//
//  11.02.2015  AH  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    SUB Start(opt aRecId  : int; opt aView   : logic) : logic;
//    SUB EvtInit(
//    SUB Pflichtfelder();
//    SUB RefreshIfm(opt aName : alpha; opt aChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(
//    SUB EvtFocusTerm(
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLEER()
//    SUB RefreshMode(opt aNoRefresh : logic);
//    SUB EvtMenuCommand(
//    SUB EvtClicked(
//    SUB EvtPageSelect(
//    SUB EvtLstDataInit(
//    SUB EvtLstSelect(
//    SUB EvtClose(
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Ressourcen-Reservierungen'
  cFile       :  170
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'Rso_Rsv'
  cZList      : $ZL.Rso.Reservierungen
  cKey        : 1
  cListen     : 'Rso_Reservierungen'
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
  winsearchpath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen  # cListen;

//  Rso_Rsv_data:Graph($Picture1);
  $Lb.Ressource->wpCaption # Rso.Stichwort;

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
end;



//========================================================================
//
//========================================================================
sub _TraegerString() : alpha;
local begin
  vA  : alpha(100);
end;
begin
  vA # "Rso.R.Trägertyp"+' '+aint("Rso.R.Trägernummer1");
  if ("Rso.R.Trägernummer2"<>0) then vA # vA + '/' + aint("Rso.R.Trägernummer2");
  if ("Rso.R.Trägernummer3"<>0) then vA # vA + '/' + aint("Rso.R.Trägernummer3");
  RETURN vA;
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
  vHdl  : int;
end;
begin

  $lb.Traeger->wpcaption # _TraegerString();

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
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
  $edRso.R.Dauer->winFocusset();
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
    Erx # Rso_Rsv_Data:Replace(_recUnlock,'MAN','FIX');
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

//  Rso_Rsv_data:Graph($Picture1);

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
    if (RekDelete(gFile,0,'MAN')=_rOK) then begin
      if (gZLList->wpDbSelection<>0) then begin
        SelRecDelete(gZLList->wpDbSelection,gFile);
        RecRead(gFile, gZLList->wpDbSelection, 0);
      end;
    end;
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
sub Auswahl(aBereich : alpha)
begin
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl    : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

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
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
    end;

  end; // ...case


end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vMdi  : int;
  vHdl  : int;
end;
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'myGraph' : begin
//debugx('addbyname...');
      vMdi # Lib_GuiCom2:OpenMultiMDI(gFrmMain, 'Mdi.Rso.Rsv.Graph', _WinAddHidden);
//vMdi # WinAddByName(gFrmMain, 'Mdi.Rso.Rsv.Graph', _winAddHidden);
//debugx('...added');
      vHdl # vMdi->Winsearch('edDatum');
      vHdl->wpCaptionDate   # today;
      Rso_Rsv_Graph:RefreshGraph(vMDI);
//debugx('show...');
      vMdi->winupdate(_WinUpdOn);
//debugx('...shown');
    end;
  end;  // ...case

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
  vDat      : date;
  vTim      : time;
  vI        : int;
  vS1, vS2  : int;
  vErr      : alpha(1000);
  vErrObj   : int;
end;
begin

  // Jumplogic:
  Lib_GuiCom:ZLQuickJumpInfo($clmGV.Alpha.10);


  GV.Alpha.01 # '';
  GV.Alpha.02 # '';
  GV.Alpha.10 # _TraegerString();
  GV.Alpha.11 # '';

  if (Rso.R.MinDat.Start<>0.0.0) then
    GV.Alpha.01 # Cnvad(Rso.R.MinDat.Start)+' '+cnvat(Rso.R.MinZeit.Start);
  if (Rso.R.MaxDat.Ende<>0.0.0) then
    GV.Alpha.02 # Cnvad(Rso.R.MaxDat.Ende)+' '+cnvat(Rso.R.MaxZeit.Ende);


  // liegt Startzeit in den Fenstern?
  if (Rso.R.Plan.StartDat<>0.0.0) then begin
    vDat # Rso.R.Plan.StartDat;
    vTim # Rso.R.Plan.StartZeit;
    vI # Rso_Rsv_Data:GetTS(vDat, vTim);
    if (Rso.R.MinDat.Start<>0.0.0) then begin
      if (vI<Rso_Rsv_Data:GetTS(Rso.R.MinDat.Start, Rso.R.MinZeit.Start)) then begin
        $clmRso.R.Plan.StartDat->wpClmColBkg # _WincolLightRed;
        vErr # 'Start zu früh für Vorgänger';
      end;
    end;
    if (Rso.R.MaxDat.Ende<>0.0.0) then begin
      if (vI>Rso_Rsv_Data:GetTS(Rso.R.MaxDat.Ende, Rso.R.MaxZeit.Ende)) then begin
        $clmRso.R.Plan.StartDat->wpClmColBkg # _WincolLightRed;
        vErr # 'Start zu spät für Nachfolger';
      end;
    end;
  end;

  // Fenster "falsch" herum?
  if (Rso.R.MaxDat.Start<>0.0.0) and (Rso.R.MinDat.Start<>0.0.0) then begin
    vS1 # Rso_Rsv_Data:GetTS(Rso.R.MaxDat.Start, Rso.R.MaxZeit.Start);
    vS2 # Rso_Rsv_Data:GetTS(Rso.R.MinDat.Start, Rso.R.MinZeit.Start);
    if (vS2>vS1) then begin
      $clmGV.Alpha.01->wpClmColBkg # _WincolLightRed;
      $clmGV.Alpha.02->wpClmColBkg # _WincolLightRed;
      vErr # 'Zeitfenster unvereinbar';
    end;
  end;


  if (vErr<>'') then begin
    GV.Alpha.11 # vErr;
    $clmGV.Alpha.11->wpClmColBkg # _WincolLightRed;
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
  $lb.Traeger->wpcaption # _TraegerString();
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
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect     : rect;
  vHdl      : int;
  vPicH     : int;
  vSize     : int;
end
begin

  vPicH # 60;
  vSize # vRect:Bottom - vRect:Top + 3;

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  //Quickbar
  vHdl # Winsearch(gMDI,'gs.Main');
  if (vHdl<>0) then begin
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left+2;
    vRect:bottom    # aRect:bottom-aRect:Top+5;
    vHdl->wparea    # vRect;
  end;

  if (aFlags & _WinPosSized != 0) then begin
    if (gZLList<>0) then vHdl # gZLList;
    else if (gDataList<>0) then vHdl # gDataList
    else RETURN true;

    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28 - w_QBHeight - vPicH;
    vHdl->wparea # vRect;

    Lib_GUiCom:ObjSetPos($myGraph, 0, aRect:bottom-aRect:Top-28-w_QBHeight - (vSize * 2)-35);
  end;

	RETURN (true);
end;


//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  Erx : int;
end;
begin

  if (aName = StrCnv('clmGV.Alpha.10',_StrUpper)) then begin

    if (aBuf->"Rso.R.Trägertyp"='BAG') then begin
      BAG.Nummer # aBuf->"Rso.R.TrägerNummer1";
      Erx # RecRead(700,1,0);
      if (Erx>_rMultikey) then RETURN;
//        Adr_Main:Start(0, Adr.Nummer,y);
      RecBufClear(702);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;  // BAG

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================