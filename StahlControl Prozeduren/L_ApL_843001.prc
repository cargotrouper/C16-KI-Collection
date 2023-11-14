@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_ApL_843001
//                    OHNE E_R_G
//  Info
//        Liste: Schlüsseldaten Aufpreise (Listeneinträge)
//
//  22.03.2005  TM  Erstellung der Prozedur
//  18.03.2010  PW  Neuer Listenstil
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
  lf_842    : handle;
  lf_843    : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Gv.Ints.01 #   0; // Version von
  Gv.Ints.02 # 999; // Version bis

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.843001', here + ':AusSel' );
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
  vA : alpha;
end;
begin
  case aName of
    'info' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] #   0.0;
      list_Spacing[ 2] #  60.0;
      list_Spacing[ 3] # 190.0;
      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
      if ( Gv.Ints.01 != 0 ) or ( Gv.Ints.02 != 999 ) then
        LF_Set( 1, 'Selektion: Version von ' + AInt( Gv.Ints.01 ) + ' bis ' + AInt( Gv.Ints.02 ), n, 0 );
      LF_Set( 2, 'MB: mengenbezogen, RAB: rabattierbar, NB: neuberechnen',    y, 0 );
      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 20.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 80.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 15.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 10.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 12.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 15.0;
      list_Spacing[ 8] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Key',         y, 0 );
      LF_Set( 2, 'Bezeichnung', n, 0 );
      LF_Set( 3, 'Menge',       y, 0 );
      LF_Set( 4, 'MEH',         n, 0 );
      LF_Set( 5, 'PEH',         y, 0 );
      LF_Set( 6, 'Preis',       y, 0 );
      LF_Set( 7, 'Optionen',    n, 0 );

      if ( list_XML ) then begin
        LF_Set(  8, 'Aufpreisgruppe', y, 0 );
        LF_Set(  9, 'Güte',           n, 0 );
        LF_Set( 10, 'ObfNr',          y, 0 );
        LF_Set( 11, 'ObfZusatz',      n, 0 );
        LF_Set( 12, 'Dicke von',      y, 0 );
        LF_Set( 13, 'Dicke bis',      y, 0 );
        LF_Set( 14, 'Breite von',     y, 0 );
        LF_Set( 15, 'Breite bis',     y, 0 );
        LF_Set( 16, 'Länge von',      y, 0 );
        LF_Set( 17, 'Länge bis',      y, 0 );
        LF_Set( 18, 'Menge MEH',      n, 0 );
        LF_Set( 19, 'Menge von',      y, 0 );
        LF_Set( 20, 'Menge bis',      y, 0 );
        LF_Set( 21, 'Zeugnis',        n, 0 );
        LF_Set( 22, 'Adresse',        y, 0 );
        LF_Set( 23, 'Erzeuger',       y, 0 );
        LF_Set( 24, 'Artikelnummer',  n, 0 );
        LF_Set( 25, 'Artikelgruppe',  y, 0 );
      end;
    end;

    '842' : begin
      if ( aPrint ) then begin
        LF_Text( 1, AInt( ApL.Key1 ) + '.' + AInt( ApL.Key2 ) + '.' + AInt( ApL.Key3 ) );
        if ( ApL.Datum.Von != 0.0.0 ) or ( ApL.Datum.Bis != 0.0.0 ) then
          LF_Text( 3, 'gültig von ' + CnvAD( ApL.Datum.Von ) + ' bis ' + CnvAD( ApL.Datum.Bis ) );

        RETURN;
      end;

      list_Spacing[ 4] # 0.0;
      LF_Format( _LF_Underline );
      LF_Set( 1, '#ApL.Keys',        y, 0);
      LF_Set( 2, '@ApL.Bezeichnung', n, 0 );
      LF_Set( 3, '#Gültigkeit',      n, 0 );
    end;

    '843' : begin
      if ( aPrint ) then begin
        if ( list_XML ) then
          LF_Text( 1, AInt( ApL.L.Key1 ) + '.' + AInt( ApL.L.Key2 ) + '.' + AInt( ApL.L.Key3 ) + '.' + AInt( ApL.L.Key4 ) );

        vA # '';
        if ( ApL.L.MengenbezugYN ) then
          vA # vA + ', MB';
        if ( ApL.L.RabattierbarYN ) then
          vA # vA + ', RAB';
        if ( ApL.L.NeuberechnenYN ) then
          vA # vA + ', NB';
        if ( vA != '' ) then
          LF_Text( 7, StrCut( vA, 3, StrLen( vA ) ) );

        RETURN;
      end;

      list_Spacing[ 4] # List_Spacing[ 3] + 15.0;
      LF_Set( 1, '@ApL.L.Key4',           y, 0 );
      LF_Set( 2, '@ApL.L.Bezeichnung.L1', n, 0 );
      LF_Set( 3, '@ApL.L.Menge',          y, _LF_Num, 2 );
      LF_Set( 4, '@ApL.L.MEH',            n, 0 );
      LF_Set( 5, '@ApL.L.PEH',            y, _LF_Int );
      LF_Set( 6, '@ApL.L.Preis',          y, _LF_Num, 2 );
      LF_Set( 7, '#Optionen',             n, 0 );

      if ( list_XML ) then begin
        LF_Set(  8, '@ApL.L.Aufpreisgruppe', y, _LF_IntNG );
        LF_Set(  9, '@ApL.L.Güte',           n, 0 );
        LF_Set( 10, '@ApL.L.ObfNr',          y, _LF_IntNG );
        LF_Set( 11, '@ApL.L.ObfZusatz',      n, 0 );
        LF_Set( 12, '@ApL.L.Dicke.Von',      y, _LF_Num, 2 );
        LF_Set( 13, '@ApL.L.Dicke.Bis',      y, _LF_Num, 2 );
        LF_Set( 14, '@ApL.L.Breite.Von',     y, _LF_Num, 2 );
        LF_Set( 15, '@ApL.L.Breite.Bis',     y, _LF_Num, 2 );
        LF_Set( 16, '@ApL.L.Länge.Von',      y, _LF_Num, 2 );
        LF_Set( 17, '@ApL.L.Länge.Bis',      y, _LF_Num, 2 );
        LF_Set( 18, '@ApL.L.Menge.MEH',      n, 0 );
        LF_Set( 19, '@ApL.L.Menge.Von',      y, _LF_Num, 2 );
        LF_Set( 20, '@ApL.L.Menge.Bis',      y, _LF_Num, 2 );
        LF_Set( 21, '@ApL.L.Zeugnis',        n, 0 );
        LF_Set( 22, '@ApL.L.Adresse',        y, _LF_IntNG );
        LF_Set( 23, '@ApL.L.Erzeuger',       y, _LF_IntNG );
        LF_Set( 24, '@ApL.L.Artikelnummer',  n, 0 );
        LF_Set( 25, '@ApL.L.Artikelgruppe',  y, _LF_IntNG );
      end;
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
  Erx   : int;
  vPrgr    : handle;
  vSel     : int;
  vSelName : alpha;
  vSelQ    : alpha(500);
end;
begin
  /* Selektion */
  if ( Gv.Ints.01 != 0 ) or ( Gv.Ints.02 != 999 ) then
    Lib_Sel:QVonBisI( var vSelQ, 'ApL.Key1', Gv.Ints.01, Gv.Ints.02 );

  vSel # SelCreate( 842, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Info   # LF_NewLine( 'info' );
  lf_Header # LF_NewLine( 'header' );
  lf_842    # LF_NewLine( '842' );
  lf_843    # LF_NewLine( '843' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  REPEAT BEGIN
    vPrgr # Lib_Progress:Init( 'Listengenerierung', RecInfo( 842, _recCount, vSel ) );

    FOR  Erx # RecRead( 842, vSel, _recFirst );
    LOOP Erx # RecRead( 842, vSel, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then
        BREAK;

      LF_Print( lf_842 );

      FOR  Erx # RecLink( 843, 842, 1, _recFirst );
      LOOP Erx # RecLink( 843, 842, 1, _recNext );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        LF_Print( lf_843 );
      END;

      LF_Print( lf_Empty );
    END;

    if ( Erx <= _rLocked ) then
      BREAK;
  END UNTIL ( true );

  /* Cleanup */
  vPrgr->Lib_Progress:Term();
  vSel->SelClose();
  SelDelete( 842, vSelName );

  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Info );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_842 );
  LF_FreeLine( lf_843 );
end;

//=========================================================================
//=========================================================================