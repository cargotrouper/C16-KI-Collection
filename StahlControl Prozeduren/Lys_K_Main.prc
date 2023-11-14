@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lys_K_Main
//                    OHNE E_R_G
//  Info
//
//
//  02.08.2005  FR  Erstellung der Prozedur
//  29.06.2012  AI  Quelle + Träger eingebaut
//  18.11.2015  AH  Neu: Kundennr
//  15.02.2016  AH  Neu: Analyse kopieren
//  13.06.2016  ST  Druck: Analysesanisicht hinzugefügt (1601/37)
//  07.02.2017  AH  AFX "Init.Pre"
//  02.03.2021  ST  AFX "Lys.K.RefreshIfm"
//  25.05.2021  AH  Edit: Einige SUBs nach Lys_Data
//  13.06.2022  AH  ERX
//  25.07.2022  HA  Quick jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLieferant()
//    SUB AusKunde()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Analysen'
  cFile :     230
  cMenuName : 'Lys.K.Bearbeiten'
  cPrefix :   'Lys_K'
  cZList :    $ZL.Lys.Kopf
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

Lib_Guicom2:Underline($edLys.K.Lieferant);
Lib_Guicom2:Underline($edLys.K.Kundennr);

  SetStdAusFeld('edLys.K.Lieferant','Lieferant');
  SetStdAusFeld('edLys.K.Kundennr','Kunde');

  // Chemietitel ggf. setzen
  if (Set.Chemie.Titel.C<>'') then begin
    $lbLys.Chemie.C->wpcaption # Set.Chemie.Titel.C;
  end;
  if (Set.Chemie.Titel.Si<>'') then begin
    $lbLys.Chemie.Si->wpcaption # Set.Chemie.Titel.Si;
  end;
  if (Set.Chemie.Titel.Mn<>'') then begin
    $lbLys.Chemie.Mn->wpcaption # Set.Chemie.Titel.Mn;
  end;
  if (Set.Chemie.Titel.P<>'') then begin
    $lbLys.Chemie.P->wpcaption # Set.Chemie.Titel.P;
  end;
  if (Set.Chemie.Titel.S<>'') then begin
    $lbLys.Chemie.S->wpcaption # Set.Chemie.Titel.S;
  end;
  if (Set.Chemie.Titel.Al<>'') then begin
    $lbLys.Chemie.Al->wpcaption # Set.Chemie.Titel.Al;
  end;
  if (Set.Chemie.Titel.Cr<>'') then begin
    $lbLys.Chemie.Cr->wpcaption # Set.Chemie.Titel.Cr;
  end;
  if (Set.Chemie.Titel.V<>'') then begin
    $lbLys.Chemie.V->wpcaption # Set.Chemie.Titel.V;
  end;
  if (Set.Chemie.Titel.Nb<>'') then begin
    $lbLys.Chemie.Nb->wpcaption # Set.Chemie.Titel.Nb;
  end;
  if (Set.Chemie.Titel.Ti<>'') then begin
    $lbLys.Chemie.Ti->wpcaption # Set.Chemie.Titel.Ti;
  end;
  if (Set.Chemie.Titel.N<>'') then begin
    $lbLys.Chemie.N->wpcaption # Set.Chemie.Titel.N;
  end;
  if (Set.Chemie.Titel.Cu<>'') then begin
    $lbLys.Chemie.Cu->wpcaption # Set.Chemie.Titel.Cu;
  end;
  if (Set.Chemie.Titel.Ni<>'') then begin
    $lbLys.Chemie.Ni->wpcaption # Set.Chemie.Titel.Ni;
  end;
  if (Set.Chemie.Titel.Mo<>'') then begin
    $lbLys.Chemie.Mo->wpcaption # Set.Chemie.Titel.Mo;
  end;
  if (Set.Chemie.Titel.B<>'') then begin
    $lbLys.Chemie.B->wpcaption # Set.Chemie.Titel.B;
  end;
  if (Set.Chemie.Titel.1<>'') then begin
    $lbLys.Chemie.Frei1->wpcaption # Set.Chemie.Titel.1;
  end;
  if ("Set.Mech.Titel.Härte"<>'') then begin
    if ($lbLys.Haerte<>0) then
      $lbLys.Haerte->wpcaption # "Set.Mech.Titel.Härte";
  end;
  if ("Set.Mech.Titel.Körn"<>'') then begin
    $lbLys.Koernung->wpcaption # "Set.Mech.Titel.Körn";
  end;
  if ("Set.Mech.Titel.Sonst"<>'') then begin
    $lbLys.Mech.Sonstiges->wpcaption # "Set.Mech.Titel.Sonst";
  end;
  if ("Set.Mech.Titel.Rau1"<>'') then begin
    if ($lbLys.RauigkeitA1<>0) then
      $lbLys.RauigkeitA1->wpcaption # "Set.Mech.Titel.Rau1";
  end;
  if ("Set.Mech.Titel.Rau2"<>'') then begin
    if ($lbLys.RauigkeitB1<>0) then
      $lbLys.RauigkeitB1->wpcaption # "Set.Mech.Titel.Rau2";
  end;

  if (Set.Mech.Dehnung.Wie<>1) then
    $lbLys.DehnungB->wpvisible # false;

  RunAFX('Lys.Init.Pre',aint(aEvt:Obj));
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
  vTmp  : int;
  Erx   : int;
end;
begin
  // Ankerfunktion?
  if (RunAFX('Lys.K.RefreshIfm',aName)<0) then RETURN;

  if (aName='') then begin
    if ("Lys.K.Trägernummer1"=0) then
      $lb.Traeger->wpcaption # ''
    else
      $lb.Traeger->wpcaption # aint("Lys.K.Trägernummer1")+'/'+aint("Lys.K.Trägernummer2")+'/'+aint("Lys.K.Trägernummer3")+'/'+aint("Lys.K.Trägernummer4");
  end;

  if (aName='') or (aName='edLys.K.Lieferant') then begin
    Erx # RecLink(100,230,2,0);   // Lieferant holen
    if (Erx<=_rLocked) and (Lys.K.Lieferant<>0) then
      Lys.K.LieferantenSW # Adr.Stichwort
    else
      Lys.K.LieferantenSW # '';
    $lb.Lieferant->wpcaption # Lys.K.LieferantenSW;
  end;


  if (aName='') or (aName='edLys.K.Kundennr') then begin
    Erx # RekLink(100,230,4,_recFirst); // Kunde holen
    if (Erx<=_rLocked) and (Lys.K.Kundennr<>0) then
      Lys.K.KundenSW # Adr.Stichwort
    else
      Lys.K.KundenSW # '';
    $lb.Kunde->wpcaption # Lys.K.KundenSW;
  end;


  if (aName='') and (Lys.K.AnalyseNr<>0) then begin
    Erx # RecLink(231,230,1,_RecFirst); // Position holen
    if (Erx>_rLocked) then RecBufClear(231);
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if (w_Context='ZUM_WE') then
    Lys_Msk_Main:CheckVorgaben('',501)
  else if (w_Context='ZUM_AUF') then
    Lys_Msk_Main:CheckVorgaben('',401)
  else
    Lys_Msk_Main:CheckVorgaben('',0);


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

  // Ankerfunktion?
  if (RunAFX('Lys.K.RecInit','')<0) then RETURN;

  // Felder Disablen durch:
  $edLys.K.Analysenr->Winupdate(_WinUpdFld2Obj);
  Lib_GuiCom:Disable($edLys.K.Analysenr);

  // Focus setzen auf Feld:
  $edLys.K.Datum->WinFocusSet(true);

  if (Mode = c_ModeNew) then begin
    // Puffer für Analysen leeren
    RecBufClear(231);

    if (w_AppendNr<>0) then begin
      Lys.K.Analysenr # w_AppendNr;
      RecRead(230,1,0);
      RecLink(231,230,1,_RecFirst);
      w_AppendNr      # 0;
      Lys.K.Analysenr # 0;
      Lys.Analysenr   # 0;
    end;

    if (w_Command='aus Mat') then begin
      Lys_Data:VorbelegenVonMatAnalyse();
    end;

  end;

  if (Mode = c_ModeEdit) then begin
    RecLink(231,230,1,_RecFirst | _RecLock);
    PtD_Main:Memorize(231);
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

  // logische Prüfung
  if (Lys.K.Lieferant<>0) then begin
    Erx # RecLink(100,230,2,_recFirst);   // Lieferant holen
    if (Erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Lieferant', 'NB.Page1', 'edLys.K.Lieferant');
      RETURN false;
    end;
  end;
  if (Lys.K.Kundennr<>0) then begin
    Erx # RecLink(100,230,4,_recFirst);   // Kunde holen
    if (Erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Kunde', 'NB.Page1', 'edLys.K.Kundennr');
      RETURN false;
    end;
  end;

  // Satz zurückspeichern & protokolieren

  TRANSON;

  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      TRANSBRK;
      RETURN False;
    end;
    Erx # RekReplace(231,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      TRANSBRK;
      RETURN False;
    end;

    PtD_Main:Compare(gFile);
    PtD_Main:Compare(231);
  end
  else begin

    if (Lys_Data:Anlegen()=falsE) then begin
      TRANSBRK;
      ErrorOutput;
      RETURN False;
    end;

  end;

  TRANSOFF;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin

  // Protokoll der Analyse löschen
  if (ProtokollBuffer[231]<>0) then PtD_Main:Forget(231);

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

    TRANSON;

    // Alle zugehörigen Analysen löschen
    Erx # RecLink(231,230,1,_RecFirst);
    while (Erx=_rOk) do begin
      Erx # RekDelete(231,0,'MAN');
      if (Erx <> _rOk) then begin
        TRANSBRK;
        RETURN;
      end;

      Erx # RecLink(231,230,1,_RecFirst);
    end;

    // Analysekopf löschen
    Erx # RekDelete(gFile,0,'MAN');
    if (Erx <> _rOk) then
      TRANSBRK;

    TRANSOFF;
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
  if (aEvt:Obj->wpname='edLys.K.Lieferant') or
    (aEvt:Obj->wpname='edLys.K.Kundennr') or
    (aEvt:Obj->wpname='xxxxx') then
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
    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kunde' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.KundenNr > 0');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Lys.K.Lieferant # Adr.Lieferantennr;

    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edLys.K.Lieferant->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edLys.K.Lieferant');
end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Lys.K.Kundennr # Adr.Kundennr;

    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edLys.K.Kundennr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edLys.K.Kundennr');
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lys_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lys_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.Material');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Material]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_AuswahlMode) or (Rechte[Rgt_Lys_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Lys_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Lys_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Lys_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Lys_Anlegen]=n);

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
  vQ      : alpha(4000);
  vBuf230 : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Copy' : begin
      w_AppendNr # Lys.K.Analysenr;
      App_Main:Action(c_ModeNew);
      RETURN true;
    end;


    'Mnu.Material' : begin
      if (Lys.K.Analysenr=0) then RETURN true;
      RecBufClear(200);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung','',false);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(998);
      vQ # '';
      Lib_Sel:QInt( var vQ, 'Mat.Analysenummer', '=', Lys.K.Analysenr);
      Lib_Sel:QRecList(0,vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
      RETURN true;
    end;


    'Mnu.Protokoll' : begin
      RecLink(231,230,1,_RecFirst);
      PtD_Main:View(230,Lys.K.Anlage.Datum, Lys.K.Anlage.Zeit, Lys.K.Anlage.User, 0.0.0, 0:0, '', '', '', 231);
    end;


    'Mnu.Auswahl' : begin
      vHdl # WinFocusGet();
      if (vHdl<>0) then begin
        case (vHdl->wpname) of
          'edLys.K.Lieferant' :   Auswahl('Lieferant');
          'edLys.K.Kundennr'  :   Auswahl('Kunde');
        end;
      end;
    end;


    'Mnu.Druck.Ansicht' : begin
      vBuf230 # RekSave(230);
      Lib_Dokumente:PrintForm(230,'Analyse',false);
      RekRestore(vBuf230);
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
    'bt.Kunde'     :   Auswahl('Kunde');
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
local begin
  Erx : int;
end;
begin

  if (w_NoList=false) and (w_Command<>'NEWREPOS') then begin   // 06.01.2020 AH: Fix für Mat->Lyse1 zeigen->Click in Felder
    Erx # RecLink(231,230,1,_RecFirst); // Position holen
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
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edLys.K.Lieferant') AND (aBuf->Lys.K.Lieferant<>0)) then begin
    RekLink(100,230,2,0);   // Lieferant holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edLys.K.Kundennr') AND (aBuf->Lys.K.Kundennr<>0)) then begin
    RekLink(100,230,4,0);   // Kunde holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================