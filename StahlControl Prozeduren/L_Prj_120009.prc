@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Prj_120009
//                    OHNE E_R_G
//  Info
//        Liste: Projekte Positionsübersicht
//
//  29.10.2007  MS  Erstellung der Prozedur
//  04.08.2008  PW  Selektionsquery
//  18.03.2009  TM  Selektion erweitert um Gelöschte Projekte JN
//  18.06.2009  MS  Selektion um enthaelt Bezeichnung erweitert
//  09.03.2010  ST  Selektionserweitung Projektnummer und nur markierte
//  14.04.2010  PW  Neuer Listenstil
//  20.03.2017  TM  Neue Liste 120.009 zu Prj. 1108/76
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

define begin
  cSumAng           :  1
  cSumIntern        :  2
  cSumPlan          :  3
  cSumPlanZKost     :  4
  cSumZusatzKost    :  5
  cSumGesPlan       :  6
  cSumGesAng        :  7
  cSumGesIntern     :  8
  cSumGesPlanZKost  :  9
  cSumGesZusatzKost : 10
end;

local begin
  lf_Empty   : handle;
  lf_Sel     : handle;
  lf_Header  : handle;
  lf_Line    : handle;
  lf_Group    : handle;
  lf_Summe   : handle;
  lf_Misc    : handle;
  lf_Zeit    : handle;
  lf_Footer  : handle;
  vGrpPrj    : int;
end;

//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.Fin.von.Rechnung # 0;  // nur Projekt
  Sel.Adr.von.Sachbear # ''; // nur Wiedervorlage
  Sel.Adr.von.KdNr     # 0;  // nur Adresse
  Sel.Art.von.Stichwor # ''; // Bezeichnung
  Sel.Art.bis.Stichwor # ''; // oder Bezeichnung
  Sel.Adr.nurMarkeYN   # false; // nur offene
  Sel.Fin.nurMarkeYN   # false; // nur markierte
  Sel.Mat.Werksnummer # ''; // Referenznummer

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.120009', here + ':AusSel' );
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow( gMDI );
  vGrpPrj # -1;
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
  vHdlLst->WinLstDatLineAdd( 'Projektnummer' ); // key 1
  vHdlLst->WinLstDatLineAdd( 'Priorität' ); // key 2
  //vHdlLst->WinLstDatLineAdd( 'Priorität' ); // key 2
  vHdlLst->wpCurrentInt # 1;
  vHdlDlg->WinDialogRun( _winDialogCenter, gMdi );
  vHdlLst->WinLstCellGet( vSortName, 1, _winLstDatLineCurrent );
  vHdlDlg->WinClose();
  //
  if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end

  vSortKey  # gSelected;
  // vSortKey  # 1;
  gSelected # 0;
  StartList( vSortKey, vSortName );
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
local begin
  Erx : int;
  vA  : alpha(500);
end;
begin
  case aName of
    'sel' : begin
      List_FontSize # 12;
      list_Spacing[ 1] # 0.0;

      list_Spacing[ 2] # list_Spacing[ 1] + 277.0;   // 'Nr.',



      if ( aPrint ) then begin
        vA # '';
        if ( Sel.Fin.von.Rechnung != 0 ) then begin
          Prj.Nummer # Sel.Fin.von.Rechnung;
          Erx # RecRead(120,1,0);
          Erx # RecLink(100,120,1,0);

          if ( Sel.Adr.von.KdNr ) = 0 then
            vA # vA + ', Adresse: ' + CnvAI(Prj.Adressnummer,_FmtNumNoGroup) + ' ' + Adr.Stichwort;
          vA # vA + ', Projekt: ' + cnvai(Sel.Fin.von.Rechnung,_FmtNumNoGroup) + ' ' + Prj.Stichwort + ' ' + Prj.Bemerkung;

        end;
        if ( Sel.Adr.von.Sachbear != '' ) then
          vA # vA + ', WV-User: ' + Sel.Adr.von.Sachbear;
        if ( Sel.Adr.von.KdNr != 0 ) then
          vA # vA + ', Adresse: ' + CnvAI( Sel.Adr.von.KdNr );

        if ( Sel.Art.von.Stichwor != '' ) or ( Sel.Art.bis.Stichwor != '' ) then begin
          vA # vA + ', Bezeichnung enthält ';

          if ( Sel.Art.von.Stichwor != '' ) and ( Sel.Art.bis.Stichwor = '' ) then
            vA # vA + '"' + Sel.Art.von.Stichwor + '"';
          else if ( Sel.Art.von.Stichwor = '' ) and ( Sel.Art.bis.Stichwor != '' ) then
            vA # vA + '"' + Sel.Art.bis.Stichwor + '"';
          else
            vA # vA + '"' + Sel.Art.von.Stichwor + '" oder "' + Sel.Art.bis.Stichwor + '"';
        end;

        if ( Sel.Fin.nurMarkeYN ) then
          vA # vA + ', nur markierte';
        if ( "Sel.Adr.nurMarkeYN" ) then
          vA # vA + ', nur offene';

        if (Sel.Mat.Werksnummer !='' ) then               // Einziges verfügbares Selektionsfeld Alpha32
          vA # vA + ', Referenznr. '+strcnv(Sel.Mat.Werksnummer,_strUpper);

        LF_Text( 1, '' + StrCut( vA, 3, StrLen( vA ) ) );

        RETURN;
      end;

      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
      LF_Set( 1, '#Selektion', n, 0 );


      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'header' : begin
      List_FontSize # 8;

      if ( aPrint ) then
        RETURN;


      list_Spacing[ 1] # 0.0;

      list_Spacing[ 2] # list_Spacing[ 1] + 18.0;   // 'Nr.',
      list_Spacing[ 3] # list_Spacing[ 2] + 0.0;    // 'Pos.',
      list_Spacing[ 4] # list_Spacing[ 3] + 0.0;   // 'Adresse',
      list_Spacing[ 5] # list_Spacing[ 4] + 97.0;   // 'Bezeichnung'
      list_Spacing[ 6] # list_Spacing[ 5] + 15.0;   // 'Plan',
      list_Spacing[ 7] # list_Spacing[ 6] + 15.0;   // 'Ang.',
      list_Spacing[ 8] # list_Spacing[ 7] + 15.0;   // 'Ist',
      list_Spacing[ 9] # list_Spacing[ 8] + 15.0;   // 'Prio.',
      list_Spacing[10] # list_Spacing[ 9] + 18.0;   // 'VW-User',
      list_Spacing[11] # list_Spacing[10] + 18.0;   // 'Termin',
      list_Spacing[12] # list_Spacing[11] + 15.0;   // 'Stat.',
      list_Spacing[13] # list_Spacing[12] + 28.0;   // 'Termin',
      list_Spacing[14] # list_Spacing[13] + 28.0;   // 'Stat.',
      list_Spacing[15] # 277.0;

      LF_Format( _LF_Underline | _LF_Bold );

      LF_Set(  1, 'Nr.',            y, 0 );
      LF_Set(  2, '',               y, 0 );
      LF_Set(  3, '',      n, 0 );
      LF_Set(  4, 'Bezeichnung',    n, 0 );
      LF_Set(  5, 'Plan',           y, 0 );
      LF_Set(  6, 'Ang.',           y, 0 );
      LF_Set(  7, 'Ist',            y, 0 );
      LF_Set(  8, 'Prio.',          y, 0 );
      LF_Set(  9, 'VW-User',        n, 0 );
      LF_Set( 10, 'Termin',         y, 0 );
      LF_Set( 11, 'Stat.',          y, 0 );

      LF_Set( 12, 'gepl. Zusatzk.', y, 0 );
      LF_Set( 13, 'Zusatzkosten',   y, 0 );

    end;

    'line' : begin
      if ( aPrint ) then begin

        if (Prj.P.SubPosition=0) then
          LF_Text( 1, cnvai(Prj.Nummer,_FmtNumNoGroup)+'/'+cnvai(Prj.P.Position,_FmtNumNoGroup))
        else
          LF_Text( 1, cnvai(Prj.Nummer,_FmtNumNoGroup)+'/'+cnvai(Prj.P.Position,_FmtNumNoGroup)+'/'+aint(Prj.P.SubPosition));
        // LF_Text( 3, Prj.Stichwort +' '+ Prj.Bemerkung );

        if ( RecLink( 100, 120, 1, _recFirst ) > _rLocked ) then
          RecBufClear( 100 );
        if ( "Prj.P.Lösch.Datum" != 0.0.0 ) then
          LF_Text( 8, DatS( "Prj.P.Lösch.Datum" ) + ' ' + "Prj.P.Lösch.User" );

        AddSum( cSumAng   , Prj.P.Dauer.Angebot );
        AddSum( cSumIntern, Prj.P.Dauer.Intern );
        AddSum( cSumPlan  , Prj.P.Dauer);

        AddSum( cSumGesAng   , Prj.P.Dauer.Angebot );
        AddSum( cSumGesIntern, Prj.P.Dauer.Intern );
        AddSum( cSumGesPlan  , Prj.P.Dauer);

        RETURN;
      end;

      // if (Prj.P.Datum.Ende != 0.0.0) then LF_Format( _LF_Bold );
      LF_Set( 1, 'Prj.Nummer',            y,0 );
      LF_Set( 2, '@Prj.P.Position',       y, _LF_IntNG)
      LF_Set( 3, '',n, 0 );
      LF_Set( 4, '@Prj.P.Bezeichnung',    n, 0 );
      LF_Set( 5, '@Prj.P.Dauer',          y, _LF_Num, 2 );
      LF_Set( 6, '@Prj.P.Dauer.Angebot',  y, _LF_Num, 2 );
      LF_Set( 7, '@Prj.P.Dauer.Intern',   y, _LF_Num, 2 );
      LF_Set( 8, '@Prj.P.Priorität',      y, 0 );
      LF_Set( 9, '@Prj.P.WiedervorlUser', n, 0 );
      LF_Set(10, '@Prj.P.Datum.Ende',     y, 0 );
      LF_Set(11, '@Prj.P.Status',         y, 0 );



    end;

    'group' : begin
      if ( aPrint ) then begin

        LF_Text( 1, cnvai(Prj.Nummer,_FmtNumNoGroup)+'/'+cnvai(Prj.P.Position,_FmtNumNoGroup));
        // LF_Text( 3, Prj.Stichwort +' '+ Prj.Bemerkung );

        if ( RecLink( 100, 120, 1, _recFirst ) > _rLocked ) then
          RecBufClear( 100 );
        if ( "Prj.P.Lösch.Datum" != 0.0.0 ) then
          LF_Text( 8, DatS( "Prj.P.Lösch.Datum" ) + ' ' + "Prj.P.Lösch.User" );

        AddSum( cSumAng   , Prj.P.Dauer.Angebot );
        AddSum( cSumIntern, Prj.P.Dauer.Intern );
        AddSum( cSumPlan  , Prj.P.Dauer);

        AddSum( cSumGesAng   , Prj.P.Dauer.Angebot );
        AddSum( cSumGesIntern, Prj.P.Dauer.Intern );
        AddSum( cSumGesPlan  , Prj.P.Dauer);

        RETURN;
      end;


      LF_Format( _LF_Overline|_LF_Underline|_LF_Bold );
      // if (Prj.P.Datum.Ende != 0.0.0) then LF_Format( _LF_Bold );
      LF_Set( 1, 'Prj.Nummer',            y,0 );
      LF_Set( 2, '@Prj.P.Position',       y, _LF_IntNG)
      LF_Set( 3, '',n, 0 );
      LF_Set( 4, '@Prj.P.Bezeichnung',    n, 0 );
      LF_Set( 5, '@Prj.P.Dauer',          y, _LF_Num, 2 );
      LF_Set( 6, '@Prj.P.Dauer.Angebot',  y, _LF_Num, 2 );
      LF_Set( 7, '@Prj.P.Dauer.Intern',   y, _LF_Num, 2 );
      LF_Set( 8, '@Prj.P.Priorität',      y, 0 );
      LF_Set( 9, '@Prj.P.WiedervorlUser', n, 0 );
      LF_Set(10, '@Prj.P.Datum.Ende',     y, 0 );
      LF_Set(11, '@Prj.P.Status',         y, 0 );



    end;

    'zeit' : begin

      if ( aPrint ) then begin

        LF_Text(4,'Z.Kosten: '+Prj.Z.Bemerkung);

        AddSum( cSumPlanZKost , Prj.Z.ZusKosten.Plan );
        AddSum( cSumZusatzKost, Prj.Z.ZusKosten );

        AddSum( cSumGesPlanZKost , Prj.Z.ZusKosten.Plan );
        AddSum( cSumGesZusatzKost, Prj.Z.ZusKosten );

        RETURN;
      end;

      LF_Set( 1, '', y, 0 );
      LF_Set( 2, '', y, 0 );
      LF_Set( 3, '', y, 0 );
      LF_Set( 4, 'Z.Kosten',n,0);
      LF_Set( 5, '',    n, 0 );
      LF_Set( 6, '', y, 0 );
      LF_Set( 7, '', y, 0 );
      LF_Set( 8, '', y, 0 );
      LF_Set( 9, '', n, 0 );
      LF_Set(10, '', y, 0 );
      LF_Set(11, '', y, 0 );
      LF_Set(12, '@Prj.Z.ZusKosten.Plan', y, 0 );
      LF_Set(13, '@Prj.Z.ZusKosten',      y, 0 );

    end;

    'summe' : begin
      if ( aPrint ) then begin
        LF_Text(4,'Projekt '+cnvai(vGrpPrj,_FmtNumNoGroup));

        LF_Sum( 5, cSumPlan  , 2 );
        LF_Sum( 6, cSumAng   , 2 );
        LF_Sum( 7, cSumIntern, 2 );

        LF_Sum(12, cSumPlanZKost  , 2 );
        LF_Sum(13, cSumZusatzKost , 2 );

        ResetSum( cSumAng    );
        ResetSum( cSumIntern );
        ResetSum( cSumPlan   );

        ResetSum( cSumPlanZKost );
        ResetSum( cSumZusatzKost);

        RETURN;
      end;

      LF_Format( _LF_Overline );
      LF_Set( 1, 'SUMME',n,0)
      LF_Set(4, '',n,0);
      LF_Set( 5, '#Prj.P.Dauer'           , y, _LF_Num, 2 );
      LF_Set( 6, '#Prj.P.Dauer.Angebot'   , y, _LF_Num, 2 );
      LF_Set( 7, '#Prj.P.Dauer.Intern'    , y, _LF_Num, 2 );
      LF_Set(12, '#Prj.P.Zusatzkost.Plan' , y, _LF_Num, 2 );
      LF_Set(13, '#Prj.P.Zusatzkosten'    , y, _LF_Num, 2 );

    end;

    'misc' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 5] # 277.0;
      LF_Set( 4, '@Gv.Alpha.01', n, 0 );
      list_Spacing[ 5] # list_Spacing[ 4] + 68.0;   // 'Bezeichnung'
    end;

    'footer' : begin
      if ( aPrint ) then begin

        LF_Sum( 5, cSumGesPlan  , 2 );
        LF_Sum( 6, cSumGesAng   , 2 );
        LF_Sum( 7, cSumGesIntern, 2 );

        LF_Sum(12, cSumGesPlanZKost  , 2 );
        LF_Sum(13, cSumGesZusatzKost , 2 );

        ResetSum( cSumGesAng    );
        ResetSum( cSumGesIntern );
        ResetSum( cSumGesPlan   );

        ResetSum( cSumGesPlanZKost );
        ResetSum( cSumGesZusatzKost);

        RETURN;
      end;

      LF_Format( _LF_Overline );
      LF_Set( 1, 'GESAMT'           , y,0 );
      LF_Set( 5, '#Prj.P.Dauer'           , y, _LF_Num, 2 );
      LF_Set( 6, '#Prj.P.Dauer.Angebot'   , y, _LF_Num, 2 );
      LF_Set( 7, '#Prj.P.Dauer.Intern'    , y, _LF_Num, 2 );
      LF_Set(12, '#Prj.P.Zusatzkost.Plan' , y, _LF_Num, 2 );
      LF_Set(13, '#Prj.P.Zusatzkosten'    , y, _LF_Num, 2 );

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

  if ( aSeite !=0 ) then begin
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
  vPrgr     : handle;
  vSel      : int;
  vSelName  : alpha;
  vSelQ122  : alpha(1000);
  vSelQ120  : alpha(1000);

  vTree     : handle;
  vItem     : handle;
  vSortKey  : alpha;

  vTxtHdl   : handle;
  vLine     : int;
  vLines    : int;

  vGrpAdr   : int;
  vGrpWvl   : alpha;
  vGrpPri   : int;
end;
begin
  /* Selektion */
  if ( Sel.Art.von.Stichwor != '' ) then
    Lib_Sel:QAlpha( var vSelQ122, 'Prj.P.Bezeichnung', '=*', '*' + Sel.Art.von.Stichwor + '*', 'OR' );
  if ( Sel.Art.bis.Stichwor != '' ) then
    Lib_Sel:QAlpha( var vSelQ122, 'Prj.P.Bezeichnung', '=*', '*' + Sel.Art.bis.Stichwor + '*', 'OR' );


  if ( Sel.Mat.Werksnummer != '' ) then
    Lib_Sel:QAlpha( var vSelQ122, 'Prj.P.Referenznr', '=*^', '*' + Sel.Mat.Werksnummer + '*');


  if ( vSelQ122 != '' ) then
    vSelQ122 # 'LinkCount(Kopf) > 0 AND ( ' + vSelQ122 + ' )';
  else
    vSelQ122 # 'LinkCount(Kopf) > 0 ';

  if( Sel.Adr.nurMarkeYN ) then
    Lib_Sel:QDate( var vSelQ122, 'Prj.P.Lösch.Datum', '=', 0.0.0 );
  if ( Sel.Adr.von.Sachbear != '' ) then
    Lib_Sel:QEnthaeltA( var vSelQ122, 'Prj.P.WiedervorlUser', Sel.Adr.von.Sachbear );
  if ( Sel.Fin.von.Rechnung != 0 ) then
    Lib_Sel:QInt( var vSelQ122, 'Prj.P.Nummer', '=', Sel.Fin.von.Rechnung );

  if ( Sel.Adr.von.KdNr != 0 ) then
    Lib_Sel:QInt( var vSelQ120, 'Prj.Adressnummer', '=', Sel.Adr.von.KdNr );
  if ( Sel.Adr.nurMarkeYN ) then
    Lib_Sel:QAlpha( var vSelQ120, 'Prj.Löschmarker', '!=', '*' );


  vSel # SelCreate( 122, 1 );
  vSel->SelAddLink( '', 120, 122, 2, 'Kopf' );
  vSel->SelDefQuery( '', vSelQ122 );
  vSel->Lib_Sel:QError();
  vSel->SelDefQuery( 'Kopf', vSelQ120 );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  // Nachselektion: nur markierte
  if ( Sel.Fin.nurMarkeYN ) then
    Lib_Sel:IntersectMark( var vSel, var vSelName, 122, 1 );


  /* Datenbaum */
  REPEAT BEGIN
    vPrgr # Lib_Progress:Init( 'Sortierung', RecInfo( 122, _recCount, vSel ) );
    vTree # CteOpen( _cteTreeCI );

    FOR  Erx # RecRead( 122, vSel, _recFirst );
    LOOP Erx # RecRead( 122, vSel, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then begin
        BREAK;
      end;

      RecLink( 120, 122, 2, _recFirst ); // Projekt
      if ( RecLink( 100, 120, 1, _recFirst ) > _rLocked ) then // Adresse
        RecBufClear( 100 );

      case aSort of
        // 1 : vSortKey # Adr.Stichwort + CnvAI( Prj.Adressnummer ) + CnvAI( Prj.Nummer );
        // 2 : vSortKey # Prj.P.WiedervorlUser + CnvAI( Prj.Nummer );
        1 : vSortkey # cnvai(Prj.Nummer,8,0,_FmtNumLeadZero|_FmtNumNoGroup);
        2 : vSortKey # AInt( 100000000 - ( ( "Prj.P.Priorität" * 100000 ) + Prj.Nummer ) );
        // 2 : vSortKey # AInt("Prj.P.Priorität");
      end;
      Sort_ItemAdd( vTree, vSortKey, 122, RecInfo( 122, _recId ) );
      debugx(vSortkey);
    END;

    vSel->SelClose();
    SelDelete( 122, vSelName );

    if ( Erx <= _rLocked ) then begin
      Sort_KillList( vTree );
      RETURN;
    end;
  END UNTIL ( true );

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Sel    # LF_NewLine( 'sel' );
  lf_Header # LF_NewLine( 'header' );
  lf_Line   # LF_NewLine( 'line' );
  lf_Group   # LF_NewLine( 'group' );
  lf_Zeit   # LF_NewLine( 'zeit' );
  lf_Summe  # LF_NewLine( 'summe' );
  lf_Misc   # LF_NewLine( 'misc' );
  lf_Footer # LF_NewLine( 'footer' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  REPEAT BEGIN
    vPrgr->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
    vTxtHdl # TextOpen( 32 );
    vGrpAdr # -1;

    vGrpWvl # '___';
    vGrpPri # -1;
    vGrpPrj # 0;

    FOR  vItem # Sort_ItemFirst( vTree );
    LOOP vItem # Sort_ItemNext( vTree, vItem );
    WHILE ( vItem != 0 ) DO BEGIN
      if ( !vPrgr->Lib_Progress:Step() ) then
        BREAK;

      RecRead( CnvIA( vItem->spCustom ), 0, 0, vItem->spId );
      RecLink( 120, 122, 2, _recFirst ); // Projekt

      case aSort of
        1 : begin // Adresse
          if ( vGrpPrj != Prj.Nummer) and( vGrpPRJ != -1 ) then begin
            LF_Print( lf_Summe );
            LF_Print( lf_Empty );
          end;
          vGrpPrj # Prj.P.Nummer;
        end;
      end;

      if (Prj.P.WiedervorlUser != 'GRUPPE') then
        LF_Print( lf_Line )
      else
        LF_Print( lf_group );

      // Text
      Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1', Prj.P.SubPosition ), vTxtHdl, 0, 0, 0, 0 );
      vLines # vTxtHdl->TextInfo( _textLines );

      if ( vLines > 0 ) then begin
        FOR  vLine # 1;
        LOOP vLine # vLine + 1;
        WHILE ( vLine <= vLines ) DO BEGIN
          Gv.Alpha.01 # vTxtHdl->TextLineRead( vLine, 0 );
          LF_Print( lf_Misc );
        END;
      end;

      // ProjektZeiten
      FOR  Erx # RecLink( 123, 122, 1, _recFirst )
      LOOP Erx # RecLink( 123, 122, 1, _recNext )
      WHILE ( Erx <=_rLocked ) DO BEGIN
        If (Prj.Z.ZusKosten >0.0 or Prj.Z.ZusKosten.Plan>0.0) then begin
          LF_Print( lf_Zeit );

        end;
      END;

    END;
    vTxtHdl->TextClose();

    if ( vItem != 0 ) then
      BREAK;

    LF_Print( lf_Summe );
  END UNTIL ( true );

  LF_Print( lf_Footer );

  /* Cleanup */
  vPrgr->Lib_Progress:Term();
  Sort_KillList( vTree );

  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Sel );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_Group );
  LF_FreeLine( lf_Summe );
  LF_FreeLine( lf_Misc );
  LF_FreeLine( lf_Zeit );
  LF_FreeLine( lf_Footer );
end;

//=========================================================================
//=========================================================================