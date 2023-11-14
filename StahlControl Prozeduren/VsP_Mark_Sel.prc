@A+
//===== Business-Control =================================================
//
//  Prozedur    VsP_Mark_Sel
//                    OHNE E_R_G
//  Info        Selektierte Adressen ausgeben
//
//
//  11.12.2012  AI  Erstellung der Prozedur
//  14.10.2021  MR  AFX "VsP.Mark.Sel.Default" eingebaut (2166/58/1)
//  12.11.2021  AH  ERX
//  31.01.2022  AH  auch für eine Aufpos. "Sel.Auf.von.Nummer"
//  11.02.2022  ST  Fix: Kundennummer korrigiert
//
//  Subprozeduren
//    sub DefaultSelection()
//    MAIN
//    sub StartSel(aFilter : logic);
//    sub AusSel(opt aFilter   : logic);
//    sub AusSelFilter();
//    SUB EvtClicked(aEvt : event;): logic;
//========================================================================
@I:Def_Global
@I:Def_Aktionen

//========================================================================
//  DefaultSelection
//
//========================================================================
sub DefaultSelection()
begin
  RecBufClear(998);
  Sel.VsP.BisTermin # 31.12.2099;
  
  RunAFX('VsP.Mark.Sel.Default','');
end;


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

  DefaultSelection();

  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.VsP',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
    end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.VsP',here+':AusSel');
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
  vQ,vQ1,vQ401  : alpha(4000);
  Erx       : int;
  vPostFix  : alpha;
end;
begin
  vList # gZLList;

  // ehemals Selektion 100 !Filter
  vQ # '';

  if ("Sel.VsP.VonTermin" != 0.0.0) then
    Lib_Sel:QDate(var vQ, '"VsP.Termin.MaxDat"', '<=', "Sel.VsP.VonTermin");
  if ("Sel.VsP.bisTermin" != 31.12.2099) then
    Lib_Sel:QDate(var vQ, '"VsP.Termin.MinDat"', '>=', "Sel.VsP.BisTermin");

  if ( Sel.VsP.VonAdresse != 0 ) then
    Lib_Sel:QInt( var vQ, 'Vsp.Start.Adresse', '=', Sel.Vsp.VonAdresse );
  if ( Sel.VsP.VonAnschrift != 0 ) then
    Lib_Sel:QInt( var vQ, 'Vsp.Start.Anschrift', '=', Sel.Vsp.VonAnschrift );
  if ( Sel.VsP.NachAdresse != 0 ) then
    Lib_Sel:QInt( var vQ, 'Vsp.Ziel.Adresse', '=', Sel.Vsp.NachAdresse );
  if ( Sel.VsP.NachAnschrif != 0 ) then
    Lib_Sel:QInt( var vQ, 'Vsp.Ziel.Anschrift', '=', Sel.Vsp.NachAnschrif );
   if( Sel.VsP.MitRest = true) then
    Lib_Sel:QFloat (var vQ, 'VsP.Menge.In.Rest', '>', 0.0);
  if (Sel.Auf.von.Nummer!=0) then
    Lib_Sel:QInt( var vQ, 'VsP.Auftragsnr', '=', Sel.Auf.von.Nummer);
  if (Sel.Auf.Kundennr != 0) then
    Lib_Sel:QInt( var vQ, 'VsP.AuftragsKundennr', '=', Sel.Auf.Kundennr);

  if (Sel.VsP.MitTheorie=false) then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    Lib_Sel:Qalpha(var vQ1, 'VsP.Artikelnr', '<>','');
    Lib_Sel:QInt(var vQ1, 'VsP.Materialnr', '<>',0, 'OR');
    vQ # vQ + '('+vQ1+')';
  end;

 
  // Selektion bauen, speichern und öffnen
  vSel # SelCreate( 655, 1 );
/** 31.01.2022 AH s.o.
  if (Sel.Auf.Kundennr != 0) then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'LinkCount(AufPos) > 0';
    Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr);
    vSel->SelAddLink('', 401, 655, 10, 'AufPos');
  end;
***/
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  if (vQ401<>'') then begin
    Erx # vSel->SelDefQuery('AufPos', vQ401);
    if (Erx <> 0) then Lib_Sel:QError(vSel);
  end;

  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n,vPostFix);


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
    end
  else begin  // Markierung...
    vFlag # _RecFirst;
    WHILE (RecRead(655,vSel,vFlag) <= _rLocked ) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      Lib_Mark:MarkAdd(655,y,y);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(655,vSelName);
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
  RETURN(true);
end;

//========================================================================