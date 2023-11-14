@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000017
//                  OHNE E_R_G
//  Zu Service: AUF_POS_AKT_SEL
//
//  Info
///  AUF_POS_AKT_SEL: Lesen von Auftragsaktionen und Rückgabe der angegeben Felder
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
global Sel_Args_000017 begin
  Tmp : alpha;

  // Auftragsnummer    Auf.A.Nummer
  sel_AufNrJN  : logic;
  sel_AufNr,
  sel_AufNrVon,
  sel_AufNrBis : int;
  sel_AufNrNot,
  sel_AufNrAus : alpha;

  // Auftragsposition  Auf.A.Position
  sel_AufPosJN  : logic;
  sel_AufPos,
  sel_AufPosVon,
  sel_AufPosBis : int;
  sel_AufPosNot,
  sel_AufPosAus : alpha;

  // Aktionstyp      Auf.A.Aktionstyp
  sel_AktTypJN  : logic;
  sel_AktTyp,
  sel_AktTypVon,
  sel_AktTypBis,
  sel_AktTypNot,
  sel_AktTypAus : alpha;

  // Aktionsnummer     Auf.A.Aktionsnr
  sel_AktNrJN  : logic;
  sel_AktNr,
  sel_AktNrVon,
  sel_AktNrBis : int;
  sel_AktNrNot,
  sel_AktNrAus : alpha;

  // Aktionsposition  Auf.A.Aktionspos
  sel_AktPosJN  : logic;
  sel_AktPos,
  sel_AktPosVon,
  sel_AktPosBis : int;
  sel_AktPosNot,
  sel_AktPosAus : alpha;

  // Rechnungsnummer    Auf.A.Rechnungsnr
  sel_RechNrJN  : logic;
  sel_RechNr,
  sel_RechNrVon,
  sel_RechNrBis : int;
  sel_RechNrNot,
  sel_RechNrAus : alpha;

  // Materialnr         Auf.A.Materialnr
  sel_MatNrJN  : logic;
  sel_MatNr,
  sel_MatNrVon,
  sel_MatNrBis : int;
  sel_MatNrNot,
  sel_MatNrAus : alpha;
end;

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;

  c_DATEI       : 404
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
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Auf.A.Nummer, Auf.A.Position, Auf.A.Aktionstyp, Auf.A.Aktionsnr, Auf.A.Aktionspos, Auf.A.Rechnungsnr, Auf.A.Materialnr','');
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
  addToApi('Auf.A.Nummer','');
  addToApi('Auf.A.Position','');
  addToApi('Auf.A.Position2','');
  addToApi('Auf.A.Aktion','');
  addToApi('Auf.A.Aktionstyp','');
  addToApi('Auf.A.Aktionsnr','');
  addToApi('Auf.A.Aktionspos','');
  addToApi('Auf.A.Aktionspos2','');
  addToApi('Auf.A.Aktionsdatum','');
  addToApi('Auf.A.TerminStart','');
  addToApi('Auf.A.TerminEnde','');
  addToApi('Auf.A.Adressnummer','');
  addToApi('Auf.A.MEH','');
  addToApi('Auf.A.Menge','');
  addToApi('Auf.A.Stueckzahl','');
  addToApi('Auf.A.Gewicht','');
  addToApi('Auf.A.Nettogewicht','');
  addToApi('Auf.A.MEH.Preis','');
  addToApi('Auf.A.Menge.Preis','');
  addToApi('Auf.A.Rechnungsnr','');
  addToApi('Auf.A.Rechnungsdatum','');
  addToApi('Auf.A.Rechnungspreis','');
  addToApi('Auf.A.RechPreisW1','');
  addToApi('Auf.A.EKPreisSummeW1','');
  addToApi('Auf.A.Bemerkung','');
  addToApi('Auf.A.Loeschmarker','');
  addToApi('Auf.A.Rechnungsmark','');
  addToApi('Auf.A.TheorieYN','');
  addToApi('Auf.A.RueckEinzelEKW1','');
  addToApi('Auf.A.interneKostW1','');
  addToApi('Auf.A.Versandpoolnr','');

  // Artikeldaten
  addToApi('Auf.A.ArtikelNr','');
  addToApi('Auf.A.Charge.Adresse','');
  addToApi('Auf.A.Charge.Anschr','');
  addToApi('Auf.A.Charge','');

  // Materialdaten
  addToApi('Auf.A.MaterialNr','');
  addToApi('Auf.A.Dicke','');
  addToApi('Auf.A.Breite','');
  addToApi('Auf.A.Länge','');

  // Protokoll
  addToApi('Auf.A.Anlage.Datum','');
  addToApi('Auf.A.Anlage.Zeit','');
  addToApi('Auf.A.Anlage.User','');

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

  vArgs # VarAllocate(Sel_Args_000017);
  // ... und mit den empfangenen Argumenten füllen

  prepSelInt(aArgs,'Auf.A.Nummer',
                    var sel_AufNrJN,
                    var sel_AufNr,
                    var sel_AufNrNot,
                    var sel_AufNrVon,
                    var sel_AufNrBis,
                    var sel_AufNrAus);

  prepSelInt(aArgs,'Auf.A.Position',
                    var sel_AufPosJN,
                    var sel_AufPos,
                    var sel_AufPosNot,
                    var sel_AufPosVon,
                    var sel_AufPosBis,
                    var sel_AufPosAus);

  prepSelAlpha(aArgs,'Auf.A.Aktionstyp',
                    var sel_AktTypJN,
                    var sel_AktTyp,
                    var sel_AktTypNot,
                    var sel_AktTypVon,
                    var sel_AktTypBis,
                    var sel_AktTypAus);

  prepSelInt(aArgs,'Auf.A.Aktionsnr',
                    var sel_AktNrJN,
                    var sel_AktNr,
                    var sel_AktNrNot,
                    var sel_AktNrVon,
                    var sel_AktNrBis,
                    var sel_AktNrAus);

  prepSelInt(aArgs,'Auf.A.Aktionspos',
                    var sel_AktPosJN,
                    var sel_AktPos,
                    var sel_AktPosNot,
                    var sel_AktPosVon,
                    var sel_AktPosBis,
                    var sel_AktPosAus);

  prepSelInt(aArgs,'Auf.A.Rechnungsnr',
                    var sel_RechNrJN,
                    var sel_RechNr,
                    var sel_RechNrNot,
                    var sel_RechNrVon,
                    var sel_RechNrBis,
                    var sel_RechNrAus);

  prepSelInt(aArgs,'Auf.A.Materialnr',
                    var sel_MatNrJN,
                    var sel_MatNr,
                    var sel_MatNrNot,
                    var sel_MatNrVon,
                    var sel_MatNrBis,
                    var sel_MatNrAus);

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
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000017:Sel',vArgs);
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
                'AUF.A.STUECKZAHL'      : vFldName #  'Auf.A.Stückzahl';
                'AUF.A.LOESCHMARKER'    : vFldName #  'Auf.A.Löschmarker';
                'Auf.A.RUECKEINZELEKW1'       : vFldName #  'Auf.A.RückEinzelEKW1';
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
  VarFree(Sel_Args_000017);
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
  VarInstance(Sel_Args_000017, SOA_PartSel_Args);

  if (SelInt( Auf.A.Nummer,
              sel_AufNrJN,
              sel_AufNrNot,
              sel_AufNrAus,
              sel_AufNrVon,
              sel_AufNrBis)) then return false;

  if (SelInt( Auf.A.Position,
              sel_AufPosJN,
              sel_AufPosNot,
              sel_AufPosAus,
              sel_AufPosVon,
              sel_AufPosBis)) then return false;

  if (SelAlpha("Auf.A.Aktionstyp",
              sel_AktTypJN,
              sel_AktTypNot,
              sel_AktTypAus,
              sel_AktTypVon,
              sel_AktTypBis)) then return false;

  if (SelInt( Auf.A.Aktionsnr,
              sel_AktNrJN,
              sel_AktNrNot,
              sel_AktNrAus,
              sel_AktNrVon,
              sel_AktNrBis)) then return false;

  if (SelInt( Auf.A.Aktionspos,
              sel_AktPosJN,
              sel_AktPosNot,
              sel_AktPosAus,
              sel_AktPosVon,
              sel_AktPosBis)) then return false;

  if (SelInt( Auf.A.Rechnungsnr,
              sel_RechNrJN,
              sel_RechNrNot,
              sel_RechNrAus,
              sel_RechNrVon,
              sel_RechNrBis)) then return false;

  if (SelInt( Auf.A.Materialnr,
              sel_MatNrJN,
              sel_MatNrNot,
              sel_MatNrAus,
              sel_MatNrVon,
              sel_MatNrBis)) then return false;


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