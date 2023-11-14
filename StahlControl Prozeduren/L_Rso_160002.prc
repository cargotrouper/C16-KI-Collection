@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Rso_160002
//                    OHNE E_R_G
//  Info
//        Liste: Ressourcen / Ersatzteile Hitliste
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
  lf_Empty    : handle;
  lf_Maschine : handle;
  lf_Header   : handle;
  lf_Line     : handle;

  gPos   : int;
  gMenge : float;
  gPreis : float;
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

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.160002', here + ':AusSel' );
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
    'maschine' : begin
      if ( aPrint ) then begin
        LF_Text( 2, AInt( Rso.Gruppe ) + '/' + AInt( Rso.Nummer ) + ' ' + Rso.Stichwort );

        RETURN;
      end;

      // Spaltenbreiten
      list_Spacing[ 1] # 20.0;
      Lib_List2:ConvertWidthsToSpacings( 2, 190.0 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Bold );
      LF_Set( 1, 'Maschine:', n, 0 );
      LF_Set( 2, '#Maschine', n, 0 );
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      // Spaltenbreiten
      list_Spacing[ 1] # 10.0; // Pos.
      list_Spacing[ 2] # 12.5; // Wgr.
      list_Spacing[ 3] # 15.0; // Art.Nr.
      list_Spacing[ 4] # 87.5; // Bezeichnung
      list_Spacing[ 5] # 20.0; // Menge
      list_Spacing[ 6] # 15.0; // Preis
      list_Spacing[ 7] # 30.0; // letzte Nutzung
      Lib_List2:ConvertWidthsToSpacings( 7, 190.0 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Pos.',           y, 0 );
      LF_Set( 2, 'Wgr.',           y, 0 );
      LF_Set( 3, 'Art.Nr.',        y, 0 );
      LF_Set( 4, 'Bezeichnung',    n, 0 );
      LF_Set( 5, 'Menge',          y, 0 );
      LF_Set( 6, 'Preis',          y, 0 );
      LF_Set( 7, 'letzte Nutzung', n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        if ( RecLink( 180, 168, 1, _recFirst ) > _rLocked ) then
          RecBufClear( 180 );

        LF_Text( 1, AInt( gPos ) );
        LF_Text( 5, ANum( gMenge, 2 ) );
        LF_Text( 6, ANum( gPreis, 2 ) );

        RETURN;
      end;

      LF_Set( 1, '#Pos.',             y, _LF_IntNG );
      LF_Set( 2, '@HuB.Warengruppe',  y, _LF_IntNG );
      LF_Set( 3, '@HuB.Artikelnr',    y, _LF_IntNG );
      LF_Set( 4, '@HuB.Bezeichnung1', n, 0 );
      LF_Set( 5, '#Menge',            y, _LF_Num );
      LF_Set( 6, '#Preis',            y, _LF_Wae );
      LF_Set( 7, '@Rso.ErT.Datum',    n, _LF_Date );
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
  vTree     : handle;
  vTree2    : handle;
  vItem     : handle;
  vRsoGrp   : int;
  vRsoNum   : int;
  vRsoErT   : alpha;
  vRecId    : int;
  vKey      : alpha;
end;
begin
  /* Selektion */
  vSelQ # '( "Rso.ErT.Datum" = 0.0.0';
  Lib_Sel:QVonBisD( var vSelQ, 'Rso.ErT.Datum', Sel.von.Datum, Sel.bis.Datum, 'OR' );
  vSelQ # vSelQ + ' )'

  if ( Gv.Int.11 != 0 ) or ( Gv.Int.12 != 0 ) then
    Lib_Sel:QVonBisI( var vSelQ, 'Rso.ErT.Gruppe', Gv.Int.11, Gv.Int.12 );
  if ( Gv.Int.13 != 0 ) or ( Gv.Int.14 != 0 ) then
    Lib_Sel:QVonBisI( var vSelQ, 'Rso.ErT.Ressource', Gv.Int.13, Gv.Int.14 );

  vSel # SelCreate( 168, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  /* Datenbaum */
  BEGIN_BLOCK
    vPrgr  # Lib_Progress:Init( 'Datenerfassung', RecInfo( 168, _recCount, vSel ) );
    vTree2 # CteOpen( _cteTreeCI );

    FOR  Erx # RecRead( 168, vSel, _recFirst );
    LOOP Erx # RecRead( 168, vSel, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then
        BREAK;

      vKey # CnvAI( Rso.ErT.Gruppe, _fmtNumLeadZero, 0, 4 ) + CnvAI( Rso.ErT.Ressource, _fmtNumLeadZero, 0, 4 );
      Sort_ItemAdd( vTree2, vKey + '||' + Rso.ErT.Artikelnr + '||', 168, RecInfo( 168, _recId ) );
    END;

    vSel->SelClose();
    SelDelete( 168, vSelName );

    if ( Erx <= _rLocked ) then begin
      Sort_KillList( vTree2 );
      RETURN;
    end;
  END_BLOCK;

  BEGIN_BLOCK
    vPrgr->Lib_Progress:Reset( 'Sortierung', CteInfo( vTree2, _cteCount ) );
    vTree # CteOpen( _cteTreeCI );

    FOR  vItem # Sort_ItemFirst( vTree2 );
    LOOP vItem # Sort_ItemNext( vTree2, vItem );
    WHILE ( vItem != 0 ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then
        BREAK;

      RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );

      if ( vRsoGrp != Rso.ErT.Gruppe ) or ( vRsoNum != Rso.ErT.Ressource ) or ( vRsoErT != Rso.ErT.Artikelnr ) then begin
        if ( vRsoGrp != 0 ) and ( vRsoNum != 0 ) and ( vRsoErT != '' ) then begin
          vKey # CnvAI( vRsoGrp, _fmtNumLeadZero, 0, 4 ) + CnvAI( vRsoNum, _fmtNumLeadZero, 0, 4 );
          vKey # vKey + '||' + CnvAF( 10000000000.0 - gMenge, _fmtNumLeadZero, 0, 15 );
          Sort_ItemAdd( vTree, vKey + '||' + CnvAF( gMenge ) + '||' + CnvAF( gPreis ) + '||', 168, vRecId );
        end;

        gMenge # 0.0;
        gPreis # 0.0;
        gDatum # 0.0.0;
        vRecId # 0;
      end;

      if ( Rso.ErT.Datum >= gDatum ) then begin
        gDatum # Rso.ErT.Datum;
        vRecId # RecInfo( 168, _recId );
      end;

      gMenge  # gMenge + Rso.ErT.Menge;
      gPreis  # gPreis + Rso.ErT.Gesamtpreis;

      vRsoGrp # Rso.ErT.Gruppe;
      vRsoNum # Rso.ErT.Ressource;
      vRsoErT # Rso.ErT.ArtikelNr;
    END;

    if ( vRsoGrp != 0 ) and ( vRsoNum != 0 ) and ( vRsoErT != '' ) then begin
      vKey # CnvAI( vRsoGrp, _fmtNumLeadZero, 0, 4 ) + CnvAI( vRsoNum, _fmtNumLeadZero, 0, 4 );
      vKey # vKey + '||' + CnvAF( 10000000000.0 - gMenge, _fmtNumLeadZero, 0, 15 );
      Sort_ItemAdd( vTree, vKey + '||' + CnvAF( gMenge ) + '||' + CnvAF( gPreis ) + '||', 168, vRecId );
    end;

    Sort_KillList( vTree2 );

    if ( Erx <= _rLocked ) then begin
      Sort_KillList( vTree );
      RETURN;
    end;
  END_BLOCK;


  /* Druckelemente */
  lf_Empty    # LF_NewLine( '' );
  lf_Maschine # LF_NewLine( 'maschine' );
  lf_Header   # LF_NewLine( 'header' );
  lf_Line     # LF_NewLine( 'line' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  BEGIN_BLOCK
    vPrgr->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );

    FOR  vItem # Sort_ItemFirst( vTree );
    LOOP vItem # Sort_ItemNext( vTree, vItem );
    WHILE ( vItem != 0 ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then
        BREAK;

      RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );

      if ( vKey != Lib_Strings:Strings_Token( vItem->spName, '||', 1 ) ) then begin
        Rso.Gruppe # Rso.ErT.Gruppe;
        Rso.Nummer # Rso.ErT.Ressource;
        RecRead( 160, 1, 0 );

        LF_Print( lf_Empty );
        LF_Print( lf_Maschine );

        gPos # 0;
        vKey # Lib_Strings:Strings_Token( vItem->spName, '||', 1 );
      end;
      gMenge # CnvFA( Lib_Strings:Strings_Token( vItem->spName, '||', 3 ) );
      gPreis # CnvFA( Lib_Strings:Strings_Token( vItem->spName, '||', 4 ) );
      gPos   # gPos + 1;

      LF_Print( lf_Line );
    END;

    Sort_KillList( vTree );

    if ( vItem != 0 ) then
      BREAK;
  END_BLOCK;

  /* Cleanup */
  vPrgr->Lib_Progress:Term();

  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Maschine );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
end;

//=========================================================================
//=========================================================================