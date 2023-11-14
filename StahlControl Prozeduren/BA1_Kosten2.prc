@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Kosten2
//                OHNE E_R_G
//  Info
//
//
//  28.03.2017  AH  Erstellung der Prozedur
//  04.05.2017  AH  BugFix: bei verketteten BAs (Fahren als 1.), wurden nicht alle Mats geadded
//  06.11.2017  AH  Stornierte Wiegungne (IO.Ist.In haben dann Mengen = 0) werden NICHT berührt (Problem war, Stornowiegung auf entfertem Einsstzmat)
//  14.11.2017  AH  Fehlermeldugen erweitert
//  07.12.2017  AH  "_SetArtEK" setzt TRUE
//  22.02.2019  AH  neuer AFX "BAG.FM.Set.MatABemerkung"
//  03.07.2019  AH  Fix: weitere Kinder von FM, bekommen die Kosten bei Abschluss auch, wenn gleiches Datum (SSW Problem!)
//  16.10.2019  AH  Fix: Recalc ignorierte geplante Schrotte
//  21.02.2021  AH  CO2
//  23.02.2021  AH  CO2 Walzstiche
//  24.02.2021  AH  CO2 Fahren
//  03.03.2021  AH  CO2-Schrottumlagen in extra Mat-Feld
//  18.03.2021  AH  CO2 Umbau für Eigen/Fremd Anteil
//  19.03.2021  AH  Schrotterlös einbeziehen
//  11.10.2021  AH  ERX
//  2022-07-05  AH  DEADLOCK
//  2022-08-31  AH/ST "GetFahrCO2Kosten" auf Gewicht bezogen
//
//  Subprozeduren
//    SUB KillAllMatAktionen(aTyp : alpha; aNr : int; aPos : int; aPos2 : int) : logic;
//    sub NeueAktion(aMatNr  : int;aAkt    : alpha; aBemerk : alpha; aPreis  : float;   aBasis  : float;  aAdr : int; aDatum : date) : logic;
//    sub AnWeiterbearbeitungen(aPos : int; aAkt : alpha; aBem1 : alpha; aBem2 : alpha; aPreis : float; aAdr : int; aNurID : int) : logic;
//    sub _Inner(aPos : int; aAkt : alpha; aBem1 : alpha; aBem2 : alpha; aWert : float; aAdr : int; aNurID : int;) : logic
//    sub Pos2Fert(aPos : int; aAG : alpha; aAdr : int) : logic
//
//    SUB UpdatePosition(aBAG : int; aPos : int; opt aSilent : logic; opt aNoProto : logic; opt aDiffTxt : int; opt aNoTrans : logic) : logic;
//
//
//========================================================================
@I:Def_Global
@I:Def_aktionen
@I:Def_BAG

//@Define PROTOKOLL

define begin
  mydebug(a)  : debug(StrChar(32,Gv.Int.01*3)+a)
  print(a) : debug(cnvaf(a))
  //: TextAddLine(vProtokoll, a)//debug(StrChar(32,Gv.Int.01*3)+a)
  //cVerschrotteBasis : false
  //true
  plus        : inc(gv.int.01)
  minus       : dec(gv.int.01)
  myWinclose(a) : begin if(aSilent = false) then begin Winclose(a); if (vMDI->wpcustom<>'') and (vMDI->wpcustom<>cnvai(VarInfo(WindowBonus))) then    VarInstance(WindowBonus,cnvIA(vMDI->wpcustom)); end; end
  Stop      : begin APPON(); GV.Alpha.99 # GV.Alpha.99 + ';'+aint(__LINE__); RETURN false; end;
  
  c_Akt_BA_UmlageSchrottErloes    : 'SCHVK'
  c_AktBem_BA_UmlageSchrottErloes : 'Schrottverkauf'
end;

global Struct_BA_Kost_Mat begin
  s_BA_Kost_Mat_Nr          : int;
  s_BA_Kost_Mat_Datei       : int;
  s_BA_Kost_Mat_Mody        : logic;
  s_BA_Kost_Mat_KG          : float;
  s_BA_Kost_Mat_Menge       : float;
  s_BA_Kost_Mat_StartKG     : float;
  s_BA_Kost_Mat_StartMenge  : float;
  s_BA_Kost_Mat_LoeschMark  : alpha;
  s_BA_Kost_Mat_Laut        : alpha;
  s_BA_Kost_Mat_Struktur    : alpha;
  s_BA_Kost_Mat_EkPreis     : float;
  s_BA_Kost_Mat_EkPreisPro  : float;
  s_BA_Kost_Mat_Kosten      : float;
  s_BA_Kost_Mat_KostenPro   : float;

  s_BA_Kost_Mat_CO2         : float;
  s_BA_Kost_Mat_CO2Kosten   : float;
  s_BA_Kost_Mat_CO2Schrott  : float;
end;

global Struct_BA_Kost_Akt begin
  s_BA_Kost_Akt_RecID       : Bigint;
  s_BA_Kost_Akt_Todo        : alpha;
  s_BA_Kost_Akt_MatNr       : int;
  s_BA_Kost_Akt_Typ         : alpha;
  s_BA_Kost_Akt_Nr          : int;
  s_BA_Kost_Akt_Pos         : int;
  s_BA_Kost_Akt_Adr         : int;
  s_BA_Kost_Akt_Bem         : alpha;
  s_BA_Kost_Akt_Datum       : date;
  s_BA_Kost_Akt_Start       : date;
  s_BA_Kost_Akt_Ende        : date;
  s_BA_Kost_Akt_KSt         : int;
  s_BA_Kost_Akt_Kosten      : float;
  s_BA_Kost_Akt_KostenPro   : float;

  s_BA_Kost_Akt_CO2Kosten   : float;
end;


declare Pos2Fert(
  aPos              : int;
  aAG               : alpha;
  aAdr              : int;
  aAnteilSchrott    : float;
  aAnteilKosten     : float;
  aAnteilCo2Eigen   : float;
  aAnteilCo2fremd   : float;
  aAnteilSchrottERl : float;
  aSchrottPreis     : float;
) : logic

declare _Inner(  aPos      : int;
  aAkt      : alpha;
  aBem1     : alpha;
  aBem2     : alpha;
  aWert     : float;
  aCO2      : float;
  aAdr      : int;
  aNurID    : int;
) : logic

local begin
  gStartDat       : date;
  gStartTim       : time;
  gAbschlussAm    : date;
  gAbschlussUm    : time;
  vProtokoll      : int;
  gMatDict        : int;
  gAktDict        : int;
  gBBDict         : int;
  gDiffTxt        : int;
end;


//========================================================================
// braucht 200
//========================================================================
sub _SetArtEK() : logic;
local begin
  Erx     : int;
  vMenge  : float;
  vWert   : float;
end;
begin

  if (s_BA_Kost_Mat_Laut<>'D') then RETURN true;
  if (s_BA_Kost_Mat_Struktur='') then RETURN true;


  if (Mat_Data:Read(s_BA_Kost_Mat_Nr)<200) then
    RETURN false;

  if (s_BA_Kost_Mat_Struktur<>Art.Nummer) then begin
    Erx # RekLink(250,200,26,_recFirst);  // Artikel holen
    if (Erx>_rLocked) then RETURN false;
  end;

  if (Art_P_Data:FindePreis('Ø-EK', 0, 0.0, '', 1)=false) then RETURN true;

  vMenge # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Art.MEH) ,2);
  vWert  # Rnd(Art.P.PreisW1 * vMenge / Cnvfi(Art.PEH) ,2); // Gesamtwert
//debugx('neuer EK auf Basis: '+anum(vMenge, 2)+Art.MEH+' mit Wert: '+anum(vWert,2));

  s_BA_Kost_Mat_Mody  # true;
  s_BA_Kost_Mat_Laut  # '';
  if (Mat.Bestand.Gew<>0.0) then
    s_BA_Kost_Mat_EkPreis # Rnd(vWert / Mat.Bestand.Gew * 1000.0 ,2);
  if (Mat.Bestand.Menge<>0.0) then
    s_BA_Kost_Mat_EkPreisPro # Rnd(vWert / Mat.Bestand.Menge ,2);

  RETURN true;
end;


//========================================================================
//========================================================================
sub _MatRead(aMat : int) : logic;
local begin
  vInhalt : alpha;
  vInst   : bigint;
end;
begin
  if (Lib_Dict:ReadExt(var gMatDict, aint(aMat), var vInhalt, var vInst)=false) then begin
debugX('nicht gefunden '+aint(aMat));
    RETURN false;
  end;

  if (vInst=0) then RETURN false;

  VarInstance(struct_BA_Kost_Mat, vInst);

  Mat.Bewertung.Laut  # s_BA_Kost_Mat_Laut;
  Mat.Strukturnr      # s_BA_Kost_Mat_Struktur;
  "Mat.Löschmarker"   # s_BA_Kost_Mat_LoeschMark;
  Mat.EK.Preis        # s_BA_Kost_Mat_EkPreis;
  Mat.EK.PreisProMEH  # s_BA_Kost_Mat_EkPreisPro
  Mat.Kosten          # s_BA_Kost_Mat_Kosten;
  Mat.KostenProMEH    # s_BA_Kost_Mat_KostenPro;
  Mat.EK.Effektiv     # s_BA_Kost_Mat_EkPreis + s_BA_Kost_Mat_Kosten;
  Mat.EK.EffektivProME  # s_BA_Kost_Mat_EkPreisPro + s_BA_Kost_Mat_KostenPro;
  Mat.Bestand.Gew     # s_BA_Kost_Mat_KG;
//debugx('LOAD KEY200');
  Mat.CO2EinstandProT # s_BA_Kost_Mat_CO2;
  Mat.CO2ZuwachsProT  # s_BA_Kost_Mat_CO2Kosten;
  Mat.CO2SchrottProT  # s_BA_Kost_Mat_CO2Schrott;
  RETURN true;
end;


//========================================================================
//========================================================================
sub _MatAdd(
  aMat          : int;
  aIstRest      : logic;
  aIstKombi     : logic) : logic;
local begin
  Erx     : int;
  v200    : int;
  v200b   : int;
  v204    : int;
  vDatei  : int;
  vBuf    : int;
end;
begin

  // schon da?
  if (Lib_Dict:Exists(var gMatDict, aint(aMat))=true) then
    RETURN _MatRead(aMat);
//debugx('MATADD:'+aint(aMat));
  v200 # RekSave(200);
  vDatei # Mat_Data:Read(aMat,_recLock);
  if (vDatei<200) then begin
    RekRestore(v200);
    RETURN false;
  end;

  vBuf # VarAllocate(struct_BA_Kost_Mat);
  s_BA_Kost_Mat_Nr          # Mat.Nummer;
  s_BA_Kost_Mat_Datei       # vDatei;
  s_BA_Kost_Mat_Mody        # false;
  s_BA_Kost_Mat_Laut        # Mat.Bewertung.Laut;
  s_BA_Kost_Mat_LoeschMark  # "Mat.Löschmarker";
  s_BA_Kost_Mat_Struktur    # Mat.Strukturnr;
  s_BA_Kost_Mat_KG          # Mat.Bestand.Gew;
  s_BA_Kost_Mat_Menge       # Mat.Bestand.Menge;
  s_BA_Kost_Mat_EkPreis     # Mat.EK.Preis;
  s_BA_Kost_Mat_EkPreisPro  # Mat.EK.PreisProMEH;
  s_BA_Kost_Mat_Kosten      # Mat.Kosten;
  s_BA_Kost_Mat_KostenPro   # Mat.KostenProMEH;

  s_BA_Kost_Mat_CO2         # Mat.CO2EinstandProT;
  s_BA_Kost_Mat_CO2Kosten   # Mat.CO2ZuwachsProT;
  s_BA_Kost_mat_CO2Schrott  # Mat.CO2SchrottProT;

  if (aIstKombi) then begin
    s_BA_Kost_Mat_StartKG     # s_BA_Kost_Mat_KG;
    s_BA_Kost_Mat_StartMenge  # s_BA_Kost_Mat_Menge;
    // ALLE früheren Einträge zurückrechnen
    FOR   Erx  # RecLink(202,200,12,_RecLast)
    LOOP  Erx  # RecLink(202,200,12,_RecPrev)
    WHILE (Erx <= _rOK) do begin
      s_BA_Kost_Mat_StartKG     # s_BA_Kost_Mat_StartKG - Mat.B.Gewicht;
      s_BA_Kost_Mat_StartMenge  # s_BA_Kost_Mat_StartMenge - Mat.B.Menge;
    END;
  end;

  if (Lib_Dict:Add(var gMatDict, aint(aMat), aint(vDatei), vBuf)=false) then begin
    RekRestore(v200);
    VarFree(struct_BA_Kost_Mat);
    RETURN false;
  end;

  // Vorgänger adden
  if ("Mat.Vorgänger"<>0) then begin
    if (_MatAdd("Mat.Vorgänger", false, false)=false) then begin
      RekRestore(v200);
      RETURN false;
    end;
  end;


  v200b # RekSave(200);   // 26.02.2021 AH: Fix für Einsatz 1. aus 2. gesplittet (GW!)

  // Aktionen loopen...
  FOR Erx # RecLink(204,200,14,_recFirst)
  LOOP Erx # RecLink(204,200,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.A.Entstanden=0) then CYCLE;

    // bei Schrottkarten: falls Kinder VOR Abschluss, dann NICHT berühren
    if (aIstRest) then begin
      if (Mat.A.Aktionsdatum<gAbschlussAm) then CYCLE;
    end;

    v204 # RekSave(204);
    if (_MatAdd(Mat.A.Entstanden, Mat.A.Aktionstyp=c_Akt_BA_Rest, Mat.A.Aktionstyp=c_Akt_Mat_Kombi)=false) then begin
      RecBufDestroy(v200b);
      RekRestore(v204);
      RekRestore(v200);
      RETURN false;
    end;
    RecBufCopy(v200b,200);
    RekRestore(v204);
    RecRead(204,1,0);
  END;
  RecBufDestroy(v200b);

  RekRestore(v200);
  RETURN true;
end;


//========================================================================
//========================================================================
sub __AktAdd(
  aBuf    : int;
  aKey    : alpha;
  aRecID  : bigint;
  aTodo   : alpha;
): logic;
local begin
  vBuf  : int;
end;
begin
  vBuf # VarAllocate(struct_BA_Kost_Akt);
//debugx('ALLOC '+aint(vBuf));
  s_BA_Kost_Akt_RecID       # aRecID;
  s_BA_Kost_Akt_Todo        # aTodo;
  s_BA_Kost_Akt_MatNr       # aBuf->Mat.A.Materialnr;
  s_BA_Kost_Akt_Typ         # aBuf->Mat.A.Aktionstyp;
  s_BA_Kost_Akt_Nr          # aBuf->Mat.A.Aktionsnr;
  s_BA_Kost_Akt_Pos         # aBuf->Mat.A.Aktionspos;
  s_BA_Kost_Akt_Bem         # aBuf->Mat.A.Bemerkung;
  s_BA_Kost_Akt_Datum       # aBuf->Mat.A.Aktionsdatum;
  s_BA_Kost_Akt_Start       # aBuf->Mat.A.TerminStart;
  s_BA_Kost_Akt_Ende        # aBuf->Mat.A.TerminEnde;
  s_BA_Kost_Akt_Adr         # aBuf->Mat.A.Adressnr;
  s_BA_Kost_Akt_KST         # aBuf->Mat.A.Kostenstelle;
  s_BA_Kost_Akt_Kosten      # aBuf->Mat.A.KostenW1;
  s_BA_Kost_Akt_KostenPro   # aBuf->Mat.A.KostenW1ProMEH;
  s_BA_Kost_Akt_CO2Kosten   # aBuf->Mat.A.CO2ProT;
  
  if (Lib_Dict:Add(var gAktDict, aKey, '', vBuf)=false) then begin
//debugx('xFREE '+aint(varinfo(struct_BA_Kost_Akt)));
    VarFree(struct_BA_Kost_Akt);
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _AktMod(
  aBuf      : int;
  aKost     : float;
  aKostPro  : float;
  aCO2      : float;
) : logic;
local begin
  vInhalt : alpha;
  vKey    : alpha;
  vInst   : Bigint;
end;
begin

  vKey # 'KOSTEN'+aint(aBuf->Mat.A.Materialnr)+'/'+aint(aBuf->Mat.A.Aktion);
//debugX('Suche für :'+vkey);
  if (Lib_Dict:ReadExt(var gAktDict, vKey, var vInhalt, var vInst)=true) then begin
    if (vInst=0) then RETURN false;
//debugx('INST :'+aint(vInst));
    VarInstance(struct_BA_Kost_akt, vInst);
    s_BA_Kost_Akt_Kosten    # s_BA_Kost_Akt_Kosten + aKost;
    s_BA_Kost_Akt_KostenPro # s_BA_Kost_Akt_KostenPro + aKostPro;
    s_BA_Kost_Akt_CO2Kosten # s_BA_Kost_Akt_CO2Kosten + aCo2;
    RETURN true
  end;

  aBuf->Mat.A.KostenW1        # aKost;
  aBuf->Mat.A.KostenW1ProMEH  # aKostPro;
  aBuf->Mat.A.CO2ProT         # aCo2;
  RETURN __AktAdd(aBuf, vKey, RecInfo(aBuf,_recId), 'KOSTEN');
end;


//========================================================================
//========================================================================
sub _AktDel204() : logic;
local begin
  vInhalt : alpha;
  vInst   : bigint;
  vKey    : alpha;
end;
begin

  //vKey # aint(Mat.A.Materialnr)+Mat.A.Aktionstyp;
  vKey # aint(Mat.A.Materialnr)+'/'+aint(Mat.A.Aktion);

  if (Lib_Dict:ReadExt(var gAktDict, vKey, var vInhalt, var vInst)=true) then begin
    if (vInst=0) then RETURN false;
    VarInstance(struct_BA_Kost_akt, vInst);
    s_BA_Kost_Akt_Todo # 'DEL';
    RETURN true;
  end;

  RETURN __AktAdd(RecBufDefault(204), vKey, RecInfo(204,_RecID), 'DEL');
end;


//========================================================================
//========================================================================
sub _AktNeu204() : logic;
local begin
  vInhalt : alpha;
  vInst   : bigint;
  vKey    : alpha;
  vItem   : int;
  vRecID  : BigInt;
end;
begin

  vKey # aint(Mat.A.Materialnr)+Mat.A.Aktionstyp;

  if (Lib_Dict:ReadExt(var gAktDict, vKey, var vInhalt, var vInst)=false) then begin
    RETURN __AktAdd(RecBufDefault(204), vKey, 0, 'NEW');
  end;

  if (vInst=0) then RETURN false;
  VarInstance(struct_BA_Kost_Akt, vInst);

  if (s_BA_Kost_Akt_Todo='DEL') then begin

    // alten EIntrag umbiegen...
    if (Lib_Dict:ReadItem(var gAktDict, vKey, var vItem)=false) then
      RETURN false;

    vRecId # s_BA_Kost_Akt_RecID; // mit ALTER RecId speichern

    gAktDict->CteDelete(vItem);   // altes Item verwerfen
    VarFree(struct_BA_Kost_Akt);

    RETURN __AktAdd(RecBufDefault(204), vKey, vRecId, 'MOD');
  end;

  RETURN false;
end;


//========================================================================
//========================================================================
sub _BBDel() : logic;
local begin
  vInhalt : alpha;
  vInst   : bigint;
  vKey    : alpha;
end;
begin

  vKey # cnvab(RecInfo(202,_RecID));
  RETURN Lib_Dict:Add(var gBBDict, vKey, 'DEL', RecInfo(202,_RecID));

end;

//========================================================================
//========================================================================
sub _VererbeKostenDiff(
  aMat              : int;
  aKostenDiff       : float;
  aKostenDiffPro    : float;
  aKostenDiffCo2    : float;
  aKostenDiffCo2S   : float;
  aFirst            : logic;
  opt aKombiVorg    : int;
  opt aDep          : int) : logic;
local begin
  Erx         : int;
  v200        : int;
  v204        : int;
  vX,vY       : float;
  vKombiNr    : int;
  vInst       : int;
  vCO2        : float;
  vCO2Schrott : float;
end;
begin
  if (aKostenDiff=0.0) and (aKostenDiffCo2=0.0) and (aKostenDiffCo2S=0.0) then RETURN true;

//debugx(aint(aDep)+'. vererbeKDiff : M'+aint(aMat)+' '+anum(aKostenDiff,2)+'euro '+anum(aKostenDiffCo2,2)+'Co2 '+anum(aKostenDiffCo2s,2)+'Co2s');

  if (s_BA_Kost_Mat_Nr<>aMat) then begin
    if (_MatRead(aMat)=false) then RETURN false;
  end;

  v200 # RecBufCreate(s_BA_Kost_Mat_Datei);
  FldDef(v200, 1,1, aMat);
  if (RecRead(v200, 1, 0)>_rLocked) then begin
    RecBufClear(v200);
    RETURN false;
  end;

  if (aFirst=false) then begin
    s_BA_Kost_Mat_Mody        # true;
    s_BA_Kost_Mat_Kosten      # s_BA_Kost_Mat_Kosten + aKostenDiff;
    s_BA_Kost_Mat_KostenPro   # s_BA_Kost_Mat_KostenPro + aKostenDiffPro;
    s_BA_Kost_Mat_CO2Kosten   # s_BA_Kost_Mat_Co2Kosten + aKostenDiffCo2;
    s_BA_Kost_Mat_CO2Schrott  # s_BA_Kost_Mat_Co2Schrott + aKostenDiffCo2S;
  end;
  
//debugx('M'+aint(v200->Mat.Nummer));
  v204 # RecbufCreate(204);
  FOR Erx # RecLink(v204,v200,14,_recFirst)
  LOOP Erx # RecLink(v204,v200,14,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // alte KOMBI-Aktion anpassen ???
    if (aKombiVorg<>0) then begin
      if (v204->Mat.A.Aktionstyp=c_Akt_Mat_Kombi) and
         (v204->Mat.A.Aktionsmat=aKombiVorg) and (v204->Mat.A.Entstanden=0) then begin

         vInst # VarInfo(struct_BA_Kost_Akt);
        _AktMod(v204, aKostenDiff, aKostenDiffPro, aKostenDiffCo2);
        VarInstance(struct_BA_Kost_Akt, vInst);

      end;
    end;

    if (v204->Mat.A.Entstanden=0) then CYCLE;
//debugx(v204->Mat.A.Bemerkung+' :'+cnvad(v204->Mat.A.Aktionsdatum)+' <= '+cnvad(gAbschlussam)+'? ja->CYCLE');
    // 28.04.2017 AH NEU NEU NEU
//debugx('...'+v204->Mat.A.Bemerkung);
    if (v204->Mat.A.Aktionsdatum<gAbschlussam) then begin
//debugx('CYLCE');
      CYCLE;   // 03.07.2019 AH: war "<="
    end;

    vX # aKostenDiff;
    vY # aKostenDiffPro;
    vCO2 # aKostenDiffCo2;
    vCO2Schrott # aKostenDiffCo2S;

    vKombiNr # 0;
    // KOMBI??? Dann Anteil vererben...
    if (v204->Mat.A.Aktionstyp=c_Akt_Mat_Kombi) then begin
      if (_MatRead(v204->Mat.A.Entstanden)=false) then begin
        RecBufDestroy(v200);
        RecBufDestroy(v204);
        RETURN false;
      end;

      if (s_BA_Kost_Mat_StartKG<>0.0) then begin
        vX # aKostenDiff * v204->Mat.A.Gewicht / 1000.0;        // Summe Kosten für Kind
        vX # Rnd(vX / (s_BA_Kost_Mat_StartKG / 1000.0), 2);
        vCO2 # aKostenDiffCo2 * v204->Mat.A.Gewicht / 1000.0;   // Summe Co2Kosten für Kind
        vCO2 # Rnd(vCO2 / (s_BA_Kost_Mat_StartKG / 1000.0), 2);
        vCO2Schrott # aKostenDiffCo2S * v204->Mat.A.Gewicht / 1000.0;   // Summe Co2Schrott für Kind
        vCO2Schrott # Rnd(vCO2Schrott / (s_BA_Kost_Mat_StartKG / 1000.0), 2);
      end
      else begin
        vX          # 0.0;
        vCO2        # 0.0;
        vCO2Schrott # 0.0;
      end;

      if (s_BA_Kost_Mat_StartMenge<>0.0) then begin
        vY # aKostenDiffPro * v204->Mat.A.Menge / 1000.0;  // Summe Kosten für Kind
        vY # Rnd(vY / (s_BA_Kost_Mat_StartMenge / 1000.0), 2);
      end
      else
        vY # 0.0;

      if (vX=0.0) and (vY=0.0) then CYCLE;
      vKombiNr # aMat;
    end;

    if (_VererbeKostenDiff(v204->Mat.A.Entstanden, vX, vY, vCO2, vCO2Schrott, false, vKombiNr, aDep+1)=false) then begin
      RecBufDestroy(v200);
      RecBufDestroy(v204);
      RETURN false;
    end;
  END;

  RecBufDestroy(v200);
  RecBufDestroy(v204);

  RETURN true;
end;



//========================================================================
//  KillAllMatAktionen
//
//========================================================================
sub KillAllMatAktionen(
  aTyp      : alpha;
  aNr       : int;
  aPos      : int;
  aPos2     : int;
): logic;
local begin
  Erx     : int;
  vOK     : logic;
end;
begin

//debug('killen von: '+atyp+aint(aNr)+'/'+aint(apos)+'/'+aint(aPos2));
  RecBufClear(204);
  Mat.A.Aktionstyp  # aTyp;
  Mat.A.Aktionsnr   # aNr;
  if (aPos>=0) then Mat.A.Aktionspos  # aPos;
  if (aPos2>=0)then Mat.A.Aktionspos2 # aPos2;

  Erx # RecRead(204,2,0);
  WHILE (Erx<=_rMultiKey) and
    (Mat.A.Aktionstyp=aTyp) and
    (Mat.A.Aktionsnr=aNr) and
    ((Mat.A.Aktionspos=aPos) or (aPos=-1)) and
    ((Mat.A.Aktionspos2=aPos2) or (aPos2=-1)) do begin

    if (_MatRead(Mat.A.Materialnr)=false) then
      RETURN false;
//debugx('remove MatAkt '+mat.a.bemerkung+' '+anum(Mat.A.KOstenw1,2)+'KOsten '+anum(Mat.A.CO2ProT,2)+'CO2');
    s_BA_Kost_Mat_Mody        # true;
    s_BA_Kost_Mat_Kosten      # s_BA_Kost_Mat_Kosten - Mat.A.KostenW1;
    s_BA_Kost_Mat_KostenPro   # s_BA_Kost_Mat_KostenPro - Mat.A.KostenW1ProMEH;
    if (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_BA_UmlagePLUS) then
      s_BA_Kost_Mat_Co2Schrott  # s_BA_Kost_Mat_Co2Schrott - Mat.A.CO2ProT
    else
      s_BA_Kost_Mat_Co2Kosten   # s_BA_Kost_Mat_Co2Kosten - Mat.A.CO2ProT;

    _AktDel204();

    Erx # RecRead(204,2,_recNext);
  END;

  RETURN true;
end;


//========================================================================
//  KillAllAbwertungen
//
//========================================================================
sub KillAllAbwertungen(
  aTyp      : alpha;
  aNr       : int;
  aPos      : int;
  aPos2     : int;
): logic;
local begin
  Erx     : int;
  vOK     : logic;
end;
begin

//debug('killen von Abwertung: '+atyp+aint(aNr)+'/'+aint(apos));

  RecBufClear(202);
  "Mat.B.Trägertyp"     # aTyp;
  "Mat.B.Trägernummer1" # aNr;
  if (aPos>=0) then   "Mat.B.Trägernummer2" # aPos;
  if (aPos2>=0) then  "Mat.B.Trägernummer3" # aPos2;
  Erx # RecRead(202,3,0);
  WHILE (Erx<=_rMultikey) and
    ("Mat.B.Trägertyp"=aTyp) and
    ("Mat.B.Trägernummer1"=aNr) and
    (("Mat.B.Trägernummer2"=aPos) or (aPos=-1)) and
    (("Mat.B.Trägernummer3"=aPos2) or (aPos2=-1)) do begin

   if (_MatRead(Mat.B.Materialnr)=false) then
      RETURN false;
    if (StrCut(Mat.B.Bemerkung,1,1)<>'>') then begin  // nur wenn keine Folge-Abwertung
      s_BA_Kost_Mat_Mody        # true;
      s_BA_Kost_Mat_EkPreis     # s_BA_Kost_Mat_EkPreis - Mat.B.PreisW1;
      s_BA_Kost_Mat_EkPreisPro  # 0.0;
    end;

    _BBDel();

    Erx # RecRead(202,3,_recNext);
  END;

  RETURN true;

end;


//========================================================================
//  NeueAktion
//
//========================================================================
sub NeueAktion(
  aPos    : int;
  aMatNr  : int;
  aAkt    : alpha;
  aBemerk : alpha;
  aPreis  : float;
  aBasis  : float;
  aBproM  : float;
  aCO2    : float;
  aAdr    : int;
  aDatum  : date;
  aTim    : time;
) : logic;
local begin
  Erx     : int;
  vBuf702 : int;
  vBuf    : int;
end;
begin

@ifdef PROTOKOLL
mydebug(aint(aMatNr)+' '+aAkt+' '+aBemerk+'  für pos '+aint(aPos));
@endif


  if (_MatRead(aMatNr)=false) then
    RETURN false;

  vBuf702 # RekSave(702);
  if (BAG.P.position<>aPos) then begin
    vBuf702->BAG.P.Position # aPos;
    RecRead(vBuf702,1,0);
  end;

  RecBufClear(204);
  Mat.A.Materialnr    # aMatNr;
  Mat.A.Aktionsmat    # aMatNr;
  Mat.A.Aktionstyp    # aAkt;
  Mat.A.Aktionsnr     # vBuf702->BAG.P.Nummer;
  Mat.A.Aktionspos    # vBuf702->BAG.P.Position;
  Mat.A.Bemerkung     # aBemerk;
  Mat.A.Aktionsdatum  # aDatum;
  Mat.A.Terminstart   # vBuf702->BAG.P.Plan.StartDat;
  Mat.A.Terminende    # vBuf702->BAG.P.Plan.EndDat;
  Mat.A.Adressnr      # aAdr;
  Mat.A.KostenW1      # aPreis;
  Mat.A.CO2ProT       # aCo2;

  // Kostenstelle ermitteln
  if (Bag.P.ExternYN) then begin
    // Bei externen Bearbeitungen Kostenstelle aus dem Arbeitsgang holen
    Erx # RecLink(828,vBuf702,8,0);
    if (Erx <= _rOK) then
      Mat.A.Kostenstelle # ArG.Kostenstelle;
  end
  else begin
    // Bei internen Bearbeitungen Kostenstelle aus Ressource lesen,
    // sollte dies nicht erfolgreich oder 0 sein, dann die Kst aus
    // dem Arbeitsgang lesen

    // Resource lesen
    Erx # RecLink(160,vBuf702,11,0);
    if ((Erx <= _rLocked) AND (Rso.Kostenstelle > 0)) then begin
      Mat.A.Kostenstelle  # Rso.Kostenstelle;
    end
    else begin
      // Lesen aus Arbeitsgang
      Erx # RecLink(828,vBuf702,8,0);
      if (Erx <= _rLocked) then
        Mat.A.Kostenstelle # ArG.Kostenstelle;
    end;
  end;

  if (vProtokoll<>0) then TextAddLine(vProtokoll,'Material '+aint(aMatNr)+' erhält Kosten '+aAkt+' '+aBemerk);

  s_BA_Kost_Mat_Mody      # true;
  s_BA_Kost_Mat_Kosten    # s_BA_Kost_Mat_Kosten + Mat.A.KostenW1;
  s_BA_Kost_Mat_KostenPro # s_BA_Kost_Mat_KostenPro + Mat.A.KostenW1ProMEH;
  if (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_BA_UmlagePLUS) then
    s_BA_Kost_Mat_CO2Schrott  # s_BA_Kost_Mat_Co2Schrott + Mat.A.CO2ProT
  else
    s_BA_Kost_Mat_CO2Kosten # s_BA_Kost_Mat_Co2Kosten + Mat.A.CO2ProT;

  _AktNeu204();

/***
  if (aBasis<>0.0) then begin
    s_BA_Kost_Mat_Mody        # true;
    s_BA_Kost_Mat_EKPreis     # s_BA_Kost_Mat_EKPreis + aBasis;
    s_BA_Kost_Mat_EKPreisPro  # 0.0;

    // Eintrag in Bestandbuch anlegen...
//    Mat_Data:Bestandsbuch(0, 0.0, 0.0, aBasis, aBproM, aBemerk, aDatum, aAkt, vBuf702->BAG.P.Nummer, vBuf702->BAG.P.Position,0,0, y);
    vBuf # RekSave(202);
    _Belege202(vBuf, aMatNr, 0, 0.0, 0.0, aBasis, aBproM, aBemerk, aDatum, aAkt, vBuf702->BAG.P.Nummer, vBuf702->BAG.P.Position,0,0, y);
    //cTodo('ADD|202|'+aint(vBuf));
    // vererben...
//    if (Mat_Data:VererbeNeubewertung(aBasis, aBproM, aBemerk, aDatum, y, aAkt, vBuf702->BAG.P.Nummer, vBuf702->BAG.P.Position,0,0)=false) then begin
//      RecBufDestroy(vBuf702);
//      RETURN false;
//    end;
  end;
***/

  RecBufDestroy(vBuf702);

  RETURN true;
end;


//========================================================================
//  AnWeiterbearbietungen
//
//========================================================================
sub AnWeiterbearbeitungen(
  aPos    : int;
  aAkt    : alpha;
  aBem1   : alpha;
  aBem2   : alpha;
  aPreis  : float;
  aCO2    : float;
  aAdr    : int;
  aNurID  : int;
) : logic;
local begin
  Erx       : int;
  vBuf702   : int;
  vBuf701   : int;
end;
begin
@ifdef PROTOKOLL
mydebug('Fert '+aint(bag.F.position)+'/'+aint(bag.f.fertigung)+'   nurID:'+aint(aNurID));
plus;
@endif

  vBuf701 # RekSave(701);

  FOR Erx # RecLink(701,703,4,_recFirst)          // Fert->Output loopen
  LOOP Erx # RecLink(701,703,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // 06.11.2017 AH: Stornos ignorieren
    if (BAG.IO.Ist.In.Stk=0) and
      (BAG.IO.Ist.In.GewN=0.0) and
      (BAG.IO.Ist.In.GewB=0.0) and
      (BAG.IO.Ist.In.Menge=0.0) then CYCLE;


    if ((BAG.IO.VonID=aNurID) or (aNurID=0)) and
      (BAG.IO.Materialnr<>0) and
      (BAg.IO.BruderID<>0) then begin
//mydebug('id:'+aint(bag.io.id));
      vBuf702 # RekSave(702);
      BAG.P.Position # aPos;
      Erx # RecRead(702,1,0);
      if (Erx<>_rOK) then todo('Interner Fehler 741');
      if (BAG.P.Aktion<>c_BAG_VSB) and (BAG.P.Aktion<>c_BAG_VERSAND) then begin
//debugx('neu an '+aint(BAG.IO.Materialnr)+' '+aBem1+':'+aBem2);
        if (NeueAktion(aPos, BAG.IO.Materialnr, aAkt, aBem1+':'+aBem2, aPreis, 0.0, 0.0, aCO2, aAdr, gStartDat, gStartTim)=false) then begin
          RekRestore(vBuf702);
          RETURN false;
        end;

        if (BAG.IO.NachPosition<>0) and (BAG.IO.NachPosition<>BAG.F.Position) then begin
          Erx # RecLink(702,701,4,_RecFirst);   // nachPos holen
          if (Erx<>_rOK) then TODO('Interner Fehler 2212');
          if (_Inner(aPos, aAkt, aBem1, aBem2, aPreis, aCO2, aAdr, BAG.IO.ID)=faLse) then begin
            RETURN false;
          end;
        end;
      end;

      RekRestore(vBuf702);
    end;

  END;

  RekRestore(vBuf701);

@ifdef PROTOKOLL
minus;
mydebug('<Fert '+aint(bag.F.position)+'/'+aint(bag.f.fertigung));
@endif

  RETURN true;
end;


//========================================================================
//  _Inner
//
//========================================================================
sub _Inner(
  aPos      : int;
  aAkt      : alpha;
  aBem1     : alpha;
  aBem2     : alpha;
  aWert     : float;
  aCO2      : float;
  aAdr      : int;
  aNurID    : int;
) : logic
local begin
  Erx     : int;
  vBuf703 : int;
  vBuf702 : int;
  vBuf701 : int;
end;
begin

@ifdef PROTOKOLL
mydebug('Inner '+aint(bag.P.position));
plus;
@endif

  vBuf703 # RekSave(703);

  Erx # RecLink(703,702,4,_recFirst);           // Fertigungen loopen
  WHILE (Erx<=_rLocked) do begin
    if (AnWeiterbearbeitungen(aPos, aAkt, aBem1, aBem2, aWert, aCO2, aAdr, aNurID)=false) then begin
      RETURN false;
    end;

    Erx # RecLink(703,702,4,_recNext);
  END;

  RekRestore(vBuf703);

  RETURN true;

@ifdef PROTOKOLL
minus;
mydebug('<inner '+aint(bag.P.position));
@endif

end;


//========================================================================
//  Pos2Fert
//
//========================================================================
sub Pos2Fert(
  aPos        : int;
  aAG         : alpha;
  aAdr        : int;
  aAnteilSchrott    : float;
  aAnteilKosten     : float;
  aAnteilCo2Eigen   : float;
  aAnteilCo2Fremd   : float;
  aAnteilSchrottERl : float;
  aSchrottPreis     : float;
  ) : logic
local begin
  Erx     : int;
  vBuf703 : int;
  vBuf702 : int;
  vBuf701 : int;
end;
begin

  vBuf703 # RekSave(703);

  Erx # RecLink(703,702,4,_recFirst);           // Fertigungen loopen
  WHILE (Erx<=_rLocked) do begin

    if ("BAG.F.KostenträgerYN"=n) then begin    //  kein Träger?
      Erx # RecLink(703,702,4,_recNext);
      CYCLE;
    end;

    // Umlage eintragen
    if (aAnteilSchrott<>0.0) or (aAnteilCo2Fremd<>0.0) then begin
@ifdef PROTOKOLL
mydebug('schorttumlage von '+aint(aPos)+' für '+aint(bag.f.position)+'/'+aint(bag.f.fertigung));
@endif
      if (AnWeiterbearbeitungen(aPos, c_Akt_BA_UmlagePLUS, c_AktBem_BA_Umlage, aAG, aAnteilSchrott, aAnteilCo2Fremd, aAdr, 0)=false) then begin
        RETURN false;
      end;
      if (aAnteilSchrottErl<>0.0) then begin
        if (AnWeiterbearbeitungen(aPos, c_Akt_BA_UmlageSchrottErloes, c_AktBem_BA_UmlageSchrottErloes, anum(aSchrottPReis,2)+'€', -aAnteilSchrottErl, 0.0, aAdr, 0)=false) then begin
          RETURN false;
        end;
      end;
    end;
//debug('..............................................');

    // Kosten eintragen
    if (aAnteilKosten<>0.0) or (aAnteilCo2Eigen<>0.0) then begin
@ifdef PROTOKOLL
mydebug('Kostenumlage von '+aint(aPos)+' für '+aint(bag.f.position)+'/'+aint(bag.f.fertigung));
@endif
      if (AnWeiterbearbeitungen(aPos, c_Akt_BA_Kosten, c_AktBem_BA_Kosten, aAG, aAnteilKosten, aAnteilCo2Eigen, aAdr, 0)=false) then begin
        RETURN false;
      end;
    end;

    Erx # RecLink(703,702,4,_recNext);
  END;

  RekRestore(vBuf703);
  RETURN true;
end;


//========================================================================
//========================================================================
sub _Save204() : logic;
local begin
  Erx       : int;
  vKost     : float;
  vKostPRo  : float;
  vKostCo2  : float;
  vKostCo2S : float;
end;
begin
//debugx(s_BA_Kost_Akt_Todo+' @Mat'+aint(s_BA_Kost_Akt_matNr)+' recid:'+cnvab(s_BA_Kost_Akt_RecID));
  if (s_BA_Kost_Akt_Todo='NEW') then begin
    if (Mat_Data:Read(s_BA_Kost_Akt_Matnr)<200) then
      RETURN false;
    if (_MatRead(s_BA_Kost_Akt_MatNr)=false) then
      RETURN false;

    RecBufClear(204);
    Mat.A.Materialnr    # s_BA_Kost_Akt_MatNr;
    Mat.A.Aktionsmat    # s_BA_Kost_Akt_MatNr;
    Mat.A.Aktionstyp    # s_BA_Kost_Akt_Typ;
    Mat.A.Aktionsnr     # s_BA_Kost_Akt_Nr;
    Mat.A.Aktionspos    # s_BA_Kost_Akt_Pos;
    Mat.A.Bemerkung     # s_BA_Kost_Akt_Bem;
    Mat.A.Aktionsdatum  # s_BA_Kost_Akt_Datum;
    Mat.A.Terminstart   # s_BA_Kost_Akt_Start;
    Mat.A.Terminende    # s_BA_Kost_Akt_Ende;
    Mat.A.Adressnr      # s_BA_Kost_Akt_Adr;
    Mat.A.KostenW1      # s_BA_Kost_Akt_Kosten;
    Mat.A.KostenW1ProMEH  # s_BA_Kost_Akt_KostenPro;
    Mat.A.CO2ProT       # s_BA_Kost_Akt_Co2Kosten;
    Mat.A.Kostenstelle  # s_BA_Kost_Akt_KST;

    if (Mat_A_data:Insert(0,'AUTO')<>_rOK) then
      RETURN false;

    // 17.09.2020 AH: Schrottnullungen nie vererben !!!
    if (Mat.A.Aktionstyp<>c_Akt_BA_UmlageMINUS) then begin
    //    if (_VererbeKostenDiff(Mat.A.Materialnr, Mat.A.KostenW1, Mat.A.KostenW1ProMEH, Mat.A.CO2ProT, true)=false) then  RETURN false;
      if (Mat.A.Aktionstyp=c_Akt_BA_UmlagePLUS) then begin
        if (_VererbeKostenDiff(Mat.A.Materialnr, Mat.A.KostenW1, Mat.A.KostenW1ProMEH, 0.0, Mat.A.CO2ProT, true)=false) then RETURN false;
      end
      else begin
        if (_VererbeKostenDiff(Mat.A.Materialnr, Mat.A.KostenW1, Mat.A.KostenW1ProMEH, Mat.A.CO2ProT, 0.0, true)=false) then RETURN false;
      end;
    end;

  end // ADD
  else if (s_BA_Kost_Akt_Todo='DEL') then begin

    if (Mat_Data:Read(s_BA_Kost_Akt_Matnr)<200) then
      RETURN false;
    if (_MatRead(s_BA_Kost_Akt_MatNr)=false) then
      RETURN false;

    Erx # RecRead(204,0,_RecId, s_BA_Kost_Akt_RecID);
    if (Erx<>_rOK) then
      RETURN false;
    Erx # RekDelete(204);
    if (Erx<>_rOK) then
      RETURN false;
      
    // 17.09.2020 AH: Schrottnullungen nie vererben !!!
    if (Mat.A.Aktionstyp<>c_Akt_BA_UmlageMINUS) then begin
//        if (_VererbeKostenDiff(Mat.A.Materialnr, -Mat.A.KostenW1, -Mat.A.KostenW1ProMEH, -Mat.A.CO2ProT, true)=false) then RETURN false;
      if (Mat.A.Aktionstyp=c_Akt_BA_UmlagePLUS) then begin
        if (_VererbeKostenDiff(Mat.A.Materialnr, -Mat.A.KostenW1, -Mat.A.KostenW1ProMEH, 0.0, -Mat.A.CO2ProT, true)=false) then RETURN false;
      end
      else begin
        if (_VererbeKostenDiff(Mat.A.Materialnr, -Mat.A.KostenW1, -Mat.A.KostenW1ProMEH, -Mat.A.CO2ProT, 0.0, true)=false) then RETURN false;
      end;
    end;

  end // DEL
  else if (s_BA_Kost_Akt_Todo='MOD') then begin

    if (Mat_Data:Read(s_BA_Kost_Akt_Matnr)<200) then
      RETURN false;
    if (_MatRead(s_BA_Kost_Akt_MatNr)=false) then
      RETURN false;

    Erx # RecRead(204,0,_RecId | _RecLock, s_BA_Kost_Akt_RecID);
    if (Erx<>_rOK) then
      RETURN false;

    vKost     # s_BA_Kost_Akt_Kosten - Mat.A.KostenW1;
    vKostPro  # s_BA_Kost_Akt_Kosten - Mat.A.KostenW1ProMEH;
    if (Mat.A.Aktionstyp=c_Akt_BA_UmlageMINUS) or (Mat.A.Aktionstyp=c_Akt_BA_UmlagePLUS) then
      vKostCo2S # s_BA_Kost_Akt_Co2Kosten - Mat.A.CO2ProT
    else
      vKostCo2  # s_BA_Kost_Akt_Co2Kosten - Mat.A.CO2ProT;

    Mat.A.Materialnr    # s_BA_Kost_Akt_MatNr;
    Mat.A.Aktionsmat    # s_BA_Kost_Akt_MatNr;
    Mat.A.Aktionstyp    # s_BA_Kost_Akt_Typ;
    Mat.A.Aktionsnr     # s_BA_Kost_Akt_Nr;
    Mat.A.Aktionspos    # s_BA_Kost_Akt_Pos;
    Mat.A.Bemerkung     # s_BA_Kost_Akt_Bem;
    Mat.A.Aktionsdatum  # s_BA_Kost_Akt_Datum;
    Mat.A.Terminstart   # s_BA_Kost_Akt_Start;
    Mat.A.Terminende    # s_BA_Kost_Akt_Ende;
    Mat.A.Adressnr      # s_BA_Kost_Akt_Adr;
    Mat.A.KostenW1      # s_BA_Kost_Akt_Kosten;
    Mat.A.KostenW1ProMEH  # s_BA_Kost_Akt_KostenPro;
    Mat.A.Kostenstelle  # s_BA_Kost_Akt_KST;
    Mat.A.Co2ProT       # s_BA_Kost_Akt_Co2Kosten;

    Erx # RekReplace(204);
    if (Erx<>_rOK) then
      RETURN false;

    // 17.09.2020 AH: Schrottnullungen nie vererben !!!
    if (Mat.A.Aktionstyp<>c_Akt_BA_UmlageMINUS) then begin
      if (_VererbeKostenDiff(Mat.A.Materialnr, vKost, vKostPro, vKostCo2, vKostCo2S, true)=false) then RETURN false;
    end;


  end // DEL
  else if (s_BA_Kost_Akt_Todo='KOSTEN') then begin

    RecRead(204,0,_RecId | _RecLock, s_BA_Kost_Akt_RecID);
    if (Erx=_rOK) then begin
      Mat.A.KostenW1        # Mat.A.KostenW1       + s_BA_Kost_Akt_Kosten;
      Mat.A.KostenW1ProMEH  # Mat.A.KostenW1ProMEH + s_BA_Kost_Akt_KostenPro;
      Mat.A.Co2ProT         # Mat.A.Co2ProT        + s_BA_Kost_Akt_Co2Kosten;
      Erx # RekReplace(204);
    end;
    if (Erx<>_rOK) then
      RETURN false;
  end
  else begin
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _Save200(aDatei : int) : logic;
local begin
  Erx     : int;
  vDiff   : float;
end;
begin
  if (s_BA_Kost_Mat_Mody) then begin  // wirklich ändern?
    if (aDatei=200) then begin
      Erx # RecRead(200, 1, _reclock);
      if (Erx=_rOK) then begin
        vDiff # Rnd((s_BA_Kost_Mat_Kosten * Mat.Bestand.Gew / 1000.0) - (Mat.Kosten * Mat.Bestand.Gew / 1000.0),2);
        if (gDiffTxt<>0) and (vDiff<>0.0) then
          TextAddLine(gDiffTxt,aint(Mat.Nummer)+'|'+anum(vDiff,2)+'|'+aint(Mat.VK.RechNr));
   
        Mat.Bewertung.Laut  # s_BA_Kost_Mat_Laut;
        Mat.EK.Preis        # Rnd(s_BA_Kost_Mat_EkPreis,2);
        Mat.EK.PreisProMEH  # Rnd(s_BA_Kost_Mat_EkPreisPro,2);
        Mat.Kosten          # Rnd(s_BA_Kost_Mat_Kosten,2);
        Mat.KostenProMEH    # Rnd(s_BA_Kost_Mat_KostenPro,2)
        Mat.CO2ZuwachsProT  # Rnd(s_BA_Kost_Mat_Co2Kosten,2);
        Mat.CO2SchrottProT  # Rnd(s_BA_Kost_Mat_CO2Schrott,2);
        Erx # Mat_Data:Replace(_recUnlock,'AUTO');
      end;
//if (Mat.Nummer=5954) then
//debugx('KEY200 mod auf '+anum(Mat.Kosten,2)+'Kosten   '+anum(Mat.CO2ZuwachsProT,2)+'CO2');
    end
    else begin
      Erx # RecRead(210, 1, _reclock);
      if (erx=_rOK) then begin
        vDiff # Rnd((s_BA_Kost_Mat_Kosten * "Mat~Bestand.Gew" / 1000.0) - ("Mat~Kosten" * "Mat~Bestand.Gew" / 1000.0),2);
        if (gDiffTxt<>0) and (vDiff<>0.0) then
          TextAddLine(gDiffTxt,aint("Mat~Nummer")+'|'+anum(vDiff,2)+'|'+aint("Mat~VK.RechNr"));

        "Mat~Bewertung.Laut"  # s_BA_Kost_Mat_Laut;
        "Mat~EK.Preis"        # Rnd(s_BA_Kost_Mat_EkPreis,2);
        "Mat~EK.PreisProMEH"  # Rnd(s_BA_Kost_Mat_EkPreisPro,2);
        "Mat~Kosten"          # Rnd(s_BA_Kost_Mat_Kosten,2);
        "Mat~KostenProMEH"    # Rnd(s_BA_Kost_Mat_KostenPro,2);
        "Mat~CO2ZuwachsProT"  # Rnd(s_BA_Kost_Mat_Co2Kosten,2);
        "Mat~CO2SchrottProT"  # Rnd(s_BA_Kost_Mat_CO2Schrott,2);
        Erx # Mat_Abl_Data:ReplaceAblage(_recUnlock,'AUTO');
      end;
    end;
  end
  else begin                          // nur freigeben
    Erx # RecRead(aDatei, 1, _recUnlock);
  end;

  if (Erx<>_rOK) then
    RETURN false;

  RETURN true;
end;

//========================================================================
sub _ProcessBB(aSave   : logic) : logic;
local begin
  Erx     : int;
  vItem   : int;
  vInst   : BigInt;
end;
begin
  if (gBBDict=0) then RETURN true;

  FOR vItem # gBBDict->CteRead(_CteFirst);
  LOOP vItem # gBBDict->CteRead(_CteFirst);
  WHILE (vItem<>0) do begin

    vInst # vItem->spID;
    if (vInst=0) then begin
      aSave # false;
      CYCLE;
    end;

    if (aSave) then begin
      Erx # RecRead(202,0,_RecId, vItem->spID);
      if (Erx<>_rOK) then
        RETURN false;
      Erx # RekDelete(202);
      if (Erx<>_rOK) then
        RETURN false;
    end;  // SAVE

    // Buffer löschen...
    vItem->spID # 0;
    gBBDict->CteDelete(vItem);
    CteClose(vItem);
  END;

  Lib_Dict:Close(var gBBDict);

  RETURN aSave;
end;


//========================================================================
sub _ProcessAkt(aSave   : logic) : logic;
local begin
  vItem   : int;
  vDatei  : int;
  vInst   : BigInt;
  vDiff   : float;
end;
begin

  if (gAktDict=0) then RETURN true;

  FOR vItem # gAktDict->CteRead(_CteFirst);
  LOOP vItem # gAktDict->CteRead(_CteFirst);
  WHILE (vItem<>0) do begin

    vInst # vItem->spID;
    if (vInst=0) then begin
      aSave # false;
      CYCLE;
    end;

    VarInstance(struct_BA_Kost_Akt, vInst);

    if (aSave) then begin
      aSave # _Save204();
    end;  // SAVE

    // Buffer löschen...
    VarFree(struct_BA_Kost_Akt);
    vItem->spID # 0;
    gAktDict->CteDelete(vItem);
    CteClose(vItem);
  END;

  Lib_Dict:Close(var gAktDict);

  RETURN aSave;
end;


//========================================================================
sub _ProcessMat(aSave : logic): Logic;
local begin
  vItem   : int;
  vDatei  : int;
  vInst   : int;
end;
begin

  if (gMatDict=0) then RETURN true;

  FOR vItem # gMatDict->CteRead(_CteFirst);
  LOOP vItem # gMatDict->CteRead(_CteFirst);
  WHILE (vItem<>0) do begin

    vInst # vItem->spID;
    if (vInst=0) then RETURN false;

    VarInstance(struct_BA_Kost_Mat, vInst);
    vDatei  # s_BA_Kost_Mat_Datei;
    Mat.Nummer    # s_BA_Kost_Mat_Nr;
    "Mat~Nummer"  # s_BA_Kost_Mat_Nr;

    if (aSave=false) then begin
      // Sperren aufheben...
      RecRead(vDatei, 1, _recUnlock);
    end
    else begin
      aSave # _Save200(vDatei);
    end;  // SAVE?

    // Buffer löschen...
    VarFree(struct_BA_Kost_Mat);
    vItem->spID # 0;
    gMatDict->CteDelete(vItem);
    CteClose(vItem);
  END;

  Lib_Dict:Close(var gMatDict);

  RETURN aSave;
end;


//========================================================================
sub ProcessDict(aSave : logic) : logic;
local begin
  vOK : logic;
end
begin
  vOK # _ProcessMat( _ProcessAkt( _ProcessBB(aSave) ) );
  RETURN vOK;
end;


//========================================================================
//========================================================================
sub GetFahrCO2Kosten(
  aAdr  : int;
  aAns  : int;
  aGew  : float;
) : float
local begin
  vFahrCo2    : float;
  vEntfernung : float;
  vFrachtGew  : float;
  vX          : float;

end;
begin
  if (aAdr=0) then RETURN 0.0;
  
  Dic.Key # 'CO2_FahrenProkm';
  Erg # recRead(935,1,0);
  if (Erg<=_rLocked) then begin
    vFahrCo2 # cnvfa(Dic.Value);
    
    if (aAns<>0) then begin
      Adr.A.Adressnr  # aAdr;
      Adr.A.Nummer    # aAns;
      Erg # RecRead(101,1,0);               // Zieladresse holen
      if (erg<=_rLocked) then
        vEntfernung # Adr.A.EntfernungKm;
      //vX # Adr.A.EntfernungKm * vFahrCo2;
    end;
    if (vEntfernung = 0.0) then begin
      Adr.A.Adressnr  # aAdr;
      Adr.A.Nummer    # 1;
      Erg # RecRead(101,1,0);               // Zieladresse Hauptanschrift holen
      // if (erg<=_rLocked) then vX # Adr.A.EntfernungKm * vFahrCo2;
      vEntfernung # Adr.A.EntfernungKm;
    end;
    
    // Alte Berechnung
    // vX # vFahrCo2 * Adr.A.EntfernungKm;
  
    Dic.Key # 'CO2_FahrenKgProFuhre';
    Erg # recRead(935,1,0);
    if (Erg<=_rLocked) then begin
      vFrachtGew # cnvfa(Dic.Value);
      if (aGew <> 0.0) AND (vFrachtGew <> 0.0) then
        vX # Rnd(vFahrCo2 * (Adr.A.EntfernungKm/vFrachtGew*aGew),2);
    end;

  end;
  
  
  RETURN vX;
end;


//========================================================================
//========================================================================
sub LoopAllMat(
) : int;
local begin
  Erx : int;
end;
begin

  // Input loopen...
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.Materialnr=0) then CYCLE;
    if (BAG.IO.Materialtyp=c_IO_BAG) then CYCLE;

    // 06.11.2017 AH: Stornos ignorieren
    if (BAG.IO.BruderID>0) and  // 20.12.2018 nur bei Weiterbearbeitungen (VFP hatte bei FahrBA1417 Problem)
      (BAG.IO.Ist.In.Stk=0) and
      (BAG.IO.Ist.In.GewN=0.0) and
      (BAG.IO.Ist.In.GewB=0.0) and
      (BAG.IO.Ist.In.Menge=0.0) then CYCLE;

    // Einsatzkarte
    if (_MatAdd(BAG.IO.Materialnr, false, false)=false) then RETURN -BAG.IO.Materialnr;

    // Restkarte
//    if (_MatAdd(BAG.IO.MaterialRstnr, true, false)=false) then RETURN false;
  END;


/***
  // Output loopen...
  FOR Erx # RecLink(701,702,3,_recFirst)
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.Materialnr=0) then CYCLE;
    if (_MatAdd(BAG.IO.Materialnr, false, false)=false) then RETURN false;
  END;
***/
  RETURN 1;
end;


//========================================================================
//========================================================================
sub SumSchrottUndSetEK(
  var aSchrottGew       : float;
  var aSchrottWert      : float;
  var aSchrottCO2Eigen  : float;
  var aSchrottCO2Fremd  : float;
  aProdKostCo2ProKGIn   : float;
) : logic;
local begin
  Erx     : int;
  vInKg   : float;
end;
begin

  // in Restkarten Lohnkosten eintragen ------------------------------------
// 11.10.2021 if ((BAG.P.Aktion<>c_BAG_Versand) and (BAG.P.Aktion<>c_BAG_Fahr09) and (BAG.P.Aktion<>c_BAG_Umlager)) or
//     ((Set.BA.LFA.SchrtUmlg) and (BAG.P.Aktion=c_BAG_Fahr09)) then begin
  if (BA1_P_data:DarfKostenHaben()) then begin

    // Input loopen...
    FOR Erx # RecLink(701,702,2,_recFirst)
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.Materialnr=0) then CYCLE;
      if (BAG.IO.Materialtyp=c_IO_BAG) then CYCLE;

      if (_MatRead(BAG.IO.MaterialRstNr)=false) then STOP;

      if (BAG.IO.Materialnr<>BAG.IO.MaterialRstNr) then begin     // ist bei echtem Einsatz und NICHT Fahren so
        if (_SetArtEK()=false) then begin
TODOX('DurchschnittsEK nicht setzbar!');
          RETURN false;
        end;
      end;

      if (BAG.P.Aktion=c_BAG_Fahr09) and ("Mat.Löschmarker"='') then CYCLE;

      if (BAG.IO.Plan.In.GewB=BAG.IO.Plan.In.GewN) then begin
        vInKG  # BAG.IO.Plan.In.GewN;
      end
      else begin
        if (VwA.Nummer<>Mat.Verwiegungsart) then begin
          Erx # RecLink(818,200,10,_recfirst);    // Verwiegungsart holen
          if (Erx>_rLocked) then VwA.NettoYN # y;
        end;
        if (VWa.NettoYN) then
          vInKG  # BAG.IO.Plan.In.GewN
        else
          vInKG  # BAG.IO.Plan.In.GewB;
      end;

@ifdef PROTOKOLL
mydebug('schrott von Karte:'+aint(s_BA_Kost_Mat_Nr)+' '+anum(mat.ek.effektiv,2)+'/t * '+anum(Mat.Bestand.Gew,0)+'kg;  Einsatz '+anum(vInKg,2));
@endif

      aSchrottGew   # aSchrottGew + Mat.Bestand.Gew;
      aSchrottWert  # aSchrottwert + (Mat.Bestand.Gew * Mat.EK.Effektiv / 1000.0);
//      aSchrottCO2   # aSchrottCO2  + (Mat.Bestand.Gew * (Mat.CO2EinstandProT+Mat.CO2ZuwachsProT+Mat.CO2SchrottProT) / 1000.0);  // 03.03.2021 AH + Schrott
      aSchrottCO2Eigen # aSchrottCO2Eigen + (Mat.Bestand.Gew * Mat.CO2ZuwachsProT / 1000.0);
      aSchrottCO2Eigen # aSchrottCO2Eigen + (vInKG * aProdKostCo2ProKGin / 1000.0);
      aSchrottCO2Fremd # aSchrottCO2Fremd + (Mat.Bestand.Gew * (Mat.CO2EinstandProT+Mat.CO2SchrottProT) / 1000.0);
     END;

    // 16.10.2019 AH: beim Recalc wurden geplanten Schrottmengen nicht berücksichtigt!
    // Schrottfertigungen loopen..
    FOR Erx # RecLink(703,702,4,_recFirst)
    LOOP Erx # RecLink(703,702,4,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.F.PlanSchrottYN=false) then CYCLE;
      // deren FMs loopen...
      FOR Erx # RecLink(707,703,10,_recFirst)
      LOOP Erx # RecLink(707,703,10,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (BAG.FM.Materialnr=0) then CYCLE;
        if (_MatRead(BAG.FM.Materialnr)=false) then CYCLE;
        if (BAG.P.Aktion=c_BAG_Fahr09) and ("Mat.Löschmarker"='') then CYCLE;
@ifdef PROTOKOLL
mydebug('schrott von geplanter Schrottkarte:'+aint(s_BA_Kost_Mat_Nr)+' '+anum(mat.ek.effektiv,2)+'/t * '+anum(Mat.Bestand.Gew,0)+'kg');
@endif
        aSchrottGew   # aSchrottGew + Mat.Bestand.Gew;
        aSchrottWert  # aSchrottwert + (Mat.Bestand.Gew * Mat.EK.Effektiv / 1000.0);
  //      aSchrottCO2   # aSchrottCO2  + (Mat.Bestand.Gew * (Mat.CO2EinstandProT+Mat.CO2ZuwachsProT) / 1000.0);
        aSchrottCO2Eigen   # aSchrottCO2Eigen  + (Mat.Bestand.Gew * Mat.CO2ZuwachsProT / 1000.0);
        aSchrottCO2Eigen   # aSchrottCO2Eigen  + (vInKG * aProdKostCo2ProKGIn / 1000.0);
        aSchrottCO2Fremd   # aSchrottCO2Fremd  + (Mat.Bestand.Gew * (Mat.CO2EinstandProT+Mat.CO2SchrottProT) / 1000.0);
      END;
    END;

  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _CheckBaPos(aBAG : int; aPos : int) : logic;
local begin
  Erx : int;
end;
begin
  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos;
  Erx # RecRead(702,1,0);
  if (Erx<>_rOK) then RETURN false;
  if (BAG.P.Aktion=c_BAG_VSB) then RETURN true;
  if (BAG.P.Aktion=c_BAG_VERSAND) then RETURN true;

  // ST 2009-08-13  Projekt: 1161/95
  // Kostenträgercheck
  // Falls geplante Schrottfertigungen eingetragen sind,
  // muss mindestens eine Kostenträgerfertigung vorhanden sein

  RETURN true;
end;


//========================================================================
//========================================================================
sub _SummePosKosten(
  var aStartDat         : date;
  var aStartTim         : time;
  var aBeistellSum      : float;
  var aEinsatzM         : float;
  var aEinsatzKG        : float;
  var aCO2              : float;
) : logic;
local begin
  Erx       : int;
  vErx      : int;
  vStiche   : float;
  vTextname : alpha;
  vTxt      : int;
  vI,vJ     : int;
  vA        : alpha(1000);
  vZ        : int;
  vCO2ProT  : float;
  vFahrCo2  : float;
end;
begin

  BAG.P.Kosten.Gesamt   # 0.0;
  BAG.P.Kosten.Ges.Stk  # 0;
  BAG.P.Kosten.Ges.Gew  # 0.0;
  BAG.P.Kosten.Ges.Men  # 0.0;
  BAG.P.Kosten.Ges.MEH  # '';
  BAG.P.Kosten.CO2      # 0.0;

  // Jüngste Fertigmeldung ermitteln ---------------------------------------
  /***
  Erx # RecLink(707,702,5,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (aDat=0.0.0) then gStartDatum # BAG.FM.Datum;
    if (aDat>BAG.FM.Datum) then gDatum # BAG.FM.Datum;
    Erx # RecLink(707,702,5,_recNext);
  END;
  if (aDat=0.0.0) then aDat # today;
***/
  FOR Erx # RecLink(707,702,5,_recFirst)
  LOOP Erx # RecLink(707,702,5,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.FM.Datum=0.0.0) then CYCLE;
    if (aStartDat=0.0.0) then begin
      aStartDat    # BAG.FM.Datum;
      aStartTim    # BAG.FM.Zeit;
    end;
    if (aStartDat>BAG.FM.Datum) then begin
      aStartDat # BAG.FM.Datum;
      aStartTim # BAG.FM.Zeit;
    end
    else if (aStartDat=BAG.FM.Datum) then begin
      if (aStartTim>BAG.FM.Zeit) then aStartTim # BAG.FM.Zeit;
    end;
  END;


  vCO2ProT # 0.0;
  Erx # RecLink(160,702,11,_recFirst);        // Ressource holen
  if (Erx<=_rLocked) then vCO2ProT # Rso.CO2ProT;


  vStiche # 1.0;
  // bei Walzen die tatsächliche Stichzahl errechnen ------------------------------
  if (BAG.P.Aktion=c_BAG_Walz) then begin
    vErx # RecLinkInfo(706,702,9,_reccount);    // Arbeitsschritte zählen
    if (vErx>0) then vStiche # cnvfi(vErx);
    // Walzprotokoll analysieren...
    vTextName # '~703.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+CnvAI(1,_FmtNumLeadZero | _FmtNumNoGroup,0,4)
//debugx('Stichprotokoll: '+vTextName);
    vTxt  # TextOpen(20);
    Erx # TextRead(vTxt, vTextName,0);
    if (Erx<=_rLocked) then begin
      vI # TextSearch(vTxt, 1, 1, _TextSearchCI, 'START|'); // Start-MatNr suchen
      if (vI>0) then begin
        vA # TextLineRead(vTxt, vI,0);
//debugx('untersuche Walzen: '+vA);
        vJ # cnvia(Str_token(vA,'|',2));  // Mat 4711
        if (vJ>0) then begin
//debugx('untersuche Mat '+aint(vJ));
          vZ # 0;
          inc(vI);
          FOR vI # TextSearch(vTxt, vI, 1, _TextSearchCI, '|'+aint(vJ)+'/')
          LOOP vI # TextSearch(vTxt, vI, 1, _TextSearchCI, '|'+aint(vJ)+'/')
          WHILE (vI>0) do begin
//debugx('Stich bei Zeile '+aint(vI));
            vA # TextLineRead(vTxt, vI,0);
            if (StrCut(vA,1,3)<>'WOF') then inc(vZ);
            inc(vI);    // 1,2,3
          END;
//          vI # TextSearch(vTxt, vI+1, 1, _TextSearchCI, 'ENDE'irgendwas+'|'+aint(vJ)+'|'); // Ende suchen
          if (vZ>0) then vStiche # cnvfi(vZ);
//debugx('Stichsumme:'+anum(vStiche,0));
        end;
      end;
    end;
    TextClose(vTxt);
 
/*** FARHEN NICHT GEWICHTSABHÄNGIG !!!
  end
  // bei Fahren Entfernung holen --------------------------------
  else if (BAG.P.Aktion=c_BAG_Fahr) then begin
    Dic.Key # 'CO2_Fahren_kg';
    Erx # recRead(935,1,0);
    if (Erx<=_rLocked) then vFahrCo2 # cnvfa(Dic.Value);
  
    Erx # RecLink(101,702,13,_recFirst);      // Zielanschrift holen
    if (Erx<=_rLocked) then vCO2ProT # Adr.A.EntfernungKm * vFahrCo2;
    if (vCO2ProT=0.0) then begin
      Adr.A.Adressnr  # BAG.P.Zieladresse;
      Adr.A.Nummer    # 1;
      Erx # RecRead(101,1,0);               // Zieladresse Hauptanschrift holen
      if (Erx<=_rLocked) then vCO2ProT # Adr.A.EntfernungKm * vFahrCo2;
    end;
***/
  end;


  // Einsatz summieren + Lohnkosten errechnen ------------------------------
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.Aktion=c_BAG_Fahr09) then begin
      BAG.IO.Plan.Out.GewN # BAG.IO.Ist.Out.GewN;
      BAG.IO.Plan.Out.GewB # BAG.IO.Ist.Out.GewB;
      BAG.IO.Plan.Out.Stk  # BAG.IO.Ist.Out.Stk;
      if (BAG.IO.MEH.In=BAG.IO.MEH.Out) then
        BAG.IO.Plan.Out.Meng # BAG.IO.Ist.Out.Menge;
    end;

    if (BAG.P.Aktion=c_BAG_Umlager) then begin
      BAG.IO.Plan.Out.GewN # BAG.IO.Plan.In.GewN;
      BAG.IO.Plan.Out.GewB # BAG.IO.Plan.In.GewB;
      BAG.IO.Plan.Out.Stk  # BAG.IO.Plan.In.Stk;
      if (BAG.IO.MEH.In=BAG.IO.MEH.Out) then
        BAG.IO.Plan.Out.Meng # BAG.IO.Plan.In.Menge;
    end;


    if (BAG.IO.Materialtyp=c_IO_Beistell) then begin    // Beistell-Artikel?
      aBeistellSum # aBeistellSum + BAG.IO.GesamtKostW1;
    end;

    if (BAG.IO.Materialtyp=c_IO_Mat) then begin    // Material??
   
      aCO2 # aCO2 + Rnd((BAG.IO.Plan.Out.GewN / 1000.0) * vCO2ProT * vStiche,2);   // summieren
//debugx('add BA-CO2:'+anum(BAG.IO.Plan.Out.GewN/1000.0,0)+'t * '+anum(vCO2ProT,2)+'co2 * '+anum(vStiche,0)+'Stiche');

      // Setting: Kompletten Einsatz ------------------------------------
      if (Set.Ba.lohnKost.Wie='K') then begin
        aEinsatzKG # aEinsatzKG + BAG.IO.Plan.Out.GewN;
        if (BAG.P.Kosten.MEH='m') then begin
          aEinsatzM # aEinsatzM + cnvfi(BAG.IO.Plan.Out.Stk) * "BAG.IO.Länge" / 1000.0;
          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + BAG.IO.Plan.Out.GewN;
          BAG.P.Kosten.Ges.Stk  # BAG.P.Kosten.Ges.Stk  + BAG.IO.Plan.Out.Stk;
        end;
        if (BAG.P.Kosten.MEH='Stk') then begin
          aEinsatzM # aEinsatzM + cnvfi(BAG.IO.Plan.Out.Stk);//cnvfi(BAG.IO.Plan.In.Stk);
          BAG.P.Kosten.Ges.Stk  # BAG.P.Kosten.Ges.Stk  + BAG.IO.Plan.Out.Stk;//BAG.IO.Plan.In.Stk;
        end;
        if (BAG.P.Kosten.MEH='kg') then begin
          aEinsatzM # aEinsatzM + BAG.IO.Plan.Out.GewN;//BAG.IO.Plan.In.GewB;
          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + BAG.IO.Plan.Out.GewN;//BAG.IO.Plan.In.GewB;
        end;
        if (BAG.P.Kosten.MEH='t') then begin
          aEinsatzM # aEinsatzM + (BAG.IO.Plan.Out.GewN / 1000.0);//(BAG.IO.Plan.In.GewB / 1000.0);
          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + BAG.IO.Plan.Out.GewN;//BAG.IO.Plan.In.GewB;
        end;
      end // Setting: kompletten Einsatz
      // Setting: nur Gutteile ----------------------------------------
      else if (Set.Ba.lohnKost.Wie='G') then begin

        FOR Erx # RecLink(707,701,12,_recFirst) // Verwiegungen loopen
        LOOP Erx # RecLink(707,701,12,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (BAG.FM.Fertigung>900) then CYCLE;
          if (BAG.FM.Gewicht.Netto=0.0) then BAG.FM.Gewicht.Netto # BAg.FM.Gewicht.Brutt;
          aEinsatzKG # aEinsatzKG + BAG.FM.Gewicht.Netto;
          if (BAG.FM.MEH=BAG.P.kosten.MEH) then begin
            aEinsatzM # aEinsatzM + BAG.FM.Menge;
          end
          else if (BAG.P.Kosten.MEH='m') then begin
            aEinsatzM # aEinsatzM + cnvfi("BAG.FM.Stück") * "BAG.FM.Länge" / 1000.0;
          end
          else if (BAG.P.Kosten.MEH='qm') then begin
            aEinsatzM # aEinsatzM + cnvfi("BAG.FM.Stück") * "BAG.FM.Länge" * BAG.FM.Breite / 1000000.0;
          end
          else if (BAG.P.Kosten.MEH='Stk') then begin
            aEinsatzM # aEinsatzM + cnvfi("BAG.FM.Stück");
          end
          else if (BAG.P.Kosten.MEH='kg') then begin
            aEinsatzM # aEinsatzM + BAG.FM.Gewicht.Netto;
          end
          else if (BAG.P.Kosten.MEH='t') then begin
            aEinsatzM # aEinsatzM + (BAG.FM.Gewicht.Netto / 1000.0);
          end;

          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + BAG.FM.Gewicht.Netto;
          BAG.P.Kosten.Ges.Stk  # BAG.P.Kosten.Ges.Stk  + "BAG.FM.Stück";
        END;
      end;  // Setting: nur Gutteile

@ifdef PROTOKOLL
mydebug('Planin '+ANum(BAG.IO.Plan.In.GewN,0)+'   Istin '+ANum(BAG.IO.Ist.In.GewN,0)+'   PlanOut '+ANum(BAG.IO.Plan.Out.GewN,0)+'   IstOut '+ANum(BAG.IO.Ist.Out.GewN,0));
mydebug('addKarte:'+aint(BAG.IO.Materialnr));
@endif

//todo('B:'+anum(bag.p.kosten.ges.gew,0));
    end;  // Material

  END;
  
  
  // 01.03.2021 AH: Fahr-CO2 pro FUHRE
  if (BAG.P.Aktion=c_BAG_Fahr) then begin
    // ST 2021-12-02 2222/111 Anteil für Ladungsgewicht hinzugefügt
    vFahrCo2 # GetFahrCo2Kosten(BAG.P.Zieladresse, BAG.P.Zielanschrift, BAG.P.Kosten.Ges.Gew);
    aCO2 # aCo2 + vFahrCo2;   // Pauschal
  end;

end;


//========================================================================
//========================================================================
sub _SummeFMs(
  aKostenSum        : float;
  aBeistellSum      : float;
  aCo2Sum           : float;
  var aFertigGew    : float;
  var aTraegerGew   : float;
  var aSchrottGew   : float;
  var aSchrottWert  : float;
  var aAnteilKosten : float;
  var aAnteilCo2    : float;
) : logic
local begin
  Erx           : int;
  vKtraeg       : logic;
  vSchrottFert  : logic;
end;
begin

  // Fertigmeldungen summieren ---------------------------------------------
  FOR Erx # RecLink(703,702,4,_recFirst)
  LOOP Erx # RecLink(703,702,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    FOR Erx # RecLink(707,703,10,_recFirst)
    LOOP Erx # RecLink(707,703,10,_recNext)
    WHILE (Erx<=_rLocked) do begin

    if ("BAG.F.KostenträgerYN") then
      vKtraeg # true;
    if (BAG.F.PlanSchrottYN) then begin
      vSchrottFert # true;
      CYCLE;      // 16.10.2019 IGNORIEREN und an späterer anderer Stelle einrechnen
    end;

    if (BAG.FM.Materialtyp<>c_IO_Mat) or (BAG.FM.Materialnr=0) or
        (BAG.FM.Status=798) then CYCLE;   // Material??

      aFertigGew # aFertigGew + BAG.FM.Gewicht.Netto;
      if ("BAG.F.KostenträgerYN") then
        aTraegerGew # aTraegerGew + BAG.FM.Gewicht.Netto;
    END;
  END;

  if (aTraegerGew<>0.0) then begin
    aAnteilKosten   # Rnd(aKostenSum*1000.0 / aTraegerGew ,2);
    aAnteilCo2      # Rnd(aCo2Sum*1000.0 / aTraegerGew ,2);
  end;

  if (aTraegerGew<>0.0) then
    aAnteilKosten # aAnteilKosten + Rnd(aBeistellSum*1000.0 / aTraegerGew,2);

  // ST 2009-08-14  Projekt 1161/95
  if (aTraegerGew <= 0.0) AND (aAnteilKosten > 0.0) then begin
    Error(702026,'');
    RETURN false;
  end;
  if (vSchrottFert) AND (!vKtraeg) then begin
    Error(702026,'');
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//
//========================================================================
sub _KillAktUndBB() :  logic;
begin
  // 12.02.2021 AH: geplante Verschrottungen auch löschen
  if (KillAllAbwertungen(c_Akt_BA_Schrott, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllAbwertungen(c_Akt_BA_UmlageMINUS, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllMatAktionen(c_Akt_BA_Kosten, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllMatAktionen(c_Akt_BA_UmlagePLUS, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllMatAktionen(c_Akt_BA_UmlageSchrottErloes, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllMatAktionen(c_Akt_BA_UmlageMINUS, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllMatAktionen(c_Akt_BA_Beistell, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _NulleSchrottFMs(
  aAdr          : int;
  ) : logic;
local begin
  Erx     : int;
  vPreis  : float;
  vBasis  : float;
  vBproM  : float;
  vCO2    : float;
end;
begin

  // Schrottverwiegungen nullen --------------------------------------------
  FOR Erx # RecLink(703,702,4,_recFirst)
  LOOP Erx # RecLink(703,702,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.F.PlanSchrottYN=false) then CYCLE;

    FOR Erx # RecLink(707,703,10,_recFirst)
    LOOP Erx # RecLink(707,703,10,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (BAG.FM.Materialtyp<>c_IO_Mat) or (BAG.FM.Materialnr=0) or
        (BAG.FM.Status=798) then CYCLE;    // Material??

      if (_MatRead(BAG.FM.MaterialNr)=false) then
        RETURN false;

      //if (cVerschrotteBasis=false) then begin  NUR PER AKTIONEN !!!
        vPreis  # -1.0 * (s_BA_Kost_Mat_EkPreis + s_BA_Kost_Mat_Kosten);
        vCO2    # -1.0 * (s_BA_Kost_Mat_CO2 + s_BA_Kost_Mat_CO2Kosten + s_BA_Kost_Mat_CO2Schrott);
      //end
      //else begin
      //  vPreis  # -1.0 * s_BA_Kost_Mat_Kosten;
      //  vBasis  # -1.0 * s_BA_Kost_Mat_EKPreis;
      //  vBproM  # -1.0 * s_BA_Kost_Mat_EKPreisPro;
      //end;
/*
debugx('nulleplanschrott M'+aint(BAG.Fm.Materialnr)+' '+anum(s_BA_Kost_Mat_EkPreis,2)+' + '+anum(s_BA_Kost_Mat_Kosten,2));
debugx('Abschluss:'+cnvat(gAbschlussum,_FmtTimeHSeconds,0));
debugx('Start:'+cnvat(gStartTim,_FmtTimeHSeconds,0));
debugx('FM:'+cnvat(BAG.FM.Zeit,_FmtTimeHSeconds,0));
debugx('FM2:'+cnvat(BAG.FM.Anlage.Zeit,_FmtTimeHSeconds,0));
*/
      if (vPreis<>0.0) or (vBasis<>0.0) or (vCO2<>0.0) then begin
//debugx('nulleplanschrott');
        Mat.A.Bemerkung # c_AktBem_BA_Nullung+':';
        if (RunAFX('BAG.FM.Set.MatABemerkung','')=0) then
          Mat.A.Bemerkung # Mat.A.Bemerkung + BAG.P.Aktion2;
//        if (NeueAktion(BAG.P.Position, s_BA_Kost_Mat_Nr, c_Akt_BA_UmlageMINUS, Mat.A.Bemerkung, vPreis, vBasis, vBproM, aAdr, gAbschlussAm, gAbschlussUm)=false) then begin
//          if (NeueAktion(BAG.P.Position, s_BA_Kost_Mat_Nr, 'BA-PS', Mat.A.Bemerkung, vPreis, vBasis, vBproM, aAdr, gAbschlussAm)=false) then begin
//        if (NeueAktion(BAG.P.Position, s_BA_Kost_Mat_Nr, c_Akt_BA_UmlageMINUS, Mat.A.Bemerkung, vPreis, vBasis, vBproM, aAdr, gStartDat, gStartTim)=false) then begin
// 12.02.2021 AH:
        if (NeueAktion(BAG.P.Position, s_BA_Kost_Mat_Nr, c_Akt_BA_Schrott, Mat.A.Bemerkung, vPreis, vBasis, vBproM, vCO2, aAdr, gAbschlussAm, gAbschlussUm)=false) then begin
          RETURN false;
        end;
      end;
    END;

  END;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _NulleReste(
  aAdr          : int;
) : logic;
local begin
  Erx     : int;
  vPreis  : float;
  vBasis  : float;
  vBProM  : float;
  vCO2    : float;
end;
begin
  // Restkarten "nullen" -------------------------------------------------
  FOR Erx # RecLink(701,702,2,_recFirst)            // Input loopen
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.Materialtyp=c_IO_Mat) then begin     // Material??

      //if (Mat_Data:Read(BAG.IO.MaterialRstNr)=falsE) then
      if (_MatRead(BAG.IO.MaterialRstNr)=false) then
        RETURN false;

      if (BAG.P.Aktion=c_BAG_Fahr09) and (s_BA_Kost_Mat_Loeschmark='') then CYCLE;

      // 08.01.2013 AI
      //if (cVerschrotteBasis=false) then begin NUR PER AKTIONEN
        vPreis  # -1.0 * (s_BA_Kost_Mat_EkPreis + s_BA_Kost_Mat_Kosten);
        vCO2    # -1.0 * (s_BA_Kost_Mat_CO2 + s_BA_Kost_Mat_CO2Kosten + s_BA_Kost_Mat_CO2Schrott);
      //end
      //else begin
      //  vPreis # -1.0 * s_BA_Kost_Mat_Kosten;
      //  vBasis # -1.0 * s_BA_Kost_Mat_EkPreis;
      //  vBproM # -1.0 * s_BA_Kost_Mat_EkPreisPro;
      //end;
      if (vPreis<>0.0) or (vBasis<>0.0) or (vCO2<>0.0) then begin
        Mat.A.Bemerkung # c_AktBem_BA_Nullung+':';
        if (RunAFX('BAG.FM.Set.MatABemerkung','')=0) then
          Mat.A.Bemerkung # Mat.A.Bemerkung + BAG.P.Aktion2;
        if (NeueAktion(BAG.P.Position, BAG.IO.MaterialRstNr, c_Akt_BA_UmlageMINUS, Mat.A.Bemerkung, vPreis, vBasis, vBproM, vCO2, aAdr, gAbschlussAm, gAbschlussUm)=false) then begin
          RETURN false;
        end;
      end;
    end;
  END;

  RETURN true;
end;


//========================================================================
//  UpdatePosition
//
//  FAHREN darf so NICHT die Kosten berechnen(bzw. Abwertungen vom Schrott vornehmen), WENN es das 1. Fahren im BA ist,
//  da dann dirkete Kinder des Fahr-Einsatzmaterials existieren
//  (Fahren leigt nicht wie Spalten etc. schon eine Restkarte "zum Fahren" an)
//  Würde man dann in dieser die Abwertung machen, würde sie auf alle Kinder vererbt werden => FALSCH
//  Wird das Fahren "später" in BA gemacht, klappt das aber.
//  Beim Spalten etc. finden die Abwertungen im "Reststrang" statt
//========================================================================
sub UpdatePosition(
  aBAG            : int;
  aPos            : int;
  opt aSilent     : logic;
  opt aNoProto    : logic;
  opt aRecalc     : logic;
  opt aDiffTxt    : int;
  opt aNoTrans    : logic) : logic;
local begin
  Erx           : int;
  vX            : float;
  vBeistellSum  : float;
  vKostenSum    : float;
  vEinsatz      : float;
  vEinsatzKG    : float;
  vCO2          : float;
  vFertigGew    : float;
  vTraegerGew   : float;
  vSchrottWert  : float;
  vSchrottGew   : float;
  vSchrottCO2eigen  : float;
  vSchrottCO2fremd  : float;

  vAdr          : int;
  vBuf100       : int;

  vDia          : int;
  vMsg          : int;

  vMDI          : int;
  vA            : alpha;

  vAnteilSchrott  : float;
  vAnteilKosten   : float;
  vAnteilBeistell : float;
  vAnteilCo2Out   : float;
  vAnteilCo2In    : float;
  vAnteilSchrottCo2eigen : float;
  vAnteilSchrottCo2fremd : float;
  vSchrottPreis   : float;
  vSchrottErl     : float;
end;
begin

  BAG.Nummer    # aBAG;
  Erx # RecRead(700,1,0);
  if (Erx>_rLocked) then RETURN false;
  if (BAG.BuchungsAlgoNr=3) then
    RETURN BA1_Kosten3:UpdatePosition(aBAG, aPos, aSilent, aNoProto, aRecalc, aDiffTxt, aNoTrans);

  GV.Int.01 # 0;
  GV.Alpha.99 # '';
  gDiffTxt # aDiffTxt;

  // Settings prüfen
  if (Set.Ba.lohnKost.Wie<>'G') and (Set.Ba.lohnKost.Wie<>'K') then STOP;

  // Ankerfunktion starten
  if (aSilent) then
    vA # aint(aBAG)+'|'+aint(aPos)+'|Y'
  else
    vA # aint(aBAG)+'|'+aint(aPos)+'|N';
  if (aNoProto) then
    vA # vA + '|Y'
  else
    vA # vA + '|N';
  if (aRecalc) then
    vA # vA + '|Y'
  else
    vA # vA + '|N';
  vA # vA + '|'+aint(aDiffTxt);
  if (aNoTrans) then
    vA # vA + '|Y'
  else
    vA # vA + '|N';
  if (RunAFX('BAG.Kosten',vA)<>0) then begin
    RETURN (AfxRes=_rOK);
  end;

  if (_CheckBaPos(aBAG, aPos)=false) then
    STOP;

  gAbschlussAm  # BAG.P.Fertig.Dat;
  gAbschlussUm  # BAG.P.Fertig.Zeit;

  // Dienstleister holen
  if (BAG.P.ExternYN) then begin
    vBuf100 # RekSave(100);
    RecLink(100,702,7,_recFirst);
    vAdr # Adr.Nummer;
    RekRestore(vBuf100);
  end
  else begin
    // 14.02.2020 AH: Zeitkosten in Pos übernehmen bei INTERNER Produktion
    if (Set.BA.ZeitKostInPos) then begin
      // Zeiten addieren
      FOR Erx # RecLink(709,702,6,_recFirst)
      LOOP Erx # RecLink(709,702,6,_recNext)
      WHILE (Erx<=_rLocked) do begin
        vX # vX + BAG.Z.GesamtkostenW1;
      END;
      if (BAG.P.Kosten.Fix<>vX) then begin
        Erx # RecRead(702,1,_recLock);
        if (Erx=_rOK) then begin
          BAG.P.Kosten.Fix # vX;
          Erx # RekReplace(702);
        end;
        if (Erx<>_rOK) then RETURN false;
      end;
    end;
  end;
  

  if (aSilent = false) then begin
    vMDI # gMDI;
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
    vMsg # Winsearch(vDia,'Progress');
    vMsg->wpvisible # false;
    vMsg # Winsearch(vDia,'Bt.Abbruch');
    vMsg->wpvisible # false;
    vMsg # Winsearch(vDia,'Label1');
    vMsg->wpcaption # Translate('Berechne BAG')+' '+aint(BAG.P.Nummer)+'/'+aint(Bag.P.Position)+'...';
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter, vMDI);
  end;

  APPOFF();   // 16.10.2019

@ifdef PROTOKOLL
mydebug('POS '+aint(bag.p.position)+' -----------------------------------------------------------');
@endif

  _SummePosKosten(var gStartDat, var gStartTim, var vBeistellSum, var vEinsatz, var vEinsatzKG, var vCO2);

  vKostenSum # BAG.P.Kosten.Fix;
  if (BAG.P.Kosten.PEH<>0) then
    vKostenSum # vKostenSum + (BAG.P.Kosten.pro * vEinsatz / cnvfi(BAG.P.Kosten.PEH));

  Erx # RecRead(702,1,_recLock | _recNoLoad);         // Position sperren
  if (erx=_rOK) then begin
    BAG.P.Kosten.Gesamt # vKostenSum;
    BAG.P.Kosten.CO2    # vCO2;
    Erx # RekReplace(702);                        // Position speichern
  end;
  if (Erx<>_rOK) then begin
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    Error(702047,aint(BAG.P.nummer));
    STOP;
  end;
  Lib_Berechnungen:Waehrung_Umrechnen(vKostenSum, BAG.P.Kosten.Wae, var vKostenSum, 1);


  // Materialbaum bauen & direkte Schrottwerte summieren
  vMsg # LoopAllMat();
  if (vMsg<0) then begin
    ProcessDict(false);
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    Error(702027,aint(-vMsg));
    STOP;
  end;


  // needs MAT
  if (_SummeFMs(vKostenSum, vBeistellSum, vCo2, var vFertigGew, var vTraegerGew, var vSchrottgew, var vSchrottWert, var vAnteilKosten, var vAnteilCo2Out)=false) then begin
    ProcessDict(false);
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    STOP;
  end;

  if (vEinsatzKG<>0.0) then
    vAnteilCO2In # Rnd(vCO2/vEinsatzKG*1000.0,2);

@ifdef PROTOKOLL
mydebug('traegergew:'+anum(vtraegerGew,0)+'   schrottgew:'+anum(vSchrottGew,0));
mydebug('geskost:'+anum(vKostensum,2) + '    anteil:'+anum(vAnteilKosten,2)+'    Co2:'+anum(vCo2,2)+' anteil:'+anum(vAnteilCo2Out,2));
mydebug('killen...');
@endif

  // bisherige Aktionen/BB löschen -------------------------------------
  if (_KillAktUndBB()=false) then begin
    ProcessDict(false);
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextClose(vProtokoll);
    STOP;
  end;

@ifdef PROTOKOLL
mydebug('...killen');
@endif

  if (SumSchrottUndSetEK(var vSchrottGew, var vSchrottWert, var vSchrottCO2eigen, var vSchrottCO2fremd, vAnteilCo2In )=false) then begin
    ProcessDict(false);
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextClose(vProtokoll);
    STOP;
  end;


  if (vTraegerGew<>0.0) then begin
    vAnteilSchrott    # Rnd(vSchrottwert*1000.0 / vTraegerGew,2);
    //vAnteilSchrottCo2 # Rnd(vSchrottCo2*1000.0 / vTraegerGew,2);
    vAnteilSchrottCo2eigen  # Rnd(vSchrottCo2Eigen*1000.0 / vTraegerGew,2);
    vAnteilSchrottCo2fremd  # Rnd(vSchrottCo2fremd*1000.0 / vTraegerGew,2);
    if (Set.Installname='BSP') then begin
      RecBufClear(935);
      Dic.Key # 'Schrott_PreisProT';
      Erx # recRead(935,1,0);
      if (Erx<=_rLocked) then begin
        vSchrottPreis # cnvfa(Dic.Value)
        vSchrottErl   # Rnd(vSchrottPreis * vSchrottGew / 1000.0,2);
        vSchrottErl   # Rnd(vSchrottErl * 1000.0 / vTraegerGew,2);
      end;
    end;
  end;

  if (aNoTrans=false) then TRANSON;

  // BA-Position ist noch offen?? -> dann keine Kosten eintragen = ENDE !!!!!!!!!!!!!
  if ("BAG.P.Löschmarker"='') then begin

    if (ProcessDict(true)=false) then begin
      if (aNoTrans=false) then TRANSBRK;
      MyWinClose(vDia);
      if (vProtokoll<>0) then TextCLose(vProtokoll);
      STOP;
    end;

    if (aNoTrans=false) then TRANSOFF;
    // Einkaufskontrolle durchführen
    Recread(702,1,0);
    if (EKK_Data:Update(702)=false) then begin
      MyWinClose(vDia);
      if (vProtokoll<>0) then TextCLose(vProtokoll);
      STOP;
    end;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    //STOP;
    // 28.11.2018 AH
    
    APPON();
    RETURN true;
  end;




@ifdef PROTOKOLL
mydebug('schrottgew:'+anum(vSchrottGew,0)+'   schrottwert:'+anum(vschrottwert,2)+'  anteil:'+anum(vAnteilSchrott,2));
mydebug('schrottCo2 eigen:'+anum(vSchrottCo2eigen,2)+' anteil:'+anum(vAnteilSchrottCo2eigen,2));
mydebug('schrottCo2 fremd:'+anum(vSchrottCo2fremd,2)+' anteil:'+anum(vAnteilSchrottCo2fremd,2));
@endif

  // neue Kostenaktionen anlegen -------------------------------------------
  if (vTraegerGew<>0.0) then begin
@ifdef PROTOKOLL
mydebug('umlegen...');
@endif
    Mat.A.Bemerkung # '';
    if (RunAFX('BAG.FM.Set.MatABemerkung','')=0) then
      Mat.A.Bemerkung # BAG.P.Aktion2;
//    if (Pos2Fert(BAG.P.Position, Mat.A.Bemerkung, vAdr, vAnteilSchrott, vAnteilKosten, vAnteilSchrottCo2, vAnteilCo2)=false) then begin
    if (Pos2Fert(BAG.P.Position, Mat.A.Bemerkung, vAdr, vAnteilSchrott, vAnteilKosten, vAnteilSchrottCo2Eigen, vAnteilSchrottCo2Fremd, vSchrottErl, vSchrottPreis)=false) then begin
      if (aNoTrans=false) then TRANSBRK;
      ProcessDict(false);
      MyWinClose(vDia);
      ErrorOutput;
      if (vProtokoll<>0) then TextCLose(vProtokoll);
      STOP;
    end;
@ifdef PROTOKOLL
mydebug('...umlegen...');
@endif


    // Schrottnullungen ========================================================
// 11.10.2021    if ((BAG.P.Aktion<>c_BAG_Versand) and (BAG.P.Aktion<>c_BAG_Fahr09) and (BAG.P.Aktion<>c_BAG_Umlager)) or
//     ((Set.BA.LFA.SchrtUmlg) and (BAG.P.Aktion=c_BAG_Fahr09)) then begin
    if (BA1_P_data:DarfKostenHaben()) then begin

      if (_NulleSchrottFMs(vAdr)=false) then begin
        if (aNoTrans=false) then TRANSBRK;
        MyWinClose(vDia);
        ErrorOutput;
        if (vProtokoll<>0) then TextCLose(vProtokoll);
        STOP;
      end;

      if (_NulleReste(vAdr)=false) then begin
        if (aNoTrans=false) then TRANSBRK;
        MyWinClose(vDia);
        Erroroutput;
        if (vProtokoll<>0) then TextCLose(vProtokoll);
        STOP;
      end;

    end;
  end;  // Träger<>0



  // Pauschalkosten des LFS vererben...

  if (BAG.P.Aktion=c_BAG_Fahr09) then begin
    Erx # RecLink(440,702,14,_recFirst)     // Lieferschein loopen
    if (Erx>_rLocked) then begin
      if (aNoTrans=false) then TRANSBRK;
      MyWinClose(vDia);
      if (vProtokoll<>0) then TextCLose(vProtokoll);
      STOP;
    end;

    if (aRecalc=false) then begin
      FOR Erx # RecLink(440,702,14,_recFirst)     // Lieferschein loopen
      LOOP Erx # RecLink(440,702,14,_recNext)
      WHILE (Erx<=_rLocked) do begin
  // zur Info: Umlageraufträge können hier bearbeitet werden, da
  //  die Lieferscheinpositionen entfernt sind
        Lfs_Data:KostenAusLFA();
      END;
    end;
  end;

  if (ProcessDict(true)=false) then begin
    if (aNoTrans=false) then TRANSBRK;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    STOP;
  end;

  if (aNoTrans=false) then TRANSOFF;

  APPON();

  MyWinClose(vDia);

  if (vProtokoll<>0) then begin
    TextAddLine(vProtokoll,'[ENDE]');
    TextDelete(myTmpText,0);
    TextWrite(vProtokoll,MyTmpText,0);
    TextClose(vProtokoll);
    if (aNoProto=false) then Mdi_TxtEditor_Main:Start(MyTmpText, n, 'Protokoll');
    TextDelete(myTmpText,0);
  end;

  // Einkaufskontrolle durchführen
  Recread(702,1,0);

  if (EKK_Data:Update(702)=false) then STOP;

  // Alles IO
  RETURN true;
end;



//=======================================================================
//=======================================================================
//=======================================================================