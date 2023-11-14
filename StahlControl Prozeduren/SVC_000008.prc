@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000008
//                  OHNE E_R_G
//  Zu Service: MAT_RES_SEL
//
//  Info
///  MAT_RES_SEL: Lesen von Reservierungen und Rückgabe der angegeben Felder
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
global Sel_Args_000008 begin
  Tmp : alpha;

  // Materialnr  Mat.R.Materialnr
  sel_MatNrJN  : logic;
  sel_MatNr,
  sel_MatNrVon,
  sel_MatNrBis : int;
  sel_MatNrNot,
  sel_MatNrAus : alpha;

  // Auftragsnr  Mat.R.Auftragsnr
  sel_AufNrJN  : logic;
  sel_AufNr,
  sel_AufNrVon,
  sel_AufNrBis : int;
  sel_AufNrNot,
  sel_AufNrAus : alpha;

  // Auftragspos  Mat.R.Auftragspos
  sel_AufPosJN  : logic;
  sel_AufPos,
  sel_AufPosVon,
  sel_AufPosBis : int;
  sel_AufPosNot,
  sel_AufPosAus : alpha;

  // Kundennr  Mat.R.Kundennummer
  sel_KndNrJN  : logic;
  sel_KndNr,
  sel_KndNrVon,
  sel_KndNrBis : int;
  sel_KndNrNot,
  sel_KndNrAus : alpha;

  // Bemerkung  Mat.R.Bemerkung
  sel_BemerkungJN  : logic;
  sel_Bemerkung,
  sel_BemerkungVon,
  sel_BemerkungBis,
  sel_BemerkungNot,
  sel_BemerkungAus : alpha;

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
  vNode->apiSetDesc('Folgende Felder können abgrfragt werden: Mat.R.Materialnr, Mat.R.Auftragsnr, Mat.R.Auftragspos, Mat.R.Kundennummer, Mat.R.Bemerkung','');
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
  addToApi('Mat.R.Materialnr'     ,'');
  addToApi('Mat.R.Reservierungnr' ,'');
  addToApi('Mat.R.Kommission'     ,'');
  addToApi('Mat.R.Auftragsnr'     ,'');
  addToApi('Mat.R.Auftragspos'    ,'');
  addToApi('Mat.R.Kundennummer'   ,'');
  addToApi('Mat.R.KundenSW'       ,'');
  addToApi('Mat.R.Stueckzahl'     ,'');
  addToApi('Mat.R.Gewicht'        ,'');
  addToApi('Mat.R.Bemerkung'      ,'');
  addToApi('Mat.R.Ablaufdatum'    ,'');
  addToApi('Mat.R.Traegertyp'     ,'');
  addToApi('Mat.R.Traegernummer1' ,'');
  addToApi('Mat.R.Traegernummer2' ,'');
  addToApi('Mat.R.Traegernummer3' ,'');

  // Protokoll
  addToApi('Mat.R.Anlage.Datum'     ,'');
  addToApi('Mat.R.Anlage.Zeit'     ,'');
  addToApi('Mat.R.Anlage.User'     ,'');
  addToApi('Mat.R.TrackingYN'     ,'');
  addToApi('Mat.R.Workflow'     ,'');


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

  vArgs # VarAllocate(Sel_Args_000008);
  // ... und mit den empfangenen Argumenten füllen


  prepSelInt(aArgs,'Mat.R.Materialnr', var sel_MatNrJN,  var sel_MatNr,  var sel_MatNrNot,  var sel_MatNrVon,   var sel_MatNrBis,   var sel_MatNrAus);
  prepSelInt(aArgs,'Mat.R.Auftragsnr', var sel_AufNrJN,  var sel_AufNr,  var sel_AufNrNot,  var sel_AufNrVon,   var sel_AufNrBis,   var sel_AufNrAus);
  prepSelInt(aArgs,'Mat.R.Auftragspos',var sel_AufPosJN,  var sel_AufPos,  var sel_AufPosNot,  var sel_AufPosVon,   var sel_AufPosBis,   var sel_AufPosAus);
  prepSelInt(aArgs,'Mat.R.Kundennummer', var sel_KndNrJN,  var sel_KndNr,  var sel_KndNrNot,  var sel_KndNrVon,   var sel_KndNrBis,   var sel_KndNrAus);

  prepSelAlpha(aArgs,'Mat.R.Bemerkung',var sel_BemerkungJN, var sel_Bemerkung, var sel_BemerkungNot, var sel_BemerkungVon,  var sel_BemerkungBis,  var sel_BemerkungAus);

  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(203, 1, 'SVC_000008:Sel',vArgs);
  vAnz  # Lib_SOA:RunPartSel(vSel, 0, 0); // Max 0 = alle, RecId 0 = von Anfang an


  // Daten Node zum einfügen extrahieren
  vNode # aResponse->getNode('DATA');

  FOR  Erx # RecRead(203, SOA_PartSel_Sel, _RecFirst);
  LOOP Erx # RecRead(203, SOA_PartSel_Sel, _RecNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    vResNode # vNode->addRecord(203);

    case (toUpper(vFelderGrp)) of

      //-------------------------------------------------------------------------------
      'ALLE', '' : begin

        vDatei # 203;
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
          if (StrCut(vFldName,1,6) = 'MAT.R.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'MAT.R.STUECKZAHL'    : vFldName #  'Mat.R.Stückzahl';     // TDS 1: Hauptdaten
                'MAT.R.TRAEGERTYP'    : vFldName #  'Mat.R.Trägertyp';
                'MAT.R.TRAEGERNUMMER1' : vFldName #  'Mat.R.Trägernummer1';
                'MAT.R.TRAEGERNUMMER2' : vFldName #  'Mat.R.Trägernummer2';
                'MAT.R.TRAEGERNUMMER3' : vFldName #  'Mat.R.Trägernummer3';
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
  VarFree(Sel_Args_000008);
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
  VarInstance(Sel_Args_000008, SOA_PartSel_Args);

  if (SelInt(Mat.R.Materialnr,  sel_MatNrJN,  sel_MatNrNot, sel_MatNrAus, sel_MatNrVon, sel_MatNrBis)) then return false;
  if (SelInt(Mat.R.Auftragsnr,  sel_AufNrJN,  sel_AufNrNot, sel_AufNrAus, sel_AufNrVon, sel_AufNrBis)) then return false;
  if (SelInt(Mat.R.Auftragspos, sel_AufPosJN, sel_AufPosNot,sel_AufPosAus,sel_AufPosVon,sel_AufPosBis)) then return false;
  if (SelInt(Mat.R.Kundennummer,sel_KndNrJN,  sel_KndNrNot, sel_KndNrAus, sel_KndNrVon, sel_KndNrBis)) then return false;

  if (SelAlpha(Mat.R.Bemerkung, sel_BemerkungJN, sel_BemerkungNot, sel_BemerkungAus,  sel_BemerkungVon,sel_BemerkungBis)) then return false;

  return true;
end; // sub Sel() : logic



//=========================================================================
//=========================================================================
//=========================================================================