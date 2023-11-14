@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_KalTage_164001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Kalendertage
//
//  23.08.2007  MS  Erstellung der Prozedur
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
      List_Spacing[ 2] # List_Spacing[ 1] + 20.0;
      List_Spacing[ 3] # List_Spacing[ 2] + 35.0;
      List_Spacing[ 4] # List_Spacing[ 3] + 15.0;
      List_Spacing[ 5] # List_Spacing[ 4] + 15.0;
      List_Spacing[ 6] # List_Spacing[ 5] + 15.0;
      List_Spacing[ 7] # List_Spacing[ 6] + 15.0;
      List_Spacing[ 8] # List_Spacing[ 7] + 15.0;
      List_Spacing[ 9] # List_Spacing[ 8] + 15.0;
      List_Spacing[10] # List_Spacing[ 9] + 15.0;
      List_Spacing[11] # List_Spacing[10] + 15.0;
      List_Spacing[12] # List_Spacing[11] + 15.0;
      List_Spacing[13] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Tagestyp',    n, 0 );
      LF_Set( 2, 'Bezeichnung', n, 0 );
      LF_Set( 3, 'Von-Bis',     n, 0 );
      LF_Set( 4, 'Von-Bis',     n, 0 );
      LF_Set( 5, 'Von-Bis',     n, 0 );
      LF_Set( 6, 'Von-Bis',     n, 0 );
      LF_Set( 7, 'Von-Bis',     n, 0 );
      LF_Set( 8, 'Von-Bis',     n, 0 );
      LF_Set( 9, 'Von-Bis',     n, 0 );
      LF_Set(10, 'Von-Bis',     n, 0 );
      LF_Set(11, 'Von-Bis',     n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        Lf_text(3, cnvat(Rso.Kal.Tag.Von1Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis1Zeit));
        Lf_text(4, cnvat(Rso.Kal.Tag.Von2Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis2Zeit));
        Lf_text(5, cnvat(Rso.Kal.Tag.Von3Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis3Zeit));
        Lf_text(6, cnvat(Rso.Kal.Tag.Von4Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis4Zeit));
        Lf_text(7, cnvat(Rso.Kal.Tag.Von5Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis5Zeit));
        Lf_text(8, cnvat(Rso.Kal.Tag.Von6Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis6Zeit));
        Lf_text(9, cnvat(Rso.Kal.Tag.Von7Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis7Zeit));
        Lf_text(10,cnvat(Rso.Kal.Tag.Von8Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis8Zeit));
        Lf_text(11,cnvat(Rso.Kal.Tag.Von9Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis9Zeit));
        RETURN;
      end;

      LF_Set( 1, '@Rso.Kal.Tag.Typ',    n, 0 );
      LF_Set( 2, '@Rso.Kal.Tag.Name',   n, 0 );
      LF_Set( 3, '#vonbis', n, 0 );
      LF_Set( 4, '#vonbis', n, 0 );
      LF_Set( 5, '#vonbis', n, 0 );
      LF_Set( 6, '#vonbis', n, 0 );
      LF_Set( 7, '#vonbis', n, 0 );
      LF_Set( 8, '#vonbis', n, 0 );
      LF_Set( 9, '#vonbis', n, 0 );
      LF_Set(10, '#vonbis', n, 0 );
      LF_Set(11, '#vonbis', n, 0 );
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

  FOR   Erx # RecRead( 164, 1, _recFirst );
  LOOP  Erx # RecRead( 164, 1, _recNext );
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