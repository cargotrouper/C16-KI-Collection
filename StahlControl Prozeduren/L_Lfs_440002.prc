@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Lfs_440002
//                    OHNE E_R_G
//  Info
//        Liste: Lieferscheine Umlagerungen
//
//  26.03.2008  ST  Erstellung der Prozedur
//  30.03.2010  PW  Neuer Listenstil
//  13.06.2022  AH  ERX
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
  lf_Sel    : handle;
  lf_Header : handle;
  lf_Line   : handle;
  lf_Summe  : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.von.Datum   # 0.0.0; // Lieferdatum von
  Sel.bis.Datum   # today; // Lieferdatum bis
  Sel.Adr.von.LKZ # 'D';   // Land von
  Sel.Adr.bis.LKZ # 'D';   // Land bis

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.440002', here + ':AusSel' );
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow( gMDI );
end;


//=========================================================================
// AusSel
//        Seitenkopf der Liste
//=========================================================================
sub AusSel ();
local begin
  vSort     : int;
  vSortName : alpha;
end;
begin
  gSelected # 0;
  StartList( vSort, vSortName );
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
local begin
  Erx     : int;
  vA      : alpha(500);
end;
begin
  case aName of
    'sel' : begin
      if ( aPrint ) then begin
        vA # 'Selektion: ';

        if ( Sel.von.Datum != 0.0.0 ) then
          vA # vA + 'Lieferdatum von ' + CnvAD( Sel.von.Datum ) + ' bis ' + CnvAD( Sel.bis.Datum );
        else
          vA # vA + 'Lieferdatum bis ' + CnvAD( Sel.bis.Datum );

        "Lnd.Kürzel" # Sel.Adr.von.LKZ;
        if ( RecRead( 812, 1, 0 ) > _rLocked ) then
          RecBufClear( 812 );
        vA # vA + ', Versandland: ' + Lnd.Name.L1;

        "Lnd.Kürzel" # Sel.Adr.bis.LKZ;
        if ( RecRead( 812, 1, 0 ) > _rLocked ) then
          RecBufClear( 812 );
        vA # vA + ', Empfängerland: ' + Lnd.Name.L1;

        LF_Text( 1, vA );

        RETURN;
      end;

      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
      LF_Set( 1, '#Selektion', n, 0 );
      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 56.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 60.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 30.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 20.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 20.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 20.0;
      list_Spacing[ 8] # list_Spacing[ 7] + 25.0;
      list_Spacing[ 9] # list_Spacing[ 8] + 23.0;
      list_Spacing[10] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Warengruppe', n, 0 );
      LF_Set( 2, 'Oberfläche',  n, 0 );
      LF_Set( 3, 'Güte',        n, 0 );
      LF_Set( 4, 'Dicke',       y, 0 );
      LF_Set( 5, 'Breite',      y, 0 );
      LF_Set( 6, 'Länge',       y, 0 );
      LF_Set( 7, 'Intrastat',   n, 0 );
      LF_Set( 8, 'Gewicht',     y, 0 );
      LF_Set( 9, 'EK',          y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        Gv.Num.01 # Lfs.P.Menge.Einsatz / 1000.0 * Mat.EK.Preis; // EK
        AddSum( 1, Lfs.P.Menge.Einsatz );
        AddSum( 2, Gv.Num.01 );

        // Oberfläche
        vA # '';
        FOR  Erx # RecLink( 402, 401, 11, _recFirst );
        LOOP Erx # RecLink( 402, 401, 11, _recNext );
        WHILE ( Erx <= _rLocked ) DO
          vA # vA + ', ' + Auf.AF.Bezeichnung;
        if ( vA != '' ) then
          LF_Text( 2, StrCut( vA, 3, StrLen( vA ) ) );

        RETURN;
      end;

      LF_Set( 1, '@Wgr.Bezeichnung.L1',  n, 0 );
      LF_Set( 2, '#Oberfläche',          n, 0 );
      LF_Set( 3, '@Auf.P.Güte',          n, 0 );
      LF_Set( 4, '@Mat.Dicke',           y, _LF_Num3, "Set.Stellen.Dicke" );
      LF_Set( 5, '@Mat.Breite',          y, _LF_Num3, "Set.Stellen.Breite" );
      LF_Set( 6, '@Mat.Länge',           y, _LF_Num3, "Set.Stellen.Länge" );
      LF_Set( 7, '@Auf.P.Intrastatnr',   n, 0 );
      LF_Set( 8, '@Lfs.P.Menge.Einsatz', y, _LF_Num3, "Set.Stellen.Menge" );
      LF_Set( 9, '@Gv.Num.01',           y, _LF_Num, 2 );
    end;

    'summe' : begin
      if ( aPrint ) then begin
        LF_Sum( 8, 1, 3 );
        LF_Sum( 9, 2, 2 );

        RETURN;
      end;

      LF_Format( _LF_Overline );
      LF_Set( 8, '#Lfs.P.Menge.Einsatz', y, _LF_Num3 );
      LF_Set( 9, '#Gv.Num.01',           y, _LF_Num, 2 );
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

  if ( aSeite = 1 ) then begin
    LF_Print( lf_Sel );
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
  vSel      : int;
  vSelName  : alpha;
  vSelQ     : alpha(1000);
  vLastKom  : int;
end;
begin
  /* Selektion */
  vSelQ # 'LinkCount( Lfs.Adr ) > 0 AND LinkCount( Mat.Adr ) > 0 AND ( Lfs.P.Auftragsnr = 0 OR LinkCount( Auf.AAr ) > 0 )';
  if ( Sel.von.Datum != 0.0.0 ) or ( Sel.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vSelQ, 'Lfs.P.Datum.Verbucht', Sel.von.Datum, Sel.bis.Datum );

  vSel # SelCreate( 441, 2 );
  vSel->SelAddLink( '',    440, 441, 1, 'Lfs' );
  vSel->SelAddLink( 'Lfs', 101, 440, 3, 'Lfs.Adr' );
  vSel->SelAddLink( '',    200, 441, 4, 'Mat' );
  vSel->SelAddLink( 'Mat', 101, 200, 6, 'Mat.Adr' );
  vSel->SelAddLink( '',    401, 441, 5, 'Auf' );
  vSel->SelAddLink( 'Auf', 835, 401, 5, 'Auf.AAr' );
  vSel->SelDefQuery( '', vSelQ );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery( 'Lfs', '' );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery( 'Lfs.Adr', '"Adr.A.LKZ" = ''' + Sel.Adr.bis.LKZ + '''' );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery( 'Mat', '' );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery( 'Mat.Adr', '"Adr.A.LKZ" = ''' + Sel.Adr.von.LKZ + '''' );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery( 'Auf', '' );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery( 'Auf.AAr', '( AAr.KonsiYN )' );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Sel    # LF_NewLine( 'sel' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  lf_Summe  # LF_NewLine( 'summe' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );
  vLastKom # -1;

  FOR  Erx # RecRead( 441, vSel, _recFirst );
  LOOP Erx # RecRead( 441, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( RecLink( 200, 441, 4, _recFirst ) > _rLocked ) then begin // Material
      if ( RecLink( 210, 441, 12, _recFirst ) <= _rLocked ) then
        RecBufCopy( 210, 200 );
      else
        RecBufClear( 200 );
    end;

    if ( RecLink( 401, 441, 5, _recFirst ) > _rLocked ) then // Auftrag
      RecBufClear( 401 );

    if ( RecLink( 819, 401, 1, _recFirst ) > _rLocked ) then // Warengruppe
      RecBufClear( 819 );

    LF_Print( lf_Line );
  END;
  LF_Print( lf_Summe );

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Sel );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Summe );

  vSel->SelClose();
  SelDelete( 441, vSelName );
end;

//=========================================================================
//=========================================================================