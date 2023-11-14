@A+
//===== Business-Control =================================================
//
//  Prozedur    L_BAG_702004
//                    OHNE E_R_G
//  Info        BA-Auswertung
//
//
//
//  17.02.2012  MS  Erstellung der Prozedur Inmet
//  24.02.2012  MS  Anpassung an Std.
//  19.11.2014  ST  Bugfix: Datumsselektion; ARtikeldaten
//                  für XML Export hinzugefügt     Projekt 1485/14
//  24.10.2016  ST  Selektionserweiterung Ressourcenauswahl
//  13.02.2018  TM  Umstellung Brutto- auf Nettogewichte
//  27.07.2020  ST  Bugfix: Ext. Lief lesen Projekt  2100/9
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB Element(aName : alpha; aPrint : logic);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List2
@I:Def_Aktionen
@I:Def_BAG

declare StartList(aSort : int; aSortName : alpha);

define begin
  cMatFMKommGewB    : 1
  cMatFMResGewB     : 2
  cMatFMLagerGewB   : 3

  cMatFMKommGewN    : 4
  cMatFMResGewN     : 5
  cMatFMLagerGewN   : 6

  cGesSumGewicht    : 10
  cGesSumKomGew     : 11
  cGesSumResGew     : 12
  cGesSumLagGew     : 13
  cGesSumSchrottGew : 14
end;

// Handles für die Zeilenelemente
local begin
  g_Empty     : int;
  g_Sel1      : int;
  g_Sel2      : int;
  g_Header    : int;
  g_Material  : int;
  g_GesSum    : int;
  g_Leselinie : logic;

  gMatRestGew : float;
  gBuf200     : int;
  vExtLief    : alpha;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  List_FontSize           # 7;

  RecBufClear(998);

  Sel.bis.Datum           # today;
  Sel.Mat.bis.WGr         # 9999;
  Sel.Mat.ObfNr2          # 999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.702004',here+':AusSel');
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
  vSort       : int;
  vSortName   : alpha;
end;
begin

  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd(Translate('Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Materialnummer'));
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
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  vLine         : int;
  vObf          : alpha(120);
  vProzKomm     : float;
  vProzRes      : float;
  vProzSchrott  : float;
  vProzLager    : float;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   20.0;
      List_Spacing[ 3]  #   22.0;
      List_Spacing[ 4]  #   30.0;
      List_Spacing[ 5]  #   47.0;
      List_Spacing[ 6]  #   53.0;
      List_Spacing[ 7]  #   80.0;
      List_Spacing[ 8]  #  100.0;
      List_Spacing[ 9]  #  102.0;
      List_Spacing[10]  #  110.0;
      List_Spacing[11]  #  130.0;
      List_Spacing[12]  #  137.0;
      List_Spacing[13]  #  160.0;
      List_Spacing[14]  #  180.0;
      List_Spacing[15]  #  182.0;
      List_Spacing[16]  #  190.0;
      List_Spacing[17]  #  210.0;
      List_Spacing[18]  #  217.0;
      List_Spacing[19]  #  240.0;

      LF_Set(1, 'Warengr'                                           ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      if (Sel.Mat.von.Wgr <> 0) then
        LF_Set(4,  ZahlI(Sel.Mat.von.Wgr)                           ,n , _LF_INT);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      if (Sel.Mat.bis.Wgr <> 0) then
        LF_Set(6,  ZahlI(Sel.Mat.bis.Wgr)                           ,y , _LF_INT);
      LF_Set(7, 'Abschlussdatum'                                    ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      if(Sel.von.Datum <> 0.0.0) then
        LF_Set(10, DatS(Sel.von.Datum)                         ,n , _LF_Date);
      LF_Set(11, ' bis: '                                           ,n , 0);
      if(Sel.bis.Datum <> 0.0.0) then
        LF_Set(12, DatS(Sel.bis.Datum)                         ,y , _LF_Date);
    end;


    'SEL2' : begin
      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Oberfläche'                                        ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      LF_Set(4, ZahlI(Sel.Mat.ObfNr)                                ,n , _LF_INT);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      LF_Set(6, ZahlI(Sel.Mat.ObfNr2)                               ,n , _LF_INT);
      LF_Set(7, 'Ressource'                                         ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(10, ZahlI(Sel.BAG.Res.Nummer)                          ,n , _LF_INT);

    end;



    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 14.0; // 'BA'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 14.0; // 'Mat.'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 24.0; // 'Lieferant'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 14.0; // 'Dicke'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 14.0; // 'Breite'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 26.0; // 'Qualität'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 26.0; // 'Oberfläche'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 13.0; // 'Wgr.'
      List_Spacing[10]  # List_Spacing[ 9]  + 15.0; // 'Gewicht'
      List_Spacing[11]  # List_Spacing[ 10] + 20.0; // 'komm. Gew.'
      List_Spacing[12]  # List_Spacing[ 11] + 17.0; // 'res. Gew.'
      List_Spacing[13]  # List_Spacing[ 12] + 20.0; // 'Lager Gew.'
      List_Spacing[14]  # List_Spacing[ 13] + 17.0; // '% komm.'
      List_Spacing[15]  # List_Spacing[ 14] + 15.0; // '% res.'
      List_Spacing[16]  # List_Spacing[ 15] + 15.0; // '% Lager'
      List_Spacing[17]  # List_Spacing[ 16] + 17.0; // '% Schrott'
      List_Spacing[18]  # List_Spacing[ 17] + 17.0; // 'XML Artikelnr'
      List_Spacing[19]  # List_Spacing[ 18] + 17.0; // 'XML Artikelgrp'
      List_Spacing[20]  # List_Spacing[ 19] + 17.0; // 'XML ???'
      List_Spacing[21]  # List_Spacing[ 20] + 17.0; // 'XML Arbeitsgang'
      List_Spacing[22]  # List_Spacing[ 21] + 17.0; // 'XML Kosten pro PEH'
      List_Spacing[23]  # List_Spacing[ 22] + 17.0; // 'XML PEH und MEH'
      List_Spacing[24]  # List_Spacing[ 23] + 17.0; // 'XML Fixpreis'
      List_Spacing[25]  # List_Spacing[ 24] + 17.0; // 'XML Externer Lief. STW'
      List_Spacing[26]  # List_Spacing[ 25] + 17.0; // 'XML frei'




      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'BA'                          ,y , 0);
      LF_Set(2,  'Mat.'                        ,y , 0);
      LF_Set(3,  'Lieferant'                   ,n , 0);
      LF_Set(4,  'Dicke'                       ,y , 0);
      LF_Set(5,  'Breite'                      ,y , 0);
      LF_Set(6,  'Qualität'                    ,n , 0);
      LF_Set(7,  'Oberfläche'                  ,n , 0);
      LF_Set(8,  'Wgr.'                        ,y , 0);
      LF_Set(9,  'Gewicht'                     ,y , 0);
      LF_Set(10, 'komm. Gew.'                  ,y , 0);
      LF_Set(11, 'res. Gew.'                   ,y , 0);
      LF_Set(12, 'Lager Gew.'                  ,y , 0);
      LF_Set(13, '% komm.'                     ,y , 0);
      LF_Set(14, '% res.'                      ,y , 0);
      LF_Set(15, '% Lager'                      ,y , 0);
      LF_Set(16, '% Schrott'                   ,y , 0);

      if(List_XML)then begin
        LF_Set(17, 'Artikelnummer'        ,n , 0);
        LF_Set(18, 'Artikelgruppe'        ,y , 0);
        LF_Set(19, 'Arbeitsgang'             ,n , 0);
        LF_Set(20, 'Kosten €'             ,y , 0);
        LF_Set(21, 'pro MEH'              ,y , 0);
        LF_Set(22, 'Fixpreis €'           ,y , 0);
        LF_Set(23, 'Ext.Lieferant'        ,n , 0);
        LF_Set(24, ''                     ,y , 0);
        
      end;


    end;


    'MATERIAL' : begin
      if (aPrint) then begin
        LF_Text(1, AInt(BAG.IO.Nummer) + '/' + AInt(BAG.IO.NachPosition));

        // vor 2018-02-13 TM
        // LF_Sum(10, cMatFMKommGewB, Set.Stellen.Gewicht);
        // LF_Sum(11, cMatFMResGewB, Set.Stellen.Gewicht);
        // LF_Sum(12, cMatFMLagerGewB, Set.Stellen.Gewicht);


        LF_Sum(10, cMatFMKommGewN, Set.Stellen.Gewicht);
        LF_Sum(11, cMatFMResGewN, Set.Stellen.Gewicht);
        LF_Sum(12, cMatFMLagerGewN, Set.Stellen.Gewicht);


        vProzKomm     # 0.0;  // Prozente berechnen
        vProzRes      # 0.0;
        vProzLager    # 0.0;
        vProzSchrott  # 0.0;

        // vor 2018-02-13 TM
        // vProzKomm     # Lib_Berechnungen:Prozent(GetSum(cMatFMKommGewB), BAG.IO.Plan.In.GewB);
        // vProzRes      # Lib_Berechnungen:Prozent(GetSum(cMatFMResGewB), BAG.IO.Plan.In.GewB);
        // vProzLager    # Lib_Berechnungen:Prozent(GetSum(cMatFMLagerGewB), BAG.IO.Plan.In.GewB);

        vProzKomm     # Lib_Berechnungen:Prozent(GetSum(cMatFMKommGewN), BAG.IO.Plan.In.GewN);
        vProzRes      # Lib_Berechnungen:Prozent(GetSum(cMatFMResGewN), BAG.IO.Plan.In.GewN);
        vProzLager    # Lib_Berechnungen:Prozent(GetSum(cMatFMLagerGewN), BAG.IO.Plan.In.GewN);
        vProzSchrott  # Lib_Berechnungen:Prozent(gMatRestGew, BAG.IO.Plan.In.GewN);

        LF_Text(13, ANum(vProzKomm   ,2));
        LF_Text(14, ANum(vProzRes    ,2));
        LF_Text(15, ANum(vProzLager  ,2));
        LF_Text(16, ANum(vProzSchrott,2));

        
        LF_Text(21, AInt(BAG.P.Kosten.PEH)+' '+BAG.P.Kosten.MEH);
        LF_Text(23, vExtLief);
        
        if((List_XML = false) and (false)) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        RETURN;

      end;

      // Instanzieren...
      LF_Set(1,  '#BA-Nr./Pos.'             ,y , 0);
      LF_Set(2,  '@Mat.Nummer'              ,y , _LF_IntNG);
      LF_Set(3,  '@Mat.LieferStichwort'              ,n , 0);
      LF_Set(4,  '@Mat.Dicke'              ,y , _LF_Num3, Set.Stellen.Dicke);
      LF_Set(5,  '@Mat.Breite'              ,y , _LF_Num3, Set.Stellen.Breite);
      LF_Set(6,  '@Mat.Güte'              ,n , 0);
      LF_Set(7,  '@Mat.AusführungOben'              ,n , 0);
      LF_Set(8,  '@Mat.Warengruppe'              ,y , _LF_IntNG);
      LF_Set(9,  '@BAG.IO.Plan.In.GewB'              ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(10, '#Komm.Gew.'               ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(11, '#Res.Gew.'               ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(12, '#LagerGew.'               ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(13, '#ProzKomm'              ,y ,  _LF_Num, 2);
      LF_Set(14, '#ProzRes'              ,y , _LF_Num, 2);
      LF_Set(15, '#ProzLager'              ,y , _LF_Num, 2);
      LF_Set(16, '#ProzSchrott'              ,y ,  _LF_Num, 2);

      if(List_XML)then begin
        LF_Set(17,  '@Art.Nummer'              ,n , 0);
        LF_Set(18,  '@Art.Artikelgruppe'              ,y , _LF_IntNG);
        LF_Set(19, '@BAG.P.Aktion'             ,n , 0);
        LF_Set(20, '@BAG.P.Kosten.Pro'             ,y , _LF_Num, 2);
        LF_Set(21, '#BAG.P.Kosten.PEH BAG.P.Kosten.MEH'              ,y , 0);
        LF_Set(22, '@BAG.P.Kosten.Fix'           ,y , _LF_Num, 2);
        LF_Set(23, '#BAG.P.ExterneLiefNr'        ,n , 0);
        LF_Set(24, ''                     ,y , 0);
      
      
      end;

    end;

    'GESAMTSUMME' : begin
      if (aPrint) then begin
        LF_Sum(9,  cGesSumGewicht , Set.Stellen.Gewicht);
        LF_Sum(10, cGesSumKomGew  , Set.Stellen.Gewicht);
        LF_Sum(11, cGesSumResGew  , Set.Stellen.Gewicht);
        LF_Sum(12, cGesSumLagGew  , Set.Stellen.Gewicht);


        vProzKomm     # 0.0;  // Prozente berechnen
        vProzRes      # 0.0;
        vProzLager    # 0.0;
        vProzSchrott  # 0.0;
        vProzKomm     # Lib_Berechnungen:Prozent(GetSum(cGesSumKomGew), GetSum(cGesSumGewicht));
        vProzRes      # Lib_Berechnungen:Prozent(GetSum(cGesSumResGew), GetSum(cGesSumGewicht));
        vProzLager    # Lib_Berechnungen:Prozent(GetSum(cGesSumLagGew), GetSum(cGesSumGewicht));
        vProzSchrott  # Lib_Berechnungen:Prozent(GetSum(cGesSumSchrottGew), GetSum(cGesSumGewicht));

        LF_Text(13, ANum(vProzKomm   ,2));
        LF_Text(14, ANum(vProzRes    ,2));
        LF_Text(15, ANum(vProzLager  ,2));
        LF_Text(16, ANum(vProzSchrott,2));

        if((List_XML = false) and (false)) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        RETURN;
      end;

      LF_Format(_LF_Overline);
      // Instanzieren...
      LF_Set(9,  '#Gewicht'                 ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(10, '#Komm.Gew.'               ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(11, '#Res.Gew.'                ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(12, '#LagerGew.'               ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(13, '#ProzKomm'                ,y , _LF_Num, 2);
      LF_Set(14, '#ProzRes'                 ,y , _LF_Num, 2);
      LF_Set(15, '#ProzLager'               ,y , _LF_Num, 2);
      LF_Set(16, '#ProzSchrott'             ,y , _LF_Num, 2);

      /*
      if(List_XML)then begin
        LF_Set(17, '#Art.Nummer'              ,n , 0);
        LF_Set(18, '#Art.Artikelgruppe'      ,y , _LF_IntNG);
      end;
      */

    end;

  end;  // case

end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();   // Drucke grosse Überschrift
  LF_Print(g_Empty);

  if (aSeite=1) then begin
    LF_Print(g_Sel1);
    LF_Print(g_Sel2);

    LF_Print(g_Empty);
    LF_Print(g_Empty);
  end;

  LF_Print(g_Header);
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
  vOK         : logic;
  vTree       : int;
  vSortKey    : alpha;

  vQ702       : alpha(4000);
  vQ701       : alpha(4000);
  vQ200       : alpha(4000);
  vQ210       : alpha(4000);
  vQ201       : alpha(4000);
  vProgress   : handle;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen


  vQ702  # '';   // Arbeitsgang-Selektion
  Lib_Sel:QDate(var vQ702, 'BAG.P.Fertig.Dat', '>', 00.00.0000);
  if((Sel.von.Datum <> 00.00.0000) or (Sel.bis.Datum <> today)) then
    Lib_Sel:QVonBisD(var vQ702, 'BAG.P.Fertig.Dat', Sel.von.Datum, Sel.bis.Datum);

  if (Sel.BAG.Res.Gruppe <> 0)  then
    Lib_Sel:QInt(var vQ702, '"BAG.P.Ressource.Grp"',  '=', Sel.BAG.Res.Gruppe);
  if (Sel.BAG.Res.Nummer <> 0)  then
    Lib_Sel:QInt(var vQ702, '"BAG.P.Ressource"',      '=', Sel.BAG.Res.Nummer);


  Lib_Strings:Append(var vQ702, '(LinkCount(BagIO) > 0)', ' AND ');

  vQ701 # ''; // Input-Selektion
  if ("Sel.Mat.von.WGr" <> 0) or ("Sel.Mat.bis.WGr" <> 9999) then
    Lib_Sel:QVonBisI(var vQ701, '"BAG.IO.Warengruppe"', "Sel.Mat.von.WGr", "Sel.Mat.bis.WGr");
  Lib_Strings:Append(var vQ701, '( (LinkCount(Mat) > 0) OR (LinkCount(MatAbl) > 0) )', ' AND ');


  vQ200 # '';  // Material Selektion
  Lib_Sel:QInt(var vQ200, 'Mat.Nummer', '>', 0);
  if (Sel.Mat.ObfNr <> 0) or (Sel.Mat.ObfNr2 <> 999) then
  Lib_Strings:Append(var vQ200, '(LinkCount(MatAF) > 0)', ' AND ');

  vQ210 # '';  // ~Material Selektion
  Lib_Sel:QInt(var vQ210, '"Mat~Nummer"', '>', 0);
  if (Sel.Mat.ObfNr <> 0) or (Sel.Mat.ObfNr2 <> 999) then
  Lib_Strings:Append(var vQ210, '(LinkCount(MatAFAbl) > 0)', ' AND ');

  vQ201 # '';  // Material-Ausfuehrung Selektion
  if (Sel.Mat.ObfNr <> 0) or (Sel.Mat.ObfNr2 <> 999) then
    Lib_Sel:QVonBisI(var vQ201, 'Mat.Af.ObfNr', Sel.Mat.ObfNr, Sel.Mat.ObfNr2);


  vSel # SelCreate(702, 1);
  vSel->SelAddLink('', 701, 702, 2, 'BagIO');
  vSel->SelAddLink('BagIO', 200, 701, 9, 'Mat');
  vSel->SelAddLink('BagIO', 210, 701, 14, 'MatAbl');
  vSel->SelAddLink('Mat', 201, 200, 11, 'MatAF');
  vSel->SelAddLink('MatAbl', 201, 210, 11, 'MatAFAbl');
  Erx # vSel->SelDefQuery('', vQ702);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('BagIO', vQ701);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Mat', vQ200);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('MatAbl', vQ210);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('MatAF', vQ201);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('MatAFAbl', vQ201);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);


  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo(702, _recCount, vSel));

  FOR Erx # RecRead(702,vSel, _recFirst);
  LOOP Erx # RecRead(702,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN


    if (!vProgress->Lib_Progress:Step()) then begin  // Progress
      SelClose(vSel);
      SelDelete(702, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    FOR Erx # RecLink(701, 702, 2, _recFirst); // Input holen
    LOOP Erx # RecLink(701, 702, 2, _recNext);
    WHILE(Erx <= _rLocked) DO BEGIN

      if((BAG.IO.BruderID <> 0) or (BAG.IO.Materialtyp <> c_IO_Mat)) then // NUR ECHTES MATERIAL
        CYCLE;

      if(Mat_Data:Read(BAG.IO.Materialnr) = _rNoRec) then
        CYCLE;

      if (aSort=1) then   vSortKey # cnvAF(BAG.IO.Dicke,_FmtNumLeadZero|_fmtNumNoGroup, 0, 3, 8)
                                   + cnvAF(BAG.IO.Breite,_FmtNumLeadZero|_fmtNumNoGroup, 0, 2, 10)
                                   + cnvAF("BAG.IO.Länge",_FmtNumLeadZero|_fmtNumNoGroup, 0, 0, 12);
      if (aSort=2) then   vSortKey # cnvAI(BAG.IO.Materialnr, _FmtNumLeadZero, 0, 9)

      Sort_ItemAdd(vTree, vSortKey, 701, RecInfo(701, _RecId));
    END;
  END;
  SelClose(vSel);
  SelDelete(702, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Header    # LF_NewLine('HEADER');
  g_Material  # LF_NewLine('MATERIAL');
  g_GesSum    # LF_NewLine('GESAMTSUMME');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(y);    // Landscape

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID);     // Datensatz holen

   
      
    Mat_Data:Read(BAG.IO.Materialnr);

    // vor 2018-02-13 TM
    // ResetSum(cMatFMKommGewB);
    // ResetSum(cMatFMResGewB);
    // ResetSum(cMatFMLagerGewB);

    ResetSum(cMatFMKommGewN);
    ResetSum(cMatFMResGewN);
    ResetSum(cMatFMLagerGewN);

    FOR Erx # RecLink(707, 701, 12, _recFirst); // FM LOOPEN
    LOOP Erx # RecLink(707, 701, 12, _recNext);
    WHILE(Erx <= _rLocked) DO BEGIN
      Erx # RecLink(703, 707, 3, _recFirst); // AusFertigung
      if(Erx > _rLocked) then
        RecBufClear(707);

      // vor 2018-02-13 TM
      // if(BAG.F.Kommission <> '') then // Kommission
      //   AddSum(cMatFMKommGewB, BAG.FM.Gewicht.Brutt);
      // else if(BAG.F.ReservierenYN = true) then // Reserviert
      //   AddSum(cMatFMResGewB, BAG.FM.Gewicht.Brutt);
      // else  // Lager
      //   AddSum(cMatFMLagerGewB, BAG.FM.Gewicht.Brutt);

      if(BAG.F.Kommission <> '') then // Kommission
        AddSum(cMatFMKommGewN, BAG.FM.Gewicht.Netto);
      else if(BAG.F.ReservierenYN = true) then // Reserviert
        AddSum(cMatFMResGewN, BAG.FM.Gewicht.Netto);
      else  // Lager
        AddSum(cMatFMLagerGewN, BAG.FM.Gewicht.Netto);


    END;
  
     
    /*
    FOR Erx # RecLink(703, 701, 10, _recFirst); // NACH - FERTIGUNG LOOPEN
    LOOP Erx # RecLink(703, 701, 10, _recNext);
    WHILE(Erx <= _rLocked) DO BEGIN
      FOR Erx # RecLink(707, 703, 10, _recFirst); // FM LOOPEN
      LOOP Erx # RecLink(707, 703, 10, _recNext);
      WHILE(Erx <= _rLocked) DO BEGIN
        if(BAG.F.Kommission <> '') then
          AddSum(cMatFMKommGewB, BAG.FM.Gewicht.Brutt);
        else if(BAG.F.ReservierenYN = true) then
          AddSum(cMatFMResGewB, BAG.FM.Gewicht.Brutt);
      END;
    END;
    */

    gMatRestGew # 0.0;
    gBuf200 # RekSave(200);
    Mat_Data:Read(BAG.IO.MaterialRstNr); // Restgew. ermitteln ueber Restkarte

    // vor 2018-02-13 TM
    // gMatRestGew # Mat.Gewicht.Brutto;

    gMatRestGew # Mat.Gewicht.Netto;
    RekRestore(gBuf200);

    RekLink(250,200,26,0);      // ST 2014-11-19: GGf. Artikel lesen
    RekLink(702,701,4,0);       // BAG IO "nach" Position


    //  ST 2020-07-27 Ext Lief. lesen P: 2100/9
    vExtLief # '';
    if (BAG.P.ExterneLiefNr <> 0) then begin
      RekLink(100,702,7,0);
      vExtLief # Adr.Stichwort;
      
      if (BAG.P.ExterneLiefAns <> 0) then begin
        Adr.A.Adressnr # Adr.Nummer;
        Adr.A.Nummer  # BAG.P.ExterneLiefAns;
        Erx # RecRead(101,1,0);
        if (Erx <= _rLocked) then
          vExtLief # Adr.A.Stichwort;
      end;
    end;
    
    LF_Print(g_Material);

    // vor 2018-02-13 TM
    // AddSum(cGesSumGewicht   , BAG.IO.Plan.In.GewB);
    // AddSum(cGesSumKomGew    , GetSum(cMatFMKommGewB));
    // AddSum(cGesSumResGew    , GetSum(cMatFMResGewB));
    // AddSum(cGesSumLagGew    , GetSum(cMatFMLagerGewB));

    AddSum(cGesSumGewicht   , BAG.IO.Plan.In.GewN);
    AddSum(cGesSumKomGew    , GetSum(cMatFMKommGewN));
    AddSum(cGesSumResGew    , GetSum(cMatFMResGewN));
    AddSum(cGesSumLagGew    , GetSum(cMatFMLagerGewN));
    AddSum(cGesSumSchrottGew, gMatRestGew);
  END;

  LF_Print(g_GesSum);

  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Material);
  LF_FreeLine(g_GesSum);
end;

//========================================================================