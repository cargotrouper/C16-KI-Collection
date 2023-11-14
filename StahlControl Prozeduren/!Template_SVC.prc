
@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_****
//                    OHNE E_R_G
//  Info
//    Stellt die ServiceAPIs und Implementierungen bereit
//
//
//  __.__.____  XX  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API


// Selektionsstruktur für Service, falls Daten selektiert werden
global matfrei_Sel_Args begin
  xxx_argDickeVon   : float;
  xxx_argDickeBis   : float;
end;


//=========================================================================
// sub test_Api() : handle
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
sub xxx_Api() : handle
local begin
  vAPI   : handle;
  vNode : handle;
end
begin

  // ----------------------------------
  // Standardapi erstellen
  vApi # apiCreateStd();

  // ----------------------------------
  // Speziele Api-Definition ab hier

  // Datei
  vNode # vApi->apiAdd('Datei',_TypeInt,true,810,900);
  vNode->apiSetDesc('Dateinummer der Schlüsseldatei; Verfügbare Schlüsseldateien '+
                    'sind über den Service KEYINFO abzufragen','844');

  // Materialnr
  vNode # vApi->apiAdd('Materialnr',_TypeInt,false);


  // ----------------------------------
  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub Kundenmaterial_Exec(aArgs : handle) : handle


//=========================================================================
// sub xxx_Exec(aArgs : handle; var aResponse : handle) : int
//
//  Führt den Service aus:
//    xxx Hier die Beschreibung xxx
//
//  @Param
//    aRequestData    : handle    // Handle für die Requestdaten
//    var aAnswerNode : handle    // Referenz auf Antwortstruktur
//
//  @Return
//    int                         // Fehlercode
//
//=========================================================================
sub xxx_Exec(aArgs : handle; var aResponse : handle) : int
local begin
  // Argumente zur Erstellung der Selektion
  vArgs       : handle;     // Handle für Argumentprüfungsstruktur
  vRecId      : int;        // Letzte Datensatz ID
  vRecMax     : int;        // Maximale Anzahl von Rückgabewerten
  vSender     : alpha;      // Sender des Requests
  vNode       : handle;     // Handle auf Datensegment der Antwort

  // Ablaufvariablen
  vErg        : int;        // Ergebnishandle
  vSel        : handle;     // Handle der Selektion
  vAnz        : int;        // Anzahl der gelesen Datensätze (unused)

  vxxxNode    : handle;     // Handle für Materialnode
end
begin

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vRecId        # CnvIA(aArgs->getValue('RECID'));
  vRecMax       # CnvIA(aArgs->getValue('RECMAX'));
  vSender       # aArgs->getValue('SENDER');

  // globales Speicherobjekt erstellen...
  vArgs # VarAllocate(xxx_Sel_Args);
  // ... und mit den empfangenen Argumenten füllen
  xxx_argDickeVon   # CnvFA(aArgs->getValue('DICKEVON') ,_FmtNumPoint);
  xxx_argGuete      # toUpper(aArgs->getValue('GUETE'));

  // --------------------------------------------------------------------------
  // Argumente Prüfen

  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(200, 1, 'SVC_xxx_00000*:xxx_Sel',vArgs);
  vAnz  # Lib_SOA:RunPartSel(vSel, vRecMax,vRecId);

  // --------------------------------------------------------------------------
  // Daten schreiben

  // Daten Node zum einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vErg # RecRead(xxx, SOA_PartSel_Sel, _RecFirst);
  WHILE (vErg<=_rLocked) do begin

    // Daten gelesen, dann Node schreiben
    vMatNode # vNode->addRecord(xxx);
    vMatNode->Lib_XML:AppendNode('xxx',  AInt(xxx));

    // Nächsten Datensatz lesen
    vErg # RecRead(xxx, SOA_PartSel_Sel, _RecNext);
  END;

  // --------------------------------------------------------------------------
  // Abschlussarbeiten

  // Speicher wieder freigeben
  VarFree(xxx_Sel_Args);
  Lib_SOA:ClosePartSel(vSel);

  // Daten des Services sind angehängt
  return _rOk;

End; // sub matfrei_Exec(...) : int


//=========================================================================
// sub xxx_Sel() : logic
//
//  Prüft einen Datensatz, ob dieser mit den gewünschten Werten überstimmt
//
//  @Param
//      -
//
//  @Return
//    logic                         // true -> passt, false -> passt nicht
//
//=========================================================================
sub xxx_Sel() : logic
begin
  // Struktur für Selektion holen
  VarInstance(xxx_Sel_Args, SOA_PartSel_Args);

  // Grundsätzliche Ausschlusskriterien
  if (xxx <> '') then return false;

    return true;
end; // sub xxx_Sel() : logic


//=========================================================================
//=========================================================================
//=========================================================================
