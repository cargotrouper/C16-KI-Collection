@A+
//==== Business-Control ==================================================
//
//  Prozedur    Mat_A_Main
//                    OHNE E_R_G
//  Info
//
//
//  31.01.2005  AI  Erstellung der Prozedur
//  07.03.2008  ST  Kostenstelle hinzugefügt
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  20.08.2012  AI  Neu: AFX "Mat.A.Recinit"
//  31.07.2014  ST  Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  14.08.2014  AH  Prüfung auf Abschlussdatum dekativiert
//  17.12.2015  AH  KostenW1ProMEH werden berechnet
//  17.11.2016  AH  MatZ für ERe
//  22.10.2018  AH  (MatZ für ERe nimmt nicht doppelt auf) siehe 03.04.2019
//  08.03.2019  AH  Neu: AFX "Mat.A.NewMatz"
//  03.04.2019  AH  Matz für ERe warnt bei mehreren Einträgen
//  30.04.2020  AH  Edit/Del darf nur auf Aktionen DIESER Karte passieren !!!
//  06.07.2020  AH  QuickJump
//  15.02.2021  AH  CO2
//  21.02.2022  AH  ERX
//  25.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(...
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
//    SUB AusKostenstelle()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle :    'Aktionen'
  cFile :     204
  cMenuName : 'Mat.A.Bearbeiten'
  cPrefix :   'Mat_A'
  cZList :    $ZL.Mat.Aktionen
  cKey :      1
end;

declare RefreshMode(opt aNoRefresh : logic);

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edMat.A.Kostenstelle);
Lib_Guicom2:Underline($edMat.A.Adressnr);

  SetStdAusFeld('edAdr.Sprache'         ,'Sprache');
  SetStdAusFeld('edMat.A.Adressnr'      ,'Adresse');
  SetStdAusFeld('edMat.A.Kostenstelle'  ,'Kostenstelle');

  if (gUsername='AH') then begin
    vHdl # Winsearch(aEvt:Obj, 'ZL.Mat.Aktionen');
    if (vHdl<>0) then begin
      vHdl # Winsearch(vHdl, 'clmMat.A.Anlage.Zeit');
      if (vHdl<>0) then begin
        vHdl->wpFmtTimeFlags # _FmtTimeHSeconds;
      end;
    end;
  end;

  if (Set.Installname='BSP') then begin
    $lbMat.A.CO2ProT->wpvisible # true;
    $edMat.A.CO2ProT->wpvisible # true;
    $lbCO2->wpvisible # true;
  end;

/*  2023-01-20  AH MEH wird PRO ZEILE ausgewisen
  vHdl # Winsearch(cZlist, 'clmMat.A.KostenW1ProMEH');
  vHdl->wpcaption # vHdl->wpcaption + Mat.MEH;
  vHdl # Winsearch(cZList, 'clmMat.A.Kosten2W1ProME');
  vHdl->wpcaption # vHdl->wpcaption + Mat.MEH;
  vHdl # Winsearch(cZList, 'clmMat.A.Menge');
  vHdl->wpcaption # vHdl->wpcaption + ' '+Mat.MEH;
*/
  // ST 2022-03-14 2228/57: Provisorium zum Ersten Testen, wenn IO dann als Ankerfunktiuon "Init.Pre" implemenentieren
/*  2023-01-16  AH
  if (Set.Installname='xxxHWN') then begin
    // ZGR
    vHdl # Winsearch($ZL.Mat.Aktionen, 'clmMat.A.KostenW1');
    vHdl->wpDbFieldName # 'Mat.A.KostenW1ProMEH';

    vHdl # Winsearch($ZL.Mat.Aktionen, 'clmMat.A.Kosten2W1');
    vHdl->wpDbFieldName # 'Mat.A.Kosten2W1ProME';


    // Dialog
    vHdl # Winsearch($Mat.A.Verwaltung, 'lbMat.A.KostenW1');
    vHdl->wpCaption # 'Kosten / kg';

    vHdl # Winsearch($Mat.A.Verwaltung, 'lbMat.A.Kosten2W1');
    vHdl->wpCaption # 'Basisaufpreis / kg';
    
    vHdl # Winsearch($Mat.A.Verwaltung, 'edMat.A.KostenW1');
    vHdl->wpDbFieldName # 'Mat.A.KostenW1ProMEH';

    vHdl # Winsearch($Mat.A.Verwaltung, 'edMat.A.Kosten2W1');
    vHdl->wpDbFieldName # 'Mat.A.Kosten2W1ProME';
  end;
*/

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  EvtMdiActivate
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin

  Call('App_Main:EvtMdiActivate',aEvt);

  if (w_Parent<>0) then begin
    if (w_Parent->wpname=Lib_Guicom:GetAlternativeName('ERe.Verwaltung')) then begin
      vHdl # Winsearch(gMenu,'Mnu.New');
      if (vHdl<>0) then vHdl->wpName # 'Mnu.NewMatz';
      vHdl # Winsearch(aEvt:Obj,'New');
      if (vHdl<>0) then begin
        vHdl->wpName # 'NewMatz';
        vHdl->WinEvtProcNameSet(_WinEvtClicked, here+':EvtClicked');
      end;
      RefreshMode();
    end;
  end;

  RETURN(true);
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
  Lib_GuiCom:Pflichtfeld($edMat.A.Aktionsdatum);
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

  if (aName='') or (aName='edMat.A.Adressnr') then begin
    Erx # RecLink(100,204,2,0);
    if (Erx<=_rLocked) then
      $Lb.Adresse->wpcaption # Adr.Stichwort
    else
      $Lb.Adresse->wpcaption # '';
  end;


  if (aName='') or (aName='edMat.A.Kostenstelle') then begin
    Erx # RecLink(846,204,3,0);
    if (Erx<=_rLocked) then
      $Lb.Kostenstelle->wpcaption # Kst.Bezeichnung
    else
      $Lb.Kostenstelle->wpcaption # '';
  end;

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

  // Ankerfunktion
  if (RunAFX('Mat.A.RecInit', '') < 0) then
    RETURN;

  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  if (Mode=c_ModeNew) then begin
    Mat.A.Materialnr    # Mat.Nummer;
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Aktionstyp    # c_Akt_Man;
    Mat.A.Aktionsdatum  # today;
    Mat.A.Aktion        # 0;
  end;

  // Focus setzen auf Feld:
  $edMat.A.Bemerkung->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vM        : float;
  vGew      : float;
  vStk      : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  if (Mat.A.Aktionsdatum=0.0.0) then begin
    Msg(001200,Translate('Datum'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edMat.A.Aktionsdatum->WinFocusSet(true);
    RETURN false;
  end;

//  if (Lib_Faktura:Abschlusstest(Mat.A.Aktionsdatum) = false) then begin
//    Msg(001400 ,Translate('Datum') + '|'+ CnvAd(Mat.A.Aktionsdatum),0,0,0);
//    $NB.Main->wpcurrent # 'NB.Page1';
//    $edMat.A.Aktionsdatum->WinFocusSet(true);
//    RETURN false;
//  end;

  // 17.12.2015 AH:
  // 17.12.2015 AH:
  // 30.03.2017 AH: auch für gelöschte/alte/Schrottkarten
  vM    # Mat.Bestand.Menge + Mat.Bestellt.Menge;
  vStk  # Mat.Bestand.Stk + Mat.Bestellt.Stk;
  vGew  # Mat.Bestand.Gew + Mat.Bestellt.Gew;

  if (vM=0.0) then begin
    if (vGew=0.0) then begin
      if (vStk=0) then vStk # 10;
      Erx # RekLink(819,200,1,0);   // Warengruppe holen
      vGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(vStk, Mat.Dicke, Mat.Breite, "Mat.Länge", Mat.Dichte, "Wgr.TränenKgProQM");
      if (vGew=0.0) then begin
        vGew # 1000.0;
        vStk # Lib_Berechnungen:Stk_aus_KgDBLDichte2(vGew, Mat.Dicke, Mat.Breite, "Mat.Länge", Mat.Dichte, "Wgr.TränenKgProQM");
      end;
    end;
    vM # Mat_Data:MengeVorlaeufig( vStk, vGew, vGew);
  end;

  if (vM<>0.0) then
    Mat.A.KostenW1ProMEH # Rnd( (Mat.A.KostenW1 * vGew / 1000.0) / vM ,2);
  if (vM<>0.0) then
    Mat.A.Kosten2W1ProME # Rnd( (Mat.A.Kosten2W1 * vGew / 1000.0) / vM ,2);

  if (Mat.A.Aktionsdatum=today) then Mat.A.Aktionszeit # now;

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren

  TRANSON;

  if (Mode=c_ModeEdit) then begin
// 21.02.2022    RekReplace(gFile,_recUnlock,'MAN');
    Erx # Mat_a_Data:replace(_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    Erx # Mat_A_Data:Insert(0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (gZLList->wpDbSelection<>0) then begin
//      vTmp # gZList->wpDbSelection;
//      vTmp-
      SelRecInsert(gZLList->wpDbSelection,gfile);
    end;
  end;

  if (Mat_A_Data:Vererben()) then begin
    TRANSOFF;
  end
  else begin
    TRANSBRK;
    ErrorOutput;
    RETURN False;
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

  // Ankerfunktion
  RunAFX('Mat.A.Delete','');

//  if (Lib_Faktura:Abschlusstest(Mat.A.Aktionsdatum) = false) then begin
//    Msg(001400,Translate('Aktionsdatum') + '|'+ CnvAd(Mat.A.Aktionsdatum),0,0,0);
//    RETURN;
//  end;


  RekDelete(gFile,0,'MAN');

  if (Mat_A_Data:Vererben()=false) then
    ErrorOutput;

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
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung','Mat_A_Main:AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    'Kostenstelle' : begin
      RecBufClear(846);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'KsT.Verwaltung','Mat_A_Main:AusKostenstelle');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  Ere_Eintrag
//========================================================================
sub Ere_Eintrag(
  aMatNr  : int;
  aAdrNr  : int) : logic;
local begin
  Erx     : int;
  vOK     : logic;
end;
begin
  if (Mat.Nummer<>aMatNr) then begin
    Mat_Data:Read(aMatNr);
  end;

  // 22.10.2018 AH: Test, ob bereits vorhanden
  FOR Erx # RecLink(204,200,14,_recFirst)
  LOOP Erx # RecLink(204,200,14,_recNext)
  WHILE (Erx<=_rLocked) and (vOK=false) do begin
    if (Mat.A.Aktionstyp=c_akt_EreMat) then vOK # true;
  END;
  
  if (vOK) then begin
    if (Msg(555010,aint(Mat.Nummer),_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;
  end;

  RecBufClear(204);
  Mat.A.Materialnr    # aMatNr;
  Mat.A.Aktionsmat    # aMatNr;
  Mat.A.Aktionstyp    # c_akt_EreMat;//c_Akt_GbMat;
  Mat.A.EK.RechNr     # ERe.Nummer;
  Mat.A.Bemerkung     # c_aktBem_EreMat;//c_AktBem_GbMat;
  Mat.A.Aktionsdatum  # ERe.WertstellungsDat;
  Mat.A.Terminstart   # ERe.WertstellungsDat;
  Mat.A.Terminende    # ERe.WertstellungsDat;
  Mat.A.Adressnr      # aAdrNr;
  Mat.A.KostenW1      # 0.0;
  if (Mat_A_data:Insert(0,'AUTO')=_rOK) then begin
    if (gZLList->wpDbSelection<>0) then
      SelRecInsert(gZLList->wpDbSelection,gfile);
  end;
end;


//========================================================================
//  AusMatZuordnungMDI
//
//========================================================================
sub AusMatZuordnungMDI()
local begin
  Erx     : int;
  vX      : int;
  vItem   : int;
  vMode   : alpha;
  vMFile  : int;
  vMID    : int;
  vAdrNr  : int;

  vQ        : alphA(4000);
  vSel      : int;
  vSelName  : alpha;
end;
begin

  Erx # RekLink(100,560,5,_recfirst);   // EreEmpfänger holen
  vAdrNr # Adr.Nummer;


  Lib_Sel:QInt(var vQ, 'Ein.E.Nummer', '=', Sel.Auf.von.Nummer);
  Lib_Sel:QInt(var vQ, 'Ein.E.Position', '=', Sel.Auf.Bis.Nummer);
  Lib_Sel:QInt(var vQ, 'Ein.E.Materialnr', '>', 0);
  vQ # vQ + ' AND Ein.E.EingangYN';
  Lib_Sel:QVonBisD(var vQ, 'Ein.E.Eingang_Datum', "Sel.Mat.von.EDatum", "Sel.Mat.bis.EDatum");

  vSel # SelCreate(506, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(506,vSel, _recFirst);
  LOOP Erx # RecRead(506,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    ERe_Eintrag(Ein.E.Materialnr, vAdrNr);
  END;
  SelClose(vSel);
  SelDelete(506, vSelName);
  vSel # 0;

  cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  cZList->WinFocusSet(false);
end;


//========================================================================
//  AusMatZuordnung
//
//========================================================================
sub AusMatZuordnung()
local begin
  Erx     : int;
  vX      : int;
  vItem   : int;
  vMode   : alpha;
  vMFile  : int;
  vMID    : int;
  vAdrNr  : int;
end;
begin

  if (gSelected<>0) then begin
    // Feldübernahme
    RecRead(200,0,_RecId | _RecLock ,gSelected);
    gSelected # 0;

    Erx # RekLink(100,560,5,_recfirst);   // Lieferant holen
    vAdrNr # Adr.Nummer;

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
            ERe_Eintrag(Mat.Nummer, vAdrNr);
          end;
        END;
      end;
    end
    else begin
      ERe_Eintrag(Mat.Nummer, vAdrNr);
    end;

  end;  // selected

  cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  cZList->WinFocusSet(false);

  Lib_Mark:Reset(200);

end;


//========================================================================
//  AusMatAblZurodnung
//
//========================================================================
sub AusMatAblZuordnung()
local begin
  Erx     : int;
  vX      : int;
  vItem   : int;
  vMode   : alpha;
  vMFile  : int;
  vMID    : int;
  vAdrNr  : int;
end;
begin

  if (gSelected<>0) then begin
    // Feldübernahme
    RecRead(210,0,_RecId | _RecLock ,gSelected);
    gSelected # 0;

    Erx # RekLink(100,560,5,_recfirst);   // Lieferant holen
    vAdrNr # Adr.Nummer;

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
            ERe_Eintrag("Mat~Nummer", vAdrNr);
          end;
        END;
      end;
    end
    else begin
      ERe_Eintrag("Mat~Nummer", vAdrNr);
    end;

  end;  // selected

  cZList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  cZList->WinFocusSet(false);

  Lib_Mark:Reset(210);

end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    Mat.A.Adressnr      # Adr.Nummer;
    // Feldübernahme
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edMat.A.Adressnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMat.A.Adressnr');
end;


//========================================================================
//  AusKostenstelle
//
//========================================================================
sub AusKostenstelle()
begin
  if (gSelected<>0) then begin
    RecRead(846,0,_RecId,gSelected);
    Mat.A.Kostenstelle # Kst.Nummer;
    // Feldübernahme
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:
  $edMat.A.Kostenstelle->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMat.A.Kostenstelle');
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
  vEreMode    : logic;
  vEreSperre  : logic;
end
begin
  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('NewMatz');
  if (vHdl <> 0) then begin
    vEreMode # true;
    vEReSperre # ERe.InOrdnung or ERe.NichtInOrdnung;
    vHdl->wpDisabled # vEreSperre;
  end;
  vHdl # gMenu->WinSearch('Mnu.NewMatz');
  if (vHdl <> 0) then
    vHdl->wpDisabled # vEReSperre;

  vHdl # gMenu->WinSearch('Mnu.BestellMatZuordnen');
  if (vHdl <> 0) then begin
    vHdl->wpDisabled # (vEreMode=false) or vEReSperre;
  end;

  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_A_Anlegen]=n) or (vEreSperre);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_A_Anlegen]=n) or (vEreSperre);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then // 2023-03-06 AH
    vHdl->wpDisabled # ((mode<>c_modeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Mat_A_Aendern]=n) or (vEReSperre) or (Mat.A.Materialnr<>Mat.Nummer) or
                              (Lib_Faktura:Abschlusstest(Mat.A.Aktionsdatum) = false);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # ((mode<>c_modeList) and (Mode<>c_ModeView)) or
                      (Rechte[Rgt_Mat_A_Aendern]=n) or (vEReSperre) or (Mat.A.Materialnr<>Mat.Nummer) or
                              (Lib_Faktura:Abschlusstest(Mat.A.Aktionsdatum) = false);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_ModeList) or (Rechte[Rgt_Mat_A_Loeschen]=n) or (vEReSperre) or (Mat.A.Materialnr<>Mat.Nummer) or
                              (Lib_Faktura:Abschlusstest(Mat.A.Aktionsdatum) = false);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode<>c_ModeList) or (Rechte[Rgt_Mat_A_Loeschen]=n) or (vEReSperre) or (Mat.A.Materialnr<>Mat.Nummer) or
                              (Lib_Faktura:Abschlusstest(Mat.A.Aktionsdatum) = false);

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
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.BestellMatZuordnen' : begin
      RecBufClear(998);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mdi.Mat.A.Zuordnung',here+':AusMatZuordnungMDI');
      gMDI->wpcaption # Lfm.Name;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.NewMatz' : begin
      if (RunAFX('Mat.A.NewMatz', '') = 0) then begin
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
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Mat.A.Anlage.Datum, Mat.A.Anlage.Zeit, Mat.A.Anlage.User);
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

  if (aEvt:Obj->wpName='NewMatz') then begin
    if (RunAFX('Mat.A.NewMatz', '') = 0) then begin
      If (Msg(210004,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then begin
        RecBufClear(210);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Ablage',here+':AusMatAblZuordnung',n);
      end
      else begin
        RecBufClear(250);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',Here+':AusMatZuordnung',n);
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->WinFocusSet(true);
    end;
    RETURN true;
  end;


  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Adresse'      :   Auswahl('Adresse');
    'bt.Kostenstelle' :   Auswahl('Kostenstelle');
    'bt.xxxxx' :   Auswahl('...');
  end;

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
local begin
  Erx   : int;
  v200  : int;
end;
begin
  Gv.Alpha.01 # Mat.A.Aktionstyp;
  if (Mat.A.Aktionsnr<>0) then    Gv.Alpha.01 # Gv.Alpha.01 + ' '+AInt(Mat.A.Aktionsnr);
  if (Mat.A.AktionsPos<>0) then   Gv.alpha.01 # gv.alpha.01 + '/'+ AInt(Mat.A.Aktionspos);
  if (Mat.A.AktionsPos2<>0) then  Gv.alpha.01 # gv.alpha.01 + '/'+ AInt(Mat.A.Aktionspos2);
  if (Mat.A.AktionsPos3<>0) then  Gv.alpha.01 # gv.alpha.01 + '/'+ AInt(Mat.A.Aktionspos3);

  // 2023-01-20 AH
  v200 # RekSave(200);
  Erx # Mat_Data:Read(Mat.A.Materialnr);
  GV.Alpha.10 # Mat.MEH;
  RekRestore(v200);

  // 06.07.2020
  if (Mat.A.Aktionsnr <> 0) then begin
    case Mat.A.Aktionstyp of
      c_Akt_VLDAW,
      c_Akt_LFS,
      c_Akt_BA_Plan_Fahr,
      c_Akt_BA           ,
      c_Akt_BA_Plan      ,
      c_Akt_BA_Fertig    ,
      c_Akt_BA_Ausfall   ,
      c_Akt_BA_Einsatz   ,
      c_Akt_BA_Rest      ,
      c_Akt_BA_Kosten    ,
      c_Akt_Reklamation : begin Lib_GuiCom:ZLQuickJumpInfo($clmGV.Alpha.01);  end;
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
  if (arecid=0) then RETURN true;
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
  Erx         : int;
  vBuf,vBuf2  : int;
end;
begin

  // Klick auf Aktionkürzel
  if (aName = StrCnv('clmGV.Alpha.01',_StrUpper)) AND (aBuf->Mat.A.Aktionsnr <> 0) then begin
    case aBuf->Mat.A.Aktionstyp of

      // Ziel Lieferschein:
      c_Akt_VLDAW,
      c_Akt_LFS : begin
                    Lfs.Nummer # aBuf->Mat.A.Aktionsnr;
                    Erx # RecRead(440,1,0);
                    if (Erx <= _rLocked) then
                      Lfs_Main:Start(RecInfo(440,_RecId),y);
                  end;

      c_Akt_BA_Plan_Fahr : begin
                    vBuf # RecBufCreate(440);
                    vBuf->Lfs.zuBA.Nummer   # aBuf->Mat.A.Aktionsnr;
                    vBuf->Lfs.zuBA.Position # aBuf->Mat.A.Aktionspos;
                    Erx # RecRead(vBuf,2,0);
                    if (Erx <= _rMultikey) then begin
                      Recread(vBuf,1,0);
                      Lfs_Main:Start(RecInfo(vBuf,_RecId),y);
                    end;
                  end;

      // Ziel Betriebsauftrag
      c_Akt_BA           ,
      c_Akt_BA_Plan      ,
      c_Akt_BA_Fertig    ,
      c_Akt_BA_Ausfall   ,
      c_Akt_BA_Einsatz   ,
      c_Akt_BA_Rest      ,
      c_Akt_BA_Kosten    : begin
                            BA1_Main:Start(0, aBuf->Mat.A.Aktionsnr,y);
                           end;
      // ZIEL Reklamaktion:
      c_Akt_Reklamation : begin
                            vBuf  # RecBufCreate(300);
                            vBuf->Rek.Nummer  # aBuf->Mat.A.Aktionsnr;
                            Erx # RecRead(vBuf,1,0);
                            if (Erx <= _rMultikey) then begin

                              // Reklamationskopf zur Position gefunden
                              vBuf2 # RecBufCreate(301);
                              Erx # RecLink(vBuf2,vBuf,1,_RecFirst)
                              if (Erx <= _rLocked) then
                                Rek_P_Main:Start(0, vBuf2->Rek.P.Nummer,vBuf2->Rek.P.Position,y);

                              RecBufDestroy(vBuf2);
                            end;
                            RecBufDestroy(vBuf);
                          end;
    end;

  end;

  RunAFX('Mat.A.JumpTo',aName+'|'+aint(aBuf));

  if ((aName =^ 'edMat.A.Kostenstelle') AND (aBuf->Mat.A.Kostenstelle<>0)) then begin
    RekLink(846,204,3,0);   // Kostenstelle holen
    Lib_Guicom2:JumpToWindow('KsT.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMat.A.Adressnr') AND (aBuf->Mat.A.Adressnr<>0)) then begin
    RekLink(100,204,2,0);   // Adresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================