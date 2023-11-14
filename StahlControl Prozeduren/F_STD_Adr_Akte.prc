@A+
//==== Business-Control ===================================================
//
//  Prozedur    F_STD_Adr_Akte
//                  OHNE E_R_G
//  Info
//    Formular: Adressen / Kundenakte
//
//  07.12.2010  TM  Erstellung
//  01.08.2011  MS  Anpassung an SSW
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  30.08.2012  ST  Artikelumsatzprüfung mit ARtikelnr>'' und Materialnr = 0
//  13.08.2013  AH  Korrektur Summe Erlös
//  16.10.2013  AH  Anfragen
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  06.03.2015  ST  Bugfix RtfDruck: RTF Text wird nur gedruckt, wenn er gefüllt ist
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    sub GetDokName (var aSprache : alpha; var aAdresse : int) : alpha;
//    sub SeitenKopf (aSeite : int);
//    sub PrintForm ();
//    sub PrintMain(opt aFilename : alpha(4096))
//
//    MAIN (opt aFilename : alpha(4096))
//=========================================================================
@I:Def_Global
@I:Def_PrintLine

define begin
  cPos0   :  10.0   // Standardeinzug links
  cTab1   :  42.0
  cTab1b  :  50.0
  cTab1c  :  72.0
  cTab2   :  95.0
  cTab2b  : 125.0
  cTab3   : 127.0
  cTab3b  : 157.0
  cTab4   : 150.0

  cPos0r  : 180.0   // Standardeinzug rechts

  cPosCR  : 189.0              // Rechter Rand
  cPosCL  :  10.0              // Linker Rand

  cPosErl0 : 10.0              // 'Re.Datum'
  cPosErl1 : cPosErl0 + 32.0   // 'Re.Nr.'
  cPosErl2 : cPosErl1 + 25.0   // 'Netto €'
  cPosErl3 : cPosErl2 + 25.0   // 'Deckungsb.'
  cPosErl4 : cPosErl3 + 23.0   // 'DB/to'
  cPosErl5 : cPosErl4 + 25.0   // 'Auftragsmng.'
  cPosErl6 : cPosErl5 + 25.0   // 'gelief. Mng.'
  cPosErl7 : cPosErl6 + 25.0   // 'Gewicht kg'
  cPosErl8 : cPosErl7 + 25.0
  cPosErl9 : cPosErl8 + 25.0
  cPosErl10 : cPosErl9 + 20.0

  cPosERe0 : 10.0              // 'Re.Datum'
  cPosERe1 : cPosERe0 + 35.0   // 'int. Re.Nr.'
  cPosERe2 : cPosERe1 + 35.0   // 'ext. Re.Nr.'
  cPosERe3 : cPosERe2 + 30.0   // 'Brutto €'
  cPosERe4 : cPosERe3 + 25.0   // 'Steuer €'
  cPosERe5 : cPosERe4 + 25.0   // 'Netto €'
  cPosERe6 : cPosERe5 + 25.0   // 'Gewicht kg'
  cPosERe7 : cPosERe6 + 25.0
  cPosERe8 : cPosERe7 + 30.0
  cPosERe9 : cPosERe8 + 30.0
  cPosERe10 : cPosERe9 + 20.0

  cPosAuf0 : 10.0              // 'Auftrag'  ,
  cPosAuf1 : cPosAuf0   + 17.0   // 'Termin'   ,
  cPosAuf2 : cPosAuf1   + 20.0   // 'Wgr'      ,
  cPosAuf3 : cPosAuf2   + 5.0    // 'Qualität' ,
  cPosAuf4 : cPosAuf3   + 30.0   // 'St'         ,
  cPosAuf5 : cPosAuf4   + 10.0   // 'Abmessung',
  cPosAuf6 : cPosAuf5   + 50.0   // 'Rest'  ,
  cPosAuf7 : cPosAuf6   + 5.0   // 'MEH'  ,
  cPosAuf8 : cPosAuf7   + 20.0   //  'E-Preis €'
  cPosAuf9 : cPosAuf8   + 7.0   // 'PEH',
  cPosAuf10 : cPosAuf9  + 20.0  // 'Gesamt €',
  cPosAuf11 : cPosAuf10 + 20.0  //

  cPosAufResArt0 : 10.0                    //
  cPosAufResArt1 : cPosAufResArt0 + 30.0   //
  cPosAufResArt2 : cPosAufResArt1 + 40.0   //
  cPosAufResArt3 : cPosAufResArt2 + 35.0    //
  cPosAufResArt4 : cPosAufResArt3 + 5.0   //
  cPosAufResArt5 : cPosAufResArt4 + 20.0   //
  cPosAufResArt6 : cPosAufResArt5 + 10.0   //
  cPosAufResArt7 : cPosAufResArt6 + 22.0   //
  cPosAufResArt8 : cPosAufResArt7 + 5.0   //
  cPosAufResArt9 : cPosAufResArt8 + 20.0
  cPosAufResArt10 : cPosAufResArt9 + 20.0

  cPosEinResArt0 : 10.0                    //
  cPosEinResArt1 : cPosEinResArt0 + 30.0   //
  cPosEinResArt2 : cPosEinResArt1 + 40.0   //
  cPosEinResArt3 : cPosEinResArt2 + 35.0    //
  cPosEinResArt4 : cPosEinResArt3 + 5.0   //
  cPosEinResArt5 : cPosEinResArt4 + 20.0   //
  cPosEinResArt6 : cPosEinResArt5 + 10.0   //
  cPosEinResArt7 : cPosEinResArt6 + 22.0   //
  cPosEinResArt8 : cPosEinResArt7 + 5.0   //
  cPosEinResArt9 : cPosEinResArt8 + 20.0
  cPosEinResArt10 : cPosEinResArt9 + 20.0

  cPosAufAArt0 : 10.0                  //
  cPosAufAArt1 : cPosAufAArt0 + 30.0   // 'Artikel-Nr.'
  cPosAufAArt2 : cPosAufAArt1 + 50.0   // 'Stichwort'
  cPosAufAArt3 : cPosAufAArt2 + 5.0   // 'Auftrag'
  cPosAufAArt4 : cPosAufAArt3 + 30.0   // 'Re-Datum'
  cPosAufAArt5 : cPosAufAArt4 + 5.0   // 'Menge'
  cPosAufAArt6 : cPosAufAArt5 + 25.0   // 'MEH'
  cPosAufAArt7 : cPosAufAArt6 + 25.0   // 'E-Preis €'
  cPosAufAArt8 : cPosAufAArt7 + 25.0   // 'VK-Wert €'
  cPosAufAArt9 : cPosAufAArt8 + 20.0
  cPosAufAArt10 : cPosAufAArt9 + 20.0

  cPosAufAMat0 : 10.0                 //
  cPosAufAMat1 : cPosAufAMat0 + 30.0  //
  cPosAufAMat2 : cPosAufAMat1 + 10.0  //
  cPosAufAMat3 : cPosAufAMat2 + 5.0  //
  cPosAufAMat4 : cPosAufAMat3 + 25.0  //
  cPosAufAMat5 : cPosAufAMat4 + 15.0  //
  cPosAufAMat6 : cPosAufAMat5 + 15.0  //
  cPosAufAMat7 : cPosAufAMat6 + 5.0  //
  cPosAufAMat8 : cPosAufAMat7 + 40.0  //
  cPosAufAMat9 : cPosAufAMat8 + 15.0
  cPosAufAMat10 : cPosAufAMat9 + 25.0
  cPosAufAMat11 : cPosAufAMat10 + 20.0
  cPosAufAMat12 : cPosAufAMat11 + 20.0

  cPosEin0 : 10.0               // 'Bestellung'
  cPosEin1 : cPosEin0  +  17.0 // 'Termin'
  cPosEin2 : cPosEin1  +  20.0 // 'Wgr'
  cPosEin3 : cPosEin2  + 5.0   // 'Qualität'
  cPosEin4 : cPosEin3  + 30.0  // 'St.'
  cPosEin5 : cPosEin4  + 10.0  // 'Abmessung'
  cPosEin6 : cPosEin5  + 50.0  // 'Rest kg'
  cPosEin7 : cPosEin6  + 5.0   // '€/t'
  cPosEin8 : cPosEin7  + 20.0  //
  cPosEin9 : cPosEin8  + 7.0
  cPosEin10 : cPosEin9 + 20.0
  cPosEin11 : cPosEin10 + 20.0

  cPosRek0 : 10.0              // 'Reklamation'
  cPosRek1 : cPosRek0 + 25.0   // 'Auf-/Ein-Nr.'
  cPosRek2 : cPosRek1 + 35.0   // 'Material'
  cPosRek3 : cPosRek2 + 22.0   // 'Gewicht kg'
  cPosRek4 : cPosRek3 + 20.0   // 'Wert €'
  cPosRek5 : cPosRek4 + 5.0   // 'Fehler'
  cPosRek6 : cPosRek5 + 65.0   //
  cPosRek7 : cPosRek6 + 30.0   //
  cPosRek8 : cPosRek7 + 30.0   //
  cPosRek9 : cPosRek8 + 30.0
  cPosRek10 : cPosRek9 + 30.0

  cPosOfp0 : 10.0               // 'Re. Datum'
  cPosOfp1 : cPosOfp0  + 40.0   // 'Re. Nr.'
  cPosOfp2 : cPosOfp1  + 10.0   // 'Fällig'
  cPosOfp3 : cPosOfp2  + 25.0   // 'Tage'
  cPosOfp4 : cPosOfp3  + 40.0   // 'Re. Betrag €'
  cPosOfp5 : cPosOfp4  + 40.0   // 'Offener Betrag'
  cPosOfp6 : cPosOfp5  + 20.0   //
  cPosOfp7 : cPosOfp6  + 20.0   //
  cPosOfp8 : cPosOfp7  + 20.0   //
  cPosOfp9 : cPosOfp8  + 20.0
  cPosOfp10 : cPosOfp9 + 20.0

  cPosVbk0 : 10.0              // 'Re.Datum'
  cPosVbk1 : cPosVbk0 + 35.0   // 'int. Re.Nr.'
  cPosVbk2 : cPosVbk1 + 35.0   // 'ext. Re.Nr.'
  cPosVbk3 : cPosVbk2 + 30.0   // 'Brutto €'
  cPosVbk4 : cPosVbk3 + 25.0   // 'Fällig €'
  cPosVbk5 : cPosVbk4 + 25.0   // 'Netto €'
  cPosVbk6 : cPosVbk5 + 25.0   // 'Gewicht kg'
  cPosVbk7 : cPosVbk6 + 25.0
  cPosVbk8 : cPosVbk7 + 30.0
  cPosVbk9 : cPosVbk8 + 30.0
  cPosVbk10 : cPosVbk9 + 20.0

  cPosVpg0 : 10.0              //
  cPosVpg1 : cPosVpg0 + 20.0   //
  cPosVpg2 : cPosVpg1 + 20.0   //
  cPosVpg3 : cPosVpg2 + 20.0   //
  cPosVpg4 : cPosVpg3 + 20.0   //
  cPosVpg5 : cPosVpg4 + 20.0   //
  cPosVpg6 : cPosVpg5 + 20.0   //
  cPosVpg7 : cPosVpg6 + 20.0
  cPosVpg8 : cPosVpg7 + 20.0
  cPosVpg9 : cPosVpg8 + 20.0
  cPosVpg10 : cPosVpg9 + 20.0

  cHauptdatenYN    : GV.Logic.01
  cUmsaetzeYN      : GV.Logic.02
  cAuftraegeYN     : GV.Logic.03
  cBestellungenYN  : GV.Logic.04
  cReklamationenYN : GV.Logic.05
  cOfpVbkYN        : GV.Logic.06
  cVerpackungenYN  : GV.Logic.07
  cDatumVon        : GV.Datum.01
  cDatumBis        : GV.Datum.02
end;

local begin
  vTopMargin          : float;
  vSubTitle           : logic;
  vNum                : int;
  vName               : alpha;

  vErlGesBrutto       : float;
  vErlGesSteuer       : float;
  vErlGesNetto        : float;
  vErlGesGewicht      : float;
  vErlGesEK           : float;
  vErlGesInternK      : float;
  vErlGesMenge        : float;
  vErlGesAufMenge     : float;


  vErlEK              : float;
  vErlInternK         : float;
  vErlMenge           : float;
  vErlAufMenge        : float;

  vEReGesBrutto       : float;
  vEReGesSteuer       : float;
  vEReGesNetto        : float;
  vEReGesGewicht      : float;

  vVbkGesBrutto       : float;
  vVbkGesRest         : float;
  vVbkGesSteuer       : float;
  vVbkGesNetto        : float;
  vVbkGesGewicht      : float;

  vAufGesRest         : float;
  vAufGesWert         : float;
  vEinGesRest         : float;

  vRekGesGewicht      : float;
  vRekGesWert         : float;

  vOfpGesRest         : float;

  vAufAArtGesBrutto   : float;
  vAufAMatGesGewicht  : float;
  vAufAMatGesBrutto   : float;

  vGesamtwert         : float;

  vPos                : int;
end;

declare PrintMain(opt aFilename : alpha(4096))

//=========================================================================
// GetDokName
//        Bestimmt den Namen eines Dokuments
//=========================================================================
sub GetDokName (var aSprache : alpha; var aAdresse : int) : alpha;
begin
  aSprache # ''
  aAdresse # Adr.V.AdressNr;

  RETURN CnvAI(Adr.V.Adressnr, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8) + '/' + CnvAI(Adr.V.lfdNr, _fmtNumNoGroup | _fmtNumLeadZero, 0, 4);
end;

//========================================================================
//  PrintIfNotEmpty
//
//========================================================================
sub PrintIfNotEmpty(aName : alpha; aContent : alpha; var aPos : int);
local begin
  aXName    : float;
  aXContent : float;
end;
begin
  if(aContent = '') then
    RETURN;

  if(aPos % 2 > 0) then begin // 1 Pos.
    aXName    # cPos0;
    aXContent # cTab1;
  end
  else begin // 2. Pos
    aXName    # cTab2;
    aXContent # cTab3;
  end;

  PL_Print(aName, aXName);
  PL_Print(aContent, aXContent);
  if(aPos % 2 = 0) then
    PL_PrintLine;

  aPos # aPos + 1;
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  vX          : logic;
  vText       : alpha(4000);
  vDeckungsb  : float;
  vEPreis     : float;
end;
begin

  case (aTyp) of

    'ErlKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Erlöse', cPosErl0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      PL_Print('Re.Datum', cPosErl0);
      PL_Print_R('Re.Nr.', cPosErl1);
      PL_Print_R('Netto €', cPosErl2);
      PL_Print_R('Deckungsb.', cPosErl3);
      /*
      PL_Print_R('DB/to', cPosErl4);
      PL_Print_R('Auftragsmng.', cPosErl5);
      PL_Print_R('gelief. Mng.', cPosErl6);
      PL_Print_R('Gewicht kg', cPosErl7);
      */
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosErl0, cPosErl3);
    end;

    'ErlPos' : begin
      PL_PrintD_L(Erl.Rechnungsdatum, cPosErl0);
      PL_PrintI(Erl.Rechnungsnr, cPosErl1);
      PL_PrintF(Erl.NettoW1, 2, cPosErl2);
      vDeckungsb #  Erl.NettoW1 - vErlEK - vErlInternK;
      PL_PrintF(vDeckungsb, 2, cPosErl3);
      /*
      if(Erl.Gewicht <> 0.0) then
        PL_PrintF(vDeckungsb / (Erl.Gewicht / 1000.0), 2, cPosErl4);
      PL_PrintF(vErlAufMenge, Set.Stellen.Gewicht, cPosErl5);
      PL_PrintF(vErlMenge, Set.Stellen.Gewicht, cPosErl6);
      PL_PrintF(Erl.Gewicht, Set.Stellen.Gewicht, cPosErl7);
      */
      PL_PrintLine;
    end;

    'ErlFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosErl0, cPosErl3);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vErlGesNetto , 2, cPosErl2);
      vDeckungsb #  vErlGesNetto - vErlGesEK - vErlGesInternK;
      PL_PrintF(vDeckungsb, 2, cPosErl3);
      /*
      if(vErlGesGewicht <> 0.0) then
        PL_PrintF(vDeckungsb / (vErlGesGewicht / 1000.0), 2, cPosErl4);
      PL_PrintF(vErlGesAufMenge, Set.Stellen.Gewicht, cPosErl5);
      PL_PrintF(vErlGesMenge, Set.Stellen.Gewicht, cPosErl6);
      PL_PrintF(vErlGesGewicht, Set.Stellen.Gewicht, cPosErl7);
      */
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

    'AufAMatKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Materialumsatz', cPosErl0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      PL_Print('Re.Datum',    cPosAufAMat0);
      PL_Print_R('Auftrag',    cPosAufAMat1);
      PL_Print_R('Wgr.',       cPosAufAMat2);
      PL_Print('Güte',         cPosAufAMat3);
      PL_Print_R('Dicke',      cPosAufAMat4);
      PL_Print_R('Breite',     cPosAufAMat5);
      PL_Print_R('Länge',      cPosAufAMat6);
      PL_Print('Obf.',         cPosAufAMat7);
      PL_Print_R('Gewicht kg', cPosAufAMat8);
      PL_Print_R('E-Preis €',  cPosAufAMat9);
      PL_Print_R('Umsatz €',   cPosAufAMat10);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosAufAMat0, cPosAufAMat10);
    end;

    'AufAMatPos' : begin
      PL_PrintD_L(Auf.A.Rechnungsdatum,  cPosAufAMat0);
      PL_Print_R(AInt(Auf.A.Nummer)+ '/ '+ AInt(Auf.A.Position),   cPosAufAMat1);
      PL_PrintI(Mat.Warengruppe,     cPosAufAMat2);
      PL_Print("Mat.Güte", cPosAufAMat3);
      PL_PrintF(Mat.Dicke, Set.Stellen.Dicke, cPosAufAMat4);
      PL_PrintF(Mat.Breite, Set.Stellen.Breite, cPosAufAMat5);
      PL_PrintF("Mat.Länge", "Set.Stellen.Länge", cPosAufAMat6);
      PL_Print("Mat.AusführungOben",   cPosAufAMat7);
      PL_PrintF(Auf.A.Menge.Preis, Set.Stellen.Gewicht, cPosAufAMat8);
      PL_PrintF(Auf.P.Einzelpreis, 2, cPosAufAMat9);
      PL_PrintF(Auf.A.RechPreisW1, 2, cPosAufAMat10);
      PL_PrintLine;
    end;

    'AufAMatFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosErl0, cPosAufAMat10);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vAufAMatGesGewicht, Set.Stellen.Gewicht, cPosAufAMat8);
      PL_PrintF(vAufAMatGesBrutto, 2, cPosAufAMat10);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

    'AufAArtKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Artikelumsatz', cPosErl0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      PL_Print(  'Artikel-Nr.', cPosAufAArt0);
      PL_Print('Stichwort', cPosAufAArt1);
      PL_Print_R('Auftrag',   cPosAufAArt2);
      PL_Print('Re-Datum',  cPosAufAArt3);
      PL_Print_R('Menge',     cPosAufAArt4);
      PL_Print('MEH',       cPosAufAArt5);
      PL_Print_R('E-Preis €', cPosAufAArt6);
      PL_Print_R('VK-Wert €', cPosAufAArt7);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosAufAArt0, cPosAufAArt7);
    end;

    'AufAArtPos' : begin
      PL_Print(Art.Nummer, cPosAufAArt0);
      PL_Print(Art.Stichwort, cPosAufAArt1);
      PL_Print_R(AInt(Auf.A.Nummer)+ '/ '+ AInt(Auf.A.Position),   cPosAufAArt2);
      PL_PrintD_L(Auf.A.Rechnungsdatum,  cPosAufAArt3);
      PL_PrintF(Auf.A.Menge, Set.Stellen.Menge,     cPosAufAArt4);
      PL_Print(Art.MEH,      cPosAufAArt5);
      vEPreis # 0.0;
      if(Auf.A.Menge <> 0.0) then
        vEPreis # Auf.A.RechPreisW1 / Auf.A.Menge;
      PL_PrintF(vEPreis, 2, cPosAufAArt6);
      PL_PrintF(Auf.A.RechPreisW1, 2, cPosAufAArt7);
      PL_PrintLine;
    end;

    'AufAArtFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosErl0, cPosAufAArt7);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vAufAArtGesBrutto, Set.Stellen.Gewicht, cPosAufAArt7);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

    'EReKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Eingangsrechnungen', cPosERe0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      PL_Print('Re.Datum', cPosERe0);
      PL_Print_R('int. Re.Nr.', cPosERe1);
      PL_Print_R('ext. Re.Nr.', cPosERe2);
      PL_Print_R('Brutto €', cPosERe3);
      PL_Print_R('Steuer €', cPosERe4);
      PL_Print_R('Netto €', cPosERe5);
      PL_Print_R('Gewicht kg', cPosERe6);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosERe0, cPosERe6);
    end;

    'ERePos' : begin
      PL_PrintD_L(ERe.Rechnungsdatum, cPosERe0);
      PL_PrintI(ERe.Nummer, cPosERe1);
      PL_Print_R(ERe.Rechnungsnr, cPosERe2);
      PL_PrintF(ERe.BruttoW1, 2, cPosERe3);
      PL_PrintF(ERe.SteuerW1, 2, cPosERe4);
      PL_PrintF(ERe.NettoW1, 2, cPosERe5);
      PL_PrintF(ERe.Gewicht, Set.Stellen.Gewicht, cPosERe6);
      PL_PrintLine;
    end;

    'EReFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosERe0, cPosERe6);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vEReGesBrutto , 2, cPosERe3);
      PL_PrintF(vEReGesNetto  , 2, cPosERe5);
      PL_PrintLine;

      PL_PrintF(vEReGesSteuer , 2, cPosERe4);
      PL_PrintF(vEReGesGewicht, Set.Stellen.Gewicht, cPosERe6);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

    'AufArtRestKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Offene Artikel Aufträge', cPosAufResArt0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;
      PL_Print('Artikelnummer'  , cPosAufResArt0);
      PL_Print('Art.Stichwort'   , cPosAufResArt1);
      PL_Print('Auftrags-Nr.'      , cPosAufResArt2);
      PL_Print_R('Menge' , cPosAufResArt3);
      PL_Print('MEH'         , cPosAufResArt4);
      PL_Print_R('E-Preis €', cPosAufResArt5);
      PL_Print_R('PEH'  , cPosAufResArt6);
      PL_Print_R('Gesamt €'      , cPosAufResArt7);
      PL_Print('Termin', cPosAufResArt8);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosAufResArt0, cPosAuf10);
    end;

    'AufArtRestPos' : begin
      PL_Print(Auf.P.Artikelnr  , cPosAufResArt0);
      PL_Print(Auf.P.ArtikelSW  , cPosAufResArt1);
      PL_Print(AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position), cPosAufResArt2);
      PL_PrintF(Auf.P.Prd.Rest, Set.Stellen.Gewicht, cPosAufResArt3);
      PL_Print(Auf.P.MEH.Preis, cPosAufResArt4);
      PL_PrintF(Auf.P.Einzelpreis, 2, cPosAufResArt5);
      PL_PrintI(Auf.P.PEH, cPosAufResArt6);
      PL_PrintF(vGesamtwert, 2, cPosAufResArt7);
      PL_PrintD_L(Auf.P.Termin1Wunsch, cPosAufResArt8);
      PL_PrintLine;

    end;

    'AufArtRestFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosAufResArt0, cPosAuf10);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vAufGesWert, Set.Stellen.Gewicht, cPosAufResArt7);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

    'AufKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Offene Aufträge', cPosAuf0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;
      PL_Print(  'Auftrag'  , cPosAuf0);
      PL_Print(  'Termin'   , cPosAuf1);
      PL_Print_R('Wgr'      , cPosAuf2);
      PL_Print(  'Qualität' , cPosAuf3);
      PL_Print(  ''         , cPosAuf4);
      PL_Print(  'Abmessung', cPosAuf5);
      PL_Print_R('Rest'  , cPosAuf6);
      PL_Print(  'MEH'  , cPosAuf7);
      PL_Print_R('E-Preis €'      , cPosAuf8);
      PL_Print_R('PEH', cPosAuf9);
      PL_Print_R('Gesamt €', cPosAuf10);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosAuf0, cPosAuf10);
    end;

    'AufPos' : begin
      PL_Print(AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position), cPosAuf0);
      PL_PrintD_L(Auf.P.Termin1Wunsch, cPosAuf1);
      PL_PrintI(Auf.P.Warengruppe, cPosAuf2);
      PL_Print("Auf.P.Güte", cPosAuf3);
      PL_Print("Auf.P.Gütenstufe", cPosAuf4);
      vText # '';
      Lib_Strings:Append(var vText, ANum(Auf.P.Dicke, Set.Stellen.Dicke), '');
      Lib_Strings:Append(var vText, ANum(Auf.P.Breite, Set.Stellen.Breite), ' x ');
      if("Auf.P.Länge" <> 0.0) then
        Lib_Strings:Append(var vText, ANum("Auf.P.Länge", "Set.Stellen.Länge"), ' x ');
      PL_Print(vText, cPosAuf5);
      PL_PrintF(Auf.P.Prd.Rest, Set.Stellen.Gewicht, cPosAuf6);
      PL_Print(Auf.P.MEH.Preis, cPosAuf7);
      PL_PrintF(Auf.P.Einzelpreis, 2, cPosAuf8);
      PL_PrintI(Auf.P.PEH, cPosAuf9);
      PL_PrintF(vGesamtwert, 2, cPosAuf10);
      PL_PrintLine;
    end;

    'AufFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosAuf0, cPosAuf10);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vAufGesRest, Set.Stellen.Gewicht, cPosAuf6);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

    'EinKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Offene Bestellungen', cPosEin0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;
      PL_Print(  'Bestellung'  , cPosEin0);
      PL_Print(  'Termin'   , cPosEin1);
      PL_Print_R('Wgr'      , cPosEin2);
      PL_Print(  'Qualität' , cPosEin3);
      PL_Print(  ''         , cPosEin4);
      PL_Print(  'Abmessung', cPosEin5);
      PL_Print_R(  'Rest', cPosEin6);
      PL_Print(  'MEH'  , cPosEin7);
      PL_Print_R('E-Preis €'      , cPosEin8);
      PL_Print_R('PEH', cPosEin9);
      PL_Print_R('Gesamt €', cPosEin10);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosEin0, cPosEin10);
    end;

    'EinPos' : begin
      PL_Print(AInt(Ein.P.Nummer) + '/' + AInt(Ein.P.Position), cPosEin0);
      PL_PrintD_L(Ein.P.Termin1Wunsch, cPosEin1);
      PL_PrintI(Ein.P.Warengruppe, cPosEin2);
      PL_Print("Ein.P.Güte", cPosEin3);
      PL_Print("Ein.P.Gütenstufe", cPosEin4);
      vText # '';
      Lib_Strings:Append(var vText, ANum(Ein.P.Dicke, Set.Stellen.Dicke), '');
      Lib_Strings:Append(var vText, ANum(Ein.P.Breite, Set.Stellen.Breite), ' x ');
      if("Ein.P.Länge" <> 0.0) then
        Lib_Strings:Append(var vText, ANum("Ein.P.Länge", "Set.Stellen.Länge"), ' x ');
      PL_Print(vText, cPosEin5);
      PL_PrintF(Ein.P.FM.Rest, Set.Stellen.Gewicht, cPosEin6);
       PL_Print(Ein.P.MEH, cPosEin7);
      PL_PrintF(Ein.P.Einzelpreis, 2, cPosEin8);
      PL_PrintI(Ein.P.PEH, cPosEin9);
      PL_PrintF(vGesamtwert, 2, cPosEin10);
      PL_PrintLine;
    end;

    'EinFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosEin0, cPosEin10);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vEinGesRest, Set.Stellen.Gewicht, cPosEin6);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

    'EinArtRestKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Offene Artikel Bestellungen', cPosEinResArt0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;
      PL_Print('Artikelnummer'  , cPosEinResArt0);
      PL_Print('Art.Stichwort'   , cPosEinResArt1);
      PL_Print('Auftrags-Nr.'      , cPosEinResArt2);
      PL_Print_R('Menge' , cPosEinResArt3);
      PL_Print('MEH'         , cPosEinResArt4);
      PL_Print_R('E-Preis €', cPosEinResArt5);
      PL_Print_R('PEH'  , cPosEinResArt6);
      PL_Print_R('Gesamt €'      , cPosEinResArt7);
      PL_Print('Termin', cPosEinResArt8);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosEinResArt0, cPosEin10);
    end;

    'EinArtRestPos' : begin
      PL_Print(Ein.P.Artikelnr  , cPosEinResArt0);
      PL_Print(Ein.P.ArtikelSW  , cPosEinResArt1);
      PL_Print(AInt(Ein.P.Nummer) + '/' + AInt(Ein.P.Position), cPosEinResArt2);
      PL_PrintF(Ein.P.FM.Rest, Set.Stellen.Gewicht, cPosEinResArt3);
      PL_Print(Ein.P.MEH.Preis, cPosEinResArt4);
      PL_PrintF(Ein.P.Einzelpreis, 2, cPosEinResArt5);
      PL_PrintI(Ein.P.PEH, cPosEinResArt6);
      PL_PrintF(Ein.P.FM.Rest, 2, cPosEinResArt7);
      PL_PrintD_L(Ein.P.Termin1Wunsch, cPosEinResArt8);
      PL_PrintLine;
    end;

    'EinArtRestFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosEinResArt0, cPosEin10);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vEinGesRest, Set.Stellen.Gewicht, cPosEinResArt7);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

    'RekKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Offene Reklamationen', cPosRek0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;
      PL_Print(  'Reklamation'  , cPosRek0);
      PL_Print(  'Auf-/Ein-Nr.' , cPosRek1);
      PL_Print_R('Material'     , cPosRek2);
      PL_Print_R('Gewicht kg'   , cPosRek3);
      PL_Print_R('Wert €'       , cPosRek4);
      PL_Print(  'Fehler'       , cPosRek5);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosRek0, cPosRek6);
    end;

    'RekPos' : begin
      PL_Print(AInt(Rek.P.Nummer) + '/' + AInt(Rek.P.Position), cPosRek0);
      if(Rek.Kundennr <> 0) then
        PL_Print(AInt(Rek.Auftragsnr) + '/' + AInt(Rek.Auftragspos), cPosRek1);
      else if (Rek.Lieferantennr <> 0) then
        PL_Print(AInt(Rek.Einkaufsnr) + '/' + AInt(Rek.Einkaufspos), cPosRek1);
      PL_PrintI(Rek.P.Materialnr, cPosRek2);
      PL_PrintF(Rek.P.Gewicht, Set.Stellen.Gewicht, cPosRek3);
      PL_PrintF(Rek.P.Wert.W1, 2, cPosRek4);
      PL_Print(FhC.Bezeichnung, cPosRek5);
      PL_PrintLine;

    end;

    'RekFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosRek0, cPosRek6);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vRekGesGewicht, Set.Stellen.Gewicht, cPosRek3);
      PL_PrintF(vRekGesWert   , 2, cPosRek4);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

    'FaelligeOfpKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Fällige Offene Posten', cPosOfp0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;
      PL_Print(  'Re. Datum'          , cPosOfp0);
      PL_Print_R('Re. Nr.'         , cPosOfp1);
      PL_Print(  'Fällig'          , cPosOfp2);
      PL_Print_R('Tage'           , cPosOfp3);
      PL_Print_R('Re. Betrag €'       , cPosOfp4);
      PL_Print_R('Offener Betrag €'       , cPosOfp5);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosOfp0, cPosOfp5);
    end;

    'FaelligeOfpPos' : begin
      PL_PrintD_L(Ofp.Rechnungsdatum, cPosOfp0);
      PL_PrintI(Ofp.Rechnungsnr, cPosOfp1);
      PL_PrintD_L(OfP.Zieldatum, cPosOfp2);
      PL_PrintI(cnvID(today) - cnvID(OfP.Zieldatum), cPosOfp3);
      PL_PrintF(OfP.BruttoW1, 2, cPosOfp4);
      PL_PrintF(OfP.RestW1, 2, cPosOfp5);
      PL_PrintLine;
    end;

    'FaelligeOfpFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosOfp0, cPosOfp5);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vOfpGesRest, 2, cPosOfp5);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;


    'OfpKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Offene Posten', cPosOfp0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;
      PL_Print(  'Re. Datum'          , cPosOfp0);
      PL_Print_R('Re. Nr.'         , cPosOfp1);
      PL_Print(  'Fällig'          , cPosOfp2);
      PL_Print_R('Tage'           , cPosOfp3);
      PL_Print_R('Re. Betrag €'       , cPosOfp4);
      PL_Print_R('Offener Betrag €'       , cPosOfp5);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosOfp0, cPosOfp5);
    end;

    'OfpPos' : begin
      PL_PrintD_L(Ofp.Rechnungsdatum, cPosOfp0);
      PL_PrintI(Ofp.Rechnungsnr, cPosOfp1);
      PL_PrintD_L(OfP.Zieldatum, cPosOfp2);
      PL_PrintI(cnvID(today) - cnvID(OfP.Zieldatum), cPosOfp3);
      PL_PrintF(OfP.BruttoW1, 2, cPosOfp4);
      PL_PrintF(OfP.RestW1, 2, cPosOfp5);
      PL_PrintLine;
    end;

    'OfpFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosOfp0, cPosOfp5);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vOfpGesRest, 2, cPosOfp5);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;

   'VbkKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Verbindlichkeiten', cPosVbk0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      PL_Print('Re.Datum', cPosVbk0);
      PL_Print_R('int. Re.Nr.', cPosVbk1);
      PL_Print_R('ext. Re.Nr.', cPosVbk2);
      PL_Print_R('Fällig €', cPosVbk3);
      PL_Print_R('Rest €', cPosVbk4);
      PL_Print_R('Netto €', cPosVbk5);
      PL_Print_R('Gewicht kg', cPosVbk6);
      PL_PrintLine;
      Lib_Print:Print_LinieEinzeln(cPosVbk0, cPosVbk6);
    end;

    'VbkPos' : begin
      PL_PrintD_L(ERe.Rechnungsdatum, cPosVbk0);
      PL_PrintI(ERe.Nummer, cPosVbk1);
      PL_Print_R(ERe.Rechnungsnr, cPosVbk2);
      PL_PrintF(ERe.BruttoW1, 2, cPosVbk3);
      PL_PrintF(ERe.RestW1, 2, cPosVbk4);
      PL_PrintF(ERe.NettoW1, 2, cPosVbk5);
      PL_PrintF(ERe.Gewicht, Set.Stellen.Gewicht, cPosVbk6);
      PL_PrintLine;
    end;

    'VbkFuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosVbk0, cPosVbk6);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintF(vVbkGesBrutto , 2, cPosVbk3);
      PL_PrintF(vVbkGesNetto  , 2, cPosVbk5);
      PL_PrintLine;

      PL_PrintF(vVbkGesRest , 2, cPosVbk4);
      PL_PrintF(vVbkGesGewicht, Set.Stellen.Gewicht, cPosVbk6);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;



  end; // case

end;

//========================================================================
//  Print2
//
//========================================================================
sub Print2(aTyp : alpha);
local begin
  Erx       : int;
  vX    : logic;
  vText : alpha(4000);
end;
begin

  case (aTyp) of
    'PARTNER' : begin
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print('Ansprechpartner',cPos0);
      PL_PrintLine;
      PL_PrintLine;

      pls_fontSize # 9;
      pls_fontAttr # 0;
      Form_Mode # '';
    end;

    'ANSCHRIFT' : begin
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print('Lieferanschriften',cPos0);
      PL_PrintLine;
      PL_PrintLine;

      pls_fontSize # 9;
      pls_fontAttr # 0;
      Form_Mode # '';
    end;

    'LZB' : begin
      // Liefer- / Zahlungsbedingungen
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print('Liefer- und Zahlungsbedingungen',cPos0);
      PL_PrintLine;
      PL_PrintLine;
      pls_fontSize # 9;
      pls_fontAttr # 0;
      Erx # RecLink(815,100,6,0);
      if (Erx < _rLocked) then
        RecBufClear(816);
      PL_Print('VK Lieferbedingung:',cPos0);
      PL_Print(LiB.Bezeichnung.L1,cTab1b);
      PL_PrintLine;

      Erx # RecLink(816,100,7,0);
      if (Erx > _rLocked) then
        RecBufClear(816);
      PL_Print('Zahlungsbedingung:',cPos0);
      PL_Print(ZaB.Bezeichnung1.L1,cTab1b);
      PL_PrintLine;
      if (ZaB.Bezeichnung2.L1 <> '') then
      PL_Print(ZaB.Bezeichnung2.L1,cTab1b);
      PL_PrintLine;


      Erx # RecLink(817,100,8,0);
      if (Erx > _rLocked) then
        RecBufClear(817);
      PL_Print('Versandart:',cPos0);
      PL_Print(VsA.Bezeichnung.L1,cTab1b);
      PL_PrintLine;

      PL_Print('Lieferantennr. bei Kd.:',cPos0);
      PL_Print(Adr.VK.Referenznr,cTab1b);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;

      Erx # RecLink(815,100,2,0);
      if (Erx > _rLocked) then
        RecBufClear(816);
      PL_Print('EK Lieferbedingung:',cPos0);
      PL_Print(LiB.Bezeichnung.L1,cTab1b);
      PL_PrintLine;

      Erx # RecLink(816,100,3,0);
      if (Erx > _rLocked) then
        RecBufClear(816);
      PL_Print('Zahlungsbedingung:',cPos0);
      PL_Print(ZaB.Bezeichnung1.L1,cTab1b);
      PL_PrintLine;
      if (ZaB.Bezeichnung2.L1 <> '') then
      PL_Print(ZaB.Bezeichnung2.L1,cTab1b);
      PL_PrintLine;

      Erx # RecLink(817,100,4,0);
      if (Erx > _rLocked) then
        RecBufClear(817);
      PL_Print('Versandart:',cPos0);
      PL_Print(VsA.Bezeichnung.L1,cTab1b);
      PL_PrintLine;

      PL_Print('Kundennr. bei Lief.:',cPos0);
      PL_Print(Adr.EK.Referenznr,cTab1b);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;

      Erx # RecLink(814, 100, 5, _recFirst); // Waehrung holen
      if(Erx > _rLocked) then
        RecBufClear(814);
      PL_Print('Abrechnung in:',cPos0);
      PL_Print("Wae.Kürzel" + ' / ' + Wae.Bezeichnung,cTab1b);
      PL_PrintLine;

      PL_Print('Zahlung in:',cPos0);
      PL_Print("Wae.Kürzel" + ' / ' + Wae.Bezeichnung,cTab1b);
      PL_PrintLine;

      PL_Print('USt-Ident-Nr.:',cPos0);
      PL_Print(Adr.USIdentNr,cTab1b);
      PL_PrintLine;

      Erx # RecLink(813, 100, 11, _recFirst); // Sts. holen
      if(Erx > _rLocked) then
        RecBufClear(813);
      PL_Print('Steuerschlüssel:',cPos0);
      PL_Print(cnvaf(StS.Prozent, 0, 0, 2) + ' % ' + StS.Bezeichnung,cTab1b);
      PL_PrintLine;

      PL_Print('Steuernummer:',cPos0);
      PL_Print(Adr.Steuernummer,cTab1b);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;
    end;

    'HAUPTDATEN' : begin
      /* Hausanschrift / Postanschrift */
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print('Hausanschrift',cPos0);
      PL_Print('Postanschrift',cTab2);
      PL_PrintLine;
      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;

      pls_fontAttr # 0;
      PL_Print(Adr.Anrede,cPos0);
      if (Adr.Postfach <> '') then
        PL_Print(Adr.Anrede,cTab2);
      PL_PrintLine;

      PL_Print(Adr.Name,cPos0);
      if (Adr.Postfach <> '') then
        PL_Print(Adr.Name,cTab2);
      PL_PrintLine;

      PL_Print(Adr.Zusatz,cPos0);
      if (Adr.Postfach <> '') then
        PL_Print(Adr.Zusatz,cTab2);
      PL_PrintLine;

      PL_Print("Adr.Straße",cPos0);
      if (Adr.Postfach <> '') then
        PL_Print(Adr.Postfach,cTab2);
      PL_PrintLine;

      if (Adr.PLZ <> '') then
        PL_Print(Adr.PLZ + ' ' + Adr.Ort,cPos0)
      else
        PL_Print(Adr.Ort,cPos0);

      if (Adr.Postfach <> '') then begin
        if (Adr.Postfach.PLZ <> '') then
          PL_Print(Adr.Postfach.PLZ + ' ' + Adr.Ort,cTab2);
        else
          PL_Print(Adr.Ort,cTab2);
      End;

      PL_PrintLine;

      Erx # RecLink(812,100,10,0);
      if (Erx > _rLocked) then
        RecBufClear(812);
      PL_Print(Lnd.Name.L1,cPos0);
      PL_Print(Lnd.Name.L1,cTab2);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;

      PL_Print('Telefon 1:',cPos0);
      PL_Print(Adr.Telefon1,cTab1);
      PL_Print('Telefon 2:',cTab2);
      PL_Print(Adr.Telefon2,cTab3);
      PL_PrintLine;

      PL_Print('Telefax:',cPos0);
      PL_Print(Adr.Telefax,cTab1);
      PL_Print('',cTab2);
      PL_Print('',cTab3);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;

      PL_Print('e-Mail:',cPos0);
      PL_Print(Adr.eMail,cTab1);
      PL_PrintLine;

      PL_Print('Homepage:',cPos0);
      PL_Print(Adr.Website,cTab1);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;

      PL_Print('Briefanrede:',cPos0);
      PL_Print(Adr.Briefanrede,cTab1);
      PL_PrintLine;

      PL_Print('Briefgruppe:',cPos0);
      PL_Print(Adr.Briefgruppe,cTab1);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;


      // Bankdaten
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print('Bankverbindung 1',cPos0);
      PL_Print('Bankverbindung 2',cTab2);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;

      pls_fontAttr # 0;
      PL_Print('Bank:',cPos0);
      PL_Print(Adr.Bank1.Name,cTab1);
      PL_Print('Bank:',cTab2);
      PL_Print(Adr.Bank2.Name,cTab3);
      PL_PrintLine;

      PL_Print('BLZ:',cPos0);
      PL_Print(Adr.Bank1.BLZ,cTab1);
      PL_Print('BLZ:',cTab2);
      PL_Print(Adr.Bank2.BLZ,cTab3);
      PL_PrintLine;

      PL_Print('Konto:',cPos0);
      PL_Print(Adr.Bank1.Kontonr,cTab1);
      PL_Print('Konto:',cTab2);
      PL_Print(Adr.Bank2.Kontonr,cTab3);
      PL_PrintLine;

      PL_Print('IBAN:',cPos0);
      PL_Print(Adr.Bank1.IBAN,cTab1);
      PL_Print('IBAN:',cTab2);
      PL_Print(Adr.Bank2.IBAN,cTab3);
      PL_PrintLine;

      PL_Print('BIC SWIFT:',cPos0);
      PL_Print(Adr.Bank1.BIC.SWIFT,cTab1);
      PL_Print('BIC SWIFT:',cTab2);
      PL_Print(Adr.Bank2.BIC.SWIFT,cTab3);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;
    end;

    'KREDITVERSICHERUNG' : begin
      // Kreditversicherungf
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print('Kreditversicherungsdaten',cPos0);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;

      Erx # RecLink(103,100,14,0);
      if (Erx > _rLocked) then
        RecBufClear(103);
      Erx # RecLink(814,103,2,0);
      if (Erx > _rLocked) then
        RecBufClear(814);

      pls_fontAttr # 0;
      PL_Print('Währung:',cPos0);
      PL_Print("Wae.Kürzel" + ' / ' + Wae.Bezeichnung,cTab1b);

      PL_Print('Kreditlimit kurzz.:',cTab2);

      if (Adr.K.KurzLimitFW > 0.0) then
        PL_Print(cnvaf(Adr.K.KurzLimitFW,0,0,2) + ' bis ' + cnvad(Adr.K.KurzLimit.Dat,_FmtDateLongYear),cTab3)
      else
        PL_Print(cnvaf(Adr.K.KurzLimitW1,0,0,2) + ' bis ' + cnvad(Adr.K.KurzLimit.Dat,_FmtDateLongYear),cTab3);

      PL_PrintLine;

      PL_Print('Kreditversicherung:',cPos0);

      if (Adr.K.VersichertFW > 0.0) then
        PL_Print(cnvaf(Adr.K.VersichertFW,0,0,2),cTab1b)
      else
        PL_Print(cnvaf(Adr.K.VersichertW1,0,0,2),cTab1b);

      PL_Print('Kreditversicherer:',cTab2);
      PL_Print(Adr.K.Versicherer,cTab3);

      PL_PrintLine;

      PL_Print('Kreditlimit:',cPos0);
      PL_Print(cnvaf(Adr.K.InternLimit,0,0,2),cTab1b);

      PL_Print('Referenznummer:',cTab2);
      PL_Print(Adr.K.Referenznr,cTab3);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;
    end;

    'UMSATZDATEN' : begin
      pls_fontSize # 10;
      pls_fontAttr # _winFontAttrB;
      PL_Print('Finanzen',cPos0);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;

      pls_fontAttr # 0;
      Adr_Data:BerechneFinanzen(); // Finanzen zur Adresse neu berechnen

      PL_Print('Auftragsrest:',cPos0);
      PL_Print_R(cnvaf(Adr.Fin.SummeAB,0,0,2),cTab1c -1.0);
      PL_Print('Offene Posten:',cTab2);
      PL_Print_R(cnvaf(Adr.Fin.SummeOP,0,0,2),cTab4 -1.0);
      PL_PrintLine;

      PL_Print('Reservierungen:',cPos0);
      PL_Print_R(cnvaf(Adr.Fin.SummeRes,0,0,2),cTab1c -1.0);
      PL_Print('Fremd-OP:',cTab2);
      PL_Print_R(cnvaf(Adr.Fin.SummeOP.Ext,0,0,2),cTab4 -1.0);
      PL_PrintLine;

      PL_Print('Lfd. Liefermenge:',cPos0);
      PL_Print_R(cnvaf(Adr.Fin.SummeLFS,0,0,2),cTab1c -1.0);
      PL_Print('akt. Kreditlimit:',cTab2);
      PL_Print_R(cnvaf(Adr.Fin.SummePlan,0,0,2),cTab4 -1.0);
      PL_PrintLine;

      PL_Print('zu berechnende Auf.:',cPos0);
      PL_Print_R(cnvaf("Adr.Fin.SummeABBerE",0,0,2),cTab1c -1.0);
      PL_Print('STAND VOM:',cTab2);
      PL_Print_R(cnvad(Adr.Fin.RefreshDatum),cTab4 -1.0);
      PL_PrintLine;

      pls_fontSize # 6;
      PL_PrintLine;
      pls_fontSize # 9;
    end;

    'ANSPRECHPARTNER' : begin
      // Ansprechpartner
      Erx # RecLink(102,100,13,_recFirst);
      if (Erx <= _rMultiKey) then begin
        Form_Mode # 'PARTNER';
        pls_fontSize # 10;
        pls_fontAttr # _winFontAttrB;
        PL_Print('Ansprechpartner',cPos0);
        PL_PrintLine;
        PL_PrintLine;

        pls_fontSize # 9;
        pls_fontAttr # 0;


        WHILE (Erx <= _rMultiKey) DO BEGIN
          vName # '';

          if (Adr.P.Vorname <> '')      then vName # vName + Adr.P.Vorname + ' ';
          if (Adr.P.Name <> '')         then vName # vName + Adr.P.Name + ' ';

          PL_Print(vName,cPos0);
          PL_Print(Adr.P.Funktion,cTab1c);
          PL_Print(Adr.P.Telefon,cTab2b);
          PL_Print(Adr.P.eMail,cTab3b);
          PL_PrintLine;
          Erx # RecLink(102,100,13,_recNext);
        End;
        Form_Mode # '';
        pls_fontSize # 6;
        PL_PrintLine;
        pls_fontSize # 9;
      end;
    end;

    'LIEFERANSCHRIFTEN' : begin
      // Lieferanschriften
      Erx # RecLink(101,100,12,_recFirst);
      if (Erx <= _rMultiKey) then begin
        Form_Mode # 'ANSCHRIFT';
        pls_fontSize # 10;
        pls_fontAttr # _winFontAttrB;
        PL_Print('Lieferanschriften',cPos0);
        PL_PrintLine;
        PL_PrintLine;

        pls_fontSize # 9;
        pls_fontAttr # 0;
      end;

      WHILE (Erx <= _rMultiKey) DO BEGIN
        vName # '';

        PL_Print(Adr.A.Name,cPos0);
        PL_Print(Adr.A.Warenannahme1,cTab2);
        PL_PrintLine;

        PL_Print(Adr.A.Zusatz,cPos0);
        PL_Print(Adr.A.Warenannahme2,cTab2);
        PL_PrintLine;

        PL_Print("Adr.A.Straße",cPos0);
        PL_Print(Adr.A.Warenannahme3,cTab2);
        PL_PrintLine;

        PL_Print(Adr.A.PLZ + ' ' + Adr.A.Ort,cPos0);
        PL_Print(Adr.A.Warenannahme4,cTab2);
        PL_PrintLine;
        Erx # RecLink(812,101,2,0);
        if (Erx > _rLocked) then RecBufClear(812);
        PL_Print(lnd.Name.L1,cPos0);
        PL_Print(Adr.A.Warenannahme5,cTab2);
        PL_PrintLine;
        PL_PrintLine;


        Erx # RecLink(101,100,12,_recNext);
      END;
    end;

  'VpgKopf' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Verpackungen', cPosVpg0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      //PL_PrintLine;
      //Lib_Print:Print_LinieEinzeln(cPosVpg0, cPosVpg6);
    end;

    'VpgHauptdaten' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Hauptdaten', cPosVpg0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      PL_Print('Verpackungsnr.:', cPos0);
      PL_PrintI_L(Adr.V.lfdNr, cTab1);
      PL_PrintLine;

      vPos # 1;
      PrintIfNotEmpty('Kd.ArtNr.:', Adr.V.KundenArtNr, var vPos);
      PrintIfNotEmpty('Abholnr.:', Adr.V.Strukturnr, var vPos);
      PrintIfNotEmpty('Zwischenlage:', Adr.V.Zwischenlage, var vPos);
      PrintIfNotEmpty('Unterlage:', Adr.V.Unterlage, var vPos);
      PrintIfNotEmpty('Umverpackung:', Adr.V.Zwischenlage, var vPos);
      if("Adr.V.Stapelhöhe" <> 0.0) then
        PrintIfNotEmpty('max. Stapelhöhe:', ANum("Adr.V.Stapelhöhe", 2), var vPos);
      if("Adr.V.StapelhAbzug" <> 0.0) then
        PrintIfNotEmpty('Höhenabzug:', ANum(Adr.V.StapelhAbzug, 2), var vPos);
      if(Adr.V.AbbindungL <> 0) then
        PrintIfNotEmpty('Abbind.längs:', AInt(Adr.V.AbbindungL), var vPos);
      if(Adr.V.AbbindungQ <> 0) then
        PrintIfNotEmpty('Abbind.quer:', AInt(Adr.V.AbbindungQ), var vPos);
      if(Adr.V.StehendYN = true) then
        PrintIfNotEmpty('stehend:', 'ja', var vPos);
      else
        PrintIfNotEmpty('stehend:', 'nein', var vPos);
      if(Adr.V.LiegendYN = true) then
        PrintIfNotEmpty('liegend:', 'ja', var vPos);
      else
        PrintIfNotEmpty('liegend:', 'nein', var vPos);


      if(Adr.V.Verwiegungsart <> 0) then
        PrintIfNotEmpty('Verwiegungsart:', '(' + AInt(Adr.V.Verwiegungsart) + ') ' + VwA.Bezeichnung.L1, var vPos);
      if(Adr.V.Etikettentyp <> 0) then
        PrintIfNotEmpty('Etikettentyp:', '(' + AInt(Adr.V.Etikettentyp) + ') ' + Eti.Bezeichnung, var vPos);
      if(Adr.V.RingKgVon <> 0.0) then
        PrintIfNotEmpty('Ringgewicht von:', ANum(Adr.V.RingKgVon, Set.Stellen.Gewicht), var vPos);
      if(Adr.V.RingKgBis <> 0.0) then
        PrintIfNotEmpty('bis:', ANum(Adr.V.RingKgBis, Set.Stellen.Gewicht), var vPos);
      if(Adr.V.KgmmVon <> 0.0) then
        PrintIfNotEmpty('kg/mm von:', ANum(Adr.V.KgmmVon, Set.Stellen.Gewicht), var vPos);
      if(Adr.V.KgmmBis <> 0.0) then
        PrintIfNotEmpty('bis:', ANum(Adr.V.KgmmBis, Set.Stellen.Gewicht), var vPos);
      if(Adr.V.RechtwinkMax <> 0.0) then
        PrintIfNotEmpty('Rechtwink. max:', ANum(Adr.V.RechtwinkMax, 2), var vPos);
      if(Adr.V.EbenheitMax <> 0.0) then
        PrintIfNotEmpty('Ebenheut max:', ANum(Adr.V.EbenheitMax, 2), var vPos);
      if("Adr.V.SäbeligkeitMax" <> 0.0) then
        PrintIfNotEmpty('Säbeligkeit max:', ANum("Adr.V.SäbeligkeitMax", 2), var vPos);
      PrintIfNotEmpty('Wicklung:', Adr.V.Wicklung, var vPos);
      if(Adr.V.VEkgMax <> 0.0) then
        PrintIfNotEmpty('max. VE-Gewicht:', ANum(Adr.V.VEkgMax, Set.Stellen.Gewicht), var vPos);
      if("Adr.V.StückProVE" <> 0) then
        PrintIfNotEmpty('max. Stück/VE:', AInt("Adr.V.StückProVE"), var vPos);
      if(Adr.V.Nettoabzug <> 0.0) then
        PrintIfNotEmpty('Nettoabzug:', ANum(Adr.V.Nettoabzug, 2), var vPos);
      if(vPos % 2 = 0) then
        PL_PrintLine;
      if(Adr.V.VpgText1 <> '') then begin
        PL_Print(Adr.V.VpgText1, cPos0);
        PL_PrintLine;
      end;
      if(Adr.V.VpgText2 <> '') then begin
        PL_Print(Adr.V.VpgText2, cPos0);
        PL_PrintLine;
      end;
      if(Adr.V.VpgText3 <> '') then begin
        PL_Print(Adr.V.VpgText3, cPos0);
        PL_PrintLine;
      end;
      if(Adr.V.VpgText4 <> '') then begin
        PL_Print(Adr.V.VpgText4, cPos0);
        PL_PrintLine;
      end;
      if(Adr.V.VpgText5 <> '') then begin
        PL_Print(Adr.V.VpgText5, cPos0);
        PL_PrintLine;
      end;
    end;

    'VpgMaterial' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Material', cPosVpg0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      vPos # 1;
      if(Adr.V.Warengruppe <> 0) then
        PrintIfNotEmpty('Warengruppe:', '(' + AInt(Adr.V.Warengruppe) + ') ' + Wgr.Bezeichnung.L1, var vPos);
      PrintIfNotEmpty('Güte:', "Adr.V.Güte", var vPos);
      PrintIfNotEmpty('Gütenstufe:', "Adr.V.Gütenstufe", var vPos);
      PrintIfNotEmpty('Ausführung Oben:', Adr.V.AusfOben, var vPos);
      PrintIfNotEmpty('Ausführung Unten:', Adr.V.AusfUnten, var vPos);
      PrintIfNotEmpty('Zeugnisart:', Adr.V.Zeugnisart, var vPos);
      if(Adr.V.Dicke <> 0.0) then
        PrintIfNotEmpty('Dicke:', ANum(Adr.V.Dicke, Set.Stellen.Dicke), var vPos);
      PrintIfNotEmpty('Tol.:', Adr.V.DickenTol, var vPos);
      if(Adr.V.Breite <> 0.0) then
        PrintIfNotEmpty('Breite:', ANum(Adr.V.Breite, Set.Stellen.Breite), var vPos);
      PrintIfNotEmpty('Tol.:', Adr.V.Breitentol, var vPos);
      if("Adr.V.Länge" <> 0.0) then
        PrintIfNotEmpty('Länge:', ANum("Adr.V.Länge", "Set.Stellen.Länge"), var vPos);
      PrintIfNotEmpty('Tol.:', "Adr.V.Längentol", var vPos);
      if(Adr.V.RID <> 0.0) then
        PrintIfNotEmpty('RID:', ANum(Adr.V.RID, "Set.Stellen.Radien"), var vPos);
      if(Adr.V.RIDmax <> 0.0) then
        PrintIfNotEmpty('max.:', ANum(Adr.V.RIDmax, "Set.Stellen.Radien"), var vPos);
      if(Adr.V.RAD <> 0.0) then
        PrintIfNotEmpty('RAD:', ANum(Adr.V.RAD,"Set.Stellen.Radien"), var vPos);
      if(Adr.V.RADmax <> 0.0) then
        PrintIfNotEmpty('max.:', ANum(Adr.V.RADmax, "Set.Stellen.Radien"), var vPos);
      if(Adr.V.EinsatzVPG.Adr <> 0) then
        PrintIfNotEmpty('Einsatz-VPG:', AInt(Adr.V.EinsatzVPG.Adr) + '/' + AInt(Adr.V.EinsatzVPG.Nr), var vPos);
      if(Adr.V.VorlageBAG <> 0) then
        PrintIfNotEmpty('Vorlage-BAG:', AInt(Adr.V.VorlageBAG), var vPos);
      if(Adr.V.PreisW1 <> 0.0) then
        PrintIfNotEmpty('Grundpreis:', ANum(Adr.V.PreisW1, 2), var vPos);
      if(Adr.V.PEH <> 0) or (Adr.V.MEH <> '') then
        PrintIfNotEmpty('Preisstellung in:', AInt(Adr.V.PEH) + ' ' + Adr.V.MEH, var vPos);

      if(vPos % 2 = 0) then
        PL_PrintLine;
    end;

    'VpgText' : begin
      PL_PrintLine;
    end;

    'VpgAnalyse' : begin
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Mechanische Vorgaben', cPosVpg0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      vPos # 1;
      if(Adr.V.Streckgrenze1 <> 0.0) or (Adr.V.Streckgrenze2 <> 0.0) then
        PrintIfNotEmpty('Streckg.(ReH):', cnvAF(Adr.V.Streckgrenze1) + ' N/mm² - ' + cnvAF(Adr.V.Streckgrenze2) + ' N/mm²', var vPos);
      if(Adr.V.Zugfestigkeit1 <> 0.0) or (Adr.V.Zugfestigkeit2 <> 0.0) then
        PrintIfNotEmpty('Zugfest.(Rm):', cnvAF(Adr.V.Zugfestigkeit1) + ' N/mm² - ' + cnvAF(Adr.V.Zugfestigkeit2) + ' N/mm²' , var vPos);
      if(Adr.V.DehnungA1 <> 0.0) or (Adr.V.DehnungA2 <> 0.0) then
        PrintIfNotEmpty('Dehnung:', cnvAF(Adr.V.DehnungA1) + ' N/mm² - ' + cnvAF(Adr.V.DehnungB1) + ' N/mm²' , var vPos);
      if("Adr.V.Härte1" <> 0.0) or ("Adr.V.Härte2" <> 0.0) then
        PrintIfNotEmpty('Härte:', cnvAF("Adr.V.Härte1") + ' - ' + cnvAF("Adr.V.Härte2")  , var vPos);
      if(Adr.V.DehnungA1 <> 0.0) or (Adr.V.DehnungA2 <> 0.0) then
        PrintIfNotEmpty('Rp 0,2:', cnvAF(Adr.V.DehnungA1) + ' - ' + cnvAF(Adr.V.DehnungA2)   , var vPos);
      if(Adr.V.DehnungB1 <> 0.0) or (Adr.V.DehnungB2 <> 0.0) then
        PrintIfNotEmpty('Rp 10:', cnvAF(Adr.V.DehnungB1) + ' - ' + cnvAF(Adr.V.DehnungB2)  , var vPos);
      if(Adr.V.RauigkeitA1 <> 0.0) or (Adr.V.RauigkeitA2 <> 0.0) then
        PrintIfNotEmpty('Rauhigkeit OS:', cnvAF(Adr.V.RauigkeitA1) + ' - ' + cnvAF(Adr.V.RauigkeitA2) , var vPos);
      if(Adr.V.RauigkeitB1 <> 0.0) or (Adr.V.RauigkeitB2 <> 0.0) then
        PrintIfNotEmpty('Rauhigkeit US:', cnvAF(Adr.V.RauigkeitB1) + ' - ' + cnvAF(Adr.V.RauigkeitB2), var vPos);
      if("Adr.V.Körnung1" <> 0.0) then
        PrintIfNotEmpty('Körnung:', cnvAF("Adr.V.Körnung1") , var vPos);
      if(Adr.V.Mech.Sonstig1 <> '') then
        PrintIfNotEmpty('Sonstiges:', Adr.V.Mech.Sonstig1, var vPos);

      if(vPos % 2 = 0) then
        PL_PrintLine;

      PL_PrintLine;
      pls_FontAttr # _WinFontAttrBold;
      PL_Print('Chemische Vorgaben', cPosVpg0);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
      PL_PrintLine;

      vPos # 1;
      if(Adr.V.Chemie.C1 <> 0.0) or (Adr.V.Chemie.C2 <> 0.0) then
        PrintIfNotEmpty('C:', cnvAF(Adr.V.Chemie.C1) + ' - ' + cnvAF(Adr.V.Chemie.C2), var vPos);
      if(Adr.V.Chemie.Si1 <> 0.0) or (Adr.V.Chemie.Si2 <> 0.0) then
        PrintIfNotEmpty('Si:', cnvAF(Adr.V.Chemie.Si1) + ' - ' + cnvAF(Adr.V.Chemie.Si2)    , var vPos);
      if(Adr.V.Chemie.Mn1 <> 0.0) or (Adr.V.Chemie.Mn2 <> 0.0) then
        PrintIfNotEmpty('Mn:', cnvAF(Adr.V.Chemie.Mn1) + ' - ' + cnvAF(Adr.V.Chemie.Mn2) , var vPos);
      if(Adr.V.Chemie.P1 <> 0.0) or (Adr.V.Chemie.P2 <> 0.0) then
        PrintIfNotEmpty('P:', cnvAF(Adr.V.Chemie.P1)  + ' - ' + cnvAF(Adr.V.Chemie.P2)  , var vPos);
      if(Adr.V.Chemie.S1 <> 0.0) or (Adr.V.Chemie.S2 <> 0.0) then
        PrintIfNotEmpty('S:', cnvAF(Adr.V.Chemie.S1)  + ' - ' + cnvAF(Adr.V.Chemie.S2) , var vPos);
      if(Adr.V.Chemie.Al1 <> 0.0) or (Adr.V.Chemie.Al2 <> 0.0) then
        PrintIfNotEmpty('Al:', cnvAF(Adr.V.Chemie.Al1) + ' - ' + cnvAF(Adr.V.Chemie.Al2) , var vPos);
      if(Adr.V.Chemie.Cr1 <> 0.0) or (Adr.V.Chemie.Cr2 <> 0.0) then
        PrintIfNotEmpty('Cr:', cnvAF(Adr.V.Chemie.Cr1)  + ' - ' + cnvAF(Adr.V.Chemie.Cr2)  , var vPos);
      if(Adr.V.Chemie.V1 <> 0.0) or (Adr.V.Chemie.V2 <> 0.0) then
        PrintIfNotEmpty('V:', cnvAF(Adr.V.Chemie.V1)   + ' - ' + cnvAF(Adr.V.Chemie.V2)  , var vPos);
      if(Adr.V.Chemie.Nb1 <> 0.0) or (Adr.V.Chemie.Nb2 <> 0.0) then
        PrintIfNotEmpty('Nb:', cnvAF(Adr.V.Chemie.Nb1)  + ' - ' + cnvAF(Adr.V.Chemie.Nb2) , var vPos);
      if(Adr.V.Chemie.Ti1 <> 0.0) or (Adr.V.Chemie.Ti2 <> 0.0) then
        PrintIfNotEmpty('Ti:', cnvAF(Adr.V.Chemie.Ti1) + ' - ' + cnvAF(Adr.V.Chemie.Ti2) , var vPos);
      if(Adr.V.Chemie.N1 <> 0.0) or (Adr.V.Chemie.N2 <> 0.0) then
        PrintIfNotEmpty('N:', cnvAF(Adr.V.Chemie.N1)  + ' - ' + cnvAF(Adr.V.Chemie.N2)  , var vPos);
      if(Adr.V.Chemie.Cu1 <> 0.0) or (Adr.V.Chemie.Cu2 <> 0.0) then
        PrintIfNotEmpty('Cu:', cnvAF(Adr.V.Chemie.Cu1) + ' - ' + cnvAF(Adr.V.Chemie.Cu2), var vPos);
      if(Adr.V.Chemie.Ni1 <> 0.0) or (Adr.V.Chemie.Ni2 <> 0.0) then
        PrintIfNotEmpty('Ni:', cnvAF(Adr.V.Chemie.Ni1) + ' - ' + cnvAF(Adr.V.Chemie.Ni2) , var vPos);
      if(Adr.V.Chemie.Mo1 <> 0.0) or (Adr.V.Chemie.Mo2 <> 0.0) then
        PrintIfNotEmpty('Mo:', cnvAF(Adr.V.Chemie.Mo1) + ' - ' + cnvAF(Adr.V.Chemie.Mo2)  , var vPos);
      if(Adr.V.Chemie.B1 <> 0.0) or (Adr.V.Chemie.B2 <> 0.0) then
        PrintIfNotEmpty('B:', cnvAF(Adr.V.Chemie.B1)  + ' - ' + cnvAF(Adr.V.Chemie.B2)   , var vPos);
      if(Adr.V.Chemie.Frei1.1 <> 0.0) or (Adr.V.Chemie.Frei1.2 <> 0.0) then
        PrintIfNotEmpty('?:', cnvAF(Adr.V.Chemie.Frei1.1) + ' - ' + cnvAF(Adr.V.Chemie.Frei1.2) , var vPos);
      if(vPos % 2 = 0) then
        PL_PrintLine;
    end;

    'VpgFuss' : begin
      //Lib_Print:Print_LinieEinzeln(cPosVpg0, cPosVpg6);
      pls_FontAttr # _WinFontAttrBold;
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;
    end;


  end; // case
end;

//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
local begin
end;
begin
  /*
  if(aSeite <> 999) then begin
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(cPosCL, cPosCR);
    pls_FontSize # 8;
    PL_Print('weiter auf der nächsten Seite' , 73.5);
    PL_PrintLine;
  end;
  */
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf des Formulars
//=========================================================================
sub SeitenKopf (aSeite : int);
local begin
  Erx       : int;
  vText : alpha;
end;
begin
  pls_fontSize # 9;

  /* Header */
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print('Kunden-/Lieferantenakte',cPos0);
  PL_Print_R('Seite ' + AInt(aSeite),cPos0r);
  PL_PrintLine;

  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  pls_fontAttr # 0;
  PL_Print('Kundennummer:',cPos0);
  PL_Print(cnvai(Adr.Kundennr),cTab1);
  PL_Print('Datum:',cTab2);
  vText # ''
  Lib_Strings:Append(var vText, cnvAD(cDatumVon), '');
  Lib_Strings:Append(var vText, 'bis ' + cnvAD(cDatumBis), ' ');
  PL_Print(vText,cTab3);
  PL_PrintLine;

  PL_Print('Lieferantennr.:',cPos0);
  PL_Print(AInt(Adr.Lieferantennr),cTab1);
  Usr.Username  # Adr.Sachbearbeiter;
  Erx # RecRead(800, 1, 0); // Usr. lesen
  if(Erx > _rLocked) then
    RecBufClear(800);
  vText # '';
  Lib_Strings:Append(var vText, Usr.Vorname, '');
  Lib_Strings:Append(var vText, Usr.Name, ' ');
  PL_Print('Sachbearbeiter:',cTab2);
  PL_Print(vText,cTab3);
  PL_PrintLine;

  PL_Print('Stichwort:',cPos0);
  PL_Print(Adr.Stichwort,cTab1);

  Erx # RecLink(110, 100, 15, _recFirst);  // Vertreter holen
  if (Erx > _rLocked) then
    RecBufClear(110);
  PL_Print('Vertreter:',cTab2);
  PL_Print(Ver.Name,cTab3);
  PL_PrintLine;

  PL_Print('Gruppe:',cPos0);
  PL_Print(Adr.Gruppe,cTab1);
  PL_Print('ABC / Punkte:',cTab2);
  PL_Print(Adr.ABC + ' / ' + cnvai(Adr.Punktzahl),cTab3);
  PL_PrintLine;

  pls_fontAttr # _winFontAttrN;
  Lib_Print:Print_LinieEinzeln(cPosCL, cPosCR);
  pls_fontSize # 6;
  PL_PrintLine;
  pls_fontSize # 9;

  if (Form_Mode = 'PARTNER') then
    Print('Partner');
  if (Form_Mode = 'ANSCHRIFT') then
    Print('Anschrift');

end;




//=========================================================================
// PrintSubTitle
//        Subtitel drucken
//=========================================================================
sub PrintSubTitle (aText : alpha; opt checkGlobal : logic)
begin
  if (checkGlobal and vSubTitle) then
    RETURN;

  PL_PrintLine;
  pls_fontSize # 10;
  pls_fontAttr # _winFontAttrB;
  PL_Print(aText, cPos0);
  pls_fontAttr # _winFontAttrN;
  pls_fontSize # 9;
  PL_PrintLine;

  if (checkGlobal) then
    vSubTitle # true;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
begin
  RecBufClear(999);

  cHauptdatenYN     # true;  //
  cUmsaetzeYN       # true;  //
  cAuftraegeYN      # true;  //
  cBestellungenYN   # true;  //
  cReklamationenYN  # true;  //
  cOfpVbkYN         # true;  //
  cVerpackungenYN   # true;  //

  cDatumBis         # today;

  if (aFilename <> '') then
    PrintMain(aFileName);
  else
    gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Sel.Adr.Akte', here + ':PrintMain');
  //gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;

//=========================================================================
// OffenePosten
//
//=========================================================================
sub OffenePosten()
local begin
  Erx       : int;
  vSel        : int;
  vSelName    : alpha;
  vItem       : int;
  vTree       : int;
  vQ460       : alpha(4000);
  vSortKey    : alpha;
end;
begin
  if(cOfpVbkYN = false) then
    RETURN;

   Lib_Print:Print_FF();

  /*
    OffenePosten
  */
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ460 # '';
  Lib_Sel:QInt(var vQ460, 'OfP.Kundennummer', '=', Adr.KundenNr);
  Lib_Sel:QAlpha(var vQ460, 'OfP.Löschmarker', '=', '');
  //Lib_Sel:QDate(var vQ460, 'OfP.Zieldatum', '>', today);

  vSel # SelCreate(460, 1);
  Erx # vSel->SelDefQuery('', vQ460);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(460,vSel, _recFirst);
  LOOP Erx # RecRead(460,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    vSortKey # cnvAI(OfP.Rechnungsnr, _FmtNumLeadZero, 0, 12);
    Sort_ItemAdd(vTree, vSortKey, 460, RecInfo(460,_RecId));
  END;
  SelClose(vSel);
  SelDelete(460, vSelName);
  vSel # 0;

  vOfpGesRest # 0.0;

  Print('OfpKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBOfpM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);

    Print('OfpPos');

    vOfpGesRest # vOfpGesRest + OfP.RestW1;
  END;
  Print('OfpFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE
end;

//=========================================================================
// FaelligeOffenePosten
//
//=========================================================================
sub FaelligeOffenePosten()
local begin
  Erx       : int;
  vSel        : int;
  vSelName    : alpha;
  vItem       : int;
  vTree       : int;
  vQ460       : alpha(4000);
  vSortKey    : alpha;
end;
begin
  if(cOfpVbkYN = false) then
    RETURN;
  /*
    OffenePosten
  */
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ460 # '';
  Lib_Sel:QInt(var vQ460, 'OfP.Kundennummer', '=', Adr.KundenNr);
  Lib_Sel:QAlpha(var vQ460, 'OfP.Löschmarker', '=', '');
  Lib_Sel:QDate(var vQ460, 'OfP.Zieldatum', '<=', today);

  vSel # SelCreate(460, 1);
  Erx # vSel->SelDefQuery('', vQ460);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(460,vSel, _recFirst);
  LOOP Erx # RecRead(460,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    vSortKey # cnvAI(OfP.Rechnungsnr, _FmtNumLeadZero, 0, 12);
    Sort_ItemAdd(vTree, vSortKey, 460, RecInfo(460,_RecId));
  END;
  SelClose(vSel);
  SelDelete(460, vSelName);
  vSel # 0;

  vOfpGesRest # 0.0;

  Print('FaelligeOfpKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBOfpM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);

    Print('FaelligeOfpPos');

    vOfpGesRest # vOfpGesRest + OfP.RestW1;
  END;
  Print('FaelligeOfpFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE
end;

//=========================================================================
// Reklamationen
//
//=========================================================================
sub Reklamationen()
local begin
  Erx       : int;
  vSel        : int;
  vSelName    : alpha;
  vItem       : int;
  vTree       : int;
  vQ301       : alpha(4000);
  vSortKey    : alpha;
end;
begin
  if(cReklamationenYN = false) then
    RETURN;
  if(Adr.KundenNr=0) and (Adr.LieferantenNr <> 0) then
    RETURN;

   Lib_Print:Print_FF();

  /*
    Reklamationen
  */
  vTree # CteOpen(_CteTreeCI);    // RambRekm anlegen
  vQ301 # '';
  if(Adr.KundenNr <> 0) then
    Lib_Sel:QInt(var vQ301, 'Rek.P.Kundennr', '=', Adr.KundenNr);
  if(Adr.LieferantenNr <> 0) then
    Lib_Sel:QInt(var vQ301, 'Rek.P.Lieferantennr', '=', Adr.LieferantenNr, 'OR');
  if (vQ301='') then
    RETURN;
  vQ301 # StrIns(vQ301, '(', 1);
  vQ301 # StrIns(vQ301, ')', StrLen(vQ301) + 1);
  Lib_Sel:QAlpha(var vQ301, 'Rek.P.Löschmarker', '=', '');


  vSel # SelCreate(301, 1);
  Erx # vSel->SelDefQuery('', vQ301);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(301,vSel, _recFirst);
  LOOP Erx # RecRead(301,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    vSortKey # cnvAI(Rek.P.Nummer, _FmtNumLeadZero, 0, 12) + cnvAI(Rek.P.Position, _FmtNumLeadZero, 0, 4)
    Sort_ItemAdd(vTree, vSortKey, 301, RecInfo(301,_RecId));
  END;
  SelClose(vSel);
  SelDelete(301, vSelName);
  vSel # 0;


  vRekGesGewicht  # 0.0;
  vRekGesWert     # 0.0;

  Print('RekKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBRekM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);

    Erx # RecLink(851, 301, 8, _recFirst); // Fehlercodes
    if(Erx > _rLocked) then
      RecBufClear(851);


    Print('RekPos');

    vRekGesGewicht  #  vRekGesGewicht + Rek.P.Gewicht;
    vRekGesWert     #  vRekGesWert    + Rek.P.Wert.W1;
  END;
  Print('RekFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE
end;

//=========================================================================
// Bestellungen
//
//=========================================================================
sub Bestellungen()
local begin
  Erx       : int;
  vSel        : int;
  vSelName    : alpha;
  vItem       : int;
  vTree       : int;
  vQ501       : alpha(4000);
  vSortKey    : alpha;
  vFontSize   : int;
end;
begin
  if(cBestellungenYN = false) then
    RETURN;

   Lib_Print:Print_FF();

  /*
    Bestellung
  */
  vTree # CteOpen(_CteTreeCI);    // RambEinm anlegen
  vQ501 # '';
  Lib_Sel:QInt(var vQ501, 'Ein.P.Lieferantennr', '=', Adr.LieferantenNr);
  Lib_Sel:QAlpha(var vQ501, 'Ein.P.Löschmarker', '=', '');
  Lib_Sel:QFloat(var vQ501, 'Ein.P.FM.Rest', '>', 0.0);
  Lib_Sel:QAlpha(var vQ501, 'Ein.P.Artikelnr', '=', '');

  vSel # SelCreate(501, 1);
  Erx # vSel->SelDefQuery('', vQ501);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(501,vSel, _recFirst);
  LOOP Erx # RecRead(501,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    RekLink(500,501,3,_recFirst); // Kopf holen
    if (Ein.Vorgangstyp<>c_Bestellung) then CYCLE;

    vSortKey # cnvAI(Ein.P.Nummer, _FmtNumLeadZero, 0, 12) + cnvAI(Ein.P.Position, _FmtNumLeadZero, 0, 4)
    Sort_ItemAdd(vTree, vSortKey, 501, RecInfo(501,_RecId));
  END;
  SelClose(vSel);
  SelDelete(501, vSelName);
  vSel # 0;

  vFontSize    # pls_FontSize;
  pls_FontSize # 7;


  vEinGesRest # 0.0;

  Print('EinKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBEinM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);

    vGesamtwert # 0.0;
    if(Ein.P.PEH <> 0) then
      vGesamtwert # (Ein.P.FM.Rest / cnvFI(Ein.P.PEH)) * Ein.P.Einzelpreis;


    Print('EinPos')

    vEinGesRest # vEinGesRest + Ein.P.FM.Rest;
  END;
  Print('EinFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE

  /*
    Bestellung Artikel
  */
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ501 # '';
  Lib_Sel:QInt(var vQ501, 'Ein.P.Lieferantennr', '=', Adr.LieferantenNr);
  Lib_Sel:QAlpha(var vQ501, 'Ein.P.Löschmarker', '=', '');
  Lib_Sel:QFloat(var vQ501, 'Ein.P.FM.Rest', '>', 0.0);
  Lib_Sel:QAlpha(var vQ501, 'Ein.P.Artikelnr', '!=', '');

  vSel # SelCreate(501, 1);
  Erx # vSel->SelDefQuery('', vQ501);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(501,vSel, _recFirst);
  LOOP Erx # RecRead(501,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    RekLink(500,501,3,_recFirst); // Kopf holen
    if (Ein.Vorgangstyp<>c_Bestellung) then CYCLE;
    vSortKey # StrFmt(Ein.P.Artikelnr, 25, _StrEnd) + cnvAI(Ein.P.Nummer, _FmtNumLeadZero, 0, 12) + cnvAI(Ein.P.Position, _FmtNumLeadZero, 0, 4)
    Sort_ItemAdd(vTree, vSortKey, 501, RecInfo(501,_RecId));
  END;
  SelClose(vSel);
  SelDelete(501, vSelName);
  vSel # 0;

  vEinGesRest # 0.0;

  Print('EinArtRestKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBEinM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);

    Print('EinArtRestPos')

    vEinGesRest # vEinGesRest + Ein.P.FM.Rest;
  END;
  Print('EinArtRestFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE

  pls_FontSize # vFontSize;
end;


//=========================================================================
// Auftraege
//
//=========================================================================
sub Auftraege()
local begin
  vSel        : int;
  Erx       : int;
  vSelName    : alpha;
  vItem       : int;
  vTree       : int;
  vQ401       : alpha(4000);
  vSortKey    : alpha;
  vFontSize   : int;
end;
begin
  if(cAuftraegeYN = false) then
    RETURN;

   Lib_Print:Print_FF();

  /*
    Auftraege
  */
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ401 # '';
  Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Adr.KundenNr);
  Lib_Sel:QAlpha(var vQ401, 'Auf.P.Löschmarker', '=', '');
  Lib_Sel:QFloat(var vQ401, 'Auf.P.Prd.Rest.Gew', '>', 0.0);
  Lib_Sel:QAlpha(var vQ401, 'Auf.P.Artikelnr', '=', '');

  vSel # SelCreate(401, 1);
  Erx # vSel->SelDefQuery('', vQ401);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(401,vSel, _recFirst);
  LOOP Erx # RecRead(401,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    //vSortKey # cnvAI(Auf.P.Nummer, _FmtNumLeadZero, 0, 12) + cnvAI(Auf.P.Position, _FmtNumLeadZero, 0, 4)
    vSortKey  # StrFmt("Auf.P.Güte", 20, _StrEnd)
          + cnvAF(Auf.P.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)
          + cnvAF(Auf.P.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)
          + cnvAF("Auf.P.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    Sort_ItemAdd(vTree, vSortKey, 401, RecInfo(401,_RecId));
  END;
  SelClose(vSel);
  SelDelete(401, vSelName);
  vSel # 0;

  vAufGesRest # 0.0;

  vFontSize    # pls_FontSize;
  pls_FontSize # 7;

  Print('AufKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID); // Datensatz holen
    vGesamtwert # 0.0;
    if(Auf.P.PEH <> 0) then
      vGesamtwert # (Auf.P.Prd.Rest / cnvFI(Auf.P.PEH)) * Auf.P.Grundpreis;

    Print('AufPos')

    vAufGesRest # vAufGesRest +  Auf.P.Prd.Rest.Gew;
  END;
  Print('AufFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE

  /*
    Auftraege-Restbestand
  */
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ401 # '';
  Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Adr.KundenNr);
  Lib_Sel:QAlpha(var vQ401, 'Auf.P.Löschmarker', '=', '');
  Lib_Sel:QFloat(var vQ401, 'Auf.P.Prd.Rest.Gew', '>', 0.0);
  Lib_Sel:QAlpha(var vQ401, 'Auf.P.Artikelnr', '!=', '');

  vSel # SelCreate(401, 1);
  Erx # vSel->SelDefQuery('', vQ401);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(401,vSel, _recFirst);
  LOOP Erx # RecRead(401,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    vSortKey # StrFmt(Auf.P.Artikelnr, 25, _StrEnd)
             + cnvAI(Auf.P.Nummer, _FmtNumLeadZero, 0, 12)
             + cnvAI(Auf.P.Position, _FmtNumLeadZero, 0, 4)
    Sort_ItemAdd(vTree, vSortKey, 401, RecInfo(401,_RecId));
  END;
  SelClose(vSel);
  SelDelete(401, vSelName);
  vSel # 0;

  vAufGesRest # 0.0;

  vFontSize    # pls_FontSize;
  pls_FontSize # 7;

  Print('AufArtRestKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID); // Datensatz holen


    vGesamtwert # 0.0;
    if(Auf.P.PEH <> 0) then
      vGesamtwert # (Auf.P.Prd.Rest / cnvFI(Auf.P.PEH)) * Auf.P.Grundpreis;

    Print('AufArtRestPos')

    vAufGesWert # vAufGesWert + vGesamtWert;
    vAufGesRest # vAufGesRest +  Auf.P.Prd.Rest.Gew;
  END;
  Print('AufArtRestFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE

  pls_FontSize # vFontSize;
end;

//=========================================================================
// Verbindlichkeiten
//
//=========================================================================
sub Verbindlichkeiten()
local begin
  Erx       : int;
  vSel        : int;
  vSelName    : alpha;
  vItem       : int;
  vTree       : int;
  vQ450       : alpha(4000);
  vQ560       : alpha(4000);
  vSortKey    : alpha;
end;
begin
  if(cOfpVbkYN = false) then
    RETURN;

  //Lib_Print:Print_FF();

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ560 # '';
  Lib_Sel:QInt(var vQ560, 'ERe.Lieferant', '=', Adr.LieferantenNr);
  if (cDatumVon <> 00.00.0000) or (cDatumBis <> today) then
   Lib_Sel:QVonBisD(var vQ560, 'ERe.Rechnungsdatum', cDatumVon, cDatumBis);

  vSel # SelCreate(560, 1);
  Erx # vSel->SelDefQuery('', vQ560);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(560,vSel, _recFirst);
  LOOP Erx # RecRead(560,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    vSortKey # cnvAI(ERe.Nummer, _FmtNumLeadZero, 0, 12)
    Sort_ItemAdd(vTree, vSortKey, 560, RecInfo(560,_RecId));
  END;
  SelClose(vSel);
  SelDelete(560, vSelName);
  vSel # 0;

  vVbkGesBrutto   # 0.0;
  vVbkGesSteuer   # 0.0;
  vVbkGesNetto    # 0.0;
  vVbkGesGewicht  # 0.0;
  vVbkGesRest     # 0.0;

  Print('VbkKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);

    Print('VbkPos');

    vVbkGesBrutto   # vVbkGesBrutto  + ERe.BruttoW1;
    vVbkGesSteuer   # vVbkGesSteuer  + ERe.SteuerW1;
    vVbkGesNetto    # vVbkGesNetto   + ERe.NettoW1;
    vVbkGesGewicht  # vVbkGesGewicht + ERe.Gewicht;
    vVbkGesRest     # vVbkGesRest    + ERe.RestW1;
  END;
  Print('VbkFuss');

  Sort_KillList(vTree); // Löschen der Liste
end;

//=========================================================================
// Umsaetze
//
//=========================================================================
sub Umsaetze()
local begin
  Erx       : int;
  vSel        : int;
  vSelName    : alpha;
  vItem       : int;
  vTree       : int;
  vQ450       : alpha(4000);
  vQ560       : alpha(4000);
  vQ401       : alpha(4000);
  vQ411       : alpha(4000);
  vQ404       : alpha(4000);
  vSortKey    : alpha;
  vFontSize   : int;
end;
begin
  if(cUmsaetzeYN = false) then
    RETURN;

  Lib_Print:Print_FF();

  /*
    ERLOESE
  */
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ450 # '';
  Lib_Sel:QInt(var vQ450, 'Erl.Kundennummer', '=', Adr.KundenNr);
  if (cDatumVon <> 0.0.0) or (cDatumBis <> today) then
   Lib_Sel:QVonBisD(var vQ450, 'Erl.Rechnungsdatum', cDatumVon, cDatumBis);

  vSel # SelCreate(450, 1);
  Erx # vSel->SelDefQuery('', vQ450);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(450,vSel, _recFirst);
  LOOP Erx # RecRead(450,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    vSortKey # cnvAI(Erl.Rechnungsnr, _FmtNumLeadZero, 0, 12)
    Sort_ItemAdd(vTree, vSortKey, 450, RecInfo(450,_RecId));
  END;
  SelClose(vSel);
  SelDelete(450, vSelName);
  vSel # 0;

  vErlGesBrutto   # 0.0;
  vErlGesSteuer   # 0.0;
  vErlGesNetto    # 0.0;
  vErlGesGewicht  # 0.0;
  vErlGesMenge    # 0.0;
  vErlGesAufMenge # 0.0;
  vErlGesEK       # 0.0;
  vErlGesInternK  # 0.0;

  vFontSize    # pls_FontSize;
  pls_FontSize # 7;

  Print('ErlKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);


    vErlEK       # 0.0;
    vErlInternK  # 0.0;
    vErlMenge    # 0.0;
    vErlAufMenge # 0.0;
    FOR Erx # RecLink(451, 450, 1, _recFirst); // Erloeskonten loopen
    LOOP Erx # RecLink(451, 450, 1, _recNext);
    WHILE(Erx <= _rLocked) DO BEGIN
      Auf_Data:Read(Erl.K.Auftragsnr, Erl.K.Auftragspos, true);

      vErlEK       # vErlEK       + Erl.K.EKPreisSummeW1;
      vErlInternK  # vErlInternK  + Erl.K.InterneKostW1;
      vErlMenge    # vErlMenge    + Erl.K.Menge;
      vErlAufMenge # vErlAufMenge + Auf.P.Menge;
    END;

    Print('ErlPos');

    vErlGesMenge    # vErlGesMenge    + vErlMenge;
    vErlGesAufMenge # vErlGesAufMenge + vErlAufMenge;
    vErlGesEK       # vErlGesEK       + vErlEK;
    vErlGesInternK  # vErlGesInternK  + vErlInternK
    vErlGesBrutto   # vErlGesBrutto   + Erl.BruttoW1;
    vErlGesSteuer   # vErlGesSteuer   + Erl.SteuerW1;
    vErlGesNetto    # vErlGesNetto    + Erl.NettoW1;
    vErlGesGewicht  # vErlGesGewicht  + Erl.Gewicht;
  END;
  Print('ErlFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE

  /*
    MATERIAL UMSATZ
  */
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ401 # '';
  vQ411 # '';
  vQ404 # '';
  if (cDatumVon <> 0.0.0) or (cDatumBis <> today) then
    Lib_Sel:QVonBisD(var vQ404, 'Auf.A.Rechnungsdatum', cDatumVon, cDatumBis);
  Lib_Sel:QDate(var vQ404, 'Auf.A.Rechnungsdatum', '>', 00.00.0000);
  Lib_Sel:QInt(var vQ404, 'Auf.A.Materialnr', '>', 0);

  Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Adr.KundenNr);
  Lib_Sel:QInt(var vQ411, '"Auf~P.Kundennr"', '=', Adr.KundenNr);
  Lib_Strings:Append(var vQ404, '((LinkCount(AufPos) > 0) OR (LinkCount(AufPosAbl) > 0))', ' AND ');

  vSel # SelCreate(404, 1);
  vSel->SelAddLink('', 401, 404, 1, 'AufPos');
  vSel->SelAddLink('', 411, 404, 7, 'AufPosAbl');
  Erx # vSel->SelDefQuery('', vQ404);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPos', vQ401);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPosAbl', vQ411);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(404, vSel, _recFirst);
  LOOP Erx # RecRead(404, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    Mat_Data:Read(Auf.A.Materialnr);

    //vSortKey # cnvAI(cnvID(Auf.A.Rechnungsdatum), _FmtNumLeadZero, 0, 12);
    vSortKey  # StrFmt("Mat.Güte", 20, _StrEnd)
              + cnvAF(Mat.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)
              + cnvAF(Mat.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)
              + cnvAF("Mat.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);
    Sort_ItemAdd(vTree, vSortKey, 404, RecInfo(404,_RecId));
  END;
  SelClose(vSel);
  SelDelete(404, vSelName);
  vSel # 0;

  vAufAMatGesBrutto   # 0.0;
  vAufAMatGesGewicht   # 0.0;

  Print('AufAMatKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID); // Datensatz holen

    Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, false);

    Mat_Data:Read(Auf.A.Materialnr);

    Print('AufAMatPos');

    vAufAMatGesBrutto  # vAufAMatGesBrutto + Auf.A.RechPreisW1;
    vAufAMatGesGewicht # vAufAMatGesGewicht + Auf.A.Menge.Preis;
  END;
  Print('AufAMatFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE



  /*
    ARTIKEL UMSATZ
  */
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ401 # '';
  vQ411 # '';
  vQ404 # '';
  if (cDatumVon <> 0.0.0) or (cDatumBis <> today) then
   Lib_Sel:QVonBisD(var vQ404, 'Auf.A.Rechnungsdatum', cDatumVon, cDatumBis);
  Lib_Sel:QDate(var vQ404, 'Auf.A.Rechnungsdatum', '>', 00.00.0000);
  Lib_Sel:QAlpha(var vQ404, 'Auf.A.Artikelnr', '>', '' );
  Lib_Sel:QInt(var vQ404, 'Auf.A.Materialnr', '=', 0);    // Materialnr muss 0 sein

  Lib_Sel:QInt(var vQ401, 'Auf.P.Kundennr', '=', Adr.KundenNr);
  Lib_Sel:QInt(var vQ411, '"Auf~P.Kundennr"', '=', Adr.KundenNr);
  Lib_Strings:Append(var vQ404, '((LinkCount(AufPos) > 0) OR (LinkCount(AufPosAbl) > 0))', ' AND ');

  vSel # SelCreate(404, 1);
  vSel->SelAddLink('', 401, 404, 1, 'AufPos');
  vSel->SelAddLink('', 411, 404, 7, 'AufPosAbl');
  Erx # vSel->SelDefQuery('', vQ404);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPos', vQ401);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPosAbl', vQ411);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(404, vSel, _recFirst);
  LOOP Erx # RecRead(404, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    //vSortKey # cnvAI(cnvID(Auf.A.Rechnungsdatum), _FmtNumLeadZero, 0, 12);
    vSortKey # StrFmt(Auf.A.ArtikelNr, 25, _StrEnd);
    Sort_ItemAdd(vTree, vSortKey, 404, RecInfo(404,_RecId));
  END;
  SelClose(vSel);
  SelDelete(404, vSelName);
  vSel # 0;

  vAufAArtGesBrutto   # 0.0;

  Print('AufAArtKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID); // Datensatz holen

    Erx # RecLink(250, 404, 3, _recFirst);   // Artikel holen
    if(Erx > _rLocked) then
      RecBufClear(250);

    Print('AufAArtPos');

    vAufAArtGesBrutto # vAufAArtGesBrutto + Auf.A.RechPreisW1;
  END;
  Print('AufAArtFuss');
  Sort_KillList(vTree); // Löschen der Liste

  PL_PrintLine; // LEERZEILE

  /*
    EINGANGSRECHNUNGEN
  */
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  vQ560 # '';
  Lib_Sel:QInt(var vQ560, 'ERe.Lieferant', '=', Adr.LieferantenNr);
  if (cDatumVon <> 0.0.0) or (cDatumBis <> today) then
   Lib_Sel:QVonBisD(var vQ560, 'ERe.Rechnungsdatum', cDatumVon, cDatumBis);

  vSel # SelCreate(560, 1);
  Erx # vSel->SelDefQuery('', vQ560);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(560,vSel, _recFirst);
  LOOP Erx # RecRead(560,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    vSortKey # cnvAI(ERe.Nummer, _FmtNumLeadZero, 0, 12)
    Sort_ItemAdd(vTree, vSortKey, 560, RecInfo(560,_RecId));
  END;
  SelClose(vSel);
  SelDelete(560, vSelName);
  vSel # 0;

  vEReGesBrutto   # 0.0;
  vEReGesSteuer   # 0.0;
  vEReGesNetto    # 0.0;
  vEReGesGewicht  # 0.0;

  Print('EReKopf');
  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem <> 0) do begin
    /*
    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    */

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);

    Print('ERePos');

    vEReGesBrutto   # vEReGesBrutto  + ERe.BruttoW1;
    vEReGesSteuer   # vEReGesSteuer  + ERe.SteuerW1;
    vEReGesNetto    # vEReGesNetto   + ERe.NettoW1;
    vEReGesGewicht  # vEReGesGewicht + ERe.Gewicht;
  END;
  Print('EReFuss');

  Sort_KillList(vTree); // Löschen der Liste

  pls_FontSize # vFontSize;
end;

//=========================================================================
//  Verpackungen
//
//=========================================================================
sub Verpackungen()
local begin
  Erx       : int;
  vSel        : int;
  vSelName    : alpha;
  vItem       : int;
  vTree       : int;
  vQ450       : alpha(4000);
  vQ560       : alpha(4000);
  vSortKey    : alpha;
end;
begin

  if(cVerpackungenYN = false) then
    RETURN;

  Lib_Print:Print_FF();

  Print2('VpgKopf');
  FOR   Erx # RecLink(105, 100, 33, _recFirst);
  LOOP  Erx # RecLink(105, 100, 33, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    Erx # RecLink(840, 105, 3, _recFirst); // Etiketten
    if(Erx > _rLocked) then
      RecBufClear(840);

    Erx # RecLink(818, 105, 4, _recFirst); // Verwiegungsart
    if(Erx > _rLocked) then
      RecBufClear(840);

    Erx # RecLink(819, 105, 2, _recFirst); //
    if(Erx > _rLocked) then
      RecBufClear(840);

    Print2('VpgHauptdaten');
    PL_PrintLine;
    Print2('VpgMaterial');
    PL_PrintLine;
    Print2('VpgAnalyse');

    Lib_Print:Print_LinieEinzeln(cPosVpg0, cPosVpg7);
  END;

  Print2('VpgFuss');
/*

 PL_Print('Kreditlimit:',cPos0);
      PL_Print(cnvaf(Adr.K.InternLimit,0,0,2),cTab1b);

      PL_Print('Referenznummer:',cTab2);
      PL_Print(Adr.K.Referenznr,cTab3);
      PL_PrintLine;

*/


end;



//=========================================================================
//  RTFText
//
//=========================================================================
sub RTFText()
local begin
  vTxtName : alpha(1000);
  vTxtHdlTmpRTF : int;
  vTxtHdlTmp1 : int;
  vTxtHdlName : alpha(1000);
end;

begin

  vTxtName # '~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  if (Lib_Texte:RtfTextHatLesbarenText(vTxtName)) then begin
    PL_PrintLine;
    PL_Print('TEXT:',cPos0);
    PL_PrintLine;
    PL_PrintLine;
    Lib_Print:Print_Textbaustein(vTxtName,cPos0,cPos0r);
    PL_PrintLine;
  end;

end;


//=========================================================================
// PrintMain
//        Einstiegspunkt
//=========================================================================
sub PrintMain(opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vDokName    : alpha;
  vDokSprache : alpha;
  vDokAdresse : int;
  vPrintLine  : int;

  vNotFirst   : logic;
  vFirst      : logic;

  vTxtHdl     : handle;
  vLines      : int;
  vLine       : int;
  vFilter     : handle;

  vUmsatzYN   : logic;
end;
begin

  Erx # RecRead(100, 1, 0); // aktuelle Adr. lesen
  if(Erx > _rLocked) then
    RecBufClear(100);


  PL_Create(vPrintLine);

  if (Lib_Print:FrmJobOpen(true, 0, 0, false, true, false) < 0) then begin
    if (vPrintLine <> 0) then PL_Destroy(vPrintLine);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);


  Form_RandOben  # rnd(Lib_Einheiten:LaengenKonv('mm', 'LE', 10.0));
  Form_RandUnten # cnvIF(rnd(Lib_Einheiten:LaengenKonv('mm', 'LE', 10.0)));

  vTopMargin    # form_RandOben;

  Lib_Print:Print_Seitenkopf();

  if(cHauptdatenYN = true) then begin
    Print2('HAUPTDATEN');
    Print2('KREDITVERISCHERUNG');
    Print2('LZB');
    /*
    // >> **** OPTIONAL: Umsatzdaten **** >>
    if (Msg(100013,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      Print('UMSATZDATEN');
    end;
    // << **** OPTIONAL: Umsatzdaten **** <<
  */
    Print2('ANSPRECHPARTNER');
    Print2('LIEFERANSCHRIFTEN');
  end;

  Umsaetze();

  Auftraege();

  Bestellungen();

  Reklamationen();

  OffenePosten();
  FaelligeOffenePosten();
  Verbindlichkeiten();

  Verpackungen();

  RTFText();


  Form_Mode # '';

  /* Druck beenden */
  Usr.Username # UserInfo(_userName, CnvIA(UserInfo(_userCurrent)));
  RecRead(800, 1, 0);
//  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  if (vPrintLine != 0) then
    PL_Destroy(vPrintLine);

end;

//=========================================================================
//=========================================================================