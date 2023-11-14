@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Ein_500009
//                    OHNE E_R_G
//  Info        Bestellrückstand MAT ausgeben
//
//
//  06.09.2004  AI  Erstellung der Prozedur
//  29.07.2008  DS  QUERY
//  03.01.2013  TM  Standardanpassung für Bestellrückstand Material
//  16.10.2013  AH  Anfragenx
//  14.11.2013  ST  Nachkommastellen bei Abmessungen hinzugefügt
//  06.11.2014  ST  Bugfix: Selektionsausgabe  Projekt 1326/406
//  28.10.2020  TM  Korrektur für XML-Ausgabe Projekt 2114/6
//  23.03.2021  TM  Erweiterung XML-Ausgabe gem. Prj. 2151/72 LZM
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
// @I:Def_List
@I:Def_List2
declare StartList(aSort : int; aSortName : alpha);

define begin
  cGesSumBestmng      : 1
  cGesSumRueckstand   : 2

  cFile : 501
  cSel  : 'LST.500009'
  cMask : 'SEL.LST.500009'

end;

// Handles für die Zeilenelemente
local begin
  g_Empty     : int;
  g_Sel1      : int;
  g_Sel2      : int;
  g_Sel3      : int;
  g_Sel4      : int;
  g_Sel5      : int;
  g_Sel6      : int;
  g_Header    : int;
  g_Material  : int;
  g_Summe     : int;
  g_ListEnd1  : int;
  g_ListEnd2  : int;
  g_Leselinie : logic;
end;


//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Auf.bis.Nummer    # 99999999;
  Sel.Auf.bis.Datum     # today;
  Sel.Auf.bis.WTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.ZTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.AufArt    # 999;
  Sel.Auf.bis.WGr       # 9999;
  Sel.Auf.ObfNr2        # 999;
  Sel.Auf.bis.Projekt   # 99999999;
  Sel.Auf.bis.Dicke     # 999999.00;
  Sel.Auf.bis.Breite    # 999999.00;
  "Sel.Auf.bis.Länge"   # 999999.00;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI, cMask, here+':AusSel');
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
  vHdl2->WinLstDatLineAdd(Translate('Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Lieferanten-Stichwort'));

  vHdl2->wpcurrentint#1;
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
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  Erx   : int;
  vLine : int;
  vObf  : alpha(120);
  
  vVsbDat : date;
  vEinDat : date;
  vWunschKw   : word;
  vWunschJahr : word;
  vWunschterm : alpha;
end;

begin

  case aName of

    'EMPTY' : begin
      if (aPrint) then RETURN;
    end;

    'SEL1' : begin
      if (aPrint) then RETURN;

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

      LF_Set(1, 'BestellNr.'                ,n ,0);
      LF_Set(2, ': '                        ,n ,0);
      LF_Set(3, ' von: '                    ,n ,0);
      LF_Set(4, Aint(Sel.Auf.von.Nummer)    ,y ,0);
      LF_Set(5, ' bis: '                    ,n ,0);
      LF_Set(6, Aint(Sel.Auf.bis.Nummer)    ,y ,0);
      LF_Set(7, 'ErfassDat.'                ,n ,0);
      LF_Set(8, ': '                        ,n ,0);
      LF_Set(9, ' von: '                    ,n ,0);
      if (Sel.Auf.von.Datum<>0.0.0) then
        LF_Set(10, CnvAd(Sel.Auf.von.Datum) ,n ,0);
      LF_Set(11, ' bis: '                   ,n ,0);
      if (Sel.Auf.bis.Datum<>0.0.0) then
        LF_Set(12, CnvAd(Sel.Auf.bis.Datum) ,n ,0);
      LF_Set(13, 'ProjektNr'                ,n ,0);
      LF_Set(14, ': '                       ,n ,0);
      LF_Set(15, ' von: '                   ,n ,0);
      LF_Set(16, Aint(Sel.Auf.von.Projekt)  ,y ,0);
      LF_Set(17, ' bis: '                   ,n ,0);
      LF_Set(18, Aint(Sel.Auf.bis.Projekt)  ,y ,0);

    End;

    'SEL2' : begin
      if (aPrint) then RETURN;

      LF_Set(1, 'Wunschter'                 ,n , 0);
      LF_Set(2, ': '                        ,n , 0);
      LF_Set(3, ' von: '                    ,n , 0);
      if (Sel.Auf.von.WTermin<>0.0.0) then
        LF_Set(4, CnvAd(Sel.Auf.von.WTermin)    ,n , 0);
      LF_Set(5, ' bis: '                    ,n , 0);
      if (Sel.Auf.von.WTermin<>0.0.0) then
        LF_Set(6, CnvAd(Sel.Auf.bis.WTermin)    ,y , 0);
      LF_Set(7, 'Vorgangsart'               ,n , 0);
      LF_Set(8, ': '                        ,n , 0);
      LF_Set(9, ' von: '                    ,n , 0);
      LF_Set(10, Aint(Sel.Auf.von.AufArt)   ,y , 0);
      LF_Set(11, ' bis: '                   ,n , 0);
      LF_Set(12, Aint(Sel.Auf.bis.AufArt)   ,y , 0);
      LF_Set(13, 'Wgr'                      ,n , 0);
      LF_Set(14, ': '                       ,n , 0);
      LF_Set(15, ' von: '                   ,n , 0);
      LF_Set(16, Aint(Sel.Auf.von.Wgr)      ,y , 0);
      LF_Set(17, ' bis: '                   ,n , 0);
      LF_Set(18, Aint(Sel.Auf.bis.Wgr)      ,y , 0);
 
    
    End;

    'SEL3' : begin
      if (aPrint) then RETURN;

      LF_Set(1, 'Lieferant'                 ,n ,0);
      LF_Set(2, ': '                        ,n ,0);
      LF_Set(4, Aint(Sel.Auf.Lieferantnr)         ,y ,0);
      LF_Set(7, 'Sachbear'                  ,n ,0);
      LF_Set(8, ': '                        ,n ,0);
      LF_Set(10, Sel.Auf.Sachbearbeit       ,n ,0);
      LF_Set(13, 'ArtNr'                    ,n ,0);
      LF_Set(14, ': '                       ,n ,0);
      LF_Set(16, Sel.Auf.Artikelnr          ,y ,0);

    End;

    'SEL4' : begin
      if (aPrint) then RETURN;
/*
      LF_Set(1, 'Zusatzbem'                 ,n , 0);
      LF_Set(2, ': '                        ,n , 0);
      LF_Set(4, GV.Alpha.01               ,n , 0);
*/
    End;

    'SEL5' : begin
      if (aPrint) then RETURN;
/*
      LF_Set(1, 'Zusatzbem'                 ,n , 0);
      LF_Set(2, ': '                        ,n , 0);
      LF_Set(4, GV.Alpha.02               ,n , 0);
*/
    End;

    'SEL6' : begin
      if (aPrint) then RETURN;
/*
      LF_Set(1, 'Zusatzbem'                 ,n , 0);
      LF_Set(2, ': '                        ,n , 0);
      LF_Set(4, GV.Alpha.03               ,n , 0);
*/
    End;

    'HEADER' : begin

      LF_Format(_LF_UnderLine + _LF_Bold);
      List_Spacing[ 1]  # 0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 35.0;
      List_Spacing[ 3]  # List_Spacing[ 2] + 40.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 20.0;
      List_Spacing[ 5]  # List_Spacing[ 4] + 20.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;
      List_Spacing[ 7]  # List_Spacing[ 6] + 20.0;
      List_Spacing[ 8]  # List_Spacing[ 7] + 25.0;
      List_Spacing[ 9]  # List_Spacing[ 8] + 15.0;
      List_Spacing[ 10] # List_Spacing[ 9] + 25.0;
      List_Spacing[ 11] # List_Spacing[10] + 30.0;
      List_Spacing[ 12] # List_Spacing[11] + 30.0;
      
      // ab hier: XML
      List_Spacing[ 13] # List_Spacing[12] + 10.0;
      List_Spacing[ 14] # List_Spacing[13] + 10.0;
      List_Spacing[ 15] # List_Spacing[14] + 10.0;
      List_Spacing[ 16] # List_Spacing[15] + 10.0;
      List_Spacing[ 17] # List_Spacing[16] + 10.0;
      List_Spacing[ 18] # List_Spacing[17] + 10.0;
      List_Spacing[ 19] # List_Spacing[18] + 10.0;
      List_Spacing[ 20] # List_Spacing[19] + 10.0;
      List_Spacing[ 21] # List_Spacing[20] + 10.0;
      List_Spacing[ 22] # List_Spacing[21] + 10.0;
      List_Spacing[ 23] # List_Spacing[22] + 10.0;

      if (aPrint) then RETURN;

      LF_Set(1, 'Lieferant'       ,n ,0);
      LF_Set(2, 'Bestellung'      ,n ,0);
      LF_Set(3, 'Güte'            ,n ,0);
      LF_Set(4, 'Dicke'           ,y ,0);
      LF_Set(5, 'Breite'          ,y ,0);
      LF_Set(6, 'Länge'           ,y ,0);
      LF_Set(7, 'Menge'           ,y ,0);
      LF_Set(8, 'MEH'             ,n ,0);
      LF_Set(9, 'Offen'           ,y ,0);
      LF_Set(10, 'Termin'         ,n ,0);
      LF_Set(11, 'neuer Termin'   ,n ,0);
      
      if(LIST_XML = true) then begin
        // neu zu Prj 2151/72
        LF_Set(12, 'Bestelldat.'  ,n ,0);
        LF_Set(13, 'Oberfläche 1' ,n ,0);
        LF_Set(14, 'Eingang'      ,n ,0);
        LF_Set(15, 'VSB'          ,n ,0);
        LF_Set(16, 'Termin KW'    ,n ,0);
        LF_Set(17, 'Zusagetermin' ,n ,0);
        LF_Set(18, 'AB'           ,n ,0);
        LF_Set(19, 'Grundpreis'   ,y ,0);
        LF_Set(20, 'Einzelpreis'  ,y ,0);
        LF_Set(21, 'Kommission'   ,n ,0);
        LF_Set(22, 'Res. Kunde'   ,n ,0);
      end;
      

    End;

    'MATERIAL' : begin

      List_Spacing[ 1]  # 0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 35.0;
      List_Spacing[ 3]  # List_Spacing[ 2] + 40.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 20.0;
      List_Spacing[ 5]  # List_Spacing[ 4] + 20.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;
      List_Spacing[ 7]  # List_Spacing[ 6] + 20.0;
      List_Spacing[ 8]  # List_Spacing[ 7] + 25.0;
      List_Spacing[ 9]  # List_Spacing[ 8] + 15.0;
      List_Spacing[ 10] # List_Spacing[ 9] + 25.0;
      List_Spacing[ 11] # List_Spacing[10] + 30.0;
      List_Spacing[ 12] # List_Spacing[11] + 30.0;

      
      vVsbDat # 0.0.0;
      vEinDat # 0.0.0;
      FOR Erx # RecLink(506,501, 14, _recFirst);
      LOOP Erx # RecLink(506,501, 14, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN
        if (Ein.E.VSB_Datum != 0.0.0) and (vVSBdat < Ein.E.VSB_Datum)  then vVSBdat # Ein.E.VSB_Datum;
        if (Ein.E.Eingang_Datum != 0.0.0) and (vEindat < Ein.E.Eingang_Datum)  then vEindat # Ein.E.Eingang_Datum;
      END;
      
      RecBufClear(203);
      FOR Erx # RecLink(203,200, 13, _recFirst);
      LOOP Erx # RecLink(203,200, 13, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN
        if (Mat.R.KundenSW !='') then begin
          BREAK;
        end;
      END;
      
      
      
      LF_Text(1,Adr.Anrede + ' ' + Adr.Name );
      LF_Text(2,ZahlI(Ein.P.Nummer) + ' / ' + ZahlI(Ein.P.Position));
      LF_Text(3,"Ein.P.Güte" + ' ' + "Ein.P.Gütenstufe");

      // --- aktuellstes Vsb- / Eingangsdatum mitdrucken wenn vorhanden
      if vVsbDat != 0.0.0 then
        Lf_Text(14,cnvad(vVsbDat))
      else
        Lf_Text(14,'');
      
      if vEinDat != 0.0.0 then
        Lf_Text(15,cnvad(vEinDat))
      else
        Lf_Text(15,'');
      
      Lib_Berechnungen:KW_aus_Datum(Ein.P.Termin1Wunsch,var vWunschKw, var vWunschJahr);
      vWunschterm # ZahlI(vWunschKw)+'/'+ZahlI(vWunschJahr);
      Lf_Text(16,vWunschTerm);

      if (Ein.P.AB.Nummer ='') then
        Lf_Text(18,Ein.AB.Nummer)
      else
        Lf_Text(18,Ein.P.AB.Nummer);



      if (aPrint) then RETURN;

      LF_Set(1, 'Anrede+Name'             ,n ,0);
      LF_Set(2, 'Bestellung+Pos'          ,n ,0);
      LF_Set(3, 'Güte+Gütenstufe'         ,n ,0);
      LF_Set(4, '@Ein.P.Dicke'            ,y , _LF_NUM, Set.Stellen.Dicke);
      LF_Set(5, '@Ein.P.Breite'           ,y , _LF_NUM, Set.Stellen.Breite);
      LF_Set(6, '@Ein.P.Länge'            ,y ,_LF_NUM, "Set.Stellen.Länge");
      LF_Set(7, '@Ein.P.Menge'            ,y ,_LF_NUM, Set.Stellen.Menge);
      LF_Set(8, '@Ein.P.MEH'              ,n ,0);
      LF_Set(9, '@Ein.P.FM.Rest'          ,y ,_LF_NUM,Set.Stellen.Menge);
      if (Ein.P.Termin1Wunsch <> 0.0.0) then
        LF_Set(10, '@Ein.P.Termin1Wunsch' ,n ,0); // Darstellung in Terminformat OK? (DA/KW/QU etc.)
      LF_Set(11, '_____________________'  ,n ,0);

    if(LIST_XML = true) then begin
        // neu zu Prj 2151/72
        LF_Set(12, '@Ein.Datum'           ,n ,0);
        LF_Set(13, '@Ein.P.AusfOben'      ,n ,0);
        LF_Set(14, 'Eingang'              ,n ,0);
        LF_Set(15, 'VSB'                  ,n ,0);
        LF_Set(16, 'Termin KW'            ,n ,0);
        LF_Set(17, '@Ein.P.TerminZusage'  ,n ,0);
        LF_Set(18, 'BestellAB'            ,n ,0);
        LF_Set(19, '@Ein.P.Grundpreis'    ,y ,0);
        LF_Set(20, '@Ein.P.Einzelpreis'   ,y ,0);
        LF_Set(21, '@Ein.P.Kommission'    ,n ,0);
        LF_Set(22, '@Mat.R.KundenSW'      ,n ,0);
      end;
    
    
    
    
    
    
    
    
    
    end;

    'SUMME' : begin
      LF_Format(_LF_OverLine);

      LF_Text(7,ZahlF(GetSum(cGesSumBestmng),Set.Stellen.Menge));
      LF_Text(9,ZahlF(GetSum(cGesSumRueckstand), Set.Stellen.Menge));

      if (aPrint) then RETURN;

      LF_Set(7, 'RestSumme'               ,y, _LF_Num, Set.Stellen.Menge);
      LF_Set(8, '@Ein.P.MEH'              ,n ,0);
      LF_Set(9, 'RueckSumme'              ,y, _LF_Num, Set.Stellen.Menge);

    end;

    'LISTEND1' : begin
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  #210.0;

      if (aPrint) then RETURN;

      LF_Set(1, '@GV.Alpha.19'            ,n ,0);
    End;

    'LISTEND2' : begin

      if (aPrint) then RETURN;

      LF_Set(1, '@GV.Alpha.20'            ,n ,0);
    End;

  end; // CASE
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

  vTree       : int;
  vProgress   : int;
  vSortKey    : alpha;
  vItem       : int;
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery für 501
  vQ # '';
  Lib_Sel:QInt(var vQ, 'Ein.P.Nummer', '<', 1000000000);
  if (Sel.Auf.von.Nummer != 0) or (Sel.Auf.bis.Nummer != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Ein.P.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer);
  if (Sel.Auf.Lieferantnr != 0) then
    Lib_Sel:QInt(var vQ, 'Ein.P.Lieferantennr', '=', Sel.Auf.Lieferantnr);
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
  Lib_Sel:QAlpha(var vQ2, '"Ein.Vorgangstyp"', '=', c_Bestellung);
  if (Sel.Auf.Sachbearbeit != '') then
   Lib_Sel:QAlpha(var vQ2, 'Ein.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit);

  vQ3 # '';
    Lib_Sel:QInt(var vQ, 'Wgr.Dateinummer', '<=', 209);


  // Selektion starten...
  vSel # SelCreate(501, 2);
  vSel->SelAddLink('', 819, 501, 1, 'Wgr');
  vSel->SelAddLink('', 500, 501, 3, 'Kopf');


  tErx # vSel->SelDefQuery('', vQ);
  tErx # vSel->SelDefQuery('Wgr', vQ3);
  tErx # vSel->SelDefQuery('Kopf', vQ2);


  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 501, _recCount, vSel ) );

  FOR Erx # RecRead(501, vSel, _recFirst);
  LOOP Erx # RecRead(501, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      SelClose(vSel);
      SelDelete(501, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;



    if (aSort =1) then vSortKey # cnvAF(Ein.P.Dicke,_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF(Ein.P.Breite,_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Ein.P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
    if (aSort =2) then vSortKey # cnvAI("Ein.P.Lieferantennr",_FmtNumLeadZero|_fmtNumNoGroup,0,8)+cnvAI("Ein.P.Nummer",_FmtNumLeadZero|_fmtNumNoGroup,0,8)+cnvAI("Ein.P.Position",_FmtNumLeadZero|_fmtNumNoGroup,0,5);
    Sort_ItemAdd(vTree,vSortKey,501,RecInfo(501,_RecId));
  END;
  SelClose(vSel);
  SelDelete(501, vSelName);
  vSel # 0;







  RecLink(100,501,4,_recFirst);                   // Lieferant holen


  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset('Listengenerierung', CteInfo(vTree, _cteCount ));

  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Sel3      # LF_NewLine('SEL3');
  g_Sel4      # LF_NewLine('SEL4');
  g_Sel5      # LF_NewLine('SEL5');
  g_Sel6      # LF_NewLine('SEL6');
  g_Header    # LF_NewLine('HEADER');
  g_Material  # LF_NewLine('MATERIAL');
  g_Summe     # LF_NewLine('SUMME');
  g_ListEnd1  # LF_NewLine('LISTEND1');
  g_ListEnd2  # LF_NewLine('LISTEND2');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape

  vLf # -1;
  vFlag # _RecFirst;

  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) DO BEGIN
    if ( !vProgress->Lib_Progress:Step() ) then begin // Progress
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen

    if (vLf<>Ein.P.Lieferantennr) then begin
      if (vLf<>-1) then begin


        if (aSort =2) and (List_XML=n) then begin
          if (vLf <> Ein.P.Lieferantennr) then begin
            LF_Print(g_Summe);
            LF_Print(g_Empty);
            vSumMenge # 0.0;
            vSumRueck # 0.0;
          end;
        end;

        // LF_Print(g_ListEnd1);
        // LF_Print(g_ListEnd2);
        // LF_Print(g_Empty);

      end;
      RecLink(100,501,4,_recFirst);                  // Lieferant holen
      vLf # Ein.P.Lieferantennr;
    end;

    Erx # RecLink(500,501,3,_recFirst);             // BestellKopf holen
    if(Erx > _rLocked) then
      RecBufClear(500);
    
    
    Erx # RecLink(200,501,13,_recFirst);             // Bestell-Materialkarte holen
    if(Erx > _rLocked) then
      RecBufClear(200);

    if (Ein.P.TerminZusage<>0.0.0) then             // Zusagetermin ggf. drucken
      Ein.P.Termin1Wunsch # Ein.P.TerminZusage;

    if  (List_XML=n) then begin
      LF_Print(g_Empty);
    end;

    LF_Print(g_Material);

    vSumMenge # vSumMenge + Ein.P.Menge;
    vSumRueck # vSumRueck + Ein.P.FM.Rest;
    AddSum(cGesSumBestmng   , Ein.P.Menge);
    AddSum(cGesSumRueckstand, Ein.P.FM.Rest);

  END;

  LF_Print(g_Summe);
  Sort_KillList(vTree); // Löschen der Liste

  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Sel3);
  LF_FreeLine(g_Sel4);
  LF_FreeLine(g_Sel5);
  LF_FreeLine(g_Sel6);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Material);
  LF_FreeLine(g_Summe);
  LF_FreeLine(g_ListEnd1);
  LF_FreeLine(g_ListEnd2);

end;

//========================================================================