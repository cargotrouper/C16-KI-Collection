@A+
//===== Business-Control =================================================
//
//  Prozedur  BA1_I_Subs
//                OHNE E_R_G
//  Info
//
//
//  16.07.2014  AH  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB MengenKorrektur() : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
end;

//========================================================================
//  MengenKorrektur
//
//========================================================================
sub MengenKorrektur() : logic;
local begin
  Erx       : int;
  vGew      : float;
  vStk      : int;
  vNetto    : float;
  vBrutto   : float;
  vPreis    : float;
  vA        : alpha;
  vDat      : date;
  vTim      : time;
  vMenge    : float;
  vPreisPM  : float;
  vDiffStk  : int;
  vDiffGew  : float;
  vDiffNet  : float;
  vDiffBrut : float;
  vDiffM    : float;
  vL        : float;
  vAlles    : logic;
  vTlgErr   : int;
  vKGMM_Kaputt  : logic;
end;
begin
  if (BAG.IO.Materialnr=0) then RETURN false;
  if (BAG.IO.BruderID<>0) then RETURN false;

  Erx # Mat_Data:Read(BAG.IO.Materialnr);
  if (Erx<>200) then begin
    Msg(701039,'',0,0,0);
    RETURN false;
  end;

  if (Mat.EigenmaterialYN) then RETURN false;

  Erx # RecLink(818,200,10,_RecFirst);    // Verwiegungsart holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;


  // Alte Mengen herstellen...
  Mat.Gewicht.Netto   # BAG.IO.Ist.In.GewN;
  Mat.Gewicht.Brutto  # BAG.IO.Ist.In.GewB;
  Mat.Bestand.Stk     # BAG.IO.Ist.In.Stk;

  RecBufClear(202);
  "Mat.B.Trägertyp"       # c_Akt_BA_Einsatz;
  "Mat.B.Trägernummer1"   # BAG.IO.Nummer;
  "Mat.B.Trägernummer2"   # BAG.IO.ID;
  Erx # RecRead(202,3,0);   // Bestandsbuch lesen
  if (Erx>_rMultikey) then RETURN false;

  vDat              # Mat.B.Datum;
  vTim              # Mat.B.Zeit;
  Mat.Bestand.Gew   # - Mat.B.Gewicht;
//  Mat.Bestand.Stk   # at.Bestand.Stk - "Mat.B.Stückzahl";
  Mat.Bestand.Menge # - Mat.B.Menge;
/*
  Mat.EK.Preis          # Mat.EK.Preis - Mat.B.PreisW1;
  Mat.EK.Effektiv       # Mat.EK.Effektiv - Mat.B.PreisW1;
  Mat.EK.PreisProMEH    # Mat.EK.PreisProMEH - Mat.B.PreisW1ProMEH;
  Mat.EK.EffektivProME  # Mat.EK.EffektivProME - Mat.B.PreisW1ProMEH;
*/

  PtD_Main:Memorize(200);

  vStk      # Mat.Bestand.Stk;
  vGew      # Mat.Bestand.Gew;
  vMenge    # Mat.Bestand.Menge;
  vNetto    # Mat.Gewicht.Netto;
  vBrutto   # Mat.Gewicht.Brutto;
  vPreis    # Mat.EK.Preis;
  vPreisPM  # Mat.EK.PreisProMEH;

  if (Dlg_Standard:Mat_Bestand(var vStk, var vNetto, var vBrutto, var vPreis, var vMenge, var vA, var Mat.Eingangsdatum,n, '',y)=false) then begin
    PtD_Main:Forget(200);
    RETURN false;
  end;

  Mat.Gewicht.Netto   # vNetto;
  Mat.Gewicht.Brutto  # vBrutto;
  Mat.Bestand.Stk     # vStk;


  // 10.04.2013 VORLÄUFIG:
  if (Mat.MEH='Stk') or (Mat.MEH='kg') or (Mat.MEH='t') then   // 2023-01-26 AH
    vMenge # Mat_Data:MengeVorlaeufig(vStk, vNetto, vBrutto);
  Mat.Bestand.Menge   # vMenge;

  if (VwA.NettoYN) then begin
    vPreisPM  # vNetto * vPreis / 1000.0;
    vGew # vNetto;
  end
  else begin
    vPreisPM  # vBrutto * vPreis / 1000.0;
    vGew # vBrutto;
  end;
  Mat.Bestand.Gew # vGew;
  DivOrNull(vPreisPM, vPreisPM, vMenge, 2);

  vDiffStk  # vStk - ProtokollBuffer[200]->Mat.Bestand.Stk;
  vDiffGew  # vGew - ProtokollBuffer[200]->Mat.Bestand.Gew;
  vDiffNet  # vNetto - ProtokollBuffer[200]->Mat.Gewicht.Netto;
  vDiffBrut # vBrutto - ProtokollBuffer[200]->Mat.Gewicht.Brutto;
  vDiffM    # vMenge - ProtokollBuffer[200]->Mat.Bestand.Menge;

  TRANSON;

  // Ankerfunktion
  RunAFX('Mat.Bestandsänderung',AInt(vStk)+'|'+ANum(vNetto,Set.Stellen.Gewicht)+'|'+ANum(vBrutto,Set.Stellen.Gewicht)+'|'+ANum(vPreis,2));

  // alte Bestandsänderung löschen
  RekDelete(202,0,'AUTO');

  //stk, gew, menge, p,ppm
  Mat_Data:Bestandsbuch(vDiffStk,
                        vDiffGew,
                        vDiffM,
                        vPreis - ProtokollBuffer[200]->Mat.EK.Preis,
                        vPreisPM - ProtokollBuffer[200]->Mat.EK.PreisProMEH,
                        vA, vDat, vTim, '');

  PtD_Main:Compare(200);

  // Preis vererben...
  if (Mat_A_Data:Vererben()=false) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN false;
  end;

  // neue Bestandsänderung eintragen
  Mat_Data:Bestandsbuch(-vStk, -vGew, 0.0, 0.0, 0.0, c_AKt_BA+' '+AInt(BAG.IO.Nummer)+'/'+AInt(BAG.IO.ID), vDat, vTim, c_akt_BA_Einsatz, BAG.IO.Nummer, BAG.IO.ID);

  // Restkarte anpassen...
  Erx # Mat_Data:Read(BAG.IO.MaterialRstnr);
  if (Erx<>200) or ("Mat.Löschmarker"<>'') then begin
    TRANSBRK;
    Msg(701039,'',0,0,0);
    RETURN false;
  end;
  Erx # RecRead(200,1,_recLock);
  Mat.Bestand.Gew     # Mat.Bestand.Gew + vDiffGew;
  Mat.Bestand.Stk     # Mat.Bestand.Stk + vDiffStk;
  Mat.Bestand.Menge   # Mat.Bestand.Menge + vDiffM;
  Mat.Gewicht.Netto   # Mat.Gewicht.Netto + vDiffNet;
  Mat.Gewicht.Brutto  # Mat.Gewicht.Brutto + vDiffBrut;
  Erx # Mat_Data:Replace(_recunlock,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN false;
  end;

  // BA.Input anpassen...
  if (BAG.IO.Plan.In.Stk=BAG.IO.Plan.Out.Stk) and
    (BAG.IO.Plan.In.Menge=BAG.IO.PLan.Out.Meng) and
    (BAG.IO.Plan.In.GewN=BAG.IO.Plan.Out.GewN) and
    (BAG.IO.Plan.In.GewB=BAG.IO.Plan.Out.GewB) then vAlles # y;
  Erx # RecRead(701,1,_recLock);
  BAG.IO.Plan.In.Stk    # BAG.IO.Plan.In.Stk + vDiffStk;
  BAG.IO.Plan.In.GewB   # BAG.IO.Plan.In.GewB + vDiffBrut;
  BAG.IO.Plan.In.GewN   # BAG.IO.Plan.In.GewN + vDiffNet;
  if (BAG.IO.MEH.IN=Mat.MEH) then begin
    BAG.IO.Plan.In.Menge # BAG.IO.Plan.In.Menge + vDiffM;
  end
  else if (BAG.IO.MEH.In='qm') then begin
    vL # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Stk, BAG.IO.Dicke, BAG.IO.Breite, Mat.Dichte, "Wgr.TränenKgProQM");
    BAG.IO.Plan.In.Menge  # Rnd( cnvfi(BAG.IO.Plan.In.Stk) * BAG.IO.Breite * vL / 1000000.0 , Set.Stellen.Menge);
  end
  else if (BAG.IO.MEH.In='m') then begin
    BAG.IO.Plan.In.Menge # Lib_Einheiten:WandleMEH(200, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, 0.0, '', BAG.IO.MEH.Out);
  end
  else if (BAG.IO.MEH.In='kg') then begin
    BAG.IO.Plan.In.Menge  # BAG.IO.Plan.In.GewN;
  end;
  BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
  BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
  BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
  BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;

  if (vAlles) then begin
    BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
    BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
    BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
    BAG.IO.Plan.Out.Meng  # BAG.IO.PLan.In.Menge;
  end;

  Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN false;
  end;


  // Output aktualisieren
  if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
    TRANSBRK;
    Error(701010,'');
    ErrorOutput;
    RETURN false;
  end;


  // Output aktualisieren
  if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
    TRANSBRK;
    Error(701010,'');
    ErrorOutput;
    RETURN false;
  end;


  // Input: Weiterbearbeitung oder Material...
  if (vTlgErr=0) then begin
    if (BA1_IO_data:Autoteilung(var vKGMM_Kaputt)=false) then begin
      if (Set.BA.AutoT.NurWarn=false) then begin
        TRANSBRK;
        ErrorOutPut;
        RETURN false;
      end
      else begin
        vTlgErr # 1;
      end;
    end;
  end;

  if ("BAG.P.Typ.1In-1OutYN") then begin
    BA1_P_Data:ErrechnePlanmengen();
  end;

  TRANSOFF;


  if (vKGMM_Kaputt) then begin
    Msg(703006,aint(BAG.P.Position),_WinIcoWarning, _WinDialogOk, 0);
  end;

  ErrorOutput;

  if (vTLGErr<>0) then begin
  end
  else begin
    Msg(999998,'',0,0,0);
  end;

  RETURN true;
end;

//========================================================================