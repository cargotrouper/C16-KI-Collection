@A+
//===== Business-Control =================================================
//
//  Prozedur    Mat_A_Data
//                    OHNE E_R_G
//  Info
//
//
//  01.02.2005  AI  Erstellung der Prozedur
//  13.04.2010  AI  Kosten nach Kombination werden richtig vererbt
//  10.04.2013  AI  MatMEH
//  15.04.2013  AI  "Vererben" setzt Basis-EK nicht automatisch, sondern nur auf explizitem Aufruf und nur
//                  solange es keine Bestandsbucheinträge für den Preis gibt
//  31.07.2014  ST  Prüfung auf Abschlussdatum bei "Insert" hinzugefügt Projekt 1326/395
//  16.10.2014  AH  MatSofortInAblage
//  13.07.2015  AH  Schrottabwertungen am gleichen Tag werden NICHT vererben
//  04.08.2015  TM  Korrektur Klammerfehler in Abfrage Z.448 ff
//  05.04.2016  AH  Nutz "Mat_Data:Replace" statt direktes Replace
//  02.08.2016  AH  "BuildFullSel"
//  23.08.2016  AH  Einbau von aDiffText
//  10.03.2017  AH  "Vererben" OHNe Ek-Vererbung
//  20.04.2018  AH  Zirkelbezüge werden ignoriert
//  08.10.2020  AH  Workaround für Schrottnullungen bei Fahren + Spalten
//  11.02.2021  AH  Fix für a) Fahren+Spalten+Spalten und b) GeplanterSchrott+WB
//  13.02.2021  AH  CO2
//  01.03.2021  AH  CO2-Schrottumlagen in separats Mat-Feld
//  03.03.2021  AH  Fahr-SChrottnullungen um 0 Uhr NIE vererben!!
//  27.07.2021  AH  ERX
//  24.11.2021  AH  Fix Fahr-Schrottabwertung (VVF)
//  21.02.2022  AH  Replace
//  2023-01-21  AH  Ratio.MehKg
//
//  Subprozeduren
//    SUB AddKosten(  opt aDatei : int; opt aDiffTxt  : int) : logic;
//    SUB Vererben(optaWas : alpha) : logic;
//    SUB BuildFullSel(var aSel : int; var aSelName : alpha) : logic;
//    SUB BuildFullAktionsliste();
//    SUB Insert(aOpt : int; aTyp : alpha) : logic
//    SUB Replace(aOpt : int; aTyp : alpha;) : int;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
//  cSuperBaBaum : true
end;

//========================================================================
//  AddKosten
//    Berechnet die Kosten dieser Karte neu (läuft Vorgänger ab!)
//========================================================================
sub AddKosten(
  opt aDatei    : int;
  opt aDiffTxt  : int) : logic;
local begin
  Erx         : int;
  vSave200    : int;
  vSave210    : int;

  vBuf204     : int;
  vBuf204b    : int;
  vAnfang     : int;
  vNr         : int;
  vKostenPT   : float;
  vKostenPM   : float;
  vCO2Kosten  : float;
  vCO2Schrott : float;
  vBuf200     : int;
  vX          : float;
  vKombiGew   : float;
  vKombiMenge : float;
  vDatei      : int;
  vBuf        : int;
  vDiff       : float;
  vVorDat     : date; // Grenze VOR der summiert wird
  vVorTim     : time;
  vKindNr     : int;
  vAbsKosten  : float;
end;
begin

  if (aDatei=0) then aDatei # 200;

  if (aDatei=200) then begin
    vAnfang   # Mat.Nummer;
  end
  else if (aDatei=210) then begin
    vAnfang   # "Mat~Nummer";
  end
  else RETURN false;

  vSave200 # RekSave(200);
  vSave210 # RekSave(210);

  vNr       # vAnfang;
  vKostenPT # 0.0;
  vKostenPM # 0.0;

//debug('Addkosten '+aint(mat.nummer));
  WHILE (vNr<>0) do begin     // Karten loopen

    vDatei # Mat_Data:Read(vNr);
    if (vDatei<200) then BREAK;

    vBuf204 # RekSave(204);
    FOR Erx # RecLink(204, vDatei, 14,_recfirst)    // Aktionen loopen
    LOOP Erx # RecLink(204, vDatei,14,_recNext)
    WHILE (Erx<=_rLocked) do begin
//debug('checkakt :'+Mat.A.aktionstyp+' '+cnvad(mat.a.aktionsdatum)+'   '+cnvad(vDat));
/***
      if (cSuperBaBaum) then begin
        if (Mat.A.Aktionsmat<>vAnfang) and (Mat.A.Aktionsdatum=vDat) and (Mat.A.Aktionszeit>vTim) then CYCLE;
      end
      else begin
        // 13.07.2015 AH : Schrottabwertungen (negativ!!) am gleichen Tag NICHT vererben!!!
        if (Mat.A.Aktionsmat<>vAnfang) and (Mat.A.Aktionsdatum=vDat) and //(Mat.A.Kosten2W1<0.0) then begin
         ((Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_Mat_Umlage)) then CYCLE;
      end;

      if (Mat.A.Aktionsmat<>vAnfang) and (Mat.A.Aktionsdatum>vDat) then CYCLE;
***/
      // alle Kosten addieren, wenn ANFANGSKARTE - sonst anhand Datum entscheiden
      if (vNr<>vAnfang) then begin
//11.02.2021 RAUS, untere Abfrage das lösen sollte (Fahren+Spalt+Spalt)
//if (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) then begin
//debugx('wäre cycle KEY204');
//  CYCLE;  // 08.10.2020 AH: Workaround wenn Fahren, dann Spalten
//end;
        if (vVorDat<>0.0.0) and (Mat.A.Aktionsdatum>vVorDat) then CYCLE;

        // 24.11.2021 AH: VVF
        if (Mat.A.Aktionsdatum<vVorDat) then begin
          if (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) and (MAt.A.Bemerkung=*'*:FAHR*') then CYCLE;
        end;

        
        if (Mat.A.Aktionsdatum=vVorDat) then begin
//11.02.2021          if (vVorTim<>0:0) and (Mat.A.Aktionszeit>vVorTim) then begin   // 11.05.2020 AH + "="
          if (Mat.A.Aktionszeit>vVorTim) then begin   // 11.05.2020 AH + "="
            CYCLE;    // SuperBaBaum !
          end
          else if (Mat.A.Aktionszeit=0:0) and (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) and (MAt.A.Bemerkung=*'*:FAHR*') then begin
            CYCLE;  /// 03.03.2021 AH
          end
          else begin
            // Schrottabwertungen (negativ!!) am gleichen Tag NICHT vererben!!!
            if (Mat.A.Aktionszeit=vVorTim) and ((Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_Mat_Umlage)) then begin
//debugx('cycle KEY204');
              CYCLE;
            end;
          end;
        end;
      end;
/**** ALT 11.02.2021
        if (vVorDat<>0.0.0) and (Mat.A.Aktionsdatum>vVorDat) then CYCLE;
        if (Mat.A.Aktionsdatum=vVorDat) then begin
          if (vVorTim<>0:0) and (Mat.A.Aktionszeit>=vVorTim) then begin  // 11.05.2020 AH + "="
            CYCLE;   // SuperBaBaum !
          end
          else begin
            // Schrottabwertungen (negativ!!) am gleichen Tag NICHT vererben!!!
            if ((Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_Mat_Umlage)) then begin
              CYCLE;
            end;
          end;
        end;
      end;
****/
      vKostenPT   # vKostenPT + Mat.A.KostenW1;
      vKostenPm   # vKostenPM + Mat.A.KostenW1ProMEH;
      vAbsKosten  # Mat.A.Gewicht * Mat.A.KostenW1 / 1000.0;
      if (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_BA_UmlagePLUS) then begin
        vCO2Schrott # vCO2Schrott + Mat.A.CO2ProT;
      end
      else begin
        vCO2Kosten  # vCO2Kosten + Mat.A.CO2ProT;
      end;
//debug('addkost :'+Mat.A.aktionstyp+' '+anum(mat.a.kostenW1,2)+'   neu:'+anum(vKosten,2));
    END;
    RekRestore(vBuf204);


    if (vDatei=200) then begin
      vKindNr # Mat.Nummer;
      vNr     # "Mat.Vorgänger";    // zum Vorgänger gehen
//      vVorDat # Mat.Datum.Erzeugt;
//      vTim    # Mat.Zeit.Erzeugt;
    end
    else begin
      vKindNr # "Mat~Nummer";
      vNr     # "Mat~Vorgänger";    // zum Vorgänger gehen
//      vVorDat  # "Mat~Datum.Erzeugt";
//      vVorTim  # "Mat~Zeit.Erzeugt";
    end;
    If (vNr<>0) then begin
      // suche Enstehungs-Aktion:
      Mat.A.Materialnr  # vNr;
      Mat.A.Entstanden  # vKindNr;
      Erx # RecRead(204,6,0);   // Mataktion lesen
      if (Erx<=_rMultikey) then begin
        vVorDat # Mat.A.Aktionsdatum;
        vVorTim # Mat.A.Aktionszeit;
//debugx('set '+cnvad(vVorDat)+'@'+cnvat(vVorTim));;
        CYCLE;
      end;
    end;

  END;


  // Kosten zurück speichern
  vDatei # Mat_data:Read(vAnfang, _recLock);
  if (vDatei<200) then begin
    RekRestore(vSave200);
    RekRestore(vSave210);
    RETURN false;
  end;

  if (vDatei=200) then begin
//debug('Kosten/t:'+anum(vKosten,2)+'   /m:'+anum(vKostenPM,2));
//debug('IST-Kosten/t:'+anum(Mat.Kosten,2)+'   /m:'+anum(Mat.KostenProMEH,2));
    if (Mat.Kosten<>vKostenPT) or (Mat.KostenProMEH<>vKostenPM) or
      (Mat.CO2SchrottProT<>vCO2Schrott) or (Mat.CO2ZuwachsProT<>vCO2Kosten) then begin  // 23.09.2020 AH
//debug('SETZE Kosten/t:'+anum(vKosten,2)+'   /m:'+anum(vKostenPM,2));
      vDiff # Rnd((vKostenPT * Mat.Bestand.Gew / 1000.0) - (Mat.Kosten * Mat.Bestand.Gew / 1000.0),2)
      Mat.Kosten            # vKostenPT;
      Mat.CO2ZuwachsProT    # vCO2Kosten;
      Mat.CO2SchrottProT    # vCO2Schrott;
// 2023-01-20 AH : FAIL bei MehWechsel
      if (Mat.Ratio.MehKG<>0.0) then begin
        Mat.KostenProMEH      # Rnd(vKostenPT/1000.0 * Mat.Ratio.MehKG,2);
      end
      else if (Mat.MEH='kg') then begin
        Mat.KostenProMEH      # vKostenPT / 1000.0;
      end
      else if (Mat.MEH='t') then begin
        Mat.KostenProMEH      # vKostenPT;
      end
      else begin  // nicht so gut...
        Mat.KostenProMEH      # vKostenPM;
      end;


      Mat.EK.effektiv       # Mat.EK.Preis + Mat.Kosten;
      Mat.EK.effektivProME  # Mat.EK.PreisProMEH + Mat.KostenProMEH;
      Erx # Mat_Data:Replace(_RecUnlock,'AUTO');
      if (erx<>_rOK) then begin
        RekRestore(vSave200);
        RekRestore(vSave210);
        RETURN false;
      end;
   
      if (aDiffTxt<>0) and (vDiff<>0.0) then // and (Mat.VK.Rechnr<>0) then
        TextAddLine(aDiffTxt,aint(Mat.Nummer)+'|'+anum(vDiff,2)+'|'+aint(Mat.VK.RechNr));
    end
    else begin
      RecRead(200,1,_recUnlock);
    end;
  end
  else begin
//debug('Kosten/t:'+anum(vKosten,2)+'   /m:'+anum(vKostenPM,2));
    if ("Mat~Kosten"<>vKostenPT) or ("Mat~KostenProMEH"<>vKostenPM) or
      ("Mat~CO2SchrottProT"<>vCO2Schrott) or ("Mat~CO2ZuwachsProT"<>vCO2Kosten) then begin  // 23.09.2020 AH
      vDiff # Rnd((vKostenPT * "Mat~Bestand.Gew" / 1000.0) - ("Mat~Kosten" * "Mat~Bestand.Gew" / 1000.0),2)
      "Mat~Kosten"            # vKostenPT;
      "Mat~CO2ZuwachsProT"    # vCO2Kosten;
      "Mat~CO2SchrottProT"    # vCO2Schrott;
      "Mat~EK.effektiv"       # "Mat~EK.Preis" + "Mat~Kosten";
//      "Mat~KostenProMEH"      # vKostenPM;
// 2023-01-20 AH : FAIL bei MehWechsel
      if ("Mat~Ratio.MehKg"<>0.0) then begin
        "Mat~KostenProMEH"      # Rnd(vKostenPT/1000.0 * "Mat~Ratio.MehKg",2);
      end
      else if ("Mat~MEH"='kg') then begin
        "Mat~KostenProMEH"      # vKostenPT / 1000.0;
      end
      else if ("Mat~MEH"='t') then begin
        "Mat~KostenProMEH"      # vKostenPT;
      end
      else begin    // nicht so gut...
        "Mat~KostenProMEH"      # vKostenPM;
      end;

      
      "Mat~EK.effektivProME"  # "Mat~EK.PreisProMEH" + "Mat~KostenProMEH";
      Erx # Mat_Abl_Data:ReplaceAblage(_RecUnlock,'AUTO')
      if (erx<>_rOK) then begin
        RekRestore(vSave200);
        RekRestore(vSave210);
        RETURN false;
      end;
      if (aDiffTxt<>0) and (vDiff<>0.0) then // and ("Mat~VK.Rechnr"<>0) then
        TextAddLine(aDiffTxt,aint("Mat~Nummer")+'|'+anum(vDiff,2)+'|'+aint("Mat~VK.RechNr"));
    end
    else begin
      RecRead(210,1,_recUnlock);
    end;
  end;

  // Kombis rechnen...
  vBuf204 # RekSave(204);
  FOR Erx # RecLink(204, aDatei, 14,_recfirst) // Aktionen loopen
  LOOP Erx # RecLink(204, aDatei, 14,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Mat.A.Aktionstyp<>c_Akt_Mat_Kombi) or (Mat.A.Entstanden=0) or (Mat.A.Entstanden=Mat.A.Materialnr) then CYCLE;

    vBuf # RekSave(aDatei);
    vBuf200 # RecBufCreate(200);
    if (aDatei=210) then RecBufCopy(210,vBuf200)
    else RecBufCopy(200,vBuf200);

    vDatei # Mat_Data:Read(Mat.A.Entstanden);
    if (vDatei<200) then begin
      RekRestore(vBuf);
      RecBufDestroy(vBuf200);
      CYCLE;
    end;

    vKombiGew # 0.0;
    vBuf204b # RekSave(204);
    FOR Erx # RecLink(204, vDatei, 14,_recFirst)
    LOOP Erx # RecLink(204, vDatei, 14,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) and (Mat.A.Entstanden=0) then begin
        vKombiGew   # vKombiGew + Mat.A.Gewicht;
        vKombiMenge # vKombiMenge + Mat.A.Menge;
      end;
    END;

    FOR Erx # RecLink(204, vDatei, 14,_recFirst)
    LOOP Erx # RecLink(204, vDatei ,14,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if ((vKombiGew<>0.0) or (vKombiMenge<>0.0))  and
        (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) and
        (Mat.A.Aktionsmat=vBuf200->Mat.Nummer) and (Mat.A.Entstanden=0) then begin

        RecRead(204,1,_reCLock);
        vX # Rnd(Mat.A.Gewicht * vKostenPT / 1000.0,2);
        DivOrNull( Mat.A.KostenW1, vX, vKombiGew * 1000.0,2);

        vX # Rnd(Mat.A.Menge * vKostenPM,2);
        DivOrNull( Mat.A.KostenW1ProMEH, vX, vKombiMenge,2);
 
      if (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_BA_UmlagePLUS) then begin
          vX # Rnd(Mat.A.Gewicht * vCo2Schrott / 1000.0,2);
          DivOrNull( Mat.A.CO2ProT, vX, vKombiGew * 1000.0,2);
        end
        else begin
          vX # Rnd(Mat.A.Gewicht * vCo2Kosten / 1000.0,2);
          DivOrNull( Mat.A.CO2ProT, vX, vKombiGew * 1000.0,2);
        end;

        Erx # RekReplace(204,_recUnlock,'AUTO');
        if (Erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
          RekRestore(vBuf204b);
          RekRestore(vBuf);
          RecBufDestroy(vBuf200);
          RekRestore(vBuf204);
          RekRestore(vSave200);
          RekRestore(vSave210);
          RETURN false;
        end;
          
        AddKosten(vDatei, aDiffTxt);
        BREAK;
      end;
    END;
    RekRestore(vBuf204b);
    RekRestore(vBuf);
    RecBufDestroy(vBuf200);
  END; // Kombi

  RekRestore(vBuf204);
  RekRestore(vSave200);
  RekRestore(vSave210);

  vBuf # Mat.Nummer;
  Erx # RecRead(aDatei,1,0);
  if (Erx>_rLocked) then begin      // 21.02.2022 AH, bei "Mat sofort löschen" ggf. Buffer der Ablage in Bestand kopieren
    "Mat~Nummer" # vBuf;
    Erx # RecRead(210,1,0);
    RecbufCopy(210,200);
  end;
  
//debugx('addkosten '+aint(FldInt(aDatei,1,1))+' = '+anum(FldFloat(aDatei,1,58),2));

  RETURN true;
end;


//========================================================================
//  Vererben      +ERR
// 10.03.2017 AH : KEINE EK-VERERBUNG MEHR !!!!!!!
//========================================================================
sub Vererben(
  opt aWas      : alpha;
  opt aDatei    : int;
  opt aDiffTxt  : Int;
//  opt aMitEK    : logic;
//  opt aEK       : float;
//  opt aEKpro    : float;
  ) : logic;
local begin
  Erx       : int;
  vBuf      : int;
  vBuf200   : int;

  vBuf200b  : int;
  vBuf210b  : int;
  vBuf204   : int;
  vWert     : float;
  vCO2Wert  : float;
  vGew      : float;
  vWertPM   : float;
  vMenge    : float;
  vOK       : logic;
  vDatei    : int;

  vDiff     : float;
  vNullung  : logic;
  aEK       : float;
  aEKpro    : float;
end;
begin
//07.03.2017
if (aWas='EKPREIS') then begin
todo('Zum Vererben von EKPREIS andere Prozedur nutzen!');
RETURN false;
end;

  if (aDatei=0) then begin
    Erx # RecRead(200,1,_recTest);
    if (Erx=_rOK) then aDatei # 200
    else aDatei # 210;
  end;

  vBuf204 # RekSave(204);

  if (AddKosten(aDatei, aDiffTxt)=false) then begin   // diese Kosten hier summieren
    Error(200106,aint(fldInt(aDatei,1,1)));
    RekRestore(vBuf204);
    RETURN false;
  end;


  FOR Erx # RecLink(204, aDatei, 14,_recFirst)
  LOOP Erx # RecLink(204, aDatei, 14,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Mat.A.Entstanden=0) then CYCLE;
    if (Mat.A.Entstanden=Mat.A.Materialnr) then CYCLE;

    vBuf # RekSave(aDatei);

    vDatei # Mat_data:Read(Mat.A.Entstanden, _recLock);
    if (vDatei<200) then begin
      RekRestore(vBuf);
      RekRestore(vBuf204);
      Error(200106,aint(Mat.A.Entstanden));
      RETURN false;
    end;
//debugx('vererbe '+awas+' an Kind KEY200');

    // Kombination mit anderen Karten???
    if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) then begin
      vGew    # 0.0;  // 16.0.72015 AH ff.
      vMenge  # 0.0;
      vWert   # 0.0;
      vWertPM # 0.0;
      FOR Erx # RecLink(204, vDatei, 14,_recFirst)
      LOOP Erx # RecLink(204, vDatei, 14,_recNext)
      WHILE (Erx<_rLocked) do begin
//debug('vererbe 3...');
        if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) and (Mat.A.Entstanden=0) then begin
          vBuf200b      # Reksave(200);
          vBuf210b      # Reksave(210);
          Mat_Data:Read(Mat.A.Aktionsmat);
//debug('X '+aint(mat.nummer)+' '+anum(mat.ek.preis,2)+'   kg'+anum(mat.a.gewicht,0));
          vGew    # vGew + Mat.A.Gewicht;
          vWert   # vWert + (Mat.EK.Preis * Mat.A.Gewicht / 1000.0);
          vCO2Wert  # vCo2Wert + (Mat.CO2EinstandProT * Mat.A.Gewicht / 1000.0);
          vMenge  # vMenge + Mat.A.Menge;
          vWertPM # vWertPM + (Mat.EK.PreisProMEH * Mat.A.Menge);
          RekRestore(vBuf200b);
          RekRestore(vBuf210b);
        end;
      END;

//debug('gew:'+anum(mat.bestand.gew,0));
      if ((vGew<>0.0) or (vMenge<>0.0)) then begin
        RecRead(vDatei,1,_recLock);
        if (vDatei=200) then begin
          DivOrNull(Mat.EK.Preis, vWert, vGew * 1000.0,2);
          DivOrNull(Mat.CO2EinstandProT, vCo2Wert, vGew * 1000.0,2);
          DivOrNull(Mat.EK.PreisProMEH, vWertPM, vMenge,2);
        end
        else begin
          DivOrNull("Mat~EK.Preis", vWert, vGew * 1000.0,2);
          DivOrNull("Mat~CO2EinstandProT", vCo2Wert, vGew * 1000.0,2);
          DivOrNull("Mat~EK.PreisProMEH", vWertPM, vMenge,2);
        end;
        if (vDatei=200) then
          Erx # Mat_Data:Replace(_RecUnlock,'AUTO')
        else
          Erx # Mat_Abl_Data:ReplaceAblage(_RecUnlock,'AUTO')
        if (Erx<>_rOK) then begin
          RekRestore(vBuf);
          RekRestore(vBuf204);
          Error(200106,aint(FldInt(vDatei,1,1)));
          RETURN false;
        end;
      end;
      RekRestore(vBuf);
      CYCLE;    // KEINE REKURSION bei Kombi !!!
    end;  // Kombi


    vBuf200 # RecBufCreate(200);
    RecbufCopy(vBuf, vBuf200);


    if (aWas='EKPREIS') then begin
      aEK     # vBuf200->Mat.EK.Preis;
      aEKPro  # vBuf200->Mat.EK.PreisProMEH;

      vOK       # Y;
      vNullung  # false;
      FOR Erx # RecLink(202, vDatei,12,_recFirst)
      LOOP Erx # RecLink(202, vDatei,12,_recNext)
      WHILE (Erx<=_rLocked) do begin
// von???       if (Mat.B.FixYN) then vOK # n;
// 19.08.2016        if (Mat.B.PreisW1<>0.0) then vOK # n;
        if (1=2) or (Mat.B.FixYN) then begin
          vNullung # (Mat.B.Bemerkung=*c_AktBem_BA_Nullung+':*') or (Mat.B.Bemerkung=*'>'+c_AktBem_BA_Nullung+':*');
          if (vNullung) then begin
todox('KEY200 hat Nullung');
            RecRead(202,1,_recLock);
            Mat.B.PreisW1       # -aEK;
            Mat.B.PreisW1proMEH # -aEKPro;
            Erx # RekReplace(202);
            if (erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
              RecBufDestroy(vBuf200);
              RekRestore(vBuf);
              RekRestore(vBuf204);
              Error(999999,thisline);
              RETURN false;
            end;
            vOK # n;
            BREAK;
          end;
        end;
      END;

      if (vOk) then begin
        if (vDatei=200) then begin
          if (aDiffTxt<>0) then begin //and (Mat.VK.Rechnr<>0) then begin
            vDiff # Rnd((aEK * Mat.Bestand.Gew / 1000.0) - (Mat.EK.Preis * Mat.Bestand.Gew / 1000.0),2)
//debugx('Dif:'+anum(vDiff,2)+'   urgew:'+anum(vUrGew,2));
            TextAddLine(aDiffTxt,aint(Mat.Nummer)+'|'+anum(vDiff,2)+'|'+aint(Mat.VK.RechNr))
          end;
          Mat.EK.Preis          # aEK;
          Mat.EK.PreisProMEH    # aEKPro;
        end
        else begin
          if (aDiffTxt<>0) then begin //and ("Mat~VK.Rechnr"<>0) then begin
            vDiff # Rnd((aEK * "Mat~Bestand.Gew" / 1000.0) - ("Mat~EK.Preis" * "Mat~Bestand.Gew" / 1000.0),2)
            TextAddLine(aDiffTxt,aint("Mat~Nummer")+'|'+anum(vDiff,2)+'|'+aint("Mat~VK.RechNr"));
          end;

          "Mat~EK.Preis"        # aEK;
          "Mat~EK.PreisProMEH"  # aEKPro;
        end;
      end
    end;  // EKPREIS


    if (aWas='WERKSNR') or (aWas='*') then begin
      if (vDatei=200) then
        Mat.Werksnummer     # vBuf200->Mat.Werksnummer
      else
        "Mat~Werksnummer"   # vBuf200->Mat.Werksnummer;
    end;
    if (aWas='COILNR') or (aWas='*') then begin
      if (vDatei=200) then
        Mat.Coilnummer      # vBuf200->Mat.Coilnummer
      else
        "Mat~Coilnummer"    # vBuf200->Mat.Coilnummer;
    end;
    if (aWas='CHARGENNR') or (aWas='*') then begin
      if (vDatei=200) then
        Mat.Chargennummer   # vBuf200->Mat.Chargennummer
      else
        "Mat~Chargennummer" # vBuf200->Mat.Chargennummer;
    end;
    if (aWas='LAGERGELD') then begin
      if (vDatei=200) and (vBuf200->"Mat.Datum.Lagergeld">"Mat.Datum.Lagergeld") then
        "Mat.Datum.Lagergeld" # vBuf200->"Mat.Datum.Lagergeld"
      else if (vDatei=210) and (vBuf200->"Mat.Datum.Lagergeld">"Mat~Datum.Lagergeld") then
        "Mat~Datum.Lagergeld" # vBuf200->"Mat.Datum.Lagergeld";
    end;

    if (vDatei=200) then
      Erx # Mat_Data:Replace(_RecUnlock,'AUTO')
    else
      Erx # Mat_Abl_Data:ReplaceAblage(_RecUnlock,'AUTO')
//debug('b Save '+aint(mat.nummer)+':'+anum(mat.Kosten,2));
    if (erx<>_rOK) then begin
      RecBufDestroy(vBuf200);
      RekRestore(vBuf);
      RekRestore(vBuf204);
      Error(200106,aint(FldInt(vDatei,1,1)));
      RETURN false;
    end;

//    if (vNullung) then
//      vOK # Vererben(aWas, vDatei, aDiffTxt);//07.03.2017, true, aEK, aEKPro)
//    else
    vOK # Vererben(aWas, vDatei, aDiffTxt);
    if (vOK=false) then begin
      RekRestore(vBuf);
      RekRestore(vBuf204);
      RETURN false;
    end;

    RekRestore(vBuf);
  END;

  RekRestore(vBuf204);

  RETURN true;

end;


//========================================================================
//  BuildFullSel
//
//========================================================================
sub BuildFullSel(
  var aSel      : int;
  var aSelName  : alpha;
) : logic;
local begin
  Erx       : int;
  vVorDat   : date;
  vVorTim   : time;
  vFirst    : logic;
  vDatei    : int;
  v200      : int;
  v210      : int;
  vKindNr   : int;
end;
begin

  v200 # RekSave(200);
  v210 # RekSave(210);

  // Selektion starten...
  aSel # SelCreate( 204, 0 );
  aSel->SelAddSortFld(1,10);  // Datum
  aSel->SelAddSortFld(1,25);  // Zeit
  aSelName # Lib_Sel:Save(aSel);          // speichern mit temp. Namen
  aSel # SelOpen();                   // Selektion öffnen
  Erx # aSel->selRead(204,_SelLock,aSelName);   // Selektion laden

  vFirst # y;

//  vVorDat # Mat.Datum.Erzeugt;
//  vVorTim # Mat.Zeit.Erzeugt;
  vDatei # 200;
  REPEAT

    FOR Erx # RecLink(204,vDatei,14,_recFirst)
    LOOP Erx # RecLink(204,vDatei,14,_recNext)
    WHILE (Erx<=_rLocked) do begin
/***
      if (vFirst=false) and
          (vVorDat<>0.0.0) and
          (Mat.A.Aktionsdatum>vVorDat) then CYCLE;

      if (cSuperBaBaum) then begin
        if (vFirst=false) and (Mat.A.Aktionsdatum=vVorDat) and (Mat.A.Aktionszeit>vVorTim) then CYCLE;
      end
      else begin
        // 13.07.2015 AH : Schrottabwertungen (negativ!!) am gleichen Tag NICHT vererben!!!
        if (vFirst=false) and (Mat.A.Aktionsdatum=vVorDat) and // (Mat.A.Kosten2W1<0.0) then begin
          ((Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_Mat_Umlage)) then CYCLE;
      end;
***/
      if (vFirst=false) then begin
//11.02.2021 RAUS, untere Abfrage das lösen sollte (Fahren+Spalt+Spalt)
//if (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) then begin
//debugx('wäre cycle KEY204');
//  CYCLE;  // 08.10.2020 AH: Workaround wenn Fahren, dann Spalten
//end;
        if (vVorDat<>0.0.0) and (Mat.A.Aktionsdatum>vVorDat) then CYCLE;

        // 24.11.2021 AH: VVF
        if (Mat.A.Aktionsdatum<vVorDat) then begin
          if (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) and (MAt.A.Bemerkung=*'*:FAHR*') then CYCLE;
        end;

        if (Mat.A.Aktionsdatum=vVorDat) then begin
//11.02.2021          if (vVorTim<>0:0) and (Mat.A.Aktionszeit>vVorTim) then begin   // 11.05.2020 AH + "="
          if (Mat.A.Aktionszeit>vVorTim) then begin   // 11.05.2020 AH + "="
            CYCLE;    // SuperBaBaum !
          end
          else if (Mat.A.Aktionszeit=0:0) and (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) and (MAt.A.Bemerkung=*'*:FAHR*') then begin
            CYCLE;  /// 03.03.2021 AH
          end
          else begin
            // Schrottabwertungen (negativ!!) am gleichen Tag NICHT vererben!!!
            if (Mat.A.Aktionszeit=vVorTim) and ((Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_Mat_Umlage)) then begin
//debugx('cycle KEY204');
              CYCLE;
            end;
          end;
        end;
      end;
      
      Erx # SelrecInsert(aSel,204);
      if (Erx<>_rOK) then debug('ERROR Erx');
    END;
    
    vFirst # n;
    If ("Mat.Vorgänger"=0) then BREAK;
    
    // suche Enstehungs-Aktion:
    vKindNr # Mat.Nummer;
    Mat.A.Materialnr  # "Mat.Vorgänger";
    Mat.A.Entstanden  # vKindNr;
    Erx # RecRead(204,6,0);   // Mataktion lesen
    if (Erx<=_rMultikey) then begin
      if (vDatei=200) then begin
//          vVorDat # Mat.Datum.Erzeugt;
        Erx # Mat_Data:Read(Mat.A.Materialnr);
      end
      else if (vDatei=210) then begin
//          vVorDat # "Mat~Datum.Erzeugt";
        Erx # Mat_Data:Read(Mat.A.Materialnr);
      end;
      if (Erx>=200) then begin
        vDatei # Erx;
        vVorDat # Mat.A.Aktionsdatum;
        vVorTim # Mat.A.Aktionszeit;
//debugx(aint(vKindNr)+' entstand '+cnvad(vVorDat)+'@'+cnvat(vVorTim));
        CYCLE;
      end;
    end;
    
  UNTIL (1=1);

  RekRestore(v200);
  RekRestore(v210);

  RETURN true;

end;


//========================================================================
//  BuildFullAktionsliste
//
//========================================================================
sub BuildFullAktionsliste();
local begin
  vVorDat : date;
  vSel    : alpha;
  vHdl    : int;
  vHdl2   : int;
end;
begin
  BuildFullSel(var vHdl, var vSel);

  vHdl2 # VarInfo(WindowBonus);
  varInstance(WindowBonus, Cnvia(gMdi->wpcustom));
  w_SelName # vSel;
  gZLList-> wpDbSelection # vHdl;
  varInstance(WindowBonus, vHdl2);

end;


//========================================================================
//  Insert
//
//========================================================================
sub Insert(aOpt : int; aTyp : alpha;)
// : logic FR*HEr VOR ERX
: int;
local begin
  Erx     : int;
  vBuf204 : int;
  vNr     : int;
  vM      : float;
end;
begin
// 17.11.2016  if (Lib_Faktura:Abschlusstest(Mat.A.Aktionsdatum) = false) then
//    RETURN false;

  vBuf204 # RecBufCreate(204);
  RecBufCopy(204,vBuf204);
  if (RecLink(204,200,14,_RecLast)>_rLocked) then vNr # 1
  else vNr # Mat.A.Aktion + 1;
  RecBufCopy(vBuf204,204);
  RecBufDestroy(vBuf204);

  Mat.A.Materialnr      # Mat.Nummer;
  Mat.A.Anlage.Datum    # Today;
  Mat.A.Anlage.Zeit     # Now;
  Mat.A.Anlage.User     # gUserName;
  Mat.A.CO2ProT         # Rnd(Mat.A.CO2ProT,2);
  Mat.A.KostenW1        # Rnd(Mat.A.KostenW1,2);
  Mat.A.Kosten2W1       # Rnd(Mat.A.Kosten2W1,2);
  Mat.A.Gewicht         # Rnd(Mat.A.Gewicht, Set.Stellen.Gewicht);
  Mat.A.Nettogewicht    # Rnd(Mat.A.Nettogewicht, Set.Stellen.Gewicht);

  // 10.04.2013 VORLÄUFIG:
  vM # Mat.Bestand.Menge + Mat.Bestellt.Menge;
  if (vM=0.0) then vM # Mat_Data:MengeVorlaeufig(Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Gew);

  if (Mat.A.KostenW1ProMEH=0.0) and
    (Mat.A.KostenW1<>0.0) and (Mat.Bestand.Menge + Mat.Bestellt.Menge<>0.0) then
    Mat.A.KostenW1ProMEH # Rnd( (Mat.A.KostenW1 * (Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0) / (Mat.Bestand.Menge + Mat.Bestellt.Menge) ,2);
//debugx(anum(Mat.A.KostenW1,2)+' * '+anum((Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0,2)+' / '+anum((Mat.Bestand.Menge + Mat.Bestellt.Menge) ,2)+' = '+anum(Mat.A.KostenW1ProMEH,2));
  if (Mat.A.Kosten2W1ProME=0.0) and
    (Mat.A.Kosten2W1<>0.0) and (vM<>0.0) then
    Mat.A.Kosten2W1ProME # Rnd( (Mat.A.Kosten2W1 * (Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0) / vM ,2);

  if (Mat.A.Menge=0.0) and
    ((Mat.A.Gewicht<>0.0) or ("Mat.A.Stückzahl"<>0)) then begin
    Mat.A.Menge # Lib_Einheiten:WandleMEH(200, "Mat.A.Stückzahl", Mat.A.Gewicht, Mat.A.Gewicht, 'kg', Mat.MEH);
  end;
  Mat.A.KostenW1ProMEH  # Rnd(Mat.A.KostenW1ProMEH,2);
  Mat.A.Kosten2W1ProME  # Rnd(Mat.A.Kosten2W1ProME,2);
  Mat.A.Menge           # Rnd(Mat.A.Menge, Set.Stellen.Menge);

  Mat.A.Aktion # vNr;
  REPEAT
    Erx # RekInsert(204,aOpt,aTyp);
    if (Erx=_rDeadLock) then RETURN Erx;
    if (erx<>_rOK) then
      Mat.A.Aktion # Mat.A.Aktion + 1;
  UNTIL (Erx=_rOK);
//debug('isnert Akt:'+aint(mat.nummer)+' '+mat.a.aktionstyp+' '+mat.a.bemerkung);

  // 21.02.2022 AH
  if (Mat.A.Aktionstyp=c_Akt_EKK) then begin
    if (EKK_Data:Update(204)=false) then RETURN _rNorec;
  end;

  RETURN _rOK;
end;


//========================================================================
//  Replace
//
//========================================================================
sub Replace(aOpt : int; aTyp : alpha;) : int;
local begin
  Erx   : int;
end;
begin
  TRANSON;
  
  Erx # RekReplace(204,aOpt, aTyp);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN Erx;
  end;
  
  if (Mat.A.Aktionstyp=c_Akt_EKK) then begin
    if (EKK_Data:Update(204)=false) then begin
      TRANSBRK;
      RETURN _rNorec;
    end;
  end;
  
  TRANSOFF;

  RETURN Erx;
end;


//========================================================================