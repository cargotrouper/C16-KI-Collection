@A+
//===== Business-Control =================================================
//
//  Prozedur    Fibu_Simba
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  Nimm(a) : vA # vA + a + ';'
end;

//========================================================================
//  Export
//
//========================================================================
sub Export()
local begin
  Erx     : int;
  vVonDat : date;
  vBisDat : date;
  vName   : alpha;
  vFile   : int;
  vA      : alpha(500);
  vGegenK : int;
  vEGUst  : float;
  vCount  : int;

  vItem   : int;
  vItem2  : int;

  vMFile  : Int;
  vMID    : Int;
end;

begin


  vName # 'c:\simba2.txt';


//  if (Dlg_Standard:DatumVonBis(Translate('Rechnungsdatum'), var vVonDat, var vBisDat, datemake(1,Datemonth(today),Dateyear(today)+1900), today)=n) then RETURN;
  if (Msg(450103,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN;

  vFile # FSIOpen(vName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);

/*
  RecBufClear(450);
  Erl.Rechnungsdatum # vVonDat;
  Erx # RecRead(450,4,0);                 // Erlöse loopen
  WHILE (Erx<=_rNokey) and (Erl.Rechnungsdatum>=vVonDat) and
    (Erl.Rechnungsdatum<=vBisDat) do begin

    if (Erl.FibuDatum<>0.0.0) then begin  // bereits übergeben?
      Erx # RecRead(450,4,_RecNext);
      CYCLE;
    end;
*/

  TRANSON;

  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=450) then begin
      RecRead(450,0,0,vMID);          // Satz holen

      vCount # vCount + 1;

      RecLink(100,450,5,_RecFirsT);         // Kunde holen
      if (cnvia(Adr.KundenFibuNr)=0) then Adr.KundenfibuNr # aint(Adr.KundenNr);


      Erx # RecLink(451,450,1,_RecFirst);   // Konten loopen
      WHILE (Erx<=_rMultikey) do begin

        // Gegenkonto bestimmen
        vEGUSt  # 0.0;
        vGegenK # "Erl.K.Erlöskonto" + 8000;
        if (Erl.K.Steuerschl=1001) then begin       // Inland
          vGegenK # vGegenk + 470;
          end
        else if (Erl.K.Steuerschl=1002) then begin  // Ausland
          vGegenK # vGegenk + 125;
          end
        else if (Erl.K.Steuerschl=1003) then begin  // EG
          vGegenK # vGegenk + 120;
          StS.Nummer # Erl.K.Steuerschl;
          RecRead(813,1,0);
          vEGUst  # StS.Prozent;
          end
        else begin
          TRANSBRK;
          FSIClose(vfile);            // Datei schliessen
          Msg(450200,'',0,0,0);
          RETURN;
        end;

        vA # '';
        // Satz-Kennung
        Nimm('"BCH"');
        // Betrag
        Nimm(ANum(Erl.K.BetragW1,2));
        // Sonderfunktions KZ
        Nimm('');
        // Umst.KZ
        Nimm('');
        // Gegenkonto
        Nimm(AInt(vGegenK));
        // Belegnummer
        Nimm(AInt(Erl.Rechnungsnr));
        // Zahlungskondition
        Nimm(AInt(Erl.Zahlungsbed));
        // Belegdatum
        Nimm(cnvaI(dateday(Erl.Rechnungsdatum),_fmtnumleadzero,0,2)+cnvaI(datemonth(Erl.Rechnungsdatum),_fmtnumleadzero,0,2)+cnvaI(dateyear(Erl.Rechnungsdatum)+1900,_fmtnumleadzero | _fmtNumnogroup,0,4));
        // Valutadatum
        Nimm(cnvaI(dateday(Erl.Rechnungsdatum),_fmtnumleadzero,0,2)+cnvaI(datemonth(Erl.Rechnungsdatum),_fmtnumleadzero,0,2)+cnvaI(dateyear(Erl.Rechnungsdatum)+1900,_fmtnumleadzero | _fmtNumnogroup,0,4));
        // Konto
        Nimm(Adr.KundenFibuNr);
        // Kostenstelle
        Nimm('');
        // Konstenträger
        Nimm('');
        // Skontobetrag
        Nimm('');
        // Buhcungstext
        Nimm('"Business Control Rechnung"');
        // WährungsKZ
        Nimm('"EUR"');
        // Fremdwährung
        Nimm('');
        // Fremdwährungsbetrag
        Nimm('');
        // Währungsdifferenz
        Nimm('');
        // UStID
        Nimm('"'+Adr.USIdentNr+'"');
        // EG-USt Prozent
        Nimm(ANum(vEGUst,1));
        // Mahnstufe
        Nimm('');

        vA # vA + strchar(13)+strchar(10);
        FsiWrite(vFile,vA);       // Datei schreiben

        Erx # RecLink(451,450,1,_RecNext);
      END;


    end;

    RecRead(450,1,_recLock);
    Erl.Fibudatum # Today;
    RekReplace(450,_recUnlock,'AUTO');

    vItem2 # gMarkList->CteRead(_CteNext,vItem);
    gMarkList->CteDelete(vItem);

    vItem # vItem2;
  END;
/*
    Erx # RecRead(450,4,_RecNext);
  END;
*/

  TRANSOFF;

  FSIClose(vfile);            // Datei schliessen

  Msg(450102,cnvai(vCount),0,0,0);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

end;

//========================================================================