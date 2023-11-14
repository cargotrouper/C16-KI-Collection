@A+
//===== Business-Control =================================================
//
//  Prozedur    Bdfr_V_Mark_Sel
//                    OHNE E_R_G
//  Info        Selektierte Materialien ausgeben
//
//  04.07.2011  TM  Erstellung der Prozedur (Kopie aus Mat_Mark_Sel)
//  28.06.2012  TM  Erstellung der Prozedur (Kopie aus Adr_V_Mark_Sel)
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
MAIN (
  opt aSelName    : alpha);
local begin
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
end;
begin

  RecBufClear(998);
  Sel.Adr.von.LiNr  # 0;
  Sel.Art.von.ArtNr # '';
  "Sel.von.Datum"   # 0.0.0;
  "Sel.bis.Datum"   # today;

  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Bedarf',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
    end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Bedarf',here+':AusSel');
  end;

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


  Erx # RecRead(100,1,0);
  if ("Sel.Adr.von.LiNr"    != 0) then
  Lib_Sel:QVonBisI(var vQ, '"Bdf.Lieferant.Wunsch"',         "Sel.Adr.von.LiNr", "Sel.Adr.von.LiNr");

  if ("Sel.Art.von.ArtNr"    != '') then
  Lib_Sel:QAlpha(var vQ, '"Bdf.Artikelnr"', '=', "Sel.Art.von.ArtNr");

  if ("Sel.von.Datum"    != 0.0.0) then
    Lib_Sel:QVonBisD(var vQ, '"Bdf.TerminWunsch"',   "Sel.von.Datum",    "Sel.von.Datum");

  vSel # SelCreate(540, 1);

  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n,vPostFix);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
    end
  else begin  // Markierung...

    Erx # RecRead(540,vSel,_recFirst);
    WHILE (Erx <= _rLocked) DO BEGIN
      Lib_Mark:MarkAdd(540,y,y);
      Erx # RecRead(540,vSel,_recNext);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(540,vSelName);   // Selektion zu Debugzwecken nicht löschen
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