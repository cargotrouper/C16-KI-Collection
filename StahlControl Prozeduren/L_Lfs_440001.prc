@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Lfs_440001
//                    OHNE E_R_G
//  Info
//        Liste: Lieferscheine Rückstände
//
//  03.01.2007  AI  Erstellung der Prozedur(L_OfP_460001)
//  19.04.2007  NH  Übernahme für L_Lfs_440001
//  30.03.2010  PW  Neuer Listenstil
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
  lf_Adr    : handle;
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
local begin
  vA : alpha;
end;
begin
  case aName of
    'adresse' : begin
      if ( aPrint ) then
        RETURN;

      LF_Format( _LF_Bold );
      LF_Set( 1, '@Adr.Stichwort', n, 0 );
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 30.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 20.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 15.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 27.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 15.0;
      list_Spacing[ 7] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Kommission',   n, 0 );
      LF_Set( 2, 'Endtermin',    y, 0 );
      LF_Set( 3, 'Stück',        y, 0 );
      LF_Set( 4, 'Nettogewicht', y, 0 );
      LF_Set( 5, 'Lfs.Nr.',      y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Lfs.P.Kommission',    n, 0 );
      LF_Set( 2, '@BAG.P.Plan.EndDat',   y, 0 );
      LF_Set( 3, '@Lfs.P.Stück',         y, _LF_Int );
      LF_Set( 4, '@Lfs.P.Gewicht.Netto', y, _LF_Num3, Set.Stellen.Gewicht );
      LF_Set( 5, '@Lfs.P.Nummer',        y, _LF_IntNG );
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
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vSelQ     : alpha(500);
  vLastKom  : int;
end;
begin
  /* Selektion */
  Lib_Sel:QFloat( var vSelQ, 'Lfs.P.Gewicht.Netto', '!=', 0.0 );
  Lib_Sel:QDate( var vSelQ, 'Lfs.P.Datum.Verbucht', '=', 0.0.0 );
  Lib_Sel:QInt( var vSelQ, 'Lfs.P.Stück', '!=', 0 );

  vSel # SelCreate( 441, 2 );
  vSel->SelDefQuery( '', vSelQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Adr    # LF_NewLine( 'adresse' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );
  vLastKom # -1;

  FOR  Erx # RecRead( 441, vSel, _recFirst );
  LOOP Erx # RecRead( 441, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( Lfs.P.Auftragsnr != vLastKom ) then begin
      if ( vLastKom != -1 ) then
        LF_Print( lf_Empty );

      if ( RecLink( 100, 441, 7, _recFirst ) > _rLocked ) then begin
        RecBufClear( 100 );
        Adr.Stichwort # '?';
      end;

      LF_Print( lf_Adr );
      vLastKom # Lfs.P.Auftragsnr;
    end;

    if ( RecLink( 702, 441, 9, _recFirst ) > _rLocked ) then
      RecBufClear( 702 );

    LF_Print( lf_Line );
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Adr );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );

  vSel->SelClose();
  SelDelete( 441, vSelName );
end;

//=========================================================================
//=========================================================================