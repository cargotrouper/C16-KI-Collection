@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Rso_160003
//                    OHNE E_R_G
//  Info
//        Liste: Ressourcen / Ausfallursachen Hitliste
//
//  21.07.2010  PW  Erstellung
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
  lf_Empty    : handle;
  lf_Maschine : handle;
  lf_Meldung  : handle;
  lf_Header   : handle;
  lf_Line     : handle;

  gPos    : int;
  gAnzahl : int;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Gv.Int.11   # 0; // Gruppe von
  Gv.Int.12   # 0; // Gruppe bis
  Gv.Int.13   # 0; // Nummer von
  Gv.Int.14   # 0; // Nummer bis
  Gv.Logic.01 # false; // nach Meldungen aufschlüsseln

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.160003', here + ':AusSel' );
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow( gMDI );
end;


//=========================================================================
// AusSel
//        Seitenkopf der Liste
//=========================================================================
sub AusSel ();
begin
  gSelected # 0;
  StartList( 0, '' );
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
begin
  case aName of
    'maschine' : begin
      if ( aPrint ) then begin
        LF_Text( 2, AInt( Rso.Gruppe ) + '/' + AInt( Rso.Nummer ) + ' ' + Rso.Stichwort );

        RETURN;
      end;

      // Spaltenbreiten
      list_Spacing[ 1] # 20.0;
      Lib_List2:ConvertWidthsToSpacings( 2, 190.0 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Bold );
      LF_Set( 1, 'Maschine:', n, 0 );
      LF_Set( 2, '#Maschine', n, 0 );
    end;

     'meldung' : begin
      if ( aPrint ) then begin
        if ( RecLink( 823, 165, 2, _recFirst ) > _rLocked ) then // IHA Meldung
          RecBufClear( 823 );

        LF_Text( 2, AInt( Rso.IHA.Meldung ) + ', ' + IHA.Mld.Bezeichnung );

        RETURN;
      end;

      LF_Set( 1, 'Meldung:', n, 0 );
      LF_Set( 2, '#Meldung', n, 0 );
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      // Spaltenbreiten
      list_Spacing[ 1] # 10.0; // Pos.
      list_Spacing[ 2] # 80.0; // Bezeichnung
      list_Spacing[ 3] # 20.0; // Anzahl
      list_Spacing[ 4] # 40.0; // zuletzt am
      Lib_List2:ConvertWidthsToSpacings( 4, 190.0 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Pos.',        y, 0 );
      LF_Set( 2, 'Bezeichnung', n, 0 );
      LF_Set( 3, 'Anzahl',      y, 0 );
      LF_Set( 4, 'zuletzt am',  n, 0 );
    end;

    'line' : begin
      if ( aPrint ) then begin
        if ( RecLink( 824, 166, 2, _recFirst ) > _rLocked ) then
          RecBufClear( 824 );

        LF_Text( 1, AInt( gPos ) );
        LF_Text( 3, AInt( gAnzahl ) );

        RETURN;
      end;

      LF_Set( 1, '#Pos.',                y, _LF_IntNG );
      LF_Set( 2, '@IHA.Urs.Bezeichnung', n, 0 );
      LF_Set( 3, '#Anzahl',              y, _LF_Num );
      LF_Set( 4, '@Rso.IHA.Termin',      n, _LF_Date );
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
  vPrgr     : handle;
  vSel      : int;
  vSelName  : alpha;
  vSelQ     : alpha(1000);
  vTree     : handle;
  vTree2    : handle;
  vItem     : handle;
  vRecId    : int;
  vKey      : alpha;
  vPrev     : alpha;
end;
begin
  /* Selektion */
  if ( Gv.Int.11 != 0 ) or ( Gv.Int.12 != 0 ) then
    Lib_Sel:QVonBisI( var vSelQ, 'Rso.Urs.Gruppe', Gv.Int.11, Gv.Int.12 );
  if ( Gv.Int.13 != 0 ) or ( Gv.Int.14 != 0 ) then
    Lib_Sel:QVonBisI( var vSelQ, 'Rso.Urs.Ressource', Gv.Int.13, Gv.Int.14 );

  vSel # SelCreate( 166, 1 );
  vSel->SelDefQuery( '', vSelQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  /* Datenbaum */
  BEGIN_BLOCK
    vPrgr  # Lib_Progress:Init( 'Datenerfassung', RecInfo( 166, _recCount, vSel ) );
    vTree2 # CteOpen( _cteTreeCI );

    FOR  Erx # RecRead( 166, vSel, _recFirst );
    LOOP Erx # RecRead( 166, vSel, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then
        BREAK;

      vKey # CnvAI( Rso.Urs.Gruppe, _fmtNumLeadZero, 0, 4 ) + CnvAI( Rso.Urs.Ressource, _fmtNumLeadZero, 0, 4 ) + '#';

      if ( Gv.Logic.01 ) then begin
        // Meldung lesen
        Rso.IHA.Gruppe    # Rso.Urs.Gruppe;
        Rso.IHA.Ressource # Rso.Urs.Ressource;
        Rso.IHA.WartungYN # Rso.Urs.WartungYN;
        Rso.IHA.Nummer    # Rso.Urs.IHA;
        if ( RecRead( 165, 1, 0 ) > _rLocked ) then
          RecBufClear( 165 );

        vKey # vKey + CnvAI( Rso.IHA.Meldung, _fmtNumLeadZero, 0, 4 ) + '##';
      end;

      Sort_ItemAdd( vTree2, vKey + '#|' + CnvAI( Rso.Urs.Ursache, _fmtNumleadZero, 0, 5 ) + '||', 166, RecInfo( 166, _recId ) );
    END;

    vSel->SelClose();
    SelDelete( 166, vSelName );

    if ( Erx <= _rLocked ) then begin
      Sort_KillList( vTree2 );
      RETURN;
    end;
  END_BLOCK;

  BEGIN_BLOCK
    vPrgr->Lib_Progress:Reset( 'Sortierung', CteInfo( vTree2, _cteCount ) );
    vTree # CteOpen( _cteTreeCI );

    FOR  vItem # Sort_ItemFirst( vTree2 );
    LOOP vItem # Sort_ItemNext( vTree2, vItem );
    WHILE ( vItem != 0 ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then
        BREAK;

      RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );

      if ( vPrev != Lib_Strings:Strings_Token( vItem->spName, '||', 1 ) ) then begin
        if ( vPrev != '' ) then begin
          vKey # Lib_Strings:Strings_Token( vPrev, '|', 1 ) + '||' + CnvAI( 1000000 - gAnzahl, _fmtNumLeadZero, 0, 7 );
          Sort_ItemAdd( vTree, vKey + '||' + CnvAI( gAnzahl ) + '||', 166, vRecId );
        end;

        gAnzahl # 0;
        vRecId  # 0;
        vPrev   # Lib_Strings:Strings_Token( vItem->spName, '||', 1 )
      end;

      vRecId  # RecInfo( 166, _recId );
      gAnzahl # gAnzahl + 1;
    END;

    if ( vPrev != '' ) then begin
      vKey # Lib_Strings:Strings_Token( vPrev, '|', 1 ) + '||' + CnvAI( 1000000 - gAnzahl, _fmtNumLeadZero, 0, 7 );
      Sort_ItemAdd( vTree, vKey + '||' + CnvAI( gAnzahl ) + '||', 166, vRecId );
    end;

    Sort_KillList( vTree2 );

    if ( Erx <= _rLocked ) then begin
      Sort_KillList( vTree );
      RETURN;
    end;
  END_BLOCK;


  /* Druckelemente */
  lf_Empty    # LF_NewLine( '' );
  lf_Maschine # LF_NewLine( 'maschine' );
  lf_Meldung  # LF_NewLine( 'meldung' );
  lf_Header   # LF_NewLine( 'header' );
  lf_Line     # LF_NewLine( 'line' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  BEGIN_BLOCK
    vPrgr->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
    vPrev # '';
    vKey  # '';

    FOR  vItem # Sort_ItemFirst( vTree );
    LOOP vItem # Sort_ItemNext( vTree, vItem );
    WHILE ( vItem != 0 ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then
        BREAK;

      RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );

      Rso.Gruppe # Rso.Urs.Gruppe;
      Rso.Nummer # Rso.Urs.Ressource;
      RecRead( 160, 1, 0 );

      Rso.IHA.Gruppe    # Rso.Urs.Gruppe;
      Rso.IHA.Ressource # Rso.Urs.Ressource;
      Rso.IHA.WartungYN # Rso.Urs.WartungYN;
      Rso.IHA.Nummer    # Rso.Urs.IHA;
      RecRead( 165, 1, 0 );

      if ( vPrev != Lib_Strings:Strings_Token( vItem->spName, '|', 1 ) ) then begin
        if ( Gv.Logic.01 ) then begin // Meldungen ausgeben
          if ( vKey != Lib_Strings:Strings_Token( vItem->spName, '#', 1 ) ) then begin
            LF_Print( lf_Empty );
            LF_Print( lf_Maschine );
          end

          LF_Print( lf_Empty );
          LF_Print( lf_Meldung );

          vKey # Lib_Strings:Strings_Token( vItem->spName, '#', 1 );
        end
        else begin
          LF_Print( lf_Empty );
          LF_Print( lf_Maschine );
        end;

        gPos  # 0;
        vPrev # Lib_Strings:Strings_Token( vItem->spName, '|', 1 );
      end;

      gAnzahl # CnvIA( Lib_Strings:Strings_Token( vItem->spName, '||', 3 ) );
      gPos    # gPos + 1;

      LF_Print( lf_Line );
    END;

    Sort_KillList( vTree );

    if ( vItem != 0 ) then
      BREAK;
  END_BLOCK;

  /* Cleanup */
  vPrgr->Lib_Progress:Term();

  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Maschine );
  LF_FreeLine( lf_Meldung );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
end;

//=========================================================================
//=========================================================================