@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000014
//                  OHNE E_R_G
//  Zu Service: AUF_POS:SEL
//
//  Info
///  AUF_POS_SEL: Lesen von Auftragspositionen und Rückgabe der angegeben Felder
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
global Sel_Args_000014 begin
  Tmp : alpha;

  // Auftragsnummer    Auf.P.Nummer
  sel_AufNrJN  : logic;
  sel_AufNr,
  sel_AufNrVon,
  sel_AufNrBis : int;
  sel_AufNrNot,
  sel_AufNrAus : alpha;

  // Kundennummer       Auf.P.Kundennr
  sel_KundeJN  : logic;
  sel_Kunde,
  sel_KundeVon,
  sel_KundeBis : int;
  sel_KundeNot,
  sel_KundeAus : alpha;

  // Güte                 Auf.P.Güte
  sel_GueteJN  : logic;
  sel_Guete,
  sel_GueteVon,
  sel_GueteBis,
  sel_GueteNot,
  sel_GueteAus : alpha;

  // Wunschtermin         Auf.P.Termin1Wunsch
  sel_TerminW1JN  : logic;
  sel_TerminW1,
  sel_TerminW1Von,
  sel_TerminW1Bis : date;
  sel_TerminW1Not,
  sel_TerminW1Aus : alpha;

  // Bestellnummer      Auf.P.Best.Nummer
  sel_BestNrJN  : logic;
  sel_BestNr,
  sel_BestNrVon,
  sel_BestNrBis,
  sel_BestNrNot,
  sel_BestNrAus : alpha;

  // Dicke       Auf.P.Dicke
  sel_DickeJN  : logic;
  sel_Dicke,
  sel_DickeVon,
  sel_DickeBis : float;
  sel_DickeNot,
  sel_DickeAus : alpha;

  // Breite      Auf.P.Breite
  sel_BreiteJN  : logic;
  sel_Breite,
  sel_BreiteVon,
  sel_BreiteBis : float;
  sel_BreiteNot,
  sel_BreiteAus : alpha;

  // Länge      Auf.P.Länge
  sel_LaengeJN  : logic;
  sel_Laenge,
  sel_LaengeVon,
  sel_LaengeBis : float;
  sel_LaengeNot,
  sel_LaengeAus : alpha;

  // Oberfläche      Auf.P.AusfOben
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

  // Gruppe
  vNode # vApi->apiAdd('FELDER',_TypeAlpha,false,null,null,'ALLE | INDI','ALLE');
  vNode->apiSetDesc('Gewünschte Rückgabewerte; ALLE:jedes Feld; INDI:nur angegebene Felder;','INDI');

  // ----------------------------------
  // Selektionsmöglichlkeiten
  // ----------------------------------
  vNode # vApi->apiAdd('..Mögliche Selektionsfelder',_TypeAlpha,false,null,null,'');
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Auf.P.Nummer, Auf.P.Kundennr, Auf.P.Güte, Auf.P.Termin1Wunsch, Auf.P.Best.Nummer, Auf.P.Dicke, Auf.P.Breite, Auf.P.Länge, Auf.P.AusfOben','');
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
  vArgNode    : handle;

  // Ablaufvariablen
  vErg        : int;        // Ergebnishandle
  vTmp        : alpha;
  vSel        : handle;     // Handle der Selektion
  vAnz        : int;        // Anzahl der gelesen Datensätze

  // Argument, fachliche Seite
  vFelderGrp  : alpha;

  // Rückgabedaten
  vAufPNode    : handle;     // Handle für Ansprechpartnernode

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

  vArgs # VarAllocate(Sel_Args_000014);
  // ... und mit den empfangenen Argumenten füllen

  prepSelInt(aArgs,'Auf.P.Nummer',
                    var sel_AufNrJN,
                    var sel_AufNr,
                    var sel_AufNrNot,
                    var sel_AufNrVon,
                    var sel_AufNrBis,
                    var sel_AufNrAus);

  prepSelInt(aArgs,'Auf.P.Kundennr',
                    var sel_KundeJN,
                    var sel_Kunde,
                    var sel_KundeNot,
                    var sel_KundeVon,
                    var sel_KundeBis,
                    var sel_KundeAus);

  prepSelAlpha(aArgs,'Auf.P.Guete',
                    var sel_GueteJN,
                    var sel_Guete,
                    var sel_GueteNot,
                    var sel_GueteVon,
                    var sel_GueteBis,
                    var sel_GueteAus);

  prepSelDate(aArgs,'Auf.P.Termin1Wunsch',
                    var sel_TerminW1JN,
                    var sel_TerminW1,
                    var sel_TerminW1Not,
                    var sel_TerminW1Von,
                    var sel_TerminW1Bis,
                    var sel_TerminW1Aus);

  prepSelAlpha(aArgs,'Auf.P.Best.Nummer',
                    var sel_BestNrJN,
                    var sel_BestNr,
                    var sel_BestNrNot,
                    var sel_BestNrVon,
                    var sel_BestNrBis,
                    var sel_BestNrAus);

  prepSelAlpha(aArgs,'Auf.P,AusfOben',
                    var sel_AusfObJN,
                    var sel_AusfOb,
                    var sel_AusfObNot,
                    var sel_AusfObVon,
                    var sel_AusfObBis,
                    var sel_AusfObAus);

  prepSelFloat(aArgs,'Auf.P.Dicke',
                    var sel_DickeJN,
                    var sel_Dicke,
                    var sel_DickeNot,
                    var sel_DickeVon,
                    var sel_DickeBis,
                    var sel_DickeAus);

  prepSelFloat(aArgs,'Auf.P.Breite',
                    var sel_BreiteJN,
                    var sel_Breite,
                    var sel_BreiteNot,
                    var sel_BreiteVon,
                    var sel_BreiteBis,
                    var sel_BreiteAus);

  prepSelFloat(aArgs,'Auf.P.Laenge',
                    var sel_LaengeJN,
                    var sel_Laenge,
                    var sel_LaengeNot,
                    var sel_LaengeVon,
                    var sel_LaengeBis,
                    var sel_LaengeAus);

/*
  prepSel...(aArgs,'Auf.P.',
                    var sel_ ... JN,
                    var sel_ ...,
                    var sel_ ... Not,
                    var sel_ ... Von,
                    var sel_ ... Bis,
                    var sel_ ... Aus);
*/


  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000014:Sel',vArgs);
  vAnz  # Lib_SOA:RunPartSel(vSel, 0, 0); // Max 0 = alle, RecId 0 = von Anfang an


  // Daten Node zum einfügen extrahieren
  vNode # aResponse->getNode('DATA');

  FOR  Erx # RecRead(c_DATEI, SOA_PartSel_Sel, _RecFirst);
  LOOP Erx # RecRead(c_DATEI, SOA_PartSel_Sel, _RecNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    vAufPNode # vNode->addRecord(c_DATEI);

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


            vAufPNode->Lib_XML:AppendNode(toUpper(vFldName),vFldData);

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
                    _TypeAlpha    : vAufPNode->Lib_SOA:AppendNode(vFldName, FldAlphaByName(vFldName));
                    _TypeBigInt   : vAufPNode->Lib_SOA:AppendNode(vFldName, CnvAb(FldBigIntByName(vFldName)));
                    _TypeDate     : vAufPNode->Lib_SOA:AppendNode(vFldName, CnvAd(FldDateByName(vFldName)));
                    _TypeDecimal  : vAufPNode->Lib_SOA:AppendNode(vFldName, CnvAM(FldDecimalByName(vFldName)));
                    _TypeFloat    : vAufPNode->Lib_SOA:AppendNode(vFldName, CnvAf(FldFloatByName(vFldName)));
                    _TypeInt      : vAufPNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldIntByName(vFldName)));
                    _TypeLogic    : vAufPNode->Lib_SOA:AppendNode(vFldName, CnvAi(CnvIl(FldLogicByName(vFldName))));
                    _TypeTime     : vAufPNode->Lib_SOA:AppendNode(vFldName, CnvAt(FldTimeByName(vFldName)));
                    _TypeWord     : vAufPNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldWordByName(vFldName)));
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
  VarFree(Sel_Args_000014);
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
  VarInstance(Sel_Args_000014, SOA_PartSel_Args);

  if (SelInt( Auf.P.Nummer,
              sel_AufNrJN,
              sel_AufNrNot,
              sel_AufNrAus,
              sel_AufNrVon,
              sel_AufNrBis)) then return false;

  if (SelInt( Auf.P.KundenNr,
              sel_KundeJN,
              sel_KundeNot,
              sel_KundeAus,
              sel_KundeVon,
              sel_KundeBis)) then return false;

  if (SelAlpha("Auf.P.Güte",
              sel_GueteJN,
              sel_GueteNot,
              sel_GueteAus,
              sel_GueteVon,
              sel_GueteBis)) then return false;

  if (SelDate(Auf.P.Termin1Wunsch,
              sel_TerminW1JN,
              sel_TerminW1Not,
              sel_TerminW1Aus,
              sel_TerminW1Von,
              sel_TerminW1Bis)) then return false;

  if (SelAlpha( Auf.P.Best.Nummer,
              sel_BestNrJN,
              sel_BestNrNot,
              sel_BestNrAus,
              sel_BestNrVon,
              sel_BestNrBis)) then return false;

  if (SelAlpha( Auf.P.AusfOben,
              sel_AusfObJN,
              sel_AusfObNot,
              sel_AusfObAus,
              sel_AusfObVon,
              sel_AusfObBis)) then return false;

  if (SelFloat( Auf.P.Dicke,
              sel_DickeJN,
              sel_DickeNot,
              sel_DickeAus,
              sel_DickeVon,
              sel_DickeBis)) then return false;

  if (SelFloat( Auf.P.Breite,
              sel_BreiteJN,
              sel_BreiteNot,
              sel_BreiteAus,
              sel_BreiteVon,
              sel_BreiteBis)) then return false;

  if (SelFloat("Auf.P.Länge",
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