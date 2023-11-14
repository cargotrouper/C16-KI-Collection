@A+
/*
===== Business-Control =================================================

Prozedur:   Lib_Auxiliaries
                    OHNE E_R_G
Info:
Lib_Auxiliaries ist ein Sammelbecken für allgemeine Hilfsfunktionen
die sich nicht genauer spezifischeren Zwecken zuordnen lassen.
Also Code der in vielen Zusammenhängen nützlich ist.

Historie:
2022-04-11  DS  Erstellung der Prozedur
2022-05-03  DS  CnvAL
2023-03-07  DS  isGuiAvailable und isHeadless
2023-03-10  DS  isDEV

Subprozeduren:
_assert
CnvAL
FieldValueAsString
FieldValueAsStringByName
countRowsMatchingQuery
printArrayAlpha
isGuiAvailable
isHeadless
isDEV
printCurrentDialogName
_WinUnload

Auxiliaries die ich in andere Libs verschoben habe:
Lib_FileIO:TempFilename
Lib_FileIO:writeAlphaAsFile
Lib_FileIO:readFullFileAsAlpha
Lib_Strings:Strings_UTF82C16

MAIN: Benutzungsbeispiele zum Testen

========================================================================
*/
@I:Def_Global


/*
========================================================================
Defines
========================================================================
*/
define begin
  // Wozu dient dieses define?
  cName     : 'Wert der Konstante'
end


/*
========================================================================
2022-05-05  DS                                               2407/1

!!! Bitte stattdessen einfach assert(bool) nutzen (aus Def_Global_Sys),
!!! denn dann werden automatisch Prozedurname und Zeile als Argument
!!! context hinzugefügt.
    
Eine Art assertion "C16-style". Gibt Fehlermeldung aus wenn eine
Bedingung nicht zutrifft.
========================================================================
*/
sub _assert(condition : logic; kontext : alpha(256))
begin
  if !condition then
  begin
    WinDialogBox(0,'Assert', 'Assertion fehlgeschlagen.' + StrChar(10) + StrChar(10) + 'Kontext:' + StrChar(10) + kontext, _WinIcoError, _WinDialogOk, 0);
  end
end


/*
========================================================================
2022-05-03  DS                                               2407/1

Konvertiert boolean/logic nach String/alpha "true" bzw. "false"
========================================================================
*/
sub CnvAL(aVal : logic) : alpha
begin
  if aVal then
    return 'true';
  else
    return 'false';
end


/*
========================================================================
2022-04-11  DS

Liefert Wert eines Feldes (qualifiziert durch Tbl-, Sbr- und Fld-Index)
als String, unabhängig von Feld-Typ.
Kann auch Buffer auslesen, siehe opt Argument.

Benutzungsbeispiel:
  v903Buf # RecBufCreate(903);
  RecRead(v903Buf,1,0);
  vVal # FieldValueAsString(903, 1, 22);             // liest aus Tabelle 903
  vVal # FieldValueAsString(903, 1, 22, v903Buf);    // liest aus Buffer v903Buf
 
  DebugM('Ausgabe von FieldValueAsString(): ' + vVal);
========================================================================
*/
sub FieldValueAsString
(
  aTbl           : int;           // Tabellen-Nummer oder Deskriptor eines Datensatz-Puffers
  aSbr           : int;           // Teildatensatz-Nummer
  aFld           : int;           // Feld-Nummer
  // die obige Methoden-Signator orientiert sich vollständig an der von FldAlpha und deren Schwestermethoden
  opt aBuffer    : handle;        // Kann genutzt werden um statt der Tabelle in aTbl einen buffer auszulesen. aTbl muss dann trotzdem der Tbl Index
                                  // der Tabelle sein zu der aBuffer gehört, denn FldInfo funktioniert nur auf Tabellen, nicht auf buffern.
) : alpha
local begin
  vTableOrBuffer : handle;
  vReturn        : alpha;
end
begin

  // bestimme, woraus die Werte gelesen werden sollen:
  if aBuffer > 0 then
  begin
    vTableOrBuffer # aBuffer;
  end
  else
  begin
    vTableOrBuffer # aTbl;
  end
  
  case FldInfo( aTbl, aSbr, aFld, _fldType ) of  // hier muss zwingenderweise aTbl verwendet werden, mit aBuffer funktioniert es nicht!
    _typeAlpha : vReturn # FldAlpha( vTableOrBuffer, aSbr, aFld );
    _typeWord  : vReturn # CnvAI( FldWord( vTableOrBuffer, aSbr, aFld ), _fmtNumNoGroup );
    _typeInt   : vReturn # CnvAI( FldInt( vTableOrBuffer, aSbr, aFld ), _fmtNumNoGroup );
    _typeFloat : vReturn # CnvAF( FldFloat( vTableOrBuffer, aSbr, aFld ), _fmtNumNoGroup, 0, 5 );
    _typeDate  : vReturn # CnvAD( FldDate( vTableOrBuffer, aSbr, aFld ) );
    _typeTime  : vReturn # CnvAT( FldTime( vTableOrBuffer, aSbr, aFld ) );
    _typeLogic : vReturn # CnvAI( CnvIL( FldLogic( vTableOrBuffer, aSbr, aFld ) ) );
  end;
  return vReturn;
end



/*
========================================================================
2022-04-11  DS

Liefert Wert eines Feldes (qualifiziert durch seinen Namen)
als String, unabhängig von Feld-Typ.

Kann (anders als FieldValueAsString()) nicht auf Buffer angewandt
werden, weil die genutzten internen C16-Methoden (Fld...ByName()) keine
Buffer unterstützen.
========================================================================
*/
sub FieldValueAsStringByName
(
  aFieldName : alpha;
) : alpha
local begin
  vReturn : alpha;
end
begin
  case FldInfoByName( aFieldName, _fldType ) of
    _typeAlpha : vReturn # FldAlphaByName( aFieldName );
    _typeWord  : vReturn # CnvAI( FldWordByName( aFieldName ), _fmtNumNoGroup );
    _typeInt   : vReturn # CnvAI( FldIntByName( aFieldName ), _fmtNumNoGroup );
    _typeFloat : vReturn # CnvAF( FldFloatByName( aFieldName ), _fmtNumNoGroup,0,5 );
    _typeDate  : vReturn # CnvAD( FldDateByName( aFieldName ) );
    _typeTime  : vReturn # CnvAT( FldTimeByName( aFieldName ) );
    _typeLogic : vReturn # CnvAI( CnvIL( FldLogicByName( aFieldName ) ) );
  end;
  return vReturn;
end



/*
========================================================================
2022-04-25  DS                                               2298/35

Liefert die Anzahl der zum Query passenden Zeilen / Datensätze.
Kann z.B. genutzt werden, um festzustellen ob multikeys faktisch
unique sind.

Beispiel:

  VarAllocate(WindowBonus);

  vQuery # '';
  Lib_Sel:QInt(var vQuery, 'Adr.V.Adressnr', '=', 1386);
  Lib_Sel:QAlpha(var vQuery, 'Adr.V.KundenArtNr', '=', 'Vorlage universell');
  
  DebugM(CnvAI(countRowsMatchingQuery(105, vQuery)));
  
========================================================================
*/
sub countRowsMatchingQuery
(
  aTable : int;          // In dieser Tabelle wird geprüft
  aQuery : alpha(4096);  // Bzgl. dieser Query wird geprüft. Query kann erzeugt werden mit Lib_Sel:QInt() und verwandten Methoden, siehe Beispiel in Doku.
) : int                  // Anzahl der auf aQuery matchenden Zeilen in aTable
local begin
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vOK       : logic;
  tErx      : int;
  vReturn   : int;
end
begin

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate(aTable, 1);
  tErx # vSel->SelDefQuery('', aQuery);
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  // Anzahl bestimmen
  vReturn # RecInfo(aTable, _recCount, vSel);

  // Aufräumen
  SelClose(vSel);             // Selektion schliessen
  SelDelete(aTable,vSelName);    // temp. Selektion löschen
  vSel # 0;
  
  return vReturn;
  
end



/*
========================================================================
2022-08-11  DS                                               2407/4

Gibt alle Werte eines Alpha Array als Popups aus.
  
========================================================================
*/
sub printArrayAlpha
(
  var array : alpha[]
)
local begin
  vIdx : int;
end
begin
  FOR   vIdx # 1;
  LOOP  Inc(vIdx);
  WHILE vIdx <= VarInfo(array) DO
  BEGIN
    DebugM('Array Index: ' + StrChar(10) + StrChar(10) + CnvAI(vIdx) + StrChar(10) + StrChar(10) + 'Array Alpha Value: ' + StrChar(10) + StrChar(10) + '"' + array[vIdx] + '"');
  END;
end



/*
========================================================================
2023-03-07  DS

Gibt aus ob die SC GUI verfügbar (geladen) ist oder nicht
========================================================================
*/
sub isGuiAvailable(): logic
begin
  // feststellen ob Datenbereich der gFrmMain enthält geladen ist
  if VarInfo(VarSys) = 0 then
  begin
  // wenn nicht mal der Datenbereich allokiert ist, ist definitiv die GUI nicht verfügbar
    return false
  end
  else
  begin
    // wenn Datenbereich allokiert ist, prüfe ob gFrmMain gefüllt ist
    return gFrmMain <> 0;
  end
end


/*
========================================================================
2023-03-07  DS

Gibt aus ob die Prozedur headless läuft oder nicht
========================================================================
*/
sub isHeadless(): logic
begin
  return !isGuiAvailable();
end



/*
========================================================================
2023-03-10  DS

Gibt aus ob SC aktuell bei Business Control in einem DEV Datenraum läuft
========================================================================
*/
sub isDEV(): logic
begin
  return DbaLicense(_DbaSrvLicense) = 'CD152667MN/H';
end


/*
========================================================================
2023-05-05  DS

Gibt den Namen des aktuellen Dialogs auf dem Bildschirm aus.
Kann z.B. innerhalb von
Lib_Debug:Button()
gerufen werden.
ALS SFX-FAVORIT KOMMT IMMER NUR DAS HAUPTMENU ZURÜCK, das geht also nicht.
========================================================================
*/
sub printCurrentDialogName()
begin
  DebugM('Name des aktuellen Dialogs:' + cCrlf2 + gMDI->wpName);
end



/*
========================================================================
2023-07-07  DS

Ruft zweimal WinClose auf dem übergebenen Dialog-Handle.
Hintergrund ist folgendes Zitat aus der Doku von WinClose:
"Das Fenster wird erst durch die erneute Ausführung von WinClose() entladen."
Ansonsten wird es nur geschlossen, bleibt aber im Speicher geladen.

Damit es in normalen Code nicht nach Copy-Paste-Fehler sondern
geplantem und bewusstem Handeln aussieht gibt es diese eindeutiger
benannte Hilfsfunktion.

Makro:
WinUnload (in Def_Global)
========================================================================
*/
sub _WinUnload(var aHdlDlg : handle)
begin

  //DebugM('aHdlDlg=' + aint(aHdlDlg) + cCrlf + '_HdlExists=' + aint(aHdlDlg->HdlInfo(_HdlExists)) + cCrlf + '_HdlType=' + aint(aHdlDlg->HdlInfo(_HdlType)) + cCrlf + '_HdlSubType=' + aint(aHdlDlg->HdlInfo(_HdlSubType)));
  
  if aHdlDlg->HdlInfo(_HdlExists) = 1 then
  begin
    WinClose(aHdlDlg);
  end
  
  //DebugM('aHdlDlg=' + aint(aHdlDlg) + cCrlf + '_HdlExists=' + aint(aHdlDlg->HdlInfo(_HdlExists)) + cCrlf + '_HdlType=' + aint(aHdlDlg->HdlInfo(_HdlType)) + cCrlf + '_HdlSubType=' + aint(aHdlDlg->HdlInfo(_HdlSubType)));
  
  if aHdlDlg->HdlInfo(_HdlExists) = 1 then
  begin
    WinClose(aHdlDlg);  // Zitat aus der Doku von WinClose:
                        // "Das Fenster wird erst durch die erneute Ausführung von WinClose() entladen."
  end
  
  //DebugM('aHdlDlg=' + aint(aHdlDlg) + cCrlf + '_HdlExists=' + aint(aHdlDlg->HdlInfo(_HdlExists)) + cCrlf + '_HdlType=' + aint(aHdlDlg->HdlInfo(_HdlType)) + cCrlf + '_HdlSubType=' + aint(aHdlDlg->HdlInfo(_HdlSubType)));
  
  aHdlDlg # 0;
end



/*
========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================
*/

MAIN()
local begin
  v903Buf                   : handle;
  vVal                      : alpha;
  vQuery                    : alpha(4096);
  vFullFileAsAlpha          : alpha(4096);
  vArrayAlpha               : alpha[];
end;
begin

  // ggf. benötigte globals allokieren für Standalone-Ausführung (CTRL + T)...
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  // ...und setzen
  gUserName # 'ME';
  
  // Benutzungsbeispiel FieldValueAsString():
  /*
  v903Buf # RecBufCreate(903);
  RecRead(v903Buf,1,0);
  //vVal # FieldValueAsString(903, 1, 22);             // liest aus Tabelle 903
  vVal # FieldValueAsString(903, 1, 22, v903Buf);    // liest aus Buffer v903Buf
  DebugM('Ausgabe von FieldValueAsString(): ' + vVal);
  */
  
  // Benutzungsbeispiel FieldValueAsStringByName():
  /*
  vVal # FieldValueAsStringByName('Set.Installname');
  DebugM('Ausgabe von FieldValueAsStringByName(): ' + vVal);
  */
  
  // Benutzungsbeispiel countRowsMatchingQuery():
  /*
  VarAllocate(WindowBonus);
  vQuery # '';
  Lib_Sel:QInt(var vQuery, 'Adr.V.Adressnr', '=', 1386);
  Lib_Sel:QAlpha(var vQuery, 'Adr.V.KundenArtNr', '=', 'Vorlage universell');
  DebugM(CnvAI(countRowsMatchingQuery(105, vQuery)));
  */
  
  // Benutzungsbeispiel Lib_FileIO:TempFilename():
  /*
  DebugM(Lib_FileIO:TempFilename('json'))
  */
  
  // Benutzungsbeispiel
  // Lib_FileIO:writeAlphaAsFile()
  // und
  // Lib_FileIO:readFullFileAsAlpha
  /*
  // ohne "pure" Mode:
  Lib_FileIO:writeTxtFile('C:\debug\test_writeAlphaAsFile.txt', 'Das ist Alpha!' + StrChar(10) + 'Sogar mit Linebreaks!' + StrChar(10) + 'Und Ümläütßön.', false, true);
  Lib_FileIO:readTxtFile ('C:\debug\test_writeAlphaAsFile.txt', var vFullFileAsAlpha                                                                     , false, true);
  DebugM(vFullFileAsAlpha);
  */
  /*
  // mit "pure" Mode:
  Lib_FileIO:writeTxtFile('C:\debug\test_writeAlphaAsFile.txt', 'Das ist Alpha!' + StrChar(10) + 'Sogar mit Linebreaks!' + StrChar(10) + 'Und Ümläütßön.', true, true);
  Lib_FileIO:readTxtFile ('C:\debug\test_writeAlphaAsFile.txt', var vFullFileAsAlpha                                                                     , true, true);
  DebugM(vFullFileAsAlpha);
  */
  
  
  /*
  VarAllocate(vArrayAlpha, 3);
  vArrayAlpha[1] # 'Dies sind';
  vArrayAlpha[2] # 'alle Alphas';
  vArrayAlpha[3] # 'im Array';
  printArrayAlpha(var vArrayAlpha);
  */
  
  
  DebugM('isGuiAvailable(): ' + CnvAL(isGuiAvailable()));
  DebugM('isHeadless(): ' + CnvAL(isHeadless()));
  
  
  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;
  
end