@A+
//==== Business-Control ==================================================
//
//  Prozedur    Wgr_Main
//                          OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  15.11.2017  ST  Aufruf der Customfelder hinzugefügt
//  12.11.2021  AH  ERX
//  14.06.2022  AH  Ronde + FlachRing
//  26.07.2022  HA  Quick Jump
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
//    SUB AusSteuerart()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle :    'Warengruppen'
  cFile :     819
  cMenuName : 'Wgr.Bearbeiten'
  cPrefix :   'Wgr'
  cZList :    $ZL.Warengruppen
  cKey :      2
  cListen : 'Warengruppen'
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
  w_Listen  # cListen;

Lib_Guicom2:Underline($edWgr.Steuerschlssel);
Lib_Guicom2:Underline($edWgr.Schrottartikel);
  // Auswahlfelder setzen...
  SetStdAusFeld('edWgr.Steuerschlssel' ,'Steuerart');
  SetStdAusFeld('edWgr.Schrottartikel' ,'Schrottartikel');

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
  Lib_GuiCom:Pflichtfeld($edWgr.Dateinummer);
  Lib_GuiCom:Pflichtfeld($edWgr.Steuerschlssel);
//  if (Wgr_Data:IstMat()) then begin   08.07.2021 AH Kann über GÜTE kommen
//    Lib_GuiCom:Pflichtfeld($edWgr.Dichte);
//  end;
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

  if (aName='') then begin
    $lbWgr.Bezeichnung.L1->wpcaption # Set.Sprache1;
    $lbWgr.Bezeichnung.L2->wpcaption # Set.Sprache2;
    $lbWgr.Bezeichnung.L3->wpcaption # Set.Sprache3;
    $lbWgr.Bezeichnung.L4->wpcaption # Set.Sprache4;
    $lbWgr.Bezeichnung.L5->wpcaption # Set.Sprache5;
  end;

  if (aName='') or (aName='edWgr.Steuerschlssel') then begin
    Erx # RecLink(813,819,1,0);
    if (Erx<=_rLocked) then
      $Lb.Steuerart->wpcaption # StS.Bezeichnung
    else
      $Lb.Steuerart->wpcaption # '';
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
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  // Focus setzen auf Feld:
  if (Mode=c_modeNew) then
    $edWgr.Nummer->WinFocusSet(true)
  else
    $cbWgr.OhneBestandYN->WinFocusSet(true);
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
  if (Wgr_Data:IstMat()=false) and
    (Wgr_Data:IstArt()=false) and
    (Wgr_Data:IstMix()=false) and
    (Wgr_Data:IstHuB()=false) then begin
    Msg(001201,Translate('Dateinummer'),0,0,0);
    $edWgr.Dateinummer->WinFocusSet(true);
    RETURN false;
  end;
  if ("Wgr.Steuerschlüssel"=0) then begin
    Msg(001201,Translate('Steuerschlüssel'),0,0,0);
    $edWgr.Steuerschlssel->WinFocusSet(true);
    RETURN false;
  end;
/*** 08.07.2021 AH, kann über GÜTE kommen
  if (Wgr_Data:IstMat()) and (Wgr.Dichte=0.0) then begin
    Msg(001201,Translate('Dichte'),0,0,0);
    $edWgr.Dichte->WinFocusSet(true);
    RETURN false;
  end;
***/
  if (Wgr.Materialtyp<>'') then begin
    if (Wgr.Materialtyp<>c_WGRTyp_Stab) and
      (Wgr.Materialtyp<>c_WGRTyp_Tafel) and
      (Wgr.Materialtyp<>c_WGRTyp_Ronde) and
      (Wgr.Materialtyp<>c_WGRTyp_Flachring) and
      (Wgr.Materialtyp<>c_WGRTyp_Rohr)  and
      (Wgr.Materialtyp<>c_WgrTyp_Profil) and
      (Wgr.Materialtyp<>c_WGRTyp_Coil) and
      (Wgr.Materialtyp<>c_WGRTyp_Artikel) then begin
      
      Msg(001201,Translate('Materialtyp'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edWgr.Materialtyp->WinFocusSet(true);
      RETURN false;
    end;
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
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;

begin

  case aBereich of
    'Schrottartikel' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusSchrottartikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Steuerart' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'StS.Verwaltung',here+':AusSteuerart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusSteuerart
//
//========================================================================
sub AusSteuerart()
local begin
  Erx   : int;
  vTmp  : int;
end;
begin

  if (gSelected<>0) then begin
    Erx # RecRead(813,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "Wgr.Steuerschlüssel" # StS.Nummer;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;

  // Focus auf Editfeld setzen:
  $edWgr.Steuerschlssel->Winfocusset(false);

  // ggf. Labels refreshen
  RefreshIfm('edWgr.Steuerschlssel');
end;


//========================================================================
//  AusSchrottartikel
//
//========================================================================
sub AusSchrottartikel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Wgr.Schrottartikel # Art.Nummer;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edWgr.Schrottartikel->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Wgr_Anlegen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Wgr_Anlegen]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Wgr_Aendern]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Wgr_Aendern]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Wgr_Loeschen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Wgr_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


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
  Erx     : int;
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
  vI      : int;
  v819    : int;
  vMerge  : logic;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of
  
    'Mnu.Edit.Nr' : begin
      if (Dlg_Standard:Anzahl(Translate('neue Nummer'), var vI)=false) then RETURN true;
      if (vI=Wgr.Nummer) or (vI<=0) or (vI>60000) then begin
        Msg(001203,aint(vI),0,0,0);
        RETURN true;
      end;

      // 2023-06-23 AH
      v819 # RekSave(819);
      Wgr.Nummer # vI;
      Erx # RecRead(819,1,0);
      RekRestore(v819);
      if (Erx=_rOK) then begin
        if (Msg(997009,aint(Wgr.Nummer)+'|'+aint(vI),_WinIcoWarning,_WinDialogYesNo, 2)<>_winidyes) then RETURN false;
        vMerge # true;
      end
      else begin
        if (Msg(997008,aint(Wgr.Nummer)+'|'+aint(vI),_WinIcoQuestion,_WinDialogYesNo, 2)<>_winidyes) then RETURN false;
      end;
      
      if (Wgr_Data:Edit.Nummer(Wgr.Nummer, vI, vMerge)) then begin
        RefreshList(gZllist, _WinLstFromFirst);
        Msg(999998,'',0,0,0);
      end;
      ErrorOutput;
    end;

   'Mnu.OSt' : begin
      if (Rechte[Rgt_OSt_Wgr]=n) then begin
        Msg(890000,'',0,0,0);
        RETURN true;
      end;
      Lib_COM:DisplayOSt( 'WGR:' + CnvAI( Wgr.Nummer ), -1, 'Warengruppe ' + AInt( Wgr.Nummer ) + ', ' + Wgr.Bezeichnung.L1 );
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;

    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
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
    'bt.Steuerart' :        Auswahl('Steuerart');
    'bt.Schrottartikel' :   Auswahl('Schrottartikel');
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
  Refreshmode();
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

  if ((aName =^ 'edWgr.Steuerschlssel') AND (aBuf->"Wgr.Steuerschlüssel"<>0)) then begin
    RekLink(813,819,1,0);   // Steuerschlüssel holen
    Lib_Guicom2:JumpToWindow('StS.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edWgr.Schrottartikel') AND (aBuf->Wgr.Schrottartikel<>'')) then begin
    RekLink(250,819,2,0);   // Schrottartikel holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================