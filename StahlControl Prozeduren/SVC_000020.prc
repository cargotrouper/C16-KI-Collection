@A
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000020
//                  OHNE E_R_G
//  Zu Service: EIN_POS_READ
//
//  Info
//  EIN_POST_READ: Lesen von Bestellpositionen und Rückgabe der angegeben Felder
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

  c_DATEI       : 501
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
  vNode->apiSetDesc('Eindeutige Bestellnummer der Bestellposition','123045');

  // Auftragsposition
  vNode # vApi->apiAdd('POSITION',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Positionsnummer der Bestellposition','1');

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Haupdaten
  addToApi('Ein.P.Nummer','');
  addToApi('Ein.P.Position','');
  addToApi('Ein.P.Nummer','');
  addToApi('Ein.P.Position','');
  addToApi('Ein.P.Lieferantennr','');
  addToApi('Ein.P.LieferantenSW','');
  addToApi('Ein.P.Auftragsart','');
  addToApi('Ein.P.AbrufAufNr','');
  addToApi('Ein.P.AbrufAufPos','');
  addToApi('Ein.P.Warengruppe','');
  addToApi('Ein.P.ArtikelID','');
  addToApi('Ein.P.Artikelnr','');
  addToApi('Ein.P.ArtikelSW','');
  addToApi('Ein.P.LieferArtNr','');
  addToApi('Ein.P.Sachnummer','');
  addToApi('Ein.P.Katalognr','');
  addToApi('Ein.P.AusfOben','');
  addToApi('Ein.P.AusfUnten','');
  addToApi('Ein.P.Guete','');
  addToApi('Ein.P.Guetenstufe','');
  addToApi('Ein.P.Werkstoffnr','');
  addToApi('Ein.P.Intrastatnr','');
  addToApi('Ein.P.Strukturnr','');
  addToApi('Ein.P.TextNr1','');
  addToApi('Ein.P.TextNr2','');
  addToApi('Ein.P.Dicke','');
  addToApi('Ein.P.Breite','');
  addToApi('Ein.P.Laenge','');
  addToApi('Ein.P.Dickentol','');
  addToApi('Ein.P.Breitentol','');
  addToApi('Ein.P.Laengentol','');
  addToApi('Ein.P.Zeugnisart','');
  addToApi('Ein.P.Kommission','');
  addToApi('Ein.P.KommissionNr','');
  addToApi('Ein.P.KommissionPos','');
  addToApi('Ein.P.KommiKunde','');
  addToApi('Ein.P.RID','');
  addToApi('Ein.P.RIDMax','');
  addToApi('Ein.P.RAD','');
  addToApi('Ein.P.RADMax','');
  addToApi('Ein.P.Stueckzahl','');
  addToApi('Ein.P.Gewicht','');
  addToApi('Ein.P.Menge.Wunsch','');
  addToApi('Ein.P.MEH.Wunsch','');
  addToApi('Ein.P.PEH','');
  addToApi('Ein.P.Grundpreis','');
  addToApi('Ein.P.AufpreisYN','');
  addToApi('Ein.P.Aufpreis','');
  addToApi('Ein.P.Einzelpreis','');
  addToApi('Ein.P.Gesamtpreis','');
  addToApi('Ein.P.Kalkuliert','');
  addToApi('Ein.P.Termin1W.Art','');
  addToApi('Ein.P.Termin1W.Zahl','');
  addToApi('Ein.P.Termin1W.Jahr','');
  addToApi('Ein.P.Termin1Wunsch','');
  addToApi('Ein.P.Termin2W.Zahl','');
  addToApi('Ein.P.Termin2W.Jahr','');
  addToApi('Ein.P.Termin2Wunsch','');
  addToApi('Ein.P.TerminZ.Zahl','');
  addToApi('Ein.P.TerminZ.Jahr','');
  addToApi('Ein.P.TerminZusage','');
  addToApi('Ein.P.Bemerkung','');
  addToApi('Ein.P.Erzeuger','');
  addToApi('Ein.P.MEH.Preis','');
  addToApi('Ein.P.Menge','');
  addToApi('Ein.P.MEH','');
  addToApi('Ein.P.Projektnummer','');
  addToApi('Ein.P.Kostenstelle','');
  addToApi('Ein.P.AB.Nummer','');
  addToApi('Ein.P.AbmessString','');
  addToApi('Ein.P.Loeschmarker','');
  addToApi('Ein.P.Aktionsmarker','');
  addToApi('Ein.P.Eingangsmarker','');
  addToApi('Ein.P.FM.VSB','');
  addToApi('Ein.P.FM.Eingang','');
  addToApi('Ein.P.FM.Ausfall','');
  addToApi('Ein.P.FM.Rest','');
  addToApi('Ein.P.Materialnr','');
  addToApi('Ein.P.FM.VSB.Stk','');
  addToApi('Ein.P.FM.Eingang.Stk','');
  addToApi('Ein.P.FM.Ausfall.Stk','');
  addToApi('Ein.P.FM.Rest.Stk','');
  addToApi('Ein.P.Wgr.Dateinr','');
  addToApi('Ein.P.Streckgrenze1','');
  addToApi('Ein.P.Streckgrenze2','');
  addToApi('Ein.P.Zugfestigkeit1','');
  addToApi('Ein.P.Zugfestigkeit2','');
  addToApi('Ein.P.DehnungA1','');
  addToApi('Ein.P.DehnungA2','');
  addToApi('Ein.P.DehnungB1','');
  addToApi('Ein.P.DehnungB2','');
  addToApi('Ein.P.DehngrenzeA1','');
  addToApi('Ein.P.DehngrenzeA2','');
  addToApi('Ein.P.DehngrenzeB1','');
  addToApi('Ein.P.DehngrenzeB2','');
  addToApi('Ein.P.Koernung1','');
  addToApi('Ein.P.Koernung2','');
  addToApi('Ein.P.Chemie.C1','');
  addToApi('Ein.P.Chemie.C2','');
  addToApi('Ein.P.Chemie.Si1','');
  addToApi('Ein.P.Chemie.Si2','');
  addToApi('Ein.P.Chemie.Mn1','');
  addToApi('Ein.P.Chemie.Mn2','');
  addToApi('Ein.P.Chemie.P1','');
  addToApi('Ein.P.Chemie.P2','');
  addToApi('Ein.P.Chemie.S1','');
  addToApi('Ein.P.Chemie.S2','');
  addToApi('Ein.P.Chemie.Al1','');
  addToApi('Ein.P.Chemie.Al2','');
  addToApi('Ein.P.Chemie.Cr1','');
  addToApi('Ein.P.Chemie.Cr2','');
  addToApi('Ein.P.Chemie.V1','');
  addToApi('Ein.P.Chemie.V2','');
  addToApi('Ein.P.Chemie.Nb1','');
  addToApi('Ein.P.Chemie.Nb2','');
  addToApi('Ein.P.Chemie.Ti1','');
  addToApi('Ein.P.Chemie.Ti2','');
  addToApi('Ein.P.Chemie.N1','');
  addToApi('Ein.P.Chemie.N2','');
  addToApi('Ein.P.Chemie.Cu1','');
  addToApi('Ein.P.Chemie.Cu2','');
  addToApi('Ein.P.Chemie.Ni1','');
  addToApi('Ein.P.Chemie.Ni2','');
  addToApi('Ein.P.Chemie.Mo1','');
  addToApi('Ein.P.Chemie.Mo2','');
  addToApi('Ein.P.Chemie.B1','');
  addToApi('Ein.P.Chemie.B2','');
  addToApi('Ein.P.Haerte1','');
  addToApi('Ein.P.Haerte2','');
  addToApi('Ein.P.Chemie.Frei1.1','');
  addToApi('Ein.P.Chemie.Frei1.2','');
  addToApi('Ein.P.Mech.Sonstig1','');
  addToApi('Ein.P.RauigkeitA1','');
  addToApi('Ein.P.RauigkeitA2','');
  addToApi('Ein.P.RauigkeitB1','');
  addToApi('Ein.P.RauigkeitB2','');
  addToApi('Ein.P.AbbindungL','');
  addToApi('Ein.P.AbbindungQ','');
  addToApi('Ein.P.Zwischenlage','');
  addToApi('Ein.P.Unterlage','');
  addToApi('Ein.P.StehendYN','');
  addToApi('Ein.P.LiegendYN','');
  addToApi('Ein.P.Nettoabzug','');
  addToApi('Ein.P.Stapelhoehe','');
  addToApi('Ein.P.StapelhAbzug','');
  addToApi('Ein.P.RingkgVon','');
  addToApi('Ein.P.RingkgBis','');
  addToApi('Ein.P.kgmmVon','');
  addToApi('Ein.P.kgmmBis','');
  addToApi('Ein.P.StueckVE','');
  addToApi('Ein.P.VEkgmax','');
  addToApi('Ein.P.RechtwinkMax','');
  addToApi('Ein.P.EbenheitMax','');
  addToApi('Ein.P.SaebeligkeitMax','');
  addToApi('Ein.P.Etikettentyp','');
  addToApi('Ein.P.Verwiegungsart','');
  addToApi('Ein.P.VpgText1','');
  addToApi('Ein.P.VpgText2','');
  addToApi('Ein.P.VpgText3','');
  addToApi('Ein.P.VpgText4','');
  addToApi('Ein.P.VpgText5','');
  addToApi('Ein.P.Skizzennummer','');
  addToApi('Ein.P.Verpacknr','');
  addToApi('Ein.P.VpgText6','');
  addToApi('Ein.P.VerpackAdrNr','');
  addToApi('Ein.P.Umverpackung','');
  addToApi('Ein.P.Wicklung','');
  addToApi('Ein.P.FE.Dicke','');
  addToApi('Ein.P.FE.Breite','');
  addToApi('Ein.P.FE.Laenge','');
  addToApi('Ein.P.FE.Dickentol','');
  addToApi('Ein.P.FE.Breitentol','');
  addToApi('Ein.P.FE.Laengentol','');
  addToApi('Ein.P.FE.RID','');
  addToApi('Ein.P.FE.RIDMax','');
  addToApi('Ein.P.FE.RAD','');
  addToApi('Ein.P.FE.RADMax','');
  addToApi('Ein.P.FE.Gewicht','');
  addToApi('Ein.P.Anlage.Datum','');
  addToApi('Ein.P.Anlage.Zeit','');
  addToApi('Ein.P.Anlage.User','');
  addToApi('Ein.P.Loesch.Datum','');
  addToApi('Ein.P.Loesch.Zeit','');
  addToApi('Ein.P.Loesch.User','');
  addToApi('Ein.P.Cust.Sort','');

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

  vFelderGrp    # aArgs->getValue('FELDER');

  // --------------------------------------------------------------------------
  // Datensatz lesen
  RecBufClear(c_DATEI);
  Ein.P.Nummer      # vEinNr;
  Ein.P.Position    # vEinPos;
  if (RecRead(c_DATEI,1,0) <> _rOK) then begin
      // nicht gefunden
      aResponse->addErrNode(errSVL_Allgemein,'Bestellposition nicht gefunden');
      RETURN errPrevent;
  end;

  // Betellpos. ist ab hier erfolgreich gelesen

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

          // Inkompatible Feldnamen für Export korrigieren
          CASE (vFldName) OF
            'Ein.P.Stück\VE'  : vFldName # 'Ein.P.StückVE';
          END

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
        if (StrCut(vFldName,1,6) = 'EIN.P.') then begin

          if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

            // Felder mit Umlauten mappen
            CASE (toUpper(vFldName)) OF
              'EIN.P.GUETE'           : vFldName #  'Ein.P.Güte';
              'EIN.P.GUETENSTUFE'     : vFldName #  'Ein.P.Gütenstufe';
              'EIN.P.LAENGE'          : vFldName #  'Ein.P.Länge';
              'EIN.P.LAENGENTOL'      : vFldName #  'Ein.P.Längentol';
              'EIN.P.STUECKZAHL'      : vFldName #  'Ein.P.Stückzahl';
              'EIN.P.LOESCHMARKER'    : vFldName #  'Ein.P.Löschmarker';
              'EIN.P.KOERNUNG1'       : vFldName #  'Ein.P.Körnung1';
              'EIN.P.KOERNUNG2'       : vFldName #  'Ein.P.Körnung2';
              'EIN.P.HAERTE1'         : vFldName #  'Ein.P.Härte1';
              'EIN.P.HAERTE2'         : vFldName #  'Ein.P.Härte2';
              'EIN.P.STAHPELHOEHE'    : vFldName #  'Ein.P.Stapelhöhe';
              'EIN.P.STUECKVE'        : vFldName #  'Ein.P.Stück\VE';
              'EIN.P.SAEBELIGKEITMAX' : vFldName #  'Ein.P.SäbeligkeitMax';
              'EIN.P.SAEBELPROM'      : vFldName #  'EIN.P.SäbelProM';
              'EIN.P.FE.LAENGE'       : vFldName #  'Ein.P.FE.Länge';
              'EIN.P.FE.LAENGENTOL'   : vFldName #  'Ein.P.FE.Längentol';
              'EIN.P.LOESCH.DATUM'    : vFldName #  'Ein.P.Lösch.Datum';
              'EIN.P.LOESCH.ZEIT'     : vFldName #  'Ein.P.Lösch.Zeit';
              'EIN.P.LOESCH.USER'     : vFldName #  'Ein.P.Lösch.User';
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
