@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Grp_810001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Gruppen
//
//  22.03.2005  TM  Erstellung der Prozedur
//  18.03.2010  PW  Neuer Listenstil
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
  lf_Line2  : handle;
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

      List_Spacing[ 1] #   0.0;
      List_Spacing[ 2] # List_Spacing[ 1] +  30.0;
      List_Spacing[ 3] # List_Spacing[ 2] +  15.0;
      List_Spacing[ 4] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Name',        n, 0 );
      LF_Set( 2, 'Kürzel',      n, 0 );
      LF_Set( 3, 'Bezeichnung', n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Grp.Name',         n, 0 );
      LF_Set( 2, '@Grp.Kürzel',       n, 0 );
      LF_Set( 3, '@Grp.Bezeichnung1', n, 0 );
    end;

    'line2' : begin
      if ( !aPrint ) then
        LF_Set( 3, '@Grp.Bezeichnung2', n, 0 );
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

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  FOR   Erx # RecRead( 810, 1, _recFirst );
  LOOP  Erx # RecRead( 810, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_Line );

    if ( Grp.Bezeichnung2 != '' ) then
      LF_Print( lf_Line2 );
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Line2 );
end;

//=========================================================================
//=========================================================================