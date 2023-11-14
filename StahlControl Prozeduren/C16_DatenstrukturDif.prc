@A+
//===== Business-Control =================================================
//
//  Prozedur  C16_DatenstrukturDif
//                    OHNE E_R_G
//  Info
//
//
//  08.02.2022  DS  Erstellung der Prozedur auf Grundlage von C16_Datenstruktur
//  2022-09-20  ST  keyFldPropName hinzugefügt
//
//  Subprozeduren
//
//========================================================================

define begin
  AInt(a)         : CnvAI(a,_FmtNumNoGroup)
  Msg(a)          : WindialogBox(0, 'C16_DatenstrukturDif', a, 0, 0, 0)
  
  // String Konstanten die als Keys im Json File genutzt werden
  keyTables       : 'Tabellen'
  keyTableName    : 'Tabellen-Name'
  keyTableIdx     : 'Tabellen-Index'
  keyTableClassName  : 'Tabellen-Classname'
  keySbrs         : 'Teildatensaetze'
  keySbrName      : 'Teildatensatz-Name'
  keySbrIdx       : 'Teildatensatz-Index'
  keyFlds         : 'Felder'
  keyFldName      : 'Feld-Name'
  keyFldIdx       : 'Feld-Index'
  keyFldType      : 'Feld-Typ'
  keyFldPropName  : 'Feld-PropName'
  
end;

//========================================================================


//========================================================================
// GetFldType
// Modifiziert aus C16_Datenstruktur:GetFldInfo mit Datentypen aus
// Vectorsoft's git Plugin
//========================================================================

sub GetFldType(
  aTableIdx : int;
  aSbrIdx : int;
  aFldIdx : int;
) : alpha
local begin
  vAlphaLength  : int;
end;
begin

  case FldInfo(aTableIdx, aSbrIdx, aFldIdx, _FldType) of
  
    _TypeAlpha  : begin
      vAlphaLength # FldInfo(aTableIdx, aSbrIdx, aFldIdx, _FldLen);
      RETURN 'Alpha(' + aint(vAlphaLength) + ')';
      end;
      
    _typeWord    : RETURN 'Word';   // war int16
    _typeInt     : RETURN 'Int';
    _typeFloat   : RETURN 'Float';
    _typeLogic   : RETURN 'Logic';
    _typeDate    : RETURN 'Date';
    _typeTime    : RETURN 'Time';
    _typeBigInt  : RETURN 'BigInt';
    _TypeDecimal : RETURN 'Decimal';
  end;
  
  Msg('Unbekannter Typ in Tabelle ' + aint(aTableIdx) + ', Teildatensatz ' + aint(aSbrIdx)+ ', Feld ' + aint(aFldIdx));
  RETURN '';
end;


//========================================================================
// DatastructureToJson
// Angelehnt an C16_Datenstruktur.CreateText, allerdings mit Json Output
// Exportiert die Datenstruktur als Json Cte Baum
//========================================================================

sub DatastructureToJson() : handle
local begin
  vCteRoot     : handle;  // handle auf Wurzel des Baumes, gleichzeitig Rückgabewert
  vCteTables   : handle;  // handle auf Tabellen-Array im Cte Baum
  vCteSbrs     : handle;  // handle auf Teildatensatz-Array im Cte Baum
  vCteFlds     : handle;  // handle auf Felder-Array im Cte Baum
  vCteTableCur : handle;  // lies wahlweise: "current Table" oder "Table Cursor". Handle auf aktuelle Tabelle in Cte Baum
  vCteSbrCur   : handle;  // lies wahlweise: "current Subrecord" oder "Subrecord Cursor". Handle auf aktuellen Teildatendatz in Cte Baum
  vCteFldCur   : handle;  // lies wahlweise: "current Field" oder "Field Cursor". Handle auf aktuelles Feld in Cte Baum
  vTableIdx    : int;
  vSbrIdx      : int;
  vFldIdx      : int;
  vSbrCount    : int;
  vFldCount    : int;
  
  vPropName   : alpha;
end
begin

  vCteRoot # CteOpen(_CteNode);
  vCteRoot->spID # _JsonNodeObject;
  
  // Tabellen ----------------------------------------
  vCteTables # vCteRoot->CteInsertNode(keyTables, _JSONNodeArray, NULL);
  FOR vTableIdx # 1
  LOOP inc(vTableIdx)
  WHILE (vTableIdx<=999) DO BEGIN
    
    // weiter mit nächster Tabelle, falls diese nicht existiert
    if (FileInfo(vTableIdx, _FileExists)=0) then begin
      CYCLE;
    end
    
    // Tabelle einfügen
    vCteTableCur # vCteTables->CteInsertNode('', _JsonNodeObject, NULL);
    
    // Daten der Tabelle
    vCteTableCur->CteInsertNode(keyTableIdx, _JSONNodeNumber, vTableIdx);
    vCteTableCur->CteInsertNode(keyTableName, _JSONNodeString, Filename(vTableIdx));
    vCteTableCur->CteInsertNode(keyTableClassName, _JSONNodeString, Lib_ODBC:TableName(vTableIdx));
    
    
    

    // Teildatensätze --------------------------------------
    vCteSbrs # vCteTableCur->CteInsertNode(keySbrs, _JSONNodeArray, NULL);
    vSbrCount # Fileinfo(vTableIdx, _FileSbrCount);
    FOR vSbrIdx # 1
    LOOP inc(vSbrIdx)
    WHILE (vSbrIdx<=vSbrCount) do begin
    
      // Teildatensatz einfügen
      vCteSbrCur # vCteSbrs->CteInsertNode('', _JsonNodeObject, NULL);
      
      // Daten des Teildatensatzes
      vCteSbrCur->CteInsertNode(keySbrIdx, _JSONNodeNumber, vSbrIdx);
      vCteSbrCur->CteInsertNode(keySbrName, _JSONNodeString, Sbrname(vTableIdx, vSbrIdx));
      
      // Felder --------------------------------------
      vCteFlds # vCteSbrCur->CteInsertNode(keyFlds, _JSONNodeArray, NULL);
      vFldCount # SbrInfo(vTableIdx, vSbrIdx, _SbrFldCount);
      FOR vFldIdx # 1
      LOOP inc(vFldIdx)
      WHILE (vFldIdx<=vFldCount) do begin
        
        // Feld einfügen
        vCteFldCur # vCteFlds->CteInsertNode('', _JsonNodeObject, NULL);
      
        // Daten des Felds
        vCteFldCur->CteInsertNode(keyFldIdx, _JSONNodeNumber, vFldIdx);
        vCteFldCur->CteInsertNode(keyFldName, _JSONNodeString, Fldname(vTableIdx, vSbrIdx, vFldIdx));
        vCteFldCur->CteInsertNode(keyFldType, _JSONNodeString, GetFldType(vTableIdx, vSbrIdx, vFldIdx));
       
        vPropName #    Lib_ODBC:FieldName(vTableIdx, vSbrIdx, vFldIdx);
        vPropName  # StrCut(vPropName,2,StrLen(vPropName)-2);
        vCteFldCur->CteInsertNode(keyFldPropName, _JSONNodeString, vPropName);
       
      END;
    END;
  END;

  return vCteRoot;
  
end


//========================================================================
// GiveUpEarlyError
// eine Abkürzung für Fehlermeldungen die einen Abbruch des Vergleichs
// bedingen. siehe ausgegebener Text und Verwendung für Details.
//
// WICHTIG!
// Auf jeden Aufruf von GiveUpEarlyError() in DatastructureComparison()
// sollte ein "return -1;" folgen, damit tatsächlich aufgegeben wird.
//
//========================================================================
sub GiveUpEarlyError(aErrorDescription : alpha(4096))
local begin
  vClipboardInc  : alpha(4096);  // Inkrement für Text im Clipboard
end
begin

  vClipboardInc # '<Terminaler Fehler>' + StrChar(13) + StrChar(10) + 'Vergleich der Datenstrukturen musste VORZEITIG BEENDET werden wg. folgendem Fehler (weitere potentielle Fehler werden nicht angezeigt):' + StrChar(13) + StrChar(10) +
                  aErrorDescription + StrChar(13) + StrChar(10) + '</Terminaler Fehler>' + StrChar(13) + StrChar(10) + StrChar(13) + StrChar(10);
  App_Update_Data:Todo(vClipboardInc);  // hängt Inkrement an Clipboard an
  
  WinDialogBox
  (
    0,
    'Fehler bei DatastructureComparison()',
    'Vergleich der Datenstrukturen wird vorzeitig beendet da das folgendem Problem den weiteren Vergleich verhindert. Es muss erst gelöst werden.' +
    StrChar(10) + StrChar(10) +
    'Fehler: ' + StrChar(10) +
    aErrorDescription,
    _WinIcoError,
    _WinDialogOK,
    1
  );
end


//========================================================================
// ReportComplexProblem
// eine Abkürzung für Problemmeldungen die keinen Abbruch des
// Vergleichs bedingen. Ersetzt weitestgehend GiveUpEarlyError().
// Statt Abbruch des Vergleichs wird eine Problembeschreibung
// dokumentiert (auch im Clipboard), die die Komplexität der anderen
// Report* Funktionen in dieser Prozedur (für die es klare Anweisungen
// gibt) übersteigt.
//
// siehe ausgegebener Text und Verwendung für Details.
//
//========================================================================
sub ReportComplexProblem(aProblemDescription : alpha(4096))
local begin
  vClipboardInc  : alpha(4096);  // Inkrement für Text im Clipboard
end
begin

  vClipboardInc # '<Komplexes Problem>' + StrChar(13) + StrChar(10) + aProblemDescription + StrChar(13) + StrChar(10) + '</Komplexes Problem>' + StrChar(13) + StrChar(10) + StrChar(13) + StrChar(10);
  App_Update_Data:Todo(vClipboardInc);  // hängt Inkrement an Clipboard an
  
  WinDialogBox
  (
    0,
    'Komplexes Problem bei DatastructureComparison()',
    'Vergleich der Datenstrukturen hat das folgende komplexe Problem festgestellt für das es aktuell keine Lösungsbeschreibung gibt.' +
    StrChar(10) + StrChar(10) +
    'Problem: ' + StrChar(10) +
    aProblemDescription,
    _WinIcoWarning,
    _WinDialogOK,
    1
  );
end


//========================================================================
// ReportThatAlterTableIsNecessary
// eine Abkürzung für Hinweise auf Notwendigkeit eines ALTER TABLE in SQL.
// siehe ausgegebener Text und Verwendung für Details.
//
// WICHTIG!
// Um nach Aufrufen von ReportThatAlterTableIsNecessary() in
// DatastructureComparison() weitere Meldungen für dieselbe Tabelle zu
// unterdrücken, siehe die vStop* Variablen.
//
//========================================================================
sub ReportThatAlterTableIsNecessary(
  aTableIdx       : int;
  aTableName      : alpha(64);
  aAdditionalText : alpha(4096);
)
local begin
  vClipboardInc  : alpha(4096);  // Inkrement für Text im Clipboard
end
begin
  
  vClipboardInc # 'SQL_ALTERTABLE ' + CnvAI(aTableIdx);
  App_Update_Data:Todo(vClipboardInc);  // hängt Inkrement an Clipboard an

  WinDialogBox
  (
    0,
    vClipboardInc + ' erforderlich',
    'Für Tabelle ' + CnvAI(aTableIdx) + ' ' + aTableName + ' ist ein ALTER TABLE in der SQL erforderlich.' +
    StrChar(10) + StrChar(10) +
    'Zusätzliche Information: ' + StrChar(10) +
    aAdditionalText,
    _WinIcoInformation,
    _WinDialogOK,
    1
  );
end


//========================================================================
// ReportThatSyncOneIsNecessary
// eine Abkürzung für Hinweise auf Notwendigkeit eines SYNCONE in SQL.
// siehe ausgegebener Text und Verwendung für Details.
//========================================================================
sub ReportThatSyncOneIsNecessary(
  aTableIdx       : int;
  aTableName      : alpha(64);
  aAdditionalText : alpha(4096);
)
local begin
  vClipboardInc  : alpha(4096);  // Inkrement für Text im Clipboard
end
begin
  
  vClipboardInc # 'SQL_SYNCONE ' + CnvAI(aTableIdx);
  App_Update_Data:Todo(vClipboardInc);  // hängt Inkrement an Clipboard an

  WinDialogBox
  (
    0,
    vClipboardInc + ' erforderlich',
    'Für Tabelle ' + CnvAI(aTableIdx) + ' ' + aTableName + ' ist ein SYNCONE in der SQL erforderlich.' +
    StrChar(10) + StrChar(10) +
    'Zusätzliche Information: ' + StrChar(10) +
    aAdditionalText,
    _WinIcoInformation,
    _WinDialogOK,
  1
  );
end


//========================================================================
// _isIgnorable
// private Hilfsmethode für DatastructureComparison.
// Gibt true zurück, wenn Abweichungen in Feld oder Teildatensatz mit Name
// aName aufgrund des Wertes von aIgnoreWithSubstr (Doku siehe
// DatastructureComparison) ignoriert werden sollen.
//========================================================================
sub _isIgnorable(
  aName             : alpha(64);
  aIgnoreWithSubstr : alpha(64);
) : logic
begin
  return (aIgnoreWithSubstr <> '') and (StrFind(aName, aIgnoreWithSubstr, 0, _StrCaseIgnore) > 0)
end

//========================================================================
// _areAllIgnorable
// private Hilfsmethode für DatastructureComparison.
// Sucht ab Knoten aCteCur nach weiteren Knoten und betrachtet deren
// values (genauer gesagt: spValueAlpha) zum key aKeyName.
// Auf jeden dieser values wird _isIgnorable angewandt. Beim ersten
// value für den _isIgnorable false liefert, wird dieser value
// zurückgegeben um im aufrufenden Code eine Meldung durch
// ReportThatAlterTableIsNecessary() mit diesem Wert auslösen zu können.
// Sollten alle values ignorable sein, wird der leere String ''
// zurückgegeben. Das bedeutet es kommt '' zurück, nur dann wenn ALLE
// spValueAlpha values des aKeyName keys ignorierbar sind gemäß _isIgnorable.
// Sobald DER ERSTE nicht ignorierbare Wert auftritt, wird sofort dieser
// Wert zurückgegeben.
//========================================================================
sub _areAllIgnorable(
  aCteParent        : handle;     // Elter Knoten von aCteCur (dient zur Suche über Kinder)
  vCteCur           : handle;     // aktuell betrachtetes Kind (dessen spValueAlpha als erstes geprüft wird) (v statt a weil es modifiziert wird)
  aKeyName          : alpha(64);  // Schlüssel-Name dessen spValueAlpha geprüft wird
  aIgnoreWithSubstr : alpha(64);  // Parameter für _isIgnorable()
) : alpha
local begin
  vMoreChildren     : logic;      // loop condition
  vChildName        : alpha(64);        // Wert hinter aKeyName des aktuellen Kindes, gleichzeitig return value
end;
begin

  // ----------------------------------------------------------
  // iteriere über Kinder von aCteParent
  vMoreChildren # vCteCur > 0;
  
  while (vMoreChildren) do
  begin
  
    // extrahiere Name für Prüfung
    vChildName # vCteCur->CteRead(_CteFirst | _CteSearch, 0, aKeyName)->spValueAlpha;
    
    if !_isIgnorable(vChildName, aIgnoreWithSubstr)
    then begin
      return vChildName;
    end else begin
      // next
      vCteCur # aCteParent->CteRead(_CteNext | _CteChildList, vCteCur);
      vMoreChildren # vCteCur > 0
    end
    
  end  // iteration über Kinder von aCteParent
          
  return '';  // leerer string (bedeutet alle waren ignorable) wenn nicht schon vorher returned wurde
end


//========================================================================
// _reportOneSidedAdditionalTables
// private Hilfsmethode für DatastructureComparison.
// Sucht ab Knoten vCteATableCur nach weiteren Knoten und ruft für jede
// gefundene weitere Tabelle ReportThatSyncOneIsNecessary() auf, um
// dem Nutzer bekanntzugeben, dass es zusätzliche Tabellen in einer
// Datenstruktur gibt.
// _reportOneSidedExcessTables darf nur aufgerufen werden, wenn die andere
// Datenstruktur bereits keine weiteren Tabellen mehr hat, sonst werden
// Tabellen in der übergebenen Datenstruktur fälschlicherweise als
// additional ausgegeben. Diese Bedingung hat die aufrufende Stelle (!)
// durch entsprechende Iteration sicherzustellen.
//========================================================================
sub _reportOneSidedAdditionalTables(
  aCteTables       : handle;     // Elter Knoten von aCteATableCur (dient zur Suche über Kinder)
  vCteTableCur     : handle;     // aktuell betrachteter Tabellen-Knoten, ein Kind von aCteATableCur (v statt a weil es modifiziert wird)
  aName            : alpha;
) : int;
local begin
  vMoreChildren    : logic;      // loop condition
  vTableName       : alpha;
  vTableIdx        : int;
  vReturnValue     : int;        // Rückgabewert. _ErrOK wenn nichts getan werden muss, -2 wenn etwas getan werden muss
end;
begin

  vReturnValue # _ErrOK;

  // ----------------------------------------------------------
  // iteriere über Kinder von aCteTables
  vMoreChildren # vCteTableCur > 0;
  
  while (vMoreChildren) do
  begin
  
    vReturnValue # -2;
  
    // extrahiere Name und Index
    vTableName # vCteTableCur->CteRead(_CteFirst | _CteSearch, 0, keyTableName)->spValueAlpha;
    vTableIdx # vCteTableCur->CteRead(_CteFirst | _CteSearch, 0, keyTableIdx)->spValueInt;
  
    ReportThatSyncOneIsNecessary(
      vTableIdx,
      vTableName,
      'Zusätzliche Tabelle ' + CnvAI(vTableIdx) + ' ' + vTableName + ' existiert in Datenraum "' + aName + '", während im anderen Datenraum keine weiteren Tabellen existieren.'
    )
  
    // next
    vCteTableCur # aCteTables->CteRead(_CteNext | _CteChildList, vCteTableCur);
    vMoreChildren # vCteTableCur > 0
    
  end  // iteration über Kinder von vCteTableCur
  
  return vReturnValue;

end

//========================================================================
// DatastructureComparison
// Vergleicht die übergebenen Datenstrukturen
//
// WICHTIG:
// STD sollte immer als A, nicht als B übergeben werden (siehe Argumente)
// LIVE sollte immer als B, nicht als A übergeben werden.
// Nur DEV kommt in beiden Rollen vor, siehe Beispielaufrufe in der main
// Methode. Hintergrund ist, dass Vergleiche stets aufwärts entlang der
// Kette STD -> DEV -> LIVE geschehen und es entsprechend nur die
// Vergleiche STD vs. DEV und DEV vs. LIVE gibt. Die Argumente dabei
// müssen in dieser Reihenfolge verwendet werden.
//========================================================================
sub DatastructureComparison(
  aCteA             : handle;  // handle auf Cte Baum mit Datenstruktur, siehe DatastructureComparison und Lib_Json:LoadJson
  aCteB             : handle;  // s.o.
  aNameA            : alpha;   // friendly names, mit denen das Lesen der Meldungen intuitiver wird
  aNameB            : alpha;   // s.o.
  aIgnoreWithSubstr : alpha;   // Überzählige Teildatensätze und Felder in aCteB (und nur dort!) werden ignoriert, wenn sie aIgnoreWithSubstr als Substring enthalten
                               // D.h. die geprüfte Gleichheit von aCteA und aCteB gilt nicht als verletzt, wenn aCteB zusätzliche Teildatensätze und Felder enthält
                               // solange deren Namen diesen Substring enthalten. Dies kann dazu genutzt werden, den STD (als aCteA) mit einem DEV Datenraum des Kunden
                               // (als aCteB) zu vergleichen, ohne dass dessen 'cust' (als aIgnoreWithSubstr) Felder zu Alter Table Meldungen führen.
                               // Beim Vergleich von DEV zu LIVE des Kunden sollte dann die exakte Gleichheit (aIgnoreWithSubstr='') geprüft werden.
  opt aCompareTable860Sbr3 : logic;  // false (default): Teildatensatz 3 der Tabelle 860 wird nicht geprüft (da hier die reinen custom Felder der speziellen Tabelle 860 lagern)
                                     // true: dann wird auch dieser Teildatensatz geprüft, was in den meisten Fällen dazu führt, dass Abweichungen zwischen STD und Kunden
                                     // Datenstruktur in Tabelle 860 gemeldet werden
) : int
local begin
  vCteATables   : handle;       // Datenstruktur A, Bedeutungen analog zu entsprechend benannten Variablen in DatastructureToJson
  vCteASbrs     : handle;       // s.o.
  vCteAFlds     : handle;       // s.o.
  vCteATableCur : handle;       // s.o.
  vCteASbrCur   : handle;       // s.o.
  vCteAFldCur   : handle;       // s.o.
  vCteBTables   : handle;       // Datenstruktur B, Bedeutungen analog zu entsprechend benannten Variablen in DatastructureToJson
  vCteBSbrs     : handle;       // s.o.
  vCteBFlds     : handle;       // s.o.
  vCteBTableCur : handle;       // s.o.
  vCteBSbrCur   : handle;       // s.o.
  vCteBFldCur   : handle;       // s.o.
  vMoreTables   : logic;        // Iterationsbedingungen
  vMoreSbrs     : logic;        // s.o.
  vMoreFlds     : logic;        // s.o.
  vStopSbrs     : logic;        // siehe Verwendung
  vStopFlds     : logic;        // siehe Verwendung
  vATableIdx    : int;          // aktuelle Werte der jeweiligen Größen (values aus json)
  vATableName   : alpha(64);    // s.o.
  vASbrIdx      : int;          // s.o.
  vASbrName     : alpha(64);    // s.o.
  vAFldIdx      : int;          // s.o.
  vAFldName     : alpha(64);    // s.o.
  vAFldType     : alpha(64);    // s.o.
  vBTableIdx    : int;          // s.o.
  vBTableName   : alpha(64);    // s.o.
  vBSbrIdx      : int;          // s.o.
  vBSbrName     : alpha(64);    // s.o.
  vBFldIdx      : int;          // s.o.
  vBFldName     : alpha(64);    // s.o.
  vBFldType     : alpha(64);    // s.o.
  vReturnValue  : int;          // Rückgabewert. _ErrOK wenn nichts getan werden muss, -1 wenn Vergleich vorzeitig abgebrochen werden musste, -2 wenn etwas getan werden muss
end
begin

  vReturnValue # _ErrOK;

  // friendly names müssen gefüllt sein
  if aNameA = '' then aNameA # 'A';
  if aNameB = '' then aNameB # 'B';
  
  // wenn aIgnoreWithSubstr leer ist, soll ein exakter Vergleich erfolgen, das beeinflusst AUCH
  // den Wert von aCompareTable860Sbr3, denn in diesem Fall sollen auch Tabelle 860, Teildatensatz 3
  // exakt übereinstimmen:
  if (aIgnoreWithSubstr = '') then begin
    aCompareTable860Sbr3 # true;
  end
  
  // einstieg in keyTables
  vCteATables # aCteA->CteRead(_CteFirst);
  if (vCteATables <= 0 or vCteATables->spName <> keyTables) then begin
    GiveUpEarlyError('Key "' + keyTables + '" nicht vorhanden oder nicht an erster Position in Datenstruktur "' + aNameA + '"');
    return -1;
  end
  vCteBTables # aCteB->CteRead(_CteFirst);
  if (vCteBTables <= 0 or vCteBTables->spName <> keyTables) then begin
    GiveUpEarlyError('Key "' + keyTables + '" nicht vorhanden oder nicht an erster Position in Datenstruktur "' + aNameB + '"');
    return -1;
  end
  
  // ----------------------------------------------------------
  // iteriere über array mit den Tabellen
  vCteATableCur # vCteATables->CteRead(_CteFirst | _CteChildList)
  vCteBTableCur # vCteBTables->CteRead(_CteFirst | _CteChildList)
  vMoreTables # vCteATableCur > 0 and vCteBTableCur > 0;
  
  while (vMoreTables) do
  begin
  
    // prüfe Nummer und Name der Tabelle
    vATableIdx # vCteATableCur->CteRead(_CteFirst | _CteSearch, 0, keyTableIdx)->spValueInt;
    vBTableIdx # vCteBTableCur->CteRead(_CteFirst | _CteSearch, 0, keyTableIdx)->spValueInt;
    vATableName # vCteATableCur->CteRead(_CteFirst | _CteSearch, 0, keyTableName)->spValueAlpha;
    vBTableName # vCteBTableCur->CteRead(_CteFirst | _CteSearch, 0, keyTableName)->spValueAlpha;
    
          
    // tabelle für vergleich skippen wenn folgende bedingungen gelten:
    // - Tabellen mit Tilden im Namen sind nicht relevant für SQL SYNC
    // - Tabellen für die Lib_Odbc:TableName() den leeren String liefert haben keinen Namen in SQL,
    //   was daran liegt dass sie dort nicht relevant sind.
    if    strfind(vATableName, '~', 0) <> 0
       or Lib_Odbc:TableName(vATableIdx) = ''
       or strfind(vBTableName, '~', 0) <> 0
       or Lib_Odbc:TableName(vBTableIdx) = ''
    then
    begin
      // mindestens eine der beiden Tabellen ist irrelevant.
      // Nun die Detail-Prüfung um ein bis zwei irrelevante Tabellen zu skippen
      
      if    strfind(vATableName, '~', 0) <> 0
         or Lib_Odbc:TableName(vATableIdx) = ''
      then
      begin
        // Tabelle A irrelevant, nächste Tabelle A:
        vCteATableCur # vCteATables->CteRead(_CteNext | _CteChildList, vCteATableCur);
        vMoreTables # vCteATableCur > 0 and vCteBTableCur > 0;
      end
      
      if    strfind(vBTableName, '~', 0) <> 0
         or Lib_Odbc:TableName(vBTableIdx) = ''
      then
      begin
        // Tabelle B irrelevant, nächste Tabelle B:
        vCteBTableCur # vCteBTables->CteRead(_CteNext | _CteChildList, vCteBTableCur);
        vMoreTables # vCteATableCur > 0 and vCteBTableCur > 0;
      end
    
      // in jedem Fall nächste Iteration der Schleife über die Tabellen
      cycle;
    end
    
        
    if (vATableIdx <> vBTableIdx or vATableName <> vBTableName) then begin
      if vATableIdx = vBTableIdx then begin
        // Index gleich, Name unterschiedlich -> GiveUpEarlyError, da nicht klar ist, ob in A oder B die nächste Tabelle betrachtet werden muss
        GiveUpEarlyError
        (
          'Abweichung in ' + keyTableIdx + ' ' + CnvAI(vATableIdx) +
          StrChar(10) + StrChar(10) +
          'In "' + aNameA + '": ' + CnvAI(vATableIdx) + ' ' + vATableName + '. ' +
          'In "' + aNameB + '": ' + CnvAI(vBTableIdx) + ' ' + vBTableName + '. ' +
          StrChar(10) + StrChar(10) +
          'Wurde ein/e ' + keyTables + ' an Index ' + CnvAI(vATableIdx) + ' umbenannt oder überschrieben?'
        );
        return -1;
      end
      else
      begin
        if vATableIdx < vBTableIdx then begin
          // neue Tabelle in A an einem bisher nicht belegten Index
          ReportThatSyncOneIsNecessary(
            vATableIdx,
            vATableName,
            'Die ' + keyTables + ' mit Index ' + CnvAI(vATableIdx) + ' existiert in Datenraum "' + aNameA + '", während in Datenraum "' + aNameB + '" keine Tabelle an diesem Index existiert.'
          )
          // nächste Tabelle in A wählen und while (vMoreTables) von vorn starten
          vCteATableCur # vCteATables->CteRead(_CteNext | _CteChildList, vCteATableCur);
          vMoreTables # vCteATableCur > 0 and vCteBTableCur > 0;
          vReturnValue # -2
          cycle;
        end
        else begin
          // neue Tabelle in B an einem bisher nicht belegten Index
          ReportThatSyncOneIsNecessary(  // evtl stattdessen lieber ReportComplexProblem?
            vBTableIdx,
            vBTableName,
            'Die ' + keyTables + ' mit Index ' + CnvAI(vBTableIdx) + ' existiert in Datenraum "' + aNameB + '", während in Datenraum "' + aNameA + '" keine Tabelle an diesem Index existiert.'
          )
          // nächste Tabelle in B wählen und while (vMoreTables) von vorn starten
          vCteBTableCur # vCteBTables->CteRead(_CteNext | _CteChildList, vCteBTableCur);
          vMoreTables # vCteATableCur > 0 and vCteBTableCur > 0;
          vReturnValue # -2
          cycle;
        end
      end
    end
    
    // ----------------------------------------------------------
    // iteriere über array mit den Teildatensätzen
    vCteASbrs # vCteATableCur->CteRead(_CteFirst | _CteSearch, 0, keySbrs);
    vCteBSbrs # vCteBTableCur->CteRead(_CteFirst | _CteSearch, 0, keySbrs);

    vCteASbrCur # vCteASbrs->CteRead(_CteFirst | _CteChildList)
    vCteBSbrCur # vCteBSbrs->CteRead(_CteFirst | _CteChildList)
    
    vMoreSbrs # vCteASbrCur > 0 and vCteBSbrCur > 0;

    while (vMoreSbrs) do
    begin
    
      // prüfe Index und Name des Teildatensatzes
      vASbrIdx # vCteASbrCur->CteRead(_CteFirst | _CteSearch, 0, keySbrIdx)->spValueInt;
      vBSbrIdx # vCteBSbrCur->CteRead(_CteFirst | _CteSearch, 0, keySbrIdx)->spValueInt;
      vASbrName # vCteASbrCur->CteRead(_CteFirst | _CteSearch, 0, keySbrName)->spValueAlpha;
      vBSbrName # vCteBSbrCur->CteRead(_CteFirst | _CteSearch, 0, keySbrName)->spValueAlpha;
      if (vASbrIdx <> vBSbrIdx or vASbrName <> vBSbrName) then begin
        ReportThatAlterTableIsNecessary
        (
          vATableIdx,
          vATableName,
          'Erste gefundene Abweichung besteht im Bereich ' + keySbrs + '.' +
          StrChar(10) + StrChar(10) +
          keySbrs + ' weicht wie folgt ab:' + StrChar(10) +
          'In "' + aNameA + '": ' + CnvAI(vASbrIdx) + ' ' + vASbrName + '. ' + StrChar(10) +
          'In "' + aNameB + '": ' + CnvAI(vBSbrIdx) + ' ' + vBSbrName + '. ' +
          StrChar(10) + StrChar(10) +
          'Wurde ein/e ' + keySbrs + ' neu angelegt/umbenannt/gelöscht?' +
          StrChar(10) + StrChar(10) +
          'Weitere Abweichungen in der o.g. Tabelle können existieren, werden aber nicht zusätzlich gemeldet.'
        );
        vReturnValue # -2;
        vStopFlds # true;  // siehe letzter Satz der obigen Meldung
        vStopSbrs # true;
      end
      
      
      // ----------------------------------------------------------
      // iteriere über array mit den Feldern
      vCteAFlds # vCteASbrCur->CteRead(_CteFirst | _CteSearch, 0, keyFlds);
      vCteBFlds # vCteBSbrCur->CteRead(_CteFirst | _CteSearch, 0, keyFlds);

      vCteAFldCur # vCteAFlds->CteRead(_CteFirst | _CteChildList)
      vCteBFldCur # vCteBFlds->CteRead(_CteFirst | _CteChildList)
      
      vMoreFlds # vCteAFldCur > 0 and vCteBFldCur > 0;
      
      while (vMoreFlds) do
      begin
      
        // prüfe Index, Name und Typ des Felds
        vAFldIdx  # vCteAFldCur->CteRead(_CteFirst | _CteSearch, 0, keyFldIdx)->spValueInt;
        vBFldIdx  # vCteBFldCur->CteRead(_CteFirst | _CteSearch, 0, keyFldIdx)->spValueInt;
        vAFldName # vCteAFldCur->CteRead(_CteFirst | _CteSearch, 0, keyFldName)->spValueAlpha;
        vBFldName # vCteBFldCur->CteRead(_CteFirst | _CteSearch, 0, keyFldName)->spValueAlpha;
        vAFldType # vCteAFldCur->CteRead(_CteFirst | _CteSearch, 0, keyFldType)->spValueAlpha;
        vBFldType # vCteBFldCur->CteRead(_CteFirst | _CteSearch, 0, keyFldType)->spValueAlpha;
        if
        (
          vAFldIdx <> vBFldIdx or
          vAFldName <> vBFldName or
          vAFldType <> vBFldType
        )
        then begin
          ReportThatAlterTableIsNecessary
          (
            vATableIdx,
            vATableName,
            'Erste gefundene Abweichung besteht in' +
            StrChar(10) + StrChar(10) +
            keySbrs + StrChar(10) +
            CnvAI(vASbrIdx) + ' ' + vASbrName + ' ' +
            StrChar(10) + StrChar(10) +
            keyFlds + ' weicht wie folgt ab:' + StrChar(10) +
            'In "' + aNameA + '": ' + CnvAI(vAFldIdx) + ' ' + vAFldName + ' ' + vAFldType + '. ' + StrChar(10) +
            'In "' + aNameB + '": ' + CnvAI(vBFldIdx) + ' ' + vBFldName + ' ' + vBFldType + '. ' +
            StrChar(10) + StrChar(10) +
            'Wurde ein/e ' + keyFlds + ' neu angelegt/umbenannt/gelöscht/Typ geändert? ' +
            StrChar(10) + StrChar(10) +
            'Weitere Abweichungen in der o.g. Tabelle können existieren, werden aber nicht zusätzlich gemeldet.'
          );
          vReturnValue # -2;
          vStopFlds # true;  // siehe letzter Satz der obigen Meldung
          vStopSbrs # true;
        end

        // nächstes Feld in beiden Datenstrukturen
        vCteAFldCur # vCteAFlds->CteRead(_CteNext | _CteChildList, vCteAFldCur)
        vCteBFldCur # vCteBFlds->CteRead(_CteNext | _CteChildList, vCteBFldCur)
        
        if vStopFlds then begin
          vMoreFlds # false;  // keine weiteren Felder dieses Teildatensatzes mehr betrachten
          vStopFlds # false;  // reset
          vCteAFldCur # 0;    // auch nicht außerhalb der Schleife auf Längendifferenzen prüfen
          vCteBFldCur # 0;    // s.o.
        end else begin
          vMoreFlds # vCteAFldCur > 0 and vCteBFldCur > 0;
        end
        
      end  // Iteration über Felder
      
      // prüfe ob jeweils einer der beiden Teildatensätze noch weitere Felder hat
      
      if (vCteAFldCur > 0) then begin
        ReportThatAlterTableIsNecessary
        (
          vATableIdx,
          vATableName,
          'Abweichung bei ' + keyTables + ' ' + CnvAI(vATableIdx) + ' ' + vATableName + ', ' + keySbrs + ' ' + CnvAI(vASbrIdx) + ' ' + vASbrName + ': ' +
          StrChar(10) + StrChar(10) +
          'In ' + aNameA + ' gibt es mindestens noch ' + keyFldName + ' ' +
          vCteAFldCur->CteRead(_CteFirst | _CteSearch, 0, keyFldName)->spValueAlpha +
          StrChar(10) +
          'In ' + aNameB + ' gibt es hingegen keine (weiteren) ' + keyFlds + '.'
        );
        vReturnValue # -2;
        vStopSbrs # true;
      end
      
      if (vCteBFldCur > 0) then begin
      
        // den Fall dass B etwas hat das A nicht hat könnten wir ignorieren dürfen:
        if
        (_isIgnorable(
          vCteBFldCur->CteRead(_CteFirst | _CteSearch, 0, keyFldName)->spValueAlpha,
          aIgnoreWithSubstr)
        ) then begin
          // erstes Feld ist ignorierbar, aber sind auch alle folgenden Felder ignorierbar?
          if '' <> _areAllIgnorable(vCteBFlds, vCteBFldCur, keyFldName, aIgnoreWithSubstr) then begin
            ReportThatAlterTableIsNecessary
            (
              vATableIdx,
              vATableName,
              'Abweichung bei ' + keyTables + ' ' + CnvAI(vATableIdx) + ' ' + vATableName + ', ' + keySbrs + ' ' + CnvAI(vASbrIdx) + ' ' + vASbrName + ': ' +
              StrChar(10) + StrChar(10) +
              'In ' + aNameA + ' gibt es keine (weiteren) ' + keyFlds + '.' + StrChar(10) +
              'In ' + aNameB + ' gibt es hingegen mindestens noch ' + keyFldName + StrChar(10) +
              _areAllIgnorable(vCteBFlds, vCteBFldCur, keyFldName, aIgnoreWithSubstr) + StrChar(10) +
              'in dem nicht aIgnoreWithSubstr="' + aIgnoreWithSubstr + '" vorkommt.'
            );
            vReturnValue # -2;
            vStopSbrs # true;
          end
        
        end
        else
        begin
        
          ReportThatAlterTableIsNecessary
          (
            vATableIdx,
            vATableName,
            'Abweichung bei ' + keyTables + ' ' + CnvAI(vATableIdx) + ' ' + vATableName + ', ' + keySbrs + ' ' + CnvAI(vASbrIdx) + ' ' + vASbrName + ': ' +
            StrChar(10) + StrChar(10) +
            'In ' + aNameA + ' gibt es keine (weiteren) ' + keyFlds + '.' + StrChar(10) +
            'In ' + aNameB + ' gibt es hingegen mindestens noch ' + keyFldName + ' ' +
            vCteBFldCur->CteRead(_CteFirst | _CteSearch, 0, keyFldName)->spValueAlpha
          );
          vReturnValue # -2;
          vStopSbrs # true;
        end
      end
      
      // nächster Teildatensatz in beiden Datenstrukturen
      vCteASbrCur # vCteASbrs->CteRead(_CteNext | _CteChildList, vCteASbrCur)
      vCteBSbrCur # vCteBSbrs->CteRead(_CteNext | _CteChildList, vCteBSbrCur)
      
      if vStopSbrs then begin
        vMoreSbrs # false;  // keine weiteren Teildatensätze dieser Tabelle mehr betrachten
        vStopSbrs # false;  // reset
        vCteASbrCur # 0;    // auch nicht außerhalb der Schleife auf Längendifferenzen prüfen
        vCteBSbrCur # 0;    // s.o.
        
      end
      else
      begin
      
        // reguläres Update der Schleifenvariablen
        vMoreSbrs # vCteASbrCur > 0 and vCteBSbrCur > 0;
        
        // Sonderfall der zu weiterem Update der Schleifenvariablen führen kann
        if !aCompareTable860Sbr3 and vMoreSbrs then begin
          // überspringe nächsten Teildatensatz, falls es sich um Teildatensatz 3 der Tabelle 860 handelt
          if
          (
            vATableIdx = 860 and
            vCteASbrCur->CteRead(_CteFirst | _CteSearch, 0, keySbrIdx)->spValueInt = 3 and
            vCteBSbrCur->CteRead(_CteFirst | _CteSearch, 0, keySbrIdx)->spValueInt = 3
          ) then begin
            // überspringe Teildatensatz 3 in beiden Datenstrukturen...
            vCteASbrCur # vCteASbrs->CteRead(_CteNext | _CteChildList, vCteASbrCur)
            vCteBSbrCur # vCteBSbrs->CteRead(_CteNext | _CteChildList, vCteBSbrCur)
            //... und Update der Schleifenvariablen
            vMoreSbrs # vCteASbrCur > 0 and vCteBSbrCur > 0;
          end
        end
      end
      
    end  // Iteration über Teildatensätze
    
    // prüfe ob jeweils eine der beiden Tabellen noch weitere Teildatensätze hat
 
    if (vCteASbrCur > 0) then begin
      ReportThatAlterTableIsNecessary
      (
        vATableIdx,
        vATableName,
        'Abweichung bei ' + keyTables + ' ' + CnvAI(vATableIdx) + ' ' + vATableName + ': ' +
        StrChar(10) + StrChar(10) +
        'In ' + aNameA + ' gibt es mindestens noch ' + keySbrName + ' ' +
        vCteASbrCur->CteRead(_CteFirst | _CteSearch, 0, keySbrName)->spValueAlpha +
        StrChar(10) +
        'In ' + aNameB + ' gibt es hingegen keine (weiteren) ' + keySbrs + '.'
      );
      vReturnValue # -2;
    end
    
    if (vCteBSbrCur > 0) then begin
    
      // den Fall dass B etwas hat das A nicht hat könnten wir ignorieren dürfen:
      if
      (_isIgnorable(
        vCteBSbrCur->CteRead(_CteFirst | _CteSearch, 0, keySbrName)->spValueAlpha,
        aIgnoreWithSubstr)
      ) then begin
        // erster Teildatensatz ist ignorierbar, aber sind auch alle folgenden Teildatensätze ignorierbar?
        if '' <> _areAllIgnorable(vCteBSbrs, vCteBSbrCur, keySbrName, aIgnoreWithSubstr) then begin
          ReportThatAlterTableIsNecessary
          (
            vATableIdx,
            vATableName,
            'Abweichung bei ' + keyTables + ' ' + CnvAI(vATableIdx) + ' ' + vATableName + ': ' +
            StrChar(10) + StrChar(10) +
            'In ' + aNameA + ' gibt es keine (weiteren) ' + keySbrs + '.' + StrChar(10) +
            'In ' + aNameB + ' gibt es hingegen mindestens noch ' + keySbrName + StrChar(10) +
            _areAllIgnorable(vCteBSbrs, vCteBSbrCur, keySbrName, aIgnoreWithSubstr) + StrChar(10) +
            'in dem nicht aIgnoreWithSubstr="' + aIgnoreWithSubstr + '" vorkommt.'
          );
          vReturnValue # -2;
          vStopSbrs # true;
        end
      end else begin
        ReportThatAlterTableIsNecessary
        (
          vATableIdx,
          vATableName,
          'Abweichung bei ' + keyTables + ' ' + CnvAI(vATableIdx) + ' ' + vATableName + ': ' +
          StrChar(10) + StrChar(10) +
          'In ' + aNameA + ' gibt es keine (weiteren) ' + keySbrs + '.' + StrChar(10) +
          'In ' + aNameB + ' gibt es hingegen mindestens noch ' + keySbrName + ' ' +
          vCteBSbrCur->CteRead(_CteFirst | _CteSearch, 0, keySbrName)->spValueAlpha
        );
        vReturnValue # -2;
      end
    end

    // nächste Tabelle in beiden Datenstrukturen
    vCteATableCur # vCteATables->CteRead(_CteNext | _CteChildList, vCteATableCur)
    vCteBTableCur # vCteBTables->CteRead(_CteNext | _CteChildList, vCteBTableCur)
    
    vMoreTables # vCteATableCur > 0 and vCteBTableCur > 0;
    
  end  // Iteration über Tabellen
 
  // prüfe jeweils ob eine von beiden Datenstrukturen noch mehr Tabellen enthält
  if vCteATableCur > 0 then begin
    _reportOneSidedAdditionalTables(vCteATables, vCteATableCur, aNameA);
    vReturnValue # -2;
  end
  if vCteBTableCur > 0 then begin
    _reportOneSidedAdditionalTables(vCteBTables, vCteBTableCur, aNameB);
    vReturnValue # -2;
  end
  
  return vReturnValue;

end


//========================================================================
// saveJsonToDataspace
// Speichert Json Daten in übergebenem Cte handle im Datenraum ab.
// Da dies nicht ohne Weiteres geht, wird ein Umweg über eine temporäre
// Datei genommen
//========================================================================
sub saveJsonToDataspace(
  aCteJson         : handle;     // handle auf JSON Objekte in Cte Struktur
  aNameInDataspace : alpha(64);  // Name unter dem im Datenraum gespeichert wird
)
local begin
  vTmpFilename   : alpha(64);
  vTmpFilehandle : handle;
end
begin
  // json Cte Struktur serialisieren in TEMP file:
  vTmpFilename # lib_Strings:Strings_Win2Dos(SysGetEnv('TEMP')) + '\c16_temp.json';
  aCteJson->JsonSave(vTmpFilename, _JsonSaveDefault, 0, _CharsetUTF8);
  // resultierenden json string laden aus TEMP file:
  vTmpFilehandle # TextOpen(32);
  vTmpFilehandle->TextRead(vTmpFilename, _TextExtern);
  // schreibe Inhalt der geladenen Datei in Datenraum
  vTmpFilehandle->TextWrite(aNameInDataspace, 0);
  // schließen
  vTmpFilehandle->TextClose();
end


//========================================================================
// loadJsonFromDataspace
// Lädt Json Daten in übergebenem Cte handle im Datenraum ab.
// Da dies nicht ohne Weiteres geht, wird ein Umweg über eine temporäre
// Datei genommen
//========================================================================
sub loadJsonFromDataspace(
  aNameInDataspace       : alpha(64);  // Name im Datenraum der zu ladenden Json Text Datei
) : handle
local begin
  vFilehandleInDataspace : handle;     // handle auf Text Datei in Datenraum
  vTmpFilename           : alpha(64);  // Name der Temp Datei
  vCteJson               : handle;     // handle auf geladene JSON Objekte in Cte Struktur (return value)
end
begin
  // lade json string aus Datenraum:
  vFilehandleInDataspace # TextOpen(32);
  if (vFilehandleInDataspace->TextRead(aNameInDataspace, 0) <> _rOk) then return -1;
  // schreibe json string in externe temp Datei:
  vTmpFilename # lib_Strings:Strings_Win2Dos(SysGetEnv('TEMP')) + '\c16_temp.json';
  vFilehandleInDataspace->TextWrite(vTmpFilename, _TextExtern);
  // lade Datenstruktur aus externer Datei
  vCteJson # Lib_Json:LoadJson(vTmpFilename);
  // schließe Datei
  vFilehandleInDataspace->TextClose();
  // gib Cte handle zurück:
  return vCteJson
end


//========================================================================
// ComparisonDuringUpdate()
// Deckt die zwei Fälle des Datenstruktur-Vergleichs ('STD->DEV' und
// 'DEV->LIVE') ab, die im Kontext der Update POST Installation Routine
// auftreten können (siehe MAIN Methode von App_Update_Data).
//========================================================================
sub ComparisonDuringUpdate(
  aWhichComparison       : alpha;  // Akzeptierte Werte: 'STD->DEV' und 'DEV->LIVE'
)
local begin
  vJsonNameA             : alpha;
  vJsonNameB             : alpha;
  vCteDatastructureA     : handle;
  vCteDatastructureB     : handle;
end
begin

  if (StrCnv(aWhichComparison, _StrUpper)) = 'STD->DEV' then
  begin
    vJsonNameA # '!Datenstruktur.STD';
    vJsonNameB # '!Datenstruktur.DEV';
  end
  else
  begin
  
    if (StrCnv(aWhichComparison, _StrUpper)) = 'DEV->LIVE' then
    begin
      vJsonNameA # '!Datenstruktur.DEV';
      vJsonNameB # '!Datenstruktur.LIVE';
    end
    else
    begin
      Msg('Abbruch des automatisierten Datenstruktur-Vergleichs. Grund: C16_DatenstrukturDif:ComparisonDuringUpdate() akzeptiert nur die beiden Werte "STD->DEV" und "DEV->LIVE". Erhalten: "' + aWhichComparison + '".');
      return;
    end

  end

  // Datenstrukturen zum Vergleich aus Datenraum laden
  vCteDatastructureA # C16_DatenstrukturDif:loadJsonFromDataspace(vJsonNameA);
  vCteDatastructureB # C16_DatenstrukturDif:loadJsonFromDataspace(vJsonNameB);
  
  if (vCteDatastructureA <= 0) then begin
    WindialogBox(0, 'Datenstruktur-Vergleich', 'Text "' + vJsonNameA + '" konnte nicht aus dem aktuellen Datenraum geladen werden.', 0, 0, 0);
    vCteDatastructureA # 0; // damit Lib_Json:CloseJSON funktioniert
  end
  
  if (vCteDatastructureB <= 0) then begin
    WindialogBox(0, 'Datenstruktur-Vergleich', 'Text "' + vJsonNameB + '" konnte nicht aus dem aktuellen Datenraum geladen werden.', 0, 0, 0);
    vCteDatastructureB # 0; // damit Lib_Json:CloseJSON funktioniert
  end
  
  if (vCteDatastructureA > 0 and vCteDatastructureB > 0) then begin
    // Daten sind vorhanden, nun prüfe für Parametrisierung des Vergleichs welcher der beiden Fälle vorliegt:
  
    if (StrCnv(aWhichComparison, _StrUpper)) = 'STD->DEV' then
    begin
      // Da hier ein STD Update in den kundenspezifischen DEV Datenraum eingespielt wird,
      // geschieht der Vergleich der Datenstrukturen mit Toleranz bei SBRs und FLDs in
      // der DEV Datenstruktur die den substring 'cust' enthalten.
      // Diese sorgen beim toleranten Vergleich NICHT für einen ALTER TABLE Hinweis
      C16_DatenstrukturDif:DatastructureComparison(vCteDatastructureA, vCteDatastructureB, 'STD', 'DEV', 'cust');
    end
    else  // Vorliegen eines dritten Falls bereits oben geprüft
    begin
      // Da hier ein kundenspezifisches DEV Update in den LIVE Datenraum desselben Kunden
      // eingespielt wird, wird exakte Gleichheit der Datenstrukturen gefordert.
      // Bei jeglicher Abweichung (also auch wenn SBRs und FLDs den substring 'cust' enthalten),
      // wird dabei pro Tabelle ein ALTER TABLE Hinweis gegeben.
      C16_DatenstrukturDif:DatastructureComparison(vCteDatastructureA, vCteDatastructureB, 'DEV', 'LIVE', '');
    end

  end else begin
    WindialogBox(0, 'Datenstruktur-Vergleich', 'Der Datenstruktur-Vergleich von ' + aWhichComparison + ' muss wegen früheren Fehlern übersprungen werden.', 0, 0, 0)
  end

  Lib_Json:CloseJSON(var vCteDatastructureA);
  Lib_Json:CloseJSON(var vCteDatastructureB);

end


//========================================================================
// MAIN (Beispiele der Benutzung)
//========================================================================


main
(
)
local begin
  vCteDataJson       : handle;
  vCteDataLoaded     : handle;
  vCteDataSTD        : handle;
  vCteDataDEV        : handle;
  vCteDataLIVE       : handle;
end
begin
  
  //Datenstruktur als json auf Festplatte speichern
  /*
  vCteDataJson # DatastructureToJson();
  vCteDataJson->JsonSave('C:\debug\datastructure.json', _JsonSaveDefault, 0, _CharsetUTF8);
  Lib_Json:CloseJSON(var vCteDataJson);
  */
  
  
  //Datenstruktur als json in Datenraum speichern
  /*
  vCteDataJson # DatastructureToJson();
  saveJsonToDataspace(vCteDataJson, '!!loeschen_datastruc');
  Lib_Json:CloseJSON(var vCteDataJson);
  */
  
  
  //Datenstruktur json aus Datenraum laden (mit Umweg über Datei)
  /*
  vCteDataLoaded # loadJsonFromDataspace('!!loeschen_datastruc');
  Lib_Json:CloseJSON(var vCteDataLoaded);
  */
  
  
  //Datenstrukturen aus json laden und vergleichen
  // ground truth siehe: C:\Workspaces\Debug\C16_DatenstrukturDif\ground_truth.txt
  vCteDataSTD  # Lib_Json:LoadJson('C:\Workspaces\Debug\C16_DatenstrukturDif\datastructure_std_2022-02-09.json');
  vCteDataDEV  # Lib_Json:LoadJson('C:\Workspaces\Debug\C16_DatenstrukturDif\datastructure_bsc_2022-02-11.json');
  vCteDataLIVE # Lib_Json:LoadJson('C:\Workspaces\Debug\C16_DatenstrukturDif\datastructure_bsc_2022-02-14.json');

  // Dieser Vergleich würde beim Update von STD nach DEV stattfinden
  // (Abweichungen in SBRs und FLDs deren Name den substring 'cust' enthält sorgen NICHT für eine Meldung)
  Msg('main: Beginne Vergleich STD -> DEV');
  DatastructureComparison(vCteDataSTD, vCteDataDEV, 'STD', 'DEV', 'cust');
  Msg('main: Beendet: Vergleich STD -> DEV');
  
  // Dieser Vergleich würde beim Update von DEV nach LIVE stattfinden
  // (hier wird exakte Gleichheit gefordert, auch wenn substring 'cust' enthalten ist)
  Msg('main: Beginne Vergleich DEV -> LIVE');
  DatastructureComparison(vCteDataDEV, vCteDataLIVE, 'DEV', 'LIVE', '');
  Msg('main: Beendet: Vergleich DEV -> LIVE');
  
  
  // Nur zum Debuggen, sonst nicht sinnvoll
  /*
  Msg('main: Beginne Vergleich STD -> LIVE');
  DatastructureComparison(vCteDataSTD, vCteDataLIVE, 'STD', 'LIVE', 'cust');
  Msg('main: Beendet: Vergleich STD -> LIVE');
  */
  
  Lib_Json:CloseJSON(var vCteDataSTD);
  Lib_Json:CloseJSON(var vCteDataDEV);
  Lib_Json:CloseJSON(var vCteDataLIVE);
  
  
  Msg('main: Benutzungsbeispiele wurden ausgeführt.');
  
end


//========================================================================
//========================================================================
//========================================================================