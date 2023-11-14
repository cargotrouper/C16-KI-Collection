@A+
//==== Business-Control ===================================================
//
//  Prozedur    F_STD_ADR_Vpkg
//                OHNE E_R_G
//  Info
//        Formular: Adressen / Stammdatenblatt Verpackungen
//
//  06.08.2010  PW  Erstellung
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    sub GetDokName ( var aSprache : alpha; var aAdresse : int ) : alpha;
//    sub SeitenKopf ( aSeite : int );
//    sub PrintForm ();
//
//    MAIN (opt aFilename : alpha(4096))
//
//=========================================================================
@I:Def_Global
@I:Def_PrintLine

define begin
  cPos0  :  10.0 // Standardeinzug links
  cPos0r : 180.0 // Standardeinzug rechts
  cPosH1 : 110.0
  cPosT1 :  12.0
  cPosT2 :  50.0
  cPosT3 :  75.0
  cPosT4 :  80.0

  cPosCh :  30.0 // chem. Tabulator
  cPosM1 :  50.0 // mech.
  cPosM2 :  90.0
end;

local begin
  vTopMargin : float;
  vSubTitle  : logic;
  vNum       : int;
end;


//=========================================================================
// GetDokName
//        Bestimmt den Namen eines Dokuments
//=========================================================================
sub GetDokName ( var aSprache : alpha; var aAdresse : int ) : alpha;
begin
  aSprache # ''
  aAdresse # Adr.V.AdressNr;

  RETURN CnvAI( Adr.V.Adressnr, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 ) + '/' + CnvAI( Adr.V.lfdNr, _fmtNumNoGroup | _fmtNumLeadZero, 0, 4 );
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf des Formulars
//=========================================================================
sub SeitenKopf ( aSeite : int );
local begin
  vTxt : alpha;
end;
begin
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.Telefax;
    Form_EMA        # Adr.EMail;
  end;

  pls_fontSize # 9;
  PL_Print_R( 'Seite: ' + CnvAI( aSeite ), cPos0r );
  PL_PrintLine;
  PL_Print( 'Stammdatenblatt Verpackungsvorschrift: ' + AInt( Adr.V.AdressNr ) + '/' + AInt( Adr.V.lfdNr ), cPos0 );
  PL_Print_R( 'Datum: ' + CnvAD( today ), cPos0r );
  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln( cPos0, cPos0r );
  PL_PrintLine;
  //Lib_Print:Print_Spacer( vTopMargin - form_RandOben, 'LE' );

  /* Header */
  pls_fontSize # 14;
  pls_fontAttr # _winFontAttrB;
  PL_Print( 'Verpackungsvorschrift: ' + AInt( Adr.V.AdressNr ) + '/' + AInt( Adr.V.lfdNr ), cPos0 );
  PL_Print( Adr.Stichwort, cPosH1 );
  PL_PrintLine;

  pls_fontSize # 9;
  pls_fontAttr # _winFontAttrN;
end;


//=========================================================================
// PrintSubTitle
//        Subtitel drucken
//=========================================================================
sub PrintSubTitle ( aText : alpha; opt checkGlobal : logic )
begin
  if ( checkGlobal and vSubTitle ) then
    RETURN;

  PL_PrintLine;
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print( aText, cPos0 );
  pls_fontAttr # _winFontAttrN;
  pls_fontSize # 9;
  PL_PrintLine;

  if ( checkGlobal ) then
    vSubTitle # true;
end;


//=========================================================================
// PrintChem
//        Chemische Vorgaben drucken
//=========================================================================
sub PrintChem ( aName : alpha; aName2 : alpha; aMin : float; aMax : float )
begin
  if ( aName2 != '' ) then
    aName # aName2;

  if ( aMin = 0.0 and aMax = 0.0 ) then
    RETURN;

  PrintSubTitle( 'Analyse', true );

  if ( vNum = 0 ) then
    PL_Print( 'Chem. Analyse:', cPosT1 );

  PL_Print( aName, cPosT2 + cPosCh * CnvFI( vNum % 4 ) );

  if ( aMin != 0.0 and aMax != 0.0 ) then
    PL_Print( ANum( aMin, -1 ) + ' - ' + ANum( aMax, -1 ), cPosT2 + cPosCh * CnvFI( vNum % 4 ) + 5.0 );
  else if ( aMin != 0.0 ) then
    PL_Print( 'min. ' + ANum( aMin, -1 ), cPosT2 + cPosCh * CnvFI( vNum % 4 ) + 5.0 );
  else if ( aMax != 0.0 ) then
    PL_Print( 'max. ' + ANum( aMax, -1 ), cPosT2 + cPosCh * CnvFI( vNum % 4 ) + 5.0 );

  vNum # vNum + 1;
  if ( vNum % 4 = 0 ) then
    PL_PrintLine;
end;


//=========================================================================
// PrintMech
//        Mechanische Vorgaben drucken
//=========================================================================
sub PrintMech ( aName : alpha; aMin : float; aMax : float; aEinheit : alpha )
begin
  aEinheit # ' ' + aEinheit;

  if ( aMin = 0.0 and aMax = 0.0 ) then
    RETURN;

  PrintSubTitle( 'Analyse', true );

  if ( vNum = 0 ) then
    PL_Print( 'Mech. Analyse:', cPosT1 );

  PL_Print( aName, cPosM1 );

  if ( aMin = aMax ) then
    PL_Print( ANum( aMin, -1 ) + aEinheit, cPosM2 );
  else if ( aMin != 0.0 and aMax != 0.0 ) then
    PL_Print( ANum( aMin, -1 ) + ' - ' + ANum( aMax, -1 ) + aEinheit, cPosM2 );
  else if ( aMin != 0.0 ) then
    PL_Print( 'min. ' + ANum( aMin, -1 ) + aEinheit, cPosM2 );
  else if ( aMax != 0.0 ) then
    PL_Print( 'max. ' + ANum( aMax, -1 ) + aEinheit, cPosM2 );

  vNum # vNum + 1;
  PL_PrintLine;
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  vPrintLine  : int;

  vNotFirst   : logic;
  vFirst      : logic;

  vTxtHdl     : handle;
  vLines      : int;
  vLine       : int;
  vFilter     : handle;
end;
begin
  Adr.Nummer # Adr.V.Adressnr;
  RecRead( 100, 1, 0 );

  PL_Create( vPrintLine );
//  Lib_Print:FrmJobOpen( 'tmp' + AInt( gUserID ), 0, 0, false, false, false );
  if (  Lib_Print:FrmJobOpen(y, 0, 0, false, false, false ) < 0) then begin
  if (vPrintline <> 0) then PL_Destroy(vPrintline);
    RETURN;
  end;


  Form_Dokname  # GetDokName( var Form_DokSprache, var form_DokAdr);

  vTopMargin    # form_RandOben;
  form_RandOben # 56693.0; // 10mm
  Lib_Print:Print_Seitenkopf();

  if ( RecLink( 819, 105, 2, _recFirst ) > _rLocked ) then // Warengruppe
    RecBufClear( 819 );
  if ( RecLink( 840, 105, 3, _recFirst ) > _rLocked ) then // Etikettentyp
    RecBufClear( 840 );
  if ( RecLink( 818, 105, 4, _recFirst ) > _rLocked ) then // Verwiegungsart
    RecBufClear( 818 );
  if ( RecLink( 220, 105, 6, _recFirst ) > _rLocked ) then // Materialstruktur
    RecBufClear( 220 );

  /* Ausgabe */
  PrintSubTitle( 'Allgemein' );

  PL_Print( 'Kundenartikelnr.', cPosT1 );
  PL_Print( Adr.V.KundenArtNr, cPosT2 );
  PL_PrintLine;

  PL_Print( 'Strukturnr.', cPosT1 );
  PL_Print( Adr.V.Strukturnr, cPosT2 );
  PL_PrintLine;

  // Zusatztext
  if ( Adr.V.VpgText1 + Adr.V.VpgText2 + Adr.V.VpgText3 + Adr.V.VpgText4 + Adr.V.VpgText5 + Adr.V.VpgText6 != '' ) then begin
    PL_Print( 'Zusatztext', cPosT1 );

    if ( Adr.V.VpgText1 != '' ) then begin
      PL_Print( Adr.V.VpgText1, cPosT2 );
      PL_PrintLine;
    end;
    if ( Adr.V.VpgText2 != '' ) then begin
      PL_Print( Adr.V.VpgText2, cPosT2 );
      PL_PrintLine;
    end;
    if ( Adr.V.VpgText3 != '' ) then begin
      PL_Print( Adr.V.VpgText3, cPosT2 );
      PL_PrintLine;
    end;
    if ( Adr.V.VpgText4 != '' ) then begin
      PL_Print( Adr.V.VpgText4, cPosT2 );
      PL_PrintLine;
    end;
    if ( Adr.V.VpgText5 != '' ) then begin
      PL_Print( Adr.V.VpgText5, cPosT2 );
      PL_PrintLine;
    end;
    if ( Adr.V.VpgText6 != '' ) then begin
      PL_Print( Adr.V.VpgText6, cPosT2 );
      PL_PrintLine;
    end;
  end;


  /* Material */
  PrintSubTitle( 'Material' );

  PL_Print( 'Warengruppe', cPosT1 );
  PL_Print( AInt( Adr.V.Warengruppe ) + ', ' + Wgr.Bezeichnung.L1, cPosT2 );
  PL_PrintLine;

  PL_Print( 'Güte', cPosT1 );
  PL_Print( "Adr.V.Güte" + ' / ' + "Adr.V.Gütenstufe", cPosT2 );
  PL_PrintLine;

  PL_Print( 'Ausführung oben', cPosT1 );
  PL_Print( Adr.V.AusfOben, cPosT2 );
  PL_PrintLine;

  PL_Print( 'Ausführung unten', cPosT1 );
  PL_Print( Adr.V.AusfUnten, cPosT2 );
  PL_PrintLine;

  PL_Print( 'Zeugnisart', cPosT1 );
  PL_Print( Adr.V.Zeugnisart, cPosT2 );
  PL_PrintLine;

  // Abmessungen
  PL_Print( 'Dicke', cPosT1 );
  PL_Print_R( ANum( "Adr.V.Dicke", "Set.Stellen.Dicke" ) + ' mm', cPosT3 );
  PL_Print( "Adr.V.DickenTol", cPosT4 );
  PL_PrintLine;

  PL_Print( 'Breite', cPosT1 );
  PL_Print_R( ANum( "Adr.V.Breite", "Set.Stellen.Breite" ) + ' mm', cPosT3 );
  PL_Print( "Adr.V.BreitenTol", cPosT4 );
  PL_PrintLine;

  PL_Print( 'Länge', cPosT1 );
  PL_Print_R( ANum( "Adr.V.Länge", "Set.Stellen.Länge" ) + ' mm', cPosT3 );
  PL_Print( "Adr.V.LängenTol", cPosT4 );
  PL_PrintLine;

  PL_Print( 'RID', cPosT1 );
  PL_Print_R( ANum( Adr.V.RID, 2 ) + ' mm', cPosT3 );
  PL_Print( 'max: ' + ANum( "Adr.V.RIDmax", 2 ), cPosT4 );
  PL_PrintLine;

  PL_Print( 'RAD', cPosT1 );
  PL_Print_R( ANum( "Adr.V.RAD", 2 ) + ' mm', cPosT3 );
  PL_Print( 'max: ' + ANum( "Adr.V.RADmax", 2 ), cPosT4 );
  PL_PrintLine;
  PL_PrintLine;

  PL_Print( 'Einsatz Vpkg.', cPosT1 );
  PL_Print( AInt( Adr.V.EinsatzVPG.Adr ) + ' / ' + AInt( Adr.V.EinsatzVPG.Nr ), cPosT2 );
  PL_PrintLine;

  PL_Print( 'Vorlage BAG', cPosT1 );
  PL_Print( AInt( Adr.V.VorlageBAG ), cPosT2 );
  PL_PrintLine;

  PL_Print( 'Grundpreis', cPosT1 );
  PL_Print( ANum( Adr.V.PreisW1, 2 ) + ' ' + "Set.Hauswährung.Kurz", cPosT2 );
  PL_PrintLine;

  PL_Print( 'Preisstellung in', cPosT1 );
  PL_Print( AInt( Adr.V.PEH ) + ' ' + Adr.V.MEH, cPosT2 );
  PL_PrintLine;


  /* Analyse */
  vSubTitle # false;

  // mechanische Vorgaben
  vNum # 0;
  PrintMech ( 'Streckgrenze', Adr.V.Streckgrenze1, Adr.V.Streckgrenze2, 'N/mm²' );
  PrintMech ( 'Zugfestigkeit', Adr.V.Zugfestigkeit1, Adr.V.Zugfestigkeit2, 'N/mm²' );
  if ( Adr.V.DehnungA1 + Adr.V.DehnungA2 + Adr.V.DehnungB1 + Adr.V.DehnungB2 != 0.0 ) then begin
    PrintSubTitle( 'Analyse', true );
    if ( vNum = 0 ) then
      PL_Print( 'Mech. Analyse:', cPosT1 );

    PL_Print( 'Dehnung', cPosM1 );
    PL_Print( ANum( Adr.V.DehnungA1, -1 ) + ' / ' + ANum( Adr.V.DehnungB1, -1 ) + '% - ' + ANum( Adr.V.DehnungA1, -1 ) + ' / '  + ANum( Adr.V.DehnungA1, -1 ) + '%' , cPosM2 );
    PL_PrintLine;

    vNum # vNum + 1;
  end;
  PrintMech ( 'Rp 0,2', Adr.V.DehngrenzeA1, Adr.V.DehngrenzeA1, 'N/mm²' );
  PrintMech ( 'Rp 10', Adr.V.DehngrenzeB1, Adr.V.DehngrenzeB2, 'N/mm²' );

  if ( "Set.Mech.Titel.Körn" != '' ) then
    PrintMech ( "Set.Mech.Titel.Körn", "Adr.V.Körnung1", "Adr.V.Körnung2", '' );
  else
    PrintMech ( 'Körnung', "Adr.V.Körnung1", "Adr.V.Körnung2", '' );

  if ( "Set.Mech.Titel.Härte" != '' ) then
    PrintMech ( "Set.Mech.Titel.Härte", "Adr.V.Härte1", "Adr.V.Härte2", '' );
  else
    PrintMech ( 'Härte', "Adr.V.Härte1", "Adr.V.Härte2", '' );

  PrintMech ( 'Rauigkeit OS', Adr.V.RauigkeitA1, Adr.V.RauigkeitA2, '' );
  PrintMech ( 'Rauigkeit US', Adr.V.RauigkeitB1, Adr.V.RauigkeitB2, '' );

  if ( Adr.V.Mech.Sonstig1 != '' ) then begin
    PrintSubTitle( 'Analyse', true );
    if ( vNum = 0 ) then
      PL_Print( 'Mech. Analyse:', cPosT1 );

    if ( "Set.Mech.Titel.Sonst" != '' ) then
      PL_Print( "Set.Mech.Titel.Sonst", cPosM1 );
    else
      PL_Print( 'Sonstiges', cPosM1 );
    PL_Print( Adr.V.Mech.Sonstig1, cPosM2 );
    PL_PrintLine;
  end;

  // chemische Vorgaben
  vNum # 0;
  PrintChem( 'C',  Set.Chemie.Titel.C,  Adr.V.Chemie.C1,  Adr.V.Chemie.C2 );
  PrintChem( 'Si', Set.Chemie.Titel.Si, Adr.V.Chemie.Si1, Adr.V.Chemie.Si2 );
  PrintChem( 'Mn', Set.Chemie.Titel.Mn, Adr.V.Chemie.Mn1, Adr.V.Chemie.Mn2 );
  PrintChem( 'P',  Set.Chemie.Titel.P,  Adr.V.Chemie.P1,  Adr.V.Chemie.P2 );
  PrintChem( 'S',  Set.Chemie.Titel.S,  Adr.V.Chemie.S1,  Adr.V.Chemie.S2 );
  PrintChem( 'Al', Set.Chemie.Titel.Al, Adr.V.Chemie.Al1, Adr.V.Chemie.Al2 );
  PrintChem( 'Cr', Set.Chemie.Titel.Cr, Adr.V.Chemie.Cr1, Adr.V.Chemie.Cr2 );
  PrintChem( 'V',  Set.Chemie.Titel.V,  Adr.V.Chemie.V1,  Adr.V.Chemie.V2 );
  PrintChem( 'Nb', Set.Chemie.Titel.Nb, Adr.V.Chemie.Nb1, Adr.V.Chemie.Nb2 );
  PrintChem( 'Ti', Set.Chemie.Titel.Ti, Adr.V.Chemie.Ti1, Adr.V.Chemie.Ti2 );
  PrintChem( 'N',  Set.Chemie.Titel.N,  Adr.V.Chemie.N1,  Adr.V.Chemie.N2 );
  PrintChem( 'Cu', Set.Chemie.Titel.Cu, Adr.V.Chemie.Cu1, Adr.V.Chemie.Cu2 );
  PrintChem( 'Ni', Set.Chemie.Titel.Ni, Adr.V.Chemie.Ni1, Adr.V.Chemie.Ni2 );
  PrintChem( 'Mo', Set.Chemie.Titel.Mo, Adr.V.Chemie.Mo1, Adr.V.Chemie.Mo2 );
  PrintChem( 'B',  Set.Chemie.Titel.B,  Adr.V.Chemie.B1,  Adr.V.Chemie.B2 );
  PrintChem( '', Set.Chemie.Titel.1, Adr.V.Chemie.Frei1.1, Adr.V.Chemie.Frei1.2 );
  PL_PrintLine;


  /* Verpackung */
  PrintSubTitle( 'Verpackung' );

  PL_Print( 'Abbindung', cPosT1 );
  if ( !Adr.V.StehendYN and !Adr.V.LiegendYN ) then
    PL_Print( 'längs ' + AInt( Adr.V.AbbindungL ) + ', quer ' + AInt( Adr.V.AbbindungQ ), cPosT2 );
  else if ( Adr.V.StehendYN ) then
    PL_Print( 'längs ' + AInt( Adr.V.AbbindungL ) + ', quer ' + AInt( Adr.V.AbbindungQ ) + ', stehend', cPosT2 );
  else if ( Adr.V.LiegendYN ) then
    PL_Print( 'längs ' + AInt( Adr.V.AbbindungL ) + ', quer ' + AInt( Adr.V.AbbindungQ ) + ', liegend', cPosT2 );

  PL_Print( 'Zwischenlage', cPosT1 );
  PL_Print( Adr.V.Zwischenlage, cPosT2 );
  PL_PrintLine;

  PL_Print( 'Unterlage', cPosT1 );
  PL_Print( Adr.V.Unterlage, cPosT2 );
  PL_PrintLine;

  PL_Print( 'Umverpackung', cPosT1 );
  PL_Print( Adr.V.Umverpackung, cPosT2 );
  PL_PrintLine;

  PL_Print( 'max. Stapelhöhe', cPosT1 );
  PL_Print( ANum( "Adr.V.Stapelhöhe", 2 ) + 'mm', cPosT2 );
  PL_PrintLine;

  PL_Print( 'Höhenabzug', cPosT1 );
  PL_Print( ANum( Adr.V.StapelhAbzug, 2 ) + 'mm', cPosT2 );
  PL_PrintLine;

  RecLink( 818, 105, 4, _recFirst ); // Verwiegungsart
  PL_Print( 'Verwiegungsart', cPosT1 );
  PL_Print( VwA.Bezeichnung.L1, cPosT2 );
  PL_PrintLine;

  RecLink( 840, 105, 3, _recFirst ); // Etikettentyp
  PL_Print( 'Etikettentyp', cPosT1 );
  PL_Print( Eti.Bezeichnung, cPosT2 );
  PL_PrintLine;

  PL_Print( 'Ringgewicht', cPosT1 );
  PL_Print( ANum( Adr.V.RingKgVon, 2 ) + ' - ' + ANum( Adr.V.RingKgBis, 2 ) + 'kg', cPosT2 );
  PL_PrintLine;

  PL_Print( 'kg/mm', cPosT1 );
  PL_Print( ANum( Adr.V.KgmmVon, 2 ) + ' - ' + ANum( Adr.V.KgmmBis, 2 ) + 'kg', cPosT2 );
  PL_PrintLine;

  PL_Print( 'kg/mm', cPosT1 );
  PL_Print( ANum( Adr.V.KgmmVon, 2 ) + ' - ' + ANum( Adr.V.KgmmBis, 2 ) + 'kg', cPosT2 );
  PL_PrintLine;

  PL_Print( 'Rechtwink.max', cPosT1 );
  PL_Print( ANum( Adr.V.RechtwinkMax, 2 ), cPosT2 );
  PL_PrintLine;

  PL_Print( 'Ebenheit max', cPosT1 );
  PL_Print( ANum( Adr.V.EbenheitMax, 2 ), cPosT2 );
  PL_PrintLine;

  PL_Print( 'Säbeligkeit max', cPosT1 );
  PL_Print( ANum( "Adr.V.SäbeligkeitMax", 2 ), cPosT2 );
  PL_PrintLine;

  PL_Print( 'Wicklung', cPosT1 );
  PL_Print( Adr.V.Wicklung, cPosT2 );
  PL_PrintLine;

  PL_Print( 'max VE-Gewicht', cPosT1 );
  PL_Print( ANum( Adr.V.VEkgMax, 2 ) + 'kg', cPosT2 );
  PL_PrintLine;

  PL_Print( 'max Stück/VE', cPosT1 );
  PL_Print( AInt( "Adr.V.StückProVE" ), cPosT2 );
  PL_PrintLine;

  PL_Print( 'Nettoabzug', cPosT1 );
  PL_Print( ANum( Adr.V.Nettoabzug, 2 ) + 'kg', cPosT2 );
  PL_PrintLine;


  /* Druck beenden */
  Usr.Username # UserInfo( _userName, CnvIA( UserInfo( _userCurrent ) ) );
  RecRead( 800, 1, 0 );
//  Lib_Print:FrmJobClose( !"Frm.DirektdruckYN" );
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  if ( vPrintLine != 0 ) then
    PL_Destroy( vPrintLine );

end;

//=========================================================================
//=========================================================================