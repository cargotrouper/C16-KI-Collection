@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Berechnungen
//                    OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  15.12.2014  AH  "IntsAusAlpha"
//  27.02.2015  AH  NewCalTime, NewDateTime
//  25.03.2015  AH  AddWerktage
//  27.07.2015  AH  Formeln für Stäbe ("ST")
//  19.11.2018  AH  AFX "Toleranzkorrektur"
//  17.12.2019  AH  Neu: "MinutenZwischen"
//  22.02.2021  AH  Neu: "CaltimeCompare"
//  08.07.2021  AH  Neu: Güte nötig zur Dichtenbestimmung
//  27.07.2021  AH  ERX
//  15.12.2021  AH  Fix gegen negative Mengen/Volumen
//  21.06.2022  AH  "Quadrat_in_Ronde"
//  2022-10-26  AH  neue Formeln
//  2022-11-28  AH  "FloatAusAlpha"
//  2023-05-23  ST  neu "Monat_Zahl_aus_Name_DE"
//
//  Subprozeduren
//    SUB RndUp(aWert : Float) : float;
//    SUB NewCaltime(aDat : date; aTim : time) : caltime;
//    SUB NewDateTime(aCT : caltime; var aDat  : date; var aTim  : time);
//    SUB StrModulo(aString : alpha; aMod : int) : int;
//    SUB inch_aus_mm(aMM : float;) : float;
//    SUB lbs_aus_kg(aGew : float;) : float;
//    SUB NettoBruttoAusGewicht(aGewicht : float; aVWA : int; var aNetto : float; var aBrutto : float);
//    SUB Prozent(aTeil : float; aGes : float) : float;
//    SUB kgmm_aus_KgStkB(aKg : float; aStk : int; aB : float) : float;
//    SUB kg_aus_StkDBLDichte2(aStk : int; aD : float; aB : float; aL : float; aDichte : float; aTraene : float, opt aAlsBlock : logic;) : float;
//    SUB Stk_aus_KgDBLDichte2(akg : float; aD : float; aB : float; aL : float; aDichte : float; aTraene : float) : int;
//    SUB RAD_aus_KgStkBDichteRID(akg : float; aStk : int; aB : float; aDichte : float; aRID : float) : float;
//    SUB L_aus_KgStkDBDichte2(aKg : float; aStk : int; aD : float; aB : float; aDichte : float; aTraene : float) : float;
//    SUB L_aus_KgStkDBWgrArt(akg : float; aStk : int; aD : float; aB : float; aWgr : int; aGuete : alpha; aArt : alpha) : float;
//    SUB Kg_aus_StkBDichteRIDRAD(aStk : int; aB : float; aDichte : float; aRID : float; aRAD : float) : float;
//    SUB L_aus_KgStkDichteRIDRAD(aKg : float; aStk : int; aDichte : float; aRID : float; aRAD : float): float;
//    SUB Kgmm_aus_DichteRIDRAD(aDichte : float, aRID :float, aRAD : float) : float;
//    SUB RAD_aus_DichteRIDKGMM(aDichte : float; aRID : float; aKGMM : float) : float;
//    SUB LeapYear(aYear : int) : int;
//    SUB KW_aus_Datum(aDate : date; VAR aKW : word; VAR aYear : word);
//    SUB Mo_von_KW(aKW : int; aYear : int; VAR aDate : date)
//    SUB Datum_aus_ZahlJahr(aArt : alpha; aZahl : word; aJahr : word; varaDatum : date);
//    SUB EndDatum_aus_ZahlJahr(aArt : alpha; var aZahl : word; var aJahr : word; varaDatum : date);
//    SUB ZahlJahr_aus_Datum(aDatum : date; aArt : alpha; varaZahl : word; varaJahr : word);
//    SUB Tag_aus_datum(aDatum : date) : alpha;
//    SUB Monat_aus_datum(aDatum : date) : alpha;
//    SUB Monat_Zahl_aus_Name_DE(aMonthName : alpha) : int
//    SUB TerminModify(var aDat  : date; var aZeit : time; aMin : float);
//    SUB AddWerktage(aDat : date; aTage : int) : date;
//    SUB Waehrung_Umrechnen(aWert1 : float; aWae1 : int; varaWert2 : float; aWae2 : int) : logic;
//    SUB ToleranzZuWerten(aText : alpha; varaVon : float; varaBis : float)
//    SUB Toleranzkorrektur(aText : alpha; aStellen : ints) : alpha;
//    SUB KurzDatum_aus_Datum(aDat : date) : alpha
//    SUB Stk_aus_KgDBLWgrArt(akg : float; aD : float; aB : float; aL : float; aWgr : int; aGuete : alpha; aArt  : alpha): int;
//    SUB KG_aus_StkDBLWgrArt(aStk : int; aD: float; aB : float; aL : float; aWgr : int; aGuete : alpha; aArt : alpha): float;
//    SUB AuflaufH_aus_RIDRAD(aRID : float; aRAD : float) : float
//    SUB RAD_aus_KgStkBDichteRIDTlg(akg : float; aStk : int; aB : float; aDichte : float; aRID : float; aTlg  : int;): float
//    SUB kg_aus_StkDAdDichte2(aStk : int; aD : float; aAD : float; aDichte : float; aTraene : float): float;
//    SUB A_aus_StkAd(aStk : int; aAD : float): float;
//    SUB Quadrat_in_Ronde
//
//    SUB Dreisatz(aGes : float; aBasis  : float; aTeil   : float) : float;
//    SUB DatTimToBig(aDat : date; aTim  : Time) : BigInt;
//    SUB LetzterTagImMonat(aMonat : int; aJahr : int) : date
//    SUB BytesToAlpha(aBytes : int) : alpha
//    SUB IntsAusAlpha(aText : alpha;  var aI : int;  var aW1 : word; var aW2 : word) : logic;
//    SUB Int1AusAlpha(aText : alpha;  var aI : int) : logic;
//    SUB Int2AusAlpha(aText : alpha;  var aI : int;  var aW1 : word) : logic;
//    SUB FloatAusAlpha
//    SUB MinutenZwischen(aStartDat : date; aStartTim : time: aEndeDat : date; aEndeTim : time) : int
//    SUB CaltimeCompare(aDat1   : date; aTim1   : time; aDat2   : date; aTim2   : time) : alpha
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

DEFINE begin
  PI : 3.141592654
end;

LOCAL begin
  vKgProStk : float;
  vV  : float;
  vRI : float;
  vRA : float;
end;

declare L_aus_KgStkDichteRIDRAD(aKg : float; aStk : int; aDichte : float; aRID : float; aRAD : float): float;

//=========================================================================
//  RndUp
//        Ganzzahliges Runden auf nächste ganze Zahl
//=========================================================================
SUB RndUp(aWert : Float) : float;
begin
  if (aWert=Trn(aWert)) then
    RETURN aWert;

  RETURN Trn(aWert) + 1.0;
end;


//=========================================================================
// NewCalTime
//      Konvertiert Date und Time in CalTime
//=========================================================================
sub NewCaltime(
  aDat  : date;
  aTim  : time) : caltime;
local begin
  vCT   : caltime;
end;
begin
  if (aDat<>0.0.0) then vCT->vpDate # aDat;
  vCT->vpTime # aTim;
  RETURN vCT;
end;


//=========================================================================
//  NewDateTime
//      Konvertiert Caltime in Date und Time
//=========================================================================
sub NewDateTime(
  aCT       : caltime;
  var aDat  : date;
  var aTim  : time);
begin
  aDat # aCT->vpDate;
  aTim # aCT->vpTime;
end;


//========================================================================
//  StrModulo
//
//========================================================================
sub StrModulo(
  aString : alpha;
  aMod    : int;
) : int;
local begin
  vI  : int;
  vA  : alpha;
end;
begin
  if (strLen(aString)<10) then begin
    vI # cnvia(aString);
    vI # vI % aMod;
    RETURN VI;
  end;

  vA # StrCut(aString,1,9);
  vI # StrModulo(vA, aMod);
  aString # aint(vI)+StrCut(aString, 10, 200);
  RETURN StrModulo(aString, aMod);
end;


//========================================================================
//  inch_aus_mm
//
//========================================================================
sub inch_aus_mm(aMM : float;) : float;
local begin
end;
begin
  RETURN aMM * 0.03937;
end;


//========================================================================
//  lbs_aus_kg
//
//========================================================================
sub lbs_aus_kg(aGew : float;) : float;
local begin
end;
begin
  RETURN aGew * 2.20462262;
end;

//========================================================================
//  NettoBruttoAusGewicht
//
//========================================================================
sub NettoBruttoAusGewicht(
  aGewicht    : float;
  aVWA        : int;
  var aNetto  : float;
  var aBrutto : float
);
local begin
  vOK : logic;
end;
begin

  vOK # y;
  // Verwiegungsart holen
  if (VWA.Nummer<>aVWA) then begin
    VWA.Nummer # aVWA;
    if (RecRead(818,1,0)>_rLocked) then vOK # n;
  end;

  if (vOK) then begin
    if (VWa.NettoYN) then begin
      if (aGewicht<>0.0) then
        aNetto    # aGewicht;
      else
        aGewicht  # aNetto;
    end;
    if (VWa.BruttoYN) then begin
      if (aGewicht<>0.0) then
        aBrutto   # aGewicht
      else
        aGewicht  # aBrutto;
    end;
    end
  else begin
    if (aGewicht<>0.0) then begin
      aNetto   # aNetto;
      aBrutto  # aGewicht;
      end
    else begin
      aGewicht  # aNetto;
    end;
  end;
end;


//========================================================================
//  Prozent
//
//========================================================================
sub Prozent(aTeil : float; aGes : float) : float;
begin
  if (aGes=0.0) then
    if (aTeil=0.0) then RETURN 0.0
    else RETURN 100.0;
  RETURN (aTeil / aGes * 100.0)
end;


//========================================================================
//  kgmm_aus_KgStkB
//
//========================================================================
sub kgmm_aus_KgStkB(
  aKg : float;
  aStk : int;
  aB : float;
) : float;
begin
  if (aB<>0.0) and (aStk<>0) then
    RETURN (rnd (aKg / CnvFI(aStk) / aB ,2))
  else
    RETURN 0.0;
end;


//========================================================================
//  kg_aus_StkDBLDichte2
//
//========================================================================
sub kg_aus_StkDBLDichte2(
  aStk    : int;
  aD      : float;
  aB      : float;
  aL      : float;
  aDichte : float;
  aTraene : float;
  opt aAlsBlock : logic;
 ): float;
local begin
  vX : float;
end;
begin

//debug('Gew aus:'+cnvaI(aStk)+'Stk, '+cnvaf(aD)+'x'+cnvaf(aB)+'x'+cnvaf(aL)+'  '+cnvaf(aDichte)+'g/cm³');
  if (aAlsBlock) then begin
    aL # aL * cnvfi(aStk);
    aStk # 1;
  end;

  aD # aD / 100.0;
  aB # aB / 100.0;
  aL # aL / 100.0;
  vX # (aD * aB * aL * aDichte);
  if ("Set.Stellen.Stk<>KG"=99) then
    vX # vX + (aB*aL /100.0 * aTraene)
  else
    vX # Rnd(vX + (aB*aL /100.0 * aTraene), "Set.Stellen.Stk<>KG");

  vX # Rnd(vX * CnvFI(aStk), Set.Stellen.Gewicht);
//debug(cnvai(aStk)+' '+cnvaf(aD)+' '+cnvaf(aB)+' '+cnvaf(aL)+' '+cnvaf(aDichte)+' '+cnvaf(atraene)+' = '+cnvaf(vX));

  RETURN vX;
end;


//========================================================================
//  Stk_aus_KgDBLDichte2
//
//========================================================================
sub Stk_aus_KgDBLDichte2(
  akg : float;
  aD : float;
  aB : float;
  aL : float;
  aDichte : float;
  aTraene : float;
): int;
begin

//debug('stk aus:'+cnvaf(aKg)+'kg, '+cnvaf(aD)+'x'+cnvaf(aB)+'x'+cnvaf(aL)+'  '+cnvaf(aDichte)+'g/cm³');

  aD # aD / 100.0;
  aB # aB / 100.0;
  aL # aL / 100.0;
  vKgProStk # aD * aB * aL * aDichte;

//  vKgProStk # Rnd(vKgProStk + (aB*aL/100.0 * aTraene),5);
  if ("Set.Stellen.Stk<>KG"=99) then
    vKgProStk # vKgProStk + (aB*aL/100.0 * aTraene)
  else
    vKgProStk # Rnd(vKgProStk + (aB*aL/100.0 * aTraene), "Set.Stellen.Stk<>KG");

  vkgProStk # (vKgproStk*100.0);
  aKG # aKG * 100.0;

//todo('kg pro stk:'+cnvaf(vKgProStk)+'   errechnet stk:'+cnvaf(aKg / vKgProStk));
  if (vKgProStk<>0.0) then begin
//    if (aKg % vKgProStk<0.001) then begin
      RETURN CnvIF(aKg div vKgProStk);
//      end
//    else begin
//      RETURN CnvIF(aKg div vKgProStk)+1;
//    end;
    end

  else begin

    RETURN 0;
  end;

end;


/*========================================================================
2022-10-26  AH
========================================================================*/
sub StkFloat_aus_KgDBLDichte2(
  akg : float;
  aD : float;
  aB : float;
  aL : float;
  aDichte : float;
  aTraene : float;
): float
local begin
  vStk  : float;
end;
begin
//debug('stk aus:'+cnvaf(aKg)+'kg, '+cnvaf(aD)+'x'+cnvaf(aB)+'x'+cnvaf(aL)+'  '+cnvaf(aDichte)+'g/cm³');
  aD # aD / 100.0;
  aB # aB / 100.0;
  aL # aL / 100.0;
  vKgProStk # aD * aB * aL * aDichte;

//  vKgProStk # Rnd(vKgProStk + (aB*aL/100.0 * aTraene),5);
  if ("Set.Stellen.Stk<>KG"=99) then
    vKgProStk # vKgProStk + (aB*aL/100.0 * aTraene)
  else
    vKgProStk # Rnd(vKgProStk + (aB*aL/100.0 * aTraene), "Set.Stellen.Stk<>KG");

  vkgProStk # (vKgproStk*100.0);
  aKG # aKG * 100.0;

//todo('kg pro stk:'+cnvaf(vKgProStk)+'   errechnet stk:'+cnvaf(aKg / vKgProStk));
  if (vKgProStk<>0.0) then begin
      vStk # aKg div vKgProStk;
  end;

  RETURN vStk;
end;


//========================================================================
//  RAD_aus_KgStkBDichteRID
//
//========================================================================
sub RAD_aus_KgStkBDichteRID(
  akg : float;
  aStk : int;
  aB : float;
  aDichte : float;
  aRID : float;
): float;
begin

  aB # aB / 100.0;
  vRI # aRid / 200.0;

  if (aStk<>0) then
    vKgProStk # aKg / CnvFI(aStk)
  else
    vKgProStk # aKg;

  if (aDichte<>0.0) then
    vV # Abs(vKgProStk / aDichte);

  if (aB<>0.0) then
//    RETURN Sqrt( (vV/(pi*aB)) + (vRI*vRI) ) * 200.0
    RETURN (Rnd( Sqrt( (vV/(pi * aB)) + (vRI*vRI) ) * 200.0, Set.Stellen.Radien))
  else
    RETURN 0.0;

end;


//========================================================================
//  L_aus_KgStkDBDichte2
//
//========================================================================
sub L_aus_KgStkDBDichte2(
  aKg     : float;
  aStk    : int;
  aD      : float;
  aB      : float;
  aDichte : float;
  aTraene : float;
): float;
local begin
  vX  : float;
end;
begin
//debug(ANum(aKg,0)+'kg   '+AInt(aStk)+'Stk   '+ANum(aD,2)+'D   '+ANum(aB,2)+'B  '+ANum(aDichte,5)+'dichte');
  aD # aD / 1000.0;
  aB # aB / 1000.0;

  if (aStk<>0) then
    vKgProStk # aKg / CnvFI(aStk)
  else
    vKgProStk # aKg;

  vX # ((aDichte*aD*1000.0)+aTraene) * aB;

  if (vX<>0.0) then
    vX # vkgProStk / vX * 1000.0;

  RETURN Rnd(vX, "Set.Stellen.Länge");
end;


//========================================================================
//  L_aus_KgStkDBWgrArt
//========================================================================
sub L_aus_KgStkDBWgrArt(
  akg     : float;
  aStk    : int;
  aD      : float;
  aB      : float;
  aWgr    : int;
  aGuete  : alpha;
  aArt    : alpha;
) : float;
local begin
  Erx   : int;
  vL    : float;
end;
begin
//debug('L aus:'+cnvaI(aStk)+'Stk, '+anum(akg,0)+'kg ,'+cnvaf(aD)+'x'+cnvaf(aB)+'  '+cnvai(aWgr)+'Wgr');
  if (Wgr.Nummer<>aWgr) then begin
    Wgr.Nummer # aWgr;
    Erx # Recread(819,1,0);       // Warengruppe holen
    if (Erx>_rlocked) then RecBufClear(819);
  end;

  // Artikelberechnung...
  if (Wgr_Data:IstMix()) or (Wgr_Data:IstArt()) then begin

    if (Art.Nummer<>aArt) then begin
      Art.Nummer # aArt;
      Erx # RecRead(250,1,0);     // Artikel holen
      if (Erx>_rLocked) then RecbufClear(250);
    end;

    if (Art.SpezGewicht=0.0) then
      Art.SpezGewicht # Wgr_Data:GetDichte(Wgr.Nummer, 250, aGuete);
    if (Art.RotativYN) and (aStk<>0) and ("Art.GewichtProm"<>0.0) then
      vL # aKg / ("Art.GewichtProm" * cnvfi(aStk)) * 1000.0;
//    if (vL=0.0) then
//      vL # Lib_Berechnungen:L_aus_StkDBLDichte2(aStk, aD,aB,aL, Art.SpezGewicht, 0.0);
    if (vL=0.0) then
      vL # "Art.Länge" * cnvfi(aStk);
  end
  else begin  // Material...
    if (Wgr.Materialtyp=c_WGRTyp_Stab) then begin
      vL # L_aus_KgStkDichteRIDRAD(aKg, aStk, Wgr_Data:GetDichte(Wgr.Nummer,0, aGuete, aArt) , 0.0, aD );
    end
    else begin
      vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(aKg, aStk, aD, aB, Wgr_Data:GetDichte(Wgr.Nummer,0, aGuete, aArt), "Wgr.TränenKgProQM");
    end;
  end;

  RETURN Rnd(vL,"Set.Stellen.Länge");
end;


//========================================================================
//  Kg_aus_StkBDichteRIDRAD
//
//========================================================================
sub Kg_aus_StkBDichteRIDRAD(
  aStk : int;
  aB : float;
  aDichte : float;
  aRID : float;
  aRAD : float;
): float;
begin
//debugx('kg_aus_StkBDickteRidRad '+aint(aStk)+'Stk '+anum(aB,2)+'b '+anum(aDichte,2)+'dichte '+anum(aRid,2)+'ID '+anum(aRad,2)+'AD');
  aB  # aB / 100.0;
  vRA # aRAD / 200.0;
  vRI # aRID / 200.0;
  vV  # Abs(((vRA*vRA) - (vRI*vRI)) * Pi * aB);
//  vKgProStk # Rnd(aDichte * vV, Set.Stellen.Gewicht);
vKgProStk # aDichte * vV;

  RETURN Rnd(vKgProStk * CnvFI(aStk) , Set.Stellen.Gewicht);
end;


/*========================================================================
2022-10-26  AH
========================================================================*/
sub Stk_aus_KgBDichteRIDRAD(
  aKG   : float;
  aB    :   float;
  aDichte : float;
  aRID  : float;
  aRAD  : float;
): float;
local begin
  vStk  : float;
end;
begin
//debugx('Stk_aus_kgBDickteRidRad '+anum(aKg,0)+'kg '+anum(aB,2)+'b '+anum(aDichte,2)+'dichte '+anum(aRid,2)+'ID '+anum(aRad,2)+'AD');
  aB  # aB / 100.0;
  vRA # aRAD / 200.0;
  vRI # aRID / 200.0;
  vV  # Abs(((vRA*vRA) - (vRI*vRI)) * Pi * aB);
//  vKgProStk # Rnd(aDichte * vV, Set.Stellen.Gewicht);
  vKgProStk # aDichte * vV;
  if (vkgProStk<>0.0) then
    vStk # aKG / vKgProStk;
  RETURN vStk;
end;


//========================================================================
//  L_aus_KgStkDichteRIDRAD
//========================================================================
sub L_aus_KgStkDichteRIDRAD(
  aKg     : float;
  aStk    : int;
  aDichte : float;
  aRID    : float;
  aRAD    : float;
): float;
begin
//debugx('L_aus_KgStkBDickteRidRad '+aint(aStk)+'Stk ,'+anum(aKg,0)+'kg, '+anum(aDichte,2)+'dichte, '+anum(aRid,2)+'ID, '+anum(aRad,2)+'AD');
  if (aStk=0) then RETURN 0.0;
  if (aDichte=0.0) then RETURN 0.0;

  vRA # aRAD / 2000.0;
  vRI # aRID / 2000.0;
  if ((vRA*vRA) - (vRI*vRI)=0.0) then RETURN 0.0;

  vV  # (aKg  / cnvfi(aStk)) / aDichte;
  vV  # (vV / pi) / ((vRA*vRA) - (vRI*vRI));

  RETURN Rnd(vV , "Set.Stellen.Länge");
end;
//  vL # (gew / dichte) / Pi / ((vRA*vRA) - (vRI*vRI));


//========================================================================
//  Kgmm_aus_DichteRIDRAD
//
//========================================================================
sub Kgmm_aus_DichteRIDRAD(
  aDichte   : float;
  aRID      : float;
  aRAD      : float;
  opt aDec  : int) : float;
begin
  if (aDec=0) then aDec # 2;
//debug('kgMM aus:'+anum(aDichte,5)+'ch  '+anum(aRID,2)+'RID  '+anum(aRad,2)+'RAD');
  vRA # aRAD / 200.0;
  vRI # aRID / 200.0;
  vV # ((vRA*vRA) - (vRI*vRI)) * Pi;
//  vKgProStk # aDichte * vV;
  RETURN Rnd(vV * aDichte / 100.0 , aDec);
end;


//========================================================================
//  RAD_aus_DichteRIDKGMM
//
//========================================================================
sub RAD_aus_DichteRIDKGMM(
  aDichte   : float;
  aRID      : float;
  aKGMM     : float) : float;
begin
//  debug('RAD aus:'+anum(aDichte,5)+'ch  '+anum(aRID,2)+'RID  '+anum(akgMM,2)+'kgmm');

  if (aDichte=0.0) then RETURN 0.0;
  vV # Rnd(aKGMM * 100.0 / aDichte, Set.Stellen.Radien);
  vRI # aRID / 200.0;

  vRA # (vV / Pi ) + (vRI*vRI);
  vRA # sqrt(vRA);
  vRA # vRA * 200.0;
  RETURN vRA;
end;


//========================================================================
//  LeapYear
//            Prüft auf Schaltjahr
//========================================================================
sub LeapYear(
aYear : int // 1900 - 2154
): int; // 1 = Schaltjahr, 0 = kein Schaltjahr
begin
  RETURN (CnvIL(((aYear % 4 = 0) and
    (aYear % 100 != 0)) or
    (aYear % 400 = 0)));
end;


//========================================================================
//  KW_aus_Datum
//
//========================================================================
sub KW_aus_Datum(
  aDate       : date;  // Ausgangsdatum
  VAR aKW     : word;  // KW nach DIN
  VAR aYear   : word;  // KW in Jahr
);
local begin
  tDay1 : date;     // 1.1. des Jahres von aDate
  tWeek : int;      // temporäre KW
  tWeekDay1 : int;  // Wochentag von tDay1
end;
begin
  aYear # DateYear(aDate) + 1900;   // Jahr von aDate
  tDay1 # DateMake(1,1,aYear);      // 1.1.
  tWeekDay1 # DateDayOfWeek(tDay1); // Wochentag (1=Mo,2=Di,...,7=So)
// Direkte Berechnung der KW:
// (Tagesdiff. zum 1.1 + Wochentag des 1.1 - 1) = relevante
// Tage
// relevante Tage / 7 = Wochenzahl
// Ist der 1.1 im Bereich Montag - Donnerstag, kommt eine
// Woche dazu
  tWeek # (CnvID(aDate) - CnvID(tDay1) + tWeekDay1 - 1) / 7 + CnvIL(tWeekDay1 < 5);
// letzte Woche des Vorjahres
  if (tWeek = 0) then begin
    dec(aYear); // Vorjahr
// wenn 1.1. ein Freitag oder (wenn Vorjahr ein
// Schaltjahr) Samstag, dann hat das Vorjahr 53 KWs
    if ((tWeekDay1 = 5) or
      (tWeekDay1 = (5 + LeapYear(aYear)))) then begin
      aKW # 53;
      RETURN;
    end;
    aKW # 52;
    RETURN;
  end;
// erste Woche des Folgejahres
// wenn 1.1. kein Donnerstag und (wenn aktuelles Jahr ein
// Schaltjahr) kein Mittwoch, dann hat das Vorjahr nur 52
// KWs, somit 1. KW im Folgejahr
  if ((tWeek = 53) and
    (tWeekDay1 != 4) and
    (tWeekDay1 != (4 - LeapYear(aYear)))) then begin
    inc(aYear); // nächstes Jahr
    aKW # 1;
    RETURN; // KW 1
  end;
  aKW # tWeek;
  RETURN;
end;


//========================================================================
//  Mo_von_KW
//
//========================================================================
Sub Mo_von_KW(
  aKW       : int;    // KW nach DIN
  aYear     : int;    // KW in Jahr
  VAR aDate : date;   // Ausgangsdatum
)
local begin
  vDay1 : int;        // 1.1. des Jahres von aDate
end;
begin
  if (aKW<=0) then aKW # 1;
  if (aYear<=2000) then aYear # 2000;
  vDay1 # cnvid(DateMake(1,1,aYear));      // 1.1.
  aDate # cnvdi( (vDay1+3) - ((vDay1+1) % 7) + 7 * (aKW - 1));
end;


//========================================================================
//  Datum_aus_ZahlJahr
//
//========================================================================
sub Datum_aus_ZahlJahr(
  aArt        : alpha;
  var aZahl   : word;
  var aJahr   : word;
  var aDatum  : date;
);
begin
  if (aZahl<>0) and (aJahr<>0) then begin
    if (aJahr<100) then aJahr # aJahr + 2000;
    if (aArt='KW') then
      Lib_Berechnungen:Mo_von_KW(aZahl,aJahr,var aDatum);
    if (aArt='DA') then begin
    end;
    if (aArt='MO') and
      (aZahl>0) and (aZahl<13) then begin
      aDatum # Datemake(1,aZahl,aJahr);
    end;
    if (aArt='QU') and
      (aZahl>0) and (aZahl<5) then begin
      aDatum # Datemake(1,(aZahl*3)-2,aJahr);
    end;
    if (aArt='SE') and
      (aZahl>0) and (aZahl<3) then begin
      aDatum # Datemake(1,(aZahl*6)-5,aJahr);
    end;
  end;
end;


//========================================================================
//  EndDatum_aus_ZahlJahr
//
//========================================================================
sub EndDatum_aus_ZahlJahr(
  aArt        : alpha;
  var aZahl   : word;
  var aJahr   : word;
  var aDatum  : date;
);
begin
  if (aZahl<>0) and (aJahr<>0) then begin
    if (aJahr<100) then aJahr # aJahr + 2000;
    if (aArt='KW') then begin
      Lib_Berechnungen:Mo_von_KW(aZahl,aJahr,var aDatum);
      aDatum->vmDayModify(6);
    end;
    if (aArt='DA') then begin
    end;
    if (aArt='MO') and
      (aZahl>0) and (aZahl<13) then begin
      if (aZahl<12) then
        aDatum # Datemake(1,aZahl+1,aJahr)
      else
        aDatum # Datemake(1,1,aJahr+1);
      aDatum->vmDayModify(-1);
    end;
    if (aArt='QU') and
      (aZahl>0) and (aZahl<5) then begin
      if (aZahl<4) then
        aDatum # Datemake(1,(aZahl*3)+1,aJahr)
      else
        aDatum # Datemake(1,1,aJahr+1);
      aDatum->vmDayModify(-1);
    end;
    if (aArt='SE') and
      (aZahl>0) and (aZahl<3) then begin
      if (aZahl=1) then
        aDatum # Datemake(1,7,aJahr)
      else
        aDatum # Datemake(1,1,aJahr+1);
      aDatum->vmDayModify(-1);
    end;
  end;
end;


//========================================================================
//  ZahlJahr_aus_Datum
//
//========================================================================
sub ZahlJahr_aus_Datum(
  aDatum    : date;
  aArt      : alpha;
  var aZahl : word;
  var aJahr : word;
);
begin
  if (aDatum<>0.0.0) then begin
    if (aArt='KW') then
      KW_aus_Datum(aDatum,var aZahl,var aJahr);
    if (aArt='DA') then begin
      aZahl # 0;
      aJahr # 0;
    end;
    if (aArt='MO') then begin
      aZahl # DateMonth(aDatum);
      aJahr # Dateyear(aDatum)+1900;
    end;
    if (aArt='QU') then begin
      case DateMonth(aDatum) of
        1,2,3 :  aZahl # 1;
        4,5,6 :  aZahl # 2;
        7,8,9 :  aZahl # 3;
        10,11,12 : aZahl # 4;
      end;
      aJahr # Dateyear(aDatum)+1900;
    end;
    if (aArt='SE') then begin
      case DateMonth(aDatum) of
        1,2,3,4,5,6     :  aZahl # 1;
        7,8,9,10,11,12  :  aZahl # 2;
      end;
      aJahr # Dateyear(aDatum)+1900;
    end;
    if (aArt='JA') then begin
      aZAhl # 0;
      aJahr # DateYear(aDatum)+1900;
    end;
  end;
end;


//========================================================================
//  Tag_aus_Datum
//
//========================================================================
sub Tag_aus_datum(aDatum : date): alpha;
begin
  case (aDatum->vpDayofWeek) of
    1 : RETURN Translate('Mo');
    2 : RETURN Translate('Di');
    3 : RETURN Translate('Mi');
    4 : RETURN Translate('Do');
    5 : RETURN Translate('Fr');
    6 : RETURN Translate('Sa');
    7 : RETURN Translate('So');
  end;
end;


//========================================================================
//  Monat_aus_Datum
//
//========================================================================
sub Monat_aus_Datum(aDatum : date): alpha;
begin
  case (aDatum->vpmonth) of
    1 : RETURN Translate('Januar');
    2 : RETURN Translate('Februar');
    3 : RETURN Translate('März');
    4 : RETURN Translate('April');
    5 : RETURN Translate('Mai');
    6 : RETURN Translate('Juni');
    7 : RETURN Translate('Juli');
    8 : RETURN Translate('August');
    9 : RETURN Translate('September');
   10 : RETURN Translate('Oktober');
   11 : RETURN Translate('November');
   12 : RETURN Translate('Dezember');
  end;
end;



//========================================================================
//  Monat_Zahl_aus_Name_DE
//
//========================================================================
sub Monat_Zahl_aus_Name_DE(aName : alpha): int;
begin
  case (StrCnv(aName,_StrUpper)) of
   'JANUAR'     : RETURN 1;
   'FEBRUAR'    : RETURN 2;
   'MÄRZ'       : RETURN 3;
   'APRIL'      : RETURN 4;
   'MAI'        : RETURN 5;
   'JUNI'       : RETURN 6;
   'JULI'       : RETURN 7;
   'AUGUST'     : RETURN 8;
   'SEPTEMBER'  : RETURN 9;
   'OKTOBER'    : RETURN 10;
   'NOVEMBER'   : RETURN 11;
   'DEZEMBER'   : RETURN 12;
  end;
end;


//========================================================================
//  TerminModify
//
//========================================================================
sub TerminModify(
  var aDat  : date;
  var aZeit : time;
  aMin      : float);
local begin
  vX  : float;
  vY  : int;
end;
begin
  if (aDat=0.0.0) or (aMin=0.0) then RETURN;

  vX # cnvfi( cnvid(aDat)-cnvid(1.1.2000) );
  vX # vX * 24.0 * 60.0;    // alles in Minuten
  vX # vX + cnvfi (cnvit(aZeit)/ 60000);

  vX # vX + aMin;

  vY # cnvif(vX) DIV (24 * 60); // ganze Tage
  aDat # cnvdi( vY + cnvid(1.1.2000));

  vY    # cnvif( vX % (24.0 * 60.0) );
  aZeit # cnvti(vY * 60000);

end;


//========================================================================
// _WerktagZwischen
//========================================================================
sub _WerktagZwischen(
  aFT     : date;
  aD1     : date;
  aD2     : date;
  ) : logic;
begin
  if (aFT->vpDayOfWeek<=5) then
    if (aD1<=aFT) and (aFT<=aD2) then begin
//debug('FEIERTAG '+cnvad(aFT));
      RETURN true;
    end;

  RETURN false;
end;


//========================================================================
//  AddWerktage
//========================================================================
sub AddWerktage(
  aDat                : date;
  aTage               : int;
  opt aOhneFeiertage  : logic;
) : date;
local begin
  vDat      : date;
  vI,vJ     : int;
  vTage     : int;
  vFT       : date;
  vTree     : int;
  vItem     : int;
end;
begin

//if (aTage<0) then aTage # -aTage;

  if (aDat=0.0.0) then RETURN 0.0.0;
  if (aTage=0) then RETURN aDat;

  vDat  # aDat;
  vTage # aTage;

  if (vTage<0) then begin // MINUS
    vTage # -aTage;
    vI # vTage / 5;       // volle Wochen
    vDat->vmdaymodify(vI * -7);
    vTage # vTage % 5;
    if (vDat->vpDayOfWeek=7) then vDat->vmDayModify(1);       // Sonntag auf Montag
    if (vDat->vpDayOfWeek=6) then vDat->vmDayModify(2);       // Samstag auf Montag
    if (vTage>=vDat->vpDayOfWeek) then vDat->vmDayModify(-2); // Wochenende einschieben
    vDat->vmdaymodify(-vTage);
  end
  else begin              // PLUS
    vI # vTage / 5;       // volle Wochen
    vDat->vmdaymodify(vI * 7);
    vTage # vTage % 5;
    if (vDat->vpDayOfWeek=7) then vDat->vmDayModify(-2);      // Sonntag auf Freitag
    if (vDat->vpDayOfWeek=6) then vDat->vmDayModify(-1);      // Samstag auf Freitag
    if (vDat->vpDayOfWeek+vTage>5) then vDat->vmDayModify(2); // Wochenende einschieben
    vDat->vmdaymodify(vTage);
  end;


  if (aOhneFeiertage=false) then begin
    // Alle Feiertage chronologisch sortieren!
    vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
    FOR vJ # aDat->vpYear
    LOOP inc(vJ)
    WHILE (vJ<=vDat->vpYear) do begin
      // Silvester
      vFT # DateMake(1,1,vJ);
      vTree->CteInsertItem(aint(cnvid(vFT)),1,cnvad(vFT));
      // Karfreitag
      vFT->vmEasterDate(vJ);
      vFT->vmDayModify(-2);
      vTree->CteInsertItem(aint(cnvid(vFT)),2,cnvad(vFT));
      // Ostermontag
      vFT->vmEasterDate(vJ);
      vFT->vmDayModify(1);
      vTree->CteInsertItem(aint(cnvid(vFT)),3,cnvad(vFT));
      // 1.Mai
      vFT # DateMake(1,5,vJ);
      vTree->CteInsertItem(aint(cnvid(vFT)),4,cnvad(vFT));
      // Christi Himmelfahrt
      vFT->vmEasterDate(vJ);
      vFT->vmDayModify(39);
      vTree->CteInsertItem(aint(cnvid(vFT)),5,cnvad(vFT));
      // Pfingstmontag
      vFT->vmEasterDate(vJ);
      vFT->vmDayModify(50);
      vTree->CteInsertItem(aint(cnvid(vFT)),6,cnvad(vFT));
      // Tag der deutschen Einheit
      vFT # DateMake(3,10,vJ);
      vTree->CteInsertItem(aint(cnvid(vFT)),7,cnvad(vFT));
      // Weihnachten
//        vFT # DateMake(24,12,vJ);
//        vTree->CteInsertItem(cnvad(vFT),8,'');
      vFT # DateMake(25,12,vJ);
      vTree->CteInsertItem(aint(cnvid(vFT)),9,cnvad(vFT));
      vFT # DateMake(26,12,vJ);
      vTree->CteInsertItem(aint(cnvid(vFT)),10,cnvad(vFT));
    END;

    if (aTage>0) then begin       // Vorwärts?
      FOR vItem # vTree->CteRead(_CteFirst)
      LOOP vItem # vTree->CteRead(_CteNext, vItem)
      WHILE (vItem<>0) do begin
        vFT # cnvda(vItem->spCustom);
        if (_WerktagZwischen(vFT, aDat, vDat)) then vDat # AddWerktage(vDat, 1, true);
      END;
    end
    else begin                    // Rückwärts
      FOR vItem # vTree->CteRead(_CteLast)
      LOOP vItem # vTree->CteRead(_CtePrev, vItem)
      WHILE (vItem<>0) do begin
        vFT # cnvda(vItem->spCustom);
        if (_WerktagZwischen(vFT, vDat, aDat)) then vDat # AddWerktage(vDat, -1, true);
      END;
    end;
    Sort_KillList(vTree);           // Löschen des RAM-Baumes

//debug(cnvad(aDat)+' '+aint(aTage)+' = '+cnvad(vDat)+'           volle Wochen:'+aint(vI));
  end;

  RETURN vDat;

end;


//========================================================================
//  Waehrung_Umrechnen
//
//========================================================================
sub Waehrung_Umrechnen(
  aWert1 : float;
  aWae1 : int;
  var aWert2 : float;
  aWae2 : int;
) : logic;
local begin
  Erx : int;
end;
begin

  // FW->Hauswährung (bzw. 1.Teil FW->FW)
  if (aWae2=1) or ((aWae1<>1) and (aWae2<>1)) then begin
    Wae.Nummer # aWae1;
    Erx # RecRead(814,1,0);
    if (Erx>_rlocked) then begin
      if (TransActive) then TRANSBRK;
      Msg(814000,AInt(aWae1),0,0,0);
      RETURN false;
    end;
    if (Wae.VK.Kurs=0.0) then begin
      if (TransActive) then TRANSBRK;
      Msg(814001,AInt(aWae1),0,0,0);
      RETURN false;
    end;
    aWert2 # aWert1 / Wae.VK.Kurs;

    if (aWae2=1) then RETURN true;  // FW->HW? Dann fertig

    aWert1 # aWert2;  // für FW->FW
    aWae1  # 1;
  end;

  // Hauswährung -> FW (bzw. 2.Teil: FW->FW)
  Wae.Nummer # aWae2;
  Erx # RecRead(814,1,0);
  if (Erx>_rlocked) then begin
    if (TransActive) then TRANSBRK;
    Msg(814000,AInt(aWae2),0,0,0);
    RETURN false;
  end;
  if (Wae.EK.Kurs=0.0) then begin
    if (TransActive) then TRANSBRK;
    Msg(814001,AInt(aWae2),0,0,0);
    RETURN false;
  end;
  aWert2 # aWert1 * Wae.VK.Kurs;

  RETURN true;

end;

//========================================================================
//  ToleranzZuWerten
//
//========================================================================
sub ToleranzZuWerten(
  aText : alpha;
  var aVon : float;
  var aBis : float;
)
local begin
  vA    : alpha;
  vX,vY : float;
end;
begin
  // 15.03.2017 AH. Bei "#" nichts machen!
  if (StrCut(aText,1,1)='#') then begin
    aVon # 0.0;
    aBis # 0.0;
    RETURN;
  end;
  vA # Str_Token(aText,'/',1);
  vX # CnvFA(vA);
  vA # Str_Token(aText,'/',2);
  vY # CnvFA(vA);
  aVon # min(vX,vY);      // 28.02.2020 AH WAR VERDREHT !!!!
  aBis # Max(vX,vY);
end;


//========================================================================
//  Toleranzkorrektur
//
//========================================================================
sub Toleranzkorrektur(
  aText     : alpha;
  aStellen  : int;
) : alpha;
local begin
  vA    : alpha;
  vB    : alpha;
  vX    : int;
  vF1   : float;
  vF2   : float;
  vRes  : alpha;
  vDone : logic;
end;
begin
  
  // 19.11.2018 AH
  if (RunAFX('Toleranzkorrektur',aText+'|'+aint(aStellen))<>0) then begin
    RETURN StrCut(GV.Alpha.99,1,16);
  end;

  if ( aText = '' ) then
    RETURN '';

  FOR  vX # 1;
  LOOP vX # vX + 1;
  WHILE ( vX < StrLen( aText ) ) DO BEGIN
    vA # StrCut( aText, vX, 1 );
    if ( vA = '#' ) or ( vA = '_' ) or
        ( ( vA >= 'a' ) and ( vA <= 'z' ) ) or
        ( ( vA >= 'A' ) and ( vA <= 'Z' ) ) then
      RETURN StrCut(aText,1,16);
  END;


  // +/-<Zahl> || -/+<Zahl> (->  +<Zahl>/-<Zahl>)
  if ( !vDone ) and ( StrLen( aText ) > 3 ) then begin
    vA # StrAdj( aText, _strAll );
    vA # StrCut( vA, 1, 3 );
    if ( vA = '+/-' ) or ( vA = '-/+' ) then begin
      vF1   # abs( CnvFA( aText ) );
      vF2   # -vF1;
      vDone # true;
    end;
  end;


  // <Zahl1>/<Zahl2>
  if ( !vDone ) then begin
    vX # StrFind( aText, '/', 0 );
    if ( vX > 1 ) then begin
      vF1   # CnvFA( StrCut( aText, 1, vX - 1 ) );
      vF2   # CnvFA( StrCut( aText, vX + 1, StrLen( aText ) ) );
      vDone # true;
    end;
  end;

  // +<Zahl1>-<Zahl2> || -<Zahl1>+<Zahl2>
  if ( !vDone ) then begin
    vA # StrCut( aText, 1, 1 );
    if ( vA = '+' ) then
      vX # StrFind( aText, '-', 1 );
    else if ( vA = '-' ) then
      vX # StrFind( aText, '+', 1 );
    else
      vX # 0;
    if ( vX > 2 ) then begin // >2: +- bzw -+ ignorieren
      vF1   # CnvFA( StrCut( aText, 1, vX - 1 ) );
      vF2   # CnvFA( StrCut( aText, vX, StrLen( aText ) ) );
      vDone # true;
    end;
  end;


  // Reperaturversuch
  if ( !vDone ) then begin
    // +-/-+ Kombinationen herausschneiden
    if ( aText =* '*+-*' or aText =* '*-+' or aText =* '+-*' or aText =* '-+*' ) then begin
      FOR  vX # StrFind( aText, '+-', 0 );
      LOOP vX # StrFind( aText, '+-', 0 );
      WHILE ( vX > 0 ) DO BEGIN
        aText # StrDel( aText, vX, 2 );
      END;

      FOR  vX # StrFind( aText, '-+', 0 );
      LOOP vX # StrFind( aText, '-+', 0 );
      WHILE ( vX > 0 ) DO BEGIN
        aText # StrDel( aText, vX, 2 );
      END;

      vF1 # CnvFA( aText );
      vF2 # CnvFA( '-' + aText );
    end
    else begin
      vF1 # CnvFA( aText );
      vF2 # 0.0;
    end;
  end;


  // keine Trenner / aber ein MINUS??
  if ( !vDone ) then begin
    if (StrFind( aText, '/', 0 )=0) then begin
      if (StrFind( aText, '-', 2 )>0) then RETURN StrCut('#'+aText,1,16);
    end;
  end;


  // Ausgabe generieren
  vA # StrAdj( ANum( vF1, aStellen ), _strAll );
  vB # StrAdj( ANum( vF2, aStellen ), _strAll );

  if ( vF1 <= 0.0 ) and ( vF2 >= 0.0 ) then begin
    if ( vF1 = 0.0 ) then
      vRes # '+' + vB + '/-' + vA;
    else
      vRes # '+' + vB + '/'  + vA;
  end
  else if ( vF1 >= 0.0 ) and ( vF2 <= 0.0 ) then begin
    if ( vF2 = 0.0 ) then
      vRes # '+' + vA + '/-' + vB;
    else
      vRes # '+' + vA + '/'  + vB;
  end
  else
    vRes # aText;

  // 20.02.2020 AH: -/- oder +/+ ???
  if ((vF1<0.0) and (vF2<0.0)) or
    ((vF1>0.0) and (vF2>0.0)) then vRes # '';
    

  RETURN StrCut(vRes,1,16);
end;


//========================================================================
//  KurzDatum_aus_datum
//
//========================================================================
sub KurzDatum_aus_Datum(aDat : date) : alpha
local begin
  vD  : int;
  vM  : int;
  vY  : int;
end;
begin
  if (aDat=0.0.0) then RETURN '';

  vD # DateDay(aDat);
  vM # datemonth(aDat);
  vY # dateyear(aDat);
  WHILE (vY>=100) do
    vY # vY - 100;
  WHILE (vY<0) do
    vY # vY + 100;

  RETURN cnvai(vD,_FmtNumLeadZero,0,2)+'.'+cnvai(vM,_FmtNumLeadZero,0,2)+'.'+cnvai(vY,_FmtNumLeadZero,0,2);
end;


//========================================================================
//  Stk_aus_KgDBLWgrArt
//
//========================================================================
sub Stk_aus_KgDBLWgrArt(
  akg     : float;
  aD      : float;
  aB      : float;
  aL      : float;
  aWgr    : int;
  aGuete  : alpha;
  aArt    : alpha;
): int;
local begin
  Erx   : int;
  vX    : float;
  vStk  : int;
end;
begin

  Wgr.Nummer # aWgr;
  Erx # Recread(819,1,0);       // Warengruppe holen
  if (Erx>_rlocked) then RecBufClear(819);

  // Artikelberechnung...
  if (Wgr_Data:IstMix()) or (Wgr_Data:IstArt()) then begin

    Art.Nummer # aArt;
    Erx # RecRead(250,1,0);     // Artikel holen
    if (Erx>_rLocked) then RecbufClear(250);

    if (Art.SpezGewicht=0.0) then
      Art.SpezGewicht # Wgr_Data:GetDichte(Wgr.Nummer,250);
    if (Art.RotativYN) and (aL<>0.0) and ("Art.GewichtProm"<>0.0) then
      vStk # cnvif(aKG / "Art.GewichtProm" / aL * 1000.0);
    if (vStk=0) then
      vStk # Stk_aus_kgDBLDichte2(aKG, aD, aB, aL, Art.SpezGewicht, 0.0);
    if (vStk=0) and ("Art.GewichtProStk"<>0.0) then
      vStk # cnvif(aKG / "Art.GewichtProStk");

  end
  else begin  // Material...

    if (Wgr.Materialtyp=c_WGRTyp_Stab) then begin
      vX # Kg_aus_StkBDichteRIDRAD(1, aL, Wgr_Data:GetDichte(Wgr.Nummer,0, aGuete, aArt), 0.0, aD );
      if (vX<>0.0) then begin
        vStk # cnvif(aKG div vX);
        if (cnvfi(vStk) * vX < aKG) then vStk # vStk + 1;
      end;
    end
    else begin
      vStk # Stk_aus_kgDBLDichte2(aKG, aD, aB, aL, Wgr_Data:GetDichte(Wgr.Nummer,0, aGuete, aArt) , "Wgr.TränenKgProQM");
    end;

  end;

  RETURN vStk;
end;


//========================================================================
//  KG_aus_StkDBLWgrArt
//
//========================================================================
sub KG_aus_StkDBLWgrArt(
  aStk    : int;
  aD      : float;
  aB      : float;
  aL      : float;
  aWgr    : int;
  aGuete  : alpha;    // 08.07.2021 AH
  aArt    : alpha;
): float;
local begin
  Erx   : int;
  vGew  : float;
end;
begin

//debug('KG aus:'+cnvaI(aStk)+'Stk, '+cnvaf(aD)+'x'+cnvaf(aB)+'x'+cnvaf(aL)+'  '+cnvai(aWgr)+'Wgr');

  if (Wgr.Nummer<>aWgr) then begin
    Wgr.Nummer # aWgr;
    Erx # Recread(819,1,0);       // Warengruppe holen
    if (Erx>_rlocked) then RecBufClear(819);
  end;

  // Artikelberechnung...
  if (Wgr_Data:IstMix()) or (Wgr_Data:IstArt()) then begin

    Art.Nummer # aArt;
    Erx # RecRead(250,1,0);     // Artikel holen
    if (Erx>_rLocked) then RecbufClear(250);

    if (Art.SpezGewicht=0.0) then
      Art.SpezGewicht # Wgr_Data:GetDichte(Wgr.Nummer,250);
    if (Art.RotativYN) and (aL<>0.0) and ("Art.GewichtProm"<>0.0) and (aStk<>0) then
      vGew # "Art.GewichtProm" * aL * cnvfi(aStk) / 1000.0;
    if (vGew=0.0) then
      vGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(aStk, aD,aB,aL, Art.SpezGewicht, 0.0);
    if (vGew=0.0) then
      vGew # "Art.GewichtProStk" * cnvfi(aStk);
  end
  else begin  // Material...

    if (Wgr.Materialtyp=c_WGRTyp_Stab) then begin
      vGew # Kg_aus_StkBDichteRIDRAD(aStk, aL, Wgr_Data:GetDichte(Wgr.Nummer,0,aGuete, aArt), 0.0, aD );
    end
    else begin
      vGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(aStk, aD, aB, aL, Wgr_Data:GetDichte(Wgr.Nummer,0,aGuete,aArt), "Wgr.TränenKgProQM");
    end;

  end;

  RETURN vGew;
end;

//========================================================================

//========================================================================
//  AuflaufH_aus_RIDRAD
//
//========================================================================
sub AuflaufH_aus_RIDRAD(
  aRID      : float;
  aRAD      : float)  : float;

  local begin
    vAH : float;
  end;

begin

  vAH # (aRAD - aRID) /2.0;

  RETURN Rnd(vAH , 2);
end;


//========================================================================
//  RAD_aus_KgStkBDichteRIDTlg
//
//========================================================================
sub RAD_aus_KgStkBDichteRIDTlg(
  akg     : float;
  aStk    : int;
  aB      : float;
  aDichte : float;
  aRID    : float;
  aTlg    : int;
): float;
begin
//debug('RAD aus:'+anum(aKg,0)+'kg  '+aint(astk)+'Stk  '+anum(aB,2)+'B  '+anum(aDichte,5)+'ch  '+anum(aRid,2)+'RID  '+aint(aTlg)+'T');
  aB # aB / 100.0;
  vRI # aRid / 200.0;

  if (aStk<>0) then
    vKgProStk # aKg / CnvFI(aStk)
  else
    vKgProStk # aKg;

  vKgProStk # vKgProStk / CnvFI(aTlg +1);

  if (aDichte<>0.0) then
    vV # Abs(vKgProStk / aDichte);

  if (aB<>0.0) then
//    RETURN Sqrt( (vV/(pi*aB)) + (vRI*vRI) ) * 200.0
    RETURN (Rnd( Sqrt( (vV/(pi * aB)) + (vRI*vRI) ) * 200.0, Set.Stellen.Radien))
  else
    RETURN 0.0;

end;


//========================================================================
//  kg_aus_StkDAdDichte2
//      für Ronden
//========================================================================
sub kg_aus_StkDAdDichte2(
  aStk    : int;
  aD      : float;
  aAD     : float;
  aDichte : float;
  aTraene : float;
 ): float;
local begin
  vX : float;
  vF : float;
end;
begin

//debug('Gew aus:'+cnvaI(aStk)+'Stk, '+cnvaf(aD)+'x'+cnvaf(aAD)+'  '+cnvaf(aDichte)+'g/cm³');
  aD # aD / 100.0;
  aAD # aAD / 200.0;  // AD wird Radion
  //vV  # ((vRA*vRA) - (vRI*vRI)) * Pi * aB;
  vF  # (aAD*aAD) * Pi;
  vX # (aD * vF * aDichte);
  if ("Set.Stellen.Stk<>KG"=99) then
    vX # vX + (vF /100.0 * aTraene)
  else
    vX # Rnd(vX + (vF /100.0 * aTraene), "Set.Stellen.Stk<>KG");

  vX # Rnd(vX * CnvFI(aStk), Set.Stellen.Gewicht);
//debug(cnvai(aStk)+' '+cnvaf(aD)+' '+cnvaf(aB)+' '+cnvaf(aL)+' '+cnvaf(aDichte)+' '+cnvaf(atraene)+' = '+cnvaf(vX));

  RETURN vX;
end;


/*========================================================================
========================================================================*/
sub Stk_aus_KgDAdDichte2(
  aGew    : Float;
  aD      : float;
  aAD     : float;
  aDichte : float;
  aTraene : float;
 ): float;
local begin
  vX    : float;
  vF    : float;
  vStk  : float;
end;
begin
  aD # aD / 100.0;
  aAD # aAD / 200.0;  // AD wird Radion
  vF  # (aAD*aAD) * Pi;
  vX # (aD * vF * aDichte);
  if ("Set.Stellen.Stk<>KG"=99) then
    vX # vX + (vF /100.0 * aTraene)
  else
    vX # Rnd(vX + (vF /100.0 * aTraene), "Set.Stellen.Stk<>KG");

  if (vX<>0.0) then
    vStk # aGew / vX;
  
  RETURN vStk;
end;


//========================================================================
//  A_aus_StkAd
//      für Ronden
//========================================================================
sub A_aus_StkAd(
  aStk    : int;
  aAD     : float;
 ): float;
local begin
  vF : float;
end;
begin
  aAD # aAD / 200.0;  // AD wird Radion
  vF  # (aAD*aAD) * Pi;
  vF # Rnd(vF * CnvFI(aStk) / 100.0, Set.Stellen.Menge);
  RETURN vF;
end;


//========================================================================
// 2022-06-21 AH
//========================================================================
sub Quadrat_in_Ronde(
  aAD : float;
) : float;
local begin
  vX  : float;
end;
begin
  vX # aAD / 2.0;       // Radius
  vX # vX * vX;         // Quadart
  vX # Sqrt(vX * 2.0);
  RETURN Rnd(vX, Set.Stellen.Breite);
end;


//========================================================================
//  Dreisatz
//
//========================================================================
SUB Dreisatz(
  aGes    : float;
  aBasis  : float;
  aTeil   : float) : float;
begin
  if (aBasis=0.0) then RETURN 0.0;
  RETURN aGes / aBasis * aTeil;
end;


//========================================================================
//  DatTimToBig
//
//========================================================================
sub DatTimToBig(
  aDat  : date;
  aTim  : Time) : BigInt;
local begin
  vI      : bigint;
end;
begin
  if (aDat>1.1.1900) then
    vI # cnvbi(cnvid(aDat));
  vI # (vI * 24\b * 60\b * 60\b) + (cnvbi(cnvit(aTim) / 1000));
  //RETURN cnvab(vI,_FmtNumNoGroup);
  RETURN vI;
end;

/**
//========================================================================
//========================================================================
sub BigToDatTim(
  aA        : alpha;
  var aDat  : date;
  var aTim  : Time);
local begin
  vI        : bigint;
end;
begin
  vI # cnvba(vA);
  vI #
  caltime
  if (aDat>1.1.1900) then
    vI # cnvbi(cnvid(aDat));
  vI # (vI * 24\b * 60\b * 60\b) + (cnvbi(cnvit(aTim) / 1000));
  RETURN cnvab(vI,_FmtNumNoGroup);
end;
***/


//========================================================================
//========================================================================
SUB LetzterTagImMonat(aMonat : int; aJahr : int) : date
local begin
  vDat  : date;
end;
begin
  vDat # DateMake(1,aMonat,aJahr);
  vDat->vmMonthModify(1);
  vDat->vmDayModify(-1);
  RETURN vDat;
end;


//========================================================================
//  BytesToAlpha
//========================================================================
SUB BytesToAlpha(aBytes : int) : alpha
begin
  if (aBytes<1024) then RETURN cnvai(aBytes)+' Bytes';
  if (aBytes<1024*1024) then RETURN cnvai(aBytes div 1024)+' KB';
  if (aBytes<1024*1024*1024) then RETURN cnvai(aBytes div 1024*1024)+' MB';

  RETURN aint(aBytes div 1024*1024*1024)+' GB';
end;


//========================================================================
// IntsAusAlpha
//========================================================================
sub IntsAusAlpha(
  aText     : alpha;
  var aI    : int;
  var aW1   : word;
  var aW2   : word) : logic;
local begin
  vA        : alpha;
end;
begin
  if (aText='') then RETURN false;

  // 1. Token
  try begin
    ErrTryCatch(_ErrCnv,y);
    ErrTryCatch(_ErrValueOverflow,y);
    if (Lib_strings:Strings_Count(aText, '/')=0) then vA # aText
    else vA # Str_Token(aText, '/',1);
    aI  # Cnvia(vA);
  end;
  if (ErrGet() != _ErrOk) then RETURN false;

  // 2. Token
  if (Lib_strings:Strings_Count(aText, '/')>0) then begin
    try begin
      ErrTryCatch(_ErrCnv,y);
    ErrTryCatch(_ErrValueOverflow,y);
      vA # Str_Token(aText, '/',2);
      aW1 # Cnvia(vA);
    end;
    if (ErrGet() != _ErrOk) then RETURN false;
  end;

  // 3. Token
  if (Lib_strings:Strings_Count(aText, '/')>1) then begin
    try begin
      ErrTryCatch(_ErrCnv,y);
    ErrTryCatch(_ErrValueOverflow,y);
      vA # Str_Token(aText, '/',3);
      aW2 # Cnvia(vA);
    end;
    if (ErrGet() != _ErrOk) then RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// Int1AusAlpha
//========================================================================
sub Int1AusAlpha(
  aText     : alpha;
  var aI    : int) : logic;
local begin
  vW1, vW2  : word;
end;
begin
  RETURN IntsAusAlpha(aText, var aI, var vW1, var vW2);
end;


//========================================================================
// Int2AusAlpha
//========================================================================
sub Int2AusAlpha(
  aText     : alpha;
  var aI    : int;
  var aW    : word) : logic;
local begin
  vW2       : word;
end;
begin
  RETURN IntsAusAlpha(aText, var aI, var aW, var vW2);
end;


/*========================================================================
2022-11-28  AH
========================================================================*/
sub FloatAusAlpha(
  aText     : alpha;
  var aF    : float) : logic;
local begin
end;
begin
  if (aText='') then RETURN false;

  try begin
    ErrTryCatch(_ErrCnv,y);
    ErrTryCatch(_ErrValueOverflow,y);
    aF  # Cnvfa(aText);
  end;
  if (ErrGet() != _ErrOk) then RETURN false;

  RETURN true;
end;


//========================================================================
//  MinutenZwischen
//========================================================================
SUB MinutenZwischen(
  aStartDat : date;
  aStartTim : time;
  aEndeDat  : date;
  aEndeTim  : time) : int
local begin
  vStd    : int;
  vDauer  : int;
end;
begin
  if (aStartDat=0.0.0) or (aEndeDat=0.0.0) then RETURN 0;
  vStd    # (CnvID(aStartDat) - cnvID(1.1.2000)) * 24 * 60;
  vStd    # vStd + (Cnvit(aStartTim) / 1000 / 60);
  vDauer  # vStd;

  vStd # (CnvID(aEndeDat) - cnvid(1.1.2000)) * 24 * 60;
  vStd # vStd + (Cnvit(aEndeTim) / 1000 / 60);
  RETURN vStd - vDauer;
end;


//========================================================================
// CaltimeCompare   : '', '=', '>' oder '<'
//========================================================================
SUB CaltimeCompare(
  aDat1   : date;
  aTim1   : time;
  aDat2   : date;
  aTim2   : time) : alpha
local begin
  vCT1      : caltime;
  vCT2      : caltime;
end;
begin
  if (aDat1=0.0.0) or (aDat2=0.0.0) then RETURN '';
  vCT1->vpDate # aDat1;
  vCT1->vpTime # aTim1;
  vCT2->vpDate # aDat2;
  vCT2->vpTime # aTim2;

  if (vCT1=vCT2) then RETURN '=';
  if (vCT1>vCT2) then RETURN '>'
  else RETURN '<';

end;


//========================================================================
MAIN
begin
  WindialogBox(0,'Unittest', cnvaf(Quadrat_In_Ronde(50.0)), 0,_WinDialogAlwaysOnTop,0);
end;

//========================================================================
