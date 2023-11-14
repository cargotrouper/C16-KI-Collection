@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Con_950003
//                    OHNE E_R_G
//  Info
//        Liste: Controlling Kurzauswertung
//
//  05.08.2011  ST  Erstellung
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
  c_iMon : Gv.Int.02
  c_Jahr : Gv.Int.01
  c_iVorg : Gv.Int.03

  cLf_Mon : Gv.Alpha.01
  cLf_Ton : GV.Num.01
  cLf_Ver : GV.Num.02
  cLf_EgE : GV.Num.03
  cLf_DB  : GV.Num.04
  cLf_DBt : GV.Num.05
  cLf_VKt : GV.Num.06
end

local begin
  lf_Empty  : handle;
  lf_Sel    : handle;
  lf_Header : handle;
  lf_Line   : handle;
  lf_Summe  : handle;
  lf_SummeGes  : handle;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
local begin

  vAbfrage  : alpha;
  vDatum    : date;
end
begin

  vDatum # Sysdate();
  c_Jahr # vDatum->vpYear;

  // Selektion für Jahr
  vAbfrage # Aint(c_Jahr);
  if !(Dlg_Standard:Standard('gewünschtes Jahr',  var vAbfrage, false, 4)) then
    RETURN;

  c_Jahr # CnvIa(vAbfrage);
  if (c_Jahr < 1900) then begin
    c_Jahr # vDatum->vpYear;
  end;

  // Abfrage Vorgangsart
  vAbfrage # Aint(c_iVorg);
  if !(Dlg_Standard:Standard('Vorgangsart',  var vAbfrage, false)) then
    RETURN;
  c_iVorg # CnvIa(vAbfrage);

  StartList( 0, '' );
  /*
  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.950003', here + ':AusSel' );
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow( gMDI );
  */
end;


//=========================================================================
// AusSel
//        Seitenkopf der Liste
//=========================================================================
sub AusSel ();
begin
/*
  gSelected # 0;
  StartList( 0, '' );
*/
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
local begin
  vA : alpha(500);
  vB : alpha(500);
  vConTyp  : alpha; // Soll, Ist, Sim
  vConWert : alpha; // Menge, Umsatz, DB

  vEinGewaEinst : float;
  vDBto : float;
  vDurchVK : float;
  vFld : alpha;

  vTonFakt : float;
end;
begin

  case aName of
    'sel' : begin
      if ( aPrint ) then begin
        if ( list_XML ) then
          LF_Text( 1, 'Liste: ' + CnvAI( Lfm.Nummer ) );

        vA # 'Jahr ' + Aint(c_Jahr);
        LF_Text( 2, 'Selektion: ' + StrCut( vA, 1, StrLen( vA ) - 1 ) );

        RETURN;
      end;

      list_Spacing[ 3] # 190.0;
      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
      if ( list_XML ) then
        LF_Set( 1, '#Listennummer', n, 0 );
      LF_Set( 2, '#Selektion', n, 0 );
      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      // Spaltenbreiten
      list_Spacing[ 1] # 20.0; // Monat
      list_Spacing[ 2] # 15.0; // Aufart
      list_Spacing[ 3] # 15.0; // Wgr
      list_Spacing[ 4] # 35.0; // Tonnage
      list_Spacing[ 5] # 35.0; // Verkauf
      list_Spacing[ 6] # 35.0; // Einkauf gew. Einstand
      list_Spacing[ 7] # 35.0; // DB
      list_Spacing[ 8] # 35.0; // DB/to
      list_Spacing[ 9] # 35.0; // Durchschn. VK/t
      list_Spacing[ 10] # 35.0; // spacer

      Lib_List2:ConvertWidthsToSpacings( 10 ); // Spaltenbreiten konvertieren

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set(  1, 'Monat',          n, 0 );
      LF_Set(  2, 'VorgArt',        y, 0 );
      LF_Set(  3, 'Wgr',            y, 0 );
      LF_Set(  4, 'Tonnage',        y, 0 );
      LF_Set(  5, 'Verkauf',        y, 0 );
      LF_Set(  6, 'Ein.gew.Einst.', y, 0 );
      LF_Set(  7, 'DB',             y, 0 );
      LF_Set(  8, 'DB/to',          y, 0 );
      LF_Set(  9, 'Durch.VK/t',     y, 0 );
    end;

    'line' : begin

      if ( aPrint ) then begin
        if (c_iMon > 0) then begin

          if (Con.MEH = 't') then
            vTonFakt # 1.0;
          if (Con.MEH = 'kg') then
            vTonFakt # 1000.0;

          cLf_Mon # Aint(c_iMon) + '/' + Aint(Con.Jahr);
          cLf_Ton # FldFloatByName('Con.Ist.Menge.' + Aint(c_iMon)) / vTonFakt;
          cLf_Ver # FldFloatByName('Con.Ist.Umsatz.' + Aint(c_iMon));
          cLf_EgE # FldFloatByName('Con.Ist.Umsatz.'+Aint(c_iMon)) -
                          FldFloatByName('Con.Ist.DB.'+Aint(c_iMon));
          cLf_DB  # FldFloatByName('Con.Ist.DB.' + Aint(c_iMon));

          if (FldFloatByName('Con.Ist.Menge.'+Aint(c_iMon)) <> 0.0) then begin
            cLf_DBt # FldFloatByName('Con.Ist.DB.'+Aint(c_iMon)) /
                            FldFloatByName('Con.Ist.Menge.'+Aint(c_iMon)) * vTonFakt;

            cLf_VKt # FldFloatByName('Con.Ist.Umsatz.'+Aint(c_iMon)) /
                            FldFloatByName('Con.Ist.Menge.'+Aint(c_iMon)) * vTonFakt;
          end;


          // Summen Monat
          AddSum(1,cLf_Ton);
          AddSum(2,cLf_Ver);
          AddSum(3,cLf_DB);
          if (GetSum(1) <> 0.0) then begin
            SetSum(4,GetSum(3)/GetSum(1));
            SetSum(5,GetSum(2)/GetSum(1));
          end;

          // Summen Gesamt
          AddSum(10,cLf_Ton);
          AddSum(20,cLf_Ver);
          AddSum(30,cLf_DB);
          if (GetSum(10) <> 0.0) then begin
            SetSum(40,GetSum(30)/GetSum(10));
            SetSum(50,GetSum(20)/GetSum(10));
          end;
        end;

        RETURN;
      end;

      LF_Set(  1, '@Gv.Alpha.01'    , n, 0 );
      LF_Set(  2, '@Con.Auftragsart', y, 0 );
      LF_Set(  3, '@Con.Warengruppe', y, 0 );
      LF_Set(  4, '@GV.Num.01'      , y, 0 );       // Tonnage
      LF_Set(  5, '@GV.Num.02'      , y, _LF_Wae);  // Verkauf
      LF_Set(  6, '@GV.Num.03'      , y, _LF_Wae);  // Einkauf gew. Einst
      LF_Set(  7, '@GV.Num.04'      , y, _LF_Wae);  // DB
      LF_Set(  8, '@GV.Num.05'      , y, _LF_Wae);  // Einkauf gew. Einst
      LF_Set(  9, '@GV.Num.06'      , y, _LF_Wae);  // Durchschn. VK/t
    end;


    'summe' : begin

      if ( aPrint ) then begin
        LF_Sum(4 ,1, Set.Stellen.Gewicht);
        LF_Sum(5 ,2, 2);
        LF_Sum(7 ,3, 2);
        LF_Sum(8 ,4, 2);
        LF_Sum(9 ,5, 2);
        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(4, 'SUM1'                 ,y , _LF_NUM, Set.Stellen.Gewicht);
      LF_Set(5, 'SUM2'                 ,y , _LF_WAE);
      LF_Set(7, 'SUM3'                 ,y , _LF_WAE);
      LF_Set(8, 'SUM4'                 ,y , _LF_WAE);
      LF_Set(9, 'SUM5'                 ,y , _LF_WAE);
    end;

  'summeges' : begin

      if ( aPrint ) then begin
        LF_Sum(4 ,10, Set.Stellen.Gewicht);
        LF_Sum(5 ,20, 2);
        LF_Sum(7 ,30, 2);
        LF_Sum(8 ,40, 2);
        LF_Sum(9 ,50, 2);
        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(4, 'SUM10'                 ,y , _LF_NUM, Set.Stellen.Gewicht);
      LF_Set(5, 'SUM20'                 ,y , _LF_WAE);
      LF_Set(7, 'SUM30'                 ,y , _LF_WAE);
      LF_Set(8, 'SUM40'                 ,y , _LF_WAE);
      LF_Set(9, 'SUM50'                 ,y , _LF_WAE);
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
  vPrgr    : handle;
  vSel     : int;
  vSelName : alpha;
  vSelQ    : alpha(1000);
  vItem    : handle;
  vMFile   : int;
  vMId     : int;

  vProgress   : handle;
  vTree       : int;
  vSortKey    : alpha;


  vLastLfS : alpha;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Alle Controlling einträge aus angegebenem Jahr mit AufArt + Wgr gefüllt, Rest leer
  // Sortiert nach Jahr, AufArt + Wgrp

  /* Selektion */
  vSelQ # '';
  Lib_Sel:QInt(    var vSelQ, 'CON.Jahr', '=', c_Jahr );
  if (c_iVorg = 0) then
    Lib_Sel:QInt(    var vSelQ, 'Con.Auftragsart', '<>', 0);
  else
    Lib_Sel:QInt(    var vSelQ, 'Con.Auftragsart', '=', c_iVorg);

  Lib_Sel:QInt(    var vSelQ, 'Con.Warengruppe', '<>', 0);

  // nur obige Felder dürfen gefüllt sein
  Lib_Sel:QInt(    var vSelQ, 'CON.Adressnummer', '=', 0);
  Lib_Sel:QInt(    var vSelQ, 'CON.Vertreternr', '=', 0);
  Lib_Sel:QInt(    var vSelQ, 'CON.Artikelgruppe', '=', 0);
  Lib_Sel:QAlpha(  var vSelQ, 'CON.Artikelnummer', '=', '');

  vSel # SelCreate( 950, 1 );
  erx # vSel->SelDefQuery( '', vSelQ );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );
  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 950, _recCount, vSel ) );

  FOR Erx # RecRead(950, vSel, _recFirst);
  LOOP Erx # RecRead(950, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      SelClose(vSel);
      SelDelete(950, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    vSortKey #             cnvAI("Con.Jahr",       _FmtNumNoGroup | _FmtNumLeadZero,0,4);
    vSortKey # vSortKey  + cnvAI("Con.Auftragsart",_FmtNumNoGroup |_FmtNumLeadZero,0,6);
    vSortKey # vSortKey  + cnvAI("Con.Warengruppe",_FmtNumNoGroup |_FmtNumLeadZero,0,6);

    Sort_ItemAdd(vTree,vSortKey,950,RecInfo(950,_RecId));
  END;
  SelClose(vSel);
  SelDelete(950, vSelName);

  /* Druckelemente */
  lf_Empty    # LF_NewLine( '' );
  lf_Sel      # LF_NewLine( 'sel' );
  lf_Header   # LF_NewLine( 'header' );
  lf_Line     # LF_NewLine( 'line' );
  lf_Summe    # LF_NewLine( 'summe' );
  lf_Summeges # LF_NewLine( 'summeges' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  //vProgress # Lib_Progress:Init( 'Listengenerierung', RecInfo( 950, _recCount, vSel)*12 );
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount )*12 );

  // Durchlauf 1 bis 12 für jeden Monat
  FOR c_iMon # 1
  LOOP inc(c_iMon)
  WHILE (c_iMon <= 12) DO BEGIN

    SetSum(1,0.0);
    SetSum(2,0.0);
    SetSum(3,0.0);
    SetSum(4,0.0);
    SetSum(5,0.0);

    // Durchlauf alle Controllingdatensätze und Monatsausgabe
    // RAMBAUM
    FOR   vItem # Sort_ItemFirst(vTree)
    loop  vItem # Sort_ItemNext(vTree,vItem)
    WHILE (vItem != 0) do begin
      // Progress
      if ( !vProgress->Lib_Progress:Step() ) then begin
        Sort_KillList(vTree);
        vProgress->Lib_Progress:Term();
        RETURN;
      end;

      // Datensatz holen
      RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID);
      LF_Print( lf_Line );

      // Berechnete Werte zurücksetzen
      cLf_Ton # 0.0;
      cLf_Ver # 0.0;
      cLf_EgE # 0.0;
      cLf_DB  # 0.0;
      cLf_DBt # 0.0;
      cLf_VKt # 0.0;

    END;

    LF_Print( lf_summe );
    LF_Print( lf_empty );

  END;
  LF_Print( lf_summeges );

  // Löschen der Liste
  Sort_KillList(vTree);

  /* Cleanup */
  vProgress->Lib_Progress:Term();
//  vSel->SelClose();
//  SelDelete( 950, vSelName );

  LF_Term();
  LF_FreeLine( lf_Empty  );
  LF_FreeLine( lf_Sel );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Summe );
  LF_FreeLine( lf_SummeGes );

/*
  LF_FreeLine( lf_LineVU );
  LF_FreeLine( lf_LineVD );
  LF_FreeLine( lf_LineIM );
  LF_FreeLine( lf_LineIU );
  LF_FreeLine( lf_LineID );
  LF_FreeLine( lf_LineSM );
  LF_FreeLine( lf_LineSU );
  LF_FreeLine( lf_LineSD );
*/
end;

//=========================================================================
//=========================================================================