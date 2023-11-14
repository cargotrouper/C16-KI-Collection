@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Rso_160004
//                    OHNE E_R_G
//  Info
//        Liste: Ressourcen / Ausfallzeiten
//
//  21.07.2010  PW  Erstellung
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    sub AusSel ();
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

  gZeit  : float;
  gDatum : date;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.von.Datum # today; // Datum von
  Sel.von.Datum->vmMonthModify( -6 );
  Sel.bis.Datum # today; // Datum bis
  Gv.Int.11     # 0; // Gruppe von
  Gv.Int.12     # 0; // Gruppe bis
  Gv.Int.13     # 0; // Nummer von
  Gv.Int.14     # 0; // Nummer bis

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.160004', here + ':AusSel' );
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow( gMDI );
end;


//=========================================================================
// AusSel
//        Seitenkopf der Liste
//=========================================================================
sub AusSel ();
begin
  gSelected # 0;
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

      // Spaltenbreiten
      list_Spacing[ 1] # 10.0; // Grp
      list_Spacing[ 2] # 10.0; // Nr.
      list_Spacing[ 3] # 40.0; // Maschine
      list_Spacing[ 4] # 25.0; // Ausfallzeit
      list_Spacing[ 5] # 15.0; // Ausfallkosten
      list_Spacing[ 6] # 40.0; // zuletzt am
      Lib_List2:ConvertWidthsToSpacings( 6, 190.0 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Grp.',          y, 0 );
      LF_Set( 2, 'Nr.',           y, 0 );
      LF_Set( 3, 'Maschine',      n, 0 );
      LF_Set( 4, 'Ausfallzeit',   y, 0 );
      LF_Set( 5, 'Kosten',        y, 0 );
      LF_Set( 6, 'zuletzt am',    n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        LF_Text( 4, ANum( gZeit, 2 ) );
        LF_Text( 5, ANum( gZeit * Rso.PreisProAusfallH, 2 ) );
        LF_Text( 6, CnvAD( gDatum ) );

        RETURN;
      end;

      LF_Set( 1, '@Rso.Gruppe',     y, _LF_IntNG );
      LF_Set( 2, '@Rso.Nummer',     y, _LF_IntNG );
      LF_Set( 3, '@Rso.Stichwort',  n, 0 );
      LF_Set( 4, '#Ausfallzeit',    y, _LF_Num );
      LF_Set( 5, '#Ausfallkosten',  y, _LF_Wae );
      LF_Set( 6, '#Rso.IHA.Termin', n, 0 );
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
  vPrgr     : handle;
  vSel      : int;
  vSelName  : alpha;
  vSelQ     : alpha(1000);
  vRsoGrp   : int;
  vRsoNum   : int;
  vRsoUrs   : int;
  vRecId    : int;
  vKey      : alpha;
end;
begin
  /* Selektion */
  if ( Gv.Int.11 != 0 ) or ( Gv.Int.12 != 0 ) then
    Lib_Sel:QVonBisI( var vSelQ, 'Rso.Gruppe', Gv.Int.11, Gv.Int.12 );
  if ( Gv.Int.13 != 0 ) or ( Gv.Int.14 != 0 ) then
    Lib_Sel:QVonBisI( var vSelQ, 'Rso.Nummer', Gv.Int.13, Gv.Int.14 );

  vSel # SelCreate( 160, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  BEGIN_BLOCK
    vPrgr  # Lib_Progress:Init( 'Listengenerierung', RecInfo( 160, _recCount, vSel ) );

    FOR  Erx # RecRead( 160, vSel, _recFirst );
    LOOP Erx # RecRead( 160, vSel, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then
        BREAK;

      gZeit  # 0.0
      gDatum # 0.0.0;

      FOR  Erx # RecLink( 165, 160, 1, _recFirst );
      LOOP Erx # RecLink( 165, 160, 1, _recNext );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        if ( Rso.IHA.Termin != 0.0.0 ) and ( Rso.IHA.Termin < Sel.von.Datum or Rso.IHA.Termin > Sel.bis.Datum ) then
          CYCLE;

        gZeit  # gZeit + Rso.IHA.Zeit.Ausfall;
        gDatum # max( gDatum, Rso.IHA.Termin );
      END;

      LF_Print( lf_Line );
    END;

    vSel->SelClose();
    SelDelete( 160, vSelName );

    if ( Erx <= _rLocked ) then
      BREAK;
  END_BLOCK;

  /* Cleanup */
  vPrgr->Lib_Progress:Term();

  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
end;

//=========================================================================
//=========================================================================