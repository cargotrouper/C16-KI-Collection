@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000047
//                  OHNE E_R_G
//  Zu Service: IPAD_GETFILE
//
//  Info
///  Liest eine vorhandene Ipad Kundenmappe und gibt diese als RESPONSE zurück
//
//  04.07.2011  ST  Erstellung der Prozedur
//  22.02.2012  PW  Aktualisierung
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
  vSender   : alpha;
  vFilename : alpha;
  vErg      : int;

  vDataNode : handle;
  vXmlFile  : handle;
  vXmlNode  : handle;
end
begin
  Lib_Soa:Allocate();

  // Sender
  vFilename # Str_ReplaceAll(aArgs->getValue('SENDER'), '/', '_');
  vFilename # Set.Soa.Path + 'ipad\' + vFilename + '.xml';

  vXmlFile # CteOpen( _cteNode );
  vErg # vXmlFile->XmlLoad( vFilename );

  if ( vErg != _errOk ) then begin
    if ( vErg = _errXmlWarning or vErg = _errXmlRecoverable or vErg = _errXmlFatal ) then
      aResponse->addErrNode(errSVL_Allgemein, 'XML Fehler: ' + XmlError( _xmlErrorText ) );
    else if ( vErg = _errFsiNoFile or vErg = _errFsiNoPath ) then
      aResponse->addErrNode(errSVL_Allgemein, 'Daten wurde nicht gefunden');
    else // _errFsi...
      aResponse->addErrNode(errSVL_Allgemein, 'Fehler beim Öffnen der Daten (' + CnvAI( vErg ) + ')' );

    RETURN errPrevent;
  end;

  // Ausgabe erstellen
  vXmlNode # vXmlFile->CteRead(_cteChildList | _cteFirst);
  vXmlFile->CteDelete(vXmlNode);

  vDataNode # aResponse->getNode('DATA');
  vDataNode->CteInsert(vXmlNode, _cteChild);

  RETURN _rOk;
end;

//=========================================================================
//=========================================================================
//=========================================================================