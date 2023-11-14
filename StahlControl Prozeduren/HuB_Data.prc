@A+
//==== Business-Control ==================================================
//
//  Prozedur    HuB_Data
//                    OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  06.02.2017  ST  "FindePreis(...)" Lieferantenartikelnr hinzugeüfgt
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB FindePreis(aArtNr : alpha; aLieferant : int; aWae : word; varaPEH : int; varaPreis : float) : logic;
//    SUB MengenBewegung(aArtNr : alpha; aMenge : float; aGrund : alpha; optaEKPreis : float; optaSeriennr : alpha) : logic
//========================================================================
@I:Def_Global

define begin
  cTitle :    'Hilfs- und Betriebsstoffe'
end;

//========================================================================
// FindePreis
//                ArtNr, Lieferant, Währung, var PEH, var Preis
//========================================================================
sub FindePreis(
  aArtNr      : alpha;
  aLieferant  : int;
  aWae        : word;
  var aPEH    : int;
  var aPreis  : float;
  var aLfArtNr  : alpha;
) : logic;
local begin
  Erx : int;
end;
begin
  HuB.Artikelnr # aArtNr;       // HuB-Artikel lesen
  Erx # RecRead(180,1,_RecLock);
  if (Erx>_rLocked) then RETURN false;
  Erx # RecLink(181,180,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (HuB.P.Lieferant=aLieferant) and
      ("HuB.P.Währung"=aWae) then begin
      aPEH     # HuB.P.PEH;
      aPreis   # HuB.P.Preis;
      aLfARtNr # HuB.P.LieferArtNr;
      RETURN true;
    end;
    Erx # RecLink(181,180,1,_RecNext);
  END;

  RETURN false;
end;


//========================================================================
// MengenBewegung
//                ArtNr, Menge, Grund, (EKPreis), (Serienenr)
//========================================================================
sub MengenBewegung(
  aArtNr : alpha;
  aMenge : float;
  aGrund : alpha;
  opt aEKPreis : float;         // ggf. EK-Preis bei Einkäufe
  opt aSeriennr : alpha;
): logic
local begin
  Erx         : int;
  vLagerwert  : float;
end;
begin
  RecBufClear(182);

  HuB.Artikelnr # aArtNr;       // HuB-Artikel lesen&sperren
  Erx # RecRead(180,1,_RecLock);
  if (Erx=_rLocked) then begin
      if (Transactive) then TRANSBRK;
      Msg(182001,aArtNr,0,0,0);
      RETURN False;
  end;
  if (Erx<>_rOk) then begin
      if (Transactive) then TRANSBRK;
      Msg(182000,aArtNr,0,0,0);
      RETURN False;
  end;

  HuB.J.Artikelnr # HuB.Artikelnr;
  HuB.J.Menge.Vorher # HuB.Menge.Ist;
  if (aEKPreis<>0.0) then begin // Preise ggf. berechnen
    vLagerwert # 0.0;
    if ((CnvFI(HuB.PEH) * HuB.Menge.Ist)<>0.0) then
      vLagerwert # (HuB.durchschEKPreis / CnvFI(HuB.PEH) * HuB.Menge.Ist);
    vLagerwert # vLagerwert + (aEKPreis * aMenge);

    if (((HuB.Menge.Ist+aMenge) * CnvFI(HuB.PEH))<>0.0) then
      HuB.durchschEKPreis # vLagerwert / (HuB.Menge.Ist+aMenge) * CnvFI(HuB.PEH);
    HuB.letzterEKPreis # aEKPreis * CnvFI(HuB.PEH);
  end;

  HuB.Menge.Ist # HuB.Menge.Ist + aMenge; // Bestand erhöhen

  RekReplace(180,_recUnlock,'AUTO');


  HuB.J.Seriennr # aSeriennr;
  HuB.J.Menge.Diff # aMenge;
  HuB.J.Bemerkung # StrFmt(aGrund,32,_StrEnd);
  HuB.J.User # gUsername;
  REPEAT
    HuB.J.Datum # sysDate();
    HuB.J.Zeit # Now;
    Erx # RekInsert(182,0,'AUTO');
  UNTIL (Erx=_rOK);

  RETURN true;
end;

//========================================================================