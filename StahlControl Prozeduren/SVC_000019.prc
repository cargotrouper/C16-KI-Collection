@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000019
//                  OHNE E_R_G
//  Zu Service: EIN_SEL
//
//  Info
///  EIN_SEL: Lesen von Bestellkopfdaten und Rückgabe der angegeben Felder
//
//  16.02.2011  ST  Erstellung der Prozedur
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
global Sel_Args_000019 begin
  Tmp : alpha;

  // Bestellnummer     Ein.Nummer
  sel_EinNrJN  : logic;
  sel_EinNr,
  sel_EinNrVon,
  sel_EinNrBis : int;
  sel_EinNrNot,
  sel_EinNrAus : alpha;

  // Bestelldatum       Ein.Datum
  sel_EinDatJN  : logic;
  sel_EinDat,
  sel_EinDatVon,
  sel_EinDatBis : date;
  sel_EinDatNot,
  sel_EinDatAus : alpha;

  // Lieferantennummer  Ein.Lieferantennr
  sel_LiefJN  : logic;
  sel_Lief,
  sel_LiefVon,
  sel_LiefBis : int;
  sel_LiefNot,
  sel_LiefAus : alpha;

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

  // AB Nummer          Ein.AB.Nummer
  sel_AbstNrJN  : logic;
  sel_AbstNr,
  sel_AbstNrVon,
  sel_AbstNrBis,
  sel_AbstNrNot,
  sel_AbstNrAus : alpha;
end;

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
  addToApiSel(a,b) : begin end;

  c_DATEI       : 500
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
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Ein.Nummer, Ein.Datum, Ein.Lieferantennr, Ein.Lieferadresse, Ein.Lieferanschrift, EIn.AB.Nummer','');
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
  addToApi('Ein.Nummer','');
  addToApi('Ein.Datum','');
  addToApi('Ein.LiefervertragYN','');
  addToApi('Ein.AbrufYN','');
  addToApi('Ein.Lieferantennr','');
  addToApi('Ein.LieferantenSW','');
  addToApi('Ein.Lieferadresse','');
  addToApi('Ein.Lieferanschrift','');
  addToApi('Ein.Tour','');
  addToApi('Ein.Verbraucher','');
  addToApi('Ein.Rechnungsempf','');
  addToApi('Ein.Sachbearbeiter','');
  addToApi('Ein.Lieferbed','');
  addToApi('Ein.Zahlungsbed','');
  addToApi('Ein.Versandart','');
  addToApi('Ein.Waehrung','');
  addToApi('Ein.Waehrungskurs','');
  addToApi('Ein.WaehrungFixYN','');
  addToApi('Ein.AbmessungsEH','');
  addToApi('Ein.GewichtsEH','');
  addToApi('Ein.Sprache','');
  addToApi('Ein.AB.Nummer','');
  addToApi('Ein.AB.Datum','');
  addToApi('Ein.AB.Bearbeiter','');
  addToApi('Ein.BDSNummer','');
  addToApi('Ein.Land','');
  addToApi('Ein.Löschmarker','');
  addToApi('Ein.Aktionsmarker','');
  addToApi('Ein.Eingangsmarker','');
  addToApi('Ein.Steuerschluessel','');
  addToApi('Ein.GueltigkeitVom','');
  addToApi('Ein.GueltigkeitBis','');

  // Protokoll
  addToApi('Ein.Anlage.Datum','');
  addToApi('Ein.Anlage.Zeit','');
  addToApi('Ein.Anlage.User','');

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
  vFldData : alpha(4096);
  vFldName : alpha;
  vChkName : alpha;
  Erx       : int;
end
begin
  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vFelderGrp    # aArgs->getValue('FELDER');

  vArgs # VarAllocate(Sel_Args_000019);
  // ... und mit den empfangenen Argumenten füllen

  prepSelInt(aArgs,'Ein.Nummer',
                    var sel_EinNrJN,
                    var sel_EinNr,
                    var sel_EinNrNot,
                    var sel_EinNrVon,
                    var sel_EinNrBis,
                    var sel_EinNrAus);

  prepSelDate(aArgs,'Ein.Datum',
                    var sel_EinDatJN,
                    var sel_EinDat,
                    var sel_EinDatNot,
                    var sel_EinDatVon,
                    var sel_EinDatBis,
                    var sel_EinDatAus);

  prepSelInt(aArgs,'Ein.Lieferantennr',
                    var sel_LiefJN,
                    var sel_Lief,
                    var sel_LiefNot,
                    var sel_LiefVon,
                    var sel_LiefBis,
                    var sel_LiefAus);

  prepSelInt(aArgs,'Ein.Lieferadresse',
                    var sel_LiefAdrJN,
                    var sel_LiefAdr,
                    var sel_LiefAdrNot,
                    var sel_LiefAdrVon,
                    var sel_LiefAdrBis,
                    var sel_LiefAdrAus);

  prepSelInt(aArgs,'Ein.Lieferanschrift',
                    var sel_LiefAnsJN,
                    var sel_LiefAns,
                    var sel_LiefAnsNot,
                    var sel_LiefAnsVon,
                    var sel_LiefAnsBis,
                    var sel_LiefAnsAus);

  prepSelAlpha(aArgs,'Ein.AB.Nummer',
                    var sel_AbstNrJN,
                    var sel_AbstNr,
                    var sel_AbstNrNot,
                    var sel_AbstNrVon,
                    var sel_AbstNrBis,
                    var sel_AbstNrAus);


  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000019:Sel',vArgs);
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
          if (StrCut(vFldName,1,4) = 'EIN.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'EIN.WAEHRUNG'        : vFldName #  'Ein.Währung';
                'EIN.WAEHRUNGSKURS'   : vFldName #  'Ein.Währungskurs';
                'EIN.WAEHRUNGFIXYN'   : vFldName #  'Ein.WährungFixYN';
                'EIN.LOESCHMARKER'    : vFldName #  'Ein.Löschmarker';
                'EIN.STUERSCHLUESSEL' : vFldName #  'Ein.Steuerschlüssel';
                'EIN.GUELTIGKEITVOM'  : vFldName #  'Ein.GültigkeitVom';
                'EIN.GUELTIGKEITBIS'  : vFldName #  'Ein.GültigkeitBis';
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
  VarFree(Sel_Args_000019);
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
  VarInstance(Sel_Args_000019, SOA_PartSel_Args);

  if (SelInt( Ein.Nummer,
              sel_EinNrJN,
              sel_EinNrNot,
              sel_EinNrAus,
              sel_EinNrVon,
              sel_EinNrBis)) then return false;

  if (SelDate( Ein.Datum,
              sel_EinDatJN,
              sel_EinDatNot,
              sel_EinDatAus,
              sel_EinDatVon,
              sel_EinDatBis)) then return false;

  if (SelInt( Ein.Lieferantennr,
              sel_LiefJN,
              sel_LiefNot,
              sel_LiefAus,
              sel_LiefVon,
              sel_LiefBis)) then return false;

  if (SelInt( Ein.Lieferadresse,
              sel_LiefAdrJN,
              sel_LiefAdrNot,
              sel_LiefAdrAus,
              sel_LiefAdrVon,
              sel_LiefAdrBis)) then return false;

  if (SelInt( Ein.Lieferanschrift,
              sel_LiefAnsJN,
              sel_LiefAnsNot,
              sel_LiefAnsAus,
              sel_LiefAnsVon,
              sel_LiefAnsBis)) then return false;

  if (SelAlpha( Ein.AB.Nummer,
              sel_AbstNrJN,
              sel_AbstNrNot,
              sel_AbstNrAus,
              sel_AbstNrVon,
              sel_AbstNrBis)) then return false;

/*
  if (Sel...( Auf.......,
              sel_ ... JN,
              sel_ ... Not,
              sel_ ... Aus,
              sel_ ... Von,
              sel_ ... Bis)) then return false;
*/


  return true;
end; // sub Sel() : logic



//=========================================================================
//=========================================================================
//=========================================================================