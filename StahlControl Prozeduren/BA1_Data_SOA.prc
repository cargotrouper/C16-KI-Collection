@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Data_SOA
//                    OHNE E_R_G
//  Info      Enthält Implmentierung der Serviceaufrufe für
//            Betriebsauftragskopfdaten

//
//  02.03.2015  ST  Erstellung der Prozedur
//  06.02.2015  ST  "Insert()/Replace()/Delete()" hinzugefügt   Projekt 1326/412
//  04.04.2022  AH  ERX
//  07.07.2022  MR  Deadlockfix für Lib_Soa:ReadNummer in sub Insert()
//
//  Subprozeduren
//    SUB Insert() : int
//    SUB Replace(aBagBuf : handle) : int
//    SUB Delete(aBagNr : int) : int
//
//========================================================================
@I:Def_Global
@I:Def_BAG


//========================================================================
//  Insert() : int  +ERR
//  Fügt einen neuen Betriebsauftragskopf ein
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Insert(opt aAlsVorlage : logic) : int
local begin
  vNr : int;
  Erx : int;
end;
begin

  // Nummernkreis lesen und erhöhen
  if (aAlsVorlage) then begin
    //  [+] 07.07.2022 MR Deadlockfix
    Erx # Lib_Soa:ReadNummer('Betriebsauftrag-Vorlage' ,var vNr);
    if(Erx = _rOk) then begin
      Error(902002,'Betriebsauftrag'); // 'E:#%1%-Nummernkreis konnte nicht erhöht werden!!!';
      RETURN -1;
    end
  end
  else begin
    //  [+] 07.07.2022 MR Deadlockfix
    Erx # Lib_Soa:ReadNummer('BETRIEBSAUFTRAG',var vNr);
    if(Erx = _rOk) then begin
      Error(902002,'Betriebsauftrag'); // 'E:#%1%-Nummernkreis konnte nicht erhöht werden!!!';
      RETURN -1;
    end
    BAG.BuchungsAlgoNr  # Set.BA.BuchungAlgoNr;
  end;
  if (vNr <> 0) then
    Lib_Soa:SaveNummer();
  else begin
    Error(902002,'Betriebsauftrag'); // 'E:#%1%-Nummernkreis konnte nicht erhöht werden!!!';
    RETURN -1;
  end;

  Bag.Nummer        # vNr;
  BAG.VorlageYN     # aAlsVorlage;
  BAG.Anlage.Datum  # today;
  BAG.Anlage.Zeit   # now;
  BAG.Anlage.User   # gUsername;

  // Datensatz einfügen
  Erx # RekInsert(700,_recUnlock,'AUTO');
  if (Erx <> _rOK) then begin
    Error(700011,''); // 'E:Es konnte kein BA angelegt werden!';
    RETURN -1;
  end;

  RETURN _rOK;
end;


//========================================================================
//  Replace(aBagBuf : handle) : int  +ERR
//  Ändert einen Betriebsauftragskopf
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Replace(aBagBuf : handle) : int
local begin
  vNr : int;
  Erx : int;
end;
begin
  if (aBagBuf <= 0) then
    RETURN -1;

  // Lesen und Sperren
  Bag.Nummer # aBagBuf->Bag.Nummer;
  Erx # RecRead(700,1,0 | _RecLock);
  if (Erx <> _rOK) then begin
    Error(001007,'Betriebsauftrag'); // 'E:#%1%-Nummernkreis konnte nicht erhöht werden!!!';
    RETURN -1;
  end;

  // Übergebene Daten übertragen
  RecBufCopy(aBagBuf,700);

  // Datensatz einfügen
  Erx # RekReplace(700,_recUnlock,'SOA');
  if (Erx <> _rOK) then begin
    Error(001012,'Betriebsauftrag');
    RETURN -1;
  end;

  RETURN _rOK;
end;


//========================================================================
//  sub Delete(aBagNr : int) : int
//  Löscht einen Betriebsauftragskopf indem die Löschinformationen gefüllt
//  werden.
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Delete(aBagNr : int) : int
local begin
  vNr : int;
  Erx : int;
end;
begin
  if (aBagNr <= 0) then
    RETURN -1;

  // Lesen und Sperren
  Bag.Nummer # aBagNr;
  Erx # RecRead(700,1,0 | _RecLock);
  if (Erx <> _rOK) then begin
    Error(001003,'Betriebsauftrag'); // 'E:#%1%:Satz nicht gefunden!';
    RETURN -1;
  end;

  if ("BAG.Löschmarker" = '*') then begin
    // Entlöschen
    "BAG.Löschmarker" # '';
    "BAG.Lösch.Datum" # 0.0.0;
    "BAG.Lösch.Zeit"  # 0:0;
    "BAG.Lösch.User"  # '';
  end else begin
    // Löschen
    "BAG.Löschmarker" # '*';
    "BAG.Lösch.Datum" # today;
    "BAG.Lösch.Zeit"  # now;
    "BAG.Lösch.User"  # gUserName;
  end;

  // Datensatz speichern
  Erx # RekReplace(700,_recUnlock,'SOA');
  if (Erx <> _rOK) then begin
    Error(001012,'Betriebsauftrag');
    RETURN -1;
  end;

  RETURN _rOK;
end;



//========================================================================