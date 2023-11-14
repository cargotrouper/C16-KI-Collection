@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Lfs_440003
//                    OHNE E_R_G
//  Info
//        Liste: Lieferscheine Ausgang
//
//  14.05.2008  MS  Anpassung fuer Lichtgitter
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
  lf_Line2  : handle;
  lf_Summe  : handle;
  lf_Gesamt : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.von.Datum   # 0.0.0; // Datum von
  Sel.bis.Datum   # today; // Datum bis

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.440003', here + ':AusSel' );
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
begin
  case aName of
    'sel' : begin
      if ( aPrint ) then begin
        if ( Sel.von.Datum != 0.0.0 ) then
          LF_Text( 1, 'Selektion: Lieferdatum von ' + CnvAD( Sel.von.Datum ) + ' bis ' + CnvAD( Sel.bis.Datum ) );
        else
          LF_Text( 1, 'Selektion: Lieferdatum bis ' + CnvAD( Sel.bis.Datum ) );

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
      list_Spacing[ 2] # list_Spacing[ 1] + 10.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 20.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 18.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 48.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 48.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 21.0;
      list_Spacing[ 8] # list_Spacing[ 7] + 25.0;
      list_Spacing[ 9] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Lfs.',         y, 0 );
      LF_Set( 2, 'Datum',       y, 0 );
      LF_Set( 3, 'Auftrag',     y, 0 );
      LF_Set( 4, 'Empfänger',   n, 0 );
      LF_Set( 5, 'Spedition',   n, 0 );
      LF_Set( 6, 'Kennz.',      n, 0 );
      LF_Set( 7, 'Gewicht',     y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        AddSum( 1, Lfs.P.Gewicht.Brutto );

        RETURN;
      end;

      LF_Set( 1, '@Lfs.Nummer',           y, _LF_IntNG );
      LF_Set( 2, '@Lfs.Anlage.Datum',     y, 0 );
      LF_Set( 3, '@Lfs.P.Kommission',     y, 0 );
      LF_Set( 4, '@Adr.Stichwort',        n, 0 );
      LF_Set( 5, '@Lfs.Spediteur',        n, 0 );
      LF_Set( 6, '@Lfs.Kennzeichen',      n, 0 );
      LF_Set( 7, '@Lfs.P.Gewicht.Brutto', y, _LF_Num3, Set.Stellen.Gewicht );
    end;

    'line2' : begin
      if ( aPrint ) then begin
        AddSum( 1, Lfs.P.Gewicht.Brutto );

        RETURN;
      end;

      LF_Set( 3, '@Lfs.P.Kommission',     y, 0 );
      LF_Set( 7, '@Lfs.P.Gewicht.Brutto', y, _LF_Num3, Set.Stellen.Gewicht );
    end;

    'summe' : begin
      if ( aPrint ) then begin
        LF_Sum( 7, 1, Set.Stellen.Gewicht );
        AddSum( 2, GetSum( 1 ) );
        ResetSum( 1 );

        RETURN;
      end;

      LF_Format( _LF_Bold );
      LF_Set( 0, '##LINE##',      n, 7, 8 ); // Linie
      LF_Set( 7, '#Ges. Gewicht', y, _LF_Num3, Set.Stellen.Gewicht );
    end;

    'gesamt' : begin
      if ( aPrint ) then begin
        LF_Sum( 7, 2, Set.Stellen.Gewicht );

        RETURN;
      end;

      LF_Format( _LF_Overline | _LF_Bold );
      LF_Set( 7, '#Ges. Gewicht', y, _LF_Num3, Set.Stellen.Gewicht );
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
  vLastLfs  : int;
end;
begin
  /* Selektion */
  if ( Sel.von.Datum != 0.0.0 ) or ( Sel.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vSelQ, 'Lfs.P.Anlage.Datum', Sel.von.Datum, Sel.bis.Datum );

  vSel # SelCreate( 441, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Sel    # LF_NewLine( 'sel' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  lf_Line2  # LF_NewLine( 'line2' );
  lf_Summe  # LF_NewLine( 'summe' );
  lf_Gesamt # LF_NewLine( 'gesamt' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );
  vLastLfs # -1;

  FOR  Erx # RecRead( 441, vSel, _recFirst );
  LOOP Erx # RecRead( 441, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    RecLink( 440, 441, 1, _recFirst ); // Lieferscheinkopf

    // Empfänger
    if ( Lfs.Kundennummer = 0 ) or ( RecLink( 100, 440, 1, _recFirst ) > _rLocked ) then
        RecBufClear( 100 );

    if ( Lfs.Nummer != vLastLfs ) then begin
      if ( vLastLfs != -1 ) then begin
        LF_Print( lf_Summe );
        LF_Print( lf_Empty );
      end;

      LF_Print( lf_Line );
      vLastLfs # Lfs.Nummer;
    end
    else
      LF_Print( lf_Line2 );
  END;

  if ( vLastLfs != -1 ) then begin
    LF_Print( lf_Summe );
    LF_Print( lf_Empty );
  end;

  LF_Print( lf_Gesamt );

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Sel );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Line2 );
  LF_FreeLine( lf_Summe );
  LF_FreeLine( lf_Gesamt );

  vSel->SelClose();
  SelDelete( 441, vSelName );
end;

//=========================================================================
//=========================================================================