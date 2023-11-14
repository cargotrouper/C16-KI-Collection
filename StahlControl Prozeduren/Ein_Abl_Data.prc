@A+
//===== Business-Control =================================================
//
//  Prozedur    Ein_Abl_Data
//                    OHNE E_R_G
//  Info
//    OfP Ablagenfunktionen
//
//  28.08.2008  PW  Erstellung der Prozedur
//  02.04.2013  AI  KEINE REK-Befehle bei Reorg wegen SQL
//  19.02.2014  AH  Anhänge werden mit Ablage verschoben und zurück
//  09.01.2015  AH  Rein/Raus mit Ablage nutzt DOCH Rek-Befehle (wegen dem Sync)
//  11.05.2017  AH  Reorg mit "bis Anlagedatum"
//  10.10.2017  AH  Rerogt mit Datumsparameter
//  05.12.2018  AH  AFX "Ein.Reorg"
//  09.04.2020  AH  Reorg überschreibt knallhart die Ablage
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    sub RestoreAusAblage(opt aNr : int) : logic;
//    sub Reorganisation(aJobServer : logic; opt aBisDat : date;) : logic;
//
//========================================================================
@I:Def_Global

//========================================================================
//  RestoreAusAblage
//
//========================================================================
sub RestoreAusAblage(opt aNr : int) : logic;
local begin
  Erx   : int;
  vNr   : int;
  vOk   : logic;
end;
begin

  // Abfrage
  vNr # aNr;
  if (vNr=0) then
    if (Dlg_Standard:Anzahl('Bestellnummer aus Ablage',var vNr)=false) then RETURN true;

  "Ein~Nummer" # vNr;
  Erx # RecRead(510,1,0);
  If (Erx<>_rOK) then begin
    Msg(510010,AInt(vNr),0,0,0);
    RETURN false;
  end;


  TRANSON;

  // Posten verschieben
  vOk # y;
  WHILE (RecLink(511,510,9,_RecFirst)<=_rLocked) do begin

    RecBufCopy(511,501);

    // 09.01.2015 erst löschen für Sync
    Erx # Rekdelete(511);
    if (Erx<>_rOK) then begin
      vOK # n;
      BREAK;
    end;
    Erx # RekInsert(501);
    if (Erx<>_rOK) then begin
      vOK # n;
      BREAK;
    end;

    if (CUS_Data:MoveAll(511,501)=false) then begin
      vOK # n;
      BREAK;
    end;
    if (Anh_Data:CopyAll(511,501,y, n)=false) then begin
      vOK # n;
      BREAK;
    end;

    Erx # RecLink(511,510,9,_RecFirst);
  END;
  if (vOK=n) then begin
    TRANSBRK;
    Msg(510011,'',0,0,0);
    RETURN false;
  end;


  // Kopf verschieben
  RecBufCopy(510,500);

  // 09.01.2015 erst löschen für Sync
  Erx # Rekdelete(510);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(510011,'',0,0,0);
    RETURN false;
  end;
  "Ein.Löschmarker" # '';
  Erx # RekInsert(500);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(510011,'',0,0,0);
    RETURN false;
  end;

  if (CUS_Data:MoveAll(510,500)=false) then begin
    TRANSBRK;
    Msg(510011,'',0,0,0);
    RETURN false;
  end;
  if (Anh_Data:CopyAll(510,500, y, n)=false) then begin
    TRANSBRK;
    Msg(510011,'',0,0,0);
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;

end;


//========================================================================
// Reorganisation
//
//========================================================================
sub Reorganisation(
  aJobServer  : logic;
  opt aBisDat : date): logic;
local begin
  Erx       : int;
  vDel      : logic;
  vOk       : logic;
  vVon,vBis : int;
  vBisDatum : date;
  vA        : alpha;
end;
begin

  // 05.12.2018
  if (aJobServer) then vA # 'y|' else vA # 'n|';
  if (aBisDat>0.0.0) then vA # vA + cnvad(aBisDat,_fmtNone);
  if (RunAFX('Ein.Reorg',vA)<>0) then RETURN (AfxRes=_rOK);

  // Sicherheitsabfrage
  if (aJobServer=n) then begin
    if (Msg(510000,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN true;
  end;
  Wupdate(gFrmMain);


  vBisDatum # today;
  if (aBisDat<>0.0.0) then vBisDatum # aBisDat;

  vVon # 0;
  vBis # 99999999;
  if (aJobServer=false) then begin
    if (Dlg_Standard:Anzahl(translate('von')+' '+translate('Bestellnr.'), var vVon, 0)=false) then RETURN true;
    if (Dlg_Standard:Anzahl(translate('bis')+' '+translate('Bestellnr.'), var vBis, 99999999)=false) then RETURN true;
    if (Dlg_Standard:Datum(translate('bis') + ' ' + translate('Anlagedatum'), var vBisDatum, today) = false) then RETURN true;
  end;

  vOk # y;

  // Köpfe loopen
  RecBufClear(500);
  Ein.Nummer # vVon;
  Erx # RecRead(500,1,0);
  Erx # RecRead(500,1,0);
  WHILE (Erx<=_rLocked) and (vOK) and (Ein.Nummer>=vVon) and (Ein.Nummer<=vBis) do begin
    vDel # (Erx=_rOK);

    // Lieferverträge erst löschen, wenn ALLE Abrufe gelöscht sind
    if (Ein.LiefervertragYN) then begin
      Erx # RecLink(501,500,18,_RecFirst);
      WHILE (Erx<=_rLocked) and (vDel) do begin
        if (Erx=_rLocked) or ("Ein.P.Löschmarker"<>'*') then vDel # n;
        Erx # RecLink(501,500,18,_RecNext);
      END;
    end;

    // Posten loopen
    Erx # RecLink(501,500,9,_RecFirst);
    WHILE (Erx<=_rLocked) and (vDel) do begin
      if (Erx=_rLocked) or ("Ein.P.Löschmarker"<>'*') or (Ein.P.Anlage.Datum >= vBisDatum)  then vDel # n;
      Erx # RecLink(501,500,9,_RecNext);
    END;


    // alles gelöscht???
    if (vDel) then begin


      TRANSON;

      // Posten verschieben
      WHILE (RecLink(501,500,9,_RecFirst)<=_rLocked) do begin
        if ("Ein.P.Löschmarker"<>'*') then begin
          vOK # n;
          BREAK;
        end;

        // 09.01.2015 erst löschen für Sync
        RecBufCopy(501,511);
        Erx # Rekdelete(501);
        if (Erx<>_rOK) then begin
          vOK # n;
          BREAK;
        end;
        // 09.04.2020 AH: Ablage immer erst löschen!
        Erx # Rekdelete(511);
        Erx # RekInsert(511);
        if (Erx<>_rOK) then begin
          vOK # n;
          BREAK;
        end;


        if (CUS_Data:MoveAll(501,511)=false) then begin
          vOK # n;
          BREAK;
        end;
        if (Anh_Data:CopyAll(501,511,y, n)=false) then begin
          vOK # n;
          BREAK;
        end;

        Erx # RecLink(501,500,9,_RecFirst);
      END;
      if (vOK=n) then begin
        TRANSBRK;
        BREAK;
      end;

      // Kopf verschieben
      RecBufCopy(500,510);

      // 09.01.2015 erst löschen für Sync
      Erx # Rekdelete(500);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        vOK # n;
        BREAK;
      end;
      "Ein~Löschmarker" # '*';
      // 09.04.2020 AH: Ablage immer erst löschen!
      Erx # Rekdelete(510);
      Erx # RekInsert(510);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        vOK # n;
        BREAK;
      end;

      if (CUS_Data:MoveAll(500,510)=false) then begin
        TRANSBRK;
        vOK # n;
        BREAK;
      end;
      if (Anh_Data:CopyAll(500,510, y, n)=false) then begin
        TRANSBRK;
        vOK # n;
        BREAK;
      end;

      TRANSOFF;

      // löschen war ok -> nächster Kopf
      Erx # RecRead(500,1,0);
      Erx # RecRead(500,1,0);
      CYCLE;
    end;  // Löschen


    // kein Löschen -> nächster Kopf
    Erx # RecRead(500,1,_recNext);

  END;  // Kopf-LOOP


  // Ergebnismeldung
  if (aJobServer=n) then begin
    if (vOk) then
      Msg(510001,'',0,0,0)
    else
      Msg(510002,'',0,0,0);
  end;

  RETURN vOk;

end;

//========================================================================