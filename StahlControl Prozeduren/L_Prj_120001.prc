@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Prj_120001
//                    OHNE E_R_G
//  Info
//        Liste: Projektplan mit Zeiten
//
//  25.09.2007  MS  Erstellung der Prozedur
//  18.06.2009  MS  Selektion um "enthält Bezeichnung" erweitert
//  08.04.2010  PW  Neuer Listenstil
//  23.02.2011  TM  Zeitensummen pro User auf separater Seite wie bei Liste 120002
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
  lf_Empty   : handle;
  lf_End     : handle;
  lf_Sel     : handle;
  lf_Prj1    : handle;
  lf_Prj2    : handle;
  lf_Header  : handle;
  lf_Line    : handle;
  lf_Summe   : handle;
  lf_MiscB   : handle;
  lf_Misc    : handle;
  lf_ZeitenH : handle;
  lf_Zeiten  : handle;
  lf_InternH : handle;
  lf_InternL : handle;
  lf_InternS : handle;
  lf_InternG : handle;
  lf_InternA : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.Art.von.Stichwor  # '';    // Bezeichnung
  Sel.Art.bis.Stichwor  # '';    // oder Bezeichnung
  Sel.Adr.nurMarkeYN    # false; // nur markierte
  "Sel.Fin.GelöschteYN" # true;  // auch gelöschte

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.120001', here + ':AusSel' );
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow( gMDI );
end;


//=========================================================================
// AusSel
//        Seitenkopf der Liste
//=========================================================================
sub AusSel ();
begin
  StartList( 0, '' );
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
        vA # '';
        if ( Sel.Art.von.Stichwor != '' ) or ( Sel.Art.bis.Stichwor != '' ) then begin
          vA # vA + ', Bezeichnung enthält ';

          if ( Sel.Art.von.Stichwor != '' ) and ( Sel.Art.bis.Stichwor = '' ) then
            vA # vA + '"' + Sel.Art.von.Stichwor + '"';
          else if ( Sel.Art.von.Stichwor = '' ) and ( Sel.Art.bis.Stichwor != '' ) then
            vA # vA + '"' + Sel.Art.bis.Stichwor + '"';
          else
            vA # vA + '"' + Sel.Art.von.Stichwor + '" oder "' + Sel.Art.bis.Stichwor + '"';
        end;

        if ( Sel.Adr.nurMarkeYN ) then
          vA # vA + ', nur markierte';
        if ( "Sel.Fin.GelöschteYN" ) then
          vA # vA + ', auch gelöschte';

        LF_Text( 1, 'Selektion: ' + StrCut( vA, 3, StrLen( vA ) ) );

        RETURN;
      end;

      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
      LF_Set( 1, '#Selektion', n, 0 );
      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'projekt-1' : begin
      if ( aPrint ) then begin
        LF_Text( 1, 'Projekt: ' + CnvAI( Prj.Nummer ) + ', ' + Prj.Stichwort );
        if ( RecLink( 100, 120, 1, _recFirst ) <= _rLocked ) then
          LF_Text( 2, 'Adresse: ' + Adr.Stichwort );
        else
          LF_Text( 2, 'Adresse: ' + CnvAI( Prj.Adressnummer ) );

        RETURN;
      end;

      list_Spacing[ 1] #   0.0;
      list_Spacing[ 2] # 110.0;
      list_Spacing[ 3] # 190.0;

      LF_Set( 1, '#Projekt', n, 0 );
      LF_Set( 2, '#Adresse', n, 0 );
    end;

    'projekt-2' : begin
      if ( aPrint ) then begin
        LF_Text( 1, 'Bemerkung: ' + Prj.Bemerkung );
        if ( Prj.Termin.Start != 0.0.0 ) then begin
          if ( Prj.Termin.Ende != 0.0.0 ) then
            LF_Text( 2, 'Zeitraum: ' + DatS( Prj.Termin.Start ) + ' - ' + DatS( Prj.Termin.Ende ) );
          else
            LF_Text( 2, 'Zeitraum: von ' + DatS( Prj.Termin.Start ) );
        end
        else if ( Prj.Termin.Ende != 0.0.0 ) then
          LF_Text( 2, 'Zeitraum: bis ' + DatS( Prj.Termin.Ende ) );

        RETURN;
      end;

      LF_Set( 1, '#Bemerkung', n, 0 );
      LF_Set( 2, '#Zeitraum',  n, 0 );
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] +  10.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 112.0;
      list_Spacing[ 4] # list_Spacing[ 3] +  17.0;
      list_Spacing[ 5] # list_Spacing[ 4] +  17.0;
      list_Spacing[ 6] # list_Spacing[ 5] +  17.0;
      list_Spacing[ 7] # list_Spacing[ 6] +  17.0;
      list_Spacing[ 8] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Nr.',         y, 0 );
      LF_Set( 2, 'Bezeichnung', n, 0 );
      LF_Set( 3, 'Angebot',     y, 0 );
      LF_Set( 4, 'Geplant',     y, 0 );
      LF_Set( 5, 'Intern',      y, 0 );
      LF_Set( 6, 'Extern',      y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        AddSum( 1, Prj.P.Dauer.Angebot );
        AddSum( 2, Prj.P.Dauer );
        AddSum( 3, Prj.P.Dauer.Intern );
        AddSum( 4, Prj.P.Dauer.Extern );

        RETURN;
      end;

      LF_Set( 1, '@Prj.P.Position',      y, _LF_IntNG );
      LF_Set( 2, '@Prj.P.Bezeichnung',   n, 0 );
      LF_Set( 3, '@Prj.P.Dauer.Angebot', y, _LF_Num, 2 );
      LF_Set( 4, '@Prj.P.Dauer',         y, _LF_Num, 2 );
      LF_Set( 5, '@Prj.P.Dauer.Intern',  y, _LF_Num, 2 );
      LF_Set( 6, '@Prj.P.Dauer.Extern',  y, _LF_Num, 2 );
    end;

    'summe' : begin
      if ( aPrint ) then begin
        LF_Sum( 3, 1, 2 );
        LF_Sum( 4, 2, 2 );
        LF_Sum( 5, 3, 2 );
        LF_Sum( 6, 4, 2 );

        RETURN;
      end;

      LF_Format( _LF_Overline | _LF_Bold );
      LF_Set( 3, '#Dauer.Angebot', y, _LF_Num );
      LF_Set( 4, '#Dauer',         y, _LF_Num );
      LF_Set( 5, '#Dauer.Intern',  y, _LF_Num );
      LF_Set( 6, '#Dauer.Extern',  y, _LF_Num );
    end;

    'misc-bold' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 3] # 190.0;
      LF_Format( _LF_Bold );
      LF_Set( 2, '@Gv.Alpha.01', n, 0 );
    end;

    'misc' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 2, '@Gv.Alpha.01', n, 0 );
    end;

    'zeiten-header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 2] # 10.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 20.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 12.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 15.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 25.0;
      list_Spacing[ 7] # 190.0;

      LF_Format( _LF_Bold );
      LF_Set( 2, 'Datum',     y, 0 );
      LF_Set( 3, 'Zeit',      y, 0 );
      LF_Set( 4, 'Dauer',     y, 0 );
      LF_Set( 5, 'User',      n, 0 );
      LF_Set( 6, 'Bemerkung', n, 0 );
      LF_Set( 0, '##LINE##',  y, 2, 7 );
    end;

    'zeiten' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 2, '@Prj.Z.Start.Datum', y, 0 );
      LF_Set( 3, '@Prj.Z.Start.Zeit',  y, 0 );
      LF_Set( 4, '@Prj.Z.Dauer',       y, _LF_Num );
      LF_Set( 5, '@Prj.Z.User',        n, 0 );
      LF_Set( 6, '@Prj.Z.Bemerkung',   n, 0 );
    end;

    'end' : begin
      if ( !aPrint ) then
        LF_Format( _LF_Underline );
    end;


  'intern-header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 30.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 20.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 10.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 20.0;
      list_Spacing[ 6] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Interne Dauer:', n, 0 );
      LF_Set( 2, 'User',           n, 0 );
      LF_Set( 3, 'Pos.',           y, 0 );
      LF_Set( 4, 'Dauer',          y, 0 );
      LF_Set( 5, 'Bemerkung',      n, 0 );
    end;

    'intern-line' : begin
      if ( aPrint ) then begin
        AddSum( 3, Prj.Z.Dauer );

        RETURN;
      end;

      LF_Set( 2, '@Prj.Z.User',      n, 0 );
      LF_Set( 3, '@Prj.Z.Position',  y, _LF_IntNG );
      LF_Set( 4, '@Prj.Z.Dauer',     y, _LF_Num, 2 );
      LF_Set( 5, '@Prj.Z.Bemerkung', n, 0 );
    end;

    'intern-summe' : begin
      if ( aPrint ) then begin
        AddSum( 4, GetSum( 3 ) );
        LF_Sum( 4, 3, 2 );
        ResetSum( 3 );

        RETURN;
      end;

      LF_Set( 4, '#Prj.Z.Dauer', y, _LF_Num );
      LF_Set( 0, '##LINE##',     n, 4, 5 );
    end;

    'intern-gesamt' : begin
      if ( aPrint ) then begin
        LF_Sum( 4, 4, 2 );

        RETURN;
      end;

      LF_Format( _LF_Overline );
      LF_Set( 4, '#Prj.Z.Dauer', y, _LF_Num );
    end;

    'intern-appendix' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] #   0.0;
      list_Spacing[ 2] # 190.0;
      LF_Set( 1, '@Gv.Alpha.01', n, 0 );
    end;















  end;
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf der Liste
//=========================================================================
sub SeitenKopf ( aSeite : int );
begin
  WriteTitel( ' ' + CnvAI( Prj.Nummer ) );
  LF_Print( lf_Empty );
  LF_Print( lf_Prj1 );
  LF_Print( lf_Prj2 );

  if ( aSeite = 1 ) then
    LF_Print( lf_Sel );

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
  vHdl      : handle;
  vSel      : int;
  vSelTmp   : alpha;
  vSelName  : alpha;
  vSelQ     : alpha(1000);
  vTree     : handle;
  vItem     : handle;
  vMFile    : int;
  vMId      : int;

  vTxtHdl   : handle;
  vLine     : int;
  vLines    : int;

  vUser     : alpha;
end;
begin
  /* Selektion */
  if ( Sel.Art.von.Stichwor != '' ) then
    Lib_Sel:QAlpha( var vSelQ, 'Prj.P.Bezeichnung', '=*', '*' + Sel.Art.von.Stichwor + '*', 'OR' );
  if ( Sel.Art.bis.Stichwor != '' ) then
    Lib_Sel:QAlpha( var vSelQ, 'Prj.P.Bezeichnung', '=*', '*' + Sel.Art.bis.Stichwor + '*', 'OR' );
  if ( vSelQ != '' ) then
    vSelQ # '( ' + vSelQ + ' )';

  if( !"Sel.Fin.GelöschteYN" ) then
    Lib_Sel:QDate( var vSelQ, 'Prj.P.Lösch.Datum', '=', 0.0.0 );
  Lib_Sel:QInt( var vSelQ, 'Prj.P.Nummer', '=', Prj.Nummer );

  vSel # SelCreate( 122, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  // Nachselektion: nur markierte
  if ( Sel.Fin.nurMarkeYN ) then
    Lib_Sel:IntersectMark( var vSel, var vSelName, 122, 1 );


  /* Druckelemente */
  lf_Empty   # LF_NewLine( '' );
  lf_End     # LF_NewLine( 'end' );
  lf_Sel     # LF_NewLine( 'sel' );
  lf_Prj1    # LF_NewLine( 'projekt-1' );
  lf_Prj2    # LF_NewLine( 'projekt-2' );
  lf_Header  # LF_NewLine( 'header' );
  lf_Line    # LF_NewLine( 'line' );
  lf_Summe   # LF_NewLine( 'summe' );
  lf_MiscB   # LF_NewLine( 'misc-bold' );
  lf_Misc    # LF_NewLine( 'misc' );
  lf_ZeitenH # LF_NewLine( 'zeiten-header' );
  lf_Zeiten  # LF_NewLine( 'zeiten' );

  lf_InternH # LF_NewLine( 'intern-header' );
  lf_InternL # LF_NewLine( 'intern-line' );
  lf_InternS # LF_NewLine( 'intern-summe' );
  lf_InternG # LF_NewLine( 'intern-gesamt' );
  lf_InternA # LF_NewLine( 'intern-appendix' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );
  vTxtHdl # TextOpen( 32 );
  vTree   # CteOpen( _cteTreeCI );


  FOR  Erx # RecRead( 122, vSel, _recFirst );
  LOOP Erx # RecRead( 122, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    LF_Print( lf_Line );

    Gv.Alpha.01 # 'Wiedervorl.: ' + Prj.P.WiedervorlUser + ' / Status: ' + AInt( Prj.P.Status ) + ' (' + Stt.Bezeichnung + ')';
    LF_Print( lf_Misc );

    if ( "Prj.P.Lösch.Datum" != 0.0.0 ) then begin
      Gv.Alpha.01 # 'gelöscht am ' + CnvAD( "Prj.P.Lösch.Datum" ) + ' durch ' + "Prj.P.Lösch.User" + ': ' + "Prj.P.Lösch.Grund";
      LF_Print( lf_Misc );
    end;

    // Text
    Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1' ), vTxtHdl, 0, 0, 0, 0 );
    vLines # vTxtHdl->TextInfo( _textLines );

    if ( vLines > 0 ) then begin
      Gv.Alpha.01 # 'Beschreibung';
      LF_Print( lf_Empty );
      LF_Print( lf_MiscB );

      FOR  vLine # 1;
      LOOP vLine # vLine + 1;
      WHILE ( vLine <= vLines ) DO BEGIN
        Gv.Alpha.01 # vTxtHdl->TextLineRead( vLine, 0 );
        LF_Print( lf_Misc );
      END;
    end;

    // Interner Text
    Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2' ), vTxtHdl, 0, 0, 0, 0 );
    vLines # vTxtHdl->TextInfo( _textLines );

    if ( vLines > 0 ) then begin
      Gv.Alpha.01 # 'Interner Text';
      LF_Print( lf_Empty );
      LF_Print( lf_MiscB );

      FOR  vLine # 1;
      LOOP vLine # vLine + 1;
      WHILE ( vLine <= vLines ) DO BEGIN
        Gv.Alpha.01 # vTxtHdl->TextLineRead( vLine, 0 );
        LF_Print( lf_Misc );
      END;
    end;

    LF_Print( lf_Empty );
    LF_Print( lf_End );

    // Zeiten
    if ( RecLinkInfo( 123, 122, 1, _recCount ) > 0 ) then begin
      LF_Print( lf_Empty );
      LF_Print( lf_ZeitenH );

      FOR  Erx # RecLink( 123, 122, 1, _recFirst );
      LOOP Erx # RecLink( 123, 122, 1, _recNext );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        LF_Print( lf_Zeiten );
        Sort_ItemAdd( vTree, Prj.Z.User + '|' + CnvAI( Prj.Z.Position, _fmtNumNoGroup | _fmtNumLeadZero, 0, 3 ), 123, RecInfo( 123, _recId ) );

      END;
    end;


  END;
  vTxtHdl->TextClose();

  LF_Print( lf_Empty );
  LF_Print( lf_Summe );

  // --- NEU:

  ResetSum( 1 );
  ResetSum( 2 );
  ResetSum( 3 );
  ResetSum( 4 );


  vHdl # form_Footer;
  form_Footer # 0;
  Lib_Print:Print_FF();
  form_Footer # vHdl;

  FOR  vItem # Sort_ItemFirst( vTree );
  LOOP vItem # Sort_ItemNext( vTree, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );
    if ( vUser != Prj.Z.User ) then begin
      if ( vUser != '' ) then
        LF_Print( lf_InternS );

      LF_Print( lf_Empty );
      vUser # Prj.Z.User;
    end;
    LF_Print( lf_InternL );
  END;

  if ( vUser != '' ) then
    LF_Print( lf_InternS );

  LF_Print( lf_Empty );
  LF_Print( lf_InternG );

  // Appendix
  Gv.Alpha.01 # Set.Prj.Cust1 + ': ' + ANum( Prj.Cust.Wert1, 2 );
  LF_Print( lf_Empty );
  LF_Print( lf_Empty );
  LF_Print( lf_InternA );


  // ---


  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_End );
  LF_FreeLine( lf_Sel );
  LF_FreeLine( lf_Prj1 );
  LF_FreeLine( lf_Prj2 );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Summe );
  LF_FreeLine( lf_MiscB );
  LF_FreeLine( lf_Misc );
  LF_FreeLine( lf_ZeitenH );
  LF_FreeLine( lf_Zeiten );
  LF_FreeLine( lf_InternH );
  LF_FreeLine( lf_InternL );
  LF_FreeLine( lf_InternS );
  LF_FreeLine( lf_InternG );
  LF_FreeLine( lf_InternA );
  vSel->SelClose();
  SelDelete( 560, vSelName );
end;

//=========================================================================
//=========================================================================