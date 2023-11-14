@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_ZAu_Scheck
//                      OHNE E_R_G
//  Info
//    Druckt eine Scheck zu einem Zahlungsausgang
//
//
//  29.09.2008  AI  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//    SUB Print(aTyp : alpha);
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG
@I:Def_Aktionen

declare Print(aTyp : alpha);

define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  // Positions
  cPos0     :  10.0 // Standardeinzug, links
  cPos0r    : 180.0 // Standardeinzug, rechts
  cPosT1    :  15.0 // Anschrifteneinzug
  cPosT2    :  45.0 // Adresseneinzug (Warenempfänger, Verbraucher, Rechnungsempfänger)
  cPosKopf1 : 110.0 // Kopfblock Einzug 1
  cPosKopf2 : 145.0 // Kopfblock Einzug 2 (Werte)

  cPos1   :  12.0 // ReNummer
  cPos2   :  40.0 // Datum
  cPos3   :  90.0 // ReBetrag
  cPos4   : 120.0 // Skonto
  cPos5   : 160.0 // Zahlung

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0
end;

local begin
  vGesSkonto  : float;
  vGesBetrag  : float;
end;


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
local begin
  vBuf100 : int;
end;
begin
  vBuf100 # RekSave(100);
  RecLink(100,565,2,_RecFirst);   // Lieferant holen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(ZAu.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  RecLink(100,565,2,_RecFirst);   // Lieferant holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  RecLink(812,101,2,_recFirst);   // Land holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  Lib_Print:Print_TextAbsolut( 'Firma xxxxxxxxxxxxxxxxxxxxxxx', 1.0, 3.0, 12 );

  // Anschrift & Kopf Block
  pls_fontSize # 9;
  PL_Print( 'aaaaaaaaaaaaaaaa', cPosKopf1 );
  PL_PrintLine;
  PL_Print( 'bbbbbbbbbbbbbbb', cPosKopf1 );
  PL_PrintLine;


  pls_fontSize # 6;
  pls_fontAttr # _WinFontAttrU;
  PL_Print( "Set.Absenderzeile", cPosT1 );
  pls_fontAttr # 0;
  pls_fontSize # 9;
  PL_Print( 'Deutschland', cPosKopf1 );
  PL_PrintLine;

  pls_fontSize # 10;
  PL_Print( "Adr.A.Anrede", cPosT1 );
  pls_fontSize # 9;
  PL_Print( 'Datum:', cPosKopf1 );
  PL_Print( CnvAD( today ), cPosKopf2 );
  PL_PrintLine;

  pls_fontSize # 10;
  PL_Print( "Adr.A.Name", cPosT1 );
  pls_fontSize # 9;
  PL_Print( 'Kundennr:', cPosKopf1 );
  PL_Print( Adr.EK.Referenznr, cPosKopf2 );
  PL_PrintLine;

  PL_Print( "Adr.A.Zusatz", cPosT1 );
  PL_PrintLine;

  PL_Print( "Adr.A.Straße", cPosT1 );
  PL_PrintLine;

  PL_Print( "Adr.A.PLZ" + ' ' + "Adr.A.Ort", cPosT1 );
  PL_PrintLine;
  if ( "Lnd.Kürzel" != 'D' ) then
    PL_Print( "Lnd.Name.L1", cPosT1 );
  PL_PrintLine;

  PL_PrintLine;
  PL_PrintLine;
  pls_FontSize # 9;
  pls_Fontattr # 0;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
    PL_PrintLine;
    PL_Print('Bitte verwenden Sie zum Ausgleich nachstehender Kosten diesen Orderscheck.',cPos0);
    PL_PrintLine;
    PL_PrintLine;
  end; // 1.Seite


  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # y;
    pls_FontSize  # 10;
    PL_Print('Rechnungsnr.',cPos1);
    PL_Print('Datum',cPos2);
    PL_Print_R('Re-Betrag',cPos3);
    PL_Print_R('Skonto',cPos4);
    PL_Print_R('Zahlbetrag',cPos5);
    PL_Drawbox(cPos1 - 2.0, cPos5 + 2.0, _winColBlack, 5.0 );
    PL_PrintLine;
  end;

end;


//========================================================================
//  Int2String
//
//========================================================================
sub Int2String(aWert : int) : alpha;
local begin
  vI    : int;
  vWert : alpha;
  vText : alpha;
end;
begin

  vWert # AInt(aWert);
  FOR vI # 1 loop inc(vI) WHILE (vI<=StrLen(vWert)) do begin

    case StrCut(vWert,vI,1) of
      '0' : vText # vText + 'null ';
      '1' : vText # vText + 'eins ';
      '2' : vText # vText + 'zwei ';
      '3' : vText # vText + 'drei ';
      '4' : vText # vText + 'vier ';
      '5' : vText # vText + 'fünf ';
      '6' : vText # vText + 'sechs ';
      '7' : vText # vText + 'sieben ';
      '8' : vText # vText + 'acht ';
      '9' : vText # vText + 'neun ';
    end;
  END;

  RETURN vText;
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  vI          : int;
  vText       : alpha;
  vRestbetrag : float;
  vbisher     : float;
end;
begin

  case aTyp of

    'POS' : begin
      vRestbetrag # ERe.Z.Betrag;//ERe.BruttoW1;// - ERe.ZahlungenW1;
      //vbisher     # ERe.ZahlungenW1 - ERe.Z.BetragW1;
      PL_Print(ERe.Rechnungsnr,cPos1);
      PL_Print(cnvAD(ERe.Rechnungsdatum),cPos2);
      PL_Print_R(ANum(ERe.Brutto,2)+' '+"Wae.Kürzel",cPos3);
      //PL_Print_R(ANum(vbisher,2)+' '+"Wae.Kürzel",cPos4);
      PL_Print_R(ANum(ERe.Z.Skontobetrag,2)+' '+"Wae.Kürzel",cPos4);
      //PL_Print_R(ANum(ERe.Z.Betrag,2)+' '+"Wae.Kürzel",cPos6);
      PL_Print_R(ANum(vRestbetrag,2)+' '+"Set.Hauswährung.Kurz",cPos5);
      PL_PrintLine;
      vGesBetrag # vGesBetrag + vRestBetrag;
    end;


    'SUMME' : begin
      PL_Print('Summe:', cPos1);
      PL_Print_R(ANum(vGesBetrag,2)+' '+"Set.Hauswährung.Kurz",cPos5);
      PL_PrintLine;
    end;


    'SCHECK' : begin
      RecLink(100,565,2,_RecFirst);   // Lieferant holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      RecLink(812,101,2,_recFirst);   // Land holen

      vI    # Cnvif(Trn(vGesBetrag));
      vText # '*** '+Int2String(vI)+'***';

      Lib_Print:Print_TextAbsolut( vText,                       1.0, 20.2 );
      Lib_Print:Print_TextAbsolut( Adr.A.Anrede,                1.0, 22.0 );
      Lib_Print:Print_TextAbsolut( Adr.A.Name,                  1.0, 22.4 );
      Lib_Print:Print_TextAbsolut( Adr.A.Zusatz,                1.0, 22.6 );
      Lib_Print:Print_TextAbsolut( "Adr.A.Straße",              1.0, 23.0 );
      Lib_Print:Print_TextAbsolut( Adr.A.PLZ + ' ' + Adr.A.Ort, 1.0, 23.4 );
      if ("Lnd.kürzel"<>'DE') then
        Lib_Print:Print_TextAbsolut( Lnd.Name.L1,               1.0, 23.8 );


      vText # ANum(vGesBetrag,2)+'*';
      vText # StrChar(42, 14 - StrLen(vText))+vText;
      Lib_Print:Print_TextAbsolut(vText,                  9.5, 21.0 );

      Lib_Print:Print_TextAbsolut(cnvad(today),           9.5, 23.0 );

    end;

  end;
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  // Datenspezifische Variablen
  vTxtName            : alpha;

  // Druckspezifische Variablen
  vPL                 : int;

  vFlag               : int;        // Datensatzlese option
end;

begin

  // ------ Druck vorbereiten ----------------------------------------------------------------

  RecLink(100,565,2,_RecFirst);   // Lieferant holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y,0,0,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

// ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();

// ------- POSITIONEN --------------------------------------------------------------------------

  // Zahlungen loopen...
  vFlag # _RecFirst;
  WHILE (RecLink(561,565,1,vFlag) <= _rLocked ) DO BEGIN
    vFlag # _RecNext;

    RecLink(560,561,1,0);   // Eingangsrechnung holen
    RecLink(814,560,6,0);   // Währung holen
    Print('POS');
  END; // WHILE: Zalhungen

  Lib_Print:Print_LinieDoppelt(cPos1,cPos5);

  PRINT('SUMME');

  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';

  PRINT('SCHECK');

  // 100 MM Rand unten lassen für den Fuss
  //WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(110.0,_PrtUnitMillimetres)) do
  //  PL_PrintLine;
  //PL_PrintLine;

// -------- Druck beenden ----------------------------------------------------------------
  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

  // letzte Seite & Job schließen, ggf. mit Vorschau
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);

end;


//=======================================================================