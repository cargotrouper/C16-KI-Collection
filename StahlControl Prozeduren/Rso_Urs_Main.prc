@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Urs_Main
//                  OHNE E_R_G
//  Info
//
//
//  08.08.2003  ST  Erstellung der Prozedur
//  13.04.2004  FR  Löschprozedur für untergeordnete Datensätze: DeleteURS()
//  04.02.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusUrsachen()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecid : int);
//    SUB EvtClose(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB DeleteURS()
//
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Ursachen'
  cFile :     166
  cMenuName : 'Rso.Urs.Bearbeiten'
  cPrefix :   'Rso_Urs'
  cZList :    $ZL.Rso.Ursachen
  cKey :      1
end;

declare Pflichtfelder();
declare DeleteURS();

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

Lib_Guicom2:Underline($edRso.Urs.Ursache);

  SetStdAusFeld('edRso.Urs.Ursache' ,'URSACHEN');

  $Lb.Ressource       -> wpcaption # AInt(Rso.Nummer);
  $Lb.Ressourcenname  -> wpcaption # Rso.Bezeichnung1;
  $Lb.Ressource2      -> wpcaption # AInt(Rso.Nummer);
  $Lb.Ressourcenname2 -> wpcaption # Rso.Bezeichnung1;
  $Lb.Nummer          -> wpcaption # AInt(Rso.IHA.Nummer);
  $Lb.Wartung         -> wpcaption # AInt(Rso.IHA.Wartung);
  $Lb.Nummer2         -> wpcaption # AInt(Rso.IHA.Nummer);
  $Lb.Wartung2        -> wpcaption # AInt(Rso.IHA.Wartung);

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx : int;
end;
begin

  if (aName='') or (aName='edRso.Urs.Ursache') then begin
    IHA.Urs.Nummer  # Rso.Urs.Ursache;

    Erx # RecRead(824,1,0);
    if (Erx<=_rLocked) then
      $LB.Ursache   -> wpCaption # IHA.Urs.Bezeichnung;
    else
      $LB.Ursache   -> wpCaption # '';
  end;

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
  vNr : int;
end;
begin

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  If (Mode=c_ModeNew) then begin
    /*RecLink(166,165,1,_RecLast);
    vNr # Rso.URS.Nummer + 1;
    RecBufClear(166);*/

    vNr # Lib_Nummern:ReadNummer('Ursachen');
    if (vNr <> 0) then Lib_Nummern:SaveNummer();
    else Debug('Reservierung fehlgeschlagen');

    Rso.Urs.Nummer      # vNr;
  end;

  Rso.Urs.Gruppe      # Rso.IHA.Gruppe;
  Rso.Urs.Ressource   # Rso.IHA.Ressource;
  Rso.Urs.WartungYN   # Rso.IHA.WartungYN;
  Rso.Urs.IHA         # Rso.IHA.Nummer;

  // Schlüsselfelder an Maske übergeben
  RefreshIfm();

  // Focus setzen auf Feld:
  $edRso.Urs.Ursache->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  iNummer : int;        // Nummer für neuanlage
  vTmp    : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If (Rso.Urs.Ursache=0) then begin
    Msg(001200,Translate('Ursache'),0,0,0);
    vTmp # gMdi->winsearch('edRso.Urs.Ursache');
    if (vTmp<>0) then
     vTmp->winFocusSet();
    RETURN false;
  end;

  if (Rso.Urs.Ursache<>0) then begin
    Erx # RecLink(824,166,2,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Ursache'),0,0,0);
      vTmp # gMdi->winsearch('edRso.Urs.Ursache');
      if (vTmp<>0) then
       vTmp->winFocusSet();
      RETURN false;
    end;
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
local begin
  Erx : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  Erx # Msg(166000,'',4,2,1);
  if (Erx = _WinIdOk) then begin
    DeleteURS();  // löscht untergeordnete Datensätze
    RekDelete(gFile,0,'MAN');
  end;

  Erx # RecRead(166,1,1); // Für Zugriffsliste
  if (Erx > _rLocked) then
    RecBufClear(166);
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
  RefreshIfm();

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
    'URSACHEN' : begin
      RecBufClear(824);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'IHA.Urs.Verwaltung','Rso_Urs_Main:AusUrsachen');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusUrsachen
//
//========================================================================
sub AusUrsachen()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(824,0,_RecId,gSelected);

    Rso.Urs.Ursache # IHA.Urs.Nummer;
    $lb.Ursache -> wpcaption # IHA.Urs.Bezeichnung;

    // Feldübernahme
    gSelected # 0;

    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edRso.Urs.Ursache->Winfocusset(true);
  // ggf. Labels refreshen

  RefreshIfm('LB.Ursache');
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

  $Rso.Urs.Verwaltung->wpVisible # true; // Einblenden

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Urs_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Urs_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Urs_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Urs_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Urs_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Urs_Loeschen]=n);

  // Deaktiviern, wenn keine Ursachen vorhanden sind

  if (!(RecLink(166,165,1,_RecTest) = _rOk)) then begin
    vHdl # gMdi->WinSearch('Mnu.Massnahmen');
    if (vHdl <> 0) then
      vHdl->wpDisabled # true;
  end
  else begin
    vHdl # gMdi->WinSearch('Mnu.Massnahmen');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false;
  end;

  RefreshIfm();


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
  vFilter : int;
  vFlag   : int;
  vTmp    : int;
  vQ      : alpha(4096);
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Massnahmen' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Mas.Verwaltung','',y);
      RecBufClear(167);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
/***
      vFilter # RecFilterCreate(167,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,Rso.Urs.Gruppe);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq,Rso.Urs.Ressource);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq,Rso.Urs.WartungYN);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq,Rso.Urs.IHA);
      vFilter->RecFilterAdd(5,_FltAND,_FltEq,Rso.Urs.Nummer);
      gZLList->wpDbFilter # vFilter;
***/
      vQ # '';
      Lib_Sel:QInt(var vQ, '"Rso.Maß.Gruppe"', '=', Rso.Urs.Gruppe);
      Lib_Sel:QInt(var vQ, '"Rso.Maß.Ressource"', '=', Rso.Urs.Ressource);
      Lib_Sel:QLogic(var vQ, '"Rso.Maß.WartungYN"', Rso.Urs.WartungYN);
      Lib_Sel:QInt(var vQ, '"Rso.Maß.IHA"', '=',    Rso.Urs.IHA);
      Lib_Sel:QInt(var vQ, '"Rso.Maß.Ursache"', '=', Rso.Urs.Nummer);
      vHdl # SelCreate(167, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);

      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
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
    'bt.Ursache' :   Auswahl('URSACHEN');
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
  if (RecLink(824,166,2,0)>_rLocked) then RecBufClear(824);
  App_Main:Refreshmode();
end;


//========================================================================
//  EvtLstSelect
//
//========================================================================
sub EvtLstSelect(
                        aEvt      : event;
                        aRecid    : int;
                   );
begin
  RecRead(166,1,0);
  App_Main:Refreshmode();    // Aktivieren/Deaktivieren von Datansatzabhängigen Menüpunkten
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
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edRso.Urs.Ursache);
end;

//========================================================================
//  DeleteURS
//      Löscht Datensätze unter URS
//========================================================================
sub DeleteURS()
local begin
  vFlags : int;
end;
begin
    vFlags # _recFirst;
    WHILE (RecLink(167,166,1,vFlags) <= _rLocked) DO BEGIN

      vFlags # _recFirst;
      WHILE (RecLink(168,167,1,vFlags) <= _rLocked) DO BEGIN
        HuB_Data:MengenBewegung(Rso.ErT.Artikelnr,Rso.ErT.Menge,'IHA:'+AInt(Rso.ErT.IHA)+'/'+AInt(Rso.ErT.Ursache)+'/'+AInt("Rso.ErT.Maßnahme")+'/'+AInt(Rso.ErT.Nummer)+' Zuteilung gelöscht')
        RekDelete(168,0,'MAN');
        vFlags # _recNext;
      END;

      vFlags # _recFirst;
      WHILE (RecLink(169,167,2,vFlags) <= _rLocked) DO BEGIN
        RekDelete(169,0,'MAN');
        vFlags # _recNext;
      END;
      RekDelete(167,0,'MAN');
      vFlags # _recNext;
    END;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edRso.Urs.Ursache') AND (aBuf->Rso.Urs.Ursache<>0)) then begin
    RekLink(824,166,2,0);   // Ursache holen
    Lib_Guicom2:JumpToWindow('IHA.Urs.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================