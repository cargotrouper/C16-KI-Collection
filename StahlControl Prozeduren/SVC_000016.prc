@A
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000016
//                  OHNE E_R_G
//  Zu Service: AUF_POS_AKT_READ
//
//  Info
//  AUF_POS_AKT_READ: Lesen von Auftragsaktionslisten und Rückgabe der angegeben Felder
//
//  16.02.2011  ST  Erstellung der Prozedur
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

  c_DATEI       : 404
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
  vNode->apiSetDesc('Eindeutige Auftragsnummer der Auftragsposition','123045');

  // Auftragsposition
  vNode # vApi->apiAdd('POSITION',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Positionsnummer der Auftragsposition','1');

  // Auftragsaktion
  vNode # vApi->apiAdd('AKTION',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Aktionnummer der Auftragspositionsaktion','1');

  // Auftragsposition 2
  vNode # vApi->apiAdd('POSITION2',_TypeInt,false,0,0,'','0');
  vNode->apiSetDesc('optionale Stücklistenposition der Auftragspositionsaktion','1');

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Haupdaten
  addToApi('Auf.A.Nummer','');
  addToApi('Auf.A.Position','');
  addToApi('Auf.A.Position2','');
  addToApi('Auf.A.Aktion','');
  addToApi('Auf.A.Aktionstyp','');
  addToApi('Auf.A.Aktionsnr','');
  addToApi('Auf.A.Aktionspos','');
  addToApi('Auf.A.Aktionspos2','');
  addToApi('Auf.A.Aktionsdatum','');
  addToApi('Auf.A.TerminStart','');
  addToApi('Auf.A.TerminEnde','');
  addToApi('Auf.A.Adressnummer','');
  addToApi('Auf.A.MEH','');
  addToApi('Auf.A.Menge','');
  addToApi('Auf.A.Stueckzahl','');
  addToApi('Auf.A.Gewicht','');
  addToApi('Auf.A.Nettogewicht','');
  addToApi('Auf.A.MEH.Preis','');
  addToApi('Auf.A.Menge.Preis','');
  addToApi('Auf.A.Rechnungsnr','');
  addToApi('Auf.A.Rechnungsdatum','');
  addToApi('Auf.A.Rechnungspreis','');
  addToApi('Auf.A.RechPreisW1','');
  addToApi('Auf.A.EKPreisSummeW1','');
  addToApi('Auf.A.Bemerkung','');
  addToApi('Auf.A.Loeschmarker','');
  addToApi('Auf.A.Rechnungsmark','');
  addToApi('Auf.A.TheorieYN','');
  addToApi('Auf.A.RueckEinzelEKW1','');
  addToApi('Auf.A.interneKostW1','');
  addToApi('Auf.A.Versandpoolnr','');

  // Artikeldaten
  addToApi('Auf.A.ArtikelNr','');
  addToApi('Auf.A.Charge.Adresse','');
  addToApi('Auf.A.Charge.Anschr','');
  addToApi('Auf.A.Charge','');

  // Materialdaten
  addToApi('Auf.A.MaterialNr','');
  addToApi('Auf.A.Dicke','');
  addToApi('Auf.A.Breite','');
  addToApi('Auf.A.Länge','');

  // Protokoll
  addToApi('Auf.A.Anlage.Datum','');
  addToApi('Auf.A.Anlage.Zeit','');
  addToApi('Auf.A.Anlage.User','');


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

  // Argument, fachliche Seite
  vAufNr      : int;
  vAufPos      : int;
  vAufPos2     : int;
  vAufPosAkt   : int;

  vFelderGrp  : alpha;

  // Rückgabedaten
  vAufNode    : handle;     // Handle für Materialnode

  // für Gruppe ALLE
  vDatei  : int;
  vTds    : int;
  vTdsCnt : int;
  vFld    : int;
  vFldCnt : int;
  vFldData   : alpha(4096);

  vFldName : alpha;
  vChkName : alpha;

end
begin

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vAufNr        # CnvIA(aArgs->getValue('NUMMER'));
  vAufPos       # CnvIA(aArgs->getValue('POSITION'));
  vAufPosAkt    # CnvIA(aArgs->getValue('AKTION'));
  vAufPos2      # CnvIA(aArgs->getValue('POSITION2'));

  vFelderGrp    # aArgs->getValue('FELDER');

  // --------------------------------------------------------------------------
  // Datensatz lesen
  RecBufClear(c_DATEI);
  Auf.A.Nummer      # vAufNr;
  Auf.A.Position    # vAufPos;
  Auf.A.Position2   # vAufPos2;
  Auf.A.Aktion      # vAufPosAkt;
  if (RecRead(c_DATEI,1,0) <> _rOK) then begin
      // nicht gefunden
      aResponse->addErrNode(errSVL_Allgemein,'Auftragsaktion nicht gefunden');
      RETURN errPrevent;
  end;

  // Auftragspos. ist ab hier erfolgreich gelesen

  // --------------------------------------------------------------------------
  // Daten schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vAufNode # vNode->addRecord(c_DATEI);

  case (toUpper(vFelderGrp)) of

    //-------------------------------------------------------------------------------
    'ALLE', '' : begin

      vDatei # c_DATEI;
      // Teildatensätze durchgehen
      vTdsCnt # FileInfo(vDatei,_FileSbrCount);
      FOR  vTds # 1;
      LOOP vTds # vTds + 1;
      WHILE (vTds <= vTdsCnt) DO BEGIN

        // Felder durchgehen
        vFldCnt # SbrInfo(vDatei,vTds,_SbrFldCount);
        FOR  vFld # 1;
        LOOP vFld # vFld + 1;
        WHILE (vFld <= vFldCnt) DO BEGIN

          CASE (FldInfo(vDatei,vTds,vFld,_FldType)) OF
            _TypeAlpha    : vFldData # FldAlpha(vDatei,vTds,vFld          );
            _TypeBigInt   : vFldData # CnvAb(FldBigint(vDatei,vTds,vFld)  );
            _TypeByte     : vFldData # CnvAi(FldInt(vDatei,vTds,vFld)     );
            _TypeDate     : vFldData # CnvAd(FldDate(vDatei,vTds,vFld)    );
            _TypeDecimal  : vFldData # CnvAM(FldDecimal(vDatei,vTds,vFld) );
            _TypeFloat    : vFldData # CnvAf(FldFloat(vDatei,vTds,vFld)   );
            _TypeInt      : vFldData # CnvAi(Fldint(vDatei,vTds,vFld)     );
            _TypeLogic    : vFldData # CnvAi(CnvIl(FldLogic(vDatei,vTds,vFld))  );
            _TypeTime     : vFldData # CnvAT(FldTime(vDatei,vTds,vFld)    );
            _TypeWord     : vFldData # CnvAi(FldWord(vDatei,vTds,vFld)    );
          END;

          // Datensatz ist gelesen
          vFldName # (FldName(vDatei,vTds,vFld));



          vAufNode->Lib_XML:AppendNode(toUpper(vFldName),vFldData);

        END; // Felder durchgehen

      END; // // Teildatensätze durchgehen


    end;


    //-------------------------------------------------------------------------------
    'INDI' : begin

      // Argumente durchsuchen und nach gewünschten Feldnamen suchen
      FOR  vNode # aArgs->CteRead(_CteFirst | _CteChildList)
      LOOP vNode # aArgs->CteRead(_CteNext  | _CteChildList, vNode)
      WHILE (vNode > 0) do begin

        vFldName # toUpper(vNode->spName);
        if (StrCut(vFldName,1,6) = 'AUF.P.') then begin

          if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

            // Felder mit Umlauten mappen
            CASE (toUpper(vFldName)) OF
              'AUF.A.STUECKZAHL'      : vFldName #  'Auf.A.Stückzahl';
              'AUF.A.LOESCHMARKER'    : vFldName #  'Auf.A.Löschmarker';
              'Auf.A.RUECKEINZELEKW1'       : vFldName #  'Auf.A.RückEinzelEKW1';
            END;

            // Feld mit "normalem" Namen prüfen
            vErg # FldInfoByName(vFldName,_FldExists);

            // Feld vorhanden?
            if (vErg <> 0) then begin

              // Alle Feldnamen in Großbuchstabenexportieren
              vFldName # toUpper(vFldName);

               // Wenn vorhanden dann je nach Feldtyp schreiben
               CASE (FldInfoByName(vFldName,_FldType)) OF
                  _TypeAlpha    : vAufNode->Lib_XML:AppendNode(vFldName, FldAlphaByName(vFldName));
                  _TypeBigInt   : vAufNode->Lib_XML:AppendNode(vFldName, CnvAb(FldBigIntByName(vFldName)));
                  _TypeDate     : vAufNode->Lib_XML:AppendNode(vFldName, CnvAd(FldDateByName(vFldName)));
                  _TypeDecimal  : vAufNode->Lib_XML:AppendNode(vFldName, CnvAM(FldDecimalByName(vFldName)));
                  _TypeFloat    : vAufNode->Lib_XML:AppendNode(vFldName, CnvAf(FldFloatByName(vFldName)));
                  _TypeInt      : vAufNode->Lib_XML:AppendNode(vFldName, CnvAi(FldIntByName(vFldName)));
                  _TypeLogic    : vAufNode->Lib_XML:AppendNode(vFldName, CnvAi(CnvIl(FldLogicByName(vFldName))));
                  _TypeTime     : vAufNode->Lib_XML:AppendNode(vFldName, CnvAt(FldTimeByName(vFldName)));
                  _TypeWord     : vAufNode->Lib_XML:AppendNode(vFldName, CnvAi(FldWordByName(vFldName)));
               END;

            end else begin
              // FEHLER
              // Feld gibts nicht, dann nicht anhängen
            end;

          end;

        end;

      END;

    end;
    //-------------------------------------------------------------------------------

  end;


  // --------------------------------------------------------------------------
  // Abschlussarbeiten

  // Daten des Services sind angehängt
  return _rOk;

End; // sub exec(...) : int



//=========================================================================
//=========================================================================
//=========================================================================
