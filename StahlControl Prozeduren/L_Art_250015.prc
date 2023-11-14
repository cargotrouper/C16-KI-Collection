@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_250015
//                    OHNE E_R_G
//  Info        Artikel Absatz
//
//
//
//  17.09.2012  MS  Erstellung der Prozedur
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

define begin
  MonthDif(a, b)              : (((a -> vpYear * 12) + a -> vpMonth) - ((b -> vpYear * 12) + b -> vpMonth) + 1)
  DayDif(a, b)                : (cnvID(a) - cnvID(b))
  MonthFromDayDif(a)          : (a div 31) + 1
  //  vMonth  # MonthFromDayDif(DayDif(today, Mat.VK.Rechdatum));


  AddReMenge(a, b)            : if((a <= cMaxReMengeMonth) and (a > 0)) then begin g_MonatReMenge[a] # g_MonatReMenge[a] + b end
  ResetReMenge(a, b)          : i # a; WHILE(i <= b) DO BEGIN g_MonatReMenge[i] # 0.0; INC(i); END

  cMaxReMengeMonth            : 12
end;

local begin // Handles für die Zeilenelemente
  g_Empty           : int;
  g_Sel1            : int;
  g_Header          : int;
  g_Artikel         : int;
  g_Leselinie       : logic;

  g_MonatReMenge    : float[20];

  i                 : int;

  g_DateVon         : date;
  vJahrReMenge      : float;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Art.bis.ArtNr # 'zzz'

  List_FontSize           # 8;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.250015',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd(Translate('ARTIKELnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Qualität * Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Ringnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Werksnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Strukturnummer'));

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
  Erx   : int;
  vLine : int;
  vObf  : alpha(120);
  vDate : date;
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
      Adr.KundenNr # Sel.Adr.Von.KdNr;
      Erx # RecRead(100, 2, 0);
      if(Erx > _rMultiKey) or (Adr.KundenNr = 0) then
        RecBufClear(100);

      LF_Set(1, 'ArtNr.'                                            ,n , 0);
      LF_Set(2,  ' von: '                                           ,n , 0);
      LF_Set(3,  Sel.Art.von.ArtNr                                  ,n , 0);
      LF_Set(4,  ' bis: '                                           ,n , 0);
      LF_Set(5, Sel.Art.bis.ArtNr                                  ,n , 0);
      LF_Set(7, 'Kunde:'                                            ,n , 0);
      LF_Set(8, ZahlI(Sel.Adr.von.KdNr)                             ,y , _LF_Int);
      LF_Set(9, Adr.Stichwort                                      ,n , 0);

    end;


    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1] #  0.0;
      List_Spacing[ 2] # List_Spacing[ 1] + 20.0;
      List_Spacing[ 3] # List_Spacing[ 2] + 20.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 20.5;
      List_Spacing[ 5] # List_Spacing[ 4] + 20.5;
      List_Spacing[ 6] # List_Spacing[ 5] + 20.5;
      List_Spacing[ 7] # List_Spacing[ 6] + 20.5;
      List_Spacing[ 8] # List_Spacing[ 7] + 20.0;
      List_Spacing[ 9] # List_Spacing[ 8] + 20.5;
      List_Spacing[10] # List_Spacing[ 9] + 20.0;
      List_Spacing[11] # List_Spacing[10] + 20.0;
      List_Spacing[12] # List_Spacing[11] + 20.5;
      List_Spacing[13] # List_Spacing[12] + 20.0;
      List_Spacing[14] # List_Spacing[13] + 20.0;
      List_Spacing[15] # List_Spacing[14] + 20.0;
      List_Spacing[16] # List_Spacing[15] + 20.0;
      List_Spacing[17] # List_Spacing[16] + 20.0;
      List_Spacing[18] # List_Spacing[17] + 20.0;
      List_Spacing[19] # List_Spacing[18] + 20.0;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'ArtNr.'                  ,n , 0);
      LF_Set(2,  'MEH'                     ,n , 0);
      vDate # g_DateVon;
      //vDate -> vmMonthModify(1);
      LF_Set(3,  AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(4,  AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(5,  AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(6,  AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(7,  AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(8,  AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(9,  AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(10, AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(11, AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(12, AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(13, AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      vDate -> vmMonthModify(1);
      LF_Set(14, AInt(vDate -> vpMonth) + '/' + AInt(vDate -> vpYear), y, 0);
      LF_Set(15, 'SUMME'   ,y, 0);
      LF_Set(16, 'Auftragrest' ,y, 0);
      LF_Set(17, 'Reserviert'  ,y, 0);
      LF_Set(18, 'Verfügbar'   ,y, 0);
      LF_Set(19, 'Ist'         ,y, 0);
    end;

/*
 $Lb.Bestand->wpcaption    # ANum(Art.C.Bestand, Set.Stellen.Menge);
 $Lb.Reserviert->wpcaption # ANum(Art.C.Reserviert,Set.Stellen.Menge);
 $Lb.Bestellt->wpcaption   # ANum(Art.C.Bestellt, Set.Stellen.Menge);
 $Lb.Verfuegbar->wpcaption # ANum("Art.C.Verfügbar", Set.Stellen.Menge);
 $Lb.AufRest->wpcaption    # ANum("Art.C.OffeneAuf", Set.Stellen.Menge);
*/

    'ARTIKEL' : begin
      if (aPrint) then begin
        LF_Text( 3, cnvaf(g_MonatReMenge[12],0,0,7));
        LF_Text( 4, cnvaf(g_MonatReMenge[11],0,0,7));
        LF_Text( 5, cnvaf(g_MonatReMenge[10],0,0,7));
        LF_Text( 6, cnvaf(g_MonatReMenge[9],0,0,7));
        LF_Text( 7, cnvaf(g_MonatReMenge[8],0,0,7));
        LF_Text( 8, cnvaf(g_MonatReMenge[7],0,0,7));
        LF_Text( 9, cnvaf(g_MonatReMenge[6],0,0,7));
        LF_Text(10, cnvaf(g_MonatReMenge[5],0,0,7));
        LF_Text(11, cnvaf(g_MonatReMenge[4],0,0,7));
        LF_Text(12, cnvaf(g_MonatReMenge[3],0,0,7));
        LF_Text(13, cnvaf(g_MonatReMenge[2],0,0,7));
        LF_Text(14, cnvaf(g_MonatReMenge[1],0,0,7));

        LF_Text(15, cnvaf(vJahrReMenge,0,0,7));
        vJahrReMenge # 0.0;

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

      LF_Set(1,  '@Art.Nummer'  ,n , 0);
      LF_Set(2,  '@Art.MEH'  ,n , 0);
      LF_Set(3,  '#Monat'  ,y , _LF_Num, 0);
      LF_Set(4,  '#Monat'  ,y , _LF_Num, 0);
      LF_Set(5,  '#Monat'  ,y , _LF_Num, 0);
      LF_Set(6,  '#Monat'  ,y , _LF_Num, 0);
      LF_Set(7,  '#Monat'  ,y , _LF_Num, 0);
      LF_Set(8,  '#Monat'  ,y , _LF_Num, 0);
      LF_Set(9,  '#Monat'  ,y , _LF_Num, 0);
      LF_Set(10, '#Monat'  ,y , _LF_Num, 0);
      LF_Set(11, '#Monat'  ,y , _LF_Num, 0);
      LF_Set(12, '#Monat'  ,y , _LF_Num, 0);
      LF_Set(13, '#Monat'  ,y , _LF_Num, 0);
      LF_Set(14, '#Monat'  ,y , _LF_Num, 0);

      LF_Set(15, '#Jahr'  ,y , _LF_Num, 0);

      LF_Set(16, '@Art.C.OffeneAuf'  ,y , _LF_Num, 0);
      LF_Set(17, '@Art.C.Reserviert'  ,y , _LF_Num, 0);
      LF_Set(18, '@Art.C.Verfügbar'  ,y , _LF_Num, 0);
      LF_Set(19, '@Art.C.Bestand'  ,y , _LF_Num, 0);



    end;


    'SUMME1' : begin

      if (aPrint) then begin
        LF_Sum(11 ,1, 0);
        LF_Sum(13 ,3, Set.Stellen.Gewicht);
        LF_Sum(17 ,4, 2);
        RETURN;
      end;

      // Instanzieren...
      List_Spacing[11]  # List_Spacing[ 10];
      //List_Spacing[12]  # List_Spacing[ 11] + 12.5;
      List_Spacing[13]  # List_Spacing[ 12];
      //List_Spacing[14]  # List_Spacing[ 13] + 17.0;
      //List_Spacing[15]  # List_Spacing[ 14] + 20.0;
      List_Spacing[16]  # List_Spacing[ 15];

      LF_Format(_LF_Overline);
      LF_Set(11, 'SUM1'                 ,y , _LF_INT);
      LF_Set(13, 'SUM3'                 ,y , _LF_NUM, Set.Stellen.Gewicht);
      LF_Set(17, 'SUM4'                 ,y , _LF_WAE);
    end;


    'SUMME2' : begin

      if (aPrint) then begin
        LF_Sum(12 ,2, Set.Stellen.Gewicht);
        RETURN;
      end;

      // Instanzieren...
      List_Spacing[11]  # List_Spacing[ 10] + 21.0;
      List_Spacing[12]  # List_Spacing[ 11] + 12.5;
      List_Spacing[13]  # List_Spacing[ 12] + 17.0;
      List_Spacing[14]  # List_Spacing[ 13] + 17.0;
      List_Spacing[15]  # List_Spacing[ 14] + 20.0;
      List_Spacing[16]  # List_Spacing[ 15] + 20.0;
      List_Spacing[12]  # List_Spacing[ 11];

      LF_Format(_LF_Overline);
      LF_set(12, 'SUM2'                 ,y , _LF_NUM, Set.Stellen.Gewicht);
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
  vProgress   : handle;
  vDate       : date;
  vMonthDif   : int;
  vBufLast250 : int;
  vBuf250     : int;
end;
begin
  g_DateVon # today;
  g_DateVon -> vmMonthModify(-11);
  g_DateVon -> vpDay # 1;

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // BESTAND-Selektion
  Lib_Sel:QAlpha(var vQ404, 'Auf.A.ArtikelNr', '!=', '');
  if (Sel.Art.von.ArtNr <> '') or (Sel.Art.bis.ArtNr <> 'zzz') then
    Lib_Sel:QVonBisA(var vQ404, 'Auf.A.ArtikelNr', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr);

  Lib_Sel:QDate(var vQ404, 'Auf.A.Rechnungsdatum', '>=', g_DateVon);

  if (Sel.Adr.von.KdNr <> 0) then begin
    Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Sel.Adr.von.KdNr);
    Lib_Sel:QInt(var vQ411, '"Auf~P.Kundennr"', '=', Sel.Adr.von.KdNr);

  end;

  if (Sel.Art.von.Wgr <> 0) or (Sel.Art.bis.Wgr <> 0) then begin
    Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Warengruppe', Sel.Art.von.Wgr, Sel.Art.bis.Wgr);
    Lib_Sel:QVonBisI(var vQ411, 'Auf~P.Warengruppe', Sel.Art.von.Wgr, Sel.Art.bis.Wgr);
  end;

  if(vQ401 <> '') or (vQ411 <> '') then
    Lib_Strings:Append(var vQ404, '((LinkCount(AufPos) > 0) OR (LinkCount(AufPosA) > 0))', ' AND ');

  // Selektion starten...
  vSel # SelCreate(404, 1);
  vSel->SelAddLink('', 401, 404, 1, 'AufPos');
  vSel->SelAddLink('', 411, 404, 7, 'AufPosA');
  Erx # vSel -> SelDefQuery('', vQ404);
  if(Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPos',    vQ401);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPosA',   vQ411);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 404, _recCount, vSel ) );

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

    vSortKey # StrFmt(Art.Nummer, 20, _StrEnd)
             + cnvAI(cnvID(Auf.A.Rechnungsdatum), _FmtNumNoGroup | _FmtNumLeadZero, 0, 5)
    Sort_ItemAdd(vTree, vSortKey, 404, RecInfo(404, _RecId));
  END;
  SelClose(vSel);
  SelDelete(404, vSelName);
  vSel # 0;


  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Header    # LF_NewLine('HEADER');
  g_Artikel   # LF_NewLine('ARTIKEL');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape


  vItem # Sort_ItemFirst(vTree)
  if(vItem <> 0) then begin
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen
    Erx # RecLink(250, 404, 3, _recFirst); // Artikel holen
    if(Erx > _rLocked) then
      RecBufClear(250);
    vBufLast250 # RekSave(250);
  end;


  FOR   vItem # Sort_ItemFirst(vTree)
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
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

    if(Art.Nummer <> vBufLast250 -> Art.Nummer) then begin
      vBuf250 # RekSave(250);
      RecBufCopy(vBufLast250, 250);
      Art.C.ArtikelNr   # Art.Nummer;
      if (Art.Nummer <> '') then
        Art_Data:ReadCharge();
      LF_Print(g_Artikel);
      ResetReMenge(1, 12)
      RekRestore(vBuf250);
    end;

    vDate     # today;
    vMonthDif # MonthDif(vDate, Auf.A.Rechnungsdatum); // Differenz von + 1 Monat da Arrays bei 1 anfangen
//  debug(cnvAD(today) + '          /          ' + cnvAD(Auf.A.Rechnungsdatum) + '          /          ' + AInt(vMonthDif));

    AddReMenge(vMonthDif, Auf.A.Menge.Preis);

    vJahrReMenge # vJahrReMenge + Auf.A.Menge.Preis;

    vBufLast250 # RekSave(250);
  END;

  LF_Print(g_Artikel);

  vJahrReMenge # 0.0;
  RecBufDestroy(vBufLast250);

  Sort_KillList(vTree); // Löschen der Liste

  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Artikel);
end;

//========================================================================