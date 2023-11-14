@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Prj_P_122001
//                    OHNE E_R_G
//  Info        Projekt Zeiten
//
//
//
//  08.04.2011  MS  Erstellung der Prozedur
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
  g_Header    : int;
  g_PrjPosZeiten  : int;
  g_Summe1    : int;
  g_Summe2    : int;
  g_Leselinie : logic;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin

  /*
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.xxxxxxx',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
  */
  L_Prj_P_122001:AusSel();
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
  vLine : int;
  vObf  : alpha(120);
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;

    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 20.0; // 'Projekt'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 20.0; // 'Datum'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 15.0; // 'Dauer'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 80.0; // 'Bemerkung'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 25.0; // 'User'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 30.0; // 'Zusatzkosten'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 30.0; //
      List_Spacing[ 9]  # List_Spacing[ 8]  + 30.0; //
      List_Spacing[10]  # List_Spacing[ 9]  + 30.0; //
      List_Spacing[11]  # List_Spacing[ 10] + 30.0; //
      List_Spacing[12]  # List_Spacing[ 11] + 30.0; //
      List_Spacing[13]  # List_Spacing[ 12] + 30.0; //
      List_Spacing[14]  # List_Spacing[ 13] + 30.0; //
      List_Spacing[15]  # List_Spacing[ 14] + 30.0; //
      List_Spacing[16]  # List_Spacing[ 15] + 30.0;
      List_Spacing[17]  # List_Spacing[ 16] + 30.0;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Projekt'                                ,y , 0);
      LF_Set(2,  'Datum'                                  ,n , 0);
      LF_Set(3,  'Dauer'                                  ,y , 0);
      LF_Set(4,  'Bemerkung'                              ,n , 0);
      LF_Set(5,  'User'                                   ,n , 0);
      LF_Set(6,  'Zusatzkosten'                           ,y , 0);
    end;


    'PrjPosZeiten' : begin
      if (aPrint) then begin
        LF_Text(1, AInt(Prj.Z.Nummer) + '/' + AInt(Prj.Z.Position) /*+ '/' + AInt(Prj.Z.lfdNr)*/);
        RETURN;
      end;

      // Instanzieren...
      LF_Set(1,  '#Projekt/Position/Zeit'     ,y , 0);
      LF_Set(2,  '@Prj.Z.End.Datum'           ,n , 0);
      LF_Set(3,  '@Prj.Z.Dauer'               ,y , _LF_Num, 2);
      LF_Set(4,  '@Prj.Z.Bemerkung'           ,n , 0);
      LF_Set(5,  '@Prj.Z.User'                ,n , 0);
      LF_Set(6,  '@Prj.Z.ZusKosten'           ,y , _LF_Wae, 2);
    end;


    'SUMME1' : begin

      if (aPrint) then begin
        LF_Sum(11 ,1, 0);
        LF_Sum(13 ,3, Set.Stellen.Gewicht);
        LF_Sum(16 ,4, 2);
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
      LF_Set(16, 'SUM4'                 ,y , _LF_WAE);
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
  vQ          : alpha(4000);
  vQ1         : alpha(4000);
  vProgress   : handle;
  Erx         : int;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  FOR vItem # gMarkList->CteRead(_CteFirst);  // erste Element holen
  LOOP vItem # gMarkList->CteRead(_CteNext, vItem); // nächstes Element
  WHILE (vItem > 0) do begin  // Elemente durchlaufen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile <> 122) then
      CYCLE;

    Erx # RecRead(122, 0, _RecID, vMID);

    FOR Erx # RecLink(123, 122, 1, _recFirst); // Zeiten zu Pos. loopen
    LOOP Erx # RecLink(123, 122, 1, _recNext);
    WHILE(Erx <= _rLocked) DO BEGIN
      vSortKey # cnvAI(Prj.Z.Nummer, _FmtNumLeadZero, 0, 9) + cnvAI(Prj.Z.Position, _FmtNumLeadZero, 0, 9) + cnvAI(Prj.Z.lfdNr, _FmtNumLeadZero, 0, 9);
      Sort_ItemAdd(vTree, vSortKey, 123, RecInfo(123,_RecId));
    END;
  END;



  // Ausgabe ----------------------------------------------------------------
  vProgress # Lib_Progress:Init('Listengenerierung', CteInfo(vTree, _cteCount));

  // Druckelemente generieren...
  g_Empty         # LF_NewLine('EMPTY');
  g_Header        # LF_NewLine('HEADER');
  g_PrjPosZeiten  # LF_NewLine('PrjPosZeiten');
  g_Summe1        # LF_NewLine('SUMME1');
  g_Summe2        # LF_NewLine('SUMME2');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(false);    // Landscape

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

    LF_Print(g_PrjPosZeiten);
  END;

  //LF_Print(g_Summe1);
  //LF_Print(g_Summe2);


  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_PrjPosZeiten);
  LF_FreeLine(g_Summe1);
  LF_FreeLine(g_Summe2);

end;

//========================================================================