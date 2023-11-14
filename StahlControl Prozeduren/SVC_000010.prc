@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000010
//                  OHNE E_R_G
//  Zu Service: MAT_Akt_SEL
//
//  Info
///  MAT_AKT_SEL: Lesen von Materialaktionen und Rückgabe der angegeben Felder
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
global Sel_Args_000010 begin
  Tmp : alpha;

  // Materialnr  Mat.R.Materialnr
  sel_MatNrJN  : logic;
  sel_MatNr,
  sel_MatNrVon,
  sel_MatNrBis : int;
  sel_MatNrNot,
  sel_MatNrAus : alpha;

  // Aktionstyp     Mat.A.Aktionstyp
  sel_AktionstypJN  : logic;
  sel_Aktionstyp,
  sel_AktionstypVon,
  sel_AktionstypBis,
  sel_AktionstypNot,
  sel_AktionstypAus : alpha;

  // Aktionsnr      Mat.A.Aktionsnr
  sel_AktionsNrJN  : logic;
  sel_AktionsNr,
  sel_AktionsNrVon,
  sel_AktionsNrBis : int;
  sel_AktionsNrNot,
  sel_AktionsNrAus : alpha;

  // Aktionsnr      Mat.A.Aktionspos
  sel_AktionsPosJN  : logic;
  sel_AktionsPos,
  sel_AktionsPosVon,
  sel_AktionsPosBis : int;
  sel_AktionsPosNot,
  sel_AktionsPosAus : alpha;

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
  vNode->apiSetDesc('Folgende Felder können abgefragt werden: Mat.A.Materialnr, Mat.A.Aktionstyp, Mat.A.Aktionsnr, Mat.A.Aktionspos','');
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
  addToApi('Mat.A.Materialnr'     ,'');
  addToApi('Mat.A.Aktion'     ,'');
  addToApi('Mat.A.Aktionsmat'     ,'');
  addToApi('Mat.A.Entstanden'     ,'');
  addToApi('Mat.A.Aktionstyp'     ,'');
  addToApi('Mat.A.Aktionsnr'     ,'');
  addToApi('Mat.A.Aktionspos'     ,'');
  addToApi('Mat.A.Aktionspos2'     ,'');
  addToApi('Mat.A.Aktionspos3'     ,'');
  addToApi('Mat.A.Aktionsdatum'     ,'');
  addToApi('Mat.A.TerminStart'     ,'');
  addToApi('Mat.A.TerminEnde'     ,'');
  addToApi('Mat.A.Adressnr'     ,'');
  addToApi('Mat.A.Stueckzahl'     ,'');
  addToApi('Mat.A.Gewicht'     ,'');
  addToApi('Mat.A.Nettogewicht'     ,'');
  addToApi('Mat.A.Bemerkung'     ,'');
  addToApi('Mat.A.KostenW1'     ,'');
  addToApi('Mat.A.Kosten2W1'     ,'');
  addToApi('Mat.A.Kostenstelle'     ,'');

  // Protokoll
  addToApi('Mat.A.Anlage.Datum'     ,'');
  addToApi('Mat.A.Anlage.Zeit'     ,'');
  addToApi('Mat.A.Anlage.User'     ,'');


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

  vArgs # VarAllocate(Sel_Args_000010);
  // ... und mit den empfangenen Argumenten füllen
  prepSelInt(aArgs,'Mat.A.Materialnr', var sel_MatNrJN,  var sel_MatNr,  var sel_MatNrNot,  var sel_MatNrVon,   var sel_MatNrBis,   var sel_MatNrAus);
  prepSelAlpha(aArgs,'Mat.A.Aktionstyp',var sel_AktionstypJN, var sel_Aktionstyp, var sel_AktionstypNot, var sel_AktionstypVon,  var sel_AktionstypBis,  var sel_AktionstypAus);
  prepSelInt(aArgs,'Mat.A.Aktionsnr', var sel_AktionsNrJN,  var sel_AktionsNr,  var sel_AktionsNrNot,  var sel_AktionsNrVon,   var sel_AktionsNrBis,   var sel_AktionsNrAus);
  prepSelInt(aArgs,'Mat.A.Aktionspos',var sel_AktionsPosJN,  var sel_AktionsPos,  var sel_AktionsPosNot,  var sel_AktionsPosVon,   var sel_AktionsPosBis,   var sel_AktionsPosAus);



  // --------------------------------------------------------------------------
  // Daten selektieren
  vSel  # Lib_SOA:CreatePartSel(204, 1, 'SVC_000010:Sel',vArgs);
  vAnz  # Lib_SOA:RunPartSel(vSel, 0, 0); // Max 0 = alle, RecId 0 = von Anfang an


  // Daten Node zum einfügen extrahieren
  vNode # aResponse->getNode('DATA');

  FOR  Erx # RecRead(204, SOA_PartSel_Sel, _RecFirst);
  LOOP Erx # RecRead(204, SOA_PartSel_Sel, _RecNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    vResNode # vNode->addRecord(204);

    case (toUpper(vFelderGrp)) of

      //-------------------------------------------------------------------------------
      'ALLE', '' : begin

        vDatei # 204;
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
          if (StrCut(vFldName,1,6) = 'MAT.A.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'MAT.A.STUECKZAHL'    : vFldName #  'Mat.A.Stückzahl';     // TDS 1: Hauptdaten
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
  VarFree(Sel_Args_000010);
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
  VarInstance(Sel_Args_000010, SOA_PartSel_Args);

  if (SelInt(Mat.A.Materialnr,  sel_MatNrJN,  sel_MatNrNot, sel_MatNrAus, sel_MatNrVon, sel_MatNrBis)) then return false;
  if (SelAlpha(Mat.A.Aktionstyp, sel_AktionstypJN, sel_AktionstypNot, sel_AktionstypAus,  sel_AktionstypVon,sel_AktionstypBis)) then return false;
  if (SelInt(Mat.A.Aktionsnr,  sel_AktionsNrJN,  sel_AktionsNrNot, sel_AktionsNrAus, sel_AktionsNrVon, sel_AktionsNrBis)) then return false;
  if (SelInt(Mat.A.Aktionspos, sel_AktionsPosJN, sel_AktionsPosNot,sel_AktionsPosAus,sel_AktionsPosVon,sel_AktionsPosBis)) then return false;

  return true;
end; // sub Sel() : logic



//=========================================================================
//=========================================================================
//=========================================================================