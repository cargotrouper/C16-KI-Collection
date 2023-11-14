@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_SLK_Main
//                  OHNE E_R_G
//  Info
//
//
//  09.07.2007  AI  Erstellung der Prozedur
//  07.06.2016  AH  Directory auf %temp%
//  04.04.2022  AH  ERX
//  14.07.2022  HA  Quick Jump
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
//    SUB AusSL()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//    SUB EvtKeyItem_TV(aEvt : event; aKey : int; aID : int) : logic;
//    SUB EvtMouseItem_TV(aEvt : event; aButton : int; aHitTest : int; aItem : handle; aID : int) : logic;

//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Artikelstrukturen'
  cFile       : 255
  cMenuName   : 'Art.SLK.Bearbeiten'
  cPrefix     : 'Art_SLK'
  cZList      : $ZL.Art.SLK
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

Lib_Guicom2:Underline($edArt.SLK.Artikelnr);

  SetStdAusFeld('edArt.SLK.Artikelnr'    ,'Artikel');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  EvtMDiActivate
//
//========================================================================
sub EvtMdiActivate(
  aEvt                 : event;    // Ereignis
) : logic;
begin

  if (gZLlist->wpdbLinkFileNo=0) then begin
    $edArt.SLK.Artikelnr->wpcustom # '_E';
    $bt.Artikel->wpcustom # '_E';
  end;

  APP_Main:EvtMdiActivate(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder
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
  vTree     : int;
  vHdl      : int;
end;
begin

  // Struktur anzeigen?
  if (Mode=c_ModeView) and (aName='') then begin
    vTree # gMDI->winsearch('TV.Stueckliste');
    if (vTree->wpcustom<>Art.SLK.Artikelnr+cnvai(art.slk.Nummer)) then begin
      vTree->wpcustom # Art.SLK.Artikelnr+cnvai(art.slk.Nummer);
      vTree->wpautoupdate # false;
      vTree->WinTreeNodeRemove();
      Art_SL_Data:BuildTree(vTree,0, 1.0);
//  $dl.Stueckliste->WinLstDatLineAdd('START '+mode,_WinLstDatLineLast);
      vTree->wpautoupdate # true;
    end;
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

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  vTree : int;
end;
begin
  if (Mode=c_ModeNew) then begin
    Art.SLK.ARtikelnr # Art.Nummer;

    if (w_appendnr=0) then begin
      $TV.Stueckliste->WinTreeNodeRemove();
      $TV.Stueckliste->wpcustom # '';
      end
    else begin
      vTree # gMDI->winsearch('TV.Stueckliste');
//      if (vTree->wpcustom<>Art.SLK.Artikelnr+cnvai(art.slk.Nummer)) then begin
        RecRead(255,0,_RecId,w_AppendNr);
        vTree->wpcustom # Art.SLK.Artikelnr+cnvai(art.slk.Nummer);
        vTree->wpautoupdate # false;
        vTree->WinTreeNodeRemove();
        Art_SL_Data:BuildTree(vTree,0, 1.0);
        vTree->wpautoupdate # true;
//      end;
    end;
  end;
  // Focus setzen auf Feld:
  $edArt.SLK.Name->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vArt    : Alpha;
  vNr     : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // Artikel vorhanden?
  Erx # RecLink(250,255,1,_RecTest);
  if (Erx <> _rOK) then begin
    Msg(001201,Translate('Artikel'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.SLK.Artikelnr->WinFocusSet(true);
    RETURN false;
  end;


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
    Art.SLK.Anlage.Datum  # Today;
    Art.SLK.Anlage.Zeit   # Now;
    Art.SLK.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (w_appendnr<>0) then begin
      vArt            # Art.SLK.Artikelnr;
      vNr             # Art.SLK.Nummer;

      RecRead(255,0,_RecId,w_AppendNr);
      w_AppendNr # 0;
      Erx # RecLink(256,255,2,_recfirst);   // Sl loopen
      WHILE (Erx<=_rLockeD) do begin
        Art.SL.Artikelnr  # vArt;
        Art.SL.Nummer     # vNr;
        Rekinsert(256,_recunlock,'MAN');
        Art.SL.Artikelnr  # Art.SLK.Artikelnr;
        Art.SL.Nummer     # Art.SLK.Nummer;
        Erx # RecLink(256,255,2,_recNext);
      END;
    end;
  end;

  Art_SL_Data:RecalcSLK(true);
  $edArt.SLK.Fert.Dauer->winupdate(_WinUpdFld2Obj);

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

  if ("Art.Stückliste"=Art.SLK.Nummer) then begin
todo('Die Stückliste wird verwendet!!!');
    RETURN;
  end;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    TRANSON;
    Erx # RecLink(256,255,2,_RecFirst); // SL löschen
    WHILE (Erx<=_rLocked) do begin
      Erx # Rekdelete(256,0,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RETURN;
      end;
      Erx # RecLink(256,255,2,_RecFirst); // SL löschen
    END;

    Erx # RekDelete(gFile,0,'MAN');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RETURN;
    end;
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
begin

  case aBereich of
    'Artikel' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
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
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.SLK.ArtikelNr # Art.Nummer ;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  gMDI->Winupdate();

  // Focus setzen:
  $edArt.SLK.Artikelnr->Winfocusset(false);
end;


//========================================================================
//  AusSL
//
//========================================================================
sub AusSL()
begin
  gSelected # 0;
  RecRead(255,1,0);
  gMDi->winupdate();
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : int;
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
  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_SL_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_SL_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_SL_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_SL_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_SL_Loeschen]=n);

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
  vHdl      : int;
  vBildName : alpha(1000);
  vTextName : alpha(1000);
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Graph' : begin
      FsiPathCreate(_Sys->spPathTemp+'StahlControl');
      FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
      vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
      vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';
      // Graphtext erzeugen
      Art_SL_Graph:BuildText(vTextName);
      // Graph erstellen
      SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_exechidden|_execwait);
      // externes Bild anzeigen
      Dlg_Bild('*'+vBildName);
    end;


    'Mnu.Copy' : begin
      w_AppendNr # RecInfo(255,_recId);
      App_Main:Action(c_ModeNew);
      RETURN true;
    end;


    'Mnu.SL' : begin
      RecBufClear(251);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.SL.Verwaltung',here+':AusSL',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Art.SLK.Anlage.Datum, Art.SLK.Anlage.Zeit, Art.SLK.Anlage.User);
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
    'bt.Artikel'  :   Auswahl('Artikel');
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
  Erx     : int;
  vBuf250 : int;
  vNr     : int;
end;
begin

  vNr # "Art.Stückliste";

  if (Art.Nummer<>Art.SLK.ArtikelNr) then begin
    vBuf250 # RecBufCreate(250);
    Erx # RecLink(vBuf250,255,1,_RecFirst);   // ARtikel holen
    vNr # vBuf250->"Art.Stückliste";
    RecBufDestroy(vBuf250);
  end;

  if (aMark=n) then begin
    if (vNr<>Art.SLK.Nummer) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
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
local begin
  Erx : int;
end;
begin

  if (gZLlist->wpdbLinkFileNo=0) then
    Erx # RecLink(250,255,1,_RecFirst);   // ARtikel holen

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

  if (aFlags & _WinPosSized != 0) then begin
    vRect           # $TV.Stueckliste->wpArea;
//    vRect:right     # aRect:right-61;
//    vRect:bottom    # aRect:bottom-200;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28;//-60;
    $TV.Stueckliste->wparea # vRect;
  end;
	RETURN App_Main:EvtPosChanged(aEvt, aRect, aClientSize, aFlags);
end;


//========================================================================
//  EvtKeyItem_TV
//
//========================================================================
sub EvtKeyItem_TV(
  aEvt                 : event;    // Ereignis
  aKey                 : int;      // Taste
  aID                  : int;      // RecID bei RecList, Node-Deskriptor bei TreeView
) : logic;
local begin
  vArt  : alpha;
  vHdl  : int;
  vHdl2 : int;
  H1,H2 : int;
end;
begin

  if (aID=0) then RETURN true;
/**
debug('key:'+aint(aKey)+'  ret:' +aint(_Winkeyreturn)+'   sel:'+aint(_WinKeySelect));
debug('key & RET :'+aint(aKey & _WinKeyReturn));
debug('key & SEL :'+aint(aKey & _WinKeyselect));
h1 # aKey & _WinKeyReturn;
h2 # aKey & _WinKeySelect;
debug('H1:'+aint(H1)+'   H2'+aint(H2));
if (H1>0) or (H2>0) then todo('XXX');
RETURN true;
***/

  // ales Artikelfenster umpositionieren...
  if (aKey & _WinKeyShift=_WinKeyShift) and
    ((aKey & _WinKeyReturn=_WinKeyReturn) or (aKey & _WinKeySelect=_WinKeySelect)) then begin
    vArt # aID->wpcustom;
    if (vArt<>'') then begin
      vHDL # w_Parent;

      vHdl2 # Varinfo(windowbonus);
      VarInstance(windowbonus, cnvia(vHDL->wpcustom));
      Art.Nummer # vArt;
      RecRead(250,1,0);
      gSelected # recinfo(250,_recID);
      VarInstance(windowbonus, vHdl2);

      mode # c_modeList;
      gMDI->winclose();
      RETURN true;
    end;
  end;


  // neues Artikelfenster öffnen...
  if (aKey & _WinKeyShift=0) and
    ((aKey & _WinKeyReturn=_WinKeyREturn) or (aKey & _WinKeySelect=_WinKeySelect)) then begin
    vArt # aID->wpcustom;
    if (vArt<>'') then begin
      vHDL # w_Parent;

      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vHdl2 # gMDI->wpDbRecBuf(250);
      vHdl2->art.Nummer # vArt;
      mode # c_ModeBald + c_ModeView;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;


  RETURN(true);

end;


//========================================================================
//  ErvMouseItem_TV
//
//========================================================================
sub EvtMouseItem_TV(
  aEvt                 : event;    // Ereignis
  aButton              : int;      // Maustaste
  aHitTest             : int;      // Hittest-Code
  aItem                : handle;   // Spalte oder Gantt-Intervall
  aID                  : int;      // RecID bei RecList / Zelle bei GanttGraph / Druckobjekt bei PrtJobPreview
)
: logic;
local begin
  vArt  : alpha;
  vHdl  : int;
  vHdl2 : int;
end;
begin

  if (aHitTest=_WinHitTreeNode) then begin

    // neues Artikelfenster öffnen...
    if (aButton & _WinMouseDouble>0) and
        (aButton & _WinMouseLeft>0) then begin
      vArt # aItem->wpcustom;
      if (vArt<>'') then begin
        vHDL # w_Parent;

        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung','',y);
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        vHdl2 # gMDI->wpDbRecBuf(250);
        vHdl2->Art.Nummer # vArt;
        mode # c_ModeBald + c_ModeView;
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    // altes Artikelfenster umpositionieren...
    if (aButton & _WinMouseDouble>0) and
        (aButton & _WinMouseRight>0) then begin
      vArt # aitem->wpcustom;
      if (vArt<>'') then begin
        vHDL # w_Parent;

        vHdl2 # Varinfo(windowbonus);
        VarInstance(windowbonus, cnvia(vHDL->wpcustom));
        Art.Nummer # vArt;
        RecRead(250,1,0);
        gSelected # recinfo(250,_recID);
        VarInstance(windowbonus, vHdl2);

        mode # c_modeList;
        gMDI->winclose();
        RETURN true;
      end;
    end;

    RETURN(true);
  end;

end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edArt.SLK.Artikelnr') AND (aBuf->Art.SLK.Artikelnr<>'')) then begin
    RekLink(250,255,1,0);   // Artikel Nummer holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
 
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================