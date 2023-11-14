@A+
//===== Business-Control =================================================
//
//  Prozedur  Mat_Abl_Data
//                OHNE E_R_G
//  Info      Ablagefunktionen
//
//
//  28.08.2008  AI  Erstellung der Prozedur
//  24.02.2010  MS  Reorg um "bis Ausgangsdatum" erweitert
//  30.11.2012  AI  Reorg überspringt reservierten Karten
//  02.04.2013  AI  KEINE REK-Befehle bei Reorg wegen SQL
//  19.02.2014  AH  Anhänge werden mit Ablage verschoben und zurück
//  17.10.2014  AH  MatSofortInAblage
//  09.01.2015  AH  Rein/Raus mit Ablage nutzt DOCH Rek-Befehle (wegen dem Sync)
//  12.01.2015  ST  Reorg über Jobserver, optionales Abgrenzungsdatum hinzugefügt
//  27.04.2015  AH  "SetAktuellenEKPreis"
//  23.08.2018  AH  Reorg ignoriert ggf. Reservierungen
//  05.12.2018  AH  AFX "Mat.Reorg"
//  09.04.2020  AH  Reorg überschreibt knallhart die Ablage
//  27.07.2021  AH  ERX
//  26.10.2021  AH  Reorg ohne Dialoge beim Job-Server
//
//  Subprozeduren
//  sub ReplaceAblage(aLock : int; aGrund : alpha; : int;
//  sub Reorganisation(aJobServer : logic; opt aBisDatum : date) : logic;
//  sub RestoreAusAblage(opt aNr: int) : logic;
//  sub SetAktuellenEKPreis(aReplace  : logic) : logic;
//
//========================================================================
@I:Def_Global

//========================================================================
//  ReplaceAblage
//
//========================================================================
sub ReplaceAblage(
  aLock   : int;
  aGrund  : alpha;
) : int;
local begin
  Erx         : int;
  vBuf200     : int;
  vWirdVkVsb  : logic;    // 2022-12-20 AH
end;
begin
  vBuf200 # RekSave(200);
  RecBufCopy(210,200);

  Mat_Data:_SetInternals(n);

  Erx # Mat_Data:_SetRef(var vWirdVkVsb);
  if (erx<>_rOK) then begin
    RekRestore(vBuf200);
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  RecBufCopy(200,210);
  RekRestore(vBuf200);

  TRANSON;
  Erx # RekReplace(210,aLock,aGrund);
  if (erx<>_rOK) then begin
    TRANSBRK;
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  TRANSOFF;

  Erg # Erx;    // TODOERX
  RETURN Erx;
end;


//========================================================================
// _Reorg_Check
//
//========================================================================
sub _Reorg_Check(
  aDate     : date;
  aResEgal  : logic): logic;
local begin
  Erx   : int;
  vMat  : int;
end;
begin
  if (aResEgal=false) then
    // 30.11.2012 AI : keine Reservierten
    if (RecLinkInfo(203,200,13,_reccOunt)>0) then RETURN false;

  vMat  # Mat.Nummer;
  RecBufClear(200);
  Mat.Ursprung # vMat;

  Erx # RecRead(200,2,0);   // Ursprung lesen
  WHILE (Erx<=_rMultikey) and (Mat.Ursprung=vMat) do begin
    if ("Mat.Löschmarker"<>'*') or (Mat.Ausgangsdatum >= aDate) then begin
      Mat.Nummer # vMat;
      RecRead(200,1,0);
      RETURN false;
    end;
    Erx # RecRead(200,2,_recNext);
  END;

  Mat.Nummer # vMat;
  RecRead(200,1,0);

  RETURN true;
end;


//========================================================================
//  MatNachAblage
//
//========================================================================
sub MatNachAblage() : logic;
local begin
  Erx : int;
end;
begin
  if ("Mat.Löschmarker"<>'*') then RETURN false;

  RecBufCopy(200,210);

  TRANSON;

  // 09.01.2015 erst löschen für Sync
  if (RekDelete(200)<>_rOK) then begin // 09.01.2015 DREHEN mit UNTEN
    TRANSBRK;
    RETURN false;
  end;
    // 09.04.2020 AH: Ablage immer erst löschen!
  Erx # Rekdelete(210);
  if (RekInsert(210)<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;

  if (CUS_Data:MoveAll(200,210)=false) then begin
    TRANSBRK;
    RETURN false;
  end;
  if (Anh_Data:CopyAll(200,210,y,n)=false) then begin
    TRANSBRK;
    RETURN false;
  end;


  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  MatAusAblage
//
//========================================================================
sub MatAusAblage() : logic;
begin

  RecBufCopy(210,200);

  TRANSON;

  // 09.01.2015 erst löschen für Sync
  if (RekDelete(210)<>_rOK) then begin  // 09.01.2015 DREHEN mit UNTEN
    TRANSBRK;
    RETURN false;
  end;
  if (RekInsert(200)<>_rOK) then begin  // 09.01.2015
    TRANSBRK;
    RETURN false;
  end;

  if (CUS_Data:MoveAll(210,200)=false) then begin
    TRANSBRK;
    RETURN false;
  end;
  if (Anh_Data:CopyAll(210,200,y,n)=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
// _BauminAblage
//
//========================================================================
sub _BaumNachAblage(): logic;
local begin
  Erx     : int;
  vBuf200 : int;
end;
begin
  vBuf200 # RekSave(200);

  TRANSON;

  Erx # RecRead(200,2,0);   // Ursprung lesen
  WHILE (Erx<=_rMultikey) and (Mat.Ursprung=vBuf200->Mat.Nummer) do begin

    if (MatNachAblage()=false) then begin
      TRANSBRK;
      RekRestore(vBuf200);
      RETURN false;
    end;

    Erx # RecRead(200,2,0);
    Erx # RecRead(200,2,0);
  END;

  TRANSOFF;

  RekRestore(vBuf200);
  RETURN true;
end;


//========================================================================
// Reorganisation
//
//========================================================================
sub Reorganisation(aJobServer : logic; opt aBisDatum : date) : logic;
local begin
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vQ        : alpha(1000);
  vCount    : int;
  vHdl      : int;
  vDia      : int;
  vOK       : logic;
  vBisDatum : date;
  vResEgal  : logic;
  vA        : alpha;
end;
begin

  // 05.12.2018
  if (aJobServer) then vA # 'y|' else vA # 'n|';
  if (aBisDatum>0.0.0) then vA # vA + cnvad(aBisDatum,_fmtNone);
  if (RunAFX('Mat.Reorg',vA)<>0) then RETURN (AfxRes=_rOK);

  vOk # y;
  vResEgal # dbalicense(_DbaSrvLicense)='TE150086MN'; // Knappstein

  // MatSofortInAblage
  if (Set.Mat.Del.SofortYN) then begin
    if (aJobServer=n) then begin
      if (Msg(210003,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN true;
    end;

    vQ # '"Mat.Löschmarker"=''*''';
    vSel # SelCreate(200,1);
    Erx # vSel->SelDefQuery( '', vQ );
    if (Erx != 0) then begin
      Lib_Sel:QError(vSel);
      Selclose(vSel);
      RETURN false;
    end;
    vSelName # Lib_Sel:SaveRun( var vSel, 0);

    if (aJobServer=false) then
      vDia # Lib_Progress:Init('Löschlauf...', SelInfo(vSel,_SelCount),y);

    FOR   Erx #  RecRead(200,vSel,_RecFirst)
    LOOP  Erx #  RecRead(200,vSel,_RecNext)
    WHILE Erx <= _rLocked DO BEGIN
      if (vDia<>0) then vDia->Lib_Progress:Step();
      if (MatNachAblage()=false) then begin
        vOK # false;
        BREAK;
      end;
    END;

    if (vDia<>0) then vDia->Lib_Progress:Term();

    SelClose(vSel); vSel # 0;
    SelDelete(200,vSelName);

    if (aJobServer=n) then begin
      if (vOK) then Msg(210001,'',0,0,0)
      else Msg(210002,'Fehler!',0,0,0);
    end;

    RETURN true;
  end;


  // Sicherheitsabfrage
  if (aJobServer=n) then begin
    if (Msg(210000,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN true;
    if (Dlg_Standard:Datum(translate('bis') + ' ' + translate('Ausgangsdatum'), var vBisDatum, today) = false) then RETURN true;
  end
  else begin

    if (aBisDatum = 0.0.0) then
      aBisDatum # today;

    vBisDatum # aBisDatum;
  end;

  vQ # 'Mat.Nummer = Mat.Ursprung AND "Mat.Vorgänger"=0 AND "Mat.Löschmarker"=''*''';

  vSel # SelCreate(200,1);
  Erx # vSel->SelDefQuery( '', vQ );
  if (Erx != 0) then begin
    Lib_Sel:QError(vSel);
    Selclose(vSel);
    RETURN false;
  end;
  vSelName # Lib_Sel:Save(vSel, '.REORG');

  vSel # vSel->SelOpen();
  // Selektion starten...
  SelRun(vSel,_SelDisplay | _SelServer | _SelServerAutoFld);


  // Prüflauf................................................................

  // Öffnen des Dialoges
  if (aJobServer=false) then
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (vDia != 0) then begin
    vHdl # Winsearch(vDia,'Label1');
    vHdl->wpcaption # Translate('Prüflauf...');
    $Progress->wpProgressPos # 0;
    $Progress->wpProgressMax # RecInfo(200,_RecCOunt,vSel);
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);
  end;

  vCount # 0;
  Erx # RecRead(200,vSel,_recFirst);    // Material loopen...
  WHILE (Erx<=_rMultikey) do begin
    inc(vCount);
    if (vDia<>0) then
      $Progress->wpProgressPos # vCount;

    if (_Reorg_Check(vBisDatum, vResEgal)=false) then begin
      SelRecDelete(vSel,200);
      Erx # RecRead(200,vSel,0);
      Erx # RecRead(200,vSel,0);
      CYCLE;
    end;

    Erx # RecRead(200,vSel,_recNext);
  END;


  if (vDia<>0) then vDia->WinClose();


  // Löschlauf................................................................

  // Öffnen des Dialoges
  if (aJobServer=false) then
    vDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (vDia != 0) then begin
    vHdl # Winsearch(vDia,'Label1');
    vHdl->wpcaption # Translate('Löschlauf...');
    $Progress->wpProgressPos # 0;
    $Progress->wpProgressMax # RecInfo(200,_RecCOunt,vSel);
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);
  end;


  vCount # 0;
  Erx # RecRead(200,vSel,_recFirst);    // MAterial loopen...
  WHILE (Erx<=_rMultikey) do begin
    inc(vCount);
    if (vDia<>0) then
      $Progress->wpProgressPos # vCount;

    if (_BaumNachAblage()=false) then begin
      vOK # n;
      BREAK;
    end;

    Erx # RecRead(200,vSel,_recNext);
  END;


  // Aufräumen
  SelClose(vSel); vSel # 0;
  SelDelete(200,vSelName);

  if (vDia<>0) then vDia->WinClose();


  if (aJobServer=n) then begin
    if (vOK) then Msg(210001,'',0,0,0)
    else Msg(210002,'Fehler!',0,0,0);
  end;

  RETURN true;
end;


//========================================================================
// _BaumAusAblage
//
//========================================================================
sub _BaumAusAblage(): logic;
local begin
  Erx     : int;
  vBuf210 : int;
end;
begin
  vBuf210 # RekSave(210);

  TRANSON;

  Erx # RecRead(210,2,0);   // Ursprung lesen
  WHILE (Erx<=_rMultikey) and ("Mat~Ursprung"=vBuf210->"Mat~Nummer") do begin

    if (MatAusAblage()=false) then begin
      TRANSBRK;
      RekRestore(vBuf210);
      RETURN false;
    end;

    Erx # RecRead(210,2,0);
    Erx # RecRead(210,2,0);
  END;

  TRANSOFF;

  RekRestore(vBuf210);
  RETURN true;
end;


//========================================================================
//  RestoreAusAblage
//
//========================================================================
sub RestoreAusAblage(opt aNr : int) : logic;
local begin
  Erx   : int;
  vNr   : int;
  vOK   : logic;
end;
begin

  // Abfrage
  vNr # aNr;
  if (vNr=0) then
    if (Dlg_Standard:Anzahl('Materialnummer aus Ablage',var vNr)=false) then RETURN true;

  "Mat~Nummer" # vNr;
  Erx # RecRead(210,1,0);
  If (Erx<>_rOK) then begin
    Msg(210010,AInt(vNr),0,0,0);
    RETURN false;
  end;


  // MatSofortInAblage
  if (Set.Mat.Del.SofortYN) then begin
    vOK # MatAusAblage();
  end;
  else begin
    vNr # "Mat~Ursprung";
    RecBufClear(210);
    "Mat~Nummer" # vNr;
    Erx # RecRead(210,1,0);
    If (Erx<>_rOK) then begin
      Msg(210010,AInt(vNr),0,0,0);
      RETURN false;
    end;

    vOK # _BaumAusAblage();
  end;


  if (vOK=false) then begin
    if (aNr=0) then Msg(210011,'',0,0,0);
    RETURN false;
    end
  else begin
    if (aNr=0) then Msg(999998,'',0,0,0);
  end;

  RETURN true;
end;


//========================================================================
//  SetAktuellenEKPreis
//                  Verändert den EK-Preis unter Beachtung von "Bewertungs.Laut"
//========================================================================
sub SetAktuellenEKPreis(
  aReplace  : logic;
) : logic;
local begin
  Erx     : int;
  vMenge  : float;
  vWert   : float;
end;
begin
  RecBufCopy(210,200);

  if (Mat.Bewertung.Laut<>'D') then RETURN true;

  if (Mat.Strukturnr='') then RETURN true;

  if (Mat.Strukturnr<>Art.Nummer) then
    Erx # RekLink(250,200,26,_recFirst);  // Artikel holen

  if (Art_P_Data:FindePreis('Ø-EK', 0, 0.0, '', 1)=false) then RETURN true;

  vMenge # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Art.MEH) ,2);
  vWert  # Rnd(Art.P.PreisW1 * vMenge / Cnvfi(Art.PEH) ,2); // Gesamtwert
//debugx('neuer EK auf Basis: '+anum(vMenge, 2)+Art.MEH+' mit Wert: '+anum(vWert,2));

  if (aReplace) then RecRead(210,1,_recLock);

  "Mat~Bewertung.Laut" # '';

  if ("Mat~Bestand.Gew"<>0.0) then
    "Mat~EK.Preis" # Rnd(vWert / "Mat~Bestand.Gew" * 1000.0 ,2);
  if ("Mat~Bestand.Menge"<>0.0) then
    "Mat~EK.PreisProMEH" # Rnd(vWert / "Mat~Bestand.Menge" ,2);
  "Mat~EK.Effektiv"       # "Mat~EK.Preis" + "Mat~Kosten";
  "Mat~EK.EffektivProME"  # "Mat~EK.PreisProMEH"  + "Mat~KostenProMEH";

  if (aReplace) then begin
    Erx # RekReplace(210,_recunlock,'AUTO');
    if (Erx<>_rOK) then RETURN false;
  end;

  RETURN true;
end;

//========================================================================