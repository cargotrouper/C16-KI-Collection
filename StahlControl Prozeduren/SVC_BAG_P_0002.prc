@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_BAG_P_0002
//                  OHNE E_R_G
//  Zu Service: BAG_P_REPLACE
//
//  Info
//  Ändert eine neue Betriebsauftragsposition
//
//  http://192.168.0.2:5060/?sender=A1386&service=bag_p_replace&bag.p.nummer=1336&bag.p.position
//  http://192.168.0.2:5060/?sender=A1386&service=bag_p_replace&bag.p.nummer=1336&bag.p.position=1&Bag.p.ressource.grp=1&bag.p.ressource=10
//  http://192.168.0.2:5060/?sender=A1386&service=bag_p_replace&bag.p.nummer=1336&bag.p.position=2&Bag.P.externeLiefNr=1644
//
//
//  02.03.2015  ST  Erstellung der Prozedur
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
  vNode # vApi->apiAdd('BAG.P.Nummer',_TypeInt,true);
  vNode->apiSetDesc('Nummer des Betriebsauftrags','1336');

  vNode # vApi->apiAdd('BAG.P.Position',_TypeInt,true);
  vNode->apiSetDesc('Nummer der zu ändernden Betriebsauftragsposition','1');


  vNode # vApi->apiAdd('BAG.P.ExterneLiefNr' ,_TypeInt);
  vNode # vApi->apiAdd('BAG.P.Ressource.Grp' ,_TypeAlpha);
  vNode # vApi->apiAdd('BAG.P.Ressource'     ,_TypeAlpha);
  vNode # vApi->apiAdd('BAG.P.Zieladresse'   ,_TypeInt);
  vNode # vApi->apiAdd('BAG.P.Zielanschrift' ,_TypeInt);
  vNode # vApi->apiAdd('BAG.P.ZielVerkaufYN' ,_TypeLogic);
  vNode # vApi->apiAdd('BAG.P.Bemerkung'     ,_TypeAlpha);
  vNode # vApi->apiAdd('BAG.P.Referenznr'    ,_TypeAlpha);
  vNode # vApi->apiAdd('BAG.P.Plan.StartDat' ,_TypeDate);
  vNode # vApi->apiAdd('BAG.P.Plan.StartZeit',_TypeTime);
  vNode # vApi->apiAdd('BAG.P.Plan.StartInfo',_TypeAlpha);
  vNode # vApi->apiAdd('BAG.P.Plan.Dauer'    ,_TypeInt);
  vNode # vApi->apiAdd('BAG.P.Plan.EndDat'   ,_TypeDate);
  vNode # vApi->apiAdd('BAG.P.Plan.EndZeit'  ,_TypeTime);
  vNode # vApi->apiAdd('BAG.P.Plan.EndInfo'  ,_TypeAlpha);
  vNode # vApi->apiAdd('BAG.P.Kosten.Wae'    ,_TypeInt);
  vNode # vApi->apiAdd('BAG.P.Kosten.Fix'    ,_TypeFloat);
  vNode # vApi->apiAdd('BAG.P.Kosten.Pro'    ,_TypeFloat);
  vNode # vApi->apiAdd('BAG.P.Kosten.PEH'    ,_TypeFloat);
  vNode # vApi->apiAdd('BAG.P.Kosten.MEH'    ,_TypeAlpha,false,0,0,'kg|m|qm');


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

  Bag.P.Nummer    # CnvIA(aArgs->getValue('BAG.P.Nummer'));
  Bag.P.Position  # CnvIA(aArgs->getValue('BAG.P.Position'));
  Erx # RecRead(702,1,0);
  if (Erx <>_rOK) then begin
    Error(001003,'Arbeitsgang');  //  001003 :  vA # 'E:#%1%:Satz nicht gefunden!';
    Lib_Soa:BuildErrorResponse(var aResponse);
    RETURN errPrevent;
  end;

  vBuff # RekSave(702);

  // --------------------------------------------------------------------------
  // Argumente extrahieren
  vTmp # aArgs->getValue('BAG.P.ExterneLiefNr');  if (vTmp <> '') then  vBuff->BAG.P.ExterneLiefNr  # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Ressource.Grp');  if (vTmp <> '') then  vBuff->BAG.P.Ressource.Grp  # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Ressource');      if (vTmp <> '') then  vBuff->BAG.P.Ressource      # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Zieladresse');    if (vTmp <> '') then  vBuff->BAG.P.Zieladresse    # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Zielanschrift');  if (vTmp <> '') then  vBuff->BAG.P.Zieladresse    # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.P.ZielVerkaufYN');  if (vTmp <> '') then  vBuff->BAG.P.ZielVerkaufYN  # CnvLi(CnvIa(vTmp));
  vTmp # aArgs->getValue('BAG.P.Bemerkung');      if (vTmp <> '') then  vBuff->BAG.P.Bemerkung      # vTmp;
  vTmp # aArgs->getValue('BAG.P.Referenznr');     if (vTmp <> '') then  vBuff->BAG.P.Referenznr     # vTmp;

  vTmp # aArgs->getValue('BAG.P.Plan.StartDat');  if (vTmp <> '') then  vBuff->BAG.P.Plan.StartDat  # CnvDa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Plan.StartZeit'); if (vTmp <> '') then  vBuff->BAG.P.Plan.StartZeit # CnvTa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Plan.StartInfo'); if (vTmp <> '') then  vBuff->BAG.P.Plan.StartInfo # StrCut(vTmp,1,32);
  vTmp # aArgs->getValue('BAG.P.Plan.Dauer');     if (vTmp <> '') then  vBuff->BAG.P.Plan.Dauer     # CnvFa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Plan.EndDat');    if (vTmp <> '') then  vBuff->BAG.P.Plan.EndDat    # CnvDa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Plan.EndZeit');   if (vTmp <> '') then  vBuff->BAG.P.Plan.EndZeit   # CnvTa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Plan.EndInfo');   if (vTmp <> '') then  vBuff->BAG.P.Plan.EndInfo   # StrCut(vTmp,1,32);

  vTmp # aArgs->getValue('BAG.P.Kosten.Wae');     if (vTmp <> '') then  vBuff->BAG.P.Kosten.Wae     # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Kosten.Fix');     if (vTmp <> '') then  vBuff->BAG.P.Kosten.Fix     # CnvFa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Kosten.Pro');     if (vTmp <> '') then  vBuff->BAG.P.Kosten.Pro     # CnvFa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Kosten.PEH');     if (vTmp <> '') then  vBuff->BAG.P.Kosten.PEH     # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.P.Kosten.MEH');     if (vTmp <> '') then  vBuff->BAG.P.Kosten.MEH     # vTmp;

  // --------------------------------------------------------------------------
  Erx # BA1_P_Data_SOA:Replace(vBuff);
  if (Erx <> _rOK) then begin
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
  vArgs->Lib_XML:AppendNode(toUpper('service'),'BAG_P_REPLACE');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.P.Nummer'),'1336');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.P.Position'),'1');
end;




//=========================================================================
//=========================================================================
//=========================================================================