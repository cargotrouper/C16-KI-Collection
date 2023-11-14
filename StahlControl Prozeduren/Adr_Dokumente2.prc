@A+
//===== Business-Control =================================================
//
//  Prozedur    Adr_Dokumente2
//                    OHNE E_R_G
//  Info
//
//
//  16.04.2014  AH  Erstellung der Prozedur
//  14.05.2014  ST  Sortierung für cDL hinzugefügt Projekt 1499/2
//  01.02.2022  ST  E r g --> Erx
//
//  Subprozeduren
//    SUB GetExtension(aName : alpha(1000)) : alpha;
//    SUB BuildTree(aPath : alpha; aListe : int) : logic
//    SUB Refresh()
//    SUB EvtNodeSelect...
//    sub _TVNodeSelect( aNode       : int; ) : logic
//    SUB EvtNodeExpand...
//    SUB StartWord()
//    SUB StartExcel()
//    SUB EvtClicked...
//    SUB EvtMouseItem...
//    SUB Init()
//    SUB EvtTerm...
//
//========================================================================
@I:Def_Global

define begin
  cTV   : $tvStrukturen
  cDL   : $dlDateien
  cDBA  : _BinDBa3
end;

Declare Init();


//========================================================================
// GetExtension
//
//========================================================================
sub GetExtension(aName : alpha(1000)) : alpha;
begin
  RETURN StrCnv(FsiSplitName(aName,_FsiNameE),_StrUpper)+'|';
end;


//========================================================================
// BuildTree
//
//========================================================================
Sub BuildTree() : logic
local begin
  vName : alpha;
  vErr  : int;
end;
begin

  if (Adr.Nummer=0) then RETURN false;

  vName # 'Adresse';
  vErr # Lib_Blob:ExistsDir(vName, cDBA);
  if (vErr<0) then RETURN false;
  if (vErr=0) then
    Lib_Blob:CreateDir('', vName, cDBA, 0);

  vName # 'Adresse\'+aint(Adr.Nummer);
  vErr # Lib_Blob:ExistsDir(vName, cDBA);
  if (vErr<0) then RETURN false;
  if (vErr=0) then begin
//    Lib_Blob:CreateDir('Adresse', aint(Adr.Nummer), cDBA, 0);
    Lib_blob:CopyDir('Templates\Adressen', 'Adresse\'+aint(Adr.Nummer), cDBA);
  end;

  Lib_Blob:ShowBinDir(cTV, 0, vName, cDBA);

  RETURN true;
end;


//========================================================================
// Refresh
//
//========================================================================
sub Refresh ()
local begin
  vItem     : int;
  vTempItem : int;
  vHdl      : int;
  vListe    : int;
  vSelected : logic;

  vRoot     : int;
end;
begin

  cTV->wpautoupdate # false;
  vRoot # cTV;
  vRoot->WinTreeNodeRemove();

  BuildTree();

  cTV->wpCurrentint # 0;
  cTV->wpautoupdate # true;

  cTV->wpcustom # '';
  cDL->WinLstDatLineRemove(_WinLstDatLineAll);
end;


//========================================================================
// sub _TVNodeSelect(...)
//  Aktualisert die Datalist und übe r gibt die Sortiereigenschaften
//========================================================================
sub _TVNodeSelect(
 aNode       : int;
 ) : logic
local begin
  vBinDirHdl  : int;
  vBinDirPath : alpha;
  vHdl      : int;
  vSortFld  : alpha;
  vSortDir  : int;
  vAnz      : int;
end;
begin

  if (Adr.Nummer=0) then RETURN false;

  // Lesen des Verzeichnisse
  vBinDirPath # Lib_Blob:FindTreePath(aNode);
  cTV->wpcustom # 'Adresse\'+aint(Adr.Nummer)+vBinDirPath;

  //Lib_Blob:FillDL('Adresse\'+aint(Adr.Nummer)+vBinDirPath, cDL, cDBA);

  // ST 2014-50-14: mit Sortierung aufrufen
  vSortFld # '';
  vSortDir # 0;
  vHdl # cDL->WinSearch(cDL->wpCustom);
  if (vHdl <> 0) then begin
    // Letzte Sortierung übernehmen
    vSortFld # cDL->wpCustom;
    vSortDir # vHdl->wpClmSortImage;
  end else begin
    // Standardsortierung
    vHdl # cDL->WinSearch('clmName');
    vHdl->wpClmSortImage # _WinClmSortImageUp;
  end;
  Lib_Blob:FillOrderdDL(var vAnz, 'Adresse\'+aint(Adr.Nummer)+vBinDirPath, cDL, cDBA, vSortFld,vSortDir);
end;


//========================================================================
// EvtNodeSelect
//
//========================================================================
sub EvtNodeSelect(
  aEvt        : event;
  aNode       : int;
) : logic
local begin
  vBinDirHdl  : int;
  vBinDirPath : alpha;
end;
begin
  RETURN _TVNodeSelect(aNode);
end;



//========================================================================
// EvtNodeExpand
//
//========================================================================
sub EvtNodeExpand(
  aEvt      : event;
  aNode     : int;
  aCollapse : logic;
) : logic
local begin
  vHdl : int;
end;
begin
  RETURN true;
end;


//========================================================================
// EvtClicked
//
//========================================================================
sub EvtClicked(
  aEvt : event;
) : logic
local begin
  vA  : alpha(4096);
end;
begin
  Case aEvt:Obj->wpName of

    'Bt.DocRefresh' : begin
      Refresh();
    end;

  end;
end;


//========================================================================
// EvtMouseItem
//
//========================================================================
sub EvtMouseItem(
  aEvt      : event;
  aButton   : int;
  aHitTest  : int;
  aItem     : int;
  aID       : int;
): logic
local begin
  vA    : alpha(4000);
  vName : alpha(4000);
  vID   : int;
  vExt  : alpha;

  vHdl  : int;
end;
begin

  if ( aItem = 0 ) then RETURN false;

  // Falls mit der linken Taste auf den Spaltenkopf geklickt wurde,
  // Sortierung ändern (Aufruf der entsprechenden Unterfunktion)
  if (aEvt:obj = cDL) and
     (aButton = _winMouseLeft) and
     (aHitTest = _winHitLstHeader) then begin

    // Name der Spalte als Sortierfeld eintragen
    cDl->wpCustom # aItem->wpName;

    // Sortierungsrichtung ändern
    if (aItem->wpClmSortImage = _WinClmSortImageNone) OR (aItem->wpClmSortImage = _WinClmSortImageDown) then begin
      aItem->wpClmSortImage # _WinClmSortImageUp
    end else begin
      aItem->wpClmSortImage # _WinClmSortImageDown;
    end;

    // Alle anderen Spalten Sortierungen umsetzen
    if (aItem->wpName <> 'clmName') then begin
      vHdl # $dlDateien->WinSearch('clmName');
      vHdl->wpClmSortImage # _WinClmSortImageNone;
    end;

    if (aItem->wpName <> 'clmGroesse') then begin
      vHdl # $dlDateien->WinSearch('clmGroesse');
      vHdl->wpClmSortImage # _WinClmSortImageNone;
    end;

    if (aItem->wpName <> 'clmDatum') then begin
      vHdl # $dlDateien->WinSearch('clmDatum');
      vHdl->wpClmSortImage # _WinClmSortImageNone;
    end;

    // DL aktualisieren
    _TVNodeSelect(cTV->wpCurrentInt);

    return true;
  end;


  // per Doppelklick sofort starten...
  if (aEvt:Obj=cDL) and (aID<>0) then begin

    if (aButton=_WinMouseLeft | _WinMouseDouble) then begin
      WinLstCellGet(cDL, vID, 5, _WinLstDatLineCurrent);
      WinLstCellGet(cDL, vA, 4, _WinLstDatLinecurrent);
      if (vID<>0) and (vA<>'') then begin
        if (Lib_blob:Recht(vA, 'V', cDBA)=false) then begin
          Msg(917004,'',0,0,0);
          RETURN true;
        end;
        vName # Lib_Blob:Execute(vA, cDBA);
        if (Lib_blob:Recht(vA, 'E', cDBA)=false) then vName # ''; // wenn kein Edit-Recht, dann nicht überwachen
        if (vName<>'') then Lib_Jobber:WatchFile(vName, vA);
      end;
    end;
  end;

end;


//========================================================================
//========================================================================
sub EvtMenuInitPopup(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüeintrag
) : logic;
begin
  gTMP # aEvt:Obj->wininfo(_WinContextmenu);
  if (gTMP>0) then begin
    gTMP # Winsearch(gTMP, 'ktx.New');
    gTMP->wpDisabled # true;
  end;

  RETURN(true);
end;


//========================================================================
//  EvtMenuCommand
//
//========================================================================
sub EvtMenuCommand(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüpunkt / Toolbar-Button
) : logic;
local begin
  vPath : alpha(4000);
  vName : alpha(4000);
  vID   : int;
  vHdl  : int;
end;
begin

  // Dateien...
  if (aEvt:Obj=cDL) then begin
    if (aEvt:Obj->wpcurrentint=0) then RETURN false;

    WinLstCellGet(cDL, vName, 1, _WinLstDatLineCurrent);
    WinLstCellGet(cDL, vPath, 4, _WinLstDatLineCurrent);
    WinLstCellGet(cDL, vID, 5, _WinLstDatLineCurrent);

    if (aMenuItem->wpname='ktx.Delete') then begin
      if (Lib_blob:Recht(vPath, 'D', cDBA)=false) then begin
        Msg(917007,'!',0,0,0);
        RETURN false;
      end;
      if (Msg(917008, vName,_WinIcoQuestion, _WinDialogYesNo, 2)<>_winIdyes) then RETURN true;
      WinLstCellGet(cDL, vName, 4, _WinLstDatLineCurrent);
      Lib_Blob:Delete(FsiSplitName(vName, _FsiNameNE), FsiSplitName(vName, _FsiNamePP), cDBA, cDL);
      RETURN true;
    end;

    if (aMenuItem->wpname='ktx.Rechte') then begin
      if (Lib_blob:Recht(vPath, 'E', cDBA)=false) then begin
        Msg(917005,'',0,0,0);
        RETURN false;
      end;
      RecBufClear(917);
      Gv.Int.20   # vID;
      Gv.Alpha.01 # vName;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Blb.R.Verwaltung','');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    if (aMenuItem->wpname='ktx.Rename') then begin
      if (Lib_blob:Recht(vPath, 'E', cDBA)=false) then begin
        Msg(917005,'kein REcht!',0,0,0);
        RETURN false;
      end;

      if (Dlg_Standard:Standard(Translate('Name'), var vName)=false) then RETURN true;
      Lib_Blob:Rename(vPath, vName, cDBA, cDL, cDL->wpcurrentint);
      RETURN true;
    end;

  end;


  // Verzeichnisse...
  if (aEvt:Obj=cTV) then begin
    vHdl  # CTV->wpCurrentInt;
    if (vHdl=0) then RETURN true;
    vPath # vHdl->wpHelpTip;
    vName # FsiSplitName(vPath, _FsiNameNE);

    if (aMenuItem->wpname='ktx.New') then begin
      if (Lib_blob:RechtDir(vPath, 'N', cDBA)=false) then begin
        Msg(917006,'',0,0,0);
        RETURN false;
      end;
      vName # '';
      if (Dlg_Standard:Standard(Translate('Name'), var vName)=false) then RETURN true;
      Lib_Blob:CreateDir(vPath, vName, cDBA, vHdl);
    end;

    if (aMenuItem->wpname='ktx.Rechte') then begin
      if (Lib_blob:RechtDir(vPath, 'E', cDBA)=false) then begin
        Msg(917005,'',0,0,0);
        RETURN false;
      end;

      RecBufClear(917);
      Gv.Int.20   # vHdl->wpid;
      Gv.ALpha.01 # vPath;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Blb.R.Verwaltung','');
      Lib_GuiCom:RunChildWindow(gMDI);
      RETURN true;
    end;

    if (aMenuItem->wpname='ktx.Delete') then begin
      if (Lib_blob:RechtDir(vPath, 'D', cDBA)=false) then begin
        Msg(917007,'',0,0,0);
        RETURN false;
      end;
      if (Msg(917002,'', _WinIcoQuestion, _WinDialogYesNo,2)<>_Winidyes) then RETURN true;
      Lib_blob:DeleteDir(vPath, cDBa, aEvt:obj, vHdl);
    end;

    if (aMenuItem->wpname='ktx.Rename') then begin

      if (Lib_blob:RechtDir(vPath, 'E', cDBA)=false) then begin
        Msg(917005,'',0,0,0);
        RETURN false;
      end;

      if (Dlg_Standard:Standard(Translate('Name'), var vName)=false) then RETURN true;
      Lib_Blob:RenameDir(vPath, vName, cDBA, vHdl);
    end;
  end;

  RETURN(true);
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
  vCTE      : int;
  vMem      : int;
  vFormat   : int;
  vItem     : int;
  vI        : int;
  vA,vB     : alpha(4000);
end;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectMove | _WinDropEffectLink;

//    vDragList # CteOpen(_CteList);

  if (gDragList=0) then
    gDragList # CteOpen(_CteList);

  CteClear(gDragList, y);


  vCTE  # cDL->wpSelData;
  vCTE  # vCTE->wpData(_WinSelDataCteTree);

  FOR vItem # CteRead(vCte,_CteFirst)
  LOOP vItem # CteRead(vCte,_Ctenext, vItem)
  WHILE (vItem<>0) do begin
    vI # vItem->spID;
    WinLstCellGet(cDL, vA, 4, vI);
    if (vA='') then CYCLE;
    vB # FsiSplitName(vA,_FsiNameNE);
    if (Lib_blob:Recht(vA, 'V', cDBA)=false) then begin
      Msg(917004,' '+vA,0,0,0);
      RETURN false;
    end;
  END;



  FOR vItem # CteRead(vCte,_CteFirst)
  LOOP vItem # CteRead(vCte,_Ctenext, vItem)
  WHILE (vItem<>0) do begin
    vI # vItem->spID;
    WinLstCellGet(cDL, vA, 4, vI);
    if (vA='') then CYCLE;

    vB # FsiSplitName(vA,_FsiNameNE);

    if (Lib_Blob:BlobToMem(vA, cDBA, var vMem)<>0) then CYCLE;

    // Objekt in Liste einfügen
    gDragList->CteInsertItem(vB, vMem, vA);

    // Setzen der Informationen im Data-Objekt
    // Format aktivieren
    aDataObject->wpFormatEnum(_WinDropDataContent) # true;
    aDataObject->wpcustom # 'vonSC|Blob';

    // Format-Objekt ermittel und Daten anhängen
    vFormat # aDataObject->wpData(_WinDropDataContent);
    vFormat->wpData # gDragList;
  END;

  RETURN(true);
end;


//========================================================================
//  EvtDragTerm
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
//  EvtDropEnter
//
//========================================================================
sub EvtDropEnter(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aEffect              : int;      // Rückgabe der erlaubten Effekte
) : logic;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectLink | _WinDropEffectMove
  RETURN(true);
end;


//========================================================================
//  EvtDropLeave
//
//========================================================================
sub EvtDropLeave(
  aEvt                 : event;    // Ereignis
) : logic;
begin
// Objekte von EvtdropEnter killen
  RETURN(true);
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
) : logic;
local begin
  Erx         : int;
  vFileList   : int;
  vListObj    : int;
  vFileName   : alpha(4000);
  vZiel       : alpha(4000);
  vOK         : logic;
  vI          : int;
  vData       : int;
  vMemObj     : int;
end;
begin

  vZiel # cTV->wpcustom;
  if (vZiel='') then RETURN false;

  // Schreibrecht in Zielordner?
  if (Lib_blob:Recht(vZiel, 'N', cDBA)=false) then begin
    Msg(917006,'',0,0,0);
    RETURN false;
  end;
/*
if (aDataObject->wpFormatEnum(_WinDropDataFile)) then debugx('file');
if (aDataObject->wpFormatEnum(_WinDropDataUser)) then debugx('user');
if (aDataObject->wpFormatEnum(_WinDropDataContent)) then debugx('conte');
if (aDataObject->wpFormatEnum(_WinDropDataText)) then debugx('text');
if (aDataObject->wpFormatEnum(_WinDropDatartf)) then debugx('rtf');
*/
//debugx(aDataObject->wpcustom+' ::: '+aDataObject->wpname);

  if (aDataObject->wpFormatEnum(_WinDropDataText)) and (Set.ExtArchiev.Path='CA1') and
    (aDataObject->wpcustom='vonSC|Blob') then begin
    vFilename # aDataObject->wpname;
    if (Anh_Data:DragDrop('Blob|'+vFilename, 0, '', vZiel, 'COPY', 0)=false) then begin
      Msg(99,'Error @ '+vFilename,0,0,0);
      RETURN false;
    end;
    aEffect # _WinDropEffectCopy | _WinDropEffectMove;
  end;

  if (aDataObject->wpFormatEnum(_WinDropDataText)) and (Set.ExtArchiev.Path='CA1') and
    (aDataObject->wpcustom='vonSC|916') then begin
    vFilename # aDataObject->wpname;
    if (Anh_Data:DragDrop(vFilename, 0, '', vZiel, 'COPY', 0)=false) then begin
      Msg(99,'Error @ '+vFilename,0,0,0);
      RETURN false;
    end;
    aEffect # _WinDropEffectCopy | _WinDropEffectMove;
  end;



  // Outlook Mail?
  if (Set.ExtArchiev.Path<>'') and
    (aDataObject->wpFormatEnum(_WinDropDataContent) and
    (aDataObject->wpFormatEnum(_WinDropDataFile)=false) and
    (aDataObject->wpFormatEnum(_WinDropDataUser)=false) and
    (aDataObject->wpFormatEnum(_WinDropDataText)) and
    (aDataObject->wpFormatEnum(_WinDropDatartf)=false)) then begin


    // DragData-Objekt ermitteln
    vData # aDataObject->wpData(_WinDropDataContent);
    // Eigentum der Daten übernehmen, da die Objekte sonst nach dem Ereignis entfernt werden
    vData->wpDataOwner # FALSE;
    // Liste mit den Daten ermitteln
    vFileList # vData->wpData;

    // alle übertragenen Dateinamen auswerten
    // Existieren schon?
    FOR  vListObj # vFileList->CteRead(_CteFirst);
    LOOP vListObj # vFileList->CteRead(_CteNext, vListObj);
    WHILE (vListObj > 0) and (vOK=false) do begin
      vFilename # vListObj->spname;
      if (fsisplitname(vFilename,_fsinameE)<>'msg') then CYCLE;
      vMemObj # vListObj->spid;

      vFilename # Lib_FileIO:NormalizedFilename(vFilename);
      Erx # Lib_blob:Exists(var vOK, vZiel, vFilename, cDBA);
      if (Erx<>_rOK) then RETURN false;
      if (vOK) then begin
        if (Lib_blob:Recht(vZiel+'\'+vFilename, 'E', cDBA)=false) then begin
          Msg(917005, ' ('+vFilename+')',0,0,0);
          RETURN false;
        end;
        vOK # y;
      end;
    END;

    if (vOK) then begin
      if (Msg(917009,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
    end;


    FOR   vListObj # vFileList->CteRead(_CteFirst);
    LOOP  vListObj # vFileList->CteRead(_CteNext, vListObj);
    WHILE (vListObj != 0) do begin
      vFilename # vListObj->spname;
      if (fsisplitname(vFilename,_fsinameE)<>'msg') then CYCLE;
      vMemObj # vListObj->spid;

      vFilename # Lib_FileIO:NormalizedFilename(vFilename);
      Erx # Lib_Blob:MemToBlob(vMemObj, vFilename, vZiel, cDBA, cDL, true, var vI);
      if (Erx<>_errOK) then Msg(99,'Error '+aint(Erx)+' @ '+vFilename,0,0,0);
    END;

    aEffect # _WinDropEffectCopy | _WinDropEffectMove;
  end;


  // File?
  // 28.07.2016 AH:
  if (aDataObject->wpFormatEnum(_WinDropDataFile)) then begin

//  if (aDataObject->wpFormatEnum(_WinDropDataContent)=false) and
//   (aDataObject->wpFormatEnum(_WinDropDataFile)) and
//   (aDataObject->wpFormatEnum(_WinDropDataUser)=false) and
//   (aDataObject->wpFormatEnum(_WinDropDataText)=false) and
//   (aDataObject->wpFormatEnum(_WinDropDatartf)=false) then begin

    // Dateipfad und -name wurde über geben
    // Format-Objekt ermitteln
    vData # aDataObject->wpData(_WinDropDataFile);
    vFileList   # vData->wpData;

    // alle übertragenen Dateinamen auswerten
    // Existieren schon?
    FOR  vListObj # vFileList->CteRead(_CteFirst);
    LOOP vListObj # vFileList->CteRead(_CteNext, vListObj);
    WHILE (vListObj > 0) and (vOK=false) do begin
      vFileName # vListObj->spName;
      Erx # Lib_blob:Exists(var vOK, vZiel, vFilename, cDBA);
      if (Erx<>_rOK) then RETURN false;
      if (vOK) then begin
        if (Lib_blob:Recht(vZiel+'\'+vFilename, 'E', cDBA)=false) then begin
          Msg(917005,' ('+vFilename+')',0,0,0);
          RETURN false;
        end;
        vOK # y;
      end;
    END;

    if (vOK) then begin
      if (Msg(917009,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
    end;

    // alle übertragenen Dateinamen auswerten
    FOR  vListObj # vFileList->CteRead(_CteFirst);
    LOOP vListObj # vFileList->CteRead(_CteNext, vListObj);
    WHILE (vListObj > 0) do begin
      vFileName # vListObj->spName;
//debugx(vFileName);
      if (Lib_Blob:Import(vFilename, vZiel, cDBA, cDL, true, var vI)<>0) then Msg(99,'Error @ '+vFilename,0,0,0);
//      if (aEffect = _WinDropEffectMove) then
//        FsiDelete(tFileName);
    END;
    aEffect # _WinDropEffectCopy | _WinDropEffectMove;
  end;

  // DL aktualisieren
  _TVNodeSelect(cTV->wpCurrentint);


  RETURN(true);
end;


//========================================================================
// Term
//
//========================================================================
sub Term()
begin

  if (gDBAConnect=0) then RETURN;

  try begin
    ErrTryIgnore(_ErrValueInvalid);
    DbaDisConnect(3);
  end;
  gDBAConnect # 0;

end;


//========================================================================
// Init
//
//========================================================================
sub Init()
begin

//  If (Mode<>'') and (Mode <> c_ModeView) then RETURN;
  if (Adr.Nummer=0) then RETURN;

  if (gDBAConnect=0) then begin
    cTV->wpcustom # '';
    if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then gDBAConnect # 3;
  end;

  // nur wenn andere Adresse!
  if (StrFind(cTV->wpcustom,'Adresse\'+aint(Adr.Nummer)+'\',0)=1) then RETURN;

  cTV->wpCurrentInt  # 0;

  Refresh();

end;


//========================================================================
// EvtTerm
//
//========================================================================
sub EvtTerm(
  aEvt : event;
) : logic
begin
  Term();

  // Baum löschen
  cTV->WinTreeNodeRemove();
end;


//========================================================================