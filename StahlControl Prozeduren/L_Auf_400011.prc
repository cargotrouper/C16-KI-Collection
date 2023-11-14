@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Auf_400011
//                    OHNE E_R_G
//  Info        Vorkalkulation pro Auftrag
//
//
//
//  25.03.2013  ST  Erstellung der Prozedur
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

  g_Aufkopf1  : int;
  g_Aufkopf2  : int;

  g_Auftrag       : int;
  g_Summe1    : int;
  g_Leselinie : logic;


  gBufKunde      : int;
  gBugLieferans  : int;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vSort       : int;
  vSortName   : alpha;
end
begin
  RecBufClear(998);

  Sel.Auf.von.Nummer # Auf.Nummer;
  Sel.Auf.bis.Nummer # Auf.Nummer;
  vSort # 1;
  gSelected # 0;




  StartList(vSort,vSortname);  // Liste generieren

  /*
  Sel.Auf.bis.Nummer # Auf.Nummer;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.400011',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
  */
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

/*
  gSelected # 0;
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
*/
  vSort # 1;
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
  vGesamt : float;

  vA : alpha(4000);
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #   30.0;
      List_Spacing[ 2]  #   30.0;
      List_Spacing[ 3]  #   10.0;
      Lib_List2:ConvertWidthsToSpacings( 3 ); // Spaltenbreiten konvertieren

      LF_Set(1, 'Auftrag:'         ,n , 0);
      LF_Set(2,  ZahlI(Auf.Nummer) ,n , _LF_INT);
    end;



    'AUFKOPF1' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #   30.0;
      List_Spacing[ 2]  #   100.0;
      List_Spacing[ 3]  #   30.0;
      List_Spacing[ 4]  #   100.0;
      List_Spacing[ 5]  #   10.0;
      Lib_List2:ConvertWidthsToSpacings( 5 ); // Spaltenbreiten konvertieren

      LF_Set(1, 'Kunde:'   ,n , 0);
      LF_Set(2,  StrAdj(gBufKunde->Adr.Name + ' '+ gBufKunde->Adr.Zusatz,_StrEnd) + ' ' + gBufKunde->Adr.Ort ,n);

      RekLink(812,gBugLieferans,2,0); // Land lesen
      vA # StrAdj(gBugLieferans->Adr.A.Name    +  ' ' +
           gBugLieferans->Adr.A.Zusatz,_StrEnd)  +  ', ' +
           gBugLieferans->"Adr.A.Straße"  +  ', ' +
           gBugLieferans->Adr.A.PLZ     +  ' ' +
           gBugLieferans->Adr.A.Ort;
      if (gBugLieferans->Adr.A.LKZ <> 'D') AND (gBugLieferans->Adr.A.LKZ <> 'DE') then
        vA # vA + ' ' + Lnd.Name.L1;

      LF_Set(3, 'Lieferadr:'                ,n , 0);
      LF_Set(4,  vA,n);
    end;

    'AUFKOPF2' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #   30.0;
      List_Spacing[ 2]  #   100.0;
      List_Spacing[ 3]  #   30.0;
      List_Spacing[ 4]  #   100.0;
      List_Spacing[ 5]  #   10.0;
      Lib_List2:ConvertWidthsToSpacings( 5 ); // Spaltenbreiten konvertieren

      LF_Set(1, 'Bestellung:'             ,n , 0);
      LF_Set(2,  Auf.Best.Nummer,n);
      LF_Set(3, 'Bestelldatum:'           ,n , 0);
      LF_Set(4,  CnvAd(Auf.Best.Datum,_FmtDateLongYear),n , _LF_Date);
    end;



    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  # 20.0; // Auftrag
      List_Spacing[ 2]  # 10.0; // Fortlaufnd. Nr
      List_Spacing[ 3]  # 60.0; // Bezeichnung
      List_Spacing[ 4]  # 30.0; // Menge
      List_Spacing[ 5]  # 10.0; // MEH
      List_Spacing[ 6]  # 15.0; // E-Preis
      List_Spacing[ 7]  # 20.0; // Preiseinheit
      List_Spacing[ 8]  # 20.0; // Gesamtpreis

      List_Spacing[ 13] # 20.0;
      Lib_List2:ConvertWidthsToSpacings( 13 ); // Spaltenbreiten konvertieren

      LF_Format(_LF_UnderLine + _LF_Bold);

      LF_Set(1, 'Auftrag'     ,n , 0);
      LF_Set(2, 'Nr'          ,y , 0);
      LF_Set(3, 'Bezeichnung' ,n , 0);
      LF_Set(4, 'Menge'       ,y , 0);
      LF_Set(5, 'MEH'         ,n , 0);
      LF_Set(6, 'E-Preis'     ,y , 0);
      LF_Set(7, 'pro'         ,y , 0);
      LF_Set(8, 'Gesamt €'    ,y , 0);
    end;


    'KALK' : begin
      if (aPrint) then begin
        LF_Text(1, Aint(Auf.P.Nummer) + '/' + Aint(Auf.P.Position) );


        LF_Text(7, Aint(Auf.K.PEH) + ' ' + Auf.K.MEH );

        // Auf.K.Menge wird ggf. durch Mengenbezug entsprechend gefüllt
        vGesamt # (Auf.K.Menge / CnvFi(Auf.K.PEH)) * Auf.K.Preis;
        LF_Text(8, ZahlF(  vGesamt,2));

        AddSum(1,vGesamt);

        if(List_XML = false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;

        RETURN;

      end;


      // Instanzieren...
      LF_Set( 1,  '#Kommission'          ,n , 0);
      LF_Set( 2,  '@Auf.K.lfdNr'         ,y , _LF_IntNG);
      LF_Set( 3,  '@Auf.K.Bezeichnung'   ,n , 0);
      LF_Set( 4,  '@Auf.K.Menge'         ,y , _LF_Num, Set.Stellen.Menge);
      LF_Set( 5,  '@Auf.K.MEH'           ,n , 0);
      LF_Set( 6,  '@Auf.K.Preis'         ,y , _LF_Wae);
      LF_Set( 7,  '#PEH'                 ,y , 0);
      LF_Set( 8,  '#Gesamtpreis'         ,y , _LF_Wae);

    end;


    'SUMME1' : begin

      if (aPrint) then begin
        LF_Sum(8 ,1, 0);
        RETURN;
      end;
      LF_Format(_LF_Overline);
      LF_Set(8, 'SUM1'                 ,y , _LF_WAE);
    end;



    'SUMME2' : begin
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

    LF_Print(g_Aufkopf1);
    LF_Print(g_Aufkopf2);

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
  vQ1         : alpha(4000);
  vProgress   : handle;

  vInserted : int;
  vItem2     : int;

  vEKMenge_kg   : float;
  vEKMenge_stk  : float;
  vEKMenge_m    : float;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // BESTAND-Selektion
  vQ  # '';

  Lib_Sel:QVonBisI(var vQ, '"Auf.P.Nummer"',        "Sel.Auf.von.Nummer", "Sel.Auf.bis.Nummer");


  vSel # SelCreate(401, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 401, _recCount, vSel ) );
  vFlag # _RecFirst;
  WHILE (RecRead(401,vSel,vFlag) <= _rLocked) DO BEGIN

    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      SelClose(vSel);
      SelDelete(401, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    if (vFlag=_RecFirst) then vFlag # _RecNext;
    vSortKey # cnvAI(Auf.P.Nummer,_FmtNumLeadZero,0,9) + cnvAI(Auf.P.Position,_FmtNumLeadZero,0,3);
    Sort_ItemAdd(vTree,vSortKey,401,RecInfo(401,_RecId));
  END;
  SelClose(vSel);
  SelDelete(401, vSelName);
  vSel # 0;

  gBufKunde   # RecBufCreate(100);
  gBufKunde->Adr.Kundennr   # Auf.Kundennr;
  RecRead(gBufKunde,2,0);


  gBugLieferans   # RecBufCreate(101);
  RekLink(gBugLieferans,400,2,0);



  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty       # LF_NewLine('EMPTY');
  g_Sel1        # LF_NewLine('SEL1');
  g_Header      # LF_NewLine('HEADER');
  g_Auftrag     # LF_NewLine('KALK');
  g_Aufkopf1    # LF_NewLine('AUFKOPF1');
  g_Aufkopf2    # LF_NewLine('AUFKOPF2');
  g_Summe1      # LF_NewLine('SUMME1');


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(y);    // Landscape


  vInserted  # CteOpen(_CteList);

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

    RekLink(400,401,3,0); // Kopfdaten lesen
    RekLink(101,400,2,0); // Lieferadresse lesen

    vEKMenge_kg   # 0.0;
    vEKMenge_stk  # 0.0;
    vEKMenge_m    # 0.0;

    // Kalkulation durchgehen, Einsätze und Mengen für ;Mengenbezogene Kalkulationen ermitteln
    FOR   Erx # RecLink(405,401,7,_RecFirst)
    LOOP  Erx # RecLink(405,401,7,_RecNext)
    WHILE Erx = _rOK DO BEGIN
      if (Auf.K.EinsatzmengeYN = false) then
        CYCLE;

      LF_Print(g_Auftrag);

      case StrCnv(Auf.K.MEH,_StrLower) of
        'stk' : vEKMenge_stk # vEKMenge_stk + Auf.K.Menge;
        'kg'  : vEKMenge_kg  # vEKMenge_kg  + Auf.K.Menge;
        'm'   : vEKMenge_m   # vEKMenge_m   + Auf.K.Menge;
      end;

      vInserted->CteInsertItem(Aint(Auf.K.lfdNr),Auf.K.lfdNr,'');
    END;

    // Kalkulation durchgehen und Einsätze Drucken
    FOR   Erx # RecLink(405,401,7,_RecFirst)
    LOOP  Erx # RecLink(405,401,7,_RecNext)
    WHILE Erx = _rOK DO BEGIN
      vItem2 # CteRead(vInserted,_CteFirst | _CteSearch,0,Aint(Auf.K.lfdNr));
      if (vItem2 > 0) then
        CYCLE;

      if (Auf.K.MengenbezugYN) then begin
        case StrCnv(Auf.K.MEH,_StrLower) of
          'stk' : Auf.K.Menge # vEKMenge_stk;
          'kg'  : Auf.K.Menge # vEKMenge_kg;
          'm'   : Auf.K.Menge # vEKMenge_m;
        end;
      end;

      LF_Print(g_Auftrag);
    END;

    LF_Print(g_Summe1);
    LF_Print(g_Empty);
  END;

  vInserted->CteClose();



  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Auftrag);
  LF_FreeLine(g_Aufkopf1);
  LF_FreeLine(g_Aufkopf2);


  LF_FreeLine(g_Summe1);

  RecBufDestroy(gBufKunde);
  RecBufDestroy(gBugLieferans);
end;

///========================================================================/
