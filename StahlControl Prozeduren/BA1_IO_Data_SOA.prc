@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_IO_Data_SOA
//                    OHNE E_R_G
//  Info      Enthält Implementierung der Serviceaufrufe für
//            Betriebsauftragseinsätze
//
//
//  09.03.2015  ST  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//  2022-12-19  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//    sub Insert(aBagNr : int; aBagPos : int; aEinsatztyp   : int;
//    sub InsertIdToPos(aBagNr : int; aSrcId : int; aDstBagPos   : int;);
//    sub InsertFertToPos(aBagNr : int; aSrcBagFPos : int; aSrcBagFFert : int; aDstBagPos : int) : int
//    sub InsertPosToPos(aBagNr : int; aSrcBagPos : int; aDstBagPos : int;) : int
//    sub Replace(aBuff : handle) : int
//    sub Delete(aBagNr : int; aIoID : int) : int
//    sub Clear(aBagNr : int; aPos : int; aTyp : alpha) : int
//    sub ClearInput(aBagNr : int; aPos : int) : int
//    sub ClearOutput(aBagNr : int; aPos : int) : intSUB Insert(aBagNr : int; aBagPos : int) : int
//
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen
@I:Def_SOA


//========================================================================
//  Insert() : int  +ERR
//  Fügt einen neuen theoretischen Betriebsauftragseinsatz ein
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Insert(
  aBagNr        : int;
  aBagPos       : int;
  aBuff         : int;
   ) : int
local begin
  Erx     : int;
  vIoId   : int;
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

  if (BAG.P.Typ.VSBYN) then begin
    Error(99,'Fertigung darf nicht für VSB Arbeitsgänge angelegt werden');
    RETURN -1;
  end;

  RekLink(828,702,8,0); //  Arbeitsgang lesen


  // IO-Einsatz anlegen
  RecLink(701,700,3,_RecLast);
  vIoId   # Bag.IO.ID;

  RecBufClear(701);
  RecbufCopy(aBuff,701);      // Übergebene Daten einlesen

  BAG.IO.Nummer         # Bag.P.Nummer;
  BAG.IO.NachBag        # Bag.P.Nummer;
  BAG.IO.NachPosition   # Bag.P.Position;
  BAG.IO.Materialtyp    # c_IO_Theo;

  BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.Out.GewN;   // Vorbelegung bei Theomaterial

  BAG.IO.Plan.In.Stk    # BAG.IO.Plan.Out.Stk ;
  BAG.IO.Plan.In.Gewn   # BAG.IO.Plan.Out.GewN;
  BAG.IO.Plan.In.GewB   # BAG.IO.Plan.Out.GewB;
  BAG.IO.Plan.In.Menge  # BAG.IO.Plan.Out.Meng;


  BAG.IO.MEH.In         # 'kg';
  BAG.IO.MEH.Out        # 'kg';//  2022-12-19  AH Arg.Meh;

  BAG.IO.Anlage.Datum   # Today;
  BAG.IO.Anlage.Zeit    # Now;
  BAG.IO.Anlage.User    # gUserName;

  REPEAT
    vIoId # Bag.IO.ID + 1;
    Bag.IO.ID # vIoId;
    Erx # BA1_IO_Data:Insert(0,'SOA')
  UNTIL (Erx = _rOK);


  if (BA1_F_Data:UpdateOutput(701) = false) then
    Error(99,'UpdateOutput(701) fehlgeschlagen');

/*
  if (BA1_F_Data:UpdateOutput(701)) then
    RETURN _rOK;
  else
    RETURN -1;
*/
  RETURN _rOK;

end;


//========================================================================
//  sub InsertIdToPos(...)
//  Verbindet eine Ausbringung mit einer Position
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub InsertIdToPos(
  aBagNr        : int;      //  BAG nummer
  aSrcId        : int;      //  Quell IO Id
  aDstBagPos   : int;       //  Ziel  Position
   ) : int
local begin
  Erx       : int;
  vIoId     : int;
  vBuff701  : int;
end;
begin
  if (aBagNr <= 0) OR (aSrcId <= 0) OR (aDstBagPos <= 0) then
    RETURN -1;

  // QuellEinsatz/Ausbringung lesen
  RecBufClear(701);
  Bag.IO.Nummer   # aBagNr;
  Bag.IO.ID       # aSrcId;

  Erx # RecRead(701,1,0);
  if (Erx > _rOK) then begin
    if (Erx = _rLocked) then
      Error(001001,'Betriebsauftragseinsatz');
    else
      Error(001003,'Betriebsauftragseinsatz');  //  001003 :  vA # 'E:#%1%:Satz nicht gefunden!';
    RETURN -1;
  end;
  vBuff701 # RekSave(701);

  // Zielposition lesen
  RecBufClear(702);
  Bag.P.Nummer    # aBagNr;
  Bag.P.Position  # aDstBagPos;
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

  if (BAG.P.Typ.VSBYN) then begin
    Error(99,'Fertigung darf nicht für VSB Arbeitsgänge angelegt werden');
    RETURN -1;
  end;


  // IO-Einsatz anlegen
  RecLink(701,700,3,_RecLast);
  vIoId   # Bag.IO.ID;

  RecBufClear(701);
  BAG.IO.Nummer       # aBagNr;

  BAG.IO.VonBAG       # vBuff701->BAG.IO.Nummer;
  BAG.IO.VonPosition  # vBuff701->BAG.IO.NachPosition;
  BAG.IO.VonFertigung # vBuff701->BAG.IO.NachFertigung;
  BAG.IO.VonID        # vBuff701->BAG.IO.ID;

  BAG.IO.NachBag      # Bag.P.Nummer;
  BAG.IO.NachPosition # Bag.P.Position;
  BAG.IO.Materialtyp  # c_IO_BAG;

  BAG.IO.Anlage.Datum  # Today;
  BAG.IO.Anlage.Zeit   # Now;
  BAG.IO.Anlage.User   # gUserName;

  REPEAT
    vIoId # Bag.IO.ID + 1;
    Bag.IO.ID # vIoId;
    Erx # BA1_IO_Data:Insert(0,'SOA')
  UNTIL (Erx = _rOK);

  if (BA1_F_Data:UpdateOutput(701) = false) then
    Error(99,'UpdateOutput(701) fehlgeschlagen');

  RETURN _rOK;
end;



//========================================================================
//  sub InsertFertToPos(...)
//  Verbindet eine Fertigung mit einer Position
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub InsertFertToPos(
  aBagNr        : int;      //  BAG nummer
  aSrcBagFPos   : int;      //  Quell Position
  aSrcBagFFert  : int;      //  Quell Fertigung
  aDstBagPos   : int;       //  Ziel  Position
   ) : int
local begin
  Erx     : int;
  vIoId   : int;
end;
begin
  if (aBagNr <= 0) OR (aSrcBagFPos <= 0) OR (aSrcBagFFert <= 0) OR (aDstBagPos <= 0) then
    RETURN -1;

  // Quellfertigung lesen
  RecBufClear(703);
  Bag.F.Nummer    # aBagNr;
  Bag.F.Position  # aSrcBagFFert;
  Bag.F.Fertigung # aSrcBagFFert;
  Erx # RecRead(703,1,0);
  if (Erx > _rOK) then begin
    if (Erx = _rLocked) then
      Error(001001,'Betriebsauftragsfertigung');
    else
      Error(001003,'Betriebsauftragsfertigung');  //  001003 :  vA # 'E:#%1%:Satz nicht gefunden!';
    RETURN -1;
  end;

  // Zielposition lesen
  RecBufClear(702);
  Bag.P.Nummer    # aBagNr;
  Bag.P.Position  # aDstBagPos;
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

  if (BAG.P.Typ.VSBYN) then begin
    Error(99,'Fertigung darf nicht für VSB Arbeitsgänge angelegt werden');
    RETURN -1;
  end;


  // IO-Einsatz anlegen
  RecLink(701,700,3,_RecLast);
  vIoId   # Bag.IO.ID;

  RecBufClear(701);
  BAG.IO.Nummer       # aBagNr;

  BAG.IO.VonBAG       # BAG.IO.Nummer;
  BAG.IO.VonPosition  # Bag.F.Position;
  BAG.IO.VonFertigung # Bag.F.Fertigung;

  BAG.IO.NachBag      # Bag.P.Nummer;
  BAG.IO.NachPosition # Bag.P.Position;
  BAG.IO.Materialtyp  # c_IO_BAG;

  BAG.IO.Anlage.Datum  # Today;
  BAG.IO.Anlage.Zeit   # Now;
  BAG.IO.Anlage.User   # gUserName;

  REPEAT
    vIoId # Bag.IO.ID + 1;
    Bag.IO.ID # vIoId;
    Erx # BA1_IO_Data:Insert(0,'SOA')
  UNTIL (Erx = _rOK);


  if (BA1_F_Data:UpdateOutput(701) = false) then
    Error(99,'UpdateOutput(701) fehlgeschlagen');

  RETURN _rOK;
end;




//========================================================================
//  sub InsertPosToPos(...)
//  Verbindet alle Fertigungen der Quellposition mit der
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub InsertPosToPos(
  aBagNr      : int;          // BA Nummer
  aSrcBagPos  : int;          // Quell Position
  aDstBagPos  : int;          // Ziel Position
   ) : int
local begin
  Erx   : int;
  vIoId : int;
  vErr : int;
end;
begin
  if (aBagNr <= 0) OR (aSrcBagPos <= 0) OR (aDstBagPos <= 0) then
    RETURN -1;

  //  für jede Fertigung der Urpsrungsposition, eine Fertigung in
  //  der Zielposition anlegen
  TRANSON;
  FOR   Erx # RecLink(703,702,4,_RecFirst)
  LOOP  Erx # RecLink(703,702,4,_RecNext)
  WHILE Erx = _rOK DO BEGIN
    vErr # InsertFertToPos(Bag.F.Nummer, Bag.F.Position, Bag.F.Fertigung, aDstBagPos);
    if (vErr < 0) then begin
      TRANSBRK;
      Error(010033,Aint(aBagNr) + '/' + Aint(aDstBagPos));
      BREAK;
    end;
  END;
  TRANSOFF;

  RETURN vErr;

end;



//========================================================================
//  Replace(aBagBuf : handle) : int  +ERR
//  Ändert einen Betriebsauftragseinsatz und berechnet die Ausbringungen neu
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

  if (aBuff->BAG.IO.AutoTeilungYN) AND (aBuff->BAG.IO.Teilungen <> 0) then begin
    Error(703006,aint(BAG.P.Position)); // 'W:Die manuell eingetragene Teilungsanzahl passt nicht zu den Vorgaben!';
    RETURN -1;
  end;


  // Lesen und Sperren
  Bag.IO.Nummer # aBuff->Bag.IO.Nummer;
  Bag.IO.ID     # aBuff->Bag.IO.ID;
  Erx # RecRead(701,1,0 | _RecLock);
  if (Erx <> _rOK) then begin
    Error(001007,'Betriebsauftragseinsatz');
    RETURN -1;
  end;

  // Übergebene Daten übertragen
  RecBufCopy(aBuff,701);

  // Verknüpfte Daten lesen
  RekLink(700,701,1,0); // Kopfdaten

  // Herkunft ermitteln
  RekLink(702,701,2,0); // Aus Position
  RekLink(703,701,3,0); // Aus Fertigung

  SOA_TRANSON;

  // Datensatz ändern
  Erx # BA1_IO_Data:Replace(_recUnlock,'SOA');
  if (Erx <> _rOK) then begin
    SOA_TRANSBRK;
    Error(001012,'Betriebsauftragseinsatz');
    RETURN -1;
  end;

  // Hier ggf. Updates durchführen: VSB Einträge, Outputs etc.
  if (BA1_F_Data:UpdateOutput(701) = false) then begin
    TRANSBRK;
    Error(701010    ,'Betriebsauftragseinsatz');      //  vA # 'E:Ausbringungsberechnung fehlgeschlagen!!!';
    RETURN -1;
  end;

  TRANSOFF;

  RETURN _rOK;
end;


//========================================================================
//  sub Delete(aBagNr : int; aIoID : int) + ERR
//  Löscht einen Betriebsauftragseinsatz
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Delete(aBagNr : int; aIoID : int) : int
local begin
  Erx : int;
end;
begin
  if (aBagNr <= 0) OR (aIoID <= 0) then
    RETURN -1;

  // Lesen und Sperren
  Bag.IO.Nummer    # aBagNr;
  Bag.IO.ID  # aIoID;
  Erx # RecRead(701,1,0);
  if (Erx <> _rOK) then begin
    Error(001007,'Betriebsauftragsfertigung');
    RETURN -1;
  end;

  TRANSON;

  Erx # BA1_IO_Data:Delete(_recUnlock,'SOA');
  if (Erx <> _rOK) then begin
    TRANSBRK;
    Error(010036,'Betriebsauftragseinsatz|'+Aint(aIoId));    //010036 :  vA # 'E:BAG %1%: Einsatz %2% konnte nicht gelöscht werden!';
    RETURN -1;
  end;

/*
  // Hier ggf. Updates durchführen: VSB Einträge, Outputs etc.
  if (BA1_F_Data:UpdateOutput(701) = false) then begin
    TRANSBRK;
    Error(701010    ,'Betriebsauftragseinsatz');      //  vA # 'E:Ausbringungsberechnung fehlgeschlagen!!!';
    RETURN -1;
  end;
*/
  TRANSOFF;

  RETURN _rOK;

end;



//========================================================================
//  sub Clear(aBagNr : int; aPos : int; aTyp : alpha) : int
//  Löscht alle Einsätze/Ausbringungen für die übergebene Betriebsauftragsposition
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub Clear(aBagNr : int; aPos : int; aTyp : alpha) : int
local begin
  Erx   : int;
  vErr  : int;
  vTypeLink : int;
end;
begin
  if (aBagNr <= 0) OR (aPos <= 0) then
    RETURN -1;

  // Position lesen
  Bag.P.Nummer    # aBagNr;
  Bag.P.Position  # aPos;
  Erx # RecRead(702,1,0);
  if (Erx <> _rOK) then begin
    Error(001007,'Betriebsauftragsposition');
    RETURN -1;
  end;

  // Input oder Output?
  case (StrCnv(aTyp,_StrLower)) of
    'input' : vTypeLink # 2;
    'output' : vTypeLink # 3;
    otherwise begin
      Error(001007,'Betriebsauftragsposition');
      RETURN -1;
    end;
  end;


  // Löschen
  vErr # _rOK;
  TRANSON;
  FOR   Erx # RecLink(701,702,vTypeLink,_RecFirst);
  LOOP  Erx # RecLink(701,702,vTypeLink,_RecNext);
  WHILE Erx = _rOK DO BEGIN

    vErr # Delete(Bag.IO.Nummer,Bag.IO.ID);
    if (vErr < _rOK) then begin
      TRANSBRK;
      BREAK;
    end;

  END;
  TRANSOFF;

  RETURN vErr;
end;


//========================================================================
//  sub ClearInput(...) + ERR
//  Alias für Clear(x,y,'input')
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub ClearInput(aBagNr : int; aPos : int) : int
begin
  RETURN Clear(aBagNr, aPos, 'Input');
end;

//========================================================================
//  sub ClearOutput(...) + ERR
//  Alias für Clear(x,y,'output')
//  SOA KOMPATIBEL ohne Meldungen
//========================================================================
sub ClearOutput(aBagNr : int; aPos : int) : int
begin
  RETURN Clear(aBagNr, aPos, 'Output');
end;




//========================================================================