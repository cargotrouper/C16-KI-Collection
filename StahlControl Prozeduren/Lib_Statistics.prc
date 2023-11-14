@A+
//===== Business-Control =================================================
/*

Prozedur    Lib_Statistics
                OHNE E_R_G
Info
Dient dazu, Statistiken und generell Aggregate aus Arrays zu bestimmen.
Kann im Kombination mit Lib_CSV dazu genutzt werden, Statistiken aus
CSV Dateien zu extrahieren. Siehe auch Benutzungsbeispiele dort.

Historie
2022-03-31  DS  Erstellung der Prozedur

Subprozeduren

maxArray_float : float
minArray_float : float
MAIN: Benutzungsbeispiele zum Testen

*/
//========================================================================
@I:Def_Global

//========================================================================
// Defines
//========================================================================
define begin
end


//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  Gibt das Maximum zurück
//========================================================================
sub maxArray_float
(
  var array  : float[];
) : float
local begin
  vIdx          : int;
  vIncumbent    : float;
  vIncumbentIdx : int;  // ggf. später nützlich für argmax-artige Funktion
end
begin

  vIncumbent # array[1];
  
  FOR   vIdx # 1;
  LOOP  Inc(vIdx);
  WHILE vIdx <= VarInfo(array) DO BEGIN
    if array[vIdx] > vIncumbent then
    begin
      vIncumbent # array[vIdx];
      vIncumbentIdx # vIdx;
    end
  END

  return vIncumbent;
end


//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  Gibt das Minimum zurück
//========================================================================
sub minArray_float
(
  var array  : float[];
) : float
local begin
  vIdx          : int;
  vIncumbent    : float;
  vIncumbentIdx : int;  // ggf. später nützlich für argmax-artige Funktion
end
begin

  vIncumbent # array[1];
  
  FOR   vIdx # 1;
  LOOP  Inc(vIdx);
  WHILE vIdx <= VarInfo(array) DO BEGIN
    if array[vIdx] < vIncumbent then
    begin
      vIncumbent # array[vIdx];
      vIncumbentIdx # vIdx;
    end
  END

  return vIncumbent;
end


//========================================================================
//  MAIN: Benutzungsbeispiele zum Testen
//========================================================================

MAIN()
local begin
  vArray : float[];
  vMax   : float;
  vMin   : float;
end;
begin

  // Lib_Statistics kann im Kombination mit Lib_CSV dazu genutzt werden, Statistiken aus
  // CSV Dateien zu extrahieren.
  //
  // !!!Siehe auch Benutzungsbeispiele dort!!!

  VarAllocate(vArray, 5);
  
  vArray[1] # 4.5;
  vArray[2] # -3.1;
  vArray[3] # -2.2;
  vArray[4] # 7.3;
  vArray[5] # 6.1;
  
  vMax # maxArray_float(var vArray);
  vMin # minArray_float(var vArray);
  
  DebugM('Maximum: ' + CnvAF(vMax));
  DebugM('Minimum: ' + CnvAF(vMin));
  
  VarFree(vArray);
  
  return;
  
end
