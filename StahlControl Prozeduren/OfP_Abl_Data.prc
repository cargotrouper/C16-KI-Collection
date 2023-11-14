@A+
//===== Business-Control =================================================
//
//  Prozedur    OfP_Abl_Data
//                    OHNE E_R_G
//
//  Info
//    OfP Ablagenfunktionen
//
//  28.08.2008  PW  Erstellung der Prozedur
//  02.04.2013  AI  KEINE REK-Befehle bei Reorg wegen SQL
//  19.02.2014  AH  Anhänge werden mit Ablage verschoben und zurück
//  09.01.2015  AH  Rein/Raus mit Ablage nutzt DOCH Rek-Befehle (wegen dem Sync)
//  11.05.2017  AH  Reorg mit von-bis Nr und Datum
//  10.10.2017  AH  Rerogt mit Datumsparameter
//  05.12.2018  AH  AFX "Ofp.Reorg"
//  12.01.2022  ST  E r g --> Erx
//  12.01.2022  ST  Ablagenzurückholen per Markierung möglich 2343/2
//
//  Subprozeduren
//    SUB RestoreAusAblage() : logic;
//    SUB Reorganisation(aJobServer : logic; opt aBisDat : date;) : logic;
//
//========================================================================
@I:Def_Global


//========================================================================
//  _RestoreAusAblage
//
//========================================================================
sub _RestoreAusAblage(aNr : int;) : logic;
local begin
  Erx : int;
  vNr : int;
end;
begin
  "Ofp~Rechnungsnr" # aNr;
  Erx # RecRead(470,1,0);
  If (Erx <>_rOK) then begin
    Msg(470010,AInt(vNr),0,0,0);
    RETURN false;
  end;

  TRANSON;

  // Kopf verschieben
  RecBufCopy(470,460);

  // 09.01.2015 erst löschen für Sync
  Erx # RekDelete(470);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    if(aNr = 0) then
      Msg(470011,'',0,0,0);
    RETURN false;
  end;

  Erx # RekInsert(460);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    if(aNr = 0) then
      Msg(470011,'',0,0,0);
    RETURN false;
  end;

  if (CUS_Data:MoveAll(470,460)=false) then begin
    TRANSBRK;
    RETURN false;
  end;
  if (Anh_Data:CopyAll(470,460,y,n)=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  RestoreAusAblage
//    Steuert die Rückholvarianten
//========================================================================
sub RestoreAusAblage(opt aNr : int;) : logic;
local begin
  Erx       : int;
  vNr       : int;
  vOk       : logic;
  vMarkCnt  : int;
  vMarked   : int;
  vMFile    : int;
  vMID      : int;
  vErrCnt   : int;
end;
begin

  if (gFile<>470) then begin
    // Abfrage aus Ofp Verwaltung
    vNr # aNr;
    if(vNr = 0) then begin
      if (Dlg_Standard:Anzahl('Rechnungsnr. aus Ablage',var vNr)=false) then
        RETURN true;
    end;
    vOk # _RestoreAusAblage(vNr);
  
  end else begin
    
    // Markierte?
    vMarkCnt # Lib_Mark:Count(470);
    if (vMarkCnt>0) then begin
      if (Msg(997007,aint(vMarkCnt),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
        
        FOR   vMarked # gMarkList->CteRead(_CteFirst);
        LOOP  vMarked # gMarkList->CteRead(_CteNext, vMarked);
        WHILE (vMarked > 0) DO BEGIN
          Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
          if (vMFile=470) then begin
            Erx # RecRead(470, 0, _recId, vMID);
            if (_RestoreAusAblage("Ofp~Rechnungsnr")=false) then
              vErrCnt # vErrCnt + 1;
          end;
        END;
        
        vOK # (vErrCnt = 0);
        if (vOK) then
          Lib_Mark:Reset(470);
              
      end;

    end else begin

      // Einzelnen Satz zurückholen
      vOk # _RestoreAusAblage("Ofp~Rechnungsnr");
    
    end;
    
  end;
    
  RETURN vOK;
end;


//========================================================================
// Reorganisation
//
//========================================================================
sub Reorganisation(
  aJobServer  : logic;
  opt aBisDat : date) : logic;
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
  if (RunAFX('Ofp.Reorg',vA)<>0) then RETURN (AfxRes=_rOK);

  // Sicherheitsabfrage
  if (aJobServer=n) then begin
    if (Msg(470000,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN true;
  end;

  vBisDatum # today;
  if (aBisDat<>0.0.0) then vBisDatum # aBisDat;
  vVon # 0;
  vBis # 99999998;
  if (aJobServer=false) then begin
    if (Dlg_Standard:Anzahl(translate('von')+' '+translate('Rechnungsnr.'), var vVon, 0)=false) then RETURN true;
    if (Dlg_Standard:Anzahl(translate('bis')+' '+translate('Rechnungsnr.'), var vBis, 99999999)=false) then RETURN true;
    if (Dlg_Standard:Datum(translate('bis') + ' ' + translate('Anlagedatum'), var vBisDatum, today) = false) then RETURN true;
  end;


  vOk # y;

  // Posten loopen
  RecBufClear(460);
  Erl.Rechnungsnr # vVon;
  Erx # RecRead(460,1,0);
  Erx # RecRead(460,1,0);
  WHILE (Erx<=_rLocked) and (vOK) and (Erl.Rechnungsnr>=vVon) and (Erl.Rechnungsnr<=vBis) do begin
    vDel # (Erx=_rOK);

    if (Ofp.Anlage.Datum >= vBisDatum)  then vDel # n;
    if ("OfP.Löschmarker"<>'*') then vDel # n;

    // alles gelöscht???
    if (vDel) then begin

      TRANSON;

      RecBufCopy(460,470);

      // 09.01.2015 erst löschen für Sync
      Erx # Rekdelete(460);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        vOK # n;
        BREAK;
      end;

      Erx # RekDelete(470);
      Erx # RekInsert(470);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        vOK # n;
        BREAK;
      end;

      if (CUS_Data:MoveAll(460,470)=false) then begin
        TRANSBRK;
        vOK # n;
        BREAK;
      end;
      if (anh_Data:CopyAll(460,470,y,n)=false) then begin
        TRANSBRK;
        vOK # n;
        BREAK;
      end;

      TRANSOFF;

      // löschen war ok -> nächster Kopf
      Erx # RecRead(460,1,0);
      Erx # RecRead(460,1,0);
      CYCLE;
    end;  // Löschen


    // kein Löschen -> nächster Kopf
    Erx # RecRead(460,1,_recNext);

  END;  // Kopf-LOOP


  // Erxebnismeldung
  if (aJobServer=n) then begin
    if (vOk) then
      Msg(470001,'',0,0,0)
    else
      Msg(470002,'',0,0,0);
  end;

  RETURN vOk;
end;


//========================================================================