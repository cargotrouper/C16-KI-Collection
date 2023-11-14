@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Auf_400010
//                    OHNE E_R_G
//  Info        Auftrags-Restbestand Artikel
//
//
//  08.08.2012  MS  Erstellung der Prozedur
//  14.02.2014  AH  Fix: Hauswährung
//  13.06.2022  AH  ERX
//
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
  cGesSumGesamtWert : 1
end;

// Handles für die Zeilenelemente
local begin
  g_Empty       : int;
  g_Sel1        : int;
  g_Sel2        : int;
  g_Header      : int;
  g_AufPos      : int;
  g_GesamtSumme : int;
  g_Leselinie   : logic;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  // Vorbelegung Selektion
  Sel.Art.bis.ArtNr       # 'zzz';
  Sel.Auf.bis.WTermin     # DateMake(31,12,DateYear(today));
  List_FontSize           # 8;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.400001',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd(Translate('Kunden-Stichwort * Kommissionsnr.'));
  vHdl2->WinLstDatLineAdd(Translate('Liefertermin'));
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

  StartList(vSort, vSortname);  // Liste generieren
end;


//========================================================================
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  vLine       : int;
  vObf        : alpha(120);
  vGesamtwert : float;
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
      List_Spacing[ 2]  # List_Spacing[ 1]  + 20.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  +  2.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  +  8.0;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 25.0;
      List_Spacing[ 6]  # List_Spacing[ 5]  +  7.0;
      List_Spacing[ 7]  # List_Spacing[ 6]  + 25.0;

      List_Spacing[ 8]  # List_Spacing[ 7]  + 20.0;
      List_Spacing[ 9]  # List_Spacing[ 8]  +  2.0;
      List_Spacing[10]  # List_Spacing[ 9]  +  8.0;
      List_Spacing[11]  # List_Spacing[10]  + 25.0;
      List_Spacing[12]  # List_Spacing[11]  +  7.0;
      List_Spacing[13]  # List_Spacing[12]  + 25.0;


      List_Spacing[14]  # List_Spacing[ 13] + 20.0;
      List_Spacing[15]  # List_Spacing[ 14] +  2.0;
      List_Spacing[16]  # List_Spacing[ 15] +  8.0;
      List_Spacing[17]  # List_Spacing[ 16] + 25.0;
      List_Spacing[18]  # List_Spacing[ 17] +  7.0;
      List_Spacing[19]  # List_Spacing[ 18] + 25.0;

      Lf_Set(1, 'ArtNr'                                                  ,n , 0);
      Lf_Set(2, ' : '                                                    ,n , 0);
      Lf_Set(3, ' von: '                                                 ,n , 0);
      Lf_Set(4, Sel.Art.von.ArtNr                                        ,n , 0);
      Lf_Set(5, ' bis: '                                                 ,n , 0);
      Lf_Set(6, Sel.Art.bis.ArtNr                                        ,n , 0);
      Lf_Set(7, 'Wunsch'                                                 ,n , 0);
      Lf_Set(8, ': '                                                     ,n , 0);
      Lf_Set(9, ' von: '                                                 ,n , 0);
      Lf_Set(10, Cnvad(Sel.Auf.von.WTermin)                              ,n , 0);
      Lf_Set(11, ' bis: '                                                ,n , 0);
      Lf_Set(12, cnvad(Sel.Auf.bis.WTermin)                              ,y , 0);
      Lf_Set(13, 'Kundennr'                                              ,n , 0);
      Lf_Set(14, ': '                                                    ,n , 0);
      Lf_Set(16, ZahlI(Sel.Auf.Kundennr)                                 ,y , _LF_INT);
    end;

  /*
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
*/

    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 40.0; // 'Kunde'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 40.0; // 'Artikelnummer'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 40.0; // 'Art. Stichwort'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 25.0; // 'Auftrags-Nr.'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 25.0; // 'Menge'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 20.0; // 'MEH'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 20.0; // 'E-Preis'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 20.0; // 'PEH'
      List_Spacing[10]  # List_Spacing[ 9]  + 25.0; // 'Summe'
      List_Spacing[11]  # List_Spacing[ 10] + 25.0; // 'Termin'
      List_Spacing[12]  # List_Spacing[ 11] + 20.0; //
      List_Spacing[13]  # List_Spacing[ 12] + 20.0;
      List_Spacing[14]  # List_Spacing[ 13] + 20.0; //
      List_Spacing[15]  # List_Spacing[ 14] + 20.0; //

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Kunde'            , n, 0);
      LF_Set(2,  'Artikelnummer'    , n, 0);
      LF_Set(3,  'Art. Stichwort'   , n, 0);
      LF_Set(4,  'Auftrags-Nr.'     , n, 0);
      LF_Set(5,  'Menge'            , y, 0);
      LF_Set(6,  'MEH'              , n, 0);
      LF_Set(7,  'E-Preis '+"Set.Hauswährung.kurz", y, 0);
      LF_Set(8,  'PEH'              , y, 0);
      LF_Set(9,  'Gesamt '+"Set.Hauswährung.kurz", y, 0);
      LF_Set(10, 'Termin'           , n, 0);
    end;


    'AUFPOS' : begin
      if (aPrint) then begin
        LF_Text(4, AInt(Auf.P.Nummer) + '/' +  AInt(Auf.P.Position));

        RekLink(814,400,8,_recfirst); // Währung holen
        if ("Auf.WährungFixYN") then
          Wae.VK.Kurs     # "Auf.Währungskurs";
        if (Wae.VK.Kurs<>0.0) then
          Auf.P.Grundpreis # Rnd(Auf.P.Grundpreis / "Wae.VK.Kurs",2)
        else
          Auf.P.Grundpreis # 0.0;

        vGesamtwert # 0.0;
        if(Auf.P.PEH <> 0) then
          vGesamtwert # (Auf.P.Prd.Rest / cnvFI(Auf.P.PEH)) * Auf.P.Grundpreis;
        LF_Text(9, ANum(vGesamtwert, 2));
        AddSum(cGesSumGesamtWert, vGesamtWert);
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
      LF_Set(1,  '@Auf.P.KundenSW'                 ,n, 0);
      LF_Set(2,  '@Auf.P.Artikelnr'                ,n, 0);
      LF_Set(3,  '@Auf.P.ArtikelSW'                ,n, 0);
      LF_Set(4,  '#Auf.P.Nummer/Auf.P.Position'    ,n, 0);
      LF_Set(5,  '@Auf.P.Prd.Rest'                 ,y , _LF_Num3, "Set.Stellen.Menge");
      LF_Set(6,  '@Auf.P.MEH.Preis'                ,n , 0);
      LF_Set(7,  '@Auf.P.Grundpreis'               ,y , _LF_Wae);
      LF_Set(8,  '@Auf.P.PEH'                      ,y , _LF_IntNG);
      LF_Set(9,  '#Summe'                          ,y , _LF_Wae);
      LF_Set(10,  '@Auf.P.Termin1Wunsch'           ,n , 0);
    end;

    'GESSUM' : begin

      if (aPrint) then begin
        LF_Text(9, ANum(GetSum(cGesSumGesamtWert), 2));
        RETURN;
      end;
      // Instanzieren...

      LF_Format(_LF_Overline);
      LF_Set(9, 'SUM1'                 ,y , _LF_Wae);

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

  vQ401,vQ400 : alpha(4000);

  vProgress   : handle;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // BESTAND-Selektion
  vQ401  # '';
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != today) then
    Lib_Sel:QVonBisD( var vQ401, 'Auf.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.Kundennr != 0 ) then
    Lib_Sel:QInt( var vQ401, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr );
  if (Sel.Art.von.ArtNr != '') or (Sel.Art.bis.ArtNr != 'zzz') then
    Lib_Sel:QVonBisA(var vQ401, 'Auf.P.Artikelnr', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr);
  Lib_Sel:QAlpha(var vQ401, 'Auf.P.Artikelnr', '!=', '');     // MUSS ARTIKEL!
  Lib_Sel:QAlpha(var vQ401, '"Auf.P.Löschmarker"', '=', '');  // NICHT GELOESCHT!
  Lib_Sel:QFloat(var vQ401, 'Auf.P.Prd.Rest', '>', 0.0);      // REST GROESSE 0

  if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
  vQ401 # vQ401 + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 400
  vQ400 # '';
  Lib_Sel:QAlpha(var vQ400, 'Auf.Vorgangstyp', '=', c_Auf);

  vSel # SelCreate(401, 1);
  vSel->SelAddLink('', 400, 401, 3, 'Kopf');
  Erx # vSel->SelDefQuery('', vQ401);
  if (Erx<>0) then Lib_Sel:QError(vSel);

  Erx # vSel->SelDefQuery('Kopf', vQ400 );
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);
  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 401, _recCount, vSel ) );

  FOR Erx # RecRead(401,vSel, _recFirst);
  LOOP Erx # RecRead(401,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(401, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;


    RekLink(400,401,3,0); // AufKopf holen

    if (aSort=1) then   vSortKey # StrFmt(Auf.P.Artikelnr, 25, _StrEnd);
    if (aSort=2) then   vSortKey # StrFmt(Auf.P.KundenSW, 20, _StrEnd)
                                 + cnvAI(Auf.P.Nummer, _FmtNumNoGroup | _FmtNumLeadZero, 0, 12)
                                 + cnvAI(Auf.P.Position, _FmtNumNoGroup | _FmtNumLeadZero, 0, 5);
    if (aSort=3) then   vSortKey # cnvAI(cnvID(Auf.P.Termin1Wunsch), _FmtNumNoGroup | _FmtNumLeadZero, 0, 12);

    Sort_ItemAdd(vTree, vSortKey, 401, RecInfo(401, _RecId));
  END;
  SelClose(vSel);
  SelDelete(401, vSelName);
  vSel # 0;


  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Header    # LF_NewLine('HEADER');
  g_AufPos    # LF_NewLine('AUFPOS');
  g_GesamtSumme # LF_NewLine('GESSUM');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(y);    // Landscape

  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    if ( !vProgress->Lib_Progress:Step() ) then begin // Progress
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen

    RekLink(400,401,3,_recFirst);   // AufKopf holen
    LF_Print(g_AufPos);
  END;

  LF_Print(g_GesamtSumme);

  Sort_KillList(vTree); // Löschen der Liste

  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_AufPos);
  LF_FreeLine(g_GesamtSumme );

end;

//========================================================================