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
//  PrintFertigung1
//
//========================================================================
sub PrintFertigung1(aTyp : alpha);
local begin
  Erx       : int;
  vEBreite  : float;      // Breite des Einsatzmaterials
  vFBreite  : float;      // Breite des Fertigungsmaterials
  vBesaum   : logic;      // Besäumen oder nicht besäumen
  vBreite   : alpha;      // Text im Kopf für Breite
  vBuf701   : int;
  vBuf702   : int;
end;
begin
case aTyp of

    'Abcoilen_K' : begin
      vBesaum  # n;
      vBreite  # '';
      vEBreite # 0.0;
      vFBreite # 0.0;
      // wenn Einsatzbreiten unterschiedlich, dann besäumen
      Erx # RecLink(701,702,2,_RecFirst);
      WHILE (Erx<=_rLocked) DO BEGIN
        if (BAG.IO.Breite <> vEBreite) and (vEBreite = 0.0) then
          vEBreite # BAG.IO.Breite
        else if (BAG.IO.Breite <> vEBreite) then begin
          vBesaum # y;
          break;
        end;
        Erx # RecLink(701,702,2,_RecNext);
      END;
      // bisher keine unterschiedliche Breiten
      if (vBesaum = n) then begin
        // wenn Fertigungsbreiten unterschiedlich, dann besäumen
        Erx # RecLink(703,702,4,_RecFirst);
        WHILE (Erx<=_rLocked) DO BEGIN
          if (BAG.F.Breite <> vFBreite) and (vFBreite = 0.0) then
            vFBreite # BAG.F.Breite;
          else if (BAG.F.Breite <> vFBreite) then begin
            vBesaum # y;
            break;
          end;
          Erx # RecLink(703,702,4,_RecNext);
        END;
      end;
      // wenn weiterhin keine unterschiedliche Breiten
      // dann überprüfen,ob Einsatzbreite zu Fertigungsbreite unterschiedlich, dann besäumen
      if (vBesaum = n) and (vEBreite <> vFBreite) then vBesaum # y;

      // Text für Breite im Kopf
      if (vBesaum) then vBreite # 'Besäumen auf Breite'
      else vBreite # 'Breite';

      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                            cPosFP+8.0 );
      PL_Print_R('Anzahl',    cPosF1k);
      PL_Print_R(vBreite,       cPosF2k);
      PL_Print_R('Länge',     cPosF3k);
      PL_Print('Breitentoleranz',    cPosF3k + 2.0);
      PL_Print('Längentoleranz',    cPosF4k + 2.0);
      PL_Print_R('Plan Stk',  cPosF6k);
      PL_Print_R('Plan kg',   cPosF7k);
      PL_Print_R('Vpg',       cPosF8k);
      PL_Print_R('Weiterverarbeitung',              cPosF9k);
      PL_Drawbox(cPosFP+1.0, cPosF9k+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Abcoilen' : begin
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                    cPosFP+8.0);
      PL_PrintI(BAG.F.StreifenAnzahl,               cPosF1k);
      PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2k);
      PL_PrintF("BAG.F.Länge", "Set.Stellen.Länge", cPosF3k);
      PL_Print(BAG.F.BreitenTol,                    cPosF3k + 2.0);
      PL_Print("BAG.F.LängenTol",                   cPosF4k + 2.0);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF6k);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF7k);
      PL_PrintI(BAG.F.Verpackung,                   cPosF8k);
      PL_Print_R(vWtrverb,                          cPosF9k);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
      vSumLaenge    # vSumLaenge + (cnvfi("BAG.F.Stückzahl") / cnvfi(BAG.F.Streifenanzahl)*"BAG.F.Länge");
    end;

    'Abcoilen_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF9k+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_PrintF(vSumBreite, Set.Stellen.Breite,   cPosF2k);
      PL_PrintF(vSumLaenge, "Set.Stellen.Länge",   cPosF3k);
      PL_Printi(vSumStk   ,                       cPosF6k);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF7k);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF9k+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1k+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2k+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3k+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4k+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5k+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6k+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF7k+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF8k+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF9k+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

    'Diverses_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                             cPosFP+8.0);
      PL_Print('Güte',                              cPosF0 + 2.0);
      PL_Print_R('Dicke',                           cPosF2c);
      PL_Print_R('Breite',                          cPosF3c);
      PL_Print_R('Länge',                           cPosF4c);
      PL_Print('Dickentol.',                        cPosF4c + 2.0);
      PL_Print('Breitentol.',                       cPosF5c + 2.0);
      PL_Print('Längentol.',                        cPosF6c + 2.0);
      PL_Print_R('RID',                             cPosF8c);
      PL_Print_R('RAD',                             cPosF9c);
      PL_Print_R('Plan Stk',                        cPosF10c);
      PL_Print_R('Plan kg',                         cPosF11c);
      PL_Print_R('Vpg',                             cPosF12c);
      PL_Print_R('Weiterverarbeitung',              cPosF13c);
      PL_Drawbox(cPosFP+1.0, cPosF13c+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Diverses' : begin
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                     cPosFP+8.0);
      PL_Print("BAG.F.Güte",                        cPosF0 + 2.0);
      PL_PrintF(BAG.F.Dicke, Set.Stellen.Dicke,     cPosF2c);
      PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF3c);
      PL_PrintF("BAG.F.Länge", "Set.Stellen.Länge", cPosF4c);
      PL_Print(BAG.F.DickenTol,                     cPosF5c + 2.0);
      PL_Print(BAG.F.BreitenTol,                    cPosF6c + 2.0);
      PL_Print("BAG.F.LängenTol",                   cPosF7c + 2.0);
      PL_PrintF(BAG.F.RID,2,                        cPosF8c);
      PL_PrintF(BAG.F.RAD,2,                        cPosF9c);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF10c);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF11c);
      PL_PrintI(BAG.F.Verpackung,                   cPosF12c);
      PL_Print_R(vWtrverb,                            cPosF13c);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
    end;

    'Diverses_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF13c+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_PrintI(vSumStk   ,                       cPosF10c);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF11c);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF13c+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF7c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF8c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF9c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF10c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF11c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF12c+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF13c+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

    'Fahren_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                            cPosFP+8.0);
      PL_Print('Zielort',    cPosF0 + 2.0);
      PL_Print_R('Plan Stk',  cPosF2d);
      PL_Print_R('Plan kg',   cPosF3d);
      PL_Print_R('Vpg',       cPosF4d);
      PL_Drawbox(cPosFP+1.0, cPosF4d+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Fahren' : begin
      pls_FontSize  # 9;
      RecLink(100,702,12,_recfirst);
      PL_PrintI(BAG.F.Fertigung,                    cPosFP+8.0);
      PL_Print(Adr.Stichwort,                       cPosF0 + 2.0);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF2d);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF3d);
      PL_PrintI(BAG.F.Verpackung,                   cPosF4d);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
    end;

    'Fahren_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF4d+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_Printi(vSumStk   ,                       cPosF2d);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF3d);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF4d+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4d+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

    'Kantenbearbeitung_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                            cPosFP+8.0 );
      PL_Print_R('Dicke',               cPosF1e);
      PL_Print_R('Breite',              cPosF2e);
      PL_Print('Dickentol.',            cPosF2e + 2.0);
      PL_Print('Breitentol.',           cPosF3e + 2.0);
      PL_Print_R('Plan Stk',            cPosF5e);
      PL_Print_R('Plan kg',             cPosF6e);
      PL_Print_R('Vpg',                 cPosF7e);
      PL_Print_R('Weiterverarbeitung',  cPosF8e);
      PL_Drawbox(cPosFP+1.0, cPosF8e+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Kantenbearbeitung' : begin
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                     cPosFP+8.0);
      PL_PrintF(BAG.F.Dicke, Set.Stellen.Dicke,     cPosF1e);
      PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2e);
      PL_Print(BAG.F.DickenTol,                     cPosF2e + 2.0);
      PL_Print(BAG.F.BreitenTol,                    cPosF3e + 2.0);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF5e);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF6e);
      PL_PrintI(BAG.F.Verpackung,                   cPosF7e);
      PL_Print_R(vWtrverb,                            cPosF8e);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
    end;

    'Kantenbearbeitung_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF8e+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_Printi(vSumStk   ,                       cPosF5e);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF6e);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF8e+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1e+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2e+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3e+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4e+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5e+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6e+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF7e+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF8e+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

    'Oberfächenbearbeitung_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                            cPosFP+8.0 );
      PL_Print('Güte',             cPosF0 + 2.0);
      PL_Print_R('Dicke',          cPosF2f);
      PL_Print('Dickentoleranz',   cPosF2f + 2.0);
      PL_Print('Ausführung Oben',  cPosF3f + 2.0);
      PL_Print('Ausführung Unten', cPosF4f + 2.0);
      PL_Print_R('Plan Stk',       cPosF6f);
      PL_Print_R('Plan kg',        cPosF7f);
      PL_Print_R('Vpg',            cPosF8f);
      PL_Print_R('Weiterverarbeitung',              cPosF9f);
      PL_Drawbox(cPosFP+1.0, cPosF9f+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Oberfächenbearbeitung' : begin
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                     cPosFP+8.0);
      PL_Print("BAG.F.Güte",                        cPosF0 + 2.0);
      PL_PrintF(BAG.F.Dicke, Set.Stellen.Dicke,     cPosF2f);
      PL_Print(BAG.F.DickenTol,                     cPosF2f + 2.0);
      PL_Print(BAG.F.AusfOben,                      cPosF3f + 2.0);
      PL_Print(BAG.F.AusfOben,                      cPosF4f + 2.0);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF6f);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF7f);
      PL_PrintI(BAG.F.Verpackung,                   cPosF8f);
      PL_Print_R(vWtrverb,                            cPosF9f);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
    end;

    'Oberfächenbearbeitung_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF9f+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_PrintI(vSumStk   ,                       cPosF6f);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF7f);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF9f+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0 +1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1f+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2f+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3f+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4f+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5f+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6f+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF7f+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF8f+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF9f+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

    'Verpacken_K' : begin
      pls_FontSize  # 10;
      PL_Print('Verpacken',cPosFP);
      vZeilenZahl # 0;
    end;

    'Verpacken' : begin

    end;

    'Verpacken_F' : begin

    end;

    'Querteilen_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                            cPosFP+8.0 );
      PL_Print_R('Länge',       cPosF1h);
      PL_Print('Längentoleranz',cPosF1h + 2.0);
      PL_Print_R('Plan Stk',    cPosF3h);
      PL_Print_R('Plan kg',     cPosF4h);
      PL_Print_R('Vpg',         cPosF5h);
      PL_Print_R('Weiterverarbeitung',              cPosF6h);
      PL_Drawbox(cPosFP+1.0, cPosF6h+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Querteilen' : begin
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                     cPosFP+8.0);
      PL_PrintF("BAG.F.Länge", "Set.Stellen.Länge", cPosF1h);
      PL_Print("BAG.F.LängenTol",                   cPosF1h + 2.0);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF3h);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF4h);
      PL_PrintI(BAG.F.Verpackung,                   cPosF5h);
      PL_Print_R(vWtrverb,                            cPosF6h);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
    end;

    'Querteilen_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF6h+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_Printi(vSumStk   ,                       cPosF3h);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF4h);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF6h+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1h+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2h+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3h+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4h+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5h+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6h+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

    'Spalten_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                            cPosFP+8.0 );
      PL_Print_R('Anzahl',    cPosF1a);
      PL_Print_R('Breite',    cPosF2a);
      PL_Print('Toleranz',    cPosF2a + 2.0);
      PL_Print_R('Plan Stk',  cPosF4a);
      PL_Print_R('Plan kg',   cPosF5a);
      PL_Print_R('Vpg',       cPosF6a);
      PL_Print_R('Komm. Nr.',              cPosF7a);
      PL_Print_R('WV-Maschine',              cPosF8a);
      PL_Drawbox(cPosFP+1.0, cPosF8a+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Spalten' : begin
      vBuf701 # RekSave(701);
      vBuf702 # RekSave(702);
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                     cPosFP+8.0);
      PL_PrintI(BAG.F.StreifenAnzahl,               cPosF1a);
      PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2a);
      PL_Print(BAG.F.BreitenTol,                    cPosF2a + 2.0);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF4a);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.GEwicht, cPosF5a);
      PL_PrintI(BAG.F.Verpackung,                   cPosF6a);
      if(BAG.P.Kommission != '') then begin
        PL_Print_R(BAG.P.Kommission,                          cPosF7a);
      end;

      Erx # RecLink(701, 703, 4, _recFirst); // OUTPUT lesen
      if(Erx > _rLocked) then
        RecBufClear(701);
      Erx # RecLink(702, 701, 4, _recFirst); // naechsten AG lesen
      if(Erx > _rLocked) then
        RecBufClear(702);
/*
Rso.Grp.Nummer # BAG.P.Ressource.Grp;
Erx # RecRead(822, 1, 0);
if(Erx > _rLocked) then
  RecBufClear(822);
PL_Print_R(Rso.Grp.Bezeichnung,                          cPosF8a);
*/
      Rso.Gruppe # BAG.P.Ressource.Grp;
      Rso.Nummer # BAG.P.Ressource;
      Erx # RecRead(160, 1, 0); // Ressource
      if(Erx > _rLocked) then
        RecBufClear(160);
      PL_Print_R(Rso.Stichwort,                          cPosF8a);

      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;

      RekRestore(vBuf701);
      RekRestore(vBuf702);
    end;

    'Spalten_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF8a + 1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_PrintF(vSumBreite, Set.Stellen.Breite,   cPosF2a);
      PL_Printi(vSumStk   ,                       cPosF4a);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF5a);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF8a +1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1a+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2a+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3a-1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4a+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5a+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6a+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF7a+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF8a+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;
  end;
end

//========================================================================
//  PrintFertigung2
//
//========================================================================
sub PrintFertigung2(aTyp : alpha);
local begin
  Erx       : int;
  vEBreite  : float;      // Breite des Einsatzmaterials
  vFBreite  : float;      // Breite des Fertigungsmaterials
  vBesaum   : logic;      // Besäumen oder nicht besäumen
  vBreite   : alpha;      // Text im Kopf für Breite
  vBuf701   : int;
  vBuf702   : int;
end;
begin
  case aTyp of

    'Spulen_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',             cPosFP+8.0 );
      PL_Print_R('Dicke',    cPosF1s);
      PL_Print_R('Breite',    cPosF2s);
      PL_Print_R('Plan Stk',  cPosF3s);
      PL_Print_R('Plan kg',   cPosF4s);
      PL_Print_R('Einzel kg',   cPosF5s);
      PL_Print_R('Plan m',  cPosF6s);
      PL_Print_R('Einzel m' ,  cPosF7s);
      PL_Print_R('Vpg',       cPosF8s);
      PL_Print_R('Komm. Nr.',     cPosF9s);
      PL_Print_R('WV-Maschine',              cPosF10s);
      PL_Drawbox(cPosFP+1.0, cPosF10s + 1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Spulen' : begin
      vBuf701 # RekSave(701);
      vBuf702 # RekSave(702);
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                     cPosFP+8.0);
      PL_PrintF(BAG.F.Dicke, Set.Stellen.Dicke,   cPosF1s);
      PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2s);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF3s);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.GEwicht, cPosF4s);
      PL_PrintF(BAG.F.Gewicht / cnvFI("BAG.F.Stückzahl"), Set.Stellen.Menge, cPosF5s);
      PL_PrintF(BAG.F.Menge, Set.Stellen.Menge, cPosF6s);
      PL_PrintF(BAG.F.Menge / cnvFI("BAG.F.Stückzahl"), Set.Stellen.Menge, cPosF7s);

      PL_PrintI(BAG.F.Verpackung,                   cPosF8s);
      if(BAG.P.Kommission != '') then begin
        PL_Print_R(BAG.P.Kommission,                          cPosF9s);
      end;

      Erx # RecLink(701, 703, 4, _recFirst); // OUTPUT lesen
      if(Erx > _rLocked) then
        RecBufClear(701);
      Erx # RecLink(702, 701, 4, _recFirst); // naechsten AG lesen
      if(Erx > _rLocked) then
        RecBufClear(702);
/*
Rso.Grp.Nummer # BAG.P.Ressource.Grp;
Erx # RecRead(822, 1, 0);
if(Erx > _rLocked) then
  RecBufClear(822);
PL_Print_R(Rso.Grp.Bezeichnung,                          cPosF8s);
*/
      Rso.Gruppe # BAG.P.Ressource.Grp;
      Rso.Nummer # BAG.P.Ressource;
      Erx # RecRead(160, 1, 0); // Ressource
      if(Erx > _rLocked) then
        RecBufClear(160);
      PL_Print_R(Rso.Stichwort,                          cPosF10s);

      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;

      RekRestore(vBuf701);
      RekRestore(vBuf702);
    end;

    'Spulen_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF10s + 1.0);
      pls_Fontattr # _WinFontAttrBold;

      //PL_PrintF(vSumBreite, Set.Stellen.Breite,   cPosF3s);
      PL_Printi(vSumStk   ,                       cPosF3s);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF4s);
      PL_PrintF(vSumMenge,Set.Stellen.Menge, cPosF5s);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF10s +1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1s+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2s+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3s+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4s+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5s+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6s+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF7s+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF8s+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF9s+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF10s+1.0, cLH * cnvfi(vZeilenZahl+1));
    end

    'Splitten_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                            cPosFP+8.0 );
      PL_Print_R('Plan Stk',  cPosF1i);
      PL_Print_R('Plan kg',   cPosF2i);
      PL_Print_R('Vpg',       cPosF3i);
      PL_Print_R('Weiterverarbeitung',              cPosF4i);
      PL_Drawbox(cPosFP+1.0, cPosF4i+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Splitten' : begin
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                     cPosFP+8.0);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF1i);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF2i);
      PL_PrintI(BAG.F.Verpackung,                   cPosF3i);
      PL_Print_R(vWtrverb,                            cPosF4i);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
    end;

    'Splitten_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF4i+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_Printi(vSumStk   ,                       cPosF2i);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF3i);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF4i+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1i+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2i+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3i+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4i+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

    'Tafeln_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                            cPosFP+8.0 );
      PL_Print_R('Fertigung',    cPosF1b); // soll Fertigung! zB. A1 ...
      PL_Print_R('Breite',    cPosF2b);
      PL_Print_R('Länge',    cPosF3b);
      PL_Print('Breitentoleranz',    cPosF3b + 2.0);
      PL_Print('Längentoleranz',    cPosF4b + 2.0);
      PL_Print_R('Plan Stk',  cPosF6b);
      PL_Print_R('Plan kg',   cPosF7b);
      PL_Print_R('Vpg',       cPosF8b);
      PL_Print_R('Weiterverarbeitung',              cPosF9b);
      PL_Drawbox(cPosFP+1.0, cPosF9b+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Tafeln' : begin
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                    cPosFP+8.0);
      PL_Print_R(BAG.F.Block + AInt(BAG.F.StreifenAnzahl), cPosF1b);
      PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2b);
      PL_PrintF("BAG.F.Länge", "Set.Stellen.Länge", cPosF3b);
      PL_Print(BAG.F.BreitenTol,                    cPosF3b + 2.0);
      PL_Print("BAG.F.LängenTol",                   cPosF4b + 2.0);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF6b);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF7b);
      PL_PrintI(BAG.F.Verpackung,                   cPosF8b);
      PL_Print_R(vWtrverb,                          cPosF9b);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
      vSumLaenge    # vSumLaenge + (cnvfi("BAG.F.Stückzahl") / cnvfi(BAG.F.Streifenanzahl)*"BAG.F.Länge");
    end;

    'Tafeln_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF9b+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_PrintF(vSumBreite, Set.Stellen.Breite,   cPosF2b);
      PL_PrintF(vSumLaenge, "Set.Stellen.Länge",   cPosF3b);
      PL_Printi(vSumStk   ,                       cPosF6b);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF7b);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF9b+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF7b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF8b+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF9b+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

    'Test/Prüfen_K' : begin
      pls_FontSize  # 10;
      PL_Print('Prüfen',cPosFP);
      PL_PrintLine;
      vZeilenZahl # 0;
    end;

    'Test/Prüfen' : begin

    end;

    'Test/Prüfen_F' : begin

    end;

    'Walzen_K' : begin
      pls_FontSize  # 10;
      PL_Print('Fertigung je Coil',cPosFP);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Pos',                            cPosFP+8.0 );
      PL_Print_R('Dicke',    cPosF1j);
      PL_Print_R('Breite',    cPosF2j);
      PL_Print('Dickentoleranz',    cPosF2j + 2.0);
      PL_Print('Breitentoleranz',    cPosF3j + 2.0);
      PL_Print('Ausf. Oben',    cPosF4j + 2.0);
      PL_Print('Ausf. Unten',    cPosF5j + 2.0);
      PL_Print_R('Plan Stk',  cPosF7j);
      PL_Print_R('Plan kg',   cPosF8j);
      PL_Print_R('Vpg',       cPosF9j);
      PL_Print_R('Weiterverarbeitung',              cPosF10j);
      PL_Drawbox(cPosFP+1.0, cPosF10j+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;

    'Walzen' : begin
      pls_FontSize  # 9;
      PL_PrintI(BAG.F.Fertigung,                     cPosFP+8.0);
      PL_PrintF(BAG.F.Dicke,  Set.Stellen.Dicke,    cPosF1j);
      PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2j);
      PL_Print(BAG.F.DickenTol,                     cPosF2j + 2.0);
      PL_Print("BAG.F.BreitenTol",                   cPosF3j + 2.0);
      PL_Print(BAG.F.AusfOben,                      cPosF4f + 2.0);
      PL_Print(BAG.F.AusfOben,                      cPosF5f + 2.0);
      PL_PrintI("BAG.F.Stückzahl",                  cPosF7j);
      PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF8j);
      PL_PrintI(BAG.F.Verpackung,                   cPosF9j);
      PL_Print_R(vWtrverb,                            cPosF10j);
      PL_PrintLine;
      vZeilenZahl # vZeilenZahl + 1;
    end;

    'Walzen_F' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF10j+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_Printi(vSumStk   ,                       cPosF7j);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF8j);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosFP+1.0,cPosF10j+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosFP+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF1j+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF2j+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF3j+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF4j+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF5j+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF6j+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF7j+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF8j+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF9j+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosF10j+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;
  end;
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

  case BAG.P.Aktion of  // siehe Def_BAG
    c_BAG_Divers  : vName # 'Diverses';
    c_BAG_Fahr    : vName # 'Fahren';
    c_BAG_Kant    : vName # 'Kantenbearbeitung';
    c_BAG_Obf     : vName # 'Oberfächenbearbeitung';
    c_BAG_Pack    : vName # 'Verpacken';
    c_BAG_QTeil   : vName # 'Querteilen';
    c_BAG_Spalt   : vName # 'Spalten';
    c_BAG_Split   : vName # 'Splitten';
    c_BAG_Tafel   : vName # 'Tafeln';
    c_BAG_ABCOIL  : vName # 'Abcoilen';
    c_BAG_Check   : vName # 'Prüfen';
    c_BAG_VSB     : vName # 'VSB/Lager';
    c_BAG_Walz    : vName # 'Walzen';
    c_BAG_Spulen  : vName # 'Spulen';
    c_BAG_SpaltSpulen  : vName # 'Spalt-Spulen';
  end;


  if (aTyp='Fertigungkopf') then
   if vName < 'Splitten' then
     PrintFertigung1(vName+'_K');
   else
     PrintFertigung2(vName+'_K');

  if (aTyp='Fertigung') then begin

      vBuf  # rekSave(701);
      vBuf2 # rekSave(702);
      Erx # Reclink(701,703,4,_recfirst); // Fertigung -> IO
      Erx # RecLink(702, 701, 4, _recFirst); // IO -> Position
      if(BAG.P.Aktion = c_BAG_VSB) then begin
        if(BAG.P.Kommission <> '') then
          vWtrverb # BAG.P.Kommission;
        else
          vWtrverb #  'Lager';
      end
      else
        vWtrverb # AInt(BAG.IO.nachBAG) + '/' + AInt(BAG.IO.nachPosition);
      if (vWtrverb = '0/0') then
        vWtrverb # '';
      RekRestore(vBuf);
      RekRestore(vBuf2);



  if vName < 'Splitten' then
     PrintFertigung1(vName+'');
   else
     PrintFertigung2(vName+'');
  end

  if (aTyp='Fertigungfuss') then
   if vName < 'Splitten' then
     PrintFertigung1(vName+'_F');
   else
     PrintFertigung2(vName+'_F');



  case aTyp of

    'Einsatzkopf' : begin
      pls_FontSize  # 10;
      PL_Print('Einsatzmaterial',cPosE0);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Stk',            cPosE1);
      PL_Print('Abmessung',        cPosE1 + 2.0);
      PL_Print('Qualität',         cPosE2);
      PL_Print_R('Mat.Nr.',        cPosE4);
      PL_Print('Coilnummer / BA',       cPosE4 + 2.0);
      PL_Print_R('Gew. Brutto', cPosE6);
      PL_Print_R('Gew. Netto',  cPosE7);
      PL_Print_R('Tlg',            cPosE8);
      PL_Drawbox(cPosE0+1.0, cPosE8+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
    end;


    'Einsatz' : begin
      pls_FontSize  # 9;
      PL_PrintI(Mat.Bestand.Stk,  cPosE1);
      // Abmessung
      vText # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' +
           ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' +
                     ANum("Mat.Länge","Set.Stellen.Länge");
      PL_Print(vText + ' mm', cPosE1 + 2.0);

      // Güte
      vText # StrAdj("Mat.Güte",_StrEnd);
      if ("Mat.Gütenstufe" <> '') then
        vText # vText +  ' / ' + StrAdj("Mat.Gütenstufe",_StrEnd);
      PL_Print(vText,cPosE2);

      PL_PrintI(Mat.Nummer,                               cPosE4);
      if(vWtrverb <> '') then
        vWtrverb # StrIns(vWtrverb, ' aus ', 0);
      PL_Print(Mat.Coilnummer + vWtrverb ,                            cPosE4 + 2.0);
      PL_PrintF(Mat.Gewicht.Brutto, Set.Stellen.Gewicht,  cPosE6);
      PL_PrintF(Mat.Gewicht.Netto, Set.Stellen.Gewicht,   cPosE7);
      PL_PrintI(BAG.IO.Teilungen,cPosE8);
      PL_Printline;
      vZeilenZahl # vZeilenZahl + 1;


    end; // EO Einsatz


    'Weiterbearb.-Einsatz' : begin
/*  DEAKTIVIERT ST, -> macht keinen Sinn
      vBuf # rekSave(701);
      reclink(701,703,3,_recfirst);
      vWtrverb # cnvai(bag.io.vonBAG) + '/' + cnvai(bag.io.vonPosition) + '/' + cnvai(bag.io.vonFertigung);
      RekRestore(vBuf);
*/
      vWtrverb # cnvai(bag.io.vonBAG) + '/' + cnvai(bag.io.vonPosition) + '/' + cnvai(bag.io.vonFertigung);

      pls_FontSize  # 9;

      PL_PrintI(BAG.IO.Plan.In.Stk,  cPosE1);
      // Abmessung
      vText # ANum(BAG.IO.Dicke,Set.Stellen.Dicke) + ' x ' +
           ANum(BAG.IO.Breite,Set.Stellen.Breite);
      if ("BAG.IO.Länge" <> 0.0) then
        vText # vText + ' x ' +
                     ANum("BAG.IO.Länge","Set.Stellen.Länge");
      PL_Print(vText + ' mm', cPosE1 + 2.0);

      // Güte
      vText # StrAdj("BAG.IO.Güte",_StrEnd);
      PL_Print(vText,cPosE2);
      //PL_PrintI(Mat.Nummer,                               cPosE4);
      Lib_PrintLine:Print('aus' + ' ' + vWtrverb ,                            cPosE4 + 2.0);
      PL_PrintF(BAG.IO.Plan.In.GewB, Set.Stellen.Gewicht,  cPosE6);
      PL_PrintF(BAG.IO.Plan.In.GewN, Set.Stellen.Gewicht,   cPosE7);
      PL_PrintI(BAG.IO.Teilungen,cPosE8);
      PL_Printline;
      vZeilenZahl # vZeilenZahl + 1;

    end;

    'Einsatzfuss' : begin
      pls_FontSize  # 9;
      Lib_Print:Print_LinieEinzeln(cPosE0+1.0,cPosE8+1.0);
      pls_Fontattr # _WinFontAttrBold;
      PL_PrintI(vSumStk,cPosE1);
      PL_PrintF(vSumGewichtB, Set.Stellen.Gewicht, cPosE6);
      PL_PrintF(vSumGewichtN, Set.Stellen.Gewicht, cPosE7);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosE0+1.0,cPosE8+1.0);
      pls_Fontattr # 0;

      Lib_Print:Print_LinieVEinzeln(cPosE0+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE1+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE2-1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE3+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE4+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE5+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE6+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE7+1.0, cLH * cnvfi(vZeilenZahl+1));
      Lib_Print:Print_LinieVEinzeln(cPosE8+1.0, cLH * cnvfi(vZeilenZahl+1));
    end;

    'Verpackungkopf' : begin
      pls_FontSize  # 10;
      PL_Print('Verpackung',cPosE0);
      PL_PrintLine;
      pls_FontSize  # 9;
      pls_Inverted  # y;
      PL_Print_R('Nr.',         cPosV1);
      PL_Print('Bescheibung',   cPosV1 + 2.0);
      PL_Drawbox(cPosV0+1.0,    cPosV2+1.5,_WinColblack, 4.5);
      PL_PrintLine;
      pls_Inverted  # n;
      vZeilenZahl # 0;
      vPoint # form_Page->ppBoundAdd;
      vCoord # PrtUnit(vPoint:Y, _PrtUnitMillimetres);
//      PrtUnitLog(aYY,_PrtUnitMillimetres);
  //vY # vUsed:y - PrtUnitLog(aYY,_PrtUnitMillimetres);
    end;

    'Verpackung' : begin
      pls_FontSize  # 9;
      PL_PrintI(BAG.Vpg.Verpackung,               cPosV1);

      //--------------------ANFANG VERpackung--------------------------
      vVerp # '';

      if (BAG.Vpg.StehendYN) then
        ADD_VERP('stehend','');

      if (BAG.Vpg.LiegendYN) then
        ADD_VERP('liegend','');

      //Abbindung
      if (BAG.Vpg.AbbindungQ <> 0 or BAG.Vpg.AbbindungL <> 0) then begin
        //Quer
        if(BAG.Vpg.AbbindungQ<>0)then vMerker # 'Abbindung '+ AInt(BAG.Vpg.AbbindungQ)+' x quer' ;
        //Längs
        if(BAG.Vpg.AbbindungL<>0)then begin
          if (vMerker<>'')then
            vMerker # vMerker+'  '+AInt(BAG.Vpg.AbbindungL)+ ' x längs';
          else
            vMerker # 'Abbindung ' + AInt(BAG.Vpg.AbbindungL)+' x längs';
        end;
       ADD_VERP(vMerker,'')
      end;

      if (BAG.Vpg.Zwischenlage <> '') then
        //'Zwischenlage: ',
        ADD_VERP(BAG.Vpg.Zwischenlage,'');

      if (BAG.Vpg.Unterlage <> '') then
        //'Unterlage: ',
        ADD_VERP(BAG.Vpg.Unterlage,'');

      if (BAG.Vpg.Nettoabzug > 0.0) then
        ADD_VERP('Nettoabzug: '+AInt(CnvIF(BAG.Vpg.Nettoabzug))+' kg','');

      if ("BAG.Vpg.Stapelhöhe" > 0.0) then
        ADD_VERP('max. Stapelhöhe: ',AInt(CnvIF("BAG.Vpg.Stapelhöhe"))+' mm');

      if (BAG.Vpg.StapelHAbzug > 0.0) then
        ADD_VERP('Stapelhöhenabzug: ',AInt(CnvIF("BAG.Vpg.StapelhAbzug"))+' mm');
      //Ringgewicht
      if (BAG.Vpg.RingKgVon + BAG.Vpg.RingKgBis  <> 0.0) then begin
        if (BAG.Vpg.RingKgVon <> 0.0 and BAG.Vpg.RingKgBis <> 0.0) then
          vMerker # 'Ringgew.: min. ' + AInt(CnvIF(BAG.Vpg.RingKgVon)) + ' kg  max. ' + AInt(CnvIF(BAG.Vpg.RingKgBis));
        if (BAG.Vpg.RingKgVon <> 0.0 and BAG.Vpg.RingKgBis = 0.0) then
          vMerker # 'Ringgew.: ' + AInt(CnvIF(BAG.Vpg.RingKgVon));
        if (BAG.Vpg.RingKgVon = 0.0 and BAG.Vpg.RingKgBis <> 0.0) then
          vMerker # 'Ringgew.: max. ' + AInt(CnvIF(BAG.Vpg.RingKgBis));
        if (BAG.Vpg.RingKgVon = BAG.Vpg.RingKgBis) then
          vMerker # 'Ringgew.: ' + AInt(CnvIF(BAG.Vpg.RingKgBis));
        vMerker#vMerker+' kg';
        ADD_VERP(vMerker,'')
      end;

      //kg/mm
      if (BAG.Vpg.KgmmVon + BAG.Vpg.KgmmBis  <> 0.0) then begin
        if (BAG.Vpg.KgmmVon <> 0.0 and BAG.Vpg.KgmmBis <> 0.0) then
          vMerker # 'Kg/mm: min. ' + CnvAF(BAG.Vpg.KgmmVon) + ' max. ' + CnvAF(BAG.Vpg.KgmmBis)
        if (BAG.Vpg.KgmmVon <> 0.0 and BAG.Vpg.KgmmBis = 0.0) then
          vMerker # 'Kg/mm: min. ' + CnvAF(BAG.Vpg.KgmmVon)
        if (BAG.Vpg.KgmmVon = 0.0 and BAG.Vpg.KgmmBis <> 0.0) then
          vMerker # 'Kg/mm: max. ' + CnvAF(BAG.Vpg.KgmmBis)
        if (BAG.Vpg.KgmmVon = BAG.Vpg.KgmmBis) then
          vMerker # 'Kg/mm: ' + CnvAF(BAG.Vpg.KgmmBis)
        ADD_VERP(vMerker,'')
      end;

      if ("BAG.Vpg.StückProVE" > 0) then
        ADD_VERP(AInt("BAG.Vpg.StückProVE") + ' Stück pro VE', '');

      if (BAG.Vpg.VEkgMax > 0.0) then
        ADD_VERP('max. kg pro VE: ',AInt(CnvIF(BAG.Vpg.VEkgMax)));

      if (BAG.Vpg.RechtwinkMax > 0.0) then
        ADD_VERP('max. Rechtwinkligkeit: ', CnvAf(BAG.Vpg.RechtwinkMax));

      if (BAG.Vpg.EbenheitMax > 0.0) then
        ADD_VERP('max. Ebenheit: ', CnvAf(BAG.Vpg.EbenheitMax));

      if ("BAG.Vpg.SäbeligMax" > 0.0) then
        ADD_VERP('max. Säbeligkeit: ', CnvAf("BAG.Vpg.SäbeligMax"));

      if (BAG.Vpg.Etikettentyp<>0)then begin
        vFlag # _RecFirst;
        WHILE (RecRead(840,1,vFlag) <= _rLocked ) DO BEGIN
          vFlag # _RecNext;
          if (Eti.Nummer = BAG.Vpg.Etikettentyp) then begin
            ADD_VERP('Etikettentyp: ',Eti.Bezeichnung);
          end;
        END;
      end;
      if (BAG.Vpg.Verwiegart<>0)then begin
        vFlag # _RecFirst;
        WHILE (RecRead(818,1,vFlag) <= _rLocked ) DO BEGIN
          vFlag # _RecNext;
          if (VwA.Nummer = BAG.Vpg.Verwiegart) then begin
            ADD_VERP('Verwiegungsart: ',VwA.Bezeichnung.L1);
          end;
        END;
      end;

      PL_Print(vVerp,cPosV1+ 2.0,cPosV2);
      PL_Printline;
      vZeilenZahl # vZeilenZahl + 1;

      if (BAG.Vpg.VpgText1 <> '') then begin
        PL_Print(BAG.Vpg.VpgText1,cPosV1+ 2.0);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText2 <> '') then begin
        PL_Print(BAG.Vpg.VpgText2,cPosV1+ 2.0);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText3 <> '') then begin
        PL_Print(BAG.Vpg.VpgText3,cPosV1+ 2.0);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText4 <> '') then begin
        PL_Print(BAG.Vpg.VpgText4,cPosV1+ 2.0);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText5 <> '') then begin
        PL_Print(BAG.Vpg.VpgText5,cPosV1+ 2.0);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText6 <> '') then begin
        PL_Print(BAG.Vpg.VpgText6,cPosV1+ 2.0);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      //--------------------------ENDE Verpackung--------------------
      pls_FontSize  # 9;
    end;

    'Verpackungfuss' : begin
      Lib_Print:Print_LinieEinzeln(cPosV0+1.0,cPosV2+1.0);
      pls_Fontattr # 0;

      vPoint # form_Page->ppBoundAdd;
      vCoord # PrtUnit(vPoint:Y, _PrtUnitMillimetres) - vCoord;
      Lib_Print:Print_LinieVEinzeln(cPosV0+1.0, vCoord);
      Lib_Print:Print_LinieVEinzeln(cPosV1+1.0, vCoord);
      Lib_Print:Print_LinieVEinzeln(cPosV2+1.0, vCoord);
    end;

    'Tabelle' : begin
      vPoint # form_Page->ppBoundAdd;
      vCoord # PrtUnit(vPoint:Y, _PrtUnitMillimetres);
      Lib_Print:Print_LinieEinzeln(cPosTab0+1.0,cPosTab6+1.0);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosTab0+1.0,cPosTab6+1.0);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosTab0+1.0,cPosTab6+1.0);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosTab0+1.0,cPosTab6+1.0);
      PL_Printline;
      Lib_Print:Print_LinieEinzeln(cPosTab0+1.0,cPosTab6+1.0);

      vPoint # form_Page->ppBoundAdd;
      vCoord # PrtUnit(vPoint:Y, _PrtUnitMillimetres) - vCoord;
      Lib_Print:Print_LinieVEinzeln(cPosTab0+1.0, vCoord);
      Lib_Print:Print_LinieVEinzeln(cPosTab1+1.0, vCoord);
      Lib_Print:Print_LinieVEinzeln(cPosTab2+1.0, vCoord);
      Lib_Print:Print_LinieVEinzeln(cPosTab3+1.0, vCoord);
      Lib_Print:Print_LinieVEinzeln(cPosTab4+1.0, vCoord);
      Lib_Print:Print_LinieVEinzeln(cPosTab5+1.0, vCoord);
      Lib_Print:Print_LinieVEinzeln(cPosTab6+1.0, vCoord);
    end;

    'Kopftext' : begin
      vText # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.K';
      Lib_Print:Print_Text(vText,1, cPosKopf1);
    end;

    'Fusstext' : begin
      vText # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.F';
      Lib_Print:Print_Text(vText,1, cPosKopf1);
    end;

  end;
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

  Erx # RecLink(160,702,11,_RecFirst);      // Hauptressource holen
  if (Erx>_rLocked) then RecBufClear(160);

  Pls_fontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('BETRIEBSAUFTRAG '+AInt(BAg.P.Nummer)+'/'+AInt(BAG.P.Position) ,cPosKopf1);
  PL_Print(BAG.P.Bezeichnung,cPosKopf2);
  PL_Print('auf Maschine '+AInt(Rso.Nummer)+' '+Rso.Stichwort,cPosKopf3);
  PL_Print('Seite:'+AInt(aSeite),cPosKopf4);

  // ST 2008-05-13
  // Anpassung Barcode für Eingabemaske Betrieb
  // lib_PrintLine:BarCode( (BAG.P.Nummer*100) + BAG.P.Position, cPosKopf5,35.0,7.0);
  // Barcode (Code39) für Schrägstrich
  vText # 'Code39N'+StrAdj(CnvAi(Bag.P.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_StrAll) + '/' +
                    StrAdj(CnvAi(BAG.P.Position,_FmtNumNoZero | _FmtNumNoGroup,0,2),_StrAll);
  lib_PrintLine:BarCode_C39(vText,cPosKopf5,35.0,7.0);

  PL_PrintLine;
  pls_Fontattr # 0;

  Pls_FontSize # 9;
  PL_PrintLine;

  PL_Print('Starttermin : '+cnvad(BAG.P.Plan.StartDat)+' '+cnvat(BAG.P.Plan.StartZeit)+' '+BAG.P.Plan.StartInfo, cPosKopf1);
  PL_Print('Endtermin : '+cnvad(BAG.P.Plan.EndDat)+' '+cnvat(BAG.P.Plan.EndZeit)+' '+BAG.P.Plan.EndInfo, cPosKopf3);
  PL_PrintLine;

  PL_PrintLine;

  if (Form_Mode='EINSATZ') then     Print('Einsatzkopf');
  if (Form_Mode='FERTIGUNG') then   Print('Fertigungkopf');
  if (Form_Mode='VERPACKUNG') then  Print('Verpackungkopf');

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


  // LOOP **********************************************************
  Erx # RecLink(702,700,1,_recFirst);       // Positionen loopen
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.ExternYN) then begin          // externe überspringen
      Erx # RecLink(702,700,1,_recNext);
      CYCLE;
    end;
    if (BAG.P.Aktion=c_BAG_VSB) then begin  // VSBs überspringen
      Erx # RecLink(702,700,1,_recNext);
      CYCLE;
    end;

    // ------- KOPFDATEN -----------------------------------------------------------------------
    form_Mode # 'EINSATZ';
    if (vFirst=n) then begin
      vFirst # Y;
      Lib_Print:Print_Seitenkopf();
      end
    else begin
      Lib_Print:Print_FF();     // Seitenvorschub auf folgenden Seiten
    end;

    // ------- EINSATZMATERIAL -----------------------------------------------------------------
    // Einsatzsummen bei jedem Arbeitsgang seperat summieren
    vSumStk         # 0;
    vSumGewichtN    # 0.0;
    vSumGewichtB    # 0.0;


    Erx # RecLink(701,702,2,_RecFirst);
    WHILE (Erx<=_rLocked) DO BEGIN
      // ECHTES Material?
      if(BAG.IO.BruderID = 0) then begin // keine Brueder drucken
        if (BAG.IO.Materialtyp=c_IO_Mat) then begin
          // Material lesen
          Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
          Print('Einsatz');
          // Summierung
          vSumStk         # vSumStk + Mat.Bestand.Stk;
          vSumGewichtN    # vSumGewichtN + Mat.Gewicht.Netto;
          vSumGewichtB    # vSumGewichtB + Mat.Gewicht.Brutto;
          end
        else
        if (BAG.IO.Materialtyp=c_IO_BAG) then begin

            Print('Weiterbearb.-Einsatz');

            // Summierung
            vSumStk         # vSumStk +      BAG.IO.Plan.In.Stk;
            vSumGewichtN    # vSumGewichtN + BAG.IO.Plan.In.GewN;
            vSumGewichtB    # vSumGewichtB + BAG.IO.Plan.In.GewB;
        end;
      end;

      Erx # RecLink(701,702,2,_RecNext);
    END;
    Print('Einsatzfuss');
    PL_PrintLine;
    Print('Kopftext');

    // ------- FERTIGUNGEN -----------------------------------------------------------------------
    vSumBreite    # 0.0;
    vSumLaenge    # 0.0;
    vSumStk       # 0;
    vSumGewichtN  # 0.0;
    vSumMenge     # 0.0;
    form_Mode # '';

    Print('Fertigungkopf');
    form_Mode # 'FERTIGUNG';
    Erx # RecLink(703,702,4,_RecFirst);
    WHILE (Erx<=_rLocked) DO BEGIN

      Print('Fertigung');

      // Verpackung der entsprechenden Fertigung im Array merken
      // Verpackungsnr einer Fertigung = 5 => fünftes Array-Element wird auf TRUE gesetzt etc.
      if (BAG.F.Verpackung > 0) then vVpg[BAG.F.Verpackung] # TRUE;

      // Summierung
      vSumBreite    # vSumBreite + (cnvfi(BAG.F.Streifenanzahl) * BAG.F.Breite);
      vSumStk       # vSumStk + "BAG.F.Stückzahl";
      vSumgewichtN  # vSumGewichtN + BAG.F.Gewicht;
      vSumMenge     # vSumMenge + BAG.F.Menge;

      Erx # RecLink(703,702,4,_RecNext);
    END;
    Print('Fertigungfuss');
    PL_PrintLine;

    // ------- VERPACKUNGEN ----------------------------------------------------------------------
    form_Mode # '';
    Print('Verpackungkopf');
    form_Mode # 'VERPACKUNG';

    // Array wird ausgelesen
    For i # 1
    loop inc(i)
    While ( i <= 100 ) DO BEGIN
      if (vVpg[i] = TRUE) then begin
        BAG.Vpg.Nummer # BAG.Nummer;        // BAG-Nummer
        BAG.Vpg.Verpackung # i;             // Verpackungsnummer
        Erx # RecRead(704,1,0);
        If (Erx <= _rLocked) then Print('Verpackung');
      end;
    END;
    Print('Verpackungfuss');
    PL_PrintLine;

    // alle Array-Elemente wieder auf False setzen
    for i # 1
    loop inc(i)
    while ( i <= 100) do begin
      vVpg[i] # FALSE;
    end;


    // ------- FUßDATEN --------------------------------------------------------------------------
    form_Mode # 'FUSS';
    Print('Fusstext');
    Print('Tabelle');

    Erx # RecLink(702,700,1,_recNext); // Positionen loopen
  END; // Positionen loopen

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
