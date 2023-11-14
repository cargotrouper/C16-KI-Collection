@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_BAG
//                    OHNE E_R_G
//  Info
//
//
//  05.10.2004  AI  Erstellung der Prozedur
//  28.07.2015  AH  Arbeitsgang Schaelen
//  15.03.2016  AH  Neu: Feld "BAG.P.Status"
//  17.01.2018  ST  Neu: Arbeitsgang "Umlagern"
//  07.06.2022  AH  Neu: WalzSpulen
//
//  Subprozeduren
//
//========================================================================

define begin
  // Status
  c_BAGStatus_Offen   :  'IN ARBEIT'
  c_BAGStatus_Fertig  :  'ABGESCHLOSSEN'
  c_BAGStatus_Anfrage :  'IN ANFRAGE'
  c_BAGStatus_Sperre  :  'GESPERRT'

  // IO-Typen
  c_IO_Mat      : 200
  c_IO_Beistell : 249
  c_IO_Art      : 250
  c_IO_VPG      : 251
  c_IO_BAG      : 703
  c_IO_VSB      : 506
  c_IO_Theo     : 1200

  // Artikeltypen
  c_Art_HDL     : 'HDL'
  c_Art_PRD     : 'PRD'
  c_Art_CUT     : 'ABM'
  c_Art_VPG     : 'VPG'
  c_Art_BGR     : 'BGR'
  c_Art_EXP     : 'EXP'
  c_Art_SET     : 'SET'

  // Aktionstypen
  c_BAG_AbCoil  : 'ABCOIL'      // Abcoilen
  c_BAG_AbLaeng : 'ABLÄNG'      // Ablängen
  c_BAG_ArtPrd  : 'ARTPRD'      // Artikel-Produktion
  c_BAG_Bereit  : 'BEREIT'      // Bereitstellung
  c_BAG_Custom  : 'CUSTOM'      // CUSTOM
  c_BAG_MatPrd  : 'MATPRD'      // Material-Produktion
  c_BAG_Divers  : 'DIVERS'      // Diverses
  c_BAG_Fahr    : 'FAHR'        // Fahren
  c_BAG_Fahr09  : 'FAHR'        // Fahren
  c_BAG_Umlager : 'UMLAG'       // Umlagern
  c_BAG_Versand : 'VERSND'      // Versand
  c_BAG_Kant    : 'KANTE'       // Kantenbeareitung
  c_BAG_Obf     : 'OBF'         // Oberfächenbearbeitung
  c_BAG_Gluehen : 'GLUEHE'      // Glühen     19.05.2022 AH
  c_BAG_Pack    : 'PACK'        // Verpacken
  c_BAG_Paket   : 'PAKET'       // Paketierung
  c_BAG_QTeil   : 'QTEIL'       // Querteilen
  c_BAG_Saegen  : 'SAEGEN'      // Sägen(Rohre)
  c_BAG_Spalt   : 'SPALT'       // Spalten
  c_BAG_Split   : 'SPLIT'       // Splitten
  c_BAG_Spulen  : 'SPULEN'      // Spulen
  c_BAG_SpaltSpulen : 'SPSPUL'  // SpaltSpulen
  c_BAG_WalzSpulen  : 'WASPUL'  // WalzSpulen
  c_BAG_Tafel   : 'TAFEL'       // Tafeln
  c_BAG_Check   : 'CHECK'       // Check/Prüfen/Analyse
  c_BAG_VSB     : 'VSB'         // VSB/Lager
  c_BAG_Walz    : 'WALZ'        // Walzen
  c_BAG_Schael  : 'SCHAEL'      // Schälen
  c_BAG_Messen  : 'MESSEN'      // Messen

end;

//========================================================================