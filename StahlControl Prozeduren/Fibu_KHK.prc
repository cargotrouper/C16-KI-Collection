@A+
//===== Business-Control =================================================
//
//  Prozedur    Fibu_KHK
//                    OHNE E_R_G
//  Info
//        1 RAD31 + N RAE31
//
//
//  20.11.2007  AI  Erstellung der Prozedur
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  WriteA(a,b) : vString # vString + '"'+ StrCut( Check(a) ,1,b) +'",';
  WriteI(a,b) : vString # vString + '"'+ StrCut( AInt(a) ,1,b) +'",';
  WriteN(a,b) : vString # vString + '"'+ cnvaf(a,_FmtNumNoGroup | _FmtNumPoint,0,b) +'",';
  WriteD(a)   : vString # vString + '"'+ Cnvai(DateDay(a),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) +  Cnvai(DateYear(a)-100,_FmtNumLeadZero,0,2) + '",';
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
  vVonDat : date;
  vBisDat : date;
  vName   : alpha;
  vFile   : int;
  vString : alpha(1000);
  vCount  : int;

  vZKondi : alpha;
  vI      : int;
  vN      : float;

  vItem   : int;
  vMFile  : Int;
  vMID    : Int;

  vOK     : logic;
  vSCount : int;
  vSCode  : int[10];
  vSFremd : float[10];
  vSEigen : float[10];
  vKonto  : int;
end;

begin

  vName # 'c:\KHK.txt';

  if (Msg(450103,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN;
  vFile # FSIOpen(vName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vName,0,0,0);
    RETURN;
  end;

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


    vSCount # 1;
    Erx # RecLink(451,450,1,_RecFirst);   // Konten loopen
    WHILE (Erx<=_rLockeD) do begin
      vOK # n;
      FOR vI # 1 LOOP inc(vI) WHILE (vI<vSCount) and (vOK=n) do begin
        if (vSCode[vI]=Erl.K.Steuerschl) then begin
          vSFremd[vI] # vSFremd[vI] + Erl.K.Betrag;
          vSEigen[vI] # vSEigen[vI] + Erl.K.BetragW1;
          vOK # y;
        end;
      END;
      if (vOK=n) then begin // neuen Stuercode anlegen
        vSCode[vSCount]   # Erl.K.Steuerschl;
        vSFremd[vSCount]  # Erl.K.Betrag;
        vSEigen[vSCount]  # Erl.K.BetragW1;
        vSCount # vSCount + 1;
      end;

      Erx # RecLink(451,450,1,_recNext);
    END;


    // Zahlungskondition aufbauen
    if (Ofp.Zieldatum<>0.0.0) then begin
      vI # cnvid(Ofp.Zieldatum)-cnvid(Erl.Rechnungsdatum);
      if (vI<5000) and (vI>=0) then ZaB.Sknt1.FixTag # vI;
    end;
    if (Ofp.Skontodatum<>0.0.0) then begin
      vI # cnvid(Ofp.Skontodatum)-cnvid(Erl.Rechnungsdatum);
      if (vI<5000) and (vI>=0) then ZaB.Sknt1.Tage # vI;
    end;
    ZaB.Sknt1.Prozent # Ofp.Skontoprozent;
    vZKondi # cnvai(ZaB.Sknt1.Tage,_FmtNumLeadZero,0,3)+
              cnvaf(ZaB.Sknt1.Prozent*100.0,_FmtNumLeadZero,0,0,4)+
              '000'+
              '0000'+
              cnvai(ZaB.Sknt1.FixTag,_FmtNumLeadZero,0,3);

    vString # '';

    // Satz-Kennung
    WriteA('RAD35',5);
    // Buchungstext1 (1 oder 20), 0=RE, 1=StornoRe, 2=GS
    WriteA('0',1);
    // Buchungstext2
    WriteA(Adr.Stichwort,20);
    // Rechnungsnr.
    WriteI(Erl.Rechnungsnr,20);
    // Rechnungsdatum
    WriteD(Erl.Rechnungsdatum);
    // OP-Nummer
    WriteI(Erl.Rechnungsnr,20);
    // Verwendungszweck
    WriteA('Ausgangsrechnung',30);
    // Debitor
    WriteI(cnvia(Adr.KundenFibuNr),10);
    // Kostenstelle (5-10 oder leer)
    WriteA('',10);
    // Buchungskreis
    WriteA('01',2);
    // KZ : 0=Brutto/1=Netto
    WriteA('0',1);
    // Mahnkennzeichen: 1.=10, 2.=20, 3.=30
    WriteA('',2);
    // Zahlungstyp: 0=selbst, 1=bank, 2=Nachnahme
    WriteA('0',1);
    // Zahlungskondition
    WriteA(vZKondi,17);
    // Währung (3 oder 6)
//      WriteA('EUR',3);
    WriteA(Wae.Fibu.Code,3);
    // KZ Bezungseinheit Währung (0=0.001, 1=0.01, 2=0.1, 3=1...)
    WriteI(0,1);
    // Nachkomma
    WriteI(0,1);
    // Valutadatum
    WriteD(Erl.Rechnungsdatum);
    // Vertreter
    WriteI(Erl.Vertreter,3);
    // Provision
    WriteN(0.0,4);
    // WährungsKurs
    WriteN(1.0,0);
    // Bruttobetrag FW
    WriteN(Erl.Brutto,2);
    // Nettobetrag FW
    WriteN(Erl.Netto,2);
    // Bruttobetrag EW
    WriteN(Erl.BruttoW1,2);
    // Nettobetrag EW
    WriteN(Erl.NettoW1,2);

    // 9 Steuerblöcke ...
    FOR vI # 1 LOOP inc(vI) WHILE (vI<=9) do begin
      RecBufClear(813);
      if (vSCode[vI]<>0) then begin
        StS.Nummer # vSCode[vI];
        Erx # RecRead(813,1,0);   // Steuerschlüssel holen
        if (Erx>_rLocked) then RecBufClear(813);
      end;

      // Code
      if (StS.Fibu.Code='') then
        WriteA('000',3)
      else
        WriteA(StS.Fibu.Code,3)
      vN # StS.Prozent * vSFremd[vI] / 100.0;
      WriteN(vSFremd[vI],2);
      WriteN(vN,2);

      vN # StS.Prozent * vSEigen[vI] / 100.0;
      WriteN(vSEigen[vI],2);
      WriteN(vN,2);
    END;

    EOL;
    FsiWrite(vFile,vString);       // Datei schreiben


    Erx # RecLink(451,450,1,_RecFirst);   // Konten loopen
    WHILE (Erx<=_rMultikey) do begin

      // Kontenplan...
      vKonto # ("Erl.K.Erlöskonto" * 10) + 85001;


      vString # '';

      // Kennung
      WriteA('RAE31',5);
      // Erlöskonto (2 oder 10)
      WriteI(vKonto,10);
      // SammelkontoKZ
      WriteA('',1);
      // Buchungskreis
      WriteA('01',2);
      // Kostenträger (5-10 oder leer)
      WriteA('',10);

      // 9 Steuerblöcke...
      StS.Nummer # Erl.K.Steuerschl;
      Erx # RecRead(813,1,0);   // Steuerschlüssel holen
      if (Erx>_rLocked) then RecBufClear(813);

      // Code
      if (StS.Fibu.Code='') then
        WriteA('000',3)
      else
        WriteA(StS.Fibu.Code,3)
      WriteN(Erl.K.Betrag,2);
      WriteN(Erl.K.BetragW1,2);

      FOR vI # 2 LOOP inc(vI) WHILE (vI<=9) do begin
        WriteA('000',3)
        WriteN(0.0,2);
        WriteN(0.0,2);
      END;

      EOL;
      FsiWrite(vFile,vString);       // Datei schreiben

      Erx # RecLink(451,450,1,_RecNext);
    END;  // Konten

    vItem # gMarkList->CteRead(_CteNext,vItem);
//    gMarkList->CteDelete(vItem);
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