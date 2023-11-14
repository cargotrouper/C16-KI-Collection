@A+
//===== Business-Control =================================================
//
//  Prozedur  BA1_Lohn_Subs
//              ohne E_R_G
//  Info
//
//
//  20.05.2010  AI  Erstellung der Prozedur
//  25.06.2012  AI  NEU:: "Erzeuge701" übernimmt nun auch Artikelnr
//  30.07.2012  AI  Erweiterung "Erzeuge701" fürs Fahren
//  19.10.2012  AI  ErzeugeBAmitMat
//  04.06.2013  AI  ErzeugeBA nimmt Reservierungen
//  14.05.2014  AH  "VerwalteBetriebsauftrag" nicht immer nur für 1. Auf.Position
//  14.08.2014  AH  BugFix "ErzeugeBA"
//  18.08.2014  AH  "VerwalteBetreibsauftrag" legt nicht in gelöschten Ba-Kopf neue Positionen an
//  05.08.2015  ST  AFX 'BA1.LohnSubs.BAGVorlageDaten' hinzugefügt
//  05.11.2015  AH  "ErzeugeBAausVorlage" kann auch "#" in BAG.P.Position
//  20.01.2016  AH  BAG.P.Texte kopieren aus Vorlage
//  16.03.2016  AH  Neu: Feld "BAG.P.Status"
//  20.06.2016  AH  Bug: "ErzeugeBAausVorlage" kopiert auch Ausführungen
//  19.07.2016  AH  Bug: "ErzeugeBAausVorlage" kopiert auch Verpackungen
//  24.11.2016  AH  Neu: LohnBAG kann auch Mat der Auftragsreservierungen absplitten
//  04.04.2017  ST  Neu: AFX "BA1.LohnSubs.ErzeugeBaMitMat.Post" hinzugefügt
//  16.08.2018  AH  Neu: zu gelöschten AufPos. keine BA-Neuanlage
//  14.11.2018  AH  Edit: "ErzeugeBAausVorlage" kann spezielles Gewicht übergeben werden
//  21.01.2019  AH  Bug: "ErzeugeBAausVorlage" rechnet jett Autoteilung
//  15.07.2020  AH  Edit: "ErzeugeBAausVorlage" kann auch mit Offset (d.h. in vorhandenen BA einfügen)
//  24.08.2021  AH  ERX, Erzeuge702 legt auch Walz-Fertigung an
//  13.09.2021  ST  HFX BSC SFX_ESK_Cut:CopyEskToBag(...); Projekt 2298/17
//  2022-12-19  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//
//  SUB HoleBAPoszuAuf() : logic;
//  SUB Erzeuge700() : logic;
//  SUB Erzeuge701(aMitRes : logic) : logic;
//  SUB Erzeuge702() : logic;
//  SUB ErzeugeBA(aMitRes : logic) : logic;
//  SUB ErzeugeBAmitMat(aMatID : int) : logic;
//  SUB EinsatzMaterial(aMatNr: int) : logic;
//  SUB VerwalteEinsatz(aAufNr : int; aAufPos : int;opt aSilent : logic;) : logic;
//  SUB VerwalteFertigung(aAufNr : int; aAufPos : int; opt aSilent : logic) : logic;
//  SUB BAschonverwogen(aBAG : int) : logic;
//  SUB DeleteAutoVSB(aBAG : int; aPos: int) : logic
//  SUB DeleteVSBzuInput() : logic
//  SUB AutoVSB(aBAG : int  ) : logic
//  SUB VerwalteBetriebsauftrag(aAufNr : int; aAufPos : int) : logic;
//  SUB ErzeugeBAausVorlage(aVorlage : int; aAufNr : int; aAufPos : int) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_aktionen
@I:Def_BAG

declare VerwalteBetriebsauftrag( aAufNr  : int;  aAufPos : int;) : logic;

//========================================================================
//  HoleBAPoszuAuf
//
//========================================================================
sub HoleBAPoszuAuf(
  var aBAnr   : int;
  var aBaPos  : int) : int;
local begin
  Erx     : int;
  vCount  : int;
end;
begin
  aBaNr  # 0;
  aBaPos # 0;

  FOR Erx # RecLink(404,400,15,_RecFirst) // AufAktionen loopen
  LOOP Erx # RecLink(404,400,15,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.A.Aktionstyp<>c_Akt_BA) or ("Auf.A.Löschmarker" = '*') then
      CYCLE;

    BAG.P.Nummer    # Auf.A.Aktionsnr;
    BAG.P.Position  # Auf.A.Aktionspos;
    if (RecRead(702,1,0) <> _rOK) then
      CYCLE;

    if (BAG.P.Auftragsnr = Auf.P.Nummer) AND
       (BAG.P.AuftragsPos = Auf.P.Position) then begin
      // BA Position zur Auftragsposition gefunden !!!
      aBaNr  # BAG.P.Nummer;
      aBaPos # BAG.P.Position;
      vCount # vCount + 1;
    end;
  END;

  // Fehlerfall
  if (vCount=0) then
    RETURN 0;

  if (aBaPos <> 0) then begin
    // BA Pos vorhanden
    BAG.P.Nummer    # aBAnr;
    BAG.P.Position  # aBaPos;
    Erx # RecRead(702,1,0);
    if (Erx>_rLocked) then RETURN -1
    RETURN vCount;
  end;

  RETURN vCount;
end;


//========================================================================
//  Erzeuge700
//
//========================================================================
sub Erzeuge700() : logic;
local begin
  Erx : int;
end;
begin

  TRANSON;

  RecBufClear(700);
  BAG.Nummer # Lib_Nummern:ReadNummer('Betriebsauftrag');
  if (BAG.Nummer<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RETURN false;
  end;

  BAG.BuchungsAlgoNr  # Set.BA.BuchungAlgoNr;
  BAG.Bemerkung     # Translate('Lohnauftrag')+' '+aint(Auf.P.Nummer);
  BAG.Anlage.Datum  # Today;
  BAG.Anlage.Zeit   # Now;
  BAG.Anlage.User   # gUserName;
  Erx # RekInsert(700,0,'MAN');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    RETURN False;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  Erzeuge701
//
//========================================================================
sub Erzeuge701(
  aMitRes   : logic;
  aMitSplit : logic;
  ) : logic;
local begin
  vMenge    : float;
  vFreiKG   : float;
  vResKG    : float;
  vResStk   : int;
  vErr      : alpha(100);
  vNetto    : float;
  vBrutto   : float;
  vM        : float;
  vNeuesMat : int;
  Erx       : int;
end;
begin

  if (aMitRes) then begin

    FOR Erx # RekLink(203, 401, 18,_recFirst) // Reseriverungen loopen
    LOOP Erx # RekLink(203, 401, 18,_recFirst)
    WHILE (Erx<=_rLocked) and (vErr='') do begin

      Erx # RecLink(200,203,1,_RecFirst);    // Material holen
      if (Erx<>_rOK) then begin
        vErr # 'Reservierungs-Fehler!';
        BREAK;
      end;

      vFreiKG # Mat.Bestand.Gew - Mat.R.Gewicht;
      vResKG  # Mat.R.Gewicht;
      vResStk # "MAt.R.Stückzahl";
      if (Mat_Rsv_Data:Entfernen()=false) then begin
        vErr # 'Reservierungs-Fehler!';
        BREAK;
      end;

// 21.11.2016
if (aMitSplit) then begin
  // neues Einsatzmaterial bei Teilentnahme
  if (vResKG < Mat.Bestand.Gew) then begin
    // Dreisatz!
    vNetto  # Rnd(Lib_Berechnungen:Dreisatz(Mat.Gewicht.Netto, Mat.Bestand.Gew, vResKG), Set.Stellen.Gewicht);
    vBrutto # Rnd(Lib_Berechnungen:Dreisatz(Mat.Gewicht.Brutto, Mat.Bestand.Gew, vResKG), Set.Stellen.Gewicht);
    vM      # Rnd(Lib_Berechnungen:Dreisatz(Mat.Bestand.Menge, Mat.Bestand.Gew, vResKG), Set.Stellen.Menge);
    if (Mat_Data:Splitten(vResStk, vNetto, vBrutto, vM, today, now, var vNeuesMat)=false) then begin
      vErr # 'Reservierungs-Split-Fehler!';
      BREAK;
    end;
    Mat.Nummer # vNeuesMat;
    Erx # RecRead(200,1,0);
    if (Erx<>_rOK) then begin
      vErr # 'Reservierungs-Split-Fehler!';
      BREAK;
    end;
  end;
end;
  /*      if (vFreiKG>0.0) then begin
        Mat_Data:Splitten(vResStk, vResKG, vResKG, var vNeuesMat);
        Mat.Nummer # vNeuesMat;
        Erx # RecRead(200,1,0);
        vFreiKG # 0.0;
      end;
  */
      if (BA1_IO_Data:EinsatzRein(BAG.P.Nummer, BAG.P.Position, Mat.Nummer)=false) then begin
        vErr # 'Einsatmaterial-Fehler 2001';
        BREAK;
      end;

    END;

    RETURN true;
  end;

  // sonst: theretisches Mat anlegen...
  RecBufClear(701);
  BAG.IO.Anlage.Datum # today;
  BAG.IO.Anlage.Zeit  # now;
  BAG.IO.Anlage.User  # gUsername;
  BAG.IO.Nummer         # BAG.P.Nummer;
  BAG.IO.ID             # 1;
  BAG.IO.NachBAG        # BAG.P.Nummer;
  BAG.IO.NachPosition   # BAG.P.Position;
  BAG.IO.Materialtyp    # c_IO_Theo;
  BAG.IO.Bemerkung      # Translate('AUTOMATISCH');
  BAG.IO.Lageradresse   # Set.EigeneAdressnr;
  BAG.IO.Lageranschr    # 1;
  BAG.IO.MEH.Out        # 'kg';//2022-12-19 AH BA1_P_Data:ErmittleMEH();
  BAG.IO.MEH.In         # 'kg';//2022-12-19 AH BAG.IO.MEH.Out;

  BAG.IO.Warengruppe    # Auf.P.Warengruppe;
  BAG.IO.Artikelnr      # Auf.P.Artikelnr;
  "BAG.IO.Güte"         # "Auf.P.Güte";
  "BAG.IO.Gütenstufe"   # "Auf.P.Gütenstufe";
  BAG.IO.Dicke          # Auf.P.Dicke;
  BAG.IO.Breite         # Auf.P.Breite;
  "BAG.IO.Länge"        # "Auf.P.Länge";
  BAG.IO.Dickentol      # Auf.P.Dickentol;
  BAG.IO.Breitentol     # Auf.P.Breitentol;
  "BAG.IO.Längentol"    # "Auf.P.Längentol";
  BAG.IO.AutoTeilungYN  # y;

  BAG.IO.AutoTeilungYN  # y;

  // 30.07.2012 AI
  if (BAG.P.ZielVerkaufYN) then begin
    BAG.IO.Auftragsnr     # Auf.P.Nummer;
    BAG.IO.AuftragsPos    # Auf.P.Position;
    BAG.IO.AuftragsFert   # 0;
  end;

  if ("Auf.P.Stückzahl" = 0) then
    "Auf.P.Stückzahl" # 1;
  BAG.IO.Plan.In.Stk    # "Auf.P.Stückzahl";
  BAG.IO.Plan.In.GewN   # Auf.P.Gewicht;
  BAG.IO.Plan.In.GewB   # Auf.P.Gewicht;
  vMenge # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.IN.Stk, BAG.IO.Plan.IN.GewN, BAG.IO.PLan.In.GewN, 'kg', BAG.IO.MEH.In);
  BAG.IO.Plan.In.Menge # Rnd(vMenge, Set.Stellen.Menge);
  BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
  vMenge # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.OUT.GewN, BAG.IO.PLan.OUT.GewN, 'kg', BAG.IO.MEH.Out);
  BAG.IO.Plan.Out.Meng # Rnd(vMenge, Set.Stellen.Menge);

  REPEAT
    BAG.IO.UrsprungsID    # BAG.IO.ID;
    // 30.07.2012 AI
    // damit auch bei VERKAUF die Fertigung anlegen
    if (BAG.P.Aktion<>c_BAG_Fahr) then begin
      Erx # RekInsert(701,0,'AUTO');
      if (Erx=_rOK) then begin
        Rso_Rsv_Data:Insert701();
      end;
    end
    else
      Erx # BA1_IO_Data:Insert(0,'AUTO');
    if (Erx<>_rOK) then BAG.IO.ID # BAG.IO.ID + 1;
  UNTIL (Erx=_rOK);


  if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
//      TRANSBRK;
//      ErrorOutput;
    RETURN false;
  end;


  RETURN true; // alles IO

end;


//========================================================================
//  Erzeuge702
//
//========================================================================
sub Erzeuge702(opt vPos : int) : logic;
local begin
  Erx : int;
end;
begin

  // Sonderfunktion für abweichende Materialselektion
  if (RunAFX('BA1.LohnSubs.Erzeuge702',Aint(vPos)) <> 0) then begin
    if (AfxRes <> _rOK) then
      RETURN false
    else
      RETURN true;
  end;


  Erx # RecLink(835,401,5,_RecFirst);     // Auftragsart holen
  if (Erx>_rlocked) then RecBufClear(819);

  if (vPos = 0) then
    vPos # Auf.P.Position;

  vPos # RecLinkInfo(702,700,1,_RecCount) + 1; // letze Position ermitteln

  TRANSON;

  RecBufClear(702);
  BAG.P.Nummer            # BAG.Nummer;
  BAG.P.Position          # vPos;
  BAG.P.Aktion2           # AAr.Lohn.Aktion;
  BAG.P.ExternYN          # n;
  BAG.P.Auftragsnr        # Auf.P.Nummer;
  BAG.P.Auftragspos       # Auf.P.Position;
  BAG.P.Kommission        # aint(BAG.P.Auftragsnr)+'/'+aint(BAG.P.Auftragspos);
  BAG.P.Ressource.Grp     # AAr.Lohn.Res.Gruppe;
  BAG.P.Ressource         # AAr.Lohn.Ressource;
  BAG.P.Reihenfolge       # BAG.P.Position;
  BAG.P.Kosten.Wae        # 1;
  BAG.P.Kosten.PEH        # 1000;
  BAG.P.Kosten.MEH        # 'kg';

  Erx # RecLink(828,702,8,_recFirst);   // Arbeitsgang holen
  if (Erx>_rLocked) then begin
    TRANSBRK;
    RETURN false;
  end;
  BAG.P.Aktion            # ArG.Aktion;
  BAG.P.Aktion2           # ArG.Aktion2;
  "BAG.P.Typ.1In-1OutYN"  # "ArG.Typ.1In-1OutYN";
  "BAG.P.Typ.1In-yOutYN"  # "ArG.Typ.1In-yOutYN";
  "BAG.P.Typ.xIn-yOutYN"  # "ArG.Typ.xIn-yOutYN";
  "BAG.P.Typ.VSBYN"       # "ArG.Typ.VSBYN";
  BAG.P.Bezeichnung       # ArG.Bezeichnung

  if (BAG.P.Status='') and ("BAG.P.Löschmarker"='') then
    BA1_Data:SetStatus(c_BagStatus_Offen);
  if ("BAG.P.Löschmarker"<>'') then
    BA1_Data:SetStatus(c_BagStatus_Fertig);

  Erx # BA1_P_Data:Insert(0,'MAN');
  if (Erx=_rOK) and
      (BAG.P.Aktion=c_BAG_Walz) then begin // autom. 1. Fertigung anlegen

    RecBufClear(703);
    BAG.F.Nummer            # BAG.P.Nummer;
    BAG.F.Position          # BAG.P.Position;
    BAG.F.Fertigung         # 1;
    BAG.F.AutomatischYN     # y;
    "BAG.F.KostenträgerYN"  # y;
    BAG.F.MEH               # 'kg';

    Erx # RecLink(828,702,8,0); // Arbeitsgang holen    18.08.2015
// 2022-12-19 AH   if (ArG.MEH<>'') then BAG.F.MEH # ArG.MEH;
    if ("BAG.P.Typ.xIn-yOutYN"=false) then begin
      BAG.F.MEH # '';
    end
    else begin
      if (ArG.MEH<>'') then BAG.F.MEH # ArG.MEH;
    end;

    BAG.F.Streifenanzahl    # 1;
    BAG.F.Artikelnummer     # ''
    BAG.F.Menge             # 0.0;
    Erx # BA1_F_Data:Insert(0,'AUTO');
  end;

  TRANSOFF;
  RETURN true;
end;


//========================================================================
//  ErzeugeBA
//
//========================================================================
sub ErzeugeBA(
  aMitRes   : logic;
  aMitSplit : logic;
  opt aBAGNr    : int) : logic;
local begin
  Erx     : int;
  vFirst  : logic;
  vMitRes : float;
end;
begin

  TRANSON;

  if (aBAGNr=0) then begin
    if (Erzeuge700()=false) then begin
      TRANSBRK;
      ERROROUTPUT;
      RETURN false;
    end;
  end
  else begin
    BAG.Nummer  # aBAGNr;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;
  end;

  if (Erzeuge702()=false) then begin
    TRANSBRK;
    ERROROUTPUT;
    RETURN false;
  end;

  if (Erzeuge701(aMitRes, aMitSplit)=false) then begin
    TRANSBRK;
    ERROROUTPUT;
    RETURN false;
  end;

  TRANSOFF;
  RETURN true;
end;



//========================================================================
//  ErzeugeBAmitMat
//
//========================================================================
Sub ErzeugeBAmitMat(
  aMatID : int;
) : logic;
local begin
  Erx     : int;
  v200  : int;
  vMat  : int;
end;
begin

  Erx # RecLink(835, 401, 5, _recFirst);     // Auftragsart holen
  if (Erx>_rlocked) then RecBufClear(819);
  if (AAr.Berechnungsart >= 700) and (AAr.Berechnungsart <= 799) then begin
    end
  else begin
    RETURN true;
  end;


  v200 # RecBufCreate(200);
  Erx # RecRead(v200,0,_recId, aMatID);
  if (Erx<=_rLocked) then
    vMat # v200->Mat.Nummer;
  RecBufDestroy(v200);
  if (vMat<>0) then begin
    TRANSON;

    if (BA1_Lohn_Subs:Erzeuge700()=false) then begin
      TRANSBRK;
      RETURN false;
    end;

    if (BA1_Lohn_Subs:Erzeuge702()=false) then begin
      TRANSBRK;
      RETURN false;
    end;

    if (BA1_Lohn_Subs:EinsatzMaterial(vMat)=false) then begin
      TRANSBRK;
      RETURN false;
    end;

    TRANSOFF;

    if (RunAFX('BA1.LohnSubs.ErzeugeBaMitMat.Post',Aint(Bag.P.Nummer) + '/' + Aint(Bag.P.Position)) <> 0) then begin
      if (AfxRes <> _rOK) then
        RETURN false;
    end;

    BA1_Lohn_Subs:VerwalteFertigung(Auf.P.Nummer, Auf.P.Position, true);
  
  end;

end;


//========================================================================
//  ErzeugeBA POS
//
//========================================================================
sub ErzeugeBAPos(aBA : int) : logic;
local begin
  vFirst  : logic;
  vPos : int;
end;
begin

  TRANSON;

  // BA Kopfdaten nur bei Bedarf anlegen
  if (aBA = 0) then begin
    if (Erzeuge700()=false) then begin
      TRANSBRK;
      RETURN false;
    end;
  end
  else begin
    Bag.Nummer # aBA;
    RecRead(700,1,0);
  end;

  // Position anlegen
  if (Erzeuge702()=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  // Einsätze verdrahten
  if (Erzeuge701(false, false)=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;
  RETURN true;
end;


//========================================================================
//  EinsatzMaterial
//
//========================================================================
sub EinsatzMaterial(
  aMatNr  : int;
) : logic;
local begin
  Erx           : int;
  vOK           : logic;
  vBuf100       : int;
  vKGMM_Kaputt  : logic;
end;
begin

  // Ankerfunktion: ST 2011-01-19
  // Sonderfunktion für abweichende Materialselektion
  if (RunAFX('BA1.LohnSubs.EinsatzMaterial',AInt(aMatNr)) <> 0) then begin
    if (AfxRes <> _rOK) then
      RETURN false
    else
      RETURN true;
  end;

  Mat.Nummer # aMatNr;
  Erx # RecRead(200,1,0);   // Material holen
  if (Erx>_rLocked) then begin
    Msg(001201,Translate('Material'),0,0,0);
    RETURN false;
  end;
  vOK # ("Mat.Löschmarker"='');
  vOK # vOK and ( (Mat.Status<=c_Status_bisFrei) or
   ((Mat.Status>=c_Status_Sonder) and (Mat.Status<=c_Status_bisSonder)) );
  if (vOK=false) then begin
    Msg(441002,'',0,0,0);
    RETURN false;
  end;

  if ("Mat.EigenmaterialYN") then vOK # n;
  if (vOK) then begin
    if (BAG.P.Auftragsnr<>0) then begin
      Erx # RecLink(401,702, 16, _recFirsT);      // AufPos holen
      if (Erx<>_rOK) then vOK # n;
    end;
    if (vOK) then begin
      Erx # RecLink(100,401,4,_RecFirst);         // Kunde holen
      if (Erx<>_rOK) then vOK # n;
      if (vOK) then begin
        vBuf100 # RecBufCreate(100);
        Erx # RecLink(vBuf100, 200, 4, _recFirst);  // Lieferant holen
        if (Erx<>_ROK) or (vBuf100->Adr.Nummer<>Adr.Nummer) then vOK # n;
        RecBufDestroy(vBuf100);
      end;
    end;
  end;
  if (vOK=false) then begin
    Msg(701027,'!',0,0,0);
    RETURN false;
  end;


  // Feldübernahme
  RecbufClear(701);
  BAG.IO.Nummer         # BAG.P.Nummer;
  BAG.IO.NachBAG        # BAG.P.Nummer;
  BAG.IO.NachPosition   # BAG.P.Position;
  BAG.IO.AutoTeilungYN  # Set.BA.AutoteilungYN;
  BAG.IO.MEH.Out        # Mat.MEH;  // 2022-12-19 AH BA1_P_Data:ErmittleMEH();
  BAG.IO.MEH.In         # BAG.IO.MEH.Out;
  BAG.IO.Materialtyp    # c_IO_Mat;
  BAG.IO.Materialnr     # Mat.Nummer;
  BAG.IO.Artikelnr      # Mat.Strukturnr;
  BAG.IO.Dicke          # Mat.Dicke;
  BAG.IO.Breite         # Mat.Breite;
  BAG.IO.Spulbreite     # Mat.Spulbreite;
  "BAG.IO.Länge"        # "Mat.Länge";
  BAG.IO.Dickentol      # Mat.Dickentol;
  BAG.IO.Breitentol     # Mat.Breitentol;
  "BAG.IO.Längentol"    # "Mat.Längentol";
  BAG.IO.AusfOben       # "Mat.AusführungOben";
  BAG.IO.AusfUnten      # "Mat.AusführungUnten";
  "BAG.IO.Güte"         # "Mat.Güte";
  "BAG.IO.GütenStufe"   # "Mat.GütenStufe";
  BAG.IO.Plan.In.Stk    # Mat.Bestand.Stk;
  BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;
  BAG.IO.Plan.In.GewB   # Mat.Gewicht.Brutto;
  if (BAG.IO.Plan.In.GewN=0.0) then BAG.IO.Plan.In.GewN # Mat.Bestand.Gew;
  if (BAG.IO.Plan.In.GewB=0.0) then BAG.IO.Plan.In.GewB # Mat.Bestand.Gew;
  if (BAG.IO.MEH.Out='qm') then begin
    "BAG.IO.Länge"  # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Stk, BAG.IO.Dicke, BAG.IO.Breite, Mat.Dichte, "Wgr.TränenKgProQM");
    BAG.IO.Plan.In.Menge  # Rnd( cnvfi(BAG.IO.Plan.In.Stk) * BAG.IO.Breite * "BAG.IO.Länge" / 1000000.0 ,Set.Stellen.Menge);
    "BAG.IO.Länge"        # "Mat.Länge";
  end
  else begin
    BAG.IO.Plan.In.Menge  # BAG.IO.Plan.In.GewN;
  end;

  BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
  BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
  BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
  BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;

  BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.In.Menge;
  BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
  BAG.IO.Warengruppe    # Mat.Warengruppe;
  BAG.IO.Lageradresse   # Mat.Lageradresse;
  BAG.IO.Lageranschr    # Mat.Lageranschrift;
  BAG.IO.MEH.In         # BAG.IO.MEH.Out;

  BAG.IO.NachFertigung # 0;
  if ("BAG.P.Typ.1in-1outYN") then    // 1zu1 Arbeitsgang?
    BAG.IO.NachFertigung # 1;

  // ID vergeben
  BAG.IO.ID           # 1;
  WHILE (RecRead(701,1,_recTest)<=_rLocked) do
    BAG.IO.ID # BAG.IO.ID + 1;

  BAG.IO.UrsprungsID    # BAG.IO.ID;
  BAG.IO.Anlage.Datum   # Today;
  BAG.IO.Anlage.Zeit    # Now;
  BAG.IO.Anlage.User    # gUserName;

  if (BA1_Mat_Data:MatEinsetzen()=false) then begin
    Msg(701005,'',0,0,0);
    RETURN false;
  end;

  Erx # BA1_IO_Data:Insert(0,'MAN');
  if (Erx<>_rOk) then begin
//    TRANSBRK;
//    Msg(001000+Erg,gTitle,0,0,0);
    RETURN False;
  end;

  // Output aktualisieren
  if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
//      TRANSBRK;
//      ErrorOutput;
    RETURN false;
  end;


  // Input: Weiterbearbeitung oder Material...
  if (BAG.IO.Materialtyp=c_IO_BAG) or
    ((BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.VonBAG=0)) then begin

    if (BA1_IO_data:Autoteilung(var vKGMM_Kaputt)=false) then begin
//      TRANSBRK;
//      ErrorOutPut;
      RETURN false;
    end;
  end;


  RETURN true;
end;


//========================================================================
//  VerwalteEinsatz
//
//========================================================================
sub VerwalteEinsatz(
  aAufNr      : int;
  aAufPos     : int;
  opt aSilent : logic;
) : logic;
local begin
  Erx     : int;
  vBAnr   : int;
  vBAPos  : int;
  vMitRes : logic;
  vHdl    : int;
  vAnz    : int;
end;
begin

  Auf.Nummer  # aAufnr;
  Erx # RecRead(400,1,0);
  if (Erx>_rLocked) OR (aAufNr <> Auf.Nummer)  then RETURN false;


  Auf.P.Nummer   # Auf.Nummer;
  Auf.P.Position # aAufPos;
  Erx # RecRead(401,1,0); // Auftragsposition laden
  if (Erx>_rLocked) OR (aAufNr <> Auf.P.Nummer) OR (aAufPos <> aAufPos) then RETURN false;


  vAnz # HoleBAPoszuAuf(var vBAnr,var vBAPos);
  if (vAnz>1) then begin
    BAG.Nummer # vBANr;
    BAG.P.Position  # vBAPos;
    BAG.P.Nummer    # vBANr;
    RecRead(700,1,0);
    RecRead(702,1,0);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung','',y);
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN true;
  end;

  if (vAnz=0) then begin
    // BA da, aber keine Pos?
    if (vBAnr <> 0) AND (vBAPos = 0) then begin
      // BA Erweitern
      if (aSilent=n) then
        if (Msg(19999,'BA '+StrAdj(CnvAi(vBAnr),_StrAll)+' erweitern?',_WinIcoQuestion, _WinDialogYesNo,2)=_winIdNo) then RETURN false;
      if (ErzeugeBAPos(vBAnr)=false) then RETURN false;
    end
    else begin
      if ("Auf.P.Löschmarker"<>'') then begin // 16.08.2018 AH
        if (aSilent=n) then
          Msg(404101, aint(Auf.P.Position),_WinIcoError, _WinDialogOk, 1);
        RETURN false;
      end;
      // Neuen BA erstellen
      if (Auf.P.VorlageBAG<>0) then begin
        if (Auf_Subs:BAG2Auf()=false) then RETURN false;
      end
      else begin
        if (aSilent=n) then begin
          if (Msg(700009,'',_WinIcoQuestion, _WinDialogYesNo,2)=_winIdNo) then RETURN false;
          if (RecLink(203, 401, 18, _recFirst)<=_rLocked) then
            vMitRes # (Msg(700010,'',_WinIcoQuestion, _WinDialogYesNo,1)=_winIdYes);
        end;
        if (ErzeugeBA(vMitRes, false)=false) then RETURN false;
      end;
    end;

    vAnz # HoleBAPoszuAuf(var vBAnr,var vBAPos);
    if (vAnz>1) then
      RETURN true;
  end;

//  RecBufClear(701);

  RecRead(700,1,0);
  RecRead(702,1,0);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.IO.Input.Lohn.Verwaltung','',y);
  Lib_GuiCom:RunChildWindow(gMDI);

  vHdl # Winsearch(gMDI, 'Lb.IO.Nummer');
  if (vHdl<>0) then vHdl->wpcustom # aint(aAufNr)+'/'+aint(aAufPos);


  RETURN true;

end;


//========================================================================
//  VerwalteFertigung
//
//========================================================================
sub VerwalteFertigung(
  aAufNr      : int;
  aAufPos     : int;
  opt aSilent : logic;
) : logic;
local begin
  Erx     : int;
  vBAnr   : int;
  vBAPos  : int;
  vMitRes : logic;
  vAnz    : int;
end;
begin

  Auf.Nummer  # aAufnr;
  Erx # RecRead(400,1,0);
  if (Erx>_rLocked) OR (aAufNr <> Auf.Nummer)  then RETURN false;

  Auf.P.Nummer   # Auf.Nummer;
  Auf.P.Position # aAufPos;
  Erx # RecRead(401,1,0); // Auftragsposition laden
  if (Erx>_rLocked) OR (aAufNr <> Auf.P.Nummer) OR (aAufPos <> aAufPos) then RETURN false;

  vAnz # HoleBAPoszuAuf(var vBAnr,var vBAPos);
  if (vAnz>1) then begin
    BAg.Nummer # vBAnr;
    RecRead(700,1,0);
  
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung','',y);
    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN true;
  end;

  if (vAnz=0) then begin
    // BA da, aber keine Pos?
    if (vBAnr <> 0) AND (vBAPos = 0) then begin
      // BA Erweitern
      if (aSilent=false) then
        if (Msg(19999,'BA '+StrAdj(CnvAi(vBAnr),_StrAll)+' erweitern?',_WinIcoQuestion, _WinDialogYesNo,2)=_winIdNo) then RETURN false;
      if (ErzeugeBAPos(vBAnr)=false) then RETURN false;
    end
    else begin
      if ("Auf.P.Löschmarker"<>'') then begin // 16.08.2018 AH
        if (aSilent=n) then
          Msg(404101, aint(Auf.P.Position),_WinIcoError, _WinDialogOk, 1);
        RETURN false;
      end;
      // Neuen BA erstellen
      if (Auf.P.VorlageBAG<>0) then begin
        if (Auf_Subs:BAG2Auf()=false) then RETURN false;
        RETURN true;
      end
      else begin
        if (aSilent=false) then begin
          if (Msg(700009,'',_WinIcoQuestion, _WinDialogYesNo,2)=_winIdNo) then RETURN false;
          if (RecLink(203, 401, 18, _recFirst)<=_rLocked) then
            vMitRes # (Msg(700010,'',_WinIcoQuestion, _WinDialogYesNo,1)=_winIdYes);
        end;
        if (ErzeugeBA(vMitRes, false)=false) then RETURN false;
      end;
    end;

    vAnz # HoleBAPoszuAuf(var vBAnr,var vBAPos);
    if (vAnz>1) then
      RETURN true;
  end;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.F.Lohn.Verwaltung','',y);
  Lib_GuiCom:RunChildWindow(gMDI);

  RETURN true;
end;


//========================================================================
//  BAschonverwogen
//
//========================================================================
sub BAschonverwogen(aBAG : int; opt aBAGP : int) : logic;
local begin
  Erx : int;
end;
begin
  BAG.Nummer # aBAG;
  Erx # RecRead(700,1,0); // BA-Kopf holen
  if (Erx<>_rOK) then RETURN false;

  if (aBAGP <> 0) then begin
    BAG.P.Nummer # aBAG;
    BAG.P.Position # aBAGP;
    Erx # RecRead(702,1,0); // BA-Pos holen
    if (Erx<>_rOK) then
      RETURN false;

    if (RecLinkInfo(707,702,5,_recCount)>0) then
      RETURN true;

  end
  else begin
    if (RecLinkInfo(707,700,5,_recCount)>0) then
      RETURN true;
  end;

  RETURN false;
end;


//========================================================================
//  DeleteAutoVSB
//
//========================================================================
sub DeleteAutoVSB(
  aBAG    : int;
  aPOS    : int;
  ) : logic
local begin
  Erx     : int;
  vBuf701 : int;
  vBuf702 : int;
  vBuf401 : int;
end;
begin
  BAG.Nummer # aBAG;
  Erx # RecRead(700, 1, 0); // BA-Kopf holen
  if (Erx <>_rOK) then RETURN false;

  vBuf701 # RekSave(701);
  vBuf702 # RekSave(702);
  vBuf401 # RekSave(401);
  //if(BA1_P_Data:DelAllVSB() = false) then begin
  if(BA1_P_Data:DelPosVSB(aBAG, aPOS) = false) then begin

    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf401);

    Error(702030,'');
    RETURN false;
  end;
  RekRestore(vBuf701);
  RekRestore(vBuf702);
  RekRestore(vBuf401);

  RETURN true;
end;


//========================================================================
//  DeleteVSBzuInput
//
//========================================================================
sub DeleteVSBzuInput() : logic
local begin
  Erx     : int;
  vBuf701   : int;
  vBuf702   : int;
  vBuf702b  : int;
  vBuf401   : int;
end;
begin

  vBuf701 # RekSave(701);
  vBuf702 # RekSave(702);
  vBuf401 # RekSave(401);

  Erx # RecLink(702,701,4,_recFirst);   // NACH Position holen
  if (Erx>_rLocked) then begin
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf401);
    RETURN false;
  end;

  Erx # RecLink(701,702,3,_RecFirst);   // Output loopen...
  WHILE (Erx<=_rLockeD) do begin
    if (BAG.IO.Materialtyp=c_IO_BAG) and (BAG.IO.NachPosition<>0) then begin
      vBuf702b # RekSave(702);
      Erx # RecLink(702,701,4,_recFirst);   // NACH Position holen
      if (Erx<=_rLocked) then begin
        if (BAG.P.Aktion = c_BAG_VSB) then
          if (BA1_P_Data:DelThisVSB()=falsE) then begin
            RekRestore(vBuf702b);
            RekRestore(vBuf701);
            RekRestore(vBuf702);
            RekRestore(vBuf401);
            RETURN false;
          end;
      end;
      RekRestore(vBuf702b);
    end;
    Erx # RecLink(701,702,3,_RecNext);   // Output loopen...
  END;

  RekRestore(vBuf701);
  RekRestore(vBuf702);
  RekRestore(vBuf401);
  RETURN true;

end;


//========================================================================
//  AutoVSB
//
//========================================================================
sub AutoVSB(
  aBAG  : int;
  opt aBAPos : int;
  ) : logic
local begin
  Erx     : int;
  vOk     : logic;
  vBuf702 : int;
  vBuf703 : int;
  vBuf401 : int;
end;
begin

  vBuf702 # Reksave(702);
  vBuf703 # RekSave(703);
  vBuf401 # RekSave(401);

  BAG.Nummer # aBAG;
  Erx # RecRead(700,1,0); // BA-Kopf holen
  if (Erx<>_rOK) then RETURN false;

  // 04.01.2011 MS Es wird nur noch fuer die "aktuelle" Kommission gewarnt
  // BA1_P_Data:CheckVSBzuAufRest(true);
  BA1_P_Data:CheckVSBzuAufRest();

  vOK # y;
  if(aBAPos <> 0) then begin
    BAG.P.Nummer   # aBAG;
    BAG.P.Position # aBAPOS;
    vOK # BA1_P_Data:AutoVSB()
  end
  else begin
    Erx # RecLink(702,700,1,_RecFirst);   // Arbeitsgänge loopen
    WHILE (Erx<=_rLocked) and (vOK) do begin
      vOK # BA1_P_Data:AutoVSB()
      Erx # RecLink(702,700,1,_RecNext);
    END;
  end;
  if (vOK=false) then begin
    RekRestore(vBuf702);
    Recread(702, 1, 0);
    RekRestore(vBuf703);
    Recread(703, 1, 0);
    RekRestore(vBuf401);
    RecRead(401, 1, 0);

    Error(702007,'');
    RETURN false;
  end;

  RekRestore(vBuf702);
  Recread(702, 1, 0);
  RekRestore(vBuf703);
  Recread(703, 1, 0);
  RekRestore(vBuf401);
  RecRead(401, 1, 0);

  // Erfolgreich !
  RETURN true;
end;


//========================================================================
//  VerwalteBetriebsauftrag
//
//========================================================================
sub VerwalteBetriebsauftrag(
  aAufNr  : int;
  aAufPos : int;
) : logic;
local begin
  Erx     : int;
  vAnz      : int;
  vNr, vPos : int;
  vMitRes   : logic;
  vBAGNr    : int;
  v401      : int;
  vMitSplit : logic;
  vHdl      : int;
end;
begin

  Auf.Nummer  # aAufnr;
  Erx # RecRead(400,1,0);
  if (Erx>_rLocked) then RETURN false

// 14.05.2014 AH war IMEMR 1. Position !!!
//  Erx # RecLink(401,400,9,_RecFirst);   // 1. Aufposition holen
//  if (Erx>_rLocked) then RETURN false
  if (Auf.P.Position<>1) then begin
    vAnz # HoleBAPoszuAuf(var vNr,var vPos);  // Referenzen sind in diesem FAll nicht interessant
    if (vAnz=0) then begin
      v401 # RekSave(401);
      Auf.P.Position # 1;
      vAnz # HoleBAPoszuAuf(var vBAGNr,var vPos);

      // wenn erster BA schon gelöscht ist, neuen Kopf anlengen...
      if (vAnz=1) then begin
        Bag.Nummer # Bag.P.Nummer;
        Erx # RecRead(700,1,0);
        if (Erx>_rLocked) or ("BAG.Löschmarker"='*') then vBagNr # 0;
      end;

      RekRestore(v401);
      vAnz # 0;
    end;
  end;

  if (vAnz=0) then
    vAnz # HoleBAPoszuAuf(var vNr,var vPos);  // Referenzen sind in diesem FAll nicht interessant

  if (vAnz=0) then begin
    if ("Auf.P.Löschmarker"<>'') then begin // 16.08.2018 AH
      Msg(404101, aint(Auf.P.Position),_WinIcoError, _WinDialogOk, 1);
      RETURN false;
    end;
    if (Msg(700009,'',_WinIcoQuestion, _WinDialogYesNo,2)=_winIdNo) then RETURN false;
      // 24.11.2016 AH:
    if (RecLink(203, 401, 18, _recFirst)<=_rLocked) then begin
      vHdl # WinDialog('Dlg.BAG.700010',_WinDialogCenter, gMDI);
//      vMitRes # (Msg(700010,'',_WinIcoQuestion, _WinDialogYesNo,1)=_winIdYes);
      if (vHdl<=0) then RETURN false;
      if (vHdl=1) then
        vMitRes   # true;
      if (vHdl=2) then begin
        vMitRes   # true;
        vMitSplit # true;
      end;
    end;
    if (ErzeugeBA(vMitRes, vMitSplit, vBAGNr)=false) then RETURN false;
  end;

  Bag.Nummer # Bag.P.Nummer;
  RecRead(700,1,0);

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Combo.Verwaltung','',y);
  Lib_GuiCom:RunChildWindow(gMDI);

  RETURN true;
end;



//========================================================================

//========================================================================
sub _VorgaengerKommission(
  opt aNurID  : int;
) : alpha;
local begin
  Erx     : int;
  vA    : alpha;
  v701  : int;
  v702  : int;
end;
begin

  FOR Erx # RecLink(701,702,2,_recFirst)    // Input loopen
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
//debugx('check: KEY701 '+aint(bag.io.auftragsnr)+'/'+aint(bag.io.auftragspos));
    if (aNurID<>0) and (aNurID<>BAG.IO.ID) then CYCLE;

    if (BAG.IO.Auftragsnr<>0) then RETURN aint(BAG.IO.Auftragsnr)+'/'+aint(BAG.IO.Auftragspos);

    if (BAG.IO.VonFertigung<>0) then begin
      Erx # RecLink(703,701,3,_recFirst); // von Fertigung holen
      if (Erx<=_rLocked) then begin
        if (BAG.F.Kommission<>'') then RETURN BAG.F.Kommission;

        v701 # RekSave(701);
        v702 # RekSave(702);
        BAG.P.Nummer    # BAG.F.Nummer;
        BAG.P.Position  # BAG.F.Position;
        Erx # RecRead(702,1,0);
        if (Erx<=_rLocked) then begin
          vA # _VorgaengerKommission(BAG.IO.VonID);
        end;
        RekRestore(v702);
        RekRestore(v701);
        if (vA<>'') then RETURN vA;
      end;
    end;

  END;

  RETURN '';
end;


//========================================================================
//  ErzeugeBAausVorlage
//      ->>>> auch in BA1_Vorlage???
//========================================================================
sub ErzeugeBAausVorlage(
  aVorlage      : int;
  aAufNr        : int;
  aAufPos       : int;
  opt aGewicht  : float;
  opt aBAG      : int;
  opt aOffsetPos  : int;
  opt aOffsetIO   : int;
  opt aOffsetVpg  : int) : int;
local begin
  Erx         : int;
  vNr         : int;
  vTheoID     : int;
  vName       : alpha;
  vName2      : alpha;
  vMengenFakt : float;
  vKGMM_Kaputt  : logic;
  vFirst      : logic;
end;
begin

  if (aGewicht=0.0) then aGewicht # Auf.P.Gewicht;

  BAG.Nummer # aVorlage;
  Erx # RecRead(700,1,0);   // BA holen
  if (Erx>_rLocked) then begin
    Msg(700007,'',0,0,0);
    RETURN 0;
  end;
  if (BAG.VorlageYN=n) or (BAG.VorlageSperreYN) then begin
    Msg(700020,aint(BAG.Nummer),0,0,0);
    RETURN 0;
  end;

  if (BAG.WandelFunktion<>'') and (aBAG=0) then begin
    RETURN Call(BAG.WandelFunktion, BAG.Nummer, Auf.P.Gewicht);
  end;

  TRANSON;

  if (aBAG=0) then begin
    vNr # Lib_Nummern:ReadNummer('Betriebsauftrag');
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      RETURN 0;
    end;

    RecBufClear(700);
    BAG.BuchungsAlgoNr  # Set.BA.BuchungAlgoNr;
    BAG.Nummer        # vNr;
    BAG.Bemerkung     # Translate('aus Vorlage-BA')+' '+aint(aVorlage);

    RunAFX('BA1.LohnSubs.BAGVorlageDaten',Aint(aAufNr) + '/'+Aint(aAufPos));

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
    vNr # aBAG;
    BAG.Nummer # aBAG;
    RecRead(700,1,0);
  end;

  BAG.Nummer # aVorlage;


  // 19.07.2016 AH: Verpackungen kopieren
  FOR Erx # RecLink(704,700,2,_RecFirst)   // Verpackungen loopen
  LOOP Erx # RecLink(704,700,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    BAG.Vpg.Nummer # vNr;
    BAG.Vpg.Verpackung  # BAG.Vpg.Verpackung + aOffSetVpg;
    Erx # RekInsert(704,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;
    BAG.vpg.Nummer # aVorlage;
    BAG.Vpg.Verpackung  # BAG.Vpg.Verpackung - aOffSetVpg;
    RecRead(704,1,0);
  END;


  // Positionen kopieren.......
  FOR Erx # RecLink(702,700,1,_recFirst)     // Positionen loopen
  LOOP Erx # RecLink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // 10.02.2015 AH
    if (BAG.P.Typ.VSBYN) and (aAufNr<>0) then begin
      if (StrCut(_VorgaengerKommission(),1,1)='#') then begin
//        BA1_P_Data:AutoVSB();
        BAG.P.Kommission    # AInt(aAufNr)+'/'+AInt(aAufPos);
        BAG.P.Auftragsnr    # aAufNr;
        BAG.P.Auftragspos   # aAufPos;
        Erx # RecLink(401,702,16,_recFirst);    // Aufpos holen
        if (Erx<=_rLockeD) then begin
          Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
          if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then Erx # _rNoRec;
        end;
        if (Erx<=_rLocked) then begin
          if (Auf.P.TerminZusage<>0.0.0) then
            BAG.P.Fenster.MaxDat  # Auf.P.TerminZusage
          else
            BAG.P.Fenster.MaxDat  # Auf.P.Termin1Wunsch;
        end;
        BAG.P.Plan.StartDat # BAG.P.Fenster.MaxDat;
        BAG.P.Plan.EndDat   # BAG.P.Fenster.MaxDat;

        // 26.04.2018 AH: geplante VSB-Menge holen
        FOR Erx # RecLink(701,702,2,_recFirst)  // Input loopen
        LOOP Erx # RecLink(701,702,2,_recNext)
        WHILE (Erx<=_rLocked) do begin
          vMengenFakt # BAG.IO.Plan.In.GewN;
        END;
        if (vMengenFakt<>0.0) then begin
          vMengenFakt # aGewicht / vMengenFakt;
        end;

      end;
      BAG.P.Bezeichnung   # BAG.P.Aktion+' '+BAG.P.Kommission;

    end;


    // 09.12.2021 + 27.09.2021 AH:
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
      Erx # RecLink(401,701,16,_recFirst);    // Aufpos holen
      if (Erx<=_rLockeD) then begin
        Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
        if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then Erx # _rNoRec;
      end;
      BAG.P.Auftragsnr    # aAufNr;
      BAG.P.Auftragspos   # aAufPos;
    end;


    // Texte kopieren 20.01.2016:
    vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
    vName2  # '~702.'+CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position+aOffsetPos,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.K';
    TxtCopy(vName,vName2,0);
    vName   # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
    vName2  # '~702.'+CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position+aOffsetPos,_FmtNumLeadZero | _FmtNumNoGroup,0,2+ cnvil(BAG.P.Position>99))+'.F';
    TxtCopy(vName,vName2,0);




    BAG.P.Nummer        # vNr;
    BAG.P.Position  # BAG.P.Position + aOffsetPos;
    if (BAG.P.Status='') and ("BAG.P.Löschmarker"='') then
      BA1_Data:SetStatus(c_BagStatus_Offen);
    if ("BAG.P.Löschmarker"<>'') then
      BA1_Data:SetStatus(c_BagStatus_Fertig);

    if (Set.Installname = 'BSC') then begin
      // ST 2021-09-13 Projekt 2298/17
      Call('SFX_ESK_Cut:CopyEskToBag', aVorlage, BAG.P.Position - aOffsetPos,true);
    end;


    Erx # BA1_P_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;
    BAG.P.Nummer # aVorlage;
    BAG.P.Position  # BAG.P.Position - aOffsetPos;


    FOR Erx # RecLink(706,702,9,_RecFirst)   // Arbeitsschritte loopen
    LOOP Erx # RecLink(706,702,9,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      BAG.AS.Nummer # vNr;
      BAG.AS.Position # BAG.AS.Position + aOffsetPos;
      Erx # RekInsert(706,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN 0;
      end;
      BAG.AS.Nummer # aVorlage;
      BAG.AS.Position # BAG.AS.Position - aOffsetPos;
      RecRead(706,1,0);
    END;

  END;  // Positionen


  // NEU 19.09.2014:
  FOR Erx # RecLink(701,700,3,_recFirst)    // InOut loopen
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    BAG.IO.Nummer   # vNr;
    BAG.IO.ID       # BAG.IO.ID + aOffsetIO;
    if (BAG.IO.VonBAG=aVorlage) then begin
      BAG.IO.VonBAG       # vNr;
      BAG.IO.VonPosition  # BAG.IO.VonPosition + aOffsetPos;
      if (BAG.IO.VonID<>0) then
        BAG.IO.VonID # BAG.IO.VonID + aOffsetIO;
    end;
    if (BAG.IO.NachBAG=aVorlage) then begin
      BAG.IO.NachBAG        # vNr;
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

    // 26.04.2018 AH : Mengen anpassen...
    if (vMengenFakt<>0.0) then begin
      if (BAG.IO.Materialtyp=c_IO_Theo) or (BAG.IO.Materialtyp=c_IO_Beistell) then begin
        BAG.IO.Plan.In.GewB   # Rnd(BAG.IO.Plan.In.GewB * vMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.In.GewN   # Rnd(BAG.IO.Plan.In.GewN * vMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.In.Menge  # Rnd(BAG.IO.Plan.In.Menge * vMengenFakt, Set.Stellen.Menge);
        BAG.IO.Plan.Out.GewB  # Rnd(BAG.IO.Plan.Out.GewB * vMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.Out.GewN  # Rnd(BAG.IO.Plan.Out.GewN * vMengenFakt, Set.Stellen.Gewicht);
        BAG.IO.Plan.Out.Meng  # Rnd(BAG.IO.Plan.Out.Meng * vMengenFakt, Set.Stellen.Menge);
        if (BAG.IO.Materialtyp=c_IO_Beistell) then begin
          BAG.IO.Plan.In.Stk  # cnvif(Lib_Berechnungen:RndUp(cnvfi(BAG.IO.Plan.In.Stk) * vMengenFakt));
          BAG.IO.Plan.Out.Stk # cnvif(Lib_Berechnungen:RndUp(cnvfi(BAG.IO.Plan.Out.Stk) * vMengenFakt));
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
      RETURN 0;
    end;

    BAG.IO.Nummer   # aVorlage;
    BAG.IO.ID       # BAG.IO.ID - aOffsetIO;
  END;



  FOR Erx # RecLink(703,700,6,_recFirst)    // Fertigungen loopen
  LOOP Erx # RecLink(703,700,6,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // 20.06.2016 AH:
    FOR Erx # RecLink(705,703,8,_RecFirst)  // Ausführungen kopieren
    LOOP Erx # RecLink(705,703,8,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      BAG.AF.Nummer   # vNr;
      BAG.AF.Position # BAG.AF.Position + aOffsetPos;
      Erx # RekInsert(705,0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN 0;
      end;
      BAG.AF.Nummer   # aVorlage;
      BAG.AF.Position # BAG.AF.Position - aOffsetPos;
    END;


    BAG.F.Nummer    # vNr;
    BAG.F.Position  # BAG.F.Position + aOffsetPos;
    if (StrCut(BAG.F.Kommission,1,1)='#') and (aAufPos<>0) then begin
      BA1_F_Data:BelegeKommisisonsDaten(BAG.F.Kommission, aAufNr, aAufPos)
    end;
    BAG.F.Anlage.Datum  # Today;
    BAG.F.Anlage.Zeit   # Now;
    BAG.F.Anlage.User   # gUserName;

    Erx # RekInsert(703,0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN 0;
    end;

    BAG.F.Nummer    # aVorlage;
    BAG.F.Position  # BAG.F.Position - aOffsetPos;
  END;

  BAG.Nummer # vNr;
  RecRead(700,1,0);

/***
  // 26.04.2018 AH: nach LEVEL
  FOR Erx # RecLink(702,700,4,_recFirst)      // Positionen loopen
  LOOP Erx # RecLink(702,700,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // 10.02.2015 AH:
    if (BAG.P.Typ.VSBYN) then begin
      if (BA1_F_Data:UpdateOutput(702)<>y) then begin
      end;
      CYCLE;
    end;

    // 21.01.2019 AH: Autoteilung !
    FOR Erx # RecLink(701,702,2,_recFirst)    // Input loopen
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BA1_IO_Data:Autoteilung(var vKGMM_Kaputt)=false) then begin
      end;
      // Output aktualisieren
      if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      end;
    END;
  END;
***/

  // 25.03.2019 AH: UMBAU
  Erx # RecLink(702,700,4,_recFirst);     // Positionen loopen
  if (Erx<=_rLocked) then begin
    FOR Erx # RecLink(701,702,2,_recFirst)    // Input loopen
    LOOP Erx # RecLink(701,702,2,_recNext)
    WHILE (Erx<=_rLocked) do begin
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
  FOR Erx # RecLink(701,700,3,_recFirst)  // IO loopen
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rLocked) and (vTheoID>=0) do begin
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

  TRANSOFF;   // 2023-07-19 AH s.u.

  if (aAufNr<>0) then begin
    if (Set.Installname<>'BFS') then  // HACK
      BA1_Subs:EinsatzLautAuftrag(aAufNr, aAufPos, vTheoID);
  end;

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

// 2023-07-19 AH  TRANSOFF; muss früher!

  RETURN vNr;
end;


//========================================================================
//========================================================================
