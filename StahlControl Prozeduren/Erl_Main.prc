@A+
//==== Business-Control ==================================================
//
//  Prozedur    Erl_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  13.06.2012  MS  Erweiterung um Mnu.DMS
//  11.09.2013  ST  Erweiterung um SammelGelangensbestätigung (1427/49)
//  15.10.2014  TM  Korrektur zum Druck Storno Bonusgutschrift / wurde noch nicht berücksichtigt
//  06.07.2015  AH  Bugfix: Nachdruck Rechnung wollte immer Sammelrechnung drucken
//  17.09.2015  ST  Erweiterung "Sub Start"
//  08.07.2016  AH  "JumpTo"
//  11.06.2018  ST  EvtLstDataInit: Umstellung Graufärbung auf Stornorechnungsnr, gegen Bug in Mehrsprachsystemen
//  27.10.2020  AH  Projektnr.
//  11.11.2021  MR  Erweiterung um Anker Erl.Init.Pre
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB JumpTo(aName : alpha; aBuf  : int);
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Erlöse'
  cFile       : 450
  cMenuName   : 'Erl.Bearbeiten'
  cPrefix     : 'Erl'
  cZList      : $ZL.Erloese
  cKey        : 1
  cDialog     : 'Erl.Verwaltung'
  cRecht      : Rgt_Erloese
  cMdiVar     : gMDIErl
end;


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aReNr    : int;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end;
begin
  if (aRecId=0) and (aReNr<>0) then begin
    Erl.Rechnungsnr # aReNr;
    Erx # RecRead(450,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(450,_recID);
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

  if (Set.Installname='BSP') then begin
    $lbErl.CO2Einstand->wpvisible # true;
    $edErl.CO2Einstand->wpvisible # true;
    $lbCO2->wpvisible # true;
    $lbErl.CO2Zuwachs->wpvisible # true;
    $edErl.CO2Zuwachs->wpvisible # true;
    $lbCO2_2->wpvisible # true;
  end;
  RunAFX('Erl.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;
  // Pflichtfelder
  //Lib_GuiCom:Pflichtfeld($);
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
  vBuf100 : int;
  vTmp    : int;
end;
begin

  if (aName='') then begin

    Erx # RecLink(853,450,12,_RecFirst);    // Rechnungstyp holen
    if (Erx<=_rLocked) then
      $lb.Rechnungstyp->wpcaption # RTy.Bezeichnung
    else
      $lb.Rechnungstyp->wpcaption # '???';


    $Lb.HW1->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW2->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW3->wpCaption # "Set.Hauswährung.Kurz";
    $Lb.HW4->wpCaption # "Set.Hauswährung.Kurz";

    Erx # RecLink(814,450,3,0); // Währung holen
    if (Erx<=_rLocked) and ("Erl.Währung"<>0) then
      $Lb.Wae->wpcaption # "Wae.Kürzel"
    else
      $Lb.Wae->wpcaption # "Wae.Kürzel";
    $Lb.Wae1->wpCaption # $Lb.Wae->wpcaption;
    $Lb.Wae2->wpCaption # $Lb.Wae->wpcaption;
    $Lb.Wae3->wpCaption # $Lb.Wae->wpcaption;
    $Lb.Wae4->wpCaption # $Lb.Wae->wpcaption;


    vBuf100 # RekSave(100);
    Erx # RecLink(100,450,5,0); // Kunde holen
    if (Erx<=_rLocked) and (Erl.Kundennummer<>0) then begin
      $Lb.Kunde->wpcaption# Adr.Stichwort;
      $Lb.KuName->wpcaption     # Adr.Name;
      $Lb.KuStrasse->wpcaption  # "Adr.Straße";
      $Lb.KuOrt->wpcaption      # Adr.Ort;
      $Lb.KuTelefon->wpcaption  # Adr.Telefon1;
      $Lb.KuRefNr->wpcaption    # Adr.VK.Referenznr;
    end
    else begin
      $Lb.Kunde->wpcaption# '';
      $Lb.KUName->wpcaption     # '';
      $Lb.KuStrasse->wpcaption  # '';
      $Lb.KuOrt->wpcaption      # '';
      $Lb.KuTelefon->wpcaption  # '';
      $Lb.KuRefNr->wpcaption    # '';
    end;

    Erx # RecLink(100,450,8,0); // Rechnungsmepf. holen
    if (Erx<=_rLocked) and (Erl.Rechnungsempf<>0) then
      $lb.ReEmpf->wpcaption # Adr.Stichwort
    else
      $lb.ReEmpf->wpcaption # '';
    RekRestore(vBuf100);

    Erx # RecLink(110,450,6,0); // Verband holen
    if (Erx<=_rLocked) and (Erl.Verband<>0) then
      $lb.Verband->wpcaption # Ver.Stichwort
    else
      $lb.Verband->wpcaption # '';

    Erx # RecLink(110,450,7,0); // Vertreter holen
    if (Erx<=_rLocked) and (Erl.Vertreter<>0) then
      $lb.Vertreter->wpcaption # Ver.Stichwort
    else
      $lb.Vertreter->wpcaption # '';

    Erx # RecLink(120,450,16,0); // Projekt holen
    if (Erx<=_rLocked) and (Erl.Projektnr<>0) then
      $lb.Projekt->wpcaption # Prj.Stichwort
    else
      $lb.Projekt->wpcaption # '';
  end;


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
  $edErl.Kundennummer->WinFocusSet(true);
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
    Erl.Anlage.Datum  # Today;
    Erl.Anlage.Zeit   # Now;
    Erl.Anlage.User   # Userinfo(_Username,cnvia(userinfo(_UserCurrent)));
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
  vA    : alpha;
  vMode : alpha;
end;
begin
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

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (y);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (y);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (y);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (y);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (y);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (y);

  vHdl # gMenu->WinSearch('Mnu.Stornieren');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
                or (Rechte[Rgt_Erl_Stornieren]=n)
                or (Erl.StornoRechNr<>0);
  end;

  vHdl # gMenu->WinSearch('Mnu.Konten');
  if (vHdl <> 0) then
    vHdl->wpDisabled #  (Rechte[Rgt_ErloesKonten]=n);

  vHdl # gMenu->WinSearch('Mnu.Fibu');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # ((Mode<>c_ModeView) and (Mode<>c_ModeLisT))
                or (Rechte[Rgt_Erl_Fibu]=n);
  end;

  vHdl # gMenu->WinSearch('Mnu.Rechnung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Erl.Rechnungstyp<>c_Erl_VK) and
                      (Erl.Rechnungstyp<>c_Erl_BOGUT) and
                      (Erl.Rechnungstyp<>c_Erl_REKOR) and
                      (Erl.Rechnungstyp<>c_Erl_Bel_KD) and
                      (Erl.Rechnungstyp<>c_Erl_Gut) and
                      (Erl.Rechnungstyp<>c_Erl_Bel_LF) and
                      (Erl.Rechnungstyp<>c_Erl_SammelVK);
  vHdl # gMenu->WinSearch('Mnu.Stornorechnung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Erl.Rechnungstyp<>c_erl_StornoVK) and
                      (Erl.Rechnungstyp<>c_Erl_StornoBOGUT) and
                      (Erl.Rechnungstyp<>c_erl_StornoREKOR) and
                      (Erl.Rechnungstyp<>c_erl_StornoBEL_KD) and
                      (Erl.Rechnungstyp<>c_erl_StornoGUT) and
                      (Erl.Rechnungstyp<>c_erl_StornoBEL_LF);


  vHdl # gMenu->WinSearch('Mnu.OSt.Recalc');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_OSt_ReCalc]=false;


  vHdl # gMenu->WinSearch('Mnu.Abschlussdatum');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Erl_Abschlussdatum]=false;


  if (Mode<>c_ModeOther) and (aNoRefresh=n) then RefreshIfm();

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
  vFilter : int;
  vAbschl : date;
  vTmp    : int;
  vModule : alpha;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of
    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;

    'Mnu.DMS' : begin
      RecLink(100, 450, 8, _recFirst);   // Rechnungsempf holen
      DMS_ArcFlow:ShowAbm('RE', Erl.Rechnungsnr, Adr.Nummer);
    end;


    'Mnu.Mark.Sel' : begin
      Erl_Mark_Sel();
    end;


    'Mnu.OSt.Recalc' : begin
      if (Rechte[Rgt_OSt_ReCalc]) then begin
        if (Msg(899001,'',0,_WinDialogYesNo,2)<>_winIdYes) then RETURN true;
        if (Dlg_Standard:Datum(Translate('ab Datum'),var vAbschl)=false) then RETURN true;
        if (OsT_Data:Recalc(vAbschl)=true) then Msg(999998,'',0,0,0)
        else Msg(999999,'',0,0,0);
      end;
    end;


    'Mnu.OSt' : begin
      if (Rechte[Rgt_OSt_Unternehmen]=n) then begin
        Msg(890000,'',0,0,0);
        RETURN true;
      end;
      Lib_COM:DisplayOSt( 'UNTERNEHMEN', -1, 'Unternehmen', true ); // mit Fixkostenausgabe
    end;


    'Mnu.Stornorechnung' : begin
      if (Erl.Rechnungstyp=c_Erl_StornoVK) or
      (Erl.Rechnungstyp=c_Erl_StornoREKOR) or
      (Erl.Rechnungstyp=c_Erl_StornoBOGUT) or // hinzugefügt 15.10.2014 TM
      (Erl.Rechnungstyp=c_Erl_StornoBEL_KD) or
      (Erl.Rechnungstyp=c_Erl_StornoGUT) or
      (Erl.Rechnungstyp=c_Erl_StornoBEL_LF) then begin
        RecLink(100,450,5,_recFirst);   // Kunde holen
        Lib_Dokumente:Printform(450,'Stornorechnung',true);
      end;
    end;


    'Mnu.Rechnung' : begin

      //if (gUsername='AH') then begin
      if (gUsergroup='PROGRAMMIERER') then begin
        if (Msg(912001,'',0,_WinDialogYesNo,2)=_WinIDno) then begin
          if (RecLink(404,450,4,_recFirst)<=_rLocked) then begin
            if (Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, y)>=401) then begin
              if (Erl.Rechnungstyp=c_Erl_StornoVK) or
                  (Erl.Rechnungstyp=c_Erl_StornorEKOR) or
                  (Erl.Rechnungstyp=c_Erl_StornoBEL_KD) or
                  (Erl.Rechnungstyp=c_Erl_StornoBOGUT) or // hinzugefügt 15.10.2014 TM
                  (Erl.Rechnungstyp=c_Erl_StornoGUT) or
                  (Erl.Rechnungstyp=c_Erl_StornoBEL_LF) then begin
              end
              else begin
                Erx # RecLink(460,450,2,_recFirst);   // OP holen
                if (Erx>_rLocked) then begin
                  Erx # RecLink(470,450,11,_recFirst);   // OP_Ablage holen
                  RecBufCopy(470,460);
                end;
                if (Erl.Rechnungstyp != c_Erl_SammelVK) then
                  Lib_Dokumente:Printform(450,'Rechnung',true)
                else
                  Lib_Dokumente:Printform(450,'Sammelrechnung',true);
              end;
              RETURN true;
            end;
          end;
        end;
      end;

      RecBufClear(915);

      gDokTyp # 'RECH';

//      WinEvtProcessSet(_winevtinit,false);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Dok.Verwaltung','');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(915,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,450);
      if (Erl.Rechnungstyp=c_Erl_SammelVK) then begin
        vFilter->RecFilterAdd(2,_FltAND,_FltEq,'SaRE');
        vFilter->RecFilterAdd(2,_FltOR,_FltEq,'SaREL');
      end
      else
        vFilter->RecFilterAdd(2,_FltAND,_FltEq,'RE');
      vFilter->RecFilterAdd(3,_FltAND,_FltScan, cnvai(Erl.Rechnungsnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8));
      gZLList->wpDbkeyno # 1;   // 26.05.2020
      gZLList->wpdbfilter # vFilter;
//      WinEvtProcessSet(_winevtinit,true);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Fibu' : begin
      if (Set.Fibu.Prozedur<>'') then
        Call(Set.Fibu.Prozedur+':Erl_Export')
      else
        Msg(450101,'',0,0,0);
    end;


    'Mnu.Stornieren' : begin
      Erl_Data:Stornieren();
      cZList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
    end;


    'Mnu.Abschlussdatum' : begin
      if (Rechte[Rgt_Erl_Abschlussdatum]) then begin
        vAbschl # Set.Abschlussdatum;
        if (Dlg_Standard:Datum('Abschlussdatum',var vAbschl)) then begin
          vModule # Set.Module;
          RecRead(903,1,_RecLock);
          Set.Abschlussdatum # vAbschl;
          if (RekReplace(903,_RecUnlock,'AUTO') <> _rOk) then
            Msg(999999,'Das Abschlussdatum konnte nicht gespeichert werden.',0,0,0);
          Set.Module # vModule;
          Lib_Initialize:ReadIni();
        end;

      end;
    end;


    'Mnu.Konten' : begin
      RecBufClear(451);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Erl.K.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpdbFileNo     # 450;
      gZLList->wpdbKeyno      # 1;
      gZLList->wpdbLinkFileNo # 451;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile, Erl.Anlage.Datum, Erl.Anlage.Zeit, Erl.Anlage.User );
    end;


    'Mnu.SammelGelangen' : begin
      Erl_Data:DruckSammelGelangen();
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
  Erx     : int;
  vBuf    : int;
end;
begin
  if (aMark) then begin
    if (RunAFX('Erl.EvtLstDataInit','y')<0) then RETURN;
  end
  else if (RunAFX('Erl.EvtLstDataInit','n')<0) then RETURN;

  if (aMark=n) then begin
    // ST 2018-06-11: Umstellung auf Stornorechnungsnr, gegen Bug in Mehrsprachsystemen
    //if (Erl.Bemerkung = Translate('STORNIERT')) then begin
    if (Erl.StornoRechNr <> 0) AND (Erl.Bemerkung <> '') then begin
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd);
    end
    else begin
      Erx # RecLink(853,450,12,_recfirst);    // Rechungstyp holen
      If (Erx<=_rLocked) and (RTy.Farbe<>0) then begin
        Lib_GuiCom:ZLColorLine(gZLList,RTy.Farbe);
      end;
    end;
  end;

  vBuf # RecBufCreate(100);
  Erx # RecLink(vBuf, 450, 8, _recFirst);
  if(Erx > _rLocked) then
    RecBufClear(vBuf);
  GV.Alpha.01 # vBuf -> Adr.Stichwort;
  RecBufDestroy(vBuf);

  /// ---------------------------------
  // Jumplogik kennzeichnen
  Lib_GuiCom:ZLQuickJumpInfo($clmErl.KundenStichwort);
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
  Erx : int;
end;
begin
  if (aName = StrCnv('clmErl.KundenStichwort',_StrUpper)) then begin
    Adr.Kundennr # aBuf->Erl.Kundennummer;
    Erx # RecRead(100,2,0);
    if (erx<=_rMultikey) then
      Adr_Main:Start(0, Adr.Nummer,y);
  end;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================
