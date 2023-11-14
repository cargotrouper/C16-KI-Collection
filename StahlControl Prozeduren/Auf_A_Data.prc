@A+
//===== Business-Control =================================================
//
//  Prozedur    Auf_A_Data
//                    OHNE E_R_G
//  Info
//
//
//  05.02.2004  AI  Erstellung der Prozedur
//  05.01.2012  AI  SetSperre änderung
//  14.08.2012  ST  Ankerfunktion bei NeuAnlegen hinzugefügt
//  30.08.2012  ST  _RecCalc, Abfrage auf Artikelnr & Mat Nr für SL (1326/287)
//  03.02.2014  AH  "_AddAktion" versucht bei aPreis=true auf Preis.MEH zu kommen
//  06.05.2014  AH  "_AddAkton" unterscheidet Bturro- und Netto-Gewichte
//  15.05.2014  AH  "_AddAktion" nimmt für Preis auch Auf.P.MEH.Preis
//  31.07.2014  ST  Prüfung auf Abschlussdatum bei "Storno" & "Neulegen" hinzugefügt Projekt 1326/395
//  14.08.2014  AH  Remove von 31.07.2014
//  19.08.2014  AH  Bug: "_reCalc" addiert auch c_Akt_BA_Plan_Fahr Mengen auf
//  12.01.2015  AH  Bug:" Recalcall" hat ÜberDFKATS im Artikel negativ eingerecehnet
//  04.02.2015  ST  "MatVsbReset()" hinzugefügt Projekt 1507/54
//  10.04.2015  AH  Recalc in SL braucht keine Artikelnummer
//  04.09.2015  AH  VSB-Aktionen können manuell storniert werden
//  17.09.2015  ST  BugFix TRANSBRK in 992
//  22.10.2015  AH  RLFS
//  11.11.2015  AH  Buffix "Recalcall": Artikel-VLDAWS/LFS hatten OffeneAuf-Menge im Artikel falsch gesetzt (Storno auch)
//  20.10.2016  AH  VSBEK
//  08.11.2016  AH  PAbruf
//  10.04.2019  AH  AFX "Auf.A.RecalcAll"
//  26.04.2019  AH  "Recalcall" prüft bei BA_Sollmengen noch mal, ob BA-Position noch aktiv ist
//  23.05.2019  AH  Fix für "Recalcall" zum Buffern der 702
//  16.07.2019  AH  "BessererLFA", der nur Restmengen anzeigt und ba BA-Ketten sich nicht addiert
//  05.06.2020  AH  AFX "Auf.A.Entfernen.Post", "Auf.A.NeuAnlegen.Post"
//  27.07.2021  AH  ERX
//  03.05.2022  AH  BA-Aktionen werden bei Lohn als "Eingeplant" gerechnet
//  11.05.2022  AH  Fix doppelter Lohnmengen
//  19.05.2022  AH  Fix für Abrufmengenedit (HOW)
//  30.05.2022  AH  SINGLELOCK
//  13.06.2022  AH  Neu: "Set.BA.LohnVBwieVK"
//  2022-07-05  AH  DEADLOCK
//
//  Subprozeduren
//    SUB _AddAktion(var aMenge  : float; var aStk    : int; var aGew    : float; opt aPreis  : logic);
//    SUB _Recalc() : logic
//    SUB RecalcAll() : logic
//    SUB NeuAmKopfAnlegen(opt akeineAutoNr  : logic) : logic;
//    SUB NeuAnlegen(opt akeineAutoNr : logic; optaSL : logic) : logic;
//    SUB Entfernen(opt aNurStern : logic) : logic;
//    SUB LiesAktion(aAufNr : int; aPosNr : int; aPosNr2 : int; aTyp : alpha; aAktNr : int; aAktPos1 : int; aAktPos2 : int; opt aBem : alpha; opt aDel : logic) : logic;
//    SUB ToggleLoeschmarker(aManuell : logic) : logic;
//    SUB Storno(opt aSilent : logic) : logic;
//    SUB SetSperre(aPos : int; aGrund  : alpha; aAktiv  : logic; aNurSet : logic) : int
//    SUB SperreUmsetzen() : logic
//    SUB MatVsbReset() : logic
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG
@I:Def_Rights

@define NurPlus
@define defBessererLFA
//@undef NurPlus

declare LiesAktion(aAufNr : int; aPosNr : int; aPosNr2 : int; aTyp : alpha; aAktNr : int; aAktPos1 : int; aAktPos2 : int; opt aBem : alpha; opt aDel : logic) : logic;


//========================================================================
// _AddAktion
//
//========================================================================
sub _AddAktion(
  var aMenge  : float;
  var aStk    : int;
  var aGew    : float;
  opt aPreis  : logic);
local begin
  vGew  : float;
end
begin
  vGew # Auf.A.Gewicht;
  if (VwA.NettoYN) then vGew # Auf.A.Nettogewicht;

  aStk # aStk + "Auf.A.Stückzahl";
  aGew # aGew + vGew;

  if (aPreis) then begin

    if (Auf.A.Menge.Preis<>0.0) then begin
      aMenge # aMenge + Auf.A.Menge.Preis;
    end
    else if (Auf.P.MEH.Preis='Stk') then begin
      aMenge # aMenge + cnvfi("Auf.A.Stückzahl");
    end
    else if (Auf.P.MEH.Preis='kg') then begin
      aMenge # aMenge + vGew;
    end
    else if (Auf.P.MEH.Preis='t') then begin
      aMenge # aMenge + vGew / 1000.0;
    end
    else if (Auf.P.MEH.Preis = Auf.A.MEH) then begin
      aMenge # aMenge + Auf.A.Menge;
    end;

/*** 15.05.2014
    if (Auf.P.MEH.Einsatz = Auf.A.MEH.Preis) then
      aMenge # aMenge + Auf.A.Menge.Preis
    else if (Auf.P.MEH.Einsatz='Stk') then
      aMenge # aMenge + cnvfi("Auf.A.Stückzahl");
    else if (Auf.P.MEH.Einsatz='kg') then
      aMenge # aMenge + vGew
    else if (Auf.P.MEH.Einsatz='t') then
      aMenge # aMenge + vGew / 1000.0;
    else if (Auf.P.MEH.Einsatz = Auf.A.MEH) then
      aMenge # aMenge + Auf.A.Menge;
***/
/***
    if (Auf.P.MEH.Preis = Auf.A.MEH.Preis) then
      aMenge # aMenge + Auf.A.Menge.Preis
    else if (Auf.P.MEH.Preis='Stk') then
      aMenge # aMenge + cnvfi("Auf.A.Stückzahl");
    else if (Auf.P.MEH.Einsatz='kg') then
      aMenge # aMenge + vGew
    else if (Auf.P.MEH.Einsatz='t') then
      aMenge # aMenge + vGew / 1000.0
    else if (Auf.A.MEH.Preis = Auf.P.MEH.Einsatz) then
      aMenge # aMenge + Auf.A.Menge;
***/
  end
  else begin
    if (Auf.P.MEH.Einsatz = Auf.A.MEH) then begin
      aMenge # aMenge + Auf.A.Menge;
    end
    else if (Auf.P.MEH.Einsatz='Stk') then begin
      aMenge # aMenge + cnvfi("Auf.A.Stückzahl");
    end
    else if (Auf.P.MEH.Einsatz='kg') then begin
      aMenge # aMenge + vGew;
    end
    else if (Auf.P.MEH.Einsatz='t') then begin
      aMenge # aMenge + vGew / 1000.0;
    end
    else if (Auf.P.MEH.Einsatz = Auf.A.MEH.Preis) then begin
      aMenge # aMenge + Auf.A.Menge.Preis;
    end;
  end;
end;


//========================================================================
// _SubAktion
//
//========================================================================
sub _SubAktion(
  var aMenge  : float;
  var aStk    : int;
  var aGew    : float);
local begin
  vGew  : float;
end
begin
  vGew # Auf.A.Gewicht;
  if (VwA.NettoYN) then vGew # Auf.A.Nettogewicht;    // 17.04.2020 AH

  aStk # aStk - "Auf.A.Stückzahl";
  aGew # aGew - vGew;
  if (Auf.A.MEH=Auf.P.MEH.Einsatz) then
    aMenge # aMenge - Auf.A.Menge
  else if (Auf.P.MEH.Einsatz='Stk') then
    aMenge # aMenge - cnvfi("Auf.A.Stückzahl");
  else if (Auf.P.MEH.Einsatz='kg') then
    aMenge # aMenge - vGew
  else if (Auf.P.MEH.Einsatz='t') then
    aMenge # aMenge - vGew / 1000.0;
  else if (Auf.A.MEH.Preis=Auf.P.MEH.Einsatz) then
    aMenge # aMenge - Auf.A.Menge.Preis
end;


//========================================================================
// _Recalc  +ERR
//
//========================================================================
sub _Recalc() : logic
local begin
  Erx                 : int;
  vInSL               : logic;
  vInPos              : logic;
  vSollteBerechenbar  : logic;
  vProz               : float;
  v440                : int;
  v441                : int;
  vVSBEkAufDemWeg     : logic;
  vLFA                : logic;
  vLohn               : logic;
end;
begin
//  if (Auf.A.ArtikelNr<>'') AND (Auf.A.Materialnr = 0) and (Auf.A.Position2<>0) then begin
// 10.04.2015  if (Auf.A.ArtikelNr<>'') and
  if (Auf.A.Position2<>0) then begin
    Erx # RecLink(409,404,5,_recFirst);
    if (Erx=_rOK) and (Auf.SL.LfdNr<>0) then vInSL # y;
  end;

  if ((vInSL) and (Auf.P.ArtikelTyp=c_Art_HDL)) then vInPos # y;
  if ((vInSL) and (Auf.P.ArtikelTyp=c_Art_SET)) then vInPos # y;
  if ((vInSL) and (Auf.P.ArtikelTyp=c_Art_CUT)) then vInPos # y;
  if ((vInSL) and (Auf.P.ArtikelTyp=c_Art_EXP)) then vInPos # y;
  if ((vInSL) and (Auf.A.aktionsTyp=c_Akt_LFS)) then vInPos # y;
  if ((vInSL) and (Auf.A.aktionsTyp=c_Akt_VLDAW)) then vInPos # y;
  if ((vInSL) and (Auf.A.aktionsTyp=c_Akt_RLFS)) then vInPos # y;
  if ((vInSL) and (Auf.A.aktionsTyp=c_Akt_RVLDAW)) then vInPos # y;
  if (vInSL=n) then begin
    vInPos # y;
    vLohn # (AAr.Berechnungsart>=700) and (AAr.Berechnungsart<=799);      // 03.05.2022 AH
    if (Set.BA.LohnVSBwieVK) then vLohn # false;                          // 13.06.2022 AH
  end;

  if (Auf.A.Aktionstyp<>c_Akt_DFaktGut) and (Auf.A.Aktionstyp<>c_Akt_DFaktBel) then begin
    if (Auf.A.MEH='Stk') and ("Auf.A.Stückzahl"=0) then
      "Auf.A.Stückzahl" # cnvif(Auf.A.Menge);
    if (Auf.A.MEH='kg') and ("Auf.A.Gewicht"=0.0) then
      "Auf.A.Gewicht" # Auf.A.Menge;
    if (Auf.A.MEH='t') and ("Auf.A.Gewicht"=0.0) then
      "Auf.A.Gewicht" # Auf.A.Menge * 1000.0;
  end;

  // fehlende Felder belegen
  if ("Auf.A.Stückzahl"=0) then begin
    if (Auf.A.MEH='Stk') then "Auf.A.Stückzahl" # Cnvif(Auf.A.Menge)
    else if (Auf.A.MEH.Preis='Stk') then "Auf.A.Stückzahl" # Cnvif(Auf.A.Menge.Preis);
  end;

  // ggf. SL sperren
  if (vInSL) then begin
    Erx # RecRead(409,1,_RecSingleLock);
    if (Erx<>_rOk) then begin
      Error(404108,AInt(Auf.SL.Nummer)+'/'+AInt(Auf.SL.Position)+'/'+AInt(Auf.SL.lfdnr));
      RETURN false;
    end;
  end;

  case Auf.A.Aktionstyp of

    // Bestellungen 23.07.2019
    c_Akt_Bestellung : begin
      _AddAktion(var Auf.P.Prd.EkBest, var Auf.P.Prd.EkBest.Stk, var Auf.P.Prd.EkBest.Gew);
    end;

    
    // Abruf
    c_Akt_Abruf : begin
      // Liefervertrag minimieren
      //Auf.P.Prd.LFS       # Auf.P.Prd.LFS     + Auf.A.Menge;
      //Auf.P.Prd.LFS.Gew   # Auf.P.Prd.LFS.Gew + Auf.A.Gewicht;
      //Auf.P.Prd.LFS.Stk   # Auf.P.Prd.LFS.Stk + "Auf.A.Stückzahl";
      _AddAktion(var Auf.P.Prd.LFS, var Auf.P.Prd.LFS.Stk, var Auf.P.Prd.LFS.Gew);

      vProz # Lib_Berechnungen:Prozent(Auf.P.Prd.LFS, Auf.P.Menge.Wunsch);
      if (Auf.P.Prd.VSB<=0.0) and (Auf.P.Prd.VSAuf<=0.0) and (Auf.P.Aktionsmarker<>'$') and
        (Auf.P.Prd.LFS-Auf.P.Prd.Rech=0.0) and
        (vProz>="Set.Wie.RechDelAuf%") then begin
        "Auf.P.Löschmarker"     # '*';
        "Auf.P.Lösch.Datum"  # today;
        "Auf.P.Lösch.Zeit"   # now;
        "Auf.P.Lösch.User"   # gUsername;
      end;
    end;


    // PAbruf
    c_Akt_PAbruf : begin
      // Liefervertrag minimieren
      _AddAktion(var Auf.P.Prd.Plan, var Auf.P.Prd.Plan.Stk, var Auf.P.Prd.Plan.Gew);
    end;


    c_Akt_AbrufSL : begin
      // LiefervertragSL minimieren
      if (vInSL) then begin
        //Auf.SL.Prd.LFS       # Auf.SL.Prd.LFS     + Auf.A.Menge;
        //Auf.SL.Prd.LFS.Gew   # Auf.SL.Prd.LFS.Gew + Auf.A.Gewicht;
        //Auf.SL.Prd.LFS.Stk   # Auf.Sl.Prd.LFS.Stk + "Auf.A.Stückzahl";
      _AddAktion(var Auf.Sl.Prd.LFS, var Auf.SL.Prd.LFS.Stk, var Auf.SL.Prd.LFS.Gew);
      end;
    end;


    // Verladeanweisung
    c_Akt_VLDAW, c_Akt_RVLDAW : begin
      
@ifdef defBessererLFA
      // 15.07.2019 AH: LFS (nicht LFA!) mindern VSB-Menge
      v440 # RekSave(440);
      Lfs.Nummer # Auf.A.Aktionsnr;
      Erx # RecRead(440,1,0);
      vLFA # (Erx<=_rLocked) and (Lfs.zuBA.Nummer<>0);
      RekRestore(v440);
      if (vLFA=false) then begin
        if (vInSL) then begin
          _SubAktion(var Auf.SL.Prd.VSB, var Auf.SL.Prd.VSb.Stk, var Auf.SL.Prd.VSB.Gew);
        end;
        if (vInPos) then begin
          _SubAktion(var Auf.P.Prd.VSB, var Auf.P.Prd.VSB.Stk, var Auf.P.Prd.VSB.Gew);
        end;
      end;
@endif
      
      if (vInSL) then begin
        //Auf.SL.Prd.VSAuf      # Auf.SL.Prd.VSAuf     + Auf.A.Menge;
        //Auf.SL.Prd.VSAuf.Gew  # Auf.SL.Prd.VSAuf.Gew + Auf.A.Gewicht;
        //Auf.SL.Prd.VSAuf.Stk  # Auf.SL.Prd.VSAuf.Stk + "Auf.A.Stückzahl";
        _AddAktion(var Auf.SL.Prd.VSAuf, var Auf.SL.Prd.VSAuf.Stk, var Auf.SL.Prd.VSAuf.Gew);
        if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
          //Auf.SL.Prd.VSB      # Auf.SL.Prd.VSB     + Auf.A.Menge;
          //Auf.SL.Prd.VSB.Gew  # Auf.SL.Prd.VSB.Gew + Auf.A.Gewicht;
          //Auf.SL.Prd.VSB.Stk  # Auf.SL.Prd.VSB.Stk + "Auf.A.Stückzahl";
          _AddAktion(var Auf.SL.Prd.VSB, var Auf.SL.Prd.VSB.Stk, var Auf.SL.Prd.VSB.Gew);
        end;
      end;
      if (vInPos) then begin
        //Auf.P.Prd.VSAuf       # Auf.P.Prd.VSAuf     + Auf.A.Menge;
        //Auf.P.Prd.VSAuf.Gew   # Auf.P.Prd.VSAuf.Gew + Auf.A.Gewicht;
        //Auf.P.Prd.VSAuf.Stk   # Auf.P.Prd.VSAuf.Stk + "Auf.A.Stückzahl";
        _AddAktion(var Auf.P.Prd.VSAuf, var Auf.P.Prd.VSauf.Stk, var Auf.P.Prd.VSAuf.Gew);
        if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
          //Auf.P.Prd.VSB      # Auf.P.Prd.VSB     + Auf.A.Menge;
          //Auf.P.Prd.VSB.Gew  # Auf.P.Prd.VSB.Gew + Auf.A.Gewicht;
          //Auf.P.Prd.VSB.Stk  # Auf.P.Prd.VSB.Stk + "Auf.A.Stückzahl";
          _AddAktion(var Auf.P.Prd.VSB, var Auf.P.Prd.VSB.Stk, var Auf.P.Prd.VSB.Gew);
        end;
      end;
    end;

    // Lieferschein
    c_Akt_LFS, c_Akt_RLFS   : begin
      if (vInSL) then begin
        //Auf.SL.Prd.LFS      # Auf.SL.Prd.LFS     + Auf.A.Menge;
        //Auf.SL.Prd.LFS.Gew  # Auf.SL.Prd.LFS.Gew + Auf.A.Gewicht;
        //Auf.SL.Prd.LFS.Stk  # Auf.SL.Prd.LFS.Stk + "Auf.A.Stückzahl";
        _AddAktion(var Auf.SL.Prd.LFS, var Auf.SL.Prd.LFS.Stk, var Auf.SL.Prd.LFS.Gew);
      end;
      if (vInPos) then begin
        //Auf.P.Prd.LFS       # Auf.P.Prd.LFS       + Auf.A.Menge;
        //Auf.P.Prd.LFS.Gew   # Auf.P.Prd.LFS.Gew   + Auf.A.Gewicht;
        //Auf.P.Prd.LFS.Stk   # Auf.P.Prd.LFS.Stk   + "Auf.A.Stückzahl";
        _AddAktion(var Auf.P.Prd.LFS, var Auf.P.Prd.LFS.Stk, var Auf.P.Prd.LFS.Gew);
        if (Auf.A.Aktionstyp<>c_AKT_RLFS) and (AAr.KonsiYN=n) and
          (((AAr.Berechnungsart>=200) and (AAr.Berechnungsart<=209)) or
          ((AAr.Berechnungsart>=250) and (AAr.Berechnungsart<=259))) then begin
          vSollteBerechenbar # y;
          end;
      end;
    end;

    // STORNO-Lieferschein
    c_Akt_StornoLFS   : begin
      if (vInSL) then begin
        //Auf.SL.Prd.LFS      # Auf.SL.Prd.LFS     - Auf.A.Menge;
        //Auf.SL.Prd.LFS.Gew  # Auf.SL.Prd.LFS.Gew - Auf.A.Gewicht;
        //Auf.SL.Prd.LFS.Stk  # Auf.SL.Prd.LFS.Stk - "Auf.A.Stückzahl";
//        _SubAktion(var Auf.SL.Prd.LFS, var Auf.SL.Prd.LFS.Stk, var Auf.SL.Prd.LFS.Gew);
      end;
      if (vInPos) then begin
        //Auf.P.Prd.LFS       # Auf.P.Prd.LFS       - Auf.A.Menge;
        //Auf.P.Prd.LFS.Gew   # Auf.P.Prd.LFS.Gew   - Auf.A.Gewicht;
        //Auf.P.Prd.LFS.Stk   # Auf.P.Prd.LFS.Stk   - "Auf.A.Stückzahl";
//        _SubAktion(var Auf.P.Prd.LFS, var Auf.P.Prd.LFS.Stk, var Auf.P.Prd.LFS.Gew);
      end;
    end;

    // BA-Verbrauch
    c_Akt_BA_Verbrauch : begin
      if (vInSL) then begin
        //Auf.SL.Prd.LFS      # Auf.SL.Prd.LFS     + Auf.A.Menge;
        //Auf.SL.Prd.LFS.Gew  # Auf.SL.Prd.LFS.Gew + Auf.A.Gewicht;
        //Auf.SL.Prd.LFS.Stk  # Auf.SL.Prd.LFS.Stk + "Auf.A.Stückzahl";
        _AddAktion(var Auf.SL.Prd.LFS, var Auf.SL.Prd.LFS.Stk, var Auf.SL.Prd.LFS.Gew);
      end;
    end;

    // Produktionsverbrauch
    c_Akt_PRD_Verbrauch : begin
      if (vInSL) then begin
        //Auf.SL.Prd.LFS      # Auf.SL.Prd.LFS     + Auf.A.Menge;
        //Auf.SL.Prd.LFS.Gew  # Auf.SL.Prd.LFS.Gew + Auf.A.Gewicht;
        //Auf.SL.Prd.LFS.Stk  # Auf.SL.Prd.LFS.Stk + "Auf.A.Stückzahl";
        _AddAktion(var Auf.SL.Prd.LFS, var Auf.SL.Prd.LFS.Stk, var Auf.SL.Prd.LFS.Gew);
      end;
      if (vInPos) then begin
        //Auf.P.Prd.LFS       # Auf.P.Prd.LFS       + Auf.A.Menge;
        //Auf.P.Prd.LFS.Gew   # Auf.P.Prd.LFS.Gew   + Auf.A.Gewicht;
        //Auf.P.Prd.LFS.Stk   # Auf.P.Prd.LFS.Stk   + "Auf.A.Stückzahl";
        _AddAktion(var Auf.P.Prd.LFS, var Auf.P.Prd.LFS.Stk, var Auf.P.Prd.LFS.Gew);
      end;
    end;

    // ArtikelChargen-Reservierung
    c_Akt_RV    : begin
/*
      RecRead(409,1,_RecLock);
      "Auf.SL.Plan.Stück" # "Auf.SL.Plan.Stück" + "Auf.A.Stückzahl";
      Auf.SL.Plan.Gewicht # Auf.SL.Plan.Gewicht + Auf.A.Gewicht;
      Auf.SL.Plan.Menge   # Auf.SL.Plan.Menge   + Auf.A.Menge;
      RekReplace(409,_recUnlock,'AUTO');

      xAuf.P.Prd.Plan      # Auf.P.Prd.Plan      + Auf.A.Menge;
      xAuf.P.Prd.Plan.Gew  # Auf.P.Prd.Plan.Gew  + Auf.A.Gewicht;
      xAuf.P.Prd.Plan.Stk  # Auf.P.Prd.Plan.Stk  + "Auf.A.Stückzahl";
*/
    end;

    // Zuordnung
    c_Akt_VSB, c_akt_VsbPool : begin
      if (vInSL) then begin
        //Auf.SL.Prd.VSB     # Auf.SL.Prd.VSB     + Auf.A.Menge;
        //Auf.SL.Prd.VSB.Gew # Auf.SL.Prd.VSB.Gew + Auf.A.Gewicht;
        //Auf.SL.Prd.VSB.Stk # Auf.SL.Prd.VSB.Stk + "Auf.A.Stückzahl";
        _AddAktion(var Auf.SL.Prd.VSB, var Auf.SL.Prd.VSb.Stk, var Auf.SL.Prd.VSB.Gew);
      end;
      if (vInPos) then begin
        //Auf.P.Prd.VSB       # Auf.P.Prd.VSB       + Auf.A.Menge;
        //Auf.P.Prd.VSB.Gew   # Auf.P.Prd.VSB.Gew   + Auf.A.Gewicht;
        //Auf.P.Prd.VSB.Stk   # Auf.P.Prd.VSB.Stk   + "Auf.A.Stückzahl";
        _AddAktion(var Auf.P.Prd.VSB, var Auf.P.Prd.VSB.Stk, var Auf.P.Prd.VSB.Gew);
      end;
    end;

    // direkte Gutshrifts-Fakturierung
    c_Akt_DFaktGut : begin
      //Auf.P.Prd.LFS       # Auf.P.Prd.LFS       + Auf.A.Menge;
      //Auf.P.Prd.LFS.Gew   # Auf.P.Prd.LFS.Gew   + Auf.A.Gewicht;
      //Auf.P.Prd.LFS.Stk   # Auf.P.Prd.LFS.Stk   + "Auf.A.Stückzahl";
        _AddAktion(var Auf.P.Prd.LFS, var Auf.P.Prd.LFS.Stk, var Auf.P.Prd.LFS.Gew);
      if ((AAr.Berechnungsart>=200) and (AAr.Berechnungsart<=209)) or
        ((AAr.Berechnungsart>=250) and (AAr.Berechnungsart<=259)) then
        vSollteBerechenbar # y;
    end;

    // direkte Belastungs-Fakturierung
    c_Akt_DFaktBel : begin
      //Auf.P.Prd.LFS       # Auf.P.Prd.LFS       + Auf.A.Menge;
      //Auf.P.Prd.LFS.Gew   # Auf.P.Prd.LFS.Gew   + Auf.A.Gewicht;
      //Auf.P.Prd.LFS.Stk   # Auf.P.Prd.LFS.Stk   + "Auf.A.Stückzahl";
      _AddAktion(var Auf.P.Prd.LFS, var Auf.P.Prd.LFS.Stk, var Auf.P.Prd.LFS.Gew);
      if ((AAr.Berechnungsart>=200) and (AAr.Berechnungsart<=209)) or
        ((AAr.Berechnungsart>=250) and (AAr.Berechnungsart<=259)) then
        vSollteBerechenbar # y;
    end;

    // direkte Fakturierung
    c_Akt_DFakt : begin
      //Auf.P.Prd.LFS       # Auf.P.Prd.LFS       + Auf.A.Menge;
      //Auf.P.Prd.LFS.Gew   # Auf.P.Prd.LFS.Gew   + Auf.A.Gewicht;
      //Auf.P.Prd.LFS.Stk   # Auf.P.Prd.LFS.Stk   + "Auf.A.Stückzahl";
      if (AAr.KonsiYN=false) then
        _AddAktion(var Auf.P.Prd.LFS, var Auf.P.Prd.LFS.Stk, var Auf.P.Prd.LFS.Gew);
      if ((AAr.Berechnungsart>=200) and (AAr.Berechnungsart<=209)) or
        ((AAr.Berechnungsart>=250) and (AAr.Berechnungsart<=259)) then
        vSollteBerechenbar # y;
    end;

    // BA-Position
    c_Akt_BA : begin
      if (vLohn) then begin
        vSollteBerechenbar # (Auf.A.Aktionsdatum<>0.0.0);
        if (Auf.A.Rechnungsnr=0) then   // 09.05.2022 AH
          _AddAktion(var Auf.P.Prd.Plan, var Auf.P.Prd.Plan.Stk, var Auf.P.Prd.Plan.Gew);
      end;
    end;

    // BA Planmenge
    c_Akt_VSBEK,
    c_Akt_BA_Plan_Fahr,
    c_Akt_BA_Plan, c_Akt_PRD_Plan : begin
      if (vLohn) and (Auf.A.Aktionstyp <> c_Akt_VSBEK) then begin // 11.05.2022 AH
      end
      else begin
        if (vInSL) then begin
          //Auf.SL.Prd.Plan     # Auf.SL.Prd.Plan     + Auf.A.Menge;
          //Auf.SL.Prd.Plan.Gew # Auf.SL.Prd.Plan.Gew + Auf.A.Gewicht;
          //Auf.SL.Prd.Plan.Stk # Auf.SL.Prd.Plan.Stk + "Auf.A.Stückzahl";
          _AddAktion(var Auf.SL.Prd.PLan, var Auf.SL.Prd.PLan.Stk, var Auf.SL.Prd.Plan.Gew);
        end;
        if (vInPos) then begin
          //Auf.P.Prd.Plan      # Auf.P.Prd.Plan      + Auf.A.Menge;
          //Auf.P.Prd.Plan.Gew  # Auf.P.Prd.Plan.Gew  + Auf.A.Gewicht;
          //Auf.P.Prd.Plan.Stk  # Auf.P.Prd.Plan.Stk  + "Auf.A.Stückzahl";

          // ST 2020-09-21 2076/64: Bei VSB/EK prüfen, ob das Material schon in einer EingangsVLAW durch ein Fahren eingeplant ist
          if (Auf.A.Aktionstyp = c_Akt_VSBEK) then begin
            vVSBEkAufDemWeg # false;
            v441 # RecBufCreate(441);
            v441->Lfs.P.Materialnr # Auf.A.MaterialNr;
            Erx # RecRead(v441,3,_RecFirst);    // 23.10.2020 AH FIX mit "v441" nicht "441"
            if (Erx <= _rMultiKey) then
              vVSBEkAufDemWeg # true;
            RecBufDestroy(v441);
          
            if (vVSBEkAufDemWeg = false) then
              _AddAktion(var Auf.P.Prd.Plan, var Auf.P.Prd.Plan.Stk, var Auf.P.Prd.Plan.Gew);
          end
          else begin
            
            // normale Addition
            _AddAktion(var Auf.P.Prd.Plan, var Auf.P.Prd.Plan.Stk, var Auf.P.Prd.Plan.Gew);
            
          end;
        end;
      end;
    end;

    // BA Fertigmenge
/* Fertig ist NICHT VSB !!!
    c_Akt_BA_Fertig : begin
      if (vInSL) then begin
        Auf.SL.Prd.VSB     # Auf.SL.Prd.VSB     + Auf.A.Menge;
        Auf.SL.Prd.VSB.Gew # Auf.SL.Prd.VSB.Gew + Auf.A.Gewicht;
        Auf.SL.Prd.VSB.Stk # Auf.SL.Prd.VSB.Stk + "Auf.A.Stückzahl";
      end;
      if (vInPos) then begin
        Auf.P.Prd.VSB       # Auf.P.Prd.VSB       + Auf.A.Menge;
        Auf.P.Prd.VSB.Gew   # Auf.P.Prd.VSB.Gew   + Auf.A.Gewicht;
        Auf.P.Prd.VSB.Stk   # Auf.P.Prd.VSB.Stk   + "Auf.A.Stückzahl";
      end;
    end;
*/

    // BA Ausfallmenge
    c_Akt_BA_Ausfall : begin
      if (vInSL) then begin
        //Auf.SL.Prd.Plan     # Auf.SL.Prd.Plan     - Auf.A.Menge;
        //Auf.SL.Prd.Plan.Gew # Auf.SL.Prd.Plan.Gew - Auf.A.Gewicht;
        //Auf.SL.Prd.Plan.Stk # Auf.SL.Prd.Plan.Stk - "Auf.A.Stückzahl";
        _SubAktion(var Auf.SL.Prd.Plan, var Auf.SL.Prd.Plan.Stk, var Auf.SL.Prd.Plan.Gew);
      end;
      if (vInPos) then begin
        //Auf.P.Prd.Plan      # Auf.P.Prd.Plan      - Auf.A.Menge;
        //Auf.P.Prd.Plan.Gew  # Auf.P.Prd.Plan.Gew  - Auf.A.Gewicht;
        //Auf.P.Prd.Plan.Stk  # Auf.P.Prd.Plan.Stk  - "Auf.A.Stückzahl";
        _SubAktion(var Auf.P.Prd.Plan, var Auf.P.Prd.Plan.Stk, var Auf.P.Prd.Plan.Gew);
      end;
    end;
  end;  // CASE

  // bereits auf Rechnung?
  if (Auf.A.Rechnungsnr<>0) and (Auf.A.Aktionstyp<>c_Akt_GBMat) then begin
//    Auf.P.Prd.Rech      # Auf.P.Prd.Rech + Auf.A.Menge.Preis;
//    Auf.P.Prd.Rech.Stk  # Auf.P.Prd.Rech.Stk + "Auf.A.Stückzahl";
//    Auf.P.Prd.Rech.Gew  # Auf.P.Prd.Rech.Gew + Auf.A.Gewicht;
   _AddAktion(var Auf.P.Prd.Rech, var Auf.P.Prd.Rech.Stk, var Auf.P.Prd.Rech.Gew, y);
  end;


  // neu zu berechnender Eintrag?
  if (vSollteBerechenbar) and (Auf.A.Anlage.User='*NEW*') then begin
    Auf.A.Rechnungsmark # '$';
    if ("Auf.P.Löschmarker"='*') then begin
      Error(404101,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position));
      RETURN false;
    end;
  end;

  // berechnebare Aktion?
  if (Auf.A.Rechnungsmark='$') and ("Auf.A.Löschmarker"='') and (Auf.A.Rechnungsnr=0) then begin
    Auf.P.Aktionsmarker # '$';
    Auf.Aktionsmarker   # '$';

//    Auf.P.Prd.zuBere      # Auf.P.Prd.zuBere      + Auf.A.Menge.Preis;
//    Auf.P.Prd.zuBere.Stk  # Auf.P.Prd.zuBere.Stk  + "Auf.A.Stückzahl";
//    Auf.P.Prd.zuBere.Gew  # Auf.P.Prd.zuBere.Gew  + Auf.A.Gewicht;
    _AddAktion(var Auf.P.Prd.zuBere, var Auf.P.Prd.zuBere.Stk, var Auf.P.Prd.zuBere.Gew,y);
  end;

  // neue Aktion??
  if (Auf.A.Anlage.User='*NEW*') then begin
    Erx # RecRead(404,1,_recSingleLock | _recNoLoad);
    if (Erx=_rOK) then begin
      Auf.A.Anlage.User   # gUserName;
      Erx # RekReplace(404,_recUnlock,'AUTO');
    end;
    if (Erx<>_rOK) then RETURN false;
  end;

  // ggf. SL speichern
  if (vInSL) then begin
    Erx # RekReplace(409,_RecUnlock,'AUTO');
    if (Erx<>_rOK) then RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// RecalcAll  +ERR
//
//========================================================================
sub RecalcAll(
  opt aSL : logic
) : logic;
local begin
  Erx       : int;
  vBuf404   : int;
  vDatei    : int;
  vBuf40x   : int;
  vM1, vM2  : float;
  vAufOffen : float;
  vA        : alpha;
  v702      : int;
end;
begin
  
  if (aSL) then vA # 'Y'
  else vA # 'N';
  if (RunAFX('Auf.A.RecalcAll', vA)<>0) then RETURN (AfxRes=_rOK);

  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  If (Erx>_rLocked) then begin
    Error(404100,AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position));
    RETURN false;
  end;

  if (VwA.Nummer<>Auf.P.Verwiegungsart) then begin
    Erx # RecLink(818,401,9,_recFirst);   // Verwiegungsart holen
    if (Erx<>_rok) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;
  end;


  // Auftragskopf holen
  vDatei # 401;
  Erx # RecLink(400,401,3,_recFirst);
  if (Erx>_rLocked) then begin
    vDatei # 411;
    "Auf~Nummer" # Auf.P.Nummer;
    Erx # RecRead(410,1,0);
    If (Erx>_rLocked) then begin
      Error(404105,AInt(Auf.P.Nummer));
      RETURN false;
    end;
    RecBufCopy(410,400);
  end;

  Erx # RecLink(818,401,9,_recFirst);   // Verwiegungsart holen
  if (Erx<>_rok) then begin
    RecBufClear(818);
    VWa.NettoYN # Y;
  end;


  vBuf404 # RekSave(404);

  TRANSON;


  // Position anpassen
  Erx # RecRead(vDatei,1,_RecSingleLock);
  If (Erx<>_rOK) then begin
    TRANSBRK;
    Error(404102,AInt(Auf.P.Nummer));
    RekRestore(vBuf404);
    RETURN false;
  end;
  vBuf40x # RecBufCreate(vDatei);
  RecBufCopy(vDatei,vBuf40x);

  Erx # RecRead(vDatei-1,1,_RecSingleLock);
  If (Erx<>_rOK) then begin
    TRANSBRK;
    Error(404106,AInt(Auf.A.Nummer));
    RekRestore(vBuf404);
    RETURN false;
  end;
  Auf.P.Prd.EkBest      # 0.0;
  Auf.P.Prd.EkBest.Stk  # 0;
  Auf.P.Prd.EkBest.Gew  # 0.0;
  Auf.P.Prd.Plan      # 0.0;
  Auf.P.Prd.Plan.Stk  # 0;
  Auf.P.Prd.Plan.Gew  # 0.0;
  Auf.P.Prd.VSB       # 0.0;
  Auf.P.Prd.VSB.Stk   # 0;
  Auf.P.Prd.VSB.Gew   # 0.0;
  Auf.P.Prd.VSAuf     # 0.0;
  Auf.P.Prd.VSAuf.Stk # 0;
  Auf.P.Prd.VSAuf.Gew # 0.0;
  Auf.P.Prd.LFS       # 0.0;
  Auf.P.Prd.LFS.Stk   # 0;
  Auf.P.Prd.LFS.Gew   # 0.0;
  Auf.P.Prd.Rech      # 0.0;
  Auf.P.Prd.Rech.Stk  # 0;
  Auf.P.Prd.Rech.Gew  # 0.0;
  Auf.P.Prd.zuBere      # 0.0;
  Auf.P.Prd.zuBere.Stk  # 0;
  Auf.P.Prd.zuBere.Gew  # 0.0;

  Auf.P.GPl.Plan      # 0.0;
  Auf.P.GPl.Plan.Stk  # 0;
  Auf.P.GPl.Plan.Gew  # 0.0;


  Auf.P.Aktionsmarker # '';
  Auf.Aktionsmarker   # '';

  // Stücklistenmengen nullen...
  Erx # RecLink(409,401,15,_recFirst);  // SL loopen
  WHILE (Erx<=_rLocked) do begin
    Erx # RecRead(409,1,_RecSingleLock | _recNoLoad);
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Error(404108,AInt(Auf.SL.Nummer)+'/'+AInt(Auf.SL.Position)+'/'+AInt(Auf.SL.lfdnr));
      RekRestore(vBuf404);
      RETURN false;
    end;
    Auf.SL.Prd.Plan       # 0.0;
    Auf.SL.Prd.Plan.Stk   # 0;
    Auf.SL.Prd.Plan.Gew   # 0.0;
    Auf.SL.Prd.VSB        # 0.0;
    Auf.SL.Prd.VSB.Stk    # 0;
    Auf.SL.Prd.VSB.Gew    # 0.0;
    Auf.SL.Prd.VSAuf      # 0.0;
    Auf.SL.Prd.VSAuf.Stk  # 0;
    Auf.SL.Prd.VSAuf.Gew  # 0.0;
    Auf.SL.Prd.LFS        # 0.0;
    Auf.SL.Prd.LFS.Stk    # 0;
    Auf.SL.Prd.LFS.Gew    # 0.0;
    Erx # RekReplace(409,_recUnlock,'AUTO');
    If (Erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
      TRANSBRK;
      Error(1010,thisline);
      RekRestore(vBuf404);
      RETURN false;
    end;

    Erx # RecLink(409,401,15,_recNext);
  END;

  // ALLE AKTIONEN SUMMIEREN...
  Erx # RecLink(404,401,12,_recFirst);  // Aktionen loopen
  WHILE (Erx<=_rLocked) do begin
    if ("Auf.A.Löschmarker"='') then begin

      // 26.04.2019 AH:
      if (Auf.A.Aktionstyp=c_Akt_BA_Plan_Fahr) or (Auf.A.Aktionstyp=c_Akt_BA_Plan) or (Auf.A.Aktionstyp=c_Akt_PRD_Plan) then begin
        v702 # RecbufCreate(702);
        Erx # RecLink(v702,404,14,_recFirst);  // BA-Position holen
        if (Erx<=_rLocked) then begin
          if (v702->"BAG.P.Löschmarker"<>'') then begin
            RecBufDestroy(v702);
            Erx # RecRead(404,1,_RecLock);
            if (Erx=_rOK) then begin
              "Auf.A.Löschmarker" # '*';
              Erx # RekReplace(404);
            end;
            if (Erx<>_rOK) then begin
              TRANSBRK;
              RecBufDestroy(v702);
              RecRead(vDatei-1,1,_recunlock);
              RecRead(vDatei,1,_recunlock);
              RekRestore(vBuf404);
              RETURN false;
            end;
            CYCLE;
          end;
        end;
        RecBufDestroy(v702);
      end;

      if (_Recalc()=false) then begin
        TRANSBRK;
        RecRead(vDatei-1,1,_recunlock);
        RecRead(vDatei,1,_recunlock);
        RekRestore(vBuf404);
        RETURN false;
      end;
    end;
    Erx # RecLink(404,401,12,_recNext);
  END;

/*
@ifdef NurPlus
  if (Auf.P.Prd.Plan<0.0) then      Auf.P.Prd.Plan      # 0.0;
  if (Auf.P.Prd.Plan.Gew<0.0) then  Auf.P.Prd.Plan.Gew  # 0.0;
  if (Auf.P.Prd.Plan.Stk<0) then    Auf.P.Prd.Plan.Stk  # 0;
  if (Auf.P.Prd.VSB<0.0) then       Auf.P.Prd.VSB       # 0.0;
  if (Auf.P.Prd.VSB.Gew<0.0) then   Auf.P.Prd.VSB.Gew   # 0.0;
  if (Auf.P.Prd.VSB.Stk<0) then     Auf.P.Prd.VSB.Stk   # 0;
  if (Auf.P.Prd.VSAuf<0.0) then     Auf.P.Prd.VSAuf     # 0.0;
  if (Auf.P.Prd.VSAuf.Gew<0.0) then Auf.P.Prd.VSAuf.Gew # 0.0;
  if (Auf.P.Prd.VSAuf.Stk<0) then   Auf.P.Prd.VSAuf.Stk # 0;
  if (Auf.P.Prd.LFS<0.0) then       Auf.P.Prd.LFS       # 0.0;
  if (Auf.P.Prd.LFS.Gew<0.0) then   Auf.P.Prd.LFS.Gew   # 0.0;
  if (Auf.P.Prd.LFS.Stk<0) then     Auf.P.Prd.LFS.Stk   # 0;
  if (Auf.P.Prd.Rech<0.0) then      Auf.P.Prd.Rech      # 0.0;
  if (Auf.P.Prd.Rech.Gew<0.0) then  Auf.P.Prd.Rech.Gew  # 0.0;
  if (Auf.P.Prd.Rech.Stk<0) then    Auf.P.Prd.Rech.Stk  # 0;
@endif
*/
  Auf.P.Prd.Rest      # Auf.P.Menge       - Auf.P.Prd.LFS;
  Auf.P.Prd.Rest.Gew  # Auf.P.Gewicht     - Auf.P.Prd.LFS.Gew;
  Auf.P.Prd.Rest.Stk  # "Auf.P.Stückzahl" - Auf.P.Prd.LFS.Stk;
  if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then begin
    if (Auf.P.Prd.Rest>0.0) then Auf.P.Prd.Rest # 0.0;
    if (Auf.P.Prd.Rest.Stk>0) then Auf.P.Prd.Rest.Stk # 0;
    if (Auf.P.Prd.Rest.Gew>0.0) then Auf.P.Prd.Rest.Gew # 0.0;
    end
  else begin
    if (Auf.P.Prd.Rest<0.0) then      Auf.P.Prd.Rest      # 0.0;
    if (Auf.P.Prd.Rest.Gew<0.0) then  Auf.P.Prd.Rest.Gew  # 0.0;
    if (Auf.P.Prd.Rest.Stk<0) then    Auf.P.Prd.Rest.Stk  # 0;
  end;

  if (vDatei=401) then
    Erx # Auf_Data:PosReplace(_recunlock,'AUTO')
  else
    Erx # RekReplace(vDatei,_recUnlock,'AUTO');
  if (erx<>_rOk) then begin
    TRANSBRK;
    RecRead(vDatei-1,1,_recunlock);
    RecRead(vDatei,1,_recunlock);
    Error(404102,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position));
    RekRestore(vBuf404);
    RETURN false;
  end;
  Erx # RekReplace(vDatei-1,_recUnlock,'AUTO');
  if (erx<>_rOk) then begin
    TRANSBRK;
    RecRead(vDatei-1,1,_recunlock);
    RecRead(vDatei,1,_recunlock);
    Error(404106,AInt(Auf.A.Nummer));
    RekRestore(vBuf404);
    RETURN false;
  end;

  // Artikelrestmengen buchen...
  if (Auf.P.Artikelnr<>'') and (vDatei=401) and ("Auf.P.löschmarker"='') then begin
    if (Auf.LiefervertragYN) then begin // 19.05.2022 AH ff.
      vM1 #  (vBuf40x->Auf.P.Menge - vBuf40x->Auf.P.Prd.LFS);
      vM1 # Max(vM1, 0.0);
      vM2 #  (Auf.P.Menge - Auf.P.Prd.LFS);
      vM2 # Max(vM2, 0.0);
       vAufOffen # vM2 - vM1;
    end
    else begin
      // 12.01.2015: Überdeckung von DFAKT abfangen
      vM1 # (vBuf40x->Auf.P.Menge - vBuf40x->Auf.P.Prd.VSB - vBuf40x->Auf.P.Prd.LFS);   // VORHER "offner Auf"
      vM1 # vM1 - vBuf40x->Auf.P.Prd.Plan; // 01.02.2018 AH Dispotest
      if (Set.Art.AufRst.Rsrv) then
        vM1 # vM1 - vBuf40x->Auf.P.Prd.Reserv;
    
  //debugx(anum(vBuf40x->Auf.P.Menge,0)+' - '+anum(vBuf40x->Auf.P.Prd.VSB,0)+' - '+anum(vBuf40x->Auf.P.Prd.LFS,0)+' = '+anum(vM1,0));
      vM2 # (Auf.P.Menge - Auf.P.Prd.VSB - Auf.P.Prd.LFS);                              // NACHHER "offener Auf"
      vM2 # vM2 - Auf.P.Prd.Plan; // 01.02.2018 AH Dispotest
      if (Set.Art.AufRst.Rsrv) then
        vM2 # vM2 - Auf.P.Prd.Reserv;

  //debugx(anum(Auf.P.Menge,0)+' - '+anum(Auf.P.Prd.VSB,0)+' - '+anum(Auf.P.Prd.LFS,0)+' = '+anum(vM2,0));
    //  if (vM1<>vM2) then begin
  //      vM2 # vM2 - vM1;
  //if (vM1+vM2<0.0) then vM2 # -vM1
    // seit 11.11.2015 so (damit VLDAWs richtig rechnen)
      if (vM1>=0.0) and (vM2>=0.0) then     vAufOffen # vM2 - vM1
      else if (vM1>0.0) and (vM2<0.0) then  vAufOffen # - vM1
      else if (vM1<0.0) and (vM2>0.0) then  vAufOffen # vM2
      else                                  vAufOffen # 0.0;
    end;
  
//debugx('ALSO '+anum(vAufOffen,0));
  if (Auf.Vorgangstyp=c_AUF) and        //  2022-06-23  AH  NUR bei =AUF
     (vAufOffen<>0.0) then begin
      Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
      if (Erx>_rLocked) then RecBufClear(835);
      if (AAr.ReservierePosYN) then begin
        Erx # RecLink(250,401,2,_recfirst);   // Artikel holen
        if (Erx<=_rLocked) then begin
          RecBufClear(252);
          Art.C.ArtikelNr     # Auf.P.ArtikelNr;
          Art.C.Dicke         # Auf.P.Dicke;
          Art.C.Breite        # Auf.P.Breite;
          "Art.C.Länge"       # "Auf.P.Länge";
          Art.C.RID           # Auf.P.RID;
          Art.C.RAD           # Auf.P.RAD;
//debugx('KEY401 AufAktion '+anum(vAufOffen,0));
          Art_Data:Auftrag(vAufOffen);
        end;
      end;
    end;
  end;

  RecBufDestroy(vBuf40x);

  TRANSOFF;

  RekRestore(vBuf404);

  RETURN true;
end;


//========================================================================
// NeuAmKopfAnlegen
//
//========================================================================
sub NeuAmKopfAnlegen(opt akeineAutoNr  : logic)
//; logic; FRÜHER VOR ERX
: int
local begin
  Erx     : int;
  vInSL   : logic;
  vInPos  : logic;
  vBuf400 : int;
  vBuf100 : int;
  v401    : int;
  vI      : int;
end;
begin
  Auf.A.Nummer        # Auf.P.Nummer;
  Auf.A.Position      # 0;
  Auf.A.Position2     # 0;

  if (Adr.Kundennr<>Auf.P.Kundennr) or (Adr.Kundennr=0) then begin
    vBuf100 # RecBufCreate(100);
    RecLink(vBuf100,401,4,_recFirst);   // Kunde holen
    Auf.A.Adressnummer  # vBuf100->Adr.Nummer;
    RecBufDestroy(vBuf100);
  end
  else begin
    Auf.A.Adressnummer  # Adr.Nummer;
  end;

  Auf.A.Anlage.User   # gUserName;
  Auf.A.Anlage.Datum  # today;
  Auf.A.Anlage.Zeit   # Now;

  TRANSON;

  if (aKeineAutoNr=n) or (Auf.A.Aktion=0) then begin
    v401 # RecBufCreate(401);
    v401->Auf.P.Nummer # Auf.Nummer;
    vI # RecLinkInfo(404,v401,12,_reccount);
    RecBufDestroy(v401);
    Auf.A.Aktion      # 1 + vI;
    WHILE (RecRead(404,1,_RecTest)<=_rLocked) do begin
      Auf.A.Aktion # Auf.A.Aktion + 1;
      if (Auf.A.Aktion>65000) then begin
        TRANSBRK;
        Erg # _rNoRec;    // TODOERX
        RETURN _rNoRec;
      end;
    END;
  end;

  Erx # RekInsert(404,0,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Erg # Erx;    // TODOERX
    RETURN _rNoRec;
  end;
  TRANSOFF;

  Erg # _rOK;    // TODOERX

  RETURN _rOK;
end;


//========================================================================
// NeuAnlegen
//
//========================================================================
sub NeuAnlegen(
  opt akeineAutoNr  : logic;
  opt aSL           : logic;
  opt aPerTodo      : logic)
//: logic; FRÜHER VOR ERX
: int;
local begin
  Erx     : int;
  vInSL   : logic;
  vInPos  : logic;
  vBuf400 : int;
  vBuf100 : int;
  vI      : int;

  vPara   : alpha;  // Parameterstring für AFX-Aufruf
end;
begin

  // ggf. Ankerfunktion aufrufen
  if (aKeineAutoNr) then     vPara # 'y|';  else    vPara # 'n|';
  if (aSL)          then     vPara # vPara + 'y|';  else    vPara # vPara + 'n|';
  if (RunAFX('Auf.A.NeuAnlegen',vPara)<>0) then begin
    Erg # AfxRes;    // TODOERX
    RETURN AfxRes;
  end;

  if (Auf.SL.LfdNr<>0) then vInSL # aSL;
  if ((aSL) and (Auf.P.ArtikelTyp=c_art_HDL)) then vInPos # y;
  if ((aSL) and (Auf.P.ArtikelTyp=c_art_SET)) then vInPos # y;
  if ((aSL) and (Auf.P.ArtikelTyp=c_art_CUT)) then vInPos # y;
  if ((aSL) and (Auf.P.ArtikelTyp=c_art_EXP)) then vInPos # y;
  if ((aSL) and (Auf.A.aktionsTyp=c_Akt_LFS)) then vInPos # y;
  if ((aSL) and (Auf.A.aktionsTyp=c_Akt_VLDAW)) then vInPos # y;
  if ((aSL) and (Auf.A.aktionsTyp=c_Akt_RLFS)) then vInPos # y;
  if ((aSL) and (Auf.A.aktionsTyp=c_Akt_RVLDAW)) then vInPos # y;

  if (aSL=n) then vInPos # y;

  Auf.A.Nummer        # Auf.P.Nummer;
  Auf.A.Position      # Auf.P.Position;
  Auf.A.Position2     # 0;

  if (Adr.Kundennr<>Auf.P.Kundennr) or (Adr.Kundennr=0) then begin
    vBuf100 # RecBufCreate(100);
    RecLink(vBuf100,401,4,_recFirst);   // Kunde holen
    Auf.A.Adressnummer  # vBuf100->Adr.Nummer;
    RecBufDestroy(vBuf100);
  end
  else begin
    Auf.A.Adressnummer  # Adr.Nummer;
  end;

  if (vInSL) then Auf.A.Position2   # Auf.SL.lfdNr;

  if (Auf.A.Aktionstyp<>c_Akt_DFaktGut) and (Auf.A.Aktionstyp<>c_Akt_DFaktBel) then begin
    if (Auf.A.MEH='Stk') and ("Auf.A.Stückzahl"=0) then
      "Auf.A.Stückzahl" # cnvif(Auf.A.Menge);
    if (Auf.A.MEH='kg') and ("Auf.A.Gewicht"=0.0) then
      "Auf.A.Gewicht" # Auf.A.Menge;
    if (Auf.A.MEH='t') and ("Auf.A.Gewicht"=0.0) then
      "Auf.A.Gewicht" # Auf.A.Menge * 1000.0;
  end;

  // fehlende Felder belegen
  if ("Auf.A.Stückzahl"=0) then begin
    if (Auf.A.MEH='Stk') then "Auf.A.Stückzahl" # Cnvif(Auf.A.Menge)
    else if (Auf.A.MEH.Preis='Stk') then "Auf.A.Stückzahl" # Cnvif(Auf.A.Menge.Preis);
  end;

  if (Auf.A.Menge.Preis=0.0) then begin
    if (Auf.A.MEH.Preis<>'') and (Auf.A.Menge<>0.0) then begin
      Auf.A.Menge.Preis   # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);
      end
    else begin
      Auf.A.Menge.Preis # 0.0;
    end;
  end;

  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  If (Erx>_rLocked) then begin
    Error(404100,AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position));
    Erg # _rNoREc;    // TODOERX
    RETURN _rNoRec;
  end;


  // Prüfen ob Auftrag schon abgeschlossen ist
//  if (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false) then begin
//    Error(001400 ,Translate('Aktionsdatum') + '|'+ CnvAd(Auf.A.Aktionsdatum));
//    RETURN false;
//  end;


  // Zahlungsbedinung holen / KREDITLIMITCHECK
  if ((Auf.A.Menge<>0.0) or (Auf.A.Menge.Preis<>0.0)) and
    (Auf.A.Aktionstyp<>c_Akt_Kasse) then begin
    vBuf400 # RecBufCreate(400);
    vBuf400->Auf.Nummer # Auf.P.Nummer;
    Erx # RecRead(vBuf400,1,0);
    if (Erx>_rLocked) then begin
      "Auf~Nummer" # Auf.P.Nummer;
      Erx # RecRead(410,1,0);
      if (Erx>_rLocked) then begin
        RecBufDestroy(vBuf400);
        Erg # _rNoRec;    // TODOERX
        RETURN _rNoRec;
      end;
      RecBufCopy(410,vBuf400);
    end;
    Zab.Nummer # vBuf400->Auf.Zahlungsbed;
    RecBufDestroy(vBuf400);
    Erx # RecRead(816,1,0);
    if (Erx>_rLocked) or (ZaB.SperreYN) then begin
      Error(404109,AInt(Auf.A.Nummer));
      Erg # _rNoRec;    // TODOERX
      RETURN _rNoRec;
    end;
  end;

  Auf.A.Anlage.User   # '*NEW*';// WICHTIG FÜR RECALC!!!
  Auf.A.Anlage.Datum  # today;
  Auf.A.Anlage.Zeit   # Now;

  TRANSON;

  if (aKeineAutoNr=n) or (Auf.A.Aktion=0) then begin
    vI # RecLinkInfo(404,401,12,_reccount);
    Auf.A.Aktion      # 1 + vI;
    WHILE (RecRead(404,1,_RecTest)<=_rLocked) do begin
      Auf.A.Aktion # Auf.A.Aktion + 1;
      if (Auf.A.Aktion>65000) then begin
        TRANSBRK;
        Erg # _rNoRec;    // TODOERX
        RETURN _rNoRec;
      end;
    END;
  end;

  Erx # RekInsert(404,0,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Erg # _rNoRec;    // TODOERX
    RETURN _rNoRec;
  end;
//debugx('NEU '+anum(auf.a.menge.preis,2)+'   KEY404');

  if (aPerTodo=false) then begin
    if (RecalcAll()=false) then begin   // 09.09.2020 DAUERT
      TRANSBRK;
      ErrorOutput;
      Erg # _rNoRec;    // TODOERX
      RETURN _rNoRec;
    end;
  end
  else begin
    Lib_Misc:AddTodo('Auf.A.Recalc|'+aint(Auf.P.nummer)+'|'+aint(Auf.P.Position));
  end;

  TRANSOFF;

  RunAFX('Auf.A.NeuAnlegen.Post','');  // 05.06.2020 AH

  Erg # _rOK;    // TODOERX

  RETURN _rOK;
end;


//========================================================================
// Entfernen
//
//========================================================================
sub Entfernen(opt aNurStern : logic) : logic;
local begin
  Erx     : int;
  vInPos  : logic
end;
begin

  // Bereits berechnet?
  if (Auf.A.Rechnungsnr<>0) /*or ("Auf.A.Löschmarker"='*')*/ then begin
    Msg(404103,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position),0,0,0);
    RETURN false;
  end;

  if (Auf.p.nummer<>auf.a.Nummer) or (auf.p.position<>auf.a.position) then begin
    Erx # ReCLink(401,404,1,_recFirst);   // Aufpos holen
    if (Erx>_rLocked) then RETURN false;
  end;

  // Auftragsposition updaten
  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  If (Erx>_rLocked) then begin
    Msg(404100,AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position),0,0,0);
    RETURN false;
  end;


  TRANSON;

  // Löschen
  if (aNurStern) then begin
    Erx # RecRead(404,1,_recSingleLock);
    if (Erx=_rOK) then begin
      "Auf.A.Löschmarker" # '*';
      Erx # RekReplace(404,_recUnlock,'AUTO');
    end;
  end
  else begin
    Erx # RekDelete(404,0,'AUTO');
  end;
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Msg(404104,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position),0,0,0);
    RETURN false;
  end;

  if (RecalcAll()=false) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN false;
  end;

  TRANSOFF;

  RunAFX('Auf.A.Entfernen.Post','');  // 05.06.2020 AH

  RETURN true;
end;


//========================================================================
// LiesAktion
//
//========================================================================
sub LiesAktion(
  aAufNr    : int;
  aPosNr    : int;
  aPosNr2   : int;
  aTyp      : alpha;
  aAktNr    : int;
  aAktPos1  : int;
  aAktPos2  : int;
  opt aBem  : alpha;
  opt aDel  : logic;
) : logic;
local begin
  Erx   : int;
end;
begin
  Erx # _rNoRec;
  RecbufClear(404);
  Auf.A.Nummer        # aAufNr;
  Auf.A.Position      # aPosNr;
  Auf.A.Position2     # aPosNr2;
  Auf.A.AktionsTyp    # aTyp;
  Auf.A.Aktionsnr     # aAktNr;
  Auf.A.AktionsPos    # aAktPos1;
  Auf.A.AktionsPos2   # aAktPos2;
  Erx # RecRead(404,6,0);
  WHILE ((erx=_rLocked) or (Erx=_rOk) or (Erx=_rMultikey)) and
    (Auf.A.Nummer=aAufNr) and (Auf.A.Position=aPosNr) and (Auf.A.Position2=aPosNr2) and
    (Auf.A.AktionsTyp=aTyp) and (Auf.A.Aktionsnr=aAktNr) and (Auf.A.AktionsPos=aAktPos1) and
    (Auf.A.AktionsPos2=aAktPos2) do begin

    if (aBem<>'') then
      if (aBem<>Auf.A.Bemerkung) then begin
        Erx # RecRead(404,6,_RecNext);
        CYCLE;
    end;

    if ("Auf.A.Löschmarker"='') or (aDel) then RETURN true;

    erx # RecRead(404,6,_RecNext);
  END;

  RecbufClear(404);
  RETURN false;
end;


//========================================================================
// ToggleLoschmarker
//
//========================================================================
sub ToggleLoeschmarker() : logic;
local begin
  Erx     : int;
  vInPos  : logic;
end;
begin

  // LFS? -> Abbruch
  if (Auf.A.Aktionstyp=c_Akt_LFS) or (Auf.A.Aktionstyp=c_Akt_RLFS) or
    (Auf.A.Aktionstyp=c_AKT_StornoLFS) then RETURN false;

  // VSB? -> Abbruch
  if (Auf.A.Aktionstyp=c_AKt_VSB) or (Auf.A.Aktionstyp=c_AKt_VsbPool) or (Auf.A.Aktionstyp=c_Akt_VSBEK) /*or (Auf.A.Aktionstyp=c_AKT_StornoVSB)*/ then RETURN false;

  // VSB? -> Abbruch
  if (Auf.A.Aktionstyp=c_AKt_DFAKT) or (Auf.A.Aktionstyp=c_AKT_StornoDFAKT) then RETURN false;


  // Bereits berechnet? -> Abbruch
  if (Auf.A.Rechnungsnr<>0) /*or ("Auf.A.Löschmarker"='*')*/ then begin
    Msg(404103,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position),0,0,0);
    RETURN false;
  end;

  // Auftragsposition updaten
  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  If (Erx>_rLocked) then begin
    Msg(404100,AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position),0,0,0);
    RETURN false;
  end;

  TRANSON;

  // Löschen
  Erx # RecRead(404,1,_recSingleLock);
  if (Erx=_rOK) then begin
    if ("Auf.A.Löschmarker"='') then
      "Auf.A.Löschmarker" # '*'
    else
      "Auf.A.Löschmarker" # '';
    Erx # RekReplace(404,_recUnlock,'AUTO');
  end;
  if (Erx<>_rOk) then begin
    Msg(404104,AInt(Auf.A.Nummer)+'/'+AInt(Auf.A.Position),0,0,0);
    RETURN false;
  end;

  if (RecalcAll()=false) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
// Storno
//
//========================================================================
sub Storno(opt aSilent : logic) : logic;
local begin
  erx     : int;
  vI      : int;
  vOK     : logic;
  vM1,vM2 : float;
end;
begin
  if (Rechte[Rgt_Auf_A_Storno]=n) then RETURN false;
  if ("Auf.P.Löschmarker"<>'') then RETURN false;
  if ("Auf.A.Löschmarker"<>'') then RETURN false;


//  if (Lib_Faktura:Abschlusstest(Auf.A.Aktionsdatum) = false) then begin
//    if (aSilent = false) then
//      Msg(001400,Translate('Aktionsdatum') + '|'+ CnvAd(Auf.A.Aktionsdatum),0,0,0);
//    RETURN false;
//  end;

  case (Auf.A.Aktionstyp) of

    // DEFAKT -------------------------------------------------
    c_Akt_DFakt : begin

      // Artikeldatei?
      if(Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
//TODO('Artikelrücknahme');
//RETURN false;

        if (aSilent=n) then
          if (Msg(404002,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;

        TRANSON;

        // Artikel wieder zubuchen
        RecBufClear(252);
        Art.C.ArtikelNr     # Auf.A.ArtikelNr;
        Art.C.Charge.Intern # Auf.A.Charge;
        RecBufClear(253);
        Art.J.Datum           # today;
        Art.J.Bemerkung       # c_AktBem_StornoDfakt+' '+AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position);
        "Art.J.Stückzahl"     # "Auf.A.Stückzahl";
        Art.J.Menge           # Auf.A.Menge;
        "Art.J.Trägertyp"     # c_Akt_StornoDFakt;
        "Art.J.Trägernummer1" # Auf.P.Nummer;
        "Art.J.Trägernummer2" # Auf.P.Position;
        "Art.J.Trägernummer3" # 0;
        vOK # Art_Data:Bewegung(0.0,0.0);
        if (vOK=false) then begin
          TRANSBRK;
          Msg(404003,'',0,0,0);
          RETURN false;
        end;

        // Aktion löschen
        Erx # RecRead(404,1,_recSingleLock);
        if (Erx=_rOK) then begin
          "Auf.A.Löschmarker" # '*';
          Erx # RekReplace(404,_recUnlock,'AUTO');
        end;
        if (erx<>_rOK) then begin
          TRANSBRK;
          Msg(404003,'',0,0,0);
          RETURN false;
        end;

        // Neue Aktion alnegen
        "Auf.A.Löschmarker" # '';
        Auf.A.Rechnungsmark # '';
        Auf.A.Aktionstyp    # c_Akt_StornoDFAKT;
        if (NeuAnlegen()<>_rOK) then begin
          TRANSBRK;
          Msg(404003,'',0,0,0);
          RETURN false;
        end;

        TRANSOFF;

        RETURN true;

      end;  // Artikel


      // Materialdatei?
      if ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr))) and
        (Auf.A.MaterialNr<>0) then begin
        Erx # RecLink(200,404,6,_recFirst);     // Material holen
        if (Erx<>_rOK) then begin
          if (aSilent=n) then
            Msg(404201,AInt(auf.a.Materialnr),0,0,0);
          RETURN false;
        end;

        if (Mat.VK.Rechnr<>0) then begin
          if (aSilent=n) then
            Msg(404202,AInt(auf.a.Materialnr),0,0,0);
          RETURN false;
        end;

        if (aSilent=n) then
          if (Msg(404002,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;


        TRANSON;

        // Material aktivieren
        Erx # RecRead(200,1,_recSingleLock);
        if (Erx=_rOK) then begin
          Mat.Ausgangsdatum # 0.0.0;
          "Mat.Löschmarker" # '';
          erx # Mat_data:Replace(_RecUnlock,'AUTO');
        end;
        if (erx<>_rOK) then begin
          Msg(404003,'',0,0,0);
          TRANSBRK;
          RETURN false;
        end;

        // Aktion löschen
        Erx # RecRead(404,1,_recSingleLock);
        if (Erx=_rOK) then begin
          "Auf.A.Löschmarker" # '*';
          Erx # RekReplace(404,_recUnlock,'AUTO');
        end;
        if (erx<>_rOK) then begin
          TRANSBRK;
          Msg(404003,'',0,0,0);
          RETURN false;
        end;

        // Neue Aktion alnegen
        "Auf.A.Löschmarker" # '';
        Auf.A.Rechnungsmark # '';
        Auf.A.Aktionstyp  # c_Akt_StornoDFAKT;
        if (NeuAnlegen()<>_rOK) then begin
          TRANSBRK;
          Msg(404003,'',0,0,0);
          RETURN false;
        end;

        TRANSOFF;

        RETURN true;
      end; // Material

    end;  // DFAKT-Aktion


    // VSB ----------------------------------------------------
    c_Akt_VSB, c_Akt_VsbPool : begin

      // Artikeldatei?
      if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin

//debug('C:'+auf.a.artikelnr+' '+cnvai(auf.a.charge.adresse)+' ' +cnvai(auf.a.charge.anschr)+' ' +auf.a.charge);
        if (Auf.A.Menge<>0.0) or ("Auf.A.Stückzahl"<>0) then begin
          Erx # RecLink(252,404,4,_RecFirsT);       // Charge holen
          if (Erx<>_rOK) then begin
            Msg(404250,Auf.A.Charge,0,0,0);
            RETURN false;
          end;

          if (aSilent=n) then
            if (Msg(404002,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;

          TRANSON;

          // Artikel freigeben / Reservierung löschen
          if (Art_Data:Reservierung(Auf.A.ArtikelNr, Auf.A.Charge.Adresse, Auf.A.Charge.Anschr, Auf.A.Charge, 0, c_Auf, Auf.A.Nummer, Auf.A.Position, 0, -Auf.A.Menge, -"Auf.A.Stückzahl", 0)=false) then begin
            TRANSBRK;
            Msg(250004,'',0,0,0);
            RETURN false;
          end;
        end
        else begin
          TRANSON;
        end;

        vM1 # Auf.P.Prd.Rest-Auf.P.Prd.VSB;

        // Aktion löschen
        Erx # RecRead(404,1,_recSingleLock);
        if (Erx=_rOK) then begin
          "Auf.A.Stückzahl"   # 0;
          Auf.A.Menge         # 0.0;
          Auf.A.Gewicht       # 0.0;
          Auf.A.Nettogewicht  # 0.0;
          Auf.A.Menge.Preis   # 0.0;
          erx # RekReplace(404,_recUnlock,'AUTO');
        end;
        if (erx<>_rOK) then begin
          Msg(404003,'',0,0,0);
          TRANSBRK;
          RETURN false;
        end;
        RecalcAll(n);
/*** 11.11.2015 macht Auf_A_Data:RecalcAll schon!!
        // Auftragsrest wieder erhöhen
        Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
        if (Erx>_rLocked) then RecBufClear(835);

        if (AAr.ReservierePosYN) then begin
          Erx # RecLink(250,401,2,_RecFirst);   // Artikel holen
          if (Erx<=_rLocked) then begin
            RecBufClear(252);
            vM2 # Auf.P.Prd.Rest-Auf.P.Prd.VSB;
            if (vM2>0.0) and (vM2>vM1) then begin
              Art_Data:Auftrag(vM2 - vM1);
            end;
          end;
        end;
***/
        TRANSOFF;

        RETURN true;

      end;  // Artikel



      // Materialdatei?
      if ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr))) and
        (Auf.A.MaterialNr<>0) then begin

        Erx # RecLink(200,404,6,_recFirst);     // Material holen
        if (Erx<>_rOK) then begin
          if (aSilent=n) then
            Msg(404201,AInt(auf.a.Materialnr),0,0,0);
          RETURN false;
        end;

        if (Mat.VK.Rechnr<>0) then begin
          if (aSilent=n) then
            Msg(404202,AInt(auf.a.Materialnr),0,0,0);
          RETURN false;
        end;

        if (aSilent=n) then
          if (Msg(404002,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;

        TRANSON;

        // Material freigeben
        vI # Mat_Data:SetKommission(Mat.Nummer, 0,0,0 ,'MAN');
        if (vI<>0) then begin
          TRANSBRK;
          Msg(200402,AInt(vI),0,0,0);
          ErrorOutput;
          RETURN false;
        end;
        // AFX
        RunAFX('Mat.SetKommission','');

        // 04.09.2015 AH:
        // Eintrag löschen, da er NICHT von der "SetKommission" entfernt wird, wenn gFile=404 ist!!
        if (Entfernen(n)=false) then begin
          TRANSBRK;
          Msg(999999,'1392',0,0,0);
          RETURN false;
        end;

        Erx # SelRecDelete(gZLList->wpDbSelection, 404);
        if (erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
          TRANSBRK;
          Msg(1010,thisline,0,0,0);
          RETURN false;
        end;

        TRANSOFF;

        Msg(200401,'',0,0,0);

        RETURN true;

      end;  // Material

    end;  // VSB-Aktion


    // LFS ----------------------------------------------------
    c_Akt_LFS, c_Akt_RLFS: begin

      // Artikeldatei?
      if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
TODO('Artikelrücknahme');
RETURN false;
      end;  // Artikel


      // Materialdatei?
      if ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr))) and
        (Auf.A.MaterialNr<>0) then begin

        Erx # Mat_Data:Read(Auf.A.Materialnr, 0, 0, true);
//        Erx # RecLink(200,404,6,_recFirst);     // Material holen
//        if (Erx<>_rOK) then begin
        if (Erx<200) then begin
          if (aSilent=n) then
            Msg(404201,AInt(auf.a.Materialnr),0,0,0);
          RETURN false;
        end;

        if (Mat.VK.Rechnr<>0) then begin
          if (aSilent=n) then
            Msg(404202,AInt(auf.a.Materialnr),0,0,0);
          RETURN false;
        end;

        if (aSilent=n) then
          if (Msg(404002,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;


        TRANSON;

        // Material aktivieren
        Erx # RecRead(200,1,_recSingleLock);
        if (Erx=_rOK) then begin
          Mat.Ausgangsdatum # 0.0.0;
          "Mat.Löschmarker" # '';
          Erx # Mat_data:Replace(_RecUnlock,'AUTO');
        end;
        if (erx<>_rOK) then begin
          Msg(404003,'',0,0,0);
          TRANSBRK;
          RETURN false;
        end;

        // Aktion löschen
        Erx # RecRead(404,1,_recSingleLock);
        if (Erx=_rOK) then begin
          "Auf.A.Löschmarker" # '*';
          Erx # RekReplace(404,_recUnlock,'AUTO');
        end;
        if (erx<>_rOK) then begin
          TRANSBRK;
          Msg(404003,'',0,0,0);
          RETURN false;
        end;

        // Neue Aktion alnegen
        "Auf.A.Löschmarker" # '';
        Auf.A.Rechnungsmark # '';
        Auf.A.Aktionstyp  # c_Akt_StornoLFS;
        if (NeuAnlegen()<>_rOK) then begin
          TRANSBRK;
          Msg(404003,'',0,0,0);
          RETURN false;
        end;

        TRANSOFF;

        RETURN true;
      end; // Material

    end;  // LFS-Aktion


  end;  // case

  // nicht möglich...
  if (aSilent=n) then
    Msg(404001,'',0,0,0);
  RETURN false;

end;


//========================================================================
//  SetSperre
//
//========================================================================
SUB SetSperre(
  aPos    : int;
  aGrund  : alpha;
  aAktiv  : logic;
  aNurSet : logic) : int;
begin

  if (aAktiv=false) then begin
    // ggf. Sperratktion löschen
    if (Auf_A_Data:LiesAktion(Auf.Nummer, aPos,0, c_Akt_Sperre, Auf.Nummer, aPos,0, aGrund,y)) then begin
      if ("Auf.A.Löschmarker"='') then begin
        ToggleLoeschmarker();
        RETURN -1;
      end;
    end;

    end
  else begin
    // Aktion anlegen
    if (Auf_A_Data:LiesAktion(Auf.Nummer, aPos,0, c_Akt_Sperre, Auf.Nummer, aPos,0, aGrund,y)) then begin
      if ("Auf.A.Löschmarker"='*') then begin
        if (aNurSet=falsE) then begin
          ToggleLoeschmarker();
          RETURN 1;
          end
        else begin
          RETURN 0;
        end;
      end;
      end
    else begin
      if (aNurSet=false) then begin   // Proj. 1161/384
        RecBufClear(404);
        Auf.A.Aktionstyp    # c_Akt_Sperre;
        Auf.A.Bemerkung     # aGrund;
        Auf.A.Aktionsnr     # Auf.Nummer;
        Auf.A.Aktionspos    # aPos;
        Auf.A.Aktionsdatum  # Today;
        Auf.A.TerminStart   # Today;
        Auf.A.TerminEnde    # Today;
        if (aPos=0) then
          NeuAmKopfAnlegen()
        else
          NeuAnlegen();
      end;
      RETURN 1;
    end;
  end;

  RETURN 0;
end;


//========================================================================
//  SperreUmsetzen
//
//========================================================================
SUB SperreUmsetzen() : logic
local begin
  vBuf401 : int;
  vSum    : float;
  vA      : alpha(200);
end;
begin

  if (Rechte[Rgt_Auf_A_Sperre]=n) or (Auf.A.Aktionstyp<>c_Akt_Sperre) then RETURN false;

  // AFX
  if (RunAFX('Auf.A.SperreUmsetzen','')<0) then RETURN true;


  // Gesamtwert ermitteln...
  vSum # Auf_Data:SumAufwert();


  // KREDITLIMIT???
  if (Auf.A.Bemerkung=c_AktBem_Sperre_Kredit) then begin

    // Freigabe...
    if ("Auf.A.Löschmarker"='') then begin
      vA # 'Wollen Sie den Auftrag über '+anum(vSum,2)+' '+"Set.Hauswährung.Kurz"+' freigeben?';
      if (Msg(99,vA,_WinIcoWarning,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
      end
    else begin
      // Aufhebung...
      if (Auf.Freigabe.WertW1<>0.0) then begin
        if (Auf.Freigabe.Datum<>0.0.0) then vA # 'am '+cnvad(Auf.Freigabe.Datum);
        vA # 'Der Auftrag wurde '+vA+' mit '+anum(Auf.Freigabe.WertW1,2)+' '+"Set.Hauswährung.Kurz"+' von '+Auf.Freigabe.User+' freigegeben!';
        vA # vA + StrChar(13)+'Freigabe löschen?';
        if (Msg(99,vA,_WinIcoWarning,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
        end
      else begin
        vA # 'Wollen Sie die Kreidtlimitsperre wieder aktivieren?';
        if (Msg(99,vA,_WinIcoWarning,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
      end;
    end;
    ToggleLoeschmarker();
    Auf_Data:FreigabeErrechnen(vSum, gUsername);
    if ("Auf.A.Löschmarker"='') then
      RunAFX('Auf.Kreditlimit.Sperrt','');
  end;


  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
  RETURN true;
end;



//========================================================================
//  MatVsbReset()             ST 2015-02-04     Projekt 1507/54
//   Entfernt für die Markierten Auftragsaktionen die Mat.VSB.Datumsangabe
//========================================================================
sub MatVsbReset() : logic;
local begin
  Erx         : int;
  vItem       : int;
  vMFile      : Int;
  vMID        : Int;

  vCnt        : int;
end;
begin

  if (Lib_Mark:Count(404) = 0) then begin
    Error(99,TRanslate('Bitte markieren Sie die gewünschten VSB Aktionen'));
    RETURN false;
  end;


  // Makierungen loopen
  FOR   vItem # gMarkList->CteRead(_CteFirst);      // erste Element holen
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
  WHILE (vItem > 0) DO BEGIN

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>404) then
      CYCLE;

    // Aktion lesen
    Erx # RecRead(404,0,_RecID, vMID);
    if (Erx <> _rOK) then begin
      Error(001011,'Auftragsaktion');
      RETURN false;
    end;

    // Nur VSB Aktionen "reseten" lassen
    if (Auf.A.Aktionstyp<>c_AKt_VSB) then
      CYCLE;

    inc(vCnt);

    // Material lesen
    Erx # Mat_Data:Read(Auf.A.Materialnr,_RecSingleLock);
    if (Erx <> 200) then begin
      Error(010007,'Material');
      RETURN false;
    end;

    Mat.Datum.VSBMeldung # 0.0.0;

    // Material speichern
    Erx # Mat_Data:Replace(_RecUnLock,'MAN');
    if (Erx <> _rOK) then begin
      Error(010007,'Material');
      RETURN false;
    end;

  END;

  if (vCnt = 0) then begin
    Error(99,Translate('Keine VSB Aktion markiert'));
    RETURN false;
  end else begin

    // Erfolgsmeldung
    Msg(404006,Aint(vCnt),0,0,0);

  end;

  RETURN true;
end;




//========================================================================