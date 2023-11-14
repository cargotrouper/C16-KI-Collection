@A+
//===== Business-Control =================================================
//
//  Prozedur    Fibu_Lexware
//                  OHNE E_R_G
//  Info
//        Fibu für Financial Office Pro
//        - Einzelbuchungsexport
//
//
//  29.08.2011  ST  Erstellung der Prozedur
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  WriteA(a,b) : vString # vString + '"'+ StrCut( Check(a) ,1,b) +'";';
  WriteI(a,b) : vString # vString + '"'+ StrCut( AInt(a) ,1,b) +'";';
  WriteN(a,b) : vString # vString + '"'+ cnvaf(a,_FmtNumNoGroup,0,b) +'";';
  WriteD(a)   : vString # vString + '"'+ Cnvai(DateDay(a),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) +  Cnvai(DateYear(a)-100,_FmtNumLeadZero,0,2) + '";';
  EOL         : vString # StrCut(vString,1,StrLen(vString)-1) + strchar(13)+strchar(10);
end;

//========================================================================
//  Check
//
//========================================================================
sub Check(
  aA  : alpha
) : alpha;
begin
  aA # Str_ReplaceAll(aA, '"', StrChar(39));  // " -> '
  RETURN aA;
end;


//========================================================================
//  Erl_Export
//
//========================================================================
sub Erl_Export()
local begin
  Erx     : int;
  vName   : alpha;
  vFile   : int;
  vString : alpha(1000);
  vCount  : int;

  vItem   : int;
  vMFile  : Int;
  vMID    : Int;

  vKonto  : int;
  vUstKto : int;
end;

begin

  if (Set.Fibu.Pfad = '') then
    Set.Fibu.Pfad # 'c:\';

  vName # Set.Fibu.Pfad + 'lexware_erloese.txt';
  if (Msg(450103,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN;
  vFile # FSIOpen(vName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate | _FsiANSI);
  if (vFile<=0) then begin
    Msg(450104,vName,0,0,0);
    RETURN;
  end;


  // Header schreiben
  vString # '';
  WriteA('Belegdatum',10);
  WriteA('Belegnummer',10);
  WriteA('Buchungstext',79);
  WriteA('Sollkonto',9);
  WriteA('Habenkonto',9);
  WriteA('Buchungsbetrag EUR',9);
  EOL;
  FsiWrite(vFile,vString);       // Datei schreiben


  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(450,0,0,vMID);          // Satz holen
    if (Erl.StornoRechNr<>0) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
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

    Erx # RecLink(816,460,8,_recFirst);     // Zahlungsbed.-holen
    if (Erx>=_rLocked) then RecBufClear(816);

    Erx # RecLink(814,450,3,_recFirst);     // Währung holen
    if (Erx>=_rLocked) then RecBufClear(814);
    if (Wae.Fibu.Code='') then Wae.Fibu.Code # "Wae.Kürzel";

    // Gegenkonto ermitteln
    vKonto # 0;
      // Kontenplan...
      vKonto # ("Erl.K.Erlöskonto" * 10) + 85001;

    vUstKto # 0;

    // -----------------------------
    // Einzelbuchung Start
    // Einzelne Konten werden von Grüber nicht benötigt
    vString # '';

// 1. Zeile
    // Belegdatum 30.01.2222
    WriteD(Erl.Rechnungsdatum);

    // Belegnummer Alpha 10
    WriteI(Erl.Rechnungsnr,10);

    // Buchungstext Alpha 79
    WriteA(Erl.KundenStichwort,79);

    // Sollkonto Debitorennummer Num (9)
    WriteI(cnvia(Adr.KundenFibuNr),9);

    // Habenkonto Num(9)    vKonto
    WriteI(vKonto,9);

    // Buchungsbetrag EUR Netto   (250,00)
    WriteN(Erl.NettoW1,2);
    EOL;

// 2. Zeile
    // -
    WriteA('',10);

    // -
    WriteA('',10);

    // Buchungstext Alpha 79
    WriteA(Erl.KundenStichwort,79);

    // Sollkonto Debitorennummer Num (9)
    WriteI(cnvia(Adr.KundenFibuNr),9);

    // Ust. Konto
    WriteI(vUstKto,9);

    // Steuerbetrag EUR Netto   (12,00)
    WriteN(Erl.SteuerW1,2);
    EOL;

// 3. Zeile
    // Summe:
    WriteA('Summe:',10);

    // -
    WriteA('',10);

    // -
    WriteA('',79);

    // -
    WriteA('',9);

    // -
    WriteA('',9);

    // Brutto EUR (262,00)
    WriteN(Erl.BruttoW1,2);
    EOL;

    // Nächster Eintrag
    FsiWrite(vFile,vString);       // Datei schreiben

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  FSIClose(vfile);            // Datei schliessen

/*
  TRANSON;
xx loop
    RecRead(450,1,_recLock);
    Erl.Fibudatum # Today;
    RekReplace(450,_recUnlock,'AUTO');
xx
  TRANSOFF;
*/
  Msg(450102,cnvai(vCount)+'|'+vName,0,0,0);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
end;



//========================================================================
//  Adr_Export
//
//========================================================================
sub Adr_Export()
local begin
  Erx     : int;
  vName   : alpha;
  vFile   : int;
  vString : alpha(1000);
  vCount  : int;
end;
begin

  if (Set.Fibu.Pfad = '') then
    Set.Fibu.Pfad # 'c:\';
  vName # Set.Fibu.Pfad + 'lexware_personenkonten.txt';
  vFile # FSIOpen(vName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate | _FsiANSI);
  if (vFile<=0) then begin
    Msg(450104,vName,0,0,0);
    RETURN;
  end;

  // Header schreiben
  vString # '';
  WriteA('Kontonummer',9);
  WriteA('Kontobezeichnung',79);
  WriteA('Kundennummer',19);
  WriteA('Anrede',29);
  WriteA('Firma',59);
  WriteA('Name',34);
  WriteA('Vorname',34);
  WriteA('Zusatz',59);
  WriteA('Land',34);
  WriteA('Straße',34);
  WriteA('Hausnummer',5);
  WriteA('Postleitzahl',9);
  WriteA('Ort',34);
  WriteA('Ansprechpartner',59);
  WriteA('Telefon1',19);
  WriteA('Telefon2',19);
  WriteA('Telefax',19);
  WriteA('E-Mail',59);
  WriteA('Bankleitzahl',8);
  WriteA('Bankkonto',8);
  WriteA('Bankbezeichnung',59);
  WriteA('BIC',11);
  WriteA('IBAN',30);
  WriteA('Zahlungsziel',3);
  WriteA('Skonto %',5);
  WriteA('Skonto Ziel',3);
  WriteA('Skonto2 %',5);
  WriteA('Skonto2 Ziel',3);
  WriteA('Einzugsermächtigung',1);
  WriteA('UStIDNr.',16);
  EOL;
  FsiWrite(vFile,vString);       // Datei schreiben


  FOR  Erx # RecRead(100,1, _recFirst);
  LOOP Erx # RecRead(100,1, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    inc(vCount);

    if (cnvia(Adr.KundenFibuNr)=0) then Adr.KundenFibuNr # aint(Adr.KundenNr);

    Erx # RecLink(816,100,7,_recFirst);     // Zahlungsbed.-holen
    if (Erx>=_rLocked) then RecBufClear(816);

    Erx # RecLink(812,100,10,_recFirst);     // Land holen
    if (Erx>=_rLocked) then RecBufClear(812);

    vString # '';
    WriteI(cnvia(Adr.KundenFibuNr),9);       // Kontonummer
    WriteA(Adr.Stichwort,79);         // Kontobezeichnung
    WriteI(Adr.KundenNr,19);          // Kundennummer
    WriteA(Adr.Anrede,29);            // Anrede
    WriteA(Adr.Name,59);              // Firma
    WriteA('',34);                    // Name
    WriteA('',34);                    // Vorname
    WriteA(Adr.Zusatz,59);            // Zusatz
    WriteA(Lnd.Name.L1,34);           // Land
    WriteA("Adr.Straße",34);          // Straße
    WriteA('',5);                     // Hausnummer         --> Gibts nich
    WriteA(Adr.PLZ,9);                // Postleitzahl
    WriteA(Adr.Ort,34);               // Ort
    WriteA('',59);                    // Ansprechpartner    --> Gibts nich
    WriteA(Adr.Telefon1,19);          // Telefon1
    WriteA(Adr.Telefon2,19);          // Telefon2
    WriteA(Adr.Telefax,19);           // Telefax
    WriteA(Adr.Email,59);             // E-Mail
    WriteA(Adr.Bank1.BLZ,8);          // Bankleitzahl
    WriteA(Adr.Bank1.KontoNr,8);      // Bankkonto
    WriteA(Adr.Bank1.Name,59);        // Bankbezeichnung
    WriteA(Adr.Bank1.BIC.Swift,11);   // BIC
    WriteA(Adr.Bank1.IBAN,30);        // IBAN
    WriteI("ZaB.Fällig1.Zieltage",3); // Zahlungsziel
    WriteN(ZaB.Sknt1.Prozent,2);      // Skonto %
    WriteI(ZaB.Sknt1.Tage,3);         // Skonto Ziel
    WriteN(ZaB.Sknt2.Prozent,2);      // Skonto2 %
    WriteI(ZaB.Sknt2.Tage,3);         // Skonto2 Ziel
    WriteA('0',1);                    // Einzugsermächtigung 1 oder 0
    WriteA(Adr.USIdentNr,16);         // UStIDNr.
    EOL;
    FsiWrite(vFile,vString);       // Datei schreiben
  END;

  FSIClose(vfile);            // Datei schliessen
  Msg(450107,cnvai(vCount)+'|'+vName,0,0,0);
  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
end;


//========================================================================