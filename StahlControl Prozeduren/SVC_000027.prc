@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000022
//                  OHNE E_R_G
//  Zu Service: LFS_REPLACE
//
//  Info
///   Updated Lieferscheinkopfdaten und gibt das Ergebnis zurück
//
//
//  17.02.2011  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB api() : handle
//    SUB exec(aArgs : handle; var aResponse : handle) : int
//
//========================================================================
@I:Def_Global
@I:Def_Global_Sys
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,b,false); end;
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

  // Auftragsnummer
  vNode # vApi->apiAdd('NUMMER',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Nummer des Lieferscheins','12345');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Hauptdaten
  addToApi('Lfs.Nummer',_TypeInt);
  addToApi('Lfs.Kundennummer',_TypeInt);
  addToApi('Lfs.Zieladresse',_TypeInt);
  addToApi('Lfs.Zielanschrift',_TypeInt);
  addToApi('Lfs.Datum.Verbucht',_TypeDate);
  addToApi('Lfs.Spediteurnr',_TypeInt);
  addToApi('Lfs.Spediteur',_TypeAlpha);
  addToApi('Lfs.Fahrer',_TypeAlpha);
  addToApi('Lfs.Kennzeichen',_TypeAlpha);
  addToApi('Lfs.Bemerkung',_TypeAlpha);
  addToApi('Lfs.Loeschmarker',_TypeAlpha);
  addToApi('Lfs.zuBA.Nummer',_TypeInt);
  addToApi('Lfs.zuBA.Position',_TypeInt);
  addToApi('Lfs.Kundenstichwort',_TypeAlpha);
  addToApi('Lfs.Lieferdatum',_TypeDate);
  addToApi('Lfs.Kosten.Pro',_TypeFloat);
  addToApi('Lfs.Kosten.PEH',_TypeInt);
  addToApi('Lfs.Kosten.MEH',_TypeAlpha);
  addToApi('Lfs.zuAuftragsnr',_TypeInt);
  addToApi('Lfs.Referenznr',_TypeAlpha);
  addToApi('Lfs.Positionsgewicht',_TypeFloat);
  addToApi('Lfs.Leergewicht',_TypeFloat);
  addToApi('Lfs.Gesamtgewicht',_TypeFloat);
  addToApi('LFs.Wiegung1.Datum',_TypeDate);
  addToApi('LFs.Wiegung1.Zeit',_TypeTime);
  addToApi('LFs.Wiegung2.Datum',_TypeDate);
  addToApi('LFs.Wiegung2.Zeit',_TypeTime);

  // Protokoll
  addToApi('Lfs.Anlage.Datum',_TypeDate);
  addToApi('Lfs.Anlage.Zeit',_TypeTime);
  addToApi('Lfs.Anlage.User',_TypeAlpha);

    // ----------------------------------
  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub api() : handle


//=========================================================================
// sub exec(aArgs : handle; var aResponse : handle) : int
//
//  Führt den Service aus:
//    Liest die übergebene Materialnummer und ersetzt die übergebenen Felder
//    mit den übergebenen Feldern
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

  // Argument, fachliche Seite
  vLfsNr      : int;

  vFelderGrp  : alpha;

  // Rückgabedaten
  vResNode    : handle;     // Handle für Materialnode

  // für Gruppe ALLE
  vDatei  : int;
  vTds    : int;
  vTdsCnt : int;
  vFld    : int;
  vFldCnt : int;
  vFldData   : alpha(4096);

  vFldName : alpha;
  vChkName : alpha;
  vVal     : alpha(4096);
  vErr     : int;

end
begin

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vLfsNr        # CnvIA(aArgs->getValue('NUMMER'));

  // --------------------------------------------------------------------------
  // Lieferschein lesen
  RecBufClear(440);
  Lfs.Nummer # vLfsNr;
  if (RecRead(440,1,0) <> _rOK) then begin
    aResponse->addErrNode(errSVL_Allgemein,'Lieferschein unbekannt');
    RETURN errPrevent;
  end;

  // Datensatz sperren
  if (RecRead(440,1,_RecLock) <> _rOK) then begin
      // Position nicht sperrbar
      aResponse->addErrNode(errSVL_Allgemein,'Lieferschein konnte nicht gesperrt werden');
      RETURN errPrevent;
  end;



  // --------------------------------------------------------------------------
  // Daten schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vResNode # vNode->addRecord(440);

  vErr # 0;

  // Argumente durchsuchen und nach gewünschten Feldnamen suchen
  FOR  vNode # aArgs->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aArgs->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin

    vFldName # toUpper(vNode->spName);
    if (StrCut(vFldName,1,4) = 'LFS.') then begin

      vVal # aArgs->getValue(vFldName);

      if (vVal <> '') then begin


        // Felder mit Umlauten mappen
        CASE (toUpper(vFldName)) OF
          'LFS.LOESCHMARKER'    : vFldName #  'Lfs.Löschmarker';     // TDS 1: Hauptdaten
        END;


        // Feld mit "normalem" Namen prüfen
        vErg # FldInfoByName(vFldName,_FldExists);

        // Feld vorhanden?
        if (vErg <> 0) then begin

          // Alle Feldnamen in Großbuchstabenexportieren
          vFldName # toUpper(vFldName);

          try begin

             // Wenn vorhanden dann je nach Feldtyp beschreiben
             CASE (FldInfoByName(vFldName,_FldType)) OF
                _TypeAlpha    : FldDefByName(vFldName, vVal);
                _TypeBigInt   : FldDefByName(vFldName, CnvBA(vVal));
                _TypeDate     : FldDefByName(vFldName, CnvDA(vVal));
                _TypeDecimal  : FldDefByName(vFldName, CnvMA(vVal));
                _TypeFloat    : FldDefByName(vFldName, CnvFA(vVal));
                _TypeInt      : FldDefByName(vFldName, CnvIA(vVal));
                _TypeLogic    : FldDefByName(vFldName, CnvLi(CnvIA(vVal)));
                _TypeTime     : FldDefByName(vFldName, CnvTA(vVal));
                _TypeWord     : FldDefByName(vFldName, CnvIA(vVal));
             END;
          end;
          if (ErrGet() <> _rOK) then begin
            // Falsches Feldformat
            aResponse->addErrNode(errSVL_Allgemein,vFldName + ' enthält einen nicht kompatiblen Wert.');
            inc(vErr);
          end;

        end else begin
          // FEHLER
          // Feld gibts nicht, dann nicht anhängen
          aResponse->addErrNode(errSVL_Allgemein,'Das Feld ' + vFldName + ' existiert nicht.');
          inc(vErr);
        end;

      end;

    end;

  END;

  // --------------------------------------------------------------------------
  // Abschlussarbeiten

  // Aufpos schreiben
  if (RekReplace(440,_RecUnlock,'SOA') <> _rOK) then begin
      // Aufpos nicht speicherbar
      aResponse->addErrNode(errSVL_Allgemein,'Lieferschein konnte nicht gespeichert werden');
      inc(vErr);
  end;

  if (vErr <> 0) then begin
    RETURN errPrevent;
  end;


  vResNode->Lib_XML:AppendNode('Ergebnis', 'OK');

  // Daten des Services sind angehängt
  return _rOk;

End; // sub exec(...) : int



//=========================================================================
//=========================================================================
//=========================================================================