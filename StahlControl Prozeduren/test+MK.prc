@A+
//===== Business-Control =================================================
//
//  Prozedur
//
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_global
@I:Def_Aktionen


sub LautAufAktionBaMergeFail()
local begin
  vProgress : int;
end
begin

  vProgress # Lib_Progress:Init('Durchlauf Auftragsaktionen',RecInfo(404,_RecCount),true);

  Erg # RecRead(404,1,_RecFirst);
  WHILE Erg < _rNoRec DO BEGIN
    vProgress->Lib_Progress:Step();
debug('KEY404');
    if (Auf.A.Aktionstyp <> c_Akt_BA_Plan) then
      CYCLE;
     
    BAG.P.Nummer    # Auf.A.Aktionsnr;
    BAG.P.Position  # Auf.A.Aktionspos;
    Erg # RecRead(701,1,_RecTest);
    if (Erg <> _rOK) then begin
      RekDelete(404);
debug('KEY404 DEL');
      Erg # RecRead(404,1,0);  // Vorgängerlesen
    end else
      Erg # RecRead(404,1,_RecNext);
  END;
  vProgress->Lib_Progress:Term();

end;


//========================================================================
//========================================================================
MAIN
local begin
 
end;
begin
  LautAufAktionBaMergeFail();
end;


//========================================================================
//========================================================================
//========================================================================
