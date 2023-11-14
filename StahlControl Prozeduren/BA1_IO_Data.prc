@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_IO_Data
//                  OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  23.07.2008  ST  Sub EinsatzRaus erwartet jetzt BA Input ID (wie Key 701/1)
//  28.01.2010  AI  Autoteilungsfunktion
//  02.02.2010  AI  EinsatzRaus entfernt beim Fahren Weiterbearbeitung/Fertigung
//  06.05.2010  AI  Artikel Reservierung wird benutzt
//  25.10.2010  AI  BruttoNetto für LFA-Reservierung
//  04.11.2010  AI  Erweiterung für LFA-MultiLFS
//  10.11.2010  AI  Autoteilung per Settings steuerbar
//  16.12.2011  AI  EinsatzRein lässt abweichende Mengen zu
//  09.01.2012  AI  kgMMMinMaxBestimmen buffert 703
//  09.07.2012  AI  MinMaxFertigungsRAD berechnet auch aus kg/mm usw. die RADs
//  22.02.2013  AI  "Replace" löscht auch Text
//  16.04.2013  AI  "Insert" für Fahren nimmt nur echte Einsätze (keine "Brüder")
//  22.04.2013  AI  MatMEH
//  26.06.2013  AH  Set.Mat.DispoAktivYN
//  27.06.2013  AH  "CreateBIS" erzeut mindestens 1 kg Schopf/BIS
//  06.03.2014  AH  "CreateBIS" erzeugt leere Fertigung 999 OHNE Einsatzplanmengen zu manipulieren
//  16.12.2014  AH  "EinsatzRein" hat Material falsch gelesen
//  09.02.2015  AH  "Replace": Gab immer Fehler, Typ C_IO_BAG neu wo anderes eingesetzt werden sollte
//  09.02.2015  AH  Neu: "OutputNachPos"
//  10.03.2015  AH  Neu: "Rename701Text"
//  10.03.2015  AH  enue AFX "BAG.IO.Replace" und "BAG.IO.Insert"
//  24.09.2015  AH  "OutputNachPos" setzt Teilungen auf Null
//  24.02.2017  AH  Bugfix wenn Materialstapel in mehreren LFA ist und ein Einsatz gelöscht wird
//  15.03.2017  AH  Bug: "OutputNachPos" prüft jetzt bei Nachfolger VK-Fahren, ob Einsatz auch Kommission trägt
//  17.01.2017  ST  Neu: Arbeitsgang "Umlagern"hinzugefügt
//  24.05.2019  AH  Fix: "EinsatzRein" für LFA legt auch die Fertigungen an
//  15.08.2019  AH  Fix: "EinsatzRaus" für LFA erlaubt, wenn nur stornierte FMs existieren
//  13.02.2020  AH  Neu: "AutoTeilungEchterEinsatz"
//  12.03.2020  AH  Fix: Einsatz Artikel/Beistellungen haben nicht mehr reserviert
//  17.12.2020  AH  Edit: Autoteilung nimmt Breite vom Einsatz, wenn in Fertigung nichts genannt ist
//  01.04.2021  AH  Fix: InsertMarkMat übernimmt Kommission
//  27.07.2021  AH  ERX
//  2022-07-05  AH  DEADLOCK
//  2022-09-12  ST  Edit: Prüfung bei BagP Löschung umgestellt von RecLinkCount auf "BA1_P_Data:BereitsVerwiegung"
//  2022-11-03  ST  Fix: Transaktionbreak bei VSB Löschungen "sub EinsatzRaus"
//
//  Subprozeduren
//    SUB Rename701Text(aNr : int; aAlt : int; aNeu : int);
//    SUB Insert(aLock : int; aGrund : alpha) : int;
//    SUB Replace(aLock : int; aGrund : alpha) : int;
//    SUB Delete(aLock : int; aGrund : alpha) : int;
//    SUB LoopCheck(aT : int; aA : alpha(4000)) : logic;
//    SUB EinsatzRaus(vEID : alpha) : logic;
//    SUB EinsatzRein(vBA : int; vPos : int; vMat : int; opt aStk : int; aGewN; float; aGewB: float; aMenge float) : logic;
//    SUB MaxFertigungsRID() : float;
//    SUB MinMaxFertigungsRAD(var aMinRAD : float; var aMaxRAD : float);
//    SUB CreateBIS() : logic;
//    SUB KGMMMinMaxBestimmen(var aMin : float; var aMax : float) : logic
//    SUB TeilungVonBis(aMin : float; aMax : float) : int;
//    SUB KGMM_Check(aMin : float; aMax : float) : logic;
//    SUB Autoteilung(var aKGMM_Kaputt  : logic) : logic;
//    SUB OutputNachPos(aBAG1 : int; aID : int; aBAG2 : int; aPos : int) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_aktionen

//@define LogFlow

declare Autoteilen(aMin : float; aMax : float) : int;
declare KGMMMinMaxBestimmen(var aMin : float; var aMax : float) : logic
declare KGMM_Check(aMin : float; aMax : float) : logic;


//========================================================================
//  Rename701Text
//
//========================================================================
sub Rename701Text(
  aNr       : int;
  aAlt      : int;
  aNeu      : int;
  opt aCopy : logic);
local begin
  vA, vB  : alpha;
end;
begin
  vA # '~701.'+CnvAI(aNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+CnvAI(aAlt,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  vB # '~701.'+CnvAI(aNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+CnvAI(aNeu,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  TextDelete(vB, 0);
  if (aCopy) then
    TextCopy(vA, vB, 0)
  else
    TextRename(vA, vB, 0);
//    vA # '~701.'+CnvAI(BAG.IO.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+CnvAI(BAG.IO.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
end;


//========================================================================
//  Insert
//
//========================================================================
sub Insert(
  aLock   : int;
  aGrund  : alpha;
) : int;
local begin
  Erx       : int;
  vBuf702   : int;
  vResGew   : float;
  vResMenge : float;
  vResStk   : int;
end;
begin

  BAG.IO.Anlage.Datum # today;
  BAG.IO.Anlage.Zeit  # now;
  BAG.IO.Anlage.User  # gUsername;

  if (RunAFX('BAG.IO.Insert',aint(aLock)+'|'+aGrund)<>0) then begin
    if (AfxRes<>_rOk) then RETURN AfxRes;
  end;

  TRANSON;

  // Fahren??
  // 11.2.2011
  if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.IO.NachBAG<>0) and (BAG.P.ZielVerkaufYN) and
    (BAG.Io.BruderID=0) then begin
//todo('neue fahrt:'+aint(bag.io.id));
    // 16.04.2013
    if (BA1_F_Data:InsertFahrt()<>_rOK) then begin
      TRANSBRK;
      Erg # _rnoRec; // TODOERX
      RETURN _rNoRec;
    end;
    // 16.04.2013:
    if (BAG.IO.NachPosition=BAG.F.Position) then
      BAG.IO.NachFertigung  # BAG.F.Fertigung;
  end;
  "BAG.IO.LöschenYN"  # n;

  BAG.IO.Anlage.Datum # today;    // 11.12.2019 AH: Doppelt machen, da evtl. InsertFahr verspringt!
  BAG.IO.Anlage.Zeit  # now;
  BAG.IO.Anlage.User  # gUsername;
  Erx # RekInsert(701,aLock,aGrund);
  if (erx<>_rOK) then begin
    TRANSBRK;
    Erg # ERX; // TODOERX
    RETURN Erx;
  end;

  Erx # Rso_Rsv_Data:Insert701();
  Erx # _rOK;
/***
Set.Mat.DispoAktivYN # false;   // STD dekativiert!
  if (Set.Mat.DispoAktivYN=n) then begin
    TRANSOFF;
    Erx # _rOK;
    Erg # ERX; // TODOERX
    RETURN Erx;
  end;


  RecBufClear(240);
  DiB.Datei # 701;
  DiB.ID1   # BAG.IO.Nummer;
  DiB.ID2   # BAG.IO.ID;
  vErx # Erx;
  Erx # RekDelete(240,0,'MAN');
  Erx # vErx;
***/
  // Input: Artikel...
  if ((BAG.IO.MaterialTyp=c_IO_Art) and (BAG.IO.VonBAG=0)) or
    (BAG.IO.MaterialTyp=c_IO_Beistell) then begin
    Erx # RecLink(250,701,8,_recFirst); // Artikel holen
    if (Erx<=_rLocked) then begin
      if (BA1_Art_Data:ArtEinsetzen()=false) then begin
        TRANSBRK;
        Erg # _rNOREC; // TODOERX
        RETURN _rnorec
      end;
    end;
  end;

  // Output: Weiterbearbeitung...
  if (BAG.IO.MaterialTyp=c_IO_BAG) and (BAG.IO.VonBAG<>0) then begin
    if (BAG.IO.NachBAG<>0) then begin
      vBuf702 # RecBufCreate(702);
      Erx # RecLink(vBuf702, 701, 4,_recfirst);   // nachPos holen
      if (Erx>_rLocked) or (vBuf702->BAG.P.Typ.VSBYN=n) then begin
        RecBufDestroy(vBuf702);
        TRANSOFF;
        Erg # ERX; // TODOERX
        RETURN Erx;
      end;
      RecBufDestroy(vBuf702);
    end;
/***
    "DiB.Güte"  # "BAG.IO.Güte";
    DiB.Dicke   # BAG.IO.Dicke;
    DiB.Breite  # BAG.IO.Breite;
    "DiB.Länge" # "BAG.IO.Länge";
    vErx # Erx;
    Erx # RekInsert(240,0,'AUTO');
    Erx # vErx;
***/
  end;

  TRANSOFF;

  Erx # _rOK;
  Erg # ERX; // TODOERX
  RETURN Erx;
end;


//========================================================================
//  Replace
//
//========================================================================
sub Replace(
  aLock   : int;
  aGrund  : alpha;
) : int;
local begin
  Erx       : int;
  vBuf702   : handle;
  vBuf703   : handle;
  vResGew   : float;
  vResStk   : int;
  vResMenge : float;
  vBufALT   : int;
  vErx      : int;
  vA        : alpha;
  vTxt      : int;
  v701Alt   : int;
  vRes      : int;
  vI        : int;
end;
begin

  // AFX
  if (RunAFX('BAG.IO.Replace',aint(aLock)+'|'+aGrund)<>0) then begin
    if (AfxRes<>_rOk) then RETURN AfxRes;
  end;

  TRANSON;

  // ggf. Text Löschen
  if ("BAG.IO.LöschenYN") then begin
    // 04.06.2021 AH: Fix für >999
    if (BAG.IO.ID<999) then
      vA # '~701.'+CnvAI(BAG.IO.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+
            CnvAI(BAG.IO.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
    else
      vA # '~701.'+CnvAI(BAG.IO.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+
            CnvAI(BAG.IO.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,5);
    vTxt # TextOpen(16);
    if (vTxt->TextRead(vA,_TextNoContents) = _rOK) then begin
      vTxt->TextClose();
      if (TxtDelete(vA,0) <> 0) then begin
        TRANSBRK;
        Erg # _rLocked; // TODOERX
        RETURN _rLocked;
      end;
    end;
  end;


  // Fahren??
  // 11.2.2011
  if (BAG.IO.NachFertigung=0) and
    (BAG.IO.VonPosition<>BAG.P.Position) and
    (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.IO.NachBAG<>0) and (BAG.P.ZielVerkaufYN) and
    // 16.04.2013
    (BAG.Io.BruderID=0) then begin
//todo('REP neue fahrt:'+aint(bag.io.id)+'  nach '+aint(bag.io.nachfertigung));
    if (BA1_F_Data:InsertFahrt()<>_rOK) then begin
      TRANSBRK;
      Erg # _rNoRec; // TODOERX
      RETURN _rNoRec;
    end;
    // 16.04.2013:
    if (BAG.IO.NachPosition=BAG.F.Position) then
      BAG.IO.NachFertigung # BAG.F.Fertigung;
  end;


  // Input: Artikel...
  if ((BAG.IO.MaterialTyp=c_IO_Art) and (BAG.IO.VonBAG=0)) or
    (BAG.IO.MaterialTyp=c_IO_Beistell) then begin

    Erx # RecLink(250,701,8,_recFirst); // Artikel holen
    if (Erx<=_rLocked) then begin

      vBufALT # RecBufCreate(701);
      RecRead(vBufALT, 0,0, RecInfo(701,_recID));

      vResStk   # BAG.IO.Plan.In.Stk    - vBufALT->BAG.IO.PLan.In.Stk;
      vResGew   # BAG.IO.Plan.In.GewN   - vBufALT->BAG.IO.PLan.In.GewN;
      RecBufDestroy(vBufALT);
      vResMenge # Lib_Einheiten:WandleMEH(701, vResStk, vResGew, vResGew, 'kg', Art.MEH);
      if (BA1_Art_Data:ArtResUpdate(vResStk, vResMenge)=false) then begin
        TRANSBRK;
        Erg # _rNoRec; // TODOERX
        RETURN _rnorec
      end;

/** 06.04.2010 AI
      RecBufClear(252);
      Art.C.ArtikelNr       # Art.Nummer;
      Art_Data:OpenCharge(y);
      vResStk   # BAG.IO.Plan.In.Stk    - vBufALT->BAG.IO.PLan.In.Stk;
      vResGew   # BAG.IO.Plan.In.GewN   - vBufALT->BAG.IO.PLan.In.GewN;
      RecBufDestroy(vBufALT);

      vResMenge # Lib_Einheiten:WandleMEH(701, vResStk, vResGew, vResGew, 'kg', Art.MEH);
      Art.C.Reserviert      # Art.C.Reserviert      + vResMenge;
      Art.C.Reserviert.Stk  # Art.C.Reserviert.Stk  + vResStk;
      Art_Data:WriteCharge(n);
*/
    end;
  end;

  // Input: Material...
  if (BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.VonBAG=0) then begin

    // FAHREN ----------------------------------------------------------------
    // TODO or ArG.Typ.ReservInput if (ArG.Aktion2<>BAG.P.Aktion2) then Erx # RecLink(828,702,8,_recFirst);
    if (BA1_P_Data:ReservierenStattStatus(BAG.P.Aktion,701)) then begin
      Mat.Nummer # BAG.IO.Materialnr;
      Erx # RecRead(200,1,0);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Erg # _rNoRec; // TODOERX
        RETURN _rNoRec;
      end;
      // FAHR-Reservierung löschen...
      Erx # RecLink(203,200,13,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        if ("Mat.R.Trägertyp"=c_Akt_BAInput) and ("Mat.R.TrägerNummer1"=BAG.IO.Nummer) and
          ("Mat.R.TrägerNummer2"=BAG.IO.ID) then BREAK;
        Erx # RecLink(203,200,13,_recNext);
      END;
      if (Erx<=_rLocked) then begin
        vRes # Mat.R.Reservierungnr;
        if (Mat_Rsv_Data:Entfernen()=false) then begin
          TRANSBRK;
          Erg # _rNoRec; // TODOERX
          RETURN _rNoRec;
        end;
      end;

      // FAHR-Reservierung neu anlegen ...
      vBuf703 # RecBufCreate(703);
      Erx # RecLink(vBuf703,701,10,_recFirst);   // NACH Fertigung holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(vBuf703,702,4,_recFirst);   // 1. Fertigung holen
        if (Erx>_rLocked) then RecBufClear(vBuf703);
      end;

      Erx # RecLink(818,200,10,_recfirst);  // Verwiegungsart holen
      if (Erx>_rLocked) then begin
        RecBufClear(818);
        VwA.NettoYN # y;
      end;

      RecBufClear(203);
      Mat.R.Materialnr      # BAG.IO.Materialnr;
      "Mat.R.Stückzahl"     # BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk;
      if (VWa.NettoYN) then
        Mat.R.Gewicht       # BAG.IO.Plan.Out.GewN - BAG.IO.Ist.Out.GewN
      else
        Mat.R.Gewicht       # BAG.IO.Plan.Out.GewB - BAG.IO.Ist.Out.GewB;

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
      if (Mat_Rsv_Data:Neuanlegen(vRes)=false) then begin
        TRANSBRK;
        Erg # _rNoRec; // TODOERX
        RETURN _rnoRec;
      end;
      
      // 03.11.2021 AH   ggf. komplette Karte auf "zum Fahren" setzen
      RecRead(200,1,0);
      if (Mat.Bestand.Stk<="Mat.R.Stückzahl") and (Mat.Bestand.Gew<="Mat.R.Gewicht") then begin
//      (RecLinkInfo(203,200,13,_recCount)=1) then begin    2022-06-23  AH: 2352/21
        if (BAG.P.Aktion=c_BAG_Fahr09) then begin
          Mat_Data:SetStatus(c_Status_BAGZumFahren);
          vI # Mat.Status;
        end
        else if (BAG.P.Aktion=c_BAG_Bereit) then begin
          Mat_Data:SetStatus(c_Status_BAGBereitgestellt);
          vI # Mat.Status;
        end;
      end
      else if (Mat.Status>700) and ((BAG.P.Aktion=c_BAG_Fahr09) or (BAG.P.Aktion=c_BAG_Bereit)) then begin
        Mat_Data:SetStatus(c_Status_frei);
        vI # Mat.Status;
      end;
      RecRead(200,1,0);
      if (Mat.Status<>vI) and (vI<>0) then begin    // Status ändern???
        Erx # RecRead(200,1,_reCLock);
        if (erx=_rOK) then begin
          Mat.Status # vI;
          Erx # Mat_Data:Replace(_recUnlock,'AUTO');  // 07.12.2020 AH Proj. 2151/45 /  26.02.2021 AH: ZURÜCK !!!
        end;
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Erg # _rNoRec; // TODOERX
          RETURN _rnoRec;
        end;
      end;
     
    end;  // Fahren
  end;

  v701Alt # RecBufCreate(701);
  RecRead(v701Alt, 0, _recId, RecInfo(701,_recID));

  // Speichern...
  Erx # RekReplace(701,aLock,aGrund);
  if (Erx<>_rOK) then begin
    RecBufDestroy(v701Alt);
    TRANSBRK;
    Erg # ERX; // TODOERX
    RETURN Erx;
  end;


  // 09.09.2020 TEST
  if (Set.Installname=^'HOWVFP') or (Set.Installname=^'HOWVVF') then begin
  end
  else begin
    Rso_Rsv_Data:Update701(v701Alt);
  end;
  RecBufDestroy(v701Alt);
  Erx # _rOK;

/***
Set.Mat.DispoAktivYN # false;   // STD dekativiert!
  if (Set.Mat.DispoAktivYN=n) then begin
    TRANSOFF;
    Erx # _rOK;
    RETURN Erx;
  end;


  RecBufClear(240);
  DiB.Datei # 701;
  DiB.ID1   # BAG.IO.Nummer;
  DiB.ID2   # BAG.IO.ID;
  vErx # Erx;
  Erx # RekDelete(240,0,'MAN');
  Erx # vErx;
***/
  // Output: Weiterbearbeitung...
  if (BAG.IO.MaterialTyp=c_IO_BAG) and (BAG.IO.VonBAG<>0) then begin
    // 07.02.2015 AH: Gab immer Fehler, C_IO_BAG neu wo anderes eingesetzte werden soll?? Deaktivert!!
//    if (BAG.IO.NachBAG<>0) then begin
//      vBuf702 # RecBufCreate(702);
//      Erx # RecLink(vBuf702, 701, 4,_recfirst);   // nachPos holen
//      if (Erx>_rLocked) or (vBuf702->BAG.P.Typ.VSBYN=n) then begin
//        RecBufDestroy(vBuf702);
//        TRANSOFF;
//        Erg # ERX; // TODOERX
//        RETURN Erx;
//      end;
//      RecBufDestroy(vBuf702);
//    end;
/***
    "DiB.Güte"  # "BAG.IO.Güte";
    DiB.Dicke   # BAG.IO.Dicke;
    DiB.Breite  # BAG.IO.Breite;
    "DiB.Länge" # "BAG.IO.Länge";
    vErx # Erx;
    Erx # RekInsert(240,0,'AUTO');
    Erx # vErx;
***/
  end;

  TRANSOFF;

  Erg # ERX; // TODOERX
  RETURN Erx;
end;


//========================================================================
//  Delete
//
//========================================================================
sub Delete(
  aLock   : int;
  aGrund  : alpha;
) : int;
local begin
  Erx       : int;
  vResMenge : float;
  vResGew   : float;
  vResStk   : int;
  vErx      : int;
end;
begin

  TRANSON;

  Erx # RekDelete(701,aLock,aGrund);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Erg # ERX; // TODOERX
    RETURN Erx;
  end;

  Erx # Rso_Rsv_Data:Delete701();
  if (Erx=_rLocked) or (Erx=_rDeadlock) then begin
    TRANSBRK;
    Erg # ERX; // TODOERX
    RETURN Erx;
  end;
//  Erx # _rOK; 2022-07-05  AH DEADLOCK

@ifdef LogFlow
debugx('Delete ID:'+aint(BAG.IO.ID));
@endif

  RecBufClear(240);
  DiB.Datei # 701;
  DiB.ID1   # BAG.IO.Nummer;
  DiB.ID2   # BAG.IO.ID;
  vErx # Erx;
  Erx # RecRead(240,1,0);
  if (erx<=_rLocked) then begin
    Erx # RekDelete(240,0,'MAN');
    if (Erx=_rLocked) or (Erx=_rDeadlock) then begin
      TRANSBRK;
      Erg # ERX; // TODOERX
      RETURN Erx;
    end;
  end;
  Erx # vErx;

  TRANSOFF;

  Erg # _rOK // TODOERX
  RETURN _rOK;
end;


//========================================================================
//  LoopCheck
//
//========================================================================
sub LoopCheck(aT : int; aA : alpha(4000)) : logic;
local begin
  vErx    : int;
  vA      : alpha;
  vBuf701 : int;
  vBuf702 : int;
  vOk     : logic;
  vFirst  : logic;
  vNr     : int;
  vPos    : int;
  vID     : int;
end;
begin
  vBuf701 # RecBufCreate(701);
  RecBufCopy(701,vBuf701);
  vBuf702 # RecBufCreate(702);
  RecBufCopy(702,vBuf702);

  if (aT=0) then begin            // 1. Aufruf?
    aT # Textopen(3);
    vFirst # y;
  end;

  vOk # y;


  // aktuelle Position aufnehmen
  vA # 'P'+Cnvai(BAG.P.Nummer)+'/'+cnvai(BAG.P.Position)+',';
  if (StrFind(aA,vA,1)<>0) then begin
    RecBufCopy(vBuf701,701);
    RecBufDestroy(vBuf701);
    RecBufCopy(vBuf702,702);
    RecBufDestroy(vBuf702);
    RETURN false;
  end;

  if (TextSearch(aT,1,1,0,vA)<>0) then begin  // schon geprüft?
    RecBufCopy(vBuf701,701);
    RecBufDestroy(vBuf701);
    RecBufCopy(vBuf702,702);
    RecBufDestroy(vBuf702);
    RETURN true;
  end
  else begin
    TextLineWrite(aT,1,vA,_TextLineInsert);
  end;

  if (vFirst) then begin
    if (BAG.IO.MaterialTyp=c_IO_BAG) then begin
      RecLink(702,701,2,_recFirst);   // Vorgänger Arbeitsgang holen
      vOk # LoopCheck(aT,vA);
    end;

  end
  else begin

    vErx # RecLink(701,702,2,_RecFirst);    // Input loopen
    WHILE (vErx<=_rLocked) and (vOK) do begin
      if (BAG.IO.MaterialTyp=c_IO_BAG) then begin
        vNr   # BAG.P.Nummer;
        vPos  # BAG.P.Position;
        vID   # BAG.IO.ID;
        RecLink(702,701,2,_recFirst);       // Vorgänger Arbeitsgang holen

        vOk # LoopCheck(aT,aA+vA);

        BAG.P.Nummer    # vNr;
        BAG.P.Position  # vPos;
        BAG.IO.ID       # vID;
        RecRead(701,1,0);
        RecRead(702,1,0);
      end;
      vErx # RecLink(701,702,2,_RecNext);
    END;
  end;

  RecBufCopy(vBuf701,701);
  RecBufDestroy(vBuf701);
  RecBufCopy(vBuf702,702);
  RecBufDestroy(vBuf702);

  if (vFirst) then begin
//    Txtwrite(aT,'c:\test.txt',_textExtern);
    TextClose(aT);
  end;

  RETURN vOK;
end;


//========================================================================
//  EinsatzRaus
//
//========================================================================
SUB EinsatzRaus(aEID : alpha) : logic;
local begin
  Erx         : int;
  vBuf702     : int;
  vBuf701     : int;
  vOk         : logic;
  vBA         : alpha;
  vBAin       : alpha;
  vDelPosBuf  : int;
  vCheck      : logic;
  vVSBKillen  : logic;
  vNoFertKill : logic;
  vKillFert   : int;
  v701        : int;
  v701Alt     : int;
end;
begin

  // BA-Einsatz aus Argument extrahieren und lesen
  BAG.IO.Nummer # Cnvia(Str_Token(aEID,'/',1));
  BAG.IO.ID     # Cnvia(Str_Token(aEID,'/',2));
  Erx # RecRead(701,1,0);
  if (Erx<>_rOK) then RETURN false;

  // BA-Kopf lesen
  Erx # RecLink(700,701,1,_recfirst);
  if (Erx>=_rLocked) then RETURN false;

  // BA-Position lesen
  Erx # RecLink(702,701,4,_recfirst);
  if (Erx>=_rLocked) then RETURN false;

  // --------------------------------------------
  // Echtes Material muss vorerste geprüft werden
  if (BAG.IO.Materialtyp = c_IO_Mat) then begin

    Mat.Nummer # BAG.IO.Materialnr;
    Erx # RecRead(200,1,0); // Material holen
    if (Erx<>_rOK) then RETURN false;

    if (BA1_P_Data:ReservierenStattStatus(BAG.P.Aktion,701)=false) then
      if ("Mat.Löschmarker"<>'*') then RETURN false;

    v701 # RekSave(701);  // 24.02.2017 AH

    Erx # RecLink(701,200,29,_recLast); // letzten Input holen
    WHILE (Erx<=_rLocked) and (BAG.IO.VonBAG<>0) do
      Erx # RecLink(701,200,29,_recPrev);
    if (Erx>_rLocked) then begin
      vNoFertKill # y;
      Erx # RecLink(701,200,29,_recLast); // letzten Input holen
    end;
    if (Erx<>_rOK) then RETURN false;

    RekRestore(v701); // 24.02.2017 AH
  end;

  // --------------------------------------------
  // beim FAHREN und EK-VSB-Material evtl. das Material löschen
  if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.IO.Materialtyp = c_IO_VSB) then begin
    if ((BAG.IO.Plan.Out.GewN<>0.0) or (BAG.IO.Plan.Out.GewB<>0.0) or
      (BAG.IO.Ist.Out.GewN<>0.0) or (BAG.IO.Ist.Out.GewB<>0.0)) AND
      (Set.LFS.MatBeiAbschl='A') then begin
      if (msg(701028,'',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes) then begin
        vVSBKillen # y;
        Erx # Mat_Data:read(BAG.IO.Materialnr);   // Material holen
        If (Erx<200) then begin
          Msg(701012,'',0,0,0);
          RETURN false;
        end;
      end;
    end;
  end;


  vCheck # y;
  if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.IO.Materialnr=0) then vCheck # n;

  if (vCheck) then begin
    // bereits Verwogen?
    vBuf702 # RekSave(702);
    // nächste Pos. holen
    RecLink(702,701,4,_recFirst);
    vOK # true;
    if (BA1_P_Data:ReservierenStattStatus(BAG.P.Aktion,701)) then begin
      // 15.08.2019 AH: wegen Entfernen im LFA
      FOR Erx # RecLink(707,701,12,_recFirst)
      LOOP Erx # RecLink(707,701,12,_recNext)
      WHILE (Erx<=_rLocked) and (vOK) do begin
        if (BAG.FM.Status=1) then vOK # false;
      END;
    end
    else begin
    
    /*
      if (RecLinkInfo(707,702,5,_RecCount)<>0) then
        vOK # false;   // FM der Pos zählen
    */
      if (BA1_P_Data:BereitsVerwiegung(BAG.P.Aktion) = true) or
         (RecLinkInfo(709,702,6,_RecCount)>0) then
         vOK # false;
         
    end;
    RekRestore(vBuf702);
    if (vOk=n) then begin
      Msg(701007,'',0,0,0);
      RETURN false;
    end;
  end;


  TRANSON;


  // bei Fahraufträgen auch Fertigung löschen...
  // 11.2.2011
  if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.P.ZielVerkaufYN) and (vNoFertKill=n) then begin
    if (BAG.IO.NachID<>0) then begin
      vBuf701 # RekSave(701);
      BAG.IO.ID # BAG.IO.NAchID;
      Erx # RecRead(701,1,0);   // Output holen
      if (Erx<=_rLocked) then begin
        vBuf702 # RekSave(702);
        // nächste Pos. holen
        Erx # RecLink(702,701,4,_recFirst);
        if (Erx<=_rLocked) and (BAG.P.Typ.VSBYN) then begin
          // wenn keine weiteren Einsatzkarten dafür vorgesehen sind, diese VSB zum Löschen merken
          if (RecLinkInfo(701,702,2,_RecCount)<=1) then begin
            vDelPosBuf # RekSave(702);
          end;
        end;
        RekRestore(vBuf702);
      end;
      RekRestore(vBuf701);
    end;

    Erx # ReclInk(703,701,10,_recFirst);    // Fertigung holen
    if (Erx<=_rLocked) and (vNoFertKill=n) then begin
      // 20.02.2012 AI
      vKillFert # BAG.F.Fertigung;
      //BA1_F_Data:Delete();
    end;
  end;


  // Eintrag zum Löschen markieren
  Erx # RecRead(701,1,_recLock);
  if (erx=_rOK) then begin
    "BAG.IO.LöschenYN" # y;
    Erx # Replace(_recUnlock,'AUTO');
  end;
  if (Erx<>_rOK) then begin    // 2022-07-05 AH DEADLOCK
    TRANSBRK;
    Msg(999999,thisline,0,0,0);
    RETURN false;
  end;
  

  // HIER WIRD LFS-POS GELÖSCHT....
  // Output aktualisieren
  if (BA1_F_Data:UpdateOutput(701,y)=false) then begin
    if (vDelPosBuf<>0) then RecBufdestroy(vDelPosBuf);
    TRANSBRK;
    ERROROUTPUT;  // 01.07.2019
    RETURN false;
  end;

  // 20.02.2012 AI
  if (vKillFert<>0) then begin
    BAG.F.Nummer    # BAG.P.Nummer;
    BAG.F.Position  # BAG.P.Position;
    BAG.F.Fertigung # vKillFert;
    Erx # RecRead(703,1,0);
    if (Erx<=_rLocked) then begin//and (RecLinkInfo(701,703,3,_reccount)=0) then begin
      BA1_F_Data:Delete();
    end;
  end;


  // ECHTES Einsatzmaterial reaktivieren?
  if (BAG.IO.Materialtyp = c_IO_MAt) then begin
    if (BA1_Mat_Data:MatFreigeben()=false) then begin
      if (vDelPosBuf<>0) then RecBufdestroy(vDelPosBuf);
      TRANSBRK;
      Msg(701006,'',0,0,0);
      RETURN false;
    end;
  end;


  // EK-VSB Einsatzmaterial reaktivieren?
  if (BAG.IO.Materialtyp = c_IO_VSB) then begin
    if (BA1_Mat_Data:VSBFreigeben()=false) then begin
      if (vDelPosBuf<>0) then RecBufdestroy(vDelPosBuf);
      TRANSBRK;
      Msg(701006,'',0,0,0);
      RETURN false;
    end;

    if (vVSBKillen) then begin
      Erx # RecLink(501,200,18,_recFirst);  // Bestellpos holen
      If (Erx>_rLocked) then begin
        TRANSBRK;
        Msg(701013,'',0,0,0);
        RETURN false;
      end;
      Erx # RecLink(500,501,3,_recFirst);   // Bestellkopf holen
      Erx # RecLink(506,200,20,_recFirst);  // Wareneingang holen
      If (Erx>_rLocked) then begin
        TRANSBRK;
        Msg(701013,'',0,0,0);
        RETURN false;
      end;

      if (Ein_E_Data:StornoVSBMat()=false) then begin
        TRANSBRK;
        ErrorOutput;
        RETURN false;
      end;
    end;

  end;

// 06.05.2010 AI
  // Artikel?
  if (BAG.IO.Materialtyp = c_IO_Art) then begin
    if (BA1_Art_Data:ArtFreigeben()=false) then begin
      if (vDelPosBuf<>0) then RecBufdestroy(vDelPosBuf);
      TRANSBRK;
      Msg(701006,'',0,0,0);
      RETURN false;
    end;
  end;

  if (vNoFertKill=n) then begin
    Erx # RekDelete(701,0,'MAN');
    if (erx<>_rOK) then begin
      if (vDelPosBuf<>0) then RecBufdestroy(vDelPosBuf);
      TRANSBRK;
      RETURN false;
    end;
    Erx # Rso_Rsv_Data:Delete701();
//    Erx # _rOK;   2022-07-05  AH DEADLOCK?!?
  end
  else begin
    Erx # RecRead(701,1,_recLock);
    if (erx=_rOK) then begin
      BAG.IO.NachPosition   # 0;
      BAG.IO.NachBAG        # 0;
      BAG.IO.NachFertigung  # 0;
      BAG.IO.NachID         # 0;
      v701Alt # RecBufCreate(701);
      RecRead(v701Alt, 0, _recId, RecInfo(701,_recID));
      Erx # RekReplace(701,_recUnlock,'MAN');
    end;
    if (erx=_rOK) then begin
      Erx # Rso_Rsv_Data:Update701(v701Alt);
//      Erx # _rOK; 2022-07-05  AH DEADLOCK
    end;
    RecBufDestroy(v701Alt);
  end;
  if (Erx<>_rOK) then begin
    if (vDelPosBuf<>0) then RecBufdestroy(vDelPosBuf);
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  // nächste Pos. holen
  RecLink(702,701,4,_recFirst);
  // alle Fertigungen neu errechnen
  BA1_P_Data:ErrechnePlanmengen();

  BA1_P_Data:UpdateSort();

  // nachfolgende Position ist zu auch löschen (bei VSB nach Fahren)
  if (vDelPosBuf<>0) then begin
    vBuf702 # RekSave(702);
    RekRestore(vDelPosBuf);
    if (BA1_P_Data:Delete(false)=false) then begin
      RekRestore(vBuf702);
      TRANSBRK;
      Erroroutput;
      RETURN false;
    end;
    RekRestore(vBuf702);
  end;


  RETURN true;
end;


//========================================================================
//  EinsatzRein
//
//========================================================================
SUB EinsatzRein(
  aBA         : int;
  aPos        : int;
  aMat        : int;
  opt aStk    : int;
  opt aGewN   : float;
  opt aGewB   : float;
  opt aMenge  : float;) : logic;
local begin
  Erx     : int;
  vNr     : int;
  vOK     : logic;

  vStk    : int;
  vGew    : float;
  vM      : float;
  vBem    : alpha;
  vBuf701 : int;
  vVonID  : int;
  vAdr    : int;
  vAns    : int;
  v701    : int;
end;
begin

  BAG.Nummer # aBA;
  Erx # RecRead(700,1,0);   // BA holen
  if (Erx<>_rOK) then RETURN false;
  if (BAG.Fertig.Datum<>0.0.0) then RETURN false;

  if (aPos<>0) then begin
    BAG.P.Nummer    # aBA;
    BAG.P.Position  # aPos;
    Erx # RecRead(702,1,0);   // BA-Position holen
    if (Erx<>_rOK) then RETURN false;
    if (BAG.P.Fertig.Dat<>0.0.0) then RETURN false;
  end;

  Mat.Nummer # aMat;
  Erx # RecRead(200,1,0);   // Material holen
  if (Erx<>_rOK) then RETURN false;

  if ("Mat.Löschmarker"='*') then RETURN false;


  // Datensatz vorbelegen...
  Erx # RecLink(701,700,3,_recLast);  // letzten IO holen
  if (Erx<=_rLocked) then vNr # 1
  else vNr # BAG.IO.ID + 1;

  RecBufClear(701);
  BAG.IO.ID # vNr;
  BAG.IO.Nummer         # BAG.P.Nummer;
  BAG.IO.NachBAG        # BAG.P.Nummer;
  BAG.IO.NachPosition   # BAG.P.Position;
  BAG.IO.AutoTeilungYN  # y;

  if ("BAG.P.Typ.1in-1outYN") then    // 1zu1 Arbeitsgang?
    BAG.IO.NachFertigung # 1;
  BAG.IO.NachBAG      # BAG.Nummer;
  BAG.IO.NachPosition # BAG.P.Position;

  // 2023-08-17 AH    Proj. 2430/109
  if (Mat.Status=502) then
    BAG.IO.Materialtyp    # c_IO_VSB
  else
    BAG.IO.Materialtyp    # c_IO_Mat;
  BA1_IO_I_Data:MatFelderInsInput();    // 03.11.2021 AH

  // Feldübernahme
//  BAG.IO.MEH.Out      # BA1_P_Data:ErmittleMEH();
//  BAG.IO.Plan.In.Stk    # Mat.Bestand.Stk;
//  BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;
//  BAG.IO.Plan.In.GewB   # Mat.Gewicht.Brutto;
//  if (BAG.IO.Plan.In.GewN=0.0) then BAG.IO.Plan.In.GewN # Mat.Bestand.Gew;
//  if (BAG.IO.Plan.In.GewB=0.0) then BAG.IO.Plan.In.GewB # Mat.Bestand.Gew;
//  if (BAG.IO.MEH.Out='qm') then begin
//    "BAG.IO.Länge"  # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Stk, BAG.IO.Dicke, BAG.IO.Breite, Mat.Dichte, "Wgr.TränenKgProQM");
//    BAG.IO.Plan.In.Menge  # Rnd( cnvfi(BAG.IO.Plan.In.Stk) * BAG.IO.Breite * "BAG.IO.Länge" / 1000000.0 ,Set.Stellen.Menge);
//    "BAG.IO.Länge"        # "Mat.Länge";
//  end
//  else if (BAG.IO.MEH.Out='m') then begin
//    BAG.IO.Plan.In.Menge # Lib_Einheiten:WandleMEH(200, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, 0.0, '', BAG.IO.MEH.Out);
//  end
//  else begin
//    BAG.IO.Plan.In.Menge  # BAG.IO.Plan.In.GewN;
//  end;

//  BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
//  BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
//  BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
//  BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;
//  BAG.IO.Warengruppe    # Mat.Warengruppe;
//  BAG.IO.Lageradresse   # Mat.Lageradresse;
//  BAG.IO.Lageranschr    # Mat.Lageranschrift;
//  BAG.IO.MEH.In         # BAG.IO.MEH.Out;

  if (aStk=0) then      aStk # BAG.IO.Plan.In.Stk;
  if (aGewN=0.0) then   aGewN # BAG.IO.PLan.In.GewN;
  if (aGewB=0.0) then   aGewB # BAG.IO.Plan.In.GewB;
  if (aMenge=0.0) then  aMenge # BAG.IO.Plan.In.Menge;
  BAG.IO.Plan.Out.Meng  # aMenge;
  BAG.IO.Plan.Out.Stk   # aStk;
  BAG.IO.Plan.Out.GewN  # aGewN;
  BAG.IO.Plan.Out.GewB  # aGewB;

  BAG.IO.VonBAG         # 0;
  BAG.IO.VonPosition    # 0;
  BAG.IO.VonFertigung   # 0;
  BAG.IO.VonID          # 0;

  // TODO

  BAG.IO.NachFertigung # 0;
  if ("BAG.P.Typ.1in-1outYN") then    // 1zu1 Arbeitsgang?
    BAG.IO.NachFertigung # 1;


  // Einsatz prüfen ================================================
  if (BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Materialtyp=c_IO_VSB) then begin
    Erx # Mat_Data:read(BAG.IO.Materialnr); // Material holen
    if (Erx<200) then begin
      Msg(001201,Translate('Material'),0,0,0);
      RETURN false;
    end;
    vOK # ("Mat.Löschmarker"='');
    if (vOK) then begin
      if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
        if ((BAG.P.Aktion<>c_BAG_Fahr09) or (BAG.P.ZielVerkaufYN=false) or (Mat.Status<>c_Status_VSB)) then
          vOK # vOK and ( (Mat.Status<=c_Status_bisFrei) or
            (Mat.Status>=c_Status_Sonder) and (Mat.Status<=c_Status_bisSonder));
      end;
      if (BAG.IO.MaterialTyp=c_IO_VSB) then
        vOK # vOK and ((Mat.Status=c_Status_EKVSB) or (MAt.Status=c_Status_EK_Konsi));  // 26.07.2021 AH: EK-Konsi
    end;
    if (vOK=false) then begin
      Msg(441002,'',0,0,0);
      RETURN false;
    end;

    v701 # RekSave(701);    // 24.10.2018 AH
    // Lagerorte prüfen...
    if (RecLinkInfo(701,702,2,_recCount)>0) then begin
      vBuf701 # RecBufCreate(701);
      Erx # RecLink(vBuf701,702,2,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        if (vBuf701->BAG.IO.Materialtyp=c_IO_Mat) or (vBuf701->BAG.IO.Materialtyp=c_IO_VSB) then begin
          Erx # Mat_Data:read(vBuf701->BAG.IO.Materialnr); // Material holen
          if (Erx>=200) then begin
            vAdr # Mat.Lageradresse;
            vAns # Mat.Lageranschrift;
            BREAK;
          end;
        end;
        Erx # RecLink(vBuf701,702,2,_recNext);
      END;
      RecBufDestroy(vBuf701);
      if (vAdr<>0) then begin
        Erx # Mat_Data:read(BAG.IO.Materialnr); // Material holen
        if (vAdr<>Mat.Lageradresse) or (vAns<>Mat.Lageranschrift) then begin
          if (Msg(441003,'',_WinIcoWarning,_WinDialogYesNo,2)<>_WinIdYes) then begin
            if (BAG.IO.Materialtyp=c_IO_Mat) then $edBAG.IO.Materialnr->WinFocusSet(true)
            else $edBAG.IO.MaterialnrVSB->WinFocusSet(true);
            RekRestore(v701);
            RETURN false;
          end;
        end;
      end;
    end;  // Lagerortsprüfung

  end;

  // KEINE Weiterbearbeitung =============================================
  RekRestore(v701);
  // ID vergeben
  WHILE (RecRead(701,1,_recTest)<=_rLocked) do
    BAG.IO.ID # BAG.IO.ID + 1;

  BAG.IO.UrsprungsID    # BAG.IO.ID;
  BAG.IO.Anlage.Datum   # Today;
  BAG.IO.Anlage.Zeit    # Now;
  BAG.IO.Anlage.User    # gUserName;

  TRANSON;

  // Material auf diesen neuen Einsatz hin anpassen
  if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
    if (BA1_Mat_Data:MatEinsetzen()=false) then begin
      TRANSBRK;
      Msg(701005,'',0,0,0);
      RETURN false;
    end;
  end;
  
  // 24.05.2019 AH: Prj. 1884/117:
  //RekInsert(701,0,'MAN');
  Erx # Insert(0,'MAN');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;

  Erx # Rso_Rsv_Data:Insert701();
  Erx # _rOK;


  // Output aktualisieren
  if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN false;
  end;

  TRANSOFF;

  // nächste Pos. holen
  RecLink(702,701,4,_recFirst);
  // alle Fertigungen neu errechnen
  BA1_P_Data:ErrechnePlanmengen();

  RETURN true;
end;


//========================================================================
// MaxFertigungsRID
// MS (02.07.2009) ermittelt den größten (minimal) RID Wert aller Fertigungen einer
//                 Position
//========================================================================
sub MaxFertigungsRID() : float;
local begin
  Erx       : int;
  vMaxRID : float;
  vBuf702 : int;
  vBuf703 : int;
end;
begin

  vMaxRID # 0.0;

  vBuf702 # RecBufCreate(702);
  Erx # RecLink(vBuf702, 701, 4, _recFirst); // Position zum Einsatz holen
  if(Erx > _rLocked) then begin
    //RecBufClear(702);           // nicht LEEREN da es zur Porbs. bei Neuanlage kommen kann
    RecBufDestroy(vBuf702);
    RETURN 0.0;
  end;

  vBuf703 # RecBufCreate(703);
  Erx # RecLink(vBuf703, vBuf702, 4,_recFirst); // Fertigungen LOOPEN
  WHILE (Erx <= _rLocked) DO BEGIN
    // Restcoils überspringen
    if (vBuf703->BAG.F.Fertigung>=999) then begin
      Erx # RecLink(vBuf703,vBuf702,4,_recNext)
      CYCLE;
    end;

    if(vMaxRID < vBuf703->BAG.F.RID) then  // Fertigungs RID größer als der letzt Größte
      vMaxRID # vBuf703->BAG.F.RID;

    Erx # RecLink(vBuf703, vBuf702, 4,_recNext); // Fertigungen LOOPEN
  END;

  RecBufDestroy(vBuf702);
  RecBufDestroy(vBuf703);

  RETURN vMaxRID;
end;


//========================================================================
// MinMaxFertigungsRAD
// MS (02.07.2009) ermittelt den kleinsten min und max RAD Werte
//                 aller Fertigungen einer Position
// AI 09.07.2012 komplett neu
//========================================================================
sub MinMaxFertigungsRAD(
  var aMinRAD : float;
  var aMaxRAD : float;
  aRID        : float);
local begin
  vBuf702 : int;
  vBuf703 : int;
  vKGMM1  : float;
  vKGMM2  : float;
end;
begin

  aMaxRAD # 0.0;
  aMinRAD # 0.0;

  if (KGMMMinMaxBestimmen(var vKGMM1, var vKGMM2)=false) then RETURN;

//  aMinRAD # vKGMM1;
  RecLink(819,701,7,_recFirst);   // Warengruppe holen
  aMinRAD # Lib_Berechnungen:RAD_aus_DichteRIDkgmm(Wgr_Data:GetDichte(Wgr.Nummer, 701), aRID, vKGMM1);
  aMaxRAD # Lib_Berechnungen:RAD_aus_DichteRIDkgmm(Wgr_Data:GetDichte(Wgr.Nummer, 701), aRID, vKGMM2);

RETURN;
/***
  vBuf702 # RecBufCreate(702);
  Erx # RecLink(vBuf702, 701, 4, _recFirst); // Position zum Einsatz holen
  if(Erx > _rLocked) then begin
    //RecBufClear(702);           // nicht LEEREN da es zur Porbs. bei Neuanlage kommen kann
    RecBufDestroy(vBuf702);
    RETURN;
  end;

  aMinRAD # 0.0;
  aMaxRAD # 99999999.9;

  vBuf703 # RecBufCreate(703);
  Erx # RecLink(vBuf703, vBuf702, 4,_recFirst); // Fertigungen LOOPEN
  WHILE (Erx <= _rLocked) DO BEGIN
    // Restcoils überspringen
    if (vBuf703->BAG.F.Fertigung>=999) then begin
      Erx # RecLink(vBuf703, vBuf702,4,_recNext)
      CYCLE;
    end;

    if(aMinRad < vBuf703->BAG.F.RAD) and (vBuf703->BAG.F.RAD <> 0.0) then
      aMinRad # vBuf703->BAG.F.RAD;

    if(aMaxRad > vBuf703->BAG.F.RADMax) and (vBuf703->BAG.F.RADMax <> 0.0) then
      aMaxRad # vBuf703->BAG.F.RADMax;

    // 09.07.2012 AI
    if (vBuf703->BAG.F.Verpackung<>0) then begin
    end;

    Erx # RecLink(vBuf703, vBuf702, 4,_recNext); // Fertigungen LOOPEN
  END;

  if(aMaxRAD = 99999999.9) then
    aMaxRAD # 0.0;

  RecBufDestroy(vBuf702);
  RecBufDestroy(vBuf703);
***/
end;


//========================================================================
// CreateBIS    +Err
//
//========================================================================
sub CreateBIS(opt aSilent : logic) : logic;
local begin
  Erx       : int;
  vBuf701   : int;
end;
begin
  // gültiger AG?
  if (BAG.P.Aktion=c_BAG_Fahr) then RETURN false;
  if (BAG.P.Aktion=c_BAG_Versand) then RETURN false;
  if (BAG.P.Aktion=c_BAG_Check) then RETURN false;
  if (BAG.P.Aktion=c_BAG_VSB) then RETURN false;

  vBuf701 # RekSave(701);

  RecBufClear(701);
  BAG.IO.VonBAG       # BAG.P.Nummer;
  BAG.IO.VonPosition  # BAG.P.Position;
  BAG.IO.VonFertigung # 999;

  // gibt es schon eine 999?
  Erx # RecRead(701,3,0);
  if (Erx<>_rNoRec) and (BAG.IO.VonBAG=BAG.P.Nummer) and (BAG.IO.VonPosition=BAG.P.Position) and
    (BAG.IO.VonFertigung=999) then begin
    RekRestore(vBuf701);
    RETURN false;
  end;
  RekRestore(vBuf701);

  Erx # RecLink(701,707,9,_recFirst);   // Input holen
  if (Erx<>_rOK) then RETURN false;

  if (BAG.IO.Plan.Out.Meng<=0.0) then RETURN false;

  TRANSON;

  // 999 anlegen:
  BA1_F_data:UpdateSchopf(n,y);

  TRANSOFF;

  if (aSilent = false) then
    Msg(999998,'',0,0,0);
  RETURN true;
end;


//========================================================================
// KGMMMinMaxbestimmen
//
//========================================================================
sub KGMMMinMaxBestimmen(
  var aMin : float;
  var aMax : float
) : logic
local begin
  Erx     : int;
  vBuf701 : int;
  vBuf703 : int;
  vRID    : float;
  vX      : float;
end;
begin

  vBuf701   # RekSave(701);
  vBuf703   # RekSave(703);

  aMin    # 0.0;
  aMax    # 999999.0;
  Erx # RecLink(703,702,4,_recFirst);     // Fertigungen loopen
  WHILE (Erx<=_rLocked) do begin

    // Restcoils überspringen
    if (BAG.F.Fertigung>=999) then begin
      Erx # RecLink(703,702,4,_recNext)
      CYCLE;
    end;

    RecLink(819,703,5,_recFirst);   // Warengruppe holen
    vRID # BAG.F.RID;
    if (vRID=0.0) then vRID # 508.0;

    // 17.12.2020 AH: wenn in dieser Fertigung keine Breite, dann Einsatzbreite beachten
    if (BAG.F.Breite=0.0) then BAG.F.Breite # vBuf701->BAG.IO.Breite;


    // passendn Output holen
    RecBufClear(701);
    BAG.IO.VonBAG       # BAG.F.Nummer;
    BAG.IO.VonPosition  # BAG.F.Position;
    BAG.IO.VonFertigung # BAG.F.Fertigung;
    BAG.IO.VonID        # vBuf701->BAG.IO.ID;
    Erx # RecRead(701,3,0);
    if (BAG.IO.VonBAG=BAG.P.Nummer) and
       (BAG.IO.VonPosition=BAG.P.Position) and
       (BAG.IO.VonFertigung=BAG.F.Fertigung) and
       (BAG.IO.VonID=vBuf701->BAG.IO.ID) and
       ((Erx<=_rLocked) or (Erx=_rMultikey)) then begin

      // RAD beachten
      if ("Set.BA.AutoT.!RADYN"=false) then begin
        if (BAG.F.RAD<>0.0) and (vRID<>0.0) then begin
          vX # Lib_Berechnungen:Kgmm_aus_DichteRIDRAD(Wgr_Data:GetDichte(Wgr.Nummer,701), vRID, BAG.F.RAD,7);
          if (vX>aMin) then aMin # vX;
        end;
        if (BAG.F.RADmax>1.0) and (vRID<>0.0) then begin
          vX # Lib_Berechnungen:Kgmm_aus_DichteRIDRAD(Wgr_Data:GetDichte(Wgr.Nummer, 701), vRID, BAG.F.RADmax,7);
          if (vX<aMax) then aMax # vX;
        end;
      end;
      Erx # RecLink(704,703,6,_recFirst);   // Verpackung holen
      if (Erx<=_rLocked) then begin

        // Ringgewichte beachten
        if ("Set.BA.AutoT.!kgYN"=false) then begin
          if (BAG.Vpg.RingKgvon<>0.0) and (BAG.F.Breite<>0.0) then begin
            vX # BAG.Vpg.RingKgVon / BAG.F.Breite;
            if (vX>aMin) then aMin # vX;
          end;
          if (BAG.Vpg.RingKgBis<>0.0) and (BAG.F.Breite<>0.0) then begin
            vX # BAG.Vpg.RingKgBis / BAG.F.Breite;
            if (vX<aMax) then aMax # vX;
          end;
        end;

        // Verpackungsmax. gewicht beachten
        if ("Set.BA.AutoT.!VEkgYN"=false) then begin
          if (BAG.Vpg.VEkgMax<>0.0) and (BAG.F.Breite<>0.0) then begin
            vX # BAG.Vpg.VEkgMax / BAG.F.Breite;
            if (vX<aMax) then aMax # vX;
          end;
        end;

        // kg/mm beachten
        if ("Set.BA.AutoT.!kgmmYN"=false) then begin
          if (BAG.Vpg.kgmmVon<>0.0) and (BAG.Vpg.kgmmVon>aMin) then
            aMin # BAG.Vpg.kgmmVon;
          if (BAG.Vpg.kgmmBis<>0.0) and (BAG.Vpg.kgmmBis<aMax) then
            aMax # BAG.Vpg.kgmmBis;
        end;

      end;  // Verpackung vorhanden

    end;  // Output vorhanden

    Erx # RecLink(703,702,4,_recNext)
  END; // Fertigungen

  RekRestore(vBuf701);
  RekRestore(vBuf703);

  if (aMax<aMin) then RETURN false;

  RETURN true;
end;


//========================================================================
// TeilungVonBis2 +Err
//  25.03.2019 AH: Refactoring, damit nicht Mengen aus Output-IO genutzt werden, die bei Vererbung noch nicht stimmen
//  (BSP ersetrzt 1. Theorie durch Echt und "tief unten" kommt eine Teilung)
//========================================================================
sub TeilungVonBis2(
  aMin      : float;
  aMax      : float;
  aTlgTxt   : int;
) : int;
local begin
  Erx         : int;
  vBuf703     : int;
  vX          : float;
  vRID        : float;
  vStk        : int;
  vGew        : float;
  vUnpassend  : int;
  vTlg        : Int;
  vInputStk   : int;
end;
begin

  vBuf703   # RekSave(703);

  // Teilungen durchprobieren...
  vTlg # 0;
//if (BAG.P.Position=19) then
//debug('T01' + '|Min/Max: ' + cnvaf(aMin) + '/' + cnvaf(aMax) + '   Akt.: ' + cnvaf(vX) + '|Gew.: ' + cnvaf(vGew) + '  Tlg.: ' + cnvai(vTlg) + '|' + cnvai(vUnpassend));
  REPEAT
    vTlg # vTlg + 1;
    FOR Erx # RecLink(703,702,4,_recFirst)      // Fertigungen loopen
    LOOP Erx # RecLink(703,702,4,_recNext)
    WHILE (Erx<=_rLocked) do begin

      // Restcoils überspringen
      if (BAG.F.Fertigung>=999) then CYCLE;

      if (BAG.F.Breite=0.0) then BAG.F.Breite # BAG.IO.Breite;

      vInputStk # Max(BAG.IO.Plan.Out.Stk,1);
      vGew      # BAG.IO.Plan.Out.GewN; // Einsatz
      if ("BAG.P.Typ.1In-yOutYN") and (BAG.IO.Breite<>0.0) then begin  // Spalten?
        vGew # vGew / BAG.IO.Breite * BAG.F.Breite;
        vGew # Rnd(vGew, Set.Stellen.Gewicht);
      end;

      vUnpassend # 0;
      vStk # vInputStk;

//  debug('T01' + '|Min/Max: ' + cnvaf(aMin) + '/' + cnvaf(aMax) + '  Gew.: ' + cnvaf(vGew));

      if (vStk<>0) and (BAG.F.Breite<>0.0) then begin
        vGew # vGew / cnvfi(vStk);
        vX # vGew / cnvfi(vTlg) / BAG.F.Breite;
        if (vX > aMax) then vUnpassend # BAG.F.Fertigung;
        if (vX < aMin) then vUnpassend # -1 * BAG.F.Fertigung;
      end;

    END;  // Fertigungen

  UNTIL (vUnpassend<=0) or (vTlg>50);  // Teilungzähler
  vTlg # vTlg - 1;
  if (vUnpassend<>0) then vTlg # -1;

  RekRestore(vBuf703);
//  debug('T02' + '|Min/Max: ' + cnvaf(aMin) + '/' + cnvaf(aMax) + '   Akt.: ' + cnvaf(vX) + '|Gew.: ' + cnvaf(vGew) + '  Tlg.: ' + cnvai(vTlg) + '|' + cnvai(vUnpassend));

  if (aTlgTxt<>0) then begin
    if (BAG.IO.Materialtyp=c_IO_BAG) then
      TextAddLine(aTlgTxt, aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : aus '+aint(BAG.IO.VonPosition)+'/'+aint(BAG.IO.VonFertigung))
    else
      TextAddLine(aTlgTxt, aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : Mat.'+aint(BAG.IO.Materialnr));
  end;

  RETURN vTLG;
end;


//========================================================================
// TeilungVonBis +Err
//
//========================================================================
sub TeilungVonBis(
  aMin  : float;
  aMax  : float;
) : int;
local begin
  Erx         : int;
  vBuf703     : int;
  vBuf701     : int;

  vX          : float;
  vRID        : float;
//  vMin,vMax   : float;
  vStk        : int;
  vGew        : float;
  vUnpassend  : int;
  vTlg        : Int;
  vInputStk   : int;
end;
begin

  RETURN TeilungVonBis2(aMin, aMax, 0);

//debug('START AUTOTEILUNG pos '+aint(BAg.P.POsition));
//debug('kg/mm:'+anum(aMin,2)+' bis '+anum(aMax,2));
  vBuf703   # RekSave(703);
  vBuf701   # RekSave(701);

  // Teilungen durchprobieren...
  vTlg # 0;
//debug('01' + '|Min/Max: ' + cnvaf(vMin) + '/' + cnvaf(vMax) + '   Akt.: ' + cnvaf(vX) + '|Gew.: ' + cnvaf(vGew) + '  Tlg.: ' + cnvai(vTlg) + '|' + cnvai(vUnpassend));

  REPEAT

    vTlg # vTlg + 1;

    Erx # RecLink(703,702,4,_recFirst);     // Fertigungen loopen
    WHILE (Erx<=_rLocked) do begin

      // Restcoils überspringen
      if (BAG.F.Fertigung>=999) then begin
        Erx # RecLink(703,702,4,_recNext)
        CYCLE;
      end;

//      vInputStk # BAG.IO.Plan.In.Stk;
      vInputStk # vBuf701->BAG.IO.Plan.Out.Stk;
      // passenden Output holen
      RecBufClear(701);
      BAG.IO.VonBAG       # BAG.F.Nummer;
      BAG.IO.VonPosition  # BAG.F.Position;
      BAG.IO.VonFertigung # BAG.F.Fertigung;
      BAG.IO.VonID        # vBuf701->BAG.IO.ID;
      Erx # RecRead(701,3,0);
      if (BAG.IO.VonBAG=BAG.P.Nummer) and
         (BAG.IO.VonPosition=BAG.P.Position) and
         (BAG.IO.VonFertigung=BAG.F.Fertigung) and
         (BAG.IO.VonID=vBuf701->BAG.IO.ID) and
         ((Erx<=_rLocked) or (Erx=_rMultikey)) then begin

        vUnpassend # 0;
        //vStk # vBuf701In->BAG.IO.Plan.Out.Stk;// * "BAG.F.Stückzahl";
// FL:
        vStk # BAG.F.Streifenanzahl;
        vGew # BAG.IO.Plan.In.GewN;
// STANDARD
        vStk # BAG.F.Streifenanzahl * vBuf701->BAG.IO.PLan.Out.Stk;
//        vGew # vBuf701->BAG.IO.Plan.Out.GewN;
//debug('701: '+aint(vBuf701->bag.io.id));
// 26.05.2010       vStk # BAG.F.Streifenanzahl * vBuf701->BAG.IO.PLan.Out.Stk;
//         vGew # vBuf701->BAG.IO.Plan.Out.GewN;

        if (BAG.F.Breite=0.0) then BAG.F.Breite # BAG.IO.Breite;
        if (vStk<>0) and (BAG.F.Breite<>0.0) then begin
          vGew # vGew / cnvfi(vStk);
          vX # vGew / cnvfi(vTlg) / BAG.F.Breite;
          if (vX > aMax) then vUnpassend # BAG.F.Fertigung;
          if (vX < aMin) then vUnpassend # -1 * BAG.F.Fertigung;
//debug('T02 ' + '|Akt.: ' + cnvaf(vX) + '|Gew.: ' + cnvaf(vGew) + '|Tlg.: ' + cnvai(vTlg) + '|' + cnvai(vUnpassend));
        end;

      end;

      Erx # RecLink(703,702,4,_recNext)
    END;  // Fertigungen

  UNTIL (vUnpassend<=0) or (vTlg>50);  // Teilungzähler
//debug('03' + '|Min/Max: ' + cnvaf(aMin) + '/' + cnvaf(aMax) + '|Akt.: ' + cnvaf(vX) + '|Gew.: ' + cnvaf(vGew) + '|Tlg.: ' + cnvai(vTlg) + '|' + cnvai(vUnpassend));
/**
if (vUnpassend>0) then
debug(cnvai(vUnpassend)+' zu gross');
if (vUnpassend<0) then
debug(cnvai(vUnpassend)+' zu klein');
**/
  vTlg # vTlg - 1;
//debug('04_'+cnvai(vTlg));
  if (vUnpassend<>0) then vTlg # -1;

//  RecBufCopy(vBuf701,701);
//vTlg # BAG.IO.Teilungen;
//debug('99_' + 'vorher:'+cnvai(bag.io.teilungen) +' / nachher:'+cnvai(vTlg));
  RekRestore(vBuf701);
  RekRestore(vBuf703);

  RETURN vTLG;
end;


//========================================================================
// KGMM_Check
//
//========================================================================
sub KGMM_Check(
  aMin  : float;
  aMax  : float;
) : logic;
local begin
  Erx         : int;
  vBuf703     : int;
  vBuf701     : int;

  vTlg        : int;
  vX          : float;
  vRID        : float;
  vStk        : int;
  vGew        : float;
  vUnpassend  : int;
  vInputStk   : int;
end;
begin
//debug('BAPos: '+aint(bag.P.position));
//debug('check :'+anum(aMin,2)+' '+anum(aMax,2));

  vTlg      # BAG.IO.Teilungen + 1;

  vBuf703   # RekSave(703);
  vBuf701   # RekSave(701);

  Erx # RecLink(703,702,4,_recFirst);     // Fertigungen loopen
  WHILE (Erx<=_rLocked) do begin

    // Restcoils überspringen
    if (BAG.F.Fertigung>=999) then begin
      Erx # RecLink(703,702,4,_recNext)
      CYCLE;
    end;

    vInputStk # vBuf701->BAG.IO.Plan.Out.Stk;
    // passenden Output holen
    RecBufClear(701);
    BAG.IO.VonBAG       # BAG.F.Nummer;
    BAG.IO.VonPosition  # BAG.F.Position;
    BAG.IO.VonFertigung # BAG.F.Fertigung;
    BAG.IO.VonID        # vBuf701->BAG.IO.ID;
    Erx # RecRead(701,3,0);
    if (BAG.IO.VonBAG=BAG.P.Nummer) and
       (BAG.IO.VonPosition=BAG.P.Position) and
       (BAG.IO.VonFertigung=BAG.F.Fertigung) and
       (BAG.IO.VonID=vBuf701->BAG.IO.ID) and
       ((Erx<=_rLocked) or (Erx=_rMultikey)) then begin

//      vUnpassend # 0;
      vStk # BAG.F.Streifenanzahl * vBuf701->BAG.IO.PLan.Out.Stk;
//      vGew # vBuf701->BAG.IO.Plan.Out.GewN;
      vGew # BAG.IO.Plan.Out.GewN;
      if (BAG.F.Breite=0.0) then BAG.F.Breite # BAG.IO.Breite;
      if (vStk<>0) and (BAG.F.Breite<>0.0) then begin
        vGew # vGew / cnvfi(vStk);
        vX # vGew / cnvfi(vTlg) / BAG.F.Breite;
        if (vX > aMax) then vUnpassend # BAG.F.Fertigung;
        if (vX < aMin) then vUnpassend # -1 * BAG.F.Fertigung;
      end;
    end;

    Erx # RecLink(703,702,4,_recNext)
  END;  // Fertigungen

  RekRestore(vBuf701);
  RekRestore(vBuf703);

//debug('unpassend:'+aint(vUnpassend));
  if (vUnpassend<>0) then RETURN true;
//debug('OK');
  RETURN false;
end;


//========================================================================
// Autoteilung
//
//========================================================================
sub Autoteilung(
  var aKGMM_Kaputt  : logic;
) : logic;
local begin
  Erx         : int;
  vKGMM1      : float;
  vKGMM2      : float;
  vTLG        : int;
end;
begin

  // kgmm-Testen...
  if (BA1_IO_Data:KGMMMinMaxBestimmen(var vKGMM1, var vKGMM2)=false) then begin
    ERROR(703005,'');
    RETURN False;
//    RETURN 703005;
  end;

  // Autoteilungen?
  if (BAG.IO.AutoteilungYN) then begin
    vTLG # TeilungVonBis(vKGMM1, vKGMM2);
    if (vTLG<0) then begin
      //ERROR(703007,anum(vKGMM1,2)+'|'+anum(vKGMM2,2)+'|'+aint(BAG.IO.NachBAG)+'/'+aint(BAG.IO.NachPosition));   // ERROR
      //RETURN false;
      RETURN true;    // 25.03.2019 AH: damit Vererbung der Mengen stattfindet
    end;
    if (vTlg<>BAG.IO.Teilungen) then begin
      Erx # RecRead(701,1,_recLock);
      if (erx<>_rOK) then begin     // 2022-07-05 AH DEADLOCK
        ERROR(1000+Erx,'');
        RETURN false;
      end;
      BAG.IO.Teilungen # vTlg;
      Erx # RekReplace(701,_recUnlock,'AUTO');
      if (erx<>_rOK) then begin
        ERROR(1000+Erx,'');
        RETURN false;
      end;
      // Output aktualisieren
      if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
        ERROR(701010,'');
        RETURN false;
      end;
    end;
  end
  else begin
    aKGMM_Kaputt # BA1_IO_Data:KGMM_Check(vKGMM1, vKGMM2);
  end;

  RETURN true;
end;


//========================================================================
// OutputNachPos
//
//========================================================================
sub OutputNachPos(
  aBAG1 : int;
  aID       : int;
  aBAG2     : int;
  aPos      : int;
  opt aTlg  : int;
) : logic;
local begin
  Erx           : int;
  v701          : int;
  v702          : int;
  vKGMM1        : float;
  vKGMM2        : float;
  vKGMM_Kaputt  : logic;
end;
begin
//debugx('outputnachpos: '+aint(aBAG1)+'/'+aint(aID)+' -> '+aint(aBAG2)+'/'+aint(aPos));
   APPOFF();

  v701 # RekSave(701);
  v702 # RekSave(702);

  BAG.IO.Nummer   # aBAG1;
  BAG.IO.ID       # aID;
  Erx # RecRead(701,1,0);
  if (Erx>_rLocked) or
    (BAG.IO.NachPosition<>0) or (BAG.IO.BruderID<>0) or (BAG.IO.Materialtyp<>c_IO_BAG) then begin
    RekRestore(v701);
    RekRestore(v702);
    APPON();
    RETURN false;
  end;

  BAG.P.Nummer    # aBAG2;
  BAG.P.Position  # aPos;
  RecRead(702,1,0);
  if (Erx>_rLocked) or
   ("BAG.P.Löschmarker"<>'') then begin
    RekRestore(v701);
    RekRestore(v702);
    APPON();
    Error(702009,'');
    RETURN false;
  end;

  // 15.03.2017 ist VK-Fahre? -> dann Kommission prüfen!
  // 09.12.2021 AH
  if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.P.ZielVerkaufYN) and (BAG.VorlageYN=false) then begin
    if (BAG.IO.Auftragsnr=0) then begin
      RekRestore(v701);
      RekRestore(v702);
      APPON();
      Error(441015,'');
      RETURN false;
    end;
  end;


  TRANSON;

  Erx # RecRead(701,1,_recLock);
  if (erx=_rOK) then begin
    BAG.IO.NachBAG        # aBAG2;
    BAG.IO.NachPosition   # aPos;
    BAG.IO.AutoTeilungYN  # (aTlg=0);
    BAG.IO.Teilungen      # aTlg;    // 2023-08-04  AH
    Erx # BA1_IO_Data:Replace(_recUnlock,'MAN');
  end;
  if (Erx<>_rOK) then begin
    APPON();
    TRANSBRK;
    RekRestore(v701);
    RekRestore(v702);
    RETURN false;
  end

  if (Autoteilung(var vKGMM_Kaputt)=false) then begin
    if (Set.BA.AutoT.NurWarn=false) then begin
      APPON();
      TRANSBRK;
      RekRestore(v701);
      RekRestore(v702);
      RETURN false;
    end
    else begin
//      vTlgErr # 1;
    end;
  end;

  // Output aktualisieren
  if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
    APPON();
    TRANSBRK;
    Error(701010,'');
    RekRestore(v701);
    RekRestore(v702);
    RETURN false;
  end;

  TRANSOFF;

  BA1_P_Data:UpdateSort();

  // alle Fertigungen neu errechnen
  if ("BAG.P.Typ.1In-1OutYN") or
      ("BAG.P.Typ.1In-yOutYN") then
    BA1_P_Data:ErrechnePlanmengen();


  if (vKGMM_Kaputt) then Error(703006,aint(BAG.P.Position));

  RekRestore(v701);
  RekRestore(v702);

  APPON();
  
  RETURN true;
end;


//========================================================================
//  AutoTeilungEchterEinsatz
//      errechnet Tlg für tatsächlichen Einsatz (BSP)
//========================================================================
sub AutoTeilungEchterEinsatz() : logic
local begin
  Erx     : int;
  vTLG    : int;
  vKGMM1  : float;
  vKGMM2  : float;
  v701    : int;
  vMod    : logic;
end;
begin
  
  // jeden ECHTEN Input loopen
  FOR Erx # RecLink(701,702,2,_RecFirst)
  LOOP Erx # RecLink(701,702,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.Materialtyp=703) then begin
    
      if (BAG.IO.AutoTeilungYN=false) then vTLG # BAG.IO.Teilungen;
      // Input muss geladen sein
      if (KGMMMinMaxBestimmen(var vKGMM1, var vKGMM2)=false) then begin
        RETURN False;
      end;
//debug(anum(vKGmm1,2)+' bis '+anum(vKGmm2,2));
      CYCLE;
    end;
    
    // nur Weiterbearbeitungen!
    if (BAG.IO.VonFertigmeld=0) or (BAG.IO.Materialnr=0) then CYCLE;

    vTLG # -1;    // 07.04.2020 AH: für JEDEN Input autoteilen
vTlg # -1;
    if (BAG.IO.BruderID<>0) then begin
      v701 # RecBufCreate(701);
      v701->BAg.IO.Nummer # BAG.IO.Nummer;
      v701->BAG.IO.ID     # BAG.IO.BruderID;
      Erx # RecRead(v701,1,0);
      if (Erx<=_rLocked) then begin
        if (v701->BAG.IO.AutoteilungYN=false) then vTlg # v701->BAG.IO.TEilungen;
//debugx('FEST ID: '+aint(v701->BAG.IO.ID)+'  T:'+aint(vTlg));
      end;
      RecBufDestroy(v701);
    end;
    
    if (vTLG=-1) then begin
      vTLG # TeilungVonBis(vKGMM1, vKGMM2);
      if (vTLG<0) then begin
        RETURN false;
      end;
    end;

    if (vTlg<>-1) and (vTlg<>BAG.IO.Teilungen) then begin
      Erx # RecRead(701,1,_recLock);
      if (erx<>_rOK) then RETURN false;
      BAG.IO.Teilungen # vTlg;
      erx # RekReplace(701,_recUnlock,'AUTO');
      if (erx<>_rOK) then RETURN false;
      vMod # true;
    end;
//debugx('Tlg M'+aint(BAG.IO.Materialnr)+' auf '+aint(vTlg));
  END;

  if (vMod) then Winsleep(1000);  // Pause für PS
  RETURN true;
end;


//========================================================================