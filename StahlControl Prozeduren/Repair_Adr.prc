@A+
//===== Business-Control =================================================
//
//  Prozedur  Repair_Adr
//                  OHNE E_R_G
//  Info
//
//
//  21.06.2012  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB Lauf_vor_1.1225
//
//========================================================================
@I:Def_Global

//========================================================================
//  Lauf_VOR_1.1225
//
//call repair_adr:Lauf_vor_1.1225
//========================================================================
SUB Lauf_vor_1.1225
local begin
  Erx  : int;
end;
begin
  Erx # RecRead(100,1,_recfirst);
  WHILE (Erx<=_rLockeD) do begin
    Erx # RecLink(101,100,12,_RecFirsT);
    if (Erx<=_rLocked) and (Adr.A.Nummer=1) then begin
      RecRead(101,1,_recLock);
      "Adr.A.Steuerschlüsse"  # "Adr.Steuerschlüssel";
      RekReplace(101,_RecUnlock,'AUTO');
    end;
    Erx # RecRead(100,1,_recNext);
  END;

  Msg(99,'',0,0,0);
end;


//========================================================================