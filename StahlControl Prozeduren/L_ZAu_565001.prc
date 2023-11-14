@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_ZAu_565001
//                    OHNE E_R_G
//  Info
//        Liste: Zahlungsausgangsliste
//
//  10.06.2008  MS  Erstellung der Prozedur
//  29.03.2010  PW  Neuer Listenstil
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
  Sel.Adr.von.KdNr      # 0;     // nur Lieferant
  Sel.von.Datum         # 0.0.0; // Zahldatum von
  Sel.bis.Datum         # today; // Zahldatum bis
  "Sel.Fin.GelöschteYN" # false; // gelöschte

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.565001', here + ':AusSel' );
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
  vHdlLst->WinLstDatLineAdd( 'Belegnummer' ); // key 1
  vHdlLst->WinLstDatLineAdd( 'Rechnungsnummer' ); // key 2
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
      list_Spacing[ 2] # 277.0;
      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;

      vA # 'Selektion: ';
      if ( Sel.von.Datum != 0.0.0 ) then
        vA # vA + 'Zahldatum von ' + CnvAD( Sel.von.Datum ) + ' bis ' + CnvAD( Sel.bis.Datum );
      else
        vA # vA + 'Zahldatum bis ' + CnvAD( Sel.bis.Datum );
      if ( Sel.Adr.von.KdNr != 0 ) then
        vA # vA + ', Lieferant: ' + AInt( Sel.Adr.von.KdNr );
      if ( "Sel.Fin.GelöschteYN" ) then
        vA # vA + ', nur gelöschte';
      LF_Set( 1, vA, n, 0 );

      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 15.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 25.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 25.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 67.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 25.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 20.0;
      list_Spacing[ 8] # list_Spacing[ 7] + 25.0;
      list_Spacing[ 9] # list_Spacing[ 8] + 25.0;
      list_Spacing[10] # list_Spacing[ 9] + 25.0;
      list_Spacing[11] # list_Spacing[10] + 25.0;
      list_Spacing[12] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set(  1, 'Nr.',          y, 0 );
      LF_Set(  2, 'ReNr. intern', y, 0 );
      LF_Set(  3, 'ReNr. extern', y, 0 );
      LF_Set(  4, 'Lieferant',    n, 0 );
      LF_Set(  5, 'Zahldatum',    y, 0 );
      LF_Set(  6, 'Belegnr.',     n, 0 );
      LF_Set(  7, 'Zahlungsart',  y, 0 );
      LF_Set(  8, 'Betrag',       y, 0 );
      LF_Set(  9, 'Zugeordnet',   y, 0 );
      LF_Set( 10, 'Re-Eingang',   y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        if ( ZAu.Zahldatum != 0.0.0 ) then
          LF_Text( 1, '*' + AInt( ZAu.Nummer ) );
        else
          LF_Text( 1, AInt( ZAu.Nummer ) );

        AddSum( 1, ZAu.BetragW1 );

        RETURN;
      end;

      LF_Set(  1, '#ZAu.Nummer',          y, 0 );
      LF_Set(  2, '@ERe.Z.Nummer',        y, _LF_Int );
      LF_Set(  3, '@ERe.Rechnungsnr',     y, 0 );
      LF_Set(  4, '@ZAu.LieferStichwort', n, 0 );
      LF_Set(  5, '@ZAu.Zahldatum',       y, 0 );
      LF_Set(  6, '@ZAu.Belegnummer',     n, 0 );
      LF_Set(  7, '@ZAu.Zahlungsart',     y, _LF_Int );
      LF_Set(  8, '@ZAu.BetragW1',        y, _LF_Wae );
      LF_Set(  9, '@ERe.Z.BetragW1',      y, _LF_Wae );
      LF_Set( 10, '@ERe.Rechnungsdatum',  y, 0 );
    end;

    'line2' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set(  2, '@ERe.Z.Nummer',        y, _LF_Int );
      LF_Set(  3, '@ERe.Rechnungsnr',     y, 0 );
      LF_Set(  9, '@ERe.Z.BetragW1',      y, _LF_Wae );
      LF_Set( 10, '@ERe.Rechnungsdatum',  y, 0 );
    end;

    'summe' : begin
      if ( aPrint ) then begin
        LF_Sum( 8, 1, 2 );

        RETURN;
      end;

      LF_Format( _LF_Overline );
      LF_Set( 8, '#Summe', y, _LF_Wae );
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
    Lib_Sel:QInt( var vSelQ, 'ZAu.Lieferant', '=', Sel.Adr.von.Kdnr );
  if ( Sel.von.Datum != 0.0.0 ) or ( Sel.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vSelQ, 'ZAu.Zahldatum', Sel.von.Datum, Sel.bis.Datum );
  if ( !"Sel.Fin.GelöschteYN" ) then
    Lib_Sel:QDate( var vSelQ, 'ZAu.Zahldatum', '=', 0.0.0 );

  vSel # SelCreate( 565, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  /* Datenbaum */
  vTree # CteOpen( _cteTreeCI );

  FOR  Erx # RecRead( 565, vSel, _recFirst );
  LOOP Erx # RecRead( 565, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( RecLink( 561, 565, 1, _recFirst ) <= _rLocked ) then begin // Eingangsrechnung Zahlung
      if ( RecLink( 560, 561, 1, _recFirst ) > _rLocked ) then // Eingangsrechnung
        RecBufClear( 560 );
    end
    else begin
      RecBufClear( 560 );
      RecBufClear( 561 );
    end;

    if ( aSort = 1 ) then // Belegnummer
      Sort_ItemAdd( vTree, ZAu.Belegnummer, 565, RecInfo( 565, _recId ) );
    else if ( aSort = 2 ) then // Rechnungsnummer
      Sort_ItemAdd( vTree, ERe.Rechnungsnr, 565, RecInfo( 565, _recId ) );
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
    vPrinted # false;
    vLastZAu # 0;


    FOR  Erx # RecLink( 561, 565, 1, _recFirst );
    LOOP Erx # RecLink( 561, 565, 1, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( RecLink( 560, 561, 1, _recFirst ) > _rLocked ) then // Eingangsrechnung
        RecBufClear( 560 );

      if ( vLastZAu != ZAu.Nummer ) then
        LF_Print( lf_Line );
      else
        LF_Print( lf_Line2 );

      vLastZAu # ZAu.Nummer;
      vPrinted # true;
    END;

    if ( !vPrinted ) then
      LF_Print( lf_Line ); // keine Rechnungseingänge
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