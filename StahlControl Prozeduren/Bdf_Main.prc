@A+
//==== Business-Control ==================================================
//
//  Prozedur    Bdf_Main
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  26.06.2012  AI  Generalüberholung
//  27.06.2012  MS  EvtLstDataInit Artikel mit Basischarge lesen
//  28.06.2012  TM  Serienmarkierung eingefügt
//  29.06.2012  TM  Preisübernahme bei Lieferantenauswahl (incl. Staffelung)
//  05.04.2022  AH  ERX
//  21.07.2022  HA  Quick jump
//  2022-11-15  AH  "Start"
//
//  Subprozeduren
//    sub Start
//    sub EvtInit(aEvt  : event): logic
//    sub Pflichtfelder()
//    sub RefreshIfm (opt aName : alpha; opt achanged : logic);
//    sub RecInit()
//    sub RecSave() : logic
//    sub RecCleanup() : logic
//    sub RecDel()
//    sub EvtFocusInit (aEvt : event; aFocusObject : int) : logic
//    sub EvtFocusTerm (aEvt : event; aFocusObject : int) : logic
//    sub Auswahl(aBereich : alpha)
//    sub AusArtikelnummer()
//    sub AusLieferant()
//    sub AusArtikelStichwort()
//    sub AusWaehrung()
//    sub RefreshMode(opt aNoRefresh:logic )
//    sub EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    sub EvtClicked (aEvt : event;) : logic
//    sub EvtLstDataInit(aEvt : Event; aRecId : int;);
//    sub EvtLstSelect(aEvt : event; aRecID : int;) : logic
//    sub EvtClose(aEvt : event;): logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Materialbedarf'
  cFile :     540
  cMenuName : 'Bdf.Bearbeiten'
  cPrefix :   'Bdf'
  cZList :    $ZL.Bedarf
  cKey :      1
  cDialog     : 'Bdf.Verwaltung'
  cRecht      : Rgt_Bedarf
  cMdiVar     : gMDIBdf
end;


/*========================================================================
2022-11-15  AH
========================================================================*/
sub Start(
  opt aRecId    : int;
  opt aBdfNr    : int;
  opt aView     : logic;
  opt aSel      : int;
  opt aSelName  : alpha) : logic;
local begin
  Erx : int;
end;
begin
  if (aRecId=0) and (aBdfNr<>0) then begin
    Bdf.Nummer # aBdfNr;
    Erx # RecRead(540,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(540,_recID);
  end;

  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView, n, aSel, aSelName);
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edBdf.Artikelnummer);
Lib_Guicom2:Underline($edBdf.ArtikelStichwort);
Lib_Guicom2:Underline($edBdf.Lieferant.Wunsch);
Lib_Guicom2:Underline($edBdf.Waehrung);

  SetStdAusFeld('edBdf.Artikelnummer'     ,'Artikelnummer');
  SetStdAusFeld('edBdf.ArtikelStichwort'  ,'Artikelstichwort');
  SetStdAusFeld('edBdf.Lieferant.Wunsch'  ,'Lieferant');
  SetStdAusFeld('edBdf.Waehrung'          ,'Waehrung');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  if (Bdf.MEH<>'Stk') then
    Lib_GuiCom:Pflichtfeld($edBdf.Menge);

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edBdf.Artikelnummer);
  Lib_GuiCom:Pflichtfeld($edBdf.Artikelstichwort);
  if (Bdf.MEH='Stk') then
    Lib_GuiCom:Pflichtfeld($edBdf.Stckzahl);
  Lib_GuiCom:Pflichtfeld($edBdf.Menge);
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
  Erx         : int;
  vArtChanged : logic;
  vTmp        : int;
end;
begin

  if ((Mode=c_modeNew) or (Mode=c_ModeEdit)) and (aName='') then
    if (Bdf.MEH='Stk') then Lib_GuicOm:Disable($edBdf.Menge)
    else Lib_GuicOm:Enable($edBdf.Menge);


  if ((Mode=c_Modeedit) or (mode=c_Modenew)) and
    (aName='edBdf.Stckzahl') and
    (Bdf.MEH='Stk') then begin
    Bdf.Menge # cnvfi("Bdf.Stückzahl");
    $edBdf.Menge->wpcaptionfloat # Bdf.Menge;
//    $edBdf.Menge->winupdate(_winupdon, _WinUpdFld2Obj);
  end;

  if (aName='edBdf.Artikelnummer') and
    (($edBdf.Artikelnummer->wpchanged) or (aChanged)) then begin
    Bdf.ArtikelStichwort # '';
    Bdf.MEH # '';
    Art.Nummer # Bdf.Artikelnr;
    Erx # RecRead(250,1,0);
    If (Erx<=_rLocked) then begin
      Bdf.MEH               # Art.MEH;
      Bdf.Artikelnr         # Art.Nummer ;
      Bdf.ArtikelStichwort  # Art.Stichwort;
      Bdf.Warengruppe       # Art.Warengruppe;
      Erx # Reklink(819,540,6,_recFirst);   // Warengruppe holen
      Bdf.Wgr.Dateinr       # Wgr.Dateinummer;
      if ("Art.ChargenführungYN") then Bdf.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Bdf.Wgr.Dateinr);
    end;
    if (Bdf.MEH='Stk') then Lib_GuicOm:Disable($edBdf.Menge)
    else Lib_GuicOm:Enable($edBdf.Menge);
    $lb.MEH->wpcaption    # Bdf.MEH;
    $lb.MEH2->wpcaption    # Bdf.MEH;
    Winupdate($edBdf.Artikelstichwort,_WinUpdFld2Obj);
    vArtChanged # y;
  end;

  if (aName='edBdf.ArtikelStichwort') and ($edBdf.ArtikelStichwort->wpchanged) then begin
    Bdf.Artikelnr # '';
    Bdf.MEH       # '';
    Art.Stichwort # Bdf.ArtikelStichwort;
    Erx # RecRead(250,6,0);
    If (Erx<=_rLocked) then begin
      Bdf.MEH               # Art.MEH;
      Bdf.Artikelnr         # Art.Nummer ;
      Bdf.ArtikelStichwort  # Art.Stichwort;
      Bdf.Warengruppe       # Art.Warengruppe;
      Erx # Reklink(819,540,6,_recFirst);   // Warengruppe holen
      Bdf.Wgr.Dateinr       # Wgr.Dateinummer;
      if ("Art.ChargenführungYN") then Bdf.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Bdf.Wgr.Dateinr);
    end;
    if (Bdf.MEH='Stk') then Lib_GuicOm:Disable($edBdf.Menge)
    else Lib_GuicOm:Enable($edBdf.Menge);
    $lb.MEH->wpcaption    # Bdf.MEH;
    $lb.MEH2->wpcaption    # Bdf.MEH;
    Winupdate($edBdf.Artikelnummer,_WinUpdFld2Obj);
    vArtChanged # y;
  end;


  if (aName='') or (vArtChanged) then begin
    Erx # RecLink(250,540,7,_RecFirst); // Artikel holen
    if (Erx<=_rLocked) then begin
      $lb.Bez1->wpcaption # Art.Bezeichnung1;
      $lb.Bez2->wpcaption # Art.Bezeichnung2;
      $lb.Bez3->wpcaption # Art.Bezeichnung3;

      RecBufClear(252);
      Art.C.ArtikelNr # Art.Nummer;
      Art_Data:ReadCharge();
      $lb.Art.MEH1->wpcaption # Art.MEH;
      $lb.Art.MEH2->wpcaption # Art.MEH;
      $lb.Art.MEH3->wpcaption # Art.MEH;
      $lb.Art.MEH4->wpcaption # Art.MEH;
      $lb.Art.MEH5->wpcaption # Art.MEH;
      $lb.Art.MEH6->wpcaption # Art.MEH;
      $lb.Art.MEH7->wpcaption # Art.MEH;
      $lb.MEH->wpcaption      # Bdf.MEH;
      $lb.MEH2->wpcaption      # Bdf.MEH;
      if (Bdf.Nummer<>0) then
        $lb.Nummer->wpcaption   # AInt(Bdf.Nummer)
      else
        $lb.Nummer->wpcaption # '';

      $Lb.Bestand->wpcaption    # anum(Art.C.Bestand, Set.Stellen.Menge);
      $Lb.Reserviert->wpcaption # anum(Art.C.Reserviert, Set.Stellen.Menge);
      $Lb.Verfuegbar->wpcaption # anum("Art.C.Verfügbar", Set.Stellen.Menge);
      $Lb.AufRest->wpcaption    # anum(Art.C.OffeneAuf, Set.Stellen.Menge);
      $Lb.Bestellt->wpcaption   # anum(Art.C.Bestellt, Set.Stellen.Menge);
      $Lb.Min->wpcaption        # anum(Art.Bestand.Min, Set.Stellen.Menge);
      $Lb.Soll->wpcaption       # anum(Art.Bestand.Soll, Set.Stellen.Menge);

      end
    else begin
      $lb.Bez1->wpcaption # '';
      $lb.Bez2->wpcaption # '';
      $lb.Bez3->wpcaption # '';
    end;


    $lb.Traeger->wpcaption  # Bdf_Data:Traegerstring();


    if (Bdf.Einkaufsnummer=0) then
      $lb.Bestellung->wpcaption # ''
    else
      $lb.Bestellung->wpcaption # AInt(Bdf.Einkaufsnummer)+'/'+AInt(Bdf.Einkaufsposition);
  end;

  if (aName='') or (aName='edBdf.Lieferant.Wunsch') then begin
    Erx # RecLink(100,540,3,_RecFirst); // Lieferant holen
    if (Erx<=_rLocked) and (Bdf.Lieferant.Wunsch<>0) then
      Bdf.LieferSW.Wunsch # Adr.Stichwort
    else
      Bdf.LieferSW.Wunsch # '';
    $lb.Lieferant->winupdate(_WinUpdFld2Obj);
  end;

  if (aName='') or (aName='edBdf.Waehrung') then begin
    Erx # RecLink(814,540,8,_RecFirst); // Währungt holen
    if (Erx>_rLocked) or ("Bdf.Währung"=0) then RecBufClear(814);
    $lb.Waehrung->wpCaption # Wae.Bezeichnung;
    $lb.WAE->wpCaption # "Wae.Kürzel";
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
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
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  if (Mode=c_ModeNew) then
    $edBdf.Artikelnummer->WinFocusSet(true)
  else
    $edBdf.Lieferant.Wunsch->WinFocusSet(true);
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
  if (Bdf.Lieferant.Wunsch<>0) then begin
    Erx # RecLink(100,540,3,_RecFirst); // Lieferant holen
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Lieferant'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edBdf.Lieferant.Wunsch->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (Bdf.ArtikelNr='') then begin
    Msg(001200,Translate('Artikel'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBdf.Artikelnummer->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(250,540,7,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Artikel'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBdf.ARtikelnummer->WinFocusSet(true);
    RETURN false;
  end;

  if (Bdf.MEH='Stk') then begin
    if ("Bdf.Stückzahl"=0) then begin
      Msg(001200,Translate('Stückzahl'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edBdf.Stckzahl->WinFocusSet(true);
      RETURN false;
    end;
  end;
  if ("Bdf.Menge"=0.0) then begin
    Msg(001200,Translate('Menge'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edBdf.Menge->WinFocusSet(true);
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
    Bdf.Nummer # Lib_Nummern:ReadNummer('Bedarf');
    if (Bdf.Nummer<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;

    Bdf.Anlage.Datum  # Today;
    Bdf.Anlage.Zeit   # Now;
    Bdf.Anlage.User   # gUserName;
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
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin
  RekDelete(gFile,0,'MAN');
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

    'Waehrung' : begin
      RecBufClear(814);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung',here+':AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferant' : begin
      RekLink(250,540,7,_RecFirst);   // Artikel holen
      RecBufClear(254);
      RecLink(254,250,6,_RecFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.P.Verwaltung',here+':AusLieferant');
      Art_P_Main:Selektieren(gMDI, Art.Nummer, 0);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikelnummer','Artikelstichwort','Sachnummer' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      case aBereich of
        'Artikelnummer'     : begin
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikelnummer');
          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
          gZLList->wpdbkeyNo # 1;
          end;
        'Artikelstichwort'  : begin
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikelstichwort');
          gZLList->wpdbkeyNo # 6;
          end;
        'Sachnummer'        : begin
          gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusSachnummer');
          gZLList->wpdbkeyNo # 3;
          end;
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusArtikelnummer
//
//========================================================================
sub AusArtikelnummer()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Bdf.Artikelnr         # Art.Nummer ;
    Bdf.ArtikelStichwort  # Art.Stichwort;
    //Bdf.Sachnummer  # Art.Sachnummer;
    Bdf.MEH               # Art.MEH;
  end;
  // Focus auf Editfeld setzen:
  $edBdf.Artikelnummer->Winfocusset(false);
  // ggf. Labels refreshen
  Refreshifm('edBdf.Artikelnummer',y);
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
local begin
  Erx : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(254,0,_RecId,gSelected);
    gSelected # 0;
    Erx # RecLink(100,254,1,_RecFirst);     // Adresse holen
    if (Erx<=_rLocked) then begin
      // Feldübernahme
      Bdf.Lieferant.Wunsch  # Adr.LieferantenNr;
      Bdf.LieferSW.Wunsch   # Adr.Stichwort;

      // Start ---- 29.06.2012  TM
      Erx # RecLink(254,250,6,_recFirst);
      WHILE (Erx <= _rLocked) DO BEGIN
        if (Art.P.Adressnr = Adr.Nummer) then begin

          if (Bdf.Menge >= Art.P.abMenge) then
            BREAK;

        end;
        Erx # RecLink(254,250,6,_recNext);
      END;

      if (Erx > _rLocked) then RecBufClear(254);
    end;

    Bdf.Preis # Art.P.Preis;
    Bdf.PEH # Art.P.PEH;
    Bdf.MEH # Art.P.MEH;
    "Bdf.Währung" # "Art.P.Währung";
    Refreshifm('edBdf.Waehrung',y);
    // Ende ---- 29.06.2012  TM

  end;
  // Focus auf Editfeld setzen:
  $edBdf.Lieferant.Wunsch->Winfocusset(false);
  // ggf. Labels refreshen
  //  RefreshIfm('edBdf.Lieferant.Wunsch');
  Refreshifm('edBdf.Artikelnummer',y);

  // Start ---- 29.06.2012  TM
  Refreshifm('edBdf.Preis',y);
  Refreshifm('edBdf.PEH',y);
  Refreshifm('edBdf.MEH',y);
  // Ende ---- 29.06.2012  TM

end;


//========================================================================
//  AusArtikelstichwort
//
//========================================================================
sub AusArtikelstichwort()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Bdf.Artikelnr         # Art.Nummer ;
    Bdf.ArtikelStichwort  # Art.Stichwort;
    //Bdf.Sachnummer  # Art.Sachnummer;
    Bdf.MEH               # Art.MEH;
  end;
  // Focus auf Editfeld setzen:
  $edBdf.ArtikelStichwort->Winfocusset(false);
  // ggf. Labels refreshen
  Refreshifm('edBdf.Artikelnummer',y);
end;


//========================================================================
//  AusWaehrung
//
//========================================================================
sub AusWaehrung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "Bdf.Währung" # Wae.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edBdf.Waehrung->WinFocusset(true);
  // ggf. Labels refreshen
  RefreshIfm('edBdf.Waehrung');
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
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Bdf_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Bdf_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Bdf_Aendern]=n) or (Bdf.Einkaufsnummer<>0);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Bdf_Aendern]=n) or (Bdf.Einkaufsnummer<>0);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) or (Rechte[Rgt_Bdf_Loeschen]=n); // or (Bdf.Einkaufsnummer<>0);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) or (Rechte[Rgt_Bdf_Loeschen]=n); // or (Bdf.Einkaufsnummer<>0);

  if (Mode<>c_ModeOther) and (aNoRefresh=false) then RefreshIfm();

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

  case (aMenuItem->wpName) of

    'Mnu.Restore' : begin
      if (Rechte[Rgt_Abl_Bdf_Restore]) then begin
        Bdf_Abl_Data:RestoreAusAblage();
        RecRead(540,1,0);
        RefreshList(gZLList, _WinLstRecFromRecID | _WinLstRecDoSelect);
      end;
    end;

    
    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edBdf.Stckzahl') then begin
        "Bdf.Stückzahl" # cnvif(Lib_Einheiten:WandleMEH(540, 0, Bdf.Gewicht, Bdf.Menge, Bdf.MEH, 'Stk'));
        $edBdf.Stckzahl->winupdate(_WinUpdFld2Obj);
      end;
    end;


    'Mnu.Aktionen' : begin
      RecBufClear(541);
//      RecLink(254,250,6,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Bdf.A.Verwaltung','');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Druck.Anfrage' : begin
      Bdf_Data:Anfragen();
    end;


    'Mnu.Bestellungen.Rahmen' : begin
      RecRead(540,0,0,gZLList->wpdbrecid);
      RekLink(250,540,7,_RecFirst);   // Artikel holen
      Art_Main:Cmd_Bestellungen('Rahmen');
    end;


    'Mnu.Art.Preise' : begin
      RecRead(540,0,0,gZLList->wpdbrecid);
      RekLink(250,540,7,_RecFirst);   // Artikel holen
      RecBufClear(254);
      RecLink(254,250,6,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.P.Verwaltung','');
      Art_P_Main:Selektieren(gMDI, Art.Nummer, 0);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Dispo' : begin
      RecRead(540,0,0,gZLList->wpdbrecid);
      RecLink(250,540,7,_Recfirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Dispo.Verwaltung','',y,n);
      Art_Disposition2:Show('Dispoliste','250_401_-RES_409_501_701',y,n, gMDI);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Bestellung' : begin
      Bdf_Data:Bestellen();
    end;


    // NEU: Serienmarkierung 2012-28-06 TM
    'Mnu.Mark.Sel' : begin
      Bdf_Mark_Sel();  // Aufruf Selektionsdialog und -durchführung
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Bdf.Anlage.Datum, Bdf.Anlage.Zeit, Bdf.Anlage.User );
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
    'bt.Artikelnr' :   Auswahl('Artikelnummer');
    'bt.ArtikelSW' :   Auswahl('Artikelstichwort');
    'bt.Lieferant' :   Auswahl('Lieferant');
    'bt.Waehrung'  :   Auswahl('Waehrung');
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
local begin
  Erx : int;
end;
begin
  // Artikel holen
  RecLink(250,540,7,_RecFirst);
  Gv.Datum.01 # Bdf.Datum.Von;

  if (Art.Bestelltage<>0) and (Gv.Datum.01>1.1.1911) then
    Gv.Datum.01->vmDayModify(Art.Bestelltage * (-1) );

  Gv.Alpha.01 # Bdf_Data:Traegerstring();

  RecBufClear(252);
  Erx # RecLink(250, 540, 7, _recFirst); // Artikel holen
  if (Erx <= _rLocked) then begin
    Art.C.ArtikelNr # Art.Nummer;
    Art_Data:ReadCharge();
  end;

  if (aMark=n) then begin
    if ("Bdf.Löschmarker"='*') then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
    else
      Lib_GuiCom:ZLColorLine(gZLList,_Wincolwhite);
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
begin
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);
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


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edBdf.Artikelnummer') AND (aBuf->Bdf.ARtikelnr<>'')) then begin
    RekLink(250,540,7,0);   // Artikelnummer holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBdf.ArtikelStichwort') AND (aBuf->Bdf.ArtikelStichwort<>'')) then begin
    Art.Stichwort # Bdf.ArtikelStichwort;
    RecRead(250,6,0)
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBdf.Lieferant.Wunsch') AND (aBuf->Bdf.Lieferant.Wunsch<>0)) then begin
    RekLink(100,540,3,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Art.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edBdf.Waehrung') AND (aBuf->"Bdf.Währung"<>0)) then begin
    RekLink(814,540,8,0);   // Währung holen
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================
