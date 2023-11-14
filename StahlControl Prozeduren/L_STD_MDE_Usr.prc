@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_BAG
//                  OHNE E_R_G
//  Info
//    Druckt kompletten internen Betriebsauftrag aus
//
//
//  09.03.2007  AI  Erstellung der Prozedur
//  21.02.2008  ST  Anpassung Einsatzmaterial
//  15.10.2009  MS  Spulen hinzugefuegt + kein Einsatzmat. mit BruderID
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB PrintFertigung1(aTyp : alpha);
//    SUB PrintFertigung2(aTyp : alpha);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG

define begin
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;
  ABBRUCH(a,b)  : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;

  cLH       : 4.3   // Höhe einer vertikalen Linie (quasi Zeilenhöhe)

  cPosFuss1 : 10.0
  cPosFuss2 : 35.0

  cPosKopf1 : 2.0
  cPosKopf2 : cPosKopf1 + 70.0
  cPosKopf3 : cPosKopf2 + 70.0
  cPosKopf4 : cPosKopf3 + 70.0
  cPosKopf5 : cPosKopf4 + 30.0

  cPosE0   : 2.0            //
  cPosE1   : cPosE0 + 10.0  // Stk
  cPosE2   : cPosE1 + 70.0  // Abmessung
  cPosE3   : cPosE2 + 40.0  // Güte
  cPosE4   : cPosE3 + 20.0  // Matnr
  cPosE5   : cPosE4 + 45.0  // Charge
  cPosE6   : cPosE5 + 20.0  // Gewicht
  cPosE7   : cPosE6 + 20.0  // Gewicht
  cPosE8   : cPosE7 + 10.0  // Teilungen

  cPosFP   : 2.0              //Pos
  cPosF0   : 10.0             //

  //a: Spalten
  cPosF1a   : cPosF0  + 20.0  // Anzahl
  cPosF2a   : cPosF1a + 30.0  // Breite
  cPosF3a   : cPosF2a + 40.0  // Toleranz
  cPosF4a   : cPosF3a + 20.0  // Plan Stk
  cPosF5a   : cPosF4a + 20.0  // Plan Gewicht
  cPosF6a   : cPosF5a + 10.0  // Verpackng
  cPosF7a   : cPosF6a + 35.0  // Weiterverarbeitung
  cPosF8a   : cPosF7a + 35.0  // WV-Maschine

  //b: Tafeln
  cPosF1b   : cPosF0  + 20.0  // Anzahl
  cPosF2b   : cPosF1b + 28.0  // Breite
  cPosF3b   : cPosF2b + 28.0  // Länge
  cPosF4b   : cPosF3b + 35.0  // Breitentoleranz
  cPosF5b   : cPosF4b + 35.0  // Längentoleranz
  cPosF6b   : cPosF5b + 20.0  // Plan Stk
  cPosF7b   : cPosF6b + 20.0  // Plan Gewicht
  cPosF8b   : cPosF7b + 10.0  // Verpackng
  cPosF9b   : cPosF8b + 35.0  // Weiterverarbeitung

  //c: Diverses
  cPosF1c   : cPosF0  + 15.0  // Güte
  cPosF2c   : cPosF1c + 20.0  // Dicke
  cPosF3c   : cPosF2c + 20.0  // Breite
  cPosF4c   : cPosF3c + 20.0  // Länge
  cPosF5c   : cPosF4c + 20.0  // Dickentoleranz
  cPosF6c   : cPosF5c + 20.0  // Breitentoleranz
  cPosF7c   : cPosF6c + 20.0  // Längentoleranz
  cPosF8c   : cPosF7c + 10.0  // RID
  cPosF9c   : cPosF8c + 10.0  // RAD
  cPosF10c  : cPosF9c + 20.0  // Plan Stk
  cPosF11c  : cPosF10c+ 20.0  // Plan Gewicht9
  cPosF12c  : cPosF11c+ 10.0  // Verpackng
  cPosF13c  : cPosF12c+ 35.0  // Weiterverarbeitung

   //d: Fahren
  cPosF1d   : cPosF0  + 40.0  // Zielort
  cPosF2d   : cPosF1d + 20.0  // Plan Stk
  cPosF3d   : cPosF2d + 20.0  // Plan Gewicht
  cPosF4d   : cPosF3d + 10.0  // Verpackng
  cPosF5d   : cPosF4d + 35.0  // Weiterverarbeitung

  //e: Kantenbearbeitung
  cPosF1e   : cPosF0  + 20.0  // Dicke
  cPosF2e   : cPosF1e + 20.0  // Breite
  cPosF3e   : cPosF2e + 30.0  // Dickentoleranz
  cPosF4e   : cPosF3e + 30.0  // Breitentoleranz
  cPosF5e   : cPosF4e + 20.0  // Plan Stk
  cPosF6e   : cPosF5e + 20.0  // Plan Gewicht
  cPosF7e   : cPosF6e + 10.0  // Verpackng
  cPosF8e   : cPosF7e + 35.0  // Weiterverarbeitung

  //f: Oberflächenbearbeitung
  cPosF1f   : cPosF0  + 16.0  // Güte
  cPosF2f   : cPosF1f + 18.0  // Dicke
  cPosF3f   : cPosF2f + 28.0  // Dickentoleranz
  cPosF4f   : cPosF3f + 55.0  // Ausführung Oben
  cPosF5f   : cPosF4f + 55.0  // Ausführung Unten
  cPosF6f   : cPosF5f + 20.0  // Plan Stk
  cPosF7f   : cPosF6f + 20.0  // Plan Gewicht
  cPosF8f   : cPosF7f + 10.0  // Verpackng
  cPosF9f   : cPosF8f + 32.0  // Weiterverarbeitung

  //g: Verpackung

  //h: Qteilen
  cPosF1h   : cPosF0  + 20.0  // Länge
  cPosF2h   : cPosF1h + 30.0  // Längentoleranz
  cPosF3h   : cPosF2h + 20.0  // Plan Stk
  cPosF4h   : cPosF3h + 20.0  // Plan Gewicht
  cPosF5h   : cPosF4h + 10.0  // Verpackng
  cPosF6h   : cPosF5h + 35.0  // Weiterverarbeitung

  //i: Splitten
  cPosF1i   : cPosF0 + 20.0   // Plan Stk
  cPosF2i   : cPosF1i + 20.0  // Plan Gewicht
  cPosF3i   : cPosF2i + 10.0  // Verpackng
  cPosF4i   : cPosF3i + 35.0  // Weiterverarbeitung

  //j: Walzen
  cPosF1j   : cPosF0  + 20.0  // Dicke
  cPosF2j   : cPosF1j + 20.0  // Breite
  cPosF3j   : cPosF2j + 30.0  // Dickentoleranz
  cPosF4j   : cPosF3j + 30.0  // Breitentoleranz
  cPosF5j   : cPosF4j + 50.0  // Ausführung Oben
  cPosF6j   : cPosF5j + 50.0  // Ausführung Unten
  cPosF7j   : cPosF6j + 20.0  // Plan Stk
  cPosF8j   : cPosF7j + 20.0  // Plan Gewicht
  cPosF9j   : cPosF8j + 10.0  // Verpackng
  cPosF10j  : cPosF9j + 35.0  // Weiterverarbeitung

  //k: Abcoilen
  cPosF1k   : cPosF0  + 20.0  // Anzahl
  cPosF2k   : cPosF1k + 36.0  // Breite
  cPosF3k   : cPosF2k + 28.0  // Länge
  cPosF4k   : cPosF3k + 35.0  // Breitentoleranz
  cPosF5k   : cPosF4k + 35.0  // Längentoleranz
  cPosF6k   : cPosF5k + 20.0  // Plan Stk
  cPosF7k   : cPosF6k + 20.0  // Plan Gewicht
  cPosF8k   : cPosF7k + 10.0  // Verpackng
  cPosF9k   : cPosF8k + 35.0  // Weiterverarbeitung

  //s: Spulen
  cPosF1s   : cPosF0    + 20.0  //
  cPosF2s   : cPosF1s   + 20.0  //
  cPosF3s   : cPosF2s   + 20.0  //
  cPosF4s   : cPosF3s   + 20.0  //
  cPosF5s   : cPosF4s   + 20.0  //
  cPosF6s   : cPosF5s   + 20.0  //
  cPosF7s   : cPosF6s   + 20.0  //
  cPosF8s   : cPosF7s   + 10.0  //
  cPosF9s   : cPosF8s   + 35.0  //
  cPosF10s   : cPosF9s  + 35.0  //
  cPosF11s   : cPosF10s + 35.0  //


  cPosV0   : 2.0            //
  cPosV1   : cPosV0 + 10.0  // Verpackung
  cPosV2   : cPosV1 + 250.0 // Text

  cPosTab0  : 2.0
  cPosTab1  : cPosTab0 + 43.0
  cPosTab2  : cPosTab1 + 43.0
  cPosTab3  : cPosTab2 + 43.0
  cPosTab4  : cPosTab3 + 43.0
  cPosTab5  : cPosTab4 + 43.0
  cPosTab6  : cPosTab5 + 43.0

end;

local begin
  vZeilenZahl     : int;
  vCoord          : float;
  vSumStk         : int;
  vSumGewichtN    : float;
  vSumGewichtB    : float;
  vSumMenge       : float;
  vSumBreite      : float;
  vSumLaenge      : float;
  vWtrverb        : alpha;
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
begin
  aAdr      # 0;
  aSprache  # '';
  RETURN CnvAI(BAG.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
//  RETURN CnvAI(BAG.P.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8)+'/'CnvAI(BAG.P.Position,_FmtNumNoGroup | _FmtNumLeadZero,0,3);      // Dokumentennummer
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  Erx       : int;
  vText     : alpha;
  vVerp     : alpha(1000);
  vFlag     : int;
  vMerker   : alpha;
  vPoint    : point;
  vName     : alpha;
  vBuf      : int;
  vBuf2     : int;
end;
begin


end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  Erx       : int;
  vTxtName  : alpha;
  vText     : alpha(250);
  vText2    : alpha(250);
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
  vFirst              : logic;
  vText               : alpha(250);

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPL                 : int;
  vNummer             : int;        // Dokumentennummer
  vTxtHdl             : int;
  vVpg                : logic[100]; // Merker für Verpackungen
  i                   : int;        // für FOR-Schleife
end;
begin
// ------ Druck vorbereiten ----------------------------------------------------------------
  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(true, vHeader ,vFooter, false, false, true) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);
  form_RandOben # 30000.0;      // Rand oben setzen


 
  


// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================
