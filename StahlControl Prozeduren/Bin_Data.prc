@A+
@C+
//                OHNE E_R_G
//******************************************************************
//* BinData                                                        *
//*                                                                *
//* Prozedur zum Steuern der Dialoges BinDat | BinInfo | BinRename *
//*                                                                *
//*                                                                *
//*                                                                *
//* vectorsoft / 2003-05-20                                        *
//******************************************************************
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event)
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int)
//    SUB EvtClicked(aEvt : event)
//    SUB EvtNodeSelect(aEvt : event; aNode : int)
//    SUB EvtLstSelect(aEvt : event; aRecID : int)
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int)
//    SUB ShowBinDirectory(aWinObj : int; aBinDir : int)
//    SUB FillDlsBinObjects(aDlsHdl : int; aBinDir : int)
//    SUB FillDlsBinInfo(aDlsHdl : int; aObjHdl : int; aLine : int)
//    SUB FindTreePath(aNode : int)
//    SUB DeleteDirectory(aTreeHdl : int; aNodeSelected : int; aBinDirPath : alpha(4096))
//    SUB DeleteObject(aDlsHdl : int; aLineSelect : int; aBinObjPath : alpha(4096))
//    SUB CreateDirectory(aTreeHdl : int; aNodeSelected : int; aCurrentPath : alpha(4096))
//    SUB RenameDirectory(aNodeSelected : int; aBinDirPath : alpha(4096))
//    SUB ImportObject(aDlsHdl : int; aNodeSelected : int; aBinDirPath : alpha(4096); aExtFilePath : alpha(4096))
//    SUB ExportObject(aDlsHdl : int; aLineSelect : int; aBinDirPath : alpha(4096))
//    SUB ComDialog(aDialogOption : alpha; aParentObj : int)
//    SUB BlobErrMsg(aAktion : int; aErr : int; optaObjName : alpha(4096))
//
//==================================================================
@I:Def_Global

define begin
  sBox(a) : WinDialogBox(0,'Meldung - Binaere Objekte',a,_winIcoInformation,_WinDialogOk,1)
  sCR     : StrChar(10)+StrChar(13)

  // Binaere Typen
  sBinTypeDir      : 900
  sBinTypeObj      : 901

  // Konstanten fuer die Fehlerbehandlung
  sAktionDirOpen   : 100
  sAktionDirCreate : 101
  sAktionDirDelete : 102
  sAktionObjOpen   : 103
  sAktionObjCreate : 104
  sAktionObjImport : 105
  sAktionObjExport : 106
  sAktionObjDelete : 107
  sAktionRename    : 108

  // eigen definierte Fehlercodes
  sObjExists      : -1600

end;

global VAR_Frm_BinData;
begin
  // Deskriptor des Dialoges
  gFrm_BinData  : int;

  // Name der Umbenennung von Objekten
  gDirRename    : alpha;

  // Selektiertes Objekte dass im Info-Dialog angezeigt wird.
  gBinSelected  : int;
  gTypeSelected : int;

  // Deskriptor des Root-Knotens
  gNodeRoot     : int;

  gBinDirPath   : alpha(4096);

  gPicName      : alpha(250);
  gPicPath      : alpha(4096);
  gBinObjCnt    : int;
end;


// Vordeklaration der Funktionen
declare EvtInit(aEvt : event;): logic;
declare EvtMenuCommand(aEvt : event; aMenuItem : int;): logic;
declare EvtClicked(aEvt : event;): logic;
declare EvtNodeSelect(aEvt : event; aNode : int;): logic;
declare EvtLstSelect(aEvt : event; aRecID : int;): logic;
declare EvtFocusTerm(aEvt : event; aFocusObject : int;): logic;
declare ShowBinDirectory(aWinObj : int; aBinDir : int;)
declare FillDlsBinObjects(aDlsHdl : int; aBinDir : int;): int;
declare FillDlsBinInfo(aDlsHdl : int; aObjHdl : int; aLine : int;);
declare FindTreePath(aNode : int;): alpha;
declare DeleteDirectory(aTreeHdl : int; aNodeSelected : int; aBinDirPath : alpha(4096)): int;
declare DeleteObject(aDlsHdl : int; aLineSelect : int; aBinObjPath : alpha(4096)): int;
declare CreateDirectory(aTreeHdl : int; aNodeSelected : int; aCurrentPath : alpha(4096);): int;
declare RenameDirectory(aNodeSelected : int; aBinDirPath : alpha(4096);): int;
declare ImportObject(aDlsHdl : int; aNodeSelected : int; aBinDirPath : alpha(4096); aExtFilePath : alpha(4096)): int;
declare ExportObject(aDlsHdl : int; aLineSelect : int; aBinDirPath : alpha(4096)): int;
declare ComDialog(aDialogOption : alpha; aParentObj    : int;): alpha;
declare BlobErrMsg(aAktion : int; aErr : int; opt aObjName : alpha(4096););



MAIN()
begin
  // Variablenbereich allokieren
  VarAllocate(VAR_Frm_BinData);

  // Dialog anzeigen
  gFrm_BinData # WinOpen('BinData',_WinOpenDialog)
  gFrm_BinData->WinDialogRun(_WinDialogCenterScreen);
  gFrm_BinData->WinClose()

  // Variablenbereich freigeben
  VarFree(VAR_Frm_BinData);
end


//******************************************************************
// Initialisierung von Objekten
//
sub EvtInit
(
  aEvt : event;
)
: logic;
begin
  switch(aEvt:Obj->wpName)
  begin
    // Treeview der Verzeichnisse der binaeren Objekte
    case 'trvBinDir' :
    begin
      // Alle Beinaeren Objekte einer Datenbank anzeigen
      ShowBinDirectory(aEvt:Obj,0) ;
    end

    // Umbenennen von binaeren Objekten
    case 'BinRename' :
    begin
      // Name des umzunennenden Objektes in das Eingabefeld setzen
      $aedRename->wpCaption # gDirRename;
    end

    case 'BinPic' :
    begin
      // Bild in Objekt setzen
      $picBinData->wpCaption # '>0'+gPicPath;

      // Name und Pfad des Bildes in der Titelleiste des Frames anzeigen
      aEvt:Obj->wpCaption # 'Bild anzeigen - '+gPicPath;
    end
  end
end


//******************************************************************
// Auswertung der Toolbarbuttons oder Menupunkte
//
sub EvtMenuCommand
(
  aEvt              : event;
  aMenuItem         : int;
)
: logic;
  local
  begin
    tDirNameSelected : alpha;
    tDirHdlSelected  : int;
    tNewDirHdl       : int;
    tNodeSelected    : int;
    tNewNode         : int;
    tNodePrev        : int;
    tErr             : int;
    tDlgHdl          : int;
    tExtObjPath      : alpha(4096);
    tNewObjHdl       : int;
    tLineSelect      : int;
    tBinDirPath      : alpha(4096);
    tExpObjName      : alpha;
    tExpObjHdl       : int;
    tFocusHdl        : int;
    tObjName         : alpha;
    tNewDirName      : alpha;
    tCnt             : int;
  end
begin
  // selektierten Knoten ermitteln
  tNodeSelected # $trvBinDir->wpCurrentInt;

  // Kontrolle wenn der Fokus auf dem RootKnoten liegt
  if (tNodeSelected != 0 AND tNodeSelected->wpName = 'Root')
    tNodeSelected # 0;

  if (tNodeSelected != 0)
  begin
    tBinDirPath # FindTreePath(tNodeSelected)
  end

  switch(aMenuItem->wpName)
  begin
    // Verzeichnis loeschen
    case 'tbnDeleteBin' :
    begin
      tFocusHdl # WinFocusGet()
      if(tFocusHdl != 0)
      begin
        // binaeres Verzeichnis selektiert ?
        if(WinInfo(tFocusHdl,_WinType) = _WinTypeTreeview)
        begin
          if(tNodeSelected != 0)
          begin
            if(WinDialogBox(WinInfo(aEvt:Obj,_winFrame),'Binäres Verzeichnis loeschen ?',
              'Möchten Sie das Verzeichnis "'+tNodeSelected->wpCaption+'" mit allen Unterverzeichnissen wirklich löschen ?',
               _WinIcoQuestion,_WinDialogYesNoCancel,3) = _WinIdYes)
            begin
              tErr # DeleteDirectory($trvBinDir,tNodeSelected,tBinDirPath)
              if(tErr != _ErrOk)
              begin
                BlobErrMsg(sAktionDirDelete,tErr,tNodeSelected->wpCaption)
              end
            end
          end
          else
          begin
            tNodeSelected # $trvBinDir->wpCurrentInt;
            if(tNodeSelected->wpName != 'Root')
            begin
              WinDialogBox(WinInfo(aEvt:Obj,_WinFrame),'Verzeichnis löschen !',
              'Es ist kein Verzeichnisknoten zum löschen selektiert!',_WinIcoError,_WinDialogOk,1)
            end
            else
            begin
              WinDialogBox(WinInfo(aEvt:Obj,_WinFrame),'Verzeichnis löschen !',
              'Das Root-Verzeichnis kann nicht gelöscht werden!',_WinIcoError,_WinDialogOk,1)
            end
            return(false)
          end
        end

        // binaeres Objekt selektiert ?
        if(WinInfo(tFocusHdl,_WinType) = _WinTypeDataList)
        begin
          tLineSelect # $dlsBinObj->wpCurrentInt
          if (tLineSelect != 0)
          begin
            if (tNodeSelected != 0)
            begin
              tBinDirPath # FindTreePath(tNodeSelected)
            end
            WinLstCellGet($dlsbinObj,tObjName,1,tLineSelect)
            if(WinDialogBox(WinInfo(aEvt:Obj,_winFrame),'Binäres Objekt löschen ?',
              'Möchten Sie das Objekt "'+tObjName+'" wirklich löschen ?',
               _WinIcoQuestion,_WinDialogYesNoCancel,3) = _WinIdYes)
            begin
              tErr # DeleteObject($dlsBinObj,tLineSelect,tBinDirPath+'\'+tObjName)
              if(tErr != _ErrOk)
              begin
                BlobErrMsg(sAktionObjDelete,tErr,tObjName)
              end
              else
              begin
                // Zaehler der Objekte erniedrigen
                tCnt # CNVIA($lblCntObj->wpCaption);
                dec(tCnt)
                $lblCntObj->wpCaption # CNVAI(tCnt)+'   ';
              end
            end
          end
          WinUpdate($dlsBinObj,_WinUpdOn);
        end
      end
    end

    // Verzeichnis anlegen
    case 'tbnNewDir' :
    begin
      if(tNodeSelected != 0)
      begin
        tErr # CreateDirectory($trvBinDir,tNodeSelected,tBinDirPath)
        if(tErr < 0)
        begin
          BlobErrMsg(sAktionDirOpen,tErr,tNodeSelected->wpCaption)
        end
      end
      else
      begin
        // neues Verzeichnis im Rootverzeichnis anlegen
        tErr # CreateDirectory($trvBinDir,gNodeRoot,'')
        if(tErr < 0)
        begin
          BlobErrMsg(sAktionDirOpen,tErr,gNodeRoot->wpCaption)
        end
      end
    end

    // Verzeichnis umbennen
    case 'tbnRenameDir' :
    begin
      if (tNodeSelected != 0)
      begin
        tErr # RenameDirectory(tNodeSelected,tBinDirPath)
        if(tErr < 0)
        begin
          BlobErrMsg(sAktionDirOpen,tDirHdlSelected,tNodeSelected->wpCaption)
        end
        else
        begin
          // Pfad auf das Verzeichnis neu setzen
          gBinDirPath # FindTreePath(tNodeSelected)
        end
      end
    end

    case 'tbnObjImport' :
    begin
      // Ausgangsverzeichnis ermitteln
      if (tNodeSelected != 0)
      begin
        tExtObjPath # ComDialog(_WinComFileOpen,gFrm_BinData);
        if (tExtObjPath != '')
        begin
          tErr # ImportObject($dlsBinObj,tNodeSelected,tBinDirPath,tExtObjPath)
          if (tErr < 0)
          begin
            BlobErrMsg(sAktionObjImport,tErr,FsiSplitName(tExtObjPath,_FsiNameNE))
          end
          else
          begin
            // Zaehler der Objekte erhoehen
            tCnt # CNVIA($lblCntObj->wpCaption);
            inc(tCnt)
            $lblCntObj->wpCaption # CNVAI(tCnt)+'   ';
          end
        end
      end
      WinUpdate($dlsBinObj,_WinUpdOn)
    end

    // Objekt exportieren
    case 'tbnObjExport' :
    begin
      tLineSelect # $dlsBinObj->wpCurrentInt
      if (tLineSelect != 0)
      begin
        ExportObject($dlsBinObj,tLineSelect,tBinDirPath)
      end
    end
  end

  // Refresh des Tree
  WinUpdate($trvBinDir,_WinUpdOn)
end


//******************************************************************
// Klicken eines Buttons
//
sub EvtClicked
(
  aEvt : event;
)
: logic;
begin
  switch(aEvt:Obj->wpName)
  begin
    case 'btnShowPic' :
    begin
      gPicPath # gbinDirPath+'\'+gPicName;
      WinDialog('BinPic',_WinDialogCenter,gFrm_BinData)
    end
  end
end

//******************************************************************
// Selektieren eines Knotens im Tree
//
sub EvtNodeSelect
(
  aEvt  : event;
  aNode : int;
)
: logic;
  local
  begin
    tBinDirHdl : int;
  end
begin
  switch(aEvt:Obj->wpName)
  begin
    // Datalist der beniaeren Objekte
    case 'trvBinDir' :
    begin
      if (aNode->wpName = 'Root')
      begin
        gFrm_BinData->wpCaption # 'Objektbrowser - Root'
        $lblCntObj->wpCaption # '0   ';
        // in das Rootverzeichnis könne keine Dateien importiert werden
        $tbnRenameDir->wpDisabled # true;
        $tbnObjImport->wpDisabled # true;
        $tbnObjExport->wpDisabled # true;
        $tbnDeleteBin->wpDisabled # true;
        // Alle Zeilen aus der DataList loeschen
        // da das Root-Verzeichnis keine binaeren Objekte enthalten kann
        WinLstDatLineRemove($dlsBinObj,_WinLstDatLineAll);
        return(true);
      end
      else
      begin
        $tbnRenameDir->wpDisabled # false;
        $tbnObjImport->wpDisabled # false;
        $tbnObjExport->wpDisabled # false;
        $tbnDeleteBin->wpDisabled # false;
      end

      // Lesen des Verzeichnisse
      gBinDirPath # FindTreePath(aNode)

      gFrm_BinData->wpCaption # 'Objektbrowser - '+gBinDirPath
      tBinDirHdl # BinDirOpen(0,gBinDirPath)
      if(tBinDirHdl > 0)
      begin
        $lblCntObj->wpCaption # CNVAI(FillDlsBinObjects($dlsBinObj,tBinDirHdl))+'   ';
        BinClose(tBinDirHdl)
      end
      else
      begin
        BlobErrMsg(sAktionDirOpen,tBinDirHdl,gBinDirPath)
      end
    end
  end
end

//******************************************************************
// Selektieren einer Zeile in der Liste
//
sub EvtLstSelect
(
  aEvt   : event;
  aRecID : int;
)
: logic;
  local
  begin
    tMimeType : alpha;
  end
begin
  switch(aEvt:Obj->wpName)
  begin
    case 'dlsBinObj':
    begin
      if (aRecID != 0)
      begin
        WinLstCellGet(aEvt:Obj,gPicName,1,aRecID);
        WinLstCellGet(aEvt:Obj,tMimeType,11,aRecID);
        // Pfad und Name des Bildes zusammensetzen
        tMimeType # StrCnv(tMimeType,_STrUpper)
        if (tMimeType = 'BMP' OR tMimeType = 'JPG' OR tMimeType = 'TIF')
        begin
          $btnShowPic->wpDisabled # false;
        end
        else
        begin
          $btnShowPic->wpDisabled # true;
        end
      end
      else
      begin
        $btnShowPic->wpDisabled # true;
      end
    end
  end
end



//******************************************************************
// Verlust des Fokus eines Objektes
//
sub EvtFocusTerm
(
  aEvt              : event;
  aFocusObject      : int;
)
: logic;
  local
  begin
    tNodeSelected   : int;
    tDirHdlSelected : int;
    tDirPathSelected : alpha(4096);
    tErr             : int;
  end
begin
  // selektierten Knoten ermitteln
  tNodeSelected # $trvBinDir->wpCurrentInt;
  switch(aEvt:Obj->wpName)
  begin
    // Name des Verzeichnis
    case 'aedRename' :
    begin
      gDirRename # aEvt:Obj->wpCaption;
    end
  end

  return(true);
end


//******************************************************************
// Anzeige der binaeren Verzeichnisse in einem Treeview-Objekt
// * rekursiver Aufruf *
sub ShowBinDirectory
(
  aWinObj : int;
  aBinDir : int;
)
  local
  begin
    tDirHdl     : int;
    tDirName    : alpha;
    tTreeNodeDir : int;
    tRootHdl     : int;
  end
begin
  // Root-Knoten anlegen
  if (aWinObj->wpName = 'trvBinDir')
  begin
    gNodeRoot # WinTreeNodeAdd(aWinObj,'Root','Root');
    aWinObj # gNodeRoot;
    aWinObj->wpNodeStyle # _WinNodeRedBall;
    aWinObj->wpHelpTip # 'Wurzelknoten - nicht löschbar.'+SCR+'In diesem Verzeichnis können keine binären Objekte definiert werden.'
  end

  // Alle Verzeichnisse ermitteln
  tDirName # BinDirRead(aBinDir,_BinFirst|_BinDirectory)
  while(tDirName != '')
  begin
    // Knoten im Tree anlegen
    tTreeNodeDir # WinTreeNodeAdd(aWinObj,tDirName,tDirName)

    // Verzeichnis ueber den Namen oeffnen
    tDirHdl # BinDirOpen(aBinDir,tDirName)

    // komplette Pfad im Helptip des Knotens anzeigen
    if (tDirHdl > 0)
      tTreeNodeDir->wpHelpTip # tDirHdl->spFullName

    // Unterverzeichnisse zu diesem Verzeichnis ermitteln
    ShowBinDirectory(tTreeNodeDir,tDirHdl);

    // Verzeichnis wieder schliessen
    BinClose(tDirHdl);

    // naechsten Verzeichnis(Namen) ermitteln
    tDirName # BinDirRead(aBinDir,_BinNext|_BinDirectory)
  end
end


//******************************************************************
// Anzeige der binaeren Objekte zu einem Ausgangsverzeichnis in
// einem DataList-Objekt
sub FillDlsBinObjects
(
  aDlsHdl           : int;
  aBinDir           : int;

)
: int;
  local
  begin
    tObjName : alpha;
    tObjHdl  : int;
    tCntObj  : int;
    tLine    : int;
  end
begin
  tCntObj # 0;
  aDlsHdl->WinUpdate(_WinUpdOff)
  WinLstDatLineRemove(aDlsHdl,_WinLstDatLineAll);
  // alle Objekte zu diesem Verzeichnis ermitteln
  tObjName # BinDirRead(aBinDir,_BinFirst)

  while(tObjName != '')
  begin
    tObjHdl # BinOpen(aBinDir,tObjName);
    tLine # WinLstDatLineAdd(aDlsHdl,tObjName,_WinLstDatLineLast);
    if(tObjHdl > 0)
    begin
      // Fuellen der Datalist mit dem Objekt
      FillDlsBinInfo(aDlsHdl,tObjHdl,tLine)
      inc(tCntObj)
    end
    tObjName # BinDirRead(aBinDir,_BinNext);
    BinClose(tObjHdl);
  end
  aDlsHdl->WinUpdate(_WinUpdOn)

  return(tCntObj)
end

//******************************************************************
// Anzeige der Eigenschaften eines binaeren Verzeichnis oder Objektes
// in einem DatList-Objekt
sub FillDlsBinInfo(
  aDlsHdl    : int;
  aObjHdl    : int;
  aLine      : int;
)
local begin
    tCaltime  : caltime;
    tTime     : time;
    tDate     : date;
end
begin
  // Eigenschaften des Objektes in die Spalten setzen
  WinLstCellSet(aDlsHdl,aObjHdl->spSizeOrg,2,aLine);
  tCaltime # aObjHdl->spcreated;//spTimeExternal;
  tDate # tCaltime->vpDate;
  tTime # tCaltime->vpTime;
  WinLstCellSet(aDlsHdl,CNVAD(tDate)+' '+CNVAT(tTime,_FmtTimeSeconds),3,aLine)
  WinLstCellSet(aDlsHdl,aObjHdl->spSizeDba,4,aLine)
  WinLstCellSet(aDlsHdl,aObjHdl->spCompression,5,aLine)
  tCaltime # aObjHdl->spCreated
  tDate # tCaltime->vpDate;
  tTime # tCaltime->vpTime;
  WinLstCellSet(aDlsHdl,CNVAD(tDate)+' '+CNVAT(tTime,_FmtTimeSeconds),6,aLine)
  WinLstCellSet(aDlsHdl,aObjHdl->spCreatedUser,7,aLine)
  tCaltime # aObjHdl->spModified
  tDate # tCaltime->vpDate;
  tTime # tCaltime->vpTime;
  WinLstCellSet(aDlsHdl,CNVAD(tDate)+' '+CNVAT(tTime,_FmtTimeSeconds),8,aLine)
  WinLstCellSet(aDlsHdl,aObjHdl->spModifiedUser,9,aLine)
  WinLstCellSet(aDlsHdl,aObjHdl->spTypeUser,10,aLine)
  WinLstCellSet(aDlsHdl,aObjHdl->spTypeMime,11,aLine)
  WinLstCellSet(aDlsHdl,aObjHdl->spId,12,aLine)
  WinLstCellSet(aDlsHdl,aObjHdl->spCustom,13,aLine)
end


//******************************************************************
// Ermitteln des Pfades zu einem Objekt mit Hilfe der Treeknoten
// * rekursiver Aufruf *
sub FindTreePath
(
  aNode : int;
)
: alpha;
  local
  begin
    tNodeParent     : int;
    tPath           : alpha(4096);
  end
begin
  tNodeParent # WinInfo(aNode,_WinParent);
  if (tNodeParent != 0 AND
      WinInfo(tNodeParent,_WinType)=_WinTypeTreeNode AND
      tNodeParent->wpName != 'Root')
  begin
    tPath # FindTreePath(tNodeParent)
  end
  tPath # tPath+'\'+aNode->wpCaption;
  return(tPath)
end

//******************************************************************
// Binaeres Verzeichnis mit allen Unterverzeichnissen und Objekten
// loeschen
sub DeleteDirectory
(
  aTreeHdl      : int;
  aNodeSelected : int;
  aBinDirPath   : alpha(4096);
)
: int;
  local
  begin
    tNodePrev : int;
    tErr      : int;
  end
begin
  // Verzeichnis loeschen
  tErr # BinDirDelete(0,aBinDirPath,_BinDeleteAll)
  if (tErr = _ErrOk)
  begin
    // vorherigen Knoten ermitteln
    tNodePrev # WinInfo(aNodeSelected,_WinPrev);

    WinTreeNodeRemove(aNodeSelected);

    // vorherigen Knoten oder keinen Knoten selektieren
    if (tNodePrev != 0)
    begin
      aTreeHdl->wpCurrentInt # tNodePrev;
    end
    else
    begin
      aTreeHdl->wpCurrentInt # 0;
    end

  end
  // Fehlercode zurueckgeben
  return(tErr);
end


//******************************************************************
// Binaeres Objekt loeschen
//
sub DeleteObject
(
  aDlsHdl           : int;
  aLineSelect       : int;
  aBinObjPath       : alpha(4096);
)
: int;
  local
  begin
    tErr            : int;
  end
begin
  // Objekt loeschen
  tErr # BinDelete(0,aBinObjPath)
  if (tErr = _ErrOk)
  begin
    // Zeile aus der DataList entfernen
    WinLstDatLineRemove(aDlsHdl,aLineSelect);
  end

  // Fehlercode zurueckgeben
  return(tErr);
end

//******************************************************************
// Binaeres Verzeichnis erstellen
//
sub CreateDirectory
(
  aTreeHdl           : int;
  aNodeSelected      : int;
  aCurrentPath       : alpha(4096);
)
: int;
  local
  begin
    tDirHdlSelected : int;
    tNewDirName     : alpha;
    tNewDirHdl      : int;
    tCnt            : int;
    tNewNode        : int;
    tErr            : int;
  end
begin
  // Ausgangsverzeichnis ermitteln
  if (aCurrentPath != '')
  begin
    tDirHdlSelected # BinDirOpen(0,aCurrentPath)
    tErr # tDirHdlSelected
  end
  else
  begin
    tErr # 0;
  end

  if(tDirHdlSelected > 0 OR aCurrentPath = '')
  begin
    tNewDirName # 'Neues Verzeichnis';
    // zuvor Pruefen ob ein verzeichnis mit deisem Namen schon  vorhanden ist
    if(aCurrentPath = '')
    begin
      // neues Verzeichnis im Ausgangsverzeichnis anlegen
      tNewDirHdl # BinDirOpen(0,tNewDirName);
    end
    else
    begin
      // neues Verzeichnis im aktuell selektierten Verzeichnis anlegen
      tNewDirHdl # BinDirOpen(tDirHdlSelected,tNewDirName);
    end

    tCnt # 2;
    while (tNewDirHdl > 0)
    begin
      tNewDirName # 'Neues Verzeichnis('+CNVAI(tCnt)+')';
      BinClose(tNewDirHdl)
      if(aCurrentPath = '')
        tNewDirHdl # BinDirOpen(0,tNewDirName);
      else
        tNewDirHdl # BinDirOpen(tDirHdlSelected,tNewDirName);

      inc(tCnt)
    end

    // neues Verzeichnis anlegen ausghend vom selektierten Verzeichnis
    if (aCurrentPath = '')
      tNewDirHdl # BinDirOpen(0,tNewDirName,_BinCreate);
    else
      tNewDirHdl # BinDirOpen(tDirHdlSelected,tNewDirName,_BinCreate);

    if(tNewDirHdl > 0)
    begin
      // neuen Knoten im Tree fuer das Verzeichnis anlegen
      tNewNode # WinTreeNodeAdd(aNodeSelected,tNewDirName,tNewDirName);
      // Neu angelegten Knoten im Tree selektieren
      aTreeHdl->wpCurrentInt # tNewNode;
    end
    else
    begin
      BlobErrMsg(sAktionDirCreate,tNewDirHdl,tNewDirName)
    end

    // Ausgangsverzeichnis wieder schliessen
    if (tDirHdlSelected > 0)
      BinClose(tDirHdlSelected)

    // Neu angelegtes Verzeichnis schliessen
    if (tNewDirHdl > 0)
    begin
      // Neu angelegtes Verzeichnis wieder schliessen
      BinClose(tNewDirHdl);
    end
  end

  // Fehlercode zurueckgeben
  return(tErr);
end

//******************************************************************
// Binaeres Verzeichnis umbennen
//
sub RenameDirectory
(
  aNodeSelected     : int;
  aBinDirPath       : alpha(4096);
)
: int;
  local
  begin
    tErr            : int;
    tDirHdlSelected : int;
  end
begin
  tDirHdlSelected # BinDirOpen(0,aBinDirPath,_BinLock)
  if (tDirHdlSelected > 0)
  begin
    gDirRename # aNodeSelected->wpCaption;

    // Dialog zur Aenderung aufrufen
    if(WinDialog('BinRename',_WinDialogCenter,WinInfo(aNodeSelected,_winFrame))=_WinIdOk AND
       gDirRename != aNodeSelected->wpCaption AND gDirRename != '')
    begin
      tErr # BinRename(tDirHdlSelected,gDirRename)
      if (tErr = _ErrOk)
      begin
        aNodeSelected->wpName # gDirRename;
        aNodeSelected->wpCaption # gDirRename;
      end
      else
      begin
        BlobErrMsg(sAktionRename,tErr,gDirRename);
      end
      WinUpdate(aNodeSelected,_WinUpdOn)
    end
    BinClose(tDirHdlSelected);
  end
  return(tDirHdlSelected)
end


//******************************************************************
// Binaeres Objekt importieren
//
sub ImportObject
(
  aDlsHdl           : int;
  aNodeSelected     : int;
  aBinDirPath       : alpha(4096);
  aExtFilePath      : alpha(4096);
)
: int;
  local
  begin
    tDirHdlSelected : int;
    tNewObjHdl      : int;
    tFileName       : alpha;
    tErr            : int;
    tLine           : int;
  end
begin
  tDirHdlSelected # BinDirOpen(0,aBinDirPath)
  if (tDirHdlSelected > 0 AND aExtFilePath != '')
  begin
    // binaeres Objekt erzeugen
    tFileName # FsiSplitName(aExtFilePath,_FsiNameNE)
    // Zuvor Pruefen ob ein Objekte mit diesem Namen schon vorhanden ist
    tNewObjHdl # BinOpen(tDirHdlSelected,tFileName)
    if (tNewObjHdl > 0)
    begin
      // Objekt mit diesem Name existiert schon
      if (tDirHdlSelected != 0)
      begin
        BinClose(tDirHdlSelected)
      end
      BinClose(tNewObjHdl);
      return(sObjExists);
    end

    tNewObjHdl # BinOpen(tDirHdlSelected,tFileName,_BinCreate|_BinLock)
    if(tNewObjHdl <= 0)
    begin
      if(tDirHdlSelected != 0)
      begin
        // Ausgangsvereichnis wieder schliessen
        BinClose(tDirHdlSelected);
      end
      return(tNewObjHdl)
    end

    // und importieren (ohne Verschluesselung)
    tErr # BinImport(tNewObjHdl,aExtFilePath,$iedKompression->wpCaptionInt)
    if(tErr != _ErrOk)
    begin
      BinClose(tNewObjHdl)
      return(tErr)
    end
    else
    begin
      // Eigenschaften des Objektes setzen
      tNewObjHdl->spTypeMime # FsiSplitName(aExtFilePath,_FsiNameE);
      // Aenderungen der Eigenschaften speichern
      tNewObjHdl->BinUpdate()
      // Zeile hinzufuegen
      tLine # WinLstDatLineAdd(aDlsHdl,tNewObjHdl->spName,_WinLstDatLineLast)
      // Eigenschaften des Objektes in der Liste anzeigen
      FillDlsBinInfo(aDlsHdl,tNewObjHdl,tLine)
      tNewObjHdl->BinClose();
    end

    if(tDirHdlSelected != 0)
    begin
      // Ausgangsvereichnis wieder schliessen
      BinClose(tDirHdlSelected);
    end
  end
  return(tDirHdlSelected)
end

//******************************************************************
// Binaeres Objekt exportieren
//
sub ExportObject
(
  aDlsHdl           : int;
  aLineSelect       : int;
  aBinDirPath       : alpha(4096)
)
: int;
  local
  begin
    tExpObjName     : alpha;
    tExpObjHdl      : int;
    tExpFilePath    : alpha(4096);
    tPathName       : alpha;
    tFileName       : alpha;
    tErr            : int;
  end
begin
  WinLstCellGet($dlsBinObj,tExpObjName,1,aLineSelect)
  tExpObjHdl # BinOpen(0,aBinDirPath+'\'+tExpObjName)
  if (tExpObjHdl < 0)
  begin
    BlobErrMsg(sAktionObjOpen,tExpObjHdl,tExpObjName)
    return(0)
  end
  else
  begin
    tExpFilePath # ComDialog(_WinComFileSave,gFrm_BinData)
    tPathName # FsiSplitName(tExpFilePath,_FsiNameP)
    tFileName # FsiSplitName(tExpFilePath,_FsiNameNE)
    if (tPathName != '' AND tFileName  != '')
    begin
     tErr # BinExport(tExpObjHdl,tExpFilePath)
      if (tErr != _ErrOk)
      begin
        BlobErrMsg(sAktionObjExport,tErr,tExpObjName)
      end
    end
    BinClose(tExpObjHdl)
  end
  return(tErr)
end

//******************************************************************
// Common-Dialog zur Ausahl der Dateinamen fuer
// das Exportieren und Importieren von binaeren Objekten
sub ComDialog
(
  aDialogOption : alpha;
  aParentObj    : int;
)
: alpha;
  local
  begin
    tDlgHdl      : int;
    tRet         : alpha(4096);
    tDialogTitel : alpha;
  end
begin
  if (aDialogOption = _WinComFileOpen)
  begin
    tDialogTitel # 'CONZEPT 16 - Import binärer Objekte.'
  end
  else
  begin
    tDialogTitel # 'CONZEPT 16 - Export binärer Objekte.'
  end

  // Dialog oeffnen
  tDlgHdl # WinOpen(aDialogOption)

  // Eigenschaften des Dialoges setzen
  tDlgHdl->wpCaption # tDialogTitel
  // FileFilter setzen
  tDlgHdl->wpFileFilter # 'Alle Dateien (*.*)|*.*|TEXT (*.txt)|*.txt|Word-Dokumente (*.doc)|*.doc|'+
                          'JPEG (*.jpg)|*.jpg|Bitmap (*.bmp)|*.bmp|TIFF (*.tif)|*.tif|Ressourcen (*.rsc)|*.rsc';
  tDlgHdl->wpFileFilterNum # 1;
  tDlgHdl->wpFlags # _WinComOverwritePrompt|_WinComCreatePrompt|_WinComExplorer;

  WinDialogRun(tDlgHdl,_WinDialogCenterScreen,aParentObj)

  tRet # tDlgHdl->wpPathName+tDlgHdl->wpFileName;

  // Dialog wieder schliessen
  WinClose(tDlgHdl);

  return(tRet)
end

//******************************************************************
// Ausgabe von Fehlermeldung im Zusammenhang mit Operationen von
// binaeren Objekten
sub BlobErrMsg
(
  aAktion           : int;
  aErr              : int;
  opt aObjName      : alpha(4096);
)
  local
  begin
    tErrText : alpha(1024);
    tAktText : alpha(1024);
    tZusText : alpha(1024);
  end
begin
  // Fehlertext zusammensetzen
  switch(aErr)
  begin
    case _ErrBinData :
      tErrText  # 'Falsches Codewort angegeben.'
    case _ErrBinDirNotEmpty :
      tErrText  # 'Verzeichnis ist nicht leer.'
    case _ErrBinExists :
      tErrText  # 'Binäres Objekt existiert bereits.'
    case _ErrBinLocked :
      tErrText  # 'Das binäre Objekt ist gesperrt.'
    case _ErrBinNameInvalid :
      tErrText  # 'Ungültiger Name.'
    case _ErrBinNoData :
      tErrText  # 'Keine Daten vorhanden.'
    case _ErrBinNoFile :
      tErrText  # 'Externe Datei nicht vorhanden.'
    case _ErrBinNoLock :
      tErrText  # 'Binäres Objekt nicht gesperrt.'
    case _ErrBinOperation :
    begin
      tErrText  # 'Operation kann nicht ausgeführt werden.'+sCR
      tErrText  # tErrText + 'Entweder wurde die maximale Anzahl von 60 Ebenen erreicht,'+SCR
      tErrText  # tErrText + 'oder es wurde versucht ein binäres Objekte im Wurzelverzeichnis anzulegen.'
    end
    case _ErrBinNoPath :
      tErrText  # 'Pfad nicht vorhanden.'
    case _ErrFsiNoPath :
      tErrText  # 'Pfad nicht vorhanden.'
    case _ErrFsiOpenOverflow :
      tErrText  # 'Zuviele offene Dateien.'
    case _ErrFsiAccessDenied :
      tErrText  # 'Zugriff verweigert.'
    case _ErrFsiHdlInvalid :
      tErrText  # 'Ungültiger Dateideskriptor.'
    case _ErrFsiDriveInvalid :
      tErrText  # 'Ungültige Laufwerksangabe.'
    case _ErrFsiSharingViolation :
      tErrText  # 'Zugriffskonflikt bei externer Datei.'
    case _ErrFsiLockViolation :
      tErrText  # 'Sperrkonflikt in externer Datei.'
    case _ErrFsiOpenFailed :
      tErrText  # 'Externe Datei konnte nicht geöffnet oder angelegt werden.'
    case _rDeadLock :
      tErrText  # 'Es ist eine Verklemmung aufgetreten.'

    case sObjExists :
      tErrText  # 'Objekt mit diesem Namen existiert in dem ausgewählten Verzeichnis schon.'

  end

  // Aktion abfragen
  switch(aAktion)
  begin
    case sAktionDirOpen :
      tAktText # 'Fehler beim Öffnen eines Verzeichnisses.'
    case sAktionDirCreate :
      tAktText # 'Fehler beim Erstellen eines Verzeichnisses.'
    case sAktionDirDelete :
      tAktText # 'Fehler beim Löschen eines Verzeichnisses.'
    case sAktionObjOpen :
      tAktText # 'Fehler beim Öffnen eines binären Objektes.'
    case sAktionObjCreate :
      tAktText # 'Fehler beim Erzeugen eines binären Objektes.'
    case sAktionObjImport :
      tAktText # 'Fehler beim Importieren eines binären Objektes.'
    case sAktionObjExport :
      tAktText # 'Fehler beim Exportieren eines binären Objektes.'
    case sAktionObjDelete :
      tAktText # 'Fehler beim Löschen eines binären Objektes'
    case sAktionRename :
      tAktText # 'Fehler beim Umbennenen eines binären Objektes.'
  end

  if(aObjName != '')
  begin
    tZusText # 'Objekt : "'+aObjName+'"'
  end

  // Fehlermeldung ausgeben
  WinDialogBox($BinData,'Fehler binäre Objekte!',
  tAktText +SCR+ tErrText +SCR+ tZusText +SCR+ 'Fehlernummer : '+CNVAI(aErr,_FmtNumNoGroup),
  _WinIcoError,_WinDialogOk,1)
end

