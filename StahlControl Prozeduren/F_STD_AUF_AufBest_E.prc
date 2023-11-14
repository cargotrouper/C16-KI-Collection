@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_AUF_AufBest_E
//                      OHNE E_R_G
//  Info
//    Druckt eine Auftragsbestätigung
//
//
//  01.03.2006  AI  Erstellung der Prozedur
//  06.10.2006  ST  Anpassung
//  15.02.2007  NH  Anpassung/Analyse Mech & Chem
//  13.08.2009  ST  Artikelausgabe überarbeitet, Material/Artikelmix hinzugefügt
//  17.08.2009  MS  Rabatte hinzugefuegt
//  25.08.2009  MS  Formular auf ENGLISCH
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  29.10.2012  ST  Lohnfertigungen -> Eigenmaterial ausgeblendet
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB AddChem(aName : alpha; aName2 : alpha; pMin : float; pMax : float);
//    SUB AddMech(Name : alpha; pMin : float; pMax : float; Einheit : alpha;);
//    SUB MaterialDruck();
//    SUB MaterialDruck_Lohn();
//    SUB BAGDruck();
//    SUB HoleEmpfaenger();
//    SUB SeitenKopf();
//    SUB Print(aTyp : alpha);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG
@I:Def_Aktionen

declare Print(aTyp : alpha);
declare PrintLohnBA(aTyp : alpha);


define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;

  cPos0   :  10.0   // Anschrift

  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  20.0   // Bez.
  cPos2a  :  50.0   // Werte
  cPos2b  :  77.0
  cPos2c  :  70.0   // Dimensions Toleranzen
  cPos2d  :  80.0
  cPos2f  :  55.0   //Stückzahl
  cPos2g  :  60.0
  cPos3   :  90.0   // Menge1
  cPos3a  :  90.0
  cPos3b  :  92.0
  cPos3c  : 105.0
  cPos4   : 110.0   // Menge2
  cPos4a  : 110.0
  cPos4b  : 112.0
  cPos5   : 143.0   // Einzelpreis
  cPos5a  : 130.0
  cPos5b  : 143.0
  cPos5c  : 144.0
  cPos6   : 165.0   // Rabatt
  cPos7   : 182.0   // Gesamt

  cPos8   : 161.0   // Gesamt
  cPos9   : 182.0   // Gesamt


  // Einsatzmaterial
  cPosE0   : cPos2  // cPosE0   : 12.0
  cPosE1   : cPosE0 + 7.0  // Stk
  cPosE2   : cPosE1 + 5.0   // Abmessung
  cPosE3   : cPosE2 + 45.0  // Güte
  cPosE4   : cPosE3 + 30.0  // Matnr
  cPosE5   : cPosE4 + 5.0  // Coilnummer
  cPosE6   : cPosE5 + 40.0  // Gewicht Br
  cPosE7   : cPosE6 + 20.0  // Gewicht Ne
  cPosE8   : cPosE7 + 10.0  // Teilungen Tlg

  //Fertigung
  cPosF1  : cPos2
  cPosF2  : cPosF1 + 55.0

  cPosF0   : cPosE0    // linker Einzug vom Einsatzmaterial übernehmen

  //Spalten   -- FERTIG
  cPosF1a   : cPosF0  + 7.0     // Anzahl
  cPosF2a   : cPosF1a + 15.0    // Breite
  cPosF3a   : cPosF2a + 10.0    // Toleranz
  cPosF4a   : cPosF3a + 100.0   // Plan Stk
  cPosF5a   : cPosF4a + 20.0    // Plan Gewicht
  cPosF6a   : cPosF5a + 10.0    // Verpackng



/*
  cPosF1a   : cPosF0  + 7.0     // Anzahl
  cPosF2a   : cPosF1a + 15.0    // Breite
  cPosF3a   : cPosF2a + 10.0    // Toleranz
  cPosF4a   : cPosF3a + 100.0   // Plan Stk
  cPosF5a   : cPosF4a + 20.0    // Plan Gewicht
  cPosF6a   : cPosF5a + 10.0    // Verpackng
*/
  //Tafeln
  cPosF1b   : cPosF0  + 7.0 - 1000.0 // Anzahl
  cPosF2b   : cPosF0  + 15.0  // Breite
  cPosF3b   : cPosF2b + 20.0  // Länge
  cPosF4b   : cPosF3b + 5.0  // Breitentoleranz
  cPosF5b   : cPosF4b + 30.0  // Längentoleranz
  cPosF6b   : cPosF5b + 62.5  // Plan Stk
  cPosF7b   : cPosF6b + 20.0  // Plan Gewicht
  cPosF8b   : cPosF7b + 10.0  // Verpackng



  //c: Diverses
  cPosF1c   : cPosF0  + 0.0  // Güte
  cPosF2c   : cPosF1c + 27.5  // Dicke
  cPosF3c   : cPosF2c + 15.0  // Breite
  cPosF4c   : cPosF3c + 15.0  // Länge
  cPosF5c   : cPosF4c + 2.5   // Dickentoleranz
  cPosF6c   : cPosF5c + 25.0  // Breitentoleranz
  cPosF7c   : cPosF6c + 30.0  // Längentoleranz
  cPosF8c   : cPosF7c + 1000.0  // RID      -- DEAKTIVIERT
  cPosF9c   : cPosF8c + 1000.0  // RAD      -- DEAKTIVIERT
  cPosF10c  : cPosF7c + 25.0  // Plan Stk
  cPosF11c  : cPosF10c+ 15.0  // Plan Gewicht
  cPosF12c  : cPosF11c+ 7.0  // Verpackng

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

  //k: Abcoilen --- FERTIG
  cPosF0k   : cPosF0
  cPosF1k   : cPosF0k + 7.0   // Anzahl
  cPosF2k   : cPosF1k + 15.0  // Breite
  cPosF3k   : cPosF2k + 20.0  // Länge
  cPosF4k   : cPosF3k + 5.0   // Breitentoleranz
  cPosF5k   : cPosF4k + 30.0  // Längentoleranz
  cPosF6k   : cPosF5k + 55.0  // Plan Stk
  cPosF7k   : cPosF6k + 20.0  // Plan Gewicht
  cPosF8k   : cPosF7k + 10.0  // Verpackng


  // Verpackung --- FERTIG
  cPosV0    : 12.0            // Basiswert
  cPosV1    : cPosV0 + 10.0  // Verpackungsnr
  cPosV2    : cPosV1 + 10.0   // Verpackungstext Start
  cPosV2Ende : cPosE8  // Verpackungstext Ende


  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cPosKopf3 : 35.0  // Feld Lieferanschrift

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0  // Felder Lieferung, Warenempfänger,...
end;

local begin
  vBuf100Re           : int;

  vZeilenZahl         : int;
  vCoord              : float;
  vSumStk             : int;
  vSumGewichtN        : float;
  vSumGewichtB        : float;
  vSumBreite          : float;
  vSumLaenge          : float;

  vAdresse            : int;      // Nummer des Empfängers
  vPreis              : float;
  vFirst              : logic;
  vA                  : alpha;
  vRechnungsempf      : alpha(250); // Adresse des Rechnungsempängers
  vWarenempf          : alpha(250); // Adresse des Warenempängers

  // Für Mehrwertsteuer
  vMwstSatz1          : float;
  vMwstWert1          : float;
  vMwstSatz2          : float;
  vMwstWert2          : float;
  vMwstText           : alpha;
  vPosMwSt            : float;

  // Für Preise
  vGesamtNetto        : float;
  vGesamtNettoRabBar  : float;
  vGesamtMwSt         : float;
  vGesamtBrutto       : float;

  vPosCount           : int;
  vPosAnzahlAkt       : int;

  vMenge              : float;
  vPosMenge           : float;
  vPosGewicht         : float;
  vPosStk             : int;
  vPosNetto           : float;
  vPosNettoRabbar     : float;
  vRB1                : alpha;
  vKopfAufpreis       : float;


  // für Verpckungen als Aufpreise
  vVPGPreis           : float;
  vVPGPEH             : int;
  vVPGMEH             : alpha;

  vWtrverb        : alpha;

  // Lohnbearbeitung
  vGedrucktePos       : int;
  vVerpCheck          : alpha;
  vVerpUsed          : alpha;
  vBAGPrinted       : logic;

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
  RecLink(100,400,1,_RecFirst);   // Kunde holen
  aAdr            # Adr.Nummer;
  aSprache        # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Auf.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
end;


//========================================================================
//   AddChem
//            Fügt eine Zeile chemischer Analyse zum Formular hinzu
//            Wird nur benötigt für MaterialDruck()
//            Argumente:
//                Name  Name des Elements
//                pMin     1. Wert
//                pMax     2. Wert
//========================================================================
sub AddChem(
  aName   : alpha;
  aName2  : alpha;
  pMin    : float;
  pMax : float);
begin

  if (aName2<>'') then aName # aName2;

  //GV.Int.01 ist die Aktuelle Spalte
  if (pMin<>0.0 or pMax<>0.0) then begin
    PL_Print(aName,CnvFI(GV.Int.01*30)+cpos2a)
    if (GV.Logic.01<>true) then begin PL_Print('Chem. Analyse:',cPos2);GV.Logic.01#true;end;
    if (pMin<>0.0 and pMax<>0.0) then
      PL_Print(CnvAF(pMin) + ' - ' + CnvAF(pMax),CnvFI(GV.Int.01*30)+cpos2a+5.0)
    if (pMin<>0.0 and pMax=0.0) then
      PL_Print('min. ' + CnvAF(pMin),CnvFI(GV.Int.01*30)+cpos2a+5.0)
    if (pMin=0.0 and pMax<>0.0) then
      PL_Print('max. ' + CnvAF(pMax),CnvFI(GV.Int.01*30)+cpos2a+5.0)

    GV.Int.01 # GV.Int.01 + 1
    if (GV.Int.01=4) then begin
      GV.Int.01#0;
      PL_Printline;
    end;
 end;
end;


//========================================================================
//   AddMech
//            Fügt eine Zeile mechanischer Analyse zum Formular hinzu
//            Wird nur benötigt für MaterialDruck()
//            Argumente:
//                Name    Name der Größe
//                pMin     1. Wert
//                pMax     2. Wert
//                Einheit Bezeichnung der Einheit
//========================================================================
sub AddMech(Name : alpha; pMin : float; pMax : float; Einheit : alpha;);
begin
  Einheit # ' ' + Einheit;
  if(pMin<>0.0 or pMax<>0.0)then begin
    if (GV.Logic.01<>true) then begin PL_Print('Mech. Analyse:',cPos2);GV.Logic.01#true;end;
    PL_Print(Name,cpos2a);
    if(pMin<>0.0 and pMax<>0.0)then begin
      PL_Print(CnvAF(pMin) + Einheit + ' - ' + CnvAF(pMax) + Einheit,75.0);end;
    if(pMin<>0.0)then begin
      if (pMax=0.0) then
        PL_Print(Name,cpos2a);PL_Print('min. ' + CnvAF(pMin) + Einheit,75.0);
    end;
    if(pMin=0.0)then begin
      if (pMax<>0.0) then
        PL_Print(Name,cpos2a);PL_Print('max. ' + CnvAF(pMax) + Einheit,75.0);
    end;
    if(pMin=pMax)then
      PL_Print(Name,cpos2a);PL_Print(CnvAF(pMin) + Einheit,75.0);
    PL_PrintLine;
  end;
end;


//========================================================================
//  MaterialDruck
//            Druckt die Materialdaten für ein Druckformular
//            Wird benötigt allen Druckroutinen
//========================================================================
sub MaterialDruck(
  aRb1      : alpha;
  aWMenge   : float;
  aPMenge   : float;
  aStk      : int;
  );
local begin
  Erx           : int;
  vVerp     : alpha(1000);
  vFlag     : int;
  vMerker   : alpha;
end;
begin

  Auf.P.Gesamtpreis # Rnd((Auf.P.Grundpreis) *  aPMenge / CnvFI(Auf.P.PEH) ,2);
  // -- Positionsdaten --
  PL_Print(AInt(Auf.P.Position),cPos1);
  PL_Print(Wgr.Bezeichnung.L2,cPos2);
  if (aStk <> 0) then
    PL_Print(AInt(aStk) + ' pcs.',cPos2f);

  PL_PrintF(aWMenge,Set.Stellen.Menge,cPos3a);
  PL_Print(Auf.P.MEH.Wunsch,cPos3b);
  if (Auf.P.MEH.Wunsch<>Auf.P.MEH.Preis) then begin
    if (Auf.P.MEH.Preis='m') or (Auf.P.MEH.Preis='qm') then
      PL_PrintF(aPMenge,2,cPos4a)
    else if (Auf.P.MEH.Preis='t') then
      PL_PrintF(aPMenge,3,cPos4a)
    else
      PL_PrintF(aPMenge,0,cPos4a)
    PL_Print(Auf.P.MEH.Preis,cPos4b);
  end;

/***
  PL_PrintF(Auf.P.Menge.Wunsch,2,cPos3a);
  PL_Print(Auf.P.MEH.Wunsch,cPos3b);
  if (Auf.P.MEH.Wunsch<>Auf.P.MEH.Preis) then begin
    if (Auf.P.MEH.Preis='m') or (Auf.P.MEH.Preis='qm') then
      PL_PrintF(vPosMenge,2,cPos4a)
    else if (Auf.P.MEH.Preis='t') then
      PL_PrintF(vPosMenge,3,cPos4a)
    else
      PL_PrintF(vPosMenge,0,cPos4a)
    PL_Print(Auf.P.MEH.Preis,cPos4b);
  end;
***/
  PL_PrintF(Auf.P.Grundpreis,2,cPos5a);
  PL_Print('pro',cPos5a+0.8);
  PL_PrintI(Auf.P.PEH,cPos5b);
  PL_Print(Auf.P.MEH.Preis,cPos5c);
  PL_Print_R(aRb1,cPos6,cPos5c+7.0);
  PL_PrintF(Auf.P.Gesamtpreis,2,cPos7);
  PL_PrintLine;
  PL_Print('',cpos2)
  PL_PrintLine;
  Gv.Alpha.01 # ANum( cnvfa(Gv.Alpha.01)+Auf.P.Gesamtpreis,2);



  // Artikelmix?
  if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin

    // Artikel lesen
    Erx # RecLink(250,401,2,_RecFirst);
    If (Erx > _rLocked) then
      RecBufClear(250);

    // Artikelnummer
    PL_Print(Art.Nummer,cPos2);
    PL_PrintLine;

    // Bezeichnungen
    if (Art.Bezeichnung1 <> '') then begin
      PL_Print(Art.Bezeichnung1,cPos2);
      PL_PrintLine;
    end;
    if (Art.Bezeichnung2 <> '') then begin
      PL_Print(Art.Bezeichnung2,cPos2);
      PL_PrintLine;
    end;
    if (Art.Bezeichnung3 <> '') then begin
      PL_Print(Art.Bezeichnung3,cPos2);
      PL_PrintLine;
    end;

    // Artikel Abmessung
    if (Auf.P.AbmessString <> '') then begin
      PL_Print(Auf.P.AbmessString,cPos2);
      PL_PrintLine;
    end;

  end; // Artikelmix?


  // Projektnummer
  if (Auf.P.Projektnummer <> 0) then begin
    PL_Print('Project-No.:',cPos2);
    PL_Print(StrAdj(AInt(Auf.P.Projektnummer),_StrBegin),cPos2a);
    PL_PrintLine;
  end;

  // Abrufbestnr
  if (Auf.P.AbrufAufNr <> 0) then begin
    PL_Print('Call-off order:',cPos2);

    if (Auf.P.AbrufAufPos <> 0) then
      PL_Print(AInt(Auf.P.AbrufAufNr)+ '/' +
               AInt(Auf.P.AbrufAufPos),cPos2a);
    else
      PL_Print(AInt(Auf.P.AbrufAufNr),cPos2a);

    PL_PrintLine;
  end;

  // PositionsBestellnummer
  if (Auf.P.Best.Nummer <> '') then begin
    PL_Print('Your order-No.:',cPos2);
    PL_Print(Auf.P.Best.Nummer,cPos2a);
    PL_PrintLine;
  end;

  // Kundenartikelnummer
  if (Auf.P.KundenArtNr <> '') then begin
    PL_Print('Your material-No.:',cPos2);
    PL_Print(Auf.P.KundenArtNr,cPos2a);
    PL_PrintLine;
  end;

  // Qualität
  if ("Auf.P.Güte"<>'') then begin
    PL_Print('Grade:',cPos2);
    PL_Print("Auf.P.Güte" + ' / '+ "Auf.P.Gütenstufe",cPos2a);
    PL_PrintLine;
  end;

  //Ausführung

  if Auf.P.AusfOben <> '' or Auf.P.AusfUnten <> '' then begin
    PL_Print('Ausführung:',cPos2);
    //vVerp ausgeliehen für Ausführungstext
    // Oben/Vorderseite
    if (Auf.P.AusfOben <> '') then begin
        //Kürzel nach Bezeichnung auflösen
        vFlag # _RecFirst;
        WHILE (RecRead(402,1,vFlag) <= _rLocked ) DO BEGIN
          vFlag # _RecNext;
          if ("Auf.AF.Kürzel" = Auf.P.AusfOben) then vVerp # 'Vorderseite: ' + Auf.AF.Bezeichnung;
        END;
    end;
    // Unten/Rückseite
    if (Auf.P.AusfUnten <> '') then begin
      //Kürzel nach Bezeichnung auflösen
      vFlag # _RecFirst;
      WHILE (RecRead(402,1,vFlag) <= _rLocked ) DO BEGIN
        vFlag # _RecNext;
        if ("Auf.AF.Kürzel" = Auf.P.AusfUnten)then vMerker # Auf.AF.Bezeichnung;
      END;
      if (vVerp <> '') then
        vVerp # vVerp + '    Rückseite: ' + vMerker;
      else
        vVerp # 'Rückseite: ' + vMerker;
    end;
    PL_Print(vverp,cpos2a);
    PL_PrintLine;
  end;

  //Dicke
  if (Auf.P.Dicke<>0.0) then begin
    PL_Print('Thickness ' + Auf.AbmessungsEH + ':',cpos2);
    PL_PrintF_L(Auf.P.Dicke,Set.Stellen.Dicke,cpos2a);

   if (Auf.P.Dickentol<>'') then begin
      PL_Print('Tol.:',cpos2c);
      PL_Print(Auf.P.Dickentol,cpos2d)
    end;

    PL_PrintLine;
  end;

  //Breite
  if (Auf.P.Breite<>0.0) then begin
    PL_Print('Width ' + Auf.AbmessungsEH + ':',cpos2);
    PL_PrintF_L(Auf.P.Breite,Set.Stellen.Breite,cpos2a);
    if (Auf.P.Breitentol <> '') then begin
      PL_Print('Tol.:',cPos2c);
      PL_Print(Auf.P.Breitentol,cPos2d);
    end;
    PL_PrintLine;
  end;

  //Länge
  if ("Auf.P.Länge"<>0.0)then begin
    PL_Print('Length ' + Auf.AbmessungsEH + ':', cpos2);
    PL_PrintF_L("Auf.P.Länge","Set.Stellen.Länge",cpos2a)
    if ("Auf.P.Längentol" <> '') then begin
      PL_Print('Tol.:',cPos2c);
      PL_Print("Auf.P.Längentol",cPos2d);
    end;
    PL_PrintLine;
  end;

  // Ringinnendurchmesser
  if ((Auf.P.RID <> 0.0) AND (Auf.P.RIDMAX = 0.0)) then begin
    PL_Print('RID ' + Auf.AbmessungsEH + ':',cpos2);
    PL_Printf_L(Auf.P.RID,4,cPos2a);
    PL_PrintLine;
  end else
  if ((Auf.P.RID <> 0.0) AND (Auf.P.RIDMAX <> 0.0)) then begin
    PL_Print('RID ' + Auf.AbmessungsEH + ':',cpos2);
    PL_Printf_L(Auf.P.RID,Set.Stellen.Radien,cPos2a);
    PL_Print(' - ', cPos2a + 12.0);
    PL_Printf_L(Auf.P.RIDMAX,Set.Stellen.Radien,cPos2a + 20.0);
    PL_PrintLine;
  end else
  if ((Auf.P.RID = 0.0) AND (Auf.P.RIDMAX <> 0.0)) then begin
    PL_Print('RID ' + Auf.AbmessungsEH + ':',cpos2);
    PL_Print('max. ' + CnvAf(Auf.P.RIDMAX),cPos2a);
    PL_PrintLine;
  end;

  // Ringaußendurchmesser
  if ((Auf.P.RAD <> 0.0) AND (Auf.P.RADMAX = 0.0)) then begin
    PL_Print('RAD ' + Auf.AbmessungsEH + ':',cpos2);
    PL_Printf_L(Auf.P.RAD,4,cPos2a);
    PL_PrintLine;
  end else
  if ((Auf.P.RAD <> 0.0) AND (Auf.P.RADMAX <> 0.0)) then begin
    PL_Print('RAD ' + Auf.AbmessungsEH + ':',cpos2);
    PL_Print(CnvAf(Auf.P.RAD) + ' - ' + CnvAf(Auf.P.RADMAX)  ,cPos2a);
    PL_PrintLine;
  end else
  if ((Auf.P.RAD = 0.0) AND (Auf.P.RADMAX <> 0.0)) then begin
    PL_Print('RAD ' + Auf.AbmessungsEH + ':',cpos2);
    PL_Print('max. ' + CnvAf(Auf.P.RADMAX),cPos2a);
    PL_PrintLine;
  end;

  // Zeugnis
  if (Auf.P.Zeugnisart <> '') then begin
    PL_Print('Certificate:',cPos2);
    PL_Print(Auf.P.Zeugnisart,cPos2a);
    PL_PrintLine;
  end;

  // Intrastat
  if (Auf.P.Intrastatnr <> '') then begin
    PL_Print('Commodity code:',cPos2);
    PL_Print(Auf.P.Intrastatnr,cPos2a);
    PL_PrintLine;
  end;

  // Erzeuger
  if (Auf.P.Erzeuger <> 0) then begin
    Erx # RecLink(100,401,10,_RecFirst);
    if (Erx <> _rNoRec) then begin
      PL_Print('Erzeuger:',cPos2);
      PL_Print(Adr.Anrede + ' ' +
               Adr.Name + ' ' +
               Adr.Zusatz ,cPos2a);
      PL_PrintLine;
    end;
  end;

  // Positionstext
  if (Auf.P.Bemerkung <> '') then begin
    PL_Print('Note:',cpos2);
    PL_Print(Auf.P.Bemerkung,cPos2a);
    PL_PrintLine;
  end;

  // Liefertermin & Lieferterminzusatz
  // Liefertermin
  PL_Print('Liefertermin:',cPos2);
  if (Auf.P.Termin1W.Art = 'DA') then begin
    PL_Print(CnvAd(Auf.P.Termin1Wunsch),cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'KW') then begin
    PL_Print('KW ' + CnvAi(Auf.P.Termin1W.Zahl,_FmtNumLeadZero) + '/' +
                     CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'MO') then begin
    PL_Print(Lib_Berechnungen:Monat_aus_datum(Auf.P.Termin1Wunsch) + ' ' +
             CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'QU') then begin
    PL_Print(CnvAi(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Quartal ' +
             CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'SE') then begin
    PL_Print(CnvAi(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Semester ' +
             CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'JA') then begin
    PL_Print('Jahr ' +  CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end;
  // Lieferterminzusatz
  if (Auf.P.Termin.Zusatz <> '') then
    PL_Print(Auf.P.Termin.Zusatz, cPos2b);

  PL_PrintLine;  // Liefertermin und Zusatz ausgeben

  //Etikettierung
  if (Auf.P.Etikettentyp<>0)then begin
    vFlag # _RecFirst;
    WHILE (RecRead(840,1,vFlag) <= _rLocked ) DO BEGIN
      vFlag # _RecNext;
      if (Eti.Nummer = Auf.P.Etikettentyp) then begin
        PL_Print('Etikettierung:',cpos2);
        PL_Print(Eti.Bezeichnung,cpos2a);
        PL_Printline;
      end;
    END;
  end;

  //------Verpackung---------
  vVerp # '';

  if (Auf.P.StehendYN) then
    ADD_VERP('stehend','');

  if (Auf.P.LiegendYN) then
    ADD_VERP('liegend','');

  //Abbindung
  if (Auf.P.AbbindungQ <> 0 or Auf.P.AbbindungL <> 0) then begin
    //Quer
    if(Auf.P.AbbindungQ<>0)then vMerker # 'Abbindung '+ AInt(Auf.P.AbbindungQ)+' x quer' ;
    //Längs
    if(Auf.P.AbbindungL<>0)then begin
      if (vMerker<>'')then
        vMerker # vMerker+'  '+AInt(Auf.P.AbbindungL)+ ' x längs';
      else
        vMerker # 'Abbindung ' + AInt(Auf.P.AbbindungL)+' x längs';
    end;
   ADD_VERP(vMerker,'')
  end;

  if (Auf.P.Zwischenlage <> '') then
    //'Zwischenlage: ',
    ADD_VERP(Auf.P.Zwischenlage,'');

  if (Auf.P.Unterlage <> '') then
    //'Unterlage: ',
    ADD_VERP(Auf.P.Unterlage,'');

  if (Auf.P.Nettoabzug > 0.0) then
    ADD_VERP('Nettoabzug: '+AInt(CnvIF(Auf.P.Nettoabzug))+' kg','');

  if ("Auf.P.Stapelhöhe" > 0.0) then
    ADD_VERP('max. Stapelhöhe: ',AInt(CnvIF("Auf.P.Stapelhöhe"))+' mm');

  if (Auf.P.StapelhAbzug > 0.0) then
    ADD_VERP('Stapelhöhenabzug: ',AInt(CnvIF("Auf.P.StapelhAbzug"))+' mm');
  //Ringgewicht
  if (Auf.P.RingKgVon + Auf.P.RingKgBis  <> 0.0) then begin
    if (Auf.P.RingKgVon <> 0.0 and Auf.P.RingKgBis <> 0.0) then
      vMerker # 'Ringgew.: min. ' + AInt(CnvIF(Auf.P.RingKgVon)) + ' kg  max. ' + AInt(CnvIF(Auf.P.RingKgBis));
    if (Auf.P.RingKgVon <> 0.0 and Auf.P.RingKgBis = 0.0) then
      vMerker # 'Ringgew.: ' + AInt(CnvIF(Auf.P.RingKgVon));
    if (Auf.P.RingKgVon = 0.0 and Auf.P.RingKgBis <> 0.0) then
      vMerker # 'Ringgew.: max. ' + AInt(CnvIF(Auf.P.RingKgBis));
    if (Auf.P.RingKgVon = Auf.P.RingKgBis) then
      vMerker # 'Ringgew.: ' + AInt(CnvIF(Auf.P.RingKgBis));
    vMerker#vMerker+' kg';
    ADD_VERP(vMerker,'')
  end;




  //kg/mm
  if (Auf.P.KgmmVon + Auf.P.KgmmBis  <> 0.0) then begin
    if (Auf.P.KgmmVon <> 0.0 and Auf.P.KgmmBis <> 0.0) then
      vMerker # 'Kg/mm: min. ' + CnvAF(Auf.P.KgmmVon) + ' max. ' + CnvAF(Auf.P.KgmmBis)
    if (Auf.P.KgmmVon <> 0.0 and Auf.P.KgmmBis = 0.0) then
      vMerker # 'Kg/mm: min. ' + CnvAF(Auf.P.KgmmVon)
    if (Auf.P.KgmmVon = 0.0 and Auf.P.KgmmBis <> 0.0) then
      vMerker # 'Kg/mm: max. ' + CnvAF(Auf.P.KgmmBis)
    if (Auf.P.KgmmVon = Auf.P.KgmmBis) then
      vMerker # 'Kg/mm: ' + CnvAF(Auf.P.KgmmBis)
    ADD_VERP(vMerker,'')
  end;

  if ("Auf.P.StückProVE" > 0) then
    ADD_VERP(AInt("Auf.P.StückProVE") + ' Stück pro VE', '');

  if (Auf.P.VEkgMax > 0.0) then
    ADD_VERP('max. kg pro VE: ',AInt(CnvIF(Auf.P.VEkgMax)));

  if (Auf.P.RechtwinkMax > 0.0) then
    ADD_VERP('max. Rechtwinkligkeit: ', CnvAf(Auf.P.RechtwinkMax));

  if (Auf.P.EbenheitMax > 0.0) then
    ADD_VERP('max. Ebenheit: ', CnvAf(Auf.P.EbenheitMax));

  if ("Auf.P.SäbeligkeitMax" > 0.0) then
    ADD_VERP('max. Säbeligkeit: ', CnvAf("Auf.P.SäbeligkeitMax"));

  if (vVerp <> '') then begin
    PL_Print('Verpackung:',cpos2);
    PL_Print(vVerp,cPos2a,cPos7);
    PL_Printline;
  end;

  if (Auf.P.VpgText1 <> '') then begin
    PL_Print(Auf.P.VpgText1,cPos2a);
//Lib_PrintLine:PrintPic(cPos5,cPos5+20.0,20.0,'*Z:\c16\client.53\bilder\skizzen\skizze100.jpg');
    PL_Printline;
  end;
  if (Auf.P.VpgText2 <> '') then begin
    PL_Print(Auf.P.VpgText2,cPos2a);
    PL_Printline;
  end;
  if (Auf.P.VpgText3 <> '') then begin
    PL_Print(Auf.P.VpgText3,cPos2a);
    PL_Printline;
  end;
  if (Auf.P.VpgText4 <> '') then begin
    PL_Print(Auf.P.VpgText4,cPos2a);
    PL_Printline;
  end;
  if (Auf.P.VpgText5 <> '') then begin
    PL_Print(Auf.P.VpgText5,cPos2a);
    PL_Printline;
  end;
  if (Auf.P.VpgText6 <> '') then begin
    PL_Print(Auf.P.VpgText6,cPos2a);
    PL_Printline;
  end;
  //mech Analyse
  GV.Logic.01#false;//=Noch kein Element gelistet (für 'Mech. Analyse:')
  AddMech('Streckgrenze',Auf.P.Streckgrenze1 , Auf.P.Streckgrenze2,'N/mm²');
  AddMech('Zugfestigkeit',Auf.P.Zugfestigkeit1 , Auf.P.Zugfestigkeit2,'N/mm²');
  if (Auf.P.DehnungA1+Auf.P.DehnungA2+Auf.P.DehnungB1+Auf.P.DehnungB2<>0.0)then begin
    if (GV.Logic.01=false)then begin GV.Logic.01#true;PL_Print('Mech. Analyse:',cPos2); end;
    PL_Print('Dehnung',cPos2a);
    PL_Print(CnvAF(Auf.P.DehnungA1) + ' / ' + CnvAF(Auf.P.DehnungB1) + '% - ' + CnvAF(Auf.P.DehnungA2) + ' / ' + CnvAF(Auf.P.DehnungB2) + '%',75.0);
    PL_PrintLine;
  end;
  AddMech('Rp 0,2',Auf.P.DehngrenzeA1 , Auf.P.DehngrenzeA2,'N/mm²');
  AddMech('Rp 10',Auf.P.DehngrenzeB1 , Auf.P.DehngrenzeB2,'N/mm²');
  if ("Set.Mech.Titel.Körn" <> '') then AddMech("Set.Mech.Titel.Körn","Auf.P.Körnung1", "Auf.P.Körnung2",'')
  else AddMech('Körnung',"Auf.P.Körnung1", "Auf.P.Körnung2",'');
  if ("Set.Mech.Titel.Härte" <> '') then AddMech("Set.Mech.Titel.Härte","Auf.P.Härte1" , "Auf.P.Härte2",'')
  else AddMech('Härte',"Auf.P.Härte1" , "Auf.P.Härte2",'');
  // Sonstiges
  if ("Auf.P.Mech.Sonstig1" <> '') then begin
    if ("Set.Mech.Titel.Sonst" <> '') then begin
      PL_Print("Set.Mech.Titel.Sonst",cpos2a);
      PL_Print("Auf.P.Mech.Sonstig1",75.0);
    end
    else begin
      PL_Print('Sonstiges',cpos2a);
      PL_Print("Auf.P.Mech.Sonstig1",75.0);
    end;
    PL_PrintLine;
  end;

  //chem Analyse
  GV.Logic.01#false;  //=Noch kein Element gelistet (für 'Chem. Analyse:')
  GV.Int.01#0;    //Akt. Spalte
  AddChem('C' ,Set.Chemie.Titel.C   ,Auf.P.Chemie.C1,Auf.P.Chemie.C2);
  AddChem('Si',Set.Chemie.Titel.Si  ,Auf.P.Chemie.Si1,Auf.P.Chemie.Si2);
  AddChem('Mn',Set.Chemie.Titel.Mn  ,Auf.P.Chemie.Mn1,Auf.P.Chemie.Mn2);
  AddChem('P' ,Set.Chemie.Titel.P   ,Auf.P.Chemie.P1,Auf.P.Chemie.P2);
  AddChem('S' ,Set.Chemie.Titel.S   ,Auf.P.Chemie.S1,Auf.P.Chemie.S2);
  AddChem('Al',Set.Chemie.Titel.Al  ,Auf.P.Chemie.Al1,Auf.P.Chemie.Al2);
  AddChem('Cr',Set.Chemie.Titel.Cr  ,Auf.P.Chemie.Cr1,Auf.P.Chemie.Cr2);
  AddChem('V' ,Set.Chemie.Titel.V   ,Auf.P.Chemie.V1,Auf.P.Chemie.V2);
  AddChem('Nb',Set.Chemie.Titel.Nb  ,Auf.P.Chemie.Nb1,Auf.P.Chemie.Nb2);
  AddChem('Ti',Set.Chemie.Titel.Ti  ,Auf.P.Chemie.Ti1,Auf.P.Chemie.Ti2);
  AddChem('N' ,Set.Chemie.Titel.N   ,Auf.P.Chemie.N1,Auf.P.Chemie.N2);
  AddChem('Cu',Set.Chemie.Titel.Cu  ,Auf.P.Chemie.Cu1,Auf.P.Chemie.Cu2);
  AddChem('Ni',Set.Chemie.Titel.Ni  ,Auf.P.Chemie.Ni1,Auf.P.Chemie.Ni2);
  AddChem('Mo',Set.Chemie.Titel.Mo  ,Auf.P.Chemie.Mo1,Auf.P.Chemie.Mo2);
  AddChem('B' ,Set.Chemie.Titel.B   ,Auf.P.Chemie.B1,Auf.P.Chemie.B2);
  AddChem(''  ,Set.Chemie.Titel.1   ,Auf.P.Chemie.Frei1.1,Auf.P.Chemie.Frei1.2);
  PL_PrintLine;

end;


//========================================================================
//  MaterialDruck_Lohn
//            Druckt die Materialdaten für ein Druckformular
//            Wird benötigt allen Druckroutinen
//========================================================================
sub MaterialDruck_Lohn(
  aRb1      : alpha;
  aWMenge   : float;
  aPMenge   : float;
  aStk      : int;
  );
local begin
  Erx           : int;
  vVerp     : alpha(1000);
  vFlag     : int;
  vMerker   : alpha;
end;
begin

  // BA suchen...
  Erx # RecLink(404,401,12,_recFirsT);    // Aktionen loopen
  WHILE (Erx<=_rLocked) do begin
    if (Auf.A.Aktionstyp=c_Akt_BA) AND ("Auf.A.Löschmarker" = '')then begin
      BAG.Nummer # Auf.A.Aktionsnr;
      Erx # RecRead(700,1,0);  // BAG holen
      if (Erx<=_rLocked) then BREAK;
    end;
    Erx # RecLink(404,401,12,_recNext);
  END;
  if (Erx<=_rLocked) then begin // BA gefunden??
    aWMenge # Auf.A.Menge;
    aPMenge # aWMenge;
  end;

  Auf.P.Gesamtpreis # Rnd((Auf.P.Grundpreis) *  aPMenge / CnvFI(Auf.P.PEH) ,2);
  // -- Positionsdaten --
  PL_Print(AInt(Auf.P.Position),cPos1);
  PL_Print(Wgr.Bezeichnung.L2,cPos2);
  if (aStk <> 0) then
    PL_Print(AInt(aStk) + ' Stk.',cPos2f);

  PL_PrintF(aWMenge,Set.Stellen.Menge,cPos3a);
  PL_Print(Auf.P.MEH.Wunsch,cPos3b);

/***
  PL_PrintF(Auf.P.Menge.Wunsch,2,cPos3a);
  PL_Print(Auf.P.MEH.Wunsch,cPos3b);
  if (Auf.P.MEH.Wunsch<>Auf.P.MEH.Preis) then begin
    if (Auf.P.MEH.Preis='m') or (Auf.P.MEH.Preis='qm') then
      PL_PrintF(vPosMenge,2,cPos4a)
    else if (Auf.P.MEH.Preis='t') then
      PL_PrintF(vPosMenge,3,cPos4a)
    else
      PL_PrintF(vPosMenge,0,cPos4a)
    PL_Print(Auf.P.MEH.Preis,cPos4b);
  end;
***/
  PL_PrintF(Auf.P.Grundpreis,2,cPos5a);
  PL_Print('je',cPos5a+0.8);

  PL_PrintI(Auf.P.PEH,cPos5b);
  PL_Print(Auf.P.MEH.Preis,cPos5c);
  PL_Print_R(aRb1,cPos6,cPos5c+7.0);
  PL_PrintF(Auf.P.Gesamtpreis,2,cPos7);
  PL_PrintLine;
  PL_Print('',cpos2)
  PL_PrintLine;
  Gv.Alpha.01 # Cnvaf( cnvfa(Gv.Alpha.01)+Auf.P.Gesamtpreis);

  // Projektnummer
  if (Auf.P.Projektnummer <> 0) then begin
    PL_Print('Project-No.:',cPos2);
    PL_Print(StrAdj(AInt(Auf.P.Projektnummer),_StrBegin),cPos2a);
    PL_PrintLine;
  end;

  // Abrufbestnr
  if (Auf.P.AbrufAufNr <> 0) then begin
    PL_Print('Call-off order:',cPos2);

    if (Auf.P.AbrufAufPos <> 0) then
      PL_Print(AInt(Auf.P.AbrufAufNr)+ '/' +
               AInt(Auf.P.AbrufAufPos),cPos2a);
    else
      PL_Print(AInt(Auf.P.AbrufAufNr),cPos2a);

    PL_PrintLine;
  end;

  // PositionsBestellnummer
  if (Auf.P.Best.Nummer <> '') then begin
    PL_Print('Your order-No.:',cPos2);
    PL_Print(Auf.P.Best.Nummer,cPos2a);
    PL_PrintLine;
  end;

  // Kundenartikelnummer
  if (Auf.P.KundenArtNr <> '') then begin
    PL_Print('Your material-No.:',cPos2);
    PL_Print(Auf.P.KundenArtNr,cPos2a);
    PL_PrintLine;
  end;

  // Positionstext
  if (Auf.P.Bemerkung <> '') then begin
    PL_Print('Bemerkung:',cpos2);
    PL_Print(Auf.P.Bemerkung,cPos2a);
    PL_PrintLine;
  end;

  // Liefertermin & Lieferterminzusatz
  // Liefertermin
  PL_Print('Liefertermin:',cPos2);
  if (Auf.P.Termin1W.Art = 'DA') then begin
    PL_Print(CnvAd(Auf.P.Termin1Wunsch),cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'KW') then begin
    PL_Print('KW ' + CnvAi(Auf.P.Termin1W.Zahl,_FmtNumLeadZero) + '/' +
                     CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'MO') then begin
    PL_Print(Lib_Berechnungen:Monat_aus_datum(Auf.P.Termin1Wunsch) + ' ' +
             CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'QU') then begin
    PL_Print(CnvAi(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Quartal ' +
             CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'SE') then begin
    PL_Print(CnvAi(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Semester ' +
             CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end else
  if (Auf.P.Termin1W.Art = 'JA') then begin
    PL_Print('Jahr ' +  CnvAi(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPos2a);
  end;
  // Lieferterminzusatz
  if (Auf.P.Termin.Zusatz <> '') then
    PL_Print(Auf.P.Termin.Zusatz, cPos2b);

  PL_PrintLine;  // Liefertermin und Zusatz ausgeben

  //Etikettierung
  if (Auf.P.Etikettentyp<>0)then begin
    vFlag # _RecFirst;
    WHILE (RecRead(840,1,vFlag) <= _rLocked ) DO BEGIN
      vFlag # _RecNext;
      if (Eti.Nummer = Auf.P.Etikettentyp) then begin
        PL_Print('Etikettierung:',cpos2);
        PL_Print(Eti.Bezeichnung,cpos2a);
        PL_Printline;
      end;
    END;
  end;

  //------Verpackung---------
  vVerp # '';

  if (Auf.P.StehendYN) then
    ADD_VERP('stehend','');

  if (Auf.P.LiegendYN) then
    ADD_VERP('liegend','');

  //Abbindung
  if (Auf.P.AbbindungQ <> 0 or Auf.P.AbbindungL <> 0) then begin
    //Quer
    if(Auf.P.AbbindungQ<>0)then vMerker # 'Abbindung '+ AInt(Auf.P.AbbindungQ)+' x quer' ;
    //Längs
    if(Auf.P.AbbindungL<>0)then begin
      if (vMerker<>'')then
        vMerker # vMerker+'  '+AInt(Auf.P.AbbindungL)+ ' x längs';
      else
        vMerker # 'Abbindung ' + AInt(Auf.P.AbbindungL)+' x längs';
    end;
   ADD_VERP(vMerker,'')
  end;

  if (Auf.P.Zwischenlage <> '') then
    //'Zwischenlage: ',
    ADD_VERP(Auf.P.Zwischenlage,'');

  if (Auf.P.Unterlage <> '') then
    //'Unterlage: ',
    ADD_VERP(Auf.P.Unterlage,'');

  if (Auf.P.Nettoabzug > 0.0) then
    ADD_VERP('Nettoabzug: '+AInt(CnvIF(Auf.P.Nettoabzug))+' kg','');

  if ("Auf.P.Stapelhöhe" > 0.0) then
    ADD_VERP('max. Stapelhöhe: ',AInt(CnvIF("Auf.P.Stapelhöhe"))+' mm');

  if (Auf.P.StapelhAbzug > 0.0) then
    ADD_VERP('Stapelhöhenabzug: ',AInt(CnvIF("Auf.P.StapelhAbzug"))+' mm');

  //Ringgewicht
  if (Auf.P.RingKgVon + Auf.P.RingKgBis  <> 0.0) then begin
    if (Auf.P.RingKgVon <> 0.0 and Auf.P.RingKgBis <> 0.0) then
      vMerker # 'Ringgew.: min. ' + AInt(CnvIF(Auf.P.RingKgVon)) + ' kg  max. ' + AInt(CnvIF(Auf.P.RingKgBis));
    if (Auf.P.RingKgVon <> 0.0 and Auf.P.RingKgBis = 0.0) then
      vMerker # 'Ringgew.: ' + AInt(CnvIF(Auf.P.RingKgVon));
    if (Auf.P.RingKgVon = 0.0 and Auf.P.RingKgBis <> 0.0) then
      vMerker # 'Ringgew.: max. ' + AInt(CnvIF(Auf.P.RingKgBis));
    if (Auf.P.RingKgVon = Auf.P.RingKgBis) then
      vMerker # 'Ringgew.: ' + AInt(CnvIF(Auf.P.RingKgBis));
    vMerker#vMerker+' kg';
    ADD_VERP(vMerker,'')
  end;

  //kg/mm
  if (Auf.P.KgmmVon + Auf.P.KgmmBis  <> 0.0) then begin
    if (Auf.P.KgmmVon <> 0.0 and Auf.P.KgmmBis <> 0.0) then
      vMerker # 'Kg/mm: min. ' + CnvAF(Auf.P.KgmmVon) + ' max. ' + CnvAF(Auf.P.KgmmBis)
    if (Auf.P.KgmmVon <> 0.0 and Auf.P.KgmmBis = 0.0) then
      vMerker # 'Kg/mm: min. ' + CnvAF(Auf.P.KgmmVon)
    if (Auf.P.KgmmVon = 0.0 and Auf.P.KgmmBis <> 0.0) then
      vMerker # 'Kg/mm: max. ' + CnvAF(Auf.P.KgmmBis)
    if (Auf.P.KgmmVon = Auf.P.KgmmBis) then
      vMerker # 'Kg/mm: ' + CnvAF(Auf.P.KgmmBis)
    ADD_VERP(vMerker,'')
  end;

  if ("Auf.P.StückProVE" > 0) then
    ADD_VERP(AInt("Auf.P.StückProVE") + ' Stück pro VE', '');

  if (Auf.P.VEkgMax > 0.0) then
    ADD_VERP('max. kg pro VE: ',AInt(CnvIF(Auf.P.VEkgMax)));

  if (Auf.P.RechtwinkMax > 0.0) then
    ADD_VERP('max. Rechtwinkligkeit: ', CnvAf(Auf.P.RechtwinkMax));

  if (Auf.P.EbenheitMax > 0.0) then
    ADD_VERP('max. Ebenheit: ', CnvAf(Auf.P.EbenheitMax));

  if ("Auf.P.SäbeligkeitMax" > 0.0) then
    ADD_VERP('max. Säbeligkeit: ', CnvAf("Auf.P.SäbeligkeitMax"));

  if (vVerp <> '') then begin
    PL_Print('Verpackung:',cpos2);
    PL_Print(vVerp,cPos2a,cPos7);
    PL_Printline;
  end;

  if (Auf.P.VpgText1 <> '') then begin
    PL_Print(Auf.P.VpgText1,cPos2a);
    PL_Printline;
  end;
  if (Auf.P.VpgText2 <> '') then begin
    PL_Print(Auf.P.VpgText2,cPos2a);
    PL_Printline;
  end;
  if (Auf.P.VpgText3 <> '') then begin
    PL_Print(Auf.P.VpgText3,cPos2a);
    PL_Printline;
  end;
  if (Auf.P.VpgText4 <> '') then begin
    PL_Print(Auf.P.VpgText4,cPos2a);
    PL_Printline;
  end;
  if (Auf.P.VpgText5 <> '') then begin
    PL_Print(Auf.P.VpgText5,cPos2a);
    PL_Printline;
  end;
  if (Auf.P.VpgText6 <> '') then begin
    PL_Print(Auf.P.VpgText6,cPos2a);
    PL_Printline;
  end;
  PL_Printline;
end;


//========================================================================
//  BAGDruck
//
//========================================================================
sub BAGDruck();
local begin
  Erx : int;
end;
begin

  PL_PrintLine;
  PL_PrintLine;

  Erx # RecLink(702,700,1,_RecFirst);   // Positionen loopen...
  WHILE (Erx<=_rLocked) DO BEGIN

    // nur BA-Positionen für diesen Auftrag oder FREI
    if ((BAG.P.Auftragsnr<>Auf.P.Nummer) or (BAG.P.Auftragspos<>Auf.P.Position)) and
      (BAG.P.Kommission<>'') then begin
      Erx # RecLink(702,700,1,_RecNext);
      CYCLE;
    end;

    vBAGPrinted # true;

    // -------- Summenreset --------
    vSumStk         # 0;
    vSumGewichtN    # 0.0;
    vSumGewichtB    # 0.0;
    vSumBreite      # 0.0;

    // -------- Einsatz --------
    Erx # RecLink(701,702,2,_RecFirst);
    PrintLohnBA('BAG-Einsatzkopf');
    vGedrucktePos # 0;
    Erx # RecLink(701,702,2,_RecFirst);
    WHILE (Erx <= _rLocked) DO BEGIN
      PrintLohnBA('BAG-Einsatzposition');
      vGedrucktePos #   vGedrucktePos + 1;
      Erx # RecLink(701,702,2,_RecNext);
    END;
    if (vGedrucktePos > 1) then
      PrintLohnBA('BAG-Einsatzfuss');

    PL_Printline;

    // -------- Arbeitsgang --------
    PrintLohnBA('BAG-Arbeitsgang');


    // -------- Fertigungen --------
    vSumBreite    # 0.0;
    vSumStk       # 0;
    vSumgewichtN  # 0.0;

    PrintLohnBA('BAG-Fertigungskopf');
    vGedrucktePos # 0;
    Erx # RecLink(703,702,4,_RecFirst);
    WHILE (Erx <= _rLocked) DO BEGIN
      // ST 2012-10-29: Lohnfertigungen die Eigenmaterial werden, nicht beachten
      if (BAG.F.WirdEigenYN) then begin
        Erx # RecLink(703,702,4,_RecNext);
        CYCLE;
      end;

      PrintLohnBA('BAG-Fertigungsposition');
      vVerpUsed # vVerpUsed + CnvAI(BAG.F.Verpackung,_FmtNumNoGroup | _FmtNumLeadZero,0,5)+';';

      vSumBreite    # vSumBreite + (cnvfi(BAG.F.Streifenanzahl) * BAG.F.Breite);
      vSumStk       # vSumStk + "BAG.F.Stückzahl";
      vSumgewichtN  # vSumGewichtN + BAG.F.Gewicht;

      vGedrucktePos # vGedrucktePos + 1;
      Erx # RecLink(703,702,4,_RecNext);
    END;
    vGedrucktePos # 2;    // zu debugzwecken
    if (vGedrucktePos > 1) then
      PrintLohnBA('BAG-Fertigungsfuss');

    PL_Printline;

    vPosStk # vSumStk; // Errechnete Stückzahl an nächste Auftragspos übergeben

  END; // EO BAG-Positions Loop


end;


//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
  Erx       : int;
  vflag   : int;
end;
begin
  // Daten aus Auftrag holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then begin
      form_FaxNummer  # Adr.Telefax;
      Form_EMA        # Adr.EMail;
      RETURN;
    end;

    if (Scr.B.2.anPartnerYN) and (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      Adr.P.Adressnr # Adr.Nummer;
      Adr.P.Nummer   # cnvia(StrCut(Auf.Best.Bearbeiter,2,3));
      Erx # RecRead(102,1,_recFirst);   // Ansprechpartner holen
      if (Erx>_rLocked) then RETURN;
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,400,12,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,400,2,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      RecLink(100,400,3,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RecLink(100,400,4,_recFirst);   // Rechnungsempf. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      Erx # RecLink(110,400,20,_recFirst);  // Vertreter holen
      if (Erx>_rLocked) then RETURN;
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      Erx # RecLink(110,400,21,_recFirst);  // Verband holen
      if (Erx>_rLocked) then RETURN;
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then RETURN;

    end // Daten aus Auf.

  else begin  // FIXE DATEN !!!

    if (Scr.B.2.anKuLfYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Kunde/Lieferant holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anPartnerYN) then begin
      // fixe Adresse testen...
      if (RecLink(102,921,3,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(102,921,3,_recfirst);   // Partner holen
      RecLink(100,102,1,_recFirsT);   // seine Adresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Lieferort holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      // fixe Adresse testen...
      if (RecLink(101,921,2,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(101,921,2,_recfirst);   // Anschrift holen
      RecLink(100,101,1,_recFirsT);   // Lieferadresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Empfänger holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen

      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      // fixe Adresse testen...
      if (RecLink(110,921,4,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(110,921,4,_recFirst);  // Vertreter  holen
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      // fixe Adresse testen...
      if (RecLink(110,921,4,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(110,921,4,_recFirst);  // Verband  holen
      if(Ver.Adressnummer<>0)then begin
        RecLink(100,110,3,_recFirst);  // Adresse holen
        RecLink(101,100,12,_recFirst); // Hauptanschrift holen
        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end else begin
        Adr.A.Stichwort # Ver.Stichwort;
        Adr.A.Anrede    # Ver.Anrede;
        Adr.A.Name      # Ver.Name;
        Adr.A.Zusatz    # Ver.Zusatz;
        "Adr.A.Straße"  # "Ver.Straße";
        Adr.A.LKZ       # Ver.LKZ;
        Adr.A.PLZ       # Ver.PLZ;
        Adr.A.Ort       # Ver.Ort;
        Adr.A.Telefon   # Ver.Telefon1;
        Adr.A.Telefax   # Ver.Telefax;
        Adr.A.eMail     # Ver.eMail;

        Form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then begin;
      // fixe Adresse testen...
      if (RecLink(101,921,2,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(101,921,2,_recfirst);   // Lagerort holen
      RecLink(100,101,1,_recFirsT);   // Lieferadresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
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
  vBuf100     : int;
  vBuf101     : int;
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;
end;
begin
  vBuf100 # RekSave(100);
  vBuf101 # RekSave(101);
  RecLink(100,400,1,_RecFirst);   // Kunde holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  // SCRIPTLOGIK
  if (Scr.B.Nummer<>0) then HoleEmpfaenger();


  vBesteller # '';
  if ((Auf.Best.Bearbeiter <> '') AND (StrLen(Auf.Best.Bearbeiter) > 4)) then begin
    if (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      vBesteller # StrCut(Auf.Best.Bearbeiter,4,StrLen(Auf.Best.Bearbeiter)-4);
    end;
  end;


  Pls_fontSize # 6
  pls_Fontattr # _WinFontAttrU;
  PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.A.Anrede   , cPos0);
//  Pls_fontSize # 9;
//  PL_Print('Auftragsnummer:',cPosKopf1);
//  PL_PrintI_L(Auf.Nummer,cPosKopf2);
  PL_PrintLine;

  PL_Print(Adr.A.Name     , cPos0);
  Pls_fontSize # 9;
  PL_Print('Auftragsdatum:',cPosKopf1);
  PL_PrintD_L(Auf.Datum,cPosKopf2);
  PL_PrintLine;

  PL_Print(Adr.A.Zusatz   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Customer-No.:',cPosKopf1);
  PL_PrintI_L(Auf.Kundennr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print("Adr.A.Straße" , cPos0);
  Pls_fontSize # 9;
  PL_Print('Delivery-Note:',cPosKopf1);
  PL_Print(Adr.VK.Referenznr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.A.Plz+' '+Adr.A.Ort, cPos0);
  Pls_fontSize # 9;
  PL_Print('VAT-No.:',cPosKopf1);
  PL_Print(vBuf100Re -> Adr.USIdentNr,cPosKopf2);
  PL_PrintLine;

  Erx # RecLink(812,101,2,_recFirst);   // Land holen
  if(Erx > _rLocked) then
    RecBufClear(812);
  Pls_fontSize # 10;
  if ("Lnd.kürzel"<>'D') then
    PL_Print(Lnd.Name.L2, cPos0);
  Pls_fontSize # 9;
  PL_Print('Ihre Steuernr.:',cPosKopf1);
  PL_Print(vBuf100Re -> Adr.Steuernummer,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 9;
  PL_Print('Your order-no:',cPosKopf1);
  PL_Print(Auf.Best.Nummer,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 9;
  PL_Print('Bestelldatum:',cPosKopf1);
  PL_PrintD_L(Auf.Best.Datum,cPosKopf2);
  PL_PrintLine;

  PL_Print('Date:',cPosKopf1);
  PL_PrintD_L(today,cPosKopf2);
  PL_PrintLine;

  PL_Print('Page:',cPosKopf1);
  PL_PrintI_L(aSeite,cPosKopf2);
  PL_PrintLine;


  Pls_FontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  if (Auf.Vorgangstyp = c_AUF) then
    Pl_Print('Acknowledgement'+' '+AInt(Auf.P.Nummer)+'     '+Frm.Markierung ,cPos0);
  if (Auf.Vorgangstyp = c_ANG) then
    Pl_Print('Quotation'+' '+AInt(Auf.P.Nummer)+'     '+Frm.Markierung   ,cPos0);
  pl_PrintLine;

  Pls_FontSize # 9;
  pls_Fontattr # 0;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    PL_PrintLine;
    PL_Print('We would like to thank you for your order, which we confirm to our',cPos0);
    PL_PrintLine;
    PL_Print('terms of business and delivery:',cPos0);
    PL_PrintLine;
    PL_PrintLine;

    //  Warenempfänger bei Abweichung
    Erx # RecLink(101,400,2,_RecFirst);   // Lieferanschrift holen
    if(Erx > _rLocked) then
      RecBufClear(101);

    if (y) then begin
      //(Auf.Lieferadresse <> 0) and
      //((Adr.Nummer <> Auf.Lieferadresse) or
      //((Adr.Nummer = Auf.Lieferadresse) and (Auf.Lieferanschrift > 1))) then begin

      Erx # RecLink(812,101,2,_recFirst);   // Land holen
      if(Erx > _rLocked) then
        RecBufClear(812);

      vText #  StrAdj(Adr.A.Anrede,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ' ' + StrAdj(Adr.A.Name,_StrBegin | _StrEnd)
      else vText # StrAdj(Adr.A.Name,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ' ' + StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd)
      else vText # StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ', ' + StrAdj("Adr.A.Straße",_StrBegin | _StrEnd)
      else vText # StrAdj("Adr.A.Straße",_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ', ' + StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd)
      else vText # StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ' ' + StrAdj(Adr.A.Ort,_StrBegin | _StrEnd)
      else vText # StrAdj(Adr.A.Ort,_StrBegin | _StrEnd);
      if (vText<>'') then vText # vText + ', ' + StrAdj(Lnd.Name.L2,_StrBegin | _StrEnd)
      else vText # StrAdj(Lnd.Name.L2,_StrBegin | _StrEnd);

      // Leerzeichen am Anfang entfernen
      vText   # StrAdj(vText, _StrBegin | _StrEnd);

      PL_Print('Consignee:',cPos0); //Lieferanschrift
      PL_Print(vText,cPosKopf3,cPosKopf3+150.0);
      PL_PrintLine;
      PL_PrintLine;
    end;

    // Kopftext drucken
    vTxtName # '~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K';
    Lib_Print:Print_Text(vTxtName,1, cPos0);
  end; // 1.Seite


  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # y;
    pls_FontSize  # 10;
    PL_Print('Pos.',cPos1);
    PL_Print('Beschreibung',cPos2);
    PL_Print_R('pcs.',cPos3);
    PL_Print_R('Price in '+"Wae.Kürzel",cPos5);
    PL_Print_R('Total',cPos7);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;
  end;

  RekRestore(vBuf100);
  RekRestore(vBuf101);
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
end;
begin


  case aTyp of
    'Artikel' : begin
      //Auf.P.Gesamtpreis # Rnd((Auf.P.Grundpreis + auf.p.aufpreis) *  vPosMenge / CnvFI(Auf.P.PEH) ,2);
      Auf.P.Gesamtpreis # Rnd((Auf.P.Grundpreis) *  vPosMenge / CnvFI(Auf.P.PEH) ,2);
      PL_Print(AInt(Auf.P.Position),cPos1);
      PL_Print(Art.Nummer,cPos2);
      PL_PrintF(Auf.P.Menge.Wunsch,2,cPos3a);
      PL_Print(Auf.P.MEH.Wunsch,cPos3b);
      if (Auf.P.MEH.Wunsch<>Auf.P.MEH.Preis) then begin
        if (Auf.P.MEH.Preis='m') or (Auf.P.MEH.Preis='qm') then
          PL_PrintF(vPosMenge,2,cPos4a)
        else if (Auf.P.MEH.Preis='t') then
          PL_PrintF(vPosMenge,3,cPos4a)
        else
          PL_PrintF(vPosMenge,0,cPos4a)
        PL_Print(Auf.P.MEH.Preis,cPos4b);
      end;
      PL_PrintF(Auf.P.Grundpreis,2,cPos5a);
      PL_Print('je',cPos5a+0.8);
      PL_PrintI(Auf.P.PEH,cPos5b);
      PL_Print(Auf.P.MEH.Preis,cPos5c);
      PL_Print_R(vRb1,cPos6,cPos5c+7.0);
      PL_PrintF(Auf.P.Gesamtpreis,2,cPos7);
      PL_PrintLine;

      // Zeile 2 und folgende
      // Artikelbezeichnungen
      begin

        PLs_FontSize # 8;

        // Bezeichnungen
        if (Art.Bezeichnung1 <> '') then begin
          PL_Print(Art.Bezeichnung1,cPos2);
          PL_PrintLine;
        end;
        if (Art.Bezeichnung2 <> '') then begin
          PL_Print(Art.Bezeichnung2,cPos2);
          PL_PrintLine;
        end;
        if (Art.Bezeichnung3 <> '') then begin
          PL_Print(Art.Bezeichnung3,cPos2);
          PL_PrintLine;
        end;
        if (Auf.P.Bemerkung <> '') then begin
          PL_Print(Auf.P.Bemerkung,cPos2);
          PL_PrintLine;
        end;

        // Artikel Abmessung
        if (Auf.P.AbmessString <> '') then begin
          PL_Print(Auf.P.AbmessString,cPos2);
          PL_PrintLine;
        end;

        // Artikeltext drucken
        Lib_Print:Print_Text('~250.VK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),1, cPos2,cPos8);
      end; // Artikelbezeichnungen


      // Bild ausgeben
      if (Art.Bilddatei<>'') and (Art.Bild.DruckenYN) then begin
        Lib_PrintLine:PrintPic(cPos2,cPos2+50.0,50.0,'*' + Art.Bilddatei);
      end;

    end;  // Artikel  --------------------------------------


    'Artikelrabatte' : begin
      // Aufpreise: MEH-Bezogen
      // Aufpreise: MEH-Bezogen
      // Aufpreise: MEH-Bezogen
      //MEH-Bezogene Aufpreise bei ARTIKEL neben Artikelbeschreibung
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.MengenbezugYN) and
        ((Auf.Z.MEH='%') or (Auf.Z.MEH=Auf.P.MEH.Preis)) then begin
          if (vRb1='') then begin

            // ST 2009-08-14 laut Projekt 1061/286
            if ("Auf.Z.Schlüssel" = '*RAB1') or ("Auf.Z.Schlüssel" = '*RAB2') then
              Auf.Z.Bezeichnung # 'Rabatt';
            // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

            PL_Print_R(Auf.Z.Bezeichnung + ' ' + CnvAF(-Auf.Z.Menge) + ' %',cPos5);
            PL_PrintLine;

          end;
          vRb1 # '';
        end;
        Erx # RecLink(403,401,6,_RecNext);
      END;

/*
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.MengenbezugYN) and
        ((Auf.Z.MEH='%') or (Auf.Z.MEH=Auf.P.MEH.Preis)) then begin
          if (vRb1='') then begin
            if ("Auf.Z.Schlüssel" = '*RAB1') or ("Auf.Z.Schlüssel" = '*RAB2') then
              Auf.Z.Bezeichnung # CnvAF(-Auf.Z.Menge) + ' %';
            // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            PL_Print_R(Auf.Z.Bezeichnung,cPos6,cPos5c+7.0);
            PL_PrintLine;
          end;
          vRb1 # '';
       end;
       Erx # RecLink(403,401,6,_RecNext);
      END;
*/

      if (Auf.P.Projektnummer=0) THEN BEGIN
        // Stückliste Drucken
        Erx # RecLink(409,401,15,_RecFirst);
        WHILE (Erx<=_rLocked) do begin
          if (Auf.P.Artikelnr=Auf.SL.Artikelnr) then begin
            PL_Print(AInt("Auf.SL.Stückzahl")+' a',cPos2+5.0);
            PL_Print_R(cnvAF("Auf.SL.Länge",0,0,0,6) + ' mm',cPos2+30.0);
            end
          else begin
            if ("Auf.SL.Länge"<>0.0) then begin
              PL_Print(AInt("Auf.SL.Stückzahl")+' Stk. von '+Auf.SL.ArtikelNr+' a '+cnvAF("Auf.SL.Länge",0,0,0,6) + ' mm',cPos2+5.0);
              end
            else begin
              PL_Print(AInt("Auf.SL.Stückzahl")+' Stk. von '+Auf.SL.ArtikelNr,cPos2+5.0);
            end;
          end;
          PL_PrintLine;
          Erx # RecLink(409,401,15,_RecNext);
        END;
      end;

      // Verpackungen anhand der Auftragsaufpreise lesen
      Auf.Z.Position  # 0;
      Auf.Z.Position  # 0;
      Erx # RecLink(403,400,13,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        // Artikelaufpreis ?
        If (Auf.Z.Vpg.Artikelnr='') then begin
          Erx # RecLink(403,400,13,_RecNext);
          CYCLE;
        end;

        Art.Nummer # Auf.Z.Vpg.Artikelnr;
        Erx # RecRead(250,1,0);   // Artikel holen
        if (Erx=_rNoRec) then begin
          Erx # RecLink(403,400,13,_RecNext);
          CYCLE;
        end;

        // Verpackungsartikel?
        If (Art.Artikelgruppe = 999) then begin
          // Standardpreis Preis hinterlegt?
          Erx # RecLink(254,250,6,_RecFirst);
          WHILE (Erx <= _rLocked) do begin
            // Standardpreis?
            if (Art.P.Adressnr = 0) then begin
              vVPGPreis # Art.P.Preis;
              vVPGPEH   # Art.P.PEH;
              vVPGMEH   # Art.P.MEH;
            end;

            Erx # RecLink(254,250,6,_RecNext);
          END;

          // Preis für Kunden hinterlegt?
          Erx # RecLink(254,250,6,_RecFirst);
          WHILE (Erx <> _rNoRec) do begin
            if (Art.P.Adressnr = vAdresse) then begin
              vVPGPreis # Art.P.Preis;
              vVPGPEH   # Art.P.PEH;
              vVPGMEH   # Art.P.MEH;
            end;
            Erx # RecLink(254,250,6,_RecNext);
          END;
        end;  // Artikelaufpreis?

        Erx # RecLink(403,400,13,_RecNext);
      END;  // Verpackung

      RecBufClear(403);

      // Drucken Start
      Auf.Z.PEH # vVPGPEH;
      Auf.Z.MEH # vVPGMEH;
      if (Auf.Z.Preis = 0.0) then
        Auf.Z.Preis # vVPGPreis;

      if (Auf.Z.Menge <> 0.0) AND (Auf.Z.PEH <> 0) then begin
        vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
        // Verpackung zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        PL_Print(Auf.Z.Bezeichnung,cPos2);
        if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
          PL_PrintF(Auf.Z.Menge,2,cPos3a)
        else if (Auf.Z.MEH='t') then
          PL_PrintF(Auf.Z.Menge,3,cPos3a)
        else
          PL_PrintF(Auf.Z.Menge,0,cPos3a)
        PL_Print(Auf.Z.MEH,cPos3b);
        PL_PrintF(Auf.Z.Preis,2,cPos5a);
        PL_Print('je',cPos5a+0.8);
        PL_PrintI(Auf.Z.PEH,cPos5b);
        PL_Print(Auf.Z.MEH,cPos5c);
        PL_PrintF(vPreis,2,cPos7);
        PL_Print(Auf.Z.MEH,cPos3b);
        PL_PrintLine;

        vPosNetto # vPosNetto + vPreis;
        if (Auf.Z.RabattierbarYN) then
          vPosNettoRabbar # vPosNettoRabBar + vPreis;
      end;

    end; // Artikelrabatte --------------------------------------------


    'Aufpreise MEH' : begin
      // Aufpreise: MEH-Bezogen
      //MEH-Bezogene Aufpreise bei MATERIAL über zus.Positionsaufpreise

      //if (Auf.P.Wgr.Dateinr>=c_Wgr_Material) and (Auf.P.Wgr.Dateinr<=c_Wgr_bisMaterial) then begin
        Erx # RecLink(403,401,6,_RecFirst);   // Aufpreise loopn
        WHILE (Erx<=_rLocked) do begin
          if /*("Auf.Z.Schlüssel" <> '*RAB1') and ("Auf.Z.Schlüssel" <> '*RAB2') and*/
            ((Auf.Z.MengenbezugYN) and (Auf.Z.MEH=Auf.P.MEH.Preis)) then begin
            if (vFirst) then begin
              PL_PrintLine;
              pls_FontAttr # _WinFontAttrBold;
              //PL_Print('mengenbezogene Positionsaufpreise',cPos2);
              PL_Print('Positionsaufpreise',cPos2);
              pls_FontAttr # 0;
              PL_PrintLine;
              Lib_Print:Print_LinieEinzeln(cPos2,cPos7);
              vFirst # n;
            end;

            Auf.Z.Menge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
            vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
            PL_Print(Auf.Z.Bezeichnung,cPos2);
            PL_PrintF(Auf.Z.Preis,2,cPos5a);
            PL_Print('je',cPos5a+0.8);
            PL_PrintI(Auf.Z.PEH,cPos5b);
            PL_Print(Auf.Z.MEH,cPos5c);
            PL_PrintF(vPreis,2,cPos7);
            PL_PrintLine;


            vGesamtNetto # vGesamtNetto + vPreis;
            vPosNetto    # vPosNetto    + vPreis;
            if (Auf.Z.RabattierbarYN) then
              vPosNettoRabbar # vPosNettoRabBar + vPreis;
          end;
          Erx # RecLink(403,401,6,_RecNext);
        END;
      //end;
    end;  // Aufpreise MEH ------------------------------------

    'Aufpreise %' : begin
      // Aufpreise: MEH-%
      //MEH-Bezogene Aufpreise bei MATERIAL über zus.Positionsaufpreise


      //if (Auf.P.Wgr.Dateinr>=c_Wgr_Material) and (Auf.P.Wgr.Dateinr<=c_Wgr_bisMaterial) then begin
        Erx # RecLink(403,401,6,_RecFirst);   // Aufpreise loopn
        WHILE (Erx<=_rLocked) do begin
          if /*("Auf.Z.Schlüssel" <> '*RAB1') and ("Auf.Z.Schlüssel" <> '*RAB2') and*/
            ((Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%')) then begin
            if (vFirst) then begin
              PL_PrintLine;
              pls_FontAttr # _WinFontAttrBold;
              //PL_Print('mengenbezogene Positionsaufpreise',cPos2);
              PL_Print('Positionsaufpreise',cPos2);
              pls_FontAttr # 0;
              PL_PrintLine;
              Lib_Print:Print_LinieEinzeln(cPos2,cPos7);
              vFirst # n;
            end;

            if ("Auf.Z.Schlüssel" = '*RAB1') or ("Auf.Z.Schlüssel" = '*RAB2') then
              Auf.Z.Bezeichnung # 'Rabatt';

            if (Auf.Z.MEH='%') then begin
              Auf.Z.Preis # vPosNettoRabbar;
              Auf.Z.PEH   # 100;
              vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

              PL_Print(Auf.Z.Bezeichnung,cPos2);
              PL_PrintF(Auf.Z.Menge,2,cPos3a);
              PL_Print(Auf.Z.MEH,cPos3b);
              PL_PrintF(vPreis,2,cPos7);
              PL_PrintLine;
            end


            vGesamtNetto # vGesamtNetto + vPreis;
            vPosNetto    # vPosNetto    + vPreis;
            if (Auf.Z.RabattierbarYN) then
              vPosNettoRabbar # vPosNettoRabBar + vPreis;
          end;
          Erx # RecLink(403,401,6,_RecNext);
        END;
      //end;
    end;  // Aufpreise % ------------------------------------


   'Aufpreise fremd' : begin
      // Aufpreise: fremd MEH-Bezogen

      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.MengenbezugYN) and
          ((Auf.Z.MEH<>'%') and (Auf.Z.MEH<>Auf.P.MEH.Preis)) then begin

          if (vFirst) then begin
            PL_PrintLine;
            pls_FontAttr # _WinFontAttrBold;
            //PL_Print('mengenbezogene Positionsaufpreise',cPos2);
            PL_Print('Positionsaufpreise',cPos2);
            pls_FontAttr # 0;
            PL_PrintLine;
            Lib_Print:Print_LinieEinzeln(cPos2,cPos7);
            vFirst # n;
          end;

          Auf.Z.Menge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
          vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

          // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          PL_Print(Auf.Z.Bezeichnung,cPos2);
          if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
            PL_PrintF(Auf.Z.Menge,2,cPos3a)
          else if (Auf.Z.MEH='t') then
            PL_PrintF(Auf.Z.Menge,3,cPos3a)
          else
            PL_PrintF(Auf.Z.Menge,0,cPos3a)
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintF(Auf.Z.Preis,2,cPos5a);
          PL_Print('je',cPos5a+0.8);
          PL_PrintI(Auf.Z.PEH,cPos5b);
          PL_Print(Auf.Z.MEH,cPos5c);
          PL_PrintF(vPreis,2,cPos7);
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintLine;

          vGesamtNetto # vGesamtNetto + vPreis;
          vPosNetto # vPosNetto + vPreis;
          if (Auf.Z.RabattierbarYN) then
            vPosNettoRabBar # vPosNettoRabBar + vPreis;
        end

        Erx # RecLink(403,401,6,_RecNext);
      END;
    end;  // Aufpreise fremd --------------------------------


    'Aufpreise FIX' : begin
      // Aufpreise: NICHT MEH-Bezogen =FIX

      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.MengenbezugYN=n) and (Auf.Z.Rechnungsnr=0) then begin

          if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,401);

          if (vFirst) then begin
            PL_PrintLine;
            pls_FontAttr # _WinFontAttrBold;
            //PL_Print('mengenbezogene Positionsaufpreise',cPos2);
            PL_Print('Positionsaufpreise',cPos2);
            pls_FontAttr # 0;
            PL_PrintLine;
            Lib_Print:Print_LinieEinzeln(cPos2,cPos7);
            vFirst # n;
          end;

          vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

          // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          PL_Print(Auf.Z.Bezeichnung,cPos2);
          if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
            PL_PrintF(Auf.Z.Menge,2,cPos3a)
          else if (Auf.Z.MEH='t') then
            PL_PrintF(Auf.Z.Menge,3,cPos3a)
          else
            PL_PrintF(Auf.Z.Menge,0,cPos3a)
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintF(Auf.Z.Preis,2,cPos5a);
          PL_Print('je',cPos5a+0.8);
          PL_PrintI(Auf.Z.PEH,cPos5b);
          PL_Print(Auf.Z.MEH,cPos5c);
          PL_PrintF(vPreis,2,cPos7);
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintLine;

          vGesamtNetto # vGesamtNetto + vPreis;
          vPosNetto # vPosNetto + vPreis;
          if (Auf.Z.RabattierbarYN) then
            vPosNettoRabBar # vPosNettoRabBar + vPreis;
        end;
        Erx # RecLink(403,401,6,_RecNext);
      END;
    end;  // Aufpreise FIX  ---------------------------------------


    'AufpreisKopf FIX' : begin
      // KopfAufpreise: NICHT MEH-Bezogen =FIX

      Auf.Z.Position  # 0;
      vKopfAufpreis # vGesamtNetto;
      Erx # RecLink(403,400,13,_RecFirst);
      WHILE (Erx<=_rLocked) do begin

        if (Auf.Z.Position=0) AND (Auf.Z.Nummer = Auf.Nummer)and (Auf.Z.MengenbezugYN=n) and
          (Auf.Z.Rechnungsnr=0) then begin

          if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,400);

          if (Auf.Z.Menge<>0.0) then begin
            if (vFirst) then begin
              PL_PrintLine;
              pls_FontAttr # _WinFontAttrBold;
              PL_Print('zusätzliche Auftragsaufpreise',cPos2);
              pls_FontAttr # 0;
              PL_PrintLine;
              Lib_Print:Print_LinieEinzeln(cPos2,cPos7);
              vFirst # n;
            end;

            vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

            // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            PL_Print(Auf.Z.Bezeichnung,cPos2);
            if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
              PL_PrintF(Auf.Z.Menge,2,cPos3a)
            else if (Auf.Z.MEH='t') then
              PL_PrintF(Auf.Z.Menge,3,cPos3a)
            else
              PL_PrintF(Auf.Z.Menge,0,cPos3a)
            PL_Print(Auf.Z.MEH,cPos3b);
            PL_PrintF(Auf.Z.Preis,2,cPos5a);
            PL_Print('je',cPos5a+0.8);
            PL_PrintI(Auf.Z.PEH,cPos5b);
            PL_Print(Auf.Z.MEH,cPos5c);
            PL_PrintF(vPreis,2,cPos7);
            PL_Print(Auf.Z.MEH,cPos3b);
            PL_PrintLine;

            vGesamtNetto # vGesamtNetto + vPreis;
            vMwstWert1 # vMwstWert1 + vPreis;

            if (Auf.Z.RabattierbarYN) then
              vGesamtNettoRabBar # vGesamtNettoRabBar + vPreis;
          end;
        end;

        Erx # RecLink(403,400,13,_RecNext);
      END;
    end;  // AufpreisKopf FIX ---------------------------


    'AufpreisKopf %' : begin
      // KopfAufpreise: %
      Auf.Z.Nummer    # Auf.Nummer;
      Auf.Z.Position  # 0;
      Erx # RecRead(403,1,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        IF (Auf.Z.Nummer <> Auf.Nummer) or (Auf.Z.Vpg.ArtikelNr <> '') then begin
          /*
            Auf.Z.Position # 0;
            Erx # RecRead(403,1,_RecNext);
            CYCLE;
          */
          BREAK;
        end;

        if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') AND (Auf.Z.Position = 0) AND (Auf.Z.Nummer = Auf.Nummer)then begin
          //Auf.Z.Preis # vGesamtNettoRabBar;
          Auf.Z.Preis # vGesamtNetto;
          Auf.Z.PEH   # 100;
          vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

          // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          PL_Print(Auf.Z.Bezeichnung,cPos2);
          if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
            PL_PrintF(Auf.Z.Menge,2,cPos3a)
          else if (Auf.Z.MEH='t') then
            PL_PrintF(Auf.Z.Menge,3,cPos3a)
          else
            PL_PrintF(Auf.Z.Menge,0,cPos3a)
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintF(Auf.Z.Preis,2,cPos5a);
          PL_Print('je',cPos5a+0.8);
          PL_PrintI(Auf.Z.PEH,cPos5b);
          PL_Print(Auf.Z.MEH,cPos5c);
          PL_PrintF(vPreis,2,cPos7);
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintLine;

          vGesamtNetto # vGesamtNetto + vPreis;
          vMwstWert1 # vMwstWert1 + vPreis;

          if (Auf.Z.RabattierbarYN) then
            vGesamtNettoRabBar # vGesamtNettoRabBar + vPreis;

        end;
        Erx # RecLink(403,400,13,_RecNext);
      END;

      vKopfAufpreis # vGesamtNetto - vKopfAufpreis;
    end;  // AufpreisKopf %


    'Summe' : begin

      // Summen drucken
      pls_Fontsize # 9;
      PL_Print_R('Summe ' + "Wae.Kürzel",cPos7-25.0);
      PL_PrintF(vGesamtNetto,2,cPos7);
      PL_PrintLine;

      pls_Fontsize # 9;
      PL_Print_R(CnvAF(vMwstSatz1) + '% MwSt. '+ "Wae.Kürzel",cPos7-25.0);
      PL_PrintF(vMwstWert1,2,cPos7);
      PL_PrintLine;

      if (vMwstSatz2>0.0) then begin
        pls_Fontsize # 9;
        PL_Print_R(CnvAF(vMwstSatz2) + '% MwSt. '+ "Wae.Kürzel",cPos7-25.0);
        PL_PrintF(vMwstWert2,2,cPos7);
        PL_PrintLine;
      end;

      pls_Fontsize # 9;
      pls_FontAttr # _WinFontAttrBold;
      PL_Print_R('Brutto '+"Wae.Kürzel",cPos7-25.0);
      PL_PrintF(vGesamtBrutto,2,cPos7);
      pls_FontAttr # 0;
      PL_PrintLine;
    end;  // Summe ----------------------------


    'AufpreisKopf MEH' : begin
      // KopfAufpreise: MEH-Bezogen
      Auf.Z.Position  # 0;
      Erx # RecLink(403,400,13,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        IF (Auf.Z.Nummer <> Auf.Nummer) or (Auf.Z.Vpg.ArtikelNr <> '') then begin
    /*
          Auf.Z.Position # 0;
          Erx # RecRead(403,1,_RecNext);
          CYCLE;
    */
          BREAK;
        end;

        if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') and (Auf.Z.Position=0) AND (Auf.Z.Nummer = Auf.Nummer)then begin
          // PosMEH in AufpreisMEH umwandeln
          vMenge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
          vPreis #  Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);

          // Aufpreis zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          PL_Print(Auf.Z.Bezeichnung,cPos2);
          if (Auf.Z.MEH='m') or (Auf.Z.MEH='qm') then
            PL_PrintF(Auf.Z.Menge,2,cPos3a)
          else if (Auf.Z.MEH='t') then
            PL_PrintF(Auf.Z.Menge,3,cPos3a)
          else
            PL_PrintF(Auf.Z.Menge,0,cPos3a)
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintF(Auf.Z.Preis,2,cPos5a);
          PL_Print('je',cPos5a+0.8);
          PL_PrintI(Auf.Z.PEH,cPos5b);
          PL_Print(Auf.Z.MEH,cPos5c);
          PL_PrintF(vPreis,2,cPos7);
          PL_Print(Auf.Z.MEH,cPos3b);
          PL_PrintLine;

          vPosNetto # vPosNetto + vPreis;
          vMwstWert1 # vMwstWert1 + vPreis;

          if (Auf.Z.RabattierbarYN) then
            vPosNettoRabBar # vPosNettoRabBar + vPreis;

        end;
        Erx # RecLink(403,400,13,_RecNext);
      END;
    end;  // AufpriesKopf MEH ----------------------------------


    'Warenempfänger' : begin
      RecLink(100,400,1,_RecFirst);   // Kunde holen
      if (Auf.Lieferadresse <> 0) and ((Adr.Nummer <> Auf.Lieferadresse) or
        ((Adr.Nummer = Auf.Lieferadresse) and (Auf.Lieferanschrift > 1))) then begin

        // Lieferadresse lesen
        RecLink(100,400,12,_RecFirst);
        vWarenempf #  StrAdj(Adr.Anrede,_StrBegin | _StrEnd)    + ' ' +
                      StrAdj(Adr.Name,_StrBegin | _StrEnd)      + ' ' +
                      StrAdj(Adr.Zusatz,_StrBegin | _StrEnd)    + ', '+
                      StrAdj("Adr.Straße",_StrBegin | _StrEnd)  + ', '+
                      StrAdj(Adr.LKZ,_StrBegin | _StrEnd)       + '-' +
                      StrAdj(Adr.PLZ,_StrBegin | _StrEnd)       + ' ' +
                      StrAdj(Adr.Ort,_StrBegin | _StrEnd);
        // ggf. Anschrift lesen
        if (Auf.Lieferanschrift <> 0) then begin
          Adr.A.Adressnr  # Auf.Lieferadresse;
          Adr.A.Nummer    # Auf.Lieferanschrift;
          RecRead(101,1,0);
          vWarenempf  # StrAdj(Adr.A.Anrede,_StrBegin | _StrEnd)  + ' ' +
                        StrAdj(Adr.A.Name,_StrBegin | _StrEnd)    + ' ' +
                        StrAdj(Adr.A.Zusatz,_StrBegin | _StrEnd)  + ', '+
                        StrAdj("Adr.A.Straße",_StrBegin | _StrEnd)+ ', '+
                        StrAdj(Adr.A.LKZ,_StrBegin | _StrEnd)     + '-' +
                        StrAdj(Adr.A.PLZ,_StrBegin | _StrEnd)     + ' ' +
                        StrAdj(Adr.A.Ort,_StrBegin | _StrEnd);
        end;

        // Leerzeichen am Anfang entfernen
        vWarenempf # StrAdj(vWarenempf, _StrBegin | _StrEnd);

        PL_Print('Warenempfänger:',cPos1);
        PL_Print(vWarenempf,cPosFuss2,cPos7);
        PL_PrintLine;
      end;
    end;  // Warenempfänger ------------------------------------


    'Rechnungsempfänger' : begin
      //  Rechungsempfänger bei Abweichung
      if (Auf.Kundennr <> Auf.Rechnungsempf) and (Auf.Rechnungsempf <> 0) then begin

        // RE Empänger lesen
        //RecLink(100,400,4,_RecFirst);
        // Firmenbezeichnung in erste Zeile
        vRechnungsempf #  StrAdj(vBuf100Re -> Adr.Anrede,_StrBegin | _StrEnd)  + ' ' +
                          StrAdj(vBuf100Re -> Adr.Name,_StrBegin | _StrEnd)    + ' ' +
                          StrAdj(vBuf100Re -> Adr.Zusatz,_StrBegin | _StrEnd);
        // Adresse in zweite Zeile
        // Post zum Postfach?
        if (Adr.Postfach <> '') then begin
          vRechnungsempf #  vRechnungsempf                              + ', Postfach ' +
                            StrAdj(vBuf100Re -> Adr.Postfach,_StrBegin | _StrEnd)    + ', '+
                            StrAdj(vBuf100Re -> Adr.Postfach.PLZ,_StrBegin | _StrEnd)+ ' ' +
                            StrAdj(vBuf100Re -> Adr.Ort,_StrBegin | _StrEnd);
          end
        else begin
          vRechnungsempf #  vRechnungsempf                            + ', '+
                            StrAdj(vBuf100Re -> "Adr.Straße",_StrBegin | _StrEnd)  + ', '+
                            StrAdj(vBuf100Re -> Adr.LKZ,_StrBegin | _StrEnd)       + '-' +
                            StrAdj(vBuf100Re -> Adr.PLZ,_StrBegin | _StrEnd)       + ' ' +
                            StrAdj(vBuf100Re -> Adr.Ort,_StrBegin | _StrEnd);
        end;

        PL_Print('Invoice recipient:',cPos1);
        PL_Print(vRechnungsempf,cPosFuss2,cPos7);
        PL_PrintLine;
      end;
    end;  // Rechnungsempfänger ---------------------------------


    'LZB' : begin
      Erx # RecLink(815,400,5,_RecFirst);   // Lieferbedingung lesen
      if(Erx > _rLocked) then
        RecBufClear(815);

      Erx # RecLink(816,400,6,_RecFirst);   // Zahlungsbedingung lesen
      if(Erx > _rLocked) then
        RecBufClear(816);

      Erx # RecLink(817,400,7,_RecFirst);   // Versandart lesen
      if(Erx > _rLocked) then
        RecBufClear(817);

      PL_Print('Terms of shipment:',cPos1);
      PL_Print(Lib.Bezeichnung.L2,cPosFuss2);
      PL_PrintLine;

      PL_Print('Payment:',cPos1);
      vA # Ofp_data:BuildZabString(Zab.Bezeichnung1.L2, 0.0.0,0.0.0);
      PL_Print(vA,cPosFuss2);
      PL_PrintLine;
      if (ZaB.Bezeichnung2.L2<>'') then begin
        PL_Print(Zab.Bezeichnung2.L2,cPosFuss2);
        PL_PrintLine;
      end;
      PL_Print('Shipment:',cPos1);
      PL_Print(Vsa.Bezeichnung.L2,cPosFuss2);
    end;  // LZB -------------------------------

  end;  // case

end;


//========================================================================
//  PrintLohnBA(aTyp : alpha; opt aSum1 : int; opt aSum2 : float; opt aSum3 : float; );
//  Enthält die Ausgaben für die Darstellung von Lohnbetriebsaufträgen
//  Übergabe von Summendaten möglich
//========================================================================
sub PrintLohnBA(aTyp : alpha);
local begin
  Erx       : int;
  vArbeitsgang     : alpha;

  vText     : alpha;

  vVerp     : alpha(1000);
  vFlag     : int;
  vMerker   : alpha;

  vBuf      : int;
end;
begin

  case aTyp of

    //----------- Einsatzmaterial -----------
    'BAG-Einsatzkopf' : begin
      PLS_Fontsize # 8;
      pls_Fontattr # _WinFontAttrBold;
      PL_Print('Einsatzmaterial',cPosE0);
      PL_PrintLine;
      PL_Print_R('Stk',         cPosE1);
      PL_Print('Abmessung',     cPosE2);
      PL_Print('Grade',      cPosE3);

      if (BAG.IO.Materialtyp=200) then begin
        PL_Print_R('Mat.Nr.',     cPosE4);
        PL_Print('Coilnummer',    cPosE5);
      end else
        PL_Print('WV',    cPosE5);

      PL_Print_R('Gew. Brutto', cPosE6);
      PL_Print_R('Gew. Netto',  cPosE7);
      PL_Print_R('Tlg',         cPosE8);
      PL_PrintLine;
      pls_Fontattr # 0;
      Lib_Print:Print_LinieEinzeln(cPosE0,cPosE8+1.0);

      vSumStk         # 0;
      vSumGewichtN    # 0.0;
      vSumGewichtB    # 0.0;

    end;

    // Weiche für die Verschiedenen Einsatztypen
    'BAG-Einsatzposition' : begin
      if (BAG.IO.Materialtyp=200) then
        PrintLohnBA('BAG-Einsatzposition-200');

      if (BAG.IO.Materialtyp=703) then
        PrintLohnBA('BAG-Einsatzposition-703');

     end;

    // Echtes Einsatzmaterial
    'BAG-Einsatzposition-200' : begin
      PLS_Fontsize # 8;
      // Material lesen
        Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen

      PL_PrintI(Mat.Bestand.Stk,  cPosE1);
      // Abmessung
      vText # CnvAf(Mat.Dicke,_FmtNumNoGroup,0,Set.Stellen.Dicke) + ' x ' +
           CnvAf(Mat.Breite,_FmtNumNoGroup,0,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' +
                     CnvAf("Mat.Länge",_FmtNumNoGroup,0,"Set.Stellen.Länge");

      PL_Print(vText + ' mm', cPosE2);


      // Güte
      vText # StrAdj("Mat.Güte",_StrEnd);
      if ("Mat.Gütenstufe" <> '') then
        vText # vText +  ' / ' + StrAdj("Mat.Gütenstufe",_StrEnd);
      PL_Print(vText,cPosE3);

      PL_PrintI(Mat.Nummer,                               cPosE4);
      PL_Print(Mat.Coilnummer,                            cPosE5);
      PL_PrintF(Mat.Gewicht.Brutto, Set.Stellen.Gewicht,  cPosE6);
      PL_PrintF(Mat.Gewicht.Netto, Set.Stellen.Gewicht,   cPosE7);
      PL_PrintI(BAG.IO.Teilungen,cPosE8);
      PL_Printline;

      vSumStk         # vSumStk      + Mat.Bestand.Stk;
      vSumGewichtN    # vSumGewichtN + Mat.Gewicht.Netto;
      vSumGewichtB    # vSumGewichtB + Mat.Gewicht.Brutto;

    end;

    // Weiterverarbeitung aus Vorgänger Fertigung
    'BAG-Einsatzposition-703' : begin
      vBuf # rekSave(701);
      reclink(701,703,3,_recfirst);
      vWtrverb # AInt(bag.io.vonBAG) + '/' + AInt(bag.io.vonPosition) + '/' + AInt(bag.io.vonFertigung);
      RekRestore(vBuf);

      pls_FontSize  # 9;
      PL_PrintI(BAG.IO.Plan.In.Stk,  cPosE1);
      // Abmessung
      vText # CnvAf(BAG.IO.Dicke,_FmtNumNoGroup,0,Set.Stellen.Dicke) + ' x ' +
           CnvAf(BAG.IO.Breite,_FmtNumNoGroup,0,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' +
                     CnvAf("BAG.IO.Länge",_FmtNumNoGroup,0,"Set.Stellen.Länge");
      PL_Print(vText + ' mm', cPosE2);

      // Güte
      vText # StrAdj("BAG.IO.Güte",_StrEnd);
/*
      if ("Mat.Gütenstufe" <> '') then
        vText # vText +  ' / ' + StrAdj("Mat.Gütenstufe",_StrEnd);
*/
      PL_Print(vText,cPosE3);

      PL_Print('aus' + ' ' + vWtrverb,                            cPosE4);
      PL_PrintF(BAG.IO.Plan.In.GewB, Set.Stellen.Gewicht,  cPosE6);
      PL_PrintF(BAG.IO.Plan.In.GewN, Set.Stellen.Gewicht,   cPosE7);
      PL_PrintI(BAG.IO.Teilungen,cPosE8);
      PL_Printline;

      vSumStk         # vSumStk      + BAG.IO.Plan.In.Stk;
      vSumGewichtN    # vSumGewichtN + BAG.IO.Plan.In.GewN;
      vSumGewichtB    # vSumGewichtB + BAG.IO.Plan.In.GewB;

    end;

    'BAG-Einsatzfuss' : begin
      pls_Fontattr # 0;
      Lib_Print:Print_LinieEinzeln(cPosE0,cPosE8+1.0);
      PLS_Fontsize # 8;
      pls_Fontattr # 0;
      PL_PrintI(vSumStk,     cPosE1);
      PL_PrintF(vSumGewichtB,Set.Stellen.Gewicht,  cPosE6);
      PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht,  cPosE7);
      PL_PrintLine;
    end;

    //----------- Arbeitsgang -----------
    'BAG-Arbeitsgang': begin
      // Bearbeitungstyp lesen
      case BAG.P.Aktion of
        c_BAG_Divers  : vArbeitsgang # 'Diverses';
        c_BAG_Fahr    : vArbeitsgang # 'Fahren';
        c_BAG_Kant    : vArbeitsgang # 'Kantenbeareitung';
        c_BAG_Obf     : vArbeitsgang # 'Oberfächenbearbeitung';
        c_BAG_Pack    : vArbeitsgang # 'Verpacken';
        c_BAG_QTeil   : vArbeitsgang # 'Querteilen';
        c_BAG_Spalt   : vArbeitsgang # 'Spalten';
        c_BAG_Split   : vArbeitsgang # 'Splitten';
        c_BAG_Tafel   : vArbeitsgang # 'Tafeln';
        c_BAG_ABCOIL  : vArbeitsgang # 'Abcoilen';
        c_BAG_Check   : vArbeitsgang # 'Prüfen';
        c_BAG_VSB     : vArbeitsgang # 'VSB/Lager';
        c_BAG_Walz    : vArbeitsgang # 'Walzen';
      end;
      vText # vArbeitsgang + ' (BA '+ CnvAi(Bag.P.Nummer, _FmtNumLeadZero | _FmtNumNoGroup)+'/'+
              Cnvai(Bag.P.Position,  _FmtNumLeadZero | _FmtNumNoGroup)  +') : Fertigung pro Einsatz';

      PLS_Fontsize # 8;
      pls_Fontattr # _WinFontAttrBold;
      PL_Print(vText, cPosE0);
      PL_PrintLine;
    end;


    //---------------------------------
    //----------- Fertigung -----------
    //---------------------------------

    //---- Fertigungsköpfe nach Typ ----
    'BAG-Fertigungskopf': begin

      pls_Fontsize # 8;
      pls_Fontattr # _WinFontAttrBold;

      case BAG.P.Aktion of

        c_BAG_Divers  : begin
          PL_Print('Güte',                              cPosF1c);
          PL_Print_R('Dicke',                           cPosF2c);
          PL_Print_R('Breite',                          cPosF3c);
          PL_Print_R('Länge',                           cPosF4c);
          PL_Print('Dickentol.',                        cPosF5c);
          PL_Print('Breitentol.',                       cPosF6c);
          PL_Print('Längentol.',                        cPosF7c);
          PL_Print_R('RID',                             cPosF8c);
          PL_Print_R('RAD',                             cPosF9c);
          PL_Print_R('Stk',                             cPosF10c);
          PL_Print_R('Gew',                             cPosF11c);
          PL_Print_R('Vpg',                             cPosF12c);
        end;

        c_BAG_Fahr    : begin
          PL_Print('Zielort',    cPosF0);
          PL_Print_R('Plan Stk',  cPosF2d);
          PL_Print_R('Plan kg',   cPosF3d);
        end;

        c_BAG_Kant    : begin
          PL_Print_R('Dicke',               cPosF1e);
          PL_Print_R('Breite',              cPosF2e);
          PL_Print('Dickentol.',            cPosF2e);
          PL_Print('Breitentol.',           cPosF3e);
          PL_Print_R('Plan Stk',            cPosF5e);
          PL_Print_R('Plan kg',             cPosF6e);
          PL_Print_R('Vpg',                 cPosF7e);
        end;

        c_BAG_Obf     : begin
          PL_Print('Güte',                cPosF0);
          PL_Print_R('Dicke',             cPosF2f);
          PL_Print('Dickentoleranz',      cPosF2f);
          PL_Print('Ausführung Oben',     cPosF3f);
          PL_Print('Ausführung Unten',    cPosF4f);
          PL_Print_R('Plan Stk',          cPosF6f);
          PL_Print_R('Plan kg',           cPosF7f);
          PL_Print_R('Vpg',               cPosF8f);
        end;

        c_BAG_Pack    : begin
          vArbeitsgang # 'Verpacken';
        end;

        c_BAG_QTeil   : begin
          PL_Print_R('Länge',       cPosF1h);
          PL_Print('Längentoleranz',cPosF1h);
          PL_Print_R('Plan Stk',    cPosF3h);
          PL_Print_R('Plan kg',     cPosF4h);
          PL_Print_R('Vpg',         cPosF5h);
        end;

        c_BAG_Spalt   : begin
          PL_Print_R( 'Anz',      cPosF1a);
          PL_Print_R( 'Breite',    cPosF2a);
          PL_Print(   'Toleranz',  cPosF3a);
          PL_Print_R( 'Plan Stk',  cPosF4a);
          PL_Print_R( 'Plan kg',   cPosF5a);
          PL_Print_R( 'Vpg',       cPosF6a);
        end;

        c_BAG_Split   : begin
          PL_Print_R('Plan Stk',  cPosF1i);
          PL_Print_R('Plan kg',   cPosF2i);
          PL_Print_R('Vpg',       cPosF3i);
        end;

        c_BAG_Tafel   : begin
          PL_Print_R('Anzahl',    cPosF1b);
          PL_Print_R('Breite',    cPosF2b);
          PL_Print_R('Länge',    cPosF3b);
          PL_Print('Breitentoleranz', cPosF4b);
          PL_Print('Längentoleranz',    cPosF5b);
          PL_Print_R('Plan Stk',  cPosF6b);
          PL_Print_R('Plan kg',   cPosF7b);
          PL_Print_R('Vpg',       cPosF8b);
        end;

        c_BAG_ABCOIL  : begin
          PL_Print_R('Anz',              cPosF1k);
          PL_Print_R('Breite',            cPosF2k);
          PL_Print_R('Länge',             cPosF3k);
          PL_Print(  'Breitentoleranz',   cPosF4k);
          PL_Print(  'Längentoleranz',    cPosF5k);
          PL_Print_R('Plan Stk',          cPosF6k);
          PL_Print_R('Plan kg',           cPosF7k);
          PL_Print_R('Vpg',               cPosF8k);
        end;

        c_BAG_Check   : begin
          vArbeitsgang # 'Prüfen';
        end;

        c_BAG_Walz    : begin
          PL_Print_R('Dicke',    cPosF1j);
          PL_Print_R('Breite',    cPosF2j);
          PL_Print('Dickentoleranz',    cPosF2j);
          PL_Print('Breitentoleranz',    cPosF3j);
          PL_Print('Ausf. Oben',    cPosF4j);
          PL_Print('Ausf. Unten',    cPosF5j);
          PL_Print_R('Plan Stk',  cPosF7j);
          PL_Print_R('Plan kg',   cPosF8j);
          PL_Print_R('Vpg',       cPosF9j);
        end;

      end;  // EO Aktionstyp

      PL_PrintLine;
      pls_Fontattr # 0;
      Lib_Print:Print_LinieEinzeln(cPosE0,cPosE8+1.0);

    end; // EO BA-Fertigungskopf


    //---- Fertigungspositionen nach Typ ----
    'BAG-Fertigungsposition': begin
      pls_Fontattr # 0;

      case BAG.P.Aktion of

        c_BAG_Divers  : begin
          PL_Print("BAG.F.Güte",                        cPosF1c);
          PL_PrintF(BAG.F.Dicke, Set.Stellen.Dicke,     cPosF2c);
          PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF3c);
          PL_PrintF("BAG.F.Länge", "Set.Stellen.Länge", cPosF4c);
          PL_Print(BAG.F.DickenTol,                     cPosF5c);
          PL_Print(BAG.F.BreitenTol,                    cPosF6c);
          PL_Print("BAG.F.LängenTol",                   cPosF7c);
          PL_PrintF(BAG.F.RID,2,                        cPosF8c);
          PL_PrintF(BAG.F.RAD,2,                        cPosF9c);
          PL_PrintI("BAG.F.Stückzahl",                  cPosF10c);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF11c);
          PL_PrintI(BAG.F.Verpackung,                   cPosF12c);
        end;

        c_BAG_Fahr    : begin
          RecLink(100,702,12,_recfirst);
          PL_Print(Adr.Stichwort,                       cPosF0);
          PL_PrintI("BAG.F.Stückzahl",                  cPosF2d);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF3d);
          PL_PrintI(BAG.F.Verpackung,                   cPosF4d);
        end;

        c_BAG_Kant    : begin
          PL_PrintF(BAG.F.Dicke, Set.Stellen.Dicke,     cPosF1e);
          PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2e);
          PL_Print(BAG.F.DickenTol,                     cPosF2e);
          PL_Print(BAG.F.BreitenTol,                    cPosF3e);
          PL_PrintI("BAG.F.Stückzahl",                  cPosF5e);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF6e);
          PL_PrintI(BAG.F.Verpackung,                   cPosF7e);
        end;

        c_BAG_Obf     : begin
          PL_Print("BAG.F.Güte",                        cPosF0);
          PL_PrintF(BAG.F.Dicke, Set.Stellen.Dicke,     cPosF2f);
          PL_Print(BAG.F.DickenTol,                     cPosF2f);
          PL_Print(BAG.F.AusfOben,                      cPosF3f);
          PL_Print(BAG.F.AusfOben,                      cPosF4f);
          PL_PrintI("BAG.F.Stückzahl",                  cPosF6f);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF7f);
          PL_PrintI(BAG.F.Verpackung,                   cPosF8f);
        end;

        c_BAG_Pack    : begin
          vArbeitsgang # 'Verpacken';
        end;

        c_BAG_QTeil   : begin
          PL_PrintF("BAG.F.Länge", "Set.Stellen.Länge", cPosF1h);
          PL_Print("BAG.F.LängenTol",                   cPosF1h);
          PL_PrintI("BAG.F.Stückzahl",                  cPosF3h);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF4h);
          PL_PrintI(BAG.F.Verpackung,                   cPosF5h);
        end;

        c_BAG_Spalt   : begin
          PL_PrintI(BAG.F.StreifenAnzahl,               cPosF1a);
          PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2a);
          PL_Print(BAG.F.BreitenTol,                    cPosF3a);
          PL_PrintI("BAG.F.Stückzahl",                  cPosF4a);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF5a);
          PL_PrintI(BAG.F.Verpackung,                   cPosF6a);

        end;

        c_BAG_Split   : begin
          PL_PrintI("BAG.F.Stückzahl",                  cPosF1i);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF2i);
          PL_PrintI(BAG.F.Verpackung,                   cPosF3i);
        end;

        c_BAG_Tafel   : begin
          PL_PrintI(BAG.F.StreifenAnzahl,               cPosF1b);
          PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2b);
          PL_PrintF("BAG.F.Länge", "Set.Stellen.Länge", cPosF3b);
          PL_Print(BAG.F.BreitenTol,                    cPosF4b);
          PL_Print("BAG.F.LängenTol",                   cPosF5b);
          PL_PrintI("BAG.F.Stückzahl",                  cPosF6b);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF7b);
          PL_PrintI(BAG.F.Verpackung,                   cPosF8b);
          vSumLaenge    # vSumLaenge + (cnvfi("BAG.F.Stückzahl") / cnvfi(BAG.F.Streifenanzahl)*"BAG.F.Länge");
        end;

        c_BAG_ABCOIL  : begin
          PL_PrintI(BAG.F.StreifenAnzahl,               cPosF1k);
          PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2k);
          PL_PrintF("BAG.F.Länge", "Set.Stellen.Länge", cPosF3k);
          PL_Print(BAG.F.BreitenTol,                    cPosF4k);
          PL_Print("BAG.F.LängenTol",                   cPosF5k);
          PL_PrintI("BAG.F.Stückzahl",                  cPosF6k);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF7k);
          PL_PrintI(BAG.F.Verpackung,                   cPosF8k);

          vSumLaenge    # vSumLaenge + (cnvfi("BAG.F.Stückzahl") / cnvfi(BAG.F.Streifenanzahl)*"BAG.F.Länge");
        end;

        c_BAG_Check   : begin
          vArbeitsgang # 'Prüfen';
        end;

        c_BAG_VSB     : begin
          vArbeitsgang # 'VSB/Lager';
        end;

        c_BAG_Walz    : begin
          PL_PrintF(BAG.F.Dicke,  Set.Stellen.Dicke,    cPosF1j);
          PL_PrintF(BAG.F.Breite, Set.Stellen.Breite,   cPosF2j);
          PL_Print(BAG.F.DickenTol,                     cPosF2j);
          PL_Print("BAG.F.BreitenTol",                  cPosF3j);
          PL_Print(BAG.F.AusfOben,                      cPosF4f);
          PL_Print(BAG.F.AusfOben,                      cPosF5f);
          PL_PrintI("BAG.F.Stückzahl",                  cPosF7j);
          PL_PrintF(BAG.F.Gewicht, Set.Stellen.Gewicht, cPosF8j);
          PL_PrintI(BAG.F.Verpackung,                   cPosF9j);
        end;

      end;  // EO Aktionstyp

      PL_PrintLine;

    end;


    //---- Fertigungsfüße nach Typ ----
    'BAG-Fertigungsfuss': begin
      pls_Fontattr # 0;
      Lib_Print:Print_LinieEinzeln(cPosE0,cPosE8+1.0);
      PLS_Fontsize # 8;


      case BAG.P.Aktion of

        c_BAG_Divers  : begin
          PL_PrintI(vSumStk   ,                       cPosF10c);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF11c);

        end;

        c_BAG_Fahr    : begin
          PL_Printi(vSumStk   ,                       cPosF2d);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF3d);
        end;

        c_BAG_Kant    : begin
          PL_Printi(vSumStk   ,                       cPosF5e);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF6e);
        end;

        c_BAG_Obf     : begin
          PL_PrintI(vSumStk   ,                       cPosF6f);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF7f);
        end;

        c_BAG_Pack    : begin
          vArbeitsgang # 'Verpacken';
        end;

        c_BAG_QTeil   : begin
          PL_Printi(vSumStk   ,                       cPosF3h);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF4h);
        end;

        c_BAG_Spalt   : begin
          PL_Printf(vSumBreite,Set.Stellen.Breite,    cPosF2a);
          PL_Printi(vSumStk   ,                       cPosF4a);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF5a);
        end;

        c_BAG_Split   : begin
          PL_Printi(vSumStk   ,                       cPosF2i);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF3i);
        end;

        c_BAG_Tafel   : begin
          PL_PrintF(vSumBreite, Set.Stellen.Breite,   cPosF2b);
          PL_PrintF(vSumLaenge, "Set.Stellen.Länge",   cPosF3b);
          PL_Printi(vSumStk   ,                       cPosF6b);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF7b);
        end;

        c_BAG_ABCOIL  : begin
          PL_PrintF(vSumBreite, Set.Stellen.Breite,   cPosF2k);
          PL_PrintF(vSumLaenge, "Set.Stellen.Länge",  cPosF3k);
          PL_Printi(vSumStk   ,                       cPosF6k);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF7k);
        end;

        c_BAG_Check   : begin
          vArbeitsgang # 'Prüfen';
        end;

        c_BAG_VSB     : begin
          vArbeitsgang # 'VSB/Lager';
        end;

        c_BAG_Walz    : begin
          PL_Printi(vSumStk   ,                       cPosF7j);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF8j);
        end;

      end;  // EO Aktionstyp

      PL_PrintLine;
    end;

    //----------- Verpackung -----------
    'BAG-Verpackungskopf': begin
      PLS_Fontsize # 8;
      pls_Fontattr # _WinFontAttrBold;
      PL_Print('BA-Verpackungsvorschriften',cPosV0);
      PL_PrintLine;
      PL_Print_R('Nr.',         cPosV1);
      PL_Print('Beschreibung',   cPosV2);
      PL_PrintLine;
      pls_Fontattr # 0;
      Lib_Print:Print_LinieEinzeln(cPosV0,cPosV2Ende);
      vZeilenZahl # 0;
    end;

    'BAG-Verpackungsposition': begin
      PLS_Fontsize # 8;
      pls_Fontattr # 0;
      PL_PrintI(BAG.Vpg.Verpackung,cPosV1);

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
            ADD_VERP('Verwiegungsart: ',VwA.Bezeichnung.L2);
          end;
        END;
      end;


      PL_Print(vVerp,cPosV2,cPosV2Ende);
      PL_Printline;
      vZeilenZahl # vZeilenZahl + 1;

      if (BAG.Vpg.VpgText1 <> '') then begin
        PL_Print(BAG.Vpg.VpgText1,cPosV2);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText2 <> '') then begin
        PL_Print(BAG.Vpg.VpgText2,cPosV2);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText3 <> '') then begin
        PL_Print(BAG.Vpg.VpgText3,cPosV2);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText4 <> '') then begin
        PL_Print(BAG.Vpg.VpgText4,cPosV2);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText5 <> '') then begin
        PL_Print(BAG.Vpg.VpgText5,cPosV2);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;
      if (BAG.Vpg.VpgText6 <> '') then begin
        PL_Print(BAG.Vpg.VpgText6,cPosV2);
        PL_Printline;
        vZeilenZahl # vZeilenZahl + 1;
      end;


    end;

    'BAG-Verpackungsfuss': begin
      pls_Fontattr # 0;
      PLS_Fontsize # 8;
      Lib_Print:Print_LinieEinzeln(cPosV0,cPosV2Ende);
    end;


  end; // EO case aTyp of

end; // EO sub PrintLohnBA(aTyp : alpha);


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  // Datenspezifische Variablen
  vTxtName            : alpha;

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;

  vFlag               : int;        // Datensatzlese option
  vTxtHdl             : int;
end;
begin
  // ------ Druck vorbereiten ----------------------------------------------------------------
  Erx # RecLink(100,400,1,_RecFirst);   // Kunde holen
  if(Erx > _rLocked) then
    RecBufClear(100);

  Erx # RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if(Erx > _rLocked) then
    RecBufClear(101);

  Erx # RecLink(814,400,8,_RecFirst);   // Währung holen
  if(Erx > _rLocked) then
    RecBufClear(814);

  vBAGPrinted # false;

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (  Lib_Print:FrmJobOpen(y, vHeader ,vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Form_Lang # 'E'; // Sprache setzen

  // ARCFLOW
  //DMS_ArcFlow:SetDokName('!SC\Verkauf','AB',Auf.Nummer);

// ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();

  vAdresse    # Adr.Nummer;
  vMwstSatz1 # -1.0;
  vMwstSatz2 # -1.0;

// ------- POSITIONEN --------------------------------------------------------------------------

  vFlag # _RecFirst;
  WHILE (RecLink(401,400,9,vFlag) <= _rLocked ) DO BEGIN
    vFlag # _RecNext;

    if ("Auf.P.Löschmarker"='*') then CYCLE;

    // Positionstyp bestimmen
    Erx # RecLink(819,401,1,0);     // Warengruppe holen
    if (Erx > _rLocked) then CYCLE;
    RecLink(835,401,5,_recFirst);   // Auftragsart holen

    RecBufClear(250);
    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
      Erx # RecLink(250,401,2,_RecFirst); // Artikel holen
      If (Erx = _rNoRec) then CYCLE
    end
    else if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false) then CYCLE;

    // Position ausgeben.....
    Inc(vPosCount);

    if (Auf.P.MEH.Wunsch = Auf.P.MEH.Preis) then begin
      vPosMenge # Auf.P.Menge.Wunsch;
      end
    else begin
      vPosMenge # Lib_Einheiten:WandleMEH(401, 0, Auf.P.Gewicht, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, Auf.P.MEH.Preis);
    end;


    // Position zusammenbauen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // ARTIKEL DRUCKEN
    if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
      Print('Artikel');
    end;  // ARTIKELDRUCK


    vPosMwSt        # 0.0;
    vPosAnzahlAkt   # 0;
    vPosGewicht     # Auf.P.Gewicht;
    vPosStk         # "Auf.P.Stückzahl";
    vPosNettoRabBar # Auf.P.Gesamtpreis;
    vPosNetto       # Auf.P.Gesamtpreis;

    // MATERIALDRUCK
    if ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr))) then begin
      if (AAr.Berechnungsart>=700) then
        MaterialDruck_Lohn(vRb1, Auf.P.Menge.Wunsch, vPosMenge, vPosStk)
      else
        MaterialDruck(vRb1, Auf.P.Menge.Wunsch, vPosMenge, vPosStk);
    end;


    // Positionstext ausgeben
    vTxtName # '';
    PLs_FontSize # 8;
    if (Auf.P.TextNr1=400) then // anderer Positionstext
      vTxtName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (Auf.P.TextNr1=0) and (Auf.P.TextNr2 != 0) then   // Standardtext
      vTxtName # '~837.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
    if (Auf.P.TextNr1=401) then // Individuell
      vTxtName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (vTxtName != '') then
      Lib_Print:Print_Text(vTxtName,1,cPos2);  // drucken
/*
    ST 2009-08-13: WIRD JETZT BEIM ARTIKEL GEDRUCKT
    // Stammdatentext drucken
    if (Art.Nummer<>'') then begin
      vTxtHdl # TextOpen(10);
      Lib_Texte:TxtLoad5Buf('~250.VK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
        vTxtHdl, 0,0,0,0);
      Lib_Print:Print_TextBuffer(vTxtHdl);  // drucken
      TextClose(vTxtHdl);
      //Lib_Print:Print_Text('~250.VK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),1, cPos2);  // drucken
    end;
*/

    if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
      //Print('Artikelrabatte');
    end;



    //========================================================================
    // Aufpreise
    //    Reihenfolge:
    //      1. Grundpreis
    //      2. + mengenbezogene Positionsaufpreise
    //      3. + pauschale (nicht mengenbezogen) Positionsaufpreise
    //      4. + prozentuale Positionsaufpreise
    //      5. + mengenbezogene Kopfaufpreise
    //      -> Positionssumme
    //      6. + pauschale Kopfaufpreise
    //      7. + prozentuale Kopfaufpreise
    //      -> Endsumme
    //========================================================================
    Print('Aufpreise MEH');
    Print('Aufpreise fremd');
    Print('Aufpreise FIX');
    Print('Aufpreise %');



    // Lohngeschäft...
    if (AAr.Berechnungsart>=700) then begin

      RecBufClear(700);
      Erx # RecLink(404,401,12,_RecFirst);
      WHILE (Erx <= _rLocked) do begin   // Aktionen loopen
        if (Auf.A.Aktionstyp=c_Akt_BA) then begin
          BAG.Nummer # Auf.A.Aktionsnr;
          Erx # RecRead(700,1,0);
          if (Erx <=_rLocked) then begin
           BAGDruck();
          end;
        end;
        Erx # RecLink(404,401,12,_RecNext);
      END;

    end;


    // Mehrwertsteuersätze
    StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
    Erx # RecRead(813,1,0);
    if (Erx>_rLocked) then RecBufClear(813);
    vPosMwst # StS.Prozent;
    if (vMwstSatz1=-1.0) then begin
      vMwstSatz1 # vPosMwSt;
      vMwstWert1 # vPosNetto;
      end
    else if (vMwstSatz1=vPosMwst) then begin
      vMwstWert1 # vMwstWert1 + vPosNetto;
      end
    else if (vMwstSatz2=-1.0) then begin
      vMwstSatz2 # vPosMwSt;
      vMwstWert2 # vPosNetto;
      end
    else if (vMwstSatz2=vPosMwst) then begin
      vMwstWert2 # vMwstWert2 + vPosNetto;
    end;

    // Positionszusatz ausgeben
    vGesamtNettoRabBar  # vGesamtNettoRabBar + vPosNettoRabBar;
    //vGesamtNetto        # vGesamtNetto + vPosNetto;

    // Leerzeile zwischen den Positionen
    PL_PrintLine;

  END; // WHILE: Positionen ************************************************

  // Falls ein BA gedruckt wurde, dann einmalig die Verpackung drucken
  if (vBAGPrinted) then begin
    // -------- Verpackung --------
    PrintLohnBA('BAG-Verpackungskopf');
    vGedrucktePos # 0;
    Erx # RecLink(704,700,2,_RecFirst);
    WHILE (Erx <= _rLocked) DO BEGIN
      vVerpCheck # CnvAI(BAG.Vpg.Verpackung,_FmtNumNoGroup | _FmtNumLeadZero,0,5)+';';
      if (StrFind(vVerpUsed,vVerpCheck,0) > 0) then
        PrintLohnBA('BAG-Verpackungsposition');

      vGedrucktePos # vGedrucktePos + 1;
      Erx # RecLink(704,700,2,_RecNext);
    END;

    if (vGedrucktePos > 1) then
      PrintLohnBA('BAG-Verpackungsfuss');
    PL_Printline;
  end;

  // Kopfaufpreise drucken...
  Print('AufpreisKopf FIX');
  Print('AufpreisKopf %');
  Print('AufpreisKopf MEH');


  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';
  // 100 MM Rand unten lassen für den Fuss
  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(110.0,_PrtUnitMillimetres)) do
    PL_PrintLine;
  Lib_Print:Print_LinieDoppelt();

  // Mehrwertstuern errechnen
  if (vMwStSatz1<>0.0) then vMwStWert1 # Rnd(vMwstWert1 * (vMwstSatz1/100.0),2)
  else vMwStWert1 # 0.0;
  if (vMwStSatz2>0.0) then vMwStWert2 # Rnd(vMwstWert2 * (vMwstSatz2/100.0),2)
  else vMwStWert2 # 0.0;
  vGesamtBrutto # Rnd(vGesamtNetto + vMwstWert1 + vMwstWert2,2);

  Print('Summe');
  PL_PrintLine;
  Print('LZB');
  Print('Rechnungsempfänger');
  PL_PrintLine;
  Print('Warenempfänger');
  PL_PrintLine;

  // Fusstext drucken
  vTxtName # '~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F';
  Lib_Print:Print_Text(vTxtName,1, cPos1, cPos7);

  PL_PrintLine;
  PL_PrintLine;
  PL_Print('mit freundlichen Grüßen',cPos1);
  PL_PrintLine;

// -------- Druck beenden ----------------------------------------------------------------

  if(HdlInfo(vBuf100Re, _HdlExists) > 0) then
    RecBufDestroy(vBuf100Re);

  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;


//=======================================================================