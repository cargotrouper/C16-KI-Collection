@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Kal_830001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Kalkulation
//
//  30.08.2007  MS  Erstellung der Prozedur
//  22.03.2010  PW  Neuer Listenstil
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
  lf_830    : handle;
  lf_831    : handle;
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
      List_Spacing[ 3] # List_Spacing[ 2] + 60.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 22.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 40.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 20.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 20.0;
      List_Spacing[ 8] # List_Spacing[ 7] + 20.0;
      List_Spacing[ 9] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',                             y, 0 );
      LF_Set( 2, 'Bezeichnung',                     n, 0 );
      LF_Set( 3, 'Termin',                          y, 0 );
      LF_Set( 4, 'Lieferanten',                     n, 0 );
      LF_Set( 5, 'Menge',                           y, 0 );
      LF_Set( 6, 'Preis ' + "Set.Hauswährung.Kurz", y, 0 );
      LF_Set( 7, 'PEH',                             y, 0 );
      LF_Set( 8, 'Vertreter',                       n, 0 );
    end;

    '830' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Kal.Nummer',      y, _LF_IntNG );
      LF_Set( 2, '@Kal.Bezeichnung', n, 0 );
    end;

    '831' : begin
      if ( aPrint ) then begin
        if ( RecLink( 100, 831, 1, _recFirst ) > _rLocked ) then // Lieferant
          RecBufClear( 100 );
        if ( RecLink( 110, 831, 2, _recFirst ) > _rLocked ) then // Vertreter
          RecBufClear( 100 );

        LF_Text( 5, ANum( Kal.P.Menge, Set.Stellen.Menge ) + ' ' + Kal.P.MEH );
        LF_Text( 7, AInt( Kal.P.PEH ) + ' ' + Kal.P.MEH );
        RETURN;
      end;

      LF_Set( 2, '@Kal.P.Bezeichnung',     n, 0 );
      LF_Set( 3, '@Kal.P.Termin',          y, 0 );
      LF_Set( 4, '@Adr.Stichwort',         n, 0 );
      LF_Set( 5, '#Kal.P.Menge+Kal.P.MEH', y, 0 );
      LF_Set( 6, '@Kal.P.PreisW1',         y, _LF_Wae, 2 );
      LF_Set( 7, '#Kal.P.PEH+Kal.P.MEH',   y, 0 );
      LF_Set( 8, '@Ver.Stichwort',         n, 0 );
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
  lf_830    # LF_NewLine( '830' );
  lf_831    # LF_NewLine( '831' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  FOR   Erx # RecRead( 830, 1, _recFirst );
  LOOP  Erx # RecRead( 830, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_830 );

    FOR   Erx # RecLink( 831, 830, 1, _recFirst );
    LOOP  Erx # RecLink( 831, 830, 1, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      LF_Print( lf_831 );
    END;
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_830 );
  LF_FreeLine( lf_831 );
end;

//=========================================================================
//=========================================================================