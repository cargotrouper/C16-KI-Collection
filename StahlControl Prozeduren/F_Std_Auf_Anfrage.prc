@A+
//===== Business-Control =================================================
//
//  Prozedur    F_Std_AUF_Anfrage
//                    OHNE E_R_G
//  Info
//    Druckt eine Anfrage aus mehreren markierten Auftragspositionen
//    an ALLE markierten Lieferanten(Adressen)
//    // wenn fertig - STANDARD //
//
//  21.08.2012  TM  Erstellung der Prozedur aus F_Std_Auf_AufBest
//  25.09.2012  TM  Fertiggestellte Prozedur in Entwicklungssystem übertragen
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB HoleEmpfaenger();
//    SUB Print_Chem(aName : alpha; aName2 : alpha; pMin : float; pMax : float);
//    SUB Print_Mech(Name : alpha; pMin : float; pMax : float; Einheit : alpha;);
//    SUB getSondertext(aText : alpha; aKeyWord : alpha) : alpha;
//    SUB FilterSondertext(aText : alpha; aKeyWord : alpha) : alpha;
//    SUB Print_Mat(aRb1 : alpha; aWMenge : float; aPMenge : float; aStk : int);
//    SUB Print_MatLohn(aRb1 : alpha; aWMenge : float; aPMenge : float; aStk : int);
//    SUB Print_BAG();
//    SUB Print_Fusstext(aKeyWordBegin : alpha; aKeyWordEnd : alpha; aVonPos : float; aBisPos : float; opt aBadWordBegin : alpha; opt aBadWordEnd : alpha; opt aPrintAllgemeinenText : logic);
//    SUB Print_FaxCode();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aTyp : alpha);
//
//    MAIN
//
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG
@I:Def_Aktionen


declare Print(aTyp : alpha);
declare PrintLohnBA(aTyp : alpha);


define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,cnvAI(b),0,0,0); RETURN false; end;
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;

  cPosAdr :  10.0

  cAbstandChemie  : 34

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

  // Position (Content)
  cPosCR   :189.0            // Rechter Rand
  cPosCL   : 10.0            // Linker Rand
  cPosC0   : 18.0            // Pos
  cPosC1   : cPosC0  +  1.0   // Guete
  cPosC2   : cPosC1  + 23.0  // :
  cPosC3   : cPosC2  + 17.0  // Zahlenwert rechtsbuendig
  cPosC3L  : cPosC2  + 3.0   // Alphawert linksbuendig
  cPosC4   : cPosC3  + 2.0   // mm
  cPosC5   : cPosC4  + 8.0   // /
  cPosC6   : cPosC5  + 3.0   // Ausfuehrung
  cPosC7   : cPosC6  + 29.0  // Toleranz (Werte) rechtbuendig
  cPosC8   : cPosC7  + 2.0   // mm
  cPosC9   : cPosC8  +  9.0  // Stueck
  cPosC10  : cPosC9  + 20.0  // Gew. kg
  cPosC11  : cPosC10 + 27.0  // EUR Preis
  cPosC12  : cPosC11 + 9.0   // von / bis
  cPosC13  : cPosC12 + 1.0   // ca.Termin
  cPosC14  : cPosC13 + 23.0  // Linie ENDE
  cPosC15  : cPosC14 + 20.0
  cPosC16  : cPosC15 + 20.0

  // Fuss (Bottom)
  cPosB0  : 10.0
  cPosB1  : cPosB0 + 20.0    // :
  cPosB2  : cPosB1 + 5.0
  cPosB3  : cPosB2 + 20.0
  cPosB4  : cPosB3 + 20.0
  cPosB5  : cPosB4 + 20.0
  cPosB6  : cPosB5 + 20.0
  cPosB7  : cPosB6 + 20.0
  cPosB8  : cPosB7 + 20.0
  cPosB9  : cPosB8 + 20.0

  // Kopf (Head)
  cPosH0  : 10.0
  cPosH1  : cPosH0 + 110.0
  cPosH2  : cPosH1 + 30.0
  cPosH3  : cPosH2 + 3.0
  cPosH4  : cPosH3 + 20.0

  // Bestellnummern
  cPosBest0   : 10.0
  cPosBest0.1 : 27.0
  cPosBest0.2 : 30.0
  cPosBest1   : cPosBest0 + 70.0
  cPosBest1.1 : cPosBest0 + 81.0
  cPosBest1.2 : cPosBest0 + 87.0
  cPosBest2   : cPosBest1 + 60.0
  cPosBest2.1 : cPosBest1 + 77.0
  cPosBest2.2 : cPosBest1 + 87.0

  // Aufpreise
  cPosA0  : 10.0 // Bez
  cPosA1  : cPosA0 + 124.0 // Menge
  cPosA2  : cPosA1 + 15.0
  cPosA3  : cPosA2 + 20.0
  cPosA4  : cPosA3 + 20.0
  cPosA5  : cPosA4 + 20.0
  cPosA6  : cPosA5 + 0.0
  cPosA7  : cPosA6 + 0.0
  cPosA8  : cPosA7 + 0.0
  cPosA9  : cPosA8 + 0.0

  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cPosKopf3 : 47.0  // Feld Warenempf

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0

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

  //Tafeln
  cPosF1b   : cPosF0  + 7.0  // Anzahl
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
  cPosF5f   : cPosF4f + 55.0  // Ausführung
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

end;

local begin
  vZeilenZahl         : int;
  vCoord              : float;
  vSumStk             : int;
  vSumGewichtN        : float;
  vSumGewichtB        : float;
  vSumBreite          : float;
  vSumLaenge          : float;
  vGesamtGewicht      : float;

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
  vWtrverb            : alpha;

  // Lohnbearbeitung
  vGedrucktePos       : int;
  vVerpCheck          : alpha;
  vVerpUsed           : alpha;
  vBAGPrinted         : logic;
  vMinRadYN           : logic;

  // Für Anfrage-Markierungen (Auf.P. und Adr.)
  vItem               : int;
  vMFile              : int;
  vMID                : int;
  vLieferantenOK      : alpha(4000);
  vAuftragsPosOK      : alpha(4000);

  // AnfrageNummernkreis und Speicherung im Dokumentensystem
  vAnfrageNr          : int;
  vAnfragePos         : int;
  vOK                 : logic;

  // Für Textbausteine in richtiger Sprache
  vTxtHdlTmp1         : int;
  vTxtHdlTmp2         : int;
  vTxtHdlTmp3         : int;
  vTxtHdlTmp4         : int;
  vTxtHdlTmp5         : int;
  vTxtHdlName         : alpha;
  vTxtHdlTmpRTF       : int;
  vTree               : int;
  vSortKey            : alpha;

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
  // RecLink(100,400,1,_RecFirst);   // Kunde holen
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN cnvAI(vAnfrageNr,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
end;


//========================================================================
//   GetLiBText
//
//========================================================================
sub GetLiBText(aText : alpha;) : alpha;
local begin
  vText     : alpha(4000);
  vHdl      : int;
  vI        : int;
end;
begin
  vHdl # TextOpen(10);
  Lib_Texte:TxtLoad5Buf(aText, vHdl, 0 , 0, 0 , 0);
  //TextRead(vHdl, aText, 0);
  vI # 1;
  vText # '';
  WHILE (TextInfo(vHdl, _TextLines) >= vI) DO BEGIN
    Lib_Strings:Append(var vText, TextLineRead(vHdl, vI, 0), ' ');
    vI # vI + 1;
  END;

  TextClose(vHdl);

  RETURN vText;
end;


//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
  Erx           : int;
  vflag   : int;
end;
begin
  // Daten aus Auftrag holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then RETURN;

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
      // RecLink(100,400,12,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      // RecLink(101,400,2,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
      // RecLink(100,400,3,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      // RecLink(100,400,4,_recFirst);   // Rechnungsempf. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      Erx # RecLink(110,400,20,_recFirst);  // Vertreter holen
      if (Erx>_rLocked) then RETURN;
      if(Ver.Adressnummer<>0)then begin
        // RecLink(100,110,3,_recFirst);  // Adresse holen
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
        // RecLink(100,110,3,_recFirst);  // Adresse holen
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
      // if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      // RecLink(100,921,1,_recFirst);   // Kunde/Lieferant holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anPartnerYN) then begin
      // fixe Adresse testen...
      if (RecLink(102,921,3,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(102,921,3,_recfirst);   // Partner holen
      // RecLink(100,102,1,_recFirsT);   // seine Adresse holen
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
      // RecLink(100,921,1,_recFirst);   // Lieferort holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      // fixe Adresse testen...
      if (RecLink(101,921,2,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(101,921,2,_recfirst);   // Anschrift holen
      // RecLink(100,101,1,_recFirsT);   // Lieferadresse holen
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
      // RecLink(100,921,1,_recFirst);   // Verbraucher holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      // fixe Adresse testen...
      // if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      // RecLink(100,921,1,_recFirst);   // Empfänger holen
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
        // RecLink(100,110,3,_recFirst);  // Adresse holen
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
        // RecLink(100,110,3,_recFirst);  // Adresse holen
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
      // RecLink(100,101,1,_recFirsT);   // Lieferadresse holen
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
//   Print_Chem
//            Fügt eine Zeile chemischer Analyse zum Formular hinzu
//            Wird nur benötigt für MaterialDruck()
//            Argumente:
//                Name  Name des Elements
//                pMin     1. Wert
//                pMax     2. Wert
//========================================================================
sub Print_Chem(
  aName   : alpha;
  aName2  : alpha;
  pMin    : float;
  pMax    : float);
begin

  if (aName2<>'') then aName # aName2;

  //GV.Int.01 ist die Aktuelle Spalte
  if (pMin<>0.0 or pMax<>0.0) then begin
    PL_Print(aName,CnvFI(GV.Int.01*cAbstandChemie)+cpos2a)
    if (GV.Logic.01<>true) then begin
      PL_Print('Chem. Analyse:',cPosC1);
      GV.Logic.01#true;
    end;
    if (pMin<>0.0 and pMax<>0.0) then begin
      PL_Print(cnvAF(pMin, 0, 0, 4) + ' - ' + cnvAF(pMax, 0, 0, 4),CnvFI(GV.Int.01*cAbstandChemie)+cpos2a+7.0)
    end
    if (pMin<>0.0 and pMax=0.0) then begin
      PL_Print('min. ' + cnvAF(pMin, 0, 0, 4),CnvFI(GV.Int.01*cAbstandChemie)+cpos2a+7.0)
      //PL_Print('min. ' + cnvAF(pMin),CnvFI(GV.Int.01*cAbstandChemie)+cpos2a+5.0)
    end;
    if (pMin=0.0 and pMax<>0.0) then begin
      PL_Print('max. ' + cnvAF(pMax, 0, 0, 4),CnvFI(GV.Int.01*cAbstandChemie)+cpos2a+7.0)
    end;
    GV.Int.01 # GV.Int.01 + 1
    if (GV.Int.01=4) then begin
      GV.Int.01 # 0;
      PL_Printline;
    end;
 end;

end;


//========================================================================
//   Print_Mech
//            Fügt eine Zeile mechanischer Analyse zum Formular hinzu
//            Wird nur benötigt für MaterialDruck()
//            Argumente:
//                Name    Name der Größe
//                pMin     1. Wert
//                pMax     2. Wert
//                Einheit Bezeichnung der Einheit
//========================================================================
sub Print_Mech(Name : alpha; pMin : float; pMax : float; Einheit : alpha;);
begin
  Einheit # ' ' + Einheit;
  if(pMin<>0.0 or pMax<>0.0)then begin
    if (GV.Logic.01<>true) then begin
      PL_Print('Mech. Werte:',cPosC1);
      GV.Logic.01#true;
    end;
    PL_Print(Name,cpos2a);
    if(pMin<>0.0 and pMax<>0.0)then begin
      PL_Print(cnvAF(pMin, 0, 0, 1) + Einheit + ' - ' + cnvAF(pMax, 0, 0, 1) + Einheit,75.0);
    end;
    if(pMin<>0.0)then begin
      if (pMax=0.0) then begin
        //PL_Print(Name,cpos2a);
        PL_Print('min. ' + cnvAF(pMin, 0, 0, 1) + Einheit,75.0);
      end;
        //PL_Print(Name,cpos2a);PL_Print('min. ' + cnvAF(pMin) + Einheit,75.0);
    end;
    if(pMin=0.0)then begin
      if (pMax<>0.0) then begin
        //PL_Print(Name,cpos2a);
        PL_Print('max. ' + cnvAF(pMax, 0, 0, 1) + Einheit,75.0);
      end;
    end;
    if(pMin=pMax)then begin
      PL_Print(Name,cpos2a);
      PL_Print(cnvAF(pMin, 0, 0, 1) + Einheit,75.0);
    end;
    PL_PrintLine;
  end;
end;


//========================================================================
//   getSondertext
//
//========================================================================
sub getSondertext(aText : alpha; aKeyWord : alpha) : alpha;
local begin
  Erx           : int;
  vX        : int;
  vHdl      : int;
  vText     : alpha(4000);
  // vOK       : logic;
  vTextLine : alpha(4000);
end;
begin
  vText # '';
  vTextLine # '';
  vOK # false;

  vHdl # TextOpen(10);
  Erx # TextRead(vHdl, aText, 0);
  if (Erx > _rLocked) then RETURN '';

  vX # TextSearch(vHdl, 1, 1, 0, aKeyWord);
  if (vX = 0) then RETURN '';

  vTextLine # StrAdj(TextLineRead(vHdl, vX, 0), _StrBegin | _StrEnd);
  vText # Str_ReplaceAll(vTextLine, aKeyWord, '');
  RETURN vText;
end;


//========================================================================
//   FilterSondertext
//
//========================================================================
sub FilterSondertext(aText : alpha; aKeyWord : alpha) : alpha;
local begin
  Erx           : int;
  vX : int;
  vHdl : int;
  vText : alpha(4000);
  // vOK   : logic;
  vTextLine : alpha(4000);
end;
begin
  vText # '';
  vTextLine # '';
  vOK # false;

  vHdl # TextOpen(10);
  Erx # TextRead(vHdl, aText, 0);
  if(Erx > _rLocked) then RETURN aText;

  vX # TextSearch(vHdl, 1, 1, 0, aKeyWord);
  if(vX = 0) then RETURN aText;

  TextLineRead(vHdl, vX,_TextLineDelete);
  TxtWrite(vHdl, MyTmpText, 0);

  RETURN MyTmpText;
end;


//========================================================================
//  Print_Mat(vRb1, Auf.P.Menge.Wunsch, vPosMenge, vPosStk);
//            Druckt die Materialdaten für ein Druckformular
//            Wird benötigt allen Druckroutinen
//========================================================================
sub Print_Mat(
  aRb1      : alpha;
  aWMenge   : float;
  aPMenge   : float;
  aStk      : int;
  );
local begin
  Erx           : int;
  vVerp                     : alpha(1000);
  vFlag                     : int;
  vMerker                   : alpha;
  vText                     : alpha(250);
  vText2                    : alpha(250);
  vVerrechenbarerAufpreis   : float;
  vPosPreis                 : float;
end;
begin
  Auf.P.Gesamtpreis # Rnd((Auf.P.Grundpreis) *  aPMenge / CnvFI(Auf.P.PEH) ,2);
  // -- Positionsdaten --
  PL_Print(cnvAI(vAnfragePos), cPosCL);


  // >>>> Anfrage in AuftragsAktionen hinterlegen
  // Pos. bereits in Anfrage enthalten?
  vOk # false;
  Erx # RecLink(404,401,12,_RecFirst);
  WHILE (Erx<=_rLocked) do begin          // Aktionen durchlaufen
    if (Auf.A.Aktionstyp = 'ANF') and (Auf.A.Aktionsnr=vAnfrageNr) then vOk # true; // c_Anf anlegen mit Inhalt 'ANF'
    Erx # RecLink(404,401,12,_RecNext);
  END;

  if (vOK = false) then begin
      // Aktion vermerken
      RecBufClear(404);
      Auf.A.Nummer          # Auf.P.Nummer;
      Auf.A.Position        # Auf.P.Position;
      Auf.A.Position2       # 0;
      Auf.A.Aktion          # 0;
      Auf.A.Aktionstyp      # 'ANF';
      Auf.A.Aktionsnr       # vAnfrageNr;
      Auf.A.Aktionspos      # vAnfragePos;
      Auf.A.Aktionsdatum    # today;
      Auf.A.Adressnummer    # Adr.Nummer;
      Auf.A.Bemerkung       # 'ANFRAGE ' + Adr.Stichwort;
      Auf.A.Anlage.Datum    # today;
      Auf.A.Anlage.Zeit     # now;
      Auf.A.Anlage.User     # gUserName;

      REPEAT
        Auf.A.Aktion         # Auf.A.Aktion + 1;
        Erx # RekInsert(404,0,'AUTO');
      UNTIL (erx=_rOK);

  end;
  vAnfragePos # vAnfragePos +1;
  // Anfrage in AuftragsAktionen hinterlegen <<<<

  vText # '';
  pls_FontAttr # _WinFontAttrBold;
  Lib_Strings:Append(var vText, "Auf.P.Güte", '');
  Lib_Strings:Append(var vText, '/', ' ');

  if(Auf.P.AusfOben <> '') or (Auf.P.AusfUnten <> '') then begin
    vText2 # '';
    FOR Erx # RecLink(402, 401, 11, _recFirst);
    LOOP Erx # RecLink(402, 401, 11, _recNext);
    WHILE (Erx <= _rLocked) DO BEGIN
      Lib_Strings:Append(var vText2, Auf.AF.Bezeichnung, ', ');
      if(Auf.AF.Zusatz <> '') then
        Lib_Strings:Append(var vText2, Auf.AF.Zusatz, ' ');
    END;
    Lib_Strings:Append(var vText, vText2, ' ');
  end;

  PL_Print(vText, cPosC1);
  pls_FontAttr # _WinFontAttrNormal;

  /*if (aStk <> 0) then
    PL_PrintI(aStk ,cPosC9);
  */
  PL_PrintF(aWMenge,Set.Stellen.Gewicht, cPosC10);
  vGesamtGewicht # vGesamtGewicht + aWMenge;
  vSumGewichtN # vSumGewichtN + aWMenge;

  //vPosPreis # Auf.P.Grundpreis + vVerrechenbarerAufpreis;
  // vPosPreis # Auf.P.Grundpreis;
  // PL_PrintF(vPosPreis, 2, cPosC11);

  if(Auf.LiefervertragYN) then begin // Rahmenvertrag
    if("Auf.GültigkeitVom" <> 00.00.0000) then begin
      PL_Print_R('vom', cPosC12);
      PL_Print(cnvAD("Auf.GültigkeitVom"), cPosC13);
    end;
    else if("Auf.GültigkeitBis" <> 00.00.0000) then begin
      PL_Print_R('bis', cPosC12);
      PL_Print(cnvAD("Auf.GültigkeitBis"), cPosC13);
    end;
  end
  else begin
    // Liefertermin & Lieferterminzusatz
    // Liefertermin
    if(Auf.P.Termin.Zusatz <> '') then begin
      PL_Print(Auf.P.Termin.Zusatz, cPosC12);
    end
    else begin
      if (Auf.P.Termin1W.Art = 'DA') and (Auf.P.Termin1Wunsch <> 31.12.2099) then begin
        PL_Print(cnvAD(Auf.P.Termin1Wunsch), cPosC12);
      end else
      if (Auf.P.Termin1W.Art = 'DA') and (Auf.P.Termin1Wunsch = 31.12.2099) then begin
        PL_Print('Auf Abruf', cPosC12);
      end else
      if (Auf.P.Termin1W.Art = 'KW') and (Auf.P.Termin1Wunsch <> 31.12.2099) then begin
        PL_Print('KW ' + cnvAI(Auf.P.Termin1W.Zahl,_FmtNumLeadZero) + '/' +
                         cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
      end else
      if (Auf.P.Termin1W.Art = 'KW') and (Auf.P.Termin1Wunsch = 31.12.2099) then begin
        PL_Print('Auf Abruf', cPosC12);
      end else
      if (Auf.P.Termin1W.Art = 'MO') then begin
        PL_Print(Lib_Berechnungen:Monat_aus_datum(Auf.P.Termin1Wunsch) + ' ' +
                 cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
      end else
      if (Auf.P.Termin1W.Art = 'QU') then begin
        PL_Print(cnvAI(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Quartal ' +
                 cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
      end else
      if (Auf.P.Termin1W.Art = 'SE') then begin
        PL_Print(cnvAI(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Semester ' +
                 cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
      end else
      if (Auf.P.Termin1W.Art = 'JA') then begin
        PL_Print('Jahr ' +  cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
      end;
    end;
  end;
  PL_PrintLine;

  // PL_Print_R('pro ' + cnvAI(Auf.P.PEH) + ' ' + Auf.P.MEH.Preis, cPosC11);

  if(Auf.P.Termin2Wunsch <> 00.00.0000) then begin
    if (Auf.P.Termin1W.Art = 'DA') then begin
      PL_Print('bis ' + cnvAD(Auf.P.Termin2Wunsch), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'KW') then begin
      PL_Print('bis ' + cnvAI(Auf.P.Termin2W.Zahl,_FmtNumLeadZero) + '/' +
                       cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'MO') then begin
      PL_Print('bis ' + Lib_Berechnungen:Monat_aus_datum(Auf.P.Termin2Wunsch) + ' ' +
               cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'QU') then begin
      PL_Print('bis ' + cnvAI(Auf.P.Termin2W.Zahl,_FmtNumNoZero) + '. ' +
               cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'SE') then begin
      PL_Print('bis ' + cnvAI(Auf.P.Termin2W.Zahl,_FmtNumNoZero) + '. ' +
               cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'JA') then begin
      PL_Print('bis ' + cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
   end;
  end
  else
    PL_Print('u. ü. Vorbehalt' ,cPosC12);

  //Dicke
  //if (Auf.P.Dicke <> 0.0) then begin
  PL_Print('Dicke', cPosC1); // Auf.AbmessungsEH
  PL_Print(':', cPosC2);
  pls_FontAttr # _WinFontAttrBold;
  PL_PrintF(Auf.P.Dicke,Set.Stellen.Dicke,cPosC3);
  pls_FontAttr # _WinFontAttrNormal;
  PL_Print(Auf.AbmessungsEH, cPosC4);
  PL_Print('/', cPosC5);

  if (Auf.P.Dickentol<>'') then begin
    PL_Print('Tol.: ', cPosC6);
    PL_Print_R(Auf.P.Dickentol, cPosC7);
    PL_Print('mm', cPosC8);
  end;

  PL_PrintLine;

  if(Auf.P.Termin2Wunsch <> 00.00.0000) then
    PL_Print('u. ü. Vorbehalt' ,cPosC12);

  //Breite
  if (Auf.P.Breite <> 0.0) then begin
    PL_Print('Breite ', cPosC1); // Auf.AbmessungsEH
    PL_Print(':', cPosC2);
    pls_FontAttr # _WinFontAttrBold;
    PL_PrintF(Auf.P.Breite,Set.Stellen.Breite,cPosC3);
    pls_FontAttr # _WinFontAttrNormal;
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_Print('/', cPosC5);

    if (Auf.P.Breitentol <> '') then begin
      PL_Print('Tol.: ', cPosC6);
      PL_Print_R(Auf.P.Breitentol, cPosC7);
      PL_Print('mm', cPosC8);
    end;
    PL_PrintLine;
  end
  else if (Auf.P.Breitentol <> '') then begin
    PL_Print('Tol.: ', cPosC6);
    PL_Print_R(Auf.P.Breitentol, cPosC7);
    PL_Print('mm', cPosC8);
    PL_PrintLine;
  end;

  //Länge
  if ("Auf.P.Länge" <> 0.0)then begin
    PL_Print('Länge', cPosC1); // Auf.AbmessungsEH
    PL_Print(':', cPosC2);
    pls_FontAttr # _WinFontAttrBold;
    PL_PrintF("Auf.P.Länge","Set.Stellen.Länge",cPosC3);
    pls_FontAttr # _WinFontAttrNormal;
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_Print('/', cPosC5);
    if ("Auf.P.Längentol" <> '') then begin
      PL_Print('Tol.: ', cPosC6);
      PL_Print_R("Auf.P.Längentol", cPosC7);
      PL_Print('mm', cPosC8);
    end;
    PL_PrintLine;
  end
  else if ("Auf.P.Längentol" <> '') then begin
    PL_Print('Tol.: ', cPosC6);
    PL_Print_R("Auf.P.Längentol", cPosC7);
    PL_Print('mm', cPosC8);
    PL_PrintLine;
 end;

  // Ringinnendurchmesser
  if ((Auf.P.RID <> 0.0) AND (Auf.P.RIDMAX = 0.0)) then begin
    PL_Print('RID ', cPosC1);
    PL_Print(':', cPosC2);
    PL_PrintF(Auf.P.RID,Set.Stellen.Radien,cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_PrintLine;
  end else
  if ((Auf.P.RID <> 0.0) AND (Auf.P.RIDMAX <> 0.0)) then begin
    PL_Print('RID ' ,cPosC1);
    PL_Print(':', cPosC2);
    PL_Print_R(cnvAF(Auf.P.RID,0,0,Set.Stellen.Radien) + ' - ' + cnvAF(Auf.P.RIDMAX,0,0,Set.Stellen.Radien)  ,cPosC3 + 4.0);
    PL_Print(Auf.AbmessungsEH, cPosC4 + 3.0);
    PL_PrintLine;
  end else
  if ((Auf.P.RID = 0.0) AND (Auf.P.RIDMAX <> 0.0)) then begin
    PL_Print('RID max' , cPosC1);
    PL_Print(':', cPosC2);
    PL_PrintF(Auf.P.RIDMAX,Set.Stellen.Radien, cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_PrintLine;
  end;

  // Ringaußendurchmesser
  if ((Auf.P.RAD <> 0.0) AND (Auf.P.RADMAX = 0.0) AND (vMinRadYN = true)) then begin
    PL_Print('RAD min', cPosC1);
    PL_Print(':', cPosC2);
    PL_PrintF(Auf.P.RAD,Set.Stellen.Radien,cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_PrintLine;
  end else
  if ((Auf.P.RAD = 0.0) AND (Auf.P.RADMAX <> 0.0) AND (vMinRadYN = false)) then begin
    PL_Print('RAD max' , cPosC1);
    PL_Print(':', cPosC2);
    PL_PrintF(Auf.P.RADMAX,Set.Stellen.Radien, cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_PrintLine;
  end else
  if ((Auf.P.RAD <> 0.0) AND (Auf.P.RADMAX <> 0.0)) then begin
    if(vMinRadYN = false) then
      PL_Print('RAD max' ,cPosC1);
    else
      PL_Print('RAD ' ,cPosC1);
    PL_Print(':', cPosC2);
    if(vMinRadYN = false) then
      PL_Print_R(cnvAF(Auf.P.RADMAX,0,0,Set.Stellen.Radien)  ,cPosC3);
    else
      PL_Print_R(cnvAF(Auf.P.RAD,0,0,Set.Stellen.Radien) + ' - ' + cnvAF(Auf.P.RADMAX,0,0,Set.Stellen.Radien)  ,cPosC3 + 7.0);

    if(vMinRadYN = false) then
      PL_Print(Auf.AbmessungsEH, cPosC4);
    else
      PL_Print(Auf.AbmessungsEH, cPosC4 + 7.0);
    PL_PrintLine;
  end;

  // Zeugnis
  if (Auf.P.Zeugnisart <> '') then begin
    PL_Print('Zeugnis', cPosC1);
    PL_Print(':', cPosC2);
    PL_Print(Auf.P.Zeugnisart,cPosC3L);
    PL_PrintLine;
  end;

  // Kundenartikelnummer
  if (Auf.P.KundenArtNr  <> '') then begin
    PL_Print('Kd.-Artikelnr.', cPosC1);
    PL_Print(':',cPosC2);
    PL_Print(Auf.P.KundenArtNr ,cPosC3L);
    PL_PrintLine;
  end;

  // Intrastat
  if (Auf.P.Intrastatnr <> '') then begin
    PL_Print('Instrastat.', cPosC1);
    PL_Print(':', cPosC2);
    PL_Print(Auf.P.Intrastatnr, cPosC3L);
    PL_PrintLine;
  end;

  // Pos. Bestellnummer (nur wenn Abweichend von Auftragsbestellnr.)
  if((Auf.P.Best.Nummer <> Auf.Best.Nummer) and (Auf.P.Best.Nummer <> '')) then begin
    PL_Print('Pos.-Bestellnr.', cPosC1);
    PL_Print(':', cPosC2);
    PL_Print(Auf.P.Best.Nummer , cPosC3L);
    PL_PrintLine;
  end;

  // Positionstext
  if (Auf.P.Bemerkung <> '') then begin
    PL_Print('Bemerkung', cPosC1);
    PL_Print(':', cPosC2);
    PL_Print(Auf.P.Bemerkung,cPosC3L);
    PL_PrintLine;
  end;

  //------Verpackung---------
  vVerp # '';
  //Abbindung
  if (Auf.P.AbbindungQ <> 0 or Auf.P.AbbindungL <> 0) then begin
    //Quer
    if(Auf.P.AbbindungQ<>0)then vMerker # 'Abbindung '+ cnvAI(Auf.P.AbbindungQ)+' x quer' ;
    //Längs
    if(Auf.P.AbbindungL<>0)then begin
      if (vMerker<>'')then
        vMerker # vMerker+'  '+cnvAI(Auf.P.AbbindungL)+ ' x längs';
      else
        vMerker # 'Abbindung ' + cnvAI(Auf.P.AbbindungL)+' x längs';
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
    ADD_VERP('Nettoabzug: '+cnvAI(CnvIF(Auf.P.Nettoabzug))+' kg','');

  if ("Auf.P.Stapelhöhe" > 0.0) then
    ADD_VERP('max. Stapelhöhe: ',cnvAI(CnvIF("Auf.P.Stapelhöhe"))+' mm');

  if (Auf.P.StapelhAbzug > 0.0) then
    ADD_VERP('Stapelhöhenabzug: ',cnvAI(CnvIF("Auf.P.StapelhAbzug"))+' mm');

  //Ringgewicht
  if (Auf.P.RingKgVon + Auf.P.RingKgBis  <> 0.0) then begin
    if (Auf.P.RingKgVon <> 0.0 and Auf.P.RingKgBis <> 0.0) then begin
      if(vMinRadYN = true) then
        vMerker # 'Ringgew.: min. ' + cnvAI(CnvIF(Auf.P.RingKgVon)) + ' kg  max. ' + cnvAI(CnvIF(Auf.P.RingKgBis));
      else
        vMerker # 'Ringgew.: max. ' + cnvAI(CnvIF(Auf.P.RingKgBis));
    end
    if((Auf.P.RingKgVon <> 0.0) and (Auf.P.RingKgBis = 0.0) and (vMinRadYN = true))  then
      vMerker # 'Ringgew.: min.' + cnvAI(CnvIF(Auf.P.RingKgVon));
    if (Auf.P.RingKgVon = 0.0 and Auf.P.RingKgBis <> 0.0) then
      vMerker # 'Ringgew.: max. ' + cnvAI(CnvIF(Auf.P.RingKgBis));
    if (Auf.P.RingKgVon = Auf.P.RingKgBis) then
      vMerker # 'Ringgew.: ' + cnvAI(CnvIF(Auf.P.RingKgBis));
    vMerker#vMerker+' kg';
    ADD_VERP(vMerker,'')
  end;

  //kg/mm
  if (Auf.P.KgmmVon + Auf.P.KgmmBis  <> 0.0) then begin
    if (Auf.P.KgmmVon <> 0.0 and Auf.P.KgmmBis <> 0.0) then begin
      if(vMinRadYN = true) then
        vMerker # 'Kg/mm: min. ' + cnvAF(Auf.P.KgmmVon) + ' max. ' + cnvAF(Auf.P.KgmmBis)
      else
        vMerker # 'Kg/mm: max. ' + cnvAF(Auf.P.KgmmBis)
    end
    if ((Auf.P.KgmmVon <> 0.0) and (Auf.P.KgmmBis = 0.0) and (vMinRadYN = true))  then
      vMerker # 'Kg/mm: min. ' + cnvAF(Auf.P.KgmmVon)
    if (Auf.P.KgmmVon = 0.0 and Auf.P.KgmmBis <> 0.0) then
      vMerker # 'Kg/mm: max. ' + cnvAF(Auf.P.KgmmBis)
    if (Auf.P.KgmmVon = Auf.P.KgmmBis) then
      vMerker # 'Kg/mm: ' + cnvAF(Auf.P.KgmmBis)
    ADD_VERP(vMerker,'')
  end;

  if (Auf.P.StehendYN) then
    ADD_VERP('stehend','');

  if (Auf.P.LiegendYN) then
    ADD_VERP('liegend','');


  if ("Auf.P.StückProVE" > 0) then
    ADD_VERP('max. ' +cnvAI("Auf.P.StückProVE") + ' Stück pro VE', '');

  if (Auf.P.VEkgMax > 0.0) then
    ADD_VERP('max. kg pro VE: ',cnvAI(CnvIF(Auf.P.VEkgMax)));

  if (Auf.P.RechtwinkMax > 0.0) then
    ADD_VERP('max. Rechtwinkligkeit: ', cnvAF(Auf.P.RechtwinkMax));

  if (Auf.P.EbenheitMax > 0.0) then
    ADD_VERP('max. Ebenheit: ', cnvAF(Auf.P.EbenheitMax));

  if ("Auf.P.SäbeligkeitMax" > 0.0) then begin
    ADD_VERP('max. Säbeligkeit: ', ANum("Auf.P.SäbeligkeitMax", 2) + ' mm');
    if("Auf.P.SäbelProM" <> 0.0) then
      Lib_Strings:Append(var vVerp, ' auf ' + ANum("Auf.P.SäbelProM", 2) + ' m');
  end;

  if (vVerp <> '') then begin
    PL_Printline;
    PL_Print('VERPACKUNG:', cPosC1);
    PL_Printline;
    PL_Print(vVerp,cPosC1, cPosC13);
    PL_Printline;
  end;
  if (Auf.P.VpgText1 <> '') then begin
    PL_Print(Auf.P.VpgText1, cPosC1);
    PL_Printline;
  end;
  if (Auf.P.VpgText2 <> '') then begin
    PL_Print(Auf.P.VpgText2, cPosC1);
    PL_Printline;
  end;

  //mech Analyse
  GV.Logic.01#false;//=Noch kein Element gelistet (für 'Mech. Analyse:')
  Print_Mech('Streckgrenze',Auf.P.Streckgrenze1 , Auf.P.Streckgrenze2,'MPa');
  Print_Mech('Zugfestigkeit',Auf.P.Zugfestigkeit1 , Auf.P.Zugfestigkeit2,'MPa');
  if (Auf.P.DehnungA1 + Auf.P.DehnungA2 + Auf.P.DehnungB1 + Auf.P.DehnungB2 <> 0.0)then begin
    if (GV.Logic.01 = false)then begin
      GV.Logic.01 # true;
      PL_Print('Mech. Analyse:',cPos2);
    end;
    PL_Print('Dehnung',cPos2a);
    vText # '';
    if(Auf.P.DehnungA1 <> 0.0) and (Auf.P.DehnungA2 <> 0.0) then begin // von bis
      Lib_Strings:Append(var vText, ANum(Auf.P.DehnungA1, 1), '');
      if(Auf.P.DehnungB1 <> 0.0) then
        Lib_Strings:Append(var vText, ANum(Auf.P.DehnungB1, 1), ' / ');
      Lib_Strings:Append(var vText, '%', '');
      Lib_Strings:Append(var vText, ANum(Auf.P.DehnungA2, 1), ' - ');
      if(Auf.P.DehnungB2 <> 0.0) then
        Lib_Strings:Append(var vText, ANum(Auf.P.DehnungB2, 1), ' / ');
      Lib_Strings:Append(var vText, '%', '');
    end
    else if(Auf.P.DehnungA1 <> 0.0) and (Auf.P.DehnungA2 = 0.0) then begin // min
      Lib_Strings:Append(var vText, 'min. ' + ANum(Auf.P.DehnungA1, 1), '');
      if(Auf.P.DehnungB1 <> 0.0) then
        Lib_Strings:Append(var vText, ANum(Auf.P.DehnungB1, 1), ' / ');
      Lib_Strings:Append(var vText, '%', '');
    end
    else if(Auf.P.DehnungA1 = 0.0) and (Auf.P.DehnungA2 <> 0.0) then begin // max
      Lib_Strings:Append(var vText, 'max. ' + ANum(Auf.P.DehnungA2, 1), '');
      if(Auf.P.DehnungB2 <> 0.0) then
        Lib_Strings:Append(var vText, ANum(Auf.P.DehnungB2, 1), ' / ');
      Lib_Strings:Append(var vText, '%', '');
    end;
    PL_Print(vText, 75.0);
    //PL_Print(ANum(Auf.P.DehnungA1, 1) + ' / ' + ANum(Auf.P.DehnungB1, 1) + '% - ' + ANum(Auf.P.DehnungA2, 1) + ' / ' + ANum(Auf.P.DehnungB2, 1) + '%',75.0);
    PL_PrintLine;
  end;
  Print_Mech('Rp 0,2',Auf.P.DehngrenzeA1 , Auf.P.DehngrenzeA2,'MPa');
  Print_Mech('Rp 10',Auf.P.DehngrenzeB1 , Auf.P.DehngrenzeB2,'MPa');
  if ("Set.Mech.Titel.Körn" <> '') then
    Print_Mech("Set.Mech.Titel.Körn","Auf.P.Körnung1", "Auf.P.Körnung2",'')
  else
    Print_Mech('Körnung',"Auf.P.Körnung1", "Auf.P.Körnung2",'');
  if ("Set.Mech.Titel.Härte" <> '') then
    Print_Mech("Set.Mech.Titel.Härte","Auf.P.Härte1" , "Auf.P.Härte2",'')
  else
    Print_Mech('Härte',"Auf.P.Härte1" , "Auf.P.Härte2",'');
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
  GV.Logic.01 # false;  //=Noch kein Element gelistet (für 'Chem. Analyse:')
  GV.Int.01 # 0;    //Akt. Spalte
  Print_Chem('C' ,Set.Chemie.Titel.C   ,Auf.P.Chemie.C1,Auf.P.Chemie.C2);
  Print_Chem('Si',Set.Chemie.Titel.Si  ,Auf.P.Chemie.Si1,Auf.P.Chemie.Si2);
  Print_Chem('Mn',Set.Chemie.Titel.Mn  ,Auf.P.Chemie.Mn1,Auf.P.Chemie.Mn2);
  Print_Chem('P' ,Set.Chemie.Titel.P   ,Auf.P.Chemie.P1,Auf.P.Chemie.P2);
  Print_Chem('S' ,Set.Chemie.Titel.S   ,Auf.P.Chemie.S1,Auf.P.Chemie.S2);
  Print_Chem('Al',Set.Chemie.Titel.Al  ,Auf.P.Chemie.Al1,Auf.P.Chemie.Al2);
  Print_Chem('Cr',Set.Chemie.Titel.Cr  ,Auf.P.Chemie.Cr1,Auf.P.Chemie.Cr2);
  Print_Chem('V' ,Set.Chemie.Titel.V   ,Auf.P.Chemie.V1,Auf.P.Chemie.V2);
  Print_Chem('Nb',Set.Chemie.Titel.Nb  ,Auf.P.Chemie.Nb1,Auf.P.Chemie.Nb2);
  Print_Chem('Ti',Set.Chemie.Titel.Ti  ,Auf.P.Chemie.Ti1,Auf.P.Chemie.Ti2);
  Print_Chem('N' ,Set.Chemie.Titel.N   ,Auf.P.Chemie.N1,Auf.P.Chemie.N2);
  Print_Chem('Cu',Set.Chemie.Titel.Cu  ,Auf.P.Chemie.Cu1,Auf.P.Chemie.Cu2);
  Print_Chem('Ni',Set.Chemie.Titel.Ni  ,Auf.P.Chemie.Ni1,Auf.P.Chemie.Ni2);
  Print_Chem('Mo',Set.Chemie.Titel.Mo  ,Auf.P.Chemie.Mo1,Auf.P.Chemie.Mo2);
  Print_Chem('B' ,Set.Chemie.Titel.B   ,Auf.P.Chemie.B1,Auf.P.Chemie.B2);
  Print_Chem(''  ,Set.Chemie.Titel.1   ,Auf.P.Chemie.Frei1.1,Auf.P.Chemie.Frei1.2);
  PL_PrintLine;
end;


//========================================================================
//  Print_MatLohn
//            Druckt die Materialdaten für ein Druckformular
//            Wird benötigt allen Druckroutinen
//========================================================================
sub Print_MatLohn(
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
  vText     : alpha(120);
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
 PL_PrintI(Auf.P.Position, cPosC0);

  pls_FontAttr # _WinFontAttrBold;
  PL_Print("Auf.P.Güte",cPosC1);
  pls_FontAttr # _WinFontAttrNormal;

  PL_PrintF(aWMenge,Set.Stellen.Gewicht, cPosC10);
  vGesamtGewicht # vGesamtGewicht + aWMenge;
  vSumGewichtN # vSumGewichtN + aWMenge;

  if (Auf.P.Termin1W.Art = 'DA') then begin
    PL_Print(cnvAD(Auf.P.Termin1Wunsch), cPosC12);
  end else
  if (Auf.P.Termin1W.Art = 'KW') then begin
    PL_Print('KW ' + cnvAI(Auf.P.Termin1W.Zahl,_FmtNumLeadZero) + '/' +
                     cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
  end else
  if (Auf.P.Termin1W.Art = 'MO') then begin
    PL_Print(Lib_Berechnungen:Monat_aus_datum(Auf.P.Termin1Wunsch) + ' ' +
             cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
  end else
  if (Auf.P.Termin1W.Art = 'QU') then begin
    PL_Print(cnvAI(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Quartal ' +
             cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
  end else
  if (Auf.P.Termin1W.Art = 'SE') then begin
    PL_Print(cnvAI(Auf.P.Termin1W.Zahl,_FmtNumNoZero) + '. Semester ' +
             cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
  end else
  if (Auf.P.Termin1W.Art = 'JA') then begin
    PL_Print('Jahr ' +  cnvAI(Auf.P.Termin1W.Jahr,_FmtNumNoGroup), cPosC12);
  end;

  PL_PrintLine;

  if(Auf.P.Termin2Wunsch <> 00.00.0000) then begin
    if (Auf.P.Termin1W.Art = 'DA') then begin
      PL_Print('bis ' + cnvAD(Auf.P.Termin2Wunsch), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'KW') then begin
      PL_Print('bis ' + cnvAI(Auf.P.Termin2W.Zahl,_FmtNumLeadZero) + '/' +
                       cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'MO') then begin
      PL_Print('bis ' + Lib_Berechnungen:Monat_aus_datum(Auf.P.Termin2Wunsch) + ' ' +
               cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'QU') then begin
      PL_Print('bis ' + cnvAI(Auf.P.Termin2W.Zahl,_FmtNumNoZero) + '. ' +
               cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'SE') then begin
      PL_Print('bis ' + cnvAI(Auf.P.Termin2W.Zahl,_FmtNumNoZero) + '. ' +
               cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
    end else
    if (Auf.P.Termin1W.Art = 'JA') then begin
      PL_Print('bis ' + cnvAI(Auf.P.Termin2W.Jahr,_FmtNumNoGroup), cPosC12);
   end;

  end;
  // else
  //   PL_Print('u. ü. Vorbehalt' ,cPosC12);

  //Dicke
  PL_Print('Dicke', cPosC1); // Auf.AbmessungsEH
  PL_Print(':', cPosC2);
  pls_FontAttr # _WinFontAttrBold;
  PL_PrintF(Auf.P.Dicke,Set.Stellen.Dicke,cPosC3);
  pls_FontAttr # _WinFontAttrNormal;
  PL_Print(Auf.AbmessungsEH, cPosC4);
  PL_Print('/', cPosC5);

  if (Auf.P.Dickentol<>'') then begin
    PL_Print('Tol.: ', cPosC6);
    PL_Print_R(Auf.P.Dickentol, cPosC7);
    PL_Print('mm', cPosC8);
  end;

  PL_PrintLine;

  //if(Auf.P.Termin2Wunsch <> 00.00.0000) then
  //   PL_Print('u. ü. Vorbehalt' ,cPosC12);

  //Breite
  if (Auf.P.Breite <> 0.0) then begin
    PL_Print('Breite ', cPosC1); // Auf.AbmessungsEH
    PL_Print(':', cPosC2);
    pls_FontAttr # _WinFontAttrBold;
    if (Auf.P.Breite <> 0.0) then
      PL_PrintF(Auf.P.Breite,Set.Stellen.Breite,cPosC3);
    pls_FontAttr # _WinFontAttrNormal;
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_Print('/', cPosC5);

    if (Auf.P.Breitentol <> '') then begin
      PL_Print('Tol.: ', cPosC6);
      PL_Print_R(Auf.P.Breitentol, cPosC7);
      PL_Print('mm', cPosC8);
    end;
    PL_PrintLine;
  end
  else if (Auf.P.Breitentol <> '') then begin
    PL_Print('Breite ', cPosC1); // Auf.AbmessungsEH
    PL_Print(':', cPosC2);
    pls_FontAttr # _WinFontAttrBold;
    //PL_PrintF(Auf.P.Breite,Set.Stellen.Breite,cPosC3);
    pls_FontAttr # _WinFontAttrNormal;
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_Print('/', cPosC5);
    PL_Print('Tol.: ', cPosC6);
    PL_Print_R(Auf.P.Breitentol, cPosC7);
    PL_Print('mm', cPosC8);
    PL_PrintLine;
  end;

  //Länge
  if ("Auf.P.Länge" <> 0.0)then begin
    PL_Print('Länge', cPosC1); // Auf.AbmessungsEH
    PL_Print(':', cPosC2);
    PL_PrintF("Auf.P.Länge","Set.Stellen.Länge",cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_Print('/', cPosC5);
    if ("Auf.P.Längentol" <> '') then begin
      PL_Print('Tol.: ', cPosC6);
      PL_Print_R("Auf.P.Längentol", cPosC7);
      PL_Print('mm', cPosC8);
    end;
    PL_PrintLine;
  end if ("Auf.P.Längentol" <> '') then begin
    PL_Print('Länge', cPosC1); // Auf.AbmessungsEH
    PL_Print(':', cPosC2);
    //PL_PrintF("Auf.P.Länge","Set.Stellen.Länge",cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_Print('/', cPosC5);
    PL_Print('Tol.: ', cPosC6);
    PL_Print_R("Auf.P.Längentol", cPosC7);
    PL_Print('mm', cPosC8);
    PL_PrintLine;
  end;

  //Ausführung
  if (Auf.P.AusfOben <> '') or (Auf.P.AusfUnten <> '') then begin
    vVerp # '';
    vMerker # '';
    PL_Print('Ausführung',cPosC1);
    PL_Print(':', cPosC2);
    // Oben/Vorderseite
    if (Auf.P.AusfOben <> '') then begin
      FOR Erx # RecLink(402, 401, 11, _recFirst);
      LOOP Erx # RecLink(402, 401, 11, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN
        if(Auf.AF.Seite <> '1') then
          CYCLE;
        Lib_Strings:Append(var vText, Auf.AF.Bezeichnung, ', ');
        if(Auf.AF.Zusatz <> '') then
          Lib_Strings:Append(var vText, Auf.AF.Zusatz, ' ');
      END;
    end;
    PL_Print(vVerp, cposC3);
    PL_PrintLine;
  end;

  // Ringinnendurchmesser
  if ((Auf.P.RID <> 0.0) AND (Auf.P.RIDMAX = 0.0)) then begin
    PL_Print('RID ', cPosC1);
    PL_Print(':', cPosC2);
    PL_PrintF(Auf.P.RID,Set.Stellen.Radien,cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_PrintLine;
  end else
  if ((Auf.P.RID <> 0.0) AND (Auf.P.RIDMAX <> 0.0)) then begin
    PL_Print('RID ' ,cPosC1);
    PL_Print(':', cPosC2);
    PL_Print_R(cnvAF(Auf.P.RID,0,0,Set.Stellen.Radien) + ' - ' + cnvAF(Auf.P.RIDMAX,0,0,Set.Stellen.Radien)  ,cPosC3 + 4.0);
    PL_Print(Auf.AbmessungsEH, cPosC4 + 3.0);
    PL_PrintLine;
  end else
  if ((Auf.P.RID = 0.0) AND (Auf.P.RIDMAX <> 0.0)) then begin
    PL_Print('RID max' , cPosC1);
    PL_Print(':', cPosC2);
    PL_PrintF(Auf.P.RIDMAX,Set.Stellen.Radien, cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_PrintLine;
  end;

  // Ringaußendurchmesser
  if ((Auf.P.RAD <> 0.0) AND (Auf.P.RADMAX = 0.0) AND (vMinRadYN = true)) then begin
    PL_Print('RAD min', cPosC1);
    PL_Print(':', cPosC2);
    PL_PrintF(Auf.P.RAD,Set.Stellen.Radien,cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_PrintLine;
  end else
  if ((Auf.P.RAD = 0.0) AND (Auf.P.RADMAX <> 0.0) AND (vMinRadYN = false)) then begin
    PL_Print('RAD max' , cPosC1);
    PL_Print(':', cPosC2);
    PL_PrintF(Auf.P.RADMAX,Set.Stellen.Radien, cPosC3);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_PrintLine;
  end else
  if ((Auf.P.RAD <> 0.0) AND (Auf.P.RADMAX <> 0.0)) then begin
    if(vMinRadYN = false) then
      PL_Print('RAD max' ,cPosC1);
    else
      PL_Print('RAD ' ,cPosC1);
    PL_Print(':', cPosC2);
    if(vMinRadYN = false) then
      PL_Print_R(cnvAF(Auf.P.RADMAX,0,0,Set.Stellen.Radien)  ,cPosC3);
    else

    PL_Print_R(cnvAF(Auf.P.RAD,0,0,Set.Stellen.Radien) + ' - ' + cnvAF(Auf.P.RADMAX,0,0,Set.Stellen.Radien)  ,cPosC3 + 7.0);
    PL_Print(Auf.AbmessungsEH, cPosC4);
    PL_PrintLine;
  end;

  // Zeugnis
  if (Auf.P.Zeugnisart <> '') then begin
    PL_Print('Zeugnis', cPosC1);
    PL_Print(':', cPosC2);
    PL_Print(Auf.P.Zeugnisart,cPosC3L);
    PL_PrintLine;
  end;

  // Kundenartikelnummer
  if (Auf.P.KundenArtNr  <> '') then begin
    PL_Print('Kd.-Artikelnr.', cPosC1);
    PL_Print(':',cPosC2);
    PL_Print(Auf.P.KundenArtNr ,cPosC3L);
    PL_PrintLine;
  end;

  // Intrastat
  if (Auf.P.Intrastatnr <> '') then begin
    PL_Print('Instrastat.', cPosC1);
    PL_Print(':', cPosC2);
    PL_Print(Auf.P.Intrastatnr, cPosC3L);
    PL_PrintLine;
  end;

  // Pos. Bestellnummer (nur wenn Abweichend von Auftragsbestellnr.)
  if((Auf.P.Best.Nummer <> Auf.Best.Nummer) and (Auf.P.Best.Nummer <> '')) then begin
    PL_Print('Pos.-Bestellnr.', cPosC1);
    PL_Print(':', cPosC2);
    PL_Print(Auf.P.Best.Nummer , cPosC3L);
    PL_PrintLine;
  end;

  // Positionstext
  if (Auf.P.Bemerkung <> '') then begin
    PL_Print('Bemerkung', cPosC1);
    PL_Print(':', cPosC2);
    PL_Print(Auf.P.Bemerkung,cPosC3L);
    PL_PrintLine;
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
    if(Auf.P.AbbindungQ<>0)then vMerker # 'Abbindung '+ cnvAI(Auf.P.AbbindungQ)+' x quer' ;
    //Längs
    if(Auf.P.AbbindungL<>0)then begin
      if (vMerker<>'')then
        vMerker # vMerker+'  '+cnvAI(Auf.P.AbbindungL)+ ' x längs';
      else
        vMerker # 'Abbindung ' + cnvAI(Auf.P.AbbindungL)+' x längs';
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
    ADD_VERP('Nettoabzug: '+cnvAI(CnvIF(Auf.P.Nettoabzug))+' kg','');

  if ("Auf.P.Stapelhöhe" > 0.0) then
    ADD_VERP('max. Stapelhöhe: ',cnvAI(CnvIF("Auf.P.Stapelhöhe"))+' mm');

  if (Auf.P.StapelhAbzug > 0.0) then
    ADD_VERP('Stapelhöhenabzug: ',cnvAI(CnvIF("Auf.P.StapelhAbzug"))+' mm');

  //Ringgewicht
  if (Auf.P.RingKgVon + Auf.P.RingKgBis  <> 0.0) then begin
    if (Auf.P.RingKgVon <> 0.0 and Auf.P.RingKgBis <> 0.0) then
      vMerker # 'Ringgew.: min. ' + cnvAI(CnvIF(Auf.P.RingKgVon)) + ' kg  max. ' + cnvAI(CnvIF(Auf.P.RingKgBis));
    if (Auf.P.RingKgVon <> 0.0 and Auf.P.RingKgBis = 0.0) then
      vMerker # 'Ringgew.: ' + cnvAI(CnvIF(Auf.P.RingKgVon));
    if (Auf.P.RingKgVon = 0.0 and Auf.P.RingKgBis <> 0.0) then
      vMerker # 'Ringgew.: max. ' + cnvAI(CnvIF(Auf.P.RingKgBis));
    if (Auf.P.RingKgVon = Auf.P.RingKgBis) then
      vMerker # 'Ringgew.: ' + cnvAI(CnvIF(Auf.P.RingKgBis));
    vMerker#vMerker+' kg';
    ADD_VERP(vMerker,'')
  end;

  //kg/mm
  if (Auf.P.KgmmVon + Auf.P.KgmmBis  <> 0.0) then begin
    if (Auf.P.KgmmVon <> 0.0 and Auf.P.KgmmBis <> 0.0) then
      vMerker # 'Kg/mm: min. ' + cnvAF(Auf.P.KgmmVon) + ' max. ' + cnvAF(Auf.P.KgmmBis)
    if (Auf.P.KgmmVon <> 0.0 and Auf.P.KgmmBis = 0.0) then
      vMerker # 'Kg/mm: min. ' + cnvAF(Auf.P.KgmmVon)
    if (Auf.P.KgmmVon = 0.0 and Auf.P.KgmmBis <> 0.0) then
      vMerker # 'Kg/mm: max. ' + cnvAF(Auf.P.KgmmBis)
    if (Auf.P.KgmmVon = Auf.P.KgmmBis) then
      vMerker # 'Kg/mm: ' + cnvAF(Auf.P.KgmmBis)
    ADD_VERP(vMerker,'')
  end;

  if ("Auf.P.StückProVE" > 0) then
    ADD_VERP(cnvAI("Auf.P.StückProVE") + ' Stück pro VE', '');

  if (Auf.P.VEkgMax > 0.0) then
    ADD_VERP('max. kg pro VE: ',cnvAI(CnvIF(Auf.P.VEkgMax)));

  if (Auf.P.RechtwinkMax > 0.0) then
    ADD_VERP('max. Rechtwinkligkeit: ', cnvAF(Auf.P.RechtwinkMax));

  if (Auf.P.EbenheitMax > 0.0) then
    ADD_VERP('max. Ebenheit: ', cnvAF(Auf.P.EbenheitMax));

  if ("Auf.P.SäbeligkeitMax" > 0.0) then begin
    ADD_VERP('max. Säbeligkeit: ', ANum("Auf.P.SäbeligkeitMax", 2) + ' mm');
    if("Auf.P.SäbelProM" <> 0.0) then
      Lib_Strings:Append(var vVerp, ' auf ' + ANum("Auf.P.SäbelProM", 2) + ' m');
  end;

  if (vVerp <> '') then begin
    PL_Printline;
    PL_Print('VERPACKUNG:', cPosC1);
    PL_Printline;
    PL_Print(vVerp,cPosC1, cPosC14);
    PL_Printline;
  end;
  if (Auf.P.VpgText1 <> '') then begin
    PL_Print(Auf.P.VpgText1, cPosC1);
    PL_Printline;
  end;
  if (Auf.P.VpgText2 <> '') then begin
    PL_Print(Auf.P.VpgText2, cPosC1);
    PL_Printline;
  end;

  //mech Analyse
  GV.Logic.01#false;//=Noch kein Element gelistet (für 'Mech. Analyse:')
  Print_Mech('Streckgrenze',Auf.P.Streckgrenze1 , Auf.P.Streckgrenze2,'MPa');
  Print_Mech('Zugfestigkeit',Auf.P.Zugfestigkeit1 , Auf.P.Zugfestigkeit2,'MPa');
  if (Auf.P.DehnungA1+Auf.P.DehnungA2+Auf.P.DehnungB1+Auf.P.DehnungB2<>0.0)then begin
    if (GV.Logic.01=false)then begin GV.Logic.01#true;PL_Print('Mech. Analyse:',cPos2); end;
    PL_Print('Dehnung',cPos2a);
    vText # '';
    if(Auf.P.DehnungA1 <> 0.0) and (Auf.P.DehnungA2 <> 0.0) then begin // von bis
      Lib_Strings:Append(var vText, ANum(Auf.P.DehnungA1, 1), '');
      if(Auf.P.DehnungB1 <> 0.0) then
        Lib_Strings:Append(var vText, ANum(Auf.P.DehnungB1, 1), ' / ');
      Lib_Strings:Append(var vText, '%', '');
      Lib_Strings:Append(var vText, ANum(Auf.P.DehnungA2, 1), ' - ');
      if(Auf.P.DehnungB2 <> 0.0) then
        Lib_Strings:Append(var vText, ANum(Auf.P.DehnungB2, 1), ' / ');
      Lib_Strings:Append(var vText, '%', '');
    end
    else if(Auf.P.DehnungA1 <> 0.0) and (Auf.P.DehnungA2 = 0.0) then begin // min
      Lib_Strings:Append(var vText, 'min. ' + ANum(Auf.P.DehnungA1, 1), '');
      if(Auf.P.DehnungB1 <> 0.0) then
        Lib_Strings:Append(var vText, ANum(Auf.P.DehnungB1, 1), ' / ');
      Lib_Strings:Append(var vText, '%', '');
    end
    else if(Auf.P.DehnungA1 = 0.0) and (Auf.P.DehnungA2 <> 0.0) then begin // max
      Lib_Strings:Append(var vText, 'max. ' + ANum(Auf.P.DehnungA2, 1), '');
      if(Auf.P.DehnungB2 <> 0.0) then
        Lib_Strings:Append(var vText, ANum(Auf.P.DehnungB2, 1), ' / ');
      Lib_Strings:Append(var vText, '%', '');
    end;
    PL_Print(vText, 75.0);
    PL_PrintLine;
  end;
  Print_Mech('Rp 0,2',Auf.P.DehngrenzeA1 , Auf.P.DehngrenzeA2,'MPa');
  Print_Mech('Rp 10',Auf.P.DehngrenzeB1 , Auf.P.DehngrenzeB2,'MPa');
  if ("Set.Mech.Titel.Körn" <> '') then
    Print_Mech("Set.Mech.Titel.Körn","Auf.P.Körnung1", "Auf.P.Körnung2",'')
  else
    Print_Mech('Körnung',"Auf.P.Körnung1", "Auf.P.Körnung2",'');
  if ("Set.Mech.Titel.Härte" <> '') then
    Print_Mech("Set.Mech.Titel.Härte","Auf.P.Härte1" , "Auf.P.Härte2",'')
  else
    Print_Mech('Härte',"Auf.P.Härte1" , "Auf.P.Härte2",'');
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
  GV.Logic.01 # false;  //=Noch kein Element gelistet (für 'Chem. Analyse:')
  GV.Int.01 # 0;    //Akt. Spalte
  Print_Chem('C' ,Set.Chemie.Titel.C   ,Auf.P.Chemie.C1,Auf.P.Chemie.C2);
  Print_Chem('Si',Set.Chemie.Titel.Si  ,Auf.P.Chemie.Si1,Auf.P.Chemie.Si2);
  Print_Chem('Mn',Set.Chemie.Titel.Mn  ,Auf.P.Chemie.Mn1,Auf.P.Chemie.Mn2);
  Print_Chem('P' ,Set.Chemie.Titel.P   ,Auf.P.Chemie.P1,Auf.P.Chemie.P2);
  Print_Chem('S' ,Set.Chemie.Titel.S   ,Auf.P.Chemie.S1,Auf.P.Chemie.S2);
  Print_Chem('Al',Set.Chemie.Titel.Al  ,Auf.P.Chemie.Al1,Auf.P.Chemie.Al2);
  Print_Chem('Cr',Set.Chemie.Titel.Cr  ,Auf.P.Chemie.Cr1,Auf.P.Chemie.Cr2);
  Print_Chem('V' ,Set.Chemie.Titel.V   ,Auf.P.Chemie.V1,Auf.P.Chemie.V2);
  Print_Chem('Nb',Set.Chemie.Titel.Nb  ,Auf.P.Chemie.Nb1,Auf.P.Chemie.Nb2);
  Print_Chem('Ti',Set.Chemie.Titel.Ti  ,Auf.P.Chemie.Ti1,Auf.P.Chemie.Ti2);
  Print_Chem('N' ,Set.Chemie.Titel.N   ,Auf.P.Chemie.N1,Auf.P.Chemie.N2);
  Print_Chem('Cu',Set.Chemie.Titel.Cu  ,Auf.P.Chemie.Cu1,Auf.P.Chemie.Cu2);
  Print_Chem('Ni',Set.Chemie.Titel.Ni  ,Auf.P.Chemie.Ni1,Auf.P.Chemie.Ni2);
  Print_Chem('Mo',Set.Chemie.Titel.Mo  ,Auf.P.Chemie.Mo1,Auf.P.Chemie.Mo2);
  Print_Chem('B' ,Set.Chemie.Titel.B   ,Auf.P.Chemie.B1,Auf.P.Chemie.B2);
  Print_Chem(''  ,Set.Chemie.Titel.1   ,Auf.P.Chemie.Frei1.1,Auf.P.Chemie.Frei1.2);
  PL_PrintLine;
end;


//========================================================================
//  Print_BAG
//
//========================================================================
sub Print_BAG();
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
      PrintLohnBA('BAG-Fertigungsposition');
      vVerpUsed # vVerpUsed + cnvAI(BAG.F.Verpackung,_FmtNumNoGroup | _FmtNumLeadZero,0,5)+';';

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
//  Print_Fusstext
//    Bringt den Fusstext nach bestimmten "Schluesselwoertern"
//
//========================================================================
sub Print_Fusstext
(
  aKeyWordBegin             : alpha;
  aKeyWordEnd               : alpha;
  aVonPos                   : float;
  aBisPos                   : float;
  opt aBadWordBegin         : alpha;
  opt aBadWordEnd           : alpha;
  opt aPrintAllgemeinenText : logic
);
local begin
  vHdlKeyPrint              : int;
  vPosKeyPrint              : int;
  vTxtName                  : alpha;
  vHdl                      : int;
  vX,vI                     : int;
  vTextZeile, vText2Print   : alpha(4000);
  vFound                    : logic;
end;
begin

  vFound # false;
  vText2Print # '';
  vX # 0;
  vI # 0;
  vPosKeyPrint # 1;

  vTxtName # '~401.'+cnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F';
  if(vTxtName <> '') then begin
    vHdl # TextOpen(10);
    vHdlKeyPrint # TextOpen(10);
    TextRead(vHdl, vTxtName, 0);
    vX # TextSearch(vHdl, 1, 1, 0, aKeyWordBegin);
    if (vX <> 0) then begin
      // ########### Text fuer gewuenschten Bereich Markierung entfernen ########
      // ########################################################################
      // ########################################################################

      vI # vX;
      WHILE (TextInfo(vHdl, _TextLines) >= vI) DO BEGIN
        vTextZeile # TextLineRead(vHdl, vI, 0);
        if((StrFind(vTextZeile, aKeyWordBegin, 1) > 0) or (vFound = true)) then begin    // Schluesselwort suchen was den Text einleitet
          if(vFound = false) then begin
            vText2Print # Str_ReplaceAll(vTextZeile, aKeyWordBegin, '');
            vFound # true;
            TextLineRead(vHdl, vI,_TextLineDelete);
            TextLineRead(vHdlKeyPrint, vPosKeyPrint,_TextLineDelete);
            if(vText2Print <> '') then begin
              TextLineWrite(vHdl, vI, vText2Print,_TextLineInsert);
              TextLineWrite(vHdlKeyPrint, vPosKeyPrint, vText2Print, _TextLineInsert);
            end;
            CYCLE;
          end;

          if((StrFind(vTextZeile, aKeyWordEnd, 1) > 0)) then begin                       // Schluesselwort suchen was den Text "abschließt"
            vText2Print # Str_ReplaceAll(vTextZeile, aKeyWordEnd, '');
            TextLineRead(vHdl, vI,_TextLineDelete);
            TextLineRead(vHdlKeyPrint, vPosKeyPrint,_TextLineDelete);
            if(vText2Print <> '') then begin
              TextLineWrite(vHdl, vI, vText2Print,_TextLineInsert);
              TextLineWrite(vHdlKeyPrint, vPosKeyPrint, vText2Print,_TextLineInsert);
            end;

            BREAK; // zu druckender Text zuende
          end;

          if((StrFind(vTextZeile, aKeyWordBegin, 0) = 0) and (StrFind(vTextZeile, aKeyWordEnd, 0) = 0)) then
            vText2Print # vTextZeile;

          if(aPrintAllgemeinenText = false) and ((TextLineRead(vHdlKeyPrint, vPosKeyPrint, 0) <> vText2Print) or (vText2Print = '')) then
            TextLineWrite(vHdlKeyPrint, vPosKeyPrint, vText2Print,_TextLineInsert);

          vI # vI + 1;
        end;
        vPosKeyPrint # vPosKeyPrint + 1;
      END;

      // ########################################################################
      // ########################################################################
      // ########### Text fuer gewuenschten Bereich Markierung entfernen ########
    end;

    if(aBadWordBegin <> '') and (aBadWordEnd <> '') then begin
      // ###############nicht gewuenschten Text entfernen########################
      // ########################################################################
      // ########################################################################
      vX # TextSearch(vHdl, 1, 1, 0, aBadWordBegin);
      if (vX <> 0) then begin
        vI # vX;
        WHILE (TextInfo(vHdl, _TextLines) >= vI) DO BEGIN
          vTextZeile # TextLineRead(vHdl, vI, 0);
          if((StrFind(vTextZeile, aBadWordEnd, 1) > 0) and ((StrFind(vTextZeile, aBadWordBegin, 1) = 0))) then begin   // Schluesselwort suchen was den Text "abschließt"
            TextLineRead(vHdl, vI,_TextLineDelete);
            BREAK; // zu druckender Text zuende
          end;
          TextLineRead(vHdl, vI,_TextLineDelete);
        END;
      end;
      // ########################################################################
      // ########################################################################
      // ###############nicht gewuenschten Text entfernen########################
    end;

    // ########################################################################
    // ###############Gewuenschten Text drucken#################################
    // ########################################################################

    if(TextInfo(vHdl, _TextLines) > 0) and (aPrintAllgemeinenText = true) then begin
      TxtWrite(vHdl, MyTmpText, 0);
      Lib_Print:Print_Text(MyTmpText, 1, aVonPos, aBisPos);  // drucken
      TxtDelete(MyTmpText,0);
    end;
    else if(TextInfo(vHdlKeyPrint, _TextLines) > 0) and (aPrintAllgemeinenText = false) then begin
      TxtWrite(vHdlKeyPrint, MyTmpText, 0);
      Lib_Print:Print_Text(MyTmpText, 1, aVonPos, aBisPos);  // drucken
      TxtDelete(MyTmpText,0);
    end;

    TextClose(vHdl);
    TextClose(vHdlKeyPrint);
  end;
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  Erx           : int;
  vBuf100     : int;
  vBuf101     : int;
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;
  vBuf        : int;
end;
begin
  vBuf100 # RekSave(100);
  vBuf101 # RekSave(101);

  Erx # RecRead(100,1,0);
  if(Erx > _rLocked) then
    RecBufClear(100);

  Erx # RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if(Erx > _rLocked) then
    RecBufClear(101);
  if(form_FaxNummer = '') then
    form_FaxNummer  # Adr.A.Telefax;
  if(form_EMA = '') then
    Form_EMA        # Adr.A.EMail;

  // SCRIPTLOGIK
  if (Scr.B.Nummer <>0) then
    HoleEmpfaenger();

  vBesteller # '';
  if ((Auf.Best.Bearbeiter <> '') AND (StrLen(Auf.Best.Bearbeiter) > 4)) then begin
    if (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      vBesteller # StrCut(Auf.Best.Bearbeiter, StrFind(Auf.Best.Bearbeiter, ':', 1) + 1,StrLen(Auf.Best.Bearbeiter) - StrFind(Auf.Best.Bearbeiter, ':', 1) + 1);
    end
    else
      vBesteller # Auf.Best.Bearbeiter;
  end;

  Pls_fontSize # 6
  pls_Fontattr # _WinFontAttrUnderline;
  PL_Print(Set.Absenderzeile, cPosH0);
  pls_Fontattr # _WinFontAttrNormal;
  PL_PrintLine;

  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.A.Anrede   , cPosAdr);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.A.Name     , cPosAdr);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.A.Zusatz  , cPosAdr);
  PL_PrintLine;
  if (Adr.A.Nummer = 1) and (Adr.Postfach <> '') then begin
    "Adr.A.Straße"  # 'Postfach '+ Adr.Postfach;
    Adr.A.PLZ       # Adr.Postfach.PLZ;
  end;

  Pls_fontSize # 10;
  PL_Print("Adr.A.Straße" , cPosAdr);
  PL_PrintLine;

  Erx # RecLink(812,101,2,_recFirst);   // Land holen
  if(Erx > _rLocked) then
    RecBufClear(812);
  Pls_fontSize # 10;
  PL_Print("Lnd.kürzel" + ' - ' + Adr.A.Plz + ' ' + Adr.A.Ort, cPosAdr);
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  //Usr.Username  # Auf.Sachbearbeiter;
  Usr.Username  # gUsername;
  Erx # RecRead(800, 1, 0);
  if(Erx > _rLocked) then
    RecBufClear(800);
  vText # '';
  Lib_Strings:Append(var vText, Usr.Anrede);
  Lib_Strings:Append(var vText, Usr.Vorname, ' ');
  Lib_Strings:Append(var vText, Usr.Name, ' ');
  PL_Print('Sachbearbeiter: '   , cPosBest0);
  PL_Print('Tel.: ' ,cPosBest1);
  PL_Print('E-Mail: '  , cPosBest2);
  PL_PrintLine;
  PL_Print(vText, cPosBest0);
  PL_Print(Usr.Telefonnr,cPosBest1);
  PL_Print(Usr.eMail, cPosBest2);
  PL_PrintLine;
  PL_PrintLine;
  pls_Fontattr # _WinFontAttrBold;
  PL_PrintLine;
  Pls_FontSize # 10;
  vText # '';

  if (Auf.Vorgangstyp = c_AUF or Auf.Vorgangstyp = c_Ang) then begin
    Lib_Strings:Append(var vText, 'Anfrage' + ' ' + cnvAI(vAnfrageNr), '');
  end;
  PL_Print(vText,cPos0);

  PL_PrintLine;

  Pls_FontSize # 9;
  pls_Fontattr # _WinFontAttrNormal;
  PL_Print(cnvAD(today,_FmtInternal), cPosH1);
  PL_Print_R('Seite: '+cnvAI(aSeite,_FmtInternal), cPosC14);
  PL_PrintLine;
  pls_Fontattr # 0;

  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
    // Lib_Strings:Append(var vText, getSondertext('~401.' + cnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8) + '.K', '$$'), ' ');
    // Pl_Print(vText ,cPos0 );
    PL_PrintLine;
    PL_Print('Hiermit fragen wir zu unseren Ihnen bekannten Einkaufsbedingungen wie folgt an:',cPos0);
    PL_PrintLine;

    PL_PrintLine;
    vTxtHdlTmpRTF # TextOpen(160);    // RTFtextpuffer
    vTxtHdlTmp1 # $edTxt_lang1_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache2.Kurz) then vTxtHdlTmp1 # $edTxt_lang2_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache3.Kurz) then vTxtHdlTmp1 # $edTxt_lang3_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache4.Kurz) then vTxtHdlTmp1 # $edTxt_lang4_head->wpdbTextBuf;
    if (Adr.Sprache=Set.Sprache5.Kurz) then vTxtHdlTmp1 # $edTxt_lang5_head->wpdbTextBuf;
    Lib_Texte:Txt2Rtf(vTxtHdlTmp1,vTxtHdlTmpRTF);

    vTxtHdlName # '~TMP.K541.' + UserInfo(_UserCurrent);

    TxtWrite(vTxtHdlTmpRTF,vTxtHdlName, _TextUnlock);    // Temporären Text sichern
    TextClose(vTxtHdlTmpRTF);
    if (TextInfo(vTxtHdlTmp1,_TextLines) > 0) then
      Lib_Print:Print_Textbaustein(vTxtHdlName,cPos0,cPosCR);
    TxtDelete(vTxtHdlName,0);
    PL_PrintLine;

  end   // 1.Seite
  else begin
    Lib_Print:Print_LinieEinzeln(cPosCL, cPosCR);

  end;

  if (Form_Mode<>'FUSS') then begin

    pls_Inverted  # n;
    pls_FontSize  # 10;
    PL_Print_R('Pos.',cPosC0);
    PL_Print('Materialbeschreibung',cPosC1);
    PL_Print_R('Gew. kg',cPosC10);

    if(Auf.LiefervertragYN)then
      PL_Print('Zeitraum', cPosC12);
    else
      PL_Print('L.-Termin', cPosC12);
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(cPosCL, cPosCR);

  end;

  RekRestore(vBuf100);
  RekRestore(vBuf101);

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
  PL_PrintLine;
  Lib_Print:Print_LinieEinzeln(cPosCL, cPosCR);
  pls_FontSize # 9;
  PL_Print('weiter auf der nächsten Seite' , 73.5);
  PL_PrintLine;
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  vText     : alpha(4000);

  vFlag     : int;
  vMerker   : alpha;
  vPoint    : point;
  vName     : alpha;
  vBuf      : int;
  vBuf400   : int;
  vBuf401   : int;
end;
begin

  case aTyp of
    'Artikel' : begin
      PL_Print(cnvAI(Auf.P.Position),cPos1);
      PL_Print(Art.Bezeichnung1,cPos2);
      PL_PrintF(Auf.P.Menge.Wunsch,2,cPos3a);
      PL_Print(Auf.P.MEH.Wunsch,cPos3b);
      if (Auf.P.MEH.Wunsch<>Auf.P.MEH.Preis) then begin
        if (Auf.P.MEH.Preis='m') or (Auf.P.MEH.Preis='qm') then
          PL_PrintF(vPosMenge,2,cPos4a)
        else if (Auf.P.MEH.Preis='t') then
          PL_PrintF(vPosMenge,3,cPos4a)
        else
          PL_PrintF(vPosMenge,0,cPos4a)

      end;

      PL_PrintI(Auf.P.PEH,cPos5b);
      PL_Print(Auf.P.MEH.Preis,cPos5c);
      PL_Print_R(vRb1,cPos6,cPos5c+7.0);
      PL_PrintLine;

      // Bild ausgeben
      if (Art.Bilddatei<>'') and (Art.Bild.DruckenYN) then begin
        Lib_PrintLine:PrintPic(cPos2,cPos2+50.0,50.0,'*' + Art.Bilddatei);
      end;
    end;  // Artikel  --------------------------------------

    'Aussendienstmitarbeiter' : begin

    end;  // Aussendienstmitarbeiter ------------------------------------

    'Warenempfänger' : begin

      /* >>>> Warenempfänger berücksichtigen?

      // RecLink(100,400,1,_RecFirst);   // Kunde holen
      /*
      if (Auf.Lieferadresse <> 0) and ((Adr.Nummer <> Auf.Lieferadresse) or
        ((Adr.Nummer = Auf.Lieferadresse) and (Auf.Lieferanschrift > 1))) then begin
      */
        // Lieferadresse lesen
        // RecLink(100,400,12,_RecFirst);
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

        PL_Print('Warenempfänger:', cPosCL);
        PL_Print(vWarenempf, cPosKopf3, cPosC14);
        PL_PrintLine;
      //end;

      Warenempfänger berücksichtigen? <<<< */

    end;  // Warenempfänger ------------------------------------

    'Rechnungsempfänger' : begin
      /* >>>> Rechnungsempfänger für Anfrage nicht berücksichtigen!
      Rechnungsempfänger für Anfrage nicht berücksichtigen! <<<< */

    end;  // Rechnungsempfänger ---------------------------------

    'LZB' : begin
      /* >>>> Liefer-/Zahlungsbedingungen für Anfrage nicht berücksichtigen!
      Liefer-/Zahlungsbedingungen für Anfrage nicht berücksichtigen! <<<< */
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
  Erx           : int;
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
      PL_Print('Qualität',      cPosE3);

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
      vText # cnvAF(Mat.Dicke,_FmtNumNoGroup,0,Set.Stellen.Dicke) + ' x ' +
           cnvAF(Mat.Breite,_FmtNumNoGroup,0,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' + cnvAF("Mat.Länge",_FmtNumNoGroup,0,"Set.Stellen.Länge");
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
      vWtrverb # cnvAI(bag.io.vonBAG) + '/' + cnvAI(bag.io.vonPosition) + '/' + cnvAI(bag.io.vonFertigung);
      RekRestore(vBuf);

      pls_FontSize  # 9;
      PL_PrintI(BAG.IO.Plan.In.Stk,  cPosE1);
      // Abmessung
      vText # cnvAF(BAG.IO.Dicke,_FmtNumNoGroup,0,Set.Stellen.Dicke) + ' x ' +
           cnvAF(BAG.IO.Breite,_FmtNumNoGroup,0,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' +
                     cnvAF("BAG.IO.Länge",_FmtNumNoGroup,0,"Set.Stellen.Länge");
      PL_Print(vText + ' mm', cPosE2);

      // Güte
      vText # StrAdj("BAG.IO.Güte",_StrEnd);
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
        c_BAG_Check   : vArbeitsgang # 'Test/Prüfen';
        c_BAG_VSB     : vArbeitsgang # 'VSB/Lager';
        c_BAG_Walz    : vArbeitsgang # 'Walzen';
      end;
      vText # vArbeitsgang + ' (BA '+ cnvAI(Bag.P.Nummer, _FmtNumLeadZero | _FmtNumNoGroup)+'/'+
              cnvAI(Bag.P.Position,  _FmtNumLeadZero | _FmtNumNoGroup)  +') : Fertigung pro Einsatz';

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
          PL_Print_R('Anz',               cPosF1k);
          PL_Print_R('Breite',            cPosF2k);
          PL_Print_R('Länge',             cPosF3k);
          PL_Print(  'Breitentoleranz',   cPosF4k);
          PL_Print(  'Längentoleranz',    cPosF5k);
          PL_Print_R('Plan Stk',          cPosF6k);
          PL_Print_R('Plan kg',           cPosF7k);
          PL_Print_R('Vpg',               cPosF8k);
        end;

        c_BAG_Check   : begin
          vArbeitsgang # 'Test/Prüfen';
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
          //RecLink(100,702,12,_recfirst);
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
          vArbeitsgang # 'Test/Prüfen';
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
          vArbeitsgang # 'Test/Prüfen';
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
        if(BAG.Vpg.AbbindungQ<>0)then vMerker # 'Abbindung '+ cnvAI(BAG.Vpg.AbbindungQ)+' x quer' ;
        //Längs
        if(BAG.Vpg.AbbindungL<>0)then begin
          if (vMerker<>'')then
            vMerker # vMerker+'  '+cnvAI(BAG.Vpg.AbbindungL)+ ' x längs';
          else
            vMerker # 'Abbindung ' + cnvAI(BAG.Vpg.AbbindungL)+' x längs';
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
        ADD_VERP('Nettoabzug: '+cnvAI(CnvIF(BAG.Vpg.Nettoabzug))+' kg','');

      if ("BAG.Vpg.Stapelhöhe" > 0.0) then
        ADD_VERP('max. Stapelhöhe: ',cnvAI(CnvIF("BAG.Vpg.Stapelhöhe"))+' mm');

      if (BAG.Vpg.StapelHAbzug > 0.0) then
        ADD_VERP('Stapelhöhenabzug: ',cnvAI(CnvIF("BAG.Vpg.StapelhAbzug"))+' mm');
      //Ringgewicht
      if (BAG.Vpg.RingKgVon + BAG.Vpg.RingKgBis  <> 0.0) then begin
        if (BAG.Vpg.RingKgVon <> 0.0 and BAG.Vpg.RingKgBis <> 0.0) then
          vMerker # 'Ringgew.: min. ' + cnvAI(CnvIF(BAG.Vpg.RingKgVon)) + ' kg  max. ' + cnvAI(CnvIF(BAG.Vpg.RingKgBis));
        if (BAG.Vpg.RingKgVon <> 0.0 and BAG.Vpg.RingKgBis = 0.0) then
          vMerker # 'Ringgew.: ' + cnvAI(CnvIF(BAG.Vpg.RingKgVon));
        if (BAG.Vpg.RingKgVon = 0.0 and BAG.Vpg.RingKgBis <> 0.0) then
          vMerker # 'Ringgew.: max. ' + cnvAI(CnvIF(BAG.Vpg.RingKgBis));
        if (BAG.Vpg.RingKgVon = BAG.Vpg.RingKgBis) then
          vMerker # 'Ringgew.: ' + cnvAI(CnvIF(BAG.Vpg.RingKgBis));
        vMerker#vMerker+' kg';
        ADD_VERP(vMerker,'')
      end;

      //kg/mm
      if (BAG.Vpg.KgmmVon + BAG.Vpg.KgmmBis  <> 0.0) then begin
        if (BAG.Vpg.KgmmVon <> 0.0 and BAG.Vpg.KgmmBis <> 0.0) then
          vMerker # 'Kg/mm: min. ' + cnvAF(BAG.Vpg.KgmmVon) + ' max. ' + cnvAF(BAG.Vpg.KgmmBis)
        if (BAG.Vpg.KgmmVon <> 0.0 and BAG.Vpg.KgmmBis = 0.0) then
          vMerker # 'Kg/mm: min. ' + cnvAF(BAG.Vpg.KgmmVon)
        if (BAG.Vpg.KgmmVon = 0.0 and BAG.Vpg.KgmmBis <> 0.0) then
          vMerker # 'Kg/mm: max. ' + cnvAF(BAG.Vpg.KgmmBis)
        if (BAG.Vpg.KgmmVon = BAG.Vpg.KgmmBis) then
          vMerker # 'Kg/mm: ' + cnvAF(BAG.Vpg.KgmmBis)
        ADD_VERP(vMerker,'')
      end;

      if ("BAG.Vpg.StückProVE" > 0) then
        ADD_VERP(cnvAI("BAG.Vpg.StückProVE") + ' Stück pro VE', '');

      if (BAG.Vpg.VEkgMax > 0.0) then
        ADD_VERP('max. kg pro VE: ',cnvAI(CnvIF(BAG.Vpg.VEkgMax)));

      if (BAG.Vpg.RechtwinkMax > 0.0) then
        ADD_VERP('max. Rechtwinkligkeit: ', cnvAF(BAG.Vpg.RechtwinkMax));

      if (BAG.Vpg.EbenheitMax > 0.0) then
        ADD_VERP('max. Ebenheit: ', cnvAF(BAG.Vpg.EbenheitMax));

      if ("BAG.VPG.SäbeligMax" > 0.0) then begin
        ADD_VERP('max. Säbeligkeit: ', ANum("BAG.VPG.SäbeligMax", 2) + ' mm');
        if("BAG.VPG.SäbelProM" <> 0.0) then
          Lib_Strings:Append(var vVerp, ' auf ' + ANum("BAG.VPG.SäbelProM", 2) + ' m');
      end;

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

    end;

    'BAG-Verpackungsfuss': begin
      pls_Fontattr # 0;
      PLS_Fontsize # 8;
      Lib_Print:Print_LinieEinzeln(cPosV0,cPosV2Ende);
    end;

  end; // EO case aTyp of

end; // EO sub PrintLohnBA(aTyp : alpha);


//========================================================================
//  AusPLZ
//
//========================================================================
sub AusPLZ()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(847,0,_RecId,gSelected);
    gSelected # 0;
    Adr.LKZ   # Ort.LKZ;
    Adr.PLZ   # Ort.PLZ;
    Adr.Ort   # Ort.Name;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.PLZ->Winfocusset(false);
  gMDI->WinUpdate(_WinUpdFld2Obj);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  Erx           : int;
  // Datenspezifische Variablen
  vTxtName            : alpha;
  vTxt                : alpha;
  vText               : alpha(500);

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;
  vFlag               : int;        // Datensatzlese option
  vTxtHdl             : int;
  vStartPos           : logic;
  vRADFilledYN        : logic;
end;

begin

  vRADFilledYN  # false;
  FOR Erx # RecLink(401, 400, 9, _recFirst); // Pos. loopen
  LOOP Erx # RecLink(401, 400, 9, _recNext); // min. RAD gefuellt?
  WHILE((Erx <= _rLocked) and (vRADFilledYN = false)) DO BEGIN
    if(Auf.P.RAD <> 0.0) then
      vRADFilledYN # true;
  END;

  vMinRadYN # false;
  if(vRADFilledYN = true) then begin
    if(Msg(99, 'Soll der min. RAD mitgedruckt werden?', _WinIcoQuestion, _WinDialogYesNo, 0) = _WinIdYes) then
      vMinRadYN # true;
  end;

  /* -- $$$$ test START -- */
  // vTree # CteOpen(_CteTreeCI);    // ZWEITEN Rambaum anlegen (welcher ist offen? 1., 2. oder beide?? siehe unten!
   // vItem # gMarkList->CteRead(_CteFirst);
   //
   // WHILE (vItem > 0) do begin
   //   Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
   //
   //   if (vMFILE <> 401) then begin
   //     vItem # gMarkList->CteRead(_CteNext); // verursacht Runtimeerror / Deskriptor ungültig??
   //     CYCLE;
   //   end;
   //   /* ---------- */
   //   RecRead(401,0,_RecId,vMID);
   //   vSortKey # cnvai(Auf.P.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,12) + '|' + cnvai(Auf.P.Position,_FmtNumNoGroup|_FmtNumLeadZero,0,12);
   //   Sort_ItemAdd(vTree,vSortKey,vMFILE,RecInfo(vMFILE,_RecId));
   //   /* ---------- */
   //   vItem # gMarkList->CteRead(_CteNext);
   // END;
   // Sort_KillList(vTree);
  /* -- $$$$ test ENDE  -- */


  // ------ Druck vorbereiten ----------------------------------------------------------------

  /* >>>>>> ANFRAGE/ Loop durch markierte LIEFERANTEN! >>xx>> */

  // Ermittelt das erste Element der Liste (oder des Baumes)

  vItem # gMarkList->CteRead(_CteFirst);

  WHILE (vItem > 0) do begin

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile <> 100) then begin
      vItem  # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    if (vMFile = 100) then begin
      RecRead(100,0,_RecId,vMID);

      if (StrFind(vLieferantenOK,cnvai(Adr.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,12),0))>0 then begin

        vItem # gMarkList->CteRead(_CteNext,vItem);
        CYCLE;
      end;

      RecRead(100,0,_RecId,vMID);
      vLieferantenOK # vLieferantenok + cnvai(Adr.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,12) + '|';

      Erx # RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      if(Erx > _rLocked) then
        RecBufClear(101);
      vBAGPrinted # false;

      // universelle PrintLine generieren
      PL_Create(vPL);

      vAnfrageNr # Lib_Nummern:ReadNummer('Anfrage');
      if (vAnfrageNr<>0) then
        Lib_Nummern:SaveNummer()
      else
        RETURN;

      vAnfragePos # 1;

      if (Lib_Print:FrmJobOpen(y,vHeader , vFooter, false, false, false) < 0) then begin
        if (vPL <> 0) then PL_Destroy(vPL);
        RETURN;
      end;


      // Start Dokumentendruck >>>
      // Sprache bestimmen über LIEFERANT!
      Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

      // ARCFLOW
      // DMS_ArcFlow:SetDokName('!SC\Verkauf','AB',Auf.Nummer);

      // ------- KOPFDATEN -----------------------------------------------------------------------

      Lib_Print:Print_Seitenkopf();
      vAdresse    # Adr.Nummer;
      vMwstSatz1 # -1.0;
      vMwstSatz2 # -1.0;

      // ------- POSITIONEN --------------------------------------------------------------------------
      vStartPos # true;
      vGesamtGewicht # 0.0;

      /* >>>>>> ANFRAGE / Loop durch markierte AUFTRAGSPOSITIONEN! >>xx>> */

      vItem # gMarkList->CteRead(_CteFirst);
      vAuftragsPosOK # '';
      WHILE (vItem > 0) do begin
        Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

        if vMFile <> 401 then begin
          vItem # gMarkList->CteRead(_CteNext,vItem);
          CYCLE;
        end;

        RecRead(401,0,_RecId,vMID);
        if (StrFind (vAuftragsPosOK,cnvai((auf.p.nummer *1000) + auf.p.position,_FmtNumNoGroup|_FmtNumLeadZero,0,12),0) >0) then begin
          vItem # gMarkList->CteRead(_CteNext,vItem);
          CYCLE;
        end;

        vAuftragsPosOK # vAuftragsPosOK + cnvai((auf.p.nummer *1000) + auf.p.position,_FmtNumNoGroup|_FmtNumLeadZero,0,12) + '|';

        if ("Auf.P.Löschmarker"='*') then begin
          vItem # gMarkList->CteRead(_CteNext,vItem);
          CYCLE;
        end;

        // Positionstyp bestimmen
        Erx # RecLink(819,401,1,0);     // Warengruppe holen
        if (Erx > _rLocked) then begin
          vItem # gMarkList->CteRead(_CteNext,vItem);
          CYCLE;
        end;

        Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
        if (Erx > _rLocked) then
            RecBufClear(835);

        RecBufClear(250);
        if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
          Erx # RekLink(250,401,2,_RecFirst); // Artikel holen
          if (Erx = _rNoRec) then  begin
            vItem # gMarkList->CteRead(_CteNext,vItem);
            CYCLE;
          end;
        end
        else
        if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false) then begin
          // vItem # st->CteRead(_CteNext,vItem);
          CYCLE;
        end;

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
        if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
          Print('Artikel');
        end;  // ARTIKELDRUCK

        vPosMwSt        # 0.0;
        vPosAnzahlAkt   # 0;
        vPosGewicht     # Auf.P.Gewicht;
        vPosStk         # "Auf.P.Stückzahl";
        vPosNettoRabBar # Auf.P.Gesamtpreis;
        vPosNetto       # Auf.P.Gesamtpreis;

        // MATERIALDRUCK
        if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(auf.p.Wgr.Dateinr)) then begin
          if (AAr.Berechnungsart>=700) then
            Print_MatLohn(vRb1, Auf.P.Menge.Wunsch, vPosMenge, vPosStk);
          else
            Print_Mat(vRb1, Auf.P.Menge.Wunsch, vPosMenge, vPosStk);
        end;

        // Stammdatentext drucken
        if (Art.Nummer <> '') then begin
          vTxtHdl # TextOpen(10);
          Lib_Texte:TxtLoad5Buf('~250.VK.'+cnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),
            vTxtHdl, 0,0,0,0);
          Lib_Print:Print_TextBuffer(vTxtHdl);  // drucken
          TextClose(vTxtHdl);
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

        // >>>> ANFRAGE / Keine Aufpreise / Rabatte!
        //  ANFRAGE / Keine Aufpreise / Rabatte! <<<<

        vItem # gMarkList->CteRead(_CteNext,vItem);

      END;

      /* >>>>>> ANFRAGE / Loop durch markierte AUFTRAGSPOSITIONEN! (nächster / Ende) >>xx>> */

      vFirst # y;

      // ------- FUßDATEN --------------------------------------------------------------------------
      Form_Mode # 'FUSS';
      Lib_Print:Print_LinieDoppelt(cPosCL, cPosCR);

      PL_Print_R('Gesamtgewicht:',cPosC9);
      PL_PrintF(vGesamtGewicht, Set.Stellen.Gewicht, cPosC10);

      PLs_FontSize # 9;

      PL_PrintLine;
      Print('LZB');

      // >>>> AnfrageFußtext holen und ausgeben
      PL_PrintLine;
      vTxtHdlTmpRTF # TextOpen(160);    // RTFtextpuffer
      vTxtHdlTmp1 # $edTxt_lang1_foot->wpdbTextBuf;
      if (Adr.Sprache=Set.Sprache2.Kurz) then vTxtHdlTmp1 # $edTxt_lang2_foot->wpdbTextBuf;
      if (Adr.Sprache=Set.Sprache3.Kurz) then vTxtHdlTmp1 # $edTxt_lang3_foot->wpdbTextBuf;
      if (Adr.Sprache=Set.Sprache4.Kurz) then vTxtHdlTmp1 # $edTxt_lang4_foot->wpdbTextBuf;
      if (Adr.Sprache=Set.Sprache5.Kurz) then vTxtHdlTmp1 # $edTxt_lang5_foot->wpdbTextBuf;
      Lib_Texte:Txt2Rtf(vTxtHdlTmp1,vTxtHdlTmpRTF);

      vTxtHdlName # '~TMP.F541.' + UserInfo(_UserCurrent);

      TxtWrite(vTxtHdlTmpRTF,vTxtHdlName, _TextUnlock);    // Temporären Text sichern
      TextClose(vTxtHdlTmpRTF);
      if (TextInfo(vTxtHdlTmp1,_TextLines) > 0) then
        Lib_Print:Print_Textbaustein(vTxtHdlName,cPos0,cPosCR);
      TxtDelete(vTxtHdlName,0);
      // AnfrageFußtext holen und ausgeben <<<<

      PL_PrintLine;
      PL_PrintLine;
      PL_PrintLine;
      PL_PrintLine;
      PL_Print('Mit freundlichen Grüßen',cPos1);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrBold;
      PL_Print(Set.mfg.Text,cPos1);
      PL_PrintLine;
      pls_FontAttr # _WinFontAttrNormal;

      // -------- Druck beenden ----------------------------------------------------------------

      // aktuellen User holen
      Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
      RecRead(800,1,0);

      // letzte Seite & Job schließen, ggf. mit Vorschau
      Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");

      // Objekte entladen
      if (vPL<>0) then PL_Destroy(vPL);
      if (vPLHeader<>0) then PL_Destroy(vPLHeader)
      else if (vHeader<>0) then vHeader->PrtFormClose();
      if (vPLFooter<>0) then PL_Destroy(vPLFooter)
      else if (vFooter<>0) then vFooter->PrtFormClose();

    end;

    vItem # gMarkList->CteRead(_CteFirst);// TEST

  END;
  /* >>>>>> ANFRAGE / Loop durch markierte LIEFERANTEN! (nächster / letzter) >>xx>> */
  // Sort_KillList(vTree); // Löschen der Liste
end;


//=======================================================================