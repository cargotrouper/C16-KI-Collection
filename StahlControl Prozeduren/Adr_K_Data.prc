@A+
//===== Business-Control =================================================
//
//  Prozedur  Adr_K_Data
//                    OHNE E_R_G
//
//  Info
//
//
//  06.11.2006  AI  Erstellung der Prozedur
//  18.07.2016  AH  Neu Setting "Set.KLP.BruttoYN"
//  23.07.2019  AH  SummeEkBest
//  28.08.2019  AH  Datumsangaben sind EINSCHLIEßLICH
//  20.08.2020  ST  Kreditlimitprüfung "opt aErr" hinzugefügt
//  16.04.2021  AH  "GibtsLfsFreigabe"
//  01.02.2022  ST  E r g --> Erx
//  2022-07-07  AH  DEADLOCK
//  2022-12-06  AH  "VersichertAm"
//
//  Subprozeduren
//
//  SUB VersichertAm
//  SUB Kreditlimit(
//  SUB Kreditlimit_BA
//  SUB GibtsLfsFreigabe
//  SUB SetLfsFreigabe
//  SUB BerechneFinanzen
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

declare BerechneFinanzen(aNoCalc : logic; var aResult : float; opt aOhneAuf : int ) : int


/*========================================================================
2022-12-06  AH
  Ersetzt alle "Adr.K.Kurz*"-Aufrufe
========================================================================*/
sub VersichertAm(
  aDat  : date
  ) : float
begin
  
  GV.Num.10 # 0.0;
  if (RunAFX('Adr.K.VersichertAm',cnvad(aDat))<>0) then begin
    RETURN GV.Num.10;
  end;
  if ("Adr.K.Währung"=0) then RETURN 0.0;

  Lib_Berechnungen:Waehrung_Umrechnen(Adr.K.VersichertFW, "Adr.K.Währung", var Adr.K.VersichertW1, 1);
  Lib_Berechnungen:Waehrung_Umrechnen(Adr.K.KurzlimitFW, "Adr.K.Währung", var Adr.K.KurzlimitW1, 1);

  if (aDat<=Adr.K.InternKurz.Dat) then
    RETURN Adr.K.InternKurz;
  if (Adr.K.InternLimit>0.0) then
    RETURN Adr.K.InternLimit;
  if (aDat<=Adr.K.KurzLimit.Dat) then
    RETURN Adr.K.KurzLimitW1;
  RETURN Adr.K.VersichertW1;
end;


//========================================================================
//  Kreditlimit
//
//========================================================================
sub Kreditlimit(
  aKuNr         : int;
  aTyp          : alpha;
  aMitABs       : logic;
  var aWert     : float;
  opt aOhneAuf  : int;
  opt aNurAuf   : int;
  opt aErr      : logic
) : logic;
local begin
  Erx : int;
  vL      : float;
  vSum    : float;
  vA      : alpha(200);
  vBuf400 : int;
  vX      : float;
end;
begin
  // ggf. andere Ankerfunktion vorhanden?
  if (aMitABs) then vA # '1'
  else vA # '0';
  vA # AInt(aKuNr)+'|'+aTyp+'|'+vA+'|'+ANum(aWert,2)+'|'+aint(aOhneAuf)+'|'+aint(aNurAuf)+'|'+Aint(CnvIl(aErr));
  // ÜbErxabeparameter: "KuNr|Typ|mitABs|Wert"
  GV.Num.01 # aWert;
  Erx # RunAFX('Adr.K.Kreditlimit',vA);
  aWert # GV.Num.01;
  if (Erx>0) then RETURN true;
  if (Erx<0) then RETURN false;

  // AUFTRAGSFREIGABE??
  if (aTyp='A') then begin
    if (aNurAuf=0) then RETURN true;
    vBuf400 # RecBufCreate(400);
    vBuf400->Auf.Nummer # aNurAuf;
    Erx # RecRead(vBuf400,1,0);
    if (Erx>_rLocked) or (vBuf400->Auf.Freigabe.Datum=0.0.0) then begin
      RecBufDestroy(vBuf400);
      if (aErr) then
        Error(103003,'');
      else
        Msg(103003,'',0,0,0);
      
      RETURN false;
    end;
    RecBufDestroy(vBuf400);
    RETURN true;
  end;


  Adr.KundenNr # aKuNr;
  Erx # RecRead(100,2,0);
  if (Erx>_rMultikey) then RETURN false;

  Erx # RecLink(103,100,14,_recfirsT);    // Limit holen
  if (Erx>_rLockeD) then RecBufClear(103);
  Lib_Berechnungen:Waehrung_Umrechnen(Adr.K.VersichertFW, "Adr.K.Währung", var Adr.K.VersichertW1, 1);
  Lib_Berechnungen:Waehrung_Umrechnen(Adr.K.KurzlimitFW, "Adr.K.Währung", var Adr.K.KurzlimitW1, 1);

//  Adr_Data:BerechneFinanzen();
  if (BerechneFinanzen(n, var vX, aOhneAuf)<>_rOK) then RETURN false;
  
  if (today<=Adr.K.InternKurz.Dat) then  vL # Adr.K.InternKurz;
  if (vL=0.0) then vL # Adr.K.InternLimit;
  if (vL=0.0) and (today<=Adr.K.KurzLimit.Dat) then vL # Adr.K.KurzLimitW1;
  if (vL=0.0) then vL # Adr.K.VersichertW1;

  //vA # ANum(vL,2)+"Set.Hauswährung.Kurz"+'|'+ANum(Adr.Fin.SummeOP,2)+"Set.Hauswährung.Kurz"+'|'+ANum(Adr.Fin.SummeAB,2)+"Set.Hauswährung.Kurz";
  //vSum # Adr.Fin.SummeOP;
  //if (aMitABs) then vSum # vSum + Adr.Fin.SummeAB;

  vA # ANum(vL,2)+"Set.Hauswährung.Kurz"+'|'+ANum(Adr.K.SummeOP,2)+"Set.Hauswährung.Kurz"+'|'+ANum(Adr.K.SummeAB,2)+"Set.Hauswährung.Kurz";
  vSum # Adr.K.SummeOP;
  if (aMitABs) then vSum # vSum + Adr.K.SummeAB;

  // komplett gesperrt?
  if (Adr.SperrKundeYN) then begin
    if (aErr) then
      Error(103002,Adr.Stichwort);
    else
      Msg(103002,Adr.Stichwort,0,0,0);
    
    RETURN false;
  end;

  aWert # vL - vSum;

  // Limit überschritten?
  if (vSum>=vL) then begin

    if (aTyp='M') and
       ((gUsergroup='MC9090') or (gUsergroup= 'BETRIEB_TS') OR
       (gUsergroup = 'BETRIEB')) then aTyp # 'S';

    // nur warnen?
    if (aTyp='M') then begin
      if (aErr) then
        Error(103000,vA+'|'+Adr.K.Bemerkung+'|'+Adr.Stichwort);
      else
        Msg(103000,vA+'|'+Adr.K.Bemerkung+'|'+Adr.Stichwort,0,0,0);
      RETURN true;
    end;

    // Sperren?
    if (aTyp='S') then begin
      if (aErr) then
        Error(103001,Adr.K.Bemerkung+'|'+Adr.Stichwort);
      else
        Msg(103001,Adr.K.Bemerkung+'|'+adr.Stichwort,0,0,0);
      RETURN false;
    end;
  end;

  RETURN true;
end;


//========================================================================
//  Kreditlimit_BA
//
//========================================================================
sub Kreditlimit_BA(
  aKuNr     : int;
  aTyp      : alpha;
  var aWert : float;
  aNurAuf   : int;
) : logic;
local begin
  Erx     : int;
  vL      : float;
  vSum    : float;
  vA      : alpha(200);
  vBuf400 : int;
  vX      : float;
end;
begin

  // ggf. andere Ankerfunktion vorhanden?
  vA # '2';
  vA # AInt(aKuNr)+'|'+aTyp+'|'+vA+'|'+ANum(aWert,2);
  // ÜbErxabeparameter: "KuNr|Typ|mitABs|Wert"
  Erx # RunAFX('Adr.K.Kreditlimit',vA);
  if (Erx>0) then RETURN true;
  if (Erx<0) then RETURN false;


  // AUFTRAGSFREIGABE??
  if (aTyp='A') then begin
    if (aNurAuf=0) then RETURN true;
    vBuf400 # RecBufCreate(400);
    vBuf400->Auf.Nummer # aNurAuf;
    Erx # RecRead(vBuf400,1,0);
    if (Erx>_rLocked) or (vBuf400->Auf.Freigabe.Datum=0.0.0) then begin
      RecBufDestroy(vBuf400);
      RETURN false;
    end;
    RecBufDestroy(vBuf400);
    RETURN true;
  end;


  Adr.KundenNr # aKuNr;
  Erx # RecRead(100,2,0);
  if (Erx>_rMultikey) then RETURN false;

  Erx # RecLink(103,100,14,_recfirsT);    // Limit holen
  if (Erx>_rLockeD) then RecBufClear(103);
  Lib_Berechnungen:Waehrung_Umrechnen(Adr.K.VersichertFW, "Adr.K.Währung", var Adr.K.VersichertW1, 1);
  Lib_Berechnungen:Waehrung_Umrechnen(Adr.K.KurzlimitFW, "Adr.K.Währung", var Adr.K.KurzlimitW1, 1);

  //Adr_Data:BerechneFinanzen();
  if (BerechneFinanzen(n, var vX)<>_rOK) then RETURN false;
  vL # VersichertAm(today);
//  if (today<=Adr.K.InternKurz.Dat) then  vL # Adr.K.InternKurz;
//  if (vL=0.0) then vL # Adr.K.InternLimit;
//  if (vL=0.0) and (today<=Adr.K.KurzLimit.Dat) then vL # Adr.K.KurzLimitW1;
//  if (vL=0.0) then vL # Adr.K.VersichertW1;

  //vA # ANum(vL,2)+"Set.Hauswährung.Kurz"+'|'+ANum(Adr.Fin.SummeOP,2)+"Set.Hauswährung.Kurz"+'|'+ANum(Adr.Fin.SummeAB,2)+"Set.Hauswährung.Kurz";
  //vSum # Adr.Fin.SummeOP;
  //vSum # vSum + Adr.Fin.SummePlan;

  vA # ANum(vL,2)+"Set.Hauswährung.Kurz"+'|'+ANum(Adr.K.SummeOP,2)+"Set.Hauswährung.Kurz"+'|'+ANum(Adr.K.SummeAB,2)+"Set.Hauswährung.Kurz";
  vSum # Adr.K.SummeOP;
  vSum # vSum + Adr.K.SummePlan;

  // komplett gesperrt?
  if (Adr.SperrKundeYN) then begin
    Msg(103002,adr.Stichwort,0,0,0)
    RETURN false;
  end;

  aWert # vL - vSum;

  // Limit überschritten?
  if (vSum>=vL) then begin

    // nur warnen?
    if (aTyp='M') then begin
      Msg(103000,vA+'|'+Adr.K.Bemerkung+'|'+Adr.Stichwort,0,0,0);
      RETURN true;
    end;

    // Sperren?
    if (aTyp='S') then begin
      Msg(103001,Adr.K.Bemerkung+'|'+adr.Stichwort,0,0,0);
      RETURN false;
    end;
  end;

  RETURN true;
end;


//========================================================================
//  GibtsLfsFreigabe
//========================================================================
sub GibtsLfsFreigabe(
  aLfs  : int;
  aAuf  : int) : logic
local begin
  Erx   : int;
  v404  : int;
  vOK   : logic;
end;
begin
  v404 # RekSave(404);
  RecBufClear(404);
  Auf.A.Nummer      # aAuf;
  Auf.A.Aktionstyp  # c_Akt_LfsFrei;
  Auf.A.AktionsNr   # aLfs;
  Erx # RecRead(404,6,0);
  vOK # (Erx<=_rMultikey);
  RekRestore(v404);
  RETURN vOK;
end;


//========================================================================
//  SetLfsFreigabe
//========================================================================
sub SetLfsFreigabe(
  aLfs  : int;
  aAuf  : int;
  aGew  : float;) : logic
local begin
  v404  : int;
  vOK   : logic;
end;
begin
  v404 # RekSave(404);
  RecBufClear(404);
  Auf.A.Nummer      # aAuf;
  Auf.A.Aktionstyp  # c_Akt_LfsFrei;
  Auf.A.AktionsNr   # aLfs;
  Auf.A.Gewicht     # aGew;
  Auf.A.Bemerkung   # c_AktBem_LfsFrei;
  Auf_A_Data:NeuAmKopfAnlegen();
  RETURN true;
end;


//========================================================================
//  BerechneFinanzen
//
//========================================================================
sub BerechneFinanzen(
  aNoCalc       : logic;
  var aResult   : float;      // 2022-07-07 AH : resultiert ERX
  opt aOhneAuf  : int;
  ) : int
local begin
  Erx       : int;
  vBuf100   : int;
  vL        : float;

  vSumOP    : float;
  vSumAB    : float;
  vSumBere  : float;
  vSumLfs   : float;
  vSumRes   : float;
  vSumPlan  : float;
  vSumBest  : float;
end;
begin
  aResult # 0.0;
  if (Adr.K.Nummer=0) then RETURN _rOK;

  if (aNoCalc=n) then begin
    vBuf100 # Reksave(100);
    // ALLE Kundne mit diesem Limit loopen...
    Erx # RecLink(100,103,1,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      // für diesen Kunden berechnen...
      Adr_Data:BerechneFinanzen(aOhneAuf);

      if (Set.KLP.BruttoYN) then begin
        vSumOP    # vSumOP    + Adr.Fin.SummeOPB + Adr.Fin.SummeOPB.Ext;
      end
      else begin
        vSumOP    # vSumOP    + Adr.Fin.SummeOP + Adr.Fin.SummeOP.Ext;
      end;

      vSumAB    # vSumAB    + Adr.Fin.SummeAB;
      vSumBere  # vSumBere  + Adr.Fin.SummeABBere;
      vSumLfs   # vSumLfs   + Adr.Fin.SummeLFS;
      vSumRes   # vSumRes   + Adr.Fin.SummeRes;
      vSumPlan  # vSumPlan  + Adr.Fin.SummePLan;
      vSumBest  # vSumBest  + Adr.Fin.SummeEkBest;

      Erx # RecLink(100,103,1,_recNext);
    END;

    // Werte rückspeichern:
    Erx # RecRead(103,1,_recLock);
    if (Erx=_rOK) then begin
      Adr.K.SummeOP       # vSumOP;
      Adr.K.SummeAB       # vSumAB;
      Adr.K.SummeABBere   # vSumBere;
      Adr.K.SummeLfs      # vSumLfs;
      Adr.K.SummeRes      # vSumRes;
      Adr.K.SummePlan     # vSumPlan;
      Adr.K.SummeEkBest   # vSumBest;
      Adr.K.Refreshdatum  # today;
      Erx # RekReplace(103,_recUnlock,'AUTO');
    end;
    if (Erx<>_rOK) then RETURN Erx;

    RekRestore(vBuf100);
  end;

  vL # VersichertAm(today);
//  if (today<=Adr.K.InternKurz.Dat) then  vL # Adr.K.InternKurz;
//  if (vL=0.0) then vL # Adr.K.InternLimit;
//  if (vL=0.0) and (today<=Adr.K.KurzLimit.Dat) then vL # Adr.K.KurzLimitW1;
//  if (vL=0.0) then vL # Adr.K.VersichertW1;

  aResult # vL - vSumAB - vSumOP;
  
  RETURN _rOK
end;




//========================================================================