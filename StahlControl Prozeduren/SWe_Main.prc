@A+
//==== Business-Control ==================================================
//
//  Prozedur    SWe_Main
//                  OHNE E_R_G
//  Info
//
//
//  18.09.2007  AI  Erstellung der Prozedur
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  23.11.2017  ST  Edit: Umstellung Positionsanzeige auf Selektion
//  04.02.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLieferant()
//    SUB AusErzeuger()
//    SUB AusSpediteur()
//    SUB AusVersandart()
//    SUB AusUrsprungsland()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Sammelwareneingänge'
  cFile       :  620
  cMenuName   : 'SWe.Bearbeiten'
  cPrefix     : 'SWe'
  cZList      : $ZL.SWE
  cKey        : 1
  cListen     : 'Sammelwareneingang'
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

Lib_Guicom2:Underline($edSWe.Lieferant);
Lib_Guicom2:Underline($edSWe.Versandart);
Lib_Guicom2:Underline($edSWe.Spediteur);
Lib_Guicom2:Underline($edSWe.Erzeuger);
Lib_Guicom2:Underline($edSWe.Ursprungsland);

  // Auswahlfelder setzen...
  SetStdAusFeld('edSWe.Lieferant'      ,'Lieferant');
  SetStdAusFeld('edSWe.Erzeuger'       ,'Erzeuger');
  SetStdAusFeld('edSWe.Spediteur'      ,'Spediteur');
  SetStdAusFeld('edSWe.Versandart'     ,'Versandart');
  SetStdAusFeld('edSWe.Ursprungsland'  ,'Ursprungsland');

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
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_SWE;
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
  Lib_GuiCom:Pflichtfeld($edSWe.Lieferant);
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
  Erx     : int;
  vTmp    : int;
end;
begin

  if (aName='') or (aName='edSWe.Lieferant') then begin
    RecBufClear(100);
    if (SWe.Lieferant<>0) then begin
      Erx # RecLink(100,620,2,0);
      if (Erx>_rLocked) then RecBufClear(100);
    end;
    SWe.LieferantenSW # Adr.Stichwort
    $lb.Lieferant->WinUpdate(_WinUpdFld2Obj);
  end;

  if (aName='') or (aName='edSWe.Versandart') then begin
    Erx # RecLink(817,620,5,0);
    if (Erx<=_rLocked) then
      $lb.Versandart->wpcaption # VSa.Bezeichnung.L1
    else
      $lb.Versandart->wpcaption # '';
  end;

  if (aName='') or (aName='edSWe.Spediteur') then begin
    Erx # RecLink(100,620,3,0);
    if (Erx<=_rLocked) then
      $lb.Spediteur->wpcaption # Adr.Stichwort
    else
      $lb.Spediteur->wpcaption # '';
  end;

  if (aName='') or (aName='edSWe.Erzeuger') then begin
    Erx # RecLink(100,620,4,0);
    if (Erx<=_rLocked) then
      $lb.Erzeuger->wpcaption # Adr.Stichwort
    else
      $lb.Erzeuger->wpcaption # '';
  end;

  if (aName='') or (aName='edSWe.Ursprungsland') then begin
    Erx # RecLink(812,620,6,0);
    if (Erx<=_rLocked) then
      $lb.Ursprungsland->wpcaption # Lnd.Name.L1
    else
      $lb.Ursprungsland->wpcaption # '';
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
  // Focus setzen auf Feld:
  $edSWe.Lieferant->WinFocusSet(true);
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
  if (SWe.Lieferant=0) then begin
    Msg(001200,Translate('Lieferant'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.Lieferant->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(100,620,2,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lieferant'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edSWe.Lieferant->WinFocusSet(true);
    RETURN false;
  end;


  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin

    TRANSON;

    SWe.Nummer # Lib_Nummern:ReadNummer('SammelWE');
    if (SWe.Nummer<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      RETURN false;
    end;

    SWe.Anlage.Datum  # Today;
    SWe.Anlage.Zeit   # Now;
    SWe.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

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
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RecRead(620,1,_recLock);
    if ("SWe.Löschmarker"='*') then "SWe.Löschmarker" # ''
    else "SWe.Löschmarker" # '*';
    RekReplace(620,_recUnlock,'MAN');
//    RekDelete(gFile,0,'MAN');
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

/***
  if (aEvt:Obj->wpname='jump') then begin
    case (aEvt:Obj->wpcustom) of
      'Page1Start' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false)
        end;
      'Page1E' : begin
        if (aFocusObject<>0) then aFocusObject->winfocusset(false);
        $NB.Main->wpcurrent # 'NB.Page1';
        $...->winfocusset(false);
        end;
    end;
    RETURN true;
  end;
***/

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
  vQ    : alpha;
end;

begin

  case aBereich of

    'Positionen' : begin
      /*
      RecBufClear(621);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'SWe.P.Verwaltung','',Y);
    //  ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
      */

      // Neu per Selektion
      RecBufClear(621);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'SWe.P.Verwaltung','',Y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QInt(var vQ, 'SWE.P.Nummer'  , '=', SWE.Nummer);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusLieferant');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Erzeuger' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusErzeuger');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Spediteur' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusSpediteur');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Versandart' : begin
      RecBufClear(817);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VSa.Verwaltung',here+':AusVersandart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Ursprungsland' : begin
      RecBufClear(812);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Lnd.Verwaltung',here+':AusUrsprungsland');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    SWe.Lieferant # Adr.Lieferantennr;
    SWe.LieferantenSW # Adr.Stichwort;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.Lieferant->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusErzeuger
//
//========================================================================
sub AusErzeuger()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    SWe.Erzeuger # Adr.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.Erzeuger->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusSpediteur
//
//========================================================================
sub AusSpediteur()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    SWe.Spediteur # Adr.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.Spediteur->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusVersandart
//
//========================================================================
sub AusVersandart()
begin
  if (gSelected<>0) then begin
    RecRead(817,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    SWe.Versandart # VSa.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edSWe.Versandart->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusUrsprungsland
//
//========================================================================
sub AusUrsprungsland()
begin
  if (gSelected<>0) then begin
    RecRead(812,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    SWe.Ursprungsland # "Lnd.Kürzel";
  end;
  // Focus auf Editfeld setzen:
  $edSWe.Ursprungsland->Winfocusset(false);
  // ggf. Labels refreshen
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SWE_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SWE_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SWE_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SWE_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SWE_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SWE_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Positionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (SWe.Nummer=0);

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
  vQ    : alpha(4000);
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (aMenuItem->wpName='Mnu.Filter.Geloescht') then begin
    Filter_SWE # !(Filter_SWE);
    $Mnu.Filter.Geloescht->wpMenuCheck # Filter_SWE;

    if (gZLList->wpdbselection<>0) then begin
      vHdl # gZLList->wpdbselection;
      gZLList->wpDbSelection # 0;
      SelClose(vHdl);
      SelDelete(gFile,w_selName);
      w_SelName # '';
      if (gZLList->wpDbRecId=0) then
        gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect)
      else
        gZLList->WinUpdate( _winUpdOn, _winLstRecFromRecId | _winLstRecDoSelect );
      App_Main:Refreshmode();
      RETURN true;
    end;
    vQ # '';
    Lib_Sel:QAlpha( var vQ, 'SWe.Löschmarker', '=', '');
    Lib_Sel:QRecList(0,vQ);

    if (gZLList->wpDbRecId=0) then
      gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect)
    else
      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);

    App_Main:Refreshmode();
    RETURN true;
  end;


  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Positionen' : begin
      Auswahl('Positionen');
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,SWe.Anlage.Datum, SWe.Anlage.Zeit, SWe.Anlage.User);
    end;


    'Mnu.Druck.LoeschLst': begin
      Lib_Dokumente:Printform(620,'Löschliste',true);
    end;


    'Mnu.Mark.Sel' : begin
      SWe_Mark_Sel();
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
    'bt.Lieferant'      :   Auswahl('Lieferant');
    'bt.Erzeuger'       :   Auswahl('Erzeuger');
    'bt.Spediteur'      :   Auswahl('Spediteur');
    'bt.Versandart'     :   Auswahl('Versandart');
    'bt.Ursprungsland'  :   Auswahl('Ursprungsland');
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
  if ("SWe.LÖschmarker"='*') then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
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
  RefreshMode(y);   // falls Menüs gesetzte werden sollen
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

  if ((aName =^ 'edSWe.Lieferant') AND (aBuf->SWe.Lieferant<>0)) then begin
    RekLink(100,620,2,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.Versandart') AND (aBuf->SWe.Versandart<>0)) then begin
    RekLink(817,620,5,0);   // Versandart holen
    Lib_Guicom2:JumpToWindow('VSa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.Spediteur') AND (aBuf->SWe.Spediteur<>0)) then begin
    RekLink(100,620,3,0);   // Speditur holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.Erzeuger') AND (aBuf->SWe.Erzeuger<>0)) then begin
    RekLink(100,620,4,0);   // Erzeuger holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edSWe.Ursprungsland') AND (aBuf->SWe.Ursprungsland<>'')) then begin
    RekLink(812,620,6,0);   // Ursprungsland holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
