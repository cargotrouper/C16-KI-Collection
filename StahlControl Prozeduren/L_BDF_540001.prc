@A+
//===== Business-Control =================================================
//
//  Prozedur    L_BDF_540001
//                    OHNE E_R_G
//
//  Info        Bedarfsliste
//
//  19.03.2012  TM  Übertahme aus TM_TEST
//  16.10.2013  AH  Anfragen
//  26.05.2014  AH  Fix: Bestellmengen werden in Art.MEH umgerechnet
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
@I:Def_BAG

declare StartList(aSort : int; aSortName : alpha);

define begin

end;

// Handles für die Zeilenelemente
local begin
  g_Empty       : int;
  g_Sel1        : int;
  g_Sel2        : int;
  g_Header      : int;
  g_Bedarf      : int;
  g_GesSum      : int;
  g_Leselinie   : logic;

  vBestellt     : float;
  vSumBestand   : float;
  vSumBestellt  : float;
  vSumVorschlag : float;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  List_FontSize           # 8;

  RecBufClear(998);

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.540001',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd(Translate('Lieferant'));
  vHdl2->wpcurrentint # 1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
    if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;
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
  vLine         : int;

end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #    0.0;
      List_Spacing[ 2]  #   20.0;
      List_Spacing[ 3]  #   40.0;
      List_Spacing[ 4]  #   50.0;
      List_Spacing[ 5]  #   60.0;

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

    end;

    'SEL2' : begin
      if (aPrint) then RETURN;

      // Instanzieren...

    end;

    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 20.0; // 'Lieferant'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 40.0; // 'Artikelnummer'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 40.0; // 'Stichwort'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 15.0; // 'MEH'

      List_Spacing[ 6]  # List_Spacing[ 5]  + 22.0; // 'Bestand'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 22.0; // 'Bestellt'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 22.0; // 'Bestell- vorschlag'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 22.0; // 'Bedarfs- termin'
      List_Spacing[10]  # List_Spacing[ 9]  + 22.0; // 'Bestell- termin'

      List_Spacing[11]  # List_Spacing[ 10] + 22.0; // 'ENDE'

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Lieferant'                ,y , 0);
      LF_Set(2,  'Artikelnummer'            ,y , 0);
      LF_Set(3,  'Stichwort'                ,n , 0);
      LF_Set(4,  'MEH'                      ,y , 0);
      LF_Set(5,  'Bestand'                  ,y , 0);

      LF_Set(6,  'Bestellt'                 ,y , 0);
      LF_Set(7,  'Bestell- vorschlag'       ,y , 0);
      LF_Set(8,  'Bedarfs- termin'          ,y , 0);
      LF_Set(9,  'Bestell- termin'          ,y , 0);

    end;


    'BEDARF' : begin
      if (aPrint) then begin
        LF_Text(6, ANum(vBestellt,2));
        RETURN;
      End;

      // Instanzieren...
      LF_Set(1,  '@Bdf.Lieferant.Wunsch'  ,y , 0);
      LF_Set(2,  '@Bdf.Artikelnr'         ,y , 0);
      LF_Set(3,  '@Art.Stichwort'         ,n , 0);
      LF_Set(4,  '@Art.MEH'               ,y , 0);
      LF_Set(5,  '@Art.C.Bestand'          ,y , 0);

      LF_Set(6,  'vBestellt'              ,y , 0);
      LF_Set(7,  '@BDF.Menge'             ,y , 0);
      LF_Set(8,  '@Bdf.Datum.Bis'      ,y , 0);
      LF_Set(9,  '@Bdf.TerminWunsch'      ,y , 0);


    end;

    'GESAMTSUMME' : begin
      if (aPrint) then begin
          LF_Text(5, ANum(vSumBestand,2));
          LF_Text(6, ANum(vSumBestellt,2));
          LF_Text(7, ANum(vSumVorschlag,2));
        RETURN;
      End;

      // Instanzieren...
      LF_Format(_LF_OverLine + _LF_Bold);
      LF_Set( 1,  'GESAMT'              ,y , 0);
      LF_Set( 2,  ''                    ,y , 0);
      LF_Set( 3,  ''                    ,n , 0);
      LF_Set( 4,  ''                    ,y , 0);
      LF_Set( 5,  'Bestand'             ,y , 0);

      LF_Set( 6,  'Bestellt'            ,y , 0);
      LF_Set( 7,  'Bestell- vorschlag'  ,Y , 0);
      LF_Set( 8,  ''                    ,y , 0);
      LF_Set( 9,  ''                    ,y , 0);

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
  vSortKey    : alpha(1000);
  vQ          : alpha(4000);

  vProgress   : handle;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  Lib_Sel:QInt( var vQ, 'Bdf.Nummer', '!=', 0 );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
  Lib_Sel:QVonBisD( var vQ, 'Bdf.Datum.Bis', Sel.von.Datum, Sel.bis.Datum );

  // Selektion starten...
  vSel # SelCreate( 540, 1 );

  Erx # vSel->SelDefQuery('', vQ );
  vSel->Lib_Sel:QError();

  vSelName # Lib_Sel:SaveRun( var vSel, 0);
  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo(540, _recCount, vSel));

  FOR Erx # RecRead(540,vSel, _recFirst);
  LOOP Erx # RecRead(540,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    if (!vProgress->Lib_Progress:Step()) then begin  // Progress
      SelClose(vSel);
      SelDelete(540, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

     vSortKey # CnvAD(Bdf.Datum.Bis,_FmtDateLongYear)+'|'
              + StrFmt(Bdf.Artikelnr,25,_StrEnd)+ '|'
              + CnvAI(Bdf.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8);

    Sort_ItemAdd(vTree, vSortKey, 540, RecInfo(540, _RecId));

  END;

  SelClose(vSel);
  SelDelete(540, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Header    # LF_NewLine('HEADER');
  g_Bedarf    # LF_NewLine('BEDARF');
  g_GesSum    # LF_NewLine('GESAMTSUMME');

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

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen aus vTree

    Erx # RecLink(100,540,3,0);                         // WunschLieferant lesen
    If (Erx > _rLocked) then                            // ggf. für weitere Details
      RecBufClear(100);

    Erx # RecLink(250,540,7,0);                         // Artikel lesen
    If (Erx > _rLocked) then                            // für weitere Details
      RecBufClear(250);

    Erx # RecLink(252,250,4,_recFirst);                 // Basis-Charge lesen
    If (Erx > _rLocked) then                            // für Bestandsmenge
      RecBufClear(252);

    vBestellt # 0.0;                                    // für jeden Posten zurücksetzen

    FOR Erx # RecLink(501,250,12,_recFirst)             // Bestellpositionen durchlaufen
    LOOP Erx # RecLink(501,250,12,_recNext)
    WHILE (Erx <= _rLocked) DO BEGIN                    // für Bestellmengen

      RekLink(500,501,3,_recFirst); // Kopf holen
      if (Ein.Vorgangstyp<>c_Bestellung) then CYCLE;

      If ("Ein.P.Löschmarker" != '*') then begin        // gelöschte ignorieren,
        // und in Art.MEH umwandeln
        vBestellt # (vBestellt + Lib_Einheiten:WandleMEH(501, Ein.P.FM.Rest.Stk, 0.0, Ein.P.FM.Rest, Ein.P.MEH, Art.MEH));
      end;
    END;

    LF_Print(g_Bedarf);                                 // Ausgabe Bedarfsposten

    vSumBestand # vSumBestand + Art.C.Bestand;
    vSumBestellt # vSumBestellt + vBestellt;
    vSumVorschlag # vSumVorschlag + BDF.Menge;

  END;                                                  // nächster Datensatz aus vTree / Ende

  LF_Print(g_GesSum);                                   // Ausgabe Gesamtsumme

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
  LF_FreeLine(g_Bedarf);
  LF_FreeLine(g_GesSum);

end;

//========================================================================