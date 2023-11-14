@A+
//===== Business-Control =================================================
//
//  Prozedur    XML_Main
//                    OHNE E_R_G
//  Info
//
//
//  14.04.2008  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event): logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB EvtClicked(aEvt : event) : logic
//
//========================================================================
@I:Def_Global

global XMLMapping begin
  gDataMapping  : int16[];
  gDataCount    : int;
  gDataLvl      : int;
end;

define begin
  cMenuName : 'Sel.Dialog'
  cPrefix :   'XML'
  cMaxWidth : 100
//  cZList :    $ZL.Abteilungen
//  cKey :      1
end;

//========================================================================
// MAIN
//
//========================================================================
main
begin

  XML_Edi_Main();

  RETURN;

  // Dialog öffnen...
  gMDI # Lib_GuiCom:AddChildWindow(gFrmMain,'Dlg.XML','');
  Lib_GuiCom:ObjSetPos(gMdi,50,50);
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
  vList : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gSelected # 0;

  // RAM-Liste öffnen...
  vList # CteOpen(_CteList);
  vHdl # WinSearch(aEvt:obj, 'lb.XML');
  vHdl->wpCustom # cnvai(vList);
  vHdl  # WinSearch(aEvt:obj, 'edFilename');
  Lib_guiCom:Disable(vHdl);

  // Datenbereich für Databinding initialisieren
  VarAllocate(XMLMapping);

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
  vHdl : int;
end;
begin

//  gZLList # 0;
//  vHdl # w_lastfocus;
  App_Main:EvtMdiActivate(aEvt);
//  w_lastfocus # vHdl;
//  GV.Alpha.01 # '';
//  if (vHdl=0) then RedrawInfo(n);
  vHDL # gMenu->WinSearch('SFX');
  if (vHDL <> 0) then  vHDL->wpDisabled # false;

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vHdl      : int;
  vHdl2     : int;
  vName     : alpha(500);
  vErr      : alpha;
  vList     : handle;   // unbenutzt
  vI        : int;
  vXMLData  : handle;
  vTmp      : alpha(4000);
  vTmpInt   : int;
end;
begin

  if (aEvt:Obj->wpName='bt.Filename') then begin

    // ------------------------------------------------
    // Datei ausgewählt
    vHdl # gMDI->Winsearch(aEvt:Obj->wpcustom);
    // Importverzeichnis aus Settings lesen
    vHdl->wpcaption # Set.XML.Pfad.Import;

    vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, vHdl->wpcaption, 'XML-Datei|*.xml');
    vHdl->wpcaption # vName;

    // STARTEN...
    if (vName<>'') then begin
      vHdl # WinSearch(gMDI, 'lb.XML');
      vList # cnvia(vHdl->wpCustom);

      // DataList resetten...
      vHdl # WinSearch(gMDI, 'dl.XML');
      vHdl->wpautoupdate # false;
      vHdl->winlstdatLineRemove(_WinLstDatLineAll);
      FOR  vHdl2 # vHdl -> WinInfo(_WinFirst);
      LOOP vHdl2 # vHdl2-> WinInfo(_WinNext);
      WHILE (vHdl2 > 0) do begin
        vI # vI + 1;
        vHdl2->wpname # 'col'+cnvai(vI);
        if (vI>1) then vHdl2->wpvisible # false;
        vHdl2->wpClmOrder # vI;
      END;
      vHdl->wpautoupdate # true;

      // ------------------------------------------------
      // Daten einlesen und an die Datalist anfügen
      begin
        vXMLData # Lib_XML:ImportXML(vName, var gDataLvl, var gDataCount);
        if (vXMLData <= 0 ) then begin
          WindialogBox(gFrmMain,'XML-Import', XmlError(_XmlErrorText),0,0,0);
          RETURN true;
        end;

        // XML Baum an DL binden
        vHdl->wpCustom  # CnvAi(vXMLData);

        // Datenbereich für Zuordnungstabelle anlegen:
        // Größe gleich WorstCase, jedes Feld in einer Zeile
        VarFree(gDataMapping);
        VarAllocate(gDataMapping, cMaxWidth* gDataCount);

        // RAM in DataList schreiben...
        vHdl->wpautoupdate # false;
        Lib_XML:FillDLFromXML(vHdl , vXMLData, var vTmp, var gDataMapping);
        vHdl->wpautoupdate # true;

// zu debugzecken
//        Lib_XML:DebugBindingPrint(var gDataMapping, gDataCount);
      end; // Daten einlesen und an die Datalist anfügen

/*
      begin
        // RAM-resetten...
        CteClear(vList,y);

        vErr # Lib_XML:Import(vList, vName);
        if (vErr<>'') then begin  // FEHLER???
          CteClear(vList,y);
          WindialogBox(gFrmMain,'XML-Import', vErr ,0,0,0);
          RETURN true;
        end;

        // RAM in DataList schreiben...
        vHdl->wpautoupdate # false;
        Lib_XML:FillDL(vHdl , vList);
        vHdl->wpautoupdate # true;
      end;
*/
    end;

  end; // if (aEvt:Obj->wpName='bt.Filename')

	RETURN (true);
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
  vList : int;
  vTmp  : int;
end;
begin
  vHdl # WinSearch(gMDI, 'lb.XML');
  vList # cnvia(vHdl->wpCustom);
  CteClear(vList,y);
  CteClose(vList);

  // Datenbereich für Databinding freimachen
  VarFree(XMLMapping);

  // Eltern aktivieren?
  if (w_Parent<>0) then begin
    vTmp # VarInfo(Windowbonus);
    VarInstance(WindowBonus,cnvIA(w_parent->wpcustom));
    w_Child # 0;
    VarInstance(WindowBonus,vTmp);
    w_Parent->wpdisabled # n;
    w_Parent->WinUpdate(_WinUpdActivate);
  end;

  RETURN true;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit (
  aEvt            : event;
  aRow            : int;
) : logic
local begin
  vCol        : int;
  vColumn     : handle;


  vNode       : handle;
  vDepth      : int;

end;
begin

  // Alle Spalten durchgehen
  vCol # 0;
  FOR  vColumn # aEvt:Obj->WinInfo(_WinFirst)
  LOOP vColumn # vColumn->WinInfo(_WinNext)
  WHILE (vColumn > 0) DO BEGIN
    inc(vCol);

    // Node aus Datamapping lesen
    vNode # Lib_XML:arrayGet(aRow, vCol,var gDataMapping);
    if (vNode = 0) then begin
      // INAKTIV
      vColumn->wpClmColBkg # _WinColRed;
    end else begin
      // AKTIV

      // Tiefe aus dem spCustom des Nodes lesen?
      vDepth # 30+255 - (CnvIa(vNode->spCustom) * 30);
      vColumn->wpClmColBkg # ((((vDepth<<8)+ vDepth)<<8)+ vDepth);
    end;

  END;

end; // sub EvtLstDataInit





//========================================================================
//  EvtLstEditCommit
//
//========================================================================
sub EvtLstEditCommit (
  aEvt            : event;
  aColumn         : int;
  aKey            : int;
  aFocusObject    : int;
) : logic
local begin
  vDL         : handle;
  vXMLData    : handle;
  vNode       : handle;
  vValue      : alpha;
  vRow        : int;
end;
begin


  // Prüfung Datamapping
  // sollte die Markierte Zelle keinen Handle im Datamapping Array haben,
  // dann ist an dieser Stelle auch kein Feld eingeplant und darf nicht
  // gefüllt werden
  begin

    // XML Baum lesen
    vDL # WinSearch(gMDI, 'DL.XML');
    vXMLData # CnvIa(vDL->wpCustom);

    vRow # aEvt:obj->wpCurrentInt;

    // XML Node vom geänderten Element lesen
    if (vDL->WinLstCellGet(vValue, aColumn->WinInfo(_WinItem), vRow)) then begin

      // Node aus Datamapping lesen
      vNode # Lib_XML:arrayGet(vRow, aColumn->WinInfo(_WinItem),var gDataMapping);
      if (vNode = 0) then
        RETURN false;
    end;

  end;

  RETURN ( aKey = _winKeyReturn );
end;




//========================================================================
//  EvtLstEditFinishedField
//
//========================================================================
sub EvtLstEditFinished (
  aEvt            : event;
  aColumn         : int;
  aKey            : int;
  aRecID          : int;
  aChanged        : logic;
) : logic
local begin
  vDL         : handle;
  vXMLData    : handle;
  vNode       : handle;
  vNodeChild  : handle;
  vItemName   : alpha;
  vValue      : alpha;
  vRow        : int;
end;
begin


  if (!aChanged OR (aKey <> _WinKeyReturn)) then
    RETURN false;


  // XML Baum lesen
  vDL # WinSearch(gMDI, 'DL.XML');
  vXMLData # CnvIa(vDL->wpCustom);

  vRow # aEvt:obj->wpCurrentInt;

  // XML Node vom geänderten Element lesen
  if (vDL->WinLstCellGet(vValue, aColumn->WinInfo(_WinItem), vRow)) then begin

    // Node aus Datamapping lesen
    vItemName # aColumn->wpCaption;
    vNode # Lib_XML:arrayGet(vRow, aColumn->WinInfo(_WinItem),var gDataMapping);
    if (vNode <> 0) then begin

      // Kindelement, im Normalfall nur ein Kindelement = Wert
      vNodeChild # vNode->CteRead(_CteFirst  | _CteChildList)

      // ggf Node Anlegen, falls ein leeres Element geändert wurde
      if (vNodeChild = 0) then begin
        // Textnode anlegen
        vNode->CteInsertNode(vItemName,_XmlNodeText, vValue,_CteChild);
      end else begin
        // Geänderten Wert in XML Struktur updaten
        vNodeChild->spValueAlpha # vValue;
      end;

    end;

  end;
// zu debugzecken
//  vXMLData->XmlSave('c:\debug\debug.txt',_XmlSaveDefault,0,_CharsetC16_1252);

  RETURN true;
end;





/******
//========================================================================
//  StartListEdit
//
//========================================================================
sub StartListEdit
(
  aList       : int; // Liste
  opt aColumn : int; // Spalte
  opt aFlags  : int;
)

  local
  {
    tFlags : int;
  }

{
  if (aList = 0)
    return;

  if (aColumn = 0)
    aColumn # aList->WinInfo(_WinFirst);

  if (aColumn = 0)
    return;

  switch (aColumn->wpCaption)
  {
    case 'Alpha' : tFlags # aFlags | _WinLstEditLst;
    case 'Int'   : tFlags # aFlags | _WinLstEditLstAlpha;
    default      : tFlags # aFlags;
  }

  aList->WinLstEdit(aColumn,tFlags);
}


// ******************************************************************
// *  DATALIST - EVENT KEY ITEM                                     *
// ******************************************************************

sub EvtKeyItem
(
  aEvt       : event; // Ereignis
  aKey       : int;   // Taste
  aRecID     : int;   // RecID nur bei RecList
) : logic
{
  if (aKey = _WinKeyReturn)
    StartListEdit(aEvt:Obj,0,_WinLstEditClearChanged);

  return (TRUE);
}


// ******************************************************************
// *  DATALIST - EVENT MOUSE ITEM                                   *
// ******************************************************************

sub EvtMouseItem
(
  aEvt      : event; // Ereignis
  aButton   : int;   // Maustaste
  aHitTest  : int;   // Hittest-Code
  aItem     : int;   // Spalte oder Gantt-Intervall
  aID       : int;   // RecID bei RecList / Zeile bei GanttGraph
) : logic
{
  // Starte Editiervorgang bei Doppelklick auf eine Spalte.
  if (aID = aEvt:obj->wpCurrentInt AND
      aItem > 0 AND
      aButton & (_WinMouseLeft | _WinMouseDouble) = (_WinMouseLeft | _WinMouseDouble) AND
      aHitTest = _WinHitLstView)
    StartListEdit(aEvt:obj,aItem,_WinLstEditClearChanged);

  return (TRUE);
}


// ******************************************************************
// *  DATALIST - EVENT LIST EDIT START                              *
// ******************************************************************

sub EvtLstEditStart
(
  aEvt         : event; // Ereignis
  aColumn      : int;   // Spalte
  aEdit        : int;   // Eingabefeld
  aList        : int;   // Datalist
) : logic

  local
  {
    tStr     : alpha(250);  // Caption
    tFrame   : int;         // Frame-Deskriptor
    tRect    : rect;        // Popup-Area
    tItem    : int;         // Spaltenindex
    tBoolStr : alpha;       // Temp. Variable
    tBoolVal : logic;       // Temp. Variable
    tBool    : logic;       // Temp. Variable
  }

{
  tFrame # aEvt:Obj->WinInfo(_WinFrame);

  if (aEdit > 0)
  {
    // je nach übergebenen Eingabeobjekt eine Zeichenkette erzeugen.
    switch (aEdit->WinInfo(_WinType))
    {
      case _WinTypeIntEdit   : tStr # CnvAI(aEdit->wpCaptionInt);
      case _WinTypeFloatEdit : tStr # CnvAF(aEdit->wpCaptionFloat,0,0,3);
      case _WinTypeDateEdit  : tStr # CnvAD(aEdit->wpCaptionDate);
      case _WinTypeTimeEdit  : tStr # CnvAT(aEdit->wpCaptionTime);
      case _WinTypeEdit      : tStr # aEdit->wpCaption
    }

    // Anzeige der Zeichenkette.
    if (tFrame > 0)
      tFrame->wpCaption # tStr + ' / ' +CnvAI(aList);
  }

  if (aList > 0)
  {
    switch (aColumn->wpCaption)
    {
      case 'Bool' :
      {
        // Liste mit Alpha-Werten erstellen und einen Logic-Wert zuordnen.
        tItem # aColumn->WinInfo(_WinItem);
        aEvt:obj->WinLstCellGet(tBoolVal,tItem,_WinLstDatLineCurrent);

        aList->WinLstDatLineRemove(_WinLstDatLineAll);

        // 'ja' -> true
        tBool    # true;
        tBoolStr # 'ja';

        aList->WinLstDatLineAdd(tBool);
        aList->WinLstCellSet(tBoolStr,2);

        // Caption muß neu gesetzt werden
        if (tBoolVal)
          aEdit->wpCaption # tBoolStr;

        // 'nein' -> false
        tBool    # false;
        tBoolStr # 'nein';

        aList->WinLstDatLineAdd(tBool);
        aList->WinLstCellSet(tBoolStr,2);

        // Caption muß neu gesetzt werden
        if (!tBoolVal)
          aEdit->wpCaption # tBoolStr;
      }

      case 'Alpha' :
      {
        // Alpha-Werte in List hinzufügen.
        aList->WinLstDatLineAdd('noname');
        aList->WinLstDatLineAdd('unknown');
        aList->WinLstDatLineAdd('edwin');
        aList->WinLstDatLineAdd('andrej');

        aEdit->wpReadOnly # TRUE;
      }
      case 'Int'   :
      {
        // Anzeige einer Liste von Zeichenketten, denen ein
        // eindeutiger Wert zugeordnet ist.

        // 'wenig' -> 1
        aList->WinLstDatLineAdd(1);
        aList->WinLstCellSet('wenig',2);

        // 'viel' -> 1000
        aList->WinLstDatLineAdd(1000);
        aList->WinLstCellSet('viel',2);

        // 'mega' -> 2000
        aList->WinLstDatLineAdd(2000);
        aList->WinLstCellSet('mega',2);

        aList->wpColGrid # _WinColBtnFace;

        // Liste etwas vergrößern.
        tItem # aList->WinInfo(_WinParent);
        if (tItem > 0)
        {
          tRect # tItem->wpArea;
          tRect:right # tRect:left + 200;
          tItem->wpArea # tRect;
        }

        // Erste Spalte auch anzeigen.
        tItem # aList->WinInfo(_WinFirst);
        if (tItem > 0)
        {
          tItem->wpClmWidth # 40;
          tItem->wpVisible # TRUE;
        }
      }
    }
  }
}

// ******************************************************************
// *  DATALIST - EVENT LIST EDIT COMMIT                             *
// ******************************************************************

sub EvtLstEditCommit
(
  aEvt         : event; // Ereignis
  aColumn      : int;   // Spalte
  aKey         : int;   // Taste
  aFocusObject : int;
) : logic
{
  // Eingabe übernehmen ?
  return (aKey != _WinKeyEsc);
}


// ******************************************************************
// *  DATALIST - EVENT LIST EDIT FINISHED                           *
// ******************************************************************

sub EvtLstEditFinished
(
  aEvt       : event; // Ereignis
  aColumn    : int;   // Spalte
  aKey       : int;   // Taste
  aID        : int;   // RecID (hier nicht benutzt)
  aChanged   : logic; // true, wenn eine Änderung vorgenommen wurde
) : logic

  local
  {
    tColumn    : int; // Deskriptor der Spalte
    tDirection : int; // Fokussierung
  }

{
  tColumn    # 0;
  tDirection # 0;

  // Tastatursteuerung zum Navigieren zw. Spalten.
  if (aKey & _WinKeyTab = _WinKeyTab)
  {
    // Shift-Tab -> eine Spalte zurück.
    if (aKey & _WinKeyShift = _WinKeyShift)
      tDirection # -1;

    // Tab -> eine Spalte weiter.
    else
      tDirection # 1;
  }

  // Return -> soll Tab entsprechen.
  else if (aKey & _WinKeyReturn = _WinKeyReturn)
    tDirection # 1;

  // Tastatursteuerung vornehmen.
  switch (tDirection)
  {
    // Ermittle die vorhergehende oder letzte Spalte.
    case -1 :
    {
      tColumn # aColumn->WinInfo(_WinPrev);
      if (tColumn = 0)
        tColumn # aEvt:Obj->WinInfo(_WinLast);
    }

    // Ermittle die nachfolgende oder 1. Spalte.
    case  1 :
    {
      tColumn # aColumn->WinInfo(_WinNext);
      if (tColumn = 0)
        tColumn # aEvt:Obj->WinInfo(_WinFirst);
    }
  }

  // Jetzt braucht nur noch der Editiervorgang mit der ermittelten
  // Spalte gestartet werden.
  if (tColumn > 0)
    StartListEdit(aEvt:obj,tColumn);
  else
    // Der Editiervorgang ist beendet. Die Liste wird neu sortiert.
    aEvt:Obj->WinUpdate(_WinUpdSort);
}
*****/

//========================================================================