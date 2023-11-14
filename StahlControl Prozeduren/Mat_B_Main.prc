@A+
//==== Business-Control ==================================================
//
//  Prozedur    Mat_B_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  05.08.2016  AH  AFX: Mat.Mnu.Bestandsänderung
//  2022-06-28  AH  ERX
//  2022-09-05  AH  Fix: Bestandsänderungen ändern nichts am Preis
//  2023-01-26  MR  Edit Bestandsänderugn berücksichtig jetzt auch die Menge 2465/17
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
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB BestandsAenderung();
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle :    'Bestandsbuch'
  cFile :     202
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Mat_B'
  cZList :    $ZL.Bestandsbuch
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

  SetStdAusFeld('edxxxxxx'        ,'xxxxxx');

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
)
local begin
  vTmp  : int;
end;
begin

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
  $edMat.A.TerminStart->WinFocusSet(true);

  if (Mode=c_ModeNew) then Mat.B.Materialnr # Mat.Nummer;
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
    Mat.B.Anlage.Datum  # Today;
    Mat.B.Anlage.Zeit   # Now;
    Mat.B.Anlage.User   # gUserName;
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

  // Button & Menüs immer sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;

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

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Mat.B.Anlage.Datum, Mat.B.Anlage.Zeit, Mat.B.Anlage.User);
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

  /*case (aEvt:Obj->wpName) of
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
  end;*/

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
// BestandsAenderung
//
//========================================================================
sub BestandsAenderung();
local begin
  Erx       : int;
  vGew      : float;
  vStk      : int;
  vNetto    : float;
  vBrutto   : float;
  vA        : alpha;
  vDat      : date;
  vDiff     : float;
  vDiffM    : float;
  vMenge    : float;
  vTim      : time;
  vPreis    : float;
  vPreisPM  : float;
end;
begin

  if (RunAFX('Mat.Mnu.Bestandsänderung','')<>0) then RETURN;


  // Material sperren...
  Erx # RecRead(200,1,_recLock);
  if (Erx<>_rOK) then begin
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;
  PtD_Main:Memorize(200);

  vStk      # Mat.Bestand.Stk;
  vNetto    # Mat.Gewicht.Netto;
  vBrutto   # Mat.Gewicht.Brutto;
  vMenge    # Mat.Bestand.Menge;

  vPreis    # Mat.EK.Preis;
  vPreisPM  # Mat.EK.PreisProMEH;

  vDat      # today;
  if (Dlg_Standard:Mat_Bestand(var vStk, var vNetto, var vBrutto, var vPreis, var vMenge, var vA, var vDat,n, '')=false) then begin
    RecRead(200,1,_recUnlock);
    PtD_Main:Forget(200);
    RETURN;
  end;
  if (vDat=today) then vTim # now;
  if (vDat<Mat.Eingangsdatum) or
    ((vDat>Mat.Ausgangsdatum) and (MAt.Ausgangsdatum<>0.0.0)) then begin
    Msg(202000,'',0,0,0);
    RecRead(200,1,_recUnlock);
    PtD_Main:Forget(200);
    RETURN;
  end;

  Erx # RecLink(818,200,10,_RecFirst);    // Verwiegungsart holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

/*
  10t = 10000kg = 5Stk
  8000€ abs = 800/t, 0,8/kg = 1600/stk
*/

  // 10.04.2013 VORLÄUFIG:
  if(Mat.MEH = 't' or Mat.MEH = 'kg') then
    vMenge # Mat_Data:MengeVorlaeufig(vStk, vNetto, vBrutto);
/***    2022-09-05  AH : reine Mengenänderungen haben KEINE Auswirkung auf Grundpreis!!!
  if (VwA.NettoYN) then
    vPreisPM  # vNetto * (vPreis / 1000.0)
  else
    vPreisPM  # vBrutto * (vPreis / 1000.0);
  DivOrNull(vPreisPM, vPreisPM, vMenge, 2);   // a=b/c
***/
//  DivOrNull(vPreisPM, vWert, vMenge, 2);   // a=b/c
//  if (VwA.NettoYN) then
//    DivOrNull(vPreis, vWert, vNetto, 2)
//  else
//    DivOrNull(vPreis, vWert, vbrutto, 2);
//debugx(anum(vWert,2)+'abs = '+anum(vPreisPM,2)+' pro '+Mat.MEH+' bei '+anum(vMenge,0)+Mat.MEH);

  TRANSON;

  vDiff   # Mat.Bestand.Gew;
  vDiffM  # Mat.Bestand.Menge;

  // Ankerfunktion
  RunAFX('Mat.Bestandsänderung',AInt(vStk)+'|'+ANum(vNetto,Set.Stellen.Gewicht)+'|'+ANum(vBrutto,Set.Stellen.Gewicht)+'|'+ANum(vPreis,2));
  Mat.Bestand.Stk     # vStk;
  Mat.Gewicht.Netto   # vNetto;
  Mat.Gewicht.Brutto  # vBrutto;
  Mat.Bestand.Menge   # vMenge;
//  Mat.EK.Preis        # vPreis;     2022-09-05  AH
//  Mat.EK.PreisProMEH  # vPreisPM;   2022-09-05  AH

  if ( VWa.NettoYN ) then
    Mat.Bestand.Gew # Mat.Gewicht.Netto;
  else
    Mat.Bestand.Gew # Mat.Gewicht.Brutto;
  Erx # Mat_Data:Replace(_recUnlock,'MAN');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RecRead(200,1,_recUnlock);
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;
  vDiff   # Mat.Bestand.Gew - vDiff;
  vDiffM  # Mat.Bestand.Menge - vDiffM;
  //stk, gew, menge, p,ppm
  Mat_Data:Bestandsbuch(vStk - Protokollbuffer[200]->Mat.Bestand.Stk,
                        Mat.Bestand.Gew - Protokollbuffer[200]->Mat.Bestand.Gew,
                        Mat.Bestand.Menge - Protokollbuffer[200]->Mat.Bestand.Menge,
                        0.0, 0.0,
                        // 2022-09-05 AH vPreis - Protokollbuffer[200]->Mat.EK.Preis,                        vPreisPM - Protokollbuffer[200]->Mat.EK.PreisProMEH,
                        vA, vDat, vTim, '');

  // eigene Schrottumlage...
  if ("Set.Mat.!InternUmlag"=false) and ((vDiff<>0.0) or (vDiffM<>0.0)) then begin
    RecBufClear(204);
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Aktionstyp    # c_Akt_Mat_Umlage;
    Mat.A.Bemerkung     # c_AktBem_Mat_Umlage;
    Mat.A.Aktionsdatum  # today;
    Mat.A.Terminstart   # Mat.A.Aktionsdatum;
    Mat.A.Terminende    # Mat.A.Aktionsdatum;
    Mat.A.Adressnr      # 0;
    if (Mat.Bestand.Gew<>0.0) then
      Mat.A.KostenW1      # Rnd(- (vDiff * Mat.EK.Effektiv / Mat.Bestand.Gew),2);
    if (Mat.Bestand.Menge<>0.0) then
      DivOrNull(Mat.A.KostenW1ProMEH, -(vDiffM * Mat.EK.EffektivProME), Mat.Bestand.Menge,2);
    Mat_A_Data:Insert(0,'AUTO')
  end;

  PtD_Main:Compare(200);

  // Preis vererben...
  //Mat_Data:VererbeDaten(y,n);
  if (Mat_A_Data:Vererben()=false) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN;
  end;

  TRANSOFF;

  Msg(999998,'',0,0,0);
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================