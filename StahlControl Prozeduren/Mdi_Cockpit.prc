@A+
//===== Business-Control =================================================
//
//  Prozedur  Mdi_Cockpit
//                  OHNE E_R_G
//  Info
//
//
//  26.10.2015  AH  Erstellung der Prozedur
//  04.03.2016  AH  vier AFX eingebaut
//  20.05.2016  AH  wpStatusItemPos als Flag für Design/nicht Design (war vorher Custom, aber muss Hdl für WindowBonus drin sein)
//  23.11.2017  AH  Erweiterung für INFO
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  cMaxSpalte    : 5
  cMDI          : gMdiNotifier
  //$MDI.Cockpit

  cAllZonesMax  : 24
  cClosedHeight : 30
  cMinDLWidth   : 100   // Wenn Fenster skaliert wird

  cIconDelete   : 174
  cIconNew      : 98

  cTypEventOld  : 110
  cTypEventNew  : 111

  FullRefresh(a) : a->wpDesign # !a->wpDesign; a->wpDesign # !a->wpDesign;

  cSep          : StrChar(254)
end;


/***
  Ablauf:
  - pro Zone ein Tree erstellen
  - alle Einträge da passend einsortieren
  - Zoneliste zeichnen:
    - Welche Spalte(GroupBox) ist die Zone? -> Gruppenzähler pro Spalte erhöhen, ggf. Spalte visible setzen
    - Spaltenhöhe DIV Gruppenzähler = Gruppenhöhe
    - Gruppe anlegen und füllen
***/

declare Spalte.Resize(aPar : int);
declare ZoneNameZu989(a989 : int) : alpha;
declare Header.Update(aBT : handle);

//========================================================================
//========================================================================
sub Off(aName : alpha);
begin
  gFrmMain->WinUpdate(_WinUpdOff);
//debug('OFF...   '+aName);
end;

//========================================================================
//========================================================================
sub On(aName : alpha);
begin
  gFrmMain->WinUpdate(_WinUpdOn);
//debug('ON   '+aName);
end;


//========================================================================
sub GetSetting(aWas : alpha) : alpha
local begin
  vItem : int;
end;
begin
  if (gUserSettings=0) then RETURN '';
  vItem # gUserSettings->CteRead(_CteFirst | _CteSearch,0,aWas);
  if (vItem=0) then RETURN '';

  RETURN vItem->spCustom;
end;


//========================================================================
sub SetSetting(aWas : alpha; aWert : alpha);
local begin
  vItem : int;
end;
begin
  if (gUserSettings=0) then RETURN;

  vItem # gUserSettings->CteRead(_CteFirst | _CteSearch,0,aWas);
  if (vItem<>0) then gUserSettings->CteDelete(vItem);

  gUserSettings->CteInsertItem(aWas, 0, aWert);
end;


//========================================================================
sub SaveSettings();
local begin
  vTxt  : int;
  vItem : int;
  vA    : alpha(250);
end;
begin

  vTxt # Textopen(16);
  FOR vItem # CteRead(gUserSettings, _cteFirst)
  LOOP vItem # CteRead(gUserSettings, _cteNext, vItem)
  WHILE (vItem<>0) do begin
    vA # vItem->spName+'|'+vItem->spCustom;
    TextAddLine(vTxt, vA);
  END;
  TextWrite(vTxt, 'INI2'+gUsername, 0);
  TextClose(vTxt);
end;


//========================================================================
sub LoadSettings();
local begin
  vTxt  : int;
  vItem : int;
  vA    : alpha(250);
end;
begin
  vTxt # Textopen(16);
  if (TextRead(vTxt, 'INI2'+gUsername, 0)<=_rLocked) then begin

    vA # TextLineRead(vTxt, 1, _textLineDelete);
    WHILE (vA<>'') do begin
      SetSetting(Str_Token(vA,'|',1), Str_Token(vA,'|',2));
      vA # TextLineRead(vTxt, 1, _textLineDelete);
    END;
  end;

  TextClose(vTxt);
end;


//========================================================================
//========================================================================
sub ReadEvent(aRecID : int) : logic;
begin
  RETURN (RecRead( 989, 0, _recId, aRecID ) <= _rLocked );
end;


//========================================================================
//========================================================================
sub GetEventIDFromItem(aItem : int) : int;
begin
  if (aItem = 0) then
    RETURN 0;
  RETURN (cnvia(Str_Token(aItem->spName, cSep,2)));
end;


//========================================================================
//========================================================================
sub FindItemFrom989InTree(
  a989  : int;
  aTree : int) : int;
local begin
  vItem   : int;
  vRecId  : alpha;
end;
begin

  vRecId # aint(RecInfo(a989,_recID));
  FOR vItem # CteRead(aTree, _CteFirst)
  LOOP vItem # CteRead(aTree, _Ctenext, vItem);
  WHILE (vItem<>0) do begin
//debugx(Str_Token(vItem->spName, '|',2)+' === '+vRecID);
    if (Str_Token(vItem->spName, cSep,2)=vRecID) then RETURN vItem;
  END;

  RETURN 0;
end;


//========================================================================
//========================================================================
sub RefreshItem989(
  a989    : int;
  aDel    : logic) : alpha;
local begin
  vName   : alpha;
  vZone   : int;
  vDL     : int;
  vBT     : int;
  vTree   : int;
  vItem   : int;
  vMax    : int;
  vRow    : int;
  vID     : int;
  vText   : alpha(1000);
end;
begin

  vText # a989->Tem.E.Bemerkung;
  if (a989->TeM.E.Ergebnistext<>'') then vText # vText + ': '+a989->TeM.E.ErgebnisText;

  vName # ZoneNameZu989(a989);
  if (vName='') then RETURN 'no Name';

  vBT # Winsearch(cMDI, 'bt.Zone'+vName)

  // Gruppe suchen
  vZone # Winsearch(cMDI, vName);
  if (vZone=0) then RETURN 'no Zone';

  // DL Suchen
  vDL # Winsearch(vZone, 'dl.Zone'+vName);
  if (vDL=0) then RETURN 'no DL';

  vTree # cnvia(vZone->wpCustom);
  if (vTree=0) then RETURN 'no tree';

  vItem # FindItemFrom989InTree(a989, vTree);
  if (vItem=0) then RETURN 'no item';


  // OPTIK?
  vMax # vDL->WinLstDatLineInfo(_WinLstDatInfoCount);
  FOR vRow # 1
  LOOP inc(vRow)
  WHILE (vRow<=vMax) do begin
    vDL->WinLstCellGet(vID,1,vRow);
    if (vID=vItem) then begin

      if (aDel) then begin
        if (vItem->spID=cTypEventNew) then begin
          vBT->wpID # vBT->wpID - 1;          // NEU Zähler mindern
          Header.Update(vBT);
        end
        vDL->WinLstDatLineRemove(vRow);
        BREAK;
      end;

      // Optik...
      vDL->WinLstCellSet(vText,4, vRow);
      BREAK;
    end;
  END;



  if (aDel) then begin
    CteDelete(vTree, vItem);              // Item löschen
    CteClose(vItem);
  end
  else begin
    // RAM...
    vText # vText + cSep +aint(recinfo(a989,_recID));
    vText # vText + cSep + aint(vItem);
    vItem->spName   # vText;
  end;


RETURN '';
/**x
  // ZOne suchen...
  vTree # Winsearch(gMDINotifier, aZone);
  if (vTree=0) then RETURN 0;
  // Tree holen...
  vTree # cnvia(vTree->wpCustom);
  if (vTree=0) then RETURN 0;

  vRecId # aint(aRecID);
  FOR vItem # CteRead(vTree, _CteFirst)
  LOOP vItem # CteRead(vTree, _Ctenext, vItem);
  WHILE (vItem<>0) do begin
    if (Str_Token(vItem->spName, cSep,2)=vRecID) then RETURN vItem;
  END;

  RETURN 0;
  ***/
end;


//========================================================================
//========================================================================
sub Tree.ToSortList(
  aTree     : handle;
  aByName   : logic;
  aReverse  : logic) : handle;
local begin
  vTree     : handle;
  vList     : handle;
  vItem     : int;
  vItem2    : int;
  vA        : alpha;
  vName     : alpha(1000);
end;
begin
/*
  if (aByName) then vA # 'name'
  else vA # 'uhr';
  if (aReverse) then vA # vA + ' REV'
  else vA # vA + '   ';
debug(vA);
*/

  vList # CteOpen(_CteList);

  vTree # CteOpen(_CteTreeCI);
//  vList # CteOpen(_CteList);
  FOR vItem # CteRead(aTree, _ctefirst)
  LOOP vItem # CteRead(aTree, _cteNext, vItem)
  WHILE (vItem<>0) do begin

    if (aByName) then vName # vItem->spName
    else vName # vItem->spCustom;
    vName # vName + cSep +aint(vItem);
    vTree->CteInsertItem(vName, vItem, '');
  END;


  // tmp.Sorttree loopen...
  if (aReverse=false) then begin
    FOR vItem # CteRead(vTree, _cteFirst)
    LOOP vItem # CteRead(vTree, _cteNext, vItem)
    WHILE (vItem<>0) do begin
      vItem2 # vItem->spID;
      // in sortierte Liste schieben
      vList->CteInsert(vItem2);
    END;
  end
  else begin
    FOR vItem # CteRead(vTree, _cteLast)
    LOOP vItem # CteRead(vTree, _ctePrev, vItem)
    WHILE (vItem<>0) do begin
      vItem2 # vItem->spID;
      // in sortierte Liste schieben
      vList->CteInsert(vItem2);
    END;
  end;

  vTree->cteClear(true);
  vTree->cteClose();

  RETURN vList;
end;


//========================================================================
//========================================================================
sub Header.Update(aBT : handle);
local begin
  vText   : alpha;
end;
begin
  vText # aBT->wpCustom;
  if (aBT->wpID<>0) then vText # vText + ' ('+aint(aBT->wpID)+' neu)';
  aBT->wpCaption # vText;
end;


//========================================================================
//========================================================================
sub Zone.Update(
  aName   : alpha;
  aZone   : int);
local begin
  vA      : alpha;
  vDL     : int;
  vBT     : int;
  vHdl    : int;
  vDesign : logic;
  vTree   : int;
  vText   : alpha;
end;
begin
//  vDesign # (cMDI->wpCustom='Design');
vDesign # (cMDI->wpStatusItemPos = 1);


  if (aZone=0) then
    aZone # Winsearch(cMDI, aName)
  else
    aName # aZone->wpName;
  if (aZone=0) then RETURN;

  vA # GetSetting('Cockpit.Zone.'+aName+'.Open');
  if (vDesign) then begin
    vA # 'N';
    SetSetting('Cockpit.Zone.'+aName+'.Open', vA);
  end;


  vBT # Winsearch(cMDI, 'bt.Zone'+aName)
  vDL # Winsearch(cMDI, 'dl.Zone'+aName)

  vText # vBT->wpCustom;
  if (vBT->wpID<>0) then vText # vText + ' ('+aint(vBT->wpID)+' neu)';
  vBT->wpCaption # vText;

  if (vA='N') then begin
    vBT->wpImageTile      # _WinImgNext;
    vDL->wpvisible        # false;
    if (vDesign) then
      aZone->wpAlignHeight # cClosedHeight;
  end
  else begin
    vBT->wpImageTile      # _WinImgPageNext;
    vDL->wpvisible        # true;
  end;

  vTree # cnvia(aZone->wpCustom);
  if (vTree=0) then RETURN;

  // Kein Inhalt?
//  if (vDesign=false) and (vDL->WinLstDatLineInfo(_WinLstDatInfoCount)=0) then begin
  if (vDesign=false) and (vTree->CteInfo(_cteCount)=0) then begin
    aZone->wpvisible  # false;
  end
  else begin
    aZone->wpvisible  # true;
  end;

end;


//========================================================================
//========================================================================
sub Zone.Draw(
  aName       : alpha;
  aZone       : int);
local begin
  vDL     : int;
  vBT     : int;
  vTree   : int;
  vItem   : int;
  vText1  : alpha(500);
  vText2  : alpha(500);
  vBig    : bigint;
  vCT     : caltime;
  vNeu    : logic;
  vHdl    : int;
  vList   : int;
end
begin

  if (aZone=0) then
    aZone # Winsearch(cMDI, aName)
  else
    aName # aZone->wpName;
  if (aZone=0) then RETURN;

  vTree # cnvia(aZone->wpCustom);
  if (vTree=0) then RETURN;

  vDL # Winsearch(aZone, 'dl.Zone'+aName)
  if (vDL=0) then RETURN;

  vBT # Winsearch(aZone, 'bt.Zone'+aName)
  if (vBT=0) then RETURN;

  vDL->wpAutoupdate # false;
  vDL->WinLstDatLineRemove(_WinLstDatLineAll);

//  if (aSortByCust)
  vBT->wpID # 0;


  vHdl # Winsearch(vDL, 'clm3');
  if (vHdl->wpClmSortImage = _WinClmSortImageDown) then begin
    vList # Tree.ToSortList(vTree, true, true);
  end
  else if (vHdl->wpClmSortImage = _WinClmSortImageUp) then begin
    vList # Tree.ToSortList(vTree, true, false);
  end
  else begin
    vHdl # Winsearch(vDL, 'clm4');
    if (vHdl->wpClmSortImage = _WinClmSortImageDown) then begin
      vList # Tree.ToSortList(vTree, false, true);
    end
    else begin
      vList # Tree.ToSortList(vTree, false, false);
    end;
  end;



  FOR vItem # vList->CteRead(_CteFirst)
  LOOP vItem # vList->CteRead(_CteNext, vItem)
  WHILE (vItem<>0) do begin
    vNeu    # vItem->spID = cTypEventNew;
    vText1  # str_token(vItem->spName, cSep,1);
    vBig    # cnvba(vItem->spCustom);
    vCT     # cnvcb(vBig);
    vText2  # cnvai(vCT->vpDay,_FmtNumleadzero,0,2)+'.'+cnvai(vCT->vpMonth,_FmtNumleadzero,0,2)+'.'+cnvai(vCT->vpYear-2000,_FmtNumleadzero,0,2)+' / '+cnvai(vCT->vpHours,_FmtNumleadzero,0,2)+':'+cnvai(vCT->vpMinutes,_FmtNumleadzero,0,2)+' Uhr';
    vDL->WinLstDatLineAdd(vItem);
//debugx('add zeile '+aint(vDL->WinLstDatLineAdd(3))+' in '+vDL->wpName);
    vDL->WinLstCellSet(cIconDelete, 2, _WinLstDatLineLast);
    if (vNeu) then begin
      vDL->WinLstCellSet(cIconNew, 3, _WinLstDatLineLast);
      vBT->wpID # vBT->wpID + 1;          // NEU Zähler erhöhen
      Header.Update(vBT);
    end;
    vDL->WinLstCellSet(vText1, 4, _WinLstDatLineLast);
    vDL->WinLstCellSet(vText1, 4, _WinLstDatLinelast, _WinLstDatModeSortInfo);
    vDL->WinLstCellSet(vText2, 5, _WinLstDatLineLast);
    vDL->WinLstCellSet(vBig, 5, _WinLstDatLinelast, _WinLstDatModeSortInfo);

  END;
  CteClose(vList);

  if (aZone->wpvisible=false) then begin
    Zone.Update('',aZone);
    Spalte.Resize(Wininfo(aZone,_winparent));
  end;

  vDL->wpAutoupdate # true;
  vDL->Winupdate(_winupdon|_WinLstFromTop);

end;


//========================================================================
//========================================================================
Sub Spalte.DrawAll();
local begin
  vSpalte : int;
  vZone   : int;
end;
begin

OFF(__PROCFUNC__);

  FOR vSpalte # WinInfo(cMDI, _winfirst)
  LOOP vSpalte # WinInfo(vSpalte, _winNext)
  WHILE (vSpalte<>0) do begin

    FOR vZone # WinInfo(vSpalte, _winfirst)
    LOOP vZone # WinInfo(vZone, _winNext)
    WHILE (vZone<>0) do begin
      Zone.Draw('', vZone);
    END;

  END;

ON(__PROCFUNC__);

end;


//========================================================================
//========================================================================
sub Spalte.Close(aSP : int);
local begin
  vZone : int;
  vTree : int;
end
begin

  FOR vZone # WinInfo(aSP, _winfirst)
  LOOP vZone # WinInfo(vZone, _winNext)
  WHILE (vZone<>0) do begin
    vTree # cnvia(vZone->wpcustom);
    if (vTree<>0) then begin
      vTree->CteClear(true);
      vTree->CteClose();
      vZone->wpCustom # '';
    end;
  END;

end;


//========================================================================
//========================================================================
sub Spalte.Save(aSP : int);
begin
  SetSetting('Cockpit.'+aSP->wpname+'.Width', aint(aSP->wpAreaRight - aSP->wpAreaLeft));
end;


//========================================================================
//========================================================================
sub Spalte.Load(aSP : int);
local begin
  vA    : alpha;
  vI    : int;
end;
begin
  vA # GetSetting('Cockpit.'+aSP->wpname+'.Width');
  if (vA='') then vA # '200';
  vI # cnvia(vA);
  aSP->wpAreaRight # aSP->wpAreaLeft + vI;
end;


//========================================================================
//========================================================================
Sub Spalte.Resize(aPar : int);
local begin
  vZone   : int;
  vMin    : int;
  vMax    : int;
  vH      : int;
  vDesign : logic;
end;
begin
//  vDesign # (cMDI->wpCustom='Design');
vDesign # (cMDI->wpStatusItemPos = 1);


  if (vDesign) then
    aPar->wpAreaBottom # cMdi->wpAreaBottom - 50;
//    cMDI->wpAreaTop + (cAllZonesMax * cClosedHeight);


  // Offen/geschlossen zählen...
  FOR vZone # WinInfo(aPar, _winfirst)
  LOOP vZone # WinInfo(vZone, _winNext)
  WHILE (vZone<>0) do begin
//          if (vDL->WinLstDatLineInfo(_WinLstDatInfoCount)<>0) then begin
    if (vZone->wpVisible=false) then CYCLE;

    if (GetSetting('Cockpit.Zone.'+vZone->wpName+'.Open')='N') then begin
      inc(vMin);
    end
    else begin
      inc(vMax);
    end;
    vZone->wpAutoupdate # false;
  END;

  vH # aPar->wpAreaBottom - aPar->wpAreaTop;
//if (aPar->wpname='Spalte1') then
//debugx('Buttom:'+aint(vH)+'   min:'+aint(vMin)+'   max:'+aint(vMax));
  // geschlossene abziehen...
  vH # vH - (cClosedHeight * vMin);
  if (vH<0) then vH # 1;

  // Rest auf geöffnete gleichmäßig verteilen...
  if (vMax<>0) then
    vMax # vH / vMax;

  // Größe setzen...
  FOR vZone # WinInfo(aPar, _winfirst)
  LOOP vZone # WinInfo(vZone, _winNext)
  WHILE (vZone<>0) do begin
    if (vMax<>0) and (GetSetting('Cockpit.Zone.'+vZone->wpName+'.Open')<>'N') then begin
      vZone->wpAreaBottom  # vMax;
      vZone->wpAlignHeight # vMax;
    end
    else begin
      vZone->wpAlignHeight # cClosedHeight;
    end;
  END;

  // alle darstellen
  FOR vZone # WinInfo(aPar, _winfirst)
  LOOP vZone # WinInfo(vZone, _winNext)
  WHILE (vZone<>0) do begin
    vZone->WinUpdate(_winupdon);
  END;

//FullRefresh(aPar);
end;


//========================================================================
//========================================================================
sub Spalte.ResizeAll();
begin
  Spalte.Resize($Spalte1);
  Spalte.Resize($Spalte2);
  Spalte.Resize($Spalte3);
  Spalte.Resize($Spalte4);
  Spalte.Resize($Spalte5);
end;


//========================================================================
//========================================================================
sub Spalte.Update(aSpalte : int);
local begin
  vZone   : int;
end;
begin

  aSpalte->wpAutoupdate # false;

  FOR vZone # aSpalte->WinInfo(_Winfirst)
  LOOP vZone # vZone->WinInfo(_WinNext)
  WHILE (vZone<>0) do begin
//winsleep(20);
    Zone.Update('',vZone);
  END;

  aSpalte->Winupdate(_Winupdon);

end;


//========================================================================
//========================================================================
Sub Spalte.UpdateAll(aPar : int);
local begin
  vI    : int;
  vHdl  : int;
  vZone : int;
  vMax  : int;
end
begin

  // höchste gefüllte Spalte ermitteln
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxSpalte) do begin
    vHdl # Winsearch(aPar, 'Spalte'+aint(vI));
    if (vHdl=0) then BREAK;

    if (vHdl->Wininfo(_winfirst)>0) then
      vMax # vI;
  END;


  aPar->wpAutoupdate # false;

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxSpalte) do begin
    vHdl # Winsearch(aPar, 'Spalte'+aint(vI));
    if (vHdl=0) then BREAK;
    if (vI<vMax) then begin
//debug(vHdl->wpname+' ist links');
      vHdl->wpAlignGrouping # _WinAlignGroupingLeft;
      vHdl->wpvisible       # true;
//      vHdl->wpALignGrouping # _WinAlignGroupingLeft;
    end
    else if (vI=vMax) then begin
//debug(vHdl->wpname+' ist MAX');
      vHdl->wpAlignGrouping # _WinAlignGroupingTiled;
      vHdl->wpvisible       # true;

      cMDI->wpAreaWidthMin # vHdl->wpAreaLeft+cMinDLWidth;

//      vHdl->wpALignGrouping # _WinAlignGroupingTiled;
//vhdl->winupdate(_Winupdon);
    end
    else if (vI>vMax) then begin
//      vHdl->wpAlignGrouping # _WinAlignGroupingLeft;
      vHdl->wpvisible       # false;
    end;
  END;


  // alle Header refreshen
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxSpalte) do begin
    vHdl # Winsearch(aPar, 'Spalte'+aint(vI));
    if (vHdl=0) then CYCLE;

    Spalte.Update(vHdl);
  END;


  aPar->Winupdate(_winupdon);
  if (aPar->wpGrouping=_WinGroupingNone) then begin
    aPar->wpGrouping # _WinGroupingTileHorz;
    aPar->wpGrouping # _WinGroupingNone;
  end;

//  aPar->winupdate(_winupdon | _WinupdActivate);

end;


//========================================================================
//========================================================================
sub Obj.Move(
  aGrp  : int;
  aWay  : int)
local begin
  vA    : alpha;
  vI    : int;
  vSP1  : int;
  vSP2  : int;
  vX    : int;
end;
begin

  vA # GetSetting('Cockpit.Zone.'+aGrp->wpName+'.Spalte');
  if (vA='') then vA # '1';

  vI # cnvia(vA);
  if (vI + aWay < 1) or (vI + aWay > cMaxSpalte) then RETURN;


  vSP1 # Winsearch(cMDI, 'Spalte'+aint(vI));
  if (vSP1=0) then RETURN;

  vI # vI + aWay;
  vSP2 # Winsearch(cMDI, 'Spalte'+aint(vI));
  if (vSP2=0) then RETURN;

OFF(__PROCFUNC__);

  WinRemove(aGrp);

  FullRefresh(vSP1);

  WinAdd(vSP2, aGrp);

  // damit neue Spalte generieren?
  if (vSP2->wpvisible=false) then begin
    vSP2->wpVisible       # true;
    vX # ((vSP1->wpAreaRight - vSp1->wparealeft) / 2);  // Breite gerecht teilen
    vSP1->wpAlignGrouping # _WinAlignGroupingLeft;
    vSP1->wpAreaRight     # vSP1->wpAreaLeft + vX;
    vSP2->wpAreaLeft      # vSP1->wpAreaRight + 4;
    vSp2->wparearight     # vSP2->wpAreaLeft + vX;
    vSP1->wpAlignGrouping # _WinAlignGroupingTiled;
    // FEnster beschränken
    cMDI->wpAreaWidthMin  # vSP2->wpAreaLeft+cMinDLWidth;
  end;

//  vSP2->wpVisible   # true;
//  cMDI->wpGrouping # _WinGroupingTileHorz;
//  cMDI->wpGrouping # _WinGroupingNone;

//  FullRefresh(vSP2);

  SetSetting('Cockpit.Zone.'+aGrp->wpName+'.Spalte', aint(vI));

  Spalte.UpdateAll(cMDI);

ON(__PROCFUNC__);

end;


//========================================================================
//========================================================================
sub Zone.Create(
  aPar        : int;
  aName       : alpha;
  aCaption    : alpha) : int;
local begin
  vSpalte     : int;
  vSpalteNr   : int;
  vSource     : int;
  vZone       : int;
  vHdl        : int;
  vI          : int;
  vMaxNr      : int;
  vTree       : int;
end;
begin

  vSpalteNr # cnvia(GetSetting('Cockpit.Zone.'+aName+'.Spalte'));
  if (vSpalteNr=0) then begin
    vSpalteNr # 1;
    if (aName='Opa') then vSpalteNr # 3;
    SetSetting('Cockpit.Zone.'+aName+'.Spalte', aint(vSpalteNr));
  end;


  vSource # Winsearch(aPar, 'gb.Zone');
  vSpalte # Winsearch(aPar, 'Spalte'+aint(vSpalteNr));
  vZone # Lib_GuiDynamisch:CopyObject(vSource, aName, vSpalte, true);

  // jede Zone erhält einen Tree
  vTree # CteOpen(_CteTreeCI);
  vZone->wpCustom # aint(vTree);

  // Zone heisst immer aNAME
  vZone->wpName    # aName;

  // Button setzen
  vHdl # Winsearch(vZone, 'bt.Zone'+aName);
  vHdl->wpcaption # aCaption;
  vHdl->wpcustom  # aCaption;
  vHdl->wpID      # 0;

  // DataList füllen
//  vHdl # Winsearch(vZone, 'dl.Zone'+aName);

  // Aktiv schalten
  vZone->wpVisible     # true;
  vZone->wpAutoupdate  # true;

//  Spalte.RedrawAll(cMDI);

  RETURN vZone;
end;


//========================================================================
//========================================================================
sub Zone.AddItem(
  aZone   : int;
  aText   : alpha(1000);
  aStamp  : bigint;
  aStarYN : logic);
local begin
  vTree   : int;
  vItem   : int;
end;
begin

  vTree # cnvia(aZone->wpCustom);
  if (vTree=0) then RETURN;

  vItem # CteOpen(_CteItem);
//  aText1 # aText1 + cSep + aint(vItem);
  aText # aText + cSep + aint(vItem);
  vItem->spName   # aText;
//  vItem->spCustom # aText2;
  vItem->spCustom # cnvab(aStamp,_FmtNumnogroup);
  if (aStarYN) then
    vItem->spID # cTypEventNew
  else
    vItem->spID # cTypEventold;

  vTree->CteInsert(vItem);
end;


//========================================================================
//========================================================================
sub CloseAll();
begin
  Spalte.Close($Spalte1);
  Spalte.Close($Spalte2);
  Spalte.Close($Spalte3);
  Spalte.Close($Spalte4);
  Spalte.Close($Spalte5);
end;


//========================================================================
//========================================================================
sub SaveAll();
begin
  Spalte.Save($Spalte1);
  Spalte.Save($Spalte2);
  Spalte.Save($Spalte3);
  Spalte.Save($Spalte4);
  Spalte.Save($Spalte5);

  SaveSettings();
end;


//========================================================================
//========================================================================
sub Init(aMdi : int)
local begin
  vHdl  : int;
  vA    : alpha;
  vI    : int;
end;
begin

  LoadSettings();

  Spalte.Load($Spalte1);
  Spalte.Load($Spalte2);
  Spalte.Load($Spalte3);
  Spalte.Load($Spalte4);
  Spalte.Load($Spalte5);

  Zone.Create(aMdi, 'INFO',        'Information');

  Zone.Create(aMdi, 'TAPI',        'geführte Telefonate');
  Zone.Create(aMdi, 'TAPI_TMP',    'verpasste Anrufe');
  Zone.Create(aMdi, 'PROJEKTPOSX', 'dringendes Ticket');
  Zone.Create(aMdi, 'PROJEKTPOS',  'Ticket');

  Zone.Create(aMdi, 'EVENT_AFG',   'Aufgabe');
  Zone.Create(aMdi, 'EVENT_BSP',   'Besprechung');
  Zone.Create(aMdi, 'EVENT_BRF',   'Brief');
  Zone.Create(aMdi, 'EVENT_EMA',   'EMail');
  Zone.Create(aMdi, 'EVENT_FAX',   'Fax');
  Zone.Create(aMdi, 'EVENT_GSV',   'Geschenkversand');
  Zone.Create(aMdi, 'EVENT_INF',   'Info');
  Zone.Create(aMdi, 'EVENT_SMS',   'SMS');
  Zone.Create(aMdi, 'EVENT_TEL',   'Telefonat');
  Zone.Create(aMdi, 'EVENT_TER',   'Termin');
  Zone.Create(aMdi, 'EVENT_WVL',   'Wiedervorlage');
  Zone.Create(aMdi, 'EVENT_WOF',   'Workflow');

  Zone.Create(aMdi, 'F100',        'Adresse');
  Zone.Create(aMdi, 'F102',        'Ansprechpartner');
  Zone.Create(aMdi, 'F250',        'Artikel');
  Zone.Create(aMdi, 'F401',        'Auftrag');
  Zone.Create(aMdi, 'F501',        'Bestellung');
  Zone.Create(aMdi, 'F200',        'Material');
  Zone.Create(aMdi, 'F120',        'Projekt');
  Zone.Create(aMdi, 'F122',        'Projektpos');
  // Summe 24 ZONEN = KONSTANTE oben

  RunAFX('Mdi.Cockpit.AddCustomZones', AInt(aMDI));

  Spalte.Resize($Spalte1);
  Spalte.Resize($Spalte2);
  Spalte.Resize($Spalte3);
  Spalte.Resize($Spalte4);
  Spalte.Resize($Spalte5);
  RETURN;
end;




//========================================================================
//========================================================================
sub Design.Start();
local begin
  vW      : int;
  vHdl    : int;
  vI      : int;
end;
begin

OFF(__PROCFUNC__);

  cMDI->wpGrouping    # _WinGroupingNone;
//  cMDI->wpCustom      # 'Design';
cMDI->wpStatusItemPos # 1;
  cMDI->wpautoupdate  # false;

cMDI->wpAreaBottom # cMDI->wpAreaTop + (cAllZonesMax * cClosedHeight) + 50;

  // Elemente auf "Design" umstellen
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxSpalte) do begin
    vHdl # Winsearch(cMDI, 'Spalte'+aint(vI));
    if (vHdl<>0) then begin
      Spalte.Update(vHdl);
    end;
  END;

  // "Design" aktivieren
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxSpalte) do begin
    vHdl # Winsearch(cMDI, 'Spalte'+aint(vI));
    if (vHdl<>0) then begin
      vHdl->wpDesign # true;
    end;
  END;


  cMDI->Winupdate(_WinUpdOn);

ON(__PROCFUNC__);

end;


//========================================================================
//========================================================================
sub Design.Stop();
local begin
  vW      : int;
  vHdl    : int;
  vI      : int;
end;
begin

OFF(__PROCFUNC__);

  cMDI->wpGrouping # _WinGroupingTileHorz;
//  cMDI->wpCustom # '';
cMDI->wpStatusItemPos # 0;

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=cMaxSpalte) do begin

    vHdl # Winsearch(cMDI, 'Spalte'+aint(vI));
    if (vHdl<>0) then begin
      Spalte.Update(vHdl);
      vW # vHdl->wpAreaRight - vHdl->wpAreaLeft;
      if (vW>0) then
        vHdl->wpAlignWidth # vW;
      vHdl->wpDesign # False;
    end;
  END;

ON(__PROCFUNC__);

end;



//========================================================================
//========================================================================
sub ZoneNameZu989(
  a989    : int
) : alpha;
local begin
  v980    : int;
  vName   : alpha;
  vName2  : alpha;
  vA,vB   : alpha(250);
end;
begin

  vA          # GV.Alpha.01;
  GV.Alpha.01 # '';
  if (RunAFX('Mdi.Cockpit.ZoneNameZu989',  Aint(a989)) < 0) then begin
    vB          # GV.Alpha.01;
    GV.Alpha.01 # vA;
    RETURN vB;
  end;
  GV.Alpha.01 # vA;



  vName # a989->TeM.e.Aktion;
  if (StrCut(vName,1,4)='INFO') then
    vName2 # 'INFO';
  else if (StrCut(vName,1,4)='TAPI') then
    vName2 # 'TAPI';
  else if (StrCut(vName,1,4)='TAPI_TMP') then
    vName2 # 'TAPI_TMP';
  else if (StrCut(vName,1,7)='122>800') and (a989->"TeM.E.Priorität">0) then
    vName2 # 'PROJEKTPOSX';
  else if (StrCut(vName,1,7)='122>800') then
    vName2 # 'PROJEKTPOS';
  else if (StrCut(vName,1,3)='980') then begin
    vName2 # 'EVENT';
    v980 # RecBufCreate(980);
    v980->TeM.Nummer # a989->TeM.E.Aktionsnr;
    if (RecRead(v980, 1, 0)<=_rLocked) then begin
      //vName2 # 'EVENT_'+v980->Tem.Typ;
      vName2 # 'EVENT_'+Lib_Termine:GetBasisTyp(v980->TeM.Typ);
    end;
    RecbufDestroy(v980);
  end
  // Datei?
  else begin
    if (StrLen(vName)>=3) and (StrCut(vName,1,3)>='001') and (StrCut(vName,1,3)<='999') then vName2 # 'F'+StrCut(vName,1,3);
  end;

  RETURN vName2;
end;


//========================================================================
//========================================================================
sub Add989(
  a989  : int) : int;   // Returns Zone
local begin
  vName   : alpha;
  vZone   : int;
  vDL     : int;
//  vStamp  : alpha;
  vText   : alpha(500);
  vDat    : date;
  vCT     : caltime;
end;
begin

  vName # ZoneNameZu989(a989);
  if (vName='') then RETURN 0;

  // Gruppe suchen
  vZone # Winsearch(cMDI, vName);
  if (vZone=0) then RETURN 0;

  vText # a989->Tem.E.Bemerkung;
  if (a989->TeM.E.Ergebnistext<>'') then vText # vText + ': '+a989->TeM.E.ErgebnisText;
  vText # vText + cSep +aint(recinfo(a989,_recID));

  vDat # today;
  if (a989->Tem.E.Datum<>0.0.0) then
    vDat # a989->Tem.E.Datum;
    //vStamp # cnvai(DateDay(a989->Tem.E.Datum))+'.'+cnvai(DateMonth(a989->Tem.E.Datum))+'.'+cnvai(DateYear(a989->Tem.E.Datum)-100);
//    vStamp # cnvai(DateDay(a989->Tem.E.Datum),_FmtNumLeadZero,0,2)+'.'+cnvai(DateMonth(a989->Tem.E.Datum),_FmtNumLeadZero,0,2)+'.'+cnvai(DateYear(a989->Tem.E.Datum)-100);
//  vStamp # vStamp + ' / '+cnvat(a989->Tem.E.Zeit,_FmtTimeSeconds|_FmtTime24Hours)+' Uhr';

  vCT->vmServerTime();
  vCT->vpdate # vDat;
  vCT->vptime # a989->Tem.E.Zeit;
  Zone.AddItem(vZone, vText, cnvbc(vCT), a989->TeM.E.NeuYN);

  RETURN vZone;
/***
  // DataList suchen
  vDL   # Winsearch(vZone, 'dl.Zone'+vName);
  vDL->WinLstDatLineAdd(123);
  vDL->WinLstCellSet(cIconDelete, 2, _WinLstDatLineLast);
  if (a989->TeM.E.NeuYN) then
    vDL->WinLstCellSet(cIconNew, 3, _WinLstDatLineLast);
  vDL->WinLstCellSet(a989->Tem.E.Bemerkung, 4, _WinLstDatLineLast);
  vDL->WinLstCellSet(vStamp, 5, _WinLstDatLineLast);
***/
end;


//========================================================================
//========================================================================
sub AddTapi(
 aBem   : alpha;
 aDat   : date;
 aTim   : time);
local begin
  vName : alpha;
  vZone : int;
  vDL   : int;
  vCT   : caltime;
end;
begin
  vName # 'TAPI_TMP';
  if (cMDI=0) then RETURN;

  // Gruppe suchen
  vZone # Winsearch(cMDI, vName);
  if (vZone=0) then RETURN;

  if (aDat=0.0.0) then aDat # today;
  vCT->vpdate # aDat;
  vCT->vptime # aTim;

  Zone.AddItem(vZone, aBem, cnvbc(vCT), true);
  Off(__PROCFUNC__);
  Zone.Draw('', vZone);
  On(__PROCFUNC__);

/***
  // DataList suchen
  vDL   # Winsearch(vZone, 'dl.Zone'+vName);
  vDL->WinLstDatLineAdd(123);
  vDL->WinLstCellSet(cIconDelete, 2, _WinLstDatLineLast);
  vDL->WinLstCellSet(cIconNew, 3, _WinLstDatLineLast);
  vDL->WinLstCellSet(aBem, 4, _WinLstDatLineLast);
  vDL->WinLstCellSet(aStamp, 5, _WinLstDatLineLast);
***/
/***
  // Zone ggf. einblenden
  if (vZone->wpvisible=false) then begin
    Zone.Update(vZone->wpname);
    Spalte.Resize(Wininfo(vZone,_winparent));
  end;
***/

end;


//========================================================================
//========================================================================
sub BuildLists();
local begin
  Erx   : int;
  v989  : int;
end;
begin

  GV.Sys.Username   # gUsername;
  v989 # RecBufCreate(989);
  FOR Erx # RecLink(v989, 999, 6, _recFirst);
  LOOP Erx # RecLink(v989, 999, 6, _recNext);
  WHILE (Erx<=_rLocked) do begin
//    Mdi_Cockpit:AddEventToZoneList(gZoneList, v989, v989->TeM.E.NeuYN);
    Add989(v989);
  END;
  RecBufDestroy(v989);

end;


//========================================================================
//========================================================================
Sub ToggleItemStar(
  aDL   : int;
  aID   : int;
  aItem : int);
local begin
  vZone : int;
  vBT   : int;
  vNew  : logic;
end;
begin

  vZone # Wininfo(aDL,_Winparent);
  vBT   # WinSearch(vZone, 'bt.Zone'+vZone->wpName);

  if (aItem->spID=cTypEventOld) then begin
    aItem->spID # cTypEventNew;
    vBT->wpID # vBT->wpID + 1;          // NEU Zähler erhöhen
    vNew # y;
    Header.Update(vBT);
  end
  else if (aItem->spID=cTypEventNew) then begin
    aItem->spID # cTypEventOld;
    if (vBT->wpID>0) then
    vBT->wpID # vBT->wpID - 1;          // NEU Zähler mindern
    Header.Update(vBT);
  end

  if (vNew) then
    aDL->WinLstCellSet(cIconNew, 3, aID)
  else
    aDL->WinLstCellSet(0, 3, aID);

  // ggf. Event updaten...
  if (ReadEvent(GetEventIDFromItem(aItem))) then begin
    RecRead(989,1,_recLock);
    TeM.E.NeuYN     # !TeM.E.NeuYN;
    RekReplace(989,_recunlock,'MAN');
  end;

  Zone.Update('',vZone);

end;


//========================================================================
//========================================================================
sub DeleteItemFromDL(
  aItem     : int;
  aDL       : int;
  aRow      : int;
  aMan      : logic) : logic
local begin
  erx       : int;
  vZone     : int;
  vBT       : int;
  vTree     : int;
  v980    : int;
end;
begin

  if (aItem=0) then RETURN true;

  vZone # Wininfo(aDL,_Winparent);
  vBT   # WinSearch(vZone, 'bt.Zone'+vZone->wpName);
  if (vZone=0) or (vBT=0) then RETURN false;

  vTree # cnvia(vZone->wpCustom);
  if (vTree=0) then RETURN false;

  // ggf. Event updaten...
  if (ReadEvent(GetEventIDFromItem(aItem))) then begin
    if (aMan) then begin
      // Ist "Event"?
      if (TeM.E.Aktion='980') then begin
        v980 # RecBufCreate(980);
        v980->TeM.Nummer # TeM.E.Aktionsnr;
        RecRead(v980, 1, 0);
        // TELEFONAT???
        if (Lib_Termine:GetBasisTyp(v980->TeM.Typ)='TEL') or (Lib_Termine:GetBasisTyp(v980->TeM.Typ)='4') then begin
          // auf weitere Anker prüfen... hier: PROJEKT
          FOR Erx # RecLink(981,v980,1,_RecFirst)
          LOOP Erx # RecLink(981,v980,1,_RecNext)
          WHILE (Erx<=_rLocked) do begin
            if (TeM.A.Datei>=120) and (TeM.A.Datei<=129) then BREAK;
          END;
          if (Erx>=_rLocked) then begin
            if (Msg(99,'Aktivität damit auch löschen?',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes) then begin
              RecBufCopy(v980,980);
              Tem_Data:delete();
              RecbufDestroy(v980);
              RETURN true;
            end;
          end;
        end;
        RecbufDestroy(v980);
      end;
    end;

    Erx # RekDelete( 989, 0, 'MAN' );
    if (Erx>_rLocked) then RETURN false;
  end;

  aDL->WinLstDatLineRemove(aRow);

  CteDelete(vTree, aItem);              // Item löschen

  if (aItem->spID=cTypEventNew) then begin
    vBT->wpID # vBT->wpID - 1;          // NEU Zähler mindern
    Header.Update(vBT);
    Zone.Update('',vZone);
    Spalte.Resize(Wininfo(vZone,_winparent));
  end


  RETURN true;
end;


//========================================================================
//========================================================================
sub Remove989(
  a989  : int) : alpha;
local begin
  Erx       : int;
  vName     : alpha;
  vZone     : int;
  vTree     : int;
  vDL       : int;
  vItem     : int;
  vRow      : int;
  vMax      : int;
  vID       : int;
  vSpalte   : int;
end;
begin
  vName # ZoneNameZu989(a989);
  if (vName='') then RETURN 'no Name';

  // PROBLEM: bei EVENT ist der eigentliche Datensatz 980 schon weg!!!
  // also in ALLEN Zonen danach suchen...
  if (vName='EVENT') then begin
    FOR vSpalte # WinInfo(cMDI, _winfirst)
    LOOP vSpalte # WinInfo(vSpalte, _winNext)
    WHILE (vSpalte<>0) do begin

      FOR vZone # WinInfo(vSpalte, _winfirst)
      LOOP vZone # WinInfo(vZone, _winNext)
      WHILE (vZone<>0) do begin

        vDL # Winsearch(vZone, 'dl.Zone'+vZone->wpName);
        if (vDL=0) then CYCLE;

        vTree # cnvia(vZone->wpCustom);
        if (vTree=0) then CYCLE;

        vItem # FindItemFrom989InTree(a989, vTree);
        // FOUND!!!
        if (vItem<>0) then BREAK;
      END;
      if (vItem<>0) then BREAK;
    END;

    // EVENT ist nirgends auffindbar? -> dann einfach Datensatz löschen
    if (vItem=0) then begin
      RecBufCopy(a989,989);
      if (RecRead(989,1,0)<=_rLocked) then
        Erx # RekDelete(989, 0, 'MAN' );
      if (Erx>_rLocked) then RETURN '989 nicht löschbar';
      RETURN '';
    end;

    vName # vZone->wpName;
  end;

  // Gruppe suchen
  if (vZone=0) then begin
    vZone # Winsearch(cMDI, vName);
    if (vZone=0) then RETURN 'no Zone';
  end;

  // DL Suchen
  if (vDL=0) then begin
    vDL # Winsearch(vZone, 'dl.Zone'+vName);
    if (vDL=0) then RETURN 'no DL';
  end;

  if (vTree=0) then begin
    vTree # cnvia(vZone->wpCustom);
    if (vTree=0) then RETURN 'no tree';
    end;

  if (vItem=0) then begin
    vItem # FindItemFrom989InTree(a989, vTree);
    if (vItem=0) then RETURN 'no item';
  end;


  vMax # vDL->WinLstDatLineInfo(_WinLstDatInfoCount);
  FOR vRow # 1
  LOOP inc(vRow)
  WHILE (vRow<=vMax); do begin
    vDL->WinLstCellGet(vID,1,vRow);
    if (vID=vItem) then begin
      DeleteItemFromDL(vItem, vDL, vRow, false);
      BREAK;
    end;
  END;

  RETURN '';
end;


//========================================================================
//========================================================================
sub Jump(aItem : int);
local begin
  Erx     : int;
  vA      : alpha;
  vRecID  : int;
  vTyp    : alpha;
end;
begin

  if (aItem=0) then RETURN;
  if (HdlInfo(aItem,_HdlExists)=0) then RETURN;

//debugx(aItem->spname);
  vRecID # cnvia(Str_Token(aItem->spName, cSep, 2));
  if (vRecId=0) then RETURN;

//debugx('read 989...');
  Erx # RecRead(989, 0, _recId, vRecID);
  if (Erx>_rLocked) then RETURN;
//debugx('found...'+tem.e.aktion+'    nr:'+aint(tem.e.aktionsnr));

  // Aktivität?
  if (Tem.E.Aktion='980') then begin
    Tem_main:start(0, TeM.E.Aktionsnr, y);
    RETURN;
  end;

  // Projekt User
  if (StrCut(Tem.E.Aktion,1,7)='122>800')  then begin
    Prj_P_Main:Start(0, cnvia(Str_Token(TeM.E.Aktion,'/',2)), cnvia(Str_Token(TeM.E.Aktion,'/',3)), cnvia(Str_Token(TeM.E.Aktion,'/',4)), y);
    RETURN;
  end;


  // Datensatz-Wiedervorlage
  vA # Str_Token(Tem.E.Aktion, '/', 1);
  if (vA='100') then begin
    Adr_main:start(cnvia(Str_Token(Tem.E.Aktion, '|', 2)));
    RETURN;
  end;


  if (vA='122') then begin
    Prj_P_Main:Start(0, cnvia(Str_Token(TeM.E.Aktion,'/',2)), cnvia(Str_Token(TeM.E.Aktion,'/',3)), cnvia(Str_Token(TeM.E.Aktion,'/',4)), y);
    RETURN;
  end;

  if (vA='401') then begin
    Auf_P_Main:Start(0, cnvia(Str_Token(TeM.E.Aktion,'/',2)), cnvia(Str_Token(TeM.E.Aktion,'/',3)), y);
    RETURN;
  end;

end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================

//========================================================================
//========================================================================
sub EvtTimer (
  aEvt      : event;
  aTimerId  : int; ) : logic
local begin
  Erx     : int;
  vI,vJ   : int;
  xvBuf800 : handle;
  vErx    : int;
  vPrio   : int;
  v989    : handle;
  vNeue   : int;
  vDel    : int;
  vUpdates  : int;
  vItem   : int;
  vFocus  : int;
  vHdl    : int;
  vErr    : alpha;
  vToDel  : logic;
end;
begin
//gMDIMenu->wpcaption # gMdi->wpname;//w_name;
// WUSCH
/***
//  if (gBlueMode=false) then
//    lib_debug:StartBluemode();

  if (GV.int.10>2) then begin
  //  MDI_Cockpit:AddTAPIToZoneList(vHdl, ' Anruf verpasst', 'hund katze maus 2089347 blabla 2304892f xxxx haus dach tür fenster');
  //  MDI_Cockpit:ReBuildZones(gMDINotifier, vHdl);
    vHdl # cnvif(random()*10.0);
    MDI_Cockpit2:AddTapi(cnvai(vHdl), today, now);
//    Lib_Sound:Play( 'notice.wav' );
    gv.int.10 # 0;
  end;
  inc(gv.int.10);
***/

  if ( gFrmMain = 0 or gMDINotifier = 0 ) then
    RETURN false;

  /* Hinweiston bei neuen Nachrichten */
  GV.Sys.Username   # gUsername;
  try begin
    ErrTryCatch(_ErrNoFile, true);
    vI # RecLinkInfo( 989, 999, 6, _recCount );
  end;
  if (Errget()<>_ErrOK) then begin
    ErrSet(_ErrOK);
    RETURN false;
  end;

  // NEUE?
  v989 # recBufCreate(989);
  FOR vErx # RecLink(v989, 999, 7, _recFirst)
  LOOP vErx # RecLink(v989, 999, 7, _recFirst)
  WHILE (vErx<=_rLocked) and (v989->TeM.E.NotifiedYN=false) do begin
    if (v989->"TeM.E.Priorität">vPrio) then vPrio # v989->"TeM.E.Priorität";
    vErx # RecRead(v989,1,_recLock);
    v989->TeM.E.NotifiedYN # y;
    vErx # Recreplace(v989,_recUnlock);

    //   22.11.2017 AH: ggf. UPDATE
    vToDel # (v989->TeM.E.ErgebnisText='OK');// or (v989->TeM.E.ErgebnisText='');

    if (vToDel) then begin
      vJ # 0;
      REPEAT
        Erx # RekDelete(v989);                       // Satz löschen
        if (Erx<>_rOK) then begin
          Winsleep(50);
        end;
        inc(vJ);
      UNTIL (Erx=_rOK) or (vJ>10);
    end;

    if (RefreshItem989(v989, vToDel)='') then begin
      inc(vUpdates);
    end
    else begin
      if (vToDel) then CYCLE;
      inc(vNeue);
      Add989(v989);
    end;
  END;


  // zu Löschen?
  FOR vErx # RecLink(v989, 999, 8, _recFirst)
  LOOP vErx # RecLink(v989, 999, 8, _recFirst)
  WHILE (vErx<=_rLocked) and (v989->"TeM.E.LöschenYN") do begin
    vErr # Remove989(v989);
    if (vErr<>'') then begin
debugx('COCKPIT FAIL : '+vErr);
BREAK;
    end;
    inc(vDel);
  END;
  RecBufDestroy(v989);


  if ( gNotifierCounter != -1 ) then begin
    if (vNeue>0) or (vUpdates>0) then begin
      if (vPrio=999) then begin
      end
      else if (vPrio>0) then
        Lib_Sound:Play('Hupe LKW.wav' )
      else if (vPrio=0) then
        Lib_Sound:Play('notice.wav' );
    end;
    if (vDel>0) then
      Lib_Sound:Play('remove.wav' )

    if (vNeue<>0) or (vDel<>0) then
      Spalte.DrawAll();
  end;

  gNotifierCounter # vI;

  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtMenuInitPopup(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüeintrag
) : logic;
local begin
  vDesign : logic;
  vMenu   : handle;
  vItem   : handle;
  vObj    : int;
end;
begin
//  vDesign # (cMDI->wpCustom='Design');
vDesign # (cMDI->wpStatusItemPos = 1);


  // Kontext - Menü
  if (aMenuItem <> 0) then RETURN true;

  // Ermitteln des Kontextmenüs des Frame-Objektes.
  vMenu # aEvt:Obj->WinInfo(_WinContextMenu);
  if (vMenu = 0) then RETURN true;

  // ersten Eintrag löschen, wenn kein Titel angegeben ist
  vItem # vMenu->WinInfo(_WinFirst);
  if (vItem > 0 and vItem->wpCaption = '') then vItem->WinMenuItemRemove(FALSE);

  if (vDesign) then begin
    vObj # aEvt:Obj;
    if (vObj<>0) then begin
      if (StrCut(vObj->wpName,1,7)='bt.Zone') then begin
        vItem # vMenu->WinMenuItemAdd('Ktx.Push.Prev', 'eine Spalte nach links');
        vItem # vMenu->WinMenuItemAdd('Ktx.Push.Next', 'eine Spalte nach rechts');
      end;
    end;
    vItem # vMenu->WinMenuItemAdd('Ktx.Design.Stop', Translate('Designer beenden'));
  end
  else begin
    vItem # vMenu->WinMenuItemAdd('Ktx.Design.Start', Translate('Designer starten'));
  end;

end;


//========================================================================
//========================================================================
sub EvtMenuCommand(
  aEvt                  : event;        // Ereignis
  aMenuItem             : handle;       // Auslösender Menüpunkt / Toolbar-Button
) : logic;
begin

  if (aMenuItem->wpname='Ktx.Push.Prev') then
    Obj.Move(Wininfo(aEvt:Obj,_WinParent), -1);

  if (aMenuItem->wpname='Ktx.Push.Next') then
    Obj.Move(Wininfo(aEvt:Obj,_WinParent), 1);

  if (aMenuItem->wpname='Ktx.Design.Start') then
    Design.Start();

  if (aMenuItem->wpname='Ktx.Design.Stop') then
    Design.Stop();

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtChangedDesign(
  aEvt                  : event;        // Ereignis
  aAction               : int;          // Aktion
) : logic;
begin
  aEvt:Obj->wpAlignWidth # aEvt:Obj->wpAreaRight - aEvt:Obj->wpAreaLeft;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtPosChanged(
  aEvt                  : event;        // Ereignis
  aRect                 : rect;         // Größe des Fensters
  aClientSize           : point;        // Größe des Client-Bereichs
  aFlags                : int;          // Aktion
) : logic;
local begin
  vIch    : int;
  vL,vR   : int;
  vI      : int;
  vHdl    : int;
  vDesign : logic;
end;
begin

  // Fenster verändert??? -------------------------------------------------
  if (WinInfo(aEvt:Obj, _Wintype)=_WinTypeMdiFrame) then begin
//    vHdl # Winsearch(aEvt:Obj, 'Spalte'+aint(cMaxSpalte));
//    vHdl->wparearight   # aEvt:Obj->wpAreaRight;
//    vHdl->wpareaBottom  # aEvt:Obj->wpAreaBottom;
    Spalte.ResizeAll();
    RETURN true;
  end;


  // Spalten verändert im Desgin ?? ---------------------------------------
//  vDesign # (cMDI->wpCustom='Design');
vDesign # (cMDI->wpStatusItemPos = 1);

  if (vDesign=false) then RETURN true;

  vIch  # cnvia(aEvt:obj->wpname);
  vL    # aEvt:Obj->wpAreaLeft;
  vR    # aEvt:Obj->wpAreaRight;

  // Linke Spalten nachführen...
  if (vIch>1) then begin
    vHdl # Winsearch(cMDI, 'Spalte'+aint(vIch-1));
    if (vHdl<>0) then begin
      vHdl->wpAreaRight # aEvt:obj->wpAreaLeft - 2;
    end;
  end;

  // Rechte Spalten nachführen...
  if (vIch<cMaxSpalte) then begin
    vHdl # Winsearch(cMDI, 'Spalte'+aint(vIch+1));
    if (vHdl<>0) then begin
      vHdl->wpAreaLeft # aEvt:obj->wpAreaRight + 2;
    end;
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vZone   : int;
  vA      : alpha;
  vDL     : int;
end;
begin
//  if (cMDI->wpCustom='Design') then RETURN true;
if (cMDI->wpStatusItemPos = 1) then RETURN true;


  vZone # Wininfo(aEvt:Obj,_winparent);

  vA # GetSetting('Cockpit.Zone.'+vZone->wpname+'.Open');
  if (vA='N') then vA # 'Y'
  else vA # 'N';
  SetSetting('Cockpit.Zone.'+vZone->wpName+'.Open', vA);

OFF(__PROCFUNC__);
  Zone.Update('',vZone);
  Spalte.Resize(Wininfo(vZone,_winparent));
ON(__PROCFUNC__);

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtLstDataInit(
  aEvt                 : event;    // Ereignis
  aID                  : int;      // Datensatz ID oder Zeilennummer
) : logic;
local begin
  vItem : int;
  vHdl  : int;
  vCol  : int;
  vCol2 : int;
end;
begin
/***
  WinLstCellGet(aEvt:obj, vItem, 1, aID);
  if (vItem<>0) then begin
    if (ReadEvent(GetEventIDFromItem(vItem))) then begin
      if ("TeM.E.Priorität">0) then
        vCol2 # _WincolLightYellow;
    end;
  end;
***/

  if (RunAFX('Mdi.Cockpit.EvtLstDataInit',  aEvt:obj->wpName + '|' +  Aint(aID)) < 0) then
    RETURN true;


  if ((aID % 2)>0) then begin
    vCol  # _WinColWhite;
  end
  else begin
    vCol  # RGB(230,230,230);
  end;

  FOR vHdl # aEvt:Obj->WinInfo(_WinFirst);
  LOOP vHdl # vHdl->WinInfo(_WinNext);
  WHILE (vHdl<>0) do begin
    if (vCol2<>0) and (vHdl->wpname='clm3') then begin
      vHdl->wpClmColBkg         # vCol2;
      CYCLE;
    end;
    vHdl->wpClmColBkg         # vCol;
  END;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
local begin
  vCol        : int;
  vSortOrder  : alpha;
  vI          : int;
  vHdlClm     : int;
  vItem       : int;
  vZone       : int;
end;
begin

  if (RunAFX('Mdi.Cockpit.EvtMouseItem',  aEvt:obj->wpName+'|'+aint(aButton)+'|'+aint(aHit)+'|'+aInt(aItem)+'|'+aint(aID)) < 0) then
    RETURN true;

  if ( aItem = 0 ) then RETURN false;


  if ( aItem->wpname = 'clm1' ) and ( aHit = _winHitLstHeader ) then RETURN false;

  // Klick auf Spaltenheader? => UMSORTIEREN
  if (StrCut(aEvt:obj->wpName,1,7)='dl.Zone') and( aButton = _winMouseLeft ) and ( aHit = _winHitLstHeader ) then begin

OFF(__PROCFUNC__);

    // Spalte kennzeichnen und Richtung ermitteln
    vSortOrder  # '';
    if (aItem->wpClmSortImage = _WinClmSortImageDown) then begin
      vSortOrder # 'DESC';
      aItem->wpClmSortImage # _WinClmSortImageUp;
    end
    else begin
      vSortOrder # 'ASC';
      aItem->wpClmSortImage # _WinClmSortImageDown;
    end;

    // Headerbilder angleichen
    FOR vI # 3
    LOOP inc(vI)
    WHILE (vI < 5) DO BEGIN
      // Vorgefertigte Spalte in DL suchen
      vHdlClm # aEvt:Obj->Winsearch('clm'+cnvai(vI));
      if (vHdlClm = 0) then BREAK;
      if (aItem=vHdlClm) then
        CYCLE;
      vHdlClm->wpClmSortImage # _WinClmSortImageKey;
      winUpdate(vHdlClm);
    END;


    // Sortierung umsetzen
    vZone # Wininfo(aEvt:Obj,_winparent);
    Zone.Draw('', vZone);

ON(__PROCFUNC__);

    RETURN true;
  end;


  // AB HIER NUR DOPPELKLICK
  if ( aButton & _winMouseLeft = 0 ) or ( aButton & _winMouseDouble = 0 ) then
    RETURN true;

//Mdi_TxtEditor_Main:Start('!TODO', y, 'Extra Text', '');
//RETURN true;

  // DELETE?
  if ( aItem->wpName = 'clm1' ) then begin
    WinLstCellGet(aEvt:obj, vItem, 1, aID);
//debug('delete '+aint(vITem)+' '+aEvT:obj->wpname+' '+aint(aID));
    DeleteItemFromDL(vItem, aEvt:obj, aID, true);
//    RebuildZones(gMDINotifier, gZonelist);
    RETURN true;
  end;  // delete



  // STAR?
  if ( aItem->wpName = 'clm2' ) then begin
    WinLstCellGet(aEvt:obj, vItem, 1, aID);
    if (vItem=0) then RETURN true;
    ToggleItemStar(aEvt:obj, aID, vItem);
  end;


  // LINK?
  if ( aItem->wpName = 'clm3' ) then begin
    WinLstCellGet(aEvt:obj, vItem, 1, aID);
    if (vItem<>0) then Jump(vItem);
  end;

end;


//========================================================================
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vSpalte : int;
  vHdl    : int;
end;
begin

  cMDI # aEvt:obj;

  gMenuName # 'Main';

  cMdi->wpcustom # cnvai(Varinfo(WindowBonus));
  w_name # cMdi->wpName;

//  Lib_Guicom:Recallwindow(aEvt:obj);  28.10.2021 AH : macht schon Lib_notifier

  Init(aEvt:obj);

  BuildLists();

  Spalte.Drawall();

  Spalte.UpdateAll(aEvt:Obj);

  vHdl # Winsearch(aEvt:obj,'Timer');
  vHdl->wpcustom # aint(SysTimerCreate(1000,-1, aEvt:obj));

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin
  if (VarInfo(Windowbonus)<>0) then
    if (Mode<>'CLOSE') then RETURN false;

  // Event wird ZWEIMAL aufgerufen - also nur EINMAL aufräumen!
  vHdl # Winsearch(aEvt:obj,'Timer');
  if (vHdl->wpcustom='') then RETURN true;

  SysTimerClose(cnvia(vHdl->wpcustom));
  vHdl->wpCustom # '';

  SaveAll();

  Lib_GuiCom:RememberWindow(aEvt:Obj);

  CloseAll();

  RETURN(true);
end;



//========================================================================
//  EvtDropEnter
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vFormat : int;
  vTxt    : int;
end;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
	RETURN (true);
end;


//=========================================================================
//=========================================================================
sub EvtDrop(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aDataPlace           : handle;   // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
) : logic;
local begin
  vPref     : alpha;
  vA        : alpha;
  vDatei    : int;
  vID       : int;
  vDetail   : logic;
  vZonelist : int;
  vBuf      : int;
  vKey      : alpha(200);
end;
begin

  if (aEffect | _WinDropEffectCopy=0) or (aEffect | _WinDropEffectMove=0) then RETURN false;


  if (aDataObject->wpFormatEnum(_WinDropDataText)) and
    (aDataObject->wpcustom<>'') then begin

    vA      # StrFmt(aDataObject->wpName,30,_strend);
    vDatei  # Cnvia(StrCut(vA,1,3));
    vID     # Cnvia(StrCut(vA,5,15));
    Lib_Workbench:CreateName(vDatei, var vPref, var vA);

    if (Dlg_Notifier:Dlg_Drop(var vA, var vDetail)=false) then RETURN false;

    if (vDetail) then begin

      RecBufClear(980);
      Tem2_Main:RecInit();
      TeM.Typ   # 'AFG';

      // Add User to TEM
// 14.03.2016 AH      TeM_A_Data:Anker(800,'MAN');  laut VBS

      // Datensatz verankern
      RecRead(vDatei, 0, _recId, vID);
      TeM_A_Data:Anker(800,'AUTO');

      TeM.Start.Von.Datum   # today;
      TeM.Start.Von.Zeit    # now;
      TeM.Ende.Von.Datum    # 0.0.0;
      TeM.Ende.Von.Zeit     # 24:0;
      TeM.SichtbarPlanerYN  # y;
      TeM.Bezeichnung       # vA;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TeM.Maske','');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_ModeNew;
      Lib_GuiCom:RunChildWindow(gMDI,gFrmMain, _WinAddHidden);
      gMdi->WinUpdate(_WinUpdOn);
    end
    else begin
      vKey # Lib_Rec:MakeKey(vDatei,y,'/');
      Lib_Notifier:NewEvent( gUserName, aint(vDatei)+'/'+vKey, vA);
    end;

  end;

  RETURN(true);
end;


//========================================================================
//  EvtDragInit
//              Sourceobjekt auswählen
//========================================================================
sub EvtDragInit(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int;      // Rückgabe der erlaubten Effekte (_WinDropEffectNone = Cancel)
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  Erx     : int;
  vItem   : int;
  vA      : alpha;
  vRecId  : int;
end;
begin

  if (aEvt:obj->wpcurrentint=0) then RETURN false;
  aEvt:obj->WinLstCellGet(vItem,1,_WinLstDatLineCurrent);

//    WinLstCellGet(aEvt:obj, vItem, 1, aID);
  vRecID # cnvia(Str_Token(vItem->spName, cSep, 2));
  if (vRecId=0) then RETURN false;

//debugx('read 989...');
  Erx # RecRead(989, 0, _recId, vRecID);
  if (Erx>_rLocked) then RETURN false;
//debugx('found...'+tem.e.aktion+'    nr:'+aint(tem.e.aktionsnr));

  // Aktivität?
  if (Tem.E.Aktion='980') then begin
    Tem.Nummer  # Tem.E.Aktionsnr;
    if (RecRead(980,1,0) = _rOK) AND
      (TeM.Start.Von.Datum <> 0.0.0) AND (TeM.Start.Von.Zeit <> 0:0:0) AND
      (TeM.Ende.Von.Datum <> 0.0.0) AND (TeM.Ende.Von.Zeit <> 0:0:0) then begin

      aDataObject->wpName # 'EVENT|'+aint(Tem.E.Aktionsnr);
      aDataObject->wpFormatEnum(_WinDropDataText) # true;
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN true;
    end;
    RETURN false;
  end;


  // Projekt User
  if (StrCut(Tem.E.Aktion,1,7)='122>800')  then begin
    RETURN false;
  end;

  // Datensatz-Wiedervorlage
  vA # Str_Token(Tem.E.Aktion, '/', 1);
  if (StrLen(vA)=3) and (StrCut(vA,1,3)>='001') and (StrCut(vA,1,3)<='999') then begin
    aDataObject->wpName # vA+cSep+aint(Tem.E.Aktionsnr);
    aDataObject->wpFormatEnum(_WinDropDataText) # true;
    aEffect # _WinDropEffectCopy | _WinDropEffectMove;
    RETURN true;
  end;

  RETURN false;
end;


//========================================================================
//  EvtDragTerm
//              D&D beenden
//========================================================================
sub EvtDragTerm(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt;Durchgeführte Dragoperation (_WinDropEffectNome = abgebrochen)
	aEffect      : int
) : logic
local begin
  vFormat : int;
  vTxtBuf : int;
  vHdl    : int;
end;
begin
  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    // Format-Objekt ermitteln.
    vFormat # aDataObject->wpData(_WinDropDataText);
    // Format schliessen.
    aDataObject->wpFormatEnum(_WinDropDataText) # false;
  end;
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================