@A+
//==== Business-Control ==================================================
//
//  Prozedur    Vsd_P_Main
//                    OHNE E_R_G
//  Info
//
//
//  06.07.2009  AI  Erstellung der Prozedur
//  11.12.2012  AI  NEU: Makrierte Pooleinträge einfügen
//  12.11.2021  AH  ERX
//  26.04.2022  AH  für Pakete
//  26.07.2022  HA  Quick Jump
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
//    SUB Auswahl(aBereich : alpha)
//    SUB AusPool()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtDropEnter(	aEvt : event;	aDataObject : int;aEffect : int) : logic
//    SUB EvtDrop(aEvt : event;	aDataObject : int;aDataPlace : int; aEffect : int;aMouseBtn : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle      : 'Versand-Positionen'
  cFile       :  651
  cMenuName   : 'Vsd.P.Bearbeiten'
  cPrefix     : 'Vsd_P'
  cZList      : $ZL.Vsd.Positionen
  cKey        : 1
  cListen : '';
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
  w_Listen  # cListen;

Lib_Guicom2:Underline($edVsd.P.Poolnr);

  // Auswahlfelder setzen...
  SetStdAusFeld('edVsd.P.Poolnr', 'Pool');

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
  Lib_GuiCom:Pflichtfeld($edVsd.P.Poolnr);
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
  vA    : alpha;
  vTmp  : int;
end;
begin

  if (aName='') then begin
    if (Vsd.P.Nummer>0) and (Vsd.P.Nummer<1000000000) then
      $lbVsd.P.Nummer->wpcaption # AInt(Vsd.P.Nummer)
    else
      $lbVsd.P.Nummer->wpcaption # '';
  end;

  // MS 08.04.2010 da sonst "keine" Verbindung zum Pool besteht
  Erx # RecLink(655, 651, 2, _recFirst);   // Pool holen
  if(Erx > _rLocked) then begin
    Erx # RecLink(656, 651, 3, _recFirst); // ~Pool holen
    if(Erx > _rLocked) then
      RecBufClear(656);
    RecBufCopy(656, 655);
  end;


  $lb.Sum.Gewicht->wpcaption # aNum(Vsd.Positionsgewicht,Set.Stellen.Gewicht);

  if (aName='') or ((aName='edVsd.P.Poolnr') and (aChanged or $edVsd.P.Poolnr->wpchanged)) then begin
    if (Mode=c_modeedit) or (Mode=c_ModeView) then begin
      VsP.Menge.In.Rest   # VsP.Menge.In.Rest + VsD.P.Menge.In;
      VsP.Menge.Out.Rest  # VsP.Menge.Out.Rest + VsD.P.Menge.Out;
      "VsP.Stück.Rest"    # "VsP.Stück.Rest" + "VsD.P.Stück";;
      VsP.Gewicht.Rest    # VsP.Gewicht.Rest + VsD.P.Gewicht;
    end;
    $lb.Pool.In->wpcaption      # ANum(VsP.Menge.IN.Rest, Set.STellen.Menge);
    $lb.Pool.Out->wpcaption     # ANum(VsP.Menge.Out.Rest, Set.STellen.Menge);
    $lb.Pool.Stk->wpcaption     # AInt("VsP.Stück.Rest");
    $lb.Pool.Gew->wpcaption     # ANum(VsP.Gewicht.Rest, Set.STellen.Gewicht)
    $lb.Pool.MEH.In->wpcaption  # VsP.MEH.In;
    $lb.Pool.MEH.Out->wpcaption # VsP.MEH.Out;
    if ((aName='edVsd.P.Poolnr') and (aChanged or $edVsd.P.Poolnr->wpchanged)) then begin
      Vsd.P.MEH.In    # VsP.MEH.In;
      Vsd.P.MEH.Out   # VsP.MEH.Out;
      Vsd.P.Menge.In  # VsP.Menge.In.Rest;
      Vsd.P.Menge.Out # VsP.Menge.Out.Rest;
      "Vsd.P.Stück"   # "VsP.Stück.Rest";
      Vsd.P.Gewicht   # VsP.Gewicht.Rest;
      $lb.MEH.In->winupdate(_WinUpdFld2Obj);
      $lb.MEH.Out->winupdate(_WinUpdFld2Obj);
      $edVsd.P.Menge.In->winupdate(_WinUpdFld2Obj);
      $edVsd.P.Menge.Out->winupdate(_WinUpdFld2Obj);
      $edVsd.P.Stck->winupdate(_WinUpdFld2Obj);
      $edVsd.P.Gewicht->winupdate(_WinUpdFld2Obj);
    end;

    // Felder sperren...
    if (Mode=c_modenew) then begin
      if (VsP.Materialnr<>0) or (VsP.Paketnr<>0) then begin
        Lib_GuiCom:Disable($edVsd.P.Menge.In);
        Lib_GuiCom:Disable($edVsd.P.Menge.Out);
        Lib_GuiCom:Disable($edVsd.P.Stck);
        Lib_GuiCom:Disable($edVsd.P.Gewicht);
      end
      else begin
        Lib_GuiCom:Enable($edVsd.P.Menge.In);
        Lib_GuiCom:Enable($edVsd.P.Menge.Out);
        Lib_GuiCom:Enable($edVsd.P.Stck);
        Lib_GuiCom:Enable($edVsd.P.Gewicht);
      end;
    end;

    // Materialinfos...
    if (VsP.Materialnr<>0) then begin
      $lb.Materialtitel->wpcaption  # Translate('Material');
      vA # AInt(VsP.Materialnr);
      Erx # RecLink(200,655,2,_recFirst);   // Material holen
      if (Erx>_rLocked) then begin
        vA # ' '+Translate('NICHT GEFUNDEN');
      end
      else begin
        vA # vA + '     ' + ANum(Mat.Dicke, Set.Stellen.Dicke);
        vA # vA + ' x ' + ANum(Mat.Breite, Set.Stellen.Breite);
        if ("Mat.Länge"<>0.0) then
          vA # vA + ' x ' + ANum("Mat.Länge", "Set.Stellen.Länge");
      end;
    end
    else begin
    // Artikelinfos...
      $lb.Materialtitel->wpcaption  # Translate('Artikel');
      vA # VsP.Artikelnr;
      Erx # RecLink(252,655,3,_recFirst);     // Charge holen
      if (Erx>_rLocked) then begin
        vA # ''
      end
      else begin
        Erx # RecLink(250,252,1,_recFirst);   // Artikel holen
        if (Erx>_rLocked) then
          vA # '' //' '+Translate('NICHT GEFUNDEN')
        else
          vA # vA + '     ' + Art.Stichwort;
      end;
    end;

    $lb.Materialinfo->wpcaption   # vA;
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
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  if (Mode=c_ModeNew) then begin
    Vsd.P.Nummer          # Vsd.Nummer;
    Vsd.P.Position        # 1;
    Vsd.P.Verladetermin   # today;
    Vsd.P.Verladezeit     # now;
  end;

  // Focus setzen auf Feld:
  if (Mode=c_ModeNew) then
    $edVsd.P.Poolnr->WinFocusSet(true)
  else
    $edVsd.P.Reihenfolge->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
  vOK : logic;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung

  // Selbstabholer dürfen nur eigenes Material holen und das muss VON und NACH eigene Firma gehen
  if (Vsd.SelbstabholKdNr<>0) then begin
    Erx # RecLink(655,651,2,_recFirst);   // Pool holen
    if (Erx<=_rLocked) then begin
// 15.11.2021 AH: andere Prüfung z.B. HWE
//debugx(VsP.Vorgangstyp+'; '+aint(VsP.AuftragsKundennr)+'<>'+aint(Vsd.SelbstabholKdNr)+' or '+aint(VsP.Start.Adresse)+'<>'+aint(VsP.Ziel.Adresse)+' or '+aint(VsP.Start.Adresse)+'<>'+aint(Set.EigeneAdressnr));
//      if (VsP.Vorgangstyp=c_VSPTyp_BAG) or
//        (VsP.AuftragsKundennr<>Vsd.SelbstabholKdNr) or
//        (VsP.Start.Adresse<>VsP.Ziel.Adresse) or (VsP.Start.Adresse<>Set.EigeneAdressnr) then begin
      vOK # (VsP.Materialnr<>0) and (VsP.AuftragsKundennr=Vsd.SelbstabholKdNr);
      if (vOK) then begin
        Erx # RecLink(401,655,10,_recFirst);    // Auftragspos holen
        if (Erx<=_rLocked) then begin
          vOK # (VsP.Ziel.Adresse=Auf.Lieferadresse);
          if (vOK) then begin
            vOK # (VsP.Start.Adresse=Set.EigeneAdressnr) or (VsP.Start.Adresse=Auf.Lieferadresse);
          end;
        end;
      end;
      if (vOK=false) then begin
        Msg(651000,Vsd.SelbstabholSW,0,0,0);
        $NB.Main->wpcurrent # 'NB.Page1';
        $edVsd.P.Poolnr->WinFocusSet(true);
        RETURN false;
      end;
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
    PtD_Main:Compare(gFile);
  end
  else begin

    // durchnummerieren...
    WHILE (RecRead(651,1,_recTest)<=_rLocked) do
      Vsd.P.Position  # Vsd.P.Position + 1;

    TRANSON;

    //Vsd.p.Anlage.Datum  # Today;
    //Vsd.p.Anlage.Zeit   # Now;
    //Vsd.p.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Verbuchen....
    Erx # RecLink(655,651,2,_recFirst);   // Pool holen
    if (Erx>=_rLockeD) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    RecRead(655,1,_recLock);
    VsP.Menge.In.Rest   # VsP.Menge.In.Rest - VsD.P.Menge.In;
    VsP.Menge.Out.Rest  # VsP.Menge.Out.Rest - VsD.P.Menge.Out;
    "VsP.Stück.Rest"    # "VsP.Stück.Rest" - "VsD.P.Stück";;
    VsP.Gewicht.Rest    # VsP.Gewicht.Rest - VsD.P.Gewicht;
    Erx # RekReplace(655,_RecUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN false;
    end;

    RecRead(650,1,_recLock);
    Vsd.Positionsgewicht # Vsd.Positionsgewicht + VsD.P.Gewicht;
    RekReplace(650,_RecUnlock,'AUTO');

    TRANSOFF;
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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    Erx # RecLink(655,651,2,_recFirst);   // Pool holen
    if (Erx>_rLocked) then RETURN;

    TRANSON;

    RecRead(655,1,_recLock);
    VsP.Menge.In.Rest   # VsP.Menge.In.Rest + VsD.P.Menge.In;
    VsP.Menge.Out.Rest  # VsP.Menge.Out.Rest + VsD.P.Menge.Out;
    "VsP.Stück.Rest"    # "VsP.Stück.Rest" + "VsD.P.Stück";;
    VsP.Gewicht.Rest    # VsP.Gewicht.Rest + VsD.P.Gewicht;
    Erx # RekReplace(655,_RecUnlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;

    Erx # RekDelete(gFile,0,'MAN');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;

    RecRead(650,1,_recLock);
    Vsd.Positionsgewicht # Vsd.Positionsgewicht - VsD.P.Gewicht;
    RekReplace(650,_RecUnlock,'AUTO');

    TRANSOFF;
    Refreshifm();
  end;

  RETURN;
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

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  if (aEvt:Obj->wpname='edVsd.P.Poolnr') and ($edVsd.P.Poolnr->wpchanged) then begin
    Erx # RecLink(655,651,2,_recFirst);   // Pool holen
    if (Erx>_rLocked) then RecBufClear(655);
    if (VsP.Materialnr<>0) then $edVsd.P.Reihenfolge->winfocusset(true);

    // logische Prüfung von Verknüpfungen
//    RefreshIfm(aEvt:Obj->wpName, y);
//    RETURN true;
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
end;

begin

  case aBereich of
    'Pool' : begin
      RecBufClear(655);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VsP.Verwaltung',here+':AusPool');
      //ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusPool
//
//========================================================================
sub AusPool()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(655,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Vsd.P.Poolnr # VsP.Nummer;

    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edVsd.P.Poolnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edVsd.P.Poolnr',y);
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

  $lb.Sum.Gewicht->wpcaption # aNum(Vsd.Positionsgewicht,Set.Stellen.Gewicht);

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Anlegen]=n) or ("Vsd.Löschmarker"<>'');
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Anlegen]=n) or ("Vsd.Löschmarker"<>'');

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Aendern]=n) or ("Vsd.Löschmarker"<>'');
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Aendern]=n) or ("Vsd.Löschmarker"<>'');

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Loeschen]=n) or ("Vsd.Löschmarker"<>'');
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Loeschen]=n) or ("Vsd.Löschmarker"<>'');

  vHdl # gMenu->WinSearch('Mnu.Ins.Kommission');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Anlegen]=n) or ("Vsd.Löschmarker"<>'');
  vHdl # gMenu->WinSearch('Mnu.Ins.VsP.Mark');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Anlegen]=n) or ("Vsd.Löschmarker"<>'');



/*
  vHdl # gMenu->WinSearch('Mnu.Ins.Workbench');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Vsd_Anlegen]=n) or ("Vsd.Löschmarker"<>'');
*/
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
  Erx   : int;
  vHdl  : int;
  vA    : alpha;
  vB    : alpha;
  vAuf  : int;
  vPos  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Ins.VsP.Mark' : begin
      if (Msg(651001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes) then begin
        Erx # VsD_Data:PoolMarkToVersandPos();
        if (Erx=_rOK) then Msg(999998,'',0,0,0)
        else Msg(Erx,'',0,0,0);
      end;
      if (Mode=c_modeList) then
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst|_WinLstRecDoSelect);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);//,xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
    end;

/*
    'Mnu.Ins.Workbench' : begin
todo('X');
      vHdl # $DL.Workbench;
      if (vHdl->wpcurrentint<>0) then
        vHdl->WinLstDatLineRemove(_WinLstDatLineCurrent);

RETURN true;

      TRANSON;

      Erx # RecRead(655,6,0);   // Pool holen
      WHILE (Erx<_rNorec) and (VsP.Auftragsnr=vAuf) and
          ((VsP.Auftragspos=vPos) or (vPos=0)) do begin

        // Selbstabholer dürfen nur eigenes Material holen und das muss VON und NACH eigene Firma gehen
        if (Vsd.SelbstabholKdNr<>0) then begin
          if (VsP.AuftragsKundennr<>Vsd.SelbstabholKdNr) or
            (VsP.Start.Adresse<>VsP.Ziel.Adresse) or (VsP.Start.Adresse<>Set.EigeneAdressnr) then begin
            Erx # RecRead(655,6,_RecNext);
            CYCLE;
          end;
        end;

        Vsd.P.Verladetermin   # today;
        Vsd.P.Verladezeit     # now;
        Vsd.P.Poolnr          # VsP.Nummer;
        Vsd.P.MEH.In          # VsP.MEH.In;
        Vsd.P.MEH.Out         # VsP.MEH.Out;
        Vsd.P.Menge.In        # VsP.Menge.In.Rest;
        Vsd.P.Menge.Out       # VsP.Menge.Out.Rest;
        "Vsd.P.Stück"         # "VsP.Stück.Rest";
        Vsd.P.Gewicht         # VsP.Gewicht.Rest;

        REPEAT
          Erx # RekInsert(gFile,0,'MAN');
          if (Erx<>_rOK) then Vsd.P.Position # Vsd.P.Position + 1;
        UNTIl (erx=_rOK);

        // Verbuchen....
        RecRead(655,1,_recLock);
        VsP.Menge.In.Rest   # VsP.Menge.In.Rest - VsD.P.Menge.In;
        VsP.Menge.Out.Rest  # VsP.Menge.Out.Rest - VsD.P.Menge.Out;
        "VsP.Stück.Rest"    # "VsP.Stück.Rest" - "VsD.P.Stück";;
        VsP.Gewicht.Rest    # VsP.Gewicht.Rest - VsD.P.Gewicht;
        Erx # RekReplace(655,_RecUnlock,'AUTO');
        if (erx<>_rOK) then begin
          TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN false;
        end;

        Erx # RecRead(655,6,_RecNext);
      END;

      TRANSOFF;

      if (Mode=c_modeList) then
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst|_WinLstRecDoSelect);
    end;
  */

    'Mnu.Ins.Kommission' : begin
      if (Dlg_Standard:Standard(Translate('Auftrag'),var vA)=false) then RETURN false;
      if (StrFind(vA,'/',0)=0) then begin
        vAuf  # Cnvia(vA);
        vPos # 0;
      end
      else begin
        vB    # Str_Token(vA,'/',1);
        vAuf  # Cnvia(vB);
        vB    # Str_Token(vA,'/',2);
        vPos  # Cnvia(vB);
      end;

      RecBufClear(655);
      VsP.Auftragsnr # vAuf;
      if (vPos<>0) then VsP.AuftragsPos # vPos;

      TRANSON;

      Erx # RecRead(655,6,0);   // Pool holen
      WHILE (Erx<_rNorec) and (VsP.Auftragsnr=vAuf) and
          ((VsP.Auftragspos=vPos) or (vPos=0)) do begin

        // Selbstabholer dürfen nur eigenes Material holen und das muss VON und NACH eigene Firma gehen
        if (Vsd.SelbstabholKdNr<>0) then begin
          if (VsP.AuftragsKundennr<>Vsd.SelbstabholKdNr) or
            (VsP.Start.Adresse<>VsP.Ziel.Adresse) or (VsP.Start.Adresse<>Set.EigeneAdressnr) then begin
            Erx # RecRead(655,6,_RecNext);
            CYCLE;
          end;
        end;

        if (Vsd_Data:VsPtoVsdP()=false) then begin
          TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN false;
        end;

        Erx # RecRead(655,6,_RecNext);
      END;

      TRANSOFF;

      if (Mode=c_modeList) then
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst|_WinLstRecDoSelect);
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
    'bt.Pool'   :   begin
      Auswahl('Pool');
      //todo(aInt(Vsd.P.nummer)+'   '+cnvad(vsd.P.verladetermin)+'   '+aNum(Vsd.P.Menge.In,0));
    end;//Auswahl('Pool');
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
  Gv.Alpha.01 # ANum(VsD.P.Menge.In, Set.Stellen.Menge)+' '+VsD.P.MEH.In;
  Gv.Alpha.02 # ANum(VsD.P.Menge.Out, Set.Stellen.Menge)+' '+VsD.P.MEH.Out;

  GV.Alpha.03 # '';
  if(VsP.Materialnr <> 0) then begin
    Lib_Strings:Append(var GV.Alpha.03, ANum("Mat.Dicke", Set.Stellen.Dicke), ' x ');
    Lib_Strings:Append(var GV.Alpha.03, ANum("Mat.Breite", Set.Stellen.Breite), ' x ');
    if("Mat.Länge" <> 0.0) then
      Lib_Strings:Append(var GV.Alpha.03, ANum("Mat.Länge", "Set.Stellen.Länge"), ' x ');
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
begin
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
    if (vFile=655) then begin
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
  vA      : alpha;
  vFile   : int;
  vID     : int;
  vPos    : int;
end;
begin

  // bereits verbucht? -> ENDE
  if ("Vsd.Löschmarker"<>'') then RETURN false;
  if (Rechte[Rgt_Vsd_Anlegen]=n) then RETURN false;

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    if (vID=0) then RETURN false;

    case vFile of

      655 : begin
        //Winfocusset( WinInfo(aEvt:obj, _WinFrame) );
        WinUpdate(WinInfo(aEvt:obj, _WinFrame), _WinUpdActivate );
        RecRead(vFile,0,_RecId,vID);    // Satz holen


        if (Vsd.SelbstabholKdNr<>0) then begin
          if (VsP.AuftragsKundennr<>Vsd.SelbstabholKdNr) or
            (VsP.Start.Adresse<>VsP.Ziel.Adresse) or (VsP.Start.Adresse<>Set.EigeneAdressnr) then begin
            Msg(651000,Vsd.SelbstabholSW,0,0,0);
            RETURN false;
          end;
        end;


        RecBufClear(651);
        Vsd.P.Nummer          # Vsd.Nummer;
        Vsd.P.Position        # 1;
        Vsd.P.Verladetermin   # today;
        Vsd.P.Verladezeit     # now;
        Vsd.P.Poolnr          # VsP.Nummer;
        Vsd.P.MEH.In    # VsP.MEH.In;
        Vsd.P.MEH.Out   # VsP.MEH.Out;
        Vsd.P.Menge.In  # VsP.Menge.In.Rest;
        Vsd.P.Menge.Out # VsP.Menge.Out.Rest;
        "Vsd.P.Stück"   # "VsP.Stück.Rest";
        Vsd.P.Gewicht   # VsP.Gewicht.Rest;

        // durchnummerieren...
        WHILE (RecRead(651,1,_recTest)<=_rLocked) do
          Vsd.P.Position  # Vsd.P.Position + 1;
        RekInsert(651,0,'MAN');

        // Verbuchen....
        RecRead(655,1,_recLock);
        VsP.Menge.In.Rest   # VsP.Menge.In.Rest - VsD.P.Menge.In;
        VsP.Menge.Out.Rest  # VsP.Menge.Out.Rest - VsD.P.Menge.Out;
        "VsP.Stück.Rest"    # "VsP.Stück.Rest" - "VsD.P.Stück";;
        VsP.Gewicht.Rest    # VsP.Gewicht.Rest - VsD.P.Gewicht;
        RekReplace(655,_RecUnlock,'AUTO');
        RecRead(650,1,_recLock);
        Vsd.Positionsgewicht # Vsd.Positionsgewicht + VsD.P.Gewicht;
        RekReplace(650,_RecUnlock,'AUTO');

        cZList->WinUpdate(_WinUpdOn, _WinLstFromFirst|_WinLstRecDoSelect);

        RETURN true;
      end;
    end;

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

  if ((aName =^ 'edVsd.P.Poolnr') AND (aBuf->Vsd.P.Poolnr<>0)) then begin
    RekLink(655,651,2,0);   // Poolnummer holen
    Lib_Guicom2:JumpToWindow('VsP.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================