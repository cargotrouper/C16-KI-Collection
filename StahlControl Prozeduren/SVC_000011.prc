@A
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000011
//                  OHNE E_R_G
//  Zu Service: AUF_READ
//
//  Info
//  AUF_READ: Lesen von Auftragskopfdaten und Rückgabe der angegeben Felder
//
//  14.02.2011  ST  Erstellung der Prozedur
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

  c_DATEI       : 400
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

  // Materialnr
  vNode # vApi->apiAdd('NUMMER',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Auftragsnummer des Auftrages','321823');

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Hauptdaten
  addToApi('Auf.Nummer','');
  addToApi('Auf.Datum','');
  addToApi('Auf.Vorgangstyp','');
  addToApi('Auf.LiefervertragYN','');
  addToApi('Auf.AbrufYN','');
  addToApi('Auf.GueltigkeitVom','');
  addToApi('Auf.GueltigkeitBis','');
  addToApi('Auf.Kundennr','');
  addToApi('Auf.KundenStichwort','');
  addToApi('Auf.Lieferadresse','');
  addToApi('Auf.Lieferanschrift','');
  addToApi('Auf.Tour','');
  addToApi('Auf.Verbraucher','');
  addToApi('Auf.Rechnungsempf','');
  addToApi('Auf.Sachbearbeiter','');
  addToApi('Auf.Lieferbed','');
  addToApi('Auf.Zahlungsbed','');
  addToApi('Auf.Versandart','');
  addToApi('Auf.Waehrung','');
  addToApi('Auf.Waehrungskurs','');
  addToApi('Auf.WaehrungFixYN','');
  addToApi('Auf.AbmessungsEH','');
  addToApi('Auf.GewichtsEH','');
  addToApi('Auf.Sprache','');
  addToApi('Auf.Best.Nummer','');
  addToApi('Auf.Best.Datum','');
  addToApi('Auf.Best.Bearbeiter','');
  addToApi('Auf.BDSNummer','');
  addToApi('Auf.Land','');
  addToApi('Auf.Vertreter','');
  addToApi('Auf.Vertreter.Prov','');
  addToApi('Auf.Vertreter.ProT','');
  addToApi('Auf.Loeschmarker','');
  addToApi('Auf.Aktionsmarker','');
  addToApi('Auf.Steuerschluessel','');
  addToApi('Auf.Vertreter2','');
  addToApi('Auf.Vertreter2.Prov','');
  addToApi('Auf.Vertreter2.ProT','');

  // Protokoll
  addToApi('Auf.Anlage.Datum','');
  addToApi('Auf.Anlage.Zeit','');
  addToApi('Auf.Anlage.User','');

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
  vAktNr      : int;
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

end
begin

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vAufNr        # CnvIA(aArgs->getValue('NUMMER'));

  vFelderGrp    # aArgs->getValue('FELDER');

  // --------------------------------------------------------------------------
  // Datensatz lesen
  RecBufClear(c_DATEI);
  Auf.Nummer      # vAufNr;
  if (RecRead(c_DATEI,1,0) <> _rOK) then begin
      // nicht gefunden
      aResponse->addErrNode(errSVL_Allgemein,'Auftrag nicht gefunden');
      RETURN errPrevent;
  end;

  // Reservierung ist ab hier erfolgreich gelesen

  // --------------------------------------------------------------------------
  // Daten schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vResNode # vNode->addRecord(c_DATEI);

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
          vResNode->Lib_XML:AppendNode(toUpper(vFldName),vFldData);

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
        if (StrCut(vFldName,1,4) = 'AUF.') then begin

          if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

            // Felder mit Umlauten mappen
            CASE (toUpper(vFldName)) OF
              'AUF.GUELTIGKEITVOM'    : vFldName #  'Auf.GültigkeitVom';     // TDS 1: Hauptdaten
              'AUF.GUELTIGKEITBIS'    : vFldName #  'Auf.GültigkeitBis';
              'AUF.WAEHRUNG'          : vFldName #  'Auf.Währung';
              'AUF.WAEHRUNGSKURS'     : vFldName #  'Auf.Währungskurs';
              'AUF.WAEHRUNGFIXYN'     : vFldName #  'Auf.WährungFixYN';
              'AUF.LOESCHMARKER'      : vFldName #  'Auf.Löschmarker';
              'AUF.STEUERSCHLUESSEL'  : vFldName #  'Auf.Steuerschlüssel';
            END;

            // Feld mit "normalem" Namen prüfen
            vErg # FldInfoByName(vFldName,_FldExists);

            // Feld vorhanden?
            if (vErg <> 0) then begin

              // Alle Feldnamen in Großbuchstabenexportieren
              vFldName # toUpper(vFldName);

               // Wenn vorhanden dann je nach Feldtyp schreiben
               CASE (FldInfoByName(vFldName,_FldType)) OF
                  _TypeAlpha    : vResNode->Lib_XML:AppendNode(vFldName, FldAlphaByName(vFldName));
                  _TypeBigInt   : vResNode->Lib_XML:AppendNode(vFldName, CnvAb(FldBigIntByName(vFldName)));
                  _TypeDate     : vResNode->Lib_XML:AppendNode(vFldName, CnvAd(FldDateByName(vFldName)));
                  _TypeDecimal  : vResNode->Lib_XML:AppendNode(vFldName, CnvAM(FldDecimalByName(vFldName)));
                  _TypeFloat    : vResNode->Lib_XML:AppendNode(vFldName, CnvAf(FldFloatByName(vFldName)));
                  _TypeInt      : vResNode->Lib_XML:AppendNode(vFldName, CnvAi(FldIntByName(vFldName)));
                  _TypeLogic    : vResNode->Lib_XML:AppendNode(vFldName, CnvAi(CnvIl(FldLogicByName(vFldName))));
                  _TypeTime     : vResNode->Lib_XML:AppendNode(vFldName, CnvAt(FldTimeByName(vFldName)));
                  _TypeWord     : vResNode->Lib_XML:AppendNode(vFldName, CnvAi(FldWordByName(vFldName)));
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


    /*
    // BEISPIEL:

         Manuelle Abfrage
      if (CnvIA(aArgs->getValue('Mat.Nummer')) = 1) then
        vResNode->Lib_XML:AppendNode('Mat.Nummer',  AInt(Mat.Nummer));

      if (CnvIA(aArgs->getValue('Mat.Vorgänger')) = 1) then
        vResNode->Lib_XML:AppendNode('Mat.Vorgaenger',  AInt("Mat.Vorgänger"));

      if (CnvIA(aArgs->getValue('Mat.Ursprung')) = 1) then
        vResNode->Lib_XML:AppendNode('Mat.Ursprung',  AInt("Mat.Ursprung"));
    */

  end;


  // --------------------------------------------------------------------------
  // Abschlussarbeiten

  // Daten des Services sind angehängt
  return _rOk;

End; // sub exec(...) : int



//=========================================================================
//=========================================================================
//=========================================================================
