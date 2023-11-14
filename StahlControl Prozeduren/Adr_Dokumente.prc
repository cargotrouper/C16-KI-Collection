@A+
//===== Business-Control =================================================
//
//  Prozedur    Adr_Dokumente
//                    OHNE E_R_G
//
//  Info
//
//
//  31.07.2003  ML  Erstellung der Prozedur
//  05.02.2014  AH  Doppelklick startet Dokument extern
//  14.06.2016  AH  Drag&Drop aktiviert
//  01.02.2022  ST  E r g --> Erx
//  2023-02-01  ST  Preview der Dokumente aufgrund von Fehlverhalten von Conzept 16 deakiviert Proj. 2333/110:
//
//  Subprozeduren
//    SUB GetExtension(aName : alpha(1000)) : alpha;
//    SUB BuildTree(aPath : alpha; aListe : int) : logic
//    SUB refresh()
//    SUB EvtNodeSelect(aEvt : event; aNode : int) : logic
//    SUB EvtNodeExpand(aEvt : event; aNode : int; aCollapse : logic) : logic
//    SUB StartWord()
//    SUB StartExcel()
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtMouseItem(aEvt : event; aButtom : int; aHitTest : int; aItem : int; aID : int) : logic
//    SUB Init()
//    SUB EvtTerm(aEvt : event) : logic
//    SUB EvtDropEnter...
//    SUB EvtDrop...
//
//========================================================================
@I:Def_Global

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
Sub BuildTree(
  aPath     : alpha(1000);
  aRoot     : int;
) : logic
local begin
  vPath     : alpha(1000);
  vDirHdl   : int;
  vEintrag  : alpha(1000);
  vAttr     : int;
  vExt      : alpha;
  vNode     : int;
  vVar      : int;
  vTile     : int;
end;
begin

  if (StrCut(aPath,StrLen(aPath),1)<>'\') then aPath # aPath + '\';

  vPath # aPath;
  aRoot->wpcustom # vPath;
  vDirHdl   # FsiDirOpen(vPath,_FsiAttrDir);
  If (vDirHdl <=0) then RETURN false;

  vEintrag  # FsiDirRead(vDirHdl);
  WHILE (vEintrag <> '') do begin

    If (vEintrag = '.') or (vEintrag = '..') then begin
      vEintrag # FsiDirRead(vDirHdl);
      CYCLE;
    end;

    vAttr # FsiAttributes(vPath+vEintrag) & _FsiAttrDir;
    If (vAttr > 0) then begin   // ist Directory
      vNode # aRoot->WinTreeNodeAdd(vPath+vEintrag,vEintrag);
      vNode->wpcustom # vPath+vEintrag;

      vTile # 2;
      vNode->wpImageTileUser # vTile;

      BuildTree(vPath+vEintrag+'\',vNode);
    end
    else If (vAttr = 0) then begin
      vExt # GetExtension(vPath+vEintrag);
      If (StrFind(StrCnv("Set.GültEndungen",_StrUpper),vExt,0) > 0) or ("Set.GültEndungen"='') then begin

        vNode # aRoot->WinTreeNodeAdd(vPath+vEintrag,vEintrag);
        vNode->wpcustom # vPath+vEintrag;
        case vExt of
          'DOC|','DOCX|'  : vTile # 39;
          'XLS|','XLSX|'  : vTile # 40;
          'PPT|'  : vTile # 41;
          'PDF|'  : vTile # 33;
          'TXT|'  : vTile # 9;
          'GIF|','BMP|','JPG|','TIF|','TIFF|','PNG|' : vTile # 29;
        otherwise
          vTile # 8;
        end;
        vNode->wpImageTileUser # vTile;
      end;
    end
    else If (vAttr < 0) then RETURN false;
    vEintrag  # FsiDirRead(vDirHdl);
  END;
  FsiDirClose(vDirHdl);
end;


//========================================================================
// Refresh
//
//========================================================================
sub refresh ()
local begin
  vPath     : alpha;
  vItem     : int;
  vTempItem : int;
  vHdl      : int;
  vListe    : int;
  vSelected : logic;

  vRoot     : int;
end;
begin

  If (Adr.Pfad.Doks = '') then RETURN;

  vPath # Set.DokumentePfad;

  // 25.11.2016 AH
  if (Lib_Strings:Strings_Count(vPath,'|')>0) then begin
    if (isTestsystem) then
      vPath # Str_Token(vPath,'|',2)
    else
      vPath # Str_Token(vPath,'|',1);
  end;

  If (vPath = '') then vPath # 'C:\';

  vPath # vPath + Adr.Pfad.Doks;

  $tvDokumente->wpautoupdate # false;
//  $tvDokumente->wpVisible    # false;
  vRoot # $tvDokumente;
  vRoot->WinTreeNodeRemove();
  BuildTree(vPath,vRoot);
  $tvDokumente->wpCurrentint # 0;
//  $tvDokumente->wpVisible    # true;
  $tvDokumente->wpautoupdate # true;
end;


//========================================================================
// EvtNodeSelect
//
//========================================================================
sub EvtNodeSelect(
  aEvt  : event;
  aNode : int;
) : logic
local begin
  vName   : alpha(2000);
  vExt    : alpha;
  vTyp    : Alpha;
  vExcel  : logic;
  vWord   : logic;
  vHdl    : handle;
  vApp    : handle;
  vI      : int;
end;
begin

  // ST 2023-02-01 Proj. 2333/110: Preview der Dokumente aufgrund von Fehlverhalten von
  //                               Conzept 16 deakiviert
  RETURN false;

  If ($wnDokumente->wpcustom<>'AKTIV') then RETURN false;

  vName # aNode->wpcustom;
  vExt # GetExtension(vName);
  case vExt of

    'GIF|','TXT|','PDF|' : begin
      vTyp # 'STD';
    end;

    'PNG|','JPG|','TIF|','TIFF|','BMP|' : begin
      vTyp # 'PIC';
    end;

    'PPT|' : begin
      vTyp # 'CTX';
    end;

    'DOC|','DOCX|' : begin
      vWord # y;
      vTyp # 'WORD';
    end;

    'XLS|','XLSX|' : begin
      vExcel # y;
      vTyp # 'EXCEL';
      end;

    otherwise begin
      vName # 'about:blank';
    end;

  end;

  $Bt.DocWord->wpDisabled   # (vWord = false);
  $Bt.DocExcel->wpDisabled  # (vExcel = false);

  // passendes Anzeigeobjekt aktualisieren.......
  if (vTyp='CTX') or (vTyp='EXCEL') or (vTyp='WORD') then begin
    $wnDokumente->wpVisible     # false;
    $wnDokumente->wpdisabled    # true;
    $PicDokumente->wpVisible    # false;
    $picDokumente->wpdisabled   # true;

    $ctxDokumente->wpdisabled   # false
    $ctxDokumente->wpfilename   # '*'+vName;
    $ctxDokumente->wpVisible    # true;

    vApp # $ctxDokumente->cphApplication;

    // WORD:
    if (vTyp='WORD') then begin
      $ctxDokumente->ComCall('Protect', 2, TRUE, '1234');
      vHdl  # $ctxDokumente->cphApplication.ActiveWindow;
      vHdl # vApp->cphCommandBars('Ribbon');
      vI  # vHdl->cpiHeight;
      if (vI > 100) then
        vHdl->ComCall('ToggleRibbon');
    end;

    // EXCEL:
    if (vTyp='EXCEL') then begin
      vHdl # vApp->cphCommandBars('Ribbon');
      vI  # vHdl->cpiHeight;
      if (vI > 100) then
        vApp->ComCall('CommandBars.ExecuteMSO','MinimizeRibbon');
      vHdl # $ctxDokumente->cphWorksheets(1);
      vHdl->ComCall('Protect', '12345', TRUE, True);
    end;

/***
      tHdlDlg # aEvt:Obj;
  vCTX    # Winsearch(tHdlDlg,'CtxOfficeControl');
  vApp # vCtX->cphApplication;

  // WORD:
//      $:CtxOfficeControl->ComCall('Protect', 2, TRUE, '1234');
  //vWnd  # vCTX->cphApplication.ActiveWindow;
  //vWnd->ComCall('ToggleRibbon');

  // EXCEL:
//  vApp->ComCall('ExecuteExcel4Macro','"Show.Toolbar(""Ribbon"", false)"');
  vApp->ComCall('CommandBars.ExecuteMSO','MinimizeRibbon');
//   vApp->ComCall('SendKeys','^{F1}');
**/

    $ctxDokumente->WinUpdate(_WinUpdOn | _WinUpdFld2Obj);
  end;


  if (vTyp='STD') then begin
    $ctxDokumente->wpVisible    # false;
    $ctxDokumente->wpdisabled   # true;
    $picDokumente->wpVisible    # false;
    $picDokumente->wpdisabled   # true;

    $wnDokumente->wpdisabled    # false
    $wnDokumente->wpCaption     # vName;
    $wnDokumente->wpVisible     # true;
    $wnDokumente->WinUpdate(_WinUpdOn | _WinUpdFld2Obj);
  end;

  if (vTyp='PIC') then begin
    $ctxDokumente->wpVisible    # false;
    $ctxDokumente->wpdisabled   # true;
    $wnDokumente->wpVisible     # false;
    $wnDokumente->wpdisabled    # true;

    $picDokumente->wpdisabled   # false
    $picDokumente->wpCaption    # '*'+vName;
    $picDokumente->wpVisible    # true;
    $picDokumente->WinUpdate(_WinUpdOn | _WinUpdFld2Obj);
  end;

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
// StartWord
//
//========================================================================
Sub StartWord ()
local begin
  vNeu  : logic;
  vApp  : int;
  vDoc  : int;
  vSel  : int;
  vFont : int;
  vLoop : int;
  vName : alpha(1000);
  vHdl  : int;

end;
begin
/**
  If $wnDokumente->wpCustom <> '' then begin
    vHdl # CteRead(CnvIA($tvDokumente->wpCustom),_CteFirst | _CteSearchCI | _CteCustom,0,$wnDokumente->wpCustom);
    VarInstance(ListItem,HdlLink(vHdl));
    vPath # iPath;
    If iDirJN then vPath # vPath + iName + '\';
    vNeu # !iWord;
  end;
**/

  if ($tvDokumente->wpcurrentInt=0) then RETURN;
  vName # $tvDokumente->wpcurrentInt->wpcustom;

  // Abfangen der COM-Fehler im try Block, ohne einen Try-Block können
  // Fehlermeldungen von COM-Befehlen nicht ausgegeben werden.
  // Ohne 'try' wird ein Laufzeitfehler generiert.

  ErrTryCatch(_ErrHdlInvalid,TRUE);
  ErrTryCatch(_ErrPropInvalid,TRUE);
  ErrTryCatch(_ErrFldType,TRUE);

  // COM-Befehle sollten in einem TRY-Block stehen, damit abgefangen werden
  // können.

  try begin
    // Verbindung zur COM-Schnittstelle öffnen/Word Applikation starten. (Word startet im HintErxrund)
    vApp # ComOpen('Word.Application', _ComAppCreate);

    // HIER SOLLTE DER PFAD GESETZT WERDEN

    // Wordanwendung sichtbar machen. cplVisible ist eine Eigenschaft der Applicationklasse
    // Die Applicationklasse wird von Word bereitgestellt.
    vApp->cplVisible # true;

    If vNeu then begin
      // Die Metode Documents der Klasse Application öffnet ein neues Word Dokument
      vApp->ComCall('Documents.Add');

      // Die Eigenschaft cphSelection ist der Descriptor des Cursors
      vSel  # vApp->cphSelection;

      // cphFont ist der Fontdescriptor der Selection
      vFont # vSel->cphFont;

      // Der Font wird für die Ausgabe eingestellt
      // Schriftart
      vFont->cpaName # 'Times New Roman';

      // Schriftgröße
      vFont->cpiSize # 12;

      // Die Methode TypeText gehört zur Word-Klasse Selection und übErxibt als Parameter
      // den Aplhastring, wecher im Worddokument ausgegeben werden soll
      vSel->ComCall('TypeText',StrChar(13,6));
      vSel->ComCall('TypeText',Adr.Anrede + StrChar(13));
      vSel->ComCall('TypeText',Adr.Name + StrChar(13));
      vSel->ComCall('TypeText',Adr.Zusatz + StrChar(13));
      vSel->ComCall('TypeText',"Adr.Straße" + StrChar(13));
      vSel->ComCall('TypeText',Adr.LKZ + ' ' + Adr.PLZ + ' ' + Adr.Ort + StrChar(13));

    end
    else begin
      $tvDokumente->wpCurrentInt  # 0;
      $wnDokumente->wpCaption     # 'about:blank';
      vApp->ComCall('Documents.Open',vName);
    end;

  end;

  if (ErrGet() != _ErrOk) then begin
    //Wenn Word nicht installiert ist
    if (ErrGet() = -191 OR ErrGet() = -199) then begin
//      ComError:ComNotFound('WORD1');
    end
    else begin
      // Falls ein Fehler aufgetreten ist, erfolgt hier die Ausgabe in einer MessageBox
      WinDialogBox(gFrmMain,'ERROR',
                 CnvAI(ErrGet())+StrChar(13)+StrChar(10)+
                 CnvAI(ErrPos())+StrChar(13)+StrChar(10)+
                 ComInfo(0,_ComInfoErrCode)+StrChar(13)+StrChar(10)+
                 ComInfo(0,_ComInfoErrText),
                 _WinIcoError,_WinDialogOk,0);
    end;
  end;

  // und den Deskriptor des COM-Objektes freigeben
  vApp->ComClose();
end;


//========================================================================
// StartExcel
//
//========================================================================
Sub StartExcel ()
local begin
  vApp        : int;
  vWorkbook   : int;
  vWorksheet  : int;
  vHdl        : int;
  vName       : alphA(1000);
end;
begin

  if ($tvDokumente->wpcurrentInt=0) then RETURN;
  vName # $tvDokumente->wpcurrentInt->wpcustom;


  ErrTryCatch(_ErrHdlInvalid,TRUE);
  ErrTryCatch(_ErrPropInvalid,TRUE);
  ErrTryCatch(_ErrFldType,TRUE);
  ErrTryCatch(_ErrArrayIndex,TRUE);

  // lokale Daten initialisieren
  vApp       # 0;
  vWorkbook  # 0;
  vWorksheet # 0;

  try begin
    vApp # ComOpen('Excel.Application', _ComAppCreate);

//    vApp->ComPropSet('DefaultFilePath',vPath);

    vApp->cplVisible # true;

    //Arbeitsmappe hinzufügen/erstellen
    $wnDokumente->wpCaption # 'about:blank';
    $tvDokumente->wpCurrentInt  # 0;
    vApp->ComCall('Workbooks.Open',vName);

  end;

  if (ErrGet() != _ErrOk) then begin
    //Wenn Excel nicht installiert ist
    if (ErrGet() = -191 OR ErrGet() = -199) then begin
//      ComError:ComNotFound('Excel');
    end
    else begin
      // Falls ein Fehler aufgetreten ist, erfolgt hier die Ausgabe in einer MessageBox
      WinDialogBox(gFrmMain,'ERROR',
                 CnvAI(ErrGet())+StrChar(13)+StrChar(10)+
                 CnvAI(ErrPos())+StrChar(13)+StrChar(10)+
                 ComInfo(0,_ComInfoErrCode)+StrChar(13)+StrChar(10)+
                 ComInfo(0,_ComInfoErrText),
                 _WinIcoError,_WinDialogOk,0);
    end;
  end;

  // und den Deskriptor des COM-Objektes freigeben
  vApp->ComClose();

end;


//========================================================================
// EvtClicked
//
//========================================================================
sub EvtClicked(
  aEvt : event;
) : logic
begin

  Case aEvt:Obj->wpName of
    'Bt.DocRefresh' : begin
      refresh();
    end;
    'Bt.DocWord' : begin
      StartWord();
    end;
    'Bt.DocExcel' : begin
      StartExcel();
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
  vTV   : int;
  vName : alpha(4000);
  vExt  : alpha;
  vCurr : int;
end;
begin

  vTV # WInsearch(gMDI, 'tvDokumente');
  if (vTV=0) then RETURN false;
  vCurr # vTV->wpCurrentint;

  // per Doppelklick sofort starten...
  if (aButton=_WinMouseLeft | _WinMouseDouble) and (vCurr<>0) then
    if (vCurr->wpcustom <>'') then begin
    vName # $tvDokumente->wpcurrentint->wpcustom;
    vExt # GetExtension(vName);
    if (vExt='DOC|') or (vExt='DOCX|') then StartWord()
    else if (vExt='XLS|') or (vExt='XLSX|') then StartExcel();
    else SysExecute('*'+'"'+$tvDokumente->wpcurrentint->wpcustom+'"','',0);
  end;


  If (aEvt:Obj = vTV) and (aHitTest <> _WinHitTreeNode) then begin
    If Adr.Pfad.Doks <> '' then begin
      $wnDokumente->wpCaption     # 'about:blank';
      vTV->wpCurrentInt  # 0;
      $Bt.DocWord->wpDisabled     # false;
      $Bt.DocExcel->wpDisabled    # false;
    end
    else begin
      $Bt.DocWord->wpDisabled     # true;
      $Bt.DocExcel->wpDisabled    # true;
    end;
  end;
end;


//========================================================================
// Term
//
//========================================================================
sub Term()
begin

  if (Set.DokumentePFad='CA1') then begin
    Adr_Dokumente2:Term();
    RETURN;
  end;

  $wnDokumente->wpcustom # '';

  $wnDokumente->wpVisible   # false;
  $wnDokumente->wpDisabled  # true;

  $ctxDokumente->wpVisible  # false;
  $ctxDokumente->wpDisabled # true;

  $picDokumente->wpVisible  # false;
  $picDokumente->wpDisabled # true;

  $ctxDokumente->wpfilename # '';
  $picDokumente->wpcaption  # '';
  $wnDokumente->wpcaption   # '';
end;


//========================================================================
// Init
//
//========================================================================
sub Init()
begin

  if (Set.DokumentePFad='CA1') then begin
    Adr_Dokumente2:Init();
    RETURN;
  end;

  If (Mode<>'') and (Mode <> c_ModeView) then RETURN;

  $wnDokumente->wpVisible   # false;
  $wnDokumente->wpDisabled  # true;
  $ctxDokumente->wpVisible  # false;
  $ctxDokumente->wpDisabled # true;
  $picDokumente->wpVisible  # false;
  $picDokumente->wpDisabled # true;


  $wnDokumente->wpCaption     # 'about:blank';
  $tvDokumente->wpCurrentInt  # 0;
//  WinEvtProcessSet(_WinEvtNodeSelect,false);
  refresh();
//  WinEvtProcessSet(_WinEvtNodeSelect,true);

  $wnDokumente->wpcustom # 'AKTIV';

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
  $tvDokumente->WinTreeNodeRemove();
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
  aEffect # _WinDropEffectCopy | _WinDropEffectMove | _WinDropEffectLink
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
  vDataFormat : int;
  vFileList   : int;
  vListObj    : int;
  vFilename   : alpha(2000);
  vPath       : alpha(4000);
  vPath2      : alpha(4000);
  vOK         : logic;

  vData       : handle;
  vList       : handle;
  vMemObj     : handle;
  vFile       : handle;
  vI          : int;
end;
begin

  vI # $tvDokumente->wpcurrentInt;
  if (vI<>0) then vPath # vI->wpCustom;
  if (aDataPlace<>0) then begin
    vI # aDataplace->wpArgInt(0);
    if (vI<>0) then begin
      vPath # vI->wpCustom;
    end;
  end;

  //vDatei  # cnvia($lb.key1->wpcustom);
  //vKey    # $lb.key2->wpcustom;


  // Outlook Mail?
  if (Set.DokumentePfad<>'') and
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
    vList # vData->wpData;
    // Deskriptor der Liste speichern

    FOR   vListObj # vList->CteRead(_CteFirst);
    LOOP  vListObj # vList->CteRead(_CteNext, vListObj);
    WHILE (vListObj != 0) and (vOK=false) do begin
      // Name und Deskriptor des Memory-Objekts in die Liste schreiben

      vMemObj # vListObj->spid;
      vFilename # vListObj->spname;
      if (fsisplitname(vFilename,_fsinameE)<>'msg') then CYCLE;

      vFilename # Lib_FileIO:NormalizedFilename(vFilename);
      vFilename # Lib_Blob:CutFilename(vFilename);
      vPath2 # vPath;
      vPath2 # vPath2 + FsiSplitName(vFileName, _FsiNameNE);

      vOK # Lib_FileIO:FileExists(vPath2);
    END;

    if (vOK) then begin
      if (Msg(917009,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then begin
          RETURN false;
        end;
    end;


    FOR   vListObj # vList->CteRead(_CteFirst);
    LOOP  vListObj # vList->CteRead(_CteNext, vListObj);
    WHILE (vListObj != 0) do begin
      // Name und Deskriptor des Memory-Objekts in die Liste schreiben

      vMemObj # vListObj->spid;
      vFilename # vListObj->spname;
      if (fsisplitname(vFilename,_fsinameE)<>'msg') then CYCLE;

      vFilename # Lib_FileIO:NormalizedFilename(vFilename);
      vFilename # Lib_Blob:CutFilename(vFilename);

      vPath2 # vPath;
      vPath2 # vPath2 + FsiSplitName(vFileName, _FsiNameNE);

      vFile # FSIOpen(vPath2,_FsiAcsRW|_FsiDenyRW|_FsiCreate);
      vFile->FsiWriteMem(vMemObj,1,vMemObj->spLen);
      vFile->FsiClose();
    END;

    Refresh();

  end;  // Outlook


  // File?
  if (aDataObject->wpFormatEnum(_WinDropDataFile)) then begin

    // Dateipfad und -name wurde übErxeben
    // Format-Objekt ermitteln
    vDataFormat # aDataObject->wpData(_WinDropDataFile);
    vFileList # vDataFormat->wpData;

    // alle übertragenen Dateinamen auswerten
    // Existieren schon?
    FOR  vListObj # vFileList->CteRead(_CteFirst);
    LOOP vListObj # vFileList->CteRead(_CteNext, vListObj);
    WHILE (vListObj > 0) and (vOK=false) do begin
      vFilename # vListObj->spname;

      vPath2 # vPath;
      vPath2 # vPath2 + FsiSplitName(vFileName, _FsiNameNE);

      vOK # Lib_FileIO:FileExists(vPath2);
    END;

    if (vOK) then begin
      if (Msg(917009,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then begin
        RETURN false;
      end;
    end;


    // alle übertragenen Dateinamen auswerten
    FOR vListObj # vFileList->CteRead(_CteFirst);
    LOOP vListObj # vFileList->CteRead(_CteNext,vListObj);
    WHILE (vListObj > 0) do begin
      vFileName # vListObj->spName;

      vPath2 # vPath;
      vPath2 # vPath2 + FsiSplitName(vFileName, _FsiNameNE);

      Lib_FileIO:FsiCopy(vFilename, vPath2, false);
    END;

    Refresh();
  end;

  aEffect # _WinDropEffectCopy | _WinDropEffectMove;

  RETURN(true);
end;


//========================================================================