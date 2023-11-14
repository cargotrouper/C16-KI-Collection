@A
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000023
//                  OHNE E_R_G
//  Zu Service: EIN_POS_WE_READ
//
//  Info
//  EIN_POS_WE_READ: Lesen von Wareneingängen und Rückgabe der angegeben Felder
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

  c_DATEI       : 506
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
  vNode->apiSetDesc('Eindeutige Bestellnummer des Eingangs','123045');

  // Auftragsposition
  vNode # vApi->apiAdd('POSITION',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Positionsnummer des Eingangs','1');

  // Auftragsaktion
  vNode # vApi->apiAdd('EINGANG',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Eingangsnummer des Eingangs','1');

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Haupdaten
  addToApi('Ein.E.Nummer','');
  addToApi('Ein.E.Position','');
  addToApi('Ein.E.Eingangsnr','');
  addToApi('Ein.E.Lieferantennr','');
  addToApi('Ein.E.Warengruppe','');
  addToApi('Ein.E.VSBYN','');
  addToApi('Ein.E.VSB_Datum','');
  addToApi('Ein.E.EingangYN','');
  addToApi('Ein.E.Eingang_Datum','');
  addToApi('Ein.E.AusfallYN','');
  addToApi('Ein.E.Ausfall_Datum','');
  addToApi('Ein.E.Preis','');
  addToApi('Ein.E.PreisW1','');
  addToApi('Ein.E.Kommission','');
  addToApi('Ein.E.Bemerkung','');
  addToApi('Ein.E.Lieferscheinnr','');
  addToApi('Ein.E.Lageradresse','');
  addToApi('Ein.E.Lageranschrift','');
  addToApi('Ein.E.Lagerplatz','');
  addToApi('Ein.E.Menge','');
  addToApi('Ein.E.Stueckzahl','');
  addToApi('Ein.E.Gewicht','');
  addToApi('Ein.E.MEH','');
  addToApi('Ein.E.Intrastatnr','');
  addToApi('Ein.E.GesperrtYN','');
  addToApi('Ein.E.Loeschmarker','');
  addToApi('Ein.E.Waehrung','');

  // Artikeldaten
  addToApi('Ein.E.Artikelnr','');
  addToApi('Ein.E.Charge','');
  addToApi('Ein.E.Art.Zustand','');

  // Materialdaten
  addToApi('Ein.E.Materialnr','');
  addToApi('Ein.E.Guete','');
  addToApi('Ein.E.Guetenstufe','');
  addToApi('Ein.E.Erzeuger','');
  addToApi('Ein.E.Coilnummer','');
  addToApi('Ein.E.Ringnummer','');
  addToApi('Ein.E.Werksnummer','');
  addToApi('Ein.E.Chargennummer','');
  addToApi('Ein.E.Dicke','');
  addToApi('Ein.E.DickenTolYN','');
  addToApi('Ein.E.DickenTol','');
  addToApi('Ein.E.Dicke.Von','');
  addToApi('Ein.E.Dicke.Bis','');
  addToApi('Ein.E.Breite','');
  addToApi('Ein.E.BreitenTolYN','');
  addToApi('Ein.E.BreitenTol','');
  addToApi('Ein.E.Breite.Von','');
  addToApi('Ein.E.Breite.Bis','');
  addToApi('Ein.E.Laenge','');
  addToApi('Ein.E.LaengenTolYN','');
  addToApi('Ein.E.LaengenTol','');
  addToApi('Ein.E.Laenge.Von','');
  addToApi('Ein.E.Laenge.Bis','');
  addToApi('Ein.E.RID','');
  addToApi('Ein.E.RAD','');
  addToApi('Ein.E.AusfOben','');
  addToApi('Ein.E.AusfUnten','');
  addToApi('Ein.E.Ursprungsland','');

  // Verpackung
  addToApi('Ein.E.Verwiegungsart','');
  addToApi('Ein.E.Gewicht.Netto','');
  addToApi('Ein.E.Gewicht.Brutto','');
  addToApi('Ein.E.AbbindungL','');
  addToApi('Ein.E.AbbindungQ','');
  addToApi('Ein.E.Zwischenlage','');
  addToApi('Ein.E.Unterlage','');
  addToApi('Ein.E.StehendYN','');
  addToApi('Ein.E.LiegendYN','');
  addToApi('Ein.E.Nettoabzug','');
  addToApi('Ein.E.Stapelhoehe','');
  addToApi('Ein.E.Stapelhoehenabz','');
  addToApi('Ein.E.Rechtwinkligk','');
  addToApi('Ein.E.Ebenheit','');
  addToApi('Ein.E.Saebeligkeit','');
  addToApi('Ein.E.Umverpackung','');
  addToApi('Ein.E.Wicklung','');

  // Analyse
  addToApi('Ein.E.Streckgrenze','');
  addToApi('Ein.E.Zugfestigkeit','');
  addToApi('Ein.E.DehnungA','');
  addToApi('Ein.E.DehnungB','');
  addToApi('Ein.E.RP02_1','');
  addToApi('Ein.E.RP10_1','');
  addToApi('Ein.E.Koernung','');
  addToApi('Ein.E.Chemie.C','');
  addToApi('Ein.E.Chemie.Si','');
  addToApi('Ein.E.Chemie.Mn','');
  addToApi('Ein.E.Chemie.P','');
  addToApi('Ein.E.Chemie.S','');
  addToApi('Ein.E.Chemie.Al','');
  addToApi('Ein.E.Chemie.Cr','');
  addToApi('Ein.E.Chemie.V','');
  addToApi('Ein.E.Chemie.Nb','');
  addToApi('Ein.E.Chemie.Ti','');
  addToApi('Ein.E.Chemie.N','');
  addToApi('Ein.E.Chemie.Cu','');
  addToApi('Ein.E.Chemie.Ni','');
  addToApi('Ein.E.Chemie.Mo','');
  addToApi('Ein.E.Chemie.B','');
  addToApi('Ein.E.Haerte1','');
  addToApi('Ein.E.Chemie.Frei1','');
  addToApi('Ein.E.Mech.Sonstig','');
  addToApi('Ein.E.Haerte2','');
  addToApi('Ein.E.RauigkeitA1','');
  addToApi('Ein.E.RauigkeitA2','');
  addToApi('Ein.E.RauigkeitB1','');
  addToApi('Ein.E.RauigkeitB2','');
  addToApi('Ein.E.Streckgrenze2','');
  addToApi('Ein.E.Zugfestigkeit2','');
  addToApi('Ein.E.RP02_2','');
  addToApi('Ein.E.RP10_2','');
  addToApi('Ein.E.Koernung2','');

  // Protokoll
  addToApi('Ein.E.Anlage.Datum','');
  addToApi('Ein.E.Anlage.Zeit','');
  addToApi('Ein.E.Anlage.User','');

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
  vEinNr      : int;
  vEinPos      : int;
  vEinLfdnr     : int;

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
  vEinNr        # CnvIA(aArgs->getValue('NUMMER'));
  vEinPos       # CnvIA(aArgs->getValue('POSITION'));
  vEinLfdnr      # CnvIA(aArgs->getValue('EINGANG'));

  vFelderGrp    # aArgs->getValue('FELDER');

  // --------------------------------------------------------------------------
  // Datensatz lesen
  RecBufClear(c_DATEI);
  Ein.E.Nummer      # vEinNr;
  Ein.E.Position    # vEinPos;
  Ein.E.Eingangsnr  # vEinLfdnr;
  if (RecRead(c_DATEI,1,0) <> _rOK) then begin
      // nicht gefunden
      aResponse->addErrNode(errSVL_Allgemein,'Wareneingang nicht gefunden');
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
        if (StrCut(vFldName,1,6) = 'EIN.E.') then begin

          if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

            // Felder mit Umlauten mappen
            CASE (toUpper(vFldName)) OF
              'EIN.E.STUECKZAHL'        : vFldName #  'Ein.E.Stückzahl';
              'EIN.E.LOESCHMARKER'      : vFldName #  'Ein.E.Löschmarker';
              'EIN.E.WAEHRUNG'          : vFldName #  'Ein.E.Währung';
              'EIN.E.GUETE'             : vFldName #  'Ein.E.Güte';
              'EIN.E.GUETENSTUFE'       : vFldName #  'Ein.E.Gütenstufe';
              'EIN.E.LAENGE'            : vFldName #  'Ein.E.Länge';
              'EIN.E.LAENGENTOLYN'      : vFldName #  'Ein.E.LängenTolYN';
              'EIN.E.LAENGENTOL'        : vFldName #  'Ein.E.LängenTol';
              'EIN.E.LAENGENTOL.VON'    : vFldName #  'Ein.E.LängenTol.Von';
              'EIN.E.LAENGENTOL.BIS'    : vFldName #  'Ein.E.LängenTol.Bis';
              'EIN.E.SAEBELIGKEIT'      : vFldName #  'Ein.E.Säbeligkeit';
              'EIN.E.SAEBELPROM'        : vFldName #  'Ein.E.SäbelProM';
              'EIN.E.KOERNUNG'          : vFldName #  'Ein.E.Körnung';
              'EIN.E.KOERNUNG2'         : vFldName #  'Ein.E.Körnung2';
              'EIN.E.HAERTE1'           : vFldName #  'Ein.E.Härte1';
              'EIN.E.HAERTE2'           : vFldName #  'Ein.E.Härte2';
              'EIN.E.STAPELHOEHE'       : vFldName #  'Ein.E.Stapelhöhe';
              'EIN.E.STAPELHOEHENABZ'   : vFldName #  'Ein.E.Stapelhöhenabz';
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
