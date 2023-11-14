@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Mat_200007
//                    OHNE E_R_G
//  Info        Ausgabe der Lagegeldberechnung
//
//
//  11.11.2009  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Element(aName : alpha; aPrint : logic);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List2
@I:Def_aktionen

@I:Struct_Lagergeld

// Handles für die Zeilenelemente
local begin
  g_Empty     : int;
  g_Alpha     : int;
  g_Header    : int;
  g_Material  : int;
  g_Summe     : int;
end;

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vSort : int;
  vSortName : alpha;
end;
begin
  StartList(vSort,vSortname);  // Liste generieren
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
    Adr.Nummer # Sel.Mat.Lagerort;
    Recread(100,1,0);                 // Adresse holen
    RecLink(101,100,12,_recFirst);    // Hauptanschrift holen
    if (Sel.Mat.Lageranschri<>0) then begin
      Adr.A.Nummer # Sel.Mat.Lageranschri;
      RecRead(101,1,0);               // Anschrift holen
    end;
    GV.Alpha.01 # 'für Lageranschrift: '+Adr.A.Anrede+' '+Adr.A.Name+' '+Adr.A.Zusatz+', '+Adr.A.Ort+', '+"Adr.A.Straße";
    LF_Print(g_alpha);
    GV.Alpha.01 # 'Zeitraum: '+dats(Sel.Mat.von.EDatum)+' bis '+Dats(Sel.Mat.bis.EDatum);
    LF_Print(g_alpha);
    GV.Alpha.01 # 'Preis pro TonnenTage : '+ANum(GV.Num.01,4)+"Set.HausWährung.Kurz";
    LF_Print(g_alpha);
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
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  vLine               : int;
  vObf                : alpha(120);
  vBereitsBerechnetYN : logic;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'ALPHA' : begin
      if (aPrint) then begin
        LF_Text( 1, Gv.Alpha.01 );
        RETURN;
      end;

      List_Spacing[ 1] #   0.0;
      List_Spacing[ 2] # 277.0;
      LF_Set( 1, '#Gv.ALpha.01', n, 0 );
    end;

    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1] # 0.0;
      List_Spacing[ 2] # List_Spacing[ 1] + 5.0; //
      List_Spacing[ 3] # List_Spacing[ 2] + 20.0; // Mat.Nr.
      List_Spacing[ 6] # List_Spacing[ 3];
      List_Spacing[ 7] # List_Spacing[ 6] + 30.0; // Qualität
      List_Spacing[ 8] # List_Spacing[ 7] + 20.0; // Dicke
      List_Spacing[ 9] # List_Spacing[ 8] + 20.0; // Breite
      List_Spacing[10] # List_Spacing[ 9] + 20.0; // Länge
      List_Spacing[11] # List_Spacing[10] + 25.0; // von Datum
      List_Spacing[12] # List_Spacing[11] + 25.0; // bis Datum
      List_Spacing[13] # List_Spacing[12] + 20.0; // Tage
      List_Spacing[14] # List_Spacing[13];
      List_Spacing[15] # List_Spacing[14] + 20.0; // Gewicht
      List_Spacing[21] # List_Spacing[15];
      List_Spacing[22] # List_Spacing[21] + 25.0; // Tonnentage
      List_Spacing[23] # List_Spacing[22] + 25.0; // Betrag

      LF_Format( _LF_UnderLine + _LF_Bold );
      LF_Set(  2, 'Mat.Nr.',                          y, 0 );

      if ( list_XML ) then begin
        LF_Set(  3, 'Bestellnummer',                         y, 0 );
        LF_Set(  4, 'Lagerort',                              n, 0 );
        LF_Set(  5, 'Lageranschrift',                        n, 0 );
      end;

      LF_Set(  6, 'Qualität',                         n, 0 );
      LF_Set(  7, 'Dicke',                            y, 0 );
      LF_Set(  8, 'Breite',                           y, 0 );
      LF_Set(  9, 'Länge',                            y, 0 );
      LF_Set( 10, 'von Datum',                        y, 0 );
      LF_Set( 11, 'bis Datum',                        y, 0 );
      LF_Set( 12, 'Tage',                             y, 0 );

      if ( list_XML ) then begin
        LF_Set( 13, 'Stück',                                 y, 0 );
      end;

      LF_Set( 14, 'Gewicht',                          y, 0 );

      if ( list_XML ) then begin
        LF_Set( 15, 'Status',                                y, 0 );
        LF_Set( 16, 'Kommision',                             n, 0 );
        LF_Set( 17, 'WE Datum',                              y, 0 );
        LF_Set( 18, 'WA Datum',                              y, 0 );
        LF_Set( 19, 'letztes Lagergeld',                     y, 0 );
        LF_Set( 20, 'EK ' + "Set.Hauswährung.Kurz" + ' / t', y, 0 );
      end;

      LF_Set( 21, 'TonnenTage',                       y, 0 );
      LF_Set( 22, 'Betrag ' + "Set.Hauswährung.Kurz", y, 0 );
    end;


    'MATERIAL' : begin
      if ( aPrint ) then begin
        GV.Datum.01 # s_VonDat;
        GV.Datum.02 # s_BisDat;
        GV.Int.11   # s_Tage;
        GV.Num.11   # s_Gewicht;
        GV.Num.12   # s_TTage;
        GV.Num.13   # Rnd( GV.Num.01 * s_TTage, 2 );
        vBereitsBerechnetYN #  ((cnvID(Mat.Datum.Lagergeld) >= cnvID(Sel.Mat.von.EDatum)) and ((cnvID(Mat.Datum.Lagergeld) <= cnvID(Sel.Mat.bis.EDatum))))
        if(vBereitsBerechnetYN = true) then
          LF_Text(1, '!');
        else
          LF_Text(1, '');

        AddSum( 11, CnvFI( s_Tage ) );
        AddSum( 13, s_Gewicht );
        AddSum( 20, s_TTage );
        AddSum( 21, GV.Num.13 );

        if ( list_XML ) then begin
          if ( RecLink( 100, 200, 5, _recFirst ) > _rLocked ) then // Lageradresse
            RecBufClear( 100 );
          LF_Text(  4, Adr.Stichwort );

          if ( RecLink( 101, 200, 6, _recFirst ) > _rLocked ) then // Lageranschrift
            RecBufClear( 100 );
          LF_Text(  5, Adr.A.Name );

          if ( RecLink( 203, 200, 13, _recFirst ) > _rLocked ) then // Reservierung
            RecBufClear( 203 );
          LF_Text( 16, Mat.R.Kommission );
        end;

        RETURN;
      end;

      // Instanzieren...
      LF_Set(  1, '#!',  n);
      LF_Set(  2, '@Mat.Nummer',  y, _LF_IntNG );

      if ( list_XML ) then begin
        LF_Set(  3, '@Mat.Bestellnummer',   y, 0 );
        LF_Set(  4, '#Lagerort',            n, 0 );
        LF_Set(  5, '#Lageranschrift',      n, 0 );
      end;

      LF_Set(  6, '@Mat.Güte',    n, 0 );
      LF_Set(  7, '@Mat.Dicke',   y, _LF_Num3, "Set.Stellen.Dicke" );
      LF_Set(  8, '@Mat.Breite',  y, _LF_Num3, "Set.Stellen.Breite" );
      LF_Set(  9, '@Mat.Länge',   y, _LF_Num3, "Set.Stellen.Länge" );
      LF_Set( 10, '@GV.Datum.01', y, _LF_Date );
      LF_Set( 11, '@GV.Datum.02', y, _LF_Date );
      LF_Set( 12, '@GV.Int.11',   y, _LF_IntNG );

      if ( list_XML ) then begin
        LF_Set( 13, '@Mat.Bestand.Stk',     y, _LF_Int );
      end;

      LF_Set( 14, '@GV.Num.11',   y, _LF_Num, "Set.Stellen.Gewicht" );

      if ( list_XML ) then begin
        LF_Set( 15, '@Mat.Status',          y, _LF_IntNG );
        LF_Set( 16, '#Mat.Kommission',      n, 0 );
        LF_Set( 17, '@Mat.Eingangsdatum',   y, _LF_Date );
        LF_Set( 18, '@Mat.Ausgangsdatum',   y, _LF_Date );
        LF_Set( 19, '@Mat.Datum.Lagergeld', y, _LF_Date );
        LF_Set( 20, '@Mat.EK.Preis',        y, _LF_Num3, 2 );
      end;

      LF_Set( 21, '@GV.Num.12',   y, _LF_Num, 0 );
      LF_Set( 22, '@GV.Num.13',   y, _LF_Wae, 2 );
    end;


    'SUMME' : begin
      if (aPrint) then begin
        LF_Sum( 12, 11, 0 );
        LF_Sum( 14, 13, 0 );
        LF_Sum( 21, 20, Set.Stellen.Gewicht );
        LF_Sum( 22, 21, 2 );
        RETURN;
      end;

      // Instanzieren...
      LF_Format( _LF_Overline );
      LF_Set( 12, '#SUM1', y, _LF_INT );
      LF_Set( 14, '#SUM2', y, _LF_NUM, Set.Stellen.Gewicht );
      LF_Set( 21, '#SUM3', y, _LF_NUM );
      LF_Set( 22, '#SUM4', y, _LF_WAE );
    end;

  end;  // case

end;


//========================================================================
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
  vTree     : int;
  vItem     : int;
end;
begin

  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Alpha     # LF_NewLine('ALPHA');
  g_Header    # LF_NewLine('HEADER');
  g_Material  # LF_NewLine('MATERIAL');
  g_Summe     # LF_NewLine('SUMME');

  // Liste starten
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  LF_Init(y);    // Landscape

  vTree   # GV.Int.01;
//  vBasis  # GV.Num.01;

  FOR  vItem # Sort_ItemFirst(vTree);
  loop vItem # Sort_ItemNext(vTree, vItem);
  WHILE (vItem != 0) DO BEGIN

    // Structure holen...
    VarInstance(struct_Lagergeld, vItem->spID);

    Mat_Data:Read(s_MatNr);

    LF_Print(g_Material);
  END;

  LF_Print(g_Summe);

  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Alpha);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Material);
  LF_FreeLine(g_Summe);

end;

//========================================================================