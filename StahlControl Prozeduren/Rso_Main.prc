@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Main
//                    OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  07.03.2008  ST  Kostenstelle hinzugefügt
//  27.07.2021  ST  Anker "Rso.Init.Pre" und "Rso.Init.Pre" hinzugefügt
//  27.07.2021  AH  ERX
//  08.09.2021  ST  Neu:Datenimport / Export
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB SwitchMask();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusGruppe()
//    SUB AusKostenstelle()
//    SUB AusAbteilung()
//    SUB AusHersteller()
//    SUB AusKundendienst()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB Pflichtfelder();
//
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle :    'Ressourcen'
  cFile :     160
  cMenuName : 'Rso.Bearbeiten'
  cPrefix :   'Rso'
  cZList  :   $ZL.Ressourcen
  cKey :      1
end;

declare Pflichtfelder();

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

Lib_Guicom2:Underline($edRso.Gruppe);
Lib_Guicom2:Underline($edRso.Abteilung);
Lib_Guicom2:Underline($edRso.Kostenstelle);
Lib_Guicom2:Underline($edRso.Hersteller);
Lib_Guicom2:Underline($edRso.Kundendienst);

  // Auswahlfelder setzen...
  SetStdAusFeld('edRso.Aktionstyp','BATyp');
  SetStdAusFeld('edRso.MEHh'      ,'MEH');
  SetStdAusFeld('edRso.Gruppe'    ,'Gruppe');
  SetStdAusFeld('edRso.Abteilung' ,'Abteilung');
  SetStdAusFeld('edRso.Kostenstelle','Kostenstelle');
  SetStdAusFeld('edRso.Hersteller'  ,'Hersteller');
  SetStdAusFeld('edRso.Kundendienst','Kundendienst');

  RunAFX('Rso.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Rso.Init',aint(aEvt:Obj));
  
  // ST CHROME Prototyp
  if (App_Main:Entwicklerversion() AND ((gUsername= 'ST') OR (gUsername = 'TM'))) then
    SFX_Chromium:AddServiceChromiumNotebookPage($NB.Main,0,'Chromium Graph','Kalender/',Aint(Rso.Gruppe));
  
end;


//========================================================================
//  Switchmask
//      Passenden Notebooks aktivieren
//========================================================================
sub SwitchMask();
local begin
  Erx : int;
end
begin
  Erx # RecLink(822,160,3,0);   // Gruppe holen
  if (erx>_rLocked) then RecbufClear(822);
  if (Rso.Grp.PersonalYN) then begin
    if ($NB.Main->wpcurrent='NB.Page2') or ($NB.Main->wpcurrent='NB.Page3') or ($NB.Main->wpcurrent='NB.Page4') then $NB.Main->wpcurrent # 'NB.Page1';
    $NB.Page2->wpvisible # false;
    $NB.Page3->wpvisible # false;
    $NB.Page4->wpvisible # false;
    $NB.Page5->wpvisible # true;
    end
  else begin
    if ($NB.Main->wpcurrent='NB.Page5') then $NB.Main->wpcurrent # 'NB.Page1';
    $NB.Page2->wpvisible # true;
    $NB.Page3->wpvisible # true;
    $NB.Page4->wpvisible # true;
    $NB.Page5->wpvisible # false;
  end;
  
  
  SFX_Chromium:RefreshServiceChromiumNotebookPage(Aint(Rso.Gruppe));
  
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vHdl  : int;
  vTmp  : int;
  Erx   : int;
end;
begin

  $lbRso.t_RstInputLfd->wpcaption   # Translate('pro Einsatz')+' '+"Rso.MEHProh";
  $lbRso.t_ProdOutLfd->wpcaption    # Translate('pro Fertig')+' '+"Rso.MEHProh";
  $lbRso.t_AbsetzInpLfd->wpcaption  # Translate('pro Einsatz')+' '+"Rso.MEHProh";
  $lbRso.t_AbsetzOutLfd->wpcaption  # Translate('pro Fertig')+' '+"Rso.MEHProh";

  if ($NB.Main->wpcurrent='NB.Page4') then begin
    if (Rso.Aktionstyp=c_BAG_Tafel) or (Rso.Aktionstyp=c_BAG_ABCOIL) then
      $NB.Zusatz->wpcurrent # 'NB.Zusatz.Tafel'
    else
      $NB.Zusatz->wpcurrent # 'NB.Zusatz.Divers';
  end;

  if (aName='') then begin
    $Lb.HW1->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW2->wpCaption # "Set.Hauswährung.Kurz";
  end;

  if (aName='') or (aName='edRso.Stichwort') then begin
    $Lb.Stichwort->wpcaption # Rso.Stichwort;
    $Lb.Stichwort2->wpcaption # Rso.Stichwort;
    $Lb.Stichwort3->wpcaption # Rso.Stichwort;
  end;

  if (aName='') or (aName='edRso.Gruppe') then begin
    Erx # RecLink(822,160,3,0);   // Gruppe holen
    if (Erx<=_rLocked) then
      $Lb.Gruppe->wpcaption # Rso.Grp.Bezeichnung
    else
      $Lb.Gruppe->wpcaption # '';
      SwitchMask();
  end;

  if (aName='') or (aName='edRso.Abteilung') then begin
    Erx # RecLink(821,160,2,0);
    if (Erx<=_rLocked) then
      $Lb.Abteilung->wpcaption # Abt.Bezeichnung
    else
      $Lb.Abteilung->wpcaption # '';
  end;
  if (aName='') or (aName='edRso.Kostenstelle') then begin
    Erx # RecLink(846,160,9,0);
    if (Erx<=_rLocked) then
      $Lb.Kostenstelle->wpcaption # KsT.Bezeichnung
    else
      $Lb.Kostenstelle->wpcaption # '';
  end;
  if (aName='') or (aName='edRso.Hersteller') then begin
    Erx # RecLink(100,160,4,0);
    if (Erx<=_rLocked) then begin
      $Lb.Hersteller1->wpcaption # Adr.Stichwort;
      $Lb.Hersteller2->wpcaption # Adr.Name+', '+Adr.Ort;
      end
    else begin
      $Lb.Hersteller1->wpcaption # '';
      $Lb.Hersteller2->wpcaption # '';
    end;
  end;
  if (aName='') or (aName='edRso.Kundendienst') then begin
    Erx # RecLink(100,160,5,0);
    if (Erx<=_rLocked) then begin
      $Lb.Kundendienst1->wpcaption # Adr.Stichwort;
      $Lb.Kundendienst2->wpcaption # Adr.Name+', '+Adr.Ort;
      end
    else begin
      $Lb.Kundendienst1->wpcaption # '';
      $Lb.Kundendienst2->wpcaption # '';
    end;
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
  
  SFX_Chromium:RefreshServiceChromiumNotebookPage(Aint(Rso.Gruppe));
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  // Felder Disablen durch:
  if (Mode=c_ModeEdit) then begin
    Lib_GuiCom:Disable($edRso.Gruppe);
    Lib_GuiCom:Disable($edRso.Nummer);
    Lib_GuiCom:Disable($edRso.Abteilung);
    $edRso.Stichwort->WinFocusSet(true);
    end
  else begin
    $edRso.Gruppe->WinFocusSet(true);
  end;

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vBuf160 : handle;
  vTmp    : int;
  Erx     : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if (Rso.Gruppe = 0) then begin
    Msg(001200,Translate('Gruppe'),0,0,0);
    vTmp # gMdi->winsearch('edRso.Gruppe');
    if (vTmp<>0) then vTmp->winFocusSet();
    RETURN false;
  end;

  if (Rso.Nummer = 0) then begin
    Msg(001200,Translate('Nummer'),0,0,0);
    vTmp # gMdi->winsearch('edRso.Nummer');
    if (vTmp<>0) then vTmp->winFocusSet();
    RETURN false;
  end;

  if (Rso.Abteilung = 0) then begin
    Msg(001200,Translate('Abteilung'),0,0,0);
    vTmp # gMdi->winsearch('edRso.Abteilung');
    if (vTmp<>0) then vTmp->winFocusSet();
    RETURN false;
  end;

  if (Rso.Personal.Code<>'') then begin
    if (StrCnv(Rso.Personal.Code, _StrLetteR)<>Rso.Personal.Code) then begin
      Msg(160000,'',0,0,0);
      $NB.Main->wpcurrent # 'NB.Page5';
      $edRso.Personal.Code->WinFocusSet(true);
      RETURN false;
    end;
    vBuf160 # RecBufCreate(160);
    vBuf160->Rso.Personal.Code # Rso.Personal.Code;
    Erx # RecRead(vBuf160, 3, 0);
    if (Erx<=_rMultikey) then begin
      if (vBuf160->Rso.Nummer<>Rso.Nummer) or (vBuf160->Rso.Gruppe<>Rso.Gruppe) then begin
        RecBufDestroy(vBuf160);
        Msg(160001,'',0,0,0);
        $NB.Main->wpcurrent # 'NB.Page5';
        $edRso.Personal.Code->WinFocusSet(true);
        RETURN false;
      end;
    end;
    RecBufDestroy(vBuf160);
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
    Rso.Anlage.Datum  # SysDate();
    Rso.Anlage.Zeit   # Now;
    Rso.Anlage.User   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));

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

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  if (aEvt:Obj->wpname='jump') then begin

    case (aEvt:Obj->wpcustom) of

      'Page1Start' : begin
        if (aFocusObject<>0) then begin
          if (aFocusObject=$NB.Zusatz.Tafel) then
            $edRso._Besumen->Winfocusset(false)
          else
            aFocusObject->winfocusset(false);
        end;
        $NB.Main->wpcurrent # 'NB.Page1';
        if (Mode=c_ModeNew) then
          $edRso.Gruppe->winfocusset(false)
        else
          $edRso.Stichwort->winfocusset(false);
        end;
      'Page2Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page2';
        $edRso.Hersteller->winfocusset(false);
        end;
      'Page3Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page3';
        $edRso.t_Rstbasis->winfocusset(false);
        end;
      'Page4Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page4';
        $edRso.t_Messerbau->winfocusset(false);
        end;

      'Page1E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $edRso.MEHh->winfocusset(false);
        end;
      'Page2E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page2';
        $edRso.Aktionstyp->winfocusset(false);
        end;
      'Page3E' : begin
        $edRso.t_Messerbau->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page3';
        $edRso.t_AbsetzOutLfd->winfocusset(false);
        end;
      'Page4E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page4';
        $edRso._Besumen->winfocusset(false);
        end;
    end;
    RETURN true;
  end;

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
  vQ    : alpha(4000);
  Erx   : int;
end;
begin

  case aBereich of

    'BATyp' : begin
      Lib_Einheiten:Popup('BAAktion',$edRso.Aktionstyp,160,2,11);
      $edRso.Aktionstyp->winfocusset(false);
      RefreshIfm('edRso.Aktionstyp');
    end;


    'Gruppe' : begin
      RecBufClear(822);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Grp.Verwaltung','Rso_Main:AusGruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Abteilung' : begin
      RecBufClear(821);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Abt.Verwaltung','Rso_Main:AusAbteilung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kostenstelle' : begin
      RecBufClear(846);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'KsT.Verwaltung','Rso_Main:AusKostenstelle');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Hersteller' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung','Rso_Main:AusHersteller');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kundendienst' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung','Rso_Main:AusKundendienst');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kalender' : begin
      if (Rechte[Rgt_Rso_Kalendertage]) then begin
        RecBufClear(163);
        Rso.Kal.Gruppe  # Rso.Gruppe;
        Rso.Kal.Datum   # today;
        Erx # RecRead(163,1,0);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rso.Kal.Verwaltung','',y);
        Erx # RecRead(163,1,_recLast);
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        vQ # '';
        Lib_Sel:QInt(var vQ, 'Rso.Kal.Gruppe', '=', Rso.Gruppe);
        Lib_Sel:QRecList(0, vQ);
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edRso.MEHh,160,1,10);
      $edRso.MEHh->winfocusset(false);
      RefreshIfm('edRso.MEHh');
    end;

  end;

end;


//========================================================================
//  AusGruppe
//
//========================================================================
sub AusGruppe()
begin
  if (gSelected<>0) then begin
    RecRead(822,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Rso.Gruppe # Rso.Grp.Nummer;
  end;
  // Focus setzen:
  $edRso.Gruppe->Winfocusset(false);
//  Refreshifm('edRso.Gruppe');
end;


//========================================================================
//  AusAbteilung
//
//========================================================================
sub AusAbteilung()
begin
  if (gSelected<>0) then begin
    RecRead(821,0,_RecId,gSelected);
    // Feldübernahme
    Rso.Abteilung # Abt.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edRso.Abteilung->Winfocusset(false);
  Refreshifm('edRso.Abteilung');
end;

//========================================================================
//  AusKostenstelle
//
//========================================================================
sub AusKostenstelle()
begin
  if (gSelected<>0) then begin
    RecRead(846,0,_RecId,gSelected);
    // Feldübernahme
    Rso.Kostenstelle # Kst.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edRso.Kostenstelle->Winfocusset(false);
  Refreshifm('edRso.Kostenstelle');
end;


//========================================================================
//  AusHersteller
//
//========================================================================
sub AusHersteller()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Rso.Hersteller # Adr.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edRso.Hersteller->Winfocusset(false);
//  RefreshIfm('edRso.Hersteller');
  Refreshifm('edRso.Hersteller');
end;


//========================================================================
//  AusKundendienst
//
//========================================================================
sub AusKundendienst()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Rso.Kundendienst # Adr.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edRso.Kundendienst->Winfocusset(false);
//  RefreshIfm('edRso.Kundendienst');
  Refreshifm('edRso.Kundendienst');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Reservierungen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.IHA');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Rso_IHA]=n);

  vHdl # gMenu->WinSearch('Mnu.Wartungen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_Rso_Wartungen]=n);


  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Import]=false;
    
  RefreshIfm();
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
  vFilter : int;
  vMode   : alpha;
  vTmp    : int;
  vQ      : alpha(4000);
  Erx     : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.Daten.Tafel' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Tab1.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Reservierungen' : begin
      RecBufClear(170);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Rsv.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      if (gUsername='xxAH') then begin
        vQ # '';
        Lib_Sel:QInt(var vQ, 'Rso.R.Trägernummer1', '=', 1191);
        Lib_Sel:QInt(var vQ, 'Rso.R.Trägernummer1', '=', 1443,'OR');
        vHdl # SelCreate(170, 1);
        Erx # vHdl->SelDefQuery('', vQ);
        if (Erx <> 0) then
          Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
        // Liste selektieren...
        gZLList->wpDbLinkFileNo # 0;
        gZLList->wpDbFileNo     # 170;
        gZLList->wpDbSelection  # vHdl;
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.IHA' : begin
      RecBufClear(165);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Iha.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
/***
      vFilter # RecFilterCreate(165,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,Rso.Gruppe);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq,Rso.Nummer);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq,false);
      gZLList->wpDbFilter # vFilter;
***/
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Rso.IHA.Gruppe', '=', Rso.Gruppe);
      Lib_Sel:QInt(var vQ, 'Rso.IHA.Ressource', '=', Rso.Nummer);
      Lib_Sel:QLogic(var vQ, 'Rso.IHA.WartungYN', false);
      vHdl # SelCreate(165, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);

      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Wartungen' : begin
      RecBufClear(165);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Wrt.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
/***
      vFilter # RecFilterCreate(165,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,Rso.Gruppe);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq,Rso.Nummer);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq,True);
      gZLList->wpDbFilter # vFilter;
***/
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Rso.IHA.Gruppe', '=', Rso.Gruppe);
      Lib_Sel:QInt(var vQ, 'Rso.IHA.Ressource', '=', Rso.Nummer);
      Lib_Sel:QLogic(var vQ, 'Rso.IHA.WartungYN', true);
      vHdl # SelCreate(165, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);

      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Belegung' : begin
//      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Bel.Verwaltung','');
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Bel.Verwaltung_Neu','',y);
      Lib_guicom:ObjSetPos(gMDI,1,1);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Kalender' : begin
      // Kalenderbelegung
      auswahl('Kalender');
    end;


    'Mnu.Druck.PersId' : begin
      Lib_Dokumente:Printform( 160, 'Personal IDs', false );
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Rso.Anlage.Datum, Rso.Anlage.Zeit, Rso.Anlage.User );
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
    'bt.BATyp'  :       Auswahl('BATyp');
    'bt.Gruppe' :       Auswahl('Gruppe');
    'bt.MEH'    :       Auswahl('MEH');
    'bt.Abteilung' :    Auswahl('Abteilung');
    'bt.Kostenstelle' : Auswahl('Kostenstelle');
    'bt.Hersteller' :   Auswahl('Hersteller');
    'bt.Kundendienst' : Auswahl('Kundendienst');
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
  if (mode=c_ModeView) then // 09.06.2022 AH: niemals bei Edit/New!!
    RecRead(gFile,1,0);
  SFX_Chromium:RefreshServiceChromiumNotebookPage(Aint(Rso.Gruppe));
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
end
begin
  Erx # RekLink(821,160,2,_recFirst);   // Abteilung holen
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
  SwitchMask();
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
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edRso.Gruppe);
  Lib_GuiCom:Pflichtfeld($edRso.Nummer);
  Lib_GuiCom:Pflichtfeld($edRso.Abteilung);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edRso.Gruppe') AND (aBuf->Rso.Gruppe<>0)) then begin
    Rso.Grp.Nummer # Rso.Gruppe;
    RecRead(822,1,0);
    Lib_Guicom2:JumpToWindow('Rso.Grp.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRso.Abteilung') AND (aBuf->Rso.Abteilung<>0)) then begin
    RekLink(821,160,2,0);   // Abteilung holen
    Lib_Guicom2:JumpToWindow('Abt.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRso.Kostenstelle') AND (aBuf->Rso.Kostenstelle<>0)) then begin
    RekLink(846,160,9,0);   // Kostenstelle holen
    Lib_Guicom2:JumpToWindow('KsT.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRso.Hersteller') AND (aBuf->Rso.Hersteller<>0)) then begin
    RekLink(100,160,4,0);   // Hersteller holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edRso.Kundendienst') AND (aBuf->Rso.Kundendienst<>0)) then begin
    RekLink(100,160,5,0);   // Kundendienst holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
 
  
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
