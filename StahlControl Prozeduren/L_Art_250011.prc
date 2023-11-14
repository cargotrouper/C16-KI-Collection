@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_250011
//                    OHNE E_R_G
//  Info        Inventurdifferenze
//
//
//  12.05.2010  AI  Erstellung der Prozedur
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
  g_Charge    : int;
  g_Summe1    : int;
  g_Summe2    : int;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Art.bis.Wgr         # 9999;
  Sel.Art.bis.ArtGr       # 9999;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.250011', here + ':AusSel');
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
  StartList(1,'');  // Liste generieren
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
  vX    : float;
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
      if (Sel.Art.von.Wgr <> 0) then
        LF_Set(4,  ZahlI(Sel.Art.von.Wgr)                           ,n , _LF_INT);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      if (Sel.Art.bis.Wgr <> 0) then
        LF_Set(6,  ZahlI(Sel.Art.bis.Wgr)                           ,y , _LF_INT);
      LF_Set(7, 'Artikelgr'                                         ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      if (Sel.Art.von.ArtGr <> 0) then
        LF_Set(10, ZahlI(Sel.Art.von.ArtGr)                        ,n , _LF_INT);
      LF_Set(11, ' bis: '                                           ,n , 0);
      if (Sel.Art.bis.ArtGr <> 0) then
        LF_Set(12,  ZahlI(Sel.Art.bis.ArtGr)                       ,y , _LF_INT);
    end;


    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 45.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  + 45.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  + 20.5;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 20.5;
      List_Spacing[ 6]  # List_Spacing[ 5]  + 20.5;
      List_Spacing[ 7]  # List_Spacing[ 6]  + 20.5;
      List_Spacing[ 8]  # List_Spacing[ 7]  + 20.0;
      List_Spacing[ 9]  # List_Spacing[ 8]  + 20.5;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Artikelnr.'                             ,n , 0);
      LF_Set(2,  'Stichwort'                              ,n , 0);
      LF_Set(3,  'Lagerot'                                ,n , 0);
      LF_Set(4,  'Anschrift'                              ,n , 0);
      LF_Set(5,  'Chargennr.'                             ,n , 0);
      LF_Set(6,  'Bestand'                                ,y , 0);
      LF_Set(7,  'Inventur'                               ,y , 0);
    end;


    'CHARGE' : begin
      if (aPrint) then begin
/*
        AddSum(1,cnvfi(Mat.Bestand.Stk));
        AddSum(2,Mat.Bestand.Gew);
        AddSum(3,Mat.Bestellt.Gew);
        AddSum(4,(Mat.EK.Effektiv*Mat.Bestand.Gew/1000.0));
        LF_Text(16, ZahlF(Mat.EK.Effektiv*Mat.Bestand.Gew/1000.0, 2));
*/
        // Inventur loopen...
        RETURN;
      end;

      // Instanzieren...
      LF_Set(1,   '@Art.Nummer'           ,n , 0);
      LF_Set(2,   '@Art.Stichwort'        ,n , 0);
      LF_Set(3,   'Ort'                   ,n , 0);
      LF_Set(4,   'Ort2'                  ,n , 0);
      LF_Set(5,   '@Art.C.Charge.Intern'  ,n , 0);
      LF_Set(6,   '@Art.C.Bestand'        ,y , _LF_Num, Set.Stellen.Menge);
      LF_Set(7,   '@Art.Inv.Menge'        ,y , _LF_Num, Set.Stellen.Menge);
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
  //vTree       : int;
  vSortKey    : alpha;

  vQ250       : alpha(4000);
  vProgress   : handle;
  vX          : float;
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  //vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery
  vQ250 # '';
  if (Sel.Art.von.ArtGr != 0) or (Sel.Art.bis.ArtGr != 9999) then
    Lib_Sel:QVonBisI(var vQ250, 'Art.Artikelgruppe', Sel.Art.von.ArtGr, Sel.Art.bis.ArtGr);
  if (Sel.Art.von.WGr != 0) or (Sel.Art.bis.WGr != 9999) then
    Lib_Sel:QVonBisI(var vQ250, 'Art.Warengruppe', Sel.Art.von.WGr, Sel.Art.bis.WGr);

  // Selektion starten...
  vSel # SelCreate(250, 1);
  Erx # vSel->SelDefQuery('', vQ250);
  if(Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);
  //vSelName # Sel_Build(vSel, 200, 'LST.200001',y,0);

  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Header    # LF_NewLine('HEADER');
  g_Charge    # LF_NewLine('CHARGE');
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(n);    // Portrait


  vProgress # Lib_Progress:Init( 'Ausgabe', RecInfo( 250, _recCount, vSel ) );
  vFlag # _RecFirst;
  WHILE (RecRead(250,vSel,vFlag) <= _rLocked) DO BEGIN
    vFlag # _recNext;

    // Progress
    vProgress->Lib_Progress:Step();

    // Chargen loopen...
    Erx # RecLink(252,250,4,_recfirst);
    WHILE (Erx<=_rLocked) do begin
      vOK # n;
      if ("Art.ChargenführungYN") then begin
        if (Art.C.Charge.Intern<>'') and (Art.C.Adressnr<>0) then vOK # y;
      end
      else begin
        if (Art.C.Adressnr<>0) and (Art.C.Charge.Intern='') then vOK # y;
      end;

      if (vOK) then begin
        vX # 0.0;
        Erx # REcLink(259,252,8,_recFirst);
        WHILE (Erx<=_rLocked) do begin
          vX # vX + Art.Inv.Menge;
          Erx # RecLink(259,252,8,_recNext);
        END;
        Art.Inv.Menge # vX;
        if (vX<>Art.C.Bestand) then LF_Print(g_Charge);
      end;

      Erx # RecLink(252,250,4,_recNext);
    END;

  END;
  SelClose(vSel);
  SelDelete(210, vSelName);
  vSel # 0;

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Charge);
  //LF_FreeLine(g_Summe1);
  //LF_FreeLine(g_Summe2);

end;

//========================================================================