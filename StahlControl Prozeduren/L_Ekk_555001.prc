@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Ekk_555001
//                    OHNE E_R_G
//  Info
//        Liste: Einkaufskontrolle
//
//  28.06.2007  NH  Erstellung der Prozedur
//  06.04.2010  PW  Neuer Listenstil
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
  lf_LfHead : handle;
  lf_Header : handle;
  lf_Line   : handle;
  lf_LfSum  : handle;
  lf_Gesamt : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.Adr.von.LiNr       # 0;     // nur Lieferant
  Sel.bis.Datum          # today; // Rechnungsdatum bis
  "Sel.Fin.GelöschteYN"  # true;  // freie Rechnungsnummer
  "Sel.Fin.!GelöschteYN" # true;  // vorhandene Rechnungsnummer

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.555001', here + ':AusSel' );
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
  vHdlLst->WinLstDatLineAdd( 'Datum' ); // key 1
  vHdlLst->WinLstDatLineAdd( 'Gewicht' ); // key 2
  vHdlLst->WinLstDatLineAdd( 'Lieferscheinnummer' ); // key 3
  vHdlLst->WinLstDatLineAdd( 'Lieferschein AB-Nr.' ); // key 4
  vHdlLst->wpCurrentInt # 1;
  vHdlDlg->WinDialogRun( _winDialogCenter, gMdi );
  vHdlLst->WinLstCellGet( vSortName, 1, _winLstDatLineCurrent );
  vHdlDlg->WinClose();

    if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;

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
  vA : alpha(500);
end;
begin
  case aName of
    'sel' : begin
      if ( aPrint ) then begin
        vA # 'Selektion: Rechnungsdatum bis ' + CnvAD( Sel.bis.Datum );

        if ( Sel.Adr.von.LiNr != 0 ) then begin // Lieferant
          Adr.LieferantenNr # Sel.Adr.von.LiNr;
          if ( RecRead( 100, 3, 0 ) > _rLocked ) then begin
            RecBufClear( 100 );
            vA # vA + ', Lieferant: ' + AInt( Sel.Adr.von.LiNr );
          end
          else
            vA # vA + ', Lieferant: ' + Adr.Stichwort;
        end;

        if ( "Sel.Fin.GelöschteYN" ) then // freie Rechnungsnummern
          vA # vA + ', freie Rechnungsnummern';
        if ( "Sel.Fin.!GelöschteYN" ) then // vorhandene Rechnungsnummern
          vA # vA + ', vorhandene Rechnungsnummern';

        LF_Text( 1, vA );

        RETURN;
      end;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 360.0;

      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
      LF_Set( 1, '#Selektion', n, 0 );
      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'lf-head' : begin
      if ( aPrint ) then
        RETURN;

      LF_Format( _LF_Underline );
      LF_Set( 1, '@EKK.LieferStichwort', n, 0 );
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 23.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 17.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 19.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 17.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 18.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 24.0;
      list_Spacing[ 8] # list_Spacing[ 7] + 15.0;
      list_Spacing[ 9] # list_Spacing[ 8] + 19.0;
      list_Spacing[10] # list_Spacing[ 9] + 15.0;
      list_Spacing[11] # list_Spacing[10] + 22.0;
      list_Spacing[12] # list_Spacing[11] + 17.0;
      list_Spacing[13] # list_Spacing[12] + 24.0;
      list_Spacing[14] # list_Spacing[13] +  8.0;
      list_Spacing[15] # list_Spacing[14] + 19.0;
      list_Spacing[16] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set(  1, 'ArtNr/Güte', n, 0 );
      LF_Set(  2, 'Lfs Nr.',    n, 0 );
      LF_Set(  3, 'Lfs ABNr.',  y, 0 );
      LF_Set(  4, 'Re.Nr.',     y, 0 );
      LF_Set(  5, 'Komm.',      n, 0 );
      LF_Set(  6, 'Aufart',     n, 0 );
      LF_Set(  7, 'Dicke',      y, 0 );
      LF_Set(  8, 'Breite',     y, 0 );
      LF_Set(  9, 'Länge',      y, 0 );
      LF_Set( 10, 'Coilnr.',    n, 0 );
      LF_Set( 11, 'Datum',      y, 0 );
      LF_Set( 12, 'Bemerkung',  n, 0 );
      LF_Set( 13, 'Stk',        y, 0 );
      LF_Set( 14, 'Gewicht',    y, 0 );
      LF_Set( 15, 'Preis €',    y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        if ( Ekk.Artikelnummer != '' ) then
          LF_Text( 1, "Ekk.Artikelnummer" );
        else
          LF_Text( 1, "Ekk.Güte" );

        // Bemerkung
        case Ekk.Datei of
          501 : vA # 'EK';
          505 : vA # 'Rück';
          506 : vA # 'WE';
          otherwise vA # '';
        end;
        if ( Ekk.Id1 != 0 ) then
          vA # vA + AInt( Ekk.Id1 );
        if ( Ekk.Id2 != 0 ) then
          vA # vA + '/' + AInt( Ekk.Id2 );
        if ( Ekk.Id3 != 0 ) then
          vA # vA + '/' + AInt( Ekk.Id3 );
        if ( Ekk.Id4 != 0 ) then
          vA # vA + '/' + AInt( Ekk.Id4 );
        LF_Text( 12, vA );

        AddSum( 1, EKK.PreisW1 );

        RETURN;
      end;

      LF_Set(  1, '#ArtNr/Güte',         n, 0 );
      LF_Set(  2, '@Ekk.Lieferscheinnr', n, 0 );
      LF_Set(  3, '@Ekk.Lief.AB.Nummer', y, 0 );
      LF_Set(  4, '@Ekk.EingangsReNr',   y, _LF_IntNG );
      LF_Set(  5, '@Ein.P.Kommission',   n, 0 );
      LF_Set(  6, '@AAr.Bezeichnung',    n, 0 );
      LF_Set(  7, '@Ekk.Dicke',          y, _LF_Num3, "Set.Stellen.Dicke" );
      LF_Set(  8, '@Ekk.Breite',         y, _LF_Num3, "Set.Stellen.Breite" );
      LF_Set(  9, '@Ekk.Länge',          y, _LF_Num3, "Set.Stellen.Länge" );
      LF_Set( 10, '@Ekk.Coilnummer',     n, 0 );
      LF_Set( 11, '@Ekk.Datum',          y, 0 );
//      pls_Hdl->ppFmtDateStyle  # _winFmtDateString;
//      pls_Hdl->ppFmtDateString # 'dd.MM.yy';
      LF_Set( 12, '#Bemerkung',          n, 0 );
      LF_Set( 13, '@EKK.Stückzahl',      y, _LF_Int );
      LF_Set( 14, '@EKK.Gewicht',        y, _LF_Num3, "Set.Stellen.Gewicht" );
      LF_Set( 15, '@EKK.PreisW1',        y, _LF_Wae );
    end;

    'lf-summe' : begin
      if ( aPrint ) then begin
        AddSum( 2, GetSum( 1 ) );
        LF_Sum( 15, 1, 2 );
        ResetSum( 1 );

        RETURN;
      end;

      LF_Set( 15, '#Summe',   y, _LF_Wae );
      LF_Set(  0, '##LINE##', n, 15, 16 ); // Linie
    end;

    'gesamt' : begin
      if ( aPrint ) then begin
        AddSum(  2, GetSum( 1 ) );
        LF_Sum( 15, 2, 2 );

        RETURN;
      end;

      LF_Format( _LF_Overline );
      LF_Set( 15, '#Summe', y, _LF_Wae );
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
  vTree     : handle;
  vItem     : handle;
  vSortKey  : alpha;
  vLastLf   : int;
end;
begin
  /* Selektion */
  if ( "Sel.Fin.GelöschteYN" ) AND ( !"Sel.Fin.!GelöschteYN" ) then
    Lib_Sel:QInt( var vSelQ, 'EKK.EingangsReNr', '=', 0 );
  if ( !"Sel.Fin.GelöschteYN" ) AND ( "Sel.Fin.!GelöschteYN" ) then
    Lib_Sel:QInt( var vSelQ, 'EKK.EingangsreNr', '>', 0 );
  if ( Sel.Adr.von.LiNr != 0 ) then
    Lib_Sel:QInt( var vSelQ, 'EKK.Lieferant', '=', Sel.Adr.von.LiNr );
  Lib_Sel:QDate( var vSelQ, 'EKK.Datum', '<=', Sel.bis.Datum );

  vSel # SelCreate( 555, 7 );
  vSel->SelDefQuery( '', vSelQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  /* Datenbaum */
  vTree # CteOpen( _cteTreeCI );

  FOR  Erx # RecRead( 555, vSel, _recFirst );
  LOOP Erx # RecRead( 555, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( aSort = 1 ) then // Datum
      vSortKey # Ekk.LieferStichwort + CnvAI( Ekk.Lieferant, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 ) + CnvAD( Ekk.Datum );
    else if ( aSort = 2 ) then // Gewicht
      vSortKey # EKK.LieferStichwort + CnvAI( Ekk.Lieferant, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 ) + CnvAI( ( CnvIF( EKK.Gewicht ) ), _fmtNumNoGroup | _fmtNumLeadZero, 0, 9 );
    else if ( aSort = 3 ) then // Lieferscheinnummer
      vSortKey # EKK.LieferStichwort + CnvAI( Ekk.Lieferant, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 ) + Ekk.LieferscheinNr + CnvAD( EKK.Datum );
    else if ( aSort = 4 ) then // Lieferschein AB-Nr.
      vSortKey # EKK.LieferStichwort + CnvAI( Ekk.Lieferant, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 ) + Ekk.Lief.AB.Nummer + CnvAD( EKK.Datum );

    Sort_ItemAdd( vTree, vSortKey, 555, RecInfo( 555, _recId ) );
  END;

  vSel->SelClose();
  SelDelete( 555, vSelName );

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Sel    # LF_NewLine( 'sel' );
  lf_LfHead # LF_NewLine( 'lf-head' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  lf_LfSum  # LF_NewLine( 'lf-summe' );
  lf_Gesamt # LF_NewLine( 'gesamt' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  FOR  vItem # Sort_ItemFirst( vTree );
  LOOP vItem # Sort_ItemNext( vTree, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );

    // Bestellposition
    if ( RecLink( 501, 555, 5, _recFirst ) > _rLocked ) then begin
      if ( RecLink( 511, 555, 6, _recFirst ) > _rLocked ) then
        RecBufClear( 511 );
      else
        RecBufCopy( 511, 501 );
    end;

    // Auftragsposition
    if ( RecLink( 401, 501, 18, _recFirst ) > _rLocked ) then begin
      if ( RecLink( 411, 501, 19, _recFirst ) > _rLocked ) then
        RecBufClear( 411 );
      else
        RecBufCopy( 411, 401 );
    end;

    // Auftragsart
    if ( RecLink( 835, 401, 5, _recFirst ) > _rLocked ) then
      RecBufClear( 835 );


    if ( Ekk.Lieferant != vLastLf ) then begin
      if ( vLastLf != 0 ) then begin
        LF_Print( lf_LfSum );
        LF_Print( lf_Empty );
      end;
      LF_Print( lf_LfHead );

      vLastLf # Ekk.Lieferant;
    end;

    LF_Print( lf_Line );
  END;

  if ( vLastLf != 0 ) then begin
    LF_Print( lf_LfSum );
    LF_Print( lf_Empty );
  end;
  LF_Print( lf_Gesamt );


  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Sel );
  LF_FreeLine( lf_LfHead );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_LfSum );
  LF_FreeLine( lf_Gesamt );
  Sort_KillList( vTree );
end;

//=========================================================================
//=========================================================================