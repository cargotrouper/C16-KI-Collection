@A+
//===== Business-Control =================================================
//
//  Prozedur  BA1_Z_Data
//                    OHNE E_R_G
//  Info
//
//
//  18.09.2018  AH  Erstellung der Prozedur
//  23.10.2018  AH  Neu: "TimeCalc" berechnet Kosten aus Ressource
//  10.05.2021  ST  Fix: "timeCalc" v160 bei Rso.Preis...
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//  sub TimeCalc()
//  sub Insert() : int;
//
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
//
//
//========================================================================
sub TimeCalc()
local begin
  Erx         : int;
  vStd        : float;
  vZeitpunkt  : float;   // für Berechnung der Start/End-Zeiten
  vCT         : caltime;
  v160        : int;
end;
begin

  if (BAG.Z.Dauer > 0.0) AND (BAG.Z.EndZeit<>0:0:0) then begin
    // --------------------------------
    // Starttermin errechnen
    if ((BAG.Z.EndDatum<>0.0.0) and (BAG.Z.StartDatum = 0.0.0) and (BAG.Z.Dauer > 0.0))then begin
      vCT->vpDate # BAG.Z.EndDatum;
      vCT->vpTime # BAG.Z.EndZeit;
      vCT->vmSecondsModify(- cnvif(BAG.Z.Dauer) * 60);
      BAG.Z.Startdatum  # vCT->vpDate;
      BAG.Z.StartZeit   # vCT->vpTime;
/***
        // Enddatum + Endzeit = Endzeitpunkt, von dem die Dauerabgezogen wird (in Minuten)
        vZeitpunkt # CnvFi((Cnvid(Bag.Z.EndDatum) * 24 * 60) + (CnvIT(Bag.Z.EndZeit) / 1000 / 60));

        // vom Zeitpunkt Dauer (in Minuten) abziehen
        vZeitpunkt # vZeitpunkt - (BAG.Z.Dauer /* *60 */ ) ;

        // Tages Zeitpunktes zurückrechnen
        BAG.Z.StartDatum # CnvDi(CnvIf(floor(vZeitpunkt / 24.0 / 60.0)));

        // EndDatum abziehen, um kleineren Wert zu erhalten
        vZeitpunkt # vZeitpunkt - CnvFi((Cnvid(Bag.Z.EndDatum) * 24 * 60));
        vZeitpunkt # vZeitpunkt * 60.0 * 1000.0;      // Restzeit in Millisekunden umrechnen

        // GGf. Tagesüberlauf beachten
        if (BAG.Z.StartDatum < BAG.Z.EndDatum) then begin
          BAG.Z.StartZeit #  CnvTi(CnvIf((24.0*60.0*60.0*1000.0) + vZeitpunkt));
        end
        else
          BAG.Z.StartZeit #  CnvTi(CnvIf(vZeitpunkt));
***/
    End;
  End;

  if ((BAG.Z.StartDatum > 0.0.0) and (BAG.Z.EndDatum = 0.0.0) and (BAG.Z.Dauer > 0.0)) then begin
    vCT->vpDate # BAG.Z.StartDatum;
    vCT->vpTime # BAG.Z.StartZeit;
    vCT->vmSecondsModify(cnvif(BAG.Z.Dauer) * 60);
    BAG.Z.Enddatum  # vCT->vpDate;
    BAG.Z.EndZeit   # vCT->vpTime;
/***
      // Enddatum + Endzeit = Endzeitpunkt, von dem die Dauerabgezogen wird (in Minuten)
      vZeitpunkt # CnvFi((Cnvid(Bag.Z.StartDatum) * 24 * 60) + (CnvIT(Bag.Z.StartZeit) / 1000 / 60));
      // vom Zeitpunkt Dauer (in Minuten) addieren um Endzeitpunkt zu erhalten
      vZeitpunkt # vZeitpunkt + (BAG.Z.Dauer /* * 60.0 */ ) ;

      // Tages Zeitpunktes zurückrechnen
      BAG.Z.EndDatum # CnvDi(CnvIf(floor(vZeitpunkt / 24.0 / 60.0)));

      // Startdatum abziehen, um kleineren Wert zu erhalten
      vZeitpunkt # vZeitpunkt - CnvFi((Cnvid(Bag.Z.StartDatum) * 24 * 60));
      vZeitpunkt # vZeitpunkt * 60.0 * 1000.0;      // Restzeit in Millisekunden umrechnen

      // GGf. Tagesüberlauf beachten
      if (BAG.Z.StartDatum <> BAG.Z.EndDatum) then begin
        BAG.Z.EndZeit #  CnvTi(CnvIf( vZeitpunkt - (24.0*60.0*60.0*1000.0)));
      end
      else
        BAG.Z.EndZeit #  CnvTi(CnvIf(vZeitpunkt));
***/
  end;

  if (/*BAG.Z.Dauer = 0.0 and */ BAG.Z.Startzeit <> 0:0:0 and BAG.Z.EndZeit <> 0:0:0) then begin
    // Dauer errechnen
    if(BAG.Z.StartDatum<>0.0.0) and (BAG.Z.EndDatum<>0.0.0) /*and (BAG.Z.Dauer = 0.0)*/ then begin
/*
      vStd # cnvfi( (CnvID(BAG.Z.StartDatum) - cnvID(1.1.2000)) * 24 );
      vStd # vStd + (cnvfi(Cnvit(BAG.Z.StartZeit)) /(1000.0*60.0));
      BAG.Z.Dauer # Rnd(vStd,2);

      vStd # cnvfi( (CnvID(BAG.Z.EndDatum) - cnvid(1.1.2000)) * 24 );
      vStd # vStd + (cnvfi(Cnvit(BAG.Z.EndZeit)) /(1000.0*60.0));
      BAG.Z.Dauer # Rnd(Rnd(vStd,2) - BAG.Z.Dauer,2);
*/
      vStd # cnvfi( (CnvID(BAG.Z.StartDatum) - cnvID(1.1.2000)) * 24 * 60 );
      vStd # vStd + (cnvfi(Cnvit(BAG.Z.StartZeit) / 1000 / 60));
      BAG.Z.Dauer # Rnd(vStd,2);

      vStd # cnvfi( (CnvID(BAG.Z.EndDatum) - cnvid(1.1.2000)) * 24 * 60 );
      vStd # vStd + (cnvfi(Cnvit(BAG.Z.EndZeit) / 1000 / 60));
      BAG.Z.Dauer # Rnd(Rnd(vStd,2) - BAG.Z.Dauer,2);

      if (BAG.Z.Dauer < 0.0) then
        BAG.Z.Dauer # 0.0;
    end;
  end;

  // 22.10.2018 AH
  if (BAG.Z.Ressource<>0) then begin
    v160 # RecBufCreate(160);
    Erx # RecLink(v160,709,5,_RecFirst);    // Ressource holen
    if (Erx<=_rLocked) then begin
      // ST 2021-05-10 Bugfix: v160 bei RspPreis...
      //BAG.Z.GesamtkostenW1 # Rso.PreisProH * (BAG.Z.Dauer / 60.0);
      BAG.Z.GesamtkostenW1 # v160->Rso.PreisProH * (BAG.Z.Dauer / 60.0);
    end;
    RecBufDestroy(v160);
  end;
end;


//=========================================================================
//=========================================================================
sub Insert() : int;
local begin
  Erx : int;
end;
begin
  Timecalc();
  BAG.Z.Anlage.Datum  # Today;
  BAG.Z.Anlage.Zeit   # Now;
  BAG.Z.Anlage.User   # gUserName;
  REPEAT
    Erx # RekInsert(709,0,'MAN');
    if (Erx<>_rOK) then begin
      inc(BAG.Z.lfdNr);
      CYCLE;
    end;
  UNTIL Erx=_rOK;

  RETURN Erx;
end;


//========================================================================