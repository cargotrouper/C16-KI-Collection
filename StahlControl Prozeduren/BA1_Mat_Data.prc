@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Mat_Data
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  05.01.2010  AI  Versand ist gleich VSB
//  25.10.2010  AI  BruttoNetto für LFA-Reservierung
//  19.01.2011  AI  Karten, die komplett gefahren werden bekommen anderen Status 702
//  11.04.2013  AI  MatMEH
//  26.03.2014  AH  "MatFreigeben" : Kein Abbruch, wenn Reseriverung nicht gefunden wurde
//  24.04.2014  AH  "MatFreigeben" : FMs aus BA kann man nicht löschen...AUSSER
//  21.05.2014  AH  "MatFreigen" : ...bei Fahren
//  20.10.2014  AH  MatSofortInAblage
//  05.05.2017  AH  "BildeFahrRest"
//  09.11.2017  AH  AFX "BA1_Mat_Einsetzen.Post" und "BA1_Mat_Freigeben.Post"
//  17.01.2018  ST  Arbeitsgang "Umlagern" hinzugefügt
//  18.02.2020  AH  Fix: "VSBEinsetzen" setzt Mat.R.Bemerkung
//  07.12.2020  AH  Mat.Status-Setzen dirket per RekRepalce statt Mat.Replace
//  15.09.2021  AH  ERX
//  15.09.2021  AH  AFX "BAG.I.VSB.Freigeben.Post"
//  2022-07-05  AH  DEADLOCK
//
//  Subprozeduren
//    SUB StatusLautEinsatz(aAktion : alpha; aAufNr : int) : int;
//    SUB MatEinsetzen() : logic;
//    SUB MatFreigeben() : logic;
//    SUB VSBEinsetzen() : logic;
//    SUB VSBFreigeben() : logic;
//    SUB MinderReservierung(aAufNr  : int;  aAufPos : int;  aKunde : int; aStk    : int;  aGew    : float);
//    SUB BildeFahrRest(aEinsatzMat : int; aDat : date) : int;
//
//========================================================================
@I:def_Global
@I:Def_BAG
@I:def_Aktionen

define begin
end;


//========================================================================
//  StatusLautEinsatz
//
//========================================================================
sub StatusLautEinsatz(aAktion : alpha; aAufNr : int) : int;
begin
  case aAktion of
    c_BAG_Spalt   :   RETURN 701;
    c_BAG_Tafel   :   RETURN 702;
    c_BAG_Fahr    :   RETURN 703;

    c_BAG_Walz    :   RETURN 704;
    c_BAG_Gluehen,c_BAG_Obf     :   RETURN 705;
    c_BAG_Kant    :   RETURN 706;
    c_BAG_Pack    :   RETURN 707;
    c_BAG_QTeil   :   RETURN 708;
    c_BAG_Check   :   RETURN 709;
    c_BAG_Split   :   RETURN 710;

// 08.11.2021 AH hier war was verdreht !
    c_BAG_AbCoil  :   RETURN 711;
    c_BAG_Paket   :   RETURN 712;
    c_BAG_Messen  :   RETURN 713;

   // 05.01.2010
    c_BAG_Versand : begin
//   18.11.2021 AH IMMER 712     if (BAG.P.ZielVerkaufYN=false) then
                      RETURN 713;   // 08.11.2021 AH war 712?? = PAKET
      if (aAufNr=0) then
                      RETURN c_Status_BAGOutFertig; // freies Lagermatrial
      else
                      RETURN c_Status_BAGOutKunde; // kommissioniert
    end;

    c_BAG_VSB     : if (aAufNr=0) then
                      RETURN c_Status_BAGOutFertig; // freies Lagermatrial
                    else
                      RETURN c_Status_BAGOutKunde; // kommissioniert

    c_BAG_Bereit  :   RETURN 715;
    c_BAG_Saegen  :   RETURN 716;   // 2022-12-13 AH
  end;

  RETURN 700;
end;


//========================================================================
//  MatEinsetzen
//
//========================================================================
sub MatEinsetzen() : logic;
local begin
  Erx       : int;
  vEinsatz  : int;
  vRest     : int;
  vBuf703   : int;
  vDat      : date;
  vTim      : time;
end;
begin DoLogProc;

  vDat # today;
  vTim # now;

  // Einsatzmaterial holen...
  Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
  if (Erx<>200) then RETURN false;

  vEinsatz # Mat.Nummer;

  // VERSAND ---------------------------------------------------------------
  if (BAG.P.Aktion=c_BAG_Versand) then begin
    BAG.IO.MaterialRstNr  # vEinsatz;

    // nur Status setzen...
    Erx # RecRead(200,1,_reCLock);
    if (erx<>_rOK) then RETURN false;
    Mat_Data:SetStatus(StatusLautEinsatz(BAG.P.Aktion,BAG.P.Auftragsnr));
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');  // 07.12.2020 AH Proj. 2151/45 /  26.02.2021 AH: ZURÜCK !!!
    if (Erx<>_rOK) then RETURN false;

    // MatAktion anlegen...
    RecBufClear(204);
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Entstanden    # 0;
    Mat.A.Aktionstyp    # c_Akt_BA_Einsatz;
    Mat.A.Aktionsnr     # BAG.IO.Nummer;
    Mat.A.Aktionspos    # BAG.IO.NachPosition;
    Mat.A.Aktionspos2   # BAG.IO.NachFertigung;
    Mat.A.Aktionsdatum  # vDat;
    Mat.A.Aktionszeit   # vTim;
    Mat.A.Bemerkung     # c_AktBem_BAEinsatz;
    Erx # Mat_A_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then RETURN false;

    RETURN true;
  end;


  // FAHREN ----------------------------------------------------------------
  // TODO or ArG.Typ.ReservInput if (ArG.Aktion2<>BAG.P.Aktion2) then Erx # RecLink(828,702,8,_recFirst);
  if (BA1_P_Data:ReservierenStattStatus(BAG.P.Aktion,701)) then begin

    // FAHR-Reservierung neu anlegen ...
    vBuf703 # RecBufCreate(703);
    Erx # RecLink(vBuf703,702,4,_recFirst);   // 1. Fertigung holen
    if (Erx>_rLocked) then RecBufClear(vBuf703);

    Erx # RecLink(818,200,10,_recfirst);  // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;

    RecBufClear(203);
    Mat.R.Materialnr      # BAG.IO.Materialnr;
    "Mat.R.Stückzahl"     # BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk;
    if (VWa.NettoYN) then
      Mat.R.Gewicht         # BAG.IO.Plan.Out.GewN - BAG.IO.Ist.Out.GewN
    else
      Mat.R.Gewicht         # BAG.IO.Plan.Out.GewB - BAG.IO.Ist.Out.GewB;

    // für MATMEH
    if (Mat.MEH=BAG.IO.MEH.Out) then
      Mat.R.Menge         # BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge
    else
      Mat.R.Menge         # Lib_Einheiten:WandleMEH(701, "Mat.R.Stückzahl", Mat.R.Gewicht, BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge, BAG.IO.MEH.Out, Mat.MEH);


    Mat.R.Bemerkung       # BAG.P.Aktion;
    "Mat.R.Trägertyp"     # c_Akt_BAInput;
    "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
    "Mat.R.TrägerNummer2" # BAG.IO.ID;
    if (vBuf703->BAG.F.Kommission<>'') then begin
      Mat.R.Kommission    # vBuf703->BAG.F.Kommission;
      Mat.R.Auftragsnr    # vBuf703->BAG.F.Auftragsnummer;
      Mat.R.Auftragspos   # vBuf703->BAG.F.Auftragspos;
      Mat.R.Kundennummer  # vBuf703->"BAG.F.ReservFürKunde";
      Erx # RecLink(100,203,3,_recfirst);   // Kunde holen
      if (Erx<=_rLocked) then
        Mat.R.KundenSW    # Adr.Stichwort;
    end;
    RecBufDestroy(vBuf703);
    if (Mat_Rsv_Data:Neuanlegen()=false) then RETURN false;
    BAG.IO.MaterialRstNr  # BAG.IO.Materialnr;
//debugx('KEY200 '+aint(Mat.Bestand.Stk)+'/'+aint("Mat.R.Stückzahl")+' '+anum(Mat.Bestand.Gew,2)+'/'+anum("Mat.R.Gewicht",2));
    // ggf. komplette Karte auf "zum Fahren" setzen
    RecRead(200,1,0);
//    if ("Mat.Verfügbar.Stk"<=0) and ("Mat.Verfügbar.Gew"<=0.0) then begin 03.11.2021 AH einzige Res:
    if (Mat.Bestand.Stk<="Mat.R.Stückzahl") and (Mat.Bestand.Gew<="Mat.R.Gewicht") then begin
//      (RecLinkInfo(203,200,13,_recCount)=1) then begin    2022-06-23  AH: 2352/21
      if (BAG.P.Aktion=c_BAG_Fahr09) then begin
        Erx # RecRead(200,1,_reCLock);
        if (erx<>_rOK) then RETURN false;
        Mat_Data:SetStatus(c_Status_BAGZumFahren);
        Erx # Mat_Data:Replace(_recUnlock,'AUTO');  // 07.12.2020 AH Proj. 2151/45 /  26.02.2021 AH: ZURÜCK !!!
        if (Erx<>_rOK) then RETURN false;
      end;
      else if (BAG.P.Aktion=c_BAG_Bereit) then begin
        Erx # RecRead(200,1,_reCLock);
        if (erx<>_rOK) then RETURN false;
        Mat_Data:SetStatus(c_Status_BAGBereitgestellt);
        Erx # Mat_Data:Replace(_recUnlock,'AUTO');
        if (Erx<>_rOK) then RETURN false;
      end;;
    end;

    RETURN true;
  end;

  // OTHERWISE -------------------------------------------------------------
  // Einsatz kopieren...

  vRest # Lib_Nummern:ReadNummer('Material');
  if (vRest<>0) then begin
    Lib_Nummern:SaveNummer()
  end
  else begin
    RETURN false;
  end;
  Mat.Nummer        # vRest;
  "Mat.Vorgänger"   # vEinsatz;

  // Restkarte setzen
  Mat_Data:SetStatus(StatusLautEinsatz(BAG.P.Aktion,BAG.P.Auftragsnr));

  Erx # Mat_Data:Insert(0,'AUTO', vDat);
  if (Erx<>_rOK) then RETURN false;

  // AF kopieren
  Mat.Nummer  # vEinsatz;
  RecRead(200,1,0);
  if (Mat_Data:CopyAF(vRest)=false) then RETURN false;
  Mat.Nummer  # vRest;
  RecRead(200,1,0);

  // BAG.IO setzen ---------------------------------------------------------
  BAG.IO.MaterialRstNr  # vRest;

  // Einsatz löschen -------------------------------------------------------
  Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
  if (Erx<>200) then RETURN false;

  // ggf. Reservierungen übernehmen ----------------------------------------
  // 17.02.2010  AI
// If ("BAG.P.Typ.1In-1OutYN") and (RecLinkInfo(203,200,13,_recCount)>0) then begin
  Erx # RecLink(203,200,13,_recfirst | _recLock);
  if (Erx=_rLocked) or (Erx=_rDeadlock) then RETURN false;
  WHILE (Erx<_rLockeD) do begin
    Mat.R.Materialnr # vRest;
    Erx # RekReplace(203,_recUnlock,'AUTO');
    if (Erx<>_rOK) then RETURN false;
    Erx # RecLink(203,200,13,_recfirst | _recLock);
    if (Erx=_rLocked) or (Erx=_rDeadlock) then RETURN false;
  END;

  Erx # RecLink(200,701,11,_recFirst);  // Rest holen
  if (Erx<>_rOK) then RETURN false;
  if (Mat_Rsv_Data:RecalcAll()=false) then RETURN false;


  Erx # Mat_Data:Read(BAG.IO.Materialnr); // EINSATZMaterial holen
  if (Mat_Rsv_Data:RecalcAll()=false) then RETURN false;

  // Materialaktion setzen -------------------------------------------------
  RecBufClear(204);
  Mat.A.Aktionsmat    # Mat.Nummer;
  Mat.A.Entstanden    # 0;
  Mat.A.Aktionstyp    # c_Akt_BA_Einsatz;
  Mat.A.Aktionsnr     # BAG.IO.Nummer;
  Mat.A.Aktionspos    # BAG.IO.NachPosition;
  Mat.A.Aktionspos2   # BAG.IO.NachFertigung;
  Mat.A.Aktionsdatum  # vDat;
  Mat.A.Aktionszeit   # vTim;
  Mat.A.Bemerkung     # c_AktBem_BAEinsatz;
  Erx # Mat_A_Data:Insert(0,'AUTO');
  if (erx<>_rOK) then RETURN false;

  RecBufClear(204);
  Mat.A.Aktionsmat    # Mat.Nummer;
  Mat.A.Entstanden    # vRest;
  Mat.A.Aktionstyp    # c_Akt_BA_Rest;
  Mat.A.Aktionsnr     # BAG.IO.Nummer;
  Mat.A.Aktionspos    # BAG.IO.NachPosition;
  Mat.A.Aktionspos2   # BAG.IO.NachFertigung;
  Mat.A.Aktionsdatum  # vDat;
  Mat.A.Aktionszeit   # vTim;
  Mat.A.Bemerkung     # c_AktBem_BARest;
  Erx # Mat_A_Data:Insert(0,'AUTO');
  if (erx<>_rOK) then RETURN false;



  // Einsatz nullen
  if ("Set.BA.Input!NullYN"=false) then begin
    if (Mat_Data:Bestandsbuch(-Mat.Bestand.Stk, -Mat.Bestand.Gew, 0.0, 0.0, 0.0, c_AKt_BA+' '+AInt(BAG.IO.Nummer)+'/'+AInt(BAG.IO.ID), vDat, vTim, c_akt_BA_Einsatz, BAG.IO.Nummer, BAG.IO.ID)=false) then
      RETURN false;
    Erx # RecRead(200,1,_recLock);
    if (erx<>_rOK) then RETURN false;
    Mat.Gewicht.Netto   # 0.0;
    Mat.Gewicht.Brutto  # 0.0;
    Mat.Bestand.Stk     # 0;
    Mat.Bestand.Gew     # 0.0;
    Mat.Bestand.Menge   # 0.0;
  end
  else begin
    Erx # RecRead(200,1,_recLock);
    if (erx<>_rOK) then RETURN false;
  end;
  if (erx<>_rOK) then RETURN false;
  Mat.Ausgangsdatum   # today;
  Mat_Data:SetLoeschmarker('*');
  Erx # Mat_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then RETURN false;

  RunAFX('BA1_Mat_Einsetzen.Post','');

  RETURN true;
end;


//========================================================================
//  MatFreigeben
//
//========================================================================
sub MatFreigeben() : logic;
local begin
  Erx       : int;
  vAltMat   : int;
  vGew      : float;
  vM        : float;
end;
begin DoLogProc;

  if (BAG.IO.MaterialRstNr=0) then RETURN false;

  // 24.04.2014 AH : FMs aus BA kann man nicht löschen!!!
  // 21.05.2014 AH : ausser bei Fahren...?
  if (BAG.P.Aktion<>c_BAG_Fahr09) and (BAG.IO.VonBAG<>0) then RETURN false;

  // Rest holen
  Erx # Mat_Data:Read(BAG.IO.MaterialRstNr,0,0, false);
  if (Erx<>200) then RETURN false;

  // VERSAND------------------------------------------------------------
  if (BAG.P.Aktion=c_BAG_Versand) then begin
    if ("Mat.Löschmarker"<>'') then RETURN false;
    if (Mat.VK.RechNr<>0) then RETURN false;
// 08.12.2016    if (Mat.VK.Kundennr<>0) then RETURN false;

    // Einsatz-Aktion löschen...
    RecBufClear(204);
    Erx # RecLink(204,200,14,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      if (Mat.A.Entstanden=0) and (Mat.A.Aktionstyp=c_Akt_BA_Einsatz) and
        (Mat.A.Aktionsnr=BAG.IO.Nummer) and (Mat.A.Aktionspos=BAG.IO.NachPosition) and
        (Mat.A.Aktionspos2=BAG.IO.NachFertigung) then begin
        Erx # RekDelete(204,0,'AUTO');
        if (erx<>_rOK) then RETURN false;
        Erx # RecLink(204,200,14,_recfirst);
        CYCLE;
      end;

      Erx # RecLink(204,200,14,_recNExt);
    END;

    // Status im Einsatz setzen...
    Erx # RecRead(200,1,_recLock);
    if (Erx<>_rOK) then RETURN false;
    if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
// 26.07.2021  AHJ ?????      Mat_Data:SetStatus(c_STatus_EKVSB)       // wieder VSB-EK machen
    end
    else
      Mat_Data:SetStatus(c_STatus_Frei);        // wieder verfügbar machen
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');  // 07.12.2020 AH Proj. 2151/45 /  26.02.2021 AH: ZURÜCK !!!
    if (erx<>_rOK) then RETURN false;

    RETURN true;
  end;  // Versand

  // FAHREN ------------------------------------------------------------
  // TODO or ArG.Typ.ReservInput if (ArG.Aktion2<>BAG.P.Aktion2) then Erx # RecLink(828,702,8,_recFirst);
  if (BA1_P_Data:ReservierenStattStatus(BAG.P.Aktion,701))  then begin

    // FAHR-Reservierung löschen...
    Erx # RecLink(203,200,13,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if ("Mat.R.Trägertyp"=c_Akt_BAInput) and ("Mat.R.TrägerNummer1"=BAG.IO.Nummer) and
        ("Mat.R.TrägerNummer2"=BAG.IO.ID) then BREAK;
      Erx # RecLink(203,200,13,_recNext);
    END;
    // 26.03.2014 AH: Hier war ABBRUCH, wenn keine Res. gefunden wurde
    if (Erx<=_rLocked) then begin
      if (Mat_Rsv_Data:Entfernen()=false) then RETURN false;
    end;

    BAG.IO.MaterialRstNr  # 0;

    // ggf. Status "zum Fahren" löschen...
    RecRead(200,1,0);
    if (Mat.Status=c_Status_BAGZumFahren) or (Mat.Status=c_Status_BAGBereitgestellt) then begin
      Erx # RecRead(200,1,_reCLock);
      if (erx<>_rOK) then RETURN false;
      if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
// 26.07.2021 AH ???        Mat_Data:SetStatus(c_Status_EKVSB);      // wieder VSB-EK machen
      end
      else begin
        if (Mat.Auftragsnr=0) then
          Mat_Data:SetStatus(c_STatus_Frei)     // komplett freies Material
        else
          Mat_Data:SetStatus(c_STatus_VSB);     // VSB für Kundenauftrag
      end;

      Erx # Mat_Data:Replace(_recUnlock,'AUTO');  // 07.12.2020 AH Proj. 2151/45 /  26.02.2021 AH: ZURÜCK !!!
      if (Erx<>_rOK) then RETURN false;
    end;

    RETURN true;
  end;

  // OTHERWISE ---------------------------------------------------------

  // Restkarte auf Aktionen testen...
  if (RecLinkInfo(204,200,14,_reccount)>0) then RETURN false;

  if ("Mat.Löschmarker"<>'') then RETURN false;
  if (Mat.VK.RechNr<>0) then RETURN false;
// 08.12.2016  if (Mat.VK.Kundennr<>0) then RETURN false;

  // Einsatz-Materialaktion löschen ----------------------------------------
  Erx # Mat_Data:Read(BAG.IO.Materialnr,0,0,true); // Material holen
  if (Erx<>200) then RETURN false;

  RecBufClear(204);
  Erx # RecLink(204,200,14,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Mat.A.Entstanden=0) and (Mat.A.Aktionstyp=c_Akt_BA_Einsatz) and
      (Mat.A.Aktionsnr=BAG.IO.Nummer) and (Mat.A.Aktionspos=BAG.IO.NachPosition) and
      (Mat.A.Aktionspos2=BAG.IO.NachFertigung) then begin
      Erx # RekDelete(204,0,'AUTO');
      if (erx<>_rOK) then RETURN false;
      Erx # RecLink(204,200,14,_recfirst);
      CYCLE;
    end;

    if (Mat.A.Entstanden=BAG.IO.MaterialRstnr) and (Mat.A.Aktionstyp=c_Akt_BA_Rest) and
      (Mat.A.Aktionsnr=BAG.IO.Nummer) and (Mat.A.Aktionspos=BAG.IO.NachPosition) and
      (Mat.A.Aktionspos2=BAG.IO.NachFertigung) then begin
      Erx # RekDelete(204,0,'AUTO');
      if (erx<>_rOK) then RETURN false;
      Erx # RecLink(204,200,14,_recfirst);
      CYCLE;
    end;

    Erx # RecLink(204,200,14,_recNExt);
  END;

  // Einsatz reaktivieren --------------------------------------------------
  RecBufClear(202);
  "Mat.B.Trägertyp"       # c_Akt_BA_Einsatz;
  "Mat.B.Trägernummer1"   # BAG.IO.Nummer;
  "Mat.B.Trägernummer2"   # BAG.IO.ID;
  Erx # RecRead(202,3,0);   // Bestandsbuch lesen
  if (Erx<=_rMultikey) then begin
    vGew  # -Mat.B.Gewicht;
    vM    # -Mat.B.Menge;
    Erx # RekDelete(202,0,'AUTO');
    if (erx<>_rOK) then RETURN false;
  end;

  Erx # RecRead(200,1,_recLock);
  if (erx<>_rOK) then RETURN false;
  Mat.Ausgangsdatum   # 0.0.0;
  if (vGew<>0.0) then begin
    Mat.Gewicht.Netto   # BAG.IO.Ist.In.GewN;
    Mat.Gewicht.Brutto  # BAG.IO.Ist.In.GewB;
    Mat.Bestand.Stk     # BAG.IO.Ist.In.Stk;
    Mat.Bestand.Gew     # vGew;
    Mat.BEstand.Menge   # vM;
  end;
  Mat_Data:SetLoeschmarker('');
  Erx # Mat_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then RETURN false;

  vAltMat # Mat.Nummer;

  // Restkarte löschen -----------------------------------------------------
  Erx # RecLink(200,701,11,_recFirst);
  if (Erx<>_rOK) then RETURN false;

  // ggf. Reservierungen zurück-übernehmen ---------------------------------
  Erx # RecLink(203,200,13,_recfirst | _recLock);
  if (erx=_rLocked) or (erx=_rDeadLock) then RETURN false;
  WHILE (Erx<_rLockeD) do begin
    Mat.R.Materialnr # vAltMat;
    Erx # RekReplace(203,_recUnlock,'AUTO');
    if (erx<>_rOK) then RETURN false;
    Erx # RecLink(203,200,13,_recfirst | _recLock);
    if (erx=_rLocked) or (erx=_rDeadLock) then RETURN false;
  END;

  Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
  if (Mat_Rsv_Data:RecalcAll()=false) then RETURN false;

  Erx # RecLink(200,701,11,_recFirst);  // Rest holen
  if (Erx<>_rOK) then RETURN false;
  if (Mat_Rsv_Data:RecalcAll()=false) then RETURN false;

  // Bei LFA den Eintrag aus dem LFS nehmen...
  if (BAG.P.Aktion=c_BAg_Fahr) then begin
    Erx # RecLink(441,200,27,_recFirst);
    WHILE (Erx<=_rLocked) do begin        // Lfs.Positionen loopen
      Erx # RecLink(440,441,1,_RecFirst); // Lfs.Kopf holen
      if (Erx>_rLocked) or ("Lfs.Löschmarker"='*') or (Lfs.Datum.Verbucht<>0.0.0) or (Lfs.P.Datum.Verbucht<>0.0.0) then begin
        RETURN false;
      end;
      Erx # RekDelete(441,0,'AUTO');
      if (erx<>_rOK) then RETURN false;

      Erx # RecLink(441,200,27,_recFirst);
    END;
  end;

  Erx # Mat_Data:Delete(0,'AUTO');
  if (erx<>_rOK) then RETURN false;

  RunAFX('BA1_Mat_Freigeben.Post','');

  // BAG.IO setzen ---------------------------------------------------------
  BAG.IO.MaterialRstNr  # 0;

  RETURN true;

end;


//========================================================================
//  VSBEinsetzen
//
//========================================================================
sub VSBEinsetzen() : logic;
local begin
  Erx       : int;
  vBuf703 : int;
  vBuf100 : int;
end;
begin DoLogProc;

  // Einsatz holen
  Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
  if (Erx<>200) then RETURN false;

  if (BAG.IO.Plan.In.Stk<=0) and (BAG.IO.Plan.In.GewN<=0.0) then RETURN true;

  Erx # RecLink(818,200,10,_recfirst);  // Verwiegungsart holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  // Reservierung neu anlegen --------------------------------------------
  RecBufClear(203);
  Mat.R.Materialnr      # Mat.Nummer;
  "Mat.R.Stückzahl"     # BAG.IO.Plan.Out.Stk;
  if (VWa.NettoYN) then
    Mat.R.Gewicht         # BAG.IO.Plan.Out.GewN
  else
    Mat.R.Gewicht         # BAG.IO.Plan.Out.GewB;
  "Mat.R.Trägertyp"     # c_Akt_BAInput;
  "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
  "Mat.R.TrägerNummer2" # BAG.IO.ID;

    // FAHREN ----------------------------------------------------------------
  if (BA1_P_Data:ReservierenStattStatus(BAG.P.Aktion,701)) then begin
    Mat.R.Bemerkung       # BAG.P.Aktion;   // 18.02.2020
  end;

  if (Mat_Rsv_Data:Neuanlegen()=false) then begin
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  VSBFreigeben
//
//========================================================================
sub VSBFreigeben() : logic;
local begin
  Erx : int;
end;
begin DoLogProc;

  // Einsatz holen
  Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
  if (Erx<200) then RETURN false;

  // kein VSB??
  //if (Mat.Status<>c_Status_EK_Storno) and
  if (Mat.Status<>c_Status_EKVSB) and (Mat.Status<>c_status_EK_Ausfall) and (Mat.Status<>c_Status_EK_Konsi) then RETURN false;

  // Reservierung suchen und löschen -------------------------------------
  RecBufClear(203);
//  Mat.R.Materialnr      # Mat.Nummer;
  "Mat.R.Trägertyp"     # c_Akt_BAInput;
  "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
  "Mat.R.TrägerNummer2" # BAG.IO.ID;
//  Erx # Recread(203,5,0);
  Erx # Recread(203,7,0);     // 10.02.2020 AH: WE auf VSB übernimmt schon LFA-Reservierung d.h. Mat.Nummer ist verändert!!!
  // nicht gefunden??
  if (Erx>_rMultikey) then RETURN true;
  if (Mat_Rsv_Data:Entfernen()=false) then RETURN false;

  RunAFX('BAG.I.VSB.Freigeben.Post','');

  RETURN true;
end;


//========================================================================
//  MinderReservierung
//
//========================================================================
sub MinderReservierung(
  aAufNr  : int;
  aAufPos : int;
  aKunde  : int;
  aStk    : int;
  aGew    : float;
) : logic;
local begin
  Erx : int;
end;
begin DoLogProc;

  // ggf. vorhandene Reservierungen mindern...
  if (aAufNr<>0) then begin
    Erx # RecLink(203,200,13,_RecFirst);    // bisherige Mat.Reservierungen loopen
    WHILE (Erx<=_rLocked) and ((aStk>0) or (aGew>0.0)) do begin

      if ("Mat.R.Trägertyp"='') and
        (Mat.R.Auftragsnr=aAufNr) and (Mat.R.Auftragspos=aAufPos) then begin
        Erx # RecRead(203,1,_recLock);
        if (erx<>_rOK) then RETURN false;
        if (aStk>"Mat.R.Stückzahl") then begin
          aStk # aStk - "Mat.R.Stückzahl";
          "Mat.R.Stückzahl" # 0;
        end
        else begin
          "Mat.R.Stückzahl" # "Mat.R.Stückzahl" - aStk;
          aStk # 0;
        end;
        if (aGew>Mat.R.Gewicht) then begin
          aGew # aGew - Mat.R.Gewicht;
          Mat.R.Gewicht # 0.0;
        end
        else begin
          Mat.R.Gewicht # Mat.R.Gewicht - aGew;
          aGew # 0.0;
        end;
        if (Mat.R.Gewicht<=0.0) and ("Mat.R.Stückzahl"<=0) then begin
          RecRead(203,1,_recunlock);
          if (Mat_Rsv_Data:Entfernen()=false) then RETURN false;
          Erx # RecLink(203,200,13,_RecFirst);
          CYCLE;
        end
        else begin
          if (Mat_Rsv_Data:Update()=false) then RETURN false;
        end;
      end;

      Erx # RecLink(203,200,13,_RecNext);
    END;
  end

  if (aKunde<>0) then begin
    Erx # RecLink(203,200,13,_RecFirst);    // bisherige Mat.Reservierungen loopen
    WHILE (Erx<=_rLocked) and ((aStk>0) or (aGew>0.0)) do begin

      if ("Mat.R.Trägertyp"='') and
        (Mat.R.Auftragsnr=0) and (Mat.R.Kundennummer=aKunde) then begin
        Erx # RecRead(203,1,_recLock);
        if (erx<>_rOK) then RETURN false;
        
        if (aStk>"Mat.R.Stückzahl") then begin
          aStk # aStk - "Mat.R.Stückzahl";
          "Mat.R.Stückzahl" # 0;
        end
        else begin
          "Mat.R.Stückzahl" # "Mat.R.Stückzahl" - aStk;
          aStk # 0;
        end;
        if (aGew>Mat.R.Gewicht) then begin
          aGew # aGew - Mat.R.Gewicht;
          Mat.R.Gewicht # 0.0;
        end
        else begin
          Mat.R.Gewicht # Mat.R.Gewicht - aGew;
          aGew # 0.0;
        end;
        if (Mat.R.Gewicht<=0.0) and ("Mat.R.Stückzahl"<=0) then begin
          RecRead(203,1,_recunlock);
          if (Mat_Rsv_Data:Entfernen()=false) then RETURN false;
          Erx # RecLink(203,200,13,_RecFirst);
          CYCLE;
        end
        else begin
          if (Mat_Rsv_Data:Update()=false) then RETURN false;
        end;
      end;

      Erx # RecLink(203,200,13,_RecNext);
    END;
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub BildeFahrRest(
  aEinsatzMat : int;
  aDat        : date;
  aTim        : time) : int;
local begin
  Erx   : int;
  vRest : int;
end;
begin
  vRest # Lib_Nummern:ReadNummer('Material');
  if (vRest<>0) then begin
    Lib_Nummern:SaveNummer()
  end
  else begin
    RETURN -1;
  end;
  Mat.Nummer        # vRest;
  "Mat.Vorgänger"   # aEinsatzMat;

  // Restkarte setzen
  Mat_Data:SetStatus(StatusLautEinsatz(BAG.P.Aktion,BAG.P.Auftragsnr));

  Erx # Mat_Data:Insert(0,'AUTO', today);
  if (Erx<>_rOK) then RETURN -1;

  // AF kopieren
  Mat.Nummer  # aEinsatzMat;
  RecRead(200,1,0);
  if (Mat_Data:CopyAF(vRest)=false) then RETURN -1;

  // Materialaktion setzen -------------------------------------------------
  RecBufClear(204);
  Mat.A.Aktionsmat    # aEinsatzMat;
  Mat.A.Entstanden    # vRest;
  Mat.A.Aktionstyp    # c_Akt_BA_Rest;
  Mat.A.Aktionsnr     # BAG.IO.Nummer;
  Mat.A.Aktionspos    # BAG.IO.NachPosition;
  Mat.A.Aktionspos2   # BAG.IO.NachFertigung;
  Mat.A.Aktionsdatum  # aDat
  Mat.A.Aktionszeit   # aTim;
  Mat.A.Bemerkung     # c_AktBem_BARest;

  "Mat.A.Stückzahl"   # Mat.Bestand.Stk;
  Mat.A.Gewicht       # Mat.Bestand.Gew;
  Erx # Mat_A_Data:Insert(0,'AUTO');
  if (erx<>_rOK) then RETURN -1;


  // Einsatz nullen...
  if ("Set.BA.Input!NullYN"=false) then begin
    if (Mat_Data:Bestandsbuch(-Mat.Bestand.Stk, -Mat.Bestand.Gew, 0.0, 0.0, 0.0, c_AKt_BA+' '+AInt(BAG.IO.Nummer)+'/'+AInt(BAG.IO.ID), aDat, aTim, c_akt_BA_Einsatz, BAG.IO.Nummer, BAG.IO.ID)=false) then
      RETURN -1;
    Erx # RecRead(200,1,_recLock);
    if (erx<>_rOK) then RETURN -1;
    Mat.Gewicht.Netto   # 0.0;
    Mat.Gewicht.Brutto  # 0.0;
    Mat.Bestand.Stk     # 0;
    Mat.Bestand.Gew     # 0.0;
    Mat.Bestand.Menge   # 0.0;
  end
  else begin
    Erx # RecRead(200,1,_recLock);
    if (erx<>_rOK) then RETURN -1;
  end;
  Mat.Ausgangsdatum   # aDat;
//debugx('AUSGANG KEY200');
  Mat_Data:SetLoeschmarker('*');
  Erx # Mat_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then RETURN -1;

  // neuen Rest laden...
  Mat.Nummer  # vRest;
  RecRead(200,1,0);

  RETURN vRest;
end;


//========================================================================