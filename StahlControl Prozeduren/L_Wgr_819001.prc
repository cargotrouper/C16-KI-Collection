@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Wgr_819001
//                  OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Warengruppen
//
//  22.03.2005  TM  Erstellung der Prozedur
//  23.03.2010  PW  Neuer Listenstil
//  2022-06-28  AH  ERX
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
  lf_Line2  : handle;
  lf_Line3  : handle;
  lf_Line4  : handle;
  lf_Line5  : handle;
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
      List_Spacing[ 2] # List_Spacing[ 1] + 10.0;
      List_Spacing[ 3] # List_Spacing[ 2] + 12.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 12.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 17.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 15.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 50.0;
      List_Spacing[ 8] # List_Spacing[ 7] + 22.0;
      List_Spacing[ 9] # List_Spacing[ 8] + 20.0;
      List_Spacing[10] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',          y, 0 );
      LF_Set( 2, 'Datei',        y, 0 );
      LF_Set( 3, 'St.S.',        y, 0 );
      LF_Set( 4, 'Erlösgr.',     y, 0 );
      LF_Set( 5, 'Dichte',       y, 0 );
      LF_Set( 6, 'Bezeichnung',  n, 0 );
      LF_Set( 7, 'Aufpreisgr.',  y, 0 );
      LF_Set( 8, 'Mat.-Typ',     n, 0 );
      LF_Set( 9, 'Tränen KG/m²', y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Wgr.Nummer',          y, _LF_IntNG );
      LF_Set( 2, '@Wgr.Dateinummer',     y, _LF_IntNG );
      LF_Set( 3, '@Wgr.Steuerschlüssel', y, _LF_IntNG );
      LF_Set( 4, '@Wgr.Erlösgruppe',     y, _LF_IntNG );
      LF_Set( 5, '@Wgr.Dichte',          y, _LF_Num, 2 );
      LF_Set( 6, '@Wgr.Bezeichnung.L1',  n, 0 );
      LF_Set( 7, '@Wgr.Aufpreisgruppe',  y, _LF_Int );
      LF_Set( 8, '@Wgr.Materialtyp',     n, 0 );
      LF_Set( 9, '@Wgr.TränenKGproQM',   y, _LF_Num, 2 );
    end;

    'line2' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@Wgr.Bezeichnung.L2', n, 0 );
    end;

    'line3' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@Wgr.Bezeichnung.L3', n, 0 );
    end;

    'line4' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@Wgr.Bezeichnung.L4', n, 0 );
    end;

    'line5' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@Wgr.Bezeichnung.L5', n, 0 );
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
  Erx : int;
end;
begin
  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  lf_Line2  # LF_NewLine( 'line2' );
  lf_Line3  # LF_NewLine( 'line3' );
  lf_Line4  # LF_NewLine( 'line4' );
  lf_Line5  # LF_NewLine( 'line5' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  FOR   Erx # RecRead( 819, 1, _recFirst );
  LOOP  Erx # RecRead( 819, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_Line );

    if ( Wgr.Bezeichnung.L2 != '' ) then
      LF_Print( lf_Line2 );
    if ( Wgr.Bezeichnung.L3 != '' ) then
      LF_Print( lf_Line3 );
    if ( Wgr.Bezeichnung.L4 != '' ) then
      LF_Print( lf_Line4 );
    if ( Wgr.Bezeichnung.L5 != '' ) then
      LF_Print( lf_Line5 );
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Line2 );
  LF_FreeLine( lf_Line3 );
  LF_FreeLine( lf_Line4 );
  LF_FreeLine( lf_Line5 );
end;

//=========================================================================
//=========================================================================