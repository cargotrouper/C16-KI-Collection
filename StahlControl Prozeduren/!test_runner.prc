@A+

@I:Lib_Debug
// OHNE E_R_G
// falls in einem Kundendatenraum nicht vorhanden, folgenden Code kopieren
/*
define begin
  // falls Lib_Debug vorhanden:
  DebugM(a)   : Lib_Debug:Dbg_Msg(a,__PROC__+':'+CnvAI(__LINE__))
  // folgendes geht IMMER (ohne dependency auf Lib_Debug)
  DebugM(a)   : WinDialogBox(0, __PROC__+':'+CnvAI(__LINE__), a, _WinIcoInformation, _WinDialogOk, 1)
end
*/



// TEST CODE:

MAIN()
local begin
end;
begin

  // ggf. benötigte globals allokieren für Standalone-Ausführung (CTRL + T)...
  /*
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  VarAllocate(WindowBonus);
  */

  Git_for_C16:__debug_popup('Beispiel-Aufruf einer sub in anderer Prozedur');
  
  return;
  
end

