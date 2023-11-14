@A+
//==== Business-Control ==================================================
//
//  Prozedur    ZEi_Main
//                OHNE E_R_G
//  Info
//
//
//  23.09.2003  ST  Erstellung der Prozedur
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  08.10.2012  AI  Ausgrauen/löschen nur wenn AUCH Zahldatum gesetzt ist
//  18.12.2012  ST  auch gelöschte Einträge markierbar
//  09.01.2013  ST  Serienmarkierung für Eingangszahlungen hinzugefügt
//  18.02.2013  AI  Zahlunsart Prüfung
//  10.06.2014  AH  Fix: Währungskurs und Umrechnungen
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
//    SUB AusKunde()
//    SUB AusWaehrung()
//    SUB AusZahlungsart()
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
  cTitle :    'Zahlungseingänge'
  cFile :     465
  cMenuName : 'ZEi.Bearbeiten'
  cPrefix :   'ZEi'
  cZList :    $ZL.Zahlungseingang
  cKey :      1
  cListen : 'Zahlungseingänge'
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

Lib_Guicom2:Underline($edZEi.Kundennummer);
Lib_Guicom2:Underline($edZEi.Zahlungsart);
Lib_Guicom2:Underline($edZEi.Whrung);

  // Auswahlfelder setzen...
  SetStdAusFeld('edZEi.Kundennummer' ,'Kunde');
  SetStdAusFeld('edZEi.Whrung'       ,'Waehrung');
  SetStdAusFeld('edZEi.Zahlungsart'  ,'Zahlart');

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
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_Zei;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  $Lb.ZEiNummer -> wpCaption # CnvAi(ZEi.Nummer);

  if (aName='') or (aName='edZEi.Kundennummer') then begin
    If (ZEi.Kundennummer > 0) then begin
      Adr.Kundennr  # ZEi.Kundennummer;
      Erx # RecRead(100,2,0);
      if (Erx <>_rNoRec) then begin
        $Lb.Kundenstw->wpcaption # Adr.Stichwort;
        ZEi.KundenStichwort      # Adr.Stichwort;
      end
      else begin
        $Lb.Kundenstw->wpcaption  # '';
        ZEi.KundenStichwort       # '';
        $lb.HW1 -> wpCaption      # '';
      end;
    end;
  end;

  if (aName='') or (aName='edZEi.Whrung') then begin
    Erx # RekLink(814,465,4,_recFirst); // Währung holen
    if (aChanged) or ($edZei.Whrung->wpchanged) then begin
      if (Erx<=_rLocked) then begin
        "Zei.Währungskurs" # Wae.VK.Kurs;
        $edZEi.Whrungskurs -> winupdate(_WinUpdFld2Obj);
      end;
    end;
    $lb.Wae       ->  wpCaption # "Wae.Kürzel";
    $lb.Wae1      ->  wpCaption # "Wae.Kürzel";
    $lb.Wae2      ->  wpCaption # "Wae.Kürzel";
//        "ZEi.Währungskurs" # Wae.EK.Kurs;
//        $edZEi.Whrungskurs -> wpCaptionFloat # "ZEi.Währungskurs";
    If ("ZEi.Währungskurs" <> 0.0) then
      ZEi.BetragW1 # Rnd(ZEi.Betrag / "ZEi.Währungskurs",2);
    $Lb.BetragW1->winupdate(_WinUpdFld2Obj);
//        $Lb.BetragW1  ->  wpCaption # ANum(ZEi.BetragW1,2);
  end;

  if (aName='') or (aName='edZEi.Betrag') then begin
    If ("ZEi.Währungskurs" <> 0.0) then begin
      ZEi.BetragW1 # Rnd(ZEi.Betrag / "ZEi.Währungskurs" ,2);
      $Lb.BetragW1  ->  wpCaption # ANum(ZEi.BetragW1,2);
    end
    else
      $Lb.BetragW1  ->  wpCaption # '';
  end;

  if (aName='') or (aNAme='edZEi.Whrungskurs')then begin
    If ("ZEi.Währungskurs" <> 0.0) then begin
      ZEi.BetragW1 # Rnd(ZEi.Betrag / "ZEi.Währungskurs" ,2);
      $Lb.BetragW1  ->  wpCaption # ANum(ZEi.BetragW1,2);
    end
    else
      $Lb.BetragW1  ->  wpCaption # '';
  end;

  if (aName = '') or (aName = 'edZEi.Zahlungsart') then begin
/*
    if (ZEi.Zahlungsart <> 0) then begin
      case ZEi.Zahlungsart of
        1 : $Lb.Zahlungsart -> wpCaption # 'Bar';
        2 : $Lb.Zahlungsart -> wpCaption # 'Scheck';
        3 : $Lb.Zahlungsart -> wpCaption # 'Überweisung';
        otherwise $LB.Zahlungsart -> wpCaption # '';
      end;
    end else
      $LB.Zahlungsart -> wpCaption # '';
*/
    Erx # RecLink(852,465,3,_RecFirst);   // Zahlungsart holen
    if (Erx>_rLocked) or (ZEi.Zahlungsart=0) then RecBufClear(852);
    $LB.Zahlungsart->wpcaption # ZhA.Bezeichnung;
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
  $Lb.Kundenstw -> wpCaption # '';
  $lb.Wae       -> wpCaption # '';
  $lb.Wae1      -> wpCaption # '';
  $lb.Wae2      -> wpCaption # '';
  $lb.HW1       -> wpCaption # '';

  if (Mode=C_ModeNEw) then begin
    Zei.Zahldatum # today;
    "Zei.Währung" # 1;
    "Zei.Währungskurs" # 1.0;
  end;

  $edZEi.Kundennummer->WinFocusSet(true);
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
  if (Zei.Zahlungsart<>0) then begin
    Erx # RekLink(852,465,3,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Zahlungsart'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edZEi.Zahlungsart->WinFocusSet(true);
      RETURN false;
    end;
  end;


  // Nummernvergabe
  if (Mode=c_ModeNew) then begin
    ZEi.Nummer # ReadNummer('Zahlungseingang');    // Nummer lesen
    if (ZEi.Nummer=0) then RETURN false;
    SaveNummer();                                  // Nummernkreis aktuallisiern
  end;

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);

    if (gZLList<>0) then
      if (gZLList->wpDbSelection<>0) then
        App_Main:refresh(true);

  end
  else begin
    ZEi.Anlage.Datum  # today;
    ZEi.Anlage.Zeit   # Now;
    ZEi.Anlage.User   # gUsername;
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

  // Zuordnungen vorhanden?
  // if (RecLink(461,465,1,_RecCount)>0) then begin
  //   RETURN;
  // end;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  if (RekDelete(gFile,0,'MAN')=_ROK) then begin
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
  vA    : alpha;
  vHdl  : int;
  vHdl2  : int;
  tText : alpha
end;

begin

  case aBereich of
    'Kunde' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Waehrung' : begin
      RecBufClear(814);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung',here+':AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Zahlart' : begin
      RecBufClear(852);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ZhA.Verwaltung',here+':AusZahlungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    ZEi.Kundennummer  # Adr.Kundennr;
    "Zei.Währung"     # "Adr.Ek.Währung";
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edZEi.Kundennummer->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edZEi.Kundennummer');
  RefreshIfm('edZEi.Whrung', true);

end;


//========================================================================
//  AusWaehrung
//
//========================================================================
sub AusWaehrung()
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    // Feldübernahme
    "ZEi.Währung"       # Wae.Nummer;
    "ZEi.Währungskurs"  # Wae.VK.Kurs;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edZEi.Whrung->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edZEi.Whrung', true);
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
    ZEi.Zahlungsart # ZHA.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edZei.Zahlungsart->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZEi_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZEi_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZEi_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZEi_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZEi_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ZEi_Loeschen]=n);

  vHdl # gMdi->WinSearch('Mnu.Vorkasse');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_ZEi_Vorkasse]=n);


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
  vTmp    : int;
  vRef    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Filter.Geloescht' : begin
      Filter_ZEi # !Filter_ZEi;
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_ZEi;

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
      Lib_Sel:QRecList( 0, '"ZEi.Zugeordnet" < "ZEi.Betrag" OR ("ZEi.Zahldatum"=0.0.0)' );
      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      App_Main:Refreshmode();
      RETURN true;
    end;


    'Mnu.Vorkasse' : begin
      Dlg_Vorkasse:Starten(1);
    end;


    'Mnu.OffenePosten' : begin
      RecRead(465,1,_recLock);
      ZEi.Zugeordnet    # 0.0;
      ZEi.ZugeordnetW1  # 0.0;
      Erx # RecLink(461,465,1,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        ZEi.Zugeordnet    # Rnd(ZEi.Zugeordnet + OfP.Z.Betrag,2);
        ZEi.ZugeordnetW1  # Rnd(ZEi.ZugeordnetW1 + OfP.Z.BetragW1,2);
        Erx # RecLink(461,465,1,_recNext);
      END;
      RekReplace(465,_recUnlock,'AUTO');

      RecBufClear(461);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'OfP.Z.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // Verknüpfungen umlenken
      gZLList->wpDbFileNo # 465;
      Lib_GuiCom:RunChildWindow(gMDI);
//      gZLList->WinFocusSet(true);
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, ZEi.Anlage.Datum, ZEi.Anlage.Zeit, ZEi.Anlage.User );
    end;

    'Mnu.Mark.Sel' : begin
      ZEi_Mark_Sel();
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
    'bt.Kunde'    :   Auswahl('Kunde');
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
  GV.Num.01 # Zei.Betrag - Zei.Zugeordnet;
  GV.Num.02 # Zei.BetragW1 - Zei.ZugeordnetW1;

  if (aMark = false) then begin   // ST 2012-12-18: auch gelöschte Einträge markierbar
    if (ZEi.Zugeordnet>=Zei.Betrag) and (Zei.Zahldatum<>0.0.0) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
  end;

//  else
//    Lib_GuiCom:ZLColorLine(gZLList,_WinColWhite);



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

  if ((aName =^ 'edZEi.Kundennummer') AND (aBuf->ZEi.Kundennummer<>0)) then begin
    RekLink(100,465,2,0);   // Kundennummer holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edZEi.Zahlungsart') AND (aBuf->ZEi.Zahlungsart<>0)) then begin
    RekLink(852,465,3,0);   // Zahlungsart holen
    Lib_Guicom2:JumpToWindow('ZhA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edZEi.Whrung') AND (aBuf->"ZEi.Währung"<>0)) then begin
    Wae.Nummer # "ZEi.Währung";
    RecRead(814,1,0);
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;

end;
//========================================================================
//========================================================================
//========================================================================
//========================================================================