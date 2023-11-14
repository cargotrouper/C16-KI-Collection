@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000045
//                  OHNE E_R_G
//  Zu Service: MAT_RES_NEW
//
//  Info
///  MAT_RES_NEW: Legt einen neue Materialreseriverung an
//
//  23.03.2011  ST  Erstellung der Prozedur
//  2022-06-29  AH  ERX
//  07.07.2022  MR  Deadlockfix für Lib_Soa:ReadNummer in sub exec()
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

  // ----------------------------------
  // Standardapi erstellen
  vApi # apiCreateStd();

  // ----------------------------------
  // Speziele Api-Definition ab hier

  // Materialnummer
  vNode # vApi->apiAdd('Materialnr',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Materialnummer zu der die Reservierung angelegt werden soll','124102');

  // Stückzahl
  vNode # vApi->apiAdd('Stueckzahl',_TypeInt,true);
  vNode->apiSetDesc('Zu reservierende Stückzahl','5');

  // Gewicht
  vNode # vApi->apiAdd('Gewicht',_TypeFloat,true);
  vNode->apiSetDesc('Zu reservierendes Gewicht','5000.00');

  // Auftragsnr
  vNode # vApi->apiAdd('Auftragsnr',_TypeInt,false);
  vNode->apiSetDesc('Kundenauftrag zur Reserverierung','123104');

  // Auftragpos
  vNode # vApi->apiAdd('Auftragspos',_TypeInt,false);
  vNode->apiSetDesc('Kundenauftragsposition zur Reserverierung','3');

  // Kundennummer
  vNode # vApi->apiAdd('Kundennummer',_TypeInt,false);
  vNode->apiSetDesc('Kundennummer, wenn nicht auf einen Auftrag reserviert werden soll','31232');

  // Bemerkung
  vNode # vApi->apiAdd('Bemerkung',_TypeInt,false);
  vNode->apiSetDesc('Bemerkungstext zur Reserverierung','Für Herrn Meier laut Telefonat');


    // ----------------------------------
  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub api() : handle


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
  // Argumente zur Erstellung der Selektion
  vArgs       : handle;     // Handle für Argumentprüfungsstruktur
  vNode       : handle;     // Handle auf Datensegment der Antwort

  // Ablaufvariablen
  vErg        : int;        // Ergebnishandle
  vTmp        : alpha;
  vErr        : int;

  // Argument, fachliche Seite
  vMatNr      : int;
  vStk        : int;
  vGew        : float;
  vAufNr      : int;
  vAufPos     : int;
  vKnd        : int;
  vBem        : alpha;
  vResID      : int;

  // Rückgabedaten
  vErgNode    : handle;     // Handle für Antwort

  // für Gruppe ALLE
  vDatei  : int;
  vTds    : int;
  vTdsCnt : int;
  vFld    : int;
  vFldCnt : int;
  vFldData  : alpha(4096);

  vFldName  : alpha;
  vChkName  : alpha;
  Erx       : int;
end
begin
  Lib_Soa:Allocate();  // Datenbereiche allokieren
  vErr # 0;

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vMatNr        # CnvIA(aArgs->getValue('Materialnr'));
  vStk          # CnvIA(aArgs->getValue('Stueckzahl'));
  vGew          # CnvFA(aArgs->getValue('Gewicht'));
  vAufNr        # CnvIA(aArgs->getValue('Auftragsnr'));
  vAufPos       # CnvIA(aArgs->getValue('Auftragspos'));
  vKnd          # CnvIA(aArgs->getValue('Kundennummer'));
  vBem          #       aArgs->getValue('Bemerkung');

  // Material vorhanden?
  RecBufClear(200);
  Mat.Nummer # vMatNr;
  if (RecRead(200,1,0) <> _rOK) then begin
    // Material nicht gefunden
    aResponse->addErrNode(errSVL_Allgemein,'Materialnummer ist nicht im Bestand');
    inc(vErr);
  end;

  // Auftrag angegeben ?
  if (vAufNr <> 0) then begin
    // Auftrag vorhanden?
    RecBufClear(401);
    Auf.P.Nummer # vAufNr;
    Auf.P.Position  # vAufPos;
    if (RecRead(401,1,0) <> _rOK) then begin
      // Auftrag nicht gefunden
      aResponse->addErrNode(errSVL_Allgemein,'Auftragsposition ist nicht im Bestand');
      inc(vErr);
    end;
  end;

  // Kunde vorhanden ?
  if (vKnd <> 0) then begin
    Adr.Kundennr # vKnd;
    vErg # RecRead(100,2,0);
    if (vErg > _rNoKey) then begin
      // Kunde nicht vorhanden
      aResponse->addErrNode(errSVL_Allgemein,'Kunde unbekannt');
      inc(vErr);
    end;
  end;

  // Auftrag oder Kunde nicht angegeben?
  if (vAufNr = 0) AND (vKnd = 0) then begin
    aResponse->addErrNode(errSVL_Allgemein,'Auftragsposition oder Kunde wurden nicht angegeben');
    inc(vErr);
  end;

  if (vErr > 0) then
    RETURN errPrevent;


  // --------------------------------------------------------------------------
  // Reservierungsdaten vorbelegen

  // Alles IO bis hierhin, dann Daten vorbelegen
  RecBufClear(203);
  Mat.R.Materialnr    # vMatNr;
  "Mat.R.Stückzahl"   # vStk;
  Mat.R.Gewicht       # vGew;
  Mat.R.Auftragsnr    # vAufNr;
  Mat.R.Auftragspos   # vAufPos;
  Mat.R.Kundennummer  # vKnd;
  Mat.R.Bemerkung     # vBem;

  if (Mat.R.Auftragspos <> 0) then begin
    Erx # RecLink(401, 203, 2, 0);
    if (Erx<=_rLocked) then begin
      Mat.R.Kundennummer # Auf.P.Kundennr;
      Mat.R.KundenSW # Auf.P.KundenSW;
    end;
  end else begin
    // Stichwort updaten
    Erx # RecLink(100,203,3,0);
    if (Erx<=_rLocked) then
      Mat.R.KundenSW # Adr.Stichwort;
  end;


  /* --------------------------------------------------------------------------
   Reservierung anlegen
  
    [+] 07.07.2022 MR Deadlockfix
   -------------------------------------------------------------------------- */
  Erx # Lib_SOA:ReadNummer('Material-Reservierung', var vResID);
  if(Erx<> _rOk) then begin
    aResponse->addErrNode(errSVL_Allgemein,'Die Reservierungsid konnte nicht gelesen werden');
    RETURN errPrevent;
  end
  if (vResID<>0) then begin
    vErg # Lib_SOA:SaveNummer();
    if (vErg <> 0) then begin
      aResponse->addErrNode(errSVL_Allgemein,'Die Reservierungsid konnte nicht gespeichert werden');
      RETURN errPrevent;
    end;
  end else begin
    aResponse->addErrNode(errSVL_Allgemein,'Die Reservierungsid konnte nicht bestimmt werden');
    RETURN errPrevent;
  end;

  if (Mat_RSV_DATA:Neuanlegen(vResID)) then begin
    // Alles IO gelaufen, dann Erfolg mit entsprechenden Daten melden
    vNode # aResponse->getNode('DATA');
    vNode->Lib_XML:AppendNode('Ergebnis',  'OK');
  end else begin
    // Fehlerhaft, dann Fehler zusammenstellen
    vNode # aResponse->getNode('ERROR');
    // .. hier genauer nach der Fehlerbeschreibung kucken
    vNode->Lib_XML:AppendNode('Ergebnis',  'Reservierung konnte nicht angelegt werden');
  end;


  // --------------------------------------------------------------------------
  // Abschlussarbeiten
  dbg('MemKB ende: ' + Aint(_Sys->spProcessMemoryKB));
  // Daten des Services sind angehängt
  return _rOk;

End; // sub exec(...) : int



//=========================================================================
//=========================================================================
//=========================================================================