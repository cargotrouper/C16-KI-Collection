@A+
//===== Business-Control =================================================
//
//  Prozedur    Adr_Mark_Sel
//                  OHNE E_R_G
//  Info
//
//
//  09.06.2005  AI  Erstellung der Prozedur
//  04.08.2008  PW  Selektionsquery
//  28.10.2011  MS  Obf hinzugefuegt
//  28.10.2013  AH  NEU: Filterfunktion
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//
//========================================================================
@I:def_global


//========================================================================
//  DefaultSelection
//
//========================================================================
sub DefaultSelection()
begin
  RecBufClear(998);
  Sel.Mat.ObfNr2        # 999;
  Sel.Art.Bis.Wgr       # 9999;
  Sel.Art.Bis.Artgr     # 9999;
  Sel.Art.Bis.ArtNr     # 'ZZZ';
  Sel.Art.Bis.Stichwor  # 'ZZZ';
  Sel.Art.Bis.Sachnr    # 'ZZZ';
end;


//========================================================================
//  MAIN
//
//========================================================================
MAIN(opt aSelName    : alpha);
local begin
  vHdl  : int;
end;
begin

  DefaultSelection();

  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Artikel',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
    end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Artikel','Art_Mark_Sel:AusSel');
  end;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  StartSel
//
//========================================================================
sub StartSel(opt aFilter   : logic);
local begin
  Erx         : int;
  vSel        : int;
  vSelName    : alpha;
  vVar        : int;
  vList       : int;
  vQ          : alpha(4000);
  vPostFix    : alpha;
end;
begin

  vList # gZLList;

  // ehemals Selektion 250 !Filter
  vQ # '';
  if (Sel.Mat.ObfNr != 0) or (Sel.Mat.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ, '"Art.Oberfläche"', Sel.Mat.ObfNr, Sel.Mat.ObfNr2);
  if ( Sel.Art.von.ArtNr != '' ) or ( Sel.Art.bis.ArtNr != 'ZZZ' ) then
    Lib_Sel:QVonBisA( var vQ, 'Art.Nummer', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr );
  if ( Sel.Art.von.Stichwor != '' ) or ( Sel.Art.bis.Stichwor != 'ZZZ' ) then
    Lib_Sel:QVonBisA( var vQ, 'Art.Stichwort', Sel.Art.von.Stichwor, Sel.Art.bis.Stichwor );
  if ( Sel.Art.von.SachNr != '' ) or ( Sel.Art.bis.SachNr != 'ZZZ' ) then
    Lib_Sel:QVonBisA( var vQ, 'Art.Sachnummer', Sel.Art.von.SachNr, Sel.Art.bis.SachNr );
  if ( Sel.Art.von.ArtGr != 0 ) or ( Sel.Art.bis.ArtGr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Art.Artikelgruppe', Sel.Art.von.ArtGr, Sel.Art.bis.ArtGr );
  if ( Sel.Art.von.WGr != 0 ) or ( Sel.Art.bis.WGr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Art.Warengruppe', Sel.Art.von.WGr, Sel.Art.bis.WGr );
  if ( Sel.Art.von.Typ != '' ) then
    Lib_Sel:QAlpha( var vQ, 'Art.Typ', '=', Sel.Art.von.Typ );

  vSel # SelCreate( 250, 1 );
  Erx # vSel->SelDefQuery( '', vQ );
  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun( var vSel, 0, n, vPostFix );

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
  end
  else begin  // Markierung...

    FOR Erx # RecRead(250,vSel,_recFirst)
    LOOP Erx # RecRead(250,vSel,_recNext)
    WHILE (Erx <= _rLocked ) DO BEGIN
      Lib_Mark:MarkAdd(250,y,y);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(250,vSelName);
    vSel # 0;
  end;

  gZLList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  App_Main:refreshmode();
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel(opt aFilter   : logic);
begin
//  Art_Main:ToggleDelFilter();

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