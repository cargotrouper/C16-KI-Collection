@A+
//===== Business-Control =================================================
//
//  Prozedur  Repair_Ein
//                  OHNE E_R_G
//  Info
//
//
//  14.12.2011  AI  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//  21.06.2022  AH  "LeereMEH"
//
//  Subprozeduren
//  SUB WE_VSB_Loeschen
//  SUB LeereMEH
//
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
//
//    call Repair_Ein:WE_VSB_Loeschen
//========================================================================
sub WE_VSB_Loeschen()
local begin
  Erx     : int;
  vBuf506 : int;
  vProz   : float;
  vOK     : logic;
end;
begin

  vBuf506 # RecBufCreate(506);

  RecBufClear(506);
  FOR Erx # RecRead(506,1,_RecFirst);
  LOOP Erx # RecRead(506,1,_RecNext);
  WHILE (Erx<=_rLocked) do begin

    if ("Ein.E.VSBYN"=n) or ("Ein.E.Löschmarker"='*') then CYCLE;

    Erx # RecLink(501,506,1,_recfirst); // Bestellpos holen
    if (Erx<=_rLocked) then begin
      if (Ein.E.Menge<>0.0) and ("Ein.P.Löschmarker"='') then CYCLE;
    end
    else begin
      RecBufClear(501);
    end;


    Erx # RecRead(506,1,_recLock);
    "Ein.E.Löschmarker" # '*';
    RekReplace(506,0,'AUTO');


    // Bestellung erledigt?
    if (Ein.P.Nummer<>0) then begin
      vProz # Lib_Berechnungen:Prozent(Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge.Wunsch);
      if (vProz>="Set.Ein.WEDelEin%") then begin

        vOK # y;
        Erx # RecLink(vBuf506,501,14,_recFirst);  // WE loopen
        WHILE (Erx<=_rLocked) do begin
          if (vBuf506->Ein.E.VSBYN) and (vBuf506->"Ein.E.Löschmarker"='') then begin
            vOK # n;
            BREAK;
          end;
          Erx # RecLink(vBuf506,501,14,_recNext);
        END;

        if (vOK) then begin
          RecRead(501,1,_recLock);
          "Ein.P.Löschmarker"     # '*';
          "Ein.P.Lösch.Datum"     # today;
          "Ein.P.Lösch.Zeit"      # now;
          "Ein.P.Lösch.User"      # gUsername;
          Ein_Data:PosReplace(_recUnlock,'AUTO');
        end;
      end;
    end;

  END;

  RecbufDestroy(vBuf506);

  msg(999998,'',0,0,0);
end;


/*========================================================================
2022-06-21  AH
      Fixt leere Ein.P.MEH

  Call Repair_Ein:LeereMEH
========================================================================*/
sub LeereMeh()
local begin
  Erx : int;
end;
begin

  FOR Erx # RecRead(501,1,_recFirst)
  LOOP Erx # RecRead(501,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Ein.P.MEH='') then begin
      RecRead(501,1,_recLock);
      Ein.P.MEH     # 'kg';
      Ein.P.Menge   # Ein.P.Gewicht;
      Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
      RekReplace(501);
    end;
  END;

  FOR Erx # RecRead(511,1,_recFirst)
  LOOP Erx # RecRead(511,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if ("Ein~P.MEH"='') then begin
      RecRead(511,1,_recLock);
      "Ein~P.MEH"     # 'kg';
      "Ein~P.Menge"   # "Ein~P.Gewicht";
      "Ein~P.FM.Rest" # "Ein~P.Menge" - "Ein~P.FM.Eingang" - "Ein~P.FM.VSB" -  "Ein~P.FM.Ausfall";
      RekReplace(511);
    end;
  END;
  Msg(999998,'Fertig!',0,0,0);
end;


//========================================================================