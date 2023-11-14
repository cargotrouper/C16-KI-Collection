@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lfs_Msk_Main
//                  OHNE E_R_G
//  Info
//
//
//  15.03.2004  AI  Erstellung der Prozedur
//  05.05.2011  TM  neue Auswahlmethode 1326/75
//  05.11.2013  AH  Fix: Kein LFS OHNE KdNr & Ziel
//  25.03.2014  AH  Neu: Zusatztext
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtChanged(aEvt : event) : logic;
//    SUB Auswahl(aBereich : alpha)
//    SUB AusSpediteur()
//    SUB AusPositionen()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtTimer(aEvt : event; aTimerId : int): logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
//  cDialog :   $Lfs.Maske
  cTitle :    'Lieferscheine'
  cFile :     440
  cMenuName : 'Lfs.Bearbeiten'
  cPrefix :   'Lfs_Msk'
  cZList :    0
  cKey :      1
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
//lfs_ms_main:erfreshifm();

  // ********************  Rechtecheck *********************************
  begin
    if (Rechte[Rgt_LFS_InterneKosten] = false) then begin
      Lib_GuiCom:Disable($edLfs.Kosten.FixW1);
      Lib_GuiCom:Disable($edLfs.Kosten.PEH);
      Lib_GuiCom:Disable($edLfs.Kosten.MEH);
      Lib_GuiCom:Disable($bt.MEH);
    end;
  end; // Rechtecheck

  SetStdAusFeld('edLfs.Spediteurnr'   ,'Spediteur');
  SetStdAusFeld('edLfs.Kosten.MEH'    ,'MEH');

  RunAFX('Lfs.Init.Pre',aint(aEvt:Obj));

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edLfs.Kosten.PEH);
  Lib_GuiCom:Pflichtfeld($edLfs.Kosten.MEH);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin

  if (aName='edLfs.Spediteurnr') and ($edLfs.Spediteurnr->wpchanged) then begin
    Erx # RecLink(100,440,6,_recFirst);
    If (Erx>_rLocked) then RecBufClear(100);
    Lfs.Spediteur # Adr.Stichwort;
    Lfs.SpediteurNr # Adr.Nummer;
    $edLfs.Spediteur->winupdate(_WinUpdFld2Obj);
  end;


  if (aName='') then begin
    if (Lfs.SpediteurNr<>0) then
      Lib_GuiCom:Disable($edLfs.Spediteur)
    else
      Lib_GuiCom:Enable($edLfs.Spediteur);

    $Lb.Datum->wpcaption # CnvAD(Lfs.Anlage.Datum);
    $Lb.Datum.Verbucht->wpcaption # CnvAD(Lfs.Datum.Verbucht);
    $Lb.Kundennr->wpcaption # AInt(Lfs.Kundennummer);
    $Lb.Zieladresse->wpcaption # AInt(Lfs.Zieladresse);
    $Lb.Zielanschrift->wpcaption # AInt(Lfs.Zielanschrift);
    $Lb.Kunde->wpcaption # Lfs.Kundenstichwort;
    Erx # RecLink(100,440,1,0);

    Erx # RecLink(101,440,3,0);
    if (Erx<=_rLocked) then begin
      $Lb.Ziel->wpcaption # Adr.A.Stichwort;
      $Lb.Ziel2->wpcaption # Adr.A.Ort;
    end
    else begin
      $Lb.Ziel->wpcaption # '';
      $Lb.Ziel2->wpcaption # '';
    end;
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vNr   : int;
  vPos  : word;
  vI    : int;
  vTree : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // 05.11.2013 AH: Kein LFS OHNE diese Felder (Dürfte eigentlich ja nie leer sein, aber hat ja OWF geschafft...)
  if (Lfs.Kundennummer=0) or (Lfs.Zieladresse=0) then RETURN false;

  // logische Prüfung
  if (Lfs.Kosten.PEH=0) then begin
    Msg(001200,Translate('Preiseinheit'),0,0,0);
    $edLfs.Kosten.PEH->WinFocusSet(true);
    RETURN false;
  end;
  if (Lfs.Kosten.MEH='') then begin
    Msg(001200,Translate('Mengeneinheit'),0,0,0);
    $edLfs.Kosten.MEH->WinFocusSet(true);
    RETURN false;
  end;
  If (Lfs.Kosten.MEH<>'Stk') and (Lfs.Kosten.MEH<>'kg') and
    (Lfs.Kosten.MEH<>'t') and (Lfs.Kosten.MEH<>'mm') and (Lfs.Kosten.MEH<>'lfm') and (Lfs.Kosten.MEH<>'m') and
    (Lfs.Kosten.MEH<>'pauschal') then begin
    Msg(001201,Translate('Mengeneinheit'),0,0,0);
    $edLfs.Kosten.MEH->WinFocusSet(true);
    RETURN false;
  end;

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
//    "xxx.Änderung.Datum"  # SysDate();
  //  "xxx.Änderung.Zeit"   # Now;
    //"xxx.Änderung.User"   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);

  end
  else begin  // Neuanlage

    if (Lfs_Data:SaveLFS()=false) then begin
      ErrorOutput;
      RETURN false;
    end;

    TxtRename(MyTmpText+'.440', '~440.'+CnvAI(LFs.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.001', 0);

  end;

  Mode # c_modeCancel;  // sofort alles beenden!
  gSelected # Lfs.Nummer; // 09.12.2019 AH war 1

  // Sonderfunktion:
  RunAFX('Lfs.Msk.RecSave.Post','');

  RETURN true;  // Speichern erfolgreich

end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin


  // ALLE Positionen verwerfen
  if (Mode=c_ModeNew) then begin
    if (Lfs.Nummer<mytmpNummer) and (Lfs.Nummer<>0) then begin
      TODO('PANIK !! Sie versuchen einen echten Lieferschein abzubrechen!!');
      RETURN false;
    end;
//todo('clean von '+cnvai(lfs.nummer));
    WHILE (RecLink(441,440,4,_RecFirst)=_rOk) do begin
      RekDelete(441,0,'MAN');
    END;

    TxtDelete(MyTmpText+'.440', 0);
  end;

  gSelected # 0;
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  RekDelete(gFile,0,'MAN');
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

  // Auswahlfelder einfärben
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);


  if (w_command='->POS') then begin
    w_command # '';
    gTimer2 # SysTimerCreate(300,1,gMdi);
    RETURN false;
  end;

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
  Erx : int;
end;
begin

  if (aEvt:Obj->wpname='edLfs.Spediteurnr') and ($edLfs.Spediteurnr->wpchanged) then begin
    Erx # RecLink(100,440,6,_RecFirst);
    if (Erx=_rOK) then
      Lfs.Spediteur # Adr.Stichwort
    else
      Lfs.Spediteur # ''
    $edLfs.Spediteur->Winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpname='edLfs.Kosten.MEH') and ($edLfs.Kosten.MEH->wpchanged) then begin
    if (Lfs.Kosten.MEH='pauschal') then begin
      Lfs.Kosten.PEH # 1;
      $edLfs.Kosten.PEH->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edLfs.Kosten.PEH);
      if (aFocusObject=$edLfs.Kosten.PEH) then $edLfs.Kosten.Pro->Winfocusset(false);
    end
    else begin
      Lib_GuiCom:Enable($edLfs.Kosten.PEH);
    end;
  end;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;


//========================================================================
//  EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (Mode=c_ModeNew) or (mode=c_ModeEdit) then begin
    $edLfs.Spediteurnr->winupdate(_WinUpdObj2Fld);
    if (Lfs.SpediteurNr<>0) then
      Lib_GuiCom:Disable($edLfs.Spediteur)
    else
      Lib_GuiCom:Enable($edLfs.Spediteur);
  end;

  RETURN(true);
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
    'Spediteur' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',Here+':AusSpediteur');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0 AND Adr.SperrLieferantYN = false'); // 21.06.2016 AH
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Positionen' : begin
      RecBufClear(441);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.P.Verwaltung',Here+':AusPositionen',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH-TRANSPORT',$edLfs.Kosten.MEH, 440,1,18);
      if (Lfs.Kosten.MEH='pauschal') then begin
        Lfs.Kosten.PEH # 1;
        $edLfs.Kosten.PEH->winupdate(_WinUpdFld2Obj);
        Lib_GuiCom:Disable($edLfs.Kosten.PEH);
      end
      else begin
        Lib_GuiCom:Enable($edLfs.Kosten.PEH);
      end;
    end;

  end;

end;


//========================================================================
//  AusSpediteur
//
//========================================================================
sub AusSpediteur()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Lfs.Spediteur # Adr.Stichwort;
    Lfs.SpediteurNr # Adr.Nummer;
    $edLfs.Spediteur->Winupdate(_WinUpdFld2Obj);

    if (Lfs.SpediteurNr<>0) then
      Lib_GuiCom:Disable($edLfs.Spediteur)
    else
      Lib_GuiCom:Enable($edLfs.Spediteur);
  end;
  // Focus auf Editfeld setzen:
  $edLfs.Spediteurnr->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusPositionen
//
//========================================================================
sub AusPositionen()
begin
  gSelected # 0;
  // Focus auf Editfeld setzen:
  SetFocus($edLfs.SpediteurNr, false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Positionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode=c_ModeEdit);

  vHdl # gMenu->WinSearch('Mnu.Druck.VLDAW');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_VLDAW]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.LFS');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_LFS]=n);

  vHdl # gMenu->WinSearch('Mnu.Verbuchen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or
                      (Lfs.Datum.Verbucht<>0.0.0) or
                      (Rechte[Rgt_Lfs_Verbuchen]=n);

  vHdl # gMenu->WinSearch('Mnu.Stornieren');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or
                      (Lfs.Datum.Verbucht=0.0.0) or
                      (Rechte[Rgt_Lfs_Stornieren]=n);


  if (Mode<>c_ModeOther) and (aNoRefresh=n) then RefreshIfm();

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

    'Mnu.Druck.LFS' : begin
      Lfs_Data:Druck_LFS();
    end;


    'Mnu.Druck.VLDAW' : begin
      Lfs_VLDAW_Data:Druck_VLDAW();
    end;


    'Mnu.Verbuchen' : begin
      Lfs_Data:Verbuchen(Lfs.Nummer, Today, now);
      ErrorOutput;
    end;


    'Mnu.Stornieren' : begin
      Lfs_Data:Stornieren(Lfs.Nummer, Today);
      ErrorOutput;
    end;


    'Mnu.Positionen' : begin
      RecBufClear(441);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.P.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
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
    'bt.Spediteur'      :   Auswahl('Spediteur');
    'bt.MEH'            :   Auswahl('MEH');
    'bt.Text'           :   Mdi_TXTEditor_Main:Start(MyTmpText+'.440', Rechte[Rgt_Lfs_Anlegen], Translate('Zusatztext'));

  end;

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
  if (Lfs.Datum.Verbucht<>0.0.0) then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);

  RecLink(100,440,1,_RecFirst);
//  Refreshmode(y);
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
// EvtTimer
//
//========================================================================
sub EvtTimer(
  aEvt                  : event;        // Ereignis
  aTimerId              : int;
): logic
local begin
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (gTimer2=aTimerId) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
    if (y) then begin
      Auswahl('Positionen');
    end;
  end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
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
//========================================================================
//========================================================================
//========================================================================
