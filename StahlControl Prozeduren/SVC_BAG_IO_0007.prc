@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_BAG_IO_0007
//                  OHNE E_R_G
//  Zu Service: BAG_IO_NEW_IdPos
//
//  Info
//  Erstellt eine Weiterverarbeitung von einer Ausbringung zu einer Position
//
//  http://192.168.0.2:5060/?sender=A1386&service=BAG_IO_NEW_IdPos&bag.io.nummer=1336&bag.io.id=1&Bag.p.Position=3
//
//  09.03.2015  ST  Erstellung der Prozedur
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
@I:Def_BAG

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
  vNode # vApi->apiAdd('BAG.IO.Nummer',_TypeInt,true);
  vNode->apiSetDesc('Nummer des Zielbetriebsauftrages','1336');

  vNode # vApi->apiAdd('BAG.IO.Id',_TypeInt,true);
  vNode->apiSetDesc('Id der Ausbringung','1');

  vNode # vApi->apiAdd('BAG.P.Position',_TypeInt,true);
  vNode->apiSetDesc('Zielposition','3');

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
  vBagPAktion : alpha;
  Erx         : int;
end
begin

  Erx # BA1_IO_Data_SOA:InsertIDToPos(
      CnvIa(aArgs->getValue('BAG.IO.Nummer')),
      CnvIa(aArgs->getValue('BAG.ID.ID')),
      CnvIa(aArgs->getValue('BAG.P.Position'))      );


  if (Erx <> _rOK) then begin
    Lib_Soa:BuildErrorResponse(var aResponse);
    RETURN errPrevent;
  end;

  // --------------------------------------------------------------------------
  // Response schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vNode->Lib_XML:AppendNode('Ergebnis', 'OK');
  vNode->Lib_XML:AppendNode('Bag.IO.ID',Aint(Bag.IO.ID));

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
  vArgs->Lib_XML:AppendNode(toUpper('service'),'BAG_IO_NEW_FertPos');
  vArgs->Lib_XML:AppendNode(toUpper('bag.io.nummer'),'1336');
  vArgs->Lib_XML:AppendNode(toUpper('bag.io.ID'),'7');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.p.Position'),'3');

end;



//=========================================================================
//=========================================================================
//========================================================================