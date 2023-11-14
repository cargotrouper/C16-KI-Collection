@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_BAG_P_0001
//                  OHNE E_R_G
//  Zu Service: BAG_P_NEW
//
//  Info
//  Erstellt eine neue Betriebsauftragsposition
//
//  http://192.168.0.2:5060/?sender=A1386&service=bag_p_new&bag.p.nummer=1336&Bag.P.Aktion=spalt
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
  vNode # vApi->apiAdd('BAG.P.Nummer',_TypeInt,true);
  vNode->apiSetDesc('Nummer des Zielbetriebsauftrages','1336');

  vNode # vApi->apiAdd('BAG.P.Aktion',_TypeAlpha,true);
  vNode->apiSetDesc('Typ des Arbeitsgangs','SPALT');

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

  vBagPAktion  # StrCut(aArgs->getValue('BAG.P.Aktion'),1,6);

  Erx # BA1_P_Data_SOA:Insert(
      CnvIa(aArgs->getValue('BAG.P.Nummer')),vBagPAktion);
  if (Erx <> _rOK) then begin
    Lib_Soa:BuildErrorResponse(var aResponse);
    RETURN errPrevent;
  end;

  // --------------------------------------------------------------------------
  // Response schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vNode->Lib_XML:AppendNode('Ergebnis', 'OK');
  vNode->Lib_XML:AppendNode('Bag.P.Position',Aint(Bag.P.Position));

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
  vArgs->Lib_XML:AppendNode(toUpper('service'),'BAG_P_NEW');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.P.Nummer'),'1336');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.P.Aktion'),'SPALT');
end;

//=========================================================================
// sub test() : handle
//
//  Hilfsmethode zum Testen des Services.
//
//=========================================================================
sub Test_Err1(var vArgs : handle)
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'BAG_P_NEW');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.P.Nummer'),'13361111');    // Ba gibts nicht
  vArgs->Lib_XML:AppendNode(toUpper('Bag.P.Aktion'),'SPALT');
end;



//=========================================================================
//=========================================================================
//=========================================================================