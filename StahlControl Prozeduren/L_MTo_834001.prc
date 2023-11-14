@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_MTo_834001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Toleranzen
//
//  22.03.2005  TM  Erstellung der Prozedur
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
  lf_Empty   : handle;
  lf_Header  : handle;
  lf_Header2 : handle;
  lf_Line    : handle;
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

      List_Spacing[ 7] # 145.0;
      List_Spacing[ 8] # List_Spacing[ 7] + 22.0;
      List_Spacing[ 9] # List_Spacing[ 8];
      List_Spacing[10] # List_Spacing[ 9] + 22.0;
      List_Spacing[11] # List_Spacing[10];
      List_Spacing[12] # List_Spacing[11] + 22.0;
      List_Spacing[13] # List_Spacing[12];
      List_Spacing[14] # List_Spacing[13] + 22.0;
      List_Spacing[15] # List_Spacing[14];
      List_Spacing[16] # List_Spacing[15] + 22.0;
      List_Spacing[17] # List_Spacing[16];
      List_Spacing[18] # List_Spacing[17] + 22.0;
      List_Spacing[19] # List_Spacing[18];
      List_Spacing[20] # 277.0;

      LF_Format( _LF_Bold );
      LF_Set(  7, 'Dicke',       y, _LF_CENTERED );
      LF_Set(  9, 'Breite',      y, _LF_CENTERED );
      LF_Set( 11, 'Länge',       y, _LF_CENTERED );
      LF_Set( 13, 'Dickentol.',  y, _LF_CENTERED );
      LF_Set( 15, 'Breitentol.', y, _LF_CENTERED );
      LF_Set( 17, 'Längentol.',  y, _LF_CENTERED );
    end;

    'header2' : begin
      if ( aPrint ) then
        RETURN;

      List_Spacing[ 1] # 0.0;
      List_Spacing[ 2] # List_Spacing[ 1] + 15.0;
      List_Spacing[ 3] # List_Spacing[ 2] + 33.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 32.0; // 12.0
      List_Spacing[ 5] # List_Spacing[ 4];        // 20.0
      List_Spacing[ 6] # List_Spacing[ 5] + 25.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 40.0;
      List_Spacing[ 8] # List_Spacing[ 7] + 11.0;
      List_Spacing[ 9] # List_Spacing[ 8] + 11.0;
      List_Spacing[10] # List_Spacing[ 9] + 11.0;
      List_Spacing[11] # List_Spacing[10] + 11.0;
      List_Spacing[12] # List_Spacing[11] + 11.0;
      List_Spacing[13] # List_Spacing[12] + 11.0;
      List_Spacing[14] # List_Spacing[13] + 11.0;
      List_Spacing[15] # List_Spacing[14] + 11.0;
      List_Spacing[16] # List_Spacing[15] + 11.0;
      List_Spacing[17] # List_Spacing[16] + 11.0;
      List_Spacing[18] # List_Spacing[17] + 11.0;
      List_Spacing[19] # List_Spacing[18] + 11.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set(  1, 'Nr.',             y, 0 );
      LF_Set(  2, 'Name',            n, 0 );
      LF_Set(  3, 'Warengruppe',     y, _LF_CENTERED );
      LF_Set(  5, 'Werkstoffnr',     y, 0 );
      LF_Set(  6, 'Zusatzkriterium', n, 0 );
      LF_Set(  7, 'von',             y, 0 );
      LF_Set(  8, 'bis',             y, 0 );
      LF_Set(  9, 'von',             y, 0 );
      LF_Set( 10, 'bis',             y, 0 );
      LF_Set( 11, 'von',             y, 0 );
      LF_Set( 12, 'bis',             y, 0 );
      LF_Set( 13, 'von',             y, 0 );
      LF_Set( 14, 'bis',             y, 0 );
      LF_Set( 15, 'von',             y, 0 );
      LF_Set( 16, 'bis',             y, 0 );
      LF_Set( 17, 'von',             y, 0 );
      LF_Set( 18, 'bis',             y, 0 );

      List_Spacing[ 4] # List_Spacing[ 3] + 12.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 20.0;
    end;

    'line' : begin
      if ( aPrint ) then begin
        Wgr.Nummer # MTo.Warengruppe;
        if ( RecRead( 819, 1, 0 ) > _rLocked ) then
          RecBufClear( 819 );

        RETURN;
      end;

      LF_Set(  1, '@MTo.ID',              y, _LF_IntNG );
      LF_Set(  2, '@MTo.Name',            n, 0 );
      LF_Set(  3, '@MTo.Warengruppe',     y, _LF_IntNG );
      LF_Set(  4, '@Wgr.Bezeichnung.L1',  n, 0 );
      LF_Set(  5, '@MTo.Werkstoffnr',     y, 0 );
      LF_Set(  6, '@MTo.ZusatzKriterium', n, 0 );
      LF_Set(  7, '@MTo.Von.Dicke',       y, _LF_Num, 2 );
      LF_Set(  8, '@MTo.Bis.Dicke',       y, _LF_Num, 2 );
      LF_Set(  9, '@MTo.Von.Breite',      y, _LF_Num, 2 );
      LF_Set( 10, '@MTo.Bis.Breite',      y, _LF_Num, 2 );
      LF_Set( 11, '@MTo.Von.Länge',       y, _LF_Num, 2 );
      LF_Set( 12, '@MTo.Bis.Länge',       y, _LF_Num, 2 );
      LF_Set( 13, '@MTo.DickenTol.Von',   y, _LF_Num, 2 );
      LF_Set( 14, '@MTo.DickenTol.Bis',   y, _LF_Num, 2 );
      LF_Set( 15, '@MTo.BreitenTol.Von',  y, _LF_Num, 2 );
      LF_Set( 16, '@MTo.BreitenTol.Bis',  y, _LF_Num, 2 );
      LF_Set( 17, '@MTo.LängenTol.Von',   y, _LF_Num, 2 );
      LF_Set( 18, '@MTo.LängenTol.Bis',   y, _LF_Num, 2 );
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
  LF_Print( lf_Header2 );
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
  lf_Empty   # LF_NewLine( '' );
  lf_Header  # LF_NewLine( 'header' );
  lf_Header2 # LF_NewLine( 'header2' );
  lf_Line    # LF_NewLine( 'line' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  FOR   Erx # RecRead( 834, 1, _recFirst );
  LOOP  Erx # RecRead( 834, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_Line );
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Header2 );
  LF_FreeLine( lf_Line );
end;

//=========================================================================
//=========================================================================