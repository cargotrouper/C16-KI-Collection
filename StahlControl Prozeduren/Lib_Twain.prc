@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Twain
//                    OHNE E_R_G
//  Info
//
//
//  14.06.2005  FR  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB Scan(aPfad : alpha; aFarbe : int; aDPI : float)
//
//========================================================================
@I:Def_global

//========================================================================
// Scan
//   scannt ein Dokument mit dem Standard-TWAIN Gerät
//========================================================================
sub Scan(
  aPfad   : alpha;
  aFarbe  : int;
  aDPI    : float;
)
local begin
 tHdl     : int;
 vZiel    : alpha;
 vPos     : int;
end
begin

   // Bestimmt Zielpfad

   // Sucht vom Ende des Pfades nach dem ersten '\' um den Dateinamen
   // abzuschneiden
   for vPos # StrLen(aPfad) loop dec(vPos) while (vPos > 0) do
   begin
    if (StrToChar(aPfad, vPos) = 92) then
      break;
   end;

   // Kein '\', ungültiger Pfad
   if (vPos = 0) then return;

   vZiel # StrCut(aPfad, 1, vPos);
debug(apfad+'   '+vZiel);

   // Pfad ist okay, beginne Scan
   tHdl # DllLoad('TWAIN\c16twain');
   DllCall(tHdl, 1, aPfad, aFarbe, aDPI);
   tHdl->DllUnload();

   // Wandle bmp in jpg um
   SysExecute('TWAIN\PVW32Con.exe',aPfad + ' -j --o ' + vZiel, _ExecWait | _ExecMinimized);

   // Lösche bmp
   FsiDelete(aPfad);

end;

//========================================================================

//========================================================================
// DEBUG
//========================================================================
// Main-funktion für Debug
/**
MAIN ()
begin
  Scan('z:\alex\ZweiUndVierzig.bmp', 24, 72.0);
end;
***/
