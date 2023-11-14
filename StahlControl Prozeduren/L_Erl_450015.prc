@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450015
//                    OHNE E_R_G
//  Info        Erlöse Projekte
//
//
//
//  02.11.2010  MS  Erstellung der Prozedur
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB Element(aName : alpha; aPrint : logic);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List2
@I:Def_Aktionen

declare StartList(aSort : int; aSortName : alpha);

// Handles für die Zeilenelemente
local begin
  g_Empty       : int;
  g_Sel1        : int;
  g_Sel2        : int;
  g_Sel3        : int;

  g_Header      : int;
  g_Position    : int;
  g_SumPrj      : int;
  g_SumKd       : int;
  g_SumGes      : int;
  g_Leselinie   : logic;

  g_BufLast451  : int;
end;

define begin
  cSumPrjNetto : 1

  cSumKdNetto  : 10

  cSumGesNetto : 20
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
  Sel.Auf.bis.Projekt     # 99999999;
  Sel.Art.bis.ArtNr       # 'zzz';

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450015',here+':AusSel');
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
  /*
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
  vHdl2->WinLstDatLineAdd(Translate('Werksnummer'));
  vHdl2->wpcurrentint#1;
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
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  Erx     : int;
  vLine   : int;
  vObf    : alpha(120);
  vSpacer : float;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin
      if (aPrint) then RETURN;
      // Instanzieren...
           // Instanzieren...
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   20.0;
      List_Spacing[ 3]  #   22.0;
      List_Spacing[ 4]  #   30.0;
      List_Spacing[ 5]  #   47.0;
      List_Spacing[ 6]  #   53.0;
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


      LF_Set(1, 'Re.Dat.'                                           ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      LF_Set(4,  DatS(Sel.von.Datum)                           ,n , _LF_Date);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      LF_Set(6,  Dats(Sel.bis.Datum)                           ,n , _LF_Date);
      LF_Set(7, 'Re.Nr.'                                            ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      LF_Set(10, ZahlI(Sel.Fin.von.Rechnung)                        ,n , _LF_INT);
      LF_Set(11, ' bis: '                                           ,n , 0);
      LF_Set(12,  ZahlI(Sel.Fin.bis.Rechnung)                       ,y , _LF_INT);
    end;


    'SEL2' : begin
      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Auf.Nr.'                                        ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      LF_Set(4, ZahlI(Sel.Auf.von.Nummer)                                ,n , _LF_INT);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      LF_Set(6, ZahlI(Sel.Auf.bis.Nummer)                               ,n , _LF_INT);
      LF_Set(7, 'Prj.Nr.'                                            ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      LF_Set(10, ZahlI(Sel.Auf.von.Projekt)                        ,n , _LF_INT);
      LF_Set(11, ' bis: '                                           ,n , 0);
      LF_Set(12,  ZahlI(Sel.Auf.bis.Projekt)                       ,y , _LF_INT);
    end;

    'SEL3' : begin
      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Kunde'                                        ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(4, ZahlI(Sel.Auf.Kundennr)                                ,n , _LF_INT);


      LF_Set(7, 'Artikel'                                            ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      LF_Set(10, Sel.Art.von.ArtNr                        ,n , 0);
      LF_Set(11, ' bis: '                                           ,n , 0);
      LF_Set(12, Sel.Art.bis.ArtNr                        ,n , 0);
    end;


    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 20.0; // 'Prj.'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 20.0; // 'Re.Datum'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 25.0; // 'Re.Nummer'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 25.0; // 'Auf.Nummer'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 40.0; // 'Artikelnr.'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 20.0; // 'Netto'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 20.0; //
      List_Spacing[ 9]  # List_Spacing[ 8]  + 20.0; //
      List_Spacing[10]  # List_Spacing[ 9]  + 20.0; //
      List_Spacing[11]  # List_Spacing[ 10] + 20.0; //
      List_Spacing[12]  # List_Spacing[ 11] + 20.0; //
      List_Spacing[13]  # List_Spacing[ 12] + 20.0; //
      List_Spacing[14]  # List_Spacing[ 13] + 20.0; //
      List_Spacing[15]  # List_Spacing[ 14] + 20.0; //
      List_Spacing[16]  # List_Spacing[ 15] + 20.0; //
      List_Spacing[17]  # List_Spacing[ 16] + 20.0; //

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Prj.'                                ,y , 0);
      LF_Set(2,  'Re.Datum'                            ,n , 0);
      LF_Set(3,  'Re.Nummer'                           ,y , 0);
      LF_Set(4,  'Auf.Nummer'                          ,y , 0);
      LF_Set(5,  'Artikelnr.'                          ,n , 0);
      LF_Set(6,  'Netto'                               ,y , 0);
    end;


    'POSITION' : begin
      if (aPrint) then begin

        RETURN;
      end;

      // Instanzieren...
      LF_Set(1,  '@Erl.K.Projektnr'       ,y , _LF_IntNG);
      LF_Set(2,  '@Erl.K.Rechnungsdatum'  ,n , _LF_Date);
      LF_Set(3,  '@Erl.K.Rechnungsnr'     ,y , _LF_IntNG);
      LF_Set(4,  '@Erl.K.Auftragsnr'      ,y , _LF_IntNG);
      LF_Set(5,  '@Auf.P.Artikelnr'       ,n , 0);
      LF_Set(6,  '@Erl.K.BetragW1'        ,y , _LF_Wae);
    end;


    'SUMPRJ' : begin
      if (aPrint) then begin
        LF_Sum(6 , cSumPrjNetto, 2);
        RETURN;
      end;

      vSpacer # List_Spacing[ 2];
      List_Spacing[ 2]  # List_Spacing[ 1]  + 120.0;

      LF_Format(_LF_Overline | _LF_Bold);
      LF_Set(1, '@Prj.Stichwort' ,n ,0);
      LF_Set(6, '#Netto'                 ,y , _LF_WAE);

      List_Spacing[ 2] # vSpacer;
    end;


    'SUMKD' : begin
      if (aPrint) then begin
        Adr.KundenNr # g_BufLast451 -> Erl.K.Kundennummer; // Kunde holen
        Erx # RecRead(100, 2, 0);
        if(Erx > _rMultiKey) then
          RecBufClear(100);


        LF_Text(1, '(' + AInt(Adr.KundenNr) + ') ' + Adr.Stichwort);
        LF_Sum(6 , cSumKdNetto, 2);
        RETURN;
      end;

      vSpacer # List_Spacing[ 2];
      List_Spacing[ 2]  # List_Spacing[ 1]  + 120.0;

      LF_Format(_LF_Overline | _LF_Bold);
      LF_Set(1, '#Adr.Stichwort' ,n ,0);
      LF_Set(6, '#Netto'                 ,y , _LF_WAE);

      List_Spacing[ 2] # vSpacer;
    end;


    'SUMGES' : begin
      if (aPrint) then begin
        LF_Sum(6 , cSumGesNetto, 2);
        RETURN;
      end;
      LF_Format(_LF_Overline | _LF_Bold);
      LF_Set(1, 'Gesamt' ,n ,0);
      LF_Set(6, '#Netto'                 ,y , _LF_WAE);
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
  LF_Print(g_Empty);

  if (aSeite=1) then begin
    LF_Print(g_Sel1);
    LF_Print(g_Sel2);
    LF_Print(g_Sel3);
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
  vQ451       : alpha(4000);
  vQ401       : alpha(4000);
  vQ411       : alpha(4000);
  vProgress   : handle;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Erl.K.-Selektion
  vQ451  # '';
  if (Sel.Fin.von.Rechnung <> 0) or (Sel.Fin.bis.Rechnung <> 99999999) then
    Lib_Sel:QVonBisI(var vQ451, 'Erl.K.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung);
  if (Sel.von.Datum <> 0.0.0) or (Sel.bis.Datum <> today) then
    Lib_Sel:QVonBisD(var vQ451, 'Erl.K.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
  if (Sel.Auf.Kundennr <> 0) then
    Lib_Sel:QInt(var vQ451, 'Erl.K.Kundennummer', '=', Sel.Auf.Kundennr);
  if (Sel.Auf.von.Projekt <> 0) or (Sel.Auf.bis.Projekt <> 99999999) then
    Lib_Sel:QVonBisI(var vQ451, 'Erl.K.Projektnr', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt);
  if (Sel.Auf.von.Nummer <> 0) or (Sel.Auf.bis.Nummer <> 99999999) then
    Lib_Sel:QVonBisI(var vQ451, 'Erl.K.Auftragsnr', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer);

  // Selektionsquery für 401
  vQ401 # '';
  if (Sel.Art.von.ArtNr <> '') or (Sel.Art.bis.ArtNr <> 'zzz') then
    Lib_Sel:QVonBisA(var vQ401, 'Auf.P.Artikelnr', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr);

  // Selektionsquery für 411
  vQ411 # '';
  if (Sel.Art.von.ArtNr <> '') or (Sel.Art.bis.ArtNr <> 'zzz') then
    Lib_Sel:QVonBisA(var vQ411, '"Auf~P.Artikelnr"', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr);

  if(vQ401 + vQ411 <> '') then begin
    if (vQ451 <> '') then
      vQ451 # vQ451 + ' AND ';
    vQ451 # vQ451 + ' ((LinkCount(AufPos) > 0) OR (LinkCount(AufPosA) > 0))';
  end;

  vSel # SelCreate(451, 1);
  vSel->SelAddLink('', 401, 451, 8, 'AufPos');
  vSel->SelAddLink('', 411, 451, 9, 'AufPosA');
  Erx # vSel->SelDefQuery('', vQ451);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPos', vQ401);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPosA', vQ411);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init('Sortierung', RecInfo(451, _recCount, vSel));

  FOR Erx # RecRead(451, vSel, _recFirst);
  LOOP Erx # RecRead(451, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(451, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    vSortKey # cnvAI(Erl.K.Kundennummer, _FmtNumLeadZero, 0, 9)
             + cnvAI(Erl.K.Projektnr, _FmtNumLeadZero, 0, 9)
             + cnvAI(Erl.K.Rechnungsnr, _FmtNumLeadZero, 0, 9);

    Sort_ItemAdd(vTree, vSortKey, 451, RecInfo(451, _RecId));
  END;
  SelClose(vSel);
  SelDelete(451, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset('Listengenerierung', CteInfo(vTree, _cteCount));
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Sel3      # LF_NewLine('SEL3');
  g_Header    # LF_NewLine('HEADER');
  g_Position  # LF_NewLine('POSITION');
  g_SumPrj    # LF_NewLine('SUMPRJ');
  g_SumKd     # LF_NewLine('SUMKD');
  g_SumGes    # LF_NewLine('SUMGES');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(false);    // Landscape

  g_BufLast451 # RecBufCreate(451);

  g_BufLast451 -> Erl.K.Projektnr # -1;
  g_BufLast451 -> Erl.K.Kundennummer # -1;

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    // Datensatz holen
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID);

    Auf_Data:Read(Erl.K.Auftragsnr, Erl.K.Auftragspos, false); // Auf.P. lesen

    if // Projektsumme
    ((
      ((g_BufLast451 -> Erl.K.Projektnr <> -1) and  (g_BufLast451 -> Erl.K.Projektnr <> Erl.K.Projektnr))
      or ((g_BufLast451 -> Erl.K.Kundennummer <> -1) and  (g_BufLast451 -> Erl.K.Kundennummer <> Erl.K.Kundennummer))
    )) then begin
      Prj.Nummer # g_BufLast451 -> Erl.K.Projektnr;
      Erx # RecRead(120, 1, 0);
      if(Erx > _rLocked)then
        RecBufClear(120);

      LF_Print(g_SumPrj);
      LF_Print(g_Empty);

      ResetSum(cSumPrjNetto);
    end;

    if // Kundensumme
    (
      ((g_BufLast451 -> Erl.K.Kundennummer <> -1) and  (g_BufLast451 -> Erl.K.Kundennummer <> Erl.K.Kundennummer))
    ) then begin
      LF_Print(g_SumKd);
      LF_Print(g_Empty);

      ResetSum(cSumKdNetto);
    end;

    LF_Print(g_Position);

    // Summierung
    AddSum(cSumPrjNetto, Erl.K.BetragW1);
    AddSum(cSumKdNetto, Erl.K.BetragW1);
    AddSum(cSumGesNetto, Erl.K.BetragW1);

    g_BufLast451 -> Erl.K.Projektnr # Erl.K.Projektnr;
    g_BufLast451 -> Erl.K.Kundennummer # Erl.K.Kundennummer;
  END;

  if(g_BufLast451 -> Erl.K.Projektnr <> -1) then begin
    LF_Print(g_SumPrj);
    LF_Print(g_Empty);
    LF_Print(g_SumKd);
    LF_Print(g_Empty);
  end;
  LF_Print(g_SumGes);

  RecBufDestroy(g_BufLast451);

  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Sel3);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Position);
  LF_FreeLine(g_SumPrj);
  LF_FreeLine(g_SumKd);
  LF_FreeLine(g_SumGes);
end;

//========================================================================