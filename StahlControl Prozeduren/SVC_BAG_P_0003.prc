@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_BAG_P_0003
//                  OHNE E_R_G
//  Zu Service: BAG_P_DELETE
//
//  Info
//  Löscht eine Betriebsauftragsposition
//
//  http://192.168.0.2:5060/?sender=A1386&service=bag_p_delete
//  http://192.168.0.2:5060/?sender=A1386&service=bag_p_delete&bag.p.nummer=1336&bag.p.position=2
//
//  02.03.2015  ST  Erstellung der Prozedur
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
  vNode # vApi->apiAdd('BAG.P.Nummer',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Betriebsauftragsnummer','124102');

  vNode # vApi->apiAdd('BAG.P.Position',_TypeInt,true);
  vNode->apiSetDesc('Positionsnr des Arbeitsgangs','1');


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
  Erx         : int;
end
begin

  Bag.P.Nummer    # CnvIA(aArgs->getValue('BAG.P.Nummer'));
  Bag.P.Position  # CnvIA(aArgs->getValue('BAG.P.Position'));
  Erx # BA1_P_Data_SOA:Delete(Bag.P.Nummer, Bag.P.Position);
  if (Erx <> _rOk) then begin
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
// sub test() : handle
//
//  Hilfsmethode zum Testen des Services.
//
//=========================================================================
sub Test(var vArgs : handle)
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'BAG_P_DELETE');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.P.Nummer'),'1336');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.P.Position'),'2');
end;




//=========================================================================
//=========================================================================
//=========================================================================