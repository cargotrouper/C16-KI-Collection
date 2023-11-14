@A+
// OHNE E_R_G
// Lib_Debug inkludiert kaskadierend die weiteren benötigten Libs und stellt daher auch die verwendeten DebugX() und DebugM() aus Def_Global_Sys hier zur Verfügung
@I:Lib_Debug


//========================================================================
//  Main
//========================================================================

MAIN()
local begin
end;
begin

  InitDebug(); // immer zu Beginn der treibenden Methode, z.B. lokale main Funktion der Prozedur (leert Datei)


  // Debug-Text in Datei:
  DebugX('Diese Zeile wurde durch einen Aufruf von DebugX() erzeugt.');
  DebugX('Diese durch einen weiteren Aufruf von DebugX()');
  
  // Debug-Text in Popup:
  DebugM('Dieses Fenster wurde mit DebugM() erzeugt. Die mit DebugX() erzeugten Debug-Ausgaben landen in ' + dbg_Filename());
  
  
  TermDebug(); // immer zum Ende der treibenden Methode, z.B. lokale main Funktion der Prozedur (schließt Datei)
  
  return;
  
end

