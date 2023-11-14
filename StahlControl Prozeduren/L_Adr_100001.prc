@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Adr_100001
//                    OHNE E_R_G
//  Info
//        Liste: Adressen
//
//  05.05.2004  AI  Erstellung der Prozedur
//  16.04.2010  PW  Neuer Listenstil
//  13.06.2022  AH  ERX
//
//  Subprozeduren
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
  lf_Break  : handle;
  lf_XML_H  : handle;
  lf_XML    : handle;
  lf_Header : handle;
  lf_Line1  : handle;
  lf_Line2  : handle;
  lf_Line3  : handle;
  lf_Line4  : handle;
  lf_Line5  : handle;
  lf_Line6  : handle;
  lf_Line7  : handle;

  gOrt      : logic;
  gPostfach : logic;
  gLand     : logic;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  StartList( 0, '' );
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
begin
  case aName of
    'break' : begin
      if ( !aPrint ) then begin
        LF_Format( _LF_Underline );
        LF_Set( 1, ' ', n, 0 );
      end;
    end;

    'xml-header' : begin
      if ( aPrint ) then
        RETURN;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set(  1, 'Anrede',         n, 0 );
      LF_Set(  2, 'Name',           n, 0 );
      LF_Set(  3, 'Zusatz',         n, 0 );
      LF_Set(  4, 'Straße',         n, 0 );
      LF_Set(  5, 'PLZ/Ort',        n, 0 );
      LF_Set(  6, 'Postfach',       n, 0 );
      LF_Set(  7, 'LKZ',            n, 0 );
      LF_Set(  8, 'AdressNr.',      n, 0 );
      LF_Set(  9, 'KundenNr.',      n, 0 );
      LF_Set( 10, 'LieferantenNr.', n, 0 );
      LF_Set( 11, 'Stichwort',      n, 0 );
      LF_Set( 12, 'Gruppe',         n, 0 );
      LF_Set( 13, 'Sachbearbeiter', n, 0 );
      LF_Set( 14, 'Telefon1',       n, 0 );
      LF_Set( 15, 'Telefon2',       n, 0 );
      LF_Set( 16, 'Telefax',        n, 0 );
      LF_Set( 17, 'E-Mail',         n, 0 );
    end;

    'xml' : begin
      if ( aPrint ) then begin
        LF_Text( 5, Adr.PLZ + ' ' + Adr.Ort );
        LF_Text( 6, Adr.Postfach.PLZ + '/' + Adr.Postfach );

        RETURN;
      end;

      LF_Set(  1, '@Adr.Anrede',         n, 0 );
      LF_Set(  2, '@Adr.Name',           n, 0 );
      LF_Set(  3, '@Adr.Zusatz',         n, 0 );
      LF_Set(  4, '@Adr.Straße',         n, 0 );
      LF_Set(  5, '#Adr.Ort',            n, 0 );
      LF_Set(  6, '#Adr.Postfach',       n, 0 );
      LF_Set(  7, '@Adr.LKZ',            n, 0 );
      LF_Set(  8, '@Adr.Nummer',         n, _LF_IntNG );
      LF_Set(  9, '@Adr.KundenNr',       n, _LF_IntNG );
      LF_Set( 10, '@Adr.LieferantenNr',  n, _LF_IntNG );
      LF_Set( 11, '@Adr.Stichwort',      n, 0 );
      LF_Set( 12, '@Adr.Gruppe',         n, 0 );
      LF_Set( 13, '@Adr.Sachbearbeiter', n, 0 );
      LF_Set( 14, '@Adr.Telefon1',       n, 0 );
      LF_Set( 15, '@Adr.Telefon2',       n, 0 );
      LF_Set( 16, '@Adr.Telefax',        n, 0 );
      LF_Set( 17, '@Adr.eMail',          n, 0 );
    end;

    'header' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 60.0;
      list_Spacing[ 4] # list_Spacing[ 2] + 60.0;
      list_Spacing[ 6] # list_Spacing[ 4] + 70.0;

      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Adresse',      n, 0 );
      LF_Set( 2, 'Daten',        n, 0 );
      LF_Set( 4, 'Kontaktdaten', n, 0 );
    end;

    'line1' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 60.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 30.0;
      list_Spacing[ 4] # 190.0;

      LF_Set( 1, '@Adr.Anrede',         n, 0 );
      LF_Set( 2, 'Stichwort:',          n, 0 );
      LF_Set( 3, '@Adr.Stichwort',      n, 0 );
    end;

    'line2' : begin
      if ( aPrint ) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 60.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 30.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 30.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 20.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 50.0;

      LF_Set( 1, '@Adr.Name',           n, 0 );
      LF_Set( 2, 'AdressNr.:',          n, 0 );
      LF_Set( 3, '@Adr.Nummer',         n, 0 );
      LF_Set( 4, 'Telefon 1:',          n, 0 );
      LF_Set( 5, '@Adr.Telefon1',       n, 0 );
    end;

    'line3' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Adr.Zusatz',         n, 0 );
      LF_Set( 2, 'KundenNr.',           n, 0 );
      LF_Set( 3, '@Adr.KundenNr',       n, 0 );
      LF_Set( 4, 'Telefon 2:',          n, 0 );
      LF_Set( 5, '@Adr.Telefon2',       n, 0 );
    end;

    'line4' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Adr.Straße',         n, 0 );
      LF_Set( 2, 'LieferantenNr.:',     n, 0 );
      LF_Set( 3, '@Adr.LieferantenNr',  n, 0 );
      LF_Set( 4, 'Telefax:',            n, 0 );
      LF_Set( 5, '@Adr.Telefax',        n, 0 );
    end;

    'line5' : begin
      if ( aPrint ) then begin
        if ( gOrt ) or ( !gPostfach ) then begin
          LF_Text( 1, Adr.PLZ + ' ' + Adr.Ort );
          gOrt # false;
        end
        else begin
          LF_Text( 1, 'Postfach: ' + Adr.Postfach.PLZ + ' ' + Adr.Postfach );
          gPostfach # false;
        end;

        RETURN;
      end;

      LF_Set( 1, '#PLZ/Ort',            n, 0 );
      LF_Set( 2, 'Gruppe:',             n, 0 );
      LF_Set( 3, '@Adr.Gruppe',         n, 0 );
      LF_Set( 4, 'E-Mail:',             n, 0 );
      LF_Set( 5, '@Adr.eMail',          n, 0 );
    end;

    'line6' : begin
      if ( aPrint ) then begin
        if ( gPostfach ) then begin
          LF_Text( 1, 'Postfach: ' + Adr.Postfach.PLZ + ' ' + Adr.Postfach );
          gPostfach # false;
        end
        else begin
          LF_Text( 1, Lnd.Name.L1 );
          gLand # false;
        end;

        RETURN;
      end;

      LF_Set( 1, '#PLZ/Ort/Land',       n, 0 );
      LF_Set( 2, 'Sachbearbeiter:',     n, 0 );
      LF_Set( 3, '@Adr.Sachbearbeiter', n, 0 );
    end;

    'line7' : begin
      if ( aPrint ) then
        RETURN;

      LF_Set( 1, '@Lnd.Name.L1',        n, 0 );
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

  if ( list_XML ) then
    LF_Print( lf_XML_H );
  else
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
  vPrgr : handle;
  Erx   : int;
end;
begin
  /* Druckelemente */
  lf_Empty  # LF_NewLine( '' );
  lf_Break  # LF_NewLine( 'break' );
  lf_Header # LF_NewLine( 'header' );
  lf_XML_H  # LF_NewLine( 'xml-header' );
  lf_XML    # LF_NewLine( 'xml' );
  lf_Line1  # LF_NewLine( 'line1' );
  lf_Line2  # LF_NewLine( 'line2' );
  lf_Line3  # LF_NewLine( 'line3' );
  lf_Line4  # LF_NewLine( 'line4' );
  lf_Line5  # LF_NewLine( 'line5' );
  lf_Line6  # LF_NewLine( 'line6' );
  lf_Line7  # LF_NewLine( 'line7' );

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );

  REPEAT BEGIN
    vPrgr # Lib_Progress:Init( 'Listengenerierung', RecInfo( 100, _recCount ) );

    FOR  Erx # RecRead( 100, 1, _recFirst );
    LOOP Erx # RecRead( 100, 1, _recNext );
    WHILE ( Erx <= _rLocked ) and ( vPrgr->Lib_Progress:Step() ) DO BEGIN
      // Land
      if ( RecLink( 812, 100, 10, _recFirst ) > _rLocked ) then
        RecBufClear( 812 );

      if ( list_XML ) then
        LF_Print( lf_XML );
      else begin
        if ( Adr.Ort != '' ) then
          gOrt # true;
        if ( Adr.Postfach != '' ) then
          gPostfach # true;
        gLand # true;

        LF_Print( lf_Line1 );
        LF_Print( lf_Line2 );
        LF_Print( lf_Line3 );
        LF_Print( lf_Line4 );
        LF_Print( lf_Line5 );
        LF_Print( lf_Line6 );

        if ( gLand ) then
          LF_Print( lf_Line7 );

        LF_Print( lf_Break );
      end;
    END;

    vPrgr->Lib_Progress:Term();
  END UNTIL ( true );



  /* Cleanup */
  LF_Term();
  LF_FreeLine( lf_Break );
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_XML_H );
  LF_FreeLine( lf_XML );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line1 );
  LF_FreeLine( lf_Line2 );
  LF_FreeLine( lf_Line3 );
  LF_FreeLine( lf_Line4 );
  LF_FreeLine( lf_Line5 );
  LF_FreeLine( lf_Line6 );
  LF_FreeLine( lf_Line7 );
end;

//=========================================================================
//=========================================================================