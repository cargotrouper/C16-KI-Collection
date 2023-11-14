@A+
//===== Business-Control =================================================
//
//  Prozedur  BA1_FM_B_Data
//                OHNE E_R_G
//  Info
//
//
//  13.12.2012  AI  Erstellung der Prozedur
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB Entfernen() : logic
//    SUB Insert();
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
end;

//========================================================================
//  Entfernen
//
//========================================================================
sub Entfernen() : logic
local begin
  v200  : int;
end;
begin
todo('Mataktion löschen');
/*
  v200 # RekSave(200);
  if (Mat.Nummer<>BAG.FM.Materialnr) then begin
    Erx # RecLink(200,707,7,_recFirst);   // Material holen
    if (Erx<_rLocked) then begin
      RekRestore(v200);
      RETURN false;
    end;
  end;

  Erx # RecLink(204,200,14,_recFirst);    // Aktionen loopen
  WHILE (Erx<=_rLocked) do begin
    if (Mat.A.Aktionstyp=c_Akt_BA_Beistell) and () then begin
problem: eine Aktion für ALLE beistellungen
    end;
    Erx # RecLink(204,200,14,_recNext);
  END;

  RekRestore(v200);
*/
  RETURN true;
end;


//========================================================================
// Insert
//========================================================================
sub Insert();
local begin
  Erx : int;
end;
begin

  if (BAG.FM.B.LfdNr=0) then
    BAG.FM.B.LfdNr # 1;

  BAG.FM.B.Nummer       # BAG.FM.Nummer;
  BAG.FM.B.Position     # BAG.FM.Position;
  BAG.FM.B.Fertigung    # BAG.FM.Fertigung;
  BAG.FM.B.Fertigmeld   # BAG.FM.Fertigmeldung;
  REPEAT
    Erx # Rekinsert(708,0,'MAN');
    if (Erx<>_rOK) then BAG.FM.B.lfdNr # BAG.FM.B.lfdNr + 1;
  UNTIL (Erx=_rOK);

end;

//========================================================================