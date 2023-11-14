@A+
//==== Business-Control ==================================================
//
//  Prozedur    Adr_K_Main
//                    OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  10.11.2020  ST  Excelexport und Import
//  01.02.2022  ST  E r g --> Erx
//  11.07.2022  HA  Quick Jump

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
//    SUB AusWaehrung()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aevt : event; arecid : int);
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Kreditlimit'
  cFile :     103
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Adr_K'
  cZList :    $ZL.Adr.Kreditlimits
  cKey :      2
  cListen :   'Adressen'
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


  Lib_Guicom2:Underline($edAdr.K.Waehrung);
  
  SetStdAusFeld('edAdr.K.Waehrung','Waehrung');


  RecLink(103,100,14,_RecFirst);
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
  vAuf  : float;
  vRech : float;
  vOP   : float;
  vRest : float;
end;
begin

  if (Mode=c_ModeView) then
    Lib_GuiCom:Enable($bt.Finanzrefresh)
  else
    Lib_GuiCom:Disable($bt.Finanzrefresh);


  if (aName='') and (Mode<>c_ModeNew) and (mode<>c_ModeEdit) then begin
    //Adr_K_Data:BerechneFinanzen(var vAuf, var vRech, var vOP, var vRest);
    Adr_K_Data:BerechneFinanzen(n, var vRest);
    $lb.SummeAuf->wpcaption       # ANum(Adr.K.SummeAB,2);
    $lb.SummeRes->wpcaption       # ANum(Adr.K.SummeRes,2);
    $lb.SummeLfs->wpcaption       # ANum(Adr.K.SummeLFS,2);
    $lb.SummeBest->wpcaption      # ANum(Adr.K.SummeEkBest,2);
    $lb.SummePlan->wpcaption      # ANum(Adr.K.SummePlan,2);
    $lb.SummeDollar->wpcaption    # ANum(Adr.K.SummeABBere,2);
    $lb.SummeOP->wpcaption        # ANUm(Adr.K.SummeOP,2);
    $Lb.Kreditlimit->wpcaption    # ANUm(vRest,2);
    $Lb.Fin.Refreshdatum->wpcaption # cnvad(Adr.K.Refreshdatum);
  end;

  if (aName='') or (aName='edAdr.K.Waehrung') then begin
    Erx # RecLink(814,103,2,0);
    if Erx<=_rLocked then begin
      $Lb.Waehrung->wpcaption # Wae.Bezeichnung;
      $Lb.FW1->wpcaption # "Wae.Kürzel";
      $Lb.FW2->wpcaption # "Wae.Kürzel";
    end
    else begin
      $Lb.Waehrung->wpcaption # '';
      $Lb.FW1->wpcaption # '???';
      $Lb.FW2->wpcaption # '???';
    end;
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
  // Focus setzen auf Feld:
  $edAdr.K.Versicherer->WinFocusSet(true);
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
  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj)
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

  Lib_Berechnungen:Waehrung_Umrechnen(Adr.K.VersichertFW, "Adr.K.Währung", var Adr.K.VersichertW1, 1);
  Lib_Berechnungen:Waehrung_Umrechnen(Adr.K.KurzlimitFW, "Adr.K.Währung", var Adr.K.KurzlimitW1, 1);
  $edAdr.K.VersichertW1->winupdate(_WinUpdFld2Obj);
  $edAdr.K.KurzLimitW1->winupdate(_WinUpdFld2Obj);

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
    'Waehrung' : begin
      RecBufClear(814);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wae.Verwaltung',here+':AusWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusWaehrung
//
//========================================================================
sub AusWaehrung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    gSelected # 0;
    "Adr.K.Währung" # Wae.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.K.Waehrung->Winfocusset(false);
  RefreshIfm('edAdr.K.Waehrung');
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

  // Button sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeEdit) or  (Mode=c_ModeNew) or (Rechte[Rgt_Adr_K_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeEdit) or  (Mode=c_ModeNew) or (Rechte[Rgt_Adr_K_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;//(vHdl->wpDisabled) or (Rechte[Rgt_Adr_K_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;//(vHdl->wpDisabled) or (Rechte[Rgt_Adr_K_Loeschen]=n);


  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Import]=false;


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
  vHdl    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

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
local begin
  vAuf  : float;
  vRech : float;
  vOP   : float;
  vRest : float;
end;
begin

  case (aEvt:Obj->wpName) of
    'bt.Waehrung'    :   Auswahl('Waehrung');
    'bt.Finanzrefresh'  : begin
      Adr_K_Data:BerechneFinanzen(n, var vRest);
      $lb.SummeAuf->wpcaption       # ANum(Adr.K.SummeAB,2);
      $lb.SummeRes->wpcaption       # ANum(Adr.K.SummeRes,2);
      $lb.SummeLfs->wpcaption       # ANum(Adr.K.SummeLFS,2);
      $lb.SummeDollar->wpcaption    # ANum(Adr.K.SummeABBere,2);
      $lb.SummeOP->wpcaption        # ANUm(Adr.K.SummeOP,2);
      $Lb.Kreditlimit->wpcaption    # ANUm(vRest,2);
      $Lb.Fin.Refreshdatum->wpcaption # cnvad(Adr.K.Refreshdatum);
    end;
  end;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aevt      :  event;
  arecid    : int;
  Opt aMark : logic;
);
begin
//  Refreshmode(y);
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
local begin
  Erx         : int;
  vBuf,vBuf2  : int;
end;
begin

  if ((aName =^ 'edAdr.K.Waehrung') AND ("Adr.K.Währung"<>0)) then begin
    RekLink(814,103,2,0);   // Währung holen
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;
  
end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================