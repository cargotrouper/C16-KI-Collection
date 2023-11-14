@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_ArG_828001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Arbeitsgänge
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
      List_Spacing[ 2] # List_Spacing[ 1] + 25.0;
      List_Spacing[ 3] # List_Spacing[ 2] + 25.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 50.0;
      List_Spacing[ 5] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Aktion',      n, 0 );
      LF_Set( 2, 'Aktion2',     n, 0 );
      LF_Set( 3, 'Bezeichnung', n, 0 );
      LF_Set( 4, 'Typ',         n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        vA # '';
        if ( "ArG.Typ.1In-1OutYN" ) then
          vA # vA + ', 1 In - 1 Out';
        if ( "ArG.Typ.1In-yOutYN" ) then
          vA # vA + ', 1 In - Y Out';
        if ( "ArG.Typ.xIn-yOutYN" ) then
          vA # vA + ', X In - Y Out';
        if ( "ArG.Typ.VSBYN" ) then
          vA # vA + ', VSB';
        if ( vA != '' ) then
          LF_Text( 4, StrCut( vA, 3, StrLen( vA ) ) );

        RETURN;
      end;

      LF_Set( 1, '@ArG.Aktion',      n, 0 );
      LF_Set( 2, '@ArG.Aktion2',     n, 0 );
      LF_Set( 3, '@ArG.Bezeichnung', n, 0 );
      LF_Set( 4, '#Arg.Typ',         n, 0 );
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

  vPrgr # Lib_Progress:Init( 'Listengenerierung', RecInfo( 828, _recCount ) );
  FOR   Erx # RecRead( 828, 1, _recFirst );
  LOOP  Erx # RecRead( 828, 1, _recNext );
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