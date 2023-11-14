@A+
//==== Business-Control ==================================================
//
//  Prozedur    HuB_EK_E_Main
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
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
  cTitle :    'Wareneingang: Hilfs- und Betriebsstoffe'
  cFile :     192
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'HuB_EK_E'
  cZList :    $ZL.HuB.EK.Eingang
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
  gKey      # cKey;
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
  vTmp  : int;
end;
begin

  if (aName='') then begin
    $Lb.Artikelnr->wpcaption    # HuB.EK.P.Artikelnr;
    $Lb.ArtikelSW->wpcaption    # HuB.EK.P.ArtikelSW;
    $Lb.Bestellung->wpcaption   # AInt(Hub.EK.E.EKNr);
    $Lb.Position->wpcaption     # AInt(Hub.EK.E.Position);
    $Lb.Nummer->wpcaption       # AInt(HuB.EK.E.Nummer)
    $Lb.Lieferant->wpcaption    # AInt(Hub.EK.P.Lieferant);
    $Lb.LieferSWort->wpcaption  # Hub.EK.P.LieferSW;
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  erx : int;
  vNr : int
end
begin
  // Felder Disablen durch:
  if (Mode=c_ModeEdit) then
    Lib_GuiCom:Disable($edHub.EK.E.Menge)
  else
    Lib_GuiCom:Enable($edHub.EK.E.Menge);

  if (Mode=c_ModeNew) then begin
    Erx # RecLink(192,191,1,_RecLast);
    If (Erx=_rNoRec) then
      vNr # 1
    else
      vNr # HuB.EK.E.Nummer + 1;
    RecBufClear(192);
    HuB.EK.E.EKNr # HuB.EK.P.EKNr;
    HuB.EK.E.Position # HuB.EK.P.Nummer;
    HuB.EK.E.Nummer # vNr;
    HuB.EK.E.Datum # sysdate();
    $Lb.MEH->wpcaption # HuB.EK.P.MEH;
  end;

  // Focus setzen auf Feld:
  $edHuB.EK.E.Datum->WinFocusSet(true);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vDiff : float;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung

  // Satz zurückspeichern & protokollieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
    end
  else begin
    HuB.EK.Anlage.Datum  # SysDate();
    HuB.EK.Anlage.Zeit   # Now;
    HuB.EK.Anlage.User   # gUserName;

    // BestellKopf holen
    Erx # RecLink(190,192,3,0);
    if (Erx=_rNoRec) then begin
      Msg(814000,gTitle,0,0,0);
      RETURN false;
    end;

    HuB.EK.E.Preis # HuB.EK.P.Preis / CnvFI(HuB.EK.P.PEH);
    if ("HuB.EK.WährungFixYN") then begin
      HuB.EK.E.PreisW1 # HuB.EK.E.Preis / "HuB.EK.Währungskurs";
      end;
    else begin
      if (Wae_Umrechnen(HuB.EK.E.Preis, "HuB.EK.Währung", var HuB.EK.E.PreisW1,1)=false) then
        RETURN false;
    end;

    TRANSON;

    // Lagerbewegung durchführen
    if (HuB_Data:MengenBewegung(HuB.EK.P.Artikelnr, HuB.EK.E.Menge,Translate('Wareneingang')+' '+AInt(HuB.EK.E.EKNr)+'/'+AInt(HuB.EK.E.Position)+' '+HuB.EK.P.LieferSW,HuB.EK.E.PreisW1,HuB.EK.E.Seriennr)=false) then begin
      TRANSBRK;
      RETURN false;
    end;

    // EK-Position updaten
    RecRead(191,1,_recLock);
    vDiff # HuB.EK.P.Menge.Best - HuB.EK.P.Menge.WE;
    if (vDiff<0.0) then vDiff # 0.0;
    HuB.EK.P.Menge.WE # HuB.EK.P.Menge.WE + HuB.EK.E.Menge;
    Erx # RekReplace(191,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // HuB-Artikel updaten
    Reclink(180,191,2,_recLock);
    if (HuB.EK.P.Menge.WE<=HuB.EK.P.Menge.Best) then
      HuB.Menge.Bestellt # HuB.Menge.Bestellt - HuB.EK.E.Menge
    else
      HuB.Menge.Bestellt # HuB.Menge.Bestellt - vDiff;

    Erx # RekReplace(180,_recunlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TRANSOFF;

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
begin
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_E_Anlegen]=n) OR
                          ("HuB.EK.Löschmarker" = '*') OR ("HuB.EK.P.Löschmarker" = '*');
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_E_Anlegen]=n) OR
                          ("HuB.EK.Löschmarker" = '*') OR ("HuB.EK.P.Löschmarker" = '*');

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_E_Aendern]=n) OR
                          ("HuB.EK.Löschmarker" = '*') OR ("HuB.EK.P.Löschmarker" = '*');
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_HuB_EK_E_Aendern]=n) OR
                          ("HuB.EK.Löschmarker" = '*') OR ("HuB.EK.P.Löschmarker" = '*');

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

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
      PtD_Main:View( gFile, HuB.EK.Anlage.Datum, HuB.EK.Anlage.Zeit, HuB.EK.Anlage.User );
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
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
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
  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================