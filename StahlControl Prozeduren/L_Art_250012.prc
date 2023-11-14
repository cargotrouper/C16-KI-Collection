@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_250012
//                    OHNE E_R_G
//  Info        enthalten in Stücklisten
//
//
//  16.07.2010  AI  Erstellung der Prozedur
//  13.06.2022  AH  ERX
//
//  Subprozeduren
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
  g_Alpha     : int;
  g_Header    : int;
  g_SL        : int;
end;


//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  StartList(0,'');
end;


//========================================================================
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  Erx       : int;
  vLine     : int;
  vObf      : alpha(120);
  vPreis    : float;
  vPreisPEH : int;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'LINIE' : begin
      LF_Format(_LF_Overline);
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   220.0;
      LF_Set(1,  ''                  ,n , 0);
    end;


    'ALPHA' : begin

      if (aPrint) then begin
//        LF_Text(1,GV.alpha.01);
        RETURN;
      end;

      // Instanzieren...
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   220.0;
      LF_Set(1,  '@GV.Alpha.01'      ,n , 0);
    end;


    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 80.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  + 20.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  + 15.0;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 30.0;
      List_Spacing[ 6]  # List_Spacing[ 5]  + 22.0;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Artikelnr'                              ,n , 0);
      LF_Set(2,  'Menge'                                  ,y , 0);
      LF_Set(3,  'MEH'                                    ,n , 0);
      LF_Set(4,  'SL-Nummer'                              ,y , 0);
      LF_Set(5,  'Name'                                   ,n , 0);
    end;


    'SL' : begin
      if (aPrint) then begin
        Erx # ReCLink(255,256,5,_recFirst);   // SL-Kopf holen
        RETURN;
      end;

      // Instanzieren...
      LF_Set(1,  '@Art.SL.Artikelnr'    ,n , 0);
      LF_Set(2,  '@Art.SL.Menge'        ,y , _LF_Num3);
      LF_Set(3,  '@Art.SL.MEH'          ,n , 0);
      LF_Set(4,  '@Art.SLK.Nummer'      ,y , _LF_IntNG);
      LF_Set(5,  '@Art.SLK.Name'        ,n , 0);
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
    GV.alpha.01 # 'Artikel : '+Art.Nummer;
    LF_Print(g_Alpha);
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
  Erx       : int;
  vProgress : int;
end;
begin

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', RecLinkInfo(256,255,2,_recCount));

  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Alpha     # LF_NewLine('ALPHA');
  g_Header    # LF_NewLine('HEADER');
  g_SL        # LF_NewLine('SL');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(n);    // Landscape


  Erx # RecLink(256,250,2,_ReCfirst);   // in SL loopen
  WHILE (Erx<_rLocked) do begin
    LF_print(g_SL);
    Erx # RecLink(256,250,2,_RecNext);
  END;

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_ALPHA);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_SL);

end;

//========================================================================