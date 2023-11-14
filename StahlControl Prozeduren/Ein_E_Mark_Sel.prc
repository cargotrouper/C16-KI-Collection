@A+
//===== Business-Control =================================================
//
//  Prozedur    Ein_E_Mark_Sel
//                            OHNE E_R_G
//  Info        Markierungsmaske für Ein.Eingänge
//
//
//  01.12.2016  AH  Erstellung der Prozedur
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB FISA() : logic;
//    sub StartSel(aFilter : logic);
//    sub AusSel(opt aFilter   : logic);
//    sub AusSelFilter();
//========================================================================
@I:Def_Global

//========================================================================
//  Main
//
//========================================================================
MAIN(
  opt aSelName  : alpha);
local begin
  vHdl  : int;
end;
begin

  RecBufClear(998);
  "Sel.Mat.bis.EDatum"    # today;

  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Ein.E',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
    end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Ein.E',here+':AusSel');
  end;
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  StartSel
//
//========================================================================
sub StartSel(
  aFilter : logic);
local begin
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ        : alpha(4000);
  tErx      : int;
  vPostFix  : alpha;
end;
begin
  vList # gZLList;

  // ehemals Selektion 100 !Filter
  vQ # '';
  Lib_Sel:QInt( var vQ, 'Ein.E.Nummer', '=', Ein.P.Nummer);
  Lib_Sel:QInt( var vQ, 'Ein.E.Position', '=', Ein.P.Position);
  Lib_Sel:qAlpha(var vQ, 'Ein.E.Löschmarker', '=', '');

  if (Sel.Mat.Lagerort<>0) then
    Lib_Sel:QInt( var vQ, 'Ein.E.Lageradresse', '=', Sel.Mat.LagerOrt);
  if (Sel.Mat.LagertExtern) then
    Lib_Sel:QInt(var vQ, 'Ein.E.Lageradresse', '<>', Set.eigeneAdressnr);
  if (Sel.Mat.LagerAnschri<>0) then
    Lib_Sel:QInt( var vQ, 'Ein.E.Lageranschrift', '=', Sel.Mat.LAgeranschri);
  Lib_Sel:QVonBisD(var vQ, 'Ein.E.Eingang_Datum', Sel.Mat.von.EDatum, Sel.Mat.bis.EDatum);
  if (Sel.Mat.Werksnummer<>'') then
    Lib_Sel:QAlpha( var vQ, 'Ein.E.Werksnummer', '=', Sel.Mat.Werksnummer);

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate( 506, 1 );
  tErx # vSel->SelDefQuery( '', vQ );
  if (tErx != 0) then Lib_Sel:QError(vSel);

  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n,vPostFix);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
  end
  else begin  // Markierung...

    Lib_Mark:Reset(506);

    vFlag # _RecFirst;
    WHILE (RecRead(506,vSel,vFlag) <= _rLocked ) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      Lib_Mark:MarkAdd(506,y,y);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(506,vSelName);
  end;

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  App_Main:refreshmode();
end;

//========================================================================
//  AusSel
//
//========================================================================
sub AusSel(opt aFilter   : logic);
begin

  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);

  if (gSelected=0) then RETURN;
  gSelected # 0;

  StartSel(aFilter);
end;


//========================================================================
//  AusSelFilter
//
//========================================================================
sub AusSelFilter();
begin
  AusSel(y);
end;


//========================================================================