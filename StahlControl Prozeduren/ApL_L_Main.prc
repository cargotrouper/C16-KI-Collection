@A+
//==== Business-Control ==================================================
//
//  Prozedur    ApL_L_Main
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  13.12.2012  AI  Formelfunktion
//  06.06.2013  AI  EditLst-Funktion deaktiviert (woher kam das??)
//  05.02.2015  AH  Neu: VpgArtikel
//  11.07.2019  AH  Neu: Lieferadresse
//  09.04.2021  AH  Neu: Artikelgruppe2
//  04.04.2022  AH  ERX
//  13.07.2022  HA  Quick Jump
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
//    SUB AusAdresse()
//    SUB AusArtikel()
//    SUB AusVpgArtikel()
//    SUB AusErzeuger()
//    SUB AusGuete()
//    SUB AusOberflaeche()
//    SUB AusArtikelgruppe()
//    SUB AusArtikelgruppe2()
//    SUB AusZeugnis()
//    SUB AusWarengruppe()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked
//    SUB EvtChanged
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHitTest : int; aItem : int; aID : int) : logic
//    SUB EvtLstEditStart(aEvt : event; aColumn : int; aEdit : int; aList : int) : logic
//    SUB EvtLstEditCommit(aEvt : event; aColumn : int; aKey : int; aFocusObject : int) : logic
//    SUB EvtLstEditFinished(aEvt : event; aColumn : int; aKey : int; aRecId : int; aChanged : logic) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Aufpreisliste'
  cFile :     843
  cMenuName : 'ApL.L.Bearbeiten'
  cPrefix :   'ApL_L'
  cZList :    $ZL.APL.L
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

  Lib_Guicom2:Underline($edApL.L.Warengruppe);
  Lib_Guicom2:Underline($edApL.L.Adresse);
  Lib_Guicom2:Underline($edApL.L.Erzeuger);
  Lib_Guicom2:Underline($edApl.L.Lieferadr);
  Lib_Guicom2:Underline($edApl.L.Lieferanschr);
  Lib_Guicom2:Underline($edApL.L.Artikelnummer);
  Lib_Guicom2:Underline($edApL.L.Artikelgruppe);
  Lib_Guicom2:Underline($edApL.L.Artikelgruppe2);
  Lib_Guicom2:Underline($edApL.L.Vpg.Artikelnr);
  Lib_Guicom2:Underline($edApL.L.Guete);
  Lib_Guicom2:Underline($edApL.L.ObfNr);
  Lib_Guicom2:Underline($edApL.L.Zeugnis);
  

  SetStdAusFeld('edApL.L.MEH'           ,'MEH');
  SetStdAusFeld('edApL.L.Menge.MEH'     ,'MEH2');
  SetStdAusFeld('edApL.L.Adresse'       ,'Adresse');
  SetStdAusFeld('edApl.L.Lieferadr'     ,'Lieferadresse');
  SetStdAusFeld('edApl.L.Lieferanschr'  ,'Lieferanschrift');
  SetStdAusFeld('edApL.L.Erzeuger'      ,'Erzeuger');
  SetStdAusFeld('edApL.L.Zeugnis'       ,'Zeugnis');
  SetStdAusFeld('edApL.L.Artikelnummer' ,'Artikel');
  SetStdAusFeld('edApL.L.Vpg.Artikelnr' ,'VpgArtikel');
  SetStdAusFeld('edApL.L.Artikelgruppe' ,'ArtGrp');
  SetStdAusFeld('edApL.L.Artikelgruppe2' ,'ArtGrp2');
  SetStdAusFeld('edApL.L.Guete'         ,'Guete');
  SetStdAusFeld('edApL.L.ObfNr'         ,'Oberflaeche');
  SetStdAusFeld('edApL.L.Warengruppe'   ,'Warengruppe');

  RETURN  App_Main:EvtInit(aEvt);
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

  if (Mode=c_modeNew) or (Mode=c_ModeEdit) then begin
    if (ApL.L.PerFormelYN) then begin
      Lib_GuiCom:Enable($edApL.L.FormelFunktion);
      end
    else begin
      Lib_GuiCom:Disable($edApL.L.FormelFunktion);
    end;
  end;

  if (aName='edApL.L.Guete') then
    MQU_Data:Autokorrektur(var "ApL.L.Güte");

  if (aName='') or (aName='edApL.L.Adresse') then begin
    Erx # RecLink(100,843,2,0);
    if (Erx<=_rLocked) then
      ApL.L.AdressSW  # Adr.Stichwort
    else
      ApL.L.AdressSW # '';
  end;
  $Lb.Adresse->wpcaption #  ApL.L.AdressSW;

  if (aName='') or (aName='edApl.L.Lieferadr') or (aName='edApl.L.Lieferanschr') then begin
    Erx # RecLink(101,843,9,_RecFirst);
    if (Erx<=_rLocked) and (Apl.L.Lieferadr<>0) then begin
      $Lb.Lieferadresse1->wpcaption # Adr.A.Stichwort+', '+Adr.A.LKZ+', '+Adr.A.Ort;
      $Lb.Lieferadresse2->wpcaption # Adr.A.Name+', '+"Adr.A.Straße";
    end
    else begin
      $Lb.Lieferadresse1->wpcaption # '';
      $Lb.Lieferadresse2->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edApL.L.Erzeuger') then begin
    Erx # RecLink(100,843,3,0);
    if (Erx<=_rLocked) then
      $Lb.Erzeuger->wpcaption # Adr.Stichwort
    else
      $Lb.Erzeuger->wpcaption # '';
  end;

  if (aName='') or (aName='edApL.L.ObfNr') then begin
    Erx # RecLink(841,843,1,0);
    if (Erx<=_rLocked) then
      $Lb.Oberflaeche->wpcaption # Obf.Bezeichnung.L1
    else
      $Lb.Oberflaeche->wpcaption # '';
  end;

  if (aName='') or (aName='edApL.L.Artikelgruppe') then begin
    Erx # RecLink(826,843,4,0);
    if (Erx<=_rLocked) then
      $Lb.Artikelgruppe->wpcaption # AGr.Bezeichnung.L1
    else
      $Lb.Artikelgruppe->wpcaption # '';
  end;
  if (aName='') or (aName='edApL.L.Artikelgruppe2') then begin
    Erx # RecLink(826,843,10,0);
    if (Erx<=_rLocked) then
      $Lb.Artikelgruppe2->wpcaption # AGr.Bezeichnung.L1
    else
      $Lb.Artikelgruppe2->wpcaption # '';
  end;

  if (aName='') or (aName='edApL.L.Warengruppe') then begin
    Erx # RecLink(819,843,6,0);
    if (Erx<=_rLocked) then
      $lb.Wgr->wpcaption # Wgr.Bezeichnung.L1
    else
      $lb.Wgr->wpcaption # '';
  end;

  if (aName='') then begin
    $lb.Kopfbezeichnung2->wpcaption # ApL.Bezeichnung;
    $Lb.HW->wpCaption # "Set.Hauswährung.Kurz";
    $lbApL.L.Bezeichnung.L1->wpcaption # Set.Sprache1;
    $lbApL.L.Bezeichnung.L2->wpcaption # Set.Sprache2;
    $lbApL.L.Bezeichnung.L3->wpcaption # Set.Sprache3;
    $lbApL.L.Bezeichnung.L4->wpcaption # Set.Sprache4;
    $lbApL.L.Bezeichnung.L5->wpcaption # Set.Sprache5;
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
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  // Felder Disablen durch:
  Lib_GuiCom:Disable($edApL.L.Key1);
  Lib_GuiCom:Disable($edApL.L.Key2);
  Lib_GuiCom:Disable($edApL.L.Key3);
  // Focus setzen auf Feld:
  $edApL.L.Key4->WinFocusSet(true);

  if (Mode=c_ModeNew) then begin
    ApL.L.Key1 # ApL.Key1;
    ApL.L.Key2 # ApL.Key2;
    ApL.L.Key3 # ApL.Key3;
    ApL.L.Aufpreisgruppe # ApL.Aufpreisgruppe;
    ApL.L.Adresse # ApL.Adressnummer;
    ApL.L.Erzeuger # ApL.Erzeugernummer;
    ApL.L.Menge.MEH # 'kg';
    ApL.L.MEH # 'kg';
    ApL.L.PEH # 1000;
    if (ApL.L.Aufpreisgruppe<>0) then Lib_GuiCom:Disable($edApL.L.Aufpreisgruppe);
    if (ApL.L.Adresse<>0) then Lib_GuiCom:Disable($edApL.L.Adresse);
    if (ApL.L.Erzeuger<>0) then Lib_GuiCom:Disable($edApL.L.Erzeuger);
  end;

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
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(gFile,0,'MAN');
    if (gZLList->wpDbSelection<>0) then begin
      SelRecDelete(gZLList->wpDbSelection,gFile);
      RecRead(gFile, gZLList->wpDbSelection, 0);
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
  Erx   : int;
  vA    : alpha;
  vQ    : alpha(4096);
  vSel  : int;
end;
begin

  case aBereich of

    'VpgArtikel' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusVpgArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikel' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('AufpreisEH',$edApL.L.MEH,843,1,11);
    end;


    'MEH2' : begin
      Lib_Einheiten:Popup('AufpreisEH',$edApL.L.Menge.MEH,843,2,11);
    end;


    'Adresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow( gMDI,'Adr.Verwaltung', here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferadresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow( gMDI,'Adr.Verwaltung', here+':AusLieferAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferanschrift' : begin
      RecLink(100,843,8,0);     // Lieferadresse holen
      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLieferanschrift');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
      vSel # SelCreate(101, 1);
      Erx # vSel->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vSel);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vSel, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vSel;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guete' : begin
      RecBufClear(832);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Oberflaeche' : begin
      RecBufClear(841);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusOberflaeche');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ArtGrp' : begin
      RecBufClear(826);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'AGr.Verwaltung',here+':AusArtikelgruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'ArtGrp2' : begin
      RecBufClear(826);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'AGr.Verwaltung',here+':AusArtikelgruppe2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Erzeuger' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusErzeuger');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zeugnis' : begin
      RecBufClear(839);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Zeu.Verwaltung',here+':AusZeugnis');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Warengruppe' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end; // Case
end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.L.Adresse   # Adr.Nummer;
    ApL.L.AdressSW  # Adr.Stichwort;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.Adresse->Winfocusset(false);
end;


//========================================================================
//  AusLieferadresse
//
//========================================================================
sub AusLieferadresse()
local begin
  Erx   : int;
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Apl.L.Lieferadr     # Adr.Nummer;
    Apl.L.Lieferanschr  # 1;

    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl <> 0) then
      vHdl->Winupdate(_WinUpdFld2Obj);
  end;

  // Focus setzen:
  $edApl.L.Lieferadr->Winfocusset(false);
  RefreshIfm('edApl.L.Lieferadr');

  if (Auf.Lieferanschrift = 1) then begin
    Erx # RecLinkInfo(101,100,12,_recCount); // Mehr als eine Anschrift vorhanden?
    if (Erx > 1) then begin
      Auswahl('Lieferanschrift');
    end
    else begin
      Erx # RecLink(101,100,12,_recFirst); // Wenn nur 1, diese holen
      if(Erx > _rLocked) then
        RecBufClear(101);
      APl.L.Lieferanschr # Adr.A.Nummer;
    end;
  end;
  $edApl.L.Lieferanschr->Winupdate(_WinUpdFld2Obj);

end;


//========================================================================
//  AusLieferanschrift
//
//========================================================================
sub AusLieferanschrift()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    APl.L.Lieferanschr # Adr.A.Nummer;
    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus setzen:
  $edAPl.L.Lieferanschr->Winfocusset(false);
  RefreshIfm('edApl.L.Lieferanschrift');
end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.L.Artikelnummer # Art.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.Artikelnummer->Winfocusset(false);
end;


//========================================================================
//  AusVpgArtikel
//
//========================================================================
sub AusVpgArtikel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.L.Vpg.Artikelnr # Art.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.Vpg.Artikelnr->Winfocusset(false);
end;


//========================================================================
//  AusErzeuger
//
//========================================================================
sub AusErzeuger()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.L.Erzeuger # Adr.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.Erzeuger->Winfocusset(false);
end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "Apl.L.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "Apl.L.Güte" # "MQu.Güte1"
    else
      "Apl.L.Güte" # "MQu.Güte2";
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.Guete->Winfocusset(false);
end;


//========================================================================
//  AusOberflaeche
//
//========================================================================
sub AusOberflaeche()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(841,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.L.ObfNr # Obf.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
    gMDI->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.ObfNr->Winfocusset(false);
end;


//========================================================================
//  AusArtikelgruppe
//
//========================================================================
sub AusArtikelgruppe()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(826,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.L.Artikelgruppe # AGr.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.Artikelgruppe->Winfocusset(false);
end;


//========================================================================
//  AusArtikelgruppe2
//
//========================================================================
sub AusArtikelgruppe2()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(826,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.L.Artikelgruppe2 # AGr.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.Artikelgruppe2->Winfocusset(false);
end;


//========================================================================
//  AusZeugnis
//
//========================================================================
sub AusZeugnis()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(839,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.L.Zeugnis # Zeu.Bezeichnung;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.Zeugnis->Winfocusset(false);
end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.L.Warengruppe # Wgr.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.L.Warengruppe->Winfocusset(false);
end;



//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : int;
end
begin
  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_APZ_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_APZ_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_APZ_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_APZ_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_APZ_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_APZ_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


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
  vAnz    : int;
  vX      : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Copy' : begin
      if (RecRead(843,1,0)<>_rOK) then RETURN false;
      if (Dlg_Standard:Anzahl('Anzahl',var vAnz)=False) then RETURN false;
      vX # ApL.L.Key4+1;
      WHILE (vAnz>0) do begin
        REPEAT
          ApL.L.Key4 # vX;
          Erx # RekInsert(843,0,'MAN');
          Inc(vX);
        UNTIL (Erx=_rOK);
        Dec(vAnz);
      END;

      App_Main:Refresh();
      //gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
    end;


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
    'bt.Guete'          :   Auswahl('Guete');
    'bt.Oberflaeche'    :   Auswahl('Oberflaeche');
    'bt.Adresse'        :   Auswahl('Adresse');
    'bt.Adresse'        :   Auswahl('Adresse');
    'bt.Lieferadresse'  :   Auswahl('Lieferadresse');
    'bt.Lieferanschrift'  : Auswahl('Lieferanschrift');
    'bt.Zeugnis'        :   Auswahl('Zeugnis');
    'bt.Artikel'        :   Auswahl('Artikel');
    'bt.VpgArtikel'     :   Auswahl('VpgArtikel');
    'bt.ArtGrp'         :   Auswahl('ArtGrp');
    'bt.ArtGrp2'        :   Auswahl('ArtGrp2');
    'bt.Erzeuger'       :   Auswahl('Erzeuger');
    'bt.MEH'            :   Auswahl('MEH');
    'bt.MEH2'           :   Auswahl('MEH2');
    'bt.Wgr'            :   Auswahl('Warengruppe');
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

  if (Mode=c_ModeView) then RETURN true;

  if (aEvt:Obj->wpname='cbApL.L.MengenbezugYN') then begin
    if (ApL.L.MengenBezugYN) then begin
      ApL.L.PerFormelYN     # n;
      ApL.L.FormelFunktion  # '';
      $edApL.L.FormelFunktion->winupdate(_WinUpdFld2Obj);
      $cbApL.L.PerFormelYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edApL.L.FormelFunktion);
    end;
  end;

  if (aEvt:Obj->wpname='cbApL.L.PerFormelYN') then begin
    if (ApL.L.PerFormelYN) then begin
      ApL.L.MengenbezugYN # n;
      $cbApL.L.MengenbezugYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Enable($edApL.L.FormelFunktion);
      end
    else begin
      ApL.L.FormelFunktion # '';
      $edApL.L.FormelFunktion->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edApL.L.FormelFunktion);
    end;
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
// EvtMouseItem
//          Mausclick in RecList
//========================================================================
sub EvtMouseItem(
  aEvt      : event; // Ereignis
  aButton   : int;   // Maustaste
  aHitTest  : int;   // Hittest-Code
  aItem     : int;   // Spalte oder Gantt-Interval
  aID       : int;   // RecID nur bei RecList
) : logic
begin
/* 06.06.2013
  if (aButton & _winmouseright > 0 ) and
     (aHitTest = _WinHitLstView) then
     if (aItem->wpname='clmApL.L.Bezeichnung.L1') or
      (aItem->wpname='clmApL.L.Menge') then begin
    WinLstEdit(aEvt:Obj,aItem);
  end;
*/
  RETURN(true);
end;


//========================================================================
// EvtLstEditStart
//          direktes Listeneditieren Start
//========================================================================
sub EvtLstEditStart(
  aEvt         : event; // Ereignis
  aColumn      : int;   // Spalte
  aEdit        : int;   // Eingabefeld
  aList        : int;   // Datalist
) : logic
local begin
  Erx : int;
end;
begin

// 06.06.2013
RETURN false;

  if (aEvt:Obj->wpDbLinkFileNo<>0) then
    Erx # RecRead(aEvt:Obj->wpDbLinkFileNo,0,_RecID | _RecLock,aEvt:Obj->wpDbRecId)
  else
    Erx # RecRead(aEvt:Obj->wpDbFileNo,0,_RecID | _RecLock,aEvt:Obj->wpDbRecId);
  RETURN(true);
end;


//========================================================================
// EvtLstEditCommit
//          direktes Listeneditieren Commit
//========================================================================
sub EvtLstEditCommit(
  aEvt         : event; // Ereignis
  aColumn      : int;   // Spalte
  aKey         : int;   // Taste
  aFocusObject : int;
) : logic
begin
  if (aKey=_winKeyReturn) then begin
    RETURN true;
  end;
  RETURN(aKey != _WinKeyEsc);
end;


//========================================================================
// EvtLstEditFinished
//          direktes Listeneditieren Finish
//========================================================================
sub EvtLstEditFinished(
  aEvt         : event; // Ereignis
  aColumn      : int;   // Spalte
  aKey         : int;   // Taste
  aRecId       : int;   // Datensatz-ID
  aChanged     : logic; // true, wenn eine Änderung vorgenommen wurde
) : logic
local begin
  Erx     : int;
  vDatei  : int;
end;
begin

  if (aEvt:Obj->wpDbLinkFileNo<>0) then
    vDatei # aEvt:Obj->wpDbLinkFileNo
  else
    vDatei # aEvt:Obj->wpDbFileNo;

  // Datensatz nicht speichern und entsperren
  if (aKey=_WinKeyEsc) then begin
    Erx # RecRead(vDatei,0,_RecId | _RecUnlock,aRecId);
  end;

  // Datensatz zurueckspeichern
  if (aKey=_WinKeyReturn) then begin
    Erx # RekReplace(vDatei,_RecUnlock,'MAN');
  end;

  // Liste aktualisieren
  aEvt:Obj->WinUpdate(_WinUpdOn,
    _WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);

  RETURN(true);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vQ    :  alpha(1000);
end
begin

  if ((aName =^ 'edApL.L.Warengruppe') AND (aBuf->ApL.L.Warengruppe<>0)) then begin
    RekLink(819,843,6,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edApL.L.Adresse') AND (aBuf->ApL.L.Adresse<>0)) then begin
    RekLink(100,843,2,0);   // Adresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;

  if ((aName =^ 'edApL.L.Erzeuger') AND (aBuf->ApL.L.Erzeuger<>0)) then begin
    RekLink(100,843,3,0);   // Erzeuger holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edApl.L.Lieferadr') AND (aBuf->Apl.L.Lieferadr<>0)) then begin
    RekLink(100,843,8,0);   // Lieferadresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edApl.L.Lieferanschr') AND (aBuf->Apl.L.Lieferanschr<>0)) then begin
    RecLink(101,843,9,0);   // Anschrift holen
    Adr.A.Adressnr # Apl.L.Lieferadr;
    Adr.A.Nummer # Apl.L.Lieferanschr;
    RecRead(101,1,0);
    
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Apl.L.Lieferadr);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;
  
  if ((aName =^ 'edApL.L.Artikelnummer') AND (aBuf->ApL.L.Artikelnummer<>'')) then begin
    RekLink(250,843,7,0);   // Artikel Nr. holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edApL.L.Artikelgruppe') AND (aBuf->ApL.L.Artikelgruppe<>0)) then begin
    RekLink(826,843,4,0);   // ArtikelGruppe holen
    Lib_Guicom2:JumpToWindow('AGr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edApL.L.Artikelgruppe2') AND (aBuf->ApL.L.Artikelgruppe2<>0)) then begin
    RekLink(826,843,10,0);   // bis Artikelgrp. holen
    Lib_Guicom2:JumpToWindow('AGr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edApL.L.Vpg.Artikelnr') AND (aBuf->ApL.L.Vpg.Artikelnr<>'')) then begin
    RekLink(250,843,7,1);   // Verpack.Artikel holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;

  if ((aName =^ 'edApL.L.Guete') AND (aBuf->"ApL.L.Güte"<>'')) then begin
    "MQu.Güte1" # "ApL.L.Güte";
    RecRead(832,2,0)
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edApL.L.ObfNr') AND (aBuf->ApL.L.ObfNr<>0)) then begin
    RekLink(841,843,1,0);   // Oberfläche holen
    Lib_Guicom2:JumpToWindow('Obf.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edApL.L.Zeugnis') AND (aBuf->ApL.L.Zeugnis<>'')) then begin
    Zeu.Bezeichnung # ApL.L.Zeugnis;
    RecRead(839,2,0)
    Lib_Guicom2:JumpToWindow('Zeu.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================