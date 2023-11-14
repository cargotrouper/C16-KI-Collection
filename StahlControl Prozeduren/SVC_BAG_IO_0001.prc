@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_BAG_IO_0001
//                  OHNE E_R_G
//  Zu Service: BAG_IO_NEW
//
//  Info
//  Erstellt eine neuen Betriebsauftragseinsatz als theoretisches Material
//
//http://192.168.0.2:5060/?sender=A1386&service=bag_io_new&bag.io.nummer=1336%bag.io.position
//http://192.168.0.2:5060/?sender=A1386&service=bag_io_new&bag.io.nummer=1336&bag.io.position=1&bag.io.warengruppe=50&bag.io.guete=dd%2011&bag.io.dicke=1&bag.io.breite=1500&bag.io.plan.out.stk=1&bag.io.plan.out.gewn=25000&bag.io.plan.out.gewb=25100
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
@I:Def_BAG

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
  vNode # vApi->apiAdd('BAG.IO.Nummer',_TypeInt,true);
  vNode->apiSetDesc('Nummer des Zielbetriebsauftrages','1336');

  vNode # vApi->apiAdd('BAG.IO.Position',_TypeInt,true);
  vNode->apiSetDesc('Nummer des Arbeitsgangs','2');

  vNode # vApi->apiAdd('BAG.IO.Artikelnr',_TypeALpha);
  vNode->apiSetDesc('Artikelnummer des ','R123');

  vNode # vApi->apiAdd('BAG.IO.Warengruppe'   , _TypeInt,true);
  vNode # vApi->apiAdd('BAG.IO.Dicke'         , _TypeFloat);
  vNode # vApi->apiAdd('BAG.IO.Breite'        , _TypeFloat);
  vNode # vApi->apiAdd('BAG.IO.Laenge'        , _TypeFloat);
  vNode # vApi->apiAdd('BAG.IO.Dickentol'     , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.IO.Breitentol'    , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.IO.Laengentol'    , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.IO.AusfOben'      , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.IO.AusfUnten'     , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.IO.Guete'         , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.IO.Guetenstufe'   , _TypeAlpha);
  vNode # vApi->apiAdd('BAG.IO.AutoTeilungYN' , _TypeLogic);
  vNode # vApi->apiAdd('BAG.IO.Teilungen'     , _TypeInt);
  vNode # vApi->apiAdd('BAG.IO.Plan.Out.Stk'  , _TypeInt);
  vNode # vApi->apiAdd('BAG.IO.Plan.Out.GewN' , _TypeFloat);
  vNode # vApi->apiAdd('BAG.IO.Plan.Out.GewB' , _TypeFloat);
  vNode # vApi->apiAdd('BAG.IO.Plan.Out.Meng' , _TypeFloat);

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
  vBagPAktion : alpha;
  vBuff       : handle;
  vTmp        : alpha(4000);
  Erx         : int;
end
begin

  vBuff # RecBufCreate(701);

  vTmp # aArgs->getValue('BAG.IO.Warengruppe'  ); if (vTmp <> '') then  vBuff->BAG.IO.Warengruppe     # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.IO.Dicke'        ); if (vTmp <> '') then  vBuff->BAG.IO.Dicke           # Cnvfa(vTmp);
  vTmp # aArgs->getValue('BAG.IO.Breite'       ); if (vTmp <> '') then  vBuff->BAG.IO.Breite          # Cnvfa(vTmp);
  vTmp # aArgs->getValue('BAG.IO.Laenge'       ); if (vTmp <> '') then  vBuff->"BAG.IO.Länge"         # Cnvfa(vTmp);
  vTmp # aArgs->getValue('BAG.IO.Dickentol'    ); if (vTmp <> '') then  vBuff->BAG.IO.Dickentol       # vTmp;
  vTmp # aArgs->getValue('BAG.IO.Breitentol'   ); if (vTmp <> '') then  vBuff->BAG.IO.Breitentol      # vTmp;
  vTmp # aArgs->getValue('BAG.IO.Laengentol'   ); if (vTmp <> '') then  vBuff->"BAG.IO.Längentol"     # vTmp;
  vTmp # aArgs->getValue('BAG.IO.AusfOben'     ); if (vTmp <> '') then  vBuff->BAG.IO.AusfOben        # vTmp;
  vTmp # aArgs->getValue('BAG.IO.AusfUnten'    ); if (vTmp <> '') then  vBuff->BAG.IO.AusfUnten       # vTmp;
  vTmp # aArgs->getValue('BAG.IO.Guete'        ); if (vTmp <> '') then  vBuff->"BAG.IO.Güte"          # vTmp;
  vTmp # aArgs->getValue('BAG.IO.Guetenstufe'  ); if (vTmp <> '') then  vBuff->"BAG.IO.Gütenstufe"    # vTmp;
  vTmp # aArgs->getValue('BAG.IO.AutoTeilungYN'); if (vTmp <> '') then  vBuff->BAG.IO.AutoTeilungYN   # CnvLi(CnvIa(vTmp));
  vTmp # aArgs->getValue('BAG.IO.Teilungen'    ); if (vTmp <> '') then  vBuff->BAG.IO.Teilungen       # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.IO.Plan.Out.Stk' ); if (vTmp <> '') then  vBuff->BAG.IO.Plan.Out.Stk    # CnvIa(vTmp);
  vTmp # aArgs->getValue('BAG.IO.Plan.Out.GewN'); if (vTmp <> '') then  vBuff->BAG.IO.Plan.Out.GewN   # CnvFa(vTmp);
  vTmp # aArgs->getValue('BAG.IO.Plan.Out.GewB'); if (vTmp <> '') then  vBuff->BAG.IO.Plan.Out.GewB   # CnvFa(vTmp);
  vTmp # aArgs->getValue('BAG.IO.Plan.Out.Meng'); if (vTmp <> '') then  vBuff->BAG.IO.Plan.Out.Meng   # CnvFa(vTmp);

  Erx # BA1_IO_Data_SOA:Insert(CnvIa(aArgs->getValue('BAG.IO.Nummer')),CnvIa(aArgs->getValue('BAG.IO.Position')),vBuff);
  RecBufDestroy(vBuff);
  if (Erx <> _rOK) then begin
    Lib_Soa:BuildErrorResponse(var aResponse);
    RETURN errPrevent;
  end;

  // --------------------------------------------------------------------------
  // Response schreiben
  // Daten Node zum Einfügen extrahieren
  vNode # aResponse->getNode('DATA');
  vNode->Lib_XML:AppendNode('Ergebnis', 'OK');
  vNode->Lib_XML:AppendNode('Bag.IO.ID',Aint(Bag.IO.ID));

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
  vArgs->Lib_XML:AppendNode(toUpper('service'),'BAG_IO_NEW');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.io.Nummer'),'1336');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.io.Position'),'1');
  vArgs->Lib_XML:AppendNode(toUpper('Bag.io.warengruppe'),'1000');
end;



//=========================================================================
//=========================================================================
//========================================================================