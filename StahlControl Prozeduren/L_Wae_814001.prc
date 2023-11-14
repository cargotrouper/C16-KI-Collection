@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Wae_814001
//                  OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Währungen
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
      List_Spacing[ 3] # List_Spacing[ 2] + 50.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 15.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 20.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 20.0;
      List_Spacing[ 7] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',         y, 0 );
      LF_Set( 2, 'Bezeichnung', n, 0 );
      LF_Set( 3, 'Kürzel',      n, 0 );
      LF_Set( 4, 'EK-Kurs',     y, 0 );
      LF_Set( 5, 'VK-Kurs',     y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Wae.Nummer',      y, _LF_IntNG );
      LF_Set( 2, '@Wae.Bezeichnung', n, 0 );
      LF_Set( 3, '@Wae.Kürzel',      n, 0 );
      LF_Set( 4, '@Wae.EK.Kurs',     y, _LF_NUM, 2 );
      LF_Set( 5, '@Wae.VK.Kurs',     y, _LF_NUM, 2 );
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

  FOR   Erx # RecRead( 814, 1, _recFirst );
  LOOP  Erx # RecRead( 814, 1, _recNext );
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