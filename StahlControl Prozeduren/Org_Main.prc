@A+
//==== Business-Control ==================================================
//
//  Prozedur    Org_Main
//                OHNE E_R_G
//  Info
//
//
//  10.07.2012  AI  Erstellung der Prozedur
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit
//    SUB EvtPosChanged
//
//    SUB RebuildOrga(aTV : int)
//
//    SUB SetStatus();
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Kontakte

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vTimer  : int;
end;
begin

  RunAFX('HM.Init',aint(aEvt:Obj));   // 12.04.2021 AH

  WinSearchPath(aEvt:Obj);
  winsearchpath(aEvt:Obj);

  if (Set.Org.IdleInterval<>0) then begin
    Org_Data:RebuildOrga($tv.Organigramm);
    Org_Data:UpdateOrga($tv.Organigramm);
    vTimer # SysTimerCreate(5000, -1, aEvt:obj);    // 5 Sekunde
    $gt.Organigramm->wpcustom # aint(vTimer);
  end;

  App_Main:EvtInit(aEvt);
end;


//=========================================================================
//=========================================================================
sub EvtTimer(
  aEvt                 : event;    // Ereignis
  aTimerID             : int;      // Timer-ID
) : logic;
begin
  Org_Data:UpdateOrga($tv.Organigramm);
  RETURN(true);
end;


//=========================================================================
//=========================================================================
sub EvtTerm(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vTimer  : int;
end;
begin

  vTimer # cnvia($gt.Organigramm->wpcustom);
  if (vTimer<>0) then begin
    SysTimerClose(vTimer);
    vTimer # 0;
  end;

  RETURN App_Main:EvtTerm(aEvt);
end;


//=========================================================================
//=========================================================================
sub EvtMenuInitPopup(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüeintrag
) : logic;
local begin
  vMenu : int;
  vItem : int;
end;
begin

  // Kontext - Menü
  if (aMenuItem=0) then begin
    // Ermitteln des Kontextmenüs des Frame-Objektes.
    vMenu # aEvt:Obj->WinInfo(_WinContextMenu);
    if (vMenu > 0) then begin
      vMenu # Winsearch(vMenu,'Mnu.Ktx.WOF');

      if (StrFind(Set.Module,'W',0)=0) or
        (Rechte[Rgt_Workflow_Schema]=false) then
        vMenu->wpDisabled # y;

      // Kontextmenü erweitern MUSTER
//      vItem # vMenu->WinMenuItemAdd('Mnu.Ktx.WOF','1000',1);
    end;
  end;

  RETURN(true);
end;


//=========================================================================
//  EvtMenuCommand
//
//=========================================================================
sub EvtMenuCommand(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüpunkt / Toolbar-Button
) : logic;
local begin
  Erx   : int;
  vItem : int;
  v800  : int;
  vA    : alpha(250);
  vQ    : alpha(1000);
  vHdl  : int;
end;
begin

  case (aMenuItem->wpname) of

    'Mnu.Ktx.Email' : begin
      vItem # aEvt:obj->wpcurrentint;
      if (vItem<>0) then begin
        v800 # RecBufCreate(800);
        v800->Usr.Username # vItem->wpname;
        Erx # RecRead(v800,1,0);
        if (erx<=_rLocked) then begin
//          vA # Adr_Ktd_data:ReadUserData(v800->Usr.Username,c_KTD_Email);
          sysExecute('*mailto:'+v800->Usr.Email,'',0)
        end;
        RecBufDeStroy(v800);
      end;
    end;


    'Mnu.Ktx.TAPI' : begin
      vItem # aEvt:obj->wpcurrentint;
      if (vItem<>0) then begin
        v800 # RecBufCreate(800);
        v800->Usr.Username # vItem->wpname;
        Erx # RecRead(v800,1,0);
        if (erx<=_rLocked) then begin
          vA # Adr_Ktd_data:ReadUserData(v800->Usr.Username,c_KTD_Typ_tel, c_KTD_intern);
          if (vA<>'') then begin
            if (gTAPIDev<>0) then
              Lib_Tapi:TapiDialNumber(vA)
            else
              Msg(99,Translate(c_KTD_intern)+': '+vA,0,0,0);
          end;
        end;
        RecBufDeStroy(v800);
      end;
    end;


    'Mnu.Ktx.Aktivitaet' : begin
      vItem # aEvt:obj->wpcurrentint;
      if (vItem=0) then RETURN false;

      v800 # RekSave(800);
      RecBufClear(980);
      Tem2_Main:RecInit();
      // Add selected User to TEM
      Usr.Username # vItem->wpname;
      Erx # RecRead(800,1,0);
      if (Erx>_rLocked) then begin
        RekRestore(v800);
        RETURN true;
      end;

      //TeM_A_Data:New(800,'MAN');
      TeM_A_Data:Anker(800,'MAN');
      RekRestore(v800);

      TeM.Start.Von.Datum # today;
      TeM.Start.Von.Zeit  # now;
      TeM.Ende.Von.Datum # 0.0.0;
      TeM.Ende.Von.Zeit  # 24:0;
      TeM.SichtbarPlanerYN # y;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TeM.Maske','');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_ModeNew;
      Lib_GuiCom:RunChildWindow(gMDI,gFrmMain, _WinAddHidden);
      gMdi->WinUpdate(_WinUpdOn);
    end;


    'Mnu.Ktx.WOF' : begin
      vItem # aEvt:obj->wpcurrentint;
      if (vItem=0) then RETURN false;

      v800 # RecBufCreate(800);
      v800->Usr.Username # vItem->wpname;
      Erx # RecRead(v800,1,0);
      RecBufDeStroy(v800);
      if (erx<=_rLocked) then begin
//        Lib_Workflow:Trigger(0,1000, '', vItem->wpname);
//        Msg(999998,'',0,0,0);
        RecBufClear(940);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'WoF.Sch.Verwaltung', here+':AusWOF', n,n,'',vItem->wpname);

        // Selektion aufbauen...
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        vQ # '';
        Lib_Sel:QInt(var vQ, 'WoF.Sch.Datei'  , '=', 0);
        vHdl # SelCreate(940, gKey);
        Erx # vHdl->SelDefQuery('', vQ);
        if (Erx != 0) then Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;

        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;

  end;

  RETURN(true);
end;


//========================================================================
//  AusWOF
//
//========================================================================
sub AusWOF(opt aPara : alpha);
begin

  if (gSelected=0) then RETURN;

  RecRead(940,0,_RecId,gSelected);
  gSelected # 0;

  // neuen Workflow starten
  Lib_Workflow:Trigger(WoF.Sch.DAtei, WoF.Sch.Nummer, '', aPara);

  Msg(999998,'',0,0,0);

end;


//========================================================================
//========================================================================
SUB SetUserStatus();
local begin
  vDlg  : int;
  vI    : int;
  vHdl  : int;
  vA    : alpha;
end;
begin
  vDlg # WinOpen('Usr.Status.Auswahl',_WinOpenDialog);
//  vDlg # WinDialog('Usr.Status.Auswahl',_WinDialogCenter,gMDI);
  vI # vDlg->WinDialogRun();
  if (vI=_winidok) then begin
    vHdl # winsearch(vDlg, 'rbFrei');
    if (vHdl->wpCheckState=_WinStateChkChecked) then vA # '';
    vHdl # winsearch(vDlg, 'rbHome');
    if (vHdl->wpCheckState=_WinStateChkChecked) then vA # Translate('im Home-Office');
    vHdl # winsearch(vDlg, 'rbTelefon');
    if (vHdl->wpCheckState=_WinStateChkChecked) then vA # Translate('telefoniert');
    vHdl # winsearch(vDlg, 'rbMeeting');
    if (vHdl->wpCheckState=_WinStateChkChecked) then vA # Translate('im Meeting');
    vHdl # winsearch(vDlg, 'rbBusy');
    if (vHdl->wpCheckState=_WinStateChkChecked) then vA # Translate('nicht stören');
    vHdl # winsearch(vDlg, 'rbBusy');
    if (vHdl->wpCheckState=_WinStateChkChecked) then vA # Translate('nicht stören');
    vHdl # winsearch(vDlg, 'rbSonstiges');
    if (vHdl->wpCheckState=_WinStateChkChecked) then begin
      vHdl # winsearch(vDlg, 'edSonstiges');
      vA # vHdl->wpCaption;
    end;

    Org_Data:SetUserStatus(vA);
  end;
  vDlg->winclose();
  
end;

//========================================================================
//========================================================================