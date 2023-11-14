@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_ERe_560003
//                    OHNE E_R_G
//  Info
//        Liste: Eingangsrechnungen
//
//  16.07.2013  ST  Erstellung der Prozedur
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

define begin
  cSumGewicht : 1
  cSumStueck  : 2
  cSumNetto   : 3
  cGesamtSumGewicht : 4
  cGesamtSumStueck  : 5
  cGesamtSumNetto   : 6

end

local begin
  lf_Empty  : handle;
  lf_Sel    : handle;
  lf_Header : handle;
  lf_Line   : handle;
  lf_KstSum  : handle;
  lf_Gesamt : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.von.Datum          # 0.0.0; // Rechnungsdatum von
  Sel.bis.Datum          # today; // Rechnungsdatum bis
  Sel.Fin.von.KostenSt   #  0;
  Sel.Fin.bis.KostenSt   # 99999;

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.560003', here + ':AusSel' );
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
      list_Spacing[ 1] # 0.0;                       // ReDatum, Rechts
      list_Spacing[ 2] # 180.0;                       // ReDatum, Rechts

      if ( aPrint ) then begin
        vA # 'Selektion: ';

        if ( Sel.von.Datum != 0.0.0 ) then
          vA # vA + 'Rechnungsdatum von ' + CnvAD( Sel.von.Datum ) + ' bis ' + CnvAD( Sel.bis.Datum );
        else
          vA # vA + 'Rechnungsdatum bis ' + CnvAD( Sel.bis.Datum );

        if (vA<>'') then
          vA # vA + ' ';
        if (Sel.Fin.von.KostenSt <> 0) then
          vA # vA + 'Kostenstelle von ' + Aint(Sel.Fin.von.KostenSt) + ' bis ' + Aint( Sel.Fin.bis.KostenSt);
        else
          vA # vA + 'Kostenstelle bis ' + Aint( Sel.Fin.bis.KostenSt);

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

      list_Spacing[ 1] # 0.0;                       // ReDatum, Rechts
      list_Spacing[ 2] # list_Spacing[ 1] + 20.0;   // kostenstelle, links
      list_Spacing[ 3] # list_Spacing[ 2] + 22.0;   // Kontierung, links
      list_Spacing[ 4] # list_Spacing[ 3] + 22.0;   // Gewicht, links
      list_Spacing[ 5] # list_Spacing[ 4] + 25.0;   // Stück, links
      list_Spacing[ 6] # list_Spacing[ 5] + 25.0;   // Netto , links
      list_Spacing[ 7] # list_Spacing[ 6] + 25.0;
      list_Spacing[ 8] # list_Spacing[ 7] + 25.0;   // ReNrIntern , links
      list_Spacing[ 9] # list_Spacing[ 8] + 30.0;   // ReNrExtern, links
      list_Spacing[10] # list_Spacing[ 9] + 15.0;   // RechnuntPos, links
      list_Spacing[11] # list_Spacing[ 10] + 25.0;  // LieferantNr, links
      list_Spacing[12] # list_Spacing[ 11] + 50.0;  // LieferantStw, rechts

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Re-Datum',      n, 0 );
      LF_Set( 2, 'Kst.',          y, 0 );
      LF_Set( 3, 'Kontierung',    y, 0 );
      LF_Set( 4, 'Gewicht',       y, 0 );
      LF_Set( 5, 'Stück',         y, 0 );
      LF_Set( 6, 'NettoBetrag',   y, 0 );
      LF_Set( 7, 'Re-Nr.Intern',  y, 0 );
      LF_Set( 8, 'Re-Nr.Extern',  y, 0 );
      LF_Set( 9, 'Re-Pos',        y, 0 );
      LF_Set(10, 'Lieferant-Nr',  y, 0 );
      LF_Set(11, 'LiefStichw',    n, 0 );
    end;


    'line' : begin
      if ( aPrint ) then begin
        AddSum( cSumGewicht , "Vbk.K.Gewicht");
        AddSum( cSumStueck  , CnvFi("Vbk.K.Stückzahl"));
        AddSum( cSumNetto   , "Vbk.K.BetragW1");
        RETURN;
      end;

      LF_Set( 1, '@ERe.Rechnungsdatum',   n, _LF_Date);
      LF_Set( 2, '@Vbk.K.Kostenstelle',   y, _LF_Int);
      LF_Set( 3, '@Vbk.K.Gegenkonto',     y, _LF_Int);
      LF_Set( 4, '@Vbk.K.Gewicht',        y, _LF_Num);
      LF_Set( 5, '@Vbk.K.Stückzahl',      y, _LF_Int);
      LF_Set( 6, '@Vbk.K.BetragW1',       y, _LF_Wae );
      LF_Set( 7, '@Ere.Nummer',           y, _LF_Int);
      LF_Set( 8, '@ERe.Rechnungsnr',      y, 0);
      LF_Set( 9, '@Vbk.K.EingangsrePos',  y, _LF_Int);
      LF_Set(10, '@Ere.Lieferant',        y, _LF_Int);
      LF_Set(11, '@Ere.LieferStichwort',  n, 0);
    end;


    'kst-summe' : begin

      if ( aPrint ) then begin

        AddSum(cGesamtSumGewicht, GetSum(cSumGewicht));
        AddSum(cGesamtSumStueck , GetSum(cSumStueck));
        AddSum(cGesamtSumNetto  , GetSum(cSumNetto));

        LF_Sum( 4, cSumGewicht, 0 );
        LF_Sum( 5, cSumStueck, 0 );
        LF_Sum( 6, cSumNetto, 2 );

        ResetSum(cSumGewicht);
        ResetSum(cSumStueck);
        ResetSum(cSumNetto);
        RETURN;
      end;

      LF_Set( 0, '##LINE##', n, 1, 7 ); // Linie
      LF_Set( 4, '#Summe',   y, _LF_Int );
      LF_Set( 5, '#Summe',   y, _LF_Int );
      LF_Set( 6, '#Summe',   y, _LF_Wae );
    end;


    'gesamt' : begin
      if ( aPrint ) then begin
        AddSum(cGesamtSumGewicht, GetSum(cSumGewicht));
        AddSum(cGesamtSumStueck , GetSum(cSumStueck));
        AddSum(cGesamtSumNetto  , GetSum(cSumNetto));

        LF_Sum( 4, cGesamtSumGewicht, 0 );
        LF_Sum( 5, cGesamtSumStueck, 0 );
        LF_Sum( 6, cGesamtSumNetto, 2 );
        RETURN;
      end;

      LF_Format( _LF_Overline );
      LF_Set( 4, '#Summe',   y, _LF_Int );
      LF_Set( 5, '#Summe',   y, _LF_Int );
      LF_Set( 6, '#Summe',   y, _LF_Wae );
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
  vSortKey  : alpha;
  vTree     : int;

  vLastLfS  : alpha;
  vProgress : int;

  vKst      : int;
  vLastPrinted : logic;
end;
begin
  // Selektion
  Lib_Sel:QVonBisD( var vSelQ, 'ERe.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );

  vSel # SelCreate( 560, aSort );
  vSel->SelDefQuery( '', vSelQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );


  // Aufarbeitung der Kontierungen
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 560, _recCount, vSel ) );
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  FOR  Erx # RecRead( 560, vSel, _recFirst );
  LOOP Erx # RecRead( 560, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      SelClose(vSel);
      SelDelete(560, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    // Kontierungen Loopen
    FOR   Erx # RecLink(551,560,3,_RecFirst)
    LOOP  Erx # RecLink(551,560,3,_RecNext)
    WHILE  ( Erx <= _rLocked ) DO BEGIN
      if (Vbk.K.Kostenstelle < Sel.Fin.von.KostenSt) OR
         (Vbk.K.Kostenstelle > Sel.Fin.Bis.KostenSt) then
          CYCLE;

      vSortKey # cnvAI(Vbk.K.Kostenstelle,_FmtNumLeadZero|_fmtNumNoGroup,0,8) + Lib_Strings:DateForSort(ERe.Rechnungsdatum);
      Sort_ItemAdd(vTree,vSortKey,551,RecInfo(551,_RecId));
    END;

  END;

  vSel->SelClose();
  SelDelete( 560, vSelName );


  // Druckelemente
  lf_Empty  # LF_NewLine( '' );
  lf_Sel    # LF_NewLine( 'sel' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  lf_KstSum  # LF_NewLine( 'kst-summe' );
  lf_Gesamt # LF_NewLine( 'gesamt' );

  // Listenanzeige
  gFrmMain->WinFocusSet();
  LF_Init( true );


  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset('Listengenerierung', CteInfo(vTree, _cteCount ));

  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) DO BEGIN
    if ( !vProgress->Lib_Progress:Step() ) then begin // Progress
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen
    vLastPrinted  # false;
    if (Vbk.K.Kostenstelle <> vKst) then begin

      if ( GetSum(1) + GetSum(2) + GetSum(3) <> 0.0) then
        LF_Print( lf_KstSum );

      LF_Print( lf_Empty );
    end;
    RekLink(560,551,2,0);// Eingangsrechnung lesen

    LF_Print( lf_Line );
    vKst  # Vbk.K.Kostenstelle;
  END;

  //if (vLastPrinted = false) then begin
    LF_Print( lf_KstSum );
    LF_Print( lf_Empty );
//  end;

  LF_Print( lf_Gesamt );

  vProgress->Lib_Progress:Term();

  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Sel );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_KstSum );
  LF_FreeLine( lf_Gesamt );

end;



//=========================================================================
//=========================================================================