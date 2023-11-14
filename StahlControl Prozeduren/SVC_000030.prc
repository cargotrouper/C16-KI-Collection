@A
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000030
//                  OHNE E_R_G
//  Zu Service: BAG_POS_READ
//
//  Info
//  BAG_POST_READ: Lesen von Betriebsauftragspositionen und Rückgabe der angegeben Felder
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

  c_DATEI       : 702
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
  vNode->apiSetDesc('Eindeutige Nummer der Betriebsauftragsposition','123045');

  // Auftragsposition
  vNode # vApi->apiAdd('POSITION',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Positionsnummer der Betriebsauftragsposition','1');

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

  // Haupdaten
  addToApi('','');
  addToApi('BAG.P.Nummer','');
  addToApi('BAG.P.Position','');
  addToApi('BAG.P.Loeschmarker','');
  addToApi('BAG.P.Aktion','');
  addToApi('BAG.P.Aktion2','');
  addToApi('BAG.P.Bezeichnung','');
  addToApi('BAG.P.ExternYN','');
  addToApi('BAG.P.ExterneLiefNr','');
  addToApi('BAG.P.Kommission','');
  addToApi('BAG.P.Auftragsnr','');
  addToApi('BAG.P.AuftragsPos','');
  addToApi('BAG.P.Zieladresse','');
  addToApi('BAG.P.Zielanschrift','');
  addToApi('BAG.P.Zielstichwort','');
  addToApi('BAG.P.ZielVerkaufYN','');
  addToApi('BAG.P.Teilungen','');
  addToApi('BAG.P.Level','');
  addToApi('BAG.P.Typ.1In-1OutYN','');
  addToApi('BAG.P.Typ.1In-yOutYN','');
  addToApi('BAG.P.Typ.xIn-yOutYN','');
  addToApi('BAG.P.Typ.VSBYN','');
  addToApi('BAG.P.Bemerkung','');
  addToApi('BAG.P.Referenznr','');

  // Terminierung
  addToApi('BAG.P.Fenster.MinDat','');
  addToApi('BAG.P.Fenster.MinZei','');
  addToApi('BAG.P.Fenster.MaxDat','');
  addToApi('BAG.P.Fenster.MaxZei','');
  addToApi('BAG.P.Plan.StartDat','');
  addToApi('BAG.P.Plan.StartZeit','');
  addToApi('BAG.P.Plan.StartInfo','');
  addToApi('BAG.P.Plan.Dauer','');
  addToApi('BAG.P.Plan.EndDat','');
  addToApi('BAG.P.Plan.EndZeit','');
  addToApi('BAG.P.Plan.EndInfo','');
  addToApi('BAG.P.Fertig.Dat','');
  addToApi('BAG.P.Fertig.Zeit','');
  addToApi('BAG.P.Fertig.User','');
  addToApi('BAG.P.FormelID','');
  addToApi('BAG.P.FormelBez','');
  addToApi('BAG.P.Ressource.Grp','');
  addToApi('BAG.P.Ressource','');
  addToApi('BAG.P.Reihenfolge','');

  // kosten
  addToApi('BAG.P.Kosten.Wae','');
  addToApi('BAG.P.Kosten.Fix','');
  addToApi('BAG.P.Kosten.Pro','');
  addToApi('BAG.P.Kosten.PEH','');
  addToApi('BAG.P.Kosten.MEH','');
  addToApi('BAG.P.Kosten.Gesamt','');
  addToApi('BAG.P.Kosten.Ges.Stk','');
  addToApi('BAG.P.Kosten.Ges.Gew','');
  addToApi('BAG.P.Kosten.Ges.Men','');
  addToApi('BAG.P.Kosten.Ges.MEH','');

  // Protokoll
  addToApi('BAG.P.Anlage.Datum','');
  addToApi('BAG.P.Anlage.Zeit','');
  addToApi('BAG.P.Anlage.User','');
  addToApi('BAG.P.Planlock.UsrID','');


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

  vFelderGrp    # aArgs->getValue('FELDER');

  // --------------------------------------------------------------------------
  // Datensatz lesen
  RecBufClear(c_DATEI);
  Bag.P.Nummer      # vBagNr;
  Bag.P.Position    # vBagPos;
  if (RecRead(c_DATEI,1,0) <> _rOK) then begin
      // nicht gefunden
      aResponse->addErrNode(errSVL_Allgemein,'Betriebsauftragsposition nicht gefunden');
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

/*
          // Inkompatible Feldnamen für Export korrigieren
          CASE (vFldName) OF
            'Ein.P.Stück\VE'  : vFldName # 'Ein.P.StückVE';
          END
*/

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
        if (StrCut(vFldName,1,6) = 'BAG.P.') then begin

          if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

            // Felder mit Umlauten mappen
            CASE (toUpper(vFldName)) OF
              'BAG.P.LOESCHMARKER'    : vFldName #  'Bag.P.Löschmarker';
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
