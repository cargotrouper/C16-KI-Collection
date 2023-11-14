@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Usr_800001
//                  OHNE E_R_G
//  Info
//        Liste: Vorgaben / User
//
//  08.10.2007  MS  Erstellung der Prozedur
//  24.03.2010  PW  Neuer Listenstil
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
      List_Spacing[ 2] # List_Spacing[ 1] + 30.0;
      List_Spacing[ 3] # List_Spacing[ 2] + 32.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 32.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 30.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 30.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 35.0;
      List_Spacing[ 8] # List_Spacing[ 7] + 70.0;
      List_Spacing[ 9] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Username',  n, 0 );
      LF_Set( 2, 'Name',      n, 0 );
      LF_Set( 3, 'Vorname',   n, 0 );
      LF_Set( 4, 'Telefon',   n, 0 );
      LF_Set( 5, 'Telefax',   n, 0 );
      LF_Set( 6, 'Abteilung', n, 0 );
      LF_Set( 7, 'E-Mail',    n, 0 );
      LF_Set( 8, 'PersID',    y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Usr.Username',   n, 0 );
      LF_Set( 2, '@Usr.Name',       n, 0 );
      LF_Set( 3, '@Usr.Vorname',    n, 0 );
      LF_Set( 4, '@Usr.Telefonnr',  n, 0 );
      LF_Set( 5, '@Usr.Telefaxnr',  n, 0 );
      LF_Set( 6, '@Usr.Abteilung',  n, 0 );
      LF_Set( 7, '@Usr.eMail',      n, 0 );
      LF_Set( 8, '@Usr.PersonalID', y, _LF_IntNG );
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

  FOR   Erx # RecRead( 800, 1, _recFirst );
  LOOP  Erx # RecRead( 800, 1, _recNext );
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