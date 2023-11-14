@A+
//===== Business-Control =================================================
//
//  Prozedur    SFX_Fibu_DatevV5
//
//  Info
//      Funktionen zum Export von
//        - Kreditoren/Debitoren (= SC Adressen)
//        - Ausgangsrechnungen
//        - Eingangszahlungen
//        - Eingangsrechnungen
//        - Ausgangszahlungen
//        - Import Offene Posten per Saldenliste
//
//      laut Datev Schnittstellen-Entwicklungsleitfaden 5.0 Stand 10/2015
//
//  25.11.2020  ST  Erstellung der Prozedur  // MMW & KUZ
//  10.05.2022  AH  ERX
//  2022-11-16  ST  Bugfix: OP Import Zahlungsanlage
//  2023-01-19  ST  Anpassung    Proj. 2465/36
//  2023-03-13  ST  Fix: Ere Fremdwährungsexport     Proj. 2465/101
//  2023-04-13  ST  Fix: Opos Importe
//
//  Subprozeduren
//    sub GetWirtschaftsJahrBeginn() : date
//    sub GetGegenKonto(aTyp : alpha) : int
//    sub _GetPath(aSubPath : alpha) : alpha
//    sub _CreateFile(aFullPath : alpha) : int;
//    sub _WriteHeader(aFileHdl : int; aDatenKat : int; aFormatversion : int; aWJJahrBegin : date; opt aDatumVon : date;opt aDatumBis : date;opt aBezeichnn : alpha;)
//    sub _WriteErloes(aFileHdl : int; opt aKontierungen : logic)
//    sub Erl_Export()
//    sub Erl_Export_Job(aPara : alpha) : logic
//    sub ZEi_Export()
//    sub Ere_Export()
//    sub Ere_Export_Job(aPara : alpha) : logic
//    sub ZAu_Export()
//    sub Adr_Export()
//    sub Ofp_Import()
//    sub OfP_Import_Job(aPara : alpha) : logic
//    sub _KillOPZahlungen();
//    sub _CreateOPZahlung(aRest : float);
//
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
  WriteDatum(a)     : FSIWrite(vFile, Lib_Strings:Strings_ReplaceAll(Lib_Strings:DateForSort(a),'.','') + StrChar(59))
  WriteNum(a,b)     : FSIWrite(vFile, StrAdj(ANum(a,b),_StrBegin | _StrEnd) + StrChar(59));

  cBeraterNr        : 1234567     // Maximal 7 Stellen
  cMandantNr        : 12345       // Maximal 5 Stellen
  cSachkontenlaenge : 4           // 4 oder 8   (4= 5stellige Deb/KredNr, 8= 8stellige Deb/Kred)
  cKuerzel          : 'FB'        // Dikatkürzel

  cWJStartTag       : 1           // z.B. 1. Tag des Monats
  cWJStartMonat     : 1           // z.B. 7 für Juli
  cGueltigVon       : '01011900'
  cGueltigBis       : '31122099'

  cErloeseMitEinzelKonten : false
  
  // ----------------------------------------------------------------------------------------
  //   Import OPOS
  // ----------------------------------------------------------------------------------------
  c_EXCEL_CSV_CONVERTER : gFsiClientPath + '\dlls\ExcelToCSVConverter.exe'
  READ(a,b)       :  begin vEingelesen  # vEingelesen  + FSIRead(a, b); b # StrAdj(b,_StrBegin | _StrEnd); end;
end;

declare _WriteZei(aFileHdl : int;)
declare _WriteZau(aFileHdl : int;)

declare _KillOPZahlungen();
declare _CreateOPZahlung(aRest : float);

//========================================================================
//  sub getMandant() : alpha
//
//========================================================================
sub getMandant() : alpha
local begin
  v100 : int;
  vRet : alpha;
end
begin
  v100 # RecBufCreate(100);
  v100->Adr.Nummer # Set.eigeneAdressnr;
  RecRead(v100,1,0);
  vRet  # v100->Adr.VerbandRefNr;
  RecBufDestroy(v100);

  return vRet;
end;



//========================================================================
//  sub TimestampYear(opt aDate : date; opt aTime : time) : alpha ST 30.07.2013
//    Gibt einen Timestap ohne Sonderzeichen zurück, inkl. kompletter Jahresangabe
//========================================================================
sub TimestampFullYearMs(opt aDate : date; opt aTime : time) : alpha
local begin
  vA,vB,vC  : alpha;
  vDate     : date;
  vTime     : time;
end;
begin
  if (aDate = 0.0.0) then
    vDate # SysDate();
  else
    vDate # aDate;

  if (aTime = 0:0:0) then
    vTime # Systime(_TimeSec | _TimeServer);
  else
    vTime # aTime;

  vA #  cnvai(vDate->vpYear, _Fmtnumleadzero | _FmtNumNoGroup)+
        cnvai(vDate->vpMonth, _Fmtnumleadzero,0,2)+
        cnvai(vDate->vpday, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpHours, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpMinutes, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpSeconds, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpMilliseconds, _Fmtnumleadzero,0,3);

  RETURN vA;
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

  vWJDatum->vpDate  # vToday;
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
//  GetGegenKonto() : alpha;
//    Gibt das passende Gegenkonto zu einem Vorgang zurück
//========================================================================
sub GetGegenKonto(aTyp : alpha) : int
local begin
  vCheck  : alpha;
end
begin

  CASE aTyp OF
    // ---------------------------------------------------------------------
    // - Typ  Erlös = nur Rechnugnsdaten ohne Positionsbezug -> Adressdaten
    'ERL' : begin
      RekLink(451,450,1,0); // Erste Erlöskontierung lesen
      RekLink(835,451,5,0); // Auftragsart lesen
                  
      case Erl.K.Steuerschl of
        1001 : RETURN 8400;  // Voll Inland & Corona
        1002 : RETURN 8125;  // Voll EG
        1003 : RETURN 8120;  // Voll Ausland
      end;

      // Schrott
      if (Erl.K.Warengruppe = 9000) then
        RETURN 8337;
          
      
    end; // 'EO ERL'


    // ---------------------------------------------------------------------
    // - Typ  Erlöskonto genaue Zusammensetzung mit Steuerschlüssel und Waren-
    //        gruppe
    'ERLK' : begin
/*
      case  Erl.K.Steuerschl of
        // Voll Inland
        1001   :  RETURN 8400;


        // Voll EG mit UstIdent
        1002   : RETURN 8339;


        // Voll Ausland Drittland ohne UstIdent
        1003    : RETURN 8338;

        // Steuerfrei Inland
        2001 :  RETURN 8200;

        // Inland Reverse Charge
        3001   :  RETURN 3001;
      end;
*/
      end; // EO 'ERLK'
      
      
    'ERE' : begin

      if (ERe.Rechnungstyp = 502) then
        RETURN 5900;
      
      case ERe.Adr.Steuerschl of
        1 : RETURN 5400;  //  Inland
        2 : RETURN 5425;  //  EG
        3 : RETURN 5200;  //  Ausland
      end;
    
    end;

      
  END;


  RETURN 0;
end;


//========================================================================
//  _GetPath(aSubPath : alpha) : alpha
//    Fragt den Benutzer ob Exportiert werden soll,
//========================================================================
sub _GetPath(aSubPath : alpha; opt aSilent : logic) : alpha
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

  vPfad  # Lib_Strings:Strings_ReplaceAll(vPfad,'\\','\');

  vMsg # 'Alle markierten Datensätze zur die Fibu nach "' + vPfad+'"  exportieren?'
  if (aSilent = false) then begin
    if (Msg(99,vMsg,_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then
      vPfad # '';
  end;
  
  RETURN vPfad;
end;



//========================================================================
//  _CreateFile(aFullPath : alpha) : int;
//  Erstellt eine Datei mit dem Übergenen Dateinamen und gibt den Filehandle
//  zurück.
//  Gibt eine Fehlermeldung aus, wenn die DAtei nicht zu erstellen war
//========================================================================
sub _CreateFile(aFullPath : alpha; opt aSilent : logic) : int;
local begin
  vFileHdl : int;
end
begin
  vFileHdl # FSIOpen(aFullPath,_FsiAcsRW|_FsiCreate|_FsiTruncate);
  if (vFileHdl<=0) then begin
    if (aSilent = false) then
      Msg(450104,aFullPath,0,0,0);
    else
      Error(450104,aFullPath);
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
  vMandant  : int;
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

  vMandant  # CnvIa(getMandant());

  // --------------------------------------------------------------
  //  Headerdaten
  // --------------------------------------------------------------
  WriteText('EXTF',4);                              //   1    DATEV-Format-KZ
  WriteZahl(510);                                   //   2    Versionsnummer
  WriteZahl(aDatenKat);                             //   3    Datenkategorie
  WriteText(vKatText,99);                           //   4    Formatname
  WriteZahl(aFormatversion)                         //   5    Formatversion
  Write(Lib_Strings:TimestampFullYearMs());         //   6    ErzeutAm
  WriteEmpty;                                       //   7    Importiert / reserviert Datev
  WriteText('',2);                                  //   8    Herkunft
  WriteText(gUserName,25);                          //   9    Exportiert von
  WriteText('',25);                                 //  10    Importiert von / reserivert Datev
  WriteZahl(cBeraterNr);                            //  11    Beraternummer
  WriteZahl(vMandant);                              //  12    Mandantennummer
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
  WriteEmpty;                                       //  26  reserviert
  WriteEmpty;                                       //  27  SKR
  WriteEmpty;                                       //  28  BranchenllösungsID
  WriteEmpty;                                       //  29  reservert
  WriteEmpty;                                       //  30  reservert
  WriteEmptyLast;                                   //  31  Anwendungsinfo
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
    WriteHead('ZugeordneteFälligkeit');       //  93

    // Stand 2015-10
    // NEU Hinzugekommen       // https://www.datev.de/dnlexom/client/app/index.html#/document/1036228
    WriteHead('Skontotyp');                     //  94
    WriteHead('Auftragsnummer');                //  95
    WriteHead('Buchungstyp');                   //  96
    WriteHead('Ust.Schlüssel (Anzahlungen)');   //  97
    WriteHead('EU-Mitgliedstaat (Anzahlungen)');//  98
    WriteHead('Sachverhalt L+L (Anzahlungen)'); //  99
    WriteHead('EU-Steuersatz (Anzahlungen)');   //  100
    WriteHead('Erlöskonto (Anzahlungen)');      //  101
    WriteHead('Herkunft-KZ');                   //  102
    WriteHead('Leerfeld');                      //  103
    WriteHead('KOST-Datum');                    //  104
    WriteHead('SEPA-Mandatsreferenz');          //  105
    WriteHead('Kontensperre');                  //  106
    WriteHead('Gesellschaftername');            //  107
    WriteHead('Beteiligennummer');              //  108
    WriteHead('Identifikationsnummer');         //  109
    WriteHead('Zeichnernummer');                //  110
    WriteHead('Postensperre bis');              //  111
    WriteHead('Bez. SoBil-Sachverhalt');        //  112
    WriteHead('Kennzeichen SoBil-Buchung');     //  113
    WriteHead('Festschreibung');                //  114
    WriteHead('Leistungsdatum');                //  115
    WriteHeadLast('Datum Zuord. Steuerperiode');//  116
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

    WriteHead('Insovlent');                                     //  221           0 = nein , = 1 ja
    FOR i # 1 LOOP inc(i) WHILE i<=10 DO
      WriteHead('SEPA Mandatsreferenz '+Aint(i));               //  222 - 231

    WriteHead('Verknüpftes OPOS-Konto');                        //  232
    WriteHead('Mahnsperre bis');                                //  233
    WriteHead('Lastschriftsperre bis');                         //  234
    WriteHead('Zahlungssperre bis');                            //  235
    WriteHead('Gebührenberechnung');                            //  236
    WriteHead('Mahngebühr 1');                                  //  237
    WriteHead('Mahngebühr 2');                                  //  238
    WriteHead('Mahngebühr 3');                                  //  239
    WriteHead('Pauschalenberechnung');                          //  240
    WriteHead('Verzugsbauschale 1');                            //  241
    WriteHead('Verzugsbauschale 2');                            //  242
    WriteHead('Verzugsbauschale 3');                            //  243
  end;

  WriteNewLine;
end;


//========================================================================
//  sub _WriteErloesEnd(aFileHdl : int)
//    Schreibt die "unnützen" Felder in den Export
//========================================================================
sub _WriteErloesEnd(aFileHdl : int; aKostenstelle1 : alpha; opt aKostenstelle2 : alpha)
local begin
  vFile : int;
  i : int;
end;
begin
  vFile # aFileHdl;

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

/*
  WriteEmptyText;                             //  37    KOST1– Kostenstelle
  WriteEmptyText;                             //  38    KOST2– Kostenstelle
*/
  WriteText(aKostenstelle1,8);                //  37    KOST1– Kostenstelle
  WriteText(aKostenstelle2,8);                //  38    KOST2– Kostenstelle

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
  WriteEmpty;                                 //  93  ZugeordneteFälligkeit

  // NEU Hinzugekommen       // https://www.datev.de/dnlexom/client/app/index.html#/document/1036228
  WriteEmpty;                                 //  94  Skontotyp
  WriteEmptyText;                             //  95  Auftragsnummer/Projekt
  WriteEmptyText;                             //  96  Buchungstyp (AA = Angeforderte Anzahlung/Abschlagsrechnung
                                                                // AG = Erhaltene Anzahlung (Geldeingang)
                                                                // AV = Erhaltene Anzahlung (Verbindlichkeit)
                                                                // SR = Schlussrechnung
                                                                // SU = Schlussrechnung (Umbuchung)
                                                                // SG = Schlussrechnung (Geldeingang)
                                                                // SO =Sonstige)

  WriteEmpty;                                 //  97  UstSchlsseü (Anzahlungen)
  WriteEmptyText;                             //  98  EU-Mitglietstaat (Anzahlungen)
  WriteEmpty;                                 //  99  SAchverhalt L+L (Anzahlungen)
  WriteEmpty;                                 // 100  EU Steuersatz (Anzahlungen)
  WriteEmpty;                                 // 101  Erlöskonto (Anzahlungen)
  WriteEmptyText;                             // 102  Herkunfts-KZ
  WriteEmptyText;                             // 103  Leerfeld
  WriteEmpty;                                 // 104  KOST-Datum
  WriteEmptyText;                             // 105  SEPA Mandatsreferenz
  WriteEmpty;                                 // 106  Sktonospere
  WriteEmptyText;                             // 107  Gesellschaftername
  WriteEmpty;                                 // 108  Beteiligtennummer
  WriteEmptyText;                             // 109  Identifikationsnummer
  WriteEmptyText;                             // 110  Zeichnernummer
  WriteEmpty;                                 // 111  Postensperre Bis  Datum
  WriteEmptyText;                             // 112  Bezeichnung SoBil-Sachverhalt
  WriteEmpty;                                 // 113  Kennnzeichen SoBil-Buchung
  WriteZahl(  0);                             // 114  Festschreibung
  WriteEmpty;                                 // 115  Leistungsdatum
  WriteEmptyLast;                             // 116  Datum Zuord. Steuerperiode

end;



//========================================================================
//  sub _WriteErloes(aFileHdl  : int;  opt aKontierungen : logic)
//    Gibt einen Erlösdatensatz aus
//========================================================================
sub _WriteErloes(
      aFileHdl        : int;
  opt aKontierungen   : logic;
  opt aRundungsDiff   : float;
  )
local begin
  i : int;
  vFile : int;

  vUmsatz       : float;
  vSHKennz      : alpha(1);
  vWAEKurs      : float;
  vBasisUmsatz  : float;
  vGegenkonto   : int;
  vSteuerschl   : int;
  vFaelligDatum : alpha;
  vBuchungstext : alpha;
end;
begin
  vFile # aFileHdl;

  // --------------------------------------------------------------
  //  Daten ermitteln
  // --------------------------------------------------------------
  if (aKontierungen) then begin
/*    // Datensatz einer Kontierung exportieren
    vUmsatz  # Abs(Erl.K.Betrag);
    if (Erl.K.Betrag < 0.0 ) then
      vSHKennz # 'H';
    else
      vSHKennz # 'S';

    vWAEKurs       # "Erl.K.Währungskurs";
    vBasisUmsatz   #  Abs(Erl.K.BetragW1);

    begin // 04.03.2014 AH
      // Bruttobetrag errechnen
      vBasisUmsatz   # vBasisUmsatz + Rnd((vBasisUmsatz / 100.0 * StS.Prozent),2);
      // Rundungsdifferenz beachten
      vBasisUmsatz    # vBasisUmsatz + aRundungsDiff;
      vUmsatz        # vBasisUmsatz;
    end
*/
  end else begin
    // Datensatz auf Basis einer kompletten Rechnung exportieren
    vUmsatz  # Abs(Erl.Brutto);
    if (Erl.Brutto < 0.0 ) then
      vSHKennz # 'H';
    else
      vSHKennz # 'S';

    vWAEKurs        # "Erl.Währungskurs";
    //vBasisUmsatz    #  Abs(Erl.BruttoW1);
    vBasisUmsatz    #  Abs(Erl.Brutto);
  end;

  // --------------------------------------------------------------
  //  Datenanpassungen
  // --------------------------------------------------------------
  if  (vWAEKurs = 0.0) then
    vWAEKurs  # 1.0;
  

  vBuchungstext # Adr.Stichwort;
  
  // ST 2022-11-14 2228/16: Buchungstext aus Auftrag
  if (Erl.K.Bemerkung = 'Grundpreis') then begin
    AUf_Data:Read(Erl.K.Auftragsnr, Erl.K.Auftragspos, false);
    RekLink(819,451,4,0); // Warengruppe
    vBuchungstext #  StrAdj(StrCut("Auf.P.Güte" + ' ' + Wgr.Bezeichnung.L1,1,60),_StrBEgin | _StrEnd);
  end;
  
  if (OfP.Zieldatum <> 0.0.0) then
    vFaelligDatum # Cnvai(DateDay(OfP.Zieldatum),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(OfP.Zieldatum),_FmtNumLeadZero,0,2) +  Cnvai(DateYear(OfP.Zieldatum)-100,_FmtNumLeadZero,0,2);

  // --------------------------------------------------------------
  //  Gegenkontoermittlung
  // --------------------------------------------------------------
  vGegenkonto # GetGegenKonto('ERL');


  // --------------------------------------------------------------
  //  Export
  // --------------------------------------------------------------
  WriteNum(   vUmsatz,2);                     //   1   Umsatz (ohne Soll /Haben-Kz)
  WriteText(  vSHKennz,1);                    //   2   Soll /Haben-Kennzeichen
  WriteText(  Wae.Fibu.Code,3);               //   3   WKZ Umsatz
  WriteNum(   vWAEKurs,6);                    //   4   Kurs
  WriteNum(   vBasisUmsatz,2 );               //   5   Basis-Umsatz
  WriteText(  'EUR',3);                       //   6   WKZ Basis-Umsatz
  WriteText(  Adr.KundenFibuNr,9);            //   7   Sach/Personenn Konto
  WriteZahl(  vGegenkonto);                   //   8   Gegenkonto
  WriteText(  StS.Fibu.Code,2);               //   9   BU Schlüssel
  WriteDatumKurz(Erl.Rechnungsdatum);         //  10   Belegdatum
  WriteText(  Aint(Erl.Rechnungsnr),12);      //  11   Rechnungs/Belegdatum
  WriteText(  vFaelligDatum,12);              //  12   Belegfeld2 (Fälligkeitsdatum für OPOS)
  WriteEmpty;                                 //  13   Skonto (nur bei Zahlungen zulässig)
  WriteText(  vBuchungstext,60);              //  14   Buchungstext


  _WriteErloesEnd(vFile, CnvAi(Erl.K.Auftragsnr));
  WriteNewLine;
end;


//========================================================================
//  Erl_Export                TEST: call Fibu_Datev_V3:Erl_Export
//
//========================================================================
sub Erl_Export(opt aSilent : logic)
local begin
  vPfad         : alpha(200);
  vName         : alpha(500);

  vVonDat       : date;
  vBisDat       : date;

  vItem         : int;
  vMFile        : Int;
  vMID          : Int;

  vFile         : int;
  vCount        : int;

  vWJBeginn     : date;

  vRundungsDiff     : float;
  vBasisUmsatz      : float;
  vBruttoUmsatzSum  : float;
end;
begin

  vPfad # _GetPath('Export',aSilent);
  if (vPfad = '') then
    RETURN;

  // --------------------------------------------------------------------------
  // Abrechnungszeitraum ermitteln
  vVonDat # 1.1.2033;
  vBisDat # 1.1.1990;
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(450,0,0,vMID);          // Satz holen
 
    // ST 2022-11-21 2228/163/10 FIbudatum darf nicht gesetzt sein
    if /* (Erl.StornoRechNr<>0) OR */ (Erl.Fibudatum <> 0.0.0) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    If (Erl.Rechnungsdatum>vBisDat) then vBisDat # Erl.Rechnungsdatum;
    If (Erl.Rechnungsdatum<vVonDat) then vVonDat # Erl.Rechnungsdatum;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (vVonDat = 1.1.2033) AND (vBisDat = 1.1.1990) then begin
    if (aSilent = false) then
      Msg(99,'Fehler: nichts markiert',0,0,0);
      
    RETURN;
  end;

  // Datei öffenen und HEader schreiben
  // ST 2022-03-04 2343/31
  vName # vPfad + cFilePrefix + 'SC_Erloese_' + StrCut(Lib_Strings:TimestampFullYearMs(),1,8) + cFileExtention;
  vFile # _CreateFile(vName, aSilent);
  if (vFile <= 0) then
    RETURN;


  // Datenkategorie 21 = Buchungsstapel
  // Versionsnummer Buchungsstapel = 2

  // Stand 2015-10:
  // Versionsnummer Buchungsstapel = 7

  vWJBeginn # GetWirtschaftsJahrBeginn();
  _WriteHeader(vFile, 21, 7, vWJBeginn, vVonDat, vBisDat, 'Stahl Control Erlöse');

  // -------------------------------------------------------------
  // - Datendatei: Buchungssätze anhängen
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(450,0,0,vMID);          // Satz holen
    // ST 2022-11-21 2228/163/10 FIbudatum darf nicht gesetzt sein
    if /* (Erl.StornoRechNr<>0) OR */ (Erl.Fibudatum <> 0.0.0) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

/*
    // ST 2022-04-26 2343/49
    if (Erl.Rechnungstyp = 425) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;
*/

    vCount # vCount + 1;


    RekLink(100,450,5,0);         // Kunde holen

    if (Adr.KundenFibuNr='') then
      Adr.KundenfibuNr # aint(Adr.KundenNr);

    Erg # RecLink(460,450,2,_recFirst);     // OP-holen
    if (erg>_rLocked) then begin
      Erg # RecLink(470,450,11,_recFirst);    // ~OP-holen
      if (erg>_rLocked) then RecBufClear(470);
      RecBufCopy(470,470);
    end;
    RekLink(816,460,8,_recFirst);     // Zahlungsbed.-holen

    // GGF. Eingangsrechnung bei LF-Belastung lesen
    if (Erl.Rechnungstyp = c_Erl_Bel_LF) /* OR (Erl.Rechnungstyp = c_Erl_Gut) */ then begin

      if (Erl.Rechnungstyp = c_Erl_Bel_LF) then
          ERe.Rechnungsnr # 'BEL-LF ' + CnvAi(Erl.Rechnungsnr,_FmtNumNoGroup);

      Erg # RecRead(560,4,0)
      if (Erg = _rMultiKey) then
        OfP.Zieldatum # ERe.Zieldatum;

    end;


    RekLink(813,450,10,0);            // AdressSteuerschlüssel lesen

    RekLink(814,450,3,_recFirst);     // Währung holen
    if (Wae.Fibu.Code='') then Wae.Fibu.Code # "Wae.Kürzel";

    RekLink(451,450,1,0);            // Erste Kontierung lesen
    
    
    // Nur Rechnung ohne Kontierung exportieren, laut vorhandener Implementierung "SFX_MMW_Fibu_Datev"
    _WriteErloes(vFile, false);

    // Fibudatum setzen
//    if (isTestsystem = false) then begin
      RecRead(450,1,_recLock);
      Erl.Fibudatum # Today;
      RekReplace(450,0,'AUTO');
//    end;
  
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;


  // -------------------------------------------------------------
  // - Datendatei: Datei schließen und ggf. Export Verbuchen
  vFile->FsiClose();

  if (aSilent = false) then
    Msg(450102,cnvai(vCount)+'|'+vName,0,0,0);

  if (gZLList <> 0) then
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    
end;



//========================================================================
//  sub Erl_Export_Job(aPara : alpha) : logic     ST 2022-03-15 2343/32
//
//  Erlösexport per Jobserver
//  SFX_Fibu_DatevV5:Erl_Export_Job
//========================================================================
sub Erl_Export_Job(aPara : alpha) : logic
local begin
  Erx         : int;
  vRet        : logic;
  vSel        : int;
  vSelName    : alpha;
  vQ          : alpha(4000);

  vProgress   : handle;
end
begin

  
  //-------------------------------------------------------------------
  // Neue Rechnungen Markieren seletieren und für Export markieren
  //-------------------------------------------------------------------

  //-------------------------------------------------------------------
  // Selektion
  vQ  #   '';
  Lib_Sel:QVonBisD(var vQ, 'Erl.Rechnungsdatum', today, today);
  
  vSel  # SelCreate(450, 1);
  Erx   # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);


  //-------------------------------------------------------------------
  // Markieren
  Lib_Mark:Reset(450);
  vProgress # Lib_Progress:Init( 'MArkierung', RecInfo( 450, _recCount, vSel ) );

  FOR   Erx # RecRead(450,vSel, _recFirst);
  LOOP  Erx # RecRead(450,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    vProgress->Lib_Progress:Step();
    
    Lib_Mark:MarkAdd(450);
  END;
  vProgress->Lib_Progress:Term();
   
  
  //-------------------------------------------------------------------
  // Export
  Erl_Export(true);
  
  
  // Fehlerhandling
  vRet # (Errlist = 0);
  ErrorOutput;
  
  
  RETURN vRet;
end;





//========================================================================
//  sub _WriteEREErloes
//
//========================================================================
sub _WriteEREErloes(
      aFileHdl  : int);
local begin
  i : int;
  vFile : int;

  vUmsatz         : float;
  vSHKennz        : alpha(1);
  vWAEKurs        : float;
  vBasisUmsatz    : float;
  vGegenkonto     : int;
  vSachPersKonto  : alpha;
  vBuchungsSchl   : alpha;
  vBelegDatum     : date;
  vBelegNummer    : alpha;

  vSteuerschl     : int;
  vBelegFeld2   : alpha;
  vBuchungstext   : alpha;
  
  vKost1  : alpha;
  vKost2  : alpha;
end;
begin
  vFile # aFileHdl;

  //  Gegenkontoermittlung
//  vGegenkonto  # GetGegenKonto('ERE');

  // --------------------------------------------------------------
  //  Daten ermitteln
  // --------------------------------------------------------------
    

  // --------------------------------------------------------------
  // Eingangsrechnung
  //vUmsatz        # Abs(ERe.BruttoW1);
//  vUmsatz         # Abs(Rnd(Vbk.K.BetragW1 + (Vbk.K.BetragW1 / 100.00 * StS.Prozent),2));
  vUmsatz         # Abs(Rnd(Vbk.K.Betrag + (Vbk.K.Betrag / 100.00 * StS.Prozent),2));

  vSHKennz       # 'H';
  if (ERe.BruttoW1 < 0.0) then
    vSHKennz       # 'S';


  // ST 2023-04-11
  if (ERe.Rechnungstyp = 502) then
    vSHKennz       # 'S';


  vWAEKurs       # "Ere.Währungskurs";
  vBasisUmsatz    # Abs(Rnd(Vbk.K.BetragW1 + (Vbk.K.BetragW1 / 100.00 * StS.Prozent),2));
  
  vSachPersKonto # Adr.LieferantFibuNr;
  vGEgenkonto     # Vbk.K.Gegenkonto;

  vBuchungsSchl  # '0';                // Buchungsschlüssel;
  if (ERe.Rechnungstyp = c_Erl_Bel_LF) /* OR  (StS.Nummer = 1501) */then begin
//    vBuchungsSchl  # '2'; // = 2 Generalumkehr   Seite 70 in im Leitfaden
    vSHKennz       # 'S';
  end else begin
    vBuchungsSchl  # '0';                // Buchungsschlüssel;

  end;

  // Bei Nicht-Automatikkonten den Steuerschlüssel mit exportieren
  if (StS.Prozent = 16.0) then
    vBuchungsSchl  # vBuchungsSchl+ '7';
  else if (StS.Prozent = 19.0) then
    vBuchungsSchl  # vBuchungsSchl+ '9';
  else if (StS.Prozent = 7.0) then
    vBuchungsSchl  # vBuchungsSchl+ '8';
  else
    vBuchungsSchl  # vBuchungsSchl+ '0';



  vBelegDatum    # ERe.Rechnungsdatum;
  vBelegNummer   # ERe.Rechnungsnr;
  vBelegNummer   # Lib_Strings:Strings_ReplaceAll(vBelegNummer   ,'BEL-LF ','');

  ERe.Rechnungsnr  # StrCnv(ERe.Rechnungsnr,_StrLetter);
  ERe.Rechnungsnr  # StrCut(StrAdj(ERe.Rechnungsnr,_StrEnd),1,12);
  vBelegFeld2    # '';

   
  vBuchungstext  # ERe.LieferStichwort;

/*
  RekLink(854,551,3,0);   // Gegenkont lesen
  if (GKo.Bezeichnung <> '') then
    vBuchungstext  # GKo.Bezeichnung;
*/
  vBuchungstext # Vbk.K.Bezeichnung;

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
  Writetext(  vSachPersKonto,9);              //   7   Sach/Personenn Konto
  WriteZahl(  vGegenkonto);                   //   8   Gegenkonto
  WriteText(  vBuchungsSchl,2);               //   9   BU Schlüssel
  WriteDatumKurz(vBelegdatum);                //  10   Belegdatum
  WriteText(  vBelegnummer,12);               //  11   Rechnungs/Belegdatum
  WriteText(  vBelegFeld2,12);                //  12   Belegfeld2 (Fälligkeitsdatum für OPOS)
  WriteEmpty;                                 //  13   Skonto (nur bei Zahlungen zulässig)
  WriteText(  vBuchungstext,60);              //  14   Buchungstext
 
// ST 2023-01-19 Proj. 2465/36: Laut Kundenwunsch immer auf Kost1
  vKost1  # CnvAi(Vbk.K.Kostenstelle,_FmtNumNoGroup);
/*
  if (SFX_VBK_K_Main:_isKostenStelleAuf(Vbk.K.Kostenstelle)) then begin
    vKost1  # '';
  end else begin
    vKost1  # CnvAi(Vbk.K.Kostenstelle,_FmtNumNoGroup);
    vKost2  # '';
  end;
*/

  _WriteErloesEnd(vFile,vKost1, vKost2);
  WriteNewLine;
end;



//========================================================================
//  Zei_Export
//    Export von Zahlungseingängen
//========================================================================
sub Zei_Export()
local begin
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

  vRundungsDiff     : float;
  vBasisUmsatz      : float;
  vBruttoUmsatzSum  : float;
end;
begin

  vPfad # _GetPath('');
  if (vPfad = '') then
    RETURN;

  // --------------------------------------------------------------------------
  // Abrechnungszeitraum ermitteln
  vVonDat # 1.1.2033;
  vBisDat # 1.1.1990;
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>465) then
      CYCLE;

    RecRead(465,0,0,vMID);          // Satz holen

    //  Sollte keine Zuordnung vorhanden sein, dann
    //  nächsten Zahlungseingang
    RekLink(461,465,1,0); // Zahlungszuordnung lesen
    if (OfP.Z.Rechnungsnr = 0) then
      CYCLE;

    If (ZEi.Zahldatum>vBisDat) or (vBisDat = 0.0.0) then vBisDat # ZEi.Zahldatum;
    If (ZEi.Zahldatum<vVonDat) or (vVonDat = 0.0.0) then vVonDat # ZEi.Zahldatum;
  END;

  if (vVonDat = 1.1.2033) AND (vBisDat = 1.1.1990) then begin
    msg(99,'Fehler: nichts markiert',0,0,0);
    RETURN;
  end;

  // Datei öffenen und HEader schreiben
  vFile # _CreateFile(vPfad + cFilePrefix + 'SC_Zahlungseingänge' + cFileExtention);
  if (vFile <= 0) then
    RETURN;


  // Datenkategorie 21 = Buchungsstapel
  // Versionsnummer Buchungsstapel = 2

  // Stand 2015-10:
  // Versionsnummer Buchungsstapel = 7

  vWJBeginn # GetWirtschaftsJahrBeginn();
  _WriteHeader(vFile, 21, 7, vWJBeginn, vVonDat, vBisDat, 'Stahl Control Zahlungseingänge');

  // -------------------------------------------------------------
  // - Datendatei: Buchungssätze anhängen
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>465) then
      CYCLE;

    RecRead(465,0,0,vMID);          // Satz holen


    // Zugeordnete Zahlungen für Zahlungseingang lesen
    FOR   Erg # RecLink(461,465,1,_RecFirst)
    LOOP  Erg # RecLink(461,465,1,_RecNext)
    WHILE (Erg = _rOK)  DO BEGIN

      RekLink(460,461,1,0);     // Ofenen Posten holen
      RekLink(450,460,2,0);     // Erlös holen
      RekLink(816,460,8,0);     // Zahlungsbed.-holen
      RekLink(814,460,7,0);     // Währung holen
      RekLink(100,460,4,0);     // Kunde holen
     if (Adr.KundenFibuNr='') then
      Adr.KundenfibuNr # aint(Adr.KundenNr);

      if (Ofp.Z.Fibudatum <> 0.0.0) then
        CYCLE;

      vCount # vCount + 1;
      _WriteZei(vFile);

      RecRead(461,1,_recLock);
      Ofp.Z.Fibudatum # Today;
      RekReplace(461,0,'AUTO');
    END;

  END;


  // -------------------------------------------------------------
  // - Datendatei: Datei schließen und ggf. Export Verbuchen
  vFile->FsiClose();

  Msg(450102,cnvai(vCount)+'|'+vPfad + cFilePrefix + 'SC_Zahlungseingänge' + cFileExtention,0,0,0);


  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
end;

//========================================================================
//  sub _WriteZei(aFileHdl  : int)
//    Gibt einen Zahlungseingangsdatensatz aus
//========================================================================
sub _WriteZei(
      aFileHdl        : int;
  )
local begin
  i : int;
  vFile : int;

  vUmsatz       : float;
  vSHKennz      : alpha(1);
  vWAEKurs      : float;
  vBasisUmsatz  : float;
  vGegenkonto   : int;
  vSteuerschl   : int;
  vFaelligDatum : alpha;
  vBuchungstext : alpha;
end;
begin
  vFile # aFileHdl;

   // Datensatz auf Basis einer kompletten Rechnung exportieren
  vUmsatz  # Abs(OfP.Z.BetragW1);
  if (OfP.Z.BetragW1 < 0.0 ) then
    vSHKennz # 'H';
  else
    vSHKennz # 'S';

  vWAEKurs        # "Erl.Währungskurs";
  vBasisUmsatz    #  Abs(Erl.BruttoW1);

  // --------------------------------------------------------------
  //  Datenanpassungen
  // --------------------------------------------------------------
  if  (vWAEKurs = 0.0) then
    vWAEKurs  # 1.0;

  vBuchungstext # Adr.Stichwort;
  vFaelligDatum # Cnvai(DateDay(OfP.Zieldatum),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(OfP.Zieldatum),_FmtNumLeadZero,0,2) +  Cnvai(DateYear(OfP.Zieldatum)-100,_FmtNumLeadZero,0,2);

  // --------------------------------------------------------------
  //  Gegenkontoermittlung
  // --------------------------------------------------------------
  // Zahlungsart als Gegenkonto lesen
  vGegenkonto # ZEi.Zahlungsart;

  // --------------------------------------------------------------
  //  Export
  // --------------------------------------------------------------
  WriteNum(   vUmsatz,2);                     //   1   Umsatz (ohne Soll /Haben-Kz)
  WriteText(  vSHKennz,1);                    //   2   Soll /Haben-Kennzeichen
  WriteText(  Wae.Fibu.Code,3);               //   3   WKZ Umsatz
  WriteNum(   vWAEKurs,6);                    //   4   Kurs
  WriteNum(   vBasisUmsatz,2 );               //   5   Basis-Umsatz
  WriteText(  'EUR',3);                       //   6   WKZ Basis-Umsatz
  WriteText(  Adr.KundenFibuNr,9);            //   7   Sach/Personenn Konto
  WriteZahl(  vGegenkonto);                   //   8   Gegenkonto
  WriteText(  StS.Fibu.Code,2);               //   9   BU Schlüssel
  WriteDatumKurz(Erl.Rechnungsdatum);         //  10   Belegdatum
  WriteText(  Aint(Erl.Rechnungsnr),12);      //  11   Rechnungs/Belegdatum
  WriteText(  '',12);                         //  12   Belegfeld2 (Fälligkeitsdatum für OPOS)
  WriteNum(   OfP.Z.SkontobetragW1,2);        //  13   Skonto (nur bei Zahlungen zulässig)
  WriteText(  vBuchungstext,60);              //  14   Buchungstext

  _WriteErloesEnd(vFile,'');
  WriteNewLine;
end;





//========================================================================
//  Ere_Export                TEST: call Fibu_Datev_V3:Ere_Export
//========================================================================
sub Ere_Export(opt aSilent : logic;)
local begin
  Erx           : int;
  vPfad         : alpha(200);
  vName         : alpha(500);

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

//  cProtokoll # TextOpen(20);

  vPfad # _GetPath('Export',aSilent);
  if (vPfad = '') then
    RETURN;


  // --------------------------------------------------------------------------
  // Abrechnungszeitraum ermitteln
  // Abrechnungszeitraum ermitteln
  vVonDat # 1.1.2033;
  vBisDat # 1.1.1990;
  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>560) then begin
      CYCLE;
    end;

    RecRead(560,0,0,vMID);          // Satz holen


    if (ERe.FibuDatum <> 0.0.0) then
      CYCLE;

    If (ERe.Rechnungsdatum>vBisDat) then vBisDat # ERe.Rechnungsdatum;
    If (ERe.Rechnungsdatum<vVonDat) then vVonDat # ERe.Rechnungsdatum;
  END;


  if (vVonDat = 1.1.2033) AND (vBisDat = 1.1.1990) then begin
    if (aSilent  = false) then
      msg(99,'Fehler: nichts markiert',0,0,0);
    RETURN;
  end;


  // Datei öffenen und HEader schreiben
  // ST 2022-03-04 2343/31
  vName # vPfad + cFilePrefix + 'SC_Eingangsrechnungen_' + StrCut(Lib_Strings:TimestampFullYearMs(),1,8) + cFileExtention;
  vFile # _CreateFile(vName, aSilent);
  if (vFile <= 0) then
    RETURN;


  // Datenkategorie 21 = Buchungsstapel
  // Versionsnummer Buchungsstapel = 2   --> 2015 Neu 7 analog zu Ausgangsrechnungen
  vWJBeginn # GetWirtschaftsJahrBeginn(vBisDat);
  _WriteHeader(vFile, 21, 7, vWJBeginn, vVonDat, vBisDat, 'Stahl Control Eingangsrechnungen');

  // -------------------------------------------------------------
  // - Datendatei: Buchungssätze anhängen

  FOR   vItem # gMarkList->CteRead(_CteFirst);
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>560) then
      CYCLE;

    RecRead(560,0,0,vMID);          // Satz holen

  if (ERe.FibuDatum <> 0.0.0) then
      CYCLE;
      
      
    RekLink(814,560,6,0);     // Währung holen
    RekLink(100,560,5,0);     // Lieferant holen

    if (Adr.LieferantFibuNr='') then
      Adr.LieferantFibuNr # aint(Adr.LieferantenNr);
   
    if (Wae.Fibu.Code='') then Wae.Fibu.Code # "Wae.Kürzel";

    // Zugeordnete Kontierungen für Eingangsrechnung lesen
    FOR   Erx # RecLink(551,560,3,_RecFirst)
    LOOP  Erx # RecLink(551,560,3,_RecNext)
    WHILE (Erx = _rOK)  DO BEGIN
      vCount # vCount + 1;

      RekLink(813,551,4,0);     // Steuerschlüssel lesen

       // Kontierung exportieren
//      _WritePos(vFile,'EREK');
      _WriteEREErloes(vFile);   // Kontierung exportieren

    END;
    
  //  _WriteEREErloes(vFile);   // Kontierung exportieren



//    if (isTestsystem = false) then begin
      RecRead(560,1,_recLock);
      ERe.FibuDatum # Today;
      RekReplace(560,0,'AUTO');
//    end;
  END;


  // -------------------------------------------------------------
  // - Datendatei: Datei schließen und ggf. Export Verbuchen
  vFile->FsiClose();
  vProg->Lib_Progress:Term();

  if (aSilent = false) then
    Msg(450102,cnvai(vCount)+'|'+vName,0,0,0);

  if (gZLList <> 0) then
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
end;






//========================================================================
//  sub Ere_Export_Job(aPara : alpha) : logic     ST 2022-03-15 2343/32
//
//  Erlösexport per Jobserver
//  SFX_Fibu_DatevV5:Ere_Export_Job
//========================================================================
sub Ere_Export_Job(aPara : alpha) : logic
local begin
  Erx         : int;
  vRet        : logic;
  vSel        : int;
  vSelName    : alpha;
  vQ          : alpha(4000);

  vProgress   : handle;
end
begin

  
  //-------------------------------------------------------------------
  // Neue Rechnungen Markieren seletieren und für Export markieren
  //-------------------------------------------------------------------

  //-------------------------------------------------------------------
  // Selektion
  vQ  #   '';
  Lib_Sel:QDate(var vQ,   'ERe.FibuDatum', '=',0.0.0);
  Lib_Sel:QLogic(var vQ, 'ERe.InOrdnung', true);
  
  
  vSel  # SelCreate(560, 1);
  Erx   # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  //-------------------------------------------------------------------
  // Markieren
  Lib_Mark:Reset(560);
  vProgress # Lib_Progress:Init( 'MArkierung', RecInfo( 560, _recCount, vSel ) );

  FOR   Erx # RecRead(560,vSel, _recFirst);
  LOOP  Erx # RecRead(560,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    vProgress->Lib_Progress:Step();
    
    Lib_Mark:MarkAdd(560);
  END;
  vProgress->Lib_Progress:Term();
   
  
  //-------------------------------------------------------------------
  // Export
  Ere_Export(true);
  
  
  // Fehlerhandling
  vRet # (Errlist = 0);
  ErrorOutput;
    
  RETURN vRet;
end;





//========================================================================
//  sub EreFibuReset() : int
//    Löscht das Fibudatum für die markierten Einträge
//  SFX_Fibu_DatevV5:EreFibuReset
//========================================================================
sub EreFibuReset() : int
local begin
  vItem         : int;
  vMFile        : Int;
  vMID          : Int;
end
begin

  FOR   vItem # gMarkList->CteRead(_CteFirst);
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>560) then
      CYCLE;

    RecRead(560,0,0,vMID);          // Satz holen

    RecRead(560,1,_recLock);
    ERe.FibuDatum # 0.0.0;
    RekReplace(560,0,'AUTO');
  END;

  RETURN 1;
end;


//========================================================================
//  Zau_Export
//    Export von Zahlungsausgängen
//========================================================================
sub Zau_Export()
local begin
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

  vRundungsDiff     : float;
  vBasisUmsatz      : float;
  vBruttoUmsatzSum  : float;
end;
begin

  vPfad # _GetPath('');
  if (vPfad = '') then
    RETURN;

  // --------------------------------------------------------------------------
  // Abrechnungszeitraum ermitteln
  vVonDat # 1.1.2033;
  vBisDat # 1.1.1990;
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>565) then
      CYCLE;

    RecRead(565,0,0,vMID);          // Satz holen

    if (ZAu.Zahldatum = 0.0.0) then
      CYCLE;

    //  Sollte keine Zuordnung vorhanden sein, dann
    //  nächsten Zahlungseingang
    RekLink(561,565,1,0); // Zahlungszuordnung lesen
    if (ERe.Z.Nummer = 0) then
      CYCLE;

    If (ZAu.Zahldatum>vBisDat) or (vBisDat = 0.0.0) then vBisDat # ZAu.Zahldatum;
    If (ZAu.Zahldatum<vVonDat) or (vVonDat = 0.0.0) then vVonDat # ZAu.Zahldatum;
  END;

  if (vVonDat = 1.1.2033) AND (vBisDat = 1.1.1990) then begin
    msg(99,'Fehler: nichts markiert',0,0,0);
    RETURN;
  end;

  // Datei öffenen und HEader schreiben
  vFile # _CreateFile(vPfad + cFilePrefix + 'SC_Zahlungsausgänge' + cFileExtention);
  if (vFile <= 0) then
    RETURN;


  // Datenkategorie 21 = Buchungsstapel
  // Versionsnummer Buchungsstapel = 2

  // Stand 2015-10:
  // Versionsnummer Buchungsstapel = 7

  vWJBeginn # GetWirtschaftsJahrBeginn();
  _WriteHeader(vFile, 21, 7, vWJBeginn, vVonDat, vBisDat, 'Stahl Control Zahlungsausgänge');

  // -------------------------------------------------------------
  // - Datendatei: Buchungssätze anhängen
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>565) then
      CYCLE;

    RecRead(565,0,0,vMID);          // Satz holen

    // Logische Prüfung
    if (ZAu.Zahldatum = 0.0.0) OR (ZAu.Zahlungsart = 0) then
      CYCLE;


    // Zugeordnete Zahlungen für Zahlungseingang lesen
    FOR   Erg # RecLink(561,565,1,_RecFirst)
    LOOP  Erg # RecLink(561,565,1,_RecNext)
    WHILE (Erg = _rOK)  DO BEGIN

      RekLink(560,561,1,0);     // Eingangsrechnung holen
      RekLink(814,560,6,0);     // Währung holen
      RekLink(100,560,5,0);     // Lieferant holen
      if (Adr.LieferantFibuNr='') then
      Adr.LieferantFibuNr # aint(Adr.LieferantenNr);

      if (Wae.Fibu.Code='') then Wae.Fibu.Code # "Wae.Kürzel";

      // Zahlungsart als Gegenkonto lesen
      _WriteZau(vFile);

      vCount # vCount + 1;

      RecRead(561,1,_recLock);
      ERe.Z.Fibudatum # Today;
      RekReplace(561,0,'AUTO');
    END;
  END;


  // -------------------------------------------------------------
  // - Datendatei: Datei schließen und ggf. Export Verbuchen
  vFile->FsiClose();

  Msg(450102,cnvai(vCount)+'|'+vPfad + cFilePrefix + 'SC_Zahlungsausgänge' + cFileExtention,0,0,0);


  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
end;

//========================================================================
//  sub _WriteZau(aFileHdl  : int)
//    Gibt einen Zahlungsausgang aus
//========================================================================
sub _WriteZau(
      aFileHdl        : int;
  )
local begin
  i : int;
  vFile : int;

  vUmsatz       : float;
  vSHKennz      : alpha(1);
  vWAEKurs      : float;
  vBasisUmsatz  : float;
  vGegenkonto   : int;
  vSteuerschl   : int;
  vFaelligDatum : alpha;
  vBuchungstext : alpha;
end;
begin
  vFile # aFileHdl;

   // Datensatz auf Basis einer kompletten Rechnung exportieren
  vUmsatz  # Abs(ERe.Z.BetragW1);
  if (ERe.Z.BetragW1 < 0.0 ) then
    vSHKennz # 'H';
  else
    vSHKennz # 'S';

  vWAEKurs        # "Ere.Währungskurs";
  vBasisUmsatz    #  Abs(ERe.Z.BetragW1);

  // --------------------------------------------------------------
  //  Datenanpassungen
  // --------------------------------------------------------------
  if  (vWAEKurs = 0.0) then
    vWAEKurs  # 1.0;

  vBuchungstext # 'Ausgangszahlung ' + Adr.Stichwort;

  // --------------------------------------------------------------
  //  Gegenkontoermittlung
  // --------------------------------------------------------------
  // Zahlungsart als Gegenkonto lesen
  vGegenkonto # ZAu.Zahlungsart;

  // --------------------------------------------------------------
  //  Export
  // --------------------------------------------------------------
  WriteNum(   vUmsatz,2);                     //   1   Umsatz (ohne Soll /Haben-Kz)
  WriteText(  vSHKennz,1);                    //   2   Soll /Haben-Kennzeichen
  WriteText(  Wae.Fibu.Code,3);               //   3   WKZ Umsatz
  WriteNum(   vWAEKurs,6);                    //   4   Kurs
  WriteNum(   vBasisUmsatz,2 );               //   5   Basis-Umsatz
  WriteText(  'EUR',3);                       //   6   WKZ Basis-Umsatz
  WriteText(  Adr.LieferantFibuNr,9);   //   7   Sach/Personenn Konto
  WriteZahl(  vGegenkonto);                   //   8   Gegenkonto
  WriteText(  StS.Fibu.Code,2);               //   9   BU Schlüssel
  WriteDatumKurz(Ere.Rechnungsdatum);         //  10   Belegdatum
  WriteText(  Ere.Rechnungsnr,12);            //  11   Rechnungs/Belegdatum
  WriteText(  '',12);                         //  12   Belegfeld2 (Fälligkeitsdatum für OPOS)
  WriteNum(   Ere.Z.SkontobetragW1,2);        //  13   Skonto (nur bei Zahlungen zulässig)
  WriteText(  vBuchungstext,60);              //  14   Buchungstext

  _WriteErloesEnd(vFile,'');
  WriteNewLine;
end;


//========================================================================
//  sub _Adr_ExportLine(aFileHdl : int)
//      Exportiert den Übergenen Adressdatensatz
//========================================================================
sub _Adr_ExportLine(aFileHdl : int; aTyp : alpha)
local begin
  vFile : int;
  i     : int;

  vKontonummer : alpha;

  vEULand  : alpha;
  vEUUstId : alpha;
  vSprachnr : int;

end
begin
  vFile   # aFileHdl;

  RekLink(110,100,15,0);  // Vertreter 1 lesen

  RekLink(812,100,10,0);  // Land Lesen

  case aTyp of
    'KUNDE' : begin
     if (Adr.KundenFibuNr='') then
      Adr.KundenfibuNr # aint(Adr.KundenNr);
      vKontonummer # Adr.KundenFibuNr;
    end;

    'LIEFERANT' : begin
      if (Adr.LieferantFibuNr='') then
      Adr.LieferantFibuNr # aint(Adr.LieferantenNr);
      vKontonummer # Adr.LieferantFibuNr;
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

  // Überschriften für Kreditoren/Debitoren generieren
  WriteText(vKontonummer,9 );                   //   1    Kontonummer
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
  WriteText(Lnd.IsoCode,2);                   //  20    Land
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
  WriteText(Lnd.IsoCode,2);                       //  44    Länderkennzeichen
  WriteText(Adr.Bank1.IBAN,32);               //  45    IBAN-Nr.
  WriteText('1',1);                            //  46    IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
  //WriteZahl(0);                             //  46    IBAN-Nr. Korrekt = 1

  WriteText(Adr.Bank1.BIC.SWIFT,11);          //  47    SWIFTCode
  WriteText('',70);                           //  48    Abw. Kontoinhaber
  WriteZahl(0);                               //  49    Kennz.Hauptbankverb. Ja = 1, nein = 0
  Write(cGueltigVon);                         //  50    Bankverb. Gültig von
  Write(cGueltigBis);                         //  51    Bankverb. Gültig bis

  if (Adr.Bank2.Name <> '') then begin
    WriteText(Adr.Bank2.BLZ,8);                 //  52    Bankleitzahl
    WriteText(Adr.Bank2.Name,30);               //  53    Bankbezeichnung
    Write(Adr.Bank2.Kontonr);                   //  54    Bank-Kontonummer
    WriteText(Lnd.IsoCode,2);                            //  55    Länderkennzeichen
    WriteText(Adr.Bank2.IBAN,32);               //  56    IBAN-Nr.
    WriteText('1',1);                            //  57    IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
  //WriteZahl(0);                               //  57    IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text

    WriteText(Adr.Bank2.BIC.SWIFT,11);          //  58    SWIFTCode
    WriteText('',70);                           //  59    Abw. Kontoinhaber
    WriteZahl(0);                               //  60    Kennz.Hauptbankverb. Ja = 1, nein = 0
    Write(cGueltigVon);                         //  61    Bankverb. Gültig von
    Write(cGueltigBis);                         //  62    Bankverb. Gültig bis
  end else begin
  WriteText('',8);                          //  41    Bankleitzahl
    WriteText('',30);                         //  42    Bankbezeichnung
    Write('');                                //  43    Bank-Kontonummer
    WriteText('',2);                          //  44    Länderkennzeichen
    WriteText('',32);                         //  45    IBAN-Nr.
    WriteText('',1);                          //  46    IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
    //WriteZahl(0);
    WriteText('',11);                         //  47    SWIFTCode
    WriteText('',70);                         //  48    Abw. Kontoinhaber
    Write('');                                //  49    Kennz.Hauptbankverb. Ja = 1, nein = 0
    Write('');                                //  50    Bankverb. Gültig von
    Write('');                                //  51    Bankverb. Gültig bis
  end;
  // Bankdaten  3-5                           //   63 - 95
  FOR i # 3 LOOP inc(i) WHILE i<=5 DO BEGIN
    WriteText('',8);                          //  41    Bankleitzahl
    WriteText('',30);                         //  42    Bankbezeichnung
    Write('');                                //  43    Bank-Kontonummer
    WriteText('',2);                          //  44    Länderkennzeichen
    WriteText('',32);                         //  45    IBAN-Nr.
    WriteText('',1);                          //  46    IBAN-Nr. Korrekt = 1    !!! ACHTUNG Fehler in Doku/Prüfprogramm Doku=Zahl Prüfprg. = Text
    //WriteZahl(0);
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

  vProgress # Lib_Progress:Init('Export',Lib_Mark:Count(100));

  FOR  vItem # gMarkList->CteRead(_CteFirst);
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

    RecRead(100,1,_recLock);
    if (Adr.KundenNr <> 0) then begin
      // Debitorenexport
      _Adr_ExportLine(vFile, 'KUNDE');
      Adr.Fibudatum.Kd # Today;
      vCount # vCount + 1;
    end;
    if (Adr.LieferantenNr <> 0) then begin
      // Kreditorenexport
      _Adr_ExportLine(vFile, 'LIEFERANT');
      Adr.Fibudatum.Lf # Today;
      vCount # vCount + 1;
    end;
    RekReplace(100,0,'MAN');

  END;
  vProgress->Lib_Progress:Term();


  // -------------------------------------------------------------
  // - Datendatei: Datei schließen und ggf. Export Verbuchen
  vFile->FsiClose();

  Msg(99,cnvai(vCount)+' Kreditoren und Debitoren wurden exportiert.',0,0,0);

end;



//========================================================================
//  sub OfP_Import()
//      Importiert die Offenen Posten aus einer XLS Datei
//========================================================================
sub Ofp_Import(opt aPathToFile : alpha(1000); opt aSilent : logic)
local begin
  Erx : int;
  
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
  vCteUnbekannteKunden : int;

  // Importierte Nutzdaten
  vKndBuchungsnr  : int;
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
  
  vBetragSteuer : float;
  
  vErr          : int;
  vReNrRoh      : alpha;
   
  vArchivPfad   : alpha(250);
  vspCustom     : alpha;
end;
begin
  if (gUsername= 'ST') then
    Set.Fibu.Pfad # 'C:\Debug\HWN\';
  

  if (aPathToFile = '') then begin
    // Datei auswählen
    vPfad # Lib_FileIO:FileIO(_WINCOMFILEOPEN,gMDI,Set.Fibu.Pfad,'*.txt;*.csv');
    if (vPfad = '') then
      RETURN;
  end else
    vPfad # aPathToFile;


  vFile # FSIOpen(vPfad, _FsiStdRead);
  if (vFile<=0) then begin
    if (aSilent = false) then
      Msg(99,'Datei nicht lesbar',_WinIcoError,_WinDialogOk,0);
    else
      Error(99,'Datei nicht lesbar:' + vPfad);
      
    RETURN;
  end;

  vMax # FsiSize(vFile);
  vPos # FsiSeek(vFile);

  vProgress # Lib_Progress:Init('Import Offene Posten Datei 1/6',vMax);
  vListOffeneOP # CteOpen(_CteList);

  // Zeile 1 und 2  überspringen
  FSIMark(vFile, 10);   /* LF */
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

    vTmp # Str_TOken(vA,';',1);                     //  1  - Debitorennr
    if (CnvIa(vTmp) <> 0) then
      vKndBuchungsnr  # CnvIa(vTmp);

    //  3  - Rechnungsnummer
    vReNrRoh # Str_TOken(vA,';',3);
    vReNrRoh # Str_ReplaceAll(vReNrRoh,'"','');

    try begin
      ErrTryCatch(_ErrCnv,y);
      vOposnr  # CnvIa(vReNrRoh);
    end;
    vErr # ErrGet();
    if (vErr <> _rOK) then
      vOposNr # 0;
    
    vBetrag       # CnvFa(Str_TOken(vA,';',8));       //  8  - Saldo
    
    vBetragSH     # StrAdj(Str_TOken(vA,';',9),_StrAll); //   9  - SOll Habenkennzeichen
    vBetragSH     # Str_ReplaceAll(vBetragSH,'"','');
    
    vSteuer       # CnvFa(Str_TOken(vA,';',20));     //  20  - Steuer %

if (vKndBuchungsnr = 10517) then
  debug('');
    // OP Merken
    vspCustom # vBetragSH+Anum(vBetrag,2)+ '|' + Aint(vKndBuchungsnr)+'|'+Anum(vSteuer,2);
    vListOffeneOP->CteInsertItem(Aint(vOposnr),vOposnr,vSpCustom);

  END;

  FSIClose(vFile);


  // AB hier sind alle noch offenen OPs eingelesen

  // ----------------------------------------------------------------------------
  // Kunden OPs zurücksetzen
  // ----------------------------------------------------------------------------
  vMax # RecInfo(100,_RecCount);
  vProgress->Lib_Progress:Reset('Löschung Fremd OPs 2/6',vMax);

  FOR   Erg # RecRead(100,1,_RecFirst)
  LOOP  Erg # RecRead(100,1,_RecNext)
  WHILE Erg = _rOK DO BEGIN
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
  vProgress->Lib_Progress:Reset('Verbuchung Offene Posten 3/6',vMax);

  FOR   Erg # RecRead(460,1,_RecFirst)
  LOOP  Erg # RecRead(460,1,_RecNext)
  WHILE Erg = _rOK DO BEGIN
    if (vProgress->Lib_Progress:Step() = false) then begin
      vProgress->Lib_Progress:Term();
      RETURN;
    end;


// ST 2017-01-04 Prj. 1548/204: immer komplett alle OFP aktualisieren,
//            da auch mal falsche Datei eingelesen wurde
/*
    if ("OfP.Löschmarker" <> '') then
      CYCLE;
*/
              
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
      if (OfP.RestW1 > 0.0) then
	      _CreateOPZahlung(0.0);

    end;

    // Nächster OP
  END;

  // ----------------------------------------------------------------------------
  // Restliche OPs an die Kunden schreiben
  // ----------------------------------------------------------------------------

  // Vorher alle Nettobeträge errechnen, damit später die gerundeten Werte stimmen
  vListAdrExtOP   # CteOpen(_CteList);

  vCteUnbekannteKunden # CteOpen(_CteList);


  vMax # CteInfo(vListOffeneOP,_CteCount);
  vProgress->Lib_Progress:Reset('Ermittlung Nettowerte OPs pro Kunde 4/6',vMax);
  FOR   vItem # vListOffeneOP->CteRead(_CteFirst);
  LOOP  vItem # vListOffeneOP->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) DO BEGIN
    if (vProgress->Lib_Progress:Step() = false) then begin
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

debug(vItem->spCustom);

    // Kundenbuchungsnummer extrahieren
    vTmp # Str_token(vItem->spCustom,'|',2);
    vKndBuchungsnr  # CnvIa(vTmp);
  if (vKndBuchungsnr  = 10517) then
    debug('');

    // Adresse lesen
    Adr.KundenNr      # vKndBuchungsnr;
    Erg # RecRead(100,2,0);
    if (Erg <= _rMultikey) AND (Adr.KundenNr = vKndBuchungsnr) then begin
      RecRead(100,1,0);

      // Beträge errechnen
      vBetragSH # StrCut(Str_token(vItem->spCustom,'|',1),1,1);
      vBetrag   # Rnd(Abs(CnvFa(Str_token(vItem->spCustom,'|',1))),2);
      if (vBetragSH='H') then
        vBetrag # -1.0 * vBetrag;
      vSteuer   # Abs(CnvFa(Str_token(vItem->spCustom,'|',3)));

  
      // ST Korrektur Nettobetragserrechnung
      vBetragSteuer  #  Rnd(vBetrag / 100.0 * vSteuer,2);
      //vBetragNetto # vBetrag / (vSteuer / 100.0 + 1.0);
      vBetragNetto # vBetrag - vBetragSteuer;

  
      vItemAdr # vListAdrExtOP->CteRead(_CteFirst | _CteSearch,0,Aint(Adr.Nummer));
      if (vItemAdr = 0) then begin
        // Kunde noch nicht drin, Eintragen
        vListAdrExtOP->CteInsertItem(Aint(Adr.nummer),Adr.Nummer,Anum(vBetrag,7) + '|' + Anum(vBetragNetto,7));
      end
      else begin
        // Kunde schon in Liste -> Wert Updaten
        vBetrag       # CnvFa(Str_token(vItemAdr->spCustom,'|',1)) + vBetrag;
        vBetragNetto  # CnvFa(Str_token(vItemAdr->spCustom,'|',2)) + vBetragNetto;
        vItemAdr->spCustom # Anum(vBetrag,7) + '|' + Anum(vBetragNetto,7);
      end;

    end;
    /*
    else begin
      
      vItemAdr # vCteUnbekannteKunden->CteRead(_CteFirst | _CteSearch,0,Aint(Adr.KundenNr));
      if (vItem <= 0) then begin
        vListAdrExtOP->CteInsertItem(Aint(Adr.KundenNr),Adr.KundenNr,'');
        Msg(99,Translate('Keine Adresse für Debitoren-Buchungsnummer ' + Aint(Adr.KundenNr)+ ' gefunden.'),_WinIcoError,_WinDialogOk,0);
      end;
      
    end;
    */

  END;
  vListOffeneOP->cteClose();
  vCteUnbekannteKunden->cteClose();


  // Pro Adresse die Summen Runden und verbuchen
  vMax # CteInfo(vListAdrExtOP,_CteCount);
  vProgress->Lib_Progress:Reset('Verbuchung externe Offene Posten 5/6',vMax);
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
  
  
  vMax # RecInfo(100,_RecCount)
  vProgress->Lib_Progress:Reset('Aktualisiere Kundensummen 6/6',vMax);
  FOR   Erx # RecRead(100,1,_RecFirst)
  LOOP  Erx # RecRead(100,1,_RecNext)
  WHILE Erx = _rOK DO BEGIN
    vProgress->Lib_Progress:Step();
    if (Adr.KundenNr > 0) then
      Adr_Data:BerechneFinanzen();
  END;
  
  vProgress->Lib_Progress:Term();



  // ST 2022-01-12 2343/2: Datei nach Impoort verschieben
  vArchivPfad # FsiSplitName(vPfad,_FsiNameP) + 'Erledigt\';
  Lib_FileIO:CreateFullPath(vArchivPfad);
    
  vArchivPfad # vArchivPfad + Lib_FileIo:StampFilename(FsiSplitName(vPfad,_FsiNameNE));
  Erx # Lib_FileIo:FsiCopy(vPfad,vArchivPfad,true);
  if (Erx < 0) then begin
    MsgErr(99,'Datei konnte nicht in den Erledigt Ordner verschoben werden');
  end;

  if(aSilent = false) then
    Msg(99,Translate('Import abgeschlossen'),_WinIcoInformation,_WinDialogOk,0);
    
  Erx # _rOK;
  ErrSet(Erx);
end;




//========================================================================
//  sub OfP_Import_Job(aPara : alpha) : logic
//   Importjob für Jobserver
//========================================================================
sub OfP_Import_Job(aPara : alpha) : logic
local begin
  vRet          : logic;
  vPathToFile   : alpha(1000);
  vHdl          : int;
end
begin
 
  vPathToFile # _GetPath('Import', true) + 'Offene_Posten.csv';
  Ofp_Import(vPathToFile, true);
            
  // Fehlerhandling und Rückgabe
  vRet # (ErrList = 0);
  ErrorOutput;
  RETURN vRet;
end;



//========================================================================
//  _KillOPZahlungen
//
//========================================================================
SUB _KillOPZahlungen();
begin
  // alle Zahlungen + Zahlungseingang löschen...
  WHILE (RecLink(461,460,1,_recFirst)<=_rLocked) do begin
    Erg # RecLink(465,461,2,_recFirst);   // Zahlungseingang holen
    if (erg<=_rLocked) then
      RekDelete(465,0,'AUTO');
    RekDelete(461,0,'AUTO');
  END;

  RecRead(460,1,_recLock);
  OfP.Zahlungen   # 0.0;
  OfP.ZahlungenW1 # 0.0;
  OfP.Rest        # OfP.Brutto;
  OfP.RestW1      # OfP.BruttoW1;
  "OfP.Löschmarker" # '';
  RekReplace(460,_RecUnlock,'AUTO');

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

  // Keine Zahlung für OFP, wenn die REchnung noch nicht exportiert wurde
  RekLink(450,460,2,0);
  if (Erl.FibuDatum = 0.0.0) then
    RETURN;

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