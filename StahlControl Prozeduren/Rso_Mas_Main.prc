@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Mas_Main
//                        OHNE E_R_G
//  Info
//
//
//  13.08.2003  ST  Erstellung der Prozedur
//  13.04.2004  FR  Löschprozedur für untergeordnete Datensätze: DeleteMAS()
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
//    SUB AusMasnahmen()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecid : int);
//    SUB EvtClose(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB DeleteMAS()
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Maßnahmen'
  cFile :     167
  cMenuName : 'Rso.Mas.Bearbeiten'
  cPrefix :   'Rso_Mas'
  cZList :    $ZL.Rso.Massnahmen
  cKey :      1
end;

declare Pflichtfelder();
declare DeleteMAS();

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

Lib_Guicom2:Underline($edRso.Mas.Masnahme);

  // Auswahlfelder setzen...
  SetStdAusFeld('edRso.Mas.Masnahme' ,'MASNAHMEN');

  $Lb.Ressource       -> wpcaption # AInt(Rso.Nummer);
  $Lb.Ressourcenname  -> wpcaption # Rso.Bezeichnung1;
  $Lb.Ressource2      -> wpcaption # AInt(Rso.Nummer);
  $Lb.Ressourcenname2 -> wpcaption # Rso.Bezeichnung1;
  $Lb.Nummer        -> wpcaption # AInt(Rso.IHA.Nummer);
  $Lb.Wartung       -> wpcaption # AInt(Rso.IHA.Wartung);
  $Lb.Nummer2       -> wpcaption # AInt(Rso.IHA.Nummer);
  $Lb.Wartung2      -> wpcaption # AInt(Rso.IHA.Wartung);
  $Lb.Ursnummer     -> wpcaption # AInt(Rso.Urs.Nummer);
  $Lb.Ursnummer2    -> wpcaption # AInt(Rso.Urs.Nummer);

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

  if (aName='') or (aName='edRso.Mas.Masnahme') then begin
    "IHA.Maß.Nummer"  # "Rso.Maß.Maßnahme";
    Erx # RecRead(825,1,0);
    if (Erx<=_rLocked) then
      $Lb.Massnahme   -> wpCaption # "IHA.Maß.Bezeichnung";
    else
      $Lb.Massnahme   -> wpCaption # '';
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

  If (Mode=c_ModeNew) then begin
    /*RecLink(167,166,1,_RecLast);
    vNr # "Rso.Maß.Nummer" + 1;
    RecBufClear(167);*/

    vNr # Lib_Nummern:ReadNummer('Massnahmen');
    if (vNr <> 0) then Lib_Nummern:SaveNummer();
    else Debug('Reservierung fehlgeschlagen');

    "Rso.Maß.Nummer"  # vNr;
  end;

  "Rso.Maß.Gruppe"    # Rso.Urs.Gruppe;
  "Rso.Maß.Ressource" # Rso.Urs.Ressource;
  "Rso.Maß.WartungYN" # Rso.Urs.WartungYN;
  "Rso.Maß.IHA"       # Rso.Urs.IHA;
  "Rso.Maß.Ursache"   # Rso.Urs.Nummer;

  // Schlüsselfelder an MAske übergeben
  RefreshIfm();

  $edRso.Mas.Masnahme->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vTmp  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If ("Rso.Maß.Maßnahme"=0) then begin
    Msg(001200,Translate('Maßnahme'),0,0,0);
    vTmp # gMdi->winsearch('edRso.Maß.Maßnahme');
    if (vTmp<>0) then vTmp->winFocusSet();
    RETURN false;
  end;

  if ("Rso.Maß.Maßnahme"<>0) then begin
    Erx # RecLink(825,167,3,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Maßnahme'),0,0,0);
      vTmp # gMdi->winsearch('edRso.Maß.Maßnahme');
      if (vTmp<>0) then vTmp->winFocusSet();
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

  Erx # Msg(167000,'',4,2,1);
  if (Erx = _WinIdOk) then begin
    DeleteMAS();
    RekDelete(gFile,0,'MAN');
  end;

  Erx # RecRead(167,1,1); // Für Zugriffsliste
  if (Erx > _rLocked) then
    RecBufClear(167);
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
end;

begin

  case aBereich of
    'MASNAHMEN' : begin
      RecBufClear(825);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'IHA.MAs.Verwaltung','Rso_Mas_Main:AusMasnahmen');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  End;
end;


//========================================================================
//  AusMasnahmen
//
//========================================================================
sub AusMasnahmen()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(825,0,_RecId,gSelected);

    "Rso.Maß.Maßnahme" # "IHA.Maß.Nummer";
    $Lb.Massnahme -> wpcaption # "IHA.MAß.Bezeichnung";

    // Feldübernahme
    gSelected # 0;

    vTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (vTMP<>0) then vTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edRso.Mas.Masnahme->Winfocusset(true);
  // ggf. Labels refreshen

  RefreshIfm();
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

  $Rso.Mas.Verwaltung->wpVisible # true; // Einblenden

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Mas_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Mas_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Mas_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Mas_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Mas_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Mas_Loeschen]=n);

  // Deaktivieren wenn keine Maßnahmen vorhanden sind
  if (!(RecLink(167,166,1,_RecTest) = _rOk)) then begin
    vHdl # gMenu->WinSearch('Mnu.Ersatzteile');
    if (vHdl <> 0) then
      vHdl->wpDisabled # true;

    vHdl # gMenu->WinSearch('Mnu.Ressourcen');
    if (vHdl <> 0) then
      vHdl->wpDisabled # true;
  end
  else begin
    vHdl # gMenu->WinSearch('Mnu.Ersatzteile');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false;

    vHdl # gMenu->WinSearch('Mnu.Ressourcen');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false;
  end;

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
  vHdl    : int;
  vFilter : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Ersatzteile' : begin
      RecBufClear(168);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Ert.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Ressourcen' : begin
      RecBufClear(169);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Rso.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(169,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,"Rso.Maß.Gruppe");
      vFilter->RecFilterAdd(2,_FltAND,_FltEq,"Rso.Maß.Ressource");
      vFilter->RecFilterAdd(3,_FltAND,_FltEq,"Rso.Maß.WartungYN");
      vFilter->RecFilterAdd(4,_FltAND,_FltEq,"Rso.Maß.IHA");
      vFilter->RecFilterAdd(5,_FltAND,_FltEq,"Rso.Maß.Ursache");
      vFilter->RecFilterAdd(6,_FltAND,_FltEq,"Rso.Maß.Nummer");
      gZLList->wpDbFilter # vFilter;
      Lib_GuiCom:RunChildWindow(gMDI);
      gMdi->WinUpdate(_WinUpdOn);
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
    'bt.Massnahme' :   Auswahl('MASNAHMEN');
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
  if (RecLink(825,167,3,0)>_rLocked) then RecBufClear(825);

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
  RecRead(167,1,0);
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
  Lib_GuiCom:Pflichtfeld($edRso.Mas.Masnahme);
end;

//========================================================================
//  DeleteMAS
//      Löscht Datensätze unter MAS
//========================================================================
sub DeleteMAS()
local begin
  vFlags : int;
end;
begin
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
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edRso.Mas.Masnahme') AND (aBuf->"Rso.Maß.Maßnahme"<>0)) then begin
    RekLink(825,167,3,0);   // Maßnahme holen
    Lib_Guicom2:JumpToWindow('IHA.MAs.Verwaltung');
    RETURN;
  end;
 
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================