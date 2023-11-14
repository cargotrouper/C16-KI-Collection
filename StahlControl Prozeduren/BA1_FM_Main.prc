@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_Main
//                    OHNE E_R_G
//  Info
//
//
//  10.10.2007  AI  Erstellung der Prozedur
//  22.12.2010  MS  Eigenes Menue + Etikettendruck
//  17.01.2012  AI  NEU: aus Weiterbearbeitung rausnhmen
//  01.08.2014  ST  "RecSave" Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  22.03.2016  AH  Feritgmeldung aus FM.Verwaltung
//  12.01.2017  AH  Verwiegungen bei Weiterbearbeitungs-Inputs richtig anzeigen
//  23.02.2017  AH  Selektion für Einsatz anzeigen von WB
//  29.11.2017  AH  Fix: Verwiegungen bei xZuy auf 1.Pos anzeigen
//  18.09.2019  AH  Neue Spalte: Vormaterialnr.
//  05.04.2022  AH  ERX
//  20.07.2022  HA  Quick JumpG
//
//  Subprozeduren
//    SUB Start(aBAG : int; aPos : int; aFert : int; aID : int; aProc : alpha; aMuendig : logic) : logic;
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
//    SUB AusFM()
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
@I:Def_BAG
@I:Def_Aktionen

define begin
ctest : (gusername='AHxxx')
  cTitle      : 'Fertigmeldungen'
  cFile       :  707
  cMenuName   : 'BA1.FM.Bearbeiten'
  cPrefix     : 'BA1_FM'
  cZList      : $ZL.BA1.FM
  cKey        : 1
end;

declare Filter(aBAG : int; aPos : int; aFert : int; aID : int);

//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  aBAG      : int;
  aPos      : int;
  aFert     : int;
  aID       : int;
  aProc     : alpha;
  aMuendig  : logic;
  opt aFM   : logic) : logic;
local begin
  Erx       : int;
  vQ        : alpha(4000);
  vHdl      : int;
  v701      : int;
  vNr       : int;
end;
begin
  if (Rechte[Rgt_BAG_FM]=false) then RETURN false;

  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos;
  Erx # RecRead(702,1,0);     // BA-Position holen
  BAG.Nummer      # aBAG;
  Erx # RecRead(700,1,0);

  RecBufClear(707);
  if ((BAG.P.Aktion=c_BAG_Messen) or (cTest)) and (aFM) then
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.FM.EdList.Verwaltung',aProc, aMuendig)
  else
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.FM.Verwaltung',aProc, aMuendig);

  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

  $ZL.BA1.FM->wpDbFileNo      # 707;
  $ZL.BA1.FM->wpDbKeyNo       # 1;
  gKey # 1;
  $ZL.BA1.FM->wpDbLinkFileNo  # 0;

  // Selektion aufbauen...
  vQ # '';

  if (aFert=0) and (aID<>0) then begin
    $lb.Was->wpCustom   # '701';
    $lb.Was->wpvisible  # true;
    $lb.Was->wpCaption  # Translate('zu Einsatz');
    $lb.Was2->wpvisible # true;
    $lb.Was2->wpCaption # aint(aID);
  end
  else if (aFert<>0) then begin
    if (aFM) then
      $lb.Was->wpCustom   # '703FM'
    else
      $lb.Was->wpCustom   # '703';
    $lb.Was->wpvisible  # true;
    $lb.Was->wpCaption  # Translate('zu Fertigung');
    $lb.Was2->wpvisible # true;
    $lb.Was2->wpCaption # aint(aFert);
  end;

  Filter(aBAG, aPos, aFert, aId);

  $lb.BAG->wpCaption  # AInt(aBAG) + '/' + aInt(aPos);

  Lib_GuiCom:RunChildWindow(gMDI);

  RETURN true;
end;


//========================================================================
//========================================================================
sub Refresh() : logic
begin

  if ($lb.Was->wpCustom='701') then
    Filter(BAG.P.Nummer, BAG.P.Position, 0, cnvia($lb.Was2->wpCaption))
  else
    Filter(BAG.P.Nummer, BAG.P.Position, cnvia($lb.Was2->wpCaption), 0);

  RETURN false;
end;;


//========================================================================
//========================================================================
sub Filter(
  aBAG  : int;
  aPos  : int;
  aFert : int;
  aID   : int)
local begin
  Erx       : int;
  vQ        : alpha(4000);
  vHdl      : int;
  v701      : int;
  vNr       : int;
end;
begin

  if (aFert=0) and (aID<>0) then begin
    // 12.01.2017 AH: Problem, bei Weiterbearbeitungen sind die FMs nicht von Eingangs-ID (Typ 703), sondern von
    //                der echten ID (Typ 200, Bruder = Typ 703)
    vHdl # SelCreate(707, gKey);
    // Selektion starten...
    w_SelName # Lib_Sel:Save(vHdl);           // speichern mit temp. Namen
    vHdl # SelOpen();                         // Selektion öffnen
    vHdl->selRead(707,_SelLock,w_SelName);    // Selektion laden
    // Output loopen
    FOR Erx # RecLink(701,702,3,_recFirst)
    LOOP Erx # RecLink(701,702,3,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.Materialtyp<>200) or (BAG.IO.VonFertigmeld=0) then CYCLE;
      if (BAG.IO.ID=aID) then CYCLE;
      if ("BAG.P.Typ.xIn-YOutYN") then begin

        // 29.11.2017 AH: bei VW auf Einsatz d.h. nicht auf WB
        if (BAG.IO.VonID=aID) then begin
          Erx # RecLink(707,701,18,_RecFirst);    // FM holen
          if (Erx<=_rMultikey) then begin
            SelRecInsert(vHdl, 707);
            CYCLE;
          end;
        end;

        Erx # RecLink(707,701,18,_RecFirst);    // FM holen
        if (Erx<=_rMultikey) then begin
          v701 # RekSave(701);
          BAG.IO.ID # BAG.FM.InputID;
          Erx # RecRead(701,1,0);
          if (Erx<=_rLocked) and (BAG.IO.Bruderid=aID) then begin
            SelRecInsert(vHdl, 707);
          end;
          RekRestore(v701);
        end;

      end
      else begin
        v701 # RekSave(701);
        BAG.IO.ID # BAG.IO.BruderID;
        RecRead(701,1,0);
        vNr # BAG.IO.VonID;
        RekRestore(v701);
        if (vNr<>aID) then CYCLE;
        Erx # RecLink(707,701,18,_RecFirst);    // FM holen
        if (Erx<=_rMultikey) then begin
          SelRecInsert(vHdl, 707);
        end;
      end;
    END;
  end
  else if (aFert<>0) then begin
    vQ # vQ + 'BAG.FM.Nummer = '+AInt(aBAG)+' AND';
    vQ # vQ + ' BAG.FM.Position = '+AInt(aPos)+ ' AND';
    vQ # vQ + ' BAG.FM.Fertigung = '+AInt(aFert);
  end
  else begin
    vQ # vQ + 'BAG.FM.Nummer = '+AInt(aBAG)+' AND BAG.FM.Position = '+aint(aPos)
  end;

  if (vQ<>'') then begin
    vHdl # SelCreate(707, gKey);
    Erx # vHdl->SelDefQuery('', vQ);
    if (Erx != 0) then Lib_Sel:QError(vHdl);
    // speichern, starten und Name merken...
    w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
  end;

  // Liste selektieren...
  $ZL.BA1.FM->wpDbSelection # vHdl;
end;


//========================================================================
// Summieren
//
//========================================================================
sub Summieren();
local begin
  Erx       : int;
  vNetto    : Float;
  vBrutto   : float;
  vM        : float;
  vStk      : int;
end;
begin
  // Summe ermitteln...
  FOR Erx # RecRead(707,gZLList->wpDbSelection,_recFirst)   // Input loopen
  LOOP Erx # RecRead(707,gZLList->wpdbSelection,_recNext)
  WHILE (Erx<=_rLocked) do begin
    vNetto  # vNetto + BAG.FM.Gewicht.Netto;
    vBrutto # vBrutto + BAG.FM.Gewicht.Brutt;
    vM      # vM + BAG.FM.Menge;
    vStk    # vStk + "BAG.FM.Stück";
  END;
  $lb.Sum.Netto->wpcaption    # ANum(vNetto,Set.Stellen.Gewicht);
  $lb.Sum.Stueck->wpcaption   # aInt(vStk);

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

//  $lb.BAG->wpCaption # AInt(BAG.F.Nummer)+'/'+AInt(BAG.F.Position)+'/'+AInt(BAG.F.Fertigung);

  if (StrFind(aEvt:obj->wpname,'.EdList.',1)>0) then begin
    Mode # c_modeEdList;
  end;

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
sub RecInit() : logic
local begin
  Erx : int;
end;
begin

  if (mode=c_modeEdList) then begin
    Erx # RecRead(gFile,0,_RecID, gZLList->wpDbRecID);

    Erx # RekLink(710,707,10,_recFirst);    // 1. Fehler holen

    // Analyse leeren bzw. holen
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
        Erx # _rnorec;
      end;
      if (Erx=_rok) then begin
        // Analyse sperren
        Erx # RecRead(231,1,_RecLock);
        if (Erx=_rOK) and (ProtokollBuffer[231]=0) then PtD_Main:Memorize(231);
      end;
    end;
    RETURN true;
  end;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:

  $edBAG.FM.Menge->WinFocusSet(true);
  RETURN false;
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vHdl        : int;
  vStatusAlt  : int;
  vFehler     : int;
  vLfd        : int;

  vGemDicke   : float;
  vGemBreite  : float;

  vBuf200     : int;
end;
begin
  // Editlist??
  if (Mode=c_ModeEdListEdit) then begin

    if (GV.Logic.01) then BAG.FM.Status # 1
    else if (GV.Logic.02) then BAG.FM.Status # c_Status_BAGfertSperre;

    if (ProtokollBuffer[707]<>0) then vStatusAlt # ProtokollBuffer[707]->BAG.FM.Status;

    TRANSON;

    // Analyse speichern
    if (Lys.Analysenr<>0) then Erx # RekReplace(231);
    if (ProtokollBuffer[231]<>0) then begin
      PtD_Main:Compare(231);
    end;

    // Material ändern...
    if (BAG.FM.Materialnr<>0) then begin
      if (BA1_FM_Messen:UpdateMaterial()=false) then begin
        TRANSBRK;
        RETURN false;
      end;
    end;

    Erx # RekReplace(707,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(707);

    // Fehlercode...
    vFehler # BAG.FM.Fh.Fehler;
    // Löschen?
    if (BAG.FM.Fh.Fehler=0) then begin
      // alle Fehler löschen
      WHILE (RecLink(710,707,10,_recFirst)=_rOK) do
        RekDelete(710);
    end
    else begin
      Erx # RecLink(710,707,10,_recFirst);
      if (Erx<=_rlocked) then begin
        // Ändern?
        if (BAG.FM.Fh.Fehler<>vFehler) then begin
          RecRead(710,1,_recLock);
          BAG.FM.Fh.Fehler # vFehler;
          Rekreplace(710);
        end;
      end
      else begin  // Neuanlage?
        vLfd # 1;
        BAG.FM.Fh.Nummer      # BAG.FM.Nummer;
        BAG.FM.Fh.Position    # BAG.FM.Position;
        BAG.FM.Fh.Fertigung   # BAG.FM.Fertigung;
        BAG.FM.Fh.Fertigmeld  # BAG.FM.Fertigmeldung;
        BAG.FM.Fh.Fehler      # vFehler;
        BAG.FM.Fh.Anlage.Dat  # Today;
        BAG.FM.Fh.Anlage.Zei  # Now;
        BAG.FM.Fh.Anlage.Usr  # gUserName;
        REPEAT
          BAG.FM.Fh.lfdNr       # vLfd;
          Erx # Rekinsert(710,0,'MAN');
          if (Erx<>_rOK) then vLfd # vLfd + 1;
        UNTIL (Erx=_rOK);
      end;
    end;


    if (BAG.FM.Status=c_status_Frei) and (vStatusalt<>c_Status_Frei) then begin
      Erx # RecLink(701,707,8,_recFirst);   // Output holen
      if (BA1_FM_MEssen:QsFreigabe()=false) then begin
        TRANSBRK;
        ErrorOutput;
        RETURN false;
      end;
    end
    else if (BAG.FM.Status=c_Status_BAGfertSperre) and (vStatusAlt<>c_Status_BAGFertSperre) then begin
      RecRead(200,1,_recLock);
      Mat_Data:SetStatus(c_Status_BAGfertSperre);    // Sperr-Status
      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Error(200106,AInt(BAG.FM.Materialnr));
        ErrorOutput;
        RETURN false;
      end;
    end;


    TRANSOFF;

    Mode # c_modeSave;  // STD muss nicht Speichern!

    RETURN true;  // Speichern erfolgreich
  end;



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
    BAG.FM.Anlage.Datum  # Today;
    BAG.FM.Anlage.Zeit   # Now;
    BAG.FM.Anlage.User   # gUserName;
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
local begin
  Erx : int;
end;
begin

  if (Mode=c_ModeEdListEdit) then begin
    // Analyse freigeben
    if (ProtokollBuffer[231]<>0) then PtD_Main:Forget(231);
    Erx # RecRead(231,1,_RecUnLock);
//debugx('');
//mode # c_ModeEdList;
//    gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst| _WinLstPosSelected | _WinLstRecDoSelect);
  end;

  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin
  // Diesen Eintrag wirklich löschen?
  if (BAG.FM.Status<>c_Status_BAGAusfall) then begin
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      //RekDelete(gFile,0,'MAN');
      BA1_FM_Subs:Entfernen();
    end;
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
  vA    : alpha;
end;

begin

  case aBereich of
  end;

end;


//========================================================================
//  AusFM
//========================================================================
sub AusFM();
local begin
  vHdl  : int;
end;
begin
  App_Main:Refresh();
  Summieren();

  RecBufClear(707);
  BAG.FM.Nummer   # Cnvia(Str_Token($Lb.BAG->wpCaption,'/',1));
  BAG.FM.Position # Cnvia(Str_Token($Lb.BAG->wpCaption,'/',2));
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx       : int;
  vHdl      : int;
  vNr       : int;
  vPNetto   : Float;
  vPBrutto  : float;
  vPM       : float;
  vPStk     : int;
end;
begin

  if (Mode=c_modeList) and ($lb.Sum.Netto->wpcustom='') then begin

    Summieren();

    // Planmenge ermitteln...
    vNr # cnvia($lb.Was2->wpcaption);
    FOR Erx # RecLink(701,702,3,_RecFirst)  // Output loopen
    LOOP Erx # RecLink(701,702,3,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      // nur geplante Weiterbearbeitungen
      if (BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;

      // für Fertigungen?
      if ($lb.Was->wpcustom='703') or ($lb.Was->wpcustom='703FM') then begin
        if (BAG.IO.VonFertigung<>vNr) then CYCLE;
      end
      // für Input?
      else if ($lb.Was->wpcustom='701') then begin
        if (BAG.IO.VonID<>vNr) then CYCLE;
      end;

      vPNetto   # vPNetto + BAG.IO.Plan.In.GewN;
      vPBrutto  # vPBrutto + BAG.IO.Plan.In.GewB;
      vPM       # vPM + BAG.IO.Plan.In.Menge;
      vPStk     # vPStk + BAG.IO.Plan.In.Stk;
    END;
    $lb.Sum.Netto->wpcustom     # 'DONE';
    $lb.Plan.Netto->wpcaption   # ANum(vPNetto,Set.Stellen.Gewicht);
    $lb.Plan.Stueck->wpcaption  # aInt(vPStk);
  end;
/***
    if (gZLList->wpDbSelection=0) then begin
      // für Fertigungen...
      Erx # RecLink(707,703,10,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        vNetto  # vNetto + BAG.FM.Gewicht.Netto;
        vBrutto # vBrutto + BAG.FM.Gewicht.Brutt;
        vM      # vM + BAG.FM.Menge;
        vStk    # vStk + "BAG.FM.Stück";
        Erx # RecLink(707,703,10,_recNext);
      END;
      Erx # RecLink(701,703,4,_RecFirst);   // Output loopen
      WHILE (Erx<=_rLockeD) do begin
        if (BAG.IO.Materialtyp=c_IO_BAG) then begin
          vPNetto   # vPNetto + BAG.IO.Plan.In.GewN;
          vPBrutto  # vPBrutto + BAG.IO.Plan.In.GewB;
          vPM       # vPM + BAG.IO.Plan.In.Menge;
          vPStk     # vPStk + BAG.IO.Plan.In.Stk;
        end;
        Erx # RecLink(701,703,4,_RecNext);
      END;
      $lb.Plan.Netto->wpvisible   # true;
      $lb.Plan.Stueck->wpvisible  # true;
      $lb.Plan1->wpvisible        # true;
      $lb.Plan2->wpvisible        # true;
      $lb.Plan3->wpvisible        # true;
    end
    else begin
      // für Einsatz...
      Erx # RecRead(707,gZLList->wpdbSelection,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        vNetto  # vNetto + BAG.FM.Gewicht.Netto;
        vBrutto # vBrutto + BAG.FM.Gewicht.Brutt;
        vM      # vM + BAG.FM.Menge;
        vStk    # vStk + "BAG.FM.Stück";
        Erx # RecRead(707,gZLList->wpdbSelection,_recNext);
      END;
    end;
    $lb.Sum.Netto->wpcustom     # 'DONE';
    $lb.Sum.Netto->wpcaption    # ANum(vNetto,Set.Stellen.Gewicht);
    $lb.Sum.Stueck->wpcaption   # aInt(vStk);
    $lb.Plan.Netto->wpcaption   # ANum(vPNetto,Set.Stellen.Gewicht);
    $lb.Plan.Stueck->wpcaption  # aInt(vPStk);
  end;
***/

  gMenu # gFrmMain->WinInfo(_WinMenu);


  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # BAG.VorlageYN or (BAG.Fertig.Datum<>0.0.0) or (Rechte[Rgt_BA_Fertigmelden]=false);// y
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # BAG.VorlageYN or (BAG.Fertig.Datum<>0.0.0) or (Rechte[Rgt_BA_Fertigmelden]=false); // Y

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # mode<>c_ModeEdList/*Y (vHdl->wpDisabled) or (Rechte[Rgt_xxx_Aendern]=n);*/
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # mode<>c_ModeEdList;/*Y (vHdl->wpDisabled) or (Rechte[Rgt_xxx_Aendern]=n);*/

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or ((Rechte[Rgt_BAG_Del_NachAbschluss]=n) and (Rechte[Rgt_BAG_Del_VorAbschluss]=n)) or (("BAG.P.Löschmarker" = '*') and (Rechte[Rgt_BAG_Del_VorAbschluss]=y) and (Rechte[Rgt_BAG_Del_NachAbschluss]=n));
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or ((Rechte[Rgt_BAG_Del_NachAbschluss]=n) and (Rechte[Rgt_BAG_Del_VorAbschluss]=n)) or (("BAG.P.Löschmarker" = '*') and (Rechte[Rgt_BAG_Del_VorAbschluss]=y) and (Rechte[Rgt_BAG_Del_NachAbschluss]=n));


  vHdl # gMenu->WinSearch('Mnu.Abschluss');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.VorlageYN) or (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG]=n) or (BAG.Fertig.Datum<>0.0.0) or ("BAG.P.Löschmarker"<>'');

  Erx # RecLink(701,707,5,_recFirst);   // BAG-Output holen
  vHdl # gMenu->WinSearch('Mnu.KeineWeiterbearbeitung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Erx<>_rOK) or (Rechte[Rgt_BAG_FM_Aendern]=n) or (BAG.IO.NachBAG=0);




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
  Erx       : int;
  vHdl      : int;
  vTmp      : int;
  vMarked   : int;
  vMFile    : int;
  vMID      : int;
  vPrinted  : logic;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Newx'     : begin
      RecBufClear(707);
      BAG.FM.Nummer   # Cnvia(Str_Token($Lb.BAG->wpCaption,'/',1));
      BAG.FM.Position # Cnvia(Str_Token($Lb.BAG->wpCaption,'/',2));
      Ba1_Fertigmelden:FMKopf(here+':AusFM');
    end;


    'Mnu.Abschluss' : begin
      if (BAG.VorlageYN)then RETURN true;
      BA1_Fertigmelden:AbschlussPos(BAG.P.Nummer, BAG.P.Position, 0.0.0, now);
      ErrorOutput;
      RETURN true;
    end;


    'Mnu.Beistell' : begin
      RecBufClear(708);
      gMDI # Lib_GuiCom:AddChildWindow( gMDI,'BA1.FM.B.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,BAG.FM.Anlage.Datum, BAG.FM.Anlage.Zeit, BAG.FM.Anlage.User);
    end;


    'Mnu.Etikett' : begin
      vPrinted # false;

      // Markierte Verwiegungen drucken
      FOR vMarked # gMarkList->CteRead(_CteFirst);
      LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
      WHILE (vMarked > 0) DO BEGIN
        Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
        if ((vMFile <> 707) or (BAG.FM.Nummer <> BAG.F.Nummer)) then // nur FM
          CYCLE;

        Erx # RecRead(707, 0, _RecId, vMID);
        if(Erx > _rLocked) then
          RecBufClear(707);

        Mat_Data:Read(BAG.FM.Materialnr); // Materikarte lesen

        Mat_Etikett:Init(Mat.Etikettentyp);

        vPrinted # true;
      END;

      // Falls keine Verwiegungen markiert, ALLE drucken
      if(vPrinted = false) then begin
        FOR Erx # RecLink(707, 703, 10, _recFirst);
        LOOP Erx # RecLink(707, 703, 10, _recNext);
        WHILE (Erx <= _rLocked) DO BEGIN
          Mat_Data:Read(BAG.FM.Materialnr); // Materikarte lesen
          Mat_Etikett:Init(Mat.Etikettentyp);
        END;
      end;

    end;


    'Mnu.KeineWeiterbearbeitung' : begin
  // Sperre :   BAG.FM.Status # 759;
      Erx # RecLink(701,707,5,_recFirst);   // BAG-Output holen
      if (Erx<=_rOK) then begin
        if (Msg(707014,'',_WinIcoQuestion,_WinDialogYesNo,2)=_winidno) then RETURN true;
        if (BA1_FM_Data:SetSperre()<>true) then begin
          ErrorOutput;
          RETURN false;
        end;
        ErrorOutput;
        Msg(999998,'',0,0,0);
      end;
    end;

  end; // case

  RETURN true;
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
    'New'       :   begin
      RecBufClear(707);
      BAG.FM.Nummer   # Cnvia(Str_Token($Lb.BAG->wpCaption,'/',1));
      BAG.FM.Position # Cnvia(Str_Token($Lb.BAG->wpCaption,'/',2));
      Ba1_Fertigmelden:FMKopf(here+':AusFM');
    end;
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
local begin
  Erx       : int;
  vBuf701   : int;
end;
begin
//  Refreshmode();
  if ($lb.Was->wpcustom='703FM') and (mode<>c_ModeEdListEdit) then begin
    Erx # RekLink(710,707,10,_recFirst);    // 1. Fehler holen
    // Analyse leeren bzw. holen
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
    GV.Logic.01 # (BAG.FM.Status=1);
    GV.Logic.02 # (BAG.FM.Status=c_Status_BAGfertSperre);
  end;

  if (aMark=n) then begin
    if (BAG.FM.Status=c_Status_BAGAusfall) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
  end;

  if (BAG.FM.Materialtyp=c_IO_Mat) and (BAG.FM.Materialnr<>0) then begin
    Mat_Data:Read(BAG.FM.Materialnr);
  end
  else begin
    RecBufClear(200);
  end;

  GV.Alpha.01 # '';
  vBuf701 # RecBufCreate(701);
  if (BAG.FM.OutPutID<>0) then begin
    vBuf701->BAG.IO.Nummer # BAG.FM.Nummer;
    vBuf701->BAG.IO.ID # BAG.FM.OutputID;
    Erx # RecRead(vBuf701, 1, 0);
    if (Erx<=_rLocked) then begin
      if (vBuf701->BAG.IO.NachPosition<>0) then begin
        GV.ALpha.01 # aint(vBuf701->BAG.IO.NachBAG)+'/'+aint(vBuf701->BAG.IO.NachPosition);
      end;
    end;
  end;

  // 18.09.2019 AH: Vormaterialnr. holen
  Gv.Int.01 # 0;
  if (BAG.FM.InputID<>0) then begin
    vBuf701->BAG.IO.Nummer  # BAG.FM.Nummer;
    vBuf701->BAG.IO.ID      # BAG.FM.InputID;
    Erx # RecRead(vBuf701, 1, 0);
    if (Erx<=_rLocked) then begin
      GV.Int.01 # vBuf701->BAG.IO.Materialnr;
    end;
  end;

  RecbufDestroy(vBuf701);

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
  vA  : alpha;
end;
begin
  RecRead(gFile,0,_recid,aRecID);

  if (Mode=c_ModeEdList) or (Mode=c_ModeEdListEdit) then begin
    GV.Logic.01 # (BAG.FM.Status=1);
    GV.Logic.02 # (BAG.FM.Status=c_Status_BAGfertSperre);
    if (GV.Logic.01) or (Gv.Logic.02) then vA # '_SKIP';
    $clmGV.Logic.01->wpCustom # vA;
    $clmGV.Logic.02->wpCustom # vA;
  end;

  RefreshMode(y);   // falls Menüs gesetzte werden sollen
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
