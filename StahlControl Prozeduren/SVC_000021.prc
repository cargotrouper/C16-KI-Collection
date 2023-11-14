@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000021
//                  OHNE E_R_G
//  Zu Service: EIN_POS:SEL
//
//  Info
///  EIN_POS_SEL: Lesen von Bestellositionen und Rückgabe der angegeben Felder
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
global Sel_Args_000021 begin
  Tmp : alpha;

  // Betellnummer         Ein.P.Nummer
  sel_EinNrJN  : logic;
  sel_EinNr,
  sel_EinNrVon,
  sel_EinNrBis : int;
  sel_EinNrNot,
  sel_EinNrAus : alpha;

  // Kundennummer         Ein.P.Lieferantennr
  sel_LiefNrJN  : logic;
  sel_LiefNr,
  sel_LiefNrVon,
  sel_LiefNrBis : int;
  sel_LiefNrNot,
  sel_LiefNrAus : alpha;

  // Güte                 Ein.P.Güte
  sel_GueteJN  : logic;
  sel_Guete,
  sel_GueteVon,
  sel_GueteBis,
  sel_GueteNot,
  sel_GueteAus : alpha;

  // Wunschtermin         Ein.P.Termin1Wunsch
  sel_TerminW1JN  : logic;
  sel_TerminW1,
  sel_TerminW1Von,
  sel_TerminW1Bis : date;
  sel_TerminW1Not,
  sel_TerminW1Aus : alpha;

  // AB Nummer            Ein.P.AB.Nummer
  sel_ABNrJN  : logic;
  sel_ABNr,
  sel_ABNrVon,
  sel_ABNrBis,
  sel_ABNrNot,
  sel_ABNrAus : alpha;

  // Dicke                Ein.P.Dicke
  sel_DickeJN  : logic;
  sel_Dicke,
  sel_DickeVon,
  sel_DickeBis : float;
  sel_DickeNot,
  sel_DickeAus : alpha;

  // Breite               Ein.P.Breite
  sel_BreiteJN  : logic;
  sel_Breite,
  sel_BreiteVon,
  sel_BreiteBis : float;
  sel_BreiteNot,
  sel_BreiteAus : alpha;

  // Länge                Ein.P.Länge
  sel_LaengeJN  : logic;
  sel_Laenge,
  sel_LaengeVon,
  sel_LaengeBis : float;
  sel_LaengeNot,
  sel_LaengeAus : alpha;

  // Oberfläche           Ein.P.AusfOben
  sel_AusfObJN  : logic;
  sel_AusfOb,
  sel_AusfObVon,
  sel_AusfObBis,
  sel_AusfObNot,
  sel_AusfObAus : alpha;

end;

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

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Selektionsmöglichlkeiten
  // ----------------------------------
  vNode # vApi->apiAdd('..Mögliche Selektionsfelder',_TypeAlpha,false,null,null,'');
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Ein.P.Nummer, Ein.P.Lieferantennr, Ein.P.Güte, Ein.P.Termin1Wunsch, Ein.P.AB.Nummer, Ein.P.Dicke, Ein.P.Breite, Ein.P.Länge, Ein.P.AusfOben','');
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
  vArgNode    : handle;

  // Ablaufvariablen
  vErg        : int;        // Ergebnishandle
  vTmp        : alpha;
  vSel        : handle;     // Handle der Selektion
  vAnz        : int;        // Anzahl der gelesen Datensätze

  // Argument, fachliche Seite
  vFelderGrp  : alpha;

  // Rückgabedaten
  vResNode    : handle;     // Handle für Responsenode

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

  vArgs # VarAllocate(Sel_Args_000021);
  // ... und mit den empfangenen Argumenten füllen

  prepSelInt(aArgs,'Ein.P.Nummer',
                    var sel_EinNrJN,
                    var sel_EinNr,
                    var sel_EinNrNot,
                    var sel_EinNrVon,
                    var sel_EinNrBis,
                    var sel_EinNrAus);

  prepSelInt(aArgs,'Ein.P.Lieferantennr',
                    var sel_LiefNrJN,
                    var sel_LiefNr,
                    var sel_LiefNrNot,
                    var sel_LiefNrVon,
                    var sel_LiefNrBis,
                    var sel_LiefNrAus);

  prepSelAlpha(aArgs,'Ein.P.Guete',
                    var sel_GueteJN,
                    var sel_Guete,
                    var sel_GueteNot,
                    var sel_GueteVon,
                    var sel_GueteBis,
                    var sel_GueteAus);

  prepSelDate(aArgs,'Ein.P.Termin1Wunsch',
                    var sel_TerminW1JN,
                    var sel_TerminW1,
                    var sel_TerminW1Not,
                    var sel_TerminW1Von,
                    var sel_TerminW1Bis,
                    var sel_TerminW1Aus);

  prepSelAlpha(aArgs,'Ein.P.AB.Nummer',
                    var sel_ABNrJN,
                    var sel_ABNr,
                    var sel_ABNrNot,
                    var sel_ABNrVon,
                    var sel_ABNrBis,
                    var sel_ABNrAus);

  prepSelAlpha(aArgs,'Ein.P,AusfOben',
                    var sel_AusfObJN,
                    var sel_AusfOb,
                    var sel_AusfObNot,
                    var sel_AusfObVon,
                    var sel_AusfObBis,
                    var sel_AusfObAus);

  prepSelFloat(aArgs,'Ein.P.Dicke',
                    var sel_DickeJN,
                    var sel_Dicke,
                    var sel_DickeNot,
                    var sel_DickeVon,
                    var sel_DickeBis,
                    var sel_DickeAus);

  prepSelFloat(aArgs,'Ein.P.Breite',
                    var sel_BreiteJN,
                    var sel_Breite,
                    var sel_BreiteNot,
                    var sel_BreiteVon,
                    var sel_BreiteBis,
                    var sel_BreiteAus);

  prepSelFloat(aArgs,'Ein.P.Laenge',
                    var sel_LaengeJN,
                    var sel_Laenge,
                    var sel_LaengeNot,
                    var sel_LaengeVon,
                    var sel_LaengeBis,
                    var sel_LaengeAus);

/*
  prepSel...(aArgs,'Auf.P.',
                    var sel_ ... JN
                    var sel_ ...,
                    var sel_ ... Not,
                    var sel_ ... Von,
                    var sel_ ... Bis,
                    var sel_ ... Aus);
*/


  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000021:Sel',vArgs);
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
        FOR  vArgNode # aArgs->CteRead(_CteFirst | _CteChildList)
        LOOP vArgNode # aArgs->CteRead(_CteNext  | _CteChildList, vArgNode)
        WHILE (vArgNode > 0) do begin

          vFldName # toUpper(vArgNode->spName);
          if (StrCut(vFldName,1,4) = 'EIN.') then begin

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
                'EIN.P.SAEBELPROM'      : vFldName #  'Ein.P.SäbelProM';
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
dbg('Feld gibts nicht: ' + vFldName);
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
  VarFree(Sel_Args_000021);
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
  VarInstance(Sel_Args_000021, SOA_PartSel_Args);

  if (SelInt( Ein.P.Nummer,
              sel_EinNrJN,
              sel_EinNrNot,
              sel_EinNrAus,
              sel_EinNrVon,
              sel_EinNrBis)) then return false;

  if (SelInt( Ein.P.Lieferantennr,
              sel_LiefNrJN,
              sel_LiefNrNot,
              sel_LiefNrAus,
              sel_LiefNrVon,
              sel_LiefNrBis)) then return false;

  if (SelAlpha("Ein.P.Güte",
              sel_GueteJN,
              sel_GueteNot,
              sel_GueteAus,
              sel_GueteVon,
              sel_GueteBis)) then return false;

  if (SelDate(Ein.P.Termin1Wunsch,
              sel_TerminW1JN,
              sel_TerminW1Not,
              sel_TerminW1Aus,
              sel_TerminW1Von,
              sel_TerminW1Bis)) then return false;

  if (SelAlpha( Ein.P.AB.Nummer,
              sel_ABNrJN,
              sel_ABNrNot,
              sel_ABNrAus,
              sel_ABNrVon,
              sel_ABNrBis)) then return false;

  if (SelAlpha( Ein.P.AusfOben,
              sel_AusfObJN,
              sel_AusfObNot,
              sel_AusfObAus,
              sel_AusfObVon,
              sel_AusfObBis)) then return false;

  if (SelFloat( Ein.P.Dicke,
              sel_DickeJN,
              sel_DickeNot,
              sel_DickeAus,
              sel_DickeVon,
              sel_DickeBis)) then return false;

  if (SelFloat( Ein.P.Breite,
              sel_BreiteJN,
              sel_BreiteNot,
              sel_BreiteAus,
              sel_BreiteVon,
              sel_BreiteBis)) then return false;

  if (SelFloat("Ein.P.Länge",
              sel_LaengeJN,
              sel_LaengeNot,
              sel_LaengeAus,
              sel_LaengeVon,
              sel_LaengeBis)) then return false;

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