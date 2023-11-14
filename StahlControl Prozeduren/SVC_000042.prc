@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000042
//                  OHNE E_R_G
//  Zu Service: MAB_SEL
//
//  Info
///  MAB_SEL: Lesen von Materialdaten aus der Ablage und Rückgabe der angegeben Felder
//
//  21.02.2011  ST  Refakturing
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


// Selektionsstruktur für Service KNDFM
global Sel_Args_000042 begin
  Tmp : alpha;

  sel_DickeJN  : logic;
  sel_Dicke,
  sel_DickeVon,
  sel_DickeBis : float;
  sel_DickeNot,
  sel_DickeAus : alpha;

  sel_BreiteJN  : logic;
  sel_Breite,
  sel_BreiteVon,
  sel_BreiteBis : float;
  sel_BreiteNot,
  sel_BreiteAus : alpha;

  sel_LaengeJN  : logic;
  sel_Laenge,
  sel_LaengeVon,
  sel_LaengeBis : float;
  sel_LaengeNot,
  sel_LaengeAus : alpha;

  sel_StatusJN  : logic;
  sel_Status,
  sel_StatusVon,
  sel_StatusBis : int;
  sel_StatusNot,
  sel_StatusAus : alpha;

  sel_CoilnrJN  : logic;
  sel_Coilnr,
  sel_CoilnrVon,
  sel_CoilnrBis,
  sel_CoilnrNot,
  sel_CoilnrAus : alpha;

  sel_LoeschmarkJN  : logic;
  sel_Loeschmark,
  sel_LoeschmarkVon,
  sel_LoeschmarkBis,
  sel_LoeschmarkNot,
  sel_LoeschmarkAus : alpha;

  sel_GueteJN  : logic;
  sel_Guete,
  sel_GueteVon,
  sel_GueteBis,
  sel_GueteNot,
  sel_GueteAus : alpha;

  sel_Reserviert_GewJN  : logic;
  sel_Reserviert_Gew,
  sel_Reserviert_GewVon,
  sel_Reserviert_GewBis : float;
  sel_Reserviert_GewNot,
  sel_Reserviert_GewAus : alpha;

  sel_Verfuegbar_GewJN  : logic;
  sel_Verfuegbar_Gew,
  sel_Verfuegbar_GewVon,
  sel_Verfuegbar_GewBis : float;
  sel_Verfuegbar_GewNot,
  sel_Verfuegbar_GewAus : alpha;

/*
  Oberfläche
*/


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
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI | ANALYSE ','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder; ANALYSE: nur Analysedaten','INDI');

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------
  // Hauptdaten
  addToApi('Mat.Nummer'           ,'Eindeutige Materialnummer');
  addToApi('Mat.Vorgaenger'       ,'Materialnummer des direkten Vorgängermaterials');
  addToApi('Mat.Urpsrung'         ,'Materialnummer des Urpsrungsmaterials');
  addToApi('Mat.Warengruppe'      ,'WarengruppenID der Materialkarte');
  addToApi('Mat.Guete'            ,'');
  addToApi('Mat.Guetenstufe'      ,'');
  addToApi('Mat.Werkstoffnr'      ,'');
  addToApi('Mat.AusfuehrungOben'  ,'Liste der Oberflächenabkürzungen');
  addToApi('Mat.AusfuehrungUnten' ,'Liste der Oberflächenabkürzungen');
  addToApi('Mat.Coilnummer','');
  addToApi('Mat.Ringnummer','');
  addToApi('Mat.Chargennummer','');
  addToApi('Mat.Werksnummer','');
  addToApi('Mat.EigenmaterialYN','');
  addToApi('Mat.Uebernahmedatum','');
  addToApi('Mat.Dicke','');
  addToApi('Mat.Dicke.Von','');
  addToApi('Mat.Dicke.Bis','');
  addToApi('Mat.DickenTolYN','');
  addToApi('Mat.DickenTol','');
  addToApi('Mat.DickenTol.Von','');
  addToApi('Mat.DickenTol.Bis','');
  addToApi('Mat.Breite','');
  addToApi('Mat.Breite.Von','');
  addToApi('Mat.Breite.Bis','');
  addToApi('Mat.BreitenTolYN','');
  addToApi('Mat.BreitenTol','');
  addToApi('Mat.BreitenTol.Von','');
  addToApi('Mat.BreitenTol.Bis','');
  addToApi('Mat.Laenge','');
  addToApi('Mat.Laenge.Von','');
  addToApi('Mat.Laenge.Bis','');
  addToApi('Mat.LaengenTolYN','');
  addToApi('Mat.LaengenTol','');
  addToApi('Mat.LaengenTol.Von','');
  addToApi('Mat.LaengenTol.Bis','');
  addToApi('Mat.RID','');
  addToApi('Mat.RAD','');
  addToApi('Mat.Kgmm','');
  addToApi('Mat.Dichte','');
  addToApi('Mat.Strukturnr','');
  addToApi('Mat.Intrastatnr','');
  addToApi('Mat.Ursprungsland','');
  addToApi('Mat.Zeugnisart','');
  addToApi('Mat.Zeugnisakte','');
  addToApi('Mat.Kommission','');
  addToApi('Mat.KommKundennr','');
  addToApi('Mat.Bestand.Stk','');
  addToApi('Mat.Bestand.Gew','');
  addToApi('Mat.Bestellt.Stk','');
  addToApi('Mat.Bestellt.Gew','');
  addToApi('Mat.Reserviert.Stk','');
  addToApi('Mat.Reserviert.Gew','');
  addToApi('Mat.Verfuegbar.Stk','');
  addToApi('Mat.Verfuegbar.Gew','');
  addToApi('Mat.Paketnr','');
  addToApi('Mat.EK.Preis','');
  addToApi('Mat.Kosten','');
  addToApi('Mat.EK.Effektiv','');
  addToApi('Mat.Status','');
  addToApi('Mat.Bemerkung1','');
  addToApi('Mat.Bemerkung2','');
  addToApi('Mat.KommKundenSWort','');
  addToApi('Mat.EK.Preis2','');

  // Bewegungsdaten
  addToApi('Mat.Bestellnummer','');
  addToApi('Mat.BestellABNr','');
  addToApi('Mat.Bestelldatum','');
  addToApi('Mat.BestellTermin','');
  addToApi('Mat.Eingangsdatum','');
  addToApi('Mat.Ausgangsdatum','');
  addToApi('Mat.Inventurdatum','');
  addToApi('Mat.Erzeuger','');
  addToApi('Mat.Lieferant','');
  addToApi('Mat.Lageradresse','');
  addToApi('Mat.Lageranschrift','');
  addToApi('Mat.Lagerplatz','');
  addToApi('Mat.VK.Kundennr','');
  addToApi('Mat.VK.Rechnr','');
  addToApi('Mat.VK.Rechdatum','');
  addToApi('Mat.VK.Preis','');
  addToApi('Mat.VK.Gewicht','');
  addToApi('Mat.EK.RechNr','');
  addToApi('Mat.EK.RechDatum','');
  addToApi('Mat.LieferStichwort','');
  addToApi('Mat.LagerStichwort','');
  addToApi('Mat.Bilddatei','');
  addToApi('Mat.Datum.Lagergeld','');
  addToApi('Mat.Datum.Zinsen','');
  addToApi('Mat.Datum.Erzeugt','');

  // Internes
  addToApi('Mat.Loeschmarker','');
  addToApi('Mat.Auftragsnr','');
  addToApi('Mat.Auftragspos','');
  addToApi('Mat.Einkaufsnr','');
  addToApi('Mat.Einkaufspos','');
  addToApi('Mat.QS.Status','');
  addToApi('Mat.QS.Datum','');
  addToApi('Mat.QS.Zeit','');
  addToApi('Mat.QS.User','');
  addToApi('Mat.QS.FehlerYN','');

  // Analyse

  addToApi('Mat.Streckgrenze1','');
  addToApi('Mat.Streckgrenze2','');
  addToApi('Mat.Zugfestigkeit1','');
  addToApi('Mat.Zugfestigkeit2','');
  addToApi('Mat.DehnungA1','');
  addToApi('Mat.DehnungA2','');
  addToApi('Mat.DehnungB1','');
  addToApi('Mat.DehnungB2','');
  addToApi('Mat.RP02_V1','');
  addToApi('Mat.RP02_V2','');
  addToApi('Mat.RP10_V1','');
  addToApi('Mat.RP10_V2','');
  addToApi('Mat.Körnung1','');
  addToApi('Mat.Körnung2','');
  addToApi('Mat.Chemie.C1','');
  addToApi('Mat.Chemie.C2','');
  addToApi('Mat.Chemie.Si1','');
  addToApi('Mat.Chemie.Si2','');
  addToApi('Mat.Chemie.Mn1','');
  addToApi('Mat.Chemie.Mn2','');
  addToApi('Mat.Chemie.P1','');
  addToApi('Mat.Chemie.P2','');
  addToApi('Mat.Chemie.S1','');
  addToApi('Mat.Chemie.S2','');
  addToApi('Mat.Chemie.Al1','');
  addToApi('Mat.Chemie.Al2','');
  addToApi('Mat.Chemie.Cr1','');
  addToApi('Mat.Chemie.Cr2','');
  addToApi('Mat.Chemie.V1','');
  addToApi('Mat.Chemie.V2','');
  addToApi('Mat.Chemie.Nb1','');
  addToApi('Mat.Chemie.Nb2','');
  addToApi('Mat.Chemie.Ti1','');
  addToApi('Mat.Chemie.Ti2','');
  addToApi('Mat.Chemie.N1','');
  addToApi('Mat.Chemie.N2','');
  addToApi('Mat.Chemie.Cu1','');
  addToApi('Mat.Chemie.Cu2','');
  addToApi('Mat.Chemie.Ni1','');
  addToApi('Mat.Chemie.Ni2','');
  addToApi('Mat.Chemie.Mo1','');
  addToApi('Mat.Chemie.Mo2','');
  addToApi('Mat.Chemie.B1','');
  addToApi('Mat.Chemie.B2','');
  addToApi('Mat.HaerteA1','');
  addToApi('Mat.HaerteA2','');
  addToApi('Mat.HaerteB1','');
  addToApi('Mat.HaerteB2','');
  addToApi('Mat.Chemie.Frei1.1','');
  addToApi('Mat.Chemie.Frei1.2','');
  addToApi('Mat.Mech.Sonstiges1','');
  addToApi('Mat.Mech.Sonstiges2','');
  addToApi('Mat.RauigkeitA1','');
  addToApi('Mat.RauigkeitA2','');
  addToApi('Mat.RauigkeitB1','');
  addToApi('Mat.RauigkeitB2','');
  addToApi('Mat.RauigkeitC1','');
  addToApi('Mat.RauigkeitC2','');
  addToApi('Mat.RauigkeitD1','');
  addToApi('Mat.RauigkeitD2','');
  addToApi('Mat.StreckgrenzeB1','');
  addToApi('Mat.StreckgrenzeB2','');
  addToApi('Mat.ZugfestigkeitB1','');
  addToApi('Mat.ZugfestigkeitB2','');
  addToApi('Mat.RP02_B1','');
  addToApi('Mat.RP02_B2','');
  addToApi('Mat.RP10_B1','');
  addToApi('Mat.RP10_B2','');
  addToApi('Mat.KoernungB1','');
  addToApi('Mat.KoernungB2','');

  // Sonstiges
  addToApi('Mat.Gewicht.Netto','');
  addToApi('Mat.Gewicht.Brutto','');
  addToApi('Mat.Verwiegungsart','');
  addToApi('Mat.AbbindungL','');
  addToApi('Mat.AbbindungQ','');
  addToApi('Mat.Zwischenlage','');
  addToApi('Mat.Unterlage','');
  addToApi('Mat.StehendYN','');
  addToApi('Mat.LiegendYN','');
  addToApi('Mat.Nettoabzug','');
  addToApi('Mat.Stapelhoehe','');
  addToApi('Mat.Stapelhoehenabzug','');
  addToApi('Mat.Rechtwinkligkeit','');
  addToApi('Mat.Ebenheit','');
  addToApi('Mat.Saebeligkeit','');
  addToApi('Mat.Etk.Guete','');
  addToApi('Mat.Etk.Dicke','');
  addToApi('Mat.Etk.Breite','');
  addToApi('Mat.Etk.Laenge','');
  addToApi('Mat.Analysenummer','');
  addToApi('Mat.Etikettentyp','');
  addToApi('Mat.Umverpackung','');
  addToApi('Mat.Wicklung','');

  // Protokoll
  addToApi('Mat.Anlage.Datum','');
  addToApi('Mat.Anlage.Zeit','');
  addToApi('Mat.Anlage.User','');
  addToApi('Mat.Loesch.Datum','');
  addToApi('Mat.Loesch.Zeit','');
  addToApi('Mat.Loesch.User','');
  addToApi('Mat.Loesch.Grund','');

  // Custom
  addToApi('Mat.Cust.Sort','');

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
  vMatNode    : handle;     // Handle für Materialnode

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

  vArgs # VarAllocate(Sel_Args_000042);
  // ... und mit den empfangenen Argumenten füllen

  prepSelFloat(aArgs,'Mat.Dicke', var sel_DickeJN,  var sel_Dicke,  var sel_DickeNot,  var sel_DickeVon,   var sel_DickeBis,   var sel_DickeAus);
  prepSelFloat(aArgs,'Mat.Breite',var sel_BreiteJN, var sel_Breite, var sel_BreiteNot, var sel_BreiteVon,  var sel_BreiteBis,  var sel_BreiteAus);
  prepSelFloat(aArgs,'Mat.Laenge',var sel_LaengeJN, var sel_Laenge, var sel_LaengeNot, var sel_LaengeVon,  var sel_LaengeBis,  var sel_LaengeAus);
  prepSelFloat(aArgs,'Mat.Reserviert.Gew',var sel_Reserviert_GewJN, var sel_Reserviert_Gew, var sel_Reserviert_GewNot, var sel_Reserviert_GewVon,  var sel_Reserviert_GewBis,  var sel_Reserviert_GewAus);
  prepSelFloat(aArgs,'Mat.Verfuegbar.Gew',var sel_Verfuegbar_GewJN, var sel_Verfuegbar_Gew, var sel_Verfuegbar_GewNot, var sel_Verfuegbar_GewVon,  var sel_Verfuegbar_GewBis,  var sel_Verfuegbar_GewAus);

  prepSelInt(  aArgs,'Mat.Status',var sel_StatusJN, var sel_Status, var sel_StatusNot, var sel_StatusVon,  var sel_StatusBis,  var sel_StatusAus);

  prepSelAlpha(aArgs,'Mat.Coilnummer',var sel_CoilnrJN, var sel_Coilnr, var sel_CoilnrNot, var sel_CoilnrVon,  var sel_CoilnrBis,  var sel_CoilnrAus);
  prepSelAlpha(aArgs,'Mat.Loeschmarker',var sel_LoeschmarkJN, var sel_Loeschmark, var sel_LoeschmarkNot, var sel_LoeschmarkVon,  var sel_LoeschmarkBis,  var sel_LoeschmarkAus);
  prepSelAlpha(aArgs,'Mat.Guete',var sel_GueteJN, var sel_Guete, var sel_GueteNot, var sel_GueteVon,  var sel_GueteBis,  var sel_GueteAus);


  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(210, 1, 'SVC_000042:Sel',vArgs);
  vAnz  # Lib_SOA:RunPartSel(vSel, 0, 0); // Max 0 = alle, RecId 0 = von Anfang an


  // Daten Node zum einfügen extrahieren
  vNode # aResponse->getNode('DATA');

  FOR  Erx # RecRead(210, SOA_PartSel_Sel, _RecFirst);
  LOOP Erx # RecRead(210, SOA_PartSel_Sel, _RecNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    vMatNode # vNode->addRecord(210);

    case (toUpper(vFelderGrp)) of

      //-------------------------------------------------------------------------------
      'ALLE', '' : begin

        vDatei # 210;
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
            vMatNode->Lib_XML:AppendNode(toUpper(vFldName),vFldData);

          END; // Felder durchgehen

        END; // // Teildatensätze durchgehen


      end;

      //-------------------------------------------------------------------------------
      'ANALYSE' : begin

        vDatei # 210;
        vTds # 4;

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
          vMatNode->Lib_XML:AppendNode(toUpper(vFldName),vFldData);

        END; // Felder durchgehen

      end;


      //-------------------------------------------------------------------------------
      'INDI' : begin
        // Argumente durchsuchen und nach gewünschten Feldnamen suchen
        FOR  vArgNode # aArgs->CteRead(_CteFirst | _CteChildList)
        LOOP vArgNode # aArgs->CteRead(_CteNext  | _CteChildList, vArgNode)
        WHILE (vArgNode > 0) do begin

          vFldName # toUpper(vArgNode->spName);
          if (StrCut(vFldName,1,4) = 'MAT.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

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


              // Feldpräfixe auf Ablage umbauen
              vFldName # Str_ReplaceAll(vFldName,'Mat.', 'Mat~');

              // Feld mit "normalem" Namen prüfen
              vErg # FldInfoByName(vFldName,_FldExists);

              // Feld vorhanden?
              if (vErg <> 0) then begin
                // Alle Feldnamen in Großbuchstabenexportieren
                vFldName # toUpper(vFldName);

                 // Wenn vorhanden dann je nach Feldtyp schreiben
                 CASE (FldInfoByName(vFldName,_FldType)) OF
                    _TypeAlpha    : vMatNode->Lib_SOA:AppendNode(vFldName, FldAlphaByName(vFldName));
                    _TypeBigInt   : vMatNode->Lib_SOA:AppendNode(vFldName, CnvAb(FldBigIntByName(vFldName)));
                    _TypeDate     : vMatNode->Lib_SOA:AppendNode(vFldName, CnvAd(FldDateByName(vFldName)));
                    _TypeDecimal  : vMatNode->Lib_SOA:AppendNode(vFldName, CnvAM(FldDecimalByName(vFldName)));
                    _TypeFloat    : vMatNode->Lib_SOA:AppendNode(vFldName, CnvAf(FldFloatByName(vFldName)));
                    _TypeInt      : vMatNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldIntByName(vFldName)));
                    _TypeLogic    : vMatNode->Lib_SOA:AppendNode(vFldName, CnvAi(CnvIl(FldLogicByName(vFldName))));
                    _TypeTime     : vMatNode->Lib_SOA:AppendNode(vFldName, CnvAt(FldTimeByName(vFldName)));
                    _TypeWord     : vMatNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldWordByName(vFldName)));
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
  VarFree(Sel_Args_000042);
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
  VarInstance(Sel_Args_000042, SOA_PartSel_Args);

  if (SelFloat("Mat~Dicke",   sel_DickeJN,  sel_DickeNot,  sel_DickeAus,  sel_DickeVon,  sel_DickeBis))   then return false;
  if (SelFloat("Mat~Breite",  sel_BreiteJN, sel_BreiteNot, sel_BreiteAus, sel_BreiteVon, sel_BreiteBis))  then return false;
  if (SelFloat("Mat~Länge", sel_LaengeJN, sel_LaengeNot, sel_LaengeAus, sel_LaengeVon, sel_LaengeBis))  then return false;
  if (SelFloat("Mat~Reserviert.Gew", sel_Reserviert_GewJN, sel_Reserviert_GewNot, sel_Reserviert_GewAus, sel_Reserviert_GewVon, sel_Reserviert_GewBis))  then return false;
  if (SelFloat("Mat~Verfügbar.Gew", sel_Verfuegbar_GewJN, sel_Verfuegbar_GewNot, sel_Verfuegbar_GewAus, sel_Verfuegbar_GewVon, sel_Verfuegbar_GewBis))  then return false;

  if (SelInt  ("Mat~Status",  sel_StatusJN, sel_StatusNot, sel_StatusAus, sel_StatusVon, sel_StatusBis))  then return false;

  if (SelAlpha("Mat~Coilnummer", sel_CoilnrJN, sel_CoilnrNot, sel_CoilnrAus, sel_CoilnrVon, sel_CoilnrBis))  then return false;
  if (SelAlpha("Mat~Löschmarker", sel_LoeschmarkJN, sel_LoeschmarkNot, sel_LoeschmarkAus, sel_LoeschmarkVon, sel_LoeschmarkBis))  then return false;
  if (SelAlpha("Mat~Güte", sel_GueteJN, sel_GueteNot, sel_GueteAus, sel_GueteVon, sel_GueteBis))  then return false;

  return true;
end; // sub Sel() : logic



//=========================================================================
//=========================================================================
//=========================================================================