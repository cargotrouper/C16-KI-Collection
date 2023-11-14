@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Mat_200010
//                    OHNE E_R_G
//  Info        Material zum Stichtag (aus Transfer 200514)
//
//
//  27.08.2014  AH  Anlage
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
@I:Def_List2

declare StartList(aSort : int; aSortName : alpha);

// Handles für die Zeilenelemente
local begin
  g_Empty     : int;
  g_Sel1      : int;
  g_Sel2      : int;
  g_Sel3      : int;
  g_Sel4      : int;

  g_Header    : int;
  g_Material  : int;
  g_Summe1    : int;
  g_Summe2    : int;
  g_Leselinie : logic;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Mat.ObfNr2        # 999;
  Sel.Mat.von.Wgr       # 0;
  Sel.Mat.bis.WGr       # 9999;
  Sel.Mat.bis.Status    # 999;
  Sel.Mat.bis.Dicke     # 999999.00;
  Sel.Mat.bis.Breite    # 999999.00;
  "Sel.Mat.bis.Länge"   # 999999.00;
  Sel.Mat.von.Obfzusat  # 'zzzzz';


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.200010',here+':AusSel');
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

  if (Sel.Von.Datum=0.0.0) then begin
    Msg(99,'Stichtag fehlt!',0,0,0);
    RETURN;
  end;

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
  vHdl2->wpcurrentint#1;
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
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  Erx   : int;
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
      List_FontSize           # 7;

      // Instanzieren...
      List_Spacing[ 1]  #   0.0;                      // Linker Rand 0.0
      List_Spacing[ 2]  #   List_Spacing[ 1]  + 16.0;
      List_Spacing[ 3]  #   List_Spacing[ 2]  +  2.0;
      List_Spacing[ 4]  #   List_Spacing[ 3]  +  6.0;
      List_Spacing[ 5]  #   List_Spacing[ 4]  + 19.0;
      List_Spacing[ 6]  #   List_Spacing[ 5]  +  6.0;

      List_Spacing[ 7]  #   List_Spacing[ 6]  + 20.0;
      List_Spacing[ 8]  #   List_Spacing[ 7]  + 19.0;
      List_Spacing[ 9]  #   List_Spacing[ 8]  +  2.0;
      List_Spacing[10]  #   List_Spacing[ 9]  +  6.0;
      List_Spacing[11]  #   List_Spacing[10]  + 19.0;
      List_Spacing[12]  #   List_Spacing[11]  +  6.0;

      List_Spacing[13]  #   List_Spacing[12]  + 18.0;
      List_Spacing[14]  #   List_Spacing[13]  + 19.0;
      List_Spacing[15]  #   List_Spacing[14]  +  6.0;
      List_Spacing[16]  #   List_Spacing[15]  +  8.0;
      List_Spacing[17]  #   List_Spacing[16]  + 19.0;
      List_Spacing[18]  #   List_Spacing[17]  +  6.0;

      List_Spacing[19]  #   List_Spacing[18]  +   18.0;
      List_Spacing[20]  #   List_Spacing[19]  +   19.0;
      List_Spacing[21]  #   List_Spacing[20]  +   2.0;
      List_Spacing[22]  #   List_Spacing[21]  +   6.0;
      List_Spacing[23]  #   List_Spacing[22]  +   19.0;
      List_Spacing[24]  #   List_Spacing[23]  +   6.0; // Rechter Rand 293.0

      LF_Set(1, 'Stichtag'                                          ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3, ''                                                  ,n , 0);
      LF_Set(4, DatS(Sel.Von.Datum)                                 ,n , _LF_Date);
    end;


    'SEL2' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
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


      LF_Set(19, 'Oberfläche'                                        ,n , 0);
      LF_Set(20,  ': '                                               ,n , 0);
      LF_Set(21,  ' von: '                                           ,n , 0);
      LF_Set(22, ZahlI(Sel.Mat.ObfNr)                                ,n , _LF_INT);
      LF_Set(23,  ' bis: '                                           ,n , 0);
      LF_Set(24, ZahlI(Sel.Mat.ObfNr2)                               ,n , _LF_INT);

    end;


    'SEL3' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Lieferant'                                         ,n , 0);
      LF_Set(2, ': '                                                ,n , 0);
      LF_Set(4, ZahlI(Sel.Mat.Lieferant)                           ,n , _LF_INT);

      LF_Set(13, 'Lagerort'                                         ,n , 0);
      LF_Set(14, ': '                                               ,n , 0);
      LF_Set(16, ZahlI(Sel.Mat.Lagerort)                            ,n , _LF_INT);
      if (Sel.Mat.LagerAnschri >0) then
        LF_Set(17, ' Anschr.: '                                           ,n , 0);
      LF_Set(18, ZahlI("Sel.Mat.LagerAnschri")                      ,n , _LF_INT);
    end;


    'SEL4' : begin

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


    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 14.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  + 16.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  + 14.5;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 17.5;
      List_Spacing[ 6]  # List_Spacing[ 5]  + 17.5;
      List_Spacing[ 7]  # List_Spacing[ 6]  + 24.5;
      List_Spacing[ 8]  # List_Spacing[ 7]  + 10.0;
      List_Spacing[ 9]  # List_Spacing[ 8]  + 12.5;
      List_Spacing[10]  # List_Spacing[ 9]  + 21.0;
      List_Spacing[11]  # List_Spacing[ 10] + 21.0;
      List_Spacing[12]  # List_Spacing[ 11] + 12.5;
      List_Spacing[13]  # List_Spacing[ 12] + 23.0;
      List_Spacing[14]  # List_Spacing[ 13] + 23.0;
      List_Spacing[15]  # List_Spacing[ 14] + 17.0;
      List_Spacing[16]  # List_Spacing[ 15] + 17.0;
      List_Spacing[17]  # List_Spacing[ 16] + 21.0;
      List_Spacing[18]  # List_Spacing[ 17] +  6.0;

      List_Spacing[19]  # List_Spacing[ 18] + 1.0;
      List_Spacing[20]  # List_Spacing[ 19] + 1.0;
      List_Spacing[22]  # List_Spacing[ 20] + 1.0;
      List_Spacing[23]  # List_Spacing[ 22] + 1.0;
      List_Spacing[24]  # List_Spacing[ 23] + 1.0;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Mat.Nr.'                                ,y , 0);
      LF_Set(2,  'Qualität'                               ,n , 0);
      LF_Set(3,  'Dicke'                                  ,y , 0);
      LF_Set(4,  'Breite'                                 ,y , 0);
      LF_Set(5,  'Länge'                                  ,y , 0);
      LF_Set(6,  'Coilnr.'                                ,n , 0);
      LF_Set(7,  'WGr.'                                   ,y , 0);
      LF_Set(8,  'Stat'                                   ,y , 0);
      LF_Set(9,  'Lieferant'                              ,n , 0);
      LF_Set(10, 'Lagerort'                               ,n , 0);
      LF_Set(11, 'Stk'                                    ,y , 0);
      LF_Set(12, 'Bstnd kg'                               ,y , 0);
      LF_Set(13, ''                                       ,y , 0);
      LF_Set(14, 'EK EUR/t'                               ,y , 0);
      LF_Set(15, 'EK eff.'                                ,y , 0);
      LF_Set(16, 'Gesamtwert'                             ,y , 0);
      if (List_XML) then begin
        LF_Set(17, 'Kommission'                            ,n , 0);
        LF_Set(18, 'Kunde'                                 ,n , 0);
        LF_Set(19, 'Reserviert kg'                         ,y , 0);
        LF_Set(20, 'Chargennr.'                            ,n , 0);
        LF_Set(21, 'Ringnummer'                            ,n , 0);
        LF_Set(22, 'Werksnummer'                           ,n , 0);
        LF_Set(23, 'Strukturnummer'                        ,n , 0);
        LF_Set(24, 'Oberfläche'                            ,n , 0);
        LF_Set(25, 'eff.Gesamtwert'                        ,y , 0);
        LF_Set(26, 'Inventurdatum'                         ,y , 0);
        LF_Set(27, 'EK-Projektnummer'                         ,y , 0);
        LF_Set(28, 'Lief.AB-Nr'                         ,y , 0);
        LF_Set(29, 'Lagerplatz'                         ,n , 0);
      end;
    end;


    'MATERIAL' : begin
      if (aPrint) then begin
        AddSum(1,cnvfi(Mat.Bestand.Stk));
        AddSum(2,Mat.Bestand.Gew);
        AddSum(3,Mat.Bestellt.Gew);
        AddSum(4,(Mat.EK.Effektiv*Mat.Bestand.Gew/1000.0));
        LF_Text(16, ZahlF(Mat.EK.Effektiv*Mat.Bestand.Gew/1000.0, 2));

        if (List_XML) then begin
          vObf # '';
          Erx # RecLink(201,200,11,_recFirst);
          WHILE(Erx <= _rLocked) DO BEGIN
            if (vObf = '') then
              vObf # Mat.AF.Bezeichnung;
            else
              vObf # vObf + ', ' + Mat.AF.Bezeichnung;
            Erx # RecLink(201,200,11,_recNext);
          END;
          LF_Text(24, vObf);
          LF_Text(25, ZahlF(Mat.EK.Effektiv*Mat.Bestand.Gew/1000.0, 2));
        end;

        if(List_XML = false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        RETURN;

      end;

      // Instanzieren...
      LF_Set(1,  '@Mat.Nummer'          ,y , _LF_IntNG);
      LF_Set(2,  '@Mat.Güte'            ,n , 0);
      LF_Set(3,  '@Mat.Dicke'           ,y , _LF_Num3, Set.Stellen.Dicke);
      LF_Set(4,  '@Mat.Breite'          ,y , _LF_Num3, Set.Stellen.Breite);
      LF_Set(5,  '@Mat.Länge'           ,y , _LF_Num3, "Set.Stellen.Länge");
      LF_Set(6,  '@Mat.Coilnummer'      ,n , 0);
      LF_Set(7,  '@Mat.Warengruppe'     ,y , _LF_IntNG);
      LF_Set(8,  '@Mat.Status'          ,y , _LF_IntNG);
      LF_Set(9,  '@Mat.LieferStichwort' ,n , 0);
      LF_Set(10, '@Mat.LagerStichwort'  ,n , 0);
      LF_Set(11, '@Mat.Bestand.Stk'     ,y , _LF_Int);
      LF_Set(12, '@Mat.Bestand.Gew'     ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(13, ''                     ,y , 0);
      LF_Set(14, '@Mat.EK.Preis'        ,y , _LF_Wae);
      LF_Set(15, '@Mat.EK.Effektiv'     ,y , _LF_Wae);
      LF_Set(16, 'Mat.EK.Effektiv*Mat.Bestand.Gew/1000.0,2)' ,y , _LF_Wae);

      if (List_XML) then begin
        LF_Set(17, '@Mat.Kommission'      , n, 0);
        LF_Set(18, '@Mat.KommKundenSWort' , n, 0);
        LF_Set(19, '@Mat.Reserviert.Gew'  , y, _LF_Num, Set.Stellen.Gewicht);
        LF_Set(20, '@Mat.Chargennummer'   , n, 0);
        LF_Set(21, '@Mat.Ringnummer'      , n, 0);
        LF_Set(22, '@Mat.Werksnummer'     , n, 0);
        LF_Set(23, '@Mat.Strukturnr'      , n, 0);
        LF_Set(24, 'vObf'                 , n, 0);
        LF_Set(25, 'preis'                , y, _LF_Wae);
        LF_Set(26, '@Mat.Inventurdatum'   , y, _LF_Date);
        LF_Set(27, '@Mat.EK.Projektnr'    , y, _LF_Int);
        LF_Set(28, '@Mat.BestellABNr'     , n, 0);
        LF_Set(29, '@Mat.Lagerplatz'      , n, 0);

      end;
    end;


    'SUMME1' : begin

      if (aPrint) then begin
        LF_Sum(11 ,1, 0);
        LF_Sum(13 ,3, Set.Stellen.Gewicht);
        LF_Sum(16 ,4, 2);
        RETURN;
      end;

      // Instanzieren...

      List_Spacing[11]  # List_Spacing[ 10];
      //List_Spacing[12]  # List_Spacing[ 11] + 12.5;
      List_Spacing[13]  # List_Spacing[ 12];
      //List_Spacing[14]  # List_Spacing[ 13] + 17.0;
      //List_Spacing[15]  # List_Spacing[ 14] + 20.0;
      List_Spacing[16]  # List_Spacing[ 15];

      LF_Format(_LF_Overline);
      LF_Set(11, 'SUM1'                 ,y , _LF_INT);
      LF_Set(13, 'SUM3'                 ,y , _LF_NUM, Set.Stellen.Gewicht);
      LF_Set(16, 'SUM4'                 ,y , _LF_WAE);
    end;


    'SUMME2' : begin

      if (aPrint) then begin
        LF_Sum(12 ,2, Set.Stellen.Gewicht);
        RETURN;
      end;

      // Instanzieren...
      List_Spacing[10]  # List_Spacing[ 9]  + 21.0;
      List_Spacing[11]  # List_Spacing[ 10] + 21.0;
      List_Spacing[12]  # List_Spacing[ 11] + 12.5;
      List_Spacing[13]  # List_Spacing[ 12] + 23.0;
      List_Spacing[14]  # List_Spacing[ 13] + 23.0;
      List_Spacing[15]  # List_Spacing[ 14] + 17.0;
      List_Spacing[16]  #  190.0;

      LF_Format(_LF_Overline);
      LF_set(12, 'SUM2'                 ,y , _LF_NUM, Set.Stellen.Gewicht);
    end;




/**** ALT
    'Mat' : begin
      StartLine();
      Write(1,  ZahlI(Mat.Nummer)                                    ,y ,_LF_Int, 3.0);
      Write(2,  Mat.Bestellnummer                                               ,n ,0);
      Write(3,  ZahlI(Mat.Warengruppe)                                    ,y ,_LF_Int);

      Erx # RecLink(501,200,18,0) // Ein.Pos holen
      if (Erx <= _rLocked) then
        if (Ein.P.Projektnummer <> 0) then
          Write(4,  ZahlI(Ein.P.Projektnummer)                       ,y ,_LF_Int, 3.0);

      if (Mat.Lieferant <> 0) then begin
      Erx # RecLink(100,200,4,0);     // Lieferant holen
        if (Erx<=_rLocked) then
          Write(5, StrCut(Adr.Stichwort, 1, 9)                                 , n, 0);
      end;
      Write(6,  ZahlI(Mat.Bestand.Stk)                                    ,y ,_LF_Int);
      Write(7,  ZahlF(Mat.Bestand.Gew, Set.Stellen.Gewicht)               ,y ,_LF_Num);
      Write(8,  ZahlI(Mat.Status)                                    ,y ,_LF_Int, 3.0);

      if (Mat.Eingangsdatum <> 0.0.0) then
        Write(9,  DatS(Mat.Eingangsdatum)                              ,n ,_LF_Date);

      Write(10, StrCut(Mat.LagerStichwort, 1, 9)                                ,n ,0);
      Write(11, Mat.Coilnummer                                                  ,n ,0);
      Write(12, ZahlF(Mat.EK.Preis,2)                                     ,y ,_LF_Wae);
      Write(13, ZahlF(Mat.EK.Preis*Mat.Bestand.Gew/1000.0,2)              ,y ,_LF_Wae);

      AddSum(1,cnvFI(Mat.Bestand.Stk));
      AddSum(2,Mat.Bestand.Gew);
      AddSum(3,(Mat.EK.Preis*Mat.Bestand.Gew/1000.0));
      Endline();

    end; // Mat
***/
  end; // case

end;


//========================================================================
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx         : int;
  vSel        : int;
  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;
  vOK         : logic;
  vTree       : int;
  vSortKey    : alpha;
  vCount      : int;

  vQ          : alpha(4000);
  vQ1         : alpha(4000);
  vDate       : alpha;

  vProgress   : handle;
end;
begin
//  APPOFF;

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsdatum
  if ( Sel.von.Datum = 0.0.0 ) then vDate # '0.0.0' else vDate # CnvAd( Sel.von.Datum );

  // BESTAND-Selektion
  vQ1 # '';
  vQ  # '( Mat.Ausgangsdatum >= ' + vDate + ' OR Mat.Ausgangsdatum = 0.0.0 )';
//  vQ  # vQ + ' AND ( Mat.Eingangsdatum < ' + vDate + ' AND Mat.Eingangsdatum > 0.0.0 )';
  vQ  # vQ + ' AND Mat.Eingangsdatum < ' + vDate + ' AND Mat.Eingangsdatum > 0.0.0';
  // seit 22.10.2015:
  vQ  # vQ + ' AND Mat.Datum.Erzeugt < ' + vDate + ' AND Mat.Datum.Erzeugt > 0.0.0';


  if ( "Sel.Mat.von.Dicke"  != 0.0 ) or ( "Sel.Mat.bis.Dicke"  != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Mat.Dicke"',         "Sel.Mat.von.Dicke", "Sel.Mat.bis.Dicke" );
  if ( "Sel.Mat.von.Breite" != 0.0 ) or ( "Sel.Mat.bis.Breite" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Mat.Breite"',        "Sel.Mat.von.Breite", "Sel.Mat.bis.Breite" );
  if ( "Sel.Mat.von.Länge"  != 0.0 ) or ( "Sel.Mat.bis.Länge"  != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Mat.Länge"',         "Sel.Mat.von.Länge", "Sel.Mat.bis.Länge" );
  if ( "Sel.Mat.von.WGr"    != 0 ) or ( "Sel.Mat.bis.WGr"    != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Mat.Warengruppe"',   "Sel.Mat.von.WGr",    "Sel.Mat.bis.WGr" );
  if ( "Sel.Mat.von.Status" != 0 ) or ( "Sel.Mat.bis.Status" != 999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Mat.Status"',        "Sel.Mat.von.Status", "Sel.Mat.bis.Status" );

  if ( "Sel.Mat.Güte" != '' ) then
    Lib_Sel:QAlpha( var vQ, '"Mat.Güte"', '=*', "Sel.Mat.Güte" );
  if ( Sel.Mat.Lagerort != 0 ) then
    Lib_Sel:QInt( var vQ, 'Mat.Lageradresse', '=', Sel.Mat.Lagerort );
  if ( Sel.Mat.LagerAnschri != 0 ) then
    Lib_Sel:QInt( var vQ, 'Mat.Lageranschrift', '=', Sel.Mat.LagerAnschri );
  if ( Sel.Mat.Lieferant != 0 ) then
    Lib_Sel:QInt( var vQ, 'Mat.Lieferant', '=', Sel.Mat.Lieferant );

  if ( Sel.Mat.ObfNr != 0 ) or ( Sel.Mat.ObfNr2 != 999 ) then begin
    Lib_Sel:QVonBisI( var vQ1, 'Mat.Af.ObfNr', Sel.Mat.ObfNr, Sel.Mat.ObfNr2 );
    if ( Sel.Mat.von.Obfzusat != '' ) or ( Sel.Mat.bis.Obfzusat != 'zzzzz' ) then
      Lib_Sel:QVonBisA( var vQ1, 'Mat.Af.Zusatz', Sel.Mat.von.Obfzusat, Sel.Mat.bis.Obfzusat );
    vQ # vQ + ' AND LinkCount(Ausf) > 0';
  end;

  vSel # SelCreate( 200, 1 );
  if (vQ1<>'') then
    vSel->SelAddLink( '', 201, 200, 11, 'Ausf');
  Erx # vSel->SelDefQuery( '', vQ );
  vSel->Lib_Sel:QError();
  if (vQ1<>'') then begin
    Erx # vSel->SelDefQuery( 'Ausf', vQ1 );
    vSel->Lib_Sel:QError();
  end;
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );


  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 200, _recCount, vSel ) );

  FOR Erx # RecRead(200,vSel, _recFirst)
  LOOP Erx # RecRead(200,vSel, _recNext)
  WHILE (Erx<=_rLocked) do begin
    if (!vProgress->Lib_Progress:Step()) then BREAK;

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
    if (aSort=12) then  vSortKey # cnvAI(Mat.Warengruppe)
    if (aSort=13) then  vSortKey # Mat.Werksnummer
    Sort_ItemAdd(vTree,vSortKey,200,RecInfo(200,_RecId));
    inc(vCount);
  END;
  SelClose(vSel);
  SelDelete(200, vSelName);
  vSel # 0;
  vProgress->Lib_Progress:Term();


  // ABLAGE-Selektion
  vQ1 # '';
  vQ  # '( "Mat~Ausgangsdatum" >= ' + vDate + ' OR "Mat~Ausgangsdatum" = 0.0.0 )';
//  vQ  # vQ + ' AND ( "Mat~Eingangsdatum" < ' + vDate + ' AND "Mat~Eingangsdatum" > 0.0.0 )';
  vQ  # vQ + ' AND "Mat~Eingangsdatum" < ' + vDate + ' AND "Mat~Eingangsdatum" > 0.0.0';
  // seit 22.10.2015:
  vQ  # vQ + ' AND "Mat~Datum.Erzeugt" < ' + vDate + ' AND "Mat~Datum.Erzeugt" > 0.0.0';


  if ( "Sel.Mat.von.Dicke"  != 0.0 ) or ( "Sel.Mat.bis.Dicke"  != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Mat~Dicke"',         "Sel.Mat.von.Dicke", "Sel.Mat.bis.Dicke" );
  if ( "Sel.Mat.von.Breite" != 0.0 ) or ( "Sel.Mat.bis.Breite" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Mat~Breite"',        "Sel.Mat.von.Breite", "Sel.Mat.bis.Breite" );
  if ( "Sel.Mat.von.Länge"  != 0.0 ) or ( "Sel.Mat.bis.Länge"  != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Mat~Länge"',         "Sel.Mat.von.Länge", "Sel.Mat.bis.Länge" );
  if ( "Sel.Mat.von.WGr"    != 0 ) or ( "Sel.Mat.bis.WGr"    != 9999) then
    Lib_Sel:QVonBisI( var vQ, '"Mat~Warengruppe"',   "Sel.Mat.von.WGr",    "Sel.Mat.bis.WGr" );
  if ( "Sel.Mat.von.Status" != 0 ) or ( "Sel.Mat.bis.Status" != 999) then
    Lib_Sel:QVonBisI( var vQ, '"Mat~Status"',        "Sel.Mat.von.Status", "Sel.Mat.bis.Status" );

  if ( "Sel.Mat.Güte" != '' ) then
    Lib_Sel:QAlpha( var vQ, '"Mat~Güte"', '=*', "Sel.Mat.Güte" );
  if ( Sel.Mat.Lagerort != 0 ) then
    Lib_Sel:QInt( var vQ, '"Mat~Lageradresse"', '=', Sel.Mat.Lagerort );
  if ( Sel.Mat.Lieferant != 0 ) then
    Lib_Sel:QInt( var vQ, '"Mat~Lieferant"', '=', Sel.Mat.Lieferant );

  if ( Sel.Mat.ObfNr != 0 ) or ( Sel.Mat.ObfNr2 != 999) then begin
    Lib_Sel:QVonBisI( var vQ1, 'Mat.Af.ObfNr', Sel.Mat.ObfNr, Sel.Mat.ObfNr2 );
    if ( Sel.Mat.von.Obfzusat != '' ) or ( Sel.Mat.bis.Obfzusat != 'zzzzz' ) then
      Lib_Sel:QVonBisA( var vQ1, 'Mat.Af.Zusatz', Sel.Mat.von.Obfzusat, Sel.Mat.bis.Obfzusat );
    vQ # vQ + ' AND LinkCount(Ausf) > 0';
  end;

  vSel # SelCreate( 210, 1 );
  if (vQ1<>'') then
    vSel->SelAddLink( '', 201, 210, 11, 'Ausf');
  Erx # vSel->SelDefQuery( '', vQ );
  vSel->Lib_Sel:QError();
  if (vQ1<>'') then begin
    Erx # vSel->SelDefQuery( 'Ausf', vQ1 );
    vSel->Lib_Sel:QError();
  end;
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );


  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 210, _recCount, vSel ) );

  FOR Erx # RecRead(210,vSel, _recFirst)
  LOOP Erx # RecRead(210,vSel, _recNext)
  WHILE (Erx<=_rLocked) do begin
    if ( !vProgress->Lib_Progress:Step() ) then BREAK;

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
    if (aSort=12) then  vSortKey # cnvAI("Mat~Warengruppe")
    if (aSort=13) then  vSortKey # "Mat~Werksnummer"
    Sort_ItemAdd(vTree,vSortKey,210,RecInfo(210,_RecId));
    inc(vCount);
  END;
  SelClose(vSel);
  SelDelete(210, vSelName);
  vSel # 0;


//debug('Count:'+aint(vCOunt));

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset('Listengenerierung', CteInfo(vTree, _cteCount ));

  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Sel3      # LF_NewLine('SEL3');
  g_Sel4      # LF_NewLine('SEL4');
  g_Header    # LF_NewLine('HEADER');
  g_Material  # LF_NewLine('MATERIAL');
  g_Summe1    # LF_NewLine('SUMME1');
  g_Summe2    # LF_NewLine('SUMME2');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    if ( !vProgress->Lib_Progress:Step() ) then begin // Progress
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      BREAK;
    end;

    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    // Ablage?
    If (CnvIA(vItem->spCustom)=210) then RecBufCopy(210,200);

    // Bestandsbuch mit einrechnen...
    Mat_B_Data:BewegungenRueckrechnen(Sel.von.Datum);

    LF_Print(g_Material);
//    Print('Mat');
  END;
  LF_Print(g_Summe1);
  LF_Print(g_Summe2);

  Sort_KillList(vTree);           // Löschen des RAM-Baumes

  vProgress->Lib_Progress:Term(); // Progremm beenden

  LF_Term();                      // Liste beenden

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Sel3);
  LF_FreeLine(g_Sel4);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Material);
  LF_FreeLine(g_Summe1);
  LF_FreeLine(g_Summe2);

end;

//========================================================================