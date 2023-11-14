@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450016
//                    OHNE E_R_G
//  Info        Kunden Hitliste pro Jahr
//              OHNE Lieferanten Gutschriften+Belastugen
//
//              MUSTER für Structures in Listen
//
//
//  14.05.2009  AI  Erstellung der Prozedur
//  29.06.2011  MS  Anpassung an eine NEUE ALLGEMEINE ARTIKEL Liste
//  20.01.2014  ST  Sortierung nach Tonnage entfernt, da
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    MAIN
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List
@I:Def_aktionen

define begin
  cS1   : 23.0;
  cS2   : 23.0;
  cS3   : 25.0;
  cS4   : 12.0;
  Proz(a,b) : Lib_Berechnungen:Prozent(a,b)
  cMax  : GV.Int.03
end

global Struct_Werte begin
  s_KuNr  : int;
  s_GewLJ : float;
  s_UmsLJ : float;
  s_EKLJ  : float;
  s_DBLJ  : float;
  s_GewVJ : float;
  s_UmsVJ : float;
  s_EKVJ  : float;
  s_DBVJ  : float;
end;

local begin
  gGewLJ  : float;
  gUmsLJ  : float;
  gEKLJ   : float;
  gDBLJ   : float;
  gGewVJ  : float;
  gUmsVJ  : float;
  gEKVJ   : float;
  gDBVJ   : float;

  gAnz    : int;

  gRGewLJ : float;
  gRUmsLJ : float;
  gREKLJ  : float;
  gRDBLJ  : float;
  gRGewVJ : float;
  gRUmsVJ : float;
  gREKVJ  : float;
  gRDBVJ  : float;

  gZSGewLJ    : float;
  gZSUmsLJ    : float;
  gZSProzLJ   : float;
  gZSDurchLJ  : float;
  gZSDBLJ     : float;
  gZSSpanLJ   : float;

  gZSGewVJ    : float;
  gZSUmsVJ    : float;
  gZSProzVJ   : float;
  gZSDurchVJ  : float;
  gZSDBVJ     : float;
  gZSSpanVJ   : float;

  gZSGew      : float;
  gZSUms      : float;
  gZSProz     : float;
  gZSDurc     : float;
  gZSDB       : float;
  gZSSpan     : float;
end;




declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vSort       : int;
  vSortName   : alpha;
  vHdl,vHdl2  : int;
end;
begin

  RecBufClear(998);
  RecBufClear(999);

  // OHNE Lieferanten Gutschriften+Belastugen
  Sel.Fin.LiefGutBelYN # false;

  // Zeitraum Abfragen...
  Gv.Int.01 # dateyear(today) + 1900;
  Sel.Von.Datum # DateMake(1, 1, GV.Int.01 - 1900);
  Sel.Bis.Datum # DateMake(31, 12, GV.Int.01 - 1900);
  GV.Int.02 # GV.Int.01 - 1;
  Sel.Von.Datum2 # DateMake(1, 1, GV.Int.02 - 1900);
  Sel.Bis.Datum2 # DateMake(31, 12, GV.Int.02 - 1900);
  cMax # 30;

  //if (Dlg_Standard:DatumVonBis(Translate('Zeitraum'), var Sel.Von.Datum, var Sel.Bis.Datum, Sel.Von.Datum, Sel.bis.datum)=false ) then RETURN;
  //if (Dlg_Standard:DatumVonBis(Translate('Vergleichs-Zeitraum'), var Sel.Von.Datum2, var Sel.Bis.Datum2, Sel.Von.Datum2, Sel.bis.datum2)=false ) then RETURN;
  //if (Dlg_Standard:Anzahl(Translate('Jahr'), var GV.Int.01, dateyear(today)+1900)=false ) then RETURN;
  //if (Gv.Int.01<1900) or (GV.Int.01>2099) then RETURN;
  //if (Dlg_Standard:Anzahl(Translate('max. Anzahl'), var gMAX, 30)=false ) then RETURN;
  //if (gMAX<0) then RETURN;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Sel.LST.450016', here + ':AusSel');
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
  vHdl2->WinLstDatLineAdd('Deckungsbeitrag');
//  vHdl2->WinLstDatLineAdd('Tonne');
  vHdl2->WinLstDatLineAdd('Umsatz');
  // vHdl2->wpcurrentint # 3;
  vHdl2->wpcurrentint # 2;

  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end   // keine Sortierung ausgewählt? ->  ENDE
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
  Erx         : int;
  vProzLJ     : float;
  vDurchLJ    : float;
  vSpanLJ     : float;
  vProzVJ     : float;
  vDurchVJ    : float;
  vSpanVJ     : float;

  vGew      : float;
  vUms      : float;
  vProz     : float;
  vDurch    : float;
  vDB       : float;
  vSpan     : float;
end;
begin

  case aName of

    'Pos' : begin
      Adr.Kundennr # s_KuNr;
      Erx # RecRead(100,2,0);     // Kunde holen
      if (Erx>_rMultiKey) then RecBufClear(100);

      // fehlende Werte errechnen...
      vProzLJ # Proz(s_UmsLJ, gUmsLJ);
      vProzVJ # Proz(s_UmsVJ, gUmsVJ);
      if (s_GewLJ<>0.0) then vDurchLJ # Rnd(s_UmsLJ / s_GewLJ,2) * 1000.0
      else vDurchLJ # 0.0;
      if (s_GewVJ<>0.0) then vDurchVJ # Rnd(s_UmsVJ / s_GewVJ,2) * 1000.0
      else vDurchVJ # 0.0;
      vSpanLJ # Proz(s_DBLJ, s_UmsLJ);
      vSpanVJ # Proz(s_DBVJ, s_UmsVJ);

      // Differenzen...
      vGew    # s_GewLJ   - s_GewVJ;
      vUms    # s_UmsLJ   - s_UmsVJ;
      vProz   # vProzLJ   - vProzVJ;
      vDurch  # vDurchLJ  - vDurchVJ;
      vDB     # s_DBLJ - s_DBVJ;
      vSpan   # Proz(vSpanLJ, vSpanVJ) - 100.0;

      // kg in Tonne wandeln...
      s_GewLJ # Rnd(s_GewLJ / 1000.0, 1);
      s_GewVJ # Rnd(s_GewVJ / 1000.0, 1);
      vGew    # Rnd(vGew / 1000.0, 1);
      s_UmsLJ # Rnd(s_UmsLJ / 1000.0, 1);
      s_UmsVJ # Rnd(s_UmsVJ / 1000.0, 1);
      vUms    # Rnd(vUms / 1000.0, 1);
      s_DBLJ  # Rnd(s_DBLJ / 1000.0, 1);
      s_DBVJ  # Rnd(s_DBVJ / 1000.0, 1);
      vDB     # Rnd(vDB / 1000.0, 1);


      StartLine();
      Write(1,  Adr.Stichwort                             ,n , 0);
      Write(2,  ZahlF(s_UmsLJ,1)                          ,y , _LF_Wae);
      Write(3,  ZahlF(vProzLJ,1)                          ,y , _LF_Num);
      Write(4,  ZahlF(s_DBLJ,1)                           ,y , _LF_Num);
      Write(5,  ZahlF(vSpanLJ,1)                          ,y , _LF_Num);
      Write(6,  ZahlF(s_UmsVJ,1)                          ,y , _LF_Wae);
      Write(7, ZahlF(vProzVJ,1)                           ,y , _LF_Num);
      Write(8, ZahlF(s_DBVJ,1)                            ,y , _LF_Num);
      Write(9, ZahlF(vSpanVJ,1)                           ,y , _LF_Num);
      Write(10, ZahlF(vUms,1)                             ,y , _LF_Wae);
      Write(11, ZahlF(vProz,1)                            ,y , _LF_Num);
      Write(12, ZahlF(vDB,1)                              ,y , _LF_Num);
      Write(13, ZahlF(vSpan,1)                            ,y , _LF_Num);
      EndLine();

      // MS(02.07.2009) Addition fuer ZWISCHENSUMME
      gZSGewLJ    #  gZSGewLJ     + s_GewLJ;
      gZSUmsLJ    #  gZSUmsLJ     + s_UmsLJ;
      gZSProzLJ   #  gZSProzLJ    + vProzLJ;
      gZSDBLJ     #  gZSDBLJ      + s_DBLJ;

      gZSGewVJ    #  gZSGewVJ     + s_GewVJ;
      gZSUmsVJ    #  gZSUmsVJ     + s_UmsVJ;
      gZSProzVJ   #  gZSProzVJ    + vProzVJ;
      gZSDBVJ     #  gZSDBVJ      + s_DBVJ;

      gZSGew      #  gZSGew       + vGew;
      gZSUms      #  gZSUms       + vUms;
      gZSProz     #  gZSProz      + vProz;
      gZSDB       #  gZSDB        + vDB;
    end;

    'ZwischenSumme' : begin
      if (gZSGewLJ<>0.0) then
        gZSDurchLJ # Rnd(gZSUmsLJ / gZSGewLJ,2) * 1000.0
      else
        gZSDurchLJ # 0.0;
      if (gZSGewVJ<>0.0) then
        gZSDurchVJ # Rnd(gZSUmsVJ / gZSGewVJ,2) * 1000.0
      else
        gZSDurchVJ # 0.0;

      gZSSpanLJ # Proz(gZSDBLJ, gZSUmsLJ);
      gZSSpanVJ # Proz(gZSDBVJ, gZSUmsVJ);
      gZSDurc   # gZSDurchLJ  - gZSDurchVJ;
      gZSSpan   # Proz(gZSSpanLJ, gZSSpanVJ) - 100.0;

      StartLine(_LF_Overline);
      Write(1, 'ZWISCHENSUMME:'                                , y, 0);

      Write(2,  ZahlF(gZSUmsLJ   , 1)                           , y, _LF_Wae);
      Write(3,  ZahlF(gZSProzLJ  , 1)                           , y, _LF_Num);

      Write(4,  ZahlF(gZSDBLJ    , 1)                           , y, _LF_Num);
      Write(5,  ZahlF(gZSSpanLJ  , 1)                           , y, _LF_Num);


      Write(6,  ZahlF(gZSUmsVJ   , 1)                           , y, _LF_Wae);
      Write(7, ZahlF(gZSProzVJ  , 1)                           , y, _LF_Num);

      Write(8, ZahlF(gZSDBVJ    , 1)                           , y, _LF_Num);
      Write(9, ZahlF(gZSSpanVJ  , 1)                           , y, _LF_Num);


      Write(10, ZahlF(gZSUms     , 1)                           , y, _LF_Wae);
      Write(11, ZahlF(gZSProz    , 1)                           , y, _LF_Num);

      Write(12, ZahlF(gZSDB      , 1)                           , y, _LF_Num);
      Write(13, ZahlF(gZSSpan    , 1)                           , y, _LF_Num);
      EndLine();
     end; // GesamtSumme


    'Rest' : begin
      // fehlende Werte errechnen...
      vProzLJ # Proz(gRUmsLJ, gUmsLJ);
      vProzVJ # Proz(gRUmsVJ, gUmsVJ);
      if (Rnd(gRGewLJ,4)<>0.0) then vDurchLJ # Rnd(gRUmsLJ / gRGewLJ,2) * 1000.0
      else vDurchLJ # 0.0;
      if (Rnd(gRGewVJ,4)<>0.0) then vDurchVJ # Rnd(gRUmsVJ / gRGewVJ,2) * 1000.0
      else vDurchVJ # 0.0;
      vSpanLJ # Proz(gRDBLJ, gRUmsLJ);
      vSpanVJ # Proz(gRDBVJ, gRUmsVJ);

      // Differenzen...
      vGew    # gRGewLJ   - gRGewVJ;
      vUms    # gRUmsLJ   - gRUmsVJ;
      vProz   # vProzLJ   - vProzVJ;
      vDurch  # vDurchLJ  - vDurchVJ;
      vDB     # gRDBLJ - gRDBVJ;
      vSpan   # Proz(vSpanLJ, vSpanVJ) - 100.0;

      // kg in Tonne wandeln...
      gRGewLJ # Rnd(gRGewLJ / 1000.0, 1);
      gRGewVJ # Rnd(gRGewVJ / 1000.0, 1);
      vGew    # Rnd(vGew / 1000.0, 1);
      gRUmsLJ # Rnd(gRUmsLJ / 1000.0, 1);
      gRUmsVJ # Rnd(gRUmsVJ / 1000.0, 1);
      vUms    # Rnd(vUms / 1000.0, 1);
      gRDBLJ  # Rnd(gRDBLJ / 1000.0, 1);
      gRDBVJ  # Rnd(gRDBVJ / 1000.0, 1);
      vDB     # Rnd(vDB / 1000.0, 1);


      StartLine(_LF_Overline);
      Write(1, 'REST:'                                    ,y, 0);

      Write(2,  ZahlF(gRUmsLJ,1)                           ,y , _LF_Wae);
      Write(3,  ZahlF(vProzLJ,1)                          ,y , _LF_Num);

      Write(4,  ZahlF(gRDBLJ,1)                            ,y , _LF_Num);
      Write(5,  ZahlF(vSpanLJ,1)                          ,y , _LF_Num);


      Write(6,  ZahlF(gRUmsVJ,1)                           ,y , _LF_Wae);
      Write(7, ZahlF(vProzVJ,1)                          ,y , _LF_Num);

      Write(8, ZahlF(gRDBVJ,1)                            ,y , _LF_Num);
      Write(9, ZahlF(vSpanVJ,1)                          ,y , _LF_Num);


      Write(10, ZahlF(vUms,1)                             ,y , _LF_Wae);
      Write(11, ZahlF(vProz,1)                            ,y , _LF_Num);

      Write(12, ZahlF(vDB ,1)                             ,y , _LF_Num);
      Write(13, ZahlF(vSpan,1)                            ,y , _LF_Num);
      EndLine();
     end; // Rest


    'GesamtSumme' : begin
      // fehlende Werte errechnen...
      vProzLJ # 100.0;
      vProzVJ # 100.0;
      if (Rnd(gGewLJ,4)<>0.0) then vDurchLJ # Rnd(gUmsLJ / gGewLJ,2) * 1000.0
      else vDurchLJ # 0.0;
      if (Rnd(gGewVJ,4)<>0.0) then vDurchVJ # Rnd(gUmsVJ / gGewVJ,2) * 1000.0
      else vDurchVJ # 0.0;
      vSpanLJ # Proz(gEKLJ, gUmsLJ);
      vSpanVJ # Proz(gEKVJ, gUmsVJ);

      // Differenzen...
      vGew    # gGewLJ   - gGewVJ;
      vUms    # gUmsLJ   - gUmsVJ;
      vProz   # vProzLJ   - vProzVJ;
      vDurch  # vDurchLJ  - vDurchVJ;
      vDB     # gDBLJ - gDBVJ;
      vSpan   # Proz(vSpanLJ, vSpanVJ) - 100.0;

      // kg in Tonne wandeln...
      gGewLJ  # Rnd(gGewLJ / 1000.0, 1);
      gGewVJ  # Rnd(gGewVJ / 1000.0, 1);
      vGew    # Rnd(vGew / 1000.0, 1);
      gUmsLJ  # Rnd(gUmsLJ / 1000.0, 1);
      gUmsVJ  # Rnd(gUmsVJ / 1000.0, 1);
      vUms    # Rnd(vUms / 1000.0, 1);
      gDBLJ   # Rnd(gDBLJ / 1000.0, 1);
      gDBVJ   # Rnd(gDBVJ / 1000.0, 1);
      vDB     # Rnd(vDB / 1000.0, 1);


      StartLine(_LF_Overline);
      Write(1, 'GESAMT SUMME:'                            ,y, 0);
      Write(2,  ZahlF(gUmsLJ,1)                           ,y , _LF_Wae);

      Write(3,  ZahlF(vProzLJ,1)                          ,y , _LF_Num);

      Write(4,  ZahlF(gDBLJ,1)                            ,y , _LF_Num);
      Write(5,  ZahlF(vSpanLJ,1)                          ,y , _LF_Num);


      Write(6,  ZahlF(gUmsVJ,1)                           ,y , _LF_Wae);
      Write(7, ZahlF(vProzVJ,1)                          ,y , _LF_Num);

      Write(8, ZahlF(gDBVJ,1)                            ,y , _LF_Num);
      Write(9, ZahlF(vSpanVJ,1)                          ,y , _LF_Num);


      Write(10, ZahlF(vUms,1)                             ,y , _LF_Wae);
      Write(11, ZahlF(vProz,1)                            ,y , _LF_Num);

      Write(12, ZahlF(vDB ,1)                             ,y , _LF_Num);
      Write(13, ZahlF(vSpan,1)                            ,y , _LF_Num);
      EndLine();
     end; // GesamtSumme

  end; // CASE

end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();
  if (aSeite=1) then begin
    List_Spacing[ 1]  #  0.0;
    List_Spacing[ 2]  # 300.0;
    StartLine();
    Write(1,  'Zeitraum 1 von '+cnvad(Sel.von.Datum)+' bis '+cnvad(Sel.bis.Datum)   ,n , 0);
    EndLine();
    StartLine();
    Write(1,  'Zeitraum 2 von '+cnvad(Sel.von.Datum2)+' bis '+cnvad(Sel.bis.Datum2) ,n , 0);
    EndLine();
    StartLine();
    Write(1,  'Umsätze in Tausend; Gesamtsummen basieren auf den echten Umsätzen - sie können von den gerundeten Einzelwerten leicht abweichen!',n , 0);
    EndLine();
  end;
  StartLine();
  EndLine();


  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 26.0;

  List_Spacing[ 3]  # List_Spacing[ 2] + cS1;
  List_Spacing[ 4]  # List_Spacing[ 3] + cS1;
  List_Spacing[ 5]  # List_Spacing[ 4] + cS2;
  List_Spacing[ 6]  # List_Spacing[ 5] + cS4;
  List_Spacing[ 7]  # List_Spacing[ 6] + cS1;
  List_Spacing[ 8]  # List_Spacing[ 7] + cS2;

  List_Spacing[ 9]  # List_Spacing[ 8] + cS1;
  List_Spacing[10]  # List_Spacing[ 9] + cS4;
  List_Spacing[11]  # List_Spacing[10] + cS2;
  List_Spacing[12]  # List_Spacing[11] + cS1;
  List_Spacing[13]  # List_Spacing[12] + cS3;
  List_Spacing[14]  # List_Spacing[13] + cS2;

  List_Spacing[15]  # List_Spacing[14] + cS1;
  List_Spacing[16]  # List_Spacing[15] + cS1;
  List_Spacing[17]  # List_Spacing[16] + cS2;
  List_Spacing[18]  # List_Spacing[17] + cS1;
  List_Spacing[19]  # List_Spacing[18] + cS1;
  List_Spacing[20]  # List_Spacing[19] + cS2;

  List_Spacing[21]  # List_Spacing[20] + 20.0;
  List_Spacing[22]  # List_Spacing[21] + 20.0;

  List_FontSize # 8;

  if(List_XML = false) then begin
    List_Spacing[ 3]  # List_Spacing[ 2] + 60.0;
    List_Spacing[ 4]  # List_Spacing[ 3] + 9.0;
    List_Spacing[ 5]  # List_Spacing[ 4] + 5.0;
    List_Spacing[ 6]  # List_Spacing[ 5] + 5.0;
    List_Spacing[ 7]  # List_Spacing[ 6] + 5.0;
    List_Spacing[ 8]  # List_Spacing[ 7] + 60.0;


    StartLine(_LF_Bold);
    Write(2,  'von ' + cnvad(Sel.von.Datum) + ' bis ' + cnvad(Sel.bis.Datum)      ,y , 0);
    Write(7,  'von ' + cnvad(Sel.von.Datum2) + ' bis ' + cnvad(Sel.bis.Datum2)    ,y , 0);
    EndLine();

    List_Spacing[ 3]  # List_Spacing[ 2] + cS1;
    List_Spacing[ 4]  # List_Spacing[ 3] + cS1;
    List_Spacing[ 5]  # List_Spacing[ 4] + cS2;
    List_Spacing[ 6]  # List_Spacing[ 5] + cS4;
    List_Spacing[ 7]  # List_Spacing[ 6] + cS1;
    List_Spacing[ 8]  # List_Spacing[ 7] + cS2;
  end;

  StartLine(_LF_UnderLine + _LF_Bold);
  if(List_XML = true) then begin
    Write(1,  'Kunde'                                                 ,n , 0);
    Write(2,  'Z1 Umsatz '+"Set.Hauswährung.Kurz"                     ,y , 0);
    Write(3,  'Z1 Umsatz % '                                          ,y , 0);
    Write(4,  'Z1 Deckungsb. '+"Set.Hauswährung.Kurz"                 ,y , 0);
    Write(5,  'Z1 RG %'                                           ,y , 0);

    Write(6,  'Z2 Umsatz '+"Set.Hauswährung.Kurz"                     ,y , 0);
    Write(7,  'Z2 Umsatz % '                                          ,y , 0);
    Write(8,  'Z2 Deckungsb. '+"Set.Hauswährung.Kurz"                 ,y , 0);
    Write(9,  'Z2 RG %'                                           ,y , 0);
    Write(10, 'Umsatz Diff '+"Set.Hauswährung.Kurz"                   ,y , 0);
    Write(11, 'Umsatz Diff %'                                         ,y , 0);
    Write(12, 'Deckungsb. Diff '+"Set.Hauswährung.Kurz"               ,y , 0);
    Write(13, 'Spanne Diff %'                                         ,y , 0);
  end
  else begin // kein XML
    Write(1,  'Kunde'                                                 ,n , 0);
    Write(2,  'Umsatz '+"Set.Hauswährung.Kurz"                     ,y , 0);
    Write(3,  'Umsatz % '                                          ,y , 0);
    Write(4,  'Deckungsb. '+"Set.Hauswährung.Kurz"                 ,y , 0);
    Write(5,  'RG %'                                           ,y , 0);

    Write(6,  'Umsatz '+"Set.Hauswährung.Kurz"                     ,y , 0);
    Write(7,  'Umsatz % '                                          ,y , 0);
    Write(8,  'Deckungsb. '+"Set.Hauswährung.Kurz"                 ,y , 0);
    Write(9,  'RG %'                                           ,y , 0);

    Write(10, 'Umsatz Diff '+"Set.Hauswährung.Kurz"                   ,y , 0);
    Write(11, 'Umsatz Diff %'                                         ,y , 0);
    Write(12, 'Deckungsb. Diff '+"Set.Hauswährung.Kurz"               ,y , 0);
    Write(13, 'Spanne Diff %'                                        ,y , 0);
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
//  MerkeDaten
//
//========================================================================
Sub MerkeDaten(aTree : int; aSort : int);
local begin
  vItem   : int;
end;
begin

  // Item für Baum anlegen...
  vItem # CteOpen(_CteItem);

  // Sortierung über EINDEUTIGEN Name
  if (aSort=1) then
    vItem->spname # cnvaf(1000000000.0-s_DBLJ,_FmtNumNoGroup|_FmtNumLeadZero,0,2,15)+cnvai(s_kunr);
/*
  if (aSort=2) then
    vItem->spname # cnvaf(1000000000.0-s_GewLJ,_FmtNumNoGroup|_FmtNumLeadZero,0,2,15)+cnvai(s_kunr);;
*/
//  if (aSort=3) then
  if (aSort=2) then
    vItem->spname # cnvaf(1000000000.0-s_UmsLJ,_FmtNumNoGroup|_FmtNumLeadZero,0,2,15)+cnvai(s_kunr);;

  // Handle der Structure im Item mekren...
  vItem->spid   # VarInfo(struct_Werte);

  // Item im Baum speicehrn...
  Cteinsert(aTree, vitem);
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
  vKey        : int;
  vTree       : int;

  vSortKey    : alpha;
  vItem       : int;

  vQ450       : alpha(4000);
  vQ100       : alpha(4000);

  vKuNr       : int;
  vX          : float;

end;
begin

  // Liste starten
  ListInit(y); // mit Landscape

  // Selektionsquery
  vQ450 # '';
  Lib_Sel:QVonBisD(var vQ450, 'Erl.Rechnungsdatum', Sel.von.Datum , Sel.bis.Datum);
  Lib_Sel:QVonBisD(var vQ450, 'Erl.Rechnungsdatum', Sel.von.Datum2, Sel.bis.Datum2, 'OR');
  vQ450 # StrIns(vQ450, '(', 1);
  Lib_Strings:Append(var vQ450, ')' , '');

  // Selektionsquery für 100
  vQ100 # '';
  if(Sel.Adr.von.LKZ <> '') then
    Lib_Sel:QAlpha(var vQ100, 'Adr.LKZ', '=', Sel.Adr.von.LKZ);

  if(vQ100 <> '') then begin
    Lib_Strings:Append(var vQ450, 'LinkCount(AdrReEmpf) > 0' , ' AND ');
  end;

  // Selektion starten...
  vSel # SelCreate(450, 1);
  vSel -> SelAddLink('', 100, 450, 8, 'AdrReEmpf');
  erx # vSel->SelDefQuery('', vQ450);
  if(Erx <> 0) then
    Lib_Sel:QError(vSel);
  erx # vSel->SelDefQuery('AdrReEmpf', vQ100);
  if(Erx <> 0) then
    Lib_Sel:QError(vSel);


  vSelName # Lib_Sel:SaveRun(var vSel, 3);  // nach Kunde sortiert

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  vTree # CteOpen(_CteTree);    // Rambaum anlegen

  Erx # RecRead(450,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN // Material loopen

    if (Sel.Fin.LiefGutBelYN=false) then begin
      Erx # RecLink(451,450,1,_RecFirst);     // 1.Erloeskonto holen
      if (Erx<=_rLocked) then begin
        Auf.Nummer # Erl.K.Auftragsnr;
        Erx # RecRead(400,1,0);               // Auftrag holen
        if (Erx > _rLocked) then begin
          "Auf~Nummer" # Erl.K.Auftragsnr;
          Erx # RecRead(410,1,0);             // Auftrag holen
          if (Erx > _rLocked) then RecBufClear(400)
          else RecbufCopy(410,400);
        end;
        if (Auf.Vorgangstyp=c_Gut) or (Auf.Vorgangstyp=c_Bel_LF) then begin
          Erx # RecRead(450,vSel,_recNext);
          CYCLE;
        end;
      end;
    end;

    // Kundenwechsel?
    if (vKuNr<>Erl.Kundennummer) then begin
      if (vKuNr<>0) then MerkeDaten(vTree,aSort); // bisherige Structure im Baum speichern
      VarAllocate(Struct_Werte);            // neue Structure anlegen
      s_KuNr # Erl.Kundennummer;
      vKuNr  # Erl.Kundennummer;
    end;

    vX # 0.0;
    Erx # RecLink(451,450,1,_RecFirst);   // Erloeskonto holen
    WHILE(Erx <= _rLocked) DO BEGIN
      vX # vX + Erl.K.EKPreisSummeW1;     // EK summieren
      Erx # RecLink(451,450,1,_RecNext);
    END;

    // aktuelle sJahr?
    if (Erl.Rechnungsdatum >= Sel.Von.Datum) then begin
      s_EKLJ  # s_EKLJ + vX;
      s_UmsLJ # s_UmsLJ + Erl.NettoW1;
      s_GewLJ # s_GewLJ + Erl.Gewicht;
      s_DBLJ  # s_UmsLJ - s_EKLJ;

      gEKLJ   # gEKLJ + vX;
      gUmsLJ  # gUmsLJ + Erl.NettoW1;
      gGewLJ  # gGewLJ + Erl.Gewicht;
      gDBLJ   # gDBLJ + (Erl.NettoW1 - vX);
      end
    else begin
//debug('re:'+erl.kundenstichwort+cnvai(erl.rechnungsnr)+'  '+cnvad(Erl.rechnungsdatum));
    // Vorjahr...
      s_EKVJ  # s_EKVJ + vX;
      s_UmsVJ # s_UmsVJ + Erl.NettoW1;
      s_GewVJ # s_GewVJ + Erl.Gewicht;
      s_DBVJ  # s_UmsVJ - s_EKVJ;

      gEKVJ   # gEKVJ + vX;
      gUmsVJ  # gUmsVJ + Erl.NettoW1;
      gGewVJ  # gGewVJ + Erl.Gewicht;
      gDBVJ   # gDBVJ + (Erl.NettoW1 - vX);
    end;

    Erx # RecRead(450,vSel,_recNext);
  END;

  if (vKuNr<>0) then MerkeDaten(vTree, aSort); // bisherige Structure im Baum speichern

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(450, vSelName);



  // AUSGABE ---------------------------------------------------------------
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  gRGewLJ # gGewLJ;
  gRUmsLJ # gUmsLJ;
  gREKLJ  # gEKLJ;
  gRDBLJ  # gDBLJ;

  gRGewVJ # gGewVJ;
  gRUmsVJ # gUmsVJ;
  gREKVJ  # gEKVJ;
  gRDBVJ  # gDBVJ;

  // Tree durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    gAnz # gAnz + 1;

    // Structure holen...
    VarInstance(struct_werte, vItem->spID);

    if (cMAX=0) or (gAnz <= cMax) then begin
      gRGewLJ # gRGewLJ - s_GewLJ;
      gRUmsLJ # gRUmsLJ - s_UmsLJ;
      gREKLJ  # gREKLJ - s_EKLJ;
      gRDBLJ  # gRDBLJ - s_DBLJ;

      gRGewVJ # gRGewVJ - s_GewVJ;
      gRUmsVJ # gRUmsVJ - s_UmsVJ;
      gREKVJ  # gREKVJ - s_EKVJ;
      gRDBVJ  # gRDBVJ - s_DBVJ;
      PRINT('Pos');
    end;

    // Structure zerstören...
    VarFree(struct_werte);

  END;  // loop

  Print('ZwischenSumme');
  Print('Rest');
  Print('GesamtSumme');

  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================