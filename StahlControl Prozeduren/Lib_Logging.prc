@A+
/*
===== Business-Control =================================================

Prozedur:   Lib_Logging

OHNE E_R_G

Info:
Diese Prozedur stellt einen global verfügbaren, persistenten Logging
Mechanismus zur Verfügung, der pro SC Session ein tabellarisches,
also strukturiertes log schreibt, das zur Analyse von Problemen
genutzt werden kann.

Historie:
2023-03-14  DS  Erstellung der Prozedur

Subprozeduren:
getSeparator
_loggifyString
InitLogging
_createLogMessage
_toLog
test_Logging

MAIN: Benutzungsbeispiele zum Testen

Tipp: CTRL + SHIFT + G ermöglicht es, per Dropdown Menu zu allen
      subs in einer Prozedur zu springen
========================================================================
*/
@I:Def_Global



/*
========================================================================
2023-03-21  DS                                               intern

Liefert den Separator der die einzelnen Spalten innerhalb einer Zeile
des Logs voneinander trennt
========================================================================
*/
sub getSeparator
(
) : alpha
begin
  return '|';
end


/*
========================================================================
2023-03-21  DS                                               intern

Liefert den Separator der die einzelnen Spalten innerhalb einer Zeile
des Logs voneinander trennt
========================================================================
*/
sub _loggifyString
(
  aAlpha : alpha(8192)
) : alpha
begin
  aAlpha # Lib_Strings:Strings_ReplaceAll(aAlpha, getSeparator(), '~');  // Separator durch unkritisches Zeichen ersetzen
  aAlpha # Lib_Strings:Strings_ReplaceAll(aAlpha, cCrlf2, ' '); // keine Zeilenumbrüche,...
  aAlpha # Lib_Strings:Strings_ReplaceAll(aAlpha, cCrlf, ' ') ; // ...auch keine einfachen...
  aAlpha # Lib_Strings:Strings_ReplaceAll(aAlpha, StrChar(13), ' ') ; // ...auch kein Wagenrücklauf (Carriage Return)...
  aAlpha # Lib_Strings:Strings_ReplaceAll(aAlpha, StrChar(10), ' ') ; // ...auch kein Zeilenvorschub (Line Feed)
  return aAlpha;
end


      


/*
========================================================================
2023-03-14  DS                                               intern

Initialisierung der Logging-Variablen.
* DARF beliebig oft gerufen werden, und
* MUSS mindestens zu Beginn der SC Session gerufen werden.

Letzteres geschieht in App_Main:EvtCreated()
========================================================================
*/
sub InitLogging
(
)
local begin
  Erx         : int;
  vReturn     : alpha(512);
end
begin

  if VarInfo(VarLogging) = 0 then
  begin
  
    VarAllocate(VarLogging)
    
    // Logging kann hier global deaktiviert werden.
    // Später konstant true setzen (nach ausgiebigem Testen)
    // gLoggingEnabled # Lib_Auxiliaries:isDEV();
    gLoggingEnabled # true;
    
    if Lib_FileIO:GetAppDataLocalSc() = '' then
    begin
      gLoggingEnabled # false;
      gLoggingFilename # '';
    end
    else
    begin
      // Log-Dateien landen hier (jeder DEV sollte sich eine Verknüpfung
      // zu diesem Ordner anlegen, damit er bequem erreichbar ist)
      gLoggingFilename # Lib_FileIO:GetAppDataLocalSc() + '\Logs\' + DbaName(_dbaAreaAlias);
    
      // Existenz des Verzeichnis sicherstellen
      Lib_FileIO:CreateFullPath(gLoggingFilename);
      
      // Name des Log files für diese SC Session festlegen:
      gLoggingFilename # gLoggingFilename + '\log_' + Lib_Strings:TimestampFullYearFilename() + '_userid_' + UserInfo(_UserCurrent) + '.csv';
    end
    
  end
  

  //DebugM(gLoggingFilename);
  
  return;

end


/*
========================================================================
2023-03-09 DS                                               intern

Erstellt zur übergebenen ErrorMessage Erm, die sich an die Nutzer richtet
eine detailliertere, an Entwickler gerichtete Fassung, die so z.B. in
das Log oder den ErrorTrace geschrieben werden kann.

Der zurückgegebene Text liegt auf einer einzigen Zeile die auch als
Zeile einer .csv Tabelle genutzt werden kann, wenn z.B. in LibreOffice
der entsprechende Separator (siehe Lib_Logging:getSeparator im Code)
eingestellt wird.
========================================================================
*/
sub _createLogMessage
(
  // für Doku aller Argumente dieser Funktion siehe Lib_Error:_complain()
  procfunc    : alpha(256);
  line        : int;
  Erx         : int;
  Erm         : alpha(4096);
  Lvl         : int;
) : alpha;
local begin
  vErmDev     : alpha(8192);  // Gesamt-Fehlermeldung, Zielgruppe: Entwickler, wird Erm enthalten
  vLvlAlpha   : alpha(32);
  vErxAlpha   : alpha(1024);
  vSep        : alpha(1);
  vSepPadded  : alpha(3);
end
begin

  // Trenner für unterschiedliche Teilbereiche der Entwickler-Fehlermeldung
  // Ziel: resultierende Zeile soll auch als Zeile einer .csv Tabelle mit entsprechendem separator funktionieren
  vSep # getSeparator();
  vSepPadded # ' ' + vSep + ' ';
  
  
  // Text-Repräsentation des Log Levels:
  case Lvl of
    cLogInfo : vLvlAlpha # 'Information';
    cLogWarn : vLvlAlpha # 'Warning';
    cLogErr  : vLvlAlpha # 'Error';
  otherwise
    vLvlAlpha # 'UNKNOWN Lvl=' + aint(Lvl);
  end
  
  
  // Versuche eine Text-Repräsentation des Fehlercodes aus C16 zu erhalten
  // (dies funktioniert nur bei C16-builtin Fehlercodes, und auch da nicht bei allen)
  if Erx > cErxSTD then
  begin
    vErxAlpha # ErrMapText(Erx, 'EN', _ErrMapC16);
  end
  
  // zusammenbauen
  vErmDev #
    Lib_Strings:TimestampFullYear() + vSepPadded +
    vLvlAlpha + vSepPadded +
    procfunc + vSepPadded +
    'line ' + aint(line) + vSepPadded +
    'Erx ' + aint(Erx) + vSepPadded +
    'Text C16: ' + vErxAlpha + vSepPadded +
    'Text Custom: ' + _loggifyString(Erm);
  ;

  //DebugM(vErmDev);
  
  return vErmDev;
  
end



/*
========================================================================
2023-03-14 DS                                               intern

Schreibt Fehlermeldungen als augmentierte, strukturierte Einzeiler in
das Log.
========================================================================
*/
sub _toLog
(
  // für Doku aller Argumente dieser Funktion siehe Lib_Error:_complain()
  procfunc    : alpha(256);
  line        : int;
  Erx         : int;
  Erm         : alpha(4096);
  Lvl         : int;
)
local begin
  vFileHdl    : handle;
  vErmDev     : alpha(8192);
end
begin

  InitLogging();  // sicherstellen, dass global gLoggingEnabled und gLoggingFilename existieren

  if !gLoggingEnabled then
  begin
    return;
  end
  
  // öffnen:
  vFileHdl # FsiOpen(gLoggingFilename, _FsiAcsRW | _FsiDenyRW | _FsiCreate | _FsiAppend);
  if (vFileHdl <= 0) then
  begin
    // stiller Fehlschlag, da Log nicht den Programmablauf behindern soll
    return;
  end
  
  
  // Log-Nachricht formatieren/erstellen:
  vErmDev # _createLogMessage(procfunc, line, Erx, Erm, Lvl);
  //DebugM(vErmDev);
  
  // Nachricht ans Ende anhängen:
  vFileHdl->FsiWrite(Lib_Strings:Strings_C162UTF8(vErmDev) + cCrlf);
  
  // Datei wieder schließen, so dass sie auch während laufendem SC immer aktuell und lesbar ist,
  // und ggf. nach einem Absturz noch den letzten gültigen Stand hat:
  vFileHdl->FsiClose();

end



/*
========================================================================
2023-03-14 DS                                               intern

Test der Logging Funktion
========================================================================
*/
sub test_Logging
()
begin
  _toLog(__PROCFUNC__, __LINE__, cErxNA, 'eine Information im Log', cLogInfo);
  _toLog(__PROCFUNC__, __LINE__, cErxNA, 'eine Warning im Log', cLogWarn);
  _toLog(__PROCFUNC__, __LINE__, cErxNA, 'ein Error im Log', cLogErr);
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
  
 
  test_Logging();
 

  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;
  
end


//========================================================================
