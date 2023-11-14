@A+
//===== Business-Control =================================================
//
//  Prozedur  BA1_PZ_Messerbau
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  06.02.2012  ST  Prüfung auf Veränderung Fertigung / Messerbau + Reset
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB ItemAdd(aCteList: int; aKey : alpha(250); aCustom : alpha(1000); aId : int) : logic;
//    SUB FlushGantt(aGantt : int);
//    SUB SetRectPos(var aRect : Rect; aX : int; aY  int);
//    SUB GetData(aIvl : int; var aFert : int; var aAnz : int; var aBreite : float; var aName : alpha);
//    SUB SetData(aIvl : int; aFert : int; aAnz : int; aBreite : float; aCap : alpha);
//    SUB ShowIvlInfo(aIvl : int);
//    SUB IvlAdd(aGantt : int; aX : int; aFert : int; aBreite : float; aAnz : int; aName : alpha) : int;
//    SUB FindIvlAtPos(aGantt : int; aX : int; aY : int) : int;
//    SUB MaxPosX(aGantt : int; aNotIvl : int) : int;
//    SUB LinksRan(aGantt : int; var aRect : Rect; opt aNotIvl : int);
//    SUB FullSort(aGantt : int;  aNotIvl : int);
//    SUB UmSort(aGantt : int; var aArea : rect; aIvl : int; aNeu : logic);
//    SUB Split(aGantt : int; aIvl : int; var aArea : rect);
//    SUB Zurueck2Fert(aGantt : int; aIvl : int; var aArea : rect) : logic;
//    SUB Reset(opt aBAG : int; opt aPos  : int);
//    SUB Save();
//    SUB _getVpgText() : alpha
//
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int) : logic;
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHitTest : int; aItem : handle; aID : int) : logic;
//    SUB EvtClicked(aEvt : event) : logic;
//    SUB EvtIvlDropItem(aEvt : event; aHdlTarget : handle; aHdlIvl : handle; aDropType : int; aRect : rect) : logic;
//    SUB EvtClicked_AnzDlg(aEvt : event) : logic;
//
//    SUB Start(aBAG : int; aPos : int);
//
//========================================================================
@I:Def_Global

define begin
  cFaktorF  : 10
end;

declare _getVpgText() : alpha

local begin
  vBem : alpha(64)[20];
end;

//=========================================================================
// ItemAdd
//        Fügt Datensatz-Item zur Liste hinzu
//=========================================================================
sub ItemAdd(
  aCteList  : int;
  aKey      : alpha(250);
  aCustom   : alpha(1000);
  aId       : int) : logic;
local begin
  vItem     : handle;
end
begin
  vItem # CteOpen( _cteItem );
  if ( vItem = 0 ) then
    RETURN false;

  vItem->spName   # aKey + CnvAI( vItem, _fmtNumHex | _fmtNumLeadZero, 0, 8 );
  vItem->spCustom # aCustom;
  vItem->spId     # aId;

  // Einsortieren
  if ( aCteList->CteInsert( vItem ) ) then
    RETURN true;
  else
    RETURN false;
end;


//========================================================================
//  FlushGantt
//      Gantt komplett leeren
//========================================================================
sub FlushGantt(aGantt : int);
local begin
  vObj          : int;  // Objekt
  vTemp         : int;  // Zwischenspeicher
end;
begin
  // Objektaktualisierung deaktivieren
  WinUpdate(aGantt,_WinUpdOff);

  // Alle Objekte vom Typ aObjType durchlaufen
  vObj # aGantt   -> WinInfo(_WinFirst, 1);
  WHILE (vObj<>0) do begin
    // Objekt entfernen
    vObj -> WinGanttIvlRemove();
    vObj # aGantt   -> WinInfo(_WinFirst, 1);
  END;

  // Objektaktualisierung aktivieren
  WinUpdate(aGantt,_WinUpdOn);
end;


//========================================================================
//  SetRectPos
//
//========================================================================
sub SetRectPos(
  var aRect : Rect;
  aX        : int;
  aY        : int);
local begin
  vXX   : int;
  vYY   : int;
end;
begin
  vXX  # aRect:right - aRect:left;
  vYY  # aRect:Bottom - aRect:Top;
  if (aX>=0) then begin
    aRect:Left    # aX;
    aRect:right   # aX + vXX;
  end;
  if (aY>=0) then begin
    aRect:Top     # aY;
    aRect:Bottom  # aY + vYY;
  end;
end;


//========================================================================
//  GetData
//
//========================================================================
sub GetData(
  aIvl            : int;
  var aFert       : int;
  var aAnz        : int;
  var aBreite     : float;
  var aName       : alpha;
  var aBreitenTol : alpha;
  var aVerpTxt    : alpha;
  );
local begin
  vInfo : alpha(250);
end
begin
  vInfo  # aIvl->wpcustom;
  aFert       # cnvia(StrCut(vInfo,1,8));
  aAnz        # cnvia(StrCut(vInfo,1+8,8));
  aBreite     # cnvfa(StrCut(vInfo,1+8+8,11));
  aBreitenTol #       StrCut(vInfo,1+8+8+11,12);
  aVerpTxt    #       StrCut(vInfo,1+8+8+11+12,200);
  aName   # aIvl->wpname;
end;


//========================================================================
//  SetData
//
//========================================================================
sub SetData(
  aIvl        : int;
  aFert       : int;
  aAnz        : int;
  aBreite     : float;
  aCap        : alpha;
  aBreitenTol : alpha(16); //2023-04-06  MR 2470/26/
  aVerpTxt    : alpha(200);
  );
local begin
  vName       : alpha;
  vLen        : int;
  vArea       : rect;
end;
begin

//todo(here);
  aIvl->wpcustom #  cnvai(aFert,_FmtNumNoGroup|_FmtNumLeadZero,0,8) +
                    cnvai(aAnz,_FmtNumNoGroup|_FmtNumLeadZero,0,8) +
                    cnvaf(aBreite,_FmtNumNoGroup|_FmtNumLeadZero,0,2,11) +
                    StrFmt(aBreitenTol,16,_StrEnd) +                          //2023-04-06  MR 2470/26/
                    StrFmt(aVerpTxt,200,_StrEnd);
//                    aName;

  vLen # cnvif( (aBreite / cnvfi(cFaktorF)) * cnvfi(aAnz) );
  if (vLen<3) then vLen # 3;
  vArea # aIvl->wpArea;
  vArea:right # vArea:left + vLen -1;
  aIvl->wpArea # vArea;

  vName # aint(aAnz)+' x '+anum(aBreite,2)+' '+aCap;
  aIvl->wpCaption # vName;
//  aIvl->wpName    # aName;
//  aGantt->WinGanttIvlAdd(0, aY, vLen, aName, aName);
end;


//========================================================================
//  ShowIvlInfo
//    Füllt die Infoobjekte
//========================================================================
sub ShowIvlInfo(aIvl : int);
local begin
  vAnz        : int;
  vFert       : int;
  vBreite     : float;
  vName       : alpha;
  vBreitenTol : alpha;
  vVpgTxt     : alpha(200);
end;
begin

  vFert # cnvia($lbFERT->wpcaption);
  if (vFert<>0) then begin
    vBem[vFert] # $edBAG.F.Bemerkung->wpcaption;
  end;


  GetData(aIvl, var vFert, var vAnz, var vBreite, var vName, var vBreitenTol, var vVpgTxt);
  $lbFERT->wpcaption        # aint(vFert);
  $lbANZAHL->wpcaption      # aint(vAnz);
  $lbBREITE->wpcaption      # anum(vBreite, Set.Stellen.Breite);
  $lbBREITENTOL->wpCaption  # vBreitenTol;
  $lbVPG->wpCaption         # vVpgTxt;

  $edBAG.F.Bemerkung->wpcaption # vBem[vFert];
end;


//=========================================================================
//  IvlAdd
//
//=========================================================================
sub IvlAdd(
  aGantt      : int;
  aX          : int;
  aFert       : int;
  aBreite     : float;
  aAnz        : int;
  aName       : alpha;
  aBreitenTol : alpha(16); //2023-04-06  MR 2470/26/
  aVerpTxt    : alpha(200);
  ) : int;
local begin
  vIvl        : int;
  vCol        : int;
end;
begin

  vCol # _WinColWhite;
  case aFert of
    1 : vCol  # _WinColLightGreen;
    2 : vCol  # _WinColLightYellow;
    3 : vCol  # RGB(128,128,255);
    4 : vCol  # _WinColLightCyan;
    5 : vCol  # _WinColLightMagenta;
    6 : vCol  # RGB(255, 88 ,88);
    7 : vCol  # RGB(128, 128, 64);
  end;

  if (aGantt=$ggMESSER) then
    vIvl # aGantt->WinGanttIvlAdd(aX, 0, cnvif(aBreite), aName, aName)
  else
    vIvl # aGantt->WinGanttIvlAdd(aX, aFert - 1, cnvif(aBreite), aName, aName);

  vIvl->wpjustify # _WinJustLeft;
  vIvl->wpColBkg  # vCol;

  SetData(vIvl, aFert, aAnz, aBreite, aName, aBreitenTol, aVerpTxt);

  RETURN vIvl;
end;


//========================================================================
//  FindIvlAtPos
//
//========================================================================
sub FindIvlAtPos(
  aGantt  : int;
  aX      : int;
  aY      : int) : int;
local begin
  vObj  : int;
  vArea : rect;
end;
begin
  FOR   vObj # aGantt-> WinInfo(_WinFirst);
  LOOP  vObj # vObj-> WinInfo(_WinNext);
  WHILE (vObj > 0) do begin
    vArea #  vObj->wparea;
    if (aX>-1) then
      if (vArea:Left>aX) or (vArea:Right<aX) then CYCLE;
    if (aY>-1) then
      if (vArea:Top>aY) or (vArea:Bottom<aY) then CYCLE;

    RETURN vObj;
  END;
  RETURN 0;
end;


//========================================================================
//  MaxPosX
//
//========================================================================
sub MaxPosX(
  aGantt  : int;
  aNotIvl : int) : int;
local begin
  vObj    : int;
  vArea   : rect;
  vMax    : int;
end;
begin
  FOR   vObj # aGantt-> WinInfo(_WinFirst);
  LOOP  vObj # vObj-> WinInfo(_WinNext);
  WHILE (vObj > 0) do begin
    vArea #  vObj->wparea;
    if (aNotIvl<>vObj) then
      if (vArea:Right>vMax) then vMax # vArea:right+1;
  END;
  RETURN vMax;
end;


//========================================================================
//  LinksRan
//    Setzt das Interval so weit nahc links wie möglich
//========================================================================
sub LinksRan(
  aGantt      : int;
  var aRect   : Rect;
  opt aNotIvl : int);
local begin
  vX          : int;
end;
begin
  vX # MaxPosX(aGantt, aNotIvl);
  SetRectPos(var aRect, vX, -1);
end;


//========================================================================
//  FullSort
//    Sortiert alle Intervall neu von links nach rechts ein
//========================================================================
sub FullSort(
  aGantt  : int;
  aNotIvl : int);
local begin
  vObj      : int;
  vArea     : rect;
  vMax      : int;

  vTree     : int;
  vItem     : int;
  vSortkey  : alpha;
end;
begin

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  FOR   vObj # aGantt-> WinInfo(_WinFirst);
  LOOP  vObj # vObj-> WinInfo(_WinNext);
  WHILE (vObj > 0) do begin
    if (vObj<>aNotIvl) then begin
      vArea #  vObj->wparea;
      vSortkey # cnvai(vArea:left, _FmtNumLeadZero|_FmtNumNoGroup, 0,8);
      ItemAdd(vTree, vSortKey, '', vObj);
    end;
  END;


  FOR   vItem # Sort_ItemFirst(vTree)
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    vObj  # vItem->spId;
    vArea # vObj->wparea;
    SetRectPos(var vArea, vMax, -1);
    vObj->wparea # vArea;
    vMax # vArea:right + 1;
  END;

  // Löschen der Liste
  Sort_KillList(vTree);
end;


//========================================================================
//  UmSort
//
//========================================================================
sub UmSort(
  aGantt    : int;
  var aArea : rect;
  aIvl      : int;
  aNeu      : logic);
local begin
  vObj      : int;
  vTree     : int;
  vItem     : int;
  vSortkey  : alpha;

  vArea     : rect;
  vIvl2     : int;
  vStartPos : int;
  vLen      : int;
  vMax      : int;
end;
begin
// Kollissions Intervall suchen...
  vIvl2 # FindIvlAtPos(aGantt, aArea:left, -1);
  // auf sich slebst verschoben??
  if (vIvl2=aIvl) then RETURN;

  // ein kleines bisschen nach rechts schieben...
  vArea # vIvl2->wpArea;
  SetRectPos(var aArea, vArea:left, -1);

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  FOR   vObj # aGantt-> WinInfo(_WinFirst);
  LOOP  vObj # vObj-> WinInfo(_WinNext);
  WHILE (vObj > 0) do begin
    vArea #  vObj->wparea;
    if (vObj=vIvl2) then
      vSortkey # cnvai(vArea:left, _FmtNumLeadZero|_FmtNumNoGroup, 0,8)+'b'
    else if (vObj=aIvl) then
      vSortkey # cnvai(aArea:left, _FmtNumLeadZero|_FmtNumNoGroup, 0,8)+'a';
    else
      vSortkey # cnvai(vArea:left, _FmtNumLeadZero|_FmtNumNoGroup, 0,8);
//debug('ins '+vObj->wpname+' bei '+vsortkey);
    ItemAdd(vTree, vSortKey, '', vObj);
  END;

  if (aNeu) then begin
    vArea #  aIvl->wparea;
    vSortkey # cnvai(aArea:left, _FmtNumLeadZero|_FmtNumNoGroup, 0,8)+'a';
//debug('xins '+aIvl->wpname+' bei '+vsortkey);
    ItemAdd(vTree, vSortKey, '', aIvl);
  end;


  FOR   vItem # Sort_ItemFirst(vTree)
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    vObj  # vItem->spId;
    vArea # vObj->wparea;
    SetRectPos(var vArea, vMax,-1);
    vObj->wparea # vArea;
    vMax # vArea:right + 1;
  END;

  // Löschen der Liste
  Sort_KillList(vTree);

end;


//========================================================================
//  Split
//
//========================================================================
sub Split(
  aGantt        : int;
  aIvl          : int;
  var aArea     : rect;
  opt aVorgabe  : int;
  );
local begin
  vMax          : int;
  vI            : int;
  vArea         : rect;

  vFert         : int;
  vBreite       : float;
  vName         : alpha;
  vBreitenTol,
   vVpgTxt      : alpha(200);

  vIvl          : int;
  vPar          : int;
  vHdl          : int;
end;
begin
  GetData(aIvl, var vFert, var vMax, var vBreite, var vName, var vBreitenTol, var vVpgTxt);
  if (vMax<=1) then RETURN;

  if (aVorgabe = 0 ) then begin
    REPEAT
      vHdl # Winfocusget();
      vPar # WinInfo(vHdl,_winframe);
      vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('BA1.PZ.Messerbau.Anzahl'),_WinOpenDialog);
      vI # WinSearch(vHdl, 'ieANZAHL');
      vI->wpcaptionint  # vMax;
      vI->wpMaxInt      # vMax;
      vHdl->WindialogRun(_WinDialogCenter, vPar);
      vI # vI->wpcaptionint;
      WinClose(vHdl);
      Winfocusset(vPar);
      WinSearchpath(vPar);
    UNTIL (vI>0) and (vI<=vMax);
  end else begin
    vI # aVorgabe;
  end;

  // neuen Rest anlegen...
  if (vMax-vI>0) then
    vIvl # IvlAdd(aGantt, 0, vFert, vBreite, vMax - vI, vName, vBreitenTol, vVpgTxt);

  // Alte Intervall anpassen...
  SetData(aIvl, vFert, vI, vBreite, vName, vBreitenTol, vVpgTxt);

  vArea # aIvl->wpArea;
  aArea:right # aArea:Left + (vArea:Right-vArea:left);
end;


//========================================================================
//  Zurueck2Fert
//
//========================================================================
sub Zurueck2Fert(
  aGantt    : int;
  aIvl      : int;
  var aArea : rect) : logic;
local begin
  vIvl      : int;

  vAnz      : int;
  vFert     : int;
  vBreite   : float;
  vName     : alpha;
  vBreitenTol : alpha;
  vVpgTxt   : alpha(200);

  vAnz2     : int;
  vFert2    : int;
  vBreite2  : float;
  vName2    : alpha;
  vBreitenTol2 : alpha;
  vVpgTxt2   : alpha(200);
end;
begin
  GetData(aIvl, var vFert, var vAnz, var vBreite, var vName, var vBreitenTol, var vVpgTxt);

  vIvl # FindIvlAtPos(aGantt, 0, vFert - 1);
  if (vIvl=0) then begin    // kein Merge...
    SetRectPos(var aArea, 0, vFert - 1);
    RETURN false;
  end;

  // Mergen...
  GetData(vIvl, var vFert2, var vAnz2, var vBreite2, var vName2, var vBreitenTol2, var vVpgTxt2);
  SetData(vIvl, vFert2, vAnz2 + vAnz, vBreite2, vName2, vBreitenTol2, vVpgTxt2);
  WinGanttIvlRemove(aIvl);
  RETURN true;

end;


//========================================================================
//  Reset
//
//========================================================================
sub Reset(
  opt aBAG  : int;
  opt aPos  : int;
);
local begin
  Erx         : int;
  vGanttM     : int;
  vGanttF     : int;
  vVerpTxt    : alpha(200);
  vObj        : int;
  vRect       : rect;
  vTmp        : int;

  vFert       : int;
  vAnz        : int;
  vBreite     : float;
  vName       : alpha;
  vBreitenTol : alpha;
  vVpgTxt     : alpha(200);

  vAnzFert    : int;
  vAnzMesser  : int;
end;
begin
//  vGantt # Winsearch(vWin,'ggFERTIGUNGEN');

  // 1. Initialisierung??
  if (aBAG<>0) then begin

    Bag.P.Nummer   # aBag;
    Bag.P.Position # aPos;
    if (RecRead(702,1,0) = _rOK) then begin
      // Statische Positionsdaten lesen und anzeigen
      $lbBA->wpCaption # StrAdj(Aint(aBAG) +'/'+ Aint(aPos), _StrAll);

      // Ressource anzeigen
      if (RecLink(160,702,11,0) = _rOK) then begin
        // Gruppe lesen
        if (RecLink(822,160,3,0) = _rOK) then begin
          $lbRESSOURCE->wpCaption # Aint(Rso.Gruppe)+'/'+ Aint(Rso.Nummer);
          $lbRESNAME->wpCaption   # Rso.Grp.Bezeichnung + '/'+ Rso.Stichwort;
        end;
      end; //Ressource anzeigen

      // ----------------------------------------------------------------------
      // ST 2012-02-06: Projekt 1323/110
      //                 Hier Prüfen ob Abweichungen zwischen den Fertigungen
      //                 und dem Messerplan bestehen
      vAnzFert    # 0;        // Fertigungsanzahl zählen
      FOR   Erx # RecLink(703,702,4,_RecFirst);
      LOOP  Erx # RecLink(703,702,4,_RecNext);
      WHILE Erx = _rOK DO BEGIN
        if (Bag.F.Fertigung > 998) then   // Schöpfe nicht mitzählen
          CYCLE;
        vAnzFert # vAnzFert + BAG.F.Streifenanzahl;
      END;

      vAnzMesser  # 0;        // Anzahl in Messerplan zählen
      FOR   Erx # RecLink(711,702,20,_RecFirst);
      LOOP  Erx # RecLink(711,702,20,_RecNext);
      WHILE Erx = _rOK DO BEGIN
        vAnzMesser  # vAnzMesser + BAG.PZ.Anzahl;
      END;

      if (vAnzFert<>vAnzMesser) AND (vAnzMesser <> 0) then begin
        // Abweichung vorhanden
        if (Msg(711002,'',_WinIcoWarning,_WinDialogYesNo,0) = _WinIdYes) then begin
          FOR   Erx # RecLink(711,702,20,_RecFirst);
          LOOP  Erx # RecLink(711,702,20,_RecFirst);
          WHILE Erx = _rOK DO
            RekDelete(711,0,'AUTO');
        end;
      end;
    end;

  end;


  vGanttF # $ggFERTIGUNGEN;
  FlushGantt(vGanttF);

  vGanttM # $ggMESSER;
  FlushGantt(vGanttM);


  // ---------------------------------------------
  // Fertigungen hinzufügen
  FOR  Erx # RecLink(703,702,4, _recFirst);
  LOOP Erx # RecLink(703,702,4, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    if (Bag.F.Fertigung >= 900) then
      CYCLE;

    // VBerpackungstext vorbereiten
    vVerpTxt # '';
    if (RecLink(704,703,6,0) = _rOK) then
      vVerpTxt # _getVpgText();

    IvlAdd(vGanttF,                // GanttObjekt
            0,                    // X Pos
            Bag.F.Fertigung,      // Fertigung
            Bag.F.Breite,         // Breite
            Bag.F.Streifenanzahl, // Anzahl
            Bag.F.Kommission,     // Name
            BAG.F.Breitentol,     // Toleranz
            vVerpTxt              // VpgText
            );

    vBem[BAG.F.Fertigung] # BAG.F.Bemerkung;
  END;


  // ---------------------------------------------
  // Messeraufbau wiederherstellen
  WinUpdate($ggMESSER,_WinUpdOff);

  // Vorhandene Daten Lesen
  Erx # RecLink(711,702,20,_RecFirst);
  WHILE (Erx <= _rLocked) DO BEGIN

    // Fertigung lesen
    Bag.F.Nummer    # BAG.PZ.Nummer;
    Bag.F.Position  # BAG.PZ.Position;
    Bag.F.Fertigung # BAG.PZ.Fertigung;
    RecRead(703,1,0);

    // Verpackungstext vorbereiten
    vVerpTxt # '';
    if (RecLink(704,703,6,0) = _rOK) then
      vVerpTxt # _getVpgText();

    // Jetzt Doppelklick, Simulieren

    // Fertigung aus dem Fertigungsgant lesen
    vObj # vGanttF-> WinInfo(_WinFirst);
    WHILE (vObj > 0) DO BEGIN
      vTmp  # Cnvia(StrCut(vObj->wpCustom ,1,8));
      if (vTmp <> BAG.PZ.Fertigung) then begin
        vObj # vObj-> WinInfo(_WinNext);
        CYCLE;
      end;

      // Fertigung gefunden
      vRect # vObj->wparea;
      Split(vGanttF, vObj, var vRect, BAG.PZ.Anzahl);
      Linksran(vGanttM, var vRect);
      // Verschieben
      // GetData(vGanttF, var vFert, var vAnz, var vBreite, var vName, var vBreitenTol, var vVpgTxt);
      GetData(vObj, var vFert, var vAnz, var vBreite, var vName, var vBreitenTol, var vVpgTxt);
      IvlAdd(vGanttM, vRect:left, vFert, vBreite, vAnz, vName, vBreitenTol, vVpgTxt);
      vObj->WinGanttIvlRemove();

      vObj # vGanttF-> WinInfo(_WinFirst);

      Erx # RecLink(711,702,20,_recNext);
    END;

    Erx # RecRead(711,1,_RecNext);
  END;

  WinUpdate($ggMESSER,_WinUpdOn);

end;


//========================================================================
//  sub _getVpgText() : alpha
//    Gibt die Verpackungsinformationen für eine geladene Verpackung zurück
//========================================================================
sub _getVpgText() : alpha
local begin
  vVerpTxt : alpha(4000);
end
begin
  vVerpTxt # '';
  if (BAG.Vpg.AbbindungL <> 0) OR (BAG.Vpg.AbbindungQ <> 0) then begin
    vVerpTxt # vVerpTxt + 'Abbind: ';
    if (BAG.Vpg.AbbindungL <> 0) then
      vVerpTxt # vVerpTxt + Aint(BAG.Vpg.AbbindungL) +'x längs, ';
    if (BAG.Vpg.AbbindungQ <> 0) then
      vVerpTxt # vVerpTxt + Aint(BAG.Vpg.AbbindungQ) +'x quer, ';
  end;

  if (BAG.Vpg.StehendYN) then
    vVerpTxt # vVerpTxt + 'stehend, ';
  if (BAG.Vpg.LiegendYN) then
    vVerpTxt # vVerpTxt + 'liegend, ';

  if (BAG.Vpg.VpgText1 <> '') then
    vVerpTxt # vVerpTxt + BAG.Vpg.VpgText1 + ', ';
  if (BAG.Vpg.VpgText2 <> '') then
    vVerpTxt # vVerpTxt + BAG.Vpg.VpgText2 + ', ';
  if (BAG.Vpg.VpgText3 <> '') then
    vVerpTxt # vVerpTxt + BAG.Vpg.VpgText3 + ', ';
  if (BAG.Vpg.VpgText4 <> '') then
    vVerpTxt # vVerpTxt + BAG.Vpg.VpgText4 + ', ';
  if (BAG.Vpg.VpgText5 <> '') then
    vVerpTxt # vVerpTxt + BAG.Vpg.VpgText5 + ', ';
  if (BAG.Vpg.VpgText6 <> '') then
    vVerpTxt # vVerpTxt + BAG.Vpg.VpgText6 + ', ';

  // Letztes Komma abschneiden
  vVerpTxt # StrAdj(vVerpTxt, _StrEnd);
  if (StrCut(vVerpTxt,StrLen(vVerpTxt),1) = ',') then
    StrCut(vVerpTxt,1,StrLen(vVerpTxt)-1);

  RETURN StrCut(vVerpTxt,1,200);
end;


//========================================================================
//  Save()
//
//========================================================================
sub Save() : logic
local begin
  Erx         : int;
  vGantt      : int;
  vBA         : int;
  vObj        : int;

  vLfndNR     : int;
  vAnz        : int;
  vFert       : int;
  vBreite     : float;
  vName       : alpha;
  vBreitenTol : alpha;
  vVpgTxt     : alpha(200);
  vDebug      : Alpha(4000);
  vMin        : int;
  vMinO       : int;
end;
begin
  // Validierung
    // Alle Streifen eingeteilt?

  vGantt # $ggFERTIGUNGEN;
  vLfndNR # 0;

  FOR   vObj # vGantt-> WinInfo(_WinFirst);
  LOOP  vObj # vObj-> WinInfo(_WinNext);
  WHILE (vObj > 0) DO BEGIN
    vDebug # vObj->wpCustom + '/' + vObj->wpName;
    inc(vLfndNR);
  END;

  // nicht komplett verplant?? -> ERROR
  if (vLfndNr>0) then begin
    Msg(711001,'',0,0,0);
    RETURN false;
  end;


  // Vorhandene Daten löschen
  vLfndNR # 0;
  BAG.PZ.Nummer     # Bag.P.Nummer;
  BAG.PZ.Position   # Bag.P.Position;
  BAG.PZ.lfdNr      # 1;
  Erx # RecRead(711,1,0);
  WHILE (BAG.PZ.Nummer = Bag.P.Nummer) AND (BAG.PZ.Position = Bag.P.Position) AND (Erx <= _rNoKey) DO BEGIN
    RekDelete(711,0,'MAN');
    BAG.PZ.Nummer     # Bag.P.Nummer;
    BAG.PZ.Position   # Bag.P.Position;
    BAG.PZ.lfdNr      # 1;
    Erx # RecRead(711,1,0);
  END;

  // "Messerwelle" durchlaufen und für jeden Intervall einen Datensatz
  //  anlegen
  RecBufClear(711);
  vGantt # $ggMESSER;
  vLfndNR # 0;

  REPEAT
    // "linkestes" Interval suchen...
    vMin  # 10000;
    vMinO # 0;
    FOR   vObj # vGantt-> WinInfo(_WinFirst);
    LOOP  vObj # vObj-> WinInfo(_WinNext);
    WHILE (vObj > 0) do begin
      if (vObj->wparea:left<vMin) then begin
        vMin  # vObj->wparea:left;
        vMinO # vObj;
      end;
    END;
    if (vMinO=0) then BREAK;


    GetData(vMinO, var vFert, var vAnz, var vBreite, var vName, var vBreitenTol, var vVpgTxt);
    RecBufClear(711);
    inc(vLfndNR);

    BAG.PZ.Nummer     # Bag.P.Nummer;
    BAG.PZ.Position   # Bag.P.Position;
    BAG.PZ.lfdNr      # vLfndNR;
    BAG.PZ.Fertigung  # vFert;
    BAG.PZ.Anzahl     # vAnz;
    BAG.PZ.Anlage.Datum # today;
    BAG.PZ.Anlage.Zeit  # now;
    BAG.PZ.Anlage.User  # gUsername;
    RekInsert(711,0,'MAN');

    vMinO->WinGanttIvlRemove();
  UNTIL (vMinO=0);


  // fertigungen loopen...
  FOR  Erx # RecLink(703,702,4, _recFirst);
  LOOP Erx # RecLink(703,702,4, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    if (Bag.F.Fertigung >= 900) then
      CYCLE;

    RecRead(703,1,_recLock);
    BAG.F.Bemerkung #  vBem[BAG.F.Fertigung];
    RekReplace(703,_RecUnlock,'AUTO');
  END;

  RETURN true;
end;

//========================================================================
//========================================================================
//========================================================================


//========================================================================
//  EvtKeyItem
//
//========================================================================
sub EvtKeyItem(
  aEvt                 : event;    // Ereignis
  aKey                 : int;      // Taste
  aID                  : int;      // RecID bei RecList, Node-Deskriptor bei TreeView, Focus-Objekt bei Frame und AppFrame
) : logic;
local begin
  vHdl  : int;
end;
begin

  if (aKey=_WinKeyF2) then begin
    vHdl # WinInfo(aEvt:Obj,_winframe);
    if (SAVE()) then begin
      WinDialogResult(vHdl,_WinIdClose);
      WinClose(vHdl);
    end;
  end;

  RETURN(true);
end;


//========================================================================
//  EvtMouseItem
//
//========================================================================
sub EvtMouseItem(
  aEvt                 : event;    // Ereignis
  aButton              : int;      // Maustaste
  aHitTest             : int;      // Hittest-Code
  aItem                : handle;   // Spalte oder Gantt-Intervall
  aID                  : int;      // RecID bei RecList / Zelle bei GanttGraph / Druckobjekt bei PrtJobPreview
) : logic;
local begin
  vRect   : rect;
  vFert   : int;
  vAnz    : int;
  vBreite : float;
  vName   : alpha;
  vBreitenTol : alpha;
  vVpgTxt : alpha(200);
end;
begin
  if (aItem=0) then RETURN true;
  if (aHitTest<>_WinHitIvl) then RETURN true;
//  if (aItem->Wininfo(_Wintype)<>_WinTypeInterval) then RETURN false;

  ShowIvlInfo(aItem);

  if (aButton & _WinMouseDouble=_WinMouseDouble) then begin
    WinUpdate($ggFERTIGUNGEN,_WinUpdOff);
    WinUpdate($ggMESSER,_WinUpdOff);

    if (aEvt:Obj=$ggFERTIGUNGEN) then begin
      vRect # aItem->wparea;
      Split(aEvt:Obj, aItem, var vRect);
      Linksran($ggMESSER, var vRect);
      // verschieben...
      GetData(aItem, var vFert, var vAnz, var vBreite, var vName, var vBreitenTol, var vVpgTxt);
      IvlAdd($ggMESSER, vRect:left, vFert, vBreite, vAnz, vName, vBreitenTol, vVpgTxt);
      aItem->WinGanttIvlRemove();
    end;

    if (aEvt:Obj=$ggMESSER) then begin
      vRect # aItem->wparea;
      FullSort(aEvt:Obj, aItem);
      if (Zurueck2Fert($ggFERTIGUNGEN, aItem, var vRect)=false) then begin
        // verschieben...
        GetData(aItem, var vFert, var vAnz, var vBreite, var vName, var vBreitenTol, var vVpgTxt);
        IvlAdd($ggFERTIGUNGEN, vRect:left, vFert, vBreite, vAnz, vName, vBreitenTol, vVpgTxt);
        aItem->WinGanttIvlRemove();
      end;
    end;

    WinUpdate($ggFERTIGUNGEN,_WinUpdOn);
    WinUpdate($ggMESSER,_WinUpdOn);
  end;

  RETURN(true);
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vHdl : int;
end
begin

  if (aEvt:Obj->wpname='btRESET') then begin
    RESET();
  end;

  if (aEvt:Obj->wpname='btCANCEL') then begin
    vHdl # WinInfo(aEvt:Obj,_winframe);
    WinDialogResult(vHdl,_WinIdCancel);
    WinClose(vHdl);
  end;

  if (aEvt:Obj->wpname='btSAVE') then begin
    vHdl # WinInfo(aEvt:Obj,_winframe);
    if (SAVE()) then begin
      WinDialogResult(vHdl,_WinIdClose);
      WinClose(vHdl);
    end;
  end;

  RETURN true;
end;


//========================================================================
//  EvtDropItem
//
//========================================================================
sub EvtIvlDropItem(
  aEvt                 : event;    // Ereignis
  aHdlTarget           : handle;   // Deskriptor des Zielobjekts (GanttGraph)
  aHdlIvl              : handle;   // Deskriptor des Intervalls
  aDropType            : int;      // Drop Ereignis
  aRect                : rect;     // Position des Intervalls
) : logic;
local begin
  vA  : alpha;
end;
begin

  vA # aEvt:Obj->wpname+' > '+aHdlTarget->wpname;

  case vA of

    'ggFERTIGUNGEN > ggMESSER' : begin

      Split(aEvt:Obj, aHdlIvl, var aRect);
      if (aEvt:ID=_WinEvtIvlDropItemOverlap) then begin
        UmSort(aHdlTarget, var aRect, aHdlIvl, y);
        RETURN true;
      end;
      Linksran(aHdlTarget, var aRect);
      RETURN true;
    end;


    'ggMESSER > ggFERTIGUNGEN' : begin
      FullSort(aEvt:Obj, aHdlIvl);
      Zurueck2Fert(aHdlTarget, aHdlIvl, var aRect);
      RETURN true;
    end


    'ggMESSER > ggMESSER' : begin

      if (aEvt:ID=_WinEvtIvlDropItemOverlap) then begin
        UmSort(aHdlTarget, var aRect, aHdlIvl, n);
        RETURN false;
      end;

      FullSort(aHdlTarget, aHdlIvl);
      aRect # aHdlIvl->wparea;
      Linksran(aHdlTarget, var aRect, aHdlIvl);
      RETURN true;
    end;

  end;


  RETURN(false);
end;


//========================================================================
//  EvtClicked_AnzDlg
//
//========================================================================
sub EvtClicked_AnzDlg(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin

  vHdl # WinInfo(aEvt:Obj,_winframe);
  vHdl # WinSearch(vHdl, 'ieANZAHL');

  case aEvt:obj->wpname of
    'btMIN'   : vHdl->wpcaptionint # 1;
    'btMAX'   : vHdl->wpcaptionint # vHdl->wpmaxint;
    'btMINUS' : if (vHdl->wpcaptionint>1) then vHdl->wpcaptionint # vHdl->wpcaptionint - 1;
    'btPLUS'  : if (vHdl->wpcaptionint<vHdl->wpmaxint) then vHdl->wpcaptionint # vHdl->wpcaptionint + 1;
    'btHALF'  : if (vHdl->wpmaxint>1) then vHdl->wpcaptionint # vHdl->wpMaxInt / 2;
  end;

  RETURN(true);
end;


//========================================================================
//  Start
//
//========================================================================
sub Start(
  aBAG  : int;
  aPos  : int;
);
local begin
  Erx   : int;
  vWin  : int;
  vBut  : int;
  vB    : float;
  vHdl  : int;
end;
begin

  // Ankerfunktion?
  if (RunAFX('BAG.PZ.Messerbau',aint(aBag)+'|'+aint(aPos))<>0) then RETURN;


  vWIN # WinOpen(Lib_GuiCom:GetAlternativeName('BA1.PZ.Messerbau'),_Winopendialog);

  vHDl # Winsearch(vWIN, 'ggMESSER');

  // grösste Breite im Einsatz suchen...
  vB # 0.0;
  Erx # RecLink(701,702,2,_RecFirst);    // Input loopen
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.BruderID=0) then
      if (BAG.IO.Breite>vB) then vB # BAG.IO.Breite;
    Erx # RecLink(701,702,2,_RecNext);
  END;

  if (vB<>0.0) then
    vHDL->ppCellSizeHorz # 100 / cnvif(vB / 100.0);

  RESET(aBAG, aPos);

  vBut # Windialogrun(vWin);

  WInClose(vWin);

end;


//========================================================================
//========================================================================
//========================================================================