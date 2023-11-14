@A+
//===== Business-Control =================================================
//
//  Prozedur    SWe_Mark_Sel
//                OHNE E_R_G
//  Info        Selektierte Sammelwareneingaenge ausgeben
//
//
//  12.08.2008  MS  Erstellung der Prozedur
//
//  Prozedur : SWe_Mark_Sel
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
  Sel.Adr.bis.KdNr # 9999999;
  Sel.Adr.bis.LiNr # 9999999;
  Sel.Adr.bis.LKZ  # 'zzz';

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.SWe','SWe_Mark_Sel:AusSel');
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
end;
begin
  vList # gZLList;

  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);

  if (gSelected=0) then RETURN;
  gSelected # 0;

  // Selektionsquery
  vQ # '';
  if (Sel.Adr.von.LiNr != 0 ) or (Sel.Adr.bis.LiNr != 9999999) then
    Lib_Sel:QVonBisI( var vQ, 'SWe.Lieferant', Sel.Adr.von.LiNr,Sel.Adr.bis.LiNr);
  if (Sel.Adr.von.KdNr != 0 ) or (Sel.Adr.bis.KdNr != 9999999) then
    Lib_Sel:QVonBisI( var vQ, 'SWe.Spediteur', Sel.Adr.von.KdNr,Sel.Adr.bis.KdNr);
    if ( Sel.Adr.von.LKZ != '' ) or (Sel.Adr.bis.LKZ != 'zzz') then
    Lib_Sel:QVonBisA( var vQ, 'SWe.Ursprungsland',Sel.Adr.von.LKZ , Sel.Adr.bis.LKZ);

  // Selektion öffnen
  vSel # SelCreate(620, 1);
  vSel->SelDefQuery( '', vQ);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  vFlag # _RecFirst;
  WHILE (RecRead(620,vSel,vFlag) <= _rLocked ) DO BEGIN

    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Lib_Mark:MarkAdd(620,y,y);
  END;

  // Selektion löschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(620, vSelName);

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

end;

//========================================================================