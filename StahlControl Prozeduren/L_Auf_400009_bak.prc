@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Auf_400009
//
//  Info        Auftragsbestandswert
//
//
//
//  07.11.2011  AI  Erstellung der Prozedur
//  11.06.2013  ST  Selektion um Auftragsvorgänge erweitert
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
  cAufGesAuftragswertN : 1
  cAufGesRestWertN     : 2
  cAufGesDeckungsb     : 3
  cGesAuftragswertN    : 4
  cGesRestWertN        : 5
  cGesDeckungsb        : 6
end;

// Handles für die Zeilenelemente
local begin
  g_Empty         : int;
  g_Sel1          : int;
  g_Sel2          : int;
  g_Header        : int;
  g_Auftrag       : int;
  g_Summe1        : int;
  g_Leselinie     : logic;
  g_Buf401        : int;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Auf.bis.WTermin #  today;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.400009',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd(Translate('Kunde'));
  vHdl2->WinLstDatLineAdd(Translate('Liefertermin'));
  vHdl2->wpcurrentint # 1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected=0) then RETURN;
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

      LF_Set(1, 'Warengr'                                           ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      if (Sel.Mat.von.Wgr <> 0) then
        LF_Set(4,  ZahlI(Sel.Mat.von.Wgr)                           ,n , _LF_INT);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      if (Sel.Mat.bis.Wgr <> 0) then
        LF_Set(6,  ZahlI(Sel.Mat.bis.Wgr)                           ,y , _LF_INT);
      LF_Set(7, 'Status'                                            ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      if (Sel.Mat.von.Status <> 0) then
        LF_Set(10, ZahlI(Sel.Mat.von.Status)                        ,n , _LF_INT);
      LF_Set(11, ' bis: '                                           ,n , 0);
      if (Sel.Mat.bis.Status <> 0) then
        LF_Set(12,  ZahlI(Sel.Mat.bis.Status)                       ,y , _LF_INT);
      if (Sel.Auf.bis.Wgr <> 0) then
        LF_Set(12,  ZahlI(Sel.Auf.bis.Wgr)                          ,y , _LF_INT);
      LF_Set(13, 'Güte'                                             ,n , 0);
      LF_Set(14, ': '                                               ,n , 0);
      LF_Set(16,  "Sel.Mat.Güte" +' ('+"Sel.Mat.Gütenstufe"+')'     ,n , 0);
    end;


    'SEL2' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Oberfläche'                                        ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      LF_Set(4, ZahlI(Sel.Mat.ObfNr)                                ,n , _LF_INT);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      LF_Set(6, ZahlI(Sel.Mat.ObfNr2)                               ,n , _LF_INT);
      LF_Set(7, 'Lieferant'                                         ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(10, ZahlI(Sel.Mat.Lieferant)                           ,n , _LF_INT);
      LF_Set(13, 'Lagerort'                                         ,n , 0);
      LF_Set(14, ': '                                               ,n , 0);
      LF_Set(16, ZahlI(Sel.Mat.Lagerort)                            ,n , _LF_INT);
    end;



    'HEADER' : begin
      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 20.0; // 'Auftrag'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 50.0; // 'Kunde'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 40.0; // 'Liefertermin'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 50.0; // 'Auftragswert netto'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 50.0; // 'Restwert netto'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 50.0; // 'Rest Deckungsbeitrag'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 50.0; //
      List_Spacing[ 9]  # List_Spacing[ 8]  + 50.0; //
      List_Spacing[10]  # List_Spacing[ 9]  + 50.0; //
      List_Spacing[11]  # List_Spacing[ 10] + 50.0; //
      List_Spacing[12]  # List_Spacing[ 11] + 50.0; //
      List_Spacing[13]  # List_Spacing[ 12] + 50.0; //
      List_Spacing[14]  # List_Spacing[ 13] + 50.0; //
      List_Spacing[15]  # List_Spacing[ 14] + 50.0; //
      List_Spacing[16]  # List_Spacing[ 15] + 50.0;
      List_Spacing[17]  # List_Spacing[ 16] + 50.0;
      List_Spacing[18]  # List_Spacing[ 17] + 50.0;


      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Auftrag'                                  ,y , 0);
      LF_Set(2,  'Kunde'                                    ,n , 0);
      LF_Set(3,  'Liefertermin'                             ,n , 0);
      LF_Set(4,  'Auftragswert netto'                       ,y , 0);
      LF_Set(5,  'Restwert netto'                           ,y , 0);
      LF_Set(6,  'Rest Deckungsbeitrag'                     ,y , 0);
    end;


    'AUFTRAG' : begin
      if (aPrint) then begin
        LF_Text(1, AInt(g_Buf401 -> Auf.P.Nummer));
        LF_Text(2, g_Buf401 -> Auf.P.KundenSW);
        LF_Text(3, cnvAD(g_Buf401 -> Auf.P.Termin1Wunsch));
        LF_Sum(4, cAufGesAuftragswertN, 2);
        LF_Sum(5, cAufGesRestWertN, 2);
        LF_Sum(6, cAufGesDeckungsb, 2);

        RETURN;
      end;

      // Instanzieren...
      LF_Set(1,  '#Auftrag'          ,y , _LF_IntNG);
      LF_Set(2,  '#KundenSW'            ,n , 0);
      LF_Set(3,  '#Liefertermin'           ,n , _LF_Date);
      LF_Set(4,  '#Auftragswert netto' ,y ,0);
      LF_Set(5,  '#Restwert netto' ,y ,0);
      LF_Set(6,  '#Rest Deckungsbeitrag' ,y ,0);

    end;


    'SUMME1' : begin

      if (aPrint) then begin
        LF_Sum(4, cGesAuftragswertN, 2);
        LF_Sum(5, cGesRestWertN, 2);
        LF_Sum(6, cGesDeckungsb, 2);
        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(4,  '#Auftragswert netto' ,y ,0);
      LF_Set(5,  '#Restwert netto' ,y ,0);
      LF_Set(6,  '#Rest Deckungsbeitrag' ,y ,0);
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
    //LF_Print(g_Sel1);
    //LF_Print(g_Sel2);
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
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;
  vOK         : logic;
  vTree       : int;
  vSortKey    : alpha;
  vQ401       : alpha(4000);
  vQ400       : alpha(4000);
  vProgress   : handle;

  vRest       : float;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  vQ401 # '';
  Lib_Sel:QAlpha(var vQ401, '"Auf.P.Löschmarker"', '=', ''); // keine geloeschten
  if (Sel.Auf.Kundennr <> 0) then
    Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr);
  if (Sel.Auf.von.WTermin <> 00.00.0000) or ( Sel.Auf.bis.WTermin <> today) then
    Lib_Sel:QVonBisD(var vQ401, 'Auf.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin);

  if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
  vQ401 # vQ401 + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 400
  vQ400 # '';
  Lib_Sel:QAlpha(var vQ400, 'Auf.Vorgangstyp', '=', c_Auf);

  vSel # SelCreate(401, 1);
  vSel->SelAddLink('', 400, 401, 3, 'Kopf');
  Erg # vSel->SelDefQuery('', vQ401);
  if (Erg<>0) then
    Lib_Sel:QError(vSel);
  Erg # vSel->SelDefQuery('Kopf', vQ400 );
  if (Erg <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 401, _recCount, vSel ) );

  FOR Erg # RecRead(401,vSel, _recFirst);
  LOOP Erg # RecRead(401,vSel, _recNext);
  WHILE (Erg <= _rLocked) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(401, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    if (aSort=1) then   vSortKey # StrFmt(Auf.P.KundenSW, 20, _StrEnd);
    if (aSort=2) then   vSortKey # cnvAI(cnvID(Auf.P.Termin1Wunsch), _FmtNumNoGroup | _FmtNumLeadZero, 0, 6);

    Sort_ItemAdd(vTree,vSortKey,401,RecInfo(401,_RecId));
  END;
  SelClose(vSel);
  SelDelete(401, vSelName);
  vSel # 0;


  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty         # LF_NewLine('EMPTY');
  g_Sel1          # LF_NewLine('SEL1');
  g_Sel2          # LF_NewLine('SEL2');
  g_Header        # LF_NewLine('HEADER');
  g_Auftrag       # LF_NewLine('AUFTRAG');
  g_Summe1        # LF_NewLine('SUMME1');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(true);    // Landscape

  g_Buf401  # RecBufCreate(401);
  g_Buf401 -> Auf.P.Nummer  # -1;

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

    if(Auf.P.Nummer = 100432) then
      debug('');

    if((g_Buf401 -> Auf.P.Nummer <> Auf.P.Nummer) and (g_Buf401 -> Auf.P.Nummer <> -1)) then begin
      LF_Print(g_Auftrag);
      ResetSum(cAufGesAuftragswertN);
      ResetSum(cAufGesRestWertN);
      ResetSum(cAufGesDeckungsb);
    end;

    vRest # 0.0;
    if(Auf.P.Menge * Auf.P.Prd.Rest <> 0.0) then
      vRest # Auf.P.Gesamtpreis / Auf.P.Menge * Auf.P.Prd.Rest;

    AddSum(cAufGesAuftragswertN, Auf.P.Gesamtpreis);
    AddSum(cAufGesRestWertN    , vRest);
    AddSum(cAufGesDeckungsb    , vRest - Auf.P.GesamtwertEKW1);

    AddSum(cGesAuftragswertN  , Auf.P.Gesamtpreis);
    AddSum(cGesRestWertN      , vRest);
    AddSum(cGesDeckungsb      , vRest - Auf.P.GesamtwertEKW1);

    RecBufCopy(401, g_Buf401);
  END;

  if(g_Buf401 -> Auf.P.Nummer <> -1) then begin
    LF_Print(g_Auftrag);
  end;

  LF_Print(g_Summe1);

  RecBufDestroy(g_Buf401);

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
  LF_FreeLine(g_Auftrag);
  LF_FreeLine(g_Summe1);
end;

//========================================================================