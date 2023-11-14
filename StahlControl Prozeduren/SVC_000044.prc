@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000044
//                  OHNE E_R_G
//  Zu Service: ERL_SEL
//
//  Info
///  ERL_SEL: Lesen von Erlösen und Rückgabe der angegeben Felder
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
global Sel_Args_000044 begin
  Tmp : alpha;

/*
  // BA nummer          BAG.P.Nummer
  sel_ JN  : logic;
  sel_ ,
  sel_ Von,
  sel_ Bis : ___;
  sel_ Not,
  sel_ Aus : alpha;
*/
  // Datum              Erl.Rechnungsdatum
  sel_DatJN  : logic;
  sel_Dat,
  sel_DatVon,
  sel_DatBis : date;
  sel_DatNot,
  sel_DatAus : alpha;

  // Rechnugnstyp       Erl.Rechnungstyp
  sel_ReTypJN  : logic;
  sel_ReTyp,
  sel_ReTypVon,
  sel_ReTypBis : int;
  sel_ReTypNot,
  sel_ReTypAus : alpha;

  // Kunde              Erl.Kundennummer
  sel_KndJN  : logic;
  sel_Knd,
  sel_KndVon,
  sel_KndBis : int;
  sel_KndNot,
  sel_KndAus : alpha;

   // Verband           Erl.Verband
  sel_VerbandJN  : logic;
  sel_Verband,
  sel_VerbandVon,
  sel_VerbandBis : int;
  sel_VerbandNot,
  sel_VerbandAus : alpha;

  // Vertreter           Erl.Vertreter
  sel_VertreterJN  : logic;
  sel_Vertreter,
  sel_VertreterVon,
  sel_VertreterBis : int;
  sel_VertreterNot,
  sel_VertreterAus : alpha;

end;



define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;

  c_DATEI       : 450
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
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Erl.Rechnungsdatum, Erl.Rechnungstyp, Erl.Kundennummer, Erl.Verband, Erl.Vertreter ','');
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
  addToApi('Erl.Hauptdaten','');
  addToApi('Erl.Rechnungsdatum','');
  addToApi('Erl.Rechnungstyp','');
  addToApi('Erl.Kundennummer','');
  addToApi('Erl.KundenStichwort','');
  addToApi('Erl.Vertreter','');
  addToApi('Erl.Verband','');
  addToApi('Erl.Waehrung','');
  addToApi('Erl.Waehrungskurs','');
  addToApi('Erl.Stueckzahl','');
  addToApi('Erl.Gewicht','');
  addToApi('Erl.VerpEinheiten','');
  addToApi('Erl.Bemerkung','');
  addToApi('Erl.FibuDatum','');
  addToApi('Erl.Rechnungsempf','');
  addToApi('Erl.StornoRechNr','');
  addToApi('Erl.Zahlungsbed','');
  addToApi('Erl.Adr.Steuerschl','');
  addToApi('Erl.Zieldatum','');
  addToApi('Erl.Skontoprozent','');
  addToApi('Erl.Skontodatum','');

  // Beträge
  addToApi('Erl.Netto','');
  addToApi('Erl.NettoW1','');
  addToApi('Erl.Steuer','');
  addToApi('Erl.SteuerW1','');
  addToApi('Erl.Brutto','');
  addToApi('Erl.BruttoW1','');

  // Protokoll
  addToApi('Erl.Anlage.Datum','');
  addToApi('Erl.Anlage.Zeit','');
  addToApi('Erl.Anlage.User','');

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

  vArgs # VarAllocate(Sel_Args_000044);
  // ... und mit den empfangenen Argumenten füllen

  prepSelDate(aArgs,'Erl.Rechnungsdatum',
                    var sel_DatJN,
                    var sel_Dat,
                    var sel_DatNot,
                    var sel_DatVon,
                    var sel_DatBis,
                    var sel_DatAus);

  prepSelInt(aArgs,'Erl.Rechnungstyp',
                    var sel_ReTypJN,
                    var sel_ReTyp,
                    var sel_ReTypNot,
                    var sel_ReTypVon,
                    var sel_ReTypBis,
                    var sel_ReTypAus);

  prepSelInt(aArgs,'Erl.Kundennummer',
                    var sel_KndJN,
                    var sel_Knd,
                    var sel_KndNot,
                    var sel_KndVon,
                    var sel_KndBis,
                    var sel_KndAus);

  prepSelInt(aArgs,'Erl.Verband',
                    var sel_VerbandJN,
                    var sel_Verband,
                    var sel_VerbandNot,
                    var sel_VerbandVon,
                    var sel_VerbandBis,
                    var sel_VerbandAus);

  prepSelInt(aArgs,'Erl.Vertreter',
                    var sel_VertreterJN,
                    var sel_Vertreter,
                    var sel_VertreterNot,
                    var sel_VertreterVon,
                    var sel_VertreterBis,
                    var sel_VertreterAus);
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
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000044:Sel',vArgs);
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

/*
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
              'Rso.%_Besäumen'      : vFldName # 'Rso.Proz_Besaeumen';
            END
*/
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
          if (StrCut(vFldName,1,4) = 'ERL.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'ERL.WAEHRUNG'           : vFldName #  'Erl.Währung';
                'ERL.WAEHRUNGSKURS'      : vFldName #  'Erl.Währungskurs';
                'ERL.STUECKZAHL'         : vFldName #  'Erl.Stückzahl';
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
  VarFree(Sel_Args_000044);
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
  VarInstance(Sel_Args_000044, SOA_PartSel_Args);

/*
  if (Sel...( Auf.......,
              sel_ ... JN,
              sel_ ... Not,
              sel_ ... Aus,
              sel_ ... Von,
              sel_ ... Bis)) then return false;
*/
  if (SelDate( Erl.Rechnungsdatum,
              sel_DatJN,
              sel_DatNot,
              sel_DatAus,
              sel_DatVon,
              sel_DatBis)) then return false;

  if (SelInt( Erl.Rechnungstyp,
              sel_ReTypJN,
              sel_ReTypNot,
              sel_ReTypAus,
              sel_ReTypVon,
              sel_ReTypBis)) then return false;

  if (SelInt( Erl.Kundennummer,
              sel_KndJN,
              sel_KndNot,
              sel_KndAus,
              sel_KndVon,
              sel_KndBis)) then return false;

  if (SelInt( Erl.Verband,
              sel_VerbandJN,
              sel_VerbandNot,
              sel_VerbandAus,
              sel_VerbandVon,
              sel_VerbandBis)) then return false;

  if (SelInt( Erl.Vertreter,
              sel_VertreterJN,
              sel_VertreterNot,
              sel_VertreterAus,
              sel_VertreterVon,
              sel_VertreterBis)) then return false;

  return true;
end; // sub Sel() : logic



//=========================================================================
//=========================================================================
//=========================================================================