@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Lst_910001
//                    OHNE E_R_G
//  Info
//        Liste: Vorgaben / Listen
//
//  08.10.2007  MS  Erstellung der Prozedur
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
  g_Buffer  : handle;
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
      List_Spacing[ 3] # List_Spacing[ 2] + 50.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 60.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 84.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 30.0;
      List_Spacing[ 7] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',          y, 0 );
      LF_Set( 2, 'Bereich',      n, 0 );
      LF_Set( 3, 'Name',         n, 0 );
      LF_Set( 4, 'Beschreibung', n, 0 );
      LF_Set( 5, 'Listenformat', n, 0 );
      LF_Set( 6, 'Prozedur',     n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        Gv.Int.01   # g_Buffer->Lfm.Nummer;
        Gv.Alpha.01 # g_Buffer->Lfm.Bereich;
        Gv.Alpha.02 # g_Buffer->Lfm.Name;
        Gv.Alpha.03 # g_Buffer->Lfm.Beschreibung;
        Gv.Alpha.04 # g_Buffer->Lfm.Listenformat;
        Gv.Alpha.05 # g_Buffer->Lfm.Prozedur;
        RETURN;
      end;

      LF_Set( 1, '@Gv.Int.01',   y, _LF_IntNG );
      LF_Set( 2, '@Gv.Alpha.01', n, 0 );
      LF_Set( 3, '@Gv.Alpha.02', n, 0 );
      LF_Set( 4, '@Gv.Alpha.03', n, 0 );
      LF_Set( 5, '@Gv.Alpha.04', n, 0 );
      LF_Set( 6, '@Gv.Alpha.05', n, 0 );
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
  Erx     : int;
  vBuf    : handle;
end;
begin
  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  g_Buffer  # RecBufCreate( 910 );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  FOR   Erx # RecRead( g_Buffer, 1, _recFirst );
  LOOP  Erx # RecRead( g_Buffer, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if(g_Buffer -> Lfm.InaktivYN = true) then // inaktive ueberspringen!
      CYCLE;

    LF_Print( lf_Line );
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  RecBufDestroy( g_Buffer );
end;

//=========================================================================
//=========================================================================