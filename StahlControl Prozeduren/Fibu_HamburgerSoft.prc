@A+
//===== Business-Control =================================================
//
//  Prozedur    Fibu_HamburgerSoft
//                      OHNE E_R_G
//  Info
//    Fibuexport für Hamburger-Software-Fibu  (MaWe)
//      - Erlöse:     JA
//      - Adressen:   NEIN
//      - Verbindl.:  NEIN
//
//  04.10.2012  ST  Erstellung der Prozedur
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
//  Write(a,b)      : GV.Alpha.01 # Format(a,b,n);ExtWrite(1,Format(a,b,n));
//  Satzende        : ExtWrite(1, Char(10));
//  WriteN(a,b,c)   : GV.Alpha.01 # Alpha(a,b,c,n,y);ExtWrite(1,Alpha(a,b,c,n,y));
//  WriteZ(a,b,c)   : if a<0 then GV.Alpha.01 # Alpha(a*(-1),b,c,n,y)+'-' else Gv.Alpha.01 # Alpha(a,b,c,n,y)+'+';ExtWrite(1,Gv.Alpha.01);
//  WriteD(a)       : If a <> Date(0) then GV.Alpha.01 # Alpha(Year(a)-100,2,0,n,y)+Alpha(Month(a),2,0,n,y)+Alpha(Day(a),2,0,n,y) else Gv.Alpha.01 # '      ';ExtWrite(1,Gv.Alpha.01);

  WriteA(a,b) : FsiWrite(vFile, StrCut( Check(a),1,b));//+StrChar(13)+StrChar(10));
  WriteI(a,b) : FsiWrite(vFile, StrCut( Check(cnvai(a,_FmtNumNoGroup|_FmtNumLeadZero | _FmtNumPoint)),1,b));
  WriteN(a,b,c) : FsiWrite(vFile, cnvaf(a,_FmtNumNoGroup|_FmtNumLeadZero| _FmtNumPoint ,0,c,c+1+b));
  WriteD(a)   : FsiWrite(vFile, Cnvai(DateDay(a),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) + Cnvai(DateYear(a)-100,_FmtNumLeadZero,0,2));
  EOL         : FsiWrite(vFile, strchar(13)+strchar(10));

  //
end;

//========================================================================
//  Check
//
//========================================================================
sub Check(
  aA  : alpha
) : alpha;
begin
  // aA # Str_ReplaceAll(aA, ',', '.');  // , -> .
  aA # StrFmt(aA,80,_StrEnd);

  RETURN aA;
end;


//========================================================================
//  Erl_Export
//
//========================================================================
sub Erl_Export() : logic;
local begin
  Erx         : int;
  vDateiname  : alpha;
  vFile       : handle;
  vStapel     : int;
  vLfdNr      : int;
  vStapelPos  : int;
  vItem       : handle;
  vMFile      : int;
  vMID        : int;
  vCount      : int;
  vA          : alpha;
  vN          : float;
  vI          : int;

/*
  vFirma      : alpha;
  vAppli      : alpha;
  vSachKonto  : int;
*/
  vMyUstID    : alpha;
  vKonto       : alpha;
  vSteuer       : alpha;
end;
begin

  Adr.Nummer # Set.EigeneAdressnr;
  Erx # RecRead(100,1,0);   // eigene Adresse holen
  if (Erx>_rLockeD) then RETURN false;
  vMyUstID # Adr.USIdentNr;


//  vDateiname # 'M:\Daten\hs\FI.DF';
  vDateiname # 'c:\FI.DF';

  vFile # FSIOpen(vDateiName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vDateiName,0,0,0);
    RETURN false;
  end;


  // --------------------------------------------------
  // Versionssatz schreiben
  WriteA('I', 1);                     // Satztyp
  WriteA('',  2);                     // Übernahme KZ
  WriteA('$', 1);                     // Satzart
  WriteA('3', 1);                     // Version
  WriteA('',148);                     // Reserviert
  EOL;


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


    // KEINE Lieferantenerlöse...
    Erx # RecLink(451,450,1,_RecFirst);   // 1.Erloeskonto holen
    if (Erx<=_rLocked) then begin
      Auf.Nummer # Erl.K.Auftragsnr;
      Erx # RecRead(400,1,0);             // Auftrag holen
      if (Erx > _rLocked) then begin
        "Auf~Nummer" # Erl.K.Auftragsnr;
        Erx # RecRead(410,1,0);             // Auftrag holen
        if (Erx > _rLocked) then RecBufClear(400)
        else RecbufCopy(410,400);
      end;
      if (Auf.Vorgangstyp=c_Gut) or (Auf.Vorgangstyp=c_Bel_LF) then begin
        vItem # gMarkList->CteRead(_CteNext,vItem);
        CYCLE;
      end;
    end;

/*
    vCount # vCount + 1;
*/
    vlfdNr # vlfdNr + 1;


    Erx # RecLink(100,450,8,0);       // Rechnungsempfänger holen
    if (cnvia(Adr.KundenFibuNr)=0) then Adr.KundenFibuNr # aint(Adr.Kundennr);

    Erx # RecLink(816,450,15,0);      // Zahlungsbed. holen

    Erx # RecLink(451,450,1,_recFirst);       // 1. Erlös holen
    if (Erx>_rLocked) then RecBufCleaR(451);

    Erx # RecLink(835,451,5,0);      // Auftragsart holen
    if (Erx>_rLocked) then RecBufCleaR(835);

    Erx # RecLink(460,450,2,0);      // Offenen Posten holen
    if (Erx>_rLocked) then RecBufCleaR(460);



    // --------------------------------------------------
    // Kontenrahmen ermitteln
    vKonto # '';
    vSteuer # '';

    // Vollgeschäftverkauf
    if (AAr.Berechnungsart = 200) then begin

      CASE (Erl.Adr.Steuerschl)  of
        1,5 :     begin vKonto # '8010';    vSteuer # 'M19';  end;  // Inland
        3,4 :     begin vKonto # '8016';    end;  // Ausland ohne Mwst
        otherwise begin vKonto # '8015';    end;  // Export
      end;

    end else
    // Lohngeschäfte
    if (AAr.Berechnungsart > 700) then begin
      CASE (Erl.Adr.Steuerschl)  of
        1,5 :     begin vKonto # '8050';    vSteuer # 'M19';  end;  // Inland
        3,4 :     begin vKonto # '8061';    end;  // Ausland ohne Mwst
        otherwise begin vKonto # '8060';    end;  // Export
      end;

    end;

    // --------------------------------------------------
    // Buchungssatz schreiben
    WriteA('3',   1);                   // Satzkennzeichen
    WriteA('',    2);                   // Übernahme KZ
    WriteA('B',   1);                   // Satzart
    WriteA('FI',  2);                   // Buchungssystem=FInanzbuchh.
    WriteA('A',   1);                   // Aktive Buchung
    WriteA('',    1);                   // Buchungskreis
    WriteA('01',  2);                   // Firma
    WriteA('',    20);                  // Buchungstext
    WriteI(Erl.Rechnungsnr,20);         // Fremdbelegnummer
    WriteA(vSteuer,3);                  // Steuerschluessel
    WriteA('',    3);                   // Zahlungsbedingung
    WriteA('',    3);                   // Tage Nettofaelligkeit
    WriteA('',    3);                   // Tage Skontofaelligkeit
    WriteN(Erl.Skontoprozent,2,2);      // Skonto% 2.2
    WriteA('',    7);                   // Satznummer - leer=autoinc.
    WriteD(Erl.Rechnungsdatum);         // Buchungsdatum TTMMJJ
    WriteD(Erl.Rechnungsdatum);         // Belegdatum
    WriteD(Erl.Zieldatum);              // OP-Faelligkeitdatum

    if (Erl.Skontodatum <> 0.0.0) then  // Skontofällikgeitsdatum
      WriteD(Erl.Skontodatum);
    else
      WriteA('000000',6);

    WriteA('',    7);                   // Kostenstelle
    WriteI(Erl.Rechnungsnr,7);          // Belegnummer
    WriteA(vKonto,    7);               // Konto-Haben
    WriteI(cnvia(Adr.KundenFibuNr),7);         //  Konto-Soll
    WriteA('',    7);                   // Beleg-Konto-Haben
    WriteA('',    7);                   // Beleg-Konto-Soll
    WriteN(Erl.BruttoW1,9,2);           // Buchungsbetrag 9.2 (Brutto)
    WriteA('',    1);                   // Vorzeichen
    WriteA('',    7);                   // USt-Id-Konto - sonst:
    WriteA(Adr.USIdentNr, 15);          // USt-Id-Nr
    WriteA('',    20);                  // Buchungstext2
    WriteA('EUR', 3);                   // Währung

    EOL;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;


  WriteA(StrChar(26),1);                 // Dateiendzeichen

  FSiClose(vFile);

  Msg(450102,cnvai(vCount)+'|'+vDateiName,0,0,0);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);


end;


//========================================================================