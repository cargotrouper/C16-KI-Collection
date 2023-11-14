@A+
//===== Business-Control =================================================
//
//  Prozedur    ERe_Mark_Sel
//                    OHNE E_R_G
//  Info        Selektierte Eingangsrechnung ausgeben
//
//
//  08.02.2012  AI  Erstellung der Prozedur
//  21.12.2021  ST  Projektnummer hinzugefügt  Projekt 2151/25/1
//  10.05.2022  AH  ERX
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
  Sel.Adr.von.LiNr          # 0;
  Sel.von.Datum             # 0.0.0;
  Sel.bis.Datum             # today;
  Sel.von.Datum2            # 0.0.0;
  Sel.bis.Datum2            # today;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.ERe',Here+':AusSel');
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
  tErx      : int;
  vDate     : date;
end;
begin
  vList # gZllist;
  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);

  if (gSelected=0) then RETURN;
  gSelected # 0;


  // Selektionsquery
  vQ # '';
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'ERe.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  if ( Sel.von.Datum2 != 0.0.0) or ( Sel.bis.Datum2 != 31.12.2020) then
    Lib_Sel:QVonBisD( var vQ, 'ERe.Zieldatum', Sel.von.Datum2, Sel.bis.Datum2 );
  if ( Sel.Adr.von.Linr != 0 ) then
    Lib_Sel:QInt( var vQ, 'ERe.Lieferant', '=', Sel.Adr.von.Linr );
  if ( Sel.Prj.Projektnr != 0 ) then
    Lib_Sel:QInt( var vQ, 'ERe.Projektnr', '=', Sel.Prj.Projektnr );
    

  // Nur fällige (Wiedervorlagedatum überschritten oder gleich heute)
  if (Sel.Fin.nurMarkeYN) then begin
    Lib_Sel:QAlpha( var vQ, '"ERe.Löschmarker"', '=', '' );
    Lib_Sel:QDate( var vQ, '"ERe.Wiedervorlage"', '<=', SysDate());
  end;

  vSel # SelCreate( 560, 1 );
  tErx # vSel->SelDefQuery( '', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFlag # _RecFirst;
  WHILE (RecRead(560,vSel,vFlag) <= _rLocked ) DO BEGIN

    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Lib_Mark:MarkAdd(560,y,y);
  END;

  // Selektion löschen
  SelClose(vSel);
  SelDelete(560,vSelName);
  vSel # 0;

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

end;

//========================================================================