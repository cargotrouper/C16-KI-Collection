@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Con_950002
//                    OHNE E_R_G
//  Info
//        Liste: Controlling Einzelsummen
//
//  20.07.2010  PW  Erstellung
//  27.09.2012  ST  Fehlerkorrektur, Spalte 1
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
  lf_LineVM : handle; // Vorgabe (Soll) & Menge
  lf_LineVU : handle; // Vorgabe (Soll) & Umsatz
  lf_LineVD : handle; // Vorgabe (Soll) & DB
  lf_LineIM : handle; // Ist & Menge
  lf_LineIU : handle; // Ist & Umsatz
  lf_LineID : handle; // Ist & DB
  lf_LineSM : handle; // Simulation & Menge
  lf_LineSU : handle; // Simulation & Umsatz
  lf_LineSD : handle; // Simulation & DB
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Gv.Logic.11 # true; // Typ: Soll
  Gv.Logic.12 # true; // Typ: Ist
  Gv.Logic.13 # true; // Typ: Simulation
  Gv.Logic.14 # true; // Wert: Menge
  Gv.Logic.15 # true; // Wert: Umsatz
  Gv.Logic.16 # true; // Wert: DB

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.LST.950002', here + ':AusSel' );
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
local begin
  vA : alpha(500);
  vB : alpha(500);
  vConTyp  : alpha; // Soll, Ist, Sim
  vConWert : alpha; // Menge, Umsatz, DB
end;
begin
  if ( StrCut( aName, 1, 1 ) = '/' ) then begin // parameterisiert
    case Lib_Strings:Strings_Token( aName, ' ', 2 ) of
      'V' : vConTyp # 'Soll';
      'I' : vConTyp # 'Ist';
      'S' : vConTyp # 'Sim';
    end;

    case Lib_Strings:Strings_Token( aName, ' ', 3 ) of
      'M' : vConWert # 'Menge';
      'U' : vConWert # 'Umsatz';
      'D' : vConWert # 'DB';
    end;

    aName # StrCut( Lib_Strings:Strings_Token( aName, ' ', 1 ), 2, StrLen( aName ) );
  end;

  case aName of
    'sel' : begin
      if ( aPrint ) then begin
        if ( Gv.Logic.11 ) then
          vA # vA + '/Soll';
        if ( Gv.Logic.12 ) then
          vA # vA + '/Ist';
        if ( Gv.Logic.13 ) then
          vA # vA + '/Simulation';
        vA # 'Typen: ' + StrCut( vA, 2, StrLen( vA ) ) + ', Werte: ';

        if ( Gv.Logic.14 ) then
          vA # vA + 'Menge/';
        if ( Gv.Logic.15 ) then
          vA # vA + 'Umsatz/';
        if ( Gv.Logic.16 ) then
          vA # vA + 'DB/';

        if ( list_XML ) then
          LF_Text( 1, 'Liste: ' + CnvAI( Lfm.Nummer ) );
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
      list_Spacing[ 1] # 27.0; // Bezeichnung
      list_Spacing[ 2] # 15.0; // Typ
      list_Spacing[ 3] # 15.0; // Wert
      list_Spacing[ 4] # 20.0; // Jan
      list_Spacing[ 5] # 20.0; // Feb
      list_Spacing[ 6] # 20.0; // Mrz
      list_Spacing[ 7] # 20.0; // Apr
      list_Spacing[ 8] # 20.0; // Mai
      list_Spacing[ 9] # 20.0; // Jun
      list_Spacing[10] # 20.0; // Jul
      list_Spacing[11] # 20.0; // Aug
      list_Spacing[12] # 20.0; // Sep
      list_Spacing[13] # 20.0; // Okt
      list_Spacing[14] # 20.0; // Nov
      list_Spacing[15] # 20.0; // Dez
      list_Spacing[16] # 20.0; // Summe
      Lib_List2:ConvertWidthsToSpacings( 16 ); // Spaltenbreiten konvertieren


      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set(  1, 'Bezeichnung',  n, 0 );
      LF_Set(  2, 'Typ',          n, 0 );
      LF_Set(  3, 'Wert',          n, 0 );
      LF_Set(  4, 'Jan',          y, 0 );
      LF_Set(  5, 'Feb',          y, 0 );
      LF_Set(  6, 'Mrz',          y, 0 );
      LF_Set(  7, 'Apr',          y, 0 );
      LF_Set(  8, 'Mai',          y, 0 );
      LF_Set(  9, 'Jun',          y, 0 );
      LF_Set( 10, 'Jul',          y, 0 );
      LF_Set( 11, 'Aug',          y, 0 );
      LF_Set( 12, 'Sep',          y, 0 );
      LF_Set( 13, 'Okt',          y, 0 );
      LF_Set( 14, 'Nov',          y, 0 );
      LF_Set( 15, 'Dez',          y, 0 );
      LF_Set( 16, 'Summe',        y, 0 );
    end;

    'line' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set(  1, '@Con.Bezeichnung', n, 0 );

      case VConTyp of
        'Soll' : LF_Set( 2, 'Soll',       n, 0 );
        'Ist'  : LF_Set( 2, 'Ist',        n, 0 );
        'Sim'  : LF_Set( 2, 'Simulation', n, 0 );
      end;

      case vConWert of
        'Menge'  : LF_Set( 3, 'Menge',  n, 0 );
        'Umsatz' : LF_Set( 3, 'Umsatz', n, 0 );
        'DB'     : LF_Set( 3, 'DB',     n, 0 );
      end;

      LF_Set(  4, '@Con.' + vConTyp + '.' + vConWert + '.1',   y, _LF_Wae );
      LF_Set(  5, '@Con.' + vConTyp + '.' + vConWert + '.2',   y, _LF_Wae );
      LF_Set(  6, '@Con.' + vConTyp + '.' + vConWert + '.3',   y, _LF_Wae );
      LF_Set(  7, '@Con.' + vConTyp + '.' + vConWert + '.4',   y, _LF_Wae );
      LF_Set(  8, '@Con.' + vConTyp + '.' + vConWert + '.5',   y, _LF_Wae );
      LF_Set(  9, '@Con.' + vConTyp + '.' + vConWert + '.6',   y, _LF_Wae );
      LF_Set( 10, '@Con.' + vConTyp + '.' + vConWert + '.7',   y, _LF_Wae );
      LF_Set( 11, '@Con.' + vConTyp + '.' + vConWert + '.8',   y, _LF_Wae );
      LF_Set( 12, '@Con.' + vConTyp + '.' + vConWert + '.9',   y, _LF_Wae );
      LF_Set( 13, '@Con.' + vConTyp + '.' + vConWert + '.10',  y, _LF_Wae );
      LF_Set( 14, '@Con.' + vConTyp + '.' + vConWert + '.11',  y, _LF_Wae );
      LF_Set( 15, '@Con.' + vConTyp + '.' + vConWert + '.12',  y, _LF_Wae );
      LF_Set( 16, '@Con.' + vConTyp + '.' + vConWert + '.Sum', y, _LF_Wae );
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

  vLastLfS : alpha;
end;
begin
  /* Selektion */
  Lib_Sel:IntersectMark( var vSel, var vSelName, 950, 1 ); // nur markierte

  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Sel    # LF_NewLine( 'sel' );
  lf_Header # LF_NewLine( 'header' );
  lf_LineVM # LF_NewLine( '/line V M' ); // Vorgabe (Soll) & Menge
  lf_LineVU # LF_NewLine( '/line V U' ); // Vorgabe (Soll) & Umsatz
  lf_LineVD # LF_NewLine( '/line V D' ); // Vorgabe (Soll) & DB
  lf_LineIM # LF_NewLine( '/line I M' ); // Ist & Menge
  lf_LineIU # LF_NewLine( '/line I U' ); // Ist & Umsatz
  lf_LineID # LF_NewLine( '/line I D' ); // Ist & DB
  lf_LineSM # LF_NewLine( '/line S M' ); // Simulation & Menge
  lf_LineSU # LF_NewLine( '/line S U' ); // Simulation & Umsatz
  lf_LineSD # LF_NewLine( '/line S D' ); // Simulation & DB

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( true );

  vPrgr # Lib_Progress:Init( 'Listengenerierung', RecInfo( 950, _recCount, vSel ) );

  FOR  Erx # RecRead( 950, vSel, _recFirst );
  LOOP Erx # RecRead( 950, vSel, _recNext );
  WHILE ( Erx <= _rLocked ) and ( vPrgr->Lib_Progress:Step() ) DO BEGIN
    // Soll
    if ( Gv.Logic.11 ) then begin
      if ( Gv.Logic.14 ) then
        LF_Print( lf_LineVM );
      if ( Gv.Logic.15 ) then
        LF_Print( lf_LineVU );
      if ( Gv.Logic.16 ) then
        LF_Print( lf_LineVD );
    end;

    // Ist
    if ( Gv.Logic.12 ) then begin
      if ( Gv.Logic.14 ) then
        LF_Print( lf_LineIM );
      if ( Gv.Logic.15 ) then
        LF_Print( lf_LineIU );
      if ( Gv.Logic.16 ) then
        LF_Print( lf_LineID );
    end;

    // Simulation
    if ( Gv.Logic.13 ) then begin
      if ( Gv.Logic.14 ) then
        LF_Print( lf_LineSM );
      if ( Gv.Logic.15 ) then
        LF_Print( lf_LineSU );
      if ( Gv.Logic.16 ) then
        LF_Print( lf_LineSD );
    end;

    LF_Print( lf_Empty );
  END;

  /* Cleanup */
  vPrgr->Lib_Progress:Term();
  vSel->SelClose();
  SelDelete( 950, vSelName );

  LF_Term();
  LF_FreeLine( lf_Empty  );
  LF_FreeLine( lf_Sel );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_LineVM );
  LF_FreeLine( lf_LineVU );
  LF_FreeLine( lf_LineVD );
  LF_FreeLine( lf_LineIM );
  LF_FreeLine( lf_LineIU );
  LF_FreeLine( lf_LineID );
  LF_FreeLine( lf_LineSM );
  LF_FreeLine( lf_LineSU );
  LF_FreeLine( lf_LineSD );
end;

//=========================================================================
//=========================================================================