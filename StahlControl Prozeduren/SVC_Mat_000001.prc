@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_Mat_000001
//                  OHNE E_R_G
//  Info
//    Stellt die ServiceAPIs und Implementierungen für den Service
//    "Kundenfertigmaterial" bereit
//
//
//  07.09.2010  ST  Erstellung der Prozedur
//  28.09.2010  ST  Service: KNDFMAT Kundenfertigmaterial hinzugefügt
//  01.10.2010  ST  Umstrukturierung
//
//  Subprozeduren
//    sub kndfm_Api() : handle
//    sub kndfm_Exec(aArgs : handle; var aResponse : handle) : int
//    sub kndfm_Sel() : logic
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API


// Selektionsstruktur für Service KNDFM
global kndfm_Sel_Args begin
  kndfm_argKunde      : int;
  kndfm_argDickeVon   : float;
  kndfm_argDickeBis   : float;
  kndfm_argBreiteVon  : float;
  kndfm_argBreiteBis  : float;
  kndfm_argLaengeVon  : float;
  kndfm_argLaengeBis  : float;
  kndfm_argWgr        : int;
  kndfm_argGuete      : alpha;
  kndfm_argGuetenStf  : alpha;
 end;


//=========================================================================
// sub kndfm_Api() : handle
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
sub kndfm_Api() : handle
local begin
  vAPI   : handle;
  vNode : handle;
end
begin

  // ----------------------------------
  // Standardapi erstellen
  vApi # apiCreateStd();

  // Kundennummer wieder rein und trotzdem checken ob Vertreter, dann IO
  vNode # vApi->apiAdd('Kundennr',_TypeInt,true);
  vNode->apiSetDesc('Kundennummer der Fertigematerialien','12312');

  // Anzahl
  vNode # vApi->apiAdd('RecMax',_TypeAlpha,false,null,null
                       ,'5 | 10 | 25 | 50 | 75 | 100 | alle','25');
  vNode->apiSetDesc('Anzahl der Datensätze, die maximal zurückgegeben '+
                    'werden sollen. Das nächste Paket kann durch die '+
                    'Übergabe von RecID angefordert werden','50');

  // RecId
  vNode # vApi->apiAdd('RecID',_TypeInt,false,null,null,null,'0');
  vNode->apiSetDesc('Referenznummer des letzten Datensatzes aus '+
                    'vorherigem Paket','-2062614528');

  // Dicke Von/Bis
  vNode # vApi->apiAdd('DickeVon',_TypeFloat,false,null,null,null,'0.0');
  vNode->apiSetDesc('Mindestdicke in mm','1.50');
  vNode->apiSetIntern('Mat.Dicke');
  vNode # vApi->apiAdd('DickeBis',_TypeFloat,false,null,null,null,'99.9');
  vNode->apiSetDesc('Maximaldicke in mm','2.50');
  vNode->apiSetIntern('Mat.Dicke');

  // Bereite Von/Bis
  vNode # vApi->apiAdd('BreiteVon',_TypeFloat,false,null,null,null,'0.0');
  vNode->apiSetDesc('Mindesbreite in mm','1160.00');
  vNode->apiSetIntern('Mat.Breite');
  vNode # vApi->apiAdd('BreiteBis',_TypeFloat,false,null,null,null,'9999.9');
  vNode->apiSetDesc('Maximalbreite in mm','1500.00');
  vNode->apiSetIntern('Mat.Breite');

  // Länge Von/Bis
  vNode # vApi->apiAdd('LängeVon',_TypeFloat,false,null,null,null,'0.0');
  vNode->apiSetDesc('Mindestlänge in mm','15000.00');
  vNode->apiSetIntern('Mat.Länge');
  vNode # vApi->apiAdd('LängeBis',_TypeFloat,false,null,null,null,'99999999.9');
  vNode->apiSetDesc('Maximallänge in mm','20000.00');
  vNode->apiSetIntern('Mat.Länge');

  // Warengruppe
  vNode # vApi->apiAdd('Warengruppe',_TypeInt,false);
  vNode->apiSetDesc('Optional gewünschte Warengruppe laut Feld Wgr.Nummer aus Service: KEYFILE(Datei:819)','1000');
  vNode->apiSetIntern('Mat.Warengruppe');

  // Gütenstufe
  vNode # vApi->apiAdd('Gütenstufe',_TypeAlpha,false);
  vNode->apiSetDesc('Optional gewünschte Gütenstufe laut Feld MQu.S.Stufe aus Service: KEYFILE(Datei:848)','1A');
  vNode->apiSetIntern('Mat.Gütenstufe');

  // Güte
  vNode # vApi->apiAdd('Guete',_TypeAlpha,false);
  vNode->apiSetDesc('Optional gewünschte Güte laut Feld MQu.ErsetzenDurch aus Service: KEYFILE(Datei:832)','DD 12');
  vNode->apiSetIntern('Mat.Guete');

  // ----------------------------------
  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub kndfm_Api() : handle


//=========================================================================
// sub kndfm_Exec(...) : int
//
//  Führt den Service aus:
//    Erstellt eine Liste aller relevanten Daten für eine
//    Kundenfertigmaterialliste
//
//  @Param
//    aRequestData    : handle    // Handle für die Requestdaten
//    var aAnswerNode : handle    // Referenz auf Antwortstruktur
//
//  @Return
//    int                         // Fehlercode
//
//=========================================================================
sub kndfm_Exec(aArgs : handle; var aResponse : handle) : int
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

  vMatNode    : handle;     // Handle für Materialnode
  vAusfNode   : handle;     // Handle für Ausführung eines Materials
  vAusfNode2  : handle;     // Handle für Ausführung eines Materials
  vFlag       : handle;
end
begin

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vRecId        # CnvIA(aArgs->getValue('RECID'));
  vRecMax       # CnvIA(aArgs->getValue('RECMAX'));
  vSender       # aArgs->getValue('SENDER');

  // globales Speicherobjekt erstellen...
  vArgs # VarAllocate(kndfm_Sel_Args);
  // ... und mit den empfangenen Argumenten füllen
  kndfm_argKunde      # CnvIA(aArgs->getValue('KUNDENNR'));
  kndfm_argDickeVon   # CnvFA(aArgs->getValue('DICKEVON') ,_FmtNumPoint);
  kndfm_argDickeBis   # CnvFA(aArgs->getValue('DICKEBIS') ,_FmtNumPoint);
  kndfm_argBreiteVon  # CnvFA(aArgs->getValue('BREITEVON'),_FmtNumPoint);
  kndfm_argBreiteBis  # CnvFA(aArgs->getValue('BREITEBIS'),_FmtNumPoint);
  kndfm_argLaengeVon  # CnvFA(aArgs->getValue('LÄNGEVON') ,_FmtNumPoint);
  kndfm_argLaengeBis  # CnvFA(aArgs->getValue('LÄNGEBIS') ,_FmtNumPoint);
  kndfm_argWgr        # CnvIA(aArgs->getValue('WARENGRUPPE'));
  kndfm_argGuete      # toUpper(aArgs->getValue('GUETE'));
  kndfm_argGuetenStf  # toUpper(aArgs->getValue('GÜTENSTUFE'));


  // --------------------------------------------------------------------------
  // Argumente Prüfen

  // Vertreter dürfen Fertigmaterial aller Kunden ansehen
  if (StrCut(vSender,1,1) <> 'V') then begin
    // Adresse ist aus der Anmeldung geladen, dann Nutzung als Ansprechpartner
    if (Adr.Kundennr <> kndfm_argKunde) then
      return errSVM_notAllowed;
  end;

  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(200, 1, 'SVC_Mat_000001:kndfm_Sel',vArgs);
  vAnz  # Lib_SOA:RunPartSel(vSel, vRecMax,vRecId);

  // --------------------------------------------------------------------------
  // Daten schreiben

  // Daten Node zum einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vErg # RecRead(200, SOA_PartSel_Sel, _RecFirst);
  WHILE (vErg<=_rLocked) do begin

    // Daten gelesen, dann Node schreiben
    vMatNode # vNode->addRecord(200);
    vMatNode->Lib_SOA:AppendNode('Materialnummer',  AInt("Mat.Nummer"));
    vMatNode->Lib_SOA:AppendNode('Warengruppe',     AInt("Mat.Warengruppe"));
    vMatNode->Lib_SOA:AppendNode('Gütenstufe',      "Mat.Gütenstufe");
    vMatNode->Lib_SOA:AppendNode('Güte',            "Mat.Güte");
    vMatNode->Lib_SOA:AppendNode('AusführungOben',  "Mat.AusführungOben");
    vMatNode->Lib_SOA:AppendNode('AusführungUnten', "Mat.AusführungUnten");
    vMatNode->Lib_SOA:AppendNode('Dicke',           CnvAF("Mat.Dicke",_FmtNumPoint));
    vMatNode->Lib_SOA:AppendNode('Breite',          CnvAF("Mat.Breite",_FmtNumPoint));
    vMatNode->Lib_SOA:AppendNode('Länge',           CnvAF("Mat.Länge",_FmtNumPoint));
    vMatNode->Lib_SOA:AppendNode('Coilnummer',      "Mat.Coilnummer");
    vMatNode->Lib_SOA:AppendNode('Chargennummer',   "Mat.Chargennummer");
    vMatNode->Lib_SOA:AppendNode('Werksnummer',     "Mat.Werksnummer");
    vMatNode->Lib_SOA:AppendNode('Ringnummer',      "Mat.Ringnummer");
    vMatNode->Lib_SOA:AppendNode('Kommission',      "Mat.Kommission");
    vMatNode->Lib_SOA:AppendNode('Stückzahl',       AInt("Mat.Bestand.Stk"));
    vMatNode->Lib_SOA:AppendNode('Gewicht',         CnvAF("Mat.Bestand.Gew",_FmtNumPoint));

    // Ausführungen bei Liste genau aufführen
    vAusfNode # vMatNode->Lib_SOA:AppendNode('Ausführungen');
    vFlag # _RecFirst;
    WHILE (RecLink(201,200,11,vFlag) <= _rLocked) DO BEGIN
      vFlag # _RecNext;
      vAusfNode2 # vAusfNode->Lib_SOA:AppendNode('Ausführung');
      vAusfNode2->Lib_SOA:AppendNode('Bezeichnung', "Mat.AF.Bezeichnung");
      vAusfNode2->Lib_SOA:AppendNode('Zusatz', "Mat.AF.Zusatz");
      vAusfNode2->Lib_SOA:AppendNode('Bemerkung', "Mat.AF.Bemerkung");
      vAusfNode2->Lib_SOA:AppendNode('Kürzel', "Mat.AF.Kürzel");
    END;

    // Nächsten Datensatz lesen
    vErg # RecRead(200, SOA_PartSel_Sel, _RecNext);
  END;

  // --------------------------------------------------------------------------
  // Abschlussarbeiten

  // Speicher wieder freigeben
  VarFree(kndfm_Sel_Args);
  Lib_SOA:ClosePartSel(vSel);

  // Daten des Services sind angehängt
  return _rOk;

End; // sub kndfm_Exec(...) : int



//=========================================================================
// sub kndfm_Sel() : logic
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
sub kndfm_Sel() : logic
begin
  // Struktur für Selektion holen
  VarInstance(kndfm_Sel_Args, SOA_PartSel_Args);

  // Grundsätzliche Ausschlusskriterien
  if (Mat.KommKundennr <> kndfm_argKunde) then return false;
  if ("Mat.Löschmarker" <> '') then return false;

  // Selektionsbedingte Ausschlusskriterien
  if (Mat.Dicke < kndfm_argDickeVon) then return false;
  if (Mat.Dicke > kndfm_argDickeBis) then return false;
  if (Mat.Breite < kndfm_argBreiteVon) then return false;
  if (Mat.Breite > kndfm_argBreiteBis) then return false;
  if ("Mat.Länge" < kndfm_argLaengeVon) then return false;
  if ("Mat.Länge" > kndfm_argLaengeBis) then return false;

   // Selektionsbedingte optionale Ausschlusskriterien
  if (kndfm_argWgr <> 0)    AND (Mat.Warengruppe <> kndfm_argWgr) then return false;
  if (kndfm_argGuete <> '') AND (toUpper("Mat.Güte") <> kndfm_argGuete) then return false;
  if (kndfm_argGuetenStf <> '') AND (toUpper("Mat.Gütenstufe") <> kndfm_argGuetenStf) then return false;

  return true;
end; // sub kndfm_Sel() : logic


//=========================================================================
//=========================================================================
//=========================================================================