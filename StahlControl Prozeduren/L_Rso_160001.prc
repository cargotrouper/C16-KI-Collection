@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Rso_160001
//                    OHNE E_R_G
//  Info
//        Liste: Ressourcen Übersichtsliste
//
//  21.07.2010  PW  Erstellung
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

      // Spaltenbreiten
      list_Spacing[ 1] # 10.0; // Grp
      list_Spacing[ 2] # 10.0; // Nr.
      list_Spacing[ 3] # 10.0; // Abt.
      list_Spacing[ 4] # 40.0; // Stichwort
      Lib_List2:ConvertWidthsToSpacings( 5, 190.0 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Grp.',        y, 0 );
      LF_Set( 2, 'Nr.',         y, 0 );
      LF_Set( 3, 'Abt.',        y, 0 );
      LF_Set( 4, 'Stichwort',   n, 0 );
      LF_Set( 5, 'Bezeichnung', n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Rso.Gruppe',       y, _LF_IntNG );
      LF_Set( 2, '@Rso.Nummer',       y, _LF_IntNG );
      LF_Set( 3, '@Rso.Abteilung',    y, _LF_IntNG );
      LF_Set( 4, '@Rso.Stichwort',    n, 0 );
      LF_Set( 5, '@Rso.Bezeichnung1', n, 0 );
    end;

    'line2' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 5, '@Rso.Bezeichnung2', n, 0 );
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
  Erx   : int;
  vPrgr : handle;
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
  vPrgr # Lib_Progress:Init( 'Listengenerierung', RecInfo( 160, _recCount ) );

  FOR   Erx # RecRead( 160, 1, _recFirst );
  LOOP  Erx # RecRead( 160, 1, _recNext );
  WHILE ( Erx <= _rLocked ) and ( vPrgr->Lib_Progress:Step() ) DO BEGIN
    LF_Print( lf_Line );

    if ( Rso.Bezeichnung2 != '' ) then
      LF_Print( lf_Line2 );
  END;

  /* Cleanup */
  vPrgr->Lib_Progress:Term();

  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Line2 );
end;

//=========================================================================
//=========================================================================