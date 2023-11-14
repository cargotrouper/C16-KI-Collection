@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_IO_Lohn_Main
//                    OHNE E_R_G
//  Info
//
//
//  20.05.2010  AI  Erstellung der Prozedur
//  21.06.2010  ST  Filter für Kundenlohnmaterial hinzugefügt
//  27.04.2011  ST  Fehlerkorrektur: Beim Ändern des Einsatzes werden die Fertigungen neu berechnet
//  30.05.2012  ST  Projekt 1345/20: Übernahme mehrer Einsatzmaterialien hinzugefügt
//  08.08.2012  ST  APPON/APPOFF für RecDel (Prj. 1352/54)
//  28.11.2012  AI  RecSave total fehlerhaft!!!! Projekt 1329/319
//  17.01.2013  ST  Überarbeitung der RecSave Methode Projekt 1329/319 & 1326/319
//  27.06.2013  ST  Bugfix "RecDel";  RecDel aus BAG_IO_Main übernommen
//  08.10.2013  AH  Bugfix zu Bugfix "RecDel" - hatte den VSB-Schritt nicht mit gelöscht und Transaktions falsch gesetzt (Proj. 1352/85)
//  24.09.2014  AH  Erweiterung für Klonen
//  03.05.2016  AH  Bug: Teilungen wurden beim Speichern für JEDEN Einsatz geprüft - soll aber nur aktueller sein
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit() : logic;
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusMaterial();
//    SUB AusKlonMaterial();
//    SUB _AusMaterialAddMat(aMatNr : int; aKlonVonID : int)
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
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
  cTitle      : 'Einsatzmaterial'
  cFile       : 701
  cMenuName   : 'BA1.IO.Lohn.Bearbeiten'
  cPrefix     : 'BA1_IO_Lohn'
  cZList      : $ZL.BA1.Input.Lohn
  cKey        : 1
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
  Erx   : int;
  vTmp  : int;
end;
begin

  if (aName='') and (Mode=c_ModeView) then begin
    Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
    if (Erx<200) then
      RecBufClear(200);

    Erx # RecLink(819,701,7,_recFirst);   // Warengruppe holen
    if (Erx>=_rLocked) then RecBufClear(819);
    $Lb.IO.WgrText_Mat->wpcaption # Wgr.Bezeichnung.L1;
    $lb.IO.Chargennummer_Mat->wpCaption # Mat.Chargennummer;
    $lb.IO.Ringnummer_Mat->wpCaption    # Mat.Ringnummer
    $lb.IO.Wgr_Mat->wpcaption           # AInt(BAG.IO.Warengruppe);
    $lb.IO.Guete_Mat->wpcaption         # "BAG.IO.Güte";
    $lb.IO.GuetenStufe_Mat->wpcaption   # "BAG.IO.GütenStufe";
    $lb.IO.Dicke_Mat->wpcaption         # ANum(BAG.IO.Dicke, Set.Stellen.Dicke);
    $lb.IO.Breite_Mat->wpcaption        # ANum(BAG.IO.Breite, Set.Stellen.Breite);
    $lb.IO.Laenge_Mat->wpcaption        # ANum("BAG.IO.Länge", "Set.Stellen.Länge");
    $lb.IO.DickeTol_Mat->wpcaption      # BAG.IO.DickenTol;
    $lb.IO.BreiteTol_Mat->wpcaption     # BAG.IO.BreitenTol;
    $lb.IO.LaengeTol_Mat->wpcaption     # "BAG.IO.LängenTol";
    $lb.IO.IstStk_Mat->wpcaption        # AInt(BAG.IO.Ist.In.Stk);
    $lb.IO.IstNetto_Mat->wpcaption      # ANum(BAG.IO.Ist.In.GewN, Set.Stellen.Gewicht);
    $lb.IO.IstBrutto_Mat->wpcaption     # ANum(BAG.IO.Ist.In.GewB, Set.Stellen.Gewicht);
  end;

  if (BAG.IO.AutoTeilungYN) then
    Lib_GuiCom:Disable($edBAG.IO.Teilungen)
  else if(Mode <> c_ModeView) then
    Lib_GuiCom:Enable($edBAG.IO.Teilungen);


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
sub RecInit() : logic;
local begin
  vBuf701 : int;
end;
begin

  if (mode=c_ModeEdListNew) then begin
    RecBufClear(701);
    BAG.IO.ID           # 1000;
    BAG.IO.Nummer       # BAG.p.Nummer;
    BAG.IO.NachBAG      # BAG.P.Nummer;
    BAG.IO.NachPosition # BAG.P.Position;
    BAG.IO.Materialtyp  # c_IO_Mat;
  end;

  vBuf701 # RekSave(701);

  if (BA1_Lohn_Subs:DeleteVSBzuInput()=false) then begin
    ErrorOutput;
    RekRestore(vBuf701);
    RETURN false;
  end;

  RekRestore(vBuf701);
  if (mode=c_modeEdit) then begin
    RecRead(701,1,_recLock);
  end;

  $cbBAG.IO.AutoTeilungYN->WinFocusSet(true);

  RefreshIfm();

  RETURN true;
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vOK     : logic;
  vKGMM1  : float;
  vKGMM2  : float;
  vTLG    : int;
  vKGMM_Kaputt  : logic;
  vBuf401 : int;
  vBuf701 : int;
  vBuf702 : int;
  vErx    : int;
  vBagF   : int;
  vProt   : int;
  vErr    : int;

  vTLGErr : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  if (Mode=c_ModeEdit) then begin

    TRANSON;

    Erx # BA1_IO_Data:Replace(_recUnlock,'MAN');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN False;
    end;

    vBuf401 # RekSave(401);
    vBuf701 # RekSave(701);
    vBuf702 # RekSave(702);

    // Fertigungen Updaten
    FOR  vErx # RecLink(703,702,4, _recFirst);
    LOOP vErx # RecLink(703,702,4, _recNext);
    WHILE (vErx <= _rLocked) and (vErr=0) DO BEGIN
      vBagF # Bag.F.Fertigung;

      RecRead(703,1,_recLock);

      // ST 2013-01-17: Übernahme aus BA1_F_Main:RecSave
      // Fertigmaterial updaten
      if (BA1_F_Data:UpdateOutput(703,n)=false) then begin
        TRANSBRK;
        ERROROUTPUT;  // 01.07.2019
/*
        if (Mode=c_ModeEdit) then
          RecRead(703,1,_recLock);
        vErr  # -1;
*/
        BREAK;
      end;

      // kgmm-Testen...
      if (BA1_IO_Data:KGMMMinMaxBestimmen(var vKGMM1, var vKGMM2)=false) then begin
        if (Set.BA.AutoT.NurWarn=false) then begin
          vErr # -1;
          TRANSBRK;
          Msg(703005,'',0,0,0);
/*
          if (Mode=c_ModeEdit) then begin
            RecRead(703,1,_recLock);
            PtD_Main:Memorize(gFile);
          end;
*/
        end;
        vTlgErr # 703005;
      end;


      // Autoteilung ***************************************************
      Erx # RecLink(701,702,2,_recFirst);   // Input loopen
      WHILE (Erx<=_rLocked) do begin

        // 03.05.2016 AH: NUR DIESEN INPUT PRÜFEN
        if (BAG.IO.ID<>vBuf701->BAG.IO.ID) then begin
          Erx # RecLink(701,702,2,_recNext);
          CYCLE;
        end;

        if (BAG.IO.BruderID<>0) then begin
          Erx # RecLink(701,702,2,_recNext);
          CYCLE;
        end;

        if (BAG.IO.AutoteilungYN) then begin
          // für diesen Einsatz Teilung ausrechnen....
          vTLG # BA1_IO_Data:TeilungVonBis(vKGMM1, vKGMM2);
          if (vTLG<0) then begin
            if (Set.BA.AutoT.NurWarn=false) then begin
              TRANSBRK;
              Msg(703007,anum(vKGMM1,2)+'|'+anum(vKGMM2,2)+'|'+aint(BAG.IO.NachBAG)+'/'+aint(BAG.IO.NachPosition),0,0,0);   // ERROR

//              if (Mode=c_ModeEdit) then RecRead(703,1,_recLock);
              vErr # -1;
              BREAK;
            end;
            vTlg # BAG.IO.Teilungen;
            vTLGErr # 703007;
          end;

          if (vTlg<>BAG.IO.Teilungen) then begin
            RecRead(701,1,_recLock);
            BAG.IO.Teilungen # vTlg;
            Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
            if (erx<>_rOK) then begin
              TRANSBRK;
              Msg(703004,'(Code A)',0,0,0);   // ERROR
//              if (Mode=c_ModeEdit) then RecRead(703,1,_recLock);
              vErr # -1;
              BREAK;
            end;

            // Output aktualisieren
            if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
              TRANSBRK;
              Msg(703004,'(Code B)',0,0,0);   // ERROR
              ERROROUTPUT;  // 01.07.2019
//              if (Mode=c_ModeEdit) then RecRead(703,1,_recLock);
              vErr # -1;
              BREAK;
            end;
          end;
          end
        else begin
          vKGMM_Kaputt # BA1_IO_Data:KGMM_Check(vKGMM1, vKGMM2);
        end;

        Erx # RecLink(701,702,2,_recNext);
      END;  // Input

      // Fehlerbehandlung
      if (vTLGErr<>0) then begin
        TRANSBRK;
        Msg(vTlgErr,anum(vKGMM1,2)+'|'+anum(vKGMM2,2),0,0,0);   // ERROR
        vErr # -1;
        BREAK;
      end;

      if (vKGMM_Kaputt) then begin
        TRANSBRK;
        Msg(703006,aint(BAG.P.Position),_WinIcoWarning, _WinDialogOk, 0);
        vErr # -1;
        BREAK;
      end;

      if (vErr <> 0) then begin
        vErr # -1;
        BREAK;
      end;
      vErr # 0;
    END;

    if (vErr<>0) then begin
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf401);
      RecRead(401,1,0);
      RecRead(701,1,_recLock);
      RecRead(702,1,0);
      RETURN false;
    end;


    // autom. VSB setzen
//debug('BAG.IO.Nummer         : ' + Aint(BAG.IO.Nummer) );
//debug('vBuf701->BAG.IO.Nummer: ' + Aint(vBuf701->Bag.IO.Nummer));
    if (BA1_Lohn_Subs:AutoVSB(BAG.IO.Nummer)=false) then begin
      TRANSBRK;
      RecBufDestroy(vBuf701);
      RecBufDestroy(vBuf702);
      ErrorOutput;
      RETURN false;
    end;

    TRANSOFF;

    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf401);
    RecRead(401,1,0);
    RecRead(701,1,0);
    RecRead(702,1,0);

    PtD_Main:Compare(701);

    BA1_P_Data:UpdateSort();
  end;// Änderungsmodus Ende

/*
  PtD_Main:Forget(701);
*/
  // AFX?
  RunAFX('BAG.Output.Check','');

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
local begin
  v701 : int;
end
begin

  if (Mode=c_ModeEdit) then begin
    v701 # RekSave(701);
    if (BA1_Lohn_Subs:AutoVSB(BAG.IO.Nummer)=false) then begin
      RekRestore(v701);
      ErrorOutput;
      RETURN false;
    end;
    RekRestore(v701);
  end;

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx       : int;
  vBuf701   : int;
  vBuf707   : int;
  vKill707  : logic;
end;
begin
// ST ALTE VERSION BUGGY!!!!!!
/*
  // Diesen Eintrag wirklich löschen?
//  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
//    RekDelete(gFile,0,'MAN');
//  end;
  if (BA1_IO_I_Data:BereitsVerwogen() = true) then begin
    Msg(701007,'',0,0,0);
    RETURN;
  end;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then
    RETURN;

  APPOFF;
  TRANSON;

  if (BA1_Lohn_Subs:DeleteVSBzuInput()=false) then begin
    APPON;
    ErrorOutput;
    TRANSBRK;
    RETURN;
  end;

  if(BA1_IO_I_Data:DeleteInput() = false) then begin
    APPON;
    TRANSBRK;
    ErrorOutput;
    RETURN;
  end;

  if (BA1_Lohn_Subs:AutoVSB(BAG.IO.Nummer)=false) then begin
    APPON;
    ErrorOutput;
    TRANSBRK;
    RETURN;
  end;

  TRANSOFF;
  BA1_P_Data:UpdateSort();
  APPON;
*/


  // ST NEUE VERSION Kopie aus BA1_IO_I_Main:RecDel
  //                APPOFF und -ON hinzugefügt

  // hierauf bereits verwogen?
  if (BA1_IO_I_Data:BereitsVerwogen() = true) then begin
    Msg(701007,'',0,0,0);
    RETURN;
  end;

  // MS 18.03.2010
  if (BAG.P.Aktion = c_BAG_VSB) then begin
    if(BA1_P_Data:BereitsVerwiegung(BAG.P.Aktion) = true) then begin
      Msg(701026, '', 0, 0, 0);
      RETURN;
    end;
  end;

  // Weiterbearbeitung?
  if (BAG.IO.Materialtyp=c_IO_BAG) then begin
    vBuf701 # RecBufCreate(701);
    vBuf707 # RecBufCreate(707);
    vKill707 # n;
    FOR Erx # RecLink(vBuf707,701,20,_recFirst)
    LOOP Erx # RecLink(vBuf707,701,20,_recNext)
    WHILE (Erx<=_rLocked) and (vKill707=n) do begin
      Erx # RecLink(vBuf701,vBuf707,8,_recFirst);
      if (Erx<=_rLocked) then begin
        if (vBuf701->BAG.IO.NachBAG<>0) then
          vKill707 # y;
      end;
    END;
    RecBufDestroy(vBuf707);
    RecBufDestroy(vBuf701);
  end;


  Mode # c_ModeDelete;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then begin
    Mode # c_ModeList;
    RETURN;
  end;


  if (vKill707) then begin
    if (Msg(701035,'?',_WinIcoWarning,_WinDialogOkCancel, 1)<>_winidok) then begin
      Mode # c_ModeList;
      RETURN;
    end;

    APPOFF();
    TRANSON;

    vBuf701 # RekSave(701);
    vBuf707 # RekSave(707);
    FOR Erx # RecLink(707,701,20,_recFirst)
    LOOP Erx # RecLink(707,701,20,_recNext)
    WHILE (Erx<=_rLocked) do begin
      Erx # RecLink(701,707,8,_recFirst);
      if (Erx<=_rLocked) then begin
        if (BAG.IO.NachBAG<>0) then begin
          if (BA1_FM_Data:SetSperre()<>true) then begin
            TRANSBRK;
            APPON();
            Mode # c_ModeList;
            ErrorOutput;
            RekRestore(vBuf707);
            RekRestore(vBuf701);
            RETURN;
          end;
          ErrorOutput;
        end;
      end;
      RecBufCopy(vBuf701, 701);
      RecBufCopy(vBuf707, 707);
    END;
    RekRestore(vBuf707);
    RekRestore(vBuf701);
    end
  else begin
    APPOFF();
    TRANSON;
  end;


  // NEU: 08.10.2013 AH
  if (BA1_Lohn_Subs:DeleteVSBzuInput()=false) then begin
    APPON();
    ErrorOutput;
    TRANSBRK;
    RETURN;
  end;


  Mode # c_ModeList;

  if (BA1_IO_I_Data:DeleteInput(false) = false) then begin
    TRANSBRK;
    APPON();
    ErrorOutput;
    RETURN;
  end;

  TRANSOFF;
  APPON();

  BA1_P_Data:UpdateSort();
  cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
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
  vSel    : int;
  vSelQ   : alpha(1000);
  vSelName : alpha;
end;
begin

  // Ankerfunktion: ST 2011-01-18
  // Sonderfunktion für abweichende Materialselektion
  if (RunAFX('BA1.IO.Lohn.Auswahl',aBereich) <> 0) then
    RETURN;

  case aBereich of

    'Material', 'KlonMaterial' : begin
      // Kunde = Lieferant => Filter auf Kundenmaterial
      if (BAG.P.Auftragsnr<>0) then begin
        Erx # RecLink(401,702,16,0);      // Auftrag lesen
        if (Erx >= _rLocked) then
          RETURN;
      end;

      Erx # RecLink(100,401,4,0);       // Kunde lesen
      if (Erx >= _rLocked) then
        RETURN;

      RecBufClear(200);         // ZIELBUFFER LEEREN
      if (aBereich='KlonMaterial') then
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusKlonMaterial')
      else
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');

      // Material filtern
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      Lib_Sel:QInt( var vSelQ, 'Mat.Lieferant', '=', Adr.LieferantenNr);
      Lib_Sel:QVonBisI( var vSelQ, 'Mat.Status', c_status_Frei, c_status_bisFrei);
      Lib_Sel:QLogic( var vSelQ, 'Mat.EigenmaterialYN', false);

      vSel # SelCreate( 200, gKey);
      vSel->SelDefQuery( '', vSelQ );
      vSel->Lib_Sel:QError();
      vSelName # Lib_Sel:SaveRun( var vSel, 0,true);
      Lib_Sel:QRecList(0, vSelQ);

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;
end;


//========================================================================
//  _AusMaterialAddMat
//    Extrahiert für wiederholten Aufruf mit unterschiedlichem Kontext
//========================================================================
sub _AusMaterialAddMat(
  aMatNr      : int;
  aKlonVonID  : int)
begin

  TRANSON;

  if (BA1_Lohn_Subs:EinsatzMaterial(aMatNr) = false) then begin
    ErrorOutput;
    TRANSBRK;
    RETURN;
  end;

  if (aKlonVonID<>0) then
    BA1_IO_I_Data:KlonenVon(aKlonVonID);

  // alle Fertigungen neu errechnen
  BA1_P_Data:ErrechnePlanmengen();

  if (BA1_Lohn_Subs:DeleteVSBzuInput() = false) then begin
    Error(701037,Aint(aMatNr)); // 'E:Die VSB Schritte des Einasatzmaterials %1% konnten nicht gelöscht werden.';
    ErrorOutput;
    TRANSBRK;
    RETURN;
  end;

  if (BA1_Lohn_Subs:AutoVSB(BAG.IO.Nummer) = false) then begin
    ErrorOutput;
    TRANSBRK;
    RETURN;
  end;

  TRANSOFF;

end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial();
local begin
  vItem     : int;
  vMFile    : int;
  vMID      : int;
  vMarkCnt  : int;
end
begin

  if (gSelected=0) then RETURN;

  RecRead(200,0,_RecId,gSelected);
  gSelected # 0;

  // ST 2012-05-29: ggf. hier markierte Materialien loopen und einfügen
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=200) then inc(vMarkCnt);
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (vMarkCnt > 0) AND  (Msg(701036 ,cnvai(vMarkCnt),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    // mehrere Übernehmen
    FOR   vItem # gMarkList->CteRead(_CteFirst);
    LOOP  vItem # gMarkList->CteRead(_CteNext,vItem);
    WHILE vItem > 0 DO BEGIN

      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile=200) then begin
        RecRead(200,0,_RecId, vMID);
        _AusMaterialAddMat(Mat.Nummer, 0);
      end;

    END;

    Lib_Mark:Reset(200);
  end
  else begin
    // Nur eine selektierte übernehmen
    _AusMaterialAddMat(Mat.Nummer, 0)
  end;

  gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusKlonMaterial
//
//========================================================================
sub AusKlonMaterial();
local begin
  vItem     : int;
  vMFile    : int;
  vMID      : int;
  vMarkCnt  : int;
  vKlonID   : int;
end
begin

  if (gSelected=00) then RETURN;

  RecRead(200,0,_RecId,gSelected);
  gSelected # 0;

  vKlonID # BAG.IO.ID;

  // ST 2012-05-29: ggf. hier markierte Materialien loopen und einfügen
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=200) then inc(vMarkCnt);
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (vMarkCnt > 0) AND  (Msg(701036 ,cnvai(vMarkCnt),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    // mehrere Übernehmen
    FOR   vItem # gMarkList->CteRead(_CteFirst);
    LOOP  vItem # gMarkList->CteRead(_CteNext,vItem);
    WHILE vItem > 0 DO BEGIN

      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile=200) then begin
        RecRead(200,0,_RecId, vMID);
        _AusMaterialAddMat(Mat.Nummer, vKlonID);
      end;

    END;

    Lib_Mark:Reset(200);
  end
  else begin
    // Nur eine selektierte übernehmen
    _AusMaterialAddMat(Mat.Nummer, vKlonID);
  end;

  gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
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
  Bag.Nummer # Bag.P.Nummer;
  RecRead(700,1,0);

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode=c_modenew) or (mode=c_modeEdit) or (Mode=c_ModeView) or ("BAG.P.Löschmarker"<>'') or ("BAG.Löschmarker"<>'');
  vHdl # gMenu->WinSearch('Mnu.New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode=c_modenew) or (mode=c_modeEdit) or (mode=c_ModeView) or ("BAG.P.Löschmarker"<>'') or ("BAG.Löschmarker"<>'');

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) and ("BAG.P.Löschmarker"='') and ("BAG.Löschmarker"='');
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) and ("BAG.P.Löschmarker"='') and ("BAG.Löschmarker"='');

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) and ("BAG.P.Löschmarker"='') and ("BAG.Löschmarker"='');
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) and ("BAG.P.Löschmarker"='') and ("BAG.Löschmarker"='');

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

    'Mnu.New2'      :   Auswahl('Material');

    'Mnu.Input.WirdTheo' : begin
      if (BAG.IO.Materialtyp=c_IO_Mat) then begin
        BA1_IO_I_Data:EchtWirdTheorie(BAG.IO.ID);
        ErrorOutput;
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect | _WinLstPosSelected);
        RETURN true;
      end;
    end;


    'Mnu.Input.WirdMat' : begin
      if (BAG.IO.Materialtyp=c_IO_Theo) then begin
        BA1_IO_I_Data:TheorieWirdEcht(BAG.IO.ID);
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect | _WinLstPosSelected);
        RETURN true;
      end;
    end;


    'Mnu.Input.Klonen' : begin
      if (BAG.IO.ID<>0) then begin
        Auswahl('KlonMaterial');
      end;
      RETURN true;
    end;


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
    'New2'      :   Auswahl('Material');
  end;

end;


//========================================================================
//  EvtChanged
//              Feldinhalt verändert
//========================================================================
sub EvtChanged (
  aEvt                  : event;        // Ereignis
) : logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  aEvt:Obj->winupdate(_WinUpdObj2Fld);

  case aEvt:obj->wpname of

    'cbBAG.IO.AutoTeilungYN' : begin
      if (BAG.IO.AutoTeilungYN) then begin
        Lib_GuiCom:Disable($edBAG.IO.Teilungen);
        end
      else begin
        Lib_GuiCom:Enable($edBAG.IO.Teilungen);
      end;
    end;


   'edBAG.IO.Teilungen' : begin
//     getRinglRad();
   end;

  end;  // case

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
  BA1_IO_I_Main:EvtLstDataInit(aEvt,aRecId, aMark);
  Mat_Data:Read(BAG.IO.Materialnr);
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


//=========================================================================
// EvtDropEnter
//        Objekt betreten
//=========================================================================
sub EvtDropEnter ( aEvt : event; aDataObject : handle; aEffect : int ) : logic
local begin
  vA    : alpha;
  vFile : int;
end;
begin
  if ( aDataObject->wpFormatEnum( _winDropDataText ) ) then begin
    vA    # StrFmt( aDataObject->wpName, 30, _strEnd );
    vFile # CnvIA( StrCut( vA, 1, 3 ) );
    if ( vFile = 200 ) then begin
      aEffect # _winDropEffectCopy | _winDropEffectMove;
      RETURN true;
    end;
  end;

  RETURN false;
end;


//=========================================================================
// EvtDrop
//        Drag&Drop Operation ausführen
//=========================================================================
sub EvtDrop ( aEvt : event; aDataObject : handle; aDataPlace : handle; aEffect : int; aMouseBtn : int ) : logic
local begin
  vArg    : alpha;

  vA      : alpha;
  vFile   : int;
  vID     : int;
  vPos    : int;
  vNr     : int;
  vOK     : logic;
end;
begin


  if ( aDataObject->wpFormatEnum( _winDropDataText ) ) then begin
    vA    # StrFmt( aDataObject->wpName, 30, _strEnd );
    vFile # CnvIA( StrCut( vA, 1, 3 ) );
    vId   # CnvIA( StrCut( vA, 5, 15 ) );
    if ( vFile != 200 ) or ( vID = 0 ) then
      RETURN false;

    if ( RecRead( vFile, 0, _recId, vId ) != _rOk ) then
      RETURN false;

    // Auftrag
    if ( RecLink( 401, 702, 16, 0 ) >= _rLocked ) then
      RETURN false;

    // Kunde
    if ( RecLink( 100, 401, 4, 0 ) >= _rLocked ) then
      RETURN false;

    // Überprüfung der Materialparameter  (Ganze Prozedur nicht ersetzbar, wegen "handle" in Argumenten )
    // Ankerfunktion: ST 2011-01-19
    if (RunAFX('BA1.IO.Lohn.EvtDropMatCheck','') <> 0) then begin

      if (AfxRes<>_rOk) then begin
        RETURN false;
      end;

    end else begin

      // Standardverhalten
      if ( Mat.Lieferant != Adr.LieferantenNr ) or ( Mat.Status < c_Status_Frei ) or
          ( Mat.Status > c_Status_bisFrei ) or ( Mat.EigenmaterialYN ) then
        RETURN false;

    end;

    BA1_Lohn_Subs:EinsatzMaterial( Mat.Nummer );

    // ST 2011-03-23: Änderungen Updaten
    // alle Fertigungen neu errechnen
    BA1_P_Data:ErrechnePlanmengen();

    BA1_Lohn_Subs:DeleteVSBzuInput();
    BA1_Lohn_Subs:AutoVSB(BAG.IO.Nummer);

    cZList->WinUpdate( _winUpdOn, _winLstFromFirst | _winLstRecDoSelect );

    RETURN true;
  end;

	RETURN false;
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================