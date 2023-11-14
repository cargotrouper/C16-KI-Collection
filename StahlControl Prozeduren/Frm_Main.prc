@A+
//==== Business-Control ==================================================
//
//  Prozedur    Frm_Main
//                      OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  30.10.2018  AH  Zusatztext
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    sub EvtInit(aEvt  : event): logic
//    sub RefreshIfm (aName : alpha);
//    sub RecInit()
//    sub RecSave() : logic
//    sub RecCleanup() : logic
//    sub RecDel()
//    sub Auswahl(aBereich : alpha;)
//    sub EvtMdiActivate (aEvt : Event) : logic;
//    sub EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    sub AuswahlExit()
//    sub RefreshMode(opt aNoRefresh:logic )
//    sub EvtClicked (aEvt : event;) : logic
//    sub EvtFocusInit (aEvt : event; aFocusObject : int) : logic
//    sub EvtLstDataInit(aEvt : Event; aRecId : int;);
//    sub EvtLstSelect(aEvt : event; aRecID : int;) : logic
//    sub EvtClose(aEvt : event;): logic
//
//========================================================================
@I:Def_Global

define begin
  cTitle :    'Formulare'
  cFile :     912
  cMenuName : 'Frm.Bearbeiten'
  cPrefix :   'Frm'
  cZList :    $ZL.Formulare
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
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  w_NoClrView # y;

  SetStdAusFeld('edFrm.Bereich'   ,'File');
  SetStdAusFeld('edFrm.Prozedur'  ,'Prozedur');
  SetStdAusFeld('edFrm.Style'     ,'Style');
  SetStdAusFeld('edFrm.Drucker'   ,'Drucker');
  SetStdAusFeld('edFrm.Schacht'   ,'Schacht');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
begin
  Lib_Guicom:Able($bt.Text, Mode=c_modeView);
  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Actionabwicklung
//========================================================================
sub RecInit()
begin
  $edFrm.Bereich->WinFocusSet(true);
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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  TxtDelete('~912.'+CnvAI(RecInfo(912,_RecID),_FmtNumLeadZero | _FmtNumNoGroup,0,8), 0);
  RekDelete(gFile,0,'MAN');
end;


//========================================================================
//  Auswahl
//          Auswahlisten öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  vA    : alpha;
  vHdl  : int;
end;
begin

  case aBereich of

    'Style' : begin
      vA # Prg_Para_Main:ParaAuswahl('Formulare','Style','Stylf');
      if vA<>'' then Frm.Style # vA;
      $edFrm.Style->WinFocusSet();
      gMdi->WinUpdate();
    end;

    'Prozedur' : begin
      vA # Prg_Para_Main:ParaAuswahl('Prozeduren','F_','F_zzz');
      if vA<>'' then Frm.Prozedur # vA;
      $edFrm.Prozedur->WinFocusSet();
      gMdi->WinUpdate();
    end;

    'File' : begin
      vA # Prg_Para_Main:ParaAuswahl('Dateien','','');
      if vA<>'' then Frm.Bereich # CnvIA(Strcut(vA,1,3));
      $edFrm.Bereich->WinFocusSet();
      gMdi->WinUpdate();
    end;

    'Drucker' : begin
      vA # Prg_Para_Main:ParaAuswahl('Drucker','','');
      if vA<>'' then Frm.Drucker # vA;
      $edFrm.Drucker->WinFocusSet();
      gMdi->WinUpdate();
    end;

    'Schacht' : begin
      vHdl # PrtDeviceOpen(Frm.Drucker,_PrtDeviceSystem);
      if (vHdl<>0) then begin
        vA # Prg_Para_Main:ParaAuswahl('Schächte','','',vHdl);
        if (vA<>'') then Frm.Schacht # vA;
        $edFrm.Schacht->WinFocusSet();
        gMdi->WinUpdate();
      end;
    end;

  end;
end;


//========================================================================
//  MenuCommand
//              Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vMode : alpha;
  vA    : alpha(250);
  vParent : int;
  vTmp  : int;
  vHdl  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of
    'Listen' : begin
      Lfm_Ausgabe:Auswahl('Formulare');
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;
  end;

end;


//========================================================================
//  AuswahlExit
//
//========================================================================
sub AuswahlExit()
local begin
  Erx : int;
end;
begin
  $ZL.Usr.Gruppen->wpdisabled # false;
  Lib_GuiCom:SetWindowState($Usr.Gruppen,true);

  if (gSelected<>0) then begin
    RecRead(801,0,0,gSelected);
    gSelected # 0;
    "Usr.U<>G.User"   # Usr.Username;
    "Usr.U<>G.Gruppe" # Usr.Grp.Gruppenname;
    Erx # RekInsert(802,0,'MAN');
    If Erx<>_rOk then begin
      //Zuweisung existiert bereits
      Msg(802001,'',_WinIcoError,_WinDialogOkCancel,1);
    end;
  end;

  $ZL.Usr.Gruppen->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $ZL.Usr.Gruppen->WinFocusSet(y);
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

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;

  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;


  // Button & Menßs sperren
  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vParent : int;
end;
begin
  case (aEvt:Obj->wpName) of
    'bt.Text' : begin   // 30.10.2018 AH
      if (Mode=c_ModeView) then begin
        Mdi_TXTEditor_Main:Start('~912.'+CnvAI(RecInfo(912,_RecID),_FmtNumLeadZero | _FmtNumNoGroup,0,8), y, aint(Frm.Bereich)+'/'+Frm.Name);
      end;
    end;

    'bt.Prozedur' :   Auswahl('Prozedur');
    'bt.Style'    :   Auswahl('Style');
    'bt.File' :       Auswahl('File');
    'bt.Drucker' :    Auswahl('Drucker');
    'bt.Schacht' :    Auswahl('Schacht');
  end;
end;


//========================================================================
//  FocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin
  if  (aEvt:Obj->wpname='edFrm.Bereich')  or
      (aEvt:Obj->wpname='edFrm.Prozedur') or
      (aEvt:Obj->wpname='edFrm.Style') or
      (aEvt:Obj->wpname='edFrm.Schacht') or
    (aEvt:Obj->wpName='edFrm.Drucker')  then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);
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
//                Datensatz in ZL gewählt
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecId                : int;          // REcord-ID) : logic
) : logic
begin
  RecRead(912,0, 0,gZLList->wpDbRecId);
  RETURN true;
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