@A+
//===== Business-Control =================================================
//
//  Prozedur  Ein_K_Data
//                OHNE E_R_G
//  Info
//
//
//  18.12.2018  AH  Erstellung der Prozedur
//  10.05.2022  AH  ERX
//  2023-01-24  AH  Kalkulationen immer in W1
//
//  Subprozeduren
//    SUB SumKalkulation();
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
  vKurs       : float;
end
begin
  vKalk # 0.0;

  Erx # RecLink(505,501,8,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Ein.K.PEH=0) then Ein.K.PEH # 1;
    if (Ein.K.MengenbezugYN) and (Ein.K.MEH<>'%') then begin
      if (Ein.K.MEH=Ein.P.MEH.Wunsch) then vMenge # Ein.P.Menge.Wunsch
      else if (Ein.K.MEH=Ein.P.MEH) then vMenge # Ein.P.Menge
      else vMenge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl" , Ein.P.Gewicht, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Ein.K.MEH);
    end
    else begin
      vMenge # Ein.K.Menge;
    end;
    vX # Rnd(Ein.K.Preis * vMenge / CnvFI(Ein.K.PEH),2);
    vKalk # vKalk + vX;
    Erx # RecLink(505,501,8,_RecNext);
  END;

//todo('Summe kalk:'+anum(vKalk,2));
  if (Ein.P.MEH.Preis=Ein.P.Meh.Wunsch) then
    vMenge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge.Wunsch, Ein.P.MEH.Wunsch, Ein.P.MEH.Preis)
  else
    vMenge # Lib_Einheiten:WandleMEH(501, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Menge, Ein.P.MEH, Ein.P.MEH.Preis);

  if (vMenge<>0.0) then
    vKalk # vKalk / vMenge * CnvFI(Ein.P.PEH)
  else
    vKalk # 0.0;
    
  // 2023-01-24 AH : W1 -> Fremdwährung
  RecLink(814,500,8,_recfirst);    // Währung holen
  if ("Ein.WährungFixYN") then
    vKurs # "Ein.Währungskurs"
  else
    vKurs # "Wae.EK.Kurs";
  vKalk # vKalk * vKurs;
  
  Ein.P.Kalkuliert # vKalk;

  if (Mode = c_ModeEdit) then begin
  end
    // Falls Benutzer NICHT im NEW-Modus, speichern (für EDIT gesperrt)
  else if (Mode = c_ModeView) then begin
    Erx # RecRead(501,1,_RecLock);  // Satz sperren
    if (Erx <= _rLocked) then begin
      Ein.P.Kalkuliert # vKalk;
      Erx # Ein_Data:PosReplace(_RecUnlock,'MAN');
      WUpdate($edEin.P.Kalkuliert_Mat);
      WUpdate($edEin.P.Kalkuliert);
    end;
  end
  else if (Mode = c_ModeList) then begin
    Erx # RecRead(501,0,_RecID | _RecLock,$ZL.EKPositionen->wpDbRecID);
    if (Erx <= _rLocked) then begin
      Ein.P.Kalkuliert # vKalk;
      Erx # Ein_Data:PosReplace(_RecUnlock,'MAN');
    end;
  end;

end;


//========================================================================