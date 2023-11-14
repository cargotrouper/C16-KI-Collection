@A+
//===== Business-Control =================================================
//
//  Prozedur  BA2_P_Data
//                    OHNE E_R_G
//  Info
//
//
//  25.10.2011  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB SumInput(a701 : int)
//
//========================================================================
@I:Def_Global
@I:Def_BAG

//========================================================================
//  SumInput
//
//========================================================================
sub SumInput(a701 : int)
local begin
  Erx       : int;
  v701      : int;
  v819      : int;
  vLen      : float;
  vStk      : int;
  vGew      : float;
  vME       : float;
  vX        : float;
  vSave701  : int;
end;
begin

//  vSave701 # RekSave(701);

  // Einsatz addieren
  if (RecLinkInfo(701,702,2,_recCount)<>0) then begin
    v701 # RecBufCreate(701);   // 2022-12-19 AH
    v819 # RecBufCreate(819);   // 2022-12-19 AH
    vLen # 0.0;
    Erx # RekLinkB(v701,702,2,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (v701->"BAG.IO.LöschenYN"=false) and
        (v701->BAG.IO.vonFertigmeld=0) and (v701->BAG.IO.Materialtyp<>c_IO_ARt) and (v701->BAG.IO.Materialtyp<>c_IO_Beistell) then begin
        if (v701->"BAG.IO.Länge"=0.0) then begin
          RekLink(v819,v701,7,_recFirst);   // Warengruppe holen
          v701->"BAG.IO.Länge" # Lib_berechnungen:L_aus_KgStkDBDichte2(v701->BAG.IO.Plan.Out.GewN, 1, v701->BAG.IO.Dicke,v701-> BAG.IO.Breite, v819->Wgr.Dichte, v819->"Wgr.TränenKgProQM");
        end;
        if (v701->"BAG.IO.Länge"<>0.0) then begin
          if (v701->"BAG.IO.Länge"<vLen) then vLen # v701->"BAG.IO.Länge";
          if (vLen=0.0) then vLen # v701->"BAG.IO.Länge";
        end;
        vStk  # vStk + v701->BAG.IO.Plan.Out.Stk;
        vGew  # vGew + v701->BAG.IO.Plan.Out.GewN;
        if (v701->BAG.IO.MEH.Out='m') then begin
          vMe   # vMe  + v701->BAG.IO.Plan.Out.Meng;
          end
        else begin
          vSave701 # RekSave(701);
          RecBufCopy(v701,701);
          vX # Lib_Einheiten:WandleMEH(701, v701->BAG.IO.Plan.Out.Stk, v701->BAG.IO.Plan.Out.GewN, v701->BAG.IO.Plan.Out.Meng, v701->BAG.IO.MEH.Out, 'm');
          RekRestore(vSave701);
          vMe   # vMe  + vX;
        end;
      end;

      Erx # RekLinkB(v701,702,2,_recNext);
    END;
    RekBufKill(v701);
    RekBufKill(v819);
  end;

  if (a701=701) then begin
    BAG.IO.Plan.Out.Stk   # vStk;
    BAG.IO.Plan.Out.GewN  # vGew;
    BAG.IO.Plan.Out.Meng  # vMe;
    "BAG.IO.Länge"        # vLen;
    end
  else begin
    a701->BAG.IO.Plan.Out.Stk   # vStk;
    a701->BAG.IO.Plan.Out.GewN  # vGew;
    a701->BAG.IO.Plan.Out.Meng  # vMe;
    a701->"BAG.IO.Länge"        # vLen;
  end;
//  if (BAG.IO.Plan.Out.Stk=0) then BAG.IO.Plan.Out.Stk # 1;

  RETURN;
end;

/***
sub xxxSumInput(aBuf701 : int)
local begin
  vSave701  : int;
  vBuf701   : int;
  vLen      : float;
  vStk      : int;
  vGew      : float;
  vME       : float;
  vX        : float;
end;
begin

  vSave701 # RekSave(701);

  vBuf701 # RecBufCreate(701);

  // Einsatz addieren
  if (RecLinkInfo(701,702,2,_recCount)=0) then begin
    RekRestore(vSave701);
    RecBufCopy(vBuf701, aBuf701)
    RecBufDestroy(vBuf701);
    RETURN;
  end;

  vLen # 0.0;

  Erx # RecLink(701,702,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if ("BAG.IO.LöschenYN"=false) and
      (BAG.IO.vonFertigmeld=0) and (BAG.IO.Materialtyp<>c_IO_ARt) and (BAG.IO.Materialtyp<>c_IO_Beistell) then begin
      if ("BAG.IO.Länge"=0.0) then begin
        RecLink(819,701,7,_recFirst);   // Warengruppe holen
        "BAG.IO.Länge" # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, 1, BAG.IO.Dicke, BAG.IO.Breite, Wgr.Dichte, "Wgr.TränenKgProQM");
      end;
      if ("BAG.IO.Länge"<>0.0) then begin
        if ("BAG.IO.Länge"<vLen) then vLen # "BAG.IO.Länge";
        if (vLen=0.0) then vLen # "BAG.IO.Länge";
      end;
      vStk  # vStk + BAG.IO.Plan.Out.Stk;
      vGew  # vGew + BAG.IO.Plan.Out.GewN;
      if (BAG.IO.MEH.Out='m') then begin
        vMe   # vMe  + BAG.IO.Plan.Out.Meng;
        end
      else begin
        vX # Lib_Einheiten:WandleMEH(701, BAG.IO.Plan.Out.Stk, BAG.IO.Plan.Out.GewN, BAG.IO.Plan.Out.Meng, BAG.IO.MEH.Out, 'm');
        vMe   # vMe  + vX;
      end;
    end;

    Erx # RecLink(701,702,2,_recNext);
  END;

  vBuf701->BAG.IO.Plan.Out.Stk   # vStk;
  vBuf701->BAG.IO.Plan.Out.GewN  # vGew;
  vBuf701->BAG.IO.Plan.Out.Meng  # vMe;
  vBuf701->"BAG.IO.Länge"        # vLen;
//  if (BAG.IO.Plan.Out.Stk=0) then BAG.IO.Plan.Out.Stk # 1;


  RekRestore(vSave701);
  RecBufCopy(vBuf701, aBuf701)
  RecBufDestroy(vBuf701);
  RETURN;

end;
****/

//========================================================================
