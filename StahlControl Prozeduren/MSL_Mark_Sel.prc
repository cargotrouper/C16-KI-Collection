@A+
//===== Business-Control =================================================
//
//  Prozedur    MSL_Mark_Sel
//                  OHNE E_R_G
//  Info        Selektierte Materialien ausgeben
//
//
//  24.08.2012  MS  Erstellung der Prozedur
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB DefaultSelection()
//    SUB EvtClicked(aEvt : event;): logic;
//    SUB AusSel();
//
//========================================================================
@I:Def_Global

define begin
  cSelMSLSturkturNrVon  : GV.Alpha.10
  cSelMSLStrukturNrBis  : GV.Alpha.11
  cSelMSLBezeichnung    : GV.Alpha.12

end;

//========================================================================
//  DefaultSelection
//
//========================================================================
sub DefaultSelection()
begin
  RecBufClear(998);
  RecBufClear(999);

  cSelMSLStrukturNrBis  # 'zzz';
end;

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
  DefaultSelection();

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.MSL', here+':AusSel');

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  StartSel
//
//========================================================================
sub StartSel();
local begin
  Erx       : int;
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ220     : alpha(4000);
  tErx      : int;
  vPostFix  : alpha;
end;
begin

  vList # gZLList;

  vQ220 # '';
  if(cSelMSLBezeichnung <> '') then
    Lib_Sel:QEnthaeltA(var vQ220, '"MSL.Bezeichnung"', cSelMSLBezeichnung);

  if(cSelMSLSturkturNrVon <> '') and (cSelMSLStrukturNrBis <> 'zzz') then
    Lib_Sel:QVonBisA(var vQ220, '"MSL.Strukturnr"', cSelMSLSturkturNrVon, cSelMSLStrukturNrBis);


  vSel # SelCreate(220, 1);
  Erx # vSel->SelDefQuery('', vQ220);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0, false, vPostFix);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  FOR Erx # RecRead(220, vSel, _recFirst);
  LOOP Erx # RecRead(220, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    Lib_Mark:MarkAdd(220, true, true);
  END;

  SelClose(vSel); // Selektion löschen
  SelDelete(220,vSelName);   // Selektion zu Debugzwecken nicht löschen
  vSel # 0;

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  App_Main:refreshmode();
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
begin
  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);
  if (gSelected=0) then RETURN;
  gSelected # 0;

  StartSel();
end;




//========================================================================