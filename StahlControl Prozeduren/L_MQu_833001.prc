@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_MQu_833001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Qualitäten (Mechanik)
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
      List_Spacing[ 2] # List_Spacing[ 1] + 12.0;
      List_Spacing[ 3] # List_Spacing[ 2] + 7.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 20.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 24.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 24.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 24.0;
      List_Spacing[ 8] # List_Spacing[ 7] + 24.0;
      List_Spacing[ 9] # List_Spacing[ 8] + 26.0;
      List_Spacing[10] # List_Spacing[ 9] + 26.0;
      List_Spacing[11] # List_Spacing[10] + 25.0;
      List_Spacing[12] # List_Spacing[11] + 25.0;
      List_Spacing[13] # List_Spacing[12] + 20.0;
      List_Spacing[14] # List_Spacing[13] + 20.0;
      List_Spacing[15] # List_Spacing[14] + 20.0;
      List_Spacing[16] # List_Spacing[15] + 20.0;
      List_Spacing[17] # List_Spacing[16] + 20.0;
      List_Spacing[18] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set(  1, 'ID',          y, 0 );
      LF_Set(  2, 'Nr.',         y, 0 );
      LF_Set(  3, 'bis Dicke',   y, 0 );
      LF_Set(  4, 'von StreckG', y, 0 );
      LF_Set(  5, 'bis StreckG', y, 0 );
      LF_Set(  6, 'von Zugfest', y, 0 );
      LF_Set(  7, 'bis Zugfest', y, 0 );
      LF_Set(  8, 'von Dehnung', y, 0 );
      LF_Set(  9, 'bis Dehnung', y, 0 );
      LF_Set( 10, 'von Körnung', y, 0 );
      LF_Set( 11, 'bis Körnung', y, 0 );
      LF_Set( 12, 'von Härte',   y, 0 );
      LF_Set( 13, 'bis Härte',   y, 0 );
      LF_Set( 14, 'von Rp 0,2',   y, 0 );
      LF_Set( 15, 'bis Rp 0,2',   y, 0 );
      LF_Set( 16, 'von Rp 1,0',   y, 0 );
      LF_Set( 17, 'bis Rp 1,0',   y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set(  1, '@MQu.M.GütenID',     y, _LF_IntNG );
      LF_Set(  2, '@MQu.M.lfdNr',       y, _LF_IntNG );
      LF_Set(  3, '@MQu.M.bisDicke',    y, _LF_Num, 2 );
      LF_Set(  4, '@MQu.M.Von.StreckG', y, _LF_Num, 2 );
      LF_Set(  5, '@MQu.M.Bis.StreckG', y, _LF_Num, 2 );
      LF_Set(  6, '@MQu.M.Von.Zugfest', y, _LF_Num, 2 );
      LF_Set(  7, '@MQu.M.Bis.Zugfest', y, _LF_Num, 2 );
      LF_Set(  8, '@MQu.M.Von.Dehnung', y, _LF_Num, 2 );
      LF_Set(  9, '@MQu.M.Bis.Dehnung', y, _LF_Num, 2 );
      LF_Set( 10, '@MQu.M.Von.Körnung', y, _LF_Num, 2 );
      LF_Set( 11, '@MQu.M.Bis.Körnung', y, _LF_Num, 2 );
      LF_Set( 12, '@MQu.M.Von.Härte',   y, _LF_Num, 2 );
      LF_Set( 13, '@MQu.M.Bis.Härte',   y, _LF_Num, 2 );
      LF_Set( 14, '@MQu.M.Von.DehnGrenzA',   y, _LF_Num, 2 );
      LF_Set( 15, '@MQu.M.Bis.DehnGrenzA',   y, _LF_Num, 2 );
      LF_Set( 16, '@MQu.M.Von.DehnGrenzB',   y, _LF_Num, 2 );
      LF_Set( 17, '@MQu.M.Bis.DehnGrenzB',   y, _LF_Num, 2 );
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
  LF_Init( true );

  FOR   Erx # RecRead( 833, 1, _recFirst );
  LOOP  Erx # RecRead( 833, 1, _recNext );
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