@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rek_8_Main
//                  OHNE E_R_G
//  Info
//
//
//  28.05.2008  DS  Erstellung der Prozedur
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  06.09.2011  TM  Buttonsteuerung für 8D-Texte
//  16.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusFehlercode()
//    SUB AusVerursachernr()
//    SUB AusRessourceGrp()
//    SUB AusRessource()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aevt : event; aRecid : int);
//    SUB EvtClose(aEvt : event) : logic
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Reklamationstexte'
  cFile :     310
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Rek_8'
  cZList :    $ZL.Reklamationstexte
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
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edRek.8.Fehlercode);
Lib_Guicom2:Underline($edRek.8.Verursachernr);
Lib_Guicom2:Underline($edRek.8.VerursacherGrp);
Lib_Guicom2:Underline($edRek.8.VerursacherRes);

  SetStdAusFeld('edRek.8.Fehlercode'      ,'Fehlercode');
  SetStdAusFeld('edRek.8.VerursacherGrp'  ,'RessourceGrp');
  SetStdAusFeld('edRek.8.VerursacherRes'  ,'Ressource');
  SetStdAusFeld('edRek.8.Verursachernr'   ,'Verursachernr')

  $bt.RekText1->wpvisible # true;
  $bt.RekText2->wpvisible # true;
  $bt.RekText3->wpvisible # true;
  $bt.RekText4->wpvisible # true;
  $bt.RekText5->wpvisible # true;

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
)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin

  if (aName='') or (aName='edRek.8.Fehlercode') then begin
    Erx # RecLink(851,310,1,0);
    if (Erx<=_rLocked) then
      $Lb.Fehlercode->wpcaption # FhC.Bezeichnung
    else
      $Lb.Fehlercode->wpcaption # '';
  end;

  if (aName='') or (aName='edRek.8.VerursacherGrp') then begin
    Erx # RecLink(822,310,2,0);
    if (Erx<=_rLocked) then
      $lb.RessourceGrp->wpcaption # Rso.Grp.Bezeichnung
    else
      $lb.RessourceGrp->wpcaption # '';
  end;

  if (aName='') or (aName='edRek.8.VerursacherRes') then begin
    Erx # RecLink(160,310,3,0);
    if (Erx<=_rLocked) then
      $lb.Ressource->wpcaption # Rso.Stichwort
    else
      $lb.Ressource->wpcaption # '';
    Erx # RecLink(822,310,2,0);
    if (Erx<=_rLocked) then
      $lb.RessourceGrp->wpcaption # Rso.Grp.Bezeichnung
    else
      $lb.RessourceGrp->wpcaption # '';
  end;

  if (aName='') or (aName='edRek.8.Verursachernr') then begin
    Erx # RecLink(100,310,4,0);
    if (Erx<=_rLocked) then
      $lb.VerursacherNr->wpcaption # Adr.Stichwort
    else
      $lb.VerursacherNr->wpcaption # '';
  end;

  //Umsetzung der internen Nummer in Checkbox-Anzeige
  if (aName='') then begin
    if (Rek.8.Verursacher = 1) then begin
      $cb.Lieferant->wpcheckstate # _WinStateChkChecked;
      $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
      $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
      $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    end
    else if (Rek.8.Verursacher = 2) then begin
      $cb.Lieferant->wpcheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpcheckstate # _WinStateChkChecked;
      $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
      $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    end
    else if (Rek.8.Verursacher = 3) then begin
      $cb.Lieferant->wpcheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
      $cb.Person->wpcheckstate    # _WinStateChkChecked;
      $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    end
    else if (Rek.8.Verursacher = 4) then  begin
      $cb.Lieferant->wpcheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
      $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
      $cb.Unbekannt->wpcheckstate # _WinStateChkChecked;
    end
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
  // Vorbelegung bei Neuanlage Felder Disablen durch:
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) then begin
    $cb.Lieferant->wpcheckstate # _WinStateChkChecked;
    $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
    $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
    $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    Lib_GuiCom:Disable($edRek.8.VerursacherGrp);
    Lib_GuiCom:Disable($bt.RessourceGrp);
    Lib_GuiCom:Disable($edRek.8.VerursacherRes);
    Lib_GuiCom:Disable($bt.Ressource);
  end
  // im Ändern-Modus
  else if (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then begin
    if ($cb.Lieferant->wpcheckstate = _WinStateChkChecked) then begin
      Lib_GuiCom:Disable($edRek.8.VerursacherGrp);
      Lib_GuiCom:Disable($bt.RessourceGrp);
      Lib_GuiCom:Disable($edRek.8.VerursacherRes);
      Lib_GuiCom:Disable($bt.Ressource);
      Lib_GuiCom:Enable($edRek.8.Verursachernr);
      Lib_GuiCom:Enable($bt.Verursachernr);
    end
    else if ($cb.Ressource->wpcheckstate = _WinStateChkChecked) then begin
      Lib_GuiCom:Enable($edRek.8.VerursacherGrp);
      Lib_GuiCom:Enable($bt.RessourceGrp);
      Lib_GuiCom:Enable($edRek.8.VerursacherRes);
      Lib_GuiCom:Enable($bt.Ressource);
      Lib_GuiCom:Disable($edRek.8.Verursachernr);
      Lib_GuiCom:Disable($bt.Verursachernr);
    end
    else if ($cb.Person->wpcheckstate = _WinStateChkChecked) then begin
      Lib_GuiCom:Disable($edRek.8.VerursacherGrp);
      Lib_GuiCom:Disable($bt.RessourceGrp);
      Lib_GuiCom:Disable($edRek.8.VerursacherRes);
      Lib_GuiCom:Disable($bt.Ressource);
      Lib_GuiCom:Enable($edRek.8.Verursachernr);
      Lib_GuiCom:Disable($bt.Verursachernr);
    end
    else if ($cb.Unbekannt->wpcheckstate = _WinStateChkChecked)then begin
      Lib_GuiCom:Disable($edRek.8.VerursacherGrp);
      Lib_GuiCom:Disable($bt.RessourceGrp);
      Lib_GuiCom:Disable($edRek.8.VerursacherRes);
      Lib_GuiCom:Disable($bt.Ressource);
      Lib_GuiCom:Disable($edRek.8.Verursachernr);
      Lib_GuiCom:Disable($bt.Verursachernr);
    end;
  end;
  // Focus setzen auf Feld:
    $edRek.8.Fehlercode->winfocusset(true);
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
  If (Mode=c_ModeNew) and (Rek.8.Nummer=0) then begin
    Rek.8.Nummer # Lib_Nummern:ReadNummer('Reklamationstext');
    if (Rek.8.Nummer<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;
  end;

  // Umsetzung der Checkboxes in interne Nummer
  if ($cb.Lieferant->wpcheckstate      = _WinStateChkChecked) then Rek.8.Verursacher # 1
  else if ($cb.Ressource->wpcheckstate = _WinStateChkChecked) then Rek.8.Verursacher # 2
  else if ($cb.Person->wpcheckstate    = _WinStateChkChecked) then Rek.8.Verursacher # 3
  else if ($cb.Unbekannt->wpcheckstate = _WinStateChkChecked) then Rek.8.Verursacher # 4;

  // Satz zurückspeichern & protokollieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  RETURN true;  // Speichern erfolgreichend;
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
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;

//========================================================================
//  EvtChanged
//              Feldinhalt verändert
//========================================================================
sub EvtChanged (
  aEvt                  : event;        // Ereignis
) : logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (Mode=c_ModeView) then RETURN true;

  if (aEvt:Obj->wpname='cb.Lieferant') and ($cb.Lieferant->wpcheckstate = _WinStateChkChecked) then begin
    $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
    $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
    $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    Lib_GuiCom:Disable($edRek.8.VerursacherGrp);
    Lib_GuiCom:Disable($bt.RessourceGrp);
    Lib_GuiCom:Disable($edRek.8.VerursacherRes);
    Lib_GuiCom:Disable($bt.Ressource);
    Lib_GuiCom:Enable($edRek.8.Verursachernr);
    Lib_GuiCom:Enable($bt.Verursachernr);
    Rek.8.VerursacherGrp # 0;
    Rek.8.VerursacherRes # 0;
    RefreshIfm('edRek.8.VerursacherGrp');
    RefreshIfm('edRek.8.VerursacherRes');
  end
  else if (aEvt:Obj->wpname='cb.Lieferant') and ($cb.Lieferant->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.Lieferant->wpcheckstate # _WinStateChkChecked;
  end
  else if (aEvt:Obj->wpname='cb.Ressource') and ($cb.Ressource->wpcheckstate = _WinStateChkChecked) then begin
    $cb.Lieferant->wpcheckstate # _WinStateChkUnChecked;
    $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
    $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    Lib_GuiCom:Enable($edRek.8.VerursacherGrp);
    Lib_GuiCom:Enable($bt.RessourceGrp);
    Lib_GuiCom:Enable($edRek.8.VerursacherRes);
    Lib_GuiCom:Enable($bt.Ressource);
    Lib_GuiCom:Disable($edRek.8.Verursachernr);
    Lib_GuiCom:Disable($bt.Verursachernr);
    Rek.8.Verursachernr # 0;
    RefreshIfm('edRek.8.Verursachernr');
  end
  else if (aEvt:Obj->wpname='cb.Ressource') and ($cb.Ressource->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.Ressource->wpcheckstate # _WinStateChkChecked;
  end else if (aEvt:Obj->wpname='cb.Person') and ($cb.Person->wpcheckstate = _WinStateChkChecked) then begin
    $cb.Lieferant->wpcheckstate # _WinStateChkUnChecked;
    $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
    $cb.Unbekannt->wpcheckstate # _WinStateChkUnChecked;
    Lib_GuiCom:Disable($edRek.8.VerursacherGrp);
    Lib_GuiCom:Disable($bt.RessourceGrp);
    Lib_GuiCom:Disable($edRek.8.VerursacherRes);
    Lib_GuiCom:Disable($bt.Ressource);
    Lib_GuiCom:Enable($edRek.8.Verursachernr);
    Lib_GuiCom:Disable($bt.Verursachernr);
    Rek.8.VerursacherGrp # 0;
    Rek.8.VerursacherRes # 0;
    Rek.8.Verursachernr # 0;
    RefreshIfm('edRek.8.VerursacherGrp');
    RefreshIfm('edRek.8.VerursacherRes');
    RefreshIfm('edRek.8.Verursachernr');
  end
  else if (aEvt:Obj->wpname='cb.Person') and ($cb.Person->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.Person->wpcheckstate # _WinStateChkChecked;
  end
  else if (aEvt:Obj->wpname='cb.Unbekannt') and ($cb.Unbekannt->wpcheckstate = _WinStateChkChecked) then begin
    $cb.Lieferant->wpcheckstate # _WinStateChkUnChecked;
    $cb.Ressource->wpcheckstate # _WinStateChkUnChecked;
    $cb.Person->wpcheckstate    # _WinStateChkUnChecked;
    Lib_GuiCom:Disable($edRek.8.VerursacherGrp);
    Lib_GuiCom:Disable($bt.RessourceGrp);
    Lib_GuiCom:Disable($edRek.8.VerursacherRes);
    Lib_GuiCom:Disable($bt.Ressource);
    Lib_GuiCom:Disable($edRek.8.Verursachernr);
    Lib_GuiCom:Disable($bt.Verursachernr);
    Rek.8.VerursacherGrp # 0;
    Rek.8.VerursacherRes # 0;
    Rek.8.Verursachernr # 0;
    RefreshIfm('edRek.8.VerursacherGrp');
    RefreshIfm('edRek.8.VerursacherRes');
    RefreshIfm('edRek.8.Verursachernr');
  end
  else if (aEvt:Obj->wpname='cb.Unbekannt') and ($cb.Unbekannt->wpcheckstate = _WinStateChkUnChecked) then begin
    $cb.Unbekannt->wpcheckstate # _WinStateChkChecked;
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
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;

begin

  case aBereich of
    'Fehlercode' : begin
      RecBufClear(851);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'FhC.Verwaltung',here+':AusFehlercode');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'RessourceGrp' : begin
      RecBufClear(822);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rso.Grp.Verwaltung',here+':AusRessourceGrp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Ressource' : begin
      RecBufClear(160);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rso.Verwaltung',here+':AusRessource');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Verursachernr' : begin
      // nur wenn Lieferant ausgewählt ist, nicht bei Person
      if ($cb.Lieferant->wpcheckstate = _WinStateChkChecked) then begin
        RecBufClear(100);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusVerursachernr');
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;

    'RekText1' : begin
      Mdi_RtfEditor_Main:Start('~310.'+CnvAI(Rek.8.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.001', Rechte[Rgt_Rek8_Aendern], '');
    end;

    'RekText2' : begin
      Mdi_RtfEditor_Main:Start('~310.'+CnvAI(Rek.8.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.002', Rechte[Rgt_Rek8_Aendern], '');
    end;

    'RekText3' : begin
      Mdi_RtfEditor_Main:Start('~310.'+CnvAI(Rek.8.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.003', Rechte[Rgt_Rek8_Aendern], '');
    end;

    'RekText4' : begin
      Mdi_RtfEditor_Main:Start('~310.'+CnvAI(Rek.8.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.004', Rechte[Rgt_Rek8_Aendern], '');
    end;

    'RekText5' : begin
      Mdi_RtfEditor_Main:Start('~310.'+CnvAI(Rek.8.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.005', Rechte[Rgt_Rek8_Aendern], '');
    end;


  end;
end;

//========================================================================
//  AusFehlercode
//
//========================================================================
sub AusFehlercode()
begin
  if (gSelected<>0) then begin
    RecRead(851,0,_RecId,gSelected);
    Rek.8.Fehlercode  # FhC.Nummer;
  end;
  $edRek.8.Fehlercode->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.8.Fehlercode');
end;

//========================================================================
//  AusVerursachernr
//
//========================================================================
sub AusVerursachernr()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    Rek.8.Verursachernr  # Adr.Nummer;
  end;
  $edRek.8.Verursachernr->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.8.Verursachernr');
end;

//========================================================================
//  AusRessourceGrp
//
//========================================================================
sub AusRessourceGrp()
begin
  if (gSelected<>0) then begin
    RecRead(822,0,_RecId,gSelected);
    Rek.8.VerursacherGrp  # Rso.Grp.Nummer;
  end;
  $edRek.8.VerursacherGrp->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.8.VerursacherGrp');
end;

//========================================================================
//  AusRessource
//
//========================================================================
sub AusRessource()
begin
  if (gSelected<>0) then begin
    RecRead(160,0,_RecId,gSelected);
    Rek.8.VerursacherGrp  # Rso.Gruppe;
    Rek.8.VerursacherRes  # Rso.Nummer;
  end;
  $edRek.8.VerursacherRes->Winfocusset(false);
  gSelected # 0;
  RefreshIfm('edRek.8.VerursacherGrp');
  RefreshIfm('edRek.8.VerursacherRes');
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

  // Button sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek8_Anlegen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek8_Anlegen]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek8_Aendern]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek8_Aendern]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek8_Loeschen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rek8_Loeschen]=n);

  $bt.RekText1->wpdisabled # (Mode<>c_ModeEdit);
  $bt.RekText2->wpdisabled # (Mode<>c_ModeEdit);
  $bt.RekText3->wpdisabled # (Mode<>c_ModeEdit);
  $bt.RekText4->wpdisabled # (Mode<>c_ModeEdit);
  $bt.RekText5->wpdisabled # (Mode<>c_ModeEdit);

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
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
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

  if Mode=c_ModeView then RETURN true;

  case (aEvt:Obj->wpName) of

    'bt.Fehlercode'   :   Auswahl('Fehlercode');
    'bt.RessourceGrp' :   Auswahl('RessourceGrp');
    'bt.Ressource'    :   Auswahl('Ressource');
    'bt.VerursacherNr':   Auswahl('Verursachernr');

    'bt.RekText1'     :   Auswahl('RekText1');
    'bt.RekText2'     :   Auswahl('RekText2');
    'bt.RekText3'     :   Auswahl('RekText3');
    'bt.RekText4'     :   Auswahl('RekText4');
    'bt.RekText5'     :   Auswahl('RekText5');

  end;
end;

//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aevt      : event;
  aRecid    : int;
  Opt aMark : logic;
                   );
begin

  // Lieferant = 1
  if (Rek.8.Verursacher=1) then begin
    if (RecLink(100,310,4,_recFirst) > _rLocked) then RecBufClear(100);
    GV.Alpha.01 # 'Lieferant';
    GV.Alpha.02 # Adr.Stichwort;
  end
  // Ressource = 2
  else if (Rek.8.Verursacher=2) then begin
    if (RecLink(160,310,3,_recFirst) > _rLocked) then RecBufClear(100);
    GV.Alpha.01 # 'Ressource';
    GV.Alpha.02 # Rso.Stichwort;
  end
  //Person = 3
  else if (Rek.8.Verursacher=3) then begin
    GV.Alpha.01 # 'Person';
    GV.Alpha.02 # '';
  end
  //Unbekannt = 4
  else if (Rek.8.Verursacher=4) then begin
    GV.Alpha.01 # 'Unbekannt';
    GV.Alpha.02 # '';
  end
  else begin
    GV.Alpha.01 # '';
    GV.Alpha.02 # '';
  end;
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
  RETURn true;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edRek.8.Fehlercode') AND (aBuf->Rek.8.Fehlercode<>0)) then begin
    RekLink(851,310,1,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('FhC.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRek.8.Verursachernr') AND (aBuf->Rek.8.Verursachernr<>0)) then begin
    RekLink(100,310,4,0);   // Verursachernr holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRek.8.VerursacherGrp') AND (aBuf->Rek.8.VerursacherGrp<>0)) then begin
    RekLink(822,310,2,0);   // RessourceGrp,. holen
    Lib_Guicom2:JumpToWindow('Rso.Grp.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRek.8.VerursacherRes') AND (aBuf->Rek.8.VerursacherRes<>0)) then begin
    RekLink(160,310,3,0);   // Ressource holen
    Lib_Guicom2:JumpToWindow('Rso.Verwaltung');
    RETURN;
  end;
  
end;

//========================================================================
