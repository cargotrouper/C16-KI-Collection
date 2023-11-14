@A+
//==== Business-Control ==================================================
//
//  Prozedur    Prj_Z_Main
//                  OHNE E_R_G
//  Info
//
//
//  18.09.2007  MS  Erstellung der Prozedur
//  15.07.2020  ST  Ankerfunktion Prj.Z.RecInit hinzugefügt 1918/13
//  16.03.2022  AH  ERX
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
//    SUB AusUser()
//    SUB AusArtikel()
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
  cTitle      : 'Projekt - Zeit'
  cFile       :  123
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'Prj_Z'
  cZList      : $ZL.Prj.Z
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

Lib_Guicom2:Underline($edPrj.Z.User);
Lib_Guicom2:Underline($edPrj.Z.Artikelnr);

  // Auswahlfelder setzen...
  SetStdAusFeld('edPrj.Z.User' ,'User');
  SetStdAusFeld('edPrj.Z.Artikelnr'    ,'Artikel');

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
  opt aChanged : logic;
)
local begin
  vTxtHdl : int;
  vTmp    : int;
end;
begin

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

  // dynamische Pflichtfelder einfärben15.07.2020
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  Erx   : int;
  vlfd  : int;
end;
begin

  if (RunAFX('Prj.Z.RecInit','')<0) then RETURN;
  
  // Neuanlage?
  if (Mode=c_ModeNew) then begin
   Erx # RecLink(123,122,1,_recLast); // letzte Zeit holen
   if (Erx>_rLocked) then vLfd # 1    // keine gefunden, dann mit 1 starten
   else vLfd # Prj.Z.lfdNr + 1;       // sonst um 1 erhöhen

   RecBufClear(123);
   Prj.Z.Nummer       # Prj.P.Nummer;
   Prj.Z.Position     # Prj.P.Position;
   Prj.Z.SubPosition  # Prj.P.SubPosition;
   Prj.Z.lfdNr        # vLfd;
   Prj.Z.User         # gUserName;
   Prj.Z.Start.Datum  # today;
   Prj.Z.End.Datum    # today;
 end;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edPrj.Z.Start.Datum->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vBuf123 : int;
  Erx     : int;
end
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if (Prj.Z.Artikelnr<>'') then begin
    Erx # RecLink(250,123,3,_RecFirst);   // Artikel holen
    if (Erx>_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Artikel', 'NB.Page1', 'edPrj.Z.Artikelnr');
      RETURN false;
    end;
  end;

  // Sonderfunktion:
  if (RunAFX('Prj.Z.RecSave','')<>0) then begin
    if (AfxRes<>_rOk) then begin
      RETURN False;
    end;
  end;
  
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
/*    "xxx.Änderung.Datum"  # Today;
    "xxx.Änderung.Zeit"   # Now;
    "xxx.Änderung.User"   # gUserName;*/
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    Prj.Z.Anlage.Datum  # Today;
    Prj.Z.Anlage.Zeit   # Now;
    Prj.Z.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');

    // eindeutigkeit prüfen
    WHILE (RecRead(123,1,_RecTest,0)<=_Rlocked) do
      Prj.Z.lfdNr # Prj.Z.lfdNr +1;
    //   WHILE (RecRead(402,1,_rectest)<=_rLocked) do
    //  Auf.AF.lfdNr # Auf.AF.LfdNr + 1;

    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  // Position updaten
  vBuf123 # RekSave(123);
  RecRead(122,1,_recLock);    //Positione sperren
  Prj.P.Dauer.Intern  # 0.0;
  Prj.P.ZusKosten     # 0.0;
  Erx # RecLink(123,122,1,_recFirsT);   // Zeiten loopen
  WHILE (Erx<=_rLocked) do begin
    Prj.P.Dauer.Intern # Prj.P.Dauer.Intern + Prj.Z.Dauer
    Prj.P.ZusKosten    # Prj.P.ZusKosten    + Prj.Z.ZusKosten;
    Erx # RecLink(123,122,1,_recNext);
  END;
  RekReplace(122,_recUnlock,'AUTO');
  RekRestore(vBuf123);

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
  vBuf123 : int;
  Erx     : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    RekDelete(gFile,0,'MAN');

    // Position updaten
    vBuf123 # RekSave(123);
    RecRead(122,1,_recLock);    //Positione sperren
    Prj.P.Dauer.Intern # 0.0;
    Prj.P.ZusKosten     # 0.0;
    Erx # RecLink(123,122,1,_recFirsT);   // Zeiten loopen
    WHILE (Erx<=_rLocked) do begin
      Prj.P.Dauer.Intern # Prj.P.Dauer.Intern + Prj.Z.Dauer
      Prj.P.ZusKosten    # Prj.P.ZusKosten    + Prj.Z.ZusKosten;
      Erx # RecLink(123,122,1,_recNext);
    END;
    RekReplace(122,_recUnlock,'AUTO');
    RekRestore(vBuf123);
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
local begin
  vStd : float;
end;
begin

  if (Prj.Z.Bemerkung <> '') then begin
    if (aEvt:Obj->wpname='edPrj.Z.End.Zeit') then begin
      if (Prj.Z.End.Zeit = 0:0) then
    Prj.Z.End.Zeit # now;
    end;

    $edPrj.Z.End.Zeit->WinUpdate(_WinUpdFld2Obj);
  end;

  // Dauer errechnen
  // richtiges Objekt?
  if (aEvt:Obj->wpname='edPrj.Z.Dauer') then begin
    if(Prj.Z.Start.Datum<>0.0.0) and (Prj.Z.End.Datum<>0.0.0) and (Prj.Z.Dauer = 0.0) then begin
    //  (Prj.Z.Start.Zeit <> 00:00) and (Prj.Z.End.Zeit <> 00:00) then begin
      vStd # cnvfi( (CnvID(Prj.Z.Start.Datum) - cnvID(1.1.2000)) * 24 );
      vStd # vStd + (cnvfi(Cnvit(Prj.Z.Start.Zeit)) /(1000.0*60.0*60.0));
      Prj.Z.Dauer # Rnd(vStd,2);
      vStd # cnvfi( (CnvID(Prj.Z.End.Datum) - cnvid(1.1.2000)) * 24 );
      vStd # vStd + (cnvfi(Cnvit(Prj.Z.End.Zeit)) /(1000.0*60.0*60.0));
      Prj.Z.Dauer # Rnd(Rnd(vStd,2) - Prj.Z.Dauer,2);
    if (Prj.Z.Dauer < 0.0) then
      Prj.Z.Dauer # 0.0;
    end;
  end;

  $edPrj.Z.Dauer->WinUpdate(_WinUpdFld2Obj);

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
local begin
  vStd  : float
end;
begin

  if (aEvt:Obj->wpname='edPrj.Z.Start.Datum') then begin
    if (Prj.Z.Start.Zeit = 0:0) then
      Prj.Z.Start.Zeit # now;
  end;
/*
  if (aEvt:Obj->wpname='edPrj.Z.End.Datum') then begin
    if (Prj.Z.End.Zeit = 0:0) then
  Prj.Z.End.Zeit # now;
  end;
*/

/*
  // Dauer errechnen
  // richtiges Objekt?
  if (aEvt:Obj->wpname='edPrj.Z.End.Zeit') then begin
    if (Prj.Z.Start.Datum<>0.0.0) and (Prj.Z.End.Datum<>0.0.0) and (Prj.Z.Dauer = 0.0) then begin
    //  (Prj.Z.Start.Zeit <> 00:00) and (Prj.Z.End.Zeit <> 00:00) then begin
      vStd # cnvfi( (CnvID(Prj.Z.Start.Datum) - cnvID(1.1.2000)) * 24 );
      vStd # vStd + (cnvfi(Cnvit(Prj.Z.Start.Zeit)) /(1000.0*60.0*60.0));
      Prj.Z.Dauer # Rnd(vStd,2);
      vStd # cnvfi( (CnvID(Prj.Z.End.Datum) - cnvid(1.1.2000)) * 24 );
      vStd # vStd + (cnvfi(Cnvit(Prj.Z.End.Zeit)) /(1000.0*60.0*60.0));
      Prj.Z.Dauer # Rnd(Rnd(vStd,2) - Prj.Z.Dauer,2);
    if (Prj.Z.Dauer < 0.0) then
      Prj.Z.Dauer # 0.0;
    end;
  end;

  $edPrj.Z.Dauer->WinUpdate(_WinUpdFld2Obj);
*/
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
    'User' : begin
      RecBufClear(800);         // ZIELBUFFER LEEREN
       gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.Verwaltung',here+':AusUser',n);
      //ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    
    'Artikel' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      Art.Nummer  # Prj.Z.Artikelnr;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    
  end
end;


//========================================================================
//  AusUser
//
//========================================================================
sub AusUser()
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Prj.Z.User # Usr.Username;
  end;
  Usr_data:RecReadThisUser();
  // Focus auf Editfeld setzen:

  $edPrj.Z.User->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  AusArtikel
//========================================================================
sub AusArtikel()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Prj.Z.Artikelnr # Art.Nummer;
  end;

  $edPrj.Z.Artikelnr->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Z_Anlegen]=n) or ("Prj.P.Lösch.Datum"<>0.0.0);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Z_Anlegen]=n) or ("Prj.P.Lösch.Datum"<>0.0.0);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Z_Aendern]=n) or ("Prj.P.Lösch.Datum"<>0.0.0);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Z_Aendern]=n) or ("Prj.P.Lösch.Datum"<>0.0.0);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Z_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Z_Loeschen]=n);

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
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Prj.Z.Anlage.Datum, Prj.Z.Anlage.Zeit, Prj.Z.Anlage.User);
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
    'bt.User'       : Auswahl('User');
    'bt.Artikel'    : Auswahl('Artikel');
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
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx : int;
end;
begin

  // Ankerfunktion
  if (RunAFX('Prj.Z.EvtClose','')<0) then RETURN (AfxRes=_rOK);

  RecRead(122,1,_recLock);    //Positione sperren
  Prj.P.Dauer.Intern  # 0.0;
  Prj.P.ZusKosten     # 0.0;
  Erx # RecLink(123,122,1,_recFirsT);   // Zeiten loopen
  WHILE (Erx<=_rLocked) do begin
    Prj.P.Dauer.Intern # Prj.P.Dauer.Intern + Prj.Z.Dauer
    Prj.P.ZusKosten    # Prj.P.ZusKosten    + Prj.Z.ZusKosten;
    Erx # RecLink(123,122,1,_recNext);
  END;
  RekReplace(122,_recUnlock,'AUTO');

  RETURN true;
end;



//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vA      : alpha;
vFile : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);

    // Drop Aktionen von EVENT von Cockpit erlauben
    if (Str_Token(vA,'|',1)='EVENT') then begin
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN (true);
    end;

	end;
	
  RETURN false;
end;


//========================================================================
//  EvtDrop
//            komplettes D&D durchführen
//========================================================================
sub EvtDrop(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aDataPlace   : int;      // DropPlace-Objekt
	aEffect      : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  vA  : alpha;
  vNr : int;
  Erx : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);

    if (Str_Token(vA,'|',1)='EVENT') then begin

      Tem.Nummer # CnvIa(Str_Token(vA,'|',2));
      Erx # RecRead(980,1,0);
      if (Erx <> _rOK) then begin
        todo('Termin konnte nicht gesen werden');
        RETURN false;
      end;

      // <<< MUSTER
      // für Drag&Drop und Focuswechsel
      WinUpdate(WinInfo(aEvt:obj, _WinFrame), _WinUpdActivate );
      if (gMDI<>0) then VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      // ENDE MUSTER >>>

      Erx # RecLink(123,122,1,_recLast);  // letzten IO holen
      vNr # Prj.Z.lfdNr;
      RecBufClear(123);

      // Zeit anlegen
      Prj.Z.Nummer        # Prj.P.Nummer;
      Prj.Z.Position      # Prj.P.Position;
      Prj.Z.SubPosition   # Prj.P.SubPosition;
      Prj.Z.lfdNr         # vNr;
      Prj.Z.Start.Datum   # TeM.Start.Von.Datum;
      Prj.Z.Start.Zeit    # TeM.Start.Von.Zeit;
      Prj.Z.End.Datum     # TeM.Ende.Von.Datum;
      Prj.Z.End.Zeit      # TeM.Ende.Von.Zeit;
      Prj.Z.Dauer         # Rnd(TeM.Dauer/60.0,2);
      Prj.Z.Bemerkung     # TeM.Bezeichnung;
      Prj.Z.User          # gUsername;

      REPEAT
        inc(vNr);
        Prj.Z.lfdNr # vNr;
        Erx # RekInsert(123,0,'MAN');
      UNTIL Erx = _rOK;

      // Anker an Termin hängen
      Tem_A_Data:Anker(122,'Zeitzuweisung',true,RecInfo(122,_RecID));


      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

    end;

  end;


	RETURN (false);
end

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edPrj.Z.User') AND (aBuf->Prj.Z.User<>'')) then begin
    Usr.Name # Prj.Z.User;
    RecRead(800,2,0);
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edPrj.Z.Artikelnr') AND (aBuf->Prj.Z.Artikelnr<>'')) then begin
    RekLink(250,123,3,0);   // Artikelnumemr holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
