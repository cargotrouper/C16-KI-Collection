@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000041
//                  OHNE E_R_G
//  Zu Service: RSO_SEL
//
//  Info
///  RSO_SEL: Lesen von Ressourcen und Rückgabe der angegeben Felder
//
//  21.02.2011  ST  Erstellung der Prozedur
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
global Sel_Args_000041 begin
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
  // Gruppe             RSO.Gruppe
  sel_GrpJN  : logic;
  sel_Grp,
  sel_GrpVon,
  sel_GrpBis : int;
  sel_GrpNot,
  sel_GrpAus : alpha;
end;



define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;

  c_DATEI       : 160
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
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Rso.Gruppe','');
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
  addToApi('Rso.Gruppe','');
  addToApi('Rso.Nummer','');
  addToApi('Rso.Abteilung','');
  addToApi('Rso.Stichwort','');
  addToApi('Rso.Bezeichnung1','');
  addToApi('Rso.Bezeichnung2','');
  addToApi('Rso.PreisProH','');
  addToApi('Rso.PreisProAusfallH','');
  addToApi('Rso.MengeProH','');
  addToApi('Rso.MEHProH','');
  addToApi('Rso.autoLaufzeitYN','');
  addToApi('Rso.autoPlanungstyp','');
  addToApi('Rso.Kostenstelle','');

  // Maschinendaten
  addToApi('Rso.Hersteller','');
  addToApi('Rso.Kundendienst','');
  addToApi('Rso.Baujahr','');
  addToApi('Rso.Seriennummer','');
  addToApi('Rso.Zeichnungsnr','');
  addToApi('Rso.ZeichnungsVers','');
  addToApi('Rso.LeistungKWatt','');
  addToApi('Rso.Abmessung','');
  addToApi('Rso.Änderungstext','');
  addToApi('Rso.Zusatztext','');
  addToApi('Rso.Aktionstyp','');

  // Personaldaten
  addToApi('Rso.PersonalID','');
  addToApi('Rso.Personal.Code','');

  // Laufzeitberechnung
  addToApi('Rso.t_Ruestbasis','');
  addToApi('Rso.t_RuestProInputStk','');
  addToApi('Rso.t_RuestProInputLfd','');
  addToApi('Rso.t_Prodbasis','');
  addToApi('Rso.t_ProdProOutStk','');
  addToApi('Rso.t_ProdProOutLfd','');
  addToApi('Rso.t_Absetzbasis','');
  addToApi('Rso.t_AbsetzProInpStk','');
  addToApi('Rso.t_AbsetzProInpLfd','');
  addToApi('Rso.t_AbsetzProOutVPE','');
  addToApi('Rso.t_AbsetzProOutStk','');
  addToApi('Rso.t_AbsetzProOutLfd','');
  addToApi('Rso.t_Messerbau','');
  addToApi('Rso.t_Laengenaenderung','');
  addToApi('Rso.Proz_Besaeumen','');

  // Protokoll
  addToApi('Rso.Anlage.Datum','');
  addToApi('Rso.Anlage.Zeit','');
  addToApi('Rso.Anlage.User','');
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
  vFldName,vFldName2  : alpha;
  vChkName  : alpha;
  Erx       : int;
end
begin

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vFelderGrp    # aArgs->getValue('FELDER');

  vArgs # VarAllocate(Sel_Args_000041);
  // ... und mit den empfangenen Argumenten füllen

  prepSelInt(aArgs,'Rso.Gruppe',
                    var sel_GrpJN,
                    var sel_Grp,
                    var sel_GrpNot,
                    var sel_GrpVon,
                    var sel_GrpBis,
                    var sel_GrpAus);
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
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000041:Sel',vArgs);
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
              'Rso.Menge\h'         : vFldName # 'Rso.MengeProH';
              'Rso.MEH\h'           : vFldName # 'Rso.MEHProH';
              'Rso.t_Rüst\InputStk' : vFldName # 'Rso.t_RüstProInputStk';
              'Rso.t_Rüst\InputLfd' : vFldName # 'Rso.t_RüstProInputLfd';
              'Rso.t_Prod\OutStk'   : vFldName # 'Rso.t_ProdProOutStk';
              'Rso.t_Prod\OutLfd'   : vFldName # 'Rso.t_ProdProOutLfd';
              'Rso.t_Absetz\InpStk' : vFldName # 'Rso.t_AbsetzProInpStk';
              'Rso.t_Absetz\InpLfd' : vFldName # 'Rso.t_AbsetzProInpLfd';
              'Rso.t_Absetz\OutVPE' : vFldName # 'Rso.t_AbsetzProOutVPE';
              'Rso.t_Absetz\OutStk' : vFldName # 'Rso.t_AbsetzProOutStk';
              'Rso.t_Absetz\OutLfd' : vFldName # 'Rso.t_AbsetzProOutLfd';
//              'Rso.%_Besäumen'      : vFldName # 'Rso.Proz_Besaeumen';
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
          if (StrCut(vFldName,1,4) = 'RSO.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'RSO.MENGEPROH'           : vFldName #  'Rso.Menge\h';
                'RSO.MEHPROH'             : vFldName #  'Rso.MEH\h';
                'RsO.AENDERUNGSTEXT'      : vFldName #  'Rso.Änderungstext';
                'RSO.T_RUESTBASIS'        : vFldName #  'Rso.t_Rüstbasis';
                'RSO.T_LAENGENAENDERUNG'  : vFldName #  'Rso.t_Längenänderung';
                'RSO.T_RUESTPROINPUTSTK'  : vFldName #  'Rso.t_Rüst\InputStk';
                'RSO.T_RUESTPROINPUTLFD'  : vFldName #  'Rso.t_Rüst\InputLfd ';
                'RSO.T_PRODPROOUTSTK'     : vFldName #  'Rso.t_Prod\OutStk';
                'RSO.T_PRODPROOUTLFD'     : vFldName #  'Rso.t_Prod\OutLfd';
                'RSO.T_ABSETZPROINPSTK'   : vFldName #  'Rso.t_Absetz\InpStk';
                'RSO.T_ABSETZPROINPLFD'   : vFldName #  'Rso.t_Absetz\InpLfd';
                'RSO.T_ABSETZPROOUTVPE'   : vFldName #  'Rso.t_Absetz\OutVPE';
                'RSO.T_ABSETZPROOUTSTK'   : vFldName #  'Rso.t_Absetz\OutStk';
                'RSO.T_ABSETZPROOUTLFD'   : vFldName #  'Rso.t_Absetz\OutLfd';
//                'RSO.PROZ_BESAEUMEN'      : vFldName #  'Rso.%_Besäumen';
              END;
              // Feld mit "normalem" Namen prüfen
              vErg # FldInfoByName(vFldName,_FldExists);

              // Feld vorhanden?
              if (vErg <> 0) then begin


                vFldName2 #  vFldName;
                // Inkompatible Feldnamen für Export korrigieren
                CASE (vFldName2) OF
                  'Rso.Menge\h'         : vFldName2 # 'Rso.MengeProH';
                  'Rso.MEH\h'           : vFldName2 # 'Rso.MEHProH';
                  'Rso.t_Rüst\InputStk' : vFldName2 # 'Rso.t_RüstProInputStk';
                  'Rso.t_Rüst\InputLfd' : vFldName2 # 'Rso.t_RüstProInputLfd';
                  'Rso.t_Prod\OutStk'   : vFldName2 # 'Rso.t_ProdProOutStk';
                  'Rso.t_Prod\OutLfd'   : vFldName2 # 'Rso.t_ProdProOutLfd';
                  'Rso.t_Absetz\InpStk' : vFldName2 # 'Rso.t_AbsetzProInpStk';
                  'Rso.t_Absetz\InpLfd' : vFldName2 # 'Rso.t_AbsetzProInpLfd';
                  'Rso.t_Absetz\OutVPE' : vFldName2 # 'Rso.t_AbsetzProOutVPE';
                  'Rso.t_Absetz\OutStk' : vFldName2 # 'Rso.t_AbsetzProOutStk';
                  'Rso.t_Absetz\OutLfd' : vFldName2 # 'Rso.t_AbsetzProOutLfd';
//                  'Rso.%_Besäumen'      : vFldName2 # 'Rso.Proz_Besaeumen';
                END;

                // Alle Feldnamen in Großbuchstabenexportieren
                vFldName # toUpper(vFldName);

               // Wenn vorhanden dann je nach Feldtyp schreiben
               CASE (FldInfoByName(vFldName,_FldType)) OF
                  _TypeAlpha    : vResNode->Lib_SOA:AppendNode(vFldName2, FldAlphaByName(vFldName));
                  _TypeBigInt   : vResNode->Lib_SOA:AppendNode(vFldName2, CnvAb(FldBigIntByName(vFldName)));
                  _TypeDate     : vResNode->Lib_SOA:AppendNode(vFldName2, CnvAd(FldDateByName(vFldName)));
                  _TypeDecimal  : vResNode->Lib_SOA:AppendNode(vFldName2, CnvAM(FldDecimalByName(vFldName)));
                  _TypeFloat    : vResNode->Lib_SOA:AppendNode(vFldName2, CnvAf(FldFloatByName(vFldName)));
                  _TypeInt      : vResNode->Lib_SOA:AppendNode(vFldName2, CnvAi(FldIntByName(vFldName)));
                  _TypeLogic    : vResNode->Lib_SOA:AppendNode(vFldName2, CnvAi(CnvIl(FldLogicByName(vFldName))));
                  _TypeTime     : vResNode->Lib_SOA:AppendNode(vFldName2, CnvAt(FldTimeByName(vFldName)));
                  _TypeWord     : vResNode->Lib_SOA:AppendNode(vFldName2, CnvAi(FldWordByName(vFldName)));
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
  VarFree(Sel_Args_000041);
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
  VarInstance(Sel_Args_000041, SOA_PartSel_Args);

/*
  if (Sel...( Auf.......,
              sel_ ... JN,
              sel_ ... Not,
              sel_ ... Aus,
              sel_ ... Von,
              sel_ ... Bis)) then return false;
*/
  if (SelInt( Rso.Gruppe,
              sel_GrpJN,
              sel_GrpNot,
              sel_GrpAus,
              sel_GrpVon,
              sel_GrpBis)) then return false;

  return true;
end; // sub Sel() : logic



//=========================================================================
//=========================================================================
//=========================================================================