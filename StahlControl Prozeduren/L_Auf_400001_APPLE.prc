@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Auf_400001_APPLE
//                    OHNE E_R_G
//  Info        Bestandsliste
//
//
//  05.03.2007  AI  Erstellung der Prozedur
//  31.07.2008  DS  QUERY
//  17.08.2010  TM  Selektions-Fixdatum 1.1.2010 getauscht durch 31.12. des aktuellen Jahres
//  16.05.2012  TM  Umstellung auf Def_List2
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
@I:Def_ListApple

declare StartList(aSort : int; aSortName : alpha);
declare Print(aName : alpha);

define begin
  cFile         : 401
  cGesRestKg    : 1
  cGesAuftragKg : 2
  cGesGesamtKg  : 3
end;

local begin
// Handles für die Zeilenelemente

  g_Empty         : int;
  g_Sel1          : int;
  g_Sel2          : int;
  g_Sel3          : int;
  g_Sel4          : int;
  g_Sel5          : int;
  g_Sel6          : int;
  g_Sel7          : int;
  g_Header        : int;
  g_Auftrag       : int;
  g_Summe1        : int;
  g_Leselinie     : logic;

  vEinzel   : float;
  vGesamt   : float;
  vMenge    : float;

end;


//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  // NUR für Kunden
  if (Adr.Kundennr=0) then RETURN;

  RecBufClear(998);
  Sel.Auf.ObfNr2        # 999;
  Sel.Auf.bis.Nummer    # 99999999;
  Sel.Auf.bis.Datum     # today;
  Sel.Auf.bis.WTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.AufArt    # 999;
  Sel.Auf.bis.WGr       # 9999;
  Sel.Auf.bis.DruckDat  # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.LiefDat   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.ZTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.Projekt   # 99999999;
  Sel.Auf.bis.Kostenst  # 99999999;
  Sel.Auf.bis.Dicke     # 999999.00;
  Sel.Auf.bis.Breite    # 999999.00;
  "Sel.Auf.bis.Länge"   # 999999.00;
  Sel.Auf.von.Obfzusat  # 'zzzzz';
  "Sel.Mat.bis.Zugfest" # 9999.0;

  Sel.Auf.Kundennr      # Adr.Kundennr;

  StartList(5,'');  // Liste generieren
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
return;
      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 20.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  +  2.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  +  8.0;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 25.0;
      List_Spacing[ 6]  # List_Spacing[ 5]  +  7.0;
      List_Spacing[ 7]  # List_Spacing[ 6]  + 25.0;

      List_Spacing[ 8]  # List_Spacing[ 7]  + 20.0;
      List_Spacing[ 9]  # List_Spacing[ 8]  +  2.0;
      List_Spacing[10]  # List_Spacing[ 9]  +  8.0;
      List_Spacing[11]  # List_Spacing[10]  + 25.0;
      List_Spacing[12]  # List_Spacing[11]  +  7.0;
      List_Spacing[13]  # List_Spacing[12]  + 25.0;


      List_Spacing[14]  # List_Spacing[ 13] + 20.0;
      List_Spacing[15]  # List_Spacing[ 14] +  2.0;
      List_Spacing[16]  # List_Spacing[ 15] +  8.0;
      List_Spacing[17]  # List_Spacing[ 16] + 25.0;
      List_Spacing[18]  # List_Spacing[ 17] +  7.0;
      List_Spacing[19]  # List_Spacing[ 18] + 25.0;

      Lf_Set( 1, 'AuftragsNr'                 ,n , 0);
      Lf_Set( 2,  ': '                        ,n , 0);
      Lf_Set( 3,  ' von: '                    ,n , 0);
      Lf_Set( 4,  ZahlI(Sel.Auf.von.Nummer)   ,Y , _LF_INT);
      Lf_Set( 5,  ' bis: '                    ,n , 0);
      Lf_Set( 6,  ZahlI(Sel.Auf.bis.Nummer)   ,y , _LF_INT);
      Lf_Set( 7, 'Datum'                      ,n , 0);
      Lf_Set( 8, ': '                         ,n , 0);
      Lf_Set( 9, 'von: '                      ,n , 0);
      Lf_Set(10, Cnvad(Sel.Auf.von.Datum)     ,n , 0);
      Lf_Set(11, ' bis: '                     ,n , 0);
      Lf_Set(12,  cnvad(Sel.Auf.bis.Datum)    ,y , 0);
      Lf_Set(13, 'Wunsch'                     ,n , 0);
      Lf_Set(14, ': '                         ,n , 0);
      Lf_Set(15, ' von: '                     ,n , 0);
      Lf_Set(16, Cnvad(Sel.Auf.von.WTermin)   ,n , 0);
      Lf_Set(17, ' bis: '                     ,n , 0);
      Lf_Set(18, cnvad(Sel.Auf.bis.WTermin)   ,y , 0);
    end;

    'SEL2' : begin
return;

      if (aPrint) then RETURN;

      // Instanzieren...

      Lf_Set( 1, 'AufArt'                     ,n , 0);
      Lf_Set( 2,  ': '                        ,n , 0);
      Lf_Set( 3,  ' von: '                    ,n , 0);
      Lf_Set( 4,  ZahlI(Sel.Auf.von.AufArt)   ,y , _LF_INT);
      Lf_Set( 5,  ' bis: '                    ,n , 0);
      Lf_Set( 6,  ZahlI(Sel.Auf.bis.AufArt)   ,y , _LF_INT);
      Lf_Set( 7, 'Wgr'                        ,n , 0);
      Lf_Set( 8, ': '                         ,n , 0);
      Lf_Set( 9, 'von: '                      ,n , 0);
      Lf_Set(10, ZahlI(Sel.Auf.von.Wgr)       ,y , _LF_INT);
      Lf_Set(11, ' bis: '                     ,n , 0);
      Lf_Set(12,  ZahlI(Sel.Auf.bis.Wgr)      ,y , _LF_INT);
      Lf_Set(13, 'Kundennr'                   ,n , 0);
      Lf_Set(14, ': '                         ,n , 0);
      Lf_Set(16, ZahlI(Sel.Auf.Kundennr)      ,y , _LF_INT);
  end;

  'SEL3' : begin
return;

      if (aPrint) then RETURN;

      // Instanzieren...

      Lf_Set( 1, 'Artikelnr'                  ,n , 0);
      Lf_Set( 2,  ': '                        ,n , 0);
      Lf_Set( 4, Sel.Auf.Artikelnr            ,n , 0);
      Lf_Set( 7, 'Sachbear.'                  ,n , 0);
      Lf_Set( 8, ': '                         ,n , 0);
      Lf_Set(10, Sel.Auf.Sachbearbeit         ,n , 0);
      Lf_Set(13, 'Vertreternr'                ,n , 0);
      Lf_Set(14, ': '                         ,n , 0);
      Lf_Set(16, ZahlI(Sel.Auf.Vertreternr)   ,y , _LF_INT);
  end;

  'SEL4' : begin
return;

      if (aPrint) then RETURN;

      // Instanzieren...

      Lf_Set( 1, 'DruckDat'                   ,n , 0);
      Lf_Set( 2,  ': '                        ,n , 0);
      Lf_Set( 3,  ' von: '                    ,n , 0);
      Lf_Set( 4,  Cnvad(Sel.Auf.von.DruckDat) ,n , 0);
      Lf_Set( 5,  ' bis: '                    ,n , 0);
      Lf_Set( 6,  cnvad(Sel.Auf.bis.DruckDat) ,y , 0);
      Lf_Set( 7, 'LiefDat'                    ,n , 0);
      Lf_Set( 8, ': '                         ,n , 0);
      Lf_Set( 9, 'von: '                      ,n , 0);
      Lf_Set(10, Cnvad(Sel.Auf.von.LiefDat)   ,n , 0);
      Lf_Set(11, ' bis: '                     ,n , 0);
      Lf_Set(12,  cnvad(Sel.Auf.bis.LiefDat)  ,y , 0);
      Lf_Set(13, 'Projekt'                    ,n , 0);
      Lf_Set(14, ': '                         ,n , 0);
      Lf_Set(15, ' von: '                     ,n , 0);
      Lf_Set(16, ZahlI(Sel.Auf.von.Projekt)   ,y , _LF_INT);
      Lf_Set(17, ' bis: '                     ,n , 0);
      Lf_Set(18, ZahlI(Sel.Auf.bis.Projekt)   ,y , _LF_INT);
  end;

  'SEL5' : begin
return;

      if (aPrint) then RETURN;

      // Instanzieren...

      Lf_Set( 1, 'Kostenst'                   ,n , 0);
      Lf_Set( 2,  ': '                        ,n , 0);
      Lf_Set( 3,  ' von: '                    ,n , 0);
      Lf_Set( 4,  ZahlI(Sel.Auf.von.Kostenst) ,Y , _LF_INT);
      Lf_Set( 5,  ' bis: '                    ,n , 0);
      Lf_Set( 6,  ZahlI(Sel.Auf.bis.Kostenst) ,y , _LF_INT);
      Lf_Set( 7, 'Dicke'                      ,n , 0);
      Lf_Set( 8, ': '                         ,n , 0);
      Lf_Set( 9, 'von: '                      ,n , 0);
      Lf_Set(10, ZahlF(Sel.Auf.von.Dicke,2)   ,y , _LF_NUM);
      Lf_Set(11, ' bis: '                     ,n , 0);
      Lf_Set(12,  ZahlF(Sel.Auf.bis.Dicke,2)  ,y , _LF_NUM);
      Lf_Set(13, 'Breite'                     ,n , 0);
      Lf_Set(14, ': '                         ,n , 0);
      Lf_Set(15, ' von: '                     ,n , 0);
      Lf_Set(16, ZahlF(Sel.Auf.von.Breite,2)  ,Y , _LF_NUM);
      Lf_Set(17, ' bis: '                     ,n , 0);
      Lf_Set(18, ZahlF(Sel.Auf.bis.Breite,2)  ,y , _LF_NUM);
   end;

   'SEL6' : begin
return;

      if (aPrint) then RETURN;

      // Instanzieren...

      Lf_Set( 1, 'Länge'                      ,n , 0);
      Lf_Set( 2,  ': '                        ,n , 0);
      Lf_Set( 3,  ' von: '                    ,n , 0);
      Lf_Set( 4,  ZahlF("Sel.Auf.von.Länge",2),Y , _LF_NUM);
      Lf_Set( 5,  ' bis: '                    ,n , 0);
      Lf_Set( 6,  ZahlF("Sel.Auf.bis.Länge",2),y , _LF_NUM);
      Lf_Set( 7, 'Güte'                       ,n , 0);
      Lf_Set( 8, ': '                         ,n , 0);
      Lf_Set(10, "Sel.Auf.Güte"               ,n , 0);
      Lf_Set(13, 'ObfNr'                      ,n , 0);
      Lf_Set(14, ': '                         ,n , 0);
      Lf_Set(15, ' von: '                     ,n , 0);
      Lf_Set(16, ZahlI(Sel.Auf.ObfNr)         ,Y , _LF_INT);
      Lf_Set(17, ' bis: '                     ,n , 0);
      Lf_Set(18, ZahlI(Sel.Auf.ObfNr2)        ,Y , _LF_INT);
  end;

  'SEL7' : begin
return;

      if (aPrint) then RETURN;

      // Instanzieren...

      Lf_Set( 1, 'ObfZusat'                   ,n , 0);
      Lf_Set( 2,  ': '                        ,n , 0);
      Lf_Set( 3,  ' von: '                    ,n , 0);
      Lf_Set( 4,  Sel.Auf.von.ObfZusat        ,n , 0);
      Lf_Set( 5,  ' bis: '                    ,n , 0);
      Lf_Set( 6,  Sel.Auf.bis.ObfZusat        ,y , 0);
      Lf_Set( 7, 'Zusage Termin'              ,n , 0);
      Lf_Set( 8, ': '                         ,n , 0);
      Lf_Set( 9, 'von: '                      ,n , 0);
      Lf_Set(10, Cnvad(Sel.Auf.von.ZTermin)   ,n , 0);
      Lf_Set(11, ' bis: '                     ,n , 0);
      Lf_Set(12, cnvad(Sel.Auf.bis.ZTermin)   ,y , 0);
  end;


  'HEADER' : begin
      if (aPrint) then RETURN;
      LF_Format(_LF_UnderLine + _LF_Bold);
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 22.0;
      List_Spacing[ 3]  # List_Spacing[ 2] + 25.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 11.4;
      List_Spacing[ 5]  # List_Spacing[ 4] + 20.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 17.0;
      List_Spacing[ 7]  # List_Spacing[ 6] + 19.0;
      List_Spacing[ 8]  # List_Spacing[ 7] + 15.0;
      List_Spacing[ 9]  # List_Spacing[ 8] + 14.0;
      List_Spacing[10]  # List_Spacing[ 9] + 23.0;
      List_Spacing[11]  # List_Spacing[ 10] + 25.0;
      List_Spacing[12]  # List_Spacing[ 11] + 22.0;
      List_Spacing[13]  # List_Spacing[ 12] + 20.0;

      List_Spacing[14]  # List_Spacing[ 13] + 30.0; // 27

      List_Spacing[15]  # List_Spacing[ 14] + 20.0; // 20
      List_Spacing[16]  # List_Spacing[ 15] + 10.0;
      List_Spacing[17]  # List_Spacing[ 16] + 10.0;
      List_Spacing[18]  # List_Spacing[ 17] + 10.0;
      List_Spacing[19]  # List_Spacing[ 18] + 10.0;
      List_Spacing[20]  # List_Spacing[ 19] + 10.0;
      List_Spacing[21]  # List_Spacing[ 11] + 42.0;


      Lf_Set(1,  'Auftrgsnr.'                         ,n , 0);
      Lf_Set(2,  'Stichwort'                          ,n , 0);
      Lf_Set(3,  'Wgr.'                               ,y , 0);
      Lf_Set(4,  'Qualität'                           ,n , 0);
      Lf_Set(5,  'Dicke'                              ,y , 0);
      Lf_Set(6,  'Breite'                             ,y , 0);
      Lf_Set(7,  'Länge'                              ,y , 0);
      Lf_Set(8,  'Stück'                              ,y , 0);
      if (list_xml=true) then begin
        Lf_Set(9,  'VSB'                              ,y , 0);
        Lf_Set(10, 'In Ausl.'                         ,y , 0);
        Lf_Set(11, 'Geliefert'                        ,y , 0);
        Lf_Set(12, 'Berechnet'                        ,y , 0);
        Lf_Set(13, 'Restmng kg'                       ,y , 0);
        Lf_Set(14, 'Aufmng kg'                        ,y , 0);
        Lf_Set(15, 'E-Preis '+ "Set.Hauswährung.Kurz" ,y , 0);
        Lf_Set(16, 'Preisst.'                         ,y , 0);
        Lf_Set(17, 'Gesamt '+ "Set.Hauswährung.Kurz"  ,y , 0);
        Lf_Set(18, 'Termin'                           ,y , 0);
        end
      else begin
        Lf_Set(9,  'Restmng kg'                       ,y , 0);
        Lf_Set(10, 'Aufmng kg'                        ,y , 0);
        Lf_Set(11, 'E-Preis '+ "Set.Hauswährung.Kurz" ,y , 0);
        Lf_Set(12, 'Preisst.'                         ,y , 0);
        Lf_Set(13, 'Gesamt '+ "Set.Hauswährung.Kurz"  ,y , 0);
        Lf_Set(14, 'Termin'                           ,y , 0);
    end;


  end;


    'AUFTRAG' : begin
      if (aPrint) then begin
/**
        LF_Text(1, AInt(Auf.P.Nummer) + '/' +  Aint(Auf.P.Position));
        LF_Text(2, StrCut(Auf.P.KundenSW,1,10));
        if (list_xml=true) then begin
          LF_Text(15,CnvAF(vEinzel,0,0,2));
          LF_Text(16, cnvai(Auf.P.PEH) + ' ' + (Auf.P.MEH.Preis))
          LF_Text(17, cnvaf(vGesamt,0,0,2));
        end else begin
          LF_Text(11,CnvAF(vEinzel,0,0,2));
          LF_Text(12, cnvai(Auf.P.PEH) + ' ' + (Auf.P.MEH.Preis))
          LF_Text(13, cnvaf(vGesamt,0,0,2));
        end;**/
        RETURN;
      end;

        LF_Set(1, '#Auftrag'          ,n ,0);
        LF_Set(2, '#Auf.P.KundenSW'            ,n , 0);
        LF_Set(3, '@Auf.P.Warengruppe'  ,n , _LF_Num3, 0);
        LF_Set(4, '@Auf.P.Güte'         ,n , 0);
        LF_Set(5, '@Auf.P.Dicke'        ,y , _LF_Num3, Set.Stellen.Dicke);
        LF_Set(6, '@Auf.P.Breite'       ,y , _LF_Num3, Set.Stellen.Breite);
        LF_Set(7, '@Auf.P.Länge'       ,y , _LF_Num3, "Set.Stellen.Länge");
        LF_Set(8, '@Auf.P.Stückzahl'          ,y , _LF_Int);

        if (list_xml=true) then begin
          LF_Set(9, '@Auf.P.Prd.VSB.Gew'        ,y , _LF_Num3, Set.Stellen.Gewicht);
          LF_Set(10, '@Auf.P.Prd.VSAuf.Gew'        ,y , _LF_Num3, Set.Stellen.Gewicht);
          LF_Set(11, '@Auf.P.Prd.LFS.Gew'        ,y , _LF_Num3, Set.Stellen.Gewicht);
          LF_Set(12, '@Auf.P.Prd.Rech.Gew'        ,y , _LF_Num3, Set.Stellen.Gewicht);

          LF_Set(13, '@Auf.P.Prd.Rest.Gew'        ,y , _LF_Num3, Set.Stellen.Gewicht);
          LF_Set(14, '@Auf.P.Gewicht'        ,y , _LF_Num3, Set.Stellen.Gewicht);
          LF_Set(15, '#vEinzel'                                  ,y );

          if (Auf.P.PEH=1) then
            LF_Set(16, '@Auf.P.MEH.Preis'                                 ,y , 0);
          else
            LF_Set(16, '#PEH'        ,y , 0);

          LF_Set(17,'#Gesamt'                                   ,y );
          LF_Set(18, '@Auf.P.Termin1Wunsch'                        ,y , 0);

        end
        else begin

          LF_Set(9, '@Auf.P.Prd.Rest.Gew'        ,y , _LF_Num3, Set.Stellen.Gewicht);
          LF_Set(10, '@Auf.P.Gewicht'        ,y , _LF_Num3, Set.Stellen.Gewicht);
          LF_Set(11, 'vEinzel'                                  ,y );

          if (Auf.P.PEH=1) then
              LF_Set(12, '@Auf.P.MEH.Preis'                                 ,y , 0);
            else
              LF_Set(12, '#PEH'        ,y , 0);

          LF_Set(13,'#Gesamt'                                   ,y );
          LF_Set(14, '@Auf.P.Termin1Wunsch'                        ,y , 0);
        end;

    end;

    'SUMME1' : begin

      if (aPrint) then begin
        if (list_xml=true) then begin
          LF_Sum(13,1 ,Set.Stellen.Gewicht);
          LF_Sum(14,2 ,Set.Stellen.Gewicht);
          LF_Sum(17,3 ,Set.Stellen.Gewicht);
        end
        else begin
          LF_Sum( 9,1 ,Set.Stellen.Gewicht);
          LF_Sum(10,2 ,Set.Stellen.Gewicht);
          LF_Sum(13,3 ,Set.Stellen.Gewicht);
        end;

        RETURN;
      end;

      LF_Format(_LF_OverLine + _LF_Bold);
      if (list_xml=true) then begin
        LF_Set(13,  '#SUM1',y,_LF_NUM,2);
        LF_Set(14,  '#SUM2',y,_LF_NUM,2);
        LF_Set(17,  '#SUM3',y,_LF_NUM,2);
      end
      else begin
        LF_Set(9,   '#SUM1',y,_LF_NUM,2);
        LF_Set(10,  '#SUM2',y,_LF_NUM,2);
        LF_Set(13,  '#SUM3',y,_LF_NUM,2);
      end;

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
  LF_Print(g_Empty)

  if (aSeite=1) then begin

    LF_Print(g_Sel1);
    LF_Print(g_Sel2);
    LF_Print(g_Sel3);
    LF_Print(g_Sel4);
    LF_Print(g_Sel5);
    LF_Print(g_Sel6);
    LF_Print(g_Sel7);

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
  vQ401       : alpha(4000);
  vQ400       : alpha(4000);
  vQ402       : alpha(4000);
  vQAufArt    : alpha(250);
  tErx        : int;
  vSelAufArt  : int;
end;
begin

  // Sortierung setzen ------------------------------------------------------
  if (aSort=1) then   vKey # 5;   // Abmessung
  if (aSort=2) then   vKey # 1;   // Auftragsnr.
  if (aSort=3) then   vKey # 9;   // Bestellnr
  if (aSort=4) then   vKey # 3;   // Kunden-SW
  if (aSort=5) then   vKey # 4;   // Quali+Abm
  if (aSort=6) then   vKey # 8;   // Wunschterm
  if (aSort=7) then   vKey # 10;  // Zusageterm

  // BESTAND-Selektion öffnen
  // Selektionsquery für 401
  vQ401 # '';
  Lib_Sel:QInt( var vQ401, 'Auf.P.Nummer', '<', 1000000000 );
  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ401, 'Auf.P.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != today) then
    Lib_Sel:QVonBisD( var vQ401, 'Auf.P.TerminZusage', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != today) then
    Lib_Sel:QVonBisD( var vQ401, 'Auf.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQ401, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr );
  if ( "Sel.Auf.Güte" != '' ) then
    Lib_Sel:QAlpha( var vQ401, '"Auf.P.Güte"', '=*', "Sel.Auf.Güte" );
  if ( Sel.Auf.von.Dicke != 0.0 ) or ( Sel.Auf.bis.Dicke != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ401, 'Auf.P.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke );
  if ( Sel.Auf.von.Breite != 0.0 ) or ( Sel.Auf.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ401, 'Auf.P.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite );
  if ( "Sel.Auf.von.Länge" != 0.0 ) or ( "Sel.Auf.bis.Länge" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ401, '"Auf.P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge" );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQ401, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 999 ) then
    Lib_Sel:QVonBisI( var vQ401, 'Auf.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ401, 'Auf.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  if ( Sel.Auf.Artikelnr != '' ) then
    Lib_Sel:QAlpha( var vQ401, 'Auf.P.Artikelnr', '=', Sel.Auf.Artikelnr );
  Lib_Sel:QInt( var vQ401, 'Auf.P.Wgr.Dateinr', '>=', 200 );
  Lib_Sel:QInt( var vQ401, 'Auf.P.Wgr.Dateinr', '<=', 209 );
  Lib_Sel:QAlpha( var vQ401, '"Auf.P.Löschmarker"', '=', '' );
  if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
  vQ401 # vQ401 + ' ( ( Auf.P.Zugfestigkeit1 <= Sel.Mat.bis.Zugfest AND Auf.P.Zugfestigkeit2 >= Sel.Mat.von.Zugfest ) '+
            ' OR  ( Auf.P.Zugfestigkeit1 = 0.0 AND Auf.P.Zugfestigkeit2 = 0.0 ) ) '

  // Haken für Positionen
  // Berechenbar
  if((cnvIL("Sel.Auf.BerechenbYN") + cnvIL("Sel.Auf.!BerechenbYN") = 1)) then begin
    if ("Sel.Auf.BerechenbYN") then
      Lib_Sel:QAlpha( var vQ401, '"Auf.P.Aktionsmarker"', '=', '$' );
    if ("Sel.Auf.!BerechenbYN") then
      Lib_Sel:QAlpha( var vQ401, '"Auf.P.Aktionsmarker"', '=', '' );
  end;


  if ( Sel.Auf.ObfNr != 0) or ( Sel.Auf.ObfNr2 != 999) then begin
    if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
    vQ401 # vQ401 + ' LinkCount(Ausf) > 0 ';
  end;
  if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
  vQ401 # vQ401 + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 400
  vQ400 # '';
  vQ400 # '(Auf.Vorgangstyp=''' + c_AUF + ''')';
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ400, 'Auf.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );
  if ( Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt( var vQ400, 'Auf.Vertreter', '=', Sel.Auf.Vertreternr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vQ400, 'Auf.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );

  vSelAufArt # 0;
  vSelAufArt # cnvIL(Sel.Auf.RahmenYN) + cnvIL(Sel.Auf.AbrufYN) + cnvIL(Sel.Auf.NormalYN);
  vQAufArt   # '';
  if(vSelAufArt <> 0) and (vSelAufArt <> 3) then begin
    Lib_Strings:Append(var vQ400, '(', ' AND ');
    if(Sel.Auf.RahmenYN) then
      Lib_Strings:Append(var vQAufArt,'"Auf.LiefervertragYN" = true', '');
    if(Sel.Auf.AbrufYN) then
      Lib_Strings:Append(var vQAufArt,'"Auf.AbrufYN" = true', ' OR ');
    if(Sel.Auf.NormalYN) then
      Lib_Strings:Append(var vQAufArt,'("Auf.AbrufYN" = false AND "Auf.LiefervertragYN" = false)', ' OR ');
    Lib_Strings:Append(var vQ400, vQAufArt, '');
    Lib_Strings:Append(var vQ400, ')', '');
  end;

  // Selektionsquery für 402
  vQ402 # '';
  if ( Sel.Auf.ObfNr != 0 ) or ( Sel.Auf.ObfNr2 != 999 ) then
    Lib_Sel:QVonBisI( var vQ402, 'Auf.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2 );

  // dynamische Soriterung? -> RAMBAUM aufbauen


  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  // Selektion starten...
  vSel # SelCreate( 401, 1 );
  vSel->SelAddLink('', 400, 401, 3, 'Kopf');
  vSel->SelAddLink('', 402, 401, 11, 'Ausf');
  tErx # vSel->SelDefQuery('', vQ401 );
  if (tErx <> 0) then
    Lib_Sel:QError(vSel);
  tErx # vSel->SelDefQuery('Kopf', vQ400 );
  if (tErx <> 0) then
    Lib_Sel:QError(vSel);
  tErx # vSel->SelDefQuery('Ausf', vQ402);
  if (tErx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  vFlag # _RecFirst;
  WHILE (RecRead(cFile,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    if (aSort=1) then   vSortKey # cnvAF(Auf.P.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)+cnvAF(Auf.P.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Auf.P.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    if (aSort=2) then   vSortKey # cnvAI(Auf.P.Nummer,_FmtNumLeadZero,0,9)
    if (aSort=3) then   vSortKey # Auf.P.Best.Nummer
    if (aSort=4) then   vSortKey # Auf.P.KundenSW
    if (aSort=5) then   vSortKey # "Auf.P.Güte"+cnvAF(Auf.P.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)+cnvAF(Auf.P.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Auf.P.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    if (aSort=6) then   vSortKey # (cnvai(dateyear(Auf.P.Termin1Wunsch)+1900,_fmtNumNoGroup)+'.'+ cnvai(datemonth(Auf.P.Termin1Wunsch),_fmtNumNoGroup|_fmtNumLeadZero,0,2)+'.'+cnvai(dateday(Auf.P.Termin1Wunsch),_fmtNumNoGroup|_fmtNumLeadZero,0,2)
                                 + cnvai(datemonth("Auf.P.Termin1Wunsch"),_fmtNumNoGroup|_fmtNumLeadZero,0,2)+'.'
                                 + cnvai(dateday("Auf.P.Termin1Wunsch"),_fmtNumNoGroup|_fmtNumLeadZero,0,2))
                                 + "Auf.P.KundenSW"
                                 + cnvAF("Auf.P.Dicke",_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)+cnvAF("Auf.P.Breite",_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Auf.P.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    if (aSort=7) then   begin
     vSortKey # cnvai(cnvid(Auf.P.TerminZusage),_FmtNumLeadZero,0,9)+Auf.P.KundenSW+cnvAF(Auf.P.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)
      vSortkey # vSortkey +cnvAF(Auf.P.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Auf.P.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    end;

    Sort_ItemAdd(vTree,vSortKey,cFIle,RecInfo(cFile,_RecId));
  END;

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Ausgabe ----------------------------------------------------------------


  // Druckelemente generieren...
  List_FontSize # 8;
  g_Empty       # LF_NewLine('EMPTY');
  g_Sel1        # LF_NewLine('SEL1');
  g_Sel2        # LF_NewLine('SEL2');
  g_Sel3        # LF_NewLine('SEL3');
  g_Sel4        # LF_NewLine('SEL4');
  g_Sel5        # LF_NewLine('SEL5');
  g_Sel6        # LF_NewLine('SEL6');
  g_Sel7        # LF_NewLine('SEL7');
  g_Header      # LF_NewLine('HEADER');
  g_Auftrag     # LF_NewLine('AUFTRAG');
  g_Summe1      # LF_NewLine('SUMME1');

  // Liste starten
  LF_Init(true);    // Landscape

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Progress
    // if ( !vProgress->Lib_Progress:Step() ) then begin
    //   Sort_KillList(vTree);
    //   vProgress->Lib_Progress:Term();
    //   RETURN;
    // end;

    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    // Ablage?
    If (CnvIA(vItem->spCustom)=411) then RecBufCopy(411,401);

    Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
    Erx # RecLink(814,400,8,_recFirst);   // Währung holen
    if ("Auf.WährungFixYN") then Wae.VK.Kurs # "Auf.Währungskurs";

    vMenge  # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Gewicht, 'kg'/*Auf.P.MEH.Wunsch*/, Auf.P.MEH.Preis);
    //Rest?      vMenge  # Lib_Einheiten:WandleMEH(401, Auf.P.Prd.Rest.Stk, Auf.P.Prd.Rest.Gew, Auf.P.Prd.Rest, Auf.P.MEH.Wunsch, Auf.P.MEH.Preis);
    if(Auf.P.PEH <> 0) then
      vGesamt # Rnd((Auf.P.Grundpreis+Auf.P.Aufpreis) *  vMenge / CnvFI(Auf.P.PEH) ,2);
    vEinzel # Auf.P.Einzelpreis;

    if("Wae.VK.Kurs" <> 0.0) then begin
      vEinzel # Rnd(vEinzel / "Wae.VK.Kurs",2)
      vGesamt # Rnd(vGesamt / "Wae.VK.Kurs",2)
    end;

    LF_Print(g_Auftrag);

    AddSum(1,Auf.P.Prd.Rest.Gew);
    AddSum(2,Auf.P.Gewicht);
    AddSum(3,(vGesamt));

  END;

  LF_Print(g_Summe1);


  // Löschen der Liste

  Sort_KillList(vTree);
  // Liste beenden
  // vProgress->Lib_Progress:Term();
  LF_Term();




  // Druckelemente freigeben...
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Sel3);
  LF_FreeLine(g_Sel4);
  LF_FreeLine(g_Sel5);
  LF_FreeLine(g_Sel6);
  LF_FreeLine(g_Sel7);
  LF_FreeLine(g_Auftrag);
  LF_FreeLine(g_Summe1);



  SelDelete(cFile, vSelName);

end;

//========================================================================