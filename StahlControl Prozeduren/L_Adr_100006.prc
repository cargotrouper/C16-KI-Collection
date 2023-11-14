@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Adr_100006
//                    OHNE E_R_G
//  Info
//        Liste: Adressen / markierte Adressen für Briefe
//
//  24.11.2010  PW  Erstellung
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    sub Element ( aName : alpha; aPrint : logic );
//    sub SeitenKopf ( aSeite : int );
//    sub SeitenFuss ( aSeite : int );
//    sub StartList ( aSort : int; aSortName : alpha );
//
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
  gSelected # 0;
  StartList( 0, '' );
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
local begin
  vPrefix : alpha;
end;
begin
  case aName of
    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[1] # 25.0;
      list_Spacing[2] # 50.0;
      list_Spacing[3] # 35.0;
      list_Spacing[4] # 45.0;
      list_Spacing[5] # 40.0;
      list_Spacing[6] # 20.0;
      Lib_List2:ConvertWidthsToSpacings( 7, 277.0 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Anrede',      n, 0 );
      LF_Set( 2, 'Name',        n, 0 );
      LF_Set( 3, 'Zusatz',      n, 0 );
      LF_Set( 4, 'Straße',      n, 0 );
      LF_Set( 5, 'Ort',         n, 0 );
      LF_Set( 6, 'Postfach',    n, 0 );
      LF_Set( 7, 'Briefanrede', n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        if ( Adr.LKZ != '' ) and ( Adr.LKZ != 'D' ) then
          vPrefix # Adr.LKZ + ' ';
        else
          vPrefix # '';

        if ( Adr.PLZ != '' ) or ( Adr.Ort != '' ) then
          LF_Text( 5, vPrefix + Adr.PLZ + ' ' + Adr.Ort );
        else
          LF_Text( 5, '' );

        if ( Adr.Postfach != '' ) then
          LF_Text( 6, vPrefix + Adr.Postfach.PLZ + ' / ' + Adr.Postfach );
        else
          LF_Text( 6, '' );

        RETURN;
      end;

      LF_Set( 1, '@Adr.Anrede',      n, 0 );
      LF_Set( 2, '@Adr.Name',        n, 0 );
      LF_Set( 3, '@Adr.Zusatz',      n, 0 );
      LF_Set( 4, '@Adr.Straße',      n, 0 );
      LF_Set( 5, '#Ort',             n, 0 );
      LF_Set( 6, '#Postfach',        n, 0 );
      LF_Set( 7, '@Adr.Briefanrede', n, 0 );
    end;
  end;
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf der Liste
//=========================================================================
sub SeitenKopf ( aSeite : int );
begin
  if ( !list_XML ) then begin
    WriteTitel();
    LF_Print( lf_Empty );
  end;

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
  Erx       : int;
  vPrgr     : handle;
  vSel      : int;
  vSelName  : alpha;
end;
begin
  /* Selektion */
  Lib_Sel:IntersectMark( var vSel, var vSelName, 100, 1 ); // nur markierte

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  vPrgr # Lib_Progress:Init( 'Listengenerierung', RecInfo( 100, _recCount, vSel ) );
  FOR  Erx # RecRead( 100, vSel, _recFirst );
  LOOP Erx # RecRead( 100, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) and ( vPrgr->Lib_Progress:Step() ) DO BEGIN
    LF_Print( lf_Line );
  END;

  /* Cleanup */
  vPrgr->Lib_Progress:Term();
  vSel->SelClose();
  SelDelete( 100, vSelName );

  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
end;

//=========================================================================
//=========================================================================