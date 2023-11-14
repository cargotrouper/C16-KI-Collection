@A+
/*
===== Business-Control =================================================

Prozedur: Lib_Error

OHNE E_R_G

Info:
Welchen Zweck(en) dient die Prozedur? High-level Übersicht.

Historie:
21.06.2004  AI  Erstellung der Prozedur
28.08.2017  ST  sub OutputToText(...) hinzugefügt
30.05.2018  AJ  Warnings
02.01.2018  ST  sub ListCopy(..) hinzugefügt
01.07.2019  ST  sub OutputToJobserverErrProt(...) hinzugefügt
02.12.2020  ST  Bugfix: ErrorOutput als Jobserver leitet jetzt ins Protokoll um
27.07.2021  AH  ERX
08.04.2022  DS  _ErrorOutputWithDisclaimerPre() und _ErrorOutputWithDisclaimerPost()
2022-07-06  AH  _ErxError
2022-12-21  DS  _showErrorTrace Fall des leeren ErrorStack hinzugefügt
2023-03-09  DS  neue Fehlerausgabe jetzt einfacher zu benutzen und näher an Bestehender
2023-03-10  DS  Doku aktualisiert
2023-03-16  DS  _Error_WrapperWithLog, _Warning_WrapperWithLog für globales Logging, entsprechender Test

Subprozeduren:
_toTrace
_Error
_Error_WrapperWithLog
_ErxError
_Warning
_Warning_WrapperWithLog
_Flush
_Output
_WarningOutput
OutputToText
OutputToJobserverErrProt
OutputToFile
ListCopy
_ErrorOutputWithDisclaimerPre
_ErrorOutputWithDisclaimerPost
_complain
_showErrorTrace
test_ErrorAndWarning

MAIN: Benutzungsbeispiele zum Testen

Tipp: CTRL + SHIFT + G ermöglicht es, per Dropdown Menu zu allen
      subs in einer Prozedur zu springen
========================================================================
*/
@I:Def_global

declare OutputToJobserverErrProt(aAktion : alpha);



/*
========================================================================
2023-03-09 DS                                               intern

Schreibt Fehlermeldungen als augmentierte, strukturierte Einzeiler in den
ErrorTrace.
Funktionsweise ähnlich _Error und _ErxError.
========================================================================
*/
sub _toTrace
(
  // für Doku aller Argumente dieser Funktion siehe Lib_Error:_complain()
  procfunc    : alpha(256);
  line        : int;
  Erx         : int;
  Erm         : alpha(4096);
  Lvl         : int;
)
local begin
  vItem       : handle;
end
begin

  Lib_Logging:InitLogging();  // sicherstellen, dass global ErrTrace existiert

  if (ErrTrace=0) then
    ErrTrace # CteOpen(_CteList);

  vItem # CteOpen(_CteItem);

  vItem->spCustom # Lib_Logging:_createLogMessage(procfunc, line, Erx, Erm, Lvl);

  ErrTrace->CteInsert(vItem);
end



//========================================================================
//
//
//========================================================================
sub _Error(aProc : alpha(4000); aCode : int; aPara : alpha(4000))
local begin
  vItem : int;
end;
begin
  if (ErrList=0) then
    ErrList # CteOpen(_CteList);

  vItem # CteOpen(_CteItem);

  vItem->spID     # aCode;
  vItem->spName   # aProc;
  vItem->spCustom # aPara;

  ErrList->CteInsert(vItem);
end;



/*
========================================================================
2023-03-16  DS                                               intern

übernimmt dieselben Aufgaben wie _Error, und schreibt zusätzlich
ins Log. Dabei werden zusätzliche Metadaten verwendet, die vom
aufrufenden Makro Def_Global_Sys:Error übergeben werden.

Der Code ist analog zu _Warning_WrapperWithLog
========================================================================
*/
sub _Error_WrapperWithLog(
  // Argumente die zu _Error gehören
  aProc : alpha(4000);
  aCode : int;
  aPara : alpha(4000);
  // Argumente die zu Lib_Logging:_toLog gehören
  procfunc    : alpha(256);
  line        : int;
  // Erx, Erm, Lvl werden anderweitig gefüllt, siehe Code
)
local begin
end;
begin

  // Als erstes die Funktionalität der regulären _Error Funktion durch
  // Aufruf dieser nachbilden...
  _Error(aProc, aCode, aPara);
  
  // ...dann Logging aufrufen
  Lib_Logging:_toLog(
    procfunc,
    line,
    cErxNA, // Erx ist nicht zwangsläufig verfügbar an allen Aufrufstellen von Error, daher kenntlich machen dass es nicht verfügbar ist. aCode ist kein Erx!
    aPara,  // verwende die an _Error übergebene Nachricht als Fehlernachricht-Argument Erm
    cLogErr // Loglevel für Error
  );

end;


//========================================================================
//
//
//========================================================================
sub _ErxError(
  aErx  : int;
  aProc : alpha(4000);
  aCode : int;
  aPara : alpha(4000))
local begin
  vItem : int;
end;
begin
  if (ErrList=0) then
    ErrList # CteOpen(_CteList);

  vItem # CteOpen(_CteItem);
  vItem->spID     # aCode;
  vItem->spName   # aProc;
  vItem->spCustom # aPara;
  ErrList->CteInsert(vItem);

  if (aErx=_rDeadLock) then begin
    vItem # CteOpen(_CteItem);
    vItem->spID     # 1010;
    vItem->spName   # aProc;
    vItem->spCustom # aPara;
    ErrList->CteInsert(vItem);
  end;

end;


//========================================================================
//========================================================================
sub _Warning(aCode : int; aPara : alpha(400))
local begin
  vItem : int;
end;
begin
  if (ErrList=0) then
    ErrList # CteOpen(_CteList);

  vItem # CteOpen(_CteItem);

  vItem->spID     # aCode;
  vItem->spName   # '';
  vItem->spCustom # aPara;

  ErrList->CteInsert(vItem);
end;



/*
========================================================================
2023-03-16  DS                                               intern

übernimmt dieselben Aufgaben wie _Warning, und schreibt zusätzlich
ins Log. Dabei werden zusätzliche Metadaten verwendet, die vom
aufrufenden Makro Def_Global_Sys:Warning übergeben werden.

Der Code ist analog zu _Error_WrapperWithLog
========================================================================
*/
sub _Warning_WrapperWithLog(
  // Argumente die zu _Warning gehören
  aCode : int;
  aPara : alpha(400);
  // Argumente die zu Lib_Logging:_toLog gehören
  procfunc    : alpha(256);
  line        : int;
  // Erx, Erm, Lvl werden anderweitig gefüllt, siehe Code
)
local begin
end;
begin

  // Als erstes die Funktionalität der regulären _Warning Funktion durch
  // Aufruf dieser nachbilden...
  _Warning(aCode, aPara);
  
  // ...dann Logging aufrufen
  Lib_Logging:_toLog(
    procfunc,
    line,
    cErxNA,   // Erx ist nicht zwangsläufig verfügbar an allen Aufrufstellen von Error, daher kenntlich machen dass es nicht verfügbar ist. aCode ist kein Erx!
    aPara,    // verwende die an _Error übergebene Nachricht als Fehlernachricht-Argument Erm
    cLogWarn  // Loglevel für Warning
  );

end;



//========================================================================
//
//
//========================================================================
sub _Flush()
begin
  if (ErrList<>0) then
    ErrList->CteClear(y);
  ErrList->CteClose();
  ErrList # 0;
  
  
  Lib_Logging:InitLogging();  // sicherstellen, dass global ErrTrace existiert
  if (ErrTrace<>0) then
    ErrTrace->CteClear(y);
  ErrTrace->CteClose();
  ErrTrace # 0;
end;


//========================================================================
//
//  Nacheinander als Popup
//========================================================================
sub _Output();
local begin
  vItem : int;
end;
begin
  if (ErrList=0) then RETURN;

  if (gUserGroup = 'JOB-SERVER') then begin
    OutputToJobserverErrProt('');
    RETURN;
  end;

  FOR vItem # ErrList->CteRead(_CteFirst)
  LOOP vItem # ErrList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin
    if (vITem->spName<>'') then   // KEINE WARNINGS
      Lib_Messages:Messages_Msg(vItem->spID, vItem->spCustom, _WinIcoError, _WinDialogOk, 1, vItem->spName);
  END;

  _Flush();
end;


//========================================================================
//  _WarningOutput
//    in ein RTF
//========================================================================
sub _WarningOutput() : logic
local begin
  vItem : int;
  vTxt  : int;
  vRTF  : int;
  vSym  : int;
  vBut  : int;
end;
begin
  if (ErrList=0) then RETURN false;

  vTxt # TextOpen(16);
 
  FOR vItem # ErrList->CteRead(_CteFirst)
  LOOP vItem # ErrList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin
    TextAddLine(vTxt, Lib_Messages:ParseMsg(vItem->spID, vItem->spCustom, var vSym, var vBut));
  END;

  _Flush();
  
  vRtf # TextOpen(16);
  Lib_Texte:Txt2Rtf(vTxt, vRTF, 'Calibre', 12, 0, (TextInfo(vRTF,_textLines)>0));
  Dlg_Standard:TooltipRTF(vRTF,'Info');
  TextClose(vRTF);
  TextClose(vTxt);

  RETURN true;
end;


//========================================================================
//  sub OutputToText(var aTextRet : alpha);
//  Gibt alle Fehler in die übergebenen Alphareferenz zurück
//========================================================================
sub OutputToText(var aTextRet : alpha);
local begin
  vItem : int;
end;
begin
  if (ErrList=0) then RETURN;

  FOR vItem # ErrList->CteRead(_CteFirst)
  LOOP vItem # ErrList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin
    if (aTextRet <> '') then
      aTextRet # aTextRet + StrChar(10);

    aTextRet # aTextRet + vItem->spCustom;
  END;

  _Flush();
end;



//========================================================================
//  sub OutputToJobserverErrProt(aAktion : alpha);
//  Gibt alle Fehler in das Jobserverprotokoll aus
//========================================================================
sub OutputToJobserverErrProt(aAktion : alpha);
local begin
  vItem : int;
  vMsg  : alpha(4000);
  vLine : alpha(250);
  vCnt  : int;

  vFile : handle;
end;
begin
  if (ErrList=0) then RETURN;

  FOR vItem # ErrList->CteRead(_CteFirst)
  LOOP vItem # ErrList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) DO BEGIN
    Job_STD:JobError(aAktion, StrCut(vItem->spCustom,1,64));
    Winsleep(100);
  END;

  Lib_Error:_Flush();
end;



//========================================================================
//  sub OutputToFile(aFilename : alpha(4000));
//    Gibt alle Fehler Meldungen in die übergebenen DAtei aus
//========================================================================
sub OutputToFile(aFilename : alpha(4000));
local begin
  vItem : int;
  vMsg  : alpha(8192);
  vLine : alpha(8192);
  vCnt  : int;

  vFile : handle;
end;
begin
  if (ErrList=0) then RETURN;

  vFile # FsiOpen(aFilename, _FsiStdWrite);

  if (vFIle > 0) then begin

    FOR vItem # ErrList->CteRead(_CteFirst)
    LOOP vItem # ErrList->CteRead(_CteNext,vItem)
    WHILE (vItem > 0) DO BEGIN
      vLine # vItem->spCustom + StrChar(13) + StrChar(10);
      vFile->FsiWrite(vLine);
      inc(vCnt);
    END;

    Lib_Error:_Flush();
    vFile->FsiClose();
  end;
end;

//========================================================================
//  sub ListCopy(var aTextRet : alpha);
//  Kopiert den aktuellen Fehlerstack
//========================================================================
sub ListCopy(var aErrListHdl : int; opt aToErr : logic);
local begin
  vItem : int;
  vItemNew : int;
end;
begin

  if (aToErr) then begin
  
    if (aErrListHdl <> 0) then begin
      FOR   vItem # aErrListHdl->CteRead(_CteFirst)
      LOOP  vItem # aErrListHdl->CteRead(_CteNext,vItem)
      WHILE (vItem > 0) do begin
        _Error(vItem->spName,vItem->spID,vItem->spCustom);
      END;
    end;
    
  end else begin
    if (ErrList <> 0) then begin
      aErrListHdl # CteOpen(_CteList);
      FOR vItem # ErrList->CteRead(_CteFirst)
      LOOP vItem # ErrList->CteRead(_CteNext,vItem)
      WHILE (vItem > 0) do begin
        
        // Deep Copy
        vItemNew # CteOpen(_CteItem);
        vItemNew->spID     # vItem->spId;
        vItemNew->spName   # vItem->spName;
        vItemNew->spCustom # vItem->spCustom;
        aErrListHdl->CteInsert(vItemNew);
      END;
    end;
  end;
  
end;



//========================================================================
//  2022-03-23  DS
//
//  Die Funktion hinter Makro Def_Global_Sys:ErrorOutputWithDisclaimerPre().
//
//  brief: vorherige ErrList ausgeben und flushen.
//
//  detailed:
//  Bevor eine neue Operation Fehler-Ausgaben per Error(...) in die ErrList schreibt,
//  sollte eigentlich die vorherige Operation die ErrList geflusht haben.
//  Wenn das vergessen wurde, würden die Inhalte beider Operationen
//  aneinandergehängt und man verliert die Übersicht.
//  Andererseits, wenn man zu Beginn der nächsten Operation einfach so flushen
//  würde, würden die Fehler die bereits in der Liste stehen niemals ausgegeben,
//  was ebenfalls nicht gewünscht sein kann.
//
//  Das Makro Def_Global_Sys:ErrorOutputWithDisclaimerPre() ist ein sicherer
//  flush mit Output der Error Liste, bei dem für den Anwender transparent
//  gemacht wird, dass die Operation der bereits in der Liste befindlichen
//  Meldungen eine andere ist, als die aktuell auszuführende, die im
//  Argument aDescriptionOfNextOperation beschrieben wird.
//
//  Siehe auch den ausgegebenen Text.
//
//  Um nach der Operation die Fehlermeldungen (if any) der aktuellen Operation
//  auszugeben, bitte das Makro Def_Global_Sys:ErrorOutputWithDisclaimerPost()
//  benutzen.
//
//  Diese beiden Funktionen sind quasi die öffnende und schließende Klammer
//  um Operationen die ErrList verwenden.
//
//========================================================================
sub _ErrorOutputWithDisclaimerPre
(
  aDescriptionOfNextOperation : alpha(4096);  // kurze Beschreibung der Operation die NACH dem Flush der Errorlist stattfinden soll, also wegen derer wir flushen.
  // Beispiel: aDescriptionOfNextOperation = 'Einlesen von .CSV Datei' oder 'Vergleich von Vorlage mit Betriebsauftrag'
);
local begin
  vErrorsAsString : alpha(8192);
end
begin
  if ErrList <> 0 then
  begin
    OutputToText(var vErrorsAsString);
    Lib_Messages:Messages_Msg(
      99,
      'Vor der Operation "' + aDescriptionOfNextOperation + '" wird die aktuell nicht-leere Fehlerliste vorheriger Operationen ausgegeben und geleert.' + cCrlf + 'Hier die Fehler aus vorherigen Operationen:' + cCrlf2 + vErrorsAsString,
      _WinIcoError,
      _WinDialogOk,
      1
    );
  end
end;


//========================================================================
//  2022-03-23  DS
//
//  Die schließende Klammer zu _ErrorOutputWithDisclaimerPre(), siehe
//  Dokumentation dort.
//
//  brief: eigene ErrList ausgeben und flushen.
//
//  Sollte zum Schließen mit demselbem Wert in aDescriptionOfNextOperation
//  aufgerufen werden wie beim Öffnen.
//========================================================================
sub _ErrorOutputWithDisclaimerPost
(
  aDescriptionOfNextOperation : alpha(4096);  // kurze Beschreibung der Operation die NACH dem Flush der Errorlist stattfinden soll, also wegen derer wir flushen.
  // Beispiel: aDescriptionOfNextOperation = 'Einlesen von .CSV Datei' oder 'Vergleich von Vorlage mit Betriebsauftrag'
);
local begin
  vErrorsAsString : alpha(8192);
end
begin
  if ErrList <> 0 then
  begin
    OutputToText(var vErrorsAsString);
    Lib_Messages:Messages_Msg(
      99,
      'Es wird nun die Fehlerliste der Operation "' + aDescriptionOfNextOperation + '" ausgegeben und danach geleert.' + cCrlf + 'Hier die Fehler aus dieser Operation:' + cCrlf2 + vErrorsAsString,
      _WinIcoError,
      _WinDialogOk,
      1
    );
  end
end;



/*
========================================================================
2022-11-02 DS                                               intern
2023-03-09 DS stark vereinfacht

Wird vom Makro Def_Global:complain gerufen.

Das Fehlerausgabe-Makro complain() und insb. sein Argument Verbosity
kontrollieren die Fehlerausgabe auf allen Ebenen. Diese Ebenen sind:
* Logging in Datei
* ErrTrace für Entwicklung (siehe _showErrorTrace)
* Bildschirmausgabe nach Ende der auslösenden Funktion (ErrList in Def_Global)
* Bildschirmausgabe sofort wenn ein Fehler auftritt.

Details:

_complain() bzw. das in Def_Global definierte Makro complain() das die
Argumente bis zur Verbosity automatisch aus dem Kontext befüllt
ist die neue one-fits-all Funktion für Fehlerausgaben unterschiedlichster
Art. Die genaue Art der Ausgabe wird über das Argument Verbosity
konfiguriert, siehe Doku dieses Arguments.

complain() ist austauschbar mit Error(99, ...) verwendbar, solange die
in _complain() geforderten Kontextargumente vorhanden sind und sinnvoll
gefüllt werden können.
Eine Migration von Error(99, ...) auf complain() ist damit straight-forward.

complain() nutzt u.A. denselben Mechanismus wie Error(99, ...)
(gemeint ist ErrList in Def_Global) und ist deshalb mit den umklammernden
Makros
ErrorOutputWithDisclaimerPre(aDescriptionOfNextOperation)
...YOUR FUNCTION CALL...
ErrorOutputWithDisclaimerPost(aDescriptionOfNextOperation)
aus Def_Global ebenso kompatibel wie es Error(99, ...) ist.
Diese Makros sollen unabhängig vom Wert des Arguments Verbosity stets
genutzt werden! Dies geschieht, indem man die auslösende Funktion mit
ihnen "umklammert". Zwischen diesen "Klammern" kann man dann bis in beliebige
Schachtelungstiefe complain() einsetzen.
Siehe !Template2022:MAIN für Benutzungsbeispiele.

Der ErrorTrace (gemeint ist ErrTrace in Def_Global) nutzt einen identisch
zur (ebenfalls in Def_Global definierten) ErrList gebauten Mechanismus,
der ebenfalls mittels der o.g. ...Pre und ...Post Makros erstellt/geleert wird.
Es ist also sichergestellt, dass ErrList und ErrTrace im produktiven
Betrieb weggeräumt werden, insofern ErrorOutputWithDisclaimerPost verwendet wird.

Der Programmierer nutzt also wie oben gesagt immer die ...Pre und ...Post
Funktionen und kann entweder Error(99,...) (alte Welt) oder complain verwenden
(neue Welt). Ersteres soll nur dazu dienen, Kompatibilität zu bestehendem
Code herzustellen. Für neuen Code soll immer complain() genutzt werden!

Vor ErrorOutputWithDisclaimerPost() kann der Entwickler optional
showErrorTrace rufen. Dies lässt alle Error-Daten unverändert und gibt
lediglich den aktuellen Stand des ErrorTrace als Tabelle aus.
Siehe !Template2022:MAIN für Benutzungsbeispiele.

Die aktuelle Umsetzung ist eine Weiterentwicklung der Ideen aus dem
folgenden Dokument:
http://vm_tfs:8080/tfs/DefaultCollection/Dokumente/_git/BCS?path=%2FCodinghandbuch%2FC16%2Ffehlerbehandlung.md&version=GBmaster&_a=preview
========================================================================
*/
sub _complain
(
  procfunc    : alpha(256);   // wird vom Makro mit __PROCFUNC__ gefüllt
  line        : int;          // wird vom Makro mit __LINE__ gefüllt
  Erx         : int;          // Makro übergibt Erx Variable des aufrufenden Kontexts
  // vom User übergebene Argumente:
  Verbosity   : int;          // BITTE DIE KONSTANTEN cVerbSilent, cVerbPost, cVerbInstant AUS Def_Global VERWENDEN!
                              // <0: (nicht empfohlen) nirgends ausgeben
                              //  cVerbSilent (==0): unsichtbar für SC enduser in error log und error trace schreiben (ausschließlich)
                              //  cVerbPost (==1): wie cVerbSilent und zusätzlich auf Bildschirm schreiben, ERST bei ErrorOutputWithDisclaimerPost()
                              //  cVerbInstant (==2): wie cVerbSilent und zusätzlich SOFORT auf Bildschirm schreiben, NICHT ERST bei ErrorOutputWithDisclaimerPost()
                              // >2: wird behandelt wie cVerbInstant
  Erm         : alpha(4096);  // Textnachricht die sich an ENDBENUTZER richtet, vom Entwickler frei befüllbar
  Lvl         : int;          // Log Level in Analogie zu den Symbolen von C16 (_WinIco*), d.h. es werden die folgenden
                              // Konstanten durch Def_Global zur Verfügung gestellt
                              // cLogInfo
                              // cLogWarn
                              // cLogErr
)
begin

  // Verbosity Wertebereich sicherstellen:
  if Verbosity < cVerbSilent then
  begin
    return;
  end
  if Verbosity > cVerbInstant then
  begin
    Verbosity # cVerbInstant;
  end

  
  // Log-Ausgabe (also in Datei):
  Lib_Logging:_toLog(procfunc, line, Erx, Erm, Lvl);
  
  // Trace-Ausgabe (also in CteList für showErrorTrace)
  _toTrace(procfunc, line, Erx, Erm, Lvl);

  
  if Verbosity = cVerbPost then
  begin
    // Bildschirm-Ausgabe erst später bei ErrorOutputWithDisclaimerPost:
    // Dazu dient die _Error Funktion:
    // WICHTIG: Weder das Makro Error() noch den Wrapper verwenden, damit Log-Nachrichten nicht mehrmals im Log landen.
    //          Denn _toLog wird bereits oben mit mehr Nutzinformation aufgerufen als für Makro und Wrapper zur Verfügung stehen.
    _Error(here, 99, Erm)
  end
  
  if Verbosity = cVerbInstant then
  begin
    // sofortige Bildschirm-Ausgabe:
    // Dazu dienen eigentlich die Msg* Makros aus Def_Global, aber es muss hier deren ursprüngliche Originalfunktion
    // verwendet werden, da die neuen Makros (mit Logging) sonst ein zweites Mal ins Log schreiben würden.
    // Deswegen werden hier nicht die Makros verwendet, sondern es wird die eigentliche Funktion mit
    // entsprechenden Parametern aufgerufen, die an die Makros angelehnt sind. Denn die eigentliche (nicht-Wrapper)
    // Funktion schreibt nicht ins Log
    
    if Lvl = cLogInfo then
    begin
      Lib_Messages:Messages_Msg(99, Erm, _WinIcoInformation, _WinDialogOk, 1);
    end
    else if Lvl = cLogWarn then
    begin
      Lib_Messages:Messages_Msg(99, Erm, _WinIcoWarning, _WinDialogOk, 1);
    end
    else
    begin
      // alle Werte außer cLogInfo und cLogWarn werden als Error behandelt (inkl. cLogErr)
      Lib_Messages:Messages_Msg(99, Erm, _WinIcoError, _WinDialogOk, 1);
    end
    
  end
  
end



/*
========================================================================
2022-11-03 DS                                               intern
2022-11-25 AH erweitert um User-Friendly-Ausgabe
2022-12-21 DS Fall des leeren ErrorStack hinzugefügt
2023-03-09 DS stark vereinfacht

Wird vom Makro Def_Global:showErrorTrace gerufen

Ausgabefunktion für den Error Trace in der globalen Variable ErrTrace
die mittels von _complain befüllt wird.

Diese Funktion richtet sich NUR AN ENTWICKLER!
Sie zeigt das was der Endnutzer sieht PLUS diverse nur für
Entwickler relevante Information.
Am einfachsten kann man diese lesen, indem man auf Entwickler-System
die .csv Endung mit LibreOffice Calc verknüpft und beim Import den
entsprechenden Separator wählt (siehe in Lib_Logging:getSeparator())
========================================================================
*/
sub _showErrorTrace()
local begin
  Erx           : int;
  vFilename     : alpha(256);
  vFileHdl      : handle;
  vCteItem      : handle;
  vCteItemText  : alpha(8192); // FsiWrite wirft compiler Fehler, wenn man vCteItem->spName direkt übergibt... daher dieser Umweg.
  vRtf, vTxt    : int;
  vMsg          : alpha(8192);
end
begin

  if !Lib_Auxiliaries:isDEV() and !DEBUG_showErrorTrace_beim_Kunden then
  begin
    // beim Kunden (also nicht DEV) soll _showErrorTrace nichts anzeigen,
    // es sei denn dies ist per DEBUG_showErrorTrace_beim_Kunden vorübergehend erlaubt,
    // zum Beispiel um beim Kunden mit detailliertem ErrorTrace debuggen zu können.
    return;
  end
  
  Lib_Logging:InitLogging();  // sicherstellen, dass global ErrTrace existiert

  if ErrTrace <= 0 then
  begin
    vMsg #
        __PROCFUNC__ + ': ErrTrace==' + aint(ErrTrace) + ' also <= 0' + cCrlf2 +
        'Error Trace ist uninitialisiert/leer.'
    DebugM(vMsg);
    return;
  end


  // Ausgabedatei
  vFilename # 'C:\Debug\SC16_ErrorTrace_' + Lib_Strings:TimestampFullYearFilename() + '.csv';
  
  // ggf. löschen
  Erx # FsiDelete(vFilename);
  if (Erx <> _ErrOK) and (erx<>_ErrFsiNoFile) then
  begin
    DebugM(__PROCFUNC__ + ': fehlgeschlagen, da "' + vFilename + '" nicht gelöscht werden konnte.' + cCrlf2 + 'Bitte löschen Sie die Datei manuell, ggf. nach Neustart von C16.');
    return;
  end

  // öffnen:
  vFileHdl # FsiOpen(vFilename, _FsiAcsRW | _FsiDenyRW | _FsiCreate);
  if (vFileHdl <= 0) then
  begin
    DebugM(__PROCFUNC__ + ': fehlgeschlagen, da Datei nicht schreibbar (existiert Verzeichnis und liegt Schreibrecht vor?): ' + vFilename);
    return;
  end

  // Iteriere über alle Einträge in ErrTrace und schreibe sie in die Tabelle
  // (neuere Einträge stehen weiter unten in der Tabelle)
  FOR   vCteItem # ErrTrace->CteRead(_CteFirst);
  LOOP  vCteItem # ErrTrace->CteRead(_CteNext, vCteItem);
  WHILE vCteItem <> 0 DO
  BEGIN
    vCteItemText # vCteItem->spCustom;
    vCteItemText # vCteItemText + cCrlf;
    vCteItemText # Lib_Strings:Strings_C162UTF8(vCteItemText);
    //DebugM(vCteItemText);
    vFileHdl->FsiWrite(vCteItemText);
  END
  
  // wegräumen der ErrTrace Variable geschieht in _Flush() das im Rahmen
  // von ErrorOutputWithDisclaimerPost() aufgerufen wird.
  // hier darf hingegen nichts weggeräumt werden, damit man auch "zwischendurch",
  // also vor ErrorOutputWithDisclaimerPost(), den ErrTrace ausgeben kann.

  vFileHdl->FsiClose();
  
  // SysExecute('notepad', '"' + vFilename + '"', _ExecWait);
  SysExecute('*"' + vFilename + '"','', _ExecWait);
        
  return;
  
end



/*
========================================================================
2023-03-16 DS                                               intern

Test des Def_Global_Sys:Error Makros das auf _Error_WrapperWithLog basiert.

========================================================================
*/
sub test_ErrorAndWarning
()
local begin
  vDescription : alpha(1024);
end
begin

  vDescription # 'TEST: Error()-Makro'
  ErrorOutputWithDisclaimerPre(vDescription);
  
  Error(99, 'Ein durch Error(99, ...) ins Log geschriebener Error');
  Error(99, 'Ein zweiter durch Error(99, ...) ins Log geschriebener Error');
  Warning(99, 'Eine durch Warning(99, ...) ins Log geschriebene Warning');
  Error(99, 'Ein dritter durch Error(99, ...) ins Log geschriebener Error');
  Warning(99, 'Eine zweite durch Warning(99, ...) ins Log geschriebene Warning');
  Warning(000005, 'Eine durch Warning(000005, ...) ins Log geschriebene Warning');
  Error(000006, 'Ein durch Error(000006, ...) ins Log geschriebener Error');
  
  ErrorOutputWithDisclaimerPost(vDescription);

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
  
  
  test_ErrorAndWarning();
 

  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;
  
end


//========================================================================
