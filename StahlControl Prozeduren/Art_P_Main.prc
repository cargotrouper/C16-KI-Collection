@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_P_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  01.08.2012  AI  Es darf nur einen Ø-EK geben (Projekt 1326/271)
//  08.01.2015  AH  "Selektieren" und allgemeine Preisverwaltung
//  04.04.2022  AH  ERX
//  02.06.2022  AH  Vorbelegung, wenn neu aus Bestellverwaltung
//  13.07.2022  HA  Quick Jump
//  2022-11-02  AH  "Selektieren" leitet in SFX um
//
//  Subprozeduren
//    SUB Selektieren(aMDI : int; aArtNr : alpha; aAdrNr : int);
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
//    SUB AusWaehrung()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Artikelpreise'
  cFile :     254
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Art_P'
  cZList :    $ZL.Art.Preise
  cKey      : 1
end;

//========================================================================
//  Selektieren
//
//========================================================================
sub Selektieren(
  aMDI    : int;
  aArtNr  : alpha;
  aAdrNr  : int;
  opt aKey : int);
local begin
  vHdl  : int;
  vQ    : alpha(4000);
  vProc : alpha;
end;
begin

  // 2022-11-02 AH
  vProc # Lib_Guicom:GetAlternativeMain(gMDI, 'Art_P_Main');
  if ((vProc=^'ART_P_MAIN')=false) then begin
    Call(vProc+':Selektieren', aMDI, aArtNr, aAdrNr, aKey);
    RETURN;
  end;
  
  RecBufClear(254);
  VarInstance(WindowBonus,cnvIA(aMDI->wpcustom));

  vQ # '';
  if (aArtNr<>'') then Lib_Sel:QAlpha( var vQ, '"Art.P.ArtikelNr"', '=', aArtNr);
  if (aAdrNr<>0) then Lib_Sel:QInt( var vQ, '"Art.P.Adressnr"', '=', aAdrNr);
  Lib_Sel:QRecList(0,vQ,'',aKey);
//  Lib_Sel:QRecList(0,vQ);

  // ehemals Selektion 843 ARTIKELPREISE
  if (aArtNr<>'') then begin
    $lb.aufpreise->wpvisible # true;
    $ZL.Art.APL.L->wpvisible # true;
  end;
  vHdl # Winsearch(gMDI,'ZL.Art.APL.L');
  Lib_Sel:QRecList(vHdl,'');

  vHdl # $ZL.Art.APL.L->wpdbselection;
  SelClear(vHdl);
  ApL_Data:AutoGenerieren(250, n, vHdl);
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

Lib_Guicom2:Underline($edArt.P.Preistyp);
Lib_Guicom2:Underline($edArt.P.Adressnr);
Lib_Guicom2:Underline($edArt.P.Whrung);

  SetStdAusFeld('edArt.P.Adressnr'     ,'Adresse');
  SetStdAusFeld('edArt.P.Whrung'       ,'Waehrung');
  SetStdAusFeld('edArt.P.MEH'          ,'MEH');
  SetStdAusFeld('edArt.P.Preistyp'     ,'Preistyp');

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
  vHdl  : int;
end;
begin

  if (aName='') or (aName='edArt.P.Adressnr') then begin
    Erx # RecLink(100,254,1,0);
    if (Erx<=_rLocked) then begin
      Art.P.AdrStichwort # Adr.Stichwort;
      end
    else begin
      Art.P.AdrStichwort # '';
    end;
  end;

  if (aName='') or (aName='edArt.P.Whrung') then begin
    Erx # RecLink(814,254,3,0);
    if (Erx<=_rLocked) then begin
      $Lb.WAE1->wpcaption # "Wae.Kürzel";
      $Lb.WAE2->wpcaption # "Wae.Kürzel";
      $Lb.Waehrung->wpcaption # Wae.Bezeichnung;
      end
    else begin
      $Lb.WAE1->wpcaption # '';
      $Lb.WAE2->wpcaption # '';
      $Lb.Waehrung->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edArt.P.MEH') then begin
    $Lb.MEH->wpcaption # Art.P.MEH;
    $Lb.MEH2->wpcaption # Art.P.MEH;
  end;

  $Lb.P.Stichwort->wpcaption # Art.P.AdrStichwort;
  $Lb.P.Artikelnr->wpcaption # Art.P.Artikelnr;
  $Lb.P.ArtStichwort->wpcaption # Art.P.ArtStichwort;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
  end;

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
end;
begin
  if (Mode=c_ModeNew) then begin
    Art.P.ArtikelNr     # Art.Nummer;
    Art.P.ArtStichwort  # Art.Stichwort;
    Art.P.ArtikelNr     # Art.Nummer;
    Art.P.MEH           # Art.MEH;
    Art.P.PEH           # Art.PEH;
    "Art.P.Währung"     # 1;
    if (w_Parent<>0) then begin
      if (w_Parent->wpname=*'*'+'Ein.P.Verwaltung') and (Ein.P.Lieferantennr<>0) then begin
        Erx # RecLink(100,501,4,_recFirst);   // Lieferant holen
        if (Erx<=_rLocked) then begin
          Art.P.AdressArtNr # Ein.P.LieferArtNr;
          Art.P.Adressnr    # Adr.Nummer;
          Adr.P.Stichwort   # Ein.P.LieferantenSW;
        end;
      end;
    end;
    $edArt.P.Preistyp->WinFocusSet(true);
  end
  else begin
    $edArt.P.Adressnr->WinFocusSet(true);
  end;
  // Focus setzen auf Feld:

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
  if (Art.P.PEH=0) then begin
    Msg(001200,Translate('Preiseinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.P.PEH->WinFocusSet(true);
    RETURN false;
  end;
  if ("Art.P.Währung"=0) then begin
    Msg(001200,Translate('Währung'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.P.Whrung->WinFocusSet(true);
    RETURN false;
  end;

  if (Art.P.Adressnr<>0) then begin
    Erx # RecLink(100,254,1,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Adresse'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.P.Adressnr->WinFocusSet(true);
      RETURN false;
    end;
  end;
  Erx # RecLink(814,254,3,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Währung'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.P.Whrung->WinFocusSet(true);
    RETURN false;
  end;


  // 01.08.2012 AI: Projekt 1326/271
  // es kann nur EINEN Ø-EK geben!!!
  if (Mode=c_modeNew) and (Art.P.Preistyp='Ø-EK') then begin
    Erx # RecRead(254,5,_recTest);
    if (Erx<=_rMultikey) then begin
      Msg(254001,'',0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.P.Preistyp->WinFocusSet(true);
      RETURN false;
    end;
  end;


  Wae_Umrechnen(Art.P.Preis,"Art.P.Währung",var Art.P.PreisW1, 1);
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # Art_P_Data:Replace(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
    end
  else begin
    Art.P.Anlage.Datum  # Today;
    Art.P.Anlage.Zeit   # Now;
    Art.P.Anlage.User   # gUserName;
    Art.P.Nummer # 0;
    REPEAT
      Art.P.Nummer # Art.P.Nummer + 1;
      Erx # Art_P_Data:Insert(0,'MAN');
    UNTIL (Erx=_rOK) or (Art.P.Nummer=1000);
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

  if ((aEvt:Obj->wpname='edArt.P.Basispreis') and ($edArt.P.Basispreis->wpchanged)) or
    ((aEvt:Obj->wpname='edArt.P.Rabatt') and ($edArt.P.Rabatt->wpchanged)) then begin
    Art.P.Preis # Art.P.Basispreis * ((100.0-"Art.P.RabattProz")/100.0);
    $edArt.p.Preis->winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpname='edArt.P.Preis') and ($edArt.P.Preis->wpchanged) then begin
    if (Art.P.Basispreis<>0.0) then
      "Art.P.RabattProz" # 100.0 - (Art.P.Preis / Art.P.Basispreis * 100.0);
    $edArt.p.Rabatt->winupdate(_WinUpdFld2Obj);
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

    'Preistyp' : begin
      Lib_Einheiten:Popup('PREISTYP',$edArt.P.Preistyp,254,1,7);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edArt.P.MEH,254,1,19);
      $Lb.MEH->wpcaption # Art.P.MEH;
      $Lb.MEH2->wpcaption # Art.P.MEH;
    end;


    'Adresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Waehrung' : begin
      RecBufClear(814);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung',here+':AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
local begin
  vHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Art.P.Adressnr # Adr.Nummer;
    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.P.Adressnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArt.P.Adressnr');
end;


//========================================================================
//  AusWaehrung
//
//========================================================================
sub AusWaehrung()
local begin
  vHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    // Feldübernahme
    "Art.P.Währung" # Wae.Nummer;
    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.P.Whrung->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArt.P.Whrung');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_P_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_P_Anlegen]=n) or
        ($lb.aufpreise->wpvisible=false);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeList)) or
      (Rechte[Rgt_Art_P_Aendern]=n) or
      (((Art.P.Preistyp='PRD' or Art.P.Preistyp='Ø-EK' or (Art.P.Preistyp='L-EK')) and (Rechte[Rgt_Art_P_Auto_edit]=n)) );
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeList)) or
      (Rechte[Rgt_Art_P_Aendern]=n) or
      (((Art.P.Preistyp='PRD' or Art.P.Preistyp='Ø-EK' or (Art.P.Preistyp='L-EK')) and (Rechte[Rgt_Art_P_Auto_edit]=n)) );

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeList)) or
      (Rechte[Rgt_Art_P_Loeschen]=n) or
      (Art.P.Preistyp='PRD' or Art.P.Preistyp='Ø-EK' or (Art.P.Preistyp='L-EK'));
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeList)) or
      (Rechte[Rgt_Art_P_Loeschen]=n) or
      (Art.P.Preistyp='PRD' or Art.P.Preistyp='Ø-EK' or (Art.P.Preistyp='L-EK'));

    //vHdl->wpDisabled # Rechte[Rgt_Art_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Art_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Art_Excel_Import]=false;
  
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

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Art.P.Anlage.Datum, Art.P.Anlage.Zeit, Art.P.Anlage.User );
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
    'bt.Waehrung'   :   Auswahl('Waehrung');
    'bt.Adresse'    :   Auswahl('Adresse');
    'bt.Preistyp'   :   Auswahl('Preistyp');
    'bt.MEH'        :   Auswahl('MEH');
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
  RecLink(814,254,3,_recFirsT);     // Währung holen
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
  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin

  // ggf. Selektion in den Aufpreisen auch löschen
  if ($lb.aufpreise->wpvisible) then
    if (w_SelName<>'') then begin     // temp. Selektionen entfernen
      SelDelete(843,w_selName);
    end;

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
  vRect     : rect;
  vMitAP    : logic;
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  vMitAP # $lb.aufpreise->wpvisible;

  if (aFlags & _WinPosSized != 0) then begin
    vRect           # gZLList->wpArea;

    vRect:right     # aRect:right-aRect:left-4;
    if (vMitAP) then
      vRect:bottom    # aRect:bottom-aRect:Top-28-120
    else
      vRect:bottom    # aRect:bottom-aRect:Top-28;

    gZLList->wparea # vRect;

    if (vMitAP) then begin
      Lib_GUiCom:ObjSetPos($lb.aufpreise, 0, vRect:bottom+8);
      Lib_GUiCom:ObjSetPos($ZL.Art.APL.L, 0, vRect:bottom+8+28);
      vRect           # $ZL.Art.APL.L->wpArea;
      vRect:right     # aRect:right-aRect:left-4;
      $ZL.Art.APL.L->wparea # vRect;
    end;
  end;
	RETURN (true);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edArt.P.Preistyp') AND (aBuf->Art.P.Preistyp<>'')) then begin
    todo('Preistyp')
   // RekLink(819,200,1,0);   // Priestyp holen
    Lib_Guicom2:JumpToWindow('');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.P.Adressnr') AND (aBuf->Art.P.Adressnr<>0)) then begin
    RekLink(100,254,1,0);   // Adresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.P.Whrung') AND (aBuf->"Art.P.Währung"<>0)) then begin
    RekLink(814,254,3,0);   // Währung holen
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;
 

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================