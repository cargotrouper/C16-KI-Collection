@A+
//===== Business-Control =================================================
//
//  Prozedur    ZAu_Mark_Sel
//                  OHNE E_R_G
//  Info        Selektierte Zahlungsausgänge ausgeben
//
//
//  09.01.2013  ST  Erstellung der Prozedur
//
//  Subprozeduren
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
  Sel.Adr.von.LiNr # 0;
  Sel.von.Datum    # 0.0.0;   // Zahldatum
  Sel.bis.Datum    # today;   // Zahldatum


  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.ZAu',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
    end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.ZAu',here+':AusSel');
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
  tErg      : int;
  vPostFix  : alpha;
end;
begin
  vList # gZLList;

  vQ # '';

  if ( Sel.Adr.von.LiNr != 0 ) then
    Lib_Sel:QVonBisI( var vQ, 'ZAu.Lieferant', Sel.Adr.von.LiNr, Sel.Adr.von.LiNr );

  if ("Sel.von.Datum" != 0.0.0) or ("Sel.bis.Datum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"ZAu.Zahldatum"', "Sel.von.Datum", "Sel.bis.Datum");

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate( 565, 1 );
  tERG # vSel->SelDefQuery( '', vQ );
  if (tErg != 0) then Lib_Sel:QError(vSel);

  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n,vPostFix);


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
    end
  else begin  // Markierung...
    vFlag # _RecFirst;
    WHILE (RecRead(565,vSel,vFlag) <= _rLocked ) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      Lib_Mark:MarkAdd(565,y,y);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(565,vSelName);
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