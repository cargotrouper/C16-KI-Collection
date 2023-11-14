@A+
//===== Business-Control =================================================
/*
Prozedur    Lib_CSV
                OHNE E_R_G
Info
Dient dazu, CSV Dateien generisch in C16 einlesen zu können


Historie
2022-03-31  DS  Erstellung der Prozedur

Subprozeduren
_MsgCsvError
_isValidDecSep : logic
_NormalizeTokenOrLine : alpha
getCsvColumnNames : logic
getCsvNumberOfColumn s: int
getCsvNumberOfDataRows : int
getCsvColumnByIndex_float : logic
getCsvColumnByName_float : logic
MAIN: Benutzungsbeispiele zum Testen
*/
//========================================================================
@I:Def_Global

//========================================================================
// Defines
//========================================================================
define begin
  cDefaultSep     : ';'  // welcher Separator wird als Standard bei .csv angenommen?
  cDefaultDecSep  : ','  // welcher Dezimaltrenner wird als Standard bei .csv angenommen?
  end


//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  Outlet für Fehlernachrichten mit optionalem Parameter
//  zur Ruhigstellung.
//========================================================================

sub _MsgCsvError
(
  aText            : alpha(4096);
  opt aShowDialog  : logic;       // Fehlermeldungen (DialogBox) aktivieren
)
begin
  if aShowDialog then
    WinDialogBox(0, 'CSV-Error', aText, _WinIcoError, _WinDialogOk, 0);
  Error(99, 'CSV-Error: ' + aText);
end


//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  prüft ob ein Zeichen als Dezimaltrenner unterstützt ist
//========================================================================

sub _isValidDecSep
(
  aDecSep : alpha(1);
) : logic
begin
  return aDecSep = '.' or aDecSep = ',';
end


//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  Normalisierung der gelesenen Token oder Zeilen.
//  Was es im Detail tut, versteht man am besten, wenn man die Kommentare
//  der Monster-Aufrufs in der sub von unten nach oben liest.
//========================================================================

sub _NormalizeTokenOrLine
(
  aToken           : alpha(4096);
) : alpha
begin
  return
  StrAdj                                                 // Entferne whitespaces an Beginn und Ende des Strings
  (
    Lib_Strings:Strings_WIN2DOS                          // Konvertiere für korrekte Umlaute
    (
      Lib_Strings:Strings_ReplaceAll                     // Entferne Linebreaks (StrChar(13)) (wichtig bei letztem Token einer Zeile)
      (
        Lib_Strings:Strings_ReplaceAll                   // Entferne Linebreaks (StrChar(10)) (wichtig bei letztem Token einer Zeile)
        (
          aToken,                                        // hier ist das Argument der Funktion
          StrChar(10),
          ''
        ),
        StrChar(13),
        ''
      )
    ),
    _StrBegin | _StrEnd
  );
end



//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  Liest Spaltennamen aus einer .csv Datei mit header (erste Zeile)
//========================================================================
sub getCsvColumnNames
(
  aCsvFilename         : alpha(512);  // Name der .csv Datei. Die exakt erste Zeile muss einen Header mit den Namen der Spalten enthalten, siehe dazu nächstes Argument.
  var aOutColumnNames  : alpha[];     // array in das die Spaltennamen eingelesen werden
  opt aSep             : alpha(1);    // Separator der Felder in der .csv Datei
  opt aShowDialog      : logic;       // Fehlermeldungen (DialogBox) aktivieren
) : logic                             // erfolgreich?
local begin
  vFileHdl         : handle;       // auf .csv Datei
  vLenLine         : int;          // Länge der aktuellen Zeile
  vLine            : alpha(8192);  // Inhalt der aktuellen Zeile
  vNumColumns      : int;          // wieviele Spalten gibt es?
  vIdx             : int;          // Zählvariable
  vReturn          : logic;
end
begin

  if aSep = '' then aSep # cDefaultSep;

  vFileHdl # FsiOpen(aCsvFilename, _FsiStdRead);
  
  if (vFileHdl <= 0) then
  begin
    _MsgCsvError('Datei nicht lesbar (Existiert sie und liegt Leseberechtigung vor?): ' + aCsvFilename, aShowDialog);
    vReturn # false;
  end
  else
  begin
  
    vFileHdl->FsiMark(10);
    
    // prüfe header (erste Zeile)
    vLenLine # vFileHdl->FsiRead(vLine);
    vLenLine # StrLen(_NormalizeTokenOrLine(vLine));
    if vLenLine <= 0 then
    begin
      _MsgCsvError('Datei hat leere erste Zeile: ' + aCsvFilename, aShowDialog);
      vReturn # false;
    end
    else
    begin

      // wieviele Spalten gibt es?
      vNumColumns # Lib_Strings:Strings_Count(vLine, aSep) + 1;
      // allokieren:
      VarAllocate(aOutColumnNames, vNumColumns);
      
      // Spaltennamen in Ausgabe schreiben
      FOR   vIdx # 1;
      LOOP  Inc(vIdx);
      WHILE vIdx <= vNumColumns DO
      BEGIN
        aOutColumnNames[vIdx] # _NormalizeTokenOrLine(Lib_Strings:Strings_Token(vLine, aSep, vIdx))  // Lese und normalisieren Token aus vLine
      END;
      
      vReturn # true;
    
    end
  
  end;

  vFileHdl->FsiClose();
  return vReturn;
  
end


//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  Ermittelt zu einer .csv Datei mit oder ohne header die Anzahl der
//  Zeilen die Daten enthalten
//========================================================================
sub getCsvNumberOfColumns
(
  aCsvFilename         : alpha(512);   // Name der .csv Datei. Die exakt erste Zeile muss einen Header mit den Namen der Spalten enthalten, siehe dazu nächstes Argument.
  opt aSep             : alpha(1);     // Separator der Felder in der .csv Datei
  opt aShowDialog      : logic;        // Fehlermeldungen (DialogBox) aktivieren
) : int                                // Anzahl der Spalten
local begin
  vColumnNames         : alpha[];      // array in das die Spaltennamen eingelesen werden
  vReturn              : int;
end
begin

  if aSep = '' then aSep # cDefaultSep;
  
  vReturn # -1;
  
  // auch wenn Datei keinen Header hat, kann getCsvColumnNames() genutzt werden um die Anzahl der Spalten zu bestimmen
  if getCsvColumnNames(aCsvFilename, var vColumnNames, aSep, aShowDialog) then
  begin
    vReturn # VarInfo(vColumnNames);
  end
  else
  begin
    _MsgCsvError('Anzahl der Spalten konnte durch getCsvNumberOfColumns() nicht korrekt bestimmt werden, da getCsvColumnNames() "false" zurücklieferte für Datei: ' + aCsvFilename, aShowDialog);
    vReturn # -1;
  end
  
  return vReturn;

end


//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  Ermittelt zu einer .csv Datei mit oder ohne header die Anzahl der
//  Zeilen die Daten enthalten
//========================================================================
sub getCsvNumberOfDataRows
(
  aCsvFilename         : alpha(512);   // Name der .csv Datei. Die exakt erste Zeile muss einen Header mit den Namen der Spalten enthalten, siehe dazu nächstes Argument.
  aHasHeader           : logic;        // Wenn die Datei einen Header hat, true übergeben, damit die erste Zeile beim Einlesen übersprüngen wird
  opt aShowDialog      : logic;        // Fehlermeldungen (DialogBox) aktivieren
) : int                                // Anzahl der Zeilen mit Daten (also ohne den Header zu zählen! und ohne leere und all-spaces Zeilen am Ende oder innerhalb der Datei)
local begin
  vFileHdl             : handle;       // auf .csv Datei
  vLenLine             : int;          // Länge der aktuellen Zeile
  vLine                : alpha(8192);  // Inhalt der aktuellen Zeile
  vReturn              : int;
end
begin

  vFileHdl # FsiOpen(aCsvFilename, _FsiStdRead);
  
  if (vFileHdl <= 0) then
  begin
    _MsgCsvError('Datei nicht lesbar (Existiert sie und liegt Leseberechtigung vor?): ' + aCsvFilename, aShowDialog);
    vReturn # -1;
  end
  else
  begin
  
    vFileHdl->FsiMark(10);
  
    if aHasHeader then
      vLenLine # vFileHdl->FsiRead(vLine);
      // überspringt erste Zeile
    
    // init: Keine Daten-Zeilen
    vReturn # 0;
    
    // Lese alle Zeilen
    FOR   vLenLine # vFileHdl->FsiRead(vLine);
    LOOP  vLenLine # vFileHdl->FsiRead(vLine);
    WHILE vLenLine > 0 DO BEGIN
    
      // auch lines können mit _NormalizeToken normalisiert werden. Durch StrAdj werden Zeilen aus whitespaces zu leeren Zeilen
      vLine # _NormalizeTokenOrLine(vLine);
      
      if vLine <> '' then
        // zähle nur Zeilen die nach Normalisierung nicht leer sind
        Inc(vReturn);
      
    END;
  
  end;

  vFileHdl->FsiClose();
  return vReturn;

end


//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  Liest einzelne Spalte mit gegebenem Spaltenindex aus einer .csv Datei
//  mit oder ohne header.
//========================================================================

// todo:
// für andere Datentypen: getCsvColumnByIndex_float als Vorlage nehmen um intern Cte mit parametrisierbarem Typ zu nutzen.
// dann wird Typ ein weiterer Eingabeparameter der bestimmt in welchen Typ des Cte Arrays geschrieben wird.
// dann müssen die Lib_Statistics Funktionen ebenfalls auf Cte angepasst werden und einen Typ-Parameter bekommen

sub getCsvColumnByIndex_float
(
  aCsvFilename         : alpha(512);   // Name der .csv Datei. Die exakt erste Zeile muss einen Header mit den Namen der Spalten enthalten, siehe dazu nächstes Argument.
  aColumnIdx           : int;          // Index der zu extrahierenden Spalte. Die erste Spalte hat Index 1.
  aHasHeader           : logic;        // Wenn die Datei einen Header hat, true übergeben, damit die erste Zeile beim Einlesen übersprüngen wird
  var aOutColumnValues : float[];      // array in das die Spaltenwerte eingelesen werden
  opt aSep             : alpha(1);     // Separator der Felder in der .csv Datei
  opt aDecSep          : alpha(1);     // Dezimaltrenner für Zahlen in der .csv Datei
  opt aShowDialog      : logic;        // Fehlermeldungen (DialogBox) aktivieren
) : logic                              // erfolgreich?
local begin
  vFileHdl             : handle;       // auf .csv Datei
  vCols                : int;          // wieviele Spalten gibt es (siehe getCsvNumberOfColumns())
  vDataRows            : int;          // wieviele Zeilen mit Daten gibt es (siehe getCsvNumberOfDataRows())
  vDataRowIdx          : int;          // Index zum Befüllen von aOutColumnValues
  vDataValAlpha        : alpha;        // einzelner gelesener Wert als String
  vDataValFloat        : float;        // einzelner gelesener Wert als float
  vLenLine             : int;          // Länge der aktuellen Zeile
  vLine                : alpha(8192);  // Inhalt der aktuellen Zeile
  vReturn              : logic;
end
begin

  if aSep = '' then aSep # cDefaultSep;
  if aDecSep = '' then aDecSep # cDefaultDecSep;
  
  if !_isValidDecSep(aDecSep) then
  begin
    _MsgCsvError('Das Zeichen aDecSep="' + aDecSep + '" mit dem getCsvColumnByIndex_float() aufgerufen wurde ist als Dezimaltrenner nicht unterstützt.', aShowDialog);
    vReturn # false;
    return vReturn;
  end

  vFileHdl # FsiOpen(aCsvFilename, _FsiStdRead);
  
  if (vFileHdl <= 0) then
  begin
    _MsgCsvError('Datei nicht lesbar (Existiert sie und liegt Leseberechtigung vor?): ' + aCsvFilename, aShowDialog);
    vReturn # false;
  end
  else
  begin
    // prüfe ob Index valide:
    vCols # getCsvNumberOfColumns(aCsvFilename, aSep, aShowDialog);
    if aColumnIdx < 1 or aColumnIdx > vCols then
    begin
      _MsgCsvError
      (
        'Fehler in getCsvColumnByIndex_float(): Indizes beginnen bei 1 und die gelesene Datei hat ' + CnvAI(vCols) +
        ' Spalten. Damit ist der übergebene aColumnIdx=' + CnvAI(aColumnIdx) + ' nicht valide für Datei "' + aCsvFilename + '"',
        aShowDialog
      );
      vReturn # false;
    end
    else
    begin
      // Index ist valide, lese Datei
  
      vFileHdl->FsiMark(10);
      
      vDataRows # getCsvNumberOfDataRows(aCsvFilename, aHasHeader, aShowDialog);
    
      if aHasHeader then
        vLenLine # vFileHdl->FsiRead(vLine);
        // überspringt erste Zeile
        
      // Allokiere Ausgabe Array
      VarAllocate(aOutColumnValues, vDataRows);
      
      // for debug only:
      //DebugM('Es wurden ' + CnvAI(vDataRows) + ' Data Rows gezählt', true);
      
      
      // Lese alle Zeilen und extrahiere dabei die Spalte mit Index aColumnIdx
      vDataRowIdx # 1;
      FOR   vLenLine # vFileHdl->FsiRead(vLine);
      LOOP  vLenLine # vFileHdl->FsiRead(vLine);
      WHILE vLenLine > 0 DO BEGIN
      
        // auch lines können mit _NormalizeToken normalisiert werden. Durch StrAdj werden Zeilen aus whitespaces zu leeren Zeilen
        vLine # _NormalizeTokenOrLine(vLine);
        
        if vLine <> '' then
        begin
          // berücksichtige nur Zeilen die nach Normalisierung nicht leer sind
          vDataValAlpha # _NormalizeTokenOrLine(Lib_Strings:Strings_Token(vLine, aSep, aColumnIdx));
          
          // for debug only:
          //DebugM('datarow[' + CnvAI(vDataRowIdx) + '] == ' + vDataValAlpha, true);
          
          //if vDataValFloat # 1.0 / 0.0;
          
          if aDecSep = ',' then
          begin
            vDataValFloat # CnvFA(vDataValAlpha);
          end
          else if aDecSep = '.' then
          begin
            vDataValFloat # CnvFA(vDataValAlpha, _FmtNumPoint);
          end
          else
          begin
            _MsgCsvError(
              'Dieser Fall sollte nicht eintreten: Das nicht unterstützte Zeichen aDecSep="' + aDecSep +
              '" mit dem getCsvColumnByIndex_float() aufgerufen wurde hat es durch die Prüfung geschafft. ' +
              'Bitte Schließen Sie die Applikation und kontaktieren Sie den Hersteller.',
              true
            );
            vFileHdl->FsiClose();
            vReturn # false;
            return vReturn;
          end
      
          aOutColumnValues[vDataRowIdx] # vDataValFloat;
          
          Inc(vDataRowIdx);
        end
      END;
      
      // prüfe ob wirklich vDataRows geschrieben wurden
      if vDataRowIdx <> vDataRows+1 then
      begin
        _MsgCsvError(
          'Diskrepanz zwischen vDataRowIdx=' + CnvAI(vDataRowIdx) + ' und vDataRows+1=' + CnvAI(vDataRows+1) + '. ' +
          'Bitte Schließen Sie die Applikation und kontaktieren Sie den Hersteller.',
          true
        );
        vReturn # false;
      end
      else
      begin
        vReturn # true;
      end
        
    end;
    
  end

  vFileHdl->FsiClose();
  return vReturn;
  
end


//========================================================================
//  2022-03-31  DS                                               2222/51/1
//
//  Liest einzelne Spalte mit gegebenem Spaltennamen aus einer .csv Datei
//  mit header (d.h. Spaltennamen sind bekannt)
//========================================================================

// todo:
// für andere Datentypen: getCsvColumnByName_float als Vorlage nehmen um intern Cte mit parametrisierbarem Typ zu nutzen.
// dann wird Typ ein weiterer Eingabeparameter der bestimmt in welchen Typ des Cte Arrays geschrieben wird.
// dann müssen die Lib_Statistics Funktionen ebenfalls auf Cte angepasst werden und einen Typ-Parameter bekommen

sub getCsvColumnByName_float
(
  aCsvFilename         : alpha(512);  // Name der .csv Datei. Die exakt erste Zeile muss einen Header mit den Namen der Spalten enthalten, siehe dazu nächstes Argument.
  aColumnName          : alpha(128);  // Name der zu extrahierenden Spalte. Dieser Name muss so im Header stehen
  var aOutColumnValues : float[];     // array in das die Spaltenwerte eingelesen werden
  opt aSep             : alpha(1);    // Separator der Felder in der .csv Datei
  opt aDecSep          : alpha(1);    // Dezimaltrenner für Zahlen in der .csv Datei
  opt aShowDialog      : logic;       // Fehlermeldungen (DialogBox) aktivieren
) : logic                             // erfolgreich?
local begin
  vFileHdl         : handle;          // auf .csv Datei
  vLenLine         : int;             // Länge der aktuellen Zeile
  vLine            : alpha(8192);     // Inhalt der aktuellen Zeile
  vVal             : alpha(4096);     // Inhalt der aktuellen Spalte in der aktuellen Zeile
  vIdx             : int;             // Index der aktuellen Spalte
  vColumnNames     : alpha(128)[];    // alle Spaltennamen
  vReturn          : logic;
end
begin

  if aSep = '' then aSep # cDefaultSep;
  if aDecSep = '' then aDecSep # cDefaultDecSep;
  
  if !_isValidDecSep(aDecSep) then
  begin
    _MsgCsvError('Das Zeichen aDecSep="' + aDecSep + '" mit dem getCsvColumnByName_float() aufgerufen wurde ist als Dezimaltrenner nicht unterstützt.', aShowDialog);
    vReturn # false;
    return vReturn;
  end

  vFileHdl # FsiOpen(aCsvFilename, _FsiStdRead);
  
  if (vFileHdl <= 0) then
  begin
    _MsgCsvError('Datei nicht lesbar (Existiert sie und liegt Leseberechtigung vor?): ' + aCsvFilename, aShowDialog);
    vReturn # false;
  end
  else
  begin
  
    vFileHdl->FsiMark(10);
    
    // prüfe header (erste Zeile)
    vLenLine # vFileHdl->FsiRead(vLine);
    vLenLine # StrLen(_NormalizeTokenOrLine(vLine));
    if vLenLine <= 0 then
    begin
      _MsgCsvError('Datei hat leere erste Zeile: ' + aCsvFilename, aShowDialog);
      vReturn # false;
    end
    else
    begin
    
      // extrahiere alle Spaltennamen:
      if !getCsvColumnNames(aCsvFilename, var vColumnNames, aSep, aShowDialog) then
      begin
        _MsgCsvError('Spaltennamen nicht lesbar: ' + aCsvFilename, aShowDialog);
        vReturn # false;
      end
      else
      begin
      
        // finde Index der gewünschten Spalte:
        FOR   vIdx # 1;
        LOOP  Inc(vIdx);
        WHILE vIdx <= VarInfo(vColumnNames) DO
        BEGIN
          if vColumnNames[vIdx] = aColumnName then
          begin
            break;
          end
        END;
        
        if vIdx > VarInfo(vColumnNames) then
        begin
          _MsgCsvError('Datei enthält nicht die gesuchte Spalte "' + aColumnName + '": ' + aCsvFilename, aShowDialog);
          vReturn # false;
        end
        else
        begin
          // extrahiere die Spalte mit dem gefundenen Index:
          
          // for debug only:
          //DebugM('"' + aColumnName + '" liegt in Spalte: ' + CnvAI(vIdx), true);
          
          vReturn # getCsvColumnByIndex_float(
            aCsvFilename,
            vIdx,
            true, // diese Datei hat einen Header
            var aOutColumnValues,
            aSep,
            aDecSep,
            aShowDialog
          );

        end
      
      end
    
    end
  
  end;
  
  vFileHdl->FsiClose();
  return vReturn;
end


//========================================================================
//  MAIN: Benutzungsbeispiele zum Testen
//========================================================================

MAIN()
local begin
  vNumCols         : int;
  vNumDataRows     : int;
  vColumnNames     : alpha(128)[];
  vColumnValues    : float[];
  vMax             : float;
  vMin             : float;
end;
begin

  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  
  vNumCols # getCsvNumberOfColumns('C:\debug\erg-20220330\kein_header.erg', cDefaultSep, true);
  DebugM('Number of columns: ' + CnvAI(vNumCols));
  
  vNumDataRows # getCsvNumberOfDataRows('C:\debug\erg-20220330\test.ERG', true, true);
  DebugM('Number of rows with Data: ' + CnvAI(vNumDataRows));

  getCsvColumnNames('C:\debug\erg-20220330\13138-4-export.ERG', var vColumnNames, cDefaultSep, true);
  /*
  DebugM('"' + vColumnNames[1] + '"');
  DebugM('"' + vColumnNames[2] + '"');
  DebugM('"' + vColumnNames[3] + '"');
  DebugM('"' + vColumnNames[13] + '"');
  */
  
  getCsvColumnByIndex_float('C:\debug\erg-20220330\test.ERG', 13, true, var vColumnValues, cDefaultSep, cDefaultDecSep, true);
  /*
  DebugM(CnvAF(vColumnValues[1]));
  DebugM(CnvAF(vColumnValues[2]));
  DebugM(CnvAF(vColumnValues[3]));
  */
  
  getCsvColumnByName_float('C:\debug\erg-20220330\test.ERG', 'A{lo 5,65}', var vColumnValues, cDefaultSep, cDefaultDecSep, true);
  /*
  DebugM(CnvAF(vColumnValues[1]));
  DebugM(CnvAF(vColumnValues[2]));
  DebugM(CnvAF(vColumnValues[3]));
  */
  
  vMax # Lib_Statistics:maxArray_float(var vColumnValues);
  vMin # Lib_Statistics:minArray_float(var vColumnValues);
  
  DebugM('Maximum: ' + CnvAF(vMax));
  DebugM('Minimum: ' + CnvAF(vMin));
  
  VarFree(vColumnValues);

  return;
  
end
