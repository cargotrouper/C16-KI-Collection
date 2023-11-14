@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_VsA_817001
//                  OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Versandarten
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
      List_Spacing[ 3] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',         y, 0 );
      LF_Set( 2, 'Bezeichnung', n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@VsA.Nummer',         y, _LF_IntNG );
      LF_Set( 2, '@VsA.Bezeichnung.L1', n, 0 );
    end;

    'line2' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@VsA.Bezeichnung.L2', n, 0 );
    end;

    'line3' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@VsA.Bezeichnung.L3', n, 0 );
    end;

    'line4' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@VsA.Bezeichnung.L4', n, 0 );
    end;

    'line5' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@VsA.Bezeichnung.L5', n, 0 );
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

  FOR   Erx # RecRead( 817, 1, _recFirst );
  LOOP  Erx # RecRead( 817, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_Line );

    if ( VsA.Bezeichnung.L2 != '' ) then
      LF_Print( lf_Line2 );
    if ( VsA.Bezeichnung.L3 != '' ) then
      LF_Print( lf_Line3 );
    if ( VsA.Bezeichnung.L4 != '' ) then
      LF_Print( lf_Line4 );
    if ( VsA.Bezeichnung.L5 != '' ) then
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