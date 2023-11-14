@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450008
//                    OHNE E_R_G
//  Info        Artikelabsatz
//
//
//  31.01.2007  NH  Erstellung der Prozedur
//  04.08.2008  DS  keine dyn. QUERY eingebaut, da diese Liste Blödsinnig
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

define begin
  cGesUmsatz  : 1
  cGesGewicht : 2
end;

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.bis.Datum           # today;
  Sel.Fin.bis.Rechnung    # 99999999;

  Sel.Auf.bis.Nummer      # 99999999;
  Sel.Auf.bis.Datum       # today;
  Sel.Auf.bis.Projekt     # 99999999;
  Sel.Auf.bis.AufArt      # 9999;
  Sel.Auf.bis.WGr         # 9999;

  Sel.Auf.bis.Nummer      # 99999999;
  Sel.Auf.bis.Datum       # today;
  Sel.Auf.bis.AufArt      # 9999;
  Sel.Auf.bis.WGr         # 9999;

  Sel.Auf.bis.LiefDat     # today;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450008',here+':AusSel');
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
/*
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd('Güte * Abmessung');
  vHdl2->WinLstDatLineAdd('Lieferdatum');
  vHdl2->WinLstDatLineAdd('Rechnungsdatum');
  vHdl2->wpcurrentint # 1;
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
local begin
  Erx   : int;
  vSum  : float;
end;
begin

  case aName of

    'Aktion' : begin
      StartLine();
      Write(1, ZahlI(Auf.A.Rechnungsnr)                           ,y ,0);
      if (Auf.A.Rechnungsdatum<>0.0.0) then
        Write(2, DatS(Auf.A.Rechnungsdatum)                       ,y ,0);
      Write(3, ZahlI(Auf.A.Nummer)+'/'+ZahlI(Auf.A.Position)      ,y ,0);
      Write(4, ZahlI(Auf.P.Warengruppe)                           ,y ,0);
      //Write(5, Art.Nummer                                         ,y ,0, 3.0);
      Write(5, Auf.A.ArtikelNr                                    ,y ,0, 3.0);
      Write(6,ZahlF(Auf.A.Gewicht,Set.Stellen.Gewicht)            ,y ,0);
      Write(7,ZahlF(Auf.A.RechPreisW1,2)                          ,y ,_LF_Wae, 3.0);
      Write(8,Auf.P.KundenSW                                      ,n ,0);
      Write(9,ZahlI(Auf.P.Projektnummer)                          ,y ,0);
      if (Auf.A.TerminEnde<>0.0.0) then
        Write(10, DatS(Auf.A.TerminEnde)                          ,y ,0);

      // ggf. mehr Daten bei XML-Ausgabe
      if (List_XML) then begin
        Write(11, ZahlI("Auf.A.Stückzahl")                        ,y ,0);
        if (Auf.P.Termin1Wunsch<>0.0.0) then
          Write(12,DatS(Auf.P.Termin1Wunsch)                      ,y ,0);
        if (Auf.P.Anlage.Datum<>0.0.0) then
          Write(13,DatS(Auf.P.Anlage.Datum)                       ,y ,0);
        Erx # RecLink(110,400,20,_recfirst);      // Vetreter holen
        if (Erx>_rLocked) then RecBufClear(110);
        Write(14, Ver.Stichwort                                   ,n ,0);
        Erx # RecLink(110,400,21,_recfirst);      // Verband holen
        if (Erx>_rLocked) then RecBufClear(110);
        Write(15, Ver.Stichwort                                   ,n ,0);
        Write(16, Auf.Sachbearbeiter                              ,n ,0);
        Write(17, ZahlI(Auf.P.Auftragsart)                        ,y ,0);
      end;  // XML-Ausgabe

      EndLine();
    end;


    'Summe' : begin
      vSum # getSum(1);
      StartLine(_LF_Overline);
      Write(6, ZahlF(GetSum(cGesUmsatz), 2) ,y, _LF_Wae, 3.0);
      Write(7, ZahlF(GetSum(cGesGewicht), 2) ,y, _LF_Wae, 3.0);
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
      if (Sel.von.Datum<>0.0.0) then
      Write(6, DatS(Sel.bis.Datum)                                   ,y , 0);
      Write(7, 'ReNr.'                                               ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(9, ' von: '                                              ,n , 0);
      Write(10, ZahlI(Sel.Fin.von.Rechnung)                          ,n , _LF_INT);
      Write(11, ' bis: '                                             ,n , 0);
      Write(12, ZahlI(Sel.Fin.bis.Rechnung)                          ,y , _LF_INT, 3.0);
      Write(13, 'AufNr.'                                             ,n , 0);
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
      Write(7, 'LiefDat.'                                            ,n , 0);
      Write(8, ': '                                                  ,n , 0);
      Write(9, ' von: '                                              ,n , 0);
      if (Sel.Auf.von.Liefdat<>0.0.0) then
      Write(10, DatS(Sel.Auf.bis.Liefdat)                            ,n , 0);
      Write(11, ' bis: '                                             ,n , 0);
      if (Sel.Auf.bis.Liefdat<>0.0.0) then
      Write(12, DatS(Sel.Auf.bis.Liefdat)                            ,y , 0, 3.0);
      Write(13, 'ArtieklNr.'                                         ,n , 0);
      Write(14, ': '                                                 ,n , 0);
      Write(15, ' von: '                                             ,n , 0);
      Write(16, Sel.Art.von.ArtNr                                    ,n , 0);
      Write(17, ' bis: '                                             ,n , 0);
      Write(18, Sel.Art.bis.ArtNr                                    ,y , 0);
      Endline();

      StartLine();
      Write(1, 'Verband'                                             ,n , 0);
      Write(2, ': '                                                  ,n , 0);

      Write(4, ZahlI(Sel.Adr.von.Verband)                            ,n , _LF_INT);

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

   /* if (Sel.Fin.von.Rechnung<>0) then begin
    Write (1, ZahlI(Sel.Fin.von.Rechnung) + ' bis ' + ZahlI(Sel.Fin.bis.Rechnung) ,n , 0);
      Endline();
      else begin
      Write(1, 'Selektions bla bla bla' ,n , 0);
    EndLine();
     end;
    end;
    */
    StartLine();
    EndLine();

    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 22.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 19.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 22.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 12.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 21.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 22.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 25.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 20.0;
  List_Spacing[10]  # List_Spacing[ 9] + 27.0;
  List_Spacing[11]  # List_Spacing[10] + 27.0;
  List_Spacing[12]  # List_Spacing[11] + 22.0;
  List_Spacing[13]  # List_Spacing[12] + 27.0;
  List_Spacing[14]  # List_Spacing[13] + 20.0;
  List_Spacing[15]  # List_Spacing[14] + 27.0;

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
  Write(5, 'Art.Nr.'                        ,y , 0, 3.0);
  Write(6,'Gewicht'                  ,y , 0);
  Write(7,'Umsatz '+"Set.Hauswährung.Kurz" ,y , 0, 3.0);
  Write(8,'Kunde'                          ,n , 0);
  Write(9,'Projekt'                        ,y , 0);
  Write(10,'Lieferdat.'                     ,y , 0);

  // mehr Daten bei XML-Ausgabe
  if (List_XML) then begin
    Write(11,'Stück'                          ,y , 0);
    Write(12,'Wunschterm.'                    ,y , 0);
    Write(13,'Anlagedat.'                     ,y , 0);
    Write(14,'Vertreter'                      ,n , 0);
    Write(15,'Verband'                        ,n , 0);
    Write(16,'Sachbear.'                      ,n , 0);
    Write(17,'Vorgangstyp'                    ,n , 0);
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
  vQ404       : alpha(4000);
  vQ401       : alpha(4000);
  vQ411       : alpha(4000);
  vQ400       : alpha(4000);
  vQ410       : alpha(4000);
  tErx        : int;
  tErx2       : int;
  tErx3       : int;
  tErx4       : int;
  tErx5       : int;
end;
begin

  // Liste starten
  if (gUsername='MS') or (gUsername='AH') then begin
    if (Msg(99,'über ReportGenerator?',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then
      gSQLBuffer # 1
  end

  if (gSQLBuffer=0) then
    ListInit(y); // mit Landscape

  // SELEKTION -------------------------------------------------------------
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektion öffnen
  //vSelName # Sel_Build(vSel, 404, 'LST.450003',y,0);
  // Selektionsquery für 404
  vQ404 # '';
  if ( Sel.Fin.von.Rechnung != 0 ) or ( Sel.Fin.bis.Rechnung != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ404, 'Auf.A.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ404, 'Auf.A.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  Lib_Sel:QInt( var vQ404, 'Auf.A.Rechnungsnr', '>', 0 );
  Lib_Sel:QInt( var vQ404, 'Auf.A.Materialnr', '=', 0 );
  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ404, 'Auf.A.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( Sel.Auf.von.LiefDat != 0.0.0) or ( Sel.Auf.bis.LiefDat != today) then
    Lib_Sel:QVonBisD( var vQ404, 'Auf.A.TerminEnde', Sel.Auf.von.LiefDat, Sel.Auf.bis.LiefDat );
  if ( Sel.Art.von.ArtNr != '' ) or ( Sel.Art.bis.ArtNr != '' ) then
    Lib_Sel:QVonBisA( var vQ404, 'Auf.A.ArtikelNr', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr );
  if (gSQLBuffer = 0) then begin
    if (vQ404 != '') then vQ404 # vQ404 + ' AND ';
    vQ404 # vQ404 + ' ( LinkCount(AufPos) > 0 OR LinkCount(AufPosA) > 0 ) ';
  end;
  // Selektionsquery für 401
  vQ401 # '';
  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQ401, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ401, 'Auf.P.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ401, 'Auf.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQ401, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ401, 'Auf.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if (gSQLBuffer=0) then begin
    if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
    vQ401 # vQ401 + ' LinkCount(AufKopf) > 0 ';
  end;

  // Selektionsquery für 411
  vQ411 # '';
  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQ411, '"Auf~P.Kundennr"', '=', Sel.Auf.Kundennr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ411, '"Auf~P.Anlage.Datum"', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ411, '"Auf~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQ411, '"Auf~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ411, '"Auf~P.Warengruppe"', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if (gSQLBuffer=0) then begin
    if (vQ411 != '') then vQ411 # vQ411 + ' AND ';
    vQ411 # vQ411 + ' LinkCount(AufKopfA) > 0 ';
  end;

  // Selektionsquery für 400
  vQ400 # '';
  if ( Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt( var vQ400, 'Auf.Vertreter', '=', Sel.Auf.Vertreternr );
  if ( Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt( var vQ400, 'Auf.Vertreter2', '=', Sel.Adr.von.Verband );
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ400, 'Auf.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );
  // Selektionsquery für 410
  vQ410 # '';
  if ( Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt( var vQ410, '"Auf~Vertreter"', '=', Sel.Auf.Vertreternr );
  if ( Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt( var vQ410, '"Auf~Vertreter2"', '=', Sel.Adr.von.Verband );
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ410, '"Auf~Sachbearbeiter"', '=', Sel.Auf.Sachbearbeit );

  if (gSQLBuffer<>0) then begin
    gSQLBuffer # 0;
    Lib_SQL:SetPara('horst', 'genau Einer');
    Lib_SQL:SetPara('ding', 'von','bis');
    Lib_SQL:SetPara('Stichtag', '31.12.2012');
    Lib_SQL:SetPara('Bereich', '','999');
    //Lib_SQL:SetSort('lalala nach ARtikel');
    Lib_SQL:SetSort('=Fields.PositionObj.Warengruppe', 'Asc');
    Lib_SQL:SetSort('=Fields.Rechnungsnr', 'Desc');
    Lib_SQL:SetSubSQL('Q404', vQ404);
    Lib_SQL:SetSubSQL('Q401', vQ401, 404, 1);
    Lib_SQL:SetSubSQL('Q400', vQ400, 401, 3);
    Lib_SQL:SetSubSQL('Q411', vQ411, 404, 7);
    Lib_SQL:SetSubSQL('Q410', vQ410, 411, 3);

    Lib_SQL:ParseSQL('Q404 AND ((Q401 AND Q400) OR (Q411 AND Q410))');

    Lib_SQL:SaveSQL(Lfm.Name, 'Form' + AInt(Lfm.Nummer));

    //Lib_SQL:RunList('Form' +AInt(Lfm.Nummer) + '.xml');
    //Lib_SQL:RunList('C:\Repository\FormTest\FormTestViewer\bin\Debug\FormTestViewer.exe', 'C:\Form' + AInt(Lfm.Nummer) + '.xml');
    //Lib_SQL:RunList('C:\Repository\FormTest\FormTestViewer\bin\Debug\FormTestViewer.exe', '');
    //Lib_SQL:RunList('C:\test.bat', '');
    RETURN;
  end;


  // Selektion starten...
  vSel # SelCreate( 404, 1 );
  vSel->SelAddLink('', 401, 404, 1, 'AufPos');
  vSel->SelAddLink('', 411, 404, 7, 'AufPosA');
  vSel->SelAddLink('AufPos', 400, 401, 3, 'AufKopf');
  vSel->SelAddLink('AufPosA', 410, 411, 3, 'AufKopfA');
  tErx # vSel->SelDefQuery('', vQ404 );
  tErx2 # vSel->SelDefQuery('AufPos',   vQ401 );
  tErx3 # vSel->SelDefQuery('AufPosA',  vQ411 );
  tErx4 # vSel->SelDefQuery('AufKopf',  vQ400 );
  tErx5 # vSel->SelDefQuery('AufKopfA', vQ410 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  // Selektion öffnen
  //vSelName # Sel_Build(vSel, 404, 'LST.450010',y,0);



  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  Erx # RecRead(404, vSel, _recFirst);
  WHILE (Erx <= _rLocked ) DO BEGIN

/*
    Erx # RecLink(401,404,1,_recFirst);     // Position holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(411,404,7,_recFirst);   // ~Position holen
      if (Erx>_rLocked) then RecBufClear(411);
      RecBufCopy(411,401);
    end;
*/
/*
    Erx # RecLink(200,404,6,_recFirst);     // Material holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(210,404,8,_recFirst);   // ~Material holen
      if (Erx>_rLocked) then RecBufClear(210);
      RecBufCopy(210,200);
    end;

    if (aSort=1) then
      vSortKey # "Mat.Güte"+cnvaf(Mat.Dicke,_FmtNumNoGroup|_FmtNumLeadZero,0,3,12)+cnvaf(Mat.Breite,_FmtNumLeadZero,0,3,12)+cnvaf("Mat.Länge",_FmtNumLeadZero,0,3,12);
    if (aSort=2) then
      vSortkey # DatS(Auf.A.TerminEnde);
    if (aSort=3) then
      vSortKey # DatS(Auf.A.Rechnungsdatum);
    Sort_ItemAdd(vTree,vSortKey,404,RecInfo(404,_RecId));
*/
    vSortKey # cnvAI((cnvID(Auf.A.Rechnungsdatum)),_FmtNumLeadZero,0,0);
    //DatS(Auf.A.Rechnungsdatum);
    Sort_ItemAdd(vTree,vSortKey,404,RecInfo(404,_RecId));
//    Erx # RecRead(404, 1, _recNext);
    Erx # RecRead(404,vSel,_recNext);
  END;

  // Selektion löschen
  SelClose(vSel);
  SelDelete(404,vSelName);
  vSel # 0;

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // AUSGABE ---------------------------------------------------------------

  // Durchlaufen und löschen
  FOR vItem # vTree->CteRead(_CteFirst);
  LOOP vItem # vTree->CteRead(_CteNext, vItem);
  WHILE (vItem <> 0) do begin
    // Datensatz holen
    RecRead(404,0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, true);

    AddSum(cGesUmsatz , Auf.A.Gewicht);
    AddSum(cGesGewicht, Auf.A.RechPreisW1);
/*
    Erx # RecLink(200,404,6,_recFirst);     // Material holen
    if (Erx > _rLocked) then begin
      Erx # RecLink(210,404,8,_recFirst);   // ~Material holen
      if (Erx > _rLocked) then
        RecBufClear(210);
      RecBufCopy(210,200);
    end;
*/
    Print('Aktion');
  END;  // loop

  Print('Summe');

  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================