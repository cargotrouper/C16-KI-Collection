@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Usr_800002
//                  OHNE E_R_G
//  Info
//        Liste: Vorgaben / Rechte
//
//  19.11.2009  PW  Erstellung der Prozedur
//  24.03.2010  PW  Neuer Listenstil
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
      List_Spacing[ 3] # 170.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',               y, 0 );
      LF_Set( 2, 'Rechtebezeichnung', n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Gv.Int.01',   y, _LF_IntNG );
      LF_Set( 2, '@Gv.Alpha.01', n, 0 );
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
  vTree  : handle;
  vItem  : handle;
  vText  : handle;
  vLines : int;
  vLine  : int;
  vA     : alpha(250);
  vX     : int;
end;
begin
  /* Datenbaum */
  vTree  # CteOpen( _cteTreeCI );
  vText  # TextOpen( 3 );
  vText->TextRead( 'Def_Rights', _textProc );
  vLines # vText->TextInfo( _textLines );

  FOR  vLine # 0;
  LOOP vLine # vLine + 1;
  WHILE ( vLine < vLines ) DO BEGIN
    vA # vText->TextLineRead( vLine, 0 );
    if ( StrFind( StrCnv( vA, _strUpper ), 'RGT_', 0 ) != 0 ) then begin
      vX # StrFind( vA, ':', 0 );
      vX # CnvIA( StrCut( vA, vX + 1, StrFind( vA, '//', 0 ) - vX ) );
      vA # StrCut( vA, StrFind( vA, '//', 0 ) + 3, StrLen( vA ) );
      Sort_ItemAdd( vTree, vA + '|', 999, vX );
    end;
  END;
  vText->TextClose();


  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  FOR  vItem # Sort_ItemFirst( vTree );
  LOOP vItem # Sort_ItemNext( vTree, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    Gv.Alpha.01 # StrCut( vItem->spName, 1, StrFind( vItem->spName, '|', 0 ) - 1 );
    Gv.Int.01   # vItem->spId;

    LF_Print( lf_Line );
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  Sort_KillList( vTree );
end;

//=========================================================================
//=========================================================================