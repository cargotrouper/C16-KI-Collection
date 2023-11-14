@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Ein_500003
//                    OHNE E_R_G
//  Info        Bestelldruck Ausgang
//
//
//  06.09.2004  AI  Erstellung der Prozedur
//  30.07.2008  DS  QUERY
//  01.10.2013  AH  Bugfix
//  16.10.2013  AH  Anfragen
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List
declare StartList(aSort : int; aSortName : alpha);

local begin
  gGesamt : float;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Auf.von.Nummer # 0;           Sel.Auf.bis.Nummer # 99999999;
  Sel.Auf.von.Datum # 0.0.0;        Sel.Auf.bis.Datum # today;
  Sel.Auf.von.WTermin # 0.0.0;      Sel.Auf.bis.WTermin # DateMake(31,12,DateYear(today));
  Sel.Auf.von.DruckDat # 1.1.1900;  Sel.Auf.bis.DruckDat # today;
  Sel.Auf.von.AufArt # 0;           Sel.Auf.bis.AufArt # 9999;
  Sel.Auf.von.Wgr # 0;              Sel.Auf.bis.Wgr # 9999;
  Sel.Auf.von.Projekt # 0;          Sel.Auf.bis.Projekt # 99999999;
  Sel.Auf.von.KostenSt # 0;         Sel.Auf.bis.KostenSt # 99999999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.500003','L_Ein_500003:AusSel');
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
  StartList(vSort,vSortname);  // Liste generieren

end;


//========================================================================
//  Print
//
//========================================================================
Sub Print(aName : alpha);
begin

  case aName of

    'Artikel' : begin
      StartLine();
      Endline();
      StartLine();
      Write(1, Ein.P.LieferantenSw                                                   ,n , 0);
      Write(2, ZahlI(Ein.P.Nummer) +' / ' + ZahlI(Ein.P.Position)                    ,n , 0);
      Write(3, Ein.P.Sachnummer                                                      ,n , 0);
      Write(4, Ein.P.Artikelnr                                                       ,n , 0);
      Write(5, Art.Stichwort                                                         ,n , 0);
      Write(6, ZahlF(Ein.P.Menge,2)                                             ,y , _LF_NUM, 2.0);
      Write(7, Ein.P.MEH                                                             ,n , 0);
      Write(8, ZahlF(Ein.P.Einzelpreis,2)                                      ,y , _LF_NUM);
      Write(9, ZahlI(Ein.P.PEH)+' '+Ein.P.MEH.Preis                            ,n , 0);
      Write(10, ZahlF(gGesamt,2)                                               ,y , _LF_NUM);
      EndLine();
      StartLine();
      Write(4, Art.Bezeichnung1                                                      ,n , 0);
      EndLine();
      AddSum(1, gGesamt);
      AddSum(2, gGesamt);
    end;

    'Zwischensum' : begin
      startline(_LF_Overline);
      Write(10, ZahlF(GetSum(1),2)     ,y , _LF_Num);
      endline();
      ResetSum(1);
    end;
    'endsum' : begin
      startline(_LF_Overline);
      Write(10, ZahlF(GetSum(2),2)     ,y , _LF_Num);
      endline();
      ResetSum(1);
    end;

  end; // CASE
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();
  StartLine();
  EndLine();
  print('Seitenkopf');
  StartLine();
  EndLine();


  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 30.0;  // Lf
  List_Spacing[ 3]  # List_Spacing[ 2] + 20.0;  // Bestnr
  List_Spacing[ 4]  # List_Spacing[ 3] + 30.0;  // Sachnr
  List_Spacing[ 5]  # List_Spacing[ 4] + 30.0;  // Artnr
  List_Spacing[ 6]  # List_Spacing[ 5] + 40.0;  // Bez.
  List_Spacing[ 7]  # List_Spacing[ 6] + 25.0;  // Menge
  List_Spacing[ 8]  # List_Spacing[ 7] + 10.0;  // MEH
  List_Spacing[ 9]  # List_Spacing[ 8] + 25.0;  // Preis
  List_Spacing[10]  # List_Spacing[ 9] + 25.0;  // PEH
  List_Spacing[11]  # List_Spacing[10] + 25.0;  // Gesamt

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Lieferant'                               ,n , 0);
  Write(2, 'Bestellnr.'                             ,n , 0);
  Write(3, 'Sachnr.'                               ,n , 0);
  Write(4, 'Artikelnr.'                       ,n , 0);
  Write(5, 'Bezeichnung'                           ,n , 0);
  Write(6, 'Bestell Menge'                       ,y , 0);
  Write(7, 'MEH'                                  ,n , 0, 2.0);
  Write(8, 'Preis'                             ,y , 0);
  Write(9, 'pro PEH'                       ,n , 0, 2.0);
  Write(10,'Gesamt EK'                          ,y , 0);
  EndLine();

  startline();
  endline();

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  StartList
//
//========================================================================
sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx         : int;
  vName       : alpha;
  vSel        : int;
  vSelName    : alpha;

  vMenge      : float;
  vGew        : float;
  vSummeRoh   : float;
  vSummeRest  : float;

  vKey        : int;
  vOK         : logic;
  vX          : float;
  vA          : alpha;

  vLf         : int;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  tErx        : int;
end;
begin

  // Selektionsquery für 501
  vQ # '';
  Lib_Sel:QInt(var vQ, 'Ein.P.Nummer', '<', 1000000000);
  if (Sel.Auf.von.Nummer != 0) or (Sel.Auf.bis.Nummer != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Ein.P.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer);
  if (Sel.Auf.Kundennr != 0) then
    Lib_Sel:QInt(var vQ, 'Ein.P.Lieferantennr', '=', Sel.Auf.Kundennr);
  if (Sel.Auf.Artikelnr != '') then
   Lib_Sel:QAlpha(var vQ, 'Ein.P.Artikelnr', '=', Sel.Auf.Artikelnr);
  Lib_Sel:QFloat(var vQ, 'Ein.P.FM.Rest', '>', 0.0);
  if (Sel.Auf.von.WTermin != 0.0.0) or (Sel.Auf.bis.WTermin != DateMake(31,12,DateYear(today))) then
    Lib_Sel:QVonBisD(var vQ, 'Ein.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin);
  if (Sel.Auf.von.Wgr != 0) or (Sel.Auf.bis.Wgr != 9999) then
    Lib_Sel:QVonBisI(var vQ, 'Ein.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr);
  if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
    Lib_Sel:QVonBisI(var vQ, 'Ein.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);
  if (Sel.Auf.von.Datum != 0.0.0) or (Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ, 'Ein.P.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum);
  if (Sel.Auf.von.Projekt != 0) or (Sel.Auf.bis.Projekt != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Ein.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt);
  if (Sel.Auf.von.Kostenst != 0) or (Sel.Auf.bis.Kostenst != 99999999)  then
    Lib_Sel:QVonBisI(var vQ, 'Ein.P.Kostenstelle', Sel.Auf.von.Kostenst, Sel.Auf.bis.Kostenst);
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Kopf) > 0 ';
  // Selektionsquery für 500
  vQ2 # '';
  Lib_Sel:QAlpha(var vQ2, '"Ein.Vorgangstyp"', '=', c_Bestellung);
  if (Sel.Auf.Sachbearbeit != '') then
   Lib_Sel:QAlpha(var vQ2, 'Ein.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit);
  if (vQ2 != '') then vQ2 # vQ2 + ' AND ';
  vQ2 # vQ2 + ' LinkCount(Aktion) > 0 ';
  // Selektionsquery für 504
  vQ3 # '';
  Lib_Sel:QAlpha(var vQ3, 'Ein.A.Aktionstyp', '=', 'DRUCK');
  if (Sel.Auf.von.DruckDat != 01.01.1900) or (Sel.Auf.bis.DruckDat != today) then begin
    Lib_Sel:QVonBisD(var vQ3, 'Ein.A.Aktionsdatum', Sel.Auf.von.DruckDat, Sel.Auf.bis.DruckDat);
  end;

  // Selektion starten...
  vSel # SelCreate(501, 2);
  vSel->SelAddLink('', 500, 501, 3, 'Kopf');
  vSel->SelAddLink('Kopf', 504, 500, 15, 'Aktion');
  vSel->SelDefQuery('', vQ);
  vSel->SelDefQuery('Kopf', vQ2);
  tErx # vSel->SelDefQuery('Aktion', vQ3);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);


//SelCopy(501,vSelname,'aaa');

  RecRead(501,vSel,_RecFirst);
  RecLink(100,501,4,_recFirst);                   // Lieferant holen
  ListInit(y); // KEIN Landscape

  vLf # -1;
  FOR Erx # RecRead(501,vSel,_recfirst)
  LOOP Erx # RecRead(501,vSel,_recnext)
  WHILE (Erx<=_rLocked) do begin

//    if (vLf=-1) then
//      print('avg');
    if (vLf<>Ein.P.Lieferantennr) and (vLf<>-1) then begin
      print('Zwischensum');
      ResetSum(1);
//      print('avg');
    end;
    vLf # Ein.P.Lieferantennr;

    RecLink(250,501,2,_recFirst);               // Artikel holen
//    Ggsesamt1 # Ein.P.Menge * Ein.P.Einzelpreis / CnvFI(Ein.P.PEH);
    gGesamt # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Gewicht, Ein.P.MEH.Wunsch, Ein.P.MEH.Preis) * Ein.P.Einzelpreis / CnvFI(Ein.P.PEH);


    print('Artikel');
  END;
  Print('endsum');

  ListTerm();

  // Selektion löschen
  SelClose(vSel);
  SelDelete(501,vSelName);
  vSel # 0;

end;

//========================================================================