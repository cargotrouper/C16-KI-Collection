@A+
//==== Business-Control ==================================================
//
//  Prozedur    Vsd_Main
//                        OHNE E_R_G
//  Info
//
//
//  02.07.2009  AI  Erstellung der Prozedur
//  22.12.2009  TM  Einbindung Druckformulare siehe SUB EvtMenuCommand
//  09.03.2010  MS  Druck Sammeltransportauftrag hinzugefuegt
//  11.03.2010  MS  Druck Abholfinfo (Freistellung) hinzugefuegt + korrektur des LFA + Lfs Drucks
//  09.04.2010  AI  für EK-VSB erweitert
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  21.09.2021  ST  Neu: Verladeanweisungsdruck hinzugefügt Projekt 2166/55
//  01.10.2021  MR  Neu: "Vsd.RecInit" Ankerfunktion Projekt 2166/88
//  04.10.2021  MR  Änderung von EvtCommand Verbuchen: Erfolgsmeldung nach print + Print in Lopp (Ticket 2166/55/2)
//  04.10.2021  MR  ERX
//  13.10.2021  MR  Printteil ausgelagert nach DruckLFS + Änderung sodass für gleiche Kommissionen nur ein Druck
//  26.07.2022  HA  Quick Jump
//  21.06.2023  ST  Customfelderverwaltung hinzugefügt
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB EvtMdiActivate( aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusSelbstabholer();
//    SUB AusSpediteur()
//    SUB AusRessource()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB DruckLFS()
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Versand'
  cFile       :  650
  cMenuName   : 'Vsd.Bearbeiten'
  cPrefix     : 'Vsd'
  cZList      : $ZL.Versand
  cKey        : 1
  cListen     : '';
end;

declare Auswahl(aBereich : alpha)

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

Lib_Guicom2:Underline($edVsd.SelbstabholKdNr);
Lib_Guicom2:Underline($edVsd.Spediteurnr);
Lib_Guicom2:Underline($edVsd.Ressource);

// Auswahlfelder setzen...
   SetStdAusFeld('edVsd.Spediteurnr'     ,'Spediteur');
   SetStdAusFeld('edVsd.Ressource.Grp'   ,'Ressource');
   SetStdAusFeld('edVsd.SelbstabholKdNr' ,'Selbstabholer');

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
  //Lib_GuiCom:Pflichtfeld($edVsd.Spediteurnr);
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
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_VSD;
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
  Erx   : int;
end;
begin

  if (aName='') then begin
    if (Vsd.Nummer>0) and (Vsd.Nummer<1000000000) then
      $lbVsd.Nummer->wpcaption # AInt(Vsd.Nummer)
    else
      $lbVsd.Nummer->wpcaption # '';
  end;

  if (aName='edVsd.SelbstabholKdNr') and ($edVsd.SelbstabholKdNr->wpchanged) then begin
    Erx # RecLink(100,650,4,_recFirst);   // Selbstabholer holen
    if (Erx>_rMultikey) or (Vsd.SelbstabholKdNr=0) then RecBufClear(100);
    Vsd.SelbstabholKdNr # Adr.Kundennr;
    Vsd.SelbstabholSW   # Adr.Stichwort;
  end;
  $lb.Selbstabholer->wpcaption # Vsd.SelbstabholSW;


  if (aName='edVsd.Spediteurnr') and ($edVsd.Spediteurnr->wpchanged) then begin
    Erx # RecLink(100,650,1,_recFirst);   // Spediteuer holen
    if (Erx>_rMultikey) or (Vsd.Spediteurnr=0) then RecBufClear(100);
    Vsd.Spediteurnr # Adr.Nummer;
    Vsd.SpediteurSW # Adr.Stichwort;
  end;
  $lb.Spediteur->wpcaption # Vsd.SpediteurSW;


  if (aName='') or ((aName='edVsd.Ressource.Grp') and ($edVsd.Ressource.Grp->wpchanged)) then begin
    Erx # RecLink(160,650,2,_recFirst);   // Ressource holen
    if (Erx>_rMultikey) or (Vsd.Ressource.Grp=0) then RecBufClear(160);
    if (aName<>'') then begin
      Vsd.Ressource.Grp   # Rso.Gruppe;
      Vsd.Ressource       # Rso.Nummer;
    end;
    $lb.Ressource->wpcaption # Rso.Stichwort;
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
  //Lib_GuiCom:Disable($...);

    //Ankerfunktion
  if (RunAFX('Vsd.RecInit','')<0) then RETURN;

  if (Mode=c_ModeNew) then begin
    Vsd.Nummer  # myTmpNummer;
    Vsd.Datum   # today;
    Vsd.Zeit    # now;
    $edVsd.SelbstabholKdNr->WinFocusSet(true);
  end
  else begin
    $edVsd.Spediteurnr->WinFocusSet(true);
  end;


  // 2022-11-10 AH    Proj. 2228/179
  if (Vsd.Datum.Verbucht=0.0.0) then
    Lib_GuiCom:Enable($edVsd.GesamtKostenW1)

  // gleich in Positionen springen...
  //gTimer2 # SysTimerCreate(1,1,gMDI);
  //w_TimerVar # '->Pos';

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vNr : int;
  Erx : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
//  If (Vsd.Spediteurnr=0) then begin   03.11.2021 AH
//    Msg(001200,Translate('Spediteur'),0,0,0);
//    $NB.Main->wpcurrent # 'NB.Page1';
//    $edVsd.Spediteurnr->WinFocusSet(true);
//    RETURN false;
//  end;
  If (Vsd.Spediteurnr<>0) then begin
    Erx # RecLink(100,650,1,_recFirst);   // Spediteur holen
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Spediteuer'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edVsd.Spediteuer->WinFocusSet(true);
      RETURN false;
    end;
  end;
  
  if (Vsd.SelbstabholKdNr<>0) then begin
    Erx # RecLink(100,650,4,_recFirst);   // Selbstabholer holen
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Kunde'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edVsd.SelbstabholKdNr->WinFocusSet(true);
      RETURN false;
    end;
  end;

  // Positionen vorhanden?
//  If (RecLinkInfo(651,650,3,_reccount)=0) then begin
//    Msg(001200,Translate('Positionen'),0,0,0);
//    $NB.Main->wpcurrent # 'NB.Page1';
//    $edVsd.Spediteurnr->WinFocusSet(true);
//    RETURN false;
//  end;

  // Sicherheitsabfrage...
//  if (Mode=c_ModeNew) then begin
//    if (Msg(650000,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;
//  end;


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

    TRANSON;

    vNr # Lib_Nummern:ReadNummer('Versand');
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      RETURN false;
    end;

    Erx # RecLink(651,650,3,_recFirst);   // Positionen loopen
    WHILE (Erx<=_rLocked) do begin
      RecRead(651,1,_recLock);
      Vsd.P.Nummer # vNr;
      Erx # RekReplace(651,_RecUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN false;
      end;
      Erx # RecLink(651,650,3,_recFirst);
    END;

    Vsd.Nummer        # vNr;
    Vsd.Anlage.Datum  # Today;
    Vsd.Anlage.Zeit   # Now;
    Vsd.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    //  verbuchen in BA...
//    if (Vsd_Data:ErzeugeBAGs()=false) then begin
//      TRANSBRK;
//      Vsd.Nummer # myTmpNummer;
//      Error(650001,'');
//      ErrorOutput;
//      RETURN false;
//    end;

    TRANSOFF;

  end;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
local begin
  Erx : int;
end;
begin

  // tmp. Erfassung löschen...
  if (Vsd.Nummer>1000000000) then begin

    TRANSON;

    Erx # RecLink(651,650,3,_recFirst);     // Positionen loopen
    WHILE (Erx<=_rLocked) do begin

      Erx # RecLink(655,651,2,_recFirst);   // Pool holen
      if (Erx<=_rLockeD) then begin
        Erx # RecRead(655,1,_recLock);
        VsP.Menge.In.Rest   # VsP.Menge.In.Rest + VsD.P.Menge.In;
        VsP.Menge.Out.Rest  # VsP.Menge.Out.Rest + VsD.P.Menge.Out;
        "VsP.Stück.Rest"    # "VsP.Stück.Rest" + "VsD.P.Stück";;
        VsP.Gewicht.Rest    # VsP.Gewicht.Rest + VsD.P.Gewicht;
        Erx # RekReplace(655,_RecUnlock,'AUTO');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN false;
        end;
      end;

      Erx # RekDelete(651,_RecUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN false;
      end;
      Erx # RecLink(651,650,3,_recFirst);
    END;

    TRANSOFF;
  end;

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
  if (Mode<>c_ModeList) or
    (Rechte[Rgt_Vsd_Loeschen]=n) or (RecLinkInfo(651,650,3,_recCount)>0) then RETURN;

  if ("VsD.Löschmarker"='*') then RETURN;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    Erx # RecRead(650,1,_recLock);
    "Vsd.Löschmarker" # '*';
    Erx # RekReplace(650,_recUnlock,'MAN');
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
local begin
  vA    : alpha;
end;

begin

  case aBereich of

    'Selbstabholer' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusSelbstabholer');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.Kundennr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Spediteur' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusSpediteur');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Ressource' : begin
      RecBufClear(160);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rso.Verwaltung',here+':AusRessource');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Positionen' : begin
      if (Vsd.Nummer<>0) then begin
        RecBufClear(651);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Vsd.P.Verwaltung','',y);
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;

  end;

end;


//========================================================================
//  AusSelbstabholer
//
//========================================================================
sub AusSelbstabholer()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Vsd.SelbstabholKdnr # Adr.Kundennr;
    Vsd.SelbstabholSW # Adr.Stichwort;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edVsd.SelbstabholKdNr->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  AusSpediteur
//
//========================================================================
sub AusSpediteur()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Vsd.Spediteurnr # Adr.Nummer;
    Vsd.SpediteurSW # Adr.Stichwort;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edVsd.SpediteurNr->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  AusRessource
//
//========================================================================
sub AusRessource()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(160,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Vsd.Ressource.Grp # Rso.Gruppe;
    Vsd.Ressource     # Rso.Nummer;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edVsd.Ressource.Grp->Winfocusset(false);
  $lb.Ressource->wpcaption # Rso.Stichwort;
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
  gMDI->WinUpdate(_WinUpdFld2Obj);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) or (w_Auswahlmode)) or
                 (Rechte[Rgt_Vsd_Loeschen]=n) or (RecLinkInfo(651,650,3,_recCount)>0);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) or (w_Auswahlmode)) or
                 (Rechte[Rgt_Vsd_Loeschen]=n) or (RecLinkInfo(651,650,3,_recCount)>0);

  vHdl # gMenu->WinSearch('Mnu.Positionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # n;

  vHdl # gMenu->WinSearch('Mnu.Verbuchen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or
                      ("Vsd.Löschmarker"<>'') or
                      (Rechte[Rgt_VSD_Verbuchen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

end;

//============================================================================================
//  DruckLFS
//           Druckt je nach Lieferscheinnummer einen oder mehrere Formulare (Ticket 2166/55/2)
//============================================================================================
sub DruckLFS()
local begin
  vList     : int;
  vListItem : int;
  Erx       : int;
  vItem     : int;
end;
begin
  // vTxt # Textopen(20);
  vList # CteOpen(_CteTree);
  // Positionen loopen....
  FOR vItem # RecLink(651,650,3,_recFirst);
  LOOP vItem # RecLink(651,650,3,_recNext);
  WHILE (vItem<=_rLocked) do begin
    Erx # RecLink(655,651,2,_recFirst); // Pool holen?
    if (erx>_rLockeD) then begin
      Erx # RecLink(656,651,3,_recFirst); // PoolAblage holen?
      if (erx>_rLockeD) then CYCLE;
        RecBufCopy(656,655);
      end;
      if (VsP.Materialnr=0) then CYCLE;
          
      // Lfs-Position mit diesem Material finden...
      RecBufClear(441);
      Lfs.P.Materialnr # VsP.Materialnr;
      Erx # RecRead(441,3,0);
      if (erx>_rMultikey) then CYCLE;

      // Lfs.P.Nummer !!
      // if (Textsearch(vTxt,1,1,0,'|'+aint(Lfs.P.Nummer)+'|')>0) then CYCLE;
      vListItem # vList->CteRead(_CteFirst | _CteSearch, 0,aint(Lfs.P.Nummer));
      if (vListItem <> 0) then CYCLE;

      // TextAddline(vTxt, '|'+aint(Lfs.P.Nummer)+'|');
      vList->CteInsertItem(aint(Lfs.P.Nummer),0,'');
//debugx('Druck für LFS'+aint(Lfs.P.Nummer));
      Erx # RecLink(440,441,1,_RecFirst);   // LFS Kopf holen
      if (Lfs.Nummer<>0) and (Erx<=_rLocked) then begin
        Lfs_VLDAW_Data:Druck_VLDAW();
//debugx('Druck für LFS'+aint(Lfs.Nummer));
      end;
    END;
        
    // Aufräumen
    vList->CteClear(true);
    CteClose(vList);
    // TextClose(vTxt);
        
    // Erfolg
    Msg(999998,'',0,0,0);
end

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
  Erx       : int;
  vTree     : int;
  vSortkey  : alpha(1000);
  vItem     : int;
  vBANummer   : int;
  vBAPosition : int;
  vQ        : alpha(4000);
  vBuf      : int;
  vTmp      : int;
  vRef      : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of


    'Mnu.Filter.Geloescht' : begin
      Filter_VSD # !(Filter_VSD);
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_VSD;

      if (gZLList->wpdbselection<>0) then begin
        vHdl # gZLList->wpdbselection;
        if (SelInfo(vHdl, _SelCount) > 0) then
          vRef # _WinLstRecFromRecId
        else
          vRef # _WinLstFromFirst;
        gZLList->wpDbSelection # 0;
        SelClose(vHdl);
        SelDelete(gFile,w_selName);
        w_SelName # '';
        gZLList->WinUpdate(_WinUpdOn, vRef | _WinLstRecDoSelect);
        App_Main:Refreshmode();
        RETURN true;
      end;
      vQ # '';
      Lib_Sel:QAlpha( var vQ, '"Vsd.Löschmarker"', '=','');
      Lib_Sel:QRecList(0,vQ);
      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);

      App_Main:Refreshmode();
      RETURN true;
    end;


   'Mnu.Verbuchen' : begin
      If (RecLinkInfo(651,650,3,_reccount)=0) then begin
        Msg(001200,Translate('Positionen'),0,0,0);
        RETURN false;
      end;

      // Sicherheitsabfrage...
      if (Vsd.SelbstabholKdNr=0) then begin
        if (Msg(650000,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;
        end
      else begin
        if (Msg(650002,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;
      end;

      if (Vsd_Data:Verbuchen()=false) then begin
        Error(650001,'');
        ErrorOutput;
        RETURN false;
      end;

      App_Main:Refresh(); // 29.09.2021
      
      //04.10.2021  MR  Änderung (Ticket 2166/55/2)
      if(Set.LFS.sofortDVSDYN = true) then begin // Formulardruck nach verbuchen?
        DruckLFS();
      
      end;
    end;


    'Mnu.Positionen' : begin
      Auswahl('Positionen');
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Vsd.Anlage.Datum, Vsd.Anlage.Zeit, Vsd.Anlage.User);
    end;


    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;



     // ======= !!!!

    'Mnu.Druck.Fahrauftrag' : begin

      vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

      Erx # RecLink(651,650,3,_recFirst); // Rambaum füllen

      WHILE (Erx <= _rLocked) DO BEGIN

        If (Vsd.P.BAG <>0 and Vsd.P.BAG.Position <>0) then begin
          BAG.P.Nummer    # VSD.P.BAG;
          BAG.P.Position  # VSD.P.BAG.Position;
          Erx # RecRead(702,1,0);

          If (Erx <= _rLocked) then begin

            vSortkey # cnvai(BAG.P.Nummer,_FmtNumLeadZero|_fmtNumNoGroup,0,10) +'|'
                     + cnvai(BAG.P.Position,_FmtNumLeadZero|_fmtNumNoGroup,0,10) +'|'

            Sort_ItemAdd(vTree,vSortKey,702,RecInfo(702,_RecId));

          End;

        End;

        Erx # RecLink(651,650,3,_recNext);
      END;

      vBANummer   # 0;
      vBAPosition # 0;
      FOR   vItem # Sort_ItemFirst(vTree)// Ausgabe pro BA-Position
      loop  vItem # Sort_ItemNext(vTree,vItem)
      WHILE (vItem != 0) do begin

        // Datensatz holen
        RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

        If (BAG.P.Nummer <> vBANummer) or (BAG.P.Position <> vBAPosition) then begin
          // Speditionn lesen um die Sprache herauszubekommen
          RecLink(100,702,7,_RecFirst);
          Lib_Dokumente:Printform(700,'Lohnfahrauftrag',true);
          vBANummer   # BAG.P.Nummer;
          vBAPosition # BAG.P.Position;
        end;


      end;

      // Löschen des Rambaums
      Sort_KillList(vTree);

    end;

    'Mnu.Druck.Frachtbrief' : begin

    end;

    'Mnu.Druck.Sammeltransportauftrag' : begin
      Lib_Dokumente:Printform(650, 'Sammeltransportauftrag', true);
    end;
    /*
    
    'Mnu.Druck.Lieferschein'  : begin
      Vsd_Data:DruckLfs();
      end;
    'Mnu.Druck.Verladeanweisung'  : begin
      Vsd_Data:DruckVLDAWs();
    end;
      
    */

    'Mnu.Druck.Lieferschein', 'Mnu.Druck.Abholinfo','Mnu.Druck.Verladeanweisungen' : begin

      if(aMenuItem->wpName = 'Mnu.Druck.Abholinfo') then begin
        Erx # Lib_Dokumente:RekReadFrm(440, 'Freistellung');
        if (Erx > _rLocked) then
          RecBufClear(912);
        vBuf # RekSave(912);

        Erx # Lib_Dokumente:RekReadFrm(650, 'Abholinfo');
        if (Erx > _rLocked) then
          RecBufClear(912);

        if(Frm.Prozedur <> vBuf->Frm.Prozedur) then begin // als Abholinfo soll nicht die Freistelleung gedruckt werden
          RecBufDestroy(vBuf);
          Lib_Dokumente:Printform(650,'Abholinfo',true);
          RETURN true;
        end;
        RecBufDestroy(vBuf);
      end;


      vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

      Erx # RecLink(651,650,3,_recFirst); // Rambaum füllen
      WHILE (Erx <= _rLocked) DO BEGIN
        If (Vsd.P.BAG <>0 and Vsd.P.BAG.Position <>0) then begin

          Lfs.ZuBA.Nummer   # VSD.P.BAG;
          Lfs.ZuBA.Position # VSD.P.BAG.Position;
          Erx # RecRead(440,2,0);

          If (Erx <= _rMultikey) then begin
            vSortkey # cnvai(Lfs.Nummer,_FmtNumLeadZero|_fmtNumNoGroup,0,10) +'|'
            Sort_ItemAdd(vTree,vSortKey,440,RecInfo(440,_RecId));
          End;

        End;

        Erx # RecLink(651,650,3,_recNext);
      END;


      vBANummer   # 0;
      vBAPosition # 0;
      FOR   vItem # Sort_ItemFirst(vTree)// Ausgabe pro Lieferscheinnummer
      loop  vItem # Sort_ItemNext(vTree,vItem)
      WHILE (vItem <> 0) do begin

        // Datensatz holen
        RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

        If (Lfs.ZuBA.Nummer <> vBANummer) or (Lfs.ZuBA.Position <> vBAPosition) then begin
          Erx # RecLink(100,440,2,_RecFirsT);   // Zieladresse holen
          if(Erx > _rLocked) then
            RecBufClear(100);

          // Druckformular aussuchen / aufrufen
          if(aMenuItem->wpName = 'Mnu.Druck.Lieferschein') then
            Lib_Dokumente:Printform(440,'Lieferschein',true);
          else if(aMenuItem->wpName = 'Mnu.Druck.Abholinfo') then
            Lib_Dokumente:Printform(440,'Freistellung',true);
          else if(aMenuItem->wpName = 'Mnu.Druck.Verladeanweisungen') then
            Lib_Dokumente:Printform(440,'Verladeanweisung',true);

          vBANummer   # Lfs.ZuBA.Nummer;
          vBAPosition # Lfs.ZuBA.Position;
        end;

      end;

      // Löschen des Rambaums
      Sort_KillList(vTree);
    end;

    // =======

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
    'bt.Spediteur'      :   Auswahl('Spediteur');
    'bt.Ressource'      :   Auswahl('Ressource');
    'bt.Selbstabholer'  :   Auswahl('Selbstabholer');
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
  if ("Vsd.Löschmarker"<>'') then
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
//  EvtTimer
//
//========================================================================
sub EvtTimer(
  aEvt                 : event;    // Ereignis
  aTimerID             : int;      // Timer-ID
)
: logic;
begin
  if (aTimerID=gTimer2) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
    if (w_TimerVar='->Pos') then begin
      w_TimerVar # '';
      Auswahl('Positionen');
    end;
    end
  else begin
    App_Main:EvtTimer(aEvt, aTimerId);
  end;

  RETURN true;
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

  if ((aName =^ 'edVsd.SelbstabholKdNr') AND (aBuf->Vsd.SelbstabholKdNr<>0)) then begin
    RekLink(100,650,4,0);   // Selbstabholer holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVsd.Spediteurnr') AND (aBuf->Vsd.Spediteurnr<>0)) then begin
    RekLink(100,650,1,0);   // Spediteur holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVsd.Ressource') AND (aBuf->Vsd.Ressource<>0)) then begin
    RekLink(160,650,2,0);   // Ressource holen
    Lib_Guicom2:JumpToWindow('Rso.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================