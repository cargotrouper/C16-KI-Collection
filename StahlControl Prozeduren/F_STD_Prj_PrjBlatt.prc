@A+
//==== Business-Control ===================================================
//
//  Prozedur    F_STD_Prj_Prjblatt
//                      OHNE E_R_G
//  Info
//        Formular: Projektpositionen / Projektplatt
//
//  28.05.2010  PW  Erstellung
//  01.08.2012  ST  Erweiterung: Arg Dateiname für Dateierstellung durch
//                  Jobserver
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    sub GetDokName ( var aSprache : alpha; var aAdresse : int ) : alpha;
//    sub SeitenKopf ( aSeite : int );
//    sub PrintForm ();
//=========================================================================
@I:Def_Global
@I:Def_PrintLine

define begin
  cPos0  :  10.0 // Standardeinzug links
  cPos0r : 180.0 // Standardeinzug rechts
  cPosH1 :  40.0
  cPosT1 :  12.0
  cPosT2 :  70.0
  cPosT3 : 130.0

  cPosC1 :  20.0 // lfdNr (r)
  cPosC2 :  45.0 // Startdatum (r)
  cPosC3 :  70.0 // Enddatum (r)
  cPosC4 :  85.0 // Zeit (r)
  cPosC5 :  87.0 // Benutzer
  cPosC6 : 110.0 // Bemerkung
end;

local begin
  vTopMargin : float;
end;

//=========================================================================
// GetDokName
//        Bestimmt den Namen eines Dokuments
//=========================================================================
sub GetDokName ( var aSprache : alpha; var aAdresse : int ) : alpha;
begin
  aSprache # '';
  aAdresse # 0;

  RETURN CnvAI( Prj.P.Nummer, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 ) + '/' + CnvAI( Prj.P.Position, _fmtNumNoGroup | _fmtNumLeadZero, 0, 4 );
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf des Formulars
//=========================================================================
sub SeitenKopf ( aSeite : int );
begin
  pls_fontSize # 9;
  PL_Print( 'Projektblatt: ' + AInt( Prj.P.Nummer ) + '/' + AInt( Prj.P.Position ), cPos0 );
  PL_Print_R( 'Datum: ' + CnvAD( today ), cPos0r );
  PL_PrintLine;
  Lib_Print:Print_Spacer( vTopMargin - form_RandOben, 'LE' );

  /* Header */
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print( 'Projekt ' + AInt( Prj.Nummer ) + ':', cPos0 );
  pls_fontAttr # _winFontAttrN;
  PL_Print( Prj.Bemerkung, cPosH1 );
  pls_fontAttr # _winFontAttrB;
  PL_Print_R( 'Kunde: ' + Adr.Stichwort, cPos0r );
  PL_PrintLine;

  pls_fontAttr # _winFontAttrB;
  PL_Print( 'Position ' + AInt( Prj.P.Position ) + ':', cPos0 );
  pls_fontAttr # _winFontAttrN;
  PL_Print( Prj.P.Bezeichnung, cPosH1 );
  PL_PrintLine;
  PL_PrintLine;
end;


//=========================================================================
// PrintForm
//        Hauptprozedur
//=========================================================================
sub PrintForm (opt aFilename : alpha(4096));
local begin
  Erx         : int;
  vPrintLine  : int;
  vBuf122     : int;
  vNotFirst   : logic;
  vFirst      : logic;

  vTxtHdl     : handle;
  vLines      : int;
  vLine       : int;
  vFilter     : handle;
end;
begin
  // erste Projektposition laden
  if ( Sel.Auf.von.Projekt > Sel.Auf.bis.Projekt ) then
    RETURN;
  else begin
    Prj.P.Position # Sel.Auf.von.Projekt;
    Erx # RecRead( 122, 1, 0 );
    WHILE ( Erx > _rLocked ) and ( Sel.Auf.von.Projekt <= Sel.Auf.bis.Projekt ) DO BEGIN
      Sel.Auf.von.Projekt # Sel.Auf.von.Projekt + 1;
      Prj.P.Position      # Sel.Auf.von.Projekt;
      Erx # RecRead( 122, 1, 0 );
    END;
    if ( Erx > _rLocked ) then
      RETURN;
  end;

  Erx # RecLink(120, 122, 2, _recFirst); // Projekt
  if(Erx > _rLocked) then
    RecBufClear(120);

  Erx # RecLink(100, 120, 1, _recFirst); // Kunde
  if(Erx > _rLocked) then
    RecBufClear(100);

  PL_Create( vPrintLine );
  if (Lib_Print:FrmJobOpen( y, 0, 0, false, false, false ) < 0) then begin
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  vTopMargin    # form_RandOben;
  form_RandOben # 56693.0; // 10mm
  Lib_Print:Print_Seitenkopf();

  pls_fontSize   # 9;
  Prj.P.Position # Sel.Auf.von.Projekt;
  vTxtHdl        # TextOpen( 32 );

  FOR  Erx # RecRead( 122, 1, 0 );
  LOOP Erx # RecRead( 122, 1, _recNext );
  WHILE ( Erx <= _rLocked ) and ( Prj.P.Nummer = Prj.Nummer ) and
      ( Prj.P.Position >= Sel.Auf.von.Projekt ) and ( Prj.P.Position <= Sel.Auf.bis.Projekt )
  DO BEGIN
    if ( vNotFirst ) then
      Lib_Print:Print_FF();
    vNotFirst # true;

    Erx # RecLink( 850, 122, 3, _recFirst ); // Status
    if(Erx > _rLocked) then
      RecBufClear(850);

    Erx # RecLink( 100, 120, 1, _recFirst ); // Kunde
    if(Erx > _rLocked) then
      RecBufClear(100);

    // Status
    PL_Print( 'Status:', cPosT1 );
    PL_Print( Stt.Bezeichnung, cPosT2 );
    PL_PrintLine;

    // Ursprungsprojekt
    if ( Prj.P.zuProjekt != 0 ) then begin
      vBuf122 # RecBufCreate( 122 );
      vBuf122->Prj.P.Nummer   # Prj.P.zuProjekt;
      vBuf122->Prj.P.Position # Prj.P.zuPosition;
      RecRead( vBuf122, 1, 0 );

      PL_Print( 'Resultiert aus:', cPosT1 );
      PL_Print( AInt( Prj.P.zuProjekt ) + '/' + AInt( Prj.P.zuPosition ) + ' ' + vBuf122->Prj.P.Bezeichnung, cPosT2 );
      PL_PrintLine;

      RecBufDestroy( vBuf122 );
    end;

    // Referenznummer
    if ( Prj.P.Referenznr != '' ) then begin
      PL_Print( 'Referenznummer:', cPosT1 );
      PL_Print( Prj.P.Referenznr, cPosT2 );
      PL_PrintLine;
    end;

    // Zeitraum
    if ( Prj.P.Datum.Start != 0.0.0 or Prj.P.Datum.Ende != 0.0.0 ) then begin
      PL_Print( 'Zeitraum:', cPosT1 );
      if ( Prj.P.Datum.Start = 0.0.0 ) then
        PL_Print( 'bis ' + CnvAD( Prj.P.Datum.Ende ), cPosT2 );
      else if ( Prj.P.Datum.Ende = 0.0.0 ) then
        PL_Print( 'von ' + CnvAD( Prj.P.Datum.Start ), cPosT2 );
      else
        PL_Print( 'von ' + CnvAD( Prj.P.Datum.Start ) + ' bis ' + CnvAD( Prj.P.Datum.Ende ), cPosT2 );
      PL_PrintLine;
    end;

    // Stunden, angebotene
    if ( Gv.Logic.11 ) then begin
      PL_Print( 'angebotene Stunden:', cPosT1 );
      PL_Print( ANum( Prj.P.Dauer.Angebot, 2 ), cPosT2 );
      PL_PrintLine;
    end;

    // Stunden, geplante
    if ( Gv.Logic.12 ) then begin
      PL_Print( 'geplante Stunden:', cPosT1 );
      PL_Print( ANum( Prj.P.Dauer, 2 ), cPosT2 );
      PL_PrintLine;
    end;

    // Stunden, interne
    if ( Gv.Logic.13 ) then begin
      PL_Print( 'interne Stunden:', cPosT1 );
      PL_Print( ANum( Prj.P.Dauer.Intern, 2 ), cPosT2 );
      PL_PrintLine;
    end;

    // Stunden, externe
    if ( Gv.Logic.14 ) then begin
      PL_Print( 'Std zur Berechnung:', cPosT1 );
      PL_Print( ANum( Prj.P.Dauer.Extern, 2 ), cPosT2 );
      PL_PrintLine;
    end;

    PL_PrintLine;
    PL_PrintLine;

    /* Stunden, detailierte Zeiten */
    if ( Gv.Logic.15 ) and ( RecLinkInfo( 123, 122, 1, _recCount ) > 0 ) then begin
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print( 'Zeiten', cPos0 );
      PL_PrintLine;

      PL_Print_R( 'Nr.',        cPosC1 );
      PL_Print_R( 'Startdatum', cPosC2 );
      PL_Print_R( 'Enddatum',   cPosC3 );
      PL_Print_R( 'Zeit',       cPosC4 );
      PL_Print( 'User',         cPosC5 );
      PL_Print( 'Bemerkung',    cPosC6 );
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln( cPosT1, cPos0r );
      pls_fontSize # 9;
      pls_fontAttr # _winFontAttrN;


      FOR  Erx # RecLink( 123, 122, 1, _recFirst );
      LOOP Erx # RecLink( 123, 122, 1, _recNext );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        PL_Print_R( AInt( Prj.Z.lfdNr ),        cPosC1 );
        PL_Print_R( CnvAD( Prj.Z.Start.Datum ), cPosC2 );
        PL_Print_R( CnvAD( Prj.Z.End.Datum ),   cPosC3 );
        PL_Print_R( ANum( Prj.Z.Dauer, 2 ),     cPosC4 );
        PL_Print( Prj.Z.User,                   cPosC5 );
        PL_Print( Prj.Z.Bemerkung,              cPosC6, cPos0r );
        PL_PrintLine;
      END;

      PL_PrintLine;
      PL_PrintLine;
    end;

    /* Beschreibung */
    Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1' ), vTxtHdl, 0, 0, 0, 0 );
    vLines # vTxtHdl->TextInfo( _textLines );

    if ( vLines > 0 ) then begin
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print( 'Beschreibung', cPos0 );
      pls_fontAttr # _winFontAttrN;
      pls_fontSize # 9;
      PL_PrintLine;

      FOR  vLine # 1;
      LOOP vLine # vLine + 1;
      WHILE ( vLine <= vLines ) DO BEGIN
        PL_Print( vTxtHdl->TextLineRead( vLine, 0 ), cPosT1, cPos0r );
        PL_PrintLine;
      END;

      PL_PrintLine;
      PL_PrintLine;
    end;

    /* Interne Informationen */
    Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2' ), vTxtHdl, 0, 0, 0, 0 );
    vLines # vTxtHdl->TextInfo( _textLines );

    if ( vLines > 0 ) then begin
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print( 'Interne Informationen', cPos0 );
      pls_fontAttr # _winFontAttrN;
      pls_fontSize # 9;
      PL_PrintLine;

      FOR  vLine # 1;
      LOOP vLine # vLine + 1;
      WHILE ( vLine <= vLines ) DO BEGIN
        PL_Print( vTxtHdl->TextLineRead( vLine, 0 ), cPosT1, cPos0r );
        PL_PrintLine;
      END;

      PL_PrintLine;
      PL_PrintLine;
    end;

    /* Externe Anhänge */
    vFirst  # true;
    vFilter # RecFilterCreate( 916, 1 );
    vFilter->RecFilterAdd( 1, _fltAnd, _fltEq, 122 );
    vFilter->RecFilterAdd( 2, _fltAnd, _fltEq, Lib_Rec:MakeKey( 122 ) );

    FOR  Erx # RecRead( 916, 1, _recFirst, vFilter );
    LOOP Erx # RecRead( 916, 1, _recNext, vFilter );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      if ( vFirst ) then begin
        pls_fontSize # 10;
        pls_fontAttr # _winFontAttrB;
        PL_Print( 'Externe Anhänge', cPos0 );
        pls_fontAttr # _winFontAttrN;
        pls_fontSize # 9;
        PL_PrintLine;
        vFirst # false;
      end;

      PL_Print( Anh.File, cPosT1, cPosT3 );
      PL_Print( Anh.Bemerkung, cPosT3 );
      PL_PrintLine;
    END;

    vFilter->RecFilterDestroy();
  END;

  vTxtHdl->TextClose();

  /* Druck beenden */
  Usr.Username # UserInfo( _userName, CnvIA( UserInfo( _userCurrent ) ) );
  RecRead( 800, 1, 0 );
  // Lib_Print:FrmJobClose( !"Frm.DirektdruckYN" );
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  if ( vPrintLine != 0 ) then
    PL_Destroy( vPrintLine );

end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN (opt aFilename : alpha(4096))
begin
  Sel.Auf.von.Projekt # Prj.P.Position; // Projektposition, von
  Sel.Auf.bis.Projekt # Prj.P.Position; // Projektposition, bis
  Gv.Logic.11         # true; // Stunden, angebotene
  Gv.Logic.12         # true; // Stunden, geplante
  Gv.Logic.13         # true; // Stunden, interne
  Gv.Logic.14         # true; // Stunden, externe
  Gv.Logic.15         # true; // Stunden, detailierte Zeiten

  // bei Dateiausgabe, keine Selektionskriterien anzeigen, sondern vorbelegen
  if (aFilename <> '') then begin
    Sel.Auf.von.Projekt # 1;
    Sel.Auf.bis.Projekt # 9999;
    Gv.Logic.11         # true; // Stunden, angebotene
    Gv.Logic.12         # true; // Stunden, geplante
    Gv.Logic.13         # true; // Stunden, interne
    Gv.Logic.14         # true; // Stunden, externe
    Gv.Logic.15         # true; // Stunden, detailierte Zeiten
    Printform(aFilename);
    RETURN;
  end;

  gMDI # Lib_GuiCom:AddChildWindow( gMDI, 'Sel.PrjP.PrjBlatt', here + ':PrintForm' );
  Lib_GuiCom:RunChildWindow( gMDI );
end;

//=========================================================================
//=========================================================================