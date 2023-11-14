@A+
//===== Business-Control =================================================
//
//  Prozedur  BA1_FM_Theo_Subs
//                    OHNE E_R_G
//  Info
//
//
//  09.10.2018  AH  Erstellung der Prozedur
//  07.11.2018  AH  Etikettendruck außerhalb der Transaktion
//  05.03.2019  AH  BA-Abschluss schließt Vorgänger-Fahren automatisch ab
//  04.11.2021  ST  Fix: Theoretische FM belegt bei FM wieder 999 vor 2166/98/1
//  18.11.2021  ST  Fix: TheoFM mit mehreren Fertigngen restored die Restkarte für Ausführungsüber. 2116/180
//  05.04.2022  AH  ERX
//  2022-12-20  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//  sub FMTheorie(aBA : int; opt aBAPos : int; opt aDatum : date; opt aSilent : logic; opt aKeinAbschluss : logic; opt aEtikett : logic) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG

define begin
end;

//========================================================================
//  FMTheorie                                     ST 2009-07-30 P.1161/86
//  Meldet eine Betriebsauftragsposition mit den geplanten Werten fertig
//  Fehler: - nimmt Ausführungen nicht mit
//          - wenn Vorgänger andere Anzahl an Wiegungen erzeugt (Z.B. 5+5 statt 10),
//              stimmt Abstammung im Material nicht (Wird immer von 1. Input gezogen)
//          - wenn Vorgänger andere Menge wiegt, kommt trotzdem immer die theoretische Outputmenge raus
//========================================================================
sub xxxFMTheorie(
  aBA             : int;
  opt aBAPos      : int;
  opt aDatum      : date;
  opt aSilent     : logic;
  opt aKeinAbschluss  : logic;
  opt aEtikett    : logic;
) : logic;
local begin
  Erx         : int;
  vMsgPara    : alpha;
  vFlagInput  : int;
  vFlagOutput : int;
  vFlagFert   : int;
  vHdlOutput  : int;
  vHdlInput   : int;
  vHdlPos     : int;
  vHdlPos2    : int;
  vHdlFert    : int;
  vFertBrk    : logic;
  vMitEtk     : logic;
  vDoneInputs : alpha(4000);
  vOk         : logic;
  vAfxPara    : alpha;
  vVorFahren  : int;
end
begin DoLogProc;

  vAfxPara #   Cnvai(aBA)+ '|' + Cnvai(aBAPos) + '|' + CnvaD(aDatum) + '|';
  if (aSilent) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (aKeinAbschluss) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (aEtikett) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (RunAFX('BAG.FM.FMTheorie',vAfxPara)<>0) then RETURN (AfxRes=_rOK);

  // ---------------------------------------
  begin // BA Daten lesen
    // BA Kopf lesen
    BAG.Nummer # aBA;
    Erx # RecRead(700,1,0);
    if (Erx>_rLocked) then RETURN false;

    // BA Position lesen
    BAG.P.Nummer   # aBA;
    BAg.P.Position # aBAPos;
    Erx # RecRead(702,1,0);
    if (Erx>_rLocked) then begin
      BAG.P.Position # BA1_Fertigmelden:ChoosePos();
      if (BAG.P.Position=0) then RETURN false;
    end;
    // Position zur Sicherheit erneut lesen
    RecRead(702,1,0);
    if ("BAG.P.Typ.xIn-yOutYN") then begin
      Msg(702033,'',0,0,0);
      RETURN true;
    end;
  end; // BA Daten lesen


  // ---------------------------------------
  // Benutzerbestätigung
  begin
    // Wirklich theoretisch fertigmelden?
    if (!aSilent) then begin
      vMsgPara  # Bag.P.Bezeichnung + '|'+ AInt(Bag.P.Nummer);
      if (Msg(702022,vMsgPara,_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;

      vMitEtk # (Msg(702023,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes);
      if (aDatum=0.0.0) then aDatum # today;
      if (Dlg_Standard:Datum(Translate('Verbuchungsdatum'), var aDatum, aDatum)=false) then RETURN false;
    end
    else begin
      vMitEtk # aEtikett;
      if (aDatum=0.0.0) then aDatum # today;
    end;

  end; // Benutzerbestätigung


  // ---------------------------------------
  // Validierung der Ba Position
  // darf die Position fertigegemeldet werden?
  begin

    // BA schon fertig??
    if (BAG.Fertig.Datum<>0.0.0) then begin
      if (!aSilent) then
        Msg(702008,'',0,0,0);
      RETURN false;
    end;

    // VSB-Position? -> Kann nicht fertiggemeldet werden!
    if (BAG.P.Typ.VSBYN) then begin
      if (!aSilent) then
        Error(702008,'');
      RETURN false;
    end;

    if ("BAG.P.Typ.xIn-yOutYN") then begin
      if (!aSilent) then
        Error(702033,'');
      RETURN false;
    end;

    // Fahraufträge werden über Lieferschein fertiggemeldet
    if (BAG.P.Aktion=c_BAG_Fahr) OR (BAG.P.Aktion=c_BAG_Versand) then begin
      if (!aSilent) then
        Error(702014,'');
      RETURN false;
    end;

    // nur BA Positionen fertigmelden,
    // die noch nicht fertiggemeldet sind
    if (BAG.P.Fertig.Dat<>0.0.0) then begin
      if (!aSilent) then
        Msg(702009,'',0,0,0);
      RETURN false;
    end;

    // Wurde schon verwogen? Abfrage nur über Anzahl der Fertigmeldungen
    vMsgPara # CnvAi(RecLinkInfo(707,702,5,_RecCount));
    if (RecLinkInfo(707,702,5,_RecCount) > 0) then begin
      if (!aSilent) then
        Msg(702008,'',0,0,0);
      RETURN false;
    end;


    // Vorgängercheck
    vOK # BA1_P_Data:SindVorgaengerAbgeschlossen(var vVorFahren, false);
    // Mindestens ein Vorgänger ist noch nicht fertiggemeldet
    if (!vOK) then begin
      if (!aSilent) then
        Msg(702024,'',0,0,0);
      RETURN false;
    end;

  end; // Validierung der Ba Position

  TRANSON;

  // -------------------------------------
  // Theoretische Fertigmeldung

  // Alle Einsätze durchlaufen
  vFlagInput # _RecFirst;
  WHILE (RecLink(701,702,2,vFlagInput) <= _rLocked) DO BEGIN
    vFlagInput # _RecNext;

    // Nur echte Einsätze zum Fertigmelden beachten
    if (BAG.IO.Materialtyp <> c_IO_MAT) then
      CYCLE;

    // Aktuellen Einsatz merken
    vHdlInput # RekSave(701);

    // Position lesen
    Bag.P.Nummer   # Bag.IO.NachBAG;
    Bag.P.Position # Bag.IO.NachPosition;
    Erx # RecRead(702,1,0);
    if (Erx > _rLocked) then begin
      TRANSBRK;
      if (!aSilent) then
        Msg(700003,AInt(Bag.IO.NachPosition),0,0,0);
      RETURN false;
    end;

    // Fertigungen lesen
    vFlagFert # _RecFirst;
    REPEAT

      // Da ein Einsatz einer festen Fertigung zugeordnet werden kann (...IO.NachFertig...<>0)
      // ist es in diesem Fall nicht nötig, alle Fertigungen der Position zu durchlaufen.
      // Hier reicht das einfache Lesen der Fertigung. Im anderen Fall (IO.NachFert..=0) hingegen
      // bezieht sich der Einsatz auf alle hinterlegten Fertigungen
      if (vHdlInput->BAG.IO.NachFertigung <> 0) then begin

        // eine spezielle Fertigung lesen
        Erx # RecLink(703,701,10,0);
        if (Erx <= _rLocked) then
          vHdlFert # RekSave(703);

        // Wiederholung nach dieser Fertigung abbrechen
        vFertBrk # true;
      end
      else begin
        // Alle Fertigungen durchgehen
        Erx # RecLink(703,702,4,vFlagFert);
        vFertBrk # (Erx >_rLocked);
        if (vFertBrk) then
          BREAK;
        vFlagFert # _RecNext;
      end;

      // Fertigung geladen
      vHdlFert # RekSave(703);

      // Verpackung lesen
      Erx # RecLink(704,703,6,_recfirst);
      if (Erx>_rLockeD) then RecBufClear(704);

      // Jeden Output durchlaufen
      vFlagOutput # _RecFirst;
      WHILE (RecLink(701,703,4,vFlagOutput) <= _rLocked) DO BEGIN
        vFlagOutput # _RecNext;

        // nur Echte Outputs anlegen
        if (BAG.IO.Materialtyp <> c_IO_BAG) then
          CYCLE;

        if (BAG.IO.VonID <> vHdlInput->BAG.IO.ID) and (BAG.IO.VonID<>0) and (BAG.IO.VonID<>vHdlInput->BAG.IO.BruderID) then
//        if (BAG.IO.VonID <> vHdlInput->BAg.IO.ID) and (BAG.IO.VonID<>0) then
          CYCLE;

        // Output merken
        vHdlOutput # RekSave(701);

        // Prüfen, ob dieser Output schon von einem anderen Einsatzmaterial
        // fertigegemeldet wurde
        if (StrFind(vDoneInputs, CnvAi(BAG.IO.ID,_FmtNumNoGroup | _FmtNumLeadZero,0,4) +';',0) > 0) then
          CYCLE;

        // -----------------------------------
        // FM Daten vorbelegen
        begin
          // Hauptdaten
          BAG.FM.Nummer           # myTmpNummer;
          BAG.FM.Fertigmeldung    # 999;    // 24.03.2015
          BAG.FM.Position         # BAG.F.Position;
          BAG.FM.Fertigung        # BAG.F.Fertigung;
          BAG.FM.Fertigmeldung    # 0;                // laufende Nummer kommt beim Verbuchen
          BAG.FM.InputBAG         # vHdlInput->BAG.IO.Nummer
          BAG.FM.InputID          # vHdlInput->BAG.IO.ID;
          BAG.FM.OutPutID         # vHdlOutput->BAG.IO.ID;
          BAG.FM.BruderID         # vHdlOutput->Bag.IO.ID;
          BAG.FM.Menge            # vHdlOutput->BAG.IO.Plan.In.Menge;

//          BAG.FM.MEH              # vHdlOutput->BAG.IO.MEH.In;
          BAG.FM.MEH              # BAG.F.MEH;
          "BAG.FM.Stück"          # vHdlOutput->BAG.IO.Plan.In.Stk;
          BAG.FM.Gewicht.Netto    # vHdlOutput->BAG.IO.Plan.In.GewN;
          BAG.FM.Gewicht.Brutt    # vHdlOutput->BAG.IO.Plan.In.GewB;
          BAG.FM.Verwiegungart    # BAG.Vpg.Verwiegart;
          BAG.FM.Materialtyp      # vHdlInput->BAG.IO.Materialtyp;
          BAG.FM.Status           # 1;
          BAG.FM.Bemerkung        # vHdlOutput->BAG.IO.Bemerkung;
          BAG.FM.Lagerplatz       # '';               // ???
          BAG.FM.Datum            # aDatum;

          // Materialdaten
          BAG.FM.Materialnr       # 0;                // sollte vom Verbuchen kommen
          BAG.FM.Dicke            # vHdlOutput->BAG.IO.Dicke;
          BAG.FM.Breite           # vHdlOutput->BAG.IO.Breite;
          "BAG.FM.Länge"          # vHdlOutput->"BAG.IO.Länge";
    /*      BAG.FM.Rechtwinklig     # ???
          BAG.FM.Ebenheit         # ???
          BAG.FM.Säbeligkeit      # ???
          BAG.FM.Dicke.3          # ???
          BAG.FM.Breite.3         # ???
          BAG.FM.Länge.3          # ???
          BAG.FM.Grat.Von         # ???
          BAG.FM.Grat.Bis         # ???
          BAG.FM.Grat.3           # ???
          BAG.FM.Werksnummer      # ???  */
          BAG.FM.AusfOben         # vHdlOutput->BAG.IO.AusfOben;
          BAG.FM.AusfUnten        # vHdlOutput->BAG.IO.AusfUnten;

          // Artikeldaten
          if (false )then begin
            BAG.FM.Artikelnr #  vHdlOutput->BAG.IO.Artikelnr;
          end;

        end; // FM Daten vorbelegen

        // FM Anlegen, ohne Etk
        if (!BA1_Fertigmelden:Verbuchen(vMitEtk)) then begin
          TRANSBRK;
          RETURN false;
        end;


        RecBufCopy(vHdlOutput,701);
        RekRestore(vHdlOutput);

        // Verbuchten Output merken, damit bei mehreren Einsatzmaterialien
        // keine Doppelverbuchungen von Fertigmaterialien entstehen
        vDoneInputs # vDoneInputs + CnvAi(BAG.IO.ID,_FmtNumNoGroup | _FmtNumLeadZero,0,4) +';';

      END; //Jeden Output durchlaufen

      // gemerkter Fertigungspuffer wieder löschen
      RecBufCopy(vHdlFert,703); // Gespeicherte Fertigung wieder lesen
      RekRestore(vHdlFert);
    UNTIL (vFertBrk); // Fertigungen lesen

    // gemerkter Einsatzpuffer wieder löschen
    RekRestore(vHdlInput);
  END;

  // Wenn alles IO, dann Position abschließen
  if (!aKeinAbschluss) then
    BA1_Fertigmelden:AbschlussPos(Bag.FM.Nummer, BAG.FM.Position, aDatum, now, true);

  TRANSOFF;

  vAfxPara #   Cnvai(aBA)+ '|' + Cnvai(aBAPos) + '|' + CnvaD(aDatum) + '|';
  if (aSilent) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (aKeinAbschluss) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (vMitEtk) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  RunAFX('BAG.FM.FMTheorie.Post',vAfxPara);

  RETURN true;  // Alles OK
end;


//========================================================================
//========================================================================
sub _SetAusfuehrung()
local begin
  Erx           : int;
  vNimmAlteAusf : logic;
  vFilter       : int;
  vBuf705       : int;
  vSeite        : alpha;
  vI            : int;
end;
begin

  vNimmAlteAusf # true;

  if (RunAFX('BAG.FM.Vorbelegung.AusF','')<>0) then begin
    vNimmAlteAusf # (AfxRes=_rOK);
  end;

  // Ausfuehrung kopieren
  if (Mat.Nummer<>0) and (vNimmAlteAusf) then begin
    Erx # RecLink(201, 200, 11, _recFirst);
    WHILE(Erx <= _rLocked) DO BEGIN
      RecBufClear(705);
      BAG.AF.Nummer         # BAG.FM.Nummer;
      BAG.AF.Position       # BAG.FM.Position;
      BAG.AF.Fertigung      # BAG.FM.Fertigung;
      BAG.AF.Fertigmeldung  # BAG.FM.Fertigmeldung;
      BAG.AF.Seite          # Mat.AF.Seite;
      BAG.AF.lfdNr          # Mat.AF.lfdNr;
      BAG.AF.ObfNr          # Mat.AF.ObfNr;
      BAG.AF.Bezeichnung    # Mat.AF.Bezeichnung;
      BAG.AF.Zusatz         # Mat.AF.Zusatz;
      BAG.AF.Bemerkung      # Mat.AF.Bemerkung;
      "BAG.AF.Kürzel"       # "Mat.AF.Kürzel";
      RekInsert(705, 0, 'AUTO');
      Erx # RecLink(201, 200, 11, _recNext);
    END;
  end;

  vFilter # RecFilterCreate(705, 1);
  vFilter->RecFilterAdd(4, _FltAND, _FltEq, 0);
  Erx # RecLink(705, 703, 8, _recFirst, vFilter); // Ausfuehrung aus Fertigung kopieren
  //debug(cnvAI(RecLinkInfo(705, 703, 8, _recCount, vFilter))); // Ausfuehrung aus Fertigung kopieren
  vBuf705 # RecBufCreate(705);
  WHILE(Erx <= _rLocked) DO BEGIN
    RecBufCopy(705, vBuf705);

    BAG.AF.Nummer         # BAG.FM.Nummer;
    BAG.AF.Fertigmeldung  # BAG.FM.Fertigmeldung;
    Erx # RecRead(705,3,_recTest);  // existiert schon?
    if (Erx>_rMultikey) then begin
      REPEAT
        Erx # RekInsert(705,0,'AUTO');
        if (Erx<>_rOK) then BAG.AF.lfdNr # BAG.AF.lfdNr + 1;
      UNTIL (Erx=_rOK);

      Erx # RecLink(841,705,1,_recFirst);   // Obf holen
      if (Obf.Gegenteil.ObfNr<>0) then begin
        vSeite  # BAG.AF.Seite;
        vI      # BAG.AF.lfdnr;
        BAG.AF.Nummer # BAG.FM.Nummer;
        Erx # RecLink(705, 707, 13,_recFirst);  // bisherige AF loopen
        WHILE (Erx<=_rLocked) do begin
          if (BAG.AF.Seite=vSeite) and
            ((BAG.AF.ObfNr=Obf.Gegenteil.ObfNr) or
              ((Obf.Gegenteil.ObfNr=9999) and (BAG.AF.lfdNr<>vI))) then begin
            RekDelete(705,0,'AUTO');
            Erx # RecLink(705, 707, 13,_recFirst);  // bisherige AF loopen
            CYCLE;
          end;

          Erx # RecLink(705, 707, 13,_recNext);
        END;
      end;
    end;  // existiert schon?

    RecBufCopy(vBuf705, 705);
    Erx # RecLink(705, 703, 8, _recNext, vFilter);
  END;
  RecBufDestroy(vBuf705);
  RecFilterDestroy(vFilter);

  if(RecLinkInfo(705, 707, 13, _recCount) > 0) then begin // Mehr als 0 Ausfuehrungen kopiert?
    BAG.FM.AusfOben # Obf_Data:BildeAFString(707,'1');
    BAG.FM.AusfUnten # Obf_Data:BildeAFString(707,'2');
  end;
end;


//========================================================================
//========================================================================
sub _TheoWiege(
  aDatum      : date;
  aMitEtk     : logic;
  opt aTlg    : int;
  opt aEtkTxt : int;
  opt aStatus : int) : logic
local begin
  Erx         : int;
  vID         : int;
  vHdlInput   : int;
  vHdlOutput  : int;
  vL          : float;
  vGewN       : float;
  vGewB       : float;
  vMitLyse    : logic;
end;
begin
  // Verpackung lesen
  Erx # RecLink(704,703,6,_recfirst);
  if (Erx>_rLocked) then RecBufClear(704);

  // Aktuellen Einsatz merken
//debug('Input KEY701 nach Fert:'+aint(BAG.IO.NachFertigung)+'  mit '+aint(BAG.IO.Plan.Out.Stk)+'Stk und kg'+anum(BAG.IO.Plan.Out.GewN,0));
  vHdlInput # RekSave(701);

  // passenden Output finden
  vID # vHdlInput->BAG.IO.ID;
  if (vHdlInput->BAG.IO.BruderID>0) then
    vID # vHdlInput->BAG.IO.BruderID;
  
//    vOk # (BAG.IO.BruderID=0) and (BAG.IO.MaterialTyp=c_IO_BAG) and
//      ( (BAG.IO.VonID=vID) or (vID=0) or (BAG.IO.VonId=0)) ;
  FOR Erx # RecLink(701,703,4,_recFirst)
  LOOP Erx # RecLink(701,703,4,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.Materialtyp=c_IO_BAG) and (BAG.IO.BruderID=0) and
      ((BAG.IO.VonId=vID) or(BAG.IO.VonId=0)) then begin
//debugx('output KEY701');
      vHdlOutput # RekSave(701);
    end;
  END;
  if (vHdlOutput=0) then begin
    RekRestore(vHdlInput);
    RETURN false;
  end;
  
  // -----------------------------------
  // Fertigmeldung füllen...
  BAG.FM.Nummer           # myTmpNummer;
  BAG.FM.Fertigmeldung    # 999;
  BAG.FM.Position         # BAG.F.Position;
  BAG.FM.Fertigung        # BAG.F.Fertigung;
  // ST 2021-11-04 BUGFIX 2166/98/1: Vorbelegung bei 999 belassen
  //BAG.FM.Fertigmeldung    # 0;                // laufende Nummer kommt beim Verbuchen
  BAG.FM.InputBAG         # vHdlInput->BAG.IO.Nummer
  BAG.FM.InputID          # vHdlInput->BAG.IO.ID;
  
  BAG.FM.OutputID         # vHdlOutput->BAG.IO.ID;
  BAG.FM.BruderID         # vHdlOutput->Bag.IO.ID;
  BAG.FM.Verwiegungart    # BAG.Vpg.Verwiegart;
  if (BAG.P.Aktion=c_BAG_Check) then          // 03.05.2022 AH
    BAG.FM.Verwiegungart  # Mat.Verwiegungsart;
  BAG.FM.Materialtyp      # c_IO_Mat;
  BAG.FM.Status           # 1;
  if (aStatus<>0) then
    BAG.FM.Status         # aStatus;
  BAG.FM.Bemerkung        # vHdlOutput->BAG.IO.Bemerkung;
  BAG.FM.Datum            # aDatum;
  BAG.FM.Teilung          # aTlg;

  // Materialdaten
  _SetAusfuehrung();
  BAG.FM.Dicke            # vHdlOutput->BAG.IO.Dicke;
  BAG.FM.Breite           # vHdlOutput->BAG.IO.Breite;
  "BAG.FM.Länge"          # vHdlOutput->"BAG.IO.Länge";
  BAG.FM.AusfOben         # vHdlOutput->BAG.IO.AusfOben;
  BAG.FM.AusfUnten        # vHdlOutput->BAG.IO.AusfUnten;
  BAG.FM.MEH              # vHdlOutput->BAG.IO.MEH.Out;
  if ("BAG.P.Typ.1In-1OutYN"=false) then  begin // 2022-12-20 AH
    BAG.FM.MEH            # BAG.F.MEH;
  end;
 
  // 07.05.2021 AH:
  if ("BAG.P.Typ.1In-1OutYN") then begin
    vGewN                 # vHdlInput->BAG.IO.Plan.Out.GewN;
    vGewB                 # vHdlInput->BAG.IO.Plan.Out.GewB;
    "BAG.F.Stückzahl"     # vHdlInput->BAG.IO.Plan.Out.Stk;
    Erx # RecLink(704,703,6,_recfirst);     // Verpackung holen
    if (Erx>_rLockeD) then RecBufClear(704);
    if (VwA.Nummer<>BAG.Vpg.Verwiegart) then begin
      Erx # RekLink(818,704,1,_recfirst);     // Verwiegungsart holen
      if (Erx>_rLocked) then VwA.NettoYN # y;
    end;
    if (VWa.NettoYN) then
      BAG.F.Gewicht         # vGewN
    else
      BAG.F.Gewicht         # vGewB;
    BAG.F.Menge           # vHdlInput->BAG.IO.Plan.Out.Meng;
//debugx('in:'+aint(vHdlInput->BAG.IO.ID)+'  M:'+anum(vHdlInput->BAG.IO.Plan.In.Menge,0)+'>'+anum(vHdlInput->BAG.IO.Plan.Out.Meng,0));
//    if (BAG.F.MEH='t') then
//      BAG.F.Menge         # Rnd(vHdlInput->BAG.IO.Plan.Out.GewN/1000.0, Set.Stellen.Menge)
//    else if (BAG.F.MEH='kg') then
//      BAG.F.Menge         # vHdlInput->BAG.IO.Plan.Out.GewN;
  end;
//debugx(anum(BAG.F.menge,0));

  RecBufDestroy(vHdlOutput);
  RecBufCopy(vHdlInput,701);

  BA1_F_Data:ErrechnePlanmengen(y,y,y,y);   // pumpt in FERTIGUNG
  "BAG.FM.Stück"          # "BAG.F.Stückzahl";
  BAG.FM.Gewicht.Netto    # BAG.F.Gewicht;
  BAG.FM.Gewicht.Brutt    # BAG.F.Gewicht;
  if ("BAG.P.Typ.1In-1OutYN") then begin    // 12.05.2021 AH
    BAG.FM.Gewicht.Netto    # vGewN;
    BAG.FM.Gewicht.Brutt    # vGewB;
  end;
  BAG.FM.Menge            # BAG.F.Menge;
  RecRead(703,1,0);                         // Restore
  
  // 15.12.2021 AH
  if ("BAG.FM.Stück"<0) or (BAG.FM.Gewicht.Netto<0.0) then begin
    RekRestore(vHdlInput);
    RETURN false;
  end;
  "BAG.FM.Stück" # Max("BAG.FM.Stück",1);   // 15.12.2021 AH
  
  // FM Anlegen, ohne Etk
//  if (!BA1_Fertigmelden:Verbuchen(aMitEtk,n,n, aEtkTxt)) then begin

  // 25.05.2021 AH:
  vMitLyse # (BAG.P.Aktion=c_BAG_Messen);
  if (vMitLyse) then begin
    RecbufClear(231);
    RecbufClear(230);
    Lys_Data:VorbelegenVonMatAnalyse();
  end;

  if (!BA1_Fertigmelden:Verbuchen(aMitEtk, vMitLyse,n, aEtkTxt, true)) then begin
    RekRestore(vHdlInput);
    RETURN false;
  end;

  RekRestore(vHdlInput);

  RETURN True;
end;


//========================================================================
//  FMTheorie                                     AH  09.10.2018
//  Meldet eine Betriebsauftragsposition mit den geplanten Werten fertig
//========================================================================
sub FMTheorie(
  aBA               : int;
  opt aBAPos        : int;
  opt aDatum        : date;
  opt aSilent       : logic;
  opt aKeinAbschluss  : logic;
  opt aEtikett      : logic;
  opt aStatus       : int;
  opt aAutoRekursiv : int;
) : logic;
local begin
  Erx         : int;
  vMsgPara    : alpha;
  vHdlOutput  : int;
  vHdlInput   : int;
  xvHdlPos     : int;
  xvHdlPos2    : int;
  xvHdlFert    : int;
  vMitEtk     : logic;
  vOk         : logic;
  vAfxPara    : alpha;
  vErr        : alpha;
  vCount      : int;
  vEtkTxt     : int;
  vA          : alpha;
  vVorFahren  : int;
  v200RestKarte : int;
end
begin DoLogProc;

  vAfxPara #   Cnvai(aBA)+ '|' + Cnvai(aBAPos) + '|' + CnvaD(aDatum) + '|';
  if (aSilent) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (aKeinAbschluss) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (aEtikett) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (RunAFX('BAG.FM.FMTheorie',vAfxPara)<>0) then RETURN (AfxRes=_rOK);

  BAG.Nummer # aBA;
  Erx # RecRead(700,1,0);
  if (Erx>_rLocked) then RETURN false;

  // BA Position lesen
  BAG.P.Nummer   # aBA;
  BAg.P.Position # aBAPos;
  Erx # RecRead(702,1,0);
  if (Erx>_rLocked) then begin
    BAG.P.Position # BA1_Fertigmelden:ChoosePos();
    if (BAG.P.Position=0) then RETURN false;
  end;
  // Position zur Sicherheit erneut lesen
  RecRead(702,1,0);
  if ("BAG.P.Typ.xIn-yOutYN") then begin
    Msg(702033,'',0,0,0);
    RETURN true;
  end;

  // Fahraufträge werden über Lieferschein fertiggemeldet
  if (BAG.P.Aktion=c_BAG_Fahr) OR (BAG.P.Aktion=c_BAG_Versand) then begin
    if (!aSilent) then
      Error(702014,'');
    RETURN false;
  end;


  // ---------------------------------------
  // Validierung der Ba Position
  // darf die Position fertigegemeldet werden?
  // BA schon fertig??
  if (BAG.Fertig.Datum<>0.0.0) then begin
    if (!aSilent) then
      Msg(702008,'',0,0,0);
    RETURN false;
  end;

  // VSB-Position? -> Kann nicht fertiggemeldet werden!
  if (BAG.P.Typ.VSBYN) then begin
    if (!aSilent) then
      Error(702008,'');
    RETURN false;
  end;

  if ("BAG.P.Typ.xIn-yOutYN") then begin
    if (!aSilent) then
      Error(702033,'');
    RETURN false;
  end;

  // nur BA Positionen fertigmelden,
  // die noch nicht fertiggemeldet sind
  if (BAG.P.Fertig.Dat<>0.0.0) then begin
    if (!aSilent) then
      Msg(702009,'',0,0,0);
    RETURN false;
  end;

  // Wurde schon verwogen? Abfrage nur über Anzahl der Fertigmeldungen
  vMsgPara # CnvAi(RecLinkInfo(707,702,5,_RecCount));
// 11.10.2021  if (RecLinkInfo(707,702,5,_RecCount) > 0) then begin
  if (BA1_P_Data:BereitsVerwiegung(BAG.P.Aktion)) then begin    // 11.10.2021 AH
    if (!aSilent) then
      Msg(702008,'',0,0,0);
    RETURN false;
  end;


  // Vorgängercheck
  vOK # BA1_P_Data:SindVorgaengerAbgeschlossen(var vVorFahren, false, 0.0.0, aAutoRekursiv);
  // Mindestens ein Vorgänger ist noch nicht fertiggemeldet
  if (!vOK) then begin
    if (!aSilent) then
      Msg(702024,'',0,0,0);
    RETURN false;
  end;


  // ---------------------------------------
  // Wirklich theoretisch fertigmelden?
  if (!aSilent) then begin
    if (BA1_IO_I_Data:HatEinsatzReservierungen()) then begin    // 03.02.2022 AH
      if (Msg(702056,'',_WinIcoQuestion,_WinDialogOkCancel,2)<>_WinIdOK) then RETURN false;
    end;
    vMsgPara  # Bag.P.Bezeichnung + '|'+ AInt(Bag.P.Nummer);
    if (Msg(702022,vMsgPara,_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;

    vMitEtk # (Msg(702023,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes);
    if (aDatum=0.0.0) then aDatum # today;
    if (Dlg_Standard:Datum(Translate('Verbuchungsdatum'), var aDatum, aDatum)=false) then RETURN false;
  end
  else begin
    vMitEtk # aEtikett;
    if (aDatum=0.0.0) then aDatum # today;
  end;

  if (vVorFahren>0) and (!aKeinAbschluss) then begin
    vVorFahren # 0;
    vOK # BA1_P_Data:SindVorgaengerAbgeschlossen(var vVorFahren, false);
    if (!vOK) then begin
      if (!aSilent) then
        Msg(702024,'',0,0,0);
      RETURN false;
    end;
  end;


  vEtkTxt # TextOpen(16);

  TRANSON;
  APPOFF(); // 03.02.2020

  // -------------------------------------
  // Theoretische Fertigmeldung

  // Input loopen...
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) and (vErr='') do begin
    // Nur echte Einsätze zum Fertigmelden beachten
    if (BAG.IO.Materialtyp <> c_IO_MAT) then CYCLE;

    if (BA1_IO_I_Data:IstMatBeistellung()) then CYCLE;

    // Restkarte holen...
    if (BAG.IO.MaterialRstNr>0) then
      Erx # RecLink(200,701,11,_RecFirst)
    else
      Erx # RecLink(200,701,9,_RecFirst);
    if (Erx>_rLocked) then begin
      vErr # 'Material nicht gefunden';
      BREAK;
    end;

    inc(vCount);

    // genau EINE Fertigung?
    if (BAG.IO.NachFertigung<>0) then begin
      Erx # RecLink(703,701,10,0);  // NachFertigung holen
      if (Erx > _rLocked) then begin
        vErr # 'Fertigung nicht gefunden';
        BREAK;
      end;
      if (_TheoWiege(aDatum, FALSe,0, vEtkTxt, aStatus)=false) then begin      // NIE direkt Etiketten drucken
        vErr # 'Wiegungsfehler';
        BREAK;
      end;
    end
    else begin
      // Fertigungen loopen...
      FOR Erx # RecLink(703,702,4,_RecFirst)
      LOOP Erx # RecLink(703,702,4,_RecNext)
      WHILE (Erx<=_rLocked) do begin
      // Restkarte merken
        v200RestKarte # RekSave(200);
        if (_TheoWiege(aDatum, FALSE, 0, vEtkTxt, aStatus)=False) then begin   // NIE direkt Etiketten drucken
          vErr # 'Wiegungsfehler';
          RekRestore(v200RestKarte);
          BREAK;
        end;
        RekRestore(v200RestKarte);
        
      END;
    end;
  END;

  if (vErr='') and (vCount=0) then begin
    vErr # 'Kein echtes Einsatzmaterial vorhanden!';
  end;
  
  if (vErr<>'') then begin
    APPON(); // 03.02.2020
    TRANSBRK;
    TextClose(vEtkTxt);
    Msg(99,vErr,0,0,0);
    RETURN false;
  end;

  // Wenn alles IO, dann Position abschließen
  if (!aKeinAbschluss) then
    BA1_Fertigmelden:AbschlussPos(Bag.FM.Nummer, BAG.FM.Position, aDatum, now, true);

  APPON(); // 03.02.2020
  TRANSOFF;

  // 06.11.2018 ETIKETTENDRUCK:
  if (vMitEtk) then begin
    if (Set.SQL.SoaYN) then
      Winsleep(500);    // wegen SQL
    FOR vA # TextLineRead(vEtkTxt, 1, _TextLineDelete)
    LOOP vA # TextLineRead(vEtkTxt, 1, _TextLineDelete)
    WHILE (vA<>'') do begin
      RecRead(707,0,_recId, cnvia(vA));
      if (BAG.FM.Materialnr<>0) then Mat_Data:Read(BAG.FM.Materialnr);
      BA1_Fertigmelden:Etikettendruck();
    END;
  end;
  TextClose(vEtkTxt);


  vAfxPara #   Cnvai(aBA)+ '|' + Cnvai(aBAPos) + '|' + CnvaD(aDatum) + '|';
  if (aSilent) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (aKeinAbschluss) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  if (vMitEtk) then vAfxPara # vAfxPara  + 'y|' else vAfxPara # vAfxPara  + 'n|';
  RunAFX('BAG.FM.FMTheorie.Post',vAfxPara);

  RETURN true;  // Alles OK
end;


//========================================================================