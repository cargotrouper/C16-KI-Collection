@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Mat_200002
//                    OHNE E_R_G
//  Info        Bestandsliste
//
//
//
//  25.02.2010  AI  Erstellung der Prozedur
//  29.12.2011  ST  XML Ausgabe: Inventurdatum hinzugefügt
//  29.02.2012  MS  Anpassung an das neue Listenformat
//  01.04.2015  ST  BUG-Fix:  BasisEK/t wird ausgegeben und summiert, soll auch so  berechnet werden
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

declare StartList(aSort : int; aSortName : alpha);


local begin // Handles für die Zeilenelemente
  g_Sel1      : int;
  g_Sel2      : int;
  g_Sel3      : int;
  g_Sel4      : int;
  g_Sel5      : int;
  g_Sel6      : int;
  g_Sel7      : int;
  g_Empty     : int;
  g_Header    : int;
  g_Material  : int;
  g_Summe1    : int;
  g_Leselinie : logic;
end;

define begin
  cGesSumStk  : 1
  cGesSumGew  : 2
  cGesSumWert : 3
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Mat.ObfNr2         # 999;
  Sel.Mat.bis.WGr        # 9999;
  Sel.Mat.bis.Status     # 999;
  Sel.Mat.bis.Dicke      # 999999.00;
  Sel.Mat.bis.Breite     # 999999.00;
  "Sel.Mat.bis.Länge"    # 999999.00;
  "Sel.Mat.bis.ÜDatum"   # today;
  "Sel.Mat.bis.EDatum"   # today;
  "Sel.Mat.bis.ADatum"   # today;
  "Sel.Mat.EigenYN"      # y;
  "Sel.Mat.ReservYN"     # y;
  "Sel.Mat.BestelltYN"   # y;
  "Sel.Mat.!EigenYN"     # y;
  "Sel.Mat.!ReservYN"    # y;
  "Sel.Mat.!BestelltYN"  # y;
  "Sel.Mat.bis.ZugFest"  # 9999.0;
  "Sel.Art.bis.ArtNr"    # 'zzzzz';
  "Sel.Mat.bis.InvDatum" # today;

  List_FontSize          # 8;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.200002',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd(Translate('Bestellnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Chargennummer'));
  vHdl2->WinLstDatLineAdd(Translate('Coilnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Kommissionsnr.'));
  vHdl2->WinLstDatLineAdd(Translate('Kunden-Stichwort'));
  vHdl2->WinLstDatLineAdd(Translate('Lagerort-Stichwort'));
  vHdl2->WinLstDatLineAdd(Translate('Lieferanten-Stichwort'));
  vHdl2->WinLstDatLineAdd(Translate('Materialnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Qualität * Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Ringnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Warengruppe'));
  vHdl2->WinLstDatLineAdd(Translate('Werksnummer'));
  vHdl2->wpcurrentint # 1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end
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
  vLine : int;
  vObf  : alpha(120);
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
      LF_Set(7, 'Status'                                            ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      if (Sel.Mat.von.Status <> 0) then
        LF_Set(10, ZahlI(Sel.Mat.von.Status)                        ,n , _LF_INT);
      LF_Set(11, ' bis: '                                           ,n , 0);
      if (Sel.Mat.bis.Status <> 0) then
        LF_Set(12,  ZahlI(Sel.Mat.bis.Status)                       ,y , _LF_INT);
      if (Sel.Auf.bis.Wgr <> 0) then
        LF_Set(12,  ZahlI(Sel.Auf.bis.Wgr)                          ,y , _LF_INT);
      LF_Set(13, 'Güte'                                             ,n , 0);
      LF_Set(14, ': '                                               ,n , 0);
      LF_Set(16,  "Sel.Mat.Güte" +' ('+"Sel.Mat.Gütenstufe"+')'     ,n , 0);
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
      LF_Set(7, 'Lieferant'                                         ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(10, ZahlI(Sel.Mat.Lieferant)                           ,n , _LF_INT);
      LF_Set(13, 'Lagerort'                                         ,n , 0);
      LF_Set(14, ': '                                               ,n , 0);
      LF_Set(16, ZahlI(Sel.Mat.Lagerort)                            ,n , _LF_INT);
    end;


    'SEL3' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Dicke'                                             ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      LF_Set(4,  ZahlF(Sel.Mat.von.Dicke,Set.Stellen.Dicke)+'mm'    ,n , 0);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      LF_Set(6,  ZahlF(Sel.Mat.bis.Dicke,Set.Stellen.Dicke)+'mm'    ,y , 0);
      LF_Set(7, 'Breite'                                            ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      LF_Set(10, ZahlF(Sel.Mat.von.Breite,Set.Stellen.Breite)+'mm'  ,n , 0);
      LF_Set(11, ' bis: '                                           ,n , 0);
      LF_Set(12, ZahlF(Sel.Mat.bis.Breite,Set.Stellen.Breite)+'mm'  ,y , 0);
      LF_Set(13, 'Länge'                                            ,n , 0);
      LF_Set(14, ': '                                               ,n , 0);
      LF_Set(15, ' von: '                                           ,n , 0);
      LF_Set(16, ZahlF("Sel.Mat.von.Länge","Set.Stellen.Länge")+'mm',n , 0);
      LF_Set(17, ' bis: '                                           ,n , 0);
      LF_Set(18, ZahlF("Sel.Mat.bis.Länge","Set.Stellen.Länge")+'mm',y , 0);
     end;


    'SEL4' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Übernahme datum'                                   ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      if("Sel.Mat.von.ÜDatum" <> 0.0.0) then
        LF_Set(4,  DatS("Sel.Mat.von.ÜDatum")                       ,n ,_LF_Date);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      if("Sel.Mat.bis.ÜDatum" <> 0.0.0) then
        LF_Set(6,  DatS("Sel.Mat.bis.ÜDatum")                       ,y , _LF_Date);
      LF_Set(7, 'Eingangs datum'                                    ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      if(Sel.Mat.von.EDatum <> 0.0.0) then
        LF_Set(10, DatS(Sel.Mat.von.EDatum)                         ,n , _LF_Date);
      LF_Set(11, ' bis: '                                           ,n , 0);
      if(Sel.Mat.bis.EDatum <> 0.0.0) then
        LF_Set(12, DatS(Sel.Mat.bis.EDatum)                         ,y , _LF_Date);
      LF_Set(13, 'Ausgabe datum'                                    ,n , 0);
      LF_Set(14, ': '                                               ,n , 0);
      LF_Set(15, ' von: '                                           ,n , 0);
      if(Sel.Mat.von.ADatum <> 0.0.0) then
        LF_Set(16, DatS(Sel.Mat.von.ADatum)                         ,n , _LF_Date);
      LF_Set(17, ' bis: '                                           ,n , 0);
      if(Sel.Mat.bis.ADatum <> 0.0.0) then
        LF_Set(18, DatS(Sel.Mat.bis.ADatum)                         ,y , _LF_Date);
    end;


    'SEL5' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Inventur datum'                                   ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      if("Sel.Mat.von.InvDatum" <> 0.0.0) then
        LF_Set(4,  DatS("Sel.Mat.von.InvDatum")                       ,n ,_LF_Date);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      if("Sel.Mat.bis.InvDatum" <> 0.0.0) then
        LF_Set(6,  DatS("Sel.Mat.bis.InvDatum")                       ,y , _LF_Date);
    end;


    'SEL6' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      if(Sel.Mat.EigenYN = y) then begin
        LF_Set(1, 'Eigenes Material'  ,n , 0);
        LF_Set(2, ' : '  ,n , 0);
        LF_Set(4, '   y'  ,n , 0);
      end
      else begin
        LF_Set(1, 'Eigenes Material' ,n , 0);
        LF_Set(2, ' : '  ,n , 0);
        LF_Set(4, '   n'  ,n , 0);
      end;
          if(Sel.Mat.ReservYN = y) then begin
        LF_Set(7, 'Reserviert'  ,n , 0);
        LF_Set(8, ' : '  ,n , 0);
        LF_Set(10, '   y'  ,n , 0);
      end
      else begin
        LF_Set(7, 'Reserviert' ,n , 0);
        LF_Set(8, ' : '  ,n , 0);
        LF_Set(10, '   n'  ,n , 0);
      end;
          if(Sel.Mat.BestelltYN  = y) then begin
        LF_Set(13, 'Bestellt'  ,n , 0);
        LF_Set(14, ' : '  ,n , 0);
        LF_Set(16, '   y'  ,n , 0);
      end
      else begin
        LF_Set(13, 'Bestellt' ,n , 0);
        LF_Set(14, ' : '  ,n , 0);
        LF_Set(16, '   n'  ,n , 0);
      end;
    end;


    'SEL7' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      if("Sel.Mat.!EigenYN" = y) then begin
        LF_Set(1, 'Fremdes Material'  ,n , 0);
        LF_Set(2, ' : '  ,n , 0);
        LF_Set(4, '   y'  ,n , 0);
      end
      else begin
        LF_Set(1, 'Fremdes Material' ,n , 0);
        LF_Set(2, ' : '  ,n , 0);
        LF_Set(4, '   n'  ,n , 0);
      end;
          if("Sel.Mat.!ReservYN" = y) then begin
        LF_Set(7, 'frei verfügbar'  ,n , 0);
        LF_Set(8, ' : '  ,n , 0);
        LF_Set(10, '   y'  ,n , 0);
      end
      else begin
        LF_Set(7, 'frei verfügbar: n' ,n , 0);
        LF_Set(8, ' : '  ,n , 0);
        LF_Set(10, '   n'  ,n , 0);
      end;
          if("Sel.Mat.!BestelltYN" = y) then begin
        LF_Set(13, 'im Bestand'  ,n , 0);
        LF_Set(14, ' : '  ,n , 0);
        LF_Set(16, '   y'  ,n , 0);
      end
      else begin
        LF_Set(13, 'im Bestand' ,n , 0);
        LF_Set(14, ' : '  ,n , 0);
        LF_Set(16, '   y'  ,n , 0);
      end;
    end;


    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  +  20.0;  // 'Mat.Nr.'
      List_Spacing[ 3]  # List_Spacing[ 2]  +  20.0;  // 'BestellNr.'
      List_Spacing[ 4]  # List_Spacing[ 3]  +  10.0;  // 'WGr.'
      List_Spacing[ 5]  # List_Spacing[ 4]  +  15.0;  // 'Prj.Nr.'
      List_Spacing[ 6]  # List_Spacing[ 5]  +  30.0;  // 'Lieferant'
      List_Spacing[ 7]  # List_Spacing[ 6]  +  15.0;  // 'Stk.'
      List_Spacing[ 8]  # List_Spacing[ 7]  +  25.0;  // 'Bestand kg'
      List_Spacing[ 9]  # List_Spacing[ 8]  +  15.0;  // 'Status'
      List_Spacing[10]  # List_Spacing[ 9]  +  25.0;  // 'Warenein.dat.'
      List_Spacing[11]  # List_Spacing[ 10] +  30.0;  // 'Lagerort'
      List_Spacing[12]  # List_Spacing[ 11] +  23.0;  // 'CoilNr.'
      List_Spacing[13]  # List_Spacing[ 12] +  20.0;  // 'EK €/t'
      List_Spacing[14]  # List_Spacing[ 13] +  25.0;  // 'Gesamtwert'
      List_Spacing[15]  # List_Spacing[ 14] +  20.0;  //
      List_Spacing[16]  # List_Spacing[ 15] +  20.0;  //
      List_Spacing[17]  # List_Spacing[ 16] +  20.0;  //
      List_Spacing[18]  # List_Spacing[ 17] +  20.0;  //

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Mat.Nr.'                                       ,y , 0);
      LF_Set(2,  'BestellNr.'                                    ,n , 0);
      LF_Set(3,  'WGr.'                                          ,y , 0);
      LF_Set(4,  'Prj.Nr.'                                       ,y , 0);
      LF_Set(5,  'Lieferant'                                     ,n , 0);
      LF_Set(6,  'Stk.'                                          ,y , 0);
      LF_Set(7,  'Bestand kg'                                    ,y , 0);
      LF_Set(8,  'Status'                                        ,y , 0);
      LF_Set(9,  'Warenein.dat.'                                 ,n , 0);
      LF_Set(10, 'Lagerort'                                      ,n , 0);
      LF_Set(11, 'CoilNr.'                                       ,n , 0);
      LF_Set(12, 'EK €/t'                                        ,y , 0);
      LF_Set(13, 'Wert'                                          ,y , 0);
    end;


    'MATERIAL' : begin
      if (aPrint) then begin
        LF_Text(5,  StrCut(Mat.LieferStichwort, 1, 9));          // Lieferant
        LF_Text(10, StrCut(Mat.LagerStichwort, 1, 9));

        // ST 2015-04-01: BUG:  BasisEK/t wird ausgegeben und summiert, soll auch so
        //                      berechnet werden
        // LF_Text(13, ZahlF(Mat.EK.Effektiv * Mat.Bestand.Gew / 1000.0, 2));
        LF_Text(13, ZahlF(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0, 2));

        if(List_XML = false)or (false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        RETURN;

      end;

      // Instanzieren...
      LF_Set(1,  '@Mat.Nummer'            ,y , _LF_IntNG);
      LF_Set(2,  '@Mat.Bestellnummer'     ,n , 0);
      LF_Set(3,  '@Mat.Warengruppe'       ,y , _LF_IntNG);
      LF_Set(4,  '@Mat.EK.Projektnr'      ,y , _LF_IntNG);
      LF_Set(5,  '#Mat.LieferStichwort'   ,n , 0);          // Lieferant
      LF_Set(6,  '@Mat.Bestand.Stk'       ,y , _LF_IntNG);
      LF_Set(7,  '@Mat.Bestand.Gew'       ,y , _LF_Num3, Set.Stellen.Gewicht);
      LF_Set(8,  '@Mat.Status'            ,y , _LF_IntNG);
      LF_Set(9,  '@Mat.Eingangsdatum'     ,n , _LF_Date);
      LF_Set(10, '#Mat.LagerStichwort'    ,n , 0);
      LF_Set(11, '@Mat.Coilnummer'        ,n , 0);
      LF_Set(12, '@Mat.EK.Preis'          ,y , _LF_Wae, 2);
      LF_Set(13, '#Gesamtwert'            ,y , _LF_Wae, 2); // Gesamtwert
    end;


    'SUMME1' : begin
      if (aPrint) then begin
        LF_Sum(6 , cGesSumStk , 0);
        LF_Sum(7 , cGesSumGew , Set.Stellen.Gewicht);
        LF_Sum(13, cGesSumWert, 2);
        RETURN;
      end;

      // Instanzieren...
      LF_Format(_LF_Overline);
      LF_Set(6,  '#Stueck'                  ,y , _LF_INT);
      LF_Set(7,  '#Gewicht'                 ,y , _LF_NUM, Set.Stellen.Gewicht);
      LF_Set(13, '#Wert'                    ,y , _LF_WAE);
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
    LF_Print(g_Sel3);
    LF_Print(g_Sel4);
    LF_Print(g_Sel5);
    LF_Print(g_Sel6);
    LF_Print(g_Sel7);
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

  vQ          : alpha(4000);
  vQ1         : alpha(4000);
  vProgress   : handle;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // BESTAND-Selektion
  vQ  # '';
  vQ1 # '';

  if ("Sel.Mat.von.Dicke"  != 0.0) or ("Sel.Mat.bis.Dicke"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat.Dicke"',         "Sel.Mat.von.Dicke", "Sel.Mat.bis.Dicke");
  if ("Sel.Mat.von.Breite" != 0.0) or ("Sel.Mat.bis.Breite" != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat.Breite"',        "Sel.Mat.von.Breite", "Sel.Mat.bis.Breite");
  if ("Sel.Mat.von.Länge"  != 0.0) or ("Sel.Mat.bis.Länge"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat.Länge"',         "Sel.Mat.von.Länge", "Sel.Mat.bis.Länge");
  if ("Sel.Mat.von.ÜDatum" != 0.0.0) or ("Sel.Mat.bis.ÜDatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat.Übernahmedatum"', "Sel.Mat.von.ÜDatum", "Sel.Mat.bis.ÜDatum", 'AND NOT');
  //if ("Sel.Mat.von.EDatum" != 0.0.0) or ("Sel.Mat.bis.EDatum" != today) then begin
  if (1!=2) then begin
    if(vQ <> '') then
      vQ # vQ + ' AND ';
    vQ # vQ + '((("Mat.Eingangsdatum" >= "Sel.Mat.von.EDatum") AND ("Mat.Eingangsdatum" <= "Sel.Mat.bis.EDatum")) OR (("Mat.Datum.Erzeugt" >= "Sel.Mat.von.EDatum") AND ("Mat.Datum.Erzeugt" <= "Sel.Mat.bis.EDatum")))'
    //Lib_Sel:QVonBisD(var vQ, '"Mat.Eingangsdatum"', "Sel.Mat.von.EDatum", "Sel.Mat.bis.EDatum");
    //Lib_Sel:QVonBisD(var vQ, '"Mat.Datum.Erzeugt"', "Sel.Mat.von.EDatum", "Sel.Mat.bis.EDatum", 'OR');
    //vQ # vQ + ')'
  end;
  if ("Sel.Mat.von.InvDatum" != 0.0.0) or ("Sel.Mat.bis.InvDatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat.Inventurdatum"', "Sel.Mat.von.InvDatum", "Sel.Mat.bis.InvDatum");
  if ("Sel.Mat.von.ADatum" != 0.0.0) or ("Sel.Mat.bis.ADatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat.Ausgangsdatum"', "Sel.Mat.von.ADatum", "Sel.Mat.bis.ADatum");
  if ("Sel.Mat.von.Status" != 0) or ("Sel.Mat.bis.Status" != 999) then
    Lib_Sel:QVonBisI(var vQ, '"Mat.Status"',        "Sel.Mat.von.Status", "Sel.Mat.bis.Status");
  if ("Sel.Mat.von.WGr"    != 0) or ("Sel.Mat.bis.WGr"    != 9999) then
    Lib_Sel:QVonBisI(var vQ, '"Mat.Warengruppe"',   "Sel.Mat.von.WGr",    "Sel.Mat.bis.WGr");
  if ("Sel.Art.von.ArtNr"  != '') or ("Sel.Art.bis.ArtNr"  != 'zzzzz') then
    Lib_Sel:QVonBisA(var vQ, '"Mat.Strukturnr"',    "Sel.Art.von.ArtNr",  "Sel.Art.bis.ArtNr");

  if (!"Sel.Mat.mit.gelöscht") then
    Lib_Sel:QAlpha(var vQ, '"Mat.Löschmarker"', '=', '');
  if ("Sel.Mat.Güte" != '') then
    Lib_Sel:QAlpha(var vQ, '"Mat.Güte"', '=*', "Sel.Mat.Güte");
  if ("Sel.Mat.Gütenstufe" != '') then
    Lib_Sel:QAlpha(var vQ, '"Mat.Gütenstufe"', '=*', "Sel.Mat.Gütenstufe");
  if (Sel.Mat.Strukturnr != '') then
    Lib_Sel:QAlpha(var vQ, 'Mat.Strukturnr', '=', Sel.Mat.Strukturnr);
  if (Sel.Mat.Lieferant != 0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lieferant', '=', Sel.Mat.Lieferant);
  if (Sel.Mat.Lagerort != 0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageradresse', '=', Sel.Mat.Lagerort);
  if (Sel.Mat.LagerAnschri != 0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageranschrift', '=', Sel.Mat.LagerAnschri);
  if (Sel.Mat.ObfNr != 0) then
    vQ # vQ + ' AND LinkCount(Ausf) > 0';

  if ("Sel.Mat.EigenYN") AND (!"Sel.Mat.!EigenYN") then
    Lib_Sel:QLogic(var vQ, 'Mat.EigenmaterialYN', y);
  else if (!"Sel.Mat.EigenYN") AND ("Sel.Mat.!EigenYN") then
    Lib_Sel:QLogic(var vQ, 'Mat.EigenmaterialYN', n);

  if ("Sel.Mat.BestelltYN") and (!"Sel.Mat.!BestelltYN") then
    Lib_Sel:QFloat(var vQ, '"Mat.Bestellt.Gew"', '>', 0.0);
  else if (!"Sel.Mat.BestelltYN") and ("Sel.Mat.!BestelltYN") then begin
    Lib_Sel:QFloat(var vQ, '"Mat.Bestellt.Gew"', '=', 0.0);
    Lib_Sel:QFloat(var vQ, '"Mat.Bestand.Gew"', '<>', 0.0);
    Lib_Sel:QDate(var vQ, '"Mat.Eingangsdatum"', '>', 00.00.0000); // kein VSB
  end

  if ("Sel.Mat.ReservYN") and (!"Sel.Mat.!ReservYN") then
    vQ # vQ + ' AND Mat.Reserviert.Gew > 0';
  else if (!"Sel.Mat.ReservYN") and ("Sel.Mat.!ReservYN") then
    vQ # vQ + ' AND Mat.Reserviert.Gew = 0';

  if ("Sel.Mat.KommissionYN") and (!"Sel.Mat.!KommissioYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + '(Mat.Auftragsnr > 0)';
    end
  else if (!"Sel.Mat.KommissionYN") and ("Sel.Mat.!KommissioYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + '(Mat.Auftragsnr = 0)';
  end;

  if (Sel.Mat.von.ZugFest<>0.0) or (Sel.Mat.bis.Zugfest<>9999.0) then
    vQ # vQ + ' AND (Mat.Zugfestigkeit1 = 0 OR Mat.Zugfestigkeit1 between[' + CnvAF(Sel.Mat.von.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + ',' + CnvAF(Sel.Mat.bis.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + '])';

  if (Sel.Mat.ObfNr != 0) or (Sel.Mat.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ1, 'Mat.Af.ObfNr', Sel.Mat.ObfNr, Sel.Mat.ObfNr2);

  vSel # SelCreate(200, 1);
  vSel->SelAddLink('', 201, 200, 11, 'Ausf');
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Ausf', vQ1);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init('Sortierung', RecInfo(200, _recCount, vSel));
  FOR Erx # RecRead(200,vSel, _recFirst);
  LOOP Erx # RecRead(200,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(200, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    if (aSort=1) then   vSortKey # cnvAF(Mat.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)+cnvAF(Mat.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Mat.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    if (aSort=2) then   vSortKey # cnvAI(Mat.Einkaufsnr,_FmtNumLeadZero,0,13)
    if (aSort=3) then   vSortKey # Mat.Chargennummer
    if (aSort=4) then   vSortKey # Mat.Coilnummer
    if (aSort=5) then   vSortKey # Mat.Kommission
    if (aSort=6) then   vSortKey # Mat.KommKundenSWort
    if (aSort=7) then   vSortKey # Mat.LagerStichwort
    if (aSort=8) then   vSortKey # Mat.LieferStichwort
    if (aSort=9) then   vSortKey # cnvAI(Mat.Nummer,_FmtNumLeadZero,0,9)
    if (aSort=10) then  vSortKey # "Mat.Güte"+cnvAF(Mat.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)+cnvAF(Mat.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Mat.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    if (aSort=11) then  vSortKey # Mat.Ringnummer
    if (aSort=12) then  vSortKey # Mat.Werksnummer
    if (aSort=13) then  vSortKey # Mat.Strukturnr
    Sort_ItemAdd(vTree,vSortKey,200,RecInfo(200,_RecId));
  END;
  SelClose(vSel);
  SelDelete(200, vSelName);
  vSel # 0;
  vProgress->Lib_Progress:Term();

  // ABLAGE-Selektion
  vQ  # '';
  vQ1 # '';

  if ("Sel.Mat.von.Dicke"  != 0.0) or ("Sel.Mat.bis.Dicke"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat~Dicke"',         "Sel.Mat.von.Dicke", "Sel.Mat.bis.Dicke");
  if ("Sel.Mat.von.Breite" != 0.0) or ("Sel.Mat.bis.Breite" != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat~Breite"',        "Sel.Mat.von.Breite", "Sel.Mat.bis.Breite");
  if ("Sel.Mat.von.Länge"  != 0.0) or ("Sel.Mat.bis.Länge"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat~Länge"',         "Sel.Mat.von.Länge", "Sel.Mat.bis.Länge");
  if ("Sel.Mat.von.ÜDatum" != 0.0.0) or ("Sel.Mat.bis.ÜDatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat~Übernahmedatum"', "Sel.Mat.von.ÜDatum", "Sel.Mat.bis.ÜDatum");

  //if ("Sel.Mat.von.EDatum" != 0.0.0) or ("Sel.Mat.bis.EDatum" != today) then
    //Lib_Sel:QVonBisD(var vQ, '"Mat~Eingangsdatum"', "Sel.Mat.von.EDatum", "Sel.Mat.bis.EDatum");

  if ("Sel.Mat.von.EDatum" != 0.0.0) or ("Sel.Mat.bis.EDatum" != today) then begin
    if(vQ <> '') then
      vQ # vQ + ' AND ';
    vQ # vQ + '((("Mat~Eingangsdatum" >= "Sel.Mat.von.EDatum") AND ("Mat~Eingangsdatum" <= "Sel.Mat.bis.EDatum")) OR (("Mat~Datum.Erzeugt" >= "Sel.Mat.von.EDatum") AND ("Mat~Datum.Erzeugt" <= "Sel.Mat.bis.EDatum")))'
  end;

  if ("Sel.Mat.von.ADatum" != 0.0.0) or ("Sel.Mat.bis.ADatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat~Ausgangsdatum"', "Sel.Mat.von.ADatum", "Sel.Mat.bis.ADatum");
  if ("Sel.Mat.von.InvDatum" != 0.0.0) or ("Sel.Mat.bis.InvDatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat~Inventurdatum"', "Sel.Mat.von.InvDatum", "Sel.Mat.bis.InvDatum");
  if ("Sel.Mat.von.Status" != 0) or ("Sel.Mat.bis.Status" != 999) then
    Lib_Sel:QVonBisI(var vQ, '"Mat~Status"',        "Sel.Mat.von.Status", "Sel.Mat.bis.Status");
  if ("Sel.Mat.von.WGr"    != 0) or ("Sel.Mat.bis.WGr"    != 9999) then
    Lib_Sel:QVonBisI(var vQ, '"Mat~Warengruppe"',   "Sel.Mat.von.WGr",    "Sel.Mat.bis.WGr");
  if ("Sel.Art.von.ArtNr"  != '') or ("Sel.Art.bis.ArtNr"  != 'zzzzz') then
    Lib_Sel:QVonBisA(var vQ, '"Mat~Strukturnr"',    "Sel.Art.von.ArtNr",  "Sel.Art.bis.ArtNr");

  if (!"Sel.Mat.mit.gelöscht") then
    Lib_Sel:QAlpha(var vQ, '"Mat~Löschmarker"', '=', '');
  if ("Sel.Mat.Güte" != '') then
    Lib_Sel:QAlpha(var vQ, '"Mat~Güte"', '=*', "Sel.Mat.Güte");
  if (Sel.Mat.Strukturnr != '') then
    Lib_Sel:QAlpha(var vQ, '"Mat~Strukturnr"', '=', Sel.Mat.Strukturnr);
  if (Sel.Mat.Lieferant != 0) then
    Lib_Sel:QInt(var vQ, '"Mat~Lieferant"', '=', Sel.Mat.Lieferant);
  if (Sel.Mat.Lagerort != 0) then
    Lib_Sel:QInt(var vQ, '"Mat~Lageradresse"', '=', Sel.Mat.Lagerort);
  if (Sel.Mat.ObfNr != 0) then
    vQ # vQ + ' AND LinkCount(Ausf) > 0';

  if ("Sel.Mat.EigenYN") AND (!"Sel.Mat.!EigenYN") then
    vQ # vQ + ' AND "Mat~EigenmaterialYN"';
  else if (!"Sel.Mat.EigenYN") AND ("Sel.Mat.!EigenYN") then
    vQ # vQ + ' AND !"Mat~EigenmaterialYN"';

  if ("Sel.Mat.ReservYN") and (!"Sel.Mat.!ReservYN") then
    vQ # vQ + ' AND "Mat~Reserviert.Gew" > 0';
  else if (!"Sel.Mat.ReservYN") and ("Sel.Mat.!ReservYN") then
    vQ # vQ + ' AND "Mat~Reserviert.Gew" = 0';

  if ("Sel.Mat.KommissionYN") and (!"Sel.Mat.!KommissioYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + '("Mat~Auftragsnr" > 0)';
    end
  else if (!"Sel.Mat.KommissionYN") and ("Sel.Mat.!KommissioYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + '("Mat~Auftragsnr" = 0)';
  end;

  if (Sel.Mat.von.ZugFest<>0.0) or (Sel.Mat.bis.Zugfest<>9999.0) then
    vQ # vQ + ' AND ("Mat~Zugfestigkeit1" = 0 OR "Mat~Zugfestigkeit1" between[' + CnvAF(Sel.Mat.von.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + ',' + CnvAF(Sel.Mat.bis.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + '])';

  if (Sel.Mat.ObfNr != 0) or (Sel.Mat.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ1, 'Mat.Af.ObfNr', Sel.Mat.ObfNr, Sel.Mat.ObfNr2);


  vSel # SelCreate(210, 1);
  vSel->SelAddLink('', 201, 210, 11, 'Ausf');
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Ausf', vQ1);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);
  vProgress # Lib_Progress:Init('Sortierung', RecInfo(210, _recCount, vSel));

  FOR Erx # RecRead(210, vSel, _recFirst);
  LOOP Erx # RecRead(210, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(210, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    if (aSort=1) then   vSortKey # cnvAF("Mat~Dicke",_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)+cnvAF("Mat~Breite",_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Mat~Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    if (aSort=2) then   vSortKey # cnvAI("Mat~Einkaufsnr",_FmtNumLeadZero,0,13)
    if (aSort=3) then   vSortKey # "Mat~Chargennummer"
    if (aSort=4) then   vSortKey # "Mat~Coilnummer"
    if (aSort=5) then   vSortKey # "Mat~Kommission"
    if (aSort=6) then   vSortKey # "Mat~KommKundenSWort"
    if (aSort=7) then   vSortKey # "Mat~LagerStichwort"
    if (aSort=8) then   vSortKey # "Mat~LieferStichwort"
    if (aSort=9) then   vSortKey # cnvAI("Mat~Nummer",_FmtNumLeadZero,0,9)
    if (aSort=10) then  vSortKey # "Mat~Güte"+cnvAF("Mat~Dicke",_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)+cnvAF("Mat~Breite",_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Mat~Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    if (aSort=11) then  vSortKey # "Mat~Ringnummer"
    if (aSort=12) then  vSortKey # "Mat~Werksnummer"
    if (aSort=13) then  vSortKey # "Mat~Strukturnr"
    Sort_ItemAdd(vTree,vSortKey,210,RecInfo(210,_RecId));
  END;
  SelClose(vSel);
  SelDelete(210, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Sel3      # LF_NewLine('SEL3');
  g_Sel4      # LF_NewLine('SEL4');
  g_Sel5      # LF_NewLine('SEL5');
  g_Sel6      # LF_NewLine('SEL6');
  g_Sel7      # LF_NewLine('SEL7');
  g_Header    # LF_NewLine('HEADER');
  g_Material  # LF_NewLine('MATERIAL');
  g_Summe1    # LF_NewLine('SUMME1');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    if (!vProgress->Lib_Progress:Step()) then begin     // Progress
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen

    if (cnvIA(vItem->spCustom) = 210) then // Ablage?
      RecBufCopy(210, 200);

    LF_Print(g_Material);

    AddSum(cGesSumStk , cnvFI(Mat.Bestand.Stk));
    AddSum(cGesSumGew , Mat.Bestand.Gew);
    AddSum(cGesSumWert,(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0));
  END;

  LF_Print(g_Summe1);

  Sort_KillList(vTree);   // Löschen der Liste

  vProgress->Lib_Progress:Term();  // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Sel3);
  LF_FreeLine(g_Sel4);
  LF_FreeLine(g_Sel5);
  LF_FreeLine(g_Sel6);
  LF_FreeLine(g_Sel7);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Material);
  LF_FreeLine(g_Summe1);

end;

//========================================================================