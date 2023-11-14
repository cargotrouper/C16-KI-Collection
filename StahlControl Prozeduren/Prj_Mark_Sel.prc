@A+
//===== Business-Control =================================================
//
//  Prozedur    Prj_Mark_Sel
//                          OHNE E_R_G
//  Info        Selektierte Projekte ausgeben
//
//
//  04.12.2007  AI  Erstellung der Prozedur
//  08.08.2008  DS  QUERY
//
//  Subprozeduren
//    SUB AusSel();
//
//========================================================================
@I:Def_Global

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
end;
begin
  RecBufClear(998);
  Sel.Auf.bis.Projekt   # 99999999;
  "Sel.Mat.EigenYN"     # n;
  "Sel.Mat.!EigenYN"    # y;
  "Sel.Mat.BestelltYN"  # y;
  "Sel.Mat.!BestelltYN" # n;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Projekte',here+':AusSel');
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ        : alpha(4000);
  tErg      : int;
end;
begin
  vList # gZllist;
  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);

  if (gSelected=0) then RETURN;
  gSelected # 0;

  // Selektion aufbauen
  vQ  # '';
  if ( "Sel.Auf.von.Projekt" != 0 ) or ( "Sel.Auf.bis.Projekt" != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Prj.Nummer"', "Sel.Auf.von.Projekt", "Sel.Auf.bis.Projekt" );
  if ( "Sel.Adr.von.KdNr"    != 0 ) then
    Lib_Sel:QInt( var vQ, '"Prj.Adressnummer"', '=', "Sel.Adr.von.KdNr" );

  if ( "Sel.Mat.EigenYN" ) and ( !"Sel.Mat.!EigenYN" ) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' "Prj.Wartungsinterval" > '''' ';
  end
  else if ( !"Sel.Mat.EigenYN" ) and ( "Sel.Mat.!EigenYN" ) then begin
    if (vQ != '') then vQ # vQ + ' AND '
    vQ # vQ + ' "Prj.Wartungsinterval" = '''' ';
  end;

  if ( "Sel.Mat.BestelltYN" ) and ( !"Sel.Mat.!BestelltYN" ) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' "Prj.Löschmarker" = '''' ';
  end
  else if ( !"Sel.Mat.BestelltYN" ) and ( "Sel.Mat.!BestelltYN" ) then begin
    if (vQ != '') then vQ # vQ + ' AND '
    vQ # vQ + ' "Prj.Löschmarker" > '''' ';
  end;


  vSel # SelCreate( 120, 1 );
  tErg # vSel->SelDefQuery( '', vQ );
  if (tErg != 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  gFrmMain->winfocusset();          // HAUPTFENSTER baut Liste auf!!!

  vFlag # _RecFirst;                // Projekte loopen...
  WHILE (RecRead(120,vSel,vFlag) <= _rLocked ) DO BEGIN

    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Lib_Mark:MarkAdd(120,y,y);      // Markierung setzen
  END;

  // Selektion löschen
  SelClose(vSel);
  SelDelete(120,vSelName);
  vSel # 0;

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

end;

//========================================================================