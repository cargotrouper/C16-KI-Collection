@A+
//===== Business-Control =================================================
//
//  Prozedur    Bdf_Abl_Data
//                  OHNE E_R_G
//  Info
//    OfP Ablagenfunktionen
//
//  2023-05-16  AH  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB RestoreAusAblage(opt aNr : int) : logic;
//    SUB Reorganisation(aJobServer : logic; opt aBisDatum : date) : logic;
//
//========================================================================
@I:Def_Global

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
    if (Dlg_Standard:Anzahl('Nummer aus Ablage',var vNr)=false) then RETURN true;

  "Bdf~Nummer" # vNr;
  Erx # RecRead(545,1,0);
  If (Erx<>_rOK) then begin
    Msg(545010,AInt(vNr),0,0,0);
    RETURN false;
  end;

  vOK # true;
  
  TRANSON;

  // erst löschen für Sync
  RecBufCopy(545,540);
  Erx # Rekdelete(545);
  if (Erx<>_rOK) then begin
    vOK # n;
  end;
  else begin
    Erx # RekInsert(540);
    if (Erx<>_rOK) then begin
      vOK # n;
    end
    else begin
      if (CUS_Data:MoveAll(545,540)=false) then begin
        vOK # n;
      end;
      else begin
        if (Anh_Data:CopyAll(545,540,y, n)=false) then begin
          vOK # n;
        end;
      end;
    end;
  end;
  
  if (vOK=n) then begin
    TRANSBRK;
    Msg(545011,'',0,0,0);
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
  if (RunAFX('Bdf.Reorg',vA)<>0) then RETURN (AfxRes=_rOK);

  // Sicherheitsabfrage
  if (aJobServer=n) then begin
    if (Msg(545000,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN true;
  end;
  Wupdate(gFrmMain);

  vVon      # 0;
  vBis      # 99999999;
  if (aBisDatum = 0.0.0) then
      aBisDatum # today;

  vBisDatum # aBisDatum;
  if (aJobServer=false) then begin
  end;

  vOk # y;
  TRANSON;

  // Bedarfe loopen
  Erx # RecRead(540,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if ("Bdf.Löschmarker"='') then begin
      Erx # RecRead(540,1,_RecNext);
      CYCLE;
    end;

    // erst löschen für Sync
    RecBufCopy(540,545);
    Erx # Rekdelete(540);
    if (Erx<>_rOK) then begin
      vOK # n;
      vMessage # 'Bdf_P '+cnvai(Bdf.Nummer);
      BREAK;
    end;
    // Ablage immer erst löschen!
    Erx # Rekdelete(545);
    Erx # RekInsert(545);
    if (Erx<>_rOK) then begin
      vOK # n;
      vMessage # 'Bdf '+cnvai(Bdf.Nummer);
      BREAK;
    end;

    if (CUS_Data:MoveAll(540,545)=false) then begin
      vOK # n;
      vMessage # 'Bdf '+cnvai(Bdf.Nummer);
      BREAK;
    end;
    if (Anh_Data:CopyAll(540,545,y, n)=false) then begin
      vOK # n;
      vMessage # 'Bdf '+cnvai(Bdf.Nummer);
      BREAK;
    end;

    Erx # RecRead(540,1,0);
    Erx # RecRead(540,1,0);
    CYCLE;
  END;
  if (vOK=n) then begin
    TRANSBRK;
  end
  else begin
    TRANSOFF;
  end;

  // Ergebnismeldung
  if (aJobServer=n) then begin
    if (vOk) then
      Msg(510001,'',0,0,0)
    else
      Msg(510002,vMessage,0,0,0);
  end;

  RETURN vOk;

end;

//========================================================================