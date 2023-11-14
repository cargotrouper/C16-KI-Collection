@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_BAG_IO_0002
//                  OHNE E_R_G
//  Zu Service: BAG_IO_REPLACE
//
//  Info
//  Ändert einen Betriebsauftragseinsatz
//
//  http://192.168.0.2:5060/?sender=A1386&service=bag_io_replace&bag.io.nummer=1336&bag.io.id=3
//  http://192.168.0.2:5060/?sender=A1386&service=bag_io_replace&bag.io.nummer=1336&bag.io.id=3&bag.io.Bemerkung=test%C3%A4nderung%20numma%202&bag.io.plan.out.stk=3&bag.io.plan.out.GewNetto=10000&bag.io.plan.out.GewBrutto=10100
//
//
//  09.03.2015  ST  Erstellung der Prozedur
//  2022-06-29  AH  ERX
//
//  Subprozeduren
//    SUB api() : handle
//    SUB exec(aArgs : handle; var aResponse : handle) : int
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
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
  // Standard-API-Beschreibung erstellen und zurückgeben
  vAPI # apiCreateStd();

  // ----------------------------------
  // Speziele Api-Definition ab hier
  vNode # vApi->apiAdd('Bag.IO.Nummer',_TypeInt,true);
  vNode->apiSetDesc('Nummer des Betriebsauftrags','1336');

  vNode # vApi->apiAdd('Bag.IO.Id',_TypeInt,true);
  vNode->apiSetDesc('ID des Einsatzmaterials','4');

  vNode # vApi->apiAdd('Bag.IO.Plan.Out.Stk'        ,_TypeInt);
  vNode # vApi->apiAdd('Bag.IO.Plan.Out.GewNetto'   ,_TypeFloat);
  vNode # vApi->apiAdd('Bag.IO.Plan.Out.GewBrutto'  ,_TypeFloat);
  vNode # vApi->apiAdd('Bag.IO.Bemerkung'           ,_TypeAlpha);
  vNode # vApi->apiAdd('Bag.IO.AutoTeilungYN'       ,_TypeLogic);
  vNode # vApi->apiAdd('Bag.IO.Teilungen'           ,_TypeInt);

  RETURN vAPI;
end;


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
  vArgs       : handle;     // Handle für Argumentprüfungsstruktur
  vNode       : handle;     // Handle auf Datensegment der Antwort
  vBuff       : handle;
  vTmp        : alpha(4000);
  Erx         : int;
end
begin

  Bag.IO.Nummer   # CnvIA(aArgs->getValue('Bag.Io.Nummer'));
  Bag.IO.ID       # CnvIA(aArgs->getValue('Bag.IO.Id'));
  Erx # RecRead(701,1,0);
  if (Erx <>_rOK) then begin
    Error(001003,'Einsatz');  //  001003 :  vA # 'E:#%1%:Satz nicht gefunden!';
    Lib_Soa:BuildErrorResponse(var aResponse);
    RETURN errPrevent;
  end;

  vBuff # RekSave(701);

  // --------------------------------------------------------------------------
  // Argumente extrahieren
  vTmp # aArgs->getValue('Bag.IO.Plan.Out.Stk');      if (vTmp <> '') then  vBuff->BAG.IO.Plan.Out.Stk   # CnvIa(vTmp);
  vTmp # aArgs->getValue('Bag.IO.Plan.Out.GewNetto'); if (vTmp <> '') then  vBuff->BAG.IO.Plan.Out.GewN  # CnvFa(vTmp);
  vTmp # aArgs->getValue('Bag.IO.Plan.Out.GewBrutto');if (vTmp <> '') then  vBuff->BAG.IO.Plan.Out.GewB  # CnvFa(vTmp);
  vTmp # aArgs->getValue('Bag.IO.Bemerkung');         if (vTmp <> '') then  vBuff->BAG.IO.Bemerkung      # StrCut(vTmp,1,32);
  vTmp # aArgs->getValue('Bag.IO.AutoTeilungYN');     if (vTmp <> '') then  vBuff->BAG.IO.AutoTeilungYN  # CnvLi(CnvIa(vTmp));
  vTmp # aArgs->getValue('Bag.IO.Teilungen');         if (vTmp <> '') then  vBuff->BAG.IO.Teilungen      # CnvIa(vTmp);

  // --------------------------------------------------------------------------
  Erx # BA1_IO_Data_SOA:Replace(vBuff);
  if (Erx < _rOK) then begin
    Lib_Soa:BuildErrorResponse(var aResponse);
    RETURN errPrevent;
  end;

  // --------------------------------------------------------------------------
  // Response schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vNode->Lib_XML:AppendNode('Ergebnis', 'OK');

  RETURN _rOk;
end;


//=========================================================================
// sub test() : handle
//
//  Hilfsmethode zum Testen des Services.
//
//=========================================================================
sub Test(var vArgs : handle)
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'BAG_IO_REPLACE');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.io.Nummer'),'1336');
  vArgs->Lib_XML:AppendNode(toUpper('BAG.IO.id'),'3');
  vArgs->Lib_XML:AppendNode(toUpper('BAG.IO.Plan.Out.Stk'),'3');
  vArgs->Lib_XML:AppendNode(toUpper('BAG.IO.Plan.Out.GewNetto'),'10000');
  vArgs->Lib_XML:AppendNode(toUpper('BAG.IO.Plan.Out.GewBrutto'),'10100');
  vArgs->Lib_XML:AppendNode(toUpper('BAG.IO.Bemerkung'),'hallooloo');
  vArgs->Lib_XML:AppendNode(toUpper('BAG.IO.AutoTeilungYN'),'1');
end;





//=========================================================================
//=========================================================================
//=========================================================================