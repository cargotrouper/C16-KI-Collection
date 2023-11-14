@A+
//==== Business-Control ==================================================
//
//  Prozedur    TeM2_Main
//                  OHNE E_R_G
//  Info
//
//
//  29.03.2005  AI  Erstellung der Prozedur
//  27.08.2009  MS  Um neue Datein erweitert, alte geprüft
//  04.12.2014  ST  Abbruch löscht nur noch hinzugefügte Anker 1326/394
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusUser()
//    SUb AusAuftrag()
//    SUB AusBestellung()
//    SUB AusAdresse()
//    SUB AusPartner()
//    SUB AusProjekt()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle :    'Aktivitäten'
  cFile :     980
  cMenuName : 'TeM.Bearbeiten'
  cPrefix :   'TeM2'
  cZList :    $ZL.Tem.Termine
  cKey :      1
end;

local begin

  lCteAnkerPuffer : int;

end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  Erx : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

// Tem2_Main:refreshfim();

  // Auswahlfelder setzen...
  SetStdAusFeld('edTeM.Typ' ,'TEMTYP');

  App_Main:EvtInit(aEvt);

  Usr.Username # gUserName;
  RecRead( 800, 1, 0 );

  // ST 2014-12-04 P1326/394: Eingetragene Anker merken, damit diese bei Abbruch
  //                          nicht gelöscht werden
  lCteAnkerPuffer # CteOpen(_CteTree);
  FOR   Erx # Reclink(981,980,1,_recFirst)
  LOOP  Erx # Reclink(981,980,1,_recNext)
  WHILE Erx <=_rLocked DO BEGIN
    lCteAnkerPuffer->CteInsertItem(CnvAi(RecInfo(981,_RecID)),  // Name
                                   RecInfo(981,_RecID),         // ID
                                   '',                          // Custom
    _CteLast);
    debugstamp(Aint(lCteAnkerPuffer->CteInfo(_CteCount)));
  END;
  $rl.Tem2.anker->wpCustom # Aint(lCteAnkerPuffer);

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
  vTmp  : int;
end;
begin

  // veränderte Felder in Objekte schreiben
  $LB.Typ->wpCaption # Call('Lib_Termine:GetTypeName',TeM.Typ);

  if (aName='') then begin
    Lib_GuiCom:Disable($edTeM.Anlage.Datum);
    Lib_GuiCom:Disable($edTeM.Anlage.Zeit);
    Lib_GuiCom:Disable($edTeM.Anlage.User);
    Lib_GuiCom:Disable($edTeM.Erledigt.User);
  end;


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

  TeM.Nummer # myTmpnummer;
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then TeM.SichtbarPlanerYN # y;

  // sich selber als Anker mal setzen
//  TeM_A_Data:New(1,'MAN');

/***
  RecBufClear(981);
  TeM.A.Nummer      # TeM.Nummer;
  TeM.A.Berichtsnr  # 0;
  TeM.A.Code        # gUserName;
  TeM.A.Datei       # 800;
  TeM.A.lfdNr       # 1;
  REPEAT
    Erx # TeM_A_Data:Insert(0,'MAN');
    if (Erx<>_rOK) then inc(TeM.A.lfdNr);
  UNTIl (Erx=_rOK);
***/
//  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

/****
  // Aktueller User kann fertigmelden
  $EdTeM.Erledigt.User->wpCaption # gUserName;
  TeM.Erledigt.User # gUsername;

  // Schlüssel und Anlagedaten sperren
  Lib_GuiCom:Disable($edTeM.Erledigt.User);
//  Lib_GuiCom:Disable($edTeM.Nummer);
  Lib_GuiCom:Disable($edTeM.Anlage.Datum);
  Lib_GuiCom:Disable($edTeM.Anlage.Zeit);
  Lib_GuiCom:Disable($edTeM.Anlage.User);

  // Schon fertiggemeldete Aktivitäten nicht nochmal fertigmeldbar
  if (TeM.Erledigt.Datum <> 00.00.00) AND (TeM.Erledigt.Zeit <> 00:00) then begin
    Lib_GuiCom:Disable($edTeM.Erledigt.Datum);
    Lib_GuiCom:Disable($edTeM.Erledigt.Zeit);
  end;

  // Focus setzen auf Feld:
  $edTeM.Typ->WinFocusSet(true);
***/
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vNr   : int;
  vTmp  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // Dauer errechnen
  TeM.Dauer # 0.0;
  if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum<>0.0.0) then begin
    vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
    vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000);
    TeM.Dauer # CnvFI(vTmp);
    vTmp # (CnvID(TeM.Ende.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
    vTmp # vTmp + (Cnvit(TeM.Ende.Von.Zeit)/60000);
    TeM.Dauer # CnvFI(vTmp) - TeM.Dauer;
  end;

  If  (TeM.Erledigt.Datum <> 00.00.00)  AND
      (TeM.Erledigt.Zeit  <> 00:00)   then begin

    FOR Erx # RecLink(981,980,1,_RecFirst)
    LOOP Erx # RecLink(981,980,1,_RecNext)
    WHILE (Erx <> _rNoRec) DO BEGIN

      // Wurde Anker schon einzeln fertiggemeldet?
      if (TeM.A.Erledigt.Datum <> 00.00.0000) AND
         (TeM.A.Erledigt.Zeit <> 00:00)       AND
         (TeM.A.Erledigt.User <> '')  then CYCLE;


        // Wurde noch nicht fertiggemeldet, also machen wir das jetzt
      RecRead(981,1,_recLock);
      TeM.A.Erledigt.Datum  # TeM.Erledigt.Datum;
      TeM.A.Erledigt.Zeit   # TeM.Erledigt.Zeit;
      TeM.A.Erledigt.User   # TeM.Erledigt.User;

      // Satz zurückspeichern & protokolieren
//          if (Mode=c_ModeEdit) then begin
      Erx # RekReplace(981,_RecUnlock,'MAN');
      if (Erx<>_rOk) then begin
        Msg(001000+Erx,Translate('Anker'),0,0,0);
        RETURN False;
      end;
      PtD_Main:Compare(gFile);
/*
          end
        else begin
//            TeM_A_Data:Insert(0,'MAN');
          Erx # TeM_A_Data:Anker(122,'MAN');
          if (Erx<>_rOk) then begin
            Msg(001000+Erx,Translate('Anker'),0,0,0);
            RETURN False;
          end;
        end;
*/

    END;
  end;

  // Nummernvergabe

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    PtD_Main:Forget(980);
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end
  else begin

    TRANSON;

    // Nummernvergabe
    vNr        # Lib_Nummern:ReadNummer('Termin');    // Nummer lesen
    Lib_Nummern:SaveNummer();                         // Nummernkreis aktuallisiern

    WHILE (RecLink(981,980,1,_RecFirst)=_rOK) DO BEGIN
      RecRead(981,1,_recLock);
      TeM.A.Nummer # vNr;
      Erx # RekReplace(981,_RecUnlock,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
    END;

    TeM.Nummer # vNr;

    Tem.Anlage.Datum  # Today;
    TEm.Anlage.Zeit   # Now;
    Tem.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TRANSOFF;

    FOR Erx # RecLink(981,980,1,_RecFirst)
    LOOP Erx # RecLink(981,980,1,_RecNext)
    WHILE (Erx<=_rLocked) DO BEGIN
      if (TeM.A.Datei=800) then
//        Lib_Notifier:NewEvent( TeM.A.Code, '980', TeM.Bezeichnung, TeM.A.Nummer, TeM.A.Start.Datum, TeM.A.Start.Zeit );
      Lib_Notifier:NewEvent( TeM.A.Code, '980', 'AKT '+AInt(TeM.Nummer)+' '+TeM.Bezeichnung, TeM.A.Nummer );

    END;

  end;

//  Mode # c_modeCancel;  // sofort ales beenden!
//  gMdi->winclose();

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
local begin
  Erx     : int;
  vFound  : int;
end;
begin

  // Anker löschen, die vor der Bearbeitung noch nicht gespeichert waren
  lCteAnkerPuffer # CnvIa($rl.Tem2.anker->wpCustom);
  FOR   Erx # Reclink(981,980,1,_recFirst)
  LOOP  Erx # Reclink(981,980,1,_recNext)
  WHILE Erx <= _rLocked DO BEGIN
     vFound # lCteAnkerPuffer->CteRead(_CteFirst | _CteSearch,0,CnvAi(RecInfo(981,_RecId)));
     if (vFound = 0) then begin
        TeM_A_Data:Delete(0,'AUTO');
        Erx # Reclink(981,980,1,_recPrev);
     end;
  END;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  tLinkFlag : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    // Zugehörige Anker
    tLinkFlag # _RecFirst;
    WHILE (RecLink(981,980,1,tLinkFlag) < _rNoRec ) DO BEGIN
      Tem_A_Data:Delete(0,'MAN');
    END;

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

  $bt.OutlookExport->wpDisabled # (!Usr.OutlookYN);
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
  vTmp  : int;
end;
begin

  case (aEvt:Obj->wpname) of

    'edTeM.Dauer' : begin
      if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum<>0.0.0) then begin
        vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
        vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000);
        vTmp # vTmp + Cnvif(TeM.Dauer);
        TeM.Ende.Von.Datum  # CnvdI( (vTmp / 1440) + cnvid(1.1.2000));
        TeM.Ende.Von.Zeit   # cnvti( (vTmp % 1440) * 60000);
        $edTeM.Ende.Von.Datum->winupdate(_WinUpdFld2Obj);
        $edTeM.Ende.Von.Zeit->winupdate(_WinUpdFld2Obj);
      end;
    end;

    'edTeM.Start.Von.Datum', 'edTeM.Start.Von.Zeit', 'edTeM.Ende.Von.Datum', 'edTeM.Ende.Von.Zeit' : begin
      TeM.Dauer # 0.0;
      if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum<>0.0.0) then begin
        vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
        vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000);
        TeM.Dauer # CnvFI(vTmp);
        vTmp # (CnvID(TeM.Ende.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
        vTmp # vTmp + (Cnvit(TeM.Ende.Von.Zeit)/60000);
        TeM.Dauer # CnvFI(vTmp) - TeM.Dauer;
        $edTeM.Dauer->winupdate(_WinUpdFld2Obj);
      end;
    end;

  end;

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
  vHdl  : int;
  vHdl2 : int;
  vi    : int;
  vText : alpha;
  vSelected : int;
end;

begin

  case aBereich of

    'Auftrag' : begin
      RecBufClear(401);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAuftrag');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Bestellung' : begin
      RecBufClear(501);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusBestellung');
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


    'BAG_P' : begin
      RecBufClear(700);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Verwaltung',here+':AusBAG_P');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Material' : begin
      RecBufClear(200);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'TEMTYP' : begin
      RecBufClear(857);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TTy.Verwaltung',here+':AusTTy');
      Lib_GuiCom:RunChildWindow(gMDI);
/***
      Lib_Einheiten:Popup('Termintyp',$edTeM.Typ,980,1,2);
      $Lb.Typ->wpCaption # Call('Lib_Termine:GetTypeName',Tem.Typ);
      $edTeM.Typ->WinUpdate(_WinUpdFld2Obj);
      $Lb.Typ->WinUpdate(_WinUpdFld2Obj);
      $edTeM.Typ->winFocusSet(true);
***/
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
//  AusTTy
//
//========================================================================
sub AusTTy()
local begin
  vPos : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(857,0,_RecId,gSelected);
    gSelected # 0;
    TeM.Typ # TTY.Typ2;
  end;
//  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
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
  end;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

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
    TeM_A_Data:Anker(200,'MAN');
  end;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;



//========================================================================
//  AusUser
//
//========================================================================
sub AusUser()
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(800,'MAN');
  end;
  Usr_data:RecReadThisUser();
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  Ausauftrag
//
//========================================================================
sub AusAuftrag()
begin
  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(401,'MAN');
  end;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusBestellung
//
//========================================================================
sub AusBestellung()
begin
  if (gSelected<>0) then begin
    RecRead(501,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(501,'MAN');
  end;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(100,'MAN');
  end;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusPartner
//
//========================================================================
sub AusPartner()
begin
  if (gSelected<>0) then begin
    RecRead(102,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(102,'MAN');
  end;
  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusProjekt
//
//========================================================================
sub AusProjekt()
begin
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(120,'MAN');
  end;

  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
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
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusProjektPos2
//
//========================================================================
sub AusProjektPos2()
begin
  if (gSelected<>0) then begin
    RecRead(122,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(122,'MAN');
  end;

  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl        : int;
  vChildmode  : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  vHdl # gMdi->WinSearch('Mnu.Anker');
  if (vHdl <> 0) then vHdl->wpDisabled # y;
  vHdl # gMdi->WinSearch('Mnu.Berichte');
  if (vHdl <> 0) then vHdl->wpDisabled # (TeM.Nummer=0);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;


  vHdl # gMdi->WinSearch('Mark');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('RecPrev');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('RecNext');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Search');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;


  // Menüleiste setzen
  vHdl # gMenu->WinSearch('Mnu.Save');
  if (vHdl <> 0) then
    vHdl->wpDisabled # n;

  vHdl # gMenu->WinSearch('Mnu.Cancel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # n;

  vHdl # gMenu->WinSearch('Mnu.Mark');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.RecPrev');
  if (vHdl <> 0) then
    vHdl->wpdisabled # y;

  vHdl # gMenu->WinSearch('Mnu.RecNext');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.RecLast');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.RecFirst');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.Search');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.NextPage');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.PrevPage');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Info');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.Info');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Listen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Druck');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

//  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then
//    RefreshIfm();
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
  vHdl : int;
end;
begin

  case (aMenuItem->wpName) of

    'Mnu.Berichte' : begin
      RecBufClear(982);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TeM.B.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Anker' : begin
      RecBufClear(981);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TeM.A.Verwaltung','');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Tem.Anlage.Datum, Tem.Anlage.Zeit, Tem.Anlage.User );
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
  Erx   : int;
  vTmp  : int;
end;
begin
  // Outlook Export
  if ( aEvt:obj->wpName = 'bt.OutlookExport' ) then
    Lib_COM:ExportTeM();

  if (Mode=c_ModeView) then
    RETURN true;

  case (aEvt:Obj->wpName) of
    
    'bt.TemTyp' :           Auswahl('TEMTYP');
    'bt.Dauer.Plus' : begin
      TeM.Dauer # TeM.Dauer + 30.0;
      $edTeM.Dauer->Winupdate(_WinUpdFld2Obj);
      if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum<>0.0.0) then begin
        vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
        vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000);
        vTmp # vTmp + Cnvif(TeM.Dauer);
        TeM.Ende.Von.Datum  # CnvdI( (vTmp / 1440) + cnvid(1.1.2000));
        TeM.Ende.Von.Zeit   # cnvti( (vTmp % 1440) * 60000);
        $edTeM.Ende.Von.Datum->winupdate(_WinUpdFld2Obj);
        $edTeM.Ende.Von.Zeit->winupdate(_WinUpdFld2Obj);
      end;
    end;


    'bt.Dauer.Minus' : begin
      TeM.Dauer # TeM.Dauer - 30.0;
      if (TeM.Dauer<0.0) then TeM.Dauer # 0.0;
      $edTeM.Dauer->Winupdate(_WinUpdFld2Obj);
      if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum<>0.0.0) then begin
        vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
        vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000);
        vTmp # vTmp + Cnvif(TeM.Dauer);
        TeM.Ende.Von.Datum  # CnvdI( (vTmp / 1440) + cnvid(1.1.2000));
        TeM.Ende.Von.Zeit   # cnvti( (vTmp % 1440) * 60000);
        $edTeM.Ende.Von.Datum->winupdate(_WinUpdFld2Obj);
        $edTeM.Ende.Von.Zeit->winupdate(_WinUpdFld2Obj);
      end;
    end;


    'bt.Anker.New' : begin
        vTmp # WinDialog('TeM.Anker.Auswahl',_WinDialogCenter,gMDI);
        IF !(vTmp = _WinIdClose) and (gSelected<>0) then begin
          gMDI->winfocusset(true);
          vTmp # gSelected;
          gSelected # 0;

          // Liste je nach Auswahl aufrufen
          // Zu verankernde Position auswählen
          CASE (vTmp) OF
            100 : Auswahl('Adresse');
            401 : Auswahl('Auftrag');
            501 : Auswahl('Bestellung');
            102 : Auswahl('Partner');
            120 : Auswahl('Projekte');
            122 : Auswahl('Projektpos');
            800 : Auswahl('User');
            200 : Auswahl('Material');
            702 : Auswahl('BAG_P');
          END;
          RETURN true;
        end;
      end;


    'bt.Anker.Del' : begin
      Erx # RecRead(981,0,0,$rl.Tem2.anker->wpdbRecId);
      if (Erx=_rOk) then begin
        TeM_A_data:Delete(0,'MAN');
      end;
      $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    end;


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
// EvtChanged
//            Feldveränderungen
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:obj->wpname='edTeM.Erledigt.Datum') then begin
    $edTeM.Erledigt.Datum->WinUpdate(_WinUpdObj2Fld);
    if (TeM.Erledigt.Datum<>0.0.0) then
      TeM.Erledigt.User # gUserName;
    else
      TeM.Erledigt.User # '';
    $edTeM.Erledigt.User->WinupdatE(_WinUpdFld2Obj);
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
//  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
return true;
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