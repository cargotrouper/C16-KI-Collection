@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Ein_500002
//                    OHNE E_R_G
//  Info        Wareneingang
//
//
//  06.09.2004  AI  Erstellung der Prozedur
//  30.07.2008  DS  QUERY
//  31.07.2009  TM  Erweiterte Darstellung (1137/304)
//  01.10.2013  AH  Bugfix
//  16.10.2013  AH  Anfragen
//  13.06.2022  AH  ERX
//  24.02.2023  TM  Listenauswertung grundsätzlich in Hauswährung HWN-Prj. 2465/62 für STD
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
  Erx         : int;
end

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
  Sel.Auf.von.LiefDat # 0.0.0;  Sel.Auf.bis.LiefDat # today;
  Sel.Auf.von.AufArt # 0;       Sel.Auf.bis.AufArt # 9999;
  Sel.Auf.von.Wgr # 0;          Sel.Auf.bis.Wgr # 9999;
  Sel.Auf.von.Projekt # 0;      Sel.Auf.bis.Projekt # 99999999;
  Sel.Auf.von.KostenSt # 0;     Sel.Auf.bis.KostenSt # 99999999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.500002','L_Ein_500002:AusSel');
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
  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Lieferantenstichwort');
  vHdl2->WinLstDatLineAdd('Projektnummer');
  vHdl2->WinLstDatLineAdd('Sachnummer');
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
Sub Print(aName : alpha);

local begin
  vAbmess   : alpha;
  vWert     : float;
end;

begin
  case aName of

    'Artikel' : begin

      StartLine();
      Endline();

      StartLine();
      Write(1, ZahlI(Ein.P.Nummer) +' / ' +  ZahlI(Ein.P.Position)                  ,n , 0);
      Write(2, AInt(Ein.P.Lieferantennr)   ,n ,0);
      Write(3, AInt(Ein.P.Warengruppe)   ,n ,0);

      if(Wgr.Dateinummer < 250) then begin
        Write(4, "Ein.P.Güte" ,n , 0);

        if ("Ein.E.Länge" = 0.0) then
        vAbmess  # ANum(Ein.E.Dicke,set.stellen.dicke) + ' x '
                 + ANum(Ein.E.Breite,set.stellen.Breite)
        else
        vAbmess  # ANum(Ein.E.Dicke,set.stellen.dicke) + ' x '
                 + ANum(Ein.E.Breite,set.stellen.Breite) + ' x '
                 + ANum("Ein.E.Länge","set.stellen.Länge");

        Write(5, vAbmess ,n , 0);
      end;

      if(Ein.P.Projektnummer <> 0) then
        Write(6, ZahlI(Ein.P.Projektnummer)                                    ,n , _LF_Int);

      if (Ein.E.Eingang_Datum <> 0.0.0) then
       Write(7, DatS(Ein.E.Eingang_Datum)                                      ,n ,_LF_Date);

      Write(8, ZahlF(Ein.E.Menge,2)                                            ,y , _LF_NUM, 2.0);
      Write(9, Ein.E.MEH                                                       ,n ,0);
//      Write(10, ZahlF(Ein.P.Einzelpreis,2)                                           ,n , _LF_NUM);
      
      // 2023-02-23 TM zu Prj. 2465/62: immer Hauswährung verwenden!
      // Write(10, ZahlF(Ein.E.preis,2)                                           ,n , _LF_NUM);
      Write(10, ZahlF(Ein.E.preisW1,2)                                           ,n , _LF_NUM);
      
      //if (list_XML = false) then
      Write(11, cnvai(Ein.P.PEH)+' '+Ein.P.MEH.Preis                           ,n , 0);

//      Write(12, ZahlF(Ein.P.Einzelpreis*(Ein.E.Menge/cnvfi(Ein.P.PEH)),2)      ,y , _LF_NUM);
      // vWert # Ein_data:SumGesamtpreis(Ein.E.Menge, Ein.P.MEH, "Ein.E.Stückzahl" , Ein.E.Gewicht);

      // 2023-03-09 TM: Exakte Umrechnung anhand PreisW1 aus Wareneingang
      vWert # Ein.E.Menge / cnvfi(Ein.P.PEH) * Ein.E.PreisW1;
      
      // 2023-02-23 TM zu Prj. 2465/62: Fremdwährung aus EK/Bestellung zurückrechnen auf Hauswährung
      /*
      Erx # RecLink(500,501,3,0);
      if ("Ein.Währung" != 1 ) then begin
        if ("Ein.WährungFixYN" and "Ein.Währungskurs" != 0.0) then
          //vWert # vWert * "Ein.Währungskurs";
          vWert # vWert / "Ein.Währungskurs"; // WertW1 = Wert dividiert durch Fixkurs
        else begin
          Erx # RecLink(814,500,8,0);
          if (Erx <=_rLocked) then
          vWert # vWert * "Wae.EK.Kurs"; // WertW1 = Wert multipliziert mit Währungskurs aus Schlüsseldaten
        end;
      end;
      */
      
      Write(12, ZahlF(vWert,2)      ,y , _LF_NUM);
      AddSum(1,vWert);
      AddSum(2,Ein.E.Menge);

      EndLine();

      StartLine();
      Write(1, ''   ,n ,0);
      Write(2, StrCut(Ein.P.LieferantenSW,1,10)   ,n ,0);
      Write(3, StrCut(Wgr.Bezeichnung.L1,1,11)   ,n ,0);
      Write(4, Ein.P.Artikelnr                                                      ,n , 0);
      Write(5, Ein.P.Artikelsw,n , 0);
      EndLine();
    end;

    'avg' : begin
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  #210.0;
      Startline();
      endline();
      StartLine();
      Write(1, GV.Alpha.19                ,n , 0);
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
      Write(1, 'BestellNr.'                   ,n , 0);
      Write(2, ': '                           ,n , 0);
      Write(3, ' von: '                       ,n , 0);
      Write(4, ZahlI(Sel.Auf.von.Nummer)      ,y , _LF_INT, 3.0);
      Write(5, ' bis: '                       ,n , 0);
      Write(6, ZahlI(Sel.Auf.bis.Nummer)      ,y , _LF_INT, 3.0);
      
      Write(7, 'ErfassDat.'                   ,n , 0);
      Write(8, ': '                           ,n , 0);
      Write(9, ' von: '                       ,n , 0);
      if (Sel.Auf.von.Datum<>0.0.0) then
        Write(10, DatS(Sel.Auf.von.Datum)     ,n , _LF_Date);
      Write(11, ' bis: '                      ,n , 0);
      if (Sel.Auf.bis.Datum<>0.0.0) then
        Write(12, DatS(Sel.Auf.bis.Datum)     ,n , _LF_Date, 3.0);
      
      Write(13, 'ProjektNr'                   ,n , 0);
      Write(14, ': '                          ,n , 0);
      Write(15, ' von: '                      ,n , 0);
      Write(16, ZahlI(Sel.Auf.von.Projekt)    ,y , _LF_INT, 3.0);
      Write(17, ' bis: '                      ,n , 0);
      Write(18, ZahlI(Sel.Auf.bis.Projekt)    ,y , _LF_INT);
      Endline();

      StartLine();
      Write(1, 'Kostenst.'                    ,n , 0);
      Write(2, ': '                           ,n , 0);
      Write(3, ' von: '                       ,n , 0);
      Write(4, ZahlI(Sel.Auf.von.Kostenst)    ,y , _LF_INT, 3.0);
      Write(5, ' bis: '                       ,n , 0);
      Write(6, ZahlI(Sel.Auf.bis.Kostenst)    ,y , _LF_Date, 3.0);

      //
      Write(7, 'Lieferdat.'                   ,n , 0);
      Write(8, ': '                           ,n , 0);
      Write(9, ' von: '                       ,n , 0);
      if (Sel.Auf.von.LiefDat<>0.0.0) then
        Write(10, DatS(Sel.Auf.von.LiefDat)   ,n , _LF_Date);
      Write(11, ' bis: '                      ,n , 0);
      if (Sel.Auf.bis.LiefDat<>0.0.0) then
        Write(12, DatS(Sel.Auf.bis.LiefDat)   ,n , _LF_Date, 3.0);
      //

      Write(13, 'Wunschter.'                  ,n , 0);
      Write(14, ': '                          ,n , 0);
      Write(15, ' von: '                      ,n , 0);
      if (Sel.Auf.von.WTermin<>0.0.0) then
        Write(16, DatS(Sel.Auf.von.WTermin)   ,n , _LF_Date);
      Write(17, ' bis: '                      ,n , 0);
      if (Sel.Auf.von.WTermin<>0.0.0) then
        Write(18, DatS(Sel.Auf.bis.WTermin)   ,n , _LF_Date,3.0);
      Endline();

      StartLine();
      Write(1, 'Vorgangsart'                  ,n , 0);
      Write(2, ': '                           ,n , 0);
      Write(3, ' von: '                       ,n , 0);
      Write(4, ZahlI(Sel.Auf.von.AufArt)      ,y , _LF_INT, 3.0);
      Write(5, ' bis: '                       ,n , 0);
      Write(6, ZahlI(Sel.Auf.bis.AufArt)      ,y , _LF_INT, 3.0);
      Write(7, 'Wgr'                          ,n , 0);
      Write(8, ': '                           ,n , 0);
      Write(9, ' von: '                       ,n , 0);
      Write(10, ZahlI(Sel.Auf.von.Wgr)        ,y , _LF_INT, 3.0);
      Write(11, ' bis: '                      ,n , 0);
      Write(12, ZahlI(Sel.Auf.bis.Wgr)        ,y , _LF_INT);
      Endline();


      StartLine();
      Write(1, 'Lieferant'                    ,n , 0);
      Write(2, ': '                           ,n , 0);
      Write(4, ZahlI(Sel.Auf.Kundennr)        ,y , _LF_INT, 3.0);
      Write(7, 'Sachbear.'                    ,n , 0);
      Write(8, ': '                           ,n , 0);
      Write(10, Sel.Auf.Sachbearbeit          ,n , 0);
      Write(13, 'ArtNr.'                      ,n , 0);
      Write(14, ': '                          ,n , 0);
      Write(16, Sel.Auf.Artikelnr             ,y , 0);
      Endline();


      // StartLine();
      // Write(1, 'Zusatzbem'                                           ,n , 0);
      // Write(2, ': '                                                  ,n , 0);
      // Write(4, GV.Alpha.01                                           ,n , 0);
      // Endline();

      StartLine();
      // Write(4, GV.Alpha.02                                           ,n , 0);
      Endline();

      StartLine();
      // Write(4, GV.Alpha.03                                           ,n , 0);
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

  print('Seitenkopf');
  Print('Selektierung');
  StartLine();
  EndLine();


  List_Spacing[ 1]  #   0.0;                    // Start Bestellnr
  List_Spacing[ 2]  # List_Spacing[ 1] + 35.0;  // Start Lieferant    = Ende Bestellnr
  List_Spacing[ 3]  # List_Spacing[ 2] + 20.0;  // Warengruppe
  List_Spacing[ 4]  # List_Spacing[ 3] + 24.0;  // Start Quali/Artnr  = Ende Lieferant
  List_Spacing[ 5]  # List_Spacing[ 4] + 36.0;  // Start Abm/Artstw   = Ende Quali/Artnr
  List_Spacing[ 6]  # List_Spacing[ 5] + 30.0;  // Start Projekt      = Ende Abm/Artstw
  List_Spacing[ 7]  # List_Spacing[ 6] + 15.0;  // Start EingDat      = Ende Projekt
  List_Spacing[ 8]  # List_Spacing[ 7] + 30.0;  // Start EingMenge    = Ende EingDat
  List_Spacing[ 9]  # List_Spacing[ 8] + 25.0;  // Start MEH          = Ende EingMenge 25
  List_Spacing[10]  # List_Spacing[ 9] + 12.0;  // Start Preis        = Ende MEH 12
  List_Spacing[11]  # List_Spacing[10] + 18.0;  // Start PEH          = Ende Preis
  List_Spacing[12]  # List_Spacing[11] + 10.0;  // Start Gesamt EK    = Ende PEH
  List_Spacing[13]  # List_Spacing[12] + 27.0;  // Ende Gesamt EK

  StartLine(_LF_UnderLine + _LF_Bold);
  Write( 1, 'Bestellnr.'                   ,n , 0);
  Write( 2, 'Lieferant'                    ,n , 0);
  Write( 3, 'Warengrp.'                    ,n , 0);
  Write( 4, 'Qualität    Artikelnummer'    ,n , 0);
  Write( 5, 'Abmessung   Artikelstichw.'   ,n , 0);
  Write( 6, 'Projekt'                   ,n , 0);
  Write( 7, 'Eing.Datum'                  ,n , 0);
  Write( 8, 'Eing.Menge'                   ,y , 0, 2.0);
  Write( 9, 'MEH'                          ,n , 0);
  Write(10, 'Preis'                        ,n , 0);
  Write(11, 'pro PEH'                      ,n , 0);
  Write(12, 'Gesamt EK'                    ,y , 0);
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

  vName       : alpha;
  vFlag       : int;        // Datensatzlese option
  vSel        : int;
  vSelName    : alpha;

  vMenge      : float;
  vGew        : float;
  vSummeRoh   : float;
  vSummeRest  : float;

  vOK         : logic;
  vX          : float;
  vA          : alpha;

  vTree       : int;
  vSortkey    : alpha;
  vItem       : int;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  vQAbl       : alpha(4000);
  vQ2Abl      : alpha(4000);
  
  tErx        : int;
end;
begin
  // Sortierung setzen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery für 501
  vQ # '';
  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQ, 'Ein.P.Lieferantennr', '=', Sel.Auf.Kundennr );
  if ( Sel.Auf.Artikelnr != '') then
   Lib_Sel:QAlpha( var vQ, 'Ein.P.Artikelnr', '=', Sel.Auf.Artikelnr );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != DateMake(31,12,DateYear(today))) then
    Lib_Sel:QVonBisD( var vQ, 'Ein.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'Ein.P.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );

  // Selektionsquery für 511
  vQAbl # '';
  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQAbl, 'Ein~P.Lieferantennr', '=', Sel.Auf.Kundennr );
  if ( Sel.Auf.Artikelnr != '') then
   Lib_Sel:QAlpha( var vQAbl, 'Ein~P.Artikelnr', '=', Sel.Auf.Artikelnr );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != DateMake(31,12,DateYear(today))) then
    Lib_Sel:QVonBisD( var vQAbl, 'Ein~P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQAbl, 'Ein~P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQAbl, 'Ein~P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQAbl, 'Ein~P.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQAbl, 'Ein~P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );

  // Selektionsquery für 500
  vQ2 # '';
  Lib_Sel:QAlpha(var vQ2, 'Ein.Vorgangstyp', '=', c_Bestellung);
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ2, 'Ein.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );

  // Selektionsquery für 510
  vQ2Abl # '';
  Lib_Sel:QAlpha(var vQ2Abl, 'Ein~Vorgangstyp', '=', c_Bestellung);
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ2Abl, 'Ein~Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );
  
  
  
  // Selektionsquery für 506
  Lib_Sel:QAlpha( var vQ3, 'Ein.E.Löschmarker', '=', '' );
  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ3, 'Ein.E.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( Sel.Auf.von.LiefDat != 0.0.0) or ( Sel.Auf.bis.LiefDat != today) then
    Lib_Sel:QVonBisD( var vQ3, '"Ein.E.Eingang_Datum"', Sel.Auf.von.LiefDat, Sel.Auf.bis.LiefDat );
  if (vQ3 != '') then vQ3 # vQ3 + ' AND ';
  vQ3 # vQ3 + ' Ein.E.EingangYN AND !Ein.E.AusfallYN ';
  if (vQ3 != '') then vQ3 # vQ3 + ' AND ';
  vQ3 # vQ3 + ' LinkCount(Kopf) > 0 AND LinkCount(Pos) > 0 ';

  // Selektion starten...
  vSel # SelCreate( 506, 1 );
  vSel->SelAddLink('', 501, 506, 1, 'Pos');
  vSel->SelAddLink('', 500, 506, 2, 'Kopf');
  vSel->SelAddLink('', 511, 506, 11, 'PosAbl');
  vSel->SelAddLink('', 510, 506, 10, 'KopfAbl');
  
  tErx # vSel->SelDefQuery('', vQ3 );
  vSel->Lib_Sel:QError();
  tErx # vSel->SelDefQuery('Pos', vQ );
  tErx # vSel->SelDefQuery('PosAbl', vQAbl );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery('Kopf', vQ2 );
  vSel->SelDefQuery('KopfAbl', vQ2Abl );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  // Selektion öffnen
  //vSelName # Sel_Build(vSel, 506, 'LST.500002',y,0);

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vFlag # _RecFirst;
  WHILE (RecRead(506,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    RecLink(501,506,1,_recFirst);   // Posten holen
    if (aSort=1) then
      vSortKey # Ein.E.Artikelnr;
    if (aSort=2) then
      vSortkey # Ein.P.LieferantenSW;
    if (aSort=3) then
      vSortKey # AInt(Ein.P.Projektnummer);
    if (aSort=4) then
      vSortKey # Ein.P.Sachnummer;
    Sort_ItemAdd(vTree,vSortKey,506,RecInfo(506,_RecId));
  END;

  // Selektion löschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(506,vSelName);

  
  // Listenformat starten
  ListInit(y); // KEIN Landscape

  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID); // Datensatz holen

    Erx # RecLink(501,506,1,_recFirst);               // Posten holen
    if(Erx > _rLocked) then
      RecBufClear(501);

    Erx # RecLink(250,501,2,_recFirst);               // Artikel holen
    if(Erx > _rLocked) then
      RecBufClear(250);

    Erx # RecLink(819, 501, 1, _recFirst);            // Wgr. holen
    if(Erx > _rLocked) then
      RecBufClear(819);

    Print('Artikel');
    //Gv.Num.01 # Ein.E.Menge * Ein.P.Einzelpreis / CnvFI(Ein.P.PEH);
  END;
  Startline(_LF_Overline);
//  Write(8,  ZahlF(GetSum(2),2) ,y,_LF_NUM,2.0);     // Menge
  Write(12, ZahlF(GetSum(1),2) ,y,_LF_NUM);           // Preis

  endline();
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================