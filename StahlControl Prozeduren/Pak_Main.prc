@A+
//==== Business-Control ==================================================
//
//  Prozedur    Pak_Main
//                OHNE E_R_G
//  Info
//
//
//  15.11.2007  MS  Erstellung der Prozedur
//  15.02.2012  ST  Löschen von einem Paket, entfernt die Paketnummern eines Materials
//  15.10.2018  ST  Etikettendruck nach verpackverbuchung muss über Ankerfunktion laufen!!!
//  11.12.2018  AH  Erweiterung um Unterlagen
//  06.12.2019  AH  kleiner Umbau für BFS
//  17.01.2020  AH  Markierungen (für BFS)
//  07.02.2020  AH  Neu: Bruttogewicht-Spalte
//  27.10.2020  AH  Zugriffsspaltenreihenfolge merken
//  31.03.2022  AH  ERX
//  14.04.2022  AH  Pak mit Inhaltangaben
//  27.04.2022  AH  Paketversand
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
//    SUB AusLEER()
//    SUB AusPositionen()
//    SUB AusLageradresse()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//    SUB BMVerpacken()
//    sub _BMVerp_Add(aDL : int)
//    sub _BMVerp_Del(aDL : int)
//    sub _BMVerp_Verbuchen(aWin : int)
//    sub _BMVerp_EvtClicked(aEvt   : event;) : logic//
//========================================================================
@I:Def_Global
@I:Def_Rights

declare _BMVerp_Del(aDL : int)
declare _BMVerp_Sum(  aWin  : int; aDL : int)
declare _BMVerp_Verbuchen(aWin : int)
declare Mark(aDL : int; aId : int;opt aRemoveOnly : logic)

define begin
  cTitle      : 'Pakete'
  cFile       :  280
  cMenuName   : 'Pak.Bearbeiten'
  cPrefix     : 'Pak'
  cZList      : $ZL.Pakete
  cKey        : 1
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
  RunAFX('Pak.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);

Lib_Guicom2:Underline($edPak.Lageradresse);
Lib_Guicom2:Underline($edPak.Lageranschrift);
Lib_Guicom2:Underline($edPak.Zwischenlage);
Lib_Guicom2:Underline($edPak.Unterlage);
Lib_Guicom2:Underline($edPak.Umverpackung);


  SetStdAusFeld('edPak.Lageradresse'  , 'Lageradresse');
  SetStdAusFeld('edPak.Lageranschrift', 'Lageranschrift');
  SetStdAusFeld('edPak.Unterlage',      'Unterlage');
  SetStdAusFeld('edPak.Zwischenlage',   'Zwischenlage');
  SetStdAusFeld('edPak.Umverpackung',   'Umverpackung');
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
  opt aChanged : logic;
)
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if (aName='') or (aName='edPak.Lageradresse') or (aName='edPak.Lageranschrift') then begin
    Erx # RecLink(101,280,2,0);
    if (Erx<=_rLocked) and (Pak.Lageradresse<>0) then begin
      $Lb.Lagerort->wpcaption # Adr.A.Stichwort
    end
    else begin
      Pak.Lageradresse # 0;
      Pak.Lageranschrift # 0;
      $Lb.Lagerort->wpcaption # '';
    end;
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
  $edPak.Typ->WinFocusSet(true);
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


  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    /*
    "xxx.Änderung.Datum"  # Today;
    "xxx.Änderung.Zeit"   # Now;
    "xxx.Änderung.User"   # gUserName;
    */
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    Pak.Nummer # Lib_Nummern:ReadNummer('Paket');    // Nummer lesen
    Lib_Nummern:SaveNummer();

    Pak.Anlage.Datum  # Today;
    Pak.Anlage.Zeit   # Now;
    Pak.Anlage.User   # gUserName;
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
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    Pak_Data:Delete(0,'MAN');
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
  vHdl  : int;
  Erx   : int;
end;
begin

  case aBereich of

    'Unterlage' : begin
      RecBufClear(838);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusUnterlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=1';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Umverpackung' : begin
      RecBufClear(838);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusUmverpackung');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=3';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zwischenlage' : begin
      RecBufClear(838);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ULa.Verwaltung',here+':AusZwischenlage');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # ' ULa.Typ=0 OR ULa.Typ=2';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageradresse'   : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLageradresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Lageranschrift' : begin
      RecLink(100,280,3,0);
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLageranschrift');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
      vHdl # SelCreate(101, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;


end;


//========================================================================
//  AusUnterlage
//
//========================================================================
sub AusUnterlage()
begin

  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Pak.Unterlage   # ULa.Bezeichnung;
    Pak.Unterlage.H # "ULa.Höhenabzug";
    $edPak.Unterlage.H->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edPak.Unterlage->Winfocusset(false);
end;


//========================================================================
//  AusUmverpackung
//
//========================================================================
sub AusUmverpackung()
begin

  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Pak.Umverpackung    # ULa.Bezeichnung;
    Pak.Umverpackung.H  # "ULa.Höhenabzug";
    $edPak.Umverpackung.H->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edPak.Umverpackung->Winfocusset(false);
end;


//========================================================================
//  AusZwischenlage
//
//========================================================================
sub AusZwischenlage()
begin

  if (gSelected<>0) then begin
    RecRead(838,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Pak.Zwischenlage    # ULa.Bezeichnung;
    Pak.Zwischenlage.H  # "ULa.Höhenabzug";
    $edPak.Zwischenlage.H->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edPak.Zwischenlage->Winfocusset(false);
end;


//========================================================================
//  AusPositionen
//
//========================================================================
sub AusPositionen()
begin
  if (gSelected<>0) then begin
//    RecRead(xxx,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
  end;
  // Focus auf Editfeld setzen:
//  $edxxx.xxxxx->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  AusLageradresse
//
//========================================================================
sub AusLageradresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Pak.Lageradresse # Adr.Nummer;
    Pak.Lageranschrift # 1;
    gSelected # 0;
  end;
  // Focus setzen:
  $edPak.Lageradresse->Winfocusset(false);
  RefreshIfm('edPak.Lageradresse');
end;


//========================================================================
//  AusLageranschrift
//
//========================================================================
sub AusLageranschrift()
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    Pak.Lageradresse # Adr.A.Adressnr;
    Pak.Lageranschrift # Adr.A.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edPak.Lageranschrift->Winfocusset(false);
  RefreshIfm('edPak.Lageranschrift');
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
  vVersand    : logic;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  vVersand # VsP_Data:ExistsPaket(Pak.Nummer);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_Loeschen]=n) or (vVersand);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Pak_Loeschen]=n) or (vVersand);

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
  vTmp : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Pak.Anlage.Datum, Pak.Anlage.Zeit, Pak.Anlage.User);
    end;


    'Mnu.Positionen' : begin
      RecBufClear(281);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Pak.P.Verwaltung',here+':AusPositionen',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gzllist->wpdbLinkfileno # 281;
      gzllist->wpdbKeyno      # 1;
      gzllist->wpdbfileno     # 280;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
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
    'bt.Lageradresse'     : Auswahl('Lageradresse');
    'bt.Lageranschrift'   : Auswahl('Lageranschrift');
    'bt.Zwischenlage'     : Auswahl('Zwischenlage');
    'bt.Unterlage'        : Auswahl('Unterlage');
    'bt.Umverpackung'     : Auswahl('Umverpackung');
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
  vHdl  : int;
end;
begin
  vHdl # Winsearch(aEvt:Obj, 'DLMats');
  if (vHdl<>0) then
    Lib_GuiCom:RememberList(vHdl, 'BM.Verpacken');

  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aID                   : bigint;       // RecID bei RecList, Node-Deskriptor bei TreeView, Focus-Objekt bei Frame und AppFrame
) : logic;
local begin
  vMark   : logic;
  vStatus : alpha;
  vHdl    : int;
  vWin    : int;
  vStk    : int;
  vGew    : float;
  vMatGew : float;
end;
begin

  if (aID=0) then RETURN true;
  
  if (aKey=_WinKeyDelete) then begin
    _BMVerp_Del(aEvt:obj);
    RETURN true;
  end;

  // Markieren?
  if (aKey=_WinKeyInsert) then begin
    Mark(aEvt:obj, aID);
  end;

  RETURN(true);
end;


//========================================================================
//  SFX sub Verpacken()
//      Ruft den Dialog "Verpacken" auf und stößt die Verbuchung an
//========================================================================
sub BMVerpacken()
local begin
  vWin  : int;
  vId   : int;
  vHdl  : int;
end
begin

  if (RunAFX('Pak_Main_BMVerpacken','')<0) then begin
    RETURN;
  end;

  // Maske auf
  vWin # WinOpen('Pak.BM.Mat.Verpacken',_WinOpenDialog);
  vHdl # Winsearch(vWin, 'DLMats');
  if (vHdl<>0) then
    Lib_GuiCom:RecallList(vHdl, 'BM.Verpacken');

  $edMat->wpCaption # '';
  WinFocusSet($edMat);

  vID   # vWin->Windialogrun(_WinDialogCenter,gMDI);

  if (vHdl<>0) then
    Lib_GuiCom:RememberList(vHdl, 'BM.Verpacken');

  // Maske zu
  vWin->winclose();
end;


//========================================================================
//  sub _BMVerp_Add(aDL : int)
//
//========================================================================
sub _BMVerp_Add(aDL : int)
local begin
  vAbfrage : alpha;
  vToken   : alpha;

  vZeilen, vZeile : int;
  vMatNr    : int;
end
begin
  if (Dlg_Standard:Standard('Materialnummer', var vAbfrage)) then begin
    // Material lesen
    vToken # Str_Token(vAbfrage,'/',1);
    if (vToken = '') then
      RETURN;


    Mat.Nummer # CnvIa(vToken);
    // Prüfen ob Materialnummer im Bestand?
    if (RecRead(200,1,0) <> _rOK) then begin
      Dlg_Standard:InfoBetrieb('ACHTUNG','Materialnummer ist nicht bekannt',true);
      RETURN;
    end;

    //  ST 2018-10-24: ggf. altes Etikett gescannt, dann "neues" Material suchen
    Mat_Data:Read(Mat_Data:lies1zu1FMAktuell(Mat.nummer));



    // Material gelöscht?
    if ("Mat.Löschmarker" <> '') then begin
      Dlg_Standard:InfoBetrieb('ACHTUNG','Das Material ist schon gelöscht',true);
      RETURN;
    end;

    // Material schon verpackt?
    if ("Mat.Paketnr" <> 0) then begin
      Dlg_Standard:InfoBetrieb('ACHTUNG','Das Material ist schon in Paket Nr. ' + Aint(Mat.Paketnr) ,true);
      RETURN;
    end;

    // passt Kommission?
    if ($edKommission->wpCaption <> '') AND ($edKommission->wpCaption <> Mat.Kommission) then begin
      Dlg_Standard:InfoBetrieb('ACHTUNG','Das Material trägt nicht die selbe Kommission',true);
      RETURN;
    end;

    // Material noch nicht eingefügt?
    vZeilen # aDL->WinLstDatLineInfo(_WinLstDatInfoCount);
    FOR vZeile # 1
    LOOP inc(vZeile)
    WHILE (vZeile <= vZeilen) DO BEGIN

      // Material aus Liste lesen
      aDL->WinLstCellGet(vMatNr, 1, vZeile);

      if (vMatNr = Mat.Nummer) then begin
        Dlg_Standard:InfoBetrieb('ACHTUNG','Das Material ist schon im Paket vorhanden',true);
        RETURN;
      end;
    END;


    // Kunde Lesen
    if(RecLink(100,200,7,0) <> _rOK) then
      RecBufClear(100);

    // Daten in DL einfügen
    aDL->WinLstDatLineAdd(Mat.Nummer);
    aDL->WinLstCellSet(Mat.Dicke          ,2,_WinLstDatLineLast);
    aDL->WinLstCellSet(Mat.Breite         ,3,_WinLstDatLineLast);
    aDL->WinLstCellSet(Mat.Gewicht.Netto  ,4,_WinLstDatLineLast);
    aDL->WinLstCellSet(Mat.Gewicht.Brutto ,5,_WinLstDatLineLast);
    aDL->WinLstCellSet(Adr.Stichwort      ,6,_WinLstDatLineLast);
    aDL->WinLstCellSet(Mat.Paketnr        ,7,_WinLstDatLineLast);
    aDL->WinLstCellSet(Mat.Ursprung       ,8,_WinLstDatLineLast);
    aDL->WinLstCellSet(false              ,9,_WinLstDatLineLast);

    $edKommission->wpCaption # Mat.Kommission;

    // Dialog wieder öffnen für neue eingabe
    _BMVerp_Sum($Pak.BM.Mat.Verpacken, $DLMats);
    _BMVerp_Add(aDL);
  end;

end;

//========================================================================
sub Mark(
  aDL             : int;
  aId             : int;
  opt aRemoveOnly : logic)
local begin
  vStatus   : alpha;
  vMark     : logic;
  vMatGew   : float;
  vMatGewB  : float;
  vStk      : int;
  vGew      : float;
  vHdl      : int;
  vWin      : int;
end;
begin
  aDL->WinLstCellGet(vStatus, 6, aID);
  if (StrFind(vStatus,'FEHLER:',1) > 0) then RETURN;
  aDL->WinLstCellGet(vMark,9, aId);
  if (aRemoveOnly) and (vMark=false) then RETURN;
  vMark # !vMark;
  aDL->WinLstCellSet(vMark,9, aId);

  aDL->WinLstCellGet(vMatGew  ,4, aId);
  aDL->WinLstCellGet(vMatGewB ,5, aId);
  vWin # Wininfo(aDL, _Winroot);
  vHdl # Winsearch(vWin, 'lbStkMark');
  vStk # cnvia(vHdl->wpCaption);
  if (vMark) then
    inc(vStk)
  else
    dec(vStk);
  vHdl->wpCaption # aint(vStk);
    
  vHdl # Winsearch(vWin, 'lbGewMark');
  vGew # cnvfa(vHdl->wpCaption);
  if (vMark) then
    vGew # vGew + vMatGew
  else
    vGew # vGew - vMatGew;
  vHdl->wpCaption # anum(vGew,0);

  vHdl # Winsearch(vWin, 'lbGewBMark');
  vGew # cnvfa(vHdl->wpCaption);
  if (vMark) then
    vGew # vGew + vMatGewB
  else
    vGew # vGew - vMatGewB;
  vHdl->wpCaption # anum(vGew,0);

end;


//========================================================================
//  sub _BMVerp_Del(aDL : int)
//
//========================================================================
sub _BMVerp_Del(aDL : int)
local begin
  vMark : logic;
end;
begin

  Mark(aDL, aDL->wpCurrentInt, true);

  // Zeile leeren
  aDL->WinLstDatLineRemove(aDL->wpCurrentInt);
end;


//========================================================================
//  sub _BMVerp_DelPaket(aDL : int)
//
//========================================================================
sub _BMVerp_DelPaket(aDL : int)
local begin
  Erx       : int;
  vAbfrage  : alpha;
end
begin

  // Löscht ein komplettes Paket
  if (Dlg_Standard:Standard('Paketnummer', var vAbfrage)) then begin

    // Paket lesen
    Pak.Nummer # CnvIa(vAbfrage);
    // Prüfen ob Materialnummer im Bestand?
    if (RecRead(280,1,0) <> _rOK) then begin
      Dlg_Standard:InfoBetrieb('ACHTUNG','Paketnummer ist nicht bekannt',true);
      RETURN;
    end;

    Erx # Pak_Data:Delete(0,'MAN');
    if (Erx <> _rOK) then
      Dlg_Standard:InfoBetrieb('ACHTUNG','Das Paket konnte nicht gelöscht werden.',true);
    else
      Dlg_Standard:InfoBetrieb('INFORMATION','Das Paket wurde erfolgreich aufgelöst.',false);

  end;

end;


//========================================================================
//    sub _BMVerp_Verbuchen(aWin : int)
//      Verbucht die Paketnummer an den Materialien
//========================================================================
sub _BMVerp_Verbuchen(aWin : int)
local begin
  vDl : int;
  vZeilen, vZeile : int;
  vMat      : int;
  vPaketNr  : int;
  vPakPos   : int;
  vGewSum   : float;
  vNetto    : float;
  vBrutto   : float;
  vStk      : int;
  vStatus   : alpha;
  vMark     : logic;
  vMarked   : int;
end
begin


  vDL # aWin;

  // Noch Fehler im Paket?
  vZeilen # vDL->WinLstDatLineInfo(_WinLstDatInfoCount);
  FOR vZeile # 1
  LOOP inc(vZeile)
  WHILE (vZeile <= vZeilen) DO BEGIN

    // Material aus Liste lesen
    vDL->WinLstCellGet(vStatus, 6, vZeile);

    if (StrFind(vStatus,'FEHLER:',1) > 0) then begin
      Dlg_Standard:InfoBetrieb('Fehler','Paket noch Fehlerhaft',true);
      RETURN;
    end;
 
    vDL->WinLstCellGet(vMark, 9, vZeile);
    if (vMark) then inc(vMarked);
  END;

  if (vMarked>0) then begin
    if (Msg(280002,aint(vMarked),0,0,0)<>_winidyes) then RETURN;
//    todox('');
//    RETURN;
  end;
  
  TRANSON;

  // Paketnummer holen
  vPaketNr # Lib_Nummern:ReadNummer('PAKET');
  if (vPaketNr <> 0) then begin
    Lib_Nummern:SaveNummer();

    vGewSum   # 0.0;
    vNetto    # 0.0;
    vBrutto   # 0.0;
    vStk      # 0;

    vZeilen # vDL->WinLstDatLineInfo(_WinLstDatInfoCount);
    FOR vZeile # 1
    LOOP inc(vZeile)
    WHILE (vZeile <= vZeilen) DO BEGIN

      if (vMarked>0) then begin
        vDL->WinLstCellGet(vMark, 9, vZeile);
        if (vMark=false) then CYCLE;
      end;

      // Material aus Liste lesen
      vDL->WinLstCellGet(vMat, 1, vZeile);

      Mat.Nummer # vMat;
      if (RecRead(200,1,_RecLock) = _rOK) then begin

        Mat.Paketnr # vPaketNr;
        if (Mat_Data:Replace(0,'MAN') <> _rOK) then begin
          TRANSBRK;
          Dlg_Standard:InfoBetrieb('Fehler','Das Material ' +Aint(Mat.Nummer)+ StrChar(10)+
                                            ' konnte nicht gespeichert werden',true);
          RETURN;
        end;

        vGewSum # vGewSum + Mat.Gewicht.Netto;
        vNetto  # vNetto  + Mat.Gewicht.Netto;
        vBrutto # vBrutto + Mat.Gewicht.Brutto;
        vStk    # vStk    + Mat.Bestand.Stk;

        // Paketposition anlegen
        RecBufClear(281);
        Pak.P.Nummer      # vPaketNr;
        Pak.P.Position    # vZeile;
        Pak.P.Typ         # 'MAT';
        Pak.P.MaterialNr  # Mat.Nummer;
        if (RekInsert(281,0,'MAN') <> _rOK) then begin
          TRANSBRK;
          Dlg_Standard:InfoBetrieb('Fehler','Das Paket '+Aint(vPaketNr)+' für ' +Aint(Mat.Nummer)+ StrChar(10)+
                                            ' konnte nicht gespeichert werden',true);
          RETURN;
        end;
      end
      else begin
        TRANSBRK;
        Dlg_Standard:InfoBetrieb('Fehler','Das Material ' +Aint(Mat.Nummer)+ StrChar(10)+
                                          ' konnte nicht gesperrt werden',true);
        RETURN;
      end;
      // Nächstes Material
    END;

    //  Paketkopf anlegen
    RecBufClear(280);
    Pak.Nummer        # vPaketNr;
    Pak.Typ           #  'MAT';
    Pak.Lageradresse  # Set.eigeneAdressnr;
    Pak.Lagerplatz    # Mat.Lagerplatz; // vom Letzten Material im Paket
    Pak.Gewicht       # vGewSum;
    Pak.Inhalt.Stk    # vStk;
    Pak.Inhalt.Netto  # vNetto;
    Pak.Inhalt.Brutto # vBrutto;
    Pak.Bemerkung     # Translate('Kommission')+': ' + Mat.Kommission;
    "Pak.Löschmarker" # '';
    Pak.Anlage.Datum  # today;
    Pak.Anlage.Zeit   # now;
    Pak.Anlage.User   # gUserName;
    if (RekInsert(280,0,'MAN') <> _rOK) then begin
      TRANSBRK;
      Dlg_Standard:InfoBetrieb('Fehler','Das Paket '+Aint(vPaketNr)+ ' konnte nicht gespeichert werden',true);
      RETURN;
     end;
  end
  else begin
    Lib_Nummern:FreeNummer();
  end;

  TRANSOFF;

  // ST 2018-10-15: Etikettendruck nach Verpacken muss über Ankerfunktion laufen!!!
  // Mat_Etikett:Init(4);
  RunAFX('Pak.Verbuchen.Post','');

  $Pak.BM.Mat.Verpacken->winclose();

end;


//========================================================================
//    sub _BMVerp_Sum(aWin : int)
//      Summiert die Gewichtsspalte und zählt die Anzahl der Ringe
//========================================================================
sub _BMVerp_Sum(
  aWin  : int;
  aDL   : int)
local begin
  vDl : int;
  vZeilen, vZeile : int;
  vMat      : int;
  vGew      : float;
  vGewGes   : float;
  vGewGesB  : float;
  vHdl      : int;
end
begin

  vZeilen # aDL->WinLstDatLineInfo(_WinLstDatInfoCount);
  FOR vZeile # 1
  LOOP inc(vZeile)
  WHILE (vZeile <= vZeilen) DO BEGIN
    // Gewicht aus Liste lesen
    aDL->WinLstCellGet(vGew, 4, vZeile);
    vGewGes # vGewGes + vGew;
    aDL->WinLstCellGet(vGew, 5, vZeile);
    vGewGesB # vGewGesB + vGew;
  END;

  vHdl # Winsearch(awin, 'lbStk');
  if (vHdl<>0) then
    vHdl->wpCaption # Aint(vZeilen);
  vHdl # Winsearch(awin, 'lbGew');
  if (vHdl<>0) then
    vHdl->wpCaption # CnvAf(vGewGes,_FmtNumNoZero,0,0);
  vHdl # Winsearch(awin, 'lbGewB');
  if (vHdl<>0) then
    vHdl->wpCaption # CnvAf(vGewGesB,_FmtNumNoZero,0,0);

  if (vZeilen = 0) then begin
    vHdl # Winsearch(awin, 'edKommission');
    if (vHdl<>0) then
      vHdl->wpCaption # '';
  end;

end;


//========================================================================
//    sub _BMVerp_EvtClicked(  aEvt   : event;) : logic
//
//========================================================================
sub _BMVerp_EvtClicked(
  aEvt   : event;
) : logic
begin

  case (aEvt:Obj->wpName) of
    'Add' : begin
      _BMVerp_Add($DLMats);
    end;
    'Del' : begin
      _BMVerp_Del($DLMats);
    end;
    'DelPaket' : begin
      _BMVerp_DelPaket($DLMats);
    end;
    'Save' : begin
      _BMVerp_Verbuchen($DLMats);
    end;
  end;

  _BMVerp_Sum($Pak.BM.Mat.Verpacken, $DLMats);
end;


//========================================================================
//    sub _BMVerp_EvtFocusTerm(aEvt : event; aFocusObject : handle;) : logic
//
//========================================================================
sub _BMVerp_EvtFocusTerm(
  aEvt         : event;
  aFocusObject : handle;
) : logic
local begin
  vDL       : int;
  vLfs      : int;
  vZeilen, vZeile : int;
  vStatus   : alpha;
  vOK       : logic;

  vMatNr      : int;
  vErg : int;

  vErr  : int;
  vErrMsg : alpha;

end
begin


  // Falls schon Lieferscheinpositionen gescannt sind, dann keine Eingabe das Verladeanweisung erlauben
  vDL # Winsearch($Pak.BM.Mat.Verpacken,'DLMats');

  if (aFocusObject  = 0) then
    RETURN true;

  if (aFocusObject <> 0) AND (aFocusObject->wpName = 'Abbruch') then
    RETURN true;

  if (aEvt:Obj->wpName = 'edMat') then begin
    // ----------------------------------------------
    // Materialnummer eingescannt

    Mat.Nummer # CnvIa($edMat->wpCaption);

    if (Mat.Nummer = 0) then begin
    
      if (aFocusObject<>0) then begin
        if (aFocusObject->wpname='DLMats') then begin
          RETURN true;
        end;
      end;
      WinFocusSet($edMat);
      RETURN true;
    end;

    REPEAT

      //  ST 2018-10-24: ggf. altes Etikett gescannt, dann "neues" Material suchen
      Mat_Data:Read(Mat_Data:lies1zu1FMAktuell(Mat.nummer));

      // Prüfen ob Materialnummer im Bestand?
      if (RecRead(200,1,0) <> _rOK) then begin
        vErr # 1;
        Mat.Nummer  # CnvIa($edMat->wpCaption);
        Mat.Dicke         # 0.0;
        Mat.Breite        # 0.0;
        Mat.Gewicht.Netto # 0.0;
        break;
      end;

      // Material gelöscht?
      if ("Mat.Löschmarker" <> '') then begin
        vErr # 2;
        break;
      end;

      //  Material schon verpackt?
      if ("Mat.Paketnr" <> 0) then begin
        vErr # 3;
        break;
      end;

      // passt Kommission?
      if ($edKommission->wpCaption <> '') AND ($edKommission->wpCaption <> Mat.Kommission) then begin
        vErr # 4;
        break;
      end;

      break;
    UNTIL false;


    // Material noch nicht eingefügt?
    vZeilen # vDL->WinLstDatLineInfo(_WinLstDatInfoCount);
    FOR vZeile # 1
    LOOP inc(vZeile)
    WHILE (vZeile <= vZeilen) DO BEGIN

      // Material aus Liste lesen
      vDL->WinLstCellGet(vMatNr, 1, vZeile);

      if (vMatNr = Mat.Nummer) then
        RETURN false;
    END;


    // Kunde Lesen
    if(RecLink(100,200,7,0) <> _rOK) then
      RecBufClear(100);

    // Daten in DL einfügen
    vDL->WinLstDatLineAdd(Mat.Nummer);

    if (vErr = 0) then begin
      vDL->WinLstCellSet(Mat.Dicke          ,2,_WinLstDatLineLast);
      vDL->WinLstCellSet(Mat.Breite         ,3,_WinLstDatLineLast);
      vDL->WinLstCellSet(Mat.Gewicht.Netto  ,4,_WinLstDatLineLast);
      vDL->WinLstCellSet(Mat.Gewicht.Brutto ,5,_WinLstDatLineLast);
      vDL->WinLstCellSet(Adr.Stichwort      ,6,_WinLstDatLineLast);
      $edKommission->wpCaption # Mat.Kommission;
    end
    else begin
      vDL->WinLstCellSet(Mat.Dicke          ,2,_WinLstDatLineLast);
      vDL->WinLstCellSet(Mat.Breite         ,3,_WinLstDatLineLast);
      vDL->WinLstCellSet(Mat.Gewicht.Netto  ,4,_WinLstDatLineLast);
      vDL->WinLstCellSet(Mat.Gewicht.Brutto ,5,_WinLstDatLineLast);
      case vErr of
        1 : begin vErrMsg # 'FEHLER: Material nicht gefunden'; end;
        2 : begin vErrMsg # 'FEHLER: Material ist gelöscht'; end;
        3 : begin vErrMsg # 'FEHLER: schon in Paket ' + Aint(Mat.Paketnr); end;
        4 : begin vErrMsg # 'FEHLER: falsche Kommission!!!'; end
      end;
      vDL->WinLstCellSet(vErrMsg            ,6,_WinLstDatLineLast);
    end;
    vDL->WinLstCellSet(Mat.Paketnr          ,7,_WinLstDatLineLast);
    vDL->WinLstCellSet(Mat.Ursprung         ,8,_WinLstDatLineLast);
    vDL->WinLstCellSet(false                ,9,_WinLstDatLineLast);

    _BMVerp_Sum($Pak.BM.Mat.Verpacken, $DLMats);

    vDL->wpAutoUpdate # true;
    // Weiter mit Mateiralnummerneingabe
    WinFocusSet($edMat);
    $edMat->wpCaption # '';

    return true;
  end;

end;


//========================================================================
//    sub _BMVerp_EvtLstDataInit(aEvt : Event;aRecId    : int; Opt aMark : logic; )
//
//========================================================================
sub _BMVerp_EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
)
local begin
  vCellHdl  : int;
  vCol      : int;
  vCell     : int;
  vStatus   : alpha;
  vInputCnt, vInputIO, vInputFail : int;
  i         : int;
  vMark     : logic;
end
begin

  // Daten lesen
  vCellHdl # aEvt:Obj;
  vCellHdl->WinLstCellGet(vStatus, 6, aRecId);

  vCol # _WinColWhite;
  if (StrFind(vStatus,'FEHLER:',1) > 0) then
    vCol # ColorRgbMake(255,161,135);

  vCellHdl->WinLstCellGet(vMark, 9, aRecId);

  if (vMark) then
    vCol # Set.Col.RList.Marke;
    
  // Zellen einer Zeile einfärben
  i # 0;
  FOR  vCell # vCellHdl->WinInfo( _winFirst, 0, _winTypeListColumn );
  LOOP vCell # vCell->   WinInfo( _winNext, 0, _winTypeListColumn );
  WHILE ( vCell != 0 ) DO BEGIN

    vCell->wpClmColBkg # vCol;
    inc(i);
    if (i%2 = 0) then begin
      vCell->wpClmColFocusBkg # vCol;
    end
    else begin
        vCell->wpClmColFocusBkg # _WinColLightYellow;
    end;
  END;

  RETURN;
end;



//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vQ    :  alpha(1000);
end
begin

  if ((aName =^ 'edPak.Lageradresse') AND (aBuf->Pak.Lageradresse<>0)) then begin
    RekLink(100,280,3,0);   // Lageradresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edPak.Lageranschrift') AND (aBuf->Pak.Lageranschrift<>0)) then begin
    RekLink(101,280,2,0);   // Lageranschrift holen
    Adr.A.Adressnr # Pak.Lageradresse;
    Adr.A.Nummer # Pak.Lageranschrift;
    RecRead(101,1,0);
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Pak.Lageradresse);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung', vQ);
    RETURN;
  end;
  
  if ((aName =^ 'edPak.Zwischenlage') AND (aBuf->Pak.Zwischenlage<>'')) then begin
    ULa.Bezeichnung # Pak.Zwischenlage;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edPak.Unterlage') AND (aBuf->Pak.Unterlage<>'')) then begin
    ULa.Bezeichnung # Pak.Unterlage;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edPak.Umverpackung') AND (aBuf->Pak.Umverpackung<>'')) then begin
    ULa.Bezeichnung # Pak.Umverpackung;
    RecRead(838,2,0);
    Lib_Guicom2:JumpToWindow('ULa.Verwaltung');
    RETURN;
  end;
  
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
