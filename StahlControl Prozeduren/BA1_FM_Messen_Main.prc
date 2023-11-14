@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_Messen_Main
//                    OHNE E_R_G
//  Info
//
//
//  07.05.2021  AH  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//  20.07.2022  HA  Quick Jump
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
  cDialog :   $BA1.FM.Paket.Maske
  cTitle :    'Fertigmeldung'
  cFile :     707
  cMenuName : 'BA1.FM.Spulen.Bearbeiten'
  cPrefix :   'BA1_FM_Messen'
  cKey :      1
end;

declare RefreshIfm(opt aName : alpha)

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  Erx   : int;
  vHdl  : int;
  vM    : Float;
  vGew  : float;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # 0;//cZList;
  gKey      # cKey;

  w_NoList # true;

  Lib_Guicom2:Underline($edBAG.FM.Lagerplatz);

  SetStdAusFeld('edBAG.FM.Lagerplatz'     ,'Lagerplatz');
  SetStdAusFeld('edBAG.FM.AusfOben'       ,'AF.Oben');
  SetStdAusFeld('edBAG.FM.AusfUnten'      ,'AF.Unten');

  if (BAG.FM.Status=c_Status_frei) then begin
    $cb.Frei->wpCheckState # _WinStateChkChecked
  end
  else if (BAG.FM.Status =c_Status_BAGfertSperre) then
    $cb.gesperrt->wpCheckState # _WinStateChkChecked;

  // Analyse leeren
  RecBufClear(230);
  RecBufClear(231);
  if (BAG.FM.Analysenummer<>0) then begin
    Lys.K.Analysenr # BAG.FM.Analysenummer;
    Erx # RecRead(230,1,0);
    if (Erx<=_rLocked) then begin
      Erx # RecLink(231,230,1,_recFirst);   // 1. Lyse holen
    end
    else begin
      RecBufClear(230);
    end;
  end;

  RETURN App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin

  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;
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
  vTmp    : int;
end;
begin
 
  if (aName='') then begin
    if (BAG.FM.Status<>c_Status_BAGfertUnklar) then begin
      Lib_guiCom:Disable($cb.gesperrt);
      Lib_guiCom:Disable($cb.Frei);
    end;
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
  vTmp    : int;
end;
begin

  // Focus setzen auf Feld:
  vTmp # gMdi->winsearch('edBAG.FM.Datum');
  vTmp->WinFocusSet(true);
  w_LastFocus # vTmp;
  Erx # gMdi->winsearch('DUMMYNEW');
  Erx->wpcustom # AInt(vTmp);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vHdl        : int;
end;
begin

  if ($cb.Frei->wpCheckState=_WinStateChkChecked) then
    BAG.FM.Status # c_Status_frei
  else if ($cb.gesperrt->wpCheckState=_WinStateChkChecked) then
    BAG.FM.Status # c_Status_BAGfertSperre
  else
    BAG.FM.Status # c_Status_BAGfertUnklar;


  "BAG.FM.Stück"  # 1;

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  if (Lib_Faktura:Abschlusstest(BAG.FM.Datum) = false) then begin
    Msg(001400 ,Translate('Fertigmeldungsdatum') + '|'+ CnvAd(BAG.FM.Datum),0,0,0);

    vHdl # gMdi->winsearch('edBAG.FM.Datum');
    if (vHdl > 0) then begin
      $NB.Main->wpcurrent # 'NB.Page1';
      vHdl->WinFocusSet(true);
    end;

    RETURN false;
  end;

  if (BA1_FM_Messen:Save()=false) then
    RETURN false;
  
//  Msg(707001,'',0,0,0);

  // Ankerfunktion für z.B. Prüfung ob ein Arbeitsgang "fertig" ist und dann
  // abgeschlossen werden kann
  RunAFX('BAG.FM.Verbuchen.Post','');

  gSelected # 1;
  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  mode # c_modeClose;
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
local begin
  vHdl : int;
end;
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
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  if (aEvt:Obj=0) then RETURN true;

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
  vTmp    : int;
  vQ      : alpha(4000);
end;

begin

  case aBereich of

    'Lagerplatz' : begin
      RecBufClear(844);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',Here+':AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'AF.Oben'        : begin
/***
      RecBufClear(705);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung','BA1_FM_Maske_Main:AusAFOben');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, 'BAG.AF.Nummer'  , '=', BAG.FM.Nummer);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Position'  , '=', BAG.FM.Position);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Fertigung'  , '=', BAG.FM.Fertigung);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Fertigmeldung'  , '=', BAG.FM.Fertigmeldung);
      Lib_Sel:QAlpha(var vQ, 'BAG.AF.Seite'  , '=', '1');
      vTmp # SelCreate(705, gkey);
      Erx # vTmp->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vTmp);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vTmp,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vTmp;


      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.Position)+'|'+
        AInt(BAG.FM.Fertigung) + '|' + AInt(BAG.FM.Fertigmeldung) + '|1';
***/
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung','BA1_FM_Maske_Main:AusAFOben');
      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, BAG.FM.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.FM.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.FM.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, BAG.FM.Fertigmeldung);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '1');
      $ZL.BA1.AF->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.F.Nummer)+'|'+AInt(BAG.F.Position)+'|'+
        AInt(BAG.F.Fertigung)+'|'+aint(BAG.FM.Fertigmeldung)+'|1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AF.Unten'       : begin
      RecBufClear(705);
/***
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung','BA1_FM_Maske_Main:AusAFUnten');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, 'BAG.AF.Nummer'  , '=', BAG.FM.Nummer);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Position'  , '=', BAG.FM.Position);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Fertigung'  , '=', BAG.FM.Fertigung);
      Lib_Sel:QInt(var vQ, 'BAG.AF.Fertigmeldung'  , '=', BAG.FM.Fertigmeldung);
      Lib_Sel:QAlpha(var vQ, 'BAG.AF.Seite'  , '=', '2');
      vTmp # SelCreate(705, gkey);
      Erx # vTmp->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vTmp);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vTmp,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vTmp;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.Position)+'|'+
        AInt(BAG.FM.Fertigung) + '|' + AInt(BAG.FM.Fertigmeldung) + '|2';
***/
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung','BA1_FM_Maske_Main:AusAFUnten');
      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, BAG.FM.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.FM.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.FM.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, BAG.FM.Fertigmeldung);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '2');
      $ZL.BA1.AF->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.Position)+'|'+
        AInt(BAG.FM.Fertigung)+'|'+aint(BAG.FM.Fertigmeldung)+'|2';
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
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
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
  case (aMenuItem->wpName) of
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
    'bt.Lagerplatz'     :   Auswahl('Lagerplatz');
    'bt.AusfOben'       :   Auswahl('AF.Oben');
    'bt.AusfUnten'      :   Auswahl('AF.Unten');
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
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cb.gesperrt') and ($cb.gesperrt->wpCheckState=_WinStateChkChecked) then begin
    $cb.frei->wpCheckState # _WinStateChkunChecked;
  end;
  if (aEvt:Obj->wpname='cb.frei') and ($cb.frei->wpCheckState=_WinStateChkChecked) then begin
    $cb.gesperrt->wpCheckState # _WinStateChkunChecked;
  end;

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
begin
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
  
  if ((aName =^ 'edBAG.FM.Lagerplatz') AND (aBuf->BAG.FM.Lagerplatz<>'')) then begin
    LPl.Lagerplatz # BAG.FM.Lagerplatz;
    RecRead(844,1,0);
    Lib_Guicom2:JumpToWindow('LPl.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================