@A+
//===== Business-Control =================================================
//
//  Prozedur    Erl_Mark_Sel
//                    OHNE E_R_G
//  Info        Selektierte Adressen ausgeben
//
//
//  31.10.2008  AI  Erstellung der Prozedur
//  31.10.2008  AI  QUERY
//  21.12.2021  ST  Projektnummer hinzugefügt  Projekt 2151/25/1
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//========================================================================
@I:Def_Global

//========================================================================
//  Main
//
//========================================================================
MAIN
begin

  RecBufClear(998);
  Sel.Fin.bis.Rechnung    # 99999999;
  Sel.bis.Datum           # today;
  Sel.bis.Datum2          # today;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Erloese','Erl_Mark_Sel:AusSel');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  Erx       : int;
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ        : alpha(4000);
  tErx      : int;
end;
begin
  vList # gZLList;

  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);

  if (gSelected=0) then RETURN;
  gSelected # 0;

  if ( Sel.Fin.von.Rechnung != 0 ) or ( Sel.Fin.bis.Rechnung != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Erl.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'Erl.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  if ( Sel.von.Datum2 != 0.0.0) or ( Sel.bis.Datum2 != today) then
    Lib_Sel:QVonBisD( var vQ, 'Erl.FibuDatum', Sel.von.Datum2, Sel.bis.Datum2 );
  if ( Sel.Adr.von.Kdnr != 0 ) then
    Lib_Sel:QInt( var vQ, 'Erl.Kundennummer', '=', Sel.Adr.von.Kdnr );
  if ( Sel.Adr.von.Vertret != 0 ) then
    Lib_Sel:QInt( var vQ, 'Erl.Vertreter', '=', Sel.Adr.von.Vertret );
  if ( Sel.Adr.von.Verband != 0 ) then
    Lib_Sel:QInt( var vQ, 'Erl.Verband', '=', Sel.Adr.von.Verband );
  if ( Sel.Prj.Projektnr != 0 ) then
    Lib_Sel:QInt( var vQ, 'Erl.Projektnr', '=', Sel.Prj.Projektnr );

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate( 450, 1 );
  Erx # vSel->SelDefQuery( '', vQ );
  if (tErx != 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  vFlag # _RecFirst;
  WHILE (RecRead(450,vSel,vFlag) <= _rLocked ) DO BEGIN

    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Lib_Mark:MarkAdd(450,y,y);
  END;

  // Selektion löschen
  SelClose(vSel);
  SelDelete(450,vSelName);

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

end;

//========================================================================