@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_Z_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  13.12.2012  AI  Formelfunktion
//  16.01.2018  AH  Wenn nur eine Aufpreisliste existiert, dann Kopfabfrage sparen
//  10.05.2022  AH  ERX
//  22.07.2022  HA  Quick Jump
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
//    SUB AusSchluessel()
//    SUB AusSchluessel2()
//    SUB AusWarengruppe()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtTimer(aEvt : event; aTimerId : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Bestellkopf-Aufpreise'
  cTitle2 :    'Bestellpositions-Aufpreise'
  cFile :     503
  cMenuName : 'Ein.Z.Bearbeiten'
  cPrefix :   'Ein_Z'
  cZList :    $ZL.Ein.Aufpreise
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
  if (Ein.P.Position=0) then
    gTitle  # Translate(cTitle)
  else
    gTitle  # Translate(cTitle2);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edEin.Z.Schluessel);
Lib_Guicom2:Underline($edEin.Z.Warengruppe);

  SetStdAusFeld('edEin.Z.Schluessel'    ,'Schluessel');
  SetStdAusFeld('edEin.Z.MEH'           ,'MEH');
  SetStdAusFeld('edEin.Z.Warengruppe'   ,'Warengruppe');

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
  Erx     : int;
  vTmp    : int;
end;
begin

  if (Mode=c_modeNew) or (Mode=c_ModeEdit) then begin
    if (Ein.Z.PerFormelYN) then begin
      Lib_GuiCom:Enable($edEin.Z.FormelFunktion);
      end
    else begin
      Lib_GuiCom:Disable($edEin.Z.FormelFunktion);
    end;
  end;

  if (aName='') then begin
    $lb.Nummer->wpcaption # AInt(Ein.Z.Nummer);
    $lb.Position->wpcaption # AInt(Ein.Z.Position);
    $lb.Lieferant->wpcaption # Ein.P.LieferantenSW;
    RecLink(814,500,8,0);     // Währung holen
    $lb.WAE->wpcaption # "Wae.Kürzel";
  end;

  if (aName='') or (aName='edEin.Z.Warengruppe') then begin
    Erx # RecLink(819,503,1,0);
    if (Erx<=_rLocked) then
      $lb.Wgr->wpcaption # Wgr.Bezeichnung.L1
    else
      $lb.Wgr->wpcaption # '';
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
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then begin
    Ein.Z.Nummer # Ein.P.Nummer;
    Ein.Z.Position # Ein.P.Position;
    Ein.Z.MEH # 'kg';
    Ein.Z.PEH # 1000;
    Ein.Z.MengenbezugYN # y;
  end;

  $edEin.Z.Schluessel->WinFocusSet(true);
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
    PtD_Main:Compare(gFile);
  end
  else begin
    Ein.Z.Anlage.Datum  # Today;
    Ein.Z.Anlage.Zeit   # Now;
    Ein.Z.Anlage.User   # gUsername;

    Ein.Z.lfdNr         # 1;

    repeat
      Erx # RekInsert(gFile,0,'MAN');
      Ein.Z.lfdNr # Ein.Z.lfdNr + 1;
    until (Erx = _rOk);

    /*erx RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;*/

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
  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
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
  Erx     : int;
  vParent : int;
  vA      : alpha;
  vMode   : alpha;
  vQ      : alpha(4000);
end;
begin

  case aBereich of
    'Schluessel' : begin

      // Ankerfunktion
      if (RunAFX('APL.Auswahl','503')<0) then RETURN;

      // 16.01.2018 AH: Wenn nur eine Liste?
      if (RecInfo(842,_recCount)=1) then begin
        Erx # RecRead(842,1,_recFirst);
        Auswahl('Schluessel2');
        RETURN;
      end;

      RecBufClear(842);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Apl.Verwaltung',here+':AusSchluessel');

      // Selektion
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList( 0, 'ApL.EinkaufYN' );

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Schluessel2' : begin
      RecBufClear(843);
      Lib_GuiCom:AddChildWindow(gMDI,'Apl.L.Verwaltung',here+':AusSchluessel2');
      // Selektion
      VarInstance(WindowBonus, CnvIA(gMDI->wpCustom));
      vQ # 'ApL.L.Key1 = ' + cnvAI(ApL.Key1);
      vQ # vQ + ' AND ApL.L.Key2 = ' + cnvAI(ApL.Key2) ;
      vQ # vQ + ' AND ApL.L.Key3 = ' + cnvAI(ApL.Key3);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edEin.Z.MEH,503,1,6);
    end;


    'Warengruppe' : begin
      RecBufClear(819);
      Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusSchluessel
//
//========================================================================
sub AusSchluessel()
begin
  if (gSelected<>0) then begin
    RecRead(842,0,_RecId,gSelected);
    $edEin.Z.Schluessel->wpCustom # 'xx';//cnvai(gselected);

    // Event für Anschriftsauswahl starten
    gTimer2 # SysTimerCreate(500,1,gMDI);

    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edEin.Z.Schluessel->Winfocusset(true);
end;


//========================================================================
//  AusSchluessel2
//
//========================================================================
sub AusSchluessel2()
begin
  // Zugriffliste wieder aktivieren
  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    RecRead(843,0,_RecId,gSelected);
    RecLink(842,843,5,_recFirst); // Aufpreisliste holen

    gSelected # 0;
    Ein.Z.Nummer          # Ein.P.Nummer;
    Ein.Z.Position        # Ein.P.Position;
    "Ein.Z.Schlüssel"     # '#'+Cnvai(ApL.L.Key2,_fmtnumleadzero,0,3)+'.'+CnvAI(ApL.L.Key3,_fmtnumleadzero,0,3)+'.'+cnvai(ApL.L.Key4,_fmtnumleadzero,0,3);
    Ein.Z.Bezeichnung     # ApL.L.Bezeichnung.L1;
    Ein.Z.Menge           # ApL.L.Menge;
    Ein.Z.MEH             # ApL.L.MEH;
    Ein.Z.PEH             # ApL.L.PEH;
    Ein.Z.MengenbezugYN   # ApL.L.MengenbezugYN;
    Ein.Z.RabattierbarYN  # ApL.L.RabattierbarYN;
    Ein.Z.NeuberechnenYN  # ApL.L.NeuberechnenYN;
    Ein.Z.ProRechnungYN   # ApL.L.ProRechnungYN;;
    Ein.Z.PerFormelYN     # ApL.L.PerFormelYN;
    Ein.Z.FormelFunktion  # ApL.L.FormelFunktion;

    Ein.Z.Preis           # ApL.L.Preis;
    Ein.Z.Warengruppe     # ApL.L.Warengruppe;
    Ein.Z.MatAktionYN     # ApL.MatAktionYN;
    RefreshIfm();
  end;

  gMDI->WinUpdate(_WinUpdFld2Obj);

  // Focus auf Editfeld setzen:
  $edEin.Z.Schluessel->Winfocusset(true);
end;

//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    Ein.Z.Warengruppe # Wgr.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edEin.Z.Warengruppe->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_Z_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_Z_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_Z_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_Z_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_Z_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EK_Z_Loeschen]=n);

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
  vHdl : int;
  vMode : alpha;
  vParent : int;
  vTmp : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Auto' : begin
        if (Msg(842000,gTitle,_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin
          if (FldInfoByName('Ein.P.Cust.PreisZum',_FldExists)>0) then
            ApL_Data:AutoGenerieren(501,n ,0, FldDateByName('Ein.P.Cust.PreisZum'))
          else
            ApL_Data:AutoGenerieren(501);
          gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
        end;
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Ein.Z.Anlage.Datum, Ein.Z.Anlage.Zeit, Ein.Z.Anlage.User );
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
    'bt.Schluessel'   :   Auswahl('Schluessel');
    'bt.MEH'          :   Auswahl('MEH');
    'bt.Wgr'          :   Auswahl('Warengruppe')
  end;

end;


//========================================================================
//  EvtChanged
//              Feldinhalt verändert
//========================================================================
sub EvtChanged (
  aEvt                  : event;        // Ereignis
) : logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (Mode=c_ModeView) then RETURN true;

  if (aEvt:Obj->wpname='cbEin.Z.MengenbezugYN') then begin
    if (Ein.Z.MengenBezugYN) then begin
      Ein.Z.PerFormelYN     # n;
      Ein.Z.FormelFunktion  # '';
      $edEin.Z.FormelFunktion->winupdate(_WinUpdFld2Obj);
      $cbEin.Z.PerFormelYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edEin.Z.FormelFunktion);
    end;
  end;

  if (aEvt:Obj->wpname='cbEin.Z.PerFormelYN') then begin
    if (Ein.Z.PerFormelYN) then begin
      Ein.Z.MengenbezugYN # n;
      $cbEin.Z.MengenbezugYN->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Enable($edEin.Z.FormelFunktion);
      end
    else begin
      Ein.Z.FormelFunktion # '';
      $edEin.Z.FormelFunktion->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edEin.Z.FormelFunktion);
    end;
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


//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer
(
  aEvt                  : event;        // Ereignis
  aTimerId              : int;
): logic
local begin
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (aTimerID=gTimer2) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
    if ($edEin.Z.Schluessel->wpcustom<>'') then begin
      $edEin.Z.Schluessel->wpcustom # '';
      Auswahl('Schluessel2');
    end;
    end
  else begin
    App_Main:EvtTimer(aEvt, aTimerId);
  end;

  RETURN true;
end;

sub JumpTo(
  aName : alpha;
  aBuf  : int);
  
local begin
  vToken : alpha;
  vBuf,vBuf2  : int;
end;

begin

  if ((aName =^ 'edEin.Z.Schluessel') AND (aBuf->"Ein.Z.Schlüssel"<>'')) then begin
     RecBufClear(842);
   vToken # Lib_Strings:Strings_Token("Ein.Z.Schlüssel", '.', 1);
   ApL.Key1 # CnvIA(vToken);
   
   vToken # Lib_Strings:Strings_Token("Ein.Z.Schlüssel", '.', 2);
   ApL.Key2 # CnvIA(vToken);
   
   vToken # Lib_Strings:Strings_Token("Ein.Z.Schlüssel", '.', 3);
   ApL.Key2 # CnvIA(vToken);
    Lib_Guicom2:JumpToWindow('Apl.L.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edEin.Z.Warengruppe') AND (aBuf->Ein.Z.Warengruppe<>0)) then begin
    RekLink(819,503,1,0);   // Schlüssel holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================