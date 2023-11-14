@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Ver_110001
//                  OHNE E_R_G
//  Info
//        Liste: Vertreter & Verbände
//
//  05.05.2008  MS  Erstellung der Prozedur
//  30.03.2010  PW  Neuer Listenstil
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

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 10.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 45.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 12.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 50.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 35.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 35.0;
      list_Spacing[ 8] # list_Spacing[ 7] + 30.0;
      list_Spacing[ 9] # list_Spacing[ 8] + 30.0;
      list_Spacing[10] # list_Spacing[ 9] + 30.0;
      list_Spacing[11] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',       y, 0 );
      LF_Set( 2, 'Stichwort', n, 0 );
      LF_Set( 3, 'Prov.',     y, 0 );
      LF_Set( 4, 'Name',      n, 0 );
      LF_Set( 5, 'Straße',    n, 0 );
      LF_Set( 6, 'Ort',       n, 0 );
      LF_Set( 7, 'Telefon1',  n, 0 );
      LF_Set( 8, 'Telefon2',  n, 0 );
      LF_Set( 9, 'Telefax',   n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        if ( Ver.Anrede != '' ) then
          LF_Text( 4, Ver.Anrede + ' ' + Ver.Name );
        else
          LF_Text( 4, Ver.Name );

        if ( Ver.LKZ != '' ) then
          LF_Text( 6, Ver.LKZ + '-' + Ver.PLZ + ' ' + Ver.Ort );
        else
          LF_Text( 6, Ver.PLZ + ' ' + Ver.Ort );

        RETURN;
      end;

      LF_Set( 1, '@Ver.Nummer',     y, _LF_IntNG );
      LF_Set( 2, '@Ver.Stichwort',  n, 0 );
      LF_Set( 3, '@Ver.ProvisionProz', y, _LF_Num, 2 );
      LF_Set( 4, '#Name',           n, 0 );
      LF_Set( 5, '@Ver.Straße',     n, 0 );
      LF_Set( 6, '#Ort',            n, 0 );
      LF_Set( 7, '@Ver.Telefon1',   n, 0 );
      LF_Set( 8, '@Ver.Telefon2',   n, 0 );
      LF_Set( 9, '@Ver.Telefax',    n, 0 );
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

  FOR  Erx # RecRead( 110, 1, _recFirst );
  LOOP Erx # RecRead( 110, 1, _recNext );
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