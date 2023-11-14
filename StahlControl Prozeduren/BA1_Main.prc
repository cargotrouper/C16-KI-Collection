@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Main
//                  OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  04.08.2009  ST  Theoretisches Fertigemelden hinzugefügt
//  26.11.2009  TM  RecDel setzt BA Einsatzmaterial wieder frei
//  09.05.2011  ST  Fehlerkorrektur; Fehlerhaftes löschen -> keine Endlosschleife mehr
//  23.05.2013  ST  Customfelder freigeschaltet
//  06.03.2015  AH  "Merge"
//  06.11.2015  AH  Funktion für neuer BA aus Vorlage
//  21.03.2016  AH  "MarkPos"
//  11.12.2018  AH  Druckmenü vom LFS
//  29.01.2019  AH  Fix für MultiLFS pro BA-Pos.
//  27.03.2019  AH  Funktion für Vorlage aus BA
//  02.12.2020  AH  Vorlage mit WandelFunktion
//  19.02.2021  ST  Anker "BAG.Init.Pre" und "BAG.Init" hinzugefügt
//  28.07.2021  AH  BA kopieren
//  11.10.2021  AH  ERX
//  13.01.2022  ST  Edit: Fahrauftragsdruck per Sub
//  21.02.2022  AH  Vorlagensperre
//  15.03.2022  AH  Text
//  01.04.2022  TM  Edit: Fahrauftragsdruck NUR per Sub, anschl. weiteren Druck deaktiviert
//  2022-09-12  ST  Edit: Prüfung bei BagP Löschung umgestellt von RecLinkCount auf "BA1_P_Data:BereitsVerwiegung"
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB EvtMdiActivate( aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusPos()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtKeyItem2(aEvt : event; aKey : int; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cDialog :   $BAG.Verwaltung
  cTitle :    'Betriebsaufträge'
  cFile :     700
  cMenuName : 'BA1.Bearbeiten'
  cPrefix :   'BA1'
  cZList :    $ZL.BA1
  cZList2 :   $RL.Info.Pos
  cZList3 :   $RL.Info.Pos2
  cKey :      1


  cDialogStart      : 'BA1.Verwaltung'
  cDialogStartCombo : 'BA1.Combo.Verwaltung'
  cRecht       : Rgt_BAG
  cMdiVar      : gMDIBag
end;

declare Auswahl(aBereich : alpha)

//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aBagNr  : int;
  opt aView   : logic;
  opt aCombo  : logic;
  opt aCmd    : alpha) : logic;
local begin
  Erx     : int;
  vBuf    : int;
  vMdi700 : int;
  vOK     : logic;
  vZL     : int;
  vI,vJ   : int;
  vHdl    : int;
  vCombo  : int;
  vProc   : alpha;
end;
begin

  if (aRecId=0) and (aBagNr<>0) then begin
    BAg.Nummer # aBagNr;
    Erx # RecRead(700,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(700,_recID);
  end;

  if (cMDIVar<>0) and (cMDIVar->wpName=^Lib_GuiCom:GetAlternativeName(cDialogStart)) then begin
    vMdi700 # cMDIVar;
    vBuf # VarInfo(WindowBonus);
    VarInstance( WindowBonus, CnvIA( cMDIVar->wpCustom ) );
    vZL # gZLList;
    if (w_Child<>0) and (w_Child->wpName=^Lib_GuiCom:GetAlternativeName(cDialogStartCombo)) then begin
      vCombo # w_Child;
      VarInstance( WindowBonus, CnvIA( vCombo->wpCustom ) );
      if (mode=c_modeList) then begin
        vOK # true;
        RecBufCopy(700, vCombo->wpdbrecbuf(700));
        if (RecLink(702,700,1,_RecFirst)>_rLocked) then RecBufClear(702);
        RecBufCopy(702, vCombo->wpdbrecbuf(702));
        w_Command # aCMD;
        //BA1_Combo_Main:Refreshall();
        vProc # Lib_Guicom:GetAlternativeMain(vCombo, 'BA1_Combo_Main');
        vCombo->Winfocusset(true);          // 2023-03-10 AH
        vCombo->WinUpdate(_WinUpdActivate);      
        Call(vProc+':Refreshall', vCombo);
       end;
    end;
    VarInstance( WindowBonus, vBuf);
  end;

  // Combomaske wurde repositioniert? -> dann BA-Verwaltung auch Repositionieren
  if (vOK) then begin
    RecBufCopy(700, cMDIVar->wpdbrecbuf(700));
    if (vZL<>0) then begin
      WinEvtProcessSet(_WinEvtLstDataInit,false);   // 2022-09-08 AH : nicht für MDI-Fremde Listen!!! Proj. 2429/507
      vZL->winupdate(_Winupdon, _WinlstRecDoSelecT);
      WinEvtProcessSet(_WinEvtLstDataInit,true);
    end;
    RETURN true;
  end;

  // Kein 700-MDI da!!!!


  vCombo # Lib_guicom2:FindMdiByName(cDialogStartCombo);
  if (vCombo>0) then begin
    vBuf # VarInfo(WindowBonus);
    VarInstance( WindowBonus, CnvIA( vCombo->wpCustom ) );
    if (mode=c_modeList) then begin
      RecBufCopy(700, vCombo->wpdbrecbuf(700));
      if (RecLink(702,700,1,_RecFirst)>_rLocked) then RecBufClear(702);
      RecBufCopy(702, vCombo->wpdbrecbuf(702));
      w_Command # aCMD;
 //     BA1_Combo_Main:Refreshall(vCombo);
      vProc # Lib_Guicom:GetAlternativeMain(vCombo, 'BA1_Combo_Main');
      vCombo->Winfocusset(true);          // 2023-03-10 AH
      vCombo->WinUpdate(_WinUpdActivate);      
      Call(vProc+':Refreshall', vCombo);
    end;
    VarInstance( WindowBonus, vBuf);
    RETURN true;
  end;

  // Kein 700-MDI und auch keine Combo da!!!
  
  // also alles neu starten...

  App_Main_Sub:StartVerwaltung(cDialogStart, cRecht, var cMDIvar, aRecID, aView);

  if (aCombo) then begin
    RecBufClear(702);
    gMDi->wpvisible # false;
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung',here+':AusPos',y);
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    w_Command # aCMD;
    Lib_GuiCom:RunChildWindow(gMDI);
  end;

  RETURN true;
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
  vFont : font;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  Lib_GuiCom:RecallList(cZList2);     // Usersettings holen
  Lib_GuiCom:RecallList(cZList3);     // Usersettings holen

  vHdl # cZList2;
  if (Usr.Font.Size<>0) then begin
    vFont # vHDL->wpfont;
    vFont:Size # Usr.Font.Size * 10;
    vHDL->wpfont # vFont;
  end;

  RunAFX('BAG.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('BAG.Init',aint(aEvt:Obj));
end;


//========================================================================
//  MarkPos
//
//========================================================================
sub MarkPos();
begin
  RecLink(700,702,1,_recFirst);
  Lib_Mark:MarkAdd(702,n,y);
  cZList2->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect | _WinLstPosSelected);
  cZList2->WinFocusSet(true);
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
//  EvtMdiActivate
//                  MDI-Fenster erhält Focus
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  App_Main:EvtMdiActivate(aEvt);
  $Mnu.Filter.Erledigt->wpMenuCheck # Filter_BAG;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vTmp : int;
end;
begin

  if (Mode=c_ModeView) then begin
    vTmp # WinSearch(gMDI,'RL.Info.Pos2');
    if (vTmp>0) then vTmp->Winupdate(_WinUpdOn, _WinLstfromfirst);
  end;

  if (BAG.Nummer<>0) and (BAG.Nummer<1000000000) then
    $lb.Nummer->wpcaption # AInt(BAG.Nummer)
  else
    $lb.Nummer->wpcaption # '';

  if ($lbBAG.WandelFunktion<>0) then begin
    $lbBAG.WandelFunktion->wpvisible # BAG.VorlageYN;
    $edBAG.WandelFunktion->wpvisible # BAG.VorlageYN;
    $cbBAG.VorlageSperreYN->wpvisible # BAG.VorlageYN;
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
  vTmp : int;
end;
begin

  // Neuanlage?
  if (Mode=c_ModeNew) then begin
    BAG.Nummer # myTmpNummer;
    vTmp # WinSearch(gMDI,'RL.Info.Pos2');
    if (vTmp>0) then vTmp->Winupdate(_WinUpdOn, _WinLstfromfirst);
  end
  else begin
    // Focus setzen auf Feld:
  end;
  $edBAG.Bemerkung->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
  vNr : int;
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

    TRANSON;

    if (BAG.VorlageYN) then begin
      vNr # Lib_Nummern:ReadNummer('Betriebsauftrag-Vorlage');
    end
    else begin
      vNr # Lib_Nummern:ReadNummer('Betriebsauftrag');
      BAG.BuchungsAlgoNr  # Set.BA.BuchungAlgoNr;
      BAG.VorlageSperreYN # false;
    end;
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      RETURN false;
    end;

    BAG.Nummer        # vNr;
    BAG.Anlage.Datum  # Today;
    BAG.Anlage.Zeit   # Now;
    BAG.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TxtRename(MyTmpText+'.700', '~700.'+CnvAI(BAG.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), 0);

    TRANSOFF;

    w_Command # '->POS';
  end;

  RunAFX('BAG.RecSave.Post','');

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin

  if (BAG.nummer=0) or (BAG.Nummer>=mytmpnummer) then TxtDelete(MyTmpText+'.700', 0);
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx   : int;
  vIOID : alpha;
end;
begin
  if ("BAG.Löschmarker"='*') then RETURN;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  // bereits fertiggemeldet?
  Erx # RecLink(702,700,1,_recLast);          // vom letzten zum ersten Arbeitsgang durchlinken
  WHILE (Erx < _rLocked) DO BEGIN
    if ("BAG.P.Löschmarker"='') then begin
      
      if (BA1_P_Data:BereitsVerwiegung(BAG.P.Aktion) = true) or
         (RecLinkInfo(709,702,6,_RecCount)>0) then begin
        Msg(702002,gTitle,0,0,0);
        RETURN;
      end;
    end;
    Erx # RecLink(702,700,1,_recPrev);
  END;

  // Keine Fertigmeldung bisher? Dann Einsatzmaterial wieder freimachen!
  Erx # RecLink(702,700,1,_recLast);          // vom letzten zum ersten Arbeitsgang durchlinken
  WHILE (Erx < _rLocked) DO BEGIN

    if ("BAG.P.Löschmarker"='') then begin
      Erx # RecLink(701,702,2,_recFirst);       // Alle Einsätze durchlaufen...
      WHILE (Erx < _rLocked) DO BEGIN

        vIOID # (cnvai(BAG.IO.Nummer) + '/' + cnvai(BAG.IO.ID));
        if !(BA1_IO_Data:EinsatzRaus(vIOID)) then begin
            Msg(701006,gTitle,0,0,0);
            // ... und entfernen
          RETURN;
        end;

        Erx # RecLink(701,702,2,_recFirst);
      END;
    end;

    Erx # RecLink(702,700,1,_recPrev);
  END;


  //RekDelete(gFile,0,'MAN');
  RecRead(700,1,_recLock);
  "BAG.Löschmarker" #  '*';
  "BAG.Lösch.Datum" # today;
  "BAG.Lösch.Zeit"  # now;
  "BAG.Lösch.User"  # gUsername;
  RekReplace(700,_recUnlock,'MAN');
  BA1_Data:SetVsbMarker("BAG.Löschmarker");      // 25.03.2021 AH

  cZList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
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
  vParent : int;
  vA    : alpha;
  vMode : alpha;
  vHdl  : int;
end;

begin

  case aBereich of

    'Positionen' : begin
      RecBufClear(702);
      gMDi->wpvisible # false;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung',here+':AusPos',y);
//      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      lib_Guicom:RecallWindow(gMDI); // Usersettings wiederherstellen
      Lib_GuiCom:RunChildWindow(gMDI);
    end

  end;

end;


//========================================================================
//  AusPos
//
//========================================================================
sub AusPos()
begin
  if (gMDI<>0) then begin
    gMDi->wpvisible # true;
    gZLList->Winfocusset(false);
  end;
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

  // ggf. sofort in Position springen...
  if (w_Command='->POS') then begin
    w_Command # '';
    Auswahl('Positionen');
    RETURN;
  end;

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);  // 06.03.2019 AH

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Mark');
  if (vHdl <> 0) then vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMenu->WinSearch('Mnu.Fertigmelden');
  if (vHdl <> 0) then vHdl->wpDisabled # (Mode<>c_ModeList) or (Rechte[Rgt_BA_Fertigmelden]=False) or (BAG.Fertig.Datum<>0.0.0);
  vHdl # gMenu->WinSearch('Mnu.Theorie.FM');
  if (vHdl <> 0) then vHdl->wpDisabled # (Mode<>c_ModeList) or (Rechte[Rgt_BA_Fertigmelden]=False) or (BAG.Fertig.Datum<>0.0.0);

  vHdl # gMenu->WinSearch('Mnu.Druck.Lohnfahren');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_modeView) and (mode<>c_ModeList)) or (BAG.P.Aktion<>c_BAG_Fahr);

  vHdl # gMenu->WinSearch('Mnu.Druck.LFA');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_modeView) and (mode<>c_ModeList)) or (Rechte[Rgt_Lfs_Druck_LFA]=n );

  vHdl # gMenu->WinSearch('Mnu.Druck.Avis');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_Avis]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.LFS');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_LFS]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.Freistellung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_Freistell]=n);



  vHdl # gMenu->WinSearch('Mnu.Positionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG]=n);

  vHdl # gMenu->WinSearch('Mnu.Graph');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (gUsergroup<>'PROGRAMMIERER') or (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG]=n);

  vHdl # gMenu->WinSearch('Mnu.Abschluss');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.VorlageYN) or (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG]=n) or (BAG.Fertig.Datum<>0.0.0);

  vHdl # gMenu->WinSearch('Mnu.Restore');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG_P_Restore]=n);

  vHdl # gMenu->WinSearch('Mnu.Gesamt.FM');
  if (vHdl<>0) then vHdl->wpdisabled # true;

  vHdl # gMenu->WinSearch('Mnu.Kosten');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.VorlageYN) or (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG]=n);// or (BAG.Fertig.Datum=0.0.0);
  vHdl # gMenu->WinSearch('Mnu.Kosten.Alle');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.VorlageYN) or (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG]=n);// or (BAG.Fertig.Datum=0.0.0);

  vHdl # gMenu->WinSearch('Mnu.Clear');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.AusVorlage');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.VorlageYN=false) or (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.ErzeugeVorlage');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (BAG.VorlageYN) or (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Rechte[Rgt_BAG_Anlegen]=n);


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
  Erx     : int;
  vHdl    : int;
  vFlag   : int;
  vQ      : alpha(4000);
  vBuf702 : int;
  vTmp    : int;
  vRef    : int;
  vNr     : int;
  vDat    : date;
  vTim    : time;
  vOK     : logic;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.CopyBA' : begin
      if (Rechte[Rgt_BAG_Anlegen]) then begin
        if (BA1_Data:CopyBA(BAG.Nummer, 1.0)>0) then begin
          if (gZLList->wpDbSelection<>0) then
            SelRecInsert(gZLList->wpDbSelection,700);
          gZLList->winupdate(_winupdon, _WinLstRecFromBuffer|_WinLstRecDoSelect);
          Msg(999998,'',0,0,0);
        end
        else begin
          ErrorOutput;
        end;
      end;
    end;


    'Mnu.Clear' : begin
      if (Rechte[Rgt_BAG_Loeschen]) then
        BA1_Subs:Clear();
    end;


    'Mnu.Bestellung' : begin
      Ein_Subs:Bag2Anf(true);
    end;


    'Mnu.Anfrage' : begin
      Ein_Subs:Bag2Anf(false);
    end;


    'Mnu.Mark2' : begin
      if (WinFocusget()=cZList2) then begin
        if (cZList2->wpdbRecId<>0) then begin
          RecRead(702,0,0,cZList2->wpdbrecid);
          MarkPos();
        end;
      end
      else App_Main:Mark();
    end;


  'Mnu.ErzeugeVorlage' : begin
      if (BAG.VorlageYN) then begin
        Msg(700016,'',0,0,0);
        RETURN false;
      end;
      if (Msg(700019,'',_WinIcoQuestion, _WinDialogYesNo,1)<>_winidyes) then RETURN false;
      vNr # BA1_Data:ErzeugeVorlageAusBA(BAG.Nummer);
      if (vNr<>0) then begin
        Msg(999998,'',0,0,0);
        BAG.Nummer # vNr;
        RecRead(700,1,0);
        if (gZLList->wpDbSelection<>0) then
          SelRecInsert(gZLList->wpDbSelection,700);
        gZLList->winupdate(_winupdon, _WinLstRecFromBuffer|_WinLstRecDoSelect);
        RETURN true;
      end;
    end;
  
  
  'Mnu.AusVorlage' : begin
      if (BAG.VorlageYN=falsE) then begin
        Msg(700013,'',0,0,0);
        RETURN false;
      end;
      if (Msg(700018,'',_WinIcoQuestion, _WinDialogYesNo,1)<>_winidyes) then RETURN false;
      vNr # BA1_Lohn_Subs:ErzeugeBAausVorlage(BAG.Nummer, 0,0);
      if (vNr<>0) then begin
        Msg(999998,'',0,0,0);
        BAG.Nummer # vNr;
        RecRead(700,1,0);
        if (gZLList->wpDbSelection<>0) then
          SelRecInsert(gZLList->wpDbSelection,700);
        gZLList->winupdate(_winupdon, _WinLstRecFromBuffer|_WinLstRecDoSelect);
        RETURN true;
      end;
    end;


    'Mnu.Merge' : begin
      BA1_Subs:Merge(BAG.Nummer);
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
      cZList2->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
      cZList3->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    end;


    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.DMS' : begin
      DMS_ArcFlow:ShowAbm('BAG', BAG.Nummer, 0);
    end;


    'Mnu.Ktx.BA.Druck' : begin
      Erx # RecRead(702,0,0,gSelectedRowID);    // Position holen
      gSelectedRowID # 0;
      if (Erx<>_rOK) then RETURN false;

      // Kreditlimitprüfung...
      if (BA1_Subs:Kreditlimit()=False) then RETURN true;

      // Drucken...
      if (BAG.P.ExternYN) then begin
        BA1_P_Subs:Print_Lohnformular(BAG.P.Nummer, BAG.P.Position);
      end
      else begin
        Lib_Dokumente:Printform(700,'Betriebsauftrag',true);
      end;

    end;


    'Mnu.Filter.Erledigt' : begin
      Filter_BAG # !(Filter_BAG);
      $Mnu.Filter.Erledigt->wpMenuCheck # Filter_BAG;

      if (gZLList->wpdbselection<>0) then begin
        vHdl # gZLList->wpdbselection;
        if (SelInfo(vHdl, _SelCount) > 0) then
          vRef # _WinLstRecFromRecId
        else
          vRef # _WinLstFromFirst;
        gZLList->wpDbSelection # 0;
        SelClose(vHdl);
        SelDelete(gFile,w_selName);
        w_SelName # '';
        gZLList->WinUpdate(_WinUpdOn, vRef | _WinLstRecDoSelect);
        RecRead(gFile,0,0,gZLList->wpdbrecid);
        App_Main:Refreshmode();
        RETURN true;
      end;
      vQ # '';
      Lib_Sel:QAlpha( var vQ, '"BAG.Löschmarker"', '=', '');
      Lib_Sel:QRecList(0,vQ);

      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      RecRead(gFile,0,0,gZLList->wpdbrecid);
      App_Main:Refreshmode();
      RETURN true;
    end;


    'Mnu.Auto.Rueck' : begin
      if (BAG.VorlageYN)then RETURN true;

      if (Msg(700004,'(rückwärts)',_WinIcoQuestion, _WinDialogYesNo,1)<>_WinidYes) then RETURN true;

      Erx # BA1_Plan_Data:AutoPlanung_R();
      if (Erx<>0) then
        Msg(700006,AInt(-Erx),0,0,0)
      else
        Msg(700005,'',0,0,0);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,BAG.Anlage.Datum, BAG.Anlage.Zeit, BAG.Anlage.User, "BAG.Lösch.Datum", "BAG.Lösch.Zeit", "BAG.Lösch.User");
    end;


    'Mnu.Fertigmelden' : begin
      if (BAG.VorlageYN)then RETURN true;

      vHdl # WinFocusGet();
      if (vHdl->wpname='RL.Info.Pos') then begin
        Erx # RecRead(702,0,_recid,$Rl.Info.Pos->wpDbRecId);
        if (Erx<=_rLocked) then begin
          RecBufClear(707);
          BAG.FM.Nummer   # BAG.Nummer;
          BAG.FM.Position # BAG.P.Position;
          BA1_Fertigmelden:FMKopf();
          ErrorOutput;
        end;
      end
      else begin
        RecBufClear(707);
        BAG.FM.Nummer   # BAG.Nummer;
        BA1_Fertigmelden:FMKopf();
        ErrorOutput;
      end;
    end;

/**
    'Mnu.Gesamt.FM' : begin
      if (BAG.VorlageYN)then RETURN true;

      BA1_Fertigmelden:FMGesamt(BAG.Nummer);
    end;
***/

    'Mnu.Theorie.FM' : begin
      if (BAG.VorlageYN)then RETURN true;

      // Focussierte Position holen
      vHdl # WinFocusGet();
      if (vHdl->wpname='RL.Info.Pos') then begin

        // Position lesen
        Erx # RecRead(702,0,_recid,$Rl.Info.Pos->wpDbRecId);
        if (Erx <= _rLocked) then begin
          if ("BAG.P.Typ.xIn-yOutYN") then begin
            Msg(702033,'',0,0,0);
            RETURN true;
          end;
          RecBufClear(707);
          BAG.FM.Nummer   # BAG.Nummer;
          BAG.FM.Position # BAG.P.Position;
          BA1_Fertigmelden:FMTheorie(BAG.FM.Nummer, BAG.FM.Position);
          ErrorOutput;    // Entstandene Fehler am Ende ausgeben
        end;
      end
      else begin
        // Position durch den User wählen lassen
        RecBufClear(707);
        BAG.FM.Nummer   # BAG.Nummer;
        BA1_Fertigmelden:FMTheorie(BAG.FM.Nummer);
        ErrorOutput;
      end;

    end; // 'Mnu.Theorie.FM'


    'Mnu.Abschluss' : begin
      if (BAG.VorlageYN)then RETURN true;

      vHdl # WinFocusGet();
      if (vHdl->wpname='RL.Info.Pos') then begin
        Erx # RecRead(702,0,_recid,$Rl.Info.Pos->wpDbRecId);
        if (Erx<=_rLocked) then begin
          // Fahraufträge oder Versandarbeitsgänge werden über Lieferschein fertiggemeldet
          if (BAG.P.Aktion=c_BAG_Fahr) then begin // 15.10.2021 AH   OR (BAG.P.Aktion=c_BAG_Versand) then begin
            Error(702014,'');
            ErrorOutput;
            RETURN false;
          end;
          BA1_Fertigmelden:AbschlussPos(BAG.P.Nummer, BAG.P.Position, 0.0.0, now)
          ErrorOutput;
          RETURN true;
        end;
      end;

      BA1_Fertigmelden:AbschlussKopf(BAG.Nummer);
      ErrorOutput;
    end;


    'Mnu.Restore' : begin
      if (BAG.VorlageYN)then RETURN true;

      if (Rechte[Rgt_BAG_P_Restore]=n) then RETURN true;
      vHdl # $RL.Info.Pos->wpdbrecId;
      if (vHdl=0) then begin
        Msg(702019,'',0,0,0);
        RETURN true;
      end;
      RecRead(702,0,0,vHdl);    // Position holen
      if ("BAG.P.Löschmarker"='*') then begin
        vOK # BA1_P_data:RestorePos();
//        if (vOK) and (Set.Wie.BaRestore='S') then begin
//          Erx # Msg(702050, '', _winicoquestion,_WinDialogYesNo,2);
//          if (Erx=_WinIdYes) then begin
//            vOK # BA1_FM_Data:AlleDerPosEntfernen();
//          end;
//        end;
        ErrorOutput;
      end;
      if (gZLList<>0) then
        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Kosten' : begin
      if (BAG.VorlageYN) then RETURN true;
      BA1_Subs:ReCalcKosten(n,n);
      Msg(999998,'',0,0,0);
    end;


    'Mnu.Kosten.Alle' : begin
      BA1_Subs:RecalcAllKosten();
    end;


    'Mnu.Positionen' : begin
      Auswahl('Positionen');
//      vParent->wpvisible # false;
    end;


    'Mnu.Graph' : begin
      BA1_Graph:Start(BAG.Nummer);
    end;


    'Mnu.Druck.BA.Deckblatt' : begin
      // Kreditlimitprüfung...
      if (BA1_Subs:Kreditlimit()=False) then RETURN true;
      Lib_Dokumente:Printform(700,'Deckblatt',true);
    end;


    'Mnu.Druck.BA' : begin
      // Kreditlimitprüfung...
      if (BA1_Subs:Kreditlimit()=False) then RETURN true;
      Lib_Dokumente:Printform(700,'Betriebsauftrag',true);
    end; // EO Mnu.Druck.BA


    'Mnu.Druck.BAUeS' : begin
      // Kreditlimitprüfung...
      if (BA1_Subs:Kreditlimit()=False) then
        RETURN true;
      Lib_Dokumente:Printform(700,'BA-Übersicht',true);
    end; // EO Mnu.Druck.BAUeS


    'Mnu.Druck.Lohn' : begin
      vHdl # $RL.Info.Pos->wpdbrecId;
      if (vHdl=0) then begin
        Msg(702019,'',0,0,0);
        RETURN true;
      end;

      RecRead(702,0,0,vHdl);    // Position holen

      // ST 2022-01-13 Projekt 2200/34 Fahraufträge als Lohnauftrag auch mit Kreditlimit
      if (BAG.P.Aktion = c_BAG_Fahr) then begin
        BA1_P_Subs:Print_LohnFahrauftag();
        RETURN true;
      end;
      
      // Kreditlimitprüfung...
      if (BA1_Subs:Kreditlimit(BAG.P.Position)=False) then RETURN true;

      RecRead(702,0,0,vHdl);    // Position holen

      // Drucken...
      BA1_P_Subs:Print_Lohnformular(BAG.P.Nummer, BAG.P.Position);

    end;  // Lohnformular


    'Mnu.Druck.AlleLohnformulare' : begin
      // Kreditlimitprüfung...
      if (BA1_Subs:Kreditlimit()=False) then RETURN true;

      // Suche alle Lohnformulare

      FOR Erx # RecLink(702, 700, 1, _recFirst);
      LOOP Erx # RecLink(702, 700, 1, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN
        vBuf702 # RekSave(702);
        BA1_P_Subs:Print_Lohnformular(BAG.P.Nummer, BAG.P.Position); // Drucken...
        RekRestore(vBuf702);
      END; // EO Positionsloop

    end; // EO Mnu.Druck.AlleLohnformulare

    'Mnu.Druck.DmsDeckblatt'  : begin
      Lib_Dokumente:Printform(700, 'DMS Deckblatt', false);
    end;


    'Mnu.Druck.LFS' : begin
      if (BAG.P.Aktion<>c_BAG_Fahr) then RETURN true;
      if (Rechte[Rgt_Lfs_Druck_LFS]=false) then RETURN false;
      
      FOR Erx # RecLink(440,702,14,_recFirst)     // LFS loopen
      LOOP Erx # RecLink(440,702,14,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (Lfs_Data:Druck_LFS()) and (Set.LFS.Verbuchen='A') and
          ((Mode=c_ModeList) or (Mode=c_ModeView)) and
          (Lfs.Datum.Verbucht=0.0.0) and
          (lfs.zuBA.Nummer=0) and
          (Rechte[Rgt_Lfs_Verbuchen]) then begin
          if (Msg(440007,'',_WinIcoQuestion,_WinDialogYesNo,1)=_winIdyes) then begin
            if (Dlg_Standard:Datum(Translate('Verbuchungsdatum'), var vDat, today)=false) then RETURN false;
            if (vDat=today) then vTim # now;
            Lfs_Data:Verbuchen(Lfs.Nummer, vDat, vTim);
            ErrorOutput;
          end;
        end;
      END;
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.Avis' : begin
      if (BAG.P.Aktion<>c_BAG_Fahr) then RETURN true;
      if (Rechte[Rgt_Lfs_Druck_Avis]=false) then RETURN false;

      FOR Erx # RecLink(440,702,14,_recFirst)     // LFS loopen
      LOOP Erx # RecLink(440,702,14,_recNext)
      WHILE (Erx<=_rLocked) do begin
        Lfs_Data:Druck_Avis();
      END;
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.LFA' : begin
      BA1_P_Subs:Print_LohnFahrauftag();
      
      // 2022-04-01 TM ausgeklammert, weil bereits durch BA1_P_Subs:Print_LohnFahrauftag() gedruckt!
      
      // FOR Erx # RecLink(440,702,14,_recFirst)     // LFS loopen
      // LOOP Erx # RecLink(440,702,14,_recNext)
      // WHILE (Erx<=_rLocked) do begin
      //   Lfs_VLDAW_Data:Druck_LFA();
      // END;
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    end;


    'Mnu.Druck.Freistellung' : begin
      if (BAG.P.Aktion<>c_BAG_Fahr) then RETURN true;
      if (Rechte[Rgt_Lfs_Druck_Freistell]=false) then RETURN false;
      
      FOR Erx # RecLink(440,702,14,_recFirst)     // LFS loopen
      LOOP Erx # RecLink(440,702,14,_recNext)
      WHILE (Erx<=_rLocked) do begin
        Lfs_Data:Druck_Freistellung();
      END;
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
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
  vA : alpha;
end;
begin

  if (aEvt:Obj->wpname='bt.Text') then begin    // 15.03.2022 AH
    if (BAG.nummer=0) or (BAG.Nummer>=mytmpnummer) then
      vA # MyTmpText+'.700';
    else
      vA # '~700.'+CnvAI(BAG.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
    Mdi_TxtEditor_Main:Start(vA, Rechte[Rgt_BAG_Aendern], Translate('BA-Text'));
  end;

  if (aEvt:Obj->wpname='Mark') then begin
    // Position?
    if (cZList2->wpdbrecid<>0) then begin
      MarkPos();
      RETURN true;
    end
    else begin
      RETURN App_Main:EvtClicked(aEvt);
    end;
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.xxxxx' :   Auswahl('...');
  end;

end;


//========================================================================
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
begin
  if (aEvt:obj->wpname='cbBAG.VorlageYN') then begin
    aEvt:obj->winupdate(_WinUpdObj2Fld);
    Refreshifm();
  end;
  
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
  vCol      : int;
end;
begin
  if (aMark) then begin
    if (RunAFX('BAG.EvtLstDataInit','y' + aEvt:obj->wpName+'|'+aint(aEvt:obj)+'|'+aint(aRecId))<0) then RETURN;
  end
  else if (RunAFX('BAG.EvtLstDataInit','n' + aEvt:obj->wpName+'|'+aint(aEvt:Obj)+'|'+aint(aRecId))<0) then RETURN;


  // Positionsliste?
  if (aEvt:obj->wpname='RL.Info.Pos') or
    (aEvt:obj->wpname='RL.Info.Pos2') then begin

    // 21.03.2016 AH: Markierungen anzeigen
    vCol # _WinColWhite;
    if (aRecId<>0) then begin
      if ( Lib_Mark:IstMarkiert( 702, aRecId)) then begin
        vCol # Set.Col.RList.Marke;
      end;
    end;
//    end;  17.05.2022 AH falsche Kammerung
    if (vCol<>0) then // begin 17.05.2022 AH falsche Kammerung
      Lib_GuiCom:ZLColorLine( cZList2, vCol, true );

    if (BAG.P.Aktion=c_BAG_VSB) then
      BAG.P.Bezeichnung   # BAG.P.Aktion+' '+BAG.P.Kommission;

    RecBufClear(401);
    Gv.ALpha.01 # '';

    if (BAG.P.Aktion=c_BAG_VSB) then begin
      if (BAG.P.Auftragsnr<>0) then begin
        // Auftrag holen
        Erx # RecLink(401,702,16,_recFirst);
        if (Erx>_rLocked) then begin
          Erx # RecLink(411,702,17,_recFirst);
          if (Erx>_rLocked) then RecBufClear(401)
          else RecBufCopy(411,401);
        end;
        Gv.Alpha.01 # ANum(Auf.P.Dicke,Set.Stellen.Dicke)+' x '+ANum(Auf.P.Breite,Set.Stellen.Breite);
        if ("Auf.P.Länge"<>0.0) then Gv.ALpha.01 # Gv.Alpha.01 + ' x '+ANum("Auf.P.Länge","Set.Stellen.Länge");
        BAG.P.Plan.EndDat # Auf.P.TerminZusage;
        if (BAG.P.Plan.EndDat=0.0.0) then BAG.P.Plan.EndDat # Auf.P.Termin1Wunsch;
      end;
    end;


    if (BAG.P.Fenster.MinDat<>0.0.0) then
      GV.Alpha.02 # cnvad(BAG.P.Fenster.MinDat) + ' ' + cnvat(BAG.P.Fenster.MinZei)
    else
      GV.alpha.02 # '';
    if (BAG.P.Fenster.MaxDat<>0.0.0) then
      GV.Alpha.03 # cnvad(BAG.P.Fenster.MaxDat) + ' ' + cnvat(BAG.P.Fenster.MaxZei)
    else
      GV.alpha.03 # '';
    if (BAG.P.Plan.StartDat<>0.0.0) then
      GV.Alpha.05 # cnvad(BAG.P.Plan.StartDat) + ' ' + cnvat(BAG.P.Plan.StartZeit)
    else
      GV.alpha.05 # '';
    if (BAG.P.Plan.EndDat<>0.0.0) then
      GV.Alpha.06 # cnvad(BAG.P.Plan.EndDat) + ' ' + cnvat(BAG.P.Plan.EndZeit)
    else
      GV.alpha.06 # '';

    GV.Alpha.04 # BAG.P.Bezeichnung;
    if (BAG.P.Level>1) then
      Gv.Alpha.04 # StrChar(32,(BAG.P.Level*3)-3)+BAG.P.Bezeichnung;

    if (aMark=n) then begin
      if (BAG.P.Aktion2='QS?') then
        Lib_GuiCom:ZLColorLine(aEvt:Obj, _WinColLightYellow)
      else if ("BAG.P.Löschmarker"='*') then
        Lib_GuiCom:ZLColorLine(aEvt:Obj,Set.Col.RList.Deletd)
    end;

  end;     // BA-Position



  // Kopfliste?
  if (aEvt:obj->wpname='ZL.BA1') then begin

    if (aMark=n) then begin
      if ("BAG.Löschmarker"='*') or (BAG.VorlageSperreYN) then
        Lib_GuiCom:ZLColorLine(aEvt:Obj,Set.Col.RList.Deletd)
    end;
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
local begin
  vTmp : int;
end;
begin

  RecRead(gFile,0,_recid,aRecID);

  vTmp # WinSearch(gMDI,'RL.Info.Pos');
  if (vTmp>0) then begin
    vTmp->Winupdate(_WinUpdOn, _WinLstfromfirst);
  end;

  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
//  EvtLstSelectPos
//                Zeilenauswahl von RecList/DataList der POSITIONEN
//========================================================================
sub EvtLstSelectPos(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
local begin
  vTmp : int;
end;
begin
  RecRead(702,0,_recid,aRecID);

  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
//  EvtKeyItem2
//            Keyboard in RecList/DataList
//========================================================================
sub EvtKeyItem2(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aRecID                : int;          // RecID
) : logic
begin

  if (aEvt:obj=cZList2) then begin
    if (Mode=c_ModeList) and (akey=_WinKeyInsert) then begin
      if (cZList2->wpdbrecid<>0) then begin
        RecRead(702,0,0,cZList2->wpdbrecid);
        MarkPos();
      end;
    end;
    RETURN true;
  end;


  if (aKey=_WinKeyReturn) and
    (w_Auswahlmode=n) and
    ((Mode=c_ModeList) or (Mode=c_ModeList2)) then begin
    RecRead(gFile,0,_recid,aRecID);
    Auswahl('Positionen');
    RETURN true;
  end;

  RETURN App_Main:EvtKeyItem(aEvt, aKey, aRecId);
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
  Lib_GuiCom:RememberList(cZList2);
  Lib_GuiCom:RememberList(cZList3);
  RETURN true;
end;


//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect : rect;
  vTmp  : int;
  vHdl  : int;
end
begin
  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  //Quickbar
  vHdl # Winsearch(gMDI,'gs.Main');
  if (vHdl<>0) then begin
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left+2;
    vRect:bottom    # aRect:bottom-aRect:Top+5;
    vHdl->wparea    # vRect;
  end;

  if (aFlags & _WinPosSized != 0) then begin
    if (gZLList<>0) then vHdl # gZLList;
    else if (gDataList<>0) then vHdl # gDataList
    else RETURN true;

    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28 - w_QBHeight;
    vHdl->wparea # vRect;
  end;
  
  if (aFlags & _WinPosSized != 0) then begin

    vRect           # gZLList->wpArea;
    vRect:right     # (aRect:right-aRect:left-4 - 60) / 2;
    vRect:bottom    # (aRect:bottom-aRect:Top-28 - w_QBHeight);
    gZLList->wparea # vRect;

    // Überschrift setzen
    Lib_GUiCom:ObjSetPos($LB.List1, (aRect:right-aRect:left-50) / 2, 0);//50);

    RecRead(gFile,0,0,gZLList->wpdbrecid);

    vRect           # cZList2->wpArea;
    vRect:left      # (aRect:right-aRect:left-50) / 2;
    vRect:right     # (aRect:right-aRect:left-4);
    vRect:bottom    # (aRect:bottom-aRect:Top-28 - w_QBHeight);
    cZList2->wparea # vRect;

    // MS 16.02.2010 Auto-Anpassung des Infosfensters "List3"
    vRect           # cZList3->wpArea;
    vRect:right     # (aRect:right-aRect:left-4);
    vRect:bottom    # (aRect:bottom-aRect:Top-28 - w_QBHeight);
    cZList3->wparea # vRect;

    vTmp # WinSearch(gMDI,'RL.Info.Pos');
    if(vTmp <> 0) then begin
      vTmp->Winupdate(_WinUpdOn, _WinLstFromFirst);
    end;

//    Lib_GUiCom:ObjSetPos($lb.Mat.Info2, 0, vRect:bottom+8+28);
  end;

	RETURN (true);
end;

//========================================================================
//========================================================================
//========================================================================