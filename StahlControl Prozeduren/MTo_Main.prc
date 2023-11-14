@A+
//==== Business-Control ==================================================
//
//  Prozedur    MTo_Main
//                  OHNE E_R_G
//  Info
//    Steuert die Abmessungstoleranzenverwaltung
//
//  06.10.2003  ST  Erstellung der Prozedur
//  10.09.2008  PW  Checkboxen
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  28.07.2016  AH  Alle drei Haken können gesetzt werden
//  2022-06-28  AH  ERX
//  25,07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit(opt aBehalten : logic);
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusWarengruppe()
//    SUB AusQualitaeten()
//    SUB AusGuetenstufe()
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

define begin
  cTitle :    'Abmessungstoleranzen'
  cFile :     834
  cMenuName : 'STD.Bearbeiten'
  cPrefix :   'MTo'
  cZList :    $ZL.AbmToleranzen
  cListen :   'Abmessungstoleranzen'
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
  w_Listen  # cListen;
  gKey      # cKey;

Lib_Guicom2:Underline($edMTo.Warengruppe);
Lib_Guicom2:Underline($edMTo.Gtenstufe);
Lib_Guicom2:Underline($edMTo.Werkstoffnr);

  SetStdAusFeld('edMTo.Warengruppe' ,'Warengruppe');
  SetStdAusFeld('edMTo.Werkstoffnr' ,'Qualitaeten');
  SetStdAusFeld('edMTo.Gtenstufe'   ,'Guetenstufe');

  App_Main:EvtInit(aEvt);
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
  if (aName='') or (aName='edMTo.Warengruppe') then begin
     Wgr.Nummer # MTo.Warengruppe;
    if (RecRead(819,1,0) <= _rLocked) then
      $Lb.Warengruppe -> wpcaption # Wgr.Bezeichnung.L1;
    else
      $Lb.Warengruppe -> wpcaption # '';
  end;

  if (aName='') or (aName='edMTo.Gtenstufe') then begin
    Erx # RecLink(848,834,1,_reCFirst);   // Stufe holen
    if (Erx>=_rLocked) then RecBufClear(848);
    $lb.Guetenstufe->wpcaption # MQu.S.Name;
  end;


  if (aName='' or (aName='Lb.ID')) then begin
    if (MTo.ID <> 0) then
      $Lb.ID -> wpCaption # AInt(MTo.ID)
     else
      $Lb.ID -> wpCaption # '';
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if ( Mode = c_ModeEdit ) or ( Mode = c_ModeNew ) and ( ( aName = '' ) or ( strCut( aName, 1, 11 ) = 'chkMTo.Glt.' ) ) then begin
    if ( aName != '' ) then begin
      $chkMTo.Glt.Dicke->winUpdate( _winUpdFld2Obj );
      $chkMTo.Glt.Breite->winUpdate( _winUpdFld2Obj );
      $chkMTo.Glt.Laenge->winUpdate( _winUpdFld2Obj );
    end;

    if ( "MTo.Gültig.DickeYN" ) then begin
      Lib_Guicom:Enable( $edMTo.DickenTol.Von );
      Lib_Guicom:Enable( $edMTo.DickenTol.Bis );
      Lib_Guicom:Enable( $cbMTo.DickeProzentYN );
    end
    else begin
      Lib_Guicom:Disable( $edMTo.DickenTol.Von );
      Lib_Guicom:Disable( $edMTo.DickenTol.Bis );
      Lib_Guicom:Disable( $cbMTo.DickeProzentYN );
    end;

    if ( "MTo.Gültig.BreiteYN" ) then begin
      Lib_Guicom:Enable( $edMTo.BreitenTol.Von );
      Lib_Guicom:Enable( $edMTo.BreitenTol.Bis );
      Lib_Guicom:Enable( $cbMTo.BreiteProzentYN );
    end
    else begin
      Lib_Guicom:Disable( $edMTo.BreitenTol.Von );
      Lib_Guicom:Disable( $edMTo.BreitenTol.Bis );
      Lib_Guicom:Disable( $cbMTo.BreiteProzentYN );
    end;

    if ( "MTo.Gültig.LängeYN" ) then begin
      Lib_Guicom:Enable( $edMTo.LaengenTol.Von );
      Lib_Guicom:Enable( $edMTo.LaengenTol.Bis );
      Lib_Guicom:Enable( $cbMTo.LngeProzentYN );
    end
    else begin
      Lib_Guicom:Disable( $edMTo.LaengenTol.Von );
      Lib_Guicom:Disable( $edMTo.LaengenTol.Bis );
      Lib_Guicom:Disable( $cbMTo.LngeProzentYN );
    end;
  end;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit(opt aBehalten : logic);
local begin
  vID : int;
  vNr : int;
end;
begin

  if (Mode=c_ModeNew) then begin
    if (aBehalten) then begin
      vNr # MTo.ID;
      w_BinKopieVonDatei  # gFile;
      w_BinKopieVonRecID  # RecInfo(gFile, _recid);
    end;
    RecRead(834,1,_recLast);
    vID # MTo.ID + 1;
    RecBufClear(834);
    if (vNr<>0) then begin
      MTO.ID # vNr;
      RecRead(834,1,0);
    end;
    MTo.ID # vID;
    RefreshIfm('Lb.ID');
  end;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edMTo.Name->WinFocusSet(true);
  RefreshIfm('Lb.ID');
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

    // Weitere neue Einträge?
    if (Msg(000009,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
      RecInit(y);
      RETURN false;
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
  vA    : alpha;
end;

begin

  case aBereich of

    'Warengruppe' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Qualitaeten' : begin
      RecBufClear(832);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusQualitaeten');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Guetenstufe' : begin
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenstufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    MTo.Warengruppe # Wgr.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edMTo.Warengruppe->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMTo.Warengruppe');
end;


//========================================================================
//  AusQualitäten
//
//========================================================================
sub AusQualitaeten()
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    MTo.Werkstoffnr # MQu.Werkstoffnr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edMTo.Werkstoffnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMTo.Werkstoffnr');
end;


//========================================================================
//  AusGuetenstufe
//
//========================================================================
sub AusGuetenstufe()
begin
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "MTo.Gütenstufe" # MQu.S.Stufe;
  end;
  // Focus auf Editfeld setzen:
  $edMTo.Gtenstufe->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MTo_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MTo_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MTo_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MTo_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MTo_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_MTo_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


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

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Warengruppe' :  Auswahl('Warengruppe');
    'bt.Werkstoffnr' :  Auswahl('Qualitaeten');
    'bt.Guetenstufe' :  Auswahl('Guetenstufe');
  end;
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged
(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vName   : alpha;
  vTxtHdl : int;
end;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if ( Mode = c_ModeView ) or ( aEvt:Obj->wpCheckState = _winStateChkUnchecked ) then
    RETURN true;

  case ( aEvt:Obj->wpName ) of
    'chkMTo.Glt.Dicke'  : begin
//      "MTo.Gültig.BreiteYN" # false;
//      "MTo.Gültig.LängeYN"  # false;
    end;
    'chkMTo.Glt.Breite' : begin
//      "MTo.Gültig.DickeYN"  # false;
//      "MTo.Gültig.LängeYN"  # false;
    end;
    'chkMTo.Glt.Laenge' : begin
//      "MTo.Gültig.DickeYN"  # false;
//      "MTo.Gültig.BreiteYN" # false;
    end;
  end;

  RefreshIfm( 'chkMTo.Glt.Change' );
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
  RETURN true;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edMTo.Warengruppe') AND (aBuf->MTo.Warengruppe<>0)) then begin
    Wgr.Nummer # MTo.Warengruppe;
    RecRead(819,3,0);
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMTo.Gtenstufe') AND (aBuf->"MTo.Gütenstufe"<>'')) then begin
    RekLink(848,834,1,0);   // Gütenstufe holen
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMTo.Werkstoffnr') AND (aBuf->MTo.Werkstoffnr<>'')) then begin
    MQu.Werkstoffnr # MTo.Werkstoffnr;
    RecRead(832,4,0);
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================