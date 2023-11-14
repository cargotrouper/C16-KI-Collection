@A+
//===== Business-Control =================================================
//
//  Prozedur    L_BAG_702005
//                    OHNE E_R_G
//  Info        Ausgabe der vorhandenen Alibidaten, die während der
//              Verwiegung beim Fertigmelden durch die Waage übermittelt
//              werden.
//
//
//  05.03.2013  ST  Erstellung der Prozedur
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

declare StartList(aSort : int; aSortName : alpha);

// Handles für die Zeilenelemente
local begin
  g_Empty     : int;
  g_Sel1      : int;
  g_Header    : int;
  g_Verwiegung  : int;
  g_Leselinie : logic;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin

  RecBufClear(998);


  if (Dlg_Standard:DatumVonBis('Fertigmeldungsdatum', var Sel.Mat.von.EDatum, var Sel.Mat.bis.EDatum, 0.0.0, today)) then
    L_BAG_702005:AusSel();


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

  vSort # 0;
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
  vBagStr : alpha;
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

      LF_Set(1, 'Datum'                                           ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      LF_Set(4,  CnvAd(Sel.Mat.von.EDatum)                  ,n ,0);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      LF_Set(6,  CnvAd(Sel.Mat.bis.EDatum)                          ,y , _LF_INT);
    end;

    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  # 30.0; // "Fertigmeldung"
      List_Spacing[ 2]  # 17.0; // Datum
      List_Spacing[ 3]  # 20.0; // Mateiral
      List_Spacing[ 4]  # 20.0; // FM Brutto
      List_Spacing[ 5]  # 20.0; // FM Netto

      List_Spacing[ 6]  # 5.0; // Leer

      List_Spacing[ 7] # 35.0;  //  Alibi1
      List_Spacing[ 8] # 35.0;  //  Alibi2
      List_Spacing[ 9] # 35.0;  //  Alibi3
      List_Spacing[10] # 35.0;  //  Alibi4
      List_Spacing[11] # 35.0;  //  Alibi5
      List_Spacing[12] # 35.0;
      Lib_List2:ConvertWidthsToSpacings( 17 ); // Spaltenbreiten konvertieren

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,   'Fertigmeldung' ,n , 0);
      LF_Set(2,   'Datum'         ,n , 0);
      LF_Set(3,   'Material'      ,y , 0);
      LF_Set(4,   'FM Brutto'     ,y , 0);
      LF_Set(5,   'FM Netto'      ,y , 0);
      LF_Set(6,   ''              ,n , 0);
      LF_Set(7,   'Alibidaten1'   ,n , 0);
      LF_Set(8,   'Alibidaten2'   ,n , 0);
      LF_Set(9,   'Alibidaten3'   ,n , 0);
      LF_Set(10,  'Alibidaten4'   ,n , 0);
      LF_Set(11,  'Alibidaten5'   ,n , 0);
    end;


    'VERWIEGUNG' : begin
      if (aPrint) then begin

        if(List_XML = false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;

        vBagStr # Aint(BAG.FM.Nummer) + '/' +
                  Aint(BAG.FM.Position) + '/' +
                  Aint(BAG.FM.Fertigung) + '/' +
                  Aint(BAG.FM.Fertigmeldung);

        LF_Text(1, vBagStr);

        RETURN;

      end;

      // Instanzieren...
      LF_Set(1,  '#gBagStr'               ,n , 0);
      LF_Set(2,  '@BAG.FM.Datum'          ,n , _LF_Date);
      LF_Set(3,  '@BAG.FM.Materialnr'     ,y , _LF_IntNG);
      LF_Set(4,  '@BAG.FM.Gewicht.Brutto' ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(5,  '@BAG.FM.Gewicht.Netto'  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(6,  ''                       ,n , 0);
      LF_Set(7,  '@BAG.FM.Waagedaten1'    ,n , 0);
      LF_Set(8,  '@BAG.FM.Waagedaten2'    ,n , 0);
      LF_Set(9,  '@BAG.FM.Waagedaten3'    ,n , 0);
      LF_Set(10, '@BAG.FM.Waagedaten4'    ,n , 0);
      LF_Set(11, '@BAG.FM.Waagedaten5'    ,n , 0);
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

  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vProgress   : handle;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // BESTAND-Selektion
  vQ  # '';
  vQ2 # '';

  Lib_Sel:QVonBisD(var vQ, '"BAG.FM.Datum"', "Sel.Mat.von.EDatum", "Sel.Mat.bis.EDatum");

  Lib_Sel:QAlpha(var vQ2, 'BAG.FM.Waagedaten1', '=', '');
  Lib_Sel:QAlpha(var vQ2, 'BAG.FM.Waagedaten2', '=', '');
  Lib_Sel:QAlpha(var vQ2, 'BAG.FM.Waagedaten3', '=', '');
  Lib_Sel:QAlpha(var vQ2, 'BAG.FM.Waagedaten4', '=', '');
  Lib_Sel:QAlpha(var vQ2, 'BAG.FM.Waagedaten5', '=', '');

  vQ # vQ + ' AND NOT (' + vQ2 + ')';

  vSel # SelCreate(707, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 707, _recCount, vSel ) );
  vFlag # _RecFirst;
  FOR   Erx # RecRead(707,vSel,_RecFirst);
  LOOP  Erx # RecRead(707,vSel,_RecNext);
  WHILE Erx <= _rLocked DO BEGIN

    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      SelClose(vSel);
      SelDelete(707, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;


    vSortKey # Lib_Strings:DateForSort(BAG.FM.Datum) + Lib_Strings:IntForSort(Bag.FM.Materialnr);
    Sort_ItemAdd(vTree,vSortKey,707,RecInfo(707,_RecId));

  END;
  SelClose(vSel);
  SelDelete(707, vSelName);
  vSel # 0;


  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Header    # LF_NewLine('HEADER');
  g_Verwiegung  # LF_NewLine('VERWIEGUNG');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(y);    // Landscape

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    LF_Print(g_Verwiegung);
  END;

  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Verwiegung);
end;

//========================================================================