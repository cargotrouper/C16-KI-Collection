@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000022
//                  OHNE E_R_G
//  Zu Service: EIN_POS_REPLACE
//
//  Info
///   Updated Bestellpositionsdaten und gibt das Ergebnis zurück
//
//
//  16.02.2011  ST  Erstellung der Prozedur
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
  vNode->apiSetDesc('Eindeutige Bestellnummer der Bestellposition','123045');

  // Auftragsposition
  vNode # vApi->apiAdd('POSITION',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Bestellnummer der Bestellposition','1');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Haupdaten
  addToApi('Ein.P.Nummer',_TypeInt);
  addToApi('Ein.P.Position',_TypeInt);
  addToApi('Ein.P.Lieferantennr',_TypeInt);
  addToApi('Ein.P.LieferantenSW',_TypeAlpha);
  addToApi('Ein.P.Auftragsart',_TypeInt);
  addToApi('Ein.P.AbrufAufNr',_TypeInt);
  addToApi('Ein.P.AbrufAufPos',_TypeInt);
  addToApi('Ein.P.Warengruppe',_TypeInt);
  addToApi('Ein.P.ArtikelID',_TypeInt);
  addToApi('Ein.P.Artikelnr',_TypeAlpha);
  addToApi('Ein.P.ArtikelSW',_TypeAlpha);
  addToApi('Ein.P.LieferArtNr',_TypeAlpha);
  addToApi('Ein.P.Sachnummer',_TypeAlpha);
  addToApi('Ein.P.Katalognr',_TypeAlpha);
  addToApi('Ein.P.AusfOben',_TypeAlpha);
  addToApi('Ein.P.AusfUnten',_TypeAlpha);
  addToApi('Ein.P.Guete',_TypeAlpha);
  addToApi('Ein.P.Guetenstufe',_TypeAlpha);
  addToApi('Ein.P.Werkstoffnr',_TypeAlpha);
  addToApi('Ein.P.Intrastatnr',_TypeAlpha);
  addToApi('Ein.P.Strukturnr',_TypeAlpha);
  addToApi('Ein.P.TextNr1',_TypeInt);
  addToApi('Ein.P.TextNr2',_TypeInt);
  addToApi('Ein.P.Dicke',_TypeFloat);
  addToApi('Ein.P.Breite',_TypeFloat);
  addToApi('Ein.P.Laenge',_TypeFloat);
  addToApi('Ein.P.Dickentol',_TypeAlpha);
  addToApi('Ein.P.Breitentol',_TypeAlpha);
  addToApi('Ein.P.Laengentol',_TypeAlpha);
  addToApi('Ein.P.Zeugnisart',_TypeAlpha);
  addToApi('Ein.P.Kommission',_TypeAlpha);
  addToApi('Ein.P.KommissionNr',_TypeInt);
  addToApi('Ein.P.KommissionPos',_TypeInt);
  addToApi('Ein.P.KommiKunde',_TypeInt);
  addToApi('Ein.P.RID',_TypeFloat);
  addToApi('Ein.P.RIDMax',_TypeFloat);
  addToApi('Ein.P.RAD',_TypeFloat);
  addToApi('Ein.P.RADMax',_TypeFloat);
  addToApi('Ein.P.Stueckzahl',_TypeInt);
  addToApi('Ein.P.Gewicht',_TypeFloat);
  addToApi('Ein.P.Menge.Wunsch',_TypeFloat);
  addToApi('Ein.P.MEH.Wunsch',_TypeAlpha);
  addToApi('Ein.P.PEH',_TypeInt);
  addToApi('Ein.P.Grundpreis',_TypeFloat);
  addToApi('Ein.P.AufpreisYN',_TypeBool);
  addToApi('Ein.P.Aufpreis',_TypeFloat);
  addToApi('Ein.P.Einzelpreis',_TypeFloat);
  addToApi('Ein.P.Gesamtpreis',_TypeFloat);
  addToApi('Ein.P.Kalkuliert',_TypeFloat);
  addToApi('Ein.P.Termin1W.Art',_TypeAlpha);
  addToApi('Ein.P.Termin1W.Zahl',_TypeInt);
  addToApi('Ein.P.Termin1W.Jahr',_TypeInt);
  addToApi('Ein.P.Termin1Wunsch',_TypeDate);
  addToApi('Ein.P.Termin2W.Zahl',_TypeInt);
  addToApi('Ein.P.Termin2W.Jahr',_TypeInt);
  addToApi('Ein.P.Termin2Wunsch',_TypeDate);
  addToApi('Ein.P.TerminZ.Zahl',_TypeInt);
  addToApi('Ein.P.TerminZ.Jahr',_TypeInt);
  addToApi('Ein.P.TerminZusage',_TypeDate);
  addToApi('Ein.P.Bemerkung',_TypeAlpha);
  addToApi('Ein.P.Erzeuger',_TypeInt);
  addToApi('Ein.P.MEH.Preis',_TypeAlpha);
  addToApi('Ein.P.Menge',_TypeFloat);
  addToApi('Ein.P.MEH',_TypeAlpha);
  addToApi('Ein.P.Projektnummer',_TypeInt);
  addToApi('Ein.P.Kostenstelle',_TypeInt)

  // Internes
  addToApi('Ein.P.AB.Nummer',_TypeAlpha);
  addToApi('Ein.P.AbmessString',_TypeAlpha);
  addToApi('Ein.P.Loeschmarker',_TypeAlpha);
  addToApi('Ein.P.Aktionsmarker',_TypeAlpha);
  addToApi('Ein.P.Eingangsmarker',_TypeAlpha);
  addToApi('Ein.P.FM.VSB',_TypeFloat);
  addToApi('Ein.P.FM.Eingang',_TypeFloat);
  addToApi('Ein.P.FM.Ausfall',_TypeFloat);
  addToApi('Ein.P.FM.Rest',_TypeFloat);
  addToApi('Ein.P.Materialnr',_TypeInt);
  addToApi('Ein.P.FM.VSB.Stk',_TypeInt);
  addToApi('Ein.P.FM.Eingang.Stk',_TypeInt);
  addToApi('Ein.P.FM.Ausfall.Stk',_TypeInt);
  addToApi('Ein.P.FM.Rest.Stk',_TypeInt);
  addToApi('Ein.P.Wgr.Dateinr',_TypeInt);

  // Analyse
  addToApi('Ein.P.Streckgrenze1',_TypeFloat);
  addToApi('Ein.P.Streckgrenze2',_TypeFloat);
  addToApi('Ein.P.Zugfestigkeit1',_TypeFloat);
  addToApi('Ein.P.Zugfestigkeit2',_TypeFloat);
  addToApi('Ein.P.DehnungA1',_TypeFloat);
  addToApi('Ein.P.DehnungA2',_TypeFloat);
  addToApi('Ein.P.DehnungB1',_TypeFloat);
  addToApi('Ein.P.DehnungB2',_TypeFloat);
  addToApi('Ein.P.DehngrenzeA1',_TypeFloat);
  addToApi('Ein.P.DehngrenzeA2',_TypeFloat);
  addToApi('Ein.P.DehngrenzeB1',_TypeFloat);
  addToApi('Ein.P.DehngrenzeB2',_TypeFloat);
  addToApi('Ein.P.Koernung1',_TypeFloat);
  addToApi('Ein.P.Koernung2',_TypeFloat);
  addToApi('Ein.P.Chemie.C1',_TypeFloat);
  addToApi('Ein.P.Chemie.C2',_TypeFloat);
  addToApi('Ein.P.Chemie.Si1',_TypeFloat);
  addToApi('Ein.P.Chemie.Si2',_TypeFloat);
  addToApi('Ein.P.Chemie.Mn1',_TypeFloat);
  addToApi('Ein.P.Chemie.Mn2',_TypeFloat);
  addToApi('Ein.P.Chemie.P1',_TypeFloat);
  addToApi('Ein.P.Chemie.P2',_TypeFloat);
  addToApi('Ein.P.Chemie.S1',_TypeFloat);
  addToApi('Ein.P.Chemie.S2',_TypeFloat);
  addToApi('Ein.P.Chemie.Al1',_TypeFloat);
  addToApi('Ein.P.Chemie.Al2',_TypeFloat);
  addToApi('Ein.P.Chemie.Cr1',_TypeFloat);
  addToApi('Ein.P.Chemie.Cr2',_TypeFloat);
  addToApi('Ein.P.Chemie.V1',_TypeFloat);
  addToApi('Ein.P.Chemie.V2',_TypeFloat);
  addToApi('Ein.P.Chemie.Nb1',_TypeFloat);
  addToApi('Ein.P.Chemie.Nb2',_TypeFloat);
  addToApi('Ein.P.Chemie.Ti1',_TypeFloat);
  addToApi('Ein.P.Chemie.Ti2',_TypeFloat);
  addToApi('Ein.P.Chemie.N1',_TypeFloat);
  addToApi('Ein.P.Chemie.N2',_TypeFloat);
  addToApi('Ein.P.Chemie.Cu1',_TypeFloat);
  addToApi('Ein.P.Chemie.Cu2',_TypeFloat);
  addToApi('Ein.P.Chemie.Ni1',_TypeFloat);
  addToApi('Ein.P.Chemie.Ni2',_TypeFloat);
  addToApi('Ein.P.Chemie.Mo1',_TypeFloat);
  addToApi('Ein.P.Chemie.Mo2',_TypeFloat);
  addToApi('Ein.P.Chemie.B1',_TypeFloat);
  addToApi('Ein.P.Chemie.B2',_TypeFloat);
  addToApi('Ein.P.Haerte1',_TypeFloat);
  addToApi('Ein.P.Haerte2',_TypeFloat);
  addToApi('Ein.P.Chemie.Frei1.1',_TypeFloat);
  addToApi('Ein.P.Chemie.Frei1.2',_TypeFloat);
  addToApi('Ein.P.Mech.Sonstig1',_TypeAlpha);
  addToApi('Ein.P.RauigkeitA1',_TypeFloat);
  addToApi('Ein.P.RauigkeitA2',_TypeFloat);
  addToApi('Ein.P.RauigkeitB1',_TypeFloat);
  addToApi('Ein.P.RauigkeitB2',_TypeFloat);

  // Verpackung
  addToApi('Ein.P.AbbindungL',_TypeInt);
  addToApi('Ein.P.AbbindungQ',_TypeInt);
  addToApi('Ein.P.Zwischenlage',_TypeAlpha);
  addToApi('Ein.P.Unterlage',_TypeAlpha);
  addToApi('Ein.P.StehendYN',_TypeBool);
  addToApi('Ein.P.LiegendYN',_TypeBool);
  addToApi('Ein.P.Nettoabzug',_TypeFloat);
  addToApi('Ein.P.Stapelhoehe',_TypeFloat);
  addToApi('Ein.P.StapelhAbzug',_TypeFloat);
  addToApi('Ein.P.RingkgVon',_TypeFloat);
  addToApi('Ein.P.RingkgBis',_TypeFloat);
  addToApi('Ein.P.kgmmVon',_TypeFloat);
  addToApi('Ein.P.kgmmBis',_TypeFloat);
  addToApi('Ein.P.StueckVE',_TypeInt);
  addToApi('Ein.P.VEkgmax',_TypeFloat);
  addToApi('Ein.P.RechtwinkMax',_TypeFloat);
  addToApi('Ein.P.EbenheitMax',_TypeFloat);
  addToApi('Ein.P.SaebeligkeitMax',_TypeFloat);
  addToApi('Ein.P.Etikettentyp',_TypeInt);
  addToApi('Ein.P.Verwiegungsart',_TypeInt);
  addToApi('Ein.P.VpgText1',_TypeAlpha);
  addToApi('Ein.P.VpgText2',_TypeAlpha);
  addToApi('Ein.P.VpgText3',_TypeAlpha);
  addToApi('Ein.P.VpgText4',_TypeAlpha);
  addToApi('Ein.P.VpgText5',_TypeAlpha);
  addToApi('Ein.P.Skizzennummer',_TypeInt);
  addToApi('Ein.P.Verpacknr',_TypeInt);
  addToApi('Ein.P.VpgText6',_TypeAlpha);
  addToApi('Ein.P.VerpackAdrNr',_TypeInt);
  addToApi('Ein.P.Umverpackung',_TypeAlpha);
  addToApi('Ein.P.Wicklung',_TypeAlpha);

  // Fremdeinheiten
  addToApi('Ein.P.FE.Dicke',_TypeFloat);
  addToApi('Ein.P.FE.Breite',_TypeFloat);
  addToApi('Ein.P.FE.Laenge',_TypeFloat);
  addToApi('Ein.P.FE.Dickentol',_TypeAlpha);
  addToApi('Ein.P.FE.Breitentol',_TypeAlpha);
  addToApi('Ein.P.FE.Laengentol',_TypeAlpha);
  addToApi('Ein.P.FE.RID',_TypeFloat);
  addToApi('Ein.P.FE.RIDMax',_TypeFloat);
  addToApi('Ein.P.FE.RAD',_TypeFloat);
  addToApi('Ein.P.FE.RADMax',_TypeFloat);
  addToApi('Ein.P.FE.Gewicht',_TypeFloat);

  // Protokoll
  addToApi('Ein.P.Anlage.Datum',_TypeDate);
  addToApi('Ein.P.Anlage.Zeit',_TypeTime);
  addToApi('Ein.P.Anlage.User',_TypeAlpha);
  addToApi('Ein.P.Loesch.Datum',_TypeDate);
  addToApi('Ein.P.Loesch.Zeit',_TypeTime);
  addToApi('Ein.P.Loesch.User',_TypeAlpha);

  // Custom
  addToApi('Ein.P.Cust.Sort',_TypeAlpha);


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
  vVal     : alpha(4096);
  vErr     : int;

end
begin

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vEinNr        # CnvIA(aArgs->getValue('NUMMER'));
  vEinPos       # CnvIA(aArgs->getValue('POSITION'));


  // --------------------------------------------------------------------------
  // Auftragsposition lesen
  RecBufClear(501);
  Ein.P.Nummer # vEinNr;
  Ein.P.Position # vEinPos;
  if (RecRead(501,1,0) <> _rOK) then begin
    // Auftragspos nicht im Bestand gefunden
    RecBufClear(501);
    RecBufClear(511);
    "Ein~P.Nummer" # vEinNr;
    "Ein~P.Position" # vEinPos;
    if (RecRead(511,1,0) <> _rOK) then begin
      // Position nicht vorhanden
      aResponse->addErrNode(errSVL_Allgemein,'Bestellposition unbekannt');
      RETURN errPrevent;
    end else begin
      // Pposition in Ablage
      aResponse->addErrNode(errSVL_Allgemein,'Bestellposition ist bereits in Ablage');
      RETURN errPrevent;
    end;
  end;

  // Auftragspos sperren
  if (RecRead(501,1,_RecLock) <> _rOK) then begin
      // Position nicht sperrbar
      aResponse->addErrNode(errSVL_Allgemein,'Bestellposition konnte nicht gesperrt werden');
      RETURN errPrevent;
  end;



  // --------------------------------------------------------------------------
  // Daten schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vResNode # vNode->addRecord(501);

  vErr # 0;

  // Argumente durchsuchen und nach gewünschten Feldnamen suchen
  FOR  vNode # aArgs->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aArgs->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin

    vFldName # toUpper(vNode->spName);
    if (StrCut(vFldName,1,6) = 'EIN.P.') then begin

      vVal # aArgs->getValue(vFldName);

      if (vVal <> '') then begin

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
  if (Ein_Data:PosReplace(_RecUnlock,'SOA') <> _rOK) then begin
      // Aufpos nicht speicherbar
      aResponse->addErrNode(errSVL_Allgemein,'Bestellposition konnte nicht gespeichert werden');
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