@A+
//===== Business-Control =================================================
//
//  Prozedur    L_BAG_702003
//                    OHNE E_R_G
//  Info        Aufruf Coilbereitstellungsliste
//
//
//  16.05.2008  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//    SUB Print(aName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
declare Print(aName : alpha);

define begin
  cFile : 702
  cSel  : 'LST.702003'
end;


//========================================================================
//  Main
//
//========================================================================
MAIN
begin

  RecBufClear(998);

  // Morgigen Tag vorbelegen
  Sel.Von.Datum # DateMake(DateDay(SysDate())+ 1,
                           DateMonth(SysDate()),
                           DateYear(SysDate())   );

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'SEL.LST.702003',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2  : int;
  vSort : int;
  vSortName : alpha;
end;
begin
  gSelected # 0;

  // Formular zur Ausgabe Aufrufen
  Lib_Dokumente:Printform(700,'Coilbereitstellung',false);

end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;

//========================================================================
//  Print
//
//========================================================================
Sub Print(aName : alpha)
begin

end;


//========================================================================
//  StartList
//
//========================================================================
sub StartList(aSort : int; aSortName : alpha);
begin
end;

//========================================================================