@A+
//===== Business-Control =================================================
//
//  Prozedur    Lfs_Mark_Sel
//                      OHNE E_R_G
//  Info        Selektierte LFS ausgeben
//
//
//  22.10.2014  AH  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB DefaultSelection()
//    SUB EvtClicked(aEvt : event;): logic;
//    SUB AusSel();
//
//========================================================================
@I:Def_Global

//========================================================================
//  DefaultSelection
//
//========================================================================
sub DefaultSelection()
begin
  RecBufClear(998);
  "Sel.von.Datum"         # 0.0.0;
  "Sel.Bis.Datum"         # today;
  Sel.Adr.von.KdNr        # 0;
  Sel.Auf.NormalYN        # true;
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked(aEvt : event;): logic;
begin
  case (aEvt:Obj -> wpName) of
    'bt.Reset' : begin
      DefaultSelection();
      gMdi -> WinUpdate();
    end;

  end; // case
  return(true);
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

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.LFS',here+':AusSel');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  StartSel
//
//========================================================================
sub StartSel(
  aFilter   : logic;
);
local begin
  Erx       : int;
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ        : alpha(4000);
  vQ1       : alpha(4000);
  vQ2       : alpha(4000);
  vQ3       : alpha(4000);
  tErx      : int;
  vPostFix  : alpha;
end;
begin

  vList # gZLList;

  // BESTAND-Selektion
  vQ  # '';
  vQ1 # '';
  vQ2 # '';
  vQ3 # '';

  if (Sel.Adr.von.KdNr<>0) then
    Lib_Sel:QInt(var vQ, '"Lfs.Kundennummer"',   '=', Sel.Adr.von.KdNr);

  Lib_Sel:QVonBisD(var vQ, '"Lfs.Lieferdatum"', "Sel.von.Datum", "Sel.bis.Datum");

  if (Sel.Auf.NormalYN) then
    Lib_Sel:QDate(var vQ, '"Lfs.Datum.Verbucht"', '=', 0.0.0);

  vSel # SelCreate(440, gKey);

  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n,vPostFix);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
    end
  else begin  // Markierung...

    Erx # RecRead(440,vSel,_recFirst);
    WHILE (Erx <= _rLocked) DO BEGIN
      Lib_Mark:MarkAdd(440,y,y);
      Erx # RecRead(440,vSel,_recNext);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(440,vSelName);   // Selektion zu Debugzwecken nicht löschen
    vSel # 0;
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
  Mat_Main:ToggleDelFilter();

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