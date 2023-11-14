@A+
//==== Business-Control ==================================================
//
//  Prozedur    Scr_B_Main
//                  OHNE E_R_G
//  Info
//
//
//  18.07.2007  AI  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
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
//    SUB AusFormular()
//    SUB AusEmpfaenger1()
//    SUB AusEmpfaenger2()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Scriptbefehle'
  cFile       :  921
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : 'Scr_B'
  cZList      : $ZL.Scr.Befehle
  cKey        : 1

  ADD(a) : GV.Alpha.01 # GV.Alpha.01 + ' ' + a
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

Lib_Guicom2:Underline($edScr.B.2.FormName);
Lib_Guicom2:Underline($edScr.B.2.FixID1);
Lib_Guicom2:Underline($edScr.B.2.FixID2);


  SetStdAusFeld('edScr.B.2.Bereich'   ,'Formular');
  SetStdAusFeld('edScr.B.2.FormName'  ,'Formular');
  SetStdAusFeld('edScr.B.2.Drucker'   ,'Drucker');
  SetStdAusFeld('edScr.B.2.Schacht'   ,'Schacht');
  SetStdAusFeld('edScr.B.2.FixID1'    ,'Empfaenger1');
  SetStdAusFeld('edScr.B.2.FixID2'    ,'Empfaenger2');



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
  //Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  Erx   : int;
  vA    : alpha;
  vTmp  : int;
end;
begin
  if (Scr.B.2.FixID1<>0) and
    ((Scr.B.2.anKuLFYN) or (Scr.B.2.anVerbrauYN) or (Scr.B.2.anReEmpfYN) or (Scr.B.2.anLiefAdrYN)) then begin
    Erx # RecLink(100,921,1,_recFirst); // Adresse holen
    if (Erx<=_rLocked) then vA # Adr.Stichwort;
  end
  else if (Scr.B.2.anPartnerYN) then begin
    Erx # RecLink(102,921,3,_recFirst); // Ansprechpartner holen
    if (Erx<=_rLocked) then vA # Adr.P.Stichwort;
  end
  else if (Scr.B.2.anLiefAnsYN) or (Scr.B.2.anLagerortYN) then begin
    Erx # RecLink(101,921,2,_recFirst); // Anschrift holen
    if (Erx<=_rLocked) then vA # Adr.A.Stichwort;
  end
  else if (Scr.B.2.anVertretYN) or (Scr.B.2.anVerbandYN) then begin
    Erx # RecLink(110,921,4,_recFirst); // Vertreter holen
    if (Erx<=_rLocked) then vA # Ver.Stichwort;
  end;
  $Lb.Stichwort->wpcaption # vA;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
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
  $edScr.B.lfdNr->WinFocusSet(true);
  if (Mode=c_ModeNew) then begin
    Scr.B.Nummer  # Scr.Nummer;
    Scr.B.Befehl  # 'PRINT';
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
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
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
  Erx   : int;
  vA    : alpha;
  vQ    : alpha;
  vHdl  : int;
end;

begin

  case aBereich of

    'Formular' : begin
      RecBufClear(912);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Frm.Verwaltung',here+':AusFormular');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Drucker' : begin
      vA # Prg_Para_Main:ParaAuswahl('Drucker','','');
      if (vA<>'') then Scr.B.2.Drucker # vA;
      $edScr.B.2.Drucker->WinFocusSet();
      gMdi->WinUpdate();
    end;

    'Schacht' : begin
      vHdl # PrtDeviceOpen(Scr.B.2.Drucker,_PrtDeviceSystem);
      if (vHdl<>0) then begin
        vA # Prg_Para_Main:ParaAuswahl('Schächte','','',vHdl);
        if (vA<>'') then Scr.B.2.Schacht # vA;
        $edScr.B.2.Schacht->WinFocusSet();
        gMdi->WinUpdate();
      end;
    end;

    'Empfaenger1' : begin
      if (Scr.B.2.anKuLFYN) or (Scr.B.2.anPartnerYN) or
        (Scr.B.2.anVerbrauYN) or (Scr.B.2.anReEmpfYN) or (Scr.B.2.anLiefAnsYN) or
        (Scr.B.2.anLagerortYN) or (Scr.B.2.anLiefAdrYN) then begin
        RecBufClear(100);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Verwaltung',here+':AusEmpfaenger1');
        Lib_GuiCom:RunChildWindow(gMDI);
        end
      else if (Scr.B.2.anVertretYN) or (Scr.B.2.anVerbandYN) then begin
        RecBufClear(110);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ver.Verwaltung',here+':AusEmpfaenger1');
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;


    'Empfaenger2' : begin
      if (Scr.B.2.anPartnerYN) and (Scr.B.2.FixID1<>0) then begin
        RecBufClear(102);         // ZIELBUFFER LEEREN
        RecLink(100,921,1,0);     // Adresse holen
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.P.Verwaltung',here+':AusEmpfaenger2');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        gZLList->wpdbfileno     # 100;
        gZLList->wpdbkeyno      # 13;
        gZLList->wpdbLinkFileNo # 102;
        // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
        gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
        Lib_GuiCom:RunChildWindow(gMDI);
        end
      else if ((Scr.B.2.anLiefAnsYN) or (Scr.B.2.anLagerortYN)) and
        (Scr.B.2.FixID1<>0) then begin
        RecLink(100,921,1,0);     // Adresse holen
        RecBufClear(101);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusEmpfaenger2');

        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

        vQ # '';
        Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
        vHdl # SelCreate(101, 1);
        Erx # vHdl->SelDefQuery('', vQ);
        if (Erx <> 0) then
          Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;

        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;

  end;

end;


//========================================================================
//  AusFormular
//
//========================================================================
sub AusFormular()
begin
  if (gSelected<>0) then begin
    RecRead(912,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Scr.B.2.Bereich   # Frm.Bereich;
    Scr.B.2.FormName  # Frm.Name;
    $edScr.B.2.Bereich->winupdate(_WinUpdFld2Obj);
    $edScr.B.2.FormName->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edScr.B.2.Bereich->Winfocusset(false);
end;


//========================================================================
//  AusEmpfaenger1
//
//========================================================================
sub AusEmpfaenger1()
begin
  if (gSelected<>0) then begin
    if (Scr.B.2.anVertretYN) or (Scr.B.2.anVerbandYN) then begin
      RecRead(110,0,_RecId,gSelected);
      gSelected # 0;
      // Feldübernahme
      Scr.B.2.FixID1  # Ver.Nummer;
      end
    else begin
      RecRead(100,0,_RecId,gSelected);
      gSelected # 0;
      // Feldübernahme
      Scr.B.2.FixID1  # Adr.Nummer;
    end;
  end;
  Scr.B.2.FixID2  # 0;
  $edScr.B.2.FixID2->winupdate(_WinUpdFld2Obj);

  // Focus auf Editfeld setzen:
  $edScr.B.2.FixID1->Winfocusset(false);
end;


//========================================================================
//  AusEmpfaenger2
//
//========================================================================
sub AusEmpfaenger2()
begin
  if (gSelected<>0) then begin

    if ((Scr.B.2.anLiefAnsYN) or (Scr.B.2.anLagerortYN)) then begin
      RecRead(101,0,_RecId,gSelected);
      gSelected # 0;
      // Feldübernahme
      Scr.B.2.FixID1  # Adr.A.AdressNr;
      Scr.B.2.FixID2  # Adr.A.Nummer;
      end
    else begin
      RecRead(102,0,_RecId,gSelected);
      gSelected # 0;
      // Feldübernahme
      Scr.B.2.FixID1  # Adr.P.AdressNr;
      Scr.B.2.FixID2  # Adr.P.Nummer;
    end;
  end;
  $edScr.B.2.FixID1->winupdate(_WinUpdFld2Obj);

  // Focus auf Editfeld setzen:
  $edScr.B.2.FixID2->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled);

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
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);//,xxx.Anlage.Datum, xxx.Anlage.Zeit, xxx.Anlage.User);
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
    'bt.Formular'   :   Auswahl('Formular');
    'bt.Drucker'    :   Auswahl('Drucker');
    'bt.Schacht'    :   Auswahl('Schacht');
    'bt.Empfaenger1' :  Auswahl('Empfaenger1');
    'bt.Empfaenger2' :  Auswahl('Empfaenger2');
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

  if (aEvt:Obj->wpCheckState=_WinStateChkChecked) then begin
    Scr.B.2.anKuLfYN      # n;
    Scr.B.2.anPartnerYN   # n;
    Scr.B.2.anLiefAdrYN   # n;
    Scr.B.2.anLiefAnsYN   # n;
    Scr.B.2.anVerbrauYN   # n;
    Scr.B.2.anReEmpfYN    # n;
    Scr.B.2.anVertretYN   # n;
    Scr.B.2.anVerbandYN   # n;
    Scr.B.2.anLagerortYN  # n;
    aEvt:Obj->winupdate(_WinUpdObj2Fld);
  end;
  Scr.B.2.FixID1 # 0;
  Scr.B.2.FixID2 # 0;
  $cbScr.B.2.anKuLfYN->winupdate(_WinUpdFld2Obj);
  $cbScr.B.2.anPartnerYN->winupdate(_WinUpdFld2Obj);
  $cbScr.B.2.anLiefAdrYN->winupdate(_WinUpdFld2Obj);
  $cbScr.B.2.anLiefAnsYN->winupdate(_WinUpdFld2Obj);
  $cbScr.B.2.anVerbrauYN->winupdate(_WinUpdFld2Obj);
  $cbScr.B.2.anReEmpfYN->winupdate(_WinUpdFld2Obj);
  $cbScr.B.2.anVertretYN->winupdate(_WinUpdFld2Obj);
  $cbScr.B.2.anVerbandYN->winupdate(_WinUpdFld2Obj);
  $cbScr.B.2.anLagerortYN->winupdate(_WinUpdFld2Obj);

  $edScr.B.2.FixID1->winupdate(_WinUpdFld2Obj);
  $edScr.B.2.FixID2->winupdate(_WinUpdFld2Obj);

  RETURN true;
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
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
begin
  GV.Alpha.01 # '';

  if (Scr.B.Befehl='CALL') then begin
    Add('Prozedurstart');
    Add(Scr.B.Prozedurname);
  end;

  if (Scr.B.Befehl='PRINT') then begin
    if (Scr.B.2.Ausgabeart='P') then Add('DRUCKE');
    else if (Scr.B.2.Ausgabeart='F') then Add('FAXE');
    else if (Scr.B.2.Ausgabeart='E') then Add('EMAIL');
    else Add('AUSGABE');

    Add(AInt(Scr.B.2.Bereich)+'/'+Scr.B.2.FormName);
    Add(AInt(Scr.B.2.Kopien)+'x');
    Add('an');
    if (Scr.B.2.anKuLfYN) then      Add('Ku/Lf');
    if (Scr.B.2.anPartnerYN) then   Add('Ansprechp.');
    if (Scr.B.2.anLiefAdrYN) then   Add('LiefAdr.');
    if (Scr.B.2.anLiefAnsYN) then   Add('LiefAns.');
    if (Scr.B.2.anVerbrauYN) then   Add('Verbr.');
    if (Scr.B.2.anReEmpfYN) then    Add('ReEmpf.');
    if (Scr.B.2.anVertretYN) then   Add('Vertr.');
    if (Scr.B.2.anVerbandYN) then   Add('Verband');
    if (Scr.B.2.anLagerortYN) then  Add('Lagerort');

    if (Scr.B.2.FixID1<>0) then     Add('(fest)');

    if (Scr.B.2.Markierung<>'') then Add('als '+Scr.B.2.Markierung);
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

  if ((aName =^ 'edScr.B.2.FormName') AND (aBuf->Scr.B.2.FormName<>'')) then begin
    todo('Formular')
    //RekLink(819,200,1,0);   // formuler holen
    Lib_Guicom2:JumpToWindow('Frm.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edScr.B.2.FixID1') AND (aBuf->Scr.B.2.FixID1<>0)) then begin
    todo('Empfaenger1' )
    //RekLink(819,200,1,0);   // fester Empf. holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edScr.B.2.FixID2') AND (aBuf->Scr.B.2.FixID2<>0)) then begin
    todo('Empfaenger2')
    //RekLink(819,200,1,0);   // fester Empf. holen
    Lib_Guicom2:JumpToWindow('Adr.P.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
