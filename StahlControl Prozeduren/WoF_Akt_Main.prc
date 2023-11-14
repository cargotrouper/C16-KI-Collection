@A+
//==== Business-Control ==================================================
//
//  Prozedur    WoF_Akt_Main
//                          OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  07.06.2016  AH  Directory auf %temp%
//  04.04.2018  AH  "UND" Verknüpfung der Bedingungen
//  06.09.2019  ST  Typo in Dialogtitel
//  12.11.2021  AH  ERX
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
//    SUB AusUser1();
//    SUB AusUser2();
//    SUB AusUser3();
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Aktivität'
  cFile       :  941
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'WoF_Akt'
  cZList      : $ZL.WoF.Aktivitaeten
  cKey        : 1

  Trim(a)     : STRAdj(cnvai(a,_fmtNumnogroup),_STRbegin)
  TrimF(a,b)  : STRAdj(cnvaf(a,_Fmtnumnogroup,0,b),_STRbegin)
  WriteLn(a,b): BA1_Graph:Writeln(a,b)
end;

declare BuildGraphText(aFileName : alpha) : logic;
declare RefreshGraph();

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

// Auswahlfelder setzen...
  //SetStdAusFeld('', '');

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

  if (Mode=c_ModeNew) then begin
    WoF.Akt.Nummer    # WoF.Sch.Nummer;
    WoF.Akt.Kontext   # cnvia(gZLList->wpcustom);
  end;

  // Focus sezen auf Feld:
  $edWoF.Akt.Position->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vBuf941 : handle;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

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
  vBuf941 # reksave(941);
  $ZL.WoF.Aktivitaeten2->winUpdate(_WinUpdOn, _winLstFromFirst);
  RekRestore(vBuf941);
//  RefreshGraph();

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
    Erx # RecLink(942,941,1,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(942,0,'MAN');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN;
      end;
      Erx # RecLink(942,941,1,_recFirst);
    END;
    Erx # RecLink(942,941,2,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(942,0,'MAN');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN;
      end;
      Erx # RecLink(942,941,2,_recFirst);
    END;
    RekDelete(gFile,0,'MAN');

    TRANSOFF;

    $ZL.WoF.Aktivitaeten2->winUpdate(_WinUpdOn, _winLstFromFirst);

    RefreshGraph();
//    gMDI->winfocusset(true);
//    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
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
  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

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

  if (aEvt:obj->wpname='ZL.WoF.Aktivitaeten') then begin
    RefreshGraph();
  end;

  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

end;


//========================================================================
//  AusUser1
//
//========================================================================
sub AusUser1();
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    gSelected # 0;
    WoF.Akt.anUser1 # Usr.Username;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  Usr_data:RecReadThisUser();
  $edWoF.Akt.anUser1->Winfocusset(false);
//  RefreshIfm('edAdr.Sachbearbeiter');
end;


//========================================================================
//  AusUser2
//
//========================================================================
sub AusUser2();
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    gSelected # 0;
    WoF.Akt.anUser2 # Usr.Username;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  Usr_data:RecReadThisUser();
  $edWoF.Akt.anUser2->Winfocusset(false);
//  RefreshIfm('edAdr.Sachbearbeiter');
end;


//========================================================================
//  AusUser3
//
//========================================================================
sub AusUser3();
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    gSelected # 0;
    WoF.Akt.anUser3 # Usr.Username;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  Usr_data:RecReadThisUser();
  $edWoF.Akt.anUser3->Winfocusset(false);
//  RefreshIfm('edAdr.Sachbearbeiter');
end;


//========================================================================
//  AusGruppe1
//
//========================================================================
sub AusGruppe1();
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(801,0,_RecId,gSelected);
    gSelected # 0;
    WoF.Akt.anUser1 # Usr.Grp.Gruppenname;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  $edWoF.Akt.anUser1->Winfocusset(false);
end;


//========================================================================
//  AusGruppe2
//
//========================================================================
sub AusGruppe2();
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(801,0,_RecId,gSelected);
    gSelected # 0;
    WoF.Akt.anUser2 # Usr.Grp.Gruppenname;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  $edWoF.Akt.anUser2->Winfocusset(false);
end;


//========================================================================
//  AusGruppe3
//
//========================================================================
sub AusGruppe3();
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(801,0,_RecId,gSelected);
    gSelected # 0;
    WoF.Akt.anUser3 # Usr.Grp.Gruppenname;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  $edWoF.Akt.anUser3->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled);// or (Rechte[Rgt_xxx_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);// or (Rechte[Rgt_xxx_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);// or (Rechte[Rgt_xxx_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);// or (Rechte[Rgt_xxx_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);// or (Rechte[Rgt_xxx_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);// or (Rechte[Rgt_xxx_Loeschen]=n);

  $bt.Bedingung->wpdisabled # false;
  $bt.Bedingung.Del->wpdisabled # false;

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
      PtD_Main:View(gFile);//xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
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
  erx     : int;
  vBuf941 : handle;
  vBuf942 : handle;
end;
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of

    'bt.User1' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.Verwaltung',here+':AusUser1');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'bt.User2' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.Verwaltung',here+':AusUser2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'bt.User3' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.Verwaltung',here+':AusUser3');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'bt.Gruppe1' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.G.Verwaltung',here+':AusGruppe1');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'bt.Gruppe2' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.G.Verwaltung',here+':AusGruppe2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'bt.Gruppe3' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.G.Verwaltung',here+':AusGruppe3');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'bt.Bedingung.Del' : begin
      if (gZLList->wpDbRecId<>0) and ($ZL.WoF.Bedingungen->wpDbRecId<>0) then begin
        // Bedingung holen
        Erx # RecRead(942,0,_recId, $ZL.WoF.Bedingungen->wpDbRecId);
        if (Erx<=_rLocked) then begin
          RekDelete(942,0,'MAN');
          $ZL.WoF.Bedingungen->winUpdate(_WinUpdOn, _winLstFromFirst|_WinLstRecDoSelect);
          RefreshGraph();
        end;
      end;
    end;


    'bt.Bedingung' : begin
      if (gZLList->wpDbRecId<>0) and ($ZL.WoF.Aktivitaeten2->wpDbRecId<>0) then begin
        vBuf942 # RekSave(942);
        // Ziel-Aktivität holen...
        Erx # RecRead(941,0,_recId, gZLList->wpDbRecId);
        vBuf941 # RekSave(941);
        RecBufClear(942);
        WoF.Bed.Nummer      # WoF.Akt.Nummer;
        WoF.Bed.Kontext     # WoF.Akt.Kontext;
        WoF.Bed.Position    # WoF.Akt.Position;
        // Vorgänger-Aktivität holen...
        Erx # RecRead(941,0,_recId, $ZL.WoF.Aktivitaeten2->wpDbRecId);
        WoF.Bed.VonPosition # WoF.Akt.Position;
        WoF.Bed.VonStatus   # 'Y';
        // WoF.Bed.Operand     # '';
        WoF.Bed.lfdNr       # 1;
        REPEAT
          Erx # RekInsert(942,0,'AUTO');
          if (erx<>_rOK) then Inc(WoF.Bed.lfdNr);
        UNTIL (erx=_rOK);
        RekRestore(vBuf941);
        RekRestore(vBuf942);
        $ZL.WoF.Bedingungen->winUpdate(_WinUpdOn, _winLstFromFirst|_WinLstRecDoSelect);
        RefreshGraph();
      end;
    end;


    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
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
  Erx     : int;
  vBuf941 : handle;
end;
begin

  if (aEvt:Obj->wpname='ZL.WoF.Bedingungen') then begin
    GV.Alpha.01 # '';
    vBuf941 # RecBufCreate(941);
    vBuf941->WoF.Akt.Nummer   # WoF.Bed.Nummer;
    vBuf941->WoF.Akt.Kontext  # WoF.Bed.Kontext;
    vBuf941->WoF.Akt.Position # WoF.Bed.VonPosition;
    Erx # RecRead(vBuf941,1,0);
    GV.ALpha.01 # vBuf941->WoF.Akt.Name;
    RecBufDestroy(vBuf941);
    if (WoF.Bed.VonStatus='Y') then GV.Ints.01 # _WinImgOk;
    if (WoF.Bed.VonStatus='N') then GV.Ints.01 # _WinImgCancel;
    if (WoF.Bed.VonStatus='T') then GV.Ints.01 # _WinImgWarning;
  end;

end;


//========================================================================
//  EvtMouseItem
//        Mausklick auf Objekt
//========================================================================
sub EvtMouseItem(
  aEvt                 : event;    // Ereignis
  aButton              : int;      // Maustaste
  aHitTest             : int;      // Hittest-Code
  aItem                : int;      // Spalte oder Gantt-Intervall
  aID                  : int;      // RecID bei RecList / Zelle bei GanttGraph
) : logic;
begin
  if (aItem=0) then RETURN false;
  if (aItem->wpname='clmGV.Ints.01') and
    (aButton = _WinMouseLeft | _WinMouseDouble) and
    (aHitTest=_winhitlstview) then begin

    RecRead(942,0,_recId|_reClock,aID);
    if (WoF.Bed.VonStatus='Y') then WoF.Bed.VonStatus # 'N'
    else if (WoF.Bed.VonStatus='N') then WoF.Bed.VonStatus # 'T'
    else WoF.Bed.VonStatus # 'Y';
    RekReplace(942,_recunlock,'MAN');
    aEvT:Obj->WinUpdate(_winupdOn, _WinlstFromselected|_WinLstPosSelected |_WinLstRecDoSelect );
    RefreshGraph();
  end;

  RETURN(true);
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

  if (StrFind(WoF.Akt.Name,'[UND]',1) > 0) or (Wof.Akt.Bed.UND) then
    $lbBedingung->wpCaption # Translate('Bedingungen')+' ("'+translate('und')+'")';
  else
    $lbBedingung->wpCaption # Translate('Bedingungen')+' ("'+translate('oder')+'")';

  RecRead(gFile,0,_recid,aRecID);

  $ZL.WoF.Bedingungen->winUpdate(_WinUpdOn, _winLstFromFirst|_WinLstRecDoSelect);
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
// RefreshGraph
//
//========================================================================
sub RefreshGraph();
local begin
  vBildName : alpha;
  vTextName : alpha;
end;
begin

  FsiPathCreate(_Sys->spPathTemp+'StahlControl');
  FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
  vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
  vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';

  // Graphtext erzeugen
  BuildGraphText(vTextName);

  // Graph deaktivieren
  $pic.Graph->wpcaption # '';
  // Graph erstellen
  SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
    gMDI->winfocusset(true);
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  $pic.Graph->wpcaption # '*'+vBildName;
end;


//========================================================================
// BuildGraphText
//
//========================================================================
sub BuildGraphText(
  aFileName : alpha) : logic;
local begin
  Erx     : int;
  vS1,vS2 : int;
  vBuf941 : handle;
  vBuf942 : handle;
  vFile   : handle;
  vA,vC   : alpha;
  vTxt    : int;
  vI,vJ   : int;
end;
begin

  vFile # FSIOpen(aFilename,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTRuncate);
  if (vFile=0) then RETURN false;

  vBuf941 # RekSave(941);
  vBuf942 # RekSave(942);

//  vHdl # $lb.zuWorkflow;

  WriteLn(vFile, 'Digraph G {');
  WriteLn(vFile, 'label="Schema '+AInt(WoF.Sch.Nummer)+' '+$lb.zuWorkflow->wpcaption+'"')
  Writeln(vFile, 'fontsize=20');
  WriteLn(vFile, 'labelloc="t"');
  WriteLn(vFile, 'labeljust="l"');
  WriteLn(vFile, 'rankdir="LR"');
  WriteLn(vFile, 'rank="same"');

  // Aktivitäten loopen...
  WriteLn(vFile,'// KNOTEN ==============================');
  Erx # RecRead(941,1,_recFirst, gZLList->wpDbFilter);
  WHILE (Erx<=_rLocked) do begin
    WriteLn(vFile, 'p'+AInt(WoF.Akt.Position)+' [label="'+AInt(WoF.Akt.Position)+') '+WoF.Akt.Name+'", shape=box]');
    Erx # RecRead(941,1,_recNext, gZLList->wpDbFilter);
  END;

  // Bedingungen loopen...
  WriteLn(vFile,'// KANTEN ==============================');
  Erx # RecRead(941,1,_recFirst, gZLList->wpDbFilter);
  WHILE (Erx<=_rLocked) do begin

    Erx # RecLink(942,941,1,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      case WoF.Bed.VonStatus of
        'Y' : vA # 'green';
        'N' : vA # 'red';
        otherwise
              vA # 'yellow';
      end;
      WriteLn(vFile,'p'+AInt(WoF.Bed.VonPosition)+' -> p'+AInt(WoF.Akt.Position)+' [color='+vA+']');
      Erx # RecLink(942,941,1,_recNext);
    END;

    Erx # RecRead(941,1,_recNext, gZLList->wpDbFilter);
  END;


  WriteLn(vFile, '}');
  FSIClose(vFile);

  RekRestore(vBuf941);
  RekRestore(vBuf942);

  RETURN TRue;
end;



//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vHdl      : int;
  vRect     : rect;
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;


  if (aFlags & _WinPosSized != 0) then begin
    vHdl # Winsearch(gMDI,'pic.Graph');
    Lib_GUiCom:ObjSetPos(vHdl, 0, 0, aRect:right-aRect:left - 4, aRect:bottom-aRect:Top - 26);

    vHdl # Winsearch(gMDI,'ZL.WoF.Aktivitaeten2');
    Lib_GUiCom:ObjSetPos(vHdl, 0, 0, aRect:right-aRect:left - 4, 0);
  end;

	RETURN (true);
end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================