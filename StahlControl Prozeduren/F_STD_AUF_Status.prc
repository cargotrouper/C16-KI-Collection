@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_AUF_Status
//                        OHNE E_R_G
//  Info
//    Druckt ein Statusblatt
//
//
//  02.10.2008  PW  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//    SUB Print(aTyp : alpha);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG
@I:Def_Aktionen

define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  // Positions
  cPos0     :  10.0 // Standardeinzug, links
  cPos0r    : 180.0 // Standardeinzug, rechts
  cPosT1    :  15.0 // Anschrifteneinzug
  cPosT2    :  42.5 // Adresseneinzug (Warenempfänger, Verbraucher, Rechnungsempfänger)
  cPosKopf1 : 110.0 // Kopfblock Einzug 1
  cPosKopf2 : 145.0 // Kopfblock Einzug 2 (Werte)

  cPosCol0  :  10.0 // Beschreibung Ebene 1
  cPosCol1  :  20.0 // Beschreibung Ebene 2
  cPosCol2  :  90.0 // Auf-/Lfs-Nummer
  cPosCol3  : 130.0 // Menge
  cPosCol3a : 133.0
  cPosCol4  : 175.0 // Rechnungsmenge
  cPosCol4a : 178.0
end;


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName (
  var aSprache : alpha;
  var aAdr     : int;
) : alpha;
local begin
  vBuf100 : int;
end;
begin
  vBuf100 # RekSave(100);
  RecLink( 100, 400, 1, _recFirst );
  aAdr     # Adr.Nummer;
  aSprache # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI( Auf.Nummer, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 );
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf ( aSeite : int );
local begin
  vText : alpha;
end;
begin
  pls_fontSize # 11;
  pls_fontAttr # _winFontAttrB;
  if ( "Auf.LiefervertragYN" ) and ( !"Auf.AbrufYN" ) then
    PL_Print( 'Statusblatt: Rahmenvertrag ' + AInt( Auf.Nummer ), cPos0 );
  else
    PL_Print( 'Statusblatt: Auftrag ' + AInt( Auf.Nummer ), cPos0 );
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrN;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;


  PL_Print( 'Kunde: ', cPos0 );
  vText # StrAdj( "Adr.A.Anrede", _StrBegin | _StrEnd );
  vText # vText + ' ' + StrAdj( "Adr.A.Name",   _StrBegin | _StrEnd );
  vText # vText + ' ' + StrAdj( "Adr.A.Zusatz", _StrBegin | _StrEnd );
  PL_Print( StrAdj( vText, _StrBegin | _StrEnd ), cPosT2, cPos0r );
  PL_PrintLine;
  vText # StrAdj( "Adr.A.Straße", _StrBegin | _StrEnd );
  vText # vText + ', ' + StrAdj( "Adr.A.PLZ", _StrBegin | _StrEnd );
  vText # vText + ' '  + StrAdj( "Adr.A.Ort", _StrBegin | _StrEnd );
  vText # vText + ', ' + StrAdj( "Lnd.Name.L1", _StrBegin | _StrEnd );
  PL_Print( StrAdj( vText, _StrBegin | _StrEnd ), cPosT2, cPos0r );
  PL_PrintLine;
  PL_PrintLine;
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin

end;
begin

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vHeader     : int;
  vFooter     : int;
  vPLHeader   : int;
  vPLFooter   : int;
  vPL         : int;

  vBuf404     : int;
  vRestGew    : float;
  vLinie      : logic;
  vLfsMenge   : float;
  vReMenge    : float;
end;
begin
  RecLink( 100, 400,  1, _recFirst ); // Kunde holen
  RecLink( 101, 100, 12, _recFirst ); // Hauptanschrift holen
  RecLink( 814, 400,  8, _recFirst ); // Währung holen

  PL_Create( vPL );
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter, y, y, n ) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);
  form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;
  Lib_Print:Print_Seitenkopf();

  /* Rahmenvertrag */
  if ( "Auf.LiefervertragYN" ) and ( !"Auf.AbrufYN" ) then begin
    pls_fontAttr # _winFontAttrB;
    PL_Print_R( 'Rahmenvertragsmenge:', cPosCol3 - 15.0 );
    PL_PrintF( Auf.P.Gewicht, Set.Stellen.Gewicht, cPosCol3 );
    PL_Print( 'kg', cPosCol3a );
    PL_Print_R( 'Rechnungsmenge', cPosCol4a );
    pls_fontAttr # _winFontAttrN;
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln( cPos0, cPos0r );
    PL_PrintLine;

    vRestGew # Auf.P.Gewicht;

    /* Abrufe aus Aktionen auslesen */
    FOR  Erx # RecLink( 404, 400, 15, _recFirst );
    LOOP Erx # RecLink( 404, 400, 15, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( Auf.A.Aktionstyp != 'ABRUF' ) then
        CYCLE;

      RecBufClear( 401 );
      Auf.P.Nummer   # Auf.A.Aktionsnr;
      Auf.P.Position # Auf.A.Aktionspos;
      RecRead( 401, 1, 0 );

      PL_Print( 'Abruf vom ' + CnvAD( Auf.A.Aktionsdatum ), cPosCol0 );
      PL_Print( 'Auf ' + AInt( Auf.A.Aktionsnr ) + '/' + AInt( Auf.A.Aktionspos ), cPosCol2 );
      PL_PrintF( Auf.A.Gewicht, Set.Stellen.Gewicht, cPosCol3 );
      PL_Print( 'kg', cPosCol3a );
      PL_PrintLine;

      vLfsMenge # 0.0;
      vReMenge  # 0.0;
      vBuf404   # RekSave( 404 );
      FOR  Erx # RecLink( 404, 401, 12, _recFirst );
      LOOP Erx # RecLink( 404, 401, 12, _recNext );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        if ( Auf.A.Aktionstyp != c_AKT_LFS ) then
          CYCLE;

        RecBufClear( 441 );
        Lfs.P.Nummer   # Auf.A.Aktionsnr;
        Lfs.P.Position # Auf.A.Aktionspos;
        RecRead( 441, 1, 0 );

        PL_Print( 'Lieferung vom ' + CnvAD( Auf.A.Aktionsdatum ), cPosCol1 );
        PL_Print( 'Lfs ' + AInt( Auf.A.Aktionsnr ) + '/' + AInt( Auf.A.Aktionspos ), cPosCol2 );
        PL_PrintF( Auf.A.Gewicht, Set.Stellen.Gewicht, cPosCol3 );
        PL_Print( 'kg', cPosCol3a );
        PL_PrintF( Auf.A.Menge.Preis, Set.Stellen.Gewicht, cPosCol4 );
        PL_Print( 'kg', cPosCol4a );
        PL_PrintLine;

        vLfsMenge # vLfsMenge + Auf.A.Gewicht;
        vReMenge  # vReMenge  + Auf.A.Menge.Preis;
      END;
      RekRestore( vBuf404 );

      if ( vLfsMenge != 0.0 ) then begin
        Lib_Print:Print_LinieEinzeln( cPosCol3 - 25.0, cPos0r );
        PL_Print_R( 'Rest:', cPosCol3 - 15.0 );
        PL_PrintF( vLfsMenge, Set.Stellen.Gewicht, cPosCol3 );
        PL_Print( 'kg', cPosCol3a );
        PL_PrintF( vReMenge, Set.Stellen.Gewicht, cPosCol4 );
        PL_Print( 'kg', cPosCol4a );
      end;
      PL_PrintLine;
      PL_PrintLine;

      vRestGew # vRestGew - Auf.P.Gewicht;
    END;

    Lib_Print:Print_LinieEinzeln( cPos0, cPos0r );
    PL_PrintF( vRestGew, Set.Stellen.Gewicht, cPosCol3 );
    PL_Print( 'kg', cPosCol3a );
    PL_PrintLine;
    PL_PrintLine;
  end;
  else begin
    pls_fontAttr # _winFontAttrB;
    PL_Print_R( 'Auftragsmenge:', cPosCol3 - 15.0 );
    PL_PrintF( Auf.P.Gewicht, Set.Stellen.Gewicht, cPosCol3 );
    PL_Print( 'kg', cPosCol3a );
    PL_Print_R( 'Rechnungsmenge', cPosCol4a );
    pls_fontAttr # _winFontAttrN;
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln( cPos0, cPos0r );
    PL_PrintLine;

    vRestGew # Auf.P.Gewicht;

    /* Abrufe aus Aktionen auslesen */
    FOR  Erx # RecLink( 404, 400, 15, _recFirst );
    LOOP Erx # RecLink( 404, 400, 15, _recNext );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( Auf.A.Aktionstyp != c_AKT_LFS ) then
        CYCLE;

      RecBufClear( 441 );
      Lfs.P.Nummer   # Auf.A.Aktionsnr;
      Lfs.P.Position # Auf.A.Aktionspos;
      RecRead( 441, 1, 0 );


      PL_Print( 'Lieferung vom ' + CnvAD( Auf.A.Aktionsdatum ), cPosCol0 );
      PL_Print( 'Lfs ' + AInt( Auf.A.Aktionsnr ) + '/' + AInt( Auf.A.Aktionspos ), cPosCol2 );
      PL_PrintF( Auf.A.Gewicht, Set.Stellen.Gewicht, cPosCol3 );
      PL_Print( 'kg', cPosCol3a );
      PL_PrintF( Auf.A.Menge.Preis, Set.Stellen.Gewicht, cPosCol4 );
      PL_Print( 'kg', cPosCol4a );
      PL_PrintLine;

      vRestGew # vRestGew - Lfs.P.Menge;
    END;

    Lib_Print:Print_LinieEinzeln( cPos0, cPos0r );
    PL_PrintF( vRestGew, Set.Stellen.Gewicht, cPosCol3 );
    PL_Print( 'kg', cPosCol3a );
    PL_PrintLine;
    PL_PrintLine;

  end;





  /* Druck abschließen */
  Usr.Username # UserInfo( _userName, CnvIA( UserInfo( _userCurrent ) ) );
  RecRead( 800, 1, 0 );
//  Lib_Print:FrmJobClose( !"Frm.DirektdruckYN" );
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if ( vPL != 0 ) then          PL_Destroy( vPL );
  if ( vPLHeader != 0 ) then    PL_Destroy( vPLHeader );
  else if ( vHeader != 0 ) then vHeader->PrtFormClose();
  if ( vPLFooter != 0 ) then    PL_Destroy( vPLFooter );
  else if ( vFooter != 0 ) then vFooter->PrtFormClose();

end;


//=======================================================================