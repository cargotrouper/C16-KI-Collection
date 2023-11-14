@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lfs_P_LFA_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  02.02.2010  MS  Summen-Infofelder hinzugefuegt
//  04.11.2010  AI  Erweiterung für LFA-MultiLFS
//  05.05.2011  TM  neue Auswahlmethode 1326/75
//  13.12.2011  AI  VSB nur löschen, wenn nicht schon gelöscht ist
//  29.05.2018  ST  Afx "Lfs.P.Lfa.Init","Lfs.P.Lfa.Init.Pre", "Lfs.P.Lfa.EvtLstDataInit" hinzugefügt
//  09.06.2022  AH  ERX
//  2022-07-06  AH  Auftragslieferverträge dürfen NICHT beliefert werden
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit() : logic
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusWE()
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
@I:Def_Aktionen
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle :    'Lieferschein-Positionen'
  cFile :     441
  cMenuName : 'Lfs.P.LFA.Bearbeiten'
  cPrefix :   'Lfs_P_LFA'
  cZList :    $ZL.Lfs.Positionen.LFA
  cKey :      1

  cFertigStk      : Gv.Int.01
  cFertigNetto    : Gv.Num.01
  cFertigBrutto   : Gv.Num.02
  cFertigBemerk   : Gv.Alpha.01
  cFertigWerksNr  : Gv.Alpha.05
  cFertigDatum    : GV.Datum.01
end;

declare RefreshMode(opt aNoRefresh : logic);

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

  SetStdAusFeld('edxxxxxx'        ,'xxxxxx');

  RunAFX('Lfs.P.LFA.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Lfs.P.LFA.Init',aint(aEvt:Obj));

  Mode # c_modeEdList;
  $lb.Lfs.P.Nummer->wpcaption # AInt(Lfs.Nummer);

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
  vTmp  : int;
end;
begin

  if (Mode=c_modeNew) or (Mode=c_ModeView) then begin
    Lfs_P_Main:RefreshIfm(aName, aChanged);
    RETURN;
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
sub RecInit() : logic
local begin
  Erx   : int;
  vOK   : logic;
  vTmp  : int;
end;
begin

  // Position lesen, da Lib_RecList den Buffer leert !!!
  RecRead(441, 0, 0, gZllist->wpdbrecid);


  if (Mode=c_modeNew) then begin
    Lfs_P_Main:RecInit();
    RETURN true;
  end;

  // Echtes Material?? --------------------------------------------------------------
  if (LFS.P.Materialtyp=c_IO_Mat) then begin

    // Prüfen, ob bereits Teilfertigmeldung erfolgt ist...

    Erx # RecLink(702,441, 9,_recFirst);    // BA-Position holen
    if (Erx>_rLocked) then RETURN false;

    Erx # RecLink(703,441,10,_recFirst);    // BA-Fertigung holen
    if (Erx>_rLocked) then RETURN false;

    Erx # RecLink(701,703,3,_recFirst);     // Input loopen
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.Materialnr=Lfs.P.Materialnr) then begin
        Erx # 99;
        BREAK;
      end;
      Erx # RecLink(701,703,3,_recNext);
    END;
    if (Erx<>99) then RETURN false;

    // nur bei neuer Eingabe prüfen...
    if (Mode=c_ModeEdList) then begin
      // Fertigmeldungen loopen
      Erx # RecLink(707,702,5,_RecFirst);
      WHILE (Erx<=_rLocked) and (vOK=false) do begin
        if ((BAG.FM.InputID=BAG.IO.ID) OR (BAG.FM.BruderID = BAG.IO.ID)) and (BAG.FM.Status=1) then
          vOK # true;
        Erx # RecLink(707,702,5,_RecNext);
      END;

      if (vOK) then begin
        if (Msg(701023,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN false;
      end;
    end;

    RETURN true;
  end;

  // VSB-Material?? ----------------------------------------------------------------
  if (LFS.P.Materialtyp=c_IO_VSB) then begin

    Erx # RecLink(702,441, 9,_recFirst);    // BA-Position holen
    if (Erx>_rLocked) then RETURN false;

    Erx # RecLink(703,441,10,_recFirst);    // BA-Fertigung holen
    if (Erx>_rLocked) then RETURN false;

    Erx # RecLink(701,703,3,_recFirst);     // Input loopen
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.Materialnr=Lfs.P.Materialnr) then begin
        Erx # 99;
        BREAK;
      end;
      Erx # RecLink(701,703,3,_recNext);
    END;
    if (Erx<>99) then RETURN false;

    RecBufClear(707);
    BAG.FM.Nummer     # BAG.P.Nummer;
    BAG.FM.Position   # BAG.P.Position;
    BAG.FM.Fertigung  # BAG.F.Fertigung;
    BAG.FM.InputBAG   # BAG.P.Nummer;
    BAG.FM.InputID    # BAG.IO.ID;
    BAG.FM.OutputID   # 0;
    BAG.FM.BruderID   # 0;

    // Recht vorhanden?
    if (Rechte[Rgt_EK_E_VSB2WE]=n) then begin
      gZLList->WinFocusSet(false);
      RETURN false;
    end;

    if (Msg(701011,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then begin
      gZLList->WinFocusSet(false);
      RETURN false;
    end;
    gZLList->WinFocusSet(false);

    Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
    If (Erx<200) then begin
      Msg(701012,'',0,0,0);
      RETURN false;
    end;

    Erx # RecLink(501,200,18,_recFirst);  // Bestellpos holen
    If (Erx>_rLocked) then begin
      Msg(701013,'',0,0,0);
      RETURN false;
    end;
    Erx # RecLink(500,501,3,_recFirst);   // BestellKopf holen

    Erx # RecLink(506,200,20,_recFirst);  // Wareneingang holen
    If (Erx>_rLocked) then begin
      Msg(701013,'',0,0,0);
      RETURN false;
    end;

    "Ein.E.Stückzahl" # BAG.IO.Plan.Out.Stk;
    //Ein.E.Gewicht     # BAG.IO.Plan.Out.GewN;
    // 16.02.2017 AH:
    Erx # RecLink(818,506,12,_recfirst);    // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    if ( VWa.NettoYN ) then
      Ein.E.Gewicht     # BAG.IO.Plan.Out.GewN
    else
      Ein.E.Gewicht     # BAG.IO.Plan.Out.GewB;

    Ein.E.Menge       # BAG.IO.Plan.Out.Meng;
    Ein.E.VSByn       # n;
    Ein.E.EingangYN   # y;
    Ein.E.Eingang_datum  # today;
    Ein.E.MaterialNr  # 0;

    // Wareneingangsdialog starten...
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ein.E.Mat.Verwaltung', here+':AusWE',y,y);
    // Gegenbuchung vorbereiten...
    vTmp # gMDI->Winsearch('lb.GegenVSB');
    vTmp->wpcustom # AInt(Ein.E.Eingangsnr);

    // RecList killen, damit sie den Buffer nicht zerstört
    vTmp # gMDI->Winsearch('ZL.Ein.Mat.Eingang');
    vTmp->wpDbFileNo # 1;

    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    Mode # c_modeBald + c_modeNew;
    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN false;   // Abbruch wegen MDI-Start
  end;


  RETURN true;
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vStk      : int;
  vNetto    : float;
  vBrutto   : float;
  vDatum    : date;
  vWerksNr  : alpha;
  vBem      : alpha(200);
  vAlteNr   : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  // neue Position in Fahrauftrag aufnehmen?
  if (Mode=c_modeNew) then begin

    Erx # RecLink(702,440,7,_recFirst);   // BA-Position holen
    Erx # RecLink(700,702,1,_RecFirst);   // BA-Kopf holen
    vAlteNr # BAG.Nummer;

    REPEAT
      BAG.F.Nummer    # BAG.P.Nummer;
      BAG.F.Position  # BAG.P.Position;
      BAG.F.Fertigung # Lfs.P.Position;
      Erx # RecRead(703,1,_recTest);
      if (Erx<=_rLocked) then
        Lfs.P.Position # Lfs.P.Position + 1;
    UNTIL (Erx>_rLocked);

    if (BA1_P_Data:_ErzeugeBAGausLFS(vAlteNr, LFS.ZuBA.Position)=false) then begin
      ErrorOutput;
      RETURN falsE;
    end;
    // automatischer Abschluss eintragen
    if (BA1_P_Data:AutoVSB()=false) then begin
      BAG.Nummer    # vAlteNr;
      BAG.P.Nummer  # vAlteNr;
//    Error(010034,AInt(BAG.P.Nummer));
      RETURN false;
    end;

    BA1_P_Data:UpdateSort();

    RETURN true;
  end;  // ...Neuanlage


  // EDITIEREN...

  if (cFertigNetto=0.0) then  cFertigNetto # cFertigBrutto;
  if (cFertigBrutto=0.0) then cFertigBrutto # cFertigNetto;

  /*** 2009 if (cFertigStk>"Lfs.P.Stück") or **/
  if (cFertigStk<1) or (cFertigNetto<1.0) or (cFertigBrutto<1.0) then begin
    mode # c_ModeCancel;
    cZList->winfocusset(true);
    RETURN false;
  end;

  vStk      # cFertigStk;
  vNetto    # cFertigNetto;
  vBrutto   # cFertigBrutto;
  vDatum    # cFertigDatum;
  vWerksnr  # StrCut(cFertigWerksnr,1,32);
  vBem      # StrCut(cFertigBemerk,1,32);

  if (Msg(441700,AInt(vStk)+' Stk., '+ANum(vBrutto,2)+' kg',0,_WinDialogYesNo,1)<>_winidyes) then begin
    mode # c_ModeCancel;
    cZList->winfocusset(true);
    RETURN false;
  end;

  Erx # RecRead(441,1,_recunlock);
  if (Lfs_LFA_Data:Verwiegung_Mat(vStk, vNetto, vBrutto, 0.0, '', vDatum,vBem,vWerksNr, '')=true) then begin

    Error(707001,'');   // Erfolg
    ErrorOutput;

    // Bemerkung übergeben:
    // letzte (neue!?) LFS-Position holen...
    Erx # RecLink(441,440,4,_RecLast);
    RecRead(441,1,_reclock);
    Lfs.P.Bemerkung # vBem;
    RekReplace(441,_recUnlock,'AUTO');
    // ggf. Aktion auch updaten...
    Erx # RecLink(401,441,5,_RecFirst);   // Auftrag holen
    if (Erx<=_rLocked) then begin
      if (Auf_A_data:LiesAktion(Auf.P.Nummer, Auf.P.Position, 0, c_AKT_LFS, Lfs.P.Nummer, Lfs.P.Position, 0)) then begin
        Recread(404,1,_recLock);
        Auf.A.Bemerkung # vBem;
        RekReplace(404,_recUnlock,'AUTO');
      end;
    end;

    mode # c_ModeCancel;
    gZLList->WinUpdate(_winupdOn,
                        _WinLstFromFirst | _WinLstRecDoSelect);
    cZList->winfocusset(true);

    RETURN false;
  end;


  // Fehler!
  Error(441701,'');
  ErrorOutput;

  mode # c_ModeCancel;
  RETURN false;
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
  Erx   : int;
  vVSP  : int;
end;
begin

  if (Rechte[Rgt_Lfs_Loeschen]=n) then RETURN;

  if (lfs.P.Datum.Verbucht<>0.0.0) then begin
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

      if (Lfs_LFA_Data:Storniere()=false) then begin
        Error(441000,aint(Lfs.P.Position));
        ErrorOutput;
        RETURN;
      end;

      gZLList->WinUpdate(_winupdOn, _WinLstFromFirst | _WinLstRecDoSelect);
      RecRead(gFile,0,0,gZLList->wpdbrecid);
      Refreshmode();
      Msg(999998,'',0,0,0);
    end;
    RETURN;
  end;

  if (Lfs.Datum.Verbucht<>0.0.0) or (lfs.P.Datum.Verbucht<>0.0.0) then RETURN;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    if (lfs.zuBA.Nummer=0) then begin
      RekDelete(gFile,0,'MAN');
      end
    else begin
      vVSP # Lfs.P.Versandpoolnr;
      Erx # RecLink(702,441,9,_recFirst);     // BA-Position holen
      Erx # RecLink(703,441,10,_recFirst);    // BA-Fertigung holen
      Erx # RecLink(701,441,11,_RecFirst);    // BA-Input holen
      if (BA1_IO_Data:EinsatzRaus(cnvai(BAG.IO.Nummer)+'/'+cnvai(BAG.IO.ID))=false) then RETURN;

      RekDelete(441,_recUnlock,'MAN');

      // ok...
      if (vVSP<>0) then begin
        VsP_Data:Rest2Pool(vVSP);
      end;

    end;
    gZLList->WinUpdate(_winupdOn, _WinLstFromFirst | _WinLstRecDoSelect);
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
  RETURN Lfs_P_Main:EvtFocusInit(aEvt, aFocusObject);
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
  RETURN Lfs_P_Main:EvtFocusTerm(aEvt, aFocusObject);
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  Erx   : int;
  vA        : alpha;
  vMenge    : float;
  vGew      : float;
  vStk      : int;
  vMengeFak : float;
  vDatFak   : date;
  vBem      : alpha;
end;

begin

  case aBereich of

    'FM_Artikel' : begin
      if (Lfs.P.Datum.Verbucht<>0.0.0) then RETURN;

      vMenge    # Lfs.P.Menge.Einsatz;
      vStk      # "Lfs.P.Stück";
      vMengeFak # Lfs.P.Menge;
      vDatFak   # today;
      vBem      # Lfs.P.Bemerkung;

      Erx # RecLink(250,441,3,_RecFirst);     // Artikel holen
      If (Erx>_rLocked) then RETURN;

      Erx # RecLink(252,441,14,_RecFirst);   // Charge holen
      If (Erx>_rLocked) then RETURN;

      // Dialog öffnen...
      //vGew    # Lib_Berechnungen:KG_aus_StkDBLWgrArt(vStk, Art.C.Dicke, Art.C.Breite, "Art.C.Länge", Art.Warengruppe, Art.C.Artikelnr);
      vGew # Lfs.P.Gewicht.Netto;
      if (vGew=0.0) then
        vGew # Rnd(Lib_Einheiten:WandleMEH(252, vStk, 0.0, vMengeFak, Lfs.P.MEH, 'kg'), Set.Stellen.Gewicht);
      if (Dlg_DFaktArt:DFaktArt(var vMenge, var vStk, var vMengeFak,var vGew, var vDatFak,var vBem, Lfs.P.MEH.Einsatz, Lfs.P.MEH)<>true) then RETURN;
      if (vMenge<0.0) or (vStk<0) or (vMengeFak<0.0) then RETURN;

      // Verbuchen...
      TRANSON;
      if (Lfs_LFA_Data:Verwiegung_Art(vMenge, Lfs.P.MEH.Einsatz, vMengeFak, Lfs.P.MEH, vStk, vGew, vDatFak,vBem)=false) then begin
        TRANSBRK;
        // Fehler!
        Error(441701,'');
        ErrorOutput;
        RETURN;
      end;

/*** KÖNSTLICHER ABBRUCH
TRANSBRK;
// Fehler!
Error(19999,'-----------------');
ErrorOutput;
RETURN;
***/
      TRANSOFF;

      Error(707001,'');   // Erfolg
      ErrorOutput;

      // Bemerkung übergeben:
      // letzte (neue!?) LFS-Position holen...
      Erx # RecLink(441,440,4,_RecLast);
      RecRead(441,1,_reclock);
      Lfs.P.Bemerkung # vBem;
      RekReplace(441,_recUnlock,'AUTO');
      // ggf. Aktion auch updaten...
      Erx # RecLink(401,441,5,_RecFirst);   // Auftrag holen
      if (Erx<=_rLocked) then begin
        if (Auf_A_data:LiesAktion(Auf.P.Nummer, Auf.P.Position, 0, c_AKT_LFS, Lfs.P.Nummer, Lfs.P.Position, 0)) then begin
          Recread(404,1,_recLock);
          Auf.A.Bemerkung # vBem;
          RekReplace(404,_recUnlock,'AUTO');
        end;
      end;

      gZLList->WinUpdate(_winupdOn,
                          _WinLstFromFirst | _WinLstRecDoSelect);
      cZList->winfocusset(true);

      RETURN;

    end;

  end;

end;


//========================================================================
//  AusWE
//
//========================================================================
sub AusWE();
local begin
  Erx   : int;
  vStk      : int;
  vGewN     : float;
  vGewB     : float;
  vMenge    : float;
  vNachBA   : int;
  vNachPos  : int;
  vNachFert : int;
  vNeuFert  : int;
  vNeuInID  : int;
  vNeuOutID : int;
  vOK       : logic;
  vI          : int;
  vMat        : int;
  vErsetzen   : logic;
  vVSBKillen  : logic;
  vAutoFM     : logic;
  vLager      : alpha;
end;
begin

  if (gSelected=0) then begin
    // Focus setzen:
    gZLList->Winfocusset(false);
    RETURN;
  end;


  RecRead(441,0,0,gZLList->wpdbrecid);
  vMat # Lfs.P.Materialnr;
//debug('auf mat:'+aint(vMAt));
  Erx # RecLink(200,441,4,_recFirst);   // VSB-Material holen

  // weitere Daten abfragen...
  vI # Dlg_LFA_WE2VSB:Start();
  if (vI=0) then RETURN;
  if (vI & 2>0) then vErsetzen  # y;
  if (vI & 4>0) then vVSBKillen # y;
  if (vI & 8>0) then vAutoFM # y;

  // neuen WE holen
  RecRead(506,0,_RecId,gSelected);
  gSelected # 0;

  // BA holen
  BAG.Nummer      # BAG.FM.Nummer;
  RecRead(700,1,0);

  // BA-Position holen
  BAG.P.Nummer    # BAG.FM.Nummer;
  BAG.P.Position  # BAG.FM.Position;
  RecRead(702,1,0);

  Erx # RecLink(200,506,8,_recFirst);   // Material holen
  if (Erx>_rLocked) then RETURN;

  // VSB-Mat wird genau EIN Echtes?
//    if (Msg(441011,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdyes) then begin

//      if (msg(701028,'',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes) then
//        vVSBKillen # y;

  if (vErsetzen) then begin
    vOK # BA1_Fertigmelden:ErzeugeMatAusVSB_genau1();

    if (vOK) and (vVSBKillen) then begin
      MAt.Nummer # vMat;
      RecRead(200,1,0);
      Erx # RecLink(501,200,18,_recFirst);  // Bestellpos holen
      If (Erx>_rLocked) then begin
        Msg(701013,'',0,0,0);
        RETURN;
      end;
      Erx # RecLink(500,501,3,_recFirst);   // Bestellkopf holen
      Erx # RecLink(506,200,20,_recFirst);  // Wareneingang holen
      If (Erx>_rLocked) then begin
        Msg(701013,'',0,0,0);
        RETURN;
      end;
      // nur wenn nicht eh schon gelöscht ist...
      if ("Ein.E.Löschmarker"='') then
        if (Ein_E_Data:StornoVSBMat()=false) then begin
        ErrorOutput;
        RETURN;
      end;
    end;

    end
  else begin
    vOK # BA1_Fertigmelden:ErzeugeMatAusVSB();
  end;
  if (vOK=false) then begin
    ErrorOutput;
    RETURN;
  end;

//18.2.2011
  BA1_P_Data:ErrechnePosRek();
  // passenden LFS erzeugen/udpaten
//    Lfs_LFA_Data:ErzeugeLFSausLFA();

  if (vAutoFM) then begin
    RecRead(440,1,0);
    RecRead(441,1,0);
//    if (Lfs_LFA_Data:GesamtFM()=false) then begin
//      ErrorOutput;
//    end;
    vGewN # Lfs.P.Gewicht.Netto;
    vGewB # Lfs.P.Gewicht.Brutto;
    if (vGewN=0.0) then vGewN # vGewB;
    if (vGewB=0.0) then vGewB # vGewN;
    // 14.09.2016 AH
    if (BAG.P.ZielVerkaufYN=false) then
      vLager # Mat.Lagerplatz
    else
      vLager  # '';
    if (Lfs_LFA_Data:Verwiegung_Mat("Lfs.P.Stück", vGewN, vGewB, 0.0, '', today, '', '', vLager)=false) then begin
      // Fehler!
//      TRANSBRK;
      Error(441701,'');
    end;
  end

  ErrorOutput;

//      RecRead(441,1,0);
//      gZLList->wpdbRecId # RecInfo(441,_recID);
  gZLList->WinUpdate(_winupdOn,
//                          _WinLstFromFirst | _WinLstRecDoSelect);
                      _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
  gZLList->winfocusset(true);

  // Focus setzen:
  gZLList->Winfocusset(false);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx   : int;
  d_MenuItem  : int;
  vHdl        : int;
  vTransLFS   : logic;
  vNetto      : float;
  vStk        : int;
end
begin

  if (Mode=c_ModeEdList) and ($lb.Sum.Netto->wpcustom = '') then begin
    Erx # RecLink(441, 440, 4, _recFirst);
    WHILE(Erx <= _rLocked) DO BEGIN
      vNetto # vNetto + Lfs.P.Gewicht.Netto;
      vStk   # vStk + "Lfs.P.Stück";
      Erx # RecLink(441, 440, 4, _recNext);
    END;

    $lb.Sum.Netto->wpcustom     # 'DONE';
    $lb.Sum.Netto->wpcaption    # ANum(vNetto, Set.Stellen.Gewicht);
    $lb.Sum.Stueck->wpcaption   # aInt(vStk);
  end;


  if (Mode=c_modeNew) then begin
    Lfs_P_Main:RefreshMode(aNoRefresh);
    RETURN;
  end;


  if (LFS.P.zuBA.Nummer<>0) then begin
    Erx # RecLink(702,441, 9,_recFirst);    // BA-Position holen
    if (Erx<=_rLocked) and (BAG.P.ZielVerkaufYN=false) then vTransLFS # Y;
  end;


  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vTransLFS) or
                      (Lfs.Datum.Verbucht<>0.0.0) or
                      (Rechte[Rgt_Lfs_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vTransLFS) or
                      (Lfs.Datum.Verbucht<>0.0.0) or
                      (Rechte[Rgt_Lfs_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Lfs.P.Datum.Verbucht<>0.0.0) or
      ((Lfs.P.Materialnr=0) and (Lfs.P.ARtikelnr='')) or
      ((Rechte[Rgt_Lfs_Verbuchen]=n) and (Lfs.P.zuBA.Nummer=0)) or
      ((Rechte[Rgt_BA_Fertigmelden]=n) and (Lfs.P.zuBA.Nummer<>0));
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Lfs.P.Datum.Verbucht<>0.0.0) or
      ((Lfs.P.Materialnr=0) and (Lfs.P.ARtikelnr='')) or
      ((Rechte[Rgt_Lfs_Verbuchen]=n) and (Lfs.P.zuBA.Nummer=0)) or
      ((Rechte[Rgt_BA_Fertigmelden]=n) and (Lfs.P.zuBA.Nummer<>0));

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # //(vTransLFS) or
                      (mode<>c_modeEdList) or
                      (Lfs.Datum.Verbucht<>0.0.0) or
                      // Lfs.P.Datum.Verbucht<>0.0.0) or //(lfs.zuBA.Nummer<>0) or
                      (Rechte[Rgt_Lfs_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled #// (vTransLFS) or
                      (mode<>c_modeEdList) or
                      (Lfs.Datum.Verbucht<>0.0.0) or
                      // (Lfs.P.Datum.Verbucht<>0.0.0) or //(lfs.zuBA.Nummer<>0) or
                      (Rechte[Rgt_Lfs_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.LFS.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Lfs.zuBA.Nummer=0) or (Lfs.P.zuBA.Nummer=0) or (Lfs.P.Materialtyp<>c_IO_VSB) or
      (Lfs.Datum.Verbucht<>0.0.0) or (Rechte[Rgt_Lfs_Aendern]=n);


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
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) or (Mode=c_ModeEdList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  if (Mode=c_modeNew) then begin
    Lfs_P_Main:EvtMenuCOmmand(aEvt, aMenuItem);
    RETURN true;
  end;

  case (aMenuItem->wpName) of

    'Mnu.New2' : begin
      Mode # c_ModeList;
      App_Main:Action(c_ModeNew);
    end;


    'Mnu.LFS.Import' : begin
      if (Lfs.Datum.Verbucht=0.0.0) and (Lfs.zuBA.Nummer<>0) and (Lfs.P.zuBA.Nummer<>0) and (Lfs.P.Materialtyp=c_IO_VSB) then
        Lfs_LFA_Data:ImportCSVzuVSB();
      gZLList->WinUpdate(_winupdOn,_WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);
      gZLList->Winfocusset(false);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
    end;


    'Mnu.Reservierungen' : begin
      if (RecRead(gFile, 1, 0) = _rOk) and (Lfs.P.Materialnr <> 0) then begin
        if (RecLink(200, 441, 4, _recFirst) = _rOk) then begin
          RecBufClear(203);
          gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Mat.Rsv.Verwaltung', '', y);
          VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
          vTmp # winsearch(gMDI, 'NB.Main');
          vTmp->wpcustom # 'MAT';
          gZLList->wpDbFileNo     # 200;
          gZLList->wpDbKeyNo      # 13;
          gZLList->wpDbLinkFileNo # 203;
          // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
          gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
          Lib_GuiCom:RunChildWindow(gMDI);
        end;
      end;
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

  if (Mode=c_modeNew) then begin
    Lfs_P_Main:EvtClicked(aEvt);
    RETURN true;
  end;

  if (aEvt:Obj->wpName='New2') then begin
    Mode # c_ModeList;
    App_Main:Action(c_ModeNew);
    RETURN true;
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
  end;

end;


//========================================================================
//  EvtClickedSpezi
//              Button gedrückt
//========================================================================
sub EvtClickedSpezi (
  aEvt                  : event;        // Ereignis
) : logic
begin

  if (Lfs.P.Materialtyp=c_IO_Art) then begin
    Auswahl('FM_Artikel');
    RETURN true;
  end;

  RETURN App_Main:EvtClicked(aEvt);

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
local begin
  Erx : int;
end;
begin

  if (aMark) then begin
    if (RunAFX('Lfs.P.Lfa.EvtLstDataInit','y' + aEvt:obj->wpName)<0) then RETURN;
  end
  else if (RunAFX('Lfs.P.Lfa.EvtLstDataInit','n' + aEvt:obj->wpName)<0) then RETURN;
  
  cFertigStk    # 0;
  cFertigNetto  # 0.0;
  cFertigBrutto # 0.0;
  cFertigDatum  # today;
  Gv.Alpha.02 # '';
  cFertigBemerk # Lfs.P.Bemerkung;

  if (Lfs.P.Datum.Verbucht<>0.0.0) then begin
    cFertigDatum # Lfs.P.Datum.Verbucht;
    if (aMark=n) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
  end;

  if (LFs.P.Materialtyp=c_IO_MAT) then
    Gv.Alpha.02 # Cnvai(Lfs.P.Materialnr)
  else if (LFs.P.Materialtyp=c_IO_VSB) then
    Gv.Alpha.02 # c_Akt_VSB+' '+Cnvai(Lfs.P.Materialnr);
  else if (LFs.P.Materialtyp=c_IO_Art) then
    GV.Alpha.02 # LFs.P.Artikelnr + ' '+lfs.p.Art.Charge;

  Gv.Alpha.03 # '';
  Gv.Alpha.04 # '';
  Gv.Alpha.05 # '';
  Gv.Alpha.07 # '';
  if (LFs.P.Materialtyp=c_IO_VSB) or (Lfs.P.Materialtyp=c_IO_Mat) then begin
    Erx # RecLink(200,441,4,_recFirst);     // Material holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(210,441,12,_recFirst);  // ~Material holen
      if (Erx<=_rLocked) then RecBufCopy(210,200);
    end;
    if (Mat.Nummer<>0) then begin
      Gv.Alpha.03 # ANum(Mat.Dicke,Set.Stellen.Dicke)+' x '+ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge"<>0.0) then Gv.Alpha.03 # Gv.ALpha.03 + ' x '+ANum("Mat.Länge","Set.Stellen.Länge");
      Gv.ALpha.04 # Mat.Coilnummer;
      Gv.Alpha.05 # Mat.Werksnummer;
      Gv.ALpha.07 # Mat.Chargennummer;
    end;
    end
  else if (Lfs.P.MaterialTyp=c_IO_Theo) then begin
    if (Lfs.P.zuBA.Nummer<>0) then begin
      Erx # RecLink(701,441,11,_recFirst);    // BA-Input holen
      if (Erx<=_rLocked) then begin
        Gv.Alpha.03 # ANum(BAG.IO.Dicke,Set.Stellen.Dicke)+' x '+ANum(BAG.IO.Breite,Set.Stellen.Breite);
        if ("BAG.IO.Länge"<>0.0) then Gv.Alpha.03 # Gv.ALpha.03 + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
      end;
    end;
  end;


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
local begin
  Erx   : int;
  vBuf200 : int;
  vRes    : logic;
end;
begin
  RecRead(gFile,0,_recid,aRecID);

  if (Lfs.P.Materialnr <> 0) then begin
    vBuf200 # RecBufCreate(200);
    RecLink(vBuf200, 441, 4, _recFirst);
    Erx # RecLink(203,vBuf200,13,_recFirsT);  // Reservierungen loopen
    WHILE (Erx<=_rLocked) and (vRes=false) do begin
      if ("Mat.R.Trägertyp"<>c_Akt_BAInput) then vRes # y;
      Erx # RecLink(203,vBuf200,13,_recNext);
    END;
  end;
  $lb.Reservierungen->wpVisible # vRes;

  RefreshMode(y);   // falls Menüs gesetzt werden sollen
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
// EvtKeyItemSpezi
//
//========================================================================
sub EvtKeyItemSpezi(
  aEvt                 : event;    // Ereignis
  aKey                 : int;      // Taste
  aID                  : int;      // RecID bei RecList, Node-Deskriptor bei TreeView
) : logic;
begin
  RecRead(gFile,0,_recid,aID);

  if (Lfs.P.Materialtyp=c_IO_Art) and (aKey=_WinKeyReturn) then begin
    Auswahl('FM_Artikel');
    RETURN true;
  end;

  RETURN Lib_RecList:EvtKeyItem(aEvt, aKey, aID);
end;



//========================================================================
// EvtMouseItemSpezi
//
//========================================================================
sub EvtMouseItemSpezi(
  aEvt                 : event;    // Ereignis
  aButton              : int;      // Maustaste
  aHitTest             : int;      // Hittest-Code
  aItem                : int;      // Spalte oder Gantt-Intervall
  aID                  : int;      // RecID bei RecList / Zelle bei GanttGraph
) : logic;
begin

  if (aID > 0 AND aItem > 0 AND
      aButton & (_WinMouseLeft | _WinMouseDouble) =
      (_WinMouseLeft | _WinMouseDouble)) then begin
    RecRead(gFile,0,_recid,aID);
    if (Lfs.P.Materialtyp=c_IO_Art) then begin
      Auswahl('FM_Artikel');
      RETURN true;
    end;
  end;

  RETURN Lib_RecList:EvtMouseItem(aEvt, aButton, aHitTest, aItem, aID);
end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================