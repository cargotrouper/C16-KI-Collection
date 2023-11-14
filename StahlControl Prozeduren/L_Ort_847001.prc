@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Ort_847001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Orte
//
//  15.07.2008  PW  Erstellung der Prozedur
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
      List_Spacing[ 3] # List_Spacing[ 2] + 12.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 90.0;
      List_Spacing[ 5] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'LKZ',        y, 0 );
      LF_Set( 2, 'PLZ',        y, 0 );
      LF_Set( 3, 'Name',       n, 0 );
      LF_Set( 4, 'Bundesland', n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Ort.LKZ',        y, 0 );
      LF_Set( 2, '@Ort.PLZ',        y, 0 );
      LF_Set( 3, '@Ort.Name',       n, 0 );
      LF_Set( 4, '@Ort.Bundesland', n, 0 );
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

  vPrgr # Lib_Progress:Init( 'Listengenerierung', RecInfo( 847, _recCount ) );
  FOR  Erx # RecRead( 847, 1, _recFirst );
  LOOP Erx # RecRead( 847, 1, _recNext );
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