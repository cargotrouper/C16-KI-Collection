@A
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000013
//                  OHNE E_R_G
//  Zu Service: AUF_POS_READ
//
//  Info
//  AUF_POST_READ: Lesen von Auftragspositonen und Rückgabe der angegeben Felder
//
//  15.02.2011  ST  Erstellung der Prozedur
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

  c_DATEI       : 401
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

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Haupdaten
  addToApi('Auf.P.Nummer','');
  addToApi('Auf.P.Position','');
  addToApi('Auf.P.Kundennr','');
  addToApi('Auf.P.KundenSW','');
  addToApi('Auf.P.Best.Nummer','');
  addToApi('Auf.P.Auftragsart','');
  addToApi('Auf.P.AbrufAufNr','');
  addToApi('Auf.P.AbrufAufPos','');
  addToApi('Auf.P.Warengruppe','');
  addToApi('Auf.P.ArtikelID','');
  addToApi('Auf.P.Artikelnr','');
  addToApi('Auf.P.ArtikelSW','');
  addToApi('Auf.P.KundenArtNr','');
  addToApi('Auf.P.Sachnummer','');
  addToApi('Auf.P.Katalognr','');
  addToApi('Auf.P.AusfOben','');
  addToApi('Auf.P.AusfUnten','');
  addToApi('Auf.P.Guete','');
  addToApi('Auf.P.Guetenstufe','');
  addToApi('Auf.P.Werkstoffnr','');
  addToApi('Auf.P.Intrastatnr','');
  addToApi('Auf.P.Strukturnr','');
  addToApi('Auf.P.TextNr1','');
  addToApi('Auf.P.TextNr2','');
  addToApi('Auf.P.Dicke','');
  addToApi('Auf.P.Breite','');
  addToApi('Auf.P.Laenge','');
  addToApi('Auf.P.Dickentol','');
  addToApi('Auf.P.Breitentol','');
  addToApi('Auf.P.Laengentol','');
  addToApi('Auf.P.Zeugnisart','');
  addToApi('Auf.P.RID','');
  addToApi('Auf.P.RIDMax','');
  addToApi('Auf.P.RAD','');
  addToApi('Auf.P.RADMax','');
  addToApi('Auf.P.Stueckzahl','');
  addToApi('Auf.P.Gewicht','');
  addToApi('Auf.P.Menge.Wunsch','');
  addToApi('Auf.P.MEH.Wunsch','');
  addToApi('Auf.P.PEH','');
  addToApi('Auf.P.MEH.Preis','');
  addToApi('Auf.P.Grundpreis','');
  addToApi('Auf.P.AufpreisYN','');
  addToApi('Auf.P.Aufpreis','');
  addToApi('Auf.P.Einzelpreis','');
  addToApi('Auf.P.Gesamtpreis','');
  addToApi('Auf.P.Kalkuliert','');
  addToApi('Auf.P.Termin1W.Art','');
  addToApi('Auf.P.Termin1W.Zahl','');
  addToApi('Auf.P.Termin1W.Jahr','');
  addToApi('Auf.P.Termin1Wunsch','');
  addToApi('Auf.P.Termin2W.Zahl','');
  addToApi('Auf.P.Termin2W.Jahr','');
  addToApi('Auf.P.Termin2Wunsch','');
  addToApi('Auf.P.TerminZ.Zahl','');
  addToApi('Auf.P.TerminZ.Jahr','');
  addToApi('Auf.P.TerminZusage','');
  addToApi('Auf.P.Bemerkung','');
  addToApi('Auf.P.Erzeuger','');
  addToApi('Auf.P.Menge','');
  addToApi('Auf.P.MEH.Einsatz','');
  addToApi('Auf.P.Projektnummer','');
  addToApi('Auf.P.Termin.Zusatz','');
  addToApi('Auf.P.Vertr1.Prov','');
  addToApi('Auf.P.Vertr2.Prov','');
  addToApi('Auf.P.AbmessString','');

  // Internes
  addToApi('Auf.P.Loeschmarker','');
  addToApi('Auf.P.Aktionsmarker','');
  addToApi('Auf.P.Wgr.Dateinr','');
  addToApi('Auf.P.Artikeltyp','');
  addToApi('Auf.P.Materialnr','');
  addToApi('Auf.P.GesamtwertEKW1','');
  addToApi('Auf.P.Prd.Plan','');
  addToApi('Auf.P.Prd.Plan.Stk','');
  addToApi('Auf.P.Prd.Plan.Gew','');
  addToApi('Auf.P.Prd.VSB','');
  addToApi('Auf.P.Prd.VSB.Stk','');
  addToApi('Auf.P.Prd.VSB.Gew','');
  addToApi('Auf.P.Prd.VSAuf','');
  addToApi('Auf.P.Prd.VSAuf.Stk','');
  addToApi('Auf.P.Prd.VSAuf.Gew','');
  addToApi('Auf.P.Prd.LFS','');
  addToApi('Auf.P.Prd.LFS.Stk','');
  addToApi('Auf.P.Prd.LFS.Gew','');
  addToApi('Auf.P.Prd.Rech','');
  addToApi('Auf.P.Prd.Rech.Stk','');
  addToApi('Auf.P.Prd.Rech.Gew','');
  addToApi('Auf.P.Prd.Rest','');
  addToApi('Auf.P.Prd.Rest.Stk','');
  addToApi('Auf.P.Prd.Rest.Gew','');
  addToApi('Auf.P.GPl.Plan','');
  addToApi('Auf.P.GPl.Plan.Stk','');
  addToApi('Auf.P.GPl.Plan.Gew','');
  addToApi('Auf.P.Prd.Reserv','');
  addToApi('Auf.P.Prd.Reserv.Stk','');
  addToApi('Auf.P.Prd.Reserv.Gew','');
  addToApi('Auf.P.Prd.zuBere','');
  addToApi('Auf.P.Prd.zuBere.Stk','');
  addToApi('Auf.P.Prd.zuBere.Gew','');

  // Analyse
  addToApi('Auf.P.Streckgrenze1','');
  addToApi('Auf.P.Streckgrenze2','');
  addToApi('Auf.P.Zugfestigkeit1','');
  addToApi('Auf.P.Zugfestigkeit2','');
  addToApi('Auf.P.DehnungA1','');
  addToApi('Auf.P.DehnungA2','');
  addToApi('Auf.P.DehnungB1','');
  addToApi('Auf.P.DehnungB2','');
  addToApi('Auf.P.DehngrenzeA1','');
  addToApi('Auf.P.DehngrenzeA2','');
  addToApi('Auf.P.DehngrenzeB1','');
  addToApi('Auf.P.DehngrenzeB2','');
  addToApi('Auf.P.Koernung1','');
  addToApi('Auf.P.Koernung2','');
  addToApi('Auf.P.Chemie.C1','');
  addToApi('Auf.P.Chemie.C2','');
  addToApi('Auf.P.Chemie.Si1','');
  addToApi('Auf.P.Chemie.Si2','');
  addToApi('Auf.P.Chemie.Mn1','');
  addToApi('Auf.P.Chemie.Mn2','');
  addToApi('Auf.P.Chemie.P1','');
  addToApi('Auf.P.Chemie.P2','');
  addToApi('Auf.P.Chemie.S1','');
  addToApi('Auf.P.Chemie.S2','');
  addToApi('Auf.P.Chemie.Al1','');
  addToApi('Auf.P.Chemie.Al2','');
  addToApi('Auf.P.Chemie.Cr1','');
  addToApi('Auf.P.Chemie.Cr2','');
  addToApi('Auf.P.Chemie.V1','');
  addToApi('Auf.P.Chemie.V2','');
  addToApi('Auf.P.Chemie.Nb1','');
  addToApi('Auf.P.Chemie.Nb2','');
  addToApi('Auf.P.Chemie.Ti1','');
  addToApi('Auf.P.Chemie.Ti2','');
  addToApi('Auf.P.Chemie.N1','');
  addToApi('Auf.P.Chemie.N2','');
  addToApi('Auf.P.Chemie.Cu1','');
  addToApi('Auf.P.Chemie.Cu2','');
  addToApi('Auf.P.Chemie.Ni1','');
  addToApi('Auf.P.Chemie.Ni2','');
  addToApi('Auf.P.Chemie.Mo1','');
  addToApi('Auf.P.Chemie.Mo2','');
  addToApi('Auf.P.Chemie.B1','');
  addToApi('Auf.P.Chemie.B2','');
  addToApi('Auf.P.Haerte1','');
  addToApi('Auf.P.Haerte2','');
  addToApi('Auf.P.Chemie.Frei1.1','');
  addToApi('Auf.P.Chemie.Frei1.2','');
  addToApi('Auf.P.Mech.Sonstig1','');
  addToApi('Auf.P.RauigkeitA1','');
  addToApi('Auf.P.RauigkeitA2','');
  addToApi('Auf.P.RauigkeitB1','');
  addToApi('Auf.P.RauigkeitB2','');

  // Verpackung
  addToApi('Auf.P.AbbindungL','');
  addToApi('Auf.P.AbbindungQ','');
  addToApi('Auf.P.Zwischenlage','');
  addToApi('Auf.P.Unterlage','');
  addToApi('Auf.P.StehendYN','');
  addToApi('Auf.P.LiegendYN','');
  addToApi('Auf.P.Nettoabzug','');
  addToApi('Auf.P.Stapelhoehe','');
  addToApi('Auf.P.StapelhAbzug','');
  addToApi('Auf.P.RingKgVon','');
  addToApi('Auf.P.RingKgBis','');
  addToApi('Auf.P.KgmmVon','');
  addToApi('Auf.P.KgmmBis','');
  addToApi('Auf.P.StueckVE','');
  addToApi('Auf.P.VEkgMax','');
  addToApi('Auf.P.RechtwinkMax','');
  addToApi('Auf.P.EbenheitMax','');
  addToApi('Auf.P.SaebeligkeitMax','');
  addToApi('Auf.P.Etikettentyp','');
  addToApi('Auf.P.Verwiegungsart','');
  addToApi('Auf.P.VpgText1','');
  addToApi('Auf.P.VpgText2','');
  addToApi('Auf.P.VpgText3','');
  addToApi('Auf.P.VpgText4','');
  addToApi('Auf.P.VpgText5','');
  addToApi('Auf.P.Skizzennummer','');
  addToApi('Auf.P.Verpacknr','');
  addToApi('Auf.P.Etk.Guete','');
  addToApi('Auf.P.Etk.Dicke','');
  addToApi('Auf.P.Etk.Breite','');
  addToApi('Auf.P.Etk.Laenge','');
  addToApi('Auf.P.Etk.Feld.1','');
  addToApi('Auf.P.Etk.Feld.2','');
  addToApi('Auf.P.Etk.Feld.3','');
  addToApi('Auf.P.Etk.Feld.4','');
  addToApi('Auf.P.Etk.Feld.5','');
  addToApi('Auf.P.VerpackAdrNr','');
  addToApi('Auf.P.VpgText6','');
  addToApi('Auf.P.Umverpackung','');
  addToApi('Auf.P.Wicklung','');

  // Fremdeinheiten
  addToApi('Auf.P.FE.Dicke','');
  addToApi('Auf.P.FE.Breite','');
  addToApi('Auf.P.FE.Laenge','');
  addToApi('Auf.P.FE.Dickentol','');
  addToApi('Auf.P.FE.Breitentol','');
  addToApi('Auf.P.FE.Laengentol','');
  addToApi('Auf.P.FE.RID','');
  addToApi('Auf.P.FE.RIDMax','');
  addToApi('Auf.P.FE.RAD','');
  addToApi('Auf.P.FE.RADMax','');
  addToApi('Auf.P.FE.Gewicht','');

  // Protokoll
  addToApi('Auf.P.Anlage.Datum','');
  addToApi('Auf.P.Anlage.Zeit','');
  addToApi('Auf.P.Anlage.User','');
  addToApi('Auf.P.Loesch.Datum','');
  addToApi('Auf.P.Loesch.Zeit','');
  addToApi('Auf.P.Loesch.User','');
  addToApi('Auf.P.Workflow','');

  // Custom
  addToApi('Auf.P.Cust.Sort','');

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

  vFelderGrp    # aArgs->getValue('FELDER');

  // --------------------------------------------------------------------------
  // Datensatz lesen
  RecBufClear(c_DATEI);
  Auf.P.Nummer      # vAufNr;
  Auf.P.Position    # vAufPos;
  if (RecRead(c_DATEI,1,0) <> _rOK) then begin
      // nicht gefunden
      aResponse->addErrNode(errSVL_Allgemein,'Auftragsposition nicht gefunden');
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

          // Inkompatible Feldnamen für Export korrigieren
          CASE (vFldName) OF
            'Auf.P.Stück\VE'  : vFldName # 'Auf.P.StückVE';
          END

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
