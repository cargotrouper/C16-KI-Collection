@A+
//===== Business-Control =================================================
//
//  Prozedur    SWe_P_Data
//                  OHNE E_R_G
//  Info
//
//
//  18.09.2007  AI  Erstellung der Prozedur
//  23.10.2018  ST  Bugfix: Kopfdaten werden vor Verbuchen erneut gelesen
//  04.02.2022  AH  ERX
//  30.05.2023  ST  Mat.Übernahmedatum wird nur bei Eigenmaterial gesetzt
//
//  Subprozeduren
//    SUB UpdateMaterial(aNeu : logic) : logic;
//    SUB Verbuchen(aNeuanlage : logic) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

//========================================================================
//  UpdateMaterial
//        Schreibt die Bestell/Eingangsdaten in das Material
//========================================================================
sub UpdateMaterial(aNeu : logic) : logic;
local begin
  Erx     : int;
  vPreis  : float;
  vDat    : date;
end;
begin

  if (SWe.P.AvisYN) then RETURN true;
  if (SWe.P.AusfallYN) then RETURN true;

  if (SWe.P.EingangYN) then vDat # SWe.P.Eingang_Datum;

  Mat.Nummer # SWe.P.MaterialNr;
  Erx # RecRead(200,1,_recLock);
//debug('read:'+cnvai(swe.p.materialnr)+'Erx');
  if (Erx<>_rOK) then RETURN false;

  RekLink(620,621,1,0); // Kopfdaten erneut lesen


  Mat.Warengruppe         # SWe.P.Warengruppe;
  "Mat.Güte"              # "SWe.P.Güte";
  "Mat.Gütenstufe"        # "SWe.P.Gütenstufe";

  "Mat.AusführungOben"    # '';
  "Mat.AusführungUnten"   # '';
  Erx # RecLink(622,621,10,_recFirsT);
  WHILE (Erx=_rOK) do begin
    RecBufClear(201);
    Mat.AF.Nummer       # Mat.Nummer;
    Mat.AF.Seite        # SWe.P.AF.Seite;
    Mat.AF.lfdNr        # SWe.P.AF.lfdNr;
    Mat.AF.ObfNr        # SWe.P.AF.ObfNr;
    Mat.AF.Bezeichnung  # SWe.P.AF.Bezeichnung;
    Mat.AF.Zusatz       # SWe.P.AF.Zusatz;
    Mat.AF.Bemerkung    # SWe.P.AF.Bemerkung;
    "Mat.AF.Kürzel"     # "SWe.P.AF.Kürzel";
    Erx # RekInsert(201,0,'AUTO');
    Erx # RecLink(622,621,10,_recNext);
  END;

  Mat.Coilnummer        # SWe.P.Coilnummer;
  Mat.Ringnummer        # SWe.P.Ringnummer;
  Mat.Chargennummer     # SWe.P.Chargennummer;
  Mat.Werksnummer       # SWe.P.Werksnummer;
  
  Mat.EigenmaterialYN   # SWe.EigenmaterialYN;
  // ST 2023-05-30: Nur Eigenmaterial darf Eigenmaterialdatum
  if (Mat.EigenmaterialYN) then
    "Mat.Übernahmedatum"  # vDat;
    
  Mat.Dicke             # SWe.P.Dicke;
  Mat.Dicke.Von         # SWe.P.Dicke.Von;
  Mat.Dicke.Bis         # SWe.P.Dicke.bis;
  Mat.DickenTolYN       # SWe.P.DickenTolYN;
  Mat.DickenTol         # SWe.P.DickenTol;
  Mat.Breite            # SWe.P.Breite;
  Mat.Breite.Von        # SWe.P.Breite.Von;
  Mat.Breite.Bis        # SWe.P.Breite.Bis;
  Mat.BreitenTolYN      # SWe.P.BreitenTolYN;
  Mat.BreitenTol        # SWe.P.BreitenTol
  "Mat.Länge"           # "SWe.P.Länge";
  "Mat.Länge.Von"       # "SWe.P.Länge.Von";
  "Mat.Länge.Bis"       # "SWe.P.Länge.Bis";
  "Mat.LängenTolYN"     # "SWe.P.LängenTolYN";
  "Mat.LängenTol"       # "SWe.P.LängenTol";
  Mat.RID               # SWe.P.RID;
  Mat.RAD               # SWe.P.RAD;
  Mat.Strukturnr        # SWe.P.Artikelnr;
  Mat.Intrastatnr       # SWe.P.Intrastatnr;
  Mat.Ursprungsland     # SWe.P.Ursprungsland;
  Mat.Zeugnisart        # '';
  Mat.Zeugnisakte       # '';
  Mat.EK.Preis          # 0.0;
  "Mat.CO2EinstandProT" # "SWe.P.CO2EinstandPT";
  "Mat.CO2ZuwachsProT"  # 0.0;
  
  Mat.Bestand.Stk       # "SWe.P.Stückzahl";
  Mat.Bestand.Gew       # SWe.P.Gewicht;


  if (aNeu) then begin
    Mat.Kommission        # '';
    if (SWe.P.GesperrtYN=n) then begin
      Mat_Data:SetStatus(c_Status_EKWE);
      end
    else begin
      Mat_Data:SetStatus(c_Status_EKgesperrt);
    end;
    end
  else begin  // Edit
    if (SWe.P.GesperrtYN=n) then begin
      Mat_Data:SetStatus(c_Status_EKWE);
      end
    else begin
      Mat_Data:SetStatus(c_Status_EKgesperrt);
    end;
  end;

  Mat.Bemerkung1        # SWe.P.Bemerkung;
  Mat.Bestellnummer     # AInt(SWe.P.Nummer)+'/'+AInt(SWe.P.Position);
  Mat.BestellABNr       # '';
  Mat.Bestelldatum      # 0.0.0;
  Mat.BestellTermin     # 0.0.0;
  if (SWe.P.EingangYN) then
    Mat.Eingangsdatum     # vDat
  else
    Mat.Eingangsdatum     # 0.0.0;

  if (SWe.P.EingangYN) then
    Mat.Datum.Erzeugt     # vDat;
  if (SWe.P.AusfallYN) then
    Mat.Datum.Erzeugt     # SWe.P.Ausfall_datum;

  Mat.Erzeuger          # SWe.P.Erzeuger;
  Mat.Lieferant         # SWe.Lieferant;
  Mat.Lageradresse      # SWe.P.Lageradresse;
  Mat.Lageranschrift    # SWe.P.Lageranschrift;
  Mat.Lagerplatz        # SWe.P.Lagerplatz;

  // Analyse
  if (Set.LyseErweitertYN) then
    Mat.Analysenummer   # SWe.P.Analysenummer;

  Mat.Streckgrenze1     # SWe.P.Streckgrenze;
  Mat.Zugfestigkeit1    # SWe.P.Zugfestigkeit;
  Mat.StreckgrenzeB1    # SWe.P.Streckgrenze2;
  Mat.ZugfestigkeitB1   # SWe.P.Zugfestigkeit2;
  Mat.DehnungA1         # SWe.P.DehnungA;
  Mat.DehnungB1         # SWe.P.DehnungB;
  Mat.DehnungC1         # SWe.P.DehnungC;
  Mat.RP02_V1           # SWe.P.RP02_1;
  Mat.RP02_B1           # SWe.P.RP02_2;
  Mat.RP10_V1           # SWe.P.RP10_1;
  Mat.RP10_B1           # SWe.P.RP10_2;
  "Mat.Körnung1"        # "SWe.P.Körnung";
  "Mat.KörnungB1"       # "SWe.P.Körnung2";
  "Mat.HärteA1"         # "SWe.P.Härte1";
  "Mat.HärteB1"         # "SWe.P.Härte2";
  Mat.RauigkeitA1       # SWe.P.RauigkeitA1;
  Mat.RauigkeitB1       # SWe.P.RauigkeitA2;
  Mat.RauigkeitC1       # SWe.P.RauigkeitB1;
  Mat.RauigkeitD1       # SWe.P.RauigkeitB2;

  Mat.Chemie.C1         # SWe.P.Chemie.C;
  Mat.Chemie.Si1        # SWe.P.Chemie.Si;
  Mat.Chemie.Mn1        # SWe.P.Chemie.Mn;
  Mat.Chemie.P1         # SWe.P.Chemie.P;
  Mat.Chemie.S1         # SWe.P.Chemie.S;
  Mat.Chemie.Al1        # SWe.P.Chemie.Al;
  Mat.Chemie.Cr1        # SWe.P.Chemie.Cr;
  Mat.Chemie.V1         # SWe.P.Chemie.V;
  Mat.Chemie.Nb1        # SWe.P.Chemie.Nb;
  Mat.Chemie.Ti1        # SWe.P.Chemie.Ti;
  Mat.Chemie.N1         # SWe.P.Chemie.N;
  Mat.Chemie.Cu1        # SWe.P.Chemie.Cu;
  Mat.Chemie.Ni1        # SWe.P.Chemie.Ni;
  Mat.Chemie.Mo1        # SWe.P.Chemie.Mo;
  Mat.Chemie.B1         # SWe.P.Chemie.B;

  // Verpackung
  Mat.Verwiegungsart    # SWe.P.Verwiegungsart;
  Mat.Gewicht.Netto     # SWe.P.Gewicht.Netto;
  Mat.Gewicht.Brutto    # SWe.P.Gewicht.Brutto;
  Mat.AbbindungL        # SWe.P.AbbindungL;
  Mat.AbbindungQ        # SWe.P.AbbindungQ;
  Mat.Zwischenlage      # SWe.P.Zwischenlage;
  Mat.Unterlage         # SWe.P.Unterlage;
  Mat.Umverpackung      # SWe.P.Umverpackung;
  Mat.Wicklung          # SWe.P.Wicklung;
  Mat.StehendYN         # SWe.P.StehendYN;
  Mat.LiegendYN         # SWe.P.LiegendYN;
  Mat.Nettoabzug        # SWe.P.Nettoabzug;
  "Mat.Stapelhöhe"      # "SWe.P.Stapelhöhe";
  "Mat.Stapelhöhenabzug" # "SWe.P.Stapelhöhenabz";
  Mat.Rechtwinkligkeit  # SWe.P.Rechtwinkligk;
  Mat.Ebenheit          # SWe.P.Ebenheit;
  "Mat.Säbeligkeit"     # "SWe.P.Säbeligkeit";
  "Mat.SäbelProM"       # "SWe.P.SäbelProM";


  Erx # Mat_data:Replace(_RecUnlock,'AUTO');
  if (erx<>_rOK) then RETURN false;

  RETURN true;
end;


//========================================================================
//  Verbuchen
//        verbucht einen Wareneingang/AVIS/Ausfall
//========================================================================
sub Verbuchen(aNeuanlage : logic) : logic;
local begin
  Erx     : int;
  vNr     : int;
  vA      : alpha;
end;
begin

  if (SWe.P.AvisYN) then RETURN true;
  if (SWe.P.AusfallYN) then RETURN true;
  if (SWe.P.EingangYN=n) then RETURN true;

  Erx # RecLink(819,621,3,_recFirst);   // Warengruppe holen
  if (Erx>_rLocked) then RETURN false;

  RekLink(620,621,1,0); // Kopfdaten erneut lesen

  // NUR Material !!!
  if ((Wgr_Data:IstMat()=false) and (Wgr_Data:IstMix()=false)) then RETURN true;

  if (aNeuanlage) and (SWe.P.Materialnr=0) then begin
    vNr # Lib_Nummern:ReadNummer('Material');
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;

    RecRead(621,1,_recLock);
    SWe.P.MaterialNr  # vNr;
    Erx # RekReplace(621,_RecUnlock,'AUTO');
    if (erx<>_rOK) then RETURN false;

    // neues Material generieren
    RecBufClear(200);
    Mat.Nummer    # vNr;
    Mat.Ursprung  # vNr;
    Erx # Mat_Data:Insert(0,'AUTO', Mat.Eingangsdatum);
    if (Erx<>_rOK) then RETURN false;
  end;


  if (UpdateMaterial(aNeuanlage)=false) then begin
    RETURN false;
  end;


  // Ankerfunktion:
  if (aNeuanlage) then vA # 'Y'
  else vA # 'N';
  RunAFX('SWE.P.Data.Verbuchen.Post',vA);


  // Erfolg !!!
  RETURN true;

end;


//========================================================================