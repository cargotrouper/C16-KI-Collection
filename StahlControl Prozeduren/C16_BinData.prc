// ******************************************************************
// * BinData                                                        *
//                    OHNE E_R_G
// *                                                                *
// * Prozedur zum Steuern der Dialoges BinDat | BinInfo | BinRename *
// *                                                                *
// * Dialog: BinData=C16.BinData                                    *
// *                                                                *
// * Erstellt: 20.05.2003 / vectorsoft AG                           *
// * Geändert: 20.09.2005 / vectorsoft AG (SplitGroup-Objekt)       *
// ******************************************************************

@A+
@C+

define
{
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

  // eigene definierte Fehlercodes
  sObjExists      : -1600

}

global VAR_Frm_BinData
{
  gGroupSplit    : int;
  gtUebersicht   : int;
  gtBild         : int;
  gtObjekte      : int;
  gToolbar       : int;
  gWindowbar     : int;

  // Deskriptor des Dialoges
  gFrm_BinData   : int;

  // Name der Umbenennung von Objekten
  gDirRename     : alpha;

  // Selektiertes Objekte dass im Info-Dialog angezeigt wird.
  gBinSelected   : int;
  gTypeSelected  : int;

  // Deskriptor des Root-Knotens
  gNodeRoot      : int;

  gBinDirPath    : alpha(4096);

  gPicName       : alpha(250);
  gPicPath       : alpha(4096);
  gBinObjCnt     : int;
}

// Vordeklaration der Funktionen
declare EvtInit(aEvt : event;): logic;
declare EvtMenuCommand(aEvt : event; aMenuItem : int;): logic;
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
declare PrintObject(aDlsHdl : int; aLineSelect : int; aBinDirPath : alpha(4096);) : int;
declare ComDialog(aDialogOption : alpha; aParentObj    : int;): alpha;
declare BlobErrMsg(aAktion : int; aErr : int; opt aObjName : alpha(4096););

main()
{
  // Variablenbereich allokieren
  VarAllocate(VAR_Frm_BinData);

  // Dialog anzeigen
  gFrm_BinData # WinOpen('C16.BinData',_WinOpenDialog)
  gFrm_BinData->WinDialogRun(_WinDialogCreateHidden | _WinDialogCenter);
  gFrm_BinData->WinClose()

  // Variablenbereich freigeben
  VarFree(VAR_Frm_BinData);
}

// ******************************************************************
// *  Änderung der Größe des Frames                                 *
// ******************************************************************

sub EvtPosChanged
(
  aEvt        : event; // Ereignis
  aRect       : rect;  // Größe des Fensters
  aClientSize : point; // Größe des Client-Bereichs
  aFlags      : int;   // Aktion
) : logic

local
{
  tRect : rect
}

{
  tRect:right  # aClientSize:x;
  tRect:bottom # aClientSize:y;
  gGroupSplit->wpArea # tRect;
}

// ******************************************************************
// *  Ermitteln der sichtbaren GroupTiles                           *
// ******************************************************************

sub CountActive : int

local
{
  tObj  : int;
  tCnt  : int
}

{
  tObj # gGroupSplit->WinInfo(_WinFirst, 0, _WinTypeGroupTile);
  while ((tObj != 0))
  {
    if (tObj->wpVisible) inc(tCnt);
    tObj # tObj->WinInfo(_WinNext, 0, _WinTypeGroupTile);
  }
  return tCnt;
}

// ******************************************************************
// *  Ermitteln des aktiven GroupTile-Objekts                       *
// ******************************************************************

sub CheckMaximized : int

{
  return gGroupSplit->WinInfo(_WinObject, _WinObjectMaximized);
}

// ******************************************************************
// *  Änderung des Attach-States                                    *
// ******************************************************************

sub EvtAttachState
(
  aEvt        : event;  // Ereignis
  aMode       : int;    // Ereignis-Modus
  aStateOld   : int;    // bisheriger attach-state
  aStateNew   : int;    // neuer attach-state
  aReason     : int;    // Grund für die Änderung des attach-state
) : logic

local
{
  tVisible    : logic;
}

{
  switch (aMode)
  {
    case _WinModeAttachChanged :
    {
      tVisible # aStateNew != _WinStateAttachClosed;
      gToolbar->wpDisabled   # !gtUebersicht->wpVisible;
      gWindowbar->wpDisabled # !gtUebersicht->wpVisible;

      switch (aEvt:Obj->wpName)
      {
        case 'gtUebersicht' : $miUebersicht->wpMenuCheck # tVisible;
        case 'gtObjekte'    : $miObjekte->wpMenuCheck # tVisible;
        case 'gtBild'       : $miBild->wpMenuCheck # tVisible;
      }
    }

    case _WinModeAttachQuery :
    {
      if (CountActive() = 1 and aStateNew = _WinStateAttachClosed)
        return(false);
    }
  }
  return(true);
}

// ******************************************************************
// *  Initialisierung von Objekten                                  *
// ******************************************************************

sub EvtInit
(
  aEvt : event;
) : logic;

{
  switch(aEvt:Obj->wpName)
  {
    // Treeview der Verzeichnisse der binaeren Objekte
    case 'trvBinDir' :
    {
      // Alle Beinaeren Objekte einer Datenbank anzeigen
      ShowBinDirectory(aEvt:Obj,0) ;
    }

    // Umbenennen von binaeren Objekten
    case 'C16.BinRename' :
    {
      // Name des umzunennenden Objektes in das Eingabefeld setzen
      $aedRename->wpCaption # gDirRename;
    }

    case 'C16.BinData' :
    {
      gGroupSplit  # aEvt:Obj->WinSearch('GsBinData');
      gtUebersicht # aEvt:Obj->WinSearch('gtUebersicht');
      gtBild       # aEvt:Obj->WinSearch('gtBild');
      gtObjekte    # aEvt:Obj->WinSearch('gtObjekte');
      gToolbar     # aEvt:Obj->WinSearch('tbToolbar');
      gWindowbar   # aEvt:Obj->WinSearch('wbWindowbar');
    }
  }
}

// ******************************************************************
// *  Initialisierung des Menüfensters                              *
// ******************************************************************

sub EvtMenuInitPopup
(
  aEvt      : event; // Ereignis
  aMenuItem : int    // auslösender Menüeintrag
) : logic

{
  if (gGroupSplit->wpStyleGroup = _WinStyleGroupTileBaseLT)
    $miDarstellung->wpCaption # '&Darstellung rechts'
  else
    $miDarstellung->wpCaption # '&Darstellung links';

  $miSymbol->wpMenuCheck     # gToolbar->wpVisible;
  $miSymbol->wpMenuCheck     # gWindowbar->wpVisible;

  return(true);
}

// ******************************************************************
// *  Unsichtbare GroupTiles wiederherstellen                       *
// ******************************************************************

sub RestoreAll
{
  if (!gtBild->wpVisible)
    gtBild->wpVisible # true;

  if (!gtUebersicht->wpVisible)
    gtUebersicht->wpVisible # true;

  if (!gtObjekte->wpVisible)
    gtObjekte->wpVisible # true;

   gtBild->WinUpdate(_WinUpdState, _WinStateAttachNormal);
   gtUebersicht->WinUpdate(_WinUpdState, _WinStateAttachNormal);
   gtObjekte->WinUpdate(_WinUpdState, _WinStateAttachNormal);
}

// ******************************************************************
// *  Auswertung der Toolbarbuttons oder Menupunkte                 *
// ******************************************************************

sub EvtMenuCommand
(
  aEvt              : event;
  aMenuItem         : int;
) : logic;

local
{
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
  tMaxiMized       : int;
  tCnt             : int;
}

{
  // selektierten Knoten ermitteln
  tNodeSelected # $trvBinDir->wpCurrentInt;

  // Kontrolle wenn der Fokus auf dem RootKnoten liegt
  if (tNodeSelected != 0 AND tNodeSelected->wpName = 'Root')
    tNodeSelected # 0;

  if (tNodeSelected != 0)
    tBinDirPath # FindTreePath(tNodeSelected)

  switch(aMenuItem->wpName)
  {
    // GroupTile 'Uebersicht' ein-/ausblenden
    case 'miUebersicht' :
    {
      tMaxiMized # CheckMaxiMized();
      if (tMaxiMized > 0)
      {
        if (gtUebersicht->WinInfo(_WinState) = _WinStateAttachMaximized)
        {
          RestoreAll();
          return true;
        }

        tMaxiMized->WinUpdate(_WinUpdState,_WinStateAttachNormal);
        gtUebersicht->WinUpdate(_WinUpdState,_WinStateAttachMaximized);
      }
      else gtUebersicht->wpVisible # !gtUebersicht->wpVisible;

      aMenuItem->wpMenuCheck # gtUebersicht->wpVisible;
    }

    // GroupTile 'Liste' ein-/ausblenden
    case 'miObjekte' :
    {
      tMaxiMized # CheckMaxiMized();
      if (tMaxiMized > 0)
      {
        if (gtObjekte->WinInfo(_WinState) = _WinStateAttachMaximized)
        {
          RestoreAll();
          return true;
        }
        tMaxiMized->WinUpdate(_WinUpdState,_WinStateAttachNormal);
        gtObjekte->WinUpdate(_WinUpdState,_WinStateAttachMaximized);
      }
      else gtObjekte->wpVisible # !gtObjekte->wpVisible;

      aMenuItem->wpMenuCheck # gtObjekte->wpVisible;
    }

    // GroupTile 'Bild' ein-/ausblenden
    case 'miBild' :
    {
      tMaxiMized # CheckMaxiMized();
      if (tMaxiMized > 0)
      {
        if (gtBild->WinInfo(_WinState) = _WinStateAttachMaximized)
        {
          RestoreAll();
          return true;
        }
        tMaxiMized->WinUpdate(_WinUpdState,_WinStateAttachNormal);
        gtBild->WinUpdate(_WinUpdState,_WinStateAttachMaximized);
      }
      else gtBild->wpVisible # !gtBild->wpVisible;

      aMenuItem->wpMenuCheck # gtBild->wpVisible;
    }

    // Darstellung rechts/links
    case 'miDarstellung' :
    {
      RestoreAll();
      if (StrFind($miDarstellung->wpCaption,'links',0) > 0)
        gGroupSplit->wpStyleGroup # _WinStyleGroupTileBaseLT
      else
        gGroupSplit->wpStyleGroup # _WinStyleGroupTileBaseRB;
    }

    // Symbolleiste ein-/ausblenden
    case 'miSymbol' :
    {
      gToolbar->wpVisible # !gToolbar->wpVisible;
      gWindowbar->wpVisible # !gWindowbar->wpVisible;
      aMenuItem->wpMenuCheck # gToolbar->wpVisible;
    }

    // Verzeichnis loeschen
    case 'tbnDeleteBin' :
    {
      tFocusHdl # WinFocusGet()
      if(tFocusHdl != 0)
      {
        // binaeres Verzeichnis selektiert ?
        if(WinInfo(tFocusHdl,_WinType) = _WinTypeTreeview)
        {
          if(tNodeSelected != 0)
          {
            if(WinDialogBox(WinInfo(aEvt:Obj,_winFrame),'Binäres Verzeichnis löschen ?',
              'Möchten Sie das Verzeichnis "'+tNodeSelected->wpCaption+'" mit allen Unterverzeichnissen wirklich löschen ?',
               _WinIcoQuestion,_WinDialogYesNoCancel,3) = _WinIdYes)
            {
              tErr # DeleteDirectory($trvBinDir,tNodeSelected,tBinDirPath)
              if(tErr != _ErrOk)
              {
                BlobErrMsg(sAktionDirDelete,tErr,tNodeSelected->wpCaption)
              }
            }
          }
          else
          {
            tNodeSelected # $trvBinDir->wpCurrentInt;
            if(tNodeSelected->wpName != 'Root')
            {
              WinDialogBox(WinInfo(aEvt:Obj,_WinFrame),'Verzeichnis löschen !',
              'Es ist kein Verzeichnisknoten zum löschen selektiert!',_WinIcoError,_WinDialogOk,1)
            }
            else
            {
              WinDialogBox(WinInfo(aEvt:Obj,_WinFrame),'Verzeichnis löschen !',
              'Das Root-Verzeichnis kann nicht gelöscht werden!',_WinIcoError,_WinDialogOk,1)
            }
            return(false)
          }
        }

        // binaeres Objekt selektiert ?
        if(WinInfo(tFocusHdl,_WinType) = _WinTypeDataList)
        {
          tLineSelect # $dlsBinObj->wpCurrentInt
          if (tLineSelect != 0)
          {
            if (tNodeSelected != 0)
            {
              tBinDirPath # FindTreePath(tNodeSelected)
            }
            WinLstCellGet($dlsbinObj,tObjName,1,tLineSelect)
            if(WinDialogBox(WinInfo(aEvt:Obj,_winFrame),'Binäres Objekt löschen ?',
              'Möchten Sie das Objekt "'+tObjName+'" wirklich löschen ?',
               _WinIcoQuestion,_WinDialogYesNoCancel,3) = _WinIdYes)
            {
              tErr # DeleteObject($dlsBinObj,tLineSelect,tBinDirPath+'\'+tObjName)
              if(tErr != _ErrOk)
              {
                BlobErrMsg(sAktionObjDelete,tErr,tObjName)
              }
            }
          }
          WinUpdate($dlsBinObj,_WinUpdOn);
        }
      }
    }

    // Verzeichnis anlegen
    case 'tbnNewDir' :
    {
      if(tNodeSelected != 0)
      {
        tErr # CreateDirectory($trvBinDir,tNodeSelected,tBinDirPath)
        if(tErr < 0)
        {
          BlobErrMsg(sAktionDirOpen,tErr,tNodeSelected->wpCaption)
        }
      }
      else
      {
        // neues Verzeichnis im Rootverzeichnis anlegen
        tErr # CreateDirectory($trvBinDir,gNodeRoot,'')
        if(tErr < 0)
        {
          BlobErrMsg(sAktionDirOpen,tErr,gNodeRoot->wpCaption)
        }
      }
    }

    // Verzeichnis umbennen
    case 'tbnRenameDir' :
    {
      if (tNodeSelected != 0)
      {
        tErr # RenameDirectory(tNodeSelected,tBinDirPath)
        if(tErr < 0)
        {
          BlobErrMsg(sAktionDirOpen,tDirHdlSelected,tNodeSelected->wpCaption)
        }
        else
        {
          // Pfad auf das Verzeichnis neu setzen
          gBinDirPath # FindTreePath(tNodeSelected)
        }
      }
    }

    case 'tbnObjImport' :
    {
      // Ausgangsverzeichnis ermitteln
      if (tNodeSelected != 0)
      {
        tExtObjPath # ComDialog(_WinComFileOpen,gFrm_BinData);
        if (tExtObjPath != '')
        {
          tErr # ImportObject($dlsBinObj,tNodeSelected,tBinDirPath,tExtObjPath)
          if (tErr < 0)
          {
            BlobErrMsg(sAktionObjImport,tErr,FsiSplitName(tExtObjPath,_FsiNameNE))
          }
        }
      }
      WinUpdate($dlsBinObj,_WinUpdOn);
    }

    // Objekt exportieren
    case 'tbnObjExport' :
    {
      tLineSelect # $dlsBinObj->wpCurrentInt
      if (tLineSelect != 0)
      {
        ExportObject($dlsBinObj,tLineSelect,tBinDirPath)
      }
    }

    // Objekt drucken
    case 'tbnObjPrint' :
    {
      tLineSelect # $dlsBinObj->wpCurrentInt
      if (tLineSelect != 0)
      {
        PrintObject($dlsBinObj,tLineSelect,tBinDirPath);
      }
    }
  }

  // Refresh des Tree
  WinUpdate($trvBinDir,_WinUpdOn)
}

// ******************************************************************
// *  Selektieren eines Knotens im Tree                             *
// ******************************************************************

sub EvtNodeSelect
(
  aEvt  : event;
  aNode : int;
) : logic;

local
{
  tBinDirHdl : int;
}

{
  switch(aEvt:Obj->wpName)
  {
    // Datalist der beniaeren Objekte
    case 'trvBinDir' :
    {
      if (aNode->wpName = 'Root')
      {
        gtUebersicht->wpCaption # 'Übersicht' + ': \Root';
        // in das Rootverzeichnis könne keine Dateien importiert werden
        $tbnRenameDir->wpDisabled # true;
        $tbnObjImport->wpDisabled # true;
        $tbnObjExport->wpDisabled # true;
        $tbnDeleteBin->wpDisabled # true;
        $tbnObjPrint ->wpDisabled # true;
        // Alle Zeilen aus der DataList loeschen
        // da das Root-Verzeichnis keine binaeren Objekte enthalten kann
        WinLstDatLineRemove($dlsBinObj,_WinLstDatLineAll);
        return(true);
      }
      else
      {
        $tbnRenameDir->wpDisabled # false;
        $tbnObjImport->wpDisabled # false;
        $tbnObjExport->wpDisabled # false;
        $tbnDeleteBin->wpDisabled # false;
        $tbnObjPrint ->wpDisabled # true;
      }

      // Lesen des Verzeichnisse
      gBinDirPath # FindTreePath(aNode)
      gtUebersicht->wpCaption # 'Übersicht' + ': ' + gBinDirPath;

      tBinDirHdl # BinDirOpen(0,gBinDirPath)
      if(tBinDirHdl > 0)
      {
        CNVAI(FillDlsBinObjects($dlsBinObj,tBinDirHdl));
        BinClose(tBinDirHdl)
      }
      else
      {
        BlobErrMsg(sAktionDirOpen,tBinDirHdl,gBinDirPath)
      }
    }
  }
}

// ******************************************************************
// *  Selektieren einer Zeile in der Liste                          *
// ******************************************************************

sub EvtLstSelect
(
  aEvt   : event;
  aRecID : int;
) : logic;

local
{
  tMimeType : alpha;
}

{
  switch(aEvt:Obj->wpName)
  {
    case 'dlsBinObj':
    {
      if (aRecID != 0)
      {
        WinLstCellGet(aEvt:Obj,gPicName,1,aRecID);
        WinLstCellGet(aEvt:Obj,tMimeType,11,aRecID);
        // Pfad und Name des Bildes zusammensetzen
        tMimeType # StrCnv(FsiSplitName(gPicName, _FsiNameE),_STrUpper)
        if (tMimeType = 'BMP' OR tMimeType = 'JPG' OR tMimeType = 'TIF')
        {
          gPicPath # gbinDirPath+'\'+gPicName;
          $picBinData->wpCaption # '>0'+gPicPath;
          $tbnObjPrint->wpDisabled # false;
        }
        else
        {
          $tbnObjPrint->wpDisabled # true;
        }
      }
      else
      {
        $tbnObjPrint->wpDisabled # true;
      }
    }
  }
}

// ******************************************************************
// *  Verlust des Fokus eines Objektes                              *
// ******************************************************************

sub EvtFocusTerm
(
  aEvt              : event;
  aFocusObject      : int;
) : logic;

local
{
  tNodeSelected    : int;
  tDirHdlSelected  : int;
  tDirPathSelected : alpha(4096);
  tErr             : int;
}

{
  // selektierten Knoten ermitteln
  tNodeSelected # $trvBinDir->wpCurrentInt;
  switch(aEvt:Obj->wpName)
  {
    // Name des Verzeichnis
    case 'aedRename' :
    {
      gDirRename # aEvt:Obj->wpCaption;
    }
  }

  return(true);
}

// ******************************************************************
// *  Anzeige der binaeren Verzeichnisse in einem Treeview-Objekt   *
// ******************************************************************

sub ShowBinDirectory
(
  aWinObj : int;
  aBinDir : int;
)

local
{
  tDirHdl     : int;
  tDirName    : alpha;
  tTreeNodeDir : int;
  tRootHdl     : int;
}

{
  // Root-Knoten anlegen
  if (aWinObj->wpName = 'trvBinDir')
  {
    gNodeRoot # WinTreeNodeAdd(aWinObj,'Root','Root');
    aWinObj # gNodeRoot;
    aWinObj->wpNodeStyle # _WinNodeRedBall;
    aWinObj->wpHelpTip # 'Wurzelknoten - nicht löschbar.'+SCR+'In diesem Verzeichnis können keine binären Objekte definiert werden.'
  }

  // Alle Verzeichnisse ermitteln
  tDirName # BinDirRead(aBinDir,_BinFirst|_BinDirectory)
  while(tDirName != '')
  {
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
  }
}

// ******************************************************************
// *  Anzeige der binaeren Objekte zu einem Ausgangsverzeichnis in  *
// ******************************************************************

sub FillDlsBinObjects
(
  aDlsHdl           : int;
  aBinDir           : int;
) : int;

local
{
  tObjName : alpha;
  tObjHdl  : int;
  tCntObj  : int;
  tLine    : int;
}

{
  tCntObj # 0;
  aDlsHdl->WinUpdate(_WinUpdOff)
  WinLstDatLineRemove(aDlsHdl,_WinLstDatLineAll);
  // alle Objekte zu diesem Verzeichnis ermitteln
  tObjName # BinDirRead(aBinDir,_BinFirst)

  while(tObjName != '')
  {
    tObjHdl # BinOpen(aBinDir,tObjName);
    tLine # WinLstDatLineAdd(aDlsHdl,tObjName,_WinLstDatLineLast);
    if(tObjHdl > 0)
    {
      // Fuellen der Datalist mit dem Objekt
      FillDlsBinInfo(aDlsHdl,tObjHdl,tLine)
      inc(tCntObj)
    }
    tObjName # BinDirRead(aBinDir,_BinNext);
    BinClose(tObjHdl);
  }
  aDlsHdl->WinUpdate(_WinUpdOn)

  return(tCntObj)
}

// ***********************************************************************
// *  Anzeige der Eigenschaften eines binaeren Verzeichnis oder Objektes *
// ***********************************************************************

sub FillDlsBinInfo
(
  aDlsHdl    : int;
  aObjHdl    : int;
  aLine      : int;
)

local
{
  tCaltime  : caltime;
  tTime     : time;
  tDate     : date;
}

{
  // Eigenschaften des Objektes in die Spalten setzen
  WinLstCellSet(aDlsHdl,aObjHdl->spSizeOrg,2,aLine)
  tCaltime # aObjHdl->spTimeExternal
  try begin
    ErrTryIgnore(_ErrValueRange);
    tDate # tCaltime->vpDate;
    tTime # tCaltime->vpTime;
  end;
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
}

// ******************************************************************
// *  Ermitteln des Pfades zu einem Objekt mit Hilfe der Treeknoten *
// ******************************************************************

sub FindTreePath
(
  aNode : int;
) : alpha;

local
{
  tNodeParent     : int;
  tPath           : alpha(4096);
}

{
  tNodeParent # WinInfo(aNode,_WinParent);
  if (tNodeParent != 0 AND
      WinInfo(tNodeParent,_WinType)=_WinTypeTreeNode AND
      tNodeParent->wpName != 'Root')
  {
    tPath # FindTreePath(tNodeParent)
  }
  tPath # tPath+'\'+aNode->wpCaption;
  return(tPath)
}

// ******************************************************************
// *  Binaeres Verzeichnis mit allen Unterverzeichnissen und Objekten
//    loeschen
// ******************************************************************

sub DeleteDirectory
(
  aTreeHdl      : int;
  aNodeSelected : int;
  aBinDirPath   : alpha(4096);
) : int;

local
{
  tNodePrev : int;
  tErr      : int;
}

{
  // Verzeichnis loeschen
  tErr # BinDirDelete(0,aBinDirPath,_BinDeleteAll)
  if (tErr = _ErrOk)
  {
    // vorherigen Knoten ermitteln
    tNodePrev # WinInfo(aNodeSelected,_WinPrev);

    WinTreeNodeRemove(aNodeSelected);

    // vorherigen Knoten oder keinen Knoten selektieren
    if (tNodePrev != 0)
    {
      aTreeHdl->wpCurrentInt # tNodePrev;
    }
    else
    {
      aTreeHdl->wpCurrentInt # 0;
    }

  }
  // Fehlercode zurueckgeben
  return(tErr);
}

// ******************************************************************
// *  Binaeres Objekt loeschen                                      *
// ******************************************************************

sub DeleteObject
(
  aDlsHdl           : int;
  aLineSelect       : int;
  aBinObjPath       : alpha(4096);
) : int;

local
{
  tErr            : int;
}

{
  // Objekt loeschen
  tErr # BinDelete(0,aBinObjPath)
  if (tErr = _ErrOk)
  {
    // Zeile aus der DataList entfernen
    WinLstDatLineRemove(aDlsHdl,aLineSelect);
  }

  // Fehlercode zurueckgeben
  return(tErr);
}

// ******************************************************************
// *  Binaeres Verzeichnis erstellen                                *
// ******************************************************************

sub CreateDirectory
(
  aTreeHdl          : int;
  aNodeSelected     : int;
  aCurrentPath      : alpha(4096);
) : int;

local
{
  tDirHdlSelected   : int;
  tNewDirName       : alpha;
  tNewDirHdl        : int;
  tCnt              : int;
  tNewNode          : int;
  tErr              : int;
}

{
  // Ausgangsverzeichnis ermitteln
  if (aCurrentPath != '')
  {
    tDirHdlSelected # BinDirOpen(0,aCurrentPath)
    tErr # tDirHdlSelected
  }
  else
  {
    tErr # 0;
  }

  if(tDirHdlSelected > 0 OR aCurrentPath = '')
  {
    tNewDirName # 'Neues Verzeichnis';
    // zuvor Pruefen ob ein verzeichnis mit deisem Namen schon  vorhanden ist
    if(aCurrentPath = '')
    {
      // neues Verzeichnis im Ausgangsverzeichnis anlegen
      tNewDirHdl # BinDirOpen(0,tNewDirName);
    }
    else
    {
      // neues Verzeichnis im aktuell selektierten Verzeichnis anlegen
      tNewDirHdl # BinDirOpen(tDirHdlSelected,tNewDirName);
    }

    tCnt # 2;
    while (tNewDirHdl > 0)
    {
      tNewDirName # 'Neues Verzeichnis('+CNVAI(tCnt)+')';
      BinClose(tNewDirHdl)
      if(aCurrentPath = '')
        tNewDirHdl # BinDirOpen(0,tNewDirName);
      else
        tNewDirHdl # BinDirOpen(tDirHdlSelected,tNewDirName);

      inc(tCnt)
    }

    // neues Verzeichnis anlegen ausghend vom selektierten Verzeichnis
    if (aCurrentPath = '')
      tNewDirHdl # BinDirOpen(0,tNewDirName,_BinCreate);
    else
      tNewDirHdl # BinDirOpen(tDirHdlSelected,tNewDirName,_BinCreate);

    if(tNewDirHdl > 0)
    {
      // neuen Knoten im Tree fuer das Verzeichnis anlegen
      tNewNode # WinTreeNodeAdd(aNodeSelected,tNewDirName,tNewDirName);
      // Neu angelegten Knoten im Tree selektieren
      aTreeHdl->wpCurrentInt # tNewNode;
    }
    else
    {
      BlobErrMsg(sAktionDirCreate,tNewDirHdl,tNewDirName)
    }

    // Ausgangsverzeichnis wieder schliessen
    if (tDirHdlSelected > 0)
      BinClose(tDirHdlSelected)

    // Neu angelegtes Verzeichnis schliessen
    if (tNewDirHdl > 0)
    {
      // Neu angelegtes Verzeichnis wieder schliessen
      BinClose(tNewDirHdl);
    }
  }

  // Fehlercode zurueckgeben
  return(tErr);
}

// ******************************************************************
// *  Binaeres Verzeichnis umbennen                                 *
// ******************************************************************

sub RenameDirectory
(
  aNodeSelected     : int;
  aBinDirPath       : alpha(4096);
) : int;
local
{
  tErr              : int;
  tDirHdlSelected   : int;
}

{
  tDirHdlSelected # BinDirOpen(0,aBinDirPath,_BinLock)
  if (tDirHdlSelected > 0)
  {
    gDirRename # aNodeSelected->wpCaption;

    // Dialog zur Aenderung aufrufen
    if(WinDialog('BinRename',_WinDialogCenter,WinInfo(aNodeSelected,_winFrame))=_WinIdOk AND
       gDirRename != aNodeSelected->wpCaption AND gDirRename != '')
    {
      tErr # BinRename(tDirHdlSelected,gDirRename)
      if (tErr = _ErrOk)
      {
        aNodeSelected->wpName # gDirRename;
        aNodeSelected->wpCaption # gDirRename;
      }
      else
      {
        BlobErrMsg(sAktionRename,tErr,gDirRename);
      }
      WinUpdate(aNodeSelected,_WinUpdOn)
    }
    BinClose(tDirHdlSelected);
  }
  return(tDirHdlSelected)
}

// ******************************************************************
// *  Binaeres Objekt importieren                                   *
// ******************************************************************

sub ImportObject
(
  aDlsHdl           : int;
  aNodeSelected     : int;
  aBinDirPath       : alpha(4096);
  aExtFilePath      : alpha(4096);
) : int;

local
{
  tDirHdlSelected   : int;
  tNewObjHdl        : int;
  tFileName         : alpha;
  tErr              : int;
  tLine             : int;
}

{
  tDirHdlSelected # BinDirOpen(0,aBinDirPath)
  if (tDirHdlSelected > 0 AND aExtFilePath != '')
  {
    // binaeres Objekt erzeugen
    tFileName # FsiSplitName(aExtFilePath,_FsiNameNE)
    // Zuvor Pruefen ob ein Objekte mit diesem Namen schon vorhanden ist
    tNewObjHdl # BinOpen(tDirHdlSelected,tFileName)
    if (tNewObjHdl > 0)
    {
      // Objekt mit diesem Name existiert schon
      if (tDirHdlSelected != 0)
      {
        BinClose(tDirHdlSelected)
      }
      BinClose(tNewObjHdl);
      return(sObjExists);
    }

    tNewObjHdl # BinOpen(tDirHdlSelected,tFileName,_BinCreate|_BinLock)
    if(tNewObjHdl <= 0)
    {
      if(tDirHdlSelected != 0)
      {
        // Ausgangsvereichnis wieder schliessen
        BinClose(tDirHdlSelected);
      }
      return(tNewObjHdl)
    }

    // und importieren (ohne Verschluesselung)
    tErr # BinImport(tNewObjHdl,aExtFilePath,$iedKompression->wpCaptionInt)
    if(tErr != _ErrOk)
    {
      BinClose(tNewObjHdl)
      return(tErr)
    }
    else
    {
      // Eigenschaften des Objektes setzen
      tNewObjHdl->spTypeMime # FsiSplitName(aExtFilePath,_FsiNameE);
      // Aenderungen der Eigenschaften speichern
      tNewObjHdl->BinUpdate()
      // Zeile hinzufuegen
      tLine # WinLstDatLineAdd(aDlsHdl,tNewObjHdl->spName,_WinLstDatLineLast)
      // Eigenschaften des Objektes in der Liste anzeigen
      FillDlsBinInfo(aDlsHdl,tNewObjHdl,tLine)
      tNewObjHdl->BinClose();
    }

    if(tDirHdlSelected != 0)
    {
      // Ausgangsvereichnis wieder schliessen
      BinClose(tDirHdlSelected);
    }
  }
  return(tDirHdlSelected)
}

// ******************************************************************
// *  Binaeres Objekt exportieren                                   *
// ******************************************************************

sub ExportObject
(
  aDlsHdl           : int;
  aLineSelect       : int;
  aBinDirPath       : alpha(4096)
) : int;

local
{
  tExpObjName       : alpha;
  tExpObjHdl        : int;
  tExpFilePath      : alpha(4096);
  tPathName         : alpha;
  tFileName         : alpha;
  tErr              : int;
}

{
  WinLstCellGet($dlsBinObj,tExpObjName,1,aLineSelect)
  tExpObjHdl # BinOpen(0,aBinDirPath+'\'+tExpObjName)
  if (tExpObjHdl < 0)
  {
    BlobErrMsg(sAktionObjOpen,tExpObjHdl,tExpObjName)
    return(0)
  }
  else
  {
    tExpFilePath # ComDialog(_WinComFileSave,gFrm_BinData)
    tPathName # FsiSplitName(tExpFilePath,_FsiNameP)
    tFileName # FsiSplitName(tExpFilePath,_FsiNameNE)
    if (tPathName != '' AND tFileName  != '')
    {
     tErr # BinExport(tExpObjHdl,tExpFilePath)
      if (tErr != _ErrOk)
      {
        BlobErrMsg(sAktionObjExport,tErr,tExpObjName)
      }
    }
    BinClose(tExpObjHdl)
  }
  return(tErr)
}

// ******************************************************************
// *  Binaeres Objekt drucken                                       *
// ******************************************************************

sub PrintObject
(
  aDlsHdl           : int;         // DataList-Objekt
  aLineSelect       : int;         // Selektierte Zeile
  aBinDirPath       : alpha(4096); // Pfad zum binären Objekt
) : int;                           // Resultat

local
{
  tPrtJob           : int;         // Druckjob
  tPrtPage          : int;         // Druckseite
  tPrtForm          : int;         // Druckformular
  tPrtPicture       : int;         // Picture-Objekt
  tObjName          : alpha(250);  // Name des binären Objektes
  tPageBoundMax     : point;       // Zur Verfügung stehender Platz auf der Seite
  tResult           : int;         // Resultat
}

{
  // Druckjob öffnen
  tPrtJob  # PrtJobOpen(_PrtDocDinA4,'',_PrtJobOpenWrite|_PrtJobOpenTemp);
  tPrtPage # PrtJobWrite(tPrtJob,_PrtJobPageStart);

  // PrintForm öffnen
  tPrtForm # PrtFormOpen(_PrtTypePrintForm,'PrtFormPrintObject');

  // Falls die PrintForm geöffnet werden konnte
  if (tPrtForm > 0) {
    // Deskriptor des Picture-Objekts ermitteln
    tPrtPicture # PrtSearch(tPrtForm,'PrtPicturePrintObject');

    // Falls das Objekt gefunden werden konnte
    if (tPrtPicture > 0) {
      // Binäres Objekt ermitteln
      WinLstCellGet(aDlsHdl,tObjName,1,aLineSelect);

      // Binäres Objekt anzeigen
      tPageBoundMax             # tPrtPage->ppBoundMax;
      tPrtPicture->ppAreaRight  # tPageBoundMax:x;
      tPrtPicture->ppAreaBottom # tPageBoundMax:y;
      tPrtPicture->ppCaption    # '>0'+aBinDirPath+'\'+tObjName;
    }

    // PrintForm der Seite hinzufügen und wieder schließen
    PrtAdd(tPrtPage,tPrtForm);
    PrtFormClose(tPrtForm);
  }

  // Seite abschließen und Druckvorschau starten
  PrtJobWrite(tPrtJob,_PrtJobPageEnd);
  tResult # PrtJobClose(tPrtJob,_PrtJobPreview);

  // Funktion mit Fehlerrückgabe beenden
  return (tResult);
}

// ******************************************************************
// *  Common-Dialog zur Ausahl der Dateinamen fuer
//    das Exportieren und Importieren von binaeren Objekten         *
// ******************************************************************

sub ComDialog
(
  aDialogOption : alpha;
  aParentObj    : int;
) : alpha;

local
{
  tDlgHdl       : int;
  tRet          : alpha(4096);
  tDialogTitel  : alpha;
}

{
  if (aDialogOption = _WinComFileOpen)
  {
    tDialogTitel # 'Objekt importieren'
  }
  else
  {
    tDialogTitel # 'Objekt exportieren'
  }

  // Dialog oeffnen
  tDlgHdl # WinOpen(aDialogOption)

  // Eigenschaften des Dialoges setzen
  tDlgHdl->wpCaption # tDialogTitel
  // FileFilter setzen
  tDlgHdl->wpFileFilter # 'Alle Dateien (*.*)|*.*|TEXT (*.txt)|*.txt|Word-Dokumente (*.doc)|*.doc|'+
                          'JPEG (*.jpg)|*.jpg|Bitmap (*.bmp)|*.bmp|TIFF (*.tif)|*.tif|Resourcen (*.rsc)|*.rsc';
  tDlgHdl->wpFileFilterNum # 1;
  tDlgHdl->wpFlags # _WinComOverwritePrompt|_WinComCreatePrompt|_WinComExplorer;

  WinDialogRun(tDlgHdl,_WinDialogCenter,aParentObj)

  tRet # tDlgHdl->wpPathName+tDlgHdl->wpFileName;

  // Dialog wieder schliessen
  WinClose(tDlgHdl);

  return(tRet)
}

// ******************************************************************
// *  Ausgabe von Fehlermeldung im Zusammenhang mit Operationen von
//    binaeren Objekten                                             *
// ******************************************************************

sub BlobErrMsg
(
  aAktion       : int;
  aErr          : int;
  opt aObjName  : alpha(4096);
)

local
{
  tErrText      : alpha(1024);
  tAktText      : alpha(1024);
  tZusText      : alpha(1024);
}

{
  // Fehlertext zusammensetzen
  switch(aErr)
  {
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
    {
      tErrText  # 'Operation kann nicht ausgeführt werden.'+sCR
      tErrText  # tErrText + 'Entweder wurde die maximale Anzahl von 60 Ebenen erreicht,'+SCR
      tErrText  # tErrText + 'oder es wurde versucht ein binäres Objekte im Wurzelverzeichnis anzulegen.'
    }
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

  }

  // Aktion abfragen
  switch(aAktion)
  {
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
  }

  if(aObjName != '')
  {
    tZusText # 'Objekt : "'+aObjName+'"'
  }

  // Fehlermeldung ausgeben
  WinDialogBox($C16.BinData,'Fehler binäre Objekte!',
    tAktText +sCR+ tErrText +sCR+ tZusText +sCR+ 'Fehlernummer : '+CnvAI(aErr,_fmtNumNoGroup),
    _WinIcoError,_WinDialogOk,1);
}
