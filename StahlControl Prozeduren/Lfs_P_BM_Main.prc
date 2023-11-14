@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lfs_P_BM_Main
//                      OHNE E_R_G
//  Info  Verwaltungsprozedur für die Lieferscheinerstellung aus dem
//       Betriebsmenü
//
//
//  02.05.2010  AI  Erstellung der Prozedur
//  05.05.2011  TM  neue Auswahlmethode 1326/75
//  15.10.2012  ST  Ankerfunktionsaufruf beim Verbuchen der VLDAW eingefügt
//  08.04.2014  AH  Erweiterung für Scanner + "CheckNummer"
//  30.06.2015  ST  AFX "Lfs.P.BM.VLDAW.EvtFocusTerm" für Lfs aus VLDAW hinzugefügt
//  07.01.2016  ST  Betrieb VLDAW: Recht für manuelle Freigabe (Button) hinzugefügt
//  24.03.2016  AH  GetAlternativeName für Maks eeingebaut
//  29.05.2018  ST  Afx "Lfs.P.Init" und "Lfs.P.Init.Pre" hinzugefügt
//  13.11.2018  AH  AFX "Lfs.P.BM.InsertPos"
//  03.01.2019  AH  Markedlöschen
//  06.09.2019  ST  Löschen von Paketen entfernt alle dazugehörigen Materialien
//  09.06.2022  AH  ERX
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
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB MyEvtKeyItem(aEvt : event; aKey : int; aRecID : int) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//    SUB InsertPos();
//    SUB CheckNummer(aVLDAWHdl : int; aDL : int; aWertHdl : int) : alpha;
//
//    sub _LfsBetriebVLDAW_Verbuchen(aWin : int)
//    sub _LfsBetriebVLDAW_AddLineLfsPos(aDL : int; aStatus : alpha)
//    sub _LfsBetriebVLDAW_Scan(aDL : int)
//    sub _LfsBetriebVLDAW_Del(aDL : int)
//    sub _LfsBetriebVLDAW_EvtClicked(  aEvt   : event;
//    sub _LfsBetriebVLDAW_Sum(aDL : int)
//    sub _LfsBetriebVLDAW_EvtLstDataInit(aEvt: Event;aRecId : int;  Opt aMark : logic;)
//    sub _LfsBetriebVLDAW_EvtFocusInit...
//    sub _LfsBetriebVLDAW_EvtFocusTerm...
//    sub _LfsBetriebVLDAW_EvtInit(aEvt  : event;): logic
//    sub LfsBetriebVLDAW()
//
//    sub Scanner(aWert : alpha; var aRes : alpha);
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Lieferschein-Positionen'
  cFile :     441
  cMenuName : 'Lfs.P.BM.Bearbeiten'
  cPrefix :   'Lfs_P_BM'
  cZList :    $ZL.Lfs.Positionen
  cKey :      1

  cCR         : Strchar(13)
  cESC        : Strchar(27)
end;

declare InsertPos();
declare _LfsBetriebVLDAW_Sum(aDL : int)
declare _LfsBetriebVLDAW_AddLineLfsPos(aDL : int; aStatus : alpha)

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
  if (lfs.nummer<1000000000) then begin
    $lb.LFSNummer->wpcaption # cnvai(lfs.Nummer);
    end
  else begin
    $lb.LFSNummer->wpcaption # 'geplant';
  end;

  SetStdAusFeld('edxxxxxx'        ,'xxxxxx');

  RunAFX('Lfs.P.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Lfs.P.Init',aint(aEvt:Obj));
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
  Erx     : int;
  vA      : alpha(250);
  vMenge  : float;
  vUpMask : logic;

  vNetto      : float;
  vBrutto     : float;
  vStk        : int;
  vTmp        : int;
end;
begin

  if (Mode=c_ModeList) then begin
    Erx # RecLink(441, 440, 4, _recFirst);
    WHILE(Erx <= _rLocked) DO BEGIN
      vNetto  # vNetto  + Lfs.P.Gewicht.Netto;
      vBrutto # vBrutto + Lfs.P.Gewicht.Brutto;
      vStk    # vStk    + "Lfs.P.Stück";
      Erx # RecLink(441, 440, 4, _recNext);
    END;

    $lb.Sum.Netto->wpcustom     # 'DONE';
    $lb.Sum.Netto->wpcaption    # ANum(vNetto, Set.Stellen.Gewicht);
    $lb.Sum.Brutto->wpcaption    # ANum(vBrutto, Set.Stellen.Gewicht);
    $lb.Sum.Stueck->wpcaption   # aInt(vStk);
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
begin
  $aaa->WinFocusSet(true);
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
    Lfs.P.Anlage.Datum  # Today;
    Lfs.P.Anlage.Zeit   # Now;
    Lfs.P.Anlage.User   # gUserName;
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
//  sub DeletePaketMats(aPaketNr : int) : logic;
//      Löscht alle Materalien eines Pakets
//========================================================================
sub DeletePaketMats(aPaketNr : int) : logic;
local begin
  Erx   : int;
  vErx  : int;
  v441  : int;
end
begin
  if (aPaketNr = 0) then
    RETURN true;
  
  v441 # RekSave(441);
             
  // ggf. andere Positionen von diesem Paket löschen
  if (aPaketNr <> 0) then begin

    vErx # RecLink(441,440,4,_RecFirst);
    WHILE vErx = _rOK DO BEGIN

        if (Lfs.P.PaketNr <> aPaketNr) then begin
          vErx # RecLink(441,440,4,_RecNext);
          CYCLE;
        end;

      // bisherige VLDAW stornieren
      if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<100000000) then begin
        if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
          RekRestore(v441);
          RETURN false;
        end;
      end;

      Erx # RekDelete(gFile,0,'MAN');
      if (Erx<>_rOK) then begin
        RekRestore(v441);
        RETURN false;
      end;

      vErx # RecLink(441,440,4,_RecFirst);
    END;     // LFS Loop
  end;

  RekRestore(v441);
  RETURN true;
end;

//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx   : int;
  v441  : int;
  vAnz  : int;
  vPaket : int;
end;
begin

  // 03.01.2019 AH: Markedlöschen
  v441 # RekSave(441);
  FOR Erx # RecLink(441,440,4,_recFirst)
  LOOP Erx # RecLink(441,440,4,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lib_Mark:IstMarkiert(441, RecInfo(441, _RecID))) then begin
      inc(vAnz);
    end;
  END;
  RekRestore(v441);
  
  if (vAnz>0) then begin
    // alle Einträg wirklich löschen?
    if (Msg(000050,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;
    v441 # RekSave(441);
    Erx # RecLink(441,440,4,_recFirst)
    WHILE (Erx<=_rLocked) do begin
      if (Lib_Mark:IstMarkiert(441, RecInfo(441, _RecID))) then begin
        vPaket  # Lfs.P.Paketnr;
        RekDelete(gFile,0,'MAN');
        DeletePaketMats(vPaket);
        
        Erx # RecLink(441,440,4,0);
        Erx # RecLink(441,440,4,0);
        CYCLE;
      end;
      Erx # RecLink(441,440,4,_recNext)
    END;
    RekRestore(v441);
    RefreshIfm();
    RETURN;
  end;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    vPaket  # Lfs.P.Paketnr;
    RekDelete(gFile,0,'MAN');
    DeletePaketMats(vPaket);
  end;

  RefreshIfm();
  cZList->winupdate(_WinUpdOn, _WinLstRecFromRecId|_WinLstRecDoSelect);
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

/***
  if (aEvt:Obj->wpname='jump') then begin
    case (aEvt:Obj->wpcustom) of
      'Page1Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false)
        end;
      'Page1E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false);
        end;
    end;
    RETURN true;
  end;
***/

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
  end;  // ...case

end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl    : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # n;
  vHdl # gMenu->WinSearch('Mnu.New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # n;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

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

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.New2' : InsertPos();


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Lfs.P.Anlage.Datum, Lfs.P.Anlage.Zeit, Lfs.P.Anlage.User);
    end;

  end; // ...case


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
    'New2'      :   InsertPos();
  end;  // ...case

end;


//========================================================================
//  MyEvtKeyItem
//            Keyboard in RecList/DataList
//========================================================================
sub MyEvtKeyItem(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aRecID                : int;          // RecID
) : logic
begin
  if (aKey=_WinKeyReturn) and (Mode=c_ModeList) then RETURN true;

  RETURN App_Main:EvtKeyItem(aEvt, aKey, aRecID);
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
  Lfs_P_Main:EvtLstDataInit(aEvt, aRecId, aMark);
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
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
// InsertPos
//
//========================================================================
sub InsertPos();
local begin
  Erx     : int;
  vName   : alpha(1000);
  vFile   : int;
  vA      : alpha(1000);
  vNr     : int;
  vPos    : int;
  vErr    : int;
  vKLim   : float;
  vMat    : int;
  vFirst  : logic;
end;
begin

  // 13.11.2018 AH:
  if (RunAFX('Lfs.P.BM.InsertPos','')<>0) then RETURN;

  Erx # RecLink(441,440,4,_recLast);    // letzte Pos holen
  if (Erx>_rLocked) then begin
    vPos # 1;
    vFirst # y;
    end
  else begin
    vPos # Lfs.P.Position + 1;
  end;
  RecBufClear(441);

  Erx # Msg(19999,'Manuell?',_WinIcoQuestion, _WinDialogYesNoCancel, 2);
  if (Erx=_WinIdCancel) then RETURN;

  if (Erx=_WinIdYes) then begin
    if (Dlg_Standard:Standard_Small(Translate('Materialnummer'),var vA)=true) then begin
      vMat  # cnvia(vA);
      if (MC9090_Subs:_Lfs_InsertMat(vMat, var vPos)=faLSe) then begin
        ErrorOutput;
        RETURN;
      end;
      if (vFirst) then begin
        // Kreditlimit prüfen...
        if ("Set.KLP.LFS-Druck"<>'') then
          if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.LFS-Druck",n, var vKLim,0, Lfs.P.Auftragsnr)=false) then RETURN;
      end;
    end;
     cZList->winupdate(_WinUpdOn, _WinLstRecFromRecId|_WinLstRecDoSelect);
    RefreshIfm();
    RETURN;
  end;

  // ggf. Ankerfunktion Setting überschreiben lassen
  Erx # RunAFX('Lfs.P.BM.Scanner','');

  // Datei öffnen...
  vName # Set.LFS.BM.ScanPfad;

  vFile # FSIOpen(vName,_FsiAcsR|_FsiDenyW);
  if (vFile<=0) then begin
    RefreshIfm();
    cZList->winupdate(_WinUpdOn, _WinLstRecFromRecId|_WinLstRecDoSelect);
    Msg(19999,'Datei '+vName+' nicht lesbar!',0,0,0);
    RETURN;
  end;

  vFirst # y;
  FsiMark(vFile,10);
  FsiRead(vFile, vA);
  WHILE (vA<>'') do begin
    vNr   # cnvia(vA);
    if (MC9090_Subs:_LFS_InsertMat(vNr,var vPos)=false) then begin
      vErr # 1;
      if (Set.LFS.BM.FehlIgnYN = false) then
        BREAK;
    end;

    if (vFirst) then begin
      vFirst # n;
      // Kreditlimit prüfen...
      if ("Set.KLP.LFS-Druck"<>'') then
        if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.LFS-Druck",n, var vKLim,0, Lfs.P.Auftragsnr)=false) then begin
          vErr # 2;
        end;
    end;

    FsiRead(vFile, vA);
  END;
  FsiClose(vFile);

  RefreshIfm();
  cZList->winupdate(_WinUpdOn, _WinLstRecFromRecId|_WinLstRecDoSelect);

  if (vErr<>0) then begin
    if (vErr=1) then
      ErrorOutput;
    Msg(441008,'',0,0,0);
    RETURN;
  end;

  RefreshIfm();
  cZList->winupdate(_WinUpdOn, _WinLstRecFromRecId|_WinLstRecDoSelect);
end;


//========================================================================
//  CheckNummer
//========================================================================
sub CheckNummer(
  aVLDAWHdl : int;
  aDL       : int;
  aWertHdl  : int;
  ) : alpha;
local begin
  vLfs          : int;
  vZeilen, vZeile : int;
  vStatus       : alpha;

  vMat          : int;
  vLfsMat       : int;
  vLfsMatPos    : int;

  vStkGes       : int;
  vGewGes       : float;
  vSeriennr     : alpha;
  vSeriennrNeu  : alpha;
  vErx          : int;
end;
begin

  vZeilen # aDL->WinLstDatLineInfo(_WinLstDatInfoCount);
  if (vZeilen = 0) then begin
    aVLDAWHdl->wpDisabled  # false;
    WinFocusSet(aVLDAWHdl);
    RETURN Translate('keine VLDAD angegeben');
  end;

  if (StrFind(aWertHdl->wpCaption,'S',1) = 1) then begin
    // ----------------------------------------------
    // Paketnummer eingescannt

    // Paket lesen
    Pak.Nummer # CnvIa(aWertHdl->wpCaption);
    if (RecRead(280,1,0) <> _rOK) then begin
      // Paketnummer nicht bekannt;
      RETURN Translate('Paket nicht gefunden');
    end;

    // Enthaltene Materialien markieren
    FOR   vErx # RecLink(281,280,1,_RecFirst);
    LOOP  vErx # RecLink(281,280,1,_RecNext);
    WHILE (vErx = _rOK) DO BEGIN

      Mat.Nummer # Pak.P.MaterialNr;
      if (RecRead(200,1,0) <> _rOK) then begin
        RETURN Translate('Nr. nicht gefunden');
      end;

      vMat # Pak.P.MaterialNr;

      // Material passt in Lieferschein?
      vLfsMatPos # -1;
      vZeilen # aDL->WinLstDatLineInfo(_WinLstDatInfoCount);
      vStatus # '';
      FOR vZeile # 1
      LOOP inc(vZeile)
      WHILE (vZeile <= vZeilen) DO BEGIN
        aDL->WinLstCellGet(vStatus, 1, vZeile);
        aDL->WinLstCellGet(vLfsMat, 3, vZeile);
        if (vLfsMat = vMat)  then begin
          // Material gefunden,
          vLfsMatPos # vZeile;
          BREAK;
        end;
      END;

      // Gefundener Lieferschein markieren
      if (vLfsMatPos < 0) then begin
        // Material ist nicht auf Lieferschein, Fehlscan darstellen
        RecBufClear(441);
        _LfsBetriebVLDAW_AddLineLfsPos(aDL,'SCAN');

      end else if (vLfsMatPos > 0) then begin
        if (vStatus = '') then begin
          aDL->WinLstCellSet('OK', 1, vLfsMatPos);
        end;
      end;

      // weiter:  Nächstes Material im Paket
    END;

    _LfsBetriebVLDAW_Sum(aDL);

    aWertHdl->wpCaption # '';
    WinFocusSet(aWertHdl);
    RETURN '';

  end else begin
    // ----------------------------------------------
    // Materialnummer eingescannt

    // Materialr nr lesen und ggf. adden
    vMat # CnvIa(aWertHdl->wpCaption);
    if (vMat  = 0) then
      RETURN Translate('unbekannte Nummer');

    Mat.Nummer # vMat;
    // Prüfen ob Materialnummer im Bestand?
    if (RecRead(200,1,0) <> _rOK) then begin
      //Dlg_Standard:InfoBetrieb('ACHTUNG','Materialnummer ist nicht bekannt',true);
      RETURN Translate('Nr. nicht gefunden');
    end;

  end;

  // Weitere Plausis
  if ("Mat.Löschmarker" <> '') then begin
    // Dlg_Standard:InfoBetrieb('ACHTUNG','Das Material ist schon gelöscht',true);
    RETURN Translate('Mat. ist gelöscht');
  end;

  // Material passt in Lieferschein?
  vLfsMatPos # -1;
  vZeilen # aDL->WinLstDatLineInfo(_WinLstDatInfoCount);
  vStatus # '';
  FOR vZeile # 1
  LOOP inc(vZeile)
  WHILE (vZeile <= vZeilen) DO BEGIN
    aDL->WinLstCellGet(vStatus, 1, vZeile);
    aDL->WinLstCellGet(vLfsMat, 3, vZeile);
    if (vLfsMat = vMat)  then begin
      // Material gefunden,
      vLfsMatPos # vZeile;
      BREAK;
    end;
  END;

  // Gefundener Lieferschein markieren
  if (vLfsMatPos < 0) then begin
    // Material ist nicht auf Lieferschein, Fehlscan darstellen
    RecBufClear(441);
    _LfsBetriebVLDAW_AddLineLfsPos(aDL,'SCAN');

  end else if (vLfsMatPos > 0) then begin
    if (vStatus = '') then begin
      aDL->WinLstCellSet('OK', 1, vLfsMatPos);
    end;
  end;

  _LfsBetriebVLDAW_Sum(aDL);

  aWertHdl->wpCaption # '';
  WinFocusSet(aWertHdl);
  RETURN '';
end;


//========================================================================
//    sub _LfsBetriebVLDAW_Verbuchen(aWin : int)
//      Verbucht die Paketnummer an den Materialien
//========================================================================
sub _LfsBetriebVLDAW_Verbuchen(aWin : int)
local begin
  vDl           : int;
  vZeilen,
  vZeile        : int;
  vLfs          :  int;
  vStatus       : alpha;
  vMaterial     : int;
  vStatusGesamt : alpha;
  vDat          : date;
  vHdl          : int;
end
begin

  if (RunAFX('Lfs.P.BM.VLDAW.Verbuchen','') <> 0) then
    RETURN;


  vDL # Winsearch(gFrmMain, Lib_GuiCom:GetAlternativeName('Lfs.P.BM.VLDAW'));
  vDL # Winsearch(vDL,'DLMats');

  // Prüfung auf
  vZeilen # vDL->WinLstDatLineInfo(_WinLstDatInfoCount);
  FOR vZeile # 1
  LOOP inc(vZeile)
  WHILE (vZeile <= vZeilen) DO BEGIN
    vDL->WinLstCellGet(vStatus, 1, vZeile);
    vDL->WinLstCellGet(vMaterial, 3, vZeile);

    if (StrFind(vStatusGesamt, '"'+vStatus+'"',1) = 0) then
      vStatusGesamt # vStatusGesamt  + '"'+vStatus+'"';

    case vStatus of
      '' : begin
          Dlg_Standard:InfoBetrieb(Translate('Fehler'),Translate('Das Material ') +Aint(vMaterial)+ StrChar(10)+
                                   Translate(' wurde noch nicht gescannt!'),true);
          return;
      end;
      'SCAN' : begin
          Dlg_Standard:InfoBetrieb(Translate('Fehler'),Translate('Das Material ') +Aint(vMaterial)+ StrChar(10)+
                                            Translate(' soll nicht geliefert werden!'),true);
          return;
      end;
    end;

  END;

  // ab hier sind alle Materialien drin

  Lfs.Nummer # CnvIa($edVerladeanweisung->wpCaption);
  if (RecRead(440,1,0) <> _rOK) then begin
    Dlg_Standard:InfoBetrieb(Translate('Fehler'),Translate('Fehler beim Lesen der Verladeanweisung'),true);
    RETURN;
  end;

  // Abschluss
  vHdl # Winsearch(gFrmMain, Lib_GuiCom:GetAlternativeName('Lfs.P.BM.VLDAW'));
  vHdl->winclose();

  // Lieferschein drucken
  if (Lfs_Data:Druck_LFS()) then begin

    if (Msg(440007,'',_WinIcoQuestion,_WinDialogYesNo,1)=_winIdyes) then begin
      Lfs_Data:Verbuchen(Lfs.Nummer, today, now);
      ErrorOutput;
    end else
      RETURN;
  end;

end;


//========================================================================
//  sub _LfsBetriebVLDAW_AddLineLfsPos(aDL : int)
//    Fügt eine Zeile in die Datalist ein
//========================================================================
sub _LfsBetriebVLDAW_AddLineLfsPos(aDL : int; aStatus : alpha)
local begin
  vSpalte : int;
end begin
  vSpalte # 1;
  aDL->WinLstDatLineAdd(aStatus);     inc(vSpalte);
  aDL->WinLstCellSet(Lfs.P.Position     ,vSpalte,_WinLstDatLineLast);inc(vSpalte);
  aDL->WinLstCellSet(Mat.Nummer         ,vSpalte,_WinLstDatLineLast);inc(vSpalte);
  aDL->WinLstCellSet(Mat.Dicke          ,vSpalte,_WinLstDatLineLast);inc(vSpalte);
  aDL->WinLstCellSet(Mat.Breite         ,vSpalte,_WinLstDatLineLast);inc(vSpalte);
  aDL->WinLstCellSet("Lfs.P.Stück"      ,vSpalte,_WinLstDatLineLast);inc(vSpalte);
  aDL->WinLstCellSet(Lfs.P.Gewicht.Netto,vSpalte,_WinLstDatLineLast);inc(vSpalte);
  aDL->WinLstCellSet(Mat.Werksnummer    ,vSpalte,_WinLstDatLineLast);inc(vSpalte);
end;


//========================================================================
//  sub _LfsBetriebVLDAW_Del(aDL : int)
//    löscht die Scanmarkierung oder Löscht ein Material aus der Liste
//========================================================================
sub _LfsBetriebVLDAW_Del(aDL : int)
local begin
  vStatus  : alpha
end
begin
  aDL->WinLstCellGet(vStatus, 1, aDL->wpCurrentInt);
  if (vStatus = 'OK') then begin
    // Zeile leeren
    aDL->WinLstCellSet('', 1, aDL->wpCurrentInt);
  end else
  if (vStatus = 'SCAN') then begin
    // Zeile löschen
    aDL->WinLstDatLineRemove(aDL->wpCurrentInt);
  end else begin
    // Zeile als OK vermerken
    if (Rechte[Rgt_Betrieb_LFS_VLDAW_Freigabe]) then
      aDL->WinLstCellSet('OK', 1, aDL->wpCurrentInt);
  end;
end;


//========================================================================
//  sub _LfsBetriebVLDAW_Del(aDL : int)
//    löscht die Scanmarkierung oder Löscht ein Material aus der Liste
//========================================================================
sub _LfsBetriebVLDAW_FromScanner(aDL : int)
local begin
  Erx     : int;
  // Datei einlesen
  vFile : int;
  vName : alpha(1000);
  vFirst : logic;
  vA    : alpha;

  // Einfügen in Liste
  vErx        : int;
  vZeile      : int;
  vZeilen     : int;
  vStatus     : alpha;
  vMat        : int;
  vLfsMat    : int;
  vLfsMatPos : int;
end
begin

  // ggf. Ankerfunktion Setting überschreiben lassen
  Erx # RunAFX('Lfs.P.BM.Scanner','');

  // Datei öffnen...
  vName # Set.LFS.BM.ScanPfad;

  vFile # FSIOpen(vName,_FsiAcsR|_FsiDenyW);
  if (vFile<=0) then begin
    if (cZList > 0) then
      cZList->winupdate(_WinUpdOn, _WinLstRecFromRecId|_WinLstRecDoSelect);
    Msg(19999,'Datei '+vName+' nicht lesbar!',0,0,0);
    RETURN;
  end;

  vFirst # y;
  FsiMark(vFile,10);
  FsiRead(vFile, vA);
  WHILE (vA<>'') do begin
    vMat  # cnvia(vA);

    Mat.Nummer # vMat;
    if (RecRead(200,1,0) <> _rOK) then begin
      Mat.Nummer # vMat;
      //RETURN ;//false;
    end;


    vMat # Mat.Nummer;

    // Material passt in Lieferschein?
    vLfsMatPos # -1;
    vZeilen # aDL->WinLstDatLineInfo(_WinLstDatInfoCount);
    vStatus # '';
    FOR vZeile # 1
    LOOP inc(vZeile)
    WHILE (vZeile <= vZeilen) DO BEGIN
      aDL->WinLstCellGet(vStatus, 1, vZeile);
      aDL->WinLstCellGet(vLfsMat, 3, vZeile);
      if (vLfsMat = vMat)  then begin
        // Material gefunden,
        vLfsMatPos # vZeile;
        BREAK;
      end;
    END;

    // Gefundener Lieferschein markieren
    if (vLfsMatPos < 0) then begin
      // Material ist nicht auf Lieferschein, Fehlscan darstellen
      RecBufClear(441);
      _LfsBetriebVLDAW_AddLineLfsPos(aDL,'SCAN');

    end else if (vLfsMatPos > 0) then begin
      if (vStatus = '') then
        aDL->WinLstCellSet('OK', 1, vLfsMatPos);
    end;




    FsiRead(vFile, vA);
  END;
  FsiClose(vFile);

  $edMat->wpCaption # '';
  WinFocusSet($edMat);
  RETURN; //true;
end;



//========================================================================
//    sub _LfsBetriebVLDAW_EvtClicked(  aEvt   : event;) : logic
//
//========================================================================
sub _LfsBetriebVLDAW_EvtClicked(
  aEvt   : event;
) : logic
begin
  case (aEvt:Obj->wpName) of
    'Del' : begin
      _LfsBetriebVLDAW_Del($DLMats);
    end;
    'OK' : begin
      _LfsBetriebVLDAW_Verbuchen($DLMats);
    end;
    'bt.Scanner' : begin
      _LfsBetriebVLDAW_FromScanner($DLMats);
    end;
  end;

  _LfsBetriebVLDAW_Sum($DLMats);
end;


//========================================================================
//    sub _LfsBetriebVLDAW_Sum(aWin : int)
//      Summiert die Gewichtsspalte und zählt die Anzahl der Ringe
//========================================================================
sub _LfsBetriebVLDAW_Sum(aDL : int)
local begin
  vDl : int;
  vZeilen, vZeile : int;
  vMat    : int;
  vGew    : float;
  vGewGes : float;

  vStk    : int;
  vStkGes : int;
  vStatus : alpha;
end
begin
  vZeilen # aDL->WinLstDatLineInfo(_WinLstDatInfoCount);
  vStkGes # 0;
  vGewGes # 0.0;
  FOR vZeile # 1
  LOOP inc(vZeile)
  WHILE (vZeile <= vZeilen) DO BEGIN
    aDL->WinLstCellGet(vStatus, 1, vZeile);
    if (vStatus <> '') then begin
      // Stk aus Liste lesen
      aDL->WinLstCellGet(vStk, 6, vZeile);
      vStkGes # vStkGes + vStk;

      // Gewicht aus Liste lesen
      aDL->WinLstCellGet(vGew, 7, vZeile);
      vGewGes # vGewGes + vGew;
    end;
  END;

  $lbStkIst->wpCaption # CnvAi(vStkGes,_FmtNumNoZero,0,0);
  $lbGewIst->wpCaption # CnvAf(vGewGes,_FmtNumNoZero,0,0);
end;


//========================================================================
//    sub _LfsBetriebVLDAW_EvtLstDataInit(aEvt : Event;aRecId    : int; Opt aMark : logic; )
//
//========================================================================
sub _LfsBetriebVLDAW_EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
)
local begin
  vCellHdl  : int;
  vCol      : int;
  vCell     : int;
  vStatus   : alpha;

  vInputCnt, vInputIO, vInputFail : int;
  i : int;
end
begin
  // Daten lesen
  vCellHdl # aEvt:Obj;
  vCellHdl->WinLstCellGet(vStatus, 1, aRecId);

  case (vStatus) of
    'OK'    : vCol # ColorRgbMake(161,255,135);
    'SCAN'  : vCol # ColorRgbMake(255,161,135);
    otherwise vCol # _WinColWhite;
  end;

  // Zellen einer Zeile einfärben
  i # 0;
  FOR  vCell # vCellHdl->WinInfo( _winFirst, 0, _winTypeListColumn );
  LOOP vCell # vCell->   WinInfo( _winNext, 0, _winTypeListColumn );
  WHILE ( vCell != 0 ) DO BEGIN

    vCell->wpClmColBkg # vCol;
    inc(i);

    if (i%2 = 0) then
      vCell->wpClmColFocusOffBkg # vCol;
    else
      vCell->wpClmColFocusOffBkg # _WinColLightYellow;
  END;

  RETURN;
end;


//========================================================================
// _LfsBetriebVLDAW_EvtFocusInit
//
//========================================================================
sub _LfsBetriebVLDAW_EvtFocusInit(
  aEvt                 : event;    // Ereignis
  aFocusObject         : handle;   // Objekt, das den Fokus zuvor hatte
) : logic;
begin
  gJobEvtProc # Here+':Scanner';
  RETURN(true);
end;


//========================================================================
// _LfsBetriebVLDAW_EvtFocusTerm(aEvt : event; aFocusObject : handle;) : logic
//
//========================================================================
sub _LfsBetriebVLDAW_EvtFocusTerm(
  aEvt         : event;
  aFocusObject : handle;
) : logic
local begin
  Erx       : int;
  vDL       : int;
  vLfs      : int;
  vZeilen, vZeile : int;
  vStatus   : alpha;
  vOK       : logic;

  vMat       : int;
  vLfsMat    : int;
  vLfsMatPos : int;

  vStkGes : int;
  vGewGes : float;

  vSeriennr : alpha;
  vSeriennrNeu : alpha;

  vErx : int;
end
begin

  gJobEvtProc # '';

  // Ankerfunktion
  if (RunAFX('Lfs.P.BM.VLDAW.EvtFocusTerm',Aint(aEvt:Obj) + '|' + Aint(aFocusObject)) <> 0) then begin
    if (AfxRes<>_rOK) then
      RETURN false;
    else
      RETURN true;
  end;


  // Falls schon Lieferscheinpositionen gescannt sind, dann keine Eingabe das Verladeanweisung erlauben
  vDL # Winsearch(gFrmMain, Lib_GuiCom:GetAlternativeName('Lfs.P.BM.VLDAW'));
  vDL # Winsearch(vDL, 'DLMats');

  if (aFocusObject  = 0) then
    RETURN true;

  if (aFocusObject <> 0) AND (aFocusObject->wpName = 'Abbruch') then
    RETURN true;

  case (aEvt:Obj->wpName) OF

    'edMat' : begin
      CheckNummer($edVerladeanweisung, vDL, $edMat);
      RETURN true;
    end;


    'edVerladeanweisung' : begin

      // Verladeanweisung nur bei Leerer Liste auswählbar
      vZeilen # vDL->WinLstDatLineInfo(_WinLstDatInfoCount);
      if (vZeilen > 0) then begin
        $edVerladeanweisung->wpDisabled  # true;
        WinFocusSet($edMat);
        RETURN false;
      end;

      vLfs # CnvIa($edVerladeanweisung->wpCaption);
      if (vLfs = 0) then begin
        RETURN false;
      end;


      // Plausis
      Lfs.Nummer # vLfs;
      if (RecRead(440,1,0) <> _rOK) then begin
        Dlg_Standard:InfoBetrieb(Translate('Fehler'),Translate('Verladeanweisung ') + Aint(vLfs) + Translate(' konnte nicht gelesen werden!'),true);
        RETURN false;
      end;

      // Schon verbucht?
      if (Lfs.Datum.Verbucht <> 00.00.00) then begin
        Dlg_Standard:InfoBetrieb(Translate('Fehler'),Translate('Verladeanweisung ') + Aint(Lfs.Nummer) + Translate(' ist schon verbucht!'),true);
        RETURN false;
      end;

      // Schon gelöscht?=?
      if ("Lfs.Löschmarker" = '*') then begin
        Dlg_Standard:InfoBetrieb(Translate('Fehler'),Translate('Verladeanweisung ') + Aint(Lfs.Nummer) + Translate(' ist schon gelöscht!'),true);
        RETURN false;
      end;

      // Lieferscheininfo oben anzeigen
      vStkGes # 0;
      vGewGes # 0.0;

      $lbLieferscheininfo->wpCaption # '';
      $lbLieferscheininfo->wpCaption # Lfs.Kundenstichwort;

      // Datalist füllen
      if (vDL > 0) then begin

        vDL->wpAutoUpdate # false;
        vDL->WinLstDatLineRemove(_WinLstDatLineAll);

        // Daten in DL einfügen
        FOR Erx # RecLink(441,440,4,_RecFirst)
        LOOP Erx # RecLink(441,440,4,_RecNext)
        WHILE (Erx = _rOK) DO BEGIN
          // Material
          if (RecLink(200,441,4,0)<> _rOK) then
            RecBufClear(200);

          // Auftrag
          if (RecLink(401,441,5,0)<> _rOK) then
            RecBufClear(401);

          if ("Lfs.P.Stück" = 0) then
            "Lfs.P.Stück" # 1;
          vStkGes # vStkGes + "Lfs.P.Stück";
          vGewGes # vGewGes + "Lfs.P.Gewicht.Netto";

          // Daten in DL einfügen
          _LfsBetriebVLDAW_AddLineLfsPos(vDL, '');
        END;

        $lbStkPlan->wpCaption # Aint(vStkGes);
        $lbGewPlan->wpCaption # CnvAf(vGewGes,_FmtNumNoZero,0,0);

        vDL->wpAutoUpdate # true;
        // Weiter mit Mateiralnummerneingabe
        $edMat->wpCaption # '';
        WinFocusSet($edMat);
        return true;
      end;


    end; // EO CASE  Verladeanweisung

  end;

end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub _LfsBetriebVLDAW_EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  Lib_GuiCom:TranslateObject(aEvt:Obj);
  //App_Main:EvtInit(aEvt);
end;


//========================================================================
//  sub LfsBetrieb()
//      Ruft den Dialog "Lieferschein erstellen" auf und stößt die Verbuchung an
//========================================================================
sub LfsBetriebVLDAW()
local begin
  vWin : int;
  vId  : int;
end
begin
  // Maske auf
  vWin  # WinOpen(Lib_GuiCom:GetAlternativeName('Lfs.P.BM.VLDAW'),_WinOpenDialog);
  WinFocusSet($edVerladeanweisung);
  vID   # vWin->Windialogrun(_WinDialogCenter,gMDI);

  // Maske zu
  vWin->winclose();
end;



//========================================================================
//  Scanner
//    Einganbe durch seriellem Scanner
//========================================================================
sub Scanner(
  aWert     : alpha;
  var aRes  : alpha);
local begin
  vA        : alpha;
  vHdl      : int;
end;
begin

//  if (aWert='BG1') then aWert # '3319';
//  if (aWert='BG2') then aWert # '3331';

  $edMat->wpcaption # aWert;

  vHdl # Winsearch(gFrmMain, Lib_GuiCom:GetAlternativeName('Lfs.P.BM.VLDAW'));
  vA # CheckNummer($edVerladeanweisung, Winsearch(vHdl, 'DLMats'), $edMat);
  if (vA='') then
    aRes # cESC+'[3q'+cESC+'[2J'+'ok'+cESC+'[8q' + cESC + '[5q' + cESC + '[9q' + cCR;
  else
    aRes # cESC+'[4q'+cESC+'[2J'+ vA + cESC + '[6q' + cESC + '[5q' + cESC +'[7q' + cCR;

end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================