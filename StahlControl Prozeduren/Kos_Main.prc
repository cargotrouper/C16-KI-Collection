@A+
//==== Business-Control ==================================================
//
//  Prozedur    Kos_Main
//                    OHNE E_R_G
//  Info
//
//
//  11.03.2016  AH  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//  25.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB Start(opt aRecId  : int; opt aView   : logic) : logic;
//    SUB EvtInit(
//    SUB Pflichtfelder();
//    SUB RefreshIfm(opt aName : alpha; opt aChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(
//    SUB EvtFocusTerm(
//    SUB Auswahl(aBereich : alpha)
//    SUB AusAdresse()
//    SUB AusGegenkonto()
//    SUB AusKostenstelle()
//    SUB AusSteuerschl()
//    SUB RefreshMode(opt aNoRefresh : logic);
//    SUB EvtMenuCommand(
//    SUB EvtClicked(
//    SUB EvtPageSelect(
//    SUB EvtLstDataInit(
//    SUB EvtLstSelect(
//    SUB EvtClose(
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cDialog     : 'Kos.Verwaltung'
  cTitle      : 'Kostenbuchung'
  cRecht      : Rgt_Kostenbuchung
  cFile       :  581
  cMenuName   : 'Kos.Bearbeiten'
  cPrefix     : 'Kos'
  cZList      : $ZL.Kostenbuchung
  cKey        : 2
  cListen     : 'Kostenbuchung'
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
  winsearchpath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen  # cListen;

Lib_Guicom2:Underline($edKos.Adressnr);
Lib_Guicom2:Underline($edKos.Gegenkonto);
Lib_Guicom2:Underline($edKos.Kostenstelle);
Lib_Guicom2:Underline($edKos.Steuerschl);

  // Auswahlfelder setzen...
  SetStdAusFeld('edKos.Adressnr'        ,'Adresse');
  SetStdAusFeld('edKos.Gegenkonto'      ,'Gegenkonto');
  SetStdAusFeld('edKos.Kostenstelle'    ,'Kostenstelle');
  SetStdAusFeld('edKos.Steuerschl'      ,'Steuerschl');

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
  Lib_GuiCom:Pflichtfeld($edKos.Belegdatum);
  Lib_GuiCom:Pflichtfeld($edKos.WerstellungsDat);
  Lib_GuiCom:Pflichtfeld($edKos.Adressnr);
  Lib_GuiCom:Pflichtfeld($edKos.Gegenkonto);
  Lib_GuiCom:Pflichtfeld($edKos.Steuerschl);
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
  vHdl  : int;
end;
begin

  if (aName='') or (aName='edKos.Adressnr') then begin
    Erx # RekLink(100,581,2,0);
    $Lb.Adresse->wpcaption # Adr.Stichwort;
  end;
  if (aName='') or (aName='edKos.Gegenkonto') then begin
    Erx # RekLink(854,581,3,0);
    $Lb.Gegenkonto->wpcaption # GKo.Bezeichnung;
  end;
  if (aName='') or (aName='edKos.Kostenstelle') then begin
    Erx # RekLink(846,581,4,0);
    $Lb.Kostenstelle->wpcaption # Kst.Bezeichnung;
  end;
  if (aName='') or (aName='edKos.Steuerschl') then begin
    Erx # RekLink(813,581,5,0);
    $Lb.Steuerschl->wpcaption # Sts.Bezeichnung;
  end;


  if (Mode=c_ModeView) then begin
    if (Kos.NettoW1<0.0) then begin
      $edKos.NettoW1N->wpcaptionfloat   # - Kos.NettoW1;
      $edKos.SteuerW1N->wpcaptionfloat  # - Kos.SteuerW1;
      $edKos.BruttoW1N->wpcaptionfloat  # - Kos.BruttoW1;
      $edKos.NettoW1->wpcaptionfloat    # 0.0;
      $edKos.SteuerW1->wpcaptionfloat   # 0.0;
      $edKos.BruttoW1->wpcaptionfloat   # 0.0;
    end
    else begin
      $edKos.NettoW1->wpcaptionfloat    # Kos.NettoW1;
      $edKos.SteuerW1->wpcaptionfloat   # Kos.SteuerW1;
      $edKos.BruttoW1->wpcaptionfloat   # Kos.BruttoW1;
      $edKos.NettoW1N->wpcaptionfloat   # 0.0;
      $edKos.SteuerW1N->wpcaptionfloat  # 0.0;
      $edKos.BruttoW1N->wpcaptionfloat  # 0.0;
    end;
  end;

  if (Mode=c_ModeNew) or (Mode=c_modeEdit) then begin
    Lib_GuiCom:Able($edKos.NettoW1N,  $edKos.NettoW1->wpcaptionfloat=0.0 and $edKos.SteuerW1->wpcaptionfloat=0.0 and $edKos.BruttoW1->wpcaptionfloat=0.0);
    Lib_GuiCom:Able($edKos.SteuerW1N, $edKos.NettoW1->wpcaptionfloat=0.0 and $edKos.SteuerW1->wpcaptionfloat=0.0 and $edKos.BruttoW1->wpcaptionfloat=0.0);
    Lib_GuiCom:Able($edKos.BruttoW1N, $edKos.NettoW1->wpcaptionfloat=0.0 and $edKos.SteuerW1->wpcaptionfloat=0.0 and $edKos.BruttoW1->wpcaptionfloat=0.0);

    Lib_GuiCom:Able($edKos.NettoW1,  $edKos.NettoW1N->wpcaptionfloat=0.0 and $edKos.SteuerW1N->wpcaptionfloat=0.0 and $edKos.BruttoW1N->wpcaptionfloat=0.0);
    Lib_GuiCom:Able($edKos.SteuerW1, $edKos.NettoW1N->wpcaptionfloat=0.0 and $edKos.SteuerW1N->wpcaptionfloat=0.0 and $edKos.BruttoW1N->wpcaptionfloat=0.0);
    Lib_GuiCom:Able($edKos.BruttoW1, $edKos.NettoW1N->wpcaptionfloat=0.0 and $edKos.SteuerW1N->wpcaptionfloat=0.0 and $edKos.BruttoW1N->wpcaptionfloat=0.0);

  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
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
  Erx : int;
  vNr : int;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  if (Mode=c_ModeNew) then begin
    Erx # RecLink(581,580,1,_recLast);    // letze Buchung holen
    if (Erx>_rLocked) then vNr # 1
    else vNr # Rek.Nummer + 1;
    RecBufClear(581);
    Kos.KopfNummer  # Kos.K.Nummer;
    Kos.Nummer      # vNr;
    $edKos.NettoW1->wpcaptionfloat    # 0.0;
    $edKos.SteuerW1->wpcaptionfloat   # 0.0;
    $edKos.BruttoW1->wpcaptionfloat   # 0.0;
    $edKos.NettoW1N->wpcaptionfloat   # 0.0;
    $edKos.SteuerW1N->wpcaptionfloat  # 0.0;
    $edKos.BruttoW1N->wpcaptionfloat  # 0.0;
  end
  else begin
    if (Kos.NettoW1<0.0) or (Kos.SteuerW1<0.0) or (Kos.BruttoW1<0.0) then begin
      $edKos.NettoW1N->wpcaptionfloat   # - Kos.NettoW1;
      $edKos.SteuerW1N->wpcaptionfloat  # - Kos.SteuerW1;
      $edKos.BruttoW1N->wpcaptionfloat  # - Kos.BruttoW1;
    end
    else begin
      $edKos.NettoW1->wpcaptionfloat    # Kos.NettoW1;
      $edKos.SteuerW1->wpcaptionfloat   # Kos.SteuerW1;
      $edKos.BruttoW1->wpcaptionfloat   # Kos.BruttoW1;
    end;
  end;

  // Focus setzen auf Feld:
  $edKos.Belegdatum->WinFocusSet(true);
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
  If (Kos.Adressnr=0) then begin
    Lib_Guicom2:InhaltFehlt('Adresse', 'NB.Page1', 'edKos.Adressnr');
    RETURN false;
  end;
  Erx # RecLink(100,581,2,0);     // Adresse holen
  if (Erx>_rLocked) then begin
    Lib_Guicom2:InhaltFalsch('Adresse', 'NB.Page1', 'edKos.Adressnr');
    RETURN false;
  end;

  If (Kos.Gegenkonto=0) then begin
    Lib_Guicom2:InhaltFehlt('Gegenkonto', 'NB.Page1', 'edKos.Gegenkonto');
    RETURN false;
  end;
  Erx # RecLink(854,581,3,0);     // Gegenkonto holen
  if (Erx>_rLocked) then begin
    Lib_Guicom2:InhaltFalsch('Gegenkonto', 'NB.Page1', 'edKos.Gegenkonto');
    RETURN false;
  end;

  if (Kos.Kostenstelle<>0) then begin
    Erx # RekLink(846,581,4,0);   // Kostenstelle holen
    if (Erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Kostenstelle', 'NB.Page1', 'edKos.Kostenstelle');
      RETURN false;
    end;
  end;

  If (Kos.steuerschl=0) then begin
    Lib_Guicom2:InhaltFehlt('Steuerschlüssel', 'NB.Page1', 'edKos.Steuerschl');
    RETURN false;
  end;
  Erx # RekLink(813,581,5,0);     // Steuerschlüssel holen
  if (Erx>_rLocked) then begin
    Lib_Guicom2:InhaltFalsch('Steuerschlüssel', 'NB.Page1', 'edKos.Steuerschl');
    RETURN false;
  end;

  if ((Kos.K.Von.Datum<>0.0.0) and (Kos.WertstellungsDat<Kos.K.Von.Datum)) or
    ((Kos.K.Bis.Datum<>0.0.0) and (Kos.WertstellungsDat>Kos.K.Bis.Datum)) then begin
    Msg(580003,'',0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edKos.Werstellungsdat->Winfocusset(true);
    RETURN false;
  end;

  if ($edKos.NettoW1->wpcaptionfloat<>0.0) or ($edKos.SteuerW1->wpcaptionfloat<>0.0) or ($edKos.BruttoW1->wpcaptionfloat<>0.0) then begin
    Kos.NettoW1   # $edKos.NettoW1->wpcaptionfloat;
    Kos.SteuerW1  # $edKos.SteuerW1->wpcaptionfloat;
    Kos.BruttoW1  # $edKos.BruttoW1->wpcaptionfloat;
  end
  else begin
    Kos.NettoW1   # - $edKos.NettoW1N->wpcaptionfloat;
    Kos.SteuerW1  # - $edKos.SteuerW1N->wpcaptionfloat;
    Kos.BruttoW1  # - $edKos.BruttoW1N->wpcaptionfloat;
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
    Kos.Anlage.Datum  # Today;
    Kos.Anlage.Zeit   # Now;
    Kos.Anlage.User   # gUserName;
    REPEAT
      Erx # RekInsert(gFile,0,'MAN');
      if (Erx<>_rOK) then begin
        inc(Kos.Nummer);
        CYCLE;
      end;
    UNTIl (Erx=_rOK);
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
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    if (RekDelete(gFile,0,'MAN')=_rOK) then begin
      if (gZLList->wpDbSelection<>0) then begin
        SelRecDelete(gZLList->wpDbSelection,gFile);
        RecRead(gFile, gZLList->wpDbSelection, 0);
      end;
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
local begin
  Erx : int;
end;
begin

  if (Kos.Steuerschl<>0) then
    Erx # RekLink(813,581,5,0)  // Steuerschlüssel holen
  else
    RecBufClear(813);

  if (aEvt:Obj->wpchanged) then begin
    if (aEvt:obj->wpname='edKos.Belegdatum') and (Kos.Wertstellungsdat=0.0.0) then
      Kos.Wertstellungsdat # aEvt:Obj->wpcaptiondate;

    if (aEvt:obj->wpname='edKos.NettoW1') and ($edKos.SteuerW1->wpCaptionfloat=0.0) then
      $edKos.SteuerW1->wpCaptionfloat # Rnd($edKos.NettoW1->wpCaptionfloat * Sts.Prozent / 100.0, 2);

    if (aEvt:obj->wpname='edKos.NettoW1') and ($edKos.BruttoW1->wpCaptionfloat=0.0) then
      $edKos.BruttoW1->wpCaptionfloat # $edKos.NettoW1->wpCaptionfloat + $edKos.SteuerW1->wpCaptionfloat;

    if (aEvt:obj->wpname='edKos.BruttoW1') and ($edKos.NettoW1->wpCaptionfloat=0.0) then
      $edKos.NettoW1->wpCaptionfloat # Rnd($edKos.BruttoW1->wpCaptionfloat / (1.0 + (Sts.Prozent / 100.0)), 2);

    if (aEvt:obj->wpname='edKos.BruttoW1') and ($edKos.SteuerW1->wpCaptionfloat=0.0) then
      $edKos.SteuerW1->wpCaptionfloat # $edKos.BruttoW1->wpCaptionfloat - $edKos.NettoW1->wpCaptionfloat;


    if (aEvt:obj->wpname='edKos.NettoW1N') and ($edKos.SteuerW1N->wpCaptionfloat=0.0) then
      $edKos.SteuerW1N->wpCaptionfloat # Rnd($edKos.NettoW1N->wpCaptionfloat * Sts.Prozent / 100.0, 2);

    if (aEvt:obj->wpname='edKos.NettoW1N') and ($edKos.BruttoW1N->wpCaptionfloat=0.0) then
      $edKos.BruttoW1N->wpCaptionfloat # $edKos.NettoW1N->wpCaptionfloat + $edKos.SteuerW1N->wpCaptionfloat;

    if (aEvt:obj->wpname='edKos.BruttoW1N') and ($edKos.NettoW1N->wpCaptionfloat=0.0) then
      $edKos.NettoW1N->wpCaptionfloat # Rnd($edKos.BruttoW1N->wpCaptionfloat / (1.0 + (Sts.Prozent / 100.0)), 2);

    if (aEvt:obj->wpname='edKos.BruttoW1N') and ($edKos.SteuerW1N->wpCaptionfloat=0.0) then
      $edKos.SteuerW1N->wpCaptionfloat # $edKos.BruttoW1N->wpCaptionfloat - $edKos.NettoW1N->wpCaptionfloat;
  end;

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

    'Adresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
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

  end;  // ...case

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
begin

  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    Kos.Adressnr # Adr.Nummer;
  end;
  $edKos.Adressnr->Winfocusset(false);
end;


//========================================================================
//  AusGegenkonto
//
//========================================================================
sub AusGegenkonto()
local begin
  Erx : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(854,0,_RecId,gSelected);
    gSelected # 0;
    Kos.Gegenkonto        # Gko.Nummer;
    if ("GKo.Steuerschlüssel"<>0) and (Kos.Adressnr<>0) then begin
      Erx # RecLink(100,581,2,0);     // Adresse holen
      if (Erx<=_rLocked) then
        Kos.Steuerschl    # ("Gko.Steuerschlüssel" * 100 ) + "Adr.Steuerschlüssel";
    end;
    $edKos.Steuerschl->Winupdate(_WinUpdFld2Obj);
  end;
  $edKos.Gegenkonto->Winfocusset(false);
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
    Kos.Steuerschl # Sts.Nummer;
  end;
  $edKos.Steuerschl->Winfocusset(false);
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
    Kos.Kostenstelle # Kst.Nummer;
  end;
  $edKos.Kostenstelle->Winfocusset(false);
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
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kos_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kos_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kos_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kos_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kos_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Kos_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Kos_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Kos_Excel_Import]=false;

  vHdl # gMenu->WinSearch('Mnu.Mark.SetField');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Kos_SerienEdit]=false;

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
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Copy' : begin
      Kos_Subs:CopyMark();
    end;


    'Mnu.Mark.SetField' : begin
      Lib_Mark:SetField(gFile);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Kos.Anlage.Datum, Kos.Anlage.Zeit, Kos.Anlage.User);
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
    'bt.Adresse'      :   Auswahl('Adresse');
    'bt.Gegenkonto'   :   Auswahl('Gegenkonto');
    'bt.Kostenstelle' :   Auswahl('Kostenstelle');
    'bt.Steuerschl'   :   Auswahl('Steuerschl');
  end;  // ...case

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


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edKos.Adressnr') AND (aBuf->Kos.Adressnr<>0)) then begin
    RekLink(100,581,2,0);   // Adresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edKos.Gegenkonto') AND (aBuf->Kos.Gegenkonto<>0)) then begin
    RekLink(854,581,3,0);   // Gegenkonto holen
    Lib_Guicom2:JumpToWindow('GKo.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edKos.Kostenstelle') AND (aBuf->Kos.Kostenstelle<>0)) then begin
    RekLink(846,581,4,0);   // Kostenstelle holen
    Lib_Guicom2:JumpToWindow('Kst.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edKos.Steuerschl') AND (aBuf->Kos.Steuerschl<>0)) then begin
    RekLink(813,581,5,0);   // Steuerschlüssel holen
    Lib_Guicom2:JumpToWindow('Sts.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
