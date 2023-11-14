@A++
//===== Business-Control =================================================
//
//  Prozedur    Fibu_Datev_V3
//                  OHNE E_R_G
//  Info
//      Funktionen zum Export von
//        - Erlösen
//        - Eingangsrechnungen
//        - Kreditoren/Debitoren (= SC Adressen)
//        - Import von OPOS Excelexporten der Datev
//      laut Datev Schnittstellen-Entwicklungsleitfaden 3.0 Stand 07/2013
//
//  30.07.2013  ST  Erstellung der Prozedur
//  28.07.2015  ST  Refactoring + Featureerweiterung
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//
//    sub Erl_Export()
//    sub Ere_Export()
//    sub _WritePos(...)
//    sub GetGegenKonto(aTyp : alpha) : int
//
//    sub Adr_Export()
//    sub _Adr_ExportLine(...)
//
//    sub Ofp_Import()
//    sub _KillOPZahlungen();
//    sub _CreateOPZahlung(aRest : float);
//
//    sub _GetPath(aSubPath : alpha) : alpha
//    sub _CreateFile(aFullPath : alpha) : int;
//    sub _WriteHeader(aFileHdl : int; aDatenKat : int; aFormatversion : int; aWJJahrBegin : date; opt aDatumVon : date;opt aDatumBis : date;opt aBezeichnn : alpha;)
//    sub GetWirtschaftsJahrBeginn() : date

//========================================================================
@I:Def_Global

define begin
  cFilePrefix       : 'EXTF_'
  cFileExtention    : '.csv'

  Write(a)          : FSIWrite(vFile, StrAdj(a,_StrBegin | _StrEnd) + StrChar(59));
  WriteNewLine      : FSIWrite(vFile, StrChar(13) + StrChar(10) );

  WriteEmpty        : FSIWrite(vFile, StrChar(59));
  WriteEmptyLast    : FSIWrite(vFile, '');

  WriteEmptyText    : FSIWrite(vFile, '""'+StrChar(59));
  WriteEmptyTextLast : FSIWrite(vFile, '""');

  WriteHead(a)      : FSIWrite(vFile, StrAdj(Lib_Strings:Strings_DOS2WIN(a),_StrBegin | _StrEnd)  + StrChar(59));
  WriteHeadLast(a)  : FSIWrite(vFile, StrAdj(Lib_Strings:Strings_DOS2WIN(a),_StrBegin | _StrEnd));

  WriteText(a,b)    : FSIWrite(vFile, '"' + StrAdj(StrCut(Lib_Strings:Strings_DOS2WIN(a),1,b),_StrBegin | _StrEnd) + '"' + StrChar(59));
  WriteTextLast(a,b): FSIWrite(vFile, '"' + StrAdj(StrCut(Lib_Strings:Strings_DOS2WIN(a),1,b),_StrBegin | _StrEnd) + '"');

  WriteZahl(a)      : FSIWrite(vFile, StrAdj(Aint(a),_StrBegin | _StrEnd)+ StrChar(59));
  WriteDatumKurz(a) : FSIWrite(vFile, Cnvai(DateDay(a),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) + StrChar(59))
  WriteDatum(a)     : FSIWrite(vFile, Str_ReplaceAll(Lib_Strings:DateForSort(a),'.','') + StrChar(59))
  WriteNum(a,b)     : FSIWrite(vFile, StrAdj(ANum(a,b),_StrBegin | _StrEnd) + StrChar(59));

  cBeraterNr        : 12345       // Maximal 7 Stellen
  cMandantNr        : 98765       // Maximal 5 Stellen
  cSachkontenlaenge : 4           // 4 oder 8   (4= 5stellige Deb/KredNr, 8= 8stellige Deb/Kred)
  cKuerzel          : 'SC'        // Dikatkürzel

  cWJStartTag       : 1           // z.B. 1. Tag des Monats
  cWJStartMonat     : 1           // z.B. 7 für Juli
  cGueltigVon       : '01011900'
  cGueltigBis       : '31122099'

  cErloeseMitEinzelKonten : true

  // ----------------------------------------------------------------------------------------
  //   Import OPOS
  // ----------------------------------------------------------------------------------------
  c_EXCEL_CSV_CONVERTER : gFsiClientPath + '\dlls\ExcelToCSVConverter.exe'
  READ(a,b)       :  begin vEingelesen  # vEingelesen  + FSIRead(a, b); b # StrAdj(b,_StrBegin | _StrEnd); end;

end;
local begin

end;


declare GetWirtschaftsJahrBeginn(opt aBezugsDatum : date) : date
declare _GetPath(aSubPath : alpha) : alpha
declare _CreateFile(aFullPath : alpha) : int;
declare _CreateOPZahlung(aRest : float);
declare _KillOPZahlungen();
declare _WriteHeader(aFileHdl : int; aDatenKat : int; aFormatversion : int; aWJJahrBegin : date; opt aDatumVon : date;opt aDatumBis : date; opt aBezeichnn : alpha;)
declare _Adr_ExportLine(aFileHdl : int; aTyp : alpha)
declare _WritePos(aFileHdl : int; opt aTyp : alpha)
declare GetGegenKonto(aTyp : alpha) : int




//========================================================================
//  Erl_Export                TEST: call Fibu_Datev_V3:Erl_Export
//
//========================================================================
sub Erl_Export()
local begin
  Erx           : int;
  vPfad         : alpha(200);
  vName         : alpha;

  vVonDat       : date;
  vBisDat       : date;

  vItem         : int;
  vMFile        : Int;
  vMID          : Int;

  vFile         : int;
  vCount        : int;

  vWJBeginn     : date;
end;
begin

  if (Lib_Mark:Count(450) = 0) then begin
    Msg(99,'Es wurden keine Datensätze zur Übergabe markiert.',_WinIcoError,_WinDialogOK,1);
    RETURN;
  end;

  vPfad # _GetPath('');
  if (vPfad = '') then
    RETURN;

  // --------------------------------------------------------------------------
  // Abrechnungszeitraum ermitteln
  vVonDat # 1.1.2033;
  vBisDat # 1.1.1990;
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then
      CYCLE;

    RecRead(450,0,0,vMID);          // Satz holen

    // Keine Stornobuchungen exportieren
    CASE (Erl.Rechnungstyp) of
      c_Erl_StornoVK      ,
      c_Erl_StornoREKOR   ,
      c_Erl_StornoBel_KD  ,
      c_Erl_StornoGut     ,
      c_Erl_StornoBel_LF  ,
      c_Erl_StornoBoGut :
      CYCLE;
    end;


    If (Erl.Rechnungsdatum>vBisDat) then vBisDat # Erl.Rechnungsdatum;
    If (Erl.Rechnungsdatum<vVonDat) then vVonDat # Erl.Rechnungsdatum;
  END;

  if (vVonDat = 1.1.2033) AND (vBisDat = 1.1.1990) then begin
    msg(99,'Fehler: Die Markierung enthält keine exportierbaren Datensätze.',0,0,0);
    RETURN;
  end;

  // Datei öffenen und HEader schreiben
  vFile # _CreateFile(vPfad + cFilePrefix + 'SCErloese' + cFileExtention);
  if (vFile <= 0) then
    RETURN;


  // Datenkategorie 21 = Buchungsstapel
  // Versionsnummer Buchungsstapel = 2
  vWJBeginn # GetWirtschaftsJahrBeginn();
  _WriteHeader(vFile, 21, 2, vWJBeginn, vVonDat, vBisDat, 'Stahl Control Erlöse');

  // -------------------------------------------------------------
  // - Datendatei: Buchungssätze anhängen
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then
      CYCLE;

    RecRead(450,0,0,vMID);          // Satz holen


    // Keine Stornobuchungen exportieren
    CASE (Erl.Rechnungstyp) of
      c_Erl_StornoVK      ,
      c_Erl_StornoREKOR   ,
      c_Erl_StornoBel_KD  ,
      c_Erl_StornoGut     ,
      c_Erl_StornoBel_LF  ,
      c_Erl_StornoBoGut :
      CYCLE;
    end;


    vCount # vCount + 1;

    RecLink(100,450,5,_RecFirsT);         // Kunde holen
    if (cnvia(Adr.KundenFibuNr)=0) then Adr.KundenFibuNr # aint(Adr.KundenNr);

    Erx # RecLink(460,450,2,_recFirst);     // OP-holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(470,450,11,_recFirst);    // ~OP-holen
      if (Erx>_rLocked) then RecBufClear(470);
      RecBufCopy(470,470);
    end;

    RekLink(816,460,8,_recFirst);     // Zahlungsbed.-holen
    RekLink(813,450,10,0);            // AdressSteuerschlüssel lesen

    RekLink(814,450,3,_recFirst);     // Währung holen
    if (Wae.Fibu.Code='') then Wae.Fibu.Code # "Wae.Kürzel";

    if (cErloeseMitEinzelKonten) then begin

      // Kontierungen loopen
      FOR   Erx # RecLink(451,450,1,_RecFirst)
      LOOP  Erx # RecLink(451,450,1,_RecNext)
      WHILE (Erx = _rOK) DO BEGIN

        RekLink(813,451,10,0);      // Steuerschlüssel lesen

        // Daten pro Erlös
        _WritePos(vFile,'ERLK');

      END;

    end else begin

      // Nur Rechnung ohne Kontierung exportieren
      _WritePos(vFile,'ERE');

    end;

    // Nächste Rechnung
  END;


  // -------------------------------------------------------------
  // - Datendatei: Datei schließen und ggf. Export Verbuchen
  vFile->FsiClose();

//  if (Msg(99,'Fibudatum setzen?',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin

    // als übergeben markieren --------------------------------------------------------------
    TRANSON;
    FOR vItem # gMarkList->CteRead(_CteFirst);
    LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
    WHILE (vItem > 0) do begin

      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile<>450) then
        CYCLE;

      RecRead(450,0,0,vMID);          // Satz holen
      if (Erl.StornoRechNr<>0) then
        CYCLE;

      RecRead(450,1,_recLock);
      Erl.Fibudatum # Today;
      RekReplace(450,0,'AUTO');
    END;
    TRANSOFF;

// end;

  Msg(450102,cnvai(vCount)+'|'+vPfad + cFilePrefix + 'SCErloese' + cFileExtention,0,0,0);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
end;


//========================================================================
//  Ere_Export
//
//========================================================================
sub Ere_Export()
local begin
  Erx           : int;
  vPfad         : alpha(200);
  vName         : alpha;

  vVonDat       : date;
  vBisDat       : date;

  vItem         : int;
  vMFile        : Int;
  vMID          : Int;

  vFile         : int;
  vCount        : int;

  vWJBeginn     : date;
  vProg         : int;
end;
begin

  if (Lib_Mark:Count(560) = 0) then begin
    Msg(99,'Es wurden keine Datensätze zur Übergabe markiert.',_WinIcoError,_WinDialogOK,1);
    RETURN;
  end;


  vPfad # _GetPath('');
  if (vPfad = '') then
    RETURN;

/*
  // Abrechnungsbereich wird von Hesse durch Datumsbereich eingegeben
  if (Dlg_Standard:DatumVonBis('Datumsbereich', var vVonDat, var vBisDat) = false) then begin
    RETURN;
  end;
*/

// --------------------------------------------------------------------------
  // Abrechnungszeitraum ermitteln
  vVonDat # 1.1.2033;
  vBisDat # 1.1.1990;
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>560) then
      CYCLE;

    RecRead(560,0,0,vMID);          // Satz holen
    if (ERe.InOrdnung = false) or (ERe.JobAusstehendJN) then
      CYCLE;

    If (Ere.Rechnungsdatum>vBisDat) then vBisDat # Ere.Rechnungsdatum;
    If (Ere.Rechnungsdatum<vVonDat) then vVonDat # Ere.Rechnungsdatum;
  END;

  if (vVonDat = 1.1.2033) AND (vBisDat = 1.1.1990) then begin
    msg(99,'Fehler: Die Markierung enthält keine exportierbaren Datensätze.',0,0,0);
    RETURN;
  end;

  // Datei öffenen und HEader schreiben
  vFile # _CreateFile(vPfad + cFilePrefix + 'SCEingangsrech' + cFileExtention);
  if (vFile <= 0) then
    RETURN;


  // Datenkategorie 21 = Buchungsstapel
  // Versionsnummer Buchungsstapel = 2
  vWJBeginn # GetWirtschaftsJahrBeginn(vBisDat);
  _WriteHeader(vFile, 21, 2, vWJBeginn, vVonDat, vBisDat, 'Stahl Control Export');

  // -------------------------------------------------------------
  // - Datendatei: Buchungssätze anhängen
  vProg # Lib_Progress:Init('Exportiere',RecInfo(560,_RecCount));
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin

    if (vProg->Lib_Progress:Step() = false) then
      BREAK;

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>560) then
      CYCLE;

    RecRead(560,0,0,vMID);          // Satz holen

    if (ERe.InOrdnung = false) or (ERe.JobAusstehendJN) then
      CYCLE;

    RekLink(814,560,6,0);     // Währung holen
    RekLink(100,560,5,0);     // Lieferant holen
    if (cnvia(Adr.LieferantFibuNr)=0) then
      Adr.LieferantFibuNr # aint(Adr.LieferantenNr);

    if (Wae.Fibu.Code='') then Wae.Fibu.Code # "Wae.Kürzel";

    // Zugeordnete Kontierungen für Eingangsrechnung lesen
    FOR   Erx # RecLink(551,560,3,_RecFirst)
    LOOP  Erx # RecLink(551,560,3,_RecNext)
    WHILE (Erx = _rOK)  DO BEGIN
      vCount # vCount + 1;

      RekLink(813,551,4,0);     // Steuerschlüssel lesen

       // Kontierung exportieren
      _WritePos(vFile,'EREK');

    END;

  END;


  // -------------------------------------------------------------
  // - Datendatei: Datei schließen und ggf. Export Verbuchen
  vFile->FsiClose();

  vProg->Lib_Progress:Term();


  TRANSON;
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>560) then
      CYCLE;

    RecRead(560,0,0,vMID);          // Satz holen

    if (ERe.InOrdnung = false) or (ERe.JobAusstehendJN) then
      CYCLE;

    RecRead(560,1,_recLock);
    ERe.FibuDatum # Today;
    RekReplace(560,0,'AUTO');
  END;
  TRANSOFF;

  Msg(450102,cnvai(vCount)+'|'+vPfad + cFilePrefix + 'SCEingangsrech' + cFileExtention,0,0,0);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
end;


//========================================================================
//  sub _WritePos(aFileHdl  : int;  opt aKontierungen : logic)
//    Gibt einen DatevPosition aus
//========================================================================
sub _WritePos(
      aFileHdl    : int;
  opt aTyp        : alpha)
local begin
  i               : int;
  vFile           : int;

  vUmsatz         : float;
  vSHKennz        : alpha(1);
  vWAEKurs        : float;
  vBasisUmsatz    : float;
  vGegenkonto     : int;
  vSachPersKonto  : int;
  vBuchungsSchl   : alpha;
  vBelegDatum     : date;
  vBelegNummer    : int;
  vSteuerschl     : int;
  vBelegFeld2     : alpha;
  vBuchungstext   : alpha;
end;
begin
  vFile # aFileHdl;

  // --------------------------------------------------------------
  //  Daten ermitteln
  // --------------------------------------------------------------
  vGegenkonto # GetGegenKonto(aTyp);

  // Erlöse / Erlöskontierungen
  if (aTyp = 'ERL') OR (aTyp = 'ERLK') then begin
    vBuchungstext   # Adr.Stichwort;
    vBelegFeld2   # Cnvai(DateDay(OfP.Zieldatum),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(OfP.Zieldatum),_FmtNumLeadZero,0,2) +  Cnvai(DateYear(OfP.Zieldatum)-100,_FmtNumLeadZero,0,2);
    vSachPersKonto  # cnvia(Adr.KundenFibuNr);
    vBelegdatum     # Erl.Rechnungsdatum;
    vBelegNummer    # Erl.Rechnungsnr;
    vBelegFeld2     # Cnvai(DateDay(OfP.Zieldatum),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(OfP.Zieldatum),_FmtNumLeadZero,0,2) +  Cnvai(DateYear(OfP.Zieldatum)-100,_FmtNumLeadZero,0,2);

    if (Erl.Rechnungstyp = c_Erl_VK) OR (Erl.Rechnungstyp = c_Erl_SammelVK) then
      vSHKennz # 'S';
    else
      vSHKennz # 'H';

    // -----------------------------------
    // Erlöskonten
    if (aTyp = 'ERLK') then begin
      vWAEKurs       # "Erl.K.Währungskurs";
      vBasisUmsatz   # Abs(Erl.K.BetragW1) + Rnd((Abs(Erl.K.BetragW1) / 100.0 * StS.Prozent),2);
      vUmsatz        # vBasisUmsatz;
    end
    // -----------------------------------
    // Erlössumme
    else if (aTyp = 'ERL') then begin
      // Datensatz auf Basis einer kompletten Rechnung exportieren
      vWAEKurs      # "Erl.Währungskurs";
      vBasisUmsatz  #  Abs(Erl.BruttoW1);
      vUmsatz       # Abs(Erl.BruttoW1);
    end;

  end  // EO Erlöse

  // -----------------------------------
  // Eingangsrechnungskontierung
  else if (aTyp = 'EREK') then begin
    vWAEKurs        # "Ere.Währungskurs";
    vBasisUmsatz    # Abs(Rnd(Vbk.K.BetragW1 + (Vbk.K.BetragW1 / 100.00 * StS.Prozent),2));
    vUmsatz         # Abs(Rnd(Vbk.K.BetragW1 + (Vbk.K.BetragW1 / 100.00 * StS.Prozent),2));

    vSachPersKonto  # vGegenkonto;        // KONTO
    vGegenkonto     # Vbk.K.Gegenkonto;   // GEGENKONTO ohne Buchungsschl
    vBelegDatum     # ERe.Rechnungsdatum;
    vBelegNummer    # Ere.Nummer;
    vBelegFeld2     # '';
    ERe.Rechnungsnr # StrCnv(ERe.Rechnungsnr,_StrLetter);
    ERe.Rechnungsnr # StrCut(StrAdj(ERe.Rechnungsnr,_StrEnd),1,12);
    vBuchungstext   # ERe.LieferStichwort + ' '  + ERe.Rechnungsnr;

    if (ERe.Rechnungstyp = c_Erl_Bel_LF) then
      vSHKennz      # 'S';
    else
      vSHKennz      # 'H';

  end;


  // Datev erlaubt keine "Null" - Buchungen
  if (vUmsatz = 0.0) then
    RETURN;



  // --------------------------------------------------------------
  //  Datenanpassungen
  // --------------------------------------------------------------
  if  (vWAEKurs = 0.0) then
    vWAEKurs  # 1.0;

  // --------------------------------------------------------------
  //  Export
  // --------------------------------------------------------------
  WriteNum(   vUmsatz,2);                     //   1   Umsatz (ohne Soll /Haben-Kz)
  WriteText(  vSHKennz,1);                    //   2   Soll /Haben-Kennzeichen
  WriteText(  Wae.Fibu.Code,3);               //   3   WKZ Umsatz
  WriteNum(   vWAEKurs,6);                    //   4   Kurs
  WriteNum(   vBasisUmsatz,2 );               //   5   Basis-Umsatz
  WriteText(  'EUR',3);                       //   6   WKZ Basis-Umsatz
  WriteZahl(  vSachPersKonto);              //   7   Sach/Personenn Konto
  WriteZahl(  vGegenkonto);                   //   8   Gegenkonto
  WriteText(  StS.Fibu.Code,2);               //   9   BU Schlüssel
  WriteDatumKurz(vBelegdatum);                //  10   Belegdatum
  WriteText(  Aint(vBelegNummer),12);      //  11   Rechnungs/Belegdatum
  WriteText(  vBelegfeld2,12);              //  12   Belegfeld2 (Fälligkeitsdatum für OPOS)
  WriteEmpty;                                 //  13   Skonto (nur bei Zahlungen zulässig)
  WriteText(  vBuchungstext,60);              //  14   Buchungstext
  WriteEmptyText;                             //  15   Postensperre
  WriteEmptyText;                             //  16   DiverseAdressnummer
  WriteEmpty;                                 //  17   Geschäftspartnerbank
  WriteEmpty;                                 //  18   Sachverhalt
  WriteEmpty;                                 //  19   Zinssperre
  WriteEmptyText;                             //  20   Beleglink

  // Beleginfos 1-8                           // 21 - 36
  FOR i # 1 LOOP inc(i) WHILE i<=8 DO BEGIN
    WriteEmptyText;                           //  21   Beleginfo– Art
    WriteEmptyText;                           //  22   Beleginfo– Inhalt
  END;

  WriteEmptyText;                             //  37    KOST1– Kostenstelle
  WriteEmptyText;                             //  38    KOST2– Kostenstelle
  WriteEmpty;                                 //  39    KOSTMenge
  WriteText(Adr.USIdentNr,15);                //  40    EU-Landu. UStID
  WriteEmpty;                                 //  41    EU-Steuersatz
  WriteEmptyText;                             //  42    Abw.Versteuerungsart
  WriteEmpty;                                 //  43    SachverhaltL+L
  WriteEmpty;                                 //  44    FunktionsergänzungL
  WriteEmpty;                                 //  45    BU 49Hauptfunktionstyp
  WriteEmpty;                                 //  46    BU 49Hauptfunktionsnummer
  WriteEmpty;                                 //  47    BU 49Funktionsergänzung

  // Beleginfos 1-8                           // 48 - 87
  FOR i # 1 LOOP inc(i) WHILE i<=20 DO BEGIN
    WriteEmptyText;                           //  48  Zusatzinformation-Art
    WriteEmptyText;                           //  49  Zusatzinformation Inhalt
  END;

  WriteEmpty;                                 //  88  Stück       / nur für BU 49
  WriteEmpty;                                 //  89  Gewicht     / nur für BU 49
  WriteEmpty;                                 //  90  Zahlweise
  WriteEmptyText;                             //  91  Forderungsart
  WriteEmpty;                                 //  92  Veranlagungsjahr
  WriteEmptyLast;                             //  93  ZugeordneteFälligkeit

  WriteNewLine;
end;

//========================================================================
//  GetGegenKonto() : alpha;
//    Gibt das passende Gegenkonto zu einem Vorgang zurück
//========================================================================
sub GetGegenKonto(aTyp : alpha) : int
local begin
  vCheck  : alpha;
  vGegenKonto : alpha;
end
begin

  CASE aTyp OF
    // ---------------------------------------------------------------------
    // - Typ  Erlös = nur Rechnugnsdaten ohne Positionsbezug -> Adressdaten
    'ERL' : begin
      if ("Erl.Adr.Steuerschl" <> 1) then
        RETURN 8125
      else
        RETURN 8440;

    end; // 'EO ERL'


    // ---------------------------------------------------------------------
    // - Typ  Erlöskonto genaue Zusammensetzung mit Steuerschlüssel und Waren-
    //        gruppe
    'ERLK' : begin

// Beispiel:
/*
      vCheck #  CnvAi(Erl.K.Steuerschl,_FmtNumNoGroup | _FmtNumLeadZero, 0 , 5) + '_'+
                CnvAi(Erl.K.Warengruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0 , 5);

      Case vCheck of
        '01001_2000',
        '01001_2200' : RETURN 8125;

        otherwise    RETURN 8400;
      end;
*/

      // Standardmäßig werden die Erlösgruppen der Warengruppe genutzt
      // Auftragsart hat Vorrang
      CASE (Erl.K.Steuerschl) OF

        // DE Voll Inland
        1001 : begin

          // Warengruppenkonto für Frachten, etc.
          if ("Erl.K.Erlöskonto" <> 0) then
            vGegenKonto #  '8' + Aint("Erl.K.Erlöskonto");

          // Standardkonto, wenn nicht anders angegeben
          if (vGegenkonto = '') then
            vGegenKonto # '8400';

          case Erl.Rechnungstyp of
            c_Erl_StornoVK,
            c_Erl_StornoREKOR,
            c_Erl_StornoGut  : vGegenKonto # '8400';

            c_Erl_BOGUT,
            c_Erl_REKOR,
            c_Erl_Gut        : vGegenKonto # '8720';
          end;

        end;


        // DE Voll EG
        1002 : begin
          vGegenkonto # '8125';

          case Erl.Rechnungstyp of
            c_Erl_StornoVK,
            c_Erl_StornoREKOR,
            c_Erl_StornoGut  : vGegenKonto # '8125';

            c_Erl_BOGUT,
            c_Erl_REKOR,
            c_Erl_Gut        : vGegenKonto # '8705';
          end;

        end;

        // DE Voll Ausland
        1003  : begin
          vGegenkonto # '8150';

        end;


        // DE Inland, Schrott, Steuerumkehr
        3001,4001 : begin
          vGegenkonto # '8337';
        end;
      END; // CASE (Erl.K.Steuerschl) OF

      return CnvIa(vGegenkonto);
    end; // EO 'ERLK'


    'EREK' : begin
      if (cnvia(Adr.LieferantFibuNr) = 0) then
        Adr.LieferantFibuNr # aint(Adr.LieferantenNr);
      RETURN cnvia(Adr.LieferantFibuNr);
    end;

  END;


  RETURN 0;
end;


//========================================================================
//  sub Adr_Export()
//      Steuert den Adressexport
//========================================================================
sub Adr_Export()
local begin
  vPfad         : alpha(200);
  vFile         : int;
  i             : int;
  vCount        : int;
  vAdrVerbuchList : int;
  vA            : alpha(1000);
  vItem         : int;
  vMFile        : Int;
  vMID          : Int;
  vProgress     : int;
end;
begin

  if (Lib_Mark:Count(100) = 0) then begin
    Msg(99,'Es wurden keine Adressen zur Übergabe markiert.',_WinIcoError,_WinDialogOK,1);
    RETURN;
  end;

  vPfad # _GetPath('');
  if (vPfad = '') then
    RETURN;


  // Datei öffenen und HEader schreiben
  vFile # _CreateFile(vPfad + cFilePrefix + 'SC_Debitoren_Kreditoren' + cFileExtention);
  if (vFile <= 0) then
    RETURN;


  // Datenkategorie 16 = Debitoren/Kreditoren
  // Versionsnummer Debitoren / Kreditoren = 2
  _WriteHeader(vFile, 16, 2, GetWirtschaftsJahrBeginn());

  vAdrVerbuchList # CteOpen(_CteList);

  vProgress # Lib_Progress:Init('Export',Lib_Mark:Count(100));

  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) DO BEGIN

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>100) then
      CYCLE;

    RecRead(100,0,0,vMID);          // Satz holen

   if (vProgress->Lib_Progress:Step() = false) then begin
      vAdrVerbuchList->CteClose();
      vFile->FsiClose();
      vProgress->Lib_Progress:Term();
      RETURN;
    end;


    //  Ausgrenzungen
    if (Adr.KundenNr = 0) AND (Adr.LieferantenNr = 0) then
      CYCLE;

    // Adressdatenaufbereitung
    if (cnvia(Adr.KundenFibuNr) = 0) then
      Adr.KundenFibuNr  # aint(Adr.KundenNr);

    if (cnvia(Adr.LieferantFibuNr) = 0) then
      Adr.LieferantFibuNr  # aint(Adr.LieferantenNr);


    if (Adr.KundenNr <> 0) then begin
      // Debitorenexport
      _Adr_ExportLine(vFile, 'KUNDE');
      vAdrVerbuchList->CteInsertItem('K'+Aint(Adr.Nummer),Adr.Nummer,'K');
      vCount # vCount + 1;
    end;
    if (Adr.LieferantenNr <> 0) then begin
      // Kreditorenexport
      _Adr_ExportLine(vFile, 'LIEFERANT');
      vAdrVerbuchList->CteInsertItem('L'+Aint(Adr.Nummer),Adr.Nummer,'L');
      vCount # vCount + 1;
    end;

  END;

  vProgress->Lib_Progress:Term();

  // -------------------------------------------------------------
  // - Datendatei: Datei schließen und ggf. Export Verbuchen
  vFile->FsiClose();

  vProgress # Lib_Progress:Init('Export',Lib_Mark:Count(100));
  if (vCount > 0) then begin
    vA # 'Exportdatum setzen?';
//    if (Msg(99,vA,_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then begin

      // als übergeben markieren --------------------------------------------------------------
      TRANSON;
      FOR vItem # vAdrVerbuchList->CteRead(_CteFirst);
      LOOP vItem # vAdrVerbuchList->CteRead(_CteNext,vItem);
      WHILE (vItem > 0) do begin

        RecRead(100,0,0,vItem->spID);          // Satz holen

        RecRead(100,1,_recLock);

        if (vItem->spCustom = 'K') then
          Adr.Fibudatum.Kd # Today;

        if (vItem->spCustom = 'L') then
          Adr.Fibudatum.Lf # Today;

        RekReplace(100,0,'MAN');
      END;
      TRANSOFF;

//    end;
  end;


  vAdrVerbuchList->CteClose();
  vProgress->Lib_Progress:Term();

  Msg(99,cnvai(vCount)+' Kreditoren und Debitoren wurden exportiert.',0,0,0);

end;
//========================================================================
//  sub _Adr_ExportLine(aFileHdl : int)
//      Exportiert den Übergenen Adressdatensatz
//========================================================================
sub _Adr_ExportLine(aFileHdl : int; aTyp : alpha)
local begin
  vFile : int;
  i     : int;

  vKontonummer : int;

  vEULand  : alpha;
  vEUUstId : alpha;
  vSprachnr : int;

end
begin
  vFile   # aFileHdl;

  RekLink(110,100,15,0);  // Vertreter 1 lesen
  RekLink(812,100,10,0);  // Land lesen

  if (Lnd.ISOCode = '') then begin
    CASE "Lnd.Kürzel" OF
      'D','DE' :  Lnd.ISOCode # 'DE'; // Deutschland
      'F','FR' :  Lnd.ISOCode # 'FR'; // Frankreich
      'E','EN' :  Lnd.ISOCode # 'GB'; // England
      'S','ES' :  Lnd.ISOCode # 'ES'; // Spanisch
      'I','IT' :  Lnd.ISOCode # 'IT'; // Italienisch
      otherwise begin
        Msg(99,'Das ISO Länderkennzeichen für "' + Lnd.Name.L1 + '" konnte nicht ermittelt werden',_WinIcoWarning,_WinDialogOk,1);
      end;
    END;
  end;


  case aTyp of
    'KUNDE' : begin
      vKontonummer # cnvia(Adr.KundenFibuNr);
    end;

    'LIEFERANT' : begin
      vKontonummer # cnvia(Adr.LieferantFibuNr);
    end;
  end;

  if (Adr.USIdentNr <> '') then begin
    vEULand  # StrCut(Adr.USIdentNr,1,2);
    vEUUstId # StrCut(Adr.USIdentNr,3,99);
  end;

  if (Adr.Postfach <> '') then
    Adr.PLZ # Adr.Postfach.PLZ;

  vSprachnr # 0;
  CASE Adr.Sprache OF
    'D','DE' :  vSprachnr # 1;    // Deutsch
    'F','FR' :  vSprachnr # 4;    // Französisch
    'E','EN' :  vSprachnr # 5;    // Englisch
    'S','ES' :  vSprachnr # 10;   // Spanisch
    'I','IT' :  vSprachnr # 19;   // Italienisch
  END;

  // Datensatz für Kreditoren/Debitoren generieren
  WriteZahl(vKontonummer );                   //   1    Kontonummer
  WriteText(Adr.Name,50);                     //   2    Name(Adressattyp Unternehmen)
  WriteText(Adr.Gruppe,50);                   //   3    Unternehmensgegenstand
  WriteText('',30);                           //   4    Name (Natürliche Person)
  WriteText('',30);                           //   5    Vorname (Natürliche Person)
  WriteText('',50);                           //   6    NAme (Kein Adressattyp)
  WriteText('2',1);                           //   7    Adressattyp 1 = Natürliche Pseron, 2 = Unternehmen
  WriteText(Adr.Stichwort,15);                //   8    Kurzbezeichnung
  WriteText(vEULand,2);                       //   9    EU-Land
  WriteText(vEUUstId,13);                     //  10    EU-UStID
  WriteText(Adr.Anrede,30);                   //  11    Anrede
  WriteText('',25);                           //  12    Titel / Akad.Grad, nicht relevant
  WriteText('',15);                           //  13    Adelstitel, nicht relevant
  WriteText('',14);                           //  14    Namensvorsatz, nicht relevant
  WriteText('',3);                            //  15    Adressart
                                              //        STR = Straße
                                              //        PF = Postfach
                                              //        GK = Großkunde
                                              //        Wird die Adressart nicht übergeben, wird sie automatisch in
                                              //        Abhängigkeit zu den übergebenen Feldern (Straße oder Postfach)
                                              //        gesetzt.
  WriteText("Adr.Straße",36);                 //  16    Straße
  WriteText(Adr.Postfach,10);                 //  17    Postfach
  WriteText(Adr.PLZ,10);                      //  18    Postleitzahl
  WriteText(Adr.Ort,30);                      //  19    Ort
  WriteText(Lnd.ISOCode,2);                   //  20    Land
  WriteText('',50);                           //  21    Versandzusatz
  WriteText('',36);                           //  22    Adresszusatz
  WriteText('',30);                           //  23    AbweichendeAnrede
  WriteText('',50);                           //  24    Abw.Zustellbezeichnung1
  WriteText('',36);                           //  25    Abw.Zustellbezeichnung2
  WriteZahl(1);                               //  26    Kennz.Korrespondenzadresse 1= Kennzeichnung Korrespondenzadresse
  Write(cGueltigVon);                         //  27    AdresseGültig von
  Write(cGueltigBis);                         //  28    AdresseGültig bis
  WriteText(Adr.Telefon1,60);                 //  29    Telefon
  WriteText('',40);                           //  30    Bemerkung(Telefon)
  WriteText('',60);                           //  31    TelefonGeschäftsleitung
  WriteText('',40);                           //  32    Bemerkung(TelefonGL)
  WriteText(Adr.eMail,60);                    //  33    E-Mail
  WriteText('',40);                           //  34    Bemerkung(E-Mail)
  WriteText(Adr.Website,60);                  //  35    Internet
  WriteText('',40);                           //  36    Bemerkung(Internet)
  WriteText(Adr.Telefax,60);                  //  37    Fax
  WriteText('',40);                           //  38    Bemerkung(Fax)
  WriteText('',60);                           //  39    Sonstige
  WriteText('',40);                           //  40    Bemerkung(Sonstige)

  // Bankdaten  1-2                           // 41 - 95
  WriteText(Adr.Bank1.BLZ,8);                 //  41    Bankleitzahl
  WriteText(Adr.Bank1.Name,30);               //  42    Bankbezeichnung
  Write(Adr.Bank1.Kontonr);                   //  43    Bank-Kontonummer
  WriteText(Lnd.ISOCode,2);                   //  44    Länderkennzeichen
  WriteText(Adr.Bank1.IBAN,32);               //  45    IBAN-Nr.
  WriteText('',1);                            //  46    IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
  WriteText(Adr.Bank1.BIC.SWIFT,11);          //  47    SWIFTCode
  WriteText('',70);                           //  48    Abw. Kontoinhaber
  WriteZahl(0);                               //  49    Kennz.Hauptbankverb. Ja = 1, nein = 0
  Write(cGueltigVon);                         //  50    Bankverb. Gültig von
  Write(cGueltigBis);                         //  51    Bankverb. Gültig bis

  if (Adr.Bank2.Name <> '') then begin
    WriteText(Adr.Bank2.BLZ,8);               //  52    Bankleitzahl
    WriteText(Adr.Bank2.Name,30);             //  53    Bankbezeichnung
    Write(Adr.Bank2.Kontonr);                 //  54    Bank-Kontonummer
    WriteText(Lnd.ISOCode,2);                 //  55    Länderkennzeichen
    WriteText(Adr.Bank2.IBAN,32);             //  56    IBAN-Nr.
    WriteText('',1);                          //  57    IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
    WriteText(Adr.Bank2.BIC.SWIFT,11);        //  58    SWIFTCode
    WriteText('',70);                         //  59    Abw. Kontoinhaber
    WriteZahl(0);                             //  60    Kennz.Hauptbankverb. Ja = 1, nein = 0
    Write(cGueltigVon);                       //  61    Bankverb. Gültig von
    Write(cGueltigBis);                       //  62    Bankverb. Gültig bis
  end else begin
    WriteText('',8);                          //  52    Bankleitzahl
    WriteText('',30);                         //  53    Bankbezeichnung
    Write('');                                //  54    Bank-Kontonummer
    WriteText('',2);                          //  55    Länderkennzeichen
    WriteText('',32);                         //  56    IBAN-Nr.
    WriteText('',1);                          //  57    IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
    WriteText('',11);                         //  58    SWIFTCode
    WriteText('',70);                         //  59    Abw. Kontoinhaber
    Write('');                                //  60    Kennz.Hauptbankverb. Ja = 1, nein = 0
    Write('');                                //  61    Bankverb. Gültig von
    Write('');                                //  62    Bankverb. Gültig bis
  end;

  // Bankdaten  3-5                           //   63 - 95
  FOR i # 3 LOOP inc(i) WHILE i<=5 DO BEGIN
    WriteText('',8);                          //  41    Bankleitzahl
    WriteText('',30);                         //  42    Bankbezeichnung
    Write('');                                //  43    Bank-Kontonummer
    WriteText('',2);                          //  44    Länderkennzeichen
    WriteText('',32);                         //  45    IBAN-Nr.
    WriteText('',1);                          //  46    IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
    WriteText('',11);                         //  47    SWIFTCode
    WriteText('',70);                         //  48    Abw. Kontoinhaber
    Write('');                                //  49    Kennz.Hauptbankverb. Ja = 1, nein = 0
    Write('');                                //  50    Bankverb. Gültig von
    Write('');                                //  51    Bankverb. Gültig bis
  END;

  Write('');                                  //  96    Leerfeld
  WriteText(Adr.Briefanrede, 100);            //  97    Briefanrede
  WriteText('',50);                           //  98    Grußformel
  WriteText(Aint(Adr.KundenNr),15);           //  99    Kundennummer
  WriteText(Adr.Steuernummer,20);             //  100   Steuernummer

  if (vSprachnr <> 0) then                    //  101   Sprache
    WriteZahl(vSprachnr);                     //          1 = deutsch
  else                                        //          4 = französisch
    Write('');                                //          5 = englisch
                                              //          10 = spanisch
                                              //          19 = italienisch

  WriteText('',40);                           //  102   Ansprechpartner
  WriteText(Ver.Name,40);                     //  103   Vertreter
  WriteText(Adr.Sachbearbeiter,40);           //  104   Sachbearbeiter
  Write('');                                  //  105   Diverse-Konto   Zahl  1=ja 0=nein
  Write('');                                  //  106   Ausgabeziel     Zahl  1=Druck, 2 = Telefax, 3=E-Mail
  Write('');                                  //  107   Währungssteuerung Zahl 0 = Zahlungen in Eingabewährung, 2 = Ausgabe in EUR
  Write('');                                  //  108   Kreditlimit(Debitor)          Num,0
  Write('');                                  //  109   Zahlungsbedingung             Zahl
  Write('');                                  //  110   Fälligkeitin Tagen(Debitor)   Zahl
  Write('');                                  //  111   Skonto in Prozent(Debitor)    ZAhl

  // Skontodaten  1-5                         // 112 - 120
  FOR i # 1 LOOP inc(i) WHILE i<=5 DO BEGIN
    Write('');                                //        Kreditoren-Ziel (Tage)        Zahl
    if (i <> 3) then   // !!! ACHTUNG BUG IN DATEV Doku
      Write('');                                //        Kreditoren-Skonto (%)         Num,2
  END;

  WriteZahl(0);                               //  121   Mahnung
                                              //          0 = Keine Angaben
                                              //          1 = 1. Mahnung
                                              //          2 = 2. Mahnung
                                              //          3 = 1.+ 2. Mahnung
                                              //          4 = 3. Mahnung
                                              //          5 = (nicht vergeben)
                                              //          6 = 2.+3. Mahnung
                                              //          7 = 1.,2. +3. Mahnung
                                              //          9 = keine Mahnung
  Write('');                                  //  122   Kontoauszug
                                              //          1 = Kontoauszug für alle Posten
                                              //          2 = Auszug nur dann, wenn ein Posten mahnfähig ist
                                              //          3 = Auszug für alle mahnfälligen Posten
                                              //          9 = kein Kontoauszug
  Write('');                                  //  123   Mahntext1  Zahl Leer  = keinen Mahntext ausgewählt
  Write('');                                  //  124   Mahntext2       1 = Textgruppe 1 ...
  Write('');                                  //  125   Mahntext3       9 = Textgruppe 9
  Write('');                                  //  126   Kontoauszugstext Zahl
                                              //          Leer = keine Kontoauszugstext ausgewählt
                                              //          1 = Kontoauszugtext 1
                                              //          …
                                              //          8 = Kontoauszugtext 8
                                              //          9 = Kein Kontoauszugstext
  Write('');                                  //  127   MahnlimitBetrag  Num,2
  Write('');                                  //  128   Mahnlimit%       Num,2
  Write('');                                  //  129   Zinsberechnung   Zahl
                                              //          0 = MPD-Schlüsselung gilt
                                              //          1 = Fester Zinssatz
                                              //          2 = Zinssatz über Staffel
                                              //          9 = Keine Berechnung für diesen Debitor
  Write('');                                  //  130   Mahnzinssatz 1  Num,2
  Write('');                                  //  131   Mahnzinssatz 2  Num,2
  Write('');                                  //  132   Mahnzinssatz 3  Num,2
  WriteText('',1) ;                           //  133   Lastschrift     !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
  //WriteZahl(0) ;                              //  133   Lastschrift     !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
                                              //          Leer bzw. 0 = keine Angaben, es gilt die MPD-Schlüsselung
                                              //          1 = Einzellastschrift mit einer Rechnung
                                              //          2 = Einzellastschrift mit mehreren Rechnungen
                                              //          3 = Sammellastschrift mit einer Rechnung
                                              //          4 = Sammellastschrift mit mehreren Rechnungen
                                              //          5 = Datenträgeraustausch mit einer Rechnung
                                              //          6 = Datenträgeraustausch mit mehreren Rechnungen
                                              //          7 = (nicht vergeben)
                                              //          8 = (nicht vergeben)
                                              //          9 = kein Lastschriftverfahren bei diesem Debitor
  WriteText('',1);                            //  134   Verfahren Zahl  !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
//  Write('');                                  //  134   Verfahren Zahl
                                              //          0 = Einzugsermächtigung
                                              //          1 = Abbuchungsverfahren

  Write('');                                  //  135   Mandantenbank Zahl

  WriteText('',1);                            //  136   Zahlungsträger
  //WriteZahl(0);                             //          !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
                                              //          Leer bzw. 0 = keine Angaben, es gilt die MPD-Schlüsselung
                                              //          1 = Einzelüberweisung mit einer Rechnung
                                              //          2 = Einzelüberweisung mit mehreren Rechnungen
                                              //          3 = Sammelüberweisung mit einer Rechnung
                                              //          4 = Sammelüberweisung mit mehreren Rechnungen
                                              //          5 = Einzelscheck
                                              //          6 = Sammelscheck
                                              //          7 = Datenträgeraustausch mit einer Rechnung
                                              //          8 = Datenträgeraustausch mit mehreren Rechnungen
                                              //          9 = keine Überweisungen, Schecks

  // Individuell 1-15                         //  137 - 151
  FOR i # 1 LOOP inc(i) WHILE i<=15 DO BEGIN
    WriteText('',40);                         //        Indiv. Feld
  END;

  WriteText('',30);                           //  152   Abweichende Anrede(Rechnungsadresse)
  WriteText('',3);                            //  153   Adressart (Rechnungsadresse)
                                              //        STR = Straße
                                              //        PF = Postfach
                                              //        GK = Großkunde
                                              //        Wird die Adressart nicht übergeben, wird sie automatisch in
                                              //        Abhängigkeit zu den übergebenen Feldern (Straße oder Postfach)
                                              //        gesetzt.
  WriteText('',36);                           //  154   Straße Rechnungsadresse
  WriteText('',10);                           //  155   Postfach Rechnungsadresse
  WriteText('',10);                           //  156   Postleitzahl Rechnungsadresse
  WriteText('',30);                           //  157   Ort Rechnungsadresse
  WriteText('',2);                            //  158   Land Rechnungsadresse
  WriteText('',50);                           //  159   Versandzusatz Rechnungsadresse
  WriteText('',36);                           //  160   Adresszusatz Rechnungsadresse
  WriteText('',50);                           //  161   Abw.Zustellbezeichnung1 Rechnungsadresse
  WriteText('',36);                           //  162   Abw.Zustellbezeichnung2 Rechnungsadresse
  Write(cGueltigVon);                         //  163   AdresseGültig von Rechnungsadresse
  Write(cGueltigBis);                         //  164   AdresseGültig bis Rechnungsadresse

  // Bankdaten  6-10                                        // 165 - 219
  FOR i # 6 LOOP inc(i) WHILE i<=10 DO BEGIN
    WriteText('',8);                          //  165   Bankleitzahl
    WriteText('',30);                         //  166   Bankbezeichnung
    Write('');                                //  167   Bank-Kontonummer
    WriteText('',2);                          //  168   Länderkennzeichen
    WriteText('',32);                         //  169   IBAN-Nr.
    WriteText('',1);                          //  170   IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
    //WriteZahl(0);                              //  170   IBAN-Nr. Korrekt = 1
    WriteText('',11);                         //  171   SWIFTCode
    WriteText('',70);                         //  172   Abw. Kontoinhaber
    Write('');                                //  173   Kennz.Hauptbankverb. Ja = 1, nein = 0
    Write('');                                //  174   Bankverb. Gültig von
    Write('');                                //  175   Bankverb. Gültig bis
  END;

  WriteTextLast('',15);                       //  220  Nummer Fremdsystem

  WriteNewLine;
end;


//========================================================================
//  sub OfP_Import()
//      Importiert die Offenen Posten aus einer XLS Datei
//========================================================================
sub Ofp_Import()
local begin
  Erx           : int;
  // Benutzeranzeige
  vDia          : int;
  vMsg          : int;
  vProgress     : int;

  // Import Technik
  vPfad         : alpha(1000);
  vOposFile     : alpha(1000);
  vFile         : int;
  vMax          : int;
  vPos          : int;
  vEingelesen   : int;
  vA            : alpha(4096);

  // Importierte Nutzdaten
  vKndBuchungsnr  : alpha;//int;
  vOposnr         : int;
  vBetrag         : float;
  vSteuer         : float;
  vBetragSH       : alpha;
  vTmp            : alpha;

  // BUchungsdaten
  vListOffeneOP : int;
  vItem         : int;
  vListAdrExtOP : int;
  vItemAdr      : int;
  vBetragNetto  : float;
end;
begin

  // Converter vorhanden?
  vPfad         # c_EXCEL_CSV_CONVERTER;
  if (Lib_FileIO:FileExists(c_EXCEL_CSV_CONVERTER) = false) then begin
    Msg(99,Translate('Excelkonverter nicht gefunden!'),_WinIcoError,_WinDialogOk,0);
    RETURN;
  end;

  // Datei auswählen
  vPfad # Lib_FileIO:FileIO(_WINCOMFILEOPEN,gMDI,Set.Fibu.Pfad,'Excel-Dateien |*.xls;*.xlsx');
  if (vPfad = '') then
    RETURN;

  // Datei Konvertieren
  vDia # WinOpen('Dlg.Pause',_WinOpenDialog);
  vMsg # Winsearch(vDia,'Label1');
  vMsg->wpcaption # 'Konvertiere: ' + vPfad;
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenterScreen);//, gFrmMain);

  vOposFile # Set.Fibu.Pfad + 'temp_oposimport';
  if (SysExecute(c_EXCEL_CSV_CONVERTER,vPfad + ' ' + vOposFile,_ExecWait | _ExecHidden) < 0) then begin
    Msg(99,Translate('Konvertierung fehlgeschlagen!'),_WinIcoError,_WinDialogOk,0);
    RETURN;
  end;
  Winclose(vDia);


  // ----------------------------------------------------------------
  // Opos File importieren
  vOposFile # Set.Fibu.Pfad + 'temp_oposimport' + '.1.csv'; // Erstes Tabellenblatt

  vFile # FSIOpen(vOposFile, _FsiStdRead);
  if (vFile<=0) then begin
    Msg(99,'Datei nicht lesbar',_WinIcoError,_WinDialogOk,0);
    RETURN;
  end;

  vMax # FsiSize(vFile);
  vPos # FsiSeek(vFile);

  vProgress # Lib_Progress:Init('Import Offene Posten Datei',vMax);
  vListOffeneOP # CteOpen(_CteList);

  // Zeile 1 und 2  überspringen
  FSIMark(vFile, 10);   /* LF */
  READ(vFile,vA);
  READ(vFile,vA);

  WHILE (true) DO BEGIN

    if (vProgress->Lib_Progress:StepTo(vEingelesen) = false) then begin
      FSIClose(vFile);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    READ(vFile,vA); //  Zeile einlesen
    if (vA  = '') then
      BREAK;

    vTmp # Str_TOken(vA,';',2);                     //  2  - Debitorennr
    if (CnvIa(vTmp) <> 0) then
    vKndBuchungsnr  # vTmp;
//      vKndBuchungsnr  # CnvIa(vTmp);
    vOposnr       # CnvIa(Str_TOken(vA,';',4));       //  4  - Rechnungsnummer
    vBetrag       # CnvFa(Str_TOken(vA,';',9));       //  9  - Saldo
    vBetragSH     # StrCut(Str_TOken(vA,';',10),2,1); // 10  - SOll Habenkennzeichen
    vSteuer       # CnvFa(Str_TOken(vA,';',20));     //  20  - Steuer %

    // OP Merken
    //vListOffeneOP->CteInsertItem(Aint(vOposnr),vOposnr,vBetragSH+Anum(vBetrag,2)+ '|' + Aint(vKndBuchungsnr)+'|'+Anum(vSteuer,2));
    vListOffeneOP->CteInsertItem(Aint(vOposnr),vOposnr,vBetragSH+Anum(vBetrag,2)+ '|' + vKndBuchungsnr+'|'+Anum(vSteuer,2));

  END;

  FSIClose(vFile);
  FsiDelete(vOposFile);

  // AB hier sind alle noch offenen OPs eingelesen

  // ----------------------------------------------------------------------------
  // Kunden OPs zurücksetzen
  // ----------------------------------------------------------------------------
  vMax # RecInfo(100,_RecCount);
  vProgress->Lib_Progress:Reset('Löschung Fremd OPs',vMax);

  FOR   Erx # RecRead(100,1,_RecFirst)
  LOOP  Erx # RecRead(100,1,_RecNext)
  WHILE Erx = _rOK DO BEGIN
    if (vProgress->Lib_Progress:Step() = false) then begin
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    if (Adr.Fin.SummeOPB.Ext = 0.0) then
      CYCLE;

    if (RecRead(100,1,_RecLock) = _rOK) then begin

      Adr.Fin.SummeOP.Ext   # 0.0;
      Adr.Fin.SummeOPB.Ext  # 0.0;

      if (RekReplace(100,_recUnlock,'MAN') <> _rOK) then
        Msg(99,Translate('Adresse ' + Adr.Stichwort+ ' konnte nicht gespeichert werden.'),_WinIcoError,_WinDialogOk,0);

    end else
      Msg(99,Translate('Adresse ' + Adr.Stichwort+ ' konnte nicht gesperrt werden.'),_WinIcoError,_WinDialogOk,0);

  END;


  // ----------------------------------------------------------------------------
  // Offene Posten durchlaufen
  // ----------------------------------------------------------------------------

  vMax # RecInfo(460,_RecCount);
  vProgress->Lib_Progress:Reset('Verbuchung Offene Posten',vMax);

  FOR   Erx # RecRead(460,1,_RecFirst)
  LOOP  Erx # RecRead(460,1,_RecNext)
  WHILE Erx = _rOK DO BEGIN
    if (vProgress->Lib_Progress:Step() = false) then begin
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    if ("OfP.Löschmarker" <> '') then
      CYCLE;

    // ist Offner Posten noch in importierter OP Liste?
    vItem # vListOffeneOP->CteRead(_CteFirst | _CteSearch,0,Aint(Ofp.Rechnungsnr));
    if (vItem <> 0)  then begin
      // OP steht noch in OP Liste

      // VOrher alle Zahlungen löschen und später neu anlegen
      _KillOPZahlungen();

      vBetragSH # StrCut(Str_token(vItem->spCustom,'|',1),1,1);
      vBetrag   # Abs(CnvFa(Str_token(vItem->spCustom,'|',1)));
      if (vBetragSH='H') then
        vBetrag # -1.0 * vBetrag;

      // Teilzahlung?
      if (OfP.RestW1 <> vBetrag) then
        _CreateOPZahlung(vBetrag);

      // Als Erledigt aus Liste entfernen
      vListOffeneOP->CteDelete(vItem);

    end else begin

      // OP ist nicht in der offenen OP Liste -> Bezahlt
      _CreateOPZahlung(0.0);

    end;

    // Nächster OP
  END;

  // ----------------------------------------------------------------------------
  // Restliche OPs an die Kunden schreiben
  // ----------------------------------------------------------------------------

  // Vorher alle Nettobeträge errechnen, damit später die gerundeten Werte stimmen
  vListAdrExtOP   # CteOpen(_CteList);

  vMax # CteInfo(vListOffeneOP,_CteCount);
  vProgress->Lib_Progress:Reset('Ermittlung Nettowerte OPs pro Kunde',vMax);
  FOR vItem # vListOffeneOP->CteRead(_CteFirst);
  LOOP vItem # vListOffeneOP->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) DO BEGIN
    if (vProgress->Lib_Progress:Step() = false) then begin
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    // Kundenbuchungsnummer extrahieren
    vTmp # Str_token(vItem->spCustom,'|',2);
    //vKndBuchungsnr  # CnvIa(vTmp);
    vKndBuchungsnr  # vTmp;

    // Adresse lesen
    Adr.KundenFibuNr # vKndBuchungsnr;
    Erx # RecRead(100,10,0);
    if (Erx <= _rMultikey) AND (Adr.KundenFibuNr = vKndBuchungsnr) then begin
      RecRead(100,1,0);

      // Beträge errechnen
      vBetragSH # StrCut(Str_token(vItem->spCustom,'|',1),1,1);
      vBetrag   # Abs(CnvFa(Str_token(vItem->spCustom,'|',1)));
      if (vBetragSH='H') then
        vBetrag # -1.0 * vBetrag;
      vSteuer   # Abs(CnvFa(Str_token(vItem->spCustom,'|',3)));
      vBetragNetto # vBetrag / (vSteuer / 100.0 + 1.0);

      vItemAdr # vListAdrExtOP->CteRead(_CteFirst | _CteSearch,0,Aint(Adr.Nummer));
      if (vItemAdr = 0) then begin
        // Kunde noch nicht drin, Eintragen
        vListAdrExtOP->CteInsertItem(Aint(Adr.nummer),Adr.Nummer,Anum(vBetrag,7) + '|' + Anum(vBetragNetto,7));

      end else begin
        // Kunde schon in Liste -> Wert Updaten
        vBetrag       # CnvFa(Str_token(vItemAdr->spCustom,'|',1)) + vBetrag;
        vBetragNetto  # CnvFa(Str_token(vItemAdr->spCustom,'|',2)) + vBetragNetto;
        vItemAdr->spCustom # Anum(vBetrag,7) + '|' + Anum(vBetragNetto,7);
      end;

    end else
      Msg(99,Translate('Keine Adresse für Debitoren-Buchungsnummer ' + vKndBuchungsnr+ ' gefunden.'),_WinIcoError,_WinDialogOk,0);

  END;
  vListOffeneOP->cteClose();


  // Pro Adresse die Summen Runden und verbuchen
  vMax # CteInfo(vListAdrExtOP,_CteCount);
  vProgress->Lib_Progress:Reset('Verbuchung externe Offene Posten',vMax);
  FOR vItem # vListAdrExtOP->CteRead(_CteFirst);
  LOOP vItem # vListAdrExtOP->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) DO BEGIN
    if (vProgress->Lib_Progress:Step() = false) then begin
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    Adr.Nummer # vItem->spId;
    if (RecRead(100,1,_RecLock) = _rOK) then begin
      // Bruttobetrag
      vBetrag   # Rnd(CnvFa(Str_token(vItem->spCustom,'|',1)),2);
      Adr.Fin.SummeOPB.Ext  # Adr.Fin.SummeOPB.Ext + vBetrag;

      // Nettobetrag
      vBetrag   # Rnd(CnvFa(Str_token(vItem->spCustom,'|',2)),2);
      Adr.Fin.SummeOP.Ext  # Adr.Fin.SummeOP.Ext + vBetrag;

      if (RekReplace(100,_recUnlock,'MAN') <> _rOK) then
        Msg(99,Translate('Adresse ' + Adr.Stichwort+ ' konnte nicht gespeichert werden.'),_WinIcoError,_WinDialogOk,0);

    end else
      Msg(99,Translate('Adresse ' + Adr.Stichwort+ ' konnte nicht gesperrt werden.'),_WinIcoError,_WinDialogOk,0);

  END;

  vListAdrExtOP->CteClose();
  vProgress->Lib_Progress:Term();

  Msg(99,Translate('Import abgeschlossen'),_WinIcoInformation,_WinDialogOk,0);

end;

//========================================================================
//  _KillOPZahlungen
//
//========================================================================
SUB _KillOPZahlungen();
local begin
  Erx : int;
end;
begin
  // alle Zahlungen + Zahlungseingang löschen...
  WHILE (RecLink(461,460,1,_recFirst)<=_rLocked) do begin
    Erx # RecLink(465,461,2,_recFirst);   // Zahlungseingang holen
    if (Erx<=_rLocked) then
      RekDelete(465,0,'AUTO');
    RekDelete(461,0,'AUTO');
  END;
end;


//========================================================================
//  _CreateOPZahlung
//
//========================================================================
SUB _CreateOPZahlung(aRest : float);
local begin
  vWert : float;
end;
begin

  vWert # OfP.BruttoW1 - aRest;

  // Zahlungseingang anlegen.......................................
  RecBufClear(465);
  ZEi.Nummer # Lib_Nummern:ReadNummer('Zahlungseingang');    // Nummer lesen
  Lib_Nummern:SaveNummer();                                  // Nummernkreis aktuallisiern

  ZEi.Kundennummer    # OfP.Kundennummer;
  ZEi.KundenStichwort # OfP.KundenStichwort;
  ZEi.Zahlungsart     # 99;
  "ZEi.Währung"       # "OfP.Währung";
  "ZEi.Währungskurs"  # "OfP.Währungskurs";
  if ("Zei.Währungskurs"=0.0) then "Zei.Währungskurs" # 1.0;
  ZEi.BetragW1        # vWert;
  ZEi.Betrag          # ZEi.BetragW1 / "ZEi.Währungskurs";
  ZEi.Zugeordnet      # ZEi.Betrag;
  ZEi.ZugeordnetW1    # ZEi.BetragW1;
  ZEi.Zahldatum       # today;
  ZEi.Anlage.Datum    # today;
  ZEi.Anlage.Zeit     # now;
  ZEi.Anlage.User     # gUserName;
  if (vWert<>0.0) then
    RekInsert(465,0,'AUTO');

  // Zahlung anlegen..................................................
  RecBufClear(461);
  OfP.Z.Rechnungsnr   # OfP.REchnungsnr;
  OfP.Z.Zahlungsnr    # ZEi.Nummer;
  OfP.Z.Betrag        # ZEi.Betrag;
  OfP.Z.BetragW1      # ZEi.BetragW1;
  OfP.Z.Bemerkung     # 'automatisch';
  OfP.Z.Anlage.Datum  # today;
  OfP.Z.Anlage.Zeit   # now;
  OfP.Z.Anlage.User   # gUsername;
  if (vWert<>0.0) then
    RekInsert(461,0,'AUTO');

  // OP neu berechnen....................................................
  RecRead(460,1,_recLock);
  OfP.Zahlungen   # OfP.Z.Betrag;
  OfP.ZahlungenW1 # OfP.Z.BetragW1;
  OfP.Rest        # Rnd(OfP.Brutto      - OfP.Zahlungen,2);
  OfP.RestW1      # Rnd(OfP.BruttoW1    - OfP.ZahlungenW1,2);
  if (Abs(Rnd(OfP.RestW1))<1.0) then begin
    "OfP.Löschmarker" # '*';
    end
  else begin
    "OfP.Löschmarker" # '';
  end;
  RekReplace(460,_RecUnlock,'AUTO');

end;




//========================================================================
//  _GetPath(aSubPath : alpha) : alpha
//    Fragt den Benutzer ob Exportiert werden soll,
//========================================================================
sub _GetPath(aSubPath : alpha) : alpha
local begin
  vPfad : alpha(1000);
  vMsg  : alpha (250)
end
begin
  vPfad  # Set.Fibu.Pfad;

  if (vPfad ='') then
    vPfad # 'c:\';

  if (StrCut(vPfad,StrLen(vPfad)-1,1) <> '\') then
    vPfad   # vPfad + '\';

  if (aSubPath <> '') then
    vPfad # vPfad + aSubPath+ '\';

  vPfad  # Str_ReplaceAll(vPfad,'\\','\');

  vMsg # 'Alle markierten Datensätze für die Fibu nach "' + vPfad+'"  exportieren?'
  if (Msg(99,vMsg,_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then
    vPfad # '';

  RETURN vPfad;
end;



//========================================================================
//  _CreateFile(aFullPath : alpha) : int;
//  Erstellt eine Datei mit dem Übergenen Dateinamen und gibt den Filehandle
//  zurück.
//  Gibt eine Fehlermeldung aus, wenn die DAtei nicht zu erstellen war
//========================================================================
sub _CreateFile(aFullPath : alpha) : int;
local begin
  vFileHdl : int;
end
begin
  vFileHdl # FSIOpen(aFullPath,_FsiAcsRW|_FsiCreate|_FsiTruncate);
  if (vFileHdl<=0) then begin
    Msg(450104,aFullPath,0,0,0);
    RETURN 0;
  end;

  RETURN vFileHdl;
end;


//========================================================================
//  _WriteHeader()
//    Schreibt die Headerzeile in die übergebene Datei
//    aFileHdl          ->  Handle auf offene Datei
//    aDatenkat         ->  16 = Debitoren/Kreditoren
//                          20 = Sachkontenbeschriftungen
//                          21 = Buchungsstapel
//                          44 = Textschlüssel
//                          46 = Zahlungsbedingungen
//                          48 = Diverse Adressen
//    aFormatversion    ->  Aktueller Stand der Formatversionen:
//                          – Buchungsstapel = 2
//                          – Debitoren / Kreditoren = 2
//                          – Diverse Adressen = 1
//                          – Kontenbeschriftungen = 1
//                          – Textschlüssel = 1
//                          – Zahlungsbedingungen = 1
//    aWJJahrBegin      ->  Wirtschaftsjahresbeginn
//    opt aDatumVon     ->  Buchungsstapel von
//    opt aDatumBis     ->  Buchungsstapel bis
//    opt aBezeichnn    ->  BEzeichunung zb. "SC Rechnugen Juli 2013"
//
//========================================================================
sub _WriteHeader(
  aFileHdl        : int;
  aDatenKat       : int;
  aFormatversion  : int;
  aWJJahrBegin    : date;
  opt aDatumVon   : date;
  opt aDatumBis   : date;
  opt aBezeichnn  : alpha;)
local begin
  vFile : int;
  vKatText : alpha;
  i         : int;
end
begin
  vFile # aFileHdl;

  CASE aDatenKat OF
    16  : vKatText  # 'Debitoren/Kreditoren';
    20  : vKatText  # 'Sachkontenbeschriftungen';
    21  : vKatText  # 'Buchungsstapel';
    44  : vKatText  # 'Textschlüssel';
    46  : vKatText  # 'Zahlungsbedingungen';
    48  : vKatText  # 'Diverse Adressen';
  END;

  // --------------------------------------------------------------
  //  Headerdaten
  // --------------------------------------------------------------
  WriteText('EXTF',4);                              //   1    DATEV-Format-KZ
  WriteZahl(300);                                   //   2    Versionsnummer
  WriteZahl(aDatenKat);                             //   3    Datenkategorie
  WriteText(vKatText,99);                           //   4    Formatname
  WriteZahl(aFormatversion)                         //   5    Formatversion
  Write(Lib_Strings:TimestampFullYearMs());         //   6    ErzeutAm
  WriteEmpty;                                       //   7    Importiert / reserviert Datev
  WriteText('',2);                                  //   8    Herkunft
  WriteText(gUserName,25);                          //   9    Exportiert von
  WriteText('',25);                                 //  10    Importiert von / reserivert Datev
  WriteZahl(cBeraterNr);                            //  11    Beraternummer
  WriteZahl(cMandantNr);                            //  12    Mandantennummer
  WriteDatum(aWJJahrBegin);                         //  13    Wirtschaftsjahrbegin
  WriteZahl(cSachkontenlaenge);                     //  14    Sachkontenlänge

  //  Die nachfolgenden Header-Felder sind ausschließlich für Buchungsstapel
  //  relevant, jedoch: Der Aufbau des Headers ist über alle Datenkategorien
  //  identisch, die Anzahl der Felder ist immer gleich.
  if (aDatumVon <> 0.0.0) then begin
    // Header mit Buchungsstapel
    WriteDatum(aDatumVon);                          //  15  Datum von
    WriteDatum(aDatumBis);                          //  16  Datum bis
    WriteText(aBezeichnn,30)                        //  17  Bezeichnung
    WriteText(cKuerzel,2);                          //  18  Diktatkürzel
    WriteZahl(1)                                    //  19  Buchungstyp   (1= Fibu, 2= Jahresabschluss
    WriteZahl(0);                                   //  20  Rechnungslegungszweck
    WriteEmpty;                                     //  21  reserviert
    WriteText('EUR',3);                             //  22  WKZ
  end else begin
    // Header ohne Buchungsstapel
    WriteEmpty;                                     //  15  Datum von
    WriteEmpty;                                     //  16  Datum bis
    WriteEmpty;                                     //  17  Bezeichnung
    WriteEmpty;                                     //  18  Diktatkürzel
    WriteEmpty;                                     //  19  Buchungstyp
    WriteEmpty;                                     //  20  Rechnungslegungszweck
    WriteEmpty;                                     //  21  reserviert
    WriteEmpty;                                     //  22  WKZ
  end;
  WriteEmpty;                                       //  23  reserviert
  WriteEmpty;                                       //  24  reserviert
  WriteEmpty;                                       //  25  reserviert
  WriteEmptyLast;                                   //  26  reserviert

  WriteNewLine;

  // --------------------------------------------------------------
  //  Spaltenüberschriften
  // --------------------------------------------------------------

  // Je nach Exporttyp die entsprechenden Überschriften schreiben
  if (aDatenKat = 21) then begin
    // Überschriften für Buchungsstapel generieren
    WriteHead('Umsatz');                      //   1
    WriteHead('Soll /Haben-Kennzeichen');     //   2
    WriteHead('WKZ Umsatz');                  //   3
    WriteHead('Kurs');                        //   4
    WriteHead('Basis-Umsatz');                //   5
    WriteHead('WKZ Basis-Umsatz');            //   6
    WriteHead('Konto');                       //   7
    WriteHead('Gegenkonto');                  //   8
    WriteHead('BUSchlüssel');                 //   9
    WriteHead('Belegdatum');                  //  10
    WriteHead('Belegfeld1');                  //  11
    WriteHead('Belegfeld2');                  //  12
    WriteHead('Skonto');                      //  13
    WriteHead('Buchungstext');                //  14
    WriteHead('Postensperre');                //  15
    WriteHead('DiverseAdressnummer');         //  16
    WriteHead('Geschäftspartnerbank');        //  17
    WriteHead('Sachverhalt');                 //  18
    WriteHead('Zinssperre');                  //  19
    WriteHead('Beleglink');                   //  20

    // Beleginfos 1-8                         // 21 - 36
    FOR i # 1 LOOP inc(i) WHILE i<=8 DO BEGIN
      WriteHead('Beleginfo– Art '+Aint(i));
      WriteHead('Beleginfo– Inhalt '+aint(i));
    END;

    WriteHead('KOST1– Kostenstelle');         //  37
    WriteHead('KOST2– Kostenstelle');         //  38
    WriteHead('KOSTMenge');                   //  39
    WriteHead('EU-Landu. UStID');             //  40
    WriteHead('EU-Steuersatz');               //  41
    WriteHead('Abw.Versteuerungsart');        //  42
    WriteHead('SachverhaltL+L');              //  43
    WriteHead('FunktionsergänzungL+L');       //  44
    WriteHead('BU 49Hauptfunktionstyp');      //  45
    WriteHead('BU 49Hauptfunktionsnummer');   //  46
    WriteHead('BU 49Funktionsergänzung');     //  47

    // Beleginfos 1-8                         // 48 - 87
    FOR i # 1 LOOP inc(i) WHILE i<=20 DO BEGIN
      WriteHead('Zusatzinformation– Art '+Aint(i));
      WriteHead('ZusatzinformationInhalt '+Aint(i));
    END;

    WriteHead('Stück');                       //  88
    WriteHead('Gewicht');                     //  89
    WriteHead('Zahlweise');                   //  90
    WriteHead('Forderungsart');               //  91
    WriteHead('Veranlagungsjahr');            //  92
    WriteHeadLast('ZugeordneteFälligkeit');       //  93
  end;

  if (aDatenKat = 16) then begin
    // Überschriften für Kreditoren/Debitoren generieren
    WriteHead('Kontonummer');                      //   1
    WriteHead('Name(AdressattypUnternehmen)');     //   2
    WriteHead('Unternehmensgegenstand');           //   3
    WriteHead('Name');                             //   4
    WriteHead('Vorname');                          //   5
    WriteHead('Name');                             //   6
    WriteHead('Adressattyp');                      //   7
    WriteHead('Kurzbezeichnung');                  //   8
    WriteHead('EU-Land');                          //   9
    WriteHead('EU-UStID');                         //  10
    WriteHead('Anrede');                           //  11
    WriteHead('Titel / Akad.Grad');                //  12
    WriteHead('Adelstitel');                       //  13
    WriteHead('Namensvorsatz');                    //  14
    WriteHead('Adressart');                        //  15
    WriteHead('Straße');                           //  16
    WriteHead('Postfach');                         //  17
    WriteHead('Postleitzahl');                     //  18
    WriteHead('Ort');                              //  19
    WriteHead('Land');                             //  20
    WriteHead('Versandzusatz');                    //  21
    WriteHead('Adresszusatz');                     //  22
    WriteHead('AbweichendeAnrede');                //  23
    WriteHead('Abw.Zustellbezeichnung1');          //  24
    WriteHead('Abw.Zustellbezeichnung2');          //  25
    WriteHead('Kennz.Korrespondenzadresse');       //  26
    WriteHead('AdresseGültig von');                //  27
    WriteHead('AdresseGültig bis');                //  28
    WriteHead('Telefon');                          //  29
    WriteHead('Bemerkung(Telefon)');               //  30
    WriteHead('TelefonGeschäftsleitung');          //  31
    WriteHead('Bemerkung(TelefonGL)');             //  32
    WriteHead('E-Mail');                           //  33
    WriteHead('Bemerkung(E-Mail)');                //  34
    WriteHead('Internet');                         //  35
    WriteHead('Bemerkung(Internet)');              //  36
    WriteHead('Fax');                              //  37
    WriteHead('Bemerkung(Fax)');                   //  38
    WriteHead('Sonstige');                         //  39
    WriteHead('Bemerkung(Sonstige)');              //  40

    // Bankdaten  1-5                              // 41 - 95
    FOR i # 1 LOOP inc(i) WHILE i<=5 DO BEGIN
      WriteHead('Bankleitzahl'+Aint(i));            //  1
      WriteHead('Bankbezeichnung'+Aint(i));         //  2
      WriteHead('Bank-Kontonummer'+Aint(i));        //  3
      WriteHead('Länderkennzeichen'+Aint(i));       //  4
      WriteHead('IBAN-Nr. '+Aint(i));               //  5
      WriteHead('IBAN '+Aint(i)+'korrekt');         //  6
      WriteHead('SWIFTCode'+ Aint(i));              //  7
      WriteHead('Abw. Kontoinhaber' +Aint(i));      //  8
      WriteHead('Kennz.Hauptbankverb.' +Aint(i));   //  9
      WriteHead('Bankverb.'+Aint(i)+' Gültigvon');  //  0
      WriteHead('Bankverb.'+Aint(i)+' Gültigbis');  //  1
    END;

    WriteHead('Leerfeld');                          //  96
    WriteHead('Briefanrede');                       //  97
    WriteHead('Grußformel');                        //  98
    WriteHead('Kundennummer');                      //  99
    WriteHead('Steuernummer');                      //  100
    WriteHead('Sprache');                           //  101
    WriteHead('Ansprechpartner');                   //  102
    WriteHead('Vertreter');                         //  103
    WriteHead('Sachbearbeiter');                    //  104
    WriteHead('Diverse-Konto');                     //  105
    WriteHead('Ausgabeziel');                       //  106
    WriteHead('Währungssteuerung');                 //  107
    WriteHead('Kreditlimit(Debitor)');              //  108
    WriteHead('Zahlungsbedingung');                 //  109
    WriteHead('Fälligkeitin Tagen(Debitor)');       //  110
    WriteHead('Skonto in Prozent(Debitor)');        //  111

    // Skontodaten  1-5                             // 112 - 120
    FOR i # 1 LOOP inc(i) WHILE i<=5 DO BEGIN
      WriteHead('Kreditoren-Ziel '+Aint(i)+' (Tage)');
     if (i <> 3) then   // !!! ACHTUNG BUG IN DATEV Doku
        WriteHead('Kreditoren-Skonto '+Aint(i)+' (%)');
    END;

    WriteHead('Mahnung');                           //  121
    WriteHead('Kontoauszug');                       //  122
    WriteHead('Mahntext1');                         //  123
    WriteHead('Mahntext2');                         //  124
    WriteHead('Mahntext3');                         //  125
    WriteHead('Kontoauszugstext');                  //  126
    WriteHead('MahnlimitBetrag');                   //  127
    WriteHead('Mahnlimit%');                        //  128
    WriteHead('Zinsberechnung');                    //  129
    WriteHead('Mahnzinssatz 1');                    //  130
    WriteHead('Mahnzinssatz 2');                    //  131
    WriteHead('Mahnzinssatz 3');                    //  132
    WriteHead('Lastschrift');                       //  133
    WriteHead('Verfahren');                         //  134
    WriteHead('Mandantenbank');                     //  135
    WriteHead('Zahlungsträger');                    //  136

    // Individuell 1-15                             //  137 - 151
    FOR i # 1 LOOP inc(i) WHILE i<=15 DO BEGIN
      WriteHead('Indiv. Feld '+Aint(i));
    END;

    WriteHead('Abweichende Anrede(Rechnungsadresse)');        //  152
    WriteHead('Adressart(Rechnungsadresse)');                 //  153
    WriteHead('Straße (Rechnungsadresse');                    //  154
    WriteHead('Postfach(Rechnungsadresse)');                  //  155
    WriteHead('Postleitzahl(Rechnungsadresse)');              //  156
    WriteHead('Ort(Rechnungsadresse)');                       //  157
    WriteHead('Land(Rechnungsadresse)');                      //  158
    WriteHead('Versandzusatz(Rechnungsadresse)');             //  159
    WriteHead('Adresszusatz(Rechnungsadresse)');              //  160
    WriteHead('Abw.Zustellbezeichnung1 (Rechnungsadresse)');  //  161
    WriteHead('Abw.Zustellbezeichnung2 (Rechnungsadresse)');  //  162
    WriteHead('Adresse Gültig von(Rechnungsadresse)');        //  163
    WriteHead('Adresse Gültig bis(Rechnungsadresse)');        //  164

    // Bankdaten  6-10                                        // 165 - 219
    FOR i # 6 LOOP inc(i) WHILE i<=10 DO BEGIN
      WriteHead('Bankleitzahl'+Aint(i));
      WriteHead('Bankbezeichnung'+Aint(i));
      WriteHead('Bank-Kontonummer'+Aint(i));
      WriteHead('Länderkennzeichen'+Aint(i));
      WriteHead('IBAN-Nr. '+Aint(i));
      WriteHead('IBAN '+Aint(i)+'korrekt');
      WriteHead('SWIFTCode'+ Aint(i));
      WriteHead('Abw. Kontoinhaber' +Aint(i));
      WriteHead('Kennz.Hauptbankverb.' +Aint(i));
      WriteHead('Bankverb.'+Aint(i)+' Gültigvon');
      WriteHead('Bankverb.'+Aint(i)+' Gültigbis');
    END;

    WriteHeadLast('Nummer Fremdsystem');                       //  220
  end;

  WriteNewLine;

end;



//========================================================================
//  sub GetWirtschaftsJahrBeginn() : date
//    Gibt den Beginn des aktuellen Wirtschaftsjahrs zurück
//========================================================================
sub GetWirtschaftsJahrBeginn(opt aBezugsDatum : date) : date
local begin
  vToday  : date;
  vWJDatum : CalTime;
end
begin
  vToday  # today;

  vWJDatum->vpDate # vToday;
  vWJDatum->vpDay   # cWJStartTag;
  vWJDatum->vpMonth # cWJStartMonat;
  vWJDatum->vpYear  # vToday->vpYear;

  if (vWJDatum->vpDate > vToday) then
    vWJDatum->vpYear  # vWJDatum->vpYear - 1;

  if (aBezugsdatum != 0.0.0) then
    vWJDatum->vpYear  # aBezugsDatum->vpYear;

  RETURN  vWJDatum->vpDate;
end;


//========================================================================