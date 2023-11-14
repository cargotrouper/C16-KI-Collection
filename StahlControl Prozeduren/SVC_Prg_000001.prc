@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_Prg_000001
//                  OHNE E_R_G
//  Info
//    Stellt die Services für und Implementierungen bereit
//
//
//  14.09.2010  ST  Erstellung der Prozedur
//  27.09.2010  ST  Service: "keyinfo" mit Sortierung, Keyfile und File
//                  implmenentiert
//  01.10.2010  ST  Umstrukturierung
//
//  Subprozeduren
//    sub treeAdd(aTree : handle; vDatei : int; aType : alpha)
//    sub keyinfo_Api() : handle
//    sub keyinfo_Exec(aArgs : handle; var aResponse : handle) : int
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API

define begin
  add(a) : treeAdd(vTree,a,vSort);
end;


//=========================================================================
// sub treeAdd(...)
//
//  Fügt einen Eintrag in einen Sortierbaum hinzu.
//
//  @Param
//    aTree   : handle    // Handle für Sortierte Liste
//    vDatei   : int       // Dateinummer der Tabelle
//    aType   : alpha     // Sortiertyp
//
//  @Return
//    -
//
//=========================================================================
sub treeAdd(aTree : handle; vDatei : int; aType : alpha)
begin
  if (aType='NAME') then
    Lib_Ramsort:add(aTree,FileName(vDatei),vDatei,FileName(vDatei))
  else if (aType='NR') then
    Lib_Ramsort:add(aTree,CnvAi(vDatei),vDatei,FileName(vDatei));
end; // sub treeAdd(aTree : handle; vDatei : int; aType : alpha)



//=========================================================================
// sub keyinfo_Api() : handle
//
//  Definiert die API Beschreibung (Servicevertrag) für den implementierten
//  Service.
//
//  @Return
//    handle                      // Handle auf die XML Struktur
//
//=========================================================================
sub keyinfo_Api() : handle
local begin
  vAPI   : handle;
  vNode : handle;
end
begin

  // Standardapi erstellen
  vApi # apiCreateStd();

  // Speziele Api-Definition ab hier

  // Sortierung
  vNode # vApi->apiAdd('Sort',_TypeAlpha,true,null,null,'NAME | NR');
  vNode->apiSetDesc('Sortierung über Dateinummer oder Dateinamen (NAME | NR)','NAME');


  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub keyinfo_Api() : handle


//=========================================================================
// sub keyinfo_Exec(aArgs : handle; var aResponse : handle) : int
//
//  Führt den Service aus:
//    Gibt alle Schlüsseldateien aus, die über Services zur Verfügung
//    gestellt werden
//
//  @Param
//    aRequestData    : handle    // Handle für die Requestdaten
//    var aAnswerNode : handle    // Referenz auf Antwortstruktur
//
//  @Return
//    int                         // Fehlercode
//
//=========================================================================
sub keyinfo_Exec(aArgs : handle; var aResponse : handle) : int
local begin
  vNode : handle;
  vSort : alpha;

  vTree : handle;
  vItem : handle;
end
begin
  vNode # aResponse->getNode('DATA');

  // Argumente Extrahieren
  vSort # toUpper(GetValue(aArgs,'SORT'));

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Codevereinfachung durch Makros,
  add(810);   // Gruppen
  add(811);   // Anreden
  add(812);   // Länder
  add(813);   // Steuerschlüssel
  add(814);   // Währungen
  add(815);   // Lieferbedingungen
  add(816);   // Zahlungsbedingungen
  add(817);   // Versandarten
  add(818);   // Verwiegungsarten
  add(819);   // Warengruppen
  add(820);   // Materialstatus
  add(821);   // Abteilungen
  add(822);   // Ressourcengruppen
  add(823);   // Instandhaltungsmeldungen
  add(824);   // Instandhaltungsursachen
  add(825);   // Instandhaltungsmaßnahmen
  add(826);   // Artikelgruppen
  add(828);   // Arbeitsgänge
  add(829);   // Skizzen
  add(830);   // Kalkulationen
  add(832);   // Qualitäten (Enthält auch 833 -> Mechanik)
  add(834);   // Abmessungstoleranzen 834 Mto.toleranzen
  add(835);   // Auftragsarten
  add(836);   // BDS Nummern
  add(838);   // Unterlagen
  add(839);   // Zeugnisse
  add(840);   // Etiketten
  add(841);   // Oberflächen
  add(842);   // Aufpreise/Rabatte
  add(846);   // Kostenstellen
  add(847);   // Orte
  add(848);   // Qualitätsstufen
  add(849);   // Reklamationsarten
  add(850);   // Vorgangsstatus
  add(851);   // Fehlercodes
  add(852);   // Zahlungsarten
  add(853);   // Rechnungstypen
  add(854);   // Gegenkonten
  add(855);   // Zeitentypen
  add(856);   // Artikelzustände

  // Durchlaufen und löschen
  vItem # Sort_ItemFirst(vTree);
  WHILE (vItem != 0) do begin

    // Daten an Response anhängen
    vNode->Lib_SOA:AppendNode(FileName(vItem->spID),CnvAi(vItem->spID));

    vTree->Ctedelete(vItem);
    vItem # Sort_ItemFirst(vTree);
  END

  Sort_KillList(vTree);
  return _rOk;
End; // sub keyinfo_Exec(aArgs : handle; var aResponse : handle) : int



//=========================================================================
//=========================================================================
//=========================================================================