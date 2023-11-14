@A+
//==== Business-Control ==================================================
//
//  Prozedur    LiB_Main
//                        OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  28.08.2012  ST  Umstellung auf Standardmenü
//  27.07.2021  AH  ERX
//  2023-02-23  AH  "EditNummer"
//  2023-06-23  AH  "EditNummer" kann MERGE
//  2023-08-14  AH  "LiB.SperreNeuYN"
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB RefreshIfm(optaName : alpha)
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Lieferbedingungen'
  cFile :     815
  cMenuName : 'LiB.Bearbeiten'
  cPrefix :   'LiB'
  cZList :    $ZL.Lieferbedingungen
  cKey :      1
  cListen     : 'Lieferbedingungen'
end;

declare RefreshIfm(opt aName : alpha;)


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
  App_Main:EvtInit(aEvt);
end;


/*========================================================================
2023-02-23  AH
========================================================================*/
sub _EditNummerInner(
  aAlt          : word;
  aNeu          : word;
  aDia          : int;
  aNurAdressen  : logic;
  ) : alpha;
local begin
  Erx : int;
end;
begin
  if (Lib_Rec:LoopDataAndReplaceInt(100, 'Adr.EK.Lieferbed', aAlt, 'Adr.EK.Lieferbed' , aNeu, aDia, 'Adresse EK') = false) then RETURN 'Adresse';
  if (Lib_Rec:LoopDataAndReplaceInt(100, 'Adr.VK.Lieferbed', aAlt, 'Adr.VK.Lieferbed' , aNeu, aDia, 'Adresse VK') = false) then RETURN 'Adresse';
  if (aNurAdressen=false) then begin
    if (Lib_Rec:LoopDataAndReplaceInt(190, 'HuB.EK.Lieferbed', aAlt, 'HuB.EK.Lieferbed' , aNeu, aDia, 'HuB-Bestellung') = false) then RETURN 'HuB-Bestellung';
    if (Lib_Rec:LoopDataAndReplaceInt(400, 'Auf.Lieferbed', aAlt, 'Auf.Lieferbed' , aNeu, aDia, 'Auftrag') = false) then RETURN 'Auftrag';
    if (Lib_Rec:LoopDataAndReplaceInt(410, 'Auf~Lieferbed', aAlt, 'Auf~Lieferbed' , aNeu, aDia, 'Auftragsablage') = false) then RETURN 'Auftragsablage';
    if (Lib_Rec:LoopDataAndReplaceInt(460, 'OfP.Lieferbed', aAlt, 'OfP.Lieferbed' , aNeu, aDia, 'Offene Posten') = false) then RETURN 'OffenePosten';
    if (Lib_Rec:LoopDataAndReplaceInt(470, 'OfP~Lieferbed', aAlt, 'OfP~Lieferbed' , aNeu, aDia, 'Offene Posten Ablage') = false) then RETURN 'OffenePostenablage';
    if (Lib_Rec:LoopDataAndReplaceInt(500, 'Ein.Lieferbed', aAlt, 'Ein.Lieferbed' , aNeu, aDia, 'Bestellung') = false) then RETURN 'Bestellung';
    if (Lib_Rec:LoopDataAndReplaceInt(510, 'Ein~Lieferbed', aAlt, 'Ein~Lieferbed' , aNeu, aDia, 'Bestellungsablage') = false) then RETURN 'Bestellungsablage';
  end;
  
  RETURN '';
end;


/*========================================================================
2023-02-23  AH
========================================================================*/
sub EditNummer(
  aNurAdresse : logic;
  ) : logic;
local begin
  Erx         : int;
  v815        : int;
  vNeu,vAlt   : int;
  vErr        : alpha;
  vDia        : int;
  vHdl        : int;
  vMax        : int;
  vMdi        : int;
  vMerge      : logic;
end;
begin
  if (Rechte[Rgt_LiB_aendern]=n) then RETURN false;

  vMdi # gMDI;
  vNeu # Lib.Nummer;
  vAlt # vNeu;

  if (Dlg_Standard:Anzahl(Translate('Nummer'), var vNeu, vAlt)=false) then RETURN false;
  if (vNeu<=0) or (vNeu>65000) then RETURN false;
  if (vAlt=vNeu) then RETURN true;

// 2023-06-23 AH
  v815 # RekSave(815);
  Lib.Nummer # vNeu;
  Erx # RecRead(815,1,0);
  RekRestore(v815);
  if (Erx=_rOK) then begin
    if (Msg(997009,aint(vAlt)+'|'+aint(vNeu),_WinIcoWarning,_WinDialogYesNo, 2)<>_winidyes) then RETURN false;
    vMerge # true;
  end
  else begin
    if (Msg(997008,aint(vAlt)+'|'+aint(vNeu),_WinIcoQuestion,_WinDialogYesNo, 2)<>_winidyes) then RETURN false;
  end;

  vMax # 9;
  vDia  # WinOpen('Dlg.Progress',_WinOpenDialog);
  vHdl  # Winsearch(vDia,'Progress');
  vHdl->wpProgressPos # 1;
  vHdl->wpProgressMax # vMax;
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);

  TRANSON;

  if (vMerge) then begin
    Lib.Nummer # vAlt;
    RecRead(815,1,0);
    Erx # RekDelete(815);
  end
  else begin
    Lib.Nummer # vAlt;
    RecRead(815,1,_recLock);
    Lib.Nummer # vNeu;
    Erx # RekReplace(815);
  end;
  if (erx<>_rOK) then begin
    if (erx<>_rDeadLock) then TRANSBRK;
    if (vDia<>0) then vDia->WinClose();
    vMDI->winupdate();
    VarInstance(WindowBonus,cnvIA(vMDI->wpcustom));
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;

  vErr # _EditNummerInner(vAlt, vNeu, vDia, aNurAdresse);
  if (vErr<>'') then begin
    TRANSBRK;
    if (vDia<>0) then vDia->WinClose();
    vMDI->winupdate();
    VarInstance(WindowBonus,cnvIA(vMDI->wpcustom));
    Msg(999999,vErr+' konnte nicht gespeichert werden!',0,0,0);
    RETURN false;
  end;

  TRANSOFF;

  if (vDia<>0) then vDia->WinClose();
  vMDI->winupdate();
  VarInstance(WindowBonus,cnvIA(vMDI->wpcustom));

  RefreshList(gZllist, _WinLstRecFromRecid | _WinLstRecDoSelect);

  Msg(999998,'',0,0,0);
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
  // Felder Disablen durch:
  // Lib_GuiCom:Disable($);

  // Focus setzen auf Feld:
  if (mode=c_Modenew) then
    $edLiB.Nummer->WinFocusSet(true)
  else
    $edLiB.Bezeichnung.L1->WinFocusSet(true);

  RefreshIfm('lbLib.Zusatztext');
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

  // Text Lesen
  Txt.Nummer # LiB.Zusatztextnr;
  Erx # RecRead(837,1,0);
  if (Erx<=_rLocked) then
    $lbLib.Zusatztext->wpcaption # Txt.Bezeichnung
  else
    $lbLib.Zusatztext->wpcaption # '';

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
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
  if (aEvt:Obj->wpname='edLib.Zusatztextnr') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

  RefreshIfm('lbLib.Zusatztext');

end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // zu verlassendes Objekt
) : logic
begin

  // logische Prüfung von Verknüpfungen

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
  vQ        : alpha(4000);
end;
begin
  case aBereich of
    'Text': begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusText');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  // Bereich Lieferbedingung
      Gv.Alpha.01 # 'G';
      vQ # '';
      Lib_Sel:QenthaeltA( var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusText
//
//========================================================================
sub AusText()
local begin
  vTxtHdl      : int;
end;
begin


  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    gSelected # 0;

    LiB.Zusatztextnr # Txt.Nummer;
    $edLib.Zusatztextnr->wpCaptionint # Txt.Nummer;
    $edLib.Zusatztextnr->Winupdate(_WinUpdFld2Obj);

    // Focus auf Editfeld setzen:
    $edLib.Zusatztextnr->Winfocusset(true);
  end;
  gSelected # 0;

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

  // Button sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LiB_Anlegen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LiB_Anlegen]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LiB_aendern]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LiB_aendern]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LiB_loeschen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_LiB_loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Export]=n);
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Schluesseldaten_Import]=n);


  RefreshIfm('lbLib.Zusatztext');
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
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.Edit.Nummer' : begin   // 2023-02-23 AH
      EditNummer(false);
    end;


    'NextPage' : begin
          vHdl # gMdi->Winsearch('NB.Main');
      end;


    'PrevPage' : begin
          vHdl # gMdi->Winsearch('NB.Main');
      end;


    'Mnu.Auswahl' : begin
        vHdl # WinFocusGet();
        if vHdl<>0 then begin
          case vHdl->wpname of
            'edLib.Zusatztextnr' :   Auswahl('Text');
          end;
        end;
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

  if Mode=c_ModeView then RETURN true;

  case (aEvt:Obj->wpName) of

    'bt.Standardtext' :  begin
       Auswahl('Text');
    end;

    //'...' : begin // simuliere Menücommand
    //  EvtMenuCommand(null,aEvt:Obj);
    //end;

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
  Refreshmode();
  if (Lib.SperreNeuYN) then
    Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
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
  RETURn true;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================