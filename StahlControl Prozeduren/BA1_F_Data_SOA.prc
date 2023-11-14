@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_F_Data_SOA
//                    OHNE E_R_G
//  Info      Enthält Implmentierung der Serviceaufrufe für
//            Betriebsauftragsfertigungen
//
//
//  02.03.2015  ST  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB Insert(aBagNr : int; aBagPos : int) : int
//    SUB Replace(aBuff : handle) : int
//    SUB Delete(aBagNr : int; aBagPos : int; aBagFert : int ) : int
//
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen


//========================================================================
//  Insert() : int  +ERR
//  Fügt eine neue Betriebsauftragsfertigung ein
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Insert(aBagNr : int; aBagPos : int) : int
local begin
  vFert : int;
  Erx   : int;
end;
begin
  if (aBagNr <= 0) OR (aBagPos <= 0) then
    RETURN -1;

  // Bag Position lesen
  RecBufClear(702);
  Bag.P.Nummer    # aBagNr;
  Bag.P.Position  # aBagPos;
  Erx # RecRead(702,1,0);
  if (Erx > _rOK) then begin
    if (Erx = _rLocked) then
      Error(001001,'Betriebsauftragsposition');
    else
      Error(001003,'Betriebsauftragsposition');  //  001003 :  vA # 'E:#%1%:Satz nicht gefunden!';
    RETURN -1;
  end;

   // BAG ok zum anhängen?
  RekLink(700,702,1,0);
  if ("Bag.Löschmarker" =  '*') then begin
    Error(702001,''); // 702001 :  vA # 'E:Position ist bereits abgeschlossen!';
    RETURN -1;
  end;

  // Passt Einsatztyp
  if ("BAG.P.Typ.1In-1OutYN" = true) then begin            // 1 zu 1 Geht über Einsatz
    Error(99,'Fertigung darf nicht eingefügt werden. Produktionstyp stimmt nicht');
    RETURN -1;
  end;

  if (BAG.P.Typ.VSBYN) then begin
    Error(99,'Fertigung darf nicht für VSB Arbeitsgänge angelegt werden');
    RETURN -1;
  end;

  // Fertigung einfügen
  RecLink(703,702,4,_RecLast);
  vFert   # Bag.F.Fertigung;

  RecBufClear(703);
  Bag.F.Nummer        # Bag.P.Nummer;
  Bag.F.Position      # Bag.P.Position;
  BAG.F.Anlage.Datum  # Today;
  BAG.F.Anlage.Zeit   # Now;
  BAG.F.Anlage.User   # gUserName;

  REPEAT
    vFert # Bag.F.Fertigung + 1;
    Bag.F.Fertigung # vFert;
    Erx # BA1_F_Data:Insert(0,'MAN');
  UNTIL (Erx = _rOK);

  if (BA1_F_Data:UpdateOutput(703) = false) then
    Error(99,'UpdateOutput(703) fehlgeschlagen');

  RETURN _rOK;

end;


//========================================================================
//  Replace(aBagBuf : handle) : int  +ERR
//  Ändert eine Betriebsauftragsfertigung
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Replace(aBuff : handle) : int
local begin
  Erx : int;
  vNr : int;
end;
begin
  if (aBuff <= 0) then
    RETURN -1;

  // Lesen und Sperren
  Bag.F.Nummer    # aBuff->Bag.F.Nummer;
  Bag.F.Position  # aBuff->Bag.F.Position;
  Bag.F.Position  # aBuff->Bag.F.Fertigung;
  Erx # RecRead(703,1,0 | _RecLock);
  if (Erx <> _rOK) then begin
    Error(001007,'Betriebsauftragsfertigung');
    RETURN -1;
  end;

  // Übergebene Daten übertragen
  RecBufCopy(aBuff,703);

  // Verknüpfte Daten ermitteln
  if (BAG.F.Auftragsnummer <> 0) then
    BAG.F.Kommission # AInt(BAG.F.Auftragsnummer)+'/'+AInt(BAG.F.Auftragspos);

  // Datensatz ändern
  Erx # BA1_F_Data:Replace(_recUnlock,'SOA');
  if (Erx <> _rOK) then begin
    Error(001012,'Betriebsauftragsposition');
    RETURN -1;
  end;

  if (BA1_F_Data:UpdateOutput(703) = false) then
    Error(99,'UpdateOutput(703) fehlgeschlagen');

  RETURN _rOK;

end;


//========================================================================
//  Delete(aBagBuf : handle) : int  +ERR
//  Löscht eine Betriebsauftragsfertigung
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Delete(aBagNr : int; aBagPos : int; aBagFert : int ) : int
local begin
  Erx : int;
  vOK : logic;
end;
begin
  if (aBagNr <= 0) OR (aBagPos <= 0) OR (aBagFert <= 0) then
    RETURN -1;

  // Lesen und Sperren
  Bag.F.Nummer    # aBagNr;
  Bag.F.Position  # aBagPos;
  Bag.F.Fertigung # aBagFert;
  Erx # RecRead(703,1,0);
  if (Erx <> _rOK) then begin
    Error(001007,'Betriebsauftragsfertigung');
    RETURN -1;
  end;

  vOK # BA1_F_Data:Delete();
  if (vOK) then
    RETURN _rOK;
  else
    RETURN -1;

end;


//========================================================================