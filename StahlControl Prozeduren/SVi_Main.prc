@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVI_Main
//                  OHNE E_R_G
//  Info
//    Steuert die Serviceinventarverwaltung
//
//  10.09.2010  ST  Erstellung der Prozedur
//  04.02.2022  AH  ERX
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
  cTitle      : 'Serviceinventar'
  cFile       : 960
  cMenuName   : 'SVi.Bearbeiten'
  cPrefix     : 'SVi'
  cZList      : $ZL.SVi
  cKey        : 1
  cListen     : ''
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
  winsearchpath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen  # cListen;
  // Auswahlfelder setzen...
  SetStdAusFeld('edSOA.Inv.Prozedur' ,'Prozedur');

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
  Lib_GuiCom:Pflichtfeld($edSOA.Inv.Ident);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic;
)
begin
  //if (aName='') or (aName='edAdr.EK.Zahlungsbed') then begin
  //  Erx # RecLink(816,100,3,0);
  //  if (Erx<=_rLocked) then
  //    $Lb.EK.Zahlungsbed->wpcaption # ZaB.Bezeichnung1.L1
  //  else
  //    $Lb.EK.Zahlungsbed->wpcaption # '';
  //end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    gTmp # gMdi->winsearch(aName);
    if (gTmp<>0) then
     gTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();
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
  $edSOA.Inv.Ident->WinFocusSet(true);
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
  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    ERx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin

    SOA.Inv.Anlage.Datum  # Today;
    SOA.Inv.Anlage.Zeit   # Now;
    SOA.Inv.Anlage.User   # gUserName;

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
  //   Auswahlfelder aktivieren
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
    'Prozedur' : begin
      vA # Prg_Para_Main:ParaAuswahl('Prozeduren','SVC_','SVC_z');
      if vA<>'' then SOA.Inv.Prozedur # vA;
      $edSOA.Inv.Prozedur->WinFocusSet();
      gMdi->WinUpdate();
    end;

  end;  // ...case

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
local begin
  Erx : int;
end;
begin

  $ZL.SVi.User->wpdisabled # false;
  Lib_GuiCom:SetWindowState($SVi.User,true);

  if (gSelected<>0) then begin

    RecRead(100,0,0,gSelected);
    gSelected # 0;

    RecBufClear(961,true);
    SOA.Usr.ServiceIdent  # SOA.Inv.Ident;
    SOA.Usr.Adressnr      # Adr.Nummer;
    SOA.Usr.Ansprechpart  # 0;
    SOA.Usr.Vertreternr   # 0;
    Erx # RekInsert(961,0,'MAN');
    If Erx<>_rOk then begin
      //Zuweisung existiert bereits!
      Msg(911002,'',_WinIcoError,_WinDialogOkCancel,1);
    end;


  end;

  // Zugriffsliste updaten
  Erx # $ZL.SVi.User->WinUpdate(_WinUpdOn, _WinLstFromFirst);
  $ZL.SVi.User->WinFocusSet(y);
end;


//========================================================================
//  AusAnsprech
//
//========================================================================
sub AusAnsprech()
local begin
  Erx : int;
end;
begin

  $ZL.SVi.User->wpdisabled # false;
  Lib_GuiCom:SetWindowState($SVi.User,true);

  if (gSelected<>0) then begin

    RecRead(102,0,0,gSelected);
    gSelected # 0;

    RecBufClear(961,true);
    SOA.Usr.ServiceIdent  # SOA.Inv.Ident;
    SOA.Usr.Adressnr      # Adr.P.Adressnr;
    SOA.Usr.Ansprechpart  # Adr.P.Nummer;
    SOA.Usr.Vertreternr   # 0;
    Erx # RekInsert(961,0,'MAN');
    If Erx<>_rOk then begin
      //Zuweisung existiert bereits!
      Msg(911002,'',_WinIcoError,_WinDialogOkCancel,1);
    end;
  end;

  // Zugriffsliste updaten
  $ZL.SVi.User->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $ZL.SVi.User->WinFocusSet(y);
end;


//========================================================================
//  AusVertreter
//
//========================================================================
sub AusVertreter()
local begin
  Erx : int;
end;
begin

  $ZL.SVi.User->wpdisabled # false;
  Lib_GuiCom:SetWindowState($SVi.User,true);

  if (gSelected<>0) then begin

    RecRead(102,0,0,gSelected);
    gSelected # 0;

    RecBufClear(961,true);
    SOA.Usr.ServiceIdent  # SOA.Inv.Ident;
    SOA.Usr.ServiceIdent  # SOA.Inv.Ident;
    SOA.Usr.Adressnr      # 0;
    SOA.Usr.Ansprechpart  # 0;
    SOA.Usr.Vertreternr   # Ver.Nummer;
    Erx # RekInsert(961,0,'MAN');
    If Erx<>_rOk then begin
      //Zuweisung existiert bereits!
      Msg(911002,'',_WinIcoError,_WinDialogOkCancel,1);
    end;
  end;

  // Zugriffsliste updaten
  $ZL.SVi.User->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $ZL.SVi.User->WinFocusSet(y);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl    : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SOA_Inv_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SOA_Inv_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SOA_Inv_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SOA_Inv_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SOA_Inv_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SOA_Inv_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.SOA.Protokoll');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_SOA_Inv_Protokoll]=n);


  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;

  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # false;



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
  vHdl2 : int;
  vUserTyp : alpha;
  vTyp : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    // Protokoll des Services
    'Mnu.Soa.Protokoll' : begin
      RecBufClear(965);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'SVi.P.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpdbfileno     # 960;
      gZLList->wpdbkeyno      # 2;
      gZLList->wpdbLinkFileNo # 965;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    // Api Exportieren
    'Mnu.Extras.ApiExport' : begin
      SVi_Data:ApiExport();
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,SOA.Inv.Anlage.Datum, SOA.Inv.Anlage.Zeit, SOA.Inv.Anlage.User);
    end;

  
    'SVi.User' : begin
      // Clientwindow starten
      gMDI # Lib_GuiCom:AddChildWindow(gMdi,'SVi.User','');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    //  ---------------------------------------------
    //    Events für das Benutzerfenster
    'Usr.Cancel' : begin
      $SVi.User->winclose();
    end;


    'Usr.Insert' : begin
        // Fragen was eingefügt werden soll
        gSelected # 0;
        vHdl # WinOpen('SVi.Usertyp',_WinOpenDialog);
        vHdl2 # vHdl->WinSearch('Dl.Typ');

        vHdl2->WinLstDatLineAdd('Kunde');
        vHdl2->WinLstDatLineAdd('Ansprechpartner');
        vHdl2->WinLstDatLineAdd('Verteter/Verband');

        vHdl2->wpcurrentint#1;
        vHdl->WinDialogRun(_WindialogCenter,gMdi);

        vHdl2->WinLstCellGet(vUserTyp , 1, _WinLstDatLineCurrent);
        vHdl->WinClose();
        if (gSelected<>0) then
          vTyp # gSelected;
        gSelected # 0;

        // Wurde ein korrekter Typ ausgewählt?
        if (vTyp <> 0) then begin

          // Wenn ja, dann Typ ermitteln
          case (vUserTyp) of
          'Kunde' : begin
            RecBufClear(100);         // ZIELBUFFER LEEREN
            gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
            Lib_GuiCom:RunChildWindow(gMDI);
          end;

          'Ansprechpartner' : begin
            gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.P.Verwaltung',here+':AusAnsprech');
            Lib_GuiCom:RunChildWindow(gMDI);
          end;

          'Verteter/Verband' : begin
            gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ver.Verwaltung',here+':AusVertreter');
            Lib_GuiCom:RunChildWindow(gMDI);
          end;
        end; // ... case vUsertyp

      end;
    end; // ..case Usr.Insert


    'Usr.Delete' : begin

      //Zuweisung aufheben?
      if (Msg(911003,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
        RekDelete(961,0,'MAN');
      end;
      $ZL.SVi.User->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
      $ZL.SVi.User->WinFocusSet(y);

    end;
  end; // ...case


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
    'bt.Prozedur' : begin
      Auswahl('Prozedur');
    end;

    'Usr.Insert' : begin
      EvtMenuCommand(null,aEvt:Obj);
    end;

    'Usr.Delete' : begin
      EvtMenuCommand(null,aEvt:Obj);
    end;

  end;  // ...case

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
//      Liest das Stichwort eines Benutzers und zeigt ihn an
//========================================================================
sub EvtLstDataInitUser(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
) : logic;
begin

  GV.Alpha.01 # ''; // Globales Datenbankfeld leeren

  // Kunde ?
  if (SOA.Usr.Adressnr <> 0) AND (SOA.Usr.Ansprechpart = 0) then begin
    Adr.Nummer # SOA.Usr.Adressnr;
    if (RecRead(100,1,0) <= _rLocked) then
      GV.Alpha.01 # Adr.Stichwort;
  end else
  // Ansprechpartner ?
  if (SOA.Usr.Adressnr <> 0) AND (SOA.Usr.Ansprechpart <> 0) then begin
    Adr.P.Adressnr # SOA.Usr.Adressnr
    Adr.P.Nummer   # SOA.Usr.Ansprechpart;
    if (RecRead(102,1,0) <= _rLocked) then
      GV.Alpha.01 # Adr.P.Stichwort;
  end else
  // Vertreter Verband ?
  if (SOA.Usr.Vertreternr <> 0) then begin
    Ver.Nummer # SOA.Usr.Vertreternr ;
    if (RecRead(110,1,0) <= _rLocked) then
      GV.Alpha.01 # Ver.Stichwort;
  end;

  return true;
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



//=====================================================================
// EvtMouseitem
//========================================================================
sub EvtMouseitem (
     aevt      : event;
     aButton   :  int;
     aHittest  : int;
     aItem     : int;
     aId       : int;
) : logic
begin
   case (aevt:obj -> wpname ) of
   'ZL.SVi.User' : begin
      if (ahittest = _winlstheader) then
      begin
         if (abutton = _winmouseleft ) then
         begin
            aevt:obj -> winupdate(_winupdon,_winlstfromfirst | _winlstrecdoselect);
         end
      end;
   end
   end;

   return(true);
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================