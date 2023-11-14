@A+
//===== Business-Control =================================================
//
//  Prozedur    L_SWe_620001
//                    OHNE E_R_G
//  Info        Sammelwareneingangsliste AVIS
//
//
//
//  27.09.2010  MS  Erstellung der Prozedur
//  19.10.2010  MS  Anpassung 1311/112
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
  g_Material  : int;
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
  RecBufClear(998);

  Sel.BAG.Nummer # 0;

  List_FontSize # 8;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.620001',here+':AusSel');
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
  //vHdl2->WinLstDatLineAdd(Translate('Abmessung'));
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
      List_Spacing[ 2]  # List_Spacing[ 1]  + 17.0; //'Datum'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 7.0;  //'Stk'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 16.0; //'Gewicht'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 23.0; //'Lfs.Nr.'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 23.0; //'Coilnr.'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 23.0; //'Chargennr.'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 23.0; //'Werksnr.'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 12.0; //'Gütenst.'
      List_Spacing[10]  # List_Spacing[ 9]  + 20.0; //'Güte'
      List_Spacing[11]  # List_Spacing[ 10] + 28.0; //'Art.Nr.'
      List_Spacing[12]  # List_Spacing[ 11] + 20.0; //'AF Oben'
      List_Spacing[13]  # List_Spacing[ 12] + 15.0; //'Wgr.'
      List_Spacing[14]  # List_Spacing[ 13] + 15.5; //'Dicke'
      List_Spacing[15]  # List_Spacing[ 14] + 15.5; //'Breite'
      List_Spacing[16]  # List_Spacing[ 15] + 9.0;  //'RID'
      List_Spacing[17]  # List_Spacing[ 16] + 15.5; //'Länge'
      List_Spacing[18]  # List_Spacing[ 17] + 20.0;
      List_Spacing[19]  # List_Spacing[ 18] + 20.0;
      List_Spacing[20]  # List_Spacing[ 19] + 1.0;

      List_Spacing[22]  # List_Spacing[ 20] + 1.0;
      List_Spacing[23]  # List_Spacing[ 22] + 1.0;
      List_Spacing[24]  # List_Spacing[ 23] + 1.0;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Datum'                       , n, 0);
      LF_Set(2,  'Stk'                          ,y, 0);
      LF_Set(3,  'Gewicht'                     , y, 0);
      LF_Set(4,  'Lfs.Nr.'                     , y, 0);
      LF_Set(5,  'Coilnr.'                     , n, 0);
      LF_Set(6,  'Chargennr.'                  , n, 0);
      LF_Set(7,  'Werksnr.'                    , n, 0);
      LF_Set(8,  'GSt.'                        , n, 0);
      LF_Set(9,  'Güte'                        , n, 0);
      LF_Set(10, 'Art.Nr.'                     , n, 0);
      LF_Set(11, 'AF Oben'                     , n, 0);
      LF_Set(12, 'Wgr.'                        , y, 0);
      LF_Set(13, 'Dicke'                       , y, 0);
      LF_Set(14, 'Breite'                      , y, 0);
      LF_Set(15, 'RID'                         , y, 0);
      LF_Set(16, 'Länge'                       , y, 0);
      if(LIST_XML = true) then begin
        LF_Set(17, 'Bem.'                      , n, 0);
      end;
    end;


    'MATERIAL' : begin
      if (aPrint) then begin
        if(List_XML = false) and (false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        RETURN;
      end;

      LF_Set(1,  '@SWe.P.Avis_Datum'            , n, _LF_Date);
      LF_Set(2,  '@SWe.P.Stückzahl'            , y, _LF_IntNG);
      LF_Set(3,  '@SWe.P.Gewicht'            , y, _LF_Num ,Set.Stellen.Gewicht);
      LF_Set(4,  '@SWe.P.Lieferscheinnr'            ,y , 0);
      LF_Set(5,  '@SWe.P.Coilnummer'            ,n , 0);
      LF_Set(6,  '@SWe.P.Chargennummer'            ,n , 0);
      LF_Set(7,  '@SWe.P.Werksnummer'            , n, 0);
      LF_Set(8,  '@SWe.P.Gütenstufe'            , n, 0);
      LF_Set(9,  '@SWe.P.Güte'            ,n , 0);
      LF_Set(10, '@SWe.P.Artikelnr'            ,n , 0);
      LF_Set(11, '@SWe.P.AusfOben'            ,n , 0);
      LF_Set(12, '@SWe.P.Warengruppe'            ,y , _LF_IntNG);
      LF_Set(13, '@SWe.P.Dicke'           ,y , _LF_Num3, Set.Stellen.Dicke);
      LF_Set(14, '@SWe.P.Breite'          ,y , _LF_Num3, Set.Stellen.Breite);
      LF_Set(15, '@SWe.P.RID'            ,y ,  _LF_Num3, Set.Stellen.Radien);
      LF_Set(16, '@SWe.P.Länge'            ,y , _LF_Num3, "Set.Stellen.Länge");
      if(LIST_XML = true) then begin
        LF_Set(17, '@SWe.P.Bemerkung'            ,n , 0);
      end;
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

  vQ621          : alpha(4000);
  vQ1         : alpha(4000);
  vProgress   : handle;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektion
  vQ621 # '';
  if (Sel.BAG.Nummer != 0 ) then
    Lib_Sel:QInt(var vQ621, 'SWe.P.Nummer', '=', Sel.BAG.Nummer);

  if(vQ621 <> '') then
    vQ621 # vQ621 + ' AND SWe.P.AvisYN';
  else
    vQ621 # 'SWe.P.AvisYN';


  vSel # SelCreate(621, 1);
  Erx # vSel->SelDefQuery('', vQ621);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init('Sortierung', RecInfo(621, _recCount, vSel));
  FOR Erx # RecRead(621, vSel, _recFirst);
  LOOP Erx # RecRead(621, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(621, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    vSortKey # cnvAF(SWe.P.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,2,8)
               + cnvAF(SWe.P.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,3,10)
               + cnvAF("SWe.P.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,3,12);

    Sort_ItemAdd(vTree,vSortKey,621,RecInfo(621,_RecId));
  END;
  SelClose(vSel);
  SelDelete(621, vSelName);
  vSel # 0;
  //vProgress->Lib_Progress:Term();

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Header    # LF_NewLine('HEADER');
  g_Material  # LF_NewLine('MATERIAL');
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
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    LF_Print(g_Material);
  END;

  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Material);
  LF_FreeLine(g_Summe1);
  LF_FreeLine(g_Summe2);
end;

//========================================================================