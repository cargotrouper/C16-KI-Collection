@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000012
//                  OHNE E_R_G
//  Zu Service: AUF_SEL
//
//  Info
///  AUF_SEL: Lesen von Auftragskopfdaten und Rückgabe der angegeben Felder
//
//  14.02.2011  ST  Erstellung der Prozedur
//  2022-06-29  AH  ERX
//
//  Subprozeduren
//    SUB api() : handle
//    SUB exec(aArgs : handle; var aResponse : handle) : int
//    SUB SelFloat(aFld : float; aJN : logic; aNot : alpha; aAus : alpha; aVon : float; aBis : float) : logic
//    SUB prepSelFloat(aArgs : int;aFldName : alpha; var aJN : logic; var aFld : float; var aFldNot : alpha; var aFldVon : float; var aFldBis : float; var aFldAus : alpha)
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API


// Selektionsstruktur für Service
global Sel_Args_000012 begin
  Tmp : alpha;

  // Auftragsnummer    Auf.Nummer
  sel_AufNrJN  : logic;
  sel_AufNr,
  sel_AufNrVon,
  sel_AufNrBis : int;
  sel_AufNrNot,
  sel_AufNrAus : alpha;

  // Auftragsdatum      Auf.Datum
  sel_AufDatJN  : logic;
  sel_AufDat,
  sel_AufDatVon,
  sel_AufDatBis : date;
  sel_AufDatNot,
  sel_AufDatAus : alpha;

  // Kundennummer       Auf.Kundennr
  sel_KundeJN  : logic;
  sel_Kunde,
  sel_KundeVon,
  sel_KundeBis : int;
  sel_KundeNot,
  sel_KundeAus : alpha;

  // Lieferadresse    Auf.Lieferadresse
  sel_LiefAdrJN  : logic;
  sel_LiefAdr,
  sel_LiefAdrVon,
  sel_LiefAdrBis : int;
  sel_LiefAdrNot,
  sel_LiefAdrAus : alpha;

  // Lieferanschrift  Auf.Lieferschrift
  sel_LiefAnsJN  : logic;
  sel_LiefAns,
  sel_LiefAnsVon,
  sel_LiefAnsBis : int;
  sel_LiefAnsNot,
  sel_LiefAnsAus : alpha;

  // Bestellnummer      Auf.Best.Nummer
  sel_BestNrJN  : logic;
  sel_BestNr,
  sel_BestNrVon,
  sel_BestNrBis,
  sel_BestNrNot,
  sel_BestNrAus : alpha;

  // Vorgangstyp        Auf.Vorgangstyp
  sel_VorgTypJN  : logic;
  sel_VorgTyp,
  sel_VorgTypVon,
  sel_VorgTypBis,
  sel_VorgTypNot,
  sel_VorgTypAus : alpha;

end;

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
  addToApiSel(a,b) : begin end;

  c_DATEI       : 400
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

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Selektionsmöglichlkeiten
  // ----------------------------------
  vNode # vApi->apiAdd('..Mögliche Selektionsfelder',_TypeAlpha,false,null,null,'');
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Auf.Nummer, Auf.Datum, Auf.Kundennr, Auf.Lieferadresse, Auf.Lieferanschrift, Auf.Best.Nummer, Auf.Vorgangstyp','');
  //

  vNode # vApi->apiAdd('sel_+Feldname',_TypeAlpha,false,null,null,'sel_Adr.Stichwort=Beispiel');
  vNode->apiSetDesc('Eingrenzung für einen genauen Wert','123456');

  vNode # vApi->apiAdd('sel_von_+Feldname',_TypeAlpha,false,null,null,'sel_von_Adr.Stichwort=Beispiel');
  vNode->apiSetDesc('Eingrenzung für einen Mindestwert, kombinierbar mit Maximalangabe ','123456');

  vNode # vApi->apiAdd('sel_bis_+Feldname',_TypeAlpha,false,null,null,'sel_bis_Adr.Stichwort=ZumBeispiel');
  vNode->apiSetDesc('Eingrenzung für einen Maximalwert, kombinierbar mit Mindestangabe','123456');

  vNode # vApi->apiAdd('sel_aus_+Feldname',_TypeAlpha,false,null,null,'sel_aus_Adr.LKZ=D|DE|NL|');
  vNode->apiSetDesc('Eingrenzung für einen Wert der angegebenen Wertegruppe','D|DE');

  vNode # vApi->apiAdd('sel_not_+Feldname',_TypeAlpha,false,null,null,'sel_not_Adr.LKZ=D|DE|');
  vNode->apiSetDesc('Eingrenzung für einen Wert der nicht in der angegebenen Wertegruppe vorkommt','D|DE');


  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------

 // Hauptdaten
  addToApi('Auf.Nummer','');
  addToApi('Auf.Datum','');
  addToApi('Auf.Vorgangstyp','Vorgangstyp kann AUF, ANG, GUT... sein ');
  addToApi('Auf.LiefervertragYN','');
  addToApi('Auf.AbrufYN','');
  addToApi('Auf.GueltigkeitVom','');
  addToApi('Auf.GueltigkeitBis','');
  addToApi('Auf.Kundennr','');
  addToApi('Auf.KundenStichwort','');
  addToApi('Auf.Lieferadresse','');
  addToApi('Auf.Lieferanschrift','');
  addToApi('Auf.Tour','');
  addToApi('Auf.Verbraucher','');
  addToApi('Auf.Rechnungsempf','');
  addToApi('Auf.Sachbearbeiter','');
  addToApi('Auf.Lieferbed','');
  addToApi('Auf.Zahlungsbed','');
  addToApi('Auf.Versandart','');
  addToApi('Auf.Waehrung','');
  addToApi('Auf.Waehrungskurs','');
  addToApi('Auf.WaehrungFixYN','');
  addToApi('Auf.AbmessungsEH','');
  addToApi('Auf.GewichtsEH','');
  addToApi('Auf.Sprache','');
  addToApi('Auf.Best.Nummer','');
  addToApi('Auf.Best.Datum','');
  addToApi('Auf.Best.Bearbeiter','');
  addToApi('Auf.BDSNummer','');
  addToApi('Auf.Land','');
  addToApi('Auf.Vertreter','');
  addToApi('Auf.Vertreter.Prov','');
  addToApi('Auf.Vertreter.ProT','');
  addToApi('Auf.Loeschmarker','');
  addToApi('Auf.Aktionsmarker','');
  addToApi('Auf.Steuerschluessel','');
  addToApi('Auf.Vertreter2','');
  addToApi('Auf.Vertreter2.Prov','');
  addToApi('Auf.Vertreter2.ProT','');

  // Protokoll
  addToApi('Auf.Anlage.Datum','');
  addToApi('Auf.Anlage.Zeit','');
  addToApi('Auf.Anlage.User','');


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
  vArgNode    : handle;

  // Ablaufvariablen
  vErg        : int;        // Ergebnishandle
  vTmp        : alpha;
  vSel        : handle;     // Handle der Selektion
  vAnz        : int;        // Anzahl der gelesen Datensätze

  // Argument, fachliche Seite
  vFelderGrp  : alpha;

  // Rückgabedaten
  vResNode    : handle;     // Handle für Ansprechpartnernode

  // für Gruppenausgabe
  vDatei  : int;
  vTds    : int;
  vTdsCnt : int;
  vFld    : int;
  vFldCnt : int;
  vFldData  : alpha(4096);
  vFldName  : alpha;
  vChkName  : alpha;
  Erx       : int;
end
begin
  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vFelderGrp    # aArgs->getValue('FELDER');

  vArgs # VarAllocate(Sel_Args_000012);
  // ... und mit den empfangenen Argumenten füllen

  prepSelInt(aArgs,'Auf.Nummer',
                    var sel_AufNrJN,
                    var sel_AufNr,
                    var sel_AufNrNot,
                    var sel_AufNrVon,
                    var sel_AufNrBis,
                    var sel_AufNrAus);

  prepSelDate(aArgs,'Auf.Datum',
                    var sel_AufDatJN,
                    var sel_AufDat,
                    var sel_AufDatNot,
                    var sel_AufDatVon,
                    var sel_AufDatBis,
                    var sel_AufDatAus);

  prepSelInt(aArgs,'Auf.Kundennr',
                    var sel_KundeJN,
                    var sel_Kunde,
                    var sel_KundeNot,
                    var sel_KundeVon,
                    var sel_KundeBis,
                    var sel_KundeAus);

  prepSelInt(aArgs,'Auf.Lieferadresse',
                    var sel_LiefAdrJN,
                    var sel_LiefAdr,
                    var sel_LiefAdrNot,
                    var sel_LiefAdrVon,
                    var sel_LiefAdrBis,
                    var sel_LiefAdrAus);

  prepSelInt(aArgs,'Auf.Lieferanschrift',
                    var sel_LiefAnsJN,
                    var sel_LiefAns,
                    var sel_LiefAnsNot,
                    var sel_LiefAnsVon,
                    var sel_LiefAnsBis,
                    var sel_LiefAnsAus);

  prepSelAlpha(aArgs,'Auf.Best.Nummer',
                    var sel_BestNrJN,
                    var sel_BestNr,
                    var sel_BestNrNot,
                    var sel_BestNrVon,
                    var sel_BestNrBis,
                    var sel_BestNrAus);

  prepSelAlpha(aArgs,'Auf.Vorgangstyp',
                    var sel_VorgTypJN,
                    var sel_VorgTyp,
                    var sel_VorgTypNot,
                    var sel_VorgTypVon,
                    var sel_VorgTypBis,
                    var sel_VorgTypAus);




  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000012:Sel',vArgs);
  vAnz  # Lib_SOA:RunPartSel(vSel, 0, 0); // Max 0 = alle, RecId 0 = von Anfang an


  // Daten Node zum einfügen extrahieren
  vNode # aResponse->getNode('DATA');

  FOR  Erx # RecRead(c_DATEI, SOA_PartSel_Sel, _RecFirst);
  LOOP Erx # RecRead(c_DATEI, SOA_PartSel_Sel, _RecNext);
  WHILE (Erx <= _rLocked) DO BEGIN

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
        FOR  vArgNode # aArgs->CteRead(_CteFirst | _CteChildList)
        LOOP vArgNode # aArgs->CteRead(_CteNext  | _CteChildList, vArgNode)
        WHILE (vArgNode > 0) do begin

          vFldName # toUpper(vArgNode->spName);
          if (StrCut(vFldName,1,4) = 'AUF.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'AUF.GUELTIGKEITVOM'    : vFldName #  'Auf.GültigkeitVom';     // TDS 1: Hauptdaten
                'AUF.GUELTIGKEITBIS'    : vFldName #  'Auf.GültigkeitBis';
                'AUF.WAEHRUNG'          : vFldName #  'Auf.Währung';
                'AUF.WAEHRUNGSKURS'     : vFldName #  'Auf.Währungskurs';
                'AUF.WAEHRUNGFIXYN'     : vFldName #  'Auf.WährungFixYN';
                'AUF.LOESCHMARKER'      : vFldName #  'Auf.Löschmarker';
                'AUF.STEUERSCHLUESSEL'  : vFldName #  'Auf.Steuerschlüssel';
              END;

              // Feld mit "normalem" Namen prüfen
              vErg # FldInfoByName(vFldName,_FldExists);

              // Feld vorhanden?
              if (vErg <> 0) then begin
                // Alle Feldnamen in Großbuchstabenexportieren
                vFldName # toUpper(vFldName);

                 // Wenn vorhanden dann je nach Feldtyp schreiben
                 CASE (FldInfoByName(vFldName,_FldType)) OF
                    _TypeAlpha    : vResNode->Lib_SOA:AppendNode(vFldName, FldAlphaByName(vFldName));
                    _TypeBigInt   : vResNode->Lib_SOA:AppendNode(vFldName, CnvAb(FldBigIntByName(vFldName)));
                    _TypeDate     : vResNode->Lib_SOA:AppendNode(vFldName, CnvAd(FldDateByName(vFldName)));
                    _TypeDecimal  : vResNode->Lib_SOA:AppendNode(vFldName, CnvAM(FldDecimalByName(vFldName)));
                    _TypeFloat    : vResNode->Lib_SOA:AppendNode(vFldName, CnvAf(FldFloatByName(vFldName)));
                    _TypeInt      : vResNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldIntByName(vFldName)));
                    _TypeLogic    : vResNode->Lib_SOA:AppendNode(vFldName, CnvAi(CnvIl(FldLogicByName(vFldName))));
                    _TypeTime     : vResNode->Lib_SOA:AppendNode(vFldName, CnvAt(FldTimeByName(vFldName)));
                    _TypeWord     : vResNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldWordByName(vFldName)));
                 END;

              end else begin
                // FEHLER
                // Feld gibts nicht, dann nicht anhängen
dbg('Feld gibts nicht');
              end;

            end;

          end else begin

            // Fehler: Kein Feld angegeben
  dbg('kein Feld angegeben');
          end;

        END;

      end; // EO Indi
      //-------------------------------------------------------------------------------


    end; // CASE


    // Nächsten Datensatz lesen

  END;

  // --------------------------------------------------------------------------
  // Abschlussarbeiten

  // Speicher wieder freigeben
  VarFree(Sel_Args_000012);
  Lib_SOA:ClosePartSel(vSel);

  // Daten des Services sind angehängt
  return _rOk;

End; // sub exec(...) : int



//=========================================================================
// sub Sel() : logic
//
//  Prüft einen Datensatz, ob dieser mit den gewünschten Werten überstimmt
//
//  @Param
//      -
//
//  @Return
//    logic                         // true -> passt, false -> passt nicht
//
//=========================================================================
sub Sel() : logic
local begin
  vok : logic;
end
begin
  // Struktur für Selektion holen
  VarInstance(Sel_Args_000012, SOA_PartSel_Args);

  if (SelInt(Auf.Nummer,sel_AufNrJN,  sel_AufNrNot,sel_AufNrAus, sel_AufNrVon, sel_AufNrBis)) then return false;
  if (SelDate(Auf.Datum, sel_AufDatJN, sel_AufDatNot,sel_AufDatAus, sel_AufDatVon,sel_AufDatBis)) then return false;
  if (SelInt(Auf.Kundennr, sel_KundeJN,  sel_KundeNot,sel_KundeAus,sel_KundeVon,   sel_KundeBis)) then return false;
  if (SelInt(Auf.Lieferadresse,sel_LiefAdrJN,  sel_LiefAdrNot,  sel_LiefAdrAus,sel_LiefAdrVon,   sel_LiefAdrBis)) then return false;
  if (SelInt(Auf.Lieferanschrift, sel_LiefAnsJN,  sel_LiefAnsNot,  sel_LiefAnsAus,sel_LiefAnsVon,   sel_LiefAnsBis)) then return false;
  if (SelAlpha(Auf.Best.Nummer,sel_BestNrJN, sel_BestNrAus,sel_BestNrNot, sel_BestNrVon,  sel_BestNrBis  )) then return false;
  if (SelAlpha(Auf.Vorgangstyp,sel_VorgTypJN, sel_VorgTypAus,sel_VorgTypNot, sel_VorgTypVon,  sel_VorgTypBis  )) then return false;

  return true;
end; // sub Sel() : logic



//=========================================================================
//=========================================================================
//=========================================================================