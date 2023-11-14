@A+
//==== Business-Control ==================================================
//
//  Prozedur    MQu_Data
//                  OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  27.10.2011  AI  Korrektur bei BildeVorgaben
//  26.04.2012  MS  Neue Funktion: Read
//  01.06.2012  ST  Fehlerverhalten bei BildeVorgabe(...) verbessert,
//                  unbekannte Mech.werte bringen keinen Runtimefehler mehr,
//                  sondern geben '???', analog zur Chemie, zurück
//  06.0.2013   AI  "Autokorrektur" prüft auf nach Key "ErsetzenDurch"
//  17.03.2016  AH  Neu: "GetWerkstoffNr"
//  25.07.2016  AH  Bug: "BildeVorgaben" hat nicht über Feld "ErsetzenDurch" gesucht
//  09.02.2017  AH  Rauigkeit in MQu.M
//  03.04.2018  TM  Gütenkopie incl. Mechaniken
//  20.09.2018  AH  "Bildevorgaben" kann mit MoreBuf (231) arbeiten
//  22.11.2018  AH  Fix "GetWerkstoffNr"
//  17.07.2020  AH  Fix "CZ" als 2 Werte
//  27.11.2020  AH  Wert "-1" wird als "OHNE" interpretiert
//  04.02.2021  AH  MQu.Mechanik mit Gütenstufe
//  04.03.2021  AH  MQU.Mechanik mit Obf
//  02.07.2021  AH  MQU.Mechanik mit Obf aber Tolernatner bei Gross/Kleinschreibung und PSaces
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB Read(aGuete : alpha) : int;
//    SUB Autokorrektur(aText : alpha) : alpha;
//    SUB BildeVorgabe(aName : Alpha; aDatei : int; aGuete : alpha; aDicke : float; var aVon : float;  var aBis : float) : alpha;
//    SUB Import_TSR()
//    SUB Copy_Guete()
//
//========================================================================
@I:Def_Global

//========================================================================
//  Read  26.04.2012 MS
//        liest die Guete
//========================================================================
sub Read(
  aGuete            : alpha;
  opt aGuetenStufe  : alpha;      // 04.02.2021 AH
  opt aMechanikYN   : logic;
  opt aMechBisDicke : float;
  opt aObfString    : alpha) : int;
local begin
  Erx : int;
  vA  : alpha;
end;
begin

  aObfString # StrCnv(aObfString,_StrUpper);
  
  if (aGuete = '') then begin
    RecBufClear(832);
    RecBufClear(833);
    RETURN 0;
  end;

  MQU.ErsetzenDurch     # "aGuete";
  Erx # RecRead(832, 5, 0);
  if (Erx > _rMultikey) then begin
    RecBufClear(832);
    "MQU.Güte2"         # "aGuete";
    Erx # RecRead(832, 3, 0);
    if (Erx > _rMultikey) then begin
      RecBufClear(832);
      "MQU.Güte1"         # "aGuete";
      Erx # RecRead(832, 2, 0);
      if (Erx > _rMultikey) then begin
        RecBufClear(832);
        RecBufClear(833);
        RETURN 0;
      end;
    end;
  end;

  if(aMechanikYN = true) then begin // Mechanik lesen
    /*
    Erx # RecLink(833, 832, 1, _recFirst);
    if(Erx > _rLocked) then
      RecBufClear(833);
   */
    "MQu.M.GütenID"       # MQu.ID;
    "MQu.M.BeiGütenstufe" # aGuetenstufe;
    MQu.M.bisDicke        # aMechBisDicke;
    FOR Erx # RecRead(833, 2, 0)        // Mechanik lesen
    LOOP Erx # RecRead(833, 2, _recNext)
    WHILE (Erx<=_rNokey) and ("MQu.M.GütenID" = MQu.ID) and ("MQu.M.BeiGütenstufe" = aGuetenstufe) and (MQu.M.bisDicke >= aMechBisDicke) do begin
//debugx('KEY833');
      if (MQu.M.ZusatzKriteriu<>'') then begin
        if (StrCut(MQu.M.ZusatzKriteriu,1,4)=^'OBF:') then begin
          vA # '|'+StrAdj(StrCut(MQu.M.ZusatzKriteriu,5,20),_StrBegin|_Strend)+'|';
          vA # StrCnv(vA,_strupper);

//debugX('muss obf:'+vA+' muss in '+aObfString);
          if (StrFind(aObfString,vA,0)=0) then CYCLE;
        end;
      end;
//debugx('FOUND KEY833');
      RETURN MQu.ID;
    END;

//debugx('nix');
    // ggf. nochmal OHNE Stufe suchen
    if (aGuetenstufe<>'') then begin
      "MQu.M.GütenID"       # MQu.ID;
      "MQu.M.BeiGütenstufe" # '';
      MQu.M.bisDicke        # aMechBisDicke;
      FOR Erx # RecRead(833, 2, 0)        // Mechanik lesen
      LOOP Erx # RecRead(833, 2, _recNext)
      WHILE (Erx<=_rNoKey) and ("MQu.M.GütenID" = MQu.ID) and ("MQu.M.BeiGütenstufe" = '') and (MQu.M.bisDicke >= aMechBisDicke) do begin
//debugx('KEY833');
        if (MQu.M.ZusatzKriteriu<>'') then begin
          if (StrCut(MQu.M.ZusatzKriteriu,1,4)=^'OBF:') then begin
            vA # '|'+StrCnv(StrCut(MQu.M.ZusatzKriteriu,5,20),_strupper)+'|';
            if (StrFind(aObfString,vA,0)=0) then CYCLE;
          end;
        end;
//debugx('FOUND KEY833');
        RETURN MQu.ID;
      END;
    end;

    RecBufClear(833);
  end;

  RETURN MQu.ID;
end;


//========================================================================
//  Autokorrektur
//                Passt eine Güte an die richtige Schreibweise an
//========================================================================
sub Autokorrektur(
  var aText : alpha;
) : logic;
local begin
  Erx : int;
end;
begin
  RecBufClear(832);
  if (aText='') then RETURN false;
  if (StrFind(aText,';',1)<>0) then RETURN false;

  "MQu.Güte1" # StrCut(aText,1,64);
  Erx # RecRead(832,2,0);
  if (Erx<=_rMultikey) then begin
    //aWST # MQu.Werkstoffnr;
    if (MQu.ErsetzenDurch<>'') then begin
      aText # MQu.ErsetzenDurch;
      RETURN true;
    end;
    aText # "MQu.Güte1";
    RETURN true;
  end;

  "MQu.Güte2" # aText;
  Erx # RecRead(832,3,0)
  if (Erx<=_rMultikey) then begin
    if (MQu.ErsetzenDurch<>'') then begin
      aText # MQu.ErsetzenDurch;
      RETURN true;
    end;
    aText # "MQu.Güte2";
    RETURN true;
  end;

  "MQu.ErsetzenDurch" # aText;
  Erx # RecRead(832,5,0)
  if (Erx<=_rMultikey) then begin
    aText # "MQu.ErsetzenDurch";
    RETURN true;
  end;

  RecBufClear(832);
  aText # StrAdj(aText, _StrEnd);   // 22.02.2017 AH
  RETURN false;
end;


//========================================================================
//  BildeVorgabe
//
//========================================================================
sub BildeVorgabe(
  aName     : Alpha;
  aDatei    : int;
  aGuete    : alpha;
  aDicke    : float;
  var aVon  : float;
  var aBis  : float;
  opt aNoRead : logic;
) : alpha;
local begin
  Erx           : int;
  vA            : alpha;
  vSpez1,vSpez2 : float;
  vDin1,vDin2   : float;
  vN1,vN2       : float;
  vKomma        : int;
  vHatDIN       : logic;
  vHatSpez      : logic;
  vOffset       : int;
  vSonst        : alpha;
  v231          : int;
end;
begin

  // AFX
  vA # aName + '|' + Aint(aDatei) + '|' + aGuete + '|' + ANum(aDicke, Set.Stellen.Dicke)+'|'+abool(aNoRead);
  GV.Num.01 # aVon;
  GV.Num.02 # aBis;
  if (RunAFX('MQU.BildeVorgabe', vA) <> 0) then begin
    aVon # GV.Num.01;
    aBis # GV.Num.02;
    RETURN GV.Alpha.01;
  end;

  if (aGuete='') then RETURN '';

  if (aDatei>5000) then begin
//debugx(aNAme+' besondere '+aint(HdlInfo(aDatei,_HdlSubType)));
    if (HdlInfo(aDatei,_HdlSubType)=231) then begin
      v231  # aDatei;
      vHatSpez # true;
    end;
  end;

  // Qualitätsvorgabe suchen...
  vHatDIN # y;
  if (aNoRead=false) then begin
    "MQu.Güte1" # aGuete;
    Erx # RecRead(832,2,0);
    if (Erx>_rMultikey) then begin
      "MQu.Güte2" # aGuete;
      Erx # RecRead(832,3,0);
      if (Erx>_rMultikey) then begin
        "MQu.ErsetzenDurch" # aGuete;
        Erx # RecRead(832,5,0);
        if (Erx>_rMultikey) then vHatDIN # n;
      end;
    end;
  end;

  if (vHatDin=n) then RecBufClear(832);

  vKomma  # 5;

  if (StrLen(aName)>=6) then begin  // MECHANIK ****************************

    if (aNoRead=false) then begin
      RecbufClear(833);
      if (vHatDin) then begin
        "MQu.M.GütenID" # MQu.ID;
        MQu.M.bisDicke  # aDicke;
        Erx # RecRead(833,2,0);       // Mechanik lesen
        if (Erx<>_rNoRec) and ("MQu.M.GütenID"=MQu.ID) and
          (MQu.M.bisDicke>=aDicke) then begin
        end
        else begin
          RecBufClear(833);
          vHatDIN # n;
        end;
      end;
    end;


    case StrCnv(aName,_strUpper) of
      'SONSTIGES' : begin
        vSonst # MQU.Sonstiges;
        if (v231<>0) then vSonst # v231->Lys.Mech.Sonstiges;
        RETURN vSonst;
      end;
      'STRECKGRENZE' : begin   // Sreckgrenze
        vKomma  # 2;
        vDin1 # FldFloat(833,1,4);
        vDin2 # FldFloat(833,1,4+1);
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Streckgrenze;
          vSpez2 # v231->Lys.Streckgrenze2;
        end;
        vOffset # 1;
      end;
      'ZUGFESTIGKEIT' : begin   // Zugfestigkeit
        vKomma  # 2;
        vDin1 # FldFloat(833,1,6);
        vDin2 # FldFloat(833,1,6+1);
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Zugfestigkeit;
          vSpez2 # v231->Lys.Zugfestigkeit2;
        end;
        vOffset # 3;
      end;
      'DEHNUNGA' : begin   // DehnungBasis
        vKomma  # 2;
        vDin1 # FldFloat(833,1,18);
        vDin2 # vDin1;
        vOffset # 5;
        // spezielle Vorgaben im Auftrag?
        if (v231<>0) then begin
          vSpez1 # v231->Lys.DehnungB;
          vSpez2 # vSpez1;
        end;
        
        if (aDatei=401) then begin
          vHatSpez # y;
          if (Set.Mech.Dehnung.Wie=1) then
            vSpez1 # "Auf.P.DehnungA1";
          else
            vSpez1 # "Auf.P.DehnungB1";
          vSpez2 # vSpez1;
        end;
        if (aDatei=411) then begin
          vHatSpez # y;
          if (Set.Mech.Dehnung.Wie=1) then
            vSpez1 # "Auf~P.DehnungA1";
          else
            vSpez1 # "Auf~P.DehnungB1";
          vSpez2 # vSpez1;
        end;
        if (aDatei=501) then begin
          vHatSpez # y;
          if (Set.Mech.Dehnung.Wie=1) then
            vSpez1 # Ein.P.DehnungA1
          else
            vSpez1 # Ein.P.DehnungB1;
          vSpez2 # vSpez1;
        end;
        if (aDatei=511) then begin
          vHatSpez # y;
          if (Set.Mech.Dehnung.Wie=1) then
            vSpez1 # "Ein~P.DehnungA1";
          else
            vSpez1 # "Ein~P.DehnungB1";
          vSpez2 # vSpez1;
        end;
      end;
      'DEHNUNGB' : begin   // DehnungB = Werte
        vKomma  # 2;
        vDin1 # FldFloat(833,1,8);
        vDin2 # FldFloat(833,1,8+1);
        if (Set.Mech.Dehnung.Wie=1) then
          vOffset # 7;
        else
          vOffset # 5;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.DehnungB;
          vSpez2 # v231->Lys.DehnungC;
        end;
      end;
     
/*      'DEHNUNGB' : begin   // DehnungB -> DehnungA
        vDin1 # FldFloat(833,1,8);
        vDin2 # FldFloat(833,1,8+1);
        vOffset # 7;
      end;
*/
      'DEHNGRENZEA'   : begin   // DehngrenzeA
        vKomma  # 2;
        vOffset # 9;
        vDin1 # FldFloat(833,1,14);
        vDin2 # FldFloat(833,1,14+1);
        if (v231<>0) then begin
          vSpez1 # v231->Lys.DehnungA;
          vSpez2 # vSpez2;
        end;
        
      end;
      'DEHNGRENZEB'   : begin   // DehngrenzeB
        vKomma  # 2;
        vOffset # 11;
        vDin1 # FldFloat(833,1,16);
        vDin2 # FldFloat(833,1,16+1);
        if (v231<>0) then begin
          vSpez1 # v231->Lys.DehnungA;
          vSpez2 # vSpez2;
        end;
      end;
      'KOERNUNG'      : begin   // Körnung
        vKomma  # 2;
        vDin1 # FldFloat(833,1,10);
        vDin2 # FldFloat(833,1,10+1);
        vOffset # 13;
        if (v231<>0) then begin
          vSpez1 # v231->"Lys.Körnung";
          vSpez2 # v231->"Lys.Körnung2";
        end;
      end;
      'HAERTE'        : begin   // Härte
        vKomma  # 2;
        vDin1 # FldFloat(833,1,12);
        vDin2 # FldFloat(833,1,12+1);
        vOffset # 45;
        if (v231<>0) then begin
          vSpez1 # v231->"Lys.Härte1";
          vSpez2 # v231->"Lys.Härte2";
        end;
      end;
      'RAUIGKEITA'        : begin   // RauigkeitA
        vKomma  # 3;
        vDin1 # FldFloat(833,1,19);
        vDin2 # FldFloat(833,1,20);
        vOffset # 50;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.RauigkeitA1;
          vSpez2 # v231->Lys.RauigkeitA2;
        end;
      end;
      'RAUIGKEITB'        : begin   // RauigkeitB
        vKomma  # 3;
        vDin1 # FldFloat(833,1,21);
        vDin2 # FldFloat(833,1,22);
        vOffset # 52;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.RauigkeitB1;
          vSpez2 # v231->Lys.RauigkeitB2;
        end;
      end;
      otherwise begin
        if (v231<>0) then begin
          case StrCnv(aName,_strUpper) of
            'STRECKGRENZEQ' : begin   // SreckgrenzeQ
              vKomma  # 2;
              vSpez1 # v231->Lys.StreckgrenzeQ1;
              vSpez2 # v231->Lys.StreckgrenzeQ2;
            end;
            'ZUGFESTIGKEITQ' : begin   // ZugfestigkeitQ
              vKomma  # 2;
              vSpez1 # v231->Lys.ZugfestigkeitQ1;
              vSpez2 # v231->Lys.ZugfestigkeitQ2;
            end;
            'DEHNUNGBQ' : begin   // DehnungBQ
              vKomma  # 2;
              vSpez1 # v231->Lys.DehnungQB;
              vSpez2 # v231->Lys.DehnungQC;
            end;
            'RAUIGKEITC'        : begin   // RauigkeitC
              vKomma  # 3;
              vSpez1 # v231->Lys.RauigkeitC1;
              vSpez2 # v231->Lys.RauigkeitC2;
            end;
            'SGVERHAELTNIS' : begin   // Streckgrenzenverhätnis
              vKomma  # 2;
              vSpez1 # v231->Lys.SGVerhaeltnis1;
              vSpez2 # v231->Lys.SGVerhaeltnis2;
            end;
            'MECH_CG' : begin   // CG
              vKomma  # 1;
              vSpez1 # v231->Lys.CG1;
              vSpez2 # v231->Lys.CG2;
            end;
            'MECH_FA' : begin   // FA
              vKomma  # 1;
              vSpez1 # v231->Lys.FA1;
              vSpez2 # v231->Lys.FA2;
            end;
            'MECH_PA' : begin   // PA
              vKomma  # 1;
              vSpez1 # v231->Lys.PA1;
              vSpez2 # v231->Lys.PA2;
            end;
            'MECH_CN' : begin   // CN
              vKomma  # 1;
              vSpez1 # v231->Lys.CN1;
              vSpez2 # v231->Lys.CN2;
            end;
            'MECH_CZ1' : begin   // CZ
              vKomma  # 1;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.CZ1;
            end;
            'MECH_CZ2' : begin   // CZ
              vKomma  # 1;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.CZ2;
            end;
            'MECH_ZE' : begin   // ZE
              vKomma  # 1;
              vSpez1 # v231->Lys.ZE1;
              vSpez2 # v231->Lys.ZE2;
            end;
            'MECH_HC' : begin   // HC
              vKomma  # 1;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.HC;
            end;
            'MECH_SS' : begin   // SS
              vKomma  # 1;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.SS;
            end;
            'MECH_OA' : begin   // OA
              vKomma  # 1;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.OA;
            end;
            'MECH_OS' : begin   // OS
              vKomma  # 1;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.OS;
            end;
            'MECH_OG' : begin   // OG
              vKomma  # 1;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.OG;
            end;
            'PARALLEL' : begin   // Parallelität
              vKomma  # 3;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.Parallelitaet;
            end;
            'PLANLAGE' : begin   // Planlage
              vKomma  # 2;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.Planlage;
            end;
            'EBENHEIT' : begin   // Ebenheit
              vKomma  # 2;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.Ebenheit;
            end;
            'SAEBEL' : begin   // Säbeligkeit
              vKomma  # 2;
              vSpez1 # 0.0;
              vSpez2 # v231->Lys.Saebeligkeit;
            end;
            
            otherwise RETURN '???'; // KEINE AHNUNG WAS DER TESTBEGRIFF IST !!!
          end;
        end;
      end;

    end; // case

  end // Mechanik

  else begin  // CHEMIE ****************************************************

    case StrCnv(aName,_strUpper) of
      'C' : begin
        vDin1 # FldFloat(832,2,1);
        vDin2 # FldFloat(832,2,2);
        vOffset # 15;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.C;
          vSpez2 # v231->Lys.Chemie.C2;
        end;
      end;

      'SI' : begin
        vDin1 # FldFloat(832,2,3);
        vDin2 # FldFloat(832,2,4);
        vOffset # 17;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.SI;
          vSpez2 # v231->Lys.Chemie.SI2;
        end;
      end;

      'MN' : begin
        vDin1 # FldFloat(832,2,5);
        vDin2 # FldFloat(832,2,6);
        vOffset # 19;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.MN;
          vSpez2 # v231->Lys.Chemie.MN2;
        end;
      end;

      'P' : begin
        vDin1 # FldFloat(832,2,7);
        vDin2 # FldFloat(832,2,8);
        vOffset # 21;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.P;
          vSpez2 # v231->Lys.Chemie.P2;
        end;
      end;

      'S' : begin
        vDin1 # FldFloat(832,2,9);
        vDin2 # FldFloat(832,2,10);
        vOffset # 23;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.S;
          vSpez2 # v231->Lys.Chemie.S2;
        end;
      end;

      'AL' : begin
        vDin1 # FldFloat(832,2,11);
        vDin2 # FldFloat(832,2,12);
        vOffset # 25;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.AL;
          vSpez2 # v231->Lys.Chemie.AL2;
        end;
      end;

      'CR' : begin
        vDin1 # FldFloat(832,2,13);
        vDin2 # FldFloat(832,2,14);
        vOffset # 27;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.CR;
          vSpez2 # v231->Lys.Chemie.CR2;
        end;
      end;

      'V' : begin
        vDin1 # FldFloat(832,2,15);
        vDin2 # FldFloat(832,2,16);
        vOffset # 29;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.V;
          vSpez2 # v231->Lys.Chemie.V2;
        end;
      end;

      'NB' : begin
        vDin1 # FldFloat(832,2,17);
        vDin2 # FldFloat(832,2,18);
        vOffset # 31;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.NB;
          vSpez2 # v231->Lys.Chemie.NB2;
        end;
      end;

      'TI' : begin
        vDin1 # FldFloat(832,2,19);
        vDin2 # FldFloat(832,2,20);
        vOffset # 33;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.TI;
          vSpez2 # v231->Lys.Chemie.TI2;
        end;
      end;

      'N' : begin
        vDin1 # FldFloat(832,2,21);
        vDin2 # FldFloat(832,2,22);
        vOffset # 35;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.N;
          vSpez2 # v231->Lys.Chemie.N2;
        end;
      end;

      'CU' : begin
        vDin1 # FldFloat(832,2,23);
        vDin2 # FldFloat(832,2,24);
        vOffset # 37;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.CU;
          vSpez2 # v231->Lys.Chemie.CU2;
        end;
      end;

      'NI' : begin
        vDin1 # FldFloat(832,2,25);
        vDin2 # FldFloat(832,2,26);
        vOffset # 39;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.NI;
          vSpez2 # v231->Lys.Chemie.NI2;
        end;
      end;

      'MO' : begin
        vDin1 # FldFloat(832,2,27);
        vDin2 # FldFloat(832,2,28);
        vOffset # 41;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.MO;
          vSpez2 # v231->Lys.Chemie.MO2;
        end;
      end;

      'B' : begin
        vDin1 # FldFloat(832,2,29);
        vDin2 # FldFloat(832,2,30);
        vOffset # 43;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.B;
          vSpez2 # v231->Lys.Chemie.B2;
        end;
      end;

      'FREI1' : begin
        vDin1 # FldFloat(832,2,31);
        vDin2 # FldFloat(832,2,32);
        vOffset # 47;
        if (v231<>0) then begin
          vSpez1 # v231->Lys.Chemie.Frei1;
          vSpez2 # v231->Lys.Chemie.Frei1_2;
        end;
      end;

      otherwise RETURN '???';

    end;  // case
  end;  // Chemie

  if (vHatDIN) and (vDin1=0.0) and (vDin2=0.0) then vHatDin # n;  // DIN nicht ausgefüllt?

  if (vHatSpez=false) and (vOffset<>0) then begin
    // spezielle Vorgaben im Auftrag?
    if (aDatei=401) then begin
      vHatSpez # y;
      vSpez1 # FldFloat(401,3,vOffset);
      vSpez2 # FldFloat(401,3,vOffset+1);
    end;
    if (aDatei=411) then begin
      vHatSpez # y;
      vSpez1 # FldFloat(411,3,vOffset);
      vSpez2 # FldFloat(411,3,vOffset+1);
    end;
    if (aDatei=501) then begin
      vHatSpez # y;
      vSpez1 # FldFloat(501,3,vOffset);
      vSpez2 # FldFloat(501,3,vOffset+1);
    end;
    if (aDatei=511) then begin
      vHatSpez # y;
      vSpez1 # FldFloat(511,3,vOffset);
      vSpez2 # FldFloat(511,3,vOffset+1);
    end;
  end;
  if (vHatSpez) and (vSpez1=0.0) and (vSpez2=0.0) then vHatSpez # n;  // nicht ausgefüllt?


  if (vHatSpez=false) and (vHatDIN=false) then RETURN '';

  // 2022-09-08 AH : Felder EINZELN betrachten, nicht als Eigenschafts-Einheit
  if (Set.Installname='LZM') then begin
    // erst mal DIN nehmen
    vN1 # vDIN1;
    vN2 # vDIN2;
    if (vHatSpez) then begin
      if (vSpez1<>0.0) then vN1 # vSpez1;
      if (vSpez2<>0.0) then vN2 # vSpez2;
    end;
  end
  else begin
    if (vHatSpez) then begin
      vN1 # vSpez1;
      vN2 # vSpez2;
    end
    else begin
      vN1 # vDIN1;
      vN2 # vDIN2;
    end;
  end;

// vN1,vN2 = Von,Bis
  if (vN1=-1.0) or (vN2=-1.0) then begin
    vA # Translate('ohne (entspricht -1)');
    aVon # -1.0;
    aBis # -1.0;
    RETURN vA;
  end;

  if (vN1=vN2) and (vN1<>0.0) then
    vA #  ANum(vN1, vKomma)
  else if (vN1<>0.0) and (vN2<>0.0) then
    vA # ANum(vN1, vKomma) + ' - ' + ANum(vN2, vKomma)
  else if (vN1=0.0) and (vN2<>0.0) then
    vA #  'max. ' + ANum(vN2,vKomma)
  else if (vN1<>0.0) and (vN2=0.0) then
    vA #  'min. ' + ANum(vN1,vKomma)
  else
    vA # '';


  aVon # vN1;
  aBis # vN2;

  // 01.09.2017 AH:
  if (aBis=0.0) and (aVon<>0.0) then
    aBis # 999999.0;

//  if (aVon<>0.0) and (aBis=0.0) then aBis # 999999.0;
//debug(aname+' '+vA);
//if (aName='Si') then
//debug(anum(aVon,2)+' - '+anum(aBis,2));
  RETURN vA;
end;


//========================================================================
// GetWerkstoffNr
//
//========================================================================
sub GetWerkstoffNr(aGuete : alpha) : alpha;
local begin
  Erx : int;
end;
begin
  MQU.ErsetzenDurch     # aGuete;
  Erx # RecRead(832,5,0);
  if (Erx<=_rMultikey) then begin
    RETURN MQU.Werkstoffnr
  end
  else begin
    "MQU.Güte2"         # aGuete;
    Erx # RecRead(832,3,0);
    if (Erx<=_rMultikey) then begin
      RETURN MQU.Werkstoffnr
    end
    else begin
      "MQU.Güte1"         # aGuete;
      Erx # RecRead(832,2,0);
      if (Erx<=_rMultikey) then
        RETURN MQU.Werkstoffnr
    end;
  end;

  RETURN '';
end;


//========================================================================
//  Copy_Guete
// Call SFX_BSP_MQu:Copy_Guete
//========================================================================
sub Copy_Guete
local begin
  Erx         : int;
  vOK         : Logic;
  vMitMechYN  : Logic;
  vBuf832     : int;
  vBuf833     : int;
  vVonGueteID : int;
  vNeuGueteID : int;
end;
begin

  // 1. Güte unter Cursor in den Puffer laden
  Erx # RecRead(832,1,0);
  vBuf832 # RekSave(832);
  vVonGueteID # MQu.ID;;
  // 2. ABFRAGEDIALOG "Güte im Puffer kopieren?"
  Erx # Msg(99,'Kopie der Güte '+"MQu.Güte1"+' anlegen?',_WinIcoQuestion,_WinDialogYesNo,0);
  TRANSON;
  if (Erx != _winidyes) then
    RETURN;

  // 3. Güte aus dem Puffer unter neuer Nummer speichern
  // RekRestore(vBuf832);
  

  MQu.ID # Lib_Nummern:ReadNummer('Qualitäten');    // Nummer lesen
  Lib_Nummern:SaveNummer();
  vNeuGueteID # MQu.ID;
  Erx # RekInsert(832,_recUnLock);
    if (Erx<>0) then begin
      TRANSBRK;
      Msg(999999,'Güte +'+"MQu.Güte1"+' nicht speicherbar',0,0,0);
      RETURN;
    end;
  TRANSOFF;
  // 4. ABFRAGEDIALOG "Mechaniken mitkopieren?"
  Erx # Msg(99,'Mechaniken zur Güte '+"MQu.Güte1"+' mit übernehmen?',_WinIcoQuestion,_WinDialogYesNo,0);
  if (Erx != _winidyes) then begin
    Erx # Msg(99,'Güte '+"MQu.Güte1"+' kopiert, neue ID '+cnvai(vNeuGueteID),_WinIcoInformation,_WinDialogOk,0);
    RETURN;
  end;
    
  TRANSON;
  // 5. Alle Gütenmechaniken zur ursprünglichen Güte durchlaufen
  MQu.ID # vVonGueteID;
  Erx # RecRead(832,1,0);
  
  FOR Erx # RecLink(833,832,1,_RecFirst)
  LOOP Erx # RecLink(833,832,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    vBuf833 # RekSave(833);
    // 6. Jeden einzelnen Mechanik-Datensatz im Puffer zwischenspeichern und unter neuer Gütennummer anlegen
    "MQu.M.GütenID" # vNeuGueteID;
    Erx # RekInsert(833,_recUnLock);
    if (Erx<>0) then begin
      TRANSBRK;
      Msg(999999,'Fehler beim Speichern der Gütenmechanik',0,0,0);
      RETURN;
    end;


    RekRestore(vBuf833);
  END;
  TRANSOFF;
  Erx # Msg(99,'Güte '+"MQu.Güte1"+' kopiert, neue ID '+cnvai(vNeuGueteID),_WinIcoInformation,_WinDialogOk,0);

end;


//========================================================================
//  call MQU_Data:CleanMechChemie
//========================================================================
sub CleanMechChemie()
local begin
  Erx : int;
end;
begin
  FOR Erx # recRead(832,1,_recFirst)
  LOOP Erx # recRead(832,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecRead(832,1,_recLock);
    SbrClear(832,2);
    Rekreplace(832);
  END;
  
  FOR Erx # recRead(833,1,_recFirst)
  LOOP Erx # recRead(833,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecRead(833,1,_recLock);
    MQu.M.Von.StreckG     # 0.0;
    MQu.M.Bis.StreckG     # 0.0;
    MQu.M.Von.Zugfest     # 0.0;
    MQu.M.Bis.Zugfest     # 0.0;
    MQu.M.Von.Dehnung     # 0.0;
    MQu.M.Bis.Dehnung     # 0.0;
    "MQu.M.Von.Körnung"   # 0.0;
    "MQu.M.Bis.Körnung"   # 0.0;
    "MQu.M.Von.Härte"     # 0.0;
    "MQu.M.Bis.Härte"     # 0.0;
    MQu.M.Von.DehnGrenzA  # 0.0;
    MQu.M.Bis.DehnGrenzA  # 0.0;
    MQu.M.Von.DehnGrenzB  # 0.0;
    MQu.M.Bis.DehnGrenzB  # 0.0;
    MQu.M.Dehnung.Basis   # 0.0;
    MQu.M.Von.RauigkeitO  # 0.0;
    MQu.M.Bis.RauigkeitO  # 0.0;
    MQu.M.Von.RauigkeitU  # 0.0;
    MQu.M.Bis.RauigkeitU  # 0.0;
    MQu.M.HaerteTyp       # '';
    MQu.M.StreckgrenzTyp  # '';
    MQu.M.ZugfestigTyp    # '';
    Rekreplace(833);
  END;
  
end;

//========================================================================