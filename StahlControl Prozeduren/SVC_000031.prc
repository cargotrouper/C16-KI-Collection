@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000031
//                  OHNE E_R_G
//  Zu Service: BAG_POS:SEL
//
//  Info
///  BAG_POS_SEL: Lesen von Betriebsauftragspositionen und Rückgabe der angegeben Felder
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
global Sel_Args_000031 begin
  Tmp : alpha;

  // BA nummer          BAG.P.Nummer
  sel_BAGNrJN  : logic;
  sel_BAGNr,
  sel_BAGNrVon,
  sel_BAGNrBis : int;
  sel_BAGNrNot,
  sel_BAGNrAus : alpha;

  // Löschmarker         BAG.P.Löschmarker
  sel_LoeschmJN  : logic;
  sel_Loeschm,
  sel_LoeschmVon,
  sel_LoeschmBis,
  sel_LoeschmNot,
  sel_LoeschmAus : alpha;

  // Aktion              BAG.P.Aktion
  sel_AktionJN  : logic;
  sel_Aktion,
  sel_AktionVon,
  sel_AktionBis,
  sel_AktionNot,
  sel_AktionAus : alpha;

  // Externer Lief.      Bag.P.ExterneLiefNr
  sel_LiefNrJN  : logic;
  sel_LiefNr,
  sel_LiefNrVon,
  sel_LiefNrBis : int;
  sel_LiefNrNot,
  sel_LiefNrAus : alpha;

   // StartDatum         Bag.P.Plan.StartDat
  sel_StartDatJN  : logic;
  sel_StartDat,
  sel_StartDatVon,
  sel_StartDatBis : date;
  sel_StartDatNot,
  sel_StartDatAus : alpha;

   // EndeDatum         Bag.P.Plan.EndDat
  sel_EndDatJN  : logic;
  sel_EndDat,
  sel_EndDatVon,
  sel_EndDatBis : date;
  sel_EndDatNot,
  sel_EndDatAus : alpha;

  // FertigDatum         Bag.P.Fertig.Dat
  sel_FertigDatJN  : logic;
  sel_FertigDat,
  sel_FertigDatVon,
  sel_FertigDatBis : date;
  sel_FertigDatNot,
  sel_FertigDatAus : alpha;

  // Ressourcengruppe     Bag.P.Ressource.Grp
  sel_RscGrpJN  : logic;
  sel_RscGrp,
  sel_RscGrpVon,
  sel_RscGrpBis : int;
  sel_RscGrpNot,
  sel_RscGrpAus : alpha;

  // Ressource            Bag.P.Ressource
  sel_RscJN  : logic;
  sel_Rsc,
  sel_RscVon,
  sel_RscBis : int;
  sel_RscNot,
  sel_RscAus : alpha;
end;



define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;

  c_DATEI       : 702
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


  // ----------------------------------
  // Ausgabewünsche
  // ----------------------------------


  // Haupdaten
  addToApi('','');
  addToApi('BAG.P.Nummer','');
  addToApi('BAG.P.Position','');
  addToApi('BAG.P.Loeschmarker','');
  addToApi('BAG.P.Aktion','');
  addToApi('BAG.P.Aktion2','');
  addToApi('BAG.P.Bezeichnung','');
  addToApi('BAG.P.ExternYN','');
  addToApi('BAG.P.ExterneLiefNr','');
  addToApi('BAG.P.Kommission','');
  addToApi('BAG.P.Auftragsnr','');
  addToApi('BAG.P.AuftragsPos','');
  addToApi('BAG.P.Zieladresse','');
  addToApi('BAG.P.Zielanschrift','');
  addToApi('BAG.P.Zielstichwort','');
  addToApi('BAG.P.ZielVerkaufYN','');
  addToApi('BAG.P.Teilungen','');
  addToApi('BAG.P.Level','');
  addToApi('BAG.P.Typ.1In-1OutYN','');
  addToApi('BAG.P.Typ.1In-yOutYN','');
  addToApi('BAG.P.Typ.xIn-yOutYN','');
  addToApi('BAG.P.Typ.VSBYN','');
  addToApi('BAG.P.Bemerkung','');
  addToApi('BAG.P.Referenznr','');

  // Terminierung
  addToApi('BAG.P.Fenster.MinDat','');
  addToApi('BAG.P.Fenster.MinZei','');
  addToApi('BAG.P.Fenster.MaxDat','');
  addToApi('BAG.P.Fenster.MaxZei','');
  addToApi('BAG.P.Plan.StartDat','');
  addToApi('BAG.P.Plan.StartZeit','');
  addToApi('BAG.P.Plan.StartInfo','');
  addToApi('BAG.P.Plan.Dauer','');
  addToApi('BAG.P.Plan.EndDat','');
  addToApi('BAG.P.Plan.EndZeit','');
  addToApi('BAG.P.Plan.EndInfo','');
  addToApi('BAG.P.Fertig.Dat','');
  addToApi('BAG.P.Fertig.Zeit','');
  addToApi('BAG.P.Fertig.User','');
  addToApi('BAG.P.FormelID','');
  addToApi('BAG.P.FormelBez','');
  addToApi('BAG.P.Ressource.Grp','');
  addToApi('BAG.P.Ressource','');
  addToApi('BAG.P.Reihenfolge','');

  // kosten
  addToApi('BAG.P.Kosten.Wae','');
  addToApi('BAG.P.Kosten.Fix','');
  addToApi('BAG.P.Kosten.Pro','');
  addToApi('BAG.P.Kosten.PEH','');
  addToApi('BAG.P.Kosten.MEH','');
  addToApi('BAG.P.Kosten.Gesamt','');
  addToApi('BAG.P.Kosten.Ges.Stk','');
  addToApi('BAG.P.Kosten.Ges.Gew','');
  addToApi('BAG.P.Kosten.Ges.Men','');
  addToApi('BAG.P.Kosten.Ges.MEH','');

  // Protokoll
  addToApi('BAG.P.Anlage.Datum','');
  addToApi('BAG.P.Anlage.Zeit','');
  addToApi('BAG.P.Anlage.User','');
  addToApi('BAG.P.Planlock.UsrID','');



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

  vArgs # VarAllocate(Sel_Args_000031);
  // ... und mit den empfangenen Argumenten füllen

  prepSelInt(aArgs,'Bag.P.Nummer',
                    var sel_BagNrJN,
                    var sel_BagNr,
                    var sel_BagNrNot,
                    var sel_BagNrVon,
                    var sel_BagNrBis,
                    var sel_BagNrAus);

  prepSelAlpha(aArgs,'Bag.P.Loeschmarker',
                    var sel_LoeschmJN,
                    var sel_Loeschm,
                    var sel_LoeschmNot,
                    var sel_LoeschmVon,
                    var sel_LoeschmBis,
                    var sel_LoeschmAus);

  prepSelAlpha(aArgs,'Bag.P.Aktion',
                    var sel_AktionJN,
                    var sel_Aktion,
                    var sel_AktionNot,
                    var sel_AktionVon,
                    var sel_AktionBis,
                    var sel_AktionAus);

  prepSelInt(aArgs,'Bag.P.ExterneLiefNr',
                    var sel_LiefNrJN,
                    var sel_LiefNr,
                    var sel_LiefNrNot,
                    var sel_LiefNrVon,
                    var sel_LiefNrBis,
                    var sel_LiefNrAus);

  prepSelDate(aArgs,'Bag.P.Plan.StartDat',
                    var sel_StartDatJN,
                    var sel_StartDat,
                    var sel_StartDatNot,
                    var sel_StartDatVon,
                    var sel_StartDatBis,
                    var sel_StartDatAus);

  prepSelDate(aArgs,'Bag.P.Plan.EndDat',
                    var sel_EndDatJN,
                    var sel_EndDat,
                    var sel_EndDatNot,
                    var sel_EndDatVon,
                    var sel_EndDatBis,
                    var sel_EndDatAus);

  prepSelDate(aArgs,'Bag.P.Fertig.Dat',
                    var sel_FertigDatJN,
                    var sel_FertigDat,
                    var sel_FertigDatNot,
                    var sel_FertigDatVon,
                    var sel_FertigDatBis,
                    var sel_FertigDatAus);

  prepSelInt(aArgs,'Bag.P.Ressource.Grp',
                    var sel_RscGrpJN,
                    var sel_RscGrp,
                    var sel_RscGrpNot,
                    var sel_RscGrpVon,
                    var sel_RscGrpBis,
                    var sel_RscGrpAus);

  prepSelInt(aArgs,'Bag.P.Ressource',
                    var sel_RscJN,
                    var sel_Rsc,
                    var sel_RscNot,
                    var sel_RscVon,
                    var sel_RscBis,
                    var sel_RscAus);

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
  vSel  # Lib_SOA:CreatePartSel(c_DATEI, 1, 'SVC_000031:Sel',vArgs);
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
//              'Ein.P.Stück\VE'  : vFldName # 'Ein.P.StückVE';
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
          if (StrCut(vFldName,1,6) = 'BAG.P.') then begin

            if (CnvIA(aArgs->getValue(vFldName)) = 1) then begin

              // Felder mit Umlauten mappen
              CASE (toUpper(vFldName)) OF
                'BAG.P.LOESCHMARKER'    : vFldName #  'Bag.P.Löschmarker';
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
  VarFree(Sel_Args_000031);
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
  VarInstance(Sel_Args_000031, SOA_PartSel_Args);

  if (SelInt( Bag.P.Nummer,
              sel_BAGNrJN,
              sel_BAGNrNot,
              sel_BAGNrAus,
              sel_BAGNrVon,
              sel_BAGNrBis)) then return false;

  if (SelAlpha( "BAG.P.Löschmarker",
              sel_LoeschmJN,
              sel_LoeschmNot,
              sel_LoeschmAus,
              sel_LoeschmVon,
              sel_LoeschmBis)) then return false;

  if (SelAlpha( BAG.P.Aktion,
              sel_AktionJN,
              sel_AktionNot,
              sel_AktionAus,
              sel_AktionVon,
              sel_AktionBis)) then return false;

  if (SelInt(  Bag.P.ExterneLiefNr,
              sel_LiefNrJN,
              sel_LiefNrNot,
              sel_LiefNrAus,
              sel_LiefNrVon,
              sel_LiefNrBis)) then return false;

  if (SelDate(  Bag.P.Plan.StartDat,
              sel_StartDatJN,
              sel_StartDatNot,
              sel_StartDatAus,
              sel_StartDatVon,
              sel_StartDatBis)) then return false;

  if (SelDate( Bag.P.Plan.EndDat,
              sel_EndDatJN,
              sel_EndDatNot,
              sel_EndDatAus,
              sel_EndDatVon,
              sel_EndDatBis)) then return false;

  if (SelDate( Bag.P.Fertig.Dat,
              sel_FertigDatJN,
              sel_FertigDatNot,
              sel_FertigDatAus,
              sel_FertigDatVon,
              sel_FertigDatBis)) then return false;

  if (SelInt( Bag.P.Ressource.Grp,
              sel_RscGrpJN,
              sel_RscGrpNot,
              sel_RscGrpAus,
              sel_RscGrpVon,
              sel_RscGrpBis)) then return false;

  if (SelInt( Bag.P.Ressource,
              sel_RscJN,
              sel_RscNot,
              sel_RscAus,
              sel_RscVon,
              sel_RscBis)) then return false;

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