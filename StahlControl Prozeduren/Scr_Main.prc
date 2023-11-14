@A+
//==== Business-Control ==================================================
//
//  Prozedur    Scr_Main
//                    OHNE E_R_G
//  Info
//
//
//  18.07.2007  AI  Erstellung der Prozedur
//  07.01.2010  MS  CopyScript hinzugefuegt
//  04.02.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB CopyScript() : logic;
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusFormular()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB Auswahlliste(aBereiche : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Scripte'
  cFile       : 920
  cMenuName   : 'Scr.Bearbeiten'
  cPrefix     : 'Scr'
  cZList      : $ZL.Scripte
  cKey        : 1
  cListen     : ''
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
  w_Listen  # cListen;

Lib_Guicom2:Underline($edScr.Name);
Lib_Guicom2:Underline($edScr.Prozedurname);

  SetStdAusFeld('edScr.Name'          ,'Formular');
  SetStdAusFeld('edScr.Prozedurname'  ,'Prozedur');


  App_Main:EvtInit(aEvt);
end;

//========================================================================
// CopyScript 07.01.2010 MS
//            Kopiert ein Script incl. Positionen
//========================================================================
sub CopyScript() : logic;
local begin
  Erx         : int;
  vBuf920     : int;
  vBuf921     : int;
end;
begin

  if(Frm.Bereich = 0) then begin // bereits ein neues Formular ausgewaehlt?
    Erx # RecRead(920,0,_recID,gZLList->wpDbRecId); // fokusiertes Script lesen
    if(Erx > _rLocked) then
      RETURN false;

    WHILE(GV.Int.01 = 0) DO BEGIN
      Dlg_Standard:Anzahl('Nummer:', var GV.Int.01, 0); // neue Nummer
    END;

    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Frm.Verwaltung',here + ':CopyScript'); // Formulare oeffnen
    Lib_GuiCom:RunChildWindow(gMDI);
  end
  else begin

    if (gSelected <> 0) then begin
      RecRead(912,0,_RecId,gSelected); // ausgewaehltes Formular lesen
      gSelected # 0;
    end;

    vBuf920 # RekSave(920);

    TRANSON;
    Scr.Nummer        # GV.Int.01
    Scr.Name          # AInt(Frm.Bereich) + '/' + Frm.Name;
    Scr.Beschreibung  # Frm.Name;
    Scr.Bereich       # '';
    Scr.Prozedurname  # '';
    Erx # RekInsert(920, 0, 'AUTO');
    if(Erx <> _rOK) then begin
      TRANSBRK;
      RETURN false;
    end;

    Erx # RecLink(921, vBuf920, 1, _recFirst);
    vBuf921 # RekSave(921);
    WHILE(Erx <= _rLocked) DO BEGIN
      Scr.B.Nummer            # GV.Int.01;
      Scr.B.lfdNr             # vBuf921 -> Scr.B.lfdNr;
      Scr.B.Befehl            # vBuf921 -> Scr.B.Befehl;
      Scr.B.2.Bereich         # Frm.Bereich;
      Scr.B.2.FormName        # Frm.Name;
      Scr.B.2.Kopien          # vBuf921 -> Scr.B.2.Kopien;
      Scr.B.2.Drucker         # vBuf921 -> Scr.B.2.Drucker;
      Scr.B.2.Schacht         # vBuf921 -> Scr.B.2.Schacht;
      Scr.B.2.Ausgabeart      # vBuf921 -> Scr.B.2.Ausgabeart;
      Scr.B.2.Markierung      # vBuf921 -> Scr.B.2.Markierung;
      Scr.B.2.anKuLfYN        # false;
      Scr.B.2.anPartnerYN     # false;
      Scr.B.2.anLiefAdrYN     # false;
      Scr.B.2.anLiefAnsYN     # false;
      Scr.B.2.anVerbrauYN     # false;
      Scr.B.2.anReEmpfYN      # false;
      Scr.B.2.anVertretYN     # false;
      Scr.B.2.anVerbandYN     # false;
      Scr.B.2.anLagerortYN    # false;
      Scr.B.2.FixID1          # 0;
      Scr.B.2.FixID2          # 0;
      Scr.B.2.DirektdrckYN    # vBuf921 -> Scr.B.2.DirektdrckYN;
      Scr.B.2.VorschauYN      # vBuf921 -> Scr.B.2.VorschauYN;
      Scr.B.2.SpeichernYN     # vBuf921 -> Scr.B.2.SpeichernYN;
      Scr.B.Prozedurname      # '';

      Erx # RekInsert(921, 0, 'AUTO');
      if(Erx <> _rOK) then begin
        TRANSBRK;
        RETURN false;
      end;

      Erx # RecLink(vBuf921, vBuf920, 1, _recNext);
    END;

    TRANSOFF;
    RecBufDestroy(vBuf920);
    RecBufDestroy(vBuf921);

    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  end;

  RETURN true;
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
/*
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();
    */

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
  if (mode=c_ModeNew) then
    $edScr.Nummer->WinFocusSet(true)
  else
    $edScr.Beschreibung->WinFocusSet(true);
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
  // NummernvErxabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
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

    Erx # RecLink(921,920,1,_recfirst); // Befehle loopen
    WHILE (Erx<=_rOK) do begin
      Erx # RekDelete(921,0,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RETURN;
      end;
      Erx # RecLink(921,920,1,_recfirst);
    END;
    RekDelete(gFile,0,'MAN');
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
  //RefreshIfm(aEvt:Obj->wpName);

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

    'Prozedur' : begin
      vA # Prg_Para_Main:ParaAuswahl('Prozeduren','SFX_','SFX_zzz');
      if vA<>'' then Scr.Prozedurname # vA;
      $edScr.Prozedurname->WinFocusSet();
      gMdi->WinUpdate();
    end;

    'Formular' : begin
      RecBufClear(912);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Frm.Verwaltung',here+':AusFormular');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusFormular
//
//========================================================================
sub AusFormular()
begin
  if (gSelected <> 0) then begin
    RecRead(912,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Scr.Name # AInt(Frm.Bereich) + '/' +Frm.Name;
  end;

  // Focus auf Editfeld setzen:
  $edScr.Name->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

  vHdl # gMenu->WinSearch('Mnu.Befehle');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode=c_ModeEdit) or (Mode=c_ModeNew));

  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode=c_ModeEdit) or (Mode=c_ModeNew));

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

    'Mnu.Copy' : begin
      RecBufClear(912); // Formularbuffer leeren
      RecBufClear(999); // Global leeren
      if(CopyScript() = false) then
        Msg(200105, gTitle, 0, 0, 0);
    end;

    'Mnu.Befehle' : begin
      RecBufClear(921);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Scr.B.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

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
local begin
  Erx     : int;
  vHdl    : int;
end;
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Prozedur' :   Auswahl('Prozedur');

    'bt.Formular' :   Auswahl('Formular');

    'Bt.OKauswahl' : begin
      recread(920, 1,_rnolock);
      gSelected # RecInfo(920,_recID);
      vHdl # $Scr.Auswahl;
      if (vHdl<>0) then vHdl->winClose();
      Erx # recread(920, 0,_recID, gSelected);
      RETURN true;
    end;

    'Bt.Abbruch' : begin
      gSelected # 0;
      vHdl # $Scr.Auswahl;
      if (vHdl<>0) then vHdl->winClose();
    end;

  end;

end;


//========================================================================
//  EvtMouseItem
//                Mausclick in Auswahlliste
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
local begin
  vTmp  : int;
end;
begin

  if (aItem=0) or (aID=0) then RETURN false;

  if ((aButton & _WinMouseLeft)<>0) and ((aButton & _WinMouseDouble)<>0) then begin
    gSelected # aID;
    vTmp # $Scr.Auswahl;
    if (vTmp<>0) then vTmp->Winclose();
  end;
end;


//========================================================================
//  EvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
local begin
  vHdl : int;
end;
begin
  if (aEvt:Obj->wpname='ZL.Scriptauswahl') and (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    vHdl # $Scr.Auswahl;
    if (vHdl<>0) then vHdl->Winclose();
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
// Auswahlliste
//          Zugriffsliste der zum Bereich passenden Scripte öffnen
//========================================================================
sub Auswahlliste(
  aBereich : alpha;
)
local begin
  Erx     : int;
  vMode   : alpha;
  vFilter : int;
  vHdl    : int;
end;
begin

  gSelected # 0;

  vFilter # RecFilterCreate(920,3);
  vFilter->RecFilterAdd(1,_fltAND,_FltEq, aBereich);
  vHdl # WinOpen('Scr.Auswahl',_WinOpenDialog);
  $ZL.Scriptauswahl->wpDBFilter # vFilter;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl->WinClose();
  RecFilterDestroy(vFilter);

  if (gSelected<>0) then begin
    Erx # recread(920, 0,_recID, gSelected);
    gSelected # 0;
    Lib_Script:Run(Scr.Nummer);
  end;

end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edScr.Name') AND (aBuf->Scr.Name<>'')) then begin
    todo('Formular')
    //RekLink(819,200,1,0);   // Name holen
    Lib_Guicom2:JumpToWindow('Frm.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edScr.Prozedurname') AND (aBuf->Scr.Prozedurname<>'')) then begin
    todo('Prozedur')
    //RekLink(819,200,1,0);   // Prozedur holen
    Lib_Guicom2:JumpToWindow('');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
