@A+
//===== Business-Control =================================================
//
//  Prozedur    Mat_Rsv_Data
//                OHNE E_R_G
//  Info
//
//
//  08.08.2005  AI  Erstellung der Prozedur
//  30.11.2012  AI  Gelöschte Karten können NICHt reserviert werden
//  10.04.2013  AI  MatMEH
//  30.06.2015  AH  "Entfernen" kann auf Matablage
//  14.04.2016  AH  Neu: "AlleMarkMatEinfuegen"
//  09.01.2018  AH  Bug: Abbruch, wenn Kommission nicht updatebar ist
//  06.05.2019  AH  Edit: "ReorgAll" löscht auch Res. auf gelöschtem Material
//  24.01.2020  AH  Neu: Mat.R.Menge wird gefüllt
//  05.02.2020  AH  Edit: "Mat.Reserviert2" zählt nur Reservierungen MIT Kommission
//  17.02.2020  AH  Edit: Fahr-Reservierungen summieren sich ggf. nicht ins Material
//  18.02.2020  AH  Neu: "RecalcAllMats"
//  18.05.2021  AH  AFX "Mat.Rsv.AufPos.Inner"
//  05.10.2021  AH  ERX
//  2022-07-05  AH  DEADLOCK
//
//  Subprozeduren
//    SUB Neuanlegen(opt aNr : int; opt aTyp : alpha) : logic;
//    SUB Entfernen
//    SUB Update() : logic;
//    SUB Takeover(aRes : int; aZielMat : int; aStk : intl; aGew : float; opt aDelRest : logic) : logic;
//    SUB ReCalcAll();
//    SUB ReorgAll(aDat : date) : logic;
//    SUB AlleMarkMatEinfuegen()
//    SUB RecalcAllMats()
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen
@I:Def_BAG

//========================================================================
//  AuftragsRes
//
//========================================================================
sub AuftragsRes(
  aStk          : int;    // DELTA
  aGew          : float;
  aMenge        : float;
  aMEH          : alpha;
  ) : logic;
local begin
  Erx       : int;
  vBuf401   : int;
  vMEH      : alpha;
  vMenge    : float;
  vRestAlt  : float;
  vRestNeu  : float;
end;
begin

  vBuf401 # RecbufCreate(401);
  Erx # RecLink(vbuf401, 203, 2, _recFirst);    // Auftragspos. holen
  if (Erx>_rLocked) then begin
    RekRestore(vBuf401);
    RETURN true;
  end;
  
  vMEH # vBuf401->Auf.P.MEH.Einsatz;
  Erx # RecRead(vBuf401,1,_recLock);
  if (erx=_rOK) then begin
    vRestAlt # vBuf401->Auf.P.Menge - vBuf401->Auf.P.Prd.VSB - vBuf401->Auf.P.Prd.LFS - vBuf401->Auf.P.Prd.Plan - vBuf401->Auf.P.Prd.Reserv;
    vRestAlt # Max(vRestAlt, 0.0);  // NICHT negativ
    
    vBuf401->Auf.P.Prd.Reserv.Stk # vBuf401->Auf.P.Prd.Reserv.Stk + aStk;
    vBuf401->Auf.P.Prd.Reserv.Gew # vBuf401->Auf.P.Prd.Reserv.Gew + aGew;
    if (vMEH='kg') then
      vBuf401->Auf.P.Prd.Reserv # vBuf401->Auf.P.Prd.Reserv + aGew
    else if (vMEH='t') then
      vBuf401->Auf.P.Prd.Reserv # vBuf401->Auf.P.Prd.Reserv + (aGew / 1000.0)
    else if (vMEH='Stk') then
      vBuf401->Auf.P.Prd.Reserv # vBuf401->Auf.P.Prd.Reserv + cnvfi(aStk)
    else if (vMEH=aMEH) then
      vBuf401->Auf.P.Prd.Reserv # vBuf401->Auf.P.Prd.Reserv + aMenge;
    else begin
      aMenge # Lib_Einheiten:WandleMEH(200, aStk, aGew, aMenge, aMEH, vMEH);
      vBuf401->Auf.P.Prd.Reserv # vBuf401->Auf.P.Prd.Reserv + aMenge;
    end;
    RunAFX('Mat.Rsv.AufPos.Inner', aint(vBuf401)+'|'+aint(aStk)+'|'+aNum(aGew,3)+'|'+aNum(aMenge,3)+'|'+aMEH);  // 18.05.2021 AH
    Erx # RekReplace(vBuf401,_recUnlock,'AUTO');
  end;
  if (Erx<>_rOK) then begin
    RekRestore(vBuf401);
    RETURN false;
  end;
  vRestNeu # vBuf401->Auf.P.Menge - vBuf401->Auf.P.Prd.VSB - vBuf401->Auf.P.Prd.LFS - vBuf401->Auf.P.Prd.Plan - vBuf401->Auf.P.Prd.Reserv;
  vRestNeu # Max(vRestNeu, 0.0);  // NICHT negativ


  // 07.02.2020 AH: PROBLEM: Überreservierungen sollen ja keine negativen OffeneAuf-Menge erzeugen, aber späteres Löschen solcher Res.
  //                buchen dann zu viel im Plus! Z.b. Auf 10t, Res11 ergeben 0 Offen; löschen davon dann aber 11 offen!!

  if (Set.Art.AufRst.Rsrv) and
    (Wgr_Data:IstMix(vBuf401->Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstArt(vBuf401->Auf.P.Wgr.Dateinr)) then begin
//debugx('mod OffenAuf um ' +anum(-aMenge,2));
//        Erx # RecLink(835,vBuf401,5,_recFirst);       // Auftragsart holen
//        if (Erx>_rLocked) then RecBufClear(835);
//        if (AAr.ReservierePosYN) then begin
    vMenge # vRestAlt - vRestNeu;
    
    Erx # _rOK;
    if (Art.Nummer<>vBuf401->Auf.P.Artikelnr) then
      Erx # RecLink(250,vBuf401,2,_recFirst)        // AufPositionsartikel holen
    if (Erx<=_rLocked) then begin
      // 12.02.2020 AH:
      if (Art.MEH<>vMEH) then begin
        if (Art.MEH='kg') then
          vMenge # aGew
        else if (Art.MEH='t') then
          vMenge # (aGew / 1000.0)
        else if (Art.MEH='Stk') then
          vMenge # cnvfi(aStk)
        else if (Art.MEH=aMEH) then
          vMenge # aMenge
        else
          vMenge # Lib_Einheiten:WandleMEH(200, aStk, aGew, aMenge, aMEH, Art.MEH);
      end;
    
      RecBufClear(252);
      Art.C.ArtikelNr     # Art.Nummer;
      Art.C.Dicke         # vBuf401->Auf.P.Dicke;
      Art.C.Breite        # vBuf401->Auf.P.Breite;
      "Art.C.Länge"       # vBuf401->"Auf.P.Länge";
      Art.C.RID           # vBuf401->Auf.P.RID;
      Art.C.RAD           # vBuf401->Auf.P.RAD;
      Art_Data:Auftrag(-vMenge);  // in ArtMEH !!!

      // Material gehört aber ANDEREM Artikel an??? 12.02.2020
      if (Mat.Strukturnr<>'') and (Mat.Strukturnr<>Art.Nummer) then begin
        vMenge # aMenge;    // hier VOLLE Menge, nicht Delta!
        vMEH # Art.MEH;
        // 12.02.2020 AH:
        if (Art.MEH<>vMEH) then begin
          if (Art.MEH='kg') then
            vMenge # aGew
          else if (Art.MEH='t') then
            vMenge # (aGew / 1000.0)
          else if (Art.MEH='Stk') then
            vMenge # cnvfi(aStk)
          else if (Art.MEH=aMEH) then
            vMenge # aMenge
          else
            vMenge # Lib_Einheiten:WandleMEH(200, aStk, aGew, aMenge, aMEH, Art.MEH);
        end;
      
        RecBufClear(252);
        Art.C.ArtikelNr     # Art.Nummer;
        Art.C.Dicke         # vBuf401->Auf.P.Dicke;
        Art.C.Breite        # vBuf401->Auf.P.Breite;
        "Art.C.Länge"       # vBuf401->"Auf.P.Länge";
        Art.C.RID           # vBuf401->Auf.P.RID;
        Art.C.RAD           # vBuf401->Auf.P.RAD;
        Art_Data:MatFremdReserv(vMenge);
      end;
    end;

/***
        if (AAr.ReserviereSLYN) then begin
          FOR Erx # RecLink(409,401,15,_recFirst)
          LOOP Erx # RecLink(409,401,15,_recNext)
          WHILE (Erx<=_rLocked) do begin
            // Stückliste entreservieren
    x        Auf_SL_Data:Reservieren(y);
          END;
        end;
***/
  end;

  RecBufDestroy(vBuf401);
  RETURN true;
end;


//========================================================================
//========================================================================
sub IstInMatSummierbar(opt aOhneSetting : logic) : logic;
begin
  if (aOhneSetting=false) then
    if (Set.Mat.Res.OhneLFA=false) then RETURN true;    // 17.02.2020 AH, Proj. 2076/22
  
  RETURN ("Mat.R.Trägertyp"<>c_Akt_BAInput) or
    ((Mat.R.Bemerkung<>c_BAG_Fahr09) and (Mat.R.Bemerkung<>c_BAG_Umlager));
end;


//========================================================================
//  NeuAnlegen
//
//========================================================================
sub Neuanlegen(
  opt aNr   : int;
  opt aTyp  : alpha) : logic;
local begin
  Erx     : int;
  vBuf200 : int;
  vNr     : int;
  vBuf401 : int;
end;
begin

  if ("Mat.Löschmarker"<>'') then RETURN false;

  if (Mat.R.Gewicht<0.0) or ("Mat.R.Stückzahl"<0) or (Mat.R.Menge<0.0) then begin
    RETURN true;
  end;

  if (Mat.R.Auftragsnr<>0) then begin
    Mat.R.Kommission # AInt(Mat.R.Auftragsnr) + '/' + AInt(Mat.R.Auftragspos);
  end;


  // 24.01.2020 AH
  if (Mat.R.Menge=0.0) then begin
    Mat.R.Menge # Rnd(Lib_Berechnungen:Dreisatz(Mat.Bestand.Menge+Mat.Bestellt.Menge, Mat.Bestand.Gew+Mat.Bestellt.Gew,  Mat.R.Gewicht), Set.Stellen.Gewicht);
  end;

  if (aTyp='') then aTyp # 'AUTO';

  TRANSON;

  if (aNr<>0) then begin
    vNr # aNr;
  end
  else begin
    vNr # Lib_Nummern:ReadNummer('Material-Reservierung');
    if (vNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      RETURN false;
    end;
  end;

  Mat.R.Reservierungnr  # vNr;
  Mat.R.Anlage.Datum    # Today;
  Mat.R.Anlage.Zeit     # Now;
  Mat.R.Anlage.User     # gUserName;
  Erx # RekInsert(203,0,aTyp);
  If (erx<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;

  vBuf200 # RekSave(200);

  // 17.02.2020
  if (IstInMatSummierbar()) then begin
    // Reservierungssummen updaten und in Materialdatei speichern
    Mat.Nummer # Mat.R.Materialnr;
    Erx # RecRead(200,1, _RecLock);
    if (Erx=_rOk) then begin
      Mat.Reserviert.Stk    # Mat.Reserviert.Stk + "Mat.R.Stückzahl";
      Mat.Reserviert.Gew    # Mat.Reserviert.Gew + Mat.R.Gewicht;
      Mat.Reserviert.Menge  # Mat.Reserviert.Menge + Mat.R.Menge;
    // 05.02.2020 AH  Proj. 2076/4, Feld "Mat.Reserviert2" wurde 2010-2012 eingebaut aber warum weiss keiner!!
    // 05.02.2020 AH  Jetzt neu, dass allgemeine kommissionlose Reservierungen NICHT addieren!
      if ("Mat.R.Trägertyp"='') and (Mat.R.Auftragsnr<>0) then begin
        Mat.Reserviert2.Stk   # Mat.Reserviert2.Stk   + "Mat.R.Stückzahl";
        Mat.Reserviert2.Gew   # Mat.Reserviert2.Gew   + Mat.R.Gewicht;
        Mat.Reserviert2.Meng  # Mat.Reserviert2.Meng  + Mat.R.Menge;
      end;
      Erx # Mat_data:Replace(_RecUnlock,'AUTO');
    end;
    If (erx<>_rOK) then begin
      RekRestore(vBuf200);
      TRANSBRK;
      RETURN false;
    end;
  end;

  // Auftragsmenge updaten
  if (Mat.R.Auftragsnr<>0) then begin

    // 09.01.2018 AH
    if (AuftragsRes("Mat.R.Stückzahl", Mat.R.Gewicht, Mat.R.Menge, Mat.MEH)=false) then begin
      RekRestore(vBuf200);
      TRANSBRK;
      RETURN false;
    end;
  end;

  TRANSOFF;

  RekRestore(vBuf200);
  RETURN true;
end;


//========================================================================
//  Entfernen
//
//========================================================================
sub Entfernen(opt aMan : logic) : logic;
local begin
  Erx     : int;
  vBuf200 : int;
  vA      : alphA(100);
end;
begin

  TRANSON;

  vBuf200 # RekSave(200);

  // 17.02.2020
  if (IstInMatSummierbar()) then begin

    Mat.Nummer # Mat.R.Materialnr;
    // Reservierungensummen updaten und in Materialdatei speichern
    Erx # Mat_Data:Read(Mat.Nummer, _recLock, 0, Y);
    if (Erx<>200) then begin
      TRANSBRK;
      RekRestore(vBuf200);
      RETURN false;
    end;

  //debug('raus bei '+aint(mat.nummer)+' von '+anum(mat.reserviert.gew,0)+' minus '+anum(mat.r.gewicht,0));

    Mat.Reserviert.Stk    # Mat.Reserviert.Stk - "Mat.R.Stückzahl";
    Mat.Reserviert.Gew    # Mat.Reserviert.Gew - Mat.R.Gewicht;
    Mat.Reserviert.Menge  # Mat.Reserviert.Menge - Mat.R.Menge;
    if ("Mat.R.Trägertyp"='') and (Mat.R.Auftragsnr<>0) then begin
      Mat.Reserviert2.Stk   # Mat.Reserviert2.Stk - "Mat.R.Stückzahl";
      Mat.Reserviert2.Gew   # Mat.Reserviert2.Gew - Mat.R.Gewicht;
      Mat.Reserviert2.Meng  # Mat.Reserviert2.Meng - Mat.R.Menge;
    end;

    Erx # Mat_data:Replace(_RecUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      RekRestore(vBuf200);
      TRANSBRK;
      RETURN false;
    end;
  end;

  // Auftragsmenge updaten
  if (Mat.R.Auftragsnr<>0) then begin
    // 09.01.2018 AH:
    if (AuftragsRes(-"MAt.R.Stückzahl", -Mat.R.Gewicht, -Mat.R.Menge, Mat.MEH)=false) then begin
      RekRestore(vBuf200);
      TRANSBRK;
      RETURN false;
    end;
  end;


  Lib_Workflow:Trigger(203, Mat.R.Workflow, _WOF_KTX_DEL);


  // Ankerfunktion
  if (aMan) then
    RunAFX('Mat.Rsv.Delete','Y')
  else
    RunAFX('Mat.Rsv.Delete','N');

  Erx # RekDelete(203,0,'AUTO');
  if (Erx<>_rOK) then begin
    RekRestore(vBuf200);
    TRANSBRK;
    RETURN false;
  end;

  Mat.R.ReservierungNr # 0;

  TRANSOFF;

  RekRestore(vBuf200);

  RETURN true;
end;


//========================================================================
//  Update
//
//========================================================================
sub Update() : logic;
local begin
  Erx     : int;
  vBuf203 : int;
  vBuf200 : int;
  vStk    : int;
  vGew    : float;
  vMenge  : float;
end;
begin
  if (Mat.R.Gewicht<=0.0) and ("Mat.R.Stückzahl"<=0) then begin
    RETURN Entfernen();
  end;

  vBuf203 # RekSave(203);
  vBuf200 # RekSave(200);

  Mat.Nummer # Mat.R.Materialnr;
  // Reservierungensummen updaten und in Materialdatei speichern
//  Erx # RecRead(200,1,_RecNoLoad | _RecLock);
  Erx # RecRead(200,1,_RecLock);
  if (Erx<>_rOk) then begin
    RekRestore(vBuf203);
    RekRestore(vBuf200);
    RETURN false;
  end;

  Erx # RecRead(203,1,_recLock);
  if (Erx<>_rOk) then begin
    RekRestore(vBuf203);
    RekRestore(vBuf200);
    RETURN false;
  end;

  // 07.02.2020 AH:
  vBuf203->Mat.R.Menge # Rnd(Lib_Berechnungen:Dreisatz(Mat.R.Menge, Mat.R.Gewicht, vBuf203->Mat.R.Gewicht), Set.Stellen.Gewicht);
  
  // DELTAS
  vStk    # (vBuf203->"Mat.R.Stückzahl") - "Mat.R.Stückzahl";
  vGew    # (vBuf203->Mat.R.Gewicht) - Mat.R.Gewicht;
  vMenge  # (vBuf203->Mat.R.Menge) - Mat.R.Menge;
  RecBufCopy(vBuf203,203);

  Mat.Reserviert.Stk    # Mat.Reserviert.Stk + vStk;
  Mat.Reserviert.Gew    # Mat.Reserviert.Gew + vGew;
  Mat.Reserviert.Menge  # Mat.Reserviert.Menge + vMenge;
  if ("Mat.R.Trägertyp"='') and (Mat.R.Auftragsnr<>0) then begin
    Mat.Reserviert2.Stk   # Mat.Reserviert2.Stk + vStk;
    Mat.Reserviert2.Gew   # Mat.Reserviert2.Gew + vGew;
    Mat.Reserviert2.Meng  # Mat.Reserviert2.Meng + vMenge;
  end;

  TRANSON;

  Erx # RekReplace(203,_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    RekRestore(vBuf203);
    RekRestore(vBuf200);
    RETURN false;
  end;

    // 17.02.2020
  if (IstInMatSummierbar()) then begin
    Erx # Mat_data:Replace(_RecUnlock,'AUTO');
    if (erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
      TRANSBRK;
      RekRestore(vBuf203);
      RekRestore(vBuf200);
      RETURN false;
    end;
  end
  else begin
    Erx # RecRead(200,1,_recUnlock);
  end;
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RekRestore(vBuf203);
    RekRestore(vBuf200);
    RETURN false;
  end;

  // Auftragsmenge updaten
  if (Mat.R.Auftragsnr<>0) then begin
    // 09.01.2018 AH:
    if (AuftragsRes(vStk, vGew, vMenge, Mat.MEH)=false) then begin
      RekRestore(vBuf203);
      RekRestore(vBuf200);
      TRANSBRK;
      RETURN false;
    end;
  end;

  TRANSOFF;

  RekRestore(vBuf203);
  RekRestore(vBuf200);
  RETURN true;
end;


//========================================================================
//  Takeover
//
//========================================================================
sub Takeover(
  aRes          : int;
  aZielMat      : int;
  aStk          : int;
  aGew          : float;
  aMenge        : float;
  opt aDelRest  : logic;
) : logic;
local begin
  Erx     : int;
  vNr       : int;
  vOK       : logic;
  v200      : int;
end;

begin

  if (aStk<0) or (aGew<0.0) or (aMenge<0.0) then RETURN false;

  // 10.04.2013 VORLÄUFIG:
  if (aMenge=0.0) then aMenge # Mat_data:MengeVorlaeufig(aStk, aGew, aGew);

  Mat.R.Reservierungnr # aRes;
  Erx # RecRead(203,1,0);
  if (Erx<>_rOK) then RETURN false;

  TRANSON;

  // alte Reservierung ändern bzw. löschen...
  "Mat.R.Stückzahl" # "Mat.R.Stückzahl" - aStk;
  Mat.R.Gewicht     # Mat.R.Gewicht - aGew;
  Mat.R.Menge       # Mat.R.Menge   - aMenge;

  if ("Mat.R.Stückzahl"<0) then "Mat.R.Stückzahl" # 0;

  if (Mat.R.Gewicht<0.0) then Mat.R.Gewicht # 0.0;
  if (Mat.R.Menge<0.0) then Mat.R.Menge # 0.0;

//debugx(abool(aDelRest)+' '+anum(Mat.R.Gewicht,0)+'|'+anum(Mat.R.menge,0));
  if (aDelRest) or ((Mat.R.Gewicht<=0.0) and (Mat.R.Menge<=0.0)) then begin
    vNr # Mat.R.ReservierungNr;
    RecRead(203,1,0); // Restore
    vOK # Entfernen();
  end
  else begin
    vOK # Update();
  end;
  if (vOK=n) then begin
    TRANSBRK;
    RETURN false;
  end;

  if (aZielMat<>0) then begin
    v200 # RekSave(200);
    Mat.Nummer # aZielMat;
    Erx # RecRead(200,1,0);
    if (Erx>_rLocked) then begin
      RekRestore(v200);
      TRANSBRK;
      RETURN false;
    end;
    // neue Reservierung anlegen...
    Mat.R.Reservierungnr  # 0;
    "Mat.R.Stückzahl"     # aStk;
    Mat.R.Gewicht         # aGew;
    Mat.R.Menge           # aMenge;
    Mat.R.Materialnr      # aZielMat;
    if (NeuAnlegen(vNr)=n) then begin
      RekRestore(v200);
      TRANSBRK;
      RETURN false;
    end;
    RekRestore(v200);
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  ReCalcall
//
//========================================================================
sub ReCalcAll() : logic;
local begin
  Erx     : int;
  vRStk     : int;
  vRGew     : float;
  vRMenge   : float;
  vR2Stk    : int;
  vR2Gew    : float;
  vR2Menge  : float;
end;
begin
//debugx('KEY203 vorher Res'+anum(Mat.Reserviert.Gew,0));

  FOR  Erx # RecLink( 203, 200, 13, _recFirst );
  LOOP Erx # RecLink( 203, 200, 13, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN

    // 17.02.2020
    if (IstInMatSummierbar()) then begin
      vRStk     # vRStk + "Mat.R.Stückzahl";
      vRGew     # vRGew + "Mat.R.Gewicht";
      vRMenge   # vRMenge + "Mat.R.Menge";
      if ("Mat.R.Trägertyp"='') and (Mat.R.Auftragsnr<>0) then begin
        vR2Stk    # vR2Stk    + "Mat.R.Stückzahl";
        vR2Gew    # vR2Gew    + "Mat.R.Gewicht";
        vR2Menge  # vR2Menge  + "Mat.R.Menge";
      end;
    end;

  END;
//debugx('KEY203 dann Res'+anum(Mat.Reserviert.Gew,0));

  if (vRStk<>Mat.Reserviert.Stk) or (vRGew<>Mat.Reserviert.Gew) or (vRMenge<>Mat.Reserviert.Menge) or
      (vR2Stk<>Mat.Reserviert2.Stk) or (vR2Gew<>Mat.Reserviert2.Gew) or (vR2Menge<>Mat.Reserviert2.Meng) then begin
    Erx # RecRead(200,1,_RecLock);
    if (Erx=_rOK) then begin
      Mat.Reserviert.Stk    # vRStk;
      Mat.Reserviert.Gew    # vRGew;
      Mat.Reserviert.Menge  # vRMenge;
      Mat.Reserviert2.Stk   # vR2Stk;
      Mat.Reserviert2.Gew   # vR2Gew;
      Mat.Reserviert2.Meng  # vR2Menge;
      Erx # Mat_Data:Replace( _recUnlock, 'AUTO' );
    end;
    If (Erx<>_rOK ) then begin
      RecRead( 200, 1, _recUnlock );
      RETURN false;
    end;
  end;

  RETURN true;
end;


//========================================================================
//  sub LoescheReserv() : logic
//    Löscht alle Reservierungen bis Ablaufdatum
//========================================================================
sub ReorgAll(
  aDat  : date;
) : logic
local begin
  Erx     : int;
  vDel    : logic;
end;
begin

  If (Rechte[Rgt_Mat_R_Reorg]=n) then RETURN false;

  APPOFF();
  TRANSON;

  // Reservierungen durchlaufen...
  RecbufClear(203);
/***
  Mat.R.Ablaufdatum # 1.1.1901;
  Erx # RecRead(203,6,0);
  WHILE (Erx <= _rNoKey) and (Mat.R.Ablaufdatum>0.0.0) and (Mat.R.Ablaufdatum<=aDat) do begin

    // Reservierung löschen
    if (Entfernen() = false) then begin
      TRANSBRK;
      APPON();
      //Error('Reservierung '+CnvAi(Mat.R.Reservierungnr)+' zu Material ' + CnvAi(Mat.Nummer) + ' konnte nicht gelöscht werden!');
      Error(203007,aint(Mat.R.Reservierungnr)+'|' +aint(Mat.Nummer));
      RETURN false;
    end;

    Erx # RecRead(203,6,0);
    Erx # RecRead(203,6,0);
  END;
***/
  Erx # RecRead(203,1,_RecFirst);
  WHILE (Erx <= _rNoKey) do begin
    vDel # false;
    if (Mat.R.Ablaufdatum>0.0.0) and (Mat.R.Ablaufdatum<=aDat) then vDel # true
    else begin
      Erx # RecLink(200,203,1,_RecFirst);   // Material holen
      if (Erx>_rLocked) or ("Mat.Löschmarker"<>'') then vDel # y;
    end;
    
    if (vDel) then begin
      // Reservierung löschen
      if (Entfernen() = false) then begin
        TRANSBRK;
        APPON();
        //Error('Reservierung '+CnvAi(Mat.R.Reservierungnr)+' zu Material ' + CnvAi(Mat.Nummer) + ' konnte nicht gelöscht werden!');
        Error(203007,aint(Mat.R.Reservierungnr)+'|' +aint(Mat.Nummer));
        RETURN false;
      end;
      Erx # RecRead(203,1,0);
      Erx # RecRead(203,6,0);
      CYCLE;
    end;
    
    Erx # RecRead(203,1,_RecNext);
  END;


  TRANSOFF;
  APPON();

  RETURN true;
end;


//========================================================================
//  AlleMarkMatEinfuegen
//
//========================================================================
sub AlleMarkMatEinfuegen()
local begin
  Erx           : int;
  vMarked       : int;
  vMarkedItem   : int;
  vMFile        : int;
  vMID          : int;
  vAnz          : int;
end;
begin

  // Ankerfunktion
  if (RunAFX('Mat.Rsv.InsertAllMark','')<>0) then RETURN;

  // Markierung loopen
  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
  WHILE (vMarked > 0) DO BEGIN

    Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);

    // Markierung nicht aus Artikel?
    if (vMFile <> 200) then CYCLE;

    inc(vAnz);
  END;


  if (vAnz=0) then RETURN;

  if (Msg(203009,aint(vAnz),_WinIcoQuestion,_WinDialogYesNo,0)<>_winidyes) then RETURN;


  TRANSON;

  // Markierung loopen
  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
  WHILE (vMarked > 0) DO BEGIN

    Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);

    // Markierung nicht aus Artikel?
    if (vMFile <> 200) then CYCLE;

    Erx # RecRead(200,0,_recid,vMID);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(203010,aint(Mat.Nummer),0,0,0);
      RETURN;
    end;

    // 19.08.2016 AH:
    if ("Mat.Verfügbar.Gew"<=0.0) and ("Mat.Verfügbar.Stk"<=0) then CYCLE;


    // 24.08.2016 AH:
    if (Mat.Auftragsnr<>0) then CYCLE;
    if (Mat.Status>c_Status_bisfrei) and (Mat.Status<>c_Status_EKWE) and (Mat.Status<>c_Status_EkVsb) and (Mat.Status<>c_Status_EK_Konsi) and
      (Mat.STatus<>c_Status_Bestellt) then CYCLE;

    RecBufClear(203);
    Mat.R.Materialnr      # Mat.Nummer;
    "Mat.R.Stückzahl"     # "Mat.Verfügbar.Stk";
    Mat.R.Gewicht         # "Mat.Verfügbar.Gew";
    "Mat.R.Trägertyp"     # '';
    "Mat.R.TrägerNummer1" # 0;
    "Mat.R.TrägerNummer2" # 0;
    Mat.R.Kundennummer    # Auf.P.Kundennr;
    Mat.R.KundenSW        # Auf.P.KundenSW;
    Mat.R.Auftragsnr      # Auf.P.Nummer;
    Mat.R.AuftragsPos     # Auf.P.Position;
    if (Mat_Rsv_Data:Neuanlegen()=false) then begin
      TRANSBRK;
      Msg(203010,aint(Mat.Nummer),0,0,0);
      RETURN;
    end;
  END;

  TRANSOFF;


  App_Main:Refresh();
  Msg(999998,'',0,0,0);

end;


//========================================================================
// RecalcAllMats
//      Reservierungen aller Materialkarten neu errechnen
//========================================================================
sub RecalcAllMats()
local begin
  Erx : int;
end;
begin
  // Material loopen...
  FOR Erx # RecRead(200,1,_recFirst)
  LOOP Erx # RecRead(200,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (RecLinkInfo(203,200,13,_recCount)=0) then begin
      If (Mat.Reserviert.Gew<>0.0) or (Mat.Reserviert.Menge<>0.0) or (Mat.Reserviert.Stk<>0) then begin
        Erx # RecRead(200,1,_recLock);
        Mat.Reserviert.Gew    # 0.0;
        Mat.Reserviert.Menge  # 0.0;
        Mat.Reserviert.Stk    # 0;
        Erx # RekReplace(200);
      end;
      CYCLE;
    end;
    
    RecalcAll();
  END;
  
  Msg(999998,'',0,0,0);
end;


//========================================================================
//========================================================================