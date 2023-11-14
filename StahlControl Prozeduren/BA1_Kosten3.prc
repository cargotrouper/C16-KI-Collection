@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Kosten3
//                OHNE E_R_G
//  Info
//
//
//  04.05.2020  AH  Erstellung der Prozedur
//  28.10.2020  AH  Fix Endlosloop
//  23.11.2020  AH  AFX "BAG.Kosten.Post"
//  08.12.2020  AH  Fix "VererbeKosten" nicht an andere FM-Aktionen
//  11.10.2021  AH  ERX
//  08.11.2021  AH  Mat.Aktion "Schrottumlage" nimmt Schrottgewicht auf
//  09.11.2021  AH  verbessert (Schrottgew anteilig absolut)
//  09.03.2022  AH  AFX "BAG.Kosten.Save204.Post"
//  07.04.2022  AH  Fix: Umlage auf FM je Verwiegungsart
//  2022-08-29  AH  Fix: Abwertungen wurden beim Nachkalkulieren nicht vorab entfernt
//  2022-09-26  AH  Edit: Fahren rechnet BRUTTOGEWICHT
//  2022-12-08  AH  Einsatzbewertung nach MEH
//
//  Subprozeduren
//    SUB KillAllMatAktionen(aTyp : alpha; aNr : int; aPos : int; aPos2 : int) : logic;
//    sub NeueAktion(aMatNr  : int;aAkt    : alpha; aBemerk : alpha; aPreis  : float;   aBasis  : float;  aAdr : int; aDatum : date) : logic;
//    sub KostenAnWeiterbearbeitungen(aPos : int; aAkt : alpha; aBem1 : alpha; aBem2 : alpha; aPreis : float; aAdr : int; aNurID : int) : logic;
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
  mydebug(a)  : if (BAG.P.Position>=0) then debug(StrChar(32,Gv.Int.01*3)+a)
  plus        : inc(gv.int.01)
  minus       : dec(gv.int.01)
  myWinclose(a) : begin if(aSilent = false) then begin Winclose(a); if (vMDI->wpcustom<>'') and (vMDI->wpcustom<>cnvai(VarInfo(WindowBonus))) then    VarInstance(WindowBonus,cnvIA(vMDI->wpcustom)); end; end
  Stop      : begin APPON(); GV.Alpha.99 # GV.Alpha.99 + ';'+aint(__LINE__); RETURN false; end;
  atime(a)  : cnvat(a,_FmtTimeHSeconds)
//  dudu(a) : (a=5158) or (a=51460)
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
  s_BA_Kost_Mat_Gew         : float;
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
  s_BA_Kost_Akt_Gew         : float;
  s_BA_Kost_Akt_Menge       : float;
  s_BA_Kost_Akt_Datum       : date;
  s_BA_Kost_Akt_Zeit        : time;
  s_BA_Kost_Akt_Start       : date;
  s_BA_Kost_Akt_Ende        : date;
  s_BA_Kost_Akt_KSt         : int;
  s_BA_Kost_Akt_Kosten      : float;
  s_BA_Kost_Akt_KostenPro   : float;
end;

declare Pos2Fert(aPos : int; aAG : alpha; aAdr : int; aAnteilSchrott : float; aAnteilKosten : float; aTraegerM : float; aSM : float; aMEH : alpha) : logic

local begin
  gAbschlussAm    : date;
  gAbschlussUm    : time;
  gStartDat       : date;
  gStartTim       : time;
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
sub MatRead(aMat : int) : logic;
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
  Mat.Nummer          # aMat;
  Mat.Bewertung.Laut  # s_BA_Kost_Mat_Laut;
  Mat.Strukturnr      # s_BA_Kost_Mat_Struktur;
  "Mat.Löschmarker"   # s_BA_Kost_Mat_LoeschMark;
  Mat.EK.Preis        # s_BA_Kost_Mat_EkPreis;
  Mat.EK.PreisProMEH  # s_BA_Kost_Mat_EkPreisPro
  Mat.Kosten          # s_BA_Kost_Mat_Kosten;
//if (dudu(Mat.Nummer)) then debugx('MatRead '+aint(Mat.Nummer)+' Kosten '+anum(Mat.Kosten,2));
  Mat.KostenProMEH    # s_BA_Kost_Mat_KostenPro;
  Mat.EK.Effektiv     # s_BA_Kost_Mat_EkPreis + s_BA_Kost_Mat_Kosten;
  Mat.EK.EffektivProME  # s_BA_Kost_Mat_EkPreisPro + s_BA_Kost_Mat_KostenPro;
  Mat.Bestand.Gew     # s_BA_Kost_Mat_KG;
  Mat.Bestand.Menge   # s_BA_Kost_Mat_Menge;    // 2022-12-08 AH

  RETURN true;
end;


//========================================================================
//========================================================================
sub MatUse(
  aMat          : int;
//  aIstRest      : logic;
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
    RETURN MatRead(aMat);
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

  v200b # RekSave(200);   // 26.02.2021 AH: Fix für Einsatz 1. aus 2. gesplittet (GW!)
  
  // Aktionen loopen...
  FOR Erx # RecLink(204,200,14,_recFirst)
  LOOP Erx # RecLink(204,200,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.A.Entstanden=0) then CYCLE;

    v204 # RekSave(204);
//    if (MatUse(Mat.A.Entstanden, Mat.A.Aktionstyp=c_Akt_BA_Rest, Mat.A.Aktionstyp=c_Akt_Mat_Kombi)=false) then begin
    if (MatUse(Mat.A.Entstanden, Mat.A.Aktionstyp=c_Akt_Mat_Kombi)=false) then begin
      RecBufDestroy(v200b);
      RekRestore(v204);
      RekRestore(v200);
      RETURN false;
    end;
    RecBufCopy(v200b, 200);
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
  s_BA_Kost_Akt_Gew         # aBuf->Mat.A.Gewicht;
  s_BA_Kost_Akt_Menge       # aBuf->Mat.A.Menge;
  s_BA_Kost_Akt_Datum       # aBuf->Mat.A.Aktionsdatum;
  s_BA_Kost_Akt_Zeit        # aBuf->Mat.A.Aktionszeit;
  s_BA_Kost_Akt_Start       # aBuf->Mat.A.TerminStart;
  s_BA_Kost_Akt_Ende        # aBuf->Mat.A.TerminEnde;
  s_BA_Kost_Akt_Adr         # aBuf->Mat.A.Adressnr;
  s_BA_Kost_Akt_KST         # aBuf->Mat.A.Kostenstelle;
  s_BA_Kost_Akt_Kosten      # aBuf->Mat.A.KostenW1;
  s_BA_Kost_Akt_KostenPro   # aBuf->Mat.A.KostenW1ProMEH;
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
  aKostPro  : float
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
    RETURN true
  end;

  aBuf->Mat.A.KostenW1        # aKost;
  aBuf->Mat.A.KostenW1ProMEH  # aKostPro;
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
sub _AktNeu() : logic;
local begin
  vInhalt : alpha;
  vInst   : bigint;
  vKey    : alpha;
  vItem   : int;
  vRecID  : BigInt;
end;
begin
// 2023-01-20 AH
//debugx('proTonne : '+anum(s_BA_Kost_Mat_Kosten,2)+' + '+anum(Mat.A.KostenW1,2));
//debugx('proMEH   : '+anum(s_BA_Kost_Mat_KostenPro,2)+' + '+anum(Mat.A.KostenW1ProMEH,2));
  s_BA_Kost_Mat_Kosten    # s_BA_Kost_Mat_Kosten + Mat.A.KostenW1;
  s_BA_Kost_Mat_KostenPro # s_BA_Kost_Mat_KostenPro + Mat.A.KostenW1ProMEH;

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
  aFirst            : logic;
  aDat              : date;
  aTim              : time;
  opt aKombiVorg    : int) : logic;
local begin
  Erx       : int;
  v200      : int;
  v204      : int;
  vX,vY     : float;
  vKombiNr  : int;
  vInst     : int;
end;
begin
  if (aKostenDiff=0.0) then RETURN true;
//debug('vererbekostendiff :'+anum(aKostenDiff,2));

  if (s_BA_Kost_Mat_Nr<>aMat) then begin
    if (MatRead(aMat)=false) then RETURN false;
  end;

  v200 # RecBufCreate(s_BA_Kost_Mat_Datei);
  FldDef(v200, 1,1, aMat);
  if (RecRead(v200, 1, 0)>_rLocked) then begin
    RecBufClear(v200);
    RETURN false;
  end;
  
//debug('M'+aint(aMat)+' Vererbungszeit :'+cnvat(vtim,_FmtTimeHSeconds)+' +'+anum(aKostenDiff,2));
  if (aFirst=false) then begin
    s_BA_Kost_Mat_Mody      # true;
    s_BA_Kost_Mat_Kosten    # s_BA_Kost_Mat_Kosten + aKostenDiff;
    s_BA_Kost_Mat_KostenPro # s_BA_Kost_Mat_KostenPro + aKostenDiffPro;
  end;
  
  v204 # RecbufCreate(204);
  FOR Erx # RecLink(v204,v200,14,_recFirst)
  LOOP Erx # RecLink(v204,v200,14,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (v204->Mat.A.Aktionsdatum<aDat) or ((v204->Mat.A.Aktionsdatum=aDat) and (v204->Mat.A.Aktionszeit<=aTim)) then CYCLE;
 // 11.05.2020 AH + "="
 
    // alte KOMBI-Aktion anpassen ???
    if (aKombiVorg<>0) then begin
      if (v204->Mat.A.Aktionstyp=c_Akt_Mat_Kombi) and
         (v204->Mat.A.Aktionsmat=aKombiVorg) and (v204->Mat.A.Entstanden=0) then begin
         vInst # VarInfo(struct_BA_Kost_Akt);
        _AktMod(v204, aKostenDiff, aKostenDiffPro);
        VarInstance(struct_BA_Kost_Akt, vInst);
      end;
    end;

    if (v204->Mat.A.Entstanden=0) then CYCLE;

    // 28.04.2017 AH NEU NEU NEU
    if (v204->Mat.A.Aktionsdatum<gAbschlussam) then CYCLE;   // 03.07.2019 AH: war "<="

    // 08.12.2020 AH: Fertigungen zu dem BA aus diesem Mat. bekommen keine Kostenumlagen vererbt
    // Kommt, wennn man Abschlussdatum VOR FM-Datum hat
    if (v204->Mat.A.aktionstyp=c_Akt_BA_Fertig) and
      (v204->Mat.A.Aktionsnr=BAG.P.Nummer) and
      (v204->Mat.A.Aktionspos=BAG.FM.Position) then begin
      CYCLE;
    end;;

    vX # aKostenDiff;
    vY # aKostenDiffPro;

    vKombiNr # 0;
    // KOMBI??? Dann Anteil vererben...
    if (v204->Mat.A.Aktionstyp=c_Akt_Mat_Kombi) then begin
      if (MatRead(v204->Mat.A.Entstanden)=false) then begin
        RecBufDestroy(v200);
        RecBufDestroy(v204);
        RETURN false;
      end;

      if (s_BA_Kost_Mat_StartKG<>0.0) then begin
        vX # aKostenDiff * v204->Mat.A.Gewicht / 1000.0;  // Summe Kosten für Kind
        vX # Rnd(vX / (s_BA_Kost_Mat_StartKG / 1000.0), 2);
      end
      else
        vX # 0.0;

      if (s_BA_Kost_Mat_StartMenge<>0.0) then begin
        vY # aKostenDiffPro * v204->Mat.A.Menge / 1000.0;  // Summe Kosten für Kind
        vY # Rnd(vY / (s_BA_Kost_Mat_StartMenge / 1000.0), 2);
      end
      else
        vY # 0.0;

      if (vX=0.0) and (vY=0.0) then CYCLE;
      vKombiNr # aMat;
    end;

   if (_VererbeKostenDiff(v204->Mat.A.Entstanden, vX, vY, false, aDat, aTim, vKombiNr)=false) then begin
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

//debugx('killen von: '+atyp+aint(aNr)+'/'+aint(apos)+'/'+aint(aPos2));
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

    if (MatRead(Mat.A.Materialnr)=false) then
      RETURN false;

    s_BA_Kost_Mat_Mody      # true;
    s_BA_Kost_Mat_Kosten    # s_BA_Kost_Mat_Kosten - Mat.A.KostenW1;
    s_BA_Kost_Mat_KostenPro # s_BA_Kost_Mat_KostenPro - Mat.A.KostenW1ProMEH;

//debugx('killen von: '+atyp+aint(aNr)+'/'+aint(apos)+'/'+aint(aPos2)+' KEY204');
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

   if (MatRead(Mat.B.Materialnr)=false) then
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
  aAdr    : int;
  aMenge  : float;
  aMEH    : alpha;
  aDatum  : date;
  aZeit   : time;
) : logic;
local begin
  Erx     : int;
  vBuf702 : int;
  vBuf    : int;
end;
begin

//@ifdef PROTOKOLL
//mydebug(aint(aMatNr)+' '+aAkt+' '+aBemerk+'  für pos '+aint(aPos));
//@endif
//
  if (MatRead(aMatNr)=false) then
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
  Mat.A.Aktionszeit   # aZeit;
  Mat.A.Terminstart   # vBuf702->BAG.P.Plan.StartDat;
  Mat.A.Terminende    # vBuf702->BAG.P.Plan.EndDat;
  Mat.A.Adressnr      # aAdr;
//vWert # aPreis * aMenge / 1000.0; // Tonnen!
//debugx('WERT:'+anum(aPreis,2)+' * '+anum(aMenge,2)+' bei Bestand '+anum(mat.bestand.menge,2)+' bas:'+anum(aBasis,2)+';'+anum(aBproM,2));
  if (aMEH='kg') then begin
    Mat.A.KostenW1        # aPreis;
    Mat.A.Gewicht         # aMenge;
Mat.A.menge # Mat.Bestand.Menge;  // 2023-01-20 AH
//DivOrNull(Mat.A.KostenW1ProMEH, vWert, Mat.Bestand.Menge, 2);
  end;
  else begin
    Mat.A.KostenW1ProMEH  # aPreis;
    Mat.A.Menge           # aMenge;
  end;
  
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
// 2023-01-20 AH
// in _aktNeu  s_BA_Kost_Mat_Kosten    # s_BA_Kost_Mat_Kosten + Mat.A.KostenW1;
//  s_BA_Kost_Mat_KostenPro # s_BA_Kost_Mat_KostenPro + Mat.A.KostenW1ProMEH;
  _AktNeu();

  RecBufDestroy(vBuf702);

  RETURN true;
end;


//========================================================================
//  KostenAnWeiterbearbeitungen
//
//========================================================================
sub KostenAnWeiterbearbeitungen(
  aPos        : int;
  aAkt        : alpha;
  aBem1       : alpha;
  aBem2       : alpha;
  aPreis      : float;
  aTraegerM   : float;
  aSM         : float;
  aMEH        : alpha;
  aAdr        : int;
  aNurID      : int;
) : logic;
local begin
  Erx       : int;
  vBuf702   : int;
  vBuf701   : int;
  vSM       : float;
  vOK       : logic;
end;
begin

//@ifdef PROTOKOLL
//mydebug('Fert '+aint(bag.F.position)+'/'+aint(bag.f.fertigung)+'   nurID:'+aint(aNurID));
//plus;
//@endif
//
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
if (aTraegerM<>0.0) then begin
  if (aMEH='kg') then
    vSM # BAG.IO.Ist.In.GewN * aSM / aTraegerM
  else
    vSM # BAG.IO.Ist.In.Menge * aSM / aTraegerM;
end;
//debugx('neu an '+aint(BAG.IO.Materialnr));
        // Kosten bei START
        vOK # NeueAktion(aPos, BAG.IO.Materialnr, aAkt, aBem1+':'+aBem2, aPreis, 0.0, 0.0, aAdr, vSM, aMEH, gStartDat, gStartTim);
        if (vOK=false) then begin
          RekRestore(vBuf702);
          RETURN false;
        end;
      end;
      
      RekRestore(vBuf702);
    end;

  END;

  RekRestore(vBuf701);

//@ifdef PROTOKOLL
//minus;
//mydebug('<Fert '+aint(bag.F.position)+'/'+aint(bag.f.fertigung));
//@endif
//
  RETURN true;
end;


//========================================================================
//  Pos2Fert
//
//========================================================================
sub Pos2Fert(
  aPos        : int;
  aAG         : alpha;
  aAdr        : int;
  aAnteilSchrott  : float;  // EUR
  aAnteilKosten   : float;  // EUR
  aTraegerM       : float;
  aSM             : float;
  aMEH            : alpha;) : logic
local begin
  Erx     : int;
  vBuf703 : int;
  vBuf702 : int;
  vBuf701 : int;
end;
begin


// mm=kg; 105mm 104mm, 120mm   ; SchrottRest Theo 5+4+20 aber echt5+2+15=22kg
// Summe der KOSTENTRÄGER FMs: 100+102+105=307kg
// 1. FM: 100kg=100mm -> 32,5% von 22kg  -> 6g
// 2. FM: 102kg=102mm -> 33,2% von 22kg  -> 7kg
// 3. FM: 105kg=105mm -> 34,2% von 22kg  -> 9kg
// 4. FM: 10kg=10mm -> kein Kostenträger!!!

// Paras:
//  PosKosten:  100€ + 50€ Schrottkosten
//  PosSchrott: 22kg
//  FmGew:      307kg
//


  vBuf703 # RekSave(703);

  FOR Erx # RecLink(703,702,4,_recFirst)          // Fertigungen loopen
  LOOP Erx # RecLink(703,702,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if ("BAG.F.KostenträgerYN"=n) then begin    //  kein Träger?
      CYCLE;
    end;

    // Umlage eintragen
    if (aAnteilSchrott<>0.0) or (aSM<>0.0) then begin
@ifdef PROTOKOLL
mydebug('schorttumlage von '+aint(aPos)+' für '+aint(bag.f.position)+'/'+aint(bag.f.fertigung));
@endif
      if (KostenAnWeiterbearbeitungen(aPos, c_Akt_BA_UmlagePLUS, c_AktBem_BA_Umlage, aAG, aAnteilSchrott, aTraegerM, aSM, aMEH, aAdr, 0)=false) then begin
        RETURN false;
      end;
    end;

    // Kosten eintragen
    if (aAnteilKosten<>0.0) then begin
@ifdef PROTOKOLL
mydebug('Kostenumlage von '+aint(aPos)+' für '+aint(bag.f.position)+'/'+aint(bag.f.fertigung));
@endif
      if (KostenAnWeiterbearbeitungen(aPos, c_Akt_BA_Kosten, c_AktBem_BA_Kosten, aAG, aAnteilKosten, aTraegerM, aSM, aMEH, aAdr, 0)=false) then begin
        RETURN false;
      end;
    end;
  END;

  RekRestore(vBuf703);
  RETURN true;
end;

/**** 09.11.2021 ALT
//========================================================================
//  Pos2Fert
//
//========================================================================
sub Pos2Fert(
  aPos        : int;
  aAG         : alpha;
  aAdr        : int;
  aAnteilSchrott  : float;
  aAnteilKosten   : float;
  aSGew           : float) : logic
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
    if (aAnteilSchrott<>0.0) then begin
@ifdef PROTOKOLL
mydebug('schorttumlage von '+aint(aPos)+' für '+aint(bag.f.position)+'/'+aint(bag.f.fertigung));
@endif
      if (KostenAnWeiterbearbeitungen(aPos, c_Akt_BA_UmlagePLUS, c_AktBem_BA_Umlage, aAG, aAnteilSchrott, aSGew, aAdr, 0)=false) then begin
        RETURN false;
      end;
    end;
//debug('..............................................');

    // Kosten eintragen
    if (aAnteilKosten<>0.0) then begin
@ifdef PROTOKOLL
mydebug('Kostenumlage von '+aint(aPos)+' für '+aint(bag.f.position)+'/'+aint(bag.f.fertigung));
@endif
      if (KostenAnWeiterbearbeitungen(aPos, c_Akt_BA_Kosten, c_AktBem_BA_Kosten, aAG, aAnteilKosten, aSGew, aAdr, 0)=false) then begin
        RETURN false;
      end;
    end;

    Erx # RecLink(703,702,4,_recNext);
  END;

  RekRestore(vBuf703);
  RETURN true;
end;
****/

//========================================================================
//========================================================================
sub _Save204() : logic;
local begin
  Erx       : int;
  vKost     : float;
  vKostPRo  : float;
end;
begin
//debugx(s_BA_Kost_Akt_Todo+' @Mat'+aint(s_BA_Kost_Akt_matNr)+' recid:'+cnvab(s_BA_Kost_Akt_RecID));
  if (s_BA_Kost_Akt_Todo='NEW') then begin
    if (Mat_Data:Read(s_BA_Kost_Akt_Matnr)<200) then
      RETURN false;
    if (MatRead(s_BA_Kost_Akt_MatNr)=false) then
      RETURN false;

    RecBufClear(204);
    Mat.A.Materialnr      # s_BA_Kost_Akt_MatNr;
    Mat.A.Aktionsmat      # s_BA_Kost_Akt_MatNr;
    Mat.A.Aktionstyp      # s_BA_Kost_Akt_Typ;
    Mat.A.Aktionsnr       # s_BA_Kost_Akt_Nr;
    Mat.A.Aktionspos      # s_BA_Kost_Akt_Pos;
    Mat.A.Bemerkung       # s_BA_Kost_Akt_Bem;
    Mat.A.Gewicht         # s_BA_Kost_Akt_Gew;
    Mat.A.Menge           # s_BA_Kost_Akt_Menge;
    Mat.A.Aktionsdatum    # s_BA_Kost_Akt_Datum;
    Mat.A.Aktionszeit     # s_BA_Kost_Akt_Zeit;
    Mat.A.Terminstart     # s_BA_Kost_Akt_Start;
    Mat.A.Terminende      # s_BA_Kost_Akt_Ende;
    Mat.A.Adressnr        # s_BA_Kost_Akt_Adr;
    Mat.A.KostenW1        # s_BA_Kost_Akt_Kosten;
    Mat.A.KostenW1ProMEH  # 0.0;//s_BA_Kost_Akt_KostenPro;
    Mat.A.Kostenstelle    # s_BA_Kost_Akt_KST;
// HIER WIRD /Tonne und /MEH gesetzt:
    if (Mat_A_data:Insert(0,'AUTO')<>_rOK) then
      RETURN false;
    if (_VererbeKostenDiff(Mat.A.Materialnr, Mat.A.KostenW1, Mat.A.KostenW1ProMEH, true, Mat.A.Aktionsdatum, Mat.A.Aktionszeit)=false) then
      RETURN false;

  end // ADD
  else if (s_BA_Kost_Akt_Todo='DEL') then begin

    if (Mat_Data:Read(s_BA_Kost_Akt_Matnr)<200) then
      RETURN false;
    if (MatRead(s_BA_Kost_Akt_MatNr)=false) then
      RETURN false;

    Erx # RecRead(204,0,_RecId, s_BA_Kost_Akt_RecID);
    if (Erx<>_rOK) then
      RETURN false;
    Erx # RekDelete(204);
    if (Erx<>_rOK) then
      RETURN false;
    if (_VererbeKostenDiff(Mat.A.Materialnr, -Mat.A.KostenW1, -Mat.A.KostenW1ProMEH, true, Mat.A.Aktionsdatum, Mat.A.Aktionszeit)=false) then
      RETURN false;

    RunAFX('BAG.Kosten.Save204.Post','DEL');    // 2023-08-01 AH

  end // DEL
  else if (s_BA_Kost_Akt_Todo='MOD') then begin

    if (Mat_Data:Read(s_BA_Kost_Akt_Matnr)<200) then
      RETURN false;
    if (MatRead(s_BA_Kost_Akt_MatNr)=false) then
      RETURN false;

    Erx # RecRead(204,0,_RecId | _RecLock, s_BA_Kost_Akt_RecID);
    if (Erx<>_rOK) then
      RETURN false;

    vKost     # s_BA_Kost_Akt_Kosten - Mat.A.KostenW1;
    vKostPro  # s_BA_Kost_Akt_Kosten - Mat.A.KostenW1ProMEH;
    Mat.A.Materialnr    # s_BA_Kost_Akt_MatNr;
    Mat.A.Aktionsmat    # s_BA_Kost_Akt_MatNr;
    Mat.A.Aktionstyp    # s_BA_Kost_Akt_Typ;
    Mat.A.Aktionsnr     # s_BA_Kost_Akt_Nr;
    Mat.A.Aktionspos    # s_BA_Kost_Akt_Pos;
    Mat.A.Bemerkung     # s_BA_Kost_Akt_Bem;
    Mat.A.Gewicht       # s_BA_Kost_Akt_Gew;
    Mat.A.Menge         # s_BA_Kost_Akt_Menge;
    Mat.A.Aktionsdatum  # s_BA_Kost_Akt_Datum;
    Mat.A.Aktionszeit   # s_BA_Kost_Akt_Zeit;
    Mat.A.Terminstart   # s_BA_Kost_Akt_Start;
    Mat.A.Terminende    # s_BA_Kost_Akt_Ende;
    Mat.A.Adressnr      # s_BA_Kost_Akt_Adr;
    Mat.A.KostenW1      # s_BA_Kost_Akt_Kosten;
    Mat.A.KostenW1ProMEH  # s_BA_Kost_Akt_KostenPro;
    Mat.A.Kostenstelle  # s_BA_Kost_Akt_KST;

    Erx # RekReplace(204);
    if (Erx<>_rOK) then
      RETURN false;
    if (_VererbeKostenDiff(Mat.A.Materialnr, vKost, vKostPro, true, Mat.A.Aktionsdatum, Mat.A.Aktionszeit)=false) then
      RETURN false;

  end // DEL
  else if (s_BA_Kost_Akt_Todo='KOSTEN') then begin

    RecRead(204,0,_RecId | _RecLock, s_BA_Kost_Akt_RecID);
    Mat.A.KostenW1        # Mat.A.KostenW1       + s_BA_Kost_Akt_Kosten;
    Mat.A.KostenW1ProMEH  # Mat.A.KostenW1ProMEH + s_BA_Kost_Akt_KostenPro;
    Erx # RekReplace(204);
    if (Erx<>_rOK) then
      RETURN false;
  end
  else begin
    RETURN false;
  end;

  // 09.03.2022 AH, BFS Kostenänderungen
  RunAFX('BAG.Kosten.Save204.Post',s_BA_Kost_Akt_Todo);

  RETURN true;
end;


//========================================================================
//========================================================================
sub _Save200(
  aMEH    : alpha;
  aDatei  : int) : logic;
local begin
  Erx     : int;
  vDiff   : float;
end;
begin
  if (s_BA_Kost_Mat_Mody) then begin  // wirklich ändern?
    if (aDatei=200) then begin
      RecRead(200, 1, _reclock);

      if (aMEH='kg') then
        vDiff # Rnd((s_BA_Kost_Mat_Kosten * Mat.Bestand.Gew / 1000.0) - (Mat.Kosten * Mat.Bestand.Gew / 1000.0),2)
      else
       vDiff # Rnd((s_BA_Kost_Mat_KostenPro * Mat.Bestand.Menge / 1000.0) - (Mat.KostenProMEH * Mat.Bestand.Menge),2);

      if (gDiffTxt<>0) and (vDiff<>0.0) then
        TextAddLine(gDiffTxt,aint(Mat.Nummer)+'|'+anum(vDiff,2)+'|'+aint(Mat.VK.RechNr));

      Mat.Bewertung.Laut  # s_BA_Kost_Mat_Laut;
      Mat.EK.Preis        # Rnd(s_BA_Kost_Mat_EkPreis,2);
      Mat.EK.PreisProMEH  # Rnd(s_BA_Kost_Mat_EkPreisPro,2);
      Mat.Kosten          # Rnd(s_BA_Kost_Mat_Kosten,2);
      Mat.KostenProMEH    # Rnd(s_BA_Kost_Mat_KostenPro,2)
      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    end
    else begin
      RecRead(210, 1, _reclock);

      if (aMEH='kg') then
        vDiff # Rnd((s_BA_Kost_Mat_Kosten * "Mat~Bestand.Gew" / 1000.0) - ("Mat~Kosten" * "Mat~Bestand.Gew" / 1000.0),2)
      else
       vDiff # Rnd((s_BA_Kost_Mat_KostenPro * "Mat~Bestand.Menge" / 1000.0) - ("Mat~KostenProMEH" * "Mat~Bestand.Menge"),2);
        
      if (gDiffTxt<>0) and (vDiff<>0.0) then
        TextAddLine(gDiffTxt,aint("Mat~Nummer")+'|'+anum(vDiff,2)+'|'+aint("Mat~VK.RechNr"));

      "Mat~Bewertung.Laut"  # s_BA_Kost_Mat_Laut;
      "Mat~EK.Preis"        # s_BA_Kost_Mat_EkPreis;
      "Mat~EK.PreisProMEH"  # s_BA_Kost_Mat_EkPreisPro
      "Mat~Kosten"          # s_BA_Kost_Mat_Kosten;
      "Mat~KostenProMEH"    # s_BA_Kost_Mat_KostenPro;
      Erx # Mat_Abl_Data:ReplaceAblage(_recUnlock,'AUTO');
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
      if (vItem->spCustom='DEL') then begin
        Erx # RecRead(202,0,_RecId, vItem->spID);
        if (Erx<>_rOK) then
          RETURN false;
        Erx # RekDelete(202);
        if (Erx<>_rOK) then
          RETURN false;
      end;
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
sub _ProcessMat(
  aMEH    : alpha;
  aSave   : logic): Logic;
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
      aSave # _Save200(aMEH, vDatei);
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
sub ProcessDict(
  aMEH    : alpha;
  aSave   : logic) : logic;
local begin
  vOK : logic;
end
begin
  vOK # _ProcessMat( aMEH, _ProcessAkt( _ProcessBB(aSave) ) );
  RETURN vOK;
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
    if (MatUse(BAG.IO.Materialnr, false)=false) then begin
      RETURN -BAG.IO.Materialnr;
    end;
  END;

  RETURN 1;
end;


//========================================================================
//========================================================================
sub SumSchrottUndSetEK(
  aMEH              : alpha;
  var aSchrottM     : float;
  var aSchrottWert  : float;
) : logic;
local begin
  Erx   : int;
  vM    : float;
  vWert : float;
end;
begin

  // in Restkarten Lohnkosten eintragen ------------------------------------
  //11.10.2021 if ((BAG.P.Aktion<>c_BAG_Versand) and (BAG.P.Aktion<>c_BAG_Fahr09) and (BAG.P.Aktion<>c_BAG_Umlager)) or
  //   ((Set.BA.LFA.SchrtUmlg) and (BAG.P.Aktion=c_BAG_Fahr09)) then begin
  if (BA1_P_data:DarfKostenHaben()) then begin

    // Input loopen...
    FOR Erx # RecLink(701,702,2,_recFirst)
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.Materialnr=0) then CYCLE;
      if (BAG.IO.Materialtyp=c_IO_BAG) then CYCLE;

      if (MatRead(BAG.IO.MaterialRstNr)=false) then STOP;

      if (BAG.IO.Materialnr<>BAG.IO.MaterialRstNr) then begin     // ist bei echtem Einsatz und NICHT Fahren so
        if (_SetArtEK()=false) then begin
TODOX('DurchschnittsEK nicht setzbar!');
          RETURN false;
        end;
      end;

      if (BAG.P.Aktion=c_BAG_Fahr09) and ("Mat.Löschmarker"='') then CYCLE;

      // 2022-12-08 AH
      if (aMEH='kg') then begin
        vM    # Mat.Bestand.Gew;
        vWert # (vM * Mat.EK.Effektiv / 1000.0);
      end
      else begin
        vM    # Mat.Bestand.Menge;
        vWert # (vM * Mat.EK.EffektivProME);
      end;

@ifdef PROTOKOLL
mydebug('schrott von Karte:'+aint(s_BA_Kost_Mat_Nr)+' GesWert '+anum(vWert,2)+' bei Menge '+anum(vM,2)+'');
@endif

      aSchrottM     # aSchrottM + vM;
      aSchrottWert  # aSchrottwert + vWert;
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
        if (MatRead(BAG.FM.Materialnr)=false) then CYCLE;
        if (BAG.P.Aktion=c_BAG_Fahr09) and ("Mat.Löschmarker"='') then CYCLE;
        
        // ALLE früheren Einträge zurückrechnen 06.05.2020
        FOR   Erx  # RecLink(202,200,12,_RecLast)
        LOOP  Erx  # RecLink(202,200,12,_RecPrev)
        WHILE (Erx <= _rOK) do begin
          Mat.Bestand.Gew   # Mat.Bestand.Gew - Mat.B.Gewicht;
          Mat.Bestand.Menge # Mat.Bestand.Menge - Mat.B.Menge;
        END;

        // 2022-12-08 AH
        if (aMEH='kg') then begin
          vM    # Mat.Bestand.Gew;
          vWert # (vM * Mat.EK.Effektiv / 1000.0);
        end
        else begin
          vM    # Mat.Bestand.Menge;
          vWert # (vM * Mat.EK.EffektivProME);
        end;

@ifdef PROTOKOLL
mydebug('schrott von geplanter Schrottkarte:'+aint(s_BA_Kost_Mat_Nr)+' GesWert '+anum(vWert,2)+' bei Menge '+anum(vM,2)+aMEH);
@endif

        aSchrottM     # aSchrottM + vM;
        aSchrottWert  # aSchrottwert + vWert;
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
  aMEH              : alpha;
  var aStartDat     : date;
  var aStartTim     : time;
  var aBeistellSum  : float;
  var aEinsatzM     : float;
) : logic;
local begin
  Erx   : int;
  vGew  : float;
  vM    : float;
end;
begin

  BAG.P.Kosten.Gesamt   # 0.0;
  BAG.P.Kosten.Ges.Stk  # 0;
  BAG.P.Kosten.Ges.Gew  # 0.0;
  BAG.P.Kosten.Ges.Men  # 0.0;
  BAG.P.Kosten.Ges.MEH  # '';

  // Jüngste Fertigmeldung ermitteln ---------------------------------------
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

      // 07.04.2022 AH WIR NEHMEN IMMER NETTO
      vGew # BAG.IO.Plan.Out.GewN;

      // 2022-09-26 AH  : bei FAHREN BRUTTO
      if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.IO.Plan.Out.GewB<>0.0) then
        vGew # BAG.IO.Plan.Out.GewB;
      if (vGew=0.0) then vGew # Max(BAG.IO.Plan.Out.GewN, BAG.IO.Plan.Out.GewB);

      // Setting: Kompletten Einsatz ------------------------------------
      if (Set.Ba.lohnKost.Wie='K') then begin

        if (BAG.P.Kosten.MEH='m') then begin
          aEinsatzM # aEinsatzM + cnvfi(BAG.IO.Plan.Out.Stk) * "BAG.IO.Länge" / 1000.0;
          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + vGew;
          BAG.P.Kosten.Ges.Stk  # BAG.P.Kosten.Ges.Stk  + BAG.IO.Plan.Out.Stk;
        end;
        if (BAG.P.Kosten.MEH='Stk') then begin
          aEinsatzM # aEinsatzM + cnvfi(BAG.IO.Plan.Out.Stk);
          BAG.P.Kosten.Ges.Stk  # BAG.P.Kosten.Ges.Stk  + BAG.IO.Plan.Out.Stk;
        end;
        if (BAG.P.Kosten.MEH='kg') then begin
          aEinsatzM # aEinsatzM + vGew;
          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + vGew;
        end;
        if (BAG.P.Kosten.MEH='t') then begin
          aEinsatzM # aEinsatzM + (vGew / 1000.0);
          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + vGew;
        end;
      end // Setting: kompletten Einsatz
      // Setting: nur Gutteile ----------------------------------------
      else if (Set.Ba.lohnKost.Wie='G') then begin

        // 07.04.2022 AH WIR NEHMEN IMMER NETTO
        vGew # BAG.FM.Gewicht.Netto;

        // 2022-09-26 AH  : bei FAHREN BRUTTO
        if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.IO.Plan.Out.GewB<>0.0) then
          vGew # BAG.IO.Plan.Out.GewB;
        if (vGew=0.0) then vGew # Max(BAG.IO.Plan.Out.GewN, BAG.IO.Plan.Out.GewB);

        FOR Erx # RecLink(707,701,12,_recFirst) // Verwiegungen loopen
        LOOP Erx # RecLink(707,701,12,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (BAG.FM.Fertigung>900) then CYCLE;
          
          vGew # BAG.FM.Gewicht.Netto;
          
          // 2022-09-26 AH  : bei FAHREN BRUTTO
          if (BAG.P.Aktion=c_BAG_Fahr09) then
            vGew # Max(BAG.FM.Gewicht.Netto, BAG.FM.Gewicht.Brutt);
//          if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.FM.Gewicht.Brutt<>0.0) then
//            vGew # BAG.FM.Gewicht.Netto;
//          if (vGew=0.0) then vGew # Max(BAG.FM.Gewicht.Netto, BAG.FM.Gewicht.Brutt);;

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
            aEinsatzM # aEinsatzM + vGew;
          end
          else if (BAG.P.Kosten.MEH='t') then begin
            aEinsatzM # aEinsatzM + (vGew / 1000.0);
          end;

          BAG.P.Kosten.Ges.Gew  # BAG.P.Kosten.Ges.Gew  + vGew;
          BAG.P.Kosten.Ges.Stk  # BAG.P.Kosten.Ges.Stk  + "BAG.FM.Stück";
        END;
      end;  // Setting: nur Gutteile

@ifdef PROTOKOLL
mydebug('Planin '+ANum(BAG.IO.Plan.In.GewN,0)+'   Istin '+ANum(BAG.IO.Ist.In.GewN,0)+'   PlanOut '+ANum(BAG.IO.Plan.Out.GewN,0)+'   IstOut '+ANum(BAG.IO.Ist.Out.GewN,0));
mydebug('addKarte:'+aint(BAG.IO.Materialnr)+' mit '+anum(vGew,0)+'kg '+anum(vM,2)+aMEH);
@endif

//todo('B:'+anum(bag.p.kosten.ges.gew,0));
    end;  // Material

  END;
end;


//========================================================================
//========================================================================
sub _SummeFMs(
  aMEH              : alpha;
  aKostenSum        : float;
  aBeistellSum      : float;
  var aFertigM      : float;
  var aTraegerM     : float;
//  var aSchrottM     : float;
//  var aSchrottWert  : float;
  var aAnteilKosten : float;
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

      if (aMEH='kg') then begin
  //      // 07.04.2022 AH VWA beachten
        if (BAG.FM.Verwiegungart<>VwA.Nummer) then begin
          Erx # RecLink(818,707,6,_recFirst);
          if (Erx>_rLocked) then VwA.NettoYN # y;
        end;
        if (VwA.NettoYN) then begin
          if ("BAG.F.KostenträgerYN") then
            aTraegerM # aTraegerM + BAG.FM.Gewicht.Netto;
          aFertigM # aFertigM + BAG.FM.Gewicht.Netto;
        end
        else begin
          if ("BAG.F.KostenträgerYN") then
            aTraegerM # aTraegerM + Max(BAG.FM.Gewicht.Brutt, BAG.FM.Gewicht.Netto);
          aFertigM # aFertigM + Max(BAG.FM.Gewicht.Brutt, BAG.FM.Gewicht.Netto);
        end;
      end
      else begin
        if ("BAG.F.KostenträgerYN") then
          aTraegerM # aTraegerM + BAG.FM.Menge;
        aFertigM # aFertigM + BAG.FM.Menge;
      end;
    END;
  END;

  if (aTraegerM<>0.0) then
    aAnteilKosten   # Rnd(aKostenSum*1000.0 / aTraegerM,2);

  if (aTraegerM<>0.0) then
    aAnteilKosten # aAnteilKosten + Rnd(aBeistellSum*1000.0 / aTraegerM,2);

  // ST 2009-08-14  Projekt 1161/95
  if (aTraegerM <= 0.0) AND (aAnteilKosten > 0.0) then begin
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
  if (KillAllAbwertungen(c_Akt_BA_UmlageMINUS, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllMatAktionen(c_Akt_BA_Kosten, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllMatAktionen(c_Akt_BA_UmlagePLUS, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllMatAktionen(c_Akt_BA_UmlageMINUS, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  if (KillAllMatAktionen(c_Akt_BA_Beistell, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  // 2022-08-29 AH
  if (KillAllMatAktionen(c_Akt_BA_Schrott, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  // 12.02.2021 AH: geplante Verschrottungen auch löschen
  if (KillAllAbwertungen(c_Akt_BA_Schrott, BAG.P.Nummer, BAG.P.Position, 0)<>true) then
    RETURN false;

  RETURN true;
end;


//========================================================================
//========================================================================
sub _NulleSchrottFMs(
  aAdr          : int;
  aMEH          : alpha;
  ) : logic;
local begin
  Erx     : int;
  vPreis  : float;
  vBasis  : float;
  vBproM  : float;
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

      if (MatRead(BAG.FM.MaterialNr)=false) then
        RETURN false;

      //if (cVerschrotteBasis=false) then begin  NUR PER AKTIONEN !!!
        vPreis  # -1.0 * (s_BA_Kost_Mat_EkPreis + s_BA_Kost_Mat_Kosten);
      //end
      //else begin
      //  vPreis  # -1.0 * s_BA_Kost_Mat_Kosten;
      //  vBasis  # -1.0 * s_BA_Kost_Mat_EKPreis;
      //  vBproM  # -1.0 * s_BA_Kost_Mat_EKPreisPro;
      //end;
      if (vPreis<>0.0) or (vBasis<>0.0) then begin
        Mat.A.Bemerkung # c_AktBem_BA_Nullung+':';
        if (RunAFX('BAG.FM.Set.MatABemerkung','')=0) then
          Mat.A.Bemerkung # Mat.A.Bemerkung + BAG.P.Aktion2;
        // Schrott bei WIEGUNG
//        if (NeueAktion(BAG.P.Position, s_BA_Kost_Mat_Nr, c_Akt_BA_UmlageMINUS, Mat.A.Bemerkung, vPreis, vBasis, vBproM, aAdr, BAG.FM.Datum, BAG.FM.Zeit)=false) then begin
//        if (NeueAktion(BAG.P.Position, s_BA_Kost_Mat_Nr, 'BA-PS', Mat.A.Bemerkung, vPreis, vBasis, vBproM, aAdr, BAG.FM.Datum, BAG.FM.Zeit)=false) then begin
// 12.02.2021
        if (NeueAktion(BAG.P.Position, s_BA_Kost_Mat_Nr, c_Akt_BA_Schrott, Mat.A.Bemerkung, vPreis, vBasis, vBproM, aAdr, 0.0, aMEH, BAG.FM.Datum, BAG.FM.Zeit)=false) then begin
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
  aMEH          : alpha;
) : logic;
local begin
  Erx     : int;
  vPreis  : float;
  vBasis  : float;
  vBProM  : float;
end;
begin

  // Restkarten "nullen" -------------------------------------------------
  FOR Erx # RecLink(701,702,2,_recFirst)            // Input loopen
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.Materialtyp=c_IO_Mat) then begin     // Material??
      //if (Mat_Data:Read(BAG.IO.MaterialRstNr)=falsE) then
      if (MatRead(BAG.IO.MaterialRstNr)=false) then
        RETURN false;

      if (BAG.P.Aktion=c_BAG_Fahr09) and (s_BA_Kost_Mat_Loeschmark='') then CYCLE;

      if (aMEH='kg') then
        vPreis # -1.0 * (Mat.EK.Preis + Mat.Kosten)
      else
        vPreis # -1.0 * (Mat.EK.EffektivProME + Mat.KostenProMEH);

      if (vPreis<>0.0) or (vBasis<>0.0) then begin
        Mat.A.Bemerkung # c_AktBem_BA_Nullung+':';
        if (RunAFX('BAG.FM.Set.MatABemerkung','')=0) then
          Mat.A.Bemerkung # Mat.A.Bemerkung + BAG.P.Aktion2;
        // Schrott bei ABSCHLUSS
        if (NeueAktion(BAG.P.Position, BAG.IO.MaterialRstNr, c_Akt_BA_UmlageMINUS, Mat.A.Bemerkung, vPreis, vBasis, vBproM, aAdr, 0.0, aMEH, gAbschlussAm, gAbschlussUm)=false) then begin
          RETURN false;
        end;
      end;
    end;
  END;

  RETURN true;
end;


/*========================================================================
2023-02-06  AH
========================================================================*/
sub OhneKostenLogik(aPara : alpha(4000)) : int
begin
  AfxRes # _rOK;
  RETURN 1;
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
  vEinsatzM     : float;
  vFertigM      : float;
  vTraegerM     : float;
  vSchrottWert  : float;
  vSchrottM     : float;

  vAdr          : int;
  vBuf100       : int;

  vDia          : int;
  vMsg          : int;

  vMDI          : int;
  vPara         : alpha;

  vAnteilSchrott  : float;
  vAnteilKosten   : float;
  vAnteilBeistell : float;
  vMEH          : alpha;
end;
begin
  GV.Int.01 # 0;
  GV.Alpha.99 # '';
  gDiffTxt # aDiffTxt;

  // Settings prüfen
  if (Set.Ba.lohnKost.Wie<>'G') and (Set.Ba.lohnKost.Wie<>'K') then STOP;

  // Ankerfunktion starten
  if (aSilent) then
    vPara # aint(aBAG)+'|'+aint(aPos)+'|Y'
  else
    vPara # aint(aBAG)+'|'+aint(aPos)+'|N';
  if (aNoProto) then
    vPara # vPara + '|Y'
  else
    vPara # vPara + '|N';
  if (aRecalc) then
    vPara # vPara + '|Y'
  else
    vPara # vPara + '|N';
  vPara # vPara + '|'+aint(aDiffTxt);
  if (aNoTrans) then
    vPara # vPara + '|Y'
  else
    vPara # vPara + '|N';
  if (RunAFX('BAG.Kosten',vPara)<>0) then begin
    RETURN (AfxRes=_rOK);
  end;

  if (_CheckBaPos(aBAG, aPos)=false) then
    STOP;

  gAbschlussAm  # BAG.P.Fertig.Dat;
  gAbschlussUm  # BAG.P.Fertig.Zeit;
//debugx('------------------------ KEY702 '+cnvad(gAbschlussam)+' '+atime(gAbschlussUm));
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
        RecRead(702,1,_recLock);
        BAG.P.Kosten.Fix # vX;
        RekReplace(702);
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

  vMEH # 'kg';
//vMEH # 'm';
  if (Set.Installname='HWN') then begin
//debugx('HACK!');
    vMEH # '';
    // Input loopen
    FOR Erx # RecLink(701,702,2,_recFirst)
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (vMEH='') then vMEH # BAG.IO.MEH.In;
      if (vMEH<>BAG.IO.MEH.In) then begin   // Kraut und Rüben im Einsatz?
        vMEH # 'kg';
        BREAK;
      end;
    END;
    if (vMeh='') then vMeh # 'kg';
  end;
//debugX(vMEH)
  APPOFF();   // 16.10.2019

@ifdef PROTOKOLL
mydebug('POS '+aint(bag.p.position)+' -----------------------------------------------------------');
@endif

  _SummePosKosten(vMEH, var gStartDat, var gStartTim, var vBeistellSum, var vEinsatzM);

  vKostenSum # BAG.P.Kosten.Fix;
  if (BAG.P.Kosten.PEH<>0) then
    vKostenSum # vKostenSum + (BAG.P.Kosten.pro * vEinsatzM / cnvfi(BAG.P.Kosten.PEH));

  RecRead(702,1,_recLock | _recNoLoad);         // Position sperren
  BAG.P.Kosten.Gesamt # vKostenSum;
  Erx # RekReplace(702);                        // Position speichern
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
    ProcessDict(vMEH, false);
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    Error(702027,aint(-vMsg));
    STOP;
  end;

  // needs MAT
  if (_SummeFMs(vMEH, vKostenSum, vBeistellSum, var vFertigM, var vTraegerM, var vAnteilKosten)=false) then begin
    ProcessDict(vMEH, false);
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    STOP;
  end;


@ifdef PROTOKOLL
mydebug('killen...');
@endif

  // bisherige Aktionen/BB löschen -------------------------------------
  if (_KillAktUndBB()=false) then begin
    ProcessDict(vMEH, false);
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextClose(vProtokoll);
    STOP;
  end;

@ifdef PROTOKOLL
mydebug('...killen');
@endif


  if (SumSchrottUndSetEK(vMEH, var vSchrottM, var vSchrottWert)=false) then begin
    ProcessDict(vMEH, false);
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextClose(vProtokoll);
    STOP;
  end;


@ifdef PROTOKOLL
mydebug('Einsatz:'+anum(vEinsatzM,2)+vMEH);
mydebug('traegerMenge:'+anum(vtraegerM,2)+vMEH+'   schrott:'+anum(vSchrottM,2)+vMEH);
mydebug('geskost:'+anum(vKostensum,2) + '    anteil:'+anum(vAnteilKosten,2));
@endif

  if (vTraegerM<>0.0) then begin
    if (vMEH='kg') then
      vAnteilSchrott  # Rnd(vSchrottwert*1000.0 / vTraegerM,2)
    else
      vAnteilSchrott  # Rnd(vSchrottwert / vTraegerM,2);
  end;

  if (aNoTrans=false) then TRANSON;

  // BA-Position ist noch offen?? -> dann keine Kosten eintragen = ENDE !!!!!!!!!!!!!
  if ("BAG.P.Löschmarker"='') then begin

    if (ProcessDict(vMEH, true)=false) then begin
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
mydebug('Schrott:'+anum(vSchrottM,2)+vMEH+'   schrottwert:'+anum(vschrottwert,2)+'  Umlageteil:'+anum(vAnteilSchrott,2));
@endif

  // neue Kostenaktionen anlegen -------------------------------------------
  if (vTraegerM<>0.0) then begin
@ifdef PROTOKOLL
mydebug('umlegen...');
@endif
    Mat.A.Bemerkung # '';
    if (RunAFX('BAG.FM.Set.MatABemerkung','')=0) then
      Mat.A.Bemerkung # BAG.P.Aktion2;
    if (Pos2Fert(BAG.P.Position, Mat.A.Bemerkung, vAdr, vAnteilSchrott, vAnteilKosten, vTraegerM, vSchrottM, vMEH)=false) then begin
      if (aNoTrans=false) then TRANSBRK;
      ProcessDict(vMEH, false);
      MyWinClose(vDia);
      ErrorOutput;
      if (vProtokoll<>0) then TextCLose(vProtokoll);
      STOP;
    end;
@ifdef PROTOKOLL
mydebug('...umlegen...');
@endif


    // Schrottnullungen ========================================================
// 11.10.2021   if ((BAG.P.Aktion<>c_BAG_Versand) and (BAG.P.Aktion<>c_BAG_Fahr09) and (BAG.P.Aktion<>c_BAG_Umlager)) or
//     ((Set.BA.LFA.SchrtUmlg) and (BAG.P.Aktion=c_BAG_Fahr09)) then begin
    if (BA1_P_data:DarfKostenHaben()) then begin

      if (_NulleSchrottFMs(vAdr, vMEH)=false) then begin
        if (aNoTrans=false) then TRANSBRK;
        MyWinClose(vDia);
        ErrorOutput;
        if (vProtokoll<>0) then TextCLose(vProtokoll);
        STOP;
      end;

      if (_NulleReste(vAdr, vMEH)=false) then begin
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

  if (ProcessDict(vMEH, true)=false) then begin
    if (aNoTrans=false) then TRANSBRK;
    MyWinClose(vDia);
    if (vProtokoll<>0) then TextCLose(vProtokoll);
    STOP;
  end;

  if (RunAFX('BAG.Kosten.Post',vPara)<>0) then begin  // 23.11.2020
    if (AfxRes<>_rOK) then begin
      if (aNoTrans=false) then TRANSBRK;
      MyWinClose(vDia);
      ErrorOutput;
      if (vProtokoll<>0) then TextCLose(vProtokoll);
      STOP;
    end;
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