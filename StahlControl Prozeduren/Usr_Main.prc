@A+
//==== Business-Control ==================================================
//
//  Prozedur    Usr_Main
//                        OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  25.02.2013  AI  "EvtLstRecControl"
//  30.06.2014  AH  "RecSave" fragt Hauptbenutzer ab
//  07.12.2017  AH  Erweiterung für Webuser
//  25.01.2018  ST  Erweiterung: Passwort setzen
//  09.10.2018  AH  Fix: Neuanlage behielt Typ
//  12.11.2021  AH  ERX
//  2023-02-08  AH  der ADMIN kann Username editieren
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB AuswahlExit()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstSelect(aEvt : event; aRecId : int) : logic
//    SUB EvtLstRecControl(
//    SUB Grp_RL_Ctrl(aEvt : event; aRecId : int) : logic
//    SUB Grp_EvtMdiActivate(aEvt : event) : logic
//    SUB GrP_EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB Auswahl_EvtMdiActivate(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Kontakte

define begin
  cTitle :    'User'
  cFile :     800
  cMenuName : 'Usr.Bearbeiten'
  cPrefix :   'Usr'
  cZList :    $ZL.User
  cKey :      1
  cListen : 'User'
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
  w_Listen  # cListen;

  // Auswahlfelder setzen...
  //SetStdAusFeld(

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//========================================================================
sub BestimmeTyp()
begin
  if ($cbTyp.Normal->wpCheckState=_WinStateChkChecked) then
    Usr.Typ # 'N'
  else if ($cbTyp.Betrieb->wpCheckState=_WinStateChkChecked) then
    Usr.Typ # 'B'
  else if ($cbTyp.Web->wpCheckState=_WinStateChkChecked) then
    Usr.Typ # 'W'
  else if ($cbTyp.System->wpCheckState=_WinStateChkChecked) then
    Usr.Typ # 'S';
end;


//========================================================================
//========================================================================
sub ZeigeTyp()
local begin
  vA  : alpha;
  Erx : int;
end;
begin
  Lib_GuiCom2:SetCheckBox($cbTyp.Normal, Usr.Typ='N');
  Lib_GuiCom2:SetCheckBox($cbTyp.Betrieb, Usr.Typ='B');
  Lib_GuiCom2:SetCheckBox($cbTyp.System, Usr.Typ='S');
  Lib_GuiCom2:SetCheckBox($cbTyp.Web, Usr.Typ='W');

  Lib_GuiCom:Able($bt.WebDatensatz, (Usr.Typ='W') and ((Mode=c_ModeEdit) or (Mode=c_ModeNew)));
  Lib_GuiCom:Able($bt.WebPasswort, (Usr.Typ='W') and (Mode=c_ModeView));
  Lib_GuiCom:Able($bt.WebPasswortSet, (Usr.Typ='W') and (Mode=c_ModeView));

  vA # '';
  if (Usr.ZuDatei=100) then begin
    Adr.Nummer # Usr.ZuNummer1;
    Erx # RecRead(100,1,0);
    if (Erx<=_rLocked) then
      vA # 'Adresse '+Adr.Stichwort;
  end
  else if (Usr.ZuDatei=102) then begin
    Adr.P.ADressNr  # Usr.ZuNummer1;
    Adr.P.Nummer    # Usr.ZuNummer2;
    Erx # RecRead(102,1,0);
    if (Erx<=_rLocked) then begin
      vA # 'Ansprechpartner '+Adr.P.Stichwort+' bei ';
      Adr.Nummer # Usr.ZuNummer1;
      Erx # RecRead(100,1,0);
      vA # vA + Adr.Stichwort;
    end;
  end

  $lb.WebDatensatz->wpCaption # vA;
end;

/*========================================================================
2023-02-08  AH
========================================================================*/
sub CreateC16User(
  aUser     : alpha;
  aHaupt    : alpha;
  aIniUser  : alpha;
) : logic
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  // Feste Vorbelegung der Benutzergruppe USER,
  // andere Gruppentypen (Programmierer, Admin, etc) werden weiterhin
  // über die C16 User verwaltet
//      Erx # UserCreate(Usr.Username,vHauptuser,StrCnv(Usr.Username,_strlower))
  Erx # UrmCreate(0, _UrmTypeUser, aUser);
  if (Erx <> _ErrOK) then RETURN false;
  winsleep(100);
  Erx # UserPassword(aUser,'',StrCnv(aUser,_strlower));
  if (Erx <> _ErrOK) then RETURN false;
  winsleep(100);
  vTMP # UrmOpen(_UrmTypeUser,_UrmLock,aUser);
  // Hauptbenutzer setzen...
  vTMP->UrmPropSet(_UrmPropUserGroup,aHaupt);// ,'LastLogin',_TypeDate);
  // Diesen Benuter der Gruppe Sales zuordnen
  Erx # vTMP->UrmCreate(_UrmTypeMember,'_Everyone');
  vTMP->UrmClose();

  //TxtCopy('INI.USER','INI.'+Usr.Username,0);
  TxtCopy('INI.'+aIniUSER,'INI.'+aUser,0);
  RETURN true;
end;


/*========================================================================
2023-02-08  AH
========================================================================*/
sub _ChangeUsernameInner(
  aAlt  : alpha;
  aNeu  : alpha) : alpha;
local begin
  Erx : int;
end;
begin
  // 801
  FOR  Erx # RecLink( 802, 800, 1, _recFirst | _recLock );
  LOOP Erx # RecLink( 802, 800, 1, _recFirst | _recLock );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    "Usr.U<>G.User" # aNeu;
    if ( RekReplace( 802, _recUnlock,'AUTO') != _rOk ) then
      RETURN 'Usergruppen';
  END;
  if (Erx=_rDeadLock) then RETURN 'Usergruppen';

  // 802
  FOR  Erx # RecLink( 107, 800, 2, _recFirst | _recLock );
  LOOP Erx # RecLink( 107, 800, 2, _recFirst | _recLock );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    Adr.Ktd.ZuUser # aNeu;
    if ( RekReplace( 107, _recUnlock,'AUTO') != _rOk ) then
      RETURN 'Userkontakt';
  END;
  if (Erx=_rDeadLock) then RETURN 'Userkontakt';

  // 805
  FOR  Erx # RecLink( 805, 800, 3, _recFirst | _recLock );
  LOOP Erx # RecLink( 805, 800, 3, _recFirst | _recLock );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    Usr.Z.User # aNeu;
    if ( RekReplace( 805, _recUnlock,'AUTO') != _rOk ) then
      RETURN 'Userzeiten';
  END;
  if (Erx=_rDeadLock) then RETURN 'Userzeiten';

  if (Lib_rec:LoopDataAndReplaceAlpha(100, 'Adr.Sachbearbeiter', aAlt, 'Adr.Sachbearbeiter' , aNeu) = false) then RETURN 'Adresse';
  if (Lib_Rec:LoopDataAndReplaceAlpha(130, 'Ver.Sachbearbeiter', aAlt, 'Ver.Sachbearbeiter' , aNeu) = false) then RETURN 'Vertreter';
  if (Lib_Rec:LoopDataAndReplaceAlpha(400, 'Auf.Sachbearbeiter', aAlt, 'Auf.Sachbearbeiter' , aNeu) = false) then RETURN 'Auftrag';
  if (Lib_Rec:LoopDataAndReplaceAlpha(500, 'Ein.Sachbearbeiter', aAlt, 'Ein.Sachbearbeiter' , aNeu) = false) then RETURN 'Bestellung';
  if (Lib_Rec:LoopDataAndReplaceAlpha(410, 'Auf~Sachbearbeiter', aAlt, 'Auf~Sachbearbeiter' , aNeu) = false) then RETURN 'Auftragsablage';
  if (Lib_Rec:LoopDataAndReplaceAlpha(510, 'Ein~Sachbearbeiter', aAlt, 'Ein~Sachbearbeiter' , aNeu) = false) then RETURN 'Bestellungsablage';
  if (Lib_Rec:LoopDataAndReplaceAlpha(300, 'Rek.Sachbearbeiter', aAlt, 'Rek.Sachbearbeiter' , aNeu) = false) then RETURN 'Reklamation';

  if (Lib_Rec:LoopDataAndReplaceAlpha(911, 'Lfm.Usr.Username', aAlt, 'Lfm.Usr.Username' , aNeu) = false) then RETURN 'Listenformat';
  if (Lib_Rec:LoopDataAndReplaceAlpha(120, 'Prj.Projektleiter', aAlt, 'Prj.Projektleiter' , aNeu) = false) then RETURN 'Projekt';
  if (Lib_Rec:LoopDataAndReplaceAlpha(981, 'TeM.A.Code', aAlt, 'TeM.A.Code' , aNeu) = false) then RETURN 'Terminanker';
  if (Lib_Rec:LoopDataAndReplaceAlpha(941, 'WoF.Akt.anUser1', aAlt, 'WoF.Akt.anUser1' , aNeu) = false) then RETURN 'Workflow1';
  if (Lib_Rec:LoopDataAndReplaceAlpha(941, 'WoF.Akt.anUser2', aAlt, 'WoF.Akt.anUser2' , aNeu) = false) then RETURN 'Workflow2';
  if (Lib_Rec:LoopDataAndReplaceAlpha(941, 'WoF.Akt.anUser3', aAlt, 'WoF.Akt.anUser3' , aNeu) = false) then RETURN 'Workflow3';

  RETURN '';
end;


/*========================================================================
2023-02-08  AH
========================================================================*/
sub ChangeUserName() : logic;
local begin
  Erx         : int;
  vNeu,vAlt   : alpha;
  vHauptuser  : alpha;
  vErr        : alpha;
end;
begin
  vNeu # Usr.Username;
  vAlt # vNeu;
  if (Dlg_Standard:Standard(Translate('Username'), var vNeu, n, 16)=false) then RETURN false;
  vNeu # StrCnv(vNeu,_Strupper);
  if (vAlt=^vNeu) then RETURN true;

  if (Usr.Typ='N') then vHauptuser # 'USER';
  if (Usr.Typ='B') then vHauptuser # 'BETRIEB';

  if (vHauptuser<>'') then begin
    if (Msg(800007, StrCnv(vNeu,_strlower),_Winicowarning, _WinDialogYesNo,2)<>_winidyes) then RETURN false;
  end;
  
  TRANSON;

  Usr.UserName # vAlt;
  RecRead(800,1,_recLock);
  Usr.Username # vNeu;
  RekReplace(800);

  vErr # _ChangeUsernameInner(vAlt, vNeu);
  if (vErr<>'') then begin
    TRANSBRK;
    Msg(999999,vErr+' konnte nicht gespeichert werden!',0,0,0);
    RETURN false;
  end;

  if (vHauptuser<>'') then begin
    if (CreateC16User(vNeu, vHauptuser, vAlt)=false) then begin
      TRANSBRK;
      Msg(99,'Usercreation failed!',0,0,0);
      RETURN False;
    end;
    Erx # UrmDelete(0, _UrmTypeUser, vAlt);
    if (erx<>_ErrOK) then begin
      TRANSBRK;
      Msg(99,'Userdelete failed!',0,0,0);
      RETURN False;
    end;
  end;

  TRANSOFF;
  
  Msg(999998,'',0,0,0);
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
  Lib_GuiCom:Pflichtfeld($edUsr.Username);
  if (Usr.Typ='W') then
    Lib_GuiCom:Pflichtfeld($edUsr.eMail);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vTmp  : int;
end;
begin

  if (Mode=c_ModeVIew) then
    ZeigeTyp();


  if ( aName = 'Tapi' or aName = '' ) and ( Mode = c_ModeEdit or Mode = c_ModeEdit2 or Mode = c_ModeNew or Mode = c_ModeNew2) then begin
    if ( Usr.TapiYN ) then begin
      Lib_GuiCom:Enable( $cbUsr.TapiIncPopUpYN );
      Lib_GuiCom:Enable( $cbUsr.TapiIncMsgYN );
    end
    else begin
      Lib_GuiCom:Disable( $cbUsr.TapiIncPopUpYN );
      Lib_GuiCom:Disable( $cbUsr.TapiIncMsgYN );
    end;
  end;

  if ( aName = 'Outlook' or aName = '' ) and ( Mode = c_ModeEdit or Mode = c_ModeEdit2 or Mode = c_ModeNew or Mode = c_ModeNew2) then begin
    if ( Usr.OutlookYN ) then
      Lib_GuiCom:Enable( $bt.OutlookKalender );
    else
      Lib_GuiCom:Disable( $bt.OutlookKalender );
  end;

  if (aName='') and (mode=c_modeview) then begin
    Adr_Ktd_Data:FillUserDL($dl.Kontakte);  // ORGA
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
//
//========================================================================
sub RecInit()
begin

  if Mode=c_ModeEdit then begin
    Lib_GuiCom:Disable($edUsr.Username);
    $edUsr.Anrede->WinFocusSet(true);
  end
  else begin
    Adr_Ktd_Data:FillUserDL($dl.Kontakte);
    $edUsr.Username->WinFocusSet(true);
  end;
  
  ZeigeTyp();

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vTmp        : int;
  vHauptUser  : alpha;
  v800        : int;
  Erx         : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  BestimmeTyp();

  if (Usr.UserName='') then begin
    Lib_Guicom2:InhaltFehlt('Username', 'NB.Page1', 'edUsr.Username');
    RETURN false;
  end;

  if (Usr.Typ='') then begin
    Lib_Guicom2:InhaltFehlt('Typ', 'NB.Page1', 'cbTyp.Normal');
    RETURN false;
  end;
  if (Usr.Typ='W') then begin
    if (Usr.EMail='') then begin
      Lib_Guicom2:InhaltFehlt('eMail-Adresse', 'NB.Page1', 'edTyp.eMail');
      RETURN false;
    end;
    if (Usr.ZuDatei=0) then begin
      Lib_Guicom2:InhaltFehlt('Datensatz', 'NB.Page1', 'cbTyp.Web');
      RETURN false;
    end;
  end;

  // 25.08.2020 AH:
  if (Usr.VertretungUser<>'') then begin
    v800 # RecBufCreate(800);
    v800->Usr.Username # Usr.VertretungUser;
    Erx # RecRead(v800,1,0);
    if (Erx<>_rOK) then begin
      RecBufDestroy(v800);
      Msg(800005,Usr.VertretungUser,0,0,0);
      RETURN false;
    end;
    if (v800->Usr.VertretungUser<>'') then begin
      Msg(800006,v800->Usr.Username+'|'+v800->Usr.VertretungUser,0,0,0);
      RecBufDestroy(v800);
    end;
  end;


  if ( GV.Alpha.40 != Usr.OutlookCalendar ) then begin // BUG. Variable zurückschreiben
    //debug( GV.Alpha.40 );
    //debug( Usr.OutlookCalendar );
    Usr.OutlookCalendar # GV.Alpha.40;
    GV.Alpha.40         # '';
  end;


//  vHauptuser # 'USER';
//  if (Mode=c_ModeNew) then begin
//    if (Msg(99,'Betriebsuser?',_WinIcoQuestion,_WinDialogYesNo,2)=_WinidYes) then vHauptUser # 'BETRIEB';
//  end;

  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Usr.Typ='N') then vHauptuser # 'USER';
  if (Usr.Typ='B') then vHauptuser # 'BETRIEB';
  if (Usr.Typ='W') then vHauptuser # 'WEB'; // FIX: 2024-09-06 MK ändern von MDE nicht möglich

  if (vHauptuser='') then
    Msg(99,'Systemuser müssen ZUSÄTZLICH vom Superuser in der C16-Datenbank angepasst werden!',0,0,0)


  if (Mode=c_ModeEdit) then begin
    TRANSON;

    Erx # RekReplace(gFile,_RecUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    PtD_Main:Compare(gFile);
  end
  else begin

    TRANSON;

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    // C16 User Anlegen
    if (vHauptUser<>'') then begin
      if (CreateC16User(Usr.Username, vHauptuser, 'USER')=false) then begin
        TRANSBRK;
        Msg(99,'Usercreation failed!',0,0,0);
        RETURN False;
      end;
    end;
  end;

  Adr_Ktd_Data:DeleteUser();    // 2022-08-22 AH

  Adr_Ktd_Data:UpdateFromUser($dl.Kontakte);  // ORGA

  TRANSOFF;

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
  vName     : alpha;
  Erx       : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    // Gruppenzugehörigkeit löschen
    WHILE (RecLink(802,800,1,_recFirsT)<=_RLocked) do
      RekDelete(802,0,'MAN');

    vName # 'INI.'+Usr.Username;
    Txtdelete(vName,0);
    RekDelete(gFile,0,'MAN');

    // C16 User und Ini-File löschen
    Erx # BinDirDelete(0,'Selektionen\'+Usr.Username,_BinDeleteAll);
    if (Usr.Typ<>'W') then begin
      Erx # UserDelete(Usr.Username);
      If (Erx <> _rOK) then begin
        if (Erx = _ErrRights) then
          Msg(800003,'Löschen eines Benutzers',0,0,0);
        else
          Msg(001000+Erx,gTitle,0,0,0);
      end;
    end;

    Adr_Ktd_Data:DeleteUser();

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
begin

  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    $Usr.Auswahl->Winclose();
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
begin
   if (aItem=0) or (aID=0) then RETURN false;
 case (aevt:obj -> wpname) of
 'ZL.User' : begin


  if ((aButton & _WinMouseLeft)<>0) and ((aButton & _WinMouseDouble)<>0) then begin
    gSelected # aID;
    $Usr.Auswahl->Winclose();
  end;
 end;

end; //
return(true)
end;


//========================================================================
//  EvtMenuCommand
//                Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vA    : alpha(4000);
  vTmp  : int;
  vUser : alpha;
  vHdl  : handle;
  Erx   : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Username' : begin
      ChangeUserName();
    end;


    'Mnu.Aktivitaeten' : begin
      TeM_Subs:Start(800);
    end;


    'Usr.Cancel' : begin
      $Usr.Auswahl->winclose();
    end;


    'Grp.Cancel' : begin
      vHdl # w_parent;
      $Usr.Gruppen->winclose();
      vHdl->wpdisabled # n;
      vHdl->winfocusset(true);
    end;


    'Grp.Insert' : begin
//      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.G.Auswahl','Usr_Main:AuswahlExit');
gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.G.Verwaltung',here+':AuswahlExit');
      Lib_GuiCom:RunChildWindow(gMDI);
//      gMDI->WinUpdate(_WinUpdOn);
    end;


    'Grp.Delete' : begin
      //Zuweisung aufheben?
      if (Msg(802002,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
        RekDelete(802,0,'MAN');
      end;
      $ZL.Usr.Gruppen->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
      $ZL.Usr.Gruppen->WinFocusSet(y);
    end;


    'Listen' : begin
      Lfm_Ausgabe:Auswahl('User');
    end;


    'Mnu.Gruppen' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Gruppen', '');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Rechte' : begin

      Erx # RecLink(802,800,1,_RecFirst);
      WHILE (Erx=_ROk) do begin
        RecLink(801,802,1,0);
        vA # Usr_R_Main:AddRightString(vA, Usr.Grp.Rights1+Usr.Grp.Rights2+Usr.Grp.Rights3+Usr.Grp.Rights4, cMaxRights);
        Erx # RecLink(802,800,1,_RecNext);
      END;

      if RecRead(800,1, _RecLock)<>_rOk then begin
        Msg(800001,'',0,0,0);
        RETURN false;
      end;
                                        // Rechtevergabe
      vA # Usr_R_Main:ManageRights(Usr.Rights1+Usr.Rights2+Usr.Rights3+Usr.Rights4,vA,y);
      Usr.Rights1 # StrCut(vA,1,250);
      Usr.Rights2 # StrCut(vA,251,250);
      Usr.Rights3 # StrCut(vA,501,250);
      Usr.Rights4 # StrCut(vA,751,250);
      ERx # RekReplace(800,_RecUnlock,'MAN');
      if (Erx<>_rOk) then begin
        Msg(800002,'',0,0,0);
        RETURN false;
      end;

      vUser # Usr.UserName;

      // Rechtearray aufbauen
      Usr_R_Main:BuildMyRights();

      Usr.UserName # vUser;
      RecRead(800,1,0);
      gMdi->winUpdate();

/*
      gZLList->wpdisabled # false;
      Mode # vMode;
      App_Main:RefreshMode();
      gZLList->WinFocusSet(true);*/
    end;

    'Mnu.Druck.UsrEtk' : begin
      Lib_Dokumente:Printform(800,'UserEtikett',true);
    end;


    'Mnu.CustomRechte' : begin

      Erx # RecLink(802,800,1,_RecFirst);
      WHILE (Erx=_ROk) do begin
        RecLink(801,802,1,0);
        vA # Usr_R_Main:AddRightString(vA, Usr.Grp.Customright1, cMaxCustomRights);
        Erx # RecLink(802,800,1,_RecNext);
      END;

      if RecRead(800,1, _RecLock)<>_rOk then begin
        Msg(800001,'',0,0,0);
        RETURN false;
      end;
                                        // Rechtevergabe
      vA # Usr_R_Main:ManageCustomRights(Usr.Customrights1,vA,y);
      Usr.Customrights1 # StrCut(vA,1,1000);
      Erx # RekReplace(800,_RecUnlock,'MAN');
      if (Erx<>_rOk) then begin
        Msg(800002,'',0,0,0);
        RETURN false;
      end;

      vUser # Usr.UserName;

      // Rechtearray aufbauen
      Usr_R_Main:BuildMyRights();

      Usr.UserName # vUser;
      RecRead(800,1,0);
      gMdi->winUpdate();
    end;

    'Mnu.Druck.MKarte' : begin
      if (Usr.Typ='W') then
        Usr_Subs:DruckMitarbeiterkarte();
         else
        Msg(99,'Kein MDE User',0,0,0);
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

//  $ZL.Usr.Gruppen->wpdisabled # false;
//  Lib_GuiCom:SetWindowState($Usr.Gruppen,true);
  gZLList->wpDisabled # false;

  if (gSelected<>0) then begin

    RecRead(801,0,0,gSelected);
    gSelected # 0;
    "Usr.U<>G.User"   # Usr.Username;
    "Usr.U<>G.Gruppe" # Usr.Grp.Gruppenname;
    Erx # RekInsert(802,0,'MAN');
    If Erx<>_rOk then begin
      //Zuweisung existiert bereits
      Msg(802001,'',_WinIcoError,_WinDialogokCancel,1);
    end;
  end;

  $ZL.Usr.Gruppen->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $ZL.Usr.Gruppen->WinFocusSet(y);
end;


//========================================================================
// AusAdresse
//========================================================================
sub AusAdresse()
begin
  if (gSelected=0) then RETURN;

  RecRead(100,0,_RecId,gSelected);
  // Feldübernahme
  gSelected     # 0;

  Usr.ZuDatei   # 100;
  USr.ZuNummer1 # Adr.Nummer;

  ZeigeTyp();

  if (Msg(99,'An Ansprechpartner binden?', _WinIcoQuestion, _WinDialogYesNo,2)<>_Winidyes) then RETURN;

  RecBufClear(102);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.P.Verwaltung',here+':AusAnsprechpartner');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  gZLList->wpdbfileno     # 100;
  gZLList->wpdbkeyno      # 13;
  gZLList->wpdbLinkFileNo # 102;
  // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
  gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//  AusAnsprechpartner
//
//========================================================================
sub AusAnsprechpartner()
local begin
  vHdl  : int;
end;
begin
  if (gSelected=0) then RETURN;
  RecRead(102,0,_RecId,gSelected);
  // Feldübernahme
  gSelected     # 0;

  Usr.ZuDatei   # 102;
  Usr.ZuNummer1 # Adr.P.AdressNr;
  Usr.ZuNummer2 # Adr.P.Nummer;

  ZeigeTyp();
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

  vHdl # gMdi->WinSearch('Rechte');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_Rechte]=n);

  vHdl # gMdi->WinSearch('Gruppen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_Gruppen]=n);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Usr_Loeschen]=n);

// aaa  if (Mode<>c_ModeOther) /*and (aNoRefresh=false)*/ then RefreshIfm();
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

    'bt.WebDatensatz' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
     end;

    'bt.WebPasswort' : begin
      if (Msg(99,'Wirklich neues Passwort erzeugen?',_WinIcoQuestion, _WinDialogYesNo,2)=_winidyes) then
        Usr_data:NeuesWebPasswort();
    end;

    'bt.WebPasswortSet' : begin
      if (Msg(99,'Wirklich neues Passwort angeben?',_WinIcoQuestion, _WinDialogYesNo,2)=_winidyes) then
        Usr_data:NeuesWebPasswortFestlegen();
    end;

    'Grp.Insert' : begin
      EvtMenuCommand(null,aEvt:Obj);
    end;


    'Grp.Delete' : begin
      EvtMenuCommand(null,aEvt:Obj);
    end;


    'bt.OutlookKalender' : begin
      Usr.OutlookCalendar # Lib_COM:ChooseCalendar(var Usr.OutlookStore1, var Usr.OutlookStore2);
      GV.Alpha.40 # Usr.OutlookCalendar; // BUG. Usr.OutlookCalendar wird irgendwo überschrieben, wenn Focus auf Outlook wechselt..
      RefreshIfm( 'edUsr.OutlookCalendar' );
      RefreshIfm( 'edUsr.OutlookStore1' );
    end;

  end;
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged ( aEvt : event; ) : logic
local begin
  vName   : alpha;
  vTxtHdl : int;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  case ( aEvt:Obj->wpName ) of
    'cbUsr.TapiYN'    : RefreshIfm( 'Tapi' );
    'cbUsr.OutlookYN' : RefreshIfm( 'Outlook' );

    'cbTyp.Normal'    : begin
      if (aEvt:Obj->wpCheckState=_WinStateChkChecked) then Usr.Typ # 'N';
      Pflichtfelder();
      ZeigeTyp();
    end;
    'cbTyp.Betrieb'   : begin
      if (aEvt:Obj->wpCheckState=_WinStateChkChecked) then Usr.Typ # 'B';
      Pflichtfelder();
      ZeigeTyp();
    end;
    'cbTyp.System'    : begin
      if (aEvt:Obj->wpCheckState=_WinStateChkChecked) then Usr.Typ # 'S';
      Pflichtfelder();
      ZeigeTyp();
    end;
    'cbTyp.Web'       : begin
      if (aEvt:Obj->wpCheckState=_WinStateChkChecked) then Usr.Typ # 'W';
      Pflichtfelder();
      ZeigeTyp();
    end;
  end;

  RETURN true;
end;


//========================================================================
//  EvtLstSelect
//                Datensatz in ZL gewählt
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecId                : int;          // REcord-ID) : logic
) : logic
local begin
   iErr : int;
   fmcount : int;
end
begin

  case (aevt:obj -> wpname) of
    'ZL.User' : begin
      recread(800,0,_recid,arecid);
      $NB.Page1 -> winupdate(_winupdfld2obj);
    end;
  end;  // case
  RETURN(true)
//  Refreshmode();
//  RecRead(801,0, 0,gZLList->wpDbRecId);
//  RETURN true;
end;


//========================================================================
//  EvtLstRecControl
//
//========================================================================
sub EvtLstRecControl(
  opt aEvt             : event;    // Ereignis
  opt aRecID           : int;      // Record-ID des Datensatzes
) : logic;
begin

  if (w_Auswahlmode) then begin
    RETURN (Usr.DeaktiviertYN=false);
  end;

  RETURN(true);
end;


//========================================================================
//  Grp_RL_Ctrl
//              Control der Gruppenliste eines Users
//========================================================================
sub Grp_RL_Ctrl(
  aEvt                  : event;        // Ereignis
  aRecId                : int;          // REcord-ID) : logic
) : logic
begin
  RETURN true;//(RecLink(801,802,1,0)=_rOK);
end;


//========================================================================
//  Grp_EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub Grp_EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin

  gMenuName # 'Usr.Gruppen';
  gTitle  # Translate('User');
  gFile   # 802;
//  gFrmMain->wpMenuname # gUsr.Gruppen'; // Menü setzen
  gPrefix # 'Usr';
  gZLList # $ZL.Usr.Gruppen;
  gKey    # 1;

  gMenu # gFrmMain->WinInfo(_WinMenu);

  Call('App_Main:EvtMdiActivate',aEvt);
  $Grp.Insert->wpdisabled # false;
  $Grp.Delete->wpdisabled # false;
end;


//========================================================================
//  Grp_EvtLstDataInit
//
//========================================================================
sub GrP_EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
local begin
 Erx  : int;
end
begin
  Erx # RecLink(801,802,1,0);
  if (Erx>_rLocked) then recbufClear(801);
end;


//========================================================================
//  Auswahl_EvtMdiActivate
//                          Fenster aktivieren
//========================================================================
sub Auswahl_EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  gTitle  # 'User';
  gPrefix # 'Usr';
  gFrmMain->wpMenuname # 'Usr.Auswahl';

  Call('App_Main:EvtMdiActivate',aEvt);
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : event;
  aRecid    : int;
  Opt aMark : logic;
);
local begin
   ierr : int;
end
begin
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  // msg(700900,'Close',0,0,0);
  RETURN true;
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit ( aEvt : event; aFocusObject : int ) : logic
begin
  RETURN true;
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
// Auswahl_EvtInit
//
//========================================================================
sub Auswahl_EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  $ZL.Userauswahl->wpcustom # cnvai(gZLList);
  gZLList   # $ZL.Userauswahl;
end;


//========================================================================
// Auswahl_EvtClose
//
//========================================================================
sub Auswahl_EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  gZLList # cnvia($ZL.Userauswahl->wpcustom);
  RETURN true;
end;


//========================================================================
//  AuswahlEvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub AuswahlEvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
begin
  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    $Usr.Auswahl2->Winclose();
  end;
end;


//========================================================================
//  AuswahlEvtMouseItem
//                Mausklicks in Listen
//========================================================================
sub AuswahlEvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin
  if (aButton=_WinMouseDouble | _WinMouseLeft) then begin
    gSelected # aID;
    $Usr.Auswahl2->Winclose();
  end;
end;


//========================================================================
//  ChooseUser
//
//========================================================================
sub ChooseUser() : alpha;
local begin
  vHdl  : int;
  vTmp  : int;
  v800  : int;
  vUser : alpha;
end;
begin
  v800 # RekSave(800);

  vHdl # WinOpen('Usr.Auswahl2',_WinOpenDialog);
  vHdl->WinDialogRun(_WinDialogCenter,gMDI);
  WinClose(vHdl);
  if (gSelected=0) then begin
    RekRestore(v800);
    RETURN '';
  end;
  RecRead(800,0,_RecId,gSelected);
  gSelected # 0;
  vUser # Usr.Username;

  RekRestore(v800);
  
  RETURN vUser;
end;


//========================================================================
//========================================================================
sub UserStatusEvtFocusInit(
  aEvt                  : event;        // Ereignis
  aFocusObject          : handle;       // Objekt, das den Fokus zuvor hatte
) : logic;
begin
  $rbSonstiges->wpCheckstate # _WinStateChkChecked;
  RETURN(true);
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================