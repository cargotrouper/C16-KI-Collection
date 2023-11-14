@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Messages
//                  OHNE E_R_G
//  Info
//      22.06.2012  AI  Msg poppen aus MDI auf
//
// _WinIcoApplication, _WinIcoError,_WinIcoInformation,
// _WinIcoWarning,_WinIcoQuestion
//
// _WinDialogOk, _WinDialogOkCancel, _WinDialogYesNo,
// _WinDialogYesNoCancel
//
//
// ERGEBNIS:
// _WinIdOk, _WinIdCancel, _WinIdYes, _WinIdNo
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  17.04.2018  ST  Bei Jobserver oder SOA, dann "msg" in "Error" mwandeln
//  30.05.2018  AH  "ParseMsg"
//  19.08.2020  ST  sub "Messages_Msg" Begrenzung der Ausgabelänge auf 500 Zeichen
//  21.01.2022  DS  Kritische Zeile verkürzt (längste Zeile im Dokument machte Probleme bei git Import in C16)
//  2023-03-16  DS  Messages_Msg_WrapperWithLog für globales Logging, entsprechender Test
//
//  Subprozeduren:
//    Fehlertext
//    ParseMsg
//    Messages_Msg
//    Messages_Msg_WrapperWithLog
//    test_MsgErr_MsgWarn_MsgInfo
//
//    MAIN: Benutzungsbeispiele zum Testen
//
//========================================================================
//
// TODO: 99=19999 usw mal ändern
//
@I:Def_Global


define begin
  cProtokolldatei : 'c:\BC_ERROR.TXT'
end;


//========================================================================
//  Fehlertext
//
//========================================================================
sub Fehlertext(aNr : int) : alpha;
local begin
  vA  : alpha(250);
end;
begin

  case aNr of

    // allgemeine Fragen
    000001 :  vA # 'Q:Diesen Eintrag wirklich löschen?';
    000002 :  vA # 'Q:Eingabe verwerfen?';
    000003 :  vA # 'Q:Änderungen verwerfen?';
    000004 :  vA # 'Q:Komplette Erfassung verwerfen?';
    000005 :  vA # 'Q:Weitere Positionen erfassen?';
    000006 :  vA # 'Q:Feldinhalte von vorheriger Position übernehmen?';
    000007 :  vA # 'Q:Diesen Eintrag wirklich zurückholen?';
    000008 :  vA # 'Q:Wollen Sie den Löschmarker wirklich umsetzen?';
    000009 :  vA # 'Q:Wollen Sie diese Daten für einen weiteren neuen Eintrag nutzen?';
    000020 :  vA # 'Q:Feldinhalte dieser Position als Vorbelegung übernehmen?';
    000050 :  vA # 'Q:Alle markierten Einträge wirklich löschen?';
    000099 :  vA # '%1%';


    // Fehler beim Benutzerpasswortwechsel
    000010 :  vA # 'E:Die Passwörter stimmen nicht überein!';
    000011 :  vA # 'E:Das alte Passwort stimmt nicht!';
    000012 :  vA # 'I:Ihr Passwort wurde erfolgreich geändert!';

    // allgemeine Fehler
    001001 :  vA # 'E:#%1%:Satz ist gesperrt durch Benutzer: '+LockedBy;
    001002 :  vA # 'E:#%1%:Kein eindeutiger Zugriff möglich!';
    001003 :  vA # 'E:#%1%:Satz nicht gefunden!';
    001004 :  vA # 'E:#%1%:Keine weiteren Datensätze vorhanden!';
    001005 :  vA # 'E:#%1%:Datei leer/kein Folgesatz vorhanden!';
    001006 :  vA # 'E:#%1%:Satz existiert bereits!';
    001007 :  vA # 'E:#%1%:Satz ist nicht gesperrt!';
    001008 :  vA # 'E:#%1%:Abbruch durch Benutzer!';
    001010 :  vA # 'E:#%1%:Satz ist DEADLOCKED!!!';
    001011 :  vA # 'E:#%1%:%2% konnte nicht gelesen werden!';
    001012 :  vA # 'E:#%1%:Satz konnte nicht gespeichert werden!';
    001013 :  vA # 'E:Keine Datensätze markiert.';
    001014 :  vA # 'E:#%1%:Satz konnte nicht gesperrt werden!';
    001050 :  vA # 'Sie haben bereits einen Datensatz dieser Tabelle im Änderungsmodus!%CR%Bitte diesen Satz erst wieder frei geben oder speichern.';

    001100 :  vA # 'E:#Transaktionsfehler: DOPPELSTART!';
    001101 :  vA # 'E:#Transaktionsfehler: Nichts zum Beenden!';
    001102 :  vA # 'E:#Transaktionsfehler: Nichts zum Abbrechen!';
    001103 :  vA # 'E:#Transaktionsfehler: Offene Transaktion bei Programmende!!!%CR%Die letzten Änderungen wurden NICHT gespeichert!!!%CR%BITTE UMGEHEND DEN HERSTELLER KONTAKTIEREN!';
    001104 :  vA # 'E:#Transaktionsfehler: Offene Transaktion !!!%CR%Die letzten Änderungen wurden evtl. FALSCH VERBUCHT!!!%CR%BITTE UMGEHEND DEN HERSTELLER KONTAKTIEREN!';

    001200 :  vA # '%1% muss angegeben werden!';
    001201 :  vA # '%1% nicht vorhanden!';
    001202 :  vA # 'Kein %1% ausgewählt!';
    001203 :  vA # '%1% außerhalb des Bereiches';
    001204 :  vA # 'E:Es existiert bereits ein Datensatz mit diesen Schlüsselwerten!%1%';
    001205 :  vA # '%1% darf nicht negativ sein!';
    001206 :  vA # 'Das Bruttogewicht darf nicht kleiner als das Nettogewicht sein!';

    001300 :  vA # 'E:Externe Datei %1% nicht vorhanden!';
    001350 :  vA # 'E:Conzept 16 Benutzerlimit erreicht. Anhangsdatenbank konnte nicht geöffnet werden!';
    001351 :  vA # 'E:Verbindung zur BLOB-Datenbank konnte nicht hergestellt werden.%CR%Server:%1% %CR% Datenbank:%2%';
      

    001400 :  vA # 'E:Das %1% %2% liegt vor dem Abschlussdatum '+CnvAD(Set.Abschlussdatum)+'!';

    001998 :  vA # 'E:#WINDOWS-ZUORDUNGS-FEHLER!%CR%Bitte dem Hersteller melden und das Programm komplett neu starten!';
    001999 :  vA # 'E:#PROZEDUR FEHLT: %1%';

    // Printserver
    002000 :  vA # 'W:Der Printserver hat noch kein Dokument geliefert.%CR%Bei umfangreichen Dokumenten/Reports kann die Aufbereitung länger dauern.%CR%Wollen Sie weiter diese Nachricht erhalten? (Abbruch = Nicht mehr warten)';
    002001 :  vA # 'W:Der Printserver lieferte kein Dokument.';

    // --------------------------------
    010001 :  vA # 'E:Position %1%: Material/Artikel %2% nicht gefunden!';
    010002 :  vA # 'E:Position %1%: Material %2% ist bereits gelöscht!';
    010003 :  vA # 'E:Position %1%: Material %2% hat eine falsche Kommission';
    010004 :  vA # 'E:Position %1%, Material %2%: Reservierung konnte nicht angepasst bzw. gelöscht werden!';
    010005 :  vA # 'E:Position %1%: Material %2% konnte nicht gesplittet werden!';
    010006 :  vA # 'E:Position %1%: Material %2% trägt noch Reservierungen!';
    010007 :  vA # 'E:Position %1%: Material %2% konnte nicht upgedatet werden!';
    010008 :  vA # 'E:Position %1% konnte nicht upgedatet werden!';
    010009 :  vA # 'E:Position %1%: Auftragsaktion %2% nicht gefunden!';
    010010 :  vA # 'E:Position %1%, Auftrag %2%: Auftragsaktion konnte nicht angelegt werden!';
    010011 :  vA # 'E:Position %1%: Artikel %2% konnte nicht verbucht werden!';
    010012 :  vA # 'E:Position %1%: Auftragsaufpreis konnte nicht verbucht werden!';
    010013 :  vA # 'E:Position %1% ist bereits verbucht!';
    010014 :  vA # 'E:Position %1%: Auftrag %2% nicht gefunden!';
    010015 :  vA # 'E:Position %1%, Auftrag %2%: Auftragskopf nicht gefunden!';
    010016 :  vA # 'E:Position %1%, Auftrag %2%: Kunde nicht gefunden!';
    010017 :  vA # 'E:Position %1%, Material %2%: Aktion konnte nicht gelöscht werden!';
    010018 :  vA # 'E:Position %1%: Auftrag %2% konnte nicht upgedatet werden!';
    010019 :  vA # 'E:Position %1%, Auftrag %2%: Auftragsaktion konnte nicht gelöscht werden!';
    010020 :  vA # 'E:Position %1%, Auftrag %2%: Auftragsaktion konnte nicht aktualisiert werden!';
    010021 :  vA # 'E:Position %1%, Material %2%: Reservierung konnte nicht neu angelegt werden!';
    010022 :  vA # 'E:Position %1%, Material %2%: Aktion konnte nicht aktualisiert werden!';
    010023 :  vA # 'E:Position %1%, Auftrag %2% hat keine ausreichende Lieferfreigabe (VSB)!';
    010024 :  vA # 'E:Position %1%, Auftrag %2%: Stücklistenposition nicht gefunden!';
    010025 :  vA # 'E:Position %1%, Auftrag %2%: Stücklistenposition konnte nicht aktualisiert werden!';
    010026 :  vA # 'E:Position %1% ist nicht verbucht!';
    010027 :  vA # 'E:BAG %1%: Einsatz %2% nicht gefunden!';
    010028 :  vA # 'E:BAG %1%, Einsatz %2%: Folgefertigung nicht gefunden!';
    010029 :  vA # 'E:BAG %1%: Lieferscheinposition dazu nicht gefunden!';
    010030 :  vA # 'E:Position %1% konnte nicht gelöscht werden!';
    010031 :  vA # 'E:BAG %1%: Auftrag %2% nicht gefunden!';
    010032 :  vA # 'E:Lieferschein konnte nicht gespeichert werden!';
    010033 :  vA # 'E:BAG %1%: Fertigung konnte nicht neu angelegt werden!';
    010034 :  vA # 'E:BAG %1% konnte nicht aktualisiert werden!';
    010035 :  vA # 'E:BAG %1%: Einsatzmaterial %2% konnte nicht aktualisiert werden!';
    010036 :  vA # 'E:BAG %1%: Einsatz %2% konnte nicht gelöscht werden!';
    010037 :  vA # 'E:BAG %1%: Fertigung %2% konnte nicht gelöscht werden!';
    010038 :  vA # 'E:BAG %1%: Auftragsaktion nicht gefunden!';
    010039 :  vA # 'E:BAG %1%: Auftragsaktion %2% konnte nicht gelöscht werden!';
    010040 :  vA # 'E:BAG %1%: Einsatzmaterial %2% nicht gefunden!';
    010041 :  vA # 'E:BAG %1%, Auftrag %2%: Auftragsaktion konnte nicht angelegt werden!';
    010042 :  vA # 'E:Material %1% hat den falschen Status : %2% statt %3%!';
    010043 :  vA # 'E:%1% gesperrt durch !'+Lockedby;
    010044 :  vA # 'E:BAG %1%: Weiterbearbeitung konnte nicht gefunden werden!';
    010045 :  vA # 'I:ACHTUNG! Archivierte und gedruckt Formulare können nicht verändert werden!';
    010046 :  vA # 'E:Der Kunde passt nicht zu dem Im Lieferscheinkopf angegebenen Kunden!';

    019999 :  vA # '%1%';

    // Betriebs-Menü:
    020001 :  vA # 'E:Materialnummer %1% nicht gefunden!';
    020002 :  vA # 'E:Materialnummer %1% hat keine Brutto-Verwiegungsart!';
  end;

  // Dateispezifische Fehlermeldungen ********************************
  case aNr of
    // Adressen
    100000 :  vA # 'E:Kundennummer bereits vergeben!';
    100001 :  vA # 'E:Lieferantennummer bereits vergeben!';
    100002 :  vA # 'E:#Haupt-Anschrift (1) konnte nicht angelegt werden!';
    100003 :  vA # 'E:#Kreditlimit konnte nicht angelegt werden!';
    100004 :  vA # 'E:Adresse darf nicht gelöscht werden, da bereits %1% dafür existieren!';
    100005 :  vA # 'E:Kunde %1% ist gesperrt!'
    100006 :  vA # 'E:Lieferant %1% ist gesperrt!'
    100007 :  vA # 'E:Die Nummer konnte leider nicht verändert werden!';
    100010 :  vA # 'E:Kunde wird bereits durch andere Datensätzen angesprochen!%CR%Keine Änderung jetzt mehr möglich!';
    100011 :  vA # 'E:Lieferant wird bereits durch andere Datensätzen angesprochen!%CR%Keine Änderung jetzt mehr möglich!';
    100012 :  vA # 'W:Keine USt.-ID angegeben, obwohl diese laut Steuerschlüssel gefordert ist!';
    100013 :  vA # 'W:Kunden-/Lieferantenakte mit Umsatzdaten ausgeben?';
    100014 :  vA # 'I:%1% E-Mails gesendet!%CR%Fenster schließen?'
    100015 :  vA # 'E:%1% ist keine gültige deutsche IBAN-Nummer!'
    100016 :  vA # 'I:Diese IBAN-Nummer scheint ok zu sein.';
    100017 :  vA # 'E:%1% entspricht nicht dem gültigen Format für eine E-Mail-Adresse.'

    101000 :  vA # 'E:Anschriftsnummer bereits vergeben!';
    101001 :  vA # 'E:Anschriftsnummer muss angegeben werden!';

    102000 :  vA # 'I:Der Ansprechpartner wurde erfolgreich übertragen!';
    102001 :  vA # 'E:Der Ansprechpartner konnte nicht übertragen werden!%CR%Bitte prüfen Sie Ihre Eingaben.';
    102002 :  vA # 'Q:Sollen die %1% markierten Kontakte nach Outlook übertragen werden?';

    103000 :  vA # 'W:%5%%CR%aktuelles Kreditlimit:%1%%CR%offene Posten:%2%%CR%erfasste Aufträge:%3%%CR%%4%';
    103001 :  vA # 'E:Das Kreditlimit des Rechnungsempfängers %2% ist überschritten!%CR%%1%';
    103002 :  vA # 'E:Der Rechnungsempfänger %1% ist komplett gesperrt!';
    103003 :  vA # 'E:Keine Kreditlimitfreigabe vorhanden!';
    103004 :  vA # 'E:Auftrag %1% besitzt keine Lieferfreigabe!';
    
    105000 :  vA # 'E:Verpackungsnummer bereits vergeben!';
    105001 :  vA # 'E:Vorschrift konnte nicht gelöscht werden!';
    105002 :  vA # 'E:Diese Verpackung dient als Einsatz bei der Verpackung %1%!';

    // Vertreter/Verband
    110000 :  vA # 'E:Vertreter/Verband %1% ist gesperrt!'

    // Projekte
    120000 :  vA # 'E:Mit diesem Intervall darf man keine Wartungen anlegen!';
    120001 :  vA # 'W:Sollen zu ALLEN fälligen Wartungsprojekten Aufträge angelegt werden?';
    120002 :  vA # 'I:Es wurden %1% Aufträge erfolgreich angelegt!';
    120003 :  vA # 'E:Automatische Auftragsanlage bei Projekt %1% fehlgeschlagen! Code %2%';
    120004 :  vA # 'E:Automatische Auftragsanlage bei Projekt %1% fehlgeschlagen!%CR%Kein gültiger Preis gefunden!';
    120005 :  vA # 'E:Das Projekt ist als ganzes bereits gelöscht!';
    120006 :  vA # 'E:Die Position %1% ist noch nicht gelöscht!';
    120007 :  vA # 'E:Das Projekt: %1% existiert nicht, oder ist gelöscht!%CR%Verschieben nicht möglich';
    120008 :  vA # 'W:Das Zielprojekt enthält Stücklisten.%CR%Trotzdem verschieben?';
    120009 :  vA # 'E:Das Quellprojekt konnte nicht gelesen werden!';
    120010 :  vA # 'E:Im Quellprojekt konnten nicht alle Zeiten gesperrt werden!';
    120011 :  vA # 'E:Fehler beim Verschieben der Zeiten [lfnNr.:%1%]!';
    120012 :  vA # 'E:Fehler beim Lesen des Textes!%CR%[%1%]';
    120013 :  vA # 'E:Fehler beim Speichern des Texte!%CR%[%1%]';
    120014 :  vA # 'E:Das Quellprojekt konnte nicht gesperrt werden!';
    120015 :  vA # 'E:Das Zielprojekt konnte nicht gespeichert werden!';
    120016 :  vA # 'E:Fehler beim Erstellen der Notifier-Message!';
    120017 :  vA # 'Q:Soll die Projektvorlage %1% in ein neues Projekt kopiert werden?';
    120018 :  vA # 'I:Neues Projekt mit Nummer %1% erfolgreich angleegt!';

    // Austauschprojekt [21.01.2010/PW]
    120100 :  vA # 'I:Projekt nach %1% exportiert. %2% Projektpositionen wurden exportiert.';
    120101 :  vA # 'I:Austauschprojekt nach %1% exportiert. %2% Projektpositionen wurden exportiert. Darin enthalten sind %3% neue Projektpositionen.';
    120102 :  vA # 'E:Die gewählte Datei ist ungültig oder enthält keine Daten für ein Austauschprojekt.%1%';
    120103 :  vA # 'E:Die Projektnummer %1% ist bereits vergeben.';
    120104 :  vA # 'I:Das Austauschprojekt %1% wurde erstellt. %2% Projektpositionen wurden importiert.';
    120105 :  vA # 'I:Das Austauschprojekt %1% wurde aktualisiert. %2% Projektpositionen wurden aktualisiert. Darin enthalten sind %3% übernommene Projektpositionen. Neue Positionen wurden markiert.';
    120106 :  vA # 'E:Das Projekt %1% ist nicht vorhanden.';
    120107 :  vA # 'E:Das Projekt %1% ist kein gültiges Ziel für ein Austauschprojektimport.';
    120108 :  vA # 'I:Das Projekt %1% wurde aktualisiert. %2% Projektpositionen wurden importiert und %3% Projektbeschreibungen aktualisiert. Aktualisierte Positionen wurden markiert.';
    120109 :  vA # 'E:Die gewählte Datei enthält ein Austauschprojekt in einem inkompatiblen Format, bitte beantragen Sie eine Datei in aktuellem Format.';
    //  21.01.2022  DS  Kritische Zeile verkürzt (längste Zeile im Dokument machte Probleme bei git Import in C16)
    120110 :  vA # 'Q:Die gewählte Datei enthält Exportdaten eines Austauschprojekts, welches in diesem Datenraum kein kompatibles Referenzprojekt besitzt. Wollen Sie fortfahren und das Projekt als Referenz für ein neues Austauschproj. nutzen?';

    // Lieferantenerklärungen
    130000 :  vA # 'W:Das Material %1% hat bereits eine Lieferantenerklärung zugewiesen (Nr.%2%)%CR%Diese Zuweisung entfernen?';
    130001 :  vA # 'Q:Diese Bestellung erwartete keine Lieferantenerklärungen. Trotzdem diesem Wareneingang eine zuweisen?';
    130002 :  vA # 'I:Die Erstellung der Lieferantenerklärung wurde erfolgreich in der Mat.Aktionsliste vermerkt.';
    130200 :  vA # 'E:Es ist bereits Material dieser Lieferantenerklärung zugewiesen!';
    130441 :  vA # 'Q:Folgende Materialien haben keine Lieferantenerklärungen:%CR%%1%CR%Trotzdem fortfahren?';


    // Ressourcen
    160000 :  vA # 'E:Es dürfen keine Sonderzeichen in dem Code benutzt werden!';
    160001 :  vA # 'E:Es existiert bereits ein Datensatz mit diesem Code!';

    161000 :  vA # 'E:Bitte geben Sie gültige Schlüsselwerte ein!';
    161001 :  vA # 'E:Es existiert bereits ein Datensatz mit diesen Schlüsselwerten!';

    165000 :  vA # 'E:Ursachen, Maßnahmen, Ersatzteile und IHA-Ressourcen werden ebenfalls gelöscht!';
    165001 :  vA # 'E:#Zuweisung fehlgeschlagen!';

    166000 :  vA # 'E:Maßnahmen, Ersatzteile und IHA-Ressourcen werden ebenfalls gelöscht!';

    167000 :  vA # 'E:Ersatzteile und IHA-Ressourcen werden ebenfalls gelöscht!';


    181000 :  vA # 'E:#HuB-Artikel %1% nicht gefunden';
    181001 :  vA # 'E:#HuB-Artikel %1% ist gesperrt durch Benutzer: '+LockedBy;

    182000 :  vA # 'E:#HuB-Artikel %1% nicht gefunden';
    182001 :  vA # 'E:#HuB-Artikel %1% ist gesperrt durch Benutzer: '+LockedBy;

    191000 :  vA # 'E:#HuB-Artikel %1% nicht gefunden';
    191001 :  vA # 'E:#HuB-Artikel %1% ist gesperrt durch Benutzer: '+LockedBy;

    192000 :  vA # 'E:#Bestellkopf nicht gefunden!';

    // Material
    200000 :  vA # 'E:Eigenmaterialhaken und Übernahmedatum passen nicht zusammen!';
    200001 :  vA # 'E:Übernahmedatum liegt NACH dem Eingangsdatum!';
    200002 :  vA # 'E:Eingangsdatum liegt NACH dem Ausgangsdatum!';
    200003 :  vA # 'E:Löschmarker und Ausgangsdatum passen nicht zusammen!';
    200004 :  vA # 'W:Achtung!%CR%Diese Karte stammt aus einer Bestellung/Wareneingang!%CR%Korrekturen sollten eigentlich dort durchgeführt werden!';
    200005 :  vA # 'E:Nur kommissioniertes Material darf den Status VSB haben!';
    200006 :  vA # 'E:Dieses Material ist bereits gelöscht';
    200007 :  vA # 'Q:Wollen Sie die bisherige Kommission entfernen und das Material wieder frei verfügbar machen?';
    200008 :  vA # 'W:Das Material würde damit den Status "VSB" bekommen!%CR%Wollen Sie fortfahren?';
    200009 :  vA # 'E:Das Material ist bereits reserviert!';
    200010 :  vA # 'W:Das Material würde nun gesplittet werden!%CR%Fortfahren?'
    200011 :  vA # 'E:Das Material ist bereits kommissioniert!';
    200012 :  vA # 'Q:Soll dieses Material als gelöscht markiert werden?';
    200013 :  vA # 'Q:Soll Dieses Material reaktiviert werden? (Status muss manuell gesetzt werden!)';
    200014 :  vA # 'Q:Sollen die EK-Preise dieser %1% Materialkarten auf %2% gesetzt werden?';
    200015 :  vA # 'Q:Material würde als gelöscht markiert.%CR%Soll der Materialwert genullt und auf die nachfolgenden Karten anteilig vererbt werden?';
    200016 :  vA # 'W:Es würde eine NEGATIVE Restmenge entstehen!%CR%Fortfahren?'
    200017 :  vA # 'E:Die markierte Karte %1% hat einen falschen Status und kann nicht mit anderen kombiniert werden!';
    200018 :  vA # 'E:Die markierten Karten sind zum Teil Eigen- und zum Teil Fremdmaterial und können nicht kombiniert werden!';
    200019 :  vA # 'Q:Sollen die %1% Karten zu einer einzigen kombiniert werden?';
    200020 :  vA # 'E:Der Endtermin darf nicht in der Zukunft liegen!';
    200021 :  vA # 'Q:Sollen die %1% '+"Set.Hauswährung.Kurz"+' pro TonnenTag verbucht werden?';
    200022 :  vA # 'Q:Sollen insgesamt %1% '+"Set.Hauswährung.Kurz"+' Zinsen verbucht werden?';
    200023 :  vA # 'Q:Wollen Sie die bisherige Kommission aus ALLEN markierten Materialien entfernen und diese wieder frei verfügbar machen?';
    200024 :  vA # 'Q:Sollen die Preise dieser %1% Materialkarten %2% geändert werden?';
    200025 :  vA # 'E:Der Artikel trägt eine abweichende Mengeneinheit (%1%) als diese Karte (%2%)!';
    200026 :  vA # 'E:Das Material %1% muss dafür in der Bestanddatei sein und nicht in der Ablage. Bitte Karte ggf. zurückholen.';
    200027 :  vA # 'E:Das Material %1% hat nicht den passenden Status!';
    200028 :  vA # 'Q:Wollen Sie die Inventurmengen ALLER Materialkarten übernehmen?'
    200029 :  vA # 'Q:Wollen Sie ALLE Materialien ohne Inventurdaten ausbuchen?'
    200030 :  vA # 'Q:Soll der verbleibende Rest von %1%kg als Rest abgesplittet werden?'

    200100 :  vA # 'E:Leider kann diese Karte nicht ordentlich aufgesplittet werden.';
    200101 :  vA # 'I:Die Karte wurde ordentlich aufgeteilt.%CR%Die neue Nummer lautet %1%.';
    200102 :  vA # 'E:Die Karte konnte nicht ordentlich aufgesplittet werden!';
    200103 :  vA # 'Q:Sind Sie sicher, dass Sie hieraus eine neue Karte anlegen wollen?';
    200104 :  vA # 'I:Es wurde erfolgreich eine Kopie %1% angelegt!';
    200105 :  vA # 'E:Kopie konnte nicht erstellt werden!'
    200106 :  vA # 'E:Material %1% konnte nicht verändert werden!'
    200107 :  vA # 'E:Das Material hat kein Eingangsdatum!';
    200108 :  vA # 'E:Das Material hat ein Ausgangsdatum!';
    200109 :  vA # 'E:Das Material hat Bestellmengen!';
    200110 :  vA # 'E:Es konnte keine Materialnummer generiert werden!';
    200111 :  vA # 'E:Der Aktionslisteneintrag konnte nicht erstellt werden!';
    200112 :  vA # 'E:Die neue Materialkarte konnte nicht erstellt werden!';
    200113 :  vA # 'E:Für das Material %1% wurde bereits eine Rechnung fakturiert!';

    200203 :  vA # 'E:Das Material %1% trägt noch Reservierungen!';

    200400 :  vA # 'E:Dieser Auftrag ist ungültig!';
    200401 :  vA # 'I:Kommission erfolgreich umgesetzt!';
    200402 :  vA # 'I:Kommission konnte NICHT verändert werden! (Fehler %1%)';

    202000 :  vA # 'E:Das Wertstellungsdatum liegt außerhalb der Zeit, in der diese Karte existierte!';

    203001 :  vA # 'Q:Sollen die Reservierungen wie angegeben aufgeteilt werden?';
    203002 :  vA # 'E:Reservierungen konnten NICHT aufgeteilt werden!';
    203003 :  vA # 'I:Reservierungen wurden erfolgreich aufgeteilt!';
    203004 :  vA # 'Q:Wollen Sie den Rest der Reservierung löschen?';
    203005 :  vA # 'W:Sie reservieren über den Bestand der Karte hinaus!%CR%Fortfahren?';
    203006 :  vA # 'Q:Sollen ALLE abgelaufene Reservierungen ALLER Materialien gelöscht werden?';
    203007 :  vA # 'E:Die Reservierung %1% zu Material %2% konnte nicht gelöscht werden!';
    203008 :  vA # 'E:Die Reservierung %1% zu Material %2% im Auftrag %3% konnte nicht gelöscht werden!';
    203009 :  vA # 'Q:Wollen die %1% Materialkarten zu diesem Auftrag komplett reserviert werden?';
    203010 :  vA # 'E:Das Material %1% konnte nicht eingefügt werden!';

    204000 :  vA # 'E:Die Materialkarte trägt bereits Aktionen!';

    // Material-Ablage
    210000 :  vA # 'Q:!!! ACHTUNG !!!%CR%Für eine Reorganisation sollten KEINE Benutzer in der Materialdatei arbeiten!!!%CR%Sollen die komplett gelöschte Material-Bäume in die Ablage verschoben werden?';
    210001 :  vA # 'I:Material-Reorganisation erfolgreich durchgeführt!';
    210002 :  vA # 'E:Material-Reorganisation abgebrochen !!!';
    210003 :  vA # 'Q:!!! ACHTUNG !!!%CR%Für eine Reorganisation sollten KEINE Benutzer in der Materialdatei arbeiten!!!%CR%Sollen alle gelöschten Materialkarten jetzt in die Ablage verschoben werden?';
    210004 :  vA # 'Q:Soll der Materialbestand geöffnet werden? (Nein = Ablage)';
    210010 :  vA # 'E:Material %1% NICHT in der Ablage gefunden!!!!';
    210011 :  vA # 'E:Rückholung fehlgeschlagen!!!';
    210012 :  vA # 'Q:Soll dieses Material aus der Ablage zurückgeholt werden?';

    220001 :  vA # 'Q:Sollen nur passende Datensätze angezeigt werden?';

    // Artikel
    250000 :  vA # 'E:Artikelnummer bereits vergeben!';
    250001 :  vA # 'E:Sachnummer bereits vergeben!';
    250002 :  vA # 'E:Katalognummer bereits vergeben!';
    250003 :  vA # 'E:Diese Berechnung ist nur bei Produktionsartikeln möglich.'
    250004 :  vA # 'E:Reservierungen konnten nicht verändert werden!';
    250005 :  vA # 'E:Diese Option ist nur bei Produktionsartikeln möglich.'
    250006 :  vA # 'E:Diese Berechnung ist bei Produktionsartikeln nicht möglich.'
    250007 :  vA # 'Q:Wollen Sie die Inventurmengen des Artikel %1% übernehmen?'
    250008 :  vA # 'Q:Wollen Sie die Inventurmengen ALLER Artikel übernehmen?'
    250009 :  vA # 'Q:Wollen Sie ALLE Chargen ohne Inventurdaten ALLER Artikel ausbuchen?'
    250010 :  vA # 'Q:Wollen Sie in allen Artikel die Stücklisten aktualisieren?';
    250011 :  vA # 'E:Keine gültige Stückliste vorhanden!';
    250012 :  vA # 'E:Die Stückliste konnte nicht verbucht werden!';
    250013 :  vA # 'Q:Wollen Sie diesen Artikel in die Stücklisten vererben?';
    250014 :  vA # 'Q:Wollen Sie alle veränderten Artikel in die Stücklisten vererben?';
    250015 :  vA # 'Q:Wollen Sie die Inventurmengen ALLER Artikel neu ermitteln?';
    250016 :  vA # 'Q:Wollen Sie die Inventurdaten ALLER Artikel zurücksetzen?%CR%Dieser Vorgang kann nicht rückgängig gemacht werden!';
    250017 :  vA # 'Q:Wollen Sie in nur diesen einen Artikel neu summieren? (sonst alle)';
    250018 :  vA # 'Q:Sollen alle %1% markierten Artikel neu summiert werden?';

    250540 :  vA # 'E:Artikel: %1% %CR%Automatische Disposition fehlgeschlagen!';
    250541 :  vA # 'Q:Automatischer Dispolauf für alle Artikel starten?';
    250542 :  vA # 'I:Automatischer Dispolauf erfolgreich beendet!';

    252000 :  vA # 'Q:Charge gesperrt durch: %1%%CR%Wiederholen?';

    253000 :  vA # 'E:#Bewegungs-Artikel %1% nicht gefunden!';
    253001 :  vA # 'E:Seriennummernartikel! Stückzahl darf nur EINS sein!';
    253002 :  vA # 'E:Seriennummer bereits vorhanden!';
    253003 :  vA # 'E:Start und Zielcharge dürfen nicht gleich sein!';
    253006 :  vA # 'E:Der Bestand bei Artikel %1% würde damit Null unterschreiten!';

    // Preise für Artikel
    254001 :  vA # 'E:Es existiert bereits ein Durchschnitts-EK, und es darf nur einen Eintrag davon geben!'
    254002 :  vA # 'E:Preisdatensatz ist gesperrt durch Benutzer '+lockedby + ', Löschen nicht möglich.'
    254003 :  vA # 'E:Preisdatensatz nicht verfügbar, Löschen nicht möglich.'
    254004 :  vA # 'Q:Wollen Sie die Preise für die markierten Artikel übernehmen?';
    254005 :  vA # 'Q:Wollen Sie die Durchschnitts-EKs aller Artikel in den Inventur-Preise übertragen?';
    254006 :  vA # 'E:Preisdatei in Artikel %1% nicht änderbar!'
    254007 :  vA # 'Q:Sollen die Inventur-EK-Preis der %1% markierten Artikel um %2%% geändert werden?';

    // Stückliste
    256001 :  vA # 'E:Dieser Artikel darf nicht eingefügt werden, da dies zu einem Zirkelbezug führen wurde!';

    // Pakete
    280001 :  vA # 'E:Die Paketnummer konnte nicht vererbt werden!';
    280002 :  vA # 'Q:Sollen die %1% markierten Einträge zu einem Paket zusammengeführt werden?';

    //Reklamationen
    300000 :  vA # 'I:Neue Reklamation angelegt: %1%%CR%%2%/%3%';
    300001 :  vA # 'I:Nur Kundenreklamationen erlaubt!%CR%Bearbeitung wird abgebrochen.'
    300002 :  vA # 'E:Materialkarte konnte nicht gefunden werden!%CR%Bearbeitung wird abgebrochen.'
    300003 :  vA # 'E:Keine Bestell-Nr. in Materialkarte %1% !!%CR%Bearbeitung wird abgebrochen.'
    300004 :  vA # 'Q:Möchten Sie einen Auftrag aus der Ablage auswählen?';
    300005 :  vA # 'E:Keine Lieferungen vorhanden!';

  end;

  case aNr of
    // Aufträge
    400001 :  vA # 'E:Keine berechenbare Einträge gefunden!';
    400002 :  vA # '#Aktionsliste von Position %1% ist gesperrt durch Benutzer: '+LockedBy;
    400003 :  vA # '#Position %1% ist gesperrt durch Benutzer: '+LockedBy;
    400004 :  vA # 'Q:Rechnung %1% so verbuchen?';
    400005 :  vA # 'I:Rechnung %1% erfolgreich erstellt!';
    400006 :  vA # 'W:Einige Aufpreise sind noch nicht angepasst worden!';
    400007 :  vA # 'E:Nur markierte Angebotspositionen des gleichen Kunden können zu einem Auftrag umgewandelt werden! ';
    400008 :  vA # 'Q:Die %1% markierten Angebotspositionen zu einen neuen Auftrag umwandeln?';
    400009 :  vA # 'E:#Allgemeiner Fehler beim Umwandeln von Angebot in Auftrag!%CR%Zeile %1%';
    400010 :  vA # 'I:Angebot wurde zu Auftrag %1% kopiert';
    400011 :  vA # 'Q:Sollen zu allen berechenbaren  Aufträgen Rechnungen gedruckt werden?';
    400012 :  vA # 'E:Im Auftrag %1% ist ein Fehler aufgetreten!';
    400013 :  vA # 'I:Rechnungen wurden erfolgreich erstellt!';
    400014 :  vA # 'E:Für diesen Auftrag existiert ein offener Lieferschein (Verladeanweisung) %1%!%CR%Dieser muss erstmal verbucht sein, bevor man weiter liefern darf!';
    400015 :  vA # 'Q:Für diesen Auftrag existiert ein offener Lieferschein (Verladeanweisung) %1%!%CR%Wollen Sie diesen überschreiben (Ja) oder einen neuen Lieferschein erzeugen? (Nein)';
    400016 :  vA # 'Q:Für diesen Auftrag existiert ein offener Lieferschein (Verladeanweisung) %1%!%CR%Dieser wird überschrieben!%CR%Fortfahren?';
    400017 :  vA # 'W:Der Lieferschein (Verladeanweisung) %1% wurde neu generiert!%CR%Bitte die alten Papiere beseitigen und neu drucken!';
    400018 :  vA # 'E:Auftragskopf konnte nicht verändert werde!';
    400019 :  vA # 'E:Auftrag hat bereits zugeordnete Aktionen!%CR%Keine Änderung der Kundennummer mehr möglich!';
    400020 :  vA # 'E:Auftrag hat bereits zugeordnete Aktionen!%CR%Keine Änderung des Rechnungsempfängers mehr möglich!';
    400021 :  vA # 'E:Auftrag hat bereits zugeordnete Aktionen!%CR%Keine Konvertierung zu Liefervertrag mehr möglich!';
    400022 :  vA # 'E:Keine USt.-ID angegeben!!';
    400023 :  vA # 'W:Der Rechnungsempfänger hat keine USt.-ID angegeben!%CR%Bis zur Fakturierung muss sie nachgereicht werden!';
    400024 :  vA # 'Q:Soll eine Auftragsbestätigung gedruckt werden (sonst Auftragsänderung)?';

    400025 :  vA # 'I:Bitte einen oder mehrere Lieferanten für die Anfrage auswählen...';
    400026 :  vA # 'I:Anfragen erfolgreich angelegt und ausgegeben!';
    400027 :  vA # 'Q:Sollen die %1% markierten Auftragspositionen zu einer neuen Lieferantenanfrage umgewandelt werden?';
    400028 :  vA # 'E:#Allgemeiner Fehler beim Umwandeln von Auftrag in Anfrage!%CR%Zeile %1%';
    400029 :  vA # 'I:Auftrag wurde zu Anfrage %1% kopiert';
    400030 :  vA # 'I:Bitte einen Lieferanten für die Anfrage auswählen...';
    400040 :  vA # 'Q:Soll der Rechnungsempfänger auf die neue Kundennummer geändert werden?';
    400041 :  vA # 'Q:Soll die Lieferadresse auf den neuen Kunden geändert werden?';
    400042 :  vA # 'E:Dieser Auftrag ist ein Puffer-Auftrag!';
    400043 :  vA # 'W:Die markierten Angebotspositionen stammen aus verschiedenen Köpfen!%CR%Der neue Auftragskopf wäre dann eine Kopie von Auftrag %1% - so fortfahren?';
    400044 :  vA # 'E:Änderung der Lieferanschrift nicht mehr möglich!';
    400045 :  vA # 'E:Angebotsposition ist schon vorhanden!';

    400094 :  vA # 'E:#Aufpreis %1% hat ungültige Warengruppe!';
    400095 :  vA # 'W:ACHTUNG!%CR%Rechnungsnummer konnte NICHT zurückgesetzt werden!!!';
    400096 :  vA # 'I:Rechnungsnummer wurde zurückgesetzt!'
    400097 :  vA # 'E:#RECHNUNGSDIFFERENZ!!!%CR%Der Ausdruck lieferte einen Betrag von %1% und die Verbuchung %2%!%CR%AUSGABE ABGEBROCHEN!';
    400098 :  vA # 'E:#Steuerschlüssel(Kombination) nicht gefunden!';
    400099 :  vA # 'E:#Allgemeiner Verbuchungsfehler! %CR%Zeile %1%';
    400100 :  vA # 'E:#RECHNUNGSDIFFERENZ!!!%CR%Der Ausdruck zu Rechnung %3% lieferte einen Betrag von %1% und die Verbuchung %2%!%CR%AUSGABE ABGEBROCHEN!';
    400101 :  vA # 'Q:Wollen Sie den Auftrag in einen Liefervertrag wandeln?%CR%Dieser Vorgang kann nicht rückgängig gemacht werden!';
    
    401000 :  vA # 'E:Löschen FEHLGESCHLAGEN! %CR%Code:%1%';
    401001 :  vA # 'E:Die Warengruppe darf im Nachhinein nicht von einem Dateityp in einen anderen geändert werden!';
    401002 :  vA # 'W:ACHTUNG!!!%CR%Diese Bestellnummer existiert bereits!';
    401003 :  vA # 'W:ACHTUNG!!!%CR%Einige Positionen haben keinen Termin gesetzt!%CR%Trotzdem speichern?';
    401004 :  vA # 'Q:Diese Termine in alle anderen Position ohne Termin eintragen?';
    401005 :  vA # 'E:Diese Art von Position kann nicht zurückgeholt werden!';
    401006 :  vA # 'E:Diese Position kann nicht gelöscht werden, weil noch offene bzw. nicht berechnete Lieferungen vorhanden sind!';
    401007 :  vA # 'Q:Diese Position hat bereits eine geplante Produktion!%CR%Trotzdem fortfahren?';
    401008 :  vA # 'Q:Diese Position hat bereits fest reservierte Chargen/Materialkarten!%CR%Zuordnung aufheben und fortfahren?';
    401009 :  vA # 'Q:Wollen Sie auf dieser Position %1% für die Gutschrift berechnen?';
    401010 :  vA # 'E:Position konnte nicht verändert werden!';
    401011 :  vA # 'Q:Wollen Sie auf dieser Position %1% für die Belastung berechnen?';
    401012 :  vA # 'Q:Wollen Sie den Artikel %1% gegen %2% austauschen?';
    401013 :  vA # 'Q:Wollen Sie die Abmessungen im Auftrag mit denen des Artikel überschreiben?';
    401014 :  vA # 'W:Es existieren noch Material-Reservierungen für diese Position!%CR%Wollen Sie diese Position UND die Reservierungen löschen?';
    401015 :  vA # 'W:Das Material %1% hat abweichende Abmessungen bzw. Güte!%CR%Trotzdem zuordnen?';
    401016 :  vA # 'E:Das Material %1% hat abweichende Abmessungen bzw. Güte!%CR%Zuordnung abgebrochen!';
    401017 :  vA # 'E:Diese Position hat noch offene Produktionen ausstehen!';
    401018 :  vA # 'Q:Sollen die Positionsdaten des ursprünglichen Auftrages übernommen werden?';
    401019 :  vA # 'Q:Wollen Sie für Kunde %1% eine Verpackungsvorschrift mit den Daten aus Auftrag %2% anlegen?';
    401020 :  vA # 'Q:Soll mit diesen Auftragsdaten automatisch eine neue Verpackungsvorschrift bei dem Kunden jetzt angelegt werden?';
    401021 :  vA # 'Q:Soll nun das VSB-Datum in den gedruckten Materialien gesetzt werden?';
    401022 :  vA # 'E:Die Verpackungsvorschrift trägt eine andere Warengruppe/Artikelnr. und kann nicht im Nachhinein übernommen werden!';
    401023 :  vA # 'Q:Sollen ALLE Daten aus der Verpackungsvorschrift in die Position kopiert werden?';
    401024 :  vA # 'Q:Wollen Sie aus der Verpackungsdatei auswählen?';
    401025 :  vA # 'Q:Soll diese Position damit auch komplett aus der Auftragseingangsstatistik gelöscht werden?';
    401026 :  vA # 'W:Diese Position hat eine Stückliste!&CR&Trotzdem auf der Position fortfahren?';
    401027 :  vA # 'W:Das Material trägt andere Reservierungen d.h. Sie dürfen nicht die komplette Karte zuordnen. Auf dem Rest verbleiben dann diese Reservierungen.';
    401028 :  vA # 'E:Sie dürfen nicht die komplette Karten zuordnen, da sonst kein Rest für die vorhandenen Reservierungen bliebe!';
    401029 :  vA # 'W:Achtung! Der verbleibende Rest wäre zu gering, um die vorhandenen Reservierungen mengenmäßig (%1% Stk, %2% kg)zu erfüllen!%CR%Trotzdem splitten?';
    401030 :  vA # 'Q:Soll der dazugehörige Lohn-BA auch mit kopiert werden?';
    401031 :  vA # 'Q:Wollen Sie den Text im Auftrag mit dem des Artikel überschreiben?';
    401032 :  vA # 'Q:Sollen die vorhandenen Aufpreise mit denen des Kundenverpackung überschrieben werden?';
    401033 :  vA # 'W:Durch den Wechsel der MEH von %1% auf %2% werden alle berechenbaren Aktionen auch verändert! Sie müssem damm deren zu fakturierende Mengen kontrollieren und anpassen - fortfahren?';
    
    401200 :  vA # 'E:Das Material passt nicht zum Auftrag wegen: %1%'
    401201 :  vA # 'Q:Das KOMPLETTE Material würde als "verkauft" gekennzeichnet, aber weiterhin in Ihrem Lager geführt werden!%CR%Fortfahren?';
    401202 :  vA # 'Q:Das KOMPLETTE Material würde als "verkauft" gekennzeichnet und aus Ihrem Bestand entfernt!%CR%Fortfahren?';
    401203 :  vA # 'E:Das Material konnte nicht zugeordnet werden!%CR%Fehlercode %1%';
    401204 :  vA # 'I:Das Material wurde erfolgreich dem Auftrag zugeordnet und ausgebucht!';
    401205 :  vA # 'E:Das Material kann nicht als Fremdmaterial übernommen werden,%CR%da der Kunde keine Lieferantennummer hat!';
    401206 :  vA # 'I:Das Material wurde erfolgreich dem Auftrag zugeordnet%CR%und eine neue Fremdkarte mit der Nummer %1% angelegt!';
    401207 :  vA # 'Q:Soll das Material zu dieser Kommission reserviert werden?';
    401208 :  vA # 'Q:Wollen Sie alle markierten Einträge (%1%) direkt fakturieren?';
    401209 :  vA # 'Q:Soll das Material dieser Kommission direkt zugewiesen werden? (VSB)';
    401210 :  vA # 'Q:Ein TEIL das Materials würde als "verkauft" gekennzeichnet, aber weiterhin in Ihrem Lager geführt werden!%CR%Ein Rest von %1% Stück bleibt erhalten!%CR%Fortfahren?';
    401211 :  vA # 'Q:Ein TEIL des Materials würde als "verkauft" gekennzeichnet und aus Ihrem Bestand entfernt!%CR%Ein Rest von %1% Stück bleibt erhalten!%CR%Fortfahren?';
    401212 :  vA # 'Q:Wollen Sie alle markierten Einträge (%1%) zuweisen?';

    401250 :  vA # 'Q:Wollen Sie wirklich %1% direkt fakturieren?%CR%(Lager wird belastet, Auftrag wird berechenbar)';
    401251 :  vA # 'I:Die angegebene Menge wurde erfolgreich direkt fakturiert!';
    401252 :  vA # 'E:Diese Charge ist bereits reserviert und kann nicht zugeordnet werden!';
    401253 :  vA # 'E:Diese Charge hat leider nur %1% Stück Bestand!';
    401254 :  vA # 'I:Die angegebene Menge der Charge wurde dieser Kommission%CR%erfolgreich zugeordnet und die Auftragsaktion angelegt!';
    401255 :  vA # 'E:Dieser Artikel hat leider nur %1% %2% verfügbar!';
    401256 :  vA # 'E:Es dürfen nur positive Mengen zugeordnet werden!';
    401257 :  vA # 'Q:Damit würde der Auftrag überliefert!%CR%Trotzdem fortfahren?';

    401401 :  vA # 'W:#Auftragsposition %1%: Konnte Abrufaktion nicht anlegen/verbuchen!';
    401403 :  vA # 'E:#Konnte die Aufpreise nicht updaten!';
    401404 :  vA # 'E:#Die Aktion konnte nicht angelegt werden!';
    401405 :  vA # 'E:#Konnte die Kalkulation nicht updaten!';
    401408 :  va # 'E:#Konnte die Feinabrufe nicht updaten!';
    401409 :  va # 'E:#Konnte die Stückliste nicht updaten!';
    401410 :  vA # 'E:#Menge im zugeordneten Betriebsauftrag konnte NICHT korrigiert werden!';

    401700 :  vA # 'E:Diese Auftragsposition besitzt mehrere BAs!%CR%Bitte über die Aktionsliste den gewünschten BA auswählen und anzeigen lassen.';
    401701 :  vA # 'E:Die markierte Position %1% passt nicht zu den anderen Markierungen!';
    401702 :  vA # 'E:Die markierte Position %1% besitzt schon den BA %2%!';
    401703 :  vA # 'Q:Soll für diese Auftragsposition ein BA angelegt werden?';
    401704 :  vA # 'Q:Soll für die %1% markierten Auftragsposition ein BA angelegt werden?';
    401705 :  vA # 'Q:Soll für diese Auftragsposition ein BA aus der Vorlage %1% angelegt werden?';

    401999 :  vA # 'E:#%1%: Auftragsposition nicht gefunden!';

    404000 :  vA # 'E:Diese Aktion kann nicht wieder reaktiviert werden!';
    404001 :  vA # 'E:Diese Aktion kann nicht storniert werden!';
    404002 :  vA # 'Q:Soll diese Lieferung rückgängig gemacht werden und die gelieferte Ware wieder in den Bestand aufnehmen?';
    404003 :  vA # 'E:Aktion konnte nicht storniert werden!';
    404004 :  vA # 'Q:Soll diese VSB-Menge rückgängig gemacht werden und wieder zu freiem Bestand werden?';
    404005 :  vA # 'E:Diese Aktion kann nicht berechnet werden!';
    404006 :  vA # 'I:%1% Materialkarten wurden aktualisert und werden erneut auf der Fertigmeldung ausgedruckt.';
    404007 :  vA # 'W:Dadurch wurde der Deckungsbeitrag mindestens einer bereits fakturierten Auftragsaktion verändert!';

    404100 :  vA # 'E:#Auftragsposition %1% hat eine ungültige Auftragsart!';
    404101 :  vA # 'E:#Auftragsposition %1% ist bereits gelöscht!';
    404102 :  vA # 'E:#Auftragsposition %1% konnte nicht upgedatet werden!';
    404103 :  vA # 'E:#Auftragsposition %1%: zu löschende Aktion ist bereits berechnet!';
    404104 :  vA # 'E:#Auftragsposition %1%: Aktion konnte nicht gelöscht werden!';
    404105 :  vA # 'E:#Auftrag %1%: Auftragskopf nicht gefunden!';
    404106 :  vA # 'E:#Auftrag %1% konnte nicht upgedatet werden!';
    404107 :  vA # 'E:#Auftragsposition %1% nicht gefunden!';
    404108 :  vA # 'E:#Stücklisteneintrag %1% konnte nicht upgedatet werden!';
    404109 :  vA # 'E:#Auftrag %1% hat keine freigegebene Zahlungsbedingung!';

    404200 :  vA # 'W:Bitte passen Sie auch die Materialkarte %1% entsprechend an!';
    404201 :  vA # 'E:Das zugehörige Material %1% konnte nicht im Bestand gelesen werden!';
    404202 :  vA # 'E:Das zugehörige Material %1% ist in einer aktiven Rechnung enthalten!';
    404250 :  vA # 'E:Die Charge %1% konnte nicht im Bestand gelesen werden!';

    409001 :  vA # 'E:Diese Einteilung ist nicht akzeptabel!';
    409002 :  vA # 'E:Die %1%.Einteilung ist so nicht in Ordnung!';
    409003 :  vA # 'Q:Soll die Menge von %1% in den Auftrag übernommen werden?';
    409700 :  vA # 'Q:Wollen Sie alle geplanten Reservierungen DIESER Position gesamt fertigmelden?';
    409701 :  vA # 'I:Die Reservierungen wurden so fertiggemeldet und die Schrottmengen gelöscht!';
    409702 :  vA # 'Q:Wollen Sie nun aus der Auftragsstückliste den Artikel %1% produzieren?';
    409703 :  vA # 'E:Konnte den Einsatzartikel %1% nicht abbuchen!';
    409704 :  vA # 'E:Konnte das Fertigprodukt %1% nicht einbuchen!';
    409705 :  vA # 'E:PRODUKTION FEHLGESCHLAGEN! %1%';
    409706 :  vA # 'I:%1% wurde ordnungsgemäß produziert';
    409707 :  vA # 'Q:Wollen Sie alle geplanten Reservierungen ALLER Positionen fertigmelden?';

    410000 :  vA # 'Q:!!! ACHTUNG !!!%CR%Für eine Reorganisation sollten KEINE Benutzer in der Auftragsdatei arbeiten!!!%CR%Sollen die als gelöscht markierten Aufträge in die Ablage verschoben werden?';
    410001 :  vA # 'I:Auftrag-Reorganisation erfolgreich durchgeführt!';
    410002 :  vA # 'E:Auftrag-Reorganisation abgebrochen: %1%';

    410010 :  vA # 'E:Auftragsnr. %1% NICHT in der Ablage gefunden!!!!';
    410011 :  vA # 'E:Rückholung fehlgeschlagen!!!';
    410012 :  vA # 'Q:Soll dieser Auftrag aus der Ablage zurückgeholt werden?';

    // Lieferschein
    440000 :  vA # 'Q:Lieferscheinschreibung abbrechen?';
    440001 :  vA # 'E:Der Lieferschein besitzt noch Positionen!';
    440002 :  vA # 'Q:Wollen Sie den Lieferschein speichern?';
    440003 :  vA # 'Q:LFS drucken & verbuchen?';
    440004 :  vA # 'Q:Sollen alle kommissionierten Materialien automatisch eingefügt werden?';
    440005 :  vA # 'Q:Sollen alle reservierten Materialien automatisch eingefügt werden?';
    440006 :  vA # 'W:Die Reservierung %1% enthält keine Stückzahl und kann nicht eingefügt werden!?';
    440007 :  vA # 'Q:Lieferschein verbuchen?'
    440008 :  vA # 'E:Der Lieferschein hat schon eine Freigabe!';
    440009 :  vA # 'Q:Wollen Sie diesen Lieferschein freigeben?';
    440010 :  vA # 'Q:Sollen alle Lieferscheine der Versandnr. %1% (BA %2%) so fertiggmeldet werden?';
    440011 :  vA # 'Q:Sollen diese Lieferscheine auch abgeschlossen werden?';

    440100 :  vA # 'E:#Lieferschein %1% konnte nicht gesperrt gelesen werden!';
    440101 :  vA # 'E:Lieferschein %1% wurde bereits verbucht!';
    440102 :  vA # 'E:#Lieferschein-Kopf konnte nicht gespeichert werden!';
    440103 :  vA # 'E:#Lieferschein konnte NICHT verbucht werden! (Code %1%)';
    440104 :  vA # 'E:#Lieferschein %1% ist nicht verbucht!';
    440105 :  vA # 'E:Keine Aktions-Zuordnungen zum Ausliefern gefunden!';
    440106 :  vA # 'E:#Lieferschein %1% ist ein LFA und darf nur als solcher verbucht werden!';
    440441 :  vA # 'E:#Konnte die LFS-Position nicht updaten! (Code %1%)';
    440700 :  vA # 'E:Der Lohnfahrauftrag konnte nicht generiert werden!';
    440701 :  vA # 'E:Nur Aufträge des gleichen Kunden mit der gleichen Zielanschrift können in einer Fuhre zusammengefasst werden!';
    440702 :  vA # 'Q:Soll der Versand über einen Lohnfahrauftrag erfolgen? (sonst nur Lieferschein)';
    440900 :  vA # 'I:Rücklieferschein erfolgreich verbucht und passende Rechnungskorrektur %1% dazu angelegt.';
    440901 :  vA # 'I:Rücklieferschein erfolgreich verbucht und passende Rechnungskorrektur %1% dazu angelegt.%CR%BITTE ABER AUFPREISE MANUELL PRÜFEN!';
    440996 :  vA # 'I:Die Lieferschein-Rekalkulation wurde erfolgreich abgeschlossen.';
    440998 :  vA # 'I:Lieferschein erfolgreich storniert!';
    440999 :  vA # 'I:Lieferschein erfolgreich verbucht!';

    441000 :  vA # 'E:Position %1% konnte nicht gelöscht werden!';
    441001 :  vA # 'Q:Wollen Sie ALLE Daten der Datei %1% an auf das VSB-Material %2% fertigmelden?';
    441002 :  vA # 'E:Das Material hat nicht den passenden Status!';
    441003 :  vA # 'W:Das Material hat einen anderen Lagerort!%CR%Trotzdem speichern?';
    441004 :  vA # 'W:Die Materialien lagern bei verschiedenen Lagerorten!';
    441005 :  vA # 'E:Lieferscheine dürfen kein EK-VSB-Material beinhalten!';
    441006 :  vA # 'E:Diese Kommission hat einen abweichenden Kunden!';
    441007 :  vA # 'E:Das Material %1% ist für keinen Auftrag kommissioniert und darf nicht ausgeliefert werden!';
    441008 :  vA # 'E:Position wurde NICHT aufgenommen!';
    441009 :  vA # 'E:Das Material trägt verschiedene Reservierungen!';
    441010 :  vA # 'E:Das Material ist bereits in einem anderen LFS/VLDAW eingeplant!';
    441011 :  vA # 'Q:Wollen Sie diese VSB-Material genau durch ein echtes Material ersetzen?';
    441012 :  vA # 'Q:Das gewählte Material ist Teil eines Paketes und kann nicht einzeln Verladen werden. Wollen Sie das komplette Paket hinzufügen?';
    441013 :  vA # 'E:Das Paket %1% konnte nicht gelesen werden.';
    441014 :  vA # 'E:Das Material %1% kann nicht dem Paket %2% zugeordnet werden';
    441015 :  vA # 'E:Das Material muss eine Kommission tragen, damit es in ein "Fahren-VK" eingesetzt werden kann!';
    441016 :  vA # 'E:Das Material ist für einen abweichenden Kunden kommissioniert, als die anderen Einsätze!';
    441017 :  vA # 'W:Sie haben nur einiges Material aus Paketen markiert!%CR%Die fehlenden Karten auch markieren? (sonst Abbruch)';
    441018 :  vA # 'E:Das Material hat keine passende Analyse!';

    441100 :  vA # 'E:#Position %1% ist gesperrt durch '+LockedBy;

    441700 :  vA # 'Q:Soll die Menge von %1% wirklich fertiggemeldet werden?';
    441701 :  vA # 'E:Fehler beim Fertigmelden!';

    // Erlöse/Umsätze
    450000 :  vA # 'Q:Diesen Erlös wirklich stornieren?';
    450001 :  vA # 'Q:Diesen bereits an die FiBu übergebenen Erlös wirklich stornieren?';
    450002 :  vA # 'I:Erlös wurde erfolgreich storniert!';
    450003 :  vA # 'E:#Auftragsaktion %1% gesperrt durch '+Lockedby;
    450004 :  vA # 'E:#Auftragsposition zu Aktion %1% nicht gefunden!';
    450005 :  vA # 'E:#Auftragsposition %1% gesperrt durch '+Lockedby;
    450006 :  vA # 'E:#Auftragskopf zu Aktion %1% nicht gefunden!';
    450007 :  vA # 'E:#Auftragskopf %1% gesperrt durch '+Lockedby;
    450008 :  vA # 'E:#Aufpreis %1% von Auftrag %2% gesperrt durch '+Lockedby;
    450009 :  vA # 'E:Eine der Rückstellungen dieser Rechnung wurde bereits zugeordnet!';
    450010 :  vA # 'E:Das Valutadatum liegt vor dem Rechnungsdatum!';
    450011 :  vA # 'E:Die Rechnungskorrektur-Position %1% bezieht sich auf keine Rechnung!';
    450012 :  vA # 'E:Die Auftragsaktion %1% hat eine abgweichende Mengeneinheit gegenüber der Preis-Mengeneinheit der Position!';

    450099 :  vA # 'E:#Allgemeiner Verbuchungsfehler!';
    450100 :  vA # 'E:Rechnungsdatum %1% liegt vor dem Abschlussdatum '+CnvAD(Set.Abschlussdatum)+'!';
    450101 :  vA # 'E:Fibu-Export-Prozedur nicht eingestellt!';
    450102 :  vA # 'I:Fibu-Export erfolgreich abgeschlossen!%CR%%1% Datensätze in Datei "%2%" übergeben!';
    450103 :  vA # 'Q:Alle markierten Erlöse an die Fibu exportieren?';
    450104 :  vA # 'E:Datei %1% konnte nicht beschrieben werden!';
    450105 :  vA # 'E:%1% erwartet eine Sammelrechnung und keine Einzelrechnung!';
    450106 :  vA # 'E:Die Eingangsrechung konnte nicht storniert werden! Bitte MANUELL prüfen!!!';
    450107 :  vA # 'I:Fibu-Export erfolgreich abgeschlossen!%CR%%1% Kunden in Datei "%2%" übergeben!';
    450108 :  vA # 'W:Die Rechnung beinhaltet noch nicht abgeschlossene Lohnfahraufträge!%CR%(d.h. deren Kosten sind noch nicht eingerechnet)%CR%Trotzdem die Rechnung fakturieren?';

    450200 :  vA # 'E:Ein Erlös konnte kein passendes Gegenkonto ermitteln!%CR%Übergabe ABGEBROCHEN!';
  end;

  case aNr of
     // Offene Posten
    460001 :  vA # 'Q:Mahnungen verbuchen?';
    460002 :  vA # 'E:Mahndatum konnte nicht gesetzt werden!';

    461001 :  vA # 'Q:Zu dieser Zahlung einen entsprechenden Zahlungseingang automatisch anlegen?';
    461002 :  vA # 'E:Die Währungen passen nicht zusammen!';

   // Zahlungseingang
    465001 :  vA # 'Q:Wollen Sie dem Auftrag %1% %2% '+"Set.Hauswährung.Kurz"+' als Vorkasse zuweisen?';
    465002 :  vA # 'E:Auftrag existiert nicht!';
    465003 :  vA # 'E:Auftrag ist bereits gelöscht!';

    // OP-Ablage
    470000 :  vA # 'Q:!!! ACHTUNG !!!%CR%Für eine Reorganisation sollten KEINE Benutzer in den Offenen Posten arbeiten!!!%CR%Sollen die als gelöscht markierten Offenen Posten in die Ablage verschoben werden?';
    470001 :  vA # 'I:OP-Reorganisation erfolgreich durchgeführt!';
    470002 :  vA # 'E:OP-Reorganisation abgebrochen !!!';
    470010 :  vA # 'E:Rechnung %1% NICHT in der Ablage gefunden!!!!';
    470011 :  vA # 'E:Rückholung fehlgeschlagen!!!';

    // Bestellungen
    500001 :  vA # 'Q:Soll eine Bestellung gedruckt werden (sonst Bestelländerung)?';

    500002 :  vA # 'Q:Sollen die %1% markierten Positionen in eine neue Anfrage kopiert werden?';
    500003 :  vA # 'I:Bitte einen Lieferanten für die neue Anfrage auswählen...';
    500004 :  vA # 'E:#Allgemeiner Fehler beim Umwandeln von Anfrage in Anfrage!%CR%Zeile %1%';
    500005 :  vA # 'I:Es wurde eine neue Anfrage %1% erstellt';
    500006 :  vA # 'E:Nur markierte Positionen eines Anfrage können zu einer Bestellung umgewandelt werden! ';
    500007 :  vA # 'Q:Die %1% markierten Anfragepositionen zu einer neuen Bestellung umwandeln?';
    500008 :  vA # 'E:#Allgemeiner Fehler beim Umwandeln von Anfrage in Bestellung!%CR%Zeile %1%';
    500009 :  vA # 'I:Anfrage wurde zu Bestellung %1% kopiert';
    500010 :  vA # 'Q:Wollen Sie für eine Schnellanfrage andere Lieferanten auswählen?';
    500011 :  vA # 'I:Bitte einen abweichenden Lieferanten auswählen oder mehrere markieren...';
    500012 :  vA # 'E:Die Bestellung hat bereits Wareneingänge!%CR%Keine Konvertierung zu Liefervertrag mehr möglich!';
    500013 :  vA # 'Q:Wollen Sie die Bestellung in einen Liefervertrag wandeln?%CR%Dieser Vorgang kann nicht rückgängig gemacht werden!';


    501001 :  vA # 'E:Bestellung kann nicht gelöscht werden, da noch aktive VSB-Einträge vorhanden sind!';
    501002 :  vA # 'E:Der Lieferant kann nicht mehr geändert werden, da bereits Eingänge verbucht wurden!';
    501003 :  vA # 'I:Bitte wählen Sie den neuen Lieferanten aus...';
    501004 :  vA # 'I:Bestellung trägt bereits Wareneingänge!';
    501005 :  vA # 'W:Bei der Kommission handelt es sich um einen Liefervertrag!';
    501006 :  vA # 'Q:Soll mit diesen Bestelldaten automatisch eine neue Verpackungsvorschrift bei dem Lieferanten jetzt angelegt werden?';
    501007 :  vA # 'Q:Wollen Sie für Lieferant %1% eine Verpackungsvorschrift mit den Daten aus Bestellung %2% anlegen?';

    501200 :  vA # 'E:#Materialkarte konnte nicht angelegt/verändert werden!';
    501250 :  vA # 'E:Artikel-Bestellmenge konnte nicht angelegt/verändert werden!';
    501503 :  vA # 'E:#Aufpreis konnte nicht angelegt werden!';
    501505 :  vA # 'E:Kalkulation konnte nicht angelegt werden!';

    504100 :  vA # 'E:#Bestellposition %1% hat ungültige Warengruppe!';
    504101 :  vA # 'E:#Bestellposition %1% ist bereits gelöscht!';
    504102 :  vA # 'E:#Bestellposition %1% konnte nicht upgedatet werden!';
    504104 :  vA # 'E:#Bestellposition %1%: Aktion konnte nicht gelöscht werden!';
    504105 :  vA # 'E:#Bestellung %1%: Bestellkopf nicht gefunden!';
    504106 :  vA # 'E:#Bestellung %1% konnte nicht upgedatet werden!';
    504107 :  vA # 'E:#Bestellposition %1% nicht gefunden!';

    506001 :  vA # 'E:#Eintrag lässt sich nicht verbuchen!';
    506002 :  vA # 'E:VSB, Eingang oder Ausfall muss angegeben werden!';
    506003 :  vA # 'E:Material %1% kann nicht diesem Wareneingang zugeordnet werden!%CR%Karte nicht gefunden!';
    506004 :  vA # 'E:Material %1% kann nicht diesem Wareneingang zugeordnet werden!%CR%Karte hat ungültige Werte!';
    506005 :  vA # 'Q:Folgende Analysewerte passen nicht:%CR%%1%Trotzdem verbuchen?';
    506006 :  vA # 'E:Folgende Analysewerte passen nicht:%CR%%1%Verbuchung nicht möglich!';
    506007 :  vA # 'Q:Soll dieser Eintrag als Ausfall gebucht werden?%CR%(Nein = nur löschen)';
    506008 :  vA # 'Q:Soll die Analyse dieses Wareneinganges in die markierten %1% Sätze kopiert werden?';
    506009 :  vA # 'E:Es sind Wareneingänge mit unterschiedlichen %1% markiert!';
    506010 :  vA # 'E:Ursprungs- und Zielwareneingang sind identisch!';
    506011 :  vA # 'E:Die Analyse konnte nicht in den %1%. Datensatz kopiert werden!';
    506012 :  vA # 'I:Die Werte der Materialdatei wurden anscheinend manuell verändert!%CR%Trotzdem Wareneingang speichern und damit Materialdatei überschreiben?';
    506013 :  vA # 'Q:Sollen alle Reservierungen übernommen werden?';
    506014 :  vA # 'Q:Soll jede Materialkarte einzeln angelegt werden?';
    506015 :  vA # 'Q:Die Anzahl der Einträge (%1%) passt nicht zu der ursprünglichen Stückzahl (%2%)!%CR%Trotzdem so verbuchen?';
    506016 :  vA # 'Q:Sollen die %1% Einträge gespeichert werden?';
    506017 :  vA # 'Q:Soll die restlichen %1% kg der VSB-Karte gelöscht werden?';
    506018 :  vA # 'Q:Soll der Rest von %1% %2% als Ausfall gebucht werden?';
    506019 :  vA # 'Q:Soll die Bestellposition damit gelöscht werden? (%1% % erfüllt)';
    506020 :  vA # 'I:Es konnte kein Warenwert ermittelt werden! Solche Eingänge sind nicht erlaubt!';
    506021 :  vA # 'W:Achtung! Es existieren PAUSCHALE Aufpreise, die jedem Wareneingang zugeschlagen werden würden!';
    506022 :  vA # 'W:Die Bestell-Karte trägt noch Reservierungen und solange kann die Bestellposition nicht gelöscht werden!';
    506023 :  vA # 'Q:Es existieren mehrere Reservierungen auf der Bestellung! Wollen Sie davon direkt welche übernehmen?';
    506024 :  vA # 'Q:Es existiert genau eine Reservierung auf dem Vorgängermaterial! Soll diese übernommen werden?';
    506025 :  vA # 'Q:Soll die Avisierung für diesen Eingang als erledigt markiert werden?';

    506555 :  vA # 'E:Einkaufskontrolle wurde bereits zugeordnet!';

    510000 :  vA # 'Q:!!! ACHTUNG !!!%CR%Für eine Reorganisation sollten KEINE Benutzer in der Bestelldatei arbeiten!!!%CR%Sollen die als gelöscht markierten Bestellungen in die Ablage verschoben werden?';
    510001 :  vA # 'I:Bestell-Reorganisation erfolgreich durchgeführt!';
    510002 :  vA # 'E:Bestell-Reorganisation abgebrochen !!!';

    510010 :  vA # 'E:Bestellnummer %1% NICHT in der Ablage gefunden!!!!';
    510011 :  vA # 'E:Rückholung fehlgeschlagen!!!';
    510012 :  vA # 'Q:Soll diese Bestellung aus der Ablage zurückgeholt werden?';

    // Bedarfsdatei
    540001 :  vA # 'I:Bestellung %1% erfolgreich angelegt!';
    540002 :  vA # 'W:ACHTUNG!%CR%Die markierten Sätze haben verschiedene Lieferanten!';
    540003 :  vA # 'E:Kein Lieferant in den markierten Sätzen angegeben!';
    540004 :  vA # 'I:Anfrage %1% erfolgreich angelegt!';
    540005 :  vA # 'W:Bitte Lieferant für Anfrage auswählen...';
    540006 :  vA # 'E:Bitte vorher die gewünschten Bedarfe markieren.';
    540007 :  vA # 'E:Es wurden unterschiedliche Währungen markiert!%CR%Bitte korrigieren!';
    540008 :  vA # 'E:Mindestens in einem der markierten Sätze wurde kein Preis angegeben!';
    540009 :  vA # 'E:Bitte vorher die gewünschten Bedarfe markieren.';
    540099 :  vA # 'E:Bestellung konnte nicht generiert werden!';

    540100 :  vA # 'Q:Alle markierten Positionen zu EINER Bestellung bei Lieferant %1% umwandeln?';
    540101 :  vA # 'Q:Alle markierten Positionen zu EINEM kummulierten Bedarf umwandeln?';

    540101 :  vA # 'E:Die Auftragsposition konnte nicht gelesen werden.'
    540102 :  vA # 'E:Die Warengruppe konnte nicht gelesen werden.'
    540103 :  vA # 'E:Der Artikel konnte nicht gelesen werden.'
    540104 :  vA # 'E:Der Bedarfs-Nummernkreis konnte nicht gelesen werden.'
    540105 :  vA # 'I:Der Bedarf wurde erfolgreich angelegt.'
    540106 :  vA # 'W:Lieferant kann nicht übernommen werden,%CR%da diese Adresse keine Lieferantennummer hat!'

    545000 :  vA # 'Q:!!! ACHTUNG !!!%CR%Für eine Reorganisation sollten KEINE Benutzer in der Bedarfsdatei arbeiten!!!%CR%Sollen die als gelöscht markierten Bedarfe in die Ablage verschoben werden?';
    545001 :  vA # 'I:Bedarfs-Reorganisation erfolgreich durchgeführt!';
    545002 :  vA # 'E:Bedarfs-Reorganisation abgebrochen: %1%';
    545010 :  vA # 'E:Bedarfnr. %1% NICHT in der Ablage gefunden!!!!';
    545011 :  vA # 'E:Rückholung fehlgeschlagen!!!';
    545012 :  vA # 'Q:Soll dieser Bedarf aus der Ablage zurückgeholt werden?';

    // EKK
    555001 :  vA # 'Q:Diese Zuweisung wirklich aufheben?';
    555002 :  vA # 'Q:Wollen Sie alle markierten Einträge (%1%) übernehmen?';
    555003 :  vA # 'E:EKK-Eintrag konnte nicht zugeordnet werden!';
    555004 :  vA # 'I:Die Summe der markierten Einkaufskontrolleinträge beträgt %1%';
    555005 :  vA # 'E:Es muss eine Rechnungsposition zwischen 1 und 100 angegeben werden!';
    555006 :  vA # 'W:Für dieses Material ist eine Reklamation angelegt!%CR%Trotzdem speichern?';

    555007 :  vA # 'E:Diese EKK ist schon einer anderen Eingangsrechnung zugewisen!';
    555008 :  vA # 'E:Diese markierten Sätze sind unterschiedliche bei : %1%';
    555009 :  vA # 'Q:Sollen die %1% Sätze (Warenwert %2%) zu einer neuen Eingangsrechnung zusammengefasst werden?';
    555010 :  vA # 'W:Das Material %1% trägt bereits mind. einen Kosteneintrag!%CR%Trotzdem einen weiteren eintragen?';

    // Eingangsrechnungen
    560001 :  vA # 'E:Lieferanten stimmen nicht überein!';
    560002 :  vA # 'E:Ungültiger Zahlungsausgang angegeben!';
    560003 :  vA # 'E:Ungültige Eingangsrechnung angegeben!';
    560004 :  vA # 'Q:Zahlungen und Ausgangszahlungen generieren?';
    560005 :  vA # 'I:Daten wurden generiert!';
    560006 :  vA # 'I:Die Summe der markierten Eingangsrechnungen beträgt %1%';
    560007 :  vA # 'E:Es dürfen keine Zahlungen zugeordnet sein!';
    560008 :  vA # 'E:Die Eingangsrechnung %1% ist nicht "in Ordnung" und darf nicht bezahlt werden!';
    560009 :  vA # 'Q:Soll die Eingangsrechnung %1% wieder auf "ungeprüft" gesetzt werden?';
    //560010 :  vA # 'W:Achtung!%CR%Der kontierte Betrag stimmt nicht mit dem Bruttowert überein!';
    560010 :  vA # 'W:Achtung!%CR%Der kontierte Betrag stimmt nicht mit dem Nettowert überein!';
    560011 :  vA # 'E:Die Kosten konnten nicht in das Material übernommen werden!';
    560012 :  vA # 'Q:Zwischen dem Rechnungswert und dem zugeordneten Betrag ist eine Differenz von %1%!%CR%Trotzdem fortfahren?!';
    560013 :  vA # 'Q:Zwischen dem Rechnungswert und dem kontierten Betrag ist eine Differenz von %1%!%CR%Trotzdem fortfahren?!';
    560014 :  vA # 'W:Achtung!%CR%Das Rechnungsdatum liegt in der Zukunft!';
    560015 :  vA # 'W:Von den markierten Eingangsrechnungen wurden %1% bereits gezahlt!%CR%Diese werden NICHT erneut ausgezahlt, sondern übersprungen!';
    560016 :  vA # 'Q:Möchten Sie eine Bestellung aus der Ablage auswählen?';
    560017 :  vA # 'E:Mindestens eine EKK-Zuordnung verweist auf eine nicht vorhandene Position laut Kontierung!';
    560018 :  vA # 'Q:Es exisitert bereits schon eine andere Eingangsrechnung mit dieser Re.Nr.!%CR%Trotzdem speichern?';
    560019 :  vA # 'Q:Der eingegbene Steuerbetrag weicht vom errechneten ab.%CR%Soll der errechnete Betrag von %1% übernommen werden?';

    561001 :  vA # 'E:Diese Zahlung wurde bereits getätigt!';
    561002 :  vA # 'Q:Zu dieser Zahlung einen entsprechenden Zahlungsausgang automatisch anlegen?';

    // Zahlungsausgang
    565001 :  vA # 'Q:Wollen Sie für alle markierten Zahlungen Schecks drucken?';
    565002 :  vA # 'W:Einige markierte Zahlungen sind bereits als "bezahlt" gekennzeichnet!%CR%Trotzdem fortfahren?';
    565003 :  vA # 'Q:Soll der Scheckdruck in den Zahlungen verbucht werden?';
    565004 :  vA # 'Q:Soll die Avis sofort gedruckt werden?';
    565005 :  vA # 'Q:Soll der Scheck sofort gedruckt werden?';

    // Kostenbuchungen
    580001 :  vA # 'E:Bitte markieren Sie zunächst die zu kopierenden Einträge!';
    580002 :  vA # 'Q:Sollen die %1% markierten Einträge wirklich kopiert werden?';
    580003 :  vA # 'E:Das Werstellungsdatum passt nicht zu dem Datumsbereich des Kopfes!';
    580004 :  vA # 'E:Die Kopfnummer %1% konnte nicht gefunden werden!';

    // Sammelwareneingänge
    621001 :  vA # 'E:Avis, Eingang oder Ausfall muss angegeben werden!';
    621002 :  vA # 'E:Das Material zu diesem Einsatz konnte nicht gelesen werden. Position kann nicht gelöscht werden.';
    621003 :  vA # 'E:Das Material zu diesem Einsatz enthält bereits Aktionen. Position kann nicht gelöscht werden.';
    621004 :  vA # 'E:Das Material zu diesem Einsatz konnte nicht gelöscht werden. Position kann nicht gelöscht werden.';
    621005 :  vA # 'E:Die Position konnte nicht gelöscht werden.';

    // Versand
    650000 :  vA # 'Q:Ist der Versand so komplett und sollen daraus nun Transportaufträge angelegt werden?';
    650001 :  vA # 'E:Versand konnte nicht verbucht werden!';
    650002 :  vA # 'Q:Soll für den Selbstabholer EIN Lieferschein anlegt werden?';
    650003 :  vA # 'W:Es wurden MEHRERE unterschiedliche Fahraufträge erstellt aber nur ein Gesamtpreis angegeben!%CR%Bitte ändern Sie die Einzelpreise in den Fahraufträgen manuell ab.';

    // Versandposten
    651000 :  vA # 'E:Dieser Pooleintrag ist nicht für Selbstabholung durch %1% bestimmt!';
    651001 :  vA # 'Q:Sollen alle markierten Pooleinträge übernommen/eingefügt werden?';
    651002 :  vA # 'E:Einige markierte Pooleinträge passen nicht zu dem Versandkopf!';

    // Versandpool
    655000 :  vA # 'E:Der Versand konnte nicht beauftragt werden!';
    655001 :  vA # 'E:Es konnte keine Versandpoolnummer bestimmt werden!';
    655101 :  vA # 'E:Anschrift %1% nicht gefunden!';
    655200 :  vA # 'E:Material %1% nicht gefunden!';
    655201 :  vA # 'E:Material %1% ist bereits im Versandpool!';
    655202 :  vA # 'E:Material %1% entspricht nicht den Voraussetzungen für einen Versand!';
    655400 :  vA # 'E:Auftrag %1% nicht gefunden!';
  end;

  case aNr of
    // BAG :
    700001 :  vA # 'Q:Soll der komplette BA mit den geplanten Mengen fertiggemeldet werden?';
    700002 :  vA # 'E:Betriebsauftrag %1% nicht gefunden!';
    700003 :  vA # 'E:Betriebsauftrags-Position %1% nicht gefunden!';
    700004 :  vA # 'Q:Sollen alle Positionen dieses Betriebsauftrages automatisch %1% eingeplant werden?';
    700005 :  vA # 'I:Automatische Planung erfolgreich!';
    700006 :  vA # 'E:Position %1% konnte nicht termingerecht eingeplant werden!%CR%Planung abgebrochen!';
    700007 :  vA # 'E:Keinen Vorlage-BA mit der Nummer %1% gefunden!';
    700008 :  vA # 'E:Keine Arbeitsschritte in Vorlage-BA Nr. %1% gefunden!';
    700009 :  vA # 'Q:Neuen Betriebsauftrag anlegen?';
    700010 :  vA # 'Q:Soll das komplette reservierte Material dieses Auftrages als Einsatz übernommen werden?%CR%(Sonst nur theoretisches Material)';
    700011 :  vA # 'E:Es konnte kein BA angelegt werden!';
    700012 :  vA # 'Q:Soll für den Rest des Einsatzmaterials ein neues Etikett gedruckt werden?';
    700013 :  vA # 'I:Bitte wählen Sie dazu vorher einen Vorlage-BA aus.';
    700014 :  vA # 'E:Betriebsauftrag %1% hat mehrere Positionen! Bitte geben Sie die Position mit an.';
    700015 :  vA # 'Q:Soll der komplette BA geleert d.h alle Positionen und Fertigungen gelöscht werden?';
    700016 :  vA # 'I:Bitte wählen Sie dazu vorher einen normalen BA aus.';
    700017 :  vA # 'E:Keinen BA mit der Nummer %1% gefunden!';
    700018 :  vA # 'Q:Soll wirklich ein neuer BA erzeugt werden?';
    700019 :  vA # 'Q:Soll wirklich ein neuer Vorlage-BA erzeugt werden?';
    700020 :  vA # 'E:Der BA %1% ist kein freigegebener Vorlage-BA!';

    // >> Fehlermeldungen zu Betriebsauftrags-Merging BA1_Data / BA1_P_Data
    700100 :  vA # 'E:BA %1% (Ziel) nicht gefunden!';
    700101 :  vA # 'E:BA %1% (Ursprung) nicht gefunden!';
    700102 :  vA # 'E:BA %1% wurde als Quelle und Ziel gewählt!';
    700103 :  vA # 'E:BA %1% und BA %2: Aktionstyp weicht ab!';
    700104 :  vA # 'E:Ursprung und Ziel sind unterschliedliche BA Typen!';
    700105 :  vA # 'E:Zu BA %1% (Ziel) existieren bereits Verwiegungen!';
    700106 :  vA # 'E:Zu BA %1% (Ursprung) existieren bereits Verwiegungen!';
    700107 :  vA # 'E:BA-Verpackung konnte nicht transferiert werden!';
    700108 :  vA # 'E:BA Einsatzdaten konnten nicht transferiert werden!';
    700109 :  vA # 'E:BA Position konnte nicht transferiert werden!';
    700110 :  vA # 'E:BA Input/Output konnte nicht transferiert werden!';
    700111 :  vA # 'E:BA Fertigungsdaten konnten nicht transferiert werden!';
    700112 :  vA # 'E:BA Ausführungsdaten konnten nicht transferiert werden!';
    700113 :  vA # 'E:BA Arbeitsschritte konnten nicht transferiert werden!';
    700114 :  vA # 'E:BA Zeiten konnten nicht transferiert werden!';
    700115 :  vA # 'E:BA Zusatzdaten konnten nicht transferiert werden!';
    700116 :  vA # 'E:Löschung Ursprungs-BA %1%: Kopf konnte nicht gelöscht werden! ';
    700117 :  vA # 'E:Fehler im Bereich %1%';
    700117 :  vA # 'E:Ursprung und Ziel sind identisch!';
    700118 :  vA # 'E:Aktionstyp ist falsch!'
    700119 :  vA # 'E:Ursprung: Falsche Input-Anzahl!';
    700120 :  vA # 'E:Ziel-BAkonnte nicht aktualisiert werden!';
    700121 :  vA # 'E:Ursprungs-BA konnte nicht aktualisiert werden!';
    700122 :  vA # 'E:Output konnte nicht aktualisiert werden!';
    700123 :  vA # 'E:Input konnte nicht aktualisiert werden!';
    700124 :  vA # 'E:Ursprungs-BA: Input konnte nicht gelöscht werden!';
    700125 :  vA # 'E:Ursprungs-BA: Vorgänger konnte nicht getrennt werden!';
    700126 :  vA # 'E:Ziel-BA enthält Schopf!';
    700127 :  vA # 'E:Ursprungs-BA enthält Schopf!';
    700128 :  vA # 'E:Zusatztext konnte nicht übertragen werden!';
    700129 :  vA # 'E:Nachfolger konnte nicht aktualisiert werden!';
    700130 :  vA # 'E:Ursprungs-BA konnte nicht gelesen werden!';
    700131 :  vA # 'E:Ursprungs-BA Position konnte nicht gelöscht werden!';
    // <<

    701001 :  vA # 'E:Vorgänger nicht gefunden!';
    701002 :  vA # 'E:Vorgänger wird bereits weiterbearbeitet!';
    701003 :  vA # 'E:Einsatzmaterial kann nicht verändert werden!';
    701004 :  vA # 'E:Hiermit würde ein Kreislauf entstehen!';
    701005 :  vA # 'E:Das angegebene Material konnte nicht als Einsatzmaterial verbucht werden!';
    701006 :  vA # 'E:Das Einsatzmaterial konnte nicht wieder "frei" gemacht werden!';
    701007 :  vA # 'E:Das Material kann nicht mehr als Einsatz gelöscht werden, da bereits Fertigmeldungen existieren!';
    701008 :  vA # 'E:Dieser Einsatz beinhaltet kein konkretes Material!';
    701009 :  vA # 'E:Diese Ausbringung ist nicht mehr buchbar!';
    701010 :  vA # 'E:Ausbringungsberechnung fehlgeschlagen!!!';
    701011 :  vA # 'Q:Dies ist VSB-Material - tatsächliches Einsatzmaterial jetzt erfassen?';
    701012 :  vA # 'E:Das VSB-Material konnte nicht gelesen werden!';
    701013 :  vA # 'E:Die Bestellung zu diesem VSB-Material konnte nicht gelesen werden!';
    701014 :  vA # 'E:Bei Fahraufträgen muss die gesamte Menge eingesetzt werden, da kein Schopf gebildet werden kann!%CR%(ggf. vorher eine manuelle Splittung vornehmen)';
    701015 :  vA # 'Q:Diese Fertigung ist schon erledigt - trotzdem darauf weiter fertigmelden?';
    701016 :  vA # 'Q:Dieser Einsatz hat nur noch %1%. Trotzdem daraus fertigmelden?';
    701017 :  vA # 'E:Betriebsauftragseinsatz konnte nicht eingefügt werden!';
    701018 :  vA # 'E:Betriebsauftragsausbringung konnte nicht aktualisiert werden!';
    701019 :  vA # 'E:VSB Material %1% konnte nicht freigegeben werden!';
    701020 :  vA # 'E:VSB Material %1% konnte nicht eigesetzt werden!';
    701021 :  vA # 'E:Das Material %1% konnte nicht als Einsatzmaterial verbucht werden!';
    701022 :  vA # 'E:Betriebsauftragseinsatz konnte nicht verändert werden (ID: %1%)!';
    701023 :  vA # 'Q:Davon wurde bereits ein Teil fertiggemeldet.%CR%Sind Sie sicher, dass Sie weiter Fertigmelden wollen?';
    701024 :  vA # 'E:Von diesem Einsatz existiert kein Rest mehr!';
    701025 :  vA # 'E:Dieser Einsatz ist nicht gültig!';
    701026 :  vA # 'E:Einsatz kann nicht gelöscht werden, da bereits Fertigmeldungen existieren!';
    701027 :  vA # 'E:Das Material gehört nicht diesem Kunden!!';
    701028 :  vA # 'Q:Soll die restliche Menge des VSB-Materials in der Bestellung gelöscht werden?';
    701029 :  vA # 'E:Positionen von Verkaufs-Fahraufträgen dürfen nicht weiterbearbeitet werden!';
    701030 :  vA # 'E:Der Zusatztext zu diesem Einsatz konnte nicht gelöscht werden!';
    701031 :  vA # 'E:Das Material %1% konnte nicht in den BA eingefügt werden!%2%';
    701032 :  vA # 'Q:Sollen ggf. die vorhandenen Reservierungen vom Auftrag als Einsatz eingefügt werden?';
    701033 :  vA # 'E:Vorgängerposition ist bereits gelöscht!';
    701034 :  vA # 'E:Dies ist VSB-Material - es kann nur aus echtem verfügbaren Einsatzmaterial produziert werden!';
    701035 :  vA # 'W:Achtung:%CR%Mindestens ein verwogenes Material wird in dieser Fertigung weiterverarbeitet! Jetzt würde diese Weiterbearbeitungen gestoppt und das Material auf Status GESPERRT gesetzt werden...';
    701036 :  vA # 'Q:Wollen Sie alle markierten Materialkarten (%1%) übernehmen?';
    701037 :  vA # 'E:Die VSB Schritte des Einsatzmaterials %1% konnten nicht gelöscht werden.';
    701038 :  vA # 'E:Der zu löschende Schopf wird weiterbearbeitet! Bitte diese Weiterbearbeitungen vorher löschen!';
    701039 :  vA # 'E:Das zugehörige Material %1% konnte nicht im Bestand gelesen werden!';
    701040 :  vA # 'E:Der Einsatz hat eine geringere Menge!';
    701041 :  vA # 'E:Einsatzmengen müssen angegeben werden!';
    701042 :  vA # 'Q:Das Material ist bereits in einem anderen BA eingefügt!%CR%Trotzdem aufnehmen?';
    701043 :  vA # 'Q:Geplante Einsatzmenge (%1%) ist größer als Ist-Menge!%CR%Trotzdem so speichern?';

    702001 :  vA # 'E:Position ist bereits abgeschlossen!';
    702002 :  vA # 'E:Position kann nicht gelöscht werden, da bereits Fertigmeldungen existieren!';
    702003 :  vA # 'E:Position kann nicht gelöscht werden, da noch Fertigungen existieren!';
    702004 :  vA # 'E:Konnte die Struktur nicht richtig verbuchen!';
    702005 :  vA # 'Q:Sollen alle Ausbringungen dieses Arbeitsganges automatisch in einen VSB-Arbeitsgang eingetragen werden?';
    702006 :  vA # 'I:Automatische VSBs erfolgreich generiert!'
    702007 :  vA # 'E:Automatische VSBs konnten NICHT angelegt werden!!!'
    702008 :  vA # 'E:Diese Position kann nicht fertiggemeldet werden!';
    702009 :  vA # 'E:Diese Position ist bereits gelöscht bzw. fertiggemeldet!';
    702010 :  vA # 'Q:Durch das Abschließen würden insgesamt %1% Schrott erzeugt!%CR%(%2% %)%CR%Position wirklich abschließen?';
    702011 :  vA # 'I:Position wurde erfolgreich abgeschlossen!';
    702012 :  vA # 'E:FEHLER: Position konnte NICHT abgeschlossen werden! (Code %1%)';
    702013 :  vA # 'E:Position kann nicht gelöscht werden, da noch ein Einsatz existiert!';
    702014 :  vA # 'E:Fahraufträge bitte über den Lieferschein fertigmelden!';
    702015 :  vA # 'Q:Mindestens eine Position wurde durch einen anderen User in eine Feinplanung aufgenommen!%CR%Sollen trotzdem Ihre Daten gespeichert werden?';
    702016 :  vA # 'Q:Wollen Sie diese Feinplanung vorm Verlassen speichern?';
    702017 :  vA # 'Q:Sollen alle Ausbringungen ALLER Arbeitsgänge automatisch in einen VSB-Arbeitsgang eingetragen werden?';
    702018 :  vA # 'Q:Es fehlen eigentlich noch %1%!%CR%Position wirklich abschließen?';
    702019 :  vA # 'E:Bitte wählen Sie zunächst einen Arbeitsgang auf der rechten Seite aus!';
    702020 :  vA # 'E:Arbeitsgang %1% konnte nicht gelesen und gesperrt werden!';
    702021 :  vA # 'E:Das Versandmodul ist nicht aktiv!';
    702022 :  vA # 'Q:Soll der Arbeitsgang %1% für den Betriebsauftrag %2% mit den theoretischen Ausbringungswerten fertiggemeldet werden?';
    702023 :  vA # 'Q:Wünschen Sie Etiketten?';
    702024 :  vA # 'E:Mindestens ein Vorgänger dieses Arbeitsganges ist noch nicht abgeschlossen!';
    702025 :  vA # 'E:Fehler bei der Kostenbestimmung!%CR%Der Betriebsauftrag wird nicht abgeschlossen.';
    702026 :  vA # 'E:Fehler bei der Kostenbestimmung!%CR%Für geplante Schrottfertigungen wird mindestens eine Kostenträgerfertigung benötigt!%CR%Der Betriebsauftrag wird nicht abgeschlossen.';
    702027 :  vA # 'E:Fehler bei der Kostenbestimmung!%CR%Material %1% macht Probleme!!%CR%Der Betriebsauftrag wird nicht abgeschlossen.';
    702028 :  vA # 'W:ACHTUNG! Auftrag %1% hat nun %2% durch Prod. geplant, sollte aber nur %3% sein! (%4%% überliefert)';
    702029 :  vA # 'Q:Möchten Sie alle VSBs wirklich löschen?';
    702030 :  vA # 'E:VSBs konnten nicht gelöscht werden!';
    702031 :  vA # 'E:Der Betriebsauftrag %1% konnte nicht verändert werden!';
    702032 :  vA # 'E:Diese BA-Position konnte nicht zurückgeholt werden!';
    702033 :  vA # 'E:Diese Position kann nicht theoretisch fertiggemeldet werden,%CR%da die Entnahme vom Einsatz zur Fertiung nicht automatisch erkenntlich ist!%CR%Bitte manuell fertigmelden!';
    702034 :  vA # 'E:Mindestens einer der zugehörigen Lieferscheine wurde noch gar nicht verwogen!';
    702035 :  vA # 'Q:Sollen ALLE (Anzahl %1%) restlichen Einsatzmaterialien komplett gelöscht werden? (in Summe %2%Stk, %3%kg)';
    702036 :  vA # 'E:Bitte entfernen Sie vorher die VSB-Materialien!';
    702037 :  vA # 'E:Bitte tauschen oder entfernen Sie vorher die theoretischen Artikel!';
    702038 :  vA # 'E:Die nachfolgende Position %1% ist bereits abgeschlossen und diese müsste vorher auch rückgängig gemacht werden!';
    702039 :  vA # 'Q:Wollen Sie mehrere Walzschritte hintereinander planen?';
    702040 :  vA # 'E:FEHLER: Position konnte NICHT abgeschlossen werden, da der Schrottartikel %1% fehlt!';
    702041 :  vA # 'E:Es konnte kein BA-Position angelegt werden!';
    702042 :  vA # 'E:Für die Anlage von Walzschritten muss das erste Walzen auch Einsatzmaterial besitzen!';
    702043 :  vA # 'E:Für die Anlage von Walzschritten darf das gesamte Fertigmaterial keine Weiterbearbeitng besitzen!';
    702044 :  vA # 'E:Nur externe Produktionen können angefragt werden!';
    702045 :  vA # 'E:Diese Position hat den falschen Status mit "%1%"!';
    702046 :  vA # 'Q:Soll die Produktion hiermit abgeschlossen werden und die Reste automatisch zurückgemeldet werden?';
    702047 :  vA # 'E:Fehler bei der Kostenbestimmung!%CR%Position %1% macht Probleme!!%CR%Der Betriebsauftrag wird nicht abgeschlossen.';
    702048 :  vA # 'Q:Mindestens ein vorheriges Fahren ist noch offen und würde damit automatisch abgeschlossen werden!%CR%Ist das in Ordnung?';
    702049 :  vA # 'Q:Sollen auch alle Vorgänger-Positionen für den Betriebsauftrag %1% mit den theoretischen Ausbringungswerten fertiggemeldet werden?';
    702050 :  vA # 'Q:Sollen alle Fertigmeldungen storniert werden?';
    702051 :  vA # 'Q:Sollen alle folgenden Positionen zurückgeholt UND auch deren Fertigmeldungen storniert werden?';
    702052 :  vA # 'Q:Sollen alle folgenden Positionen nur zurückgeholt werden?';
    702053 :  vA # 'Q:Sollen alle Ausbringungen ALLER Arbeitsgänge automatisch in einen Versand- mit folgendem VSB-Arbeitsgang eingetragen werden?';
    702054 :  vA # 'E:Zum direkten Einbinden einer neuen Position, muss sie vom Typ "1 zu 1" mit autoamtischer Fertigung sein - das ist aber der Arbeitsang %1% nicht!';
    702055 :  vA # 'Q:Sollen alle Ausbringungen ALLER Arbeitsgänge automatisch in Folge verpackt, versendet und dann in einen VSB-Arbeitsgang eingetragen werden?';
    702056 :  vA # 'W:Achtung!%CR%Das Einsatzmaterial trägt Reservierungen und diese würden durch das theoretische Fertigmelden verlogen gehen!%CR%Trotzdem fortfahren?';
    702057 :  vA # 'Q:Durch das Abschließen würden insgesamt %1% Schrott erzeugt!%CR%Der prozentuale Anteil der Einsätze zur Verwiegung konnte nicht berechnet werden.%CR%Position wirklich abschließen?';

    702401 :  vA # 'Q:Soll der Vorlage-BA %1% aus dem Kundenauftrag mit eingefügt werden?';


    702440 :  vA # 'E:FEHLER: Lieferschein konnte NICHT verbucht werden!';
    702441 :  vA # 'E:FEHLER: Lieferschein %1% konnte NICHT gefunden werden!';
    702442 :  vA # 'E:FEHLER: Lieferscheinposition %1% konnte nicht gelöscht werden!';
    702443 :  vA # 'Q:Wollen Sie den Fahrauftrag mit den geplanten Mengen fertigmelden??';
    702444 :  vA # 'E:Position %1% kann nicht automatisch fertiggemeldet werden, da sie kein normales Material umfasst!';
    702445 :  vA # 'E:Position %1% ist bereits manuell fertiggemeldet worden!!';

    702500 :  vA # 'I:Die noch anzufragenden Positionen wurden markiert.';
    702501 :  vA # 'E:Es dürfen nur BA-Positionen mit Status "%1%" angefragt werden!';
    702502 :  vA # 'E:Die BA-Positionen %1% hat kein Einsatzaterial definiert und kann nicht so nicht angefragt werden';
    702503 :  vA # 'E:Zur BA-Position %1% existiert bereits eine Anfrage!';
    702504 :  vA # 'Q:Sollen zu den %1% markierten BA-Positionen eine Anfrage erstellt werden?';
    702505 :  vA # 'E:Die markierten BA-Positionen sind für verschiedene Lieferanten!';
    702506 :  vA # 'Q:Sollen zu den %1% markierten BA-Positionen dirket eine Bestellung erstellt werden?';

    703001 :  vA # 'E:Für die %1%. Fertigung gibt es bereits Fertigmeldungen!%CR%Darum kann sie nicht mehr gelöscht werden!';
    703002 :  vA # 'E:Die Fertigung %1% wird weiterverarbeitet und kann nicht gelöscht werden!';
    703003 :  vA # 'I:Die bisherige Fertigung wurde erfolgreich angepasst und eine neue generiert!';
    703004 :  vA # 'E:Die Aufteilung konnte nicht durchgeführt werden! %1%';
    703005 :  vA # 'E:Die Gewichtsvorgaben der Fertigungen passen nicht zusammen!';
    703006 :  vA # 'W:Die manuell eingetragene Teilungsanzahl bei Position %1% passt nicht zu den Vorgaben!';
    703007 :  vA # 'E:BA %3%%CR%Der erlaubte kgmm-Bereich von %1% bis %2% konnte durch die Teilung nicht erreicht werden!';
    703008 :  vA # 'E:Es konnte kein BA-Fertigung angelegt werden!';
    703009 :  vA # 'W:Bei der Kommission handelt es sich um einen Liefervertrag!';

    707001 :  vA # 'I:Fertigmeldung wurde ordnungsgemäß angelegt und verbucht';
    707002 :  vA # 'E:Die Fertigmeldung konnte NICHT verbucht werden! (Code %1%)';
    707003 :  vA # 'I:Fertigmeldung wurde erfolgreich storniert!';
    707004 :  vA # 'E:Fertigmeldung konnte NICHT gelöscht werden!';
    707005 :  vA # 'I:Bei Nettoverwiegungen darf das Bruttogewicht nicht dem Nettogewicht entsprechen und darf nicht NULL sein!';
    707006 :  vA # 'E:Bitte die Messwerte überprüfen!';
    707007 :  vA # 'E:Fehler beim Etikettendruck!%CR%Fertigung konnte nicht gelesen werden!';
    707008 :  vA # 'E:Fehler beim Etikettendruck!%CR%Verpackung konnte nicht gelesen werden!';
    707009 :  vA # 'E:Fehler beim Etikettendruck!%CR%Etikettendefinition %1% konnte nicht gelesen werden!';
    707010 :  vA # 'Q:Wollen Sie alle allgemeinen Reservierungen (z.B. aus Auftrag)%CR%des Einsatzmaterials übernehmen?';
    707011 :  vA # 'E:Der zugehörige Versandauftrag %1% konnte nicht verbucht werden!';
    707012 :  vA # 'E:Kein gültiges Einsatzmaterial!';
    707013 :  vA # 'I:Einsatzmaterial ist gültig!';
    707014 :  vA # 'Q:Soll diese Verwiegung aus der Produktion genommen werden und auf den Status GESPERRT gesetzt werden?';
    707015 :  vA # 'E:Fertigmaterial %1% konnte nicht im Bestand gefunden werden!';
    707016 :  vA # 'I:Die Beistellungen werden dadurch jetzt wieder in das Lager gebucht!%CR%Fortfahren?';
    707017 :  vA # 'E:Bitte die Beistellungen überprüfen!';
    707018 :  vA # 'W:Sie melden damit mehr fertig, als eingesetzt wird! (d.h. negativer Schrott)&CR&Wollen Sie wirklich fortfahren?';

    707100 :  vA # 'E:Material %1% trägt bereits weitere Aktionen und kann nicht storniert werden!';
    707101 :  vA # 'E:Fehler bei Anlage des Fertigmaterials!%CR%Ursprungsmaterial %1% konnte nicht gelesen werden!';
    707102 :  vA # 'E:Fehler bei Anlage des Fertigmaterials!%CR%Aktionslisteneintrag des Ursprungsmaterials %1% konnte nicht erstellt werden!';
    707103 :  vA # 'E:Fehler bei Anlage des Fertigmaterials!%CR%Fertigmaterial konnte nicht angelegt werden!';
    707104 :  vA # 'E:Fehler bei Anlage des Fertigmaterials!%CR%Die Reservierung des Fertigmaterials %1% konnte nicht angelegt werden!';
    707105 :  vA # 'E:Fehler bei Anlage des Fertigmaterials!%CR%Die theoretischen Ausbringungsdaten konnten nicht aktualisiert werden!';
    707106 :  vA # 'E:Fehler bei Anlage des Fertigmaterials!%CR%Die Reservierung konnte nicht erstellt werden!!';
    707107 :  vA # 'E:Fehler bei Anlage des Fertigmaterials!%CR%Die Fertigmenge konnte nicht aktualisiert werden!';
    707108 :  vA # 'E:Fehler bei Anlage des Fertigmaterials!%CR%Das Fertigmaterialidentifikation konnte nicht aktualisiert werden!';
    707109 :  vA # 'E:Fehler bei Anlage des Fertigmaterials!%CR%Der Lieferschein zum Fahrauftrag %1% konnte nicht aktualisiert werden!';
    707110 :  vA # 'E:Material %1% wird durch Lieferschein %2% verladen und muss vorher dort entfernt werden!';
//    707111 :  vA # 'W:Material %1% wird durch Lieferschein %2% verladen und müsste ggf. dort auch entfernt werden!';

    708001 :  vA # 'E:Die Menge der Beistellung muss positiv sein!';
    708002 :  vA # 'E:Materialnummerntausch kann nur bei Weiterbearbeitungen passieren, aber nie an einem Lagermaterial/Anfang vom BA!';

    711001 :  vA # 'E:Es sind nicht alle Streifen auf dem Messerplan verteilt!';
    711002 :  vA # 'Q:Der Messerbauplan weicht von den Fertigungen ab. Messerbauplan jetzt neu erstellen?';
  end;
  
  case aNr of
   //---
    800001 :  vA # 'E:#User konnte nicht gesperrt werden!'
    800002 :  vA # 'E:#User konnte nicht gespeichert werden!'
    800003 :  vA # 'E:#Berechtigung für [ %1% ] nicht ausreichend.'
    800004 :  vA # 'E:User [%1%] nicht vorhanden.'
    800005 :  vA # 'E:Der Vertretrunguser %1% exisitert nicht!'
    800006 :  vA # 'W:Der Vertretrunguser %1% hat selber auch einen Vertretrunguser %2% eingetragen!'
    800007 :  vA # 'Q:Dies würde das Passwort des User auf "%1%" resetten - fortfahren?'
    801001 :  vA # 'E:#Usergruppe konnte nicht gesperrt werden!'
    801002 :  vA # 'E:#Usergruppe konnte nicht gespeichert werden!'

    802001 :  vA # 'E:#Zuweisung existiert bereits!'
    802002 :  vA # 'Q:Zuweisung aufheben?'

    814000 :  vA # 'E:Währung %1% nicht gefunden!';
    814001 :  vA # 'E:#Währungsnr. %1%: Umrechnungskurs ist NULL!';

    815001 :  vA # 'E:Diese Lieferbedingung ist für Neuerfassung gesperrt!';

    816001 :  vA # 'E:Skontozeiten dürfen sich nicht überschneiden!';
    816002 :  vA # 'E:Skontozeit ist ungültig, Monatsüberschneidungen sind nicht möglich.';
    816003 :  vA # 'E:Diese Zahlungsbedingung ist für Neuerfassung gesperrt!';

    828001 :  vA # 'E:Der Arbeitsgang [ %1% ] ist in der Vorgabedatei nicht vorhanden.'
    828002 :  vA # 'E:Der Arbeitsgang %1% hat in der Vorgabedatei keine Auftragsart eingetragen!';

    831000 :  va # 'E:Der Arbeitsgang [ %1% ] ist bereits vorhanden.'

    842000 :  vA # 'Q:Wollen Sie die Aufpreise automatisch bestimmen?';

    844000 :  vA # 'Q:Es existiert bereits eine Inventurdatei vom %1%. %CR%Soll diese verworfen werden? ';
    844001 :  vA # 'I:Die Inventurdatei wurde erfolgreich eingelesen.';
    844002 :  vA # 'E:Die Inventurdatei konnte nicht eingelesen werden!';
    844003 :  vA # 'E:Der Name des Lagerplatzes ist zu lang. Für eine Inventur darf dieser maximal 15 Stellen lang sein!';
    844004 :  vA # 'E:Die alte Inventurdatei konnte nicht gelöscht werden!';
    844005 :  vA # 'Q:Sollen die Inventurdaten für die markierten Lagerplätze %CR%%1%übernommen werden?';
    844006 :  vA # 'I:Inventur erfolgreich verbucht.';
    844007 :  vA # 'E:Fehler beim Verbuchen der Inventur!';
    844008 :  vA # 'I:Bitte scannen Sie den zu prüfenden Lagerplatz ein, aktivieren am Scanner den Sendemodus und klicken Sie auf OK.';
    844009 :  vA # 'E:Fehler bei der Scannerkommunikation!%CR%Bitte prüfen Sie die Verbindung und ob der Scanner im Sendemodus ist.';
    844010 :  vA # 'E:Fehler beim Einlesen der gescannten Daten!';
    844011 :  vA # 'E:Der ausgewählte Lagerplatz stimmt nicht mit dem gescannten Lagerplatz überein!';

    844012 :  vA # 'I:Bitte scannen Sie die Umlagerungen ein, aktivieren am Scanner den Sendemodus und klicken Sie auf OK.';
    844013 :  vA # 'I:Umbuchung erfolgreich eingelesen.';
    844014 :  vA # 'E:Nicht alle Umbuchungen konnten erfolgreich gespeichert werden!%CR%Die Scannerdatei wurde nicht gelöscht um den Fehler nachzuvollziehen.';
    844015 :  vA # 'E:Die Scannerdatei enthält strukturelle Fehler!';
    844016 :  vA # 'E:Material (%1%) konnte nicht gelesen werden!';
    844017 :  vA # 'E:Lagerplatz (%1%) konnte nicht gelesen werden!';
    844018 :  vA # 'I:Die alten Inventurdateien wurden erfolgreich gelöscht.';
    844019 :  vA # 'I:Bitte scannen Sie die Lagerplätze, aktivieren am Scanner den Sendemodus und klicken Sie auf OK.';
    844020 :  vA # 'Q:Sollen die kompletten Inventurdaten übernommen werden?';
    844021 :  vA # 'Q:Sind Sie sicher dass alle temporären Inventurdaten gelöscht werden sollen?';
    844022 :  vA # 'E:Lagerplatz (%1%) konnte nicht gelesen werden! Der Name ist länger als 15 Zeichen.';
    844023 :  vA # 'I:Der eingegebene Lagerplatz ist länger als 15 Zeichen.%CR%Sollten Sie die Scannerinventur des Standardumfanges von %CR%Stahl Control benutzen, ist eine Inventur für diesen Lagerplatz%CR%nicht möglich.';
    844024 :  vA # 'E:Die Protokolldatei "%1%" konnte nicht erstellt werden.';

    890000 :  vA # 'E:Sie haben leider keine Berechtigung diese Onlinestatistik aufzurufen!';
    890001 :  vA # 'Q:Soll die komplette Statistik neu berechnet werden?';
    890002 :  vA # 'Q:Wollen Sie eine Anzeige in Excel?';
    890003 :  vA # 'Q:Sollen die Gewichte mit ausgegeben werden?';

    899001 :  vA # 'Q:Sind Sie sicher, dass Sie die komplette Statistik neu errechnen wollen?';

    902001 :  vA # 'E:%1%-Nummernkreis gesperrt durch: %2%%CR%Wiederholen?';
    902002 :  vA # 'E:#%1%-Nummernkreis konnte nicht erhöht werden!!!';
    902003 :  vA # 'E:#%1%-Nummernkreis konnte NICHT gelesen werden!!!%CR%!!! ABBRUCH !!!';
    903000 :  va # 'E:In den Settings fehlt die Angabe für [ %1% ]%CR%Bitte sofort nachtragen!';

    908000 :  vA # 'Q:Sind Sie sicher, dass Sie alle Job-Server Fehlermeldungen (%1%) löschen möchten?';

    910001 :  vA # 'E:Liste Nummer %1% nicht gefunden!';
    910002 :  vA # 'Q:Die Liste als XML-File erzeugen? (sonst Ausdruck)';
    910003 :  vA # 'I:XML-Datei %1% wurde erfolgreich erzeugt!';
    910004 :  vA # 'E:XML-Datei %1% konnte nicht erzeugt werden!';
    910005 :  vA # 'E:XML-Datei %1% konnte nicht erzeugt werden! Ausdruck wird angezeigt.';
    910006 :  vA # 'Q:Die Datei %1% existiert bereits!%CR%Wollen Sie die Datei überschreiben?';
    910007 :  vA # 'Q:Die Liste als Excel XML-File erzeugen? (sonst Ausdruck)';

    911001 :  vA # 'E:Keine Berechtigung für Listenausgabe!';
    911002 :  vA # 'E:Zuweisung existiert bereits!';
    911003 :  vA # 'Q:Zuweisung aufheben?';

    912001 :  va # 'Q:Soll das bereits gedruckte Dokument angezeigt werden?';
    912002 :  va # 'E:#Formular %1% nicht gefunden!';
    912003 :  vA # 'Q:Soll das FAX-Logo mit ausgegeben werden?';
    912004 :  vA # 'Q:Soll das E-Mail-Logo mit ausgegeben werden?';
    912005 :  vA # 'E:Sie haben keine Schreibberechtigung im Druckordner : '+Set.Druckerpfad;
    912006 :  vA # 'Q:Soll das Druck-Logo mit ausgegeben werden?';
    912007 :  va # 'Q:War die Vorschau in Ordnung und kann der Ausdruck nun erfolgen?';
    912008 :  vA # 'Q:Soll das Dokument archiviert werden?';
    912009 :  vA # 'E:Fehler bei Druckausgabe:%CR%%1%%CR%%2%';

    915001 :  vA # 'E:#Formulartyp unbekannt: %1%';
    915002 :  vA # 'E:DMS-System: %1%';

    916001 :  vA # 'E:Anhänge können nicht kopiert/verschoben werden!';
    916002 :  vA # 'Q:Die Datei %1% wurde verändert!%CR%Soll die veränderte Version in die Datenbank aufgenommen werden?';
    916003 :  vA # 'E:Diese Datei kann nicht gelöscht werden, da Verknüpfungen hierauf existieren!';
    916004 :  vA # 'Q:Soll die Datei nur verlinkt statt kopiert werden? (Nein = kopieren)';

    917001 :  vA # 'Q:Berechtigung für %1% entfernen?';
    917002 :  vA # 'Q:Diesen Ordner wirklich löschen?';
    917003 :  vA # 'Q:Diese Rechte an alle Adress-Strukturen vererben?';
    917004 :  vA # 'E:Sie haben keine Berechtigung zum Lesen!';
    917005 :  vA # 'E:Sie haben keine Berechtigung zum Ändern!%1%';
    917006 :  vA # 'E:Sie haben keine Berechtigung zum Erstellen!';
    917007 :  vA # 'E:Sie haben keine Berechtigung zum Löschen!';
    917008 :  vA # 'Q:Die Datei %1% wirklich endgültig löschen?';
    917009 :  vA # 'Q:Mindestens eine der Dateien existiert bereits!%CR%Alle überschreiben?'
    917010 :  vA # 'E:Verzeichnis %1% nicht erstellbar!';
    917011 :  vA # 'Q:Zusätzlich anhängen?'

    921000 :  vA # 'E:Sonderfunktion konnte nicht korrekt ausgeführt werden!';
    921001 :  vA # 'I:Ausführung der Sonderfunktion abgeschlossen.';
    921002 :  vA # 'E:Sie haben leider keine Berechtigung für diese Sonderfunktion!';

    // SOA : 960
    960101 : vA # 'E:Allgemeiner Service Fehler';
    960102 : vA # 'E:Protokollierungsfehler';
    960103 : vA # 'E:Das Protokoll konnte nicht erweitert werden';
    960104 : vA # 'E:Der passende Protokolleintrag konnte nicht gefunden werden';
    960105 : vA # 'E:Der passende Protokolleintrag konnte nicht aktualisiert werden';
    960106 : vA # 'E:Protokollierungsfehler: Logdatei konnte nicht angelegt werden.';
    960107 : vA # 'E:Protokollierungsfehler: LogVerzeichnis konnte nicht angelegt werden.';

    960201 : vA # 'E:Keine Stahl Control Version angegeben';
    960202 : vA # 'E:Die Stahl Control Version ist nicht mit dem Server nicht kompatibel';
    960203 : vA # 'E:Kein Service angegeben';
    960204 : vA # 'E:Kein Servicebenutzer angegeben';
    960205 : vA # 'E:Der angeforderte Service wurde nicht gefunden';
    960206 : vA # 'E:Der angeforderte Service wird zur Zeit nicht angeboten';
    960207 : vA # 'E:Der angeforderte Service steht zur Zeit nicht zur Verfügung';
    960208 : vA # 'E:Autorisierung für den angeforderten Service fehlgeschlagen';
    960209 : vA # 'E:Autorisierung für den angeforderten Service fehlgeschlagen. Bitte Serviceanbieter kontaktieren';
    960210 : vA # 'E:Autorisierung für den angeforderten Service fehlgeschlagen. Bitte Zugangsdaten prüfen.';

    960301 : vA # 'E:Argumentfehler';
    960302 : vA # 'E:Argument nicht gefunden';
    960303 : vA # 'E:Argument hat keinen Wert';
    960304 : vA # 'E:Argumentwert zu klein';
    960305 : vA # 'E:Argumentwert zu groß';
    960306 : vA # 'E:Argumentwert entspricht nicht dem gewünschten Typ';
    960307 : vA # 'E:Argumentwert entspricht nicht der möglichen Werte';


    981001 : vA # 'Q:Sollen die %1% markierten Sätze als Anker eingetragen werden?';
    981002 : vA # 'E:Anker konnte nicht angelegt werden!';

    990001 :  vA # 'E:#Protokollpuffer belegt!';
    990002 :  vA # 'E:#Protokollpuffer leer! (forget)';
    990003 :  vA # 'E:#Protokollpuffer leer! (compare)';
    990010 :  vA # 'E:#Protokollsatz konnte nicht angelegt werden!';

    997000 :  vA # 'E:Tränencoils können nicht berechnet werden!';

    997001 :  vA # 'W:Bitte wählen Sie das zu ändernde Feld aus...';
    997002 :  vA # 'Q:Sind Sie sicher, dass Sie in den %1% markierten Sätze das Feld "%2%" mit "%3%" beschreiben wollen?';
    997003 :  vA # 'I:Die markierten Sätze wurden erfolgreich verändert!';
    997004 :  vA # 'E:Nicht alle markierten Sätze konnten geändert werden!!!%CR%Es wurde ALLES rückgängig gemacht!';
    997005 :  vA # 'Q:Sollen die Markierungen aufgehoben werden?';
    997006 :  vA # 'I:Sie haben keinen passenden Datensatz markiert!';
    997007 :  vA # 'Q:Für die %1% markierten Datensätze durchführen?';
    997008 :  vA # 'Q:Soll nun überall "%1%" mit "%2%" ausgetauscht werden (kann etwas dauern)?';
    997009 :  vA # 'W:Die Zielnummer "%2%" gibt es bereits! Damit würden alle Sätze der Nummer "%1%" damit ZUSAMMENGELEGT werden! Das ist IRREVERSIBEL! Wirklich fortfahren?';

    998000 :  vA # 'Q:Listengenerierung dauert ungewohnt lange%CR%Liste abbrechen?';
    998001 :  vA # 'I:TELEFON!!!%CR%Interner Anruf von Apparat %1%';
    998002 :  vA # 'I:TELEFON!!!%CR%Anruf von %1%';
    998003 :  vA # 'Q:Wollen Sie ALLE Daten dieser Tabelle nach %1% exportieren?';
    998004 :  vA # 'I:Datei %1% geschrieben!%CR%Anzahl der Sätze: %2%';
    998005 :  vA # 'Q:Wollen Sie ALLE Daten der Datei %1% einlesen?';
    998006 :  vA # 'I:Datei %1% eingelesen!%CR%Anzahl der Sätze: %2%';
    998007 :  vA # 'E:Das Visualisierungstool GRAPHVIZ scheint nicht installiert zu sein!';
    998008 :  vA # 'E:Dafür müssen alle anderen Benutzer die Datenbank verlassen!';
    998009 :  vA # 'W:Vor einer Diagnose ist UNBEDINGT EIN BACKUP manuell anzulegen!!!%CR%Diagnose jetzt starten?';
    998010 :  vA # 'W:Vor einer Optimierung ist UNBEDINGT EIN BACKUP manuell anzulegen!!!%CR%Optimierung jetzt starten?';
    998011 :  vA # 'Schlüsselreorgansisation jetzt starten?';
    998012 :  vA # 'Q:Wollen Sie nur die MARKIERTEN Daten dieser Tabelle nach %1% exportieren?';
    998013 :  vA # 'Q:Wollen Sie die Markierungen aufheben?';
    998014 :  vA # 'W:Bitte schließen Sie zunächst alle Unterfenster!';
    998015 :  vA # 'E:Datei %1% konnte nicht beschrieben werden!';
    998016 :  vA # 'I:Datei %1% erfolgreich angelegt!';
    998017 :  vA # 'E:Die Datei passt nicht zu diesem Dialog!%CR%%1%';
    998018 :  vA # 'E:Es existiert bereits eine Datei mit diesem Namen!&CR&Bitte neuen Namen vergeben...';

    999001 :  vA # 'E:Programm-Lizenz nicht gefunden!';
    999002 :  vA # 'E:Programm-Lizenz nicht korrekt!';
    999003 :  vA # 'E:Programm-Lizenz nicht passend für dieses Produkt!';
    999004 :  vA # 'E:Programm-Lizenz passt nicht zu den Datenbank-Lizenzen!';
    999005 :  vA # 'E:Programm-Lizenz ist abgelaufen!';
    999010 :  vA # 'E:Useranzahl für diese Programm-Lizenz zu hoch!';
    999011 :  vA # 'E:Job-Server-Anzahl für diese Programm-Lizenz zu hoch!';
    999012 :  vA # 'E:Betriebs-Useranzahl für diese Programm-Lizenz zu hoch!';

    999050 :  vA # 'Q:Wollen Sie eine neue/andere Programm-Lizenz installieren?';
    999051 :  vA # 'I:Programm-Lizenz eingespielt - Bitte neu starten!';
    999998 :  vA # 'I:Erfolgreich!';
    999999 :  vA # 'E:!!! ALLGEMEINER FEHLER !!!%CR%%1%';

    otherwise if (vA='') then
              vA # '#unknown error: '+CnvAI(aNr)+', %1% %2% %3% %4% %5%';
  end;

  RETURN vA;
end;


//========================================================================
//========================================================================
Sub ParseMsg(
  aNr           : int;
  aPara         : alpha(1000);
  var aSymbols  : int;
  var aButtons  : int;
) : alpha
local begin
  vA,vB   : alpha(4000);
  vA1     : alpha(4000);
  vA2     : alpha(4000);
  vA3     : alpha(4000);
  vA4     : alpha(4000);
  vA5     : alpha(4000);
  vX      : int;
end;
begin
  vB # gUserSprache;
  if (vB='D') or (vB='') then
    vA # Lib_messages:Fehlertext(aNr)
  else
    vA # Call('Lib_Messages_'+vB+':Fehlertext', aNr);

  // Testzwecke
//  vA # vA +StrChar(13)+'Debugcode: '+cnvai(aNr);

  // Symbol ermitteln
  if (StrCut(vA,2,1)=':') then begin
    case StrCut(vA,1,2) of
      'Q:' : begin
        aSymbols # _WinIcoQuestion;
        if (aButtons=0) then aButtons # _WinDialogYesNo;
        end;
      'E:' : aSymbols # _WinIcoError;
      'W:' : aSymbols # _WinIcoWarning;
      'I:' : aSymbols # _WinIcoInformation;
      'A:' : aSymbols # _WinIcoApplication;
    end;
    vA # StrCut(vA,3,999);
  end;

  vA1 # Str_Token(aPara,'|',1);
  vA2 # Str_Token(aPara,'|',2);
  vA3 # Str_Token(aPara,'|',3);
  vA4 # Str_Token(aPara,'|',4);
  vA5 # Str_Token(aPara,'|',5);

  vX # strfind(vA,'%1%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA1+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%2%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA2+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%3%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA3+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%4%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA4+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%5%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA5+StrCut(vA,vX+3,999);

  // alle _CR_zu CR umwanden
  REPEAT
    vX # strfind(vA,'%CR%',0);
    if vX<>0 then
      vA # StrCut(vA,1,vX-1)+StrChar(13)+StrCut(vA,vX+4,999);
  UNTIL (vX=0);
  
  RETURN vA;
end;


//========================================================================
//  Msg
//      Gibt eine Meldung aus
//      Sonderzeichen
//      '%x%': X=1,2,3,4,5 = Platzhalter für Token
//      '%CR$': Carriage Return
//      Start 'Q:' = _WinIcoQuestion;
//      Start 'E:' = _WinIcoError;
//      Start 'W:' = _WinIcoWarning;
//      Start 'I:' = _WinIcoInformation;
//      Start 'A:' = _WinIcoApplication;
//      1.Zeichen '#' = Fehler wird protokolliert
//
//
//========================================================================
sub Messages_Msg(
  aNr         : int;
  aPara       : alpha(4000);
  aSymbols    : int;
  aButtons    : int;
  aPreselect  : int;
  opt aProc   : alpha(4000);
) : int
local begin
  vA,vB   : alpha(4000);
  vText   : alpha(300);
  vOldF   : int;
  vButton : int;
  vFile   : int;
  vOK     : logic;
  vTitle  : alpha(500);
  vIsJobServer  : logic;
  vMDI    : int;
end;
begin

//RETURN Lib_Messages_NL:Messages_Msg(aNr, aPara, aSymbols, aButtons, aPreselect, aProc);

/*
  if (VarInfo(varSysPublic)<>0) then begin
    if (ErrMsg<>0) then begin
      vX # ErrMsg;
      ErrMsg # 0;
      Messages_Msg(vX,'',0,0,0);
    end;
  end;
*/

// mögliche Symbole, Buttons, Ergebnisse:
//
// _WinIcoApplication, _WinIcoError,_WinIcoInformation,
// _WinIcoWarning,_WinIcoQuestion
//
// _WinDialogOk, _WinDialogOkCancel, _WinDialogYesNo,
// _WinDialogYesNoCancel
//
//
// ERGEBNIS:
// _WinIdOk, _WinIdCancel, _WinIdYes, _WinIdNo

//  vA # FehlerText(aNr);
/***
  case (gUserSprachnummer) of
    1 : vB # Set.Sprache1.Kurz;
    2 : vB # Set.Sprache2.Kurz;
    3 : vB # Set.Sprache3.Kurz;
    4 : vB # Set.Sprache4.Kurz;
    5 : vB # Set.Sprache5.Kurz;
  //  2 : vA # Lib_messages_NL:Fehlertext(aNr);
  //  2 : vA # Lib_messages_E:Fehlertext(aNr);
  //  otherwise
  //    vA # Lib_messages:Fehlertext(aNr)
  end;
***/
/****
  vB # gUserSprache;
  if (vB='D') or (vB='') then
    vA # Lib_messages:Fehlertext(aNr)
  else
    vA # Call('Lib_Messages_'+vB+':Fehlertext', aNr);

  // Testzwecke
//  vA # vA +StrChar(13)+'Debugcode: '+cnvai(aNr);

  // Symbol ermitteln
  if (StrCut(vA,2,1)=':') then begin
    case StrCut(vA,1,2) of
      'Q:' : begin
        aSymbols # _WinIcoQuestion;
        if (aButtons=0) then aButtons # _WinDialogYesNo;
        end;
      'E:' : aSymbols # _WinIcoError;
      'W:' : aSymbols # _WinIcoWarning;
      'I:' : aSymbols # _WinIcoInformation;
      'A:' : aSymbols # _WinIcoApplication;
    end;
    vA # StrCut(vA,3,999);
  end;

  vA1 # Str_Token(aPara,'|',1);
//  aPara # Str_Token(aPara,'|',2);
  vA2 # Str_Token(aPara,'|',2);
//  aPara # Str_Token(aPara,'|',2);
  vA3 # Str_Token(aPara,'|',3);
//  aPara # Str_Token(aPara,'|',2);
  vA4 # Str_Token(aPara,'|',4);
//  aPara # Str_Token(aPara,'|',2);
  vA5 # Str_Token(aPara,'|',5);
//  aPara # Str_Token(aPara,'|',2);

  vX # strfind(vA,'%1%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA1+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%2%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA2+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%3%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA3+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%4%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA4+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%5%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA5+StrCut(vA,vX+3,999);

  // ggf. Protokolldatei mitschreiben
  if (StrCut(vA,1,1)='#') then begin
    vA # StrCut(vA,2,250);
    vText # CnvAD(Today)+':'+CnvAT(Now)+'|'+cnvAI(aNr)+'|'+vA+'|'+gUserName;
    vText # vText + strchar(13) + strchar(10);
    vFile # FSIOpen(cProtokollDatei,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
    if (vFile>0) then begin
      FsiWrite(vFile, vText);
      FsiClose(vFile);
    end;
  end;

  // alle _CR_zu CR umwanden
  REPEAT
    vX # strfind(vA,'%CR%',0);
    if vX<>0 then
      vA # StrCut(vA,1,vX-1)+StrChar(13)+StrCut(vA,vX+4,999);
  UNTIL (vX=0);
***/

  aPara # Strcut(aPara, 1, 1000);
  // 30.05.2018 AH : als SUB
  vA # ParseMsg(aNr, aPara, var aSymbols, var aButtons);
  
  // ggf. Protokolldatei mitschreiben
  if (StrCut(vA,1,1)='#') then begin
    vA # StrCut(vA,2,250);
    vText # CnvAD(Today)+':'+CnvAT(Now)+'|'+cnvAI(aNr)+'|'+vA+'|'+gUserName;
    vText # vText + strchar(13) + strchar(10);
    vFile # FSIOpen(cProtokollDatei,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
    if (vFile>0) then begin
      FsiWrite(vFile, vText);
      FsiClose(vFile);
    end;
  end;

  // ST 2020-08-19: ggf. auf Variablenlänge begrenzen
  //if (TransActive) then vA # '!!! TRANSACTION OPEN !!! '+StrChar(13)+vA;
  if (TransActive) then vA # StrCut('!!! TRANSACTION OPEN !!! '+StrChar(13)+vA,1,500);

  // ST 2018-04-17: Bei Jobserver oder SOA, dann "simple" in Errormeldung umwandeln
  vIsJobServer  # (gUsergroup = 'SOA_SERVER') OR (gUsergroup = 'JOB-SERVER');
  if (vIsJobServer) then begin
    ERROR(99,vA);
    RETURN _WinIdCancel;    // Klappt, wenn die Abfragen Positive Angaben abfragen
  end;
  

  if (VarInfo(windowbonus)<>0) then
    vTitle # gTitle
  else
    vTitle # cPrgName;
  if (aSymbols=_WinIcoError) then begin
    vTitle # vTitle + '('+cnvai(aNr)+')';
    if (aProc<>'') then vA # vA + ' (P:'+aProc+')';
  end;

  vOldF # WinFocusGet();


  // Falls es eine TRAY ist...
  if (gFrmMain<>0) then begin
    if (Wininfo(gFrmMain,_wintype)=_WinTypeTrayFrame) then begin
      vButton # WindialogBox(gFrmMain,cPrgName,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect);
      RETURN vButton;
    end;
    // auf jeden Fall Anwendung aktivieren....
    APPON();
  end;


  if (gMdi<>0) then begin
    TRY begin
      Winpropget(gMDI,_Winpropname,vB);
    END
    if (errGet()=_rOK) then begin
      vOK # y;
//      gMDI->wpdisabled # y;
vMDI # gMDI;
//debugx(aint(VarInfo(windowbonus)));
      if (VarInfo(windowbonus)<>0) then
        vButton # WindialogBox(gFrmMain,vTitle,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect)
// 03.03.2021 AH wieder APPFRAME        vButton # WindialogBox(gMDI,vTitle,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect)
      else
        vButton # WindialogBox(gFrmMain,cPrgName,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect);
// 03.03.2021 AH wieder APPFRAME        vButton # WindialogBox(gMDI,cPrgName,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect);
//debugx(aint(VarInfo(windowbonus)));
WinFocusset(vMDI);  // 03.03.2021 AH
//debugx(aint(VarInfo(windowbonus)));
//      gMDI->wpdisabled # n;
    end;
  end;
  if (vOK=n) then begin
    vButton # WindialogBox(gFrmMain,cPrgName,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect);
  end;

  if (vOldF<>0) then begin
    Try begin
      ErrTryIgnore(_ErrHdlInvalid);
//      vOldf # vOldf + 123;
      vOldF->WinFocusSet();
    end;
  end;
  RETURN vButton;

end;



/*
========================================================================
2023-03-16  DS                                               intern

übernimmt dieselben Aufgaben wie Messages_Msg, und schreibt zusätzlich
ins Log. Dabei werden zusätzliche Metadaten verwendet, die vom
aufrufenden Makro

Def_Global_Sys:Msg

bereitgestellt werden, so dass sie durch die wiederum dieses
rufenden Shortcut-Makros

Def_Global:MsgErr
Def_Global:MsgWarn
Def_Global:MsgInfo

NICHT bereitgestellt werden müssen.
========================================================================
*/
sub Messages_Msg_WrapperWithLog(
  // Argumente die zu Messages_Msg gehören
  aNr         : int;
  aPara       : alpha(4000);
  aSymbols    : int;
  aButtons    : int;
  aPreselect  : int;
  // Argumente die zu Lib_Logging:_toLog gehören
  procfunc    : alpha(256);
  line        : int;
  // Erx, Erm, Lvl werden anderweitig gefüllt, siehe Code
) : int
local begin
  vLvl : int;
  vErm : alpha(8192);
  vRetVal_of_Messages_Msg : int;
  vSepPadded : alpha(3);
end;
begin

  vSepPadded # ' ' + Lib_Logging:getSeparator() + ' ';

  // Als erstes die Funktionalität der regulären Messages_Msg Funktion durch
  // Aufruf dieser nachbilden...
  vRetVal_of_Messages_Msg # Messages_Msg(aNr, aPara, aSymbols, aButtons, aPreselect);
  
  // Error Message vErm analog zu Messages_Msg bestimmen:
  aPara # StrCut(aPara, 1, 1000);
  vErm # ParseMsg(aNr, aPara, var aSymbols, var aButtons);
  
  // gesamte Information in vErm sammeln:
  vErm #
    aPara + vSepPadded +
    'Messages_Msg() user answer: ' + aint(vRetVal_of_Messages_Msg) + vSepPadded +
    'ParseMsg() resulting text: ' + Strcut(vErm, 1, 5000);
  
  // Symbol auf Log Level mappen:
  case aSymbols of
    _WinIcoInformation : vLvl # cLogInfo;
    _WinIcoWarning     : vLvl # cLogWarn;
    _WinIcoError       : vLvl # cLogErr;
  otherwise
    // default, falls keiner der explizit behandelten Fälle zutrifft
    vLvl # aSymbols;  // lasse unbekanntes log level weiter downstream geeignet behandeln
  end
  
  // ...dann Logging aufrufen
  Lib_Logging:_toLog(
    procfunc,
    line,
    cErxNA, // Erx ist nicht zwangsläufig verfügbar an allen Aufrufstellen der Msg* Makros, daher kenntlich machen dass es nicht verfügbar ist. aNr ist kein Erx!
    vErm,   // verwende die ggf. analog zu Messages_Msg verdaute und erweiterte Fehlernachricht vErm von oben
    vLvl    // Loglevel wird durch Interpretation des Symbols festlgelegt, s.o.
  );
  
  return vRetVal_of_Messages_Msg;

end;



/***
//========================================================================
//  MsgBox
//          Gibt eine Meldung aus
//========================================================================
sub Error_MsgBox(
  aWindow   : int;
  aTitle    : alpha;
  aText     : alpha;
  aSymbols  : int;
  aButtons  : int;
  aPreselect : int;
): int
local begin
  vX,vY : int;
end;
begin
  vY # WinFocusGet();
  vX # WinDialogBox(aWindow,aTitle,aText,aSymbols,aButtons,aPreselect);
  if (vY<>0) then vY->WinFocusSet();
  RETURN vX;
end;
***/




/*
========================================================================
2023-03-16 DS                                               intern

Test der Makros
Def_Global:MsgErr
Def_Global:MsgWarn
Def_Global:MsgInfo
die auf Def_Global_Sys:Msg basieren, was wiederum _Error_WrapperWithLog
aufruft.
========================================================================
*/
sub test_MsgErr_MsgWarn_MsgInfo
()
local begin
  vDescription : alpha(1024);
  vResult : int;
end
begin

  vDescription # 'TEST: Error()-Makro'
  ErrorOutputWithDisclaimerPre(vDescription);
  
  vResult # MsgErr(99, 'Ein durch MsgErr(99, ...) ins Log geschriebener Error');
  DebugM('vResult: ' + aint(vResult));
  vResult # MsgErr(000005, 'Ein durch MsgErr(000005, ...) ins Log geschriebener Error');
  DebugM('vResult: ' + aint(vResult));
  vResult # MsgWarn(99, 'Eine durch MsgWarn(99, ...) ins Log geschriebene Warning');
  DebugM('vResult: ' + aint(vResult));
  vResult # MsgWarn(000006, 'Eine durch MsgWarn(000006, ...) ins Log geschriebene Warning');
  DebugM('vResult: ' + aint(vResult));
  vResult # MsgInfo(99, 'Eine durch MsgInfo(99, ...) ins Log geschriebene Information');
  DebugM('vResult: ' + aint(vResult));
  vResult # MsgInfo(000007, 'Eine durch MsgInfo(000007, ...) ins Log geschriebene Information');
  DebugM('vResult: ' + aint(vResult));
  
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
  
  
  test_MsgErr_MsgWarn_MsgInfo();
 

  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;
  
end


//========================================================================
