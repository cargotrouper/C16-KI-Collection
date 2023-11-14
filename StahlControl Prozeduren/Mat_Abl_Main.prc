@A+
//==== Business-Control ==================================================
//
//  Prozedur    Mat~Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  14.06.2010  AI  NEU: Etikettentyp
//  12.10.2010  AI  Etikettendruck für MArkierungen
//  12.01.2011  ST  Anker für RecInit hinzugefügt
//  16.03.2011  ST  Anker für "Mat.RecSave.Pre" Hinzugefügt
//  16.01.2012  AI  Kommission Umsetzen für markierte Karten
//  22.03.2012  MS  Anpassung ABLAGE
//  17.10.2014  AH  MatSofortInAblage
//  17.09.2015  ST  Erweiterung "Sub Start"
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB CheckAnalyse (aObjName : alpha; aFieldName : alpha);
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel(opt aSilent : logic; opt aNullen : logic)
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstRecControl(aEvt : event; aRecid : int) : logic;
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen
@I:Def_BAG
define begin
  cTitle :    'Material'
  cFile :     210
  cMenuName : 'Mat.Abl.Bearbeiten'
  cPrefix :   'Mat_Abl'
  cZList :    $ZL.Abl.Material
  cKey :      1

  cDialog     : 'Mat.Ablage'
  cRecht      : Rgt_Material
  cMdiVar     : gMDIMat
end;


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aMatNr   : int;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end;
begin
  if (aRecId=0) and (aMatNr<>0) then begin
    "Mat~Nummer" # aMatNr;
    Erx # RecRead(210,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(210,_recID);
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
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_NoView  # y;

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

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vName : alpha;
  vA    : alpha;
end;
begin
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
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  vNr       : int;
end;
begin
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then // dynamische Pflichtfelder überprüfen
    RETURN false;

  RETURN false;
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
sub RecDel(
  opt aSilent : logic;
  opt aNullen : logic)
begin
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
  vA        : alpha;
  vFilter   : int;
  vSelName  : alpha;
  vSel      : int;
  vQ        : alpha(4000);
  tErx      : int;
  vTmp      : int;
  vHdl      : int;
end;
begin
end;

//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
  vA          : Alpha;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

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
  vHdl       : int;
  vSel       : alpha;
  vI,vJ      : int;
  vX,vY      : float;
  vStk       : int;
  vGew       : float;
  vA         : alpha;
  vBAG       : int;
  vBuf210    : int;
  vBildName  : alpha(1000);
  vTextName  : alpha(1000);
  vDateBegin : date;
  vDateEnd   : date;

  vMarked    : int;
  vMFile     : int;
  vMID       : int;
  vOK        : logic;
  vTmp       : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  case (aMenuItem->wpName) of

    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.Restore' : begin
       if (Rechte[Rgt_Abl_Mat_Restore]) then begin
        if (Msg(210012, '', _WinIcoQuestion, _WinDialogYesNo, 1) = _WinIdYes) then begin
          if (Mat_Abl_Data:RestoreAusAblage("Mat~Nummer")) then begin
            Msg(999998,'',0,0,0);
            gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
          end;
        end;
      end;
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile, "Mat~Anlage.Datum", "Mat~Anlage.Zeit", "Mat~Anlage.User", "Mat~Lösch.Datum", "Mat~Lösch.Zeit", "Mat~Lösch.User", "Mat~Lösch.Grund");
    end;

  end; // case


end;


//========================================================================
//  IsPageActive
//========================================================================
Sub IsPageActive(aName : alpha) : logic;
begin
  RETURN aName<>'NB.Page5';
end


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vName : alpha;
  vTmp  : int;
end;
begin
  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
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

  RecBufCopy(210,200);

  // Sonderfunktion:
 if (aMark) then begin
    if (RunAFX('Mat.EvtLstDataInit','y')<0) then RETURN;
  end
    else if (RunAFX('Mat.EvtLstDataInit','n')<0) then RETURN;
/***/
  if (aMark=n) then begin
    if ("Mat~Löschmarker"='*') then
      Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
    else if ("Mat~Status">c_Status_bisEK) and ("Mat~Status"<c_Status_BAGOutput) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.inBAG);
    else if ("Mat~Status">=c_Status_gesperrt) or (RecLinkInfo(401,210,22,_reccount)>0) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Gesperrt)
    else if ("Mat~Status">=c_Status_bestellt) and ("Mat~Status"<=c_Status_bisEK) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Bestellt)
    else if ("Mat~Kommission"<>'') then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Kommissi)
    else if ("Mat~Reserviert.Gew" > 0.0) and ("Mat~Verfügbar.Gew" <= 0.0) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.Reserv);
    else if ("Mat~Reserviert.Gew" > 0.0) then
      Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.TeilRes)
    else if ("Mat~EigenmaterialYN") then
          Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.frei)
        else
        Lib_GuiCom:ZLColorLine(gZLList, Set.Mat.Col.fremd);
  end;

  Erx # RecLink(100, 210, 3, _recFirst); // Erzeuger holen
  if(Erx > _rLocked) then
    RecBufClear(100);

  GV.Alpha.02 # '';
  if ("Mat~BestellTermin"<>0.0.0) then Gv.ALpha.02 # cnvad("Mat~BestellTermin");

  GV.Alpha.01 # Adr.Stichwort;

  GV.Num.01 # "Mat~Bestand.Gew" + "Mat~Bestellt.Gew" -  "Mat~Reserviert2.Gew";

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
  vA  : alpha(210);
end;
begin

  RecRead(gFile,0,_recid,aRecID);
  RecBufCopy(210,200);

  RefreshMode(y);   // falls Menüs gesetzte werden sollen

  // Ankerfunktion:
  if (RunAFX('Mat.EvtLstSelect','')<0) then RETURN true;


  if ("Mat~Löschmarker"='*') then
    vA # Translate('gelöscht')
  else if ("Mat~Status"=c_Status_bestellt) then
    va # Translate('bestellt')
  else if ("Mat~Status"=c_Status_EKVSB) then
    vA # Translate('VSB-Einkauf')
  else if ("Mat~Kommission"<>'') then
    vA # Translate('kommissioniert')
  else if ("Mat~Reserviert.Gew">0.0) then
    vA # Translate('reserviert')
  else
    vA # '';

  Erx # RecLink(820,210,9,0); // Status holen
  Erx # RecLink(819,210,1,0); // Warengruppe holen
  vA # vA + ', ' + AInt("Mat~Status") + ', ' + "Mat.Sta.Bezeichnung" + ', '
       + AInt("Mat~Warengruppe") + ' ' + Wgr.Bezeichnung.L1;

  $lb.Mat.Info1->wpcaption # "Mat~Bemerkung1";
  $lb.Mat.Info2->wpcaption # vA;

  if ("Mat~EigenmaterialYN"=n) then
    $lb.Mat.Info3->wpcaption # Translate('Fremdmaterial')
  else
    $lb.Mat.Info3->wpcaption # '';

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

  if (gZLList->wpDbSelection<>0) then begin // Filter deaktivieren
/***
    SelClose(gZLList->wpDbselection);
    gZLList->wpDbselection # 0;
    Seldelete(210,myTmpSel);
      SelDelete(gFile,SelektionTmp[gFile]);
      SelektionTmp[gFile] # '';
***/
//    $Mnu.Filter.Lieferant->wpMenuCheck # false;
//    $Mnu.Filter.Lieferant->wpcaption # Translate('&Lieferant');
  end;

  RETURN true;
end;

/***
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

  if (gTimer2=aTimerId) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
    if ($edMat.LagerStichwort->wpcustom='next') then begin
      $edMat.LagerStichwort->wpcustom # '';
      Erx # RecLink(100,210,5,0);
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLagerStichwort2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    end
  else begin
    App_Main:EvtTimer(aEvt,aTimerId);
  end;

  RETURN true;
end;
***/

//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect     : rect;
end
begin

  // Workaround JEPSEN pennt....
//  if (DbaLicense(_DbaSrvLicense)='CE105655MU') then Winsleep(100);


  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  if (aFlags & _WinPosSized != 0) then begin
    vRect           # gZLList->wpArea;
//    vRect:right     # aRect:right-61;
//    vRect:bottom    # aRect:bottom-210;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28-60;
    gZLList->wparea # vRect;

    Lib_GUiCom:ObjSetPos($lb.Mat.Info1, 0, vRect:bottom+8);
    Lib_GUiCom:ObjSetPos($lb.Mat.Info2, 0, vRect:bottom+8+28);
    Lib_GUiCom:ObjSetPos($lb.Mat.Info3, 720, vRect:bottom+8);

    //$lb.Mat.Info1->wpautoupdate # false;
    //$lb.Mat.Info1->wpcolBkg # RGB(cnvif(random()*250.0),0,0);
    //vRect           # $lb.Mat.Info1->wpArea;
    //vRect:right     # aRect:right-aRect:left-4;
    //vRect:bottom    # aRect:bottom-aRect:Top-28-60;
    //$lb.Mat.Info1->wparea # vRect;
  end;

//  gZLList->wpAreaRight  # gMDI->wpAreaRight-58;
//  gZLList->wpAreaBottom # gMDI->wpAreabottom-142;
//debug(cnvai(gZLList->wpAreaBottom));
//  gZLList->winupdate(_WinUpdActivate);
	RETURN (true);
end;


//========================================================================
//========================================================================