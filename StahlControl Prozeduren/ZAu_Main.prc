@A+
//==== Business-Control ==================================================
//
//  Prozedur    ZAu_Main
//                        OHNE E_R_G
//  Info
//
//
//  23.09.2003  ST  Erstellung der Prozedur
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  03.05.2012  AI  Löschen verboten Prj.1347/80
//  08.10.2012  AI  Zahlungsarten eingebaut
//  09.01.2013  ST  Serienmarkierung für Eingangszahlungen hinzugefügt
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusZahlungsart()
//    SUB AusLieferant()
//    SUB AusWaehrung()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Lib_Nummern

define begin
  cTitle :    'Zahlungsausgänge'
  cFile :     565
  cMenuName : 'ZAu.Bearbeiten'
  cPrefix :   'ZAu'
  cZList :    $ZL.Zahlungsausgaenge
  cKey :      1
  cListen : 'Zahlungsausgänge'
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
  w_Listen # cListen;

Lib_Guicom2:Underline($edZAu.Lieferant);
Lib_Guicom2:Underline($edZAu.Zahlungsart);
Lib_Guicom2:Underline($edZAu.Whrung);

// Auswahlfelder setzen...
  SetStdAusFeld('edZAu.Lieferant'   ,'Lieferant');
  SetStdAusFeld('edZAu.Whrung'      ,'Waehrung');
  SetStdAusFeld('edZAu.Zahlungsart' ,'Zahlart');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  EvtMdiActivate
//                  MDI-Fenster erhält Focus
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  App_Main:EvtMdiActivate(aEvt);
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_ZAU;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vTmp  : int;
  Erx   : int;
end;
begin
  $Lb.ZAu.Nummer -> wpCaption # CnvAi(ZAu.Nummer);

  if (aName='') or (aName='edZAu.Lieferant') then begin
    If (ZAu.Lieferant > 0) then begin
      Adr.LieferantenNr # ZAu.Lieferant;
      Erx # RecRead(100,3,0);
      if (Erx <>_rNoRec) then begin
        $LB.Lieferantenstw->wpcaption # Adr.Stichwort;
        ZAu.LieferStichwort          # Adr.Stichwort;

        If (RecLink(814,100,1,_RecFirst) <= _rLocked) then begin
          $lb.HW1 ->  wpCaption # "Wae.Kürzel";
        end
        else
          $lb.HW1 -> wpCaption  # '';
      end
      else begin
        $Lb.Lieferantenstw->wpcaption  # '';
        ZAu.LieferStichwort       # '';
        $lb.HW1 -> wpCaption      # '';
      end;
    end;
  end;

  if (aName='') or (aName='edZAu.Whrung') then begin
    if ("ZAu.Währung" <> 0) then begin
      Wae.Nummer # "ZAu.Währung";
      if (RecRead(814,1,0) = _rOk) then begin
        $lb.Wae       ->  wpCaption # "Wae.Kürzel";
        $lb.Wae1      ->  wpCaption # "Wae.Kürzel";
        $lb.Wae2      ->  wpCaption # "Wae.Kürzel";
        "ZAu.Währungskurs" # Wae.EK.Kurs;
        $edZAu.Whrungskurs -> wpCaptionFloat # "ZAu.Währungskurs";

        ZAu.BetragW1 # ZAu.Betrag * "ZAu.Währungskurs";
        $Lb.BetragW1  ->  wpCaption # ANum(ZAu.BetragW1,2);
      end;
    end;
  end;

  if (aName='') or (aName='edZAu.Betrag') then begin
    If ("ZAu.Währungskurs" <> 0.0) then begin
      ZAu.BetragW1 # ZAu.Betrag / "ZAu.Währungskurs";
      $Lb.BetragW1  ->  wpCaption # ANum(ZAu.BetragW1,2);
    end
    else
      $Lb.BetragW1  ->  wpCaption # '';
  end;

  if (aName='') or (aNAme='edZAu.Whrungskurs')then begin
    If ("ZAu.Währungskurs" <> 0.0) then begin
      ZAu.BetragW1 # ZAu.Betrag / "ZAu.Währungskurs";
      $Lb.BetragW1  ->  wpCaption # ANum(ZAu.BetragW1,2);
    end
    else
      $Lb.BetragW1  ->  wpCaption # '';
  end;

  if (aName = '') or (aName = 'edZAu.Zahlungsart') then begin
    if (ZAu.Zahlungsart <> 0) then begin
/** 08.10.2012 AI
      case ZAu.Zahlungsart of
        1 : $Lb.Zahlungsart -> wpCaption # 'Bar';
        2 : $Lb.Zahlungsart -> wpCaption # 'Scheck';
        3 : $Lb.Zahlungsart -> wpCaption # 'Überweisung';
        otherwise $LB.Zahlungsart -> wpCaption # '';
      end;
***/
      Erx # RecLink(852,565,3,_RecFirst);   // Zahlungsart holen
      if (Erx>_rLocked) or (ZAu.Zahlungsart=0) then RecBufClear(852);
      $LB.Zahlungsart->wpcaption # ZHA.Bezeichnung;

    end
    else
      $LB.Zahlungsart -> wpCaption # '';

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
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $LB.Lieferantenstw -> wpCaption # '';
  "ZAu.Währung" # 1;

  $edZAu.Lieferant->WinFocusSet(true);
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
  if (Mode=c_ModeNew) then begin
    ZAu.Nummer # ReadNummer('Zahlungsausgang');    // Nummer lesen
    SaveNummer();                                  // Nummernkreis aktuallisiern
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

    if (gZLList<>0) then begin
      if (gZLList->wpDbSelection<>0) then begin
        App_Main:refresh(true);

      end;
    end;
//        SelRecDelete(gZLList->wpDbSelection,gfile);
//        SelRecInsert(gZLList->wpDbSelection,gfile);
  end
  else begin
    ZAu.Anlage.Datum  # today;
    ZAu.Anlage.Zeit   # Now;
    ZAu.Anlage.User   # gUsername;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (gZLList<>0) then
      if (gZLList->wpDbSelection<>0) then
        SelRecInsert(gZLList->wpDbSelection,gfile);
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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  if (RekDelete(gFile,0,'MAN')=_rOK) then begin
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
  vParent : int;
  vA    : alpha;
  vMode : alpha;
  vHdl  : int;
  vHdl2  : int;
  tText : alpha
end;

begin

  case aBereich of
    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung','ZAu_Main:AusLieferant');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Waehrung' : begin
      RecBufClear(814);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung','ZAu_Main:AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Zahlart' : begin
/**
      vHdl # WinOpen('Prg.Para.Auswahl',_WinOpenDialog);
      vHdl->wpAreaLeft    # $edZAu.Zahlungsart->wpAreaLeft+gMdi->wpAreaLeft+50;
      vHdl->wpAreaTop     # $edZAu.Zahlungsart->wpAreatop+gMdi->wpAreaTop+120;
      vHdl->wpAreaRight   # vHdl->wpAreaLeft + 200;
      vHdl->wpAreabottom  # vHdl->wpAreaTop + 180;
      vHdl->wpCaption     # 'Zahlungsart wählen...';
      vHdl2 # vHdl->WinSearch('DL.ParaAuswahl');
      // Auswahlliste füllen
      tText # 'Bar';
      vHdl2->WinLstDatLineAdd(tText,1);
      tText # 'Scheck';
      vHdl2->WinLstDatLineAdd(tText,2);
      tText # 'Überweisung';
      vHdl2->WinLstDatLineAdd(tText,3);
      vHdl->windialogrun();
      if (gSelected<>0) then
        vHdl2->WinLstCellGet(ZAu.Zahlungsart,2,gSelected);
      vHdl->WinClose();
      ZAu.Zahlungsart # gSelected;        // Auswahl sichern
      gSelected # 0;
***/

/*** 08.10.2012 AI
      Zau.Zahlungsart # cnvia(Lib_Einheiten:Popup('Zahlungsart',$edZAu.Zahlungsart,0,0,0));

      $edZAu.Zahlungsart -> wpCaptionInt # ZAu.Zahlungsart;
      case ZAu.Zahlungsart of
        1 : $Lb.Zahlungsart -> wpCaption # 'Bar';
        2 : $Lb.Zahlungsart -> wpCaption # 'Scheck';
        3 : $Lb.Zahlungsart -> wpCaption # 'Überweisung';
      end;
***/
      RecBufClear(852);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ZhA.Verwaltung',here+':AusZahlungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusZahlungsart
//
//========================================================================
sub AusZahlungsart()
begin
  if (gSelected<>0) then begin
    RecRead(852,0,_RecId,gSelected);
    // Feldübernahme
    ZAu.Zahlungsart # ZHA.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edZau.Zahlungsart->Winfocusset(false);
end;


//========================================================================
//  AusLieferant
//
//========================================================================

sub AusLieferant()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    ZAu.Lieferant # Adr.Lieferantennr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edZAu.Lieferant->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edZAu.Lieferant');

  Wae.Nummer # "Adr.Ek.Währung";

  if (RecRead(814,1,0) = _rOk) then begin
    // Wenn noch keine Währung gesetzt ist, dann HW
    if ("ZAu.Währung" = 0) then begin
      "ZAu.Währung" # "Adr.Ek.Währung";
      $lb.Wae1 -> wpCaption # "Wae.Kürzel";
      $lb.Wae2 -> wpCaption # "Wae.Kürzel";
      $lb.Wae  -> wpCaption # "Wae.Kürzel";
      RefreshIfm('edZAu.Whrung');
    end;
    $lb.HW1  -> wpCaption # "Wae.Kürzel";
  end;

end;

sub AusWaehrung()
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    // Feldübernahme
    "ZAu.Währung" # Wae.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edZAu.Whrung->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edZAu.Whrung');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZAu_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZAu_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZAu_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZAu_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_ZAu_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_ZAu_Loeschen]=n);


  vHdl # gMenu->WinSearch('Mnu.Druck.Avis');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
    or (w_Auswahlmode) or (Rechte[Rgt_ZAu_Druck_Avis]=n);
  end;
  vHdl # gMenu->WinSearch('Mnu.Druck.Scheck');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
    or (w_Auswahlmode) or (Rechte[Rgt_ZAu_Druck_Scheck]=n);
  end;


  // Markierung
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);


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
  Erx     : int;
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vMarked : int;
  vMFile  : int;
  vMId    : int;
  vOK     : logic;
  vTmp    : int;
  vRef    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Filter.Geloescht' : begin
      Filter_ZAu # !Filter_ZAu;
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_ZAu;
      if ( gZLList->wpDbSelection != 0 ) then begin
        vHdl # gZLList->wpDbSelection;
        if (SelInfo(vHdl, _SelCount) > 0) then
          vRef # _WinLstRecFromRecId
        else
          vRef # _WinLstFromFirst;
        gZLlist->wpDbSelection # 0;
        SelClose( vHdl );
        SelDelete( gFile, w_selName );
        w_selName # '';
        gZLList->WinUpdate( _winUpdOn, vRef | _winLstRecDoSelect );
        App_Main:Refreshmode();
        RETURN true;
      end;
      Lib_Sel:QRecList( 0, '"ZAu.Zahldatum" = 0.0.0' );
      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);

      App_Main:Refreshmode();
      RETURN true;
    end;


    'Mnu.Rechnungseingang' : begin
      RecBufClear(561);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ERe.Z.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Verknüpfungen umlenken
      gZLList->wpDbFileNo # 565;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Druck.Avis' : begin
      if (Rechte[Rgt_ZAu_Druck_Avis])then begin
        if(Rnd(ZAu.Betrag,2) = Rnd(ZAu.Zugeordnet,2)) then
          Lib_Dokumente:Printform(565,'Zahlungsavis',false);
      end;
    end;


    'Mnu.Druck.Scheck' : begin
      if (Rechte[Rgt_ZAu_Druck_Scheck]) then begin

        vOK # y;
        vMarked # gMarkList->CteRead(_CteFirst);
        WHILE (vMarked > 0) and (vOK) DO BEGIN
          Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);
          if (vMFile<>565) then begin
            vMarked # gMarkList->CteRead(_CteNext,vMarked);
            CYCLE;
          end;
          RecRead(565,0,_RecId,vMID);
            if (ZAu.Zahldatum<>0.0.0) then vOK # n
          vMarked # gMarkList->CteRead(_CteNext,vMarked);
        END;

        // bereits verbucht??
        if (vOK=n) then begin
          Erx # Msg(565001,'',_WinIcoWarning,_WinDialogYesNo,2);
          if (Erx<>_WinIDYes) then RETURN true;
        end;

        Erx # Msg(565002,'',_WinIcoQuestion,_WinDialogYesNo,2);
        if (Erx<>_WinIDYes) then RETURN true;

        vMarked # gMarkList->CteRead(_CteFirst);
        WHILE (vMarked > 0) DO BEGIN
          Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);
          if (vMFile<>565) then begin
            vMarked # gMarkList->CteRead(_CteNext,vMarked);
            CYCLE;
          end;
          RecRead(565,0,_RecId,vMID);

          Lib_Dokumente:Printform(565,'Scheck',false);

          vMarked # gMarkList->CteRead(_CteNext,vMarked);
        END;

        // verbuchen???
        Erx # Msg(565003,'',_WinIcoQuestion,_WinDialogYesNo,2);
        if (Erx<>_WinIDYes) then RETURN true;

        vMarked # gMarkList->CteRead(_CteFirst);
        WHILE (vMarked > 0) DO BEGIN
          Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);
          if (vMFile<>565) then begin
            vMarked # gMarkList->CteRead(_CteNext,vMarked);
            CYCLE;
          end;
          RecRead(565,0,_RecId,vMID);

          RecRead(565,1,_recLock);
          ZAu.Zahldatum # today;
          RekReplace(565,_recUnlock,'AUTO');

          vMarked # gMarkList->CteRead(_CteNext,vMarked);

          // Marker weg...
          Lib_Mark:MarkAdd(565, n, y);

        END;


      end;
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, ZAu.Anlage.Datum, ZAu.Anlage.Zeit, ZAu.Anlage.User );
    end;

    'Mnu.Mark.Sel' : begin
      ZAu_Mark_Sel();
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
    'bt.Lieferant' :   Auswahl('Lieferant');
    'bt.Waehrung' :   Auswahl('Waehrung');
    'bt.Zahlart'  :   Auswahl('Zahlart');
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
  if (aMark=n) then begin
    if (ZAu.Zahldatum<>0.0.0) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
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
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edZAu.Lieferant') AND (aBuf->ZAu.Lieferant<>0)) then begin
    RekLink(100,565,2,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edZAu.Zahlungsart') AND (aBuf->ZAu.Zahlungsart<>0)) then begin
    RekLink(852,565,3,0);   // Zahlungsart holen
    Lib_Guicom2:JumpToWindow('ZhA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edZAu.Whrung') AND (aBuf->"ZAu.Währung"<>0)) then begin
    Wae.Nummer # "ZAu.Währung";
    RecRead(814,1,0);
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================