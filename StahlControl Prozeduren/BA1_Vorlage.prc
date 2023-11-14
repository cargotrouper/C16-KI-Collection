@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Vorlage
//                        OHNE E_R_G
//  Info
//  10.12.2020 KLÄREN: 1x706 und 1x706 mit jeweils eigenen Ketten ODER 2x706
//      Antwort: DUNKER: 2x706 + 1x306
//
//
//  07.12.2020  AH  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//  28.07.2021  AH  AFX "BA1.BAGVorlageDaten"
//  08.04.2022  AH  Edit: "ErzeugeBAausVorlage" wandelt echte BAs in Theo
//  05.04.2023  DB  Proj. 2470/27: Ausführungen, die fertiggemeldet wurden (Fertigmeldung <> 0), sollen nicht kopiert werden
//
//  Subprozeduren
//    SUB ErzeugeVorlageAusBA(aVorlage : int) : int
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

declare _HoleStart(a702 : int; var aBinLimit : float) : logic;
declare _HoleVorSpalt(a702 : int; a703 : int; var aBoutLimit : float) : logic;
declare _HoleNachSpalt(a702 : int; var aBinLimit : float) : logic;
declare _HoleNSFertigung(a702 : int; a703 : int) : logic;
declare _HoleEnde(a702 : int) : logic;
declare GetLimit(a702 : int) : float;

//========================================================================
//========================================================================
sub PlaneEinCoil(
  aSollAnz        : float;    // 9
  aBNS            : float;    // 100
  aSaumVS         : float;    // 6
  aBinVS          : float;    // 1800
  aMaxBinNS       : float;    // 750
  
  var aAnzVS      : float;
  var aBVS        : float;
  var aAnzNS      : float;
  var aRestAnzNS  : float;
  var aRestBVS    : float;
  var aRestAnzVS  : float
) : float
local begin
  vMaxAnzNS     : float;
  vMaxBVS       : float;
  vMaxAnzVS     : float;
  vMaxRestBVS   : float;
  vMaxRestAnzNS : float;
  vMaxAnzProC   : float;
  vAnzCoils     : float;
  vAnzProC      : float;
  vX,vY,vZ      : float;
end;
begin
  vMaxAnzNS     # Floor((aMaxBinNS-aSaumVS)/aBNS);
  vMaxBVS       # (vMaxAnzNS*aBNS)+aSaumVS;
  vMaxAnzVS     # Floor(aBinVS/vMaxBVS);
  vMaxRestBVS   # aBinVS-(vMaxAnzVS*vMaxBVS);
  vMaxRestAnzNS # Floor((vMaxRestBVS-aSaumVS)/aBNS);
  vMaxAnzProC   # vMaxRestAnzNS+(vMaxAnzVS*vMaxAnzNS)
  vAnzCoils     # Ceil(aSollAnz/vMaxAnzProC)
  vAnzProC      # MIN(aSollAnz, vMaxAnzProC)

  // RESULTATE:
  aAnzNS        # MIN(aSollAnz,vMaxAnzNS);
  aAnzVS        # Floor(vAnzProC/aAnzNS);
  aBVS          # (aAnzNS*aBNS)+aSaumVS;
  aRestAnzNS    # vAnzProC-(aAnzVS*aAnzNS);
  aRestBVS      # (aRestAnzNS*aBNS)+aSaumVS;
  if (aRestAnzNS>0.0) then aRestAnzVS # 1.0
  else aRestAnzVS # 0.0;

  // ggf. Fertigungen optimieren?
  if (aRestAnzVS>0.0) then begin
//debug('optimiere -------------------------------------');
    // Beispiel:
    // 5 x 906, 1 x 906
    // 9,9,9,9,9,1 = 46
    vZ # aAnzVS + aRestAnzVS;         // 6 VS
    vX # Floor(vAnzProC DIV vZ);      // 46 / 6 = 7
    vY # vAnzProC % vZ;               // 46 & 6 = 4
    // ==> 8,8,8,8,7,7
    aAnzVS      # vY;
    aBVS        # ((vX+1.0)*aBNS)+aSaumVS;
    aRestAnzVS  # vZ - aAnzVS;        // 2
    aRestBVS    # (1.0*vX*aBNS)+aSaumVS;
    aAnzNS      # vX + 1.0;
    aRestAnzNS  # vX;
  end;

  if (aAnzVS=0.0) then begin
    aAnzVS      # aRestAnzVS;
    aBVS        # aRestBVS;
    aRestAnzVS  # 0.0;
    aRestBVS    # 0.0;
    aAnzNS      # aRestAnzNS;
    aRestAnzNS  # 0.0;
  end;
  
//debug('VS  A): '+anum(aAnzVS,0)+' x '+anum(aBVS,2)+'mm    NS: '+anum(aAnzNS,0)+' x '+anum(aBNS,2)+'mm');
//if (aRestAnzVS<>0.0) then
//  debug('VS  B): '+anum(aRestAnzVS,0)+' x '+anum(aRestBVS,2)+'mm    NS: '+anum(aRestAnzNS,0)+' x '+anum(aBNS,2)+'mm');

  RETURN vAnzProC;
end;


//========================================================================
//========================================================================
sub _CopyBAFert(
  aNr     : int;
  aPos    : int;
  aFert   : int;
  aAufNr  : int;
  aAufPos : int;
  aAnz    : int;
  aB      : float;
  opt aReset  : logic;
) : logic
local begin
  v703  : int;
  Erx   : int;
  vPos  : int;
end;
begin
  FOR erx # RecLink(705,703,8,_RecFirst)  // Ausführungen kopieren
  LOOP erx # RecLink(705,703,8,_RecNext)
  WHILE (erx<=_rLocked) do begin
    // 05.04.2023 DB Proj. 2470/27: Ausführungen, die fertiggemeldet wurden (Fertigmeldung <> 0), sollen nicht kopiert werden
    if (BAG.AF.Fertigmeldung <> 0) then CYCLE;
  
    BAG.AF.Nummer     # aNr;
    BAG.AF.Position   # aPos;
    BAG.AF.Fertigung  # aFert;
    Erx # RekInsert(705,0,'AUTO');
    if (erx<>_rOK) then RETURN false;
    BAG.AF.Nummer     # BAG.F.Nummer;
    BAG.AF.Position   # BAG.F.Position;
    BAG.AF.Fertigung  # BAG.F.Fertigung;
  END;

  BAG.F.Breite          # aB;
  BAG.F.Streifenanzahl  # aAnz;

  v703 # RekSave(703);    // 2022-08-22 AH
  
  BAG.F.Nummer    # aNr;
  BAG.F.Position  # aPos;
  BAG.F.Fertigung # aFert;
  if (StrCut(BAG.F.Kommission,1,1)='#') and (aAufPos<>0) then begin
    BA1_F_Data:BelegeKommisisonsDaten(BAG.F.Kommission, aAufNr, aAufPos)
  end;
  BAG.F.Anlage.Datum  # Today;
  BAG.F.Anlage.Zeit   # Now;
  BAG.F.Anlage.User   # gUserName;
  if (aReset) then begin  // 08.04.2022 AH
    BAG.F.Fertig.Gew    # 0.0;
    BAG.F.Fertig.Menge  # 0.0;
    BAG.F.Fertig.Stk    # 0;
  end;
  Erx # RekInsert(703,0,'AUTO');
  if (erx<>_rOK) then begin
    RekRestore(v703);
    RETURN false;
  end;

  RekRestore(v703);
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub _ReMap(
  aTxt      : int;
  aPart     : alpha;
  var aPos  : word;
) : logic;
local begin
  vI  : int;
  vA  : alpha;
end
begin
  if (aPos=0) then RETURN true;
  vI # TextSearch(aTxt,1,1,_TextSearchCI, '|'+aPart+aint(aPos)+'|');
  if (vI=0) then RETURN false;
  vA # TextLineRead(aTxt, vI, 0);
  aPos # cnvia(Str_Token(vA,'|',3));
  RETURN true;
end;


//========================================================================
//  ErzeugeBAausVorlage
//
//========================================================================
sub ErzeugeBAausVorlage(
  aVorlage      : int;
  aAufNr        : int;
  aAufPos       : int;
  aGewicht      : float;
  aMengenFakt   : float;
  aBAG          : int;
  aOffsetPos    : int;
  aOffsetIO     : int;
  a702VS        : int;
  aAnzVS        : float;
  aBVS          : float;
  aRestAnzVS    : float;
  aRestBVS      : float;
  a702NS        : int;
  aAnzNS        : float;
  aBNS          : float;
  aRestAnzNS    : float;
) : int;
local begin
  Erx         : int;
  vNeueNr     : int;
  vTheoID     : int;
  vName       : alpha;
  vName2      : alpha;
  vKGMM_Kaputt  : logic;
  vFirst      : logic;

  vNeuePos    : int;
  vNeueFert   : int;
  vNeueID     : int;

  vOK         : logic;
  vI          : int;
  vRestTxt    : int;
  vA          : alpha;
  vBinNS      : logic;
  vStartPos   : int;
end;
begin

  if (aGewicht=0.0) then aGewicht # Auf.P.Gewicht;

  BAG.Nummer # aVorlage;
  erx # RecRead(700,1,0);   // BA holen
  if (erx>_rLocked) then begin
    Msg(700007,'',0,0,0);
    RETURN 0;
  end;
  if (BAG.VorlageYN=n) or (BAG.VorlageSperreYN) then begin
    Msg(700020,aint(BAG.Nummer),0,0,0);
    RETURN 0;
  end;

  TRANSON;

  if (aBAG=0) then begin
    vNeueNr # Lib_Nummern:ReadNummer('Betriebsauftrag');
    if (vNeueNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      RETURN 0;
    end;
  
    RecBufClear(700);
    BAG.BuchungsAlgoNr  # Set.BA.BuchungAlgoNr;
    BAG.Nummer        # vNeueNr;
    BAG.Bemerkung     # Translate('aus Vorlage-BA')+' '+aint(aVorlage);

    RunAFX('BA1.BAGVorlageDaten',Aint(aAufNr) + '/'+Aint(aAufPos));

    BAG.Anlage.Datum  # Today;
    BAG.Anlage.Zeit   # Now;
    BAG.Anlage.User   # gUserName;
    Erx # RekInsert(700,0,'AUTO');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      RETURN 0;
    end;
  end
  else begin
    vNeueNr     # aBAG;
    BAG.Nummer  # aBAG;
    RecRead(700,1,0);
  end;

  BAG.Nummer # aVorlage;

  // Verpackungen kopieren bei NEUEM BA
  if (aBAG=0) then begin
    FOR erx # RecLink(704,700,2,_RecFirst)   // Verpackungen loopen
    LOOP erx # RecLink(704,700,2,_RecNext)
    WHILE (erx<=_rLocked) do begin
      BAG.Vpg.Nummer # vNeueNr;
      BAG.Vpg.Verpackung  # BAG.Vpg.Verpackung;
      Erx # RekInsert(704,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN 0;
      end;
      BAG.vpg.Nummer # aVorlage;
      BAG.Vpg.Verpackung  # BAG.Vpg.Verpackung;
      RecRead(704,1,0);
    END;
  end;


  // POSITIONEN kopieren -----------------------------------------------
  vNeuePos # 0;
  FOR erx # RecLink(702,700,1,_recFirst)     // Positionen loopen
  LOOP erx # RecLink(702,700,1,_recNext)
  WHILE (erx<=_rLocked) do begin

    vNeuePos # aOffsetPos + BAG.P.Position;

    if (BAG.P.Typ.VSBYN) and (aAufNr<>0) then begin
      if (StrCut(BA1_Lohn_Subs:_VorgaengerKommission(),1,1)='#') then begin
        BAG.P.Kommission    # AInt(aAufNr)+'/'+AInt(aAufPos);
        BAG.P.Auftragsnr    # aAufNr;
        BAG.P.Auftragspos   # aAufPos;
        erx # RecLink(401,702,16,_recFirst);    // Aufpos holen
        if (erx<=_rLockeD) then begin
          erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
          if (erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then erx # _rNoRec;
        end;
        if (erx<=_rLocked) then begin
          if (Auf.P.TerminZusage<>0.0.0) then
            BAG.P.Fenster.MaxDat  # Auf.P.TerminZusage
          else
            BAG.P.Fenster.MaxDat  # Auf.P.Termin1Wunsch;
        end;
        BAG.P.Plan.StartDat # BAG.P.Fenster.MaxDat;
        BAG.P.Plan.EndDat   # BAG.P.Fenster.MaxDat;
      end;
      BAG.P.Bezeichnung   # BAG.P.Aktion+' '+BAG.P.Kommission;
      
    end;

    // 27.09.2021 AH + 09.12.2021 AH
    if ((BAG.P.Aktion=c_BAG_Versand) or (BAG.P.ZielVerkaufYN)) and (aAufNr<>0) then begin
      Erx # 400;
      if (Auf.nummer<>aAufNr) then
        Erx # Auf_Data:Read(aAufNr, aAufPos, y);
      if (Erx>=400) then begin
        BAG.P.Zieladresse   # Auf.Lieferadresse;
        BAG.P.Zielanschrift # Auf.Lieferanschrift;
        BAG.P.Zielstichwort # Auf.KundenStichwort;
      end;
    end;

    if (BAG.P.Typ.VSBYN=false) and (aAufNr<>0) and (StrCut(BAG.P.Kommission,1,1)='#') then begin
      BAG.P.Kommission    # AInt(aAufNr)+'/'+AInt(aAufPos);
      erx # RecLink(401,701,16,_recFirst);    // Aufpos holen
      if (erx<=_rLockeD) then begin
        erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
        if (erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then erx # _rNoRec;
      end;
      BAG.P.Auftragsnr    # aAufNr;
      BAG.P.Auftragspos   # aAufPos;
    end;


    // Texte kopieren 20.01.2016:
    vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
    vName2  # '~702.'+CnvAI(vNeueNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position+aOffsetPos,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
    TxtCopy(vName,vName2,0);
    vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
    vName2  # '~702.'+CnvAI(vNeueNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position+aOffsetPos,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
    TxtCopy(vName,vName2,0);

    BAG.P.Nummer        # vNeueNr;
    BAG.P.Position  # BAG.P.Position + aOffsetPos;
    if (BAG.P.Status='') and ("BAG.P.Löschmarker"='') then
      BA1_Data:SetStatus(c_BagStatus_Offen);
    if ("BAG.P.Löschmarker"<>'') then
      BA1_Data:SetStatus(c_BagStatus_Fertig);
    Erx # BA1_P_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      if (vRestTxt<>0) then TextCLose(vRestTxt);
      RETURN 0;
    end;
    BAG.P.Nummer # aVorlage;
    BAG.P.Position  # BAG.P.Position - aOffsetPos;


    FOR erx # RecLink(706,702,9,_RecFirst)   // Arbeitsschritte loopen
    LOOP erx # RecLink(706,702,9,_RecNext)
    WHILE (erx<=_rLocked) do begin
      BAG.AS.Nummer # vNeueNr;
      BAG.AS.Position # BAG.AS.Position + aOffsetPos;
      Erx # RekInsert(706,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        if (vRestTxt<>0) then TextCLose(vRestTxt);
        RETURN 0;
      end;
      BAG.AS.Nummer # aVorlage;
      BAG.AS.Position # BAG.AS.Position - aOffsetPos;
      RecRead(706,1,0);
    END;

    // in Kette HINTER VS?
    if (vRestTxt<>0) then begin
      TextAddLine(vRestTxt, '|Pos'+aint(BAG.P.Position)+'|');
    end

    // FERTIGUNGEN ------------------------------------------------------
    FOR erx # RecLink(703,702,4,_recFirst)    // Fertigungen loopen
    LOOP erx # RecLink(703,702,4,_recNext)
    WHILE (erx<=_rLocked) do begin
   
      // Vorspalten?
      if (BAG.P.Position=a702VS->BAG.P.Position) then begin
        vOK # _CopyBAFert(vNeueNr, vNeuePos, 1, aAufNr, aAufPos, cnvif(aAnzVS), aBVS);
        if (aRestAnzVS<>0.0) then begin
          vRestTxt # TextOpen(20);
          TextAddLine(vRestTxt, '|Fert'+aint(BAG.F.Nummer)+'/'+aint(BAG.F.Position)+'/'+aint(BAG.F.Fertigung));
//          if (_CopyBAFert(vNeueNr, vNeuePos, 2, aAufNr, aAufPos, cnvif(aRestAnzVS), aRestBVS)=false) then begin
//            TRANSBRK;
//            RETURN 0;
//          end;
        end;
      end
      else if (BAG.P.Position=a702NS->BAG.P.Position) then begin
        // Nachspalten?
        vOK # _CopyBAFert(vNeueNr, vNeuePos, 1, aAufNr, aAufPos, cnvif(aAnzNS), aBNS);
      end
      else begin
        vOK # _CopyBAFert(vNeueNr, vNeuePos, BAG.F.Fertigung, aAufNr, aAufPos, BAG.F.Streifenanzahl, BAG.F.Breite );
        // alles andere...
      end;
      if (vOK=false) then begin
        TRANSBRK;
        if (vRestTxt<>0) then TextCLose(vRestTxt);
        RETURN 0;
      end;

    END;  // Fertigungen

  END;  // Positionen


  FOR erx # RecLink(701,700,3,_recFirst)    // InOut loopen
  LOOP erx # RecLink(701,700,3,_recNext)
  WHILE (erx<=_rLocked) do begin

    // Kanten ggf. Klonen für weitere VS?
    if (vRestTxt<>0) then begin
//if (vRestTxt<>0) then TextAddLine(vRestTxt, 'IO '+aint(BAG.IO.ID)+' '+aint(BAG.IO.VonPosition)+' -> '+aint(BAG.IO.NachPosition));
      vI # 0;
      if (BAG.IO.VonPosition<>0) then
        vI # TextSearch(vRestTxt,1,1,_TextSearchCI, '|Pos'+aint(BAG.IO.VonPosition)+'|');
      if (BAG.IO.NachPosition<>0) and (vI=0) then
        vI # TextSearch(vRestTxt,1,1,_TextSearchCI, '|Pos'+aint(BAG.IO.NachPosition)+'|');
      if (vI<>0) then begin
        TextAddLine(vRestTxt, '|IO'+aint(BAG.IO.ID)+'|');
      end;
    end;

    BAG.IO.Nummer   # vNeueNr;
    BAG.IO.ID       # BAG.IO.ID + aOffsetIO;

    if (BAG.IO.VonBAG=aVorlage) then begin
      BAG.IO.VonBAG       # vNeueNr;
      BAG.IO.VonPosition  # BAG.IO.VonPosition + aOffsetPos;
      if (BAG.IO.VonID<>0) then
        BAG.IO.VonID # BAG.IO.VonID + aOffsetIO;
    end;
    if (BAG.IO.NachBAG=aVorlage) then begin
      BAG.IO.NachBAG        # vNeueNr;
      BAG.IO.NachPosition   # BAG.IO.NachPosition + aOffsetPos;
      if (BAG.IO.NachID<>0) then
        BAG.IO.NachID         # BAG.IO.NachID + aOffsetIO;
    end;
    if (BAG.IO.UrsprungsID<>0) then
      BAG.IO.UrsprungsID # BAG.IO.UrsprungsID + aOffsetIO;
    if (BAG.IO.BruderID<>0) then
      BAG.IO.BruderID # BAG.IO.BruderID + aOffsetIO;


    BAG.IO.Anlage.Datum  # Today;
    BAG.IO.Anlage.Zeit   # Now;
    BAG.IO.Anlage.User   # gUserName;

    // Entnahmen hochrechnen
    if (BAG.IO.VonBAG=0) then begin
      vStartPos # BAG.IO.NachPosition;
      if (BAG.IO.Materialtyp=c_IO_Theo) or (BAG.IO.Materialtyp=c_IO_Beistell) then begin
        BAG.IO.Breite         # (aAnzVS * aBVS) + (aRestAnzVS * aRestBVS);
        BAG.IO.Plan.In.GewB   # Rnd(BAG.IO.Plan.In.GewB * aMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.In.GewN   # Rnd(BAG.IO.Plan.In.GewN * aMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.In.Menge  # Rnd(BAG.IO.Plan.In.Menge * aMengenFakt, Set.Stellen.Menge);
        BAG.IO.Plan.Out.GewB  # Rnd(BAG.IO.Plan.Out.GewB * aMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.Out.GewN  # Rnd(BAG.IO.Plan.Out.GewN * aMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.Out.Meng  # Rnd(BAG.IO.Plan.Out.Meng * aMengenFakt, Set.Stellen.Menge);
        if (BAG.IO.Materialtyp=c_IO_Beistell) then begin
          BAG.IO.Plan.In.Stk  # cnvif(Lib_Berechnungen:RndUp(cnvfi(BAG.IO.Plan.In.Stk) * aMengenFakt));
          BAG.IO.Plan.Out.Stk # cnvif(Lib_Berechnungen:RndUp(cnvfi(BAG.IO.Plan.Out.Stk) * aMengenFakt));
        end;
        if (BAG.IO.MEH.In='Stk') then
          BAG.IO.Plan.In.Menge  # cnvfi(BAG.IO.Plan.In.Stk);
        if (BAG.IO.MEH.Out='Stk') then
          BAG.IO.Plan.Out.Meng  # cnvfi(BAG.IO.Plan.Out.Stk);
      end;
    end;
    Erx # BA1_IO_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      if (vRestTxt<>0) then TextCLose(vRestTxt);
      RETURN 0;
    end;

    vNeueID # BAG.IO.ID;

    BAG.IO.Nummer   # aVorlage;
    BAG.IO.ID       # BAG.IO.ID - aOffsetIO;
  END;

  BAG.Nummer # vNeueNr;
  RecRead(700,1,0);


  // 2. Fertigung beim Vorspalten? ------------------------------------------
  if (vRestTxt<>0) then begin
    vI # TextSearch(vRestTxt,1,1,_TextSearchCI, '|Fert');
    if (vI<>0) then begin
      vA # TextLineRead(vRestTxt, vI, 0);
      if (Lib_Berechnungen:IntsAusAlpha(vA, var BAG.F.Nummer, var BAG.F.Position, var BAG.F.Fertigung)) then begin
        RecRead(703,1,0);
        if (_CopyBAFert(vNeueNr, BAG.F.Position, 2, aAufNr, aAufPos, cnvif(aRestAnzVS), aRestBVS)=false) then begin
          TRANSBRK;
          if (vRestTxt<>0) then TextCLose(vRestTxt);
          RETURN 0;
        end;
//        if (BA1_F_Data:UpdateOutput(703,n)=false) then begin // erstmal löschen!!!
//          TRANSBRK;
//          if (vRestTxt<>0) then TextCLose(vRestTxt);
//          RETURN 0;
//        end;
      end;

      // Positionen kopieren...
      FOR vI # TextSearch(vRestTxt,1,1,_TextSearchCI, '|Pos')
      LOOP vI # TextSearch(vRestTxt,vI+1,1,_TextSearchCI, '|Pos')
      WHILE (vI>0) do begin
        vA # TextLineRead(vRestTxt, vI, 0);

        BAG.P.Nummer    # vNeueNr;
        BAG.P.Position  # cnvia(Strcut(vA,5,10));
        RecRead(702,1,0);
        inc(vNeuePos);
        
        vBinNS # BAG.P.Position = a702NS->BAG.P.Position;

        // FERTIGUNGEN kopieren...
        FOR erx # RecLink(703,702,4,_recFirst)    // Fertigungen loopen
        LOOP erx # RecLink(703,702,4,_recNext)
        WHILE (erx<=_rLocked) do begin
          if (vBinNS) then begin
            vOK #_CopyBAFert(vNeueNr, vNeuePos, BAG.F.Fertigung, aAufNr, aAufPos, cnvif(aRestAnzNS), BAG.F.Breite );
          end
          else begin
            vOK #_CopyBAFert(vNeueNr, vNeuePos, BAG.F.Fertigung, aAufNr, aAufPos, BAG.F.Streifenanzahl, BAG.F.Breite );
          end;
          if  (vOK=false) then begin
            TRANSBRK;
            if (vRestTxt<>0) then TextCLose(vRestTxt);
            RETURN 0;
          end;
        END;  // Fertigungen

        BAG.P.Position  # vNeuePos;
        TextLineWrite(vRestTxt, vI, vA+aint(vNeuePos)+'|',0); // Remapping merken
        erx # BA1_P_Data:Insert(0,'AUTO');
        if (erx<>_rOK) then begin
          TRANSBRK;
          if (vRestTxt<>0) then TextCLose(vRestTxt);
          RETURN 0;
        end;

      END; // Pos kopieren...
      
      // IOs kopieren...
      FOR vI # TextSearch(vRestTxt,1,1,_TextSearchCI, '|IO')
      LOOP vI # TextSearch(vRestTxt,vI+1,1,_TextSearchCI, '|IO')
      WHILE (vI>0) do begin
        vA # TextLineRead(vRestTxt, vI, 0);
        BAG.IO.Nummer # vNeueNr;
        BAG.IO.ID     # cnvia(vA);
        RecRead(701,1,0);
        
//if (vRestTxt<>0) then TextAddLine(vRestTxt, 'vonIO '+aint(BAG.IO.ID)+' '+aint(BAG.IO.VonPosition)+'/'+aint(BAG.IO.VonID)+' -> '+aint(BAG.IO.NachPosition)+'/'+aint(BAG.IO.NAchid));
        // ID3 Von2 Nach4 WIRD: ID9 Von2 Nach10
        _ReMap(vRestTxt, 'IO', var BAG.IO.VonID);
        _ReMap(vRestTxt, 'IO', var BAG.IO.NachID);

        if (BAG.IO.VonPosition=a702VS->BAG.P.Position) then begin
          BAG.IO.VonPosition  # BAG.IO.VOnPosition + aOffSetPos;
          BAG.IO.VOnID        # BAG.IO.VonID + aOffsetIO;
          BAG.IO.VonFertigung # 2;
        end
        else begin
          _ReMap(vRestTxt, 'Pos', var BAG.IO.VonPosition);
        end;
        _ReMap(vRestTxt, 'Pos', var BAG.IO.NachPosition);

        inc(vNeueID);
        BAG.IO.ID # vNeueID;

/*
if (vRestTxt<>0) then TextAddLine(vRestTxt, 'wirdIO '+aint(BAG.IO.ID)+' '+aint(BAG.IO.VonPosition)+'/'+aint(BAG.IO.VonID)+' -> '+aint(BAG.IO.NachPosition)+'/'+aint(BAG.IO.NAchid));
if (BAG.Io.ID=23) then begin
BAG.IO.VonPosition # 16;
BAG.IO.VonID # 16;
end;
*/
        TextLineWrite(vRestTxt, vI, vA+aint(vNeueID)+'|',0); // Remapping merken

        //Erx # BA1_IO_Data:Insert(0,'AUTO');
        Erx # RekInsert(701);
        if (erx<>_rOK) then begin
//textWrite(vRestTxt,'d:\debug\debug.txt',_TextExtern);
          TRANSBRK;
          if (vRestTxt<>0) then TextCLose(vRestTxt);
          RETURN 0;
        end;
      END; // IOs kopieren

//if (vrestTxt<>0) then textWrite(vRestTxt,'d:\debug\debug.txt',_TextExtern);

      // IOs remappen...
      FOR vI # TextSearch(vRestTxt,1,1,_TextSearchCI, '|IO')
      LOOP vI # TextSearch(vRestTxt,vI+1,1,_TextSearchCI, '|IO')
      WHILE (vI>0) do begin
        vA # TextLineRead(vRestTxt, vI, 0);
        BAG.IO.Nummer # vNeueNr;
        BAG.IO.ID     # cnvia(Str_token(vA,'|',3));
        erx # RecRead(701,1,_recLock);
        
        // UrsprungsID BruderID
        // ID3 Von2 Nach4 WIRD: ID9 Von2 Nach10
        _ReMap(vRestTxt, 'IO', var BAG.IO.VonID);
        _ReMap(vRestTxt, 'IO', var BAG.IO.NachID);
        _ReMap(vRestTxt, 'IO', var BAG.IO.BruderID);
        _ReMap(vRestTxt, 'IO', var BAG.IO.UrsprungsID);

        Erx # BA1_IO_Data:Replace(0,'AUTO');
        if (erx<>_rOK) then begin
//textWrite(vRestTxt,'d:\debug\debug.txt',_TextExtern);
          TRANSBRK;
          if (vRestTxt<>0) then TextCLose(vRestTxt);
          RETURN 0;
        end;
      END; // IOs kopieren
      
    end;
  end;
/***
  TRANSOFF;
  if (vRestTxt<>0) then TextCLose(vRestTxt);
  RETURN vNeueNr;
***/

//  erx # RecLink(702,700,4,_recFirst);     // Positionen loopen
  BAG.P.Nummer    # vNeueNr;
  BAG.P.Position  # vStartPos;
  erx # RecRead(702,1,0);
  if (erx<=_rLocked) then begin
    FOR erx # RecLink(701,702,2,_recFirst)    // Input loopen
    LOOP erx # RecLink(701,702,2,_recNext)
    WHILE (erx<=_rLocked) do begin
      if (vFirst=false) then begin
        if (BA1_IO_Data:Autoteilung(var vKGMM_Kaputt)=false) then begin
//debugx('aua');
        end;
        vFirst # true;
      end;

      // Output aktualisieren
      if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      end;
    END;
  end;


// 27.02.2015
  FOR erx # RecLink(701,700,3,_recFirst)  // IO loopen
  LOOP erx # RecLink(701,700,3,_recNext)
  WHILE (erx<=_rLocked) and (vTheoID>=0) do begin
    if (BAG.IO.Materialtyp=c_IO_Theo) and (BAG.IO.NachPosition<>0) then begin
      if (vTheoID=0) then vTheoID # BAG.IO.ID;
      else vTheoID # -1;
    end;
  END;

  RecLink(702,700,1,_recFirsT); // 1. Position holen
  if (vTheoID<0) then begin
    BAG.P.Position # 0;
    vTheoID # 0;
  end;

  if (aAufNr<>0) then
    BA1_Subs:EinsatzLautAuftrag(aAufNr, aAufPos, vTheoID);


  FOR Erx # RecLink(702,700,1,_recFirst)     // Positionen loopen
  LOOP Erx # RecLink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecRead(702,1,_recLock);
    if (BA1_Laufzeit:Automatisch(y)) then begin
      BA1_P_Data:Replace(_recUnlock,'MAN');
      BA1_P_Data:UpdateAufAktion(n);
    end
    else begin
      RecRead(702,1,_recUnlock);
    end;
  END;

  TRANSOFF;

  if (vRestTxt<>0) then TextCLose(vRestTxt);

  RETURN vNeueNr;
end;


//========================================================================
SUB WandelAlgo1(
  aNr       : int;  // VorlageBA
  aSollGew  : float;
) : int;
local begin
  Erx           : int;
  v702Start     : int;
  v702VS        : int;
  v702NS        : int;
  v702Ende      : int;
  v703VS        : int;
  v703NS        : int;
  v701Start     : int;

  vLosGew       : float;
  vBNS          : float;  // z5
  vSaumVS       : float;  // z6
  vMaxBCoil     : float;  // z1
  vMaxBinVS     : float;  // z2
  vMaxBinNS     : float;  // z4
  vSollAnz      : float;  // z3
  
  vMaxBoutVS    : float;  // passend zu NS !!! also wie "MaxBinNS"
  vBinVS        : float;
  
  vOK           : logic;

  vAnzVS        : float;
  vBVS          : float;
  vAnzNS        : float;
  vRestAnzNS    : float;
  vRestBVS      : float;
  vRestAnzVS    : float;
  vAnz          : float;
  vCoilGew      : float;
  vCoilB        : float;
  vKgMM         : float;
  vFakt         : float;

  vBAG          : int;
  vLastIO       : int;
  vLastPos      : int;
end;
begin


  BAG.Nummer # aNr;
  Erx # RecRead(700,1,0);   // BA holen
  if (Erx>_rLocked) or (BAG.VorlageYN=false) or (BAG.VorlageSperreYN) then begin
    Msg(700017,'',0,0,0);
    RETURN 0;
  end;

 if (Msg(99,'Blauen Modus starten?',_WinIcoQuestion,_WinDialogYesNo,1)=_Winidyes) then
    lib_debug:startBluemode();

//debug('---------------------------'+anum(aSollGew,0));
  v702Start   # RecBufCreate(702);
  v702Ende    # RecBufCreate(702);
  v702VS      # RecBufCreate(702);
  v702NS      # RecBufCreate(702);

  v703VS      # RecBufCreate(703);
  v703NS      # RecBufCreate(703);

  v701Start   # RecBufCreate(701);

  REPEAT
    // Ende/VSB suchen...
    if (_HoleEnde(v702Ende)=false) then begin
      Msg(99,'Keine ENDE-Position gefunden!',0,0,0);
      BREAK;
    end;
    RecBufCopy(v702Ende, v702NS);
    // wenn ENDE <> Nachspalten dann höher suchen...
    if (v702Ende->BAG.P.Aktion=c_BAG_Spalt) then begin
      vMaxBinNS # GetLimit(v702NS);
    end
    else begin
      if (_HoleNachSpalt(v702NS, var vMaxBinNS)=false) then begin
        Msg(99,'Keine NACHSPALTEN-Position gefunden!',0,0,0);
        BREAK;
      end;
    end;

    _HoleNSFertigung(v702NS, v703NS);

    RecBufCopy(v702NS, v702VS);
    if (_HoleVorSpalt(v702VS, v703VS, var vMaxBoutVS)=false) then begin
      Msg(99,'Keine VORSPALTEN-Position gefunden!',0,0,0);
      BREAK;
    end;

    vMaxBinVS # GetLimit(v702VS);

    RecBufCopy(v702VS, v702Start);
    if (_HoleStart(v702Start, var vMaxBCoil)=false) then begin
      Msg(99,'Keine START-Position gefunden!',0,0,0);
      BREAK;
    end;
    Erx # RecLink(v701Start, v702Start, 2,_recFirst);   // Einsatz
    if (Erx>_rLocked) then begin
      Msg(99,'Keine START-Einsatz gefunden!',0,0,0);
      BREAK;
    end;
    

   // Plausiprüfungen ------------------------------------------
    vLosGew # v703NS->BAG.F.Gewicht;
    if (vLosGew=0.0) then begin
      Msg(99,'Keine Losgröße gefunden!',0,0,0);
      BREAK;
    end;
    vBNS # v703NS->BAG.F.Breite;
    if (vBNS=0.0) then begin
      Msg(99,'Keine Fertigbreite gefunden!',0,0,0);
      BREAK;
    end;
    vSaumVS # v703VS->BAG.F.Breite - vBNS;
    if (vSaumVS<0.0) then begin
      Msg(99,'Keine Vorspaltbreite gefunden!',0,0,0);
      BREAK;
    end;
    if (v701Start->BAG.IO.Breite<>0.0) then
      vkgMM # v701Start->BAG.IO.Plan.In.GewB / v701Start->BAG.IO.Breite;
    if (vkgMM<=0.0) then begin
      Msg(99,'Keine Einsatz-KG-MM gefunden!',0,0,0);
      BREAK;
    end;
    if (Auf.P.Breite<>0.0) then begin
      vBNS # Auf.P.Breite;
    end;

//debug('START:'+aint(v702Start->BAG.P.Position)+' BLimit:'+anum(vMaxBCoil,2)+' - ');
//debug('VORSPALT:'+aint(v702VS->BAG.P.Position)+' BLimit:'+anum(vMaxBinVS,2)+' - '+anum(vMaxBoutVS,2));
//debug('NACHSPALT:'+aint(v702NS->BAG.P.Position)+' BLimit:'+anum(vMaxBinNS,2)+' - ');

    // Sollmenge in Losgröße rastern
    vLosGew # vLosGew / v703NS->BAG.F.Breite * vBNS;
    vSollAnz # Ceil(aSollGew / vLosGew);
    
    // Einsatz-Vorspalten kann nicht größer als Coil bzw. Scherenlimit sein
    vBinVS # Min(vMaxBCoil, vMaxBinVS);

    WHILE (vSollAnz>0.0) do begin
      vAnz # PlaneEinCoil(vSollAnz, vBNS, vSaumVS, vBinVS, vMaxBoutVS,
        var vAnzVS, var vBVS, var vAnzNS, var vRestAnzNS, var vRestBVS, var vRestAnzVS);
      vSollAnz  # vSollAnz - vAnz;
      vCoilB    # (vAnzVS * vBVS) + (vRestAnzVS * vRestBVS);
      vCoilGew  # Rnd(vCoilB * vKgMM,0);

      vFakt # vCoilgew / v701Start->BAG.IO.Plan.In.GewN;

      vBAG # ErzeugeBAausVorlage(Auf.P.VorlageBAG, Auf.P.Nummer, Auf.P.Position, vCoilGew, vFakt, vBAG, vLastPos, vLastIO,
        v702VS, vAnzVS, vBVS, vRestAnzVS, vRestBVS, v702NS, vAnzNS, vBNS, vRestAnzNS);
      Erx # RecLink(701,700,3,_recLast);
      vLastIO  # BAG.IO.ID;
      Erx # RecLink(702,700,1,_recLast);
      vLastPos # BAG.P.Position;
      
//      if (vSollAnz>0.0) then debug('Weiteres Coil...');
    END;
    
  BREAK;

    vOK # true;
  UNTIL (1=1);

  RecBufDestroy(v702Start);
  RecBufDestroy(v702VS);
  RecBufDestroy(v702NS);
  RecBufDestroy(v702Ende);
  RecBufDestroy(v703NS);
  RecBufDestroy(v701Start);

  RETURN vBAG;
end;


//========================================================================
sub GetLimit(a702 : int) : float;
local begin
  vX  : float;
end;
begin
  vX # cnvfa(a702->BAG.P.Zusatz);
  if (vX<>0.0) then RETURN vX;
  else RETURN 999999.9;
end;


//========================================================================
sub  _DrillUp(
  a702          : int;
  aAkt          : alpha;
  var aBinLimit : float;
  opt a703      : int) : logic
local begin
  Erx   : int;
  v702  : int;
  vOK   : logic;
  vX    : float;
end;
begin
  if (aBinLimit=0.0) then aBinLimit # 99999.0;
  v702 # RecBufCreate(702);

  FOR Erx # RecLink(701,a702,2,_recFirst)     // Input loopen
  LOOP Erx # RecLink(701,a702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.VonBAG=0) then CYCLE;
    if (BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;
    Erx # RecLink(v702,701,2,_recFirst);      // Vorgängerpos holen
    if (Erx>_rLocked) then CYCLE;
    
    vX # GetLimit(a702);
//debugx(aint(a702->BAG.P.Position)+')'+a702->BAG.P.Aktion+' BLimitMin '+anum(aBinLimit,2)+','+anum(vX,2));
    aBinLimit # min(aBinLimit, vX);

    if (v702->BAG.P.Aktion=aAkt) or (aAkt='*') then begin // Vorgänger passt?
      RecBufCopy(v702,a702);
      RecBufDestroy(v702);
      if (a703<>0) then begin
        Reclink(a703,701,3,_recFirst);      // Vorgängerfertigung holen
      end;
     
      RETURN true;
    end;

    vOK # _Drillup(v702, aAkt, var aBinLimit, a703);       // Rekursiv!
    RecBufCopy(v702,a702);
    RecBufDestroy(v702);
    RETURN vOK;
  END;

  RecBufDestroy(v702);
  RETURN false;
end;


//========================================================================
//========================================================================
sub _HoleNSFertigung(
  a702 : int;
  a703 : int;
) : logic
local begin
  Erx : int;
end;
begin
  FOR Erx # RecLink(a703,a702,4,_recFirst)   // Fertigungen loopen
  LOOP Erx # RecLink(a703,a702,4,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (a703->BAG.F.Kommission<>'') then RETURN TRUE;
  END;
  RecbufClear(a703);
  RETURN false;
end;


//========================================================================
//========================================================================
sub _HoleNachSpalt(
  a702          : int;
  var aBinLimit : float
  ) : logic;
local begin
  vOK   : logic;
end
begin
 
  vOK # _DrillUp(a702, c_BAG_Spalt, var aBinLimit);
  if (vOK=false) then RETURN false;

  aBinLimit # GetLimit(a702);

  RETURN TRUE;
end;


//========================================================================
//========================================================================
sub _HoleVorSpalt(
  a702            : int;
  a703            : int;
  var aBoutLimit  : float;) : logic;
local begin
  vOK         : logic;
end;
begin
  vOK # _DrillUp(a702, c_BAG_Spalt, var aBoutLimit, a703);
//  aBin # GetLimit(a702);
//  aBin # Min(aBin, aBout);
  RETURN vOK;
end;


//========================================================================
//========================================================================
sub _HoleStart(
  a702          : int;
  var aBinLimit : float;
) : logic;
begin
  WHILE (_DrillUp(a702, '*', var aBinLimit)) do begin
  END;
  
  aBinLimit # GetLimit(a702);

  RETURN true;
end;


//========================================================================
//========================================================================
sub _HoleEnde(
  a702        : int;
  ) : logic;
local begin
  Erx : int;
end;
begin
  FOR Erx # RecLink(702,700,1,_recLast)     // Positionen loopen
  LOOP Erx # RecLink(702,700,1,_recPrev)
  WHILE (Erx<=_rLocked) do begin
    // Entweder wirklichen VSB-Schritt und dessen VORGÄNGER ist das ENDE...
    if (BAG.P.Typ.VSBYN) then begin
      Erx # RecLink(701,702,2,_recFirst);   // Input holen
      if (Erx>_rLocked) then CYCLE;
      if (BAG.IO.VonBAG=0) then CYCLE;
      if (BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;
      Erx # RecLink(a702,701,2,_recFirst);   // vonPos holen
      if (Erx<>_rOK) then CYCLE;
      RETURN true;
    end;
    
    // ODER Position nur mit offenen Outputs ist ENDE
    FOR Erx # RecLink(701,702,3,_recFirst)   // Outputs loopen
    LOOP Erx # RecLink(701,702,3,_recNext)
    WHILE (Erx<_rLocked) do begin
      if (BAG.IO.NachBAG<>0) then BREAK;
    END;
    if (Erx>_rLocked) then begin
      RecBufCopy(702, a702);
      RETURN true;
    end;
  END;
  
  RecBufClear(a702);
  RETURN false;
end;


//========================================================================