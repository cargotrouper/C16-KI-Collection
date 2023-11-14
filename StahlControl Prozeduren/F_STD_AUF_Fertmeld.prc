@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_AUF_Fertmeld
//                        OHNE E_R_G
//  Info
//    Druckt eine Fertigmeldung
//
//
//  14.05.2008  DS  Erstellung der Prozedur
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
  cPosE0   : cPos0  // cPosE0   : 10.0
  cPosE1   : cPosE0 + 7.0  // Stk
  cPosE2   : cPosE1 + 5.0   // Abmessung
  cPosE3   : cPosE2 + 55.0  // Güte
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
  cPosF2a   : cPosF1a + 15.0    // Dicke
  cPosF3a   : cPosF2a + 15.0    // Breite
  cPosF3aa  : cPosF3a + 90.0    // Bunde
  cPosF4a   : cPosF3aa + 15.0    // Stk
  cPosF5a   : cPosF4a + 20.0    // Gewicht
  cPosF6a   : cPosF5a + 10.0    // Verpackng

  //Tafeln
  cPosF1b   : cPosF0  + 7.0     // Anzahl
  cPosF2b   : cPosF1b + 15.0    // Dicke
  cPosF3b   : cPosF2b + 15.0    // Breite
  cPosF4b   : cPosF3b + 15.0    // Länge
  cPosF5b   : cPosF4b + 75.0    // Bunde
  cPosF6b   : cPosF5b + 15.0    // Stk
  cPosF7b   : cPosF6b + 20.0    // Gewicht
  cPosF8b   : cPosF7b + 10.0    // Verpackng

  //k: Abcoilen --- FERTIG
  cPosF1k   : cPosF0  + 7.0     // Anzahl
  cPosF2k   : cPosF1k + 15.0    // Dicke
  cPosF3k   : cPosF2k + 15.0    // Breite
  cPosF4k   : cPosF3k + 15.0    // Länge
  cPosF5k   : cPosF4k + 75.0    // Bunde
  cPosF6k   : cPosF5k + 15.0    // Stk
  cPosF7k   : cPosF6k + 20.0    // Gewicht
  cPosF8k   : cPosF7k + 10.0    // Verpackng


  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cPosKopf3 : 35.0  // Feld Lieferanschrift

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0  // Felder Lieferung, Warenempfänger,...
end;

local begin
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
/*
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
*/
  vMenge              : float;
  vPosMenge           : float;
  vPosGewicht         : float;
  vPosStk             : int;
  vPosNetto           : float;
  vPosNettoRabbar     : float;
  vRB1                : alpha;
  vKopfAufpreis       : float;

/*
  // für Verpckungen als Aufpreise
  vVPGPreis           : float;
  vVPGPEH             : int;
  vVPGMEH             : alpha;
*/
  vWtrverb        : alpha;

  // Lohnbearbeitung
  vGedrucktePos       : int;
//  vVerpCheck          : alpha;
//  vVerpUsed          : alpha;
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
  aAdr      # Adr.Nummer;
  aSprache  # Auf.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Auf.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
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
      //vVerpUsed # vVerpUsed + CnvAI(BAG.F.Verpackung,_FmtNumNoGroup | _FmtNumLeadZero,0,5)+';';

      vSumBreite    # vSumBreite + (cnvfi(BAG.F.Streifenanzahl) * BAG.F.Breite);
      vSumStk       # vSumStk + "BAG.F.Fertig.Stk";
      vSumgewichtN  # vSumGewichtN + BAG.F.Fertig.Gew;

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
  PL_PrintLine;

  PL_Print(Adr.A.Name     , cPos0);
  Pls_fontSize # 9;
  PL_Print('Auftragsdatum:',cPosKopf1);
  PL_PrintD_L(Auf.Datum,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.A.Zusatz   , cPos0);
  Pls_fontSize # 9;
  Usr.Username # Auf.Sachbearbeiter;            // Sachbearbeiter holen
  Erx # RecRead(800,1,0);
  PL_Print('Sachbearbeiter:',cPosKopf1);
  PL_Print(Usr.Vorname +' '+Usr.Name,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print("Adr.A.Straße" , cPos0);
  Pls_fontSize # 9;
  PL_Print('Telefon:',cPosKopf1);
  PL_Print(Usr.Telefonnr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(Adr.A.Plz+' '+Adr.A.Ort, cPos0);
  Pls_fontSize # 9;
  PL_Print('Bestellnummer:',cPosKopf1);
  PL_Print(Auf.Best.Nummer,cPosKopf2);
  PL_PrintLine;

  RecLink(812,101,2,_recFirst);   // Land holen
  Pls_fontSize # 10;
  if ("Lnd.kürzel"<>'D') then
    PL_Print(Lnd.Name.L1, cPos0);
  Pls_fontSize # 9;
  PL_Print('Datum:',cPosKopf1);
  PL_PrintD_L(today,cPosKopf2);
  PL_PrintLine;

  PL_Print('Seite:',cPosKopf1);
  PL_PrintI_L(aSeite,cPosKopf2);
  PL_PrintLine;
  PL_PrintLine;

  Pls_FontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  Pl_Print('Fertigmeldung'+' '+AInt(Auf.P.Nummer)   ,cPos0 );
  pl_PrintLine;

  Pls_FontSize # 9;
  pls_Fontattr # 0;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
/*
    PL_PrintLine;
    PL_Print('Wir danken für Ihre Bestellung, die wir gemäss unserer Ihnen bekannten allgemeinen Verkaufsbedingungen',cPos0);
    PL_PrintLine;
    PL_Print('wie folgt gebucht haben:',cPos0);
    PL_PrintLine;
    PL_PrintLine;
*/
  end; // 1.Seite

/*
  if (Form_Mode<>'FUSS') then begin
    pls_FontSize  # 9;
    pls_Inverted  # y;
    pls_FontSize  # 10;
    PL_Print('Pos.',cPos1);
    PL_Print('Beschreibung',cPos2);
    PL_Print_R('Menge',cPos3);
    PL_Print_R('E-Preis '+"Wae.Kürzel",cPos5);
    PL_Print_R('Gesamt',cPos7);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;
  end;
*/
  RekRestore(vBuf100);
  RekRestore(vBuf101);
end;

//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
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
      Auf.P.Gesamtpreis # Rnd((Auf.P.Grundpreis + auf.p.aufpreis) *  vPosMenge / CnvFI(Auf.P.PEH) ,2);
      PL_Print(AInt(Auf.P.Position),cPos1);
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
        PL_Print(Auf.P.MEH.Preis,cPos4b);
      end;
      PL_PrintF(Auf.P.Grundpreis,2,cPos5a);
      PL_Print('je',cPos5a+0.8);
      PL_PrintI(Auf.P.PEH,cPos5b);
      PL_Print(Auf.P.MEH.Preis,cPos5c);
      PL_Print_R(vRb1,cPos6,cPos5c+7.0);
      PL_PrintF(Auf.P.Gesamtpreis,2,cPos7);
      PL_PrintLine;

      // Bild ausgeben
      if (Art.Bilddatei<>'') and (Art.Bild.DruckenYN) then begin
        Lib_PrintLine:PrintPic(cPos2,cPos2+50.0,50.0,'*' + Art.Bilddatei);
      end;
    end;  // Artikel  --------------------------------------
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
  vBunde    : int;

  vMatEtkDicke : float;
  vMatDicke    : float;
  vMatBreite   : float;
  vMatLaenge   : float;

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

      if (BAG.IO.Materialtyp=c_IO_Mat) then begin
        PL_Print_R('Mat.Nr.',     cPosE4);
        PL_Print('Coilnummer',    cPosE5);
      end else
        PL_Print('WV',    cPosE5);

      //PL_Print_R('Gew. Brutto', cPosE6);
      PL_Print_R('Gew. Brutto',  cPosE7);
      //PL_Print_R('Tlg',         cPosE8);
      PL_PrintLine;
      pls_Fontattr # 0;
      Lib_Print:Print_LinieEinzeln(cPosE0,cPosE8+1.0);

      vSumStk         # 0;
      vSumGewichtN    # 0.0;
      vSumGewichtB    # 0.0;

    end;

    // Weiche für die Verschiedenen Einsatztypen
    'BAG-Einsatzposition' : begin
      //if (BAG.IO.Materialtyp=c_IO_Mat) then
      PrintLohnBA('BAG-Einsatzposition-200');

      //if (BAG.IO.Materialtyp=c_IO_703) then
      //  PrintLohnBA('BAG-Einsatzposition-703');

     end;

    // Echtes Einsatzmaterial
    'BAG-Einsatzposition-200' : begin
      PLS_Fontsize # 8;
      // Material lesen
      Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen

      PL_PrintI(Mat.Bestand.Stk,  cPosE1);
      // Abmessung
      vText # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' +
           ANum(Mat.Breite,Set.Stellen.Breite);
      if ("Mat.Länge" <> 0.0) then
        vText # vText + ' x ' +
                     ANum("Mat.Länge","Set.Stellen.Länge");

      PL_Print(vText + ' mm', cPosE2);


      // Güte
      vText # StrAdj("Mat.Güte",_StrEnd);
      if ("Mat.Gütenstufe" <> '') then
        vText # vText +  ' / ' + StrAdj("Mat.Gütenstufe",_StrEnd);
      PL_Print(vText,cPosE3);

      PL_PrintI(Mat.Nummer,                               cPosE4);
      PL_Print(Mat.Coilnummer,                            cPosE5);
      //PL_PrintF(Mat.Gewicht.Brutto, Set.Stellen.Gewicht,  cPosE6);
      PL_PrintF(Mat.Gewicht.Brutto, Set.Stellen.Gewicht,   cPosE7);
      //PL_PrintI(BAG.IO.Teilungen,cPosE8);
      PL_Printline;

      vSumStk         # vSumStk      + Mat.Bestand.Stk;
      vSumGewichtN    # vSumGewichtN + Mat.Gewicht.Netto;
      vSumGewichtB    # vSumGewichtB + Mat.Gewicht.Brutto;

    end;
/*
    // Weiterverarbeitung aus Vorgänger Fertigung
    'BAG-Einsatzposition-703' : begin
      vBuf # rekSave(701);
      reclink(701,703,3,_recfirst);
      vWtrverb # cnvai(bag.io.vonBAG) + '/' + cnvai(bag.io.vonPosition) + '/' + cnvai(bag.io.vonFertigung);
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
      //PL_PrintF(BAG.IO.Plan.In.GewB, Set.Stellen.Gewicht,  cPosE6);
      PL_PrintF(BAG.IO.Plan.In.GewB, Set.Stellen.Gewicht,   cPosE7);
      //PL_PrintI(BAG.IO.Teilungen,cPosE8);
      PL_Printline;

      vSumStk         # vSumStk      + BAG.IO.Plan.In.Stk;
      vSumGewichtN    # vSumGewichtN + BAG.IO.Plan.In.GewN;
      vSumGewichtB    # vSumGewichtB + BAG.IO.Plan.In.GewB;

    end;
*/
    'BAG-Einsatzfuss' : begin
      pls_Fontattr # 0;
      Lib_Print:Print_LinieEinzeln(cPosE0,cPosE8+1.0);
      PLS_Fontsize # 8;
      pls_Fontattr # 0;
      PL_PrintI(vSumStk,     cPosE1);
      //PL_PrintF(vSumGewichtB,Set.Stellen.Gewicht,  cPosE6);
      PL_PrintF(vSumGewichtB,Set.Stellen.Gewicht,  cPosE7);
      PL_PrintLine;
    end;

    //----------- Arbeitsgang -----------
    'BAG-Arbeitsgang': begin
      // Bearbeitungstyp lesen
      case BAG.P.Aktion of
        c_BAG_Spalt   : vArbeitsgang # 'Spalten';
        c_BAG_Tafel   : vArbeitsgang # 'Tafeln';
        c_BAG_ABCOIL  : vArbeitsgang # 'Abcoilen';
      end;
      vText # vArbeitsgang + ' (BA '+ CnvAi(Bag.P.Nummer, _FmtNumLeadZero | _FmtNumNoGroup)+'/'+
              Cnvai(Bag.P.Position,  _FmtNumLeadZero | _FmtNumNoGroup)  +')';

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

        c_BAG_Spalt   : begin
          PL_Print_R( 'Anz',      cPosF1a);
          PL_Print_R( 'Dicke',    cPosF2a);
          PL_Print_R( 'Breite',   cPosF3a);
          Pl_Print_R( 'Bunde',    cPosF3aa);
          PL_Print_R( 'Stk',      cPosF4a);
          PL_Print_R( 'Gewicht',  cPosF5a);
          //PL_Print_R( 'Vpg',       cPosF6a);
        end;

        c_BAG_Tafel   : begin

          PL_Print_R( 'Anz',      cPosF1b);
          PL_Print_R( 'Dicke',    cPosF2b);
          PL_Print_R( 'Breite',   cPosF3b);
          PL_Print_R( 'Länge',    cPosF4b);
          Pl_Print_R( 'Bunde',    cPosF5b);
          PL_Print_R( 'Stk',      cPosF6b);
          PL_Print_R( 'Gewicht',  cPosF7b);
          //PL_Print_R('Vpg',       cPosF8b);
        end;

        c_BAG_ABCOIL  : begin
          PL_Print_R( 'Anz',      cPosF1k);
          PL_Print_R( 'Dicke',    cPosF2k);
          PL_Print_R( 'Breite',   cPosF3k);
          PL_Print_R( 'Länge',    cPosF4k);
          Pl_Print_R( 'Bunde',    cPosF5k);
          PL_Print_R( 'Stk',      cPosF6k);
          PL_Print_R( 'Gewicht',  cPosF7k);
          //PL_Print_R('Vpg',               cPosF8k);
        end;



      end;  // EO Aktionstyp

      PL_PrintLine;
      pls_Fontattr # 0;
      Lib_Print:Print_LinieEinzeln(cPosE0,cPosE8+1.0);

    end; // EO BA-Fertigungskopf


    //---- Fertigungspositionen nach Typ ----
    'BAG-Fertigungsposition': begin
      pls_Fontattr # 0;
      RecLink(707,703,10,0);            // Verwiegung holen
      Erx # RecLink(200,707,7,0);       // Material holen
      if (Erx > _rLocked) then RecBufClear(200);

      if (Mat.Etk.Dicke > 0.0) then vMatDicke # Mat.Etk.Dicke
      else vMatDicke # Mat.Dicke;
      if (Mat.Etk.Breite > 0.0) then vMatBreite # Mat.Etk.Breite
      else vMatBreite # BAG.F.Breite;
      if ("Mat.Etk.Länge" > 0.0) then vMatLaenge # "Mat.Etk.Länge"
      else vMatLaenge # "BAG.F.Länge";

      // Verwiegungen durchtoggeln, um Anzahl der Bunde zu ermitteln
      vBunde # 0;
      Erx # RecLink(707,703,10,_RecFirst);
      While (Erx <= _rLocked) do begin
        vBunde # vBunde + 1;
        Erx # RecLink(707,703,10,_RecNext);
      END;

      case BAG.P.Aktion of

        c_BAG_Spalt   : begin
          PL_PrintI(BAG.F.StreifenAnzahl,                   cPosF1a);
          PL_PrintF(vMatDicke, Set.Stellen.Dicke,           cPosF2a);
          PL_PrintF(vMatBreite, Set.Stellen.Breite,         cPosF3a)
          PL_PrintI(vBunde,                                 cPosF3aa);
          PL_PrintI("BAG.F.Fertig.Stk",                     cPosF4a);
          PL_PrintF(BAG.F.Fertig.Gew, Set.Stellen.Gewicht,  cPosF5a);
          //PL_PrintI(BAG.F.Verpackung,                   cPosF6a);

        end;

        c_BAG_Tafel   : begin
          PL_PrintI(BAG.F.StreifenAnzahl,               cPosF1b);
          PL_PrintF(vMatDicke, Set.Stellen.Dicke,       cPosF2b);
          PL_PrintF(vMatBreite, Set.Stellen.Breite,     cPosF3b);
          PL_PrintF(vMatLaenge, "Set.Stellen.Länge",    cPosF4b);
          PL_PrintI(vBunde         ,                    cPosF5b);
          PL_PrintI("BAG.F.Fertig.Stk",                 cPosF6b);
          PL_PrintF(BAG.F.Fertig.Gew, Set.Stellen.Gewicht, cPosF7b);
          //PL_PrintI(BAG.F.Verpackung,                   cPosF8b);
          vSumLaenge    # vSumLaenge + (cnvfi("BAG.F.Fertig.Stk") / cnvfi(BAG.F.Streifenanzahl)*vMatLaenge);
        end;

        c_BAG_ABCOIL  : begin
          PL_PrintI(BAG.F.StreifenAnzahl,               cPosF1k);
          PL_PrintF(vMatDicke, Set.Stellen.Dicke,       cPosF2k);
          PL_PrintF(vMatBreite, Set.Stellen.Breite,     cPosF3k);
          PL_PrintF(vMatLaenge, "Set.Stellen.Länge",    cPosF4k);
          PL_PrintI(vBunde         ,                    cPosF5k);
          PL_PrintI("BAG.F.Fertig.Stk",                 cPosF6k);
          PL_PrintF(BAG.F.Fertig.Gew, Set.Stellen.Gewicht, cPosF7k);
          //PL_PrintI(BAG.F.Verpackung,                   cPosF8k);

          vSumLaenge    # vSumLaenge + (cnvfi("BAG.F.Fertig.Stk") / cnvfi(BAG.F.Streifenanzahl)*vMatLaenge);
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

        c_BAG_Spalt   : begin
          //PL_Printf(vSumBreite,Set.Stellen.Breite,    cPosF2a);
          PL_PrintI(vSumStk   ,                       cPosF4a);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF5a);
        end;

        c_BAG_Tafel   : begin
          //PL_PrintF(vSumBreite, Set.Stellen.Breite,   cPosF2b);
          PL_PrintF(vSumLaenge, "Set.Stellen.Länge",    cPosF4b);
          PL_PrintI(vSumStk   ,                         cPosF6b);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht,   cPosF7b);
        end;

        c_BAG_ABCOIL  : begin
          //PL_PrintF(vSumBreite, Set.Stellen.Breite,   cPosF2k);
          PL_PrintF(vSumLaenge, "Set.Stellen.Länge",  cPosF4k);
          PL_PrintI(vSumStk   ,                       cPosF6k);
          PL_PrintF(vSumGewichtN,Set.Stellen.Gewicht, cPosF7k);
        end;

      end;  // EO Aktionstyp

      PL_PrintLine;
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
  RecLink(100,400,1,_RecFirst);   // Kunde holen
  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  RecLink(814,400,8,_RecFirst);   // Währung holen
  vBAGPrinted # false;

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
//  Lib_Print:FrmJobOpen(CnvAi(vNummer,_FmtNumNogroup),vHeader , vFooter,y,y,n);
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  // ARCFLOW
  //DMS_ArcFlow:SetDokName('!SC\Verkauf','AB',Auf.Nummer);


// ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();

  vAdresse    # Adr.Nummer;
  //vMwstSatz1 # -1.0;
  //vMwstSatz2 # -1.0;

// ------- POSITIONEN --------------------------------------------------------------------------

  //vFlag # _RecFirst;
  Erx # RecLink(401,400,9,_RecFirst);
  WHILE (Erx <= _rLocked ) DO BEGIN
    //vFlag # _RecNext;

    if ("Auf.P.Löschmarker"='*') then begin
      Erx # RecLink(401,400,9,_RecNext);
      CYCLE;
    end;

    // Positionstyp bestimmen
    Erx # RecLink(819,401,1,0);     // Warengruppe holen
    if (Erx > _rLocked) then begin
      Erx # RecLink(401,400,9,_RecNext);
      CYCLE;
    end;
    RecLink(835,401,5,_recFirst);   // Auftragsart holen

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
    Erx # RecLink(401,400,9,_RecNext);

  END; // WHILE: Positionen ************************************************


  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';
  // 100 MM Rand unten lassen für den Fuss
//  WHILE (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y > PrtUnitLog(110.0,_PrtUnitMillimetres)) do
//    PL_PrintLine;
//  Lib_Print:Print_LinieDoppelt();
/*
  Print('Summe');
  PL_PrintLine;
  Print('LZB');
  Print('Rechnungsempfänger');
  PL_PrintLine;
  Print('Warenempfänger');
  PL_PrintLine;

  // Fusstext drucken
  //vTxtName # '~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F';
  //Lib_Print:Print_Text(vTxtName,1, cPos1);
*/
  PL_PrintLine;
  PL_PrintLine;
  PL_Print('mit freundlichen Grüßen',cPos1);
  PL_PrintLine;
  PL_PrintLine;
  PL_Print(Set.mfg.Text,cPos1)
  PL_PrintLine;

// -------- Druck beenden ----------------------------------------------------------------

  // aktuellen User holen
  Usr.Username # UserInfo(_UserName,CnvIa(UserInfo(_UserCurrent)));
  RecRead(800,1,0);

  // letzte Seite & Job schließen, ggf. mit Vorschau
//  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;


//=======================================================================