@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450019
//                    OHNE E_R_G
//  Info        Artikelverkauf an Kd.
//
//
//
//  27.03.2012  MS  Erstellung der Prozedur
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
  g_KdSum      : int;
  g_GesSum     : int;
  g_Leselinie  : logic;
  g_BufLast401 : int;
end;

define begin
  cZwSumUmsatz  : 1
  cZwSumDB      : 2
  cZwSumMenge   : 3

  cGesSumUmsatz : 10
  cGesSumDB     : 11
  cGesSumMenge  : 12

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

  List_FontSize     # 8;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450019',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd(Translate('Artikelnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Artikelgruppe * Artikelnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Warengruppe * Artikelnummer'));
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
      List_Spacing[ 2]  # List_Spacing[ 1]  + 45.0; //  'Kunde'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 20.0; //  'Re.-Datum'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 20.0; //  'Rechnung'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 25.0; //  'Artikelnr.'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 25.0; //  'Stichwort'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 20.0; //  'Menge'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 10.0; //  'PEH'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 10.0; //  'MEH'
      List_Spacing[10]  # List_Spacing[ 9]  + 20.0; //  'Gewicht'
      List_Spacing[11]  # List_Spacing[ 10] + 20.0; //  'VK E-Preis'
      List_Spacing[12]  # List_Spacing[ 11] + 20.0; //  'Umsatz €'
      List_Spacing[13]  # List_Spacing[ 12] + 35.0; //  'Deckungsbeitrag €'
      List_Spacing[14]  # List_Spacing[ 13] + 30.0; //
      List_Spacing[15]  # List_Spacing[ 14] + 30.0; //
      List_Spacing[16]  # List_Spacing[ 15] + 30.0; //
      List_Spacing[17]  # List_Spacing[ 16] + 30.0; //
      List_Spacing[18]  # List_Spacing[ 17] + 30.0; //


      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Kunde'                                  ,n , 0);
      LF_Set(2,  'Re.-Datum'                              ,n , 0);
      LF_Set(3,  'Rechnung'                               ,y , 0);
      LF_Set(4,  'Artikelnr.'                             ,n , 0);
      LF_Set(5,  'Stichwort'                              ,n , 0);
      LF_Set(6,  'Menge'                                  ,y , 0);
      LF_Set(7,  'PEH'                                    ,n , 0);
      LF_Set(8,  'MEH'                                    ,n , 0);
      LF_Set(9,  'Gewicht'                                ,y , 0);
      LF_Set(10, 'VK E-Preis'                             ,y , 0);
      LF_Set(11, 'Umsatz €'                               ,y , 0);
      LF_Set(12, 'Deckungsbeitrag €'                      ,y , 0);
    end;


    'ARTIKEL' : begin
      if (aPrint) then begin
        /*
        LF_Text(1, g_BufLast404 -> Auf.A.Artikelnr);
        LF_Text(2, g_BufLast250 -> Art.Stichwort);
        LF_Sum(3, cArtSumMng, Set.Stellen.Menge);
        LF_Text(4, g_BufLast404 -> Auf.A.MEH);
        LF_Sum(5, cArtSumGew, Set.Stellen.Gewicht);
        LF_Sum(6, cArtSumUmsatz, 2);
        LF_Sum(7, cArtSumDB, 2);
        */

        if(g_BufLast401 -> Auf.P.KundenSW <> Auf.P.KundenSW) then
          LF_Text(1, Auf.P.KundenSW);
        else
          LF_Text(1, '');

        LF_Text(12, ANum(Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1, 2));
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
      LF_Set(1, '#Auf.P.KundenSW'          ,n , 0);
      LF_Set(2, '@Auf.A.Rechnungsdatum'    ,n , _LF_Date);
      LF_Set(3, '@Auf.A.Rechnungsnr'       ,y , _LF_IntNG);
      LF_Set(4, '@Auf.A.Artikelnr'         ,n , 0);
      LF_Set(5, '@Art.Stichwort'           ,n , 0);
      LF_Set(6, '@Auf.A.Menge'             ,y , _LF_Num, Set.Stellen.Menge);
      LF_Set(7, '@Auf.A.MEH.Preis'         ,n , 0);
      LF_Set(8, '@Auf.A.MEH'               ,n , 0);
      LF_Set(9, '@Auf.A.Gewicht'           ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(10, '@Auf.P.Einzelpreis'       ,y , _LF_Wae, 2);
      LF_Set(11, '@Auf.A.RechPreisW1'       ,y , _LF_Wae, 2);
      LF_Set(12, '#DB'                     ,y , _LF_Wae, 2);
    end;

   'KDSUM' : begin
      if (aPrint) then begin
        LF_Sum(6,  cZWSumMenge, 2);
        LF_Sum(11, cZWSumUmsatz, 2);
        LF_Sum(12, cZWSumDB, 2);
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
      LF_Set(11, '#'       ,y , _LF_Wae, 2);
      LF_Set(12, '#'       ,y , _LF_Wae, 2);
    end;


    'GESSUM' : begin
      if (aPrint) then begin
        LF_Sum(6, cGesSumMenge, 2);
        LF_Sum(11, cGesSumUmsatz, 2);
        LF_Sum(12, cGesSumDB, 2);
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
      LF_Set(11, '#'       ,y , _LF_Wae, 2);
      LF_Set(12, '#'       ,y , _LF_Wae, 2);
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

  FOR Erx # RecRead(404, vSel, _recFirst);
  LOOP Erx # RecRead(404, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    if (!vProgress->Lib_Progress:Step()) then begin // Progress
      SelClose(vSel);
      SelDelete(404, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    Erx # RecLink(250, 404, 3, _recFirst); // Artikel holen
    if(Erx > _rLocked) then
      RecBufClear(250);

    Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, true);

    vSortKey # StrFmt(Auf.P.KundenSW, 20, _StrEnd)
             + cnvAI(cnvID(Auf.A.Rechnungsdatum), _FmtNumNoGroup | _FmtNumLeadZero, 0, 5)
             + StrFmt(Art.Nummer, 20, _StrEnd);


/*
    if (aSort=1) then   vSortKey # StrFmt(Art.Nummer, 20, _StrEnd);
    if (aSort=2) then   vSortKey # cnvAI(Art.Artikelgruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 5)
                                 + StrFmt(Art.Nummer, 20, _StrEnd);
    if (aSort=3) then   vSortKey # cnvAI(Auf.P.Warengruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 7)
                                 + StrFmt(Art.Nummer, 20, _StrEnd);
*/
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
  g_KdSum     # LF_NewLine('KDSUM');
  g_GesSum    # LF_NewLine('GESSUM');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape


  vItem # Sort_ItemFirst(vTree)
  if(vItem <> 0) then
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen
  Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, true);
  g_BufLast401 # RekSave(401);
  g_BufLast401 -> Auf.P.KundenSW # '###';


  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) DO BEGIN
    if (!vProgress->Lib_Progress:Step()) then begin // Progress
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen

    Erx # RecLink(250, 404, 3, _recFirst); // Artikel holen
    if(Erx > _rLocked) then
      RecBufClear(250);
    Erx # RecLink(826, 250, 11, _recFirst); // Artikelgruppe holen
    if(Erx > _rLocked) then
      RecBufClear(826);
    Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, true);
    Erx # RecLink(819, 401, 1, _recFirst); // Warengruppe holen
    if(Erx > _rLocked) then
      RecBufClear(819);


    if((g_BufLast401 -> Auf.P.KundenNr <> Auf.P.KundenNr) and (g_BufLast401 -> Auf.P.KundenSW <> '###')) then begin // anderer Kd.?
      LF_Print(g_KdSum);
      LF_Print(g_Empty);
      ResetSum(cZwSumUmsatz);
      ResetSum(cZwSumDB);
      ResetSum(cZwSumMenge);
    end;

    LF_Print(g_Artikel);

    AddSum(cZwSumUmsatz, Auf.A.RechPreisW1);
    AddSum(cZwSumDB    , Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1);
    AddSum(cZwSumMenge , Auf.A.Menge);

    AddSum(cGesSumUmsatz, Auf.A.RechPreisW1);
    AddSum(cGesSumDB    , Auf.A.RechPreisW1 - Auf.A.EKPreisSummeW1);
    AddSum(cGesSumMenge , Auf.A.Menge);

    RecBufCopy(401, g_BufLast401);
  END;

  LF_Print(g_KdSum);
  LF_Print(g_GesSum);

  Sort_KillList(vTree); // Löschen der Liste

  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Artikel);
  LF_FreeLine(g_KdSum);
  LF_FreeLine(g_GesSum);
end;

//========================================================================