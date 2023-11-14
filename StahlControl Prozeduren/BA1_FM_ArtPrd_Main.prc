@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_ArtPrd_Main
//                    OHNE E_R_G
//  Info
//
//
//  07.09.2012  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//  19.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLagerplatz()
//    SUB AusZustand()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic;) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG
@I:Def_Aktionen

define begin
  cDialog :   $BA1.FM.Maske
  cTitle :    'Fertigmeldung'
  cFile :     707
  cMenuName : 'BA1.FM.Maske.Bearbeiten'
  cPrefix :   'BA1_FM_ArtPrd'
  cKey :      1
  cZList2 :   $DL.Einsatz
end;

declare RefreshIfm(opt aName : alpha)
declare Wiegedaten()

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
  gZLList   # 0;//cZList;
  gKey      # cKey;

  Lib_Guicom2:Underline($edBAG.FM.Art.Zustand);
  Lib_Guicom2:Underline($edBAG.FM.Lagerplatz);

  SetStdAusFeld('edBAG.FM.Art.Zustand'    ,'Zustand');
  SetStdAusFeld('edBAG.FM.Lagerplatz'     ,'Lagerplatz');
  SetStdAusFeld('edBAG.FM.Artikelnr'      ,'Struktur');

  cZList2->wpColFocusBkg    # Set.Col.RList.Cursor;
  cZList2->wpColFocusOffBkg # "Set.Col.RList.CurOff";

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
  Lib_GuiCom:Pflichtfeld($edBAG.FM.Datum);
  Lib_GuiCom:Pflichtfeld($edBAG.FM.Menge);
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


  if (aName='') or (aName='edBAG.FM.Art.Zustand') then begin
    Erx # RecLink(856,707,16,_recfirst);  // Zustand holen
    if (Erx>_rLocked) then RecBufClear(856);
    $lb.Zustand->wpcaption # Art.Zst.Name;
  end;


  if (aName='') then begin

    // Artikel holen...
    Erx # RecLink(250,703,13,_recFirst);
    if (Erx>_rLocked) then RecBufClear(250);

    $lb.Artikel->wpcaption      # Art.Nummer;
    $lb.Stichwort->wpcaption    # Art.Stichwort;
    $lb.Bezeichnung1->wpcaption # Art.Bezeichnung1;
    $lb.Bezeichnung1->wpcaption # Art.Bezeichnung2;
    $lb.Bezeichnung1->wpcaption # Art.Bezeichnung3;


    // Mengen anzeigen
    $Lb.Menge.Soll->wpcaption   # ANum(BAG.F.Menge,"Set.Stellen.Menge");
    $Lb.Menge.Ist->wpcaption    # ANum(BAG.F.Fertig.Menge,"Set.Stellen.Menge");
    $Lb.Menge.Fehl->wpcaption   # ANum(BAG.F.Menge - BAG.F.Fertig.Menge,"Set.Stellen.Menge");

    $lb.MEH1->wpcaption   # BAG.F.MEH;
    $lb.MEH2->wpcaption   # BAG.F.MEH;
    $lb.MEH3->wpcaption   # BAG.F.MEH;
    $lb.MEH4->wpcaption   # BAG.F.MEH;
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
local begin
  Erx     : int;
  vA      : alpha;
  vFM     : int;
  vBuf707 : int;
  vSeite  : alpha;
  vFilter : int;
  vNummer : int;
  vBuf705 : int;
  vHdl    : int;
  vTmp : int;
end;
begin

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  RunAFX('BA1_FM_Maske_Main_RecInit','');

  // Vorbelegung
  vBuf707 # RecBufCreate(707);
  RecBufCopy(707,vBuf707);

  Erx # RecLink(707,703,10,_RecLast);   // letzte FM holen
  if (Erx<=_rLocked) then vFM # BAG.FM.Fertigmeldung
  else vFM # 1;
  RecBufCopy(vBuf707,707);
  RecBufDestroy(vbuf707);

  BAG.FM.Nummer         # myTmpNummer;
  BAG.FM.Position       # BAG.F.Position;
  BAG.FM.Fertigung      # BAG.F.Fertigung;
  BAG.FM.Fertigmeldung  # vFM;
  BAG.FM.Verwiegungart  # 1;
  BAG.FM.MEH            # BAG.F.MEH;
  BAG.FM.Materialtyp    # c_IO_Art;
  BAG.FM.Status         # 1;
  BAG.FM.Datum          # today;
  BAG.FM.Artikelnr      # BAG.F.Artikelnummer;



  // ********************  Rechtecheck *********************************

  // je nach Aktion Felder freischalten
  if (Mode=c_ModeNew) then begin
//    BA1_FM_Data:Vorbelegen();
  end;

  // Focus setzen auf Feld:
  vTmp # gMdi->winsearch('edBAG.FM.Menge');

  vTmp->WinFocusSet(true);
  w_LastFocus # vTmp;
  Erx # gMdi->winsearch('DUMMYNEW');
  Erx->wpcustom # cnvai(vTmp);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vBuf703 : int;
  vErx    : int;
  vF      : float;
  vI      : int;
  vOK     : logic;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  if (BAG.FM.Datum=0.0.0) then begin
    Msg(001200,Translate('Datum'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBAG.FM.Datum->WinFocusSet(true);
    RETURN false;
  end;

  // logische Prüfung
  if (BAG.FM.Menge<=0.0) then begin
    Msg(001200,Translate('Menge'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBAG.FM.Menge->WinFocusSet(true);
    RETURN false;
  end;

//Todo('Fertigmelden...kommt später!');
//$NB.Main->wpcurrent # 'NB.Page1';
//$edBAG.FM.Menge->WinFocusSet(true);
//return false;

  // Ankerfunktion
  if (RunAFX('BAG.FM.Recsave','ArtPrd')<>0) then begin
    if (AfxRes=111) then RETURN true;
    if (AfxRes<>_rOK) then RETURN false;
  end;

  // Nummernvergabe...
  // Fertigmeldung verbuchen
  if (BA1_Fertigmelden:Verbuchen(true, false)=false) then begin
    Error(707002,'');
    ErrorOutput;
    RETURN false;
  end;

  // Ankerfunktion für z.B. Prüfung ob ein Arbeitsgang "fertig" ist und dann
  // abgeschlossen werden kann
  RunAFX('BAG.FM.Verbuchen.Post','');

  Msg(707001,'',0,0,0);

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
local begin
  Erx : int;
end;
begin

  Erx # RecLink(710,707,10,_recFirst);    // Fehler loopen
  WHILE (Erx<=_rLocked) do begin
    RekDelete(710,0,'MAN');
    Erx # RecLink(710,707,10,_recFirst);
  END;

  Erx # RecLink(708,707,12,_recFirst);    // Bewegungen loopen
  WHILE (Erx<=_rLocked) do begin
    RekDelete(708,0,'MAN');
    Erx # RecLink(708,707,12,_recFirst);
  END;

  Erx # RecLink(705,707,13,_recFirst);    // Ausführungen loopen
  WHILE (Erx<=_rLocked) do begin
    RekDelete(705,0,'MAN');
    Erx # RecLink(705,707,13,_recFirst);
  END;

  // ALLE Positionen verwerfen
  RETURN true;
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
local begin
  vFak  : float;
  vLfd  : int;
  vOK   : logic;
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  if (aEvt:Obj->wpname='edBAG.FM.Menge') then begin
    if (BAG.FM.MEH='Stk') then "BAG.FM.Stück" # cnvif(BAG.FM.Menge)
    else if (BAG.FM.MEH='kg') then BAG.FM.Gewicht.Netto # Rnd(BAG.FM.Menge, Set.STellen.Gewicht);
    else if (BAG.FM.MEH='t') then BAG.FM.Gewicht.Netto # Rnd(BAG.FM.Menge * 1000.0, Set.STellen.Gewicht);
    BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto;

    // ggf. Einsatz automatisch anpassen
    if (cZList2->wpcustom='') then vOK # y;
else vOK # (Msg(99,'Soll Einsatz trotzdem neu berechnet werden?',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes);
    if (vOK) then begin
      BA1_F_ArtPrd_data:RecalcEinsatzToDL(BAG.FM.Menge, $DL.Einsatz);
      cZList2->wpcustom # '';
      cZList2->winupdate(_WinUpdOn, _WinLstFromFirst);
    end;
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
  vA      : alpha;
  vFilter : int;
  vTmp : int;
end;

begin

  case aBereich of

    'Zustand' : begin
      RecBufClear(856);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.ZSt.Verwaltung',here+':AusZustand');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lagerplatz' : begin
      RecBufClear(844);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',Here+':AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusLagerplatz
//
//========================================================================
sub AusLagerplatz()
begin

  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);

  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    gSelected # 0;
    BAG.FM.Lagerplatz # Lpl.Lagerplatz;
  end;

  // Focus auf Editfeld setzen:
  $edBAG.FM.Lagerplatz->Winfocusset(true);
end;


//========================================================================
//  AusZustand
//
//========================================================================
sub AusZustand();
begin
  if (gSelected<>0) then begin
    RecRead(856,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.FM.Art.Zustand # Art.Zst.Nummer;

    gTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (gTMP<>0) then gTMP->Winupdate(_WinUpdFld2Obj);
  end;
  $edBAG.FM.Art.Zustand->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.F.AutomatischYN) or (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

  vHdl # gMdi->WinSearch('bt.AusfOben');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_AF]=n);

  vHdl # gMdi->WinSearch('bt.AusfUnten');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_AF]=n);

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
  vTmp : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

end;


//========================================================================
// EvtKeyItem
//
//========================================================================
sub EvtKeyItem(
  aEvt                 : event;    // Ereignis
  aKey                 : int;      // Taste
  aID                  : int;      // RecID bei RecList, Node-Deskriptor bei TreeView, Focus-Objekt bei Frame und AppFrame
) : logic;
begin

  if (aKey=_WinKeyReturn) then
    BA1_F_ArtPrd_Data:EinsatzEdit(cZList2, aID)
  else if (aKey=_WinKeyDelete) then
    BA1_F_ArtPrd_Data:EinsatzDel(cZList2, aID)
  else if (aKey=_WinKeyInsert) then
    BA1_F_ArtPrd_Data:EinsatzIns(cZList2);

  RETURN(true);
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
    'bt.Zustand'        : Auswahl('Zustand');
    'bt.Lagerplatz'     : Auswahl('Lagerplatz');

    'bt.Verbrauch.Edit' : BA1_F_ArtPrd_Data:EinsatzEdit(cZList2,_WinLstDatLineCurrent);
    'bt.Verbrauch.Ins'  : BA1_F_ArtPrd_Data:EinsatzIns(cZList2);
    'bt.Verbrauch.Del'  : BA1_F_ArtPrd_Data:EinsatzDel(cZList2,_WinLstDatLineCurrent);
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
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

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
) : logic;
local begin
  vM1 : float;
  vM2 : float;
  vC  : alpha;
end;
begin
  if (aEvt:obj=cZList2) then begin
    WinLstCellGet(aEvt:obj,vC,2,aRecID);
    WinLstCellGet(aEvt:obj,vM1,3,aRecID);
    WinLstCellGet(aEvt:obj,vM2,4,aRecID);

    if (vC='') then
      $clmCharge->wpClmColBkg # _WinColLightRed
    else
      $clmCharge->wpClmColBkg # _WinColWhite;

    if (vM1-vM2<>0.0) then
      $clmMengeIst->wpClmColBkg # _WinColLightRed
    else
      $clmMengeIst->wpClmColBkg # _WinColWhite;
  end;

  RETURN(true);
//  Refreshmode(y);
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

  if ((aName =^ 'edBAG.FM.Art.Zustand') AND (aBuf->BAG.FM.Art.Zustand<>0)) then begin
    RekLink(856,707,16,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Art.ZSt.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edBAG.FM.Lagerplatz') AND (aBuf->BAG.FM.Lagerplatz<>'')) then begin
    LPl.Lagerplatz # BAG.FM.Lagerplatz;
    RecRead(844,1,0);
    Lib_Guicom2:JumpToWindow('LPl.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================