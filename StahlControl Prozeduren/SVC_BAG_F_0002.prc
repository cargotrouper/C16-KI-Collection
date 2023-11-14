@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_BAG_F_0002
//                  OHNE E_R_G
//  Zu Service: BAG_F_REPLACE
//
//  Info
//  Ändert eine Betriebsauftragsfertigung
//
//  http://192.168.0.2:5060/?sender=A1386&service=bag_f_replace&bag.f.nummer=1336&bag.f.position=1&bag.f.fertigung=2
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
  vNode # vApi->apiAdd('BAG.F.Nummer',_TypeInt,true);
  vNode->apiSetDesc('Nummer des Betriebsauftrags','1336');

  vNode # vApi->apiAdd('BAG.F.Position',_TypeInt,true);
  vNode->apiSetDesc('Nummer der zu ändernden Betriebsauftragsposition','1');

  vNode # vApi->apiAdd('BAG.F.Fertigung',_TypeInt,true);
  vNode->apiSetDesc('Nummer der zu ändernden Fertigung','1');

  vNode # vApi->apiAdd('BAG.F.Warengruppe'    , _TypeInt);
  vNode # vApi->apiAdd('BAG.F.KostentraegerYN', _TypeLogic);
  vNode # vApi->apiAdd('BAG.F.ReservierenYN'  , _TypeLogic);
  vNode # vApi->apiAdd('BAG.F.Auftragsnummer' , _TypeInt);
  vNode # vApi->apiAdd('BAG.F.Auftragspos'    , _TypeInt);
  vNode # vApi->apiAdd('BAG.F.ReservFuerKunde', _TypeInt);
  vNode # vApi->apiAdd('BAG.F.Bemerkung'      , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.F.Stueckzahl'     , _TypeInt);
  vNode # vApi->apiAdd('BAG.F.Gewicht'        , _TypeFloat);
  vNode # vApi->apiAdd('BAG.F.Menge'          , _TypeFloat);
  vNode # vApi->apiAdd('BAG.F.MEH'            , _TypeAlpha,false,0,0,'kg|m|qm');
  vNode # vApi->apiAdd('BAG.F.PlanSchrottYN'  , _TypeLogic);
  vNode # vApi->apiAdd('BAG.F.WirdEigenYN'    , _TypeLogic);
  vNode # vApi->apiAdd('BAG.F.Guete'          , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.F.Guetenstufe'    , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.F.Dicke'          , _TypeFloat);
  vNode # vApi->apiAdd('BAG.F.Dickentol'      , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.F.Breite'         , _TypeFloat);
  vNode # vApi->apiAdd('BAG.F.Breitentol'     , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.F.Laenge'         , _TypeFloat);
  vNode # vApi->apiAdd('BAG.F.Laengentol'     , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.F.Streifenanzahl' , _TypeInt);
  vNode # vApi->apiAdd('BAG.F.Block'          , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.F.RID'            , _TypeFloat);
  vNode # vApi->apiAdd('BAG.F.RIDMax'         , _TypeFloat);
  vNode # vApi->apiAdd('BAG.F.RAD'            , _TypeFloat);
  vNode # vApi->apiAdd('BAG.F.RADMax'         , _TypeFloat);
  vNode # vApi->apiAdd('BAG.F.BesaeumenYN'    , _TypeLogic);
  vNode # vApi->apiAdd('BAG.F.ResttafelYN'    , _TypeLogic);
  vNode # vApi->apiAdd('BAG.F.Gluehtemperatur', _TypeFloat);

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

  Bag.F.Nummer    # CnvIA(aArgs->getValue('BAG.F.Nummer'));
  Bag.F.Position  # CnvIA(aArgs->getValue('BAG.F.Position'));
  Bag.F.Fertigung # CnvIA(aArgs->getValue('BAG.F.Fertigung'));
  Erx # RecRead(703,1,0);
  if (Erx <>_rOK) then begin
    Error(001003,'Fertigung');  //  001003 :  vA # 'E:#%1%:Satz nicht gefunden!';
    Lib_Soa:BuildErrorResponse(var aResponse);
    RETURN errPrevent;
  end;

  vBuff # RekSave(703);

  // --------------------------------------------------------------------------
  // Argumente extrahieren
  vTmp # aArgs->getValue('BAG.F.Warengruppe'    ); if (vTmp <>'') then vBuff->BAG.F.Warengruppe       # CnvIA(vTmp);
  vTmp # aArgs->getValue('BAG.F.KostentraegerYN'); if (vTmp <>'') then vBuff->"BAG.F.KostenträgerYN"  # CnvLi(CnviA(vTmp));
  vTmp # aArgs->getValue('BAG.F.ReservierenYN'  ); if (vTmp <>'') then vBuff->BAG.F.ReservierenYN     # CnvLi(CnviA(vTmp));
  vTmp # aArgs->getValue('BAG.F.Auftragsnummer' ); if (vTmp <>'') then vBuff->BAG.F.Auftragsnummer    # CnvIA(vTmp);
  vTmp # aArgs->getValue('BAG.F.Auftragspos'    ); if (vTmp <>'') then vBuff->BAG.F.Auftragspos       # CnvIA(vTmp);
  vTmp # aArgs->getValue('BAG.F.ReservFuerKunde'); if (vTmp <>'') then vBuff->"BAG.F.ReservFürKunde"  # CnvIA(vTmp);
  vTmp # aArgs->getValue('BAG.F.Bemerkung'      ); if (vTmp <>'') then vBuff->BAG.F.Bemerkung         # vTmp;
  vTmp # aArgs->getValue('BAG.F.Stueckzahl'     ); if (vTmp <>'') then vBuff->"BAG.F.Stückzahl"       # CnvIA(vTmp);
  vTmp # aArgs->getValue('BAG.F.Gewicht'        ); if (vTmp <>'') then vBuff->BAG.F.Gewicht           # CnvFA(vTmp);
  vTmp # aArgs->getValue('BAG.F.Menge'          ); if (vTmp <>'') then vBuff->BAG.F.Menge             # CnvFA(vTmp);
  vTmp # aArgs->getValue('BAG.F.MEH'            ); if (vTmp <>'') then vBuff->BAG.F.MEH               # vTmp;
  vTmp # aArgs->getValue('BAG.F.PlanSchrottYN'  ); if (vTmp <>'') then vBuff->BAG.F.PlanSchrottYN     # CnvLi(CnvIA(vTmp));
  vTmp # aArgs->getValue('BAG.F.WirdEigenYN'    ); if (vTmp <>'') then vBuff->BAG.F.WirdEigenYN       # CnvLi(CnvIA(vTmp));
  vTmp # aArgs->getValue('BAG.F.Guete'          ); if (vTmp <>'') then vBuff->"BAG.F.Güte"            # vTmp;
  vTmp # aArgs->getValue('BAG.F.Guetenstufe'    ); if (vTmp <>'') then vBuff->"BAG.F.Gütenstufe"      # vTmp;
  vTmp # aArgs->getValue('BAG.F.Dicke'          ); if (vTmp <>'') then vBuff->BAG.F.Dicke             # CnvFA(vTmp);
  vTmp # aArgs->getValue('BAG.F.Dickentol'      ); if (vTmp <>'') then vBuff->BAG.F.Dickentol         # vTmp;
  vTmp # aArgs->getValue('BAG.F.Breite'         ); if (vTmp <>'') then vBuff->BAG.F.Breite            # CnvFA(vTmp);
  vTmp # aArgs->getValue('BAG.F.Breitentol'     ); if (vTmp <>'') then vBuff->BAG.F.Breitentol        # vTmp;
  vTmp # aArgs->getValue('BAG.F.Laenge'         ); if (vTmp <>'') then vBuff->"BAG.F.Länge"           # CnvFA(vTmp);
  vTmp # aArgs->getValue('BAG.F.Laengentol'     ); if (vTmp <>'') then vBuff->"BAG.F.Längentol"       # vTmp;
  vTmp # aArgs->getValue('BAG.F.Streifenanzahl' ); if (vTmp <>'') then vBuff->BAG.F.Streifenanzahl    # CnvIA(vTmp);
  vTmp # aArgs->getValue('BAG.F.Block'          ); if (vTmp <>'') then vBuff->BAG.F.Block             # vTmp;
  vTmp # aArgs->getValue('BAG.F.RID'            ); if (vTmp <>'') then vBuff->BAG.F.RID               # CnvfA(vTmp);
  vTmp # aArgs->getValue('BAG.F.RIDMax'         ); if (vTmp <>'') then vBuff->BAG.F.RIDMax            # CnvfA(vTmp);
  vTmp # aArgs->getValue('BAG.F.RAD'            ); if (vTmp <>'') then vBuff->BAG.F.RAD               # CnvfA(vTmp);
  vTmp # aArgs->getValue('BAG.F.RADMax'         ); if (vTmp <>'') then vBuff->BAG.F.RADMax            # CnvfA(vTmp);
  vTmp # aArgs->getValue('BAG.F.BesaeumenYN'    ); if (vTmp <>'') then vBuff->"BAG.F.BesäumenYN"      # CnvLi(CnvIA(vTmp));
  vTmp # aArgs->getValue('BAG.F.ResttafelYN'    ); if (vTmp <>'') then vBuff->BAG.F.ResttafelYN       # CnvLi(CnvIA(vTmp));
  vTmp # aArgs->getValue('BAG.F.Gluehtemperatur'); if (vTmp <>'') then vBuff->"BAG.F.Glühtemperatur"  # CnvfA(vTmp);


  // --------------------------------------------------------------------------
  Erx # BA1_F_Data_SOA:Replace(vBuff);
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
//=========================================================================
//=========================================================================