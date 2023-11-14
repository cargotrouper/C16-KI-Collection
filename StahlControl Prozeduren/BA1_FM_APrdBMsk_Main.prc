@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_FM_APrdBMsk_Main
//                    OHNE E_R_G
//  Info    Maskensteuerung für die Beistellungsangabe der Artikelproduktion
//
//
//  26.09.2012  AI  Erstellung der Prozedur
//  04.04.2022  AH  ERX
//  19.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtChanged(aEvt : event) : logic;
//    SUB Auswahl(aBereich : alpha)
//    SUB AusArtikelnummer()
//    SUB AusCharge()
//    SUB AusCharge_Mat()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtTimer(aEvt : event; aTimerId : int): logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB _SuchePassendeCharge()
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle :    'Einsatz'
  cFile :     0
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'BA1_FM_APrdBMsk'
  cZList :    0
  cKey :      1
end;

declare Auswahl(aBereich : alpha)
declare _SuchePassendeCharge()
declare RefreshIfm(opt aName : alpha)


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl,vDl,vLine : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  Lib_Guicom2:Underline($edBAG.FM.B.Artikelnr);
  Lib_Guicom2:Underline($edBAG.FM.B.Art.Charge);

  SetStdAusFeld('edBAG.FM.B.Artikelnr'      ,'Artikel');
  SetStdAusFeld('edBAG.FM.B.Art.Charge'     ,'Charge');       // Wird auch für 209er ArtMatMix genutzt

  $DL_Mode->wpCaption # 'NEW';
  // Änderung an Artikelangabe nicht möglich. Änderung nur über Löschen und neu Einfügen
  if (BAG.FM.B.Artikelnr <> '') then begin
    Lib_GuiCom:Disable($edBAG.FM.B.Artikelnr);
    Lib_GuiCom:Disable($bt.Artikel);
    $DL_Mode->wpCaption # 'EDIT';
  end;

  // ggf. bei Chargenführungsartikeln die passende Charge schon vorauswählen und
  //      dann die Auswahl deaktivieren
  _SuchePassendeCharge();

  // Modus wieder auf Neuanlage setzen, da so die AppMain Bearbeitung für EDIT
  // nicht weiter durchgeführt wird diese verhindert:
  //  - Lesen/Sperren/Entsperren von Datensätzen, die in diesem Fall nicht Aktiv sind
  //  - Moduswechsel nach Speicherung in Ansichtsmodus
  Mode # c_ModeNew;

  App_Main:EvtInit(aEvt);

  RefreshIfm();
end;



//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edBAG.FM.B.Art.Artikelnr);
  Lib_GuiCom:Pflichtfeld($edBAG.FM.B.Art.Charge);
  Lib_GuiCom:Pflichtfeld($edBAG.FM.B.Menge);
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

  $Lb.Zustand->wpCaption          # '';
  $Lb.ZustandText->wpCaption      # '';
  $Lb.Lageradresse->wpCaption     # '';
  $Lb.LageradresseText->wpCaption # '';
  $Lb.Lageranschr->wpCaption      # '';
  $Lb.Lageranschrift->wpCaption   # '';
  $lb.MEH.IN2->wpCaption          # '';
  $lb.Bestand->wpCaption          # '';

  // Ohne Artikel, keine Chargenangabe
  if (BAG.FM.B.Artikelnr = '') then begin
    BAG.FM.B.Art.Charge # '';
    RETURN;
  end;

  // Artikel lesen
  Erx # RecLink(250,708,1,0);
  if (Erx <> _rOK) then begin
    RecBufClear(250);
    RETURN;
  end;
  $lb.MEH.IN2->wpCaption  # Art.MEH;
  $lb.MEH->wpCaption      # Art.MEH;
  BAG.FM.B.MEH            # Art.MEH;

  // Charge lesen und Anzeigen
  if (BAG.FM.B.Art.Charge <> '') or (BAG.FM.B.Materialnr <> 0) then begin

    // Warengruppe des Artikels lesen
    Erx # RecLink(819,250,10,0);
    if (Erx <> _rOK) then begin
      RecBufClear(819);
      RETURN;
    end;

    if (Wgr_Data:IstMix()) then begin

      // ---------------------------
      // Materialcharge lesen
      BAG.FM.B.Materialnr # CnvIa(BAG.FM.B.Art.Charge);

      Erx # Mat_Data:Read(BAG.FM.B.Materialnr);
      if  (Erx = 200) OR (Erx = 210) then begin

        // Material hat keinen Zustand (höchstens status)
        $Lb.Zustand->wpCaption      # '';
        $Lb.ZustandText->wpCaption  # '';

        // Lageradresse
        $Lb.Lageradresse->wpCaption # Aint(Mat.Lageradresse);
        $Lb.LageradresseText->wpCaption # '';
        if (RecLink(100,200,5,0) =  _rOK) then
          $Lb.LageradresseText->wpCaption # Adr.Stichwort;

        // Lageranschrift
        $Lb.Lageranschr->wpCaption # Aint(Mat.Lageranschrift);
        $Lb.Lageranschrift->wpCaption # '';
        if (RecLink(101,200,6,0) =  _rOK) then
          $Lb.Lageranschrift->wpCaption # Adr.A.Stichwort;

        $lb.Bestand->wpCaption # Anum("Mat.Bestand.Gew",Set.Stellen.Menge);
      end;

      BAG.FM.B.Art.Charge   # Aint(BAG.FM.B.Materialnr);

    end else begin

      // ---------------------------
      // Echte Charge lesen
      Erx # RecLink(252,708,2,0);
      if (Erx = _rOK) then begin

        // Zustand
        $Lb.Zustand->wpCaption      # Aint(Art.C.Zustand);
        $Lb.ZustandText->wpCaption  # '';
        if (RecLink(856,252,9,0) = _rOK) then
          $Lb.ZustandText->wpCaption  # Art.Zst.Name;

        // Lageradresse
        $Lb.Lageradresse->wpCaption # Aint(Art.C.Adressnr);
        $Lb.LageradresseText->wpCaption # '';
        if (RecLink(100,252,4,0) =  _rOK) then
          $Lb.LageradresseText->wpCaption # Adr.Stichwort;

        // Lageranschrift
        $Lb.Lageranschr->wpCaption # Aint(Art.C.Anschriftnr);
        $Lb.Lageranschrift->wpCaption # '';
        if (RecLink(101,252,3,0) =  _rOK) then
          $Lb.Lageranschrift->wpCaption # Adr.A.Stichwort;

        $lb.Bestand->wpCaption # Anum("Art.C.Bestand",Set.Stellen.Menge);
      end;

    end;
  end;


  if (aName = 'edBAG.FM.B.Art.Charge') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
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
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vDL   : int;
  vLine : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if (BAG.FM.Artikelnr='') then begin
    Msg(001200,Translate('Artikel'),0,0,0);
    $edBAG.FM.B.Artikelnr->WinFocusSet(true);
    RETURN false;
  end;

  if (BAG.FM.B.Art.Charge='') then begin
    Msg(001200,Translate('Charge'),0,0,0);
    $edBAG.FM.B.Art.Charge->WinFocusSet(true);
    RETURN false;
  end;

  if (BAG.FM.B.Menge = 0.0) then begin
    Msg(001200,Translate('Menge'),0,0,0);
    $edBAG.FM.B.Menge->WinFocusSet(true);
    RETURN false;
  end;

  // Passt die Charge um Artikel?
  Erx # RecLink(250,708,1,0);
  if (Erx <= _rLocked) then begin

    if (BAG.FM.B.Materialnr <> 0) then begin
      // Materialcharge prüfen
      Erx # Mat_Data:Read(BAG.FM.B.Materialnr);
      if (Erx < 0) then begin
        // Material nicht gefunden
        Msg(010001,Aint(BAG.FM.B.Materialnr),0,0,0);
        $edBAG.FM.B.Art.Charge->WinFocusSet(true);
        RETURN false;
      end;

      if (Mat.Strukturnr <> Art.Nummer) then begin
        // Materialcharge nicht vorhanden
        //404250 :  vA # 'E:Die Charge %1% konnte nicht im Bestand gelesen werden!';
        Msg(404250,Aint(BAG.FM.B.Materialnr),0,0,0);
        $edBAG.FM.B.Art.Charge->WinFocusSet(true);
        RETURN false;
      end;

    end else begin
      // Artikelcharge prüfen

      Erx # RecLink(252,708,2,0);
      if (Erx > _rLocked) then begin
        // Chrage nicht gefunden
        Msg(404250,Aint(BAG.FM.B.Materialnr),0,0,0);
        $edBAG.FM.B.Art.Charge->WinFocusSet(true);
        RETURN false;
      end;
    end;

  end else begin
    // Artikel nicht gefunden
    Msg(010001,BAG.FM.B.Artikelnr,0,0,0);
    $edBAG.FM.B.Artikelnr->WinFocusSet(true);
    RETURN false;
  end;



if (BAG.FM.B.MEH = '') then
  todo('Die MEH des Ist Menge ist leer');

  vDL   # cnvia($lb.Datalist->wpcustom);
  vLine # cnvia($lb.Datalist->wpCaption);

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if ($DL_Mode->wpCaption = 'EDIT') then begin

     // Listeneintrag Updaten
    vDl->WinLstCellSet(BAG.FM.B.Artikelnr,  1,vLine);
    vDl->WinLstCellset(BAG.FM.B.Art.Charge, 2,vLine);
    // Sollmenge = 3
    vDl->WinLstCellset(BAG.FM.B.Menge,      4,vLine);
    vDl->WinLstCellset(BAG.FM.B.MEH,        5,vLine);
    vDl->WinLstCellset(BAG.FM.B.Bemerkung,  6,vLine);

  end else begin  // Neuanlage
    vDL # cnvia($lb.Datalist->wpcustom);

    vLine # vDl->WinLstDatLineAdd(BAG.FM.B.Artikelnr, _WinLstDatLineLast);
    vDl->WinLstCellset(BAG.FM.B.Art.Charge, 2,vLine);
    // Sollmenge = 3
    vDl->WinLstCellset(BAG.FM.B.Menge,      4,vLine);
    vDl->WinLstCellset(BAG.FM.B.MEH,        5,vLine);
    vDl->WinLstCellset(BAG.FM.B.Bemerkung,  6,vLine);
  end;

  Mode # c_modeCancel;  // sofort alles beenden!
  gSelected # 1;

  RETURN true;  // Speichern erfolgreich

end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  gSelected # 0;
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin
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

  // Auswahlfelder einfärben
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);


  if (w_command='->POS') then begin
    w_command # '';
//    gTimer2 # SysTimerCreate(300,1,gMdi);
    RETURN false;
  end;

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

  RETURN(true);
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  Erx     : int;
  vA      : alpha;
  vHdl    : int;
  vQ,vQ2  : alpha(4096);
  vI      : int;
  tErx    : int;
end;

begin

  case aBereich of

    'Artikel' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN

      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikelnummer');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gKey # 1;

      // Übernommen aus Auftragsauswahl
      vHdl # Winsearch(gMDI,'ZL.Artikel');
      if (Auf.P.Warengruppe<>0) and (Set.Auf.Artfilter=819) then begin
        vQ # 'LinkCount(WGR) > 0 AND NOT(Art.GesperrtYN)';
        vI # Auf.P.Wgr.Dateinr;
        vI # Wgr_data:WennArtDannCharge(vI);
        Lib_Sel:QInt(var vQ2, 'Wgr.Dateinummer'  , '=', vI);
        vHdl # SelCreate(250, gKey);
        vHdl->SelAddLink('',819, 250, 10, 'WGR');
        tErx # vHdl->SelDefQuery('', vQ);
        if (tErx != 0) then Lib_Sel:QError(vHdl);
        tErx # vHdl->SelDefQuery('WGR', vQ2);
        if (tErx != 0) then Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl,gKey,n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;
        end
      else begin
        Lib_Sel:QRecList(vHdl,'Art.Nummer>'''' AND NOT(Art.GesperrtYN)');
      end;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Charge' : begin
      if (BAG.FM.B.Artikelnr = '') then
        RETURN;

      Erx # RecLink(250,708,1,0); // Artikel holen
      if (Erx>_rlockeD) then RETURN;

      //  Warengruppe des Artikels lesen
      Erx # RecLink(819,250,10,0);
      if (Erx <> _rOK) then begin
        RecBufClear(819);
        RETURN;
      end;

      if (Wgr_data:IstMix()) then begin
        // Bei MatArt Mix Materialauswahl aufrufen
        Auswahl('Charge_Mat');

      end else begin

        RecBufClear(252);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.C.Verwaltung',here+':AusCharge');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

        vQ # '';
        Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', Art.Nummer);
        Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '=', Bag.P.Zieladresse);
        Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
        Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);



        vHdl # SelCreate(252, gKey);
        Erx # vHdl->SelDefQuery('', vQ);
        if (Erx != 0) then Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;

        Lib_GuiCom:RunChildWindow(gMDI);
      end;

    end;


    'Charge_Mat' : begin
      RecBufClear(200);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusCharge_Mat');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'Mat.Strukturnr'   , '=', Art.Nummer);
      vHdl # SelCreate(200, gKey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


  end; // CASE

end;



//========================================================================
//  sub AusArtikelnummer()
//
//========================================================================
sub AusArtikelnummer()
local begin
  vTxtHdl     : int;
  vHdl        : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    BAG.FM.B.Artikelnr # Art.Nummer;
    Bag.FM.B.Art.Charge   # '';
    BAG.FM.B.Art.Adresse  # 0;
    BAG.FM.B.Art.Anschr   # 0;
    BAG.FM.B.Materialnr   # 0;

    // ggf. bei Chargenführungsartikeln die passende Charge schon vorauswählen und
    //      dann die Auswahl deaktivieren
    _SuchePassendeCharge();

  end;
  gSelected # 0;

  RefreshIfm('edBAG.FM.B.Art.Charge');
end;

//========================================================================
//  sub AusCharge()
//
//========================================================================
sub AusCharge()
local begin
  vTxtHdl     : int;
  vHdl        : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(252,0,_RecId,gSelected);
    Bag.FM.B.Art.Charge   # Art.C.Charge.Intern;
    BAG.FM.B.Art.Adresse  # Art.C.Adressnr;
    BAG.FM.B.Art.Anschr   # Art.C.Anschriftnr;
    BAG.FM.B.Materialnr   # 0;
  end;
  gSelected # 0;

end;



//========================================================================
//  sub AusCharge_Mat()
//
//========================================================================
sub AusCharge_Mat()
local begin
  vTxtHdl     : int;
  vHdl        : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    Bag.FM.B.Art.Charge   # '';
    BAG.FM.B.Art.Adresse  # 0;
    BAG.FM.B.Art.Anschr   # 0;
    BAG.FM.B.Materialnr   # Mat.Nummer;
    Bag.FM.B.Art.Charge   # Aint(Mat.Nummer);
  end;
  gSelected # 0;

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
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  if (Mode<>c_ModeOther) and (aNoRefresh=n) then RefreshIfm();

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

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of
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
    'bt.Artikel'        :   Auswahl('Artikel');
    'bt.Charge'         :   Auswahl('Charge');
  end;

end;


//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer(
  aEvt                  : event;        // Ereignis
  aTimerId              : int;
): logic
local begin
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (gTimer2=aTimerId) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
    if (y) then begin
//      Auswahl('Positionen');
    end;
    end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
  end;

  RETURN true;
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
// sub _SuchePassendeCharge()
//    Sucht anhand des Artikels ggf. die einzig passende Charge heraus
//    und setzt diese in den Dialog ein
//========================================================================
sub _SuchePassendeCharge()
local begin
  Erx   : int;
  vQ    : alpha(4096);
  vSel  : int;
  vSelCnt : int;
end
begin
  if (Bag.FM.B.Art.Charge  <> '') then
    RETURN;

  Erx # RecLink(250,708,1,0);
  if (Erx <= _rLocked) then begin

    if ("Art.ChargenführungYN" = false) then begin

      // Chargen nur automatisch füllen, wenn es "echte" Chargen sind,
      //  nicht bei ArtMatMix
      Erx # RecLink(819,250,10,0);      //  Warengruppe des Artikels lesen
      if (Erx <> _rOK) then begin
        RecBufClear(819);
        RETURN;
      end;

      if (Wgr_Data:IstMix()) then
        RETURN;

      vQ # '';
      Lib_Sel:QAlpha(var vQ,  'Art.C.ArtikelNr'     , '=', Art.Nummer);
      Lib_Sel:QInt(var vQ,    'Art.C.Adressnr'      , '>', 0);
      Lib_Sel:QAlpha(var vQ,  'Art.C.Charge.Intern' , '>', '');
      Lib_Sel:QDate(var vQ,   'Art.C.Ausgangsdatum' , '=', 0.0.0);

      vSel # SelCreate(252, gKey);
      Erx # vSel->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vSel);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vSel,0,n);

      vSelCnt # RecInfo(252, _recCount, vSel);

      case vSelCnt of
        // Keine Charge?
        0 : begin
          // Geht "garnicht"

        end;

        // Genau eine pasasende?
        1 : begin
          Erx # RecRead(252, vSel, _recFirst);
          BAG.FM.B.ArtikelNr    # Art.C.ArtikelNr;    //  !!!ACHTUNG!!! WICHTIG ARtNr aus Charge übernehmen
          BAG.FM.B.Art.Charge   # Art.C.Charge.Intern;
          BAG.FM.B.Art.Adresse  # Art.C.Adressnr;
          BAG.FM.B.Art.Anschr   # Art.C.Anschriftnr;
          BAG.FM.B.Materialnr   # 0;

        end;

        // Mehrere Chargen zur Auswahl
        otherwise begin
          Bag.FM.B.Art.Charge   # '';
          BAG.FM.B.Art.Adresse  # 0;
          BAG.FM.B.Art.Anschr   # 0;
          BAG.FM.B.Materialnr   # 0;
        end;
      end; // Case

      SelClose(vSel);
      SelDelete(252, w_SelName);
      vSel # 0;

    end;

  end;

end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edBAG.FM.B.Artikelnr') AND (aBuf->BAG.FM.B.Artikelnr<>'')) then begin
    Art.Nummer # BAG.FM.B.Artikelnr;
    RecRead(250,1,0);
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edBAG.FM.B.Art.Charge') AND (aBuf->BAG.FM.B.Art.Charge<>'')) then begin
    Art.C.Charge.Intern # BAG.FM.B.Art.Charge;
    RecRead(252,1,0);
    Lib_Guicom2:JumpToWindow('Art.C.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================