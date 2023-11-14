@A+
//===== Business-Control =================================================
//
//  Prozedur  aaa_ankertest
//
//  Info
//    Testet ob ein Anker ausgeführt wird
//
//
//  14.06.2010  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    sub test()
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Bag
@I:Def_Aktionen

define begin
end;

local begin
end;


//========================================================================
//  aaa_ankertest:test()
//     testet ob ein Anker aufgerufen wurde
//========================================================================
sub test(opt aPar : alpha) : int
local begin
end;
begin

  debug('Anker aufgerufen');
  return 1;
end;