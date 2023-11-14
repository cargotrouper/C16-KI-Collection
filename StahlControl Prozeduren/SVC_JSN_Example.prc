@A+
//==== Business-Control ===================================================
//
//  Prozedur    SVC_JSN_Example
//
//  Service     BAGEXAMPLE
//                  OHNE E_R_G
//  Info
//        Liefert eine Binärdatei über den HTTP-Service für die mobile
//        Anwendung zurück.
//
//  2022-08-22  ST  Erstellung
//
//  Subprozeduren
//    sub api() : handle
//    sub exec ( aArgs : handle; var aResponse : handle ) : int
//    sub execMemory ( aArgs : handle; var aMem : handle; var aContentType : alpha ) : int
//=========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API

define begin
  LogActive     : true
  Log(a)        : if (LogActive) then Lib_Soa:Dbg(CnvAd(today) + ' ' + cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+ '['+__PROC__+':'+aint(__LINE__)+']' + ':' + a);
  LogErr(a) :    begin  Log(a); Error(99,a); end;
end;

//=========================================================================
// api
//        Definiert die API-Beschreibung für den implementierten Service.
//=========================================================================
sub api() : handle
local begin
  vApi  : handle;
  vNode : handle;
end;
begin
  vApi  # apiCreateStd();

  // Parameter: name
  vNode # vApi->apiAdd('Nummer', _typeInt, true);
  vNode->apiSetDesc('Betriebsauftragsnummer', '1234');

  // Parameter: type
  vNode # vApi->apiAdd('Position', _TypeInt, true);
  vNode->apiSetDesc('Betriebsauftragsposition', '5');

  RETURN vApi;
end;


//=========================================================================
// exec
//        Führt den Service aus.
//        Gibt den MemoryExec Fehlercode zurück, um die Ausführung der
//        `execMemory`-Prozedur zu bewirken.
//=========================================================================
sub exec ( aArgs : handle; var aResponse : handle ) : int
begin
  RETURN errSVL_ExecMemory;
end;


//=========================================================================
// execMemory
//        Führt den Service mit einer direkten Binärausgabe aus.
//        Bla.
//=========================================================================
sub execMemory (aArgs : handle; var aMem : handle; var aContentType : alpha ) : int
local begin
  Erx       : int;
  vSender   : alpha;
  
  vJsonCte  : handle;
  vBagNr    : int;
  vBagPos   : int;
    
  vJsonBagPos         : handle;
  vJsonBagPosInner    : handle;
    
  vJsonEinsaetze      : handle;
  vJsonEinsaetzInner  : handle;

  vJsonEinsaetzVorgaenger     : handle;
  vJsonEinsaetzVorgaengerInner  : handle;
  
  
  vJsonFertigungen    : handle;
  vJsonFertigungInner : handle;
end
begin
  Lib_Soa:Allocate();

  Lib_XML:GetValueI(   Lib_Soa:getNode(aArgs,'NUMMER'),   var vBagNr);
  Lib_XML:GetValueI(   Lib_Soa:getNode(aArgs,'POSITION'), var vBagPos);
      
  vJsonCte # Lib_Json:OpenJSON();
  //----------------------------------------------------------
  
  Bag.P.Nummer    # vBagNr;
  Bag.P.Position  # vBagPos;
  Erx # RecREad(702,1,0);
  if (Erx <> _rOK) then
    RecBufClear(702);

  Log('Bag Gelesen' + Aint(Bag.P.Nummer) + '/' + Aint(Bag.P.Position));
  
  vJsonBagPos       # vJsonCte->CteInsertNode('BAG.Position', _JSONNodeArray, NULL);
  vJsonBagPosInner  # vJsonBagPos->CteInsertNode('', _JsonNodeObject, NULL);
    
  vJsonBagPosInner->CteInsertNode('Bag.P.Nummer',   _JsonNodeNumber, Aint(Bag.P.Nummer)   );
  vJsonBagPosInner->CteInsertNode('Bag.P.Position', _JsonNodeNumber, Aint(Bag.P.Position) );
    
  
  vJsonEinsaetze  #   vJsonBagPosInner->CteInsertNode('Einsaetze', _JSONNodeArray, NULL);
  
  vJsonEinsaetzInner  # vJsonEinsaetze->CteInsertNode('', _JsonNodeObject, NULL);
  vJsonEinsaetzInner->CteInsertNode('Mat.Nummer',   _JsonNodeNumber, Aint(123)   );
  vJsonEinsaetzInner->CteInsertNode('Mat.Dicke',   _JsonNodeNumber, Aint(123)   );
  
  // Vorgänger
  vJsonEinsaetzVorgaenger       # vJsonEinsaetzInner->CteInsertNode('Vorgaenger', _JSONNodeArray, NULL);
  vJsonEinsaetzVorgaengerInner  # vJsonEinsaetzVorgaenger->CteInsertNode('', _JsonNodeObject, NULL);
  vJsonEinsaetzVorgaengerInner->CteInsertNode('Mat.Nummer',   _JsonNodeNumber, Aint(123)   );
  vJsonEinsaetzVorgaengerInner->CteInsertNode('Mat.Dicke',   _JsonNodeNumber, Aint(123)   );
  
  
  vJsonEinsaetzInner  # vJsonEinsaetze->CteInsertNode('', _JsonNodeObject, NULL);
  vJsonEinsaetzInner->CteInsertNode('Mat.Nummer',   _JsonNodeNumber, Aint(321)   );
  vJsonEinsaetzInner->CteInsertNode('Mat.Dicke',   _JsonNodeNumber, Aint(50)   );


  
  
  
  //Lib_Json:RecToJson(var vJsonCte, 702, 'Bag.Position');
 
  // Einsätze
  vJsonEinsaetze # vJsonCte->CteInsertNode('Einsaetze', _JSONNodeArray, NULL);
  FOR   Erx # RecLink(701,702,2,_RecFirst)
  LOOP  Erx # RecLink(701,702,2,_RecNext)
  WHILE Erx = _rOK DO BEGIN
/*
    vJsonEinsaetze  # vJsonEinsaetze->CteInsertNode('', _JsonNodeObject, NULL);
    vJsonFertigungInner->CteInsertNode('Horst', _JsonNodeString, 'Echte Falsche, echte falsche');
    vJsonFertigungInner->CteInsertNode('Horst', _JsonNodeString, 'Echte Falsche, echte falsche');
*/
    Lib_Json:RecToJson(var vJsonEinsaetze, 701, 'Bag.IO.Einsatz');
    // Mat Vorgänger
    Mat_Data:Read(BAG.IO.Materialnr);
    Mat_Data:Read("Mat.Vorgänger");
        
    vJsonEinsaetzInner  # vJsonEinsaetze->CteInsertNode('', _JsonNodeObject, NULL);
    Lib_Json:RecToJson(var vJsonEinsaetze, 200, 'Vorgaenger');

  
  END;
  
  
  
  // Fertigungen
  vJsonFertigungen # vJsonCte->CteInsertNode('Fertigungen', _JSONNodeArray, NULL);
  FOR   Erx # RecLink(703,702,4,_RecFirst)
  LOOP  Erx # RecLink(703,702,4,_RecNext)
  WHILE Erx = _rOK DO BEGIN
    vJsonFertigungInner  # vJsonFertigungen->CteInsertNode('', _JsonNodeObject, NULL);
    vJsonFertigungInner->CteInsertNode('Horst', _JsonNodeString, 'Echte Falsche, echte falsche');
    vJsonFertigungInner->CteInsertNode('Horst', _JsonNodeString, 'Echte Falsche, echte falsche');
    
    vJsonFertigungInner  # vJsonFertigungen->CteInsertNode('', _JsonNodeObject, NULL);
    vJsonFertigungInner->CteInsertNode('Horst', _JsonNodeString, 'FalscheEchte , falsche echte ');
    vJsonFertigungInner->CteInsertNode('Horst', _JsonNodeString, 'FalscheEchte , falsche echte' );
    
    /*
    vJsonFertigungInner->Lib_Json:CteInsertNodeVarByName('BAG.F.Nummer');
    vJsonFertigungInner->Lib_Json:CteInsertNodeVarByName('BAG.F.Position');
    vJsonFertigungInner->Lib_Json:CteInsertNodeVarByName('BAG.F.Fertigung');
    */
  END;

  

 
  //----------------------------------------------------------
  aContentType # 'application/json';
  vJsonCte->JsonSave('', _JsonSaveDefault, aMem, _CharsetUTF8);
  //vJsonCte->JsonSave('c:\debug\test.jsn', _JsonSaveDefault, aMem, _CharsetUTF8);
  Lib_Json:CloseJSON(var vJsonCte);

  RETURN 200;
end;

//=========================================================================
//=========================================================================
