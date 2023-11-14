@A+
//===== Business-Control =================================================
//
//  Prozedur    !History
//                  OHNE E_R_G
//  Info        Nur Infotext - keine Prozeduren !!!
//
//========================================================================
//
//  DATUM     US  TYP   INFO
//  01.09.14  AH  Neu   SQL-PrintServer
//  10.09.14  AH  Neu   BA-Graph auch am Kopf einsehbar
//  11.09.14  AH  Neu   Dashboard/Gauges implementiert
//  17.09.14  AH  Neu   SQL-Inits auch einzeln pro Tabelle startbar
//  18.09.14  AH  Bug   Onlinestatistik für Dashboard: "_Save" ignoriert "_EINGANG"-Sätze für Quartal und Jahr
//  22.09.14  AH  Bug   Lib_Strings:DOS2XML für €-Konvertierung
//  22.09.14  AH  Bug   Verwaltungs-Moduswechsel List->View mit Selektion
//  22.09.14  ST  Neu   Anker "BAG.F.Tafel.RecSave"
//  24.09.14  AH  Neu   Klonen auch im Lohneinsatzdialog
//  24.09.14  AH  Edit  Tafelgewicht wird "am Stück" errechnet und nicht so stark gerundet
//  24.09.14  AH  Bug   Autoamtische Auftragslöschung bei Faktura hatte Probleme mit anderen MEH
//  25.09.24  AH  Edit  beim BA-Tafeln die Blockberechnung verändert (nicht mehr Division durch BAG.IO.Plan.Stk)
//  30.09.14  AH  Edit  APPON/APPOFF sind nun Funktionen
//  07.10.14  AH  Bug   Eingangsrechnungskontierung erwartet ab jetzt einen FINALEN Steuerschlüssel
//  15.10.14  AH  Neu   Setting für "gelsöchte Materialkarten sofort ablegen" samt ERweiterungen der Stammbäume, Aktionen usw. dafür
//  22.10.14  AH  Neu   Markierungen im LFS
//  23.10.14  AH  Edit  Lieferantenbestätigungen bei LFS sind nicht mehr Pflicht, sondern Warnung
//  30.10.14  AH  Edit  Adrss-Stichwort-Ändern mit APPOFF
//  31.10.14  AH  Edit  Excel-Export kann nun auch XML usw.
//  03.11.14  AH  Edit  Adresse->Info->Aufträge & Bestellung nun Selektion statt Link
//  03.11.14  AH  Neu   AFX BAG.P.Abschluss.Pre
//  06.11.14  AH  Bug   Verwaltungsskalierung nutzt jetzt gepufferten Zoomfaktor um Fehler durch zufälligen Focuswechsel zu vermeiden
//  06.11.14  AH  Bug   Mehrere LFA auf gleichem Einsatzmaterial gingen nicht
//  06.11.14  ST  Bug   Selektionsausgabe für Liste 500.009 korigiert
//  07.11.14  AH  Neu   *Lieferantenerklärungen-Strukturnummern nun auch löschbar
//  11.11.14  AH  Bug   Runtimerror in Feinplanung beim Fensterwechsel
//  12.11.14  AH  Neu   Adresse->Druck->Besuchsbericht
//  12.11.14  AH  Bug   "Zum Vorgang" im Workflow springt machnmal falsch (REPOS defekt)
//  12.11.14  AH  Neu   Workflow pro Auftragposition
//  14.11.14  AH  Edit  Blob-Dokumente ausdrucken passiert temporär über Druckerpfad, nicht zwingend C:
//  18.11.14  ST  Edit  Materialbestandsbuchübersicht zeigt jetzt die auch Menge an
//  19.11.14  ST  Edit  Materialkarten werden mit "Force" beim Lesen auch aus der Ablage geholt
//  19.11.14  ST  Bug   Liste 702.004: Datumsselektion repariert
//  19.11.14  ST  Neu   Liste 702.004: gibt jetzt Artikelnummer und Gruppe in XML aus, damit simple Art.Produktiosnlisten in Excel erstellt werden können (P. 1485/14)
//  19.11.14  AH  Edit  AFX für xxx.Init (z.B. Mat.Init) werden NACH der App_Main:EvtInit aufgerufen, damit ggf. eine startende Selektion das richtige Fenster (gMDI) hat
//  19.11.14  AH  Bug   Material-Splitten protokollierte die Menge falsch
//  24.11.14  AH  Bug   Bestellkarten von ArtMatMix errechnen ihre Menge und Preis richtig, auch wenn Bestell-MEH nicht KG ist
//  26.11.14  AH  Edit  TeM-Anker sind nun alle zentral über eine Funktion anzulegen
//  26.11.14  AH  Neu   Auftragsarten könne verschiedene Bewertungen/Verbuchungen vom Wareneingang benutzen
//  26.11.14  AH  Neu   Material-Wareneingang: Gewichtsermittlung per Maus setzt Brutto+Netto
//  02.12.14  AH  Edit  Artikepreise: "SetzePreis" mit neuem Datumsargument
//  03.12.14  AH  Edit  Materialneuanlage aus Artikel belegt Felder vor
//  04.12.14  ST  Bug   Terminplaner löschte beim Abbrechen der Eingabe alle Anker des Termins
//  08.12.14  AH  Edit  Alle Warengruppenprüfungen auf Dateinummer sind zentralisiert in Wgr_Data
//  10.12.14  AH  Neu   Materialrohrmaske mit Kontextmenü für Mengenberechnungen
//  11.12.14  AH  Edit  Selektionsmasken für Printserver erweitert
//  12.12.14  ST  Bug   Eingangsrechnug: Skontoberechnung rundet jetzt auf 2 Stellen nach dem Komma
//  15.12.14  AH  Bug   BA1_IO_Data: "EinsatzRein" holte Material falsch
//  16.12.14  AH  Bug   Material Splitten setzte Menge falsch,
//  16.12.14  AH  Edit  Auftragskopfverwaltung deaktiverit (passte nicht mehr zu Positinsmaske)
//  17.12.14  AH  Edit  Artikelmakse: Gewichte immer mit 4 Nachkommastellen
//  17.12.14  AH  Neu   Lieferantenerklärungen mit Bestellnummer
//  18.12.14  AH  Edit  Unterfensteröffnen erlaubt mehr Events (Lib_Guicom)
//  18.12.14  AH  Edit  Quickinfo-Liste setzt Summen nur optional
//  18.12.14  AH  Neu   Quick-Saegen aus Material
//  06.01.15  ST  Edit  Artikelzustände und Etiketten haben eigenen Listenbereich bekommen
//  07.01.15  ST  Neu   Excelexport und -Import für Listendefinitionen hinzugefügt
//  08.01.15  AH  Neu   Artikelpreisverwaltung
//  09.01.15  AH  Edit  Verschieben vopn Daten in/aus den Ablagen nutzt Rek-Befehle (für Sync)
//  12.01.15  ST  Edit  Reorg.Jobserver Material & Auftrag Datumsangabe bei Aufruf möglich
//  13.01.15  AH  Edit  DFakt und Matz im Auftrag filtern ggf. auf Artikelnummer bei MatMix
//  19.01.15  AH  Bug   Wareneingang hat auch ohne gefüllter Artikelnr versucht die Preisdatei zu refreshen
//  22.01.15  AH  Bug   Auftragsposition: Einsatzmenge bei Mix und Filter bei Artikelauswahl "Set.Auf.ArtFilter"
//  23.01.15  AH  Edit  Walzschritte im BA über Extras-Menü
//  23.01.15  AH  Bug   Editierbare Listen können nun auch mit Maus/F2 gespeichert werden
//  26.01.15  AH  Bug   Auftragsposition: Aufpreise für Artikel wurden falsch angezeigt
//  26.01.15  AH  Edit  Dashboarddaten auch für Angebots-Eingang
//  29.01.15  AH  Bug   Wandeln von Angebot zu Auftrag nahm in BLOBs nicht richtig mit bzw. verlinkte nicht
//  02.02.15  AH  Bug   Faktura speiohert Auftrags-Aktions-Rechnungsendpreise summiert pro Rechnung
//  02.02.15  AH  Edit  "Lib_Dokumente" und "Lib_Script" restoren "WindowBonus" für Druckaufruf
//  04.02.15  ST  Neu   Auftragsaktion/Extras/ MaterialVSB Datum für FM Druck zurücknehmen
//  04.02.15  AH  Bug   Aufpreis-Warengruppentext wurde nicht nach AUswahl refreshed
//  05.02.15  AH  Neu   Vorgaben->Aufpreise tragen eine Verpackungartikelnr
//  06.02.15  AH  Bug   Im Einkauf wurde Art.AbmessString nicht immer übernommen
//  09.02.15  AH  Neu   Kontextmenü im der BA-Combo
//  09.02.15  AH  Neu   Betriebsmenü: Verwiegung sperren + theoeretisches FM
//  11.02.15  AH  Edit  Adress std.Lieferanschriften
//  18.02.15  AH  Bug   Blättern in View ohne Edit-Knopf geht wieder
//  18.02.15  ST  Neu   Printserver Druckausgabe über verbundene ODBC Datenbank
//  18.02.15  AH  Bug   Ermittlung des Artikel-DS-Preises bei MatMix falsch
//  26.02.15  AH  Bug   Artikel-Wareineingang sperrte Chargensatz
//  27.02.15  ST  Bug   Druck von PDFs wandelt Text in Kurven um 1512/23
//  27.02.15  AH  Neu   *Ressourcen besitzen eigene Reservierungsdatei
//  01.03.15  AH  Neu   Auftrag: Nummernfilter
//  04.03.15  AH  Bug   BA-FM: Unterdeckungen in den Beistellungen können nicht gespeichert werden (auch nicht beim zweiten Speichernversuch)
//  04.03.15  ST  Neu   Druckerauswahl für Dokuemntenvorschau ohne Druckerangabe kann abgebrochen werden
//  06.03.15  ST  Bug   Kunden-/Lieferantenakte: RtfDruck: RTF Text wird nur gedruckt, wenn er gefüllt ist
//  10.03.15  AH  Neu   "BA importieren" und "BA-Arbeitsgänge importieren"
//  11.03.15  AH  Neu   Datenexport der Übersichtsliste
//  12.03.15  AH  Edit  PDFs ab jetzt als PDF/A
//  13.03.15  AH  Neu   Manuelle Material-Anlage bei MatMix setzt bei Preis=0 diesen auf Durchschnittspreis
//  13.03.15  AH  Neu   Update nimmt Listenformate mit, Kundeninfo-Text
//  25.03.15  ST  Neu   Druck über Druckerauswahl versteht jetzt zu Druckende Seiten (z.B. Seite 4 - 10)
//  26.03.15  ST  Bug   Fakturierung von MatMix schreibt wieder RE Daten an Materialkarte
//  30.03.15  AH  Edit  std. Auftrag/Einkaufsmaske per Setting, neuer Artikelfilter "250"
//  14.04.15  ST  Edit  Mehrsprachige Texte können jetzt lange Zeilen (> 250 Zeilen) und echte Umbrüche
//  15.04.15  ST  Neu   Printserver fragt bei Langläufern, ob erneut gewartet werden soll
//  15.04.15  ST  Neu   Temporäre Druckdateien (in DB und Filesystem) werden beim Starten/Verlassen geleert
//  21.04.15  ST  Bug   Liste Auf_400009 gruppiert jetzt nach AUftragskopf, sortiert innerhalb der Pos nach Termin
//  29.04.15  ST  Neu   Ankeraufruf BA1_V_Main:RecSave (RecSavePost) hinzugefügt
//  05.05.15  AH  Bug   Wareneingang: Erfüllungsprozent wurden auf falsche MEH bezogen
//  11.05.15  AH  Neu   Benutzersettings sind ex- und importierbar
//  18.05.15  AH  Neu   Rechnungsanschrift in Adresse
//  18.05.15  AH  Neu   Artikeltyp SET
//  20.05.15  AH  Bug   Fertigmeldungen haben Ausführungen verloren !
//  20.05.15  AH  Edit  PrintPreview speichert Druckerhandle anders ab (Problem mit ArcFlow)
//  29.05.15  AH  Bug   LFA-Umlagen wurden falsch berechnet, beim Setting "Material-Sofort-in-Ablage"
//  29.05.15  AH  Bug   neue EK-Wareneingänge mit vorbelegter Mat.Nr. nehmen nun den ggf. veränderten Bestand mit
//  09.06.15  AH  Neu   Quick-Tafeln aus Material
//  18.06.15  AH  Edit  "Rechnungslauf" optimiert (Appon/AppOff)
//  22.06.15  AH  Neu   EKK-RecList neue Spalte "Artikelstichwort"
//  24.06.15  AH  Neu   Archivierte Formulare können aus der Autragsaktionsliste gedrucke werden
//  29.06.15  ST  Neu   PDF Vorschau: Button zum Kopieren der Faxnummer hinzugefügt
//  30.06.15  ST  Neu   Anker: Betriebsmenü, Lfs aus VLDAW, EvtFocusTerm -> komplete Individualisierung möglich
//  06.07.15  ST  Bug   Autotispo Bedarfanlage: Warengruppenlink korrigiert
//  07.07.15  ST  Bug   Kreditlimitprüfung Lohn-BA Druck: LFA wird auch jetzt abgefragt
//  09.07.15  AH  Edit  Einkauf: Liefervertag oder Rahmen kann nicht im Nachhinein geändert werden
//  09.07.15  AH  Neu   Setting für "Umlage des Warenrestwertes der Einsatzrestkarten im LFA"
//  13.07.15  AH  Edit  LFA können über BA neu kalkuliert werden
//  16.07.15  AH  Neu   Rückstellungen der Auftragsvorkalkulation gehen in LFS/LFA als Kosten ein
//  20.07.15  ST  Edit  Manuelle Reklamationsaktion immer vom Typ MAN, Bearbeitung der AKtionsnummern deaktiviert
//  21.07.15  AH  Neu   Adress-Verpackungen für EK und VK getrennt
//  30.07.15  ST  Neu   DatevFibuV3 Umstrukturiert: kann jetzt Export: ERL,ERLK,EREK,ADR Import:OFP
//  04.08.15  ST  Bug   PS SQL Pdf klappt jetzt Direktdruck + Archivierung
//  04.08.15  ST  Bug   Fließkommafehler bei Ganzzahldivision bei Einheitenumrechnung
//  18.08.15  AH  Neu   Arbeitsgang "Schälen"
//  18.08.15  AH  Edit  Arbeitsgang "QTeil" überarbeitet
//  24.08.15  AH  Neu   Eingangsrechnung mit Werstellungsdatum
//  28.08.15  ST  Bug   QuickSägen: letzte Kommission4 wurde immer auf Komm.3 verbucht
//  04.09.15  ST  Bug   Wareneingang Abschlussdatumsprüfung nur bei entsprechenden Haken
//  18.09.15  ST  Neu   Quickjump aus Auftragsaktionsliste
//  30.09.15  ST  Bug   Adr/Info/Verkäufe beachtet jetzt Mat/Art/Mix/Warengruppentypen
//  07.10.15  AH  Neu   Arbeitsgang "SpaltSpulen"
//  12.10.15  ST  Bug   "App_Main_sub:ModeCommand" prüft ob Notebook vorhanden ist, bevor Notebookpage gesetzt wird
//  14.10.15  ST  Neu   Quickjump aus Bestellpositionübersicht (Artikel, Kommission)
//  15.10.15  ST  Neu   Materialverwaltung Rechte für Filter Start/Stop eingebaut
//  30.10.15  ST  Neu   Allgemeiner Wareneingang: Stk. Berechnung über Kontextmenü eingebaut
//  03.11.15  AH  Neu   Rücklieferscheine
//  04.11.15  AH  Edit  BA-Einsatzmaterialprüfung verbessert (kommissioniertes Mat ist illegal)
//  05.11.15  AH  Neu   Vorlage-BAs können dirket in BAs gewandelt werden
//  05.11.15  AH  Neu   Vorlage-BAs können auch für Lohnaufträge genutzt werden
//  11.11.15  AH  Bug   Auftragsrestmengen im Artikel wurden bei VLDAWs flasch errechnet (auch Storno und ggf. DFakt)
//  11.11.15  AH  Edit  Artikel-Inventurdatei auch für Material
//  18.11.15  ST  Neu   FM Maske Betrieb2: Stk. Berechnung über Kontextmenü eingebaut
//  18.11.15  AH  Edit  Printserver JSON als Node, nicht mehr als Alpha
//  19.11.15  AH  Edit  Analysedatei hat nun einen Kunden
//  26.11.15  AH  Edit  Cockpit 2.0
//  07.12.15  AH  Edit  Eingangsrechnung: Steuerbetrag wird wieder vorbelegt anhand Steuerprozent
//  17.12.15  AH  Bug   Mat.Aktion: "KostenW1ProMEH wurden mei manueller Eingabe nicht umgerechnet
//  19.01.16  ST  Neu   Anker "Auf.P.AusMaterial.Post" für Drag'n Drop hinzugefügt
//  19.01.16  ST  Neu   Setting VK/MatAblauf 4: Direktfakturierung nach Zuweisung
//  21.01.16  ST  Edit  Performanceverbesserung Kreditlimitprüfung bei Druck von BAs
//  05.02.16  AH  Neu   BA-Fertigmelden: Verpacken übernimmt Messwerte
//  05.02.16  AH  Bug   Lfs-Verbuchen vor Artikel ohne Mengenverbuchung hat keinen EK genommen
//  11.02.16  ST  Edit  Statistik-Rekalk. zeigt Buchungsfortschritt an (Erlösnr & ReDAtum)
//  16.02.16  AH  Edit  Restcoil beim Walzen behält Stückzahl (Prj.1556/82)
//  16.02.16  AH  Neu   Materialanylse kann kopiert werden
//  16.02.16  AH  Neu   AFX Mat.LagergeldFremd
//  01.03.16  ST  Neu   BAG. Theo.Einsatzstückzahl per Kontextmenü errechnbar
//  01.03.16  ST  Neu   Anker "BAG.P.AutoVSB" zum Austausch der automatischen VSB Erstellung im BAG
//  11.03.16  AH  Neu   *Finanzen->Kostenbuchung
//  15.03.16  ST  Edit  BA FM Betrieb: BA Eingabe ohne Position prüft auf Eindeutigkeit
//  17.03.16  ST  Neu   fixierte Zahlungsbedingung nur für Änderung mit entsprechendem Recht
//  18.03.16  AH  Neu   BAG.P.Status
//  21.03.16  ST  Neu   Anker "Mat.Zinsen" zum Austausch der Zinsberechnung unter "Finanzen/Material/Zinsen berechnen"
//  23.03.16  ST  Neu   Eingangsrechnungsprüfung bei OK per Setting einstellbar (K,Z,B, leer)
//  22.03.16  AH  Neu   EKK/ERe rechnet Kosten-Differenzen in BAG ein
//  22.03.16  AH  Neu   Fertigmelden/Abschluss aus BA-Verwiegungen möglich
//  23.03.16  AH  Neu   Anfragen zu Lohnaufträgen
//  24.03.16  AH  Neu   Quick-Sägen von 4 auf 7 Fertigungen
//  29.03.16  ST  Bug   PDF Vorschau, Seitennavigation nur im Bereich der vorhandenen Blätter möglich
//  29.03.16  ST  Neu   Anker "Betrieb.BetriebsauftragZeiten" zum Austausch der BA Zeitenerfassung im Betrieb
//  06.04.16  AH  Neu   Drag&Drop für Material in Auftrags-Reservierungen
//  07.04.16  AH  Neu   Drag&Drop für Material in Bestellposition als Vorlage
//  07.04.16  AH  Neu   Angebot zu Auftrag transfertiert Reservierungen
//  26.04.16  AH  Neu   Vorlage-Projekte samt Kopierfunktion
//  27.04.16  AH  Bug   Umkommissionieren von Material beachtet den Status
//  03.05.16  AH  Bug   LohnAuftrags-Einsatz: Teiliungspürüfung nur noch für diesen Einsatz statt für alle
//  10.05.16  AH  Neu   Vertretung für User
//  11.05.16  AH  Bug   BA-Schrottumlage mit Lohnkosten
//  20.05.16  AH  Edit  Material-Rohrmaske: manuelle Vorbelegung mit "kg" und Preisanzeige dann trotzdem in "T"
//  01.06.16  AH  Edit  MEH im Auftrag und Bestellung werden geprüft auf Rechtschreibung
//  02.06.16  AH  Edit  Adresse: Buchungsnummern jetzt FibuNummern alphanumerisch
//  03.06.16  ST  Edit  FRX Formulardruck mit optionalem Subject für Anhangsdateinamen & EMailbetreff
//  03.06.16  AH  Edit  Wareneingang: Material muss immer einen EK-Preis bekommen
//  03.06.16  AH  Edit  Auftrag-Materialzuordnung: Netto/Brutto sind ggf. Pflichtfelder
//  06.06.16  AH  Edit  Visualizer arbeitet mit %temp%-Directory
//  07.06.16  AH  Edit  Ausdrucke/Dokumente/Blobs arbeiten mit %temp%-Directory wenn Set.Druckerpfad=''
//  08.06.16  ST  Edit  Lieferscheinübersicht, SpaltenSortierung wieder per LfsNummer ermöglicht
//  08.06.16  AH  Edit  Auftrag/Bestellung: neues Feld "Güte" bei Artikel
//  14.06.16  ST  Neu   Neues Formular "Stammdaten/Material/Analyse"
//  14.06.16  AH  Bug   User-Passwort konnte nicht auf oder von Leer gesetzt werden
//  16.06.16  AH  Bug   Artikeltext wurde bei dirketem Editieren nicht geladaen
//  20.06.16  AH  Bug   BA : "ErzeugeBAausVorlage" kopiert auch Ausführungen
//  01.07.16  AH  Edit  Matz akzeptiert Material mit mehreren Reservierungen
//  14.07.16  AH  Neu   Drag&Drop in Adressdokumnete
//  14.07.16  AH  Bug   Kontakte falsch zugeordnet
//  18.07.16  AH  Neu   neues Setting : Kreditlimit kann auch BRUTTO rechnen
//  19.07.16  AH  Bug   BA : "ErzeugeBAausVorlage" kopiert auch Verpackungen
//  19.07.16  ST  Edit  Bestellübersicht zeigt jetzt AB-Nummer aus der Position an, anstatt aus den Kopfdaten
//  20.07.16  ST  Edit  LFA: Verwiegungsart wird jetzt aus der Auftragsposition gelesen
//  26.07.16  AH  Edit  Quick-Tafeln mit 6 Zeilen
//  29.07.16  ST  Neu   Liste BAG0003 für Fertigmeldungen hinzugefügt
//  05.08.16  ST  Edit  Ermittlung der Abm.Tol. Rundet jetzt laut Nachkommastellen-Setting
//  15.08.16  AH  Neu   "VK-Korrektur"-Felder für Erlöse, Kontierungen, Aktionen, Mateiral und Statistik
//  18.08.16  AH  Bug   Auftrag/Einkauf: Bug, wenn man Kopfaufpreise während Erfassung pflegte
//  23.08.16  AH  Neu   Eingangsrechungskorrekturen können direkt in Aktionen, Statistik etc. gebucht werden (Setting)
//  30.08.16  AH  Neu   Setting für KEINE Umlagekosten im Material bei Mengenänderungen
//  12.09.16  AH  Neu   direkte Bestellungen zu Lohnaufträgen
//  28.10.16  ST  Neu   Serienmarkierung für Bestellpositionen aktiviert
//  04.11.16  AH  Neu   Ringnummer 32 Stellen
//  05.11.16  AH  Neu   Gutschriften/Belastungen mit Materialzuordnung zur DB-Erlöskorrektur
//  07.11.16  AH  Edit  Pflichtfelder in LFS-Positions-Maske
//  07.11.16  AH  Neu   AFX "Mat.Rsv.InsertAllMark"
//  10.11.16  AH  Neu   Auf.PAbrufYN
//  10.11.16  AH  Neu   AFX "LfE.RecInit"
//  01.12.16  ST  Edit  SOA Sync startet sich im Fehlerfall selbstständig neu
//  07.12.16  ST  Bug   Materialstrukturliste Gütenauswahl funktioniert wieder
//  09.12.16  AH  Edit  Aktueller User wird überall per "Usr_data:RecReadThisUser" gelanden, damit Rechte auch wieder stimmen
//  13.12.16  AH  Edit  Liefern von freiem Material auf Kommission, setzt dieses erst VSB
//  14.12.16  ST  Edit  Tapi: Rufeingang Benachrichtigungen überarbeitet
//  19.12.16  ST  Bug   Dateidialog bei Import der Benutzereinstellungen korrigiert
//  22.12.16  AH  Neu   MATZ kann markierte Karten übernehmen
//  02.02.17  ST  Neu   Datenexport/Import bei Vertreter & Verbände
//  27.02.17  ST  Neu   Datenexport/Import bei Customefeldern und Customauswahlfeldern
//  08.03.17  AH  Bug   BA-Kosten haben nicht immer einen Fehler gemeldet, wenn Daten nicht verändert werden konnten
//  10.03.17  AH  Edit  EK-Preis-Änderungen (durch EKK oder Neubewertung) werden nun chronologisch richtig eingerechnet
//  10.03.17  ST  Edit  Aufpreis/Neuberechnung: Ein Prozentsatz wird auch in Menge übernommen
//  14.03.17  AH  Edit  Tolernazen-Von/Bis werden im Material immer gefüllt
//  23.03.17  AH  Neu   AFX "ERe.Unpruefen", "ERe.RecInit"
//  28.03.17  ST  Neu   Userliste, Vornamen in Übersichtsliste hinzugefügt
//  12.04.17  ST  Neu   AFX "Auf.P.ToggleLoeschmarker" hinzugefügt
//  19.04.17  ST  Edit  Rechnungsdruck liest Sprache aus Auftragskopf
//  18.05.17  ST  Neu   Customfelderauswahl in Bestellpositionen hinzugefügt
//  12.06.17  AH  Neu   AFX "Auf.Rechnung.Maske.Check"
//  14.06.17  ST  Edit  Aufpreis AutoGenerierung für Auftragskopf mit Aufpreisgruppe 999
//  08.08.17  ST  Edit  MAtz: Zuordnung von Material prüft auch die Güte
//  08.08.17  ST  Edit  Mat: Kommissionierung prüft Abm + Güte
//  16.08.17  AH  Neu   Einkaufskontrolle kann gelöscht werden
//  16.08.17  AH  Neu   Mat: Invetur.DruckYN
//  16.08.17  AH  Neu   Sta: Skonto
//  21.08.17  AH  Edit  Art.Inventur passt jetzt auch auf NUR Material
//  31.08.17  AH  Neu   "BA1_FM_Data:MengenDifferenz" zum Nachträglichen verändert der FM-Mengen (solange nicht Weiterbearbeitet)
//  01.09.17  AH  Neu   BA-Arbeitsgang "MatProd"
//  04.09.17  AH  Bug   Toleranzen wurden bei Weiterbearbeitungen nicht in den Input der Nachfolgers übernommen
//  13.09.17  AH  Edit  Einkaufskontrolle vom Wareneingang speiechrt Menge in Preis-MEH und NICHT WunschMEH
//  13.09.17  AH  Edit  Wareneingang setzt MEH2 auf PreisMEH
//  20.09.17  AH  Neu   EDI
//  10.10.16  AH  Edit  Ein.Reorg mit Datum
//  23.10.17  AH  Edit  Art.Inventur füt Material ignoriert gelöschte/verkaufte Materialien
//  25.10.17  AH  Neu   RTF-Text in Adressverpackung
//  07.11.17  ST  Neu   AFX "Auf.PasstAuf2Mat" hinzugefügt
//  15.11.17  ST  Neu   Customfelder in Auftragsarten und Warengruppen
//  22.11.17  ST  Bug   Zeiteneingabe: Dauerberechnung bei Änderung von Zeiten
//  23.11.17  ST  Edit  Sammelwarneingang auf Selektionsbasis
//  04.12.17  AH  Neu   AFX "Lib_Nummern:Name"
//  07.12.17  AH  Edit  Userverwaltung auch für Webuser
//  18.12.17  ST  Bug   Materialkommisionierung Direkte Fehlerausgabe per ErrOutput
//  18.12.17  AH  Neu   Schnellsuche kann per Setting deaktiviert werden (dann nur per RETURN/ENTER)
//  18.12.17  AH  Neu   GUI IN CALIBRI
//  03.01.18  AH  Neu   AFX: "Art.Inv.EvtLstDataInit", "Art.Inv.Uebernahme.Einzel.Mat"
//  01.02.18  AH  Edit  Andere Artikeldispo
//  13.02.18  ST  Neu   Workflow: Bedingungen können "Verundet" werden
//  13.02.18  AH  Bug   Bedarf beachtet Mindestbestellmengen
//  26.02.18  ST  Neu   AFX: "Lfs.P.RecInit.Post"
//  01.03.18  ST  Neu   AFX: "Adr.V.Init.Pre", "Adr.V.Init", "Adr.V.EvtLstDataInit"
//  21.03.18  AH  Neu   Erweiterte Analyse
//  19.04.18  ST  Neu   AFX: "Auf.A.DokAnzeigen"
//  18.05.18  ST  Bug   Umfuhrfahrauftrag legt wieder Ausbringungen pro Einsatzmat an
//  28.05.18  ST  Neu   AFX "Auf.A.Init.Pre" und "Auf.A.Init" hinzugefügt
//  28.05.18  ST  Neu   AFX "Auf.A.JumpTo" hinzugefügt
//  29.05.18  ST  Neu   AFX "Lfs.P.Init", "Lfs.P.Init.Pre", "Lfs.P.EvtLstDataInit" hinzugefügt
//  29.05.18  ST  Neu   AFX "Lfs.P.Lfa.Init", "Lfs.P.Lfa.Init.Pre", "Lfs.P.Lfa.EvtLstDataInit" hinzugefügt
//  13.06.18  AH  Neu   BAG.Positionen können eine "Stillstandszeit zum Nachfolger" haben
//  16.06.18  ST  Neu   AFX "SWe.P.Init" % "SWe.P.Init.Pre" hinzugefügt
//  20.06.18  AH  Neu   "Cleanup" für VorlageBAs
//  20.06.18  AH  Neu   AFX "Auf.P.AusText"
//  21.06.18  AH  Bug   Material: Kopiere Analyse in 2. Mesung nahm falsche Analyse
//  21.06.18  AH  Edit  Reorganisationen bis 99.999.999
//  22.06.18  AH  Edit  Datensatz-Suche (Leerzeichen werden ggf. NICHT als Trenner genutzt)
//  25.06.18  AH  Neu   Felder in der BA-Position für Zusatz und Festedauer
//  29.06.18  AH  Edit  BA-Materialauswahl: Filtert auf Lohnkunnde, falls Lohn
//  05.07.18  ST  Edit  Pakenummernauflösung über Betrieb entfernt alle Paketzuordnungen der Nummer
//  09.07.18  AH  Neu   MatStatus für VSB-VK-Rahmen
//  26.07.18  ST  Bug   Filescanner prüft nur angegeben Pfade
//  31.07.18  AH  Neu   LKZ in Eingangsrechnung
//  09.08.18  ST  Edit  Stammbaumdruck auf kombinierter Karte angepasst
//  14.08.18  ST  Edit  SC Filescanner-App zeigt jetzt den Datenbanknamen im Tray Tooltip und im Dialog an
//  30.08.18  ST  Edit  SC Filescanner-App Länge der Dateinamen vergrößert (2000 Zeichen); Fehlermeldung in Protokoll
//  31.08.18  ST  Bug   Artikeldispo Aufruf aus Artikelverwaltung beachtet jetzt das eingegebene Dispodatum
//  31.08.18  ST  Edit  Artikeldispolauf zeigt jetzt Progressbar
//  04.09.18  ST  Neu   Datenexport/-import für Jobservereinträge, Filescanpfade hinzugefügt
//  20.09.18  AH  Neu   zur erweiterten Analyse: Prüfung/Rotfärbung im Wareneingang, SWE und BA-FM
//  20.09.18  AH  Neu   Status für VSB-VK-KonsiRahmenAuftrag
//  26.09.18  AH  Edit  SQL-Updates führen gff. ein Insert nachträglich durch
//  08.10.18  ST  Neu   AFX "MAt.Rsv.RecSave.Pre"
//  09.10.18  ST  Edit  BAG Kopie ohne Fertigmaterialien ermöglicht
//  09.10.18  AH  Bug   BA-Theorie-FM hat keine Ausführungen genommen und nie auf tatsächliche Inputmengen (auch Satzzahl) geachtet
//  18.10.18  AH  Edit  Tauschen im BA-Fahren von Theorie in Echtmaterial übernimmt Kommission
//  18.10.18  AH  Edit  Formulareinträge können mit einem "@USERNAME" versehen werden, damit z.B. spezielle Dirketdrucker angesteuert werden
//  23.10.18  AH  Neu   AFX "BAG.V.RecInit"
//  30.10.18  AH  Neu   AFX "Auf.P.Auswahl.Aufpreise"
//  30.10.18  AH  Neu   Formulareinträge haben auch noch einen Text, der ggf. solche Zeilen haben kann: "y;Epson;@AH@ST@MK@"
//  07.11.18  AH  Neu   BA: bei 1zu1 Gängen kann man die Mat.Nr. vom Input mit der FM tauschen, wenn man nicht etikettieren möchte
//  09.11.18  AH  Neu   AFX "Ein.E.Mat.Pflichtfelder"
//  13.11.18  AH  Neu   AFX "Lfs.P.BM.InsertPos"
//  19.11.18  ST  Edit  Usergruppe "SOA_Server" integriert zur Benutzerabgrenzung von WebApp
//  19.11.18  AH  Neu   AFX "Toleranzkorrektur", "BAG.RecSave.Post"
//  21.11.18  ST  Bug   Etikettendruck im Allgemeinen Wareneingang auf WE Etikettensetting umgebaut
//  26.11.18  AH  Neu   AFX "Ein.P.Auswahl.Pre"
//  28.11.18  AH  Bug   "BA1_Kosten2" ergab FALSE, wenn BA noch offen war (was aber eigentlich OK ist!)
//  28.11.18  AH  Neu   AFX "Mat.Msk.Init.Pre"
//  29.11.18  ST  Neu   Recht Rgt_LFS_Druck_LFA hinzugefügt
//  05.12.18  AH  Neu   AFX "Ofp.Reorg","Auf.Reorg","Ein.Reorg","Mat.Reorg"
//  06.12.18  ST  Bug   Auftrag Matz Plausi wegen Konsigeschäfte umgestellt
//  11.12.18  AH  Neu   AFX "BAG.F.Replace.Pre", "KLimit.Lfs.Druck"
//  12.12.18  AH  Neu   AFX "BAG.F.RefreshIfm"
//  14.12.18  ST  Neu   AFX "ADr.Init" & "Adr.Init.Pre"
//  18.12.18  ST  Neu   Dokumentendruck über SOA Server NUR über Jobserver
//  18.12.18  AH  Neu   Einkaufs-Kalkulation addiert sich in Position
//  18.12.18  AH  Bug   Ressource-Res. errechnete Fenster ggf. falsch
//  18.12.18  AH  Bug   BA-Theroie gegen MEHRERE Mat. tauaschen hatte keine Autoteilung
//  07.01.19  ST  Neu   AFX "Auf.Druck.FM"
//  10.01.19  AH  Neu   Mat.Vererbeanalyse kann auch Erweiterteanalyse
//  14.01.19  AH  Bug   Recdelete hatte bei Buffern falsche RecId
//  18.01.19  AH  Neu   BA-Position wird wenn "BAG.P.Plan.ManuellYN" NICHt mit autoamtischer Laufzeit gefüllt
//  21.01.19  AH  Bug   BA aus Vorlage erstellen, achtete nicht auf Autoteilung
//  21.01.19  AH  Neu   AFX "Mat.WE.RecSave.Post"
//  29.01.19  AH  Neu   AFX "Lfs.ErzeugeAusLFA"
//  22.02.19  AH  Neu   AFX "BAG.FM.Set.MatABemerkung"
//  26.02.19  ST  Neu   AFX "Adr.RecInit"
//  28.02.19  ST  Bug   LFsStorno auf Konsi Lfs -> Materialprüfung auf gelöscht deaktiviert
//  28.02.19  ST  Neu   AFX "Betrieb.AusLfsMaske"
//  05.03.19  AH  Neu   BA-Abschluss schließt Vorgänger-Fahren automatisch ab
//  06.03.19  AH  Neu   ERe-Excel-Import/Export
//  07.03.19  AH  Bug   BA-Kopieren verlor bei VSB-Schritten das max. Zeitfenster
//  08.03.19  AH  Neu   AFX "Mat.A.NewMatz"
//  18.03.19  AH  Neu   AFX "Auf.P.Drop.Mat"
//  21.03.19  ST  Neu   AFX "Dlg_PDFPreview.ShowPDF"
//  10.04.19  AH  Neu   AFX "Auf.A.RecalcAll" + "BAG.Set.Auf.Aktion"
//  18.04.19  AH  Neu   Workflows können nun auch per Mail versendet werden
//  08.05.19  ST  Edit  Fertigmeldung auf Fahraufträge für Rahmenmaterial möglich
//  15.05.19  ST  Neu   AFX "Art.Inv.Loesche.MatOhneInv"
//  28.05.19  AH  Neu   Projekt-Positionen mit SubPositionen
//  07.06.19  AH  Neu   AFX "BAG.V.RecSave", "ERe.MatAktionen"#
//  02.07.19  ST  Edit  Filescanner prüft Pfad vor hinzufügen; Fehlerausgabe verbessert
//  05.07.19  AH  Neu   AFX "Lfs.P.Verbuchen.Check" "Lfs.P.VLDAW.Verbuchen.Check" "BAG.P.AutoVSB.Check"
//  15.07.19  AH  Edit  Adressn: Finanzmaske ohne Bruttos
//  18.07.19  AH  Edit  BessereLFA: Summierung beim Auftrag in "In Prod" sind nur Restmengen und ohne LFA; LFS zubtrahieren aus "VSB-Menge"
//  26.07.19  AH  Edit  neue Felder für Bestellte Mengen im Auftrag (also bei Strecke) und entsprechend Kreditlimitprüfungen
//  29.07.19  AH  Neu   AFX "Auf.P.Replace.Mengenaenderung" , "Ein.P.Replace.Mengenaenderung"
//  31.07.19  AH  Neu   Adr-Verpackung aus Bestellpos. erzeugbar
//  08.08.19  AH  Neu   Workflows manuell aus den Hauptbereichen startbar
//  13.08.19  ST  Edit  SOA / SOAP Verbindungen per IPV6 priorisiert
//  11.10.19  AH  Neu   Quickbuttons für Listen
//  14.10.19  AH  Neu   AFX "BAG.FM.Entfernen.Pre"
//  16.10.19  AH  Bug   BA-Kosten Recalc ignorierte geplante Schrotte
//  17.10.19  AH  Neu   Material-Entsthungskette
//  24.10.19  AH  Neu   AFX "Auf.Rechnung.Verbucht.PreMark"
//  29.10.19  AH  Neu   AFX "Lfs.P.Verbuchen.Rueck_Mat"
//  05.11.19  AH  Neu   Controlling für Auftrag-,Angebot-,Bestellerfassung und Graph
//  25.11.19  AH  Neu   AFX "Auf.P.RefreshIfm.Post"
//  09.12.19  AH  Neu   AFX "BA1.FM.Maske.EvtChanged.Post"
//  11.12.19  AH  Neu   Sortierschlüssel mit Prozeduren
//  12.12.19  AH  Neu   Custom für Rek.Positionen
//  13.12.19  AH  Neu   "BelegeKommissionsDaten" kann V_erpackung
//  09.01.20  TM  Neu   AFX LFS.Print.Lohnformular
//  09.01.20  TM  Neu   AFX LFS.Print.Freistellung
//  07.01.20  AH  Neu   externes Tool "CmdTwain" Unterstützung
//  15.01.20  AH  Edit  KgMM im Material wird bei genullten Karten NICHT neu berechnet
//  20.01.20  AH  Neu   Adr-Verpackungs-Aufpreise
//  23.01.20  AH  Neu   Kommando "Excelexport" + "Excelimport"
//  03.02.20  AH  Neu   Artikelcharge summiert Kommis30.04.2020sionerte Menge, Verfügbar + Aufrest Summen in Artikel per Settings steuerbar
//  07.02.20  AH  Neu   Pak-Maske mit Netto UND Bruttogewicht
//  07.02.20  AH  Neu   LFA-Maske kann auch interne Ressosurcen
//  10.02.20  AH  Fix   Sortierschlüssel für Prozeduren können nun auch gleichen Basiskey nutzen
//  10.02.20  AH  Fix   VSB-EK-Material Fahren löscht nun alte Reservierung richtig (wurde wegen dem WE auf das VSB-Mat umgebucht und hatte darum andere MatNr)
//  17.02.20  AH  Neu   AFX "Ein.P.EvtFocusTerm"
//  17.02.20  AH  Neu   Setting, dass Fahrauftragsreservierung nicht in Material summiert wird
//  02.02.20  AH  Fix   Fix APPOFF, LFA-Theorie-FM f+ür Artikel
//  03.03.20  AH  Neu   AFX "Erl.Insert"
//  12.03.20  AH  Neu   BA-Abschluß und BA-Neucalc verändern ggf. Erlöse, die diese Materialien fakturiert haben
//  13.03.20  AH  Neu   AFX "Art.Data.Bewegung"
//  27.03.20  AH  Neu   Kommentare in Anhängen, Workflows an Anhängen
//  29.03.20  AH  Neu   dynamischer WoF
//  01.04.20  AH  Neu   Aktivität "Diskussion"
//  02.04.20  AH  Fix   Art-Dispo zu Verfügbar + Rest
//  09.04.20  AH  Neu   Sprung zum BA in den BA-Planungs-Tools
//  14.04.20  AH  Neu   Quickbuttons im BA-Combo-Maske
//  15.04.20  AH  Neu   Zahlungsbedinungung mit EK/VK-Sperre
//  23.04.20  AH  Fix   BA-Fertigungszahl beim Walzen
//  06.05.20  AH  Neu   OPs mit Löschfeldern
//  11.05.20  AH  Neu   BA-Funktion: neue Pos. einfügen
//  18.05.20  ST  Neu   Grobplanung EvtInit Anker & Customfeldmenü hinzugefügt
//  22.05.20  AH  Neu   Möglichkeit Customseiten in eine Verwaltung zu laden + PageUp/Down per App_Main
//  25.05.20  AH  Neu   Termintypen Verwaltung
//  28.05.20  AH  Neu   Vorgabetexte können RTF sein, RTF-Auswahl in Berichten
//  02.06.20  AH  Fix   Aktivitäten Meldungen
//  05.06.20  AH  Neu   AFX "Ost.ProcessStack.Unbekannt", "Auf.A.Entfernen.Post", "Auf.A.NeuAnlegenPost"
//  16.06.20  AH  Neu   eigene User für "SOA_SYNC" und "SOA_JOB", Lizenzzählung angepasst
//  19.06.20  AH  Neu   "Set.BA.Ziel.AktivJN"
//  03.07.20  AH  Neu   PDFs vom PrintServer kommen über Service und NICHT mehr per SQL-Connection !!!
//  21.07.20  ST  Neu   AFX "BA1.IO.I.AW.LstDInit"
//  20.08.20  ST  Neu   Adr_K_Data:Kreditlimit opt Argument "aErr" hinzugefügt
//  25.08.20  AH  Neu   im BA können Outputs nun "tunneln" und Fertigungen in andere Positionen verschieben
//  26.08.20  AH  Neu   Kurzinfo-Masken
//  28.08.20  AH  Neu   Info Adr-Verpackungen an Artikel
//  01.09.20  ST  Neu   "Lib_FileIO:CreateFullPath" funktioniert jetzt auch mit Serververzeichnissen
//  09.09.20  AH  Neu   Customrechte
//  28.09.20  AH  Neu   LFS-Erfassung mit Markierungen + markierte löschen
//  29.09.20  AH  Neu   AFX "Lfs.Init.Pre"
//  12.10.20  AH  Neu   AFX "Mat.Mark.Sel"
//  16.10.20  AH  Neu   Unterlagen mit Artikelbindung
//  10.11.20  ST  Neu   ExcelExport/Import für Kreditlimits und Anschriften
//  18.11.20  ST  Neu   Materialkartendruck für markierte Karten
//  23.11.20  AH  Neu   AFX "BAG.Kosten.Post"
//  23.11.20  AH  Neu   Auftrags-AbrufVerbuchen setzt Löschmakrer am Rahmen
//  23.11.20  AH  Neu   AFX "BAG.P.RecSave.VorSave"
//  02.12.20  AH  Neu   Vorlage-BAs mit Feld "WandelFunktion"
//  01.02.21  AH  Neu   Customauswahlfelder mit Kürzel und exklusiven Inhalt
//  09.02.21  AH  Neu   AFX "Auf.Rechnung.NachPrintForm"
//  19.02.21  ST  Neu   AFX "BAG.Init.Pre" & "BAG.Init"
//  24.02.21  AH  Neu   Ansprechpartner nach Outlook
//  02.03.21  ST  Neu   AFX "Lys_Msk_Main"
//  16.03.21  ST  Fix   Keine doppelten Ausführungen bei FM Vorbeleigung
//  25.03.21  AH  Edit  BA-Abschluss löscht/entlöscht VSB-Arbeitsgänge
//  31.03.21  AH  Neu   LFA fragt Abschlussdatum ab
//  31.03.21  AH  Neu   Druck Proformarechnung schreibt sich in Aktionsliste
//  12.04.21  AH  Neu   AFX "BAG.FM.Verbuchen.Inner.Post"
//  22.04.21  AH  Neu   AFX "Ein.E.UpdateMaterial"
//  26.04.21  AH  Neu   AFX "Auf.P.Obf.Filter"
//  27.04.21  ST  Fix   Betriebsmenü: Shortcut für Nettoverwiegung korrigiert
//  03.05.21  AH  Neu   AFX "BAG.FM.Verbuchen.Etikettenlauf"
//  04.05.21  ST  Fix   BAG FM: "VererbeReservierungen" fragt bei MDE Nutzung nicht mehr nach, sondern übernimmt die Reservierungen
//  18.05.21  AH  Neu   AFX "Mat.Rsv.AufPos.Inner"
//  25.05.21  ST  Fix   Mat_Etikett leert jetzt bei Init die Globalen Variablen
//  07.07.21  AH  Neu   Dichtenerrechnunge auch über Güte
//  08.07.21  AH  Neu   Sync-Protokoll zunächst übers RAM
//  21.07.21  ST  Fix   Jobserver gibt jetzt Fehlermeldung aus, wenn Printserver nicht erreichbar
//  26.07.21  AH  Neu   EK-Konsi-Material kann in BA eingesetzt werden
//  27.07.21  ST  Neu   AFX "Rso.Init.Pre" und "Rso.Init.Pre" hinzugefügt
//  28.07.21  AH  Neu   AFX "BA1.ImportBA.Post" , AFX "BA1.BAGVorlageDaten"
//  28.07.21  AH  Neu   BA Kopieren
//  03.09.21  MR  Neu   Quickbuttons für Reklamationsverwaltung
//  07.09.21  AH  Edit  MATZ fragt Splittung ab je nach Setting
//  08.09.21  AH  Neu   Markierungselektion für Mat, Auf, Best kann mehrere Güten + Obfs
//  08.09.21  MR  Neu   AFX "VsP.Init" & "VsP.Init.Pre"
//  08.09.21  AH  Neu   AFX "ApL.Autogenerieren"
//  09.09.21  MR  Neu   AFX "Mat.Mark.Sel.Default" & "Ein.P.Mark.Sel.Default" & "Auf.P.Mark.Sel.Default"
//  13.09.21  AH  Neu   AFX "BAG.FM.ChooseMultiInput"
//  14.09.21  AH  Neu   RecList-Spalten direkt an Anfang oder Ende
//  21.09.21  ST  Neu   Versandmodul: Druck Verladeanweisungen
//  21.09.21  MR  Neu   Quickbuttons für Projektverwaltung
//  24.09.21  MR  Fix   Bug bei der Selektion von Anfragen in der Ein_P_Mar_Sel:StartSel
//  27.09.21  MR  Neu   Excel Import/Export in VsP
//  29.09.21  MR  Neu   AFX "Vsd.Verbuchen.Post"
//  01.10.21  MR  Neu   AFX "Vsd.RecInit"
//  04.10.21  MR  Edit  Änderung in Vsd_Main: Nach verbuchen durch BA.Pos loopen und füe jede BA.Pos print aufrufen
//  04.10.21  MR  Neu   VsP_Main:EvtLstDataInit Hinzufügen von GV.Alpha.06 & GV.Int.01  (2166/42/1)
//  05.10.21  AH  Edit  "Auf_DataPasstAuf2Mat" resultiert INT statt LOGIC
//  05.10.21  ST  Neu   AFX "Ein.E.Mat.RecSave.Post"
//  08.10.21  ST  Neu   Fertigmeldung vor "Versand" nutzt Zielanschrift aus Auftrag der Kommission (2166/99)
//  13.10.21  MR  Neu   Sub Vsd_Main:DruckLFS (Ticket 2166/55/2)
//  14.10.21  MR  Neu   AFX "VsP_Mark_Sel:VsP.Mark.Sel.Default" (Ticket 2166/58/1)
//  20.10.21  ST  Fix   "PDF an Outlook" Delay nach COM CLOSE
//  26.10.21  ST  Neu   AFX "Betrieb.BagVWStorno"
//  26.10.21  MR  Edit  EMA:BEST und EMA:ANF in F_SQL
//  27.10.21  AH  Edit  BA-Abschluss und BA-FM-Storno kann rekursiv arbeiten; bei FM-Storno werden die Mat-FM-Aktionen entfernt
//  02.11.21  MR  Neu   AFX "Obf.RecSave.Pre"
//  02.11.21  ST  Fix   EinzelringFM räumt Ausführungen korrekt auf
//  04.11.21  AH  Neu   AFX "EKK.Update""
//  08.11.21  MR  Neu   Quickbuttons für VersandPool
//  09.11.21  AH  Neu   AFX "BAG.F.UpdateOutput.Post"
//  10.11.21  AH  Edit  LIZENZZÄHLUNG : pro User+Pc+Session zählen 2 Anmeldungen als 1 Lizenz
//  11.11.21  MR  Neu   AFX Erl.Init.Pre
//  12.11.21  ST  Neu   Anzahl der selektierten Datensätze im Fenstertitel
//  12.11.21  MR  Neu   AFX Mat.Rsv.Init.Pre
//  12.11.21  ST  Fix   Drag'n Drop AufP -> BAGFert: Ausführungen werden korrekt übernommen
//  15.11.21  AH  Neu   im BA : Automatischer Versand+VSB Anlage
//  16.11.21  MR  Neu   AFX OfP.EvtLstDataInit & OfP.Init.Pre Projekt(2166/176)
//  23.11.21  AH  Neu   AFX "BAG.FM.ChooseInput", "BAG.FM.Start.Maske"
//  24.11.21  ST  Neu   Hilfeseiten können auch auf http Seiten verlinken
//  02.12.21  MR  Fix   Aktiosnamrker D nicht nur für 'Bestellung Rest' sondern auch für 'Bestellung'
//  21.12.21  ST  Neu   Erlös- und Eigangsrechnungsmarkierung per Serienmarkierung hinzugefügt
//  04.01.22  AH  Neu   AFX "BAG.FM.GetMaskenName"
//  12.01.22  ST  Neu   OFP Ablage: Serienmarkierung hinzugefügt
//  12.01.22  ST  Neu   OFP Ablage: "Zurückholen aus Ablage" jetzt auch mit makierten Sätzen möglich
//  14.01.22  MR  Neu   Bugfix Änderung Angebot anch Auftrag aktualisiert Feld nicht (2346/4)
//  27.01.22  AH  Neu   Versandpool mit Kundenstichwort, Strukturanpassung der Ablage, BAs setzen auch schon KdNr
//  28.01.22  AH  Neu   Setting PDF-Vorschau kann sich nach Druck, PDF, Mail direkt schliesen
//  28.01.22  AH  Neu   Setting "Set.KLP.OhneAuf" für Kreditlimitberechnung OHNE jeden Auftragsbestand (also nur OPs)
//  01.02.22  AH  Fix   BA.FM löschen erhöht ggf. Versandpooolmengen
//  01.02.22  MR  Edit  BA_Fertigmelden:AbschlussPos Prozentanteil in Messagebox beim BA-Abschluss (2166/136)
//  02.02.22  ST  Fix   Materialmarkierung für Abwertung achtet jetzt auf das Erzeuchungsdatum
//  11.02.22  ST  Fix   Versandpoolfilter: Kundennummer korrigiert
//  16.02.22  DS  Neu   Integration von C16_DatenstrukturDif (automatisches Anzeigen von nötigen ALTER TABLE Befehlen), parallel zu bestehendem Mechanismus
//  15.02.22  MR  Neu   Überprüfung nach gültiger Email
//  21.02.22  AH  Neu   Menüpunkt im LFS "Kosten neu berechnen"
//  22.02.22  ST  Fix   Fehler bei manueller LfsErfassung als Betriebsuser, bei Anzeige des eingegebenen Materials gefixed
//  23.02.22  AH  Neu   Doppelklick auf gesperrten Felder kopiert in die Zwischenablage
//  28.02.22  ST  Bug   BAG-Fertigmeldung: Stückzahlprüfung zeigt nicht nur Pflichtfeldangabe an, sondern prüft auch auch wieder
//  03.03.22  ST  Edit  Maerialneubewertung vererbt Preis auch an Restkarten
//  04.03.22  DS  Neu   Automatische Git-Integration ("Auto-Git") aktiviert
//  09.03.22  AH  Neu   AFX "BAG.Kosten.Save204.Post"
//  14.03.22  AH  Neu   Jobs vom Job-Server können in Gruppen eingeteilt werden und so durch verschiedene Job-Server abgearbeitet werden
//  15.03.22  AH  Neu   BA-FM stornieren tauscht beo 1zu1-Arbeitsgängen ggf. MatNr. zurück
//  15.03.22  AH  Neu   BA-Kopf hat einen Text
//  15.03.22  MR  Bug   Listenselektierung für Adressen selektiert nun nicht nur nach Stichwort
//  21.03.22  AH  Bug   Eingangsrechnujngsddatum/Nummer wird in Kinder-Materialkarten NICHT gesetzt
//  22.03.22  ST  Bug   Jobserver per SOA: mögliches MemLeak bei RecBuf 905 gefixed
//  25.03.22  AH  Neu   BA: AutoVersand+VpG+VSB auch für Vorlagen; Gütensufen, Etiketten, Unterlagen, Zeugnisse mit Mehrsprachigkeit
//  11.04.22  MR  Bug   Möglichkeit zur Überprüfung von mehreren E-Mail-Adressen
//  14.04.22  AH  Neu   Pakete mit Inhaltangaben
//  26.04.22  ST  Edit  BA: AutoVPO übernimmt Reservierhungsdaten aus Vorfertigung
//  29.04.22  AH  Neu   Pakete können in den Versandpool laufene
//  03.05.22  MR  Bug   Verhinderung des Fehlers beim Editieren des Vorgangstyps einer Bestellung (2228/67)
//  03.05.22  AH  Edit  Lohn-VSB-Schritte werden nicht mehr als Eingeplant in den Auftrag addiert, sondern nur die BA-Lohn-Aktion
//  05.05.22  AH  Neu   AFX "BAG.P.SetStatus"
//  18.05.22  AH  Neu   BA Spalt-Spulen, Material mit Spulenbreite
//  19.05.22  AH  Fix   Abrufmengenedit (Abruf überliefert Rahmen etc. - siehe HOW 2224/38)
//  13.06.22  AH  Neu   Setting: "Set.BA.LohnVSBwieVK", damit Lohn-VSB-Schritte wie "damals" gerechnet werden
//  14.06.22  AH  Neu   Materialtyp: Rohne + FlachRing; AFX "Wgr.WertBlockenBeiTyp"
//  22.06.22  ST  Edit  Fehlermeldung bei Dokumenendruck erweitert (falsches Seitenformat, etc.)
//  22.06.22  AH  Fix   Erlös-Storno toggelte den Löschmarker am Auftrag fröhlich
//  28.06.22  MR  Fix   Refresh Problem beim wechsel von eRe zu EKK
//  28.06.22  MR  Neu   Hinzufügen der Möglichkeit zum speichern von Arbeitsschritten über den MDE
//  29.06.22  MR  Neu   AFX "Lfs.PreDruck.VLDAW"
//  05.07.22  AH  Fix   besseres Abfangen von Deadlocks (Teil 1: BA + LFS)
//  06.07.22  AH  FIX   Ändern vom Mat.Status rechnete falsch in Artikelbestände
//  07.07.22  MR  Fix   Lib_Soa:ReadNummer + Deadlockfix in aufrufenden Funktionen Prz: BA1_Data, BA1_Data_SOA, SVC_000045, SVC_SWe_000001, SVC_WEBAPP_Action
//  22-07-11  AH  Neu   AFX "BAG.P.RefreshIfm.Post"
//  13.07.22  MR  Fix   Bug im BA Kopieren welcher die BAG.BuchungsAlgoNr  beim kopieren immer auf 0 setzt
//  22-07-14  AH  Neu   AFX "BAG.Plan.Data.SetTermin.Post"
//  14.07.22  MR  Fix   Bug in BA1_FM_Data_SOA:ReadBagData, welcher dazu führt das Einsatzmaterialien nicht genau zugeordnet werden können und dann auch mit der Ausbringung matchen.
//  22-07-14  AH  Neu   TimeStamp in allen Sätzen
//  22-08-07  MR  Neu   Erweiterung der Lib_Json, um die Möglichkeit für ein Json eine tabellarische Darstellung zu erzeugen
//  22-08-08  ST  Edit  Co2 Berechnung bei Faktura: CO2 Anteil des Schrottes wird dem CO2 EK zugeschlagen
//  22-08-08  AH  Neu   AFX "ERe.Data.RealKosten.Vbk.K.Loop"
//  22-08-08  MR  Fix   Verhinderung von Fehlermledung durch returnVal im Wareneingang (MDE)
//  22-08-16  ST  Neu   Eingang auf Sammelwareneingng erledigt auf Nachfrage den Avisierungseintrag
//  22-08-17  AH  Neu   AFX "Erl.K.Insert.Pre", ""Erl.K.Replace.Pre"
//  22-08-19  MR  Fix   Ein_P_Mark_Sel Gleichzeitge Auswahl von Anfrage sowie Angebot hat nicht funktioniert
//  22-08-23  MR  Neu   Mdi.Template2022 als Vorlage für die Erstellung eines Frames
//  22-08-30  MR  Fix   Abweichende Funktionsargumente bei Serienmarkierung in OfP.Mark.Sel
//  22-09-01  AH  Neu   AFX "BAG.F.Data.CopyAufToVpg"
//  22-09-01  AH  Edit  PLZ 12 stellig
//  22-09-12  ST  Edit  Löschen von Betriebsaufträgen prüft jetzt den FM Status auf Stornierungen und lässt Löschen zu
//  22-09-13  ST  New   Angebotspositionensnummern können verändert werden
//  22-09-30  MR  Neu   L_Usr_800005 zur Rechteausgabe von ST für HP erstellt
//  22-10-09  MR  Fix   Emailüberprüfung in Adressen
//  22-10-12  MR  Neu   Filter auf gesetzte Anker (+ SR)
//  22-10-16  MR  Fix   SVC_WebAppAction Fix bug bei WE + Kommissionierung
//  22-10-27  AH  Neu   AFX "Mat.WirdVkVSB"
//  22-11-03  ST  Fix   Transaktionsfehler bei Entfernen von VSB/EK Materialien aus Betriebsaufträgen korrigiert
//  22-11-08  ST  Fix   Verbindlichkeitskontierung: Setting für Dezimalstellen der Gewichtsangabe wird jetzt berücksichtigt
//  22-11-08  MR  Neu   MDE Teilverladung
//  22-11-15  MR  Fix   Nachtragen der Ein.E.Position für WE über MDE
//  22-11-21  MR  Neu   WOF Trigger für Adressen
//  22-11-22  ST  Fix   Betriebsauftrags FM: Materialbemerkung bei FM ohne Verpackung wieder io
//  22-11-28  ST  Neu   AFX "Ere.RecSave.Post"
//  22-12-01  ST  Fix   Betriebsauftragsabschluss: Abschlussdatum anhand der letzten FM korrigiert
//  22-12-06  AH  Neu   AFX "Lfs.P.Rueck.Verbuchen.Mat.Pre", AFX "Adr.K.VersichertAm", Bestimmung der Kreditsumme über zentrale Funktion
//  22-12-08  MK  Neu   Neues Form Kürzel "UETK" im Bereich 800. Stellt im PS das UsrObj zur Verfügung.
//  22-12-20  AH  Edit  BA: MEH-Wechsel werden nur INNERHALB der Pos gemacht
//  23-01-02  MR  Neu   AFX "Lfs.LFA.Data.GesamtFM.Post" zum eingreifen bei Verbuchung von Lohnfahraufträgen
//  23-01-02  MR  Fix   Fehler bei der Selektion von Sachbearbeitern in Kombination mit Anfragen in den Bestellungen
//  23-01-05  MR  Fix   Bug beim löschen von VsP-Einträgen
//  23-01-23  AH  Edit  BA: MEH-Wechsel bewertet Mat-EK und Kosten richtig
//  23-01-24  AH  Edit  EK-Kalkulationen die Rückstellungen erzeugen, werden als Kosten ins MatAktion geschrieben; nur Hauswährung
//  23-01-24  AH  Edit  Eingangsrechnungen können auch EKKs anderer Lieferanten zugeordnet werden
//  23-01-24  MR  Fix   Fix beim holen von Anschriften im MDE
//  23-01-26  MR  Edit  Bestandsänderung kann jetzt auch die Menge verändern 2465/17
//  23-01-31  MR  Edit  optionaler Etikettendruck nach Paketauflösung (MDE-Schnittstelle) 2436/415/4
//  23-02-01  ST  Fix   Dokumentenvorschau in der Adressverwaltung bei Anzeige deaktiviert
//  23-02-03  MR  Fix   Beachtung von gelöschten Eingängen in EDI_Analyse 2469/2
//  23-02-06  MR  Neu   MDE Schnittstelle um Reservierungen aus Aufträgen zu löschen + AFX WebApp.Auf.Post.Erledigt
//  23-02-08  ST  Neu   Liefermengen werden bei der manuellen Lieferscheinpositionserfassung nach Auwahl aus Materialkarte vorbelegt
//  23-02-17  MR  Edit  MDE Splitten kann jetzt auch einen Wert für die Länge entgegennehmen
//  23-02-21  MR  Fix   MDE VSB Datum wurde beim eingagn immer gelöscht 2202/104
//  23-02-27  AH  Neu   Materialkarten fixen automatisch Netto<=Bruttogewicht
//  23-02-28  AH  Neu   Setting für Bestelltermin aus Zusagetermin (Set.Mat.BestTermin)
//  23-03-02  AH  Neu   AFX "BAG.F.Detail.Init"
//  23-03-03  ST  Fix   Auftragsverwaltung/Gütenauswahl per F9 korrigiert#
//  23-03-07  MR  Fix   TimeStamp Problem in Benutzer trotz sql_syncone 800
//  23-03-17  AH  Edit  EK-Vorlkalkulationen werden bei Rückstellung auf den GrundEK addiert, NICHT Kosten
//  23-03-21  MR  Fix   Lib_Mark:Reset hatte immer den letzten Eintrag bzw dem aus dem vorhandenem Scope im Buffer und überschrieb die Selektion damit
//  05-04-23  DB  Fix   BA1_Vorlage:_CopyBAFert: Proj. 2470/27: Ausführungen, die fertiggemeldet wurden (Fertigmeldung <> 0), sollen nicht kopiert werden
//  23-04-06  MR  Fix   Erweiterung der BreitenToleranz in BA1_PZ_Messerbau außerdem wurde Zeile 6096 in der App_Main:EvtInit auskommentiert, da Folgefehler aus Änderung (2470/26)
//  23-04-12  MR  Fix   Erweiterung der Ein_P_Mark_Sel um Rid+Rad Vorbelegung
//  23-04-20  MR  Neu   Druckerzonen + Erweiterung der Druckaufträge an JobServer mit der DruckerID
//  23-04-21  MR  Neu   Neuer Anker Mat.Rsv.EvtLstDataInit
//  23-04-24  ST  Neu   Customfelder in Wareneingangsverwaltung
//  23-05-04  MK  Neu   Usr->Menü->Druck=> Mitarbeiterkarte QR; Usr_Subs neu; Usr_Main angepasst; Neuer Formulartype 'ETK'
//  23-05-04  ST  Edit  Änderung am Wareneingang ändert den Materiallagerlatz nur noch, wenn das Material keinen Lagerplatz hinterlegt hatte
//  23-05-15  DB  Edit  Lib_GuiDynamisch:CopyObject soll RecList kopieren können
//  23-05-20  MR  Edit  Hashfunktion für die Passwörter von Webusern von SHA-1 auf SHA-512 hochgesetzt; Usr.Passwort auf 128 Zeichen erhöht; ChangePassword in SVC_WebAppAction
//  23-05-30  ST  Fix   Eingang auf Sammelwareneingang setzt Mat.Übernahmedatum nur noch bei Eigenmaterialeingängen
//  23-06-02  MR  Fix   MDE Problem beim Druck von mehreren Etiketten aufeinmal
//  23-06-05  ST  Neu   Einkauf: VSB Eingang auf Abweichende Lageradresse/Anschrift setzt MAterial in Versandpool
//  23-06-06  MR  Fix   Fehler von Mengeberechnung bei Artikeln mit veränderten Abmessungen und MEH= 'm' beim Splitten. Vorher wurde immer mit Stk gerechnet
//  23-06-12  ST  Edit  MDE: Wareneingang auf VSB sperrt EK Eintrag grundsätzlich
//  23-06-14  MR  Fix   Bug bei leeren MatKarten nach Splitten über C16 + MDe
//  23-06-19  ST  Neu   AFX "Lys.Msk.Init.Pre" + "Lys.Msk.Init"
//  23-06-21  ST  Neu   Customfelder in Versandverwaltung
//  23-06-23  MR  Edit  MDE Limitgrenze bei Kommissionierung kann über para an Controller aufgehoben werden + Fehlerbehbeung beim ziehen der Matnummer für Etikettendruck in Kommission
//  23-07-04  MR  Fix   Fehler beim Versuch der Editierung eines BA-Einsatzes 2396/161
//  23-07-06  ST  Neu   Excel-Export/-Import für Nummernkreise hinzugefügt
//  23-07-06  ST  Neu   Anzeige der Referenzmengen bei Mateiral-Reservierungsübernahme
//  23-07-12  ST  Neu   AFX "Ere.Ekk.Init.Pre" + "Ere.Ekk.EvtDstDataInit"
//  23-07-27  AH  Neu   AFX "Auf.Rechnung.Vorbereiten.Post"
//  23-07-28  SR  Neu   AFX "BAG.P.Data.Operation"
//  23-07-28  MR  Neu   MDE Versionierung bei Breaking Changes im STD. Erzeugt jetzt eine Meldung nach entsprechendem STD-Update
//  23-08-01  MR  Neu   Erweiterte Fehlermeldung m. Druckereigenschaften b. fehlerh. Papierformat + AFX "Print.Custom.InnerPrint" f. Custom InnerPrint Routinen
//  23-08-03  ST  Edit  EDI Import EinkaufVSB/Analysen: keine Doppeltprüfung auf Änderung der Coilnummer/Werksnummer bei ImportIdentifikation per Werksnummer oder Coilnummer
//  23-08-21  ST  Fix   "todo-Meldung" bei Mengenumwandlung z.B. KG -> L  ausgebaut; führt bei Fehleingaben zum Blocker von SC, wenn Umrechnungsfehler in Zgr aufftaucht
//  23-08-22  MR  Neu   Sonderfunktionen können jetzt auch Parameter als Alpha entgegennehmen
main begin end;


