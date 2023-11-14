@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000037
//                  OHNE E_R_G
//  Zu Service: OBF_SEL
//
//  Info
///  OBF_SEL: Lesen von Oberflächen und Rückgabe der angegeben Felder
//
//  18.02.2011  ST  Erstellung der Prozedur
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
global Sel_Args_000037 begin
  Tmp : alpha;

  /*

  // BA nummer          BAG.P.Nummer
  sel_BAGNrJN  : logic;
  sel_BAGNr,
  sel_BAGNrVon,
  sel_BAGNrBis : int;
  sel_BAGNrNot,
  sel_BAGNrAus : alpha;
*/

end;



define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;

  c_DATEI       : 841
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

/*
  // ----------------------------------
  // Selektionsmöglichlkeiten
  // ----------------------------------
  vNode # vApi->apiAdd('..Mögliche Selektionsfelder',_TypeAlpha,false,null,null,'');
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Bag.P.Nummer, Bag.P.Loeschmarker, Bag.P.Aktion, Bag.P.ExterneLiefNr, Bag.P.Plan.StartDat, Bag.P.Plan.EndDat, Bag.P.Fertig.Dat, Bag.P.Ressourcen.Grp, Bag.P.Ressource','');
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
*/

  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------


  // Haupdaten
  addToApi('Obf.Nummer','');
  addToApi('Obf.Bezeichnung.L1','');
  addToApi('Obf.Bezeichnung.L2','');
  addToApi('Obf.Bezeichnung.L3','');
  addToApi('Obf.Bezeichnung.L4','');
  addToApi('Obf.Bezeichnung.L5','');
  addToApi('Obf.Kuerzel','');
  addToApi('Obf.Gegenteil.ObfNr','');


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

  vArgs # VarAllocate(Sel_Args_000037);
  // ... und mit den empfangenen Argumenten füllen

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
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000037:Sel',vArgs);
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
          if (StrCut(vFldName,1,4) = 'OBF.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

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
  VarFree(Sel_Args_000037);
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
  VarInstance(Sel_Args_000037, SOA_PartSel_Args);

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