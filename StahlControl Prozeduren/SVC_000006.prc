@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000006
//                  OHNE E_R_G
//  Zu Service: ANS_SEL
//
//  Info
///  ANS_SEL: Lesen von Ansprechpartnern und Rückgabe der angegeben Felder
//
//  14.02.2011  ST  Erstellung der Prozedur
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
global Sel_Args_000006 begin
  Tmp : alpha;

  // Adressnummer
  sel_AdrNrJN  : logic;
  sel_AdrNr,
  sel_AdrNrVon,
  sel_AdrNrBis : int;
  sel_AdrNrNot,
  sel_AdrNrAus : alpha;

  // Stichwort
  sel_StichwJN  : logic;
  sel_Stichw,
  sel_StichwVon,
  sel_StichwBis,
  sel_StichwNot,
  sel_StichwAus : alpha;

  // Name
  sel_NameJN  : logic;
  sel_Name,
  sel_NameVon,
  sel_NameBis,
  sel_NameNot,
  sel_NameAus : alpha;

  // Vorname
  sel_VornameJN  : logic;
  sel_Vorname,
  sel_VornameVon,
  sel_VornameBis,
  sel_VornameNot,
  sel_VornameAus : alpha;


/*
  sel_xxxJN  : logic;
  sel_xxx,
  sel_xxxVon,
  sel_xxxBis : float;
  sel_xxxNot,
  sel_xxxAus : alpha;
*/
end;

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
  addToApiSel(a,b) : begin end;
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
  vNode->apiSetDesc('Folgende Felder können abgrfragt werden: Adr.P.Adressnr, Adr.P.Stichwort, Adr.P.Name, Adr.P.Vorname','');
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
  addToApi('Adr.P.Adressnr'     ,'Eindeutige Adressnummer');
  addToApi('Adr.P.Nummer'       ,'');
  addToApi('Adr.P.Stichwort'     ,'');
  addToApi('Adr.P.Vorname'     ,'');
  addToApi('Adr.P.Name'     ,'');
  addToApi('Adr.P.Titel'     ,'');
  addToApi('Adr.P.Telefon'     ,'');
  addToApi('Adr.P.Telefax'     ,'');
  addToApi('Adr.P.Mobil'     ,'');
  addToApi('Adr.P.eMail'     ,'');
  addToApi('Adr.P.Abteilung'     ,'');
  addToApi('Adr.P.Funktion'     ,'');
  addToApi('Adr.P.Vorgesetzter'     ,'');
  addToApi('Adr.P.Briefanrede'     ,'');
  addToApi('Adr.P.Priv.LKZ'     ,'');
  addToApi('Adr.P.Priv.PLZ'     ,'');
  addToApi('Adr.P.Priv.Strasse'     ,'');
  addToApi('Adr.P.Priv.Ort'     ,'');
  addToApi('Adr.P.Priv.Telefon'     ,'');
  addToApi('Adr.P.Priv.Telefax'     ,'');
  addToApi('Adr.P.Priv.eMail'     ,'');
  addToApi('Adr.P.Priv.Mobil'     ,'');
  addToApi('Adr.P.Geburtsdatum'     ,'');
  addToApi('Adr.P.PrivGeschenkYN'     ,'');
  addToApi('Adr.P.Familienstand'     ,'');
  addToApi('Adr.P.Hobbies'     ,'');
  addToApi('Adr.P.Vorlieben'     ,'');
  addToApi('Adr.P.Auto'     ,'');
  addToApi('Adr.P.Religion'     ,'');
  addToApi('Adr.P.Partner.Name'     ,'');
  addToApi('Adr.P.Partner.GebTag'     ,'');
  addToApi('Adr.P.Hochzeitstag'     ,'');
  addToApi('Adr.P.Kind1.Name'     ,'');
  addToApi('Adr.P.Kind1.GebTag'     ,'');
  addToApi('Adr.P.Kind2.Name'     ,'');
  addToApi('Adr.P.Kind2.GebTag'     ,'');
  addToApi('Adr.P.Kind3.Name'     ,'');
  addToApi('Adr.P.Kind3.GebTag'     ,'');
  addToApi('Adr.P.Kind4.Name'     ,'');
  addToApi('Adr.P.Kind4.GebTag'     ,'');

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
  vAnsNode    : handle;     // Handle für Ansprechpartnernode

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

  vArgs # VarAllocate(Sel_Args_000006);
  // ... und mit den empfangenen Argumenten füllen


  prepSelInt(aArgs,'Adr.P.Adressnr', var sel_AdrNrJN,  var sel_AdrNr,  var sel_AdrNrNot,  var sel_AdrNrVon,   var sel_AdrNrBis,   var sel_AdrNrAus);
  prepSelAlpha(aArgs,'Adr.P.Stichwort',var sel_StichwJN, var sel_Stichw, var sel_StichwNot, var sel_StichwVon,  var sel_StichwBis,  var sel_StichwAus);
  prepSelAlpha(aArgs,'Adr.P.Name',var sel_NameJN, var sel_Name, var sel_NameNot, var sel_NameVon,  var sel_NameBis,  var sel_NameAus);
  prepSelAlpha(aArgs,'Adr.P.Vorname',var sel_VornameJN, var sel_Vorname, var sel_VornameNot, var sel_VornameVon,  var sel_VornameBis,  var sel_VornameAus);

  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(102, 1, 'SVC_000006:Sel',vArgs);
  vAnz  # Lib_SOA:RunPartSel(vSel, 0, 0); // Max 0 = alle, RecId 0 = von Anfang an


  // Daten Node zum einfügen extrahieren
  vNode # aResponse->getNode('DATA');

  FOR  Erx # RecRead(102, SOA_PartSel_Sel, _RecFirst);
  LOOP Erx # RecRead(102, SOA_PartSel_Sel, _RecNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    vAnsNode # vNode->addRecord(102);

    case (toUpper(vFelderGrp)) of

      //-------------------------------------------------------------------------------
      'ALLE', '' : begin

        vDatei # 102;
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
            vAnsNode->Lib_XML:AppendNode(toUpper(vFldName),vFldData);

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
          if (StrCut(vFldName,1,6) = 'ADR.P.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'ADR.P.PRIV.STRASSE'    : vFldName #  'Adr.P.Priv.Straße';     // TDS 1: Hauptdaten
              END;

              // Feld mit "normalem" Namen prüfen
              vErg # FldInfoByName(vFldName,_FldExists);

              // Feld vorhanden?
              if (vErg <> 0) then begin
                // Alle Feldnamen in Großbuchstabenexportieren
                vFldName # toUpper(vFldName);

                 // Wenn vorhanden dann je nach Feldtyp schreiben
                 CASE (FldInfoByName(vFldName,_FldType)) OF
                    _TypeAlpha    : vAnsNode->Lib_SOA:AppendNode(vFldName, FldAlphaByName(vFldName));
                    _TypeBigInt   : vAnsNode->Lib_SOA:AppendNode(vFldName, CnvAb(FldBigIntByName(vFldName)));
                    _TypeDate     : vAnsNode->Lib_SOA:AppendNode(vFldName, CnvAd(FldDateByName(vFldName)));
                    _TypeDecimal  : vAnsNode->Lib_SOA:AppendNode(vFldName, CnvAM(FldDecimalByName(vFldName)));
                    _TypeFloat    : vAnsNode->Lib_SOA:AppendNode(vFldName, CnvAf(FldFloatByName(vFldName)));
                    _TypeInt      : vAnsNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldIntByName(vFldName)));
                    _TypeLogic    : vAnsNode->Lib_SOA:AppendNode(vFldName, CnvAi(CnvIl(FldLogicByName(vFldName))));
                    _TypeTime     : vAnsNode->Lib_SOA:AppendNode(vFldName, CnvAt(FldTimeByName(vFldName)));
                    _TypeWord     : vAnsNode->Lib_SOA:AppendNode(vFldName, CnvAi(FldWordByName(vFldName)));
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
  VarFree(Sel_Args_000006);
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
  VarInstance(Sel_Args_000006, SOA_PartSel_Args);

  if (SelInt  (Adr.P.Adressnr,   sel_AdrNrJN, sel_AdrNrNot, sel_AdrNrAus, sel_AdrNrVon, sel_AdrNrBis))  then return false;

  if (SelAlpha(Adr.P.Stichwort, sel_StichwJN, sel_StichwNot, sel_StichwAus, sel_StichwVon, sel_StichwBis))  then return false;
  if (SelAlpha(Adr.P.Name, sel_NameJN, sel_NameNot, sel_NameAus, sel_NameVon, sel_NameBis))  then return false;
  if (SelAlpha(Adr.P.VorName, sel_VorNameJN, sel_vorNameNot, sel_VorNameAus, sel_VorNameVon, sel_VorNameBis))  then return false;

  return true;
end; // sub Sel() : logic



//=========================================================================
//=========================================================================
//=========================================================================