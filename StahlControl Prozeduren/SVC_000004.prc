@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000004
//                  OHNE E_R_G
//  Zu Service: ADR_SEL
//
//  Info
///  ADR_SEL: Lesen von Adressdaten und Rückgabe der angegeben Felder
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
global Sel_Args_000004 begin
  Tmp : alpha;

  // Kundennummer
  sel_KundenNrJN  : logic;
  sel_KundenNr,
  sel_KundenNrVon,
  sel_KundenNrBis : int;
  sel_KundenNrNot,
  sel_KundenNrAus : alpha;

  // Lieferantennummer
  sel_LiefNrJN  : logic;
  sel_LiefNr,
  sel_LiefNrVon,
  sel_LiefNrBis : int;
  sel_LiefNrNot,
  sel_LiefNrAus : alpha;

  // Stichwort
  sel_StichwJN  : logic;
  sel_Stichw,
  sel_StichwVon,
  sel_StichwBis,
  sel_StichwNot,
  sel_StichwAus : alpha;

/*
  sel_xxxJN  : logic;
  sel_xxx,
  sel_xxxVon,
  sel_xxxBis : float;
  sel_xxxNot,
  sel_xxxAus : alpha;
*/
end;

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
  addToApiSel(a,b) : begin end;
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
  vNode->apiSetDesc('Folgende Felder können abgrfragt werden: Adr.KundenNr, Adr.LieferantenNr, Adr.Stichwort','');
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
  addToApi('Adr.Nummer'           ,'Eindeutige Adressnummer');
  addToApi('Adr.KundenNr'         ,'');
  addToApi('Adr.KundenBuchNr'     ,'');
  addToApi('Adr.LieferantenNr'    ,'');
  addToApi('Adr.LieferantBuchNr'  ,'');
  addToApi('Adr.Stichwort'        ,'');
  addToApi('Adr.Gruppe'           ,'');
  addToApi('Adr.Sachbearbeiter'   ,'');
  addToApi('Adr.Vertreter'        ,'');
  addToApi('Adr.Verband'          ,'');
  addToApi('Adr.VerbandRefNr'     ,'');
  addToApi('Adr.ABC'              ,'');
  addToApi('Adr.Punktzahl'        ,'');
  addToApi('Adr.Anrede'           ,'');
  addToApi('Adr.Name'             ,'');
  addToApi('Adr.Zusatz'           ,'');
  addToApi('Adr.Strasse'          ,'');
  addToApi('Adr.LKZ'              ,'');
  addToApi('Adr.PLZ'              ,'');
  addToApi('Adr.Postfach.PLZ'     ,'');
  addToApi('Adr.Postfach'         ,'');
  addToApi('Adr.Ort'              ,'');
  addToApi('Adr.Telefon1'         ,'');
  addToApi('Adr.Telefon2'         ,'');
  addToApi('Adr.Telefax'          ,'');
  addToApi('Adr.eMail'            ,'');
  addToApi('Adr.Website'          ,'');
  addToApi('Adr.Briefanrede'      ,'');
  addToApi('Adr.Briefgruppe'      ,'');
  addToApi('Adr.Kreditnummer'     ,'');
  addToApi('Adr.SperrKundeYN'     ,'');
  addToApi('Adr.SperrLieferantYN' ,'');
  addToApi('Adr.Sperrvermerk'     ,'');
  addToApi('Adr.Bemerkung'        ,'');
  addToApi('Adr.Vertreter2'       ,'');
  addToApi('Adr.Vertr1.Prov'      ,'');
  addToApi('Adr.Vertr2.Prov'      ,'');

  // Bankverbindung
  addToApi('Adr.Bank1.Name'       ,'');
  addToApi('Adr.Bank1.BLZ'        ,'');
  addToApi('Adr.Bank1.Kontonr'    ,'');
  addToApi('Adr.Bank1.IBAN'       ,'');
  addToApi('Adr.Bank1.BIC.SWIFT'  ,'');
  addToApi('Adr.Bank2.Name'       ,'');
  addToApi('Adr.Bank2.BLZ'        ,'');
  addToApi('Adr.Bank2.Kontonr'    ,'');
  addToApi('Adr.Bank2.IBAN'       ,'');
  addToApi('Adr.Bank2.BIC.SWIFT'  ,'');

  // Einkauf
  addToApi('Adr.EK.Lieferbed'     ,'');
  addToApi('Adr.EK.Zahlungsbed'   ,'');
  addToApi('Adr.EK.Versandart'    ,'');
  addToApi('Adr.EK.Waehrung'      ,'');
  addToApi('Adr.EK.Referenznr'    ,'');
  addToApi('Adr.EK.Fusstext'      ,'');
  addToApi('Adr.EK.Zertifikat'    ,'');
  addToApi('Adr.EK.ZertifikatBis' ,'');

  // Verkauf
  addToApi('Adr.VK.Lieferbed'     ,'');
  addToApi('Adr.VK.Zahlungsbed'   ,'');
  addToApi('Adr.VK.Versandart'    ,'');
  addToApi('Adr.VK.Währung'       ,'');
  addToApi('Adr.VK.Referenznr'    ,'');
  addToApi('Adr.VK.ReEmpfaenger'  ,'');
  addToApi('Adr.VK.SammelReYN'    ,'');
  addToApi('Adr.VK.Verwiegeart'   ,'');
  addToApi('Adr.VK.Fusstext'      ,'');
  addToApi('Adr.VK.EigentumVBYN'  ,'');
  addToApi('Adr.VK.EigentumVBDat' ,'');

  // Zusatz
  addToApi('Adr.USIdentNr'        ,'');
  addToApi('Adr.Steuernummer'     ,'');
  addToApi('Adr.Steuerschluessel' ,'');
  addToApi('Adr.Sprache'          ,'');
  addToApi('Adr.AbmessungEH'      ,'');
  addToApi('Adr.GewichtEH'        ,'');
  addToApi('Adr.Pfad.Bild'        ,'');
  addToApi('Adr.Pfad.Doks'        ,'');
  addToApi('Adr.BonusEmpfaengerYN','');
  addToApi('Adr.BonusProzent'     ,'');
  addToApi('Adr.Fibudatum.Kd'     ,'');
  addToApi('Adr.Fibudatum.Lf'     ,'');

  // Protokoll
  addToApi('Adr.Anlage.Datum'     ,'');
  addToApi('Adr.Anlage.Zeit'      ,'');
  addToApi('Adr.Anlage.User'      ,'');
  addToApi('Adr.Aenderung.Datum'  ,'');
  addToApi('Adr.Aenderung.Zeit'   ,'');
  addToApi('Adr.Aenderung.User'   ,'');

  // Finanzdaten
  addToApi('Adr.Fin.Vzg.FixTag'   ,'');
  addToApi('Adr.Fin.Vzg.Offset'   ,'');
  addToApi('Adr.Fin.Vzg.AnzZhlg'  ,'');
  addToApi('Adr.Fin.letzterAufAm' ,'');
  addToApi('Adr.Fin.letzteReAm'   ,'');
  addToApi('Adr.Fin.SummeOP'      ,'');
  addToApi('Adr.Fin.SummeAB'      ,'');
  addToApi('Adr.Fin.SummeABDoll'  ,'');
  addToApi('Adr.Fin.SummeLFS'     ,'');
  addToApi('Adr.Fin.SummeRes'     ,'');
  addToApi('Adr.Fin.Refreshdatum' ,'');
  addToApi('Adr.Fin.SummePlan'    ,'');
  addToApi('Adr.Fin.SummeOP.Ext'  ,'');
  addToApi('Adr.Fin.SummeOPB'     ,'');
  addToApi('Adr.Fin.SummeOPB.Ext' ,'');

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
  vAdrNode    : handle;     // Handle für Materialnode

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

  vArgs # VarAllocate(Sel_Args_000004);
  // ... und mit den empfangenen Argumenten füllen

  prepSelInt(aArgs,'Adr.KundenNr', var sel_KundenNrJN,  var sel_KundenNr,  var sel_KundenNrNot,  var sel_KundenNrVon,   var sel_KundenNrBis,   var sel_KundenNrAus);
  prepSelInt(aArgs,'Adr.LieferantenNr',var sel_LiefNrJN, var sel_LiefNr, var sel_LiefNrNot, var sel_LiefNrVon,  var sel_LiefNrBis,  var sel_LiefNrAus);
  prepSelAlpha(aArgs,'Adr.Stichwort',var sel_StichwJN, var sel_Stichw, var sel_StichwNot, var sel_StichwVon,  var sel_StichwBis,  var sel_StichwAus);


  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(100, 1, 'SVC_000004:Sel',vArgs);
  vAnz  # Lib_SOA:RunPartSel(vSel, 0, 0); // Max 0 = alle, RecId 0 = von Anfang an


  // Daten Node zum einfügen extrahieren
  vNode # aResponse->getNode('DATA');

  FOR  Erx # RecRead(100, SOA_PartSel_Sel, _RecFirst);
  LOOP Erx # RecRead(100, SOA_PartSel_Sel, _RecNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    vAdrNode # vNode->addRecord(100);

    case (toUpper(vFelderGrp)) of

      //-------------------------------------------------------------------------------
      'ALLE', '' : begin

        vDatei # 100;
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
            vAdrNode->Lib_XML:AppendNode(toUpper(vFldName),vFldData);

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
          if (StrCut(vFldName,1,4) = 'ADR.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'ADR.STRASSE'           : vFldName #  'Adr.Straße';           // TDS 1: Hauptdaten

                'ADR.EK.WAEHRUNG'       : vFldName #  'Adr.EK.Währung';       // TDS 3: Einkauf

                'ADR.VK.WAEHRUNG'       : vFldName #  'Adr.VK.Währung';       // TDS 4: Verkauf
                'ADR.VK.REEMPFAENGER'   : vFldName #  'Adr.VK.ReEmpfänger';

                'ADR.STEUERSCHLUESSEL'  : vFldName #  'Adr.Steuerschlüssel';  // TDS 5: Zusatz
                'ADR.BONUSEMPFAENGER'   : vFldName #  'Adr.BonusEmpfängerYN';
//                'ADR.BONUSPROZENT'      : vFldName #  'Adr.BonusProz';

                'ADR.AENDERUNG.DATUM'  : vFldName #   'Adr.Änderung.Datum';   // TDS 6: Protokoll
                'ADR.AENDERUNG.ZEIT'   : vFldName #   'Adr.Änderung.Zeit';
                'ADR.AENDERUNG.USER'   : vFldName #   'Adr.Änderung.User';

//                'ADR.FIN.SUMMEABDOLL'  : vFldName #   'Adr.Fin.SummeAB$';     // TDS 7: Finanzdaten
              END;

              // Feld mit "normalem" Namen prüfen
              vErg # FldInfoByName(vFldName,_FldExists);

              // Feld vorhanden?
              if (vErg <> 0) then begin
                // Alle Feldnamen in Großbuchstabenexportieren
                vFldName # toUpper(vFldName);

                 // Wenn vorhanden dann je nach Feldtyp schreiben
                 CASE (FldInfoByName(vFldName,_FldType)) OF
                    _TypeAlpha    : vAdrNode->Lib_SOA:AppendNode(vFldName, FldAlphaByName(vFldName));
                    _TypeBigInt   : vAdrNode->Lib_SOA:AppendNode(vFldName, CnvAb(FldBigIntByName(vFldName)));
                    _TypeDate     : vAdrNode->Lib_SOA:AppendNode(vFldName, CnvAd(FldDateByName(vFldName)));
                    _TypeDecimal  : vAdrNode->Lib_SOA:AppendNode(vFldName, CnvAM(FldDecimalByName(vFldName)));
                    _TypeFloat    : vAdrNode->Lib_SOA:AppendNode(vFldName, CnvAf(FldFloatByName(vFldName)));
                    _TypeInt      : vAdrNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldIntByName(vFldName)));
                    _TypeLogic    : vAdrNode->Lib_SOA:AppendNode(vFldName, CnvAi(CnvIl(FldLogicByName(vFldName))));
                    _TypeTime     : vAdrNode->Lib_SOA:AppendNode(vFldName, CnvAt(FldTimeByName(vFldName)));
                    _TypeWord     : vAdrNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldWordByName(vFldName)));
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
  VarFree(Sel_Args_000004);
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
  VarInstance(Sel_Args_000004, SOA_PartSel_Args);

  if (SelInt  (Adr.KundenNr,      sel_KundenNrJN, sel_KundenNrNot, sel_KundenNrAus, sel_KundenNrVon, sel_KundenNrBis))  then return false;
  if (SelInt  (Adr.LieferantenNr, sel_LiefNrJN, sel_LiefNrNot, sel_LiefNrAus, sel_LiefNrVon, sel_LiefNrBis))  then return false;

  if (SelAlpha(Adr.Stichwort, sel_StichwJN, sel_StichwNot, sel_StichwAus, sel_StichwVon, sel_StichwBis))  then return false;


  return true;
end; // sub Sel() : logic



//=========================================================================
//=========================================================================
//=========================================================================