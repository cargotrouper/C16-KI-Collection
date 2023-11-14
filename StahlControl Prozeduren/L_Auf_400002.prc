@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Auf_400002
//                    OHNE E_R_G
//  Info        Eingangsliste
//
//
//  05.03.2007  AI  Erstellung der Prozedur
//  31.07.2008  DS  QUERY
//  17.08.2010  TM  Selektions-Fixdatum 1.1.2010 getauscht durch 31.12. des aktuellen Jahres
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

declare StartList(aSort : int; aSortName : alpha);
declare Print(aName : alpha);

define begin
  cFile : 401
  cSel  : 'LST.400002'
  cMask : 'SEL.LST.400002'
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
  Sel.Auf.bis.AufArt    # 9999;
  Sel.Auf.bis.WGr       # 9999;
  Sel.Auf.bis.DruckDat  # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.LiefDat   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.Projekt   # 99999999;
  Sel.Auf.bis.Kostenst  # 99999999;
  Sel.Auf.bis.Dicke     # 999999.00;
  Sel.Auf.bis.Breite    # 999999.00;
  "Sel.Auf.bis.Länge"   # 999999.00;

  List_FontSize         # 7;

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
  vHdl2->WinLstDatLineAdd(Translate('Auftragsnr.'));
  vHdl2->WinLstDatLineAdd(Translate('Bestellnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Erfassdatum'));
  vHdl2->WinLstDatLineAdd(Translate('Kunden-Stichwort'));
  vHdl2->WinLstDatLineAdd(Translate('Qualität * Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Wunschtermin'));
  vHdl2->WinLstDatLineAdd(Translate('Zusagetermin'));
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
    List_Spacing[ 2]  #   20.0;
    List_Spacing[ 3]  #   22.0;
    List_Spacing[ 4]  #   30.0;
    List_Spacing[ 5]  #   50.0;
    List_Spacing[ 6]  #   57.0;
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
    StartLine();
    Write( 1, 'AuftragsNr'                                       ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  ZahlI(Sel.Auf.von.Nummer)                          ,n , _LF_INT);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  ZahlI(Sel.Auf.bis.Nummer)                          ,y , _LF_INT, 2.0);
    Write(7, 'Datum'                                             ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(9, 'von: '                                             ,n , 0);
    Write(10, Cnvad(Sel.Auf.von.Datum)                           ,n , 0);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12,  cnvad(Sel.Auf.bis.Datum)                          ,y , 0, 2.0);
    Write(13, 'Wunsch'                                           ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(15, ' von: '                                           ,n , 0);
    Write(16, Cnvad(Sel.Auf.von.WTermin)                         ,n , 0);
    Write(17, ' bis: '                                           ,n , 0);
    Write(18, cnvad(Sel.Auf.bis.WTermin)                         ,y , 0, 2.0);
    EndLine();
    StartLine();
    Write( 1, 'AufArt'                                           ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  ZahlI(Sel.Auf.von.AufArt)                          ,n , _LF_INT);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  ZahlI(Sel.Auf.bis.AufArt)                          ,y , _LF_INT, 2.0);
    Write(7, 'Wgr'                                              ,n , 0);
    Write(8, ': '                                                ,n , 0);  List_Spacing[11]  # List_Spacing[10] + 20.0;
/*
  List_Spacing[12]  # List_Spacing[11] + 30.0;
  List_Spacing[13]  # List_Spacing[12] + 35.0;
  List_Spacing[14]  # List_Spacing[13] + 13.0;
  List_Spacing[15]  # List_Spacing[14] + 20.0;*/
    Write(10, ZahlI(Sel.Auf.von.Wgr)                             ,n , _LF_INT);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12,  ZahlI(Sel.Auf.bis.Wgr)                            ,y , _LF_INT, 2.0);
    Write(13, 'Kundennr'                                         ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(16, ZahlI(Sel.Auf.Kundennr)                            ,n , _LF_INT);

    EndLine();
    StartLine();
    Write( 1, 'Artikelnr'                                           ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(4, Sel.Auf.Artikelnr                          ,n , 0);
    Write(7, 'Sachbear.'                                              ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(10, Sel.Auf.Sachbearbeit                            ,n , 0);
    Write(13, 'Vertreternr'                                         ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(16, ZahlI(Sel.Auf.Vertreternr)                            ,n , _LF_INT);
    EndLine();
    StartLine();
    Write( 1, 'DruckDat'                                       ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  Cnvad(Sel.Auf.von.DruckDat)                          ,n , 0);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  cnvad(Sel.Auf.bis.DruckDat)                          ,y , 0, 2.0);
    Write(7, 'LiefDat'                                             ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(9, 'von: '                                             ,n , 0);
    Write(10, Cnvad(Sel.Auf.von.LiefDat)                           ,n , 0);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12,  cnvad(Sel.Auf.bis.LiefDat)                          ,y , 0, 2.0);
    Write(13, 'Projekt'                                           ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(15, ' von: '                                           ,n , 0);
    Write(16, ZahlI(Sel.Auf.von.Projekt)                         ,n , _LF_INT);
    Write(17, ' bis: '                                           ,n , 0);
    Write(18, ZahlI(Sel.Auf.bis.Projekt)                         ,y , _LF_INT, 2.0);
    EndLine();
    StartLine();
    Write( 1, 'Kostenst'                                       ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  ZahlI(Sel.Auf.von.Kostenst)                          ,n , _LF_INT);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  ZahlI(Sel.Auf.bis.Kostenst)                          ,y , _LF_INT, 2.0);
    Write(7, 'Dicke'                                             ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(9, 'von: '                                             ,n , 0);
    Write(10, ZahlF(Sel.Auf.von.Dicke,2)                           ,n , _LF_NUM);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12,  ZahlF(Sel.Auf.bis.Dicke,2)                          ,y , _LF_NUM, 2.0);
    Write(13, 'Breite'                                           ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(15, ' von: '                                           ,n , 0);
    Write(16, ZahlF(Sel.Auf.von.Breite,2)                         ,n , _LF_NUM);
    Write(17, ' bis: '                                           ,n , 0);
    Write(18, ZahlF(Sel.Auf.bis.Breite,2)                         ,y , _LF_NUM, 2.0);
    EndLine();
    StartLine();
    Write( 1, 'Länge'                                       ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  ZahlF("Sel.Auf.von.Länge",2)                          ,n , _LF_NUM);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  ZahlF("Sel.Auf.bis.Länge",2)                          ,y , _LF_NUM, 2.0);
    Write(7, 'Güte'                                             ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(10, "Sel.Auf.Güte"                           ,n , 0);
    Write(13, 'ObfNr'                                           ,n , 0);
    Write(14, ': '                                               ,n , 0);
    Write(15, ' von: '                                           ,n , 0);
    Write(16, ZahlI(Sel.Auf.ObfNr)                         ,n , _LF_INT);
    Write(17, ' bis: '                                           ,n , 0);
    Write(18, ZahlI(Sel.Auf.ObfNr2)                        ,y , _LF_INT,2.0);
    EndLine();
    StartLine();
    Write( 1, 'ObfZusat'                                       ,n , 0);
    Write(2,  ': '                                               ,n , 0);
    Write(3,  ' von: '                                           ,n , 0);
    Write(4,  Sel.Auf.von.ObfZusat                          ,n , 0);
    Write(5,  ' bis: '                                           ,n , 0);
    Write(6,  Sel.Auf.bis.ObfZusat                          ,y , 0, 2.0);
    Write(7, 'Zusage Termin'                                             ,n , 0);
    Write(8, ': '                                                ,n , 0);
    Write(9, 'von: '                                             ,n , 0);
    Write(10, Cnvad(Sel.Auf.von.ZTermin)                           ,n , 0);
    Write(11, ' bis: '                                           ,n , 0);
    Write(12, cnvad(Sel.Auf.bis.ZTermin)                           ,y , 0, 2.0);
    EndLine();
    StartLine();
    EndLine();
    StartLine();
    EndLine();
  end;

  List_Spacing[50]  #  2.0;

  List_Spacing[ 1]  #   0.0; //
  List_Spacing[ 2]  #  List_Spacing[ 1] + 20.0; // 'Auftrgsnr.'
  List_Spacing[ 3]  #  List_Spacing[ 2] + 18.0; // 'Kunden- stichwort'
  List_Spacing[ 4]  #  List_Spacing[ 3] + 11.0; // 'Wgr.'
  List_Spacing[ 5]  #  List_Spacing[ 4] + 15.0; // 'Qualität'
  List_Spacing[ 6]  #  List_Spacing[ 5] + 14.0; // 'Dicke'
  List_Spacing[ 7]  #  List_Spacing[ 6] + 15.0; // 'Breite'
  List_Spacing[ 8]  #  List_Spacing[ 7] + 15.0; // 'Länge'
  List_Spacing[ 9]  #  List_Spacing[ 8] + 14.0; // 'Stück'
  List_Spacing[10]  #  List_Spacing[ 9] + 24.0; // 'Gewicht kg'
  List_Spacing[11]  #  List_Spacing[10] + 16.0; // 'E-Preis'
  List_Spacing[12]  #  List_Spacing[11] + 29.0; // 'Gesamt'
  List_Spacing[13]  #  List_Spacing[12] + 19.0; // 'Erfassdatum'
  List_Spacing[14]  #  List_Spacing[13] + 16.0; // 'Wunsch Temin'
  List_Spacing[15]  #  List_Spacing[14] + 16.0; // 'Zusage Termin'
  List_Spacing[16]  #  List_Spacing[15] + 16.0; // 'letzte Lief.'
  List_Spacing[17]  #  List_Spacing[16] + 20.0; // 'Projektnr'

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'Auftrgsnr.'                            ,n , 0);
  Write(2,  'Kunden- stichwort'                     ,n , 0);
  Write(3,  'Wgr.'                                  ,y , 0, 2.0);
  Write(4,  'Qualität'                              ,n , 0);
  Write(5,  'Dicke'                                 ,y , 0, 2.0);
  Write(6,  'Breite'                                ,y , 0, 2.0);
  Write(7,  'Länge'                                 ,y , 0, 2.0);
  Write(8,  'Stück'                                 ,y , 0, 2.0);
  Write(9,  'Gewicht kg'                            ,y , 0, 2.0);
  Write(10, 'E-Preis'                               ,y , 0, 2.0);
  Write(11, 'Gesamt'                                ,y , 0, 7.0);
  Write(12, 'Erfassdatum'                           ,y , 0, 2.0);
  Write(13, 'Wunsch Temin'                          ,y , 0, 2.0);
  Write(14, 'Zusage Termin'                         ,y , 0, 2.0);
  Write(15, 'letzte Lief.'                          ,y , 0, 2.0);
  Write(16, 'Projektnr.'                            ,y , 0, 2.0);
  EndLine();
//berech.Gew, letzt. Lieferung,.
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
Sub Print(aName : alpha);
local begin
  Erx   : int;
  vDat  : date;
end;
begin
   case aName of

    'Position' : begin
      Erx # RecLink(404,401,12,_recFirst);  // Aktionen loopen
      WHILE (Erx<=_rLocked) do begin
        if (Auf.A.Rechnungsnr<>0) or (Auf.A.Rechnungsmark='$') then begin
          if (Auf.A.TerminEnde>vDat) then vDat # Auf.A.TerminEnde;
        end;
        Erx # RecLink(404,401,12,_recNext);
      END;

      StartLine();
      Write(1, ZahlI(Auf.P.Nummer) +'/ '+ ZahlI(Auf.P.Position)                       ,n , 0);
      Write(2, Auf.P.KundenSW                           ,n , 0);
      Write(3, ZahlI(Auf.P.Warengruppe)                 ,y , _LF_INT, 2.0);
      Write(4, "Auf.P.Güte"                             ,n , 0);
      Write(5, ZahlF(Auf.P.Dicke,Set.Stellen.Dicke)     ,y , _LF_NUM, 2.0);
      Write(6, ZahlF(Auf.P.Breite, Set.Stellen.Breite)  ,y , _LF_NUM, 2.0);
      Write(7, ZahlF("Auf.P.Länge","Set.Stellen.Länge") ,y , _LF_NUM, 2.0);
      Write(8, ZahlI("Auf.P.Stückzahl")                 ,y , _LF_INT, 2.0);
      Write(9, ZahlF(Auf.P.Gewicht,Set.Stellen.Gewicht) ,y , _LF_NUM, 2.0);
/* mögliche:
Auf.P.Prd.Plan.Gew
Auf.P.Prd.VSB.Gew
Auf.P.Prd.VSAuf.Gew
Auf.P.Prd.LFS.Gew
Auf.P.Prd.Rech.Gew
Auf.P.Prd.Rest.Gew
*/
      Write(10, ZahlF(Auf.P.Einzelpreis,2)              ,y , _LF_WAE, 2.0);
      Write(11, ZahlF(Auf.P.Gesamtpreis,2)              ,y , _LF_WAE, 7.0);
      if(Auf.Anlage.Datum <> 0.0.0) then
        Write(12, DatS(Auf.Anlage.Datum)             ,y , 0, 2.0);
      if (Auf.P.Termin1Wunsch<>0.0.0) then
        Write(13, DatS(Auf.P.Termin1Wunsch)             ,y , 0, 2.0);
      if (Auf.P.TerminZusage<>0.0.0) then
        Write(14, DatS(Auf.P.TerminZusage)              ,y , 0, 2.0);
      if (vDat<>0.0.0) then
        Write(15, DatS(vDat)                            ,y , 0, 2.0);
      Write(16, ZahlI(Auf.P.Projektnummer)              ,y , _LF_INT, 2.0);
      EndLine();

      AddSum(1, Auf.P.Gewicht);
      AddSum(2, Auf.P.Gesamtpreis);
    end;

    'GesamtSumme' : begin
      StartLine(_lf_OverLine);
      Write(1, 'Gesamt:'  ,n ,0);
      Write(9, ZahlF(GetSum(1),Set.Stellen.Gewicht) ,y , _LF_NUM, 2.0);
      Write(11, ZahlF(GetSum(2),2) ,y , _LF_NUM, 7.0);
      EndLine();
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
  tErx        : int;
  vSelAufArt  : int;
  vQAufArt    : alpha(250);
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // BESTAND-Selektion öffnen
  // Selektionsquery für 401
  vQ # '';
  Lib_Sel:QInt( var vQ, 'Auf.P.Nummer', '<', 1000000000 );
  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Auf.P.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != 01.01.2010 ) then
    Lib_Sel:QVonBisD( var vQ, 'Auf.P.TerminZusage', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != 1.1.2010) then
    Lib_Sel:QVonBisD( var vQ, 'Auf.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQ, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr );
  if ( "Sel.Auf.Güte" != '' ) then
    Lib_Sel:QAlpha( var vQ, '"Auf.P.Güte"', '=*', "Sel.Auf.Güte" );
  if ( Sel.Auf.von.Dicke != 0.0 ) or ( Sel.Auf.bis.Dicke != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Auf.P.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke );
  if ( Sel.Auf.von.Breite != 0.0 ) or ( Sel.Auf.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Auf.P.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite );
  if ( "Sel.Auf.von.Länge" != 0.0 ) or ( "Sel.Auf.bis.Länge" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Auf.P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge" );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Auf.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Auf.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  if ( Sel.Auf.Artikelnr != '' ) then
    Lib_Sel:QAlpha( var vQ, 'Auf.P.Artikelnr', '=', Sel.Auf.Artikelnr );
  Lib_Sel:QInt( var vQ, 'Auf.P.Wgr.Dateinr', '>=', 200 );
  Lib_Sel:QInt( var vQ, 'Auf.P.Wgr.Dateinr', '<=', 209 );
  // Offene oder Erledigte Aufträge
  if ( Sel.Auf.OffeneYN ) and ( Sel.Auf.ErledigteYN = n ) then
    Lib_Sel:QAlpha( var vQ, '"Auf.P.Löschmarker"', '=', '' );
  if ( Sel.Auf.OffeneYN = n ) and ( Sel.Auf.ErledigteYN ) then
    Lib_Sel:QAlpha( var vQ, '"Auf.P.Löschmarker"', '=', '*' );

  if ( Sel.Auf.ObfNr != 0) or ( Sel.Auf.ObfNr2 != 999) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Ausf) > 0 ';
  end;
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 400
  vQ2 # '';
  vQ2 # '(Auf.Vorgangstyp=''' + c_AUF + ''')';
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ2, 'Auf.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );
  if ( Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt( var vQ2, 'Auf.Vertreter', '=', Sel.Auf.Vertreternr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vQ2, 'Auf.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  Lib_Sel:QAlpha(var vQ2, 'Auf.Vorgangstyp', '=', c_Auf);

  vSelAufArt # 0;
  vSelAufArt # cnvIL(Sel.Auf.RahmenYN) + cnvIL(Sel.Auf.AbrufYN) + cnvIL(Sel.Auf.NormalYN);
  vQAufArt   # '';
  if(vSelAufArt <> 0) and (vSelAufArt <> 3) then begin
    Lib_Strings:Append(var vQ2, '(', ' AND ');
    if(Sel.Auf.RahmenYN) then
      Lib_Strings:Append(var vQAufArt,'"Auf.LiefervertragYN" = true', '');
    if(Sel.Auf.AbrufYN) then
      Lib_Strings:Append(var vQAufArt,'"Auf.AbrufYN" = true', ' OR ');
    if(Sel.Auf.NormalYN) then
      Lib_Strings:Append(var vQAufArt,'("Auf.AbrufYN" = false AND "Auf.LiefervertragYN" = false)', ' OR ');
    Lib_Strings:Append(var vQ2, vQAufArt, '');
    Lib_Strings:Append(var vQ2, ')', '');
  end;

  // Selektionsquery für 402
  vQ3 # '';
  if ( Sel.Auf.ObfNr != 0 ) or ( Sel.Auf.ObfNr2 != 999 ) then
    Lib_Sel:QVonBisI( var vQ3, 'Auf.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2 );


  // Selektion starten...
  vSel # SelCreate( 401, 1 );
  vSel->SelAddLink('', 400, 401, 3, 'Kopf');
  vSel->SelAddLink('', 402, 401, 11, 'Ausf');
  Erx # vSel->SelDefQuery('', vQ );
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Kopf', vQ2 );
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Ausf', vQ3 );
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 401, cSel,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(401,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    if (aSort=1) then vSortKey # cnvAF(Auf.P.Dicke,_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF(Auf.P.Breite,_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Auf.P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
    if (aSort=2) then vSortKey # cnvAI(Auf.P.Nummer,_FmtNumLeadZero,0,9);
    if (aSort=3) then vSortKey # Auf.P.Best.Nummer;
    if (aSort=4) then vSortKey # cnvAI(cnvID(Auf.P.Anlage.Datum),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    if (aSort=5) then vSortKey # Auf.P.KundenSW;
    if (aSort=6) then vSortKey # "Auf.P.Güte" + cnvAF(Auf.P.Dicke,_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF(Auf.P.Breite,_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Auf.P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
    if (aSort=7) then vSortKey # cnvAI(cnvID(Auf.P.Termin1Wunsch),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    if (aSort=8) then vSortKey # cnvAI(cnvID(Auf.P.TerminZusage),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    Sort_ItemAdd(vTree,vSortKey,401,RecInfo(401,_RecId));
  END;
  SelClose(vSel);
  SelDelete(401, vSelName);
  vSel # 0;

  // ABLAGE-Selektion öffnen
  if ( Sel.Auf.ErledigteYN ) then begin

    // Selektionsquery für 411
    vQ # '';
    Lib_Sel:QInt( var vQ, '"Auf~P.Nummer"', '<', 1000000000 );
    if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
      Lib_Sel:QVonBisI( var vQ, '"Auf~P.Nummer"', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
    if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != 01.01.2010 ) then
      Lib_Sel:QVonBisD( var vQ, '"Auf~P.TerminZusage"', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
    if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != 1.1.2010) then
      Lib_Sel:QVonBisD( var vQ, '"Auf~P.Termin1Wunsch"', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
    if ( Sel.Auf.Kundennr != 0 ) then
      Lib_Sel:QInt( var vQ, '"Auf~P.Kundennr"', '=', Sel.Auf.Kundennr );
    if ( "Sel.Auf.Güte" != '' ) then
      Lib_Sel:QAlpha( var vQ, '"Auf~P.Güte"', '=*', "Sel.Auf.Güte" );
    if ( Sel.Auf.von.Dicke != 0.0 ) or ( Sel.Auf.bis.Dicke != 999999.00 ) then
      Lib_Sel:QVonBisF( var vQ, '"Auf~P.Dicke"', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke );
    if ( Sel.Auf.von.Breite != 0.0 ) or ( Sel.Auf.bis.Breite != 999999.00 ) then
      Lib_Sel:QVonBisF( var vQ, '"Auf~P.Breite"', Sel.Auf.von.Breite, Sel.Auf.bis.Breite );
    if ( "Sel.Auf.von.Länge" != 0.0 ) or ( "Sel.Auf.bis.Länge" != 999999.00 ) then
      Lib_Sel:QVonBisF( var vQ, '"Auf~P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge" );
    if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 999 ) then
      Lib_Sel:QVonBisI( var vQ, '"Auf~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
    if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
      Lib_Sel:QVonBisI( var vQ, '"Auf~P.Warengruppe"', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
    if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
      Lib_Sel:QVonBisI( var vQ, '"Auf~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
    if ( Sel.Auf.Artikelnr != '' ) then
      Lib_Sel:QAlpha( var vQ, '"Auf~P.Artikelnr"', '=', Sel.Auf.Artikelnr );
    Lib_Sel:QInt( var vQ, '"Auf~P.Wgr.Dateinr"', '>=', 200 );
    Lib_Sel:QInt( var vQ, '"Auf~P.Wgr.Dateinr"', '<=', 209 );
    if ( Sel.Auf.ObfNr != 0) or ( Sel.Auf.ObfNr2 != 999) then begin
      if (vQ != '') then vQ # vQ + ' AND ';
      vQ # vQ + ' LinkCount(Ausf) > 0 ';
    end;
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Kopf) > 0 ';

    // Selektionsquery für 410
    vQ2 # '';
    if ( Sel.Auf.Sachbearbeit != '') then
      Lib_Sel:QAlpha( var vQ2, '"Auf~Sachbearbeiter"', '=', Sel.Auf.Sachbearbeit );
    if ( Sel.Auf.Vertreternr != 0) then
      Lib_Sel:QInt( var vQ2, '"Auf~Vertreter"', '=', Sel.Auf.Vertreternr );
    if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today ) then
      Lib_Sel:QVonBisD( var vQ2, '"Auf~Anlage.Datum"', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
    Lib_Sel:QAlpha(var vQ2, '"Auf~Vorgangstyp"', '=', c_Auf);

    vSelAufArt # 0;
    vSelAufArt # cnvIL(Sel.Auf.RahmenYN) + cnvIL(Sel.Auf.AbrufYN) + cnvIL(Sel.Auf.NormalYN);
    vQAufArt   # '';
    if(vSelAufArt <> 0) and (vSelAufArt <> 3) then begin
      Lib_Strings:Append(var vQ2, '(', ' AND ');
      if(Sel.Auf.RahmenYN) then
        Lib_Strings:Append(var vQAufArt,'"Auf~LiefervertragYN" = true', '');
      if(Sel.Auf.AbrufYN) then
        Lib_Strings:Append(var vQAufArt,'"Auf~AbrufYN" = true', ' OR ');
      if(Sel.Auf.NormalYN) then
        Lib_Strings:Append(var vQAufArt,'("Auf~AbrufYN" = false AND "Auf~LiefervertragYN" = false)', ' OR ');
      Lib_Strings:Append(var vQ2, vQAufArt, '');
      Lib_Strings:Append(var vQ2, ')', '');
    end;

    // Selektionsquery für 402
    vQ3 # '';
    if ( Sel.Auf.ObfNr != 0 ) or ( Sel.Auf.ObfNr2 != 999 ) then
      Lib_Sel:QVonBisI( var vQ3, 'Auf.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2 );


    // Selektion starten...
    vSel # SelCreate( 411, 1 );
    vSel->SelAddLink('', 410, 411, 3, 'Kopf');
    vSel->SelAddLink('', 402, 411, 11, 'Ausf');
    Erx # vSel->SelDefQuery('', vQ );
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);
    Erx # vSel->SelDefQuery('Kopf', vQ2 );
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);
    Erx # vSel->SelDefQuery('Ausf', vQ3 );
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);
    vSelName # Lib_Sel:SaveRun( var vSel, 0);


    //vSelName # Sel_Build(vSel, 411, cSel,y,0);
    vFlag # _RecFirst;
    WHILE (RecRead(411,vSel,vFlag) <= _rLocked ) DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      if (aSort=1) then vSortKey # cnvAF("Auf~P.Dicke",_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF("Auf~P.Breite",_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Auf~P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
      if (aSort=2) then vSortKey # cnvAI("Auf~P.Nummer",_FmtNumLeadZero,0,9);
      if (aSort=3) then vSortKey # "Auf~P.Best.Nummer";
      if (aSort=4) then vSortKey # cnvAI(cnvID("Auf~P.Anlage.Datum"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);;
      if (aSort=5) then vSortKey # "Auf~P.KundenSW";
      if (aSort=6) then vSortKey # "Auf~P.Güte" + cnvAF("Auf~P.Dicke",_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF("Auf~P.Breite",_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Auf~P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
      if (aSort=7) then vSortKey # cnvAI(cnvID("Auf~P.Termin1Wunsch"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
      if (aSort=8) then vSortKey # cnvAI(cnvID("Auf~P.TerminZusage"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
      Sort_ItemAdd(vTree,vSortKey,411,RecInfo(411,_RecId));
    END;
    SelClose(vSel);
    SelDelete(411, vSelName);
    vSel # 0;
  end;


  // Ausgabe ----------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y);              // starte Landscape

//  List_FontSize # 7;  FONTGRÖSSE ÄNDERN!

  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    // Ablage?
    If (CnvIA(vItem->spCustom)=411) then RecBufCopy(411,401);

    Auf_Data:Read(Auf.P.Nummer, Auf.P.Position, true);

    Print('Position');
  END;

  Print('GesamtSumme');

  // Löschen der Liste
  Sort_KillList(vTree);

  ListTerm();
end;

//========================================================================