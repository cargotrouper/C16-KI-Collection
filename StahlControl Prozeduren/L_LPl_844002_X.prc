@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_LPl_844002
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Lagerplätze
//               Materialien am richtigen Lagerplatz
//
//  22.03.2005  TM  Erstellung der Prozedur
//  23.03.2010  PW  Neuer Listenstil
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    sub Element ( aName : alpha; aPrint : logic );
//    sub SeitenKopf ( aSeite : int );
//    sub SeitenFuss ( aSeite : int );
//    sub StartList ( aSort : int; aSortName : alpha );
//=========================================================================
@I:Def_Global
@I:Def_List2
declare StartList ( aSort : int; aSortName : alpha );

local begin
  lf_Empty  : handle;
  lf_Header : handle;
  lf_Line   : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  StartList( 0, '' );
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
begin
  case aName of
    'header' : begin
      if ( aPrint ) then
        RETURN;

      List_Spacing[ 1] # 0.0;
      List_Spacing[ 2] # List_Spacing[ 1] + 25.0;
      List_Spacing[ 3] # List_Spacing[ 2] + 20.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 20.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 15.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 20.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 20.0;
      List_Spacing[ 8] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Lagerplatz', n, 0 );
      LF_Set( 2, 'Material',   y, 0 );
      LF_Set( 3, 'Dicke',      y, 0 );
      LF_Set( 4, 'Breite',     y, 0 );
      LF_Set( 5, 'Länge',      y, 0 );
      LF_Set( 6, 'Gewicht',    y, 0 );
      LF_Set( 7, 'Bemerkung',  n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Mat.Lagerplatz',   n, 0 );
      LF_Set( 2, '@Mat.Nummer',       y, _LF_IntNG );
      LF_Set( 3, '@Mat.Dicke',        y, _LF_Num, "Set.Stellen.Dicke" );
      LF_Set( 4, '@Mat.Breite',       y, _LF_Num, "Set.Stellen.Breite" );
      LF_Set( 5, '@Mat.Länge',        y, _LF_Num, "Set.Stellen.Länge" );
      LF_Set( 6, '@Mat.Bestand.Gew',  y, _LF_Num, 0 );
      LF_Set( 7, StrChar( 95, 40 ),   n, 0 );
    end;
  end;
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf der Liste
//=========================================================================
sub SeitenKopf ( aSeite : int );
begin
  WriteTitel();
  LF_Print( lf_Empty );
  LF_Print( lf_Header );
end;


//=========================================================================
// SeitenFuss
//        Seitenfuß der Liste
//=========================================================================
sub SeitenFuss ( aSeite : int );
begin
end;


//=========================================================================
// StartList
//        Listenstart
//=========================================================================
sub StartList ( aSort : int; aSortName : alpha );
local begin
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vLPl      : alpha;
end;
begin
  /* Selektion */
  vSel # SelCreate( 200, 0 );
  vSel->SelAddSortFld( 2, 12, _keyFldAttrUpperCase );
  vSel->SelAddSortFld( 1, 16, _keyFldAttrUpperCase );
  vSel->SelAddSortFld( 1, 23, _keyFldAttrUpperCase );
  vSel->SelAddSortFld( 1, 30, _keyFldAttrUpperCase );
  vSelName # Lib_Sel:Save( vSel );



  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  FOR   Erx # RecRead( 200, vSel, _recFirst );
  LOOP  Erx # RecRead( 200, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( vLPl != Mat.Lagerplatz ) then
      LF_Print( lf_Empty );

    LF_Print( lf_Line );
    vLPl # Mat.Lagerplatz;
  END;


  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );

  vSel->SelClose();
  SelDelete( 200, vSelName );
end;

//=========================================================================
//=========================================================================