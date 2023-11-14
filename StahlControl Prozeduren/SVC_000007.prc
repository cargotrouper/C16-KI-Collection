@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000007
//                  OHNE E_R_G
//  Zu Service: MAT_RES_READ
//
//  Info
//  MAT_RES_READ: Lesen von Reservierungsdaten und Rückgabe der angegeben Felder
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

  // Reservierungsnummer
  vNode # vApi->apiAdd('NUMMER',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Reservierungsnummer des zu lesenden Reservierung','321823');

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Hauptdaten
  addToApi('Mat.R.Materialnr'     ,'');
  addToApi('Mat.R.Reservierungnr' ,'');
  addToApi('Mat.R.Kommission'     ,'');
  addToApi('Mat.R.Auftragsnr'     ,'');
  addToApi('Mat.R.Auftragspos'    ,'');
  addToApi('Mat.R.Kundennummer'   ,'');
  addToApi('Mat.R.KundenSW'       ,'');
  addToApi('Mat.R.Stueckzahl'     ,'');
  addToApi('Mat.R.Gewicht'        ,'');
  addToApi('Mat.R.Bemerkung'      ,'');
  addToApi('Mat.R.Ablaufdatum'    ,'');
  addToApi('Mat.R.Traegertyp'     ,'');
  addToApi('Mat.R.Traegernummer1' ,'');
  addToApi('Mat.R.Traegernummer2' ,'');
  addToApi('Mat.R.Traegernummer3' ,'');

  // Protokoll
  addToApi('Mat.R.Anlage.Datum'     ,'');
  addToApi('Mat.R.Anlage.Zeit'     ,'');
  addToApi('Mat.R.Anlage.User'     ,'');
  addToApi('Mat.R.TrackingYN'     ,'');
  addToApi('Mat.R.Workflow'     ,'');

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
  vResNr      : int;
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
  vResNr        # CnvIA(aArgs->getValue('NUMMER'));

  vFelderGrp    # aArgs->getValue('FELDER');

  // --------------------------------------------------------------------------
  // Reservierung lesen
  RecBufClear(203);
  Mat.R.Reservierungnr # vResNr;
  if (RecRead(203,1,0) <> _rOK) then begin
      // nicht gefunden
      aResponse->addErrNode(errSVL_Allgemein,'Reservierungsnummer unbekannt');
      RETURN errPrevent;
  end;

  // Reservierung ist ab hier erfolgreich gelesen

  // --------------------------------------------------------------------------
  // Daten schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vResNode # vNode->addRecord(203);

  case (toUpper(vFelderGrp)) of

    //-------------------------------------------------------------------------------
    'ALLE', '' : begin

      vDatei # 203;
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
        if (StrCut(vFldName,1,6) = 'MAT.R.') then begin

          if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin


            // Felder mit Umlauten mappen
            CASE (toUpper(vFldName)) OF
              'MAT.R.STUECKZAHL'    : vFldName #  'Mat.R.Stückzahl';     // TDS 1: Hauptdaten
              'MAT.R.TRAEGERTYP'    : vFldName #  'Mat.R.Trägertyp';
              'MAT.R.TRAEGERNUMMER1' : vFldName #  'Mat.R.Trägernummer1';
              'MAT.R.TRAEGERNUMMER2' : vFldName #  'Mat.R.Trägernummer2';
              'MAT.R.TRAEGERNUMMER3' : vFldName #  'Mat.R.Trägernummer3';
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
