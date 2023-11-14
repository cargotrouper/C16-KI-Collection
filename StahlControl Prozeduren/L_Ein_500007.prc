@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Ein_500007
//                    OHNE E_R_G
//  Info        Eingangsliste
//
//
//  14.01.2008  DS  Erstellung der Prozedur
//  30.07.2008  DS  QUERY
//  17.08.2010  TM  Selektions-Fixdatum 1.1.2010 getauscht durch 31.12. des aktuellen Jahres
//  01.10.2013  AH  Bugfix
//  16.10.2013  AH  Anfragenx
//  13.11.2013  TM  Bugfix Gesamtpreisberechnung Preiseinheit
//  02.12.2013  ST  Lageranschrift hinzugefügt (Projekt Knappstein : 1304/219)
//  23.03.2021  TM  Coilnummer in XML-Ausgabe eingefügt Prj. 2151/73 LZM
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
declare Print(aName : alpha);

define begin
  cFile : 506
  cSel  : 'LST.500007'
  cMask : 'SEL.LST.500007'
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Auf.ObfNr2        # 999;
  Sel.Auf.bis.Nummer    # 99999999;
  Sel.Auf.bis.Datum     # today;
  Sel.Auf.bis.WTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.ZTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.AufArt    # 999;
  Sel.Auf.bis.WGr       # 9999;
  Sel.Auf.bis.Projekt   # 99999999;
  Sel.Auf.bis.Dicke     # 999999.00;
  Sel.Auf.bis.Breite    # 999999.00;
  "Sel.Auf.bis.Länge"   # 999999.00;
  Sel.bis.Datum         # 31.12.2099;
  Sel.bis.Datum2        # 31.12.2099;

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
  vSort       : int;
  vSortName   : alpha;
end;
begin

  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd(Translate('Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Bestellnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Lieferanten-Stichwort'));
  vHdl2->WinLstDatLineAdd(Translate('Qualität * Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('WE-Datum'));
  vHdl2->WinLstDatLineAdd(Translate('VSB-Datum'));
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
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();   // Drucke grosse Überschrift
  StartLine();
  EndLine();
  if (aSeite=1) then begin
    List_Spacing[ 1]  #   0.0;
    List_Spacing[ 2]  #  80.0;
    List_Spacing[ 3]  # 160.0;
    List_Spacing[ 4]  # 240.0;

    StartLine();
    if (Sel.von.Datum <> 0.0.0) and (Sel.bis.Datum <> 0.0.0) then
      Write( 1, 'Eingangsdatum von ' + DatS(Sel.von.Datum) + ' bis ' + DatS(Sel.bis.Datum) ,n , 0)
    else if (Sel.von.Datum = 0.0.0) and (Sel.bis.Datum <> 0.0.0) then
      Write( 1, 'Eingangsdatum bis ' + DatS(Sel.bis.Datum) ,n , 0)
    else if (Sel.von.Datum <> 0.0.0) and (Sel.bis.Datum = 0.0.0) then
      Write( 1, 'Eingangsdatum von ' + DatS(Sel.von.Datum) ,n , 0);
    if (Sel.von.Datum2 <> 0.0.0) and (Sel.bis.Datum2 <> 0.0.0) then
      Write( 2, 'VSB-Datum von ' + DatS(Sel.von.Datum2) + ' bis ' + DatS(Sel.bis.Datum2) ,n , 0)
    else if (Sel.von.Datum2 = 0.0.0) and (Sel.bis.Datum2 <> 0.0.0) then
      Write( 2, 'VSB-Datum bis ' + DatS(Sel.bis.Datum2) ,n , 0)
    else if (Sel.von.Datum2 <> 0.0.0) and (Sel.bis.Datum2 = 0.0.0) then
      Write( 2, 'VSB-Datum von ' + DatS(Sel.von.Datum2) ,n , 0);
    EndLine();
    StartLine();
    Write( 1, 'Bestell-Nr von ' + AInt(Sel.Auf.von.Nummer) + ' bis ' + AInt(Sel.Auf.bis.Nummer) ,n , 0);
    // Erfassdatum
    if (Sel.Auf.von.Datum <> 0.0.0) and (Sel.Auf.bis.Datum <> 0.0.0) then
      Write( 2, 'Datum von ' + DatS(Sel.Auf.von.Datum) + ' bis ' + DatS(Sel.Auf.bis.Datum) ,n , 0)
    else if (Sel.Auf.von.Datum = 0.0.0) and (Sel.Auf.bis.Datum <> 0.0.0) then
      Write( 2, 'Datum bis ' + DatS(Sel.Auf.bis.Datum) ,n , 0)
    else if (Sel.Auf.von.Datum <> 0.0.0) and (Sel.Auf.bis.Datum = 0.0.0) then
      Write( 2, 'Datum von ' + DatS(Sel.Auf.von.Datum) ,n , 0);
    // Wunschtermin
    if (Sel.Auf.von.WTermin <> 0.0.0) and (Sel.Auf.bis.WTermin <> 0.0.0) then
      Write( 3, 'Wunsch Termin von ' + DatS(Sel.Auf.von.WTermin) + ' bis ' + DatS(Sel.Auf.bis.WTermin) ,n , 0)
    else if (Sel.Auf.von.WTermin = 0.0.0) and (Sel.Auf.bis.WTermin <> 0.0.0) then
      Write( 3, 'Wunsch Termin bis ' + DatS(Sel.Auf.bis.WTermin) ,n , 0)
    else if (Sel.Auf.von.WTermin <> 0.0.0) and (Sel.Auf.bis.WTermin = 0.0.0) then
      Write( 3, 'Wunsch Termin von ' + DatS(Sel.Auf.von.WTermin) ,n , 0);
    EndLine();
    StartLine();
    Write( 1, 'Vorgangsart von ' + AInt(Sel.Auf.von.AufArt) + ' bis ' + AInt(Sel.Auf.bis.AufArt) ,n , 0);
    Write( 2, 'Wgr von ' + AInt(Sel.Auf.von.Wgr) + ' bis ' + AInt(Sel.Auf.bis.Wgr) ,n , 0);
    // Zusagetermin
    if (Sel.Auf.von.ZTermin <> 0.0.0) and (Sel.Auf.bis.ZTermin <> 0.0.0) then
      Write( 3, 'Zusage  Termin von ' + DatS(Sel.Auf.von.ZTermin) + ' bis ' + DatS(Sel.Auf.bis.ZTermin) ,n , 0)
    else if (Sel.Auf.von.ZTermin = 0.0.0) and (Sel.Auf.bis.ZTermin <> 0.0.0) then
      Write( 3, 'Zusage  Termin bis ' + DatS(Sel.Auf.bis.ZTermin) ,n , 0)
    else if (Sel.Auf.von.ZTermin <> 0.0.0) and (Sel.Auf.bis.ZTermin = 0.0.0) then
      Write( 3, 'Zusage  Termin von ' + DatS(Sel.Auf.von.ZTermin) ,n , 0);

    EndLine();
    StartLine();
    Write( 1, 'Dicke von ' + ANum(Sel.Auf.von.Dicke,Set.Stellen.Dicke) + ' bis ' + ANum(Sel.Auf.bis.Dicke,Set.Stellen.Dicke) ,n , 0);
    Write( 2, 'Breite von ' + ANum(Sel.Auf.von.Breite,Set.Stellen.Breite) + ' bis ' + ANum(Sel.Auf.bis.Breite,Set.Stellen.Breite) ,n , 0);
    Write( 3, 'Länge von ' + ANum("Sel.Auf.von.Länge","Set.Stellen.Länge") + ' bis ' + ANum("Sel.Auf.bis.Länge","Set.Stellen.Länge") ,n , 0);
    EndLine();
    StartLine();
    Write( 1, 'Projekt von ' + AInt(Sel.Auf.von.Projekt) + ' bis ' + AInt(Sel.Auf.bis.Projekt) ,n , 0);
    Write( 2, 'Sachbearbeiter : ' +Sel.Auf.Sachbearbeit    ,n , 0);
    Write( 3, 'Lieferant : ' + AInt(Sel.Auf.Lieferantnr),n , 0);
    EndLine();
    StartLine();
    Write( 1, 'Güte : ' + "Sel.Auf.Güte" ,n , 0);
    Write( 2, 'ObfNr von ' + AInt(Sel.Auf.ObfNr) + ' bis '+ AInt(Sel.Auf.ObfNr2),n , 0);
    Write( 3, 'NUR MATERIAL',n,0);
    EndLine();
    StartLine();
    EndLine();
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 16.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 16.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 25.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 50.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 30.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 15.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 20.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 17.0;
  List_Spacing[10]  # List_Spacing[ 9] + 30.0;
  List_Spacing[11]  # List_Spacing[10] + 20.0;
  List_Spacing[12]  # List_Spacing[11] + 25.0;
  List_Spacing[13]  # List_Spacing[12] + 25.0;

  // Lagerort
  List_Spacing[14]  # List_Spacing[13] + 25.0;
  List_Spacing[15]  # List_Spacing[14] + 25.0;
  List_Spacing[16]  # List_Spacing[15] + 25.0;
  List_Spacing[17]  # List_Spacing[16] + 25.0;
  List_Spacing[18]  # List_Spacing[17] + 25.0;
  List_Spacing[19]  # List_Spacing[18] + 25.0;
  List_Spacing[20]  # List_Spacing[19] + 25.0;
  List_Spacing[21]  # List_Spacing[20] + 25.0;
  List_Spacing[22]  # List_Spacing[21] + 25.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'WE-Dat.'                               ,n,  0);
  Write(2,  'VSB-Dat.'                              ,y,  0);
  Write(3,  'Bestellnr.'                            ,y , 0 , 2.0);
  Write(4,  'Lieferantenstichwort'                  ,n , 0);
  Write(5,  'Qualität'                              ,n , 0);
  Write(6,  'Dicke'                                 ,y , 0 , 2.0);
  Write(7,  'Breite'                                ,y , 0 , 2.0);
  Write(8,  'Länge'                                 ,y , 0 , 2.0);
  Write(9,  'Gewicht kg'                            ,y , 0 , 2.0);
  Write(10, 'EK '+"Set.Hauswährung.Kurz"+'/t'       ,y , 0 , 2.0);
  Write(11, 'Gesamt '  + "Set.Hauswährung.Kurz"     ,y , 0 , 2.0);
  if(LIST_XML = true) then begin
    Write(12, 'Warengruppe'                         ,y , 0);
    
    Write(13, 'Coilnummer'                         ,n , 0);
    
    Write(14, 'Intrastat-Nr.'                       ,y , 0);
    Write(15, 'Lagerans. Stw'                       ,n , 0);
    Write(16, 'Name'                                ,n , 0);
    Write(17, 'Zusatz'                              ,n , 0);
    Write(18, 'Straße'                              ,n , 0);
    Write(19, 'LKZ'                                 ,n , 0);
    Write(20, 'PLZ'                                 ,n , 0);
    Write(21, 'Ort'                                 ,n , 0);
    Write(22, 'AB-Nr.'                                 ,n , 0);
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
//  Print
//
//========================================================================
Sub Print(aName   : alpha);
local begin
  vEinzel : float;
  vGesamt : float;
end;
begin
   case aName of

    'Position' : begin
      if ("Ein.WährungFixYN") then Wae.VK.Kurs # "Ein.Währungskurs";

      //vGesamt # (Ein.E.Menge * Ein.P.Einzelpreis) / cnvfi(Ein.P.PEH);
      //vEinzel # Ein.P.Einzelpreis;
//      vEinzel # Rnd(vEinzel / "Wae.VK.Kurs",2)
//      vGesamt # Rnd(vGesamt / "Wae.VK.Kurs",2)
//    vX # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Gewicht, Ein.P.MEH.Wunsch, Ein.P.MEH.Preis);

//      vEinzel # Mat.EK.Preis;
//      vGesamt # (Ein.E.Menge * vEinzel) / 1000.0;
      vGesamt # (Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Gewicht, Ein.P.MEH.Wunsch, Ein.P.MEH.Preis) * Ein.E.PreisW1 / cnvfi(Ein.P.PEH));
      vEinzel # 0.0;
      if (Ein.E.Gewicht<>0.0) then vEinzel # Rnd(vGesamt / Ein.E.Gewicht * 1000.0, 2);
      vGesamt # Rnd(vGesamt, 2);

      StartLine();
      if (Ein.E.Eingang_Datum <> 0.0.0) then
        Write(1, DatS(Ein.E.Eingang_Datum)        ,n , _LF_Date);
      if (Ein.E.VSB_Datum <> 0.0.0) then
        Write(2, DatS(Ein.E.VSB_Datum)                            ,y , _LF_Date);
      Write(3, ZahlI(Ein.P.Nummer) +'/ '+ ZahlI(Ein.P.Position)   ,y , 0 , 2.0);
      Write(4, Ein.P.LieferantenSW                                ,n , 0);
      Write(5, "Ein.E.Güte"                                       ,n , 0);
      Write(6, ZahlF(Ein.E.Dicke, Set.Stellen.Dicke)              ,y , _LF_NUM, 2.0);
      Write(7, ZahlF(Ein.E.Breite, Set.Stellen.Breite)            ,y , _LF_NUM, 2.0);
      if ("Ein.E.Länge" <> 0.00) then
        Write(8, ZahlF("Ein.E.Länge", "Set.Stellen.Länge")        ,y , _LF_NUM, 2.0);
      Write(9, ZahlF(Ein.E.Gewicht, Set.Stellen.Gewicht)          ,y , _LF_Num , 2.0);
      Write(10, ZahlF(vEinzel,2)                                  ,y , _LF_NUM, 2.0);
      Write(11, ZahlF(vGesamt,2)                                  ,y , _LF_NUM, 2.0);
      if(LIST_XML = true) then begin
        Write(12, ZahlI(Ein.E.Warengruppe)                        ,y , _LF_Int);

        Write(13, Mat.Coilnummer                                 ,n , 0);
        
        
        Write(14, Mat.Intrastatnr                                 ,n , 0);

        // Lageranschrift
        Write(15, Adr.A.Stichwort                                 ,n , 0);
        Write(16, Adr.A.Name                                      ,n , 0);
        Write(17, Adr.A.Zusatz                                    ,n , 0);
        Write(18, "Adr.A.Straße"                                  ,n , 0);
        Write(19, Adr.A.LKZ                                       ,n , 0);
        Write(20, Adr.A.PLZ                                       ,n , 0);
        Write(21, Adr.A.Ort                                       ,n , 0);
        Write(22, Ein.AB.Nummer                                   ,n , 0);
      end;
      EndLine();

      AddSum(1,vGesamt);
      AddSum(2,Ein.E.Gewicht);
    end;

    'Summe' : begin

      // Spezielles Spacing für Summen, damit Gesamt€ passt
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 9]  # 189.0;
      List_Spacing[11]  # List_Spacing[9] + 20.0;
      List_Spacing[12]  # List_Spacing[9] + 75.0;

      StartLine(_LF_Overline + _LF_Bold);
      Write( 9, ZahlF(GetSum(2),Set.Stellen.Gewicht)                                   ,y , 0 , 2.0)
      Write(11, ZahlF(GetSum(1),2)                                                     ,y , _LF_NUM, 2.0);
      EndLine();
      ResetSum(1);
      ResetSum(2);
    end;
  end; // CASE
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
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  vQ4         : alpha(4000);
  vQ5         : alpha(4000);
  vQ6         : alpha(4000);
  vLastDay    : date;
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen


  // BESTAND-Selektion öffnen

  vLastDay  # DateMake(31,12,DateYear(today));

  // Selektionsquery für 506
  vQ # '';

  if ( Sel.von.Datum != 0.0.0 ) or ( Sel.bis.Datum != 31.12.2099 ) then
    Lib_Sel:QVonBisD( var vQ, 'Ein.E.Eingang_Datum', Sel.Von.Datum, Sel.bis.Datum );
  if ( Sel.von.Datum2 != 0.0.0 ) or ( Sel.bis.Datum2 != 31.12.2099 ) then
    Lib_Sel:QVonBisD( var vQ, 'Ein.E.VSB_Datum', Sel.Von.Datum2, Sel.bis.Datum2);

  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.E.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( "Sel.Auf.Güte" != '') then
    Lib_Sel:QAlpha( var vQ, '"Ein.E.Güte"', '=*', "Sel.Auf.Güte" );
  if ( Sel.Auf.von.Dicke != 0.0 ) or ( Sel.Auf.bis.Dicke != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Ein.E.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke );
  if ( Sel.Auf.von.Breite != 0.0 ) or ( Sel.Auf.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Ein.E.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite );
  if ( "Sel.Auf.von.Länge" != 0.0 ) or ( "Sel.Auf.bis.Länge" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Ein.E.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge" );

  if (vQ<>'') then vQ # vQ + ' AND ';
  vQ # vQ + 'Ein.E.AusfallYN = FALSE';
  Lib_Sel:QAlpha(var vQ, '"Ein.E.Löschmarker"', '!=', '*'); // GELOESCHT?
  if ( Sel.Auf.ObfNr != 0) or ( Sel.Auf.ObfNr2 != 999) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Ausf) > 0 ';
  end;
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( LinkCount(Kopf) > 0 OR LinkCount(KopfA) > 0 ) ';
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( LinkCount(Pos) > 0 OR LinkCount(PosA) > 0 ) ';

  // Selektionsquery für 501
  vQ2 # '';
  if ( Sel.Auf.Lieferantnr != 0 ) then
    Lib_Sel:QInt( var vQ2, 'Ein.P.Lieferantennr', '=', Sel.Auf.Lieferantnr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ2, 'Ein.P.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != vLastDay) then
    Lib_Sel:QVonBisD( var vQ2, 'Ein.P.TerminZusage', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != vLastDay  ) then
    Lib_Sel:QVonBisD( var vQ2, 'Ein.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Ein.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Ein.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Ein.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  Lib_Sel:QInt( var vQ2, 'Ein.P.Wgr.Dateinr', '>=', 200 );
  Lib_Sel:QInt( var vQ2, 'Ein.P.Wgr.Dateinr', '<=', 209 );

  // Selektionsquery für 500
  vQ3 # '';
  Lib_Sel:QAlpha(var vQ3, '"Ein.Vorgangstyp"', '=', c_Bestellung);
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ3, 'Ein.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );


  // Selektionsquery für 511
  vQ4 # '';
  if ( Sel.Auf.Lieferantnr != 0 ) then
    Lib_Sel:QInt( var vQ4, '"Ein~P.Lieferantennr"', '=', Sel.Auf.Lieferantnr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ4, '"Ein~P.Anlage.Datum"', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != vLastDay) then
    Lib_Sel:QVonBisD( var vQ4, '"Ein~P.TerminZusage"', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != vLastDay) then
    Lib_Sel:QVonBisD( var vQ4, '"Ein~P.Termin1Wunsch"', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ4, '"Ein~P.Warengruppe"', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 999 ) then
    Lib_Sel:QVonBisI( var vQ4, '"Ein~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ4, '"Ein~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  Lib_Sel:QInt( var vQ4, '"Ein~P.Wgr.Dateinr"', '>=', 200 );
  Lib_Sel:QInt( var vQ4, '"Ein~P.Wgr.Dateinr"', '<=', 209 );

  // Selektionsquery für 510
  vQ5 # '';
  Lib_Sel:QAlpha(var vQ5, '"Ein~Vorgangstyp"', '=', c_Bestellung);
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ5, '"Ein~Sachbearbeiter"', '=', Sel.Auf.Sachbearbeit );

  //Selektionsquery für 507
  vQ6 # '';
  if ( Sel.Auf.ObfNr != 0 ) or ( Sel.Auf.ObfNr2 != 999 ) then
    Lib_Sel:QVonBisI( var vQ6, 'Ein.E.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2 );


  // Selektion starten...
  vSel # SelCreate( 506, 1 );
  vSel->SelAddLink('', 501, 506, 1, 'Pos');
  vSel->SelAddLink('', 500, 506, 2, 'Kopf');
  vSel->SelAddLink('', 511, 506, 11, 'PosA');
  vSel->SelAddLink('', 510, 506, 10, 'KopfA');
  vSel->SelAddLink('', 507, 506, 13, 'Ausf');
  Erx # vSel->SelDefQuery('', vQ );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Pos', vQ2 );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Kopf',  vQ3 );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('PosA',  vQ4 );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('KopfA', vQ5 );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Ausf',  vQ6 );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 506, cSel,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(506,vSel,vFlag) <= _rLocked ) DO BEGIN
    Erx # RecLink(501,506,1,_recFirst);
    if (Erx > _rLocked) then begin
      Erx # RecLink(511,506,11,_recFirst);
      if (Erx > _rLocked) then RecBufClear(511);
      RecBufCopy(511,501);
    end;
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    if (aSort=1) then vSortKey # cnvAF(Ein.E.Dicke,_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF(Ein.E.Breite,_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Ein.E.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
    if (aSort=2) then vSortKey # cnvAI(Ein.E.Nummer,_FmtNumLeadZero,0,13);
    if (aSort=3) then vSortKey # Ein.P.LieferantenSW;
    if (aSort=4) then vSortKey # "Ein.E.Güte" + cnvAF(Ein.E.Dicke,_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF(Ein.E.Breite,_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Ein.E.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
    if (aSort=5) then vSortKey # cnvAI(cnvID(Ein.E.Eingang_Datum),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    if (aSort=6) then vSortKey # cnvAI(cnvID(Ein.E.VSB_Datum),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    Sort_ItemAdd(vTree,vSortKey,506,RecInfo(506,_RecId));
  END;
  SelClose(vSel);
//  SelDelete(506, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y);              // starte Landscape

  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    Mat_Data:Read(Ein.E.Materialnr);

    Ein_Data:Read(Ein.E.Nummer, Ein.E.Position, true);

    Erx # RecLink(814,506,16,_recFirst);   // Währung holen
    if(Erx > _rLocked) then
      RecBufClear(814);

    RekLink(101,506,7,0);                 // Lageranschrift holen
    RekLink(500,506,2,0);                 // Bestellkopf holen
    Print('Position');
  END;
  Print('Summe'); //Summen drucken

  // Löschen der Liste
  Sort_KillList(vTree);

  ListTerm();
end;

//========================================================================