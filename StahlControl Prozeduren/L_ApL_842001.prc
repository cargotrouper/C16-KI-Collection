@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_ApL_842001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Aufpreise
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
local begin
  vA : alpha;
end;
begin
  case aName of
    'header' : begin
      if ( aPrint ) then
        RETURN;

      List_Spacing[ 1] # 0.0;
      List_Spacing[ 2] # List_Spacing[ 1] + 10.0;
      List_Spacing[ 3] # List_Spacing[ 2] +  8.0;
      List_Spacing[ 4] # List_Spacing[ 3] +  8.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 80.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 10.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 22.0;
      List_Spacing[ 8] # List_Spacing[ 7] + 22.0;
      List_Spacing[ 9] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Ver.',        y, 0 );
      LF_Set( 2, 'Nr1',         y, 0 );
      LF_Set( 3, 'Nr2',         y, 0 );
      LF_Set( 4, 'Bezeichnung', n, 0 );
      LF_Set( 5, 'Grp.',        y, 0 );
      LF_Set( 6, 'Datum von',   y, 0 );
      LF_Set( 7, 'Datum bis',   y, 0 );
      LF_Set( 8, 'Typ',         n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        vA # '';
        if ( "ApL.EinkaufYN" ) then
          vA # vA + ', EK';
        if ( "ApL.VerkaufYN" ) then
          vA # vA + ', VK';
        if ( "ApL.autoAnlegenYN" ) then
          vA # vA + ', Anl.';
        if ( "ApL.autoAuswahlYN" ) then
          vA # vA + ', Ausw.';
        if ( vA != '' ) then
          LF_Text( 8, StrCut( vA, 3, StrLen( vA ) ) );

        RETURN;
      end;

      LF_Set( 1, '@ApL.Key1',           y, _LF_IntNG );
      LF_Set( 2, '@ApL.Key2',           y, _LF_IntNG );
      LF_Set( 3, '@ApL.Key3',           y, _LF_IntNG );
      LF_Set( 4, '@ApL.Bezeichnung',    n, 0 );
      LF_Set( 5, '@ApL.Aufpreisgruppe', y, _LF_IntNG );
      LF_Set( 6, '@ApL.Datum.Von',      y, 0 );
      LF_Set( 7, '@ApL.Datum.Bis',      y, 0 );
      LF_Set( 8, '#Typ',                n, 0 );
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

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  vPrgr # Lib_Progress:Init( 'Listengenerierung', RecInfo( 842, _recCount ) );
  FOR  Erx # RecRead( 842, 1, _recFirst );
  LOOP Erx # RecRead( 842, 1, _recNext );
  WHILE ( Erx <= _rLocked ) and ( vPrgr->Lib_Progress:Step() ) DO BEGIN
    LF_Print( lf_Line );
  END;
  vPrgr->Lib_Progress:Term();

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
end;

//=========================================================================
//=========================================================================