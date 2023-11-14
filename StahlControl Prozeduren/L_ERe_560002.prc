@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_ERe_560002
//                    OHNE E_R_G
//  Info
//        Liste: Eingangsrechnungen
//
//  26.03.2008  ST  Erstellung der Prozedur
//  31.03.2010  PW  Neuer Listenstil
//  19.07.2012  ST  Fehlerkorrektur in Selektionebedung
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
  lf_LfSum  : handle;
  lf_Gesamt : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.Adr.von.LiNr       # 0;     // Lieferant
  Sel.von.Datum          # 0.0.0; // Rechnungsdatum von
  Sel.bis.Datum          # today; // Rechnungsdatum bis
  "Sel.Fin.nurMarkeYN"   # false; // nur markierte
  "Sel.Fin.GelöschteYN"  # false; // gelöschte
  "Sel.Fin.!GelöschteYN" # true;  // bestehende

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.560002', here + ':AusSel' );
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
  vHdlLst->WinLstDatLineAdd( 'Lieferantenstichwort' ); // key 1
  vHdlLst->WinLstDatLineAdd( 'Fälligkeit' ); // key 2
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
        vA # 'Selektion: ';

        if ( Sel.von.Datum != 0.0.0 ) then
          vA # vA + 'Rechnungsdatum von ' + CnvAD( Sel.von.Datum ) + ' bis ' + CnvAD( Sel.bis.Datum );
        else
          vA # vA + 'Rechnungsdatum bis ' + CnvAD( Sel.bis.Datum );

        if ( Sel.bis.Datum2 != 0.0.0 ) then
          vA # vA + 'Fälligkeit bis ' + CnvAD( Sel.bis.Datum );

        if ( Sel.Adr.von.LiNr != 0 ) then begin // Lieferant
          Adr.LieferantenNr # Sel.Adr.von.LiNr;
          if ( RecRead( 100, 3, 0 ) > _rLocked ) then begin
            RecBufClear( 100 );
            vA # vA + ', Lieferant: ' + AInt( Sel.Adr.von.LiNr );
          end
          else
            vA # vA + ', Lieferant: ' + Adr.Stichwort;
        end;

        if ( "Sel.Fin.nurMarkeYN" ) then // nur markierte
          vA # vA + ', nur markierte';
        if ( "Sel.Fin.GelöschteYN" ) then // gelöschte
          vA # vA + ', gelöschte';
        if ( "Sel.Fin.!GelöschteYN" ) then // bestehende
          vA # vA + ', bestehende';

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
      list_Spacing[ 2] # list_Spacing[ 1] + 45.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 40.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 40.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 20.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 20.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 25.0; // 20
      list_Spacing[ 8] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Lieferantenstichwort', n, 0 );
      LF_Set( 2, 'interne Re.Nr.',       n, 0 );
      LF_Set( 3, 'externe Re.Nr.',       n, 0 );
      LF_Set( 4, 'Re.Datum',             y, 0 );
      LF_Set( 5, 'Fälligkeit',           y, 0 );
      LF_Set( 6, 'Restbetrag',           y, 0 );

      if(LIST_XML = true) then begin // nur XML
        LF_Set( 7, 'Rechnungsgewicht',           y, 0 );
        LF_Set( 8, 'Bemerkung',           y, 0 );
      end;

    end;


    'line' : begin
      if ( aPrint ) then begin
        LF_Text( 6, ZahlF( ERe.BruttoW1 - ERe.ZahlungenW1, 2 ) );
        AddSum( 1, ERe.BruttoW1 - ERe.ZahlungenW1 );

        RETURN;
      end;

      LF_Set( 1, '@ERe.LieferStichwort', n, 0 );
      LF_Set( 2, '@ERe.Nummer',       n, 0 );
      LF_Set( 3, '@ERe.Rechnungsnr',     n, 0 );
      LF_Set( 4, '@ERe.Rechnungsdatum',  y, 0 );
      LF_Set( 5, '@ERe.Zieldatum',       y, 0 );
      LF_Set( 6, '#Restbetrag',          y, _LF_Wae );

      if(LIST_XML = true) then begin // nur XML
        LF_Set( 7, '@ERe.Gewicht',          y, _LF_Num);
        LF_Set( 8, '@ERe.Bemerkung', n, 0 );
      end;
    end;


    'lf-summe' : begin
      if ( aPrint ) then begin
        AddSum( 2, GetSum( 1 ) );
        LF_Sum( 6, 1, 2 );
        ResetSum( 1 );

        RETURN;
      end;

      LF_Set( 6, '#Summe',   y, _LF_Wae );
      LF_Set( 0, '##LINE##', n, 5, 6 ); // Linie
    end;


    'gesamt' : begin
      if ( aPrint ) then begin
        AddSum( 2, GetSum( 1 ) );
        LF_Sum( 6, 2, 2 );

        RETURN;
      end;

      LF_Format( _LF_Overline );
      LF_Set( 6, '#Summe', y, _LF_Wae );
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
  vSelTmp   : alpha;
  vSelName  : alpha;
  vSelQ     : alpha(1000);
  vItem     : handle;
  vMFile    : int;
  vMId      : int;
  vLastLfS  : alpha;
end;
begin
  // Sortierung
  if ( aSort = 1 ) then // Lieferantenstichwort
    aSort # 3;
  else if ( aSort = 2 ) then // Fälligkeit
    aSort # 5;
  else
    RETURN;

  /* Selektion */
  if ( "Sel.Fin.GelöschteYN" ) then
    vSelQ # vSelQ + ' OR ("ERe.Löschmarker" = ''*'')';
  if ( "Sel.Fin.!GelöschteYN" ) then
    vSelQ # vSelQ + ' OR ("ERe.Löschmarker" != ''*'' AND ( "ERe.Rest" < -0.9 OR "ERe.Rest" > 0.9 ))';

  if ( vSelQ != '' ) then
    vSelQ # '( ' + StrCut( vSelQ, 4, StrLen( vSelQ ) ) + ' ) ';

  if ( Sel.von.Datum != 0.0.0 ) or ( Sel.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vSelQ, 'ERe.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );

  if ( Sel.bis.Datum2 != 0.0.0 ) then
    Lib_Sel:QDate( var vSelQ, 'ERe.Zieldatum', '=', Sel.bis.Datum2 );

  if ( Sel.Adr.von.LiNr != 0 ) then
    Lib_Sel:QInt( var vSelQ, 'ERe.Lieferant', '=', Sel.Adr.von.LiNr );


  vSel # SelCreate( 560, aSort );
  vSel->SelDefQuery( '', vSelQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  // Nachselektion: nur markierte
  if ( Sel.Fin.nurMarkeYN ) then
    Lib_Sel:IntersectMark( var vSel, var vSelName, 560, aSort );


  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Sel    # LF_NewLine( 'sel' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  lf_LfSum  # LF_NewLine( 'lf-summe' );
  lf_Gesamt # LF_NewLine( 'gesamt' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );
  vLastLfS # '_';

  FOR  Erx # RecRead( 560, vSel, _recFirst );
  LOOP Erx # RecRead( 560, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( aSort != 3 ) then begin // Sortierung nicht nach Lieferantenstichwort, also keine Gruppierung
      LF_Print( lf_Line );
      CYCLE;
    end;

    if ( ERe.LieferStichwort != vLastLfS ) then begin
      // Ausgabe: Lieferantensumme
      if ( vLastLfS != '_' ) then begin
        LF_Print( lf_LfSum );
        LF_Print( lf_Empty );
      end;

      vLastLfS # ERe.LieferStichwort;
    end;

    LF_Print( lf_Line );
  END;

  if ( aSort = 3 ) then begin // Sortierung nach Lieferantenstichwort, also Gruppierung
    if ( vLastLfS != '_' ) then begin
      LF_Print( lf_LfSum );
      LF_Print( lf_Empty );
    end;
  end;

  LF_Print( lf_Gesamt );

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Sel );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_LfSum );
  LF_FreeLine( lf_Gesamt );

  vSel->SelClose();
  SelDelete( 560, vSelName );
end;

//=========================================================================
//=========================================================================