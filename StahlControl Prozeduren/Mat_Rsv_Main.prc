@A+
//==== Business-Control ==================================================
//
//  Prozedur    Mat_Rsv_Main
//                  OHNE E_R_G
//
//  Info
//    Steuert die Material-Reservierungsverwaltung
//
//  22.07.2004  ST  Erstellung der Prozedur
//  25.08.2009  MS  Mnu.Ktx.Errechnen hinzugefuegt
//  24.02.2011  ST  Fehlerkorrektur
//  30.11.2012  AI  gelöschte Karten können NICHT reserviert werden
//  25.06.2014  AH  Bugfix: Materialnr. wird wieder gefüllt
//  07.04.2016  AH  Neu: Drag&Drop
//  14.04.2016  AH  Neu: Mnu.AlleMat
//  02.05.2016  AH  Neu: Summe
//  30.05.2016  AH  Neu: Auftrags-Preis als Spalte
//  07.06.2016  AH  Directory auf %temp%
//  08.10.2018  ST  AFX "Mat.Rsv.RecSave.Pre" hinzugefügt
//  04.02.2020  AH  Materialauswahl ggf. nur für Artikelnr. des Auftrages
//  15.06.2020  AH  Summen nehmen Werte von gelöschtem Material NICHT auf
//  31.01.2022  AH  ERX, Timer für Res.Übernahme
//  25.07.2022  HA  Quick Jump
//  2023-04-21  MR: Neuer Anker Mat.Rsv.EvtLstDataInit 2460/10
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusKommission()
//    SUB AusMaterial()
//    SUB AusKunde()
//    SUB AusInfo()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtDropEnter...
//    SUB EvtDrop...
//    SUB EvtTimer(aEvt : event; aTimerId : int) : logic
//
//    SUB Uebernahme
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle :    'Reservierungen'
  cFile :     203
  cMenuName : 'Mat.Rsv.Bearbeiten'
  cPrefix :   'Mat_Rsv'
  cZList :    $ZL.Mat.Reservierungen
  cKey :      1
end;
declare Uebernahme()


//========================================================================
// Summieren
//
//========================================================================
sub Summieren();
local begin
  Erx       : int;
  vNetto    : Float;
  vStk      : int;
  vM        : float;
  v200      : int;
end;
begin

  // Summe ermitteln...
  if (gZLList->wpdbSelection<>0) then begin
    FOR Erx # RecRead(203,gZLList->wpDbSelection,_recFirst)   // Input loopen
    LOOP Erx # RecRead(203,gZLList->wpdbSelection,_recNext)
    WHILE (Erx<=_rLocked) do begin
      v200 # RecBufCreate(200);
      Erx # RecLink(v200, 203, 1,0);  // Material holen 15.06.2020
      if (Erx > _rLocked or v200->"Mat.Löschmarker" = '*') then begin
        RecbufDestroy(v200);
        CYCLE;
      end;
      RecbufDestroy(v200);

      vNetto  # vNetto + Mat.R.Gewicht;
      vM      # vM + "Mat.R.Menge";
      vStk    # vStk + "Mat.R.Stückzahl";
    END;
  end
  else begin
    FOR Erx # RecLink(203,200,13,_recFirst)   // Input loopen
    LOOP Erx # RecLink(203,200,13,_recNext)
    WHILE (Erx<=_rLocked) do begin
      vNetto  # vNetto + Mat.R.Gewicht;
      vM      # vM + "Mat.R.Menge";
      vStk    # vStk + "Mat.R.Stückzahl";
    END;
  end;

  $lb.Sum.Netto->wpcaption    # ANum(vNetto,Set.Stellen.Gewicht);
  $lb.Sum.Stueck->wpcaption   # aInt(vStk);
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vTmp  : int;
end;
begin
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

Lib_Guicom2:Underline($edMat.R.Materialnr);
Lib_Guicom2:Underline($edMat.R.Kommission);
Lib_Guicom2:Underline($edMat.R.Kundennummer);

  SetStdAusFeld('edAdr.Sprache'         ,'Sprache');
  SetStdAusFeld('edMat.R.Kommission'    ,'Kommission');
  SetStdAusFeld('edMat.R.Kundennummer'  ,'Kunde');
  SetStdAusFeld('edMat.R.Materialnr'    ,'Material');
  SetStdAusFeld('edMat.R.WorkflowNr'    ,'WoF');
  
  RunAFX('Mat.Rsv.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);

  vTmp # gMDI->WinSearch('lb.Sort');
  if (vTmp<>0) then vTmp->wpvisible # false;
  vTmp # gMDI->WinSearch('lb.Suche');
  if (vTmp<>0) then vTmp->wpvisible # false;
  vTmp # gMDI->WinSearch('ed.Sort');
  if (vTmp<>0) then vTmp->wpvisible # false;
  vTmp # gMDI->WinSearch('ed.Suche');
  if (vTmp<>0) then vTmp->wpvisible # false;

end;


//========================================================================
// EvtMdiActivate
//
//========================================================================
sub EvtMdiActivate(
	aEvt         : event     // Ereignis
) : logic
begin

  if (w_Command='UEBERNAHME') then begin
    w_Command # '';
    w_TimerVar # 'UEBERNAME|'+w_Cmd_Para;
    gTimer2 # SysTimerCreate(1000,1,aEvt:Obj);
  end;

  // Aus Auftrag?
//  if (gZLList->wpDbKeyNo=18) then
  if ($NB.Main->wpcustom='AUF') then begin
    $lb.LinkInfo->wpcaption # Translate('zu Auftrag')+' '+aint(Auf.P.Nummer) + '/' + aint(Auf.P.Position);
  end;
  if ($NB.Main->wpcustom='MAT') then begin
    $lb.LinkInfo->wpcaption # Translate('zu Material')+' '+aint(Mat.Nummer);
    $lb.LinkInfo->wpcustom  # aint(Mat.Nummer);
  end;
  RETURN App_Main:EvtMdiActivate(aEvt);
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
  Lib_GuiCom:Pflichtfeld($edMat.R.Kundennummer);
  Lib_GuiCom:Pflichtfeld($edMat.R.Stckzahl);
  Lib_GuiCom:Pflichtfeld($edMat.R.Gewicht);
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
  Erx   : int;
  vPos  : int;
  vA    : alpha;
  vTmp  : int;
end
begin

  if (Mat.R.Materialnr<>0) then begin   // 16.07.2021 AH
    Erx # RecLink(200,203,1,_recFirst);   // Material holen
    if (Erx>_rLocked) then RecBufClear(200);
  end;

  $Lb.Mat.Dicke->wpcaption # cnvaf(Mat.Dicke,0,0,Set.Stellen.Dicke);
  $Lb.Mat.Breite->wpcaption # cnvaf(Mat.Breite,0,0,Set.Stellen.Breite);
  $Lb.Mat.Laenge->wpcaption # cnvaf("Mat.Länge",0,0,"Set.Stellen.Länge");
  $Lb.Mat.Bestand.Gew->wpcaption # anum("Mat.Verfügbar.Gew",Set.Stellen.Gewicht);
  $Lb.Mat.Bestand.Stk->wpcaption # aint("Mat.Verfügbar.Stk");

  if (aName='edMat.R.Materialnr') and
    (($edMat.R.Materialnr->wpchanged) or (aChanged)) then begin
    if ("Mat.R.Stückzahl"=0) then "Mat.R.Stückzahl" # "Mat.Verfügbar.Stk";
    if (Mat.R.Gewicht=0.0) then Mat.R.Gewicht       # "Mat.Verfügbar.Gew";
    $edMat.R.Stckzahl->winupdate(_WinUpdFld2Obj);
    $edMat.R.Gewicht->winupdate(_WinUpdFld2Obj);

    $Lb.Mat.Dicke->winupdate(_WinUpdFld2Obj);
    $Lb.Mat.Breite->winupdate(_WinUpdFld2Obj);
    $Lb.Mat.Laenge->winupdate(_WinUpdFld2Obj);
    $Lb.Mat.Guete->winupdate(_WinUpdFld2Obj);
  end;

  // Aus Kommission Kunden ermitteln
  if (aName='') or (aName='Kommission') then begin
    // Die Kommission kann eingetippt werden, daher müssen die Felder Auftragnummer und -stichwort
    // aus dieser entnommen werden

    vPos # StrFind(Mat.R.Kommission, '/', 0);
    if (vPos <> 0) then begin
      Mat.R.Auftragsnr  # CnvIA(StrCut(Mat.R.Kommission,1,vPos-1));
      Mat.R.Auftragspos # CnvIA(StrCut(Mat.R.Kommission,vPos,99));

      Mat.R.Kundennummer # 0;
      Mat.R.KundenSW # '';

      if (Mat.R.Auftragspos <> 0) then begin
        Erx # RecLink(401, 203, 2, 0);
        if (Erx<=_rLocked) then begin
          Mat.R.Kundennummer # Auf.P.Kundennr;
          Mat.R.KundenSW # Auf.P.KundenSW;
        end;
      end;

      $edMat.R.Kundennummer->WinUpdate(_WinUpdFld2Obj);
      $ld.Kundenstw->WinUpdate(_WinUpdFld2Obj);
    end;
  end;

  // Kunde wurde gewählt/manuell eingeben
  if (aName='Kunde') then begin
    // Kommission entfernen
    Mat.R.Kommission # '';
    Mat.R.Auftragsnr # 0;
    Mat.R.Auftragspos # 0;
    $edMat.R.Kommission->WinUpdate(_WinUpdFld2Obj);

    Mat.R.KundenSW # '';

    // Stichwort updaten
    Erx # RecLink(100,203,3,0);
    if (Erx<=_rLocked) then
      Mat.R.KundenSW # Adr.Stichwort;

    $ld.Kundenstw->WinUpdate(_WinUpdFld2Obj);

  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if (aName='') then begin
    if ("Mat.R.Trägertyp"='') then begin
      $lb.Traeger->wpcaption # '';
    end
    else begin
      vA # "Mat.R.Trägertyp"+' '+cnvai("Mat.R.Trägernummer1");
      if ("Mat.R.Trägernummer2"<>0) then vA # vA +'/'+cnvai("Mat.R.Trägernummer2");
      if ("Mat.R.Trägernummer3"<>0) then vA # vA +'/'+cnvai("Mat.R.Trägernummer3");
      $lb.Traeger->wpcaption # vA;
    end;
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

  // Aus Auftrag?
  if ($NB.Main->wpcustom='AUF') then begin
    $edMat.R.Materialnr->WinFocusSet(true);
    Mat.R.Auftragsnr  # Auf.P.Nummer;
    Mat.R.Auftragspos # Auf.P.Position;
    Mat.R.Kommission  # CnvAI(Mat.R.Auftragsnr, _FmtNumNoGroup) + '/' + CnvAI(Mat.R.Auftragspos, _FmtNumNoGroup);
    Lib_GuiCom:Disable($edMat.R.Kommission);
    Lib_GuiCom:Disable($bt.Kommission);
    Lib_GuiCom:Disable($edMat.R.Kundennummer);
    Lib_GuiCom:Disable($bt.Kunde);
    RETURN;
  end;

  if (Mode=c_ModeNew) then begin
    Mat.R.TrackingYN # y;
  end;

  // Felder Disablen durch:
  Lib_GuiCom:Disable($edMat.R.Materialnr);
  Lib_GuiCom:Disable($bt.Material);
  // Focus setzen auf Feld:
  $edMat.R.Kommission->WinFocusSet(true);

//  Mat.R.Materialnr # Mat.Nummer;
  Mat.R.Materialnr # cnvia($lb.LinkInfo->wpcustom);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vNr         : int;
  vMenge      : int;
  vMengeDif   : int;
  vGewicht    : float;
  vGewichtDif : float;
end
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  if (Mat.Auftragsnr<>0) then RETURN false;

  // logische Prüfung
  if (Mat.R.Kundennummer = 0) then begin
    Msg(001200,'Kundennummer',0,0,0);
    $edMat.R.Kundennummer->WinFocusSet(false);
    RETURN false;
  end
  else if (RecLink(100,203,3,0)>_rLocked) then begin
    Msg(001201,'Kundennummer',0,0,0);
    $edMat.R.Kundennummer->WinFocusSet(false);
    RETURN false;
  end;

  if("Mat.R.Stückzahl" = 0) and (Mat.R.Gewicht = 0.0) then begin
    Msg(001200, 'Stückzahl oder Gewicht', 0, 0, 0);
    $edMat.R.Stckzahl -> WinFocusSet(false);
    RETURN false;
  end;
  
  // Hier erweiterte Meldungen bei falschen Daten
  if (RunAFX('Mat.Rsv.RecSave.Pre','')<0) then
    RETURN false;



  TRANSON;

  // Satz zurückspeichern & protokolieren

  vMengeDif   # 0;
  vGewichtDif # 0.0;

  Mat.R.Workflow # 100;
  if (Mode=c_ModeEdit) then begin

    // Ankerfunktion
    RunAFX('Mat.Rsv.RecSave','EDIT');

    // Berechnung der Differenz zum _alten_ Datensatz
//    vMengeDif # FldInt(ProtokollBuffer[203],1,8);
//    vGewichtDif # FldFloat(ProtokollBuffer[203],1,9);
//    RekReplace(gFile,_recUnlock,'MAN');
    if (Mat_Rsv_Data:Update()=false) then begin
    //if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(999999,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
    Lib_Workflow:Trigger(203, Mat.R.Workflow, _WOF_KTX_EDIT);
  end
  else begin

    // Ankerfunktion
    RunAFX('Mat.Rsv.RecSave','NEW')

    Mat.R.Anlage.Datum  # Today;
    Mat.R.Anlage.Zeit   # Now;
    Mat.R.Anlage.User   # gUserName;
//    RekInsert(gFile,0,'MAN');
    if (Mat_Rsv_Data:NeuAnlegen(0, 'MAN')=false) then begin
//    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(999999,gTitle,0,0,0);
      RETURN False;
    end;
    Lib_Workflow:Trigger(203, Mat.R.Workflow, _WOF_KTX_NEU);
  end;

/***
  // Reservierungssummen updaten und in Materialdatei speichern
  Erx # RecRead(200,1,_RecNoLoad | _RecLock);
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Msg(001000+Erx,Translate('Materialdatei'),0,0,0);
    RETURN false;
  end;

  vMenge # Mat.Reserviert.Stk;
  vGewicht # Mat.Reserviert.Gew;

  // Falls der Datensatz editiert wurde muss die Differenz der Menge/des Gewichts
  // addiert werden

  vMengeDif # "Mat.R.Stückzahl" - vMengeDif;
  vGewichtDif # Mat.R.Gewicht - vGewichtDif;

  vMenge # vMenge + vMengeDif;
  vGewicht # vGewicht + vGewichtDif;

  Mat.Reserviert.Stk # vMenge;
  Mat.Reserviert.Gew # vGewicht;

  Mat_data:Replace(_RecUnlock,'MAN');
***/

  TRANSOFF;

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
  Erx   : int;
  vOK   : logic;
enD;
begin

  // Eintrag mit Träger dürfen nicht gelöscht werden, wenn Träger auch gelöscht ist!
  if ("Mat.R.Trägertyp"='') then begin
    VOK # y;
  end
  else if ("Mat.R.TRägertyp"=c_Akt_BAInput) then begin
    vOK # y;
    BAG.IO.Nummer # "Mat.R.TrägerNummer1";
    BAG.IO.ID     # "Mat.R.TrägerNummer2";
    Erx # RecRead(701,1,0);
    if (Erx<=_rLocked) then begin
      Erx # RecLink(702,701,4,_recFirst);   // Nach-Pos holen
      if (Erx<=_rLocked) then begin
        if ("BAG.P.Löschmarker"='') then vOK # n;
      end;
    end;
  end;
  if (vOK=false) then RETURN;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;

  // Reservierungensummen updaten und in Materialdatei speichern
  if (Mat_Rsv_Data:Entfernen(true)=false) then begin
    Msg(999999,Translate('Materialdatei'),0,0,0);
    RETURN;
  end;

  if (gZLList->wpDbSelection<>0) then begin
    SelRecDelete(gZLList->wpDbSelection,gFile);
    RecRead(gFile, gZLList->wpDbSelection, 0);
  end;

/***
  Erx # RecRead(200,1,_RecNoLoad | _RecLock);
  if (Erx<>_rOk) then begin
    Msg(001000+Erx,Translate('Materialdatei'),0,0,0);
  end
  else begin
    Mat.Reserviert.Stk # Mat.Reserviert.Stk - "Mat.R.Stückzahl";
    Mat.Reserviert.Gew # Mat.Reserviert.Gew - Mat.R.Gewicht;
    Mat_data:Replace(_RecUnlock,'MAN');
    RekDelete(gFile,0,'MAN');
  end;
***/

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
  vHdl  : int;
  vQ    : alpha(4000);
end;

begin

  case aBereich of

    'Material' : begin
      // Ankerfunktion
      if (RunAFX('Mat.Rsv.Auswahl.Mat.Pre','')<>0) then RETURN;

      // 04.02.2020 AH: Proj. 2076/3
      if ($NB.Main->wpcustom='AUF') and (Auf.P.Artikelnr<>'') and (Wgr_data:IstMix(Auf.P.Wgr.Dateinr)) then begin
        Lib_Sel:QAlpha(var vQ, 'Mat.Strukturnr', '=', Auf.P.Artikelnr);
      end;
      RecBufClear(200);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial',n,n, '401');
      if (vQ<>'') then begin
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        Lib_Sel:QRecList(0,vQ);
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kommission' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusKommission');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kunde' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusKunde');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusKommission
//
//========================================================================
sub AusKommission()
begin
  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    // Feldübernahme
    Mat.R.Auftragsnr # Auf.P.Nummer;
    Mat.R.Auftragspos # Auf.P.Position;
    Mat.R.Kommission # CnvAI(Mat.R.Auftragsnr, _FmtNumNoGroup) + '/' + CnvAI(Mat.R.Auftragspos, _FmtNumNoGroup);
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:

  $edMat.R.Kommission->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('Kommission');
end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial()
begin
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Mat.R.MaterialNr # Mat.Nummer;
  end;
  // Focus auf Editfeld setzen:
  $edMat.R.Materialnr->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('edMat.R.Materialnr',y);
end;


//========================================================================
//  AusKunde
//
//========================================================================
sub AusKunde()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Mat.R.Kundennummer # Adr.KundenNr;
    Mat.R.KundenSW # Adr.Stichwort;
    gSelected # 0;
  end;
  // Focus auf Editfeld setzen:

  $edMat.R.Kundennummer->Winfocusset(false);
  // ggf. Labels refreshen
  RefreshIfm('Kunde');
end;


//========================================================================
//  AusInfo
//
//========================================================================
sub AusInfo()
begin
  gSelected # 0;
  // Focus auf Editfeld setzen:
  if (Mode=c_ModeList) then
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
  else
    Refreshifm();
  // ggf. Labels refreshen
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  Erx         : int;
  d_MenuItem  : int;
  vHdl        : int;
end
begin
 
  if (Mode=c_modeList) then begin
    Summieren();
  end;


  gMenu # gFrmMain->WinInfo(_WinMenu);
  Erx # gMDI->winsearch('NB.Main');

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or ("Mat.Löschmarker"='*') or (Rechte[Rgt_Mat_R_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or ("Mat.Löschmarker"='*') or (Rechte[Rgt_Mat_R_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or ("Mat.Löschmarker"='*') or (w_Auswahlmode) or (Rechte[Rgt_Mat_R_Aendern]=n) or ("Mat.R.Trägertyp"<>'');
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or ("Mat.Löschmarker"='*') or (w_Auswahlmode) or (Rechte[Rgt_Mat_R_Aendern]=n) or ("Mat.R.Trägertyp"<>'');

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Mat_R_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Mat_R_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Reorg');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) and ((w_Auswahlmode) or (Rechte[Rgt_Mat_R_Reorg]=n));


  vHdl # gMenu->WinSearch('Mnu.AlleMat');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList) or (Rechte[Rgt_Mat_R_Anlegen]=n) or ($NB.Main->wpcustom<>'AUF');



  // MUSTER Workflow
  vHdl # gMenu->WinSearch('Mnu.Workflow');
  if (vHdl <> 0) then
    vHdl->wpdisabled # ((mode<>c_modeList) and (Mode<>c_ModeView)) or (StrFind(Set.Module,'W',0)=0);
  // MUSTER ENDE

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
  Erx       : int;
  vHdl      : int;
  vMode     : alpha;
  vParent   : int;
  vMatNr    : int;
  vBildName : alpha(1000);
  vTextName : alpha(1000);
  vTmp      : int;
  vAblauf   : date;
  vM        : float;
  vGew      : float;
  vStk      : int;
  v200      : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.AlleMat' : begin
      Mat_Rsv_Data:AlleMarkMatEinfuegen();
      Summieren();
    end;


    // MUSTER Workflow
    'Mnu.Workflow' : begin
      if (Mat.R.Reservierungnr<>0) then WoF_Dlg_Main:Dialog(203);
    end;
    // MUSTER ENDE


    'Mnu.Reorg' : begin
      // Abfrage Liefertermin heute
      if (Dlg_Standard:Datum(Translate('bis Ablaufdatum'),var vAblauf,today) = false) then
        RETURN false;
      if (Mat_Rsv_Data:ReorgAll(vAblauf)=false) then begin
        Erroroutput;
        RETURN false;
      end;
      // Sonderfunktion beendet
      Msg(921001,gTitle,0,0,0);
      RETURN true;
    end;


    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edMat.R.Gewicht') then begin
        Erx # RecLink(401, 203, 2, _recFirst); // Auftrag zur Reservierung holen
        if(Erx > _rLocked) then
          RecBufClear(401);
        Mat.R.Gewicht   # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Mat.R.Stückzahl", Mat.Dicke, Mat.Breite, "Mat.länge", Mat.Warengruppe, "Mat.Güte", Mat.Strukturnr);
        $edMat.R.Gewicht->winupdate(_WinUpdFld2Obj);
      end;
      if (aEvt:Obj->wpname='edMat.R.Stckzahl') then begin
        Erx # RecLink(401, 203, 2, _recFirst); // Auftrag zur Reservierung holen
        if(Erx > _rLocked) then
          RecBufClear(401);
        "Mat.R.Stückzahl" # Lib_Berechnungen:STK_aus_KgDBLWgrArt(Mat.R.Gewicht, Mat.Dicke, Mat.Breite, "Mat.länge", Mat.Warengruppe, "Mat.Güte", Mat.Strukturnr);
        $edMat.R.Stckzahl->winupdate(_WinUpdFld2Obj);
      end;
    end;


    'Mnu.BAG.Graph' : begin
      if ("Mat.R.Trägertyp"=c_AKT_BAInput) then begin
        BAG.Nummer # "Mat.R.Trägernummer1";
        Erx # Recread(700,1,0);   // BAG holen
        if (Erx<=_rLocked) then begin

          FsiPathCreate(_Sys->spPathTemp+'StahlControl');
          FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
          vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
          vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';
          // Graphtext erzeugen
          BA1_Graph:BuildText(vTextName);

          // Graph erstellen
          SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);

          // externes Bild anzeigen
          Dlg_Bild('*'+vBildName);
        end;
      end;
    end;


    'Mnu.Takeover' : begin
      Uebernahme();
      RETURN true;
    end;


    'Mnu.Recalc' : begin

      // ST 2011-02-24:
      // Im Customfeld des Dialoges wird AUF oder MAT, je nach Aufrufsherkunft übergeben
      vHdl # winsearch(gMDI, 'NB.Main');
//      if ( gZLList->wpDbKeyNo = 18 ) then begin
      if (vHdl->wpcustom = 'AUF') then begin
        // Auftragsreservierungen neu summieren
        If ( RecRead( 401, 1, _recLock ) = _rOK ) then begin
          FOR  Erx # RecRead( 203, gZLList->wpDbSelection, _recFirst );
          LOOP Erx # RecRead( 203, gZLList->wpDbSelection, _recNext );
          WHILE ( Erx <= _rLocked ) DO BEGIN
          
            v200 # RecBufCreate(200);
            Erx # RecLink(v200, 203, 1,0);  // Material holen 15.06.2020
            if (Erx > _rLocked or v200->"Mat.Löschmarker" = '*') then begin
              RecbufDestroy(v200);
              CYCLE;
            end;
            RecbufDestroy(v200);

            vStk # vStk + "Mat.R.Stückzahl";
            vGew # vGew + "Mat.R.Gewicht";
            if (Auf.P.MEH.Einsatz='kg') then
              vM # vM + Mat.R.Gewicht
            else if (Auf.P.MEH.Einsatz='t') then
              vM # vM + (Mat.R.Gewicht / 1000.0)
            else if (Auf.P.MEH.Einsatz='Stk') then
              vM # vM + cnvfi("Mat.R.Stückzahl")
            else if (Mat.R.Menge<>0.0) then    // 24.01.2020 AH
              vM # vM + Mat.R.Menge;
          END;

          if (Auf.P.Prd.Reserv<>vM) or (Auf.P.Prd.Reserv.Gew<>vGew) or (Auf.P.Prd.Reserv.Stk<>vStk) then begin
            RecRead(401,1,_recLock);
            Auf.P.Prd.Reserv      # vM;
            Auf.P.Prd.Reserv.Gew  # vGew;
            Auf.P.Prd.Reserv.Stk  # vStk;
            Auf_Data:PosReplace(_recUnlock, 'AUTO' );
          end;
        end;
      end
      else
        Mat_Rsv_Data:ReCalcAll(); // Materialreservierungen neu summieren
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Mat.R.Anlage.Datum, Mat.R.Anlage.Zeit, Mat.R.Anlage.User);
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
    'bt.Kommission' :   Auswahl('Kommission');
    'bt.Kunde'      :   Auswahl('Kunde');
    'bt.Material'   :   Auswahl('Material');
    'bt.WoF'        :   Auswahl('WoF');
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
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='edMat.R.Kommission') then begin
    $edMat.R.Kommission->WinUpdate(_WinUpdObj2Fld);
    RefreshIfm('Kommission');
  end;

  if (aEvt:Obj->wpname='edMat.R.Kundennummer') then begin
    $edMat.R.Kundennummer->WinUpdate(_WinUpdObj2Fld);
    RefreshIfm('Kunde');
  end;

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
  Erx     : int;
  vBuf401 : int;
  vKW     : word;
  vYear   : word;
  vCol    : int;
end;
begin


  //2023-04-21  MR  Neuer Anker 2460/10
  if (aMark) then begin
    if (RunAFX('Mat.Rsv.EvtLstDataInit','y' + aEvt:obj->wpName)<0) then RETURN;
  end
  else if (RunAFX('Mat.Rsv.EvtLstDataInit','n' + aEvt:obj->wpName)<0) then RETURN;
  

  if (Mat.R.Materialnr<>0) then begin   // 16.07.2021 AH
    Erx # RecLink(200, 203, 1, _recFirst); // Material zu Reservierung holen, da man den
    if(Erx > _rLocked) then                // Dialog auch aus dem Auftrag aufrufen kann
      RecBufClear(200);
  end;

  // 31.07.2017 AH:
  if ("Mat.Löschmarker"<>'') then
    vCol # Set.Col.RList.Deletd
  else if (Mat_rsv_Data:IstInMatSummierbar(true)=false) then  // 17.02.2020
    vCol # _WinColLightYellow;

  if (vCol<>0) then
    Lib_GuiCom:ZLColorLine(gZLList,vCol);


  GV.Num.01 # "Mat.Verfügbar.Gew" + Mat.R.Gewicht;

  Gv.Num.02   # 0.0;
  Gv.Num.03   # 0.0;
  Gv.Num.04   # 0.0;
  Gv.Int.01   # 0;
  Gv.Datum.01 # 0.0.0;
  Gv.Alpha.40 # '';
  if (Mat.R.Auftragsnr<>0) then begin
    vBuf401 # RekSave(401);
    Erx # Auf_Data:Read(Mat.R.Auftragsnr, Mat.R.Auftragspos,n);
    if (Erx>=400) then begin
      Gv.Num.02   # Auf.P.Dicke;
      Gv.Num.03   # Auf.P.Breite;
      Gv.Num.04   # "Auf.P.Länge";
      Gv.Int.01   # Auf.P.Warengruppe;
      Gv.Datum.01 # Auf.P.TerminZusage;
      Lib_Berechnungen:KW_aus_Datum(Auf.P.TerminZusage, var vKW, var vYear);
      Gv.Int.02   # vKW;
      if (Rechte[Rgt_Auf_Preise]) then begin
        if (Auf.P.MEH.Preis='kg') and (Auf.P.PEH=1000) then
          GV.ALpha.40 # anum(Auf.P.Grundpreis,2)+' / t'
        else
          GV.ALpha.40 # anum(Auf.P.Grundpreis,2)+' / '+aint(Auf.P.PEH)+' '+Auf.P.MEH.Preis;
      end;
    end;
    RekRestore(vBuf401);
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
local begin
  Erx : int;
end;
begin
  if (aRecID<>0) then begin
    Erx # RecLink(200,203,1,_recFirst);   // Material holen
  end;
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
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
//  EvtDropEnter
//
//========================================================================
sub EvtDropEnter(
  aEvt                 : event;    // Ereignis
  aDataObject          : int;      // Drag-Datenobjekt
  aEffect              : int;      // Rückgabe der erlaubten Effekte
) : logic;
local begin
  vA      : alpha;
  vFile   : int;
  vMDI    : int;
  vHdl    : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin

    vMDI # Lib_GuiCom:FindMDI(aEvt:Obj);
    vHdl # WinSearch(vMDI, 'NB.Main');

    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    if ((vHdl->wpcustom='AUF') and (vFile=200)) then begin
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN (true);
    end;
	end;

  RETURN false;
end;


//========================================================================
//  EvtDrop
//
//========================================================================
sub EvtDrop(
  aEvt                 : event;    // Ereignis
  aDataObject          : int;      // Drag-Datenobjekt
  aDataPlace           : int;      // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
) : logic;
local begin
  vA      : alpha;
  vFile   : int;
  vID     : int;
  vMDI    : int;
  vHdl    : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin

    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    if (vID=0) then RETURN false;

    vMDI # Lib_GuiCom:FindMDI(aEvt:Obj);
    vHdl # WinSearch(vMDI, 'NB.Main');

    if ((vHdl->wpcustom='AUF') and (vFile=200)) then begin
      WinUpdate(vMDI, _winupdactivate);
      Winfocusset(vMDI, true);
      VarInstance(WindowBonus,cnvIA(vMDI->wpcustom));

      RecRead(200,0,_RecId,vID);

      RecBufClear(203);
      Mat.R.Materialnr      # Mat.Nummer;
      "Mat.R.Stückzahl"     # "Mat.Verfügbar.Stk";
      Mat.R.Gewicht         # "Mat.Verfügbar.Gew";
      "Mat.R.Trägertyp"     # '';
      "Mat.R.TrägerNummer1" # 0;
      "Mat.R.TrägerNummer2" # 0;
      Mat.R.Kundennummer    # Auf.P.Kundennr;
      Mat.R.KundenSW        # Auf.P.KundenSW;
      Mat.R.Auftragsnr      # Auf.P.Nummer;
      Mat.R.AuftragsPos     # Auf.P.Position;
      Mat_Rsv_Data:Neuanlegen();

      App_Main:Refresh();

      RETURN true;
    end;
  end;

  RETURN false;
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
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (gTimer2=aTimerId) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;

   if (StrFind(w_TimerVar,'UEBERNAME',0)>0) then begin
      Uebernahme();
      RETURN true;
    end;
  end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
  end;

  RETURN true;
end;


//========================================================================
//  Uebernahme
//========================================================================
sub Uebernahme()
local begin
  Erx     : int;
  vHdl    : int;
  vMatNr  : int;
end;
begin
  if ( w_Parent != 0 ) then begin
    if ( w_Parent->wpName = GetDialogName( 'Ein.E.Mat.Verwaltung' ) ) then begin // aus Wareneingang
      Erx # RecLink( 501, 506, 1, _recFirst ); // Position holen
      if ( Erx <= _rLocked ) then
        vMatNr # Ein.P.Materialnr;
    end
    else if ( w_Parent->wpName = GetDialogname( 'Lfs.P.LFA.Verwaltung' ) ) then begin // aus Lieferscheinposition
      if ( RecLink( 200, 441, 4, _recFirst ) <=_rLocked ) then
        vMatNr # "Mat.Vorgänger";
    end;
  end;

  
  RecBufClear(203);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Rsv.Copy.Verwaltung',here+':AusInfo',y);
  if (vMatNr<>0) then begin
    vHdl # Winsearch(gMDI,'lb.Kopftext');
    if (vHdl<>0) then vHdl->wpcustom # cnvai(vMatNr);
  end;
  Lib_GuiCom:RunChildWindow(gMDI);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edMat.R.Materialnr') AND (aBuf->Mat.R.Materialnr<>0)) then begin
    RekLink(200,203,1,0);   // Material holen
    Lib_Guicom2:JumpToWindow('Mat.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMat.R.Kommission') AND (aBuf->Mat.R.Kommission<>'')) then begin
    Auf.P.Nummer # BAG.F.Auftragsnummer;
    Auf.P.Position # BAG.F.Auftragspos;
    RecRead(401,1,0);
    Lib_Guicom2:JumpToWindow('Auf.P.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edMat.R.Kundennummer') AND (aBuf->Mat.R.Kundennummer<>0)) then begin
    RekLink(100,203,3,0);   // Kunde holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;

end;


//========================================================================
//========================================================================
//========================================================================