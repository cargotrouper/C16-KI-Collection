@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lfm_Main
//                        OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  07.01.2015  ST  Excelexport und - import freigeschaltet
//  12.05.2022  AH  ERX
//  25.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB Auswahl(aBereich : alpha)
//    SUB AuswahlExit()
//    SUB RefreshIfm(optaName : alpha)
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtMouseitem(aevt : event; aButton : int; aHittest : int; aItem : int; aId : int) : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB UsA_EvtMdiActivate(aEvt : event) : logic
//    SUB evtlstselect(aevt : event; arecid : int) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global

define begin
  cTitle :    'Listenformate'
  cFile :     910
  cMenuName : 'Lfm.Bearbeiten'
  cPrefix :   'Lfm'
  cZList :    $ZL.Listen
  cKey :      1
end

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

  w_NoClrView # y;
  w_NoClrList # y;

Lib_Guicom2:Underline($edLfm.Prozedur);

  SetStdAusFeld('edLfm.File'          ,'File');
  SetStdAusFeld('edLfm.Prozedur'      ,'Prozedur');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
  // Felder Disablen durch:
  // Focus setzen auf Feld:
  if (Mode=c_ModeNew) then begin

    Lfm.NeuYN # y;
    if (App_Main:Entwicklerversion()) then begin
      Lfm.InaktivYN # y;
      Lfm.NeuYN     # n;
    end;
  end;

  $edLfm.Nummer->WinFocusSet(true);
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
    TRANSON;

    // Wenn der Key geändert wurde, dann soll auch in alle APL Positionen der Key geändert sein
    if (Lfm.Nummer <> ProtokollBuffer[910]->Lfm.Nummer) or
     (Lfm.Kuerzel <> ProtokollBuffer[910]->Lfm.Kuerzel) then begin
      Erx # RecLink(911,ProtokollBuffer[910],1,_RecFirst | _recLock)
      WHILE (Erx<= _rLocked) do begin
        Lfm.Usr.Kuerzel # Lfm.Kuerzel;
        Lfm.Usr.Nummer  # Lfm.Nummer;
        Erx # RekReplace(911, _recUnlock, 'AUTO');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN False;
        end;
        Erx # RecLink(911,ProtokollBuffer[910],1, _RecFirst | _recLock);
      END;
    end;

    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TRANSOFF;

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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  Erx # RekDelete(gFile,0,'MAN');
  if (Erx=_rOK) then begin
    Erx # RecLink(911,910,1,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      RekDelete(911,0,'AUTO');
      Erx # RecLink(911,910,1,_RecNext);
    END;
  end;

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
end;

begin

  case aBereich of

    'Prozedur' : begin
      vA # Prg_Para_Main:ParaAuswahl('Prozeduren','L_','L_zzz');
//      vA # Prg_Para_Main:ParaAuswahl('TAPI','','ZZZ');
      if (vA<>'') then Lfm.Prozedur # vA;
      $edLfm.Prozedur->WinFocusSet();
      gMdi->WinUpdate();
    end;

    'File' : begin
      vA # Prg_Para_Main:ParaAuswahl('Dateien','','');
      if (vA<>'') then Lfm.File # CnvIA(Strcut(vA,1,3));
      $edLfm.File->WinFocusSet();
      gMdi->WinUpdate();
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
//  $ZL.Lfm.User->wpdisabled # false;
//  Lib_GuiCom:SetWindowState($Lfm.User,true);

  if (gSelected<>0) then begin
    RecRead(800,0,0,gSelected);
    gSelected # 0;
    Lfm.Usr.Kuerzel   # Lfm.Kuerzel;
    Lfm.Usr.Nummer    # Lfm.Nummer;
    Lfm.Usr.Username  # Usr.Username;
    Erx # RekInsert(911,0,'MAN');
    If Erx<>_rOk then begin
      //Zuweisung existiert bereits!
      Msg(911002,'',_WinIcoError,_WinDialogOkCancel,1);
    end;
  end;
  Usr_data:RecReadThisUser();

  $ZL.Lfm.User->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $ZL.Lfm.User->WinFocusSet(y);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
begin

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  d_MenuItem # gMenu->WinSearch('Lfm.User');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Lfm.EinzelrechtYN=false));

  d_MenuItem # gMenu->WinSearch('Mnu.Daten.Export');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled # false;
  d_MenuItem # gMenu->WinSearch('Mnu.Excel.Import');
  if (d_MenuItem <> 0) then
    d_MenuItem->wpDisabled # false;


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

    'Lfm.User' : begin
//        RecRead(910,0, 0,gZLList->wpDbRecId);
        // Clientwindow starten
//        gMdi # WinAddByName(gFrmMain,'Lfm.User', _WinAddHidden);
        gMDI # Lib_GuiCom:AddChildWindow(gMdi,'Lfm.User','');
        Lib_GuiCom:RunChildWindow(gMDI);
//        gMdi->WinUpdate(_WinUpdOn);

      end;


    'Mnu.Mark.SetField' : begin
      Lib_Mark:SetField(gFile);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;


    'Usr.Cancel' : begin
      $Lfm.User->winclose();
    end;


    'Usr.Insert' : begin
//      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Auswahl',here+':AuswahlExit');
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AuswahlExit');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Usr.Delete' : begin
      //Zuweisung aufheben?
      if (Msg(911003,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
        RekDelete(911,0,'MAN');
      end;
      $ZL.Lfm.User->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
      $ZL.Lfm.User->WinFocusSet(y);
    end;
  end;

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
    'bt.Prozedur' :   Auswahl('Prozedur');

    'bt.File' :       Auswahl('File');

    'Usr.Insert' : begin
      EvtMenuCommand(null,aEvt:Obj);
    end;

    'Usr.Delete' : begin
      EvtMenuCommand(null,aEvt:Obj);
    end;

  end;

end;

//=====================================================================
sub EvtMouseitem (
                             aevt      : event;
                             aButton   :  int;
                             aHittest  : int;
                             aItem     : int;
                             aId       : int;
                 ) : logic
begin
   case (aevt:obj -> wpname ) of
   'ZL.Lfm.User' : begin

      if (ahittest = _winlstheader) then
      begin
         if (abutton = _winmouseleft ) then
         begin

            aevt:obj -> winupdate(_winupdon,_winlstfromfirst | _winlstrecdoselect);
         end
      end;
   end
   end;

   return(true);
end

//========================================================================
//  FocusInit
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
  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;

//========================================================================
//  UsA_EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub UsA_EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  gTitle  # 'User';
  gPrefix # 'Lfm';
  gFrmMain->wpMenuname # 'Lfm.User';
  gZLList # 0;
  Call('App_Main:EvtMdiActivate',aEvt);
end;
//===================================================================
sub evtlstselect( aevt : event; arecid : int) : logic
local begin
   d_menuitem : int;
end;
begin
   case aevt:obj -> wpname of
   'ZL.Listen' : begin
      recread(910,0,_recid,arecid);
      GV.Int.15 # lfm.nummer;
       gMenu # gFrmMain->WinInfo(_WinMenu);

       d_MenuItem # gMenu->WinSearch('Lfm.User');
     if (d_MenuItem <> 0) then
       d_MenuItem->wpDisabled #
         ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Lfm.EinzelrechtYN=false));

    end;
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
 //  Refreshmode();
  gv.int.17 # reclinkinfo(911,910,1,_reccount);
  if (aMark=n) then begin
    if (Lfm.InaktivYN) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
  end;

end;


//========================================================================
// UsA_EvtClose
//          Schliessen eines Fensters
//========================================================================
sub UsA_EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  Mode # c_ModeCancel;
  RETURN APP_Main:EvtClose(aEvt);
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

sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edLfm.Prozedur') AND (aBuf->Lfm.Prozedur<>'')) then begin
    todo('Prozedur')
    //RekLink(819,200,1,0);   // prozedur holen
    Lib_Guicom2:JumpToWindow('');
    RETURN;
  end;

end;
//========================================================================
//========================================================================
//========================================================================
//========================================================================