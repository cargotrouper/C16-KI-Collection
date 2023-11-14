@A+
//==== Business-Control ==================================================
//
//  Prozedur    ApL_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  30.05.2014  AH  Aufruf der Aufpreisliste (Zeile 530ff) nutzt AINT statt CNVAI
//  14.02.2022  AH  ERX, Kopieren übernimmt Adresse + Erzeuger
//  17.07.2022  HA  Quick Jump
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
//    SUB AusErzeuger()
//    SUB AusLKZ()
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

define begin
  cTitle :    'Aufpreise'
  cFile :     842
  cMenuName : 'ApL.Bearbeiten'
  cPrefix :   'Apl'
  cZList :    $ZL.APL
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

  Lib_Guicom2:Underline($edApL.Adressnummer);
  Lib_Guicom2:Underline($edApL.Erzeugernummer);

  SetStdAusFeld('edApL.gueltigeLKZ'    ,'LKZ');
  SetStdAusFeld('edApL.Adressnummer'   ,'Adresse');
  SetStdAusFeld('edApL.Erzeugernummer' ,'Erzeuger');

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

  if (aName='') or (aName='edApL.Adressnummer') then begin
    Erx # RecLink(100,842,2,0);
    if (Erx<=_rLocked) then
      $Lb.Adresse->wpcaption # Adr.Stichwort
    else
      $Lb.Adresse->wpcaption # '';
  end;

  if (aName='') or (aName='edApL.Erzeugernummer') then begin
    Erx # RecLink(100,842,3,0);
    if (Erx<=_rLocked) then
      $Lb.Erzeuger->wpcaption # Adr.Stichwort
    else
      $Lb.Erzeuger->wpcaption # '';
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
begin
  if (Mode=c_ModeNew) then begin
    if (w_AppendNr<>0) then begin
      RecRead(gFile,0,0,w_AppendNr);
    end;
  end;

  // Focus setzen auf Feld:
  $edApL.Key1->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx               : int;
  vID1, vID2, vID3  : int;
  vTmp              : int;
  vAdr, vErz        : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin

    TRANSON;

    // Wenn der Key geändert wurde, dann soll auch in alle APL Positionen der Key geändert sein
    if  (ApL.Key1 <> ProtokollBuffer[842]->ApL.Key1) or
      (ApL.Key2 <> ProtokollBuffer[842]->ApL.Key2) or
      (ApL.Key3 <> ProtokollBuffer[842]->ApL.Key3) then begin

      Erx # RecLink(843,ProtokollBuffer[842],1,_RecFirst | _recLock)
      WHILE (Erx<= _rLocked) do begin
        ApL.L.Key1 # ApL.Key1;
        ApL.L.Key2 # ApL.Key2;
        ApL.L.Key3 # ApL.Key3;
        Erx # RekReplace(843, _recUnlock, 'AUTO');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN False;
        end;
        Erx # RecLink(843,ProtokollBuffer[842],1, _RecFirst | _recLock);
      END;
    end;

    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    TRANSOFF;

    PtD_Main:Compare(gFile);
    end
  else begin

    TRANSON;

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    // Copy von anderer Liste?
    if (w_AppendNr<>0) then begin
      vID1 # ApL.Key1;
      vID2 # ApL.Key2;
      vID3 # ApL.Key3;
      vAdr # ApL.Adressnummer;
      vErz # ApL.Erzeugernummer;
      RecRead(gFile,0,0,w_AppendNr);
      w_AppendNr # 0;
      Erx # RecLink(843,842,1,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        vTmp # RecInfo(843, _recID);
        ApL.L.Key1 # vID1;
        ApL.L.Key2 # vID2;
        ApL.L.Key3 # vID3;
        ApL.L.Adresse   # vAdr;
        ApL.L.Erzeuger  # vErz;
        Erx # RekInsert(843,0,'AUTO');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Msg(001000+Erx,gTitle,0,0,0);
          RETURN False;
        end;
        RecRead(843,0,0,vTmp);
        Erx # RecLink(843,842,1,_recNext);
      END;
      ApL.Key1 # vID1;
      ApL.Key2 # vID2;
      ApL.Key3 # vID3;
      RecRead(842,1,0);
    end;  // Copy

    TRANSOFF;

  end;

  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  w_AppendNr # 0;
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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    TRANSON;
    // Die dazugehörigen Positionen werden mit gelöscht
    Erx # RecLink(843,842,1, _Recfirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(843,0,'MAN');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN;
      end;
      Erx # RecLink(843,842,1, _Recfirst);
    END;

    Erx # RekDelete(gFile,0,'MAN');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
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


    'Erzeuger' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusErzeuger');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LKZ' : begin
      RecBufClear(812);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lnd.Verwaltung',here+':AusLKZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;  // ...case

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.Adressnummer # Adr.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.Adressnummer->Winfocusset(false);
end;


//========================================================================
//  AusErzeuger
//
//========================================================================
sub AusErzeuger()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    ApL.Erzeugernummer # Adr.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.Erzeugernummer->Winfocusset(false);
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
    // Feldübernahme
    gSelected # 0;
    if ("ApL.gültigeLKZ"<>'') then
      "ApL.gültigeLKZ" # "ApL.gültigeLKZ" + ',' + "Lnd.Kürzel"
    else
      "ApL.gültigeLKZ" # "Lnd.Kürzel";
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edApL.gueltigeLKZ->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ApZ_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ApZ_Anlegen]=n);

  vHdl # gMenu->WinSearch('Mnu.Copy');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((Mode<>c_ModeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_ApZ_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ApZ_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ApZ_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ApZ_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_ApZ_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.ChangeLog');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Db_Historie]=n);

  vHdl # gMenu->WinSearch('Mnu.Aufpreisliste');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeEdit) or (Mode=c_ModeNew);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


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
  vQ    : alpha(4000);
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Copy' : begin
      w_AppendNr # RecInfo(gFile,_RecId);
      App_Main:Action(c_ModeNew);
      RETURN true;
    end;


    'Mnu.Aufpreisliste' : begin
      RecBufClear(843);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ApL.L.Verwaltung', '', true);
      // Selektion
      VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
      vQ # 'ApL.L.Key1 = ' + AInt(ApL.Key1);
      vQ # vQ + ' AND ApL.L.Key2 = ' + AInt(ApL.Key2) ;
      vQ # vQ + ' AND ApL.L.Key3 = ' + AInt(ApL.Key3);
      Lib_Sel:QRecList(0, vQ);
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
    'bt.LKZ'      :   Auswahl('LKZ');
    'bt.Adresse'  :   Auswahl('Adresse');
    'bt.Erzeuger' :   Auswahl('Erzeuger');
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


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin
  
  if ((aName =^ 'edApL.Adressnummer') AND (aBuf->ApL.Adressnummer<>0)) then begin
    RekLink(100,842,2,0);   // Gültige LKZs holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edApL.Erzeugernummer') AND (aBuf->ApL.Erzeugernummer<>0)) then begin
    RekLink(100,842,3,0);   // Erzeuger holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;

end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================