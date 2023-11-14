@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_SL_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2005  AI  Erstellung der Prozedur
//  04.04.2022  AH  ERX
//  14.07.2022  HA  Qucik Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusArtikel()
//    SUB AusArbeitsgang()
//    SUB AusRessource()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtDropEnter(	aEvt : event;	aDataObject : int;aEffect : int) : logic
//    SUB EvtDrop(aEvt : event;	aDataObject : int;aDataPlace : int; aEffect : int;aMouseBtn : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Stückliste'
  cFile :     256
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Art_SL'
  cZList :    $ZL.Art.Stueckliste
  cKey :      1
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edArt.SL.Input.ArtNr);
Lib_Guicom2:Underline($edArt.SL.Input.ArGAkt);
Lib_Guicom2:Underline($edArt.SL.Input.ResNr);


  SetStdAusFeld('edArt.SL.Input.ArtNr'   ,'Artikel');
  SetStdAusFeld('edArt.SL.Input.ArGAkt'  ,'Arbeitsgang');
  SetStdAusFeld('edArt.SL.Input.ResGrp'  ,'Ressource');
  SetStdAusFeld('edArt.SL.Input.ResNr'   ,'Ressource');
  SetStdAusFeld('edArt.SL.Kosten.MEH'    ,'MEH');

  App_Main:EvtInit(aEvt);

  vHdl # gMDI->winsearch('lb.Artikelnr');
  vHdl->wpcaption # Art.SLK.Artikelnr;
  vHdl # gMDI->winsearch('lb.SLNummer');
  vHdl->wpcaption # AInt(Art.SLK.Nummer);

  vHdl # gMDI->winsearch('lb.PROEINZEL');
  vHdl->wpcaption # Translate('pro')+' 1 '+Art.MEH;

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
  vHdl    : int;
end;
begin

  // Artikelnummer sichern
  Gv.Alpha.10 # Art.Nummer;

  if (w_Child=0) then begin

    // Datei spezifische Vorgaben
    gTitle  # Translate(cTitle);
    gFile   # cFile;
    gFrmMain->wpMenuname # cMenuName;    // Menü setzen
    gPrefix # cPrefix;
    gZLList # cZList;
    gKey    # cKey;

    gMenu # gFrmMain->WinInfo(_WinMenu);

    // gelinkter Datensatz? -> dann Sort/Suche abschalten
    if (gZLList->wpDbLinkFileNo<>0) or (gZLList->wpdbfilter<>0) then begin
      vHdl # gMDI->WinSearch('lb.Sort');
      vHdl->wpvisible # false;
      vHdl # gMDI->WinSearch('lb.Suche');
      vHdl->wpvisible # false;
      vHdl # gMDI->WinSearch('ed.Sort');
      vHdl->wpvisible # false;
      vHdl # gMDI->WinSearch('ed.Suche');
      vHdl->wpvisible # false;
    end;
  end;

  Call('App_Main:EvtMdiActivate',aEvt);

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
)
local begin
  Erx     : int;
  vTmp    : int;
  vBuf250 : int;
end;
begin

  $lb.HW1->wpcaption # "Set.Hauswährung.Kurz";
  $lb.HW2->wpcaption # "Set.Hauswährung.Kurz";

  // Je nach Art des Stücklisteneintrages die anderen Möglichkeiten
  // deaktivieren (Artikel, Arbeitsgang, Ressource, Text)
  if ((aName='') or (aName='Typ')) and (Mode<>c_ModeView) then begin
    if (Art.SL.Typ = 250) then begin
      Lib_GuiCom:Enable($edArt.SL.Input.ArtNr);
      Lib_GuiCom:Disable($edArt.SL.Input.ArGAkt);
      Lib_GuiCom:Disable($edArt.SL.Input.ResGrp);
      Lib_GuiCom:Disable($edArt.SL.Input.ResNr);

      Art.SL.Kosten.StdYN # y;
      $cbArt.SL.Kosten.StdYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($cbArt.SL.Kosten.StdYN);

      aName # 'edArt.SL.Input.ArtNr';
    end
    else if (Art.SL.Typ = 828) then begin
      Lib_GuiCom:Disable($edArt.SL.Input.ArtNr);
      Lib_GuiCom:Enable($edArt.SL.Input.ArGAkt);
      Lib_GuiCom:Disable($edArt.SL.Input.ResGrp);
      Lib_GuiCom:Disable($edArt.SL.Input.ResNr);

      Lib_GuiCom:Enable($cbArt.SL.Kosten.StdYN);

      Art.SL.MEH # 'min';
      aName # 'edArt.SL.Input.ArGAkt';
      end
    else if (Art.SL.Typ = 160) then begin
      Lib_GuiCom:Disable($edArt.SL.Input.ArtNr);
      Lib_GuiCom:Disable($edArt.SL.Input.ArGAkt);
      Lib_GuiCom:Enable($edArt.SL.Input.ResGrp);
      Lib_GuiCom:Enable($edArt.SL.Input.ResNr);

      Lib_GuiCom:Enable($cbArt.SL.Kosten.StdYN);

      Art.SL.MEH # 'min';
      aName # 'edArt.SL.Input.ResNr';
      end
    else if (Art.SL.Typ = 0) then begin
      Lib_GuiCom:Disable($edArt.SL.Input.ArtNr);
      Lib_GuiCom:Disable($edArt.SL.Input.ArGAkt);
      Lib_GuiCom:Disable($edArt.SL.Input.ResGrp);
      Lib_GuiCom:Disable($edArt.SL.Input.ResNr);

      Lib_GuiCom:Disable($cbArt.SL.Kosten.StdYN);

      aName # 'Text';
      end
    else if (Art.SL.Typ = 999) then begin
      Lib_GuiCom:Disable($edArt.SL.Input.ArtNr);
      Lib_GuiCom:Disable($edArt.SL.Input.ArGAkt);
      Lib_GuiCom:Disable($edArt.SL.Input.ResGrp);
      Lib_GuiCom:Disable($edArt.SL.Input.ResNr);

      Art.SL.Kosten.StdYN # y;
      $cbArt.SL.Kosten.StdYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($cbArt.SL.Kosten.StdYN);
    end;
  end;

  if (aName='Kosten') then begin
      if (Art.SL.Typ = 250) then
        aName # 'edArt.SL.Input.ArtNr';
      else if (Art.SL.Typ = 828) then
        aName # 'edArt.SL.Input.ArGAkt';
      else if (Art.SL.Typ = 160) then
        aName # 'edArt.SL.Input.ResNr';
      else if (Art.SL.Typ = 0) then begin
        aName # 'Text';
      end;
  end;

  if (aName='' and Art.SL.Typ=250) or (aName='edArt.SL.Input.ArtNr') then begin

    $lb.Artikelstichwort->wpCaption # '';
    $lb.Ressource->wpCaption # '';
    $lb.Arbeitsgang->wpCaption # '';

    // Aktuellen Artikel speichern
    vBuf250 # RekSave(250);
    Erx # RecLink(250, 256, 2, 0);
    if (Erx<=_rLocked) then begin
      $lb.Artikelstichwort->wpCaption # Art.Stichwort;

      // Kosten eintragen
      if (Art.SL.Kosten.StdYN) then begin
        Art.SL.Kosten.FixW1 # 0.0;
        Art.SL.Kosten.VarW1 # Art.Fert.KostenW1;
        Art.SL.Kosten.MEH # Art.MEH;
        Art.SL.Kosten.PEH # Art.PEH;
        Art.SL.MEH        # Art.MEH;

        $edArt.SL.Kosten.FixW1->WinUpdate(_WinUpdFld2Obj);
        $edArt.SL.Kosten.VarW1->WinUpdate(_WinUpdFld2Obj);
        $edArt.SL.Kosten.MEH->WinUpdate(_WinUpdFld2Obj);
        $edArt.SL.Kosten.PEH->WinUpdate(_WinUpdFld2Obj);

        $lb.MEH->wpCaption # Art.SL.Kosten.MEH;
      end;
    end;

    // Artikel wiederherstellen
    RekRestore(vBuf250);
  end;


  if (aName='' and Art.SL.Typ=828) or (aName='edArt.SL.Input.ArGAkt') then begin

    $lb.Artikelstichwort->wpCaption # '';
    $lb.Ressource->wpCaption # '';
    $lb.Arbeitsgang->wpCaption # '';

    Erx # RecLink(828, 256, 4, 0);    // Arbeitsgang holen

    if (Erx<=_rLocked) then begin
      $lb.Arbeitsgang->wpCaption # ArG.Bezeichnung;

      // Kosten eintragen
      if (Art.SL.Kosten.StdYN) then begin
        Art.SL.Kosten.FixW1 # 0.0;
        Art.SL.Kosten.VarW1 # 0.0;
        Art.SL.Kosten.MEH # 'min';
        Art.SL.Kosten.PEH # 60;

        $edArt.SL.Kosten.FixW1->WinUpdate(_WinUpdFld2Obj);
        $edArt.SL.Kosten.VarW1->WinUpdate(_WinUpdFld2Obj);
        $edArt.SL.Kosten.MEH->WinUpdate(_WinUpdFld2Obj);
        $edArt.SL.Kosten.PEH->WinUpdate(_WinUpdFld2Obj);

        $lb.MEH->wpCaption # Art.SL.Kosten.MEH;
      end;

    end;
  end;

  if (aName='' and Art.SL.Typ=160) or (aName='edArt.SL.Input.ResNr') then begin

    $lb.Artikelstichwort->wpCaption # '';
    $lb.Ressource->wpCaption # '';
    $lb.Arbeitsgang->wpCaption # '';

    Erx # RecLink(160, 256, 3, 0);  // Ressource
    if (Erx<=_rLocked) then begin
      $lb.Ressource->wpCaption # Rso.Stichwort;
      $edArt.SL.Input.ResGrp->WinUpdate(_WinUpdFld2Obj);

      // Kosten eintragen
      if (Art.SL.Kosten.StdYN) then begin
        Art.SL.Kosten.FixW1 # 0.0;
        Art.SL.Kosten.VarW1 # Rso.PreisProH;
        Art.SL.Kosten.MEH # 'min';
        Art.SL.Kosten.PEH # 60;

        $edArt.SL.Kosten.FixW1->WinUpdate(_WinUpdFld2Obj);
        $edArt.SL.Kosten.VarW1->WinUpdate(_WinUpdFld2Obj);
        $edArt.SL.Kosten.MEH->WinUpdate(_WinUpdFld2Obj);
        $edArt.SL.Kosten.PEH->WinUpdate(_WinUpdFld2Obj);

        $lb.MEH->wpCaption # Art.SL.Kosten.MEH;
      end;

    end;
  end;

  if (aName='' and Art.SL.Typ=0) or (aName='Text') then begin

    $lb.Artikelstichwort->wpCaption # '';
    $lb.Ressource->wpCaption # '';
    $lb.Arbeitsgang->wpCaption # '';

    // Kosten eintragen (Standard: keine)
    if (Art.SL.Kosten.StdYN) then begin
      Art.SL.Kosten.FixW1 # 0.0;
      Art.SL.Kosten.VarW1 # 0.0;
      Art.SL.Kosten.MEH # '';
      Art.SL.Kosten.PEH # 0;

      $edArt.SL.Kosten.FixW1->WinUpdate(_WinUpdFld2Obj);
      $edArt.SL.Kosten.VarW1->WinUpdate(_WinUpdFld2Obj);
      $edArt.SL.Kosten.MEH->WinUpdate(_WinUpdFld2Obj);
      $edArt.SL.Kosten.PEH->WinUpdate(_WinUpdFld2Obj);
    end;

  end;

  if (aName='') or (aName='MEH') then
    $lb.MEH->wpcaption # Art.SL.Kosten.MEH

  // Haken setzen
  if (aName='' and Mode=c_ModeView) then begin
    $cb.Artikel->wpCheckState # _WinStateChkUnChecked;
    $cb.Arbeitsgang->wpCheckState # _WinStateChkUnChecked;
    $cb.Ressource->wpCheckState # _WinStateChkUnChecked;
    $cb.Text->wpCheckState # _WinStateChkUnChecked;

    if (Art.SL.Typ=250) then
      $cb.Artikel->wpCheckState # _WinStateChkChecked
    else if (Art.SL.Typ=828) then
      $cb.Arbeitsgang->wpCheckState # _WinStateChkChecked
    else if (Art.SL.Typ=160) then
      $cb.Ressource->wpCheckState # _WinStateChkChecked;
    else
      $cb.Text->wpCheckState # _WinStateChkChecked;
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

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
  // Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:

  $edArt.SL.Blocknr->WinFocusSet(true);

  $cb.Artikel->wpCheckstate # _WinStateChkUnChecked;
  $cb.Ressource->wpCheckstate # _WinStateChkUnChecked;
  $cb.Arbeitsgang->wpCheckstate # _WinStateChkUnChecked;
  $cb.Text->wpCheckstate # _WinStateChkUnChecked;

  if (Mode=c_ModeNew) then begin
    RecBufClear(256);

    $lb.Artikelstichwort->wpCaption # '';
    $lb.Ressource->wpCaption # '';
    $lb.Arbeitsgang->wpCaption # '';
    $lb.MEH->wpCaption # '';

    Lib_GuiCom:Disable($edArt.SL.Input.ArtNr);
    Lib_GuiCom:Disable($edArt.SL.Input.ArGAkt);
    Lib_GuiCom:Disable($edArt.SL.Input.ResGrp);
    Lib_GuiCom:Disable($edArt.SL.Input.ResNr);
    Art.SL.Artikelnr  # Art.Nummer;
    Art.SL.Nummer     # Art.SLK.Nummer;

    // Standard-kosten aktivieren (Kostenfelder deaktivieren & automatisch füllen)
    $cbArt.SL.Kosten.StdYN->wpcheckstate # _WinStateChkChecked;
    Art.SL.Kosten.StdYN # true;

    Lib_GuiCom:Disable($edArt.SL.Kosten.FixW1);
    Lib_GuiCom:Disable($edArt.SL.Kosten.VarW1);
    Lib_GuiCom:Disable($edArt.SL.Kosten.PEH);
    Lib_GuiCom:Disable($edArt.SL.Kosten.MEH);
    Lib_GuiCom:Disable($bt.MEH.Kosten);

    Art.SL.Typ # 999; // 'Kein-Typ'
    end
  else if (Mode=c_ModeEdit) then begin
    if (Art.SL.Typ = 250) then begin
      // Artikel
      $cb.Artikel->wpCheckstate # _WinStateChkChecked;
      Lib_GuiCom:Disable($edArt.SL.Input.ArGAkt);
      Lib_GuiCom:Disable($edArt.SL.Input.ResGrp);
      Lib_GuiCom:Disable($edArt.SL.Input.ResNr);
      Lib_GuiCom:Disable($cbArt.SL.Kosten.StdYN);
    end
    else if (Art.SL.Typ = 828) then begin
      // Arbeitsgang
      $cb.Arbeitsgang->wpCheckstate # _WinStateChkChecked;
      Lib_GuiCom:Disable($edArt.SL.Input.ArtNr);
      Lib_GuiCom:Disable($edArt.SL.Input.ResGrp);
      Lib_GuiCom:Disable($edArt.SL.Input.ResNr);
      Lib_GuiCom:Enable($cbArt.SL.Kosten.StdYN);
    end
    else if (Art.SL.Typ = 160) then begin
      // Ressource
      $cb.Ressource->wpCheckstate # _WinStateChkChecked;
      Lib_GuiCom:Disable($edArt.SL.Input.ArtNr);
      Lib_GuiCom:Disable($edArt.SL.Input.ArGAkt);
      Lib_GuiCom:Enable($cbArt.SL.Kosten.StdYN);
    end
    else if (Art.SL.Typ = 0) then begin
      // Text
      $cb.Text->wpCheckstate # _WinStateChkChecked;
      Lib_GuiCom:Disable($edArt.SL.Input.ArtNr);
      Lib_GuiCom:Disable($edArt.SL.Input.ArGAkt);
      Lib_GuiCom:Disable($edArt.SL.Input.ResGrp);
      Lib_GuiCom:Disable($edArt.SL.Input.ResNr);
      Lib_GuiCom:Disable($cbArt.SL.Kosten.StdYN);
    end;

    // bei Standardkosten kann nichts editiert werden
    if (Art.SL.Kosten.StdYN) then begin
      Lib_GuiCom:Disable($edArt.SL.Kosten.FixW1);
      Lib_GuiCom:Disable($edArt.SL.Kosten.VarW1);
      Lib_GuiCom:Disable($edArt.SL.Kosten.PEH);
      Lib_GuiCom:Disable($edArt.SL.Kosten.MEH);
      Lib_GuiCom:Disable($bt.MEH.Kosten);

      // Standardkosten eintragen
      if (Art.SL.Typ = 250) then
        RefreshIfm('edArt.SL.Input.ArtNr');
      else if (Art.SL.Typ = 160) then
        RefreshIfm('edArt.SL.Input.ArGAkt');
      else if (Art.SL.Typ = 828) then
        RefreshIfm('edArt.SL.Input.ResNr');
      else if (Art.SL.Typ = 0) then begin
        RefreshIfm('Text');
      end;

    end
    else begin
      Lib_GuiCom:Enable($edArt.SL.Kosten.FixW1);
      Lib_GuiCom:Enable($edArt.SL.Kosten.VarW1);
      Lib_GuiCom:Enable($edArt.SL.Kosten.PEH);
      Lib_GuiCom:Enable($edArt.SL.Kosten.MEH);
      Lib_GuiCom:Enable($bt.MEH.Kosten);
    end;
  end;
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
  vX  : float;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // wurde ein Typ ausgewählt?
  if (Art.SL.Typ = 999) then begin
    Msg(001202,Translate('Typ'),0,0,0);
    $cb.Artikel->WinFocusSet(true);
    RETURN false;
  end;

  // je nach Typ die restlichen verknüpfungen entfernen (falls Typ geändert wird)
  if (Art.SL.Typ = 250) then begin
    Art.SL.Input.ArGAkt # '';
    Art.SL.Input.ResGrp # 0;
    Art.SL.Input.ResNr # 0;
    if (Art_SL_Data:CheckArtInArt(Art.SLK.Artikelnr, Art.SL.Input.ArtNr)=true) then begin
      Msg(256001,'',0,0,0);
      RETURN false;
    end;

  end
  else
  if (Art.SL.Typ = 828) then begin
    Art.SL.Input.ArtNr # '';
    Art.SL.Input.ResGrp # 0;
    Art.SL.Input.ResNr # 0;
  end
  else
  if (Art.SL.Typ = 160) then begin
    Art.SL.Input.ArtNr # '';
    Art.SL.Input.ArGAkt # '';
  end
  else
  if (Art.SL.Typ = 0) then begin
      Art.SL.Input.ArtNr # '';
    Art.SL.Input.ArGAkt # '';
    Art.SL.Input.ResGrp # 0;
    Art.SL.Input.ResNr # 0;
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
    Art.SL.Anlage.Datum  # Today;
    Art.SL.Anlage.Zeit   # Now;
    Art.SL.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  Art_SL_Data:RecalcSLK();

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
  gZLList->winFocusSet(false);
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

    'Artikel' : begin
//      RecBufClear(250);         // ZIELBUFFER LEEREN
      $lb.SLvonArtikelnr->wpcustom # Art.Nummer;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Arbeitsgang' : begin
      RecBufClear(828);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ArG.Verwaltung',here+':AusArbeitsgang');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Ressource' : begin
      RecBufClear(160);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Verwaltung',here+':AusRessource');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edArt.SL.Kosten.MEH,256,2,4);
      RefreshIfm('MEH');
    end;

  end;

end;


//========================================================================
//  AusArtikel
//
//========================================================================
sub AusArtikel()
local begin
  vBuf250 : int;
end;
begin
  if (gSelected<>0) then begin
    vBuf250 # RekSave(250);
    RecRead(250,0,_RecId,gSelected);
    // Feldübernahme
    Art.SL.Input.ArtNr # Art.Nummer;
    gSelected # 0;
    RekRestore(vBuf250);
  end;

  // Focus auf Editfeld setzen:
  $edArt.SL.Input.ArtNr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArt.SL.Input.ArtNr');
end;


//========================================================================
//  AusArbeitsgang
//
//========================================================================
sub AusArbeitsgang()
begin
  if (gSelected<>0) then begin
    RecRead(828,0,_RecId,gSelected);
    // Feldübernahme
    Art.SL.Input.ArGAkt # ArG.Aktion2;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edArt.SL.Input.ArGAkt->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArt.SL.Input.ArGAkt');
end;


//========================================================================
//  AusRessource
//
//========================================================================
sub AusRessource()
begin
  if (gSelected<>0) then begin
    RecRead(160,0,_RecId,gSelected);
    // Feldübernahme
    Art.SL.Input.ResGrp # Rso.Gruppe;
    Art.SL.Input.ResNr  # Rso.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edArt.SL.Input.ResNr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edArt.SL.Input.ResNr');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_SL_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_SL_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (vChildMode=2) or (Rechte[Rgt_Art_SL_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (vChildMode=2) or (Rechte[Rgt_Art_SL_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (vChildMode=2) or (Rechte[Rgt_Art_SL_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (vChildMode=2) or (Rechte[Rgt_Art_SL_Loeschen]=n);

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
      PtD_Main:View(gFile,Art.SL.Anlage.Datum, Art.SL.Anlage.Zeit, Art.SL.Anlage.User);
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
    'bt.Artikel'      :   Auswahl('Artikel');
    'bt.Arbeitsgang'  :   Auswahl('Arbeitsgang');
    'bt.Gruppe'       :   Auswahl('Ressource');
    'bt.MEH.Kosten'   :   Auswahl('MEH');
    'bt.xxxxx'        :   Auswahl('...');
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
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='edArt.SL.Kosten.MEH') then begin
    $edArt.SL.Kosten.MEH->WinUpdate(_WinUpdObj2Fld);
    RefreshIfm('MEH');
  end;

  // Radiobutton-verhalten mit Checkboxen simulieren
  if (aEvt:Obj->wpname='cb.Artikel') then begin
    if ($cb.Artikel->wpCheckstate=_WinStateChkChecked) then begin
      $cb.Arbeitsgang->wpCheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpCheckstate # _WinStateChkUnChecked;
      $cb.Text->wpCheckstate # _WinStateChkUnChecked;
      Art.SL.Typ # 250;

      end
    else
      Art.SL.Typ # 999;  // Kein Typ

    RefreshIfm('Typ');
  end;
  if (aEvt:Obj->wpname='cb.Arbeitsgang') then begin
    if ($cb.Arbeitsgang->wpCheckstate=_WinStateChkChecked) then begin
      $cb.Artikel->wpCheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpCheckstate # _WinStateChkUnChecked;
      $cb.Text->wpCheckstate # _WinStateChkUnChecked;
      Art.SL.Typ # 828;
    end
    else
      Art.SL.Typ # 999;  // Kein Typ

    RefreshIfm('Typ');
  end;
  if (aEvt:Obj->wpname='cb.Ressource') then begin
    if ($cb.Ressource->wpCheckstate=_WinStateChkChecked) then begin
      $cb.Artikel->wpCheckstate # _WinStateChkUnChecked;
      $cb.Arbeitsgang->wpCheckstate # _WinStateChkUnChecked;
      $cb.Text->wpCheckstate # _WinStateChkUnChecked;
      Art.SL.Typ # 160;
    end
    else
      Art.SL.Typ # 999;  // Kein Typ

    RefreshIfm('Typ');
  end;
  if (aEvt:Obj->wpname='cb.Text') then begin
    if ($cb.Text->wpCheckstate=_WinStateChkChecked) then begin
      $cb.Artikel->wpCheckstate # _WinStateChkUnChecked;
      $cb.Arbeitsgang->wpCheckstate # _WinStateChkUnChecked;
      $cb.Ressource->wpCheckstate # _WinStateChkUnChecked;
      Art.SL.Typ # 0;
    end
    else
      Art.SL.Typ # 999;  // Kein Typ

    RefreshIfm('Typ');
  end;

  if (aEvt:Obj->wpname='cbArt.SL.Kosten.StdYN') then begin
    if ($cbArt.SL.Kosten.StdYN->wpCheckstate=_WinStateChkChecked) then begin
      Lib_GuiCom:Disable($edArt.SL.Kosten.FixW1);
      Lib_GuiCom:Disable($edArt.SL.Kosten.VarW1);
      Lib_GuiCom:Disable($edArt.SL.Kosten.PEH);
      Lib_GuiCom:Disable($edArt.SL.Kosten.MEH);
      Lib_GuiCom:Disable($bt.MEH.Kosten);

      // Standardkosten eintragen
      RefreshIfm('Kosten');

    end
    else begin
      Lib_GuiCom:Enable($edArt.SL.Kosten.FixW1);
      Lib_GuiCom:Enable($edArt.SL.Kosten.VarW1);
      Lib_GuiCom:Enable($edArt.SL.Kosten.PEH);
      Lib_GuiCom:Enable($edArt.SL.Kosten.MEH);
      Lib_GuiCom:Enable($bt.MEH.Kosten);
    end;
  end;

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
  vBuf250   : int;
end;
begin

  Gv.Alpha.01 # '';

  if (Art.SL.Typ = 250) then begin
//    Gv.Alpha.10 # Art.Nummer;
//    Erx # RecLink(250,256,2,0);   // InputArtikel holen
//    if Erx<=_rLocked then
  //    Gv.Alpha.01 # Art.Nummer;
      GV.Alpha.01 # Art.SL.Input.ArtNr;
//    Art.Nummer # Gv.Alpha.10;
//    RecRead(250,1,0);
  end
  else if (Art.SL.Typ = 828) then begin
    Erx # RecLink(828,256,4,0);   // Arbeitsgang
    if Erx<=_rLocked then
      Gv.Alpha.01 # ArG.Aktion2;
  end
  else if (Art.SL.Typ = 160) then begin
    Erx # RecLink(160,256,3,0);   // Ressource holen
    if Erx<=_rLocked then
      Gv.Alpha.01 # Rso.Stichwort;
  end;


  if (aMark=false) then begin
    if (Art.SL.Typ=250) then begin
      vBuf250 # RekSave(250);
      Erx # RecLink(250,256,2,_recFirst);   // Input-Artikel holen
      if ("Art.SLRefreshNötigYN") then
        Lib_GuiCom:ZLColorLine(gZLList,Set.Art.SL.Col.Refsh)
      else if (Art.GesperrtYN) then
        Lib_GuiCom:ZLColorLine(gZLList,Set.Art.SL.Col.Sperr);
      RekRestore(vBuf250);
      end
    else if (Art.SL.Typ=828) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Art.Sl.Col.ArG)
    else if (Art.SL.Typ=160) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Art.SL.Col.Resso)
    else
      Lib_GuiCom:ZLColorLine(gZLList,Set.Art.SL.Col.Text);
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
  Erx : int;
end;
begin
  Erx # RecLink(250,255,1,_recFirst);   // Artikel holen
  RecBufClear(256);
  RETURN true;
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
    if ((vFile=250)) then begin
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
  Erx         : int;
  vA          : alpha;
  vFile       : int;
  vID         : int;
  vBlock      : int;
  vLfd        : int;
  vBuf250     : int;
  vLine       : int;
  vPlace      : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    if (vID=0) then RETURN false;

    case vFile of

      250 : begin

        vBuf250 # RekSave(250);
        RecRead(vFile,0,_RecId,vID);        // Artikel holen

        if (Art_SL_Data:CheckArtInArt(Art.SLK.Artikelnr, Art.Nummer)=true) then begin
          RekRestore(vBuf250);
          Msg(256001,'',0,0,0);
          RETURN false;
        end;

        vLine       # aDataPlace->wpArgInt(0);
//        vPlace      # aDataPlace->wpDropPlace;
//      vDropIsDrag # aDataPlace->wpDragSource = aEvt:obj;
        // Einfügeposition.
//        case vPlace of
//          _WinDropPlaceAppend  then vA # 'NACH';//  inc(vLine);
//          _WinDropPlaceBefore) then vA # 'VOR';//  inc(vLine);
//          _WinDropPlaceNone) then vA # '??';//vLine # aDataObject->WinLstDatLineInfo(_WinLstDatInfoCount) + 1;
//        Erx # RecRead(256,0,0,vLine);
        Erx # RecLink(256,255,2,_recLast);
        if (Erx>_rLocked) then begin
          vBlock  # 1;
          vLfd    # 1;
          end
        else begin
          vBlock  # Art.SL.BlockNr;
          vLfd    # Art.SL.lfdNr + 1;
        end;
        RecBufClear(256);
        Art.SL.Artikelnr    # Art.SLK.Artikelnr;
        Art.SL.Nummer       # Art.SLK.Nummer;
        Art.SL.BlockNr      # vBlock;
        Art.SL.lfdNr        # vlfd;
        Art.SL.Typ          # 250;
        Art.SL.MEH          # Art.MEH;
        Art.SL.Input.ArtNr  # Art.Nummer;
        Art.SL.Kosten.StdYN # y;
        REPEAT
          Art.SL.Anlage.Datum # Today;
          Art.SL.Anlage.Zeit  # Now;
          Art.SL.Anlage.User  # gUserName;
          Erx # RekInsert(256,0,'MAN');
          if (Erx<>_rOK) then Art.SL.lfdNr # Art.SL.lfdNr + 1;
        UNTIL (Erx=_rOK);
        RekRestore(vBuf250);

        aEvt:Obj->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
//        aEvt:Obj->WinUpdate(_WinUpdOn, _WinLst
//      Art_SL_Main:RefreshIfm();
        RETURN true;
      end;

    end; // case

  end;

	RETURN (false);
end

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);

begin

  if ((aName =^ 'edArt.SL.Input.ArtNr') AND (aBuf->Art.SL.Input.ArtNr<>'')) then begin
    RekLink(250,256,1,1);   // Artikel nr. holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.SL.Input.ArGAkt') AND (aBuf->Art.SL.Input.ArGAkt<>'')) then begin
    RekLink(828,256,4,1);   // Artikel nr. holen
    Lib_Guicom2:JumpToWindow('ArG.Verwaltung');
    RETURN;
  end;

  if ((aName =^ 'edArt.SL.Input.ResNr') AND (aBuf->Art.SL.Input.ResNr<>0)) then begin
    RekLink(160,256,3,2);   // Resource nr. holen
    Lib_Guicom2:JumpToWindow('Rso.Verwaltung');
    RETURN;
  end;

  
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
