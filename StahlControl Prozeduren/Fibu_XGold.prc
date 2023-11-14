@A+
//===== Business-Control =================================================
//
//  Prozedur    Fibu_XGold
//                  OHNE E_R_G
//  Info
//
//
//  04.09.2017  AH  Erstellung der Prozedur
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  cKonzern    : 3247
  cFirma      : 3247


  WriteA(a,b) : FsiWrite(vFile, StrFmt(a,b,_StrEnd))
  WriteI(a,b) : FsiWrite(vFile, StrCut( cnvai(a,_FmtNumNoGroup|_FmtNumLeadZero),1,b))
  WriteN(a,b,c) : FsiWrite(vFile, cnvaf(abs(a)*100.0,_FmtNumNoGroup|_FmtNumLeadZero ,0,0, b+c))
  WriteD(a)   : FsiWrite(vFile, Cnvai(DateYear(a),_FmtNumLeadZero,0,4) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) +  Cnvai(DateDay(a),_FmtNumLeadZero,0,2))
  WriteEOL    : FsiWrite(vFile, strchar(13)+strchar(10))
end;


//========================================================================
//========================================================================
sub _Write451(
  aFile     : int;
  aKonzern  : int;
  aFirma    : int;
  aGegen    : int);
local begin
  vFile     : int;
end;
begin
  vFile # aFile;
                                      // KONZERN
  WriteI(aKonzern,4);
                                      // FIRMA
  WriteI(aFirma,4);
                                      // BUCH-VORZ
  if (Erl.BruttoW1>=0.0) then
    WriteA('+',1)
  else
    WriteA('-',1);
                                      // BUCH-NUMMER
  WriteA(cnvai(Erl.Rechnungsnr),18);
                                      // KTO-QUAL
  WriteA(' ',1);
                                      // KTO
  WriteI(aGegen,8);
                                      // BUCH-BTR-VORZ'
  if (Erl.K.BetragW1>=0.0) then
    WriteA('+',1)
  else
    WriteA('-',1);
                                      // BUCH-BTR
  WriteN(Erl.K.BetragW1, 16,2);
                                      // BUCH-TEXT
  WriteA(Erl.K.Bemerkung,24);
                                      // KOSTST
  WriteI(0, 6);
                                      // KOSTTR
  WriteA('', 10);
                                      // MENGE-VORZ
  if (Erl.K.Menge>=0.0) then
    WriteA('+',1)
  else
    WriteA('-',1);
                                      // MENGE
  WriteN(Erl.K.Menge, 15,3);
  WriteEOL;
end;


//========================================================================
//  Erl_Export
//
//========================================================================
sub Erl_Export() : logic;
local begin
  Erx         : int;
  vDateiname  : alpha(1000);
  vFile       : handle;
  vFile2      : handle;
  vItem       : handle;
  vMFile      : int;
  vMID        : int;
  vCount      : int;

  vGegen      : int;
  vTxt        : int;
  vI          : int;
  vA          : alpha;
end;
begin

//  Adr.Nummer # Set.EigeneAdressnr;
//  Erx # RecRead(100,1,0);   // eigene Adresse holen
//  if (Erx>_rLocked) then RETURN false;
//  vMyUstID # Adr.USIdentNr;

  // KOPF ---------------------------------------------------------------------------------
  vDateiname  # 'd:\fibu\grass\_by_SC_ufiin.txt';
  vFile # FSIOpen(vDateiName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vDateiName,0,0,0);
    RETURN false;
  end;

  vTxt # TextOpen(16);

  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext)
  WHILE (vItem > 0) do begin

    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then CYCLE;

    RecRead(450,0,0,vMID);          // Satz holen

    Erx # RecLink(100,450,8,_recFirst);       // Rechnungsempfänger holen
    if (cnvia(Adr.KundenFibuNr)=0) then Adr.KundenFibuNr # aint(Adr.Kundennr);

    Erx # RecLink(816,450,15,_recFirst);      // Zahlungsbed. holen

    Erx # RecLink(451,450,1,_recFirst);       // 1. Erlös holen
    if (Erx>_rLocked) then RecBufClear(451);
    Erx # RecLink(813,451,10,_recFirst);      // Steuerschluessel holen
    if (Erx>_rLocked) then RecBufClear(813);

    // OP holen...
    Erx # Ofp_data:read(Erl.Rechnungsnr);
    if (Erx<460) then CYCLE;

    vGegen  # 140990;
                                      // ERROR-FLAG
    WriteI(0,4);
                                      // KONZERN
    WriteI(cKonzern,4);
                                      // FIRMA
    WriteI(cFirma,4);
                                      // BUCH-VORZ
    if (Erl.BruttoW1>=0.0) then
      WriteA('+',1)
    else
      WriteA('-',1);
                                      // BUCH-NUMMER
    WriteA(cnvai(Erl.Rechnungsnr),18);
                                      // BUCH-DAT
    WriteD(Erl.Rechnungsdatum);
                                      // BUCH-ART (1020=Ausgangsre.)
    WriteI(1020,4);
                                      // KTO-QUAL (D=Debitor)
    WriteA('D',1);
                                      // KTO
    WriteI(cnvia(Adr.KundenFibuNr),8);
                                      // JOUR-KTO
    WriteI(vGegen,8);
                                      // PN = Primanota (woher kommt der Satz)
    WriteI(2005,4);
                                      // BELEG-DAT
    WriteD(Erl.Rechnungsdatum);
                                      // BELEG-NR
    WriteA(cnvai(Erl.Rechnungsnr),8);
                                      // S-H zu Adresse (1=soll, 2=haben, 3=stornosoll, 4=stornohaben))
    WriteI(1,1);
                                      // FILLER
    WriteA('+',1);
                                      // BUCH-BTR
    WriteN(Erl.BruttoW1, 16,2);
                                      // FILLER
    WriteA('+',1);
                                      // SEC-BUCH-BTR
    WriteN(0.0, 16,2);
                                      // WAEHRUNG
    WriteA('',4);
                                      // FILLER
    WriteA('+',1);
                                      // W-BUCH-BTR
    WriteN(0.0, 16,2);
                                      // STSCHL
    WriteI(cnvia(Sts.Fibu.Code),2);
                                      // FILLER
    WriteA('+',1);
                                      // ST-BTR
    WriteN(0.0, 16,2);
                                      // BUCH-TEXT
    WriteA('aus Stahl-Control',24);
                                      // FAELL-DAT
    WriteD(Ofp.Zieldatum);
                                      // SKTO-DAT1
    WriteD(Ofp.SkontoDatum);
                                      // SKTO-DAT2
    WriteA('00000000',8);
                                      // FILLER
    WriteA('+',1);
                                      // SKTO-VORSCHLAG1
    WriteN(Ofp.SkontoW1, 16,2);
                                      // FILLER
    WriteA('+',1);
                                      // SKTO-VORSCHLAG2
    WriteN(0.0, 16,2);
                                      // BANK
    WriteI(0,2);
                                      // REGU-SPERRE
    WriteI(0,1);
                                      // LAST-SPERRE
    WriteI(0,1);
                                      // KOSTST
    WriteI(0,6);
                                      // KOSTTR
    WriteA('',10);
                                      // MENGE-VORZ
    WriteA('+',1);
                                      // MENGE
    WriteN(0.0, 15,3);
                                      // BELEG-KRED
    WriteA('',10);
                                      // OP-MFF
    WriteI(0,4);

    WriteEOL;
    inc(vCount);
    TextAddLine(vTxt, aint(Erl.Rechnungsnr)); // MERKEN
  END;

  FSiClose(vFile);


  // POSITIONEN -------------------------------------------------------------------------------
  vDateiname  # 'd:\fibu\grass\_by_SC_ufiTab.txt';
  vFile # FSIOpen(vDateiName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    TextClose(vTxt);
    Msg(450104,vDateiName,0,0,0);
    RETURN false;
  end;

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=TextInfo(vTxt,_textLines)) do begin
    vA # TextLineRead(vTxt, vI, 0);
    Erl.Rechnungsnr # cnvia(vA);
    Erx # RecRead(450,1,0);

    // Konten loopen..............................
    FOR Erx # RecLink(451,450,1,_recFirst)
    LOOP Erx # RecLink(451,450,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      Erx # RecLink(813,451,10,_recFirst);      // Steuerschluessel holen

      vGegen # "Erl.K.Erlöskonto";    // TODO

      _Write451(vFile, cKonzern, cFirma, vGegen);
    END;

  END;

  FSiClose(vFile);

  TextClose(vTxt);


  Msg(450102,cnvai(vCount)+'|'+vDateiName,0,0,0);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
end;

//========================================================================