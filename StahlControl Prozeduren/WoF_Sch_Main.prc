@A+
//==== Business-Control ==================================================
//
//  Prozedur    WoF_Sch_Main
//                      OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  09.07.2013  AH  sonstiger WOF = 999
//  17.02.2014  ST  Erweiterung um Auslöser 700 - Betriebsauftrag
//  30.05.2018  AH  Fix für Dateityp als NUMMER nicht mehr Radiobutton
//  13.06.2018  AH  BugFIx
//  12.11.2021  AH  ERX
//
//  Subprozeduren
//    SUB Start(opt aRecId  : int; opt aView   : logic) : logic;
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
  cDialog       : 'WoF.Sch.Verwaltung'
  cRecht        : Rgt_Workflow_Schema
  cMDIVar       : gMDIPara
  cTitle        : 'Workflow-Schemata'
  cFile         :  940
  cMenuName     : 'Std.Bearbeiten'
  cPrefix       : 'WoF_Sch'
  cZList        : $ZL.WoF.Schema
  cKey          : 1
end;


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aView   : logic) : logic;
begin

  if (StrFind(Set.Module,'W',0)=0) then RETURN false;

  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView);
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
  //if (StrFind(Set.Module,'WOF')=0) then aEvt
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  // Auswahlfelder setzen...
//  SetStdAusFeld('', '');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//========================================================================
sub SetKontext(aDatei : int)
begin

  case aDatei of
    120 : //    'rb.Projekt' :
      begin
      WoF.Sch.Kontext1  # '';
      WoF.Sch.Kontext2  # '';
      WoF.Sch.Kontext3  # '';
      WoF.Sch.Kontext4  # '';
      WoF.Sch.Kontext5  # '';
    end;

// 401,501,561 ???
    200,
    400,
    401,
    440,
    500,
    501,
    540,
    560,
    700,702 :
      begin
      WoF.Sch.Kontext1  # _WOF_KTX_NEU;
      WoF.Sch.Kontext2  # _WOF_KTX_EDIT;
      WoF.Sch.Kontext3  # _WOF_KTX_DEL;
      WoF.Sch.Kontext4  # '';
      WoF.Sch.Kontext5  # '';
    end;
    
    203 : begin   // Mat-Reservierung
      WoF.Sch.Kontext1  # _WOF_KTX_NEU;
      WoF.Sch.Kontext2  # _WOF_KTX_EDIT;
      WoF.Sch.Kontext3  # _WOF_KTX_DEL;
      WoF.Sch.Kontext4  # _WOF_KTX_TIMO;
      WoF.Sch.Kontext5  # '';
    end;

    otherwise begin
      WoF.Sch.Kontext1  # '';
      WoF.Sch.Kontext2  # '';
      WoF.Sch.Kontext3  # '';
      WoF.Sch.Kontext4  # '';
      WoF.Sch.Kontext5  # '';
    end;
  end;
  
  $bt.Ktx1->wpcaption # WoF.Sch.Kontext1;
  $bt.Ktx2->wpcaption # WoF.Sch.Kontext2;
  $bt.Ktx3->wpcaption # WoF.Sch.Kontext3;
  $bt.Ktx4->wpcaption # WoF.Sch.Kontext4;
  $bt.Ktx5->wpcaption # WoF.Sch.Kontext5;
  $bt.Ktx6->wpcaption # Translate('manuell');

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
  vHdl  : handle;
  vTmp  : int;
end;
begin

  if (aName='') then begin

    $bt.Ktx1->wpcaption # WoF.Sch.Kontext1;
    $bt.Ktx2->wpcaption # WoF.Sch.Kontext2;
    $bt.Ktx3->wpcaption # WoF.Sch.Kontext3;
    $bt.Ktx4->wpcaption # WoF.Sch.Kontext4;
    $bt.Ktx5->wpcaption # WoF.Sch.Kontext5;

    $bt.Ktx1->wpdisabled # (Mode<>c_modeView) or (WoF.Sch.Kontext1='');
    $bt.Ktx2->wpdisabled # (Mode<>c_modeView) or (WoF.Sch.Kontext2='');
    $bt.Ktx3->wpdisabled # (Mode<>c_modeView) or (WoF.Sch.Kontext3='');
    $bt.Ktx4->wpdisabled # (Mode<>c_modeView) or (WoF.Sch.Kontext4='');
    $bt.Ktx5->wpdisabled # (Mode<>c_modeView) or (WoF.Sch.Kontext5='');
    $bt.Ktx6->wpdisabled # (Mode<>c_modeView);
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
  // Felder Disablen durch:
  if (Mode=c_ModeNew) then begin
    WoF.Sch.Datei # 0;
  end;

  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edWoF.Sch.Nummer->WinFocusSet(false);
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
  If (WoF.Sch.Nummer=0) then begin
    Msg(001200,Translate('Nummer'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edWoF.Sch.Nummer->WinFocusSet(true);
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
local begin
  Erx : int;
end;
begin

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    TRANSON;

    Erx # RecLink(941,940,1,_recFirst);   // Aktivitäten löschen
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(941,0,'MAN');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN;
      end;
      Erx # RecLink(941,940,1,_recFirst);
    END;

    Erx # RecLink(942,940,2,_recFirst);   // Bedingungen löschen
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(942,0,'MAN');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN;
      end;
      Erx # RecLink(942,940,2,_recFirst);
    END;

    Erx # RekDelete(gFile,0,'MAN');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;

    TRANSOFF;
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

  if (aEvt:Obj->wpName='edWoF.Sch.Datei') then begin
    SetKontext(aEvT:Obj->wpCaptionInt);
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
  end;  // ...case

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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_WoF_Sch_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_WoF_Sch_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_WoF_Sch_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_WoF_Sch_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_WoF_Sch_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_WoF_Sch_Loeschen]=n);

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
      PtD_Main:View(gFile);//,xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
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
  vFilter : int;
  vDatei  : int;
  vButton : int;
  vHdl    : handle;
  vTmp    : int;
end;
begin

  vDatei # WoF.Sch.Datei;
  case (aEvt:Obj->wpName) of

/**** ALTE RADIOBUTTONS
    'rb.Projekt' : begin
      WoF.Sch.Datei     # 120;
      WoF.Sch.Kontext1  # '';
      WoF.Sch.Kontext2  # '';
      WoF.Sch.Kontext3  # '';
      WoF.Sch.Kontext4  # '';
      WoF.Sch.Kontext5  # '';
    end;


    'rb.Mat' : begin
      WoF.Sch.Datei     # 200;
      WoF.Sch.Kontext1  # _WOF_KTX_NEU;
      WoF.Sch.Kontext2  # _WOF_KTX_EDIT;
      WoF.Sch.Kontext3  # _WOF_KTX_DEL;
      WoF.Sch.Kontext4  # _WOF_KTX_TIMO;
      WoF.Sch.Kontext5  # '';
    end;


    'rb.Mat.Rsv' : begin
      WoF.Sch.Datei     # 203;
      WoF.Sch.Kontext1  # _WOF_KTX_NEU;
      WoF.Sch.Kontext2  # _WOF_KTX_EDIT;
      WoF.Sch.Kontext3  # _WOF_KTX_DEL;
      WoF.Sch.Kontext4  # _WOF_KTX_TIMO;
      WoF.Sch.Kontext5  # '';
    end;


    'rb.Auf.Kopf' : begin
      WoF.Sch.Datei     # 400;
      WoF.Sch.Kontext1  # _WOF_KTX_NEU;
      WoF.Sch.Kontext2  # _WOF_KTX_EDIT;
      WoF.Sch.Kontext3  # _WOF_KTX_DEL;
      WoF.Sch.Kontext4  # '';//_WOF_KTX_TIMO;
      WoF.Sch.Kontext5  # '';
    end;


    'rb.Auf.Pos' : begin
      WoF.Sch.Datei     # 401;
      WoF.Sch.Kontext1  # _WOF_KTX_NEU;
      WoF.Sch.Kontext2  # _WOF_KTX_EDIT;
      WoF.Sch.Kontext3  # _WOF_KTX_DEL;
      WoF.Sch.Kontext4  # '';//_WOF_KTX_TIMO;
      WoF.Sch.Kontext5  # '';
    end;


    'rb.Lfs.Kopf' : begin
      WoF.Sch.Datei     # 440;
      WoF.Sch.Kontext1  # _WOF_KTX_NEU;
      WoF.Sch.Kontext2  # _WOF_KTX_EDIT;
      WoF.Sch.Kontext3  # _WOF_KTX_DEL;
      WoF.Sch.Kontext4  # '';//_WOF_KTX_TIMO;
      WoF.Sch.Kontext5  # '';
    end;


    'rb.EK.Kopf' : begin
      WoF.Sch.Datei     # 500;
      WoF.Sch.Kontext1  # _WOF_KTX_NEU;
      WoF.Sch.Kontext2  # _WOF_KTX_EDIT;
      WoF.Sch.Kontext3  # _WOF_KTX_DEL;
      WoF.Sch.Kontext4  # '';//_WOF_KTX_TIMO;
      WoF.Sch.Kontext5  # '';
    end;

    'rb.Bag.Kopf' : begin
      WoF.Sch.Datei     # 700;
      WoF.Sch.Kontext1  # _WOF_KTX_NEU;
      WoF.Sch.Kontext2  # _WOF_KTX_EDIT;
      WoF.Sch.Kontext3  # _WOF_KTX_DEL;
      WoF.Sch.Kontext4  # '';//_WOF_KTX_TIMO;
      WoF.Sch.Kontext5  # '';
    end;


    'rb.unknown' : begin
      WoF.Sch.Datei     # 999;
      WoF.Sch.Kontext1  # '';
      WoF.Sch.Kontext2  # '';
      WoF.Sch.Kontext3  # '';
      WoF.Sch.Kontext4  # '';
      WoF.Sch.Kontext5  # '';
    end;
***/

    'bt.Ktx1' : vButton # 1;
    'bt.Ktx2' : vButton # 2;
    'bt.Ktx3' : vButton # 3;
    'bt.Ktx4' : vButton # 4;
    'bt.Ktx5' : vButton # 5;
    'bt.Ktx6' : vButton # 6;
  end;  // ...case


  if (vDatei<>WoF.Sch.Datei) then begin
    $bt.Ktx1->wpcaption # WoF.Sch.Kontext1;
    $bt.Ktx2->wpcaption # WoF.Sch.Kontext2;
    $bt.Ktx3->wpcaption # WoF.Sch.Kontext3;
    $bt.Ktx4->wpcaption # WoF.Sch.Kontext4;
    $bt.Ktx5->wpcaption # WoF.Sch.Kontext5;
    $bt.Ktx6->wpcaption # Translate('manuell');
  end;

  if (vButton<>0) then begin
    RecBufClear(941);         // ZIELBUFFER LEEREN
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'WoF.Akt.Verwaltung','',y);
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vHdl # Winsearch(gMDI, 'lb.zuWorkflow');
    case vButton of
      1 : vHdl->wpcaption # WoF.Sch.Name+' : '+WoF.Sch.Kontext1;
      2 : vHdl->wpcaption # WoF.Sch.Name+' : '+WoF.Sch.Kontext2;
      3 : vHdl->wpcaption # WoF.Sch.Name+' : '+WoF.Sch.Kontext3;
      4 : vHdl->wpcaption # WoF.Sch.Name+' : '+WoF.Sch.Kontext4;
      5 : vHdl->wpcaption # WoF.Sch.Name+' : '+WoF.Sch.Kontext5;
      6 : vHdl->wpcaption # WoF.Sch.Name+' : '+translate('manuell');
    end;
    vFilter # RecFilterCreate(941,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, WoF.Sch.Nummer);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, vButton);
    gZLList->wpDbFilter # vFilter;
    gZLList->wpcustom # Aint(vButton);
    vTMP # Winsearch(gMDI,'ZL.WoF.Aktivitaeten2');
    if (vTMP<>0) then vTMP->wpDbFilter # vFilter;
    Lib_GuiCom:RunChildWindow(gMDI);
  end;

  if (Mode=c_ModeView) then RETURN true;

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