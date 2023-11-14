@A+
//==== Business-Control ==================================================
//
//  Prozedur    Prj_Main
//                        OHNE E_R_G
//  Info        Hauptsteuerungsprozedur der Projektdatei (120)
//
//
//  06.04.2004  TM  Erstellung der Prozedur
//  28.07.2009  ST  Umstellung des Zeitplans auf andere Farben und Statusbezogen
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  19.07.2012  ST  Druck: DMS-Deckblatt hinzugefügt
//  25.04.2016  AH  Prj.VorlageYN
//  07.06.2016  AH  Directory auf %temp%
//  16.09.2019  ST  Datenexport und -import freigeschaltet
//  16.03.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusAdresse()
//    SUB AusProjektleiter()
//    SUB AusTeam()
//    SUB AusPositionen()
//    SUB AusText()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB Zeitplan();
//    SUB JumpTo(aName : alpha; aBuf  : int);
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Projekte'
  cFile :     120
  cMenuName : 'Prj.Bearbeiten'
  cPrefix :   'Prj'
  cZList :    $ZL.Projekte
  cKey :      1
end;

declare TxtSave();
declare TxtRead();
declare Zeitplan();


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
  Filter_Prj # y;
  App_Main:EvtInit(aEvt);

Lib_Guicom2:Underline($edPrj.Adressnummer);
Lib_Guicom2:Underline($edPrj.Projektleiter);
Lib_Guicom2:Underline($edPrj.Team);


  SetStdAusFeld('edPrj.Adressnummer'      ,'Adresse');
  SetStdAusFeld('edPrj.Wartungsinterval'  ,'Intervall');
  SetStdAusFeld('edPrj.Projektleiter'     ,'Projektleiter');
  SetStdAusFeld('edPrj.Team'              ,'Team');

  if (Set.Installname='BCS') then begin
    $lbPrj.Projektleiter->wpcaption # 'Product Owner';
  end;
 
  if ( Set.Prj.Cust1 != '' ) then begin
    $lbPrj.Cust.1->wpCaption # Set.Prj.Cust1;
    $clmPrj.Cust1->wpCaption # Set.Prj.Cust1;
  end;
  if ( Set.Prj.Cust2 != '' ) then begin
    $lbPrj.Cust.2->wpCaption # Set.Prj.Cust2;
    $clmPrj.Cust2->wpCaption # Set.Prj.Cust2;
  end;
  if ( Set.Prj.Cust3 != '' ) then begin
    $lbPrj.Cust.3->wpCaption # Set.Prj.Cust3;
    $clmPrj.Cust3->wpCaption # Set.Prj.Cust3;
  end;
  if ( Set.Prj.Cust4 != '' ) then begin
    $lbPrj.Cust.4->wpCaption # Set.Prj.Cust4;
    $clmPrj.Cust4->wpCaption # Set.Prj.Cust4;
  end;
end;


//========================================================================
//  EvtMdiActivate
//                  MDI-Fenster erhält Focus
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  App_Main:EvtMdiActivate(aEvt);
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_Prj;
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;
  // Pflichtfelder
  // Lib_GuiCom:Pflichtfeld($edPrj.Adressnummer);
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
  vTxtHdl : int;
  vTmp    : int;
end;
begin
//  $lb.letztesDatum->wpcaption # cnvad(Prj.Wtg.letztesDatum);
  $lb.nextDatum->wpcaption    # cnvad(Prj_data:Wtg_naechsterTermin());

  $lb.Nr1->wpcaption # AInt(Prj.Nummer);
  $lb.Nr2->wpcaption # AInt(Prj.Nummer);

  if (aName='') and (Mode<>c_ModeEdit) then begin
    vTxtHdl # $Prj.TextEdit->wpdbTextBuf;    // Textpuffer ggf. anlegen
    if (vTxtHdl=0) then begin
      vTxtHdl # TextOpen(32);
      $Prj.TextEdit->wpdbTextBuf # vTxtHdl;
    end;
    TxtRead();
  end;

  if (Mode=c_ModeView) then begin
    if (Prj.Wartung.AME='A') then begin
      $cb.Anfang->wpCheckState  # _WinStateChkChecked;
      $cb.Mitte->wpCheckState   # _WinStateChkUnChecked;
      $cb.Ende->wpCheckState    # _WinStateChkUnChecked;
    end;
    if (Prj.Wartung.AME='M') then begin
      $cb.Anfang->wpCheckState  # _WinStateChkUnChecked;
      $cb.Mitte->wpCheckState   # _WinStateChkChecked;
      $cb.Ende->wpCheckState    # _WinStateChkUnChecked;
    end;
    if (Prj.Wartung.AME='E') then begin
      $cb.Anfang->wpCheckState  # _WinStateChkUnChecked;
      $cb.Mitte->wpCheckState   # _WinStateChkUnChecked;
      $cb.Ende->wpCheckState    # _WinStateChkChecked;
    end;
  end;

  if (aName='') or (aName='edPrj.Adressnummer') then begin
    RecBufClear(110);
    Erx # RecLink(100,120,1,_Recfirst);       // Adresse holen
    if (Erx<=_rLocked) then begin
      $Lb.Adresse->wpcaption  # Adr.Stichwort;
      Prj.Adressstichwort     # Adr.Stichwort;
      If (Adr.Vertreter<>0) then begin
        Erx # RecLink(110,100,15,_recFirst);  // Vertreter holen
        if (Erx>_rLocked) then RecBufClear(110);
      end;
    end
    else begin
      $Lb.Adresse->wpcaption    # '';
      Prj.Adressstichwort       # '';
    end;
    $Lb.Vertreter->wpcaption  # Ver.Stichwort;
  end;

  // Austauschprojekt [21.01.2010/PW]
  if ( Prj.AustauschPrjNr > 0 ) then
    $lbPrj.Austausch->wpVisible # true;
  else
    $lbPrj.Austausch->wpVisible # false;

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
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  // Focus setzen auf Feld:
  $edPrj.Adressnummer->WinFocusSet(true);
  $cb.Anfang->wpCheckState # _WinStateChkUnChecked;
  $cb.Mitte->wpCheckState # _WinStateChkUnChecked;
  $cb.Ende->wpCheckState # _WinStateChkUnChecked;

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


  if (Mode=c_ModeNew) and (Prj.Nummer<>0) and (Prj.VorlageYN) then begin
    Msg(99,'neenne',0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edPrj.Nummer->WinFocusSet(true);
    RETURN false;
  end;


  // logische Prüfung
  If (Prj.Adressnummer=0) then begin
/*
    Msg(001200,Translate('Adresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edPrj.Adressnummer->WinFocusSet(true);
    RETURN false;
*/
  end
  else begin
    Erx # RecLink(100,120,1,_RecTest);
    if (Erx <> _rOK) then begin
      Msg(001201,Translate('Adresse'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edPrj.Adressnummer->WinFocusSet(true);
      RETURN false;
    end;
    if (Prj.Wartung.AME<>'') and (Adr.Kundennr=0) then begin
      Msg(001201,Translate('Kundennummer'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edPrj.Adressnummer->WinFocusSet(true);
      RETURN false;
    end;
  end;


  if (Prj.Wartungsinterval<>'') then begin
    if (Prj.Wartungsinterval<>'KW') and
      (Prj.Wartungsinterval<>'MO') and
      (Prj.Wartungsinterval<>'QU') and
      (Prj.Wartungsinterval<>'SE') and
      (Prj.Wartungsinterval<>'JA') then begin
    Msg(120000,'',0,0,0);
    $edPrj.Wartung.AME->WinFocusSet(true);
    RETURN false;
    end;
  end;

  if (RunAFX('Prj.RecSave.Pre','')<0) then
    RETURN false;

  // Nummernvergabe
  If (Mode=c_ModeNew) and (Prj.Nummer=0) then begin
    if (Prj.VorlageYN=false) then
      Prj.Nummer # Lib_Nummern:ReadNummer('Projekt')
    else
      Prj.Nummer # Lib_Nummern:ReadNummer('Projekt-Vorlage');

    if (Prj.Nummer<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;
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
    Prj.Anlage.Datum  # Today;
    Prj.Anlage.Zeit   # Now;
    Prj.Anlage.User   # gUsername;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  TxtSave();

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

  if (RunAFX('Prj.RecDel','') < 0) then RETURN;

  if ("Prj.Löschmarker"='') then begin
    Erx # RecLink(122,120,4,_recFirst);   // Positionen loopen
    WHILE (Erx<=_rLocked) do begin
      if ("Prj.P.Lösch.Datum"=0.0.0) then BREAK;
      Erx # RecLink(122,120,4,_recNext);
    END;
    if (Erx<=_rLocked) then begin
      Msg(120006,AInt(Prj.P.Position)+'/'+aint(Prj.P.SubPosition),0,0,0);
      RETURN;
    end;
  end;

  // Löschmarker umsetzen?
  if (Msg(000008,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  RecRead(120,1,_recLock);
  if ("Prj.Löschmarker"='*') then "Prj.Löschmarker" # ''
  else "Prj.Löschmarker" # '*';
  Erx # RekReplace(120,_recUnlock,'MAN');
  if (erx<>_rOK) then begin
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;

/****
  TRANSON;    // Transaktion öffnen

  // Positionen loopen & löschen
  WHILE (RecLink(122,120,4,_recFirst)<=_rLocked) do begin

    // Zeiten loopen & Löschen
    WHILE (RecLink(123,122,1,_recFirst)<=_rLocked) do begin
     Erx RekDelete(123,0,'MAN')    // Zeiten löschen
      if (Erx<>_rOK) then begin
        TRANSBRK;   // Transaktion abbrechen
        RETURN;
      end;
    END;

    Erx RekDelete(122,0, 'MAN');    // Position löschen
    if (Erx<>_rOK) then begin
      TRANSBRK;   // Transaktion abbrechen
      RETURN;
    end;
    Erx # TxtDelete (Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1' ),0);
    if (Erx<>_rOK) then begin
      TRANSBRK;   // Transaktion abbrechen
      RETURN;
    end;
    Erx # TxtDelete (Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2' ),0);
    if (Erx<>_rOK) then begin
      TRANSBRK;   // Transaktion abbrechen
      RETURN;
    end;

// textbausteine killen

  END;

  Erx RekDelete(gFile,0,'MAN');
  if (Erx<>_rOK) then begin
    TRANSBRK;   // Transaktion abbrechen
    RETURN;
  end;


  TRANSOFF;   // Transaktion durchführen und beenden
***/

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
  vQ    : alpha(4000);
end;

begin

  case aBereich of

    'Intervall' : begin
      Lib_Einheiten:Popup('Datumstyp',$edPrj.Wartungsinterval,120,1,7);
    end;

    'Adresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Projektleiter' : begin
      RecBufClear(800);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.Verwaltung',here+':AusProjektleiter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Team' : begin
      RecBufClear(800);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.Verwaltung',here+':AusTeam');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Text' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusText');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'P';
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
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
    Prj.Adressnummer # Adr.Nummer;
    Prj.Adressstichwort # Adr.Stichwort;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edPrj.Adressnummer->Winfocusset(false);
  // ggf. Labels refreshen

  RefreshIfm('edPrj.Adressnummer');
end;


//========================================================================
//  AusProjektleiter
//
//========================================================================
sub AusProjektleiter()
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    // Feldübernahme
    Prj.Projektleiter # Usr.Username;
    gSelected # 0;
  end;
  Usr_data:RecReadThisUser();

  $edPrj.Projektleiter->Winfocusset();
end;


//========================================================================
//  AusTeam
//
//========================================================================
sub AusTeam()
begin
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    // Feldübernahme
    Prj.Team # Usr.Username;
    gSelected # 0;
  end;
  Usr_data:RecReadThisUser();

  $edPrj.Team->Winfocusset();
end;


//========================================================================
//  AusPositionen
//
//========================================================================
sub AusPositionen()
local begin
  Erx     : int;
  vPrio   : int;
end;
begin
  gSelected # 0;

  Erx # RecLink(122,120,4,_recFirst);     // Positionen loopen
  WHILE (Erx<=_rLockeD) do begin
    if ("Prj.P.Priorität">vPrio) then vPrio # "Prj.P.Priorität";
    Erx # RecLink(122,120,4,_recNext);
  END;
  if (vPrio>"Prj.Priorität") then begin
    RecRead(120,1,_recLock);
    "Prj.Priorität" # vPrio;
    RekReplace(120,_recUnlock,'AUTO');
  end;

end;


//========================================================================
//  AusText
//
//========================================================================
sub AusText();
local begin
  vTxtHdl : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;
    vTxtHdl # $Prj.TextEdit->wpdbTextBuf;
    Lib_Texte:TxtLoadLangBuf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxtHdl, '');
    $Prj.TextEdit->WinUpdate(_WinUpdBuf2Obj);
  end;
  // Focus auf Editfeld setzen:
  $Prj.TextEdit->Winfocusset(false);
  // ggf. Labels refreshen
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
  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMenu->WinSearch('Mnu.Stueckliste');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Prj_Stueckliste]=n);

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Prj_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Positionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
      (Rechte[Rgt_Prj_Positionen]=n) or (Prj.Wartungsinterval<>'');

  vHdl # gMenu->WinSearch('Mnu.AusVorlage');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) or (Prj.VorlageYN=false) or (Rechte[Rgt_Prj_Anlegen]=n));

  $NB.Page2->wpdisabled # (Rechte[Rgt_Prj_Wartung]=n);


  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Mat_Excel_Export]=false;

  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Mat_Excel_Import]=false;
    

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
  vHdl      : int;
  vA        : alpha(1000);
  vFilename : alpha;
  vQ        : alpha(4000);
  vTmp      : int;
  vRef      : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.AusVorlage' : begin
      Prj_Data:CopyVorlage(Prj.Nummer);
    end;


    'Mnu.Aktivitaeten' : begin
      TeM_Subs:Start(120);
    end;


    'Mnu.Filter.Geloescht' : begin
      Filter_Prj # !Filter_Prj;
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_Prj;

       if (gZLList->wpdbselection<>0) then begin
        vHdl # gZLList->wpdbselection;
        if (SelInfo(vHdl, _SelCount) > 0) then
          vRef # _WinLstRecFromRecId
        else
          vRef # _WinLstFromFirst;
        gZLList->wpDbSelection # 0;
        SelClose(vHdl);
        SelDelete(gFile,w_selName);
        w_SelName # '';
        gZLList->WinUpdate(_WinUpdOn, vRef | _WinLstRecDoSelect);
        App_Main:Refreshmode();
        RETURN true;
      end;
      vQ # '';
      Lib_Sel:QAlpha( var vQ, '"Prj.Löschmarker"', '=', '');
      Lib_Sel:QRecList(0,vQ);
      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      App_Main:Refreshmode();
      RETURN true;
    end;


    'Mnu.Mark.Sel' : begin
      Prj_Mark_Sel();
    end;


    'Mnu.MyPos' : begin
      Sel.Auf.Sachbearbeit # gUserName;
      if (Dlg_Standard:Standard(Translate('Wiedervorlage'),var Sel.Auf.Sachbearbeit)=false) then RETURN false;
      Sel.Auf.Sachbearbeit # StrCnv(Sel.Auf.Sachbearbeit,_StrUpper);
      RecBufClear(122,y);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Prj.P.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      Sel.Auf.Sachbearbeit # gUserName;
//      gzllist->wpdbLinkfileno # 0;
//      gzllist->wpdbKeyno      # 1;
//      gzllist->wpdbfileno     # 122;
      vQ # '';
      Lib_Sel:QDate( var vQ, '"Prj.P.Lösch.Datum"', '=', 0.0.0);
      Lib_Sel:QenthaeltA( var vQ, 'Prj.P.WiedervorlUser', Sel.Auf.Sachbearbeit);
      Lib_Sel:QRecList(0,vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.WartungsAuf' : begin
      if (Rechte[Rgt_Prj_WartungsAuf]=n) then RETURN true;
      if (Msg(120001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;

      vTmp # Prj_Data:Wtg_Wartungslauf();
      if (vTmp>=0) then begin
        Msg(120002,cnvai(vTmp),_WinIcoInformation,_WinDialogok,1);
      end
      else begin
        if (vTmp=-289) then
          Msg(120004,AInt(Prj.Nummer)+'|'+AInt(vTmp),_WinIcoError,_WinDialogOk,1)
        else
          Msg(120003,AInt(Prj.Nummer)+'|'+AInt(vTmp),_WinIcoError,_WinDialogOk,1);
      end;
    end;


    'Mnu.Stueckliste' : begin
      if (Mode=c_Modeview) or
        ((Mode=c_ModeList) and (RecRead(gFile,0,0,gZLList->wpdbrecid)<=_rLocked)) then begin
        RecBufClear(121);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.SL.Verwaltung','',y);
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Mnu.Positionen' : begin
      // MUSTER SELEKTION (RecbufClear mit TRUE!!!)
      RecBufClear(122,y);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Prj.P.Verwaltung',here+':AusPositionen',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      gzllist->wpdbLinkfileno # 122;
//      gzllist->wpdbKeyno      # 4;
//      gzllist->wpdbfileno     # 120;
      gzllist->wpdbLinkfileno # 0;
      gzllist->wpdbKeyno      # 1;
      gzllist->wpdbfileno     # 122;
      vQ # '';
      Lib_Sel:QInt( var vQ, 'Prj.P.Nummer', '=', Prj.Nummer);
      Lib_Sel:QRecList(0,vQ);

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.NextPage' : begin
      vHdl # gMdi->Winsearch('NB.Main');
      // durch Seiten cyclen
      if (vHdl->wpcurrent='NB.Page1') then vHdl->wpcurrent # 'NB.Page2'
      else
      if (vHdl->wpcurrent='NB.Page2') then vHdl->wpcurrent # 'NB.Page3'
      else
      if (vHdl->wpcurrent='NB.Page3') then vHdl->wpcurrent # 'NB.Page1';
      if (Mode=c_ModeView) then begin
        vTmp # gMdi->winsearch('Edit');
        if (vTmp->wpdisabled) then
          if (gMdi->winsearch('EditErsatz')<>0) then
            vTmp # gMdi->winsearch('EditErsatz');
        vTmp->WinFocusSet(false);
      end;
    end;


    'Mnu.PrevPage' : begin
      vHdl # gMdi->Winsearch('NB.Main');
      // durch Seiten cyclen
      if (vHdl->wpcurrent='NB.Page3') then vHdl->wpcurrent # 'NB.Page2'
      else
      if (vHdl->wpcurrent='NB.Page1') then vHdl->wpcurrent # 'NB.Page3'
      else
        if (vHdl->wpcurrent='NB.Page2') then vHdl->wpcurrent # 'NB.Page1';
      if (Mode=c_ModeView) then begin
        vTmp # gMdi->winsearch('Edit');
        if (vTmp->wpdisabled) then
          if (gMdi->winsearch('EditErsatz')<>0) then
            vTmp # gMdi->winsearch('EditErsatz');
        vTmp->WinFocusSet(false);
      end;
    end;


    'Mnu.Druck.Analyse' : begin
      Lib_Dokumente:Printform(120,'Aufwandsanalyse',true);
    end;


    'Mnu.Druck.AufUeb' : begin
      Lib_Dokumente:Printform(120,'Auftrags-Übersicht',true);
    end;


    'Mnu.Druck.Etikett' : begin
      Lib_Dokumente:Printform(120,'Etiketten',true);
    end;


    'Mnu.Druck.StkListe' : begin
      Lib_Dokumente:Printform(120,'Stückliste',true);
      Lfm_Ausgabe:Starten('', 121001);
    end;

    'Mnu.Druck.Zeitplan' : begin
      Zeitplan();
    end;

    'Mnu.Druck.DmsDeckblatt' : begin
      Lib_Dokumente:Printform(120,'DMS Deckblatt',false);
    end;

    // Austauschprojekt [14.01.2010/PW]
    'Mnu.AP.Export' : begin
      Prj_Data:ProjektExport();
    end;


    'Mnu.AP.Import' : begin
      Prj_Data:ProjektImport();
      App_Main:Refresh();
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Prj.Anlage.Datum, Prj.Anlage.Zeit, Prj.Anlage.User );
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
    'bt.Adresse' :        Auswahl('Adresse');
    'bt.Text' :           Auswahl('Text');
    'bt.Projektleiter' :  Auswahl('Projektleiter');
    'bt.Team' :           Auswahl('Team');
    'bt.Intervall' :      Auswahl('Intervall');
  end;

end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:obj->wpname='cb.Anfang') and ($cb.Anfang->wpCheckState=_WinStateChkChecked) then begin
    $cb.Mitte->wpCheckState # _WinStateChkUnChecked;
    $cb.Ende->wpCheckState # _WinStateChkUnChecked;
    Prj.Wartung.AME # 'A';
  end;
  if (aEvt:obj->wpname='cb.Mitte') and ($cb.Mitte->wpCheckState=_WinStateChkChecked) then begin
    $cb.Anfang->wpCheckState # _WinStateChkUnChecked;
    $cb.Ende->wpCheckState # _WinStateChkUnChecked;
    Prj.Wartung.AME # 'M';
  end;
  if (aEvt:obj->wpname='cb.Ende') and ($cb.Ende->wpCheckState=_WinStateChkChecked) then begin
    $cb.Mitte->wpCheckState # _WinStateChkUnChecked;
    $cb.Anfang->wpCheckState # _WinStateChkUnChecked;
    Prj.Wartung.AME # 'E';
  end;

  if ($cb.Ende->wpCheckState=_WinStateChkUnChecked) and
    ($cb.Mitte->wpCheckState=_WinStateChkUnChecked) and
    ($cb.Anfang->wpCheckState=_WinStateChkUnChecked) then begin
    Prj.Wartung.AME # '';
  end;

  $lb.nextDatum->wpcaption # cnvad(Prj_data:Wtg_naechsterTermin());
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
  If (RecLink(100,120,1,_RecFirst) > _rLocked) then RecBufClear(100) ;

  if (aMark=n) then begin
    if ("Prj.Löschmarker"='*') then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
    else if (Prj.Wartungsinterval <> '') then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Auf.Col.Ang)
    else if (Prj.VorlageYN) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Auf.Col.Sperre)
  end;

  //Refreshmode();
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
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTmp  : int;
end;
begin

  vTmp # $Prj.TextEdit->wpdbTextBuf;
  if (vTmp<>0) then TextClose(vTmp);

  RETURN true;
end;


//========================================================================
// TxtRead
//              Texte auslesen
//========================================================================
sub TxtRead()
local begin
  Erx         : int;
  vTxtHdl     : int;         // Handle des Textes
  vName       : alpha;
end
begin

  vName # '~120.'+CnvAI(Prj.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  // Prj.P-Text1(Beschreibung) laden
  vTxtHdl # $Prj.TextEdit->wpdbTextBuf;
  Erx # TextRead(vTxtHdl, vName, 0);
  if (Erx>_rLocked) then TextClear(vTxtHdl);
//  Lib_Texte:TxtLoadLangBuf(vName,vTxtHdl, Auf.Sprache);

  // Textpuffer an Felder übergeben
  $Prj.TextEdit->wpdbTextBuf # vTxtHdl;
  $Prj.TextEdit->WinUpdate(_WinUpdBuf2Obj);

end;


//========================================================================
// TxtSave
//              Text abspeichern
//========================================================================
sub TxtSave()
local begin
  vTxtHdl     : int;         // Handle des Textes
  vName       : alpha;
end
begin

  vName # '~120.'+CnvAI(Prj.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8);

  vTxtHdl # $Prj.TextEdit->wpdbTextBuf;
  $Prj.TextEdit->WinUpdate(_WinUpdObj2Buf);
  TxtWrite(vTxtHdl,vName, _TextUnlock);

//  Lib_Texte:TxtSave5Buf('~120.'+CnvAI(Prj.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Prj.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'',
//    vTxtHdl_L1, 0,0,0,0);
END;


//========================================================================
//  Zeitplan
//                  Zeitplan ausdrucken
//========================================================================
sub Zeitplan();
local begin
  Erx       : int;
  vHdl      : int;
  vA        : alpha(1000);
  vFilename : alpha;
  vFile     : int;
  vCount    : int;
  vMin,vMax : date;
  vBasis    : int;
  vEnd      : int;
  vX        : int;
  vI        : int;
  vDat      : date;
  vF        : float;
  vTree     : int;
  vItem     : int;
  vTextName : alpha(1000);
  vBildName : alpha(1000);
  vGleName  : alpha(1000);
  vEpsName  : alpha(1000);
end;
begin

  FsiPathCreate(_Sys->spPathTemp+'StahlControl');
  FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
  vFilename # gUsername;

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  vMin # 1.1.2099;
  FOR Erx # RecLink(122,120,4,_recFirst)
  LOOP Erx # RecLink(122,120,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // Keine gelöschten Positionen mehr anzeigen
    if ("Prj.P.Lösch.Datum" <> 0.0.0) then
      CYCLE;
    if (Prj.P.Datum.Start=0.0.0) or (Prj.P.Datum.Ende=0.0.0) then
      CYCLE;

    if (Prj.P.Datum.Start<vMin) and (Prj.P.Datum.Start>0.0.0) then
      vMin # Prj.P.Datum.Start;
    if (Prj.P.Datum.Ende>vMax) then   vMax # Prj.P.Datum.Ende;

    Sort_ItemAdd(vTree,cnvai(cnvid(Prj.P.Datum.Start),_FmtNumNoGroup|_FmtNumLeadZero,0,8),122,RecInfo(122,_RecId));

    vCount # vCount + 1;
  END;
  if (vCount=0) then begin
    Sort_KillList(vTree);
    RETURN;
  end;


  vBasis # cnvid(vMin);

  // Datenfile erzeugen...
  vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+vFilename+'.txt';
  vFile # FSIOpen(vTextName, _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then RETURN;
    //Gv.Alpha.01     # Translate('Datei nicht beschreibbar:')+' '+fName;


  vA # '"Projektplan: '+Prj.Bemerkung+' '+Prj.Adressstichwort+ ': '+CnvAd(SysDate()) +'"';
  vA # vA + ' '+AInt(vCount);
  vEnd #  cnvid(vMax) - vBasis;    // grösster Balken
  vA # vA + ' '+AInt(vEnd);
  vA # Lib_strings:Strings_DOS2XML(vA);
  vA # vA + strchar(13)+ strchar(10);
  FsiWrite(vFile, vA);


  vA # '';
  FOR vI # 0 loop inc(vI) while (vI<=10) do begin
    if (vA<>'') then vA # vA + ' ';
    vF # (cnvfi(vEnd) / 10.0) * cnvfi(vI);
    vX # cnvif(vF) + vBasis;
    vDat # cnvdI(vX);
    vA # vA + '"'+Lib_Berechnungen:KurzDatum_Aus_Datum(vDat)+'"';
  END;
  vA # vA + strchar(13)+ strchar(10);
  FsiWrite(vFile, vA);

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    // Keine gelöschten Positionen mehr anzeigen
    if ("Prj.P.Lösch.Datum" <> 0.0.0) then
      CYCLE;


    vA # '"'+StrCut(AInt(prj.p.position)+'/'+aint(Prj.P.SubPosition)+') '+Prj.P.Bezeichnung,1,35)+'"';
    if (Prj.P.Datum.Start<>0.0.0) and (Prj.P.Datum.Ende<>0.0.0) then begin
      vX # cnvid(Prj.P.Datum.Start) - vBasis;
      vA # vA + ' ' + AInt(vX);
      vX # cnvid(Prj.P.Datum.Ende) - vX - vBasis;
      vA # vA + ' ' + AInt(vX);
    end
    else begin
      vA # vA + ' 0 0';
    end;

    vA # vA + ' "' + Lib_Berechnungen:KurzDatum_Aus_Datum(Prj.P.Datum.Start)+'"';
    vA # vA + ' "' + Lib_Berechnungen:KurzDatum_Aus_Datum(Prj.P.Datum.Ende)+'"';

    // ST 2009-07-28 ********************************************************
    // Farbdarstellung abhängig vom Status
    begin
      CASE (Prj.P.Status) OF
        // In Planung
        2 : begin
          // Verzögerung
          if (Prj.P.Datum.Ende < sysDate()) then
            vA # vA + ' "red"';
          else
          // Noch ok
          if (Prj.P.Datum.Ende >= sysDate()) then
            vA # vA + ' "green"';
        end;

        // Angebot
        3 : begin
          vA # vA + ' "yellow"';
        end;

        // erledigt
        12 : begin
          vA # vA + ' "gray"';
        end;

        // Alle anderen Stati
        otherwise
          vA # vA + ' "blue"';

      END;


/*  // Alte Version
    if ("Prj.P.Lösch.Datum"=0.0.0) then
      vA # vA + ' "green"'
    else
      vA # vA + ' "red"';
*/

    end; // ST 2009-07-28




    vA # Lib_strings:Strings_DOS2XML(vA);
    vA # vA + strchar(13)+ strchar(10);
    FsiWrite(vFile, vA);

  END;

  Sort_KillList(vTree);
  FsiClose(vFile);


  vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+vFilename+'.jpg';
  vGleName  # _Sys->spPathTemp+'StahlControl\Visualizer\'+vFilename+'.gle';
  vEpsName  # _Sys->spPathTemp+'StahlControl\Visualizer\'+vFilename+'.eps';


  // Script kopieren...
//  SysExecute('cmd', '/c copy '+Set.Graph.Workpfad+'scripts\PROJEKTE.gle '+Set.Graph.Workpfad+'scripts\'+vFilename+'.gle',_execminimized|_execwait);
  SysExecute('cmd', '/c copy '+Set.Graph.Workpfad+'scripts\PROJEKTE.gle '+vGleName,_execminimized|_execwait);

  // EPS generieren...
/*
  vA # Set.Graph.Workpfad+'scripts\'+vFilename+'.gle';
  vA # vA + ' .\' + Set.Graph.Workpfad + vFilename+'.txt';
*/
  vA # vGleName;
  vA # vA + ' ' + vTextName;
  SysExecute(Set.Graph.Workpfad+'gle\bin\gle',vA ,_execminimized|_execwait);

  // EPS in JPG wandeln...
//  vA # '-I'+Set.Graph.Workpfad+'gscript -dBATCH -dNOPAUSE -dDEVICEWIDTHPOINTS=1000 -dDEVICEHEIGHTPOINTS=550 -r300 -sDEVICE=jpeg -sOUTPUTFILE='+Set.Graph.Workpfad+'pics\'+ vFilename +'.jpg '+Set.Graph.Workpfad+'scripts\'+vFilename+'.eps';
  vA # '-I'+Set.Graph.Workpfad+'gscript -dBATCH -dNOPAUSE -dDEVICEWIDTHPOINTS=1000 -dDEVICEHEIGHTPOINTS=550 -r300 -sDEVICE=jpeg -sOUTPUTFILE='+vBildName+' '+vEpsName;
  SysExecute(Set.Graph.Workpfad+'GScript\bin\gswin32',vA,_execminimized|_execwait);

  // JPG anzeigen
//  Dlg_Bild('*'+Set.Graph.Workpfad+'pics\'+vFilename+'.jpg');
  Dlg_Bild('*'+vBildName);

  // Aufräumen...
/*
  FsiDelete(Set.Graph.Workpfad+'scripts\'+vFilename+'.eps');
  FsiDelete(Set.Graph.Workpfad+'scripts\'+vFilename+'.gle');
  FsiDelete(Set.Graph.Workpfad+vFilename+'.txt');
  FsiDelete(Set.Graph.Workpfad+'pics\'+vFilename+'.jpg');
*/
  FsiDelete(vEpsName);
  FsiDelete(vGleName);
  FsiDelete(vTextName);
  FsiDelete(vBildName);
end;


//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vBuf  : int;
end;
begin

  if (aName='CLMPRJ.ADRESSSTICHWORT') and (aBuf->Prj.Adressnummer<>0) then
     Adr_Main:Start(0, aBuf->Prj.Adressnummer,y);
  
  if ((aName =^ 'edPrj.Adressnummer') AND (aBuf->Prj.Adressnummer<>0)) then begin
    RekLink(100,120,1,0);   // Adresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edPrj.Projektleiter') AND (aBuf->Prj.Projektleiter<>'')) then begin
    Usr.Name # Prj.Projektleiter;
    RecRead(800,1,0);
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edPrj.Team') AND (aBuf->Prj.Team<>'')) then begin
    Usr.Name # Prj.Team;
    RecRead(800,1,0);
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;

  

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================