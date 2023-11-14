@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_FM_Data
//                  OHNE E_R_G
//  Info
//
//
//  10.10.2007  AI  Erstellung der Prozedur
//  23.04.2010  AI  Ausfall wird gelöscht mit Sternchen
//  30.11.2011  AI  RID/RAD in der Vorbelegung der 707
//  03.01.2012  AI  Obf.Gegenteil=9999 löscht alles
//  17.01.2012  AI  NEU: SetSperre
//  23.01.2012  ST  FM Storno verringert OUT Put des theoretischen Einsatz des Vorgängers
//  02.07.2012  AI  "Vorbelegen" setzt Mengen bei Prüfen/Check
//  10.10.2012  AI  "Entfernen" löscht Auftragsaktion BA_FM
//  02.07.2013  AH  "Vorbelegen" setzt nur IO-Eisatzmenge
//  18.09.2013  AH  "Entfernen" rechnet im Material auch Bestand.Menge richtig wieder zurück
//  08.04.2014  AH  AFX 'BAG.FM.Vorbelegung.Post'
//  05.05.2014  AH  "Entfernen" löscht auch BA_FM, wenn nur BAG.F.Auftragsnummer gefüllt und nicht BAG.P.Auftragsnr
//  31.08.2017  AH  "MengenDifferenz"
//  04.07.2018  ST  "sub MengenDifferenz" VSB Aktionen werden nur bei VOrhandensein geändert
//  13.08.2018  AH  AFX "BAG.FM.Vorbelegung.AusF" mit ERG=_rOK als vNimmAlteAsuf
//  14.10.2019  AH  AFX "BAG.FM.Entfernen.Pre"
//  13.11.2019  AH  Fix: Storno von Weiterbearbeitungen hatten den Input gesperrt
//  11.12.2019  AH  Neu: "CalcSchrottGewAnteil"
//  16.03.2021  ST  Fix: "Vorbelegen"; Doppelte Ausführungen nicht mehr inserten
//  11.10.2021  AH  ERX, "AlleDerPosEntfernen"
//  27.10.2021  AH  "Entfernen" kann rekursiv arbeiten; die FM-Aktion wird auch entfernt!
//  01.02.2022  AH  Fix: "Entfernen" erhöht ggf. Versandpooolmenge wieder
//  15.03.2022  AH  "Entfernen" tauscht ggf. Matnr zurück und LÖSCHT dann FMs komplett (PUG)
//  07.07.2022  ST  DEADLOCK
//  2022-12-20  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//  sub SetSperre() : logic;
//  SUB Entfernen(opt aNoTrans : logic) : logic;
//  SUB AlleDerPosEntfernen() : logic;
//  SUB Vorbelegen();
//  SUB MengenDifferenz(aStk : int; aGewN : float; aGewB : float; aM : float; aM2 : float) : logic
//  SUB CalcSchrottGewAnteil(aMat : int; opt aSubProz  : float;  ) : float;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG

declare TauscheMats(aMat1 : int; aMat2 : int) : logic

//========================================================================
//  SetSperre
//
//========================================================================
sub SetSperre(opt aNocheck : logic) : logic;
local begin
  Erx     : int;
  vBuf700 : handle;
  vBuf701 : handle;
  vBuf702 : handle;
  vBuf703 : handle;
  vBuf707 : handle;
  vGew    : float;
  vA      : alpha;
  vOk     : logic;
end;
begin
  if (aNocheck=false) then
    if (BAG.FM.Status<>c_Status_Frei) and (BAG.FM.Status<>c_Status_BAGfertUnklar) then RETURN false;

  vBuf700 # RekSave(700);
  vBuf701 # RekSave(701);
  vBuf702 # RekSave(702);
  vBuf703 # RekSave(703);

  Erx # RecLink(701,707,5,_recFirst);   // Output holen
  if (Erx>=_rLocked) then begin
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001000+Erx,Translate('Output'));
    RETURN false;
  end;

  TRANSON;

  // ggf. Material anpassen ------------------------------------------------
  if (BAG.FM.Materialnr<>0) then begin
    Erx # RecLink(200,707,7,_recFirst);   // Material holen
    if (Erx>_rLocked) then begin
      TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000+Erx,Translate('Material')+' '+AInt(BAG.FM.Materialnr));
      RETURN false;
    end;

    if ("Mat.Löschmarker"<>'') or (Mat.Ausgangsdatum<>0.0.0) then begin
      TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(200007,'');   // Material schon gelöscht
      RETURN false;
    end;

    // auf FAHREN/Lieferschein/Verladeanweisung testen...
//    Erx # RecLink(702,701,4,_recfirst);   // Nach-Pos holen
//    if (Erx<=_rLocked) and (BAG.P.Aktion=c_BAG_Fahr) then begin
//todo(bag.p.aktion+'  '+aint(Erx));
    Erx # RecLink(204,200,14,_recFirst);    // Aktionen loopen
    WHILE (Erx<=_rLocked) do begin
      if (Mat.A.Aktionstyp=c_Akt_VLDAW) then begin
//          ((Mat.A.Aktionstyp=c_Akt_LFS)) then begin
        TRANSBRK;
        RekRestore(vBuf700);
        RekRestore(vBuf701);
        RekRestore(vBuf702);
        RekRestore(vBuf703);
        //Error(707100,AInt(BAG.FM.Materialnr));
        error(707110,AInt(BAG.FM.Materialnr)+'|'+aint(Mat.A.Aktionsnr));
        RETURN false;
      end;

      Erx # RecLink(204,200,14,_recNext);
    END;
//    end

    Erx # RecRead(200,1,_recLock);
    if (Erx <> _rOK) then begin
      TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001014,Translate('Material')+ '|' + Aint(Mat.Nummer));
      RETURN false;
    end;
    
    
    Mat_Data:SetStatus(c_Status_BAGfertSperre);    // Sperr-Status
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(200106,AInt(BAG.FM.Materialnr));
      RETURN false;
    end;

    if (VsP_Data:DelMatAusPool(Mat.Nummer)=false) then begin
      TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000,Translate('Versandpool'));
      RETURN false;
    end;

  end;

  // BA-Output ändern ---------------------------------
  Erx # Recread(701,1,_RecLock);
  if (Erx <> _rOK) then begin
    TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001014,Translate('Material')+ '|' + Aint(Mat.Nummer));
    RETURN false;
  end;
  
  BAG.IO.NachBAG        # 0;
  BAG.IO.NachPosition   # 0;
  BAG.IO.NachFertigung  # 0;
  BAG.IO.NachID         # 0;
  Erx # RekReplace(701,0,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001000+Erx,Translate('Output'));
    RETURN false;
  end;


  // BA-FM ändern --------------------------------------
  if (BAG.FM.Status<>c_Status_BAGfertSperre) then begin
    Erx # RecRead(707,1,_recLock);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000+Erx,Translate('Fertigmeldung'));
      RETURN false;
    end;
    BAG.FM.Status           # c_Status_BAGfertSperre;  // auf SPERRE setzen
    RekReplace(707,_recUnlock,'AUTO');
  end;

  TRANSOFF;

  RekRestore(vBuf700);
  RekRestore(vBuf701);
  RekRestore(vBuf702);
  RekRestore(vBuf703);
  RETURN true;
end;


//========================================================================
//========================================================================
sub _EntfernenEinsatz(
  aGewN : float;
  aGewB : float;
  aStk  : int;
  aM    : float;
) : logic;
local begin
  Erx : int;
end;
begin

  FOR   Erx # RecLink(202,200,12,_recfirst)     // Bestandsbuch loopen
  LOOP  Erx # RecLink(202,200,12,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if ("Mat.B.Trägertyp"=c_Akt_BA_Fertig) and
      ("Mat.B.Trägernummer1"=BAG.FM.Nummer) and
      ("Mat.B.Trägernummer2"=BAG.FM.Position) and
      ("Mat.B.Trägernummer3"=BAG.FM.Fertigung) and
      ("Mat.B.Trägernummer4"=BAG.FM.Fertigmeldung)  then begin
            
      Erx # RekDelete(202,0,'AUTO');
      if (Erx <> _rOK) then
        RETURN false;
      
      BREAK;
    end;
  END;

  // 27.10.2021 AH: bei Mathistorie mi "BA-Tiefe", muss die Aktion weg, da diese auf Zwischenmaterial sein könnte
  FOR Erx # RecLink(204,200,14,_recfirst)   // Aktionen loopen
  LOOP Erx # RecLink(204,200,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.A.Aktionstyp=c_Akt_BA_Fertig) and
      (Mat.A.Aktionsnr=BAG.FM.Nummer) and
      (Mat.A.Aktionspos=BAG.FM.Position) and
      (Mat.A.Aktionspos2=BAG.FM.Fertigung) and
      (Mat.A.Aktionspos3=BAG.FM.Fertigmeldung) then begin
      Erx # RekDelete(204);
      if (Erx <> _rOK) then
        RETURN false;
      
      BREAK;
    end;
  END;

  
  Mat.Gewicht.Netto   # Mat.Gewicht.Netto   + aGewN;
  Mat.Gewicht.Brutto  # Mat.Gewicht.Brutto  + aGewB;
  if ("BAG.P.Typ.1In-1OutYN") or (BAG.P.Aktion=c_BAG_spulen) or
    (BAG.P.Aktion=c_BAG_MatPrd) or (BAG.P.Aktion=c_BAG_Paket) then
    Mat.Bestand.Stk     # Mat.Bestand.Stk + aStk;
  Mat.Bestand.Gew     # -1.0;  // freimachen zur Berechnung

  // kein Eintrag?? -> dann anhand FM rückrechnen...    18.09.2013
  if (Erx>_rLocked) then begin
    if (Mat.MEH=BAG.FM.MEH) then
      Mat.Bestand.Menge   # Mat.Bestand.Menge   + aM;
    else
      Mat.Bestand.Menge   # 0.0;    // per Formel errechnen
    end
  else begin
    Mat.Bestand.Menge   # Mat.Bestand.Menge   - Mat.B.Menge;
  end;
  Erx # Mat_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then
    RETURN false;

  RETURN true;
end;


//========================================================================
//  Entfernen
//
//  - Beistellungen löschen
//  - Output nullen
//  - Output-Material nullen (+Res. löschen)
//  - Bruder ändern
//  - Fertigung ändern
//  - ggf. Auf.Aktion ändern
//  - Input ändern
//  - Input-Bruder ändern
//  - Input-Material ändern
//  - Fertigmeldug nullen
//========================================================================
sub Entfernen(
  opt aNoTrans  : logic;
  opt aRek      : logic) : logic;
local begin
  vBuf700 : handle;
  vBuf701 : handle;
  vBuf702 : handle;
  vBuf703 : handle;
  vBuf707 : handle;
  v701b   : handle;
  vA      : alpha;
  vOk     : logic;
  vErr    : int;
  vStk    : int;
  Erx     : int;
  vDebug  : logic;
  vVorMat : int;
  vFMMat  : int;
end;
begin

  // OK :       BAG.FM.Status # 1;
  // Sperre :   BAG.FM.Status # 759; (790 früher MC9090)
  // Ausfall :  BAG.FM.Status # 798;
  if (BAG.FM.Status<>c_Status_Frei) and (BAG.FM.Status<>c_Status_BAGFertSperre) and (BAG.FM.Status<>c_Status_BAGfertUnklar) then RETURN false;

  if (BAG.FM.Materialnr=0) then RETURN false;
vdebug # FALSE;

if (vDebug) then debugx('ENTFERNE KEY707');
  vBuf700 # RekSave(700);
  vBuf701 # RekSave(701);
  vBuf702 # RekSave(702);
  vBuf703 # RekSave(703);

  // Arbeitsgang holen
  Erx # RecLink(828,702,8,_recfirst);
  if (erx>_rLocked) or ("BAG.P.Typ.1In-1OutYN"=false) then RecbufClear(828);
  if (ArG.TauscheInOutYN) then begin
//  2022-08-19  AH : ohne LOCK  Erx # RecLink(701,707,9,_RecLock|_recFirst);   // Input holen
    Erx # RecLink(701,707,9,_recFirst);   // Input holen
    if (Erx<=_rLocked) then begin
      vVorMat # BAG.IO.Materialnr;
      vFMmat  # BAG.FM.Materialnr;
    end;
  end;

  Erx # RecLink(701,707,5,_recFirst);   // Output holen
  if (Erx>=_rLocked) then begin
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001000+Erx,Translate('Output'));
if (vDebug)then debugx('aua');
    RETURN false;
  end;

  if (aNoTrans=false) then TRANSON;

  if (RunAFX('BAG.FM.Entfernen.Pre','')<0) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
if (vDebug)then debugx('aua');
    RETURN false;
  end;


  vBuf707 # RekSave(707);

  // 27.10.2021 AH: Rekursiv??
  if (aRek) then begin
    v701b # RekSave(701);
    RecbufClear(707);
    BAG.FM.InputBAG # vBuf707->BAG.FM.Nummer;
    BAG.FM.InputID  # vBuf707->BAG.FM.OutputID;
    FOR Erx # RecRead(707,2,0)
    LOOP Erx # RecRead(707,2,_recNext)
    WHILE (erx<=_rMultikey) and (BAG.FM.InputBAG=vBuf707->BAG.FM.Nummer) and
      (BAG.FM.InputID=vBuf707->BAG.FM.OutputID) do begin

      if (BAG.FM.Status=c_Status_BAGAusfall) then CYCLE;
      
      Erx # RecLink(702,707,2,_RecFirst);   // Pos holen
      Erx # RecLink(703,707,3,_RecFirst);   // Fertigung holen
      Erx # RecLink(701,707,9,_RecFirst);   // Input holen
if (vDebug) then debugx('rek... KEY702 KEY707');
      vok  # Entfernen(false, true);
if (vDebug)then debugx(abool(vOK)+'...rek');
      RecbufCopy(v701b, 701);
      RecbufCopy(vBuf702, 702);
      RecbufCopy(vBuf703, 703);
      RecbufCopy(vBuf707, 707);
      if (vOK=false) then BREAK;
    END;
    RecbufCopy(vBuf707, 707);
    RekRestore(v701b);
  end;

  // bereits weiterbearbeitet??
  vOK # y;
  //if (RecLinkInfo(707,701,12,_RecCount)>0) then begin
  Erx # RecLink(707,701,12,_RecFirst);
  WHILE (Erx<=_rLocked) and (vOK) do begin
    if (BAG.FM.Status<>c_Status_BAGAusfall) or
        ("BAG.FM.Stück"<>0) or
        (BAG.FM.Gewicht.Netto<>0.0) or
        (BAG.FM.Gewicht.Brutt<>0.0) or
        (BAG.FM.Menge<>0.0) then begin
          vOK # n;
if (vDebug)then begin
  debugx('kein guter Satz KEY707');
  lib_Debug:Dump(707);
end;
    end;
    Erx # RecLink(707,701,12,_RecNext);
  END;
  RekRestore(vBuf707);
  if (vOK=false) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(703002,aint(BAG.FM.Nummer)+'/'+aint(BAG.FM.Position)+'/'+aint(BAG.FM.Fertigung)+'/'+aint(BAG.FM.Fertigmeldung));
if (vDebug)then debugx('aua');
    RETURN false;
  end;





  // 09.03.2022 AH Rücktauschen???
  if (vVorMat<>0) then begin
    if (TauscheMats(vFMMat, vVorMat)=false) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(703002,aint(BAG.FM.Nummer)+'/'+aint(BAG.FM.Position)+'/'+aint(BAG.FM.Fertigung)+'/'+aint(BAG.FM.Fertigmeldung));
if (vDebug)then debugx('aua');
      RETURN false;
    end;
    BAG.FM.Materialnr # vVorMat;
  end;


//  Erx # RecLink(200,707,7,_recFirst);   // Material holen
//  if (Erx>_rLocked) then begin
  Erx # Mat_data:Read(BAG.FM.Materialnr, 0, 0, true); // Material holen mit ggf. RESTORE
  if (Erx<200) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001000+Erx,Translate('Material')+' '+AInt(BAG.FM.Materialnr));
if (vDebug)then debugx('aua');
    RETURN false;
  end;

  if ("Mat.Löschmarker"<>'') or (Mat.Ausgangsdatum<>0.0.0) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(200007,'');   // Material schon gelöscht
if (vDebug)then debugx('aua');
    RETURN false;
  end;
  
  // 13.12.2012 AI: Beistellungen rückbuchen...
  Erx # RecLink(708,707,12,_recFirst);
  WHILE (Erx<=_rLocked) do begin

// SEPP 12.09.2017
    if (BAG.FM.B.VonID<>0) then begin
      Erx # RecLink(708,707,12,_recNext);
      CYCLE;
    end
    else begin  // "normale" Beistellung...
      Erx # RecLink(252,708,2,_recFirst); // Charge holen
      if (Erx>_rLocked) then begin
        vErr # 1;
        BREAK;
      end;
      Erx # RecLink(250,252,1,_recFirst); // Charge holen
      if (Erx>_rLocked) then begin
        vErr # 2;
        BREAK;
      end;

      // Einsatz mindern bei NICHT Fahren --> sonst machts der LFS ja schon --------
      if (BAG.P.Aktion<>c_BAG_Fahr) then begin
        if (BAG.FM.MEH='Stk') then vStk # cnvif(BAG.FM.Menge)
        else vStk # 0;

        // Gegen-Bewegung buchen...
        RecBufClear(253);
        Art.J.Datum           # today;
        Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.FM.Nummer)+'/'+AInt(BAG.FM.Position)+'/'+aint(BAG.FM.Fertigung)+'/'+aint(BAG.FM.Fertigmeldung);
        "Art.J.Stückzahl"     # vStk;
        Art.J.Menge           # BAG.FM.B.Menge;
        "Art.J.Trägertyp"     # c_Akt_BA;
        "Art.J.Trägernummer1" # BAG.FM.Nummer;
        "Art.J.Trägernummer2" # BAG.FM.Position;
        "Art.J.Trägernummer3" # BAG.FM.Fertigung;
        vOK # Art_Data:Bewegung(0.0, 0.0);
        if (vOK=false) then begin
          vErr # 3;
          BREAK;
        end;
      end;
    end;

    erx # RekDelete(708,_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      vErr # 4;
      BREAK;
    end;
    Erx # RecLink(708,707,12,_recFirst);
  END;
  if (vErr<>0) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(999999,aint(vErr));   // Material schon gelöscht
if (vDebug)then debugx('aua');
    RETURN false;
  end;


  // auf FAHREN/Lieferschein/Verladeanweisung testen...
  Erx # RecLink(204,200,14,_recFirst);    // Aktionen loopen
  WHILE (Erx<=_rLocked) do begin
    if (Mat.A.Aktionstyp=c_Akt_VLDAW) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      //Error(707100,AInt(BAG.FM.Materialnr));
      error(707110,AInt(BAG.FM.Materialnr)+'|'+aint(Mat.A.Aktionsnr));
if (vDebug)then debugx('aua');
      RETURN false;
    end;

    Erx # RecLink(204,200,14,_recNext);
  END;

  // schon andere Aktionen ausser Schrottumlage??
  if (BA1_Kosten:LoescheVorgaengerKosten()=false) then begin
  //if (RecLinkInfo(204,200,14,_RecCount)>0) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(707100,AInt(BAG.FM.Materialnr));
if (vDebug)then debugx('aua');
    RETURN false;
  end;

  // Output nullen ---------------------------------------------------------
  if (vVorMat<>0) then begin
    Erx # RekDelete(701);
    if (Erx <> _rOK) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001014,Translate('BAG IO')+ '|' + Aint(Bag.IO.Nummer) + '/' + Aint(Bag.IO.ID));
      RETURN false;
    end;
  end
  else begin
    Erx # RecRead(701,1,_recLock);
    if (Erx <> _rOK) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001014,Translate('BAG IO')+ '|' + Aint(Bag.IO.Nummer) + '/' + Aint(Bag.IO.ID));
      RETURN false;
    end;
    
       
    BAG.IO.NachPosition # 0;
    BAG.IO.NachFertigung # 0;
    BAG.IO.NachBAG # 0;
    BAG.IO.NachID # 0;
  //BAG.IO.VonID # 0;

    BAG.IO.Ist.IN.Stk     # 0;
    BAG.IO.Ist.IN.GewN    # 0.0;
    BAG.IO.Ist.IN.GewB    # 0.0;
    BAG.IO.Ist.IN.Menge   # 0.0;
    BAG.IO.Plan.IN.Stk    # BAG.IO.Ist.IN.Stk;
    BAG.IO.Plan.IN.GewN   # BAG.IO.Ist.IN.GewN;
    BAG.IO.Plan.IN.GewB   # BAG.IO.Ist.IN.GewB;
    BAG.IO.Plan.IN.Menge  # BAG.IO.Ist.IN.Menge;
    BAG.IO.Plan.Out.Stk   # BAG.IO.Ist.IN.Stk;
    BAG.IO.Plan.Out.GewN  # BAG.IO.Ist.IN.GewN;
    BAG.IO.Plan.Out.GewB  # BAG.IO.Ist.IN.GewB;
    BAG.IO.Plan.Out.Meng  # 0.0;
    if (vVorMat<>0) then begin
      if (BAG.IO.MaterialRstNr=vFMMat) then
        BAG.IO.MaterialRstNr # vVorMat;
      if (BAG.IO.MaterialNr=vFMMat) then
        BAG.IO.MaterialNr # vVorMat;
    end;
    Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000+Erx,Translate('Output'));
  if (vDebug)then debugx('aua');
      RETURN false;
    end;
  end;

  // Material nullen --------------------------------------------------------
  Erx # RecRead(200,1,_recLock);
  if (Erx <> _rOK) then begin
    TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001014,Translate('Material')+ '|' + Aint(Mat.Nummer));
    RETURN false;
  end;
  
  Mat.Bestand.Gew     # 0.0;
  Mat.Bestand.Stk     # 0;
  Mat.Gewicht.Netto   # 0.0;
  Mat.Gewicht.Brutto  # 0.0;
  Mat.Bestand.Menge   # 0.0;  // 18.09.2013
  Mat.Ausgangsdatum   # Mat.Eingangsdatum;
  Mat_Data:SetLoeschmarker('*');
  Mat_Data:SetStatus(c_Status_BAGAusfall);
  Erx # Mat_Data:Replace(_recUnlock,'AUTO');
  if (Erx<>_rOK) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(200106,AInt(BAG.FM.Materialnr));
if (vDebug)then debugx('aua');
    RETURN false;
  end;

  if (VsP_Data:DelMatAusPool(Mat.Nummer)=false) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001000,Translate('Versandpool'));
if (vDebug)then debugx('aua');
    RETURN false;
  end;


  // Reservierungen löschen ------------------------------------------------
  WHILE (RecLink(203,200,13,_recFirst)<=_rLocked) do begin
    if (Mat_Rsv_Data:Entfernen()=false) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000,Translate('Reservierung'));
if (vDebug)then debugx('aua');
      RETURN false;
    end;
  END;


  // theoretischen Bruder ändern -------------------------------------------
  Erx # RecLink(701,707,11,_RecLock|_recFirst);   // Bruder holen
  if (Erx<>_rOK) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(010027,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.BruderID));
if (vDebug)then debugx('aua');
    RETURN false;
  end;
  BAG.IO.Ist.In.Stk  # BAG.IO.Ist.In.Stk   - "BAG.FM.Stück";
  BAG.IO.Ist.In.GewN # BAG.IO.Ist.In.GewN  - BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.In.GewB # BAG.IO.Ist.In.GewB  - BAG.FM.Gewicht.Brutt;
  if (BAG.FM.Meh=BAG.IO.MEH.In) then
    BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge - BAG.FM.Menge;
  Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    RecRead(701,1,_recUnlock);
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001000+Erx,Translate('Output'));
if (vDebug)then debugx('aua');
    RETURN false;
  end;


  // 01.02.2022 AH: ursprünglichen Versand reaktivieren?
  if (BAG.IO.NachPosition<>0) then begin
    Erx # RecLink(702,701,4,_RecFirst);   // nachpos holen
    if (BAG.P.Aktion=c_BAG_Versand) then begin
      vOK # VsP_Data:ErzeugePoolZumVersand();
      if (vOK=false) then begin
        RekRestore(vBuf700);
        RekRestore(vBuf701);
        RekRestore(vBuf702);
        RekRestore(vBuf703);
        Error(001000+Erx,Translate('Versandpool'));
  if (vDebug)then debugx('aua');
        RETURN false;
      end;
    end;
    RecbufCopy(vBuf702, 702);   // 13.06.2022 AH
  end;
  
  
  // Fertigung ändern ------------------------------------------------------
  Erx # RecLink(703,707,3,_recLock|_recFirst);   // Fertigung holen
  if (Erx = _rOK) then begin
    BAG.F.Fertig.Gew    # BAG.F.Fertig.Gew    - BAG.FM.Gewicht.Netto;
    BAG.F.Fertig.Stk    # BAG.F.Fertig.Stk    - "BAG.FM.Stück";
    BAG.F.Fertig.Menge  # BAG.F.Fertig.Menge  - BAG.FM.Menge;
    Erx # BA1_F_Data:Replace(_recUnlock,'AUTO');
  end;
  if (erx<>_rOK) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001000+Erx,Translate('Fertigung'));
if (vDebug)then debugx('aua');
    RETURN false;
  end;

  // 10.10.2012 AI
  // Auf.Aktion ändern -----------------------------------------------------
  if (BAG.P.Auftragsnr<>0) or
     (BAG.F.Auftragsnummer<>0) then begin
    // 05.05.2014 AH
    if (BAG.P.Auftragsnr<>0)then
      Erx # Auf_data:Read(BAG.P.Auftragsnr,BAG.P.Auftragspos,n)
    else
      Erx # Auf_data:Read(BAG.F.Auftragsnummer,BAG.F.Auftragspos,n)
    if (Erx=401) or (Erx=411) then begin
      RecBufClear(404);
      Auf.A.Aktionsnr     # BAG.FM.Nummer;
      Auf.A.Aktionspos    # BAG.FM.Position;
      Auf.A.Aktionspos2   # BAG.FM.Fertigung;
      Auf.A.Aktionstyp  # c_Akt_BA_Fertig;

      vOK # n;
      Erx # RecRead(404,2,0);
      WHILE (vOk=false) and (Erx<=_rMultikey) and
        (Auf.A.Aktionsnr=BAG.FM.Nummer) and
        (Auf.A.Aktionspos=BAG.FM.Position) and
        (Auf.A.Aktionspos2=BAG.FM.Fertigung) and
        (Auf.A.Aktionstyp=c_Akt_BA_Fertig) do begin
        if (Auf.A.Materialnr=BAG.FM.Materialnr) and
          (Auf.A.Nummer=Auf.P.Nummer) and (Auf.A.Position=Auf.P.Position) then begin
          vOK # y;
          BREAK;
        end;
        Erx # RecRead(404,2,_recNext);
      END;
      if (vOK) then begin
        if (Auf_A_Data:Entfernen(y)=false) then begin
          if (aNoTrans=false) then TRANSBRK;
          RekRestore(vBuf700);
          RekRestore(vBuf701);
          RekRestore(vBuf702);
          RekRestore(vBuf703);
          Error(001000,Translate('Aufragsaktion'));
if (vDebug)then debugx('aua');
          RETURN false;
        end;
      end;

    end;
  end;



  // Input ändern ----------------------------------------------------------
  Erx # RecLink(701,707,9,_RecLock|_recFirst);   // Input holen
  if (Erx>=_rLocked) then begin
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001000+Erx,Translate('Einsatz'));
if (vDebug)then debugx('aua');
    RETURN false;
  end;
  BAG.IO.Ist.Out.Stk   # BAG.IO.Ist.Out.Stk   - "BAG.FM.Stück";
  BAG.IO.Ist.Out.GewN  # BAG.IO.Ist.Out.GewN  - BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.Out.GewB  # BAG.IO.Ist.Out.GewB  - BAG.FM.Gewicht.Brutt;
  if (BAG.FM.MEH=BAG.IO.MEH.Out) then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge - BAG.FM.Menge;
if (vVorMat<>0) then begin
  if (BAG.IO.MaterialRstNr=vVorMat) then
    BAG.IO.MaterialRstNr # vFMMat;
  if (BAG.IO.MaterialNr=vVorMat) then
    BAG.IO.MaterialNr # vFMMat;
end;

  Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    RecRead(701,1,_recUnlock);
    if (aNoTrans=false) then TRANSBRK;
    RekRestore(vBuf700);
    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);
    Error(001000+Erx,Translate('Einsatz'));
if (vDebug)then debugx('aua');
    RETURN false;
  end;


  // Theoretischen Bruder des Inputs ändern ----------------------------------------------------------
  if (Bag.IO.BruderID <> 0) then begin
    BAG.IO.ID # Bag.IO.BruderID;
    Erx # RecRead(701,1,_RecLock);   // Input holen
    if (Erx>=_rLocked) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000+Erx,Translate('Einsatz'));
if (vDebug)then debugx('aua');
      RETURN false;
    end;
    BAG.IO.Ist.Out.Stk   # BAG.IO.Ist.Out.Stk   - "BAG.FM.Stück";
    BAG.IO.Ist.Out.GewN  # BAG.IO.Ist.Out.GewN  - BAG.FM.Gewicht.Netto;
    BAG.IO.Ist.Out.GewB  # BAG.IO.Ist.Out.GewB  - BAG.FM.Gewicht.Brutt;
    if (BAG.FM.MEH=BAG.IO.MEH.Out) then
      BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge - BAG.FM.Menge;
    Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      RecRead(701,1,_recUnlock);
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000+Erx,Translate('Einsatz'));
if (vDebug)then debugx('aua');
      RETURN false;
    end;
    Erx # RecLink(701,707,9,_recFirst);   // Input holen    fix 13.11.2019
  end;


  // Einsatzkarte ändern ---------------------------------------------------

  if (BAG.P.Aktion=c_BAG_MatPrd) then begin
    // Beistellungne loopen...
    Erx # RecLink(708,707,12,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (BAG.FM.B.VonId=0) then begin
        Erx # RecLink(708,707,12,_recNext);
        CYCLE;
      end;

      Erx # RecLink(701,708,5,_recFirst);   // VonID holen
      if (Erx<>_rOK) then begin
        if (aNoTrans=false) then TRANSBRK;
        RekRestore(vBuf700);
        RekRestore(vBuf701);
        RekRestore(vBuf702);
        RekRestore(vBuf703);
        Error(001000+Erx,Translate('Einsatz')+' '+AInt(BAG.FM.B.VonID));
if (vDebug)then debugx('aua');
        RETURN false;
      end;
      Erx # RecLink(200,701,11,_RecLock|_RecFirst);  // Restkarte holen
      if (Erx<>_rOK) then begin
        if (aNoTrans=false) then TRANSBRK;
        RekRestore(vBuf700);
        RekRestore(vBuf701);
        RekRestore(vBuf702);
        RekRestore(vBuf703);
        Error(001000+Erx,Translate('Einsatz'));
if (vDebug)then debugx('aua');
        RETURN false;
      end;
      if (_EntfernenEinsatz(BAG.FM.B.Gew.Netto, BAG.FM.B.Gew.Brutto, "BAG.FM.B.Stück", BAG.FM.B.Menge)=false) then begin
        RecRead(200,1,_RecUnlock);
        if (aNoTrans=false) then TRANSBRK;
        RekRestore(vBuf700);
        RekRestore(vBuf701);
        RekRestore(vBuf702);
        RekRestore(vBuf703);
        Error(200106,AInt(BAG.FM.Materialnr));
if (vDebug)then debugx('aua');
        RETURN false;
      end;
      erx # RekDelete(708,_recUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        vErr # 4;
        BREAK;
      end;
      Erx # RecLink(708,707,12,_recFirst);
    END;
  end
  else begin
//    if (vFMMat<>0) then
//      Erx # Mat_data:Read(vFMMat, _recLock, 0, true)
//    else
    Erx # Mat_data:Read(BAG.IO.MaterialRstNr, _recLock, 0, true); // RestMaterial holen mit ggf. RESTORE
    if (Erx<200) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000+Erx,Translate('Einsatz'));
if (vDebug)then debugx('aua');
      RETURN false;
    end;
    if (_EntfernenEinsatz(BAG.FM.Gewicht.Netto, BAG.FM.Gewicht.Brutt, "BAG.FM.Stück", BAG.FM.Menge)=false) then begin
      Erx # RecRead(200,1,_RecUnlock);
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(200106,AInt(BAG.FM.Materialnr));
if (vDebug)then debugx('aua');
      RETURN false;
    end;
  end;


  // Fertigmeldung nullen --------------------------------------------------
  if (vVorMat<>0) then begin
    WHILE RecLink(705,707,13,_recFirst)=_rOK do begin
      Erx # RekDelete(705);
      if (Erx <> _rOK) then begin
        if (aNoTrans=false) then TRANSBRK;
        RekRestore(vBuf700);
        RekRestore(vBuf701);
        RekRestore(vBuf702);
        RekRestore(vBuf703);
        Error(200106,AInt(BAG.FM.Materialnr));
  if (vDebug)then debugx('aua');
        RETURN false;
      end;
      
    end;
    RekDelete(707);
  end
  else begin
    Erx # RecRead(707,1,_recLock);
    if (Erx<>_rOK) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000+Erx,Translate('Fertigmeldung'));
  if (vDebug)then debugx('aua');
      RETURN false;
    end;
    BAG.FM.Status           # c_Status_BAGAusfall;  // auf Ausfall setzen
    "BAG.FM.Stück"          # 0;
    BAG.FM.Gewicht.Netto    # 0.0;
    BAG.FM.Gewicht.Brutt    # 0.0;
    BAG.FM.Menge            # 0.0;
    
    if (vVorMat<>0) then
      BAG.FM.Materialnr # vVorMat;
    
    Erx # RekReplace(707,_recUnlock,'AUTO');
    if (Erx <> _rOK) then begin
      if (aNoTrans=false) then TRANSBRK;
      RekRestore(vBuf700);
      RekRestore(vBuf701);
      RekRestore(vBuf702);
      RekRestore(vBuf703);
      Error(001000+Erx,Translate('Fertigmeldung'));
      if (vDebug)then debugx('aua');
      RETURN false;
    end;
    
    
  end;

  if (aNoTrans=false) then TRANSOFF;

  RekRestore(vBuf700);
  RekRestore(vBuf701);
  RekRestore(vBuf702);
  RekRestore(vBuf703);

  RETURN true;
end;


//========================================================================
//  AlleDerPosEntfernen
//========================================================================
sub AlleDerPosEntfernen() : logic;
local begin
  Erx : int;
  vOK : logic;
end;
begin

  TRANSON;
  
  vOK # true;
  // alle FMs der Pos loopen...
  FOR Erx # RecLink(707,702,5,_recFirst)
  LOOP Erx # RecLink(707,702,5,_recNext)
  WHILE (Erx<=_rLocked) AND (vOK) do begin
    if (BAG.FM.Status<>c_Status_Frei) and (BAG.FM.Status<>c_Status_BAGFertSperre) and (BAG.FM.Status<>c_Status_BAGfertUnklar) then CYCLE;
    vOK # Entfernen(true);
  END;
  
  if (vOK) then
    TRANSOFF
  else
    TRANSBRK;

  RETURN vOK;
end;


//========================================================================
//  TauscheMats
//========================================================================
sub TauscheMats(
  aMat1 : int;    // FM
  aMat2 : int;    // Vorgänger
) : logic;
local begin
  Erx     : int;
end;
begin

  // EINS = FM-Mat
  Mat.Nummer # aMat1;
  Erx # RecRead(200,1,0);
  if (Erx>_rOK) then begin
    RETURN false;
  end;
 
  // ZWEI = Vorgänger-Mat
  Mat.Nummer # aMat2;
  Erx # RecRead(200,1,0);
  if (Erx>_rOK) then begin
    RETURN false;
  end;

  RETURN Mat_Data:TauscheMats(aMat1, aMat2);
end;


//========================================================================
// Vorbelegen
//
//========================================================================
sub Vorbelegen() : logic
local begin
  Erx           : int;
  vNimmAlteAusf : logic;
  vBuf705       : handle;
  vFilter       : handle;
  vSeite        : alpha;
  vI            : int;
  vIgnore       : logic;
end;
begin


  BAG.FM.Nummer         # myTmpNummer;

  BAG.FM.Position       # BAG.F.Position;
  BAG.FM.Fertigung      # BAG.F.Fertigung;
  BAG.FM.Fertigmeldung  # 999;  //vFM;  20.05.2015
  BAG.FM.Verwiegungart  # 1;
  BAG.FM.MEH            # BAG.F.MEH;
  if ("BAG.P.Typ.1In-1OutYN") then  begin // 2022-12-20 AH
    BAG.FM.MEH          # BAG.IO.MEh.out; // vom INPUT=OUTPUT
  end;
    
  BAG.FM.Materialtyp    # c_IO_MAT;
  BAG.FM.Status         # 1;
  BAG.FM.Datum          # today;
  BAG.FM.Zeit           # 0:0;    // wird bei Verbuchen richtig gesetzt, wenn TODAY
  BAG.FM.Verwiegungart  # BAG.Vpg.Verwiegart;
  BAG.FM.Artikelnr      # BAG.F.Artikelnummer;
  BAG.FM.Dicke          # BAG.F.Dicke;
  BAG.FM.Breite         # BAG.F.Breite;
  "BAG.FM.Länge"        # "BAG.F.Länge";
  BAG.FM.Spulbreite     # BAG.F.Spulbreite;

  // Prüfen belegt Mengen vor
  if (BAG.P.Aktion=c_BAG_Check) then begin
    "BAG.FM.Stück"          # BAG.IO.Plan.Out.Stk;
    BAG.FM.Gewicht.Netto    # BAG.IO.Plan.Out.GewN;
    BAG.FM.Gewicht.Brutt    # BAG.IO.Plan.Out.GewB;
    BAG.FM.Menge            # Lib_Einheiten:WandleMEH(701, "BAG.FM.STück", BAG.FM.Gewicht.Netto, BAG.IO.Plan.Out.Meng, BAG.IO.MEH.Out, BAG.F.MEH);
/*** alt 2.7.2013
    "BAG.FM.Stück"          # "BAG.F.Stückzahl";
    BAG.FM.Gewicht.Netto    # BAG.F.Gewicht;
    BAG.FM.Gewicht.Brutt    # BAG.F.Gewicht;
    BAG.FM.Menge            # BAG.F.Menge;
***/
  end;

//  BAG.FM.RID            # Mat.RID;
//  BAG.FM.RAD            # Mat.RAD;
  // 2022-10-26 AH
  if ((BAG.P.Aktion=c_BAG_Saegen) or
    (BAG.P.Aktion=c_BAG_Ablaeng)) // 2023-04-04 AH
    and (Mat.Nummer<>0) then begin
    BAG.FM.RID            # Mat.RID;
    BAG.FM.RAD            # Mat.RAD;
  end
  else if (BAG.P.Aktion=c_BAG_Abcoil) or (BAG.P.Aktion=c_BAG_Tafel) or
    (BAG.P.Aktion=c_BAG_Saegen) then begin
    // 2023-04-04 AH Propupe? or (BAG.P.Aktion=c_BAG_Ablaeng) then begin
    if (BAG.F.Fertigung>=999) then begin
      BAG.FM.RID            # Mat.RID;
      if (BAG.F.RID<>0.0) then BAG.FM.RID # BAG.F.RID;
      BAG.FM.RAD            # 0.0;
    end
    else begin
      BAG.FM.RID            # 0.0;
      BAG.FM.RAD            # 0.0;
    end;
  end
  else begin  // alle anderen Arbeitsgänge:
    BAG.FM.RID              # BAG.F.RID;
    BAG.FM.RAD              # 0.0;
  end;

  vNimmAlteAusf # true;

  if (RunAFX('BAG.FM.Vorbelegung.AusF','')<>0) then begin
    vNimmAlteAusf # (AfxRes=_rOK);
  end;


  // 15.02.2021 AH: ab hier alles neu
  vFilter # RecFilterCreate(705, 1);
  vFilter->RecFilterAdd(4, _FltAND, _FltEq, 0);

  // Ausfuehrung kopieren
  if (Mat.Nummer<>0) and (vNimmAlteAusf) then begin
    BAG.FM.AusfOben # "Mat.AusführungOben";     // 08.04.2021 AH
    BAG.FM.AusfUnten # "Mat.AusführungUnten";

    // Vormaterial AF loopen...
    FOR Erx # RecLink(201, 200, 11, _recFirst)
    LOOP Erx # RecLink(201, 200, 11, _recNext)
    WHILE (Erx <= _rLocked) DO BEGIN
      // Gegenteile überspringen
      if (Mat.AF.ObfNr<>0) then begin
        vIgnore # false;
        FOR Erx # RecLink(705, 703, 8, _recFirst, vFilter)
        LOOP Erx # RecLink(705, 703, 8, _recNext, vFilter)
        WHILE (Erx<=_rLocked) and (vIgnore=false) do begin
          if (BAG.AF.ObfNr=0) then CYCLE;
          if (BAG.AF.Seite<>Mat.AF.Seite) then CYCLE;
          Erx # RecLink(841,705,1,_recFirst);   // Obf holen
          vIgnore # (Erx<=_rLocked) and (Obf.Gegenteil.ObfNr=Mat.AF.ObfNr);
        END;
        if (vIgnore) then CYCLE;
      end;


      // Übernehmen
      RecBufClear(705);
      BAG.AF.Nummer         # BAG.FM.Nummer;
      BAG.AF.Position       # BAG.FM.Position;
      BAG.AF.Fertigung      # BAG.FM.Fertigung;
      BAG.AF.Fertigmeldung  # BAG.FM.Fertigmeldung;
      BAG.AF.Seite          # Mat.AF.Seite;
      BAG.AF.lfdNr          # 1;
      BAG.AF.ObfNr          # Mat.AF.ObfNr;
      BAG.AF.Bezeichnung    # Mat.AF.Bezeichnung;
      BAG.AF.Zusatz         # Mat.AF.Zusatz;
      BAG.AF.Bemerkung      # Mat.AF.Bemerkung;
      "BAG.AF.Kürzel"       # "Mat.AF.Kürzel";
      REPEAT
        Erx # RekInsert(705, 0, 'AUTO');
        if (Erx = _rDeadlock) then begin
          RecFilterDestroy(vFilter);
          Error(001010,Translate('Ausführung'));
          RETURN false;
        end;
        if (Erx<>_rOK) then BAG.AF.lfdNr # BAG.AF.lfdNr + 1;
      UNTIL (Erx=_rOK);
      
    END;
  end;

  vBuf705 # RecBufCreate(705);

  // Alle AF der Fertigung übernehmen
  FOR Erx # RecLink(705, 703, 8, _recFirst, vFilter)  // Ausfuehrung aus Fertigung kopieren
  LOOP Erx # RecLink(705, 703, 8, _recNext, vFilter)
  WHILE(Erx <= _rLocked) DO BEGIN
    RecBufCopy(705, vBuf705);

    BAG.AF.Nummer         # BAG.FM.Nummer;
    BAG.AF.Fertigmeldung  # BAG.FM.Fertigmeldung;
    Erx # RecRead(705,3,_recTest);  // existiert schon?
    if (Erx > _rMultikey) then begin      // ST 2021-03-16 Bugfix
      REPEAT
        Erx # RekInsert(705,0,'AUTO');
        if (Erx = _rDeadlock) then begin
          RecFilterDestroy(vFilter);
          RecBufDestroy(vBuf705);
          Error(001010,Translate('Ausführung'));
          RETURN false;
        end;
        
        if (Erx<>_rOK) then BAG.AF.lfdNr # BAG.AF.lfdNr + 1;
      UNTIL (Erx=_rOK);
    end;

    RecBufCopy(vBuf705, 705);
    Recread(705,1,0);
  END;
  RecBufDestroy(vBuf705);
  
  RecFilterDestroy(vFilter);
  
  if(RecLinkInfo(705, 707, 13, _recCount) > 0) then begin // Mehr als 0 Ausfuehrungen kopiert?
    BAG.FM.AusfOben # Obf_Data:BildeAFString(707,'1');
    BAG.FM.AusfUnten # Obf_Data:BildeAFString(707,'2');
  end;

  RunAFX('BAG.FM.Vorbelegung.Post','');

  RETURN true;
end;


//========================================================================
//  MengenDifferenz   + ERR
//      !!! GEHT NICHT BEI FAHREN !!!
//      Korrigiert die Mengen einer Verwiegung im Nachhinein:
//      - ändert den OUTPUT
//      - ändert das OUTPUT-Material
//      - ändert den BRUDER
//      - ändert die Fertigung
//      - ändert ggf. die Auf.Aktion
//      - ändert den INPUT
//      - ändert ggf. den INPUTBRUDER
//      - ändert das INPUT-Material (+Bestandsbuch)
//      - ändert die Mat.Aktion
//      - ändert die Fertigmeldung (707)
//========================================================================
SUB MengenDifferenz(
  aStk    : int;
  aGewN   : float;
  aGewB   : float;
  aM      : float;
  aM2     : float) : logic
local begin
  Erx     : int;
  vDStk   : int;
  vDGewN  : float;
  vDGewB  : float;
  vDM     : float;
  vDM2    : float;
  vM,vM2  : float;
  vGewBB  : float;
  vMBB    : float;
  vOK     : logic;
  v702    : int;
  vVsbAuf : int;
  vVsbPos : int;
  vMatIn  : int;
  vFound  : logic;
end;
begin
  vDStk   # aStk - "BAG.FM.Stück";
  vDGewN  # aGewN - BAG.FM.Gewicht.netto;
  vDGewB  # aGewB - BAG.FM.Gewicht.brutt;
  vDM     # aM - BAG.FM.Menge;
  vDM2    # aM2 - BAG.FM.Menge2;
  // keine Änderung?
  if (vDStk=0) and (vDGewN=0.0) and (vDGewB=0.0) and (vDM=0.0) and (vDM2=0.0) then RETURN true;

  if (BAG.P.Aktion=c_BAG_Fahr) then begin
    Error(999999,'Fertigmledungen von "Fahren" können nicht verändert werden!');
    RETURN false;
  end;

  if (BAG.FM.Materialnr=0) then begin
    Error(999999,'Keine Materialkarte zum ändern!');
    RETURN false;
  end;


  Erx # RecLink(703, 707, 3, _recFirst);   // Fertigung holen
  if (Erx<>_rOK) then begin
    Error(999999,'Fertigung kann nicht gelesen werden!');
    RETURN false;
  end;

  TRANSON;

  // OUTPUT ändern -----------------------------------------------------------
  Erx # RecLink(701,707,5,_recFirst|_recLock);    // OUTPUT holen
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Output kann nicht gelesen werden!');
    RETURN false;
  end;
  BAG.IO.Ist.IN.Stk     # BAG.IO.Ist.IN.Stk + vDStk;
  BAG.IO.Ist.IN.GewN    # BAG.IO.Ist.IN.GewN + vDGewN;
  BAG.IO.Ist.IN.GewB    # BAG.IO.Ist.IN.GewB + vDGewB;
  if (BAG.FM.Meh=BAG.IO.MEH.IN) then
    BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge + vDM
  else if (BAG.FM.Meh2=BAG.IO.MEH.IN) and (BAG.FM.MEH2<>'') then
    BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge + vDM2;
  BAG.IO.Plan.IN.Stk    # BAG.IO.Ist.IN.Stk;
  BAG.IO.Plan.IN.GewN   # BAG.IO.Ist.IN.GewN;
  BAG.IO.Plan.IN.GewB   # BAG.IO.Ist.IN.GewB;
  BAG.IO.Plan.IN.Menge  # BAG.IO.Ist.IN.Menge;
  BAG.IO.Plan.Out.Stk   # BAG.IO.Ist.IN.Stk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.Ist.IN.GewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.Ist.IN.GewB;
  if (BAG.FM.Meh=BAG.IO.MEH.Out) then
    BAG.IO.Plan.Out.Meng # BAG.IO.Plan.Out.Meng + vDM
  else if (BAG.FM.MEH2=BAG.IO.MEH.Out) and (BAG.FM.MEH2<>'') then
    BAG.IO.Plan.Out.Meng # BAG.IO.Plan.Out.Meng + vDM2
  else
    BAG.IO.Plan.Out.Meng # Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);
  Erx # RekReplace(701);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Output kann nicht verändert werden!');
    RETURN false;
  end;


  // Output-Material ändern -------------------------------------------------------
  Erx # RecLink(200, 707,7,_recFirst | _recLock);  // Karte holen
  if (Erx>_rLocked) then begin
    TRANSBRK;
    Error(999999,'Material '+aint(BAG.FM.Materialnr)+' nicht mehr im Bestand!');
    RETURN false;
  end;
  if (Erx=_rLocked) then begin
    TRANSBRK;
    Error(999999,'Material '+aint(BAG.FM.Materialnr)+' ist gesperrt durch User '+LockedBy);
    RETURN false;
  end;
  Mat.Bestand.Stk     # Mat.Bestand.Stk + vDStk;
  Mat.Gewicht.Netto   # Mat.Gewicht.Netto + vDGewN;
  Mat.Gewicht.Brutto  # Mat.Gewicht.Brutto + vDGewB;
  Mat.Bestand.Gew     # -1.0;        // freimachen zur Berechnung

  if (Mat.MEH=BAG.FM.MEH) then
    Mat.Bestand.Menge # Mat.Bestand.Menge - vDM
  else if (Mat.MEH=BAG.FM.MEH2) then
    Mat.Bestand.Menge # Mat.Bestand.Menge - vDM2
  else if (Mat.MEH='Stk') then
    Mat.Bestand.Menge # Mat.Bestand.Menge + cnvfi(vDStk);

  Erx # Mat_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Material '+aint(Mat.Nummer)+' kann nicht verändert werden!');
    RETURN false;
  end;


  // BRUDER ändern ---------------------------------------------------------
  Erx # RecLink(701,707,11,_RecLock|_recFirst);   // Bruder holen
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Bruder kann nicht gelesen werden!');
    RETURN false;
  end;
  BAG.IO.Ist.In.Stk  # BAG.IO.Ist.In.Stk   + vDStk;
  BAG.IO.Ist.In.GewN # BAG.IO.Ist.In.GewN  + vDGewN;
  BAG.IO.Ist.In.GewB # BAG.IO.Ist.In.GewB  + vDGewB;
  if (BAG.FM.Meh=BAG.IO.MEH.In) then
    BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge + vDM;
  Erx # RekReplace(701);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Bruder kann nicht verändert werden!');
    RETURN false;
  end;


  // Fertigung ändern --------------------------------------------------------------
  Erx # RecLink(703, 707, 3, _recFirst|_recLock);   // Fertigung holen
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Fertigung kann nicht verändert werden!');
    RETURN false;
  end;
  BAG.F.Fertig.Gew    # BAG.F.Fertig.Gew    + vDGewN;
  BAG.F.Fertig.Stk    # BAG.F.Fertig.Stk    + vDStk;
  if (BAG.FM.Meh=BAG.F.MEH) then
    BAG.F.Fertig.Menge  # BAG.F.Fertig.Menge  + vDM
  else if (BAG.FM.MEH2=BAG.F.MEH) and (BAG.FM.MEH2<>'') then
    BAG.F.Fertig.Menge  # BAG.F.Fertig.Menge  + vDM2
  else if (BAG.F.MEH='Stk') then
    BAG.F.Fertig.Menge  # BAG.F.Fertig.Menge  + cnvfi(vDStk)
  else begin
    vM # Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.F.MEH);
    vM # Lib_Einheiten:WandleMEH(707, aStk, aGewN, aM, BAG.FM.MEH, BAG.F.MEH) - vM;
    BAG.F.Fertig.Menge # BAG.F.Fertig.Menge + vM;
  end;
  Erx # RekReplace(703);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Fertigung kann nicht verändert werden!');
    RETURN false;
  end;

  // VSB-AufAktion ändern -------------------------------------------------
  if (BAG.IO.NachBAG<>0) then begin     // Weiterbearbeitung?
    v702 # RekSave(702);
    Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin
      if (BAG.P.Aktion=c_BAG_VSB) and (BAG.P.Auftragsnr<>0) then begin
        vVsbAuf # BAG.P.Auftragsnr;
        vVsbPos # BAG.P.Auftragspos;
      end;
    end;
    RekRestore(v702);
  end;
  if (vVsbAuf<>0) then begin
    Erx # Auf_data:Read(vVsbAuf, vVsbPos,n);
    if (Erx=401) then begin

      vFound  # false;

      Auf.A.Aktionstyp    # c_Akt_BA_Fertig;
      Auf.A.Aktionsnr     # BAG.FM.Nummer;
      Auf.A.Aktionspos    # BAG.FM.Position;
      Auf.A.Aktionspos2   # BAG.FM.Fertigung;
      Erx # RecRead(404, 2, 0);
      WHILE (Erx = _rMultikey) OR (Erx = _rOK) DO BEGIN     // Suche FM Aktion
        if (Auf.A.Materialnr = BAG.FM.Materialnr) then begin
          vFound   # true;
          BREAK;
        end
        Erx # RecRead(404, 2, _RecNext);
      END;
      if (vFound) then begin

        RecRead(404,1,_recLock);
        "Auf.A.Stückzahl"   # aStk;
        Auf.A.Gewicht       # aGewN;
        Auf.A.Nettogewicht  # aGewB;
        if (Auf.A.MEH=BAG.FM.MEH) then
          Auf.A.Menge       # aM
        else if (Auf.A.MEH=BAG.FM.MEH2) then
          Auf.A.Menge       # aM2
        else if (Auf.A.MEH='kg') then
          Auf.A.Menge       # Auf.A.Gewicht
        else if (Auf.A.MEH='t') then
          Auf.A.Menge       # Auf.A.Gewicht / 1000.0
        else if (Auf.A.MEH='Stk') then
          Auf.A.Menge       # Cnvfi("Auf.A.Stückzahl")
        else if (Auf.A.MEH.Preis=BAG.FM.MEH) then
          Auf.A.Menge.Preis # aM
        else if (Auf.A.MEH.Preis=BAG.FM.MEH2) then
          Auf.A.Menge.Preis # aM2
        else if (Auf.A.MEH.Preis='kg') then
          Auf.A.Menge.Preis # Auf.A.Gewicht
        else if (Auf.A.MEH.Preis='t') then
          Auf.A.Menge.Preis # Auf.A.Gewicht / 1000.0
        else if (Auf.A.MEH.Preis='Stk') then
          Auf.A.Menge.Preis # Cnvfi("Auf.A.Stückzahl");
        RunAFX('BAG.Set.Auf.Aktion','');
        Erx # RekReplace(404);
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Error(999999,'AufAktion kann nicht verändert werden!');
          RETURN false;
        end;
        if (Auf_A_Data:RecalcAll()=false) then begin
          TRANSBRK;
          Error(999999,'Auftrag '+aint(vVsbAuf)+'/'+aint(vVsbPos)+' kann nicht verändert werden!');
          RETURN false;
        end;
      end;
    end;
  end;

/*** MUSS DAS?
  // Auf.Aktion ändern -----------------------------------------------------
  if (BAG.P.Auftragsnr<>0) or
     (BAG.F.Auftragsnummer<>0) then begin
    if (BAG.P.Auftragsnr<>0) then
      Erx # Auf_data:Read(BAG.P.Auftragsnr,BAG.P.Auftragspos,n)
    else
      Erx # Auf_data:Read(BAG.F.Auftragsnummer,BAG.F.Auftragspos,n)
    if (Erx=401) or (Erx=411) then begin
      RecBufClear(404);
      Auf.A.Aktionsnr     # BAG.FM.Nummer;
      Auf.A.Aktionspos    # BAG.FM.Position;
      Auf.A.Aktionspos2   # BAG.FM.Fertigung;
      Auf.A.Aktionstyp  # c_Akt_BA_Fertig;

      vOK # n;
      Erx # RecRead(404,2,0);
      WHILE (vOk=false) and (Erx<=_rMultikey) and
        (Auf.A.Aktionsnr=BAG.FM.Nummer) and
        (Auf.A.Aktionspos=BAG.FM.Position) and
        (Auf.A.Aktionspos2=BAG.FM.Fertigung) and
        (Auf.A.Aktionstyp=c_Akt_BA_Fertig) do begin
        if (Auf.A.Materialnr=BAG.FM.Materialnr) and
          (Auf.A.Nummer=Auf.P.Nummer) and (Auf.A.Position=Auf.P.Position) then begin
          vOK # y;
          BREAK;
        end;
        Erx # RecRead(404,2,_recNext);
      END;
      if (vOK) then begin
        Erx # RecRead(404,1,_recLock);

        RecRead(404,1,_recLock);
        Erx # RekReplace(404,_recUnlock,'AUTO');
        if (Erx<>_rOk) then begin
          TRANSBRK;
          Error(999999,'AufAktion kann nicht verändert werden!');
          RETURN false;
        end;
        if (Auf_A_Data:RecalcAll()=false) then begin
          TRANSBRK;
          Error(999999,'AufAktion kann nicht verändert werden!');
          RETURN false;
        end;
      end;
    end;
  end;
*****/



  // Input ändern -------------------------------------------------------------
  Erx # RecLink(701,707,9,_recFirst|_recLock);   // INPUT holen
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Input kann nicht gelesen werden!');
    RETURN false;
  end;
  BAG.IO.Ist.Out.Stk   # BAG.IO.Ist.Out.Stk   + vDStk;
  BAG.IO.Ist.Out.GewN  # BAG.IO.Ist.Out.GewN  + vDGewN;
  BAG.IO.Ist.Out.GewB  # BAG.IO.Ist.Out.GewB  + vDGewB;
  if (BAG.FM.MEH=BAG.IO.MEH.Out) then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + vDM;
  Erx # RekReplace(701);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Input kann nicht verändert werden!');
    RETURN false;
  end;


  // Theoretischen Bruder des Inputs ändern ----------------------------------------------------------
  if (Bag.IO.BruderID <> 0) then begin
    BAG.IO.ID # Bag.IO.BruderID;
    Erx # RecRead(701,1,_RecLock);   // Input holen
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Error(999999,'Inputsbruder kann nicht gelesen werden!');
      RETURN false;
    end;
    BAG.IO.Ist.Out.Stk   # BAG.IO.Ist.Out.Stk   + vDStk;
    BAG.IO.Ist.Out.GewN  # BAG.IO.Ist.Out.GewN  + vDGewN;
    BAG.IO.Ist.Out.GewB  # BAG.IO.Ist.Out.GewB  + vDGewB;
    if (BAG.FM.MEH=BAG.IO.MEH.Out) then
      BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + vDM;
    Erx # RekReplace(701);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Error(999999,'Inputsbruder kann nicht verändert werden!');
      RETURN false;
    end;
  end;


  // INPUT-MaterialRest ändern ---------------------------------------------------------------
  Erx # RecLink(701,707,9,_recFirst);   // INPUT holen
  Erx # RecLink(200, 701,11,_recFirst | _recLock);  // RestKarte holen
  if (Erx>_rLocked) then begin
    TRANSBRK;
    Error(999999,'Material '+aint(BAG.IO.MaterialRstnr)+' nicht mehr im Bestand!');
    RETURN false;
  end;
  if (Erx=_rLocked) then begin
    TRANSBRK;
    Error(999999,'Material '+aint(BAG.IO.MaterialRstNr)+' ist gesperrt durch User '+LockedBy);
    RETURN false;
  end;

  // Ursprüngliche InputMatNr besteimmen...
  if (BAG.IO.BruderID=0) then begin
    vMatIn              # BAG.IO.Materialnr;
  end
  else begin
    if (Set.BA.BuchungAlgoNr<3) then      // 13.05.2022 AH
      vMatIn              # "Mat.Vorgänger"
    else
      vMatIn              # Mat.Nummer;
  end;


  vGewBB  # Mat.Bestand.Gew;
  vMBB    # Mat.Bestand.Menge;
  Mat.Gewicht.Netto   # Mat.Gewicht.Netto   - vDGewN;
  Mat.Gewicht.Brutto  # Mat.Gewicht.Brutto  - vDGewB;
  if ("BAG.P.Typ.1In-1OutYN") or (BAG.P.Aktion=c_BAG_spulen) or
    (BAG.P.Aktion=c_BAG_Paket) then
    Mat.Bestand.Stk     # Mat.Bestand.Stk - vDStk;
  Mat.Bestand.Gew     # -1.0;  // freimachen zur Berechnung


  vM # 0.0;
  if (Mat.MEH=BAG.FM.MEH) then
    vM # vDM
  else if (Mat.MEH=BAG.FM.MEH2) then
    vM # vDM2
  else if (Mat.MEH='Stk') then
    vM # cnvfi(vDStk)
  else if (Mat.MEH='kg') then
    vM # vDGewN
  else if (Mat.MEH='t') then
    vM # vDGewN / 1000.0;
  Mat.Bestand.Menge # Mat.Bestand.Menge - vM;

  vM2 # Mat.Bestand.Menge;
  if (vM=0.0) or (vM2=0.0) then begin
    Mat.Bestand.Menge # 0.0;
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Error(999999,'Material '+aint(Mat.Nummer)+' kann nicht verändert werden!');
      RETURN false;
    end;
  end
  else begin
    Erx # Mat_Data:Replace(_reclock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Error(999999,'Material '+aint(Mat.Nummer)+' kann nicht verändert werden!');
      RETURN false;
    end;
    Mat.Bestand.Menge # vM2;
    RekReplace(200,_recunlock,'AUTO');
  end;
  vGewBb  # Mat.Bestand.Gew - vGewBB;
  vMBB    # Mat.Bestand.Menge - vMBB;
//debugx('KEY200 mat.bestand:'+anum(Mat.Bestand.Menge,2));


  // Bestandsbuch ändern -----------------------------------------------
  RecBufClear(202);
  "Mat.B.Trägertyp"     # c_Akt_BA_Fertig;
  "Mat.B.TrägerNummer1" # BAG.FM.Nummer;
  "Mat.B.TrägerNummer2" # BAG.FM.Position;
  "Mat.B.TrägerNummer3" # BAG.FM.Fertigung;
  "Mat.B.TrägerNummer4" # BAG.FM.Fertigmeldung;
  Erx # RecRead(202, 3, 0);
  if (Erx<>_rMultikey) or (Mat.B.Materialnr<>BAG.IO.MaterialRstNr) then begin
    TRANSBRK;
    Error(999999,'Bestandsbucheintrag kann nicht gelesen werden!');
    RETURN false;
  end;
  Erx # RecRead(202,1,_recLock);
  if (Erx = _rOK) then begin
    "Mat.B.Stückzahl" # - aStk;
    Mat.B.Gewicht     # Mat.B.Gewicht + vGewBB;
    Mat.B.Menge       # Mat.B.Menge + vMBB;
    Erx # RekReplace(202);
  end;
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Bestandsbucheintrag kann nicht verändert werden!');
    RETURN false;
  end;


  // Mat-Aktion ändern ---------------------------------------------------
  RecBufClear(204);
  Mat.A.Aktionstyp    # c_Akt_BA_Fertig;
  Mat.A.Aktionsnr     # BAG.FM.Nummer;
  Mat.A.Aktionspos    # BAG.FM.Position;
  Mat.A.Aktionspos2   # BAG.FM.Fertigung;
  Mat.A.Aktionspos3   # BAG.FM.Fertigmeldung;
  Erx # RecRead(204,2,0);
//debugx('KEY707 KEY204 er:Erx  '+aint(Mat.A.Materialnr)+' soll '+aint(vMatIn));
  if (Erx<>_rMultikey) or (Mat.A.Materialnr<>vMatIn) then begin
    TRANSBRK;
    Error(999999,'MatAktion kann nicht gelesen werden!');
    RETURN false;
  end;
  Erx # RecRead(204,1,_recLock);
  if (Erx = _rOK) then begin
    "Mat.A.Stückzahl"   # - "Mat.B.Stückzahl";    // andersherum wie Bestandsbuch
    Mat.A.Gewicht       # - Mat.B.Gewicht;        // andersherum wie Bestandsbuch
    Mat.A.Menge         # - Mat.B.Menge;          // andersherum wie Bestandsbuch
    Erx # RekReplace(204);
  end;
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'MatAktion kann nicht verändert werden!');
    RETURN false;
  end;


  // Fertigmeldung ändern -------------------------------------------------
  Erx # RecRead(707,1,_recLock);
  if (Erx = _rOK) then begin
    "BAG.FM.Stück"        # aStk;
    BAG.FM.Gewicht.netto  # aGewN;
    BAG.FM.Gewicht.brutt  # aGewB;
    BAG.FM.Menge          # aM;
    BAG.FM.Menge2         # aM2;
    Erx # RekReplace(707);
  end;
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Verwiegung nicht änderbar!');
    RETURN false;
  end;



/**** ??? ist das InputsBruder?
  // BRUDER ändern ------------------------------------------------------
  Erx # RecLink(701,707,5,_recFirst|_recLock);    // BRUDER holen
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Bruder kann nicht gelesen werden!');
    RETURN false;
  end;
  if (BAG.P.Aktion<>c_BAG_Spulen) then
    BAG.IO.Ist.In.Stk  # BAG.IO.Ist.In.Stk   + vDStk;
  BAG.IO.Ist.In.GewN # BAG.IO.Ist.In.GewN  + vDGewN;
  BAG.IO.Ist.In.GewB # BAG.IO.Ist.In.GewB  + vDGewB;
  if (BAG.FM.Meh=BAG.IO.MEH.In) then
    BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge + vDM;
  Erx # RekReplace(701);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(999999,'Bruder kann nicht verändert werden!');
    RETURN false;
  end;
***/

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//========================================================================
//  CalcSchrottGewAnteil
//      Errechnet das Gewicht von BA-Schrott "auf dem Weg zum Material"
//      das anzeilig am FM-Gewicht
//========================================================================
sub CalcSchrottGewAnteil(
  aMat          : int;
  opt aSubProz  : float;
  opt aBrutto   : logic;
  ) : float;
local begin
  Erx       : int;
  v200      : int;
  vIchKG    : float;
  vSchrott  : float;
  vProz     : float;
  vAnteil   : float;
  vX        : float;
  vY        : float;
  vIN, vOUt : float;
end;
begin
  v200 # RekSave(200);

  if (Mat.Nummer<>aMat) then begin
    Erx # Mat_Data:Read(aMat);
    if (Erx<200) then begin
      RekRestore(v200);
      RETURN 0.0;
    end;
  end;
//debugx('KEY200');
  RecBufClear(707);                     // BA-FM leeren

  Erx # RecLink(707,200,28,_recFirst);  // FM suchen
  if (Erx>=_rLocked) then begin
    if ("Mat.Vorgänger"<>0) then begin
      RekRestore(v200);
      RETURN CalcSchrottGewAnteil("Mat.Vorgänger",0.0,aBrutto);
    end;
    RETURN 0.0;
  end;

  vIchKG  # BAG.FM.Gewicht.Netto;
  if (aBrutto) then
    vIchKG  # BAG.FM.Gewicht.Brutt;

  Erx # RecLink(701,707,9,_recFirst);   // IO-Input holen
  if (Erx>_rLocked) then begin
    RekRestore(v200);
    RETURN 0.0;
  end;

  if (BAG.IO.Materialnr=0) then begin
    RekRestore(v200);
    RETURN 0.0;
  end;

  vOUT  # BAG.IO.Ist.Out.GewN;
  vIN   # BAG.IO.Plan.In.GewN;
  if (aBrutto) then begin
    vOUT # BAG.IO.Ist.Out.GewB;
    vIN # BAG.IO.Plan.In.GewB;
  end;
  vProz # Lib_Berechnungen:Prozent(vIchKG, vOut);
  vY # vProz;
  if (aSubProz<>0.0) then begin
    vProz # vProz * (aSubProz / 100.0);
  end;

  vSchrott # vIN - vOut
  vAnteil   # vSchrott * (vProz / 100.0);
if gUSername='AH' and (vAnteil<>0.0) then begin
  if (aSubProz=0.0) then
debug('KEY701: Schrott '+anum(vSchrott,0)+'kg , IN:'+anum(vIN,0)+'kg, FM:'+anum(vIchKG,0)+'kg => '+anum(vProz,3)+'% ===> '+anum(vAnteil,5)+'kg')
else
debug('KEY701: Schrott '+anum(vSchrott,0)+'kg , IN:'+anum(vIN,0)+'kg, FM:'+anum(vIchKG,0)+'kg => '+anum(aSubPRoz,3)+'% von '+anum(vY,3)+'%='+anum(vProz,3)+'% ===> '+anum(vAnteil,5)+'kg');
end;

  // Wenn MatNr=RestMatNr dann ist die Mat-IO eine Weiterbearbeitung!
  if (BAG.IO.Materialnr=BAG.IO.MaterialRstNr) then begin
    Erx # Mat_Data:Read(BAG.IO.MaterialRstNr);
    if (Erx<200) then begin
      RekRestore(v200);
      RETURN vAnteil;
    end;
    vX # vAnteil + CalcSchrottGewAnteil(Mat.Nummer, vProz, aBrutto);
    RekRestore(v200);
    RETURN vX;
  end;

  RekRestore(v200);

  // Einsatz ist MATERIAL?
  RETURN vAnteil;
end;


//========================================================================