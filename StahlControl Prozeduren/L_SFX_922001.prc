@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_SFX_922001
//                    OHNE E_R_G
//  Info
//        Liste: Vorgaben / Sonderfunktionen
//
//  08.08.2008  MS  Erstellung der Prozedur
//  22.03.2010  PW  Neuer Listenstil
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
      List_Spacing[ 3] # List_Spacing[ 2] + 15.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 10.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 60.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 15.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 25.0;
      List_Spacing[ 8] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',       y, 0 );
      LF_Set( 2, 'Bereich',   n, 0 );
      LF_Set( 3, 'Rfg.',      y, 0 );
      LF_Set( 4, 'Name',      n, 0 );
      LF_Set( 5, 'Hotkey',    n, 0 );
      LF_Set( 6, 'Hauptmenü', n, 0 );
      LF_Set( 7, 'Prozedur',  n, 0 );
      if ( list_XML ) then
        LF_Set( 8, 'Bemerkung', n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@SFX.Nummer',      y, _LF_IntNG );
      LF_Set( 2, '@SFX.Bereich',     n, 0 );
      LF_Set( 3, '@SFX.Reihenfolge', y, _LF_IntNG );
      LF_Set( 4, '@SFX.Name',        n, 0 );
      LF_Set( 5, '@SFX.Hotkey',      n, 0 );
      LF_Set( 6, '@SFX.Hauptmenuname',   n, 0 );
      LF_Set( 7, '@SFX.Prozedur',    n, 0 );
      if ( list_XML ) then
        LF_Set( 8, '@SFX.Bemerkung',   n, 0 );
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

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  FOR   Erx # RecRead( 922, 1, _recFirst );
  LOOP  Erx # RecRead( 922, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_Line );
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
end;

//=========================================================================
//=========================================================================