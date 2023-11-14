@A+
//==== Business-Control ==================================================
//
//  Prozedur    Adr_A_Main
//                    OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  28.06.2012  MS  Steuerschluessel als Pflichtfeld DEAKTIVIERT
//  10.11.2020  ST  Excelexport und Import
//  01.02.2022  ST  E r g --> Erx
//  11.07.2022  HA  Quick Jump

//  Subprozeduren
//    SUB Start(sub Start(opt aRecId : int; opt aAdrNr : int; opt aASNr : int; opt aView : logic) : logic;
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(opt aName : alpha; opt aChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLKZ()
//    SUB AusPLZ();
//    SUB AusVertreter()
//    SUB AusSteuerschluessel()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aevt : event; arecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cDialog   : 'Adr.A.Verwaltung'
  cRecht    : Rgt_Adr_Anschriften
  cMDIVar   : gMDIAdr
  cTitle :    'Adress-Anschriften'
  cFile :     101
  cMenuName : 'Adr.A.Bearbeiten'
  cPrefix :   'Adr_A'
  cZList :    $ZL.Adr.Anschriften
  cKey :      1
end;

//========================================================================
//  Start
//      Startet das Fenster ein
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aAdrNr  : int;
  opt aASNr   : int;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end
begin
  if (aRecId=0) and (aAdrNr<>0) then begin
    Adr.A.Adressnr  # aAdrNr;
    Adr.A.Nummer    # aASNr;
    Erx # RecRead(101,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(101,_recID);
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

  Lib_Guicom2:Underline($edAdr.A.PLZ);
  Lib_Guicom2:Underline($edAdr.A.LKZ);
  
  
  // Auswahlfelder setzen...
  SetStdAusFeld('edAdr.A.LKZ'           ,'LKZ');
  SetStdAusFeld('edAdr.A.PLZ'           ,'PLZ');
  SetStdAusFeld('edAdr.A.Vertreter'     ,'Vertreter');
  SetStdAusFeld('edAdr.A.Steuerschluessel','Steuerschluessel');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx : int;
end
begin

  if (aName='') or (aName='edAdr.A.Vertreter') then begin
    Erx # RecLink(110,101,6,0);
    if Erx<=_rLocked then
      $Lb.A.Vertreter->wpcaption # Ver.Stichwort
    else
      $Lb.A.Vertreter->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.A.LKZ') then begin
    Erx # RecLink(812,101,2,0);
    if Erx<=_rLocked then
      $Lb.A.Land->wpcaption # Lnd.Name.L1
    else
      $Lb.A.Land->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.A.Steuerschluessel') then begin
    Erx # RecLink(813,101,7,0);
    if (Erx<=_rLocked) then
      $Lb.Steuerschluessel->wpcaption # StS.Bezeichnung
    else
      $Lb.Steuerschluessel->wpcaption # '';
  end;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  vNr   : int;
  Erx : int;
end;
begin

  Adr.A.Adressnr # Adr.Nummer;

  // Felder Disablen durch:
  if (Mode=c_ModeEdit) then begin
    Lib_GuiCom:Disable($edAdr.A.Anschriftnr);
    if (Adr.A.Nummer=1) then begin
      Lib_GuiCom:Disable($edAdr.A.Stichwort);
      Lib_GuiCom:Disable($edAdr.A.Anrede);
      Lib_GuiCom:Disable($edAdr.A.Name);
      Lib_GuiCom:Disable($edAdr.A.Zusatz);
      Lib_GuiCom:Disable($edAdr.A.Strasse);
      Lib_GuiCom:Disable($edAdr.A.LKZ);
      Lib_GuiCom:Disable($edAdr.A.PLZ);
      Lib_GuiCom:Disable($edAdr.A.Ort);
      Lib_GuiCom:Disable($edAdr.A.Telefon);
      Lib_GuiCom:Disable($edAdr.A.Telefax);
      Lib_GuiCom:Disable($edAdr.A.eMail);
      Lib_GuiCom:Disable($edAdr.A.Vertreter);
      Lib_GuiCom:Disable($edAdr.A.USIdentNr);
      Lib_GuiCom:Disable($edAdr.A.Steuerschluessel);
      Lib_GuiCom:Disable($bt.LKZ);
      Lib_GuiCom:Disable($bt.Steuerschluessel);
      Lib_GuiCom:Disable($bt.PLZ);
      $edAdr.A.Tour->WinFocusSet(false);
    end
    else begin
      $edAdr.A.Stichwort->WinFocusSet(false);
    end;
    end;
  else begin
    Erx # RecLink(101,100,12,_reclast);
    if (Erx>_rLocked) then vNr # 1
    else vNr # Adr.A.Nummer + 1;
    RecBufClear(101);
    Adr.A.Adressnr # Adr.Nummer;
    Adr.A.nummer # vNr;
    Lib_GuiCom:Enable($edAdr.A.Anschriftnr);
    $edAdr.A.Anschriftnr->WinFocusSet(false);
  end;

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
end
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;


/* MS 28.06.2012  Als Pflichtfeld ueberfluessig da Std. der Sts. aus der Adr. genommen wird
  Erx # RecLink(813,101,7,0);
  If (Erx>_rLocked) or ("Adr.A.Steuerschlüsse">999) then begin
    Msg(001201,Translate('Steuerschlüssel'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page3';
    $edAdr.A.Steuerschluessel->WinFocusSet(true);
    RETURN false;
  end;
*/

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
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  Adr_Ktd_Data:UpdateFromAnschr();

  RETURN true;  // Speichern erfolgreichend;
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

  if (Adr.A.Nummer<>0) and (RecLinkInfo(252,101,4,_recCount)<>0) then begin
    Msg(100004,translate('Chargen'),0,0,0);
    RETURN;
  end;
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    if (RekDelete(gFile,0,'MAN')=_rOK) then begin
      if (gZLList->wpDbSelection<>0) then begin
        SelRecDelete(gZLList->wpDbSelection,gFile);
        RecRead(gFile, gZLList->wpDbSelection, 0);
      end;
    end;
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
  aFocusObject          : int           // zu verlassendes Objekt
) : logic
local begin
  Erx : int;
end
begin

  if (aEvt:obj->wpname='edAdr.A.Telefon') then begin
    Adr.A.Telefon # Lib_TAPI:Telefonnummer(Adr.A.Telefon);
  end;

  if (aEvt:obj->wpname='edAdr.A.Telefax') then begin
    Adr.A.Telefax # Lib_TAPI:Telefonnummer(Adr.A.Telefax);
  end;

  // logische Prüfung von Verknüpfungen
  if (aEvt:Obj->wpname='edAdr.A.Anschriftnr') and (Mode=c_ModeNew) then begin
    if (Adr.A.Nummer=0) then begin
      Msg(101001,'',0,0,0);
      RETURN false;
    end;
    Erx # RecRead(101,1,_Rectest);
    if (Erx<=_rLocked) then begin
      Msg(101000,'',0,0,0);
      RETURN false;
    end;
  end;
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
    'Vertreter' : begin
      RecBufClear(110);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ver.Verwaltung',here+':AusVertreter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LKZ' : begin
      RecBufClear(812);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Lnd.Verwaltung',here+':AusLKZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'PLZ' : begin
      RecBufClear(847);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ort.Verwaltung',here+':AusPLZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Steuerschluessel' : begin
      RecBufClear(813);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'StS.Verwaltung',here+':AusSteuerschluessel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;  // ...case

end;


//========================================================================
//  AusLKZ
//
//========================================================================
sub AusLKZ()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(812,0,_RecId,gSelected);
    gSelected # 0;
    Adr.A.LKZ   # "Lnd.Kürzel";
    "Adr.A.Steuerschlüsse" # "Lnd.Steuerschlüssel";

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.A.LKZ->Winfocusset(false);
  RefreshIfm('edAdr.A.LKZ');
end;


//========================================================================
//  AusPLZ
//
//========================================================================
sub AusPLZ()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(847,0,_RecId,gSelected);
    gSelected # 0;
    Adr.A.LKZ   # Ort.LKZ;
    Adr.A.PLZ   # Ort.PLZ;
    Adr.A.Ort   # Ort.Name;

    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.A.PLZ->Winfocusset(false);
  gMDI->WinUpdate(_WinUpdFld2Obj);
  RefreshIfm('edAdr.A.LKZ');
end;


//========================================================================
//  AusVertreter
//
//========================================================================
sub AusVertreter()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(110,0,_RecId,gSelected);
    gSelected # 0;
    Adr.A.Vertreter # Ver.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.A.Vertreter->Winfocusset(false);
  //RefreshIfm('edAdr.A.LKZ');
end;


//========================================================================
//  AusSteuerschluessel
//
//========================================================================
sub AusSteuerschluessel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(813,0,_RecId,gSelected);
    gSelected # 0;
    "Adr.A.Steuerschlüsse" # StS.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.A.Steuerschluessel->Winfocusset(false);
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

    vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_A_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_A_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_A_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_A_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (mode<>c_modeView)) or (Rechte[Rgt_Adr_A_Loeschen]=n) or (Adr.A.Nummer=1);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (mode<>c_modeView)) or (Rechte[Rgt_Adr_A_Loeschen]=n) or (Adr.A.Nummer=1);

  $bt.Maps->wpDisabled # false;

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Import]=false;



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
  vHdl : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

     'Mnu.CUS.Felder' : begin
       CUS_Main:Start(gFile, RecInfo(gFile, _recID));
     end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;

  end;
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
    'bt.Maps'           :   Adr_Data:OpenGoogleMaps( "Adr.A.Straße", Adr.A.PLZ, Adr.A.Ort );
  end;

  if Mode=c_ModeView then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.LKZ'            :   Auswahl('LKZ');
    'bt.PLZ'            :   Auswahl('PLZ');
    'bt.Vertreter'      :   Auswahl('Vertreter');
    'bt.Steuerschluessel'  : Auswahl('Steuerschluessel');
  end;

end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aevt      : event;
  arecid    : int;
  Opt aMark : logic;);
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
  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);
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


//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);

begin

  
  if ((aName =^ 'edAdr.A.PLZ') AND (aBuf->Adr.A.PLZ<>'')) then begin
    Ort.LKZ   # aBuf->Adr.A.LKZ;
    Ort.PLZ   # aBuf->Adr.A.PLZ;
    Ort.Name  # aBuf->Adr.A.Ort;
    RecRead(847,1,0);

    Lib_Guicom2:JumpToWindow('Ort.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.A.LKZ') AND (aBuf->Adr.A.LKZ<>'')) then begin
    RekLink(812,101,2,0);   // LKZ holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.A.Vertreter') AND (aBuf->Adr.A.Vertreter<>0)) then begin
    RekLink(110,101,6,0);   // Vertreter holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.A.Steuerschluessel') AND (aBuf->"Adr.A.Steuerschlüsse"<>0)) then begin
    RekLink(813,101,7,0);   // Steuerschlüss holen
    Lib_Guicom2:JumpToWindow('StS.Verwaltung');
    RETURN;
  end;
  
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================