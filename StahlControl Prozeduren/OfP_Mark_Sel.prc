@A+
//===== Business-Control =================================================
//
//  Prozedur    OfP_Mark_Sel
//                    OHNE E_R_G
//  Info        Selektierte Offene Posten ausgeben
//
//
//  19.01.2009  AI  Erstellung der Prozedur
//  12.01.2022  ST  Ablagenselektion hinzugefügt 2343/2
//  02.02.2022  AH  ERX, auch als Filter
//
//  Subprozeduren
//    SUB AusSel();
//    SUB AusSelAblage();
//
//========================================================================
@I:Def_Global

//========================================================================
//  Main
//
//========================================================================
MAIN(
  opt aAblage   : logic;
  opt aSelName  : alpha)
local begin
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
  
  vAuswahProz : alpha;
end;
begin
  RecBufClear(998);
  Sel.Adr.von.KdNr          # 0;
  Sel.von.Datum             # 0.0.0;
  Sel.bis.Datum             # today;
  Sel.von.Datum2            # 0.0.0;
  Sel.bis.Datum2            # today;

  vAuswahProz # Here+':AusSel';
  if (aAblage) then
    vAuswahProz  # vAuswahProz  + 'Ablage';

  if (aSelName<>'') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Ofp',here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
  end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.OfP',vAuswahProz);
  end;
  
  
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  sub _FldNameAbl(aName : alpha; aFile : int) : alpha
//
//========================================================================
sub _FldNameAbl(aName : alpha; aFile : int) : alpha
local begin
  vRet  : alpha;
end
begin
  vRet # '"' + aName + '"';
  if (aFile = 470) then
    vRet # '"' + StrCut(aName,1,3)+'~'+StrAdj(StrCut(aName,5,99),_StrAll)+'"';
    
  RETURN vRet;
end;


//========================================================================
//  StartSel
//
//========================================================================
sub StartSel(
  aFilter   : logic;
  aAblage   : logic;
  );
local begin
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ        : alpha(4000);
  tErg      : int;
  vDate     : date;
  vFile     : int;
  vPostFix  : alpha;
end;
begin
  vList # gZllist;
  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);

  vFile # 460;
  if (aAblage) then
    vFile # 470;

  // Selektionsquery
  vQ # '';
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, _FldNameAbl('OfP.Rechnungsdatum',vFile) , Sel.von.Datum, Sel.bis.Datum );
  if ( Sel.von.Datum2 != 0.0.0) or ( Sel.bis.Datum2 != 31.12.2020) then
    Lib_Sel:QVonBisD( var vQ, _FldNameAbl('OfP.Zieldatum',vFile)  , Sel.von.Datum2, Sel.bis.Datum2 );
  if ( Sel.Adr.von.Kdnr != 0 ) then
    Lib_Sel:QInt( var vQ, _FldNameAbl('OfP.Kundennummer',vFile), '=', Sel.Adr.von.Kdnr );
  if ( Sel.Adr.von.Vertret != 0 ) then
    Lib_Sel:QInt( var vQ, _FldNameAbl('OfP.Vertreter',vFile)  , '=', Sel.Adr.von.Vertret );
  if ( Sel.Adr.von.Verband != 0 ) then
    Lib_Sel:Qint( var vQ, _FldNameAbl('OfP.Verband',vFile)  , '=', Sel.Adr.von.Verband );
  if (  "Sel.Fin.GelöschteYN" ) and (  "Sel.Fin.!GelöschteYN"  ) then
    vQ # vQ
  else if (  "Sel.Fin.GelöschteYN" ) and (  "Sel.Fin.!GelöschteYN" = n ) then
    Lib_Sel:QAlpha( var vQ, _FldNameAbl('OfP.Löschmarker',vFile)  , '=', '*' )
  else if (  "Sel.Fin.GelöschteYN" = n ) and (  "Sel.Fin.!GelöschteYN" ) then
    Lib_Sel:QAlpha( var vQ, _FldNameAbl('OfP.Löschmarker',vFile)  , '=', '' );

  // Nur fällige (Wiedervorlagedatum überschritten oder gleich heute)
  if (Sel.Fin.nurMarkeYN) then begin
    Lib_Sel:QAlpha( var vQ, _FldNameAbl('OfP.Löschmarker',vFile) , '=', '' );
    Lib_Sel:QDate( var vQ, _FldNameAbl('OfP.Wiedervorlage',vFile) , '<=', SysDate());
  end;

  vSel # SelCreate( vFile, 1 );
  tErg # vSel->SelDefQuery( '', vQ );

  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n,vPostFix);


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
  end
  else begin  // Markierung...
    vFlag # _RecFirst;
    WHILE (RecRead(vFile,vSel,vFlag) <= _rLocked ) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      Lib_Mark:MarkAdd(vFile,y,y);
    END;
    // Selektion löschen
    SelClose(vSel);
    SelDelete(vFile,vSelName);
    vSel # 0;
  end;

  vList->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel(
  opt aFilter   : logic;   //Bugfix MR 2022-08-30 Kriegt nicht immer oder generell keien Funktionsargumente übergeben
  opt aAblage   : logic;
  );
begin
  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(gMDI,true);

  if (gSelected=0) then RETURN;
  gSelected # 0;

  StartSel(aFilter, aAblage);
end;


//========================================================================
//  AusSelAblage
//========================================================================
sub AusSelAblage();
begin
  AusSel(false, true);
end;


//========================================================================
//  AusSelFilter
//
//========================================================================
sub AusSelFilter();
begin
  AusSel(true, false);
end;


//========================================================================