@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Log_995001
//                    OHNE E_R_G
//  Info
//        Liste: Vorgaben / Versionshistorie
//
//  16.09.2008  MS  Erstellung der Prozedur
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
  lf_Line   : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.von.Datum # 0.0.0; // Datum von
  Sel.bis.Datum # today; // Datum bis

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.995001', here + ':AusSel' );
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
    'info' : begin
      if ( aPrint ) then
        RETURN;

      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
      if ( Sel.von.Datum != 0.0.0 ) then
        LF_Set( 1, 'Versionshistorie von ' + CnvAD( Sel.von.Datum ) + ' bis ' + CnvAD( Sel.bis.Datum ), n, 0 );
      else
        LF_Set( 1, 'Versionshistorie bis ' + CnvAD( Sel.bis.Datum ), n, 0 );
      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] +  35.0;
      list_Spacing[ 3] # list_Spacing[ 2] +  20.0;
      list_Spacing[ 4] # list_Spacing[ 3] +  12.0;
      list_Spacing[ 5] # list_Spacing[ 4] +   8.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 180.0;
      list_Spacing[ 7] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Bereich',     n, 0 );
      LF_Set( 2, 'Datum',       y, 0 );
      LF_Set( 3, 'Zeit',        y, 0 );
      LF_Set( 4, 'Std',         n, 0 );
      LF_Set( 5, 'Bemerkung',   n, 0 );
      LF_Set( 6, 'Installdat.', y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        if ( Log.StandardYN ) then
          LF_Text( 4, 'ja' );
        else
          LF_Text( 4, 'nein' );

        RETURN;
      end;

      LF_Set( 1, '@Log.Bereich',          n, 0 );
      LF_Set( 2, '@Log.Datum',            y, 0 );
      LF_Set( 3, '@Log.Zeit',             y, 0 );
      LF_Set( 4, '#Log.StandardYN',       n, 0 );
      LF_Set( 5, '@Log.Bemerkung',        n, 0 );
      LF_Set( 6, '@Log.Installationsdat', y, 0 );
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
end;
begin
  /* Selektion */
  if ( Sel.von.Datum != 0.0.0 ) or ( Sel.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vSelQ, 'Log.Datum', Sel.von.Datum, Sel.bis.Datum );

  vSel # SelCreate( 995, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Info   # LF_NewLine( 'info' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  FOR   Erx # RecRead( 995, vSel, _recFirst );
  LOOP  Erx # RecRead( 995, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_Line );
  END;

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Info );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );

  vSel->SelClose();
  SelDelete( 995, vSelName );
end;

//=========================================================================
//=========================================================================