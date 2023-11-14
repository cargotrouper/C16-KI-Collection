@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_ZaB_816001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Zahlungsbedingungen
//
//  22.03.2005  TM  Erstellung der Prozedur
//  03.11.2008  PW  Überarbeitung
//  23.03.2010  PW  Neuer Listenstil
//  13.04.2010  PW  Anpassung für neue Zahlungsbedingungen
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
  lf_SktA   : handle;
  lf_SktB   : handle;
  lf_Bez1_1 : handle;
  lf_Bez1_2 : handle;
  lf_Bez1_3 : handle;
  lf_Bez1_4 : handle;
  lf_Bez1_5 : handle;
  lf_Bez2_1 : handle;
  lf_Bez2_2 : handle;
  lf_Bez2_3 : handle;
  lf_Bez2_4 : handle;
  lf_Bez2_5 : handle;
  lf_End    : handle;
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

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] +  10.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 182.0;
      list_Spacing[ 4] # list_Spacing[ 3] +  35.0;
      list_Spacing[ 5] # list_Spacing[ 4] +  15.0;
      list_Spacing[ 6] # list_Spacing[ 5] +  35.0;
      list_Spacing[ 7] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',           y, 0 );
      LF_Set( 2, 'Bezeichnungen', n, 0 );
      LF_Set( 3, 'Fälligkeit',    n, 0 );
      LF_Set( 4, 'Proz.',         y, 0 );
      LF_Set( 5, 'Skonto',        n, 0 );
    end;

    'end' : begin
      if ( !aPrint ) then
        LF_Format( _LF_Underline );
    end;

    'skontoA' : begin
      if ( aPrint ) then begin
        LF_Text( 2, 'Rechnungszeitraum A: ' + AInt( ZaB.Sknt1.VonTag ) + ' - ' + AInt( ZaB.Sknt1.BisTag ) );

        if ( "ZaB.Fällig1.FixTag" != 0 ) then
          LF_Text( 3, CnvAI( "ZaB.Fällig1.FixTag" ) + '. Tag / ' + CnvAI( "ZaB.Fällig1.FixMonat" ) + '. Monat' );
        else
          LF_Text( 3, CnvAI( "ZaB.Fällig1.Zieltage" ) + ' Tage' );

        if ( "ZaB.Sknt1.FixTag" != 0 ) then
          LF_Text( 5, CnvAI( "ZaB.Sknt1.FixTag" ) + '. Tag / ' + CnvAI( "ZaB.Sknt1.ZielMonat" ) + '. Monat' );
        else if ( "ZaB.Sknt1.VorZielYN" ) then
          LF_Text( 5, CnvAI( "ZaB.Sknt1.Tage" ) + ' Tage v.Z.' );
        else
          LF_Text( 5, CnvAI( "ZaB.Sknt1.Tage" ) + ' Tage' );

        RETURN;
      end;

      LF_Set( 2, '#Info',              n, 0 );
      LF_Set( 3, '#Fälligkeit',        n, 0 );
      LF_Set( 4, '@ZaB.Sknt1.Prozent', y, _LF_Num, 2 );
      LF_Set( 5, '#Skonto',            n, 0 );
    end;

    'skontoB' : begin
      if ( aPrint ) then begin
        LF_Text( 2, 'Rechnungszeitraum B: ' + AInt( ZaB.Sknt2.VonTag ) + ' - ' + AInt( ZaB.Sknt2.BisTag ) );

        if ( "ZaB.Fällig2.FixTag" != 0 ) then
          LF_Text( 3, CnvAI( "ZaB.Fällig2.FixTag" ) + '. Tag / ' + CnvAI( "ZaB.Fällig2.FixMonat" ) + '. Monat' );
        else
          LF_Text( 3, CnvAI( "ZaB.Fällig2.Zieltage" ) + ' Tage' );

        if ( "ZaB.Sknt2.FixTag" != 0 ) then
          LF_Text( 5, CnvAI( "ZaB.Sknt2.FixTag" ) + '. Tag / ' + CnvAI( "ZaB.Sknt2.ZielMonat" ) + '. Monat' );
        else if ( "ZaB.Sknt2.VorZielYN" ) then
          LF_Text( 5, CnvAI( "ZaB.Sknt2.Tage" ) + ' Tage v.Z.' );
        else
          LF_Text( 5, CnvAI( "ZaB.Sknt2.Tage" ) + ' Tage' );

        RETURN;
      end;

      LF_Set( 2, '#Info',              n, 0 );
      LF_Set( 3, '#Fälligkeit',        n, 0 );
      LF_Set( 4, '@ZaB.Sknt1.Prozent', y, _LF_Num, 2 );
      LF_Set( 5, '#Skonto',            n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        if ( ZaB.IndividuellYN and ZaB.SperreYN ) then
          vA # ', individuell, Sperre';
        else if ( ZaB.IndividuellYN ) then
          vA # ', individuell';
        else if ( ZaB.SperreYN ) then
          vA # ', Sperre';
        else
          vA # '';
        if ( ZaB.abRechDatumYN ) then
          LF_Text( 3, 'ab Rechnungsdatum' + vA );
        else if ( ZaB.abLFSDatumYN ) then
          LF_Text( 3, 'ab Lieferdatum' + vA );

        RETURN;
      end;

      list_Spacing[ 4] # 277.0;
      LF_Set( 1, '@ZaB.Nummer',           y, _LF_IntNG );
      LF_Set( 2, '@ZaB.Kurzbezeichnung',  n, 0 );
      LF_Set( 3, '#Typ',                  n, 0 );
    end;


    // Bezeichnungen
    'bez1_2' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung1.L2', n, 0 );
    end;

    'bez1_1' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung1.L1', n, 0 );
    end;

    'bez1_3' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung1.L3', n, 0 );
    end;

    'bez1_4' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung1.L4', n, 0 );
    end;

    'bez1_5' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung1.L5', n, 0 );
    end;

    'bez2_1' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung2.L1', n, 0 );
    end;

    'bez2_2' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung2.L2', n, 0 );
    end;

    'bez2_3' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung2.L3', n, 0 );
    end;

    'bez2_4' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung2.L4', n, 0 );
    end;

    'bez2_5' : begin
      if ( !aPrint ) then
        LF_Set( 2, '@ZaB.Bezeichnung2.L5', n, 0 );
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
  lf_SktA   # LF_NewLine( 'skontoA' );
  lf_SktB   # LF_NewLine( 'skontoB' );
  lf_Line   # LF_NewLine( 'line' );
  lf_Bez1_1 # LF_NewLine( 'bez1_1' );
  lf_Bez1_2 # LF_NewLine( 'bez1_2' );
  lf_Bez1_3 # LF_NewLine( 'bez1_3' );
  lf_Bez1_4 # LF_NewLine( 'bez1_4' );
  lf_Bez1_5 # LF_NewLine( 'bez1_5' );
  lf_Bez2_1 # LF_NewLine( 'bez2_1' );
  lf_Bez2_2 # LF_NewLine( 'bez2_2' );
  lf_Bez2_3 # LF_NewLine( 'bez2_3' );
  lf_Bez2_4 # LF_NewLine( 'bez2_4' );
  lf_Bez2_5 # LF_NewLine( 'bez2_5' );
  lf_End    # LF_NewLine( 'end' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  FOR   Erx # RecRead( 816, 1, _recFirst );
  LOOP  Erx # RecRead( 816, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_Line );

    if ( ZaB.Sknt1.VonTag != 0 and ZaB.Sknt1.BisTag != 0 ) then
      LF_Print( lf_SktA );
    if ( ZaB.Sknt2.VonTag != 0 and ZaB.Sknt2.BisTag != 0 ) then
      LF_Print( lf_SktB );

    LF_Print( lf_Empty );


    // Bezeichnungen
    if ( ZaB.Bezeichnung1.L1 != '' ) then
      LF_Print( lf_Bez1_1 );
    if ( ZaB.Bezeichnung2.L1 != '' ) then
      LF_Print( lf_Bez2_1 );
    if ( ZaB.Bezeichnung1.L2 != '' ) then
      LF_Print( lf_Bez1_2 );
    if ( ZaB.Bezeichnung2.L2 != '' ) then
      LF_Print( lf_Bez2_2 );
    if ( ZaB.Bezeichnung1.L3 != '' ) then
      LF_Print( lf_Bez1_3 );
    if ( ZaB.Bezeichnung2.L3 != '' ) then
      LF_Print( lf_Bez2_3 );
    if ( ZaB.Bezeichnung1.L4 != '' ) then
      LF_Print( lf_Bez1_4 );
    if ( ZaB.Bezeichnung2.L4 != '' ) then
      LF_Print( lf_Bez2_4 );
    if ( ZaB.Bezeichnung1.L5 != '' ) then
      LF_Print( lf_Bez1_5 );
    if ( ZaB.Bezeichnung2.L5 != '' ) then
      LF_Print( lf_Bez2_5 );

    LF_Print( lf_End );
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_SktA );
  LF_FreeLine( lf_SktB );
  LF_FreeLine( lf_Bez1_1 );
  LF_FreeLine( lf_Bez1_2 );
  LF_FreeLine( lf_Bez1_3 );
  LF_FreeLine( lf_Bez1_4 );
  LF_FreeLine( lf_Bez1_5 );
  LF_FreeLine( lf_Bez2_1 );
  LF_FreeLine( lf_Bez2_2 );
  LF_FreeLine( lf_Bez2_3 );
  LF_FreeLine( lf_Bez2_4 );
  LF_FreeLine( lf_Bez2_5 );
  LF_FreeLine( lf_End );
end;

//=========================================================================
//=========================================================================