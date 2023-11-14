@A+
//===== Business-Control =================================================
//
//  Prozedur    L_OfP_460007
//                    OHNE E_R_G
//  Info        OP Liste mit Zahlungseingaengen
//
//
//
//  18.11.2010  MS  Erstellung der Prozedur
//  2022-06-28  AH  ERX
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
  g_Empty     : int;
  g_Sel1      : int;
  g_Header    : int;
  g_Position  : int;
  g_SumGesamt    : int;
  g_Leselinie : logic;
end;

define begin
  cSumGesSaldo : 1
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.bis.Datum # today;
  "Sel.Fin.GelöschteYN" # true;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.460007',here+':AusSel');
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
  Erx   : int;
  vLine : int;
  vObf  : alpha(120);
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  #  List_Spacing[ 1] + 20.0; // 'Re. Datum'
      List_Spacing[ 3]  #  List_Spacing[ 2] + 3.0;  //  ': '
      List_Spacing[ 4]  #  List_Spacing[ 3] + 20.0; //  ' von: '
      List_Spacing[ 5]  #  List_Spacing[ 4] + 20.0; //  DatS(Sel.Von.Datum)
      List_Spacing[ 6]  #  List_Spacing[ 5] + 20.0; //  ' bis: '
      List_Spacing[ 7]  #  List_Spacing[ 6] + 25.0; //  DatS(Sel.bis.Datum)
      List_Spacing[ 8]  #  List_Spacing[ 7] + 15.0; //  'Kunde'
      List_Spacing[ 9]  #  List_Spacing[ 8] + 3.0;  //  ': '
      List_Spacing[10]  #  List_Spacing[ 9] + 50.0; //  Adr.Stichwort
      List_Spacing[11]  #  List_Spacing[10] + 20.0; //
      List_Spacing[12]  #  List_Spacing[11] + 20.0; //
      List_Spacing[13]  #  List_Spacing[12] + 20.0; //
      List_Spacing[14]  #  List_Spacing[13] + 20.0; //
      List_Spacing[15]  #  List_Spacing[14] + 20.0;
      List_Spacing[16]  #  List_Spacing[15] + 20.0;
      List_Spacing[17]  #  List_Spacing[16] + 20.0;


      LF_Set(1, 'Re. Datum'                                           ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      LF_Set(4,  DatS(Sel.Von.Datum)                           ,n , _LF_Date);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      LF_Set(6,  DatS(Sel.bis.Datum)                           ,n , _LF_Date);

      Adr.KundenNr # Sel.Adr.von.KdNr;
      Erx # RecRead(100, 2, 0); // Kunde holen
      if(Erx > _rMultiKey) or (Adr.KundenNr = 0) then
        RecBufClear(100);
      LF_Set(7, 'Kunde'                                            ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, Adr.Stichwort                                ,n , 0);

    end;

    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 50.0; // 'Stichwort'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 25.0; // 'Re. Nr.'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 25.0; // 'Re. Datum'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 25.0; // 'Fällig Datum'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 25.0; // 'Re. Betrag'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 30.0; // 'ZE Nr.'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 35.0; // 'letzter ZE Betrag'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 35.0; // 'letztes ZE Datum'
      List_Spacing[10]  # List_Spacing[ 9]  + 30.0; // 'Saldo'
      List_Spacing[11]  # List_Spacing[ 10] + 30.0; //
      List_Spacing[12]  # List_Spacing[ 11] + 30.0; //
      List_Spacing[13]  # List_Spacing[ 12] + 30.0; //
      List_Spacing[14]  # List_Spacing[ 13] + 30.0; //
      List_Spacing[15]  # List_Spacing[ 14] + 30.0;
      List_Spacing[16]  # List_Spacing[ 15] + 30.0;
      List_Spacing[17]  # List_Spacing[ 16] + 30.0;
      List_Spacing[18]  # List_Spacing[ 17] + 30.0;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Stichwort'                     ,n , 0);
      LF_Set(2,  'Re. Nr.'                       ,y , 0);
      LF_Set(3,  'Re. Datum'                     ,n , 0);
      LF_Set(4,  'Fällig Datum'                  ,n , 0);
      LF_Set(5,  'Re. Betrag'                    ,y , 0);
      LF_Set(6,  'letzte ZE Nr.'                 ,y , 0);
      LF_Set(7,  'letzter ZE Betrag'             ,y , 0);
      LF_Set(8,  'letztes ZE Datum'              ,n , 0);
      LF_Set(9,  'Saldo'                         ,y , 0);
    end;


    'POSITION' : begin
      if (aPrint) then begin
        // WURSCHTEL
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
      LF_Set(1,  '@OfP.KundenStichwort'        ,n , 0);
      LF_Set(2,  '@OfP.Rechnungsnr'            ,y , _LF_IntNG);
      LF_Set(3,  '@OfP.Rechnungsdatum'         ,n , _LF_Date);
      LF_Set(4,  '@OfP.Zieldatum'              ,n , _LF_Date);
      LF_Set(5,  '@OfP.BruttoW1'               ,y , _LF_Wae);
      LF_Set(6,  '@ZEi.Nummer'                 ,y , _LF_IntNG);
      LF_Set(7,  '@ZEi.BetragW1'               ,y , _LF_Wae);
      LF_Set(8,  '@ZEi.Zahldatum'              ,n , _LF_Date);
      LF_Set(9,  '@OfP.RestW1'                 ,y , _LF_Wae);
      /*
      LF_Set(1,  '@Mat.Nummer'          ,y , _LF_IntNG);
      LF_Set(2,  '@Mat.Güte'            ,n , 0);
      LF_Set(3,  '@Mat.Dicke'           ,y , _LF_Num3, Set.Stellen.Dicke);
      LF_Set(4,  '@Mat.Breite'          ,y , _LF_Num3, Set.Stellen.Breite);
      LF_Set(5,  '@Mat.Länge'           ,y , _LF_Num3, "Set.Stellen.Länge");
      LF_Set(6,  '@Mat.Coilnummer'      ,n , 0);
      LF_Set(7,  '@Mat.Warengruppe'     ,y , _LF_IntNG);
      LF_Set(8,  '@Mat.Status'          ,y , _LF_IntNG);
      LF_Set(9,  '@Mat.LieferStichwort' ,n , 0);
      LF_Set(10, '@Mat.LagerStichwort'  ,n , 0);
      LF_Set(11, '@Mat.Bestand.Stk'     ,y , _LF_Int);
      LF_Set(12, '@Mat.Bestand.Gew'     ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(13, '@Mat.Bestellt.Gew'    ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(14, '@Mat.EK.Preis'        ,y , _LF_Wae);
      LF_Set(15, '@Mat.EK.Effektiv'     ,y , _LF_Wae);
      LF_Set(16, 'Mat.EK.Effektiv*Mat.Bestand.Gew/1000.0,2)' ,y , _LF_Wae);
      */
    end;


    'GESAMT' : begin

      if (aPrint) then begin
        LF_Text(9, ANum(GetSum(cSumGesSaldo), 2));
        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(9, '#'                 ,y , _LF_WAE);
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
  vQ460       : alpha(4000);
  vQ470       : alpha(4000);
  vProgress   : handle;
  vZEiNr      : int;
  vZEiDat     : date;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  vQ460 # '';
  if (Sel.von.Datum <> 00.00.0000) or (Sel.bis.Datum <> today) then
    Lib_Sel:QVonBisD(var vQ460, 'OfP.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
  if (Sel.Adr.von.Kdnr <> 0)then
    Lib_Sel:QInt(var vQ460, 'OfP.Kundennummer', '=', Sel.Adr.von.Kdnr);

  if("Sel.Fin.GelöschteYN" = false) then
    Lib_Sel:QFloat(var vQ460, 'OfP.RestW1', '!=', 0.0);


  vSel # SelCreate(460, 1);
  Erx # vSel->SelDefQuery('', vQ460);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);
  vProgress # Lib_Progress:Init('Sortierung', RecInfo(460, _recCount, vSel));
  FOR Erx # RecRead(460, vSel, _recFirst);
  LOOP Erx # RecRead(460, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(460, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    vSortKey # cnvAI(OfP.Rechnungsnr, _FmtNumLeadZero, 0, 12);
    Sort_ItemAdd(vTree,vSortKey,460,RecInfo(460,_RecId));
  END;
  SelClose(vSel);
  SelDelete(460, vSelName);
  vSel # 0;
  vProgress->Lib_Progress:Term();

  // ABLAGE-Selektion
  vQ470 # '';
  if (Sel.von.Datum <> 00.00.0000) or (Sel.bis.Datum <> today) then
    Lib_Sel:QVonBisD(var vQ470, '"OfP~Rechnungsdatum"', Sel.von.Datum, Sel.bis.Datum);
  if (Sel.Adr.von.Kdnr <> 0)then
    Lib_Sel:QInt(var vQ470, '"OfP~Kundennummer"', '=', Sel.Adr.von.Kdnr);
  if("Sel.Fin.GelöschteYN" = false) then
    Lib_Sel:QFloat(var vQ470, 'OfP~RestW1', '!=', 0.0);

  vSel # SelCreate(470, 1);
  Erx # vSel->SelDefQuery('', vQ470);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 470, _recCount, vSel ) );
  FOR Erx # RecRead(470, vSel, _recFirst);
  LOOP Erx # RecRead(470, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(470, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    vSortKey # cnvAI("OfP~Rechnungsnr", _FmtNumLeadZero, 0, 12);
    Sort_ItemAdd(vTree,vSortKey,470,RecInfo(470,_RecId));
  END;
  SelClose(vSel);
  SelDelete(470, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Header    # LF_NewLine('HEADER');
  g_Position  # LF_NewLine('POSITION');
  g_SumGesamt # LF_NewLine('GESAMT');
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    // Datensatz holen
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID);

    // Ablage?
    if (cnvIA(vItem->spCustom) = 470) then
      RecBufCopy(470, 460);


    vZEiNr   # 0;
    vZEiDat  # 00.00.0000;

    FOR Erx # RecLink(461, 460, 1, _recFirst); // OfP Zahlungen
    LOOP Erx # RecLink(461, 460, 1, _recNext);
    WHILE(Erx <= _rLocked) DO BEGIN
      Erx # RecLink(465, 461, 2, _recFirst); // Zahlungseingang
      if(Erx > _rLocked) then
        RecBufClear(465);
      if(vZEiDat < ZEi.Zahldatum) then begin
        vZEiNr   # OfP.Z.Zahlungsnr;
        vZEiDat  # ZEi.Zahldatum;
      end;
    END;

    ZEi.Nummer  # vZEiNr;
    Erx # RecRead(465, 1, 0);
    if(Erx > _rLocked) then
      RecBufClear(465);

    LF_Print(g_Position);

    AddSum(cSumGesSaldo, OfP.RestW1);
  END;

  LF_Print(g_SumGesamt);

  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Position);
  LF_FreeLine(g_SumGesamt);
end;

//========================================================================