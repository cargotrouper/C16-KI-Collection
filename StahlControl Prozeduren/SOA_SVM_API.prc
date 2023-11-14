@A+
//==== Business-Control ===================================================
//
//  Prozedur    SOA_SVM_API
//                OHNE E_R_G
//  Info
//        Beinhaltet die Implementerung der API Behandlung
//
//  27.09.2010  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    sub checkPflichtfelder(aApi : handle; aArgs : handle; var aResponse : handle) : int
//    sub checkRules(aApi : handle; aArgs : handle; var aResponse : handle) : int
//    sub getPflichtfelderRek(aParent : handle; var aPflicht : handle)
//    sub getRulesRek(aParent : handle; var aChecks : handle)
//    sub apiAdd(aParent : handle; aFld : alpha; aFldTyp : int; aPflicht : logic; opt aWertVon : int; opt aWertBis : int; opt aWertAus  : alpha;opt aWertStd  : alpha;)  : handle
//    sub apiSetDesc(aParent : handle; aBeschr : alpha(4000); aBsp : alpha;) : handle
//    sub apiSetIntern(aParent : handle; aFeldname : alpha) : handle
//    sub apiCreateStd(opt aWritemode : logic) : handle
//
//=========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA

declare getPflichtfelderRek(aParent : handle; var aPflicht : handle)
declare getRulesRek(aParent : handle; var aChecks : handle)


//=========================================================================
//  sub checkPflichtfelder(...) : int
//
//  Überprüft die Argumente anhand der übergebenen API auf das vorhandensein
//  von allen Pflichtfeldern.
//
//  @Param
//        aApi      : handle    //  Handle der Apibeschreibung
//        aArgs     : handle    //  Argumente zur Überprüfung
//    var aResponse : handle    //  Referenz auf Antwortobjekt
//
//  @Return
//    int                       // Fehlercode
//
//=========================================================================
sub checkPflichtfelder(aApi : handle; aArgs : handle; var aResponse : handle) : int
local begin
  vPfFelder   : handle;       // Handle für die Liste der Pflichtfelder
  vNode       : handle;       // Iterationshandle für Pflichtfeldliste
  vArgNode    : handle;       // Handle für Prüfung eines Arguments

  vName : alpha;
  vCheckVal : alpha;
end
begin

  // alle Pflichtfelder aus API zusammenstellen
  vPfFelder # CteOpen(_CteList);
  getPflichtfelderRek(aApi, var vPfFelder);

  // Argumentliste auf Vollständigkeit der Pflichtfelder prüfen
  FOR  vNode # vPfFelder->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # vPfFelder->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) DO BEGIN

    // Schlüsselwert prüfen
    vName #vNode->spName
    vArgNode # aArgs->getNode(vName);
    if (vArgNode = 0) then begin

      // Wert nicht gefunden, dann Fehler anhängen
      vNode # aResponse->addErrNode(errSVC_argNotFound,
               vName +' muss angegeben werden');
      return errPrevent;

    end else begin

      // Prüfen ob Daten gefüllt sind
      vCheckVal # aArgs->getValue(vName);
      if (isEmpty(vCheckVal)) then begin
        // Wert gefunden, aber leer... dann Fehler anhängen
        vNode # aResponse->addErrNode(errSVC_argNotFound,
                  vName +' muss angegeben werden');
        return errPrevent;
      end;

    end;

  END;

  // Alles IO
  return _rOK;

end; // sub checkPflichtfelder(...)



//=========================================================================
//  sub checkRules(...) : int
//
//  Überprüft die übergebenen Argumente anhand der Apibeschreibung auf
//  Korrektheit wie z.B. Datentypen, Wertebereiche und ggf. Standardwerte
//
//  @Param
//        aApi      : handle    //  Handle der Apibeschreibung
//        aArgs     : handle    //  Argumente zur Überprüfung
//    var aResponse : handle    //  Referenz auf Antwortobjekt
//
//  @Return
//    int                       // Fehlercode
//
//=========================================================================
sub checkRules(aApi : handle; aArgs : handle; var aResponse : handle) : int
local begin
  vArgNode    : handle;       // Handle für Prüfung eines Arguments
  vCheckRules : handle;       // Handle für Liste der zu prüfenden Felder
  vKey        : alpha;        // Name des zu prüfenden Wertes
  vRules      : handle;       // Handle für eine gefundene Checkregelgruppe
  vRule       : handle;       // Handle für Regeliteration
  vRuleVal    : alpha(4096);  // Wert des übergebenen Argumentes
  vCheckVal   : alpha(4096);  // Wert des übergebenen Argumentes
  vCheck_typ  : alpha;        // Datentyp des Argumentes
  vCheck_Err  : int;          // Fehler bei Konvertierung
  vCheck_Int  : int;          // Prüfvariablen der verfügbaren Typen
  vCheck_Flt  : float;
  vCheck_Dec  : decimal;
  vCheck_Dt   : date;
  vCheck_Tm   : time;
end
begin

  // alle Checks aus API zusammenstellen
  vCheckRules # CteOpen(_CteNode, _CteChildList);
  getRulesRek(aApi, var vCheckRules);

  // Argumentliste auf Korrektheit der Checkwerte prüfen
  FOR  vArgNode # aArgs->CteRead(_CteFirst | _CteChildList)
  LOOP vArgNode # aArgs->CteRead(_CteNext  | _CteChildList, vArgNode)
  WHILE (vArgNode > 0) DO BEGIN

    // Aktuelles Feld:
    vKey # vArgNode->spName;
// dbg(vKey);

    // Lookup: Ist Feld zur Prüfung?
    vRules # vCheckRules->getNode(vKey);
    if (vRules <> 0) then begin

      // Wert des Schlüssels lesen
      vCheckVal # aArgs->getValue(vKey);

      // Datentyp für jedes Feld neu setzen
      vCheck_typ # '';

      // Angegebenes Feld ist für Prüfung bereit
      // Alle Prüfungen für dieses Feld anwenden
      FOR  vRule # vRules->CteRead(_CteFirst | _CteChildList)
      LOOP vRule # vRules->CteRead(_CteNext  | _CteChildList, vRule)
      WHILE (vRule > 0) do begin

        // Wert der zu prüfenden Checkregel
        vRuleVal  # vRule->spCustom;

        // Prüfung je nach Checktyp
        case(toUpper(vRule->spName)) of

          // -----------------------------------------------
          //   DATENTYP
          // -----------------------------------------------
          'DATENTYP'  : begin
            ErrTryCatch(_ErrCnv,true);
            try begin
              // Konvertierung in gewünschten Datentyp möglich?
              case (toUpper(vRuleVal)) of
                'STRING'  : begin /* String ist String...*/       end;
                'INTEGER' : begin vCheck_Int # CnvIA(vCheckVal);  end;
                'FLOAT'   : begin vCheck_Flt # CnvFA(vCheckVal);  end;
                'DECIMAL' : begin vCheck_Dec # CnvMA(vCheckVal);  end;
                'DATE'    : begin vCheck_Dt  # CnvDA(vCheckVal);  end;
                'TIME'    : begin vCheck_Tm  # CnvTA(vCheckVal);  end;
                'BOOLEAN' : begin
                    if (vCheckVal <> '0') AND (vCheckVal <> '1') then
                      ErrSet(1);
                end;
              end; // EO Case of Datentyp
            end; // EO Try

            // Fehler beim Konvertieren?
            if (ErrGet() <> 0) then begin
              aResponse->addErrNode(errSVC_argWrongType,
                        vRuleVal +' erwartet. (' +vCheckVal+')');
              return errPrevent;
            end;

            vCheck_typ # toUpper(vRuleVal); // Datentyp merken
          end;

          // -----------------------------------------------
          //   WERTVON
          // -----------------------------------------------
          'WERTVON'   : begin
            vCheck_Err # 0;
            case (toUpper(vCheck_typ)) of
              'STRING'  : begin
                if (toUpper(vRuleVal) > toUpper(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'INTEGER' : begin
                if (CnvIA(vRuleVal) > CnvIA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'FLOAT'   : begin
                if (CnvFA(vRuleVal) > CnvFA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'DECIMAL' : begin
                if (CnvMA(vRuleVal) > CnvMA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'DATE'    : begin
                if (CnvDA(vRuleVal) > CnvDA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'TIME'    : begin
                if (CnvTA(vRuleVal) > CnvTA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

            end; // EO Catch Datentyp

            // Fehler bei Wertebereichsprüfung?
            if (vCheck_Err <> 0) then begin
              aResponse->addErrNode(errSVC_argValueToLow,
                       vArgNode->spName+ ' >= '+vRuleVal+' ('+vCheckVal+')');
              return errPrevent;
            end;

          end; // EO WERTVON

          // -----------------------------------------------
          //   WERTBIS
          // -----------------------------------------------
          'WERTBIS'   : begin
            vCheck_Err # 0;
            case (toUpper(vCheck_typ)) of
              'STRING'  : begin
                if (toUpper(vRuleVal) < toUpper(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'INTEGER' : begin
                if (CnvIA(vRuleVal) < CnvIA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'FLOAT'   : begin
                if (CnvFA(vRuleVal) < CnvFA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'DECIMAL' : begin
                if (CnvMA(vRuleVal) < CnvMA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'DATE'    : begin
                if (CnvDA(vRuleVal) < CnvDA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

              'TIME'    : begin
                if (CnvTA(vRuleVal) < CnvTA(vCheckVal)) then
                  vCheck_Err # errPrevent;
              end;

            end; // EO Catch Datentyp

            // Fehler bei Wertebereichsprüfung?
            if (vCheck_Err <> 0) then begin
              aResponse->addErrNode(errSVC_argValueToHigh,
                          vArgNode->spName+' <= '+vRuleVal+' ('+vCheckVal+')');
              return errPrevent;
            end;

          end; // EO WERTBIS

          // -----------------------------------------------
          //   WERT AUS
          // -----------------------------------------------
          'WERTAUS' : begin
            if (StrFind(StrAdj(vRuleVal,_StrAll)+'|',
                        vCheckVal+'|',1,_StrCaseIgnore) = 0) then begin
              aResponse->addErrNode(errSVC_argChoice,
                          vArgNode->spName+' aus ('+vRuleVal+') nicht gefunden: '+vCheckVal+'');
              return errPrevent;
            end;
          end; // EO WERTAUS

          // -----------------------------------------------
          //   STANDARDWERT
          // -----------------------------------------------
          'STANDARDWERT' : begin

            if (isEmpty(vCheckval)) then begin
              if !(aArgs->setValue(vKey,vRuleVal)) then begin
                aResponse->addErrNode(errSVC_argGeneral,
                            'Standardwert '+vRuleVal+' konnte nicht gesetzt werden. ('+vKey+')');
                return errPrevent;
              end;
            end;

          end; // EO STANDARDWERT

        end; // EO case Checktyp

      END; // EO Loop Checkregeln

    end; // EO if (vRules <> 0)

  END; // EO Attribprüfung


  // ---------------------------------------------
  // Keine Fehler gefunden --> API OK
  return _rOK;

end; // sub checkRules(...)





//=========================================================================
//  sub getPflichtfelderRek(...)
//
//  Liest anhand der API Beschreibung der Implementierung rekursiv die zu
//  prüfenden Pflichtfelder aus.
//
//  @Param
//        aParent   : handle    //  Vorheriges Nodeelement
//    var aPflicht  : handle    //  Referenz auf Pflichtfeldliste
//
//  @Return
//    -
//
//=========================================================================
sub getPflichtfelderRek(aParent : handle; var aPflicht : handle)
local begin
  vNode   : handle;     // Iterationsobjekt
  vAttrib : handle;     // Attributlistenobjekt
  vItem   : handle;     // Eintrag für Pflichtfeldliste
  vCheck  : handle;     // Nodeelement für "check" Knoten
end;
begin

  // alle Pflichtfelder in Api suchen
  FOR  vNode # aParent->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aParent->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin

    if (vNode->spID  = _XmlNodeElement) then begin
      // XML Node Element
      // Hat Checkregel?
      vCheck # vNode->getNode('CHECK');
      if (vCheck <> 0) then begin

        // Hat Checkregel, dann Attribute durchgehen
        FOR  vAttrib # vCheck->CteRead(_CteFirst | _CteAttribList)
        LOOP vAttrib # vCheck->CteRead(_CteNext  | _CteAttribList,vAttrib)
        WHILE (vAttrib > 0) do begin

          // Eintrag für Liste erstellen
          if (toUpper(vAttrib->spName) = 'PFLICHT') AND
             (toUpper(vAttrib->spValueAlpha) = '1') then begin
            vItem           # CteOpen(_CteItem);
            vItem->spName   # vNode->spName;

            // in Liste anhängen
            aPflicht->CteInsert(vItem);
          end;

        END;

      end else begin
        // hat keine Checkregel, dann Kinder prüfen

        // hat Kinder?
        if (vNode->spChildCount > 0) then
          getPflichtfelderRek(vNode, var aPflicht);

      end;

    end; // if (vNode->spID  = _XmlNodeElement)




  END;

end; // sub _getPflichtfelderRek(...)



//=========================================================================
//  sub getRulesRek(...)
//
//  Extrahiert aus der API Beschreibung eines Services alle Checkregeln
//  und schreibt diese in übergebene flache NodeStruktur zurück
//
//  @Param
//        aParent   : handle    //  Vorheriges Nodeelement
//    var aChecks   : handle    //  Referenz auf Checkliste
//
//  @Return
//    -
//
//=========================================================================
sub getRulesRek(aParent : handle; var aChecks : handle)
local begin
  vNode   : handle;   // Iterationshandle
  vCheck  : handle;   // Handle auf "Check" Knoten
  vKey    : handle;   // Knotenpunkt der Checks für diesen Schlüssel
  vAttrib : handle;   // Attributiterationshandle
  vItem   : handle;   // Checklisteneintrag
end;
begin

   // alle Checkregeln in Api suchen
  FOR  vNode # aParent->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aParent->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin

    if (vNode->spID  = _XmlNodeElement) then begin

      // Nicht ausführungsrelevanten API Elemente müssen nicht geprüft werden
      case (toUpper(vNode->spName)) of
        'SERVICE',
        'SENDER',
        'KEY' : begin
          CYCLE;
        end;
      end;

      // Hat Checkregel?
      vCheck # vNode->getNode('CHECK');
      if (vCheck <> 0) then begin

        // Feld als Knoten einbauen
        vKey # CteOpen(_CteNode);
        vKey->spName # vNode->spName;
// dbg(vKey->spName);

        // Hat Checkregel, dann Attribute durchgehen
        FOR  vAttrib # vCheck->CteRead(_CteFirst | _CteAttribList)
        LOOP vAttrib # vCheck->CteRead(_CteNext  | _CteAttribList,vAttrib)
        WHILE (vAttrib > 0) do begin

          // Folgende Attribute nicht in die Liste aufnehmen
          if (toUpper(vAttrib->spName) = 'PFLICHT') then
            CYCLE;

          // Eintrag für Liste erstellen und anhängen
          vItem # CteOpen(_CteNode);
          vItem->spName   # vAttrib->spName;
          vItem->spCustom # vAttrib->spValueAlpha;

          vKey->CteInsert(vItem, _CteChild);
        END;

        // Checkregeln für diesen Schlüssel anhängen
        aChecks->CteInsert(vKey);

      end else begin
        // hat keine Checkregel, dann Kinder prüfen

        // hat Kinder?
        if (vNode->spChildCount > 0) then
          getRulesRek(vNode, var aChecks);

      end;

    end; // if (vNode->spID  = _XmlNodeElement)

  END;

end; // sub getRulesRek(...)




//=========================================================================
//  sub apiAdd(...) : handle
//
//  Fügt der API Beschreibung ein neues Feld hinzu
//
//  @Param
//    aParent       : handle      //  Parentknoten
//    aFld          : alpha       //  Feldbezeichnung
//    aFldTyp       : int         //  Feldtyp
//    aPflicht      : logic       //  Pflichtfeld
//    opt aWertVon  : int         //  Wertebereich von
//    opt aWertBis  : int         //  Wertebereich bis
//    opt aWertAus  : alpha       //  Wertmenge von möglichen Elementen
//    opt aWertStd  : alpha       //  Standardwert
//
//  @Return
//    handle                      // Handle des eingefügten Nodes
//
//=========================================================================
sub apiAdd(
  aParent       : handle;     //  Parentknoten
  aFld          : alpha;      //  Feldbezeichnung
  aFldTyp       : int;        //  Feldtyp
  opt aPflicht  : logic;      //  Pflichtfeld
  opt aWertVon  : int;        //  Wertebereich von
  opt aWertBis  : int;        //  Wertebereich bis
  opt aWertAus  : alpha;      //  Wertmenge von möglichen Elementen
  opt aWertStd  : alpha;      //  Standardwert
)  : handle
local begin
  vNode : handle;
  vCheck : handle;
end;
begin

  // Feldbezeichnung als Hauptelement
  vNode # aParent->Lib_XML:AppendNode(toUpper(aFld));

  // Checkregel Node einfügen
  vCheck # vNode->Lib_XML:AppendNode(toUpper('Check'));

  // Feldtyp
  case (aFldTyp) of
    _TypeAlpha    : vCheck->Lib_XML:AppendAttributeNode('Datentyp','String');
    _TypeInt      : vCheck->Lib_XML:AppendAttributeNode('Datentyp','Integer');
    _TypeFloat    : vCheck->Lib_XML:AppendAttributeNode('Datentyp','Float');
    _TypeBool     : vCheck->Lib_XML:AppendAttributeNode('Datentyp','Boolean');
    _TypeDecimal  : vCheck->Lib_XML:AppendAttributeNode('Datentyp','Decimal');
    _TypeDate     : vCheck->Lib_XML:AppendAttributeNode('Datentyp','Date');
    _TypeTime     : vCheck->Lib_XML:AppendAttributeNode('Datentyp','Time');
  end;

  // Pflichtfeld?
  if (aPflicht) then
    vCheck->Lib_XML:AppendAttributeNode('Pflicht','1')
  else
    vCheck->Lib_XML:AppendAttributeNode('Pflicht','0');

  // Wertebereich angegeben?
  if (aWertVon <> 0) then
    vCheck->Lib_XML:AppendAttributeNode('WertVon',CnvAi(aWertVon));
  if (aWertBis <> 0) then
    vCheck->Lib_XML:AppendAttributeNode('WertBis',CnvAi(aWertBis));
  if (aWertAus <> '') then
    vCheck->Lib_XML:AppendAttributeNode('WertAus',aWertAus);

  // Standardwert angegeben?
  if (aWertStd <> '') then
    vCheck->Lib_XML:AppendAttributeNode('Standardwert',aWertStd);

  // Hauptnode des Schlüsselwortes zurückgeben
  return vNode;
end; // apiAdd(...)



//=========================================================================
//  sub apiSetDesc(...) : handle
//
//  Fügt derAPI Beschreibung eines Feldes eine leserliche Beschreibung hinzu
//
//  @Param
//        aParent   : handle      //  Parentknoten
//        aBeschr   : alpha       //  Beschreibung des Feldes
//   opt  aBsp      : alpha       //  Beispieldaten
//
//  @Return
//    handle                      // Handle des eingefügten Nodes
//
//=========================================================================
sub apiSetDesc(aParent : handle; aBeschr : alpha(4000); aBsp : alpha;) : handle
local begin
  vInfo : handle;
end;
begin
  vInfo # aParent->Lib_XML:AppendNode('INFO');
  vInfo->Lib_XML:AppendAttributeNode('Beschreibung',aBeschr);
  vInfo->Lib_XML:AppendAttributeNode('Beispiel',aBsp);
  return vInfo;
end; // sub apiSetDesc(...)



//=========================================================================
//  sub apiSetDesc(...) : handle
//
//  Fügt derAPI Beschreibung eines Feldes interne Informationen hinzu
//
//  @Param
//    aParent   : handle      //  Parentknoten
//    aFeldname : alpha       //  Names eines Refrenzfeldes
//
//  @Return
//    handle                  // Handle des eingefügten Nodes
//
//=========================================================================
sub apiSetIntern(aParent : handle; aFeldname : alpha) : handle
local begin
  vIntern : handle;
end;
begin
  vIntern # aParent->Lib_XML:AppendNode('INTERN');
  vIntern->Lib_XML:AppendAttributeNode('SCFLD',aFeldname);
  return vIntern;
end; // sub apiSetIntern(...)


//=========================================================================
//  sub apiCreateStd() : handle
//
//  Erstellt eine StandardAPI Beschreibung
//
//  @Param
//
//  @Return
//    handle                  // Handle des eingefügten Nodes
//
//=========================================================================
sub apiCreateStd(opt aWritemode : logic) : handle
local begin
  vApi  : handle;
  vRoot : handle;
  vNode : handle;
end;
begin
  vAPI        # CteOpen(_cteNode);
  vAPI->spId  # _xmlNodeDocument;
  vRoot       # vAPI->Lib_XML:AppendNode('SCAPI');

  // ------------------------------
  // STANDARDDEFINITION

  // Servicenamen
  vNode # vRoot->apiAdd('SERVICE',_TypeAlpha,true);
  vNode->apiSetDesc('ID des angefragten Service','KNDFMAT');

  // Sender
  vNode # vRoot->apiAdd('SENDER',_TypeAlpha,true);
  vNode->apiSetDesc('Ihre Servicekennung. Wird vom Anbieter übermittelt','A123/4');

  // Key
  vNode # vRoot->apiAdd('KEY',_TypeAlpha,false);
  vNode->apiSetDesc('Ihr Servicekey. Wird vom Anbieter übermittelt','!"§§2wedsfsAS§SDFSD');


  // Schreibmodus um Apiprüfung zu verlagern
  if (aWriteMode) then begin
    vNode # vRoot->apiAdd('WRITE',_TypeLogic,true,null,null,null,'0');
    vNode->apiSetDesc('Signalisiert einen schreibenden Service','1');
  end;

  return vRoot;
end; // sub apiCreateStd(...)


//=========================================================================
//=========================================================================
//=========================================================================
