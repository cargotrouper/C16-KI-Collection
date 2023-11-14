@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_BAG_0002
//                  OHNE E_R_G
//  Zu Service: BAG_REPLACE
//
//  Info
//  Ändert einen Betriebsauftrag
//
//  http://192.168.0.2:5060/?sender=A1386&service=bag_replace
//  http://192.168.0.2:5060/?sender=A1386&service=bag_replace&bag.Nummer=1336&bag.bemerkung=SOA%20BAG%20hallo%20zusammen
//
//  27.01.2015  ST  Erstellung der Prozedur
//  2022-06-29  AH  ERX
//
//  Subprozeduren
//    SUB api() : handle
//    SUB exec(aArgs : handle; var aResponse : handle) : int
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
end;


//=========================================================================
// sub api() : handle
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
sub api() : handle
local begin
  vAPI   : handle;
  vNode : handle;
end
begin
  // Standard-API-Beschreibung erstellen und zurückgeben
  vAPI # apiCreateStd();

  // ----------------------------------
  // Speziele Api-Definition ab hier

  // BAG Nummer
  vNode # vApi->apiAdd('BAG.Nummer',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Betriebsauftragsnummer','124102');

  // Bemerkung
  vNode # vApi->apiAdd('BAG.Bemerkung',_TypeAlpha,false);
  vNode->apiSetDesc('Bemerkung zum Betriebsauftrags','Lohnauftrag 1234');

  // Plankosten
  vNode # vApi->apiAdd('BAG.Plankosten',_TypeFloat,false);
  vNode->apiSetDesc('Plankosten für den kompletten Betriebsauftrag in SC Hauswährung','5000.00');

  // Planzeit
  vNode # vApi->apiAdd('BAG.Planzeit',_TypeFloat,false);
  vNode->apiSetDesc('Geplante Laufzeit aller Arbeitsgänge in Minuten','720.00');

  RETURN vAPI;
end;


//=========================================================================
// sub exec(aArgs : handle; var aResponse : handle) : int
//
//  Führt den Service aus:
//    Liest die übergebene Materialnummer und gibt alle Felder aus,
//    deren Feldnamen oder Nummern in Stahl Control vorhanden sind
//
//  @Param
//    aRequestData    : handle    // Handle für die Requestdaten
//    var aAnswerNode : handle    // Referenz auf Antwortstruktur
//
//  @Return
//    int                         // Fehlercode
//
//=========================================================================
sub exec(aArgs : handle; var aResponse : handle) : int
local begin
  vArgs       : handle;     // Handle für Argumentprüfungsstruktur
  vNode       : handle;     // Handle auf Datensegment der Antwort
  vBuff       : handle;
  vTmp        : alpha(4000);
  Erx         : int;
end
begin

  Bag.Nummer # CnvIA(aArgs->getValue('BAG.Nummer'));
  RecRead(700,1,0);

  vBuff # RekSave(700);

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten

  vTmp # aArgs->getValue('BAG.Bemerkung');
  if (vTmp <> '') then
    vBuff->Bag.Bemerkung  # vTmp;

  vTmp # aArgs->getValue('BAG.Plankosten');
  if (vTmp <> '') then
    vBuff->Bag.Plankosten # CnvFA(vTmp);

  vTmp # aArgs->getValue('BAG.Planzeit');
  if (vTmp <> '') then
    vBuff->BAG.Planzeit # CnvFA(vTmp);


  /*
    Folgende Daten werden durch die Businesslogik gefüllt und können
    nicht von außen geändert werden
  */
  //  BAG.Fertig.Datum
  //  BAG.Fertig.Zeit
  //  BAG.Fertig.User
  //  BAG.Anlage.Datum
  //  BAG.Anlage.Zeit
  //  BAG.Anlage.User
  //  BAG.Lösch.Datum
  //  BAG.Lösch.Zeit
  //  BAG.Lösch.User

  Erx # BA1_Data_SOA:Replace(vBuff);
  RecbufDestroy(vBuff);

  if (Erx <> _rOK) then begin
    Lib_Soa:BuildErrorResponse(var aResponse);
    RETURN errPrevent;
  end;

  // --------------------------------------------------------------------------
  // Response schreiben
  vNode # aResponse->getNode('DATA');           // Daten Node zum Einfügen extrahieren
  vNode->Lib_XML:AppendNode('Ergebnis', 'OK');

  RETURN _rOk;
end;

//=========================================================================
//=========================================================================
//=========================================================================