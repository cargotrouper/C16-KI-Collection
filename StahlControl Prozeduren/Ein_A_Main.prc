@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_A_Main
//                  OHNE E_R_G
//  Info
//
//
//  30.03.2004  AI  Erstellung der Prozedur
//  10.05.2022  AH  ERX
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
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle :    'Aktionen'
  cFile :     504
  cMenuName : 'Ein.A.Bearbeiten'
  cPrefix :   'Ein_A'
  cZList :    $ZL.Ein.Aktionen
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
  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;
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
  Erx     : int;
  vTmp    : int;
end;
begin

  if (aName='') then begin
    // Adresse
    Erx # RecLink(100,504,2,_RecFirst);
    if (Erx<=_rLocked) then
      $Lb.Adresse->wpcaption # Adr.Stichwort
    else
      $Lb.Adresse->wpcaption # '';
    // Artikel
    Erx # RecLink(250,504,3,_RecFirst);
    if (Erx<=_rLocked) and (Ein.A.ArtikelNr<>'') then
      $Lb.Artikel->wpcaption # Art.Nummer
    else
      $Lb.Artikel->wpcaption # '';

    $Lb.MEH->wpcaption # Ein.A.MEH;
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
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
  Erx : int;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edEin.A.TerminStart->WinFocusSet(true);

  if (Mode=c_ModeNew) then begin
    recbufClear(504);
    Erx # RecLink(100,501,4,_Recfirst);   // Lieferant holen...
    Ein.A.Nummer        # Ein.P.Nummer;
    Ein.A.Position      # Ein.P.Position;
    Ein.A.Aktion        # 1;
    Ein.A.MEH           # Ein.P.MEH.Preis;
    Ein.A.Artikelnr     # Ein.P.Artikelnr;
    Ein.A.Adressnummer  # Adr.Nummer;
    Ein.A.TerminStart   # today;
    Ein.A.TerminEnde    # today;
    Ein.A.Aktionsdatum  # today;
    Ein.A.Aktionstyp    # 'MAN';
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
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
//    "xxx.Änderung.Datum"  # SysDate();
  //  "xxx.Änderung.Zeit"   # Now;
    //"xxx.Änderung.User"   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    Ein.A.Anlage.Datum  # Today;
    Ein.A.Anlage.Zeit   # Now;
    Ein.A.Anlage.User   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));
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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  RekDelete(gFile,0,'MAN');
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
end;
begin
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_A_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_A_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_A_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_A_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_A_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_A_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Sperre');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (mode<>c_ModeView)) or (Rechte[Rgt_Ein_A_Sperre]=n) or
                      (Ein.A.Aktionstyp<>c_Akt_Sperre);

  if (Mode<>c_ModeOther) then RefreshIfm();

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
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Sperre' : begin
      if (Rechte[Rgt_Ein_A_Sperre]=n) or (Ein.A.Aktionstyp<>c_Akt_Sperre) then RETURN true;
      Ein_A_Data:SperreUmsetzen();
    end;


    'Mnu.RecalcPos' : begin
      if (Ein_A_Data:RecalcAll()=false) then begin
        ErrorOutput;
        RETURN false;
      end;
      Msg(999998,'',0,0,0);
      RETURN true;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Ein.A.Anlage.Datum, Ein.A.Anlage.Zeit, Ein.A.Anlage.User );
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
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
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
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx : int;
end;
begin

  if (Ein.A.Nummer=0) or (gZLList->wpdbrecid=0) then RETURN true;
  RecRead(gFile,0,0,gZLList->wpdbrecid);

  if (Ein.A.Nummer<>0) then begin
    // BestellPos holen
    if (Ein.A.Position<>0) then begin
      Erx # RecLink(501,504,1,_recFirst);
      If (Erx>_rLocked) then begin
        Erx # RecLink(511,504,4,_recFirst);
        If (Erx>_rLocked) then begin
          Msg(504107,AInt(Ein.A.Nummer)+'/'+AInt(Ein.A.Position),0,0,0);
          RETURN false;
        end;
        RETURN true;
      end;
    end;
  end;

  // Bestellkopf holen
  Erx # RecLink(500,501,3,_recFirst);
  If (Erx>_rLocked) then begin
    Msg(504104,AInt(Ein.A.Nummer),0,0,0);
    RETURN false;
  end;

  // Position anpassen
  RecRead(501,1,_RecLock);
  Ein_Data:Pos_BerechneMarker();
  Erx # Ein_Data:PosReplace(_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    Msg(504102,AInt(Ein.A.Nummer)+'/'+AInt(Ein.A.Position),0,0,0);
    RETURN false;
  end;

  // Kopf anpassen
  RecRead(500,1,_RecLock);
  Ein_Data:BerechneMarker();
  Erx # RekReplace(500,_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    Msg(504106,AInt(Ein.A.Nummer),0,0,0);
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================
