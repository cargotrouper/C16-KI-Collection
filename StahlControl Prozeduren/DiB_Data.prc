@A+
//===== Business-Control =================================================
//
//  Prozedur    DiB_Data
//                    OHNE E_R_G
//  Info
//
//
//  29.01.2009  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

//========================================================================
// RecalcAll
//
//========================================================================
sub ReCalcAll();
local begin
  vOK : logic;
  Erx : int;
end;
begin

  RecbufClear(240);
  RekDeleteAll(240);

  // BAG-IO loopen....................................
  Erx # RecRead(701,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.MaterialTyp=c_IO_BAG) and (BAG.IO.VonBAG<>0) then begin
      vOK # y;
      if (BAG.IO.NachBAG<>0) then begin
        Erx # RecLink(702, 701, 4,_recfirst);   // nachPos holen
        if (Erx>_rLocked) or (BAG.P.Typ.VSBYN=n) then vOK # n;
      end;
    end;

    if (vOK) then begin
      vOK # n;
      DiB.Datei   # 701;
      DiB.ID1     # BAG.IO.Nummer;
      DiB.ID2     # BAG.IO.ID;
      "DiB.Güte"  # "BAG.IO.Güte";
      DiB.Dicke   # BAG.IO.Dicke;
      DiB.Breite  # BAG.IO.Breite;
      "DiB.Länge" # "BAG.IO.Länge";
      DiB.Coilnummer  # '';
      Erx # RekInsert(240,0,'AUTO');
    end;

    Erx # RecRead(701,1,_RecNext);
  END;



  // Material loopen....................................
  Erx # RecRead(200,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if ("Mat.Löschmarker"='') and (Mat.Status<=c_status_bisFrei) and
      ("Mat.Verfügbar.Gew">0.0) and (Mat.Bestellt.Gew=0.0)then begin
      DIB.Datei   # 200;
      DIB.ID1     # Mat.Nummer;
      DIB.ID2     # 0;
      "DiB.Güte"  # "Mat.Güte";
      DiB.Dicke   # Mat.Dicke;
      DiB.Breite  # Mat.Breite;
      "DiB.Länge" # "Mat.Länge";
      DiB.Coilnummer  # Mat.Coilnummer;
      Erx # RekInsert(240,0,'AUTO');
    end;

    Erx # RecRead(200,1,_RecNext);
  END;


end;

//========================================================================