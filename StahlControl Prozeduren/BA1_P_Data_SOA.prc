@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_P_Data_SOA
//                  OHNE E_R_G
//
//  Info      Enthält Implmentierung der Serviceaufrufe für
//            Betriebsauftragsarbeitsgänge
//
//
//  02.03.2015  ST  Erstellung der Prozedur
//  16.03.2016  AH  Neu: Feld "BAG.P.Status"
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB Insert(aBagNr : int; aAktion : alpha) : int
//    SUB Replace(aBuff : handle) : int
//    SUB Delete(aCheckFertigung : logic) : logic;
//    SUB AutoVsb(aBagNr : int; aBagPos : int ) : int
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG

//========================================================================
//  Insert() : int  +ERR
//  Fügt eine neuen Betriebsauftragsposition ein
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Insert(aBagNr : int; aAktion : alpha) : int
local begin
  Erx   : int;
  vPos  : int;
end;
begin
  if (aBagNr <= 0) then begin
    RETURN -1;
  end;

  // Bag lesen
  RecBufClear(700);
  Bag.Nummer # aBagNr;
  Erx # RecRead(700,1,0);
  if (Erx > _rOK) then begin
    if (Erx = _rLocked) then
      Error(001001,'Betriebsauftrag');
    else
      Error(001003,'Betriebsauftrag');  //  001003 :  vA # 'E:#%1%:Satz nicht gefunden!';
    RETURN -1;
  end;

  // BAG ok zum anhängen?
  if ("Bag.Löschmarker" =  '*') then begin
    Error(702001,''); // 702001 :  vA # 'E:Position ist bereits abgeschlossen!';
    RETURN -1;
  end;

  // Aktion ermitteln
  ArG.Aktion2 # aAktion;
  Erx # RecRead(828,1,0);
  if (Erx > _rOK) then begin
    if (Erx = _rLocked) then
      Error(001001,'Arbeitsgang');
    else
      Error(001003,'Arbeitsgang');  //  001003 :  vA # 'E:#%1%:Satz nicht gefunden!';
    RETURN -1;
  end;

  // Position einfügen
  RecLink(702,700,1,_RecLast);
  Bag.P.Nummer            #   Bag.Nummer;

  BAG.P.Anlage.Datum      #   today;
  BAG.P.Anlage.Zeit       #   now;
  BAG.P.Anlage.User       #   gUsername;

  BAG.P.Aktion            #   ArG.Aktion;
  BAG.P.Aktion2           #   ArG.Aktion2;
  BAG.P.Bezeichnung       #   ArG.Bezeichnung;
  "BAG.P.Typ.1In-1OutYN"  #   "ArG.Typ.1In-1OutYN";
  "BAG.P.Typ.1In-yOutYN"  #   "ArG.Typ.1In-yOutYN";
  "BAG.P.Typ.xIn-yOutYN"  #   "ArG.Typ.xIn-yOutYN";
  BAG.P.Typ.VSBYN         #   ArG.Typ.VSBYN;

  BAG.P.Kosten.Wae        #   1;
  BAG.P.Kosten.PEH        #   1000;
  BAG.P.Kosten.MEH        #   'kg';

  if (BAG.P.Status='') and ("BAG.P.Löschmarker"='') then
    BA1_Data:SetStatus(c_BagStatus_Offen);
  if ("BAG.P.Löschmarker"<>'') then
    BA1_Data:SetStatus(c_BagStatus_Fertig);

  vPos # Bag.P.Position + 1;
  REPEAT
    Bag.P.Position # vPos;
    Erx # BA1_P_Data:Insert(_recUnlock,'SOA');
  UNTIL (Erx = _rOK);

  RETURN _rOK;
end;



//========================================================================
//  Replace(aBagBuf : handle) : int  +ERR
//  Ändert eine Betriebsauftragsposition
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Replace(aBuff : handle) : int
local begin
  Erx   : int;
  vNr   : int;
end;
begin
  if (aBuff <= 0) then
    RETURN -1;

  // Lesen und Sperren
  Bag.P.Nummer    # aBuff->Bag.P.Nummer;
  Bag.P.Position  # aBuff->Bag.P.Position;
  Erx # RecRead(702,1,0 | _RecLock);
  if (Erx <> _rOK) then begin
    Error(001007,'Betriebsauftragsposition');
    RETURN -1;
  end;

  // Übergebene Daten übertragen
  RecBufCopy(aBuff,702);

  // Verknüpfte Daten ermitteln
  if (BAG.P.ExterneLiefNr <> 0) then
    BAG.P.ExternYN # true
  else
    BAG.P.ExternYN # false;

  if (BAG.P.Auftragsnr <> 0) then
    BAG.P.Kommission # AInt(BAG.P.Auftragsnr)+'/'+AInt(BAG.P.Auftragspos);

  if (BAG.P.Zieladresse <> 0) AND (BAG.P.Zielanschrift <> 0)  then begin
    RekLink(101,703,13,0);
    BAG.P.Zieladresse   # Adr.A.Adressnr;
    BAG.P.Zielanschrift # Adr.A.Nummer;
    BAG.P.Zielstichwort # Adr.A.Stichwort;
  end;

  // Hier Bag.P.Kosten.Gesamt ausrechnen

  // Datensatz ändern
  Erx # BA1_P_Data:Replace(_recUnlock,'SOA');
  if (Erx <> _rOK) then begin
    Error(001012,'Betriebsauftragsposition');
    RETURN -1;
  end;

  RETURN _rOK;
end;


//========================================================================
//  Delete(aBagBuf : handle) : int  +ERR
//  Löscht eine Betriebsauftragsposition
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Delete(aBagNr : int; aBagPos : int ) : int
local begin
  Erx     : int;
  vOK     : logic;
end;
begin
  if (aBagNr <= 0) OR (aBagPos <= 0) then
    RETURN -1;

  // Lesen und Sperren
  Bag.P.Nummer    # aBagNr;
  Bag.P.Position  # aBagPos;
  Erx # RecRead(702,1,0);
  if (Erx <> _rOK) then begin
    Error(001007,'Betriebsauftragsposition');
    RETURN -1;
  end;

  vOK # Ba1_P_Data:Delete(true);
  if (vOK) then
    RETURN _rOK;
  else
    RETURN -1;

end;



//========================================================================
//  AutoVSB(aBagNr : int; aBagPos : int ) : int  +ERR
//   Erstellt VSB Einträge für die Angegeben BA Position
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub AutoVsb(aBagNr : int; aBagPos : int ) : int
local begin
  Erx   : int;
  vOK   : logic;
end;
begin
  if (aBagNr <= 0) OR (aBagPos <= 0) then
    RETURN -1;

  vOK # true;

  if (aBagPos <> 0) then begin

    // VSBs für nur eine Position

    // Lesen und Sperren
    Bag.P.Nummer    # aBagNr;
    Bag.P.Position  # aBagPos;
    Erx # RecRead(702,1,0);
    if (Erx <> _rOK) then begin
      Error(001007,'Betriebsauftragsposition');
      RETURN -1;
    end;

    vOK # Ba1_P_Data:AutoVSB();

  end else begin

    // VSB für alle Arbeitsgänge anlegen
    FOR   Erx # RecLink(702,700,1,_RecFirst)
    LOOP  Erx # RecLink(702,700,1,_RecNext)
    WHILE Erx = _rOK DO BEGIN
      vOK # Ba1_P_Data:AutoVSB();
      if (vOK = false) then begin
        Error(702007 ,'');    // 702007 :  vA # 'E:Automatische VSBs konnten NICHT angelegt werden!!!'
        BREAK;
      end;
    END;

  end;

  if (vOK) then
    RETURN _rOK;
  else
    RETURN -1;

end;



//========================================================================
//  ClearVSB(aBagNr : int; aBagPos : int ) : int  +ERR
//   Löscht VSB Einträge für die angegeben BA Position, oder alle
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub ClearVsb(aBagNr : int; aBagPos : int ) : int
local begin
  Erx   : int;
  vOK   : logic;
end;
begin
  if (aBagNr <= 0) OR (aBagPos <= 0) then
    RETURN -1;

  vOK # true;

  if (aBagPos <> 0) then begin

    // VSBs für nur eine Position

    // Position Lesen
    Bag.P.Nummer    # aBagNr;
    Bag.P.Position  # aBagPos;
    Erx # RecRead(702,1,0);
    if (Erx <> _rOK) then begin
      Error(001007,'Betriebsauftragsposition');
      RETURN -1;
    end;

    vOK # Ba1_P_Data:DelPosVSB(aBagNr, aBagPos);

  end else begin

    // BA Lesen
    Bag.Nummer    # aBagNr;
    Erx # RecRead(700,1,0);
    if (Erx <> _rOK) then begin
      Error(001007,'Betriebsauftrag');
      RETURN -1;
    end;

    vOK # Ba1_P_Data:DelAllVSB();

  end;

  if (vOK) then
    RETURN _rOK;
  else
    RETURN -1;

end;

//========================================================================