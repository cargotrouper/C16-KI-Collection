@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_SWe_000001
//                  OHNE E_R_G
//  Info
//    Stellt die ServiceAPIs und Implementierungen bereit:
//      Erstellung von Sammelwareneingängen : CREATESWE
//
//
//  02.10.2010  ST  Erstellung der Prozedur
//  07.07.2022 MR Deadlockfix aus Lib_Soa:ReadNummer in  sub createSwe_Exec
//  Subprozeduren
//    SUB
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API

define begin
  errAbort(a,b) : begin SOA_TRANSBRK;aResponse->addErrNode(a,b); return errPrevent; end;
  get(a)        : vNode->getValue(toUpper(a))
end;



//=========================================================================
// sub CREATESWE_Api() : handle
//
//  Definiert die API Beschreibung (Servicevertrag) für den implementierten
//  Service.
//
//  DESIGNENTSCHEIDUNG
//    Diese Methode muss in jedem Service implementiert sein; wird für folgende
//    Zwecke benutzt:
//      1) Prüfung der übergebenen Argumente
//      2) Ausgabe der API für den Benutzer mit Beispieldaten
//
//  @Return
//    handle                      // Handle des XML Dokumentes der API
//
//=========================================================================
sub createSwe_Api() : handle
local begin
  vAPI   : handle;
  vNode  : handle;
  vHead  : handle;
  vPos   : handle;
end
begin

  // --------------------------------------------------
  // Standardapi erstellen für "Schreiben" erstellen
//  vApi # apiCreateStd(true);
  vApi # apiCreateStd();

  // ----------------------------------
  // Speziele Api-Definition ab hier


  // Hauptknoten für Kopfdaten
  vHead # vApi->apiAdd('SWE',_TypeAlpha,false);
  vHead->apiSetDesc('Startknoten der Kopfdaten der Lieferavisierung; muss angegeben werden','SWe');

    // Vorgangsnummer
    vNode # vHead->apiAdd('Vorgangsnr',_TypeAlpha,false);
    vNode->apiSetDesc('Ihre allgemeine Vorgangsnummer','V123456');
    vNode->apiSetIntern('SWe.Vorgangsnr');

    // Liefertermin
    vNode # vHead->apiAdd('Termin',_TypeDate,false);
    vNode->apiSetDesc('allgemeiner Anlieferungstermin','15.07.2010');
    vNode->apiSetIntern('SWe.Termin');

    // Bemerkung 1
    vNode # vHead->apiAdd('Bemerkung1',_TypeAlpha,false);
    vNode->apiSetDesc('allgemeiner Bemerkungstext 1','Laut Besprechung vom .....');
    vNode->apiSetIntern('SWe.Bemerkung1');

    // Bemerkung 2
    vNode # vHead->apiAdd('Bemerkung2',_TypeAlpha,false);
    vNode->apiSetDesc('allgemeiner Bemerkungstext 2','...letzten Besuch bei Ihnen...');
    vNode->apiSetIntern('SWe.Bemerkung2');

    // Versandart
    vNode # vHead->apiAdd('Versandart',_TypeAlpha,false);
    vNode->apiSetDesc('Versandartnr laut Feld VsA.Nummer aus Service: KEYFILE Datei=817','3');
    vNode->apiSetIntern('SWe.Versandart');

    // Ursprungsland
    vNode # vHead->apiAdd('Ursprungsland',_TypeAlpha,false);
    vNode->apiSetDesc('Kennzeichnung des Ursprungslandes laut Feld Lnd.Kürzel aus Service KEYFILE Datei=812','DK');
    vNode->apiSetIntern('SWe.Ursprungsland');

    // Positionsknoten
    vPos # vHead->apiAdd('Pos',_TypeAlpha,false);
    vPos->apiSetDesc('Positionsknoten für Positionsangaben','Pos');

      // RefID
      vNode # vPos->apiAdd('Refid',_TypeAlpha,false);
      vNode->apiSetDesc('Ihre eindeutige Referenznummer zur Avisposition für Weiterverarbeitung in Ihrer Applikation','UID123-DSA');

      // ----------------------------------------------------
      //  Hauptdaten

      // Referenznummer
      vNode # vPos->apiAdd('Referenznummer',_TypeAlpha,false);
      vNode->apiSetDesc('Ihre Referenznummer zur Avisposition','V123456/3');
      vNode->apiSetIntern('SWe.P.Referenznr');

      // Avisiserungsdatum
      vNode # vPos->apiAdd('Avisiertzum',_TypeDate,false);
      vNode->apiSetDesc('Datum des geplanten Eingangs des Materials','01.08.2010');
      vNode->apiSetIntern('SWe.P.Avis_Datum');

      // Lieferscheinnummer
      vNode # vPos->apiAdd('Lieferscheinnr',_TypeAlpha,false);
      vNode->apiSetDesc('Lieferscheinnummer der Avisierung','LFS123/2');
      vNode->apiSetIntern('SWe.P.Lieferscheinnr');

      // Stückzahl
      vNode # vPos->apiAdd('Stückzahl',_TypeInt,true);
      vNode->apiSetDesc('Stückzahl des Materials','2');
      vNode->apiSetIntern('SWe.P.Stückzahl');

      // Gewicht
      vNode # vPos->apiAdd('Gewicht',_TypeFloat,true);
      vNode->apiSetDesc('Nenngewicht des Materials in kg','25.000');
      vNode->apiSetIntern('SWe.P.Gewicht');

      // Verwiegungsart
      vNode # vPos->apiAdd('Verwiegungsart',_TypeInt,false);
      vNode->apiSetDesc('Verwiegungsart des Materials; Verwiegungsarten laut VwA.Nummer aus Service KEYFILE(818)','2');
      vNode->apiSetIntern('SWe.P.Verwiegungsart');

      // Gewicht Netto
      vNode # vPos->apiAdd('Nettogewicht',_TypeFloat,false);
      vNode->apiSetDesc('Nettogewicht des Materials','24.780');
      vNode->apiSetIntern('SWe.P.Gewicht.Netto');

      // Gewicht Brutto
      vNode # vPos->apiAdd('Bruttogewicht',_TypeFloat,false);
      vNode->apiSetDesc('Bruttogewicht des Materials','25.057');
      vNode->apiSetIntern('SWe.P.Gewicht.Brutto');

      // Intrastatnummer
      vNode # vPos->apiAdd('Intrastatnr',_TypeAlpha,false);
      vNode->apiSetDesc('Intrastatnummer für Lieferungen innerhalb der EG','...');
      vNode->apiSetIntern('SWe.P.Intrastatnr');

      // Coilnummer
      vNode # vPos->apiAdd('Coilnummer',_TypeAlpha,false);
      vNode->apiSetDesc('Coilnummer des Mateials','C123');
      vNode->apiSetIntern('SWe.P.Coilnummer');

      // Ringnummer
      vNode # vPos->apiAdd('Ringnummer',_TypeAlpha,false);
      vNode->apiSetDesc('Ringnummer für gefertiges Material','C123/2/1');
      vNode->apiSetIntern('SWe.P.Ringnummer');

      // Chargennummer
      vNode # vPos->apiAdd('Chargennummer',_TypeAlpha ,false);
      vNode->apiSetDesc('Chargennummer des Materials','CH1234');
      vNode->apiSetIntern('SWe.P.Chargennummer');

      // Werksnummer
      vNode # vPos->apiAdd('Werksnummer',_TypeAlpha ,false);
      vNode->apiSetDesc('Werksnummer des  Materials','W123');
      vNode->apiSetIntern('SWe.P.Werksnummer');

      // Gütenstufe
      vNode # vPos->apiAdd('Gütenstufe',_TypeAlpha ,false);
      vNode->apiSetDesc('Güteneinstufung des Materials; frei beschreibbar oder Feld MQu.S.Stufe aus Service KEYFILE Datei=848','1A');
      vNode->apiSetIntern('SWe.P.Gütenstufe');

      // Güten
      vNode # vPos->apiAdd('Güte',_TypeAlpha ,false);
      vNode->apiSetDesc('Güte des Materials; frei beschreibbar oder Feld MQu.Güte1 aus Service KEYFILE Datei=832','1A');
      vNode->apiSetIntern('SWe.P.Güte');

      // Ausführung oben
      vNode # vPos->apiAdd('AusführungOben',_TypeAlpha ,false);
      vNode->apiSetDesc('Oberflächenbeschaffenheit der Oberseite; frei beschreibbar oder Verkettung aus Obf.Kürzel aus Service KEYFILE Datei=841, mit Komma getrennt','BZ,ÖL');
      vNode->apiSetIntern('SWe.P.AusfOben');

      // Ausführung unten
      vNode # vPos->apiAdd('AusführungUnten',_TypeAlpha ,false);
      vNode->apiSetDesc('Oberflächenbeschaffenheit der Unterseite; frei beschreibbar oder Verkettung aus Obf.Kürzel aus Service KEYFILE Datei=841, mit Komma getrennt','BZ,ÖL');
      vNode->apiSetIntern('SWe.P.AusfUnten');

      // Warengruppe
      vNode # vPos->apiAdd('Warengruppe',_TypeInt ,true);
      vNode->apiSetDesc('Warengruppe des Materials; Feld Wgr.Nummer aus Service KEYFILE Datei=819','50');
      vNode->apiSetIntern('SWe.P.Warengruppe');

      // Ursprungsland
      vNode # vPos->apiAdd('Ursprungsland',_TypeAlpha,true);
      vNode->apiSetDesc('Abweichendes Urpsrungsland gegenüber Angabe aus Kopfdaten','DE');
      vNode->apiSetIntern('SWe.P.Ursprungsland');

      // Dicke
      vNode # vPos->apiAdd('Dicke',_TypeFloat ,false);
      vNode->apiSetDesc('Nenndicke des Materials in mm','1.50');
      vNode->apiSetIntern('SWe.P.Dicke');

      // Dickentoleranz
      vNode # vPos->apiAdd('Dickentoleranz',_TypeAlpha ,false);
      vNode->apiSetDesc('Dickentoleranz in +xx.xx/-yy.yy oder DIN','+0.2/-0.1');
      vNode->apiSetIntern('SWe.P.DickenTol');

      // Breite
      vNode # vPos->apiAdd('Breite',_TypeFloat ,false);
      vNode->apiSetDesc('Nennbreite des Materials in mm','1500.00');
      vNode->apiSetIntern('SWe.P.Breite');

      // Dickentoleranz
      vNode # vPos->apiAdd('Breitentoleranz',_TypeAlpha ,false);
      vNode->apiSetDesc('Breitentoleranz in +xx.xx/-yy.yy oder DIN','DIN');
      vNode->apiSetIntern('SWe.P.BreitenTol');

      // Länge
      vNode # vPos->apiAdd('Länge',_TypeFloat ,false);
      vNode->apiSetDesc('Nennlänge des Materials in mm','200000.00');
      vNode->apiSetIntern('SWe.P.Länge');

      // Längentoleranz
      vNode # vPos->apiAdd('Längentoleranz',_TypeAlpha ,false);
      vNode->apiSetDesc('Längentoleranz in +xx.xx/-yy.yy oder DIN','DIN');
      vNode->apiSetIntern('SWe.P.LängenTol');

      // RID
      vNode # vPos->apiAdd('RID',_TypeFloat ,false);
      vNode->apiSetDesc('Ringinnendurchmesser des Materials in mm','508.00');
      vNode->apiSetIntern('SWe.P.RID');

      // RAD
      vNode # vPos->apiAdd('RAD',_TypeFloat,false);
      vNode->apiSetDesc('Ringaußendurchmesser des Materials in mm','2840.1');
      vNode->apiSetIntern('SWe.P.RAD');

      // Bemerkung
      vNode # vPos->apiAdd('Bemerkung',_TypeAlpha ,false);
      vNode->apiSetDesc('Freie Bemerkungsangabe','wellige Kanten');
      vNode->apiSetIntern('SWe.P.Bemerkung');


      // ----------------------------------------------------
      //  Verpackungsangaben

      // Abbindung Längs
      vNode # vPos->apiAdd('AbbindungLängs',_TypeInt ,false);
      vNode->apiSetDesc('Anzahl der Längsabbindungen des Materials','3');
      vNode->apiSetIntern('SWe.P.AbbindungL');

      // Abbindung Quer
      vNode # vPos->apiAdd('AbbindungQuer',_TypeInt ,false);
      vNode->apiSetDesc('Anzahl der Querabbindungen des Materials','2');
      vNode->apiSetIntern('SWe.P.AbbindungQ');

      // Zwischenlage
      vNode # vPos->apiAdd('Zwischenlage',_TypeAlpha ,false);
      vNode->apiSetDesc('Trennmaterial innerhalb des Materials; frei'+
                        ' beschreibbar oder Feld ULa.Bezeichnunge aus Service'+
                        ' KEYFILE Datei=838','Kantholz');
      vNode->apiSetIntern('SWe.P.Zwischenlage');

      // Unterlage
      vNode # vPos->apiAdd('Unterlage',_TypeAlpha ,false);
      vNode->apiSetDesc('Untermaterial des Materials; frei beschreibbar oder Feld ULa.Bezeichnunge aus Service KEYFILE Datei=838','Europalette');
      vNode->apiSetIntern('SWe.P.Unterlage');

      // Umverpackung
      vNode # vPos->apiAdd('Umverpackung',_TypeAlpha ,false);
      vNode->apiSetDesc('Umverpackung des Materials; frei beschreibbar oder Feld ULa.Bezeichnunge aus Service KEYFILE Datei=838','Überseeverpackung');
      vNode->apiSetIntern('SWe.P.Umverpackung');

      // StehendYN
      vNode # vPos->apiAdd('Stehend',_TypeLogic,false);
      vNode->apiSetDesc('Material wird stehend geliefert','0');
      vNode->apiSetIntern('SWe.P.StehendYN');

      // LiegendYN
      vNode # vPos->apiAdd('Liegend',_TypeLogic,false);
      vNode->apiSetDesc('Material wird liegend geliefert','1');
      vNode->apiSetIntern('SWe.P.LiegendYN');

      // Nettoabzug
      vNode # vPos->apiAdd('Nettoabzug',_TypeFloat ,false);
      vNode->apiSetDesc('Verpackungsgewicht in kg','56.3');
      vNode->apiSetIntern('SWe.P.Nettoabzug');

      // Stapelhöhe
      vNode # vPos->apiAdd('Stapelhöhe',_TypeFloat ,false);
      vNode->apiSetDesc('Höhe des verpackten Materials in mm','1534.21');
      vNode->apiSetIntern('SWe.P.Stapelhöhe');

      // Stapelhöhenabzug
      vNode # vPos->apiAdd('Stapelhöhenabzug',_TypeFloat ,false);
      vNode->apiSetDesc('Nettohöhe der Verpackung in mm','212.00');
      vNode->apiSetIntern('SWe.P.Stapelhöhenabz');

      // Rechtwinkeligkeit
      vNode # vPos->apiAdd('Rechtwinkeligkeit',_TypeFloat ,false);
      vNode->apiSetDesc('Rechtwinkeligkeitsangabe','bsp');
      vNode->apiSetIntern('SWe.P.Rechtwinkligk');

      // Ebenheit
      vNode # vPos->apiAdd('Ebenheit',_TypeFloat ,false);
      vNode->apiSetDesc('Ebenheitssangabe','bsp');
      vNode->apiSetIntern('SWe.P.Ebenheit');

      // Säbeligkeit
      vNode # vPos->apiAdd('Säbeligkeit',_TypeFloat ,false);
      vNode->apiSetDesc('Säbeligkeitsangabe','bsp');
      vNode->apiSetIntern('SWe.P.Säbeligkeit');

      // Säbel pro Meter
      vNode # vPos->apiAdd('SäbeligkeitProM',_TypeFloat ,false);
      vNode->apiSetDesc('Säbeligkeitsangabe pro Meter','bsp');
      vNode->apiSetIntern('SWe.P.SäbelProM');


      // Wicklung
      vNode # vPos->apiAdd('Wicklung',_TypeAlpha ,false);
      vNode->apiSetDesc('Wicklungssangabe','bsp');
      vNode->apiSetIntern('SWe.P.Wicklung');

      // ----------------------------------------------------
      //  Analyseangaben  Mechanik

      // Streckgrenze
      vNode # vPos->apiAdd('StreckgrenzeVon',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Streckgrenze');
      vNode # vPos->apiAdd('StreckgrenzeBis',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Streckgrenze2');

      // Zugfestigkeit
      vNode # vPos->apiAdd('ZugfestigkeitVon',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Zugfestigkeit');
      vNode # vPos->apiAdd('ZugfestigkeitBis',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Zugfestigkeit2');

      // Dehnung
      vNode # vPos->apiAdd('DehnungA',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.DehnungA');
      vNode # vPos->apiAdd('DehnungB',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.DehnungB');

      // Rp02
      vNode # vPos->apiAdd('Rp02von',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.RP02_1');
      vNode # vPos->apiAdd('Rp02bis',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.RP02_2');

      // Rp10
      vNode # vPos->apiAdd('Rp10von',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.RP10_1');
      vNode # vPos->apiAdd('Rp10bis',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.RP10_2');

      // Körnung
      vNode # vPos->apiAdd('Körnung',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Körnung');

      // Härte
      vNode # vPos->apiAdd('HärteVon',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Härte1');
      vNode # vPos->apiAdd('HärteBis',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Härte2');

      // Rauhigkeit Oben
      vNode # vPos->apiAdd('RauhigkeitObenVon',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.RauigkeitA1');
      vNode # vPos->apiAdd('RauhigkeitObenBis',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.RauigkeitA2');

      // Rauhigkeit Unten
      vNode # vPos->apiAdd('RauhigkeitUntenVon',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.RauigkeitB1');
      vNode # vPos->apiAdd('RauhigkeitUntenBis',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.RauigkeitB2');

      // Mechanisch Sonstiges
      vNode # vPos->apiAdd('MechanikSontiges',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Mech.Sonstiges');


      // ----------------------------------------------------
      //  Analyseangaben  Chemie

      // C
      vNode # vPos->apiAdd('C',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.C');

      // Si
      vNode # vPos->apiAdd('Si',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.So');

      // Mn
      vNode # vPos->apiAdd('Mn',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie..Mn');

      // P
      vNode # vPos->apiAdd('P',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.P');

      // S
      vNode # vPos->apiAdd('S',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.S');

      // Al
      vNode # vPos->apiAdd('Al',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.Al');

      // Cr
      vNode # vPos->apiAdd('Cr',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.Cr');

      // V
      vNode # vPos->apiAdd('V',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.V');

      // Nb
      vNode # vPos->apiAdd('Nb',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.Nb');

      // Ti
      vNode # vPos->apiAdd('Ti',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.Ti');

      // N
      vNode # vPos->apiAdd('N',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.N');

      // Cu
      vNode # vPos->apiAdd('Cu',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.Cu');

      // Ni
      vNode # vPos->apiAdd('Ni',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.Ni');

      // Mo
      vNode # vPos->apiAdd('Mo',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.Mo');

      // B
      vNode # vPos->apiAdd('B',_TypeFloat ,false);
      vNode->apiSetIntern('SWe.P.Chemie.B');

/*
      //
      vNode # vPos->apiAdd('',_Type ,false);
      vNode->apiSetIntern('SWe.P.');
*/


  // ----------------------------------
  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub Kundenmaterial_Exec(aArgs : handle) : handle


//=========================================================================
// sub createSwe_Exec(aArgs : handle; var aResponse : handle) : int
//
//  Führt den Service aus:
//    Erstellt einen Sammelwareneingang anhand der übergebenen Daten
//
//  @Param
//    aRequestData    : handle    // Handle für die Requestdaten
//    var aAnswerNode : handle    // Referenz auf Antwortstruktur
//
//  @Return
//    int                         // Fehlercode
//
//  [+] 07.07.2022 MR Deadlockfix
//=========================================================================
sub createSwe_Exec(aArgs : handle; var aResponse : handle) : int
local begin
  vSender     : alpha;      // Sender des Requests
  vNode       : handle;     // Allgemeines Nodehandle
  vErg        : int;        // Ergebnishandle
  vErr        : int;        // Anzahl der der Fehler
  vFld        : alpha;      // Hilfvariable zum Prüfen von Übergabewerten
  vSWeNode    : handle;     // Handle für Sammelwareneingangs Daten
  
  vSWeNr      : int;        //  [+] 07.07.2022 MR Deadlockfix


  vRefID      : alpha;      // Rückgabe für Fehlerbezug
  vResponse   : handle;     // Handle für Rückgabedaten

  vRespHead   : handle;     // Handle für Rückgabe von Kopfdaten
  vRespPos    : handle;     // Handle für Rückgabe von Positionsdaten

  vSwePosCnt  : int;        // Anzahl der SWe Positionen

  vtmp  : alpha;

end
begin

  // --------------------------------------------------------------------------
  // Hauptargumente Extrahieren und für Prüfung vorbereiten
  vSender       # aArgs->getValue('SENDER');

  // Lieferantennummer des Senders prüfen
  if(Adr.Lieferantennr = 0) then
    return errSVM_notAllowed;

  // SWE Knoten lesen
  vSWeNode # aArgs->getNode(toUpper('SWE'));
  if (vSWeNode = 0) then begin
    aResponse->addErrNode(errSVC_argGeneral,
                  'Der Knotenpunkt "SWE" konnte nicht gefunden werden');
    return errPrevent;
  end;



  // Neue Kopfdaten für Sammelwareneingang erstellen
  RecBufClear(620);

  // --------------------------------------------------------------------------
  // Daten aus Argumenten lesen

  vNode # vSWeNode; // vNode wird für 'get' benötigt


  SWe.Termin          # CnvDA(get('Termin'));
  SWe.Vorgangsnr      #       get('Vorgangsnr');
  SWe.Bemerkung1      #       get('Bemerkung1');
  SWe.Bemerkung2      #       get('Bemerkung2');
  SWe.Ursprungsland   #       get('Ursprungsland');
  SWe.Versandart      # CnvIA(get('Versandart'));

  // Check Versandart
  if (SWe.Versandart <> 0) then begin
    VsA.Nummer # SWe.Versandart;
    vErg # RecRead(817,1,0);
    if (vErg > _rLocked) then
      errAbort(errSVC_argChoice,'falsche Versandart angegeben');
  end;

  // Voreingestellte und gelesene Daten
  SWe.Lieferant       # Adr.Lieferantennr;
  SWe.LieferantenSW   # Adr.Stichwort;
  SWe.Spediteur       # 0;                // bei Benutzung vordefinieren
  SWe.Erzeuger        # 0;                // bei Benutzung vordefinieren
  SWe.EigenmaterialYN # false;            // bei Benutzung vordefinieren

  // -------------------
  // Bis hier alles ok?
  if (vErr > 0) then
    return errPrevent;


  // ---------------------------------
  //  Kopf anlegen
  // ---------------------------------
  SOA_TRANSON;
  //  [+] 07.07.2022 MR Deadlockfix
  vErg # Lib_SOA:ReadNummer('SammelWE',var vSWeNr);
  if (vErg <> 0) then
        errAbort(errSVC_argGeneral,'Speicherung des Sammelwareneinganges nicht möglich (-2)');

  SWe.Nummer # vSWeNr;
  if (SWe.Nummer<>0) then begin
    vErg # Lib_SOA:SaveNummer();
    if (vErg <> 0) then
        errAbort(errSVC_argGeneral,'Speicherung des Sammelwareneinganges nicht möglich (-1)');
  end else
    errAbort(errSVC_argGeneral,'Speicherung des Sammelwareneinganges nicht möglich (-2)');

  SWe.Anlage.Datum  # Today;
  SWe.Anlage.Zeit   # Now;
  SWe.Anlage.User   # UserName(UserID(_UserCurrent));
  vErg # RekInsert(620,_RecUnlock,'AUTO');
  if (vErg<>_rOk) then
    errAbort(errSVC_argGeneral,'Speicherung des Sammelwareneinganges nicht möglich (-3)');


  // Erfolgsmeldung an Response anhängen
  vResponse # aResponse->getNode('DATA');

  vRespHead # vResponse->addRecord(620);
  vRespHead->Lib_XML:AppendNode('SWE.Nummer',AInt(SWE.Nummer));


  // ---------------------------------
  //  Positionen lesen und anlegen
  // ---------------------------------

  // Nodes durchlaufen und nach Positiionen suchen
  FOR  vNode # vSWeNode->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # vSWeNode->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin

    if (toUpper(vNode->spName) = 'POS') then begin
      inc(vSwePosCnt);

      RecBufClear(621);
      // -----------------------------
      // Vorbelegte Werte

      // Protokoll
      SWe.P.Anlage.Datum    # today;
      SWe.P.Anlage.Zeit     # now;
      SWe.P.Anlage.User     # UserName(UserID(_UserCurrent));

      // Hauptdaten
      SWe.P.Nummer          # SWe.Nummer;
      SWe.P.Position        # vSwePosCnt;
      SWe.P.Eingangsnr      # 1;
      SWe.P.Lieferantennr   # SWe.Lieferant;
      SWe.P.AvisYN          # true;
      SWe.P.MEH             # 'kg';

      // Konstanten zur Belegung bei Implementierung des Services
      SWe.P.Lageradresse    # 0;    // bei Benutzung vordefinieren
      SWe.P.Lageranschrift  # 0;    // bei Benutzung vordefinieren
      SWe.P.Lagerplatz      # '-1';  // bei Benutzung vordefinieren
      SWe.P.Erzeuger        # 0;    // bei Benutzung vordefinieren

      // ---------------------------------------
      // Daten aus Positionsnode lesen

      vRefID # get('RefID');

      // Pflichtfelder

      // Warengruppe
      "SWe.P.Warengruppe" # CnvIA(get('Warengruppe'));
      if ("SWe.P.Warengruppe" <= 0) then
        errAbort(errSVC_argNoValue,'Warengruppe muss angegeben werden. ('+ vRefId + ')');
      // Warengruppe existent?
      Wgr.Nummer # "SWe.P.Warengruppe";
      vErg # RecRead(819,1,0);
      if (vErg > _rLocked) then
        errAbort(errSVC_argChoice,'falsche Warengruppe angegeben. ('+ vRefId + ')');

      // Stückzahl
      "SWe.P.Stückzahl" # CnvIA(get('Stückzahl'));
      if ("SWe.P.Stückzahl" <= 0) then
        errAbort(errSVC_argNoValue,'Stückzahl muss angegeben werden. ('+ vRefId + ')');

      // Gewicht
      "SWe.P.Gewicht" # CnvFA(get('Gewicht'),_FmtNumPoint);
      if ("SWe.P.Gewicht" <= 0.0) then
        errAbort(errSVC_argNoValue,'Gewicht muss angegeben werden. ('+ vRefId + ')');
      SWe.P.Menge # "SWe.P.Gewicht";

      // Ursprungsland
      SWe.P.Ursprungsland # get('Ursprungsland');
      if ("SWe.P.Ursprungsland" = '') then
        errAbort(errSVC_argNoValue,'Ursprungsland muss angegeben werden. ('+ vRefId + ')');


      // ----------------------------------------
      //  Restliche Daten


      // Werte mit möglichen fehlerhaften Schlüsselangaben
      SWe.P.Verwiegungsart  # CnvIA(get('Verwiegungsart'));
      if (SWe.P.Verwiegungsart <> 0) then begin
        VwA.Nummer # SWe.P.Verwiegungsart;
        if (RecRead(818,1,0) > _rLocked) then
          errAbort(errSVC_argChoice,'falsche Verwiegungsart angegeben. ('+ vRefId + ')');
      end;

      // Hauptdaten
      SWe.P.Referenznr      #       get('Referenznummer');
      SWe.P.Avis_Datum      # CnvDA(get('Avisiertzum'));
      SWe.P.Lieferscheinnr  #       get('Lieferscheinnr');
      SWe.P.Gewicht.Netto   # CnvFA(get('Nettogewicht'));
      SWe.P.Gewicht.Brutto  # CnvFA(get('Bruttogewicht'));
      SWe.P.Intrastatnr     #       get('Intrastatnr');
      SWe.P.Coilnummer      #       get('Coilnummer');
      SWe.P.Ringnummer      #       get('Ringnummer');
      SWe.P.Werksnummer     #       get('Werksnummer');
      SWe.P.Chargennummer   #       get('Chargennummer');
      "SWe.P.Gütenstufe"    #       get('Gütenstufe');
      "SWe.P.Güte"          #       get('Güte');
      SWe.P.AusfOben        #       get('AusführungOben');
      SWe.P.AusfUnten       #       get('AusführungUnten');
      SWe.P.Dicke           # CnvFA(get('Dicke'));
      SWe.P.DickenTol       #       get('Dickentoleranz');
      SWe.P.Breite          # CnvFA(get('Breite'));
      SWe.P.BreitenTol      #       get('Breitentoleranz');
      "SWe.P.Länge"         # CnvFA(get('Länge'));
      "SWe.P.LängenTol"     #       get('Längentoleranz');
      SWe.P.RID             # CnvFA(get('RID'));
      SWe.P.RAD             # CnvFA(get('RAD'));
      SWe.P.Bemerkung       #       get('Bemerkung');

      // Verpackungsdaten
      SWe.P.AbbindungL      # CnvIa(get('AbbindungLängs'));
      SWe.P.AbbindungQ      # CnvIa(get('AbbindungQuer'));
      SWe.P.Zwischenlage    #       get('Zwischenlage');
      SWe.P.Unterlage       #       get('Unterlage');
      SWe.P.Umverpackung    #       get('Umverpackung');
      SWe.P.StehendYN       # CnvLI(CnvIa(get('Stehend')));
      SWe.P.LiegendYN       # CnvLI(CnvIa(get('Liegend')));
      SWe.P.Nettoabzug      # CnvFA(get('Nettoabzug'));
      "SWe.P.Stapelhöhe"    # CnvFA(get('Stapelhöhe'));
      "SWe.P.Stapelhöhenabz"# CnvFA(get('Stapelhöhenabzug'));
      SWe.P.Rechtwinkligk   # CnvFA(get('Rechtwinkeligkeit'));
      SWe.P.Ebenheit        # CnvFA(get('Ebenheit'));
      "SWe.P.Säbeligkeit"   # CnvFA(get('Säbeligkeit'));
      "SWe.P.SäbelProM"     # CnvFA(get('SäbeligkeitProM'));
      SWe.P.Wicklung        #       get('Wicklung');

      // Analysedaten - Mechanisch
      SWe.P.Streckgrenze    # CnvFA(get('StreckgrenzeVon'));
      SWe.P.Streckgrenze2   # CnvFA(get('StreckgrenzeBis'));
      SWe.P.Zugfestigkeit   # CnvFA(get('ZugfestigkeitVon'));
      SWe.P.Zugfestigkeit2  # CnvFA(get('ZugfestigkeitBis'));
      SWe.P.DehnungA        # CnvFA(get('DehnungA'));
      SWe.P.DehnungB        # CnvFA(get('DehnungB'));
      SWe.P.RP02_1          # CnvFA(get('Rp02Von'));
      SWe.P.RP02_2          # CnvFA(get('Rp02Bis'));
      SWe.P.RP10_1          # CnvFA(get('Rp10Von'));
      SWe.P.RP10_2          # CnvFA(get('Rp10Bis'));
      "SWe.P.Körnung"       # CnvFA(get('Körnung'));
      "SWe.P.Härte1"        # CnvFA(get('HärteVon'));
      "SWe.P.Härte2"        # CnvFA(get('HärteBis'));
      SWe.P.RauigkeitA1     # CnvFA(get('RauhigkeitObenVon'));
      SWe.P.RauigkeitA2     # CnvFA(get('RauhigkeitObenBis'));
      SWe.P.RauigkeitB1     # CnvFA(get('RauhigkeitUntenVon'));
      SWe.P.RauigkeitB2     # CnvFA(get('RauhigkeitUntenBis'));
      SWe.P.Mech.Sonstiges  #       get('MechanikSonstiges');

      // Analysedaten - Chemisch
      SWe.P.Chemie.C        # CnvFA(get('C'));
      SWe.P.Chemie.Si       # CnvFA(get('Si'));
      SWe.P.Chemie.Mn       # CnvFA(get('Mn'));
      SWe.P.Chemie.P        # CnvFA(get('P'));
      SWe.P.Chemie.S        # CnvFA(get('S'));
      SWe.P.Chemie.Al       # CnvFA(get('Al'));
      SWe.P.Chemie.Cr       # CnvFA(get('Cr'));
      SWe.P.Chemie.V        # CnvFA(get('V'));
      SWe.P.Chemie.Nb       # CnvFA(get('Nb'));
      SWe.P.Chemie.Ti       # CnvFA(get('Ti'));
      SWe.P.Chemie.N        # CnvFA(get('N'));
      SWe.P.Chemie.Cu       # CnvFA(get('Cu'));
      SWe.P.Chemie.Ni       # CnvFA(get('Ni'));
      SWe.P.Chemie.Mo       # CnvFA(get('Mo'));
      SWe.P.Chemie.B        # CnvFA(get('B'));


      // ---------------------------------------------
      // Speichern
      vErg # RekInsert(621,_RecUnlock,'AUTO');
      if (vErg<>_rOk) then begin
        SOA_TRANSBRK;
        aResponse->addErrNode(errSVC_argGeneral,'Speicherung der Position nicht möglich. (Ihre Refid: ' +vRefID+ ')');
        return errPrevent;
      end;

      vRespPos # vRespHead->addRecord(621);
      vRespPos->Lib_XML:AppendNode('RefId',vRefId);
      vRespPos->Lib_XML:AppendNode('SWE.P.Position',  AInt(SWe.P.Position));
    end;

  END;


  // Alles IO, dann Transaktion abschließen und in DB zurückschreiben1
  SOA_TRANSOFF;

  // --------------------------------------------------------------------------
  // Abschlussarbeiten

  // Daten des Services sind angehängt
  return _rOk;

End; // sub createSwe_Exec(...) : int




//=========================================================================
//=========================================================================
//=========================================================================
