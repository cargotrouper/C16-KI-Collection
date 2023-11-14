@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000005
//                  OHNE E_R_G
//  Zu Service: ANS_READ
//
//  Info
///  ANS_READ: Lesen von Ansprechpartnern und Rückgabe der angegeben Felder
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

  // Adressnummer
  vNode # vApi->apiAdd('ADRNUMMER',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Adressnummer des zu lesenden Ansprechpartners','124102');

  // Adressnummer
  vNode # vApi->apiAdd('NUMMER',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Ansprechpartnernummer des zu lesenden Ansprechpartners','3');


  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------
  // Hauptdaten
  addToApi('Adr.P.Adressnr'     ,'Eindeutige Adressnummer');
  addToApi('Adr.P.Nummer'       ,'');
  addToApi('Adr.P.Stichwort'     ,'');
  addToApi('Adr.P.Vorname'     ,'');
  addToApi('Adr.P.Name'     ,'');
  addToApi('Adr.P.Titel'     ,'');
  addToApi('Adr.P.Telefon'     ,'');
  addToApi('Adr.P.Telefax'     ,'');
  addToApi('Adr.P.Mobil'     ,'');
  addToApi('Adr.P.eMail'     ,'');
  addToApi('Adr.P.Abteilung'     ,'');
  addToApi('Adr.P.Funktion'     ,'');
  addToApi('Adr.P.Vorgesetzter'     ,'');
  addToApi('Adr.P.Briefanrede'     ,'');
  addToApi('Adr.P.Priv.LKZ'     ,'');
  addToApi('Adr.P.Priv.PLZ'     ,'');
  addToApi('Adr.P.Priv.Strasse'     ,'');
  addToApi('Adr.P.Priv.Ort'     ,'');
  addToApi('Adr.P.Priv.Telefon'     ,'');
  addToApi('Adr.P.Priv.Telefax'     ,'');
  addToApi('Adr.P.Priv.eMail'     ,'');
  addToApi('Adr.P.Priv.Mobil'     ,'');
  addToApi('Adr.P.Geburtsdatum'     ,'');
  addToApi('Adr.P.PrivGeschenkYN'     ,'');
  addToApi('Adr.P.Familienstand'     ,'');
  addToApi('Adr.P.Hobbies'     ,'');
  addToApi('Adr.P.Vorlieben'     ,'');
  addToApi('Adr.P.Auto'     ,'');
  addToApi('Adr.P.Religion'     ,'');
  addToApi('Adr.P.Partner.Name'     ,'');
  addToApi('Adr.P.Partner.GebTag'     ,'');
  addToApi('Adr.P.Hochzeitstag'     ,'');
  addToApi('Adr.P.Kind1.Name'     ,'');
  addToApi('Adr.P.Kind1.GebTag'     ,'');
  addToApi('Adr.P.Kind2.Name'     ,'');
  addToApi('Adr.P.Kind2.GebTag'     ,'');
  addToApi('Adr.P.Kind3.Name'     ,'');
  addToApi('Adr.P.Kind3.GebTag'     ,'');
  addToApi('Adr.P.Kind4.Name'     ,'');
  addToApi('Adr.P.Kind4.GebTag'     ,'');


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
  vAdrNr      : int;
  vAnsNr      : int;
  vFelderGrp  : alpha;

  // Rückgabedaten
  vAnsNode    : handle;     // Handle für Materialnode

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
  vAdrNr        # CnvIA(aArgs->getValue('ADRNUMMER'));
  vAnsNr        # CnvIA(aArgs->getValue('NUMMER'));

  vFelderGrp    # aArgs->getValue('FELDER');

  // --------------------------------------------------------------------------
  // Adresse lesen
  RecBufClear(102);
  Adr.P.Adressnr  # vAdrNr;
  Adr.P.Nummer    # vAnsNr;
  if (RecRead(102,1,0) <> _rOK) then begin
      // Adresse nicht vorhanden
      aResponse->addErrNode(errSVL_Allgemein,'Ansprechpartner unbekannt');
      RETURN errPrevent;
  end;

  // Adresse ist ab hier erfolgreich gelesen

  // --------------------------------------------------------------------------
  // Daten schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vAnsNode # vNode->addRecord(102);

  case (toUpper(vFelderGrp)) of

    //-------------------------------------------------------------------------------
    'ALLE', '' : begin

      vDatei # 102;
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
          vAnsNode->Lib_XML:AppendNode(toUpper(vFldName),vFldData);

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
        if (StrCut(vFldName,1,6) = 'ADR.P.') then begin

          if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

            // Felder mit Umlauten mappen
            CASE (toUpper(vFldName)) OF
              'ADR.P.PRIV.STRASSE'    : vFldName #  'Adr.P.Priv.Straße';     // TDS 1: Hauptdaten
            END;

            // Feld mit "normalem" Namen prüfen
            vErg # FldInfoByName(vFldName,_FldExists);

            // Feld vorhanden?
            if (vErg <> 0) then begin

              // Alle Feldnamen in Großbuchstabenexportieren
              vFldName # toUpper(vFldName);

               // Wenn vorhanden dann je nach Feldtyp schreiben
               CASE (FldInfoByName(vFldName,_FldType)) OF
                  _TypeAlpha    : vAnsNode->Lib_XML:AppendNode(vFldName, FldAlphaByName(vFldName));
                  _TypeBigInt   : vAnsNode->Lib_XML:AppendNode(vFldName, CnvAb(FldBigIntByName(vFldName)));
                  _TypeDate     : vAnsNode->Lib_XML:AppendNode(vFldName, CnvAd(FldDateByName(vFldName)));
                  _TypeDecimal  : vAnsNode->Lib_XML:AppendNode(vFldName, CnvAM(FldDecimalByName(vFldName)));
                  _TypeFloat    : vAnsNode->Lib_XML:AppendNode(vFldName, CnvAf(FldFloatByName(vFldName)));
                  _TypeInt      : vAnsNode->Lib_XML:AppendNode(vFldName, CnvAi(FldIntByName(vFldName)));
                  _TypeLogic    : vAnsNode->Lib_XML:AppendNode(vFldName, CnvAi(CnvIl(FldLogicByName(vFldName))));
                  _TypeTime     : vAnsNode->Lib_XML:AppendNode(vFldName, CnvAt(FldTimeByName(vFldName)));
                  _TypeWord     : vAnsNode->Lib_XML:AppendNode(vFldName, CnvAi(FldWordByName(vFldName)));
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
        vAnsNode->Lib_XML:AppendNode('Mat.Nummer',  AInt(Mat.Nummer));

      if (CnvIA(aArgs->getValue('Mat.Vorgänger')) = 1) then
        vAnsNode->Lib_XML:AppendNode('Mat.Vorgaenger',  AInt("Mat.Vorgänger"));

      if (CnvIA(aArgs->getValue('Mat.Ursprung')) = 1) then
        vAnsNode->Lib_XML:AppendNode('Mat.Ursprung',  AInt("Mat.Ursprung"));
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