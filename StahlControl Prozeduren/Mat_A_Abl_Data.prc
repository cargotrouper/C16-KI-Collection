@A+
//===== Business-Control =================================================
//
//  Prozedur    Mat_A_Abl_Data
//                  OHNE E_R_G
//  Info
//
//
//  11.11.2009  AI  Erstellung der Prozedur
//  10.04.2013  AI  MatMEH
//  17.10.2014  AH  MatSofortInAblage
//  20.04.2018  AH  Zirkelbezüge werden ignoriert
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB Abl_AddKosten() : logic;
//    SUB Abl_Vererben(optaWas : alpha) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

//========================================================================
//  Abl_AddKosten
//    Berechnet die Kosten dieser Karte neu
//========================================================================
sub Abl_AddKosten() : logic;
local begin
  vBuf204   : int;
  vBuf204b  : int;
  vAnfang   : int;
  vNr       : int;
  vKosten   : float;
  vKostenPM : float;
  vBuf210   : int;
  vX        : float;
  vDat      : date;
  vDatei    : int;
end;

begin

RETURN Mat_A_Data:AddKosten(210);
/****
  vAnfang   # "Mat~Nummer";
  vNr       # "Mat~Nummer";
  vKosten   # 0.0;
  vKostenPM # 0.0;
  vDat      # "Mat~Datum.Erzeugt";

  WHILE (vNr<>0) do begin     // Karten loopen
/*
    "Mat~Nummer" # vNr;
    Erx # RecRead(210,1,0);
    if (Erx>_rLocked) then BREAK;
*/
    vDatei # Mat_Data:Read(vNr);
    if (vDatei<200) then BREAK;
    if (vDatei=200) then RecBufCopy(200,210);

    vBuf204 # RekSave(204);
    FOR Erx # RecLink(204,210,14,_recfirst)  // Aktionen loopen
    LOOP Erx # RecLink(204,210,14,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (Mat.A.Aktionsmat=vAnfang) or (Mat.A.Aktionsdatum<=vDat) then begin
        vKosten   # vKosten + Mat.A.KostenW1;
        vKostenPM # vKostenPM + Mat.A.KostenW1ProMEH;
      end;
    END;
    RekRestore(vBuf204);

    vNr   # "Mat~Vorgänger";    // zum Vorgänger gehen
    vDat  # "Mat~Datum.Erzeugt";
  END;

  "Mat~Nummer" # vAnfang;       // Kosten zurück speichern
  Erx # RecRead(210,1,_recLock);
  if (Erx<>_rOK) then RETURN false;
  "Mat~Kosten"            # vKosten;
  "Mat~EK.effektiv"       # "Mat~EK.Preis" + "Mat~Kosten";
  "Mat~KostenProMEH"      # vKostenPM;
  "Mat~EK.effektivProME"  # "Mat~EK.PreisProMEH" + "Mat~KostenProMEH";
  erx # Mat_Abl_data:ReplaceAblage(_RecUnlock,'AUTO');
  if (Erx<>_rOK) then RETURN false;


  vBuf204 # RekSave(204);
  FOR Erx # RecLink(204,210,14,_recfirst)   // Aktionen loopen
  LOOP Erx # RecLink(204,210,14,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) and (Mat.A.Entstanden<>0) and (Mat.A.Entstanden<>Mat.A.Materialnr) then begin
      vBuf210 # RekSave(210);
/*
      "Mat~Nummer" # Mat.A.Entstanden;
      RecRead(210,1,0);
*/
      vDatei # Mat_Data:Read(Mat.A.Entstanden);

      vBuf204b # RekSave(204);
      FOR Erx # RecLink(204, vDatei, 14,_recFirst)
      LOOP Erx # RecLink(204, vDatei, 14,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) and
          (Mat.A.Aktionsmat=vBuf210->"Mat~Nummer") and (Mat.A.Entstanden=0) then begin
          RecRead(204,1,_reCLock);
          vX # Rnd(Mat.A.Gewicht * vKosten / 1000.0,2);
          Mat.A.KostenW1        # Rnd(vX / "Mat~Bestand.Gew" * 1000.0,2);

          vX # Rnd(Mat.A.Menge * vKostenPM,2);
          DivOrNull(Mat.A.KostenW1ProMEH, vX, "Mat~Bestand.Menge",2);

          RekReplace(204,_recUnlock,'AUTO');
          Abl_AddKosten();
          BREAK;
        end;
      END;
      RekRestore(vBuf204b);
      RekRestore(vBuf210);
    end; // Kombi

    if (Mat.A.Aktionsdatum<="Mat~Datum.Erzeugt") then begin
      vKosten   # vKosten + Mat.A.KostenW1;
      vKostenPM # vKostenPM + Mat.A.KostenW1ProMEH;
    end;

  END;

  RekRestore(vBuf204);

  RETURN true;
  ****/
end;


//========================================================================
//  Abl_Vererben
//
//========================================================================
sub Abl_Vererben(opt aWas : alpha) : logic;
local begin
  Erx       : int;
  vBuf210   : int;
  vBuf200b  : int;
  vBuf210b  : int;
  vBuf204   : int;
  vWert     : float;
  vGew      : float;
  vMenge    : float;
  vWertPM   : float;
  vDatei    : int;
  vOK       : logic;
end;
begin

RETURN Mat_A_Data:Vererben(aWas, 210);


  vBuf204 # RekSave(204);

  if (Abl_AddKosten()=false) then begin   // diese Kosten hier summieren
    RekRestore(vBuf204);
    RETURN false;
  end;

  FOR Erx # RecLink(204,210,14,_recFirst)
  LOOP Erx # RecLink(204,210,14,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Mat.A.Entstanden=0) then CYCLE;
    if (Mat.A.Entstanden=Mat.A.Materialnr) then CYCLE;

    vBuf210 # RekSave(210);

    vDatei # Mat_data:Read(Mat.A.Entstanden, _recLock);
    if (vDatei<200) then begin
      RekRestore(vBuf210);
      RekRestore(vBuf204);
      Error(200106,aint(Mat.A.Entstanden));
      RETURN false;
    end;
/*
    "Mat~Nummer" # Mat.A.Entstanden;
    Erx # RecRead(210,1,_recLock);
    if (Erx<>_rOK) then begin
      RekRestore(vBuf210);
      RekRestore(vBuf204);
      RETURN false;
    end;
*/
    // Kombination mit anderen Karten???
    if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) then begin
      FOR Erx # RecLink(204, vDatei, 14,_recFirst)
      LOOP Erx # RecLink(204, vDatei, 14,_recNext)
      WHILE (Erx<_rLocked) do begin
        if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) and (Mat.A.Entstanden=0) then begin
          vBuf200b      # Reksave(200);
          vBuf210b      # Reksave(210);
//          "Mat~Nummer"  # Mat.A.Aktionsmat;
//          RecRead(210,1,0);
          Mat_Data:Read(Mat.A.Aktionsmat);
          vGew    # vGew + Mat.A.Gewicht;
          vWert   # vWert + ("Mat~EK.Preis" * Mat.A.Gewicht / 1000.0);
          vMenge  # vMenge + Mat.A.Menge;
          vWertPM # vWertPM + ("Mat~EK.PreisProMEH" * Mat.A.Menge);
          RekRestore(vBuf200b);
          RekRestore(vBuf210b);
        end;
      END;

      if ((vGew<>0.0) or (vMenge<>0.0)) then begin
        RecRead(vDatei,1,_recLock);
        if (vDatei=200) then begin
          DivOrNull(Mat.EK.Preis, vWert, vGew * 1000.0,2);
          DivOrNull("Mat.EK.PreisProMEH", vWertPM, vMenge,2);
        end;
        if (vDatei=210) then begin
          DivOrNull("Mat~EK.Preis", vWert, vGew * 1000.0,2);
          DivOrNull("Mat~EK.PreisProMEH", vWertPM, vMenge,2);
        end;
        Erx # RekReplace(vDatei,_RecUnlock,'AUTO');
        if (Erx<>_rOK) then begin
          RekRestore(vBuf210);
          RekRestore(vBuf204);
          Error(200106,aint(FldInt(vDatei,1,1)));
          RETURN false;
        end;
      end;
      RekRestore(vBuf210);
      CYCLE;
    end;  // Kombi

    if (aWas='EKPREIS') then begin
      vOK # Y;
      FOR Erx # RecLink(202, vDatei,12,_recFirst)
      LOOP Erx # RecLink(202, vDatei,12,_recNext)
      WHILE (Erx<=_rLocked) and (vOK) do begin
        if (Mat.B.PreisW1<>0.0) then vOK # n;
      END;
      if (vOk) then begin
        if (vDatei=200) then begin
          Mat.EK.Preis          # vBuf210->"Mat~EK.Preis";
          Mat.EK.PreisProMEH    # vBuf210->"Mat~EK.PreisProMEH";
        end
        else begin
          "Mat~EK.Preis"        # vBuf210->"Mat~EK.Preis";
          "Mat~EK.PreisProMEH"  # vBuf210->"Mat~EK.PreisProMEH";
        end;
        end
      else begin
        aWas # '';
      end;
    end;
//    "Mat~EK.Preis"          # vBuf210->"Mat~EK.Preis";
//    "Mat~EK.PreisProMEH"    # vBuf210->"Mat~EK.PreisProMEH";

    if (aWas='WERKSNR') or (aWas='*') then begin
      if (vDatei=200) then
        Mat.Werksnummer     # vBuf210->"Mat~Werksnummer"
      else
        "Mat~Werksnummer"   # vBuf210->"Mat~Werksnummer";
    end;
    if (aWas='COILNR') or (aWas='*') then begin
      if (vDatei=200) then
        Mat.Coilnummer      # vBuf210->"Mat~Coilnummer"
      else
        "Mat~Coilnummer"    # vBuf210->"Mat~Coilnummer";
    end;
    if (aWas='CHARGENNR') or (aWas='*') then begin
      if (vDatei=200) then
        Mat.Chargennummer   # vBuf210->"Mat~Chargennummer"
      else
        "Mat~Chargennummer" # vBuf210->"Mat~Chargennummer";
    end;
    if (aWas='LAGERGELD') then begin
      if (vDatei=200) and (vBuf210->"Mat~Datum.Lagergeld">"Mat.Datum.Lagergeld") then
        "Mat.Datum.Lagergeld" # vBuf210->"Mat~Datum.Lagergeld"
      else if (vDatei=210) and (vBuf210->"Mat~Datum.Lagergeld">"Mat~Datum.Lagergeld") then
        "Mat~Datum.Lagergeld" # vBuf210->"Mat~Datum.Lagergeld";
    end;

    Erx # RekReplace(vDatei,_RecUnlock,'AUTO');
    if (erx<>_rOK) then begin
      RekRestore(vBuf210);
      RekRestore(vBuf204);
      Error(200106,aint(FldInt(vDatei,1,1)));
      RETURN false;
    end;

    if (vDatei=200) then vOK # Mat_A_Data:Vererben(aWas);
    else if (vDatei=210) then vOK # Abl_Vererben(aWas);
    if (vOK=false) then begin
      RekRestore(vBuf210);
      RekRestore(vBuf204);
      RETURN false;
    end;

    RekRestore(vBuf210);
  END;

  RekRestore(vBuf204);

  RETURN true;

end;


//========================================================================