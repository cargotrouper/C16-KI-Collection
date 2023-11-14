@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_P_Data
//                      OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  18.03.2010  MS  DelAllVSB + BereitsVerwiegung + EinsatzVorhanden
//  10.06.2010  AI  Erweiterung für AAR 710
//  13.07.2010  AI  Bug in DelAllVSB behoben (hat nicht alle Inputs gelöscht)
//  19.08.2010  AI  DelAllVSB korrigiert (hat ggf. gelöscht, obwohl verwogen war)
//  19.08.2010  AI  Einsatzvorhanden korrigiert (hat zu viel "abgewiesen")
//  10.02.2012  AI  UpdateAufAktion buffert 401
//  07.05.2012  AI  RestorePos prüft Nachfolger erst noch ab (Prj. 1326/222)
//  03.09.2012  AI  BA-Kosten mit in die Aktionsliste schreiben
//  06.09.2012  AI  "Delete" löscht Zeiten + Ressourcen
//  30.11.2012  AI  Storno sucht sich die Schrottcharge wieder raus und legt keine neue an
//  27.05.2013  AI  "CheckVSB" prüft gegen AuftragswusnchMEH und nicht nur Gewicht
//  04.06.2013  AI  bei Berechnungsart 701 (Output) nur gleiche Kommission auch addieren
//  28.06.2013  AH  "AutoVSB" setzt bei Fertigungen ohne Kommission nur VSB/Lager
//  14.08.2013  AH  "CheckVSB" prüft gegen AuftragsEINSATZ-MEH und nicht Wunsch
//  08.10.2013  ST  sub ErmittleMEH(...) um Ankerufruf erweitert (1326/370)
//  08.10.2013  ST  ErmittleMEH liest MEH aus Arbeitsgang
//  18.12.2013  AH  "RestorePos" reserivert Einsatzartikel wieder
//  15.05.2014  AH  "UpdateAufAktion" holt sich veränderte AufPos.
//  16.05.2014  AH  "_ErzeugeBAGAusLFS" nimm LFS.P.MEH.Einsatz
//  22.05.2014  AH  "_ErzeugeBAGAusLFS" setzt Ist aif Plan
//  21.07.2014  AH  "RestorePos" setzt Mat.Status wieder richtig auf "in BA..."
//  01.08.2014  ST  "RestorePos" Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  06.11.2014  AH  "_ErzeugeBAGAusLFS" setzt BAG.IO.ID nicht noch weiter hoch (Sonst Probleme bei Matreservierung)
//  06.03.2015  AH  "Merge"
//  10.03.2015  AH  "Rename702Text"
//  10.04.2015  AH  Auftrags-SL in Kommission aktiviert
//  24.04.2015  AH  "ImportBA"
//  01.03.2016  ST  Neuer Anker "BAG.P.AutoVSB" in "sub AutoVSB()"
//  17.03.2016  AH  Neu: Feld "BAG.P.Status" und Subs "RepairStatus", "Replace" , "Insert"
//  22.03.2016  AH  Neu: "ComboClosedCheck"
//  13.03.2017  AH  Fix: "Merge" von Fahren nummeriert die Referenzen in LFS auch richtig
//  06.07.2017  AH  Fix: "UpdateSort"
//  21.03.2018  AH  Edit: "ImportBA" kann bei Copy echtes Mat in Theo wandeln
//  04.05.2018  AH  Edit: "Merge" nur für Spalten mit theoretischem Input
//  29.05.2018  AH  Fix: Merge hat Plandauer nicht gespeichert
//  09.10.2018  ST  "ImportBA" Kopie ohne Fertigmaterial Projekt 1808/60
//  18.10.2018  AH  Edit: "ErrechnePlanmengen" übernimmt ggf. Kommission aus Input (beim Tausch von Theo in Echt beim Fahren)
//  14.01.2019  AH  Fix: Textekopieren beim Merge
//  29.01.2019  AH  Fix für MultiLFS pro BA-Pos.
//  12.02.2019  AH  Neu: "ImportBA" leert einige BA-Pos-Felder beim Kopieren
//  25.02.2019  ST  Bugfix in "UpdateAufAktion..." falls Aufpos mit Nr. 0 existiert
//  05.03.2019  AH  Neu: "SindVorgaengerAbgeschlossen" können Vorgänger-Fahren abschließen
//  27.03.2019  AH  Neu: "ImportBA" kann auch ohne Zeiten
//  10.04.2019  AH  Fix: "ImportBA" kopiert keine Ausführungen der FMs
//  05.07.2019  AH  AFX "BAG.P.AutoVSB.Check"
//  30.09.2019  AH  Neu: "Delete" entfernt auch alle Outputs
//  08.10.2019  AH  Neu: "Merge" kann auch DIVERS + Fix für VSB-Aktionen
//  03.12.2019  ST  Bugfix: "Merge" nur auf Divers ODER Spalten
//  11.05.2020  AH  Neu: "Aufruecken"
//  04.06.2021  AH  Edit: "Merge" akzeptiert auch ein echtes Mat.
//  27.07.2021  AH  ERX
//  28.07.2021  AH  AFX "BA1.ImportBA.Post"
//  13.09.2021  ST  AFX BSC SFX_ESK_Cut:CopyEskToBag(...); Projekt 2298/17
//  11.10.2021  AH  AG "Bereit"
//  15.11.2021  AH  "Auto1zu1"
//  17.01.2022  ST  Bugfix: "ImportBA" nullt IstIn- & OutWerte bei Copy
//  18.01.2022  ST  Bugfix: "sub SindVorgaengerAbgeschlossen", neue Abfrage bringt bei Brockhaus den BAG Fortschritt durcheinander, für BSP abgeschaltet
//  26.01.2022  AH  Fix: "RestorePos" setzt ggf. zuvor entfernte Kommission ins Material wieder ein
//  14.02.2022  AH  Edit: AutoVSB
//  26.04.2022  ST  Edit: "AutoVpg" Kundenreservierung von Vorfertigung werden übernommen
//  07.06.2022  AH  Fix: "Aufruecken" auch für Lohn
//  09.06.2022  AH  Neu: "CopyAbPos"
//  2022-08-31  AH  "Aufruecken" kann auch leere Positionsnr. füllen OHNE Aufrücken
//  2023-01-19  ST  Neu: "SetBagPDelMark" für externen Aufruf zur Datenkorrektur
//  2022-12-19  AH  neue BA-MEH-Logik
//  2023-07-28  SR  AFX "BAG.P.Data.Operation"
//
//  Subprozeduren
//    SUB Rename702Text(aNr : int; aAlt : int; aNeu : int);
//    SUB Copy706vonBA(aVorlageBA : int; aVorlagePos : int) : logic;
//    SUB ReservierenStattStatus(aAktion : alpha) : logic
//    SUB DarfLfsHaben(aAktion : alpha) : logic
//    SUB Muss1AutoFertigungHaben() : logic
//    SUB DarfKostenHaben() : logic
//    SUB DarfSchopfHaben() : logic
//    SUB DarfNur1EinsatzHaben(aAktion : alpha) : logic
//    SUB Erzeuge702(aPos : int; aAG : alpha; aVorlageBA : int; aVorlagePos : int) : logic;
//    SUB EinsatzVorhanden() : logic;
//    SUB BereitsVerwiegung(aBAGAktion : alpha;) : logic;
//    SUB DelThisVSB() : logic;                             22.7.2011 AI
//    SUB DelPosVSB(aBANr : int; aBAPos : int;) : logic;
//    SUB DelAllVSB() : logic;
//    SUB CheckVSBzuAufREST (opt aAll : logic) : logic;
//    SUB AutoVSB() : logic;
//    SUB RecalcThisLevel();
//    SUB Fenster_GetMin(var aMinDat : date; var aMinZeit : time);
//    SUB Fenster_GetMax(var aMaxDat : date; var aMaxZeit : time);
//    SUB UpdateFenster
//    SUB UpdateMinVSB
//    SUB UpdateFolgendeVSB();
//    SUB UpdateAufAktion(aDel : logic) : logic;
//    SUB _ErzeugeBAGausLFS(aBANr : int; aBAPos : int) : logic
//    SUB EreugeBAGausLFS : logic
//    SUB ErrechnePlanmengen(opt aFahrTausch : logic);
//    SUB ErrechnePosRek();
//    SUB Delete(aCheckFertigung : logic) : logic;
//    SUB RestorePos() : logic;
//    SUB ErmittleMEH() : alpha;
//    SUB SindVorgaengerAbgeschlossen(opt aSchliesseVorFahren : logic; opt aAbschlussVorFahren : date) : logic;
// SUB Merge
// SUB ImportBA
//    SUB Aufruecken(aBAG : int; aAbPos : int) : logic
//    SUB ComboPostCloseCheck();
//    SUB RepairStatus();
//    SUB Insert(aLock : int; aGrund : alpha) : int;
//    SUB Replace(aLock : int; aGrund : alpha) : int;
//    SUB CopyAbPos
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG


declare RecalcThisLevel(var aBuf : alpha);
declare UpdateSort();
declare Insert(aLock : int; aGrund : alpha) : int;
declare Replace(aLock : int; aGrund : alpha) : int;
declare Delete(aCheckFertigung : logic) : logic;

//========================================================================
//  Rename702Text
//
//========================================================================
sub Rename702Text(
  aBA1      : int;
  aPos1     : int;
  aBA2      : int;
  aPos2     : int;
  opt aCopy : logic);
local begin
  Erx     : int;
  vA, vB  : alpha;
end;
begin
  vA # '~702.'+CnvAI(aBA1,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(aPos1,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(aPos1>99))+'.K';
  vB # '~702.'+CnvAI(aBA2,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(aPos2,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(aPos2>99))+'.K';
  Erx # TxtDelete(vB, 0);

  if (aCopy) then
    Erx # TxtCopy(vA, vB, 0)
  else
    Erx # TxtRename(vA, vB, 0);

  vA # '~702.'+CnvAI(aBA1,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(aPos1,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(aPos1>99))+'.F';
  vB # '~702.'+CnvAI(aBA2,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(aPos2,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(aPos2>99))+'.F';
  TxtDelete(vB, 0);
  if (aCopy) then
    TxtCopy(vA, vB, 0)
  else
    TxtRename(vA, vB, 0);
end;


//========================================================================
//  Copy706vonBA
//
//========================================================================
SUB Copy706VonBA(
  aVorlageBA  : int;
  aVorlagePos : int) : logic;
local begin
  Erx     : int;
  vBuf702 : int;
end;
begin

   vBuf702 # RecbufCreate(702);

  vBuf702->BAG.P.Nummer    # aVorlageBA;
  vBuf702->BAG.P.Position  # aVorlagePos;
  Erx # RecLink(706,vBuf702,9,_RecFirst);   // Arbeitsschritte loopen
  WHILE (Erx<=_rLocked) do begin
    BAG.AS.Nummer   # BAG.Nummer;
    BAG.AS.Position # BAG.P.Position;
    Erx # RekInsert(706,0,'AUTO');
    if (erx<>_rOK) then begin
      RecBufdestroy(vBuf702);
      RETURN false;
    end;
    BAG.AS.Nummer    # vBuf702->BAG.P.Nummer;
    BAG.AS.Position  # vBuf702->BAG.P.Position;
    RecRead(706,1,0);

    Erx # RecLink(706,vBuf702,9,_RecNext);
  END;
  RecBufdestroy(vBuf702);

  RETURN true;
end;


//========================================================================
// sub ReservierenStattStatus
//        TRUE, wenn Material nur Reserviert ist (z. B. bei Fahren)
//========================================================================
Sub ReservierenStattStatus(
  aAktion : alpha;
  aDatei  : int;) : logic
begin
  if (aDatei=701) then begin
    if (BA1_IO_I_Data:IstMatBeistellung()) then RETURN true;  // 15.11.2021 AH
  end;
  RETURN (aAktion=c_BAG_Fahr09) or (aAktion=c_BAG_Umlager) or (aAktion=c_BAG_Bereit);
end;

//========================================================================
Sub DarfLfsHaben(aAktion : alpha) : logic
begin
  // BAG.P.Aktion
  RETURN (aAktion=c_BAG_Fahr09) or (aAktion=c_BAG_Umlager);
end;

//========================================================================
sub Muss1AutoFertigungHaben() : logic
begin
  RETURN ((BAG.P.Aktion<>c_BAG_ArtPrd) and ("BAG.P.Typ.1In-1OutYN") and
      (((BAG.P.Aktion<>c_BAG_Fahr09) and (BAG.P.Aktion <> c_BAG_Umlager)) or (BAG.P.ZielVerkaufYN=n))) or
      (BAG.P.Aktion=c_BAG_Walz) or (BAG.P.Aktion=c_BAG_WalzSpulen) or
      (BAG.P.Aktion=c_BAG_Versand);
end;

//========================================================================
sub DarfKostenHaben() : logic
begin
  RETURN ((BAG.P.Aktion<>c_BAG_Versand) and (BAG.P.Aktion<>c_BAG_Fahr09) and (BAG.P.Aktion<>c_BAG_Umlager) and (BAG.P.Aktion<>c_BAG_Bereit)) or
      ((Set.BA.LFA.SchrtUmlg) and (BAG.P.Aktion=c_BAG_Fahr09));
end;

//========================================================================
sub DarfSchopfHaben() : logic
begin
  if (Set.Installname='HWN') then begin
    if (BAG.P.Aktion=c_BAG_Saegen) then RETURN false;
  end;
  RETURN (BAG.P.Aktion<>c_BAG_Fahr09) and (BAG.P.Aktion<>c_BAG_Umlager) and (BAG.P.Aktion<>c_BAG_Versand) and (BAG.P.Aktion<>c_BAG_Bereit);
end;

//========================================================================
Sub DarfNur1EinsatzHaben(aAktion : alpha) : logic
begin
  RETURN aAktion=c_BAG_Bereit;
end;


//========================================================================
//  Erzeuge702
//
//========================================================================
SUB Erzeuge702(
  aPos        : int;
  aAG         : alpha;
  aVorlageBA  : int;
  aVorlagePos : int) : logic;
local begin
  Erx : int;
end;
begin

  // neue Pos per AG anlegen...
  if (aVorlageBA=0) then begin
    RecBufClear(702);
    BAG.P.Nummer            # BAG.Nummer;
    BAG.P.Position          # aPos;
    BAG.P.Aktion2           # aAG;
    Erx # RecLink(828,702,8,_recFirst);   // Arbeitsgang holen
    if (Erx>_rLocked) then begin
      RETURN false;
    end;
    BAG.P.ExternYN          # n;
    BAG.P.Reihenfolge       # BAG.P.Position;
    BAG.P.Kosten.Wae        # 1;
    BAG.P.Kosten.PEH        # 1000;
    BAG.P.Kosten.MEH        # 'kg';
    BAG.P.Aktion            # ArG.Aktion;
    BAG.P.Aktion2           # ArG.Aktion2;
    "BAG.P.Typ.1In-1OutYN"  # "ArG.Typ.1In-1OutYN";
    "BAG.P.Typ.1In-yOutYN"  # "ArG.Typ.1In-yOutYN";
    "BAG.P.Typ.xIn-yOutYN"  # "ArG.Typ.xIn-yOutYN";
    "BAG.P.Typ.VSBYN"       # "ArG.Typ.VSBYN";
    BAG.P.Bezeichnung       # ArG.Bezeichnung
  end
  else begin
  // Vorlage BA-Pos kopieren...
    BAG.P.Nummer    # aVorlageBA;
    BAG.P.Position  # aVorlagePos;
    Erx # RecRead(702,1,0);
    if (Erx>_rlocked) then RETURN false;
    BAG.P.Nummer    # BAG.Nummer;
    BAG.P.Position  # aPos;
  end;

  TRANSON;

  Erx # Insert(0,'MAN');
  if (Erx>_rLocked) then begin
    TRANSBRK;
    RETURN false;
  end;

  // ggf. Arbeitsschritte auch kopieren
  if (aVorlageBA<>0) then begin
    if (Copy706vonBA(aVorlageBA, aVorlagePos)=false) then begin
      TRANSBRK;
      RETURN false;
    end;
  end;

  TRANSOFF;
  RETURN true
end;


//========================================================================
//  EinsatzVorhanden
//    Guckt ob es ein Einsatzmaterial zur Position gibt
//    AUSNAHME! Beachtet keine stornieren Verwiegungen
//    MS 18.03.2010
//========================================================================
sub EinsatzVorhanden() : logic;
local begin
  Erx     : int;
  vBuf702 : int;
  vBuf707 : int;
  vOk     : logic;
end;
begin
  vOK # false;

  FOR Erx # RecLink(701, 702, 2, _recFirst); // Einsatz loopen
  LOOP Erx # RecLink(701, 702, 2, _recNext);
  WHILE(Erx <= _rLocked) and (vOK=false) DO BEGIN

    // Weiterberbeitungen als Einsatz? -> sind ok
//    if (BAG.IO.Materialtyp=c_IO_BAG) then CYCLE;

    // Konkrete Fertigungs-Karte?
    if (BAG.IO.Materialtyp=c_IO_Mat) and (BAG.IO.BruderID <> 0) then begin
      FOR Erx # RecLink(707, 701, 18, _recFirst); // FM loopen
      LOOP Erx # RecLink(707, 701, 18, _recNext);
      WHILE(Erx <= _rLocked) and (vOK=false) DO BEGIN
        if(BAG.FM.Status <> c_Status_BAGAusfall) then begin // Verwiegung storniert?
          vOK # true;
          BREAK;
        end;
      END;
    end;
    else begin
      vOK # true;
    end;

  END;

  RETURN vOK;
end;


//========================================================================
//  BereitsVerwiegung
//    Guckt ob auf EINE Position schon verwogen wurde
//    AUSNAHME! Bei VSB wird geguckt ob ein "echter" Einsatz existiert
//    MS 18.03.2010 erstellt
//    MS 14.04.2010 VSB angepasst
//========================================================================
sub BereitsVerwiegung(aBAGAktion : alpha;) : logic;
local begin
  Erx     : int;
  vBuf701 : int;
  vBuf702 : int;
  vBuf707 : int;
  vOk     : logic;
end;
begin
  vOK # false;

  vBuf701 # RekSave(701);
  vBuf702 # RekSave(702);
  vBuf707 # RekSave(707);
  if (aBAGAktion = c_BAG_VSB) then begin
    FOR Erx # RecLink(701, 702, 2, _recFirst); // Input des VSB loopen
    LOOP Erx # RecLink(701, 702, 2, _recNext);
    WHILE(Erx <= _rLocked) DO BEGIN
      if(BAG.IO.BruderID <> 0) then begin // echtes Mat.?
        vOK # true;
        break;
      end;
    END;
  end
  else begin
    FOR Erx # RecLink(707, 702, 5, _recFirst); // Pos -> FM loopen
    LOOP Erx # RecLink(707, 702, 5, _recNext);
    WHILE(Erx <= _rLocked) DO BEGIN
      if(BAG.FM.Status <> c_Status_BAGAusfall) then begin // Verwiegung storniert?
        vOK # true;
        break;
      end;
    END;
  end;

  RekRestore(vBuf701);
  RekRestore(vBuf702);
  RekRestore(vBuf707);

  RETURN vOK;
end;


//========================================================================
//  DelThisVSB
//
//========================================================================
sub DelThisVSB() : logic;
local begin
  Erx     : int;
  vBuf701 : int;
end;
begin
  if (BAG.P.Aktion <> c_BAG_VSB) then RETURN false;

  vBuf701 # RekSave(701);

  TRANSON;

  // Inputs loopen...
  FOR Erx # RecLink(701, 702, 2, _recFirst)
  LOOP Erx # RecLink(701, 702, 2, _recFirst)
  WHILE (Erx = _rOK) DO BEGIN
    if (BA1_IO_I_Data:BereitsVerwogen() = true) then begin
      TRANSBRK;
      RekRestore(vBuf701);
      RETURN false;
    end;

    if(BA1_IO_I_Data:DeleteInput(false) = false) then begin
      TRANSBRK;
      RekRestore(vBuf701);
      RETURN false;
    end;
  END;

  RekRestore(vBuf701);

  //Erx # RekDelete(702, 0, 'MAN'); // Position loeschen, OHNE RSORES

  if (Delete(false)=false) then begin// Position loeschen
  //if(Erx <> _rOK) then begin

    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  12.07.2011 MS
//  call BA1_P_Data:DelPosVSB
//    Löscht alle VSB-Eintraege zu einem Arbeitsgang
//========================================================================
sub DelPosVSB(aBANr : int; aBAPos : int;) : logic;
local begin
  Erx     : int;
  vBuf702 : int;
end;
begin

  if (aBANr=0) or (aBAPos=0) then RETURN false;

  BAG.P.Nummer   #  aBANr;
  BAG.P.Position #  aBAPos;
  Erx # RecRead(702, 1, 0);
  if(Erx > _rLocked) then RETURN false;

  if (BereitsVerwiegung(BAG.P.Aktion) = true) then begin
    Error(702002, '');
    RETURN false;
  end;

  TRANSON;

  //  Output loopen
  FOR Erx # RecLink(701, 702, 3, _recFirst);
  LOOP Erx # RecLink(701, 702, 3, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    vBuf702 # RekSave(702);

    Erx # RecLink(702, 701, 4, _recFirst);
    if(Erx > _rLocked) then
      RecBufClear(702);

    if (BAG.P.Aktion <> c_BAG_VSB) then begin // nur VSB¦s
      RekRestore(vBuf702);
      CYCLE;
    end;

    Erx # RecLinkInfo(701, 702, 2, _recCount); // nur 1 INPUT!
    if(Erx > 1) then begin
      TRANSBRK;
      RETURN false;
    end;

    if(BA1_IO_I_Data:DeleteInput(false) = false) then begin // VSB Einsatz freigeben
      TRANSBRK;
      RETURN false;
    end;

    Erx # RekDelete(702, 0, 'MAN'); // Position loeschen, OHNE RSORES
    if(Erx <> _rOK) then begin
      TRANSBRK;
      RETURN false;
    end;

    RekRestore(vBuf702);
  END;

  TRANSOFF;

  UpdateSort();

  RETURN true;
end;


//========================================================================
//  18.03.2009 MS
//  DelAllVSB
//    Löscht alle VSB-Eintraege eines BAs
//========================================================================
sub DelAllVSB() : logic;
local begin
  Erx     : int;
  vBuf702 : int;
end;
begin

  TRANSON;

  Erx # RecLink(702, 700, 1, _recLast); // Positionen loopen
  WHILE(Erx = _rOK) DO BEGIN

    if (BAG.P.Aktion <> c_BAG_VSB) then begin // nur VSB¦s
      Erx # RecLink(702, 700, 1, _recPrev); // Positionen loopen
      CYCLE;
    end;

    if (BereitsVerwiegung(BAG.P.Aktion) = true) then begin
      TRANSBRK;
      Error(702002, '');
      RETURN false;
    end;

    if (DelThisVSB()=false) then begin
      TRANSBRK;
      RETURN false;
    end;

    Erx # RecLink(702, 700, 1, _recLast); // Positionen loopen
  END;

  TRANSOFF;

  UpdateSort();

  RETURN true;
end;


//========================================================================
//  20.10.2009 MS
//  CheckVSBzuAufREST
//    Guckt ob ein Auftrag nicht überliefert wird
//========================================================================
sub CheckVSBzuAufREST (opt aAll : logic) : logic;
local begin
  Erx     : int;
  vTree               : int;
  vItem               : int;
  vKomAuf             : int;
  vKomPos             : int;
  vKommission         : alpha;
  vVSB_Menge          : float;
  vAUF_Rest           : float;
  vProzUeberliefert   : float;
  vText               : alpha(4000);
  vBuf                : handle;
end;
begin

  vKommission # '';
  vVSB_Menge # 0.0;

  vTree # CteOpen(_cteTreeCI);
  if(aAll = true) then begin // Alle oder nur einen Arbeitsgang VSB melden?
    Erx # RecLink(702,700,1,_RecFirst);   // Arbeitsgänge loopen
    WHILE (Erx <= _rLocked) DO BEGIN

      //  Fertigung loopen
      Erx # RecLink(703,702,4,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        if(BAG.F.Kommission = '') then begin // uninteressant da kein Auftrag
          Erx # RecLink(703,702,4,_recNext);
          CYCLE;
        end;

        Sort_ItemAdd(vTree, StrFmt(BAG.F.Kommission, 21, _StrEnd), 703, RecInfo(703, _recId));

        Erx # RecLink(703,702,4,_recNext);
      END;

      Erx # RecLink(702,700,1,_RecNext);
    END;
  end
  else begin
    //  Fertigung loopen
    Erx # RecLink(703,702,4,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if(BAG.F.Kommission = '') then begin // uninteressant da kein Auftrag
        Erx # RecLink(703,702,4,_recNext);
        CYCLE;
      end;

      Sort_ItemAdd(vTree, StrFmt(BAG.F.Kommission, 21, _StrEnd), 703, RecInfo(703, _recId));

      Erx # RecLink(703,702,4,_recNext);
    END;
  end;

  FOR  vItem # Sort_ItemFirst(vTree);
  loop vItem # Sort_ItemNext(vTree, vItem);
  WHILE (vItem <> 0) DO BEGIN

    RecRead(CnvIA(vItem->spCustom), 0, 0, vItem->spID);

    // Auftrag holen
    Erx # RecLink(401, 703, 9, _recFirst);
    if(Erx > _rLocked) then
      RecBufClear(401);

    if (vKommission <> '') and (vKommission <> BAG.F.Kommission) then begin // Auftrag´s-Rest mit VSB Menge vergleichen
      if (vVSB_Menge > vAUF_Rest) then begin

 //     vProz # Lib_Berechnungen:Prozent(vAUF_Rest, vVSB_Menge);
 // if (vProz>="Set.Ein.WEDelEin%") then begin
        if ((vAuf_Rest / 100.0) <> 0.0) then
          vProzUeberliefert # (vVSB_Menge - vAuf_Rest) / (vAuf_Rest / 100.0);
        if (vProzUeberliefert>="Set.BA.VSBWarntAuf%") then begin
//          vText # vText +'ACHTUNG! Auftrag ' + vKommission + ' hat nun ' + cnvAF(vVSB_Menge) + ' ' + Auf.P.MEH.Wunsch + ' durch Prod. geplant, sollte aber nur ' + cnvAF(vAuf_Rest);
//          vText # vText + ' ' + Auf.P.MEH.Wunsch + ' sein ';
//          if(vProzUeberliefert <> 0.0) then
//            vText # vText + '('+ cnvAF(vProzUeberliefert) + '% überliefert)';
          vBuf # RekSave(703);
//          Msg(99, vText, _WinIcoInformation, _WinDialogOk , 0);
          vText # vKommission+'|'
          vText # vText + ANum(vVSB_Menge,Set.Stellen.Menge)+' '+Auf.P.MEH.Einsatz+'|';
          vText # vText + ANum(vAuf_Rest,Set.Stellen.Menge)+' '+Auf.P.MEH.Einsatz+'|';
          vText # vText + ANum(vProzUeberliefert,2);
          Msg(702028, vText , _WinIcoInformation, _WinDialogOk , 0);
          RekRestore(vBuf);
          vText # '';
          // Auftrag NOCHMAL holen da durch das Oeffnen des MSG-Fensters die Datensaetze verspringen
          Erx # RecLink(401, 703, 9, _recFirst);
          if(Erx > _rLocked) then
            RecBufClear(401);
        end;
      end;
      vVSB_Menge # 0.0;
      vProzUeberliefert # 0.0;
    end;

     // alle Outputs dieser Fertigung loopen
    Erx # RecLink(701,703,4,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.NachBAG=0) and (BAG.IO.NachPosition=0) then begin
//        vVSB_Menge # vVSB_Menge + BAG.IO.PLAN.Out.GewN;   27.05.2013
// 14.08.2013 AH: War alles "wunsch", muss aber "Einsatz" sein
        vVSB_Menge # vVSB_Menge + Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.Out.GewN, BAG.IO.plan.out.Meng, BAG.IO.MEH.Out, Auf.P.MEH.Einsatz);
        end;
      Erx # RecLink(701,703,4,_recNext);
    END;

    vKommission # BAG.F.Kommission;
//    vAUF_Rest   # Auf.P.Prd.Rest.Gew; 27.05.2013
    vAUF_Rest   # Auf.P.Prd.Rest;
  END;


  if (vKommission <> '') and (vKommission = BAG.F.Kommission) then begin // Auftrag´s-Rest mit VSV Menge vergleichen
    if(vVSB_Menge > vAUF_Rest) then begin
      if((vAuf_Rest / 100.0) <> 0.0) then
        vProzUeberliefert # (vVSB_Menge - vAuf_Rest) / (vAuf_Rest / 100.0);
      if (vProzUeberliefert>="Set.BA.VSBWarntAuf%") then begin
        vText # vKommission+'|'
        vText # vText + ANum(vVSB_Menge, Set.Stellen.Menge)+' '+Auf.P.MEH.Einsatz+'|';
        vText # vText + ANum(vAuf_Rest, Set.Stellen.Menge)+' '+Auf.P.MEH.Einsatz+'|';
        vText # vText + ANum(vProzUeberliefert,2);
        Msg(702028, vText , _WinIcoInformation, _WinDialogOk , 0);
      end;
    end;
    vVSB_Menge # 0.0;
    vProzUeberliefert # 0.0;
  end;

  Sort_KillList(vTree);

end;


//========================================================================
//========================================================================
sub ModifyFensterMax() : logic
local begin
  Erx     : int;
  v701      : int;
  v702      : int;
  vDat      : date;
  vTim      : time;
  vTS       : int;
  vNextTim  : time;
  vNextDat  : date;
end;
begin

  v701  # RecBufCreate(701);
  v702  # RecBufCreate(702);

  vDat  # 31.12.2099;
  vTim  # 0:0;

  //  Output der Position loopen...
  FOR Erx # RecLink(v701,702,3,_RecFirst)
  LOOP Erx # RecLink(v701,702,3,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    // nur Vekrettungen
    if (v701->BAG.IO.MaterialTyp<>c_IO_BAG) or
      (v701->BAG.IO.nachBAG=0) or (v701->BAG.IO.nachPosition=0) then
      CYCLE;

    // VSB???
    Erx # RecLink(v702,v701,4,_recFirst);   // Nachfolger Pos. holen
    if (Erx<=_rLocked) and (v702->BAG.P.Aktion=c_Akt_VSB) then begin
      vNextDat # v702->BAG.P.Plan.StartDat;
      vNextTim # v702->BAG.P.Plan.StartZeit;
      if (vNextDat=0.0.0) then begin
        vNextDat #v702->BAG.P.Fenster.MaxDat;
        vNextTim #v702->BAG.P.Fenster.MaxZei;
      end;
      if (vDat<>0.0.0) then begin
        if (vNextDat<vDat) or
          ((vNextDat=vDat) and (vNextTim<vTim)) then begin
          vDat # vNextDat;
          vTim # vNextTim;
        end;
      end;
    end;

  END;

  RecBufDestroy(v701);
  RecBufDestroy(v702);

  if (vDat=31.12.2099) then begin
    vDat  # 0.0.0;
    vTim  # 0:0;
  end;

  // Änderung?
  if (vDat<>BAG.P.Fenster.Maxdat) or (vTim<>BAG.P.Fenster.MaxZei) then begin
    Erx # RecRead(702,1,_recLock);
    vTS # Rso_Rsv_Data:GetTS(vDat, vTim);
    vTS # vTS - cnvif(BAG.P.Plan.DauerPost);
    Rso_Rsv_Data:SetTS(vTS, var vDat, var vTim);
Rso_Rsv_Data:_SchiebeInAZ(BAG.P.Ressource.Grp, var vDat, var vTim,'<');
    BAG.P.Fenster.MaxDat  # vDat;
    BAG.P.Fenster.MaxZei  # vTim;
    Erx # Replace(_recUnlock,'AUTO');
    RETURN true;
//    Rekreplace(702);
  end;

  RETURN false;
end;

/*** 14.02.2022 AH Proj. 2343/14
//========================================================================
//  Auto1zu1
//
//========================================================================
sub altAuto1zu1(
  aAktion     : alpha;
) : logic;
local begin
  Erx       : int;
  vBAG      : int;
  vPos      : int;
  vNeuePos  : int;
  vTerm     : date;
  vMyTrans  : logic;
  vIO       : int;
  vAufNr    : int;
  vAufPos   : int;
  vAufPos2  : int;
  v701      : int;
  v702      : int;
  v703      : int;
end;
begin
  if (BAG.P.Typ.VSBYN) then RETURN true;
  if (BAG.P.Aktion=aAktion) then RETURN true;
//
  vBAG    # BAG.P.Nummer;
  vPos    # BAG.P.Position;

  // Vorgänger max.Termin bestimmen...
  vTerm   # BAG.P.Plan.StartDat;
  if (BAG.P.Plan.EndDat<>0.0.0) then vTerm # BAG.P.Plan.EndDat;

  if (Transactive=n) then begin
    vMyTrans # y;
    TRANSON;
  end;

  v702 # RekSave(702);

  //  Output der Position loopen...
  FOR Erx # RecLink(701,702,3,_RecFirst)
  LOOP Erx # RecLink(701,702,3,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    // Weiterbearbeitete überspringen
    if (BAG.IO.nachBAG <> 0) or (BAG.IO.nachPosition <> 0) then
      CYCLE;
//debugx('process KEY701 aus '+aint(BAG.IO.VonPosition)+'/'+aint(BAG.IO.VonFertigung));
    vIO # BAG.IO.ID;

    Erx # RecLink(703,701,3,_recFirst);   // Abstammungs Fertigung holen
    if (Erx>_rLocked) then RecBufClear(703);

    // 2.7.2013 Schadensbegrenzung bei fälschlich Schopf von CHECK
    if (BAG.F.Auftragsnummer=0) then begin
      BAG.F.Auftragsnummer # BAG.IO.Auftragsnr;
      BAG.F.Auftragspos    # BAG.IO.Auftragspos;
      BAG.F.AuftragsFertig # BAG.IO.Auftragsfert;
    end;

    if (BAG.F.Auftragsnummer=0) then CYCLE;   // NIEMALS ohne Auftrag !!!

    // 1zu1-Position generieren...
    RecBufClear(702);
    BAG.P.Nummer        # vBAG;
    BAG.P.Position      # vPos+1;

    BAG.P.Aktion2           # aAktion; // c_BAG_Versand;
    BAG.P.ZielVerkaufYN     # y;
    BAG.P.Zieladresse       # Set.eigeneAdressnr;   // 2022-11-23 AH : war 1
    BAG.P.Zielanschrift     # 1;
    Erx # RecLink(828,702,8,0); // Arbeitsgang holen
    BAG.P.Aktion  # ArG.Aktion;
    BAG.P.Aktion2 # ArG.Aktion2;
    "BAG.P.Typ.1In-1OutYN" # "ArG.Typ.1In-1OutYN";
    "BAG.P.Typ.1In-yOutYN" # "ArG.Typ.1In-yOutYN";
    "BAG.P.Typ.xIn-yOutYN" # "ArG.Typ.xIn-yOutYN";
    "BAG.P.Typ.VSBYN"      # "ArG.Typ.VSBYN";
    BAG.P.Bezeichnung # ArG.Bezeichnung;
    if ("BAG.P.Typ.1In-1OutYN"=false) then begin
      if (vmyTrans) then begin
        RekRestore(v702);
        TRANSBRK;
        ERROROUTPUT
      end;
      RETURN false;
    end;


    BAG.P.Level         # 1;
    BAG.P.ExternYN      # n;
    BA1_Data:SetStatus(c_BagStatus_Offen);

    RecBufClear(400);
    RecbufClear(401);
    if (BAG.IO.Auftragsnr<>0) and (BAG.F.Auftragsnummer<>0) then begin
      BAG.P.Kommission    # AInt(BAG.IO.Auftragsnr)+'/'+AInt(BAG.IO.Auftragspos);
      if (BAG.IO.AuftragsFert<>0) then
        BAG.P.Kommission # BAG.P.Kommission +'/'+AInt(BAG.IO.AuftragsFert);
      Erx # RecLink(401,701,16,_recFirst);    // Aufpos holen
      if (Erx<=_rLockeD) then begin
        Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
        if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then Erx # _rNoRec;
      end;
      if (Erx<=_rLocked) then begin
        if (Auf.P.TerminZusage<>0.0.0) then
          BAG.P.Fenster.MaxDat  # Auf.P.TerminZusage
        else
          BAG.P.Fenster.MaxDat  # Auf.P.Termin1Wunsch;
      end;
      BAG.P.Plan.StartDat # BAG.P.Fenster.MaxDat;
      BAG.P.Plan.EndDat   # BAG.P.Fenster.MaxDat;
      BAG.P.Auftragsnr    # BAG.IO.Auftragsnr;
      BAG.P.Auftragspos   # BAG.IO.Auftragspos;
      BAG.P.AuftragsPos2  # BAG.IO.AuftragsFert;
      BAG.P.Zieladresse     # Auf.Lieferadresse;
      BAG.P.Zielanschrift   # Auf.Lieferanschrift;
      BAG.P.Zielstichwort   # Auf.KundenStichwort;
    end;

    vAufNr    # BAG.P.Auftragsnr;
    vAufPos   # BAG.P.Auftragspos;
    vAufPos2  # BAG.P.Auftragspos2;
    if (vTerm<>0.0.0) then begin
      BAG.P.Fenster.MinDat  # vTerm;
      if (BAG.P.Plan.StartDat=0.0.0) then begin
        BAG.P.plan.StartDat # vTerm;
        BAG.P.Plan.EndDat   # vTerm;
      end;
    end

    REPEAT
      Erx # Insert(0,'AUTO');
      if (Erx<>_rOK) then BAG.P.Position # BAG.P.Position + 1;
    UNTIL (Erx=_rOK);
    vNeuePos # BAG.P.Position;

  // 1zu1 hat immer eine Fertigung!
    v703 # RekSave(703);
    RecBufClear(703);
    BAG.F.Nummer            # BAG.P.Nummer;
    BAG.F.Position          # BAG.P.Position;
    BAG.F.Fertigung         # 1;
    BAG.F.AutomatischYN     # y;
    "BAG.F.KostenträgerYN"  # y;
    BAG.F.MEH               # 'kg';
    if (ArG.MEH<>'') then BAG.F.MEH # ArG.MEH;
    BAG.F.Streifenanzahl    # 1;
    BAG.F.Artikelnummer     # ''
    BAG.F.Menge             # 0.0;
    Erx # BA1_F_Data:Insert(0,'AUTO');
    Rekrestore(v703);

    // alle Outputs dieser Abstammungs-Fertigung loopen...
    FOR Erx # RecLink(701,703,4,_recFirst)
    LOOP Erx # RecLink(701,703,4,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (BAG.IO.NachBAG=0) and (BAG.IO.NachPosition=0) then begin
        if ((BAG.IO.Auftragsnr=vAufNr) and (BAG.IO.Auftragspos=vAufPos) and (BAG.IO.AuftragsFert=vAufPos2)) then begin
          Erx # RecRead(701,1,_recLock);
          BAG.IO.nachBAG      # vBAG;
          BAG.IO.nachPosition # vNeuePos;
          Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
          if (erx<>_rOK) then begin
            RekRestore(v702);
            if (vmyTrans) then TRANSBRK;
            RETURN false;
          end;

          v701 #  RekSave(701);
          if (BA1_F_Data:UpdateOutput(701,n,n,n,n,y)<>y) then begin
            if (vmyTrans) then begin
              RekRestore(v702);
              TRANSBRK;
              ERROROUTPUT
            end;
            RekRestore(v701);
            RETURN false;
          end;
          RekRestore(v701);

        end;
      end;

    END;

    // Restore Output
    BAG.IO.Nummer # vBAG;
    BAG.IO.ID     # vIO;
    RecRead(701,1,0);

    // Restore Position
    RecBufCopy(v702,702);

  END;  // alle Outputs der Pos.

  if (Lib_misc:ProcessTodos()=false) then begin     // 09.09.2020
    if (vmyTrans) then begin
      TRANSBRK;
      ERROROUTPUT;
    end;
    RETURN false;
  end;


  if (vmyTrans) then TRANSOFF;

  UpdateSort();

  if (vMyTrans) then ErrorOutput;

  BAG.P.Position # vNeuePos;
  RecRead(702,1,0);

  RETURN true;
end;
***/

//========================================================================
//  Auto1zu1
//      muss Vor-Fertigung geladen haben
//========================================================================
sub Auto1zu1(
  aAktion       : alpha;
  opt aOhneVK   : logic;    // Ziel-Verkauf leeren
  opt aOhneAuf  : logic;    // Kommission leeren
) : logic;
local begin
  Erx       : int;
  vBAG      : int;
  vPos      : int;
  vNeuePos  : int;
  vTerm     : date;
  vMyTrans  : logic;
  vIO       : int;
  vAufNr    : int;
  vAufPos   : int;
  vAufPos2  : int;
  v701      : int;
  v702      : int;
  v703      : int;
end;
begin

  if (BAG.P.Typ.VSBYN) then RETURN true;
  if (BAG.P.Aktion=aAktion) then RETURN true;

  vBAG    # BAG.P.Nummer;
  vPos    # BAG.P.Position;

  // Vorgänger max.Termin bestimmen...
  vTerm   # BAG.P.Plan.StartDat;
  if (BAG.P.Plan.EndDat<>0.0.0) then vTerm # BAG.P.Plan.EndDat;

  if (Transactive=n) then begin
    vMyTrans # y;
    TRANSON;
  end;

  v702 # RekSave(702);

  //  Output der FERTIGUNG loopen...
  FOR Erx # RecLink(701,703,4,_RecFirst)
  LOOP Erx # RecLink(701,703,4,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    // Weiterbearbeitete überspringen
    if (BAG.IO.nachBAG <> 0) or (BAG.IO.nachPosition <> 0) then
      CYCLE;
//debugx('process KEY701 aus '+aint(BAG.IO.VonPosition)+'/'+aint(BAG.IO.VonFertigung));
    vIO # BAG.IO.ID;

    // 2.7.2013 Schadensbegrenzung bei fälschlich Schopf von CHECK
    if (BAG.F.Auftragsnummer=0) then begin
      BAG.F.Auftragsnummer # BAG.IO.Auftragsnr;
      BAG.F.Auftragspos    # BAG.IO.Auftragspos;
      BAG.F.AuftragsFertig # BAG.IO.Auftragsfert;
    end;

    // 1zu1-Position generieren...
    RecBufClear(702);
    BAG.P.Nummer        # vBAG;
    BAG.P.Position      # vPos+1;

    BAG.P.Aktion2           # aAktion; // c_BAG_Versand;
    BAG.P.ZielVerkaufYN     # y;
    BAG.P.Zieladresse       # 1;
    BAG.P.Zielanschrift     # 1;

    Erx # RecLink(828,702,8,0); // Arbeitsgang holen
    BAG.P.Aktion  # ArG.Aktion;
    BAG.P.Aktion2 # ArG.Aktion2;
    "BAG.P.Typ.1In-1OutYN" # "ArG.Typ.1In-1OutYN";
    "BAG.P.Typ.1In-yOutYN" # "ArG.Typ.1In-yOutYN";
    "BAG.P.Typ.xIn-yOutYN" # "ArG.Typ.xIn-yOutYN";
    "BAG.P.Typ.VSBYN"      # "ArG.Typ.VSBYN";
    BAG.P.Bezeichnung # ArG.Bezeichnung;
    if ("BAG.P.Typ.1In-1OutYN"=false) then begin
      if (vmyTrans) then begin
        RekRestore(v702);
        TRANSBRK;
        ERROROUTPUT
      end;
      RETURN false;
    end;


    BAG.P.Level         # 1;
    BAG.P.ExternYN      # n;
    BA1_Data:SetStatus(c_BagStatus_Offen);

    RecBufClear(400);
    RecbufClear(401);
    if (BAG.IO.Auftragsnr<>0) and (BAG.F.Auftragsnummer<>0) then begin
      BAG.P.Kommission    # AInt(BAG.IO.Auftragsnr)+'/'+AInt(BAG.IO.Auftragspos);
      if (BAG.IO.AuftragsFert<>0) then
        BAG.P.Kommission # BAG.P.Kommission +'/'+AInt(BAG.IO.AuftragsFert);
      Erx # RecLink(401,701,16,_recFirst);    // Aufpos holen
      if (Erx<=_rLockeD) then begin
        Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
        if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then Erx # _rNoRec;
      end;
      if (Erx<=_rLocked) then begin
        if (Auf.P.TerminZusage<>0.0.0) then
          BAG.P.Fenster.MaxDat  # Auf.P.TerminZusage
        else
          BAG.P.Fenster.MaxDat  # Auf.P.Termin1Wunsch;
      end;
      BAG.P.Plan.StartDat # BAG.P.Fenster.MaxDat;
      BAG.P.Plan.EndDat   # BAG.P.Fenster.MaxDat;
      BAG.P.Auftragsnr    # BAG.IO.Auftragsnr;
      BAG.P.Auftragspos   # BAG.IO.Auftragspos;
      BAG.P.AuftragsPos2  # BAG.IO.AuftragsFert;
      BAG.P.Zieladresse     # Auf.Lieferadresse;
      BAG.P.Zielanschrift   # Auf.Lieferanschrift;
      BAG.P.Zielstichwort   # Auf.KundenStichwort;
    end;

    vAufNr    # BAG.P.Auftragsnr;
    vAufPos   # BAG.P.Auftragspos;
    vAufPos2  # BAG.P.Auftragspos2;
    if (vTerm<>0.0.0) then begin
      BAG.P.Fenster.MinDat  # vTerm;
      if (BAG.P.Plan.StartDat=0.0.0) then begin
        BAG.P.plan.StartDat # vTerm;
        BAG.P.Plan.EndDat   # vTerm;
      end;
    end

    if (aOhneVK) then begin
      BAG.P.ZielVerkaufYN     # n;
      BAG.P.Zieladresse       # 0;
      BAG.P.Zielanschrift     # 0;
      BAG.P.Zielstichwort     # '';
    end;
    if (aOhneAuf) then begin
      BAG.P.Auftragsnr      # 0;
      BAG.P.Auftragspos     # 0;
      BAG.P.AuftragsPos2    # 0;
      BAG.P.Kommission      # '';
      BAG.P.Plan.StartDat   # 0.0.0;
      BAG.P.Plan.EndDat     # 0.0.0;
      BAG.P.Fenster.MaxDat  # 0.0.0;
    end;

    REPEAT
      Erx # Insert(0,'AUTO');
      if (Erx=_rDeadLock) then begin
        if (vmyTrans) then begin
          RekRestore(v702);
          TRANSBRK;
          ERROROUTPUT
        end;
        RekRestore(v702);
        RETURN false;
      end;
      if (Erx<>_rOK) then BAG.P.Position # BAG.P.Position + 1;
    UNTIL (Erx=_rOK);
    vNeuePos # BAG.P.Position;

  // 1zu1 hat immer eine Fertigung!
    v703 # RekSave(703);
    RecBufClear(703);
    BAG.F.Nummer            # BAG.P.Nummer;
    BAG.F.Position          # BAG.P.Position;
    BAG.F.Fertigung         # 1;
    BAG.F.AutomatischYN     # y;
    "BAG.F.KostenträgerYN"  # y;
    "BAG.F.KostenträgerYN"  # y;
//2022-12-19  AH    BAG.F.MEH               # 'kg';
//    if (ArG.MEH<>'') then BAG.F.MEH # ArG.MEH;
    BAG.F.MEH               # '';
    if (ArG.MEH<>'') then BAG.F.MEH # ArG.MEH;
    BAG.F.Streifenanzahl    # 1;
    BAG.F.Artikelnummer     # ''
    BAG.F.Menge             # 0.0;

    // ST 2022-04-26 2343/50: Reservierungswunsch der Vor-Fertigung übernehmen
    if (v703->BAG.F.ReservierenYN) then begin
      BAG.F.ReservierenYN     # true;
      "BAG.F.ReservFürKunde"  # v703->"BAG.F.ReservFürKunde";
    end;
    
    Erx # BA1_F_Data:Insert(0,'AUTO');
    Rekrestore(v703);

    // alle Outputs dieser Abstammungs-Fertigung loopen...
    FOR Erx # RecLink(701,703,4,_recFirst)
    LOOP Erx # RecLink(701,703,4,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (BAG.IO.NachBAG=0) and (BAG.IO.NachPosition=0) then begin
        if ((BAG.IO.Auftragsnr=vAufNr) and (BAG.IO.Auftragspos=vAufPos) and (BAG.IO.AuftragsFert=vAufPos2)) then begin
          Erx # RecRead(701,1,_recLock);
          BAG.IO.nachBAG      # vBAG;
          BAG.IO.nachPosition # vNeuePos;
          Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
          if (erx<>_rOK) then begin
            RekRestore(v702);
            if (vmyTrans) then TRANSBRK;
            RETURN false;
          end;

          v701 #  RekSave(701);
          if (BA1_F_Data:UpdateOutput(701,n,n,n,n,y)<>y) then begin
            if (vmyTrans) then begin
              RekRestore(v702);
              TRANSBRK;
              ERROROUTPUT;
            end;
            RekRestore(v701);
            RETURN false;
          end;
          RekRestore(v701);

        end;
      end;

    END;

    // Restore Output
    BAG.IO.Nummer # vBAG;
    BAG.IO.ID     # vIO;
    RecRead(701,1,0);

    // Restore Position
    RecBufCopy(v702,702);

  END;  // alle Outputs der Pos.

  if (Lib_misc:ProcessTodos()=false) then begin     // 09.09.2020
    if (vmyTrans) then begin
      TRANSBRK;
      ERROROUTPUT;
    end;
    RETURN false;
  end;


  if (vmyTrans) then TRANSOFF;

  UpdateSort();

  if (vMyTrans) then ErrorOutput;

  BAG.P.Position # vNeuePos;
  RecRead(702,1,0);
  

  // 15.02.2022 AH
  Erx # RecLink(701,702,3,_recFirst);     // neuen Output holen

  Erx # RecLink(703,701,3,_recFirst);     // Abstammungs Fertigung holen
  if (Erx>_rLocked) then begin
    Erx # Reclink(703,702,4,_RecFirst);   // sonst 1. Fertigung holen
    if (Erx>_rLocked) then RecbufClear(703);
  end;

  RETURN true;
end;

/**** 14.02.2022 AH Proj. 2343/14
//========================================================================
//  AutoVSB
//
//========================================================================
sub AltAutoVSB(
  opt aMitVersand : logic;
  opt amitVpg     : logic) : logic;
local begin
  Erx       : int;
  vBAG      : int;
  vPos      : int;
  vVSBPos   : int;
  vTerm     : date;
  vMyTrans  : logic;
  vIO       : int;
  vAufNr    : int;
  vAufPos   : int;
  vAufPos2  : int;
  vAnz      : int;
  v702      : int;
  v702First : int;
end;
begin
  if (BAG.P.Typ.VSBYN) then RETURN true;
  
  v702First # RekSave(702);
  if (aMitVpg) then begin     // 26.01.2022 AH z.B. wegen HWE
    if (altAuto1zu1(c_BAG_pack,y)=false) then begin   // 2022-11-23 AH : OHNE Verkauf
      RekRestore(v702First);
      RETURN false;
    end;
  end;
  if (aMitVersand) then begin // 15.11.2021 AH z.B. wegen HWE
    if (altAuto1zu1(c_BAG_Versand)=false) then begin
      RekRestore(v702First);
      RETURN false;
    end;
  end;

  if (RunAFX('BAG.P.AutoVSB','') <> 0) then begin
    RekRestore(v702First);
    RETURN (AfxRes = _rOK);
  end;

  if (BAG.P.Typ.VSBYN) then begin
    RekRestore(v702First);
    RETURN true;
  end;
 
  
  vBAG    # BAG.P.Nummer;
  vPos    # BAG.P.Position;

  // Vorgänger max.Termin bestimmen...
  vTerm   # BAG.P.Plan.StartDat;
  if (BAG.P.Plan.EndDat<>0.0.0) then vTerm # BAG.P.Plan.EndDat;

  if (Transactive=n) then begin
    vMyTrans # y;
    TRANSON;
  end;

  v702 # RekSave(702);

  //  Output der Position loopen...
  FOR Erx # RecLink(701,702,3,_RecFirst)
  LOOP Erx # RecLink(701,702,3,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    // Weiterbearbeitete überspringen
    if (BAG.IO.nachBAG <> 0) or (BAG.IO.nachPosition <> 0) then
      CYCLE;

    vIO # BAG.IO.ID;

    Erx # RecLink(703,701,3,_recFirst);   // Abstammungs Fertigung holen
    if (Erx>_rLocked) then RecBufClear(703);

    // 2.7.2013 Schadensbegrenzung bei fälschlich Schopf von CHECK
    if (BAG.F.Auftragsnummer=0) then begin
      BAG.F.Auftragsnummer # BAG.IO.Auftragsnr;
      BAG.F.Auftragspos    # BAG.IO.Auftragspos;
      BAG.F.AuftragsFertig # BAG.IO.Auftragsfert;
    end;

    // VSB-Position generieren

    RecBufClear(702);
    BAG.P.Nummer        # vBAG;
    BAG.P.Position      # vPos+1;
    BAG.P.Aktion        # c_BAG_VSB;
    BAG.P.Aktion2       # c_BAG_VSB;
    Erx # RecLink(828,702,8,0); // Arbeitsgang holen
    BAG.P.Typ.VSBYN         # "ArG.Typ.VSBYN";
    
    BAG.P.Level         # 1;
    BAG.P.ExternYN      # n;
    BA1_Data:SetStatus(c_BagStatus_Offen);

    RecBufClear(400);
    RecbufClear(401);
    if (BAG.IO.Auftragsnr<>0) and (BAG.F.Auftragsnummer<>0) then begin
      BAG.P.Kommission    # AInt(BAG.IO.Auftragsnr)+'/'+AInt(BAG.IO.Auftragspos);
      if (BAG.IO.AuftragsFert<>0) then
        BAG.P.Kommission # BAG.P.Kommission +'/'+AInt(BAG.IO.AuftragsFert);
      Erx # RecLink(401,701,16,_recFirst);    // Aufpos holen
      if (Erx<=_rLockeD) then begin
        Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
        if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then Erx # _rNoRec;
      end;
      if (Erx<=_rLocked) then begin
        if (Auf.P.TerminZusage<>0.0.0) then
          BAG.P.Fenster.MaxDat  # Auf.P.TerminZusage
        else
          BAG.P.Fenster.MaxDat  # Auf.P.Termin1Wunsch;
      end;
      BAG.P.Plan.StartDat # BAG.P.Fenster.MaxDat;
      BAG.P.Plan.EndDat   # BAG.P.Fenster.MaxDat;
      BAG.P.Auftragsnr    # BAG.IO.Auftragsnr;
      BAG.P.Auftragspos   # BAG.IO.Auftragspos;
      BAG.P.AuftragsPos2  # BAG.IO.AuftragsFert;
    end;


    BAG.P.Bezeichnung   # BAG.P.Aktion+' '+BAG.P.Kommission;
    vAufNr    # BAG.P.Auftragsnr;
    vAufPos   # BAG.P.Auftragspos;
    vAufPos2  # BAG.P.Auftragspos2;
    if (vTerm<>0.0.0) then begin
      BAG.P.Fenster.MinDat  # vTerm;
      if (BAG.P.Plan.StartDat=0.0.0) then begin
        BAG.P.plan.StartDat # vTerm;
        BAG.P.Plan.EndDat   # vTerm;
      end;
    end

    REPEAT
      Erx # Insert(0,'AUTO');
      if (Erx<>_rOK) then BAG.P.Position # BAG.P.Position + 1;
    UNTIL (Erx=_rOK);
    vVSBPos # BAG.P.Position;

    vAnz # 0;
    // alle Outputs dieser Abstammungs-Fertigung loopen...
    FOR Erx # RecLink(701,703,4,_recFirst)
    LOOP Erx # RecLink(701,703,4,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (BAG.IO.NachBAG=0) and (BAG.IO.NachPosition=0) then begin

        if (BAG.IO.Auftragsnr=0) or
          ((BAG.IO.Auftragsnr=vAufNr) and (BAG.IO.Auftragspos=vAufPos) and (BAG.IO.AuftragsFert=vAufPos2)) then begin
          Erx # RecRead(701,1,_recLock);
          BAG.IO.nachBAG      # vBAG;
          BAG.IO.nachPosition # vVSBPos;
          Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
          if (erx<>_rOK) then begin
            RekRestore(v702);
            if (vmyTrans) then TRANSBRK;
            RekRestore(v702First);
            RETURN false;
          end;

          // 05.07.2019 AH: z.B. für Kreditlimit
          inc(vAnz);
          if (RunAFX('BAG.P.AutoVSB.Check',aint(vAnz)+'|'+aint(v702))<>0) then begin
            if (AfxRes<>_rOK) then begin
              RekRestore(v702);
              if (vmyTrans) then TRANSBRK;
              ERROROUTPUT;
              RekRestore(v702First);
              RETURN false;
            end;
          end;

        end;
      end;

    END;

    if (BA1_F_Data:UpdateOutput(702,n,n,n,n,y)<>y) then begin   // 09.09.2020 AH "perTodo"
      if (vmyTrans) then begin
        RekRestore(v702);
        TRANSBRK;
        ERROROUTPUT;  // 01.07.2019
      end;
      RekRestore(v702First);
      RETURN false;
    end;

    // Restore Output
    BAG.IO.Nummer # vBAG;
    BAG.IO.ID     # vIO;
    RecRead(701,1,0);

    // Restore Position
    RecBufCopy(v702,702);

  END;  // alle Outputs der Pos.

  if (Lib_misc:ProcessTodos()=false) then begin     // 09.09.2020
    if (vmyTrans) then begin
      TRANSBRK;
      ERROROUTPUT;
    end;
    RekRestore(v702First);
    RETURN false;
  end;

  if (vmyTrans) then TRANSOFF;

  UpdateSort();

  if (vMyTrans) then ErrorOutput;

  RunAFX('BAG.P.AutoVSB.Post','');
  RekRestore(v702First);

  RETURN true;
end;
***/

//========================================================================
//  AutoVSB
//
//========================================================================
sub AutoVSB(
  opt aMitVersand : logic;
  opt amitVpg     : logic) : logic;
local begin
  Erx       : int;
  vBAG      : int;
  vPos      : int;
  vVSBPos   : int;
  vTerm     : date;
  vMyTrans  : logic;
  vAufNr    : int;
  vAufPos   : int;
  vAufPos2  : int;
  vAnz      : int;
  v702      : int;
  v702First : int;
  v701      : int;
end;
begin
  if (BAG.P.Typ.VSBYN) then RETURN true;
  
  v702First # RekSave(702);
  if (RunAFX('BAG.P.AutoVSB','') <> 0) then begin
    RekRestore(v702First);
    RETURN (AfxRes = _rOK);
  end;
  if (BAG.P.Typ.VSBYN) then begin
    RekRestore(v702First);
    RETURN true;
  end;
 
  
  vBAG    # BAG.P.Nummer;
  vPos    # BAG.P.Position;

  // Vorgänger max.Termin bestimmen...
  vTerm   # BAG.P.Plan.StartDat;
  if (BAG.P.Plan.EndDat<>0.0.0) then vTerm # BAG.P.Plan.EndDat;

  if (Transactive=n) then begin
    vMyTrans # y;
    TRANSON;
  end;

  v702 # RekSave(702);

  //  Output der Position loopen -------------------------------------------------------
  FOR Erx # RecLink(701,702,3,_RecFirst)
  LOOP Erx # RecLink(701,702,3,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    // Weiterbearbeitete überspringen
    if (BAG.IO.nachBAG <> 0) or (BAG.IO.nachPosition <> 0) then
      CYCLE;

    Erx # RecLink(703,701,3,_recFirst);     // Abstammungs Fertigung holen
    if (Erx>_rLocked) then begin
      Erx # Reclink(703,702,4,_RecFirst);   // sonst 1. Fertigung holen
      if (Erx>_rLocked) then RecbufClear(703);
    end;
    
    if (BAG.F.Auftragsnummer=0) then begin
      BAG.F.Auftragsnummer # BAG.IO.Auftragsnr;
      BAG.F.Auftragspos    # BAG.IO.Auftragspos;
      BAG.F.AuftragsFertig # BAG.IO.Auftragsfert;
    end;

    vAufNr    # BAG.F.Auftragsnummer;
    vAufPos   # BAG.F.Auftragspos;
    vAufPos2  # BAG.F.AuftragsFertig;

    v701 # RekSave(701);

    if (aMitVpg) then begin
      if (Auto1zu1(c_BAG_pack)=false) then begin
        if (vmyTrans) then TRANSBRK;
        RekRestore(v701);
        RekRestore(v702First);
        RETURN false;
      end;
    end;
  
    if (aMitVersand) then begin
      if (vAufNr<>0) or (BAG.VorlageYN) then begin
        if (Auto1zu1(c_BAG_Versand)=false) then begin
          if (vmyTrans) then TRANSBRK;
          RekRestore(v701);
          RekRestore(v702First);
          RETURN false;
        end;
      end;
    end;

    Erx # RecLink(703,701,3,_recFirst);     // Abstammungs Fertigung holen
    if (Erx>_rLocked) then begin
      Erx # Reclink(703,702,4,_RecFirst);   // sonst 1. Fertigung holen
      if (Erx>_rLocked) then RecbufClear(703);
    end;

    // VSB-Position NEU generieren
    RecBufClear(702);
    BAG.P.Nummer        # vBAG;
    BAG.P.Position      # vPos+1;
    BAG.P.Aktion        # c_BAG_VSB;
    BAG.P.Aktion2       # c_BAG_VSB;
    Erx # RecLink(828,702,8,0); // Arbeitsgang holen
    BAG.P.Typ.VSBYN         # "ArG.Typ.VSBYN";
    
    BAG.P.Level         # 1;
    BAG.P.ExternYN      # n;
    BA1_Data:SetStatus(c_BagStatus_Offen);

    RecBufClear(400);
    RecbufClear(401);
    if (vAufNr<>0) and (vAufPos<>0) then begin
      BAG.P.Kommission    # AInt(vAufNr)+'/'+AInt(vAufPos);
      if (vAufPos2<>0) then
        BAG.P.Kommission # BAG.P.Kommission +'/'+AInt(vAufPos2);
      Erx # RecLink(401,701,16,_recFirst);    // Aufpos holen
      if (Erx<=_rLockeD) then begin
        Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
        if (Erx<=_rLocked) and (Auf.Vorgangstyp<>c_Auf) then Erx # _rNoRec;
      end;
      if (Erx<=_rLocked) then begin
        if (Auf.P.TerminZusage<>0.0.0) then
          BAG.P.Fenster.MaxDat  # Auf.P.TerminZusage
        else
          BAG.P.Fenster.MaxDat  # Auf.P.Termin1Wunsch;
      end;
      BAG.P.Plan.StartDat # BAG.P.Fenster.MaxDat;
      BAG.P.Plan.EndDat   # BAG.P.Fenster.MaxDat;
      BAG.P.Auftragsnr    # vAufNr;
      BAG.P.Auftragspos   # vAufPos;
      BAG.P.AuftragsPos2  # vAufPos2;
    end;


    BAG.P.Bezeichnung   # BAG.P.Aktion+' '+BAG.P.Kommission;
    if (vTerm<>0.0.0) then begin
      BAG.P.Fenster.MinDat  # vTerm;
      if (BAG.P.Plan.StartDat=0.0.0) then begin
        BAG.P.plan.StartDat # vTerm;
        BAG.P.Plan.EndDat   # vTerm;
      end;
    end

    REPEAT
      Erx # Insert(0,'AUTO');
      if (Erx<>_rOK) then BAG.P.Position # BAG.P.Position + 1;
    UNTIL (Erx=_rOK);
    vVSBPos # BAG.P.Position;
    vAnz # 0;

    // alle Outputs dieser Abstammungs-Fertigung loopen...
    FOR Erx # RecLink(701,703,4,_recFirst)
    LOOP Erx # RecLink(701,703,4,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.NachBAG<>0) or (BAG.IO.NachPosition<>0) then CYCLE;

      if (BAG.IO.Auftragsnr=0) or
        ((BAG.IO.Auftragsnr=vAufNr) and (BAG.IO.Auftragspos=vAufPos) and (BAG.IO.AuftragsFert=vAufPos2)) then begin
        Erx # RecRead(701,1,_recLock);
        BAG.IO.nachBAG      # vBAG;
        BAG.IO.nachPosition # vVSBPos;
        Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
        if (erx<>_rOK) then begin
          RekRestore(v702);
          if (vmyTrans) then TRANSBRK;
          RekRestore(v702First);
          RETURN false;
        end;

        // 05.07.2019 AH: z.B. für Kreditlimit
        inc(vAnz);
        if (RunAFX('BAG.P.AutoVSB.Check',aint(vAnz)+'|'+aint(v702))<>0) then begin
          if (AfxRes<>_rOK) then begin
            RekRestore(v702);
            if (vmyTrans) then TRANSBRK;
            ERROROUTPUT;
            RekRestore(v702First);
            RETURN false;
          end;
        end;

      end;
    END;

    if (BA1_F_Data:UpdateOutput(702,n,n,n,n,y)<>y) then begin
      if (vmyTrans) then begin
        RekRestore(v702);
        TRANSBRK;
        ERROROUTPUT;  // 01.07.2019
      end;
      RekRestore(v702First);
      RETURN false;
    end;

    // Restore Output
    RekRestore(v701);

    // Restore Position
    RecBufCopy(v702,702);

  END;  // alle Outputs der Pos.

  if (Lib_misc:ProcessTodos()=false) then begin     // 09.09.2020
    if (vmyTrans) then begin
      TRANSBRK;
      ERROROUTPUT;
    end;
    RekRestore(v702First);
    RETURN false;
  end;

  if (vmyTrans) then TRANSOFF;

  UpdateSort();

  if (vMyTrans) then ErrorOutput;

  RunAFX('BAG.P.AutoVSB.Post','');
  RekRestore(v702First);

  RETURN true;
end;


//========================================================================
//  Fenster_GetMin
//
//========================================================================
sub Fenster_GetMin(
  var aMinDat   : date;
  var aMinZeit  : time;
  opt aOhneKal  : logic;
);
local begin
  Erx     : int;
  v701      : int;
  v702      : int;
  vDat      : date;
  vZeit     : time;
  vResGrp   : word;
  vDatEnde  : date;
  vTimEnde  : time;
end;
begin
  // frühestes MIN-Fenster suchen über:
  // 1) Vorgänger holen
  // 2) hat EndTermin?
  //    JA -> übernehmen wenn gösserter
  //    NEIN -> hat MINFenster?
  //            JA -> MINFenster um Dauer nach hinten bewegen, übernehmen wenn grösster
//debugx('KEY702');
  v701 # RekSave(701);

  vResGrp   # BAG.P.Ressource.Grp;
  aMinDat   # 0.0.0;
  aMinZeit  # 0:0;
  Erx # RecLink(701,702,2,_recFirst);   // Input loopen
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.Materialtyp=c_IO_BAG) and (BAG.IO.VonBAG<>0) and (BAG.IO.VonPosition<>0) then begin
      v702 # RekSave(702);
      Erx # RecLink(702,701,2,_RecFirst); // Vorgänger holen
      if (Erx<=_rLocked) then begin
        if (BAG.P.Plan.EndDat<>0.0.0) then begin
          vDat  # BAG.P.Plan.EndDat;
          vZeit # BAG.P.Plan.EndZeit;
        end
        else if (BAG.P.Fenster.MinDat<>0.0.0) then begin
          vDat  # BAG.P.Fenster.MinDat;
          vZeit # BAG.P.Fenster.MinZei;
          // 07.06.2018 AH: mit DauerPost
          if (aOhneKal=false) then
            Rso_Kal_Data:GetPlantermin(BAG.P.Ressource.Grp, var vDat, var vZeit, cnvif(BAG.P.Plan.Dauer + BAG.P.Plan.DauerPost), var vDatEnde, var vTimEnde);
        end
        else begin
          vDat  # 0.0.0;
          vZeit # 0:0;
        end;

        // prüfen, ob hier auch wirklich Arbeitszeit ist!
        // Logik: 1 min. vorwärts abfragen
        if (aOhneKal=false) then
          Rso_Kal_Data:GetPlantermin(vResGrp, var vDat, var vZeit, 1, var vDatEnde, var vTimEnde);

        if (vDat>aMinDat) and (vDat<>0.0.0) then begin
          aMinDat  # vDat;
          aMinZeit # vZeit;
        end
        else if (vDat=aMinDat) and (vZeit>aMinZeit) then begin
          aMinZeit # vZeit;
        end;

      end;
      RekRestore(v702);
    end;

    Erx # RecLink(701,702,2,_recNext);
  END;

  RekRestore(v701);
end;


//========================================================================
//  Fenster_GetMax
//
//========================================================================
sub Fenster_GetMax(
  var aMaxDat  : date;
  var aMaxZeit : time
);
local begin
  Erx     : int;
  vBuf702   : int;
  vDat      : date;
  vZeit     : time;
  vResGrp   : word;
  vDatEnde  : date;
  vTimEnde  : time;
end;
begin
  // frühestes MAX-Fenster suchen übeR:
  // 1) Nachfolger holen
  // 2) hat Termin?
  //    JA -> übernehmen wenn kleinster
  //    NEIN -> hat MAXFenster?
  //            JA -> MAXFenster um Dauer nach vorne bewegen, übernehmen wenn kleinster

  vResGrp   # BAG.P.Ressource.Grp;
  aMaxDat   # 31.12.2099;
  aMaxZeit  # 0:0;
  FOR Erx # RecLink(701,702,3,_recFirst)  // Output loopen
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.Materialtyp<>c_IO_BAG) or (BAG.IO.NachBAG=0) or (BAG.IO.NachPosition=0) then CYCLE;

    vBuf702 # RekSave(702);
    Erx # RecLink(702,701,4,_RecFirst); // Nachfolger holen
    if (Erx>_rLocked) then begin
      RekRestore(vBuf702);
      CYCLE;
    end;

    if (BAG.P.Aktion=c_Akt_VSB) then begin
      vDat  # BAG.P.Fenster.MaxDat;
      vZeit # BAG.P.Fenster.MaxZei;
    end
    else begin
      if (BAG.P.Plan.StartDat<>0.0.0) then begin
        vDat  # BAG.P.Plan.StartDat;
        vZeit # BAG.P.Plan.StartZeit;
      end
      else if (BAG.P.Fenster.MaxDat<>0.0.0) then begin
        vDat  # BAG.P.Fenster.MaxDat;
        vZeit # BAG.P.Fenster.MaxZei;
        Rso_Kal_Data:GetPlantermin(BAG.P.Ressource.Grp, var vDat, var vZeit, cnvif((-1.0) * BAG.P.Plan.Dauer), var vDatEnde, var vTimEnde);
      end
      else begin
        vDat  # 0.0.0;
        vZeit # 0:0;
      end;

      // prüfen, ob hier auch wirklich Arbeitszeit ist!
      // Logik: 1 min. rückwärts abfragen und von dem Termin 1h vor
      Rso_Kal_Data:GetPlantermin(vResGrp, var vDat, var vZeit, -1, var vDatEnde, var vTimEnde);
      Lib_Berechnungen:TerminModify(var vDat, var vZeit, 60.0);
    end;

    if (vDat<aMaxDat) and (vDat<>0.0.0) then begin
      aMaxDat  # vDat;
      aMaxZeit # vZeit;
    end
    else if (vDat=aMaxDat) and (vZeit<aMaxZeit) then begin
      aMaxZeit # vZeit;
    end;

    RekRestore(vBuf702);

  END;

end;


//========================================================================
//  UpdateFenster
//
//========================================================================
sub UpdateFenster() : int
local begin
  Erx     : int;
  vBuf702   : int;
  vMaxDat   : date;
  vMaxZeit  : time;
  vMinDat   : date;
  vMinZeit  : time;
end;
begin
//debugx('updatefesnster');
  vBuf702 # RekSave(702);

  // bei NICHT VSB MaxFenster leeren
  Erx # RecLink(702,700,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.Aktion<>c_Akt_VSB) then begin
      Erx # RecRead(702,1,_RecLock);
      if (Erx<>_rOK) then RETURN Erx;
      BAG.P.Fenster.MaxDat # 0.0.0;
      BAG.P.Fenster.MaxZei # 0:0;
      BAG.P.Fenster.MinDat # 0.0.0;
      BAG.P.Fenster.MinZei # 0:0;
      Erx # Replace(_recUnlock,'AUTO');
      if (Erx<>_rOK) then RETURN Erx;
    end;

    Erx # RecLink(702,700,1,_RecNext);
  END;


  // MAX-Fenster berechnen ****************************************************
  Erx # RecLink(702,700,4,_RecLast);    // Posten tiefenmässig RÜCKWÄRTS loopen
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.Fenster.MaxDat<>0.0.0) then begin
      Erx # RecLink(702,700,4,_RecPrev);
      CYCLE;
    end;

    Fenster_GetMax(var vMaxDat, var vMaxZeit);

    // neues MAX-Fenster gefunden??
    if (vMaxDat<>31.12.2099) then begin
      erx # RecRead(702,1,_recLock);
      if (Erx<>_rOK) then RETURN Erx;
      BAG.P.Fenster.MaxDat # vMaxDat;
      BAG.P.Fenster.MaxZei # vMaxZeit;
      Erx # Replace(_recUnlock,'AUTO');
      if (Erx<>_rOK) then RETURN Erx;
    end;

    Erx # RecLink(702,700,4,_RecPrev);
  END;  // Positionen


  // MIN-Fenster berechnen ****************************************************
  Erx # RecLink(702,700,4,_RecFirst);   // Posten tiefenmässig VORWÄRTS loopen
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.Fenster.MinDat<>0.0.0) then begin
      Erx # RecLink(702,700,4,_RecNext);
      CYCLE;
    end;
    Fenster_GetMin(var vMinDat, var vMinZeit);

    // neues MAX-Fenster gefunden??
    if (vMinDat<>0.0.0) then begin
      Erx # RecRead(702,1,_recLock);
      if (Erx<>_rOK) then RETURN Erx;
      BAG.P.Fenster.MinDat # vMinDat;
      BAG.P.Fenster.MinZei # vMinZeit;
      Erx # Replace(_recUnlock,'AUTO');
      if (Erx<>_rOK) then RETURN Erx;
    end;

    Erx # RecLink(702,700,4,_RecNext);
  END;  // Positionen

  RekRestore(vBuf702);

  RETURN _rOK;
end;


//========================================================================
// UpdateMinVSB
//========================================================================
sub UpdateMinVSB()
local begin
  vMinDat   : date;
  vMinZeit  : time;
end;
begin
  Fenster_GetMin(var vMinDat, var vMinZeit, true);
  // neues MIN-Fenster gefunden??
  if (vMinDat<>0.0.0) then begin
    RecRead(702,1,_recLock);
    BAG.P.Fenster.MinDat  # vMinDat;
    BAG.P.Fenster.MinZei  # vMinZeit;
    BAG.P.Plan.StartDat   # vMinDat;
    BAG.P.Plan.StartZeit  # vMinZeit;
    Replace(_recUnlock,'AUTO');
    BA1_F_Data:UpdateVSB(false);
  end;
end;


//========================================================================
//  UpdateFolgendeVSB
//
//========================================================================
sub UpdateFolgendeVSB();
local begin
  Erx     : int;
  v702      : int;
  v702b     : int;
  v701      : int;
end;
begin
//debugx('UpdateFolgendeVSB');
  v702 # RekSave(702);
  v701 # RekSave(701);

  // Outputs loopen...
  FOR Erx # RecLink(701,702,3,_recFirst)
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.NachPosition=0) then CYCLE;
    v702b # RekSave(702);
    Erx # RecLink(702,701,4,_recFirst);   // Nach Position holen
    if (Erx<=_rLocked) and (BAG.P.Typ.VSBYN) then begin
      UpdateMinVSB();
    end;
    RekRestore(v702b);
  END;

  RekRestore(v701);
  RekRestore(v702);
  RETURN;

end;


/***
//========================================================================
//  UpdateSort
//
//========================================================================
sub UpdateSort();
local begin
  vBuf701   : handle;
  vBuf702   : handle;
  vPPos     : Int;
  vBuf      : alpha(4000);
end;
begin
  vBuf701 # RekSave(701);
  vBuf702 # RekSave(702);

  // Alle Posten auf NULL setzen
  FOR Erx # RecLink(702,700,1,_RecFirst)
  LOOP Erx # RecLink(702,700,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    RecRead(702,1,_RecLock);
    BAG.P.Level # 0;
    RekReplace(702,_recUnlock,'AUTO');
  END;


  // Jeden Posten einmal prüfen
  Erx # RecLink(702,700,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (BAG.P.Level=0) then begin
      vPPos # BAG.P.Position;

      RecalcThisLevel(var vBuf);

      BAG.P.Position # vPPos;     // RESTORE
      RecRead(702,1,0);
    end;

    Erx # RecLink(702,700,1,_RecNext);
  END;

  RekRestore(vBuf702);
  RekRestore(vBuf701);
end;
***/

//========================================================================
//  UpdateEinAktion
//
//========================================================================
sub UpdateEinAktion(aDel : logic) : logic;
local begin
  Erx     : int;
  vSumNet   : float;
  vSumBrut  : float;
  vSumStk   : int;
  vSumMenge : float;
end;
begin
  // Einsatz summieren
  FOR Erx # RecLink(701,702,2,_RecFirst)  // Input loopen
  LOOP Erx # RecLink(701,702,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if ("Bag.IO.LöschenYN") then CYCLE;

    // BA offen? -> nur Theorie addieren
    // BA fertig? -> nur echte addieren
    if (BAG.IO.Materialtyp<>c_IO_Mat) then begin
      if ((BAG.P.Fertig.Dat=0.0.0) and (BAG.IO.BruderID<>0)) or
        ((BAG.P.Fertig.Dat<>0.0.0) and (BAG.IO.BruderID=0)) then begin  // Offen?
        CYCLE;
      end;
    end;

    vSumStk   # vSumStk   + BAG.IO.Plan.Out.Stk;
    vSumNet   # vSumNet   + BAG.IO.Plan.Out.GewN;
    vSumBrut  # vSumBrut  + BAG.IO.Plan.Out.GewB;
    if (StrCnv(Auf.P.MEH.Einsatz,_StrUppeR)='KG') then begin
      vSumMenge # vSumMenge + BAG.IO.Plan.Out.GewN
    end
    else if (StrCnv(Auf.P.MEH.Einsatz,_StrUppeR)='T') then begin
      vSumMenge # vSumMenge + (BAG.IO.Plan.Out.GewN / 1000.0);
    end
    else if (StrCnv(Auf.P.MEH.Einsatz,_StrUpper)='STK') then begin
      vSumMenge # vSumMenge + cnvfi(BAG.IO.Plan.Out.Stk);
    end
    else if (Auf.P.MEH.Einsatz=BAG.IO.MEH.Out) then begin
      vSumMenge # vSumMenge + BAG.IO.Plan.Out.Meng;
    end;
  END;


  // Bestellaktion suchen...
  RecBufClear(504);
  Ein.A.Aktionsnr   # BAG.P.Nummer;
  Ein.A.Aktionspos  # BAG.P.Position;
  Ein.A.Aktionstyp  # c_Akt_BA;
  FOR Erx # RecRead(504,2,0)   // Bestellaktion loopen...
  LOOP Erx # RecRead(504,2,_recNext)
  WHILE (Erx<=_rMultikey) and
    (Ein.A.Aktionsnr=BAG.P.Nummer) and
    (Ein.A.Aktionspos=BAG.P.Position) and
    (Ein.A.Aktionstyp=c_Akt_BA) do begin

    if ("Ein.A.Löschmarker"<>'') then CYCLE;

    RecRead(504,1,_recLock);
    Ein.A.Gewicht       # vSumNet;
    "Ein.A.Stückzahl"   # vSumStk;
    Ein.A.Menge         # vSumNet;//vSumMenge;
    Ein.A.MEH           # 'kg';
    RekReplace(504);

    Erx # RekLink(501,504,1,_RecFirst | _recLock);  // Bestell-Position holen
    Ein.P.Gewicht       # Ein.A.Gewicht;
    "Ein.P.Stückzahl"   # "Ein.A.Stückzahl";
    Ein.P.Menge.Wunsch  # Ein.A.Menge;
    Ein.P.Menge         # Ein.A.Menge;
    RekReplace(501);
  END;

  RETURN true;
end;


//========================================================================
//  UpdateAufAktion
//
//========================================================================
sub UpdateAufAktion(aDel : logic) : logic;
local begin
  Erx     : int;
  vBuf401   : int;
  vBuf701   : int;
  vSumNet   : float;
  vSumBrut  : float;
  vSumStk   : int;
  vSumMenge : float;
  vBuf404   : int;
  vBuf703   : int;
  vOK       : logic;
end;
begin

  if (BAG.P.Typ.VSBYN) then RETURN true;            // VSBs sind niemals Lohn

  if (BA1_P_Lib:StatusInAnfrage()) then begin
    if (UpdateEinAktion(aDel)=false) then RETURN false;
  end;

  if (BAG.P.Aktion=c_BAG_Fahr) then RETURN true;    // FAHREN niemals Lohn
  if (BAG.P.Aktion=c_BAG_Fahr09) then RETURN true;  // FAHREN niemals Lohn
  if (BAG.P.Aktion=c_BAG_Bereit) then RETURN true;  // BEREIT niemals Lohn
  if (BAG.P.Aktion=c_BAG_Versand) then RETURN true; // VERSAND niemals Lohn
  if (BAG.P.Auftragsnr = 0) then RETURN true;       // ST 2019-02-25 Bugfix, falls Aufpos mit Nr. 0 existiert!

  vBuf401 # RekSave(401);
  Auf.P.Nummer      # BAG.P.Auftragsnr;
  Auf.P.Position    # BAG.P.Auftragspos;
  Erx # RecRead(401,1,0);       // Auftrag holen
  if (Erx>_rLocked) then begin
    RekRestore(vBuf401);
    RETURN true;
  end;

  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  If (Erx>_rLocked) then begin
    RekRestore(vBuf401);
    RETURN false;
  end;

  Auf.A.Aktionsnr   # BAG.P.Nummer;
  Auf.A.Aktionspos  # BAG.P.Position;
  Auf.A.Aktionspos2 # 0;
  Auf.A.Aktionstyp  # c_Akt_BA;
  Erx # RecRead(404,2,0);
  if (Erx=_rLocked) then begin
    RekRestore(vBuf401);
    RETURN false;
  end;
  if (Erx<=_rMultikey) then begin    // erstmal auf jeden Fall löschen!!!
    if (Auf.A.Rechnungsnr<>0) or ("Auf.A.Löschmarker"='*') then begin
      RekRestore(vBuf401);
      RETURN True;
    end;
    vBuf404 # RekSave(404);
    if (Auf_A_Data:Entfernen()=false) then begin
      RekRestore(vBuf401);
      RekRestore(vBuf404);
      RETURN false;
    end;
  end;

  if (aDel) then begin          // Löschen?
    if (vBuf404<>0) then RekRestore(vBuf404);
    RekRestore(vBuf401);
    RETURN true;
  end;

  vBuf701 # RekSave(701);


  if (AAr.Berechnungsart<>710) then begin
    // Einsatz summieren
    FOR Erx # RecLink(701,702,2,_RecFirst)  // Input loopen
    LOOP Erx # RecLink(701,702,2,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      if ("Bag.IO.LöschenYN") then CYCLE;

      // BA offen? -> nur Theorie addieren
      // BA fertig? -> nur echte addieren
      if (BAG.IO.Materialtyp<>c_IO_Mat) then begin
        if ((BAG.P.Fertig.Dat=0.0.0) and (BAG.IO.BruderID<>0)) or
          ((BAG.P.Fertig.Dat<>0.0.0) and (BAG.IO.BruderID=0)) then begin  // Offen?
          CYCLE;
        end;
      end;

      vSumStk   # vSumStk   + BAG.IO.Plan.Out.Stk;
      vSumNet   # vSumNet   + BAG.IO.Plan.Out.GewN;
      vSumBrut  # vSumBrut  + BAG.IO.Plan.Out.GewB;
      if (StrCnv(Auf.P.MEH.Einsatz,_StrUppeR)='KG') then begin
        vSumMenge # vSumMenge + BAG.IO.Plan.Out.GewN
      end
      else if (StrCnv(Auf.P.MEH.Einsatz,_StrUppeR)='T') then begin
        vSumMenge # vSumMenge + (BAG.IO.Plan.Out.GewN / 1000.0);
      end
      else if (StrCnv(Auf.P.MEH.Einsatz,_StrUpper)='STK') then begin
        vSumMenge # vSumMenge + cnvfi(BAG.IO.Plan.Out.Stk);
      end
      else if (Auf.P.MEH.Einsatz=BAG.IO.MEH.Out) then begin
        vSumMenge # vSumMenge + BAG.IO.Plan.Out.Meng;
      end;
    END;
  end
  else begin    // OUTPUT als Berechnungsart....

    vBuf703 # RecBufCreate(703);

    // OUTPUT summieren...
    FOR Erx # RecLink(701,702,3,_RecFirst)  // Output loopen
    LOOP Erx # RecLink(701,702,3,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      // BA offen? -> nur Theorie addieren
      if (BAG.P.Fertig.Dat=0.0.0) then begin
        if (BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;
      end
      else begin
        // BA fertig? -> nur echte addieren
        if (BAG.IO.Materialtyp<>c_IO_Mat) then CYCLE;
      end;

      // gpelanten SChrott überspringen
      Erx # RecLink(vBuf703,701,3,_recFirst);   // AusFertigung holen
      if (vBuf703->BAG.F.PlanSchrottYN) then CYCLE;

      // ST 2013-08-23: Umstellung auf ggf. Stücklistenkommission in Bag.F.Kommission
      if (Lib_Strings:Strings_Count(vBuf703->BAG.F.Kommission, '/')  > 1) then
        vBuf703->BAG.F.Kommission # Str_Token(vBuf703->BAG.F.Kommission,'/',1) + '/' +
                                    Str_Token(vBuf703->BAG.F.Kommission,'/',2);

      // 04.06.2013:
      if (vBuf703->BAG.F.Kommission<>BAG.P.Kommission) then CYCLE;


      vSumStk   # vSumStk   + BAG.IO.Plan.IN.Stk;
      vSumNet   # vSumNet   + BAG.IO.Plan.IN.GewN;
      vSumBrut  # vSumBrut  + BAG.IO.Plan.IN.GewB;
      if (StrCnv(Auf.P.MEH.Einsatz,_StrUppeR)='KG') then begin
        vSumMenge # vSumMenge + BAG.IO.Plan.IN.GewN
      end
      else if (StrCnv(Auf.P.MEH.Einsatz,_StrUppeR)='T') then begin
        vSumMenge # vSumMenge + (BAG.IO.Plan.IN.GewN / 1000.0);
      end
      else if (StrCnv(Auf.P.MEH.Einsatz,_StrUpper)='STK') then begin
        vSumMenge # vSumMenge + cnvfi(BAG.IO.Plan.IN.Stk);
      end
      else if (Auf.P.MEH.Einsatz=BAG.IO.MEH.IN) then begin
        vSumMenge # vSumMenge + BAG.IO.Plan.IN.Menge;
      end;

    END;
    RecBufDestroy(vBuf703);
  end; // ...Output addieren


  RekRestore(vBuf701);


  RecBufClear(404);             // Aktion neu anlegen
  Auf.A.Aktionsnr     # BAG.P.Nummer;
  Auf.A.Aktionspos    # BAG.P.Position;
  Auf.A.Aktionspos2   # 0;
  Auf.A.Aktionstyp    # c_Akt_BA;
  Auf.A.Nummer        # BAG.P.Auftragsnr;
  Auf.A.Position      # BAG.P.Auftragspos;
  Erx # RekLink(401,702,16,_recFirst);  // Auftragspos. holen 15.05.2014 AH

  Auf.A.Aktionsdatum  # BAG.P.Fertig.Dat;
  Auf.A.TerminStart   # BAG.P.Plan.StartDat
  Auf.A.TerminEnde    # BAG.P.Plan.EndDat;
  if (BAG.P.Fertig.Dat<>0.0.0) then
    Auf.A.TerminEnde    # BAG.P.Fertig.Dat;

  "Auf.A.Stückzahl"   # vSumStk;
  Auf.A.Gewicht       # vSumBrut;
  Auf.A.NettoGewicht  # vSumNet;
  Auf.A.Menge         # vSumMenge;
  Auf.A.MEH           # Auf.P.MEH.Einsatz;
  Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
//  Auf.A.Bemerkung     # c_AktBem_BA;
  Auf.A.Bemerkung     # BAG.P.Bezeichnung;

  // BA-Kosten mit in die Aktionsliste schreiben 03.09.2012 AI
  if (BAG.P.ExternYN) then begin
    Auf.A.interneKostW1   # 0.0;
    Auf.A.EKpreisSummeW1  # BAG.P.Kosten.Gesamt;
  end
  else begin
    Auf.A.interneKostW1   # BAG.P.Kosten.Gesamt;
    Auf.A.EKpreisSummeW1  # 0.0;
  end;


  RunAFX('BAG.Set.Auf.Aktion','');

  // neuen Eintagn anlegen...
  if (vBuf404=0) then begin
    vOK #  Auf_A_Data:NeuAnlegen(y)=_rOK;
    RekRestore(vBuf401);
    RETURN vOK;
  end;

  // Eintrag schon vorhand? -> Anlegen + Refresh
  Auf.A.Aktion # vBuf404->Auf.A.Aktion;
  if (Auf_A_Data:NeuAnlegen(y)<>_rOK) then begin
    RekRestore(vBuf401);
    RecBufDestroy(vBuf404);
    RETURN false;
  end;
  RecRead(404,1,_recLock);
  Auf.A.Anlage.Datum  # vBuf404->Auf.A.Anlage.Datum;
  Auf.A.Anlage.Zeit   # vBuf404->Auf.A.Anlage.Zeit;
  Auf.A.Anlage.User   # vBuf404->Auf.A.Anlage.User;
  RekReplace(404,_recUnlock,'AUTO');
  RecBufDestroy(vBuf404);

  RekRestore(vBuf401);

  RETURN true;
end;


//========================================================================
//  _ErzeugeBAGausLFS    +ERR
//
//========================================================================
sub _ErzeugeBAGausLFS(
  aBANr       : int;
  aBAPos      : int;
  opt aNoUpd  : logic;    // 14.02.2020 AH: weiter NICHT Updaten, wenn z.B. aus LFA-Erfassung noch weiter Positionen kommen (sonst würde der LFS zig mal refreshed)
  ) : logic
local begin
  Erx       : int;
  vNeuesMat : int;
  vID       : int;
end;
begin
  // Einsatzmaterial anlegen **************************
  Erx # RecLink(701,700,3,_recLast);
  if (Erx>_rLocked) then vID # 0
  else vID # BAG.IO.ID;

  RecBufClear(701);
  BAG.IO.Nummer         # BAG.Nummer;
  BAG.IO.NachBAG        # BAG.Nummer;
  //BAG.IO.NachPosition   # 1;
  BAG.IO.NachPosition   # aBAPos;
  BAG.IO.NachFertigung  # Lfs.P.Position;

  BAG.IO.ID # vID;
  REPEAT
    BAG.IO.ID # BAG.IO.ID + 1;
    Erx # RecRead(701,1,_recTest);
  UNTIL (Erx<>_rOK);

  // ECHTES MATERIAL ??? -----------------------------------------------
  If (Lfs.P.Materialtyp=c_IO_MAT) then begin // Material?
    Mat.Nummer # Lfs.P.Materialnr;
    Erx # RecRead(200,1,0);
    if (Erx>_rLocked) then begin
      BAG.Nummer    # aBANr;
      BAG.P.Nummer  # aBANr;
      Error(010001,AInt(lfs.p.position)+'|'+AInt(Lfs.P.Materialnr));
      RETURN false;
    end;

    vNeuesMat # Mat.Nummer;

    // Verwieungsart beachten
    BAG.IO.Materialnr     # Mat.Nummer;
    BAG.IO.Dicke          # Mat.Dicke;
    BAG.IO.Breite         # Mat.Breite;
    BAG.IO.Spulbreite     # Mat.Spulbreite;
    "BAG.IO.Länge"        # "Mat.Länge";
    BAG.IO.Dickentol      # Mat.Dickentol;
    BAG.IO.Breitentol     # Mat.Breitentol;
    "BAG.IO.Längentol"    # "Mat.Längentol";
    BAG.IO.AusfOben       # "Mat.AusführungOben";
    BAG.IO.AusfUnten      # "Mat.AusführungUnten";
    "BAG.IO.Güte"         # "Mat.Güte";

// 16.05.2014
//    BAG.IO.MEH.In         # Lfs.P.MEH;
//    BAG.IO.MEH.Out        # Lfs.P.MEH;
    BAG.IO.MEH.In         # Lfs.P.MEH.Einsatz;
    BAG.IO.MEH.Out        # BAG.IO.MEH.IN;

    BAG.IO.Plan.Out.Stk   # "Lfs.P.Stück";
    BAG.IO.Plan.Out.GewN  # Lfs.P.Gewicht.Netto;
    BAG.IO.Plan.Out.GewB  # Lfs.P.Gewicht.Brutto;
// 16.05.2014
//    BAG.IO.Plan.Out.Meng  # Lfs.P.Menge;
    BAG.IO.Plan.Out.Meng  # Lfs.P.Menge.Einsatz;
    BAG.IO.Plan.In.Stk    # Mat.Bestand.Stk;
    BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;
    BAG.IO.Plan.In.GewB   # Mat.Gewicht.Brutto;
    BAG.IO.Plan.In.Menge  # BAG.IO.Plan.Out.Meng;
    if (BAG.IO.MEH.In='kg') then
      BAG.IO.Plan.In.Menge  # Mat.Bestand.Gew;

    // 22.05.2014: Ist = Plan setzen
    BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
    BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
    BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
    BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;

    BAG.IO.Warengruppe    # Mat.Warengruppe;
    BAG.IO.Lageradresse   # Mat.LAgeradresse;//Lfs.P.Art.Adresse;
    BAG.IO.Lageranschr    # Mat.Lageranschrift;//Lfs.P.Art.Anschrift;
    BAG.IO.Materialtyp    # Lfs.P.Materialtyp;
    BAG.IO.VonBAG         # 0;
    BAG.IO.VonPosition    # 0;
    BAG.IO.VonFertigung   # 0;
    BAG.IO.VonID          # 0;

    // Material auf diesen neuen Einsatz hin anpassen
    if (BA1_Mat_Data:MatEinsetzen()=false) then begin
      BAG.Nummer    # aBANr;
      BAG.P.Nummer  # aBaNr;
      Error(010007,AInt(lfs.p.position)+'|'+AInt(Lfs.P.Materialnr));
      RETURN false;
    end;
  end   // Material

  // VSB-MATERIAL ??? --------------------------------------------------
  else If (Lfs.P.Materialtyp=c_IO_VSB) then begin // VSB-Material?
    Mat.Nummer # Lfs.P.Materialnr;
    Erx # RecRead(200,1,0);
    if (Erx>_rLocked) then begin
      BAG.Nummer    # aBaNr;
      BAG.P.Nummer  # aBaNr;
      Error(010001,AInt(lfs.p.position)+'|'+AInt(Lfs.P.Materialnr));
      RETURN false;
    end;

    // Verwieungsart beachten
    BAG.IO.Materialnr     # Mat.Nummer;
    BAG.IO.Dicke          # Mat.Dicke;
    BAG.IO.Breite         # Mat.Breite;
    BAG.IO.Spulbreite     # Mat.Spulbreite;
    "BAG.IO.Länge"        # "Mat.Länge";
    BAG.IO.Dickentol      # Mat.Dickentol;
    BAG.IO.Breitentol     # Mat.Breitentol;
    "BAG.IO.Längentol"    # "Mat.Längentol";
    BAG.IO.AusfOben       # "Mat.AusführungOben";
    BAG.IO.AusfUnten      # "Mat.AusführungUnten";
    "BAG.IO.Güte"         # "Mat.Güte";
    BAG.IO.Plan.In.Stk    # "Lfs.P.Stück";
    BAG.IO.Plan.In.GewN   # Lfs.P.Gewicht.Netto;
    BAG.IO.Plan.In.GewB   # Lfs.P.Gewicht.Brutto;
    // 16.05.2014
//    BAG.IO.MEH.In         # Lfs.P.MEH;
    BAG.IO.MEH.In         # Lfs.P.MEH.Einsatz;
    BAG.IO.MEH.Out        # BAG.IO.MEH.In;;
//    BAG.IO.Plan.In.Menge  # Lfs.P.Menge;
    BAG.IO.Plan.In.Menge  # Lfs.P.Menge.Einsatz;

    BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
    BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
    BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
    BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.In.Menge;
    BAG.IO.Warengruppe    # Mat.Warengruppe;
    BAG.IO.Lageradresse   # Mat.LAgeradresse;//Lfs.P.Art.Adresse;
    BAG.IO.Lageranschr    # Mat.Lageranschrift;//Lfs.P.Art.Anschrift;
    BAG.IO.Materialtyp    # Lfs.P.Materialtyp;
    BAG.IO.VonBAG         # 0;
    BAG.IO.VonPosition    # 0;
    BAG.IO.VonFertigung   # 0;
    BAG.IO.VonID          # 0;

    // Material auf diesen neuen Einsatz hin anpassen
    if (BA1_Mat_Data:VSBEinsetzen()=false) then begin
      BAG.Nummer    # aBANr;
      BAG.P.Nummer  # aBANr;
      Error(010007,AInt(lfs.p.position)+'|'+AInt(Lfs.P.Materialnr));
      RETURN false;
    end;

  end  // VSB-Material

  // ARTIKEL ??? --------------------------------------------------------
  else if (Lfs.P.Materialtyp=c_IO_ART) then begin // Artikel?
    Erx # RecLink(250,441,3,_recFirst); // Artikel holen
    if (Erx>_rLocked) then begin
      BAG.Nummer    # aBANr;
      BAG.P.Nummer  # aBANr;
      Error(010001,AInt(lfs.p.position)+'|'+Lfs.P.Artikelnr);
      RETURN false;
    end;

    BAG.IO.Artikelnr      # Lfs.P.Artikelnr;
    BAG.IO.Lageradresse   # Lfs.P.Art.Adresse;
    BAG.IO.Lageranschr    # Lfs.P.Art.Anschrift;
    BAG.IO.Charge         # LFs.P.Art.Charge;

    BAG.IO.Plan.In.Stk    # "Lfs.P.Stück";
    BAG.IO.Plan.In.GewN   # Lfs.P.Gewicht.Netto;
    BAG.IO.Plan.In.GewB   # Lfs.P.Gewicht.Brutto;

    BAG.IO.MEH.In         # Lfs.P.MEH.Einsatz;
    BAG.IO.Plan.In.Menge  # Lfs.P.Menge.Einsatz;

// LFA-Update
//      BAG.IO.MEH.Out        # Lfs.P.MEH;
//      BAG.IO.Plan.Out.Meng  # Lfs.P.Menge;
    BAG.IO.MEH.Out        # Lfs.P.MEH.Einsatz;
    BAG.IO.Plan.Out.Meng  # Lfs.P.Menge.Einsatz;

    BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
    BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
    BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
    BAG.IO.Warengruppe    # Art.Warengruppe;
    BAG.IO.Materialtyp    # Lfs.P.Materialtyp;
    BAG.IO.VonBAG         # 0;
    BAG.IO.VonPosition    # 0;
    BAG.IO.VonFertigung   # 0;
    BAG.IO.VonID          # 0;
  end   // Artikel

  // VERPACKUNG ??? -------------------------------------------------------- 14.02.2020
  else if (Lfs.P.Materialtyp=c_IO_VPG) then begin // Verpackung?
    Erx # RecLink(250,441,3,_recFirst); // Artikel holen
    if (Erx>_rLocked) then begin
      BAG.Nummer    # aBANr;
      BAG.P.Nummer  # aBANr;
      Error(010001,AInt(lfs.p.position)+'|'+Lfs.P.Artikelnr);
      RETURN false;
    end;

    BAG.IO.Artikelnr      # Lfs.P.Artikelnr;
    BAG.IO.Lageradresse   # Lfs.P.Art.Adresse;
    BAG.IO.Lageranschr    # Lfs.P.Art.Anschrift;
    BAG.IO.Charge         # LFs.P.Art.Charge;

    BAG.IO.Plan.In.Stk    # "Lfs.P.Stück";
    BAG.IO.Plan.In.GewN   # Lfs.P.Gewicht.Netto;
    BAG.IO.Plan.In.GewB   # Lfs.P.Gewicht.Brutto;
    BAG.IO.MEH.In         # Lfs.P.MEH.Einsatz;
    BAG.IO.Plan.In.Menge  # Lfs.P.Menge.Einsatz;
    BAG.IO.MEH.Out        # Lfs.P.MEH.Einsatz;
    BAG.IO.Plan.Out.Meng  # Lfs.P.Menge.Einsatz;
    BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
    BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
    BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
    BAG.IO.Warengruppe    # Art.Warengruppe;
    BAG.IO.Materialtyp    # c_IO_Beistell;// Lfs.P.Materialtyp;
    BAG.IO.VonBAG         # 0;
    BAG.IO.VonPosition    # 0;
    BAG.IO.VonFertigung   # 0;
    BAG.IO.VonID          # 0;
  end;  // Verpackung


  // ID vergeben
  // 06.11.2014 AH
  BAG.IO.UrsprungsID    # BAG.IO.ID;
  BAG.IO.Anlage.Datum   # Today;
  BAG.IO.Anlage.Zeit    # Now;
  BAG.IO.Anlage.User    # gUserName;
  Erx # BA1_IO_Data:Insert(0,'MAN');
  if (Erx<>_rOk) then begin
    BAG.Nummer    # aBANr;
    BAG.P.Nummer  # aBANr;
    Error(0,'Input nicht speicherbar');
    RETURN false;
  end;
/** Prüfung schon "oben" wegen Übergabe als Träger an MatReservierung !!!
  BAG.IO.ID # vID + 1;//0;//Lfs.P.Position;
  REPEAT
    BAG.IO.ID # BAG.IO.ID + 1; //Lfs.P.Position;
    BAG.IO.UrsprungsID    # BAG.IO.ID;
    BAG.IO.Anlage.Datum   # Today;
    BAG.IO.Anlage.Zeit    # Now;
    BAG.IO.Anlage.User    # gUserName;
    Erx # BA1_IO_Data:Insert(0,'MAN');
//    if (Erx<>_rOk) then begin
//      BAG.Nummer    # vAlteNr;
//      BAG.P.Nummer  # vAlteNr;
//      RETURN '90';
//    end;
  UNTIL (Erx=_rOK);
***/

  // ggf. vorhandene Reservierungen mindern...
  if (Lfs.P.Auftragsnr<>0) then begin
    BA1_Mat_Data:MinderReservierung(Lfs.P.Auftragsnr, Lfs.P.AuftragsPos, 0, BAG.IO.Plan.In.Stk, BAG.IO.PLan.In.GewN);
  end;


  // Fertigung anlegen bzw. anpassen ************
  // 11.2.2011
/***/
  Erx # RecLink(703,701,10,_RecFirst);    // nach fertigung holen
  if (Erx<=_rLocked) then begin
    recread(703,1,_recLock);
    "BAG.F.KostenträgerYN"  # y;
    BAG.F.ReservierenYN     # y;
    BAG.F.Auftragsnummer    # Lfs.P.Auftragsnr;
    BAG.F.Auftragspos       # Lfs.P.Auftragspos;
    BAG.F.AuftragsFertig    # Lfs.P.Auftragspos2;
    BAG.F.Kommission        # Lfs.P.Kommission;
    "BAG.F.ReservFürKunde"  # Lfs.P.Kundennummer;
/**
    "BAG.F.Stückzahl"       # BAG.IO.Plan.Out.Stk;
    BAG.F.Gewicht           # BAG.IO.Plan.Out.GewN;
    BAG.F.Menge             # BAG.IO.Plan.Out.Meng;
    BAG.F.MEH               # BAG.IO.MEH.Out;
    BAG.F.Artikelnummer     # BAG.IO.Artikelnr;
    BAG.F.Warengruppe       # BAG.IO.Warengruppe;
**/
    Erx # BA1_F_Data:Replace(0,'AUTO');
  end
  else begin
//todo('aaa ba1_p_data');
end;
/***/
/***
if (1=2) then begin
  RecBufClear(703);
  BAG.F.Nummer            # BAG.Nummer;
  BAG.F.Position          # BAG.P.Position;
  BAG.F.Fertigung         # BAG.IO.nachFertigung;
  "BAG.F.KostenträgerYN"  # y;
  BAG.F.ReservierenYN     # y;
  BAG.F.Auftragsnummer    # Lfs.P.Auftragsnr;
  BAG.F.Auftragspos       # Lfs.P.Auftragspos;
  BAG.F.AuftragsFertig    # Lfs.P.Auftragspos2;
  BAG.F.Kommission        # Lfs.P.Kommission;
  "BAG.F.ReservFürKunde"  # Lfs.P.Kundennummer;
  "BAG.F.Stückzahl"       # BAG.IO.Plan.Out.Stk;
  BAG.F.Gewicht           # BAG.IO.Plan.Out.GewN;
  BAG.F.Menge             # BAG.IO.Plan.Out.Meng;
  BAG.F.MEH               # BAG.IO.MEH.Out;
  BAG.F.Artikelnummer     # BAG.IO.Artikelnr;
  BAG.F.Warengruppe       # BAG.IO.Warengruppe;

  BAG.F.Anlage.Datum   # Today;
  BAG.F.Anlage.Zeit    # Now;
  BAG.F.Anlage.User    # gUserName;
//debug('isnert:'+aint(bag.f.nummer)+'/'+aint(bag.f.position)+'/'+aint(bag.f.fertigung));
  Erx # BA1_F_Data:Insert(0,'MAN');
  if (Erx<>_rOk) then begin
    BAG.Nummer    # aBANr;
    BAG.P.Nummer  # aBANr;
    Error(010033,AInt(BAG.F.Nummer));
    RETURN false;
  end;
end;
***/
  Erx # RekDelete(441,0,'MAN'); // LFS-Position entfernen

  // Output aktualisieren ****************
  if (BA1_F_Data:UpdateOutput(701,n,n,n,aNoUpd)=false) then begin
    BAG.Nummer    # aBANr;
    BAG.P.Nummer  # aBANr;
    Error(010034,AInt(BAG.F.Nummer));
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  ErzeugeBAGausLFS    +ERR
//
//========================================================================
sub ErzeugeBAGausLFS() : logic
local begin
  Erx     : int;
  vBANr     : int;
  vAlteNr   : int;
  vBAPos    : int;

  vNeuesMat : int;
  vRestMat  : int;
end;
begin
  vAlteNr # BAG.P.Nummer;
  vBAPos  # BAG.P.Position;
  if (vBAPos=0) then vBAPos # 1;

  vBANr # Lib_Nummern:ReadNummer('Betriebsauftrag');
  if (vBANr<>0) then Lib_Nummern:SaveNummer()
  else begin
    Error(019999,'BA-Nummer nicht bestimmbar!');
    RETURN false;
  end;

  // BA-Kopf anlegen *************************
  RecBufClear(700);
  BAG.BuchungsAlgoNr  # Set.BA.BuchungAlgoNr;
  BAG.Nummer          # vBANr;
  BAG.Bemerkung       # c_AktBem_BA_Fahr;
  BAG.Anlage.Datum    # Today;
  BAG.Anlage.Zeit     # Now;
  BAG.Anlage.User     # gUserName;
  Erx # RekInsert(700,0,'AUTO');
  if (Erx<>_rOk) then begin
    BAG.Nummer    # vAlteNr;
    BAG.P.Nummer  # vAlteNr;
    Error(019999,'BA-Kopf nicht speicherbar!');
    RETURN false;
  end;


  // Position anlegen *************************
  // ist durch Maske vorbelegt
  BA1_Data:SetStatus(c_BagStatus_Offen);
  BAG.P.Nummer    # BAG.Nummer;
  Erx # Insert(0,'AUTO');
  if (Erx<>_rOk) then begin
    BAG.Nummer    # vAlteNr;
    BAG.P.Nummer  # vAlteNr;
    Error(019999,'BA-Pos. nicht speicherbar!');
    RETURN false;
  end;


  RecBufClear(440);
  Lfs.Nummer # myTmpNummer;
  Erx # RecLink(441,440,4,_RecFirst);
  WHILE (Erx<=_rLocked) do begin  // Positionen loopen
    // übernimmt und LÖSCHT 441
    // 14.02.2020 AH: bei MEHREREN Positionen nicht immer LFS refreshen !!!
//    if (_ErzeugeBAGausLFS(vAlteNr, vBAPos, false)=false) then begin
    if (_ErzeugeBAGausLFS(vAlteNr, vBAPos, (RecLinkInfo(441,440,4,_RecCount)>=2) )=false) then begin
      RETURN false;
    end;

//    Erx # RecLink(441,440,4,_RecNext);
    Lfs.Nummer # myTmpNummer;
    Erx # RecLink(441,440,4,_RecFirst);
  END;  // LFS-Pos


  // automatischer Abschluss eintragen
  if (AutoVSB()=false) then begin
    BAG.Nummer    # vAlteNr;
    BAG.P.Nummer  # vAlteNr;

    Error(010034,AInt(BAG.P.Nummer));
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  ErrechnePlanmengen
//
//========================================================================
sub ErrechnePlanmengen(opt aFahrTausch : logic);
local begin
  Erx     : int;
  vBuf701 : int;
  vBuf703 : int;
end;
begin

  vBuf701 # RekSave(701);
  vBuf703 # RekSave(703);

  // Einsatzmengen addieren
  case BAG.P.Aktion of
    c_BAG_abcoil  : BA1_F_Data:SumInput('qm');
    c_BAG_Tafel   : BA1_F_Data:SumInput('qm');
    c_BAG_ablaeng : BA1_F_Data:SumInput('m');
    c_BAG_Schael  : BA1_F_Data:SumInput(ArG.MEH);
    otherwise       BA1_F_Data:SumInput('kg');
  end;

  // Fertigungen loopen
  Erx # RecLink(703,702,4,_recFirst);
  WHILE (Erx<_rLocked) do begin
    BA1_F_Data:ErrechnePlanmengen(y,y,y);
    RecRead(703,1,_recLock | _RecNoLoad);

    // 17.10.2018 AH:
//debugx('KEY701 '+aint(BAG.IO.Auftragsnr));
    if (aFahrTausch) then begin
      BAG.F.Auftragsnummer  # BAG.IO.Auftragsnr;
      BAG.F.Auftragspos     # BAG.IO.Auftragspos;
      BAG.F.AuftragsFertig  # BAG.IO.Auftragsfert;
      BAG.F.Kommission      # '';   // 21.01.2022 AH
      if (BAG.F.Auftragsnummer<>0) then
      BAG.F.Kommission      # aint(BAG.F.Auftragsnummer)+'/'+aint(BAG.F.Auftragspos);
    end;

    Erx # BA1_F_Data:Replace(_recUnlock,'AUTO');
    Erx # RecLink(703,702,4,_recNext);
  END;

  RekRestore(vBuf701);
  RekRestore(vBuf703);
end;


/*** WOFÜR??? AI 2.2.2012 ***/
//========================================================================
//  ErrechnePosRek
//
//========================================================================
sub ErrechnePosRek();
local begin
  Erx     : int;
  vBuf701   : int;
  vBuf702   : int;
  vBuf703   : int;
end;
begin

  Erx # RecLink(701,702,3,_recFirst);   // Output loopen
  WHILE (Erx<=_rLocked) do begin

    vBuf701 # RekSave(701);
    vBuf702 # RekSave(702);
    vBuf703 # RekSave(703);

    RekRestore(vBuf701);
    RekRestore(vBuf702);
    RekRestore(vBuf703);

    Erx # RecLink(701,702,3,_recNext);
  END;

/***
  Erx # RecLink(703,702,4,_RecFirst); // Fertigungen loopen
  WHILE (Erx<=_rLockeD) do begin

    RecRead(703,1,_recLock);
    "BAG.F.Stückzahl" # 0;

    // ST 2011-03-31
    if (BAG.P.Aktion=c_BAG_Spalt) then
      "BAG.F.Gewicht" # 0.0;

//    Erx # RecLink(701,702,3,_recFirst); // Output loopen
    Erx # RecLink(701,703,4,_recFirst); // Output loopen
    WHILE (Erx<=_rLocked) do begin

      if (BAG.IO.Materialtyp<>c_IO_BAG) then begin
        Erx # RecLink(701,703,4,_recNext);
        CYCLE;
      end;

      "BAG.F.Stückzahl" # "BAG.F.Stückzahl" + BAG.IO.Plan.In.Stk;

      // ST 2011-03-31
      if (BAG.P.Aktion=c_BAG_Spalt) then
        "BAG.F.Gewicht" # "BAG.F.Gewicht" + BAG.IO.Plan.In.Menge;

      Erx # RecLink(701,703,4,_recNext);
    END;
    Erx # BA1_F_Data:Replace(_recUnlock,'AUTO');

    Erx # RecLink(703,702,4,_recNext)
  END;  // Fertigungen
***/

end;


//========================================================================
//  Delete  +Err
//
//========================================================================
sub Delete(aCheckFertigung : logic) : logic;
local begin
  Erx     : int;
  vName : alpha;
end;
begin
  // Ressourcen löschen
  Erx # RecLink(706,702,9,_RecFirst);
  WHILE (Erx=_rOK) do begin
    Erx # RekDelete(706,0,'MAN');
    if (erx<>_rOK) then begin
      Error(001000+Erx,Translate('Ressourcen'));
      RETURN false;
    end;
    Erx # RecLink(706,702,9,_RecFirst);
  END;

  // Zeiten löschen
  Erx # RecLink(709,702,6,_RecFirst);
  WHILE (Erx=_rOK) do begin
    Erx # RekDelete(709,0,'MAN');
    if (erx<>_rOK) then begin
      Error(001000+Erx,Translate('Zeiten'));
      RETURN false;
    end;
    Erx # RecLink(709,702,6,_RecFirst);
  END;

  // ggf. Lohnarbeitsgang am Auftrag löschen
  if (UpdateAufAktion(y)=false) then begin
    RETURN false;
  end;

  // Fertigungen löschen
  Erx # RecLink(703,702,4,_RecFirst);
  WHILE (Erx<=_rLocked) and (aCheckFertigung) do begin

    // Ausführungen löschen
    Erx # RecLink(705,703,8,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RekDelete(705,0,'MAN');
      if (erx<>_rOK) then begin
        RETURN false;
      end;
      Erx # RecLink(705,703,8,_recFirst);
    END;

    Erx # RekDelete(703,0,'MAN');
    if (erx<>_rOK) then begin
      RETURN false;
    end;
    Erx # RecLink(703,702,4,_RecFirst);
  END;


  // Outputs löschen (zur Sicherheit z.B: bei BSP "hingen" da einige falsche Pack-Outputs) 30.09.2019
  FOR Erx # RecLink(701,702,3,_RecFirst)
  LOOP Erx # RecLink(701,702,3,_RecFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(701);
    if (Erx<>_rOK) then begin
      RETURN false;
    end;
  END;

  // Fahren?? ggf. LFS löschen
  if (DarfLfsHaben(BAG.P.Aktion)) then begin
    FOR Erx # RecLink(440,702,14,_recFirst)     // Lfs loopen
    LOOP Erx # RecLink(440,702,14,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if ("Lfs.Löschmarker"='*') then CYCLE;
      // DOCH NOCH Positionen da?
      if (RecLinkInfo(441,440,4,_RecCount)>0) then RETURN false;
      RecRead(440,1,_recLock);
      "Lfs.Löschmarker" # '*';
      Lfs.zuBA.Nummer   # 0;
      Lfs.zuBA.Position # 0;
      Erx # RekReplace(440,_recUnlock,'MAN');
      if (erx<>_rOK) then RETURN false;
    END;
  end;


  // Position löschen
  Erx # RekDelete(702,0,'MAN');
  if (Erx<>_rOK) then begin
    Error(001000+Erx,Translate('Position'));
    RETURN false;
  end;

  Rso_Rsv_Data:Delete702();
  Erx # _rOK;


  // Texte löschen
  vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.K';
  TxtDelete(vName,0)
  vName # '~702.'+CnvAI(BAG.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(BAG.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,2+cnvil(BAG.P.Position>99))+'.F';
  TxtDelete(vName,0)
  
  if (RunAFX('BAG.P.Data.Operation','DEL') <> 0) then begin
    ERx# AfxRes;
  end;

  RETURN true;
end;


//========================================================================
//  RestorePos    +ERR
//
//========================================================================
sub RestorePos(
  opt aSilent   : logic;
  opt aRek      : logic;
  opt aStornoFM : logic) : logic;
local begin
  Erx           : int;
  vStk          : int;
  vM            : float;
  vOK           : logic;
  vDatum        : date;
  v702          : int;
  v701          : int;
  vAbschlussDat : date;
  vSilent       : logic;
end;
begin
  if (BAG.P.Aktion=c_BAG_Fahr09) then   RETURN false;
  if (BAG.P.Aktion=c_BAG_Bereit) then   RETURN false;
  if (BAG.P.Aktion=c_BAG_VSB) then      RETURN false;
  if (BAG.P.Aktion=c_BAG_Versand) then  RETURN false;

  vDatum  # today;
  vSilent # aSilent;

  v702 # RekSave(702);

  // Nachfolge Pos auf Abschluss prüfen
  FOR Erx # RecLink(701,702,3,_recFirst)  // Output loopen
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.NachPosition=0) then CYCLE;
    Erx # RecLink(702, 701, 4,_recFirst);   // Nach-Pos holen
    if (Erx>_rLocked) then begin
      RecbufCopy(v702,702);
      CYCLE;
    end;

    if ("BAG.P.Löschmarker"<>'*') or (BAG.P.Typ.VSBYN) then begin
      RecbufCopy(v702,702);
      CYCLE;
    end;
    
    if (Set.Wie.BaRestore='S') then begin  // 25.10.2021 AH
      if (vSilent=false) then begin
        vSilent   # true;
        aStornoFM # false;
        if (Msg(702051,'',_WinIcoQuestion,_windialogyesno,1)=_winidyes) then begin
          aRek      # true;
          aStornoFM # true;
        end
        else if (Msg(702052,'',_WinIcoQuestion,_windialogyesno,1)=_winidyes) then begin
          aRek      # true;
        end
      end;
    end
    else begin
      aRek # false;
    end;
    
    if (aRek) then begin
      v701 # RekSave(701);
      if (RestorePos(true, true, aStornoFM)=false) then begin
        RekRestore(v702);
        RekRestore(v701);
        RETURN false;
      end;
      RekRestore(v701);
    end
    else begin
      Error(702038,aint(BAG.P.Position));
      RekRestore(v702);
      RETURN false;
    end;
    RecbufCopy(v702,702);
  END;
  RekRestore(v702);
  
  vAbschlussDat # BAG.P.Fertig.Dat;

  if (Lib_Faktura:Abschlusstest(vAbschlussDat) = false) then begin
    Error(001400 ,Translate('Betriebsauftragsabschlussdatum') + '|'+ CnvAd(vAbschlussDat));
    RETURN false;
  end;

  APPOFF();

  TRANSON;

  RecRead(702,1,_recLock);
  "BAG.P.Löschmarker" # '';
  BAG.P.Fertig.Dat    # 0.0.0;
  BA1_Data:SetStatus(c_BagStatus_Offen);
  Replace(_RecUnlock,'AUTO');

  // Kosten entfernen -------------------------------------------
  if (BA1_Kosten:UpdatePosition(BAG.P.Nummer, BAG.P.Position, false, false, true)=false) then begin
    TRANSBRK
    APPON();
    Error(702032,'');
    RETURN false;
  end;

  // Auftragsaktionen reaktivieren -------------------------------
  UpdateAufAktion(n);

  // INPUT LOOPEN.*************************************************
  Erx # recLink(701,702,2,_RecFirst);   // Input loopen
  WHILE (Erx<=_rLocked) do begin

    // Besteillartikel wieder zubuchen ------------------------------
    if (BAG.IO.MaterialTyp=c_IO_Beistell) then begin
      Erx # RecLink(250,701,8,_recFirst);     // Artikel holen
      if (Erx<=_rLocked) then begin
        Erx # RecLink(252,701,17,_recFirst);  // Charge holen
        if (Erx<=_rLocked) then begin

          // Bewegung buchen...
          RecBufClear(253);
          Art.J.Datum           # today;
          Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
          "Art.J.Stückzahl"     # BAG.IO.PLan.In.Stk;
          Art.J.Menge           # BAG.IO.Plan.In.Menge;
          "Art.J.Trägertyp"     # c_Akt_BA;
          "Art.J.Trägernummer1" # BAG.P.Nummer;
          "Art.J.Trägernummer2" # BAG.P.Position;
          "Art.J.Trägernummer3" # 0;
          vOK # Art_Data:Bewegung(0.0, 0.0);
          if (vOK=false) then begin
            APPON();
            TRANSBRK;
            Error(702012,aint(__LINE__));
            RETURN false;
          end;
        end;
      end;
    end;

    // Artikel reservieren...
    if ((BAG.IO.MaterialTyp=c_IO_Art) and (BAG.IO.VonBAG=0)) or
      (BAG.IO.MaterialTyp=c_IO_Beistell) then begin
      Erx # RecLink(250,701,8,_recFirst); // Artikel holen
      if (Erx<=_rLocked) then begin
        if (BA1_Art_Data:ArtEinsetzen()=false) then begin
          APPON();
          TRANSBRK;
          Error(702012,aint(__LINE__));
          RETURN false;
        end;
      end;
    end;


    // echtes Material? --------------------------------------------------
    if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
//      Erx # RecLink(200,701,11,_recFirst);    // Restkarte holen
      Erx # Mat_Data:Read(BAG.IO.MaterialRstNr,0,0,true); // 27.04.2015
      if (Erx<200) then begin
        APPON();
        TRANSBRK;
        Error(99,'karte '+aint(BAG.IO.MaterialRstNr)+' nicht im Bestand!');
        RETURN false;
      end;

      RecRead(200,1,_recLock);
      // 26.01.2022 AH: ggf. wieder Kommission eintragen (wurde beim Löschen ja geleert) Proj. 2343/12
      if (BAG.IO.Auftragsnr<>0) then begin
        Mat.Auftragsnr  # BAG.IO.Auftragsnr;
        Mat.Auftragspos # BAG.IO.Auftragspos;
      end;
      Mat_Data:SetLoeschmarker('');
      Mat.Ausgangsdatum # 0.0.0;
      // 21.07.2014 AH:
//      Mat_Data:SetStatus(c_Status_BAGverschnitt); // auf "in BAG" setzen
      Mat_Data:SetStatus(BA1_Mat_Data:StatusLautEinsatz(BAG.P.Aktion,BAG.P.Auftragsnr));

      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
      if (erx<>_rOK) then begin
        APPON();
        TRANSBRK;
        Error(702012,'908');
        RETURN false;
      end;


      if (Mat.Bestand.Gew>0.0) then begin
        // Schrottartikel ggf. buchen...
        Erx # RekLink(819,200,1,_recFirst);   // Warengruppe holen
        RunAFX('BAG.FM.FindSchrottArtikel','');
        if (Wgr.Schrottartikel<>'') then begin
          Erx # RecLink(250,819,2,_recFirst); // Artikel holen
          if (Erx>_rLocked) then begin
            APPON();
            TRANSBRK;
            Error(702040,Wgr.Schrottartikel);
            RETURN false;
          end;


          vStk # Mat.Bestand.Stk;
          if (vStk=0) then vStk # 1;
          vM # Lib_Einheiten:WandleMEH(250, Mat.Bestand.Stk, Mat.Bestand.Gew, 0.0, '', Art.MEH);

          // 30.11.2012 AI:
          Erx # RekLink(252,701,17,_recfirst);    // Schrottcharge holen
          if (Erx>_rLocked) then begin            // ALTE BAS haben das nicht -> Journalsuche
            RecBufClear(253);
            Art.J.Artikelnr # Art.Nummer;
            Art.J.Datum     # vAbschlussDat;
            Erx # RecRead(253,2,0);
            WHILE (Erx<=_rNokey) and (Art.J.Artikelnr=Art.Nummer) and
                  (Art.J.Datum=vAbschlussDat) do begin
                  if (Art.J.Bemerkung =c_Akt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position)) then begin
                    Art.C.Charge.Intern # Art.J.Charge;
//                    vM                  # Art.J.Menge;
//                    vStk                # "Art.J.Stückzahl";
                    BREAK;
                  end;
              Erx # RecRead(253,2,_recnext);
            END;
//            if (Art.C.Charge.Intern='') then begin
//              TRANSBRK;
//              Error(702040,'');
//              RETURN false;
//            end;
          end
          else begin
//            vM    # Art.C.Bestand;
//            vStk  # Art.C.Bestand.Stk;
          end;


          if (Art.C.Charge.Intern<>'') then begin
            // Bewegung buchen...
            RecBufClear(253);
            Art.J.Datum           # vDatum;
            Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
            "Art.J.Stückzahl"     # -vStk;
            Art.J.Menge           # -vM;
            "Art.J.Trägertyp"     # c_Akt_BA;
            "Art.J.Trägernummer1" # BAG.P.Nummer;
            "Art.J.Trägernummer2" # BAG.P.Position;
            "Art.J.Trägernummer3" # 0;
            vOK # Art_Data:Bewegung(0.0, 0.0, 0, true);
            if (vOK=false) then begin
              APPON();
              TRANSBRK;
              Error(702012,'1188');
              RETURN false;
            end;
          end;
        end;    // Schrottartikel
      end;    // Menge>0

    end; // echtes Material


    Erx # RecLink(701,702,2,_RecNext);
  END;  // Input



  v702 # RekSave(702);
  Erx # RecLink(701,702,3,_recFirst);       // OUTPUT loopen
  WHILE (Erx<=_rLocked) do begin

    // nur Weiterbearbeitungen prüfen
    if (BAG.IO.MaterialTyp=c_IO_BAG) then begin
      Erx # RecLink(702,701,4,_recFirst);   // Nachfolger holen

      if (BAG.P.Typ.VSBYN) or (BAG.P.Aktion=c_BAG_Versand) then begin
        Auf.P.Nummer      # BAG.P.Auftragsnr;
        Auf.P.Position    # BAG.P.Auftragspos;
        Erx # RecRead(401,1,0);       // Auftrag holen
        if (Erx<=_rLocked) then begin
          Auf.A.Aktionsnr   # BAG.IO.VonBAG;
          Auf.A.Aktionspos  # BAG.IO.VonPosition;
          Auf.A.Aktionspos2 # BAG.IO.ID;
          Auf.A.Aktionstyp  # c_Akt_BA_Plan;

          Erx # RecRead(404,2,0);
          if (Erx>_rMultikey) then begin  // NICHT GEFUNDEN??? -> weitermachen...
//            TRANSBRK;
//            Error(010038,cnvai(BAG.IO.VonBAG)+'/'+cnvai(BAG.IO.VonPosition));
//            RETURN false;
          end
          else begin
            if (Auf_A_Data:ToggleLoeschmarker()=false) then begin
              APPON();
              TRANSBRK;
              RekRestore(v702);
              Error(010039,AInt(BAG.IO.VonBAG)+'/'+AInt(BAG.IO.VonPosition)+'|'+AInt(Auf.A.Nummer)+'/'+AInt(auf.A.Position)+'/'+AInt(Auf.a.Aktion));
              RETURN false;
            end;
          end;

        end;
      end; // ist VSB/Versand

      RecBufCopy(v702,702);

    end; // Weiterbearbeitung

    Erx # RecLink(701,702,3,_recNext);
  END;
  RecBufDestroy(v702);

  if (BAG.P.Aktion=c_BAG_MatPrd) then begin
    if (BA1_FM_MatPrd_Data:RestorePos()=false) then begin
      APPON();
      TRANSBRK;
      ErrorOutput;
      RETURN false;
    end;
  end;



  // BA-Kopf reaktivieren....
  RecRead(700,1,_recLock);
  "BAG.Löschmarker" # '';
  "BAG.Lösch.Datum" # 0.0.0;
  "BAG.Lösch.Zeit"  # 0:0;
  "BAG.Lösch.User"  # '';
  BAG.Fertig.Datum  # 0.0.0;
  BAG.Fertig.Zeit   # 0:0;
  BAG.Fertig.User   # '';
  RekReplace(700,_RecUnlock,'AUTO');
  BA1_Data:SetVsbMarker("BAG.Löschmarker");      // 25.03.2021 AH

  APPON();

  TRANSOFF;

  // 25.10.2021 AH
  if (aStornoFM) then begin
    vOK # BA1_FM_Data:AlleDerPosEntfernen();
    if (vOK=false) then begin
//      TRANSBRK;
//      RETURN false;
    end;
  end;

  if (aSilent=false) then
    Error(999998,'');
    
  RETURN true;
end;


//========================================================================
//  ErmittleMEH
//
//========================================================================
sub ErmittleMEH() : alpha;
local begin
  Erx     : int;
  vGvAlpha : alpha(250);
end;
begin

  Erx # RekLink(828,702,8,_recFirst);   // Arbeitsgang holen
  if (Erx>_rLocked) or (ArG.MEH='') then begin
    if (BAG.P.Aktion=c_BAG_Tafel) or (BAG.P.Aktion=c_BAG_ABCOIL) then
      RETURN 'qm'
    else if (BAG.P.Aktion=c_BAG_abLaeng) or (BAG.P.Aktion=c_BAG_Saegen) then
      RETURN 'm'

    RETURN 'kg';
  end;

  RETURN ArG.MEH;
end;


//========================================================================
//  SindVorgaengerAbgeschlossen
//
//========================================================================
sub SindVorgaengerAbgeschlossen(
  var aOffeneVorFahren      : int;
  opt aSchliesseVorFahren   : logic;
  opt aAbschlussVorFahren   : date;
  opt aAutoVorgaengerTheoFM : int)      // -1 = NEIN, 0=Frage, 1=ohne Frage
  : logic;
/***
local begin
  vBuf701   : int;
  vBuf702   : int;
  vBuf702B  : int;
  vOK       : logic;
end;
begin

  // --------------------------------
  // Vorgängercheck
  // Sind alle Vorgänger schon fertig?

  vBuf702 # RekSave(702);
  vBuf701   # RecBufCreate(701);
  vBuf702B  # RecBufCreate(702);

  // alle "Inputs" duchgehen um herauszufinden ob der Arbeitsgang Vorgänger hat
  vOK # true;
  FOR Erx # RecLink(vBuf701,702,2,_recFirst)
  LOOP Erx # RecLink(vBuf701,702,2,_RecNext)
  WHILE (Erx <= _rLocked) and (vOK) DO BEGIN

    // Einsätze ohne vorherige Position sind IO
    if (vBuf701->BAG.IO.VonPosition = 0) then CYCLE;

    // Einsätze von mir selber (LFA) ignorieren
    if (vBuf701->BAG.IO.VonPosition = vBuf701->BAG.IO.NachPosition) then CYCLE;

    // Position lesen
    Erx # RecLink(vBuf702B,vBuf701,2,0);
    if (Erx > _rLocked) then begin
      vOk # false;
      BREAK;
    end;

    // Prüfen ob noch nicht fertiggemeldet?
    if (vBuf702B->BAG.P.Fertig.Dat=0.0.0) then begin // Alte Version

      vOk # false;
      BREAK;
    end;

  END;

  RecBufDestroy(vBuf701);
  RecBufDestroy(vBuf702B);
  RekRestore(vBuf702);

  RETURN vOK;
end;
***/
local begin
  Erx     : int;
  vOK   : logic;
  v701  : int;
  v702  : int;
end;
begin
  v701 # RekSave(701);
  v702 # RekSave(702);
  // alle "Inputs" duchgehen um herauszufinden ob der Arbeitsgang Vorgänger hat
  vOK # true;
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_RecNext)
  WHILE (Erx <= _rLocked) and (vOK) DO BEGIN

    // Einsätze ohne vorherige Position sind IO
    if (BAG.IO.VonPosition = 0) then CYCLE;

    // Einsätze von mir selber (LFA) ignorieren
    if (BAG.IO.VonPosition = BAG.IO.NachPosition) then CYCLE;

    // VOR-Position lesen
    Erx # RecLink(702, 701,2,0);
    if (Erx > _rLocked) then begin
      vOk # false;
      BREAK;
    end;

    // Prüfen ob noch nicht fertiggemeldet?
    if (BAG.P.Fertig.Dat=0.0.0) then begin // Alte Version
    
      // ST 2022-01-18 2222/106: Neue Abfrage bringt bei Brockhaus den BAG Fortschritt durcheinander
      if (Set.Installname = 'BSP') then
        aAutoVorgaengerTHeoFM # -1;
        
    
      if (aAutoVorgaengerTHeoFM=0) then begin
        //if (Msg(99,'Vorgängerpos. '+aint(BAG.P.Position)+' theofm?',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes) then begin
        if (Msg(702049,aint(BAG.P.Nummer),_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes) then
          aAutoVorgaengerTheoFM # 1
        else
          aAutoVorgaengerTheoFM # -1;
      end;
      
      if (aAutoVorgaengerTheoFM>0) then begin
          if (BA1_FM_Theo_subs:FMTheorie(BAG.P.Nummer, BAG.P.Position, today,y,n,n,0, aAutoVorgaengertheoFM)=true) then begin
            RecBufCopy(v702, 702);
            CYCLE;
          end;
//        end;
      end;
    
      vOk # false;
      if (BAG.P.Aktion<>c_BAG_Fahr09) then BREAK;
      vOK # true;
      inc(aOffeneVorFahren);
 //     if (aAbschlussVorFahren<>0.0.0) then begin
      if (aSchliesseVorFahren) then begin
        Erx # RecLink(440,702,14,_recFirst);    // LFS holen
        if (Erx<=_rLocked) then begin
          if (aAbschlussVorFahren=0.0.0) then begin
            FOR Erx # RecLink(441,440,4,_recFirst)  // Positionen loopen
            LOOP Erx # RecLink(441,440,4,_recNext)
            WHILE (Erx<=_rLocked) do begin
              if (Lfs.P.Datum.Verbucht>aAbschlussVorFahren) then
                aAbschlussVorFahren # Lfs.P.Datum.Verbucht;
            END;
            if (aAbschlussVorFahren=0.0.0) then
              aAbschlussVorFahren # today;
          end;
          if (Lfs_LFA_Data:Abschluss(aAbschlussVorFahren, true)=false) then begin
            ErrorOutput;
            vOK # false;
            BREAK;
          end;
        end;
      end;
    end;

    RecBufCopy(v702, 702);
  END;

  RekRestore(v701);
  RekRestore(v702);

  RETURN vOK;
end;


//========================================================================
// Merge  +ERR
//    - NUR FÜR SPALTEN + DIVERS !!!!
//    - Einsatz 1: Theo oder Mat, Einsatz 2: Theo
//    - addiert bei 2 Theos die Theomeengen und Breiten (d.h. NUR EIN EINSATZ)
//    - fügt Fertigungen zusammen
//    - Biegt Pfade an
//
//========================================================================
sub Merge(
  aBAG      : int;
  aPos1     : int;  // ZIEL
  aPos2     : int;  // VON
) : logic;
local begin
  Erx       : int;
  vTxt      : int;
  v702a     : int;
  v702b     : int;
  vF,vI,vJ  : int;
  vA        : alpha;
  v701b     : int;
  vIdA      : int;
  vIdB      : int;
  vCTa      : caltime;
  vCTb      : caltime;
  v1HatMat  : logic;
end;
begin

  if (aPos1=aPos2) then begin
    Error(700117,''); // todox('gleiche Positionen');
    RETURN false;
  end;

  APPOFF();

  v702a # RecBufCreate(702);
  v702b # RecBufCreate(702);

  v702a->BAG.P.Nummer    # aBAG;
  v702a->BAG.P.Position  # aPos1;
  Erx # RecRead(v702a,1,0);
  if (Erx>_rLocked) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);

    Error(700100,cnvai(aBAG)+'/'+cnvai(aPos1)); // todox('A nicht gefunden');
    RETURN false;
  end;
  v702b->BAG.P.Nummer    # aBAG;
  v702b->BAG.P.Position  # aPos2;
  Erx # RecRead(v702b,1,0);
  if (Erx>_rLocked) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700101,cnvai(aBAG)+'/'+cnvai(aPos2)); // todox('B nicht gefunden');
    RETURN false;
  end;


  // Prüfungen -------------------------------------------------
   if (v702a->BAG.P.Aktion<>v702b->BAG.P.Aktion) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700104,''); // todox('ungleich');
    RETURN false;
  end;
  if (v702a->BAG.P.Aktion<>c_BAG_Spalt) and        // or -> and ST 2019-12-03 Projekt 2042/11
    (v702a->BAG.P.Aktion<>c_BAG_Divers) then begin      // BISHER NUR SPALTEN ODER DIVER
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);

    Error(700118,''); // todox('falscher Aktionstyp');
    RETURN false;
  end;
  if (RecLinkInfo(707,v702a,5,_reccount)>0) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700105,''); // todox('A schon verwogen');
    RETURN false;
  end;
  if (RecLinkInfo(707,v702b,5,_reccount)>0) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700106,''); // todox('B schon verwogen');
    RETURN false;
  end;

  if (RecLinkInfo(701,v702b,2,_reccount)<>1) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700119,''); // todox('B falsche Input-Zahl');
    RETURN false;
  end;
  if (RecLinkInfo(701,v702a,2,_reccount)<>1) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700119,''); // todox('A falsche Input-Zahl');
    RETURN false;
  end;

  Erx # RecLink(701,v702b,2,_recFirst);   // Input holen
  if (BAG.IO.MaterialTyp<>c_IO_Theo) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700119,''); // todox('B falsche Input-Typ');
    RETURN false;
  end;
  vIdB # BAG.IO.Id;
  v701b # RekSave(701);

  Erx # RecLink(701,v702a,2,_recFirst);   // Input holen
  if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
    v1HatMat # true;
  end
  else if (BAG.IO.MaterialTyp<>c_IO_Theo) then begin
    APPON();
    RecBufDestroy(v701b);
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700119,''); // todox('A falsche Input-Typ');
    RETURN false;
  end;
  vIdA # BAG.IO.Id;

  vTxt # TextOpen(20);

  TRANSON;

  // den EINEN Einsatz erhöhen ---------------------
  if (v1HatMat) then begin
  end
  else begin
    Erx # RecRead(701,1,_recLock);
    BAG.IO.Breite         # BAG.IO.Breite + v701b->BAG.IO.Breite;
    BAG.IO.Plan.In.GewN   # BAG.IO.Plan.In.GewN + v701b->BAG.IO.Plan.In.GewN;
    BAG.IO.Plan.In.GewB   # BAG.IO.Plan.In.GewB + v701b->BAG.IO.Plan.In.GewB;
    BAG.IO.Plan.In.Menge  # BAG.IO.Plan.In.Menge + v701b->BAG.IO.Plan.In.Menge;
    BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.Out.GewN + v701b->BAG.IO.Plan.Out.GewN;
    BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.Out.GewB + v701b->BAG.IO.Plan.Out.GewB;
    BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.Out.Meng + v701b->BAG.IO.Plan.Out.Meng;
    BAG.IO.Ist.Out.GewN   # BAG.IO.Ist.Out.GewN + v701b->BAG.IO.Ist.Out.GewN;
    BAG.IO.Ist.Out.GewB   # BAG.IO.Ist.Out.GewB + v701b->BAG.IO.Ist.Out.GewB;
    BAG.IO.Ist.Out.Menge  # BAG.IO.Ist.Out.Menge + v701b->BAG.IO.Ist.Out.Menge;
    RekReplace(701);
  end;

  // alten Einsatz löschen ---------------------------------
  RekRestore(v701b);
  RekDelete(701);

  // Fertigungen transferieren -----------------------------
  // letzte Fertigung bestimmen:
  FOR Erx # RecLink(703,v702a,4,_recLast)
  LOOP Erx # RecLink(703,v702a,4,_recPrev)
  WHILE (Erx<=_rLocked) and (BAG.F.Fertigung>=999) do begin
    if (BAG.F.Fertigung>=999) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700126,'');// todox('A hat Absatz');
      RETURN false;
    end;
  END;
  vF # 1;
  if (Erx<=_rLocked) and (BAG.F.Fertigung<999) then vF # BAG.F.Fertigung;

  FOR Erx # RecLink(703,v702b,4,_recFirst|_recLock)   // Fertigungen loopen
  LOOP Erx # RecLink(703,v702b,4,_recFirst|_recLock)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.F.Fertigung>=999) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700127,''); // todox('B hat Absatz');
      RETURN false;
    end;

    vF # vF + 1;
    TextAddLine(vTxt, 'F'+aint(BAG.F.Fertigung)+':'+aint(vF));

    // Text unbenennen
    BA1_F_Data:Rename703Text(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, aPos1, vF);

    BAG.F.Position  # aPos1;
    BAG.F.Fertigung # vF;
    Erx # BA1_F_Data:Replace(_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700128,'');  // todox('Error');
      RETURN false;
    end;
  END;


  // Nachfolger umbiegen ----------------------------------
  FOR Erx # RecLink(701,v702b,3,_recFirst|_recLock)
  LOOP Erx # RecLink(701,v702b,3,_recFirst|_RecLock)
  WHILE (Erx<=_rLocked) do begin
    vI # Textsearch(vTxt, 1,1, 0, 'F'+aint(BAG.IO.VonFertigung)+':');
    if (vI=0) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700129,''); // todox('Transfer Error');
      RETURN false;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2);
    vI # cnvia(vA);

    BAG.IO.VonPosition    # aPos1;
    BAG.IO.VonFertigung   # vI;
    Erx # BA1_IO_Data:Replace(_recunlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700129,''); // todox('Nachfolger Error');
      RETURN false;
    end;
  END;


  // ALLE IOPs loopen und alten Einsatz-ID ersetzen (in Urpsrung oder VonId)
  FOR Erx # RecLink(701,700,3,_recFirst)
  LOOP Erx # RecLink(701,700,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.UrsprungsID<>vIdB) and (BAG.IO.VonID<>vIdB) then CYCLE;
    Erx # RecRead(701,1,_RecLock);
    if (BAG.IO.UrsprungsID=vIdB) then
      BAG.IO.UrsprungsID # vIdA;
    if (BAG.IO.VonID=vIdB) then
      BAG.IO.VonID # vIdA;
    RekReplace(701);
  END;


  // Position löschen ---------------------
  RecBufCopy(v702b, 702);
  Erx # RecRead(702,1,0);
  if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700130,''); // todox('Error');
      RETURN false;
  end;
  if (Delete(true)=false) then begin
    TRANSBRK;
    APPON();
    Textclose(vTxt);
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700130,''); // todox('Pos nicht löschbar');
    RETURN false;
  end;


  // VSB-Aktiionen umbiegen ------------------- 09.10.2019
  Recbufclear(404);
  Auf.A.Aktionsnr   # BAG.P.Nummer;
  Auf.A.Aktionspos  # BAG.P.Position;
  Auf.A.Aktionspos2 # 0;
  Auf.A.Aktionstyp  # c_Akt_BA_Plan;
  Erx # RecRead(404,2,0);
  WHILE (Erx<=_rNoRec) and (Auf.A.Aktionspos2<>0) and
    (Auf.A.Aktionsnr=BAG.P.Nummer) and (Auf.A.Aktionspos=BAG.P.Position) and (Auf.A.Aktionstyp=c_Akt_BA_Plan) do begin
    RecRead(404,1,_recLock);
    Auf.A.Aktionspos # aPos1;
    Erx # RekReplace(404);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(99,'Merge: VSB-Aktion nicht änderbar');
      RETURN false;
    end;
    //Auf.A.Aktionspos # aPos2; 15.04.2021 AH
    Auf.A.Aktionspos # BAG.P.Position;
    Erx # RecRead(404,1,0);
    Erx # RecRead(404,1,0);
  END;


  // kleinsten Termin bestimmen --------------------
  vA # 'b';
  if (v702a->BAG.P.Plan.StartDat>1.1.1900) and (v702b->BAG.P.Plan.StartDat>1.1.1900) then begin
    vCTa->vpDate # v702a->BAG.P.Plan.StartDat;
    vCTa->vpTime # v702a->BAG.P.Plan.StartZeit;
    vCTb->vpDate # v702b->BAG.P.Plan.StartDat;
    vCTb->vpTime # v702b->BAG.P.Plan.StartZeit;
    if (vCTa>vCTb) then vA # 'b'
  end
  else if (v702a->BAG.P.Plan.StartDat=0.0.0) then begin
    vA # 'b';
  end;
//debugx('merge '+aint(v702a->BAG.P.Nummer)+' bekommt '+aint(v702b->BAG.P.Nummer)+' '+vA);
  RecBufCopy(v702a,702);
  RecRead(702,1,_recLock);
  if (vA='b') then begin
    BAG.P.Plan.StartDat  # v702b->BAG.P.Plan.StartDat;
    BAG.P.Plan.StartZeit # v702b->BAG.P.Plan.StartZeit;
  end;
//debugx('also '+cnvad(BAG.P.Plan.StartDat));

  // Dauer addieren...
  BAG.P.Plan.Dauer # BAG.P.Plan.Dauer + v702b->BAG.P.Plan.Dauer;
  BA1_Laufzeit:Automatisch(n);

  BA1_P_Data:Replace(0,'MAN');


  TRANSOFF;

  APPON();
//TextWrite(vTxt, 'd:\debug\debug.txt', _TextExtern);
  Textclose(vTxt);
  RecBufDestroy(v702a);
  RecBufDestroy(v702b);
  RETURN true;
end;


//========================================================================
// Merge  +ERR
//
//========================================================================
sub MergeALTundKomisch(
  aBAG      : int;
  aPos1     : int;
  aPos2     : int; // nach Pos1
) : logic;
local begin
  Erx       : int;
  vTxt      : int;
  v702a     : int;
  v702b     : int;
  vF,vI,vJ  : int;
  vA        : alpha;
  vID       : int;
  v701      : int;
end;
begin

  if (aPos1=aPos2) then begin
    Error(700117,''); // todox('gleiche Positionen');
    RETURN false;
  end;

  APPOFF();

  v702a # RecBufCreate(702);
  v702b # RecBufCreate(702);

  v702a->BAG.P.Nummer    # aBAG;
  v702a->BAG.P.Position  # aPos1;
  Erx # RecRead(v702a,1,0);
  if (Erx>_rLocked) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);

    Error(700100,cnvai(aBAG)+'/'+cnvai(aPos1)); // todox('A nicht gefunden');
    RETURN false;
  end;
  v702b->BAG.P.Nummer    # aBAG;
  v702b->BAG.P.Position  # aPos2;
  Erx # RecRead(v702b,1,0);
  if (Erx>_rLocked) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700101,cnvai(aBAG)+'/'+cnvai(aPos2)); // todox('B nicht gefunden');
    RETURN false;
  end;


  // Prüfungen -------------------------------------------------
   if (v702a->BAG.P.Aktion<>v702b->BAG.P.Aktion) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700104,''); // todox('ungleich');
    RETURN false;
  end;
  if (v702a->BAG.P.Aktion<>c_BAG_Spalt) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);

    Error(700118,''); // todox('falscher Aktionstyp');
    RETURN false;
  end;
  if (RecLinkInfo(707,v702a,5,_reccount)>0) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700105,''); // todox('A schon verwogen');
    RETURN false;
  end;
  if (RecLinkInfo(707,v702b,5,_reccount)>0) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700106,''); // todox('B schon verwogen');
    RETURN false;
  end;

  if (RecLinkInfo(701,v702b,2,_reccount)<>1) then begin
    APPON();
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700119,''); // todox('B falsche Input-Zahl');
    RETURN false;
  end;

  vTxt # TextOpen(20);

  TRANSON;

  RecBufCopy(v702b, 702);
  Erx # RecLink(701,702,2,_recFirst);  // Input holen
  vID # BAG.IO.ID;

  Erx # RecLink(701, v702a, 2, _recFirst);  // Input loopen
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.BruderID<>0) then begin
      Erx # RecLink(701, v702a, 2, _recNext)
      CYCLE;
    end;

    v701 # RekSave(701);

    if (BAG.IO.NachFertigung<>0) or (BAG.IO.NachID<>0) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700120,''); // todox('KlonA Error');
      RETURN false;
    end;

    TextAddLine(vTxt, 'ID'+aint(BAG.IO.ID)+';');

    RecBufCopy(v702b, 702);

    RecRead(701,1,_recLock);
    BAG.IO.NachPosition   # aPos2;
    BAG.IO.NachFertigung  # 0;
    BAG.IO.NachID         # 0;
    Erx # BA1_IO_Data:Replace(_recunlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700121,''); // todox('KlonB Error');
      RETURN false;
    end;

    // Output aktualisieren
    if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      TRANSBRK;
      ERROROUTPUT;  // 01.07.2019
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700122,'');todox('KlonC Error');
      RETURN false;
    end;

    if (BA1_IO_I_Data:KlonenVon(vID)=false) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700123,''); // todox('KlonD Error');
      RETURN false;
    end;

    RekRestore(v701);
    Erx # RecLink(701, v702a, 2, 0);
    Erx # RecLink(701, v702a, 2, 0);
  END;



  // Vorgänger trennen ------------------------------------
  RecBufCopy(v702b, 702);
  Erx # RecLink(701,702,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    vI # TextSearch(vTxt, 1,1, 0, 'ID'+aint(BAG.IO.ID)+';');
    if (vI>0) then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;
    if (BA1_IO_I_Data:DeleteInput(false) = false) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700124,''); // todox('Delete Error');
      RETURN false;
    end;
    Erx # RecLink(701,702,2,0);
    Erx # RecLink(701,702,2,0);
  END;



  // Zurück biegen...
  FOR vI # TextSearch(vTxt, 1, 1, 0, 'ID')
  LOOP vI # TextSearch(vTxt, vI+1, 1, 0, 'ID')
  WHILE (vI>0) do begin
    vA # TextLineRead(vTxt, vI, 0);
    vJ # cnvia(vA);
    BAG.IO.ID # vJ;
    Erx # RecRead(701,1,_recLock);
    BAG.IO.NachPosition   # aPos1;
    Erx # BA1_IO_Data:Replace(_recunlock,'AUTO');
  END;



  // Vorgänger trennen ------------------------------------
  FOR Erx # RecLink(701,v702b,2,_recFirst|_recLock)
  LOOP Erx # RecLink(701,v702b,2,_recFirst|_RecLock)
  WHILE (Erx<=_rLocked) do begin
    BAG.IO.NachBAG        # 0;
    BAG.IO.NachPosition   # 0;
    BAG.IO.NachFertigung  # 0;
    BAG.IO.NachID         # 0;
    Erx # BA1_IO_Data:Replace(_recunlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700125,'');// todox('Vorgänger Error');
      RETURN false;
    end;
  END;



  // Fertigungen transferieren -----------------------------
  // letzte Fertigung bestimmen:
  FOR Erx # RecLink(703,v702a,4,_recLast)
  LOOP Erx # RecLink(703,v702a,4,_recPrev)
  WHILE (Erx<=_rLocked) and (BAG.F.Fertigung>=999) do begin
    if (BAG.F.Fertigung>=999) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700126,'');// todox('A hat Absatz');
      RETURN false;
    end;
  END;
  vF # 1;
  if (Erx<=_rLocked) and (BAG.F.Fertigung<999) then vF # BAG.F.Fertigung;

  FOR Erx # RecLink(703,v702b,4,_recFirst|_recLock)   // Fertigungen loopen
  LOOP Erx # RecLink(703,v702b,4,_recFirst|_recLock)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.F.Fertigung>=999) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700127,''); // todox('B hat Absatz');
      RETURN false;
    end;

    vF # vF + 1;

    TextAddLine(vTxt, 'F'+aint(BAG.F.Fertigung)+':'+aint(vF));

    // Text unbenennen
    BA1_F_Data:Rename703Text(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, aPos1, vF);

    BAG.F.Position  # aPos1;
    BAG.F.Fertigung # vF;
    Erx # BA1_F_Data:Replace(_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700128,'');  // todox('Error');
      RETURN false;
    end;
  END;


  // Nachfolger umbiegen ----------------------------------
  FOR Erx # RecLink(701,v702b,3,_recFirst|_recLock)
  LOOP Erx # RecLink(701,v702b,3,_recFirst|_RecLock)
  WHILE (Erx<=_rLocked) do begin
    vI # Textsearch(vTxt, 1,1, 0, 'F'+aint(BAG.IO.VonFertigung)+':');
    if (vI=0) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700129,''); // todox('Transfer Error');
      RETURN false;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2);
    vI # cnvia(vA);

    BAG.IO.VonPosition    # aPos1;
    BAG.IO.VonFertigung   # vI;
    Erx # BA1_IO_Data:Replace(_recunlock,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700129,''); // todox('Nachfolger Error');
      RETURN false;
    end;

  END;


  // Position löschen ---------------------
  RecBufCopy(v702b, 702);
  Erx # RecRead(702,1,0);
  if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Textclose(vTxt);
      RecBufDestroy(v702a);
      RecBufDestroy(v702b);
      Error(700130,''); // todox('Error');
      RETURN false;
  end;
  if (Delete(true)=false) then begin
    TRANSBRK;
    APPON();
    Textclose(vTxt);
    RecBufDestroy(v702a);
    RecBufDestroy(v702b);
    Error(700130,''); // todox('Pos nicht löschbar');
    RETURN false;
  end;


  TRANSOFF;

  APPON();

  Textclose(vTxt);
  RecBufDestroy(v702a);
  RecBufDestroy(v702b);
  RETURN true;
end;


//========================================================================
//========================================================================
sub _ProcessProto(
  aTxt        : int;
  aBAG1       : int;
  aLohn       : logic;
  aCopy       : logic;) : alpha
local begin
  Erx     : int;
  vI,vJ : int;
  vA,vB : alpha;
  vErr  : alpha(250);
  vAkt  : alpha;
end;
begin

  if (aCopy=false) then begin
    // Protokolltext loopen und Aktionen etc. konvertieren...
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=TextInfo(aTxt, _TextLines)) and (vErr='') do begin
      vA # TextLineRead(aTxt, vI, 0);
      if (StrFind(vA,'MATBB|',0)>0) then begin
        Mat.Nummer      # cnvia(Str_Token(vA,'|',2));
        vAkt # Str_Token(vA,'|',3);
        BAG.IO.Nummer   # cnvia(Str_Token(vA,'|',4));
        BAG.IO.Id       # cnvia(Str_Token(vA,'|',5));
        FOR Erx # RecLink(202, 200, 12, _recfirst)
        LOOP Erx # RecLink(202, 200, 12, _recNext)
        WHILE (Erx<=_rLocked) and (vErr='') do begin
          if ("Mat.B.Trägertyp"=vAkt) and
              ("Mat.B.TrägerNummer1"=BAG.IO.Nummer) and
              ("Mat.B.TrägerNummer2"=BAG.IO.ID) then begin

            vAkt # Str_Token(vA,'|',6);
            vJ # TextSearch(aTxt, 1, 1, 0,'ID_'+aint(BAG.IO.ID)+':');
            if (vJ=0) then begin
              vErr # 'MatBestandsbuch';
              BREAK;
            end;
            vA # TextLineRead(aTxt, vJ, 0);
            BAG.IO.Nummer    # aBAG1;
            BAG.IO.ID        # cnvia(Str_Token(vA,':',2));

            Erx # RecRead(202, 1, _recLock);
            "Mat.B.Trägernummer1" # BAG.IO.Nummer;
            "Mat.B.Trägernummer2" # BAG.IO.ID;
            Mat.B.Bemerkung       # vAkt+' '+AInt(BAG.IO.Nummer)+'/'+AInt(BAG.IO.ID);
            Erx # RekReplace(202);
            if (erx<>_rOK) then vErr # 'MatBestandsbuch';
            BREAK;
          end;
        END;
      end
      else if (StrFind(vA,'MATAKT|',0)>0) then begin
        Mat.Nummer # cnvia(Str_Token(vA,'|',2));
        "Mat~Nummer" # cnvia(Str_Token(vA,'|',3));
        vAkt # Str_Token(vA,'|',4);
        BAG.P.Nummer # cnvia(Str_Token(vA,'|',5));
        BAG.P.Position # cnvia(Str_Token(vA,'|',6));

        // Mat-Aktion konvertieren...
        FOR Erx # RecLink(204,200,14,_recFirst)
        LOOP Erx # RecLink(204,200,14,_recNext)
        WHILE (Erx<=_rLocked) and (vErr='') do begin
          if (Mat.A.Entstanden="Mat~Nummer") and (Mat.A.Aktionstyp=vAkt) and
            (Mat.A.Aktionsnr=BAG.P.Nummer) and (Mat.A.Aktionspos=BAG.P.Position) and
            (Mat.A.Aktionspos2=0) then begin
            vJ # TextSearch(aTxt, 1, 1, 0,'POS_'+aint(BAG.P.Position)+':');
            if (vJ=0) then begin
              vErr # 'MatAktion';
              BREAK;
            end;
            vA # TextLineRead(aTxt, vJ, 0);
            vA # Str_Token(vA,':',2)
            BAG.P.Nummer     # aBAG1;
            BAG.P.Position   # cnvia(vA);
            RecRead(204,1,_recLock);
            Mat.A.Aktionsnr   # BAG.P.Nummer;
            Mat.A.Aktionspos  # BAG.P.Position;
            Erx # RekReplace(204);
            if (erx<>_rOK) then vErr # 'MatAktions';
          end;
        END;

      end
      else if (StrFind(vA,'AUFAKT|',0)>0) then begin
        RecBufClear(404);
        Auf.A.Nummer      # cnvia(Str_Token(vA,'|',2));
        Auf.A.Position    # cnvia(Str_Token(vA,'|',3));
        Auf.A.Aktionstyp  # Str_Token(vA,'|',4);
        Auf.A.Aktionsnr   # cnvia(Str_Token(vA,'|',5));
        Auf.A.AktionsPos  # cnvia(Str_Token(vA,'|',6));
        Auf.A.AktionsPos2 # cnvia(Str_Token(vA,'|',7));
        Erx # RecRead(404,6,0);
        if (Erx<=_rMultikey) then begin
          vJ # TextSearch(aTxt, 1, 1, 0,'POS_'+aint(Auf.A.AktionsPos)+':');
          if (vJ=0) then begin
            vErr # 'AufAktion';
            BREAK;
          end;
          vA # TextLineRead(aTxt, vJ, 0);
          BAG.P.Position   # cnvia(Str_Token(vA,':',2));
          BAG.P.Nummer     # aBAG1;
          RecRead(404,1,_recLock);
          Auf.A.Aktionsnr   # BAG.P.Nummer;
          Auf.A.Aktionspos  # BAG.P.Position;

          if (Auf.A.AktionsPos2>0) then begin   // 07.06.2022 AH
            // 08.05.2018 AH: Fix
            vJ # TextSearch(aTxt, 1, 1, 0,'ID_'+aint(Auf.A.AktionsPos2)+':');
            if (vJ=0) then begin
              vErr # 'AufAktion2';
              BREAK;
            end;
            vA # TextLineRead(aTxt, vJ, 0);
            Auf.A.Aktionspos2  # cnvia(Str_Token(vA,':',2));
            
            // Mat-Reservierungen transferieren...
            RecBufClear(203);
            "Mat.R.Trägertyp"     # c_Akt_BAInput;
            "Mat.R.TrägerNummer1" # BAG.P.nummer;
            "Mat.R.TrägerNummer2" # Auf.A.AktionsPos2;
            Erx # RecRead(203,7,0);
            if (Erx<=_rMultikey) then begin
              Erx # RecRead(203,1,_recSingleLock);
              if (Erx<>_rOK) then begin
                vErr # 'MatReservierung';
                BREAK;
              end;
              "Mat.R.TrägerNummer2" # cnvia(Str_Token(vA,':',2));
              Erx # RekReplace(203);
              if (Erx<>_rOK) then begin
                vErr # 'MatReservierung';
                BREAK;
              end;
            end;
          end;
          
          Erx # RekReplace(404);
          if (Erx<>_rOK) then vErr # 'AufAktion';
        end;
      end;

      if (vErr<>'') then BREAK;
    END;

    if (vErr<>'') then RETURN vErr;
  end;


  if (aLohn) or (aCopy) then begin
    vI # 1;
    FOR vI # TextSearch(aTxt, vI, 1, 0,'POS_')
    LOOP vI # TextSearch(aTxt, vI+1, 1, 0,'POS_')
    WHILE (vI>0) do begin
      vA # TextLineRead(aTxt, vI, 0);
      vA # Str_Token(vA,':',2)

      BAG.P.Nummer    # BAG.Nummer;
      BAG.P.Position  # cnvia(vA);
      Erx # RecRead(702,1,0);
      if (Erx<=_rLocked) then begin

        if (aLohn) then
          BA1_P_Data:UpdateAufAktion(n);

        if (aCopy) and (BAG.P.Aktion=c_BAG_VSB) then begin
          if (BA1_F_Data:UpdateOutput(702)<>y) then begin
            vErr # 'VSB-Updaten';
            RETURN vErr;
          end;
        end;

      end;
    END;
  end; // Lohn

  RETURN '';
end;


//========================================================================
//  ImportBA
//
//========================================================================
sub ImportBA(
  aBAG1           : int;        // Ziel
  aBAG2           : int;        // Source
  aAufNr          : int;        // Kommission für '#'
  aAufPos         : int;
  aCopy           : logic;
  opt aOhneZeiten : logic;)
  : int                 // 1. neuer theoretischer Input
local begin
  Erx     : int;
  v700a         : int;
  v700b         : int;
  vTxt          : int;
  vPos          : int;
  vID           : int;
  vID1          : int;
  vVPG          : int;
  vI,vJ         : int;
  vA,vB         : alpha;
  vAkt          : alpha;
  vErr          : alpha;
//  vCopy         : logic;
  vBuf          : int;
  vLowestPos    : int;
  vLowestLevel  : int;
  vTheoInput    : int;
  vLohn         : logic;
end;
begin

  if (aBAG1=aBAG2) then RETURN 0;

  APPOFF();

  v700a # RecBufCreate(700);
  v700b # RecBufCreate(700);

  v700a->BAG.Nummer    # aBAG1;
  Erx # RecRead(v700a,1,0);
  if (Erx>_rLocked) then begin
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);

    Error(700100,cnvai(aBAG1)); // todox('A nicht gefunden');
    RETURN 0;
  end;
  v700b->BAG.Nummer    # aBAG2;
  Erx # RecRead(v700b,1,0);
  if (Erx>_rLocked) then begin
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);
    Error(700101,cnvai(aBAG1)); // todox('B nicht gefunden');
    RETURN 0;
  end;


  // Prüfugen -------------------------
  if (aCopy=false) then begin
    if (v700a->BAG.VorlageYN<>v700b->BAG.VorlageYN) then begin
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700104,''); // todox('sind Unterschiedlicher Typ');
      RETURN 0;
    end;
  end;
//  vCopy # v700b->BAG.VorlageYN;

  if (RecLinkInfo(707,v700a,5,_reccount)>0) then begin
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);
    Error(700105,cnvai(aBAG1)); // todox('A schon verwogen');
    RETURN 0;
  end;

  // ST 2018-10-09 1808/60
  if (aCopy = false) AND (RecLinkInfo(707,v700b,5,_reccount)>0) then begin
  //if (RecLinkInfo(707,v700b,5,_reccount)>0) then begin
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);
    Error(700106,cnvai(aBAG2)); // todox('B schon verwogen');
    RETURN 0;
  end;
  // letzte ID bestimmen....
  Erx # RecLink(701,v700a,3,_recLast);
  if (Erx<=_rMultikey) then vID # BAG.IO.ID + 1
  else vID # 1;
  // letzte Pos bestimmen....
  Erx # RecLink(702,v700a,1,_recLast);
  if (Erx<=_rMultikey) then vPos # BAG.P.Position + 1
  else vPos # 1;
  // letzte Verpackung bestimmen....
  Erx # RecLink(704,v700a,2,_recLast);
  if (Erx<=_rMultikey) then vVpg # BAG.Vpg.Verpackung + 1
  else vVpg # 1;


  vTxt # Textopen(20);
  vLowestLevel # 9999;

  TRANSON;

  // Verpackungen transferieren...
  FOR Erx # RecLink(704,v700b,2,_recFirst)
  LOOP  if (aCopy) then Erx # RecLink(704,v700b,2,_recNext)
        else Erx # RecLink(704,v700b,2,_recFirst)
  WHILE (Erx<=_rLocked) do begin

    TextAddLine(vTxt, 'VPG_'+aint(BAG.Vpg.Verpackung)+':'+aint(vVpg));

    if (aCopy) then vBuf # RekSave(704);
    else RecRead(704,1,_recLock);

    BAG.Vpg.Nummer      # aBAG1;
    BAG.Vpg.Verpackung  # vVpg;
    if (aCopy) then
      Erx # RekInsert(704,_recunlock,'AUTO')
    else
      Erx # RekReplace(704,_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700107,''); // todox('Verpackungs Error');
      RETURN 0;
    end;

    inc(vVpg);

    if (aCopy) then begin
      RekRestore(vBuf);
      RecRead(704,1,0);
    end;
  END;


  vID1 # vID;
  // Input/Output transferieren...
  FOR Erx # RecLink(701,v700b,3,_recFirst)
  LOOP  if (aCopy) then Erx # RecLink(701,v700b,3,_recNext)
        else Erx # RecLink(701,v700b,3,_recFirst)
  WHILE (Erx<=_rLocked) do begin

    if (aCopy) AND (BAG.IO.VonFertigmeld > 0) then
      CYCLE;

    TextAddLine(vTxt, 'ID_'+aint(BAG.IO.ID)+':'+aint(vID));

    if (aCopy) then begin
      vBuf # RekSave(701);
      // Text kopieren
      BA1_IO_Data:Rename701Text(BAG.IO.Nummer, BAG.IO.ID, vID, true);
    end
    else begin
      RecRead(701,1,_recLock);
      // Text unbenennen
      BA1_IO_Data:Rename701Text(BAG.IO.Nummer, BAG.IO.ID, vID);
    end;

    if (BAG.IO.Materialnr<>0) and (BAG.IO.MaterialTyp<>c_IO_BAG) then begin
      if (aCopy) then begin
//        BAG.IO.Materialnr     # 0;
//        BAG.IO.MaterialRstNr  # 0;
//        BAG.IO.Materialtyp    # c_IO_THeo;
//        if (1=2) then begin
//          TRANSBRK;
//          RecBufDestroy(v700a);
//          RecBufDestroy(v700b);
//          APPON();
//  todox('Einsatz mit echtem Material kann nicht kopiert werden!');
//          RETURN 0;
//        end;
      end
      else begin
        TextAddLine(vTxt, 'MATBB|'+aint(BAG.IO.Materialnr)+'|'+c_Akt_BA_Einsatz+'|'+aint(BAG.IO.Nummer)+'|'+aint(BAG.IO.ID)+'|'+c_Akt_BA);
      end;
    end;

    if (BAG.IO.NachBAG<>0) and (BAG.IO.VonBAG<>0) then begin
      Erx # RecLink(702, 701, 4, _recFirst);    // NachPosition holen
      if (Erx<=_rLocked) and (BAG.P.Typ.VSBYN) and (BAG.P.Auftragsnr<>0) then begin
        vAkt # aint(BAG.P.Auftragsnr)+'|'+aint(BAG.P.Auftragspos);
        Erx # RecLink(702, 701, 2, _recFirst);  // VonPosition holen
        if (Erx<=_rLocked) and ((BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand)) and (BAG.P.ZielVerkaufYN) then
          vAkt # vAkt + '|'+ c_Akt_BA_Plan_Fahr;
        else
          vAkt # vAkt + '|' + c_Akt_BA_Plan;
        TextAddLine(vTxt, 'AUFAKT|'+vAkt+'|'+aint(BAG.IO.VonBAG)+'|'+aint(BAG.IO.VonPosition)+'|'+aint(BAG.IO.ID));
      end;
    end;

// 10.03.2017 AH : wegen FAHREN
    if (aCopy=false) then begin
      // LFS-Positionen transferieren...
      FOR Erx # RecLink(441,701,13,_recFirst)   // Von-Pos loopen
      LOOP Erx # RecLink(441,701,13,_recNext)
      WHILE (Erx<=_rLocked) do begin
        RecRead(441,1,_recLock);
        Lfs.P.ZuBA.Nummer     # aBAG1;
        Lfs.P.ZuBA.InputID    # vID;
        Erx # RekREplace(441);
        if (Erx<>_rOK) then begin
          Textclose(vTxt);
          TRANSBRK;
          APPON();
          RecBufDestroy(v700a);
          RecBufDestroy(v700b);
          Error(700107,''); // todox('Verpackungs Error');
          RETURN 0;
        end;
      END;
      // Mat-Reservierungen transferieren...
      RecBufClear(203);
      "Mat.R.Trägertyp"     # c_Akt_BAInput;
      "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
      "Mat.R.TrägerNummer2" # BAG.IO.ID;
      Erx # RecRead(203,7,0);
      if (Erx<=_rMultikey) then begin
        RecRead(203,1,_recLock);
        "Mat.R.TrägerNummer1" # aBAG1;
        "Mat.R.TrägerNummer2" # vID;
        Erx # RekReplace(203);
        if (Erx<>_rOK) then begin
          Textclose(vTxt);
          TRANSBRK;
          APPON();
          RecBufDestroy(v700a);
          RecBufDestroy(v700b);
          Error(700107,''); // todox('Verpackungs Error');
          RETURN 0;
        end;
      end;
    end;


    BAG.IO.Nummer     # aBAG1;
    BAG.IO.ID         # vID;
    if (aCopy) then begin
      Erx # RekInsert(701,_recunlock,'AUTO')
    end
    else begin
      Erx # RekReplace(701,_recunlock,'AUTO');
    end;
    if (Erx<>_rOK) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700108,''); // todox('Input/Output Error');
      RETURN 0;
    end;

    inc(vID);

    if (aCopy) then begin
      RekRestore(vBuf);
      RecRead(701,1,0);
    end;
  END;


  // Positionen transferieren...
  FOR Erx # RecLink(702,v700b,1,_recFirst)// | _recLock)
  LOOP  if (aCopy) then Erx # RecLink(702,v700b,1,_recNext)
        else Erx # RecLink(702,v700b,1,_recFirst)
  WHILE (Erx<=_rLocked) do begin

    TextAddLine(vTxt, 'POS_'+aint(BAG.P.Position)+':'+aint(vPos));

    if (BAG.P.Level<vLowestLevel) then begin
      vLowestLevel  # BAG.P.Level;
      vLowestPos    # BAG.P.Position;
    end;

    if (aCopy) then begin
      vBuf # RekSave(702);
      // Text kopieren
      Rename702Text(BAG.P.Nummer, BAG.P.position, aBAG1, vPos, true);
    end
    else begin
      RecRead(702,1,_recLock);
      // Text unbenennen
      Rename702Text(BAG.P.Nummer, BAG.P.Position, aBAG1, vPos, false);
    end;

    if (BAG.P.Auftragsnr<>0) and (BAG.P.Typ.VSBYN=False) then
      TextAddLine(vTxt, 'AUFAKT|'+aint(BAG.P.Auftragsnr)+'|'+aint(BAG.P.Auftragspos)+'|'+c_Akt_BA+'|'+aint(BAG.P.Nummer)+'|'+aint(BAG.P.Position)+'|0');

// 10.03.2017 AH
    if (aCopy=false) then begin
      // LFS transferieren...
      FOR Erx # RecLink(440,702,14,_recFirst)   // LFS loopen
      LOOP Erx # RecLink(440,702,14,_recNext)
      WHILE (Erx<=_rLocked) do begin
        RecRead(440,1,_recLock);
        Lfs.ZuBA.Nummer     # aBAG1;
        Lfs.ZuBA.Position   # vPos;
        Erx # RekReplace(440);
        if (Erx<>_rOK) then begin
          Textclose(vTxt);
          TRANSBRK;
          APPON();
          RecBufDestroy(v700a);
          RecBufDestroy(v700b);
          Error(700109,''); // todox('Positions Error');
          RETURN 0;
        end;
/**
debugx('');
        // Posten loopen...
        FOR Erx # RecLink(441,440,4,_RecFirst)
        LOOP Erx # RecLink(441,440,4,_RecNext)
        WHILE (Erx<=_rLocked) do begin
          if (LFs.P.ZuBA.Nummer=BAG.P.Nummer) then begin
            RecRead(441,1,_RecLock);
            Lfs.P.ZuBA.Nummer # aBAG1;
debugX('');
      vI # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(Lfs.P.ZuBA.InputID)+':');
      if (vI<>0) then begin
        vA # TextLineRead(vTxt, vI, 0);
        vA # Str_Token(vA,':',2)
debug('biege '+aint(Lfs.P.ZuBA.InputID)+' wird '+vA);
        Lfs.P.ZuBA.InputID # cnvia(vA);
      end;
            RekReplace(441);
          end;
        END;
****/
/***
              FOR Erx # RecLink(441,701,15,_recFirst)   // Nach-Pos loopen
      LOOP Erx # RecLink(441,701,15,_recNext)
      WHILE (Erx<=_rLocked) do begin
        RecRead(441,1,_recLock);
        Lfs.P.ZuBA.Nummer     # aBAG1;
        Lfs.P.ZuBA.InputID    # vID;
        Erx # RekReplace(441);
        if (Erx<>_rOK) then begin
          TRANSBRK;
          APPON();
          RecBufDestroy(v700a);
          RecBufDestroy(v700b);
          Error(700107,''); // todox('Verpackungs Error');
          RETURN 0;
        end;
      END;
***/
      END;
    end;

    BAG.P.Nummer      # aBAG1;
    BAG.P.Position    # vPos;
    if (aCopy) then begin
      if (BAG.P.Auftragsnr<>0) and (aAufNr<>0) then begin
        BAG.P.Auftragsnr    # aAufNr;
        BAG.P.AuftragsPos   # aAufPos;
        BAG.P.Kommission    # AInt(aAufNr)+'/'+AInt(aAufPos);
        if (BAG.P.Aktion=c_BAG_VSB) then
          BAG.P.Bezeichnung   # BAG.P.Aktion+' '+BAG.P.Kommission;
        vLohn # y;

        // ST 2018-10-09 1808/60
        "BAG.P.Löschmarker" # '';
        BAG.P.Fertig.Dat  # 0.0.0;
        BAG.P.Fertig.User # '';
        BAG.P.Fertig.Zeit # 0:0;

        // 12.02.2019 AH:
        BA1_Data:SetStatus(c_BagStatus_Offen);
        BAG.P.Plan.StartDat   # 0.0.0;
        BAG.P.Plan.StartZeit  # 0:0;
        BAG.P.Plan.StartInfo  # '';
        BAG.P.Plan.EndDat     # 0.0.0;
        BAG.P.Plan.EndZeit    # 0:0;
        BAG.P.Plan.EndInfo    # '';
        if (Set.Installname='BSP') then begin
          BAG.P.Zusatz          # '';
          BAG.P.Ressource       # 0;
          BAG.P.Ressource.Grp   # 0;
        end;

      end;

      if (Set.Installname = 'BSC') then begin
        // ST 2021-09-13 Projekt 2298/17
        Call('SFX_ESK_Cut:CopyEskToBag', aBAG1, vPos,true);
      end;


      Erx # Insert(0,'AUTO');
    end
    else begin


      if (Set.Installname = 'BSC') then begin
        // ST 2021-09-13 Projekt 2298/17
        Call('SFX_ESK_Cut:CopyEskToBag', aBAG1, vPos,true);
      end;

      Erx # Replace(_recunlock,'AUTO');
    end;
    if (Erx<>_rOK) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700109,''); // todox('Positions Error');
      RETURN 0;
    end;

    inc(vPos);

    if (aCopy) then begin
      RekRestore(vBuf);
      RecRead(702,1,0);
    end;

  END;

  // Input/Output konvertieren...
  BAG.IO.Nummer # aBAG1;
  BAG.IO.ID     # vID1;
  FOR Erx # RecRead(701, 1, 0)
  LOOP Erx # RecLink(701, v700a ,3, _recNext)
  WHILE (Erx<=_rLocked) and (BAG.IO.ID>=vID1) do begin

    if (vTheoInput=0) and (BAG.IO.VonPosition=0) and (BAG.IO.NachPosition=vLowestPos) then begin
      if (BAG.IO.Materialtyp=c_IO_Theo) or
        (aCopy and ((BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Materialtyp=c_IO_VSB))) then begin // aus Echt/VSB  wird bei Copy ja Theo
        vTheoInput # BAG.IO.ID;
      end;
    end;

    RecRead(701,1,_recLock);

    if (aCopy) then begin
      if (BAG.IO.Auftragsnr<>0) and (aAufNr<>0) then begin
        BAG.IO.Auftragsnr   # aAufNr;
        BAG.IO.Auftragspos  # aAufPos;
      end;
    end;
    
    // ST 2022-01-17: Wiegungsdaten von Transferrierte BAG Einsätzen nullen  2209/14
    if (BAG.IO.MaterialTyp = c_IO_BAG) then begin
        BAG.IO.Ist.In.GewB    # 0.0;
        BAG.IO.Ist.In.GewN    # 0.0;
        BAG.IO.Ist.In.Menge   # 0.0;
        BAG.IO.Ist.In.Stk     # 0;

        BAG.IO.Ist.Out.GewB   # 0.0;
        BAG.IO.Ist.Out.GewN   # 0.0;
        BAG.IO.Ist.Out.Menge  # 0.0;
        BAG.IO.Ist.Out.Stk    # 0;
    end;
    
    
    
    if (BAG.IO.VonPosition<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.IO.VonPosition)+':');
      if (vI=0) then begin
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('IDPos Error');
        RETURN 0;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)
      BAG.IO.VonPosition  # cnvia(vA);
      BAG.IO.VonBAG       # aBAG1;
    end;

    if (BAG.IO.NachPosition<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.IO.NachPosition)+':');
      if (vI=0) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,'');// todox('IDPos Error');
        RETURN 0;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)

      if (BAG.IO.Materialnr<>0)  then begin

        if (aCopy) then begin
          if (BAG.IO.MaterialTyp<>c_IO_BAG) then begin
            BAG.IO.Materialnr     # 0;
            BAG.IO.MaterialRstNr  # 0;
            BAG.IO.Materialtyp    # c_IO_THeo;
          end;

          // ST 2018-10-09 1808/60, Verwogene Mengen nullen
          BAG.IO.Ist.In.GewB    # 0.0;
          BAG.IO.Ist.In.GewN    # 0.0;
          BAG.IO.Ist.In.Menge   # 0.0;
          BAG.IO.Ist.In.Stk     # 0;

          BAG.IO.Ist.Out.GewB   # 0.0;
          BAG.IO.Ist.Out.GewN   # 0.0;
          BAG.IO.Ist.Out.Menge  # 0.0;
          BAG.IO.Ist.Out.Stk    # 0;

        end else begin

          if (BAG.IO.MaterialTyp<>c_IO_BAG) then begin
            TextAddLine(vTxt, 'MATAKT|'+aint(BAG.IO.Materialnr)+'|'+aint(0)+'|'+c_Akt_BA_Einsatz+'|'+aint(BAG.IO.NachBAG)+'|'+aint(BAG.IO.NachPosition));
            TextAddLine(vTxt, 'MATAKT|'+aint(BAG.IO.Materialnr)+'|'+aint(BAG.IO.MaterialRstNr)+'|'+c_Akt_BA_Rest+'|'+aint(BAG.IO.NachBAG)+'|'+aint(BAG.IO.NachPosition));
          end;
        end;

      end;


      BAG.IO.NachPosition # cnvia(vA);
      BAG.IO.NachBAG      # aBAG1;
    end;

    if (BAG.IO.VonID<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.VonID)+':');
      if (vI=0) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('ID Error');
        RETURN 0;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)
      BAG.IO.VonID # cnvia(vA);
    end;
    if (BAG.IO.NachID<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.NachID)+':');
      if (vI=0) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('ID Error');
        RETURN 0;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)
      BAG.IO.NachID # cnvia(vA);
    end;
    if (BAG.IO.UrsprungsID<>0) then begin
      vI # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.UrsprungsID)+':');
      if (vI=0) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('ID Error');
        RETURN 0;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)
      BAG.IO.UrsprungsID # cnvia(vA);
    end;
    Erx # RekReplace(701,_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700110,''); // todox('ID Error');
        RETURN 0;
    end;
  END;



  // Fertigungen loopen...
  FOR Erx # RecLink(703, v700b, 6, _recFirst)
  LOOP  if (aCopy) then Erx # RecLink(703, v700b, 6, _recNext)
        else Erx # RecLink(703, v700b, 6, _recFirst)
  WHILE (Erx<=_rLocked) do begin

    vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.F.Position)+':');
    if (vI=0) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700111,''); // todox('Fertigung Error');
      RETURN 0;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2)
    vJ # cnvia(vA);

    TextAddLine(vTxt, 'FERT_'+aint(BAG.F.Position)+'/'+aint(BAG.F.Fertigung)+':'+aint(vPos)+'/'+aint(BAG.F.Fertigung));

    if (aCopy) then begin
      vBuf # RekSave(703);
      // Text kopieren
      BA1_F_Data:Rename703Text(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, vJ, BAG.F.Fertigung, True);
    end
    else begin
      RecRead(703,1,_recLock);
      // Text unbenennen
      BA1_F_Data:Rename703Text(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, vJ, BAG.F.Fertigung);
    end;


    if (StrCut(BAG.F.Kommission,1,1)='#') and (aAufPos<>0) then begin
      BA1_F_Data:BelegeKommisisonsDaten(BAG.F.Kommission, aAufNr, aAufPos)
    end;


    BAG.F.Nummer    # aBAG1;
    BAG.F.Position  # vJ;
    if (BAG.F.Verpackung<>0) then begin
      vJ # 0;
      vI # TextSearch(vTxt, 1, 1, 0,'VPG_'+aint(BAG.F.Verpackung)+':');
      if (vI<>0) then begin
        vA # TextLineRead(vTxt, vI, 0);
        vA # Str_Token(vA,':',2)
        vJ # cnvia(vA);
      end;
      BAG.F.Verpackung # vJ;
    end;
    if (aCopy) then begin

      // ST 2018-10-09 1808/60
      BAG.F.Fertig.Gew   # 0.0;
      BAG.F.Fertig.Menge # 0.0;
      BAG.F.Fertig.Stk   # 0;
      "BAG.F.Löschmarker" # '';   // 09.04.2019

      if (BAG.F.Auftragsnummer<>0) and (aAufNr<>0) then begin
        BAG.F.Auftragsnummer    # aAufNr;
        BAG.F.Auftragspos       # aAufPos;
        BAG.F.Kommission          # aInt(BAG.F.Auftragsnummer)  + '/' +aint(BAG.F.Auftragspos);
      end;

      Erx # RekInsert(703, _recUnlock, 'AUTO')
    end
    else begin
      Erx # RekReplace(703, _recUnlock, 'AUTO');
    end;
    if (Erx<>_rOK) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700111,''); // todox('Fertigungs Error');
      RETURN 0;
    end;

    if (aCopy) then begin
      RekRestore(vBuf);
      RecRead(703,1,0);
    end;
  END;


  // Ausführungen loopen...
  FOR Erx # RecLink(705, v700b, 7, _recFirst)
  LOOP  if (aCopy) then Erx # RecLink(705, v700b, 7, _recNext)
        else Erx # RecLink(705, v700b, 7, _recFirst)
  WHILE (Erx<=_rLocked) do begin

    vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.AF.Position)+':');
    if (vI=0) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700112,''); // todox('Ausführung Error');
      RETURN 0;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2)
    vJ # cnvia(vA);

    if (aCopy) then begin
      vBuf # RekSave(705);
    end
    else begin
      RecRead(705,1,_recLock);
    end;

    BAG.AF.Nummer     # aBAG1;
    BAG.AF.Position   # vJ;
    if (aCopy) then begin
      if (BAG.AF.Fertigmeldung=0) then  // nur wenn NICHT aus FM
        Erx # RekInsert(705, _recUnlock, 'AUTO');
    end
    else
      Erx # RekReplace(705, _recUnlock, 'AUTO');
    if (Erx<>_rOK) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700112,''); // todox('Ausführungs Error');
      RETURN 0;
    end;

    if (aCopy) then begin
      RekRestore(vBuf);
      RecRead(705,1,0);
    end;
  END;


  // Arbeitsschritte loopen...
  FOR Erx # RecLink(706, v700b, 8, _recFirst)
  LOOP  if (aCopy) then Erx # RecLink(706, v700b, 8, _recNext)
        else Erx # RecLink(706, v700b, 8, _recFirst)
  WHILE (Erx<=_rLocked) do begin

    vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.AS.Position)+':');
    if (vI=0) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700113,''); // todox('Arbeitsschritte Error');
      RETURN 0;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2)
    vJ # cnvia(vA);


    if (aCopy) then begin
      vBuf # RekSave(706);
    end
    else begin
      RecRead(706,1,_recLock);
    end;

    BAG.AS.Nummer     # aBAG1;
    BAG.AS.Position   # vJ;
    if (aCopy) then
      Erx # RekInsert(706, _recUnlock, 'AUTO')
    else
      Erx # RekReplace(706, _recUnlock, 'AUTO');
    if (Erx<>_rOK) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700113,''); // todox('Arbeitsschritte Error');
      RETURN 0;
    end;

    if (aCopy) then begin
      RekRestore(vBuf);
      RecRead(706,1,0);
    end;
  END;


  // Zeiten loopen...
  if (aOhneZeiten) then begin
    FOR Erx # RecLink(709, v700b, 9, _recFirst)
    LOOP  if (aCopy) then Erx # RecLink(709, v700b, 9, _recNext)
          else Erx # RecLink(709, v700b, 9, _recFirst)
    WHILE (Erx<=_rLocked) do begin

      vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.Z.Position)+':');
      if (vI=0) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700114,''); // todox('Zeiten Error');
        RETURN 0;
      end;
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)
      vJ # cnvia(vA);


      if (aCopy) then begin
        vBuf # RekSave(709);
      end
      else begin
        RecRead(709,1,_recLock);
      end;

      BAG.Z.Nummer     # aBAG1;
      BAG.Z.Position   # vJ;
      if (aCopy) then
  //      Erx # RekReplace(709, _recUnlock, 'AUTO'); 28.01.2019 AH
        Erx # RekInsert(709, _recUnlock, 'AUTO')
      else
        Erx # RekReplace(709, _recUnlock, 'AUTO');
      if (Erx<>_rOK) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        RecBufDestroy(v700a);
        RecBufDestroy(v700b);
        Error(700114,''); // todox('Zeiten Error');
        RETURN 0;
      end;

      if (aCopy) then begin
        RekRestore(vBuf);
        RecRead(709,1,0);
      end;
    END;
  end;

  // Zusatz loopen...
  FOR Erx # RecLink(711, v700b, 10, _recFirst)
  LOOP  if (aCopy) then Erx # RecLink(711, v700b, 10, _recNext)
        else Erx # RecLink(711, v700b, 10, _recFirst)
  WHILE (Erx<=_rLocked) do begin

    vI # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.PZ.Position)+':');
    if (vI=0) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700115,''); // todox('Zusatz Error');
      RETURN 0;
    end;
    vA # TextLineRead(vTxt, vI, 0);
    vA # Str_Token(vA,':',2)
    vJ # cnvia(vA);


    if (aCopy) then begin
      vBuf # RekSave(711);
    end
    else begin
      RecRead(711,1,_recLock);
    end;

    BAG.PZ.Nummer     # aBAG1;
    BAG.PZ.Position   # vJ;
    if (aCopy) then begin
      BAG.PZ.Anlage.Datum # today;
      BAG.PZ.Anlage.Zeit  # now;
      BAG.PZ.Anlage.User  # gUsername;
      Erx # RekInsert(711, _recUnlock, 'AUTO')
    end
    else begin
      Erx # RekReplace(711, _recUnlock, 'AUTO');
    end;
    if (Erx<>_rOK) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700115,''); // todox('Zusatz Error');
      RETURN 0;
    end;

    if (aCopy) then begin
      RekRestore(vBuf);
      RecRead(711,1,0);
    end;
  END;


  // Nur wenn MOVE ---
  if (aCopy=false) then begin
    // Kopf löschen...
    RecBufCopy(v700b, 700);
    RecRead(700,1,_recLock);
    BAG.Bemerkung     # Translate('exportiert nach BA')+' '+aint(v700a->BAG.Nummer);
    "BAG.Löschmarker" # '*';
    Erx # RekReplace(700,_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Error(700116,cnvai(BAG.Nummer)) // ;todox('Kopf Error');
      RETURN 0;
    end;
    BA1_Data:SetVsbMarker("BAG.Löschmarker");      // 25.03.2021 AH


    vErr # _ProcessProto(vTxt, aBAG1, vLohn, aCopy);
    if (vErr<>'') then begin
      TRANSBRK;
      APPON();
      RecBufDestroy(v700a);
      RecBufDestroy(v700b);
      Textclose(vTxt);
      Error(700117,vErr); // todox(vErr);
      RETURN 0;
    end;
  end;

/*** 09.05.2020 AH
    // Protokolltext loopen und Aktionen etc. konvertieren...
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=TextInfo(vTxt, _TextLines)) and (vErr='') do begin
      vA # TextLineRead(vTxt, vI, 0);

      if (StrFind(vA,'MATBB|',0)>0) then begin
        Mat.Nummer      # cnvia(Str_Token(vA,'|',2));
        vAkt # Str_Token(vA,'|',3);
        BAG.IO.Nummer   # cnvia(Str_Token(vA,'|',4));
        BAG.IO.Id       # cnvia(Str_Token(vA,'|',5));
        FOR Erx # RecLink(202, 200, 12, _recfirst)
        LOOP Erx # RecLink(202, 200, 12, _recNext)
        WHILE (Erx<=_rLocked) and (vErr='') do begin
          if ("Mat.B.Trägertyp"=vAkt) and
              ("Mat.B.TrägerNummer1"=BAG.IO.Nummer) and
              ("Mat.B.TrägerNummer2"=BAG.IO.ID) then begin

            vAkt # Str_Token(vA,'|',6);
            vJ # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.ID)+':');
            if (vJ=0) then begin
              vErr # 'MatBestandsbuch';
              BREAK;
            end;
            vA # TextLineRead(vTxt, vJ, 0);
            BAG.IO.Nummer    # aBAG1;
            BAG.IO.ID        # cnvia(Str_Token(vA,':',2));

            Erx # RecRead(202, 1, _recLock);
            "Mat.B.Trägernummer1" # BAG.IO.Nummer;
            "Mat.B.Trägernummer2" # BAG.IO.ID;
            Mat.B.Bemerkung       # vAkt+' '+AInt(BAG.IO.Nummer)+'/'+AInt(BAG.IO.ID);
            Erx # RekReplace(202);
            if (erx<>_rOK) then vErr # 'MatBestandsbuch';
            BREAK;
          end;
        END;
      end
      else if (StrFind(vA,'MATAKT|',0)>0) then begin
        Mat.Nummer # cnvia(Str_Token(vA,'|',2));
        "Mat~Nummer" # cnvia(Str_Token(vA,'|',3));
        vAkt # Str_Token(vA,'|',4);
        BAG.P.Nummer # cnvia(Str_Token(vA,'|',5));
        BAG.P.Position # cnvia(Str_Token(vA,'|',6));

        // Mat-Aktion konvertieren...
        FOR Erx # RecLink(204,200,14,_recFirst)
        LOOP Erx # RecLink(204,200,14,_recNext)
        WHILE (Erx<=_rLocked) and (vErr='') do begin
          if (Mat.A.Entstanden="Mat~Nummer") and (Mat.A.Aktionstyp=vAkt) and
            (Mat.A.Aktionsnr=BAG.P.Nummer) and (Mat.A.Aktionspos=BAG.P.Position) and
            (Mat.A.Aktionspos2=0) then begin
            vJ # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(BAG.P.Position)+':');
            if (vJ=0) then begin
              vErr # 'MatAktion';
              BREAK;
            end;
            vA # TextLineRead(vTxt, vJ, 0);
            vA # Str_Token(vA,':',2)
            BAG.P.Nummer     # aBAG1;
            BAG.P.Position   # cnvia(vA);
            RecRead(204,1,_recLock);
            Mat.A.Aktionsnr   # BAG.P.Nummer;
            Mat.A.Aktionspos  # BAG.P.Position;
            Erx # RekReplace(204);
            if (erx<>_rOK) then vErr # 'MatAktions';
          end;
        END;

      end
      else if (StrFind(vA,'AUFAKT|',0)>0) then begin
        RecBufClear(404);
        Auf.A.Nummer      # cnvia(Str_Token(vA,'|',2));
        Auf.A.Position    # cnvia(Str_Token(vA,'|',3));
        Auf.A.Aktionstyp  # Str_Token(vA,'|',4);
        Auf.A.Aktionsnr   # cnvia(Str_Token(vA,'|',5));
        Auf.A.AktionsPos  # cnvia(Str_Token(vA,'|',6));
        Auf.A.AktionsPos2 # cnvia(Str_Token(vA,'|',7));
        Erx # RecRead(404,6,0);
        if (Erx<=_rMultikey) then begin
          vJ # TextSearch(vTxt, 1, 1, 0,'POS_'+aint(Auf.A.AktionsPos)+':');
          if (vJ=0) then begin
            vErr # 'AufAktion';
            BREAK;
          end;
          vA # TextLineRead(vTxt, vJ, 0);
          BAG.P.Position   # cnvia(Str_Token(vA,':',2));
          BAG.P.Nummer     # aBAG1;
          RecRead(404,1,_recLock);
          Auf.A.Aktionsnr   # BAG.P.Nummer;
          Auf.A.Aktionspos  # BAG.P.Position;

          // 08.05.2018 AH: Fix
          vJ # TextSearch(vTxt, 1, 1, 0,'ID_'+aint(Auf.A.AktionsPos2)+':');
          if (vJ=0) then begin
            vErr # 'AufAktion2';
            BREAK;
          end;
          vA # TextLineRead(vTxt, vJ, 0);
          Auf.A.Aktionspos2  # cnvia(Str_Token(vA,':',2));

          Erx # RekReplace(404);
          if (Erx<>_rOK) then vErr # 'AufAktion';
        end;
      end;

      if (vErr<>'') then BREAK;
    END;

  end;  // MOVE

  if (vErr<>'') then begin
    TRANSBRK;
    APPON();
    RecBufDestroy(v700a);
    RecBufDestroy(v700b);
    Textclose(vTxt);
    Error(700117,vErr); // todox(vErr);
    RETURN 0;
  end;
***/

  if (vLohn) or (aCopy) then begin
    vI # 1;
    FOR vI # TextSearch(vTxt, vI, 1, 0,'POS_')
    LOOP vI # TextSearch(vTxt, vI+1, 1, 0,'POS_')
    WHILE (vI>0) do begin
      vA # TextLineRead(vTxt, vI, 0);
      vA # Str_Token(vA,':',2)

      BAG.P.Nummer    # BAG.Nummer;
      BAG.P.Position  # cnvia(vA);
      Erx # RecRead(702,1,0);
      if (Erx<=_rLocked) then begin


        if (vLohn) then
          BA1_P_Data:UpdateAufAktion(n);

        if (aCopy) and (BAG.P.Aktion=c_BAG_VSB) then begin
          if (BA1_F_Data:UpdateOutput(702)<>y) then begin
            TRANSBRK;
            ERROROUTPUT;  // 01.07.2019
            APPON();
            RecBufDestroy(v700a);
            RecBufDestroy(v700b);
            Textclose(vTxt);
            Error(700117,'VSB-Updaten');
            RETURN 0;
          end;
        end;

      end;
    END;
  end; // Lohn


  TRANSOFF;

  APPON();

  RecBufCopy(v700a, 700);

//TextWrite(vTxt,'d:\debug\debug.txt',_TextExtern);
  Textclose(vTxt);

  RecBufDestroy(v700a);
  RecBufDestroy(v700b);

  RunAFX('BA1.ImportBA.Post','');

  RETURN vTheoInput;
end;


//========================================================================
//  Aufruecken
//
//========================================================================
sub Aufruecken(
  aBAG            : int;        // Ziel
  aAbPos          : int)
  : int                         // 2022-08-31 AH : NEUE Pos-Nr (früher nur TRUE)
local begin
  Erx     : int;
  vTxt          : int;
  vLastPos      : int;
  vZielPos      : int;
  vI,vJ         : int;
  vA,vB         : alpha;
  vAkt          : alpha;
  vErr          : alpha;
  vBuf          : int;
  vMod          : logic;
  v702          : int;
end;
begin

  APPOFF();

  BAG.Nummer # aBAG;
  Erx # RecRead(700, 1,0);
  if (Erx>_rLocked) then begin
    APPON();
    RETURN -1;
  end;

  // 2022-08-31 AH : Falls Positionsnr "frei" ist, einfach dorthin einfügen!
  if (aAbPos>1) then begin
    BAG.P.Nummer    # aBag;
    BAG.P.Position  # aAbPos - 1;
    Erx # RecRead(702,1,_recTest);
    if (Erx>_rLocked) then begin
      APPON();
      RETURN aAbPos - 1;
    end;
  end;

  // AB HIER AUFRÜCKEN !!!!!!!

  // Prüfugen -------------------------
  if (RecLinkInfo(707,700,5,_reccount)>0) then begin
    APPON();
    Error(700105,cnvai(aBAG)); // todox('A schon verwogen');
    RETURN -1;
  end;
  // letzte Pos bestimmen....
  vLastPos # aAbPos;
  REPEAT
    vLastPos # vLastPos + 1;
    BAG.P.Nummer    # aBag;
    BAG.P.Position  # vLastpos;
    Erx # RecRead(702,1,_recTest);
  UNTIL (Erx>_rLocked);


  vTxt # Textopen(20);

  TRANSON;


  // Positionen verschieben...
  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # vLastPos - 1;
  FOR Erx # RecRead(702,1,0)
  LOOP Erx # RecLink(702,700,1,_recPrev)   // Rückwärts die Positionen umnummerieren
  WHILE (Erx<=_rLocked) and (BAG.P.Position>=aAbPos) do begin

    vZielPos # BAG.P.Position + 1;
    TextAddLine(vTxt, 'POS_'+aint(BAG.P.Position)+':'+aint(vZielPos));

    vBuf # RekSave(702);
    // Text kopieren
    Rename702Text(BAG.P.Nummer, BAG.P.position, BAG.P.Nummer, vZielPos, true);

    if (BAG.P.Auftragsnr<>0) and (BAG.P.Typ.VSBYN=False) then begin
      //TextAddLine(vTxt, 'AUFAKT|'+aint(BAG.P.Auftragsnr)+'|'+aint(BAG.P.Auftragspos)+'|'+c_Akt_BA+'|'+aint(BAG.P.Nummer)+'|'+aint(vZielPos)+'|0');
      // 07.06.2022 AH FIX
      TextAddLine(vTxt, 'AUFAKT|'+aint(BAG.P.Auftragsnr)+'|'+aint(BAG.P.Auftragspos)+'|'+c_Akt_BA+'|'+aint(BAG.P.Nummer)+'|'+aint(BAG.P.Position)+'|0');
    end;

    // Fertigungen verschieben...
    FOR Erx # RecLink(703,702,4,_recFirst|_RecLock)
    LOOP Erx # RecLink(703,702,4,_recFirst|_recLock)
    WHILE (Erx<=_rLocked) do begin
      TextAddLine(vTxt, 'FERT_'+aint(BAG.F.Position)+'/'+aint(BAG.F.Fertigung)+':'+aint(vZielPos)+'/'+aint(BAG.F.Fertigung));

      // Text kopieren
      BA1_F_Data:Rename703Text(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, vZielPos, BAG.F.Fertigung, True);

      // Ausführungen verschieben...
      FOR Erx # RecLink(705, 703, 8, _recFirst|_RecLock)
      LOOP Erx # RecLink(705, 703, 8, _recFirst|_recLock)
      WHILE (Erx<=_rLocked) do begin
        BAG.AF.Position   # vZielPos;
        Erx # RekReplace(705, _recUnlock, 'AUTO');
        if (Erx<>_rOK) then begin
          Textclose(vTxt);
          TRANSBRK;
          APPON();
          Error(700112,''); // todox('Ausführungs Error');
          RETURN -1;
        end;
      END;  // AF

      BAG.F.Position # vZielPos;
      Erx # RekReplace(703, _recUnlock, 'AUTO');
      if (Erx<>_rOK) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        Error(700111,''); // todox('Fertigungs Error');
        RETURN -1;
      end;
    END; // Fertigung


    // Arbeitsschritte loopen...
    FOR Erx # RecLink(706, 702, 9, _recFirst|_recLock)
    LOOP Erx # RecLink(706, 702, 9, _recFirst|_recLock)
    WHILE (Erx<=_rLocked) do begin
      BAG.AS.Position   # vZielPos;
      Erx # RekReplace(706, _recUnlock, 'AUTO');
      if (Erx<>_rOK) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        Error(700113,''); // todox('Arbeitsschritte Error');
        RETURN -1;
      end;
    END;

    // Zeiten loopen...
    FOR Erx # RecLink(709, 702, 6, _recFirst|_recLock)
    LOOP Erx # RecLink(709, 702, 6, _recFirst|_RecLock)
    WHILE (Erx<=_rLocked) do begin

      BAG.Z.Position   # vZielPos;
      Erx # RekReplace(709, _recUnlock, 'AUTO');
      if (Erx<>_rOK) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        Error(700114,''); // todox('Zeiten Error');
        RETURN -1;
      end;
    END;


    // Zusatz loopen...
    FOR Erx # RecLink(711, 702, 20, _recFirst|_recLock)
    LOOP Erx # RecLink(711, 702, 20, _recFirst|_recLock)
    WHILE (Erx<=_rLocked) do begin

      BAG.PZ.Position   # vZielPos;
      Erx # RekReplace(711, _recUnlock, 'AUTO');
      if (Erx<>_rOK) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        Error(700115,''); // todox('Zusatz Error');
        RETURN -1;
      end;
    END;


    // LFS transferieren...
    FOR Erx # RecLink(440,702,14,_recFirst)   // LFS loopen
    LOOP Erx # RecLink(440,702,14,_recNext)
    WHILE (Erx<=_rLocked) do begin
      RecRead(440,1,_recLock);
      Lfs.ZuBA.Position   # BAG.P.Position + 1;
      Erx # RekReplace(440);
      if (Erx<>_rOK) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        Error(700109,''); // todox('Positions Error');
        RETURN -1;
      end;
    END;


    // Inputs konvertieren...
    FOR Erx # RecLink(701, 702, 2, _recFirst|_reCLock)
    LOOP Erx # RecLink(701, 702, 2, _recFirst|_RecLock)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.Materialnr<>0)  then begin
        TextAddLine(vTxt, 'MATAKT|'+aint(BAG.IO.Materialnr)+'|'+aint(0)+'|'+c_Akt_BA_Einsatz+'|'+aint(BAG.IO.NachBAG)+'|'+aint(vZielPOs));
        TextAddLine(vTxt, 'MATAKT|'+aint(BAG.IO.Materialnr)+'|'+aint(BAG.IO.MaterialRstNr)+'|'+c_Akt_BA_Rest+'|'+aint(BAG.IO.NachBAG)+'|'+aint(vZielPos));
      end;

      if (TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.ID)+':')=0) then begin   // 07.06.2022 AH
        TextAddLine(vTxt, 'ID_'+aint(BAG.IO.ID)+':'+aint(BAG.IO.ID));
      end;

      if (BAG.P.Typ.VSBYN) and (BAG.P.Auftragsnr<>0) then begin
        vAkt # aint(BAG.P.Auftragsnr)+'|'+aint(BAG.P.Auftragspos);
        v702 # RecBufCreate(702);
        Erx # RecLink(v702, 701, 2, _recFirst);  // VonPosition holen
        if (Erx<=_rLocked) and ((v702->BAG.P.Aktion=c_BAG_Fahr) or (v702->BAG.P.Aktion=c_BAG_Versand)) and (v702->BAG.P.ZielVerkaufYN) then
          vAkt # vAkt + '|'+ c_Akt_BA_Plan_Fahr;
        else
          vAkt # vAkt + '|' + c_Akt_BA_Plan;
        RecBufDestroy(v702);
        TextAddLine(vTxt, 'AUFAKT|'+vAkt+'|'+aint(BAG.IO.VonBAG)+'|'+aint(BAG.IO.VonPosition)+'|'+aint(BAG.IO.ID));
      end;


      BAG.IO.NachPosition # vZielPos;
      Erx # RekReplace(701,_recunlock,'AUTO');
      if (Erx<>_rOK) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        Error(700110,''); // todox('ID Error');
        RETURN -1;
      end;
    END;  // Input


    // Outputs konvertieren...
    FOR Erx # RecLink(701, 702, 3, _recFirst|_reCLock)
    LOOP Erx # RecLink(701, 702, 3, _recFirst|_RecLock)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.Materialnr<>0)  then begin
        TextAddLine(vTxt, 'MATAKT|'+aint(BAG.IO.Materialnr)+'|'+aint(0)+'|'+c_Akt_BA_Einsatz+'|'+aint(BAG.IO.NachBAG)+'|'+aint(vZielPOs));
        TextAddLine(vTxt, 'MATAKT|'+aint(BAG.IO.Materialnr)+'|'+aint(BAG.IO.MaterialRstNr)+'|'+c_Akt_BA_Rest+'|'+aint(BAG.IO.NachBAG)+'|'+aint(vZielPos));
      end;

      if (TextSearch(vTxt, 1, 1, 0,'ID_'+aint(BAG.IO.ID)+':')=0) then begin   // 07.06.2022 AH
        TextAddLine(vTxt, 'ID_'+aint(BAG.IO.ID)+':'+aint(BAG.IO.ID));
      end;

      BAG.IO.VonPosition # vZielPos;
      Erx # RekReplace(701,_recunlock,'AUTO');
      if (Erx<>_rOK) then begin
        Textclose(vTxt);
        TRANSBRK;
        APPON();
        Error(700110,''); // todox('ID Error');
        RETURN -1;
      end;
    END;  // Input


    RecRead(702,1,_recLock);
    BAG.P.Position # vZielPos;
    Erx # Replace(_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
      Textclose(vTxt);
      TRANSBRK;
      APPON();
      Error(700109,''); // todox('Positions Error');
      RETURN -1;
    end;

  END;  // Pos


  vErr # _ProcessProto(vTxt, aBAG, false, false);
  Textclose(vTxt);
  if (vErr<>'') then begin
    TRANSBRK;
    APPON();
    Error(700117,vErr); // todox(vErr);
    RETURN -1;
  end;

  TRANSOFF;

  APPON();

  RETURN aAbPos;//BAG.P.Position;
end;


//========================================================================
//  ComboClosedCheck
//      Nach Schlieüen der Combo-Maske für Prüfungen wie VSB, Angebote etc.
//      08.06.2018 AH: neu auch LAUFZEIT
//========================================================================
SUB ComboClosedCheck();
local begin
  Erx     : int;
  vOK   : logic;
  vOK2  : logic;
  vAutoLaufzeit : logic;
end;
begin

  // 03.01.2019 AH
  vAutoLaufzeit # y;
  if (Set.Installname='BSP') then begin
    call('SFX_BSP_BAG:VererbeVsbDatenHoch');
    REPEAT
      Erx # Msg(99,'Laufzeit aller Positionen neu errechnen?',_WinIcoQuestion,_WinDialogYesNoCancel,3);
    UNTIL (Erx<>_WinIdCancel);
    vAutoLaufzeit # Erx = _winidyes;
  end;


  Lib_Mark:Reset(702, true);

  vOK # true;

  FOR Erx # Reklink(702,700,1,_recFirst)    // Positionen loopen
  LOOP Erx # Reklink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // Laufzeitermittlung
    if (vAutoLaufzeit) then
      BA1_Laufzeit:Automatisch(n,y);    // 08.06.2018 AH

    if (BA1_P_Lib:StatusInAnfrage()=false) then CYCLE;

    vOK2 # false;

    // Bestellaktion suchen...
    RecBufClear(504);
    Ein.A.Aktionsnr   # BAG.P.Nummer;
    Ein.A.Aktionspos  # BAG.P.Position;
    Ein.A.Aktionstyp  # c_Akt_BA;
    FOR Erx # RecRead(504,2,0)   // Bestellaktion loopen...
    LOOP Erx # RecRead(504,2,_recNext)
    WHILE (Erx<=_rMultikey) and
      (Ein.A.Aktionsnr=BAG.P.Nummer) and
      (Ein.A.Aktionspos=BAG.P.Position) and
      (Ein.A.Aktionstyp=c_Akt_BA) do begin

      if ("Ein.A.Löschmarker"<>'') then CYCLE;
      // Found!
      vOK2 # true;
      BREAK;
    END;
    if (vOK2=false) then begin
      vOK # false;
      Lib_Mark:MarkAdd(702,y,y);
    end;

  END;

  //  ST 2022-04-04 2298/13/20 Deaktiviert laut Kundenwunsch
/*
  // ST 2021-08-05 Projekt 2298/13
  if (Set.Installname='BSC') then
    Call('SFX_BA1_P:UpdateTerminPlanung',Bag.Nummer);
*/
  if (vOK=false) then begin
    Msg(702500,'',0,0,0);
  end;

end;


//========================================================================
//========================================================================
sub _InnerUpdateSort(
  aTxt    : int;
  aLevel  : int);
local begin
  Erx     : int;
  vNextL  : int;
  vA,vB   : alpha(200);
  vI, vJ  : int;
  v702    : int;
  v701    : int;
end;
begin
//Textaddline(aTxt, 'INNER '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position));
//debugx('_inner KEY702');
//    FOR vItem # Lib_RamSort:ItemFirst(aTree)
//    LOOP vItem # Lib_RamSort:ItemNext(aTree, vItem)
//    WHILE (vItem<>0) do begin
  
  if (aLevel>50) then RETURN;   // 24.02.2022 AH: Schutz vor ZIRKEL
  aLevel # aLevel + 1;

  vI # TextSearch(aTxt, 1, 1, _TextSearchCI, 'P'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position));
  if (vI=0) then RETURN;

  vA # TextLineRead(aTxt, vI, 0);
  vNextL # cnvia(Str_Token(vA,'=',2));
//TextAddLine(aTxt, 'suche '+aint(BAG.P.Nummer)+'/'+aint(bag.p.position)+' ergab '+aint(vNextL));
  if (aLevel<=vNextL) then RETURN;    // Knoten bereits "teurer"

  vA # Str_Token(vA,'=',1);
  TextLineWrite(aTxt, vI, vA + '='+ aint(aLevel), 0);
//TextAddLine(aTxt, 'modde auf '+aint(BAG.P.Nummer)+'/'+aint(bag.p.position)+' = '+aint(aLevel));
//    TextLineWrite(aTxt, vI, vA + aint(vLevel), 0);
//    TextLineRead(aTxt, vI, _TextLineDelete);    // todo entfernen

  // Output durchlaufen und Kinder suchen...
  vNextL # aLevel;
  FOR Erx # RecLink(701,702,3,_RecFirst)
  LOOP Erx # RecLink(701,702,3,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.NachBAG<>BAG.P.Nummer) then CYCLE;
    if (BAG.IO.MaterialTyp<>c_IO_BAG) then CYCLE;
    if (BAG.IO.NachPosition=BAG.P.Position) then CYCLE;
    if (BAG.IO.NachPosition=0) then CYCLE;

    v702 # RekSave(702);
    v701 # RekSave(701);
    BAG.P.Nummer    # BAG.IO.NachBAG;
    BAG.P.Position  # BAG.IO.NachPosition;
    _InnerUpdateSort(aTxt, aLevel);
    RekRestore(v702);
    RekRestore(v701);
  END;

//      Lib_RamSort:Add(vTree, aint(Bag.P.nummer)+'/'+aint(Bag.P.Position), Bag.P.Position, '-1')
//  Lbi_ramSort:KillList(vTree);

end;


//========================================================================
// Call BA1_P_data:UpdateSort
//========================================================================
sub UpdateSort();
local begin
  Erx     : int;
  vTxt    : int;
  vLevel  : int;
  vA,vB   : alpha(200);
  vI, vJ  : int;
  v702    : int;
  v701    : int;
  vOK     : logic;
end;
begin
  APPOFF();

  v701 # RekSave(701);
  v702 # RekSave(702);

  vTxt # TextOpen(20);

  // Alle Posten aufnehmen
  FOR Erx # RecLink(702,700,1,_RecFirst)
  LOOP Erx # RecLink(702,700,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin
//    Lib_RamSort:Add(vTree, aint(Bag.P.nummer)+'/'+aint(Bag.P.Position), Bag.P.Position, '0');
    TextAddLine(vTxt, 'P'+aint(Bag.P.nummer)+'/'+aint(Bag.P.Position)+'=0');
  END;

  // Posten loopen...
  FOR Erx # RecLink(702,700,1,_RecFirst)
  LOOP Erx # RecLink(702,700,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    // Input loopen und STARTER suchen...
    vOK # true;
    FOR Erx # RecLink(701,702,2,_RecFirst)
    LOOP Erx # RecLink(701,702,2,_RecNext)
    WHILE (Erx<=_rLocked) and (vOK) do begin
//      if (BAG.IO.MaterialTyp=c_IO_BAG) then CYCLE;
//      _InnerUpdateSort(vTxt, 0);
      if (BAG.IO.MaterialTyp=c_IO_BAG) then vOK # false;
    END;
    if (vOK) then begin
      _InnerUpdateSort(vTxt, 0);
    end;
  END;


  // Speichern...
  FOR vI # TextSearch(vTxt, 1, 1, _TextSearchCI, 'P')
  LOOP vI # TextSearch(vTxt, vI + 1, 1, _TextSearchCI, 'P')
  WHILE (vI<>0) do begin
    vA # TextLineRead(vTxt, vI, 0);
    vLevel # cnvia(Str_Token(vA,'=',2));
    vB # Str_Token(vA,'=',1);
    BAG.P.Nummer    # cnvia(Str_Token(vB,'/',1));
    BAG.P.Position  # cnvia(Str_Token(vB,'/',2));
    Erx # RecRead(702,1,0);
    if (Erx<=_rLocked) then begin
      if (BAG.P.Level<>vLevel) then begin
      REcRead(702,1,_RecLock);
      BAG.P.Level # vLevel;
      Replace(_recUnlock,'AUTO');
//debugx('SET KEY702 auf '+aint(vLevel));
      end;
    end;
  END;

  TextClose(vTxt);

  RekRestore(v702);
  RekRestore(v701);

  APPON();
end;


//========================================================================
// RepairStatus
//========================================================================
sub RepairStatus();
local begin
  Erx : int;
end;
begin
  // BA-Positionen loopen
  FOR Erx # RecRead(702,1, _RecFirst)
  LOOP Erx # RecRead(702,1, _RecNext)
  WHILE (Erx = _rOk) do begin
    if (BAG.P.Status='') then begin
      RecRead(702,1,_reclock);
      if ("BAG.P.Löschmarker"='') then
        BA1_Data:SetStatus(c_BagStatus_Offen)
      else
        BA1_Data:SetStatus(c_BagStatus_Fertig);
      RekReplace(702);
    end;
  END;

end;


//========================================================================
//  Replace
//
//========================================================================
SUB Replace(
  aLock     : int;
  aGrund    : alpha) : int;
local begin
  Erx     : int;
  vAlt    : int;
end;
begin
  if (BAG.P.Status='') and ("BAG.P.Löschmarker"='') then
    BA1_Data:SetStatus(c_BagStatus_Offen);
  if ("BAG.P.Löschmarker"<>'') then
    BA1_Data:SetStatus(c_BagStatus_Fertig);

  // 10.07.2017...
  vAlt # RecBufCreate(702);
  RecRead(vAlt, 0, _recId, RecInfo(702,_recID));

  Erx # RekReplace(702,aLock,aGrund);
  if (Erx=_rOK) and (BAG.P.Typ.VSBYN=false) then begin
    Rso_Rsv_Data:Update702(vAlt);
  end;
  RecBufDestroy(vAlt);

//debugx('TEST...');
//  // ALLE Fenster updaten...
//&&  if (aAuto=false) and
  if (BAG.P.Typ.VSBYN=false) then begin
//UpdateFenster();
    UpdateFolgendeVSB();
  end;
  
  if (RunAFX('BAG.P.Data.Operation','EDIT') <> 0) then begin
    ERx# AfxRes;
  end;

  Erg # Erx; // TODOERX
  RETURN Erx;
end;


//========================================================================
//  Insert
//
//========================================================================
SUB Insert(aLock : int; aGrund : alpha) : int;
local begin
  Erx  : int;
end;
begin

  if (BAG.P.Status='') and ("BAG.P.Löschmarker"='') then
    BA1_Data:SetStatus(c_BagStatus_Offen);
  if ("BAG.P.Löschmarker"<>'') then
    BA1_Data:SetStatus(c_BagStatus_Fertig);

  BAG.P.Kosten.Wae    # Max(BAG.P.Kosten.Wae, 1);
  BAG.P.Anlage.Datum  # Today;
  BAG.P.Anlage.Zeit   # Now;
  BAG.P.Anlage.User   # gUserName;
  Erx # RekInsert(702,aLock,aGrund);

  if (Erx<>_rOK) then
    RETURN Erx;

  Rso_Rsv_Data:Insert702();

  // AUTOMATISCH FERTIGUNGEN ANLEGEN: (Walzen macht das sonstwo!)
  if (RunAFX('BAG.P.Data.Operation','NEW') <> 0) then begin
    ERx# AfxRes;
  end;

  Erg # Erx; // TODOERX
  RETURN Erx;
end;


//========================================================================
//  09.06.2022  AH                                            2298/6/160
//========================================================================
sub CopyAbPos(
  aPos        : int;
  opt aParPos : int;
  opt aOffPos : int;
  opt aOffIO  : int;
) : int
local begin
  Erx       : int;
  vOffPos   : int;
  vOffIO    : int;
  vUr702    : int;
  v703      : int;
  v702      : int;
  v701      : int;
  v705      : int;
  v706      : int;
  v711      : int;
  vNeuePos  : int;
end;
begin
//debugx(aint(aPos)+'/'+aint(aParPos)+'/'+aint(aoffpos)+'/'+aint(aoffIO));
  vUr702 # RekSave(702);
  if (BAG.P.Nummer<>aPos) then begin
    BAG.P.Position # aPos;
    Erx # RecRead(702,1,0);
    if (erx>_rLocked) then begin
      RekRestore(vUr702);
      RETURN -1;
    end;
  end;
  if (BAG.Nummer<>BAG.P.Position) then begin
    Erx # RecLink(700,702,1,_recFirst);   // Kopf holen
    if (erx>_rLocked) then begin
      RekRestore(vUr702);
      RETURN -1;
    end;
  end;

  v702 # RekSave(702);

  if (aParPos=0) then begin
    // Offsets bestimmen...
    Erx # RecLink(702,700,1,_recLast);    // letzte Pos
    vOffPos # BAG.P.Position;
    Erx # RecLink(701,700,3,_recLast);    // letzter IO
    vOffIO  # BAG.IO.ID;
  end
  else begin
    vOffPos # aOffPos;
    vOffIO  # aOffIO;
  end;
  
  RekRestore(v702);
  
  vNeuePos # BAG.P.Position + vOffPos;

  TRANSON;

  // 1. Inputs loopen ------------------------------
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.VonFertigmeld<>0) then CYCLE;
    
    v701 # RekSave(701);
//debugx('IO '+aint(BAG.IO.ID)+' wird '+aint(BAG.IO.ID + vOffIO));
    BAG.IO.ID           # BAG.IO.ID + vOffIO;
    if (BAG.IO.Materialtyp=c_IO_BAG) and (BAG.IO.VonPosition=aParPos) then begin
      CYCLE;
    end
    else begin
      BAG.IO.Materialtyp    # c_IO_Theo;      // ALLE FREMDEN WERDEN THEORIE
      BAG.IO.VonBAG         # 0;
      BAG.IO.VonFertigung   # 0;
      BAG.IO.VonID          # 0;
      BAG.IO.VonPosition    # 0;
      BAG.IO.Materialnr     # 0;
      BAG.IO.MaterialRstNr  # 0;
    end;
    BAG.IO.NachPosition # vNeuePos;
    if (BAG.IO.NachID<>0) then      BAG.Io.Nachid #  BAG.IO.NachID + vOffIO;
    if (BAG.IO.UrsprungsID<>0) then BAG.IO.UrsprungsID  # BAG.IO.UrsprungsID + vOffIO;
    Erx # RekInsert(701);
    if (erx<>_rOK) then begin
//debugx('AUA');
      RekRestore(v701);
      RekRestore(vUr702);
      TRANSBRK;
      RETURN -1;
    end;

    RekRestore(v701);
  END;

  // Fertigungen loopen -------------------------
  FOR Erx # RecLink(703,702,4,_recFirst)
  LOOP Erx # RecLink(703,702,4,_recNext)
  WHILE (erx<=_rLocked) do begin
    v703 # RekSave(703);
    BAG.F.Position      # vNeuePos;
    BAG.F.zuVersand     # 0;
    BAG.F.zuVersand.Pos # 0;
    Erx # RekInsert(703);
    if (erx<>_rOK) then begin
//debugx('AUA');
      RekRestore(v703);
      RekRestore(vUr702);
      TRANSBRK;
      RETURN -1;
    end;

    // Text unbenennen
    BA1_F_Data:Rename703Text(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, vNeuePos, BAG.F.Fertigung);
    
    RekRestore(v703);

    // Ausführungen loopen -------------------------
    FOR Erx # RecLink(705,703,8,_recFirst)
    LOOP Erx # RecLink(705,703,8,_recNext)
    WHILE (erx<=_rLocked) do begin
      v705 # RekSave(705);
      BAG.AF.Position      # vNeuePos;
      Erx # RekInsert(705);
      if (erx<>_rOK) then begin
        RekRestore(v705);
        RekRestore(vUr702);
        TRANSBRK;
        RETURN -1;
      end;
      RekRestore(v705);
    END;
  END;
  
  // Arbeitsschritte loopen -------------------------
  FOR Erx # RecLink(706,702,9,_recFirst)
  LOOP Erx # RecLink(706,702,9,_recNext)
  WHILE (erx<=_rLocked) do begin
    v706 # RekSave(706);
    BAG.AS.Position      # vNeuePos;
    Erx # RekInsert(706);
    if (erx<>_rOK) then begin
      RekRestore(v706);
      RekRestore(vUr702);
      TRANSBRK;
      RETURN -1;
    end;
    RekRestore(v706);
  END;

  // Zusatz loopen -------------------------
  FOR Erx # RecLink(711,702,20,_recFirst)
  LOOP Erx # RecLink(711,702,20,_recNext)
  WHILE (erx<=_rLocked) do begin
    v711 # RekSave(711);
    BAG.PZ.Position # vNeuePos;
    Erx # RekInsert(711);
    if (erx<>_rOK) then begin
      RekRestore(v711);
      RekRestore(vUr702);
      TRANSBRK;
      RETURN -1;
    end;
    RekRestore(v711);
  END;
  
  // Pos. kopieren -----------------------
  v702 # RekSave(702);
  BAG.P.Position # vNeuePos;
  Erx # RekInsert(702);
  if (erx<>_rOK) then begin
//debugx('AUA');
    RekRestore(v702);
    RekRestore(vUr702);
    TRANSBRK;
    RETURN -1;
  end;
  RekRestore(v702);

  // Text unbenennen
  Rename702Text(BAG.P.Nummer, BAG.P.position, BAG.P.nummer, vNeuePos, true);

  // Outputs loopen ------------------------------
  FOR Erx # RecLink(701,702,3,_recFirst)
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.VonFertigmeld<>0) then CYCLE;

    v701 # RekSave(701);
    BAG.IO.ID           # BAG.IO.ID + vOffIO;
    BAG.IO.VonPosition  # vNeuePos;
    if (BAG.IO.VonId<>0) then         BAG.IO.VonID # BAG.IO.VonID + vOffIO;
    if (BAG.IO.NachID<>0) then        BAG.Io.Nachid #  BAG.IO.NachID + vOffIO;
    if (BAG.IO.NachPosition<>0) then  BAG.IO.NachPosition  # BAG.IO.NachPosition + vOffPos;
    Erx # RekInsert(701);
    if (erx<>_rOK) then begin
//debugx('AUA');
      RekRestore(v701);
      RekRestore(vUr702);
      TRANSBRK;
      RETURN -1;
    end;
    RekRestore(v701);
    
    if (BAG.IO.NachPosition<>0) then begin
//debugx('Rek...');
      Erx # CopyAbPos(BAG.IO.NachPosition, BAG.P.Position, vOffPos, vOffIO);
      if (erx<=0) then begin
//debugx('AUA '+aint(erx));
        RekRestore(vUr702);
        TRANSBRK;
        RETURN -1;
      end;
    end;
  END;


  // neue Pos "buchen" ----------------------
  BAG.P.Position # vNeuePos;
  Erx # Recread(702,1,0);
//xdebugx(aint(RecRead(702,1,_recLock)));
/***
    if (BA1_Laufzeit:Automatisch(y)) then begin
      Replace(_recUnlock,'MAN');
      UpdateAufAktion(n);
    end
    else begin
      RecRead(702,1,_recUnlock);
      UpdateAufAktion(n);
    end;
***/
  if (BA1_F_Data:UpdateOutput(702,n,n,n,n,y)<>y) then begin
    RekRestore(vUr702);
    TRANSBRK;
    RETURN -1;
  end;

  // oberster Rekursionslauf beendet alles...
  if (aParPos=0) then begin
    if (Lib_misc:ProcessTodos()=false) then begin
      RekRestore(vUr702);
      TRANSBRK;
      RETURN -1;
    end;
  end;

  TRANSOFF;
  
  RekRestore(vUr702);
  
  RETURN vNeuePos;
end;



//========================================================================
//  2023-01-19  ST
//  Zum Manuellen löschen einer BA Position, ohne Abräumen der Reste
//  CAll BA1_P_Data:SetBagPDelMark()
//========================================================================
sub SetBagPDelMark() : int
local begin
  Erx : int;
  vBagPNummerPos : alpha;
end
begin

  if (Dlg_Standard:Standard('BagNr/Pos', var vBagPNummerPos) = false) then
    RETURN 0;

  Bag.P.Nummer    # CnvIa(Str_Token(vBagPNummerPos,'/',1));
  Bag.P.Position  # CnvIa(Str_Token(vBagPNummerPos,'/',2));
  Erx # RecRead(702,1,_RecLock);
  if (Erx <> _rOK) then begin
    MsgErr(99,'Arbeitsgang nicht lesbar');
    RETURN 0;
  end;

  "BAG.P.Löschmarker" # '*';
  
  Erx # RekReplace(702,_RecUnLock);
  if (Erx <> _rOK) then
    MsgErr(99,'Arbeitsgang nicht speicherbar');
    
  
end;





//========================================================================
//========================================================================