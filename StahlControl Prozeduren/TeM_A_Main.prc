@A+
//==== Business-Control ==================================================
//
//  Prozedur    TeM_A_Main
//                  OHNE E_R_G
//  Info
//    Steuert die Terminaktionsmaske
//
//  25.07.2003  ST  Erstellung der Prozedur
//  01.06.2012  AI  Markierte übernehmen als Anker
//  04.02.2022  AH  ERX
//  2023-08-22  AH  Proj. 2511/8
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusBAG_P()
//    SUB AusAuftrag()
//    SUB AusBestellung()
//    SUB AusMaterial()
//    SUB AusUser()
//    SUB AusAdresse()
//    SUB AusPartner()
//    SUB AusProjekt()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Lib_Nummern
@I:Def_Aktionen

define begin
  cTitle :    'Anker'
  cFile :     981
  cMenuName : 'TeM.A.Bearbeiten'
  cPrefix :   'TeM_A'
  cZList :    $ZL.TeM.Anker
  cKey :      1
  cListen : 'Termine';
end;

declare Auswahl(aBereich : alpha);

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
  //SetStdAusFeld('', ''):

  App_Main:EvtInit(aEvt);
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
  vA1,vA2 : alpha;
end;
begin

  TeM_A_Data:Code2Text(var vA1,var vA2);

  $lb.Anker->wpCaption # vA1+' '+vA2;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  vTmp  : int;
  vHdl  : handle;
end;
begin

  if (Mode=c_ModeNew) then begin
    App_Main:Refreshmode();
    vTmp # WinDialog('TeM.Anker.Auswahl',_WinDialogCenter,gMDI);

    IF (vTmp= _WinIdClose) or (gSelected=0) then begin
      App_Main_Sub:StopModeNew();   // Neuerfassung abbrechen
      RETURN;
    end;

    gMDI->winfocusset(true);
    vTmp # gSelected;
    gSelected # 0;
    // Liste je nach Auswahl aufrufen
    // Zu verankernde Position auswählen
    CASE (vTmp) OF
        100 : Auswahl('Adresse');
        102 : Auswahl('Partner');
        120 : Auswahl('Projekte');
        122 : Auswahl('Projektpos');
        200 : Auswahl('Material');
        401 : Auswahl('Auftrag');
        501 : Auswahl('Bestellung');
        800 : Auswahl('User');
        702 : Auswahl('BAG_P');
    END;
//    Call('TeM_Ank_Create');
//    Lib_GuiCom:Disable($edTeM.A.Erledigt.Datum);
//    Lib_GuiCom:Disable($edTeM.A.Erledigt.Zeit);
    RETURN;
  end;

  if (Mode=c_ModeEdit) then begin
    TeM.A.Erledigt.Datum # today;
    TeM.A.Erledigt.Zeit  # Now;
    $edTeM.A.Erledigt.Datum->WinFocusSet(true);
  end;
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vA        : alphA;
  vErinnern : logic;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If (($edTeM.A.Erledigt.Datum <> 0) AND ($edTeM.A.Erledigt.Datum <> 0)) then
    TeM.A.Erledigt.User # Usr.Username;

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
    // 2023-08-22 AH    Proj. 2511/8
    if (TeM.A.Datei=800) then begin
      vA # Lib_Termine:GetBasisTyp(Tem.Typ);
      if (vA='WVL') then vErinnern # true;
    end;
    TeM_A_Data:Anker(981,'MAN', vErinnern);
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
  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable( aEvt:obj );
  else
    Lib_GuiCom:AuswahlDisable( aEvt:obj );
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
begin

  $edTeM.A.Start.Datum->WinFocusSet(false); // Focus setzen !WICHTIG! da vor der jeweiligen Auswahl ein weiteres
                                            // "Auswahlfenster" aufpopt
  case aBereich of

    'BAG_P' : begin
      RecBufClear(700);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Verwaltung',here+':AusBAG_P');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Adresse' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Partner' : begin
      RecBufClear(102);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.P.Verwaltung',here+':AusPartner');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Projekte' : begin
      RecBufClear(120);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusProjekt');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Projektpos' : begin
      RecBufClear(120);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusProjektPos1');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'User' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AusUser');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Material' : begin
      RecBufClear(200);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Auftrag' : begin
      RecBufClear(401);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusAuftrag');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Bestellung' : begin
      RecBufClear(501);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung',here+':AusBestellung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  ChoosePos
//
//========================================================================
sub ChoosePos() : int;
local begin
  vHdl  : int;
  vTmp  : int;
 end;
begin
  vHdl # WinOpen('BA1.P.Auswahl',_WinOpenDialog);

  vTmp # Winsearch(vHdl,'LB.Info1');
  vTmp->wpcaption # c_AKt_BA+' '+AInt(BAG.Nummer)+' '+BAG.Bemerkung;
  vTmp # Winsearch(vHdl,'LB.Info3');
  vTmp->wpcaption # Translate('Arbeitsgang wählen:');

  vHdl->WinDialogRun(_WinDialogCenter,gMDI);
  WinClose(vHdl);
  if (gSelected=0) then RETURN 0;
  RecRead(702,0,_RecId,gSelected);
  gSelected # 0;

  RETURN BAG.P.Position;
end;


//========================================================================
//  AusBAG_P
//
//========================================================================
sub AusBAG_P()
local begin
  Erx   : int;
  vPos  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(700,0,_RecId,gSelected);
    gSelected # 0;

    // Position wählen
    vPos # ChoosePos();

    BAG.P.Nummer # BAG.Nummer;
    BAG.P.Position # BAG.P.Position;
    Erx # RecRead(702, 1, 0); // BAG.Pos lesen
    if(Erx > _rLocked) then
      RecBufClear(702);

    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Datei   # 702;
    TeM.A.ID1     # BAG.P.Nummer;
    TeM.A.ID2     # BAG.P.Position;
  end;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $edTeM.A.Start.Datum->WinFocusSet(true);
  RefreshIfm();
end;


//========================================================================
//  AusAuftrag
//
//========================================================================
sub AusAuftrag()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Datei   # 401;
    TeM.A.ID1     # Auf.P.Nummer;
    TeM.A.ID2     # Auf.P.Position;
    TeM.A.lfdNr   # 1;
  end;
  $edTeM.A.Start.Datum->winFocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusBestellung
//
//========================================================================
sub AusBestellung()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(501,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Datei   # 501;
    TeM.A.ID1     # Ein.P.Nummer;
    TeM.A.ID2     # Ein.P.Position;
    TeM.A.lfdNr   # 1;
  end;
  $edTeM.A.Start.Datum->winFocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.ID1     # Mat.Nummer;
    TeM.A.Datei   # 200;
  end;
  $edTeM.A.Start.Datum->winFocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusUser
//
//========================================================================
sub AusUser()
local begin
  Erx : int;
end;
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    Erx # RecRead(800,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Code    # Usr.Username;
    TeM.A.Datei   # 800;
    TeM.A.lfdNr   # 1;
  end;
  Usr_data:RecReadThisUser();
  RefreshIfm();
  Erx # $edTeM.A.Start.Datum->WinFocusSet(false);

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Datei   # 100;
    TeM.A.ID1     # Adr.Nummer;
    TeM.A.lfdNr   # 1;
  end;
  $edTeM.A.Start.Datum->winFocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusPartner
//
//========================================================================
sub AusPartner()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(102,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Datei   # 102;
    TeM.A.ID1     # Adr.P.Adressnr;
    TeM.A.ID2     # Adr.P.Nummer;
    TeM.A.lfdNr   # 1;
  end;
  $edTeM.A.Start.Datum->winFocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusProjekt
//
//========================================================================
sub AusProjekt()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Datei   # 120;
    TeM.A.ID1     # Prj.Nummer;
  end;
  $edTeM.A.Start.Datum->winFocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusProjektPos1
//
//========================================================================
sub AusProjektPos1()
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vHdl  : int;
end;
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    gSelected # 0;


    RecBufClear(122);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.P.Verwaltung',here+':AusProjektPos2');

    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

    vQ # '';
    Lib_Sel:QInt(var vQ, 'Prj.P.Nummer', '=', Prj.Nummer);
    vHdl # SelCreate(122, 1);
    Erx # vHdl->SelDefQuery('', vQ);
    if (Erx <> 0) then Lib_Sel:QError(vHdl);
    // speichern, starten und Name merken...
    w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
    // Liste selektieren...
    gZLList->wpDbSelection # vHdl;

    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;

  end;
  $edTeM.A.Start.Datum->winFocusset(true);
  RefreshIfm();
end;


//========================================================================
//  AusProjektPos2
//
//========================================================================
sub AusProjektPos2()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(122,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Datei   # 122;
    TeM.A.ID1     # Prj.P.Nummer;
    TeM.A.ID2     # Prj.P.Position;
    TeM.A.ID3     # Prj.P.SubPosition;
  end;
  $edTeM.A.Start.Datum->winFocusset(true);
  RefreshIfm();
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : handle;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeEdit) or  (Mode=c_ModeNew) or (Rechte[Rgt_TeM_A_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_TeM_A_Loeschen]=n);

  $bt.Notify->wpDisabled # false;

  // Menüs sperren
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;

  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeEdit) or  (Mode=c_ModeNew) or (Rechte[Rgt_TeM_A_Aendern]=n);

  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_TeM_A_Loeschen]=n);

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
  vHdl  : handle;
  vTmp  : int;
end;
begin
  case (aMenuItem->wpName) of

    'Mnu.InsertAdr' : begin
      vTmp # Lib_Mark:Count(100);
      if (vTmp>0) then begin
        if (Msg(981001,aint(vTmp),_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes) then begin
          Lib_Mark:Foreach(100,here+':DelegateInsertAdr');
          gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
        end;
      end;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;

  end; // case

end;


//========================================================================
//  DelegateInsertAdr
//
//========================================================================
sub DelegateInsertAdr() : int;
begin
  TeM_A_Data:Anker(100,'MAN');
  RETURN 0;
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin
  case (aEvt:Obj->wpName) of
    'bt.Notify' : begin
      RecLink( 980, 981, 1, _recFirst );

      if ( TeM.A.Datei = 800 ) then
        Lib_Notifier:NewEvent( TeM.A.Code, '980/' + AInt( TeM.A.Nummer ), TeM.Bezeichnung, TeM.A.Nummer, TeM.A.Start.Datum, TeM.A.Start.Zeit );
      else
        Lib_Notifier:NewEvent( gUsername, '980/' + AInt( TeM.A.Nummer ), TeM.Bezeichnung, TeM.A.Nummer, TeM.A.Start.Datum, TeM.A.Start.Zeit );
    end;
  end;

  if ( Mode = c_ModeView ) then
    RETURN true;

  case (aEvt:Obj->wpName) of

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
local begin
  vA1,vA2 : alpha;
end;
begin
  TeM_A_Data:Code2Text(var vA1,var vA2);
  Gv.Alpha.01 # vA1+' '+vA2;
  Refreshmode();
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