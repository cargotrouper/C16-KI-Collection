@A+
//===== Business-Control =================================================
//
//  Prozedur    Auf_Abl_Data
//                  OHNE E_R_G
//  Info
//    OfP Ablagenfunktionen
//
//  28.08.2008  PW  Erstellung der Prozedur
//  24.08.2009  MS  Reorg um "bis Anlagedatum" erweitert
//  02.04.2013  AI  KEINE REK-Befehle bei Reorg wegen SQL
//  19.02.2014  AH  Anhänge werden mit Ablage verschoben und zurück
//  09.01.2015  AH  Rein/Raus mit Ablage nutzt DOCH Rek-Befehle (wegen dem Sync)
//  12.01.2015  ST  Reorg über Jobserver, optionales Abgrenzungsdatum hinzugefügt
//  11.05.2017  AH  Reorg von Lohnaufträgen löscht, wenn mind. eine Faktrua, keine weiteren offenen BAs und kein
//                  VSB-Material existiert
//  05.12.2018  AH  AFX "Auf.Reorg"
//  18.02.2020  AH  Reorg prüft noch mal nach offenen, kommissioniertem Material
//  09.04.2020  AH  Reorg überschreibt knallhart die Ablage
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB SumGesamtpreisAblage(aPosMenge : float; aPosStk : int; aPosGew : float) : float;
//    SUB RestoreAusAblage(opt aNr : int) : logic;
//    SUB Reorganisation(aJobServer : logic; opt aBisDatum : date) : logic;
//
//========================================================================
@I:Def_Global

//========================================================================
// SumGesamtpreis Auftrag Ablage
//
//========================================================================
sub SumGesamtpreisAblage(aPosMenge : float; aPosStk : int; aPosGew : float) : float;
local begin
  Erx             : int;
  vMenge          : float;
  vPosNetto       : float;
  vPosNettoRabBar : float;
  vWert           : float;
end;
begin
  vWert # 0.0;
  //vMenge # Lib_Einheiten:WandleMEH(401, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.wunsch, Auf.P.MEH.Preis);
  //vMenge # Lib_Einheiten:WandleMEH(401, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Preis, Auf.P.MEH.Preis);
  vMenge # Lib_Einheiten:WandleMEH(411, aPosStk, aPosGew, aPosMenge, "Auf~P.MEH.einsatz", "Auf~P.MEH.Preis");
  if (Auf.P.PEH<>0) then
    vWert # "Auf~P.Grundpreis" * vMenge / Cnvfi("Auf~P.PEH");

  vPosNettoRabBar # vWert;
  vPosNetto       # vWert;

  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  // Aufpreise: MEH-Bezogen
  Erx # RecLink(403,411,6,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') then begin
      // PosMEH in AufpreisMEH umwandeln
      //vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
      vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, "Auf~P.MEH.Preis", Auf.Z.MEH)
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
      vWert # vWert + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
    end;
    Erx # RecLink(403,411,6,_RecNext);
  END;

  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  // Aufpreise: NICHT MEH-Bezogen =FIX
  Erx # RecLink(403,411,6,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
    if (Auf.Z.MengenbezugYN=n) and (Auf.Z.Rechnungsnr=0) then begin

      if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,411);

      if (Auf.Z.Menge<>0.0) then begin
        vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
        if (Auf.Z.RabattierbarYN) then
          vPosNettoRabBar # vPosNettoRabBar + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
        vWert # vWert + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      end;
    end;
    Erx # RecLink(403,411,6,_RecNext);
  END;


  // Aufpreise: %
  // Aufpreise: %
  // Aufpreise: %
  Erx # RecLink(403,411,6,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if ("Auf.Z.Schlüssel"='*RAB1') or ("Auf.Z.Schlüssel"='*RAB2') then begin
      Erx # RecLink(403,411,6,_RecNext);
      CYCLE;
    end;

    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH='%') then begin
      Auf.Z.Preis # vPosNettoRabBar;
      Auf.Z.PEH   # 100;
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

      vWert  # vWert + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
    end;
    Erx # RecLink(403,411,6,_RecNext);
  END;

  if (gFile=400) or (gFile=401) then begin
    Auf.Z.Menge # (-1.0) * $edRabatt1->wpcaptionfloat;
    if (Auf.Z.Menge<>0.0) then begin
      Auf.Z.Preis # vPosNettoRabBar;
      Auf.Z.PEH   # 100;
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
      vWert  # vWert + Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
    end;
  end;


  // KopfAufpreise: MEH-bezogen
  // KopfAufpreise: MEH-Bezogen
  // KopfAufpreise: MEH-Bezogen
  Erx # RecLink(403,410,13,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
    if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') and (Auf.Z.Position=0) then begin
      // PosMEH in AufpreisMEH umwandeln
      vMenge # Lib_Einheiten:WandleMEH(403, aPosStk, aPosGew, aPosMenge, "Auf~P.MEH.Preis", Auf.Z.MEH)
      vPosNetto # vPosNetto + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
      if (Auf.Z.RabattierbarYN) then
        vPosNettoRabBar # vPosNettoRabBar + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);

        vWert # vWert + Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
     end;
    Erx # RecLink(403,410,13,_RecNext);
  END;


  // Stückliste EKs addieren
//  Erx # RecLink(409,401,15,_recFirst);
//  WHILE (Erx=_rOK) do begin
//  Erx # RecLink(409,401,15,_recNext);
//  END;

  RETURN vWert;
end;


//========================================================================
//  RestoreAusAblage
//
//========================================================================
sub RestoreAusAblage(opt aNr : int) : logic;
local begin
  Erx : int;
  vNr : int;
  vOk : logic;
end;
begin

  // Abfrage

  vNr # aNr;
  if (vNr=0) then
    if (Dlg_Standard:Anzahl('Auftragsnummer aus Ablage',var vNr)=false) then RETURN true;

  "Auf~Nummer" # vNr;
  Erx # RecRead(410,1,0);
  If (Erx<>_rOK) then begin
    Msg(410010,AInt(vNr),0,0,0);
    RETURN false;
  end;


  TRANSON;

  // Posten verschieben
  vOk # y;
  WHILE (RecLink(411,410,9,_RecFirst)<=_rLocked) do begin

    // 09.01.2015 erst löschen für Sync
    RecBufCopy(411,401);
    Erx # Rekdelete(411);
    if (Erx<>_rOK) then begin
      vOK # n;
      BREAK;
    end;
    Erx # RekInsert(401);
    if (Erx<>_rOK) then begin
      vOK # n;
      BREAK;
    end;

    if (CUS_Data:MoveAll(411,401)=false) then begin
      vOK # n;
      BREAK;
    end;
    if (Anh_Data:CopyAll(411,401,y, n)=false) then begin
      vOK # n;
      BREAK;
    end;

    Erx # RecLink(411,410,9,_RecFirst);
  END;
  if (vOK=n) then begin
    TRANSBRK;
    Msg(410011,'',0,0,0);
    RETURN false;
  end;


  // Kopf verschieben
  RecBufCopy(410,400);
  // 09.01.2015 erst löschen für Sync
  Erx # Rekdelete(410);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(410011,'',0,0,0);
    RETURN false;
  end;
  "Auf.Löschmarker" # '';
  Erx # RekInsert(400);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(410011,'',0,0,0);
    RETURN false;
  end;

  if (CUS_Data:MoveAll(410,400)=false) then begin
    TRANSBRK;
    Msg(410011,'',0,0,0);
    RETURN false;
  end;
  if (Anh_Data:CopyAll(410,400,y, n)=false) then begin
    TRANSBRK;
    Msg(410011,'',0,0,0);
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;

end;


//========================================================================
// Reorganisation
//
//========================================================================
sub Reorganisation(aJobServer : logic; opt aBisDatum : date) : logic;
local begin
  Erx       : int;
  vDel      : logic;
  vOk       : logic;
  vVon,vBis : int;
  vBisDatum : date;
  vA        : alpha;
  vMessage  : alpha;
end;
begin
  
  // 05.12.2018
  if (aJobServer) then vA # 'y|' else vA # 'n|';
  if (aBisDatum>0.0.0) then vA # vA + cnvad(aBisDatum,_fmtNone);
  if (RunAFX('Auf.Reorg',vA)<>0) then RETURN (AfxRes=_rOK);


  // Sicherheitsabfrage
  if (aJobServer=n) then begin
    if (Msg(410000,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN true;
  end;
  Wupdate(gFrmMain);

  vVon      # 0;
  vBis      # 99999999;
  if (aBisDatum = 0.0.0) then
      aBisDatum # today;

  vBisDatum # aBisDatum;
  if (aJobServer=false) then begin
    if (Dlg_Standard:Anzahl(translate('von')+' '+translate('Auftragsnr.'), var vVon, 0)=false) then RETURN true;
    if (Dlg_Standard:Anzahl(translate('bis')+' '+translate('Auftragsnr.'), var vBis, 99999999)=false) then RETURN true;
    if (Dlg_Standard:Datum(translate('bis') + ' ' + translate('Anlagedatum'), var vBisDatum, today) = false) then RETURN true;
  end;

  vOk # y;
  // Köpfe loopen
  RecBufClear(400);
  Auf.Nummer # vVon;
  Erx # RecRead(400,1,0);
  Erx # RecRead(400,1,0);
  WHILE (Erx<=_rLocked) and (vOK) and (Auf.Nummer>=vVon) and (Auf.Nummer<=vBis) do begin
    vDel # (Erx=_rOK);

    // Lieferverträge erst löschen, wenn ALLE Abrufe gelöscht sind
    if (Auf.LiefervertragYN) then begin
      Erx # RecLink(401,400,23,_RecFirst);
      WHILE (Erx<=_rLocked) and (vDel) do begin
        if (Erx=_rLocked) or ("Auf.P.Löschmarker"<>'*') or ("Auf.P.aktionsmarker"='$') or (Auf.P.Anlage.Datum >= vBisDatum)  then vDel # n;
        Erx # RecLink(401,400,23,_RecNext);
      END;
    end;

    // Posten loopen
    Erx # RecLink(401,400,9,_RecFirst);
    WHILE (Erx<=_rLocked) and (vDel) do begin
      if (Erx=_rLocked) then begin
        vDel # n;
        BREAK;
      end;
      if ("Auf.P.aktionsmarker"='$') or (Auf.P.Anlage.Datum >= vBisDatum) then begin
        vDel # n;
        BREAK;
      end;

      // 18.02.2020 AH: Material noch mal prüfen...
      FOR Erx # RecLink(200,401,17,_recFirst)
      LOOP Erx # RecLink(200,401,17,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if ("Mat.Löschmarker"='') then begin
          vDel # n;
          BREAK;
        end;
      END;


      Erx # RecLink(835,401,5,_RecFirst);     // Auftragsart holen
      if (Erx>_rlocked) then RecBufClear(819);
      // offener LOHNAUFTRAG?
      if (AAr.Berechnungsart>=700) and (AAr.Berechnungsart<=799) and ("Auf.P.Löschmarker"<>'*') then begin
        // bereits Fakturiert und keine weiteren Mengen da?
        if (Auf.P.Prd.Rech>0.0) and (Auf.P.Prd.Plan=0.0) and (Auf.P.Prd.VSB=0.0) then begin
          // Position versuchen zu löschen...
          if (Auf_P_Subs:ToggleLoeschmarker(false)=false) then begin
            vDel # n;
            BREAK;
          end;
        end;
      end;

      if ("Auf.P.Löschmarker"<>'*') then vDel # n;
      Erx # RecLink(401,400,9,_RecNext);
    END;


    // alles gelöscht???
    if (vDel) then begin

      TRANSON;

      // Posten verschieben
      WHILE (RecLink(401,400,9,_RecFirst)<=_rLocked) do begin
        if ("Auf.P.Löschmarker"<>'*') then begin
          vOK # n;
          vMessage # 'Auf_P '+cnvai(Auf.P.Nummer) + '/'+cnvai(Auf.P.Position);
          BREAK;
        end;

        // 09.01.2015 erst löschen für Sync
        RecBufCopy(401,411);
        Erx # Rekdelete(401);
        if (Erx<>_rOK) then begin
          vOK # n;
          vMessage # 'Auf_P '+cnvai(Auf.P.Nummer) + '/'+cnvai(Auf.P.Position);
          BREAK;
        end;
        // 09.04.2020 AH: Ablage immer erst löschen!
        Erx # Rekdelete(411);
        Erx # RekInsert(411);
        if (Erx<>_rOK) then begin
          vOK # n;
          vMessage # 'Auf_P '+cnvai(Auf.P.Nummer) + '/'+cnvai(Auf.P.Position);
          BREAK;
        end;

        if (CUS_Data:MoveAll(401,411)=false) then begin
          vOK # n;
          vMessage # 'Auf_P '+cnvai(Auf.P.Nummer) + '/'+cnvai(Auf.P.Position);
          BREAK;
        end;
        if (Anh_Data:CopyAll(401,411,y, n)=false) then begin
          vOK # n;
          vMessage # 'Auf_P '+cnvai(Auf.P.Nummer) + '/'+cnvai(Auf.P.Position);
          BREAK;
        end;

        Erx # RecLink(401,400,9,_RecFirst);
      END;
      if (vOK=n) then begin
        TRANSBRK;
        BREAK;
      end;

      // Kopf verschieben
      RecBufCopy(400,410);
      // 09.01.2015 erst löschen für Sync
      Erx # Rekdelete(400);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        vOK # n;
        vMessage # 'Auf '+cnvai(Auf.Nummer);
        BREAK;
      end;
      "Auf~Löschmarker" # '*';
      // 09.04.2020 AH: Ablage immer erst löschen!
      Erx # Rekdelete(410);
      Erx # RekInsert(410);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        vOK # n;
        vMessage # 'Auf '+cnvai(Auf.Nummer);
        BREAK;
      end;

      if (CUS_Data:MoveAll(400,410)=false) then begin
        TRANSBRK;
        vOK # n;
        vMessage # 'Auf '+cnvai(Auf.Nummer);
        BREAK;
      end;
      if (Anh_Data:CopyAll(400,410,y, n)=false) then begin
        TRANSBRK;
        vOK # n;
        vMessage # 'Auf '+cnvai(Auf.Nummer);
        BREAK;
      end;

      TRANSOFF;

      // löschen war ok -> nächster Kopf
      Erx # RecRead(400,1,0);
      Erx # RecRead(400,1,0);
      CYCLE;
    end;  // Löschen


    // kein Löschen -> nächster Kopf
    Erx # RecRead(400,1,_recNext);

  END;  // Kopf-LOOP


  // Ergebnismeldung
  if (aJobServer=n) then begin
    if (vOk) then
      Msg(410001,'',0,0,0)
    else
      Msg(410002,vMessage,0,0,0);
  end;

  RETURN vOk;

end;

//========================================================================