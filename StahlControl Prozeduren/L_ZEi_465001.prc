@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_ZEi_465001
//                    OHNE E_R_G
//  Info
//        Liste: Zahlungseingangsliste
//
//  16.04.2007  AI  Erstellung der Prozedur
//  29.03.2010  PW  Neuer Listenstil
//  15.09.2015  TM  XML Ausgabe korrigiert
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
@I:Def_Aktionen
declare StartList ( aSort : int; aSortName : alpha );

local begin
  lf_Empty  : handle;
  lf_Info   : handle;
  lf_Header : handle;
  lf_Line   : handle;
  lf_Line2  : handle;
  lf_Summe  : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.Adr.von.KdNr      # 0;     // nur Kunde
  Sel.von.Datum         # 0.0.0; // Zahldatum von
  Sel.bis.Datum         # today; // Zahldatum bis
  "Sel.Fin.GelöschteYN" # false; // nur offene

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.465001', here + ':AusSel' );
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow( gMDI );
end;


//=========================================================================
// AusSel
//        Seitenkopf der Liste
//=========================================================================
sub AusSel ();
local begin
  vSortKey  : int;
  vSortName : alpha;
  vHdlDlg   : handle;
  vHdlLst   : handle;
end;
begin
  gSelected # 0;

  vHdlDlg # WinOpen( 'Lfm.Sortierung', _winOpenDialog );
  vHdlLst # vHdlDlg->WinSearch( 'Dl.Sort' );
  vHdlLst->WinLstDatLineAdd( 'Kundenstichwort' ); // key 1
  vHdlLst->WinLstDatLineAdd( 'Zahldatum' ); // key 2
  vHdlLst->wpCurrentInt # 1;
  vHdlDlg->WinDialogRun( _winDialogCenter, gMdi );
  vHdlLst->WinLstCellGet( vSortName, 1, _winLstDatLineCurrent );
  vHdlDlg->WinClose();

  if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end

  vSortKey  # gSelected;
  gSelected # 0;
  StartList( vSortKey, vSortName );
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
    'info' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] #   0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 100.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 10.0;
      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;

      vA # 'Selektion: ';
      if ( Sel.von.Datum != 0.0.0 ) then
        vA # vA + 'Zahldatum von ' + CnvAD( Sel.von.Datum ) + ' bis ' + CnvAD( Sel.bis.Datum );
      else
        vA # vA + 'Zahldatum bis ' + CnvAD( Sel.bis.Datum );
      if ( Sel.Adr.von.KdNr != 0 ) then
        vA # vA + ', Kunde: ' + AInt( Sel.Adr.von.KdNr );
      if ( "Sel.Fin.GelöschteYN" ) then
        vA # vA + ', nur offene';

      LF_Set( 1, vA, n, 0 );
      LF_Set( 2, 'Beträge in ' + "Set.Hauswährung.Kurz", y, 0 );

      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 22.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 80.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 35.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 25.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 25.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 30.0;
      list_Spacing[ 8] # list_Spacing[ 7] + 30.0;
      list_Spacing[ 9] # list_Spacing[ 8] + 30.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set(  1, 'Zahldatum',   y, 0 );
      LF_Set(  2, 'Kunde',       n, 0 );
      LF_Set(  3, 'Belegnr.',    n, 0 );
      LF_Set(  4, 'Referenznr.', n, 0 );
      LF_Set(  5, 'Auftrag',     y, 0 );
      LF_Set(  6, 'in Kasse',    y, 0 );
      LF_Set(  7, 'Eingang',     y, 0 );
      LF_Set(  8, 'Restbetrag',  y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        GV.Num.01 # ZEi.BetragW1 - ZEi.ZugeordnetW1;
        AddSum( 1, ZEi.BetragW1 );
        AddSum( 3, GV.Num.01 );
        RETURN;
      end;

      LF_Set(  1, '@ZEi.Zahldatum',       y, 0 );
      LF_Set(  2, '@ZEi.Kundenstichwort', n, 0 );
      LF_Set(  3, '@ZEi.Belegnummer',     n, 0 );
      LF_Set(  4, '@ZEi.Referenz',        n, 0 );
      LF_Set(  5, '',         y, 0 );
      LF_Set(  6, '',         y, 0 );
      LF_Set(  7, '@ZEi.BetragW1',        y, _LF_Wae );
      LF_Set(  8, '@GV.Num.01',           y, _LF_Wae );
    end;

    'line2' : begin
      if ( aPrint ) then begin
        AddSum( 2, Auf.A.Menge );

        RETURN;
      end;
      LF_Set(  1, '',   y, 0 );
      LF_Set(  2, '',   n, 0 );
      LF_Set(  3, '',   n, 0 );
      LF_Set(  4, '',   n, 0 );
      LF_Set(  5, '@Auf.A.Nummer', y, _LF_IntNG );
      LF_Set(  6, '@Auf.A.Menge',  y, _LF_Wae );
      LF_Set(  7, '',   y, 0 );
      LF_Set(  8, '',   y,0 );

    end;

    'summe' : begin
      if ( aPrint ) then begin

        LF_Sum( 6, 2, 2 );
        LF_Sum( 7, 1, 2 );
        LF_Sum( 8, 3, 2 );

        RETURN;
      end;

      LF_Set(  1, '', y, 0 );
      LF_Set(  2, '', n, 0 );
      LF_Set(  3, '', n, 0 );
      LF_Set(  4, '', n, 0 );
      LF_Set(  5, '', y, 0 );

      LF_Format( _LF_Overline );
      LF_Set( 6, '#Summe2', y, _LF_Wae );
      LF_Set( 7, '#Summe1', y, _LF_Wae );
      LF_Set( 8, '#Summe3', y, _LF_Wae );
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
    LF_Print( lf_Info );
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
  vSelQ     : alpha(500);
  vTree     : int;
  vItem     : int;
  vLastZAu  : int;
  vPrinted  : logic;
end;
begin
  /* Selektion */
  if ( Sel.Adr.von.KdNr != 0 ) then
    Lib_Sel:QInt( var vSelQ, 'ZEi.Kundennummer', '=', Sel.Adr.von.Kdnr );
  if ( Sel.von.Datum != 0.0.0 ) or ( Sel.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vSelQ, 'ZEi.Zahldatum', Sel.von.Datum, Sel.bis.Datum );

  vSel # SelCreate( 465, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  /* Datenbaum */
  vTree # CteOpen( _cteTreeCI );

  FOR  Erx # RecRead( 465, vSel, _recFirst );
  LOOP Erx # RecRead( 465, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( aSort = 1 ) then // Kundenstichwort
      Sort_ItemAdd( vTree, ZEi.Kundenstichwort, 465, RecInfo( 465, _recId ) );
    else if ( aSort = 2 ) then // Zahldatum
      Sort_ItemAdd( vTree, CnvAI( CnvID( ZEi.Zahldatum ), _fmtNumNoGroup | _fmtNumLeadZero, 0, 6 ), 465, RecInfo( 465, _recId ) );
  END;

  vSel->SelClose();
  SelDelete( 565, vSelName );

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Info   # LF_NewLine( 'info' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  lf_Line2  # LF_NewLine( 'line2' );
  lf_Summe  # LF_NewLine( 'summe' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  FOR  vItem # Sort_ItemFirst( vTree );
  LOOP vItem # Sort_ItemNext( vTree, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );

    if ( "Sel.Fin.GelöschteYN" ) and ( ZEi.ZugeordnetW1 >= ZEi.BetragW1 ) then
      CYCLE;

    LF_Print( lf_Line );

    RecBufClear( 404 );
    Auf.A.Aktionstyp # c_Akt_Kasse;
    Auf.A.Aktionsnr  # ZEi.Nummer;

    FOR  Erx # RecRead( 404, 2, 0 );
    LOOP Erx # RecRead( 404, 2, _recNext );
    WHILE ( Erx != _rNoRec ) and ( Auf.A.Aktionstyp = c_Akt_Kasse ) and ( Auf.A.Aktionsnr = ZEi.Nummer ) DO BEGIN
      if ( abs( Auf.A.Menge ) >= 1.0 ) and ( "Auf.A.Löschmarker" = '' ) then
        LF_Print( lf_Line2 );
    END;
  END;

  LF_Print( lf_Summe );

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Info );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Line2 );
  LF_FreeLine( lf_Summe );
  Sort_KillList( vTree );
end;

//=========================================================================
//=========================================================================