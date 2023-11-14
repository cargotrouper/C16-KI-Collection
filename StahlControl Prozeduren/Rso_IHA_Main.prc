@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_IHA_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  25.03.2004  FR  Neue Subprozedur KopieVonWartung(..)
//  07.04.2004  FR  Kopie von Wartung mit Änderung der Ert-Menge
//  13.04.2004  FR  Löschprozedur für untergeordnete Datensätze: DeleteIHA()
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
//    SUB AusMeldung()
//    SUB AusErsatzteil()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecid : int);
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB Auswahl_EvtMdiActivate(aEvt : event) : logic
//    SUB AuswahlExit()
//    SUB Pflichtfelder();
//    SUB KopieVonWartung(aWartung : int) : logic;
//    SUB DeleteIHA()
//
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle     : 'Instandhaltungen'
  cFile      : 165
  cMenuName  : 'Rso.IHA.Bearbeiten'
  cPrefix    : 'Rso_IHA'
  cZList     : $ZL.Rso.IHA
  cKey       : 1

  cDokumente : '*.doc;*.xls;*.txt;*.pdf;*.rtf'
end;

declare KopieVonWartung(aWartung : int) : logic;
declare Pflichtfelder();
declare DeleteIHA();

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

Lib_Guicom2:Underline($edRso.IHA.Meldung);

  SetStdAusFeld('edRso.IHA.Meldung' ,'Meldung');
  SetStdAusFeld('edRso.IHA.externesDok' ,'DOKUMENT' );

  $Lb.Ressource       -> wpcaption # AInt(Rso.Nummer);
  $Lb.Ressourcenname  -> wpcaption # Rso.Bezeichnung1;
  $Lb.Ressource2      -> wpcaption # AInt(Rso.Nummer);
  $Lb.Ressourcenname2 -> wpcaption # Rso.Bezeichnung1;

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm ( opt aName : alpha; opt aChanged : logic )
local begin
  Erx : int;
end;
begin

  if (aName='') or (aName='edRso.IHA.Meldung') then begin
    Erx # RecLink(823,165,2,0);
    if (Erx<=_rLocked) then
      $Lb.Meldung->wpcaption # IHA.Mld.Bezeichnung
    else
      $Lb.Meldung->wpcaption # '';
  end;

  if (aName='') then begin
    $Lb.Nummer2         -> wpcaption # aint(Rso.Iha.Nummer);

    if (Rso.IHA.Wartung<>0) then begin
      $Lb.Wartung2 -> wpcaption # AInt(Rso.IHA.Wartung);
    end
    else begin
      $Lb.Wartung2 -> wpcaption # '';
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
local begin
  vNr : int;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  If (Mode=c_ModeNew) then begin
    /*RecRead(165,1,_Reclast);
    vNr # Rso.IHA.Nummer + 1;*/

    vNr # Lib_Nummern:ReadNummer('Instandhaltungen');
    if (vNr <> 0) then Lib_Nummern:SaveNummer();
    else Debug('Reservierung fehlgeschlagen');

    RecBufClear(165);

    Rso.IHA.Gruppe    # Rso.Gruppe;
    Rso.IHA.Ressource  # Rso.Nummer;
    Rso.IHA.Nummer    # vNr;
    Rso.IHA.WartungYN # false;
  end;

  // Focus setzen auf Feld:
  $edRso.IHA.Meldung->WinFocusSet(true);

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

  /*if (Rso.IHA.Meldung=0) then begin
    Msg(001200,Translate('Meldung'),0,0,0);
    vTmp # gMdi->winsearch('edRso.IHA.Meldung');
    if (vTmp<>0) then
     vTmp->winFocusSet();
    RETURN false;
  end;*/  // Meldung darf 0 sein

  if (Rso.IHA.Meldung<>0) then begin
    Erx # RecLink(823,165,2,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Meldung'),0,0,0);
      vTmp # gMdi->winsearch('edRso.IHA.Meldung');
      if (vTmp<>0) then
       vTmp->winFocusSet();
      RETURN false;
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
    REPEAT
      Rso.IHA.Anlage.Datum  # SysDate();
      Rso.IHA.Anlage.Zeit   # Now;
      Rso.IHA.Anlage.User   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));

      Erx # RekInsert(gFile,0,'MAN');
      if (Erx<>_rOK) then
        Rso.IHA.Nummer # Rso.IHA.Nummer + 1;
    UNTIl (erx=_rOk);
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


  Erx # Msg(165000,'',4,2,1);
  if (Erx = _WinIdOk) then begin
    DeleteIHA();
    RekDelete(gFile,0,'MAN');
  end;

  Erx # RecRead(165,1,1); // Für Zugriffsliste
  if (Erx > _rLocked) then
    RecBufClear(165);
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
  vTmp  : int;
end;

begin

  case aBereich of
    'Meldung' : begin
      RecBufClear(823);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'IHA.Mld.Verwaltung',here+':AusMeldung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'DOKUMENT' : begin
      vTmp # WinOpen(_WinComFileopen,_WinOpenDialog);
      if (vTmp<>0) then begin
        vTmp->wpFileFilter # 'Dokumente|' + cDokumente + '|Alle Dateien|*.*';
        if (vTmp->WinDialogRun(_WinDialogCenter,gMdi) = _rOK) then begin
          Rso.IHA.externesDok # StrFmt(vTmp->wpPathname+ vTmp->wpFileName,64,_StrEnd);
          $edRso.IHA.externesDok->wpcaption # Rso.IHA.externesDok;
          RefreshIfm('edRso.IHA.externesDok');
        end;
        WinClose(vTmp);
      end;
    end;


    'Ersatzteile' : begin
      RecBufClear(168);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Ert.Verwaltung',here+':AusErsatzteil');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpdisabled # false;
      vHdl # gMdi->WinSearch('Lb.Hidden');  // Versteckes Label-Feld in Rso.Ert.Verwaltung
      if (vHdl <> 0) then                   // an welchem erkannt wird, zu welchem Zweck die
        vHdl->wpcustom # 'IHA';             // Ersatzteile aufgerufen wurden
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusMeldung
//
//========================================================================
sub AusMeldung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(823,0,_RecId,gSelected);
    // Feldübernahme
    Rso.IHA.Meldung # IHA.Mld.Nummer;
    gSelected # 0;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edRso.IHA.Meldung->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusErsatzteil
//
//========================================================================

sub AusErsatzteil()
local begin
  Erx     : int;
  vFlags  : int;
end;
begin
  gSelected # 0;
  Erx # Msg(168000,'',5,3,1);

  if (Erx <> _WinIdYes) then begin
    Auswahl('Ersatzteile');
  end
  else begin
    // führt Verbuchung für Ersatzteile durch
    vFlags # _recFirst;
    while (RecLink(168,167,1,vFlags) <= _rLocked) do begin
      HuB_Data:MengenBewegung(Rso.ErT.Artikelnr,(-1.0)*Rso.ErT.Menge,'IHA:'+AInt(Rso.ErT.IHA)+'/'+AInt(Rso.ErT.Ursache)+'/'+AInt("Rso.ErT.Maßnahme")+'/'+AInt(Rso.ErT.Nummer)+' zugeteilt')
      vFlags # _recNext;
    end;
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

  //$Rso.IHA.Verwaltung->wpVisible # true; // Einblenden

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_IHA_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_IHA_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_IHA_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_IHA_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_IHA_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_IHA_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.WrtZuweisen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode <> c_ModeList) and (Mode <> c_ModeView);

  // Deaktivieren, wenn keine Instandhaltungen vorhanden sind
/***
  Rso.IHA.Gruppe    # Rso.Gruppe;
  Rso.IHA.Ressource # Rso.Nummer;
  Rso.IHA.WartungYN # false;
***/
  if (RecRead(165,1,_RecTest) >= _rNoKey) then begin
    vHdl # gMenu->WinSearch('Mnu.Ursachen');
    if (vHdl <> 0) then
      vHdl->wpDisabled # true;

    vHdl # gMenu->WinSearch('Mnu.WrtZuweisen');
    if (vHdl <> 0) then
      vHdl->wpDisabled # true;
  end
  else begin
    vHdl # gMenu->WinSearch('Mnu.Ursachen');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false;

    // Deaktivieren, wenn aktuelle IHA bereits Ursache hat
    if (RecLink(166,165,1,0) <> _rNoRec) then begin
      vHdl # gMenu->WinSearch('Mnu.WrtZuweisen');
      if (vHdl <> 0) then
        vHdl->wpDisabled # true;
    end
    else begin
      vHdl # gMenu->WinSearch('Mnu.WrtZuweisen');
      if (vHdl <> 0) then
        vHdl->wpDisabled # false;
    end;
  end;

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) then RefreshIfm();

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
  vTmp    : int;
  vQ      : alpha(4000);
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of
   
    'Mnu.Ursachen' : begin
      RecBufClear(824);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Urs.Verwaltung','',y);
/***
      vFilter # RecFilterCreate(166,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,Rso.IHA.Gruppe);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq,Rso.IHA.Ressource);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq,Rso.IHA.WartungYN);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq,Rso.IHA.Nummer);
      $ZL.Rso.Ursachen->wpDbFilter # vFilter;
***/
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Rso.Urs.Gruppe', '=', Rso.IHA.Gruppe);
      Lib_Sel:QInt(var vQ, 'Rso.Urs.Ressource', '=', Rso.IHA.Ressource);
      Lib_Sel:QLogic(var vQ, 'Rso.Urs.WartungYN', Rso.IHA.WartungYN);
      Lib_Sel:QInt(var vQ, 'Rso.Urs.IHA', '=', Rso.IHA.Nummer);

      vHdl # SelCreate(166, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);

      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.WrtZuweisen' : begin
      $ZL.Rso.IHA->wpCustom # CnvAI(RecInfo(165,_RecId));
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Wrt.Verwaltung',here+':AuswahlExit');

/***
      vFilter # RecFilterCreate(165,1);
      vFilter->RecFilterAdd(1,_FltAnd,_FltEq,Rso.Gruppe);
      vFilter->RecFilterAdd(2,_FltAnd,_FltEq,Rso.Nummer);
      vFilter->RecFilterAdd(3,_FltAnd,_FltEq,true);
      $ZL.Wartungsauswahl->wpDbFilter # vFilter;
***/
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Rso.IHA.Gruppe', '=', Rso.Gruppe);
      Lib_Sel:QInt(var vQ, 'Rso.IHA.Ressource', '=', Rso.Nummer);
      Lib_Sel:QLogic(var vQ, 'Rso.IHA.WartungYN', true);
      Lib_Sel:QInt(var vQ, 'Rso.IHA.Wartung', '=', 0);
      vHdl # SelCreate(165, 1);
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
      PtD_Main:View( gFile, Rso.IHA.Anlage.Datum, Rso.IHA.Anlage.Zeit, Rso.IHA.Anlage.User );
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
    'bt.Meldung' :   Auswahl('Meldung');
    'bt.Dokument' :   Auswahl('DOKUMENT');
    'bt.xxxxx' :   Auswahl('...');
  end;

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
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
                   );
begin
  //App_Main:Refreshmode();
  RecLink(823,165,2,0);  // Meldung holen
end;


//========================================================================
//  EvtLstSelect
//
//========================================================================
sub EvtLstSelect(
                        aEvt      : event;
                        aRecid    : int;
                   ) : logic;
begin
  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);
  //App_Main:Refreshmode();    // Aktivieren/Deaktivieren von Datansatzabhängigen Menüpunkten
end;

/***
//========================================================================
//  EvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
begin
//  RecRead(165,1,0);
  App_Main:Refreshmode();    // Aktivieren/Deaktivieren von Datansatzabhängigen Menüpunkten

  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    If $ZL.Wartungsauswahl->wpDbFilter <> 0 then
      RecFilterDestroy($ZL.Wartungsauswahl->wpDbFilter);
    $Rso.Wrt.Auswahl->Winclose();
  end;
end;
***/

/***
//========================================================================
//  EvtMouseItem
//                Mausclick in Auswahlliste
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin
  if (aItem=0) or (aID=0) then RETURN false;

  if ((aButton & _WinMouseLeft)<>0) and ((aButton & _WinMouseDouble)<>0) then begin
    gSelected # aID;
    If $ZL.Wartungsauswahl->wpDbFilter <> 0 then
      RecFilterDestroy($ZL.Wartungsauswahl->wpDbFilter);
    $Rso.Wrt.Auswahl->Winclose();
  end;

end;
***/


//========================================================================
//  Auswahl_EvtMdiActivate
//                          Fenster aktivieren
//========================================================================
sub Auswahl_EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  gTitle  # 'Wartung';
  gPrefix # 'Rso_IHA';
  gFrmMain->wpMenuname # 'Rso.Wrt.Auswahl';

  Call('App_Main:EvtMdiActivate',aEvt);
end;


//========================================================================
//  AuswahlExit
//
//========================================================================
sub AuswahlExit()
local begin
  Erx     : int;
  vNr     : int;
  vFilter : int;
end;
begin
  $ZL.Rso.IHA->wpdisabled # false;
  Lib_GuiCom:SetWindowState($Rso.Wrt.Auswahl,true);

  if (gSelected<>0) then begin

    RecRead(165,0,0,gSelected);
    vNr # Rso.IHA.Nummer;
    gSelected # 0;
    RecRead(165,0,_RecLock,CnvIA($ZL.Rso.IHA->wpCustom));
    Rso.IHA.Wartung # vNr;
    Erx # RekReplace(165,_RecUnlock,'MAN');
    If Erx<>_rOk then begin
      //Zuweisung existiert bereits!
      Msg(165001,'',_WinIcoError,_WinDialogOkCancel,1);
    end
    else begin
      KopieVonWartung(vNr);     // Kopiert Wartung als IHA mit Urs, Mas, Ert und Rso
     // Auswahl('Ersatzteile');   // Ermöglicht Benutzer das Ändern der Ersatzteile
    end;

  end;
  RecBufClear(165);

/***
  vFilter # RecFilterCreate(165,1);
  vFilter->RecFilterAdd(1,_FltAND,_FltEq,Rso.Gruppe);
  vFilter->RecFilterAdd(2,_FltAND,_FltEq,Rso.Nummer);
  vFilter->RecFilterAdd(3,_FltAND,_FltEq,false);
  $ZL.Rso.IHA->wpDbFilter # vFilter;
***/

  $ZL.Rso.IHA->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $ZL.Rso.IHA->WinFocusSet(y);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edRso.IHA.Meldung);
end;


//========================================================================
//  KopieVonWartung
//      Kopiert Wartung auf Instandhaltung
//========================================================================
sub KopieVonWartung(
    aWartung : int;
) : logic;
local begin
  Erx     : int;
  vIHANum : int;  // Für Nummernkreisreservierungen;
  vUrsNum : int;
  vMasNum : int;
  vErtNum : int;
  vRsoNum : int;

  vIHABuf : int;  // Puffer für Instandhaltung
  vGRPBuf : int;

  vGruppe     : word; // Schlüsselfelder zum Auslagern
  vRessource  : word;
  vIHA        : word;
  vURS        : word;
  vMAS        : word;
  vERT        : word;
  vRSO        : word;

  vFlags      : int;
end;
begin

  vIHANum # Rso.IHA.Nummer;

  vIHABuf # Rso.IHA.Nummer;
  vGRPBuf # Rso.IHA.Gruppe;

  Rso.IHA.Nummer # Rso.IHA.Wartung;
  Rso.IHA.WartungYN # true;
  Erx # RecRead(165,1,0); // KVW_Holen

  if (Erx <> 0) then begin
    Debug('Wartung konnte nicht kopiert werden (Breakpoint:"KVW_Holen")');
    return false;
  end;

  vFlags # _recFirst;
  WHILE (RecLink(166,165,1,vFlags) <= _rLocked) DO BEGIN
    vUrsNum #  Lib_Nummern:ReadNummer('Ursachen');
    if (vUrsNum <> 0) then
      Lib_Nummern:SaveNummer()
    else begin
      Debug('Reservierung fehlgeschlagen');
      BREAK;
    end;

    vFlags # _recFirst;
    WHILE (RecLink(167,166,1,vFlags) <= _rLocked) DO BEGIN
      vMasNum #  Lib_Nummern:ReadNummer('Massnahmen');
      if (vMasNum <> 0) then
        Lib_Nummern:SaveNummer()
      else begin
        Debug('Reservierung fehlgeschlagen');
        BREAK;
      end;

      vFlags # _recFirst;
      WHILE (RecLink(168,167,1,vFlags) <= _rLocked) DO BEGIN
        vErtNum #  Lib_Nummern:ReadNummer('Ersatzteile');
        if (vErtNum <> 0) then
          Lib_Nummern:SaveNummer()
        else begin
          Debug('Reservierung fehlgeschlagen');
          BREAK;
        end;

        vGruppe           # Rso.ErT.Gruppe;
        vRessource        # Rso.ErT.Ressource;
        vIHA              # Rso.ErT.IHA;
        vURS              # Rso.ErT.Ursache;
        vMAS              # "Rso.ErT.Maßnahme";
        vERT              # Rso.ErT.Nummer;

        Rso.ErT.Gruppe    # Rso.IHA.Gruppe;
        Rso.ErT.Ressource # Rso.IHA.Ressource;
        Rso.ErT.WartungYN # false;   // Aus Wartung wird IHA
        Rso.ErT.IHA       # vIHANum;
        Rso.ErT.Ursache   # vUrsNum;
       "Rso.ErT.Maßnahme" # vMasNum;
        Rso.ErT.Nummer    # vErtNum;

        RekInsert(168,0,'MAN');

        //Debug('Insert RSO: '  + CnvAI(vErtNum) + ' '  + CnvAI(Rso.Ert.Ursache) + ' ' + CnvAI(Rso.Ert.IHA) + ' ' + CnvAI(Rso.Ert.Ressource) + ' ' + CnvAI(Rso.Ert.Gruppe));

        Rso.ErT.Gruppe    # vGruppe;
        Rso.ErT.Ressource # vRessource;
        Rso.ErT.WartungYN # true;
        Rso.ErT.IHA       # vIHA;
        Rso.ErT.Ursache   # vURS;
       "Rso.ErT.Maßnahme" # vMAS;
        Rso.ErT.Nummer    # vERT;

        vFlags # _recNext;
      END;

      vFlags # _recFirst;
      WHILE (RecLink(169,167,2,vFlags) <= _rLocked) DO BEGIN
        vRsoNum #  Lib_Nummern:ReadNummer('Ressourcen');
        if (vRsoNum <> 0) then
          Lib_Nummern:SaveNummer()
        else begin
          Debug('Reservierung fehlgeschlagen');
          BREAK;
        end;

        vGruppe           # Rso.Rso.Gruppe;
        vRessource        # Rso.Rso.Ressource;
        vIHA              # Rso.Rso.IHA;
        vURS              # Rso.Rso.Ursache;
        vMAS              # "Rso.Rso.Maßnahme";
        vRso              # Rso.Rso.Nummer;

        Rso.Rso.Gruppe    # Rso.IHA.Gruppe;
        Rso.Rso.Ressource # Rso.IHA.Ressource;
        Rso.Rso.WartungYN # false;   // Aus Wartung wird IHA
        Rso.Rso.IHA       # vIHANum;
        Rso.Rso.Ursache   # vUrsNum;
       "Rso.Rso.Maßnahme" # vMasNum;
        Rso.Rso.Nummer    # vRsoNum;

        RekInsert(169,0,'MAN');

        //Debug('Insert RSO: '  + CnvAI(vRsoNum) + ' '  + CnvAI(Rso.Rso.Ursache) + ' ' + CnvAI(Rso.RSo.IHA) + ' ' + CnvAI(Rso.Rso.Ressource) + ' ' + CnvAI(Rso.Rso.Gruppe));

        Rso.Rso.Gruppe    # vGruppe;
        Rso.Rso.Ressource # vRessource;
        Rso.Rso.WartungYN # true;
        Rso.Rso.IHA       # vIHA;
        Rso.Rso.Ursache   # vURS;
       "Rso.Rso.Maßnahme" # vMAS;
        Rso.Rso.Nummer    # vRSO;

        vFlags # _recNext;
      END;

      vGruppe           # "Rso.Maß.Gruppe";
      vRessource        # "Rso.Maß.Ressource";
      vIHA              # "Rso.Maß.IHA";
      vURS              # "Rso.Maß.Ursache";
      vMAS              # "Rso.Maß.Nummer";

     "Rso.Maß.Gruppe"   # Rso.IHA.Gruppe;
     "Rso.Maß.Ressource"# Rso.IHA.Ressource;
     "Rso.Maß.WartungYN"# false;   // Aus Wartung wird IHA
     "Rso.Maß.IHA"      # vIHANum;
     "Rso.Maß.Ursache"  # vUrsNum;
     "Rso.Maß.Nummer"   # vMasNum;

      RekInsert(167,0,'MAN');

      //Debug('Insert MAS: '  + CnvAI(vMasNum) + ' '  + CnvAI("Rso.Maß.Ursache") + ' ' + CnvAI("Rso.Maß.IHA") + ' ' + CnvAI("Rso.Maß.Ressource") + ' ' + CnvAI("Rso.ErT.Gruppe"));

     "Rso.Maß.Gruppe"   # vGruppe;
     "Rso.Maß.Ressource"# vRessource;
     "Rso.Maß.WartungYN"# true;
     "Rso.Maß.IHA"      # vIHA;
     "Rso.Maß.Ursache"  # vURS;
     "Rso.Maß.Nummer"   # vMAS;

      vFlags # _recNext;
    END;

    vGruppe           # Rso.Urs.Gruppe;
    vRessource        # Rso.Urs.Ressource;
    vIHA              # Rso.Urs.IHA;
    vURS              # Rso.Urs.Nummer;

    Rso.Urs.Gruppe    # Rso.IHA.Gruppe;
    Rso.Urs.Ressource # Rso.IHA.Ressource;
    Rso.Urs.WartungYN # false;   // Aus Wartung wird IHA
    Rso.Urs.IHA       # vIHANum;
    Rso.Urs.Nummer    # vUrsNum;

    RekInsert(166,0,'MAN');

    //Debug('Insert URS: '  + CnvAI(vUrsNum) + ' ' + CnvAI(Rso.Urs.IHA) + ' ' + CnvAI(Rso.Urs.Ressource) + ' ' + CnvAI(Rso.Urs.Gruppe));

    Rso.Urs.Gruppe    # vGruppe;
    Rso.Urs.Ressource # vRessource;
    Rso.Urs.WartungYN # true;
    Rso.Urs.IHA       # vIHA;
    Rso.Urs.Nummer    # vURS;

    vFlags # _recNext
  END;

  // Kopien wurden erstellt
  // Editieren der kopierten Ersatzteile ermöglichen

  Rso.IHA.Nummer # vIHABuf;
  Rso.IHA.Gruppe # vGRPBuf;
  Rso.IHA.WartungYN # false;

  RecRead(165,1,0); // Laden der Instandhaltung

  vFlags # _recFirst;
  WHILE (RecLink(166,165,1,vFlags) <= _rLocked) DO BEGIN
    vFlags # _recFirst;
    WHILE (RecLink(167,166,1,vFlags) <= _rLocked) DO BEGIN
      vFlags # _recFirst;
      WHILE (RecLink(168,167,1,vFlags) <= _rLocked) DO BEGIN
        Auswahl('Ersatzteile');
        vFlags # _recNext;
      END;
      vFlags # _recNext;
    END;
    vFlags # _recNext;
  END;


  return true;
end;


//========================================================================
//  DeleteIHA
//      Löscht Datensätze unter IHA
//========================================================================
sub DeleteIHA()
local begin
  vFlags : int;
end;
begin
    vFlags # _recFirst;
  WHILE (RecLink(166,165,1,vFlags) <= _rLocked) DO BEGIN

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
    RekDelete(166,0,'MAN');
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

  if ((aName =^ 'edRso.IHA.Meldung') AND (aBuf->Rso.IHA.Meldung<>0)) then begin
    RekLink(823,165,2,0);   // Meldung holen
    Lib_Guicom2:JumpToWindow('IHA.Mld.Verwaltung');
    RETURN;
  end;
 
end;
//========================================================================
//========================================================================
//========================================================================
//========================================================================