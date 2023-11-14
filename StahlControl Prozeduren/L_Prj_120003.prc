@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Prj_120003
//                    OHNE E_R_G
//  Info
//        Liste: Projekte Zeiten
//
//  08.10.2007  MS  Erstellung der Prozedur
//  04.08.2008  PW  Selektionsquery
//  08.04.2010  PW  Neuer Listenstil
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
  lf_Sel     : handle;
  lf_Header  : handle;
  lf_Line    : handle;
  lf_Summe   : handle;
  lf_Gesamt  : handle;
end;

//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.von.Datum          # 0.0.0; // Datum von
  Sel.bis.Datum          # today; // Datum bis
  "Sel.Fin.GelöschteYN"  # true;  // offene Projekte
  "Sel.Fin.!GelöschteYN" # true;  // erledigte Projekte

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.120003', here + ':AusSel' );
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
  vHdlLst->WinLstDatLineAdd( 'Kunde' ); // key 1
  vHdlLst->WinLstDatLineAdd( 'User' ); // key 2
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
  vA : alpha(500);
end;
begin
  case aName of
    'sel' : begin
      if ( aPrint ) then begin
        vA # 'Selektion: ';
        if ( Sel.von.Datum != 0.0.0 ) then
          vA # vA + 'Datum von ' + CnvAD( Sel.von.Datum ) + ' bis ' + CnvAD( Sel.bis.Datum );
        else
          vA # vA + 'Datum bis ' + CnvAD( Sel.bis.Datum );

        if ( "Sel.Fin.GelöschteYN" ) then
          vA # vA + ', offene Projekte';
        if ( "Sel.Fin.!GelöschteYN" ) then
          vA # vA + ', erledigte Projekte';

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
      list_Spacing[ 2] # list_Spacing[ 1] + 50.0;
      list_Spacing[ 3] # list_Spacing[ 2];
      list_Spacing[ 4] # list_Spacing[ 3] + 10.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 10.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 25.0;
      list_Spacing[ 7] # list_Spacing[ 6] + 25.0;
      list_Spacing[ 8] # list_Spacing[ 7] + 20.0;
      list_Spacing[ 9] # 190.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Kunde',    n, 0 );
      LF_Set( 3, 'Prj.',     y, 0 );
      LF_Set( 4, 'Pos.',     y, 0 );
      LF_Set( 5, 'Datum',    y, 0 );
      LF_Set( 6, 'Dauer',    y, 0 );
      LF_Set( 7, 'User',     n, 0 );
      LF_Set( 8, 'Erledigt', n, 0 );

      list_Spacing[ 2] # list_Spacing[ 1] + 10.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 40.0;
    end;

    'line' : begin
      if ( aPrint ) then begin
        if ( RecLink( 100, 120, 1, _recFirst ) > _rLocked ) then
          RecBufClear( 100 );
        if ( "Prj.P.Lösch.Datum" != 0.0.0 ) then
          LF_Text( 8, DatS( "Prj.P.Lösch.Datum" ) + ' ' + "Prj.P.Lösch.User" );

        AddSum( 1, Prj.Z.Dauer );

        RETURN;
      end;

      LF_Set( 1, '@Prj.Adressnummer',  y, _LF_IntNG );
      LF_Set( 2, '@Adr.Stichwort',     n, 0 );
      LF_Set( 3, '@Prj.Nummer',        y, _LF_IntNG );
      LF_Set( 4, '@Prj.P.Position',    y, _LF_IntNG );
      LF_Set( 5, '@Prj.Z.Start.Datum', y, 0 );
      LF_Set( 6, '@Prj.Z.Dauer',       y, _LF_Num, 2 );
      LF_Set( 7, '@Prj.Z.User',        n, 0 );
      LF_Set( 8, '#erledigt',          n, 0 );
    end;

    'summe' : begin
      if ( aPrint ) then begin
        AddSum( 2, GetSum( 1 ) );
        LF_Sum( 6, 1, 2 );
        ResetSum( 1 );

        RETURN;
      end;

      LF_Set( 6, '#Prj.Z.Dauer', y, _LF_Num, 2 );
      LF_Set( 0, '##LINE##', n, 6, 7 ); // Linie
    end;

    'gesamt' : begin
      if ( aPrint ) then begin
        AddSum( 2, GetSum( 1 ) );
        LF_Sum( 6, 2, 2 );

        RETURN;
      end;

      LF_Format( _LF_Overline );
      LF_Set( 6, '#Prj.Z.Dauer', y, _LF_Num, 2 );
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
  vSelQ122  : alpha(1000);
  vSelQ123  : alpha(1000);
  vTree     : handle;
  vItem     : handle;
  vSortKey  : alpha;
  vUser     : alpha;
  vKunde    : int;
end;
begin
  /* Selektion */
  vSelQ122 # 'LinkCount(Zeiten) > 0';

  if ( "Sel.Fin.GelöschteYN" ) AND ( !"Sel.Fin.!GelöschteYN" ) then
    Lib_Sel:QDate( var vSelQ122, 'Prj.P.Lösch.Datum', '=', 0.0.0 );

  else if ( !"Sel.Fin.GelöschteYN" ) AND ( "Sel.Fin.!GelöschteYN" ) then
    Lib_Sel:QDate( var vSelQ122, 'Prj.P.Lösch.Datum', '>', 0.0.0 );

  if ( Sel.von.Datum != 0.0.0 ) or ( Sel.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vSelQ123, 'Prj.Z.Start.Datum', Sel.von.Datum, Sel.bis.Datum );

  vSel # SelCreate( 120, 1 );
  vSel->SelAddLink( '',    122, 120, 4, 'Pos');
  vSel->SelAddLink( 'Pos', 123, 122, 1, 'Zeiten');
  vSel->SelDefQuery( '', 'LinkCount(Pos) > 0' );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery( 'Pos', vSelQ122 );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery( 'Zeiten', vSelQ123 );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  /* Datenbaum */
  vTree # CteOpen( _cteTreeCI );

  FOR  Erx # RecRead( 120, vSel, _recFirst );
  LOOP Erx # RecRead( 120, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN // Projekte
    FOR  Erx # RecLink( 122, 120, 4, _recFirst );
    LOOP Erx # RecLink( 122, 120, 4, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN // Positionen
      FOR  Erx # RecLink( 123, 122, 1, _recFirst );
      LOOP Erx # RecLink( 123, 122, 1, _recNext );
      WHILE ( Erx <= _rLocked ) DO BEGIN // Zeiten
        if ( Prj.Z.Start.Datum < Sel.von.Datum ) or ( Prj.Z.Start.Datum > Sel.bis.Datum ) then
          CYCLE;

        case aSort of
          1 : vSortKey # CnvAI( Prj.Adressnummer, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 ) + '|' + CnvAI( CnvID( Prj.Z.Start.Datum ) );
          2 : vSortKey # Prj.Z.User + '|' + CnvAI( CnvID( Prj.Z.Start.Datum ) );
        end;
        Sort_ItemAdd( vTree, vSortKey, 123, RecInfo( 123, _recId ) );
      END;
    END;
  END;

  vSel->SelClose();
  SelDelete( 120, vSelName );


  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Sel    # LF_NewLine( 'sel' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  lf_Summe  # LF_NewLine( 'summe' );
  lf_Gesamt # LF_NewLine( 'gesamt' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );
  vKunde # -1;
  vUser  # '___';

  FOR  vItem # Sort_ItemFirst( vTree );
  LOOP vItem # Sort_ItemNext( vTree, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );
    RecLink( 122, 123, 1, _recFirst ); // Projektposition
    RecLink( 120, 123, 2, _recFirst ); // Projekt

    if ( aSort = 1 ) then begin // Kunde
      if ( vKunde != Prj.Adressnummer ) and ( vKunde != -1 ) then begin
        LF_Print( lf_Summe );
        LF_Print( lf_Empty );
      end;
    end
    else if ( aSort = 2 ) then begin // User
      if ( vUser != Prj.Z.User ) and ( vUser != '___' ) then begin
        LF_Print( lf_Summe );
        LF_Print( lf_Empty );
      end;
    end;

    vKunde # Prj.Adressnummer;
    vUser  # Prj.Z.User;
    LF_Print( lf_Line );
  END;

  if ( vKunde != -1 ) or ( vUser != '___' ) then begin
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
  LF_FreeLine( lf_Summe );
  LF_FreeLine( lf_Gesamt );
  Sort_KillList( vTree );
end;

//=========================================================================
//=========================================================================