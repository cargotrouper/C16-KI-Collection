//===== Business-Control =================================================
//
//  Prozedur    !FAQ
//                  OHNE E_R_G
//  Info        Nur Infotext - keine Prozeduren !!!
//
//========================================================================
/*

//########################################################################
//########################################################################
//#                Laufzeitumgebung, Fehlermeldungen                     #
//########################################################################
//########################################################################

/*
  RecRead(1,2,_RecLock);          // AUA
  Erx # RecRead(1,2,_RecLock);    // AUA
  blabla
  
  Erx # RecRead(1,2,_RecLock);    // OK
  if (Erx=blablabla


  RekReplace(aaa);        // AUA
  
  Erx # ReKReplace(aaa);  // AUA
  
  if (ReKREPLAce(aaa)     // OK
  
  Erx # RekrePLACE(aaa)   // OK
  if (Erx=blablabla
  
  Erx # RekrePLACE(aaa)   // OK

  if (Erx=blablabla
  

  xxx
*/

//========================================================================
//  Demodatenraum/Evaluierungsdatenraum erstellen
//            AI 24.07.2009
//========================================================================
- DB darf nirgends mehr als 1000 Datensätze haben
- DB darf nicht reserviert (OEM Kit "Freigabe") sein
- DB mit dem ADVANCED-Client öffnen und dort Menp "Datei->Konvertieren"
//========================================================================

//========================================================================
//  ARCFLOW starten/drucken geht nicht
//            AI 03.08.2009
//========================================================================
- Pfad zur AF_API.DLL muss in den Settings eingetragen werden ("z:\c16_client\arflow_api")
  sonst Error -20002
- USERNAME+PW müssen stimmen sonst Error 5
//========================================================================

//========================================================================
//  Onlinehilfe geht nicht, Fehlermeldung "Die Navi... wurde abgebrochen"
//            ST 27.07.2009
//========================================================================
- Windows Internetoptionen:Sicherheit/Lokales Intranet/Sites Haken: nyyy

//========================================================================
//  Formulardruck mit Briefbogen über PrintServer / FRX
//            TM 13.03.2014
//========================================================================
- Briefbogen muss im Printwerver\Frx\ Ordner hinterlegt werden.
- Die Abfrage 'Briefbogen j/n' wird direkt in die Formularprozedur geschrieben.
  Beispiel:
  if (Msg(912006,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then vLogo     # 'BRIEFBOGEN1.JPG';

//========================================================================
//  PrintServer fr Testsystem
//            AH 29.07.2016
//========================================================================
- in der Host.ini Port jeweils +2 und an Namen und Descrition "_Testsystem" anhängen

//========================================================================
//  Formulardruck über PrintServer / FRX: Wie "echten" Lauf erkennen?
//            AH 18.05.2016
//========================================================================
- if (Engine.FinalPass)

//========================================================================
//  Formulardruck über PrintServer / FRX: Wie leere Felder unterdrücken?
//            AH 18.05.2016
//========================================================================
- Event All_AfterData eintragen

//========================================================================
//  Listendruck über PrintServer / FRX: Wie Gruppierung/Sortierung nach Abm.?
//            TM 06.07.2016
//========================================================================
- Gruppierungsstring ist alphanumerisch, Abmessungswerte müssen mit führenden
  Nullen als AUSDRUCK eingetragen werden:

  ToString(Format("{0:00000.00}",[Abmessungswert]))

//========================================================================
//  Langsamer Formulardruck über PrintServer / ganzseitiger Briefbogen
//            TM 24.04.2019
//========================================================================
- Installation von Ghostscript KANN das Problem beheben, hängt von Hardware / Treibern ab
  z.B. Samsung ML2250 ohne GS Druck ~30 sek/2 Seiten, mit GS < 1 sek/2 Seiten
       Kyocera        ohne GS Druck ~60 sek/2 Seiten, mit GS ~30 sek/2 Seiten


//========================================================================
//========================================================================



//########################################################################
//########################################################################
//#      Entwicklung                                                     #
//########################################################################
//########################################################################

//========================================================================
// Dialog: JUMP-LOGIK für Mittlere Maustaste
//            AH 08.07.2016
//========================================================================
- "EvtLstDataInit" erwetiern um "Lib_GuiCom:ZLQuickJumpInfo($clmOfp.Kundenstichwort);"  z.B. OFP_MAIN
- Sub "JumpTo" einbauen z.B. OFP_MAIN

//========================================================================
// Editor: reguläre Ausdrücke
//            AH 30.07.2014
//========================================================================
- Beispiel: Lfs\.P\.MEH\.Einsatz.*\#.*\'kg\'
            [^App]+[^PtD]_main:               NICHT App_Main oder PtD_Main
            \. = Punkt (Sonderzeichen)
            .* = irgendwas
- (?i)^\s{0,100}REKINSERT|REKDELETE|REKREPLACE

//========================================================================
//  GUI: Icons
//            AH 26.11.2013
//========================================================================
- 24x24er Icons mit GIMP (!!!) als PNG speichern, damit ALPHA-Channel klappen

//========================================================================
//  GUI: Beim Neuanlegen von Sätzen, wird das letzte fokusierte Feld nicht geleert...
//            AI 24.07.2009
//========================================================================
- DUMMYNEW muss ENABLED UND VISIBLE sein

//========================================================================
//  GUI: Neuer Dialog lässt keine Aktion (Neu, Ändern...) zu...
//            AI 24.07.2009
//========================================================================
- Name der RecList nicht gleich in der MAIN und dem Dialog

//========================================================================
//  Updates: Generieren und Veröffentlichen
//            ST 04.08.2009
//========================================================================
- Bei jedem Update werden folgende Punkte abgearbeitet, egal wie kleine
  eine Kundenänderung auch ist:
  1. Update laut Updatedefinition "Vollupdate" aus dem Entwicklungs-
     datenraum über die Kommandozeile mit  "createupdate" generieren.
     Versionsnummer mit OK bestätigen.
  2. Update Datei umbenennen (jjjj_mm_tt.d01)
  3. Update auf "\\word\updates\freigegeben" kopieren
  4. Einspielen in Kundendatenraum durch Useranmeldung "installupdate"
  5. Alle Prozeduren neu übersetzen (über Prozedurassistent )
  6. Update laut Updatedefinition "Vollupdate" aus dem Kundendatenraum
     über die Kommandozeile mit  "createupdate" generieren. Versionsnummer
     mit OK bestätigen.
  7. Update umbenennen in Kundenkürzel+"jjjj_mm_tt" und in auf
     \\word\updates kopieren (nur Temporär für Kundenverteilung)
  8. Per VNC Auf den FTP Server (192.168.0.250:5999) verbinden
  9. Das Update von Word in den Ordner c:\ftproot\"Kundenname_KndNummer"
     VERSCHIEBEN
 10. Datei "Update.txt" anpassen (File: "Updatedateiname")
 11. fertig


//========================================================================
//  Formulare: Formularfehler nach Seitenanfang
//            ST 04.08.2009
//========================================================================
- Sollte ein Formular nach einem Seitenumbruch sich fehlerhaft Verhalten,
  dann muss die Prozedur auf die Benutzung von ERG untersucht werden.
- ERG Darf nur als Ergebnisvarialbe und nicht als Steuerungsvariable benutzt
  werden z.B. nicht Schleifen mit Printline!!!! Erg wird durch Printline verändert


//========================================================================
//  Läufe: Grundsätzliches
//            ST 07.08.2009
//========================================================================
- Lauf in xxx_Data Prozedur
- Änderungen mit RekRepace(xxx,yyy,'AUTO')
- Protokollierung der Änderungen des Laufes mit debug('...')
- Beispiel: Mat_Data:Repair_ResetLoeschdatum

//========================================================================
//  Formulare: Formulare anderer Sprache
//            MS 25.08.2009
//========================================================================
- Form_Lang muss gesetzt werden (zB. Englisch Form_Lang # 'E')
- wird diese nicht gesetzt, wird Deutsch als Standard genommen
- ist nötig zB. für einen anders sprachiger Seitenfuss
//========================================================================

//========================================================================
//  Pflichtfelder
//            MS 21.06.2010
//========================================================================
- Als Bsp. in der Art_Main:
- Prüfung vor dem Speichern (RecSave):
  if(Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() = false) then
    RETURN false;

- Einfaerben (RefreshIfm):
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
//========================================================================

//========================================================================
//  PDF Datein drucken / am Druck anhaengen
//            MS 21.06.2010
//========================================================================
- Lib_Print:Print_Pdf('DATEI');
//========================================================================

//========================================================================
//  Faxen mit Tobit / David
//            MS 01.09.2010
//========================================================================
- Der Faxcode muss auf der 1 Seite des Dokuments gedruckt werden
- Aufruf des drucks nach dem printen des Seitenkopfs da es sonst zu
  Zeilenspruengen kommen kann
- Beispiel zB. in der Alfa AB zu finden
//========================================================================


//========================================================================
//  Quickbars installieren:
//            AI 30.11.2012
//========================================================================
- aus Adr.Verwaltung oder MAt.Verwaltung das GroupsplitObjekt "gs.main" samt
  Unterobjekten kopieren
- in den Grouptile "gt.Dialog" das zu Notebook "NB.Main" ersetzen mit dem
  aktuell zu nutzenden (also das NB.Main von Adr.Verwaltung löschen und
  dafür z.B. Wgr.Verwaltung-NR.Main reinsetzen)
/***
- in der Prozedur "EvtPosChanged" diesen Block einsetzen:
...
  // Quickbar
  vHdl # Winsearch(gMDI,'gs.Main');
  if (vHdl<>0) then begin
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left+2;
    vRect:bottom    # aRect:bottom-aRect:Top+5;
    vHdl->wparea    # vRect;
  end;
  if ( aFlags & _winPosSized != 0 ) then begin
...
***/
- Das Menü unter Extras eintragen "Mnu.Quickbar.Config"
//========================================================================


//========================================================================
//  SERVICES: Standard Webserviceprozeduren werden wie folgt benannt:
//    SVC_000000
//     |  |_______ sechsstellige Servicenummer, wird IMMER hochgezählt
//     |__________ Serviceopräfix
//
//    Kundenindividuelle Services werden nur im Kundendatenraum entwickelt
//    und werden wie folgt bezeichnet:
//
//    SVC_ISB_100001
//     |   |  |___________ Servicenummer des Kunden wird einzeln hochgezählt + 100000
//     |   |______________ Kundenpräfix
//     |__________________ Servicepräfix
//
//            ST 28.01.2011
//========================================================================


//########################################################################
//########################################################################
//#      Sonstiges                                                       #
//########################################################################
//########################################################################

//========================================================================
//Windows Anwendungsprotokoll z.B. zur Weiterleitung an vectorsoft
//========================================================================
- C:\Windows\System32\WinEvt\Logs\Application.evtx




//========================================================================
MAKRO FÜR EXCEL:
//========================================================================
Sub Test_Future()

   Dim Testsnr As Integer
   Testsnr = 10
     connstring = "ODBC;DSN=future;UID=AI;PWD=;Database=future"
     sqlstring = "SELECT Adr_Adressen.Adr_Nummer, Adr_Adressen.Adr_KundenNr, Adr_Adressen.Adr_Stichwort " & _
         "FROM Adr_Adressen Adr_Adressen "
rem         "WHERE Adr_Adressen.Adr_Nummer < 5;")

    With Sheets("Tabelle1").QueryTables.Add(Connection:=connstring, _
        Destination:=Range("A1"), Sql:=sqlstring)
      .Refresh BackgroundQuery:=False
   End With

End Sub
//========================================================================


//========================================================================
//  Lokales Debuggen des PrintServers aber CA1 + SQL online beim Kunden
//            AH 08.01.2020
//========================================================================
- mit Anydesk auf Server verbinden
- Anydesk TCP-Tunnel aktivieren:  20000 -> Localhost, Port_der_Sql (z.B. 1433)
- Anydesk TCP-Tunnel aktivieren:  5001 Localhost <- 25001
- Lokalen Printserver mit Host.ini: - "Server = localhost\SQLEXPRESS,20000"
                                    - "Database = Name_der_SQL_beim_Kunden"
                                    - "User" + "Password" vom Kunden
- In C16: erst Kommando "DEBUG" um Debugmode für Programmierer zu starten und dann Formulare im Designer starten
- Wichtig: Datenstruktur der SQL muss zum benutzen PS passen - sonst vorher updaten

//========================================================================

//========================================================================
CMDTWAIN:
cmdtwin.exe -c "DPI 300 GRAY ADF 1 AS 1 DPX 1" PDF3 d:\....bla.pdf

Pdf2Tiff PdfToTiff: per GS
gswin64c.exe -dNOPAUSE -r300 -sDEVICE=tiffscaled24 -sCompression=lzw -dBATCH -sOutputFile="d:\debug\_qwe.tif" "d:\debug\_qwe.pdf"

OCR Tesseract:
tesseract.exe d:\debug\scans\tiff\_qwe.tif d:\debug\scans\txt\_qwe.txt
oder für Umlaute:
tesseract.exe d:\debug\scans\tiff\_qwe.tif d:\debug\scans\txt\_qwe.txt -l deu

//========================================================================
// LOKALER PRINTSERVER UNTER WINDOWS 8 / 10
//========================================================================
Um den lokalen Printserver unter Windows 8 / 10 lauffähig zu machen, bitte die
Eingabeaufforderung als Administrator öffnen und folgendes Kommando ausführen:

netsh http add urlacl url=http://[IP]:5001/ user=bcs2010\[Benutzerkonto]

netsh http add urlacl url=http://+:5001/local/Report/ user=bcs2010\[Benutzerkonto]
netsh http add urlacl url=http://+:5001/local/Critical/ user=bcs2010\[Benutzerkonto]
netsh http add urlacl url=http://+:5001/local/System/ user=bcs2010\[Benutzerkonto]
netsh http add urlacl url=http://+:5001/local/Custom/ user=bcs2010\[Benutzerkonto]
netsh http add urlacl url=http://+:5001/local/StahlControl/ user=bcs2010\[Benutzerkonto]
netsh http add urlacl url=http://+:5001/local/StahlControl/EdiService/ user=bcs2010\[Benutzerkonto]

!! Wichtig !! zu prüfen im SQL Configuration Manager:
TCP muss für die verwendete SQL-Instanz AKTIVIERT sein.
Der Server Browser-Dienst muss ggf. von Hand aktiviert werden (default Start Type "Disabled" ändern auf "Automatic", dann starten)




//========================================================================
//========================================================================
VISUAL STUDIO, Probleme mit "Micrsofot.Build.Framework"

Launch the Visual Studio 2017 Developer Command Prompt
Type the following commands (replace Professional with your edition, either Enterprise or Community, or adjust the path accordingly):
gacutil /i "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\Microsoft.Build.Framework.dll"
gacutil /i "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\Microsoft.Build.dll"
gacutil /i "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\Microsoft.Build.Engine.dll"
gacutil /i "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\Microsoft.Build.Conversion.Core.dll"
gacutil /i "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\Microsoft.Build.Tasks.Core.dll"
gacutil /i "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\Microsoft.Build.Utilities.Core.dll"

//========================================================================
// CONZEPT16 SYSTEMFEHLER DATENBANKKERN
//========================================================================
Conzept16 Systemfehler
Bereich: Datenbankkern
Fehler: Temporäre Datei kann nicht angelegt werden

Tritt auf, wenn auf Windows\Temp nicht zugegrifen werden kann (Schreibzugriff benötigt).
Ein Neustart des jeweiligen Geräts löst das Problem.

//========================================================================
// SR 04.05.2022
// Funktion um Custom Felder, die in C16 implementiert wurden, im Report aufrufen zu können (GetExtended)
//========================================================================
- Die Library BC.Util.Frx mit ins frx holen
- Die Funktion GetExtended erwartet folgende Werte (string DataSource, string NameCustomFeld) und gibt den Inhalt des Customwerts zurück
- Ein Beispiel wäre GetExtended("View.PositionenObj.ExtendedFelder" , "Cust_StkProBnd") Referenz ist bei Dexter der Report DEX_AUFBEST im Code



BÖSE WEGEN DEADLOCKS (Sort nach grobe Prio):

- _RecLock OHNE Prüfung auf ERX
- RekInsert, RekReplace, RekDelete OHNE Prüfung auf ERX (z.B. RekInsert mit UNTIL ERX=_rOK)
- TextWrite/TxtWrite etc.
- SelRun, Sel...

***/
main begin end;

