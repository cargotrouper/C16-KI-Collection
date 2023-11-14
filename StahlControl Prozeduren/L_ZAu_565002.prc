@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_ZAu_565002
//                    OHNE E_R_G
//  Info
//        Liste: Zahlungsausgangsliste
//
//  10.06.2008  MS  Erstellung der Prozedur
//  29.03.2010  PW  Neuer Listenstil
//  01.12.2010  TM  Erstellung Zahlungsausgangsinfo aus 565001
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
declare AusSel();

local begin
  lf_INFO       : handle;
  lf_TITEL      : handle;
  lf_HEADER_A   : handle;
  lf_HEADER_B   : handle;
  lf_POSTEN     : handle;
  lf_SUMMEN     : handle;
  lf_EMPTY      : handle;
  lf_GESAMT     : handle;

  vSumNetto     : float;
  vSumBrutto    : float;
  vSumZahlung   : float;

  vSumNettoG    : float;
  vSumBruttoG   : float;
  vSumZahlungG  : float;

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

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.565002', here + ':AusSel' );
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow( gMDI );

  // AusSel();

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

  /*
  gSelected # 0;

  vHdlDlg # WinOpen( 'Lfm.Sortierung', _winOpenDialog );
  vHdlLst # vHdlDlg->WinSearch( 'Dl.Sort' );
  vHdlLst->WinLstDatLineAdd( 'Belegnummer' ); // key 1
  vHdlLst->WinLstDatLineAdd( 'Rechnungsnummer' ); // key 2
  vHdlLst->wpCurrentInt # 1;
  vHdlDlg->WinDialogRun( _winDialogCenter, gMdi );
  vHdlLst->WinLstCellGet( vSortName, 1, _winLstDatLineCurrent );
  vHdlDlg->WinClose();

  if ( gSelected = 0 ) then
    RETURN;

  vSortKey  # gSelected;
  gSelected # 0;
  */

  vSortKey # 1;

  StartList( vSortKey, vSortName );
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
local begin
  vA    : alpha;
  vRest : float;
end;
begin
  case aName of
    'INFO' : begin
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

    'TITEL' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1]  #   0.0;
      list_Spacing[ 2]  # 277.0;

    end;

    'HEADER_A' : begin

      vRest # (ZAu.BetragW1 - ZAu.ZugeordnetW1);
      Lf_Text(6,StrCut(Adr.Stichwort,1,8));
      Lf_Text(10,cnvaf(vRest  ,0,0,2));

      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1]  #  0.0;
      list_Spacing[ 2]  # list_Spacing[ 1] + 40.0;
      list_Spacing[ 3]  # list_Spacing[ 2] + 24.0;
      list_Spacing[ 4]  # list_Spacing[ 3] + 24.0;
      list_Spacing[ 5]  # list_Spacing[ 4] + 24.0;
      list_Spacing[ 6]  # list_Spacing[ 5] + 24.0;
      list_Spacing[ 7]  # list_Spacing[ 6] + 24.0;
      list_Spacing[ 8]  # list_Spacing[ 7] + 19.0;
      list_Spacing[ 9]  # list_Spacing[ 8] + 24.0;
      list_Spacing[10]  # list_Spacing[ 9] + 24.0;
      list_Spacing[11]  # list_Spacing[10] + 24.0;


      LF_Format( _LF_Bold );
      LF_Set(  1, 'Zahlungsausgang:'            , n, 0 );
      LF_Set(  2, '@ZAu.Nummer'                 , n, 0 );
      LF_Set(  3, 'Belegnr.:'                   , n, 0 );
      LF_Set(  4, '@ZAu.BelegNummer'            , n, 0 );

      LF_Set(  5, 'Empfänger:'                  , n, 0 );
      LF_Set(  6, 'vStw'              , n, 0 );


      LF_Set(  7, 'Betrag '+ "Wae.Kürzel" + ':' , n, 0 );
      LF_Set(  8, '@ZAu.BetragW1'               , n, 0 );

      LF_Set(  9, 'Rest '+ "Wae.Kürzel" + ':'   , n, 0 );
      LF_Set(  10, 'vRest'                       , n, _LF_Int );

    end;

    'HEADER_B' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 32.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 30.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 24.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 24.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 24.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 30.0;
      list_Spacing[ 8] # list_Spacing[ 7] + 20.0;
      list_Spacing[ 9] # list_Spacing[ 8] + 30.0;
      list_Spacing[10] # list_Spacing[ 9] + 32.0;
      list_Spacing[11] # list_Spacing[10] + 32.0;
      List_Spacing[12] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set(  1, 'ReNr. intern'  , y, 0 );
      LF_Set(  2, 'ReNr. extern'  , y, 0 );
      LF_Set(  3, 'Re.Datum'      , y, 0 );
      LF_Set(  4, 'Fälligkeit'    , y, 0 );
      LF_Set(  5, 'Re. Gewicht'   , y, 0 );
      LF_Set(  6, 'Zug. Gewicht'  , y, 0 );
      LF_Set(  7, 'Skt.Dat.'   , y, 0 );
      LF_Set(  8, 'Skonto '       + "Wae.Kürzel"  , y, 0 );
      LF_Set(  9, 'Re.Betrag '    + "Wae.Kürzel"  , y, 0 );
      LF_Set( 10, 'Zahlungen '    + "Wae.Kürzel"  , y, 0 );

    end;

    'POSTEN' : begin
      if ( aPrint ) then begin
        if ( ZAu.Zahldatum != 0.0.0 ) then
          LF_Text( 1, '*' + AInt( ZAu.Nummer ) );
        else
          LF_Text( 1, AInt( ZAu.Nummer ) );

        AddSum( 1, ZAu.BetragW1 );

        RETURN;
      end;

      LF_Set(  1, '@ERe.Z.Nummer'         , y, _LF_Int  );
      LF_Set(  2, '@ERe.Rechnungsnr'      , y, 0 );
      LF_Set(  3, '@ERe.Rechnungsdatum'   , y, 0 );
      LF_Set(  4, '@ERe.Zieldatum'        , y, 0 );
      LF_Set(  5, '@ERe.Gewicht'          , y, _LF_Int  );
      LF_Set(  6, '@ERe.Kontroll.Gewicht' , y, _LF_Int  );
      LF_Set(  7, '@ERe.Skontodatum'      , y, _LF_Date );
      LF_Set(  8, '@ERe.SkontoW1'         , y, _LF_Wae  );
      LF_Set(  9, '@ERe.BruttoW1'         , y, _LF_Wae  );
      LF_Set( 10, '@ERe.Z.BetragW1'       , y, _LF_Wae  );

    end;

    'SUMMEN' : begin


      Lf_Text(9,cnvaf(vSumBrutto  , _FmtNumNoZero,0,2));
      Lf_Text(10,cnvaf(vSumZahlung , _FmtNumNoZero,0,2));

      if ( aPrint ) then
        RETURN;

      LF_Format(_LF_Bold );
      // LF_Set(  1, 'Summe:'     , n ,0);

      LF_Set(  9, 'vSumBrutto'  , y , _LF_Wae );
      LF_Set( 10, 'vSumZahlung' , y , _LF_Wae );
      LF_Format(_LF_Overline|_LF_Bold );

    end;

  'GESAMT' : begin


      Lf_Text(9,cnvaf(vSumBruttoG  , _FmtNumNoZero,0,2));
      Lf_Text(10,cnvaf(vSumZahlungG , _FmtNumNoZero,0,2));

      if ( aPrint ) then
        RETURN;

      LF_Format(_LF_Bold );
      LF_Set(  1, 'GESAMT:'     , n ,0);

      LF_Set(  9, 'vSumBruttoG'  , y , _LF_Wae );
      LF_Set( 10, 'vSumZahlungG' , y , _LF_Wae );
      LF_Format( _LF_Overline | _LF_Bold );

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

  if ( aSeite = 1 ) then begin
    LF_Print( lf_INFO );
    LF_Print( lf_Empty );
  end;

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
  vFirst    : logic;
  vDruckAnz : int;
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
      Sort_ItemAdd( vTree, cnvai(ZAu.Nummer,_FmtNumLeadZero,0,9), 565, RecInfo( 565, _recId ) );
    else if ( aSort = 2 ) then // Rechnungsnummer
      Sort_ItemAdd( vTree, ERe.Rechnungsnr, 565, RecInfo( 565, _recId ) );
  END;

  vSel->SelClose();
  SelDelete( 565, vSelName );

  /* Druckelemente */
  lf_INFO     # LF_NewLine( 'INFO');
  lf_TITEL    # LF_NewLine( 'TITEL' );
  lf_HEADER_A # LF_NewLine( 'HEADER_A' );
  lf_HEADER_B # LF_NewLine( 'HEADER_B' );
  lf_POSTEN   # LF_NewLine( 'POSTEN' );
  lf_SUMMEN   # LF_NewLine( 'SUMMEN' );
  lf_GESAMT   # LF_NewLine( 'GESAMT' );
  lf_EMPTY    # LF_NewLine( '' );

  Wae.Nummer # 1;
  erx # RecRead(814,1,0);
  If (Erx > _rLocked) then RecBufClear(814);



  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  vFirst # true;

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

      if vFirst = true then begin
        vFirst # false;
        Erx # RecLink(100,565,2,0);
        LF_Print( lf_HEADER_A );
        LF_Print( lf_EMPTY );
        LF_Print( lf_HEADER_B );

        vLastZAu # ZAu.Nummer;
      end;

      if ( vLastZAu != ZAu.Nummer ) then begin
        vDruckAnz # vDruckAnz +1;
        LF_Print( lf_SUMMEN );
        LF_Print( lf_EMPTY );
        vSumNetto   # 0.0;
        vSumBrutto  # 0.0;
        vSumZahlung # 0.0;

        LF_Print( lf_EMPTY );

        If vDruckAnz =2 then begin
          vDruckAnz # 0;
          Lib_Print:PRINT_FF();
        End;

        Erx # RecLink(100,565,2,0);
        LF_Print( lf_HEADER_A );
        LF_Print( lf_EMPTY );
        LF_Print( lf_HEADER_B );
        vLastZAu # ZAu.Nummer;
      End;

      LF_Print( lf_POSTEN );

      vSumNetto   # (vSumNetto   + ERe.NettoW1);
      vSumBrutto  # (vSumBrutto  + ERe.BruttoW1);
      vSumZahlung # (vSumZahlung + ERe.Z.BetragW1);

      vSumNettoG   # (vSumNettoG   + ERe.NettoW1);
      vSumBruttoG  # (vSumBruttoG  + ERe.BruttoW1);
      vSumZahlungG # (vSumZahlungG + ERe.Z.BetragW1);

      //Erx # RecLink(561,565,1,_recNext);

    END;
    // ENDE  Durchlauf Eingangsrechnungszahlungen

  End;
  LF_Print( lf_SUMMEN );
  LF_Print( lf_EMPTY );
  LF_Print( lf_EMPTY );
  LF_Print( lf_GESAMT );

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_TITEL );
  LF_FreeLine( lf_HEADER_A );
  LF_FreeLine( lf_HEADER_B );
  LF_FreeLine( lf_POSTEN );
  LF_FreeLine( lf_SUMMEN );
  LF_FreeLine( lf_GESAMT );
  LF_FreeLine( lf_EMPTY );

end;

//=========================================================================