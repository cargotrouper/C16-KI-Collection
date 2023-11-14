@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000015
//                  OHNE E_R_G
//  Zu Service: AUF_POS_REPLACE
//
//  Info
///   Updated Auftragspositionsdaten und gibt das Ergebnis zurück
//
//
//  15.02.2011  ST  Erstellung der Prozedur
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
  vNode->apiSetDesc('Eindeutige Auftragsnummer der Auftragsposition','123045');

  // Auftragsposition
  vNode # vApi->apiAdd('POSITION',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Positionsnummer der Auftragspositions','1');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Haupdaten
  addToApi('Auf.P.Nummer',    _TypeInt);
  addToApi('Auf.P.Position',  _TypeInt);
  addToApi('Auf.P.Kundennr',  _TypeInt);
  addToApi('Auf.P.KundenSW',  _TypeAlpha);
  addToApi('Auf.P.Best.Nummer',_TypeAlpha);
  addToApi('Auf.P.Auftragsart',_TypeInt);
  addToApi('Auf.P.AbrufAufNr',_TypeInt);
  addToApi('Auf.P.AbrufAufPos',_TypeInt);
  addToApi('Auf.P.Warengruppe',_TypeInt);
  addToApi('Auf.P.ArtikelID',_TypeInt);
  addToApi('Auf.P.Artikelnr',_TypeAlpha);
  addToApi('Auf.P.ArtikelSW',_TypeAlpha);
  addToApi('Auf.P.KundenArtNr',_TypeAlpha);
  addToApi('Auf.P.Sachnummer',_TypeAlpha);
  addToApi('Auf.P.Katalognr',_TypeAlpha);
  addToApi('Auf.P.AusfOben',_TypeAlpha);
  addToApi('Auf.P.AusfUnten',_TypeAlpha);
  addToApi('Auf.P.Guete',_TypeAlpha);
  addToApi('Auf.P.Guetenstufe',_TypeAlpha);
  addToApi('Auf.P.Werkstoffnr',_TypeAlpha);
  addToApi('Auf.P.Intrastatnr',_TypeAlpha);
  addToApi('Auf.P.Strukturnr',_TypeAlpha);
  addToApi('Auf.P.TextNr1',_TypeInt);
  addToApi('Auf.P.TextNr2',_TypeInt);
  addToApi('Auf.P.Dicke',_TypeFloat);
  addToApi('Auf.P.Breite',_TypeFloat);
  addToApi('Auf.P.Laenge',_TypeFloat);
  addToApi('Auf.P.Dickentol',_TypeAlpha);
  addToApi('Auf.P.Breitentol',_TypeAlpha);
  addToApi('Auf.P.Laengentol',_TypeAlpha);
  addToApi('Auf.P.Zeugnisart',_TypeAlpha);
  addToApi('Auf.P.RID',_TypeFloat);
  addToApi('Auf.P.RIDMax',_TypeFloat);
  addToApi('Auf.P.RAD',_TypeFloat);
  addToApi('Auf.P.RADMax',_TypeFloat);
  addToApi('Auf.P.Stueckzahl',_TypeInt);
  addToApi('Auf.P.Gewicht',_TypeFloat);
  addToApi('Auf.P.Menge.Wunsch',_TypeFloat);
  addToApi('Auf.P.MEH.Wunsch',_TypeAlpha);
  addToApi('Auf.P.PEH',_TypeInt);
  addToApi('Auf.P.MEH.Preis',_TypeAlpha);
  addToApi('Auf.P.Grundpreis',_TypeFloat);
  addToApi('Auf.P.AufpreisYN',_TypeBool);
  addToApi('Auf.P.Aufpreis',_TypeFloat);
  addToApi('Auf.P.Einzelpreis',_TypeFloat);
  addToApi('Auf.P.Gesamtpreis',_TypeFloat);
  addToApi('Auf.P.Kalkuliert',_TypeFloat);
  addToApi('Auf.P.Termin1W.Art',_TypeAlpha);
  addToApi('Auf.P.Termin1W.Zahl',_TypeInt);
  addToApi('Auf.P.Termin1W.Jahr',_TypeInt);
  addToApi('Auf.P.Termin1Wunsch',_Typedate);
  addToApi('Auf.P.Termin2W.Zahl',_TypeInt);
  addToApi('Auf.P.Termin2W.Jahr',_TypeInt);
  addToApi('Auf.P.Termin2Wunsch',_TypeDate);
  addToApi('Auf.P.TerminZ.Zahl',_TypeInt);
  addToApi('Auf.P.TerminZ.Jahr',_TypeInt);
  addToApi('Auf.P.TerminZusage',_TypeDate);
  addToApi('Auf.P.Bemerkung',_TypeAlpha);
  addToApi('Auf.P.Erzeuger',_TypeInt);
  addToApi('Auf.P.Menge',_TypeFloat);
  addToApi('Auf.P.MEH.Einsatz',_TypeAlpha);
  addToApi('Auf.P.Projektnummer',_TypeInt);
  addToApi('Auf.P.Termin.Zusatz',_TypeAlpha);
  addToApi('Auf.P.Vertr1.Prov',_TypeFloat);
  addToApi('Auf.P.Vertr2.Prov',_TypeFloat);
  addToApi('Auf.P.AbmessString',_TypeAlpha);

  // Internes
  addToApi('Auf.P.Loeschmarker',_TypeAlpha);
  addToApi('Auf.P.Aktionsmarker',_TypeAlpha);
  addToApi('Auf.P.Wgr.Dateinr',_TypeInt);
  addToApi('Auf.P.Artikeltyp',_TypeAlpha);
  addToApi('Auf.P.Materialnr',_TypeInt);
  addToApi('Auf.P.GesamtwertEKW1',_TypeFloat);
  addToApi('Auf.P.Prd.Plan',_TypeFloat);
  addToApi('Auf.P.Prd.Plan.Stk',_TypeInt);
  addToApi('Auf.P.Prd.Plan.Gew',_TypeFloat);
  addToApi('Auf.P.Prd.VSB',_TypeFloat);
  addToApi('Auf.P.Prd.VSB.Stk',_TypeInt);
  addToApi('Auf.P.Prd.VSB.Gew',_TypeFloat);
  addToApi('Auf.P.Prd.VSAuf',_TypeFloat);
  addToApi('Auf.P.Prd.VSAuf.Stk',_TypeInt);
  addToApi('Auf.P.Prd.VSAuf.Gew',_TypeFloat);
  addToApi('Auf.P.Prd.LFS',_TypeFloat);
  addToApi('Auf.P.Prd.LFS.Stk',_TypeInt);
  addToApi('Auf.P.Prd.LFS.Gew',_TypeFloat);
  addToApi('Auf.P.Prd.Rech',_TypeFloat);
  addToApi('Auf.P.Prd.Rech.Stk',_TypeInt);
  addToApi('Auf.P.Prd.Rech.Gew',_TypeFloat);
  addToApi('Auf.P.Prd.Rest',_TypeFloat);
  addToApi('Auf.P.Prd.Rest.Stk',_TypeInt);
  addToApi('Auf.P.Prd.Rest.Gew',_TypeFloat);
  addToApi('Auf.P.GPl.Plan',_TypeFloat);
  addToApi('Auf.P.GPl.Plan.Stk',_TypeInt);
  addToApi('Auf.P.GPl.Plan.Gew',_TypeFloat);
  addToApi('Auf.P.Prd.Reserv',_TypeFloat);
  addToApi('Auf.P.Prd.Reserv.Stk',_TypeInt);
  addToApi('Auf.P.Prd.Reserv.Gew',_TypeFloat);
  addToApi('Auf.P.Prd.zuBere',_TypeFloat);
  addToApi('Auf.P.Prd.zuBere.Stk',_TypeInt);
  addToApi('Auf.P.Prd.zuBere.Gew',_TypeFloat);

  // Analyse
  addToApi('Auf.P.Streckgrenze1',_TypeFloat);
  addToApi('Auf.P.Streckgrenze2',_TypeFloat);
  addToApi('Auf.P.Zugfestigkeit1',_TypeFloat);
  addToApi('Auf.P.Zugfestigkeit2',_TypeFloat);
  addToApi('Auf.P.DehnungA1',_TypeFloat);
  addToApi('Auf.P.DehnungA2',_TypeFloat);
  addToApi('Auf.P.DehnungB1',_TypeFloat);
  addToApi('Auf.P.DehnungB2',_TypeFloat);
  addToApi('Auf.P.DehngrenzeA1',_TypeFloat);
  addToApi('Auf.P.DehngrenzeA2',_TypeFloat);
  addToApi('Auf.P.DehngrenzeB1',_TypeFloat);
  addToApi('Auf.P.DehngrenzeB2',_TypeFloat);
  addToApi('Auf.P.Koernung1',_TypeFloat);
  addToApi('Auf.P.Koernung2',_TypeFloat);
  addToApi('Auf.P.Chemie.C1',_TypeFloat);
  addToApi('Auf.P.Chemie.C2',_TypeFloat);
  addToApi('Auf.P.Chemie.Si1',_TypeFloat);
  addToApi('Auf.P.Chemie.Si2',_TypeFloat);
  addToApi('Auf.P.Chemie.Mn1',_TypeFloat);
  addToApi('Auf.P.Chemie.Mn2',_TypeFloat);
  addToApi('Auf.P.Chemie.P1',_TypeFloat);
  addToApi('Auf.P.Chemie.P2',_TypeFloat);
  addToApi('Auf.P.Chemie.S1',_TypeFloat);
  addToApi('Auf.P.Chemie.S2',_TypeFloat);
  addToApi('Auf.P.Chemie.Al1',_TypeFloat);
  addToApi('Auf.P.Chemie.Al2',_TypeFloat);
  addToApi('Auf.P.Chemie.Cr1',_TypeFloat);
  addToApi('Auf.P.Chemie.Cr2',_TypeFloat);
  addToApi('Auf.P.Chemie.V1',_TypeFloat);
  addToApi('Auf.P.Chemie.V2',_TypeFloat);
  addToApi('Auf.P.Chemie.Nb1',_TypeFloat);
  addToApi('Auf.P.Chemie.Nb2',_TypeFloat);
  addToApi('Auf.P.Chemie.Ti1',_TypeFloat);
  addToApi('Auf.P.Chemie.Ti2',_TypeFloat);
  addToApi('Auf.P.Chemie.N1',_TypeFloat);
  addToApi('Auf.P.Chemie.N2',_TypeFloat);
  addToApi('Auf.P.Chemie.Cu1',_TypeFloat);
  addToApi('Auf.P.Chemie.Cu2',_TypeFloat);
  addToApi('Auf.P.Chemie.Ni1',_TypeFloat);
  addToApi('Auf.P.Chemie.Ni2',_TypeFloat);
  addToApi('Auf.P.Chemie.Mo1',_TypeFloat);
  addToApi('Auf.P.Chemie.Mo2',_TypeFloat);
  addToApi('Auf.P.Chemie.B1',_TypeFloat);
  addToApi('Auf.P.Chemie.B2',_TypeFloat);
  addToApi('Auf.P.Haerte1',_TypeFloat);
  addToApi('Auf.P.Haerte2',_TypeFloat);
  addToApi('Auf.P.Chemie.Frei1.1',_TypeFloat);
  addToApi('Auf.P.Chemie.Frei1.2',_TypeFloat);
  addToApi('Auf.P.Mech.Sonstig1',_TypeAlpha);
  addToApi('Auf.P.RauigkeitA1',_TypeFloat);
  addToApi('Auf.P.RauigkeitA2',_TypeFloat);
  addToApi('Auf.P.RauigkeitB1',_TypeFloat);
  addToApi('Auf.P.RauigkeitB2',_TypeFloat);

  // Verpackung
  addToApi('Auf.P.AbbindungL',_TypeInt);
  addToApi('Auf.P.AbbindungQ',_TypeInt);
  addToApi('Auf.P.Zwischenlage',_TypeAlpha);
  addToApi('Auf.P.Unterlage',_TypeAlpha);
  addToApi('Auf.P.StehendYN',_TypeBool);
  addToApi('Auf.P.LiegendYN',_TypeBool);
  addToApi('Auf.P.Nettoabzug',_TypeFloat);
  addToApi('Auf.P.Stapelhoehe',_TypeFloat);
  addToApi('Auf.P.StapelhAbzug',_TypeFloat);
  addToApi('Auf.P.RingKgVon',_TypeFloat);
  addToApi('Auf.P.RingKgBis',_TypeFloat);
  addToApi('Auf.P.KgmmVon',_TypeFloat);
  addToApi('Auf.P.KgmmBis',_TypeFloat);
  addToApi('Auf.P.StueckVE',_TypeInt);
  addToApi('Auf.P.VEkgMax',_TypeFloat);
  addToApi('Auf.P.RechtwinkMax',_TypeFloat);
  addToApi('Auf.P.EbenheitMax',_TypeFloat);
  addToApi('Auf.P.SaebeligkeitMax',_TypeFloat);
  addToApi('Auf.P.Etikettentyp',_TypeInt);
  addToApi('Auf.P.Verwiegungsart',_TypeInt);
  addToApi('Auf.P.VpgText1',_TypeAlpha);
  addToApi('Auf.P.VpgText2',_TypeAlpha);
  addToApi('Auf.P.VpgText3',_TypeAlpha);
  addToApi('Auf.P.VpgText4',_TypeAlpha);
  addToApi('Auf.P.VpgText5',_TypeAlpha);
  addToApi('Auf.P.Skizzennummer',_TypeInt);
  addToApi('Auf.P.Verpacknr',_TypeInt);
  addToApi('Auf.P.Etk.Guete',_TypeAlpha);
  addToApi('Auf.P.Etk.Dicke',_TypeFloat);
  addToApi('Auf.P.Etk.Breite',_TypeFloat);
  addToApi('Auf.P.Etk.Laenge',_TypeFloat);
  addToApi('Auf.P.Etk.Feld.1',_TypeAlpha);
  addToApi('Auf.P.Etk.Feld.2',_TypeAlpha);
  addToApi('Auf.P.Etk.Feld.3',_TypeAlpha);
  addToApi('Auf.P.Etk.Feld.4',_TypeAlpha);
  addToApi('Auf.P.Etk.Feld.5',_TypeAlpha);
  addToApi('Auf.P.VerpackAdrNr',_TypeInt);
  addToApi('Auf.P.VpgText6',_TypeAlpha);
  addToApi('Auf.P.Umverpackung',_TypeAlpha);
  addToApi('Auf.P.Wicklung',_TypeAlpha);

  // Fremdeinheiten
  addToApi('Auf.P.FE.Dicke',_TypeFloat);
  addToApi('Auf.P.FE.Breite',_TypeFloat);
  addToApi('Auf.P.FE.Laenge',_TypeFloat);
  addToApi('Auf.P.FE.Dickentol',_TypeAlpha);
  addToApi('Auf.P.FE.Breitentol',_TypeAlpha);
  addToApi('Auf.P.FE.Laengentol',_TypeAlpha);
  addToApi('Auf.P.FE.RID',_TypeFloat);
  addToApi('Auf.P.FE.RIDMax',_TypeFloat);
  addToApi('Auf.P.FE.RAD',_TypeFloat);
  addToApi('Auf.P.FE.RADMax',_TypeFloat);
  addToApi('Auf.P.FE.Gewicht',_TypeFloat);

  // Protokoll
  addToApi('Auf.P.Anlage.Datum',_TypeDate);
  addToApi('Auf.P.Anlage.Zeit',_TypeTime);
  addToApi('Auf.P.Anlage.User',_TypeAlpha);
  addToApi('Auf.P.Loesch.Datum',_TypeDate);
  addToApi('Auf.P.Loesch.Zeit',_TypeTime);
  addToApi('Auf.P.Loesch.User',_TypeAlpha);
  addToApi('Auf.P.Workflow',_TypeInt);

  // Custom
  addToApi('Auf.P.Cust.Sort',_TypeAlpha);




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
  vAufNr      : int;
  vAufPos      : int;

  vFelderGrp  : alpha;

  // Rückgabedaten
  vAufPNode    : handle;     // Handle für Materialnode

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
  vAufNr        # CnvIA(aArgs->getValue('NUMMER'));
  vAufPos       # CnvIA(aArgs->getValue('POSITION'));


  // --------------------------------------------------------------------------
  // Auftragsposition lesen
  RecBufClear(401);
  Auf.P.Nummer # vAufNr;
  Auf.P.Position # vAufPos;
  if (RecRead(401,1,0) <> _rOK) then begin
    // Auftragspos nicht im Bestand gefunden
    RecBufClear(401);
    RecBufClear(411);
    "Auf~P.Nummer" # vAufNr;
    "Auf~P.Position" # vAufPos;
    if (RecRead(411,1,0) <> _rOK) then begin
      // Auftragsposition nicht vorhanden
      aResponse->addErrNode(errSVL_Allgemein,'Auftragsposition unbekannt');
      RETURN errPrevent;
    end else begin
      // Auftragsposition in Ablage
      aResponse->addErrNode(errSVL_Allgemein,'Auftragsposition ist bereits in Ablage');
      RETURN errPrevent;
    end;
  end;

  // Auftragspos sperren
  if (RecRead(401,1,_RecLock) <> _rOK) then begin
      // Auftragspos nicht sperrbar
      aResponse->addErrNode(errSVL_Allgemein,'Auftragsposition konnte nicht gesperrt werden');
      RETURN errPrevent;
  end;



  // --------------------------------------------------------------------------
  // Daten schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vAufPNode # vNode->addRecord(401);

  vErr # 0;

  // Argumente durchsuchen und nach gewünschten Feldnamen suchen
  FOR  vNode # aArgs->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aArgs->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin

    vFldName # toUpper(vNode->spName);
    if (StrCut(vFldName,1,6) = 'AUF.P.') then begin

      vVal # aArgs->getValue(vFldName);

      if (vVal <> '') then begin

       // Felder mit Umlauten mappen
        CASE (toUpper(vFldName)) OF
          'AUF.P.GUETE'           : vFldName #  'Auf.P.Güte';
          'AUF.P.GUETENSTUFE'     : vFldName #  'Auf.P.Gütenstufe';
          'AUF.P.LAENGE'          : vFldName #  'Auf.P.Länge';
          'AUF.P.LAENGENTOL'      : vFldName #  'Auf.P.Längentol';
          'AUF.P.STUECKZAHL'      : vFldName #  'Auf.P.Stückzahl';
          'AUF.P.LOESCHMARKER'    : vFldName #  'Auf.P.Löschmarker';
          'AUF.P.KOERNUNG1'       : vFldName #  'Auf.P.Körnung1';
          'AUF.P.KOERNUNG2'       : vFldName #  'Auf.P.Körnung2';
          'AUF.P.HAERTE1'         : vFldName #  'Auf.P.Härte1';
          'AUF.P.HAERTE2'         : vFldName #  'Auf.P.Härte2';
          'AUF.P.STAHPELHOEHE'    : vFldName #  'Auf.P.Stapelhöhe';
          'AUF.P.STUECKVE'        : vFldName #  'Auf.P.Stück\VE';
          'Auf.P.SAEBELIGKEITMAX' : vFldName #  'Auf.P.SäbeligkeitMax';
          'Auf.P.SAEBELPROM'      : vFldName #  'Auf.P.SäbelProM';
          'Auf.P.ETK.GUETE'       : vFldName #  'Auf.P.Etk.Güte';
          'Auf.P.ETK.LAENGE'      : vFldName #  'Auf.P.Etk.Länge';
          'Auf.P.FE.LAENGE'       : vFldName #  'Auf.P.FE.Länge';
          'Auf.P.FE.LAENGENTOL'   : vFldName #  'Auf.P.FE.Längentol';
          'Auf.P.LOESCH.DATUM'    : vFldName #  'Auf.P.Lösch.Datum';
          'Auf.P.LOESCH.ZEIT'     : vFldName #  'Auf.P.Lösch.Zeit';
          'Auf.P.LOESCH.USER'     : vFldName #  'Auf.P.Lösch.User';
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
  if (Auf_Data:PosReplace(_recUnlock,'SOA') <> _rOK) then begin
      // Aufpos nicht speicherbar
      aResponse->addErrNode(errSVL_Allgemein,'Auftragsposition konnte nicht gespeichert werden');
      inc(vErr);
  end;

  if (vErr <> 0) then begin
    RETURN errPrevent;
  end;


  vAufPNode->Lib_XML:AppendNode('Ergebnis', 'OK');

  // Daten des Services sind angehängt
  return _rOk;

End; // sub exec(...) : int



//=========================================================================
//=========================================================================
//=========================================================================