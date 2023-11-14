@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Bel_Main
//                OHNE E_R_G
//  Info
//
//
//  05.02.2004  AI  Erstellung der Prozedur
//  29.07.2009  TM  Anzeige Einsatz- und Fertigungs Stk/Gew bei IvlClicked
//  26.06.2013  AH  auf Viertelstunden-Raster gestellt
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB realtime(aRect : rect; aDauer : int; aPlan : logic) : rect
//    SUB RemoveAll(aObjType : int)
//    SUB RefreshAll();
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtTerm(aEvt : event) : logic
//    SUB IvlClicked(aEvt : event; aButton : int; aHitTest : int; aItem : int; aID : int) : logic
//    SUB IvlDrop(aEvt : event; aHdlTarget : int; aHdlIvl : int; aDropType : int; aRect : rect) : logic
//    SUB Uebernahme() : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB BAsEinplanen() : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB SetzeMarker(aRecID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHitTest : int; aItem : int; aID : int) : logic
//    SUB EvtKeyItem(aEvt : event; aKey : int; aRecID : int) : logic
//    SUB rlCopyBAInit(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecID : int) : logic
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

//========================================================================
// Berechnung der Länge eines Intervalls Aufgrund der Arbeitszeit
declare realtime(aRect : rect;aDauer : int;aPlan : logic;): rect
// Eventbehandlung der Mausclicks auf ein Intervall
declare IvlClicked(aEvt : event;aButton : int;aHitTest : int;aItem : int;aID : int;): logic
// Eventbehandlung beim Fallenlassen eines Intervalls
declare IvlDrop(aEvt : event;aHdlTarget : int;aHdlIvl : int;aDropType : int;aRect : rect;): logic
// Eventbehandlung für die Buttons
declare EvtClicked (aEvt : event;) : logic
declare RefreshAll();
//========================================================================

define begin
  cMenuName   : 'Rso.Bel.Bearbeiten'
end;


//========================================================================
// EvtMdiActivate
//
//========================================================================
sub EvtMdiActivate(aEvt : event): logic;
local begin
  vMenuItem : int;
end;
begin

  App_Main:EvtMdiActivate(aEvt);
  mode # c_modeList;

  // Menu aktivieren
  gMenu # gFrmMain->WinInfo(_WinMenu);
  vMenuItem # gMenu ->WinSearch('Mnu.Cancel');
  if (vMenuItem <> 0) then
    vMenuItem->wpDisabled # false;

  RETURN(true);
end;


//========================================================================
// EvtInit
//
//========================================================================
sub EvtInit (aEvt : event;) : logic
local begin
  Erx       : int;
  vList     : int;
  vItem     : int;
  vTmp      : int;
  vCount    : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  gMenuName # cMenuName;

  // alle Ressourcen in Liste speichern...
  vList # CteOpen(_CteList);
  Erx # RecRead(160,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    vItem # CteOpen(_CteItem);
    vItem->spID     # RecInfo(160,_RecID);
    vItem->spName   # AInt(Rso.Gruppe)+'|'+AInt(Rso.Nummer);
    CteInsert(vList,vItem);   // in Liste einbinden
    Erx # RecRead(160,1,_recNext);
  END;
  FOR vCount # vCount LOOP inc(vCount) while (vCount<4) do begin
    vItem # CteOpen(_CteItem);
    vItem->spID     # 0;
    vItem->spName   # '';
    CteInsert(vList,vItem);   // in Liste einbinden
  END;


    // Gantt-Strukturen anlegen und verankern...
  vTmp # Gantt_Rso_Data:Init();
  HdlLink(aEvt:Obj, vTmp);

  $ed.DatVon->wpcaptiondate # DateMake(01,datemonth(today),dateyear(today));
  $ed.DatBis->wpcaptiondate # DateMake(31,12,dateyear(today));
  Gantt_Rso_Data:SetStruct('DatVon',cnvad($ed.DatVon->wpcaptiondate));
  Gantt_Rso_Data:SetStruct('DatBis',cnvad($ed.DatBis->wpcaptiondate));

  Gantt_Rso_Data:SetStruct('Gantt','1',cnvai($gt.Rso1));
  Gantt_Rso_Data:SetStruct('Label','1',cnvai($bt.Rso1));
  Gantt_Rso_Data:SetStruct('Gantt','2',cnvai($gt.Rso2));
  Gantt_Rso_Data:SetStruct('Label','2',cnvai($bt.Rso2));

  Gantt_Rso_Data:SetStruct('Gantt','3',cnvai($gt.Rso3));
  Gantt_Rso_Data:SetStruct('Label','3',cnvai($bt.Rso3));
  Gantt_Rso_Data:SetStruct('Gantt','4',cnvai($gt.Rso4));
  Gantt_Rso_Data:SetStruct('Label','4',cnvai($bt.Rso4));


  Gantt_Rso_Data:SetStruct('ResList',cnvai(vList));

  Gantt_Rso_Data:Refreshall();

  App_Main:EvtInit(aEvt);


end;


//========================================================================
// EvtTerm
//
//========================================================================
sub EvtTerm(
  aEvt : event;
) : logic
begin
  Gantt_Rso_Data:Term();
  RETURN App_Main:EvtTerm(aEvt);
end;


//========================================================================
// EvtDragInit
//
//========================================================================
sub EvtDragInit(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int;      // Rückgabe der erlaubten Effekte (_WinDropEffectNone = Cancel)
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
begin
	RETURN (true);
end;


//========================================================================
// IvlClicked
//
//========================================================================
Sub IvlClicked(
  aEvt      : event;
  aButton   : int;
  aHitTest  : int;
  aItem     : int;
  aID       : int;
) : logic
local begin
  Erx       : int;
  vID       : int;
  vName     : alpha;
  vRect     : Rect;
  vInStk    : int;
  vInGew    : float;
  vOutStk   : int;
  vOutGew   : float;
end;
begin
  // Ausgabezeile bei Rechtsklick löschen
  If (aButton = _WinMouseRight) then begin
    RETURN falsE;
  end;
  If (aHitTest <> _winHitIvl) and (aButton <> _WinMouseRight) then RETURN false;

  if (aItem->wpcustom=c_AKt_BA) then begin
    RecRead(702,0,_RecId,aItem->wpID);

    //  29.07.2009  TM  -----

    vInStk # 0;
    vInGew # 0.0;
    Erx # RecLink(701,702,2,_recFirst);
    WHILE (Erx = _rOK) DO BEGIN
      vInStk # vInStk + BAG.IO.Plan.In.Stk;
      vInGew # vInGew + BAG.IO.Plan.In.GewN;
      Erx # RecLink(701,702,2,_recNext);
    END;
    $edBAG.P.Einsatz.Stk->wpcaptionint    # vInStk;
    $edBAG.P.Einsatz.Gew->wpcaptionfloat  # vInGew;

    vOutStk # 0;
    vOutGew # 0.0;
    Erx # RecLink(701,702,3,_recFirst);
    WHILE (Erx = _rOK) DO BEGIN
      vOutStk # vOutStk + BAG.IO.Plan.Out.Stk;
      vOutGew # vOutGew + BAG.IO.Plan.Out.GewN;
      Erx # RecLink(701,702,3,_recNext);
    END;
    $edBAG.P.Fertigung.Stk->wpcaptionint    # vOutStk;
    $edBAG.P.Fertigung.Gew->wpcaptionfloat  # vOutGew;
    // ----------------------
    $GB.Detail->winupdate(_WinUpdFld2Obj);
  end;

  RETURN true;
end;


//========================================================================
// IvlDrop
//
//========================================================================
Sub IvlDrop(
  aEvt        : event;
  aHdlTarget  : int;
  aHdlIvl     : int;
  aDropType   : int;
  aRect       : rect;
) : logic
begin
  RETURN True;
end;


//========================================================================
// EvtClose
//
//========================================================================
sub EvtClose(
  aEvt : event;
) : logic
local begin
  vFilter : int;
  vID     : int;
  vA      : alpha;
end;
begin

  vA # Gantt_Rso_Data:GetStruct('Changed');
  If (vA<>'') then begin
    vID # WindialogBox(gFrmMain,'Beenden', 'Es wurden Änderungen gemacht, die noch nicht übernommen wurden!'+StrChar(13)+
                                    'Wollen Sie wirklich die Erfassung abbrechen?',_WinIcoQuestion,_WinDialogYesNo,2);
    If (vID = _WinIdNo) then return false;
  end;
/**
  If ($Zwischenablage->WinInfo(_WinFirst, 1,_WinTypeInterval) <> 0) then begin
    vID # WindialogBox(gFrmMain,'Beenden','Es befinden sich noch BAs in der Zwischenablage.'+StrChar(13)+
                              'Wollen sie das Einplanen wirklich beenden?',_WinIcoQuestion,_WinDialogYesNo,2);
    if (vID = _WinIdNo) then return false;
  end;
***/

  RETURN App_Main:EvtClose(aEvt);
end;


//========================================================================
// EvtClicked
//
//========================================================================
sub EvtClicked (aEvt : event;) : logic
begin
  Case (aEvt:Obj->wpName) of
    // Sprungbutton gedrückt

    'bt.Up' : begin
      Gantt_Rso_Data:MoveRes(-1);
    end;
    'bt.Down' : begin
      Gantt_Rso_Data:MoveRes(1);
    end;
    'bt.Left' : begin
      Gantt_Rso_Data:MoveTime(-24*2*4);
    end;
    'bt.Right' : begin
      Gantt_Rso_Data:MoveTime(24*2*4);
    end;


    'bt.Refresh' : begin
      Gantt_Rso_Data:SetStruct('DatVon',cnvad($ed.DatVon->wpcaptiondate));
      Gantt_Rso_Data:SetStruct('DatBis',cnvad($ed.DatBis->wpcaptiondate));

      Gantt_Rso_Data:Refreshall();

      RETURN true;
    end;


    // Sichernbutton gedrückt
    'Sichern' : begin
    end;


    // Laufzeit setzen
    'LzSetzen' : begin
    end;

  end;  // Case

end;


//========================================================================
// EvtMenuCommand
//
//========================================================================
sub EvtMenuCommand(
  aEvt      : event;
  aMenuItem : int;
) : logic
local begin
  vI      : int;
  vIvl    : int;
  vSel    : alpha;
  vID     : int;
  vErg    : int;
  vFilter : int;
  vName   : alpha;
  vRead   : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  vName # aEvt:obj->wpName;
  Case vName of
    'Zwischenablage' : begin
    end; /* Zwischenablage */

    'Mas.L.Belegung' : begin
      case aMenuItem->wpName of

        'miUebernahme' : begin
        end; // miUebernahme

        'miBAs' : begin
        end; // miBAs
      end; // case
    end; // Mas.L.Belegung

  end;

end;


//========================================================================
// SetzeMarker
//
//========================================================================
sub SetzeMarker(
  aRecID    : int;
)
begin
/* ACHTUNG
  If RecRead(701,0,_RecID | _RecLock,aRecId) = _rOK then begin
    If Bag.P.UserName = '' then Bag.P.UserName # UserInfo(_UserName)
    else if Bag.P.UserName = UserInfo(_UserName) then bag.P.UserName # '';
    RekReplace(701,_RecUnlock);
    $rlCopyBA->WinUpdate(_WinUpdOn,_WinLstPosSelected | _WinLstRecDoSelect | _WinLstRecFromBuffer);
  end;
*/
end;


//========================================================================
// EvtMouseItem
//
//========================================================================
sub EvtMouseItem
(
  aEvt      : event;
  aButton   : int;
  aHitTest  : int;
  aItem     : int;
  aID       : int;
) : logic
begin
  case aEvt:Obj->wpName of
    'rlCopyBA' : begin
      If aHitTest = _WinHitLstView and aButton = _WinMouseDouble | _WinMouseLeft then SetzeMarker(aID);
      return true;
    end;
  end;
end;


//========================================================================
// EvtKeyItem
//
//========================================================================
Sub EvtKeyItem
(
  aEvt      : event;
  aKey      : int;
  aRecID    : int;
) : logic
begin
  case aEvt:Obj->wpName of
    'rlCopyBA' : begin
      SetzeMarker(aRecID);
    end;
  end;
end;


//========================================================================
// EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
) : logic
begin
/* ACHTUNG
  If Bag.P.UserName = UserInfo(_UserName) then
    GV.Alpha.01 # '>'
  else if Bag.P.UserName <> '' then
    GV.ALPHA.01 # 'X'
  else
    GV.ALPHA.01 # '';
  return true;
*/
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
//========================================================================
//========================================================================
