@A+
//===== Business-Control =================================================
//
//  Prozedur  UsrSubs
//                  MIT ERX
//  Info
//
//
//  04.05.2023  MK  Erstellung der Prozedur

//
//  Subprozeduren
//
//    SUB DruckMitarbeiterkarte();

//========================================================================
@I:Def_global



//========================================================================
//  DruckMitarbeiterkarte
//        Druckt eine Mitarbeiterkarte als QR Etikett
//========================================================================
SUB DruckMitarbeiterkarte() : logic;
local begin
  Erx   : int;
end;
begin
  Erx # RecRead(800,1,0,0);
  if (Erx>_rLocked) then RETURN false;
        Lib_Dokumente:Printform(800,'Mitarbeiterkarte',true);
 return true;
end;