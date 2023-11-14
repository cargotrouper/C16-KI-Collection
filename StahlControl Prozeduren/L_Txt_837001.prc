@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Txt_837001
//                    OHNE E_R_G
//  Info
//        Liste: Vorgaben / Texte
//
//  22.03.2005  TM  Erstellung der Prozedur
//  24.03.2010  PW  Neuer Listenstil
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
  lf_Entry  : handle;
  lf_End    : handle;
  lf_Line   : handle;
  lf_Divide : handle;
  vText     : alpha(250);
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
      List_Spacing[ 3] # List_Spacing[ 2] + 20.0;
      List_Spacing[ 4] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',         y, 0 );
      LF_Set( 2, 'Bereich',     n, 0 );
      LF_Set( 3, 'Bezeichnung', n, 0 );
    end;

    'entry' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Txt.Nummer',        y, _LF_IntNG );
      LF_Set( 2, '@Txt.Bereichstring', n, 0 );
      LF_Set( 3, '@Txt.Bezeichnung',   n, 0 );
    end;

    'end' : begin
      if ( !aPrint ) then
        LF_Format( _LF_Underline );
    end;

    'line' : begin
      if ( aPrint ) then begin
        LF_Text( 1, vText );
        RETURN;
      end;

      List_Spacing[ 1] #  15.0;
      List_Spacing[ 2] # 190.0;

      LF_Set( 1, '#Text', n, 0 );
    end;

    'divide' : begin
      if ( !aPrint ) then
        LF_Set( 0, '##LINE##', y, 1, 2 ); // Linie
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
  vTxt1   : handle;
  vTxt2   : handle;
  vLines  : int;
  vLine   : int;
end;
begin
  lf_Empty  # LF_NewLine( '' );
  lf_Header # LF_NewLine( 'header' );
  lf_Entry  # LF_NewLine( 'entry' );
  lf_End    # LF_NewLine( 'end' );
  lf_Line   # LF_NewLine( 'line' );
  lf_Divide # LF_NewLine( 'divide' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  vTxt1 # TextOpen( 32 );
  vTxt2 # TextOpen( 32 );

  FOR  Erx # RecRead( 837, 1, _recFirst );
  LOOP Erx # RecRead( 837, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_Entry );
    Lib_Texte:TxtLoad5Buf( '~837.' + CnvAI( Txt.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8 ), vTxt1, vTxt2, 0, 0, 0 );

    // Text 1
    vLines # vTxt1->TextInfo( _textLines );
    FOR  vLine # 1;
    LOOP vLine # vLine + 1;
    WHILE ( vLine <= vLines ) DO BEGIN
      vText # vTxt1->TextLineRead( vLine, 0 );
      LF_Print( lf_Line );
    END;

    // Text 2
    vLines # vTxt2->TextInfo( _textLines );
    if ( vLines > 0 ) then begin
      LF_Print( lf_Divide );
      FOR  vLine # 1;
      LOOP vLine # vLine + 1;
      WHILE ( vLine <= vLines ) DO BEGIN
        vText # vTxt2->TextLineRead( vLine, 0 );
        LF_Print( lf_Line );
      END;
    end;

    LF_Print( lf_Empty );
    LF_Print( lf_End );
  END;

  vTxt1->TextClose();
  vTxt2->TextClose();

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Entry );
  LF_FreeLine( lf_End );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Divide );
end;

//=========================================================================
//=========================================================================