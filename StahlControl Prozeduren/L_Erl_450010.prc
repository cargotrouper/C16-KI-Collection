@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450010
//                    OHNE E_R_G
//  Info        Umsatzauswertung mit Einzelkosten pro Kostenstelle
//
//
//  13.03.2008  ST  Erstellung der Prozedur
//  28.07.2008  DS  QUERY
//  19.08.2013  ST  Auftragsart in XML Ausgabe hinzugefügt Knappstein 1304/202
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//    SUB StartList(aSort : int; aSortName : alpha);
//    SUB GetMatKosten(aMaterial : int; aGewicht : float; var aEK : float ; var aEKEff : float);
//
//========================================================================
@I:Def_Global
@I:Def_List

define begin
  cSumStk : 1
  cSumGew : 2
  cSumUms : 3
  cSumEK  : 4
  cSumEKF : 5
end;

declare StartList(aSort : int; aSortName : alpha);
declare GetMatKosten(aMaterial : int; aGewicht : float; var aEK : float ; var aEKEff : float);


global L450010 begin
  ga_KstType   : int[];
  ga_KstVal    : float[];
  ga_KstValSum : float[];
end;

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
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450010',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd('Rechnungsnummer');
  vHdl2->WinLstDatLineAdd('Auftragsnummer');
  vHdl2->WinLstDatLineAdd('Kunde');
  vHdl2->WinLstDatLineAdd('Warengruppe');

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
//  Print
//
//========================================================================
Sub Print(aName : alpha);
local begin
  vEK      : float;
  vEKEff   : float;
  vMarge   : float;
  i : int;
end;
begin

  case aName of

    'Auftrag' : begin
/*
      vEK      # 1343.57;
      vEKEff   # 1500.99;
*/

      vEK      # 0.0;
      vEKEff   # 0.0;

      if(Auf.A.MaterialNr <> 0) then
        GetMatKosten(Auf.A.MaterialNr,Auf.A.Gewicht,var vEK, var vEKEff);
//      vMarge # Auf.A.RechPreisW1 - vEKEff;    // Absolute Marge
      if (Auf.A.RechPreisW1 > 0.0) then
        vMarge # ((Auf.A.RechPreisW1 - vEKEff) / Auf.A.RechPreisW1) * 100.0;  // prozentuale Marge
      else
        vMarge # 0.0;

      StartLine();

      Write(1, ZahlI(Auf.A.Rechnungsnr)                           ,y ,_LF_Int);
      if (Auf.A.Rechnungsdatum<>0.0.0) then
        Write(2, DatS(Auf.A.Rechnungsdatum)                       ,y ,_LF_Date);
      Write( 3,ZahlI(Auf.A.Nummer)+'/'+ZahlI(Auf.A.Position)      ,y ,0);
      Write( 4,ZahlI(Auf.P.Warengruppe)                           ,y ,_LF_Int);
      Write( 5,Auf.P.KundenSW                                     ,n ,0,2.0);
      Write( 6,"Auf.P.Güte"                                       ,n ,0);
      Write( 7,ZahlF(Auf.P.Dicke,Set.Stellen.Dicke)               ,y ,_LF_Num);
      Write( 8,ZahlF(Auf.P.Breite,Set.Stellen.Breite)             ,y ,_LF_Num);
      Write( 9,ZahlF("Auf.P.Länge","Set.Stellen.Länge")           ,y ,_LF_Num);
      Write(10,ZahlI("Auf.A.Stückzahl")                           ,y ,_LF_Int);
      Write(11,ZahlF(Auf.A.Gewicht,Set.Stellen.Gewicht)           ,y ,_LF_Num);
      Write(12,ZahlF(Auf.A.RechPreisW1,2)                         ,y ,_LF_Wae, 3.0);
      Write(13,ZahlF(vEK,2)                                       ,y ,_LF_Wae, 3.0);
      Write(14,ZahlF(vEKEff,2)                                    ,y ,_LF_Wae, 3.0);
      Write(15,ZahlF(vMarge,2)                                    ,y ,_LF_Wae, 3.0);
      // ggf. mehr Daten bei XML-Ausgabe
      if (List_XML) then begin
        Write(16, Adr.LKZ                      ,n ,0);
        Write(17, Aint(Auf.P.Auftragsart)   ,y,0);

        // Kostenstellenverteilung nur bei XML Ausgabe
        FOR i # 1
        LOOP inc(i)
        WHILE (i <= VarInfo(ga_KstType))
        DO BEGIN
          List_Spacing[i+18]  # List_Spacing[i+17] + 20.0;
          Write(i+17, ZahlF(ga_KstVal[i],2)        ,y , _LF_Wae, 3.0);
          ga_KstValSum[i] # ga_KstValSum[i] + ga_KstVal[i];   // Summierung
          ga_KstVal[i]    # 0.0;                              // RESET
        END;
      end;  // XML-Ausgabe

      EndLine();



      // AddSum

      AddSum(cSumStk, CnvFi("Auf.A.Stückzahl"));
      AddSum(cSumGew, "Auf.A.Gewicht");
      AddSum(cSumUms, "Auf.A.RechPreisW1");
      AddSum(cSumEK,  vEK);
      AddSum(cSumEKF, vEKEff)


    end;

    'Summe' : begin

      StartLine(_LF_Overline);
      Write(10, ZahlF(GetSum(cSumStk), 0) ,y, _LF_Num);
      if(List_XML) then
        Write(11, ZahlF(GetSum(cSumGew), 0) ,y, _LF_Num);
      Write(12, ZahlF(GetSum(cSumUms), 2) ,y, _LF_Wae, 3.0);
      if(List_XML) then
        Write(13, ZahlF(GetSum(cSumEK) , 2) ,y, _LF_Wae, 3.0);
      Write(14, ZahlF(GetSum(cSumEKF), 2) ,y, _LF_Wae, 3.0);



      // ggf. mehr Daten bei XML-Ausgabe
      if (List_XML) then begin
        // Kostenstellenverteilung nur bei XML Ausgabe
        FOR i # 1
        LOOP inc(i)
        WHILE (i <= VarInfo(ga_KstType))
        DO BEGIN
          List_Spacing[i+18]  # List_Spacing[i+17] + 20.0;
          Write(i+17, ZahlF(ga_KstValSum[i],2)        ,y , _LF_Wae, 3.0);
        END;
      end;  // XML-Ausgabe

      EndLine();

      if(List_XML = false) then begin
        StartLine();
        Write(11, ZahlF(GetSum(cSumGew), 0) ,y, _LF_Num);
        Write(13, ZahlF(GetSum(cSumEK) , 2) ,y, _LF_Wae, 3.0);
        EndLine();
      end;

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
      Write(13, 'ArtikelNr.'                                         ,n , 0);
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
local begin
  i : int;

end;

begin
  WriteTitel();
  StartLine();
  EndLine();
  if (aSeite=1) then begin

    Print('Selektierung');

    StartLine();
    EndLine();

    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 12.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 17.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 17.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 11.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 37.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 15.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 17.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 17.0;
  List_Spacing[10]  # List_Spacing[ 9] + 17.0;
  List_Spacing[11]  # List_Spacing[10] + 10.0;
  List_Spacing[12]  # List_Spacing[11] + 17.0;
  List_Spacing[13]  # List_Spacing[12] + 27.0;
  List_Spacing[14]  # List_Spacing[13] + 24.0;
  List_Spacing[15]  # List_Spacing[14] + 24.0;
  List_Spacing[16]  # List_Spacing[15] + 20.0;
  List_Spacing[17]  # List_Spacing[16] + 20.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Re.Nr.'                          ,y , 0);
  Write(2, 'Re.Dat.'                         ,y , 0);
  Write(3, 'Auf.Nr.'                         ,y , 0);
  Write(4, 'Wgr.'                            ,y , 0);
  Write(5, 'Kunde'                           ,n , 0, 2.0);
  Write(6, 'Güte'                            ,n , 0);
  Write(7, 'Dicke'                           ,y , 0);
  Write(8, 'Breite'                          ,y , 0);
  Write(9, 'Länge'                           ,y , 0);
  Write(10, 'Stk'                            ,y , 0);
  Write(11, 'Gewicht'                        ,y , 0);
  Write(12, 'Umsatz '+"Set.Hauswährung.Kurz" ,y , 0, 3.0);
  Write(13, 'EK'                             ,y , 0, 3.0);
  Write(14, 'EK-Eff'                         ,y , 0, 3.0);
  Write(15, 'Marge %'                          ,y , 0, 3.0);
  // mehr Daten bei XML-Ausgabe
  if (List_XML) then begin
    Write(16, 'LKZ-Kunde'                    ,n ,0);
    Write(17, 'Auf.Art'                      ,n ,0);

    FOR i # 1
    LOOP inc(i)
    WHILE (i <= VarInfo(ga_KstType))
    DO BEGIN
      List_Spacing[i+18]  # List_Spacing[i+17] + 20.0;

      Kst.Nummer # ga_KstType[i];
      if (RecRead(846,1,0) <= _rLocked) then
        Write(i+17, Kst.Bezeichnung ,y , 0, 3.0);
    END;
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
  vItem,i     : int;
  vKey        : int;
  vMFile,vMID : int;
  vTree       : int;
  vOK         : logic;
  vSortKey    : alpha;
  vPL         : int;
  vSize       : int;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  vQ4         : alpha(4000);
  vQ5         : alpha(4000);
  tErx        : int;
  tErx2       : int;
  tErx3       : int;
  tErx4       : int;
  tErx5       : int;
end;
begin

  // Kostenstellen in Array Übernehmen
  vSize # RecInfo(846,_RecCount);
  VarAllocate(L450010);
  VarAllocate(ga_KstType,vSize);
  VarAllocate(ga_KstVal,vSize);
  VarAllocate(ga_KstValSum,vSize);
  vFlag # _RecFirst;
  WHILE (RecRead(846,1,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    i # i + 1;
    ga_KstType[i] # Kst.Nummer;
  END;


  // Liste starten
  ListInit(y); // mit Landscape


  // SELEKTION -------------------------------------------------------------

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery für 404
  vQ # '';
  if ( Sel.Fin.von.Rechnung != 0 ) or ( Sel.Fin.bis.Rechnung != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Auf.A.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'Auf.A.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  Lib_Sel:QInt( var vQ, 'Auf.A.Rechnungsnr', '>', 0 );
  //Lib_Sel:QInt( var vQ, 'Auf.A.Materialnr', '>', 0 );
  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Auf.A.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( Sel.Auf.von.LiefDat != 0.0.0) or ( Sel.Auf.bis.LiefDat != today) then
    Lib_Sel:QVonBisD( var vQ, 'Auf.A.TerminEnde', Sel.Auf.von.LiefDat, Sel.Auf.bis.LiefDat );
  if ( Sel.Art.von.ArtNr != '' ) or ( Sel.Art.bis.ArtNr != '' ) then
    Lib_Sel:QVonBisA( var vQ, 'Auf.A.ArtikelNr', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr );
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( LinkCount(AufPos) > 0 OR LinkCount(AufPosA) > 0 ) ';

  // Selektionsquery für 401
  vQ2 # '';
  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQ2, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ2, 'Auf.P.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Auf.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Auf.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if (vQ2 != '') then vQ2 # vQ2 + ' AND ';
  vQ2 # vQ2 + ' LinkCount(AufKopf) > 0 ';

  // Selektionsquery für 411
  vQ3 # '';
  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQ3, '"Auf~P.Kundennr"', '=', Sel.Auf.Kundennr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ3, '"Auf~P.Anlage.Datum"', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ3, '"Auf~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQ3, '"Auf~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ3, '"Auf~P.Warengruppe"', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if (vQ3 != '') then vQ3 # vQ3 + ' AND ';
  vQ3 # vQ3 + ' LinkCount(AufKopfA) > 0 ';

  // Selektionsquery für 400
  vQ4 # '';
  if ( Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt( var vQ4, 'Auf.Vertreter', '=', Sel.Auf.Vertreternr );
  if ( Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt( var vQ4, 'Auf.Vertreter2', '=', Sel.Adr.von.Verband );
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ4, 'Auf.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );
  // Selektionsquery für 410
  vQ5 # '';
  if ( Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt( var vQ5, '"Auf~Vertreter"', '=', Sel.Auf.Vertreternr );
  if ( Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt( var vQ5, '"Auf~Vertreter2"', '=', Sel.Adr.von.Verband );
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ5, '"Auf~Sachbearbeiter"', '=', Sel.Auf.Sachbearbeit );

  // Selektion starten...
  vSel # SelCreate( 404, 1 );
  vSel->SelAddLink('', 401, 404, 1, 'AufPos');
  vSel->SelAddLink('', 411, 404, 7, 'AufPosA');
  vSel->SelAddLink('AufPos', 400, 401, 3, 'AufKopf');
  vSel->SelAddLink('AufPosA', 410, 411, 3, 'AufKopfA');
  tErx # vSel->SelDefQuery('', vQ );
  tErx2 # vSel->SelDefQuery('AufPos',   vQ2 );
  tErx3 # vSel->SelDefQuery('AufPosA',  vQ3 );
  tErx4 # vSel->SelDefQuery('AufKopf',  vQ4 );
  tErx5 # vSel->SelDefQuery('AufKopfA', vQ5 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  // Selektion öffnen
  //vSelName # Sel_Build(vSel, 404, 'LST.450010',y,0);

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vFlag # _RecFirst;
  WHILE (RecRead(404,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Erx # RecLink(401,404,1,_recFirst);     // Position holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(411,404,7,_recFirst);   // ~Position holen
      if (Erx>_rLocked) then RecBufClear(411);
      RecBufCopy(411,401);
    end;

    Mat_Data:Read(Auf.A.Materialnr);

    if (aSort=1) then
      vSortKey # "Mat.Güte"+cnvaf(Mat.Dicke,_FmtNumNoGroup|_FmtNumLeadZero,0,3,12)+cnvaf(Mat.Breite,_FmtNumLeadZero,0,3,12)+cnvaf("Mat.Länge",_FmtNumLeadZero,0,3,12);
    if (aSort=2) then
      vSortkey # DatS(Auf.A.TerminEnde);
    if (aSort=3) then
      vSortKey # DatS(Auf.A.Rechnungsdatum);
    if (aSort=4) then
      vSortKey # CnvAi(Auf.A.Rechnungsnr,_FmtNumNoGroup|_FmtNumLeadZero,0,8);
    if (aSort=5) then
      vSortKey # CnvAi(Auf.A.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8) +
                 CnvAi(Auf.A.Position,_FmtNumNoGroup|_FmtNumLeadZero,0,8);
    if (aSort=6) then
      vSortKey # Auf.P.KundenSW;
    if (aSort=7) then
      vSortKey # CnvAi(Auf.P.Warengruppe,_FmtNumNoGroup|_FmtNumLeadZero,0,8);

    Sort_ItemAdd(vTree,vSortKey,404,RecInfo(404,_RecId));

  END;

  // Selektion löschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(404,vSelName);


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // AUSGABE ---------------------------------------------------------------

  // Durchlaufen und löschen
  vItem # Sort_ItemFirst(vTree);
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


    Erx # RecLink(100, 401, 4, _recFirst) // Kunde holen
    if(Erx > _rLocked) then
      RecBufClear(100);

    RecBufClear(200); // Materialbuffer leeren

    Print('Auftrag');

    vTree->Ctedelete(vItem);
    vItem # Sort_ItemFirst(vTree);
  END;  // loop

  Print('Summe');

  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

  VarFree(L450010);


end;


//========================================================================
//  GetMatKosten
//    Errechnet die absoluten Materialkosten zu einem Bezugsgewicht und
//    summiert die globalen Kostenstellen
//========================================================================
Sub GetMatKosten(aMaterial : int; aGewicht : float; var aEK : float ; var aEKEff : float);
local begin
  vBezugsgewicht : float;
  i,
  vFlag : int;
  vFileSrc  : int;
end;
begin

  // Übergebenes Material lesen, ggf. aus Ablage
  /*
  vFileSrc  # 200;
  Mat.Nummer # aMaterial;
  erx # RecRead(200,1,0);
  if (Erx >_rLocked) then begin
    Erx # RecLink(210,404,8,_recFirst);   // ~Material holen
    if (Erx>_rLocked) then RecBufClear(210);
    RecBufCopy(210,200);
    vFileSrc  # 210;
  end;
  */
  vFileSrc # Mat_Data:Read(Auf.A.Materialnr);

  // Bezugsgewicht setzen
  if (aGewicht = 0.0) then
    vBezugsgewicht # Mat.Gewicht.Brutto
  else
    vBezugsgewicht # aGewicht;

  // Einkaufswerte errechnen
  aEK     # vBezugsgewicht / 1000.0 * Mat.EK.Preis;
  aEKEff  # vBezugsgewicht / 1000.0 * Mat.EK.Effektiv;

  // Kosten der Aktionen in KsT Array summieren
  vFlag # _RecFirst;
  WHILE (RecLink(204,vFileSrc,14,vFlag) <= _rLocked) DO BEGIN
    vFlag # _RecNext;

    if (Mat.A.Kostenstelle = 0) then
      CYCLE;

    // Kostenstellen Summierung
    FOR i # 1
    LOOP inc(i)
    WHILE (i <= VarInfo(ga_KstType))
    DO BEGIN

      if (ga_KstType[i] = Mat.A.Kostenstelle) then begin
        // Entsprechende Kostenstelle gefunden, Wert Summieren
        ga_KstVal[i] # ga_KstVal[i] + (Mat.A.KostenW1 * vBezugsgewicht / 1000.0);
        BREAK;
      end;

    END;  // EO Materialaktionen

  END;

end;

//========================================================================