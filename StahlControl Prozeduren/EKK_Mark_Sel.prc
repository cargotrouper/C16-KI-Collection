@A+
//===== Business-Control =================================================
//
//  Prozedur    EKK_Mark_Sel
//                OHNE E_R_G
//  Info        Selektierte EKK ausgeben
//
//
//  12.02.2009  AI  Erstellung der Prozedur
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
  Sel.Auf.von.Nummer        # 0;
  "Sel.Fin.GelöschteYN"     # n;
  "Sel.Fin.!GelöschteYN"    # y;
  if (w_parent<>0) then begin
    if (w_Parent->wpname=Lib_Guicom:GetAlternativeName('ERe.EKK.Verwaltung')) then begin
      Sel.Adr.von.LiNr      # ERe.Lieferant;
    end;
  enD;


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.EKK',Here+':AusSel');
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
  Erx       : int;
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
    Lib_Sel:QVonBisD( var vQ, 'EKK.Datum', Sel.von.Datum, Sel.bis.Datum );
  if ( Sel.Adr.von.LiNr != 0 ) then
    Lib_Sel:QInt( var vQ, 'EKK.Lieferant', '=', Sel.Adr.von.LiNr );

  if (Sel.Auf.von.Nummer<>0) then
    Lib_Sel:QInt( var vQ, 'EKK.ID1', '=', Sel.Auf.Von.Nummer);

  if (  "Sel.Fin.GelöschteYN" ) and (  "Sel.Fin.!GelöschteYN"  ) then
    vQ # vQ
  else if (  "Sel.Fin.GelöschteYN" ) and (  "Sel.Fin.!GelöschteYN" = n ) then
    Lib_Sel:QInt( var vQ, 'EKK.EingangsReNr', '>', 0 )
  else if (  "Sel.Fin.GelöschteYN" = n ) and (  "Sel.Fin.!GelöschteYN" ) then
    Lib_Sel:QINt( var vQ, 'EKK.EingangsReNr', '=', 0 );


  vSel # SelCreate( 555, 1 );
  tErx # vSel->SelDefQuery( '', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFlag # _RecFirst;
  WHILE (RecRead(555,vSel,vFlag) <= _rLocked ) DO BEGIN

    if (vFlag=_RecFirst) then vFlag # _RecNext;

    if (Sel.Fin.Wert<>0.0) then begin
      if (EKK.Datei<>506) then CYCLE;
      Erx # Ein_Data:Read(EKK.Id1,EKK.Id2,n);
      if (Erx<500) then CYCLE;
      if (Ein.P.Grundpreis<>Sel.Fin.Wert) then CYCLE;
    end;

    Lib_Mark:MarkAdd(555,y,y);
  END;

  // Selektion löschen
  SelClose(vSel);
  SelDelete(555,vSelName);
  vSel # 0;

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

end;

//========================================================================