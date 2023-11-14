@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450018
//                    OHNE E_R_G
//  Info        Artikelumsatz Kunde verdichtet
//
//
//
//  09.08.2011  MS  Erstellung der Prozedur
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
  g_Empty      : int;
  g_Sel1       : int;
  g_Sel2       : int;
  g_Header     : int;
  g_Artikel    : int;
  g_ArtGrpK    : int;
  g_WgrK       : int;
  g_ArtGrpSum  : int;
  g_WgrSum     : int;
  g_GesSum     : int;
  g_Leselinie  : logic;

  g_BufLast250 : int;
  g_BufLast404 : int;
  gLastWgr     : int;
end;

define begin
  cZwSumUmsatz  : 1
  cZwSumDB      : 2

  cGesSumUmsatz : 10
  cGesSumDB     : 11

  cArtSumMng    : 20
  cArtSumUmsatz : 21
  cArtSumDB     : 22
  cArtSumGew    : 23
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Art.bis.ArtNr # 'zzz'
  Sel.Art.bis.WGr   # 9999
  Sel.Art.bis.ArtGr # 9999
  Sel.bis.Datum     # today;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450018',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd(Translate('Artikelnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Artikelgruppe * Artikelnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Warengruppe * Artikelnummer'));
  vHdl2->wpcurrentint#1;
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
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  vLine : int;
  vObf  : alpha(120);
  vDB   : float;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin

      if (aPrint) then RETURN;
/*
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
*/
      // Instanzieren...
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   24.0;
      List_Spacing[ 3]  #   26.0;
      List_Spacing[ 4]  #   34.0;
      List_Spacing[ 5]  #   51.0;
      List_Spacing[ 6]  #   60.0;
      List_Spacing[ 7]  #   93.0;
      List_Spacing[ 8]  #  123.0;
      List_Spacing[ 9]  #  125.0;
      List_Spacing[10]  #  133.0;
      List_Spacing[11]  #  153.0;
      List_Spacing[12]  #  160.0;
      List_Spacing[13]  #  183.0;
      List_Spacing[14]  #  203.0;
      List_Spacing[15]  #  205.0;
      List_Spacing[16]  #  213.0;
      List_Spacing[17]  #  233.0;
      List_Spacing[18]  #  240.0;
      List_Spacing[19]  #  263.0;

      LF_Set(1, 'Artikelnr.'                                           ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      if (Sel.Art.von.ArtNr <> '') then
        LF_Set(4,  Sel.Art.von.ArtNr                           ,n , 0);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      if (Sel.Art.bis.ArtNr <> '') then
        LF_Set(6,  Sel.Art.bis.ArtNr                           ,y , 0);
      LF_Set(7, 'Artikelgruppe'                                            ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      if (Sel.Art.von.ArtGr <> 0) then
        LF_Set(10, ZahlI(Sel.Art.von.ArtGr)                        ,n , _LF_INT);
      LF_Set(11, ' bis: '                                           ,n , 0);
      if (Sel.Art.bis.ArtGr <> 0) then
        LF_Set(12,  ZahlI(Sel.Art.bis.ArtGr)                       ,y , _LF_INT);
      LF_Set(13, 'Kunde'                                             ,n , 0);
      LF_Set(14, ': '                                               ,n , 0);
      LF_Set(16, AInt(Sel.Adr.von.KdNr)     ,n , 0);
    end;


    'SEL2' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Warengruppe'                                        ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      LF_Set(4, ZahlI(Sel.Art.von.WGr)                                ,n , _LF_INT);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      LF_Set(6, ZahlI(Sel.Art.bis.WGr)                               ,n , _LF_INT);
      LF_Set(7, 'Rechnungsdatum'                                     ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      if (Sel.von.Datum <> 00.00.0000) then
        LF_Set(10, DatS(Sel.von.Datum)                        ,n , _LF_Date);
      LF_Set(11, ' bis: '                                           ,n , 0);
      if (Sel.bis.Datum <> 00.00.0000) then
        LF_Set(12,  DatS(Sel.bis.Datum)                       ,y , _LF_Date);
    end;






    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 60.0; //  'Artikelnr.'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 60.0; //  'Stichwort'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 30.0; //  'Menge'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 30.0; //  'MEH'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 30.0; //  'Gewicht'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 30.0; //  'Umsatz €'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 40.0; //  'Deckungsbeitrag €'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 30.0; //
      List_Spacing[10]  # List_Spacing[ 9]  + 30.0; //
      List_Spacing[11]  # List_Spacing[ 10] + 30.0; //
      List_Spacing[12]  # List_Spacing[ 11] + 30.0; //
      List_Spacing[13]  # List_Spacing[ 12] + 30.0; //
      List_Spacing[14]  # List_Spacing[ 13] + 30.0; //
      List_Spacing[15]  # List_Spacing[ 14] + 30.0; //
      List_Spacing[16]  # List_Spacing[ 15] + 30.0; //
      List_Spacing[17]  # List_Spacing[ 16] + 30.0; //
      List_Spacing[18]  # List_Spacing[ 17] + 30.0; //


      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1, 'Artikelnr.'                             ,n , 0);
      LF_Set(2, 'Stichwort'                              ,n , 0);
      LF_Set(3, 'Menge'                                  ,y , 0);
      LF_Set(4, 'MEH'                                    ,n , 0);
      LF_Set(5, 'Gewicht'                                ,y , 0);
      LF_Set(6, 'Umsatz €'                               ,y , 0);
      LF_Set(7, 'Deckungsbeitrag €'                      ,y , 0);

    end;


    'ARTIKEL' : begin
      if (aPrint) then begin
        LF_Text(1, g_BufLast404 -> Auf.A.Artikelnr);
        LF_Text(2, g_BufLast250 -> Art.Stichwort);
        LF_Sum(3, cArtSumMng, Set.Stellen.Menge);
        LF_Text(4, g_BufLast404 -> Auf.A.MEH);
        LF_Sum(5, cArtSumGew, Set.Stellen.Gewicht);
        LF_Sum(6, cArtSumUmsatz, 2);
        LF_Sum(7, cArtSumDB, 2);

        if(List_XML = false) and (false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        RETURN;

      end;

      // Instanzieren...
      LF_Set(1, '#Auf.A.Artikelnr'         ,n , 0);
      LF_Set(2, '#Art.Stichwort'           ,n , 0);
      LF_Set(3, '#Auf.A.Menge'             ,y , _LF_Num, Set.Stellen.Menge);
      LF_Set(4, '#Auf.A.MEH'               ,n , 0);
      LF_Set(5, '#Auf.A.Gewicht'           ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(6, '#Auf.A.RechPreisW1'       ,y , _LF_Wae, 2);
      LF_Set(7, '#DB'                      ,y , _LF_Wae, 2);
    end;

    'ARTIKELGRPKOPF' : begin
      if (aPrint) then begin
        RETURN;
      end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 120.0; //

      LF_Format(_LF_UnderLine + _LF_Bold);

      // Instanzieren...
      LF_Set(1, '@AGr.Bezeichnung.L1'         ,n , 0);
      /*
      LF_Set(2, '@Art.Stichwort'           ,n , 0);
      LF_Set(3, '@Auf.A.Menge'             ,y , _LF_Num, Set.Stellen.Menge);
      LF_Set(4, '@Auf.A.MEH'               ,n , 0);
      LF_Set(5, '@Auf.A.Gewicht'           ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(6, '@Auf.A.RechPreisW1'       ,y , _LF_Wae, 2);
      LF_Set(7, '#DB'                      ,y , _LF_Wae, 2);
      */
    end;

    'WGRKOPF' : begin
      if (aPrint) then begin
        RETURN;
      end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 120.0; //

      LF_Format(_LF_UnderLine + _LF_Bold);

      // Instanzieren...
      LF_Set(1, '@Wgr.Bezeichnung.L1'         ,n , 0);
      /*
      LF_Set(2, '@Art.Stichwort'           ,n , 0);
      LF_Set(3, '@Auf.A.Menge'             ,y , _LF_Num, Set.Stellen.Menge);
      LF_Set(4, '@Auf.A.MEH'               ,n , 0);
      LF_Set(5, '@Auf.A.Gewicht'           ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(6, '@Auf.A.RechPreisW1'       ,y , _LF_Wae, 2);
      LF_Set(7, '#DB'                      ,y , _LF_Wae, 2);
      */
    end;

    'WGRSUM' : begin
      if (aPrint) then begin
        LF_Sum(6, cZwSumUmsatz, 2);
        LF_Sum(7, cZwSumDB, 2);
        RETURN;
      end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 120.0; //

      LF_Format(_LF_OverLine + _LF_Bold);

      // Instanzieren...
      LF_Set(1, ''         ,n , 0);
      /*
      LF_Set(2, '@Art.Stichwort'           ,n , 0);
      LF_Set(3, '@Auf.A.Menge'             ,y , _LF_Num, Set.Stellen.Menge);
      LF_Set(4, '@Auf.A.MEH'               ,n , 0);
      LF_Set(5, '@Auf.A.Gewicht'           ,y , _LF_Num, Set.Stellen.Gewicht);
      */
      LF_Set(6, '#'       ,y , _LF_Wae, 2);
      LF_Set(7, '#'                      ,y , _LF_Wae, 2);
    end;

    'ARTGRPSUM' : begin
      if (aPrint) then begin
        LF_Sum(6, cZwSumUmsatz, 2);
        LF_Sum(7, cZwSumDB, 2);
        RETURN;
      end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 120.0; //

      LF_Format(_LF_OverLine + _LF_Bold);

      // Instanzieren...
      LF_Set(1, ''         ,n , 0);
      /*
      LF_Set(2, '@Art.Stichwort'           ,n , 0);
      LF_Set(3, '@Auf.A.Menge'             ,y , _LF_Num, Set.Stellen.Menge);
      LF_Set(4, '@Auf.A.MEH'               ,n , 0);
      LF_Set(5, '@Auf.A.Gewicht'           ,y , _LF_Num, Set.Stellen.Gewicht);
        */
      LF_Set(6, '#'       ,y , _LF_Wae, 2);
      LF_Set(7, '#'                      ,y , _LF_Wae, 2);

    end;

    'GESSUM' : begin
      if (aPrint) then begin
        LF_Sum(6, cGesSumUmsatz, 2);
        LF_Sum(7, cGesSumDB, 2);
        RETURN;
      end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 120.0; //

      LF_Format(_LF_OverLine + _LF_Bold);

      // Instanzieren...
      //LF_Set(1, ''         ,n , 0);
      /*
      LF_Set(2, '@Art.Stichwort'           ,n , 0);
      LF_Set(3, '@Auf.A.Menge'             ,y , _LF_Num, Set.Stellen.Menge);
      LF_Set(4, '@Auf.A.MEH'               ,n , 0);
      LF_Set(5, '@Auf.A.Gewicht'           ,y , _LF_Num, Set.Stellen.Gewicht);
        */
      LF_Set(6, '#'       ,y , _LF_Wae, 2);
      LF_Set(7, '#'                      ,y , _LF_Wae, 2);

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
  vQ404       : alpha(4000);
  vQ401       : alpha(4000);
  vQ411       : alpha(4000);
  vQ400       : alpha(4000);
  vQ410       : alpha(4000);
  vQ250       : alpha(4000);
  vProgress   : handle;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery


  vQ404 # ''; // Auftrag-Aktionen
  Lib_Sel:QVonBisD(var vQ404 , 'Auf.A.Rechnungsdatum', Sel.von.Datum , Sel.bis.Datum);
  Lib_Sel:QInt(var vQ404, 'Auf.A.Rechnungsnr', '!=', 0);
  Lib_Sel:QAlpha(var vQ404, 'Auf.A.ArtikelNr', '!=', '');
  if (Sel.Art.von.ArtNr <> '') or (Sel.Art.bis.ArtNr <> 'zzz') then
    Lib_Sel:QVonBisA(var vQ404, 'Auf.A.ArtikelNr', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr);


  vQ401 # ''; // Auftrag-Pos (+Ablage)
  vQ411 # '';
  if (Sel.Art.von.WGr <> 0) or (Sel.Art.bis.WGr <> 9999) then begin
    Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Warengruppe', Sel.Art.von.WGr, Sel.Art.bis.WGr);
    Lib_Sel:QVonBisI(var vQ411, '"Auf~P.Warengruppe"', Sel.Art.von.WGr, Sel.Art.bis.WGr);
  end;
  if (Sel.Adr.von.KdNr <> 0) then begin
    Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Sel.Adr.von.KdNr);
    Lib_Sel:QInt(var vQ411, '"Auf~P.Kundennr"', '=', Sel.Adr.von.KdNr);
  end;


  vQ250 # ''; // Artikel
  if (Sel.Art.von.ArtGr <> 0) or (Sel.Art.bis.ArtGr <> 9999) then
    Lib_Sel:QVonBisI(var vQ250, 'Art.Artikelgruppe', Sel.Art.von.ArtGr, Sel.Art.bis.ArtGr);

  if(vQ250 <> '') then
    Lib_Strings:Append(var vQ404, '(LinkCount(Artikel) > 0)', ' AND ');

  if(vQ401 <> '') or (vQ411 <> '') then
    Lib_Strings:Append(var vQ404, '((LinkCount(AufPos) > 0) OR (LinkCount(AufPosA) > 0))', ' AND ');


  // Selektion starten...
  vSel # SelCreate(404, 1);
  vSel->SelAddLink('', 250, 404, 3, 'Artikel');
  vSel->SelAddLink('', 401, 404, 1, 'AufPos');
  vSel->SelAddLink('', 411, 404, 7, 'AufPosA');
  Erx # vSel -> SelDefQuery('', vQ404);
  if(Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Artikel',    vQ250);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPos',    vQ401);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPosA',   vQ411);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 5);  // nach Artikel sortiert

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  vProgress # Lib_Progress:Init('Sortierung', RecInfo(404, _recCount, vSel));

  FOR Erx # RecRead(404,vSel, _recFirst);
  LOOP Erx # RecRead(404,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(404, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    Erx # RecLink(250, 404, 3, _recFirst); // Artikel holen
    if(Erx > _rLocked) then
      RecBufClear(250);

    Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, true);



    if (aSort=1) then   vSortKey # StrFmt(Art.Nummer, 20, _StrEnd);
    if (aSort=2) then   vSortKey # cnvAI(Art.Artikelgruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 5)
                                 + StrFmt(Art.Nummer, 20, _StrEnd);
    if (aSort=3) then   vSortKey # cnvAI(Auf.P.Warengruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 7)
                                 + StrFmt(Art.Nummer, 20, _StrEnd);

    Sort_ItemAdd(vTree, vSortKey, 404, RecInfo(404, _RecId));
  END;
  SelClose(vSel);
  SelDelete(404, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset('Listengenerierung', CteInfo(vTree, _cteCount));
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Header    # LF_NewLine('HEADER');
  g_Artikel   # LF_NewLine('ARTIKEL');
  g_ArtGrpK   # LF_NewLine('ARTIKELGRPKOPF');
  g_WgrK      # LF_NewLine('WGRKOPF');
  g_ArtGrpSum # LF_NewLine('ARTGRPSUM');
  g_WgrSum    # LF_NewLine('WGRSUM');
  g_GesSum    # LF_NewLine('GESSUM');


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(y);    // Landscape


  gLastWgr    # 0;
  g_BufLast250 # RecBufCreate(250);
  g_BufLast250 -> Art.Nummer # '###';

  g_BufLast404 # RecBufCreate(404);
  g_BufLast404 -> Auf.A.Nummer # -1;

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    // Datensatz holen
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID);

    Erx # RecLink(250, 404, 3, _recFirst); // Artikel holen
    if(Erx > _rLocked) then
      RecBufClear(250);
    Erx # RecLink(826, 250, 11, _recFirst); // Artikelgruppe holen
    if(Erx > _rLocked) then
      RecBufClear(826);
    Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, true);
    Erx # RecLink(819, 401, 1, _recFirst);
    if(Erx > _rLocked) then
      RecBufClear(819);

    if(g_BufLast250 -> Art.Nummer <> '###') then begin
      if(g_BufLast250 -> Art.Nummer <> Art.Nummer)
      or ((g_BufLast250 -> Art.Artikelgruppe <> Art.Artikelgruppe) and (aSort = 2))
      or ((gLastWgr  <> Auf.P.Warengruppe) and (aSort = 3)) then begin
        LF_Print(g_Artikel);
        ResetSum(cArtSumMng   );
        ResetSum(cArtSumUmsatz);
        ResetSum(cArtSumDB    );
        ResetSum(cArtSumGew   );

      end;

      if ((g_BufLast250 -> Art.Artikelgruppe <> Art.Artikelgruppe) and (aSort = 2)) then begin
        LF_Print(g_ArtGrpSum);
        ResetSum(cZwSumUmsatz);
        ResetSum(cZwSumDB    );
        LF_Print(g_Empty);
        LF_Print(g_ArtGrpK);
      end
      else if((gLastWgr  <> Auf.P.Warengruppe) and (aSort = 3)) then begin
        LF_Print(g_WgrSum);
        ResetSum(cZwSumUmsatz);
        ResetSum(cZwSumDB    );
        LF_Print(g_Empty);
        LF_Print(g_WgrK);
      end;
    end
    else begin
      if(aSort = 2) then
        LF_Print(g_ArtGrpK);
      else if (aSort = 3) then
        LF_Print(g_WgrK);
    end;

    AddSum(cArtSumMng    , Auf.A.Menge);
    AddSum(cArtSumGew    , Auf.A.Gewicht);
    AddSum(cArtSumUmsatz , Auf.A.RechPreisW1);
    AddSum(cArtSumDB     , Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1);

    AddSum(cZwSumUmsatz, Auf.A.RechPreisW1);
    AddSum(cZwSumDB    , Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1);
    AddSum(cGesSumUmsatz, Auf.A.RechPreisW1);
    AddSum(cGesSumDB    , Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1);

    gLastWgr    # Auf.P.Warengruppe;
    RecBufCopy(250, g_BufLast250);
    RecBufCopy(404, g_BufLast404);
  END;

  if(g_BufLast250 -> Art.Nummer <> '###') then begin
    LF_Print(g_Artikel);
    ResetSum(cArtSumMng   );
    ResetSum(cArtSumUmsatz);
    ResetSum(cArtSumDB    );
    ResetSum(cArtSumGew   );
    if(aSort = 2) then begin
      LF_Print(g_ArtGrpSum);
      ResetSum(cZwSumUmsatz);
      ResetSum(cZwSumDB    );
      LF_Print(g_Empty);
    end
    else if(aSort = 3) then begin
      LF_Print(g_WgrSum);
      ResetSum(cZwSumUmsatz);
      ResetSum(cZwSumDB    );
      LF_Print(g_Empty);
    end;
  end;

  LF_Print(g_GesSum);

  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Artikel);
  LF_FreeLine(g_ArtGrpK);
  LF_FreeLine(g_WgrK);
  LF_FreeLine(g_ArtGrpSum);
  LF_FreeLine(g_WgrSum);
  LF_FreeLine(g_GesSum);

end;

//========================================================================