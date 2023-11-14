@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_FM_Data_SOA
//                  OHNE E_R_G
//  Info
//    Enthält Funktionen, die zum Fertigemelden ohne GUI (SOA, EDI, Filescanner)
//    genutzt werden können
//
//
//  21.04.2022  ST  Erstellung der Prozedur
//  14.07.2022  MR  Fix damit Materialien die eig zu einer Fertigmeldung bzw. Ausbringung gehalten werden nicht als Einsatz verwechselt werden
//  2022-12-20  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//    sub ReadBagData(aMatNr : int; aBagFertigung : int; var a707Output : int;) : logic
//    sub FMData_Prepare(var a707Output : int) : logic
//    sub FMData_FillFromBuf(var aBuf707 : int) : logic
//    TODO sub FMData_FillFromXMLNode(aNode : int) : logic
//    TODO sub FMData_FillFromCSV(aLine : alpha(4000)) : logic
//    sub FMData_Validate() : logic
//    sub FMData_Finalize() : logic
//
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG

define begin
  LogActive     : true
  Log(a)        : if (LogActive) then Lib_Soa:Dbg(CnvAd(today) + ' ' + cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+ '['+__PROC__+':'+aint(__LINE__)+']' + ':' + a);
  LogErr(a) :    begin  Log(a); Error(99,a); end;
end;


//========================================================================
//  sub ReadBagData(aMatNr : int; aBagFertigung : int) : logic
//
//  Liest die benötigten Betriebsauftragsdaten für die Fertigmeldung
//========================================================================
sub ReadBagData(aMatNr : int; aBagNummer  : int; aBagFertigung : int; var a701Output : int;) : logic
local begin
  Erx : int;
  v701Input :  int;
end
begin
Log('BAG Daten lesen START');

  // Material lesen
  Erx # Mat_Data:Read(aMatNr);
  Log(cnvai(Erx));
  if (Erx <> 200) then begin
    Error(99,Translate('Einsatzmaterialnummer nicht gefunden: Mat ') + Aint(aMatNr));
    RETURN false;
  end;
Log('... Material gelesen');
  
  //[+] 14.07.22 MR Fix damit Materialien die eig zu einer Fertigmeldung bzw. Ausbringung gehalten werden nicht als Einsatz verwechselt werden
  // BA-Input holen   // 3 mit Materialtyp 200
  FOR Erx # RecLink(701,200,29,_RecFirst)
  LOOP Erx # RecLink(701,200,29,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if(aBagNummer <> BAG.IO.Nummer)then CYCLE
    
    if(BAG.IO.VonBAG = 0) then break;
  
  END;
    
//  // BA-Input holen   // 3 mit Materialtyp 200
//  Erx # RecLink(701,200,29,_recFirst);
//  if (Erx>_rLocked) then begin
//    Error(99,Translate('Kein gültiger BA-Einsatz gefunden: Mat. ') + Aint(aMatNr));
//    RETURN false;
//  end;
Log('... BA-Input gelesen');
    debugx(cnvai(BAG.IO.Nummer))
  // BA-Kopf holen
  Erx # RecLink(700,701,1,_RecFirst);
  if (Erx>_rLocked) then begin
    Error(99,Translate('Kein gültiger BA-Kopf zu Mat:  ') +Aint(aMatNr));
    RETURN false;
  end;
Log('... BA-Kopf gelesen');

  // BA-Pos holen
  Erx # RecLink(702,701,4,_RecFirst);
  if (Erx>_rLocked) then begin
    Error(99,Translate('Kein gültiger BA-Pos zu Mat: ') +Aint(aMatNr));
    RETURN false;
  end;
Log('... BA-Pos gelesen');
  
  // Restkarte holen
  Erx # RecLink(200,701,11,_recFirst);
  if (Erx>_rLocked) then begin
    Error(99,Translate('Kein gültiges Restmaterial gefunden: Mat ') + Aint(aMatNr));
    RETURN false;
  end;
Log('... Restkarte gelesen');

  // Fertigung holen
  Bag.F.Nummer    # BAG.P.Nummer;
  BAG.F.Position  # BAG.P.Position;
  Bag.F.Fertigung # aBagFertigung;
  Erx # RecRead(703,1,0);
  if (Erx>_rLocked) then begin
    Error(99,Translate('Keine gültige Fertigung: ' + Aint(aBAGFertigung)));
    RETURN false;
  end;
Log('... Fertigung gelesen');

  // BA-Output holen   // 3 mit Materialtyp 200
  v701Input # RekSave(701);
  FOR   Erx # RecLink(a701Output  ,703,4,_recFirst);
  LOOP  Erx # RecLink(a701Output  ,703,4,_recNext);
  WHILE Erx = _rOK DO BEGIN
    if (a701Output->BAG.IO.Materialtyp = c_IO_BAG) then
      BREAK;
  END;
  RekRestore(v701Input);
  if (Erx > _rLocked) then begin
    Error(99,Translate('Output nicht gefunden!'));
    RETURN false;
  end;
Log('... BA-Output gelesen');
          
  RekLink(828,702,8,0);     // Arbeitsgangdaten holen
  RekLink(704,703,6,0);     // Verpackung lesen
  RekLink(818,704,1,0);     // Verwiegungsart
    
Log('BAG Daten lesen ENDE');

  RETURN true;
end;

//========================================================================
//  sub ReadBagData(aBagFertigung : int) : logic
//
//  Liest die benötigten Betriebsauftragsdaten für die Fertigmeldung
//========================================================================
sub ReadBAGDataPaket(aBagFertigung : int;) : logic
local begin
  Erx : int;
end
begin

  // BA-Kopf holen
  Erx # RecLink(700,701,1,_RecFirst);
  if (Erx>_rLocked) then begin
    Error(99,Translate('Kein gültiger BA-Kopf zu Mat:  '));
    RETURN false;
  end;
  Log('... BA-Kopf gelesen');

  // BA-Pos holen
  Erx # RecLink(702,701,4,_RecFirst);
  if (Erx>_rLocked) then begin
    Error(99,Translate('Kein gültiger BA-Pos zu Mat: '));
    RETURN false;
  end;
  Log('... BA-Pos gelesen');
  
  // Fertigung holen
  Bag.F.Nummer    # BAG.P.Nummer;
  BAG.F.Position  # BAG.P.Position;
  Bag.F.Fertigung # aBagFertigung;
  Erx # RecRead(703,1,0);
  if (Erx>_rLocked) then begin
    Error(99,Translate('Keine gültige Fertigung: ' ));
    RETURN false;
  end;
  Log('... Fertigung gelesen');
  
  
  RekLink(828,702,8,0);     // Arbeitsgangdaten holen
  RekLink(704,703,6,0);     // Verpackung lesen
  RekLink(818,704,1,0);     // Verwiegungsart
  
  Log('BAG Daten lesen ENDE');
  RETURN true;
end;


//========================================================================
//  sub PrepareFMData(aLine : alpha(1000)) : logic
//
//  Belegt einen Datensatz
//========================================================================
sub FMData_Prepare(var a707Output : int) : logic
begin
  // Vorbelegungen:
  RecBufClear(707);
  BA1_FM_Data:Vorbelegen();

  BAG.FM.Nummer         # myTmpNummer;
  BAG.FM.Position       # BAG.P.Position;
  BAG.FM.Fertigung      # BAG.F.Fertigung;
  BAG.FM.InputBAG       # BAG.P.Nummer;
  BAG.FM.InputID        # BAG.IO.ID;
  BAG.FM.BruderID       # a707Output->BAG.IO.ID;
  BAG.FM.Verwiegungart  # BAG.Vpg.Verwiegart;
  BAG.FM.MEH            # a707Output->BAG.IO.MEH.In;    // 2022-12-19 AH  ArG.MEH;
  BAG.FM.MaterialTyp    # c_IO_Mat;
  BAG.FM.Status         # 1;
  BAG.FM.Datum          # today;
 
  RETURN true;
end;


//========================================================================
//  sub PrepareFMDataPaket(aLine : alpha(1000)) : logic
//
//  Belegt einen Datensatz
//========================================================================
sub FMData_PreparePaket() : logic
begin
  // Vorbelegungen:
  RecBufClear(707);
  BA1_FM_Data:Vorbelegen();

  BAG.FM.Nummer         # myTmpNummer;
  BAG.FM.Position       # BAG.P.Position;
  BAG.FM.Fertigung      # BAG.F.Fertigung;
  BAG.FM.InputBAG       # BAG.P.Nummer;
  BAG.FM.Verwiegungart  # BAG.Vpg.Verwiegart;
  BAG.FM.MEH            # 'kg';//2022-12-19 AH  ArG.MEH;
  BAG.FM.MaterialTyp    # c_IO_Mat;
  BAG.FM.Status         # 1;
  BAG.FM.Datum          # today;
 
  RETURN true;
end;


//========================================================================
//  sub PrepareFMData(aLine : alpha(1000)) : logic
//
//  Extrahiert die Daten aus der Fertigmeldungsdatei
//========================================================================
sub FMData_FillFromBuf(var aBuf707 : int) : logic
local begin
  vParseErr : logic;

  vTds  : int;
  vFld  : int;

  vTdsMax  : int;
  vFldMax  : int;
end
begin
    
  // Nicht vorbelegte gefüllte Werte aus Buffer übernehmen
  vTdsMax # FileInfo(707,_FileSbrCount);
  FOR   vTds # 1
  LOOP  inc(vTds)
  WHILE vTds<=vTdsMax  DO BEGIN
  
    vFldMax # SbrInfo(707,vTds, _SbrFldCount);
    FOR   vFld # 1
    LOOP  inc(vFld)
    WHILE vFld<=vFldMax  DO BEGIN
      
      case FldInfo(707,vTds,vFld,_FldType) of
        _TypeAlpha    : if (FldAlpha( 707,vTds,vFld) <> '')       then CYCLE;
        _TypeBigInt   : if (FldBigint(707,vTds,vFld) <> 0)        then CYCLE;
        _TypeDate     : if (FldDate(  707,vTds,vFld) <> 00.00.00) then CYCLE;
        _TypeTime     : if (FldTime(  707,vTds,vFld) <> 00:00)    then CYCLE;
        _TypeFLoat    : if (FldFloat(  707,vTds,vFld) <> 0.0)     then CYCLE;
        _TypeInt      : if (FldInt  (  707,vTds,vFld) <> 0)       then CYCLE;
        _TypeWord     : if (FldWord (  707,vTds,vFld) <> 0)       then CYCLE;
        _TypeLogic    : if (FldLogic(  707,vTds,vFld) <> null)    then CYCLE;
      end;
            
      FldCopy(aBuf707,vTds,vFld,707,vTds,vFld);
    END;
 
  END;
  
  RETURN true;
end;



//========================================================================
//  sub PrepareFMData(aLine : alpha(1000)) : logic
//
//  Extrahiert die Daten aus der Fertigmeldungsdatei
//========================================================================
sub FMData_FillFromXMLNode(aNode : int) : logic
local begin
  vParseErr : logic;
end
begin
  TODO('FMData_FillFromXMLNode');
/*
  BAG.FM.Gewicht.Netto    # CnvFa(Str_Token(aLine,';', 4));
  ...
  ...
 
*/
  RETURN vParseErr;
end;


//========================================================================
//  sub PrepareFMData(aLine : alpha(1000)) : logic
//
//  Extrahiert die Daten aus der Fertigmeldungsdatei
//========================================================================
sub FMData_FillFromCSV(aLine : alpha(4000)) : logic
local begin
  vParseErr : logic;
end
begin
  TODO('FMData_FillFromCSV');
/*
  BAG.FM.Gewicht.Netto    # CnvFa(Str_Token(aLine,';', 4));
  ...
  ...
 
*/
  RETURN vParseErr;
end;



//========================================================================
//  sub FMData_Validate(aLine : alpha(1000)) : logic
//
//  Extrahiert die Daten aus der Fertigmeldungsdatei
//========================================================================
sub FMData_Validate() : logic
local begin
  
end
begin
  if ("BAG.FM.Stück" <= 0) then begin
    ERROR(99,'Stückzahl muss angegeben werden');
  end;
  
  /*
  todo weiter Plausis hier
  
  */
  
  RETURN (Errlist=0);
end;




//========================================================================
//  sub PrepareFMData(aLine : alpha(1000)) : logic
//
//  Extrahiert die Daten aus der Fertigmeldungsdatei
//========================================================================
sub FMData_Finalize() : logic
local begin
  vL        : float;
end
begin

  vL # "BAG.FM.Länge";
  if (vL=0.0) then begin
    vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Netto, "BAG.FM.Stück", BAG.IO.Dicke, BAG.IO.Breite, Wgr.Dichte, "Wgr.TränenKGproQM");
    if(BAG.FM.Gewicht.Netto = 0.0) then
      vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Brutt, "BAG.FM.Stück", BAG.IO.Dicke, BAG.IO.Breite, Wgr.Dichte, "Wgr.TränenKGproQM");
  end;

  If (BAG.P.Aktion <> c_BAG_AbLaeng)or (BAG.FM.Menge =0.0) then begin
    if (BAG.FM.MEH='qm') then
      BAG.FM.Menge # BAG.FM.Breite * Cnvfi("BAG.FM.Stück") * vL / 1000000.0;
    if (BAG.FM.MEH='Stk') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück");
    if (BAG.FM.MEH='kg') then
      BAG.FM.Menge # Bag.FM.Gewicht.Netto;
    if (BAG.FM.MEH='t') then
      BAG.FM.Menge # Bag.FM.Gewicht.Netto / 1000.0;
    if (BAG.FM.MEH='m') or (BAG.FM.MEH='lfdm') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück") * vL / 1000.0;
  End;
  BAG.FM.Menge  # Rnd(BAG.FM.Menge , Set.Stellen.Menge);
 
 
  RETURN true;
end;




//========================================================================