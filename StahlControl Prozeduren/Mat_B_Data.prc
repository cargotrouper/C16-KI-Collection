@A+
//==== Business-Control ==================================================
//
//  Prozedur    Mat_B_Data
//                  OHNE E_R_G
//  Info
//    Enthält Funktionen zum Ermitteln von Bestandsbuchwerten
//
//  12.08.2014  ST  Erstellung der Prozedur
//  27.08.2014  AH  Neu: "BewegungenRueckrechnen"
//  19.11.2014  AH  BugFix: Splitten hatte Menge positiv
//  10.03.2017  AH  "EkZumDatum"
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB BewegungenRueckrechnen(aStichtag : date);
//    SUB GewichtZumDatum(aMaterialnr : int; aStichtag : date) : float
//    SUB EkZumDatum(aStichtag   : date; var aEK     : float;  var aEkPro  : float) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

//========================================================================
// BewegungenRueckrechnen
//========================================================================
sub BewegungenRueckrechnen(
  aStichtag     : date;
  opt aNurMenge : logic);
local begin
  Erx   : int;
  v202  : int;
  v204  : int;
end;
begin
  v202 # RekSave(202);
  v204 # RekSave(204);

  // Bestandsbuch mit einrechnen...
  FOR Erx # RecLink(202,200,12,_recFirst)
  LOOP Erx # RecLink(202,200,12,_recNext)
  WHILE (Erx<=_rLocked) do begin
    // alle Bewegungen NACH dem Stichtag rückrechnen...
    if (Mat.B.Datum>=aStichtag) then begin
//debugx('KEY204                    bb:'+anum(mat.b.gewicht,0)+'kg   '+anum(mat.b.menge,2)+Mat.MEH);
      // 19.11.2014 BUGFIX zum Negieren
      if (Mat.B.Bemerkung=c_Akt_SPLIT) then begin
        if (("Mat.B.Stückzahl"<0) or (Mat.B.Gewicht<0.0)) and (Mat.B.Menge>0.0) then
          Mat.B.Menge # - Mat.B.Menge;
      end;

      Mat.Bestand.Gew   # Mat.Bestand.Gew - Mat.B.Gewicht;
      Mat.Bestand.Stk   # Mat.Bestand.Stk - "Mat.B.Stückzahl";
      Mat.Bestand.Menge # Mat.Bestand.Menge - "Mat.B.Menge";
    end;
    if (aNurMenge=false) then begin
      // alle Bewertungen INCL. des Stichtages rückrechnen...
      if (Mat.B.Datum>aStichtag) then begin
        Mat.EK.Preis    # Mat.EK.Preis - Mat.B.PreisW1;
        Mat.EK.Effektiv # Mat.EK.Effektiv - Mat.B.PreisW1;
      end;
    end;
  END;

  if (aNurMenge=false) then begin
    // Aktionen loopen...
    FOR Erx # RecLink(204,200,14,_RecFirst)
    LOOP Erx # RecLink(204,200,14,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      // alle Aktionen NACH dem Stichtag rückrechnen...
      if (Mat.A.AktionsDatum>=aStichtag) then begin
        Mat.EK.Effektiv # Mat.EK.Effektiv - Mat.A.KostenW1;
      end;
    END;
  end;


  RekRestore(v202);
  RekRestore(v204);

  // FIXMENGE
  if (Mat.Bestand.Menge=0.0) then begin
    if (Mat.MEH='kg') then Mat.Bestand.Menge # Mat.Bestand.Gew
    else if (Mat.MEH='t') then Mat.Bestand.Menge # Rnd(Mat.Bestand.Gew / 1000.0, Set.Stellen.Menge)
    else if (Mat.MEH='Stk') then Mat.Bestand.Menge # cnvfi(Mat.Bestand.Stk)
  end;

end;


//========================================================================
// sub GewichtZumDatum(aMaterialnr : int; aStichtag : date) : float
//
//    Ermittelt das Gewicht zum Datum
//========================================================================
sub GewichtZumDatum(aMaterialnr : int; aStichtag : date) : float
local begin
  Erx   : int;
  vGew  : float;
end;
begin

  // Material lesen
  if (Mat_Data:Read(aMaterialNr) < 200) then
    RETURN 0.0;

  vGew # Mat.Bestand.Gew;

  // Alle früheren Einträge zurückrechnen
  FOR   Erx  # RecLink(202,200,12,_RecLast)
  LOOP  Erx  # RecLink(202,200,12,_RecPrev)
  WHILE (Erx <= _rOK) and (Mat.B.Datum >= aStichtag) do begin
//    if (Mat.B.Datum >= aStichtag) then
      vGew # vGew - Mat.B.Gewicht;
  END;

  RETURN vGew;
end


//========================================================================
//========================================================================
sub EkZumDatum(
  aStichtag   : date;
  var aEK     : float;
  var aEkPro  : float) : logic;
local begin
  Erx : int;
end;
begin

  aEK     # Mat.EK.Preis;
  aEkPro  # Mat.EK.PreisProMeh;

  // Bestandsbuch mit einrechnen...
  FOR Erx # RecLink(202,200,12,_recFirst)
  LOOP Erx # RecLink(202,200,12,_recNext)
  WHILE (Erx <= _rOK) do begin
    if (Mat.B.Datum > aStichtag) then begin
      // alle Bewegungen NACH dem Stichtag rückrechnen...
      aEK    # aEk - Mat.B.PreisW1;
      aEkPro # aEkPro - Mat.B.PreisW1ProMeh;  // 2023-03-23 AH FIX, war aEKpro # aEK - ... 
    end;
  END;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================