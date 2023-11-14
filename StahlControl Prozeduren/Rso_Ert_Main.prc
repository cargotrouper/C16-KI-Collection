@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Ert_Main
//                  OHNE E_R_G
//  Info
//
//
//  12.08.2003  ST  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
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
//    SUB AusArtikel()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecid : int);
//    SUB EvtClose(aEvt : event) : logic
//    SUB Pflichtfelder();
//
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Ersatzteile'
  cFile :     168
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Rso_ErT'
  cZList :    $ZL.Rso.Ersatzteile
  cKey :      1
end;

declare Pflichtfelder();

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

//  cZList->wpdisabled # false;

//  App_Main:Refreshmode();

Lib_Guicom2:Underline($edRso.ErT.Artikelnr);

  SetStdAusFeld('edRso.ErT.Artikelnr' , 'ARTIKEL');

  // Labels
  $Lb.Ressource       -> wpcaption  # AInt(Rso.Nummer);
  $Lb.Ressourcenname  -> wpcaption  # Rso.Bezeichnung1;
  $Lb.Ressource2      -> wpcaption  # AInt(Rso.Nummer);
  $Lb.Ressourcenname2 -> wpcaption  # Rso.Bezeichnung1;
  $Lb.Nummer          -> wpcaption  # AInt(Rso.IHA.Nummer);
  $Lb.Wartung         -> wpcaption  # AInt(Rso.IHA.Wartung);
  $Lb.Nummer2         -> wpcaption  # AInt(Rso.IHA.Nummer);
  $Lb.Wartung2        -> wpcaption  # AInt(Rso.IHA.Wartung);
  $Lb.Ursnummer     -> wpcaption    # AInt(Rso.Urs.Nummer);
  $Lb.Ursnummer2    -> wpcaption    # AInt(Rso.Urs.Nummer);
  $Lb.Masnummer     -> wpcaption    # AInt("Rso.Maß.Maßnahme");
  $Lb.Masnummer2     -> wpcaption   # AInt("Rso.Maß.Maßnahme");

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

  $edRso.ErT.Datum  -> wpCaptionDate # Rso.ErT.Datum;
  $edRso.ErT.Zeit   -> wpCaptionTime # Rso.ErT.Zeit;

  if (aName='edRso.ErT.Artikelnr') and ($edRso.ErT.Artikelnr->wpchanged) then begin
    Erx # RecLink(180,168,1,0);
    if (Erx<=_rLocked) then begin
      Rso.ErT.MEH # HuB.MEH;
    end
    else begin
      Rso.ErT.MEH # '';
    end;
  end;

  if (aName='') or (aName='Lb.Artikelstichwort') then begin
    HuB.Artikelnr # Rso.ErT.Artikelnr

    Erx # RecRead(180,1,0);
    if (Erx<=_rLocked) then begin
      $Lb.Artikelstichwort   -> wpCaption # Hub.Stichwort;
    end
    else begin
      $Lb.Artikelstichwort   -> wpCaption # '';
    end;
  end;

  if (aName='') or (aName='LB.Ressourcenname') or (aName='LB.Ressourcenname2') then begin
    Rso.Gruppe    # Rso.Urs.Gruppe;
    Rso.Nummer    # Rso.Urs.Ressource;
    RecRead(160,1,0);  // Lies Ressourcenbeschreibung

    Erx # RecRead(824,1,0);
    if (Erx<=_rLocked) then begin
      $Lb.Ressourcenname  -> wpcaption # Rso.Bezeichnung1;
      $Lb.Ressourcenname2 -> wpcaption # Rso.Bezeichnung1;
    end
    else begin
      $Lb.Ressourcenname  -> wpcaption # '';
      $Lb.Ressourcenname2 -> wpcaption # '';
    end;
  end;

  $Lb.MEH                -> wpCaption # Rso.ErT.MEH;

// veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

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
  vNr : int;
end;
begin
  If (Mode=c_ModeNew) then begin
    /*RecLink(168,167,1,_RecLast);
    vNr # Rso.ErT.Nummer + 1;
    RecBufClear(168);*/

    vNr # Lib_Nummern:ReadNummer('Ersatzteile');
    if (vNr <> 0) then Lib_Nummern:SaveNummer();
    else Debug('Reservierung fehlgeschlagen');

    Rso.ErT.Nummer  # vNr;

    Rso.ErT.Datum     #   Rso.IHA.Termin; // Zeit: von IHA
    Rso.ErT.User      #   Usr.Username;
  end;

  "Rso.ErT.Gruppe"    # "Rso.Maß.Gruppe";
  "Rso.ErT.Ressource" # "Rso.Maß.Ressource";
  "Rso.ErT.WartungYN" # "Rso.Maß.WartungYN";
  "Rso.ErT.IHA"       # "Rso.Maß.IHA";
  "Rso.ErT.Ursache"   # "Rso.Maß.Ursache";
  "Rso.ErT.Maßnahme"  # "Rso.Maß.Nummer";

  //Rso.ErT.Datum     #   SysDate();    // Zeit: Jetzt
  //Rso.ErT.Zeit      #   Now;

  RefreshIfm();

  $edRso.ErT.Artikelnr->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If (Rso.ErT.Artikelnr='') then begin
    Msg(001200,Translate('Artikelnummer'),0,0,0);
    vTmp # gMdi->winsearch('edRso.ErT.ArtikelNr');
    if (vTmp<>0) then
     vTmp->winFocusSet();
    RETURN false;
  end;

  if (Rso.ErT.Artikelnr<>'') then begin
    Erx # RecLink(180,168,1,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Artikelnummer'),0,0,0);
      vTmp # gMdi->winsearch('edRso.ErT.ArtikelNr');
      if (vTmp<>0) then
       vTmp->winFocusSet();
      RETURN false;
    end;
  end;

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  RecLink(180,168,1,_RecFirst);   // Artikel lesen
  RecLink(181,180,1,_RecFirst);   // Preis lesen

  if ($lb.hidden->wpcustom = 'IHA') then begin  // Ersatzteile nach IHA aus Wrt (keine Verbuchung)
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
    RETURN true;
  end
  else begin                                             // 'normales' Speichern und Verbuchen der Ersatzteile
    if (HuB.PEH<>0) then
      Rso.ErT.Gesamtpreis # Rso.ErT.Menge * HuB.durchschEKPreis / CnvFI(HuB.PEH)
    else
      Rso.ErT.Gesamtpreis # Rso.ErT.Menge * HuB.durchschEKPreis;

    if (Mode=c_ModeEdit) then begin
      Erx # RekReplace(gFile,_recUnlock,'MAN');
      if (Erx<>_rOk) then begin
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN False;
      end;
      PtD_Main:Compare(gFile);
    end
    else begin
      If HuB_Data:MengenBewegung(Rso.ErT.Artikelnr,(-1.0)*Rso.ErT.Menge,'IHA:'+AInt(Rso.ErT.IHA)+'/'+AInt(Rso.ErT.Ursache)+'/'+AInt("Rso.ErT.Maßnahme")+'/'+AInt(Rso.ErT.Nummer)+' zugeteilt') then begin
        Erx # RekInsert(gFile,0,'MAN');
        if (Erx<>_rOk) then begin
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN False;
        end;
      end
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


  if ($lb.hidden->wpcustom = 'IHA') then begin  // Ersatzteile nach IHA aus Wrt (keine Verbuchung)
    RekDelete(gFile,0,'MAN');
  end
  else begin
    If HuB_Data:MengenBewegung(Rso.ErT.Artikelnr,Rso.ErT.Menge,'IHA:'+AInt(Rso.ErT.IHA)+'/'+AInt(Rso.ErT.Ursache)+'/'+AInt("Rso.ErT.Maßnahme")+'/'+AInt(Rso.ErT.Nummer)+' Zuteilung gelöscht') then
      RekDelete(gFile,0,'MAN');

    Erx # RecRead(168,1,1); // Für Zugriffsliste
    if (Erx > _rLocked) then
      RecBufClear(168);
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
  if (aEvt:Obj->wpname='edRso.ErT.Artikelnr') then
    RefreshIfm('Lb.Artikelstichwort');

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
    'ARTIKEL' : begin
      RecBufClear(180);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'HUB.Verwaltung',here+':AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

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
    RecRead(180,0,_RecId,gSelected);
    // Feldübernahme
    Rso.ErT.Artikelnr # HuB.Artikelnr;
    Rso.ErT.MEH       # HuB.MEH;
    gSelected # 0;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;

  RefreshIfm('Lb.Artikelstichwort');
  // Focus auf Editfeld setzen:
   $edRso.ErT.Artikelnr->Winfocusset(true);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Anlegen]=n);


  if ($lb.hidden->wpcustom = 'IHA') then begin  // Ersatzteile nach IHA aus Wrt (keine Verbuchung)
    vHdl # gMdi->WinSearch('Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false; //(vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Aendern]=n);
    vHdl # gMenu->WinSearch('Mnu.Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false; //(vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Aendern]=n);
    vHdl # gMdi->WinSearch('Delete');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false; //(vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Loeschen]=n);
        vHdl # gMenu->WinSearch('Mnu.Delete');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false; //(vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Loeschen]=n);
  end
  else begin
      vHdl # gMdi->WinSearch('Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # true; //(vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Aendern]=n);
    vHdl # gMenu->WinSearch('Mnu.Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # true;//(vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Aendern]=n);
    vHdl # gMdi->WinSearch('Delete');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Loeschen]=n);
    vHdl # gMenu->WinSearch('Mnu.Delete');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_ErT_Loeschen]=n);
  end;

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
    'bt.Artikel' :   Auswahl('ARTIKEL');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
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
  App_Main:Refreshmode();
end;

//========================================================================
//  EvtLstSelect
//
//========================================================================
sub EvtLstSelect(
                        aEvt      : event;
                        aRecid    : int;
                   );
begin
  RecRead(168,1,0);
  App_Main:Refreshmode();    // Aktivieren/Deaktivieren von Datansatzabhängigen Menüpunkten
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
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edRso.ErT.Artikelnr);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edRso.ErT.Artikelnr') AND (aBuf->Rso.ErT.Artikelnr<>'')) then begin
    RekLink(180,168,1,0);   // Artikelnummer holen
    Lib_Guicom2:JumpToWindow('HUB.Verwaltung');
    RETURN;
  end;
 
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================