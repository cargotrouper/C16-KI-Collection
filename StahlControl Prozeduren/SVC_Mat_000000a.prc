@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_Mat_000000a
//                  OHNE E_R_G
//  Info
//    Stellt die ServiceAPIs und Implementierungen bereit für:
///     matinfo: Updaten von Materialdaten und Rückgabe des Ergebnisses
//
//
//  27.01.2011  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB matinfo_Api() : handle
//    SUB matinfo_Exec(aArgs : handle; var aResponse : handle) : int
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,b,false); end;

end;


//=========================================================================
// sub matrepl_Api() : handle
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
sub matrepl_Api() : handle
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
  vNode->apiSetDesc('Eindeutige Nummer der zu lesenden Materialkarte','124102');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------
  // Hauptdaten
  addToApi('Mat.Nummer'           ,_TypeInt);
  addToApi('Mat.Vorgaenger'       ,_TypeInt);
  addToApi('Mat.Urpsrung'         ,_TypeInt);
  addToApi('Mat.Warengruppe'      ,_TypeWord);
  addToApi('Mat.Guete'            ,_TypeAlpha);
  addToApi('Mat.Guetenstufe'      ,_TypeAlpha);
  addToApi('Mat.Werkstoffnr'      ,_TypeAlpha);
  addToApi('Mat.AusfuehrungOben'  ,_TypeAlpha);
  addToApi('Mat.AusfuehrungUnten' ,_TypeAlpha);
  addToApi('Mat.Coilnummer'       ,_TypeAlpha);
  addToApi('Mat.Ringnummer'       ,_TypeAlpha);
  addToApi('Mat.Chargennummer'    ,_TypeAlpha);
  addToApi('Mat.Werksnummer'      ,_TypeAlpha);
  addToApi('Mat.EigenmaterialYN'  ,_TypeLogic);
  addToApi('Mat.Uebernahmedatum'  ,_TypeDate);
  addToApi('Mat.Dicke'            ,_TypeFloat);
  addToApi('Mat.Dicke.Von'        ,_TypeFloat);
  addToApi('Mat.Dicke.Bis'        ,_TypeFloat);
  addToApi('Mat.DickenTolYN'      ,_TypeLogic);
  addToApi('Mat.DickenTol'        ,_TypeAlpha);
  addToApi('Mat.DickenTol.Von'    ,_TypeFloat);
  addToApi('Mat.DickenTol.Bis'    ,_TypeFloat);
  addToApi('Mat.Breite'           ,_TypeFloat);
  addToApi('Mat.Breite.Von'       ,_TypeFloat);
  addToApi('Mat.Breite.Bis'       ,_TypeFloat);
  addToApi('Mat.BreitenTolYN'     ,_TypeLogic);
  addToApi('Mat.BreitenTol'       ,_TypeAlpha);
  addToApi('Mat.BreitenTol.Von'   ,_TypeFloat);
  addToApi('Mat.BreitenTol.Bis'   ,_TypeFloat);
  addToApi('Mat.Laenge'           ,_TypeFloat);
  addToApi('Mat.Laenge.Von'       ,_TypeFloat);
  addToApi('Mat.Laenge.Bis'       ,_TypeFloat);
  addToApi('Mat.LaengenTolYN'     ,_TypeLogic);
  addToApi('Mat.LaengenTol'       ,_TypeAlpha);
  addToApi('Mat.LaengenTol.Von'   ,_TypeFloat);
  addToApi('Mat.LaengenTol.Bis'   ,_TypeFloat);
  addToApi('Mat.RID'              ,_TypeFloat);
  addToApi('Mat.RAD'              ,_TypeFloat);
  addToApi('Mat.Kgmm'             ,_TypeFloat);
  addToApi('Mat.Dichte'           ,_TypeFloat);
  addToApi('Mat.Strukturnr'       ,_TypeAlpha);
  addToApi('Mat.Intrastatnr'      ,_TypeAlpha);
  addToApi('Mat.Ursprungsland'    ,_TypeAlpha);
  addToApi('Mat.Zeugnisart'       ,_TypeAlpha);
  addToApi('Mat.Zeugnisakte'      ,_TypeAlpha);
  addToApi('Mat.Kommission'       ,_TypeAlpha);
  addToApi('Mat.KommKundennr'     ,_TypeInt);
  addToApi('Mat.Bestand.Stk'      ,_TypeInt);
  addToApi('Mat.Bestand.Gew'      ,_TypeFloat);
  addToApi('Mat.Bestellt.Stk'     ,_TypeInt);
  addToApi('Mat.Bestellt.Gew'     ,_TypeFloat);
  addToApi('Mat.Reserviert.Stk'   ,_TypeInt);
  addToApi('Mat.Reserviert.Gew'   ,_TypeFloat);
  addToApi('Mat.Verfuegbar.Stk'   ,_TypeInt);
  addToApi('Mat.Verfuegbar.Gew'   ,_TypeFloat);
  addToApi('Mat.Paketnr'          ,_TypeInt);
  addToApi('Mat.EK.Preis'         ,_TypeFloat);
  addToApi('Mat.Kosten'           ,_TypeFloat);
  addToApi('Mat.Status'           ,_TypeInt);
  addToApi('Mat.Bemerkung1'       ,_TypeAlpha);
  addToApi('Mat.Bemerkung2'       ,_TypeAlpha);
  addToApi('Mat.KommKundenSWort'  ,_TypeAlpha);
  addToApi('Mat.EK.Preis2'        ,_TypeFloat);

  // Bewegungsdaten
  addToApi('Mat.Bestellnummer'    ,_TypeAlpha);
  addToApi('Mat.BestellABNr'      ,_TypeAlpha);
  addToApi('Mat.Bestelldatum'     ,_TypeDate);
  addToApi('Mat.BestellTermin'    ,_TypeDate);
  addToApi('Mat.Eingangsdatum'    ,_TypeDate);
  addToApi('Mat.Ausgangsdatum'    ,_TypeDate);
  addToApi('Mat.Inventurdatum'    ,_TypeDate);
  addToApi('Mat.Erzeuger'         ,_TypeInt);
  addToApi('Mat.Lieferant'        ,_TypeInt);
  addToApi('Mat.Lageradresse'     ,_TypeInt);
  addToApi('Mat.Lageranschrift'   ,_TypeInt);
  addToApi('Mat.Lagerplatz'       ,_TypeAlpha);
  addToApi('Mat.VK.Kundennr'      ,_TypeInt);
  addToApi('Mat.VK.Rechnr'        ,_TypeInt);
  addToApi('Mat.VK.Rechdatum'     ,_TypeDate);
  addToApi('Mat.VK.Preis'         ,_TypeFloat);
  addToApi('Mat.VK.Gewicht'       ,_TypeFloat);
  addToApi('Mat.EK.RechNr'        ,_TypeInt);
  addToApi('Mat.EK.RechDatum'     ,_TypeDate);
  addToApi('Mat.LieferStichwort'  ,_TypeAlpha);
  addToApi('Mat.LagerStichwort'   ,_TypeAlpha);
  addToApi('Mat.Bilddatei'        ,_TypeAlpha);
  addToApi('Mat.Datum.Lagergeld'  ,_TypeDate);
  addToApi('Mat.Datum.Zinsen'     ,_TypeDate);
  addToApi('Mat.Datum.Erzeugt'    ,_TypeDate);

  // Internes
  addToApi('Mat.Loeschmarker'     ,_TypeAlpha);
  addToApi('Mat.Auftragsnr'       ,_TypeInt);
  addToApi('Mat.Auftragspos'      ,_TypeWord);
  addToApi('Mat.Einkaufsnr'       ,_TypeInt);
  addToApi('Mat.Einkaufspos'      ,_TypeWord);
  addToApi('Mat.QS.Status'        ,_TypeWord);
  addToApi('Mat.QS.Datum'         ,_TypeDate);
  addToApi('Mat.QS.Zeit'          ,_TypeTime);
  addToApi('Mat.QS.User'          ,_TypeAlpha);
  addToApi('Mat.QS.FehlerYN'      ,_TypeLogic);

  // Analyse
  addToApi('Mat.Streckgrenze1'    ,_TypeFloat);
  addToApi('Mat.Streckgrenze2'    ,_TypeFloat);
  addToApi('Mat.Zugfestigkeit1'   ,_TypeFloat);
  addToApi('Mat.Zugfestigkeit2'   ,_TypeFloat);
  addToApi('Mat.DehnungA1'        ,_TypeFloat);
  addToApi('Mat.DehnungA2'        ,_TypeFloat);
  addToApi('Mat.DehnungB1'        ,_TypeFloat);
  addToApi('Mat.DehnungB2'        ,_TypeFloat);
  addToApi('Mat.RP02_V1'          ,_TypeFloat);
  addToApi('Mat.RP02_V2'          ,_TypeFloat);
  addToApi('Mat.RP10_V1'          ,_TypeFloat);
  addToApi('Mat.RP10_V2'          ,_TypeFloat);
  addToApi('Mat.Körnung1'         ,_TypeFloat);
  addToApi('Mat.Körnung2'         ,_TypeFloat);
  addToApi('Mat.Chemie.C1'        ,_TypeFloat);
  addToApi('Mat.Chemie.C2'        ,_TypeFloat);
  addToApi('Mat.Chemie.Si1'       ,_TypeFloat);
  addToApi('Mat.Chemie.Si2'       ,_TypeFloat);
  addToApi('Mat.Chemie.Mn1'       ,_TypeFloat);
  addToApi('Mat.Chemie.Mn2'       ,_TypeFloat);
  addToApi('Mat.Chemie.P1'        ,_TypeFloat);
  addToApi('Mat.Chemie.P2'        ,_TypeFloat);
  addToApi('Mat.Chemie.S1'        ,_TypeFloat);
  addToApi('Mat.Chemie.S2'        ,_TypeFloat);
  addToApi('Mat.Chemie.Al1'       ,_TypeFloat);
  addToApi('Mat.Chemie.Al2'       ,_TypeFloat);
  addToApi('Mat.Chemie.Cr1'       ,_TypeFloat);
  addToApi('Mat.Chemie.Cr2'       ,_TypeFloat);
  addToApi('Mat.Chemie.V1'        ,_TypeFloat);
  addToApi('Mat.Chemie.V2'        ,_TypeFloat);
  addToApi('Mat.Chemie.Nb1'       ,_TypeFloat);
  addToApi('Mat.Chemie.Nb2'       ,_TypeFloat);
  addToApi('Mat.Chemie.Ti1'       ,_TypeFloat);
  addToApi('Mat.Chemie.Ti2'       ,_TypeFloat);
  addToApi('Mat.Chemie.N1'        ,_TypeFloat);
  addToApi('Mat.Chemie.N2'        ,_TypeFloat);
  addToApi('Mat.Chemie.Cu1'       ,_TypeFloat);
  addToApi('Mat.Chemie.Cu2'       ,_TypeFloat);
  addToApi('Mat.Chemie.Ni1'       ,_TypeFloat);
  addToApi('Mat.Chemie.Ni2'       ,_TypeFloat);
  addToApi('Mat.Chemie.Mo1'       ,_TypeFloat);
  addToApi('Mat.Chemie.Mo2'       ,_TypeFloat);
  addToApi('Mat.Chemie.B1'        ,_TypeFloat);
  addToApi('Mat.Chemie.B2'        ,_TypeFloat);
  addToApi('Mat.HaerteA1'         ,_TypeFloat);
  addToApi('Mat.HaerteA2'         ,_TypeFloat);
  addToApi('Mat.HaerteB1'         ,_TypeFloat);
  addToApi('Mat.HaerteB2'         ,_TypeFloat);
  addToApi('Mat.Chemie.Frei1.1'   ,_TypeFloat);
  addToApi('Mat.Chemie.Frei1.2'   ,_TypeFloat);
  addToApi('Mat.Mech.Sonstiges1'  ,_TypeAlpha);
  addToApi('Mat.Mech.Sonstiges2'  ,_TypeAlpha);
  addToApi('Mat.RauigkeitA1'      ,_TypeFloat);
  addToApi('Mat.RauigkeitA2'      ,_TypeFloat);
  addToApi('Mat.RauigkeitB1'      ,_TypeFloat);
  addToApi('Mat.RauigkeitB2'      ,_TypeFloat);
  addToApi('Mat.RauigkeitC1'      ,_TypeFloat);
  addToApi('Mat.RauigkeitC2'      ,_TypeFloat);
  addToApi('Mat.RauigkeitD1'      ,_TypeFloat);
  addToApi('Mat.RauigkeitD2'      ,_TypeFloat);
  addToApi('Mat.StreckgrenzeB1'   ,_TypeFloat);
  addToApi('Mat.StreckgrenzeB2'   ,_TypeFloat);
  addToApi('Mat.ZugfestigkeitB1'  ,_TypeFloat);
  addToApi('Mat.ZugfestigkeitB2'  ,_TypeFloat);
  addToApi('Mat.RP02_B1'          ,_TypeFloat);
  addToApi('Mat.RP02_B2'          ,_TypeFloat);
  addToApi('Mat.RP10_B1'          ,_TypeFloat);
  addToApi('Mat.RP10_B2'          ,_TypeFloat);
  addToApi('Mat.KoernungB1'       ,_TypeFloat);
  addToApi('Mat.KoernungB2'       ,_TypeFloat);

  // Sonstiges
  addToApi('Mat.Gewicht.Netto'    ,_TypeFloat);
  addToApi('Mat.Gewicht.Brutto'   ,_TypeFloat);
  addToApi('Mat.Verwiegungsart'   ,_TypeInt);
  addToApi('Mat.AbbindungL'       ,_TypeInt);
  addToApi('Mat.AbbindungQ'       ,_TypeInt);
  addToApi('Mat.Zwischenlage'     ,_TypeAlpha);
  addToApi('Mat.Unterlage'        ,_TypeAlpha);
  addToApi('Mat.StehendYN'        ,_TypeLogic);
  addToApi('Mat.LiegendYN'        ,_TypeLogic);
  addToApi('Mat.Nettoabzug'       ,_TypeFloat);
  addToApi('Mat.Stapelhoehe'      ,_TypeFloat);
  addToApi('Mat.Stapelhoehenabzug',_TypeFloat);
  addToApi('Mat.Rechtwinkligkeit' ,_TypeFloat);
  addToApi('Mat.Ebenheit'         ,_TypeFloat);
  addToApi('Mat.Saebeligkeit'     ,_TypeFloat);
  addToApi('Mat.Etk.Guete'        ,_TypeAlpha);
  addToApi('Mat.Etk.Dicke'        ,_TypeFloat);
  addToApi('Mat.Etk.Breite'       ,_TypeFloat);
  addToApi('Mat.Etk.Laenge'       ,_TypeFloat);
  addToApi('Mat.Analysenummer'    ,_TypeInt);
  addToApi('Mat.Etikettentyp'     ,_TypeWord);
  addToApi('Mat.Umverpackung'     ,_TypeAlpha);
  addToApi('Mat.Wicklung'         ,_TypeAlpha);

  // Protokoll
  addToApi('Mat.Anlage.Datum'     ,_TypeDate);
  addToApi('Mat.Anlage.Zeit'      ,_TypeTime);
  addToApi('Mat.Anlage.User'      ,_TypeAlpha);
  addToApi('Mat.Loesch.Datum'     ,_TypeDate);
  addToApi('Mat.Loesch.Zeit'      ,_TypeTime);
  addToApi('Mat.Loesch.User'      ,_TypeAlpha);
  addToApi('Mat.Loesch.Grund'     ,_TypeAlpha);

  // Custom
  addToApi('Mat.Cust.Sort'        ,_TypeAlpha);

    // ----------------------------------
  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub matrepl_Api(...) : handle


//=========================================================================
// sub matrepl_Exec(aArgs : handle; var aResponse : handle) : int
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
sub matrepl_Exec(aArgs : handle; var aResponse : handle) : int
local begin
  // Argumente zur Erstellung der Selektion
  vArgs       : handle;     // Handle für Argumentprüfungsstruktur
  vNode       : handle;     // Handle auf Datensegment der Antwort

  // Ablaufvariablen
  vErg        : int;        // Ergebnishandle
  vTmp        : alpha;

  // Argument, fachliche Seite
  vMatNr      : int;
  vFelderGrp  : alpha;

  // Rückgabedaten
  vMatNode    : handle;     // Handle für Materialnode

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
  vMatNr        # CnvIA(aArgs->getValue('NUMMER'));

  // --------------------------------------------------------------------------
  // Materialkarte lesen
  RecBufClear(200);
  Mat.Nummer # vMatNr;
  if (RecRead(200,1,0) <> _rOK) then begin
    // Materialkarte nicht im Bestand gefunden
    RecBufClear(200);
    RecBufClear(210);
    "Mat~Nummer" # vMatNr;
    if (RecRead(210,1,0) <> _rOK) then begin
      // Materialkarte nicht vorhanden
      aResponse->addErrNode(errSVL_Allgemein,'Materialnummer unbekannt');
      RETURN errPrevent;
    end else begin
      // Materialkarte nicht in Ablage
      aResponse->addErrNode(errSVL_Allgemein,'Material ist bereits in Ablage');
      RETURN errPrevent;
    end;
  end;

  // Materialkarte sperren
  if (RecRead(200,1,_RecLock) <> _rOK) then begin
      // Materialkarte nicht vorhanden
      aResponse->addErrNode(errSVL_Allgemein,'Materialkarte konnte nicht gesperrt werden');
      RETURN errPrevent;
  end;



  // --------------------------------------------------------------------------
  // Daten schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vMatNode # vNode->addRecord(200);

  vErr # 0;

  // Argumente durchsuchen und nach gewünschten Feldnamen suchen
  FOR  vNode # aArgs->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aArgs->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin

    vFldName # toUpper(vNode->spName);
    if (StrCut(vFldName,1,4) = 'MAT.') then begin

      vVal # aArgs->getValue(vFldName);

      if (vVal <> '') then begin

        // Felder mit Umlauten mappen
        CASE (toUpper(vFldName)) OF
          'MAT.VORGAENGER'        : vFldName #  'Mat.Vorgänger';     // TDS 1: Hauptdaten
          'MAT.GUETE'             : vFldName #  'Mat.Güte';
          'MAT.GUETENSTUFE'       : vFldName #  'Mat.Gütenstufe';
          'MAT.AUSFUEHRUNGOBEN'   : vFldName #  'Mat.AusführungOben';
          'MAT.AUSFUEHRUNGUNTEN'  : vFldName #  'Mat.AusführungUnten';
          'MAT.UEBERNAHMEDATUM'   : vFldName #  'Mat.Übernahmedatum';
          'MAT.LAENGE'            : vFldName #  'Mat.Länge';
          'MAT.LAENGE.VON'        : vFldName #  'Mat.Länge.Von';
          'MAT.LAENGE.BIS'        : vFldName #  'Mat.Länge.Bis';
          'MAT.LAENGENTOL.YN'     : vFldName #  'Mat.LängenTolYN';
          'MAT.LAENGENTOL'        : vFldName #  'Mat.LängenTol';
          'MAT.LAENGENTOL.VON'    : vFldName #  'Mat.LängenTol.Von';
          'MAT.LAENGENTOL.BIS'    : vFldName #  'Mat.LängenTol.Bis';
          'MAT.VERFUEGBAR.STK'    : vFldName #  'Mat.Verfügbar.Stk';
          'MAT.VERFUEGBAG.GEW'    : vFldName #  'Mat.Verfügbar.Gew';
          'MAT.LOESCHMARKER'      : vFldName #  'Mat.Löschmarker';    // TDS 3: Internes
          'MAT.KOERNUNG1'         : vFldName #  'Mat.Körnung1';       // TDS 4: Analyse
          'MAT.KOERNUNG2'         : vFldName #  'Mat.Körnung2';
          'MAT.KOERNUNGB1'        : vFldName #  'Mat.KörnungB1';
          'MAT.KOERNUNGB2'        : vFldName #  'Mat.KörnungB2';
          'MAT.HAERTEA1'          : vFldName #  'Mat.HärteA1';
          'MAT.HAERTEA2'          : vFldName #  'Mat.HärteA2';
          'MAT.HAERTEB1'          : vFldName #  'Mat.HärteB1';
          'MAT.HAERTEB2'          : vFldName #  'Mat.HärteB2';
          'MAT.STAPELHOEHE'       : vFldName #  'Mat.Stapelhöhe';     // TDS 5: Sonstiges
          'MAT.STAPELHOEHENABZUG' : vFldName #  'Mat.Stapelhöhenabzug';
          'MAT.SAEBELIGKEIT'      : vFldName #  'Mat.Säbeligkeit';
          'MAT.SAEBELPROM'        : vFldName #  'Mat.SäbelProM';
          'MAT.ETK.GUETE'         : vFldName #  'Mat.Etk.Güte';
          'MAT.ETK.LAENGE'        : vFldName #  'Mat.Etk.Länge';
          'MAT.LOESCH.DATUM'      : vFldName #  'Mat.Lösch.Datum';     // TDS 6: Protokoll
          'MAT.LOESCH.ZEIT'       : vFldName #  'Mat.Lösch.Zeit';
          'MAT.LOESCH.USER'       : vFldName #  'Mat.Lösch.User';
          'MAT.LOESCH.GRUND'      : vFldName #  'Mat.Lösch.Grund';
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

  // Materialkarte sperren
//  if (RekReplace(200,_RecUnlock,'AUTO') <> _rOK) then begin
     if (Mat_data:Replace(_recunlock,'AUTO') <> _rOK) then begin  // 26.08.2014
      // Materialkarte nicht vorhanden
      aResponse->addErrNode(errSVL_Allgemein,'Materialkarte konnte nicht gespeichert werden');
      inc(vErr);
  end;

  if (vErr <> 0) then begin
    RETURN errPrevent;
  end;


  vMatNode->Lib_XML:AppendNode('Ergebnis', 'OK');

  // Daten des Services sind angehängt
  return _rOk;

End; // sub matinfo_Exec(...) : int



//=========================================================================
//=========================================================================
//=========================================================================