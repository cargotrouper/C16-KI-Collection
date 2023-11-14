@A+
//==== Business-Control ==================================================
//
//  Prozedur    Vbk_K_Main
//                        OHNE E_R_G
//  Info
//
//
//  02.11.2003  ST  Erstellung der Prozedur
//  18.02.2013  AI  Gegenkonto Prüfung
//  07.10.2014  AH  Gegenkonto zieht immer Steuerschlüssel
//  10.08.2016  AH  Nur Kontierungen mit Rechnungsposition < 10000 werden summiert
//  12.11.2021  AH  ERX
//  26.07.2022  HA  Quick Jump
//  2022-11-08  ST  Fix: Nachkommastellen Gewichtsangabe
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
//    SUB AusGegenkonto()
//    SUB AusSteuerschl()
//    SUB AusKostenstelle()
//    SUB AusSchluessel()
//    SUB AusSchluessel2()
//    SUB AusIntrastat()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Verbindlichkeiten Kontierung'
  cFile :     551
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Vbk_k'
  cZList :    $ZL.Verbind.Kontierung
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

  Lib_Guicom2:Underline($edVbk.K.Schluessel);
  Lib_Guicom2:Underline($edVbk.K.Gegenkonto);
  Lib_Guicom2:Underline($edVbk.K.Kostenstelle);
  Lib_Guicom2:Underline($edVbk.K.Steuerschl);
  Lib_Guicom2:Underline($edVbk.K.Intrastat);


  // Auswahlfelder setzen...
  SetStdAusFeld('edVbk.K.Gegenkonto'    ,'Gegenkonto');
  SetStdAusFeld('edVbk.K.Intrastat'     ,'Intrastat');
  SetStdAusFeld('edVbk.K.Steuerschl'    ,'Steuerschl');
  SetStdAusFeld('edVbk.K.Kostenstelle'  ,'Kostenstelle');
  SetStdAusFeld('edVbk.K.Schluessel'    ,'Schluessel');

  $edGewicht->wpDecimals # Set.Stellen.Gewicht;
  
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
  Erx   : int;
  vTmp  : int;
end;
begin

  if (aName = '') or (aName = 'LB.Nummer') then begin
    $Lb.Nummer -> wpcaption # AInt(Vbk.K.Nummer);
  end;

  if (aName = '') or (aName = 'edBetrag') then begin
    Vbk.K.BetragW1 # Vbk.K.Betrag / "ERe.Währungskurs";
    $edHW1 -> wpCaptionFloat # Vbk.K.BetragW1;
  end;


   // Währungen von Eingangsrechnung holen
  Erx # RecLink(814,560,6,0);
  if (Erx<=_rLocked) then begin
    $lb.Wae1 ->wpcaption # "Wae.Kürzel";
  end else
    $lb.Wae1 ->wpcaption # '';

  // Gegenkonto holen...
  Erx # RekLink(854,551,3,0);
  if (aNamE='edVbk.K.Gegenkonto') and ($edVBK.K.Gegenkonto->wpchanged) and (Erx<=_rLocked) then begin
    if ("GKo.Steuerschlüssel"<>0) then
      VBK.K.Steuerschl        # ("Gko.Steuerschlüssel" * 100 ) + ERe.Adr.Steuerschl;
    $edVBk.K.Steuerschl->Winupdate(_WinUpdFld2Obj);
  end;
  $lb.Gegenkonto ->wpcaption # GKo.Bezeichnung;

  // Steuerschl. holen...
  Erx # RecLink(813,551,4,0);
  if (Erx<=_rLocked) then begin
    $lb.steuerschl ->wpcaption # Sts.Bezeichnung;
  end else
    $lb.Steuerschl ->wpcaption # '';

  // Kostenstelle holen...
  Erx # RecLink(846,551,5,0);
  if (Erx<=_rLocked) then begin
    $lb.Kostenstelle ->wpcaption # Kst.Bezeichnung;
  end else
    $lb.Kostenstelle ->wpcaption # '';

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
sub RecInit( opt aKeepData : logic )
local begin
  vGegenkonto : int;
end;
begin

  // Ankerfunktion?
  if (RunAFX('Vbk.K.RecInit','')<0) then RETURN;

  if ( aKeepData ) then begin
//    vGegenkonto # Vbk.K.Gegenkonto;
//    RecBufClear( 551 );
//    Vbk.K.Gegenkonto # vGegenkonto;
  end;

  // Felder Disablen durch:
  Vbk.K.Nummer # ERe.Nummer;

  Lib_GuiCom:Disable($edHW1);
  // Focus setzen auf Feld:
  $edVbk.K.EingangsrePos->WinFocusSet(true);

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
  if (Vbk.K.Steuerschl<>0) then begin
    Erx # RecLink(813,551,4,0);
    If (Erx>_rLocked) or (VbK.K.Steuerschl<1000) then begin
      Msg(001201,Translate('Steuerschlüssel'),0,0,0);
      $edVbk.K.Steuerschl->WinFocusSet(true);
      RETURN false;
    end;
  end;
  if (Vbk.K.Gegenkonto<>0) then begin
    Erx # RecLink(854,551,3,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Gegenkonto'),0,0,0);
      $edVbk.K.Gegenkonto->WinFocusSet(true);
      RETURN false;
    end;
  end;


  // Sonderfunktion:
  if (RunAFX('Vbk.K.RecSave','')<>0) then begin
    if (AfxRes<>_rOk) then begin
      RETURN False;
    end;
  end;

  
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Eingangsrechnung updaten
    IF (Vbk.k.Eingangsrepos<10000) and (RecLink(560,551,2,_RecLock) = _rOk) then begin
      ERe.KontiertBetrag    # ERe.Kontiertbetrag + Vbk.K.Betrag - Protokollbuffer[551]->Vbk.K.Betrag;
      ERe.KontiertBetragW1  # ERe.KontiertbetragW1 + Vbk.K.BetragW1 - Protokollbuffer[551]->Vbk.K.BetragW1;
      "ERe.Kontiert.Stück"  # "ERe.Kontiert.Stück" + "Vbk.K.Stückzahl" - Protokollbuffer[551]->"Vbk.K.Stückzahl";
      ERe.Kontiert.Gewicht  # ERe.Kontiert.Gewicht + Vbk.K.Gewicht - Protokollbuffer[551]->Vbk.K.Gewicht;
      Erx # RekReplace(560,_RecUnlock,'AUTO');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
    end;

    PtD_Main:Compare(gFile);
  end
  else begin

    TRANSON;

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Eingangsrechnung updaten
    IF (Vbk.k.Eingangsrepos<10000) and (RecLink(560,551,2,_RecLock) = _rOk) then begin
      ERe.KontiertBetrag    # ERe.Kontiertbetrag + Vbk.K.Betrag;
      ERe.KontiertBetragW1  # ERe.KontiertbetragW1 + Vbk.K.BetragW1;
      "ERe.Kontiert.Stück"  # "ERe.Kontiert.Stück" + "Vbk.K.Stückzahl";
      ERe.Kontiert.Gewicht  # ERe.Kontiert.Gewicht + Vbk.K.Gewicht;
      Erx # RekReplace(560,_RecUnlock,'AUTO');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
    end;

    TRANSOFF;

    // weitere Positionen [19.05.2010/PW]
    if (Set.Installname<>'BSP') then begin
      if ( Msg( 000005, '', _winIcoQuestion, _winDialogYesNo, 1 ) = _winIdYes ) then begin
        RecInit( true );
        RETURN false;
      end;
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
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  TRANSON;

  ERx # RekDelete(gFile,0,'MAN');
  if (erx<>_rOK) then begin
    TRANSBRK;
    RETURN;
  end;

  // Eingangsrechnung updaten
  IF (Vbk.k.Eingangsrepos<10000) and (RecLink(560,551,2,_RecLock) = _rOk) then begin
    ERe.KontiertBetrag    # ERe.Kontiertbetrag - Vbk.K.Betrag;
    ERe.KontiertBetragW1  # ERe.KontiertbetragW1 - Vbk.K.BetragW1;
    "ERe.Kontiert.Stück"  # "ERe.Kontiert.Stück" - "Vbk.K.Stückzahl";
    ERe.Kontiert.Gewicht  # ERe.Kontiert.Gewicht - Vbk.K.Gewicht;
    Erx # RekReplace(560,_RecUnlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;
  end;

  TRANSOFF;
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
  aBereich : alpha
)
local begin
  vQ : alpha(4000);
end;
begin

  case aBereich of

    'Intrastat' : begin
      RecBufClear(220);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusIntrastat');
      // Selektion
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QAlpha(var vQ, 'MSL.Strukturtyp', '=', 'INTRA');
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Schluessel' : begin
      // Ankerfunktion
      if (RunAFX('APL.Auswahl','551')<0) then RETURN;

      RecBufClear(842);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Apl.Verwaltung',here+':AusSchluessel');
      // Selektion
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList( 0, 'ApL.EinkaufYN' );
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Schluessel2' : begin
      RecBufClear(843);

      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Apl.L.Verwaltung',here+':AusSchluessel2');
      // Selektion
      VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
      vQ # 'ApL.L.Key1 = ' + cnvAI(ApL.Key1);
      vQ # vQ + ' AND ApL.L.Key2 = ' + cnvAI(ApL.Key2) ;
      vQ # vQ + ' AND ApL.L.Key3 = ' + cnvAI(ApL.Key3);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Gegenkonto' : begin
      RecBufClear(854);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'GKo.Verwaltung',here+':AusGegenkonto');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Steuerschl' : begin
      RecBufClear(813);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Sts.Verwaltung',here+':AusSteuerschl');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kostenstelle' : begin
      RecBufClear(846);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Kst.Verwaltung',here+':AusKostenstelle');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;
end;


//========================================================================
//  AusGegenkonto
//
//========================================================================
sub AusGegenkonto()
begin

  if (gSelected<>0) then begin
    RecRead(854,0,_RecId,gSelected);
    gSelected # 0;
    VBK.K.Gegenkonto        # Gko.Nummer;
    if ("GKo.Steuerschlüssel"<>0) then
      VBK.K.Steuerschl        # ("Gko.Steuerschlüssel" * 100 ) + ERe.Adr.Steuerschl;
    $edVBk.K.Steuerschl->Winupdate(_WinUpdFld2Obj);
  end;
  $edVBk.K.Gegenkonto->Winfocusset(false);
end;


//========================================================================
//  AusSteuerschl
//
//========================================================================
sub AusSteuerschl()
begin

  if (gSelected<>0) then begin
    RecRead(813,0,_RecId,gSelected);
    gSelected # 0;
    VBK.K.Steuerschl # Sts.Nummer;
  end;
  $edVBk.K.Steuerschl->Winfocusset(false);
end;


//========================================================================
//  AusKostenstelle
//
//========================================================================
sub AusKostenstelle()
begin

  if (gSelected<>0) then begin
    RecRead(846,0,_RecId,gSelected);
    gSelected # 0;
    VBK.K.Kostenstelle # Kst.Nummer;
  end;
  $edVBk.K.Kostenstelle->Winfocusset(false);
end;


//========================================================================
//  AusSchluessel
//
//========================================================================
sub AusSchluessel()
begin
  if (gSelected<>0) then begin
    RecRead(842,0,_RecId,gSelected);
    gSelected # 0;
    //"VBK.K.Schlüssel" #
    Auswahl('Schluessel2');
  end;
  $edVBk.K.Schluessel->Winfocusset(true);
end;


//========================================================================
//  AusSchluessel2
//
//========================================================================
sub AusSchluessel2()
begin
  if (gSelected<>0) then begin
    RecRead(843,0,_RecId,gSelected);
    //Auf.Z.Schluessel #
    gSelected # 0;
    "VbK.K.Schlüssel"     # '#'+Cnvai(ApL.L.Key2,_fmtnumleadzero,0,3)+'.'+CnvAI(ApL.L.Key3,_fmtnumleadzero,0,3)+'.'+cnvai(ApL.L.Key4,_fmtnumleadzero,0,3);
    VbK.K.Bezeichnung     # ApL.L.Bezeichnung.L1;
    gMDI->winupdate();
  end;
  // Focus auf Editfeld setzen:
  $edVbK.K.Schluessel->Winfocusset(true);
end;


//========================================================================
//  AusIntrastat
//
//========================================================================
sub AusIntrastat()
local begin
  vTmp  : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(220,0,_RecId,gSelected);
    // Feldübernahme
    Vbk.K.Intrastat # MSL.Intrastatnr;
    gSelected # 0;
    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edVbk.K.Intrastat->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vbk_K_Anlegen]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vbk_K_Anlegen]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vbk_K_Aendern]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vbk_K_Aendern]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vbk_K_Loeschen]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vbk_K_Loeschen]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);

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
      PtD_Main:View( gFile );
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
    'bt.Gegenkonto'   : Auswahl('Gegenkonto');
    'bt.Steuerschl'   : Auswahl('Steuerschl');
    'bt.Kostenstelle' : Auswahl('Kostenstelle');
    'bt.Schluessel'   : Auswahl('Schluessel');
    'bt.Intrastat'    : Auswahl('Intrastat');
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
sub EvtClose(
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
local begin
  vToken : alpha;
  vBuf,vBuf2  : int;
end;

begin

  if ((aName =^ 'edVbk.K.Schluessel') AND (aBuf->"Vbk.K.Schlüssel"<>'')) then begin
    RecBufClear(842);
   vToken # Lib_Strings:Strings_Token("Vbk.K.Schlüssel", '.', 1);
   ApL.Key1 # CnvIA(vToken);
   
   vToken # Lib_Strings:Strings_Token("Vbk.K.Schlüssel", '.', 2);
   ApL.Key2 # CnvIA(vToken);
   
   vToken # Lib_Strings:Strings_Token("Vbk.K.Schlüssel", '.', 3);
   ApL.Key2 # CnvIA(vToken);
    Lib_Guicom2:JumpToWindow('Apl.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVbk.K.Gegenkonto') AND (aBuf->Vbk.K.Gegenkonto<>0)) then begin
    RekLink(854,551,3,0);   // Gegenkonto holen
    Lib_Guicom2:JumpToWindow('GKo.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVbk.K.Kostenstelle') AND (aBuf->Vbk.K.Kostenstelle<>0)) then begin
    RekLink(846,551,5,0);   // Kostenstelle holen
    Lib_Guicom2:JumpToWindow('Kst.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVbk.K.Steuerschl') AND (aBuf->Vbk.K.Steuerschl<>0)) then begin
    RekLink(813,551,4,0);   // Steuerschlüssel holen
    Lib_Guicom2:JumpToWindow('Sts.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVbk.K.Intrastat') AND (aBuf->Vbk.K.Intrastat<>'')) then begin
    MSL.Intrastatnr # Vbk.K.Intrastat;
    RecRead(220,2,0);
    Lib_Guicom2:JumpToWindow('MSL.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================