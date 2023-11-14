@A+
//==== Business-Control ==================================================
//
//  Prozedur    EKK_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  05.12.2011  TM  RefreshMode: Löschbutton und -menüeintrag dauerhaft deaktiviert
//  13.04.2012  AI  BUG: beim Filter auf gelöschten Einträgen - Projekt 1326/217
//  25.06.2013  AH  Neu: EKK.Zuordnung.Datum
//  22.06.2015  AH  RecList: Artikelstichwort
//  22.03.2016  AH  Menü "Verwiegungen"
//  07.04.2017  AH  AFX; "EKK.Init.Pre","EKK.EvtLstDataInit"
//  16.08.2017  AH  Neu: Löschen/Entlöschen
//  21.02.2022  AH  ERX, "Mnu.MatAktionen"
//  2023-01-24  AH  Ent-/Löschen von Rückstellugen toggelt die Mat-Aktions-Kosten
//  2023-03-17  AH  Kalkulationen HWN
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
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
@I:Def_aktionen

define begin
  cTitle :    'Einkaufskontrolle'
  cFile :     555
  cMenuName : 'EKK.Bearbeiten'
  cPrefix :   'EKK'
  cZList :    $ZL.EKK
  cKey :      1
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vQ    : alpha(1000);
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

/*** passiert noch in der APP_MAin
  gMDI # aevt:obj;
  gMDI->wpcustom # cnvai(VarInfo(WindowBonus));
  Filter_EKK # y;
  vQ # '';
  Lib_Sel:QInt( var vQ, 'EKK.EingangsreNr', '=', 0);
  Lib_Sel:QRecList(0,vQ);
***/
  RunAFX('EKK.Init.Pre',aint(aEvt:Obj));

  RETURN App_Main:EvtInit(aEvt);
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
  $Mnu.Filter.Geloescht->wpMenuCheck # Filter_EKK;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vTmp  : int;
end;
begin
  vTmp # Winsearch(gMenu, 'Mnu.MatAktionen');
  if (vTmp<>0) then vTmp->wpdisabled # false;

  // 2023-01-24 AH
  if (w_Auswahlmode) then begin
    vTmp # Winsearch(gMenu, 'Mnu.Filter.Lieferant');
    vTmp->wpdisabled # false;
  end;

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
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  if (w_Auswahlmode) then begin
    RETURN;
/*** k.A. ???
    Mode # c_ModeList;
    Lib_GuiCom:SetMaskState(false);
    vHdl # gMdi->winsearch('NB.List');
    vHdl->wpdisabled # false;
    vHdl # gMdi->winsearch('NB.Main');
    vHdl->wpCurrent # 'NB.List';

    RecBufClear(555);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'EKK.Verwaltung',here+':AusZuordnung');
      Lib_GuiCom:RunChildWindow(gMDI);
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    gZLList->WinFocusSet(true);
***/
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
  Erx     : int;
  vDatei  : int;
end;
begin

  if (w_Auswahlmode) then begin
    if (Msg(555001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      EKK_Data:Aufheben();
    end;

    cZList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
    RETURN;
  end;

//    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
//      RekDelete(gFile,0,'MAN');
//    end;

  // 16.08.2017 AH:
  if (EKK.Eingangsrenr=0) then begin
    if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

      TRANSON;

      RecRead(555,1,_recLock);
      EKK.EingangsReNr    # -1;
      EKK.Zuordnung.Datum # today;
      EKK.Zuordnung.Zeit  # now;
      EKK.Zuordnung.User  # gUsername;
      Erx # RekReplace(555);
      if (erx<>_rOK) then begin
        if (Erx<>_rDeadLock) then TRANSBRK;
        RETURN;
      end;

      // 2023-01-24 AH
      if ((EKK.Datei=505) and (EKK.Materialnummer<>0)) then begin
        Mat.A.Materialnr  # EKK.Materialnummer;
        Mat.A.Aktionstyp  # c_Akt_Kalk;
        Mat.A.Aktionsnr   # EKK.ID1;
        Mat.A.Aktionspos  # EKK.ID2;
        Mat.A.Aktionspos2 # EKK.ID3;
        Mat.A.Aktionspos3 # EKK.ID4;
        Erx # RecRead(204,4,0);
        if (Erx<=_rMultikey) then begin
          vDatei # Mat_Data:Read(Mat.A.Materialnr);
          if (vDatei<200) then begin
            TRANSBRK;
            RETURN;
          end;

          RecRead(204,1,_recLock);
// 2023-03-17 AH
//          Mat.A.KostenW1        # 0.0;
//          Mat.A.KostenW1promeh  # 0.0;
          Mat.EK.Preis            # Mat.EK.Preis            - Mat.A.Kosten2W1;
          Mat.EK.PreisProMEH      # Mat.EK.PreisProMEH      - Mat.A.Kosten2W1ProME;
          Mat.A.Kosten2W1         # 0.0;
          Mat.A.Kosten2W1prome    # 0.0;
          Erx # RekReplace(204);
          if (erx<>_rOK) then begin
            if (Erx<>_rDeadLock) then TRANSBRK;
            RETURN;
          end;
          if (Mat_Data:SetUndVererbeEkPreis(vDatei, EKK.Datum, Mat.EK.Preis, Mat.EK.PreisProMEH, Mat.MEH, 0)=false) then begin
            TRANSBRK;
            RETURN;
          end;
          
/*
          Erx # RecLink(200,204,1,_recFirst);   // Material holen
          if (Erx<=_rLocked) then begin
            if (Mat_A_Data:Vererben()) then begin
            end
          end;
          else begin
            Erx # RecLink(210,204,4,_recFirst);   // Material holen
            if (Erx<=_rLocked) then begin
              RecbufCopy(210,200);
              if (Mat_A_Abl_Data:Abl_Vererben()) then begin
              end
            end;
          end;
*/
        end;
      end;
      TRANSOFF;
      
    end;
    RETURN;
  end;
  if (EKK.Eingangsrenr=-1) then begin
    if (Msg(000007,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      RecRead(555,1,_recLock);
      EKK.EingangsReNr    # 0;
      EKK.Zuordnung.Datum # 0.0.0;
      EKK.Zuordnung.Zeit  # 0:0;
      EKK.Zuordnung.User  # '';
      RekReplace(555);

      // 2023-01-24 AH
      if ((EKK.Datei=505) and (EKK.Materialnummer<>0)) then begin
        Mat.A.Materialnr  # EKK.Materialnummer;
        Mat.A.Aktionstyp  # c_Akt_Kalk;
        Mat.A.Aktionsnr   # EKK.ID1;
        Mat.A.Aktionspos  # EKK.ID2;
        Mat.A.Aktionspos2 # EKK.ID3;
        Mat.A.Aktionspos3 # EKK.ID4;
        Erx # RecRead(204,4,0);
        if (Erx<=_rMultikey) then begin
          RecRead(204,1,_recLock);
          DivOrNull(Mat.A.KostenW1, EKK.PreisW1*1000.0, EKK.Gewicht, 2);
          Mat.A.KostenW1promeh  # 0.0;
          RekReplace(204);
          Erx # RecLink(200,204,1,_recFirst);   // Material holen
          if (Erx<=_rLocked) then begin
            if (Mat_A_Data:Vererben()) then begin
            end
          end;
          else begin
            Erx # RecLink(210,204,4,_recFirst);   // Material holen
            if (Erx<=_rLocked) then begin
              RecbufCopy(210,200);
              if (Mat_A_Abl_Data:Abl_Vererben()) then begin
              end
            end;
          end;
        end;
      end;

    end;
    RETURN;
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
  vParent : int;
  vA      : alpha;
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
  //  cZList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  //  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected<>0) then begin
    // Feldübernahme
    RecRead(555,0,_RecId | _RecLock ,gSelected);
    gSelected # 0;

    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile=555) then vX # vX + 1;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

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

        if (vPos<>0) then begin
          vItem # gMarkList->CteRead(_CteFirst);
          WHILE (vItem > 0) do begin
            Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
            if (vMFile=555) then begin
              RecRead(555,0,_RecId, vMID);
              if (ERe_Data:EKK_Zuordnen(vPos)=false) then Msg(555003,'',0,0,0);
            end;
            vItem # gMarkList->CteRead(_CteNext,vItem);
          END;
        end;  // vPos<>0
      end;
      end
    else begin
      WHILE (vPos=0) do begin
        if (Dlg_standard:Anzahl(Translate('zu Rechnungsposition'),var vPos)=false) then BREAK;
        if (vPos<1) or (vPos>999) then begin
          Msg(555005,'',0,0,0);
          vPos # 0;
        end;
      END;
      if (vPos<>0) then
        if (ERe_Data:EKK_Zuordnen(vPos)=false) then Msg(555003,'',0,0,0);
    end;

  end;  // selected

  cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  cZList->WinFocusSet(false);

  Lib_Mark:Reset(555);

  // Focus auf Editfeld setzen:
  //  $edxxx.xxxxx->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusMatZuordnung
//
//========================================================================
sub AusMatZuordnung()
local begin
  vX      : int;
  vItem   : int;
  vMode   : alpha;
  vMFile  : int;
  vMID    : int;
end;
begin

  if (gSelected<>0) then begin
    // Feldübernahme
    RecRead(200,0,_RecId | _RecLock ,gSelected);
    gSelected # 0;

    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile=200) then vX # vX + 1;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

    // markierte Sätze übernehmen?
    if (vX>0) then begin
      if (Msg(555002,cnvai(vX),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

        FOR vItem # gMarkList->CteRead(_CteFirst)
        LOOP vItem # gMarkList->CteRead(_CteNext, vItem)
        WHILE (vItem > 0) do begin
          Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
          if (vMFile=200) then begin
            RecRead(200,0,_RecId, vMID);
            EKK_Data:EKK_Aktion(Mat.Nummer);
          end;
        END;
      end;
    end
    else begin
      EKK_Data:EKK_Aktion(Mat.Nummer);
    end;

  end;  // selected

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  gZLList->WinFocusSet(false);

  Lib_Mark:Reset(200);
end;


//========================================================================
//  AusMatAblZurodnung
//
//========================================================================
sub AusMatAblZuordnung()
local begin
  vX      : int;
  vItem   : int;
  vMode   : alpha;
  vMFile  : int;
  vMID    : int;
end;
begin

  if (gSelected<>0) then begin
    // Feldübernahme
    RecRead(210,0,_RecId | _RecLock ,gSelected);
    gSelected # 0;

    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile=210) then vX # vX + 1;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

    // markierte Sätze übernehmen?
    if (vX>0) then begin
      if (Msg(555002,cnvai(vX),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

        FOR vItem # gMarkList->CteRead(_CteFirst)
        LOOP vItem # gMarkList->CteRead(_CteNext, vItem)
        WHILE (vItem > 0) do begin
          Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
          if (vMFile=210) then begin
            RecRead(210,0,_RecId, vMID);
            EKK_Data:EKK_Aktion("Mat~Nummer");
          end;
        END;
      end;
    end
    else begin
      EKK_Data:EKK_Aktion("Mat~Nummer");
    end;

  end;  // selected

  cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  cZList->WinFocusSet(false);

  Lib_Mark:Reset(210);

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

  vHdl # gMdi->WinSearch('NewX');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (Mode<>c_ModeView)) or (gZLList->wpDbLinkFileNo=0);
  vHdl # gMenu->WinSearch('Mnu.NewX');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_ModeList) and (Mode<>c_ModeView)) or (gZLList->wpDbLinkFileNo=0);;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EKK_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EKK_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    // vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EKK_Loeschen]=n);
    vHdl->wpDisabled # true;

  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_EKK_Loeschen]=n);
//    vHdl->wpDisabled # true;


  vHdl # gMenu->WinSearch('Mnu.Verwiegungen');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_BAG_FM]=false) or (EKK.Datei<>702));

  vHdl # gMenu->WinSearch('Mnu.Mark.WirdERe');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
    ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_ERe]=false));

  RefreshIfm();

end;


//========================================================================
//  MatAktionen
//========================================================================
sub MatAktionen()
begin
  If (Msg(210004,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then begin
    RecBufClear(210);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Ablage',here+':AusMatAblZuordnung',n);
  end
  else begin
    RecBufClear(200);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMatZuordnung',n);
  end;
  Lib_GuiCom:RunChildWindow(gMDI);
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
  Erx     : int;
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vQ      : alpha(4000);
  vTmp    : int;
  vRef    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of
  
    'Mnu.Filter.Lieferant' : begin
      if (gZLList->wpDbSelection=0) then RETURN true;
      gZLList->wpAutoUpdate # false;
      vHdl # gZLList->wpdbselection;
      gZLList->wpDbSelection # 0;
      SelClose(vHdl);
      SelDelete(gFile,w_selName);
      w_SelName # '';
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

    end;


    'Mnu.MatAktionen' : begin
      MatAktionen();
    end;


    'Mnu.Mark.WirdERe' : begin
      EKK_Data:Mark2Ere();
    end;


   'Mnu.Verwiegungen' :  begin
    if (EKK.Datei=702) then begin
      BAG.P.Nummer    # EKK.ID1;
      BAG.P.Position  # EKK.ID2;
      Erx # RecRead(702,1,0);     // BA-Position holen
      if (Erx<=_rLocked) then begin
        BA1_FM_Main:Start(BAG.F.Nummer, BAG.F.Position, 0, 0, '', true);
      end;
     end;
   end;


   'Mnu.Mark.Sel' : begin
      EKK_Mark_Sel();
    end;


    'Mnu.Filter.Geloescht' : begin
      Filter_EKK # !(Filter_EKK);
      $Mnu.Filter.Geloescht->wpMenuCheck # Filter_EKK;

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
      Lib_Sel:QInt( var vQ, 'EKK.EingangsreNr', '=', 0);
      Lib_Sel:QRecList(0,vQ);

      // 13.4.2012 AI: Projekt 1326/217
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      App_Main:Refreshmode();
      RETURN true;
    end;


    'Mnu.SumMarkiert' : begin
      Msg(555004,CnvAF(EKK_Data:SumMarkiert())+' '+"Set.Hauswährung.Kurz",0,0,0);
    end;


    'Mnu.NewX' : begin
      RecBufClear(555);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'EKK.Verwaltung',here+':AusZuordnung',n);
      Lib_GuiCom:RunChildWindow(gMDI);
//      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      gZLList->WinFocusSet(true);
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

  if (aEvt:Obj->wpName='NewX') then begin
  //RETURN App_Main:EvtClicked(aEvt);
    RecBufClear(555);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'EKK.Verwaltung','EKK_Main:AusZuordnung',n);
    Lib_GuiCom:RunChildWindow(gMDI);
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    gZLList->WinFocusSet(true);
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
local begin
  Erx : int;
end;
begin

  // Ankerfunktion:
  if (aMark) then begin
    if (RunAFX('EKK.EvtLstDataInit','y')<0) then RETURN;
  end
  else begin
    if (RunAFX('EKK.EvtLstDataInit','n')<0) then RETURN;
  end;

  case EKK.Datei of
    204 : GV.Alpha.01 # 'MatAkt ';
    501 : GV.Alpha.01 # 'EK ';
    505 : GV.Alpha.01 # 'Rück ';
    506 : GV.Alpha.01 # 'WE ';
    702 : GV.Alpha.01 # 'Lohn ';
    406 : GV.Alpha.01 # 'VK-Rück ';
    450 : GV.Alpha.01 # 'Re-Rück ';
    otherwise
      GV.Alpha.01 # '??? ';
  end;

  if (EKK.ID1<>0) then GV.Alpha.01 # GV.Alpha.01 + AInt(EKK.ID1);
  if (EKK.ID2<>0) then GV.Alpha.01 # GV.Alpha.01 + '/' + AInt(EKK.ID2);
  if (EKK.ID3<>0) then GV.Alpha.01 # GV.Alpha.01 + '/' + AInt(EKK.ID3);
  if (EKK.ID4<>0) then GV.Alpha.01 # GV.Alpha.01 + '/' + AInt(EKK.ID4);

  if (aMark=n) then begin
    if ("EKK.Eingangsrenr"<>0) then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
  end;

  Art.Stichwort # '';
  if (EKK.Artikelnummer<>'') then RekLink(250,555,11,_recFirst);  // Artikel holen


  GV.Alpha.02 # '';
  GV.Alpha.03 # '';
  if (EKK.Datei=506) then begin
    Erx # Ein_Data:Read(EKK.Id1,EKK.Id2,y);
    if (Erx>=500) then begin
      Erx # RecLink(814,500,8,0);  // Währung holen
      if (Erx<=_rLocked) then begin
        GV.Alpha.02 # anum(Ein.P.Grundpreis,2)+' '+"Wae.Kürzel";
        GV.Alpha.03 # aint(Ein.P.PEH)+' '+Ein.P.MEH;
      end;
    end;
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