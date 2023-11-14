@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Rek_301001
//                    OHNE E_R_G
//  Info        Reklamationsliste
//
//
//
//  27.07.2011  MS  Erstellung der Prozedur
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
  g_Sel2      : int;
  g_Sel3      : int;
  g_Header    : int;
  g_Position  : int;
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
  List_FontSize # 8;

  RecBufClear(998);
  Sel.Mat.bis.Status    # 9999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.300001',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd(Translate('Reklamationsnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Status'));
  vHdl2->wpcurrentint # 1;
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
      List_Spacing[ 2]  # List_Spacing[ 1]  + 18.0; // 'Nr./Pos.'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 15.0; // 'Erfassdatum'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 23.0; // 'Status'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 30.0; // 'Stichwort'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 18.0; // 'Auftrag'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 20.0; // 'Kd.-Beststellnr.'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 30.0; // 'Güte'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 8.0;  // 'St.'
      List_Spacing[10]  # List_Spacing[ 9]  + 14.0; // 'Dicke'
      List_Spacing[11]  # List_Spacing[ 10] + 16.0; // 'Breite'
      List_Spacing[12]  # List_Spacing[ 11] + 16.0; // 'Länge'
      List_Spacing[13]  # List_Spacing[ 12] + 10.0; // 'Stk.'
      List_Spacing[14]  # List_Spacing[ 13] + 18.0; // 'Gewicht'
      List_Spacing[15]  # List_Spacing[ 14] + 45.0; // 'Fehlercode'
      List_Spacing[16]  # List_Spacing[ 15] + 20.0; //
      List_Spacing[17]  # List_Spacing[ 16] + 20.0; //

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Nr.'                             ,n , 0);
      LF_Set(2,  'Erfassd.'                        ,n , 0);
      LF_Set(3,  'Status'                          ,n , 0);
      LF_Set(4,  'Stichwort'                       ,n , 0);
      LF_Set(5,  'Auftrag'                         ,n , 0);
      LF_Set(6,  'Kd.-Best.'                       ,n , 0);
      LF_Set(7,  'Güte'                            ,n , 0);
      LF_Set(8,  'GSt.'                             ,n , 0);
      LF_Set(9,  'Dicke'                           ,y , 0);
      LF_Set(10, 'Breite'                          ,y , 0);
      LF_Set(11, 'Länge'                           ,y , 0);
      LF_Set(12, 'Stk.'                            ,y , 0);
      LF_Set(13, 'Gewicht'                         ,y , 0);
      LF_Set(14, 'Fehlercode'                      ,n , 0);
    end;


    'POSITION' : begin
      if (aPrint) then begin
        /*
        if(List_XML = false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        */
        LF_Text(1, AInt(Rek.P.Nummer) + '/' + AInt(Rek.P.Position));
        RETURN;
      end;

      // Instanzieren...
      LF_Set(1,  '#Rek.P.Nummer/Rek.P.Position'          ,n ,0);
      LF_Set(2,  '@Rek.P.Datum'           ,n , _LF_Date);
      LF_Set(3,  '@Stt.Bezeichnung'         ,n , 0);
      LF_Set(4,  '@Rek.P.Stichwort'       ,n , 0);
      LF_Set(5,  '@Rek.Kommission'        ,n , 0);
      LF_Set(6,  '@Auf.P.Best.Nummer'     ,n , 0);
      LF_Set(7,  '@Mat.Güte'              ,n , 0);
      LF_Set(8,  '@Mat.Gütenstufe'         ,n , 0);
      LF_Set(9,  '@Mat.Dicke'           ,y , _LF_Num3, Set.Stellen.Dicke);
      LF_Set(10,  '@Mat.Breite'          ,y , _LF_Num3, Set.Stellen.Breite);
      LF_Set(11,  '@Mat.Länge'           ,y , _LF_Num3, "Set.Stellen.Länge");
      LF_Set(12, '@Rek.P.Stückzahl'     ,y , _LF_Int);
      LF_Set(13, '@Rek.P.Gewicht'     ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(14,  '@FhC.Bezeichnung'                       ,n , 0);
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
    LF_Print(g_Sel1);
    LF_Print(g_Sel2);
    LF_Print(g_Sel3);
    /*
    LF_Print(g_Sel4);
    LF_Print(g_Sel5);
    LF_Print(g_Sel6);
    */
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

  vQ301          : alpha(4000);

  vProgress   : handle;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Reklamationspos.-Selektion
  vQ301  # '';
  if ("Sel.Mat.von.Status" <> 0) or ("Sel.Mat.bis.Status" <> 9999) then
    Lib_Sel:QVonBisI(var vQ301, 'Rek.P.Status', "Sel.Mat.von.Status", "Sel.Mat.bis.Status");

  vSel # SelCreate(301, 1);
  Erx # vSel->SelDefQuery('', vQ301);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);


  vProgress # Lib_Progress:Init('Sortierung', RecInfo(301, _recCount, vSel));

  FOR Erx # RecRead(301, vSel, _recFirst);
  LOOP Erx # RecRead(301, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    // Progress
    if (!vProgress -> Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(301, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    if (aSort = 1) then   vSortKey # StrFmt(Rek.P.Stichwort, 20, _StrEnd);
    if (aSort = 2) then   vSortKey # cnvAI(Rek.P.Nummer,_FmtNumLeadZero, 0, 9)
                                   + cnvAI(Rek.P.Position,_FmtNumLeadZero, 0, 3);
    if (aSort = 3) then   vSortKey # cnvAI(Rek.P.Status,_FmtNumLeadZero, 0, 9);

    Sort_ItemAdd(vTree, vSortKey, 301, RecInfo(301, _RecId));
  END;
  SelClose(vSel);
  SelDelete(301, vSelName);
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
  g_Summe1    # LF_NewLine('SUMME1');
  g_Summe2    # LF_NewLine('SUMME2');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(y);    // Landscape

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Progress
    if (!vProgress->Lib_Progress:Step()) then BREAK;

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);

    Erx # RecLink(300, 301, 1, _recFirst); // Rek.Kopf holen
    if(Erx > _rLocked) then
      RecBufClear(300);

    Mat_Data:Read(Rek.P.Materialnr); // Mat.Karte lesen

    Auf_Data:Read(Rek.Auftragsnr, Rek.Auftragspos, true); // Auftragspos. + Kopf lesen

    Erx # RecLink(851, 301, 8, _recFirst); // Fehlercode holen
    if(Erx >_rLocked) then
      RecBufClear(851);

    Erx # RecLink(850, 301, 7, _recFirst); // Vorgangs-Status holen
    if(Erx >_rLocked) then
      RecBufClear(850);

    LF_Print(g_Position);
  END;


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
  LF_FreeLine(g_Summe1);
  LF_FreeLine(g_Summe2);

end;

//========================================================================