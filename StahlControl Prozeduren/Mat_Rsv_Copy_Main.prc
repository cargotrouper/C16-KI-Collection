@A+
//==== Business-Control ==================================================
//
//  Prozedur    Mat_Rsv_Copy_Main
//                  OHNE E_R_G
//  Info        Dialog zum Übernehmen der Reservierungen von Mat. nach Mat.
//
//              ZIEL ist momentanes Material
//              QUELLE ist entweder Mat. aus $lb.Kopftext->wpcustom
//              oder alles markierte
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  10.04.2013  AI  MatMEH
//  2022-06-28  AH  ERX
//  2023-07-06  ST  Anzeige der Referenzmengen des Zielmaterials 2396/110/1
//
//  Subprozeduren
//    SUB Res2DataList();
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt: event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB EvtLstLineEdited (aDataList : int; aColumn : int; aRow : int);
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
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    sub EvtPosChanged ( aEvt : event; aRect : rect; aClientSize : point; aFlags : int ) : logic
//    SUB StartEdit();
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Reservierungsübernahme'
  cFile :     203
//  cMenuName : 'Mat.Rsv.Copy.Bearbeiten'
  cMenuName : 'Std.DL.Bearbeiten'
  cPrefix :   'Mat_Rsv_Copy'
//  cZList :    $dl.Mat.Rsv.Copy
  cZList :    $dl.List
  cKey :      1

  cDLRes      : 1

  cDLStkRes   : 6
  cDLGewRes   : 7
  
  
  cDLStk      : 14
  cDLGew      : 15
  cDLDel      : 16
end;

declare EvtLstSelect(aEvt : event; aRecID : int) : logic

//========================================================================
// Res2DataList
//
//========================================================================
sub Res2DataList();
local begin
  Erx     : int;
  vHdl    : int;
  vKW     : word;
  vYear   : word;
  vBuf401 : int;
end;
begin
  vHdl # cZList;
  $clm.Dicke->wpFmtPostComma  # Set.Stellen.Dicke;
  $clm.Breite->wpFmtPostComma # Set.Stellen.Breite;
  $clm.Laenge->wpFmtPostComma # "Set.Stellen.Länge";
//debug('x:'+cnvai(mat.nummer));
  Erx # RecLink(203,200,13,_recFirst);
  WHILE (Erx<=_rLocked) do begin
//debug('ins');
    vHdl->WinLstDatLineAdd(Mat.R.Reservierungnr);
    vHdl->WinLstCellSet(Mat.R.Materialnr,2);
    vHdl->WinLstCellSet(Mat.R.Kommission,3);
    vHdl->WinLstCellSet(Mat.R.Kundennummer,4);
    vHdl->WinLstCellSet(Mat.R.KundenSW,5);
    vHdl->WinLstCellSet("Mat.R.Stückzahl",6);
    vHdl->WinLstCellSet(Mat.R.Gewicht, 7);


    vBuf401 # RekSave(401);
    if (Mat.R.Auftragsnr<>0) then begin
      Erx # Auf_Data:Read(Mat.R.Auftragsnr, Mat.R.Auftragspos,n);
      if (Erx<400) then RecBufClear(401);
      /* Prj 1330/72 */
      vHdl->WinLstCellSet(Auf.P.TerminZusage, 8);
      if (Auf.P.Termin1W.Art = 'KW') then
        vKW # Auf.P.TerminZ.Zahl;
      else
        Lib_Berechnungen:KW_aus_Datum(Auf.P.TerminZusage, var vKW, var vYear);
      vHdl->WinLstCellSet(vKW, 9);
      vHdl->WinLstCellSet(Auf.P.Warengruppe,10);
      vHdl->WinLstCellSet(Auf.P.Dicke,11);
      vHdl->WinLstCellSet(Auf.P.Breite,12);
      vHdl->WinLstCellSet("Auf.P.Länge",13);
    end;
    RekRestore(vBuf401);

    Erx # RecLink(203,200,13,_recNext);
  END;
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
  //gZLList   # cZList; // MS 13.01.2010 Prj. 1330/72
  gZLList   # 0;//cZList;
  w_nolist # y;
  gKey      # cKey;

  SetStdAusFeld('edxxxxxx'        ,'xxxxxx');

  App_Main:EvtInit(aEvt);
  Mode # c_modeEdList;

/**
  vHdl # cZList;
  vMat # Mat.Nummer;
  if ($lb.KopfText->wpcustom<>'') then begin
    Mat.Nummer # cnvia($lb.KopfText->wpcustom);
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then begin
      Res2DataList();
    end;
    end;
  else begin
    // Ermittelt das erste Element der Liste
    vItem # gMarkList->CteRead(_CteFirst);
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile = 200) then begin
        RecRead(200,0,_RecId,vMID);
        Res2DataList();
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;
  end;

  Mat.Nummer # vMat;
  RecRead(200,1,0);
***/
//  cZList->wpCurrentInt # 1;
//  cZList->winupdate(_Winupdon, _WinLstFromFirst);
//  EvtLstSelect(aEvt, 1);

  Lib_GuiCom:RecallList(cZList);
end;


//========================================================================
// EvtMdiActivate
//
//========================================================================
sub EvtMdiActivate(
	aEvt         : event     // Ereignis
) : logic
local begin
  Erx     : int;
  vHdl    : int;
  vMat    : int;
  vItem   : int;
  vMID    : int;
  vMFile  : int;
  vZeile  : int;
  
  vMatInfoTop : alpha(1000);
end;
begin

  vMatInfoTop  #  AInt(Mat.Nummer) + ',  ' +  "Mat.Güte" + ', ' + ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' + ANum(Mat.Breite,Set.Stellen.Breite);

  if ($lb.KopfText->wpcustom<>'') then begin
    //$lb.Kopftext->wpcaption # Translate('Übernahme von Mat.')+$lb.Kopftext->wpcustom+' '+Translate('nach Mat.')+AInt(Mat.Nummer);
    $lb.Kopftext->wpcaption # Translate('Übernahme von Mat.')+Str_ReplaceAll($lb.Kopftext->wpcustom,'.','')+' '+Translate('nach Mat.')+ vMatInfoTop;
    end
  else begin
    //$lb.Kopftext->wpcaption # Translate('Übernahme von markiertem Material nach Mat.')+AInt(Mat.Nummer);
    $lb.Kopftext->wpcaption # Translate('Übernahme von markiertem Material nach Mat.')+vMatInfoTop;
  end;

  vHdl # cZList;
  vMat # Mat.Nummer;
  if ($lb.KopfText->wpcustom<>'') then begin
    Mat.Nummer # cnvia($lb.KopfText->wpcustom);
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then begin
      Res2DataList();
      if (vZeile=0) then vZeile # 1;
    end;
    end;
  else begin
    // Ermittelt das erste Element der Liste
    vItem # gMarkList->CteRead(_CteFirst);
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile = 200) then begin
        RecRead(200,0,_RecId,vMID);
        Res2DataList();
        if (vZeile=0) then vZeile # 1;
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;
  end;

  Mat.Nummer # vMat;
  RecRead(200,1,0);


  if (vZeile<>0) then begin
    cZList->wpCurrentInt # vZeile;
    cZList->winupdate(_Winupdon, _WinLstFromFirst);
    EvtLstSelect(aEvt, 1);
  end;


  // ST 2023-07-06 2396/110/1:  Anzeige der Mengen des Zielmaterials als Userhilfe
  $lbMat.Rsv.Copy.Info1->wpCaption # 'Mat. verfügbar: ' + ANum("Mat.Verfügbar.Gew",Set.Stellen.Gewicht) + ' kg';
  $lbMat.Rsv.Copy.Info2->wpCaption # 'Bereits reserviert: ' + ANum(Mat.Reserviert.Gew,Set.Stellen.Gewicht) + ' kg';

//  cZList->wpCurrentInt    # 1;
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
//  $...->WinFocusSet(true);
end;


//========================================================================
//  EvtLstLineEdited
//              Sonderfunktion der Lib_Datalist
//========================================================================
sub EvtLstLineEdited (
  aDataList       : int;
  aColumn         : int;
  aRow            : int;
)
local begin
  vHdl  : int;
  vX,vY : float;
end;
begin

  vHdl # cZList;
  // Rest löschen?
  vHdl->WinLstCellGet(vX, 7,_WinLstDatLineCurrent);
  vHdl->WinLstCellGet(vY,cDLGew,_WinLstDatLineCurrent);
  if (vX-vY>0.0) then begin
    if (msg(203004,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then
      vHdl->WinLstCellSet(y,cDLDel,_WinLstDatLineCurrent)
    else
      vHdl->WinLstCellSet(n,cDLDel,_WinLstDatLineCurrent);
    end
  else begin  // "Rest<=0" löschen
    vHdl->WinLstCellSet(y,cDLDel,_WinLstDatLineCurrent)
  end;

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
begin
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
sub RecDel()
local begin
  vHdl  : int;
  vRes  : int;
end;
begin
  RETURN;
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
  end;

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
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.DL.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Mat_R_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.DL.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Mat_R_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.DL.Delete');
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
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
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
//    'Delete' : todo('X');
    'bt.xxxxx' :   Auswahl('...');
    'bt.xxxxx' :   Auswahl('...');
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
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
begin
//  $lbMat.Rsv.Copy.Info1->wpcaption # 'asd'+anum(random(),10);
  if (RunAFX('Mat.Rsv.Copy.EvtLstSelect','')<0) then RETURN true;
//  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
  RETURN true;
end;





//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx     : int;
  vHdl    : int;
  vMax    : int;
  vX      : int;
  vMat    : int;
  vRes    : int;
  vStk    : int;
  vGew    : float;
  vMenge  : float;
  vDelJN  : logic;
  vSumGew : float;
end;
begin

  vMat # Mat.Nummer;
  vHdl # cZList;
  vMax # vHdl->WinLstDatLineInfo(_WinLstDatInfoCount);
  vHdl->wpAutoupdate # n;
  vX  # 0;
  WHILE (vX<vMax) do begin
    vX # vX + 1;
    vHdl->wpcurrentint # vX
    vHdl->WinLstCellGet(vRes,cDLRes,_WinLstDatLineCurrent);
    vHdl->WinLstCellGet(vStk,cDLStk,_WinLstDatLineCurrent);
    vHdl->WinLstCellGet(vGew,cDLGew,_WinLstDatLineCurrent);
    vHdl->WinLstCellGet(vDelJN,cDLDel,_WinLstDatLineCurrent);
    vSumGew # vSumGew + vGew;
  END;

  if (vSumGew=0.0) then begin
    Lib_GuiCom:RememberList(cZList);
    RETURN true;
  end;

  // zu viel reserviert?
  if (vSumGew>Mat.Bestand.Gew) then begin
    if (msg(203005,'',_WinIcoWarning,_WinDialogOkCancel,2)=_WinIdCancel) then RETURN false;
  end;

  // Umbuchungen übernehmen?
  Erx # msg(203001,'',0,_WinDialogYesNoCancel,1);
  if (Erx=_WinIdCancel) then begin
    mode # c_ModeList;    // in der Liste bleiben
    vHdl->wpAutoupdate # y;
    RETURN false;
  end;
  if (Erx=_WinIdNo) then begin
    Lib_GuiCom:RememberList(cZList);
    RETURN true;
  end;


  TRANSON;

  vX  # 0;
  WHILE (vX<vMax) do begin
    vX # vX + 1;
    vHdl->wpcurrentint # vX
    vHdl->WinLstCellGet(vRes,cDLRes,_WinLstDatLineCurrent);
    vHdl->WinLstCellGet(vStk,cDLStk,_WinLstDatLineCurrent);
    vHdl->WinLstCellGet(vGew,cDLGew,_WinLstDatLineCurrent);
    vHdl->WinLstCellGet(vDelJN,cDLDel,_WinLstDatLineCurrent);

    // 10.04.2013 VORLÄUFIG:
    vMenge # Mat_Data:MengeVorlaeufig(vStk, vGew, vGew);

    if (vStk<>0) or (vGew<>0.0) then begin
      if (Mat_Rsv_Data:Takeover(vRes, vMat, vStk, vGew, vMenge, vDelJN)=n) then begin
        TRANSBRK;
        vHdl->wpAutoupdate # y;
        msg(203002,'',0,0,0);
        RETURN false;
      end;
      Erx # RecLink(200,501,13,_recLock);  // Bestellkarte holen
      Mat_Rsv_data:RecalcAll();
    end;
  END;

  TRANSOFF;
  msg(203003,'',0,0,0);

  Lib_GuiCom:RememberList(cZList);
  RETURN true;
end;


//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged ( aEvt : event; aRect : rect; aClientSize : point; aFlags : int ) : logic
local begin
  vRect : rect;
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  if ( aFlags & _winPosSized != 0 ) then begin
    vRect           # cZList->wpArea;
    vRect:right     # aRect:right  - aRect:left - 4;
    vRect:bottom    # aRect:bottom - aRect:top - 28 - 64;
    cZList->wpArea # vRect;

    Lib_GuiCom:ObjSetPos( $lbMat.Rsv.Copy.Info1, 0, vRect:bottom + 8  );
    Lib_GuiCom:ObjSetPos( $lbMat.Rsv.Copy.Info2, 0, vRect:bottom + 8 +28 );
//    Lib_GuiCom:ObjSetPos( $lbAuf.P.Info2, 0, vRect:bottom + 8 + 28 );
  end;

	RETURN true;
end;


//========================================================================
// StartEdit
//
//========================================================================
sub xStartEdit();
begin
  //Lib_dataList:StartListEdit(cZList);//, 1, _winLstEditClearChanged );
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================
