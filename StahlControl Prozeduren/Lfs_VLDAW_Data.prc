@A+
//===== Business-Control =================================================
//
//  Prozedur    Lfs_VLDAW_Data
//                      OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  06.05.2010  AI  Artikel Reservierung wird benutzt
//  25.10.2010  AI  BruttoNetto
//  30.08.2012  ST  Bei Mat und Vsb Auftragskation für 209er Artikelnr mit in AufAktion (1326/287)
//  11.04.2013  AI  MatMEH
//  07.04.2015  AH  Auftrags-SL in Kommission aktiviert
//  22.10.2015  AH  RLFS
//  13.12.2016  AH  Liefern von freiem Material auf Kommission, setzt dieses erst VSB (Prj. 1586/69)
//  18.01.2018  ST  Arbeitsgang "Umlagern" integriert
//  05.07.2019  AH  AFX "Lfs.P.VLDAW.Verbuchen.Check"
//  27.07.2021  AH  ERX
//  28.06.2022  MR  AFX "Lfs.PreDruck.VLDAW"
//  2023-02-07  AH  Aktions-Termine verändert
//
//  Subprozeduren
//    SUB Nimm_von_VSB(aMenge : float; aStk : int; aNetto : float; aBrutto : float) : logic;
//    SUB Pos_VLDAW_Mat(aDelYN : logic; optaBuf441 : int) : alpha;
//    SUB Pos_VLDAW_VSBMat(aDelYN : logic; optaBuf441 : int) : alpha;
//    SUB Pos_VLDAW_Art(aDelYN : logic; optaBuf441 : int) : alpha;
//    SUB Pos_VLDAW_Verbuchen(aDelYN : logic; optaBuf441 : int) : alpha;
//    SUB Druck_VLDAW()
//    SUB Druck_LFA()
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG


//========================================================================
// Nimm_von_VSB +ERR
//          zieht (addiert) von den bisherigen VSB/MATZs ab
//========================================================================
sub Nimm_von_VSB(
  aMenge    : float;
  aStk      : int;
  aNetto    : float;
  aBrutto   : float;
  aArtikel  : alpha;
  aAdresse  : int;
  aAnschr   : int;
  aCharge   : alpha;
  ) : logic;
local begin
  Erx     : int;
  vOk     : logic;
  vMenge2 : float;
  vNet    : float;
  vBrut   : float;
  vStk    : int;
  vNr     : int;
  vPos1   : int;
  vPos2   : int;
  vDifStk : int;
  vDifM   : float;
end;
begin

  vNr   # Lfs.P.Auftragsnr;
  vPos1 # Lfs.P.Auftragspos;
  vPos2 # Lfs.P.Auftragspos2;

  // bisherige MATZ/Reservierung suchen
  RecbufClear(404);
  Auf.A.Aktionsnr     # vNr;
  Auf.A.AktionsPos    # vPos1;
  Auf.A.AktionsPos2   # vPos2;
  Auf.A.AktionsTyp    # c_Akt_VSB;
  Erx # RecRead(404,2,0);
  vMenge2 # aMenge;
  vNet    # aNetto;
  vBrut   # aBrutto;
  vStk    # aStk;

  if (aMenge>0.0) then begin

    WHILE ((Erx=_rOK) or (Erx=_rMultikey)) and (vMenge2>0.0) and
      (Auf.A.Aktionsnr=vNr) and (Auf.A.AktionsPos=vPos1) and (Auf.A.AktionsPos2=vPos2) and (Auf.A.AktionsTyp=c_Akt_VSB) do begin

      if (Auf.A.Menge>0.0) and ("Auf.A.Löschmarker"='') and
        (Auf.A.Artikelnr=aArtikel) and (Auf.A.Charge=aCharge) and (Auf.A.Charge.Adresse=aAdresse)  and (Auf.A.Charge.Anschr=aAnschr) then begin

        RecRead(404,1,_recLock);
        if (Auf.A.Menge<=vMenge2) then begin
          vMenge2     # vMenge2 - Auf.A.Menge;
          vNet        # vNet    - Auf.A.NettoGewicht;
          vBrut       # vBrut   - Auf.A.Gewicht;
          vStk        # vStk    - "Auf.A.Stückzahl";
          vDifM       # -Auf.A.Menge;
          vDifStk     # -"Auf.A.Stückzahl";
          Auf.A.Menge         # 0.0;
          Auf.A.Gewicht       # 0.0;
          Auf.A.NettoGewicht  # 0.0;
          "Auf.A.Stückzahl"   # 0;
        end
        else begin
          Auf.A.Menge         # Auf.A.Menge - vMenge2;
          Auf.A.Gewicht       # Auf.A.Gewicht - vBrut;
          Auf.A.NettoGewicht  # Auf.A.NettoGewicht - vNet;
          "Auf.A.Stückzahl"   # "Auf.A.Stückzahl" - vStk;
          vDifM       # -vMenge2;
          vDifStk     # -vStk;
          vMenge2     # 0.0;
          vNet        # 0.0;
          vBrut       # 0.0;
          vStk        # 0;
        end;
        if (Auf.A.MEH.Preis=Auf.A.MEH) then
          Auf.A.Menge.Preis # Auf.A.Menge
        else if (Auf.A.MEH.Preis='Stk') then
          Auf.A.Menge.Preis # cnvfi("Auf.A.Stückzahl")
        else if (Auf.A.MEH.Preis='kg') then
          Auf.A.Menge.Preis # Auf.A.Gewicht
        else if (Auf.A.MEH.Preis='t') then
          Auf.A.Menge.Preis # Auf.A.Gewicht / 1000.0
        else Auf.A.Menge.Preis # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);

        Erx # Rekreplace(404,_recUnlock,'AUTO');
        if (erx<>_rOK) then RETURN false;

        // 06.05.2010 AI
        if (Lfs.P.zuBA.Nummer<>0) then begin
          // Reservierung anpassen...
          vOK # Art_Data:Reservierung(Auf.A.Artikelnr, Auf.A.Charge.Adresse, Auf.a.Charge.Anschr, Auf.A.Charge, 0, c_Auf, Auf.A.Nummer, Auf.A.Position, Auf.A.Position2, vDifM, vDifStk, 0);
          if (vOK=false) then RETURN false;
        end;
      end;

      Erx # RecRead(404,2,_RecNext);
    END;

  end
  else begin

    WHILE ((Erx=_rOK) or (Erx=_rMultikey)) and (vMenge2<0.0) and
      (Auf.A.Aktionsnr=vNr) and (Auf.A.AktionsPos=vPos1) and (Auf.A.AktionsPos2=vPos2) and (Auf.A.AktionsTyp=c_Akt_VSB) do begin

      if ("Auf.A.Löschmarker"='') and (Auf.A.Artikelnr=aArtikel) and
        (Auf.A.Charge=aCharge) and (Auf.A.Charge.Adresse=aAdresse)  and (Auf.A.Charge.Anschr=aAnschr) then begin

        RecRead(404,1,_recLock);
        Auf.A.Menge         # Auf.A.Menge - vMenge2;
        Auf.A.Gewicht       # Auf.A.Gewicht - vBrut;
        Auf.A.NettoGewicht  # Auf.A.NettoGewicht - vNet;
        "Auf.A.Stückzahl"   # "Auf.A.Stückzahl" - vStk;
        vDifStk     # -vStk;
        vDifM       # -vMenge2;
        vMenge2     # 0.0;
        vNet        # 0.0;
        vBrut       # 0.0;
        vStk        # 0;

        if (Auf.A.MEH.Preis=Auf.A.MEH) then
          Auf.A.Menge.Preis # Auf.A.Menge
        else if (Auf.A.MEH.Preis='Stk') then
          Auf.A.Menge.Preis # cnvfi("Auf.A.Stückzahl")
        else if (Auf.A.MEH.Preis='kg') then
          Auf.A.Menge.Preis # Auf.A.Gewicht
        else if (Auf.A.MEH.Preis='t') then
          Auf.A.Menge.Preis # Auf.A.Gewicht / 1000.0
        else Auf.A.Menge.Preis # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);

        Erx # Rekreplace(404,_recUnlock,'AUTO');
        if (erx<>_rOK) then RETURN false;

        // 06.05.2010 AI
        if (Lfs.P.zuBA.Nummer<>0) then begin
          // Reservierung anpassen...
          vOK # Art_Data:Reservierung(Auf.A.Artikelnr, Auf.A.Charge.Adresse, Auf.a.Charge.Anschr, Auf.A.Charge, 0, c_Auf, Auf.A.Nummer, Auf.A.Position, Auf.A.Position2, vDifM, vDifStk, 0);
          if (vOK=false) then RETURN false;
        end;
      end;

      Erx # RecRead(404,2,_RecNext);
    END;

  end;

  if (vMenge2<>0.0) then RETURN false;

  Auf_A_Data:Recalcall();

  RETURN true;
end;


//========================================================================
// Pos_VLDAW_Mat  +ERR
//      1. VLDAW Auf- und Mat-Aktion anlegen (+VSAufMenge)
//   (2. kommi.Material von AuftragVSB abziehen)
//
//  deaktiviert AI 15.08.08:
//      x. ggf. bisherige Reservierung am Material löschen
//      x. neue Res. anlegen
//========================================================================
sub Pos_VLDAW_Mat(
  aDelYN      : logic;  // Satz löschen???
  opt aBuf441 : int;
) : logic;
local begin
  Erx           : int;
  vOk         : logic;
  vTyp        : alpha;
  vDifStk     : int;
  vDifEinsatz : float;
  vDifMenge   : float;
  vDifNetto   : float;
  vDifBrutto  : float;
  //vDifGewicht : float;
  vMatIstVSB  : logic;
  vMatInAbl   : logic;
end;
begin

  vTyp # c_Akt_VLDAW
  if ("Lfs.RücknahmeYN") then vTyp # c_AKT_RVLDAW;
  // Differenzen bei Edit errechnen
  if (aBuf441<>0) then begin
    vDifMenge   # Lfs.P.Menge           - aBuf441->Lfs.P.Menge;
    vDifEinsatz # Lfs.P.Menge.Einsatz   - aBuf441->Lfs.P.Menge.Einsatz;
    vDifStk     # "Lfs.P.Stück"         - aBuf441->"Lfs.P.Stück";
    vDifNetto   # Lfs.P.Gewicht.Netto   - aBuf441->Lfs.P.Gewicht.Netto;
    vDifBrutto  # Lfs.P.Gewicht.Brutto  - aBuf441->Lfs.P.Gewicht.Brutto;
  end;


//debug('lfs:'+aint(lfs.p.nummeR)+'/'+aint(lfs.p.position)+':'+aint(lfs.p.materialtyp)+' '+aint(lfs.p.materialnr));
  Erx # RecLink(200,441,4,_RecFirst);     // Material holen
  if (Erx>_rLocked) and ((aDelYN) or ("Lfs.RücknahmeYN")) then begin
    Erx # RecLink(210,441,12,_RecFirst);  // MaterialAblage holen
    if (Erx=_rOK) then begin
      vMatInAbl # y;
      RecBufCopy(210,200);
    end;
  end;
  if (Erx>_rLocked) then begin
//debug('B');
    Error(010001, AInt(Lfs.P.Position)+'|'+AInt(LFs.P.Materialnr));
    RETURN false;
  end;

  // Material prüfen***************************
//  if ("Mat.Löschmarker"='*') then begin
//    Error(010002, CnvAI(Lfs.P.Position)+'|'+CnvAI(Mat.Nummer));
//    RETURN false;
//  end;
  if (Lfs.P.Auftragsnr<>0) and (Mat.Auftragsnr<>0) and (Mat.AuftragsNr<>Lfs.P.Auftragsnr) then begin
    Error(010003, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
    RETURN false;
  end;

  // Löschen?????***********************************************************

  if (aDelYN=true) then begin
/***
    // Reservierung löschen...
    if (Lfs.P.ReservierungNr<>0) then begin
      Erx # RecLink(203,441,6,_RecFirst);   // Reservierung löschen
      if (Erx<>_rOK) then begin
        Error(010004, CnvAI(Lfs.P.Position)+'|'+CnvAI(Mat.Nummer));
        RETURN false;
      end;
      if (Mat_Rsv_Data:Entfernen()=false) then begin
        Error(010004, CnvAI(Lfs.P.Position)+'|'+CnvAI(Mat.Nummer));
        RETURN false;
      end;
    end;
***/

    // Materialstatus setzen...
    if (vMatInABL=n) then begin
//      if (Mat.Status<>c_Status_BAGRestFahren) then begin
      if (Mat.Status=c_Status_inVLDAW) then begin
        RecRead(200,1,_recLock);
        vMatIstVSB # Y;
        Mat_data:SetStatus(c_Status_VSB);
        Erx # Mat_data:Replace(_recunLock,'AUTO')
        if (erx<>_rOk) then begin
          Error(010002, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
          RETURN false;
        end;

      end
      else if (Mat.Status=c_Status_BAGzumFahren) then begin
      end

      else if (Mat.Status>=c_Status_BAG) and
        (Mat.Status<=c_Status_BAGOutput) then begin
        RecRead(200,1,_recLock);
        if (Mat.Auftragsnr<>0) then begin
          vMatIstVSB # Y;
          Mat_data:SetStatus(c_Status_VSB);
        end
        else begin
          Mat_data:SetStatus(c_Status_Frei);
        end;
        Erx # Mat_data:Replace(_recunLock,'AUTO')
        if (erx<>_rOk) then begin
          Error(010002, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
          RETURN false;
        end;
      end;
    end;


    // Mataktion löschen
    RecBufClear(204);
    Mat.A.AktionsTyp  # vTyp;
    Mat.A.Aktionsnr   # Lfs.P.Nummer;
    Mat.A.AktionsPos  # Lfs.P.Position;
    Erx # RecRead(204,2,0);
    if (Erx=_rOK) or (Erx=_rMultikey) then begin
      Erx # RekDelete(204,0,'AUTO');
      if (Erx<>_rOK) then begin
        Error(010017, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
        RETURN false;
      end;
    end;

    // ggf. Auftrags-Aktion löschen...
    RecBufClear(404);
    Auf.A.AktionsTyp  # vTyp;
    Auf.A.Aktionsnr   # Lfs.P.Nummer;
    Auf.A.AktionsPos  # Lfs.P.Position;
    Erx # RecRead(404,2,0);     // bisherige Aktion suchen...

    if (Erx<>_rNoRec) and (Auf.A.AktionsTyp=vTyp) and   // gibts schon?
        (Auf.A.Aktionsnr=Lfs.P.Nummer) and
        (Auf.A.AktionsPos=Lfs.P.Position) then begin

      if (vMatIstVSB=n) then begin
        // Auftragspos. updaten *****************
        RecLink(401,404,1,_recFirsT);   // Auf.Pos. holen
      end;

      if (Auf_A_Data:Entfernen()=false) then begin
        Error(010019, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
        RETURN false;
      end;

    end;  // Auftrag anpassen

    // Löschen Erfolg
    RETURN true;
  end;  // Löschen *********************************************************



  // Material anpassen *****************************************************
  Erx # RecLink(818,200,10,_recFirst);  // Verwiegungsart Material holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  if ("LFs.RücknahmeYN"=falsE) and (aBuf441=0) then begin // Materialstatus setzen...
    if (Lfs.P.zuBA.Nummer=0) and // Fahr09 2009
      ((Mat.Status<700) or (Mat.Status>799)) then begin

      // 13.12.2016 AH: Falls es freies Material ist, aber auf Kommission geliefert wwird, setze es hier VSB
      if (Lfs.P.Auftragsnr<>0) and (Mat.Auftragsnr=0) then begin
        Erx # Mat_data:SetKommission(Mat.Nummer, Lfs.P.Auftragsnr, Lfs.P.Auftragspos,0,'AUTO');
        if (Erx<>0) then begin
          Error(010007, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
          RETURN false;
        end;
      end;

      RecRead(200,1,_recLock);
      Mat_data:SetStatus(c_Status_inVLDAW);
      Erx # Mat_data:Replace(_recunLock,'AUTO')
      if (erx<>_rOK) then begin
        RecRead(200,1,_recUnlock);
        Error(010007, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
        RETURN false;
      end;
    end;
  end;


  if (aBuf441=0) then begin  // Mataktion neu anlegen
    RecBufClear(204);
    Mat.A.Materialnr    # Mat.Nummer;
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Aktionstyp    # vTyp;
    Mat.A.Aktionsnr     # Lfs.P.Nummer;
    Mat.A.Aktionspos    # Lfs.P.Position;
    Mat.A.Aktionsdatum  # today;
    Mat.A.TerminStart   # today;

    // 2023-02-07 AH  : war mal nur BFS, Proj. 2333/18/1
    Mat.A.TerminEnde    # today;
    if (Lfs.Lieferdatum<>0.0.0) then begin
      Mat.A.TerminStart   # Lfs.Lieferdatum;
      Mat.A.TerminEnde    # Lfs.Lieferdatum;
    end;
    if (Lfs.zuBA.Nummer<>0) and (BAG.P.Nummer=Lfs.zuBA.Nummer) and
      (BAG.P.Position=Lfs.zuBA.Position) then begin
      if (BAG.P.Plan.Startdat<>0.0.0) then
        Mat.A.TerminStart   # BAG.P.Plan.StartDat;
      if (BAG.P.Plan.Enddat<>0.0.0) then
        Mat.A.TerminEnde    # BAG.P.Plan.EndDat;
    end;
    
    Mat.A.Adressnr      # Lfs.Zieladresse;
    "Mat.A.Stückzahl"   # "Lfs.P.Stück";
    if (VWA.NettoYN) then
      Mat.A.Gewicht # Lfs.P.Gewicht.Netto
    else
      Mat.A.Gewicht # Lfs.P.Gewicht.Brutto;
    Mat.A.Nettogewicht  # Lfs.P.Gewicht.Netto;
    // für MATMEH
    if (Mat.MEH=Lfs.P.MEH) then
      Mat.A.Menge       # Lfs.P.Menge;

    Mat_A_Data:Insert(0,'AUTO');

    // Versandpool prüfen--------
    VsP_Data:LfsPos_Verbuchen();

  end
  else begin  // Mataktion updaten...

    RecBufClear(204);
    Mat.A.AktionsTyp  # vTyp;
    Mat.A.Aktionsnr   # Lfs.P.Nummer;
    Mat.A.AktionsPos  # Lfs.P.Position;
    Erx # RecRead(204,2,0);
    if (Erx=_rOK) or (Erx=_rMultikey) then begin
      RecRead(204,1,_recLock);
//      Mat.A.Aktionsdatum  # Auf.A.Aktionsdatum;
//      Mat.A.TerminStart   # Auf.A.TerminStart;
      Mat.A.Adressnr      # Lfs.Zieladresse;
      "Mat.A.Stückzahl"   # "Lfs.P.Stück";
      if (VWA.NettoYN) then
        Mat.A.Gewicht # Lfs.P.Gewicht.Netto
      else
        Mat.A.Gewicht # Lfs.P.Gewicht.Brutto;
      Mat.A.Nettogewicht  # Lfs.P.Gewicht.Netto;
      // 10.04.2013 VORLÄUFIG:
      Mat.A.Menge         # 0.0;

      Erx # RekReplace(204,_recUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        Error(010022, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
        RETURN false;
      end;
    end;
  end;

  // ENDE Material **************************************************************


  // Auftrag anpassen ******************************************************
  Erx # RecLink(401,441,5,_recfirst);   // Position holen
  if (Erx=_rLocked) then begin
    Error(010018, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr));
    RETURN false;
  end;
  Erx # RecLink(818,401,9,_recFirst);   // Verwiegungsart Auftrag holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;


  // Auftrags-Aktionn...
  RecBufClear(404);
  Auf.A.AktionsTyp  # vTyp;
  Auf.A.Aktionsnr   # Lfs.P.Nummer;
  Auf.A.AktionsPos  # Lfs.P.Position;

  Erx # RecRead(404,2,0);     // bisherige Aktion suchen...

  if (Erx<>_rNoRec) and (Auf.A.AktionsTyp=vTyp) and   // gibts schon?
      (Auf.A.Aktionsnr=Lfs.P.Nummer) and
      (Auf.A.AktionsPos=Lfs.P.Position) then begin

    // ÄNDERN.........................
    Erx # RecRead(404,1,_RecLock);
    if (Erx=_rLocked) then begin
      Error(010020, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      Error(010020,'Auftragsaktion');
      RETURN false;
    end;

//    Auf.A.Menge         # Auf.A.Menge + vDifMenge;//vDifEinsatz;
// 01.02.2017    Auf.A.Menge.Preis   # 0.0;//Auf.A.Menge.Preis + vDifMenge;
    Auf.A.Menge.Preis   # Auf.A.Menge.Preis + vDifMenge;  // 01.02.2017

    "Auf.A.Stückzahl"   # "Auf.A.Stückzahl" + vDifStk;
    Auf.A.Gewicht       # Auf.A.Gewicht + vDifBrutto;
    Auf.A.Nettogewicht  # Auf.A.Nettogewicht + vDifNetto;

//    if (VWa.NettoYN) then
//      Auf.A.Menge # Auf.A.Nettogewicht
//    else
//      Auf.A.Menge # Auf.A.Gewicht;
//    Auf.A.Menge.Preis   # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);
    case Auf.A.MEH of
      Lfs.P.MEH : Auf.A.Menge # Auf.A.Menge + vDifMenge;

      Lfs.P.MEH.Einsatz : Auf.A.Menge # Auf.A.Menge + vDifEinsatz;

      'kg'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge # Auf.A.Nettogewicht
        else
          Auf.A.Menge # Auf.A.Gewicht;
      end;

      't'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge # Rnd(Auf.A.Nettogewicht /1000.0,Set.Stellen.Menge)
        else
          Auf.A.Menge # Rnd(Auf.A.Gewicht / 1000.0, Set.Stellen.Menge);
      end;

      'Stk' : Auf.A.Menge # cnvfi("auf.A.Stückzahl");

      otherwise
        Auf.A.Menge # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, 0.0, '', Auf.A.MEH);

    end;  // Case-MEH


    case Auf.A.MEH.Preis of
      Lfs.P.MEH : Auf.A.Menge.Preis # Auf.A.Menge.Preis + vDifMenge;

      Lfs.P.MEH.Einsatz : Auf.A.Menge.Preis # Auf.A.Menge.Preis + vDifEinsatz;

      'kg'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Auf.A.Nettogewicht
        else
          Auf.A.Menge.Preis # Auf.A.Gewicht;
      end;

      't'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Rnd(Auf.A.Nettogewicht /1000.0,Set.Stellen.Menge)
        else
          Auf.A.Menge.Preis # Rnd(Auf.A.Gewicht / 1000.0, Set.Stellen.Menge);
      end;

      'Stk' : Auf.A.Menge.Preis # cnvfi("auf.A.Stückzahl");

      otherwise
        Auf.A.Menge.Preis # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);

    end;  // Case-MEH-Preis

    Erx # RekReplace(404,_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      Error(010020, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
    // Auftragspos. updaten...

  end
  else begin        // existiert nicht? Aktion NEU anlegen********************

    RecBufClear(404);
    Auf.A.Aktionstyp    # vTyp;
    Auf.A.Aktionsnr     # Lfs.P.Nummer;
    Auf.A.Aktionspos    # Lfs.P.Position;
    Auf.A.Aktionsdatum  # today;
    Auf.A.TerminStart   # Today;
    Auf.A.TerminEnde    # today;

    // 2023-02-07 AH  : Neu, Proj. 2333/18/1
    if (Lfs.Lieferdatum<>0.0.0) then begin
      Auf.A.TerminStart   # Lfs.Lieferdatum;
      Auf.A.TerminEnde    # Lfs.Lieferdatum;
    end;
    if (Lfs.zuBA.Nummer<>0) and (BAG.P.Nummer=Lfs.zuBA.Nummer) and
      (BAG.P.Position=Lfs.zuBA.Position) then begin
      if (BAG.P.Plan.Startdat<>0.0.0) then
        Auf.A.TerminStart   # BAG.P.Plan.StartDat;
      if (BAG.P.Plan.Enddat<>0.0.0) then
        Auf.A.TerminEnde    # BAG.P.Plan.EndDat;
    end;
    
    Auf.A.MaterialNr    # Mat.Nummer;
    if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then  // ggf. Artikelnummer für 209er übernehmen
      Auf.A.ArtikelNr # Mat.Strukturnr;

    Auf.A.Dicke         # Mat.Dicke;
    Auf.A.Breite        # Mat.Breite;
    "Auf.A.Länge"       # "Mat.Länge";
    if (LFS.zuBA.Nummer<>0) then
      Auf.A.Bemerkung     # Translate('zu BA')+' '+cnvai(LFS.zuBA.Nummer)+'/'+cnvai(LFS.zuBA.Position);

    "Auf.A.Stückzahl"   # "Lfs.P.Stück";
    Auf.A.Nettogewicht  # Lfs.P.Gewicht.Netto;
    Auf.A.Gewicht       # Lfs.P.Gewicht.Brutto;
    if (Auf.A.Gewicht=0.0) then       Auf.A.Gewicht # Auf.A.Nettogewicht;
    if (Auf.A.Nettogewicht=0.0) then  Auf.A.Nettogewicht # Auf.A.Gewicht;

    Auf.A.MEH           # Lfs.P.MEH.Einsatz;
    Auf.A.MEH.Preis     # Auf.P.MEH.Preis;

    case Auf.A.MEH of
      Lfs.P.MEH : Auf.A.Menge # LFs.P.Menge;

      Lfs.P.MEH.Einsatz : Auf.A.Menge # LFs.P.Menge.Einsatz;

      'kg'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge # Auf.A.Nettogewicht
        else
          Auf.A.Menge # Auf.A.Gewicht;
      end;

      't'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge # Rnd(Auf.A.Nettogewicht /1000.0,Set.Stellen.Menge)
        else
          Auf.A.Menge # Rnd(Auf.A.Gewicht / 1000.0, Set.Stellen.Menge);
      end;

      'Stk' : Auf.A.Menge # cnvfi("auf.A.Stückzahl");

      otherwise
        Auf.A.Menge # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, 0.0, '', Auf.A.MEH);

    end;  // Case-MEH


    case Auf.A.MEH.Preis of

      Lfs.P.MEH : Auf.A.Menge.Preis # LFs.P.Menge;

      Lfs.P.MEH.Einsatz : Auf.A.Menge.Preis # LFs.P.Menge.Einsatz;

      'kg'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Auf.A.Nettogewicht
        else
          Auf.A.Menge.Preis # Auf.A.Gewicht;
      end;

      't'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Rnd(Auf.A.Nettogewicht /1000.0,Set.Stellen.Menge)
        else
          Auf.A.Menge.Preis # Rnd(Auf.A.Gewicht / 1000.0, Set.Stellen.Menge);
      end;

      'Stk' : Auf.A.Menge.Preis # cnvfi("auf.A.Stückzahl");

      otherwise
        Auf.A.Menge.Preis # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);

    end;  // Case-MEH-Preis


    if (Auf.P.Nummer<>0) then begin
      vOk # Auf_A_Data:NeuAnlegen(n,(Lfs.P.AuftragsPos2<>0))=_rOK;
      if (vOK=false) then begin
        Error(010010, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
        RETURN false;
      end;
    end; // Auf vorhanden

  end;  // Auftrag **********************************************************

  // Erfolg!
  RETURN true;
end;


//========================================================================
// Pos_VLDAW_VSBMat +ERR
//      1. VLDAW Auf- und Mat-Aktion anlegen (+VSAufMenge)
//   (2. kommi.Material von AuftragVSB abziehen)
//========================================================================
sub Pos_VLDAW_VSBMat(
  aDelYN        : logic;  // Satz löschen???
  opt aBuf441   : int;
) : logic
local begin
  Erx         : int;
  vOk         : logic;
  vTyp        : alpha;
  vDifStk     : int;
  vDifEinsatz : float;
  vDifMenge   : float;
  vDifNetto   : float;
  vDifBrutto  : float;
  //vDifGewicht : float;
  vMatIstVSB  : logic;
end;
begin

  vTyp # c_Akt_VLDAW
  if ("Lfs.RücknahmeYN") then vTyp # c_AKT_RVLDAW;

  // Differenzen bei Edit errechnen
  if (aBuf441<>0) then begin
    vDifMenge   # Lfs.P.Menge           - aBuf441->Lfs.P.Menge;
    vDifEinsatz # Lfs.P.Menge.Einsatz   - aBuf441->Lfs.P.Menge.Einsatz;
    vDifStk     # "Lfs.P.Stück"         - aBuf441->"Lfs.P.Stück";
    vDifNetto   # Lfs.P.Gewicht.Netto   - aBuf441->Lfs.P.Gewicht.Netto;
    vDifBrutto  # Lfs.P.Gewicht.Brutto  - aBuf441->Lfs.P.Gewicht.Brutto;
  end;

  Erx # RecLink(200,441,4,_RecFirst);   // Material holen
  if (Erx>_rLocked) then begin
    Error(010001, AInt(Lfs.P.Position)+'|'+AInt(LFs.P.Materialnr));
    RETURN false;
  end;

  // Material prüfen***************************
  //if ("Mat.Löschmarker"='*') and (aDelYN=n) then begin
  //  Error(010002, CnvAI(Lfs.P.Position)+'|'+CnvAI(Mat.Nummer));
  //  RETURN false;
  //end;

  if (Mat.AuftragsNr=Lfs.P.Auftragsnr) and (Mat.AuftragsPos=Lfs.P.AuftragsPos) then
    vMatIstVSB # Y;

//if (vMatIstVSB) then xebug('mat ist VSB!')
//else xebug('mat ist NICHT Vsb!');

  // Löschen?????***********************************************************
  if (aDelYN=true) then begin

    // Mataktion löschen
    RecBufClear(204);
    Mat.A.AktionsTyp  # vTyp;
    Mat.A.Aktionsnr   # Lfs.P.Nummer;
    Mat.A.AktionsPos  # Lfs.P.Position;
    Erx # RecRead(204,2,0);
    if (Erx=_rOK) or (Erx=_rMultikey) then begin
      erx # RekDelete(204,0,'AUTO');
    end;
    if (Erx<>_rOK) then begin
      Error(010017, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;

    // ggf. Auftrags-Aktion löschen...
    RecBufClear(404);
    Auf.A.AktionsTyp  # vTyp;
    Auf.A.Aktionsnr   # Lfs.P.Nummer;
    Auf.A.AktionsPos  # Lfs.P.Position;
    Erx # RecRead(404,2,0);     // bisherige Aktion suchen...

    if (Erx<>_rNoRec) and (Auf.A.AktionsTyp=vTyp) and   // gibts schon?
        (Auf.A.Aktionsnr=Lfs.P.Nummer) and
        (Auf.A.AktionsPos=Lfs.P.Position) then begin

      // Auftragspos. updaten *****************
      RecLink(401,404,1,_recFirsT);   // Auf.Pos. holen
      // Material war bisher NICHT für diesen Auf?
      // ->dann vorher VSB anpassen
      if (Auf_A_Data:Entfernen()=false) then begin
        Error(010019, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
        RETURN false;
      end;
    end;  // Auftrag anpassen

    // Löschen Erfolg
    RETURN true;
  end;  // Löschen *********************************************************


  // Material anpassen *****************************************************
  Erx # RecLink(818,200,10,_recFirst);  // Verwiegungsart Material holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  if (aBuf441=0) then begin  // Mataktion neu anlegen
    RecBufClear(204);
    Mat.A.Materialnr    # Mat.Nummer;
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Aktionstyp    # vTyp;
    Mat.A.Aktionsnr     # Lfs.P.Nummer;
    Mat.A.Aktionspos    # Lfs.P.Position;
    Mat.A.Aktionsdatum  # today;
    Mat.A.TerminStart   # today;
    Mat.A.Adressnr      # Lfs.Zieladresse;
    "Mat.A.Stückzahl"   # "Lfs.P.Stück";
    if (VWA.NettoYN) then
      Mat.A.Gewicht # Lfs.P.Gewicht.Netto
    else
      Mat.A.Gewicht # Lfs.P.Gewicht.Brutto;
    Mat.A.Nettogewicht  # Lfs.P.Gewicht.Netto;
    // für MATMEH
    if (Mat.MEH=Lfs.P.MEH) then
      Mat.A.Menge       # Lfs.P.Menge;

    Mat_A_Data:Insert(0,'AUTO');

  end
  else begin  // Mataktion updaten...
    RecBufClear(204);
    Mat.A.AktionsTyp  # vTyp;
    Mat.A.Aktionsnr   # Lfs.P.Nummer;
    Mat.A.AktionsPos  # Lfs.P.Position;
    Erx # RecRead(204,2,0);
    if (Erx=_rOK) or (Erx=_rMultikey) then begin
      RecRead(204,1,_recLock);
//      Mat.A.Aktionsdatum  # Auf.A.Aktionsdatum;
//      Mat.A.TerminStart   # Auf.A.TerminStart;
      Mat.A.Adressnr      # Lfs.Zieladresse;
      "Mat.A.Stückzahl"   # "Lfs.P.Stück";
      if (VWA.NettoYN) then
        Mat.A.Gewicht # Lfs.P.Gewicht.Netto
      else
        Mat.A.Gewicht # Lfs.P.Gewicht.Brutto;
      Mat.A.Nettogewicht  # Lfs.P.Gewicht.Netto;
      // 10.04.2013 VORLÄUFIG:
      Mat.A.Menge         # 0.0;

      Erx # RekReplace(204,_recUnlock,'AUTO');
    end;
    if (Erx<>_rOK) then begin
      Error(010022, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;
  end;  // Material ********************************************************


  // Auftrag anpassen ******************************************************

  // Auftrags-Aktion updaten...
  RecBufClear(404);
  Auf.A.AktionsTyp  # vTyp;
  Auf.A.Aktionsnr   # Lfs.P.Nummer;
  Auf.A.AktionsPos  # Lfs.P.Position;
  Erx # RecRead(404,2,0);     // bisherige Aktion suchen...

  if (Erx<>_rNoRec) and (Auf.A.AktionsTyp=vTyp) and   // gibts schon?
      (Auf.A.Aktionsnr=Lfs.P.Nummer) and
      (Auf.A.AktionsPos=Lfs.P.Position) then begin

    Erx # RecRead(404,1,_RecLock);
    if (Erx=_rLocked) then begin
      Error(010020, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      Error(010020,'Auftragsaktion');
      RETURN false;
    end;

    Auf.A.Menge         # Auf.A.Menge + vDifEinsatz;
    Auf.A.Menge.Preis   # Auf.A.Menge.Preis + vDifMenge;

    "Auf.A.Stückzahl"   # "Auf.A.Stückzahl" + vDifStk;
    //if (VWA.NettoYN) then
    //  vDifGewicht # vDifNetto
    //else
    //  vDifGewicht # vDifBrutto;
    //Auf.A.Gewicht # Auf.A.Gewicht + vDifGewicht;
    Auf.A.Gewicht       # Auf.A.Gewicht + vDifBrutto;
    Auf.A.Nettogewicht  # Auf.A.Nettogewicht + vDifNetto;


    case Auf.A.MEH of
      'kg'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge # Auf.A.Nettogewicht
        else
          Auf.A.Menge # Auf.A.Gewicht;
      end;

      't'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge # Rnd(Auf.A.Nettogewicht /1000.0,Set.Stellen.Menge)
        else
          Auf.A.Menge # Rnd(Auf.A.Gewicht / 1000.0, Set.Stellen.Menge);
      end;

      'Stk' : Auf.A.Menge # cnvfi("auf.A.Stückzahl");

      Lfs.P.MEH : Auf.A.Menge # Auf.A.Menge + vDifMenge;

      Lfs.P.MEH.Einsatz : Auf.A.Menge # Auf.A.Menge + vDifEinsatz;

      otherwise
        Auf.A.Menge # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, 0.0, '', Auf.A.MEH);

    end;  // Case-MEH


    case Auf.A.MEH.Preis of
      Lfs.P.MEH : Auf.A.Menge.Preis # Auf.A.Menge.Preis + vDifMenge;

      Lfs.P.MEH.Einsatz : Auf.A.Menge.Preis # Auf.A.Menge.Preis + vDifEinsatz;

      'kg'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Auf.A.Nettogewicht
        else
          Auf.A.Menge.Preis # Auf.A.Gewicht;
      end;

      't'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Rnd(Auf.A.Nettogewicht /1000.0,Set.Stellen.Menge)
        else
          Auf.A.Menge.Preis # Rnd(Auf.A.Gewicht / 1000.0, Set.Stellen.Menge);
      end;

      'Stk' : Auf.A.Menge.Preis # cnvfi("auf.A.Stückzahl");

      otherwise
        Auf.A.Menge.Preis # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);

    end;  // Case-MEH-Preis

    Erx # RekReplace(404,_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      Error(010020, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
    Auf_A_Data:Recalcall(n);

  end
  else begin        // existiert nicht? Aktion NEU anlegen********************

    RecBufClear(404);
    Auf.A.Aktionstyp    # vTyp;
    "Auf.A.TheorieYN"   # (vMatIstVSB = n);
    Auf.A.Aktionsnr     # Lfs.P.Nummer;
    Auf.A.Aktionspos    # Lfs.P.Position;
    Auf.A.Aktionsdatum  # today;
    Auf.A.TerminStart   # Today;
    Auf.A.TerminEnde    # today;
    //Erx # RecLink(100,440,1,_recfirst);   // Kunde holen
    //if (Erx>_rLockeD) then RecBufClear(100);
    //Aufx.A.Adressnummer  # Adr.Nummer;
    Auf.A.MaterialNr    # Mat.Nummer;
    if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then  // ggf. Artikelnummer für 209er übernehmen
      Auf.A.ArtikelNr # Mat.Strukturnr;

    Auf.A.Dicke         # Mat.Dicke;
    Auf.A.Breite        # Mat.Breite;
    "Auf.A.Länge"       # "Mat.Länge";
    if (LFS.zuBA.Nummer<>0) then
      Auf.A.Bemerkung     # Translate('zu BA')+' '+cnvai(LFS.zuBA.Nummer)+'/'+cnvai(LFS.zuBA.Position);

//    Auf.A.MEH           # 'kg';
//    Auf.A.Menge         # Lfs.P.Menge.Einsatz;
//    Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
//    Auf.A.Menge.Preis   # Lfs.P.Menge;

    Auf.A.MEH           # Lfs.P.MEH.Einsatz;
    Auf.A.MEH.Preis     # Auf.P.MEH.Preis;

    "Auf.A.Stückzahl"   # "Lfs.P.Stück";
    if (VWA.NettoYN) then
      Auf.A.Gewicht # Lfs.P.Gewicht.Netto
    else
      Auf.A.Gewicht # Lfs.P.Gewicht.Brutto;
    Auf.A.Nettogewicht  # Lfs.P.Gewicht.Netto;


    case Auf.A.MEH of
      'kg'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge # Auf.A.Nettogewicht
        else
          Auf.A.Menge # Auf.A.Gewicht;
      end;

      't'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge # Rnd(Auf.A.Nettogewicht /1000.0,Set.Stellen.Menge)
        else
          Auf.A.Menge # Rnd(Auf.A.Gewicht / 1000.0, Set.Stellen.Menge);
      end;

      'Stk' : Auf.A.Menge # cnvfi("auf.A.Stückzahl");

      Lfs.P.MEH : Auf.A.Menge # LFs.P.Menge;

      Lfs.P.MEH.Einsatz : Auf.A.Menge # LFs.P.Menge.Einsatz;

      otherwise
        Auf.A.Menge # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, 0.0, '', Auf.A.MEH);

    end;  // Case-MEH


    case Auf.A.MEH.Preis of
      Lfs.P.MEH : Auf.A.Menge.Preis # LFs.P.Menge;

      Lfs.P.MEH.Einsatz : Auf.A.Menge.Preis # LFs.P.Menge.Einsatz;

      'kg'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Auf.A.Nettogewicht
        else
          Auf.A.Menge.Preis # Auf.A.Gewicht;
      end;

      't'  : begin
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Rnd(Auf.A.Nettogewicht /1000.0,Set.Stellen.Menge)
        else
          Auf.A.Menge.Preis # Rnd(Auf.A.Gewicht / 1000.0, Set.Stellen.Menge);
      end;

      'Stk' : Auf.A.Menge.Preis # cnvfi("auf.A.Stückzahl");

      otherwise
        Auf.A.Menge.Preis # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);

    end;  // Case-MEH-Preis

    if (Auf.P.Nummer<>0) then begin
      vOk # Auf_A_Data:NeuAnlegen()=_rOK;
      if (vOK=false) then begin
        Error(010010, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
        RETURN false;
      end;
    end; // Auf vorhanden
  end;  // Auftrag **********************************************************


//debugx('ENDE');

  // Erfolg!
  RETURN true;
end;


//========================================================================
// Pos_VLDAW_Art  +ERR
//
//========================================================================
sub Pos_VLDAW_Art(
  aDelYN      : logic;  // Satz löschen???
  opt aBuf441 : int;    // Urspungsdatenbuffer
) : logic
local begin
  Erx       : int;
  vOk       : logic;
  vTyp      : alpha;
  vDatum    : date;
  vMode     : alpha;
  vDiff     : float;
  vDiffStk  : int;
  vDiffNet  : float;
  vDiffBrut : float;
end;
begin

  vTyp # c_Akt_VLDAW
  if ("Lfs.RücknahmeYN") then vTyp # c_AKT_RVLDAW;

  vDatum # 1.1.1900;
  if (aBuf441<>0) then begin
    vDiff     # 0.0 - (aBuf441->Lfs.P.Menge.Einsatz);
    vDiffStk  # 0 - (aBuf441->"Lfs.P.Stück");
    vDiffNet  # 0.0 - (aBuf441->Lfs.P.Gewicht.Netto);
    vDiffBrut # 0.0 - (aBuf441->Lfs.P.Gewicht.Brutto);
  end;

  vDiff     # vDiff     + Lfs.P.Menge.Einsatz;
  vDiffStk  # vDiffStk  + "Lfs.P.Stück";
  vDiffNet  # vDiffNet  + Lfs.P.Gewicht.Netto;
  vDiffBrut # vDiffBrut + Lfs.P.Gewicht.Brutto;

  // Aktionen bereits vorhanden?
  RecBufClear(404);
  Auf.A.AktionsTyp  # vTyp;
  Auf.A.Aktionsnr   # Lfs.P.Nummer;
  Auf.A.AktionsPos  # Lfs.P.Position;
  Erx # RecRead(404,2,0);     // bisherige Aktion suchen...

  if (Erx<>_rNoRec) and (Auf.A.AktionsTyp=vTyp) and   // gibts schon?
      (Auf.A.Aktionsnr=Lfs.P.Nummer) and
      (Auf.A.AktionsPos=Lfs.P.Position) then begin

    if (Erx=_rLocked) then begin
//      RANSBRK;
      Error(010020, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      Error(010020,'Auftragsaktion');
      RETURN false;
    end;


    // Löschen??? ----------------------------------------------------
    if (aDelYN=true) then begin
      vDiff     # 0.0 - Lfs.P.Menge.Einsatz;
      vDiffStk  # 0  - "Lfs.P.Stück";
      vDiffNet  # 0.0 - Lfs.P.Gewicht.Netto;
      vDiffBrut # 0.0 - Lfs.P.Gewicht.Brutto;

      // Auftragsmengen anpassen ------------------------------
      Erx # RecLink(401,441,5,_recfirst);   // Position holen
      if (Erx<>_rOK) then begin
        Error(010014, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
        RETURN false;
      end;

      if (Lfs.P.Auftragspos2<>0) then begin
        Erx # RecLink(409,441,8,_recfirst);   // SL-Position holen
        if (Erx<>_rOK) then begin
          Error(010024, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
          RETURN false;
        end;
      end;

      if (Auf_A_Data:Entfernen()<>true) then begin
        Error(010019, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
        RETURN false;
      end;

      if ("Lfs.RücknahmeYN"=false) then begin
        if (Nimm_von_VSB(vDiff, vDiffStk, vDiffNet, vDiffBrut, Lfs.P.Artikelnr, Lfs.P.Art.Adresse, Lfs.P.Art.Anschrift, Lfs.P.Art.Charge)=false) then begin
          Error(010023, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
          RETURN false;
        end;
      end;

      // ERFOLG!
      RETURN true;
    end;

    vDatum # Auf.A.Aktionsdatum;

    vMode # 'REP';

  end
  else begin        // existiert nicht? Aktion NEU anlegen
    RecBufClear(404);
    Auf.A.Aktionstyp    # vTyp;
    Auf.A.Aktionsnr     # Lfs.P.Nummer;
    Auf.A.Aktionspos    # Lfs.P.Position;
    vMode # 'INS';
  end;


  if (vDatum=1.1.1900) then vDatum # Today;

  // Aktion verändern
  Auf.A.Aktionsdatum  # vDatum;
  Auf.A.TerminStart   # vDatum;
  Auf.A.TerminEnde    # vDatum;
  //Erx # RecLink(100,440,1,_recfirst);   // Kunde holen
  //if (Erx>_rLockeD) then RecBufClear(100);
  //Aufx.A.Adressnummer  # Adr.Nummer;
  Auf.A.Menge         # Lfs.P.Menge.Einsatz;
  "Auf.A.Stückzahl"   # "Lfs.P.Stück";
  Auf.A.Gewicht       # Lfs.P.Gewicht.Brutto;
  Auf.A.Nettogewicht  # Lfs.P.Gewicht.Netto;
//  Auf.A.MEH           # Lfs.P.MEH;  // 22.06.2011 AI
  Auf.A.MEH           # Lfs.P.MEH.Einsatz;

  Auf.A.ArtikelNr       # Lfs.P.ArtikelNr;
  Auf.A.Charge          # Lfs.P.Art.Charge;
  Auf.A.Charge.Adresse  # Lfs.P.Art.Adresse;
  Auf.A.Charge.Anschr   # Lfs.P.Art.Anschrift;
  Erx # RecLink(252,404,4,_recFirst);   // Charge holen
  if (Erx>_rLocked) then RETURN false;
  if (Art.C.Bezeichnung<>'') then Auf.A.Bemerkung # Art.C.Bezeichnung;

//xebug('setzte VLDAW auf'+cnvaf(auf.a.menge));

  // Preismenge berechnen
  Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
  if (Auf.A.MEH.Preis=Lfs.P.MEH) then
    Auf.A.Menge.Preis   # Lfs.P.Menge
  else if (Auf.A.MEH.Preis='Stk') then
    Auf.A.Menge.Preis   # cnvfi("Lfs.P.Stück")
  else if (Auf.A.MEH.Preis='kg') then
    Auf.A.Menge.Preis   # Lfs.P.Gewicht.Netto;
  else if (Auf.A.MEH.Preis='t') then
    Auf.A.Menge.Preis   # Lfs.P.Gewicht.Netto / 1000.0
  else if (Auf.A.MEH.Preis=Lfs.P.MEH.Einsatz) then
    Auf.A.Menge.Preis   # Lfs.P.Menge.Einsatz
  else
    Auf.A.Menge.Preis   # Lib_Einheiten:WandleMEH(252, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis);

  // Stückliste ggf. holen
  RecBufClear(409);
  if (Lfs.P.Auftragspos2<>0) then begin
    Auf.SL.Nummer   # LFs.P.AuftragsNr;
    Auf.SL.Position # Lfs.P.Auftragspos;
    Auf.SL.lfdNr    # Lfs.P.AuftragsPos2;
    Erx # RecRead(409,1,0);
    if (Erx<>_rOK) then begin
//      RANSBRK;
      Error(010011, AInt(Lfs.P.Position)+'|'+Lfs.P.ArtikelNr);
      RETURN false;
    end;
  end;

  Erx # RecLink(250,401,2,_RecFirst);   // PosArtikel holen


  // NEUANLAGE ****************************************************
  if (vMode='INS') then begin
    vOk # Auf_A_Data:NeuAnlegen(n,y)=_rOK;
    if (vOK=false) then begin
//      RANSBRK;
      Error(010010, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;

    if ("Lfs.RücknahmeYN"=false) then begin
      if (Nimm_von_VSB(vDiff, vDiffStk, vDiffNet, vDiffBrut, Lfs.P.Artikelnr, Lfs.P.Art.Adresse, Lfs.P.Art.Anschrift, Lfs.P.Art.Charge)=false) then begin
//        RANSBRK;
          Error(010023, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
          RETURN false;
      end;
    end;

    // ERFOLG!
    RETURN true;
  end;


  // ERSETZEN *****************************************************
  if (vMode='REP') then begin
    // Aktion sperren
    RecRead(404,1,_RecLock | _RecNoLoad);
    Erx # RekReplace(404,_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
//      RANSBRK;
      Error(010043, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;


    // Auftragsmengen anpassen --------------------------
    Erx # RecLink(401,441,5,_recfirst);   // Position holen
    if (Erx<>_rOK) then begin
      Error(010014, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;

    if (Lfs.P.Auftragspos2<>0) then begin
      Erx # RecLink(409,441,8,_recfirst);   // SL-Position holen
      if (Erx<>_rOK) then begin
        Error(010024, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
        RETURN false;
      end;
      RecRead(409,1,_recLock);
      Auf.SL.Prd.VSAuf       # Auf.SL.Prd.VSAuf     + vDiff;
      Auf.SL.Prd.VSAuf.Gew   # Auf.SL.Prd.VSAuf.Gew + vDiffBrut;
      Auf.SL.Prd.VSAuf.Stk   # Auf.SL.Prd.VSAuf.Stk + vDiffStk;
      Auf.SL.Prd.VSB         # Auf.SL.Prd.VSB       - vDiff;
      Auf.SL.Prd.VSB.Gew     # Auf.SL.Prd.VSB.Gew   - vDiffBrut;
      Auf.SL.Prd.VSB.Stk     # Auf.SL.Prd.VSB.Stk   - vDiffStk;
      Erx # Rekreplace(409,_recUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        Error(010025, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
        RETURN false;
      end;
    end;

    if ("Lfs.RücknahmeYN"=false) then begin
      if (Nimm_von_VSB(vDiff, vDiffStk, vDiffNet, vDiffBrut, Lfs.P.Artikelnr, Lfs.P.Art.Adresse, Lfs.P.Art.Anschrift, Lfs.P.Art.Charge)=false) then begin
        Error(010023, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
        RETURN false;
      end;
    end;

    // ERFOLG!
    RETURN true;
  end;


  // ERFOLG!
  RETURN true;
end;


//========================================================================
// Pos_VLDAW_Verbuchen  +ERR
//      Bucht die aktuelle Position als geplante Verladung
//========================================================================
sub Pos_VLDAW_Verbuchen(
  aDelYN        : logic;  // Satz löschen???
  opt aBuf441   : int;    // Urspungsdatenbuffer
  opt aMod      : logic;  // Kreditlimitprüfung
) : logic
local begin
  Erx : int;
  vA  : alpha;
end;
begin
  if (Lfs.Datum.Verbucht<>0.0.0) then begin
    Error(010013, AInt(Lfs.P.Position));
    RETURN false;
  end;

  if (Lfs.Kundennummer<>0) and (Lfs.P.Auftragsnr<>0) then begin
    // Auftragsposition holen
    Erx # RecLink(401,441,5,_RecFirst);
    if (Erx>_rLocked) then begin
      Error(010014, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
    Erx # RecLink(400,401,3,_RecFirst); // Kopf holen
    if (Erx>_rLocked) then begin
      Error(010014, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
    Erx # RecLink(100,400,1,_RecFirst); // Kunde holen
    if (Erx>_rLocked) then begin
      Error(010016, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
    Erx # RecLink(818,401,9,_recFirst);   // Verwiegungsart Auftrag holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;

    // AI 01.08.2011
    if (Lfs.Kundennummer<>Auf.Kundennr) then begin
//debugx(aint(Lfs.Kundennummer)+' <> '+aint(Auf.Kundennr));
      Error(010046,'');
      RETURN false;
    end;

  end
  else begin
    RecBufClear(400);
    RecBufClear(401);
    RecBufClear(100);
    RecBufClear(818);
    VWa.NettoYN # y;
  end;

  // MATERIALLIEFERUNG ???????????????????????????????????????
  if (Lfs.P.Materialtyp=c_IO_Mat) then begin
    if (Pos_VLDAW_Mat(aDelYN,aBuf441)=false) then RETURN false;
  end;

  // VSB-MATERIALLIEFERUNG ???????????????????????????????????????
  if (Lfs.P.Materialtyp=c_IO_VSB) then begin
    if (Pos_VLDAW_VSBMat(aDelYN,aBuf441)=false) then RETURN false;
  end;

  // ARTIKELLIEFERUNG ????????????????????????????????????????
  if (Lfs.P.Materialtyp=c_IO_ART) then begin
    if (Pos_VLDAW_Art(aDelYN,aBuf441)=false) then RETURN false;
  end;

  // 05.07.2019 AH: z.B. Kreditlimit
  if (aDelYN) then vA # 'Y|' else vA # 'N|';
  if (aMod) then vA # vA + 'Y|' else vA # vA + 'N|';
  if (RunAFX('Lfs.P.VLDAW.Verbuchen.Check',vA+aint(aBuf441))<>0) then begin
    if (AfxRes<>_rOK) then RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// Druck_VLDAW  +ERR
//      Drucke die Verladeanweisung
//========================================================================
sub Druck_VLDAW()
local begin
  vKLim : float;
end;
begin

  // ST 2018-01-18: Auch Verladeanweisung für Fahraufträge möglich
  //if (Lfs.zuBA.Nummer<>0) then RETURN;

  RecLink( 100, 440, 2, _recFirst ); // Zieladresse
  
  if (RunAFX('Lfs.PreDruck.VLDAW','')<0) then RETURN;   // 29.06.2022 MR
  Lib_Dokumente:Printform( 440, 'Verladeanweisung', true );

end;


//========================================================================
// Druck_LFA +ERR
//      Drucke den LFA
//========================================================================
sub Druck_LFA()
local begin
  Erx   : int;
  vKLim : float;
  vOK   : logic;
  vTyp  : alpha;
end;
begin

  if (Lfs.zuBA.Nummer=0) then RETURN;

  // Kreditlimit prüfen [02.06.2010/PW]
  if ( "Set.KLP.LFA-Druck" != '' ) then begin

    if ( Lfs.P.Nummer != Lfs.Nummer ) then
      RecLink( 441, 440, 4, _recFirst ); // erste Position holen

    if (Lfs.P.Auftragsnr <> 0) and (Lfs.P.AuftragsPos <> 0) then begin
      Erx # RecLink(401,441,5,_RecFirst);     // Auftragspos holen
      if (Erx>_rLocked) then RETURN;
      Erx # RecLink(400,401,3,0);             // Auftragskopf holen
      if (Erx>_rLocked) then RETURN;
      Erx # RecLink(100,400,1,_RecFirst);     // Kunde holen
      if (Adr.SperrKundeYN) then begin
        Msg(100005,Adr.Stichwort,0,0,0);
        RETURN;
      end;
      Erx # RecLink(100,400,4,_recFirst);     // Rechnungsempfänger holen
      if (Adr.SperrKundeYN) then begin
        Msg(100005,Adr.Stichwort,0,0,0);
        RETURN;
      end;
      vTyp # "Set.KLP.LFA-Druck";
      if (vTyp = 'L') then begin   // 16.04.2021 AH: Proj.2199/4
        vOK # Adr_K_Data:GibtsLfsFreigabe(Lfs.Nummer, Auf.Nummer);
        vTyp # 'S';
      end;
      if (vOK=false) then begin
        if ( Adr_K_Data:Kreditlimit( Auf.Rechnungsempf, vTyp, true, var vKLim,0,Auf.Nummer,false ) = false ) then
          RETURN;
      end;

    end;
  end;


  Erx # RecLink(702,440,7,_recFirst);   // BA-Position holen
  if (Erx>_rLocked) then RETURN;

  RecLink(100,702,7,_RecFirst);   // Spediteru holen
  
  if (RunAFX('Lfs.Print.Lohnformular','')<0) then RETURN;   // 09.01.2020 TM
  
  Lib_Dokumente:Printform(700,'Lohnfahrauftrag',true);
  
end;


//========================================================================