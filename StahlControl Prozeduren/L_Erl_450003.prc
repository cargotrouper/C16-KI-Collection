@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450003
//                    OHNE E_R_G
//  Info        Materialabsatz
//
//
//  31.01.2007  AI  Erstellung der Prozedur
//  28.07.2008  DS  QUERY
//  12.04.2021  ST  Erweiterung Lieferscheinnummer in XML
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List
@I:Def_aktionen

define begin
end;

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);

  Sel.Auf.ObfNr2          # 999;

  Sel.bis.Datum           # today;
  Sel.Fin.bis.Rechnung    # 99999999;

  Sel.Auf.bis.Nummer      # 99999999;
  Sel.Auf.bis.Datum       # today;
  Sel.Auf.bis.Projekt     # 99999999;
  Sel.Auf.bis.AufArt      # 999;
  Sel.Auf.bis.WGr         # 9999;

  Sel.Auf.bis.Nummer      # 99999999;
  Sel.Auf.bis.Datum       # today;
  Sel.Auf.bis.AufArt      # 9999;
  Sel.Auf.bis.WGr         # 9999;

  Sel.Auf.bis.LiefDat     # today;
  Sel.Auf.bis.Dicke       # 999999.00;
  Sel.Auf.bis.Breite      # 999999.00;
  "Sel.Auf.bis.Länge"     # 999999.00;

  Sel.Fin.GutschriftYN    # y;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450003',here+':AusSel');
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
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');

  vHdl2->WinLstDatLineAdd('Güte * Abmessung');
  vHdl2->WinLstDatLineAdd('Lieferdatum');
  vHdl2->WinLstDatLineAdd('Rechnungsdatum');
  vHdl2->wpcurrentint # 1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
    if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;
  vSort # gSelected;
  gSelected # 0;

  StartList(vSort,vSortname);  // Liste generieren

end;

//========================================================================
//  Print
//
//========================================================================
Sub Print(aName : alpha);
local begin
  Erx   : int;
  vSum  : float;
  vSum2 : float;
  vObf  : alpha(120);
end;
begin

  case aName of

    'Aktion' : begin
      StartLine();
      Write(1, ZahlI(Auf.A.Rechnungsnr)                           ,y ,_LF_INT);
      if (Auf.A.Rechnungsdatum<>0.0.0) then
        Write(2, DatS(Auf.A.Rechnungsdatum)                         ,y ,_LF_Date);
      Write(3, ZahlI(Auf.A.Nummer)+'/'+ZahlI(Auf.A.Position)      ,y ,0);
      Write(4, ZahlI(Auf.P.Warengruppe)                           ,y ,_LF_INT);
      Write(5, ZahlI(Mat.Nummer)                                  ,y ,_LF_INT , 3.0);
      Write(6, "Mat.Güte"                                         ,n ,0);
      Write(7, ZahlF(Mat.Dicke,Set.Stellen.Dicke)                 ,y ,_LF_Num);
      Write(8, ZahlF(Mat.Breite,Set.Stellen.Breite)               ,y ,_LF_Num);
      Write(9, ZahlF("Mat.Länge","Set.Stellen.Länge")             ,y ,_LF_Num);
      Write(10,ZahlF(Auf.A.NettoGewicht,Set.Stellen.Gewicht)      ,y ,_LF_Num);
      Write(11,ZahlF(Auf.A.Gewicht,Set.Stellen.Gewicht)           ,y ,_LF_Num);
      Write(12,ZahlF(Auf.A.RechPreisW1,2)                         ,y ,_LF_Wae  , 3.0);
      Write(13,Auf.P.KundenSW                                     ,n ,0);
      Write(14,ZahlI(Auf.P.Projektnummer)                         ,y ,_LF_INT);
      if (Auf.A.Aktionsdatum<>0.0.0) then
        Write(15, DatS(Auf.A.Aktionsdatum)                          ,y ,_LF_Date);

      // ggf. mehr Daten bei XML-Ausgabe
      if (List_XML) then begin
        Write(16, ZahlI("Auf.A.Stückzahl")                        ,y ,_LF_Int);
        if (Auf.P.Termin1Wunsch<>0.0.0) then
          Write(17,DatS(Auf.P.Termin1Wunsch)                      ,y ,_LF_Date);
        if (Auf.P.Anlage.Datum<>0.0.0) then
          Write(18,DatS(Auf.P.Anlage.Datum)                       ,y ,_LF_Date);
        Erx # RecLink(110,400,20,_recfirst);      // Vetreter holen
        if (Erx>_rLocked) then RecBufClear(110);
        Write(19, Ver.Stichwort                                   ,n ,0);
        Erx # RecLink(110,400,21,_recfirst);      // Verband holen
        if (Erx>_rLocked) then RecBufClear(110);
        Write(20, Ver.Stichwort                                   ,n ,0);
        Write(21, Auf.Sachbearbeiter                              ,n ,0);
        Write(22, ZahlI(Auf.P.Auftragsart)                        ,y ,_LF_Int);
        vObf # '';
        FOR Erx # RecLink(201,200,11,_recFirst);
        LOOP Erx # RecLink(201,200,11,_recNext);
        WHILE(Erx <= _rLocked) DO BEGIN
          Lib_Strings:Append(var vObf, Mat.AF.Bezeichnung, ', ');
        END;
        Write(23, vObf                                            ,n , 0);
        Write(24, Adr.LKZ                                         ,n , 0);  // LKZ
/*
        if (Auf.A.Aktionstyp = c_Akt_LFS) then
          Write(25, ZahlI(Auf.A.Aktionsnr)                          ,y ,_LF_INT);
*/
      end;  // XML-Ausgabe

      EndLine();

      AddSum(1, Auf.A.NettoGewicht);
      AddSum(2, Auf.A.Gewicht);
      AddSum(3, Auf.A.RechPreisW1);
    end;

    'Summe' : begin
      StartLine(_LF_Overline);
      Write(10, ZahlF(getSum(1), 0)                                         ,y, _LF_Num);
      Write(11, ZahlF(getSum(2), 0)                                         ,y, _LF_Num);
      Write(12, ZahlF(getSum(3), 2)                                    ,y, _LF_Wae, 3.0);
      EndLine();
    end; // Summe

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
      Write(1, 'ReDat.'                                              ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(3, ' von: '                                              ,n , 0);
      if (Sel.von.Datum<>0.0.0) then
      Write(4, DatS(Sel.von.Datum)                                   ,n , 0);
      Write(5, ' bis: '                                              ,n , 0);
      if (Sel.bis.Datum<>0.0.0) then
      Write(6, DatS(Sel.bis.Datum)                                   ,y , 0, 3.0);
      Write(7, 'ReNr.'                                               ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(9, ' von: '                                              ,n , 0);
      Write(10, ZahlI(Sel.Fin.von.Rechnung)                          ,n , _LF_INT);
      Write(11, ' bis: '                                             ,n , 0);
      Write(12, ZahlI(Sel.Fin.bis.Rechnung)                          ,y , _LF_INT, 3.0);
      Write(13, 'AuftragsNr.'                                        ,n , 0);
      Write(14, ': '                                                 ,n , 0);
      Write(15, ' von: '                                             ,n , 0);
      Write(16, ZahlI(Sel.Auf.von.Nummer)                            ,n , _LF_INT);
      Write(17, ' bis: '                                             ,n , 0);
      Write(18, ZahlI(Sel.Auf.bis.Nummer)                            ,y , _LF_INT);
      Endline();

      StartLine();
      Write(1, 'ErfassDat.'                                          ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(3, ' von: '                                              ,n , 0);
      if (Sel.Auf.von.Datum<>0.0.0) then
      Write(4, DatS(Sel.Auf.von.Datum)                               ,n , 0);
      Write(5, ' bis: '                                              ,n , 0);
      if (Sel.Auf.bis.Datum<>0.0.0) then
      Write(6, DatS(Sel.Auf.bis.Datum)                               ,y , 0, 3.0);
      Write(7, 'Projekt'                                             ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(9, ' von: '                                              ,n , 0);
      Write(10, ZahlI(Sel.Auf.von.Projekt)                           ,n , _LF_INT);
      Write(11, ' bis: '                                             ,n , 0);
      Write(12, ZahlI(Sel.Auf.bis.Projekt)                           ,y , _LF_INT, 3.0);
      Write(13, 'Vorgangsart'                                        ,n , 0);
      Write(14, ': '                                                 ,n , 0);
      Write(15, ' von: '                                             ,n , 0);
      Write(16, ZahlI(Sel.Auf.von.AufArt)                            ,n , _LF_INT);
      Write(17, ' bis: '                                             ,n , 0);
      Write(18, ZahlI(Sel.Auf.bis.AufArt)                            ,y , _LF_INT);
      Endline();

      StartLine();
      Write(1, 'Wgr'                                                 ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(3, ' von: '                                              ,n , 0);
      Write(4, ZahlI(Sel.Auf.von.WGr)                                ,n , _LF_INT);
      Write(5, ' bis: '                                              ,n , 0);
      Write(6, ZahlI(Sel.Auf.bis.WGr)                                ,y , _LF_INT, 3.0);
      Write(7, 'KundeNr.'                                            ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(10, ZahlI(Sel.Auf.Kundennr)                              ,n , _LF_INT);
      Write(13, 'VertreterNr.'                                       ,n , 0);
      Write(14, ': '                                                 ,n , 0);
      Write(16, ZahlI(Sel.Auf.Vertreternr)                           ,n , _LF_INT);
      Endline();

      StartLine();
      Write(1, 'Sachbear.'                                           ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(4, Sel.Auf.Sachbearbeit                                  ,n , 0);
      Write(7, 'LiefDat.'                                             ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(9, ' von: '                                              ,n , 0);
      if (Sel.Auf.von.Liefdat<>0.0.0) then
      Write(10, DatS(Sel.Auf.bis.Liefdat)                            ,n , 0);
      Write(11, ' bis: '                                             ,n , 0);
      if (Sel.Auf.bis.Liefdat<>0.0.0) then
      Write(12, DatS(Sel.Auf.bis.Liefdat)                            ,y , 0, 3.0);
      Write(13, 'Güte'                                               ,n , 0);
      Write(14, ': '                                                 ,n , 0);
      Write(16, "Sel.Auf.Güte"                                       ,n , 0);
      Endline();

      StartLine();
      Write(1, 'ObfNr.'                                              ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(3, ' von: '                                              ,n , 0);
      Write(4, ZahlI(Sel.Auf.ObfNr)                                  ,n , _LF_Int);
      Write(5, ' bis: '                                              ,n , 0);
      Write(6, ZahlI(Sel.Auf.ObfNr2)                                 ,n , _LF_Int,3.0);
      Write(7, 'Dicke'                                               ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(9, ' von: '                                              ,n , 0);
      Write(10, ZahlF(Sel.Auf.von.Dicke, Set.Stellen.Dicke)          ,n , _LF_Num);
      Write(11, ' bis: '                                             ,n , 0);
      Write(12, ZahlF(Sel.Auf.bis.Dicke, Set.Stellen.Dicke)          ,y , _LF_Num  , 3.0);
      Write(13, 'Breite'                                             ,n , 0);
      Write(14, ': '                                                 ,n , 0);
      Write(15, ' von: '                                             ,n , 0);
      Write(16, ZahlF(Sel.Auf.von.Breite, Set.Stellen.Breite)        ,n , _LF_Num);
      Write(17, ' bis: '                                             ,n , 0);
      Write(18, ZahlF(Sel.Auf.bis.Breite, Set.Stellen.Breite)        ,y , _LF_Num);
      Endline();

      StartLine();
      Write(1, 'Länge'                                               ,n , 0);
      Write(2, ': '                                                  ,n , 0);
      Write(3, ' von: '                                              ,n , 0);
      Write(4, ZahlF("Sel.Auf.von.Länge", "Set.Stellen.Länge")       ,n , _LF_Num);
      Write(5, ' bis: '                                              ,n , 0);
      Write(6, ZahlF("Sel.Auf.bis.Länge", "Set.Stellen.Länge")       ,y , _LF_Num  , 3.0);
      Write(7, 'Verband'                                             ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(10, ZahlI(Sel.Adr.von.Verband)                           ,n , _LF_Int);

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
  StartLine();
  EndLine();
  if (aSeite=1) then begin

    Print('Selektierung');

    StartLine();

    EndLine();

  end;
// ---- Hier gehts weiter!
  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 12.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 20.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 20.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 10.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 17.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 15.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 15.0;
  List_Spacing[10]  # List_Spacing[ 9] + 15.0;
  List_Spacing[11]  # List_Spacing[10] + 20.0;
  List_Spacing[12]  # List_Spacing[11] + 18.0;
  List_Spacing[13]  # List_Spacing[12] + 30.0;
  List_Spacing[14]  # List_Spacing[13] + 35.0;
  List_Spacing[15]  # List_Spacing[14] + 13.0;
  List_Spacing[16]  # List_Spacing[15] + 20.0;

  List_Spacing[17]  # 300.0;
  List_Spacing[18]  # 300.0;
  List_Spacing[19]  # 300.0;
  List_Spacing[20]  # 300.0;
  List_Spacing[21]  # 300.0;
  List_Spacing[22]  # 300.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Re.Nr.'                         ,y , 0);
  Write(2, 'Re.Dat.'                        ,y , 0);
  Write(3, 'Auf.Nr.'                        ,y , 0);
  Write(4, 'Wgr.'                           ,y , 0);
  Write(5, 'Mat.Nr.'                        ,y , 0, 3.0);
  Write(6, 'Güte'                           ,n , 0);
  Write(7, 'Dicke'                          ,y , 0);
  Write(8, 'Breite'                         ,y , 0);
  Write(9, 'Länge'                          ,y , 0);
  Write(10, 'Netto kg'                       ,y , 0);
  Write(11, 'Brutto kg'                      ,y , 0);
  Write(12, 'Umsatz '+"Set.Hauswährung.Kurz" ,y , 0, 3.0);
  Write(13, 'Kunde'                          ,n , 0);
  Write(14, 'Projekt'                        ,y , 0);
  Write(15, 'Lieferdat.'                     ,y , 0);

  // mehr Daten bei XML-Ausgabe
  if (List_XML) then begin
    Write(16, 'Stück'                          ,y , 0);
    Write(17, 'Wunschterm.'                    ,y , 0);
    Write(18, 'Anlagedat.'                     ,y , 0);
    Write(19, 'Vertreter'                      ,n , 0);
    Write(20, 'Verband'                        ,n , 0);
    Write(21, 'Sachbear.'                      ,n , 0);
    Write(22, 'Vorgangstyp'                    ,n , 0);
    Write(23, 'Oberfläche'                     ,n , 0);
    Write(24, 'LKZ'                            ,n , 0);  // LKZ
/*
    Write(25, 'Lieferscheinnr.'                ,n , 0);
*/
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
Sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx         : int;
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;
  vTree       : int;
  vOK         : logic;
  vSortKey    : alpha;
  vPL         : int;
  vQ          : alpha(4000);
  vQ401       : alpha(4000);
  vq411       : alpha(4000);
  vQ400       : alpha(4000);
  vQ402       : alpha(4000);
  vQ410       : alpha(4000);
  vQ200       : alpha(4000);
  vQ210       : alpha(4000);
  vQ201       : alpha(4000);
  vQ100       : alpha(4000);
  tErx        : int;
  tErx2       : int;
  tErx3       : int;
  tErx4       : int;
  tErx5       : int;
  tErx6       : int;
  tErx7       : int;
  tErx8       : int;
  tErx9       : int;
end;
begin

  // Liste starten
if (gusername='AH') then gSQLBuffer # 1
else
  ListInit(y); // mit Landscape


  // SELEKTION -------------------------------------------------------------
  // Selektionsquery für 100
  vQ100 # '';
  if(Sel.Adr.von.LKZ <> '') then
    Lib_Sel:QAlpha(var vQ100, 'Adr.LKZ', '=', Sel.Adr.von.LKZ);

  // Selektionsquery für 404
  vQ # '';
  if (Sel.Fin.von.Rechnung != 0) or (Sel.Fin.bis.Rechnung != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.A.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung);
  if (Sel.von.Datum != 0.0.0) or (Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ, 'Auf.A.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
  Lib_Sel:QInt(var vQ, 'Auf.A.Rechnungsnr', '>', 0);
  Lib_Sel:QInt(var vQ, 'Auf.A.Materialnr', '>', 0);
  if (Sel.Auf.von.Nummer != 0) or (Sel.Auf.bis.Nummer != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.A.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer);
  if (Sel.Auf.von.LiefDat != 0.0.0) or (Sel.Auf.bis.LiefDat != today) then
    Lib_Sel:QVonBisD(var vQ, 'Auf.A.Aktionsdatum', Sel.Auf.von.LiefDat, Sel.Auf.bis.LiefDat);
  if (gSQLBuffer=0) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' ((LinkCount(AufPos) > 0 OR LinkCount(AufPosA) > 0)) AND '+
              ' ((LinkCount(Material) > 0 OR LinkCount(MaterialA) > 0)) ';
  end;

  // Selektionsquery für 401
  vQ401 # '';
  if (Sel.Auf.Kundennr != 0) then
    Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr);
  if (Sel.Auf.von.Datum != 0.0.0) or (Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ401, 'Auf.P.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum);
  if (Sel.Auf.von.Projekt != 0) or (Sel.Auf.bis.Projekt != 99999999) then
    Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt);
  if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
    Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);
  if (Sel.Auf.von.Wgr != 0) or (Sel.Auf.bis.Wgr != 9999) then
    Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr);
  if (gSQLBuffer=0) then begin
    if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
    vQ401 # vQ401 + ' LinkCount(AufKopf) > 0 ';
  end;

  // Selektionsquery für 411
  vQ411 # '';
  if (Sel.Auf.Kundennr != 0) then
    Lib_Sel:QInt(var vQ411, '"Auf~P.Kundennr"', '=', Sel.Auf.Kundennr);
  if (Sel.Auf.von.Datum != 0.0.0) or (Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vq411, '"Auf~P.Anlage.Datum"', Sel.Auf.von.Datum, Sel.Auf.bis.Datum);
  if (Sel.Auf.von.Projekt != 0) or (Sel.Auf.bis.Projekt != 99999999) then
    Lib_Sel:QVonBisI(var vq411, '"Auf~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt);
  if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
    Lib_Sel:QVonBisI(var vq411, '"Auf~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);
  if (Sel.Auf.von.Wgr != 0) or (Sel.Auf.bis.Wgr != 9999) then
    Lib_Sel:QVonBisI(var vq411, '"Auf~P.Warengruppe"', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr);
  if (gSQLBuffer=0) then begin
    if (vq411 != '') then vq411 # vq411 + ' AND ';
    vq411 # vq411 + ' LinkCount(AufKopfA) > 0 ';
  end;

  // Selektionsquery für 400
  vQ400 # '';
  if (Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt(var vQ400, 'Auf.Vertreter', '=', Sel.Auf.Vertreternr);
  if (Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt(var vQ400, 'Auf.Vertreter2', '=', Sel.Adr.von.Verband);
  if (Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha(var vQ400, 'Auf.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit);
  if (gSQLBuffer=0) then begin
    if (vQ400 != '') then vQ400 # vQ400 + ' AND ';
    vQ400 # vQ400 + ' LinkCount(AdrRechEmpf) > 0 ';
  end;

  // Selektionsquery für 410
  vQ410 # '';
  if (Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt(var vQ410, '"Auf~Vertreter"', '=', Sel.Auf.Vertreternr);
  if (Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt(var vQ410, '"Auf~Vertreter2"', '=', Sel.Adr.von.Verband);
  if (Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha(var vQ410, '"Auf~Sachbearbeiter"', '=', Sel.Auf.Sachbearbeit);
  if (gSQLBuffer=0) then begin
    if (vQ410 != '') then vQ410 # vQ410 + ' AND ';
    vQ410 # vQ410 + ' LinkCount(AdrRechEmpfA) > 0 ';
  end;

  //Selektionsquery für 200
  vQ200 # '';
  if ("Sel.Auf.Güte" != '') then
    Lib_Sel:QAlpha(var vq200, '"Mat.Güte"', '=*', "Sel.Auf.Güte");
  if (Sel.Auf.von.Dicke != 0.0) or (Sel.Auf.bis.Dicke != 999999.00) then
    Lib_Sel:QVonBisF(var vq200, 'Mat.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke);
  if (Sel.Auf.von.Breite != 0.0) or (Sel.Auf.bis.Breite != 999999.00) then
    Lib_Sel:QVonBisF(var vq200, 'Mat.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite);
  if ("Sel.Auf.von.Länge" != 0.0) or ("Sel.Auf.bis.Länge" != 999999.00) then
    Lib_Sel:QVonBisF(var vq200, '"Mat.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge");
  if (gSQLBuffer=0) then begin
    if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then begin
      if (vq200 != '') then vq200 # vq200 + ' AND ';
      vq200 # vq200 + ' LinkCount(MatAusf) > 0 ';
    end;
  end;

  //Selektionsquery für 210
  vQ210 # '';
  if ("Sel.Auf.Güte" != '') then
    Lib_Sel:QAlpha(var vQ210, '"Mat~Güte"', '=*', "Sel.Auf.Güte");
  if (Sel.Auf.von.Dicke != 0.0) or (Sel.Auf.bis.Dicke != 999999.00) then
    Lib_Sel:QVonBisF(var vQ210, '"Mat~Dicke"', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke);
  if (Sel.Auf.von.Breite != 0.0) or (Sel.Auf.bis.Breite != 999999.00) then
    Lib_Sel:QVonBisF(var vQ210, '"Mat~Breite"', Sel.Auf.von.Breite, Sel.Auf.bis.Breite);
  if ("Sel.Auf.von.Länge" != 0.0) or ("Sel.Auf.bis.Länge" != 999999.00) then
    Lib_Sel:QVonBisF(var vQ210, '"Mat~Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge");
  if (gSQLBuffer=0) then begin
    if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then begin
      if (vQ210 != '') then vQ210 # vQ210 + ' AND ';
      vQ210 # vQ210 + ' LinkCount(MatAusfA) > 0 ';
    end;
 end;

  //Selektionsquery für 201
  vQ201 # '';
  if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ201, 'Mat.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2);

if (gSQLBuffer<>0) then begin
  gSQLBuffer # 0;
  Lib_SQL:SetPara('horst', 'genau Einer');
  Lib_SQL:SetPara('ding', 'von','bis');
  Lib_SQL:SetPara('Stichtag', '31.12.2012');
  Lib_SQL:SetPara('Bereich', '','999');
  //Lib_SQL:SetSort('lalala nach ARtikel');
  Lib_SQL:SetSubSQL('Q404',   vQ);
  Lib_SQL:SetSubSQL('Q401',   vQ401,  404,1);
  Lib_SQL:SetSubSQL('Q400',   vQ400,  401,3);
  Lib_SQL:SetSubSQL('Q100',   vQ100,  400,4);
  Lib_SQL:SetSubSQL('Q411',   vQ411,  404,7);
  Lib_SQL:SetSubSQL('Q410',   vQ410,  411,3);
  Lib_SQL:SetSubSQL('Q100b',  vQ100,  410,4);
  Lib_SQL:SetSubSQL('Q200',   vQ200,  404,6);
  Lib_SQL:SetSubSQL('Q201',   vQ201,  200,11);
  Lib_SQL:SetSubSQL('Q210',   vQ210,  404,8);
  Lib_SQL:SetSubSQL('Q201b',  vQ201,  210,11);
  if (vQ201<>'') then
    Lib_SQL:ParseSQL('Q404 AND ((Q401 AND Q400 AND Q100) OR (Q411 AND Q410 AND Q100b)) AND ((Q200 AND Q201) OR (Q210 AND Q201b))');
  else
    //Lib_SQL:ParseSQL('Q404 AND ((Q401 AND [Q400] AND Q100 [\Q400]) OR (Q411 AND Q410 AND Q100b)) AND ((Q200) OR (Q210))');
  //Lib_SQL:SaveSQL('E:\text.xml');
  RETURN;
/****
  Lib_SQL:AddSQL(vQ);

  if (vQ401<>'') or (vQ400<>'') or (vQ100<>'') then begin
    Lib_SQL:AddSQL('AND (');

      Lib_SQL:AddSQL(vQ401, 404,1);
        Lib_SQL:AddSQL('AND');
        Lib_SQL:AddSQL(vQ400, 401,3);
          Lib_SQL:AddSQL('AND');
          Lib_SQL:AddSQL(vQ100, 400,4);
          Lib_SQL:AddSQL(')');  // 100
        Lib_SQL:AddSQL(')');    // 400
      Lib_SQL:AddSQL(')');      // 401
      Lib_SQL:AddSQL('OR');
      Lib_SQL:AddSQL(vQ411, 404,7);
        Lib_SQL:AddSQL('AND');
        Lib_SQL:AddSQL(vQ410, 411,3);
          Lib_SQL:AddSQL('AND');
          Lib_SQL:AddSQL(vQ100, 410,4);
          Lib_SQL:AddSQL(')');
        Lib_SQL:AddSQL(')');
      Lib_SQL:AddSQL(')');

    Lib_SQL:AddSQL(')'); // 1. AND
  end;

  if (vQ200<>'') or (vQ201<>'') then begin
    Lib_SQL:AddSQL('AND (');

      Lib_SQL:AddSQL(vQ200, 404,6);
      if (vQ201<>'') then begin
        Lib_SQL:AddSQL('AND');
        Lib_SQL:AddSQL(vQ201, 200,11);
        Lib_SQL:AddSQL(')');
      end;
      Lib_SQL:AddSQL(')');  // 200
      Lib_SQL:AddSQL('OR');
      Lib_SQL:AddSQL(vQ210, 404,8);
      if (vQ201<>'') then begin
        Lib_SQL:AddSQL('AND');
        Lib_SQL:AddSQL(vQ201, 210,11);
        Lib_SQL:AddSQL(')');
      end;
      Lib_SQL:AddSQL(')');  // 210

    Lib_SQL:AddSQL(')');    // 1. AND
  end;

  Lib_SQL:SaveSQL();
  RETURN;
*****/
end;


  // Selektion starten...
  vSel # SelCreate(404, 1);
  vSel->SelAddLink('', 401,           404, 1, 'AufPos');
  vSel->SelAddLink('', 411,           404, 7, 'AufPosA');
  vSel->SelAddLink('AufPos',400,      401, 3, 'AufKopf');
  vSel->SelAddLink('AufPosA', 410,    411, 3, 'AufKopfA');
  vSel->SelAddLink('AufKopf', 100,    400, 4, 'AdrRechEmpf');
  vSel->SelAddLink('AufKopfA', 100,   410, 4, 'AdrRechEmpfA');
  vSel->SelAddLink('', 200,           404, 6, 'Material');
  vSel->SelAddLink('', 210,           404, 8, 'MaterialA');
  vSel->SelAddLink('Material', 201,   200, 11, 'MatAusf');
  vSel->SelAddLink('MaterialA', 201,  210, 11, 'MatAusfA');
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPos',    vQ401);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPosA',   vQ411);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufKopf',   vQ400);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufKopfA',  vQ410);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AdrRechEmpf',   vQ100);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AdrRechEmpfA',  vQ100);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Material',  vq200);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('MaterialA', vQ210);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('MatAusf',   vQ201);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('MatAusfA',  vQ201)
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

//if (gUsername='AH') then begin
//  SelDelete(404, '___TEST');
//  SelCopy(404,vSelname, '___TEST');
//end;

  // Alte Version
  // Selektion öffnen
  //vSelName # Sel_Build(vSel, 404, 'LST.450003',y,0);

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vFlag # _RecFirst;
  WHILE (RecRead(404,vSel,vFlag) <= _rLocked) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Erx # RecLink(200,404,6,_recFirst);     // Material holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(210,404,8,_recFirst);   // ~Material holen
      if (Erx>_rLocked) then RecBufClear(210);
      RecBufCopy(210,200);
    end;

    if (aSort=1) then
      vSortKey # "Mat.Güte"+cnvaf(Mat.Dicke,_FmtNumNoGroup|_FmtNumLeadZero,0,3,12)+cnvaf(Mat.Breite,_FmtNumLeadZero,0,3,12)+cnvaf("Mat.Länge",_FmtNumLeadZero,0,3,12);
    if (aSort=2) then
      vSortkey # cnvAI((cnvID(Auf.A.Aktionsdatum)),_FmtNumLeadZero,0,0);
    if (aSort=3) then
      vSortKey # cnvAI((cnvID(Auf.A.Rechnungsdatum)),_FmtNumLeadZero,0,0);
    Sort_ItemAdd(vTree,vSortKey,404,RecInfo(404,_RecId));

  END;
  // Selektion löschen
  SelClose(vSel); vSel # 0;
  SelDelete(404,vSelName);

  if (Sel.Fin.GutschriftYN) then begin
    // GUTSCHRIFTEN ***************************************************

    // Selektionsquery für 404
    vQ # '';
    if (Sel.Fin.von.Rechnung != 0) or (Sel.Fin.bis.Rechnung != 99999999) then
      Lib_Sel:QVonBisI(var vQ, 'Auf.A.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung);
    if (Sel.von.Datum != 0.0.0) or (Sel.bis.Datum != today) then
      Lib_Sel:QVonBisD(var vQ, 'Auf.A.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
    Lib_Sel:QInt(var vQ, 'Auf.A.Rechnungsnr', '>', 0);
    //Lib_Sel:QAlpha(var vQ, 'Auf.A.Aktionstyp', '=', 'GUT');
    if (vQ != '') then
      vQ # vQ + ' AND ';
    vQ # vQ + ' (Auf.A.Aktionstyp = ''' + c_REKOR + ''' OR Auf.A.Aktionstyp = ''' + c_BOGUT +''' OR Auf.A.Aktionstyp = ''' + c_GUT + ''' OR Auf.A.Aktionstyp = ''' + c_Bel_KD + ''' OR Auf.A.Aktionstyp = ''' + c_Bel_LF + ''') '


    if (Sel.Auf.von.Nummer != 0) or (Sel.Auf.bis.Nummer != 99999999) then
      Lib_Sel:QVonBisI(var vQ, 'Auf.A.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer);
    if (Sel.Auf.von.LiefDat != 0.0.0) or (Sel.Auf.bis.LiefDat != today) then
      Lib_Sel:QVonBisD(var vQ, 'Auf.A.Aktionsdatum', Sel.Auf.von.LiefDat, Sel.Auf.bis.LiefDat);
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' (LinkCount(AufPos) > 0 OR LinkCount(AufPosA) > 0)';

    // Selektionsquery für 401
    vQ401 # '';
    if ("Sel.Auf.Güte" != '') then
      Lib_Sel:QAlpha(var vQ401, '"Auf.P.Güte"', '=*', "Sel.Auf.Güte");
    if (Sel.Auf.von.Dicke != 0.0) or (Sel.Auf.bis.Dicke != 999999.00) then
      Lib_Sel:QVonBisF(var vQ401, 'Auf.P.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke);
    if (Sel.Auf.von.Breite != 0.0) or (Sel.Auf.bis.Breite != 999999.00) then
      Lib_Sel:QVonBisF(var vQ401, 'Auf.P.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite);
    if ("Sel.Auf.von.Länge" != 0.0) or ("Sel.Auf.bis.Länge" != 999999.00) then
      Lib_Sel:QVonBisF(var vQ401, '"Auf.P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge");
    if (Sel.Auf.Kundennr != 0) then
      Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr);
    if (Sel.Auf.von.Datum != 0.0.0) or (Sel.Auf.bis.Datum != today) then
      Lib_Sel:QVonBisD(var vQ401, 'Auf.P.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum);
    if (Sel.Auf.von.Projekt != 0) or (Sel.Auf.bis.Projekt != 99999999) then
      Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt);
    if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 999) then
      Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);
    if (Sel.Auf.von.Wgr != 0) or (Sel.Auf.bis.Wgr != 9999) then
      Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr);
    if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then begin
      if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
      vQ401 # vQ401 + ' LinkCount(Ausf) > 0 ';
    end;
    if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
    vQ401 # vQ401 + ' LinkCount(AufKopf) > 0 ';

    // Selektionsquery für 411
    vq411 # '';
    if ("Sel.Auf.Güte" != '') then
      Lib_Sel:QAlpha(var vq411, '"Auf~P.Güte"', '=*', "Sel.Auf.Güte");
    if (Sel.Auf.von.Dicke != 0.0) or (Sel.Auf.bis.Dicke != 999999.00) then
      Lib_Sel:QVonBisF(var vq411, '"Auf~P.Dicke"', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke);
    if (Sel.Auf.von.Breite != 0.0) or (Sel.Auf.bis.Breite != 999999.00) then
      Lib_Sel:QVonBisF(var vq411, '"Auf~P.Breite"', Sel.Auf.von.Breite, Sel.Auf.bis.Breite);
    if ("Sel.Auf.von.Länge" != 0.0) or ("Sel.Auf.bis.Länge" != 999999.00) then
      Lib_Sel:QVonBisF(var vq411, '"Auf~P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge");
    if (Sel.Auf.Kundennr != 0) then
      Lib_Sel:QInt(var vq411, '"Auf~P.Kundennr"', '=', Sel.Auf.Kundennr);
    if (Sel.Auf.von.Datum != 0.0.0) or (Sel.Auf.bis.Datum != today) then
      Lib_Sel:QVonBisD(var vq411, '"Auf~P.Anlage.Datum"', Sel.Auf.von.Datum, Sel.Auf.bis.Datum);
    if (Sel.Auf.von.Projekt != 0) or (Sel.Auf.bis.Projekt != 99999999) then
      Lib_Sel:QVonBisI(var vq411, '"Auf~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt);
    if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
      Lib_Sel:QVonBisI(var vq411, '"Auf~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);
    if (Sel.Auf.von.Wgr != 0) or (Sel.Auf.bis.Wgr != 9999) then
      Lib_Sel:QVonBisI(var vq411, '"Auf~P.Warengruppe"', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr);
    if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then begin
      if (vq411 != '') then vq411 # vq411 + ' AND ';
      vq411 # vq411 + ' LinkCount(AusfA) > 0 ';
    end;
    if (vq411 != '') then vq411 # vq411 + ' AND ';
    vq411 # vq411 + ' LinkCount(AufKopfA) > 0 ';
    // Selektionsquery für 400
    vQ400 # '';
    if (Sel.Auf.Vertreternr != 0) then
      Lib_Sel:QInt(var vQ400, 'Auf.Vertreter', '=', Sel.Auf.Vertreternr);
    if (Sel.Adr.von.Verband != 0) then
      Lib_Sel:QInt(var vQ400, 'Auf.Vertreter2', '=', Sel.Adr.von.Verband);
    if (Sel.Auf.Sachbearbeit != '') then
      Lib_Sel:QAlpha(var vQ400, 'Auf.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit);

    // Selektionsquery für 410
    vQ410 # '';
    if (Sel.Auf.Vertreternr != 0) then
      Lib_Sel:QInt(var vQ410, '"Auf~Vertreter"', '=', Sel.Auf.Vertreternr);
    if (Sel.Adr.von.Verband != 0) then
      Lib_Sel:QInt(var vQ410, '"Auf~Vertreter2"', '=', Sel.Adr.von.Verband);
    if (Sel.Auf.Sachbearbeit != '') then
      Lib_Sel:QAlpha(var vQ410, '"Auf~Sachbearbeiter"', '=', Sel.Auf.Sachbearbeit);

    //Selektionsquery für 402
    vQ402 # '';
    if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then
      Lib_Sel:QVonBisI(var vQ402, 'Auf.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2);

    // Selektion starten...
    vSel # SelCreate(404, 1);
    vSel->SelAddLink('', 401, 404, 1, 'AufPos');
    vSel->SelAddLink('', 411, 404, 7, 'AufPosA');
    vSel->SelAddLink('AufPos', 400, 401, 3, 'AufKopf');
    vSel->SelAddLink('AufPosA', 410, 411, 3, 'AufKopfA');
    vSel->SelAddLink('AufPos', 402, 401, 11, 'Ausf');
    vSel->SelAddLink('AufPosA', 402, 411, 11, 'AusfA');
    tErx  # vSel->SelDefQuery('',           vQ );
    tErx2 # vSel->SelDefQuery('AufPos',     vQ401);
    tErx3 # vSel->SelDefQuery('AufPosA',    vq411);
    tErx4 # vSel->SelDefQuery('AufKopf',    vQ400);
    tErx5 # vSel->SelDefQuery('AufKopfA',   vQ410);
    tErx6 # vSel->SelDefQuery('Ausf',       vQ402);
    tErx7 # vSel->SelDefQuery('AusfA',      vQ402);
    vSelName # Lib_Sel:SaveRun(var vSel, 0);

    // Alte Version
    //vSelName # Sel_Build(vSel, 404, 'LST.450003_2',y,0);
    vFlag # _RecFirst;
    WHILE (RecRead(404,vSel,vFlag) <= _rLocked) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;

      Erx # RecLink(401,404,1,_recFirst);     // Position holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(411,404,7,_recFirst);   // ~Position holen
        if (Erx>_rLocked) then RecBufClear(411);
        RecBufCopy(411,401);
      end;

      if (aSort=1) then
        vSortKey # "Auf.P.Güte"+cnvaf(Auf.P.Dicke ,_FmtNumNoGroup|_FmtNumLeadZero,0,3,12)+cnvaf(Auf.P.Breite,_FmtNumLeadZero,0,3,12)+cnvaf("Auf.P.Länge",_FmtNumLeadZero,0,3,12);
      if (aSort=2) then
        vSortkey # cnvAI((cnvID(Auf.A.Aktionsdatum)),_FmtNumLeadZero,0,0);
      if (aSort=3) then
        vSortKey # cnvAI((cnvID(Auf.A.Rechnungsdatum)),_FmtNumLeadZero,0,0);
      Sort_ItemAdd(vTree,vSortKey,404,RecInfo(404,_RecId));
    END;
    // Selektion löschen
    SelClose(vSel); vSel # 0;
    SelDelete(404,vSelName);
  end;



  // AUSGABE ---------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Durchlaufen und löschen
  vItem # Sort_ItemFirst(vTree)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    Erx # RecLink(401,404,1,_recFirst);     // Position holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(411,404,7,_recFirst);   // ~Position holen
      if (Erx<=_rLocked) then begin
        RecLink(410,411,3,_recFirst);   // Kopf holen
        RecBufCopy(410,400);
        RecBufCopy(411,401);
        end
      else begin
        RecBufClear(400);
        RecBufClear(401);
      end;
      end
    else begin
      RecLink(400,401,3,_recFirst);   // Kopf holen
    end;

    Erx # RecLink(450, 404, 9, _recFirst); // Erl. holen
    if(Erx > _rLocked) then
      RecBufClear(450);

    Erx # RecLink(100, 450, 5, _recFirst); // Kd. holen
    if(Erx > _rLocked) then
      RecBufClear(100);

    if (Auf.A.Aktionstyp=c_Akt_DfaktGut) or (Auf.A.Aktionstyp=c_Akt_DfaktBel) then begin
      RecBufClear(200);
      "Mat.Güte"  # "Auf.P.Güte";
      Mat.Dicke   # Auf.P.Dicke;
      Mat.Breite  # Auf.P.Breite;
      "Mat.Länge" # "Auf.P.Länge";
      end
    else begin
      Erx # RecLink(200, 404, 6, _recFirst);     // Material holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(210, 404, 8, _recFirst);   // ~Material holen
        if (Erx>_rLocked) then
          RecBufClear(210);
        RecBufCopy(210, 200);
      end;
    end;


    Print('Aktion');

    vTree->Ctedelete(vItem);
    vItem # Sort_ItemFirst(vTree)

  END;  // loop

  Print('Summe');


  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================