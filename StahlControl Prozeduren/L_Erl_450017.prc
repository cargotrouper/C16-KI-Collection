@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450017
//                    OHNE E_R_G
//  Info        Artikel Hitliste pro Jahr
//              UEBER Auftrags Aktionen
//
//              MUSTER für Structures in Listen
//
//
//  14.05.2009  AI  Erstellung der Prozedur
//  29.06.2011  MS  Anpassung an eine NEUE ALLGEMEINE ARTIKEL Liste
//  05.07.2011  MS  Anpassung an Artikel Hitliste
//  09.07.2013  ST  Spaltenüberschrift von "Kunde" auf "Artikel" korrigiert
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
  cS1       : 21.0;
  cS2       : 23.0;
  cS3       : 25.0;
  cS4       : 12.0;
  Proz(a,b) : Lib_Berechnungen:Prozent(a,b)
  cMax      : GV.Int.03
end

global Struct_Werte begin
  s_ArtNr   : alpha;
  s_GewLJ   : float;
  s_UmsLJ   : float;
  s_EKLJ    : float;
  s_IntKLJ  : float;
  s_DBLJ    : float;
  s_GewVJ   : float;
  s_UmsVJ   : float;
  s_EKVJ    : float;
  s_IntKVJ  : float;
  s_DBVJ    : float;
end;

local begin
  gGewLJ    : float;
  gUmsLJ    : float;
  gEKLJ     : float;
  gIntKLJ   : float;
  gDBLJ     : float;
  gGewVJ    : float;
  gUmsVJ    : float;
  gEKVJ     : float;
  gIntKVJ   : float;
  gDBVJ     : float;

  gAnz      : int;

  gRGewLJ   : float;
  gRUmsLJ   : float;
  gREKLJ    : float;
  gRIntKLJ  : float;
  gRDBLJ    : float;
  gRGewVJ   : float;
  gRUmsVJ   : float;
  gREKVJ    : float;
  gRIntKVJ  : float;
  gRDBVJ    : float;

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

  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Sel.LST.450017', here + ':AusSel');
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
  vHdl2->WinLstDatLineAdd('Umsatz');
  vHdl2->wpcurrentint # 3;
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
      Art.Nummer # s_ArtNr;
      Erx # RecRead(250, 1, 0);     // Kunde holen
      if (Erx > _rMultiKey) then
        RecBufClear(250);



      // fehlende Werte errechnen...
      vProzLJ # Proz(s_UmsLJ, gUmsLJ);
      vProzVJ # Proz(s_UmsVJ, gUmsVJ);
      if(s_GewLJ <> 0.0) then
        vDurchLJ # Rnd(s_UmsLJ / s_GewLJ,2) * 1000.0
      else
        vDurchLJ # 0.0;
      if(s_GewVJ <> 0.0) then
        vDurchVJ # Rnd(s_UmsVJ / s_GewVJ,2) * 1000.0
      else
        vDurchVJ # 0.0;
      vSpanLJ # Proz(s_DBLJ, s_UmsLJ);
      vSpanVJ # Proz(s_DBVJ, s_UmsVJ);

      // Differenzen...
      vGew    # s_GewLJ   - s_GewVJ;
      vUms    # s_UmsLJ   - s_UmsVJ;
      vProz   # Proz(s_UmsLJ, s_UmsVJ) - 100.0;
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
      Write(1,  Art.Stichwort                             ,n , 0);
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
      gZSProz   # Proz(gZSUmsVJ, gZSUmsLJ);
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
      vProz   # Proz(gRUmsLJ, gRUmsVJ);
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
      if (Rnd(gGewLJ,4) <> 0.0) then
        vDurchLJ # Rnd(gUmsLJ / gGewLJ,2) * 1000.0
      else
        vDurchLJ # 0.0;

      if (Rnd(gGewVJ,4)<>0.0) then
        vDurchVJ # Rnd(gUmsVJ / gGewVJ,2) * 1000.0
      else
        vDurchVJ # 0.0;

      vSpanLJ # Proz(gEKLJ, gUmsLJ);
      vSpanVJ # Proz(gEKVJ, gUmsVJ);

      // Differenzen...
      vGew    # gGewLJ   - gGewVJ;
      vUms    # gUmsLJ   - gUmsVJ;
      vProz   # Proz(gUmsLJ ,gUmsVJ);
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
  List_Spacing[ 2]  # List_Spacing[ 1] + 28.0;

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
    Write(1,  'Artikel'                                                 ,n , 0);
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
    Write(1,  'Artikel'                                                 ,n , 0);
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
  if (aSort = 1) then
    vItem->spname # cnvaf(1000000000.0-s_DBLJ,_FmtNumNoGroup|_FmtNumLeadZero,0,2,15) + s_ArtNr;
  if (aSort = 2) then
    vItem->spname # cnvaf(1000000000.0-s_UmsLJ,_FmtNumNoGroup|_FmtNumLeadZero,0,2,15) + s_ArtNr;

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
  vQ404       : alpha(4000);
  vQ400       : alpha(4000);
  vQ100       : alpha(4000);

  vArtNr      : alpha;
  vX          : float;

end;
begin

  // Liste starten
  ListInit(y); // mit Landscape

  // Selektionsquery
  vQ404 # '';
  Lib_Sel:QVonBisD(var vQ404 , 'Auf.A.Rechnungsdatum', Sel.von.Datum , Sel.bis.Datum);
  Lib_Sel:QVonBisD(var vQ404 , 'Auf.A.Rechnungsdatum', Sel.von.Datum2, Sel.bis.Datum2, 'OR');
  vQ404  # StrIns(vQ404 , '(', 1);
  Lib_Strings:Append(var vQ404 , ')' , '');
  Lib_Sel:QInt(var vQ404, 'Auf.A.Rechnungsnr', '!=', 0);
  Lib_Sel:QAlpha(var vQ404, 'Auf.A.ArtikelNr', '!=', '');

  // Selektion starten...
  vSel # SelCreate(404, 1);
  Erx # vSel -> SelDefQuery('', vQ404);
  if(Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 5);  // nach Artikel sortiert

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  vTree # CteOpen(_CteTree);    // Rambaum anlegen

  FOR Erx # RecRead(404, vSel, _recFirst);
  LOOP Erx # RecRead(404, vSel,_recNext);
  WHILE (Erx <= _rLocked) DO BEGIN // Aktionen loopen
    Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, true);

    if (Sel.Fin.LiefGutBelYN = false) then begin
      if (Auf.Vorgangstyp=c_Gut) or (Auf.Vorgangstyp=c_Bel_LF) then
        CYCLE;
    end;

    // Artikelwechsel?
    if (vArtNr <> Auf.A.ArtikelNr) then begin
      if (vArtNr <> '') then
        MerkeDaten(vTree,aSort); // bisherige Structure im Baum speichern
      VarAllocate(Struct_Werte);            // neue Structure anlegen
      s_ArtNr # Auf.A.ArtikelNr;
      vArtNr  # Auf.A.ArtikelNr;
    end;

    if (Auf.A.Rechnungsdatum >= Sel.Von.Datum) then begin     // aktuelle sJahr?
      s_EKLJ    # s_EKLJ + Auf.A.EKPreisSummeW1;
      s_IntKLJ  # s_IntKLJ + Auf.A.interneKostW1;
      s_UmsLJ   # s_UmsLJ + Auf.A.RechPreisW1;
      s_GewLJ   # s_GewLJ + Auf.A.Gewicht;
      s_DBLJ    # s_DBLJ + (Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1 - Auf.A.interneKostW1);

      /*
      debug('     - - -      ');
      debug(Auf.A.ArtikelNr);
      debug('EK: '   + ANum(Auf.A.EKPreisSummeW1,2) );
      debug('IntK: ' + ANum(Auf.A.interneKostW1,2) );
      debug('Ums: '  + ANum(Auf.A.RechPreisW1,2) );
      debug('Gew: '  + ANum(Auf.A.Gewicht,2) );
      debug('DB: '   + ANum(s_DBLJ,2) );
      debug('     - - -      ');
      */

      gEKLJ   # gEKLJ + Auf.A.EKPreisSummeW1;
      gIntKLJ # gIntKLJ + Auf.A.interneKostW1;
      gUmsLJ  # gUmsLJ + Auf.A.RechPreisW1;
      gGewLJ  # gGewLJ + Auf.A.Gewicht;
      gDBLJ   # gDBLJ + (Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1 - Auf.A.interneKostW1);
      end
    else begin      // Vorjahr...
      s_EKVJ   # s_EKVJ + Auf.A.EKPreisSummeW1;
      s_IntKVJ # s_IntKVJ + Auf.A.interneKostW1;
      s_UmsVJ  # s_UmsVJ + Auf.A.RechPreisW1;
      s_GewVJ  # s_GewVJ + Auf.A.Gewicht;
      s_DBVJ   # s_DBVJ + (Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1 - Auf.A.interneKostW1);

      gEKVJ   # gEKVJ + Auf.A.EKPreisSummeW1;
      gIntKVJ # gIntKVJ + Auf.A.interneKostW1;
      gUmsVJ  # gUmsVJ + Auf.A.RechPreisW1;
      gGewVJ  # gGewVJ + Auf.A.Gewicht;
      gDBVJ   # gDBVJ + (Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1 - Auf.A.interneKostW1);
    end;

  END;

  if (vArtNr <> '') then
    MerkeDaten(vTree, aSort); // bisherige Structure im Baum speichern

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(404, vSelName);



  // AUSGABE ---------------------------------------------------------------
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  gRGewLJ   # gGewLJ;
  gRUmsLJ   # gUmsLJ;
  gREKLJ    # gEKLJ;
  gRIntKLJ  # gIntKLJ;
  gRDBLJ    # gDBLJ;


  /*

  debug('     - GESAMT -      ');
  debug('EK: '   + ANum(gEKLJ,2) );
  debug('IntK: ' + ANum(gIntKVJ,2) );
  debug('Ums: '  + ANum(gUmsLJ,2) );
  debug('Gew: '  + ANum(gGewLJ,2) );
  debug('DB: '   + ANum(gDBLJ,2) );
  debug('     - - -      ');

*/


  gRGewVJ   # gGewVJ;
  gRUmsVJ   # gUmsVJ;
  gREKVJ    # gEKVJ;
  gRIntKVJ  # gIntKVJ;
  gRDBVJ    # gDBVJ;


/*
  debug('     - - -      ');
  debug('     AUSGABE      ');
  debug('     - - -      ');
*/
  // Tree durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    gAnz # gAnz + 1;

    // Structure holen...
    VarInstance(struct_werte, vItem->spID);

    if (cMAX = 0) or (gAnz <= cMax) then begin
      /*
      debug('     - - -      ');
      debug(s_ArtNr);
      debug('EK: '   + ANum(s_EKLJ,2) );
      debug('IntK: ' + ANum(s_IntKLJ,2) );
      debug('Ums: '  + ANum(s_UmsLJ,2) );
      debug('Gew: '  + ANum(s_GewLJ,2) );
      debug('DB: '   + ANum(s_DBLJ,2) );
      debug('     - - -      ');
*/

      gRGewLJ # gRGewLJ - s_GewLJ;
      gRUmsLJ # gRUmsLJ - s_UmsLJ;
      gREKLJ  # gREKLJ - s_EKLJ;
      gRIntKLJ  # gRIntKLJ - s_IntKLJ;
      gRDBLJ  # gRDBLJ - s_DBLJ;

      gRGewVJ # gRGewVJ - s_GewVJ;
      gRUmsVJ # gRUmsVJ - s_UmsVJ;
      gREKVJ  # gREKVJ - s_EKVJ;
      gRIntKVJ  # gRIntKVJ - s_IntKVJ;
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
