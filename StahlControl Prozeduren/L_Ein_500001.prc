@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Ein_500001
//                    OHNE E_R_G
//  Info        Bestellrückstand ausgeben
//
//
//  06.09.2004  AI  Erstellung der Prozedur
//  29.07.2008  DS  QUERY
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

define begin
  cGesSumBestmng      : 1
  cGesSumRueckstand   : 2
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Auf.von.Nummer # 0;       Sel.Auf.bis.Nummer # 99999999;
  Sel.Auf.von.Datum # 0.0.0;    Sel.Auf.bis.Datum # today;
  Sel.Auf.von.WTermin # 0.0.0;  Sel.Auf.bis.WTermin # DateMake(31,12,DateYear(today));
  Sel.Auf.von.AufArt # 0;       Sel.Auf.bis.AufArt # 9999;
  Sel.Auf.von.Wgr # 0;          Sel.Auf.bis.Wgr # 9999;
  Sel.Auf.von.Projekt # 0;      Sel.Auf.bis.Projekt # 99999999;
  Sel.Auf.von.KostenSt # 0;     Sel.Auf.bis.KostenSt # 99999999;
  GV.Alpha.01 # '';
  GV.Alpha.02 # '';
  GV.Alpha.03 # '';

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.500001','L_Ein_500001:AusSel');
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
/***
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Auftragsnummer');
  vHdl2->WinLstDatLineAdd('Kundenstichwort');
  vHdl2->WinLstDatLineAdd('Wunschtermin');
  vHdl2->WinLstDatLineAdd('Zusagetermin');
  vHdl2->wpcurrentint#1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected=0) then RETURN;
  vSort # gSelected;
  gSelected # 0;
*/
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
     /* List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # 40.0;
      List_Spacing[ 3]  # 60.0;
      List_Spacing[ 4]  # 90.0;
      List_Spacing[ 5]  #125.0;
      List_Spacing[ 6]  #150.0;
      List_Spacing[ 7]  #160.0;
      List_Spacing[ 8]  #185.0;
      List_Spacing[ 9]  #210.0;
      List_Spacing[10]  #235.0; */



      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 35.0;
      List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 25.0;
      List_Spacing[ 5]  # List_Spacing[ 4] + 35.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 35.0;
      List_Spacing[ 7]  # List_Spacing[ 6] + 10.0;
      List_Spacing[ 8]  # List_Spacing[ 7] + 30.0;
      List_Spacing[ 9]  # List_Spacing[ 8] + 30.0;
      List_Spacing[ 10] # List_Spacing[ 9] + 30.0;


      StartLine();
      Endline();
      StartLine();
      Write(1, Adr.Anrede + ' ' + Adr.Name                            ,n , 0);
      Write(2, ZahlI(Ein.P.Nummer) + ' / ' + ZahlI(Ein.P.Position)    ,y , 0);
      Write(3, Ein.P.Artikelnr                                        ,y , 0, 3.0);
      Write(4, Ein.P.ArtikelSW                                        ,n , 0);
      Write(5, ZahlF(Ein.P.Menge,2)                                   ,y , _LF_NUM, 3.0);
      Write(6, Ein.P.MEH                                              ,n ,0);
      Write(7, ZahlF(Ein.P.FM.Rest,2)                                 ,y ,_LF_NUM, 3.0);
      if (Ein.P.Termin1Wunsch <> 0.0.0) then
        Write(8, DatS(Ein.P.Termin1Wunsch)                              ,n , _LF_Date);
      Write(9, '_____________________'                                ,n , 0);
      if(List_XML = true) then begin
        Write(10, Art.Bezeichnung1                                       ,n , 0);
      end;
      EndLine();
    end;

    'Summe' : begin
      StartLine();
      Endline();
      StartLine(_LF_Overline + _LF_Bold);
      Write(5, ZahlF(GetSum(cGesSumBestmng), 2)                                   ,y , _LF_NUM, 3.0);
      Write(6, Ein.P.MEH                                                          ,n ,0);
      Write(7, ZahlF(GetSum(cGesSumRueckstand), 2)                                 ,y ,_LF_NUM, 3.0);
      EndLine();
    end;

    'Listend' : begin
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  #210.0;
      Startline();
      endline();
      StartLine();
      Write(1, GV.Alpha.19                ,n , 0);
      EndLine();
      StartLine();
      Write(1, GV.Alpha.20                ,n , 0);
      EndLine();
      StartLine();
      EndLine();
    end;

  'Selektierung' : begin
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 20.0;
      List_Spacing[ 3]  # List_Spacing[ 2] + 3.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 9.0;
      List_Spacing[ 5]  # List_Spacing[ 4] + 20.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 10.0;
      List_Spacing[ 7]  # List_Spacing[ 6] + 25.0;
      List_Spacing[ 8]  # List_Spacing[ 7] + 20.0;
      List_Spacing[ 9]  # List_Spacing[ 8] + 3.0;
      List_Spacing[10]  # List_Spacing[ 9] + 9.0;
      List_Spacing[11]  # List_Spacing[10] + 20.0;
      List_Spacing[12]  # List_Spacing[11] + 10.0;
      List_Spacing[13]  # List_Spacing[12] + 25.0;
      List_Spacing[14]  # List_Spacing[13] + 20.0;
      List_Spacing[15]  # List_Spacing[14] + 3.0;
      List_Spacing[16]  # List_Spacing[15] + 9.0;
      List_Spacing[17]  # List_Spacing[16] + 20.0;
      List_Spacing[18]  # List_Spacing[17] + 10.0;
      List_Spacing[19]  # List_Spacing[18] + 25.0;

      StartLine();
      Write(1, 'BestellNr.'                                          ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(3, ' von: '                                              ,n , 0);
      Write(4, ZahlI(Sel.Auf.von.Nummer)                             ,y , _LF_INT, 3.0);
      Write(5, ' bis: '                                              ,n , 0);
      Write(6, ZahlI(Sel.Auf.bis.Nummer)                             ,y , _LF_INT, 3.0);
      Write(7, 'ErfassDat.'                                          ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(9, ' von: '                                              ,n , 0);
      if (Sel.Auf.von.Datum<>0.0.0) then
        Write(10, DatS(Sel.Auf.von.Datum)                            ,n , _LF_Date);
      Write(11, ' bis: '                                             ,n , 0);
      if (Sel.Auf.bis.Datum<>0.0.0) then
        Write(12, DatS(Sel.Auf.bis.Datum)                              ,n , _LF_Date, 3.0);
      Write(13, 'ProjektNr'                                          ,n , 0);
      Write(14, ': '                                                 ,n , 0);
      Write(15, ' von: '                                             ,n , 0);
      Write(16, ZahlI(Sel.Auf.von.Projekt)                           ,y , _LF_INT, 3.0);
      Write(17, ' bis: '                                             ,n , 0);
      Write(18, ZahlI(Sel.Auf.bis.Projekt)                           ,y , _LF_INT);
      Endline();

      StartLine();
      Write(1, 'Wunschter'                                           ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(3, ' von: '                                              ,n , 0);
      if (Sel.Auf.von.WTermin<>0.0.0) then
        Write(4, DatS(Sel.Auf.von.WTermin)                             ,n , _LF_Date);
      Write(5, ' bis: '                                              ,n , 0);
      if (Sel.Auf.von.WTermin<>0.0.0) then
        Write(6, DatS(Sel.Auf.bis.WTermin)                             ,y , _LF_Date, 3.0);
      Write(7, 'Vorgangsart'                                         ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(9, ' von: '                                              ,n , 0);
      Write(10, ZahlI(Sel.Auf.von.AufArt)                            ,y , _LF_INT, 3.0);
      Write(11, ' bis: '                                             ,n , 0);
      Write(12, ZahlI(Sel.Auf.bis.AufArt)                            ,y , _LF_INT, 3.0);
      Write(13, 'Wgr'                                                ,n , 0);
      Write(14, ': '                                                 ,n , 0);
      Write(15, ' von: '                                             ,n , 0);
      Write(16, ZahlI(Sel.Auf.von.Wgr)                               ,y , _LF_INT, 3.0);
      Write(17, ' bis: '                                             ,n , 0);
      Write(18, ZahlI(Sel.Auf.bis.Wgr)                               ,y , _LF_INT);
      Endline();

      StartLine();
      Write(1, 'Lieferant'                                           ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(4, ZahlI(Sel.Auf.Kundennr)                               ,y , _LF_INT, 3.0);
      Write(7, 'Sachbear'                                            ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(10, Sel.Auf.Sachbearbeit                                 ,n , 0);
      Write(13, 'ArtNr'                                              ,n , 0);
      Write(14, ': '                                                 ,n , 0);
      Write(16, Sel.Auf.Artikelnr                                    ,y , 0);
      Endline();

      StartLine();
      Write(1, 'Zusatzbem'                                           ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(4, GV.Alpha.01                                           ,n , 0);
      Endline();

      StartLine();
      Write(4, GV.Alpha.02                                           ,n , 0);
      Endline();

      StartLine();
      Write(4, GV.Alpha.03                                           ,n , 0);
      Endline();
    end; // Selektierung

  end; // CASE
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();
  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # 50.0;
  List_Spacing[ 3]  # 100.0;
  StartLine();
  EndLine();
  Print('Selektierung');
  StartLine();
  EndLine();


  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 35.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 25.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 35.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 35.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 10.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 30.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 30.0;
  List_Spacing[10]  # List_Spacing[ 9] + 30.0;
  List_Spacing[11]  # List_Spacing[10] + 30.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Lieferant'                             ,n , 0);
  Write(2, 'BestellNr'                             ,y , 0);
  Write(3, 'ArtNr'                                 ,y , 0, 3.0);
  Write(4, 'Stichwort'                             ,n , 0);
  Write(5, 'Bestell Menge'                         ,y , 0, 3.0);
  Write(6, 'MEH'                                   ,n , 0);
  Write(7, 'Rückstand'                             ,y , 0, 3.0);
  Write(8, 'Liefertermin'                         ,n , 0);
  Write(9, 'neuer Termin'                          ,n , 0);
  if(List_XML = true) then begin
    Write(10, 'Bezeichnung'                           ,n , 0);
  end;
  EndLine();
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
  vFlag       : int;        // Datensatzlese option
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
  vTxt        : int;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  tErx        : int;

  vSumMenge   : float;
  vSumRueck   : float;

end;
begin

  // Sortierung setzen
//  if (aSort=1) then vKey # 6; // Artikelnr

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
  if (Sel.Auf.von.Kostenst != 0) or (Sel.Auf.bis.Kostenst != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Ein.P.Kostenstelle', Sel.Auf.von.Kostenst, Sel.Auf.bis.Kostenst);
  Lib_Sel:QAlpha(var vQ, '"Ein.P.Löschmarker"', '!=', '*');
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Kopf) > 0 ';
  // Selektionsquery für 500
  vQ2 # '';
  Lib_Sel:QAlpha(var vQ2, 'Ein.Vorgangstyp', '=', c_Bestellung);
  if (Sel.Auf.Sachbearbeit != '') then
   Lib_Sel:QAlpha(var vQ2, 'Ein.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit);

  vQ3 # '';
    Lib_Sel:QInt(var vQ, 'Wgr.Dateinummer', '>=', 209);

  // Selektion starten...
  vSel # SelCreate(501, 2);
  vSel->SelAddLink('', 819, 501, 1, 'Wgr');
  vSel->SelAddLink('', 500, 501, 3, 'Kopf');


  tErx # vSel->SelDefQuery('', vQ);
  tErx # vSel->SelDefQuery('Wgr', vQ3);
  tErx # vSel->SelDefQuery('Kopf', vQ2);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  // Selektion öffnen
  //vSelName # Sel_Build(vSel, 501, 'LST.500001' ,y ,0);

  RecRead(501,vSel,_RecFirst);
  RecLink(100,501,4,_recFirst);                   // Lieferant holen


  ListInit(y); // KEIN Landscape

/*
  if (Sel.Adr.von.KdNr<>0) then begin
    Adr.Kundennr # Sel.Adr.von.KdNr;
    Erx # RecRead(100,2,0);
    if (Erx<_rNokey) then
      Callold('old_List','Lfprint',5,'nur Kunde : '+Adr.Stichwort);
  end;
  if (Sel.Art.von.Typ<>'') then begin
    Callold('old_List','Lfprint',5,'nur Artikeltyp : '+Sel.Art.von.Typ);
  end;
*/
  vLf # -1;
  vFlag # _RecFirst;

  vSumMenge # 0.0;
  vSumRueck # 0.0;

  WHILE (RecRead(501,vSel,vFlag) <= _rLocked) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    if (vLf<>Ein.P.Lieferantennr) then begin
      if (vLf<>-1) then Print('Listend');//Callold('old_List','Lfprint',7);
      RecLink(100,501,4,_recFirst);                  // Lieferant holen
      vLf # Ein.P.Lieferantennr;
    end;

    Erx # RecLink(250,501,2,_recFirst);                   // Artikel holen
    if(Erx > _rLocked) then
      RecBufClear(250);

    //    Art_Data:ReadCharge(Ein.P.ArtikelID, '', 0,0);  // Charge holen
    if (Ein.P.TerminZusage<>0.0.0) then
      Ein.P.Termin1Wunsch # Ein.P.TerminZusage;

    Print('Artikel');
    vSumMenge # vSumMenge + Ein.P.Menge;
    vSumRueck # vSumRueck + Ein.P.FM.Rest;
    AddSum(cGesSumBestmng   , Ein.P.Menge);
    AddSum(cGesSumRueckstand, Ein.P.FM.Rest);
  END;
  //Print('Summe');

  ListTerm();


  // Selektion löschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(501,vSelName);

end;

//========================================================================