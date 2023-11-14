@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000026
//                  OHNE E_R_G
//  Zu Service: LFS_SEL
//
//  Info
///  LFS_SEL: Lesen von Lieferscheinkopfdaten und Rückgabe der angegeben Felder
//
//  17.02.2011  ST  Erstellung der Prozedur
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
global Sel_Args_000026 begin
  Tmp : alpha;

  // Lieferscheinnr    Lfs.Nummer
  sel_LfsNrJN  : logic;
  sel_LfsNr,
  sel_LfsNrVon,
  sel_LfsNrBis : int;
  sel_LfsNrNot,
  sel_LfsNrAus : alpha;

  // Lieferdatum      Lfs.Lieferdatum
  sel_LfsDatJN  : logic;
  sel_LfsDat,
  sel_LfsDatVon,
  sel_LfsDatBis : date;
  sel_LfsDatNot,
  sel_LfsDatAus : alpha;

  // Kundennummer       Lfs.Kundennummer
  sel_KundeJN  : logic;
  sel_Kunde,
  sel_KundeVon,
  sel_KundeBis : int;
  sel_KundeNot,
  sel_KundeAus : alpha;

  // Lieferadresse    Lfs.Zieladresse
  sel_LiefAdrJN  : logic;
  sel_LiefAdr,
  sel_LiefAdrVon,
  sel_LiefAdrBis : int;
  sel_LiefAdrNot,
  sel_LiefAdrAus : alpha;

  // Lieferanschrift  Lfs.Zielanschrift
  sel_LiefAnsJN  : logic;
  sel_LiefAns,
  sel_LiefAnsVon,
  sel_LiefAnsBis : int;
  sel_LiefAnsNot,
  sel_LiefAnsAus : alpha;

  // Auftragsnummer    Lfs.zuAuftragsnr
  sel_AufNrJN  : logic;
  sel_AufNr,
  sel_AufNrVon,
  sel_AufNrBis : int;
  sel_AufNrNot,
  sel_AufNrAus : alpha;

  // Referenznr       Lfs.Referenznr
  sel_RefNrJN  : logic;
  sel_RefNr,
  sel_RefNrVon,
  sel_RefNrBis,
  sel_RefNrNot,
  sel_RefNrAus : alpha;

  // zu BA              Lfs.zuBA.Nummer
  sel_BAJN  : logic;
  sel_BA,
  sel_BAVon,
  sel_BABis : int;
  sel_BANot,
  sel_BAAus : alpha;

  // zu BAPos           Lfs.zuBA.Position
  sel_BAPosJN  : logic;
  sel_BAPos,
  sel_BAPosVon,
  sel_BAPosBis : int;
  sel_BAPosNot,
  sel_BAPosAus : alpha;

end;

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
  addToApiSel(a,b) : begin end;

  c_DATEI       : 440
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
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Lfs.Nummer, Lfs.Lieferdatum, Lfs.Kundennummer, Lfs.Zieladresse, Lfs.Zielanschrift, Lfs.zuAuftragsnr, Lfs.Referenznr, Lfs.zuBA.Nummer, Lfs.zuBA.Position','');
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
  addToApi('Lfs.Nummer','');
  addToApi('Lfs.Kundennummer','');
  addToApi('Lfs.Zieladresse','');
  addToApi('Lfs.Zielanschrift','');
  addToApi('Lfs.Datum.Verbucht','');
  addToApi('Lfs.Spediteurnr','');
  addToApi('Lfs.Spediteur','');
  addToApi('Lfs.Fahrer','');
  addToApi('Lfs.Kennzeichen','');
  addToApi('Lfs.Bemerkung','');
  addToApi('Lfs.Loeschmarker','');
  addToApi('Lfs.zuBA.Nummer','');
  addToApi('Lfs.zuBA.Position','');
  addToApi('Lfs.Kundenstichwort','');
  addToApi('Lfs.Lieferdatum','');
  addToApi('Lfs.Kosten.Pro','');
  addToApi('Lfs.Kosten.PEH','');
  addToApi('Lfs.Kosten.MEH','');
  addToApi('Lfs.zuAuftragsnr','');
  addToApi('Lfs.Referenznr','');
  addToApi('Lfs.Positionsgewicht','');
  addToApi('Lfs.Leergewicht','');
  addToApi('Lfs.Gesamtgewicht','');
  addToApi('LFs.Wiegung1.Datum','');
  addToApi('LFs.Wiegung1.Zeit','');
  addToApi('LFs.Wiegung2.Datum','');
  addToApi('LFs.Wiegung2.Zeit','');

  // Protokoll
  addToApi('Lfs.Anlage.Datum','');
  addToApi('Lfs.Anlage.Zeit','');
  addToApi('Lfs.Anlage.User','');



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

  vArgs # VarAllocate(Sel_Args_000026);
  // ... und mit den empfangenen Argumenten füllen

  prepSelInt(aArgs,'Lfs.Nummer',
                    var sel_LfsNrJN,
                    var sel_LfsNr,
                    var sel_LfsNrNot,
                    var sel_LfsNrVon,
                    var sel_LfsNrBis,
                    var sel_LfsNrAus);

  prepSelDate(aArgs,'Lfs.Lieferdatum',
                    var sel_LfsDatJN,
                    var sel_LfsDat,
                    var sel_LfsDatNot,
                    var sel_LfsDatVon,
                    var sel_LfsDatBis,
                    var sel_LfsDatAus);

  prepSelInt(aArgs,'Lfs.Kundennummer',
                    var sel_KundeJN,
                    var sel_Kunde,
                    var sel_KundeNot,
                    var sel_KundeVon,
                    var sel_KundeBis,
                    var sel_KundeAus);

  prepSelInt(aArgs,'Lfs.Zieladresse',
                    var sel_LiefAdrJN,
                    var sel_LiefAdr,
                    var sel_LiefAdrNot,
                    var sel_LiefAdrVon,
                    var sel_LiefAdrBis,
                    var sel_LiefAdrAus);

  prepSelInt(aArgs,'Lfs.Zielanschrift',
                    var sel_LiefAnsJN,
                    var sel_LiefAns,
                    var sel_LiefAnsNot,
                    var sel_LiefAnsVon,
                    var sel_LiefAnsBis,
                    var sel_LiefAnsAus);

  prepSelAlpha(aArgs,'Lfs.Referenznr',
                    var sel_RefNrJN,
                    var sel_RefNr,
                    var sel_RefNrNot,
                    var sel_RefNrVon,
                    var sel_RefNrBis,
                    var sel_RefNrAus);

  prepSelInt(aArgs, 'Lfs.zuAuftragsnr',
                    var sel_AufNrJN,
                    var sel_AufNr,
                    var sel_AufNrNot,
                    var sel_AufNrVon,
                    var sel_AufNrBis,
                    var sel_AufNrAus);

  prepSelInt(aArgs,'Lfs.zuBA.Nummer',
                    var sel_BAJN,
                    var sel_BA,
                    var sel_BANot,
                    var sel_BAVon,
                    var sel_BABis,
                    var sel_BAAus);

  prepSelInt(aArgs,'Lfs.zuBA.Position',
                    var sel_BAPosJN,
                    var sel_BAPos,
                    var sel_BAPosNot,
                    var sel_BAPosVon,
                    var sel_BAPosBis,
                    var sel_BAPosAus);



  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000026:Sel',vArgs);
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
          if (StrCut(vFldName,1,4) = 'LFS.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'LFS.LOESCHMARKER'    : vFldName #  'Lfs.Löschmarker';     // TDS 1: Hauptdaten
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
  VarFree(Sel_Args_000026);
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
  VarInstance(Sel_Args_000026, SOA_PartSel_Args);

  if (SelInt( Lfs.Nummer,
              sel_LfsNrJN,
              sel_LfsNrNot,
              sel_LfsNrAus,
              sel_LfsNrVon,
              sel_LfsNrBis)) then return false;

  if (SelDate( Lfs.Lieferdatum,
              sel_LfsDatJN,
              sel_LfsDatNot,
              sel_LfsDatAus,
              sel_LfsDatVon,
              sel_LfsDatBis)) then return false;

  if (SelInt( Lfs.Kundennummer,
              sel_KundeJN,
              sel_KundeNot,
              sel_KundeAus,
              sel_KundeVon,
              sel_KundeBis)) then return false;

  if (SelInt( Lfs.Zieladresse,
              sel_LiefAdrJN,
              sel_LiefAdrNot,
              sel_LiefAdrAus,
              sel_LiefAdrVon,
              sel_LiefAdrBis)) then return false;

  if (SelInt( Lfs.Zielanschrift,
              sel_LiefAnsJN,
              sel_LiefAnsNot,
              sel_LiefAnsAus,
              sel_LiefAnsVon,
              sel_LiefAnsBis)) then return false;

  if (SelInt(  Lfs.zuAuftragsnr,
              sel_AufNrJN,
              sel_AufNrNot,
              sel_AufNrAus,
              sel_AufNrVon,
              sel_AufNrBis)) then return false;

  if (SelAlpha(Lfs.Referenznr,
              sel_RefNrJN,
              sel_RefNrNot,
              sel_RefNrAus,
              sel_RefNrVon,
              sel_RefNrBis)) then return false;

  if (SelInt( Lfs.zuBA.Nummer,
              sel_BAJN,
              sel_BANot,
              sel_BAAus,
              sel_BAVon,
              sel_BABis)) then return false;

  if (SelInt( Lfs.zuBA.Position,
              sel_BAPosJN,
              sel_BAPosNot,
              sel_BAPosAus,
              sel_BAPosVon,
              sel_BAPosBis)) then return false;

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