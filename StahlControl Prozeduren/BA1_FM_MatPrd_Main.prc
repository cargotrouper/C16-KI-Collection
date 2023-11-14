@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_MatPrd_Main
//                    OHNE E_R_G
//  Info
//
//
//  23.08.2017  AH  Erstellung der Prozedur
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
  cDialog :   $BA1.FM.MatPtd.Maske
  cTitle :    'Fertigmeldung'
  cFile :     707
  cMenuName : 'BA1.FM.Maske.Bearbeiten'
  cPrefix :   'BA1_FM_MatPrd'
  cKey :      1
//  cZList2 :   $DL.Einsatz

  cArt      : 2
  cUrStk    : 7
  cUrGew    : 8
  cUrM      : 9
  cStk      : 13
  cGew      : 14
  cM        : 15
end;

declare RefreshIfm(opt aName : alpha)

//========================================================================
//========================================================================
sub _GetTree(
  aMDI  : int;
) : int;
local begin
  vHdl  : int;
end;
begin
  vHdl # Winsearch(aMDI, 'hdl.Inputlist');
  RETURN cnvia(vHdl->wpCustom);
end;


//========================================================================
//========================================================================
sub _getInputTree(aMDI : int) : int;
local begin
  vA      : alpha;
  vI      : int;
  vJ      : int;
  vDL     : int;
  vGew    : float;
  vM      : float;
  vStk    : int;
  vID     : int;
  vItem   : handle;
  vTree   : int;
end;
begin

  vTree # _GetTree(aMDI);

  vTree->CteClear(true);
//  Cteclose(vTree);

  vDL # aMdi->WinSearch('dl.Input');
  if (vDL<>0) then begin
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
      vDL->WinLstCellGet(vID,     1, vI);
      vDL->WinLstCellGet(vStk,    cStk, vI);
      vDL->WinLstCellGet(vGew,    cGew, vI);
      vDL->WinLstCellGet(vA,      cM, vI);
      vM # cnvfa(vA);
      if (vStk<>0) then begin
        Inc(vJ);
        vItem # CteOpen(_CteItem);
        vItem->spname   # Aint(vID);
        vItem->spcustom # AInt(vStk)+'|'+ANum(vGew, Set.Stellen.Gewicht)+'|'+ANum(vGew, Set.Stellen.Gewicht)+'|'+anum(vM, Set.Stellen.Menge);
        vTree->CteInsert(vItem);
      end;
    END;
  end;

  RETURN vTree;
end;


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
  vHdl2   : int;
  vTmp    : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # 0;//cZList;
  gKey      # cKey;

  Lib_Guicom2:Underline($edBAG.FM.Lagerplatz);

  SetStdAusFeld('edBAG.FM.Lagerplatz'     ,'Lagerplatz');
  SetStdAusFeld('edBAG.FM.Artikelnr'      ,'Struktur');

//  cZList2->wpColFocusBkg    # Set.Col.RList.Cursor;
//  cZList2->wpColFocusOffBkg # "Set.Col.RList.CurOff";
  // Dataliste füllen ------------------------------
  begin
    vHdl # aEvt:obj;
    vHdl2 # vHdl->WinSearch('dl.Input');
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
    WHILE (Erx<=_rLocked) do begin
    // Art, D, B, Güte, Stk, Gew, Menge, RestStk, RestGew, MengeRest, Stk, Gew, M
      if (BAG.IO.Materialnr<>0) and (BAG.IO.Materialtyp=c_IO_Mat) then begin
        vHdl2->WinLstDatLineAdd(BAG.IO.ID);
        vHdl2->WinLstCellSet(BAG.IO.Artikelnr, 2,  _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Materialnr, 3,  _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Dicke, 4,  _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Breite,5,  _WinLstDatLineLast);
        vHdl2->WinLstCellSet("BAG.IO.Güte", 6,  _WinLstDatLineLast);

        vHdl2->WinLstCellSet(BAG.IO.Plan.Out.Stk, 7, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Plan.Out.GewB, 8, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(ANum(BAG.IO.Plan.Out.Meng, Set.Stellen.Menge)+' '+BAG.IO.MEH.Out, 9, _WinLstDatLineLast);

        vHdl2->WinLstCellSet(BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk, 10, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Plan.Out.GewB - BAG.IO.Ist.Out.GewB,11, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(ANum(BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge, Set.Stellen.Menge)+' '+BAG.IO.MEH.Out,12, _WinLstDatLineLast);

        vHdl2->WinLstCellSet(0,13, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(0.0,14, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.MEH.Out,15, _WinLstDatLineLast);
      end;
      Erx # RecLink(701,702,2,_RecNext);
    END;
    vHdl2->wpcurrentint # 1;
  end // Dataliste füllen

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

    $lb.MEH1->wpcaption   # BAG.F.MEH;
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
  vBuf703       : int;
  vErx          : int;
  vF            : float;
  vI            : int;
  vOK           : logic;
  vInputList    : int;
  vItem         : int;
  vA,vB         : alpha;
  vStk          : int;
  vGewN,vGewB   : float;
  vM            : float;
  vGesStk       : int;
  vGesGew       : float;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  if (BAG.FM.Datum=0.0.0) then begin
    Lib_Guicom2:InhaltFehlt('Datum', 'NB.Page1', 'edBAG.FM.Datum');
    RETURN false;
  end;

  // logische Prüfung
  if (BAG.FM.Menge<=0.0) then begin
    Lib_Guicom2:InhaltFehlt('Menge', 'NB.Page1', 'edBAG.FM.Menge');
    RETURN false;
  end;

  BAG.FM.Gewicht.Netto  # Lib_Berechnungen:Dreisatz(BAG.F.Gewicht, cnvfi("BAG.F.Stückzahl"), cnvfi("BAG.FM.Stück"));
  BAG.FM.Gewicht.Brutt  # BAG.FM.Gewicht.Netto;

  // Prüfung...
  vInputList # _GetInputTree(gMDI);
  FOR vItem # vInputList->CteRead(_CteFirst)
  LOOP vItem # vInputList->CteRead(_CteNext, vItem)
  WHILE (vItem > 0) do begin

    vA    # vItem->spcustom;
    vB    # Str_Token(vA, '|', 1);
    vStk  # cnvia(vB);
    vB    # Str_Token(vA, '|', 2);
    vGewN # cnvfa(vB);
    vB    # Str_Token(vA, '|', 3);
    vGewB # cnvfa(vB);
    vB    # Str_Token(vA, '|', 4);
    vM    # cnvfa(vB);
    vGesStk # vGesStk + vStk;
    vGesGew # vGesGew + vGewN;
  END;
  if (vGesStk=0) then begin
    Msg(701041,'',0,0,0);
    $dl.Input->winfocusset(true);
    RETURN false;
  end;


  // Ankerfunktion
  if (RunAFX('BAG.FM.Recsave','MatPrd')<>0) then begin
    if (AfxRes=111) then RETURN true;
    if (AfxRes<>_rOK) then RETURN false;
  end;

  // Beistellungen erzeugen...
  if (BA1_FM_MatPrd_Data:InputList2Beistellung(vInputList)=false) then begin
    Error(707002,'');
    ErrorOutput;
    RETURN false;
  end;

  // Verbuchen...
  if (BA1_Fertigmelden:Verbuchen(true, false)=false) then begin
    // alle Beistellungne löschen !!!
    WHILE (RecLink(708,707,12,_recFirst)=_Rok) do begin
      RekDelete(708);
    END;
    Error(707002,'');
    ErrorOutput;
    RETURN false;
  end;

  if (vInputList<>0) then begin
    vInputList->CteClear(true);
    Cteclose(vInputList);
  end;

  // Ankerfunktion für z.B. Prüfung ob ein Arbeitsgang "fertig" ist und dann
  // abgeschlossen werden kann
  RunAFX('BAG.FM.Verbuchen.Post','');

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

  if (aEvt:Obj->wpname='edBAG.FM.Menge') then begin
    if (BAG.FM.MEH='Stk') then "BAG.FM.Stück" # cnvif(BAG.FM.Menge)
    else if (BAG.FM.MEH='kg') then BAG.FM.Gewicht.Netto # Rnd(BAG.FM.Menge, Set.STellen.Gewicht);
    else if (BAG.FM.MEH='t') then BAG.FM.Gewicht.Netto # Rnd(BAG.FM.Menge * 1000.0, Set.STellen.Gewicht);
    BAG.FM.Gewicht.Brutt # BAG.FM.Gewicht.Netto;

    // ggf. Einsatz automatisch anpassen
/**
    if (cZList2->wpcustom='') then vOK # y;
else vOK # (Msg(99,'Soll Einsatz trotzdem neu berechnet werden?',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes);
    if (vOK) then begin
      BA1_F_ArtPrd_data:RecalcEinsatzToDL(BAG.FM.Menge, cZList2);
      cZList2->wpcustom # '';
      cZList2->winupdate(_WinUpdOn, _WinLstFromFirst);
    end;
**/
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
    'bt.Lagerplatz'     : Auswahl('Lagerplatz');

//    'bt.Verbrauch.Edit' : BA1_F_ArtPrd_Data:EinsatzEdit(cZList2,_WinLstDatLineCurrent);
//    'bt.Verbrauch.Ins'  : BA1_F_ArtPrd_Data:EinsatzIns(cZList2);
//    'bt.Verbrauch.Del'  : BA1_F_ArtPrd_Data:EinsatzDel(cZList2,_WinLstDatLineCurrent);
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
  // Delete
  if ( aKey = _WinKeyDelete) then begin
    Lib_DataList:RemoveDLRow();
  end;


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
  vM      : float;
  vUrStk  : int;
  vUrGew  : float;
  vUrM    : float;
end;
begin
  aEvt:Obj->WinLstCellGet(vStk, cStk, _WinLstDatLineCurrent);
  aEvt:Obj->WinLstCellGet(BAG.IO.ID,1, _WinLstDatLineCurrent);
  BAG.IO.Nummer # BAG.P.Nummer;
  Erx # RecRead(701,1,0);   // Einsatz holen
  if (Erx<=_rLocked) then begin
    if (BAG.IO.Plan.Out.Stk-BAG.IO.Ist.Out.Stk-vStk<0) then begin
      Msg(99,'Zuviel Stücke!!',0,0,0);
      aEvt:Obj->WinLstCellSet(0,12,  _WinLstDatLineCurrent);
    end;
  end;

  Lib_DataList:EvtLstEditFinished(aEvt, aColumn, aKey, aRecid, aChanged);

  aEvt:Obj->WinLstCellGet(vUrStk, cUrStk, _WinLstDatLineCurrent);
  aEvt:Obj->WinLstCellGet(vUrGew, cUrGew, _WinLstDatLineCurrent);
  aEvt:Obj->WinLstCellGet(vStk, cStk, _WinLstDatLineCurrent);
  aEvt:Obj->WinLstCellGet(vA, cUrM, _WinLstDatLineCurrent);
  vUrM # cnvfa(vA);
  aEvt:Obj->WinLstCellGet(BAG.IO.ID,1, _WinLstDatLineCurrent);
  BAG.IO.Nummer # BAG.P.Nummer;
  Erx # RecRead(701,1,0);   // Einsatz holen
  if (Erx<=_rLocked) then begin
    vGew # Lib_Berechnungen:Dreisatz(vUrGew, cnvfi(vUrStk), cnvfi(vStk));
    aEvt:Obj->WinLstCellSet(vGew, cGew,  _WinLstDatLineCurrent);
    vM # Lib_Berechnungen:Dreisatz(vUrM, cnvfi(vUrStk), cnvfi(vStk));
    vA # anum(vM, Set.Stellen.Menge)+' ' + bag.IO.Meh.Out;
    aEvt:Obj->WinLstCellSet(vA, cM,  _WinLstDatLineCurrent);
  end;


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

  if ((aName =^ 'edBAG.FM.Lagerplatz') AND (aBuf->BAG.FM.Lagerplatz<>'')) then begin
    Lpl.Lagerplatz # BAG.FM.Lagerplatz;
    RecRead(844,1,0);
    Lib_Guicom2:JumpToWindow('LPl.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================