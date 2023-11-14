@A+
//==== Business-Control ==================================================
//
//
//  Prozedur    Anh_Main
//                  OHNE E_R_G
//  Info
//
//
//  27.11.2006  AI  Erstellung der Prozedur
//  06.03.2014  AH  Alle lokalen Daten werden in das Netzwerkarchiv kopiert
//  23.04.2014  AH  für BLOBDB gängig gemacht
//  04.03.2015  ST  Import von Dateien in Blobs: Maximale Namenlänge auf 60 Zeichen
//  23.02.2018  AH  Neu: direktes Drag&Drop von Anhängen aus Mails
//  25.06.2019  AH  Umbau für SubProjekte
//  03.02.2022  AH  ERX und Fix für doppelte Eintäge
//  28.03.2022  AH  Edit: EvtDrop mit mehr opt. Parametern
//  2022-09-15  AH  Proj. 2429/208
//  2022-09-19  ST  Edit: Sonderweg BSC: Immer kopieren, anstatt linken Proj. 2429/208
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
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtMouseItemStart
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtDropEnter...
//    SUB EvtDrop...
//    SUB EvtDragInit,,,
//    SUB EvtDragTerm...
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle      : 'Anhänge'
  cFile       : 916
  cMenuName   : 'Anh.Bearbeiten'
  cPrefix     : 'Anh'
  cZList      : $ZL.Anhaenge
  cKey        : 1

  cDBA        : _BinDBA3
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

  if (Set.ExtArchiev.Path='CA1xxx') then begin
    $edAnh.File->wpcustom # '_N';
    $bt.File->wpcustom # '_N';
  end
  else begin
    SetStdAusFeld('edAnh.File' ,'File');
  end;
  

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

  if (Mode=c_ModeView) then
    Lib_GuiCom:Enable($bt.Oeffnen)
  else
    Lib_GuiCom:Disable($bt.Oeffnen);

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
  // Focus setzen auf Feld:
  if (Mode=c_ModeNew) then
    $edAnh.File->WinFocusSet(true)
  else
    $teAnh.Bemerkung->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vBuf916   : int;
  vFileName : alpha(1000);
  vA        : alpha(1000);
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

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
//    if (Anh.lfdNr=0) then begin
//      vBuf916 # RekSave(916);
//      Erx # RecRead(916,gZLList->wpdbSelection,_recLast);
//      if (Erx<>_rOK) then vNr # 1
//      else vNr # Anh.lfdNr + 1;
//      RekRestore(vBuf916);
//    end;

    Anh.Datei         #  cnvia($lb.key1->wpcustom);
    Anh.Key           #  $lb.key2->wpcustom;
//    Anh.lfdnr         # vNr;

    // 2022-09-15 AH Proj. 2429/208
    if (Set.Installname='BSC') then begin    // immer kopieren
      vFilename # Anh.File
      // lokale Datei?? -> dann kopieren
      if (StrCut(vFilename,2,1)=':') then begin
        vA # StrCut(vFilename,1,1);
//        if (Lib_FileIO:IsNetworkdrive(vA)=false) then begin
          vA # FsiSplitname(vFilename, _FsiNameNE);
          vA # Anh_Data:FindArchivName(vA, Anh.Datei, Anh.Key);
          Lib_FileIO:FsiCopy(vFilename, vA, n);
          Anh.File # vA;
//        end;
      end;
    end;

    Anh_Data:Insert();
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
  Erx   : int;
  v916  : int;
end;
begin

  // KEINE Verknüpfung?
  if (Anh.Link.Datei=0) and (Anh.ID<>0) then begin
    v916 # RekSave(916);
    Anh.Link.Datei      # Anh.Datei;
//    Anh.Link.Key        # Anh.Key;
//    Anh.Link.lfdNr      # Anh.lfdnr;
//    Erx # RecRead(916,2,0);
    Anh.Link.ID  # Anh.ID;
    Erx # RecRead(916,2,0);
    if (Erx<=_rMultikey) then begin
      RekRestore(v916);
      Msg(916003,'',0,0,0)
      RETURN;
    end;
/***  25.05.2020 AH
    Erx # RecRead(916,4,0);
    if (Erx<=_rMultikey) then begin
      if (Anh.Link.ID=Anh.ID) then begin
        Erx # RecRead(916,4,0);
        if (Erx<=_rMultikey) then begin
          RekRestore(v916);
          Msg(916003,'',0,0,0)
          RETURN;
        end;
      end;
    end;
***/
    RekRestore(v916);
  end;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    if (RekDelete(gFile,0,'MAN')=_rOK) then
      Anh_Data:Delete();
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
  vA    : alpha;
end;

begin

  case aBereich of
    'File' : begin
      Anh.File # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', '');
      RefreshIfm('edAnh.File');
    end;
  end;

end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Anh_Anlegen]=n) or
      (Set.ExtArchiev.Path='CA1xxx');
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Anh_Anlegen]=n) or
      (Set.ExtArchiev.Path='CA1xxx');

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Anh_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Anh_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Anh_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Anh_Loeschen]=n);

  vHdl # gMdi->WinSearch('Scan');
  if (vHdl <> 0) then
    vHdl->wpDisabled #(Rechte[Rgt_Anh_Anlegen]=n) or (Mode<>c_ModeList);
  vHdl # gMdi->WinSearch('Mnu.Scan');
  if (vHdl <> 0) then
    vHdl->wpDisabled #(Rechte[Rgt_Anh_Anlegen]=n) or (Mode<>c_ModeList);
  vHdl # gMdi->WinSearch('Mnu.Scan.Settings');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

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

    'Mnu.Scan'  : begin
      if (Anh_Data:StartScan(cnvia($lb.key1->wpcustom), $lb.key2->wpcustom)) then begin
        SelRecInsert(gZLList->wpDbSelection,916);
        gZLList->winupdate(_winupdon, _WinLstFromFirst);
      end;
    end;


    'Mnu.Scan.Settings' : Anh_Data:StartScanSettings();


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Anh.Anlage.Datum, Anh.Anlage.Zeit, Anh.Anlage.User);
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
  vgzList : int;    // ST 2020-09-17 Fix nach Externem Scannen
end
begin


  if (aEvt:obj->wpname='bt.Oeffnen')  then begin
    Anh_Data:Execute();
  end;

  if (aEvt:obj->wpname='Scan')  then begin
    vgzList # gZLList;
    if (Anh_Data:StartScan(cnvia($lb.key1->wpcustom), $lb.key2->wpcustom)) then begin
      if (gZLList <> vgzList) then
        gZLList # vgzList;
      SelRecInsert(gZLList->wpDbSelection,916);
      gZLList->winupdate(_winupdon, _WinLstFromFirst);
    end;
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.File'     :   Auswahl('File');
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
//  EvtMouseItemStart
//                Mausklicks in Listen
//========================================================================
sub EvtMouseItemStart(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin

  // Doppelklick auf Spalte "Datei" -> Öffnet Datei
  if (aButton & _WinMouseDouble > 0)  AND
     (aHit = _WinHitLstView) AND
     (aId <> 0) AND
     (aItem->wpCaption = 'Datei') then begin

    RecRead(916,0,0,aID);

    Anh_Data:Execute();
    RETURN false;
  end;


  RETURN App_Main:EvtMouseItem(aEvt,aButton,aHit,aItem,aID);
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
  if (Anh.ZuID=Anh.ID) then begin
//    Lib_GuiCom:ZLColorLine(gZLList, _WinColWhite)
    Gv.Alpha.01 # Anh.Bemerkung;
  end
  else begin
//    Lib_GuiCom:ZLColorLine(gZLList, _WinColLightGray);
    Gv.Alpha.01 # StrCut('   '+Anh.Bemerkung,1,250);
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
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
//  EvtDtopEnter
//
//========================================================================
sub EvtDropEnter(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aEffect              : int;      // Rückgabe der erlaubten Effekte
) : logic;
begin

  if (Rechte[Rgt_Anh_Anlegen]) then
    aEffect # _WinDropEffectCopy | _WinDropEffectMove | _WinDropEffectLink
  else
    aEffect # _WinDropEffectNone;

  RETURN(true);
end;

//========================================================================
//========================================================================
sub BestimmeLfdNr()
local begin
  Erx     : int;
  v916    : int;
  vNr     : int;
  vFilter : int;
end;
begin

  if (Anh.LfdNr=0) then Anh.LfdNr # 1;
  v916 # RekSave(916);

  vFilter # RecFilterCreate(916,5);
  vFilter->RecFilterAdd(1,_FltAND,_FltEq, Anh.Datei);
  vFilter->RecFilterAdd(2,_FltAND,_FltEq, Anh.Key);
  Erx # RecRead(916,5,_recLast, vFilter);
  RecFilterDestroy(vFilter);
  if (Erx>_rMultiKey) then vNr # 1
  else vNr # Anh.LfdNr + 1;

  RekRestore(v916);
  Anh.LfdNr # vNr;
end;


//========================================================================
//  EvtDrop
//
//========================================================================
sub EvtDrop(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aDataPlace           : handle;   // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
  opt aDatei            : int;
  opt aKey              : alpha;
  opt aTyp              : alpha;
  opt aName             : alpha;
) : logic;
local begin
  Erx         : int;
  vAfx        : int;
  vHdl        : int;
  vWin        : int;
  vDataFormat : int;
  vFileList   : int;
  vListObj    : int;
  vFilename   : alpha(2000);
//  vNr         : int;
  vData       : handle;
  vList       : handle;
  vMemObj     : handle;
  vFile       : handle;
  vPath       : alpha(4000);
  vPath2      : alpha(4000);
  vA          : alpha;
  vDBACon : int;
  vBlobID     : int;
  vOK         : logic;
  vID         : int;
  v916        : int;
  vI          : int;

  vTmp        : alpha;
  vExists     : logic;
end;
begin

  if (Rechte[Rgt_Anh_Anlegen]=false) then RETURN false;

  if (aDatei=0) then begin
    aDatei  # cnvia($lb.key1->wpcustom);
    aKey    # $lb.key2->wpcustom;
  end;
  
  if Lib_SFX:Check_AFX('DMS.Drop') and AFX.Prozedur <> '' then
  begin
  
    vAfx # Call(AFX.Prozedur, aEvt, aDataObject, aDataPlace, aEffect, aMouseBtn, aDatei, aKey, aTyp, aName);
    
    // falls Anker-Rückgabewert Ersetzung fordert, kann hier returned werden, also keine STD Funktionalität:
    if vAfx < 0 then
    begin
    
      // angezeigte Liste refreshen
      App_Main:Refresh();
        
      RETURN(true);// Ermitteln der vorhandenen Daten
      
    end
  end

// Outlookkmail: Text + Content

//if (aDataObject->wpFormatEnum(_WinDropDataFile)) then debugx('file');
//if (aDataObject->wpFormatEnum(_WinDropDataUser)) then debugx('user');
//if (aDataObject->wpFormatEnum(_WinDropDataContent)) then debugx('conte');
//if (aDataObject->wpFormatEnum(_WinDropDataText)) then debugx('text');
//if (aDataObject->wpFormatEnum(_WinDropDatartf)) then debugx('rtf');
//debugx(aDataObject->wpcustom);

  if (aDataObject->wpFormatEnum(_WinDropDataText)) and (aDataObject->wpcustom='vonSC|Blob') then begin
    // in BLOB-DB aufnehmen?
    if (Set.ExtArchiev.Path='CA1') then begin
      Anh_Data:DragDrop('Blob|'+aDataObject->wpname, aDatei, aKey, '', 'COPY', aEvt:obj);
    end;
  end;

  if (aDataObject->wpFormatEnum(_WinDropDataText)) and (aDataObject->wpcustom='vonSC|916') then begin
    // in BLOB-DB aufnehmen?
    if (Set.ExtArchiev.Path='CA1') then begin
      if (aDatei=0) then begin
        // 05.10.2020 AH: Zielfenster Daten bestimmen...
        vWin # Wininfo(aEvT:obj, _Winparent, 0, _WinTypeMdiFrame);
        vHdl # Winsearch(vWin, 'lb.Key1');
        aDatei  # cnvia(vHdl->wpcustom);
        vHdl # Winsearch(vWin, 'lb.Key2');
        aKey    # vHdl->wpcustom;
      end;
      
      Anh_Data:DragDrop(aDataObject->wpname, aDatei, aKey, '', '?', aEvt:obj, aTyp, aName);
    end;

    RETURN true;
  end;

  // Outlook Mail?
  if (Set.ExtArchiev.Path<>'') and
    (aDataObject->wpFormatEnum(_WinDropDataContent) and
    (aDataObject->wpFormatEnum(_WinDropDataFile)=false) and
    (aDataObject->wpFormatEnum(_WinDropDataUser)=false) and
  //dumbo  (aDataObject->wpFormatEnum(_WinDropDataText)) and
    (aDataObject->wpFormatEnum(_WinDropDatartf)=false)) then begin

    // DragData-Objekt ermitteln
    vData # aDataObject->wpData(_WinDropDataContent);
    // Eigentum der Daten übernehmen, da die Objekte sonst nach dem Ereignis entfernt werden
    vData->wpDataOwner # FALSE;
    // Liste mit den Daten ermitteln
    vList # vData->wpData;
    // Deskriptor der Liste speichern

    // in BLOB-DB aufnehmen?
    if (Set.ExtArchiev.Path='CA1') then begin
      if (gDBAConnect=0) and (vDBACon=0) then begin
        if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBACon # 3
        else RETURN false;;
      end;
    end;


    FOR   vListObj # vList->CteRead(_CteFirst);
    LOOP  vListObj # vList->CteRead(_CteNext, vListObj);
    WHILE (vListObj != 0) and (vOK=false) do begin
      // Name und Deskriptor des Memory-Objekts in die Liste schreiben

      vMemObj # vListObj->spid;
      vFilename # vListObj->spname;
//dumbo      if (fsisplitname(vFilename,_fsinameE)<>'msg') then CYCLE;
      vFilename # Lib_FileIO:NormalizedFilename(vFilename);

//      Erx # RecRead(916,gZLList->wpdbSelection,_recLast);
//      if (Erx<>_rOK) then vNr # 1
//      else vNr # Anh.lfdNr + 1;
      RecBufClear(916);


      // in BLOB-DB aufnehmen?
      if (Set.ExtArchiev.Path='CA1') then begin
        vPath # Anh_Data:CreateBLOBPath(aDatei, aKey);
        if (vPath='') then CYCLE;
        Erx # Lib_Blob:Exists(var vOK, vPath, vFilename, cDBA);
        if (erx<>_rOK) then RETURN false;
      end
      // in externes Archiev
      else begin
        vFilename # Anh_Data:FindArchivName(vFilename, aDatei, aKey);
        if (vFileName='') then CYCLE;
        if (Lib_FileIO:FileExists(vFilename)) then vOK # y;
      end;

    END;

    if (vOK) then begin
      if (Msg(917009,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then begin
        if (vDbaCon<>0) then DbaDisconnect(vDbaCon);  // 28.09.2015
        RETURN false;
      end;
    end;


    FOR   vListObj # vList->CteRead(_CteFirst);
    LOOP  vListObj # vList->CteRead(_CteNext, vListObj);
    WHILE (vListObj != 0) do begin
      // Name und Deskriptor des Memory-Objekts in die Liste schreiben

      vMemObj # vListObj->spid;
      vFilename # vListObj->spname;
//Dumbo      if (fsisplitname(vFilename,_fsinameE)<>'msg') then CYCLE;

      vFilename # Lib_FileIO:NormalizedFilename(vFilename);
      vFilename # Lib_Blob:CutFilename(vFilename);  // ST 2015-03-04: Blobs können max 60 Zeichen als Bezeichnung

//      Erx # RecRead(916,gZLList->wpdbSelection,_recLast);
//      if (Erx<>_rOK) then vNr # 1
//      else vNr # Anh.lfdNr + 1;
      RecBufClear(916);

      vOK # true;
      // in BLOB-DB aufnehmen?
      if (Set.ExtArchiev.Path='CA1') then begin

        vPath # Anh_Data:CreateBLOBPath(aDatei, aKey);
        if (vPath='') then CYCLE;
        Erx # Lib_Blob:Exists(var vExists, vPath, vFilename, cDBA);
        if (erx<>_rOK) then RETURN false;

        if (Lib_Blob:MemToBlob(vMemObj, vFilename, vPath, cDBA, 0, true, var vBlobID)<>_ErrOK) then begin
          Msg(99,'Error @ '+vFilename,0,0,0);
          vOK # false;
        end;
//        if (vBlobID<>Anh.BlobID) then begin
//          RecRead(916,1,_recLock);
//          Anh.BlobID # vBlobID;
//          Erx # RekReplace(916,_recunlock,'AUTO');
//        end;
        vFilename # FsiSplitName(vFileName, _FSINameNE);
      end
      else begin
        vFilename # Anh_Data:FindArchivName(vFilename, aDatei, aKey);
        if (vFileName='') then CYCLE;
        vExists # Lib_FileIO:FileExists(vFilename);   // 03.02.2022 AH

        vFile # FSIOpen(vFileName,_FsiAcsRW|_FsiDenyRW|_FsiCreate);
        vFile->FsiWriteMem(vMemObj,1,vMemObj->spLen);
        vFile->FsiClose();
      end;

      if (vOK) and (vExists=false) then begin
        Anh.Bemerkung     # StrCut(vListObj->spname,1,64);
        Anh.Datei         # aDatei;
        Anh.File          # vFileName;
        Anh.Key           # aKey;
        Anh.BlobID        # vBlobID;
        Anh.Name          # aName;
        Anh.Typ           # aTyp;
  //      Anh.lfdnr         # vNr;
        BestimmeLfdNr();
        
        Anh_Data:Insert();

        SelRecInsert(gZLList->wpDbSelection,916);
        gZLList->winupdate(_winupdon, _WinLstFromFirst);
      end;
    END;

  end;  // Outlook




  // File?
  if (aDataObject->wpFormatEnum(_WinDropDataFile)) then begin

    // Dateipfad und -name wurde übergeben
    // Format-Objekt ermitteln
    vDataFormat # aDataObject->wpData(_WinDropDataFile);
    vFileList # vDataFormat->wpData;

    // in BLOB-DB aufnehmen?
    if (Set.ExtArchiev.Path='CA1') then begin
      if (gDBAConnect=0) and (vDBACon=0) then begin
        if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBACon # 3
        else RETURN false;;
      end;
    end;


    // alle übertragenen Dateinamen auswerten
    // Existieren schon?
    FOR  vListObj # vFileList->CteRead(_CteFirst);
    LOOP vListObj # vFileList->CteRead(_CteNext, vListObj);
    WHILE (vListObj > 0) and (vOK=false) do begin
      vFilename # vListObj->spname;

      // in BLOB-DB aufnehmen?
      if (Set.ExtArchiev.Path='CA1') then begin
        vPath # Anh_Data:CreateBLOBPath(aDatei, aKey);
        if (vPath='') then CYCLE;
        Erx # Lib_Blob:Exists(var vOK, vPath, vFilename, cDBA);
        if (erx<>_rOK) then RETURN false;
      end
      else begin
        // lokale Datei?? -> dann kopieren
        if (StrCut(vFilename,2,1)=':') then begin
          vA # StrCut(vFilename,1,1);
if (DbaLicense(_DbaSrvLicense)<>'CE107511MU') AND (Set.Installname <> 'BSC') then begin    // Hammecke
          if (Lib_FileIO:IsNetworkdrive(vA)=false) then begin
            vA # FsiSplitname(vFilename, _FsiNameNE);
            vA # Anh_Data:FindArchivName(vA, aDatei, aKey);
            if (Lib_FileIO:FileExists(vA)) then vOK # y;
          end;
end;
        end;
      end;
    END;

    if (vOK) then begin
      if (Msg(917009,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then begin
        if (vDbaCon<>0) then DbaDisconnect(vDbaCon);  // 28.09.2015
        RETURN false;
      end;
    end;


    // alle übertragenen Dateinamen auswerten
    FOR vListObj # vFileList->CteRead(_CteFirst);
    LOOP vListObj # vFileList->CteRead(_CteNext,vListObj);
    WHILE (vListObj > 0) do begin
      vFileName # vListObj->spName;

//      Erx # RecRead(916,gZLList->wpdbSelection,_recLast);
//      if (Erx<>_rOK) then vNr # 1
//      else vNr # Anh.lfdNr + 1;
      RecBufClear(916);

      vOK # true;
      // in BLOB-DB aufnehmen?
      if (Set.ExtArchiev.Path='CA1') then begin

        vPath # Anh_Data:CreateBLOBPath(aDatei, aKey);
        if (vPath='') then CYCLE;
        Erx # Lib_Blob:Exists(var vExists, vPath, vFilename, cDBA);
        if (erx<>_rOK) then RETURN false;

        if (Lib_Blob:Import(vFilename, vPath, cDBA, 0, true, var vBlobID)<>_ErrOK) then begin
          Msg(99,'Error @ '+vFilename,0,0,0);
          vOK # false;
        end;
        //vFilename # FsiSplitName(vFileName, _FSINameNE);
        vFilename # Lib_Blob:CutFilename(vFilename);
      end
      else begin
        // lokale Datei?? -> dann kopieren
        if (StrCut(vFilename,2,1)=':') then begin
          vA # StrCut(vFilename,1,1);
if (DbaLicense(_DbaSrvLicense)<>'CE107511MU') then begin    // Hammecke
          if (Lib_FileIO:IsNetworkdrive(vA)=false) OR (Set.Installname = 'BSC') then begin
            vA # FsiSplitname(vFilename, _FsiNameNE);
            vA # Anh_Data:FindArchivName(vA, aDatei, aKey);
            vExists # Lib_FileIO:FileExists(vA);   // 03.02.2022 AH
            Lib_FileIO:FsiCopy(vFilename, vA, n);
            vFilename # vA;
          end;
end;
        end;
      end;

      if (vOK) and (vExists=false) then begin
        Anh.Datei         # aDatei;
        Anh.File          # vFilename;
        Anh.Key           # aKey;
        Anh.BlobID        # vBlobID;
        Anh.Name          # aName;
        Anh.Typ           # aTyp;
  //      Anh.lfdnr         # vNr;
  
        BestimmeLfdNr();
        
        Anh_Data:Insert();
        if (gZLList<>0) then begin
          SelRecInsert(gZLList->wpDbSelection,916);
          gZLList->winupdate(_winupdon, _WinLstFromFirst);
        end;
      end;

    end;
  end;
//    case aDataObject->wpFormatEnum(_WinDropDataText) :

  aEffect # _WinDropEffectCopy | _WinDropEffectMove;

  if (vDBACon<>0) then DbaDisconnect(vDBACon);

  RETURN(true);// Ermitteln der vorhandenen Daten

end;


//========================================================================
//  EvtDragInit
//
//========================================================================
sub EvtDragInit(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aEffect              : int;      // Rückgabe der erlaubten Effekte (_WinDropEffectNone = Cancel)
  aMouseBtn            : int;      // Verwendete Maustasten (optional)
) : logic;
local begin
  Erx     : int;
  vCTE    : int;
  vMem    : int;
  vFormat : int;
  vItem   : int;
  vI      : int;
  vA,vB   : alpha(4000);
  vDatei  : int;
  vKey    : alpha;
  vPath   : alpha(4000);
  vDBACon : int;
  v916    : int;
end;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectMove | _WinDropEffectLink;

  vDatei  # cnvia($lb.key1->wpcustom);
  vKey    # $lb.key2->wpcustom;
  //vPath # Anh_Data:CreateBLOBPath(vDatei, vKey);
  vPath # Anh_Data:BLOBPath(vDatei, vKey);
  if (vPath='') then RETURN false;
  if (aEvt:Obj->wpDbRecId=0) then RETURN false;
  RecRead(916,0,_recID,aEvt:Obj->wpDbRecId);

  if (gDragList=0) then
    gDragList # CteOpen(_CteList);

  CteClear(gDragList, y);


  aDataObject->wpFormatEnum(_WinDropDataContent) # true;
  aDataObject->wpFormatEnum(_WinDropDataText) # true;

  aDataObject->wpCustom # 'vonSC|916';
//  aDataObject->wpName   # cnvai(916,0,0,3)+'|'+Cnvai(RecInfo(916,_recID),_FmtNumNoGroup,0,15)+'|'+Lib_Rec:Makekey(916,y);

  vCTE  # gZLList->wpSelData;
  if (vCTE<>0) then begin
    vCTE  # vCTE->wpData(_WinSelDataCteTree);
    FOR vItem # CteRead(vCte,_CteFirst)
    LOOP vItem # CteRead(vCte,_Ctenext, vItem)
    WHILE (vItem<>0) do begin
      vI # vItem->spID;

      Erx # RecRead(916,0,_recID, vI);
      if (Erx>_rLocked) then CYCLE;

      vA # Anh.File;
      if (Anh.Link.Datei<>0) then begin
        Anh.Datei     # Anh.Link.Datei;
  //      Anh.Key       # Anh.Link.Key;
  //      Anh.lfdNr     # Anh.Link.lfdnr;
        Anh.ID        # Anh.Link.ID;
        v916 # RekSave(916);
  //      RecRead(v916,1,0);
        RecRead(v916,3,0);
        aDataObject->wpName   # cnvai(916,0,0,3)+'|'+Cnvai(RecInfo(v916,_recID),_FmtNumNoGroup,0,15)+'|'+Lib_Rec:Makekey(v916,y);
        RecBufDestroy(v916);
      end
      else begin
        aDataObject->wpName   # cnvai(916,0,0,3)+'|'+Cnvai(RecInfo(916,_recID),_FmtNumNoGroup,0,15)+'|'+Lib_Rec:Makekey(916,y);
      end;
      if (vA='') then CYCLE;


      vB # FsiSplitName(vA,_FsiNameNE);
      vA # '\' + vPath + '\' + vA;
      if (gDBAConnect=0) and (vDBACon=0) then begin
        if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBACon # 3
        else CYCLE;
      end;

      Erx # Lib_Blob:BlobToMem(vA, cDBA, var vMem);
      if (Erx<>_rOK) then CYCLE;

      // Objekt in Liste einfügen
      gDragList->CteInsertItem(vB, vMem, '');

      // Format-Objekt ermittel und Daten anhängen
      vFormat # aDataObject->wpData(_WinDropDataContent);
      vFormat->wpData # gDragList;
    END;
  end // MULTI
  else begin
    vA # 'start';
    WHILE (vA='start') do begin
      // SINGLE
      vA # Anh.File;
      if (Anh.Link.Datei<>0) then begin
        Anh.Datei     # Anh.Link.Datei;
        Anh.ID        # Anh.Link.ID;
        v916 # RekSave(916);
        RecRead(v916,3,0);
        aDataObject->wpName   # cnvai(916,0,0,3)+'|'+Cnvai(RecInfo(v916,_recID),_FmtNumNoGroup,0,15)+'|'+Lib_Rec:Makekey(v916,y);
        RecBufDestroy(v916);
      end
      else begin
        aDataObject->wpName   # cnvai(916,0,0,3)+'|'+Cnvai(RecInfo(916,_recID),_FmtNumNoGroup,0,15)+'|'+Lib_Rec:Makekey(916,y);
      end;
      if (vA<>'') then begin
        vB # FsiSplitName(vA,_FsiNameNE);
        vA # '\' + vPath + '\' + vA;
        if (gDBAConnect=0) and (vDBACon=0) then begin
          if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBACon # 3
          else CYCLE;
        end;

        Erx # Lib_Blob:BlobToMem(vA, cDBA, var vMem);
        if (Erx<>_rOK) then CYCLE;

        // Objekt in Liste einfügen
        gDragList->CteInsertItem(vB, vMem, '');

        // Format-Objekt ermittel und Daten anhängen
        vFormat # aDataObject->wpData(_WinDropDataContent);
        vFormat->wpData # gDragList;
      end;
    end;
  end;
  
  if (vDBACon<>0) then DbaDisconnect(vDBACon);

  RETURN(true);
end;


//========================================================================
// EvtDragTerm
//
//========================================================================
sub EvtDragTerm(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aEffect              : int;      // Durchgeführte Dragoperation (_WinDropEffectNone = abgebrochen)
) : logic;
local begin
  vItem : int;
  vMem  : int;
end;
begin

  if (gDragList<>0) then begin

    FOR vItem # CteRead(gDragList,_CteFirst)
    LOOP vItem # CteRead(gDragList,_Ctenext, vItem)
    WHILE (vItem<>0) do begin
      vMem # vItem->spID;
      MemFree(vMem);
    END;

    CteClear(gDragList, y);
    CteClose(gDragList);
    gDragList # 0;
  end;


  RETURN(true);
end;




//========================================================================
//========================================================================
//========================================================================
//========================================================================