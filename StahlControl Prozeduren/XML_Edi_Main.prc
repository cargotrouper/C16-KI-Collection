@A+
//===== Business-Control =================================================
//
//  Prozedur    XML_Edi_Main
//                        OHNE E_R_G
//  Info
//
//
//  14.04.2008  AI  Erstellung der Prozedur
//  11-11-2014  ST  Übernahme aus XML_Main
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

  // Dialog öffnen...
  gMDI # Lib_GuiCom:AddChildWindow(gFrmMain,'Dlg.XML_Edi','');
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

  vFiletype : alpha;
end;
begin

  if (aEvt:Obj->wpName='bt.Filename') then begin

    // ------------------------------------------------
    // Datei ausgewählt
    vHdl # gMDI->Winsearch(aEvt:Obj->wpcustom);
    // Importverzeichnis aus Settings lesen
    vHdl->wpcaption # Set.XML.Pfad.Import;

    vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, vHdl->wpcaption, 'Austausch-Datei|*.xml;*.txt');
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
      vFileType # StrCnv(StrCut(vName,StrLen(vName)-2,3),_StrLower);

      case (vFileType) of

        'xml' : begin
                  vXMLData # Lib_XML:ImportXML(vName, var gDataLvl, var gDataCount);
              end;

        'txt' : begin
                  vXMLData # Lib_EDI:ImportAsXML(vName, var gDataLvl, var gDataCount);
              end;
/*
        'csv' : begin
                  vXMLData # Lib_XML:ImportXML(vName, var gDataLvl, var gDataCount);
              end;
*/
        otherwise
          vXMLData # -1;

      end; // EO Case

      if (vXMLData <= 0 ) then begin
        if (vXmlData = -1) then
          Msg(99,'Datenformat unbekannt',0,0,0);
        else
          WindialogBox(gFrmMain,'Datenimport', XmlError(_XmlErrorText),0,0,0);

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

RETURN true;

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

  RETURN true;
end;





//========================================================================