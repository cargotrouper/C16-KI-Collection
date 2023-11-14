@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_List_Main
//                    OHNE E_R_G
//  Info
//
//
//  2022-10-14  AH  Erstellung der Prozedur
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
  cDialog :   $BA1.FM.List
  cTitle :    'Fertigmeldung'
  cFile :     707
  cMenuName : 'BA1.FM.Maske.Bearbeiten'
  cPrefix :   'BA1_FM_List'
  cKey :      1

  cClmID      : 1
  cClmFert    : 2
  cClmArt     : 3
  cCLmGuete   : 4
  cClmAbm     : 5
  cClmKomm    : 6
  cClmKunde   : 7
  cCLmSollStk : 8
  cClmSollGew : 9
  cClmIstStk  : 10
  cClmIstGew  : 11
  cClmEinzel  : 12
  cClmFertStk : 13
  cClmFertGew : 14
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
  Erx     : int;
  vHdl    : int;
  vDL     : int;
  vTmp    : int;
  vA      : alpha(200);
  vX      : float;
  v701    : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # 0;//cZList;
  gKey      # cKey;

    WinSearchPath(aEvt:obj);

    // Einsatz anzeigen
    $Lb.Guete.E->wpcaption      # "BAG.IO.Güte";
    $Lb.GuetenStufe.E->wpcaption # "BAG.IO.GütenStufe";
    $Lb.Dicke.E->wpcaption      # ANum(BAG.IO.Dicke,"Set.Stellen.Dicke");
    $Lb.Breite.E->wpcaption     # ANum(BAG.IO.Breite,"Set.Stellen.Breite");
    if (Abs("BAG.IO.Länge")>9999.99) then begin
      $lb.LenMEH_E->wpcaption    # 'm';
      $Lb.Laenge.E->wpcaption   # ANum("BAG.IO.Länge"/1000.0,"Set.Stellen.Länge");
    end
    else begin
      $lb.LenMEH_E->wpcaption    # 'mm';
      $Lb.Laenge.E->wpcaption   # ANum("BAG.IO.Länge","Set.Stellen.Länge");
    end;
    $Lb.Dickentol.E->wpcaption  # BAG.IO.Dickentol;
    $Lb.Breitentol.E->wpcaption # BAG.IO.Breitentol;
    $Lb.Laengentol.E->wpcaption # "BAG.IO.Längentol";

    $Lb.Stueck.E->wpcaption     # AInt(BAG.IO.Plan.Out.Stk);
    $Lb.Gewicht.E->wpcaption    # ANum(BAG.IO.Plan.Out.GewB, "Set.Stellen.Gewicht");

  vHdl # aEvt:obj;
  vDL # vHdl->WinSearch('dl.Output');
/*
  vTmp # Winsearch(vHdl2, 'clm.Dicke');
  vTmp->wpFmtPostComma # Set.Stellen.Dicke;
  vTmp # Winsearch(vHdl2, 'clm.Breite');
  vTmp->wpFmtPostComma # Set.Stellen.Breite;
  vTmp # Winsearch(vHdl2, 'clm.Gewicht');
  vTmp->wpFmtPostComma # Set.Stellen.Gewicht;
  vTmp # Winsearch(vHdl2, 'clm.Gewicht.Rest');
  vTmp->wpFmtPostComma # Set.Stellen.Gewicht;
  vTmp # Winsearch(vHdl2, 'clm.Gewicht.Einsatz');
  vTmp->wpFmtPostComma # Set.Stellen.Gewicht;
  vTmp # Winsearch(vHdl2, 'clm.Menge');
  vTmp->wpFmtPostComma # Set.Stellen.Menge;
  vTmp # Winsearch(vHdl2, 'clm.Menge.Rest');
  vTmp->wpFmtPostComma # Set.Stellen.Menge;
  Erx # RecLink(701,702,2,_RecFirst);
*/

  v701 # RekSave(701);
  // Dataliste füllen ------------------------------
  FOR Erx # RecLink(701,702,3,_recFirst) // Outputs loopen
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.VonFertigmeld<>0) then CYCLE;

    // 2023-02-08 AH : nur von diesem Input
    if (BAG.IO.VOnID<>0) and (BAG.IO.VonID<>v701->Bag.IO.ID) then CYCLE;

    Erx # RecLink(703,701,3,_recFirst); // Fertigung holen

    vDL->WinLstDatLineAdd(BAG.IO.ID);
    vDL->WinLstCellSet(BAG.F.Fertigung            , cClmFert,  _WinLstDatLineLast);
    vDL->WinLstCellSet(BAG.F.Artikelnummer        , cClmArt,  _WinLstDatLineLast);
    vDL->WinLstCellSet("BAG.IO.Güte"              , cClmGuete,  _WinLstDatLineLast);
    vA # anum(BAG.F.Dicke, Set.stellen.Dicke);
    if (BAG.F.Breite<>0.0) then begin
      vA # vA + ' x ' +anum(BAG.F.Breite, Set.Stellen.Breite);
      if ("BAG.F.Länge"<>0.0) then begin
        vA # vA + ' x '+anum("BAG.F.Länge", "Set.Stellen.länge");
      end;
    end;
    vDL->WinLstCellSet(vA                         , cClmAbm,  _WinLstDatLineLast);
    vDL->WinLstCellSet(BAG.F.Kommission           , cClmKomm,  _WinLstDatLineLast);
    RecbufClear(401);
    if (BAG.F.Auftragsnummer<>0) then begin
      Auf_Data:Read(BAG.F.Auftragsnummer, BAG.F.Auftragspos, false);
      vDL->WinLstCellSet(Auf.P.KundenSW           , cClmKunde,  _WinLstDatLineLast);
    end;
    vDL->WinLstCellSet("BAG.F.Stückzahl"          , cClmSollStk,  _WinLstDatLineLast);
    vDL->WinLstCellSet("BAG.F.Gewicht"            , cClmSollGew,  _WinLstDatLineLast);
    vDL->WinLstCellSet("BAG.F.Fertig.Stk"         , cClmIstStk,  _WinLstDatLineLast);
    vDL->WinLstCellSet("BAG.F.Fertig.Gew"         , cClmIstGew,  _WinLstDatLineLast);
    DivOrNull(vX, BAG.F.Gewicht, cnvfi("BAG.F.Stückzahl"), 0);
    vDL->WinLstCellSet(vX                         , cClmEinzel,  _WinLstDatLineLast);

  END;
  vDL->wpcurrentint # 1;
  RekRestore(v701);

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
  BAG.FM.Materialtyp    # c_IO_Mat;
  BAG.FM.Status         # 1;
  BAG.FM.Datum          # today;
  BAG.FM.Artikelnr      # BAG.F.Artikelnummer;



  // ********************  Rechtecheck *********************************

  // je nach Aktion Felder freischalten
  if (Mode=c_ModeNew) then begin
//    BA1_FM_Data:Vorbelegen();
  end;

  // Focus setzen auf Feld:
  vTmp # gMdi->winsearch('dl.Output');
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
  Erx           : int;
  vStk          : int;
  vGew          : float;
  vDL           : int;
  vI            : int;
  vFert         : int;
  v707          : int;
  vL            : float;
  vEtkTxt       : int;
  vA            : alpha;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  if (BAG.FM.Datum=0.0.0) then begin
    Lib_Guicom2:InhaltFehlt('Datum', 'NB.Page1', 'edBAG.FM.Datum');
    RETURN false;
  end;


  vDL # $dl.Output;
  if (vDL=0) then RETURN false;

  vEtkTxt # TextOpen(20);

  v707 # RekSave(707);
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin

    vDL->WinLstCellGet(BAG.FM.OutputID,     cClmID, vI);
    vDL->WinLstCellGet(vFert,     cClmFert, vI);
    vDL->WinLstCellGet(vStk,      cClmFertStk, vI);
    vDL->WinLstCellGet(vGew,      cClmFertGew, vI);
//Msg(99,aint(vfert)+'.  : '+aint(vStk)+'stk '+anum(vGew,0)+'kg',0,0,0);

//debugx('KEY200 KEY703 '+aint(BAG.IO.Nummer)+'/'+aint(BAG.IO.ID)+'ID, '+aint(vfert)+'fert  : '+aint(vStk)+'stk '+anum(vGew,0)+'kg');
    BAG.F.Nummer    # BAG.P.Nummer;
    BAG.F.Position  # BAG.P.Position;
    BAG.F.Fertigung # vFert;
    Erx # RecRead(703,1,0);

    BA1_FM_Data:Vorbelegen();

    BAG.FM.Fertigung # vFert;
    "BAG.FM.Stück" # vStk;
    BAG.FM.Gewicht.Brutt # vGew;
    BAG.FM.Gewicht.Netto # vGew;
    BAG.FM.BruderID # BAG.FM.OutputId;
    vL # "BAG.FM.Länge";
    if (vL=0.0) then begin
      Erx # RecLink(819,703,5,0);   // Warengruppe holen
      vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Netto, "BAG.FM.Stück", BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKGproQM");
      if(BAG.FM.Gewicht.Netto = 0.0) then // MS 28.12.2009
        vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Brutt, "BAG.FM.Stück", BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKGproQM");
    end;

    if (BAG.FM.MEH='qm') then
      BAG.FM.Menge # BAG.FM.Breite * Cnvfi("BAG.FM.Stück") * vL / 1000000.0;
    if (BAG.FM.MEH='Stk') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück");
    if (BAG.FM.MEH='kg') then
      BAG.FM.Menge # Bag.FM.Gewicht.Netto;
    if (BAG.FM.MEH='t') then
      BAG.FM.Menge # Bag.FM.Gewicht.Netto / 1000.0;
    if (BAG.FM.MEH='m') or (BAG.FM.MEH='lfdm') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück") * vL / 1000.0;

    // Verbuchen...
    if (BA1_Fertigmelden:Verbuchen(true, false, true, vEtktxt)=false) then begin
      RekRestore(v707);
      Error(707002,'');
      ErrorOutput;
      TextClose(vEtkTxt);
      RETURN false;
    end;

    // Ankerfunktion für z.B. Prüfung ob ein Arbeitsgang "fertig" ist und dann
    // abgeschlossen werden kann
    RunAFX('BAG.FM.Verbuchen.Post','');

    RecBufCopy(v707,707);
  END;

  RecBufDestroy(v707)

  // Etikettendruck....
  Ba1_Fertigmelden:EtkDruckAusTxt(vEtkTxt);
  TextClose(vEtkTxt);

  Msg(707001,'',0,0,0);

  if ($cb.Abschluss->wpcheckState=_WinStateChkChecked) then begin
    BA1_Fertigmelden:AbschlussPos(BAG.P.Nummer, BAG.P.Position, 0.0.0, now);
    ErrorOutput;
    RETURN true;
  end;

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
/**
  if (aKey=_WinKeyReturn) then
    BA1_F_ArtPrd_Data:EinsatzEdit(cZList2, aID)
  else if (aKey=_WinKeyDelete) then
    BA1_F_ArtPrd_Data:EinsatzDel(cZList2, aID)
  else if (aKey=_WinKeyInsert) then
    BA1_F_ArtPrd_Data:EinsatzIns(cZList2);
**/
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
/***
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
***/

  RETURN(true);
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
//  EvtKeyItemInput
//
//========================================================================
sub EvtKeyItemInput (
  aEvt            : event;
  aKey            : int;
  aRecID          : int;
) : logic
local begin
  vTmp  : int;
end;
begin

  // Return = Edit
  if (aKey = _WinKeyTab) or ( aKey = _winKeyReturn ) then begin

    if ( aEvt:obj->WinLstDatLineInfo( _winLstDatInfoCount ) = 0 ) then
      RETURN false;

    if ( aEvt:obj->wpCurrentInt = 0 ) then
      aEvt:obj->wpCurrentInt # 1;

    if (mode=c_ModeEdList) then
      Lib_DataList:StartListEdit( aEvt:obj, c_ModeEdListEdit, 0, _winLstEditClearChanged )
    else
      Lib_DataList:StartListEdit( aEvt:obj, '', 0, _winLstEditClearChanged );

  end;

  RETURN true;
end;


//========================================================================
// EvtLstEditFinishedInput
//
//========================================================================
sub EvtLstEditFinishedInput(
  aEvt                 : event;    // Ereignis
  aColumn              : int;      // Spalte
  aKey                 : int;      // Taste
  aRecID               : int;      // Datensatz-ID
  aChanged             : logic;    // true, wenn eine Änderung vorgenommen wurde
) : logic;
local begin
  Erx     : int;
  vA      : alpha;
  vStk    : int;
  vGew    : float;
  vMaxStk : int;
  vMaxGew : float;
  vEinzel : float;
end;
begin
  if (aColumn<>0) and (aColumn->wpname='clm.FertigStk') then begin
    aEvt:Obj->WinLstCellGet(vEinzel, cClmEinzel, _WinLstDatLineCurrent);

    aEvt:Obj->WinLstCellGet(vStk, cClmSollStk, _WinLstDatLineCurrent);
    aEvt:Obj->WinLstCellGet(vMaxStk, cClmIstStk, _WinLstDatLineCurrent);
    vMaxStk # vStk - vMaxStk;
    aEvt:Obj->WinLstCellGet(vGew, cClmSollGew, _WinLstDatLineCurrent);
    aEvt:Obj->WinLstCellGet(vMaxGew, cClmIstGew, _WinLstDatLineCurrent);
    vMaxGew # vGew - vMaxGew;

    aEvt:Obj->WinLstCellGet(vStk, cClmFertStk, _WinLstDatLineCurrent);
    aEvt:Obj->WinLstCellGet(BAG.F.Fertigung, cClmFert, _WinLstDatLineCurrent);
    if (vStk>vMaxStk) then begin
      Msg(99,'Zuviel Stücke!!',0,0,0);
      vStk # 0;
      aEvt:Obj->WinLstCellSet(vStk,cClmFertStk,  _WinLstDatLineCurrent);
    end;

  //  Lib_DataList:EvtLstEditFinished(aEvt, aColumn, aKey, aRecid, aChanged);

    vGew # vEinzel * cnvfi(vStk);
    aEvt:Obj->WinLstCellSet(vGew, cClmFertGew,  _WinLstDatLineCurrent);
  end;

  Lib_DataList:EvtLstEditFinished(aEvt, aColumn, aKey, aRecid, aChanged);

/*
  aEvt:Obj->WinLstCellGet(vGew, cClmFertGew, _WinLstDatLineCurrent);
  vUrM # cnvfa(vA);
  aEvt:Obj->WinLstCellGet(BAG.IO.ID,1, _WinLstDatLineCurrent);
  BAG.IO.Nummer # BAG.P.Nummer;
  Erx # RecRead(701,1,0);   // Einsatz holen
  if (Erx<=_rLocked) then begin
    vGew # Lib_Berechnungen:Dreisatz(vUrGew, cnvfi(vUrStk), cnvfi(vStk));
    aEvt:Obj->WinLstCellSet(vGew, cClmFertGew,  _WinLstDatLineCurrent);
    vM # Lib_Berechnungen:Dreisatz(vUrM, cnvfi(vUrStk), cnvfi(vStk));
    vA # anum(vM, Set.Stellen.Menge)+' ' + bag.IO.Meh.Out;
    aEvt:Obj->WinLstCellSet(vA, cClmFertGew,  _WinLstDatLineCurrent);
  end;
*/

  RETURN true;
end

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
