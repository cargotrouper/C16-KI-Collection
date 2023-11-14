@A+
//===== Business-Control =================================================
//
//  Prozedur  Auf_K_Data
//                  OHNE E_R_G
//  Info
//
//
//  22.03.2011  AI  Erstellung der Prozedur
//  14.02.2014  AH  Fix: "Sync2Pos": in Fremdwährung umrechen
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB SumKalkulation();
//    SUB Syn2Pos()
//
//========================================================================
@I:Def_Global
@I:Def_BAG

//========================================================================
//  SumKalkulation
//
//========================================================================
sub SumKalkulation();
local begin
  Erx         : int;
  vKalk       : float;
  vMenge      : float;
  vX          : float;
end
begin
  vKalk # 0.0;

  Erx # RecLink(405,401,7,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Auf.K.PEH=0) then Auf.K.PEH # 1;
    if (Auf.K.MengenbezugYN) and (Auf.K.MEH<>'%') then begin//and (Auf.K.MEH=Auf.P.MEH.Preis) then
      if (Auf.K.MEH=Auf.P.MEH.Wunsch) then vMenge # Auf.P.Menge.Wunsch
      else if (Auf.K.MEH=Auf.P.MEh.Einsatz) then vMenge # Auf.P.Menge
      else vMenge # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl" , Auf.P.Gewicht, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, Auf.K.MEH);
    end
    else begin
      vMenge # Auf.K.Menge;
    end;
    vX # Rnd(Auf.K.Preis * vMenge / CnvFI(Auf.K.PEH),2);
    vKalk # vKalk + vX;
    Erx # RecLink(405,401,7,_RecNext);
  END;

//todo('Summe kalk:'+anum(vKalk,2));
  if (Auf.P.MEH.Preis=Auf.P.Meh.Wunsch) then
    vMenge # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, Auf.P.MEH.Preis)
  else
    vMenge # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge, Auf.P.MEH.einsatz, Auf.P.MEH.Preis);

  if (vMenge<>0.0) then
    vKalk # vKalk / vMenge * CnvFI(Auf.P.PEH)
  else
    vKalk # 0.0;
  Auf.P.Kalkuliert # vKalk;

  if (Mode = c_ModeEdit) then begin
  end
    // Falls Benutzer NICHT im NEW-Modus, speichern (für EDIT gesperrt)
  else if (Mode = c_ModeView) then begin
    Erx # RecRead(401,1,_RecLock);  // Satz sperren
    if (Erx <= _rLocked) then begin
      Auf.P.Kalkuliert # vKalk;
      Auf_Data:SumEKGesamtPreis();
      Auf.P.Einzelpreis # Auf.P.Grundpreis + Auf.P.Aufpreis;
      Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht)
      Erx # Auf_Data:PosReplace(_RecUnlock,'MAN');
      $lb.Kalkuliert->wpcaption # ANum(Auf.P.Kalkuliert,2);
      $lb.Poswert->wpcaption # ANum(Auf.P.Gesamtpreis,2);
      $lb.Rohgewinn->wpcaption # ANum(Auf.P.Gesamtpreis - "Auf.P.GesamtwertEKW1",2);
    end;
  end
  else if (Mode = c_ModeList) then begin
    Erx # RecRead(401,0,_RecID | _RecLock,$ZL.AufPositionen->wpDbRecID);
    if (Erx <= _rLocked) then begin
      Auf.P.Kalkuliert # vKalk;
      Auf_Data:SumEKGesamtPreis();
      Auf.P.Einzelpreis # Auf.P.Grundpreis + Auf.P.Aufpreis;
      Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht)
      Erx # Auf_Data:PosReplace(_RecUnlock,'MAN');
    end;
  end;

end;


//========================================================================
//  Sync2Pos
//
//========================================================================
sub Sync2Pos();
local begin
  Erx : int;
  vNr : int;
end;
begin

  // Basiskalkulation löschen...
  vNr # 1;
  Erx # RecLink(405,401,7,_recFirst);   // Kalkulation loopen
  WHILE (Erx<=_rLocked) do begin
    if (Auf.K.Typ='POS') then begin
      vNr # Auf.K.lfdNr;
      RekDelete(405,_recUnlock,'AUTO');
      BREAK;
    end;
    Erx # RecLink(405,401,7,_recNext);
  END;


  // Basiskalkulation anlegen bie Artikel
//  if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) and (Auf.P.ArtikelTyp=c_Art_HDL) then begin
  if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
    Erx # RecLink(250,401,2,_recfirst);   // Artikel holen
    RecBufClear(405);
    Auf.K.Nummer        # Auf.P.Nummer;
    Auf.K.Position      # Auf.P.Position;
    Auf.K.LfdNr         # vNr;
    Auf.K.Bezeichnung   # Art.Nummer;
    Auf.K.Typ           # 'POS';

    Auf.K.MEH           # Auf.P.MEH.Preis;
    Auf.K.PEH           # Auf.P.PEH;
    Auf.K.Termin.Art    # 'KW';
    Auf.K.MengenbezugYN # y;
    if (Art_P_Data:FindePreis('Ø-EK', 0, 0.0, '', 1)) then begin

      // 14.02.2014 AH: in Fremdwährung umrechen
      Auf.K.Preis       # Art.P.PreisW1;
      RecLink(814,400,8,_recfirst); // Währung holen
      if ("Auf.WährungFixYN") then
        Wae.VK.Kurs   # "Auf.Währungskurs";
      Auf.K.Preis   # Rnd(Auf.K.Preis * "Wae.VK.Kurs",2)

    end;
    WHILE (Recread(405,1,_RecTest,0)<=_Rlocked) do
      Auf.K.LfdNr # Auf.K.Lfdnr + 1;

    Auf.K.Anlage.Datum  # Today;
    Auf.K.Anlage.Zeit   # Now;
    Auf.K.Anlage.User   # gUsername;
    RekInsert(405,0,'MAN');
  end;

end;


//========================================================================