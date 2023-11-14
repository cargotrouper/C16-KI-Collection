@A+
//==== Business-Control ==================================================
//
//  Prozedur    Auf_K_Main
//                  OHNE E_R_G
//  Info
//
//
//  04.02.2004  FR  Erstellung der Prozedur   (aus Ein_K_Main)
//  30.03.2009  TM  Anzeige Kalkulationssumme (nur Auftrags-MEH)
//  **.**.2009  TM  optionale Übernahme der Kalk.Summe in Auftragspos.
//  04.04.2022  AH  ERX
//  14.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit() : logic
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLieferant()
//    SUB AusVertreter()
//    SUB AusSchluessel()
//    SUB AusSchluessel2()
//    SUB AusKalkulation()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtTimer(aEvt : event; aTimerId : int): logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle :    'Auftrags-Kalkulation'
  cFile :     405
  cMenuName : 'Auf.K.Bearbeiten'
  cPrefix :   'Auf_K'
  cZList :    $ZL.Auf.Kalkulation
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
  w_ListQuickEdit # y;

Lib_Guicom2:Underline($edAuf.K.LieferantenNr);
Lib_Guicom2:Underline($edAuf.K.VertreterNr);
Lib_Guicom2:Underline($edAuf.K.Termin.Art);


  SetStdAusFeld('edAuf.K.Bezeichnung'   ,'Kalkulation');
  SetStdAusFeld('edAuf.K.LieferantenNr' ,'Lieferant');
  SetStdAusFeld('edAuf.K.MEH'           ,'MEH');
  SetStdAusFeld('edAuf.K.Termin.Art'    ,'Terminart');
  SetStdAusFeld('edAuf.K.VertreterNr'   ,'Vertreter');

  App_Main:EvtInit(aEvt);
//  Mode # c_modeEdList;
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
  Lib_GuiCom:Pflichtfeld($edAuf.K.PEH);
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
  vBuf405 : int;
  vFlag   : int;
  vSumme  : float;
  vSumme2 : float;
  vHdl    : int;
end;
begin

  if (aName='') then begin
    $lb.Nummer->wpcaption # AInt(Auf.K.Nummer);
    $lb.Position->wpcaption # AInt(Auf.K.Position);
    $lb.Kunde->wpcaption # Auf.P.KundenSW;
    RecLink(814,400,8,0);     // Währung holen
    $lb.WAE->wpcaption # "Wae.Kürzel";
  end;

  if (aName='') or (aName='edAuf.K.LieferantenNr') then begin
    Erx # RecLink(100,405,1,0);     // Lieferant holen
    if (Erx>_rLocked) or (Auf.K.LieferantenNr=0) then
      $lb.LieferantKalk->wpcaption # ''
    else
      $lb.LieferantKalk->wpcaption # Adr.Stichwort;
  end;

  if (aName='') or (aName='edAuf.K.VertreterNr') then begin
    Erx # RecLink(110,405,2,0);     // Lieferant holen
    if (Erx>_rLocked) or (Auf.K.VertreterNr=0) then
      $lb.VertreterKalk->wpcaption # ''
    else
      $lb.VertreterKalk->wpcaption # Ver.Stichwort;
  end;

  if ((aName='edAuf.K.Termin.Zahl') or (aName='edAuf.K.Termin.Jahr')) and
    (($edAuf.K.Termin.Zahl->wpchanged) or ($edAuf.K.Termin.Jahr->wpchanged)) then begin
    Lib_Berechnungen:Datum_aus_ZahlJahr(Auf.K.Termin.Art, var Auf.K.Termin.Zahl, var Auf.K.Termin.Jahr, var Auf.K.Termin);
    $edAuf.K.Termin->winupdate(_WinUpdFld2Obj);
  end;
  if (aName='edAuf.K.Termin') and
    ($edAuf.K.Termin->wpchanged) then begin
    Lib_Berechnungen:ZahlJahr_aus_Datum(Auf.K.Termin, Auf.K.Termin.Art, var Auf.K.Termin.Zahl,var Auf.K.Termin.Jahr);
    $edAuf.K.Termin.Zahl->winupdate(_WinUpdFld2Obj);
    $edAuf.K.Termin.Jahr->winupdate(_WinUpdFld2Obj);
  end;


  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();


  // ++++ Summenfeld ++++
  if (Mode=c_modeList) then begin
    vBuf405 # RekSave(405);
    vFlag # _recFirst;
    vSumme  # 0.0;
    vSumme2 # 0.0;
    WHILE (RecLink(405,401,7,vFlag) <= _rLocked) do begin
      if (Auf.K.MengenbezugYN) then
        Auf.K.Menge # Auf.P.Menge;

      If (Auf.K.MEH = Auf.P.MEH.Preis) then begin
        vSumme # vSumme + ((Auf.K.Menge /cnvfi(Auf.K.PEH))*Auf.K.Preis);
      End;
      vSumme2 # vSumme2 + ((Auf.K.Menge /cnvfi(Auf.K.PEH))*Auf.K.Preis);
      vFlag # _recNext;
    END;
    RekRestore(vBuf405);

    // Ankerfunktion:
    Gv.Num.01 # vSumme;
    Gv.Num.02 # vSumme2;
    RunAFX('Auf.K.Summe','');

    $ed.Summe->wpCaption # ANum(Gv.Num.01,2);
    $ed.Summe2->wpCaption # ANum(Gv.Num.02,2);
  end;

  // ++++ Summenfeld ++++

  Erx # RekLink(814,400,8,_RecFirst);
  $lb.WAE1->wpcaption # "Wae.Kürzel";
  $lb.WAE2->wpcaption # "Wae.Kürzel";
  $lb.WAE3->wpcaption # "Wae.Kürzel";
  $lb.WAE4->wpcaption # "Wae.Kürzel";
  $lb.WAE5->wpcaption # "Wae.Kürzel";
  gMDI->winupdate();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit() : logic
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then begin
    Auf.K.Nummer # Auf.P.Nummer;
    Auf.K.Position # Auf.P.Position;
    Auf.K.LfdNr # 1;
    Auf.K.MEH # 'kg';
    Auf.K.PEH # 1000;
    Auf.K.Termin.Art # 'KW';
    Auf.K.MengenbezugYN # y;
  end;

  $edAuf.K.Bezeichnung->WinFocusSet(true);

  RETURN true;
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
  if (Auf.K.PEH=0) then begin
    Msg(001200,Translate('Preiseinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAuf.K.PEH->WinFocusSet(true);
    RETURN false;
  end;

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (mode=c_modeList) or (Mode=c_ModeEdListEdit) then RETURN true;

  if (Mode=c_ModeEdit) then begin
    ERx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else if (Mode=c_ModeNew) then begin
    WHILE (Recread(gFile,1,_RecTest,0)<=_Rlocked) do
      Auf.K.LfdNr # Auf.K.Lfdnr + 1;

    Auf.K.Anlage.Datum  # Today;
    Auf.K.Anlage.Zeit   # Now;
    Auf.K.Anlage.User   # gUsername;
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

  if (Auf.K.Typ='POS') then RETURN;

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
  vQ    : alpha(4000);
end;

begin

  case aBereich of
    'Kalkulation' : begin

      // Ankerfunktion
      if (RunAFX('APL.Auswahl','405')<0) then RETURN;

      RecBufClear(842);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ApL.Verwaltung',here+':AusSchluessel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Schluessel2' : begin
      RecBufClear(843);
      Lib_GuiCom:AddChildWindow(gMDI,'Apl.L.Verwaltung',here+':AusSchluessel2');
      // Selektion
      VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
      vQ # 'ApL.L.Key1 = ' + cnvAI(ApL.Key1);
      vQ # vQ + ' AND ApL.L.Key2 = ' + cnvAI(ApL.Key2) ;
      vQ # vQ + ' AND ApL.L.Key3 = ' + cnvAI(ApL.Key3);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Vertreter' : begin
      RecBufClear(110);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ver.Verwaltung',here+':AusVertreter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edAuf.K.MEH,405,1,11);
    end;


    'Terminart' : begin
      Lib_Einheiten:Popup('Datumstyp',$edAuf.K.Termin.Art,405,1,6);
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
    // Feldübernahme
    Auf.K.Lieferantennr # Adr.Lieferantennr;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edAuf.K.Lieferantennr->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusVertreter
//
//========================================================================
sub AusVertreter()
begin
  if (gSelected<>0) then begin
    RecRead(110,0,_RecId,gSelected);
    // Feldübernahme
    Auf.K.Vertreternr # Ver.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edAuf.K.Vertreternr->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusSchluessel
//
//========================================================================
sub AusSchluessel()
begin
  if (gSelected<>0) then begin
    RecRead(842,0,_RecId,gSelected);
    // Event für Anschriftsauswahl starten
    gTimer2 # SysTimerCreate(333,1,gMDI);
    w_TimerVar # '->Key2';

    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edAuf.K.Bezeichnung->Winfocusset(true);
end;


//========================================================================
//  AusSchluessel2
//
//========================================================================
sub AusSchluessel2()
begin
  if (gSelected<>0) then begin
    RecRead(843,0,_RecId,gSelected);
    gSelected # 0;
    Auf.K.Bezeichnung     # ApL.L.Bezeichnung.L1;
    Auf.K.Menge           # ApL.L.Menge;
    Auf.K.MEH             # ApL.L.MEH;
    Auf.K.PEH             # ApL.L.PEH;
    Auf.K.MengenbezugYN   # ApL.L.MengenbezugYN;
    Auf.K.Preis           # ApL.L.Preis;
  end;
  // Focus auf Editfeld setzen:
  $edAuf.K.Bezeichnung->Winfocusset(true);
end;


//========================================================================
//  AusKalkulation
//
//========================================================================
sub AusKalkulation()
local begin
  Erx : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(830,0,_RecId,gSelected);
    gSelected # 0;

    // Kopieroutine....
    Erx # RecLink(831,830,1,_recFirst);   // Positionen loopen
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(405);
      Auf.K.Nummer          # Auf.P.Nummer;
      Auf.K.Position        # Auf.P.Position;
      Auf.K.lfdNr           # 1;
      Auf.K.Bezeichnung     # Kal.P.Bezeichnung;
      Auf.K.Lieferantennr   # Kal.P.Lieferantennr;
      Auf.K.VertreterNr     # Kal.P.Vertreternr;
      Auf.K.Termin.Art      # Kal.P.Termin.Art;
      Auf.K.Termin.Zahl     # Kal.P.Termin.Zahl
      Auf.K.Termin.Jahr     # Kal.P.Termin.Jahr
      Auf.K.Termin          # Kal.P.Termin
      Auf.K.Menge           # Kal.P.Menge
      Auf.K.MEH             # Kal.P.MEH
      Auf.K.PEH             # Kal.P.PEH
      Auf.K.MengenbezugYN   # Kal.P.MengenbezugYN
      Auf.K.Preis           # Kal.P.PreisW1
      "Auf.K.RückstellungYN"# "Kal.P.RückstellungYN"
      Auf.K.EinsatzmengeYN  # Kal.P.EinsatzmengeYN;


      Auf.K.Anlage.Datum  # today;
      Auf.K.Anlage.Zeit   # now;
      Auf.K.Anlage.User   # gUsername;
      REPEAT
        Erx # RekInsert(405,0,'AUTO');
        if (Erx<>_rOK) then begin
          Auf.K.lfdNr # Auf.K.lfdNr + 1;
          CYCLE;
        end;
      UNTIL (Erx=_rOK);

      Erx # RecLink(831,830,1,_recNext);
    END; // Kopierloop

  end;

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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_K_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_K_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_K_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_K_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Auf.K.Typ='POS') or (Rechte[Rgt_Auf_K_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Auf.K.Typ='POS') or (Rechte[Rgt_Auf_K_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Vorlagen.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled #  (Mode<>c_Modelist) or (Rechte[Rgt_Kalkulationen]=n);


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
  vHdl : int;
  vMode : alpha;
  vParent : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.Vorlagen.Import' : begin
      RecBufClear(830);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Kal.Verwaltung', here+':AusKalkulation');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Auf.K.Anlage.Datum, Auf.K.Anlage.Zeit, Auf.K.Anlage.User );
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
    'bt.Kalkulation'  :   Auswahl('Kalkulation');
    'bt.Lieferant'    :   Auswahl('Lieferant');
    'bt.MEH'          :   Auswahl('MEH');
    'bt.Terminart'    :   Auswahl('Terminart');
    'bt.Vertreter'    :   Auswahl('Vertreter');
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
  if ("Auf.K.Löschmarker"='*') then
    Lib_GuiCom:ZLColorLine(gZLList, Set.Col.RList.Deletd)
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
// EDEDLIST
//  if (mode=c_modeList) then mode # c_modeEdList;

  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer
(
  aEvt                  : event;        // Ereignis
  aTimerId              : int;
): logic
local begin
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (aTimerID=gTimer2) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
    if (w_TimerVar='->Key2') then begin
      w_TimerVar # '';
      Auswahl('Schluessel2');
    end;
    end
  else begin
    App_Main:EvtTimer(aEvt, aTimerId);
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
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  if (aFlags & _WinPosSized != 0) then begin
    vRect           # gZLList->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28-41;
    gZLList->wparea # vRect;
  end;

  Lib_GUiCom:ObjSetPos($lb.summe, 0, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($ed.Summe, 128, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($lb.WAE1, 224, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($lb.Summe2, 384, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($ed.Summe2, 512, vRect:bottom+3);
  Lib_GUiCom:ObjSetPos($lb.WAE5, 608, vRect:bottom+3);

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
  
  if ((aName =^ 'edAuf.K.LieferantenNr') AND (aBuf->Auf.K.LieferantenNr<>0)) then begin
    RekLink(100,405,1,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.K.VertreterNr') AND (aBuf->Auf.K.VertreterNr<>0)) then begin
    RekLink(110,405,2,0);   // Vertreter holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;
  
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================