@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ver_Main
//                        OHNE E_R_G
//  Info
//    Steuert die Vertreter- & Verbandsverwalung
//
//  25.09.2003  ST  Erstellung der Prozedur
//  12.11.2021  AH  ERX
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
//    SUB AusAdresse()
//    SUB AusGruppe()
//    SUB AusSachbearbeiter()
//    SUB AusBriefanrede()
//    SUB AusAnrede()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Vertreter & Verbände'
  cFile       : 110
  cMenuName   : 'Ver.Bearbeiten'
  cPrefix     : 'Ver'
  cZList      : $ZL.VertreterVerbaende
  cKey        : 1
  cListen     : 'Vertreter & Verbände'
  cDialog     : 'Ver.Verwaltung'
  cMdiVar     : gMDIPara
  cRecht      : Rgt_VertreterVerbaende
end;


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aVerNr  : int;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end;
begin
  if (aRecId=0) and (aVerNr<>0) then begin
    Ver.Nummer # aVerNr;
    Erx # RecRead(110,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(110,_recID);
  end;
  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView);
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
  w_Listen  # cListen;
  
Lib_Guicom2:Underline($edVer.Sachbearbeiter);
Lib_Guicom2:Underline($edVer.Anrede);
Lib_Guicom2:Underline($edVer.LKZ);
Lib_Guicom2:Underline($edVer.PLZ);
Lib_Guicom2:Underline($edVer.Postfach.PLZ);
Lib_Guicom2:Underline($edVer.Briefanrede);
Lib_Guicom2:Underline($edVer.Adressnummer);
Lib_Guicom2:Underline($edVer.Gruppe);

  // Auswahlfelder setzen...
  SetStdAusFeld('edVer.Gruppe'         ,'Gruppe');
  SetStdAusFeld('edVer.Sachbearbeiter' ,'Sachbearbeiter');
  SetStdAusFeld('edVer.Adressnummer'   ,'Adresse');
  SetStdAusFeld('edVer.Briefanrede'    ,'Briefanrede');
  SetStdAusFeld('edVer.Anrede'         ,'Anrede');
  SetStdAusFeld('edVer.PLZ'            ,'PLZ');
  SetStdAusFeld('edVer.LKZ'            ,'LKZ');
  SetStdAusFeld('edVer.Postfach.PLZ'   ,'PLZPost');

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
  Erx   : int;
  vTmp  : int;
end;
begin

  if (aName='') or (aName='edVer.Adressnummer') then begin
    Erx # RecLink(100,110,3,_recFirst);   // Adresse holen
    if (Erx>_rLocked) then RecBufClear(100);
    $lb.Adresse->wpcaption # Adr.Stichwort;
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
Local begin
  vNummer : int;
end;
begin
  // Nummer bei Neuanlage vergeben
  if (Mode=c_ModeNew) then begin
    RecRead(110,1,_RecLast);
    vNummer # Ver.Nummer + 1;
    RecBufClear(110);
    Ver.Nummer # vNummer;
    $edVer.Nummer->WinFocusSet(true);
    end
  else begin
    $edVer.Stichwort->WinFocusSet(true);
  end;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
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
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
/*
    "xxx.Änderung.Datum"  # SysDate();
    "xxx.Änderung.Zeit"   # Now;
    "xxx.Änderung.User"   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));
*/
    PtD_Main:Compare(gFile);
  end
  else begin
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
/*
    xxx.Anlage.Datum  # SysDate();
    xxx.Anlage.Zeit   # Now;
    xxx.Anlage.User   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));
*/
  end;

  Adr_Ktd_Data:UpdateFromVer();

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
RETURN;
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
  vA    : alpha;
end;

begin

  case aBereich of

    'Adresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Gruppe' : begin
      RecBufClear(810);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Grp.Verwaltung',here+':AusGruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Sachbearbeiter' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AusSachbearbeiter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Briefanrede' : begin
      RecBufClear(811);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Anr.Verwaltung',here+':AusBriefanrede');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Anrede' : begin
      RecBufClear(811);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Anr.Verwaltung',here+':AusAnrede');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

   'PLZ' : begin
      RecBufClear(847);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ort.Verwaltung', here+':AusPLZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'LKZ' : begin
      RecBufClear(812);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Lnd.Verwaltung', here+':AusLKZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

   'PLZPost' : begin
      RecBufClear(847);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ort.Verwaltung', here+':AusPLZPost');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Ver.Adressnummer # Adr.Nummer;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edVer.Adressnummer->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusGruppe
//
//========================================================================
sub AusGruppe()
begin
  if (gSelected<>0) then begin
    RecRead(810,0,_RecId,gSelected);
    // Feldübernahme
    Ver.Gruppe  # "Grp.Kürzel";
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edVer.Gruppe->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edVer.Gruppe');
end;


//========================================================================
//  AusSachbearbeiter
//
//========================================================================
sub AusSachbearbeiter()
begin
  cZList->wpdisabled # false;
  Lib_GuiCom:SetWindowState($Ver.Verwaltung,true);
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    Ver.Sachbearbeiter # Usr.Name;
    gSelected # 0;
  end;
  Usr_data:RecReadThisUser();
  $edVer.Sachbearbeiter->Winfocusset(false);
  RefreshIfm('edVer.Sachbearbeiter');
end;


//========================================================================
//  AusBriefanrede
//
//========================================================================
sub AusBriefanrede()
begin
  cZList->wpdisabled # false;
  Lib_GuiCom:SetWindowState($Ver.Verwaltung,true);
  if (gSelected<>0) then begin
    RecRead(811,0,_RecId,gSelected);
    Ver.Briefanrede # Anr.Bezeichnung;
    gSelected # 0;
  end;
  $edVer.Briefanrede->Winfocusset(false);
  RefreshIfm('edVer.Briefanrede');
end;


//========================================================================
//  AusAnrede
//
//========================================================================
sub AusAnrede()
begin
  cZList->wpdisabled # false;
  Lib_GuiCom:SetWindowState($Ver.Verwaltung,true);
  if (gSelected<>0) then begin
    RecRead(811,0,_RecId,gSelected);
    Ver.Anrede # Anr.Bezeichnung;
    gSelected # 0;
  end;
  $edVer.Anrede->Winfocusset(false);
  RefreshIfm('edVer.Anrede');
end;



//========================================================================
//  AusPLZ
//
//========================================================================
sub AusPLZ()
begin
  if (gSelected<>0) then begin
    RecRead(847,0,_RecId,gSelected);
    gSelected # 0;
    Ver.LKZ   # Ort.LKZ;
    Ver.PLZ   # Ort.PLZ;
    Ver.Ort   # Ort.Name;
  end;
  $edVer.PLZ->Winfocusset(false);
  gMDI->WinUpdate(_WinUpdFld2Obj);
end;



//========================================================================
//  AusLKZ
//
//========================================================================
sub AusLKZ()
begin
  if (gSelected<>0) then begin
    RecRead(812,0,_RecId,gSelected);
    gSelected # 0;
    Ver.LKZ  # "Lnd.Kürzel";
  end;
  $edVer.LKZ->Winfocusset(false);
  gMDI->WinUpdate(_WinUpdFld2Obj);
end;


//========================================================================
//  AusPLZPost
//
//========================================================================
sub AusPLZPost()
begin
  if (gSelected<>0) then begin
    RecRead(847,0,_RecId,gSelected);
    gSelected # 0;
    Ver.Postfach.PLZ   # Ort.PLZ;
  end;
  $edVer.Postfach.PLZ->Winfocusset(false);
  gMDI->WinUpdate(_WinUpdFld2Obj);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Ver_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Ver_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Ver_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Ver_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_Ver_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_Ver_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Import]=false;


  $bt.Maps->wpDisabled # false;

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
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.OSt.Verband' : begin
      if (Rechte[Rgt_OSt_Verband]=n) then begin
        Msg(890000,'',0,0,0);
        RETURN true;
      end;
      Lib_COM:DisplayOSt( 'VERB:' + CnvAI( Ver.Nummer ), -1, 'Verband ' + AInt( Ver.Nummer ) + ', ' + Ver.Stichwort );
    end;

    'Mnu.OSt.Vertreter' : begin
      if (Rechte[Rgt_OSt_Vertreter]=n) then begin
        Msg(890000,'',0,0,0);
        RETURN true;
      end;
      Lib_COM:DisplayOSt( 'VERT:' + CnvAI( Ver.Nummer ), -1, 'Vertreter ' + AInt( Ver.Nummer ) + ', ' + Ver.Stichwort );
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
  case ( aEvt:Obj->wpName ) of
    'bt.Maps'           :   Adr_Data:OpenGoogleMaps( "Ver.Straße", Ver.PLZ, Ver.Ort );
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of

    'bt.Outlook' : begin
      Ver.OutlookCalendar # Lib_COM:ChooseCalendar(var Ver.OutlookStore1, var Ver.OutlookStore2);
//      GV.Alpha.40 # Usr.OutlookCalendar; // BUG. Usr.OutlookCalendar wird irgendwo überschrieben, wenn Focus auf Outlook wechselt..
      RefreshIfm( 'edVer.OutlookCalendar' );
      RefreshIfm( 'edVer.OutlookStore1' );
    end;

    'bt.Adresse'        :   Auswahl('Adresse');

    'bt.Gruppe'         :   Auswahl('Gruppe');

    'bt.Sachbearbeiter' :   Auswahl('Sachbearbeiter');

    'bt.Briefanrede'    :   Auswahl('Briefanrede');

    'bt.Anrede'         :   Auswahl('Anrede');

    'bt.PLZ'            :   Auswahl('PLZ');

    'bt.LKZ'            :   Auswahl('LKZ');

    'bt.PLZPost'        :   Auswahl('PLZPost');

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

  if (aMark=n) then begin
    if (Ver.SperreYN) then
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
begin
  RETURN true;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edVer.Sachbearbeiter') AND (aBuf->Ver.Sachbearbeiter<>'')) then begin
    Usr.Name # Ver.Sachbearbeiter;
    RecRead(800,2,0);
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVer.LKZ') AND (aBuf->Ver.LKZ<>'')) then begin
    RekLink(812,110,1,0);   // LKZ holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVer.PLZ') AND (aBuf->Ver.PLZ<>'')) then begin
    Ort.PLZ # Ver.PLZ;
    RecRead(847,1,0);
    Lib_Guicom2:JumpToWindow('Ort.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVer.Postfach.PLZ') AND (aBuf->Ver.Postfach.PLZ<>'')) then begin
    Ort.PLZ # Ver.Postfach.PLZ;
    RecRead(847,1,0);
    Lib_Guicom2:JumpToWindow('Ort.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVer.Adressnummer') AND (aBuf->Ver.Adressnummer<>0)) then begin
    RekLink(100,110,3,0);   // zugehörige Adr. holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edVer.Gruppe') AND (aBuf->Ver.Gruppe<>'')) then begin
    Grp.Name # Ver.Gruppe;
    RecRead(810,1,0);
    Lib_Guicom2:JumpToWindow('Grp.Verwaltung');
    RETURN;
  end;
  
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================