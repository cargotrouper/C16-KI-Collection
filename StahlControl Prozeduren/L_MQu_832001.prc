@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_MQu_832001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Qualitäten
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
      List_Spacing[ 2] # List_Spacing[ 1] + 15.0;
      List_Spacing[ 3] # List_Spacing[ 2] + 30.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 30.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 30.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 30.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 30.0;
      List_Spacing[ 8] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'ID',             y, 0 );
      LF_Set( 2, 'Güte 1',         n, 0 );
      LF_Set( 3, 'Güte 2',         n, 0 );
      LF_Set( 4, 'Werkstoffnr.',   y, 0 );
      LF_Set( 5, 'Ersetzen durch', n, 0 );
      LF_Set( 6, 'nach Norm',      n, 0 );
      LF_Set( 7, 'Gütenstufe',     n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@MQu.ID',            y, _LF_IntNG );
      LF_Set( 2, '@MQu.Güte1',         n, 0 );
      LF_Set( 3, '@MQu.Güte2',         n, 0 );
      LF_Set( 4, '@MQu.Werkstoffnr',   y, 0 );
      LF_Set( 5, '@MQu.ErsetzenDurch', n, 0 );
      LF_Set( 6, '@MQu.nachNorm',      n, 0 );
      LF_Set( 7, '@MQu.NurStufe',      n, 0 );
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

  FOR   Erx # RecRead( 832, 1, _recFirst );
  LOOP  Erx # RecRead( 832, 1, _recNext );
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