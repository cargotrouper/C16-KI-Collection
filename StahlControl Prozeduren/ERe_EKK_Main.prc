@A+
//==== Business-Control ==================================================
//
//  Prozedur    ERe_EKK_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  25.06.2013  AH  Neu: EKK.Zuordnung.Datum
//  01.07.2014  ST  APPON, APPOFF bei Zuordnung markierter Datensätze Projekt 1423/22
//  31.07.2018  AH  AFX "ERe.Ekk.AusZuordnung"
//  06.03.2019  ST  EvtLstDAtaInit: weitere Materialdaten hinzugefügt (Charge, Werksnr)
//  21.02.2022  AH  ERX
//  09.05.2022  AH  "ZurEKK"
//  2023-07-12  ST  Neu: Anker für EvtInit und EvtLstDataInit hinzugefügt
//
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
//    SUB AusZuordnung()
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
  cTitle :    'Einkaufskontrolle'
  cFile :     555
  cMenuName : 'EKK.Bearbeiten'
  cPrefix :   'ERe_EKK'
  cZList :    $ZL.ERe.EKK
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

  RunAFX('Ere.Ekk.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Ere.Ekk.Init',aint(aEvt:Obj));
 
end;


//========================================================================
sub zurEKK(opt aFilter : alpha)
local begin
  Erx   : int;
  vQ    : alpha(1000);
end;
begin

  RecBufClear(555);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'EKK.Verwaltung',here+':AusZuordnung',n,n,'560');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  vQ # '';
  Lib_Sel:QInt( var vQ, 'EKK.EingangsreNr', '=', 0);
  Lib_Sel:QInt( var vQ, 'EKK.Lieferant', '=', ERe.Lieferant);
  if (aFilter=*'506:*') then begin
    Lib_Sel:QInt( var vQ, 'EKK.Datei', '=', 506);
    Lib_Sel:QInt( var vQ, 'EKK.ID1', '=', cnvia(Str_Token(aFilter,':',2)));
  end;
  Lib_Sel:QRecList(0,vQ);
  Filter_EKK # y;
  Lib_GuiCom:RunChildWindow(gMDI);
  gZLList->WinFocusSet(true);

  RETURN;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vTmp : int;
end;
begin

  if (w_Command=*'->EKK') then begin
    gMDI->WinEvtProcNameSet(_WinEvtTimer, here+':EvtTimer');
    w_TimerVar # '->EKK|'+w_Cmd_Para;
    w_command   # '';
    w_cmd_Para  # '';
    gTimer2 # SysTimerCreate(700,1,gMdi);
  end;

  vTmp # Winsearch(gMenu, 'Mnu.MatAktionen');
  if (vTmp<>0) then vTmp->wpdisabled # true;

  RecLink(814,555,3,_recFirst);   // Währung holen
  $lb.Waehrung->wpcaption # Wae.Bezeichnung;
  $lb.Wae1->wpcaption # "Wae.Kürzel";
  $lb.Wae2->wpcaption # "Wae.Kürzel";

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
local begin
  vHdl : int;
end;
begin
  RETURN;
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  if (w_Auswahlmode) then begin

    Mode # c_ModeList;
    Lib_GuiCom:SetMaskState(false);
    vHdl # gMdi->winsearch('NB.List');
    vHdl->wpdisabled # false;
    vHdl # gMdi->winsearch('NB.Main');
    vHdl->wpCurrent # 'NB.List';

    RecBufClear(555);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'EKK.Verwaltung',here+':AusZuordnung');
    Lib_GuiCom:RunChildWindow(gMDI);
//      $ZL.EKK->wpDbFileno # 555;
  //    $ZL.EKK->wpDbKeyNo # 4;
    //  $ZL.EKK->wpDbLinkFileno # 560;
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    gZLList->WinFocusSet(true);
  end
  else begin
    // Focus setzen auf Feld:
    $edEKK.Lieferant->WinFocusSet(true);
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
  if (EKK.Materialnummer<>0) then begin
    Rek.P.Materialnr # EKK.Materialnummer;
    Erx # RecRead(301,8,0);   // Reklamation vorhanden?
    if (Erx<=_rMultikey) then begin
      if (Msg(555006,'',_WinIcoWarning,_WinDialogYesNo,1)<>_WinIdYes) then RETURN false;
    end;
  end;

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
local begin
  Erx : int;
end;
begin

//  if (w_Auswahlmode) then begin
    if (Msg(555001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      RecRead(555, 1, _RecLock);
      EKK.EingangsReNr    # 0;
      EKK.Zuordnung.Datum # 0.0.0;
      EKK.Zuordnung.Zeit  # 0:0;
      EKK.Zuordnung.User  # '';
      Rekreplace(555,_recUnlock,'AUTO');

      // Wareneingang?
      if (EKK.Datei=506) then begin
        Erx # RecLink(506,555,2,_RecFirst);
        if (Erx>_rOK) then RecBufClear(506);
        // Materialeingang?
        if (Ein.E.Materialnr<>0) then begin
          Erx # RecLink(200,506,8,_recFirst);
          if (Erx=_rOK) then begin
            RecRead(200,1,_recLock);
            Mat.EK.RechNr # 0;
            Mat.EK.RechDatum # 0.0.0;
            Mat_data:Replace(_RecUnlock,'AUTO');
          end
          else begin
            Erx # RecLink(210,506,9,_recFirst);
            if (Erx=_rOK) then begin
              RecRead(210,1,_recLock);
              "Mat~EK.RechNr"     # 0;
              "Mat~EK.RechDatum"  # 0.0.0;
              Mat_Abl_Data:ReplaceAblage(_RecUnlock,'AUTO');
            end;
          end;
        end;
      end;

    end;
/*
    end
  else begin
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      RekDelete(gFile,0,'MAN');
    end;
  end;
*/
  cZList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

end;


//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer(
  aEvt                  : event;        // Ereignis
  aTimerId              : int;
): logic
local begin
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (gTimer2=aTimerId) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;

   if (StrFind(w_TimerVar,'->EKK',0)>0) then begin
      vA # Str_Token(w_TimerVar,'|',2);
      ZurEKK(vA);
      RETURN true;
    end
  end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
  end;

  RETURN true;
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

  Lib_GuiCom:Disable($edEKK.ZuordnungDatum);

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
//  AusZuordnung
//
//========================================================================
sub AusZuordnung()
local begin
  vX      : int;
  vItem   : int;
  vMode   : alpha;
  vMFile  : int;
  vMID    : int;
  vPos    : int;
end;
begin

  // Zugriffliste wieder aktivieren
  // cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  //  Lib_GuiCom:SetWindowState(gMDI,true);

  RunAFX('ERe.Ekk.AusZuordnung','');
 
  if (gSelected<>0) then begin
    // Feldübernahme
    RecRead(555,0,_RecId,gSelected);
    gSelected # 0;

    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile=555) then vX # vX + 1;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

    if (Set.Installname='BSC') then
      vPos # 1;

    // markierte Sätze übernehmen?
    if (vX>0) then begin
      if (Msg(555002,cnvai(vX),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
        WHILE (vPos=0) do begin
          if (Dlg_standard:Anzahl(Translate('zu Rechnungsposition'),var vPos)=false) then BREAK;
          if (vPos<1) or (vPos>999) then begin
            Msg(555005,'',0,0,0);
            vPos # 0;
          end;
        END;

        APPOFF();        // ST 2014-07-01 Projekt 1423/22

        if (vPos<>0) then begin
          vItem # gMarkList->CteRead(_CteFirst);
          WHILE (vItem > 0) do begin
            Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
            if (vMFile=555) then begin
              RecRead(555,0,_RecId, vMID);
              if (ERe_Data:EKK_Zuordnen(vPos)=false) then begin
                 APPON(); // ST 2014-07-01 Projekt 1423/22
                 Msg(555003,'',0,0,0);
              end;
            end;
            vItem # gMarkList->CteRead(_CteNext,vItem);
            Lib_Mark:MarkAdd(555,n);
          END;
        end;  // vPos<>0

        APPON();  // ST 2014-07-01 Projekt 1423/22
      end;

    end
    else begin

      vMID # RecInfo(555,_recId);
      WHILE (vPos=0) do begin
        if (Dlg_standard:Anzahl(Translate('zu Rechnungsposition'),var vPos)=false) then BREAK;
        if (vPos<1) or (vPos>999) then begin
          Msg(555005,'',0,0,0);
          vPos # 0;
        end;
      END;

      RecRead(555,0,_RecId,vMID);
      if (vPos<>0) then
        if (ERe_Data:EKK_Zuordnen(vPos)=false) then Msg(555003,'',0,0,0);
    end;
  end;  // selected

  cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  cZList->WinFocusSet(false);
  // Focus auf Editfeld setzen:
//  $edxxx.xxxxx->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
end
begin
  
  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('NewX');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (Mode<>c_ModeView)) or (gZLList->wpDbLinkFileNo=0) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);
  vHdl # gMenu->WinSearch('Mnu.NewX');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (Mode<>c_ModeView)) or (gZLList->wpDbLinkFileNo=0) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EKK_Aendern]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EKK_Aendern]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EKK_Loeschen]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EKK_Loeschen]=n) or (ERe.InOrdnung) or (ERe.NichtInOrdnung);

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
  vQ      : alpha(4000);
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of
  
    'Mnu.NewX' : begin
      ZurEKK();
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
local begin
  vQ      : alpha(4000);
end;
begin

  if (aEvt:Obj->wpName='NewX') then begin
    ZurEKK();
//    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//    gZLList->WinFocusSet(true);
    RETURN true;
  end;


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

  // Sonderfunktion:
  if (aMark) then begin
    if (RunAFX('Ere.Ekk.EvtLstDataInit','y')<0) then RETURN;
  end
  else begin
    if (RunAFX('Ere.Ekk.EvtLstDataInit','n')<0) then RETURN;
  end;  
  
  case EKK.Datei of
    501 : GV.Alpha.01 # 'EK';
    505 : GV.Alpha.01 # 'Rück';
    506 : GV.Alpha.01 # 'WE';
    otherwise
      GV.Alpha.01 # '';
  end;

  if (EKK.ID1<>0) then GV.Alpha.01 # GV.Alpha.01 + AInt(EKK.ID1);
  if (EKK.ID2<>0) then GV.Alpha.01 # GV.Alpha.01 + '/' + AInt(EKK.ID2);
  if (EKK.ID3<>0) then GV.Alpha.01 # GV.Alpha.01 + '/' + AInt(EKK.ID3);
  if (EKK.ID4<>0) then GV.Alpha.01 # GV.Alpha.01 + '/' + AInt(EKK.ID4);

  GV.ALpha.02 # '';
  GV.ALpha.03 # '';
  if (EKK.Materialnummer <> 0) then begin
    Mat_Data:REad(EKK.Materialnummer);
    Gv.ALpha.02 # Mat.Chargennummer;
    GV.Alpha.03 # Mat.Werksnummer;
  end;
  
  

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
//========================================================================
//========================================================================
//========================================================================