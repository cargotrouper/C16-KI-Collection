@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_Paket_Main
//                    OHNE E_R_G
//  Info
//
//
//  22.04.2021  AH  Erstellung der Prozedur
//  27.07.2021  AH  ERX
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
//    SUB AusArtikel()
//    SUB AusStruktur()
//    SUB Wiegedaten()
//    SUB AusVerwiegungsart()
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
  cPrefix :   'BA1_FM_Paket'
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

 Lib_Guicom2:Underline($edBAG.FM.Verwiegungart);
 Lib_Guicom2:Underline($edBAG.FM.Lagerplatz);

  SetStdAusFeld('edBAG.FM.Verwiegungart'  ,'Verwiegungsart');
  SetStdAusFeld('edBAG.FM.Lagerplatz'     ,'Lagerplatz');

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
  Erx : int;
  va : alphA;
  vX : int;

  vBB   : float;
  vBL   : float;
  vBGew : float;
  vBM   : float;
  vL    : float;
  vGew  : float;
  vM    : float;

  vInStk  : int;
  vInGew  : float;
  vInME   : float;
  vOutME  : float;
  vBuf701 : int;
  vBuf707 : int;
  vHdl    : handle;
  vTmp    : int;
  vItem   : handle;
end;
begin

  if (aName='') or (aName='edBAG.FM.Verwiegungart') then begin
    erx # RecLink(818,707,6,_recfirst);
    if (erx>_rLocked) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;
    $lb.Verwiegungsart->wpcaption # VWa.Bezeichnung.L1;
  end;


  if (aName='') then begin

    vBuf701 # RekSave(701);
    BA1_F_Data:SumInput(BAG.F.MEH);
    RekRestore(vBuf701);

    if (BAG.IO.MEH.Out=BAG.F.MEH) then begin
      vOutME # BAG.IO.Ist.Out.Menge;
    end
    else begin
      vBuf707 # RekSave(707);
      erx # RecLink(707,703,10,_RecFirst);    // Fertigmeldungen loopen
      WHILE (erx<=_rLocked) do begin
        vOutME # vOutME + BAG.FM.Menge;
        erx # RecLink(707,703,10,_recNext);
      END;
      RekRestore(vBuf707);
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
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);


  // ********************  Rechtecheck *********************************
  // Je nach Berechtigung können z.B. die Abmessungen eingegeben werden
  // oder nicht.
  begin
    if (Rechte[Rgt_BAG_FM_Brutto]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Gewicht.Brutt);

    if (Rechte[Rgt_BAG_FM_Netto]=n) then
      Lib_GuiCom:Disable($edBAG.FM.Gewicht.Netto);

    if(Rechte[Rgt_BAG_FM_Tara] = false) then
      Lib_GuiCom:Disable($edTara);
  end; // Rechtecheck


  // je nach Aktion Felder freischalten
  if (Mode=c_ModeNew) then begin
    //Vorbelegen();04.04.2016 AH
    BA1_FM_Data:Vorbelegen();
  end;

  // Focus setzen auf Feld:
  vTmp # gMdi->winsearch('edBAG.FM.Gewicht.Brutt');
  vTmp->WinFocusSet(true);
  w_LastFocus # vTmp;
  erx # gMdi->winsearch('DUMMYNEW');
  erx->wpcustom # AInt(vTmp);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vBuf703     : int;
  verx        : int;
  vHdl        : int;
  vTmp        : int;
  vI,vJ       : int;
  vAnz        : int;
  vInputList  : handle;
end;
begin

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

  // logische Prüfung
  If (BAG.fM.Gewicht.Netto=0.0 and BAG.FM.Gewicht.Brutt=0.0) then begin
    Msg(001200,Translate('Wiegung'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBAG.FM.Gewicht.Netto->WinFocusSet(true);
    RETURN false;
  end;

  // fehlende Gewichte errechnen
  if ("Set.BA.FM.!CalcGewYN"=false) then begin
    if (BAG.FM.Gewicht.Brutt = 0.0) AND (BAG.FM.Gewicht.Netto <> 0.0) then
      BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto;

    if (BAG.FM.Gewicht.Brutt <> 0.0) AND (BAG.FM.Gewicht.Netto = 0.0) then
      BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt;
  end;

  // Ankerfunktion
  if (RunAFX('BAG.FM.Recsave','Paket')<>0) then begin
    if (AfxRes=111) then RETURN true;
    if (AfxRes<>_rOK) then RETURN false;
  end;

  // Nummernvergabe...
  // Fertigmeldung verbuchen
  vTmp # Winsearch(gMDI,'hdl.Inputlist');
  vInputList # Cnvia(vTmp->wpcustom);
  if (BA1_Fertigmelden:VerbuchenPaket(0, vInputList, true)=false) then begin
    Error(707002,'');
    ErrorOutput;
    RETURN false;
  end;

  if (vInputList<>0) then begin
    vInputList->CteClear(true);
    Cteclose(vInputList);
  end;

  Msg(707001,'',0,0,0);

  // Ankerfunktion für z.B. Prüfung ob ein Arbeitsgang "fertig" ist und dann
  // abgeschlossen werden kann
  RunAFX('BAG.FM.Verbuchen.Post','');

// 2022-11-30 AH ist in der BA1_Fertigmelden:VerbuchenPaket  Lib_Dokumente:Printform(200,'PaketEtikett',false);


  gSelected # 1;
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

  erx # RecLink(710,707,10,_recFirst);    // Fehler loopen
  WHILE (erx<=_rLocked) do begin
    RekDelete(710,0,'MAN');
    erx # RecLink(710,707,10,_recFirst);
  END;

  erx # RecLink(708,707,12,_recFirst);    // Bewegungen loopen
  WHILE (erx<=_rLocked) do begin
    RekDelete(708,0,'MAN');
    erx # RecLink(708,707,12,_recFirst);
  END;

  erx # RecLink(705,707,13,_recFirst);    // Ausführungen loopen
  WHILE (erx<=_rLocked) do begin
    RekDelete(705,0,'MAN');
    erx # RecLink(705,707,13,_recFirst);
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
  Erx : int;
  vS  : int;
  vL  : float;
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);


  if (aEvt:Obj=0) then RETURN true;

  vS # WinInfo(aEvt:Obj,_Wintype);
  if ((vS=_WinTypeEdit) or (vS=_WinTypeFloatEdit) or (vS=_WinTypeIntEdit)) then
    if (aEvt:obj->wpchanged) then begin

    erx # RecLink(818,707,6,_recfirst);     // Verwiegungsart holen
    if (erx>_rLocked) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;

    case (aEvt:Obj->wpname) of

      'edTara' : begin
        if (VWa.NettoYN=VWa.BruttoYN) and (VWa.NettoYN=false) then begin
          if (BAG.FM.Gewicht.Brutt=0.0) then
            BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto + aEvt:Obj->wpcaptionfloat
          else
            BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt - aEvt:Obj->wpcaptionfloat;
        end
        else if (VWa.NettoYN) then begin
          BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto + aEvt:Obj->wpcaptionfloat
        end if (VWa.BruttoYN) then begin
          BAG.FM.Gewicht.Netto # BAG.FM.Gewicht.Brutt - aEvt:Obj->wpcaptionfloat
        end;

        $edBAG.FM.Gewicht.Netto->winupdate(_WinUpdFld2Obj);
        $edBAG.FM.Gewicht.Brutt->winupdate(_WinUpdFld2Obj);
      end;

    end;  // case


    erx # RecLink(819,703,5,0);   // Warengruppe holen
    vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Netto, 1, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 707) , "Wgr.TränenKGproQM");

    If (BAG.P.Aktion <> c_BAG_AbLaeng) or (BAG.FM.Menge =0.0) then begin
      if (BAG.FM.MEH='qm') then
        BAG.FM.Menge # BAG.F.Breite * Cnvfi("BAG.FM.Stück") * vL / 1000000.0;
      if (BAG.FM.MEH='Stk') then
        BAG.FM.Menge # cnvfi("BAG.FM.Stück");
      if (BAG.FM.MEH='kg') then
        BAG.FM.Menge # Bag.FM.Gewicht.Netto;
      if (BAG.FM.MEH='t') then
        BAG.FM.Menge # Bag.FM.Gewicht.Netto / 1000.0;
      if (BAG.FM.MEH='m') or (BAG.FM.MEH='lfdm') then
        BAG.FM.Menge # /*cnvfi("BAG.FM.Stück") * */ vL / 1000.0;
    end;

    // Netto und Bruttoangaben dürfen nicht abweichen
    if  (BAG.FM.Verwiegungart = 2) AND
        (BAG.FM.Gewicht.Netto <> 0.0) AND
        ((BAG.FM.Gewicht.Brutt = BAG.FM.Gewicht.Netto) OR (BAG.FM.Gewicht.Brutt = 0.0))
        then begin
      Msg(707005,'',0,0,0);
//      BAG.FM.Gewicht.Brutt # 0.0;
      $edBAG.FM.Gewicht.Brutt->winupdate(_WinUpdFld2Obj);
      $edBAG.FM.Gewicht.Brutt->WinFocusSet();
    end;

  end;


  if (BAG.FM.Gewicht.Netto<>0.0) and (BAG.FM.Gewicht.Brutt<>0.0) then
    $edTara->wpcaptionfloat # BAG.FM.Gewicht.Brutt - BAG.FM.Gewicht.Netto;

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
end;

begin

  case aBereich of

    'Verwiegungsart' : begin
      RecBufClear(818);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VwA.Verwaltung',Here+':AusVerwiegungsart');
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
//  AusVerwiegungsart
//
//========================================================================
sub AusVerwiegungsart()
begin

  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);

  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    gSelected # 0;
    BAG.FM.Verwiegungart # VWA.Nummer;
  end;

  // Focus auf Editfeld setzen:
  $edBAG.FM.Verwiegungart->Winfocusset(true);
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
//  Wiegedaten
//          Liest Wiegedaten aus Datei ein
//========================================================================
sub Wiegedaten()
local begin
end;
begin
  RunAFX('BAG.Waage','');
  RefreshIfm();
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
    'bt.Verwiegungsart' :   Auswahl('Verwiegungsart');
    'bt.Lagerplatz'     :   Auswahl('Lagerplatz');
    'bt.Waage'          :   Wiegedaten();
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

  if (aEvt:Obj->wpname='cb.gesperrt') and ($cb.gesperrt->wpCheckState=_WinStateChkChecked) then begin
    $cb.Ausfall->wpCheckState # _WinStateChkunChecked;
    BAG.FM.Status # c_Status_BAGfertSperre;
  end;
  if (aEvt:Obj->wpname='cb.Ausfall') and ($cb.Ausfall->wpCheckState=_WinStateChkChecked) then begin
    $cb.gesperrt->wpCheckState # _WinStateChkunChecked;
    BAG.FM.Status # c_Status_BAGAusfall;
  end;
  if ($cb.gesperrt->wpCheckState=_WinStateChkUnChecked) and
    ($cb.Ausfall->wpCheckState=_WinStateChkUnChecked) then begin
    BAG.FM.Status # c_Status_Frei;
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

  if ((aName =^ 'edBAG.FM.Verwiegungart') AND (aBuf->BAG.FM.Verwiegungart<>0)) then begin
    RekLink(818,707,6,0);   // Verwaigungsart holen
    Lib_Guicom2:JumpToWindow('VwA.Verwaltun');
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