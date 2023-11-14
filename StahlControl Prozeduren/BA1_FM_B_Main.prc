@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_B_Main
//                    OHNE E_R_G
//  Info
//
//
//  05.03.2009  AI  Erstellung der Prozedur
//  26.03.2013  AI  BUG: Chargenauswahl
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusArtikel()
//    SUB AusCharge()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Beistellungen'
  cFile       :  708
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'BA1_FM_B'
  cZList      : $ZL.BA1.FM.Verbrauch
  cKey        : 1
end;

declare AusCharge()


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
  App_Main:EvtInit(aEvt);
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
  opt aChanged : logic;
)
local begin
  vTmp : int;
end;
begin

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
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $bt.Fehler.Ins->WinFocusSet(true);
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
local begin
  Erx : int;
end;
begin

  Erx # RecRead(708,0,_recid,cZList->wpDbRecId);
  if (Erx>_rLocked) then RETURN;
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(708,0,'MAN');
    cZList->winupdate(_WinUpdOn, _WinLstFromFirst);
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
  Erx     : int;
  vFilter : int;
  vHdl    : int;
  vQ      : alphA(4094);
end;
begin

  case aBereich of
    'Artikel' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Art.Verwaltung',here+':AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Charge' : begin
      RecBufClear(252);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Art.C.Verwaltung',here+':AusCharge');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
/*
      vFilter # RecFilterCreate(252,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,BAG.FM.B.Artikelnr);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq,0);
      vFilter->RecFilterAdd(4,_FltAND,_FltAbove,'');
      gZLList->wpDbFilter # vFilter;
      gKey # 1;
*/
      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', BAG.FM.B.Artikelnr);
      Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
      Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
      Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
      vHdl # SelCreate(252, gKey);
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


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
local begin
  Erx   : int;
  vLfd  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    RecbufClear(708);
    BAG.FM.B.Artikelnr    # Art.Nummer;
    if (RecLinkInfo(252,250,4,_RecCount)>1) and ("Art.ChargenführungYN") then begin
      Auswahl('Charge');
      end
    else begin
      // immer EIGENES Lager abbuchen
      FOR Erx # RecLink(252,250,4,_Recfirst)   // Chargen loopen
      LOOP Erx # RecLink(252,250,4,_RecNext);
      WHILE (Erx<=_rLocked) do begin
        if (Art.C.Charge.Intern<>'') and
          (Art.C.Adressnr=Set.EigeneAdressnr) and (Art.C.Anschriftnr=1) then begin
          gSelected # RecInfo(252,_recID);
          BREAK;
        end;
      END;
      if (gSelected<>0) then AusCharge();
     end;
  end;
  cZList->winupdate(_WinUpdOn, _WinLstFromFirst);
end;


//========================================================================
//  AusCharge
//
//========================================================================
sub AusCharge()
local begin
  Erx   : int;
  vLfd  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(252,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Erx # RecLink(708,707,12,_recLast);
    if (Erx>_rLocked) then vLfd # 1
    else vLfd # BAG.FM.B.lfdNr + 1;
    RecbufClear(708);
    BAG.FM.B.Nummer       # BAG.FM.Nummer;
    BAG.FM.B.Position     # BAG.FM.Position;
    BAG.FM.B.Fertigung    # BAG.FM.Fertigung;
    BAG.FM.B.Fertigmeld   # BAG.FM.Fertigmeldung;
    BAG.FM.B.Artikelnr    # Art.C.Artikelnr;
    BAG.FM.B.Art.Adresse  # Art.C.Adressnr;
    BAG.FM.B.Art.Anschr   # Art.C.Anschriftnr;
    BAG.FM.B.Art.Charge   # Art.C.Charge.intern;
    BAG.FM.B.Bemerkung    # Art.C.Bezeichnung;
    BAG.FM.B.Menge        # 0.0;
    BAG.FM.B.MEH          # Art.MEH;
    REPEAT
      if (Dlg_Standard:Menge(Translate('Menge')+' '+BAG.FM.B.MEH, var BAG.FM.B.Menge)=false) then RETURN;
      if (BAG.FM.B.Menge<=0.0) then Msg(708001,'',0,0,0);
    UNTIl (BAG.FM.B.Menge>0.0);
    REPEAT
      BAG.FM.B.lfdNr       # vLfd;
      Erx # Rekinsert(708,0,'MAN');
      if (Erx<>_rOK) then vLfd # vLfd + 1;
    UNTIL (Erx=_rOK);
    cZList->winupdate(_WinUpdOn, _WinLstFromFirst);
  end;
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
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_BAG_FM_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or ((Rechte[Rgt_BAG_Del_NachAbschluss]=n) and (Rechte[Rgt_BAG_Del_VorAbschluss]=n)) or (("BAG.Löschmarker" = '*') and (Rechte[Rgt_BAG_Del_VorAbschluss]=y) and (Rechte[Rgt_BAG_Del_NachAbschluss]=n));
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or ((Rechte[Rgt_BAG_Del_NachAbschluss]=n) and (Rechte[Rgt_BAG_Del_VorAbschluss]=n)) or (("BAG.Löschmarker" = '*') and (Rechte[Rgt_BAG_Del_VorAbschluss]=y) and (Rechte[Rgt_BAG_Del_NachAbschluss]=n));

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

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
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
    'bt.Verbrauch.Ins'  :   Auswahl('Artikel');
    'bt.Verbrauch.Del'  :   RecDel();
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
//========================================================================
//========================================================================
//========================================================================