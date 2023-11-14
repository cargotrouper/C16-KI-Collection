@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_F_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  26.05.2008  ST  Etikettierungsfelder hinzugefügt
//  24.02.2010  ST  Sub: Delete: "Silent Modus hinzugefügt"
//  12.01.2012  AI  Set.BA.AutoT.NurWarn
//  29.02.2012  AI  Fertigungen vom Spalten werden nun nicht mehr beim RecSave addiert, sondern im UpdateOutput
//  22.03.2012  AI  beim Recsave: Kommission wird geprüft auf Löschmarker
//  31.05.2012  AI  NEU: AFX BAG.F.RecSave
//  17.07.2012  ST  Etkfelder: Fix nach Maskenänderung
//  23.08.2012  ST  EvtClicked leitet Delete Befehl jetzt zu AppMain:EvtClicked weiter
//  30.08.2012  ST  EditModus bei 999  aktiviert 1326/284
//  24.09.2012  AI  ArtPrd eingebaut
//  25.09.2012  ST  Info.PassendeAufträgeZuEinsatz hinzugefügt
//  28.07.2015  AH  Arbeitsgang Schaelen
//  18.08.2015  AH  Arbeitsgang QTeil überarbeitet
//  27.03.2018  AH  Neu: Etikettenfelder 5+6
//  29.11.2019  AH  Funktionen zentralisiert in BA1_F_Main
//  12.11.2021  ST  Fix: Drag'n Drop AufP -> Fert; Ausführungen korrigiert
//  25.01.2022  AH  Neu: direktes neue Pos. Einbinden
//  25.01.2022  AH  ERX
//  07.06.2022  AH  WalzSpulen
//  2022-12-21  AH  neue BA-MEH-Logik
//  2023-03-02  AH  neue AFX "BAG.F.Detail.Init"
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecSave(aMode : alpha) : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel();
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusDetail()
//    SUB AusAFOben();
//    SUB AusAFUnten();
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtMouseItemStart(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB EvtKeyItemStart(aEvt : event; aKey : int; aID : int)
//    SUB AuswahlEvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB AuswahlEvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtDropEnter(aEvt : event; aDataObject : int; aEffect : int) : logic
//    SUB EvtDrop(aEvt : event;	aDataObject : int; aDataPlace : int; aEffect : int; aMouseBtn : int) : logic
//    SUB Splitten() : Logic;
//
//    SUB RecInit();
//    SUB EvtMenuInitPopup...
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen
@I:Def_BAG

define begin
//  cDialog :   $BA1.F.Verwaltung
  cDialog :   $BA1.Combo.Verwaltung
  cTitle :    'Fertigungen'
  cFile :     703
  cMenuName : 'BA1.F.Bearbeiten'
  cPrefix :   'BA1_F'
  cZList :    $RL.BA1.Fertigung
  cKey :      1

  cZList1 :   $RL.BA1.Pos
  cZList2 :   $RL.BA1.Input
  cZList3 :   $RL.BA1.Fertigung
  cZList4 :   $RL.BA1.Output
end;


//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
end;
begin
todo('INTERNAL PREFIX-ERROR 703 !!!');
  if (w_Child=0) then begin
    // Datei spezifische Vorgaben
    gTitle  # Translate(cTitle);
    gFile   # cFile;
    gFrmMain->wpMenuname # cMenuName;    // Menü setzen
    gPrefix # cPrefix;
    gZLList # cZList;
    gKey    # cKey;
    gMenu # gFrmMain->WinInfo(_WinMenu);
  end;

  Call('App_Main:EvtMdiActivate',aEvt);

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vA    : alpha;
  vX    : int;
  vClr  : logic;
  vTmp  : int;
  vHdl  : int;
  Erx   : int;
end;
begin

  if (Mode=c_ModeCancel) then RETURN;

  if (RunAFX('BAG.F.RefreshIfm',aName)<0) then RETURN;

  // 2022-12-21 AH
  if (aName='edBAG.F.Artikelnummer') then begin
    Erx # RekLink(819,703,5,_recFirst);   // Warengruppe holen
    if (Wgr_Data:IstMix()) then begin
      Erx # RecLink(250,703,13,_recFirst);    // Artikel holen
      if (erx<=_rLocked) then begin
        BAG.F.MEH             # Art.MEH;
        BA1_F_Data:ErrechnePlanmengen(y,y,y);
      end;
    end;
  end;

  // Etikettendaten lesen
  if (aName = '') or (aName='edBAG.F.Verpackung') then begin
    vClr # true;
    // Verpackung lesen
    If (RecLink(704,703,6,0) <= _rLocked) then begin
      // Verpackung gefunden, jetzt Etk Lesen
      If (RecLink(840,704,2,0) <= _rLocked) then begin
        vClr # false;
        $lbBag.F.Etk.Feld.1->wpcaption # Eti.Feld.1;
        $lbBag.F.Etk.Feld.2->wpcaption # Eti.Feld.2;
        $lbBag.F.Etk.Feld.3->wpcaption # Eti.Feld.3;
        $lbBag.F.Etk.Feld.4->wpcaption # Eti.Feld.4;
        $lbBag.F.Etk.Feld.5->wpcaption # Eti.Feld.5;
        vHdl # Winsearch(gMDI, 'lbBag.F.Etk.Feld.6')
        if (vHdl<>0) then vHdl->wpcaption # Eti.Feld.6;
        vHdl # Winsearch(gMDI, 'lbBag.F.Etk.Feld.7')
        if (vHdl<>0) then vHdl->wpcaption # Eti.Feld.7;
      end;
    end;

    // Keine Daten gefunden, dann keine Bezeichnung anzeigen
    if (vClr) then begin
      vTmp # gMdi->winsearch('lbBag.F.Etk.Feld.1');   // ST 2012-07-17: Fix nach Maskenänderung
      if (vTmp > 0) then begin
        $lbBag.F.Etk.Feld.1->wpcaption # '';
        $lbBag.F.Etk.Feld.2->wpcaption # '';
        $lbBag.F.Etk.Feld.3->wpcaption # '';
        $lbBag.F.Etk.Feld.4->wpcaption # '';
        $lbBag.F.Etk.Feld.5->wpcaption # '';
        vHdl # Winsearch(gMDI, 'lbBag.F.Etk.Feld.6')
        if (vHdl<>0) then vHdl->wpcaption # '';
        vHdl # Winsearch(gMDI, 'lbBag.F.Etk.Feld.7')
        if (vHdl<>0) then vHdl->wpcaption # '';
      end;
    end;
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
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave(aMode : alpha) : logic;
local begin
  Erx         : int;
  vBuf703     : int;

//  vBuf701In   : int;
  vBuf701Out  : int;
  vHdl        : int;
  vX          : float;
  vRID        : float;
  vMin,vMax   : float;
  vStk        : int;
  vGew        : float;
  vUnpassend  : int;
  vTlg        : Int;
  vGesStk     : int;
  vInputStk   : int;
  vKLim       : float;

  vKGMM1      : float;
  vKGMM2      : float;
  vKGMM_Kaputt  : logic;
  vA,vB       : alpha;
  vTLGErr     : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


  // Auftragsnummer prüfen,,,
  if (StrCut(BAG.F.Kommission,1,1)='#') and (BAG.VorlageYN=false) then begin
    Lib_Guicom2:InhaltFehlt(Translate('Kommission'), 'NB.Page1', 'edBAG.F.Kommission');
    RETURN false;
  end;
  if (BAG.F.Kommission <> '') and (StrCut(BAG.F.kommission,1,1)<>'#') then begin
    Erx # RecLink(401,703,9,_recFirst);  // AufPos holen
//    If (Erx>_rLocked) or ("Auf.P.Löschmarker"<>'') then begin
//      Lib_Guicom2:InhaltFalsch(BAG.F.Kommission  + ' ' + Translate('Kommission'), 'NB.Page1', 'edBAG.F.Kommission');
//      RETURN false;
//    end;
// 16.08.2018 AH
    if (Erx>_rLocked) or ("Auf.P.Löschmarker"<>'') then begin
      if (mode=c_modeNew) or ((Mode=c_ModeEdit) and (ProtokollBuffer[703]->BAG.F.Kommission<>BAG.F.Kommission)) then begin
        Msg(404101, BAG.F.Kommission,_WinIcoError, _WinDialogOk, 1);
        vHdl # gMdi->Winsearch('NB.Main');
        vHdl->wpcurrent # 'NB.Page1';
        $edBAG.F.Kommission->WinFocusSet(true);
        RETURN false;
      end;
    end;
  end;


  // Hier erweiterte Meldungen bei falschen Daten
  if (RunAFX('BAG.F.RecSave.Pre','')<0) then
    RETURN false;

  TRANSON;

  // Satz zurückspeichern & protokolieren
  if (aMode=c_ModeEdit) then begin
    Erx # BA1_F_Data:Replace(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // AFX?
    RunAFX('BAG.F.RecSave','');

    PtD_Main:Compare(gFile);

  end
  else begin  // Neuanlage
    BAG.F.Anlage.Datum  # Today;
    BAG.F.Anlage.Zeit   # Now;
    BAG.F.Anlage.User   # gUserName;

    // 1zu1 Arbeitsgang? ========================================
    if ("BAG.P.Typ.1In-1OutYN") then begin
      if (BAG.F.Fertigung<>1999) then begin    // allgem. Fertigung
      end
      else begin                              // spez. Fertigung
        BAG.F.Fertigung # 1;
        WHILE (RecRead(703,1,_RecTest)<=_rLocked) do
          BAG.F.Fertigung # BAG.F.Fertigung + 1;

        // Einsatz auf diese Fertigung umbiegen
        RecRead(701,0,0,w_AppendNr);
        vBuf703 # RecBufcreate(703);
        RecBufCopy(703,vBuf703);
        RecLink(703,701,10,_recFirst);
        if (BA1_F_Data:UpdateOutput(701,y)=false) then begin // erstmal löschen!!!
          TRANSBRK;
          ERROROUTPUT;
          Msg(701003,gTitle,0,0,0);
          RETURN False;
        end;
        RecBufCopy(vBuf703, 703);
        RecbufDestroy(vBuf703);

        RecRead(701,0,_RecLock,w_AppendNr);
        BAG.IO.NachFertigung # BAG.F.Fertigung;
        Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          Msg(701003,gTitle,0,0,0);
          RETURN False;
        end;
      end;

    end
    // XzuY Arbeitsgang ==========================================
    else begin
      BAG.F.Fertigung # 1;
      WHILE (RecRead(703,1,_RecTest)<=_rLocked) do
        BAG.F.Fertigung # BAG.F.Fertigung + 1;
    end;


    Erx # BA1_F_Data:Insert(0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      RecRead(703,1,_recLock);
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // AFX?
    RunAFX('BAG.F.RecSave','');

    // Text umbenennen...
    vA # mytmpText+'.703';
    vB # '~703.'+CnvAI(BAG.F.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+
      CnvAI(BAG.F.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+
      CnvAI(BAG.F.Fertigung,_FmtNumLeadZero | _FmtNumNoGroup,0,4);
    TxtRename(vA,vB,0);

  end;  // Neuanlage


  // beim Spalten: RID aus 1. Fertigung gilt für ALLE
  if (BAG.P.Aktion=c_BAG_Spalt) and (BAG.F.Fertigung=1) then begin
    vBuf703 # RekSave(703);
    Erx # RecLink(703,702,4,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      // Restringe behalten ihren RID...
      if (BAG.F.Fertigung <> 999) then begin
        RecRead(703,1,_recLock);
        BAG.F.RID     # vBuf703->BAG.F.RID;
        //BAG.F.RAD     # vBuf703->BAG.F.RAD;
        //BAG.F.RADmax  # vBuf703->BAG.F.RADmax;
        Erx # BA1_F_Data:Replace(_recUnlock,'MAN');
      end;
      Erx # RecLink(703,702,4,_recNext);
    END;
    RekRestore(vBuf703);
    RecRead(703,1,0);
  end;

  // Fertigmaterial updaten
  if (BA1_F_Data:UpdateOutput(703,n,n,y,n)=false) then begin    // 02.12.2021 AH mit IgnoreKgMM
    TRANSBRK;
    ERROROUTPUT;  // 01.07.2019
    if (aMode=c_ModeEdit) then begin
      RecRead(703,1,_recLock);
      PtD_Main:Memorize(gFile);
    end;
    RETURN False;
  end;


  // Autoteilung ***************************************************
  FOR Erx # RecLink(701,702,2,_recFirst)  // Input loopen
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.BruderID<>0) then CYCLE;

    // kgmm-Testen...
    if (BA1_IO_Data:KGMMMinMaxBestimmen(var vKGMM1, var vKGMM2)=false) then begin
      if (Set.BA.AutoT.NurWarn=false) then begin
        TRANSBRK;
        Msg(703005,'',0,0,0);
        if (aMode=c_ModeEdit) then begin
          RecRead(703,1,_recLock);
          PtD_Main:Memorize(gFile);
        end;
        RETURN False;
      end;
      vTlgErr # 703005;
    end;



    if (BAG.IO.AutoteilungYN) then begin
      // für diesen Einsatz Teilung ausrechnen....
      vTLG # BA1_IO_Data:TeilungVonBis(vKGMM1, vKGMM2);
      if (vTLG<0) then begin
        if (Set.BA.AutoT.NurWarn=false) then begin
          TRANSBRK;
          Msg(703007,anum(vKGMM1,2)+'|'+anum(vKGMM2,2)+'|'+aint(BAG.IO.NachBAG)+'/'+aint(BAG.IO.NachPosition),0,0,0);   // ERROR
          if (aMode=c_ModeEdit) then begin
            RecRead(703,1,_recLock);
            PtD_Main:Memorize(gFile);
          end;
          RETURN false;
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
          if (aMode=c_ModeEdit) then begin
            RecRead(703,1,_recLock);
            PtD_Main:Memorize(gFile);
          end;
          RETURN false;
        end;

        // Output aktualisieren
        if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
//          RekRestore(vBuf701In);
          TRANSBRK;
          Msg(703004,'(Code B)',0,0,0);   // ERROR
          ERROROUTPUT;  // 01.07.2019
          if (aMode=c_ModeEdit) then begin
            RecRead(703,1,_recLock);
            PtD_Main:Memorize(gFile);
          end;
          RETURN false;
        end;
      end;
    end
    else begin
      vKGMM_Kaputt # BA1_IO_Data:KGMM_Check(vKGMM1, vKGMM2);
    end;

  END;  // Input


  TRANSOFF;

  ErrorOutput;

  if (vTLGErr<>0) then begin
    Msg(vTlgErr,anum(vKGMM1,2)+'|'+anum(vKGMM2,2),0,0,0);   // ERROR
  end;


  if (vKGMM_Kaputt) then begin
    Msg(703006,aint(BAG.P.Position),_WinIcoWarning, _WinDialogOk, 0);
  end;

  // AFX?
  RunAFX('BAG.Output.Check','');

  RETURN true;
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin

  if (Mode=c_ModeNew) then begin
    // Ausführungen löschen...
    WHILE (RecLink(705,703,8,_recFirst)<=_rLocked) do begin
      RekDelete(705,0,'MAN');
    END;

    // Text löschen...
    TxtDelete(mytmpText+'.703',0);
  end;
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel(opt aSilent : logic);
local begin
  Erx     : int;
  vBuf701 : int;
  vOK     : logic;
end;
begin

  // Bereits verwogen??
  if (RecLinkInfo(707,703,10,_RecCount)<>0) then begin
    Msg(703001,AInt(BAG.F.Fertigung),0,0,0);
    RETURN;
  end;

  // 1zu1 und 1.Fertigung darf nicht gelöscht werden
  if ("BAG.P.Typ.1In-1OutYN") and (BAG.F.Fertigung=1) and (BAG.P.Aktion<>c_BAG_ArtPrd) then RETURN;
  if (BAG.F.AutomatischYN) then RETURN; // 28.07.2015

  // Ausbringung wird weiterbearbeitet?
  vBuf701 # RecBufCreate(701);
  RecBufCopy(701,vBuf701);
  vOk # y;
  Erx # RecLink(701,703,4,_recFirst);
  WHILE (Erx<=_rLocked) and (vOK) do begin
    if (BAG.IO.NachBAG<>0) then begin
      vOK # n;
      BREAK;
    end;
    Erx # RecLink(701,703,4,_recNext);
  END;

  if (vOK=n) then begin
    Msg(703002,aint(BAG.F.Nummer)+'/'+aint(BAG.F.Position)+'/'+aint(BAG.F.Fertigung),0,0,0);
    RecbufCopy(vBuf701,701);
    Recbufdestroy(vBuf701);
    RETURN;
  end;
  RecbufCopy(vBuf701,701);
  Recbufdestroy(vBuf701);


  Mode # c_ModeDelete;

  // ST 2010-02-24: Keine Abfrage für Silentmode
  if (!aSilent) then begin
    // Diesen Eintrag wirklich löschen?
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;
  end;
  Mode # c_ModeList;

  BAG.P.Nummer # BAG.F.Nummer;
  RecRead(701,1,0);


  TRANSON;

  // Fertigmaterial löschen
  if (BA1_F_Data:UpdateOutput(703,true)=false) then begin
    TRANSBRK;
    ERROROUTPUT;  // 01.07.2019
    RETURN;
  end;

  // Ausführungen löschen...
  Erx # RecLink(705,703,8,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(705,0,'MAN');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;
    Erx # RecLink(705,703,8,_recFirst);
  END;

  // Text löschen...
  TxtDelete('~703.'+CnvAI(BAG.F.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+CnvAI(BAG.F.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+CnvAI(BAG.F.Fertigung,_FmtNumLeadZero | _FmtNumNoGroup,0,4) ,0);

  if (RekDelete(703,0,'MAN')<>_rOK) then begin
    TRANSBRK;
    RETURN;
  end;


  // Schopf? -> dann alle Einsätze wieder auf 100% setzen
  if (BAG.F.Fertigung=999) then begin
    Erx # RecLink(701,702,2,_recFirst);   // Input loopen
    WHILE (Erx<=_rLocked) do begin
      if ((BAG.IO.NachBAG=BAG.F.Nummer) and
        (BAG.IO.NachPosition=BAG.F.Position) and
        (BAG.IO.NachFertigung=BAG.F.Fertigung)) or
        (BAG.IO.NachFertigung=0) then begin
        RecRead(701,1,_recLock);
        BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
        BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
        BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.In.Menge;
        Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          RETURN;
        end;
      end;

      Erx # RecLink(701,702,2,_recNext);
    END;
    if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      TRANSBRK;
      ERROROUTPUT;  // 01.07.2019
      RETURN;
    end;

    TRANSOFF;

    $RL.BA1.Output->Winupdate(_WinUpdOn, _WinLstfromfirst);
    // alle Fertigungen neu errechnen
    BA1_P_Data:ErrechnePlanmengen();

    RETURN;
  end;  // Schopf

  TRANSOFF;

  // ST 2010-02-24: Keine Maskenupdates für Silentmode
  if (!aSilent) then
    $RL.BA1.Output->Winupdate(_WinUpdOn, _WinLstfromfirst);

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
    Lib_GuiCom:AuswahlEnable( aEvt:obj );
  else
    Lib_GuiCom:AuswahlDisable( aEvt:obj );
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

  if (aEvt:obj->wpname='edBAG.F.AusfOben') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|1');
  if (aEvt:obj->wpname='edBAG.F.AusfUnten') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','703|2');


  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich  : alpha;
  opt aProc : alpha;
)
local begin
  Erx     : int;
  vX      : int;
  vA      : alpha;
  vMask   : alpha;
  vFilter : int;
  vQ      : alpha(4000);
  vTmp    : int;
end;
begin
  case BAG.P.Aktion of
    c_BAG_AbLaeng : vMask # 'BA1.F.AbLaeng.Maske';
    c_BAG_ArtPrd  : vMask # 'BA1.F.ArtPrd.Maske';
    c_BAG_MatPrd  : vMask # 'BA1.F.MatPrd.Maske';
    c_BAG_Tafel   : vMask # 'BA1.F.Tafel.Maske';
    c_BAG_AbCoil  : vMask # 'BA1.F.AbCoil.Maske';
    c_BAG_Spalt   : vMask # 'BA1.F.Spalt.Maske';
    c_BAG_Walz    : vMask # 'BA1.F.Walzen.Maske';
    c_BAG_Saegen  : vMask # 'BA1.F.Saegen.Maske';
    c_BAG_Spulen  : vMask # 'BA1.F.Spulen.Maske';
    c_BAG_SpaltSpulen   : vMask # 'BA1.F.SpaltSpulen.Maske';
    c_BAG_WalzSpulen    : vMask # 'BA1.F.WalzSpulen.Maske';
    c_BAG_Schael  : vMask # 'BA1.F.Schaelen.Maske';
    c_BAG_Fahr    : vMask # 'BA1.F.Fahr.Maske';
    c_BAG_Versand : vMask # 'BA1.F.Fahr.Maske';
    c_BAG_Obf,c_BAG_Gluehen     : vMask # 'BA1.F.Obf.Maske';
    c_BAG_QTEIL   : vMask # 'BA1.F.QTeil.Maske';
//    c_BAG_Kant    : vMask # 'BA1.F.Kant.Maske';
    otherwise       vMask # 'BA1.F.Divers.Maske';
  end;

  case aBereich of

    'Detail' : begin
      Mode # c_Modeother;
      RecRead(701,0,0,cZList2->wpdbrecid);
      RecRead(702,0,0,cZList1->wpdbrecid);
      RecRead(703,0,0,cZList3->wpdbrecid);
      vMask # Lib_GuiCom:GetAlternativeName(vMask);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, vMask, here+':AusDetail',y,y);
      Lib_guiCom:ObjSetPos(gMdi,10,0);
      vX # gZLList;
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_modeBald + c_modeView;
      gZLList # vX;
      RunAFX('BAG.F.Detail.Init',aint(gMDI));   // 2023-03-02 AH
      Lib_GuiCom:RunChildWindow(gMDI);
      RETURN;
    end;


    'Detail.New' : begin
      // 1zu1 hat nur EINE Fertigung!
      if ("BAG.P.Typ.1In-1OutYN") then RETURN;
      if (BAG.P.Aktion=c_BAG_Walz) then RETURN;       // 28.07.2015
      if (BAG.P.Aktion=c_BAG_WalzSpulen) then RETURN;
      if (BAG.P.Aktion=c_BAG_Schael) and (RecLinkInfo(703,702,4,_reccount)>0) then RETURN;


      if (Mode=c_ModeView) then begin
        App_Main:Action(c_ModeNew);
        RETURN;
      end;

      Mode # c_Modeother;
      RecRead(701,0,0,cZList2->wpdbrecid);
      RecRead(702,0,0,cZList1->wpdbrecid);
      RecBufClear(703);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, vMask, here+':AusDetail',y,y);
      Lib_guiCom:ObjSetPos(gMdi,10,0);
      vX # gZLList;
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_modeBald + c_modeNew;
      gZLList # vX;
      RunAFX('BAG.F.Detail.Init',aint(gMDI));   // 2023-03-02 AH
      Lib_GuiCom:RunChildWindow(gMDI);
      RETURN;
    end;


    'Detail.Edit' : begin
      if (Mode=c_ModeView) then begin
        App_Main:Action(c_ModeEdit);
        RETURN;
      end;
      Mode # c_Modeother;
      RecRead(701,0,0,cZList2->wpdbrecid);
      RecRead(702,0,0,cZList1->wpdbrecid);
      RecRead(703,0,0,cZList3->wpdbrecid);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, vMask, here+':AusDetail',y,y);
      Lib_guiCom:ObjSetPos(gMdi,10,0);
      vX # gZLList;
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_modeBald + c_modeEdit;
      //19.08.08 - überflüssig, entfernt
      //w_Appendnr # cZList2->wpdbRecId; // Satz-ID merken für allgemeine Fertigung (999)
      gZLList # vX;
      RunAFX('BAG.F.Detail.Init',aint(gMDI));   // 2023-03-02 AH
      Lib_GuiCom:RunChildWindow(gMDI);

      RETURN;
    end;

    'Kommission'  : begin
      //if (aProc='') then aProc # here+':AusKommission';
      //RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung', aProc);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Verpackung'  : begin
      if (aProc='') then aProc # here+':AusVerpackung';
      RecBufClear(704);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.V.Verwaltung', aProc);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kunde' : begin
      if (aProc='') then aProc # here+':AusKunde';
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung', aProc);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Kundenartnr' : begin
      if (aProc='') then aProc # here+':AusKundenartnr';
      RecLink(100,703,7,_recFirst);   // Kunde holen
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung', aProc);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'Kundenartnr2' : begin
      if (aProc='') then aProc # here+':AusKundenartnr2';
      RecBufClear(105);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.V.Verwaltung', aProc);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
      vQ # vQ + ' AND Adr.V.VerkaufYN'; // 21.07.2015
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Wgr' : begin
      if (aProc='') then aProc # here+':AusWgr';
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung', aProc);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Struktur' : begin
      Erx # RecLink(819,703,5,0);   // Warengruppe holen
      if (Erx>_rLocked) then RecBufClear(819);
      if (Wgr_Data:IstMix()) then begin
        if (aProc='') then aProc # here+':AusArtikel';
        RecBufClear(250);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung', aProc);
        Lib_GuiCom:RunChildWindow(gMDI);
      end
      else begin
        if (aProc='') then aProc # here+':AusStruktur';
        RecBufClear(220);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung', aProc);
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;
    
    'Guete' : begin
      if (aProc='') then aProc # here+':AusGuete';
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung', aProc);

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(848);
      MQu.S.Stufe # "BAG.F.Gütenstufe";
      if (MQu.S.Stufe<>'') then begin
        vQ # ' MQu.NurStufe = '''+MQu.S.Stufe+''' OR MQu.NurStufe = '''' ';
        Lib_Sel:QRecList(0, vQ);
      end;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Guetenstufe' : begin
      if (aProc='') then aProc # here+':AusGuetenstufe';
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung', aProc);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'AF.Oben'        : begin
      RecBufClear(705);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung', here+':AusAFOben');
      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, BAG.F.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.F.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.F.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, 0);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '1');
      $ZL.BA1.AF->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.F.Nummer)+'|'+AInt(BAG.F.Position)+'|'+
        AInt(BAG.F.Fertigung)+'|0|1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'AF.Unten'       : begin
      RecBufClear(705);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.AF.Verwaltung', here+':AusAFUnten');
      vFilter # RecFilterCreate(705,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, BAG.F.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, BAG.F.Position);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq, BAG.F.Fertigung);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq, 0);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq, '2');
      $ZL.BA1.AF->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # AInt(BAG.F.Nummer)+'|'+AInt(BAG.F.Position)+'|'
        +AInt(BAG.F.Fertigung)+'|0|2';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusDetail
//
//========================================================================
sub AusDetail()
begin

  // Zugriffliste wieder aktivieren
  cZList->wpdisabled # false;

  RecRead(703,0,_RecId,gSelected);
  gSelected # 0;

//  cZList3->wpdbrecid # gSelected;
  mode # c_ModeList;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  // Focus setzen:
  cZList3->Winfocusset(false);

  cZList3->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

  // 12.11.2014 wegen Walzen, wo Dicke in Postext kommt
  cZList1->winupdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

  $RL.BA1.Output->Winupdate(_WinUpdOn, _WinLstfromfirst);

end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
local begin
  vA  : alpha;
end;
begin

  // gesamtes Fenster aktivieren
  gSelected # 0;

  vA # Obf_Data:BildeAFString(703,'1');
  if (vA<>BAG.F.AusfOben) then RunAFX('Obf.Changed','703|1');
  BAG.F.AusfOben # vA;

  // Focus auf Editfeld setzen:
  $edBAG.F.AusfOben->Winfocusset(true);
end;


//========================================================================
//  AusAFUnten
//
//========================================================================
sub AusAFUnten()
local begin
  vA  : alpha;
end;
begin

  // gesamtes Fenster aktivieren
  gSelected # 0;

  vA # Obf_Data:BildeAFString(703,'2');
  if (vA<>BAG.F.AusfUnten) then RunAFX('Obf.Changed','703|2');
  BAG.F.AusfUnten # vA;

  // Focus auf Editfeld setzen:
  $edBAG.F.AusfUnten->Winfocusset(true);
end;


//========================================================================
//  AusVerpackung
//
//========================================================================
sub AusVerpackung()
begin
  if (gSelected<>0) then begin
    RecRead(704,0,_RecId,gSelected);
    // Feldübernahme
    BAG.F.Verpackung # BAG.Vpg.Verpackung;
    gSelected # 0;
  end;
  // Focus setzen:
  $edBAG.F.Verpackung->Winfocusset(false);
end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "BAG.F.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "BAG.F.Güte" # "MQu.Güte1"
    else
      "BAG.F.Güte" # "MQu.Güte2";
    gSelected # 0;
  end;
  // Focus setzen:
  $edBAG.F.Guete->Winfocusset(false);
end;


//========================================================================
//  AusGuetenstufe
//
//========================================================================
sub AusGuetenstufe()
begin
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "BAG.F.Gütenstufe" # MQu.S.Stufe;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.F.Guetenstufe->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    // Feldübernahme
    BAG.F.Artikelnummer   # Art.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  RefreshIfm('edBAG.F.Artikelnummer');
  $edBAG.F.Artikelnummer->Winfocusset(false);
end;


//========================================================================
//  AusStruktur
//
//========================================================================
sub AusStruktur()
begin
  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    // Feldübernahme
    BAG.F.Artikelnummer # MSL.Strukturnr;
    gSelected # 0;
  end;
  // Focus setzen:
  $edBAG.F.Artikelnummer->Winfocusset(false);
end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    "BAG.F.ReservFürKunde" # Adr.Kundennr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.F.ReservFuerKunde->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusKundenArtnr
//
//========================================================================
sub AusKundenArtNr()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
//    "BAG.F.ReservFürKunde" # Adr.Kundennr;
    Auswahl('Kundenartnr2');
    end
  else begin
    // Focus auf Editfeld setzen:
    $edBAG.F.KundenArtNr->Winfocusset(false);
  end;
end;


//========================================================================
//  AusKundenArtnr2
//
//========================================================================
sub AusKundenArtNr2()
local begin
  vTmp : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(105,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BA1_F_Data:AusKundenArtNr();
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    gMDI->Winupdate();
  end;
  // Focus auf Editfeld setzen:
  $edBAG.F.KundenArtNr->Winfocusset(false);
end;


//========================================================================
//  AusWgr
//
//========================================================================
sub AusWgr()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    BAG.F.Warengruppe # Wgr.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edBAG.F.Warengruppe->Winfocusset(false);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl : int;
  vSchopfEditYN : logic;
end
begin
  gMenu # gFrmMain->WinInfo(_WinMenu);


  vHdl # gMenu->WinSearch('Mnu.PassendeAuftragspos');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auftrag]=n);


  // Graphnotebook richtig setzen
  vHdl # gMdi->WinSearch('NB.Graph');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_modeEdit) or (Mode=c_modeNew);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);
  vHdl # gMenu->WinSearch('Mnu.New2');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n) or
                        (BAG.P.Typ.VSBYN);


  // ST 2012-08-30: Edit für 999 aktiviert 1326/284
  Arg.Aktion2 # Bag.P.Aktion;
  RecRead(828,1,0);
    vSchopfEditYN #  (Arg.Aktion = c_BAG_Divers) OR
                   (Arg.Aktion = c_BAG_AbCoil) OR
                   (Arg.Aktion = c_BAG_Spalt)  OR
                   (Arg.Aktion = c_BAG_Tafel);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Bag.F.Fertigung = 999) AND (vSchopfEditYN=false)) OR (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  end;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Bag.F.Fertigung = 999) AND (vSchopfEditYN=false)) OR  (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  end;
  vHdl # gMenu->WinSearch('Mnu.Edit2');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Bag.F.Fertigung = 999) AND (vSchopfEditYN=false)) OR (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  end;


  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # //(BAG.F.AutomatischYN) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # //(BAG.F.AutomatischYN) or
      (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

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
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(703,BAG.F.Anlage.Datum, BAG.F.Anlage.Zeit, BAG.F.Anlage.User);
    end;


    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edBAG.F.Dickentol') then
        MTo_Data:BildeVorgabe(703,'Dicke');
      if (aEvt:Obj->wpname='edBAG.F.Breitentol') then
        MTo_Data:BildeVorgabe(703,'Breite');
      if (aEvt:Obj->wpname='edBAG.F.Laengentol') then
        MTo_Data:BildeVorgabe(703,'Länge');
    end;


    'Mnu.Verwiegungen' : begin
      if (Rechte[Rgt_BAG_FM]=false) then RETURN false;
      BA1_FM_Main:Start(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, 0, '', true);
    end;


    'Mnu.Verpackungen' : begin
      RecBufClear(704);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.V.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end


    'Mnu.Restcoil' : begin
      if (BAG.P.Aktion=c_BAG_TAFEL) or (BAG.P.Aktion=c_BAG_ABCOIL) then begin
        BA1_F_Data:UpdateRestCoil();
        cZList2->Winupdate(_WinUpdOn, _WinLstfromfirst);
        cZList3->Winupdate(_WinUpdOn, _WinLstfromfirst);
        $RL.BA1.Output->Winupdate(_WinUpdOn, _WinLstfromfirst);
      end;
      RETURN true;
    end;


    'Mnu.Versand' : begin
      if (BAG.P.Aktion<>c_BAG_VSB) and (BAG.P.Aktion<>c_BAG_VERSAND) then begin
        if (BA1_F_Data:Versand()=false) then begin
          ErrorOutput;
        end
        else begin
          Msg(999998,'',0,0,0);
        end;
        cZList1->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);
        cZList2->Winupdate(_WinUpdOn, _WinLstfromfirst);
        cZList3->Winupdate(_WinUpdOn, _WinLstfromfirst);
        $RL.BA1.Output->Winupdate(_WinUpdOn, _WinLstfromfirst);
      end;
      RETURN true;
    end;


    'Mnu.New2' : begin
      Auswahl('Detail.New');
      RETURN true;
    end;


    'Mnu.Edit2' : begin
      if (RecRead(gFile,0,0,gZLList->wpdbrecid)<=_rLocked) then Auswahl('Detail.Edit');
      RETURN true;
    end;


    'Mnu.Graph' : RETURN BA1_Combo_Main:EvtMenuCommand(aEvt, aMenuItem);


    'Mnu.PassendeAuftragspos' : begin
      BA1_F_Data:PassendesMatAusAuftrag();
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
local begin
  vA  : alpha;
end;
begin

//  if (Mode=c_ModeView) then RETURN true;

  if (aEvt:Obj->wpname='bt.InternerText') then begin
// tmp.12345.703.1231234
    if (mode=c_modeNew) then
      vA # mytmpText+'.703'
    else
      vA # '~703.'+CnvAI(BAG.F.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+
        CnvAI(BAG.F.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+
        CnvAI(BAG.F.Fertigung,_FmtNumLeadZero | _FmtNumNoGroup,0,4);
    Mdi_RtfEditor_Main:Start(vA, Rechte[Rgt_BAG_Aendern], Translate('Bemerkung'));
  end;


  if (aEvt:Obj->wpname='Edit') then begin
    if (RecRead(gFile,0,0,gZLList->wpdbrecid)<=_rLocked) then Auswahl('Detail.Edit');
    RETURN true;
  end;
  if (aEvt:Obj->wpname='New') then begin
    Auswahl('Detail.New');
    RETURN true;
  end;


  // ST 2012-08-23: Delete wurde "damals" durch die EvtClick-Verknüpfung
  //                auf die AppMain:EvtClicked durchgeführt. Wurde aber
  //                aus irgendwelchen Gründen auch immer, auf die BA1_Combo_Main geändert
  if (aEvt:Obj->wpname='Delete') then begin
    return App_Main:EvtClicked(aEvt);
  end;

end;


//========================================================================
//  EvtChanged
//              Inhalt geändert
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
): logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  CASE (aEvt:Obj->wpName) OF
    'cbBAG.F.KostentrgerYN' : begin
      if ("BAG.F.KostenträgerYN") then
        BAG.F.PlanSchrottYN # false;
      gMDI->winUpdate(_WinUpdFld2Obj);
    end;

    'cbBAG.F.PlanSchrottYN' : begin
      if (BAG.F.PlanSchrottYN) AND (BAG.F.Kommission = '') then
        "BAG.F.KostenträgerYN" # false;
      else
        BAG.F.PlanSchrottYN # false;
      gMDI->winUpdate(_WinUpdFld2Obj);
    end;
  END;

  return(true);
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
  RETURN BA1_Combo_Main:EvtPageSelect(aEvt, aPage, aSelecting);
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

  // AFX?
  if (RunAFX('BAG.F.LstDataInit','')<0) then RETURN;

  Gv.Datum.01 # 0.0.0;
  if (BAG.F.AutomatischYN) and (BAG.P.Aktion=c_BAG_Tafel) then begin
    Gv.Alpha.01 # Translate('REST');
    RETURN;
  end;
  if (BAG.F.AutomatischYN) and ((BAG.P.Aktion=c_BAG_AbCoil) or (BAG.P.Aktion=c_BAG_Spalt) or (BAG.P.Aktion=c_BAG_QTeil)) then begin
    Gv.Alpha.01 # Translate('RESTCOIL');
    RETURN;
  end;
  Gv.Alpha.01 # ANum(BAG.F.Dicke,"Set.Stellen.Dicke")+' x '+ANum(BAG.F.Breite,"Set.Stellen.Breite");
  if ("BAG.F.Länge"<>0.0) then Gv.Alpha.01 # Gv.Alpha.01 + ' x '+ANum("BAG.F.Länge","Set.Stellen.Länge");

  if (BAG.F.Kommission<>'') then begin
    Erx # RecLink(401,703,9,_recFirst);     // Aufpos. holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(411,703,11,_recFirst);  // ~Aufpos. holen
      if (Erx>_rLocked) then RecBufClear(411);
      RecBufCopy(411,401);
    end;
    if (Auf.P.TerminZusage<>0.0.0) then Gv.Datum.01 # Auf.P.Terminzusage
    else if (Auf.P.Termin1Wunsch<>0.0.0) then Gv.Datum.01 # Auf.P.Termin1Wunsch;
  end;
//  Refreshmode();
end;


//========================================================================
//  EvtMouseItemStart
//                Mausklicks in Listen
//========================================================================
sub EvtMouseItemStart(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin

  if ((aButton & _WinMouseDouble)<>0) and (aEvt:Obj=gZLList) then begin
    if (RecRead(gFile,0,0,gZLList->wpdbrecid)<=_rLocked) then Auswahl('Detail');
    RETURN false;
  end;

  RETURN App_Main:EvtMouseItem(aEvt, aButton, aHit, aItem, aID);
end;


//========================================================================
//  EvtKeyItemStart
//              Tastendruck in Auswahlliste
//========================================================================
sub EvtKeyItemStart(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
begin
  if (aKey=_WinKeyReturn) then begin
    if (RecRead(gFile,0,0,gZLList->wpdbrecid)<=_rLocked) then Auswahl('Detail');
    RETURN;
  end;

  App_Main:EvtKeyItem(aEvt,aKEy,aID);
end;


//========================================================================
//  AuswahlEvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub AuswahlEvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
local begin
  Erx : int;
end;
begin
  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    erx # wininfo(aEvt:Obj,_Winframe);    // 17.05.2022 AH
    if (erx<>0) then
      Erx->winclose()
    else
      $BA1.F.Auswahl->Winclose();
  end;
end;


//========================================================================
//  AuswahlEvtMouseItem
//                Mausklicks in Listen
//========================================================================
sub AuswahlEvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin
  if (aButton=_WinMouseDouble | _WinMouseLeft) then begin
    gSelected # aID;
    $BA1.F.Auswahl->Winclose();
  end;
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
local begin
  vProc : alpha;
end;
begin
  gSelected # RecInfo(gFile, _recid);
  vProc # Lib_Guicom:GetAlternativeMain(aEvt:Obj, 'BA1_Combo_Main');
  RETURN Call(vProc+':EvtClose', aEvt);
end;


//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vA      : alpha;
  vFile   : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    if (vFile=401) then begin
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN (true);
    end;
	end;
	
  RETURN false;
end;


//========================================================================
//  EvtDrop
//            komplettes D&D durchführen
//========================================================================
sub EvtDrop(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aDataPlace   : int;      // DropPlace-Objekt
	aEffect      : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  Erx     : int;
  vA      : alpha;
  vFile   : int;
  vID     : int;
  vInput  : int;
  vNr     : int;
  vPos    : int;
  vFert   : int;
  v401    : int;
  vOK     : logic;
  v703    : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    if (vID=0) then RETURN false;

    case vFile of

      401 : begin
        // <<< MUSTER
        // für Drag&Drop und Focuswechsel
        WinUpdate(WinInfo(aEvt:obj, _WinFrame), _WinUpdActivate );
        if (gMDI<>0) then VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        // ENDE MUSTER >>>

        Erx # RecRead(vFile,0,_RecId,vID);    // Satz holen
        if (Erx<>_rOK) then begin
        	RETURN (false);
        end;
        Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
        if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then Erx # _rNoRec;
        if (Erx<>_rOK) then begin
        	RETURN (false);
        end;

        if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)=false) then begin
        	RETURN (false);
        end;
        if ("Auf.P.Löschmarker"='*') then begin
        	RETURN (false);
        end;
        if ("Auf.Vorgangstyp"<>c_AUF) then begin
        	RETURN (false);
        end;

        RecRead(702,0,0,cZList1->wpdbrecid);  // Pos holen

        if (Rechte[Rgt_BAG_Anlegen]=n) or (BAG.P.Typ.VSBYN) or
          ("BAG.P.Typ.1In-1OutYN") then RETURN false;



        if (Auf.P.VorlageBAG<>0) then begin
          v401 # RekSave(401);

          vOK # Msg(702401,aint(auf.p.vorlageBAG),_WinIcoQuestion, _WinDialogYesNo,0)=_winIdYes;

          RekRestore(v401);
          RecRead(702,0,0,cZList1->wpdbrecid);  // Pos holen
        end;

        // AUFTRAGSPOSITION AUFNEHMEN...
        RecBufClear(703);
        BAG.F.Nummer    # BAG.P.Nummer;
        BAG.F.Position  # BAG.P.Position;
        BAG.F.Fertigung # 1;
        v703 # RekSave(703);
        WHILE (RecRead(v703,1,0)<=_rLocked) do begin
          BAG.F.RID # v703->BAG.F.RID;    // 13.05.2020 AH: Übernehmen
          v703->BAG.F.Fertigung # v703->BAG.F.Fertigung + 1;
          BAG.F.Fertigung # v703->BAG.F.Fertigung;  // ST 2021-11-12 inkrementierte Fertigung übernehmen
        END;
        recbufdestroy(v703);
        BAG.F.Warengruppe     # Auf.P.Warengruppe;
        BAG.F.MEH             # 'kg';
//        "BAG.F.Güte"          # "Auf.P.Güte";
        "BAG.F.KostenträgerYN"  # y;
BAG.F.Streifenanzahl # 1;        // 13.05.2020 AH: min. 1 Mal!
        BA1_F_Data:AusKommission(Auf.P.Nummer, Auf.P.Position, 0);

        // Speichern wie bei Neuanlage...
        RecSave(c_ModeNew);

        vNr   # BAG.F.Nummer;
        vPos  # BAG.F.Position;
        vFert # BAG.F.Fertigung;

        // 23.04.2015 mit Vorlage kopieren:
        Erx # RecRead(vFile,0,_RecId,vID);    // Satz holen
        if (vOK) then begin
          if (BA1_F_Data:BindeAnVorlage(vNr, vPos, vFert, Auf.P.VorlageBAG, Auf.P.nummer, Auf.P.Position)=false) then begin
            ErrorOutput;
            RETURN false;
          end;
          BA1_P_Data:UpdateSort();
        end;

//        cZList1->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect); 20.06.2016 AH besser so bei mehrfachen D&D
        cZList1->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
        cZList2->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
        cZList3->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
        cZList4->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

        if (vOK) then
          Msg(999998,'',0,0,0);

      end;

    end;

  end;

	RETURN (false);
end


//========================================================================
// Splitten
//
//========================================================================
sub Splitten() : logic
local begin
  Erx     : int;
  vBA     : int;
  vPos    : int;
  vFert   : int;

  v701ID  : int;
  vBuf703 : int;
  vTmp    : int;
end;
begin

  // Gegenbuchung?
  vTmp # Winsearch(gMDI,'lb.GegenID');
  if (vTmp=0) then RETURN false;
  if (vTmp->wpcustom='') then RETURN false;
  v701ID # cnvia(vTmp->wpcustom);

  gSelected # 0;

  vBuf703 # RekSave(703);
  Erx # RecRead(703,0,_RecId,v701ID);   // Fertigung restoren
  if (Erx=_rOK) then begin
    vBA   # BAG.F.Nummer;
    vPos  # BAG.F.Position;
    vFert # BAG.F.Fertigung;
    RekRestore(vBuf703);
    if (BA1_F_Data:Splitten(vBA,vPos,vFert)=false) then begin
      Msg(703004,'(Code C)',0,0,0);   // ERROR
      RETURN false;
    end
    else begin
      Msg(703003,'',0,0,0);   // OK
      RETURN true;
    end;
  end
  else begin
    RekRestore(vBuf703);
    RETURN false;
  end;

end;


//========================================================================
//========================================================================
sub RecInit();
begin
end;


//========================================================================
//========================================================================
sub EvtMenuInitPopup(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüeintrag
) : logic;
local begin
  Erx       : int;
  vMenu     : handle;
  vItem     : handle;
  v701      : int;
  v702      : int;
  vNextPos  : int;
  vHatFM    : logic;
  vFirst    : logic;
end;
begin

  // Kontext - Menü
  if (aMenuItem <> 0) then RETURN true;

  // Ermitteln des Kontextmenüs des Frame-Objektes.
  vMenu # aEvt:Obj->WinInfo(_WinContextMenu);
  if (vMenu = 0) then RETURN true;

  // ersten Eintrag löschen, wenn kein Titel angegeben ist
  vItem # vMenu->WinInfo(_WinFirst);
  if (vItem > 0 and vItem->wpCaption = '') then vItem->WinMenuItemRemove(FALSE);
  vItem # 0;
  
  if (aEvt:Obj->wpDbRecId=0) then RETURN true;

  // Keine Weiterbearbeitung von Umlagerungen
  if (Bag.P.Aktion = c_BAG_Umlager) then
    RETURN true;

  // Prüfen, ob freie Ausbringungen vorhanden sind...
  RecRead(703, 0, _recId, aEvt:Obj->wpdbRecId);
  v701 # RecBufCreate(701);
  FOR Erx # RecLink(v701,703,4,_recFirst)   // Output von Fertigung loopen...
  LOOP Erx # RecLink(v701,703,4,_recNext)
  WHILE (Erx<=_rLocked) do begin
    vHatFM # vHatFM or (v701->BAG.IO.BruderId<>0);
    if (v701->BAG.IO.NachPosition<>0) then begin
      if (vNextPos=0) then
        vNextPos # v701->BAG.IO.NachPosition
      else
        if (vNextPos<>v701->BAG.IO.NachPosition) then vNextPos # -1;
    end;
  END;
  RecBufDestroy(v701);

  if (vHatFM) then begin
    RETURN(true);
  end;
  
  if (vNextPos=0) then begin
vItem # vMenu->WinMenuItemAdd('Ktx.FertNachQTeil', Translate('weiter mit neuem Querteilen'));

    v702 # RecBufCreate(702);
    FOR Erx # RecLink(v702, 700, 1, _recfirst)  // Positionen loopen...
    LOOP Erx # RecLink(v702, 700, 1, _recNext)
    WHILE (Erx<=_rLocked) do begin
      if (v702->BAG.P.Typ.VSBYN) then CYCLE;
      if (v702->BAG.P.Aktion = c_BAG_Umlager) then CYCLE;

      vItem # vMenu->WinMenuItemAdd('Ktx.FertNachPos'+aint(v702->BAG.P.Position), Translate('weiter mit Pos.')+aint(v702->BAG.P.Position)+' '+v702->bag.p.bezeichnung);
      if (vItem<>0) then begin
        if (v702->Bag.P.Position = BAG.P.Position) or
          (v702->"BAG.P.Löschmarker"<>'') then vItem->wpDisabled # true;
      end;
    END;
    RecBufDestroy(v702);
  end;
  
  // 22.07.2020 AH:
  vFirst # true;
  if (vNextPos>0) then begin
    // 25.01.2022 AH neues Einbinden
    Erx # RecRead(703, 0, _recId, cZList3->wpdbRecId);      // Fertigung holen
    vItem # vMenu->WinMenuItemAdd('Ktx.InsertNeuePosNachFert'+aint(RecInfo(703,_recId)), Translate('erst durch neue Pos.')+' '+Translate('dann Pos.')+aint(vNextPos));
    
    v702 # RecBufCreate(702);
    FOR Erx # RecLink(v702, 700, 1, _recfirst)  // Positionen loopen
    LOOP Erx # RecLink(v702, 700, 1, _recNext)
    WHILE (Erx<=_rLocked) do begin
      // nur Pos OHNE bisherigen Einsatz können eingegüt werden...
      if (recLinkInfo(701,v702,2,_recCount)<>0) then CYCLE;
      if (v702->BAG.P.Position=BAG.P.Position) then CYCLE;
      vItem # vMenu->WinMenuItemAdd('Ktx.InsertPosNachFert'+aint(v702->BAG.P.Position), Translate('erst durch Pos.')+aint(v702->BAG.P.Position)+' '+v702->bag.p.bezeichnung+' '+Translate('dann Pos.')+aint(vNextPos));
    END;
    RecBufDestroy(v702);
  end;

  // andere gleichartige Positionen suchen, in die exportiert werden könnte?
  vFirst # true;
//  if (gUsergroup='PROGRAMMIERER') then begin
    v702 # RecBufCreate(702);
    FOR Erx # RecLink(v702, 700, 1, _recfirst)  // Positionen loopen
    LOOP Erx # RecLink(v702, 700, 1, _recNext)
    WHILE (Erx<=_rLocked) do begin
      // nur GLEICHE Aktionen können gemerged werden...
      if (v702->BAG.P.Aktion<>BAG.P.Aktion) then CYCLE;
      if (v702->BAG.P.Position=BAG.P.Position) then CYCLE;
      // nur Pos MIT bisherigen Einsatz können eingefügt werden...
      if (recLinkInfo(701,v702,2,_recCount)=0) then CYCLE;

      if (vFirst) and (vItem<>0) then begin
        vFirst # false;
        vItem # vMenu->WinMenuItemAdd();
        vItem->wpMenuSeparator # true;
      end;
      vItem # vMenu->WinMenuItemAdd('Ktx.FertExportNachPos'+aint(v702->BAG.P.Position), Translate('Exportieren nach Pos.')+aint(v702->BAG.P.Position));
    END;
    RecBufDestroy(v702);
//  end;

  RETURN(true);
end;

//========================================================================
//========================================================================
//========================================================================