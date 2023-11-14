@A
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000032
//                  OHNE E_R_G
//  Zu Service: BAG_POS_FER_READ
//
//  Info
//  BAG_POS_FER_READ: Lesen von Betriebsauftragsfertigungen und Rückgabe der angegeben Felder
//
//  17.02.2011  ST  Erstellung der Prozedur
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

  c_DATEI       : 703
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
  vNode->apiSetDesc('Eindeutige Nummer der Betriebsauftragsfertigung','123045');

  // Auftragsposition
  vNode # vApi->apiAdd('POSITION',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Positionsnummer der Betriebsauftragsfertigung','1');

  // Auftragsposition
  vNode # vApi->apiAdd('FERTIGUNG',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Fertigungsnummer der Betriebsauftragsfertigung','1');


  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Haupdaten
  addToApi('BAG.F.Nummer','');
  addToApi('BAG.F.Position','');
  addToApi('BAG.F.Fertigung','');
  addToApi('BAG.F.Loeschmarker','');
  addToApi('BAG.F.Warengruppe','');
  addToApi('BAG.F.KostentraegerYN','');
  addToApi('BAG.F.ReservierenYN','');
  addToApi('BAG.F.Kommission','');
  addToApi('BAG.F.Auftragsnummer','');
  addToApi('BAG.F.Auftragspos','');
  addToApi('BAG.F.AuftragsFertig','');
  addToApi('BAG.F.ReservFuerKunde','');
  addToApi('BAG.F.Verpackung','');
  addToApi('BAG.F.Stueckzahl','');
  addToApi('BAG.F.Gewicht','');
  addToApi('BAG.F.Menge','');
  addToApi('BAG.F.MEH','');
  addToApi('BAG.F.Fertig.Stk','');
  addToApi('BAG.F.Fertig.Gew','');
  addToApi('BAG.F.Fertig.Menge','');
  addToApi('BAG.F.AutomatischYN','');
  addToApi('BAG.F.Bemerkung','');
  addToApi('BAG.F.KundenArtNr','');
  addToApi('BAG.F.zuVersand','');
  addToApi('BAG.F.zuVersand.Pos','');
  addToApi('BAG.F.PlanSchrottYN','');

  // Artikel
  addToApi('BAG.F.Artikelnummer','');

  // Material
  addToApi('BAG.F.Guete','');
  addToApi('BAG.F.Guetenstufe','');
  addToApi('BAG.F.AusfOben','');
  addToApi('BAG.F.AusfUnten','');
  addToApi('BAG.F.Dicke','');
  addToApi('BAG.F.Dickentol','');
  addToApi('BAG.F.Dickentol.Von','');
  addToApi('BAG.F.Dickentol.Bis','');
  addToApi('BAG.F.Breite','');
  addToApi('BAG.F.Breitentol','');
  addToApi('BAG.F.Breitentol.Von','');
  addToApi('BAG.F.Breitentol.Bis','');
  addToApi('BAG.F.Laenge','');
  addToApi('BAG.F.Laengentol','');
  addToApi('BAG.F.Laengentol.Von','');
  addToApi('BAG.F.Laengentol.Bis','');
  addToApi('BAG.F.Streifenanzahl','');
  addToApi('BAG.F.Block','');
  addToApi('BAG.F.RID','');
  addToApi('BAG.F.RIDMax','');
  addToApi('BAG.F.RAD','');
  addToApi('BAG.F.RADMax','');
  addToApi('BAG.F.Etk.Guete','');
  addToApi('BAG.F.Etk.Dicke','');
  addToApi('BAG.F.Etk.Breite','');
  addToApi('BAG.F.Etk.Laenge','');
  addToApi('BAG.F.Etk.Feld.1','');
  addToApi('BAG.F.Etk.Feld.2','');
  addToApi('BAG.F.Etk.Feld.3','');
  addToApi('BAG.F.Etk.Feld.4','');
  addToApi('BAG.F.Etk.Feld.5','');

  // Protokoll
  addToApi('BAG.F.Anlage.Datum','');
  addToApi('BAG.F.Anlage.Zeit','');
  addToApi('BAG.F.Anlage.User','');

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
  vBagNr      : int;
  vBagPos      : int;
  vBagFert     : int;

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
  vBagNr        # CnvIA(aArgs->getValue('NUMMER'));
  vBagPos       # CnvIA(aArgs->getValue('POSITION'));
  vBagFert      # CnvIA(aArgs->getValue('FERTIGUNG'));

  vFelderGrp    # aArgs->getValue('FELDER');

  // --------------------------------------------------------------------------
  // Datensatz lesen
  RecBufClear(c_DATEI);
  Bag.F.Nummer      # vBagNr;
  Bag.F.Position    # vBagPos;
  Bag.F.Fertigung   # vBagFert;
  if (RecRead(c_DATEI,1,0) <> _rOK) then begin
      // nicht gefunden
      aResponse->addErrNode(errSVL_Allgemein,'Betriebsauftragsfertigung nicht gefunden');
      RETURN errPrevent;
  end;

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
        if (StrCut(vFldName,1,6) = 'BAG.F.') then begin

          if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

            // Felder mit Umlauten mappen
            CASE (toUpper(vFldName)) OF
              'BAG.F.LOESCHMARKER'    : vFldName #  'Bag.F.Löschmarker';
              'BAG.F.KOSTENTRAEGERYN' : vFldName #  'Bag.F.kostenträgerYN';
              'BAG.F.RESERVFUERKUNDE' : vFldName #  'Bag.F.ReservFürKunde';
              'BAG.F.STUECKZAHL'      : vFldName #  'Bag.F.Stückzahl';
              'BAG.F.GUETE'           : vFldName #  'Bag.F.Güte';
              'BAG.F.GUETENSTUFE'     : vFldName #  'Bag.F.Gütenstufe';
              'BAG.F.LAENGE'          : vFldName #  'Bag.F.Länge';
              'BAG.F.LAENGENTOL'      : vFldName #  'Bag.F.Längentol';
              'BAG.F.LAENGENTOL.VON'  : vFldName #  'Bag.F.Längentol.Von';
              'BAG.F.LAENGENTOL.BIS'  : vFldName #  'Bag.F.Längentol.Bis';
              'BAG.F.ETK.GUETE'       : vFldName #  'Bag.F.Etk.Güte';
              'BAG.F.ETK.LAENGE'      : vFldName #  'Bag.F.Etk.Länge';
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

  end;


  // --------------------------------------------------------------------------
  // Abschlussarbeiten

  // Daten des Services sind angehängt
  return _rOk;

End; // sub exec(...) : int



//=========================================================================
//=========================================================================
//=========================================================================
