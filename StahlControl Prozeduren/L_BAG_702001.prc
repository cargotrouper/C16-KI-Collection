@A+
//===== Business-Control =================================================
//
//  Prozedur    L_BAG_702001
//                    OHNE E_R_G
//  Info        Gibt offene Aktionen aus
//
//
//  13.08.2004  NH  Erstellung der Prozedur
//  01.08.2008  DS  QUERY
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List
@I:Def_BAG

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//

//========================================================================
MAIN
begin
  RecBufClear(998);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'SEL.LST.702001',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2  : int;
  vSort : int;
  vSortName : alpha;
end;
begin

  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd('BA-Nummer');
  vHdl2->WinLstDatLineAdd('Endtermin');
  vHdl2->WinLstDatLineAdd('Kommission');
  vHdl2->WinLstDatLineAdd('Lieferant');
  vHdl2->wpcurrentint#1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
    if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;
  vSort # gSelected;
  gSelected # 0;
  StartList(vSort,vSortname);  // Liste generieren
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();   // Drucke grosse Überschrift

  if (aSeite=1) then begin
    StartLine();
    EndLine();
  end;
    StartLine();
    EndLine();
  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # 20.0;
  List_Spacing[ 3]  # 40.0;
  List_Spacing[ 4]  # 58.0;
  List_Spacing[ 5]  # 90.0;
  List_Spacing[ 6]  #120.0;
  List_Spacing[ 7]  #160.0;
  List_Spacing[ 7]  #180.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Nummer'                           ,y , 0, 2.0);
  Write(2, 'Endtermin'                           ,n , 0);
  Write(3, 'Position'                  ,y , 0, 2.0);
  Write(4, 'Aktion'                  ,n , 0);
  Write(5, 'Kommission'                  ,n , 0);
  Write(6, 'Zielort'                  ,n , 0);
  Write(7, 'Lieferant'                ,n , 0);
  EndLine();

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  StartList
//
//========================================================================
sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx         : int;
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;
  vOK         : logic;
  vTree       : int;
  vSortKey    : alpha;
  vQ702       : alpha(4000);
  vQ700       : alpha(4000);
  tErx        : int;
end;
begin

 // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery für 702
  vQ702 # '';
  Lib_Sel:QDate( var vQ702, 'BAG.P.Fertig.Dat', '=', 0.0.0 );
  if ( Sel.BAG.Aktion != '' ) then
    Lib_Sel:QAlpha( var vQ702, 'BAG.P.Aktion', '=', Sel.BAG.Aktion );
  if ( Sel.Adr.von.LiNr != 0 ) then
    Lib_Sel:QInt( var vQ702, 'BAG.P.ExterneLiefNr', '=', Sel.Adr.von.LiNr );
  if ( Sel.BAG.Res.Gruppe != 0 ) then
    Lib_Sel:QInt( var vQ702, 'BAG.P.Ressource.Grp', '=', Sel.BAG.Res.Gruppe );
  if ( Sel.BAG.Res.Nummer != 0 ) then
    Lib_Sel:QInt( var vQ702, 'BAG.P.Ressource', '=', Sel.BAG.Res.Nummer );

  Lib_Strings:Append(var vQ702, '(LinkCount(BAG) > 0)', ' AND ');

  vQ700 # '';
  Lib_Sel:QAlpha(var vQ700, '"BAG.Löschmarker"', '=', ''); // keine geloeschten BA´s

  // Selektion starten...
  vSel # SelCreate( 702, 1 );
  vSel -> SelAddLink('', 700, 702, 1, 'BAG');
  tErx # vSel->SelDefQuery('', vQ702);
  if(tErx <> 0) then
    Lib_Sel:QError(vSel);
  tErx # vSel->SelDefQuery('BAG', vQ700);
  if(tErx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 702, 'LST.702001',y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(702,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    if (aSort=1) then vSortKey # cnvAI(BAG.P.Nummer,_FmtNumLeadZero,0,8);
    if (aSort=2) then vSortKey # cnvAI(cnvID(BAG.P.Plan.EndDat),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    if (aSort=3) then vSortKey # BAG.P.Kommission;
    if (aSort=4) then vSortKey # cnvAI(BAG.P.ExterneLiefNr,_FmtNumLeadZero,0,8);
    Sort_ItemAdd(vTree,vSortKey,702,RecInfo(702,_RecId));
  END;
  SelClose(vSel);
  vSel # 0;
  SelDelete(702, vSelName);

    // Ausgabe ----------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y);              // starte Landscape

//  List_FontSize # 7;  FONTGRÖSSE ÄNDERN!

  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID); // Datensatz holen

    if(BAG.P.Aktion2 <> c_BAG_VSB) then begin
      StartLine();
      Write(1,  ZahlI(BAG.P.Nummer)                ,y , _LF_Int, 2.0);
      Write(2,  cnvAD(BAG.P.Plan.EndDat)                      ,n , 0);
      Write(3,  ZahlI(BAG.P.Position)              ,y , _LF_Int, 2.0);
      Write(4,  BAG.P.Aktion                                  ,n , 0);

      Write(5,  BAG.P.Kommission                              ,n , 0);
      Erx # RecLink(100, 702, 12, _recFirst);
      if((Erx > _rLocked) or (BAG.P.Zieladresse = 0)) then
        RecBufClear(100);
      Write(6, Adr.Stichwort                                  ,n , 0);
      Erx # RecLink(100, 702, 7, _recFirst);
      if((Erx > _rLocked) or (BAG.P.ExterneLiefNr = 0)) then
        RecBufClear(100);
      Write(7, Adr.Stichwort                                  ,n , 0);
      EndLine();
    end;
  END;
  // Löschen der Liste
  Sort_KillList(vTree);

  ListTerm();
end;

//========================================================================