@A+
//===== Business-Control =================================================
//
//  Prozedur    Ein_E_Data
//                  OHNE E_R_G
//  Info
//
//
//  28.03.2004  AI  Erstellung der Prozedur
//  30.07.2009  AI  neu: Artikel-Dreiecksgeschäfte
//  28.09.2009  MS  CheckWE2Mat
//  11.03.2010  ST  Materialaktion "WE + Eingangnr"  bei VSB->EING an VSB Karte
//  15.02.2011  AI  neue Chargen
//  26.06.2012  AI  Pos.Löschen nur bei KEINEM Stern
//  11.03.2013  AI  neu: AAr.Ein.E.ReservYN
//  11.04.2013  AI  MatMEH
//  15.04.2013  AI  neue Matkarte erhält beim Insert schon die Artikelnr und Warengruppe
//  20.08.2013  AH  Bugfix: "Aufpreis2Aktion" löscht nicht "wild" irgendwelche Aktionen
//  23.08.2013  AH  NEU: IstJungfrauMat
//  16.10.2013  AH  Anfragen
//  14.11.2013  AH  BugFix: Netto/Brutto darf genau wie Bestandgewicht NICHT beim Ändern in Matkarte geschrieben werden
//  10.02.2014  AH  "Verbuchen": Autolöschen als Setting
//  10.06.2014  AH  Mat.Bestand.Menge wird genullt, damit Formeln dann greifen
//  01.08.2014  ST  "Verbuchen": Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  19.08.2014  AH  BugFix: "Verbuchen" Mat.EK.Preis nur in Wareneingang aufnehmen bei NEUANLAGE (sonst Chaos bei späteren MatAbwertungen)
//  28.11.2014  AH  Neu: "VerbucheArtikelpreise" + Bugfix Mengenhandling
//  19.01.2015  AH  "VerbucheArtikelPreise" nur nutzen, wenn Artikelnr gefüllt ist
//  18.02.2015  AH  Bugfix: "VerbucheArtikelPreis" hat aktuellen Wareneingang mit als Bestand im DS-Preis eingerechnet
//  26.02.2015  AH  Bugfix: "VerbucheArtikelPreis" sperrte Artikelcharge
//  29.05.2015  AH  BugFix: Neue Sätze mit vorbelegter Materialnr. übernahmen den Bestand nicht
//  04.09.2015  ST  BugFix: Verbuchen:Abschlussdatumprüfung nur bei gesetzen Haken
//  08.12.2015  AH  AFX: "Ein.E.Data.VerbucheArtikelPreise"
//  24.05.2016  AH  Neu: "Gegenbuchung"
//  03.06.2016  AH  Neu: Es MUSS immer ein EK-Preis ermittelt werden können
//  28.06.2016  AH  EK-Preis auch rechenn, wenn Karte aus unqualifiziertem Eingang kommt d.h. Mat.Nummer schon existiert
//  14.07.2016  AH  Kopfrabatte werden mit in Position gerechnet
//  03.04.2017  AH  Mat-WE löschen, entfernt Mat.Reseriverungen
//  19.10.2018  AH  Reservierungen für BA-Einsatz übernehmen das Eingangsmaterial
//  11.12.2018  ST  Bugfix: Aufpreise von VSB Materialkarten werden bei Eingang an Eingänge kopiert (sub UpdateMaterial(...))
//  26.07.2019  AH  Fix: neues Mat bekommt erst mal "Bestellt"-Status, damit Statistik nicht bucht! Danach wird ja Status richtig verändert
//  22.04.2021  AH  AFX "Ein.E.UpdateMaterial"
//  14.07.2021  AH  Löschen/Storno von WE-Material verschiebt Res. auf Bestellkarte
//  17.01.2022  AH  Fix: Aufpreis-Mat-Aktionen werden bei WE auf VSB direkt beim Verbuchen des neuen WE erzeugt und nicht "nachgereicht"
//  17.01.2022  AH  ERX
//  2022-11-29  AH  "Verbuchen" berechnet fehlende Mengenfelder
//  2023-01-16  AH  Fix, damit Mat.Aktionen auch in Aufpreise in MEH führen
//  2023-02-23  AH  Änderung ändert nicht zwingend den Materialstatus (Proj. 2511/1)
//  2023-02-28  AH  neues Setting für Bestelltermin aus Zusagetermin (Set.Mat.BestTermin)
//  2023-03-15  AH  KalkNachtrag
//  2023-04-18  AH  BUGFIX für Stückpreise (HWN)
//  2023-04-25  AH  BUGFIX Bestandsänderung setzt Mat.EK.PreisPROMEH (HWN)
//  2023-05-04  ST  Edit: Mat.Lagerplatz wird bei Materialupdate nicht mehr mit Daten aus dem Eingang überschrieben
//  2023-06-05  ST  Neu: "sub UpdateMaterial"  Eingang auf abweichende Lagerort  setzt Material in Versandpool Proj. 2399/103
//
//  Subprozeduren
//    SUB VerbucheArtikelPreise();
//    SUB Aufpreis2Aktion(aPreis : float);
//    SUB FinalAufpreise(aWert : float; aPosMenge : float; aPosStk : int; aPosGew : float) : float;
//    SUB UpdateMaterial(aNeu : logic;opt aGegenbuchung : logic) : logic;
//    SUB CheckWE2Mat() : logic;
//    SUB Verbuchen(aNeuanlage : logic; opt aGegenbuchung : logic; opt aVorlageMat : int) : logic;
//    SUB BildeAnalyseToleranz(aFld : int) : alpha;
//    SUB RecalcPosition();
//    SUB AnalyseError() : alpha;
//    SUB BestandsAenderung()
//    SUB StornoVSBMat() : logic;
//    SUB IstJungfrauMat() : logic;
//========================================================================
@I:Def_Global
@I:Def_Aktionen

//@define LogPreise

//========================================================================
// NUR FÜR MATERIAL, ZUGANG ist bereits gebucht!!!
//========================================================================
sub VerbucheArtikelPreise();
local begin
  Erx         : int;
  vWert       : float;
  vAltBestand : float;
  vZugangM    : float;
  vPreisM     : float;
  vPreis      : float;
  vLetzter    : float;
  v100        : int;
  v200        : int;
end;
begin

  if (RunAFX('Ein.E.Data.VerbucheArtikelPreise','')<0) then RETURN;


  if (Ein.E.Artikelnr='') then RETURN;

  // nur echter EINGANG
  if (Ein.E.EingangYN=false) then RETURN;

  if (AAr.Nummer<>Ein.P.Auftragsart) then
    Erx # RekLink(835,501,5,_recFirst);   // Auftragsart holen

  if (Art.Nummer<>Ein.E.Artikelnr) then
    Erx # RekLink(250,506,5,_RecFirst);     // Artikel holen
  if (Erx>_rLocked) then RETURN;

//  if (Art_P_Data:FindePreis('Ø-EK', 0, 0.0, '', 1)=false) then
//    Art_P_Data:FindePreis('EK', 0, 0.0, '', 1);
  if (Art_P_Data:LiesPreis('Ø-EK', 0)=false) then
    Art_P_Data:LiesPreis('EK', 0);


  if (Art.PEH=0) then Art.PEH # 1;
  if (Ein.P.PEH=0) then Ein.P.PEH # 1;

  vZugangM # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Art.MEH);

  if (Ein.E.MEH2=Ein.P.MEH.Preis) then
    vPreisM # Ein.E.Menge2
  else
    vPreisM # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.P.MEH.Preis);


  // wie "früher"?
  if (AAr.Ein.E.PreisWie='') then begin
    // Artikel-Summen-Charge lesen + sperren
    RecBufClear(252);
    Art.C.ArtikelNr   # Art.Nummer;
    Art_Data:OpenCharge(false);
    vAltBestand # Art.C.Bestand - vZugangM;
  end
  else begin

    // ChargenKarten loopen
    v200 # RekSave(200);
    FOR Erx # RecLink(200, 250, 8, _recfirst)
    LOOP Erx # RecLink(200, 250, 8, _recNext)
    WHILE (Erx<=_rLocked) do begin
      if (Mat.Status>=c_Status_bestellt) and (Mat.Status<=c_status_bisEK) then CYCLE;
      if (Mat.Bewertung.Laut<>'D') or ("Mat.Löschmarker"<>'') or (Mat.EigenmaterialYN=false) then CYCLE;
      if (Mat.Nummer=Ein.E.Materialnr) then CYCLE;  // eigene Karte natürlich NICHT

      vAltBestand # vAltBestand + Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Art.MEH);
    END;
    RekRestore(v200);
  end;

  // bisheriger Wert:
  if (Art.PEH<>0) then vWert # (Art.P.Preis * (vAltBestand / CnvFI(Art.PEH)));
//debugx('ALTwert : '+anum(vWert,0)+' bei ALTbestand '+anum(vAltBestand,0));
//debugx('buche DuEK mit :'+anum(ein.e.preisw1,2)+' bei zugang von '+anum(vPReisM,2)+ein.e.meh+' '+anum(vZugangM,2)+Art.MEH);

  vLetzter  # Ein.E.PreisW1 * vPreisM / Cnvfi(Ein.P.PEH);      // Wertzuwachs
  vWert     # vWert + (Ein.E.PreisW1 * vPreisM / Cnvfi(Ein.P.PEH));

  vPreisM   # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Art.MEH);
  if (vPreisM<>0.0) then
    vLetzter # vLetzter / vPreisM * cnvfi(Art.PEH);
  else
    vLetzter # 0.0;

//debugx('neuer wert : '+anum(vWert,0)+' neue Menge:'+anum(vMenge,0));
  vPreis # 0.0;
  if ((vAltBestand + vZugangM) * CnvFI(Art.PEH)<>0.0) then     // 13.08.2015
    vPreis # Rnd(vWert / (vAltBestand + vZugangM) * CnvFI(Art.PEH) ,5);

//debugx('ergibt preis: '+anum(vPreis,2));

  // Preise updaten
  if (StrFind(AAr.Ein.E.PreisWie,'K',0)=0) then
    Art_P_Data:SetzePreis('Ø-EK', vPreis, 0);

  v100 # RecbufCreate(100);
  Erx # RekLink(v100,501,4,_recfirst);     // Lieferant holen
  if (Erx>_rLocked) then RecbufClear(v100);
  Art_P_Data:SetzePreis('L-EK', vLetzter, v100->Adr.Nummer, 0, '', Ein.E.Eingang_Datum);  // mit Lieferant am 07.08.2012 AI
  RecBufDestroy(v100);

end;


//========================================================================
// Aufpreis2Aktion
//
//========================================================================
sub Aufpreis2Aktion(
  aPreisProT    : float;
  aPreisProMEH  : float;
);
local begin
  Erx : int;
end;
begin

  if (Mat.Nummer = 0) then RETURN;

  RecBufClear(204);
  Mat.A.Materialnr    # Mat.Nummer;
  Mat.A.Aktionstyp    # c_Akt_Aufpreis;
  Mat.A.Aktionsnr     # Ein.Z.Nummer;
  Mat.A.Aktionspos    # Ein.Z.Position;
  Mat.A.Aktionspos2   # Ein.E.Eingangsnr;
  Mat.A.Aktionspos3   # Ein.Z.lfdNr;

  REPEAT
    Erx # RecRead(204,4,0);
    // 20.08.2013 AH
    if (Erx<=_rMultikey) and
      (Mat.A.Materialnr=Mat.Nummer) and
      (Mat.A.Aktionstyp=c_Akt_Aufpreis) and
      (Mat.A.Aktionsnr=Ein.Z.Nummer) and
      (Mat.A.Aktionspos=Ein.Z.Position) and
      (Mat.A.Aktionspos2=Ein.E.Eingangsnr) and
      (Mat.A.Aktionspos3=Ein.Z.lfdNr) then begin
      Rekdelete(204,0,'AUTO');
//      CYCLE;
    end;
  UNTIL (1=1);


  RecBufClear(204);
  Mat.A.Aktionstyp    # c_Akt_Aufpreis;
  Mat.A.Aktionsnr     # Ein.Z.Nummer;
  Mat.A.Aktionspos    # Ein.Z.Position;
  Mat.A.Aktionspos2   # Ein.E.Eingangsnr;
  Mat.A.Aktionspos3   # Ein.Z.lfdNr;
  Mat.A.Aktionsmat    # Mat.Nummer;
  if (Ein.E.VSBYN) then Mat.A.Aktionsdatum  # Ein.E.VSB_Datum;
  if (Ein.E.EingangYN) then Mat.A.Aktionsdatum  # Ein.E.Eingang_Datum;
  if (Ein.E.ausfallYN) then Mat.A.Aktionsdatum  # Ein.E.Ausfall_Datum;
  Mat.A.Adressnr      # 0;
  Mat.A.Bemerkung     # StrCut(Ein.Z.Bezeichnung, 1, 32);
//  Wae_Umrechnen(aPreis,"Ein.E.Währung",var Mat.A.Kosten2W1,1);
//  Mat.A.Kosten2W1 # Rnd(Mat.A.Kosten2W1,2);
  Mat.A.Kosten2W1       # Rnd(aPreisProT / "Ein.Währungskurs",2)
  Mat.A.Kosten2W1ProME  # Rnd(aPreisProMEH / "Ein.Währungskurs",2)

  Erx # Mat_A_Data:Insert(0,'AUTO');
  if (Erx<>_ROK) then TODO('MatAktion-insert FAILED!');
end;


//========================================================================
// FinalAufpreise
//
//========================================================================
sub FinalAufpreise(
  aWert     : float;
  aPosMenge : float;
  aMEH      : alpha;
  aPosStk   : int;
  aPosGew   : float) : float;
local begin
  Erx             : int;
  vMenge          : float;
  vPosNetto       : float;
  vPosNettoRabBar : float;
  vWert           : float;
  vX              : float;
  vPreisProMEH    : float;
  vMengeMat       : float;
end;
begin
  vPosNettoRabBar # aWert;
  vPosNetto       # aWert;
  
  vMengeMat       # Ein.E.Menge;  // 2023-01-16 AH
//debugx(anum(ein.e.menge,0)+' | '+anum(Ein.E.Menge2,0));
  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  Erx # RecLink(503,501,7,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Ein.Z.PEH=0) then Ein.Z.PEH # 1;
    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH<>'%') then begin

      // PosMEH in AufpreisMEH umwandeln
      vMenge # Lib_Einheiten:WandleMEH(506, aPosStk, aPosGew, aPosMenge, aMEH, Ein.Z.MEH);
      vX # Rnd(Ein.Z.Preis * vMenge / CnvFI(Ein.Z.PEH),2);

      vPosNetto # vPosNetto + vX;
      if (Ein.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;

      vWert # vWert + vX;

@ifdef LogPreise
debug('A:'+Ein.Z.Bezeichnung+' '+cnvaf(vX));
@endif

      if (vMengeMat<>0.0) then vPreisProMEH # vX / vMengeMat else vPreisProMEH # 0.0;
      if (Ein.E.Gewicht<>0.0) then vX # vX / Ein.E.Gewicht * 1000.0;
      if (Ein.Z.MatAktionYN) then Aufpreis2Aktion(vX, vPreisProMEH);

    end;
    Erx # RecLink(503,501,7,_RecNext);
  END;

  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  Erx # RecLink(503,501,7,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Ein.Z.PEH=0) then Ein.Z.PEH # 1;
    if (Ein.Z.MengenbezugYN=n) then begin

      if (Ein.Z.PerFormelYN) and (Ein.Z.FormelFunktion<>'') then Call(Ein.Z.FormelFunktion,501);

      if (Ein.Z.Menge<>0.0) then begin

        vX # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

        vPosNetto # vPosNetto + vX;
        if (Ein.Z.RabattierbarYN) then
          vPosNettoRabBar # vPosNettoRabBar + vX;

        vWert # vWert + vX;
@ifdef LogPreise
debug('A:'+Ein.Z.Bezeichnung+' '+cnvaf(vX));
@endif
        if (vMengeMat<>0.0) then vPreisProMEH # vX / vMengeMat else vPreisProMEH # 0.0;
        if (Ein.E.Gewicht<>0.0) then vX # vX / Ein.E.Gewicht * 1000.0;
        if (Ein.Z.MatAktionYN) then Aufpreis2Aktion(vX, vPreisProMEH);
      end;
    end;

    Erx # RecLink(503,501,7,_RecNext);
  END;


  // Aufpreise: %
  // Aufpreise: %
  // Aufpreise: %
  FOR Erx # RecLink(503,501,7,_RecFirst)
  LOOP Erx # RecLink(503,501,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH='%') then begin

      Ein.Z.Preis # vPosNettoRabBar;
      Ein.Z.PEH   # 100;
      vX # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

      vPosNetto # vPosNetto + vX;
      if (Ein.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

      vWert # vWert + vX;
@ifdef LogPreise
debug('A:'+Ein.Z.Bezeichnung+' '+cnvaf(vX));
@endif
      if (vMengeMat<>0.0) then vPreisProMEH # vX / vMengeMat else vPreisProMEH # 0.0;
      if (Ein.E.Gewicht<>0.0) then vX # vX / Ein.E.Gewicht * 1000.0;
      if (Ein.Z.MatAktionYN) then Aufpreis2Aktion(vX, vPreisProMEH);

    end;
  END;


  // KopfAufpreise: MEH-bezogen
  // KopfAufpreise: MEH-Bezogen
  // KopfAufpreise: MEH-Bezogen
  FOR Erx # RecLink(503,500,13,_RecFirst)
  LOOP Erx # RecLink(503,500,13,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Ein.Z.PEH=0) then Ein.Z.PEH # 1;
    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH<>'%') and (Ein.Z.Position=0) then begin
      // PosMEH in AufpreisMEH umwandeln
      vMenge # Lib_Einheiten:WandleMEH(506, aPosStk, aPosGew, aPosMenge, aMEH, Ein.Z.MEH)
      vX # Rnd(Ein.Z.Preis * vMenge / CnvFI(Ein.Z.PEH),2);

      vPosNetto # vPosNetto + vX;
      if (Ein.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + vX;

      vWert # vWert + vX;
@ifdef LogPreise
debug('A:'+Ein.Z.Bezeichnung+' '+cnvaf(vX));
@endif
      if (vMengeMat<>0.0) then vPreisProMEH # vX / vMengeMat else vPreisProMEH # 0.0;
      if (Ein.E.Gewicht<>0.0) then vX # vX / Ein.E.Gewicht * 1000.0;
      if (Ein.Z.MatAktionYN) then Aufpreis2Aktion(vX, vPreisProMEH);
    end;
  END;


  // seit 14.07.2016;
  FOR Erx # RecLink(503,500,13,_RecFirst)
  LOOP Erx # RecLink(503,500,13,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Ein.Z.Position<>0) then CYCLE;

    if (Ein.Z.MengenbezugYN) and (Ein.Z.MEH='%') then begin

      Ein.Z.Preis # vPosNettoRabBar;
      Ein.Z.PEH   # 100;
      vX # Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

      vPosNetto # vPosNetto + vX;
      if (Ein.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + Rnd(Ein.Z.Preis * Ein.Z.Menge / CnvFI(Ein.Z.PEH),2);

      vWert # vWert + vX;
@ifdef LogPreise
debug('A:'+Ein.Z.Bezeichnung+' '+cnvaf(vX));
@endif
      if (vMengeMat<>0.0) then vPreisProMEH # vX / vMengeMat else vPreisProMEH # 0.0;
      if (Ein.E.Gewicht<>0.0) then vX # vX / Ein.E.Gewicht * 1000.0;
      if (Ein.Z.MatAktionYN) then Aufpreis2Aktion(vX, vPreisProMEH);
    end;
  END;


  RETURN vWert;
end;


//========================================================================
//  UpdateMaterial
//        Schreibt die Bestell/Eingangsdaten in das Material
//========================================================================
sub UpdateMaterial(
  aNeu                : logic;
  var aWertOhneKalkW1 : float;
  opt aGegenbuchung   : logic;
  opt aVorlageMat     : int;          // 17.01.2022 AH z.B. das VSB bei WE
  ) : logic;
local begin
  Erx       : int;
  vOK       : logic;
  vGesWert  : float;
  vPreis    : float;
  vDat      : date;
  vZeit     : time;
  vMenge    : float;
  vX,vY     : float;
  vSetPreis : logic;
  
  vEingangMatBeiVsbGegenbuchung : int;
  v200VSB   : int;
  v204VSB   : int;
  v506      : int;
  vWertOhneKalkW1 : float;
  vKalkWertW1     : float;
end;
begin
//debugx(aint(aVorlageMat)+'/'+abool(aNeu)+'/'+abool(aGegenbuchung)+' updatemat KEY506');

  if (Ein.E.VSBYN) then vDat # Ein.E.VSB_Datum;
  if (Ein.E.EingangYN) then vDat # Ein.E.Eingang_Datum;
  if (Ein.E.AusfallYN) then begin
    if (aNeu) then RETURN true;//vDat # Ein.E.ausfall_Datum;
    if (Ein.E.MaterialNr=0) then RETURN true;//vDat # Ein.E.ausfall_Datum;
  end;

  Erx # RecLink(814,506,16,_recFirst);   // Währung holen
  if ("Ein.WährungFixYN"=n) then
    "Ein.Währungskurs" # Wae.EK.Kurs;
  if ("Ein.Währungskurs"=0.0) then "Ein.Währungskurs" # 1.0;

  Erx # RekLink(835,501,5,_recFirst);   // Auftragsart holen

  // VSB Mat Merken, um ggf. später Aufpreisaktionen von ihr zu erben
  if (Ein.E.VSBYN) AND (aGegenbuchung) AND (aNeu = false) then
    vEingangMatBeiVsbGegenbuchung # Mat.Nummer;

  Mat.Nummer # Ein.E.MaterialNr;
  Erx # RecRead(200,1,_recLock);
  if (Erx<>_rOK) then RETURN false;

  Mat.Warengruppe         # Ein.E.Warengruppe;
  "Mat.Güte"              # "Ein.E.Güte";
  "Mat.Gütenstufe"        # "Ein.E.Gütenstufe";

  "Mat.AusführungOben"    # '';
  "Mat.AusführungUnten"   # '';
  Erx # RecLink(507,506,13,_recFirsT);
  WHILE (Erx=_rOK) do begin
    RecBufClear(201);
    Mat.AF.Nummer       # Mat.Nummer;
    Mat.AF.Seite        # Ein.E.AF.Seite;
    Mat.AF.lfdNr        # Ein.E.AF.lfdNr;
    Mat.AF.ObfNr        # Ein.E.AF.ObfNr;
    Mat.AF.Bezeichnung  # Ein.E.AF.Bezeichnung;
    Mat.AF.Zusatz       # Ein.E.AF.Zusatz;
    Mat.AF.Bemerkung    # Ein.E.AF.Bemerkung;
    "Mat.AF.Kürzel"     # "Ein.E.AF.Kürzel";
    Erx # RekInsert(201,0,'AUTO');
    Erx # RecLink(507,506,13,_recNext);
  END;

  Mat.Coilnummer        # Ein.E.Coilnummer;
  Mat.Ringnummer        # Ein.E.Ringnummer;
  Mat.Chargennummer     # Ein.E.Chargennummer;
  Mat.Werksnummer       # Ein.E.Werksnummer;
  Erx # RecLink(100,500,4,_recFirst);   // Rechnungsempf. holen
  if (Ein.Rechnungsempf<>0) and (Ein.Rechnungsempf<>Adr.Lieferantennr) then
    Mat.EigenmaterialYN   # n
  else
    Mat.EigenmaterialYN   # y;

  if (Ein.E.VSBYN=n) then begin
    "Mat.Übernahmedatum"  # vDat
  end
  else begin    // VSB....
    "Mat.Übernahmedatum"  # 0.0.0;
    if (AAr.KonsiYN) then Mat.EigenmaterialYN   # n;
  end;

  Mat.Dicke             # Ein.E.Dicke;
  Mat.Dicke.Von         # Ein.E.Dicke.Von;
  Mat.Dicke.Bis         # Ein.E.Dicke.bis;
  Mat.DickenTolYN       # Ein.E.DickenTolYN;
  Mat.DickenTol         # Ein.E.DickenTol;
  Mat.Breite            # Ein.E.Breite;
  Mat.Breite.Von        # Ein.E.Breite.Von;
  Mat.Breite.Bis        # Ein.E.Breite.Bis;
  Mat.BreitenTolYN      # Ein.E.BreitenTolYN;
  Mat.BreitenTol        # Ein.E.BreitenTol
  "Mat.Länge"           # "Ein.E.Länge";
  "Mat.Länge.Von"       # "Ein.E.Länge.Von";
  "Mat.Länge.Bis"       # "Ein.E.Länge.Bis";
  "Mat.LängenTolYN"     # "Ein.E.LängenTolYN";
  "Mat.LängenTol"       # "Ein.E.LängenTol";
  Mat.RID               # Ein.E.RID;
  Mat.RAD               # Ein.E.RAD;
  if (aNeu) then begin
    Mat.Strukturnr      # Ein.E.Artikelnr;
    Mat.EK.Projektnr    # Ein.P.Projektnummer;
  end;
  if (Mat.Strukturnr='') and (Ein.P.Strukturnr<>'') then
    Mat.Strukturnr      # Ein.P.Strukturnr;

  Mat.Intrastatnr       # Ein.E.Intrastatnr;
  Mat.Ursprungsland     # Ein.E.Ursprungsland;
  Mat.Zeugnisart        # Ein.P.Zeugnisart;
  //Mat.Zeugnisakte       # '';
  "Mat.CO2EinstandProT" # "Ein.E.CO2EinstandPT";
  "Mat.CO2ZuwachsProT"  # 0.0;


  if ("Mat.Löschmarker"='') then begin
    if (aGegenbuchung) then begin
      Mat.Bestand.Stk       # "Ein.E.Stückzahl";
      Mat.Bestand.Gew       # Ein.E.Gewicht;
      // 14.11.2013...
      Mat.Gewicht.Netto     # Ein.E.Gewicht.Netto;
      Mat.Gewicht.Brutto    # Ein.E.Gewicht.Brutto;
      Mat.Bestand.Menge     # 0.0;  // 10.06.2014
    end;
    if (aNeu) then begin
      // 14.11.2013...
      Mat.Bestand.Stk       # "Ein.E.Stückzahl";
      Mat.Bestand.Gew       # Ein.E.Gewicht;
      Mat.Gewicht.Netto     # Ein.E.Gewicht.Netto;
      Mat.Gewicht.Brutto    # Ein.E.Gewicht.Brutto;
      Mat.Bestand.Menge     # 0.0;  // 10.06.2014

      // 09.01.2015
      if (Wgr.Nummer<>Mat.Warengruppe) then RekLink(819, 200, 1, _recfirst);     // Wgr holen
      if (Wgr_Data:IstMix()) then begin
        RekLink(250, 200, 26, _recfirst);  // Artikel holen
        Mat.MEH # Art.MEH;
        if (Mat.MEH=Ein.E.MEH) then Mat.Bestand.Menge # Ein.E.Menge;
      end;

    end;

    if (aNeu) or (Mat.EK.Preis=0.0) then begin
      if (Mat.MEH='') then Mat.MEH # 'kg';    // 2023-01-16 AH

      // Menge in MEHPreis
      vY # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.P.MEH.Preis);
      // Fester EK vorgegeben?? (z.B. druch Eingang auf alten VSB)
      if (Ein.E.PreisW1<>0.0) then begin
        vX # Ein.E.PreisW1 * vY / cnvfi(Ein.P.PEH);
        if (Ein.E.Gewicht<>0.0) then
          vPreis # Rnd(vX / Ein.E.Gewicht*1000.0,5);
      end
      else begin
        // neuen Preis errechnen
        vPreis # Lib_Einheiten:PreisProT(Ein.P.Grundpreis, Ein.P.PEH, Ein.P.MEH.Preis, "Ein.E.Stückzahl",Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.E.Dicke,Ein.E.Breite,"Ein.E.Länge", "Ein.E.Güte", Ein.E.Artikelnr);
@ifdef LogPreise
debug('Basis/t:'+cnvaf(vPreis));
@endif
        vX # Ein.P.Grundpreis * vY / cnvfi(Ein.P.PEH);
@ifdef LogPreise
debug('SumBasis:'+cnvaf(vX)+' bei '+cnvaf(vY)+Ein.P.MEH.Preis);
@endif
        vGesWert # vX;
        vX # FinalAufpreise(vX, vY, Ein.P.MEH.Preis, "Ein.E.Stückzahl" , Ein.E.Gewicht);
        vGesWert # vGesWert + vX;
        if (Ein.E.Gewicht<>0.0) then
          vPreis # vPreis + (vX / Ein.E.Gewicht*1000.0);
        vPreis # Rnd(vPreis / "Ein.Währungskurs",5)
        vGesWert  # Rnd(vGesWert / "Ein.Währungskurs",5);   // 2023-05-04 AH
       end;

      // 23.05.2022 AH z.B. Dextra Holz
      if (vPreis=0.0) then begin
        if (Ein.E.Gewicht<>0.0) then begin
          vPreis # Ein.E.Menge2 * Ein.P.Grundpreis / cnvfi(Ein.P.PEH);
          vPreis # vPreis / Ein.E.Gewicht * 1000.0;
        end;
      end;
      Mat.EK.Preis        # vPreis;
      // 2023-03-14 AH
/* 2023-04-18 AH
      if (Ein.E.MEH=Ein.P.MEH) then
        vX # Ein.E.Menge;
      else
        vX # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge2, Ein.E.MEH2, Ein.P.MEH);
*/
      if (Ein.E.MEH2='') then begin
        Ein.E.MEH2    # Ein.P.MEH;
        Ein.E.Menge2  # vX;
      end;

      // 2023-04-18 AH
      begin
//      DivOrNull(vX, Ein.E.Gewicht, vX, 5);  // RATIO
//      Mat.EK.PreisProMEH  # Rnd(Mat.EK.Preis / 1000.0 * vX,2);
// 2023-04-24 AH      Mat.Bestand.Menge # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge2, Ein.E.MEH2, Mat.MEH);
      Mat.Bestand.Menge # Lib_Einheiten:WandleMEH2(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.E.Menge2, Ein.E.MEH2, Mat.MEH);
      
      DivOrNull(Mat.EK.PreisProMEH, vGesWert, Mat.Bestand.Menge, 5);
//debugx(anum(Mat.EK.Preis,2)+'/t '+anum(Mat.EK.PreisProMEH,2)+'/'+mat.meh+'  bestand:'+anum(mat.Bestand.Menge,2));
      end;

      if (StrFind(AAr.Ein.E.PreisWie,'D',0)>0) then Mat.Bewertung.Laut # 'D';
      vSetPreis # y;
      // 2023-03-15 AH
      vWertOhneKalkW1 # Mat.EK.PreisProMEH * Mat.Bestand.Menge;
      if (vWertOhneKalkW1=0.0) then
        vWertOhneKalkW1 # Mat.EK.Preis * Mat.Bestand.Gew / 1000.0;
    end;

    Mat_Data:SetLoeschmarker("Ein.E.Löschmarker");
  end;

  if (Mat.Status=0) then
    Mat_Data:SetStatus(c_Status_EKVSB);   // 30.05.2017 AH: Fallback  29.05.2018 AH nur wenn LEER

  if (aNeu) then begin
    if (AAr.Ein.E.ReservYN) and (Ein.P.Kommission<>'') then begin
      if (Ein.E.EingangYN) then Mat_Data:SetStatus(c_Status_EKWE);
    end
    else begin
      Mat.Kommission        # Ein.P.Kommission;
      if (Ein.E.GesperrtYN=n) then begin
        if (Ein.E.EingangYN) then Mat_Data:SetStatus(c_Status_EKWE);
        if (Ein.E.VSBYN) and (AAr.KonsiYN) then
          Mat_Data:SetStatus(c_Status_EK_Konsi);
        if (Ein.E.VSBYN) and (AAr.KonsiYN=false) then
          Mat_Data:SetStatus(c_Status_EKVSB);
      end
      else begin
        Mat_Data:SetStatus(c_Status_EKgesperrt);
      end;
    end;

  end
  else begin
    // 2023-02-23 AH  Proj. 2511/1
    v506 # Protokollbuffer[506];
    if (v506<>0) then begin
      if (v506->Ein.E.GesperrtYN=n) and (Ein.E.GesperrtYN) then begin
        Mat_Data:SetStatus(c_Status_EKgesperrt);
      end;
    end;

  end;

  if (Ein.E.Bemerkung<>'') then
    Mat.Bemerkung1        # Ein.E.Bemerkung;
  Mat.Bestellnummer     # AInt(Ein.E.Nummer)+'/'+AInt(Ein.E.Position);
//  Mat.BestellABNr       # Ein.AB.Nummer;
//  if (Ein.P.AB.Nummer<>'') then
  Mat.BestellABNr       # Ein.P.AB.Nummer;

  Mat.Bestelldatum      # Ein.Datum;
  Mat.BestellTermin     # Ein.P.Termin1Wunsch;
  // 2023-02-28 AH
  if (Set.Mat.BestTermin=1) and (Ein.P.TerminZusage<>0.0.0) then
    Mat.BestellTermin     # Ein.P.TerminZusage;
  
  if (Ein.E.EingangYN) then
    Mat.Eingangsdatum     # vDat
  else
    Mat.Eingangsdatum     # 0.0.0;

  if (Ein.E.VSBYN) then
    Mat.Datum.Erzeugt     # Ein.E.VSB_Datum;
  if (Ein.E.EingangYN) then
    Mat.Datum.Erzeugt     # Mat.Eingangsdatum;
  if (Ein.E.AusfallYN) then
    Mat.Datum.Erzeugt     # Ein.E.Ausfall_datum;

  Mat.Erzeuger          # Ein.E.Erzeuger;
  Mat.Lieferant         # Ein.P.Lieferantennr;
  
  // ST 2023-05-04 2469/50:
  //  Lagerplatz nur Initlal übernehmen, wenn die Materialkarte noch keinen Lagerplatz trägt.
  //  Bei Kunden die MDEs einsetzen kann es sein, dass schon Umlagerungen durch den BEtrieb
  //  durchgeführt wurden und eine Anpassung der gemessenenem, chemischen oder Mechanischen Werte
  //  den Lagerplatz wieder auf den Ursprungslagerplatz setzen
  if (Mat.Lagerplatz = '') then
    Mat.Lagerplatz        # Ein.E.Lagerplatz;

  if ("Mat.Löschmarker"='') and ((aNeu) or (Ein.E.VSBYN)) then begin    // 01.04.2022 AH, VSB IMMER
    Mat.Lageradresse      # Ein.E.Lageradresse;
    Mat.Lageranschrift    # Ein.E.Lageranschrift;
  end;

  // Analyse
  if (Set.LyseErweitertYN) then
    Mat.Analysenummer   # Ein.E.Analysenummer;

  Mat.Streckgrenze1     # Ein.E.Streckgrenze;
  Mat.StreckgrenzeB1    # Ein.E.Streckgrenze2;
  Mat.Zugfestigkeit1    # Ein.E.Zugfestigkeit;
  Mat.ZugfestigkeitB1   # Ein.E.Zugfestigkeit2;
  Mat.DehnungA1         # Ein.E.DehnungA;
  Mat.DehnungB1         # Ein.E.DehnungB;
  Mat.DehnungC1         # Ein.E.DehnungC;
  Mat.RP02_V1           # Ein.E.RP02_1;
  Mat.RP02_B1           # Ein.E.RP02_2;
  Mat.RP10_V1           # Ein.E.RP10_1;
  Mat.RP10_B1           # Ein.E.RP10_2;
  "Mat.Körnung1"        # "Ein.E.Körnung";
  "Mat.KörnungB1"       # "Ein.E.Körnung2";
  "Mat.HärteA1"         # "Ein.E.Härte1";
  "Mat.HärteB1"         # "Ein.E.Härte2";
  Mat.RauigkeitA1       # Ein.E.RauigkeitA1;
  Mat.RauigkeitB1       # Ein.E.RauigkeitA2;
  Mat.RauigkeitC1       # Ein.E.RauigkeitB1;
  Mat.RauigkeitD1       # Ein.E.RauigkeitB2;


  Mat.Chemie.C1         # Ein.E.Chemie.C;
  Mat.Chemie.Si1        # Ein.E.Chemie.Si;
  Mat.Chemie.Mn1        # Ein.E.Chemie.Mn;
  Mat.Chemie.P1         # Ein.E.Chemie.P;
  Mat.Chemie.S1         # Ein.E.Chemie.S;
  Mat.Chemie.Al1        # Ein.E.Chemie.Al;
  Mat.Chemie.Cr1        # Ein.E.Chemie.Cr;
  Mat.Chemie.V1         # Ein.E.Chemie.V;
  Mat.Chemie.Nb1        # Ein.E.Chemie.Nb;
  Mat.Chemie.Ti1        # Ein.E.Chemie.Ti;
  Mat.Chemie.N1         # Ein.E.Chemie.N;
  Mat.Chemie.Cu1        # Ein.E.Chemie.Cu;
  Mat.Chemie.Ni1        # Ein.E.Chemie.Ni;
  Mat.Chemie.Mo1        # Ein.E.Chemie.Mo;
  Mat.Chemie.B1         # Ein.E.Chemie.B;
  Mat.Chemie.Frei1.1    # Ein.E.Chemie.Frei1;
  Mat.Mech.Sonstiges1   # Ein.E.Mech.Sonstig;

  // Verpackung
  Mat.Verwiegungsart    # Ein.E.Verwiegungsart;
// 14.11.2013:
//  Mat.Gewicht.Netto     # Ein.E.Gewicht.Netto;
//  Mat.Gewicht.Brutto    # Ein.E.Gewicht.Brutto;
  Mat.AbbindungL        # Ein.E.AbbindungL;
  Mat.AbbindungQ        # Ein.E.AbbindungQ;
  Mat.Zwischenlage      # Ein.E.Zwischenlage;
  Mat.Unterlage         # Ein.E.Unterlage;
  Mat.Umverpackung      # Ein.E.Umverpackung;
  Mat.Wicklung          # Ein.E.Wicklung;
  if (Ein.P.MitLfEYN) then
    Mat.LfENr # -1
  else
    Mat.LfeNr # 0;
  Mat.StehendYN         # Ein.E.StehendYN;
  Mat.LiegendYN         # Ein.E.LiegendYN;
  Mat.Nettoabzug        # Ein.E.Nettoabzug;
  "Mat.Stapelhöhe"      # "Ein.E.Stapelhöhe";
  "Mat.Stapelhöhenabzug" # "Ein.E.Stapelhöhenabz";
  Mat.Rechtwinkligkeit  # Ein.E.Rechtwinkligk;
  Mat.Ebenheit          # Ein.E.Ebenheit;
  "Mat.Säbeligkeit"     # "Ein.E.Säbeligkeit";
  "Mat.SäbelProM"       # "Ein.E.SäbelProM";
  if ("Ein.E.Löschmarker"='*') and
    ((Ein.E.EingangYN) or (Ein.E.VSBYN)) then begin
    if (Mat.Bestand.Stk>0) or (Mat.Bestand.Gew>0.0) then
      Mat_Data:SetStatus(c_Status_EK_Storno);
    Mat.Bestand.Stk       # 0;
    Mat.Bestand.Gew       # 0.0;
    Mat.Gewicht.Netto     # 0.0;
    Mat.Gewicht.Brutto    # 0.0;
    Mat.Bestand.Menge     # 0.0;  // 10.06.2014
    Mat.Ausgangsdatum     # Mat.Eingangsdatum;
  end;

  RunAFX('Ein.E.UpdateMaterial',aBool(aNeu)+'|'+abool(aGegenbuchung));    // 22.04.2021 Ah

  // 2023-03-14 AH
  // 2023-03-15 AH MIT EKK VERBUCHUNG
  if (aNeu) then begin
    if (Ein_Data:CopyPosKalkToMat("Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.E.Eingangsnr, vDat)=false) then RETURN false;
  end;
  Erx # Mat_data:Replace(_RecUnlock,'AUTO');
  if (erx<>_rOK) then RETURN false;
// 2023-03-21 AH
if (Mat.Ratio.MehKg=0.0) then begin
  RETURN false;
end;

  // 03.04.2017 AH: ggf. auch Reservierungen löschen WENN NICHT Gegenbuchung
  if ("Mat.Löschmarker"<>'') then begin
    if (aGegenbuchung=false) then begin
// 19.07.2017 AH:
//      WHILE (RecLink(203,200,13,_recFirst)<=_rLocked) do begin
//        if (Mat_Rsv_Data:Entfernen()=false) then
//          RETURN false;
//      END;
    // 14.07.2021 AH: besser Res. wieder in Bestellkarte schieben
      if (Ein.P.Materialnr<>0) then begin
        WHILE (RecLink(203,200,13,_RecFirst)<_rLockeD) do begin
          if (Mat_Rsv_Data:Entfernen()=false) then BREAK;
          Erx # RecLink(200, 501, 13, _recFirst); // Bestellkarte holen
          if(Erx > _rLocked) then BREAK;
          Mat.R.Materialnr # Mat.Nummer;
          Mat_Rsv_data:NeuAnlegen(Mat.R.Reservierungnr);
          Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
          if (Erx<>_rOK) then BREAK;
        END;
        Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
      end;

    end;
  end;

  // evtl. Preise in Aktion eintragen...
  if (vSetPreis) then begin

    if (Mat_A_Data:Vererben()=false) then RETURN false;

    // 2023-02-06 AH:
//    if (Ein_Data:CopyPosKalkToMat("Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.E.Eingangsnr, Ein.E.Eingang_Datum)=false) then RETURN false;
  end;    // Preis setzen


  // ggf. reservieren?
  if (aNeu) and (AAr.Ein.E.ReservYN) and (Ein.P.Kommission<>'') then begin
    RecBufClear(203);
    Mat.R.Materialnr      # Mat.Nummer;
    "Mat.R.Stückzahl"     # Mat.Bestand.Stk;
    Mat.R.Gewicht         # Mat.Bestand.Gew;
    "Mat.R.Trägertyp"     # '';
    "Mat.R.TrägerNummer1" # 0;
    "Mat.R.TrägerNummer2" # 0;
    Mat.R.Kundennummer    # Auf.P.Kundennr;
    Mat.R.KundenSW        # Auf.P.KundenSW;
    Mat.R.Auftragsnr      # Auf.P.Nummer;
    Mat.R.AuftragsPos     # Auf.P.Position;
    if (Mat_Rsv_Data:Neuanlegen()=false) then RETURN false;
  end;



  // STRECKENVERKAUF???
  if (Set.Ein.OhneStreckVK=false) and (aNeu) and (Ein.E.EingangYN) and (Mat.Auftragsnr<>0) then begin
    Erx # RecLink(401,200,16,_recFirst);    // Auftragspos holen
    if (Erx<=_rLocked) then begin
      Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
      if (Erx<=_rLocked) then begin
        if (Mat.Lageradresse=Auf.Lieferadresse) and (Mat.Lageranschrift=Auf.Lieferanschrift) then begin

          if (Erx<=_rLocked) and (AAr.KonsiYN=n) then begin

            Erx # RecLink(818,401,9,_recFirst);   // Verwiegungsart holen
            if (Erx>_rLocked) then begin
              RecBufClear(818);
              VwA.NettoYN # y;
            end;
            if (VWa.NettoYN) then vMenge # Mat.Gewicht.Netto
            else vMenge # Mat.Gewicht.Brutto;

            vMenge # Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, vMenge, 0.0, '', Auf.P.MEH.Preis);
            if (Ein.E.MEH2=Auf.P.MEH.Preis) then vMenge # Ein.E.Menge2;

//    SUB WandleMEH(aDatei : int; aStk : int; aGewicht : float; aMenge : float; aMEH : alpha; aZielMEH : alpha) : float;
            // DFAKT
//x            vOK # Auf_Data:DFaktMat(Mat.Nummer, Mat.Bestand.Stk, Mat.Gewicht.Netto, Mat.Gewicht.Brutto, vMenge);
            if (Ein.E.Eingang_datum<>0.0.0) then begin
              if (Ein.E.Eingang_Datum=today) then vZeit # now;
              vOK # Auf_Data:DFaktMat_DoIt(n, Mat.Bestand.Stk, Mat.Gewicht.Netto, Mat.Gewicht.Brutto, vMenge, Mat.Eingangsdatum, vZEit);
            end;
            else if (Ein.E.VSB_datum<>0.0.0) then begin
              if (Ein.E.VSB_Datum=today) then vZeit # now;
              vOK # Auf_Data:DFaktMat_DoIt(n, Mat.Bestand.Stk, Mat.Gewicht.Netto, Mat.Gewicht.Brutto, vMenge, Ein.E.VSB_Datum, vZeit);
            end;
            if (vOK=false) then RETURN false;

          end;
        end;
      end;
    end;
  end;

  // 17.01.2022 AH: Neu, Aktionen aus Vorlage kopieren
  if (Ein.E.EingangYN) AND (aGegenbuchung=false) AND (aNeu) AND (aVorlageMat<>0) then begin

    if (Set.Ein.GetPreisImWE<>1) then begin     // 13.06.2022 AH: 2208/4 nur wenn Preis NICHT neu berechnen!
      // ggf. Aufpreise vom VSB Mat in Neue Karte übertragen
      Mat.Nummer # aVorlageMat;
      FOR   Erx # RecLink(204,200,14,_RecFirst)
      LOOP  Erx # RecLink(204,200,14,_RecNext)
      WHILE Erx = _rOK DO BEGIN
        if (Mat.A.Aktionstyp <> c_Akt_Aufpreis) then
          CYCLE;
      
        v204VSB # RekSave(204);
        Mat.Nummer        # Ein.E.Materialnr;
        Mat.A.Materialnr  # Ein.E.Materialnr;
        Mat.A.Aktionsmat  # Ein.E.Materialnr;
        Mat_A_Data:Insert(0,'AUTO');
        RekRestore(v204VSB);
        Mat.Nummer # aVorlageMat;
      END;
    end;
  end;
  
  
  // ST 2023-06-05 Proj. 2399/103
  // Bei VSB-EK auf anderen Lagerort per Versandpool abholbar machen
  if (Set.LFS.mitVersandYN) AND (Ein.E.VSBYN) AND (aNeu) AND (aVorlageMat = 0) then begin
  
    // Mater8al
    if !((Ein.E.Lageradresse   = Ein.Lieferadresse) AND
        (Ein.E.Lageranschrift = Ein.Lieferanschrift)) then begin

      Vsp_Data:Mat2Pool(Ein.E.Materialnr, c_VSPTyp_Ein, Ein.E.Nummer, Ein.E.Position, Ein.E.Eingangsnr);
       
    end;
  
  end;
  
  

/**** 17.01.2022 ALT
  // ggf. Aufpreise vom VSB Mat in Neue Karte übertragen
  // VSB Mat merken, um ggf. später Aufpreisaktionen von ihr zu erben
  if (Ein.E.VSBYN) AND (aGegenbuchung) AND (aNeu = false) then begin
    
    FOR   Erx # RecLink(204,200,14,_RecFirst)
    LOOP  Erx # RecLink(204,200,14,_RecNext)
    WHILE Erx = _rOK DO BEGIN
      if (Mat.A.Aktionstyp <> c_Akt_Aufpreis) then
        CYCLE;
    
      v200VSB # RekSave(200);
      v204VSB # RekSave(204);
      
      // Aktion in neues Mat einfügen
      Mat_Data:Read(vEingangMatBeiVsbGegenbuchung);
      
      Mat.A.Materialnr # Mat.Nummer;
      Mat.A.Aktionsmat # Mat.Nummer;

      Mat_A_Data:Insert(0,'AUTO');
      
      RekRestore(v204VSB);
      RekRestore(v200VSB);
    END;
  end;
****/

  // Analyse + Preis vererben...
  Mat_Data:VererbeDaten(y,y);

  aWertOhneKalkW1 # vWertOhneKalkW1;
  RETURN true;
end;


//========================================================================
//  CheckWE2Mat
//  Beim Speichern eines veränderten WE für Material prüfen, ob es Abweichungen
//  der Vor-Änderungs-Werte (aus Protokolldatei) gegenüber der Materialdatei gibt.
//  (NICHT Preis, Lagerort, Stk, Gewicht)
////========================================================================
sub CheckWE2Mat() : logic;
begin
    if(ProtokollBuffer[506]->"Ein.E.Güte" <> "Mat.Güte") then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Gütenstufe" <> "Mat.Gütenstufe") then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Erzeuger <> Mat.Erzeuger) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Coilnummer <> Mat.Coilnummer) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Ringnummer <> Mat.Ringnummer) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Werksnummer <> Mat.Werksnummer) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chargennummer <> Mat.Chargennummer) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Dicke <> Mat.Dicke) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.DickenTol <> Mat.DickenTol) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Dicke.Von <> Mat.Dicke.Von) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Dicke.Bis <> Mat.Dicke.Bis) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Breite <> Mat.Breite) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.BreitenTol <> Mat.BreitenTol) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Breite.Von <> Mat.Breite.Von) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Breite.Bis <> Mat.Breite.Bis) then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Länge" <> "Mat.Länge") then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.LängenTol" <> "Mat.LängenTol") then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Länge.Von" <> "Mat.Länge.Von") then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Länge.Bis" <> "Mat.Länge.Bis") then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RID <> Mat.RID) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RAD <> Mat.RAD) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.AusfOben <> "Mat.AusführungOben") then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.AusfUnten <> "Mat.AusführungUnten") then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Ursprungsland <> Mat.Ursprungsland) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Verwiegungsart <> Mat.Verwiegungsart) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Gewicht.Netto <> Mat.Gewicht.Netto) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Gewicht.Brutto <> Mat.Gewicht.Brutto) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.AbbindungL <> Mat.AbbindungL) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.AbbindungQ <> Mat.AbbindungQ) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Zwischenlage <> Mat.Zwischenlage) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Unterlage <> Mat.Unterlage) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Umverpackung <> Mat.Umverpackung) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Wicklung <> Mat.Wicklung) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.StehendYN <> Mat.StehendYN) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.LiegendYN <> Mat.LiegendYN) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Nettoabzug <> Mat.Nettoabzug) then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Stapelhöhe" <> "Mat.Stapelhöhe") then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Stapelhöhenabz" <> "Mat.Stapelhöhenabzug") then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Rechtwinkligk <> Mat.Rechtwinkligkeit) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Ebenheit <> Mat.Ebenheit) then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Säbeligkeit" <> "Mat.Säbeligkeit") then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.SäbelProM" <> "Mat.SäbelProM") then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Streckgrenze <> Mat.Streckgrenze1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Streckgrenze2 <> Mat.StreckgrenzeB1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Zugfestigkeit <> Mat.Zugfestigkeit1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Zugfestigkeit2 <> Mat.ZugfestigkeitB1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.DehnungA <> Mat.DehnungA1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.DehnungB <> Mat.DehnungB1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Dehnungc <> Mat.DehnungC1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RP02_1 <> Mat.RP02_V1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RP02_2 <> Mat.RP02_B1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RP10_1 <> Mat.RP10_V1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RP10_2 <> Mat.RP10_B1) then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Körnung" <> "Mat.Körnung1") then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Körnung2" <> "Mat.KörnungB1") then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.C <> Mat.Chemie.C1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Si <> Mat.Chemie.Si1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Mn <> Mat.Chemie.Mn1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.P <> Mat.Chemie.P1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.S <> Mat.Chemie.S1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Al <> Mat.Chemie.Al1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Cr <> Mat.Chemie.Cr1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.V <> Mat.Chemie.V1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Nb <> Mat.Chemie.Nb1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Ti <> Mat.Chemie.Ti1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.N <> Mat.Chemie.N1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Cu <> Mat.Chemie.Cu1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Ni <> Mat.Chemie.Ni1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Mo <> Mat.Chemie.Mo1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.B <> Mat.Chemie.B1) then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Härte1" <> "Mat.HärteA1") then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Chemie.Frei1 <> Mat.Chemie.Frei1.1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.Mech.Sonstig <> Mat.Mech.Sonstiges1) then RETURN false;
    if(ProtokollBuffer[506]->"Ein.E.Härte2" <> "Mat.HärteB1") then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RauigkeitA1 <> Mat.RauigkeitA1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RauigkeitA2 <> Mat.RauigkeitB1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RauigkeitB1 <> Mat.RauigkeitC1) then RETURN false;
    if(ProtokollBuffer[506]->Ein.E.RauigkeitB2 <> Mat.RauigkeitD1) then RETURN false;

    RETURN true;
end;


//========================================================================
//  Verbuchen
//        verbucht einen Wareneingang/VSB/Ausfall
//========================================================================
sub Verbuchen(
  aNeuanlage        : logic;
  opt aGegenBuchung : logic;
  opt aVorlageMat   : int;
  ) : logic;
local begin
  Erx         : int;
  vZeit       : time;
  vOk         : logic;
  vNr         : int;
  vMenge      : float;
  vMenge2     : float;

  vPreis      : float;
  vPreisArt   : float;
  vArtMEH     : alpha;
  vEinEMEH    : alpha;
  vEinPMEH    : alpha;
  vCharge     : alpha;
  vX          : float;
  vMengeBest  : float;

  vAltMenge   : float;
  vAltStk     : int;
  vAltGew     : float;
  vWarVSB     : logic;
  vWarEingang : logic;
  vWarAusfall : logic;

  vNeu        : logic;
  vRestAlt    : float;
  vBuf506     : int;

  vProz       : float;
  vDel        : logic;

  vVsbKarte   : int;
  vMatTmp     : handle;
  vA          : alpha;
  vFixed      : logic;
  vWertOhneKalkW1  : float;
end;
begin

  // Prüfung auf Abschlussdatum
// 16.02.2017 AH: muss "einfache" Felder doch ändern können wie z.B. Chemie
//  if ((Ein.E.VSBYN)     AND (Ein.E.VSB_Datum <> 0.0.0)     AND (Lib_Faktura:Abschlusstest(Ein.E.VSB_Datum) = false))      OR
//     ((Ein.E.EingangYN) AND (Ein.E.Eingang_Datum <> 0.0.0) AND (Lib_Faktura:Abschlusstest(Ein.E.Eingang_Datum) = false))  OR
//     ((Ein.E.AusfallYN) AND (Ein.E.Ausfall_Datum <> 0.0.0) AND (Lib_Faktura:Abschlusstest(Ein.E.Ausfall_Datum) = false))
//   then begin
//    RETURN false;
//  end;

// 2022-11-29 AH    ggf. fehlende, aber nötige Daten(Sätze) laden/errechnen
  if (aNeuanlage) and (aGegenBuchung=false) and (Ein.P.Materialnr<>0) then begin
    If (Mat.Nummer<>Ein.P.Materialnr) then
      Erx # RekLink(200,501,13,_recFirst);  // Bestell-Material holen
  end;
/*vDebug # 'KEY500 KEY501 KEY506 KEY250 KEY200';
Lib_Soa:Dbg(vDebug);
debugx(vDebug)
Lib_Debug:Protokoll('d:\c16\!AlexDebug.txt','START VERBUCHEN');
Lib_Debug:Protokoll('d:\c16\!AlexDebug.txt',Lib_Debug:_ParseText(vDebug));*/
  if (Ein.E.menge=0.0) then begin
    if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
      Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
    end
    else if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
      Ein.E.Menge # Ein.E.Gewicht;
    end;
    if (Ein.E.Menge=0.0) then Ein.E.Menge # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, 0.0,'', Ein.E.MEH);
    vFixed # (Ein.E.Menge<>0.0);
  end;
  if (Ein.E.Menge2=0.0) then begin
    if (StrCnv(Ein.E.MEH2,_Strupper)='STK') then begin
      Ein.E.Menge2 # cnvfi("Ein.E.Stückzahl");
    end
    else if (StrCnv(Ein.E.MEH2,_Strupper)='KG') then begin
      Ein.E.Menge2 # Ein.E.Gewicht;
    end if (Ein.E.MEH2<>'') then begin
      if (Ein.E.Menge2=0.0) then Ein.E.Menge2 # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.E.MEH2);
    end;
    vFixed # (Ein.E.Menge2<>0.0);
  end;
  if (Ein.E.Gewicht.Brutto=0.0) then begin
    Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
    vFixed # true;
  end;
  if (Ein.E.Gewicht.Netto=0.0) then begin
    Ein.E.Gewicht.Netto # Ein.E.Gewicht;
    vFixed # true;
  end;
  if (vFixed) then begin  // gefixte Daten rückspeichern
    RecRead(506,1,_recLock|_RecNoload);
    Erx # RekReplace(506,_recUnlock,'AUTO');
  end;


  if (aNeuanlage=n) then begin
    if (ProtokollBuffer[506]->"Ein.E.Löschmarker"='') then begin
      vAltGew   # ProtokollBuffer[506]->Ein.E.Gewicht;
      vAltStk   # ProtokollBuffer[506]->"Ein.E.Stückzahl";
      vAltMenge # ProtokollBuffer[506]->Ein.E.Menge;
      if ("Ein.E.Löschmarker"='*') then vDel # y;
    end;
    vWarVSB     # ProtokollBuffer[506]->Ein.E.VSBYN;
    vWarEingang # ProtokollBuffer[506]->Ein.E.EingangYN;
    vWarAusfall # ProtokollBuffer[506]->Ein.E.AusfallYN;

  end;

  // Bestellkopf holen
  RekLink(500,501,3,_recFirst); // Kopf holen
  if (EIn.Vorgangstyp<>c_Bestellung) then RETURN false;


  Erx # RecLink(814,506,16,_recFirst);   // Währung holen
  if ("Ein.WährungFixYN"=n) then
    "Ein.Währungskurs" # Wae.EK.Kurs;
  if ("Ein.Währungskurs"=0.0) then "Ein.Währungskurs" # 1.0;
@ifdef LogPreise
debug('-------------');
@endif

  // MATERIAL ****************11.03.2010********************************************
  if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin

    if (aNeuanlage) and (Ein.E.Materialnr=0) then begin
      vNeu # y;
      if (Ein.E.AusfallYN=n) then begin

        vNr # Lib_Nummern:ReadNummer('Material');
        if (vNr<>0) then Lib_Nummern:SaveNummer()
        else RETURN false;
        RecRead(506,1,_recLock);
        Ein.E.MaterialNr  # vNr;
//        Ein.E.Menge       # Ein.E.Gewicht;
        Erx # RekReplace(506,_recUnlock,'AUTO');
        if (erx<>_rOK) then RETURN false;

        if (aVorlageMat=0) then begin
          RecBufClear(200);
        end
        else begin
          Mat.Nummer # aVorlageMat;
          Erx # RecRead(200,1,0);   // Vorlage Material holen
          if (Erx>_rLocked) then RecBufClear(200);
          Mat.Status # c_Status_Bestellt;
// 26.07.2019 weiter unten   in UpdateMaterial        Mat_Data:SetStatus(c_Status_EKWE)
        end;
        Mat.Nummer    # vNr;
        Mat.Ursprung  # vNr;

        // 15.04.2013:
        Mat.Strukturnr      # Ein.E.Artikelnr;
        if (Mat.Strukturnr='') and (Ein.P.Strukturnr<>'') then
          Mat.Strukturnr    # Ein.P.Strukturnr;
        Mat.Warengruppe         # Ein.E.Warengruppe;
        // 26.07.2019 AH: Damit Statistik das nicht als Umbuchung bucht:
        "Mat.Güte"          # "Ein.E.Güte";
        Erx # RecLink(100,500,4,_recFirst);   // Rechnungsempf. holen
        if (Ein.Rechnungsempf<>0) and (Ein.Rechnungsempf<>Adr.Lieferantennr) then
          Mat.EigenmaterialYN   # n
        else
          Mat.EigenmaterialYN   # y;
        if (Ein.E.VSBYN) then begin
            Erx # RekLink(835,501,5,_recFirst);   // Auftragsart holen
          if (AAr.KonsiYN) then Mat.EigenmaterialYN   # n;
        end;

        Mat.Bestand.Menge     # 0.0;  // 10.06.2014
        if (Mat.Eingangsdatum=today) then vZeit # now;
        Erx # Mat_Data:Insert(0,'AUTO', Mat.Eingangsdatum);
        if (Erx<>_rOK) then RETURN false;

        // Aktion an VSB Karte anhängen und auf Eingangskarte verweisen
        if (Ein.E.EingangYN) AND (Ein.E.VSB_Datum != 00.00.00) then begin
          // Vsbkarte Lesen
          vMatTmp # RekSave(200);
          Erx # Mat_data:read(aVorlageMat);
          if (Erx<200) then RETURN false;

          // Aktion anlegen
          RecBufClear(204);
          Mat.A.Aktionsmat    # aVorlageMat;
          Mat.A.Entstanden    # 0;
          Mat.A.Aktionstyp    # 'INFO';
          Mat.A.Aktionsdatum  # today;
          Mat.A.Bemerkung     # 'WE ' + AInt(vNr);
          Mat_A_Data:Insert(0,'AUTO');

          RekRestore(vMatTmp);
        end;

      end;
    end;

    // 29.05.2015 AH: bei Neuanlage aber Vorgabe von Materialnr, auch BESTAND ÜBERNEHMEN
    if (UpdateMaterial(vNeu or (aNeuanlage and Ein.E.Materialnr<>0), var vWertOhneKalkW1, aGegenbuchung, aVorlageMat)=false) then begin
      RETURN false;
    end;
    // Gesamtpreis wieder in den Wareneingang aufnehmen NUR BEI NEUANLAGE
    if (Ein.E.AusfallYN=falsE) and (aNeuanlage) then begin
      vX # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.P.MEH.Preis);
      if (vX<>0.0) then begin
        if ("Ein.WährungFixYN"=n) then
          "Ein.Währungskurs" # Wae.EK.Kurs;
        if ("Ein.Währungskurs"=0.0) then "Ein.Währungskurs" # 1.0;
// 2023-03-15 AH        vPreis # Rnd(Mat.Bestand.Gew * Mat.EK.Preis / 1000.0,5)
//        vPreis # Rnd(vPreis / vX * cnvfi(Ein.P.PEH),5);
        vPreis # Rnd(vWertOhneKalkW1 / vX * cnvfi(Ein.P.PEH),5);
        if (Ein.E.PreisW1<>vPreis) then begin
          RecRead(506,1,_recLock);
//debugx('set:'+anum(ein.e.preis,2)+' auf '+anum(vPreis,2));
          Ein.E.PreisW1 # vPreis;
          Ein.E.Preis   # Rnd(vPreis * "Ein.Währungskurs",5)
          Erx # RekReplace(506,_recUnlock,'AUTO');
          if (erx<>_rOK) then RETURN false;
        end;
      end;
    end;

//    vEinEMEH # 'kg';
//    vEinPMEH # 'kg';
    vEinEMEH # StrCnv(Ein.E.MEH,_StrUpper);
    vEinPMEH # StrCnv(Ein.P.MEH,_StrUpper);

    VerbucheArtikelPreise();

  end   // Material

  // ARTIKEL *************************************************************
  else if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstHuB(Ein.P.Wgr.Dateinr)) then begin
    RecBufClear(200); // Materialpuffer leeren

    Erx # RecLink(250,506,5,_RecFirst);     // Artikel holen
    if (Erx>_rLocked) then RETURN false;

    vArtMEH # StrCnv(Art.MEH,_StrUpper);
    vEinEMEH # StrCnv(Ein.E.MEH,_StrUpper);
    vEinPMEH # StrCnv(Ein.P.MEH,_StrUpper);


    if (vArtMEH=vEinEMEH) then    vMenge # Ein.E.Menge - vAltMenge
    else if (vArtMEH='STK') then  vMenge # CnvFI("Ein.E.Stückzahl"-vAltStk)
    else if (vArtMEH='KG') then   vMenge # Ein.E.Gewicht - vAltGew
    else if (vArtMEH='T') then    vMenge # (Ein.E.Gewicht - vAltGew) / 1000.0;

    // Preis Menge errechnen
//todo('stk:'+cnvai("ein.e.stückzahl")+'  gewicht:'+cnvaf(ein.e.gewicht)+'  menge:'+cnvaf(ein.e.menge)+ein.e.MEH);
    if (vMenge<>0.0) then begin
      vMengeBest # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.P.MEH.Preis);
      //vPreis # Ein.P.Einzelpreis / Cnvfi(Ein.P.PEH) * vX;
      vPreis # Ein.P.Grundpreis / Cnvfi(Ein.P.PEH) * vMengeBest;
@ifdef LogPreise
todo('Grundsumme:'+cnvaf(vPreis)+' für '+cnvaf(vMengeBest)+Ein.P.MEH.Preis);
@endif
      vX # FinalAufpreise(vPreis, vMengeBest, Ein.P.MEH.Preis, "Ein.E.Stückzahl" , Ein.E.Gewicht);
      vPreis # vPreis + vX;

      // wieder in ART-PEH umrechnen...
      vPreisArt # vPreis / vMenge * Cnvfi(Art.PEH);
      vPreis # vPreis / vMengeBest * Cnvfi(Ein.P.PEH);

@ifdef LogPreise
todo('finaler BestPreis:'+cnvaf(vPreis)+' / '+AInt(Ein.P.PEH)+' '+Ein.P.MEH.Preis);
todo('finaler ArtPreis:'+cnvaf(vPreisArt)+' / '+AInt(Art.PEH)+' '+Art.MEH);
@endif
      // Preis in Hauswährung errechnen
      if ("Ein.WährungFixYN"=n) then
        "Ein.Währungskurs" # Wae.EK.Kurs;
      if ("Ein.Währungskurs"=0.0) then "Ein.Währungskurs" # 1.0;
      vPreis # vPreis / "Ein.Währungskurs";
      vPreisArt # vPreisArt / "Ein.Währungskurs";

//todo('P-menge:'+cnvaf(vX)+'   artMenge: '+cnvaf(vMenge)+'   einzelpreis:'+cnvaf(vPreis));

      // echter Eingang? dann Artikelbewegung buchen
      if (Ein.E.EingangYN=y) then begin
        RecBufClear(252);
        Art.C.Charge.Intern # Ein.E.Charge;
        Art.C.ArtikelNr     # Ein.E.ArtikelNr;
/**
        if (aNeuanlage=n) then begin
          Erx # RecRead(252,1,_recLock);
          if (Erx<>_rOK) then RETURN false;
        end;
**/
        Art.C.Lieferantennr # Ein.E.Lieferantennr;
        Art.C.AdressNr      # Ein.E.Lageradresse;
        Art.C.AnschriftNr   # Ein.E.Lageranschrift;
        Art.C.Zustand       # Ein.E.Art.Zustand;
        Art.C.Dicke         # Ein.E.Dicke;
        Art.C.Breite        # Ein.E.Breite;
        "Art.C.Länge"       # "Ein.E.Länge";
        Art.C.RID           # Ein.E.RID;
        Art.C.RAD           # Ein.E.RAD;
        Art.C.Lagerplatz    # Ein.E.Lagerplatz;
        Art.C.Charge.Extern # Ein.E.Chargennummer;
        Art.C.Bezeichnung   # Ein.E.Bemerkung;
        Art.C.Bestellnummer # AInt(Ein.P.Nummer)+'/'+AInt(Ein.P.Position);

        if (aNeuanlage) then begin
          RecBufClear(253);
          Art.J.Datum           # Ein.E.Eingang_Datum;
          Art.J.Bemerkung       # Translate('Wareneingang')+' '+AInt(Ein.E.Nummer)+'/'+AInt(Ein.E.Position)+'/'+AInt(Ein.E.Eingangsnr);
          "Art.J.Stückzahl"     # "Ein.E.Stückzahl";
          Art.J.Menge           # vMenge;
          "Art.J.Trägertyp"     # 'WE';
          "Art.J.Trägernummer1" # Ein.E.Nummer;
          "Art.J.Trägernummer2" # Ein.E.Position;
          "Art.J.Trägernummer3" # Ein.E.Eingangsnr;
          Erx # RecLink(100,506,3,_recFirst);   // Lieferant holen
          vOK # Art_Data:Bewegung(rnd(vPreisArt,2), 0.0, Adr.Nummer);
          if (vOK=false) then RETURN false;

          RecRead(506,1,_RecLock);    // Charge im WE merken
          Ein.E.Charge # Art.C.Charge.intern;//vCharge;
          // Gesamtpreis wieder in Bestellposition aufnehmen
          Ein.E.PreisW1 # vPreis;// * cnvfi(Ein.P.PEH); AI 03.08.2011
          Ein.E.Preis   # Rnd(Ein.E.PreisW1 * "Ein.Währungskurs",2)
          RekReplace(506,_recUnlock,'AUTO');
/***
        end
        else begin
          Erx RekReplace(252,_recUnlock,'MAN');
          if (Erx<>_rOK) then RETURN false;
***/
        end;

        // Bestellte Menge reduzieren
        RecBufClear(252);
        Art.C.ArtikelNr     # Ein.P.ArtikelNr;
        Art.C.Lieferantennr # Ein.P.Lieferantennr;
        Art.C.Dicke         # Ein.P.Dicke;
        Art.C.Breite        # Ein.P.Breite;
        "Art.C.Länge"       # "Ein.P.Länge";
        Art.C.RID           # Ein.P.RID;
        Art.C.RAD           # Ein.P.RAD;
        if (vMenge>Ein.P.FM.Rest) then
          vOk # Art_Data:Bestellung((-1.0) * Ein.P.FM.Rest)
        else
          vOk # Art_Data:Bestellung((-1.0) * vMenge);
        if (vOk=false) then RETURN false;
      end;    // .. Eingang

    end;    // ...Menge vorhanden


    if (vDel) then begin    // Löschen?
      RecBufClear(252);
      Art.C.Charge.Intern # Ein.E.Charge;
      Art.C.ArtikelNr     # Ein.E.ArtikelNr;
      Art.C.Lieferantennr # Ein.E.Lieferantennr;
      Art.C.AdressNr      # Ein.E.Lageradresse;
      Art.C.AnschriftNr   # Ein.E.Lageranschrift;
      Erx # RecRead(252,1,_recLock);
      if (Erx<>_rOK) then RETURN false;
      RecBufClear(253);
      Art.J.Datum           # Ein.E.Eingang_Datum;
      Art.J.Bemerkung       # Translate('Storno-Wareneingang')+' '+AInt(Ein.E.Nummer)+'/'+AInt(Ein.E.Position)+'/'+AInt(Ein.E.Eingangsnr);
      "Art.J.Stückzahl"     # (-1) * vAltStk;
      Art.J.Menge           # (-1.0) * vAltMenge;
      "Art.J.Trägertyp"     # '-WE';
      "Art.J.Trägernummer1" # Ein.E.Nummer;
      "Art.J.Trägernummer2" # Ein.E.Position;
      "Art.J.Trägernummer3" # Ein.E.Eingangsnr;
      vOK # Art_Data:Bewegung(vPreis,0.0);
      if (vOK=false) then RETURN false;
    end;


    // Neuanlage mit Kommisison ???
    vOK # n;
    if (aNeuanlage) and (Ein.E.EingangYN) and (Ein.P.Kommissionnr<>0) then begin
      Erx # RecLink(401,501,18,_recFirst);      // Auftragspos holen
      if (Erx<=_rLocked) then begin
        Erx # RecLink(400,401,3,_recFirst);     // Kopf holen
        if (Erx<=_rLocked) then begin
          Erx # RekLink(835,401,5,_recFirst);   // Auftragsart holen
          // STRECKE ----------------------
          if (Set.Ein.OhneStreckVK=false) and (Ein.E.Lageradresse=Auf.Lieferadresse) and (Ein.E.Lageranschrift=Auf.Lieferanschrift) then begin
            if (Erx<=_rLocked) and (AAr.KonsiYN=n) then begin
              vOK # y;
              Erx # RecLink(818,401,9,_recFirst);   // Verwiegungsart holen
              if (Erx>_rLocked) then begin
                RecBufClear(818);
                VwA.NettoYN # y;
              end;
              vMenge # Lib_Einheiten:WandleMEH(250, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Auf.P.MEH.Preis);
              if (Ein.E.Eingang_datum<>0.0.0) then
                vOk # Auf_Data_Buchen:DFaktArtC(Ein.E.Artikelnr, Ein.E.LagerAdresse, Ein.E.Lageranschrift, Ein.E.Charge, n, Ein.E.Menge, "Ein.E.Stückzahl", vMenge, Ein.E.Eingang_Datum)
              else if (Ein.E.VSB_datum<>0.0.0) then
                vOk # Auf_Data_Buchen:DFaktArtC(Ein.E.Artikelnr, Ein.E.LagerAdresse, Ein.E.Lageranschrift, EIn.E.Charge, n, Ein.E.Menge, "Ein.E.Stückzahl", vMenge, Ein.E.VSB_Datum);
              if (vOK=false) then RETURN false;
            end;
          end;  // ...Strecke

          // sonst DREIECK -----------------
          if (vOK=n) then begin
            vMenge # Lib_Einheiten:WandleMEH(250, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Art.MEH);
            vMenge2 # Lib_Einheiten:WandleMEH(250, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Auf.P.MEH.Preis);

            // VSB setzen...
            vOK # Auf_data_Buchen:MatzArt(Ein.E.Artikelnr, Ein.E.Lageradresse, Ein.E.Lageranschrift, Ein.E.Charge,
                    n, n, vMenge, "Ein.E.Stückzahl", vMenge2);
            if (vOK=false) then RETURN false;
          end;  // ...Dreieck

        end;
      end;
    end;  // Neuanlage mit Kommission

  end;    // ...Artikel


  // 03.06.2016 AH: Kein Wareneingang ohne Preis!!!
  if (Ein.E.AusfallYN=false) and (Ein.E.Preis=0.0) then begin
    Error(506020,'');
    RETURN false;
  end;


  // Bestellung updaten
  Erx # RecLink(501,506,1,_RecFirst | _RecLock);     // Bestellposition holen
  vRestAlt # Ein.P.FM.Rest;

  if (vEinPMEH=vEinEMEH) then   vMenge # Ein.E.Menge
  else if (vEinPMEH='STK') then  vMenge # CnvFI("Ein.E.Stückzahl")
  else if (vEinPMEH='KG') then   vMenge # (Ein.E.Gewicht)
  else if (vEinPMEH='T') then    vMenge # (Ein.E.Gewicht) / 1000.0;
  if (vWarVSB) then begin
    Ein.P.FM.VSB      # Ein.P.FM.VSB      - vAltMenge;
    Ein.P.FM.VSB.Stk  # Ein.P.FM.VSB.Stk  - vAltStk;
  end;
  if (vWarEingang) then begin
    Ein.P.FM.Eingang      # Ein.P.FM.Eingang      - vAltMenge;
    Ein.P.FM.Eingang.Stk  # Ein.P.FM.Eingang.Stk  - vAltStk;
  end;
  if (vWarAusfall) then begin
    Ein.P.FM.Ausfall      # Ein.P.FM.Ausfall      - vAltMenge;
    Ein.P.FM.Ausfall.Stk  # Ein.P.FM.Ausfall.Stk  - vAltStk;
  end;

  if ("Ein.E.Löschmarker"='') then begin
    if (Ein.E.VSBYN) then begin
      Ein.P.FM.VSB      # Ein.P.FM.VSB      + vMenge;
      Ein.P.FM.VSB.Stk  # Ein.P.FM.VSB.Stk  + "Ein.E.Stückzahl";
    end;
    if (Ein.E.EingangYN) then begin
      Ein.P.FM.Eingang      # Ein.P.FM.Eingang      + vMenge;
      Ein.P.FM.Eingang.Stk  # Ein.P.FM.Eingang.Stk  + "Ein.E.Stückzahl";
    end;
    if (Ein.E.AusfallYN) then begin
      Ein.P.FM.Ausfall      # Ein.P.FM.Ausfall      + vMenge;
      Ein.P.FM.Ausfall.Stk  # Ein.P.FM.Ausfall.Stk  + "Ein.E.Stückzahl";
    end;
  end;

  Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
  Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
  if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
  if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;


  vOK # n;
/** 10.02.2014 AH : Autolöschen als Setting
  vProz # Lib_Berechnungen:Prozent(Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge.Wunsch);
  if (vProz>="Set.Ein.WEDelEin%") then begin
    vBuf506 # RekSave(506);
    vOK # y;
    Erx # RecLink(506,501,14,_recFirst);  // WE loopen
    WHILE (Erx<=_rLocked) do begin
      if (Ein.E.VSBYN) and ("Ein.E.Löschmarker"='') then begin
        vOK # n;
        BREAK;
      end;
      Erx # RecLink(506,501,14,_recNext);
    END;
    RekRestore(vBuf506);
  end;

  Erx Ein_Data:PosReplace(_recUnlock,'AUTO');
  if (erx<>_rOK) then RETURN false;

  // Position löschen?
  if (vOK) and ("Ein.P.Löschmarker"='') then begin
    if (Ein_P_Subs:ToggleLoeschmarker(n)=n) then RETURN false;
  end;
***/
  Erx # Ein_Data:PosReplace(_recUnlock,'AUTO');
  if (erx<>_rOK) then RETURN false;


  // Einkaufskontrolle durchführen
  if (EKK_Data:Update(506)=false) then RETURN false;

  // Material?
  if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin

    // Restkarte update nur bei NICHT löschen
    if (vOK=false) then begin
      if (Ein_Data:UpdateMaterial()=false) then  RETURN False;
    end;
/*** alles in UpdateMaterial 2023-03-15 AH
    if (Ein.E.MaterialNr<>0) then begin

      Erx # Mat_Data:Read(Ein.E.Materialnr);
      if (Erx<200) then RETURN false;

      Erx # RecLink(505,501,8,_RecFirst);   // Kalkulation loopen
      WHILE (Erx<=_rLocked) do begin
        if (Ein.K.MengenbezugYN) and ("Ein.K.RückstellungYN") then begin
          if (EKK_Data:Update(505)=false) then RETURN false;
        end;
        Erx # RecLink(505,501,8,_recNext);
      END;
    end;
***/

  end;  // Material

  // 2023-06-02 AH
  if (Ein.E.Materialnr<>0) then begin
    Erx # Mat_Data:Read(Ein.E.Materialnr);
    if (Erx<200) then RecBufClear(200);
  end;

  // Ankerfunktion:
  if (aNeuanlage) then vA # 'Y'
  else vA # 'N';
  if (aGegenbuchung) then vA # vA +'|Y'
  else vA # vA + '|N';
  vA # vA + '|'+aint(aVorlageMat);

  RunAFX('Ein.E.Data.Verbuchen.Post',vA);

  RETURN true;

end;


//========================================================================
// RecalcPosition
//        rechnet die Positionssummen neu aus
//========================================================================
sub RecalcPosition();
local begin
  Erx       : int;
  vMenge    : float;
  vEinPMEH  : alpha;
  vEinEMEH  : alpha;
end;
begin

  // MATERIAL
  if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) then begin
    vEinEMEH # 'kg';
    vEinPMEH # 'kg';
  end
  else begin
    Erx # RecLink(250,506,5,_RecFirst);     // Artikel holen
    if (Erx>_rLocked) then RETURN;
    vEinEMEH # StrCnv(Ein.E.MEH,_StrUpper);
    vEinPMEH # StrCnv(Ein.P.MEH,_StrUpper);
  end;

  Erx # RecRead(501,1,_RecLock);
  Ein.P.FM.VSB          # 0.0;
  Ein.P.FM.VSB.Stk      # 0;
  Ein.P.FM.Eingang      # 0.0;
  Ein.P.FM.Eingang.Stk  # 0;
  Ein.P.FM.Ausfall      # 0.0;
  Ein.P.FM.Ausfall.Stk  # 0;
  Erx # RecLink(506,501,14,_recFirst);   // eingänge loopen
  WHILE (Erx<=_rLocked) do begin

    if (vEinPMEH=vEinEMEH) then   vMenge # Ein.E.Menge
    else if (vEinPMEH='STK') then  vMenge # CnvFI("Ein.E.Stückzahl")
    else if (vEinPMEH='KG') then   vMenge # (Ein.E.Gewicht)
    else if (vEinPMEH='T') then    vMenge # (Ein.E.Gewicht) / 1000.0;

    if ("Ein.E.Löschmarker"='') then begin
      if (Ein.E.VSBYN) then begin
        Ein.P.FM.VSB      # Ein.P.FM.VSB      + vMenge;
        Ein.P.FM.VSB.Stk  # Ein.P.FM.VSB.Stk  + "Ein.E.Stückzahl";
      end;
      if (Ein.E.EingangYN) then begin
        Ein.P.FM.Eingang      # Ein.P.FM.Eingang      + vMenge;
        Ein.P.FM.Eingang.Stk  # Ein.P.FM.Eingang.Stk  + "Ein.E.Stückzahl";
      end;
      if (Ein.E.AusfallYN) then begin
        Ein.P.FM.Ausfall      # Ein.P.FM.Ausfall      + vMenge;
        Ein.P.FM.Ausfall.Stk  # Ein.P.FM.Ausfall.Stk  + "Ein.E.Stückzahl";
      end;
    end;

    Erx # RecLink(506,501,14,_recnext);
  END;
  Ein_Data:PosReplace(_recUnlock,'AUTO');

end;


//========================================================================
// AnalyseError
//
//========================================================================
sub _AnalyseError_Sub(
  aName : alpha;
  aWert : float;
) : alpha;
local begin
  vVon,vBis : float;
end;
begin
  MQU_Data:BildeVorgabe(aName, 501, "Ein.P.Güte", Ein.P.Dicke, var vVon, var vBis);
  if ((aWert<vVon) or (aWert>vBis)) and ((vVon<>0.0) or (vBis<>0.0)) then
    RETURN Translate(aName)+'%CR%';

  RETURN '';
end;


//========================================================================
// AnalyseError
//
//========================================================================
sub AnalyseError() : alpha;
local begin
  vA        : alpha(4000);
  vVon,vBis : float;
  vWert     : float;
end;
begin

  if (Set.Mech.Dehnung.Wie=1) then begin
    vA # vA + _AnalyseError_Sub('DehnungA',Ein.E.DehnungA)
    vA # vA + _AnalyseError_Sub('DehnungB',Ein.E.DehnungB);
  end
  else begin
    vA # vA + _AnalyseError_Sub('DehnungA',Ein.E.DehnungB);
    vA # vA + _AnalyseError_Sub('DehnungB',Ein.E.DehnungA);
  end;
  vA # vA + _AnalyseError_Sub('Streckgrenze', Ein.E.Streckgrenze);
  vA # vA + _AnalyseError_Sub('Zugfestigkeit',Ein.E.Zugfestigkeit);
  vA # vA + _AnalyseError_Sub('DehnungA',Ein.E.DehnungA);
  vA # vA + _AnalyseError_Sub('DehnungB',Ein.E.DehnungB);
  vA # vA + _AnalyseError_Sub('DehngrenzeA',Ein.E.RP02_1);
  vA # vA + _AnalyseError_Sub('DehngrenzeB',Ein.E.RP10_1);
  vA # vA + _AnalyseError_Sub('DehngrenzeB',"Ein.E.Körnung");
  vA # vA + _AnalyseError_Sub('C',Ein.E.Chemie.C);
  vA # vA + _AnalyseError_Sub('Si',Ein.E.Chemie.Si);
  vA # vA + _AnalyseError_Sub('Mn',Ein.E.Chemie.Mn);
  vA # vA + _AnalyseError_Sub('P',Ein.E.Chemie.P);
  vA # vA + _AnalyseError_Sub('S',Ein.E.Chemie.S);
  vA # vA + _AnalyseError_Sub('Al',Ein.E.Chemie.Al);
  vA # vA + _AnalyseError_Sub('Cr',Ein.E.Chemie.Cr);
  vA # vA + _AnalyseError_Sub('V',Ein.E.Chemie.V);
  vA # vA + _AnalyseError_Sub('Nb',Ein.E.Chemie.Nb);
  vA # vA + _AnalyseError_Sub('Ti',Ein.E.Chemie.Ti);
  vA # vA + _AnalyseError_Sub('N',Ein.E.Chemie.N);
  vA # vA + _AnalyseError_Sub('Cu',Ein.E.Chemie.Cu);
  vA # vA + _AnalyseError_Sub('Ni',Ein.E.Chemie.Ni);
  vA # vA + _AnalyseError_Sub('Mo',Ein.E.Chemie.Mo);
  vA # vA + _AnalyseError_Sub('B',Ein.E.Chemie.B);
  vA # vA + _AnalyseError_Sub('Frei1',Ein.E.Chemie.Frei1);

  RETURN vA;
end;


//========================================================================
// BestandsAenderung
//
//========================================================================
sub BestandsAenderung();
local begin
  Erx       : int;
  vStk      : int;
  vNetto    : float;
  vBrutto   : float;
  vTPreis   : float;
  vMPreis   : float;
  vMenge    : float;
  vA        : alpha;
  vBuf200   : int;
  vDat      : date;
  vTim      : time;
  vdStk     : int;
  vdNetto   : float;
  vdBrutto  : float;
  vdPreis   : float;
  vdMenge   : float;
  vdGew     : float;
  vOK       : logic;
  vPEH      : alpha;
end;
begin

  if (Ein.E.Materialnr=0) then RETURN;

  Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
  if (Erx<>_rOK) then begin
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;
  if (EKK_Data:BereitsVerbuchtYN(506)) then begin
    Msg(506555,'',0,0,0);
    RETURN;
  end;

  // Gelöscht???
  if ("Mat.Löschmarker"<>'') then begin
    Msg(200006,'',0,0,0);
    RETURN;
  end;

  // bereits Aktionen vorhanden???
  vOK # Y;
  Erx # RecLink(204,200,14,_recFirst);  // Aktionen loopen
  WHILE (Erx<=_rLocked) and (vOK) do begin
    if (Mat.A.Aktionstyp<>c_Akt_Aufpreis) then vOK # false;
    Erx # RecLink(204,200,14,_recNext);
  END;
  if (vOK=false) then begin
    Msg(204000,'',0,0,0);
    RETURN;
  end;

  // Material sperren...
/**
  Erx # RecRead(200,1,_recLock);
  if (Erx<>_rOK) then begin
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;
  PtD_Main:Memorize(200);
**/

  Erx # RecRead(506,1,_recLock);
  if (Erx<>_rOK) then begin
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;
  PtD_Main:Memorize(506);

  vStk    # "Ein.E.Stückzahl";
  vNetto  # Ein.E.Gewicht.Netto;
  vBrutto # Ein.E.Gewicht.Brutto;
  vMenge  # Mat.Bestand.Menge;  // 2023-04-25 AH
// OOPS  vPreis  # Mat.EK.Preis;
//  vPreis  # Ein.E.PreisW1;
  vDat    # today;
  vTim    # now;

  vTPreis  # Ein.E.Preis;

  if (Ein.Nummer<>ein.P.Nummer) then
    Erx # RecLink(500,501,3,_RecFirst); // Bestellkopf holen
  Erx # RecLink(814,500,8,_recFirst);   // Währung holen
  if ("Ein.WährungFixYN"=n) then
    "Ein.Währungskurs" # Wae.EK.Kurs;
  if ("Ein.Währungskurs"=0.0) then "Ein.Währungskurs" # 1.0;
  vPEH    # "Wae.Kürzel" + ' / '+aint(Ein.P.PEH)+' '+Ein.P.MEH.Preis;

  if (Dlg_Standard:Mat_Bestand(var vStk, var vNetto, var vBrutto, var vTPreis, var vMenge, var vA, var vDat, y, vPEH)=false) then begin
    RecRead(506,1,_recUnlock);
    PtD_Main:Forget(506);
    RETURN;
  end;
  if (vDat<>today) then vTim # 0:0;
  if (vDat<Mat.Eingangsdatum) or
    ((vDat>Mat.Ausgangsdatum) and (MAt.Ausgangsdatum<>0.0.0)) then begin
    Msg(202000,'',0,0,0);
    RecRead(506,1,_recUnlock);
    PtD_Main:Forget(506);
    RETURN;
  end;


  // Delta ausrechnen...
  if (Mat.MEH='Stk') or (Mat.MEH='kg') or (Mat.MEH='t') then   // 2023-01-26 AH
    vMenge # Mat_Data:MengeVorlaeufig(vStk, vNetto, vBrutto);
  vdStk     # "Ein.E.StückZAhl" - vStk;
  vdNetto   # Ein.E.Gewicht.Netto - vNetto;
  vdBrutto  # Ein.E.Gewicht.Brutto - vBrutto;
  vdMenge   # Ein.E.Menge - vMenge;

  "Ein.E.StückZAhl"     # vStk;
  Ein.E.Gewicht.Netto   # vNetto;
  Ein.E.Gewicht.Brutto  # vBrutto;

  Erx # RecLink(818,506,12,_recfirst);    // Verwiegungsart holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;
  if ( VWa.NettoYN ) then begin
    vdGew # Ein.E.Gewicht - Ein.E.Gewicht.Netto;
    Ein.E.Gewicht # Ein.E.Gewicht.Netto;
  end
  else begin
    vdGew # Ein.E.Gewicht - Ein.E.Gewicht.brutto;
    Ein.E.Gewicht # Ein.E.Gewicht.Brutto;
  end;

  if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
    Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
  end
  else if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
    Ein.E.Menge # Ein.E.Gewicht;
  end
  else
    Ein.E.Menge # vMenge;   // 2023-01-26 AH
  
  if (Ein.E.Gewicht.Brutto=0.0) then
    Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
  if (Ein.E.Gewicht.Netto=0.0) then
    Ein.E.Gewicht.Netto # Ein.E.Gewicht;
//oops  Ein.E.PreisW1 # vPreis * cnvfi(Ein.P.PEH);
  //Ein.E.Preis # Rnd(Ein.E.PreisW1,2);// * "Ein.Währungskurs",2)

  Ein.E.Preis # Rnd(vTPreis,2);// * "Ein.Währungskurs",2)
  vDPreis # Ein.E.PreisW1;
  Ein.E.PreisW1 # Rnd(vTPreis / "Ein.Währungskurs",2)
  vTPreis    # Ein.E.PreisW1;
//  vdPreis   # vDPreis - Ein.E.PreisW1;
  vTPreis # Lib_Einheiten:PreisProT(vTPreis, Ein.P.PEH, Ein.P.MEH.Preis, "Ein.E.Stückzahl",Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.E.Dicke,Ein.E.Breite,"Ein.E.Länge", "Ein.E.Güte", Ein.E.Artikelnr);
  vdPreis # Mat.EK.Preis - vTPreis;
//  vPreis = per T;

  vdStk     # 0 - vdStk;
  vdGew     # 0.0 - vdGew;
  vdBrutto  # 0.0 - vdBrutto;
  vdNetto   # 0.0 - vdNetto;
  vdPreis   # 0.0 - vdPreis;
  vdMenge   # 0.0 - vdMenge;

  TRANSON;

  Erx # RekReplace(506,_recUnlock,'MAN');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RecRead(506,1,_recUnlock);
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;

  Erx # RecLink(200,506,8,_recFirst);   // Material holen
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;

  PtD_Main:Compare(506);

/***
  vBuf200 # RekSave(200);

  // Vorgang buchen
  if (Ein_E_Data:Verbuchen(n)=false) then begin
    TRANSBRK;
    RecRead(506,1,_recUnlock);
    Error(506001,'');
    ErrorOutput;
    RecBufDestroy(vBuf200);
    RETURN;
  end;
***/
  RecRead(200,1,_recLock);
  // Ankerfunktion:
  RunAFX('Mat.Bestandsänderung',AInt(vStk)+'|'+ANum(vNetto,Set.Stellen.Gewicht)+'|'+ANum(vBrutto,Set.Stellen.Gewicht)+'|'+ANum(vTPreis,2));
  Mat.Bestand.Gew     # Mat.Bestand.Gew + vdGew;
  Mat.Bestand.Stk     # Mat.Bestand.Stk + vdStk;
  Mat.Gewicht.Netto   # Mat.Gewicht.Netto + vdNetto;
  Mat.Gewicht.Brutto  # Mat.Gewicht.Brutto + vdBrutto;
  Mat.Bestand.Menge   # Mat.Bestand.Menge + vdMenge;
  Mat.EK.Preis        # vTPreis;
  Mat.EK.PreisProMEH  # 0.0; // 2023-04-25 AH : damit AUSRECHNEN
  
  Erx # Mat_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;

  // Einkaufskontrolle updaten...
  if (EKK_Data:Update(506)=false) then begin
    TRANSBRK;
    Msg(001000,gTitle,0,0,0);
    RETURN;
  end;

  TRANSOFF;

  Erx # RecLink(200,506,8,_recFirst);   // Material holen
//  Mat_Data:Bestandsbuch(Mat.Bestand.Stk - vBuf200->Mat.Bestand.Stk, Mat.Bestand.Gew - vBuf200->Mat.Bestand.Gew, vA, today);
  Mat_Data:Bestandsbuch(vdStk, vdGew, vdMenge, vdPreis, 0.0, vA, vDat, vTim, '');
//  RecBufDestroy(vBuf200);

  // Bestellposition anpassen...
//  Erx # RecLink(501,506,1,_RecFirst | _RecLock);     // Bestellposition holen
/**
  if (vEinPMEH=vEinEMEH) then     vMenge # Ein.E.Menge
  else if (vEinPMEH='STK') then   vMenge # CnvFI("Ein.E.Stückzahl")
  else if (vEinPMEH='KG') then    vMenge # (Ein.E.Gewicht)
  else if (vEinPMEH='T') then     vMenge # (Ein.E.Gewicht) / 1000.0;
  if (vWarVSB) then begin
    Ein.P.FM.VSB      # Ein.P.FM.VSB      - vAltMenge;
    Ein.P.FM.VSB.Stk  # Ein.P.FM.VSB.Stk  - vAltStk;
  end;
  if (vWarEingang) then begin
    Ein.P.FM.Eingang      # Ein.P.FM.Eingang      - vAltMenge;
    Ein.P.FM.Eingang.Stk  # Ein.P.FM.Eingang.Stk  - vAltStk;
  end;
  if (vWarAusfall) then begin
    Ein.P.FM.Ausfall      # Ein.P.FM.Ausfall      - vAltMenge;
    Ein.P.FM.Ausfall.Stk  # Ein.P.FM.Ausfall.Stk  - vAltStk;
  end;

  Ein.P.FM.VSB          # Ein.P.FM.VSB - Ein.E.
  Ein.P.FM.Eingang      # Ein.P.FM.Eingang -
  Ein.P.FM.Ausfall      # Ein.P.FM.Ausfall -
  Ein.P.FM.VSB.Stk      # Ein.P.FM.VSB.Stk -
  Ein.P.FM.Eingang.Stk  # Ein.P.FM.Eingang.Stk -
  Ein.P.FM.Ausfall.Stk  # Ein.P.FM.Ausfall.Stk -

  Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
  Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
  if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
  if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
  Erx # Ein_Data:PosReplace(_recUnlock,'MAN');
  if (erx<>_rOK) then begin
    TRANSBRK;
    RecRead(200,1,_recUnlock);
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;

**/
/**
  "Ein.E.Stückzahl"     # Mat.Bestand.Stk;
  Ein.E.Gewicht.Netto   # Mat.Gewicht.Netto;
  Ein.E.Gewicht.Brutto  # Mat.Gewicht.Brutto;
  Ein.E.Gewicht         # Mat.Bestand.Gew;

  // Vorgang buchen
  if (Ein_E_Data:Verbuchen(n)=false) then begin
    TRANSBRK;
    RecRead(200,1,_recUnlock);
    Error(506001,'');
    ErrorOutput;
    RETURN;
  end;

  PtD_Main:Compare(506);
**/

//  TRANSOFF;

  Msg(999998,'',0,0,0);
end;


//========================================================================
// StornoVSBMat
//
//========================================================================
sub StornoVSBMat() : logic;
local begin
  Erx : int;
end;
begin

  TRANSON;

  RecRead(506,1,_recLock);
  PtD_Main:Memorize(506);
  if ("Ein.E.Löschmarker"='') then begin
    "Ein.E.Löschmarker" # '*';
  end
  else begin
    "Ein.E.Löschmarker" # '';
  end;
  Erx # RekReplace(506,_recUnlock,'MAN');
  if (erx<>_rOK) then begin
    Ptd_Main:Forget(506);
    TRANSBRK;
    RETURN false;
  end;
  if (Verbuchen(n)=false) then begin
    TRANSBRK;
    RETURN false;
  end;
  PtD_Main:Compare(506);

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  IstJungfrauMat
//========================================================================
sub IstJungfrauMat() : logic;
local begin
  Erx : int;
end;
begin

  FOR Erx # Reklink(204,200,14,_recFirst)
  LOOP Erx # Reklink(204,200,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.A.Aktionstyp<>c_Akt_Aufpreis) then RETURN false;
  END;

  RETURN true;
end;


//========================================================================
//========================================================================
Sub Gegenbuchung(
  aNeueNr     : int;
  aGegen      : int;
  var aMitRes : logic) : logic;
local begin
  Erx       : int;
  vBuf506   : int;
  vVsbMat   : int;
  vHatRes   : logic;
  vStk      : int;
  vGew      : float;
  vGewN     : float;
  vGewB     : float;
  vMenge    : float;
  vProz     : float;
  vKillVSB  : logic;
  vTim      : time;
end
begin

  vBuf506 # RekSave(506);
  Ein.E.Eingangsnr # aGegen;//cnvia($lb.GegenVSB->wpcustom);
  Erx # RecRead(506,1,_recLock);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RekRestore(vBuf506);
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;
  vVSBMat # Ein.E.Materialnr;
  Mat.Nummer # vVSBMat;
  if (RecLinkInfo(203,200,13,_recCOunt)>0) then begin
    Erx # RecLink(203,200,13,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      vHatRes # y;
      // 19.10.2018 AH: auch für BAInput
      if ("Mat.R.Trägernummer1"=0) or ("Mat.R.Trägertyp"=c_Akt_BAInput) then begin
        aMitRes # y;
        BREAK;
      end;
      Erx # RecLink(203,200,13,_RecNext);
    END;
  end;

  RekRestore(vBuf506);

  // neue Karte buchen...
  if (Ein_E_Data:Verbuchen(y,n,vVSBMat)=false) then begin
    TRANSBRK;
    Error(506001,'');
    ErrorOutput;
    RETURN false;
  end;

  vStk    # "Ein.E.Stückzahl";
  vGew    # Ein.E.Gewicht;
  vGewN   # Ein.E.Gewicht.Netto;
  vGewB   # Ein.E.Gewicht.Brutto;
  vMenge  # Ein.E.Menge;
  Ein.E.Eingangsnr # aGegen;//cnvia($lb.GegenVSB->wpcustom);
  Erx # RecRead(506,1,_recLock);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;
  PtD_Main:Memorize(506);   // für die Gegenbuchung!!

  vProz # Lib_Berechnungen:Prozent(vMenge, Ein.E.Menge);

  "Ein.E.Stückzahl"     # "Ein.E.Stückzahl" - vStk;
  Ein.E.Gewicht         # Ein.E.Gewicht     - vGew;
  Ein.E.Menge           # Ein.E.Menge       - vMenge;
  Ein.E.Gewicht.Netto   # Ein.E.Gewicht.Netto - vGewN;
  Ein.E.Gewicht.Brutto  # Ein.E.Gewicht.Brutto - vGewB;
  if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
    Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
  end;
  if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
    Ein.E.Menge # Ein.E.Gewicht;
  end;
  if ("Ein.E.Stückzahl"<0) then       "Ein.E.Stückzahl"     # 0;
  if (Ein.E.Gewicht<0.0) then         Ein.E.Gewicht         # 0.0;
  if (Ein.E.Gewicht.Netto<0.0) then   Ein.E.Gewicht.Netto   # 0.0;
  if (Ein.E.Gewicht.Brutto<0.0) then  Ein.E.Gewicht.Brutto  # 0.0;
  if (Ein.E.Menge<0.0) then           Ein.E.Menge           # 0.0;

  if ("Set.Ein.WEDelVSB%">0.0) and (vHatRes=false) then
    if (vProz>=(100.0-"Set.Ein.WEDelVSB%")) then vKillVSB # y

  // MS VogelBauer Wunsch
  if (vKillVSB) or
//    (("Ein.E.Stückzahl" = 0) and (Ein.E.Gewicht = 0.0) and (Ein.E.Gewicht.Brutto = 0.0) and (Ein.E.Gewicht.Netto = 0.0) and (Ein.E.Menge = 0.0)) then
    (("Ein.E.Stückzahl" = 0) and (Ein.E.Gewicht = 0.0) and  (Ein.E.Gewicht.Netto = 0.0) and (Ein.E.Menge = 0.0)) then
    "Ein.E.Löschmarker" # '*';
  // Wenn Karte genullt, dann Löschmarker setzen
  Erx # RekReplace(506,_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    PtD_Main:Forget(506);
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;

  // Vorgang buchen (Bisherige VSB mindern)
  if (Ein_E_Data:Verbuchen(n,y)=false) then begin
    PtD_Main:Forget(506);
    TRANSBRK;
    Error(506001,'');
    ErrorOutput;
    RETURN false;
  end;
  PtD_Main:Forget(506);

  // Restore
  if (Ein.E.Eingang_Datum=today) then vTim # now;
  Ein.E.Nummer      # Ein.P.Nummer;
  Ein.E.Eingangsnr  # aNeueNr;
  Erx # RecRead(506,1,0);
  if (Erx<=_rLocked) and (Ein.E.Materialnr<>0) then begin
    // 22.04.2010 AI Abgang in Bestandsbuch eintragen
    Mat.Nummer # vVSBMat;
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then
      Mat_Data:Bestandsbuch(-vStk, -vGew, 0.0, 0.0, 0.0, Translate('WE')+' '+aint(Ein.E.Nummer)+'/'+aint(ein.E.Position)+'/'+aint(ein.e.eingangsnr), Ein.E.Eingang_datum, vTim, c_Akt_WE, Ein.E.Nummer, ein.E.Position, ein.e.eingangsnr);
    gSelected # Recinfo(506,_RecID);
  end;


  RETURN true;
end;


/*========================================================================
2023-03-15  AH
========================================================================*/
sub KalkNachtrag(opt aDelOnly : logic) : logic;
local begin
  Erx       : int;
  vDatei    : int;
  vDat      : date;
  vWert     : float;
  vKostPT   : float;
  vKostPM   : float;
  vGesKG    : float;
  vGesMenge : float;
end;
begin

  // KALK: 500€
  // WE1 :  50kg  3Stk
  // WE2 : 200kg  6Stk
  vWert # Ein.K.Preis;
  if (Ein.K.PEH=0) then Ein.K.PEH # 1;
  if (Ein.K.Menge<>0.0) then
    vWert # Ein.K.Preis * Ein.K.Menge / cnvfi(Ein.K.PEH);
  
  // Wareneingang loopen...
  FOR Erx # RecLink(506,501,14,_recFirst)
  LOOP Erx # RecLink(506,501,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Ein.E.AusfallYN) then CYCLE;
    vGesMenge # vGesMenge + Ein.E.Menge;
    vGesKG    # vGesKG    + Ein.E.Gewicht;
  END;

  DivOrNull(vKostPM, vWert, vGesMenge, 2);        // GesWert pro GesMenge
  DivOrNull(vKostPT, vWert, (vGesKG/1000.0), 2);  // GesWert pro Tonnage

  // Wareneingang loopen...
  FOR Erx # RecLink(506,501,14,_recFirst)
  LOOP Erx # RecLink(506,501,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Ein.E.AusfallYN) then CYCLE;
  
    if (Ein.E.Materialnr<>0) then begin
      vDatei # Mat_Data:Read(Ein.E.Materialnr);
      if (vDatei<200) then RETURN false;
      vDat # Ein.E.Eingang_Datum;
      if (Ein.E.VSBYN) then
        vDat # Ein.E.VSB_Datum;
//      if (Ein_Data:CopyPosKalkToMat("Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.E.Eingangsnr, vDat, TRUE)=false) then RETURN false;

      Erx # RecLink(100,501,4,_recFirst);   // Lieferant holen

      // Alten erst LÖSCHEN     2023-06-19  AH
      RecBufClear(204);
      Mat.A.Aktionstyp    # c_Akt_Kalk;
      Mat.A.Aktionsnr     # Ein.K.Nummer;
      Mat.A.Aktionspos    # Ein.K.Position;
      Mat.A.Aktionspos2   # Ein.E.Eingangsnr;
      Mat.A.Aktionspos3   # Ein.K.lfdNr;
      Mat.A.Aktionsmat    # Mat.Nummer;
      Mat.A.Materialnr    # Mat.Nummer;
      Erx # RecRead(204,4,0)
      if (Erx<=_rMultikey) then begin
        Mat.EK.Preis          # Mat.EK.Preis - Mat.A.Kosten2W1;
        Mat.EK.PreisProMEH    # Mat.EK.PreisProMEH - Mat.A.Kosten2W1ProME;
        Erx # RekDelete(204);
        if (erx<>_rOK) then begin
//debugx('KEY204 kann nicht gelöscht werden!');
          RETURN false;
        end;
      end;

      if (aDelOnly=false) then begin    // 2023-06-20 AH
        RecBufClear(204);
        Mat.A.Aktionstyp    # c_Akt_Kalk;
        Mat.A.Aktionsnr     # Ein.K.Nummer;
        Mat.A.Aktionspos    # Ein.K.Position;
        Mat.A.Aktionspos2   # Ein.E.Eingangsnr;
        Mat.A.Aktionspos3   # Ein.K.lfdNr;
        Mat.A.Aktionsmat    # Mat.Nummer;
        Mat.A.Aktionsdatum  # vDat;
        Mat.A.Adressnr      # Adr.Nummer;
        Mat.A.Bemerkung     # Ein.K.Bezeichnung;

        Mat.A.Gewicht       # Ein.E.Gewicht;
        Mat.A.Menge         # Ein.E.Menge;

        Mat.A.Kosten2W1       # vKostPT;
        Mat.A.Kosten2W1ProME  # vKostPM;
        Mat.EK.Preis          # Mat.EK.Preis + vKostPT;
        Mat.EK.PreisProMEH    # Mat.EK.PreisProMEH + vKostPM;
  //debugx('matek :'+anum(Mat.EK.PReis,2)+'/t   '+anum(Mat.EK.PReisProMEH,2)+'/'+mat.meh);
        Mat_A_Data:Insert(0,'AUTO');
        
        // Daten "faken"
        if (vKostPM<>0.0) then
          Ein.K.Preis # vKostPM * Ein.E.Menge
        else
          Ein.K.Preis # vKostPT * Ein.E.Gewicht;

        if (EKK_Data:Update(505)=false) then RETURN false;
      end;

      if (Mat_Data:SetUndVererbeEkPreis(vDatei, vDat, Mat.EK.Preis, Mat.EK.PreisProMEH, Mat.MEH, 0)=false) then begin
        RETURN false;
      end
    end
    else begin
      // Artikel??? TODO
      RecBufClear(200);
      ReCbufClear(204);
      if (EKK_Data:Update(505)=false) then RETURN false;
    end;

  END;
  
 
  RETURN true;
end;


//========================================================================