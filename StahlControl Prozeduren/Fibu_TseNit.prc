@A+
//===== Business-Control =================================================
//
//  Prozedur  Fibu_TseNit
//              OHNE E_R_G
//  Info
//
//
//  20.04.2009  AI  Erstellung der Prozedur
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//  SUB ErlExport();
//
//========================================================================
@I:Def_global

define begin
  Msg2(a) : WindialogBox(gFrmMain,'FIBU-Übergabe',a,_WinIcoError, 0 |_WinDialogAlwaysOnTop,1);

  //WriteF(a,b,c) : vString # vString + cnvaf(a,_FmtNumNoGroup | _FmtNumPoint,0,c,b) + ';'
  //WriteI(a,b)   : vString # vString + cnvai(a,_FmtNumNoGroup,0,b) + ';'
  //WriteD(a)     : if (a>1.1.1900) then vString # vString + Cnvai(DateDay(a),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) +  Cnvai(DateYear(a)+1900,_FmtNumLeadZero,0,4)+';'
  //Satzende      : begin FSIWrite(vFile , vString); vstring # ''; end;
end;

declare Write(aText : alpha; opt aTiefe : int);

local begin
  vFile         : int;
  vTiefe        : int;
end;

//========================================================================
//  Erl_Export
//
//========================================================================
sub Erl_Export();
local begin
  vDateiname      : alpha;            /* Name der Export-Datei        */
  vAnzahl         : int;
  vItem           : int;
  vMID,vMFile     : int;
  vWert           : float;
  vKonto          : int;
  vDat            : date;
  Erx             : int;
end
begin

  if (Set.Fibu.Pfad='') then RETURN;
  if (Strcut(Set.Fibu.Pfad, StrLen(Set.Fibu.Pfad) ,1)<>'\') then
    Set.Fibu.Pfad # Set.Fibu.Pfad + '\';

  vDateiname # Set.Fibu.Pfad+'BUCHUNGEN.TXT';

  if (Msg(450103,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN;
  if (Dlg_Standard:Datum('Buchungszeitraum',var vDat, today)=false) then RETURN;

  vFile # FSIOpen(vDateiName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vDateiName,0,0,0);
    RETURN;
  end;

  //FsiSeek(vFile, FSISize(vFile));

  Write('ExportedSystem="Unknown"');
  Write('LangVer="3.00"');
  Write('WorkstationID="0"');
  //Write('CodePage="ANSI"');
  //Write('Created="20.03.2006 11:01:25"');
  Write('Comment="Ausgangsrechnungen aus StahlControl"');
  Write('<Block,'+cnvad(today,_FmtDateLongYear)+' '+cnvat(now,_FmtTimeSeconds)+'>');
  Write('[Mandant]',1);
  Write('plManNr=10');                // MANDANTENNUMMER
  //Write('pbBuchungskreis=True');
  //Write('pbMitFremdKonten=False');

  Write('[FibBuchung]',1);
  Write('pbyMonat='+cnvai(datemonth(vDat)));
  Write('pdtBuchZeitRaum='+cnvad(vDat,_FmtDateLongYear));
  Write('plStrukturform=0');
  //Write('pbyZustand=1');
  Write('pbAutofolgeBuchung=True');
  //Write('pbSkNeuohneAbfrage=True');

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


    vAnzahl # vAnzahl + 1;
    RecRead(450,1,0);

    Erx # RecLink(460,450,2,_recFirst);     // OP holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(470,450,11,_recFirst);  // ~OP holen
      if (Erx>_rLocked) then RecBufClear(470);
      RecBufcopy(470,460);
    end;

    Erx # RecLink(100,450,5,_recFirst);     // Kunde holen
    if (cnvia(Adr.KundenFibuNr)=0) then Adr.KundenFibuNr # aint(Adr.KundenNr);

  //  case "Erl.Adr.Steuerschl" of          // VAT 1-Inl./0-Ausl/2-EG

    Erx # RecLink(451,450,1,_recFirst);     // Konten loopen
    WHILE (Erx<=_rLocked) do begin

      Erx # RecLink(813,451,10,_recFirst);  // Steuerschl. holen
      if (Erx>_rLocked) then RecBufClear(813);
      StS.Prozent # StS.Prozent + 100.0;
      vWert # Rnd(Erl.K.Betrag * StS.Prozent / 100.0,2);

  /*
  8120 Steuerfreie Umsätze §4 Nr. 1a UStG (Ausland)
  8125 steuerfreie innergemeinschaftliche Liefrungen § 4 Nr. 1b UStG
  8400 Erlöse 19% UST
  8420 Erlöse Frachten 19% UST
  */
      if ("Erl.K.Erlöskonto"=8420) then begin
        vKonto # 8420;      // Erlöse Frachten 19% UST
        end
      else begin
        if (Erl.Adr.Steuerschl=1) then
          vKonto # 8400     // Erlöse 19% UST
        else if (Erl.Adr.Steuerschl=2) then
          vKonto # 8125     // steuerfreie innergemeinschaftliche Liefrungen § 4 Nr. 1b UStG
        else
          vKonto # 8120;    // Steuerfreie Umsätze §4 Nr. 1a UStG (Ausland)
      end;

      Write('[Buchungssatz]',1);
      Write('[Grundangaben]',1);
      //Write('plNr='+cnvai(vAnzahl,_FmtNumNoGroup));
      //Write('plLfdNr=1');
      Write('pbyTyp=1');
      Write('pbyOpos=1');

      Write('pbHaben=True');
      Write('pbyErfassung=1');    // 1=Euro
      Write('pcBetrag='+cnvaf(vWert,_FmtNumNoGroup));
      Write('pdtDatum_Beleg='+cnvad(Erl.Rechnungsdatum,_FmtDateLongYear));
      Write('plSkNr_Haben='+cnvai(vKonto,_FmtNumNoGroup));
      Write('plSkNr_Soll='+Adr.KundenFibuNr);
      Write('psBeleg1='+cnvai(Erl.Rechnungsnr,_FmtNumNoGroup));
      Write('plBeleg2='+cnvai(Erl.Rechnungsnr,_FmtNumNoGroup));
      Write('psText=Ausgangsrechnung aus SC');
      Write('plStSchlNr_Haben='+StS.Fibu.Code);

      Write('[END]',-1);  // Grunddaten

      // OP anlegen...
      Write('[OffenerPosten]',1);
      Write('pcSkto_Proz1='+cnvaf(OfP.Skontoprozent));
      //Write('pcSkto_Proz2=2');
      Write('pcSktofaehig='+cnvaf(Erl.BruttoW1,_FmtNumNoGroup));;
      Write('pdtFaelligkeit='+cnvad(OfP.Zieldatum,_FmtDateLongYear));
      Write('pdtSkto_Datum1='+cnvad(OfP.SkontoDatum,_FmtDateLongYear));
      //Write('pdtSkto_Datum2=');
      Write('[END]',-1);

      Write('[END]',-1);  // Buchungssatz

      Erx # RecLink(451,450,1,_recNext);
    END;




    vItem # gMarkList->CteRead(_CteNext,vItem);
//    gMarkList->CteDelete(vItem);
  END;

  Write('[END]',-1);
  Write('[END]',-1);
  Write('<END>',0);
  Write('END_OF_FILE');

  FSIClose(vfile);            // Datei schliessen

  Msg(450102, cnvai(vAnzahl,_FmtNumNoGroup)+'|'+vdateiname, 0,0,0);


  if (WindialogBox(gFrmMain,'FIBU-Übergabe','Übergabe abgeschlossen!'+Strchar(13)+'Die markierte Datensätze als übergeben kennzeichnen?',_WinIcoQuestion, _WinDialogYesNo |_WinDialogAlwaysOnTop,1)<>_WinIDYes) then begin
    RETURN;
  end;

  // Löschlauf...
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(450,0,0,vMID);              // Satz holen
    RecRead(450,1,_recLock);
    "Erl.FibuDatum" # today;
    RekReplace(450,_RecUnlock,'AUTO');

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

end;


//========================================================================
//  Write
//
//========================================================================
sub Write(aText : alpha; opt aTiefe : int)
local begin
  vI  : int;
end
begin
  aText # aText + StrChar(13)+StrChar(10);

  if (aTiefe<0) then
    vTiefe # vTiefe + aTiefe;

  FOR vI # 0 loop inc(vI) while (vI<vTiefe) do
    aText # '  '+aText;

  FSIWrite(vFile, aText);

  if (aTiefe>0) then
    vTiefe # vTiefe + aTiefe;
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================
//========================================================================