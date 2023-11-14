@A+
//===== Business-Control =================================================
//
//  Prozedur    Adr_P_Mark_Sel
//                    OHNE E_R_G
//
//  Info        Selektierte Ansprechpartner ausgeben
//
//
//  12.04.2012  MS  Erstellung der Prozedur
//  01.02.2022  ST  E r g --> Erx
//
//Prozedur : Adr_Mark_Sel
//  Subprozeduren
//    SUB FISA() : logic;
//    sub StartSel(aFilter : logic);
//    sub AusSel(opt aFilter   : logic);
//    sub AusSelFilter();
//========================================================================
@I:Def_Global

define begin
  cSelAdresse  : GV.Int.10
  cSelFunktion : GV.Alpha.10
end;

//========================================================================
//  Main
//
//========================================================================
MAIN(opt aSelName  : alpha);
local begin
  vHdl  : int;
end;
begin

  RecBufClear(998);
  RecBufClear(999);
  Sel.Adr.bis.KdNr # 9999999;
  Sel.Adr.bis.LiNr # 9999999;
  Sel.Adr.bis.FibuKd # 'ZZZ';
  Sel.Adr.bis.FibuLi # 'ZZZ'
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
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Ansprechpartner', here+':AusSelFilter');
    vHdl # gMDi->winsearch('bt.OK');
    vHdl->wpcustom # aSelName;
    end
  else begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Ansprechpartner', here+':AusSel');
  end;

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
sub StartSel(aFilter : logic);
local begin
  vSel      : int;
  vFlag     : int;
  vSelName  : alpha;
  vList     : int;
  vQ100     : alpha(4000);
  vQ102     : alpha(4000);
  Erx      : int;
  vPostFix  : alpha;
end;
begin
  vList # gZLList;

  vQ102 # '';
  if(cSelFunktion <> '') then
    Lib_Sel:QenthaeltA( var vQ102, 'Adr.P.Funktion', cSelFunktion);


  vQ100 # '';
  if (cSelAdresse != 0) then
    Lib_Sel:QInt( var vQ100, 'Adr.Nummer', '=', cSelAdresse);
  if ( Sel.Adr.von.Sachbear != '' ) then
    vQ100 # '(Sel.Adr.von.Sachbear=Sel.Adr.von.Sachbear)';
  if ( Sel.Adr.von.KdNr != 0 ) or ( Sel.Adr.bis.KdNr != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ100, 'Adr.KundenNr', Sel.Adr.von.KdNr, Sel.Adr.bis.KdNr );
  if ( Sel.Adr.von.LiNr != 0 ) or ( Sel.Adr.bis.LiNr != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ100, 'Adr.LieferantenNr', Sel.Adr.von.LiNr, Sel.Adr.bis.LiNr );
  if ( Sel.Adr.von.FibuKd != '' ) or ( Sel.Adr.bis.FibuKd != 'ZZZ' ) then
//      Lib_Sel:QVonBisI( var vQ100, 'Adr.KundenBuchNr', Sel.Adr.von.FibuKd, Sel.Adr.bis.FibuKd );
      Lib_Sel:QVonBisA( var vQ100, 'Adr.KundenFibuNr', Sel.Adr.von.FibuKd, Sel.Adr.bis.FibuKd);

  if ( Sel.Adr.von.FibuLi != '' ) or ( Sel.Adr.bis.FibuLi != 'ZZZ' ) then
//    Lib_Sel:QVonBisI( var vQ100, 'Adr.LieferantBuchNr', Sel.Adr.von.FibuLi, Sel.Adr.bis.FibuLi );
    Lib_Sel:QVonBisA( var vQ100, 'Adr.LieferantFibuNr', Sel.Adr.von.FibuLi, Sel.Adr.bis.FibuLi);

  if ( Sel.Adr.von.Stichw != '' ) or ( Sel.Adr.bis.Stichw != 'zzz' ) then
    Lib_Sel:QVonBisA( var vQ100, 'Adr.Stichwort', Sel.Adr.von.Stichw, Sel.Adr.bis.Stichw );
//  if ( Sel.Adr.von.Sachbear != '') then
//    Lib_Sel:QAlpha( var vQ100, 'Adr.Sachbearbeiter', '=', Sel.Adr.von.Sachbear );
  if ( Sel.Adr.von.Vertret != 0) then
    Lib_Sel:QInt( var vQ100, 'Adr.Vertreter', '=', Sel.Adr.von.Vertret );
  if ( Sel.Adr.von.Gruppe != '' ) or ( Sel.Adr.bis.Gruppe != 'zzz' ) then
    Lib_Sel:QVonBisA( var vQ100, 'Adr.Gruppe', Sel.Adr.von.Gruppe, Sel.Adr.bis.Gruppe );
  if ( Sel.Adr.von.ABC != '' ) or ( Sel.Adr.bis.ABC != 'z' ) then
    Lib_Sel:QVonBisA( var vQ100, 'Adr.ABC', Sel.Adr.von.ABC, Sel.Adr.bis.ABC );
  if ( Sel.Adr.von.LKZ != '' ) or ( Sel.Adr.bis.LKZ != 'zzz' ) then
    Lib_Sel:QVonBisA( var vQ100, 'Adr.LKZ', Sel.Adr.von.LKZ, Sel.Adr.bis.LKZ );
  if ( Sel.Adr.von.PLZ != '' ) or ( Sel.Adr.bis.PLZ != 'zzz' ) then
    Lib_Sel:QVonBisA( var vQ100, 'Adr.PLZ', Sel.Adr.von.PLZ, Sel.Adr.bis.PLZ );
  if ( Sel.Adr.Briefgruppe != '') then
    Lib_Sel:QenthaeltA( var vQ100, 'Adr.Briefgruppe', Sel.Adr.Briefgruppe );

  // Kundensperre
  if (Sel.Adr.SperrKdYN = true) and ("Sel.Adr.!SperrKdYN" = false) then
    Lib_Sel:QLogic(var vQ100, 'Adr.SperrKundeYN', false)
  else if (Sel.Adr.SperrKdYN = false) and ("Sel.Adr.!SperrKdYN" = true) then
    Lib_Sel:QLogic(var vQ100, 'Adr.SperrKundeYN', true);

  // Lieferantensperre
  if (Sel.Adr.SperrLiYN = true) and ("Sel.Adr.!SperrLiYN" = false) then
    Lib_Sel:QLogic(var vQ100, 'Adr.SperrLieferantYN', false)
  else if (Sel.Adr.SperrLiYN = false) and ("Sel.Adr.!SperrLiYN" = true) then
    Lib_Sel:QLogic(var vQ100, 'Adr.SperrLieferantYN', true);

  if(vQ100 <> '') then
    Lib_Strings:Append(var vQ102, 'LinkCount(Adr) > 0', ' AND ');

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate(102, 1 );
  vSel->SelAddLink('', 100, 102, 1, 'Adr');

  Erx # vSel->SelDefQuery( '', vQ102)
  if (Erx != 0) then Lib_Sel:QError(vSel);

  if ( Sel.Adr.von.Sachbear != '' ) then
    Erx # vSel->SelDefQuery( 'Adr', vQ100, here+':FISA')
  else
    Erx # vSel->SelDefQuery( 'Adr', vQ100 );
  if (Erx != 0) then Lib_Sel:QError(vSel);


  if (aFilter) then vPostFix # '.SEL';
  vSelName # Lib_Sel:SaveRun(var vSel, 0, n, vPostFix);

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  if (aFilter) then begin
    gZLList->wpdbselection # vSel;
    w_Selname # vSelName;
    end
  else begin  // Markierung...
    vFlag # _RecFirst;
    WHILE (RecRead(102, vSel, vFlag) <= _rLocked ) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      Lib_Mark:MarkAdd(102, y, y);
    END;

    // Selektion löschen
    SelClose(vSel);
    SelDelete(102,vSelName);
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