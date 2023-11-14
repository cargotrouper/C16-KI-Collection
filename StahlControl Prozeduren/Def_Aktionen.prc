@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_Aktionen
//                    OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  22.08.2016  AH  "Schrottnullung"
//  20.10.2016  AH  VSBEK
//  02.11.2016  AH  GuBe-Zuordnung
//  20.09.2018  AH  Neu "VSB-Konsi-Rahmen"
//  11.06.2021  ST  Neue Warengruppenmaterialart: ART für Artikel
//  14.06.2022  AH  Typ Flachring + Ronde
//
//  Subprozeduren
//
//========================================================================

define begin

  // Versandpool
  c_VSPTyp_Auf        : 'AUF'       // Auftrag/VSB-VK
  c_VSPTyp_Ein        : 'EIN'       // Einkauf/VSB-EK
  c_VSPTyp_BAG        : 'BAG'       // Betriebsauftrag/Umlagern
  c_VSPTyp_Mat        : 'MAT'       // Lagermaterial umlagern
  c_VSPTyp_Pak        : 'PAK'       // Paket umlagern

  // Warengruppe
  c_WGRTyp_Coil       : 'CO'
  c_WGRTyp_Tafel      : 'TA'
  c_WGRTyp_Stab       : 'ST'
  c_WGRTyp_Rohr       : 'RO'
  c_WGRTyp_Profil     : 'PR'
  c_WGRTyp_Artikel    : 'AR'
  c_WGRTyp_Flachring  : 'FR'
  c_WGRTyp_Ronde      : 'RONDE'

  // Materialaktionen
  c_Akt_Info          : 'INFO'      // Information
  c_Akt_Man           : 'MAN'       // Manuell
  c_Akt_Kalk          : 'KOST'      // Kosten aus Kalkulation
  c_Akt_Aufpreis      : 'AFPRS'     // Kosten aus Aufpreise
  c_Akt_ERAP          : 'ER-AP'     // Kosten aus Aufpreise aus Eingangsrechnung
  c_Akt_Split         : 'SPLIT'     // Splittung
  c_Akt_RV            : 'RES'       // Reservierung
  c_Akt_GPL           : 'GPL'       // Grobplanung
  c_Akt_BAInput       : 'BAG'       // BAG Einsatz (für VSB Material)
  c_Akt_Mat_Umlage    : 'UMLAG'     // Umlagekosten
  c_Akt_Mat_Kombi     : 'KOMBI'     // Kombination
  c_Akt_Lagergeld     : 'LG'        // LAgergeld
  c_Akt_Zinsen        : 'ZG'        // Zinsen
  c_Akt_Sondererloes  : 'SERL'      // Sondererlös
  c_Akt_Move          : 'MOVE'      // Umlagern
  c_Akt_Schrott       : 'SCHRT'     // Schrott
  c_Akt_WE            : 'WE'        // Wareneingang
  c_Akt_Status        : 'STUS'      // Statusänderung

  // Aktionstypen
  c_Akt_VSB           : 'VSB'       // Materialzuordnung
  c_Akt_VsbPool       : 'VSBPO'     // Materialzuordnung im VersandPool
  c_Akt_VSBEK         : 'VSBEK'     // Materialzuordnung wenn Material noch im EK als VSB
  c_Akt_Prd_Plan      : 'PR S'      // Auftragsproduktions erwartete Menge
  c_Akt_Prd_Fertig    : 'PR I'      // Auftragsproduktions produzierte Menge
  c_Akt_Prd_Verbrauch : 'PR V'      // Auftragsproduktions Verbrauch

  c_Akt_Angebot       : 'ANG'       // Angebot
  c_Akt_Anfrage       : 'ANF'       // Anfrage
  c_Akt_Storniert     : 'STORN'     // stornierter Auftrag
  c_Akt_LFE           : 'LFE'       // Lieferantenerklärung erzeugt
  c_Akt_VLDAW         : 'VLDAW'     // Verlade-Anweisung / ungebuchter LFS
  c_Akt_RVLDAW        : 'RÜCK'      // RÜCKNAHME Verlade-Anweisung / ungebuchter LFS
  c_Akt_LFS           : 'LFS'       // verbuchter Lieferschein
  c_Akt_LFS_VPG       : 'VLFS'      // verbuchter Lieferschein Verpackung
  c_Akt_RLFS          : 'RLFS'      // verbuchter Rücknahme-Lieferschein
  c_Akt_KLFS          : 'KLFS'      // umkommissionierter Lieferschein
  c_Akt_Abruf         : 'ABRUF'     // Abrufauftrag
  c_Akt_PAbruf        : 'CACHE'     // Puffer-Abrufauftrag
  c_Akt_AbrufSL       : 'ABRSL'     // Abrufauftrag-Stückliste
  c_Akt_Druck         : 'DRUCK'     // Ausdruck erzeugt
  c_Akt_Sperre        : 'SPERR'     // Vorgang gesperrt (z.B. WoF, Kreditlimit)
  c_Akt_Ang2Auf       : '>>AUF'     // Angebot wurde Auftrag
  c_Akt_Anf2Best      : '>>BES'     // Anfrage wurde Bestellung
  c_Akt_Dfakt         : 'DFAKT'     // direkte Fakturierung
  c_Akt_DfaktGut      : 'GUT'       // direkte Fakturierung Gutschrift
  c_Akt_DfaktBel      : 'BEL'       // direkte Fakturierung Belastung
  c_Akt_Kasse         : 'KASSE'     // Freigae bei Vorkasse
  c_Akt_sieheReKor    : '>REKO'     // Rechnungskorrektur vorhanden
  c_Akt_sieheBel      : '>BEL'      // Belastung vorhanden
  c_Akt_GbMat         : 'GBMAT'     // Gutschrifts/Belastungs-Material
  c_Akt_EreMat        : 'ER'        // Eingangsrechnung
  c_Akt_LfsFrei       : 'LFSFG'     // Lieferscheinfreigabe

  c_Akt_EKK           : 'EKK'       // Einkaufskontrolle

  c_Akt_StornoLFS     : '*LFS'      // stornierter Lieferschein
//  c_Akt_StornoVSB     : '*VSB'      // stornierte Materialzuordnung
  c_Akt_StornoDFAKT   : '*DFAK'     // stornierte direkte Fakturierung

  c_Akt_Bestellung    : 'EK S'      // EK-Bestellung
  c_Akt_Wareneingang  : 'EK FM'     // EK-Wareneingang

  c_Akt_Reklamation   : 'REKL'      // Reklamation

  c_Akt_BA            : 'BA'        // gesamter BA für einen Auftrag (Lohnarbeit)
  c_Akt_BA_Plan       : 'BA S'      // geplante Menge aus BA
  c_Akt_BA_Plan_Fahr  : 'BA FA'     // geplante Fahrmenge
  c_Akt_BA_Fertig     : 'BA FM'     // produzierte Menge aus BA
//  c_Akt_BA_FertigKombi : 'BA+FM'    // produzierte Menge aus BA
  c_Akt_BA_Ausfall    : 'BA A'      // gesperrte/ausgefallene Menge aus BA
  c_Akt_BA_Einsatz    : 'BA IN'     // Einsatzmaterial
  c_Akt_BA_Rest       : 'BA RE'     // Restkarte
  c_Akt_BA_Kosten     : 'BA KO'     // Kosten

  c_Akt_BA_UmlagePLUS   : 'BA+UM'     // Schrottumlage
  c_Akt_BA_UmlageMINUS  : 'BA-UM'     // Schrottumlage
  c_Akt_BA_Schrott      : 'BA-AB'     // Schrottumlage ABWERTUNG bei Planschrott
  c_Akt_BA_Verbrauch    : 'BA V'      // Verbrauch
  c_Akt_BA_Beistell     : 'BA BS'     // Beistellungen

  // Bemerkungen zu Aktionen
  c_AktBem_AB             : 'Auftragsbestätigung'
  c_AktBem_Angebot        : 'Angebot'
  c_AktBem_Anfrage        : 'Anfrage'
  c_AktBem_Bestell        : 'Bestellung Rest'
  c_AktBem_Storniert      : 'Storniert'
  c_AktBem_PRD_Plan       : 'Soll-Menge'
  c_AktBem_PRD_Verbrauch  : 'verbraucht für Prd.'
  c_AktBem_BA_Plan        : 'Rest-Soll-Menge'
  c_AktBem_BA_Plan_Fahr   : 'Fahrauftrag Soll-Menge'
  c_AktBem_BA_Fertig      : 'Fertigmeldung'
  c_AktBem_BA             : 'Lohn-Arbeitsgang'
  c_AktBem_RV             : 'Reservierung'
  c_AktBem_Schrott        : 'manueller Schrott'
  c_AktBem_Sperre_Kredit  : 'Kreditlimit'
  c_AktBem_BA_Verbrauch   : 'verbraucht für BA'
  c_AktBem_VSB            : 'versandbereite Ware'
  c_AktBem_VsbPool        : 'VSB im Versandpool'
  c_AktBem_VSBEK          : 'versandbereite Ware im Zulauf'
  c_AktBem_DFakt          : 'direkte Fakturierung'
  c_AktBem_StornoDFakt    : 'Storno direkte Fakturierung'
  c_AktBem_BA_Kosten      : 'Produktionskosten'
  c_AktBem_BA_Umlage      : 'Schrottumlage'
  c_AktBem_BA_Nullung     : 'Schrottnullung'
  c_AktBem_BA_Fahr        : 'Fahrauftrag'
  c_AktBem_KLFS           : 'neue Kommission:'
  c_AktBem_VorKasse       : 'Vorkasse'
  c_AktBem_Mat_Gegenbuch  : 'Gegenbuchung'
  c_AktBem_Mat_Schrott    : 'Schrottumlage'
  c_AktBem_sieheReKor     : 'zugehörige Rechnungskorrektur'
  c_AktBem_sieheBel       : 'zugehörige Belastung'
  c_AktBem_Lagergeld      : 'Lagergeld'
  c_AktBem_Zinsen         : 'Zinsen'
  c_AktBem_Mat_Umlage     : 'Umlagekosten'
  c_AktBem_Move           : 'Umlagerung'
  c_AktBem_GbMat          : 'Gutschrift/Belastungs-Material'
  c_AktBem_EreMat         : 'Eingangsrechnung'
  c_AktBem_EKK            : 'Einkaufskontrolle'
  c_AktBem_LfsFrei        : 'Lieferscheinfreigabe'

  c_AktBem_BAEinsatz      : 'Einsatzmaterial'
  c_AktBem_BARest         : 'Restmaterial'
  c_AktBem_BABeistell     : 'Beistellungen'

  c_AktBem_Reklamation    : 'Reklamation'


  // STATUS IM MATERIAL
  c_status_Frei           : 1
  c_status_bisFrei        : 99
  c_Status_manuellerSchrott : 299
  c_Status_VSB            : 400
  c_Status_VSBKonsi       : 401
  c_Status_VSBPuffer      : 402
  c_Status_VSBRahmen      : 403
  c_Status_VSBKonsiRahmen : 404

  c_Status_inVLDAW        : 440
  c_Status_geliefert      : 441
  c_Status_LFSRueck       : 449
  c_Status_Verkauft       : 450
  c_Status_bestellt       : 500
  c_Status_EKWE           : 501
  c_Status_EKVSB          : 502
  c_Status_EK_Konsi       : 503
  c_Status_bestellt_Sperr : 597
  c_Status_EK_Storno      : 598
  c_Status_EK_Ausfall     : 599
  c_status_bisEK          : 599

  c_Status_Versand        : 650
  c_Status_VersandDel     : 651

  c_Status_BAG            : 700
  c_Status_bisBAG         : 799
  c_Status_BAGInput       : 700
  c_Status_BAGZumFahren   : 703
  c_Status_BAGBereitgestellt : 715
  c_Status_BAGOutput      : 750
  c_Status_BAGOutFertig   : 751
  c_Status_BAGOutKunde    : 752
  c_Status_BAGfertUnklar  : 758
  c_Status_BAGfertSperre  : 759

  c_Status_BAGRestFahren  : 770

  c_Status_BAGSchrott     : 797   // ST 2009-08-13 für Projekt 1161/95
  c_Status_BAGAusfall     : 798
  c_Status_BAGVerschnitt  : 799

  c_status_Sonder         : 800
  c_status_bisSonder      : 899

  c_Status_gesperrt       : 900
  c_Status_EKgesperrt     : 950
  c_Status_EKgesperrtBetrieb  : 951

end;

//========================================================================