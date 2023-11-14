@A+
//===== Business-Control =================================================
//
//  Prozedur    Adr_Mark_Sel
//                    OHNE E_R_G
//
//  Info        Selektierte Adressen ausgeben
//
//
//  05.05.2004  AI  Erstellung der Prozedur
//  14.08.2008  DS  QUERY
//  29.11.2010  HB  Filter des Sachbearbeiter angepasst
//  09.03.2011  HB  An die "Filter start" Funktion angepasst
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  01.02.2022  ST  E r g --> Erx
//  2023-03-28  AH  Sel.Adr.Ort
//
//Prozedur : Adr_Mark_Sel
//  Subprozeduren
//    SUB FISA() : logic;
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
  Sel.Adr.bis.KdNr # 9999999;
  Sel.Adr.bis.LiNr # 9999999;
  Sel.Adr.bis.FibuKd # 'ZZZ';
  Sel.Adr.bis.FibuLi # 'ZZZ';
  Sel.Adr.bis.Gruppe # 'zzz';
  Sel.Adr.bis.Stichw # 'zzz';
  Sel.Adr.bis.ABC    # 'z';
  Sel.Adr.bis.LKZ    # 'zzz';
  Sel.Adr.bis.PLZ    # 'zzz';
  "Sel.Adr.SperrKdYN"   # true;
  "Sel.Adr.!SperrKdYN"  # true;
  "Sel.Adr.SperrLiYN"   # true;
  "Sel.Adr.!SperrLiYN"  # true;

  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Adressen',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
    end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Adressen',here+':AusSel');
  end;
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  Sachbearbeiter
//
//========================================================================
SUB FISA() : logic;
begin
  if (StrFind(StrCnv(Adr.Sachbearbeiter, _StrUmlaut), StrCnv(Sel.Adr.von.Sachbear, _StrUmlaut), 1, _StrCaseIgnore) > 0) then
    RETURN true
  else
    RETURN false;
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
  Erx      : int;
  vPostFix  : alpha;
end;
begin
  vList # gZLList;

  // ehemals Selektion 100 !Filter
  vQ # '';
  if ( Sel.Adr.von.Sachbear != '' ) then
    vQ # '(Sel.Adr.von.Sachbear=Sel.Adr.von.Sachbear)';
  if ( Sel.Adr.von.KdNr != 0 ) or ( Sel.Adr.bis.KdNr != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Adr.KundenNr', Sel.Adr.von.KdNr, Sel.Adr.bis.KdNr );
  if ( Sel.Adr.von.LiNr != 0 ) or ( Sel.Adr.bis.LiNr != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Adr.LieferantenNr', Sel.Adr.von.LiNr, Sel.Adr.bis.LiNr );
  if ( Sel.Adr.von.FibuKd != '' ) or ( Sel.Adr.bis.FibuKd != 'ZZZ' ) then
//      Lib_Sel:QVonBisI( var vQ, 'Adr.KundenBuchNr', Sel.Adr.von.FibuKd, Sel.Adr.bis.FibuKd );
    Lib_Sel:QVonBisA( var vQ, 'Adr.KundenFibuNr', Sel.Adr.von.FibuKd, Sel.Adr.bis.FibuKd);

  if ( Sel.Adr.von.FibuLi != '' ) or ( Sel.Adr.bis.FibuLi != 'ZZZ' ) then
//    Lib_Sel:QVonBisI( var vQ, 'Adr.LieferantBuchNr', Sel.Adr.von.FibuLi, Sel.Adr.bis.FibuLi );
    Lib_Sel:QVonBisA( var vQ, 'Adr.LieferantFibuNr', Sel.Adr.von.FibuLi, Sel.Adr.bis.FibuLi);

  if ( Sel.Adr.von.Stichw != '' ) or ( Sel.Adr.bis.Stichw != 'zzz' ) then
    Lib_Sel:QVonBisA( var vQ, 'Adr.Stichwort', Sel.Adr.von.Stichw, Sel.Adr.bis.Stichw );
//  if ( Sel.Adr.von.Sachbear != '') then
//    Lib_Sel:QAlpha( var vQ, 'Adr.Sachbearbeiter', '=', Sel.Adr.von.Sachbear );
  if ( Sel.Adr.von.Vertret != 0) then
    Lib_Sel:QInt( var vQ, 'Adr.Vertreter', '=', Sel.Adr.von.Vertret );
  if ( Sel.Adr.von.Gruppe != '' ) or ( Sel.Adr.bis.Gruppe != 'zzz' ) then
    Lib_Sel:QVonBisA( var vQ, 'Adr.Gruppe', Sel.Adr.von.Gruppe, Sel.Adr.bis.Gruppe );
  if ( Sel.Adr.von.ABC != '' ) or ( Sel.Adr.bis.ABC != 'z' ) then
    Lib_Sel:QVonBisA( var vQ, 'Adr.ABC', Sel.Adr.von.ABC, Sel.Adr.bis.ABC );
  if ( Sel.Adr.von.LKZ != '' ) or ( Sel.Adr.bis.LKZ != 'zzz' ) then
    Lib_Sel:QVonBisA( var vQ, 'Adr.LKZ', Sel.Adr.von.LKZ, Sel.Adr.bis.LKZ );
  if ( Sel.Adr.von.PLZ != '' ) or ( Sel.Adr.bis.PLZ != 'zzz' ) then
    Lib_Sel:QVonBisA( var vQ, 'Adr.PLZ', Sel.Adr.von.PLZ, Sel.Adr.bis.PLZ );
  if ( Sel.Adr.Briefgruppe != '') then
    Lib_Sel:QenthaeltA( var vQ, 'Adr.Briefgruppe', Sel.Adr.Briefgruppe );
  if ( Sel.Adr.Ort != '') then    // 2023-03-28 AH
    Lib_Sel:QenthaeltA( var vQ, 'Adr.Ort', Sel.Adr.Ort );

  // Kundensperre
  if (Sel.Adr.SperrKdYN = true) and ("Sel.Adr.!SperrKdYN" = false) then
    Lib_Sel:QLogic(var vQ, 'Adr.SperrKundeYN', false)
  else if (Sel.Adr.SperrKdYN = false) and ("Sel.Adr.!SperrKdYN" = true) then
    Lib_Sel:QLogic(var vQ, 'Adr.SperrKundeYN', true);

  // Lieferantensperre
  if (Sel.Adr.SperrLiYN = true) and ("Sel.Adr.!SperrLiYN" = false) then
    Lib_Sel:QLogic(var vQ, 'Adr.SperrLieferantYN', false)
  else if (Sel.Adr.SperrLiYN = false) and ("Sel.Adr.!SperrLiYN" = true) then
    Lib_Sel:QLogic(var vQ, 'Adr.SperrLieferantYN', true);

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate( 100, 1 );
//  vSel->SelAddSortFld(1,17, _KeyFldAttrUpperCase);
  if ( Sel.Adr.von.Sachbear != '' ) then
    Erx # vSel->SelDefQuery( '', vQ, here+':FISA')
  else
    Erx # vSel->SelDefQuery( '', vQ );
  if (Erx != 0) then Lib_Sel:QError(vSel);

  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n,vPostFix);


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
    end
  else begin  // Markierung...
    vFlag # _RecFirst;
    WHILE (RecRead(100,vSel,vFlag) <= _rLocked ) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      Lib_Mark:MarkAdd(100,y,y);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(100,vSelName);
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