@A+
/*
===== Business-Control =================================================

Prozedur:   LibKeyVal

OHNE E_R_G

Info:
Stellt einen persistenten Key Value Store auf Basis von Tabelle 935 zur
Verfügung. Es geht hier also darum, die SC-session-übergreifende
Persistenz von Daten (die durch Tabelle 935 realisiert ist) über
komfortable Mechanismen verfügbar zu machen.

Historie:
2023-06-07  DS  Erstellung der Prozedur

Subprozeduren:
existsKey
getKeyValue
setOrCreateKeyValue

MAIN: Benutzungsbeispiele zum Testen
========================================================================
*/
@I:Def_Global


/*
========================================================================
2023-06-07  DS                                               2436/407

Prüft ob ein gegebener Schlüssel existiert
========================================================================
*/
sub existsKey(
  aKey    : alpha(256);
) : logic
local begin
  Erx     : int;
end
begin

  // Timestamp der letzten Suche aus Dictionary-Tabelle 935 holen
  RecBufClear(935);
  Dic.Key # aKey;
  Erx # RecRead(935, 1, 0);
  
  if Erx <> _ErrOK then
  begin
    return false;
  end
  
  return true;
  
end



/*
========================================================================
2023-06-07  DS                                               2436/407

Holt den Wert eines gegebenen Schlüssels
========================================================================
*/
sub getKeyValue(
  // Pflicht-Argument:
  Verbosity   : int;
  // Eigene Argumente:
  aKey    : alpha(256);   // Name des zu holenden Schlüssels
  // für Konsistenz mit Methodenname und der Reihenfolge bei setOrCreateKeyValue kommt das Ausgabeargument hier ausnahmsweise später:
  var outValue : alpha;   // der Value wird hierin zurückgegeben, falls vorhanden (dann Erx == _ErrOK). ansonsten leer und Erx <> _ErrOK
) : int
local begin
  // Pflicht-locals
  Erx     : int;
  Erm     : alpha(4096);
end
begin

  // Timestamp der letzten Suche aus Dictionary-Tabelle 935 holen
  RecBufClear(935);
  Dic.Key # aKey;
  Erx # RecRead(935, 1, 0);
  
  if Erx <> _ErrOK then
  begin
    outValue # '';
    
    Erm # 'Fehler beim Holen des Werts zum Schlüssel "' + aKey + '" aus Tabelle 935.' + cCrlf +
      'Fehlercode Erx=' + aint(Erx);
    complain(Verbosity, Erm);
    return Erx;
  end
  
  outValue # Dic.Value;
  
end




/*
========================================================================
2023-06-07  DS                                               2436/407

Setzt den Wert eines gegebenen Schlüssels (wenn dieser Schlüssel
bereits existiert), bzw. legt diesen Schlüssel neu an (wenn dieser
Schlüssel noch nicht existiert)
========================================================================
*/
sub setOrCreateKeyValue(
  // Pflicht-Argument:
  Verbosity   : int;
  // Eigene Argumente:
  aKey        : alpha(256);   // Schlüssel zum zu setzenden Wert
  aValue      : alpha(256);   // der zu setzende Wert selbst
) : int
local begin
  // Pflicht-locals
  Erx     : int;
  Erm     : alpha(4096);
  // ab hier reguläre Variablen
  vCreate : logic;  // wird false falls der Schlüssel existiert, wird true falls er neu angelegt werden muss
end
begin

  // init Fehlermeldung Präfix
  Erm # 'Fehler beim Setzen des Werts zum Schlüssel "' + aKey + '" in Tabelle 935.' + cCrlf;

  // Timestamp der letzten Suche aus Dictionary-Tabelle 935 holen
  RecBufClear(935);
  Dic.Key # aKey;
  
  // sperrend lesen, denn es soll geschrieben werden
  Erx # RecRead(935, 1, _RecLock);
  
  if Erx = _rLocked then
  begin
    Erm # Erm +
      'Der entsprechende Datensatz ist aktuell GESPERRT.' + cCrlf +
      'Daher ABBRUCH.';
    complain(Verbosity, Erm);
    return Erx;
  end
  else if Erx = _ErrOK then
  begin
    // Datensatz mit diesem Schlüssel existiert bereits
    vCreate # false;
  end
  else if Erx = _rNoKey or Erx = _rLastRec or Erx = _rNoRec then
  begin
    // all diese Fehlercodes bedeuten laut Doku von RecRead dass der gesuchte Datensatz noch nicht existiert,
    // und also neu angelegt werden muss:
    vCreate # true;
    // Schlüssel setzen
    Dic.Key # aKey;
  end
  else
  begin
    Erm # Erm +
      'Der entsprechende Datensatz konnte nicht geladen werden. Fehlercode aus RecRead: ' + aint(Erx) + cCrlf +
      'Daher ABBRUCH.';
    complain(Verbosity, Erm);
    return Erx;
  end
  
  
  // wenn man hier im Code ankommt, kann geschrieben werden:
  TRANSON;
  Dic.Value # aValue;
  // Protokoll befüllen:
  Dic.Anlage.Datum # Today;
  Dic.Anlage.Zeit # Now;
  Dic.Anlage.User # gUsername;
  
  if vCreate then
  begin
    RekInsert(935, _RecLock);
  end
  else
  begin
    RekReplace(935, _RecLock);
  end
  // entsperren
  Erx # RecRead(935, 1, _RecUnlock);
  if Erx <> _ErrOK then
  begin
    TRANSOFF;
    Erm # Erm +
      'Fehler beim entsperrenden Lesen des Datensatzes. Fehlercode aus RecRead: ' + aint(Erx) + cCrlf +
      'Daher ABBRUCH.';
    complain(Verbosity, Erm);
    return Erx;
  end
  TRANSOFF;
  
  return _ErrOK;
  
end




/*
========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================
*/
MAIN()
local begin
  Erx     : int;
  vDescription : alpha(512);
  // hier ausnahmsweise generische Variablennamen die in Beispielen wiederverwendet werden
  vAlpha  : alpha;
  vBeta   : alpha;
  vInt    : int;
  vLogic  : logic;
  // buffer zum Übergeben von Datensätzen an Funktionen
  vBuf    : handle;
end;
begin

  // ggf. benötigte globals allokieren für Standalone-Ausführung (CTRL + T)...
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  VarAllocate(WindowBonus);
  // ...und setzen
  gUserName # 'ME';
  
  // Erforderlich damit Lib_SFX:* Funktionen bei standalone Ausführung (STRG+T) funktionieren (nicht nötig innerhalb von laufendem SC (STRG+R))
  Lib_SFX:InitAFX();
  
  // Logging initialisieren (wird bei normalem SC Betrieb durch App_Main:EvtCreated() gemacht)
  Lib_Logging:InitLogging();

  
  /*
  vAlpha # 'test';
  vLogic # existsKey(vAlpha);
  DebugM('existsKey("' + vAlpha + '") == ' + Lib_Auxiliaries:CnvAL(vLogic))
  */
  
  
  vDescription # 'Beispiel-Aufruf von Lib_KeyVal:setOrCreateKeyValue()'
  ErrorOutputWithDisclaimerPre(vDescription);
  vAlpha # 'testKey';
  vBeta # 'testValue';
  Erx # setOrCreateKeyValue(cVerbPost, vAlpha, vBeta);
  DebugM('Ausgabe von setOrCreateKeyValue(..., "' + vAlpha + '", "' + vBeta + '"): ' + cCrlf + 'Erx=' + aint(Erx));
  ErrorOutputWithDisclaimerPost(vDescription);
  
  
  
  vDescription # 'Beispiel-Aufruf von Lib_KeyVal:getKeyValue()'
  ErrorOutputWithDisclaimerPre(vDescription);
  vAlpha # 'testKey';
  Erx # getKeyValue(cVerbPost, vAlpha, var vBeta);
  DebugM('Ausgabe von getKeyValue(..., "' + vAlpha + '", ...): ' + cCrlf + 'Erx=' + aint(Erx) + cCrlf + 'Value="' + vBeta + '"');
  ErrorOutputWithDisclaimerPost(vDescription);
  
  

  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;
  
end


//========================================================================