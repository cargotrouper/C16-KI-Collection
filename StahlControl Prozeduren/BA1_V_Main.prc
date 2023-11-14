@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_V_Main
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  24.02.2010  ST  Sub RecDel: SilentModus hinzugefügt
//  29.04.2015  ST  Ankeraufruf RecSavePost hinzugefügt
//  23.10.2018  AH  AFX "BAG.V.RecInit"
//  07.06.2019  AH  AFX "BAG.V.RecSave"
//  05.04.2022  AH  ERX
//  20.07.2022  HA  Quick jump
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
//    SUB EvtChanged
//    SUB Auswahl(aBereich : alpha)
//    SUB AusVerpackung()
//    SUB AusUnterlage()
//    SUB AusUmverpackung()
//    SUB AusZwischenlage()
//    SUB AusVerwiegungsart()
//    SUB AusEtikettentyp()
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

define begin
  cDialog :   $BA1.V.Verwaltung
  cTitle :    'Verpackungen'
  cFile :     704
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'BA1_V'
  cZList :    $ZL.BAG.Verpackungen
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

  $edBAG.V.VEkgMax->wpDecimals # Set.Stellen.Gewicht;
  $edBAG.V.RingKgVon->wpDecimals # Set.Stellen.Gewicht;
  $edBAG.V.RingKgBis->wpDecimals # Set.Stellen.Gewicht;
  $edBAG.V.Nettoabzug->wpDecimals # Set.Stellen.Gewicht;

  // Verpackungstitel setzen
  if(Set.Vpg1.Titel <> '') then
    $lbBAG.V.VpgText1 -> wpcaption  # Set.Vpg1.Titel;
  if(Set.Vpg2.Titel <> '') then
    $lbBAG.V.VpgText2 -> wpcaption  # Set.Vpg2.Titel;
  if(Set.Vpg3.Titel <> '') then
    $lbBAG.V.VpgText3 -> wpcaption  # Set.Vpg3.Titel;
  if(Set.Vpg4.Titel <> '') then
    $lbBAG.V.VpgText4 -> wpcaption  # Set.Vpg4.Titel;
  if(Set.Vpg5.Titel <> '') then
    $lbBAG.V.VpgText5 -> wpcaption  # Set.Vpg5.Titel;
  if(Set.Vpg6.Titel <> '') then
    $lbBAG.V.VpgText6 -> wpcaption  # Set.Vpg6.Titel;

Lib_Guicom2:Underline($edBAG.V.lfdNr);
Lib_Guicom2:Underline($edBAG.V.Verwiegungsart);
Lib_Guicom2:Underline($edBAG.V.Etikettentyp);
Lib_Guicom2:Underline($edBAG.V.Zwischenlage);
Lib_Guicom2:Underline($edBAG.V.Unterlage);
Lib_Guicom2:Underline($edBAG.Vpg.Umverpackung);
Lib_Guicom2:Underline($edBAG.Vpg.Skizzennr);

  SetStdAusFeld('edBAG.V.lfdNr'           ,'Verpackung');
  SetStdAusFeld('edBAG.V.Zwischenlage'    ,'Zwischenlage');
  SetStdAusFeld('edBAG.V.Unterlage'       ,'Unterlage');
  SetStdAusFeld('edBAG.Vpg.Umverpackung'  ,'Umverpackung');
  SetStdAusFeld('edBAG.V.Verwiegungsart'  ,'Verwiegungsart');
  SetStdAusFeld('edBAG.V.Etikettentyp'    ,'Etikettentyp');
  SetStdAusFeld('edBAG.Vpg.Skizzennr'     ,'Skizze');

  RETURN App_Main:EvtInit(aEvt);
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
  vTmp : int;
end;
begin
  if (aName='') or (aName='edBAG.V.Verwiegungsart') then begin
    Erx # RecLink(818,704,1,0);
    if (Erx<=_rLocked) then
      $lb.BA1.V.Verwiegungsart->wpcaption # VwA.Bezeichnung.L1
    else
      $lb.BA1.V.Verwiegungsart->wpcaption # '';
  end;

  if (aName='') or (aName='edBAG.V.Etikettentyp') then begin
    Erx # RecLink(840,704,2,0);
    if (Erx<=_rLocked) then
      $lb.BA1.V.Etikettentyp->wpcaption # Eti.Bezeichnung
    else
      $lb.BA1.V.Etikettentyp->wpcaption # '';
  end;

  if (aName='') or (aName='edBAG.Vpg.Skizzennr') then begin
    Erx # RecLink(829,704,4,0); // Skizze holen
    if (Erx<=_rLocked) then
     $picSkizze->wpcaption # '*' + Skz.Dateiname;
    else
     $picSkizze->wpcaption # '';
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
  RunAFX('BAG.V.RecInit','');
  
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  BAG.Vpg.Nummer # BAG.Nummer;
  // Focus setzen auf Feld:
  $edBAG.V.lfdNr->WinFocusSet(true);
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

  if (RunAFX('BAG.V.RecSave','')<>0) then begin
    if (Afxres<>_rOk) then begin
      RETURN False;
    end;
  end;


  // logische Prüfung
  if (BAG.Vpg.Verpackung=0) then begin
    Msg(001200,Translate('Verpackungsnummer'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBAG.V.lfdNr->WinFocusSet(true);
    RETURN false;
  end;
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
/*    xxx.Anlage.Datum  # Today;
    xxx.Anlage.Zeit   # Now;
    xxx.Anlage.User   # gUserName;*/
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  // AFX
  RunAFX('BAG.V.RecSavePost','');

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
sub RecDel(opt aSilent : logic)
begin
  if (!aSilent) then begin
    // Diesen Eintrag wirklich löschen?
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      RekDelete(gFile,0,'MAN');
    end;
  end else begin
     // Einfach nur löschen ohne Abfrage
     RekDelete(gFile,0,'MAN');
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
//  EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cbBAG.V.StehendYN') and (BAG.Vpg.StehendYN) then begin
    BAG.Vpg.LiegendYN # n;
    $cbBAG.V.LiegendYN->winupdate(_WinUpdFld2Obj);
  end;
  if (aEvt:Obj->wpname='cbBAG.V.LiegendYN') and (BAG.Vpg.LiegendYN) then begin
    BAG.Vpg.StehendYN # n;
    $cbBAG.V.StehendYN->winupdate(_WinUpdFld2Obj);
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
  vA    : alpha;
  vQ    : alpha(1000);
end;

begin

  case aBereich of
    'Verpackung' : begin
      RecBufClear(105);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.V.Verwaltung', here+':AusVerpackung');

      // Selektion
      VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
      vQ # 'Adr.V.Adressnr = ' + AInt(Set.eigeneAdressnr);
      if ("BAG.F.ReservFürKunde" != 0) then begin
        RecLink(100, 703, 7, _recFirst); // Kunde holen
        vQ # vQ + ' OR Adr.V.Adressnr = ' + AInt(Adr.Nummer);
      end;
      vQ # 'Adr.V.VerkaufYN AND ('+vQ+')'; // 21.07.2015
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Unterlage' : begin
      RecBufClear(838);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusUnterlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=1';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Umverpackung' : begin
      RecBufClear(838);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusUmverpackung');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=3';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zwischenlage' : begin
      RecBufClear(838);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusZwischenlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=2';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Verwiegungsart' : begin
      RecBufClear(818);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VWa.Verwaltung',here+':AusVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Etikettentyp' : begin
      RecBufClear(840);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Eti.Verwaltung',here+':AusEtikettentyp');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Skizze' : begin
      RecBufClear(829);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Skz.Verwaltung',here+':AusSkizze');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusVerpackung
//
//========================================================================
sub AusVerpackung()
begin

  if (gSelected<>0) then begin
    RecRead(105,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Vpg.AbbindungL    # Adr.V.AbbindungL;
    BAG.Vpg.AbbindungQ    # Adr.V.AbbindungQ;
    BAG.Vpg.Zwischenlage  # Adr.V.Zwischenlage;
    BAG.Vpg.Unterlage     # Adr.V.Unterlage;
    BAG.Vpg.Umverpackung  # Adr.V.Umverpackung;
    BAG.Vpg.Wicklung      # Adr.V.Wicklung;
    BAG.Vpg.StehendYN     # Adr.V.StehendYN;
    BAG.Vpg.LiegendYN     # Adr.V.LiegendYN;
    BAG.Vpg.Nettoabzug    # Adr.V.Nettoabzug;
    "BAG.Vpg.Stapelhöhe"  # "Adr.V.Stapelhöhe";
    BAG.Vpg.StapelHAbzug  # Adr.V.StapelhAbzug;
    BAG.Vpg.RingkgVon     # Adr.V.RingKgVon;
    BAG.Vpg.RingkgBis     # Adr.V.RingKgBis;
    BAG.Vpg.KgmmVon       # Adr.V.KgmmVon;
    BAG.Vpg.KgmmBis       # Adr.V.KgmmBis;
    "BAG.Vpg.StückProVE"  # "Adr.V.StückProVE";
    BAG.Vpg.VEkgMax       # Adr.V.VEkgMax;
    BAG.Vpg.RechtwinkMax  # Adr.V.RechtwinkMax;
    BAG.Vpg.EbenheitMax   # Adr.V.EbenheitMax;
    "BAG.Vpg.SäbeligMax"  # "Adr.V.SäbeligkeitMax";
    "BAG.Vpg.SäbelProM"   # "Adr.V.SäbelProM";
    BAG.Vpg.Etikettentyp  # Adr.V.Etikettentyp;
    BAG.Vpg.Verwiegart    # Adr.V.Verwiegungsart;
    BAG.Vpg.VpgText1      # Adr.V.VpgText1;
    BAG.Vpg.VpgText2      # Adr.V.VpgText2;
    BAG.Vpg.VpgText3      # Adr.V.VpgText3;
    BAG.Vpg.VpgText4      # Adr.V.VpgText4;
    BAG.Vpg.VpgText5      # Adr.V.VpgText5;
    BAG.Vpg.VpgText6      # Adr.V.VpgText6;
  end;

  gMdi->WinUpdate(_WinUpdFld2Obj);

  // Focus auf Editfeld setzen:
  $edBAG.V.lfdNr->Winfocusset(false);
end;


//========================================================================
//  AusUnterlage
//
//========================================================================
sub AusUnterlage()
begin

  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Vpg.Unterlage # ULa.Bezeichnung;
    BAG.Vpg.StapelhAbzug # "ULa.Höhenabzug";
    $edBAG.V.StapelhAbzug->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edBAG.V.Unterlage->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusUmverpackung
//
//========================================================================
sub AusUmverpackung()
begin

  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Vpg.Umverpackung # ULa.Bezeichnung;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.Vpg.Umverpackung->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusSkizze
//
//========================================================================
sub AusSkizze()
begin

  if (gSelected<>0) then begin
    RecRead(829,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Vpg.Skizzennr # Skz.Nummer;
    $picSkizze->wpcaption # '*'+Skz.Dateiname;
    $edBAG.Vpg.Skizzennr->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edBAG.Vpg.Skizzennr->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;



//========================================================================
//  AusZwischenlage
//
//========================================================================
sub AusZwischenlage()
begin

  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Vpg.Zwischenlage # ULa.Bezeichnung;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.V.Zwischenlage->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusVerwiegungsart
//
//========================================================================
sub AusVerwiegungsart()
begin

  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Vpg.Verwiegart # VWa.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.V.Verwiegungsart->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusEtikettentyp
//
//========================================================================
sub AusEtikettentyp()
begin

  if (gSelected<>0) then begin
    RecRead(840,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    BAG.Vpg.Etikettentyp # Eti.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edBAG.V.Etikettentyp->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl : int;
  vChildmode : int;
end
begin

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

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);//xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
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
    'bt.Verpackung'      : Auswahl('Verpackung');
    'bt.Zwischenlage'    : Auswahl('Zwischenlage');
    'bt.Unterlage'       : Auswahl('Unterlage');
    'bt.Umverpackung'    : Auswahl('Umverpackung');
    'bt.Verwiegungsart'  : Auswahl('Verwiegungsart');
    'bt.Etikettentyp'    : Auswahl('Etikettentyp');
    'bt.Skizze'          : Auswahl('Skizze');
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

  if ((aName =^ 'edBAG.V.lfdNr') AND (aBuf->BAG.Vpg.Verpackung<>0)) then begin
    Adr.V.lfdNr # BAG.Vpg.Verpackung;
    Lib_Guicom2:JumpToWindow('Adr.V.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.V.Verwiegungsart') AND (aBuf->BAG.Vpg.Verwiegart<>0)) then begin
    RekLink(818,704,1,0);   // Verwiegungsart holen
    Lib_Guicom2:JumpToWindow('VWa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.V.Etikettentyp') AND (aBuf->BAG.Vpg.Etikettentyp<>0)) then begin
    RekLink(840,704,2,0);   // Etikettentyp holen
    Lib_Guicom2:JumpToWindow('Eti.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.V.Zwischenlage') AND (aBuf->BAG.Vpg.Zwischenlage<>'')) then begin
   todo('Zwischenlage')
    //RekLink(819,200,1,0);   // Zwischenlage holen
    ULa.Bezeichnung # BAG.Vpg.Zwischenlage;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.V.Unterlage') AND (aBuf->BAG.Vpg.Unterlage<>'')) then begin
    ULa.Bezeichnung # BAG.Vpg.Unterlage;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBAG.Vpg.Umverpackung') AND (aBuf->BAG.Vpg.Umverpackung<>'')) then begin
    ULa.Bezeichnung # BAG.Vpg.Umverpackung;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
    if ((aName =^ 'edBAG.Vpg.Skizzennr') AND (aBuf->BAG.Vpg.Skizzennr<>0)) then begin
    RekLink(829,704,4,0);   // Skizze holen
    Lib_Guicom2:JumpToWindow('Skz.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
