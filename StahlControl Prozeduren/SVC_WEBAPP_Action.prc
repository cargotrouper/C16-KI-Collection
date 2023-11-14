@A
//==== Business-Control ==================================================
//
//  Prozedur    SVC_WEBAPP_Action
//                  OHNE E_R_G
//  Zu Service: WEBAPP_Action
//
//  Info
//  WEBAPP_Action: Verknüpfungspunkt mit der Webapp
//
//  05.07.2017  ST  Erstellung der Prozedur
//  09.11.2021  MR  Edit  Universialisierung von WE
//  04.02.2022  AH  ERX
//  21.04.2022  ST  Neu: Action "BAG FERTIGMELDEN" WIP
//  07.07.2022  MR  Deadlockfix für Lib_Soa:ReadNummer in sub MatPaketnrNew(); sub WebApp_WE_Allgemein, (); sub WebApp_MatInventur();
//  22.08.2022  ST  Neu: SCDB / SC_DB_Struktur per MemoryRückgabe
//  2022-11-08  MR  Neu (WIP/ TEMP) VerladenCustom: Bitet die Möglichkeit Teilverladung zumachen und dann Materialien in den Versandpool oder in den Status 1 zurückzulegen
//  2023-05-04  ST  Fix: Umlagern / Memorize: Forget im Fehlerfall
//  2023-06-12  ST  Edit: Wareneingang auf VSB sperrt EK Eintrag grundsätzlich
//
//  Subprozeduren
//    SUB api() : handle
//    SUB exec(aArgs : handle; var aResponse : handle) : int
//
//    sub _MatWerksnummer(aLieferant : int; aWerksNrData : alpha(1000)) : alpha
//    sub _MatBarcodeData(aBuf200 : int; var aBarcodeData : alpha) : logic
//    sub MatWerksnummer(aXmlPara : handle; opt aLf : int; opt aWnr : alpha): alpha
//    sub MatPaketnrNew(): alpha
//    sub SweMatWerksnummerLookup(aXmlPara : handle; ): alpha
//    sub MatWareineingang(aXmlPara : handle; opt aBuf200 : int; opt aScannerdata : alpha(1000)): alpha
//    sub MatUmlagerungWerksnr(aXmlPara : handle; opt aLf : int; opt aLpl : alpha; opt aWnr : alpha(1000)): alpha
//    sub LfsVerbucheVldaw(aXmlPara : handle; opt aLfNr : int; opt aMats : alpha(4000)) : alpha
//    sub MatAbruf(aXmlPara : handle; opt aMats : alpha; opt aTermin : alpha; opt aClientUser : alpha; opt aLieferAdr : alpha): alpha
//
//
//    sub WebApp_WE_QR_SWeP(  aLieferantennr  : int;  aLagerplatz     : alpha;  aQrDaten        : alpha(1000);  aTransportId    : alpha;  ) : logic
//    sub WebApp_WE(aBuf200 : int;) : logic
//    sub WebApp_WE_Allgemein(aBuf200 : int;) : logic
//    sub WebApp_Umlagern_Materialnr(aMaterial  : int; aLagerplatz : alpha) : logic
//    sub WebApp_Umlagern_Paketnr(aPaketnr  : int; aLagerplatz : alpha) : logic
//    sub WebApp_Umlagern_Werksnummer(  aLieferantennr  : int;  aWerksnr        : alpha(1000);  aLagerplatz     : alpha) : logic
//    sub _WebApp_LFS_VerbucheVldaw_DelLfsPos() : logic
//    sub WebApp_LFS_VerbucheVldaw(aLfs : int; aMats : alpha(4000)) : logic;
//    sub WebApp_MatAbruf(aBuf800User : int; aMats : alpha(4000); aTermin : alpha; aLieferAdr : alpha) : logic;
//
//    sub _JsnKeyValPairNum(aKey : alpha; aVal : float; aDeci : int) : alpha
//    sub _JsnKeyValPairInt(aKey : alpha; aVal : int) : alpha
//    sub _JsnKeyValPairInt(aKey : alpha; aVal : int) : alpha
//    sub _JsnKeyValPairAlpha(aKey : alpha; aVal : alpha) : alpha
//
//=======================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
  cSWeNr        : 100
  cCustProc     : 101

  LogActive     : true
  Log(a)        : if (LogActive) then Lib_Soa:Dbg(CnvAd(today) + ' ' + cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+ '['+__PROC__+':'+aint(__LINE__)+']' + ':' + a);
  LogErr(a) :    begin  Log(a); Error(99,a); end;
end;


declare _JsnKeyValPairNum(aKey : alpha; aVal : float; aDeci : int) : alpha
declare _JsnKeyValPairInt(aKey : alpha; aVal : int) : alpha
declare _JsnKeyValPairAlpha(aKey : alpha; aVal : alpha) : alpha
declare MatWareneingangMulti_checkArguments(aBuf200 : int;): logic
declare MatWareneingangMulti_Vorbelegung(aBuf200 : int): logic
declare MatWareneingangMulti_Uebernehmen(aBuf200 : int;): logic



// -------------------------------------------------------------------
//    Mögliche Endpunkte zur Kommunikation
// -------------------------------------------------------------------
declare SC_DB_Struktur(var aResponseMemObj : handle; var aContentType : alpha) : alpha
declare SC_Settings(var aResponseMemObj : handle; var aContentType : alpha) : alpha
declare SC_UserAbteilung(aXmlPara : handle; opt aUser : alpha)  : alpha
declare SC_CalcStk(aXmlPara : handle;)  : alpha

declare SC_ChangePassword(aXmlPara : handle; opt aNewPassword : alpha(128))  : alpha


declare AdrKreditlimit(aXmlPara : handle; opt aAdressnr : int; opt aZusatzwert : float): alpha

declare MatWerksnummer(aXmlPara : handle; opt aLf : int; opt aWnr : alpha): alpha
declare MatWareineingang(aXmlPara : handle; opt aBuf200 : int; opt aScannerdata : alpha(1000)): alpha
declare MatWareneingangMulti(aXmlPara : handle; var aReturnval : alpha; opt aBuf200 : int;): alpha
declare MatPaketnrNew(): alpha
declare MatPaketNeu(aXmlPara : handle; opt aMats : alpha(4000); opt aBeistellungen : alpha(4000)): alpha
declare MatPaketDel(aXmlPara : handle; opt aPaketnr : int; opt aDruckEtk  : logic): alpha
declare MatInventur(aXmlPara : handle;  opt aAufnahmetyp  : alpha; opt aEtikettendruckYN : alpha; opt a200 : int; opt a259 : int): alpha
declare MatUmlagerungWerksnr(aXmlPara : handle; opt aLf : int; opt aLpl : alpha; opt aWnr : alpha(1000)): alpha
declare MatUmlagerung(aXmlPara : handle; opt aLpl : alpha; opt aMats : alpha(4000)): alpha
declare MatUmlagerungLagerplaetze(aXmlPara : handle; opt aLagerplatz_Von : alpha; opt aLagerplatz_Nach : alpha): alpha
declare DruckEtikett(aXmlPara : handle;  opt aMats : alpha(4000);opt aEtkNr : int; ): alpha
declare MatSperren(aXmlPara : handle;  opt aMats : alpha(8000); opt aGrund  : alpha; opt aEtkNr : int; ): alpha
declare MatSplitten(aXmlPara : handle;  opt aMatNr : int; opt aGewBrutto : float; opt aGewNetto : float; opt aLaenge  : float; opt aStk : int; opt aDatum : date; opt aPrintMatEtikYN : logic ): alpha
declare MatUmreservieren(aXmlPara : handle;  opt aMatNrListe : alpha(8000); opt aKommission  : alpha(1000);):alpha
declare MarkAufAlsErld(aXmlPara : handle;  opt aAufNr : int; opt aAufPos  : int;)  :alpha
declare MatDelInfo(aXmlPara : handle;  opt aMatNr : int;)  :alpha

declare LfsVerbucheVldaw(aXmlPara : handle; opt aLfNr : int; opt aMats : alpha(4000); opt aVerbuchen : logic) : alpha
declare LfsVerbucheVldawVsP(aXmlPara : handle; opt aLfNr : int; opt aMats : alpha(8000); opt aVerbuchen : logic) : alpha
declare LfsVerbucheLFS(aXmlPara : handle; opt aLieferscheine : alpha(1000)) : alpha
declare LfaFertigmeldungEinzeln(aXmlPara : handle; opt aLfNr : int; opt aMats : alpha(4000);) : alpha
declare CheckKreditlimit(aXmlPara : handle;): alpha

declare LfsAusNeuerVerladung(aXmlPara : handle; opt aMaterialien : alpha(4000);  opt aLieferdat : date;  opt aMaxLadung : float;  opt aSpediteurNr : int;  opt aReferenz : alpha;  ) : alpha

declare SweMatWerksnummerLookup(aXmlPara : handle; ): alpha
declare MatAbruf(aXmlPara : handle; opt aMats : alpha; opt aTermin : alpha; opt aClientUser : alpha; opt aLieferAdr : alpha): alpha
declare AufZuordnung(aXmlPara : handle; opt aAufNr : int; opt aAufPos : int;opt aStk : int; opt aGew    : float; opt aMenge : float; opt aMat : alpha; opt aRsvNr : int; opt aKannMehrKommissionierenYN : logic) : alpha
declare BagAbschluss(aXmlPara : handle; opt a702 : int;): alpha
declare BagFertigmeldungTheo(aXmlPara : handle; opt a702 : int): alpha
declare BagFertigmeldung(aXmlPara : handle; opt a701 : int;opt a707 : int; opt aCustomInput : alpha(1000)): alpha
declare BagFertigmeldungPaketieren(aXmlPara : handle; opt a707 : int; opt a280 : int; opt aInputListe : alpha(8096);): alpha;
declare WebApp_BagFertigmeldungPaketieren(a707 : int; a280  : int; aInputListe  : alpha(8096); )  : logic;

declare BagArbeitsschritteUpdate(aXmlPara : handle; opt a706 : int; opt aArbeitsschritt : alpha(8096)): alpha


declare RsoKal_UpdateTage(aXmlPara : handle;  opt aTagTypen : alpha(4000);  ): alpha

// -------------------------------------------------------------------
//    Implementierung der Businesslogik (auch in C16 testba, ohne Serviceaufruf)
// -------------------------------------------------------------------
declare WebApp_SC_DB_Struktur(var aResponseMemObj : handle;) : logic
declare WebApp_SC_Settings(var aResponseMemObj : handle;) : logic
declare WebApp_UserAbteilung(aUser  : alpha; var aReturnval : alpha) : logic;
declare WebApp_ChangePassword(aNewPassword : alpha(128); var aReturnVal : alpha) : logic;
declare WebApp_SC_CalcStk(  akg : float; aD : float; aB : float; aL : float; aWgr : int; aGuete  : alpha; aArt : alpha;)
declare WebApp_MatDelInfo(aMatNr : int;  var aReturnval : alpha;)  : logic;

declare WebApp_AdrKreditlimit(aAdrNr : int; aZusatzwert : float ) : logic

declare WebApp_WE_Allgemein(aBuf200 : int; var aReturnval : alpha) : logic
declare WebApp_WE_EinP_VSB(aBuf200 : int; var aReturnval : alpha) : logic;
declare WebApp_WE_EinP(aBuf200 : int; aEinMenge : alpha; var aReturnval : alpha) : logic;
  // genutzt bei MEG:y
  declare WebApp_WE(aBuf200 : int; bestellID : alpha; var aReturnVal : alpha) : logic
  declare WebApp_WE_Werksnummer(aBuf200 : int/*aLieferantennr : int;aWerksnr : alpha; aLagerplatz : alpha; aTransportId : alpha*/) : logic
  declare WebApp_WE_QR_SWeP(aLieferantennr : int; aLagerplatz : alpha;  aQrDaten : alpha(1000);aTransportId    : alpha;  ) : logic

declare WebApp_Umlagern(aLagerplatz : alpha;  aMats  : alpha(4000); ) : logic
declare WebApp_Umlagern_Lagerplaetze(aLagerplatz_Von : alpha;  aLagerplatz_Nach  : alpha; ) : logic
declare WebApp_Umlagern_Werksnummer(aLieferantennr : int; aWerksnr : alpha(1000); aLagerplatz : alpha) : logic
declare WebApp_Umlagern_Paketnr(aPaketnr  : int; aLagerplatz : alpha) : logic
declare WebApp_MatSplitten(aMatNr : int; aGewBrutto : float; aGewNetto : float; aLaenge : float; aStk : int; aDatum : date; aPrintMatEtikYN : logic ) : logic
declare WebApp_MatSperren(aMatNrListe : alpha(8000); aGrund  : alpha; aEtkNr : int)  : logic;
declare WebApp_MatUmreservieren(aMatNrListe : alpha(8000); aKommission : alpha(1000))  : logic;
declare WebApp_LFS_VerbucheVldaw(aLfs : int; aMats : alpha(4000); aVerbuchen : logic; aBuf440 : int ) : logic;
declare WebApp_LFS_VerbucheVldawVsP(aLfs : int; aMats : alpha(8000); aVerbuchen : logic) : logic;
declare WebApp_LFS_Verbuchen(aLfs : int; opt aVerbDatum : date; opt aVerbZeit : time) : logic;
declare WebApp_LfaFertigmeldungEinzeln(aLfs : int; aMats : alpha(4000)) : logic;
declare WebApp_Lfs_NeuAusVerladung(aMaterialien : alpha(4000); aLieferdat : date; aMaxLadung : float; aSpediteurNr : int; aReferenz : alpha;) : logic;
declare WebApp_MatAbruf(aBuf800User : int; aMats : alpha(4000); aTermin : alpha; aLieferAdr : alpha) : logic;
declare WebApp_Auf_Zuordnung(aAufNr : int; aAufPos : int; aStk : int; aGew : float; aMenge : float; aMat : alpha; aRsvNr : int; aKannMehrKommissionierenYN : logic ) : logic;
declare WebApp_PaketErstellen(aMats : alpha(2000);  aBeist : alpha(2000);) : logic
declare WebApp_PaketAufloesen(aPaketnr : int; aDruckEtk : logic) : logic
declare WebApp_MatInventur(aAufnahmetyp : alpha; avEtikettendruckYN : logic; a200 : int; a259 : int) : logic;
declare WebApp_BagAbschluss(a702 : int) : logic;
declare WebApp_BagFertigmeldungTheo(a702 : int) : logic;
declare WebApp_BagFertigmeldung(a701 : int; a707 : int; aCustomInput : alpha(1000)) : logic;
declare WebApp_BagArbeitsschritteUpdate(a706  : int;  aArbeitsschritt : alpha(8096)) : logic;
declare WebApp_MarkAufAlsErld(aAufNr : int; aAufPos : int;) : logic;

declare WebApp_DruckEtikett(aMats : alpha(4000); aEtk : int;) : logic;
declare WebApp_RsoKAl_UpdateTage(aTagTypen : alpha(4000);) : logic

//=========================================================================
// sub _JsnKeyValPairNum(aKey : alpha; aVal : float; aDeci : int) : alpha
//  Formatiert einen Float Wert in Json Format
//=========================================================================
sub _JsnKeyValPairNum(aKey : alpha; aVal : float; aDeci : int) : alpha
begin
  RETURN '"' + aKey + '": ' + CnvAf(aVal,_FmtNumNoGroup | _FmtNumPoint,0,aDeci);
end;

//=========================================================================
// sub _JsnKeyValPairInt(aKey : alpha; aVal : int) : alpha
//  Formatiert einen Int Wert in Json Format
//=========================================================================
sub _JsnKeyValPairInt(aKey : alpha; aVal : int) : alpha
begin
  RETURN '"' + aKey + '": ' + CnvAi(aVal, _FmtNumNoGroup);
end;

//=========================================================================
// sub _JsnKeyValPairAlpha(aKey : alpha; aVal : alpha) : alpha
//  Formatiert einen Alpha Wert in Json Format
//=========================================================================
sub _JsnKeyValPairAlpha(aKey : alpha; aVal : alpha) : alpha
begin
  RETURN '"' + aKey + '": ' + '"'+ aVal +  '"';
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

  // ----------------------------------
  // ApiBeschreibung zurückgeben
  RETURN vAPI;
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
  vActiontype : alpha(1000); //  Manueller Aktionstyp

  vPostData   : handle;     // Handle für Externe XML Struktur
  vErrText    : alpha(1000);

  vReturnval  : alpha(1000);  // ggf. kurze Antwort
end
begin
  vErrText # '';

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vActiontype   # aArgs->getValue('ACTION');            //  EventAktion von WebApp
  vPostData     # aArgs->GetNode('POSTDATA');
  

  vActiontype # StrCnv(vActiontype,_StrUpper);

  Log('=======================================================================');
  Log('WebappActiontype = "' + vActionType + '"');


  case vActiontype of

    // -------------------------------------------------------------------
    // SC Datenstrukturbeschreibung   per JSon
    // -------------------------------------------------------------------
    'SCDB' : begin
      RETURN errSVL_ExecMemory;
    end;
    
    'SCSETTINGS' : begin
      RETURN errSVL_ExecMemory;
    end;
    
    'USERABTEILUNG' : begin
      vReturnval # SC_UserAbteilung(vPostData->GetNode('UserTransferObj'));
    end;
    
    'LIEFERANSCHRIFT' : begin
      if(Set.Ein.Lieferadress <> -1) then vReturnVal # cnvai(Set.Ein.Lieferadress);
      else vReturnval # cnvai(Set.Ein.Lieferanschr);
    end;
    
    'CHANGEPASSWORD' : begin
      vReturnval # SC_ChangePassword(vPostData->GetNode('ChangePasswordTransferObj'));
    end;
    
     //2023-05-30 MR: nur temporär
    'CALCSTK' : begin
      vReturnval # SC_CalcStk(vPostData->GetNode('StkCalcTransferObj'));
    end;
    
    // -------------------------------------------------------------------
    // Adressen
    // -------------------------------------------------------------------
    'ADRKREDITLIMT' : begin
      vErrText # AdrKreditlimit(vPostData->GetNode('CheckKreditlimitTransferObj'));
    end;


    // -------------------------------------------------------------------
    // Material
    // -------------------------------------------------------------------
    'MATWERKSNUMMER' : begin
      vReturnval # MatWerksnummer(vPostData->GetNode('WerksnummerTransferObj'));
    end;

    'GETCUSTOMIDENT' : begin
//      vReturnval # MatNummern(vPostData->GetNode('GetIdentTransferObj'));
    end;

    'MATUMLAGERUNG' : begin
      vErrText # MatUmlagerung(vPostData->GetNode('UmlagernTransferObj'));
    end;
    
    'MATDELINFO' : begin
      vErrText # MatDelInfo(vPostData->GetNode('MaterialTransferObj'));
    end;
    
     'MATUMLAGERUNGLAGERPLAETZE' : begin
      vErrText # MatUmlagerungLagerplaetze(vPostData->GetNode('UmlagernLagerplatzTransferObj'));
    end;

    'MATUMLAGERUNGWERKSNR' : begin
      vErrText # MatUmlagerungWerksnr(vPostData->GetNode('UmlagernTransferObj'));
    end;
    
    
    'MATSPERREN' : begin
      vErrText # MatSperren(vPostData->GetNode('SperrenTransferObj'));
    end;
    
    'MATSPLITTEN' : begin
      vErrText # MatSplitten(vPostData->GetNode('SplitTransferObj'));
    end;
    
    'MATUMRESERVIEREN' : begin
      vErrText # MatUmreservieren(vPostData->GetNode('UmreservierungTransferObj'));
    end;



    // -------------------------------------------------------------------
    // Material - Pakete
    // -------------------------------------------------------------------
    'MATPAKETNUMMERNEW' : begin
      vReturnval # MatPaketnrNew();
    end;

    'MATPAKETNEU',
    'MATPAKETEMATNR' : begin
      vErrText # MatPaketNeu(vPostData->GetNode('PaketTransferObj'));
    end;

    'MATPAKETDEL' : begin
      vErrText # MatPaketDel(vPostData->GetNode('PaketDelTransferObj'));
    end;



    // -------------------------------------------------------------------
    // Material  - Wareneingang
    // -------------------------------------------------------------------
    'MATWARENEINGANG' : begin
      vErrText # MatWareineingang(vPostData->GetNode('WareneingangTransferObj'));
    end;

    // WIP GW; Fertiug zum Testen
    'MATWARENEINGANG_MULTI' : begin
      vReturnVal # '';
      vErrText # MatWareneingangMulti(vPostData->GetNode('WareneingangTransferObj'), var vReturnval);
    end;

    'SWELOOKUPWERKSNR'  : begin
      vReturnval # SweMatWerksnummerLookup(vPostData->GetNode('SweLookupTransferObj'));
    end;


    // -------------------------------------------------------------------
    // Material - Inventur
    // -------------------------------------------------------------------
    'MATINVENTUR' : begin
      vErrText # MatInventur(vPostData->GetNode('InventurVerbucheTransferObj'));
    end;


    // -------------------------------------------------------------------
    // Logistik
    // -------------------------------------------------------------------
    'LFSVERBUCHEVLDAW' : begin
      vErrText # LfsVerbucheVldaw(vPostData->GetNode('VldawTransferObj'));
    end;
    
    'LFSVERBUCHEVLDAWVSP' : begin
      vErrText # LfsVerbucheVldawVsP(vPostData->GetNode('VldawTransferObj'));
    end;

    'LFSVERBUCHELFS' : begin
      vErrText # LfsVerbucheLfs(vPostData->GetNode('LfsVerbuchenTransferObj'));
    end;

    'VERLADUNGERSTELLEN' : begin
      vErrText # LfsAusNeuerVerladung(vPostData->GetNode('VerladungErstellenTransferObj'));
    end;

    'LFAFERTIGMELDUNGEINZELN' : begin
      vErrText # LfaFertigmeldungEinzeln(vPostData->GetNode('LfaFertigmeldungEinzelnTransferObj'));
    end;

    // -------------------------------------------------------------------
    // Auftrag
    // -------------------------------------------------------------------
    'MATABRUF' : begin
      vErrText # MatAbruf(vPostData->GetNode('MatAbrufTransferObj'));
    end;

    'KOMMISSIONIERUNG' : begin
      vErrText # AufZuordnung(vPostData->GetNode('KommissionierungTransferObj'));
    end;

    'KOMMISSIONDONE' : begin
      vErrText # MarkAufAlsErld(vPostData->GetNode('AufPosObj'));
    end;

    // -------------------------------------------------------------------
    // Betriebsauftrag / Produktion
    // -------------------------------------------------------------------
    'BAGABSCHLUSS' : begin
      vErrText # BagAbschluss(vPostData->GetNode('BagAbschlussTransferObj'));
    end;

    'BAGFERTIGMELDUNGTHEO' : begin
      vErrText # BagFertigmeldungTheo(vPostData->GetNode('BagFertigmeldungTheoTransferObj'));
    end;
    
    'BAGFERTIGMELDUNG' : begin
      vErrText # BagFertigmeldung(vPostData->GetNode('BagFertigmeldungTransferObj'));
    end;
    
    'BAGFERTIGMELDUNGPAKETIEREN' : begin
      vErrText # BagFertigmeldungPaketieren(vPostData->GetNode('BagFertigmeldungTransferObj_Pack'))
    end;
    
    'BAGARBEITSSCHRITTEUPDATE' : begin
      vErrText # BagArbeitsschritteUpdate(vPostData->GetNode('ArbeitsschrittTransferObj'));
    end;


    // -------------------------------------------------------------------
    // Druck
    // -------------------------------------------------------------------
    'PRINTETIKETT' : begin
      vErrText # DruckEtikett(vPostData->GetNode('EtikettDruckenTransferObj'));
    end;


    // -------------------------------------------------------------------
    // Ressourcen
    // ----------1---------------------------------------------------------
    'RSOGRPKALUPDATE' : begin
      vErrText # RsoKal_UpdateTage(vPostData->GetNode('KalenderToolTransferObj'));
    end;

    otherwise begin
      vErrText # 'ACTION NOT FOUND!!!';
    end;
  end;

  Log('Action done');


  // --------------------------------------------------------------------------
  // Result schreiben
  // temp. Workaround: Gibt bei Brockhaus einen falschen Error
  if(vErrText = 'Möchten Sie noch weitere Eingänge verbuchen?') then
    vErrText # '';
    if( StrFind(vErrText,'TODO',0) <> 0) then
      vErrText # '';
   
    
  if (vErrText = '') then begin
    Log('No errors');

    vNode # aResponse->getNode('DATA');
    vNode->Lib_XML:AppendNode('Erg','ok');

    if (vReturnVal <> '') then
      vNode->Lib_XML:AppendNode('Return',vReturnval);

  end else begin
    Log('Error: ' + vErrText);
    
    vNode # aResponse->getNode('ERRORS');
    vNode->Lib_XML:AppendNode('Error',vErrText);
    RETURN -1;
  end;

  Log('return OK');

  // Daten des Services sind angehängt
  RETURN _rOk;

End; // sub exec(...) : int

//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup_LFS() : logic
begin

  // ALLE 441 Positionen verwerfen
    Log('LFS RecCleanup - lösche temporär angelegte LFS Positionen');
    
    if (Lfs.Nummer<mytmpNummer) and (Lfs.Nummer<>0) then begin
      LogErr('Sie versuchen einen echten Lieferschein '+aint(lfs.nummer)+' abzubrechen!! CleanUp wird abgebrochen!');
      RETURN false;
    end;

    WHILE (RecLink(441,440,4,_RecFirst)=_rOk) do begin
      RekDelete(441,0,'MAN');
      Log('Temporäre LFS Position'+ aint(lfs.nummer)+'/'+aint(lfs.p.position)+' erfolgreich gelöscht.');
    END;
    
  RETURN true;
end;

//=========================================================================
// execMemory
//   Führt den Service mit einer direkten Binärausgabe aus.
//=========================================================================
sub execMemory (aArgs : handle; var aMem : handle; var aContentType : alpha ) : int
local begin
  vSender   : alpha;
  vFileName : alpha;
  vFileType : alpha;
  vFilePath : alpha;
  vFileHdl  : handle;
  
  vActiontype : alpha(1000); //  Manueller Aktionstyp
  vPostData   : handle;     // Handle für Externe XML Struktur
  vErrText    : alpha(1000);
end
begin
  Lib_Soa:Allocate();
  vSender   # Str_ReplaceAll(aArgs->getValue('SENDER'), '/', '_');
  vSender   # Lib_Strings:Strings_ReplaceEachToken(vSender, '<>:"/\|?*^');
  vFileName # Lib_Strings:Strings_ReplaceEachToken(aArgs->getValue('name'), '<>:"/\|?*^');
  vFileType # Lib_Strings:Strings_ReplaceEachToken(StrCnv(aArgs->getValue('type'), _strLower), '<>:"/\|?*^');
  
  vActiontype  # aArgs->getValue('ACTION');            //  EventAktion von WebApp
  vActiontype # StrCnv(vActiontype,_StrUpper);

  case vActiontype of

    // -------------------------------------------------------------------
    // SC Datenstrukturapi
    // -------------------------------------------------------------------
    'SCDB' : begin
      vErrText # SC_DB_Struktur(var aMem, var aContentType);
    end;
    
    'SCSETTINGS' : begin
      vErrText # SC_Settings(var aMem, var aContentType);
    end;
    
  end;

  if (vErrText = '') AND (ErrList = 0) then
    RETURN 200;
  else
    RETURN 501;
end;




//=========================================================================
// sub SC_DB_Struktur
//
//=========================================================================
sub SC_DB_Struktur(var aResponseMemObj : handle; var aContentType : alpha) : alpha
local begin
  vErg          : alpha(1000);
end;
begin
  aContentType # 'application/json';

  if (WebApp_SC_DB_Struktur(var aResponseMemObj) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;


//=========================================================================
// sub SC_Settings
//
//=========================================================================
sub SC_Settings(var aResponseMemObj : handle; var aContentType : alpha) : alpha
local begin
  vErg          : alpha(1000);
end;
begin
  aContentType # 'application/json';

  if (WebApp_SC_Settings(var aResponseMemObj) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;



//=========================================================================
// sub SC_Settings
//
//=========================================================================
sub MatDelInfo(aXmlPara : handle; opt aMatNr : int;) : alpha
local begin
  vMatNr  : int;
  Erx     : int;
  vReturn : alpha;
end;
begin
    // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'MatNr'), var vMatNr);
  end else begin
    vMatNr      # aMatNr;
  end;
  
  Log(cnvai(vMatNr))
  WebApp_MatDelInfo(vMatNr, var vReturn)
  Lib_Error:OutputToText(var vReturn);
  Log(vReturn)
  Return vReturn;
end;


//=========================================================================
// sub SC_UserAbteilung
//
//=========================================================================
sub SC_UserAbteilung(aXmlPara : handle; opt aUser : alpha;): alpha
local begin
  vUser   : alpha;
  Erx     : int;
  vReturn : alpha;
end
begin
  
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'Username'), var vUser);
  end else begin
    vUser      # aUser;
  end;
  
  
  WebApp_UserAbteilung(vUser, var vReturn)
  Log(vReturn);
  Return vReturn;
end



//=========================================================================
// sub SC_UserAbteilung
//
//=========================================================================
sub SC_ChangePassword(aXmlPara : handle; opt aNewPassword : alpha(128);): alpha
local begin
  vNewPassword   : alpha(128);
  Erx     : int;
  vReturn : alpha(128);
end
begin
  
  
  
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'PasswordNew'), var vNewPassword);
  end else begin
    vNewPassword      # aNewPassword;
  end;
  
  
  WebApp_ChangePassword(vNewPassword, var vReturn)
  Log(vReturn);
  Return vReturn;
end


//=========================================================================
// sub SC_CalcStk
//
//=========================================================================
sub SC_CalcStk(aXmlPara : handle;) : alpha
local begin
  vErg    : alpha(1000);
  vStk    : int;
  vkg     : float;
  vD      : float;
  vB      : float;
  vL      : float;
  vWgr    : int;
  vGuete  : alpha;
  vArt    : alpha;
end;
begin

  if (aXmlPara > 0) then begin
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Kg'), var vkg);
    Lib_XML:GetValueF(   Lib_Soa:getNode(aXmlPara,'Dicke'), var vD);
    Lib_XML:GetValueF( Lib_Soa:getNode(aXmlPara, 'Breite'), var vB);
    Lib_XML:GetValueF( Lib_Soa:getNode(aXmlPara, 'Laenge'), var vL);
    Lib_XML:GetValueI( Lib_Soa:getNode(aXmlPara, 'Warengruppe'), var vWgr);
    Lib_XML:GetValue( Lib_Soa:getNode(aXmlPara, 'Guete'), var vGuete);
    Lib_XML:GetValue( Lib_Soa:getNode(aXmlPara, 'Artikel'), var vArt);
  end else begin

  end;

  vStk # Lib_berechnungen:Stk_aus_KgDBLWgrArt(vkg, vD,vB, vL, vWgr, vGuete, vArt)
  
  
  
  if(vStk <> 0) then
    vErg # cnvai(vStk, _FmtNumNoGroup);
  else vErg # '0';
  Log(vErg);
  
    //Lib_Error:OutputToText(var vErg);
  
  
//  Log(vErg);
//
//  if(vErg <> '') then
//    vErg # 'Kreditlimit überschritten.';
  

  RETURN vErg;
end;


//=========================================================================
// sub SC_LieferAnschrift
//
//=========================================================================
//sub SC_LieferAnschrift(aXmlPara : handle; opt a : alpha;): alpha
//local begin
//  vUser   : alpha;
//  Erx     : int;
//  vReturn : alpha;
//end
//begin
//
//  // Daten extrahieren
//  if (aXmlPara > 0) then begin
//    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'Username'), var vUser);
//  end else begin
//    vUser      # aUser;
//  end;
//
//
//  WebApp_UserAbteilung(vUser, var vReturn)
//  Log(vReturn);
//  Return vReturn;
//end



//=========================================================================
// sub _MatWerksnummer(aLieferant : int; aWerksNrData : alpha(1000)) : alpha
//      Konvertiert eine Werksnummer nach Kundenvorgabe
//=========================================================================
sub _MatWerksnummer(aLieferant : int; aWerksNrData : alpha(1000)) : alpha
local begin
  Erx     : int;
  vCall   : alpha;
end
begin
  Log('Konvertiere Werksnummer Lieferant "' + Aint(aLieferant)+ '" Werksnummer Rohdaten "'+aWerksNrData+'"');

  Adr.Lieferantennr # aLieferant;
  Erx # RecRead(100,3,0);
  if (Erx <= _rMultikey) then begin
    Log('Lieferant gefunden');
    Erx # Cus_Data:Read(100,RecInfo(100,_RecId),cCustProc);
    if (Erx = _rOK) then begin

      // Als "Lieferantennr" kommt von der App die Kundennummer aus dem Lieferscheinkopf.
/*
      try begin
        ErrTryIgnore(_rlocked,_rNoRec);
        ErrTryCatch(_ErrNoProcInfo,y);
        ErrTryCatch(_ErrNoSub,y);
*/
        vCall # Cus.Inhalt+':Werksnummer';
        Log('Starte Konvertierungsprozedur "' + vCall + '"');
        Call(vCall,var aWerksNrData);
      //end;

    end;
  end;

  Log('Werksnummer konvertiert in "'+aWerksNrData+'"');

  RETURN aWerksNrData;
end;


//=========================================================================
// sub __MatBarcodeData(aLieferant : int; aWerksNrData : alpha(1000)) : alpha
//      Konvertiert eine Werksnummer nach Kundenvorgabe
//=========================================================================
sub _MatBarcodeData(aBuf200 : int; var aBarcodeData : alpha) : logic
local begin
  Erx     : int;
  vCall   : alpha;
end
begin

  Log('Konvertiere 2D Barcodedaten Lieferant "' + Aint(aBuf200->Mat.Lieferant)+ '"  Rohdaten "'+aBarcodeData+'"');

  // ggf. Matrixbarcode Mapping
  Adr.Lieferantennr # aBuf200->Mat.Lieferant;
  Erx # RecRead(100,3,0);
  if (Erx <= _rMultikey) then begin
    Log('Lieferant gefunden');
    Erx # Cus_Data:Read(100,RecInfo(100,_RecId),cCustProc);
    if (Erx = _rOK) then begin

      // Als "Lieferantennr" kommt von der App die Kundennummer aus dem Lieferscheinkopf.
/*
      try begin
        ErrTryIgnore(_rlocked,_rNoRec);
        ErrTryCatch(_ErrNoProcInfo,y);
        ErrTryCatch(_ErrNoSub,y);
 */
        vCall # Cus.Inhalt+':SWe_QrParser';
        Log('Starte Konvertierungsprozedur "' + vCall + '"');
        Call(vCall,aBuf200,aBarcodeData);
        Log('Konvertierung in abgeschlossen');
/*
      end;
*/
    end;
  end;

  RETURN true;
end;


//=========================================================================
// sub AdrKreditlimit(aXmlPara : handle; opt aAdressnr : int; opt aZusatzwert : float): alpha
//      Konvertiert eine Werksnummer nach Kundenvorgabe
//=========================================================================
sub AdrKreditlimit(aXmlPara : handle; opt aAdressnr : int; opt aZusatzwert : float): alpha
local begin
  vAdrNr        : int;
  vZusatzwert   : float;
  vMaterialien  : alpha(8096);
  vErg          : alpha(1000);
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Adressnr'), var vAdrNr);
    Lib_XML:GetValueF(   Lib_Soa:getNode(aXmlPara,'Zusatzwert'), var vZusatzwert);
    Lib_XML:GetValue( Lib_Soa:getNode(aXmlPara, 'Materialien'), var vMaterialien);
  end else begin
    vAdrNr       # aAdressnr;
    vZusatzwert  # aZusatzwert;
  end;

  if (WebApp_AdrKreditlimit(vAdrNr, vZusatzwert) = false) then
    Lib_Error:OutputToText(var vErg);
  
  
  Log(vErg);
  
  if(vErg <> '') then
    vErg # 'Kreditlimit überschritten.';
  

  RETURN vErg;

end;




//=========================================================================
// sub MatWerksnummer(aXmlPara : handle; opt aLf : int; opt aWnr : alpha): alpha
//      Konvertiert eine Werksnummer nach Kundenvorgabe
//=========================================================================
sub MatWerksnummer(aXmlPara : handle; opt aLf : int; opt aWnr : alpha): alpha
local begin
  vLieferant    : int;
  vWerksnummer  : alpha(1000);
  vErg          : alpha(1000);
  vCall : alpha;
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'LieferantNr'), var vLieferant);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Werksnummer'), var vWerksnummer);
  end else begin
    vLieferant      # aLf;
    vWerksnummer    # aWnr;
  end;

  vErg # _MatWerksnummer(vLieferant,vWerksnummer);

  RETURN vErg;
end;


//=========================================================================
// sub MatPaketnrNew(): alpha
//      Erstellt ein neues Paket
//
//=========================================================================
sub MatPaketnrNew(): alpha
local begin
  Erx           : int;
  vLieferant    : int;
  vPakNr        : int;
  vWerksnummer  : alpha(1000);
  vErg          : alpha(1000);
  vCall : alpha;
end;
begin

  Log('MatPaketnrNew START');

  TRANSON;
  //[+] 07.07.2022 MR Deadlockfix
  Erx # Lib_Soa:ReadNummer('Paket',var vPakNr);    // Nummer lesen
  if (Erx<>_rOk) then begin
    Log('Fehler bei Nummerlesen');
    TRANSBRK;
    Error(99,'Fehler bei Nummerlesen');
    RETURN '0';
  end;
  Pak.Nummer # vPakNr;
  Lib_SOA:SaveNummer();

  Pak.Anlage.Datum  # Today;
  Pak.Anlage.Zeit   # Now;
  Pak.Anlage.User   # gUserName;
  Erx # RekInsert(280,0,'MAN');
  if (Erx<>_rOk) then begin
    Log('Fehler bei Paketanlage');
    TRANSBRK;
    Error(99,'Fehler bei Paketanlage');
    RETURN '0';
  end;

  Log('Paket generiert: ' + Aint(Pak.Nummer));
  TRANSOFF;

  Log('MatPaketnrNew Ende');

  RETURN aint(Pak.Nummer);
end;




//=========================================================================
// sub MatPaketNeu(aXmlPara : handle; opt aMats : alpha(4000); opt aBeistellungen : alpha(4000)): alpha
//
//  Erstellt ein neues Paket mit den angegebenen Materialien und Beistellungen
//=========================================================================
sub MatPaketNeu(aXmlPara : handle; opt aMats : alpha(4000); opt aBeistellungen : alpha(4000)): alpha
local begin
  vMats         : alpha(4000);
  vBeist        : alpha(4000);
  vErg          : alpha(1000);
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Materialien'),   var vMats);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Beistellungen'), var vBeist);
  end else begin
    vMats  # aMats;
    vBeist # aBeistellungen;
  end;

  if (WebApp_PaketErstellen(vMats, vBeist) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;


//=========================================================================
// sub MatPaketDel(aXmlPara : handle; opt aPaketnr : int): alpha
//
//  Löst ein bestehendes Materialpaket auf, etwaige Beistellungen gehen
//  hierbei verloren
//=========================================================================
sub MatPaketDel(aXmlPara : handle; opt aPaketnr : int; opt aDruckEtk  : logic): alpha
local begin
  vPaketnr      : int;
  vDruckEtk     : int;
  vErg          : alpha(1000);
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(   Lib_Soa:getNode(aXmlPara,'Paketnr'),   var vPaketnr);
    Lib_XML:GetValueI(   Lib_Soa:getNode(aXmlPara,'DruckEtkYN'),   var vDruckEtk);
  end else begin
    vPaketnr  # aPaketnr;
    vDruckEtk # cnvIL(aDruckEtk);
  end;
  if (WebApp_PaketAufloesen(vPaketnr, cnvLI(vDruckEtk)) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;



//=========================================================================
// sub SweMatWerksnummerLookup(aXmlPara : handle; ): alpha
//
//  Sucht ein Sammelwareneingang Avis und gibt die Daten des Avis zurück
//=========================================================================
sub SweMatWerksnummerLookup(aXmlPara : handle; ): alpha
local begin
  Erx     : int;

  // Handlingsvars
  vErg    : alpha(4000);

  v200Buf : int;
  vQrCodeDaten  : alpha(4000);

  vSweNr  : int;
end;
begin
  Log('SweMatWerksnummerLookup START');

  v200Buf # RecBufCreate(200);

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Lieferantennr'), var v200Buf->Mat.Lieferant);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Werksnummer'),   var v200Buf->Mat.Werksnummer);
  end;

  // Lieferant lesen
  Adr.LieferantenNr # v200Buf->Mat.Lieferant;
  Erx # RecRead(100,3,0);
  if (Erx > _rMultikey) then begin
    Error(99,'Lieferant nicht gefunden')
    RETURN '';
  end;

//  // Sammelwareneingang ermitteln
//  if (Cus_Data:Read(100,RecInfo(100,_RecId),cSWeNr) <> _rOK) then begin
//    Error(99,'Sammelwareneingangsnummer für den Lieferanten "'+Adr.Stichwort+'" kann nicht ermittelt werden');
//    RETURN '';
//  end;
//  vSweNr # CnvIa(Cus.Inhalt);


  // -------------------------------------------------------
  // Material schon im Bestand?
  Mat.Werksnummer # v200Buf->Mat.Werksnummer;
  FOR   Erx # RecRead(200,8,0);
  LOOP  Erx # RecRead(200,8,_RecNext);
  WHILE Erx = _rMultikey AND (Mat.Werksnummer = v200Buf->Mat.Werksnummer) DO BEGIN
    if (Mat.Lieferant = Adr.Lieferantennr) then begin
      // Material ist schon eingegangen, alles IO,
      Erx # _rOK;
      BREAK;
    end;
  END;
  if (Erx = _rOK) then begin
    // Material ist schon im Bestand, Alle Daten zurückgeben
    vErg # '';
    Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Status',         'Bestand'));
    Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Coilnummer',     Mat.Coilnummer                      ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Chargennummer',  Mat.Chargennummer                   ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairNum('Dicke',            Mat.Dicke,Set.Stellen.Dicke         ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairNum('Breite',           Mat.Breite, Set.Stellen.Breite      ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairNum('Laenge',          "Mat.Länge", "Set.Stellen.Länge"     ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairInt('Stueck',           Mat.Bestand.Stk                     ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairNum('Gewicht',          Mat.Bestand.Gew,Set.Stellen.Gewicht ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Guete',         "Mat.Güte"                           ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairNum('RID',              Mat.Rid, Set.Stellen.Radien         ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairNum('RAD',              Mat.Rad, Set.Stellen.Radien         ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Bemerkung1',     Mat.Bemerkung1                      ) ,', ');
    Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Paketnummer',    Aint(Mat.Paketnr)                   ) ,', ');
  end else begin

    // Material nicht in Material gefunden, dann in Sammelwareneingang suchen

    // -------------------------------------------------------
    // Sammelwareneingang schon vorhanden?
    SWe.P.Lieferantennr # Adr.Lieferantennr;
    SWe.P.Werksnummer   # v200Buf->Mat.Werksnummer;
    FOR   Erx # RecRead(621,6,0);
    LOOP  Erx # RecRead(621,6,_RecNext);
    WHILE (Erx = _rMultikey) AND (SWe.P.Werksnummer =  v200Buf->Mat.Werksnummer) DO BEGIN
      if (SWe.P.AvisYN) AND (SWe.P.EingangYN = false) AND ("SWe.P.Löschmarker" = '')  then begin
        Erx # _rOK;
        BREAK;
      end;
    END;
    if (Erx = _rOK) then begin
      vErg # '';
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Status',         'Avis'));
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Coilnummer',     SWe.P.Coilnummer                        ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Chargennummer',  SWe.P.Chargennummer                     ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Dicke',     Anum(SWe.P.Dicke,Set.Stellen.Dicke)          ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Breite',     Anum(SWe.P.Breite, Set.Stellen.Breite)      ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Laenge',     Anum("SWe.P.Länge", "Set.Stellen.Länge")    ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Stueck',     Aint("SWe.P.Stückzahl")                     ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Gewicht',    Anum(SWe.P.Gewicht,Set.Stellen.Gewicht) ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Guete',          "SWe.P.Güte"                            ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('RID',        Anum(SWe.P.Rid, Set.Stellen.Radien)         ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('RAD',        Anum(SWe.P.Rad, Set.Stellen.Radien)         ) ,', ');
      Lib_Strings:Append(var vErg,_JsnKeyValPairAlpha('Bemerkung1',      SWe.P.Bemerkung                        ) ,', ');
    end;
  end;

  RecBufDestroy(v200Buf);

  if (vErg  = '') then
    vErg # '{'+_JsnKeyValPairAlpha('Status', '')  + '}';

  vErg # '{' + vErg + '}';

  Log('Erg = ' + vErg);

  Log('SweMatWerksnummerLookup ENDE');

  RETURN vErg;
end;


//=========================================================================
// sub MatWareineingangWerksnr(aXmlPara : handle): alpha
//
//  Verbucht einen Wareeneingang anhand eines QR Codes
//=========================================================================
sub MatWareineingang(aXmlPara : handle; opt aBuf200 : int; opt aScannerdata : alpha(1000)): alpha
local begin

  // Handlingsvars
  vErg          : alpha(1000);
  vCall         : alpha;
  vWeTyp        : alpha(4000);
  vGesperrt     : logic;
  vSperrgrund   : alpha(1000);
  v200Buf       : int;
  vQrCodeDaten  : alpha(4000);
  vWerksnr      : alpha(4000);
  vReturnVal    : alpha

end;
begin

  v200Buf # RecBufCreate(200);
  if (aBuf200 <> 0) then
    RecBufCopy(aBuf200,v200Buf);

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    
      Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'BestellID'),        var vWeTyp);
    Log('BestellID')
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Lieferantennr'),    var v200Buf->Mat.Lieferant);
     Log('Lieferantennr')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Lagerplatz'),       var v200Buf->Mat.Lagerplatz);
     Log('Lagerplatz')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Werksnummer'),      var vWerksnr);
     Log('Werksnummer')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'TransportID'),      var v200Buf->Mat.Intrastatnr)
     Log('TransportID')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Ringnummer'),       var v200Buf->Mat.Ringnummer);
     Log('Ringnummer')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Coilnummer'),       var v200Buf->Mat.Coilnummer);
     Log('Coilnummer')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Chargennummer'),    var v200Buf->Mat.Chargennummer);
     Log('Chargennummer')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Dicke'),            var v200Buf->Mat.Dicke);
     Log('Dicke')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Breite'),           var v200Buf->Mat.Breite); Log('Breite')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Laenge'),           var v200Buf->"Mat.Länge");  Log('Laenge')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemDickeVon'),      var v200Buf->Mat.Dicke.Von);  Log('gemDickeVon')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemDickeBis'),      var v200Buf->Mat.Dicke.Bis);  Log('gemDickeBis')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemBreiteVon'),     var v200Buf->Mat.Breite.Von);  Log('gemBreiteVon')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemBreiteBis'),     var v200Buf->Mat.Breite.Bis);  Log('gemBreiteBis')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemLaengeVon'),     var v200Buf->"Mat.Länge.Von");  Log('gemLaengeVon')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemLaengeBis'),     var v200Buf->"Mat.Länge.Bis");  Log('gemLaengeBis')
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Stueck'),           var v200Buf->Mat.Bestand.Stk); Log('Stueck')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Gewicht'),          var v200Buf->Mat.Bestand.Gew); Log('Gewicht')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Gewicht_Netto'),    var v200Buf->Mat.Gewicht.Netto); Log('Gewicht_Netto')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Gewicht_Brutto'),   var v200Buf->Mat.Gewicht.Brutto); Log('Gewicht_Brutto')
    Lib_XML:GetValueI16(Lib_Soa:getNode(aXmlPara,'Verwiegungsart'),   var v200Buf->Mat.Verwiegungsart); Log('Verwiegungsart')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Guete'),            var v200Buf->"Mat.Güte"); Log('Guete')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Guetenstufe'),      var v200Buf->"Mat.Gütenstufe"); Log('Guetenstufe')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'RID'),              var v200Buf->Mat.Rid); Log('RID')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'RAD'),              var v200Buf->Mat.Rad); Log('RAD')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Bemerkung1'),       var v200Buf->Mat.Bemerkung1); Log('Bemerkung1')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Lieferscheinr'),    var v200Buf->Mat.Bemerkung2); Log('Lieferscheinr')
    Lib_XML:GetValueI16(Lib_Soa:getNode(aXmlPara,'Lageranschrift'),   var v200Buf->Mat.Lageranschrift); Log('Lageranschrift')
    Lib_XML:GetValueI16(Lib_Soa:getNode(aXmlPara,'Warengruppe'),      var v200Buf->Mat.Warengruppe); Log('Warengruppe')
    Lib_XML:GetValueB(  Lib_Soa:getNode(aXmlPara,'EigenmaterialYN'),  var v200Buf->Mat.EigenmaterialYN); Log('EigenmaterialYN')
    Lib_XML:GetValueD(  Lib_Soa:getNode(aXmlPara,'Eingangsdatum'),    var v200Buf->Mat.Eingangsdatum); Log('Eingangsdatum')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'AusfuehrungOben'),  var v200Buf->"Mat.AusführungOben"); Log('AusfuehrungOben')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'AusfuehrungUnten'), var v200Buf->"Mat.AusführungUnten"); Log('AusfuehrungUnten')
    Lib_XML:GetValueB(  Lib_Soa:getNode(aXmlPara,'GesperrtYN'),       var vGesperrt); Log('GesperrtYN') //MR temporär Überflüssig da möglicherweise alles über Sperrgrund handlebar
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'Sperrgrund'),       var vSperrgrund); Log('Sperrgrund')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'QrCodeDaten'),   var vQrCodeDaten);
    Log('Variablen OK');
     v200Buf->Mat.Werksnummer # vWerksnr
    
  end;

/*
vWerksnr # 'Cust:VETTER INDUSTRIE GMBH;BundleID:17CFG168;Part:249211;CPart:RB03852;Heat:1-3403;Quantity:3158/ 10;Dim:100,00X40,00  10000,00;Grade:VQ32+;OrdNo:396866/10;S/N:234602;T/O:624569';
v200Buf->Mat.Lieferant # 10150;
*/
  if (StrLen(vWerksnr) > 20) then
    vQrCodeDaten #vWerksnr;

  // Werksnummer konvertieren
  v200Buf->Mat.Werksnummer # _MatWerksnummer(v200Buf->Mat.Lieferant,vWerksnr);

  // ggf. 2D Barcodes für Material vorbelegen
  _MatBarcodeData(v200Buf, var vQrCodeDaten);

   if (WebApp_WE(v200Buf,vWeTyp, var vReturnVal) = false) then
    Lib_Error:OutputToText(var vErg);
  Log('vReturnVal = ' + vReturnVal );
  RecBufDestroy(v200Buf);
  
   if (ErrList=0) then
    vErg # vReturnVal

  RETURN vErg;
end;



//=========================================================================
// sub MatUmlagernWerksnr(aXmlPara : handle; opt aLf : int; opt aLpl : alpha; opt aWnr : alpha): alpha
//
//  Verbucht eine Umlagerung anhand Lieferantennummer und Werksnummer
//=========================================================================
sub MatUmlagerungWerksnr(aXmlPara : handle; opt aLf : int; opt aLpl : alpha; opt aWnr : alpha(1000)): alpha
local begin
  vLieferant    : int;
  vLagerplatz   : alpha;
  vWerksnummer  : alpha(1000);
  vErg          : alpha(1000);
  vQrCodeDaten  : alpha(4000);
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Lieferantennr'), var vLieferant);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Lagerplatz'),    var vLagerplatz);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Werksnummer'),   var vWerksnummer);
  end else begin
    vLieferant      # aLf;
    vLagerplatz     # aLpl;
    vWerksnummer    # aWnr;
  end;

  vWerksnummer # _MatWerksnummer(vLieferant,vWerksnummer);

  if (WebApp_Umlagern_Werksnummer(vLieferant, vWerksnummer, vLagerplatz) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;





//=========================================================================
// sub MatWareineingangAllgemein(aXmlPara : handle): alpha
//
//  Verbucht einen Wareeneingang anhand eines QR Codes
//=========================================================================
sub MatWareneingangMulti(aXmlPara : handle; var aReturnval : alpha; opt aBuf200 : int;): alpha
local begin
  vErg        : alpha(1000);
  v200Buf     : int;
  vWeTyp      : alpha(4000);
  vGesperrt   : alpha;
  vSperrgrund : alpha(1000);
  vEinMenge   : alpha;
  Erx         : int;
end;
begin
   Log('Start');
  v200Buf # RecBufCreate(200);
  if (aBuf200 <> 0) then
    RecBufCopy(aBuf200,v200Buf);

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'BestellID'),        var vWeTyp);
    Log('BestellID')
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Lieferantennr'),    var v200Buf->Mat.Lieferant);
     Log('Lieferantennr')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Lagerplatz'),       var v200Buf->Mat.Lagerplatz);
     Log('Lagerplatz')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Werksnummer'),      var v200Buf->Mat.Werksnummer);
     Log('Werksnummer')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'TransportID'),      var v200Buf->Mat.Intrastatnr)
     Log('TransportID')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Ringnummer'),       var v200Buf->Mat.Ringnummer);
     Log('Ringnummer')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Coilnummer'),       var v200Buf->Mat.Coilnummer);
     Log('Coilnummer')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Chargennummer'),    var v200Buf->Mat.Chargennummer);
     Log('Chargennummer')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Dicke'),            var v200Buf->Mat.Dicke);
     Log('Dicke')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Breite'),           var v200Buf->Mat.Breite); Log('Breite')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Laenge'),           var v200Buf->"Mat.Länge");  Log('Laenge')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemDickeVon'),      var v200Buf->Mat.Dicke.Von);  Log('gemDickeVon')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemDickeBis'),      var v200Buf->Mat.Dicke.Bis);  Log('gemDickeBis')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemBreiteVon'),     var v200Buf->Mat.Breite.Von);  Log('gemBreiteVon')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemBreiteBis'),     var v200Buf->Mat.Breite.Bis);  Log('gemBreiteBis')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemLaengeVon'),     var v200Buf->"Mat.Länge.Von");  Log('gemLaengeVon')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'gemLaengeBis'),     var v200Buf->"Mat.Länge.Bis");  Log('gemLaengeBis')
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Stueck'),           var v200Buf->Mat.Bestand.Stk); Log('Stueck')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Gewicht'),          var v200Buf->Mat.Bestand.Gew); Log('Gewicht')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Gewicht_Netto'),    var v200Buf->Mat.Gewicht.Netto); Log('Gewicht_Netto')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Gewicht_Brutto'),   var v200Buf->Mat.Gewicht.Brutto); Log('Gewicht_Brutto')
    Lib_XML:GetValue (  Lib_Soa:getNode(aXmlPara,'EinMenge'),         var vEinMenge); Log('EinMenge')
    Lib_XML:GetValueI16(Lib_Soa:getNode(aXmlPara,'Verwiegungsart'),   var v200Buf->Mat.Verwiegungsart); Log('Verwiegungsart')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Guete'),            var v200Buf->"Mat.Güte"); Log('Guete')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Guetenstufe'),      var v200Buf->"Mat.Gütenstufe"); Log('Guetenstufe')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'RID'),              var v200Buf->Mat.Rid); Log('RID')
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'RAD'),              var v200Buf->Mat.Rad); Log('RAD')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Bemerkung1'),       var v200Buf->Mat.Bemerkung1); Log('Bemerkung1')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Lieferscheinr'),    var v200Buf->Mat.Bemerkung2); Log('Lieferscheinr')
    Lib_XML:GetValueI16(Lib_Soa:getNode(aXmlPara,'Lageranschrift'),   var v200Buf->Mat.Lageranschrift); Log('Lageranschrift')
    Lib_XML:GetValueI16(Lib_Soa:getNode(aXmlPara,'Warengruppe'),      var v200Buf->Mat.Warengruppe); Log('Warengruppe')
    Lib_XML:GetValueB(  Lib_Soa:getNode(aXmlPara,'EigenmaterialYN'),  var v200Buf->Mat.EigenmaterialYN); Log('EigenmaterialYN')
    Lib_XML:GetValueD(  Lib_Soa:getNode(aXmlPara,'Eingangsdatum'),    var v200Buf->Mat.Eingangsdatum); Log('Eingangsdatum')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'AusfuehrungOben'),  var v200Buf->"Mat.AusführungOben"); Log('AusfuehrungOben')
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'AusfuehrungUnten'), var v200Buf->"Mat.AusführungUnten"); Log('AusfuehrungUnten')
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'GesperrtYN'),       var vGesperrt); Log('GesperrtYN') //MR temporär Überflüssig da möglicherweise alles über Sperrgrund handlebar
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'Sperrgrund'),       var vSperrgrund); Log('Sperrgrund')
    Log('Variablen OK');
  end else begin

    vWeTyp  # v200Buf->Mat.Bestellnummer;
    
  
  end;
   

  if (MatWareneingangMulti_checkArguments(v200Buf) = false) then begin
    Lib_Error:OutputToText(var vErg);
    RETURN vErg;
  end;
 
  Log('Check Typ von: ' + vWeTyp);
  
  // Allgemeiner Wareneingang
  if (vWeTyp  = '') then begin
    if (WebApp_WE_Allgemein(v200Buf, var aReturnVal) = false) then
      Lib_Error:OutputToText(var vErg);
  end;
  
  
  // Eingang auf VSB EK: Bestellnr / BestellPos / VSB Nr
  // vWeTyp = 'xxx/yy/zz'
  if (Str_Count(vWeTyp,'/') = 2) then begin
    v200Buf->Mat.Bestellnummer # vWeTyp;
    
    if (WebApp_WE_EinP_VSB(v200Buf, var aReturnVal) = false) then
      Lib_Error:OutputToText(var vErg);
  
  end;
  
  if (Str_Count(vWeTyp,'/') = 1) then begin
    v200Buf->Mat.Bestellnummer # vWeTyp;
    if (WebApp_WE_EinP(v200Buf,vEinMenge, var aReturnVal) = false) then
      Lib_Error:OutputToText(var vErg);
  end;
  
 
 
if((aReturnVal <> '' and vSperrgrund <> '') or vGesperrt = 'true') then begin
    PtD_Main:Memorize(200);
    Mat.Nummer # cnvia(aReturnVal);
    Erx # RecRead(200,1,_recLock);
    if(Erx > _rMultikey) then begin
      LogErr('Materialnr'+cnvai(cnvia(aReturnVal)) +' konnte nicht gefunden werden');
      Return vErg;
    end
    // Feldübernahme
    Mat.Status # 950;
    Erx # Mat_data:Replace(_RecUnlock,'MAN');
    PtD_Main:Compare(200);

    // Aktionen anlegen...
    RecBufClear(204);
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Aktionstyp    # c_Akt_Status;
    Mat.A.Aktionsnr     # 950;
    Mat.A.Aktionspos    # 900;
    Mat.A.Aktionsdatum  # today;
    Mat.A.Bemerkung     # vSperrgrund;
    Mat_A_Data:Insert(0,'AUTO');
    Log('Materialnr'+cnvai(Mat.Nummer) +' erfolgreich gesperrt.');
    aReturnVal # '';
 end

 //2023-06-27 MR ReturnVal benötigt um einen Key für den Upload von Bildern zu haben bei einem unqualifizierten WE
 if((aReturnVal <>'') and (cnvia(aReturnVal)) <> 0 and (ErrList<>0)) then
    aReturnVal # '';

  RecBufDestroy(v200Buf);

  RETURN vErg;
end;




// -------------------------------------------------------------------
//   Vorbelegung
// -------------------------------------------------------------------
sub MatWareneingangMulti_Vorbelegung(aBuf200 : int;): logic
local begin
  Erx : int;
end;
begin
  Ein.E.Materialnr      # 0;
  Ein.E.VSByn           # n;
  Ein.E.VSB_Datum       # 0.0.0;
  Ein.E.EingangYN       # y;
  Ein.E.Eingangsnr      # 0;
  Ein.E.Eingang_Datum   # aBuf200->Mat.Eingangsdatum;
  if (Ein.E.Eingang_Datum = 0.0.0) then
    Ein.E.Eingang_Datum # today;

  Ein.E.Lageradresse    # Set.eigeneAdressnr;
  Ein.E.Lageranschrift  # aBuf200->Mat.Lageranschrift;
  
  // ST 2023-06-12 2469/41: ggf. in AFX, falls andere Vorgehensweisen notwendig sein sollten
  Ein.E.GesperrtYN      # true;

  Log('Vorbelegung abgeschlossen')
end


// -------------------------------------------------------------------
//   Daten übernehmen
// -------------------------------------------------------------------
sub MatWareneingangMulti_Uebernehmen(aBuf200 : int;): logic
local begin
  Erx : int;
end;
begin
  Ein.E.Lagerplatz      # aBuf200->Mat.Lagerplatz;
  
  if (aBuf200->Mat.Werksnummer <> '') then
    Ein.E.Werksnummer     # aBuf200->Mat.Werksnummer;
  
  if (aBuf200->Mat.Ringnummer <> '') then
    Ein.E.Ringnummer      # aBuf200->Mat.Ringnummer;
        
  if (aBuf200->Mat.Coilnummer <> '') then
    Ein.E.Coilnummer      # aBuf200->Mat.Coilnummer;
  
  if (aBuf200->Mat.Chargennummer <> '') then
  Ein.E.Chargennummer   # aBuf200->Mat.Chargennummer;

  if (aBuf200->Mat.Dicke <> 0.0) then
    Ein.E.Dicke           # aBuf200->Mat.Dicke;
    
  if (aBuf200->Mat.Breite <> 0.0) then
    Ein.E.Breite          # aBuf200->Mat.Breite;
    
  if (aBuf200->"Mat.Länge" <> 0.0) then
    "Ein.E.Länge"         # aBuf200->"Mat.Länge";

  Ein.E.Dicke.Von       # aBuf200->Mat.Dicke.Von;
  Ein.E.Dicke.Bis       # aBuf200->Mat.Dicke.Bis;
  Ein.E.Breite.Von      # aBuf200->Mat.Breite.Von;
  Ein.E.Breite.Bis      # aBuf200->Mat.Breite.Bis;
  "Ein.E.Länge.Von"     # aBuf200->"Mat.Länge.Von";
  "Ein.E.Länge.Bis"     # aBuf200->"Mat.Länge.Bis";
  
  "Ein.E.Stückzahl"     # aBuf200->Mat.Bestand.Stk;
  Ein.E.Gewicht         # aBuf200->Mat.Bestand.Gew;
  Ein.E.Gewicht.Netto   # aBuf200->Mat.Gewicht.Netto;
  Ein.E.Gewicht.Brutto  # aBuf200->Mat.Gewicht.Brutto;
  Ein.E.Verwiegungsart  # aBuf200->Mat.Verwiegungsart;
  "Ein.E.Güte"          # aBuf200->"Mat.Güte";
  "Ein.E.Gütenstufe"    # aBuf200->"Mat.Gütenstufe";
  Ein.E.RID             # aBuf200->Mat.Rid;
  Ein.E.RAD             # aBuf200->Mat.Rad;
  
  if (aBuf200->Mat.Bemerkung1 <> '') then
    Ein.E.Bemerkung       # aBuf200->Mat.Bemerkung1;
    
  if (aBuf200->Mat.Bemerkung2 <> '') then
    Ein.E.Lieferscheinnr  # aBuf200->Mat.Bemerkung2;

  Ein.E.Warengruppe     # aBuf200->Mat.Warengruppe;
    
  Ein.E.AusfOben        # Ein.P.AusfOben;         // Erstmal übernahme aus Bestellpos
  Ein.E.AusfUnten       # Ein.P.AusfUnten;        // Erstmal übernahme aus Bestellpos

  // Übernahme aus Posdaten und generierte Daten
  Ein.E.Lieferantennr   #  Ein.P.Lieferantennr;
  
  /* zu Klären
  Ein.E.Ursprungsland   #
  */
  
  if ("Ein.E.Stückzahl" = 0) then
    "Ein.E.Stückzahl"  # 1;
  
  EDI_Analysen:_RecCalcEinE();   //

  Ein.E.Anlage.User     # gUserName;
  Ein.E.Anlage.Datum    # Today;
  Ein.E.Anlage.Zeit     # Now;

  Ein.E.MEH             # Ein.P.MEH;
  Ein.E.Artikelnr       # Ein.P.Artikelnr;
  Ein.E.Kommission      # Ein.P.Kommission;
  "Ein.E.Währung"       # "Ein.Währung";
  Ein.E.Intrastatnr     # Ein.P.Intrastatnr;

  Ein.E.AbbindungL        # Ein.P.AbbindungL;
  Ein.E.AbbindungQ        # Ein.P.AbbindungQ;
  Ein.E.Zwischenlage      # Ein.P.Zwischenlage;
  Ein.E.Unterlage         # Ein.P.Unterlage;
  Ein.E.Umverpackung      # Ein.P.Umverpackung;
  Ein.E.Wicklung          # Ein.P.Wicklung;
  Ein.E.StehendYN         # Ein.P.StehendYN;
  Ein.E.LiegendYN         # Ein.P.LiegendYN;
  Ein.E.Nettoabzug        # Ein.P.Nettoabzug;
  "Ein.E.Stapelhöhe"      # "Ein.P.Stapelhöhe";
  "Ein.E.Stapelhöhenabz"  # "Ein.P.StapelhAbzug";
  Ein.E.AusfOben          # Ein.P.AusfOben;
  Ein.E.AusfUnten         # Ein.P.AusfUnten;

  
  Ein.E.Nummer        # Ein.P.Nummer;
  Ein.E.Position      # Ein.P.Position;
  Ein.E.Anlage.User   # gUserName;
  
  
  Log('Daten übernahme abgeschlossen')
  
  
end



// -------------------------------------------------------------------
//   Argumentprüfung
// -------------------------------------------------------------------
sub MatWareneingangMulti_checkArguments(aBuf200 : int;): logic
local begin
  Erx : int;
end;
begin
  Log('Argumenteprüfung...');
  // Lieferant lesen
  Adr.Lieferantennr # aBuf200->Mat.Lieferant;
  Erx # RecRead(100,3,0);
  if (Erx > _rMultikey) or (Adr.Lieferantennr = 0) then begin
    LogErr('Lieferant nicht gefunden');
    RETURN false;
  end;
  Log('Lieferant gelesen: ' + Aint(Adr.Lieferantennr) + ' ' + Adr.Stichwort);

  // Verwiegungsart lesen
  VwA.Nummer # aBuf200->Mat.Verwiegungsart;
  Erx # RecRead(818,1,0);
  if (Erx <> _rOK) then begin
    LogErr('Verwiegungsart nicht gefunden');
    RETURN false;
  end;
  Log('Verwiegungsart gelesen: ' + Aint(VwA.Nummer) + ' ' + VwA.Bezeichnung.L1);

  // Lageranschrift lesen
  Adr.A.Adressnr  # Set.eigeneAdressnr;
  Adr.A.Nummer   # aBuf200->Mat.Lageranschrift;
  Erx # RecRead(101,1,0);
  if (Erx <> _rOK) then begin
    LogErr('Lageranschrift nicht gefunden');
    RETURN false;
  end;
  Log('Lageranschrift gelesen: ' + Aint(Adr.A.Nummer) + ' ' + Adr.A.Stichwort);

  // Warengruppe lesen
  Wgr.Nummer # aBuf200->Mat.Warengruppe;
  Erx # RecRead(819,1,0);
  if (Erx <> _rOK) then begin
    LogErr('Warengruppe nicht gefunden');
    RETURN false;
  end;
  Log('Warengruppe gelesen: ' + Aint(Wgr.Nummer) + ' ' + Wgr.Bezeichnung.L1);

  // Gütenstufe lesen
  if (aBuf200->"Mat.Gütenstufe" <> '') then begin
    MQu.S.Stufe # aBuf200->"Mat.Gütenstufe";
    Erx # RecRead(848,1,0);
    if (Erx <> _rOK) then begin
      LogErr('Gütenstufe nicht gefunden');
      RETURN false;
    end;
    Log('Gütenstufe gelesen: ' + MQu.S.Stufe + ' ' + Mqu.S.Name);
  end;

  // Güte lesen
  if (StrAdj(aBuf200->"Mat.Güte",_StrAll) = '') then begin
    LogErr('Güte muss angegeben werden');
    RETURN false;
  end;


  Log('Argumenteprüfung...OK');
  RETURN true;
end;

// -------------------------------------------------------------------
sub MatWareneingangMultiTest()
local begin
  v200  : int;
  vRet  : alpha;
  vRes  : alpha;
end
begin
  Ein.P.Nummer # 1464;
  Ein.P.Position # 1;
  Recread(501,1,0);
  
  
  v200 # RecBufCreate(200);
  
  v200->Mat.Bestellnummer     # '1464/1';
  v200->Mat.Lieferant         #  125;
  v200->Mat.Verwiegungsart    # 1;
  
  v200->Mat.Lageranschrift    # Set.Ein.Lieferanschr;
  v200->Mat.Warengruppe       # Ein.P.Warengruppe;
  v200->"Mat.Güte"            # "Ein.P.Güte";
  v200->Mat.Bestand.Gew       # 24555.0;
  v200->Mat.Gewicht.Brutto    # v200->Mat.Bestand.Gew;
  v200->Mat.Gewicht.Netto     # v200->Mat.Bestand.Gew;
   
  vRes #  MatWareneingangMulti(0, var vRet, v200);
  RecBufDestroy(v200);
end



//=========================================================================
// sub MatUmlagerung(aXmlPara : handle; opt aLpl : alpha; opt aMats : alpha(4000)): alpha
//
//  Verbucht eine Umlagerung anhand Lieferantennummer und Werksnummer
//=========================================================================
sub MatUmlagerung(aXmlPara : handle; opt aLpl : alpha; opt aMats : alpha(4000)): alpha
local begin
  vLagerplatz   : alpha;
  vMats         : alpha(1000);
  vErg          : alpha(1000);
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Lagerplatz'),    var vLagerplatz);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Materialien'),   var vMats);
  end else begin
    vLagerplatz     # aLpl;
    vMats           # aMats;
  end;

  if (WebApp_Umlagern(vLagerplatz, vMats) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;



//=========================================================================
// sub MatUmlagerungLagerplaetze(aXmlPara : handle; opt aLagerplatz_Von : alpha; opt aLagerplatz_Nach : alpha): alpha
//
//  Verbucht eine Umlagerung anhand von Lagerplaetzen
//=========================================================================
sub MatUmlagerungLagerplaetze(aXmlPara : handle; opt aLagerplatz_Von : alpha; opt aLagerplatz_Nach : alpha): alpha
local begin
  vLagerplatz_Von   : alpha;
  vLagerplatz_Nach  : alpha;
  vErg              : alpha;
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Lagerplatz_Von'),    var vLagerplatz_Von);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Lagerplatz_Nach'),   var vLagerplatz_Nach);
  end else begin
    vLagerplatz_Von       # aLagerplatz_Von;
    vLagerplatz_Nach      # aLagerplatz_Nach;
  end;

  if (WebApp_Umlagern_Lagerplaetze(vLagerplatz_Von, vLagerplatz_Nach) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;




//=========================================================================
// sub MatSperren(aXmlPara : handle;  opt aMats : alpha(8000); opt aGrund  : alpha; opt aEtkNr : int; ): alpha
//
//  Sperrt die angegebenen Materialien
//=========================================================================
sub MatSperren(aXmlPara : handle;  opt aMats : alpha(8000); opt aGrund  : alpha; opt aEtkNr : int; ): alpha
local begin
  vGrund        : alpha;
  vMats         : alpha(8000);
  vErg          : alpha(1000);
  vEtkNr        : int;
end;
begin
  
  
  Log(cnvai(aXmlPara));
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Grund'),    var vGrund);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Materialien'),   var vMats);
    Lib_XML:GetValueI(   Lib_Soa:getNode(aXmlPara,'EtkNr'),   var vEtkNr);
  end else begin
    vGrund          # aGrund;
    vMats           # aMats;
    vEtkNr          # aEtkNr;
  end;
  log(vMats);
  if (WebApp_MatSperren(vMats, vGrund, vEtkNr) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;




//=========================================================================
// sub MatSplitten(aXmlPara : handle;  opt aMats : alpha(8000); opt aGrund  : alpha; opt aEtkNr : int; ): alpha
//
//  Splitten von Material
//=========================================================================
	sub MatSplitten(aXmlPara : handle;  opt aMatNr : int; opt aGewBrutto : float; opt aGewNetto : float; opt aLaenge :float; opt aStk : int;opt aDatum : date; opt aPrintMatEtikYN : logic ): alpha;
local begin
  vMatNr          : int;
  vGewBrutto      : float;
  vGewNetto       : float;
  vLaenge         : float;
  vStk            : int;
  vDatum          : date;
  vPrintMatEtikYN : logic;
  tmpPrintMatEtk  : alpha;
  vErg        : alpha(1000);
end;
begin
  
  
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(   Lib_Soa:getNode(aXmlPara,'MatNr'),    var vMatNr);
    Lib_XML:GetValueF(   Lib_Soa:getNode(aXmlPara,'GewNetto'),   var vGewNetto);
    Lib_XML:GetValueF(   Lib_Soa:getNode(aXmlPara,'GewBrutto'),   var vGewBrutto);
    Lib_XML:GetValueF(   Lib_Soa:getNode(aXmlPara,'Laenge'),   var vLaenge) //Holzrichter Custom Prop
    Lib_XML:GetValueI(   Lib_Soa:getNode(aXmlPara,'Stk'),   var vStk);
    Lib_XML:GetValueD(   Lib_Soa:getNode(aXmlPara,'Datum'),   var vDatum);
    Lib_XML:GetValue(    Lib_Soa:getNode(aXmlPara,'PrintMatEtikYN'),   var tmpPrintMatEtk)
    
    if(tmpPrintMatEtk = 'true') then
      vPrintMatEtikYN # true;
    else vPrintMatEtikYN # false;
    
    
    
  end else begin
    vMatNr        # aMatNr;
    vGewBrutto    # aGewBrutto;
    vGewNetto     # aGewNetto;
    vStk          # aStk;
    vDatum        # aDatum;
  end;
  if (WebApp_MatSplitten(vMatNr, vGewBrutto, vGewNetto, vLaenge, vStk ,vDatum , vPrintMatEtikYN ) = false) then
    Lib_Error:OutputToText(var vErg);
  RETURN vErg;
end;

//=========================================================================
// MatUmreservieren(aXmlPara : handle;  opt aMatNrListe : alpha(8000); opt aRsvNr  : int;):alpha
//
//  Umreservieren
//=========================================================================
sub MatUmreservieren(aXmlPara : handle;  opt aMatNrListe : alpha(8000); opt aKommission  : alpha(1000);):alpha
local begin
  vMatNrListe  : alpha(8000);
  vKommission  : alpha(1000);
  vErg         : alpha(1000);
end;
begin
  
  
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'MaterialListe'),    var vMatNrListe);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Kommission'),   var vKommission);
  end else begin
    vMatNrListe   # aMatNrListe;
    vKommission        # aKommission;
  end;

  if (WebApp_MatUmreservieren(vMatNrListe, vKommission) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;


//=========================================================================
// sub MatInventur(aXmlPara : handle;  opt aAufnahmetyp  : alpha;
//                opt aEtikettendruckYN : alpha; opt a200 : int; opt a259 : int): alpha
//
//  Verbucht einen Inventurdatensatz
//=========================================================================
sub MatInventur(
  aXmlPara : handle;
  opt aAufnahmetyp      : alpha;
  opt aEtikettendruckYN : alpha;
  opt a200 : int;
  opt a259 : int): alpha
local begin
  vErg          : alpha(1000);

  vAufnahmetyp      : alpha;
  vEtikettendruckYN : alpha;
  v200 :  int;
  v259 :  int;
end;
begin

  v200  # RecBufCreate(200);
  v259  # RecBufCreate(259);

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Aufnahmetyp'),      var vAufnahmetyp);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'EtikettendruckYN'), var vEtikettendruckYN);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'InvNummer'),        var v259->Art.Inv.Nummer);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'InvLageradresse'),  var v259->Art.Inv.Adressnr);
    Lib_XML:GetValueI16(Lib_Soa:getNode(aXmlPara,'InvLageranschrift'),var v259->Art.Inv.Anschrift);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'InvLagerplatz'),    var v259->Art.Inv.Lagerplatz);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'InvMaterialnr'),    var v259->Art.Inv.Materialnr);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'InvStk'),           var v259->"Art.Inv.Stückzahl");
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'InvMenge'),         var v259->"Art.Inv.Menge");
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'InvBemerkung'),     var v259->Art.Inv.Bemerkung);
    Lib_XML:GetValueI16(Lib_Soa:getNode(aXmlPara,'MatWarengruppe'),   var v200->Mat.Warengruppe);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'MatGuete'),         var v200->"Mat.Güte");
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'MatLieferant'),     var v200->"Mat.Lieferant");
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'MatCoilnummer'),    var v200->"Mat.Coilnummer");
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'MatChargennummer'), var v200->"Mat.Chargennummer");
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'MatDicke'),         var v200->"Mat.Dicke");
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'MatBreite'),        var v200->"Mat.Breite");
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'MatLaenge'),        var v200->"Mat.Länge");
  end else begin
    vAufnahmetyp              # aAufnahmetyp;
    vEtikettendruckYN         # aEtikettendruckYN;
    v259->Art.Inv.Nummer      # a259->Art.Inv.Nummer;
    v259->Art.Inv.Adressnr    # a259->Art.Inv.Adressnr;
    v259->Art.Inv.Anschrift   # a259->Art.Inv.Anschrift;
    v259->Art.Inv.Lagerplatz  # a259->Art.Inv.Lagerplatz;
    v259->Art.Inv.Materialnr  # a259->Art.Inv.Materialnr;
    v259->"Art.Inv.Stückzahl" # a259->"Art.Inv.Stückzahl";
    v259->"Art.Inv.Menge"     # a259->"Art.Inv.Menge";
    v259->Art.Inv.Bemerkung   # a259->Art.Inv.Bemerkung;
    v200->Mat.Warengruppe     # a200->Mat.Warengruppe;
    v200->"Mat.Güte"          # a200->"Mat.Güte";
    v200->"Mat.Lieferant"     # a200->"Mat.Lieferant";
    v200->"Mat.Coilnummer"    # a200->"Mat.Coilnummer";
    v200->"Mat.Chargennummer" # a200->"Mat.Chargennummer";
    v200->"Mat.Dicke"         # a200->"Mat.Dicke";
    v200->"Mat.Breite"        # a200->"Mat.Breite";
    v200->"Mat.Länge"         # a200->"Mat.Länge";
  end;

  if (WebApp_MatInventur(vAufnahmetyp,(vEtikettendruckYN = 'on'), v200, v259) = false) then
    Lib_Error:OutputToText(var vErg);

  RecBufDestroy(v200);
  RecBufDestroy(v259);

  RETURN vErg;
end;






//=========================================================================
// sub sub LfsVerbuchcheVldaw(aXmlPara : handle; opt aLfNr : int) : alpha
//
//  Verbucht eine Verladeanweisung
//=========================================================================
sub LfsVerbucheVldaw(aXmlPara : handle; opt aLfNr : int; opt aMats : alpha(4000); opt aVerbuchen : logic) : alpha
local begin
  vLfsNr        : int;
  vErg          : alpha(1000);
  vMats         : alpha(4000);
  vVerbuchen    : logic;
  vVerbuchenStr : alpha(1000);
  vBuf440       : int;
  
end;
begin
  // Daten extrahieren
  
  vBuf440 # RecBufCreate(440)
  
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Lieferscheinnr'), var vLfsNr);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Materialien'), var vMats);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Kennzeichen'), var vBuf440->LFS.Kennzeichen);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Spediteur'), var vBuf440->Lfs.Spediteur);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara, 'SpediteurNr'), var vBuf440->Lfs.Spediteurnr);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Fahrer'), var vBuf440->Lfs.Fahrer);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Bemerkung'), var vBuf440->Lfs.Bemerkung);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Referenznummer'), var vBuf440->Lfs.Referenznr);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Verbuchen'), var vVerbuchenStr);
    vVerbuchen # (vVerbuchenStr <> 'false');
  end else begin
    vLfsNr    # aLfNr;
    vMats     # aMats;
    vVerbuchen # aVerbuchen;
  end;
//,vFahrer, vSpediteur, vSpediteurNr, vBemerkung, vReferenznr,vKennzeichen
  if (WebApp_LFS_VerbucheVldaw(vLfsNr, vMats, vVerbuchen, vBuf440) = false) then
    Lib_Error:OutputToText(var vErg);
  
  RecBufDestroy(vBuf440)
  
  RETURN vErg;
end;




//=========================================================================
// sub sub LfsVerbuchcheVldaw(aXmlPara : handle; opt aLfNr : int) : alpha
//
//  Verbucht eine Verladeanweisung
//=========================================================================
sub LfsVerbucheVldawVsP(aXmlPara : handle; opt aLfNr : int; opt aMats : alpha(8000); opt aVerbuchen : logic) : alpha
local begin
  vLfsNr        : int;
  vErg          : alpha(1000);
  vMats         : alpha(8000);
  vVerbuchen    : logic;
  vVerbuchenStr : alpha(1000);
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Lieferscheinnr'), var vLfsNr);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Materialien'), var vMats);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Verbuchen'), var vVerbuchenStr);
    vVerbuchen # (vVerbuchenStr <> 'false');
  end else begin
    vLfsNr    # aLfNr;
    vMats     # aMats;
    vVerbuchen # aVerbuchen;
  end;

  if (WebApp_LFS_VerbucheVldawVsP(vLfsNr, vMats, vVerbuchen) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;



//=========================================================================
// sub sub LfsVerbucheLFS(aXmlPara : handle; opt aLfNr : int) : alpha
//
//  Verbucht eine Verladeanweisung
//=========================================================================
sub LfsVerbucheLFS(aXmlPara : handle; opt aLieferscheine : alpha(1000)) : alpha
local begin
  vLfsNr          : int;
  vErg            : alpha(1000);
  vLieferscheine  : alpha(1000);
  vCnt            : int;
  vI              : int;
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara,'Lieferscheine'),  var vLieferscheine);
  end else begin
    vLieferscheine  # aLieferscheine;
  end;
  Log('Los gehts mit : ' + vLieferscheine);

  vCnt # Str_Count(vLieferscheine, '|') + 1;
  FOR   vI # 1
  LOOP  inc(vI)
  WHILE vI <= vCnt DO BEGIN
    vLfsNr # CnvIa(Str_Token(vLieferscheine, '|',vI));
    Log(' Verbuche' +Aint(vLfsNr));
    if (WebApp_LFS_Verbuchen(vLfsNr) = false) then
      BREAK;
  END;
  Log('Fertig mit: ' + vLieferscheine);

  if (ErrList <> 0) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;


//=========================================================================
// sub LfaFertigmeldungEinzeln(aXmlPara : handle; opt aLfNr : int) : alpha
//
//  Verbucht einzelne Positionen eines Fahrauftrages
//=========================================================================
sub LfaFertigmeldungEinzeln(aXmlPara : handle; opt aLfNr : int; opt aMats : alpha(4000);) : alpha
local begin
  vLfsNr        : int;
  vErg          : alpha(1000);
  vMats         : alpha(4000);
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Lieferscheinnr'), var vLfsNr);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Materialien'), var vMats);
  end else begin
    vLfsNr    # aLfNr;
    vMats     # aMats;
  end;

  if (WebApp_LfaFertigmeldungEinzeln(vLfsNr, vMats) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;


//=========================================================================
// sub sub LfsVerbuchcheVldaw(aXmlPara : handle; opt aLfNr : int) : alpha
//
//  Verbucht eine Verladeanweisung
//=========================================================================
sub LfsAusNeuerVerladung(
  aXmlPara : handle;
  opt aMaterialien : alpha(4000);
  opt aLieferdat : date;
  opt aMaxLadung : float;
  opt aSpediteurNr : int;
  opt aReferenz : alpha;
  ) : alpha
local begin
  vTmp        : alpha;

  vErg          : alpha(1000);
  vMats         : alpha(4000);

  vLieferDat    : date;
  vMaxLadung    : float;
  vSpediteurnr  : int;
  vReferenz     : alpha(100);
end;
begin

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara, 'Materialien'),       var vMats);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,  'Lieferdatum'),      var vTmp);
    vLieferDat    # CnvDa(vTmp,_FmtDateYMD);
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'MaxLadegewicht'), var vMaxLadung);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Spediteur'),          var vSpediteurnr);
    Lib_XML:GetValue(   Lib_Soa:getNode(aXmlPara, 'Referenz'),          var vReferenz);
  end else begin
    vMats         # aMaterialien;
    vLieferDat    # aLieferdat  ;
    vMaxLadung    # aMaxLadung  ;
    vSpediteurnr  # aSpediteurNr;
    vReferenz     # aReferenz   ;
  end;
  if (WebApp_Lfs_NeuAusVerladung(vMats, vLieferDat, vMaxLadung, vSpediteurnr, vReferenz) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;




//=========================================================================
// sub MatAbruf(aXmlPara : handle; opt aMats : alpha; opt aTermin : alpha; opt aAdrNr : int): alpha
//
//  Ruft die markierten Materialkarten ab indem ein neuer Auftrag erstellt
//  wird und das Material darauf kommissioniert wird.
//=========================================================================
sub MatAbruf(aXmlPara : handle; opt aMats : alpha; opt aTermin : alpha; opt aClientUser : alpha; opt aLieferAdr : alpha): alpha
local begin
  Erx     : int;
  // Handlingsvars
  vErg  : alpha(1000);
  vCall : alpha;

  vMats :  alpha(4000);
  vWunschterm : alpha;
  vClientUser : alpha;
  vLieferAdr  : alpha;

  v800 : int;
end;
begin

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'Materialien'), var vMats);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'Wunschtermin'), var vWunschterm);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'ClientUser'), var vClientUser );
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'Lieferadresse'), var vLieferAdr );
  end else begin
    vMats       # aMats;
    vWunschterm # aTermin;
    vClientUser # aClientUser;
    vLieferAdr  # aLieferAdr;
  end;

  // Adresse lesen
  v800 # RecBufCreate(800);
  v800->Usr.Username # vClientUser;
  Erx # RecRead(v800,1,0);
  if (Erx <> _rOK) OR ((Erx = _rOK) = Usr.DeaktiviertYN) then begin
    RETURN 'User issue';
  end;

  // Kommissionierung durchführen
  if (WebApp_MatAbruf(v800, vMats, vWunschterm,vLieferAdr) = false) then
    Lib_Error:OutputToText(var vErg);
  RecBufDestroy(v800);

  RETURN vErg;
end;





//=========================================================================
// sub sub AufZuordnung(...) : alpha
//
//  Verbucht eine Kommmissionierung
//=========================================================================
sub AufZuordnung(
  aXmlPara                        : handle;
  opt aAufNr                      : int;
  opt aAufPos                     : int;
  opt aStk                        : int;
  opt aGew                        : float;
  opt aMenge                      : float;
  opt aMat                        : alpha;
  opt aRsvNr                      : int;
  opt aKannMehrKommissionierenYN  : logic;
  ) : alpha
local begin
  vAufNr                      : int;
  vAufPos                     : int;
  vStk                        : int;
  vGew                        : float;
  vMenge                      : float;
  vMat                        : alpha;
  vRsvNr                      : int;
  vErg                        : alpha(1000);
  vTmpValYN  : alpha;
  vKannMehrKommissionierenYN  : logic;
end;
begin
  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Auftragsnr'), var vAufNr);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Auftragspos'), var vAufPos);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'Stk'), var vStk);
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Gewicht'), var vGew);
    Lib_XML:GetValueF(  Lib_Soa:getNode(aXmlPara,'Menge'), var vMenge);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Material'), var vMat);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara, 'ReservierungNr'), var vRsvNr);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'KannMehrKommissionierenYN'), var vTmpValYN)
    
   if(vTmpValYN = 'true') then
    vKannMehrKommissionierenYN # true;
   else vKannMehrKommissionierenYN # false;
    
  end else begin
    vAufNr      # aAufNr;
    vAufPos     # aAufPos;
    vStk        # aStk;
    vGew        # aGew;
    vMenge      # aMenge;
    vMat        # aMat;
    vRsvNr      # aRsvNr;
  end;
    
    

    
 
  if (WebApp_Auf_Zuordnung(vAufNr,vAufPos,vStk,vGew,vMenge,vMat,vRsvNr, vKannMehrKommissionierenYN) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;



//=========================================================================
// sub MarkAufAlsErld(...)
//
//  Löscht Reservierungen aus Auf
//=========================================================================
sub MarkAufAlsErld(
  aXmlPara : handle;
  opt aAufNr   : int;
  opt aAufPos  : int;
  ): alpha
local begin
  vErg       : alpha(1000);
  vAufNr     :  int;
  vAufPos    :  int;
end;
begin

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,'AufNr'),       var vAufNr);
    Lib_XML:GetValueI(  Lib_Soa:getNode(aXmlPara,'AufPos'),      var vAufPos);
  end else begin
    vAufNr    # aAufNr;
    vAufPos # aAufPos;
  end;

  if (WebApp_MarkAufAlsErld(vAufNr, vAufPos) = false) then
    Lib_Error:OutputToText(var vErg);

  RETURN vErg;
end;


//=========================================================================
// sub BagAbschluss(...)
//
//  Schließt eine Betriebsauftragposition ab
//=========================================================================
sub BagAbschluss(
  aXmlPara : handle;
  opt a702   : int;): alpha
local begin
  vErg       : alpha(1000);
  v702       :  int;
end;
begin
  v702  # RecBufCreate(702);

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,'BagNummer'),        var v702->BAG.P.Nummer);
    Lib_XML:GetValueI16(  Lib_Soa:getNode(aXmlPara,'BagPosition'),      var v702->BAG.P.Position);
  end else begin
    v702->Bag.P.Nummer    # a702->BAG.P.Nummer;
    v702->Bag.P.Position  # a702->BAG.P.Position;
  end;

  if (WebApp_BagAbschluss(v702) = false) then
    Lib_Error:OutputToText(var vErg);

  RecBufDestroy(v702);

  RETURN vErg;
end;




//=========================================================================
// sub BagFertigmeldungTheo(...)
//
//  Meldet einen Betriebsauftrag mit theoretischen Werten fertig
//=========================================================================
sub BagFertigmeldungTheo(
  aXmlPara : handle;
  opt a702   : int;): alpha
local begin
  vErg       : alpha(1000);
  v702       :  int;
end;
begin
  v702  # RecBufCreate(702);


  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,'BagNummer'),        var v702->BAG.P.Nummer);
    Lib_XML:GetValueI16(  Lib_Soa:getNode(aXmlPara,'BagPosition'),      var v702->BAG.P.Position);
  end else begin
    v702->Bag.P.Nummer    # a702->BAG.P.Nummer;
    v702->Bag.P.Position  # a702->BAG.P.Position;
  end;

  if (WebApp_BagFertigmeldungTheo(v702) = false) then
    Lib_Error:OutputToText(var vErg);
log(vErg);

  RecBufDestroy(v702);

  RETURN vErg;
end;




//=========================================================================
// sub BagFertigmeldung(...)
//
//  Meldet eine Verwiegung zu einem Betriebsauftrag fertig
// [+] 2022-08-12 MR Ergänzung um Rid und Rad
//=========================================================================
sub BagFertigmeldung(
  aXmlPara : handle;
  opt a701          : int;
  opt a707          : int;
  opt aCustomInput  : alpha(1000);): alpha
local begin
  vErg       : alpha(1000);
  v701       : int;
  v707       : int;
  vCustomInput  : alpha(8096);
end;
begin
  v701  # RecBufCreate(701);
  v707  # RecBufCreate(707);

	  // Daten extrahieren
  if (aXmlPara > 0) then begin
  //log(aParentNode->CteRead(_CteSearch | _CteFirst |_CteChildList ,0 , aName));
    // Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,''),      var v707->);
    Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,'BagNummer'),    var v707->"BAG.FM.Nummer");
    Lib_XML:GetValueI16(  Lib_Soa:getNode(aXmlPara,'BagPosition'),  var v707->"BAG.FM.Position");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Breite'),       var v707->"BAG.FM.Breite");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Dicke'),        var v707->"BAG.FM.Dicke");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Laenge'),       var v707->"BAG.FM.Länge");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Rad'),          var v707->"BAG.FM.RAD");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Rid'),          var v707->"BAG.FM.RID");
    Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,'Stueckzahl'),   var v707->"BAG.FM.Stück");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Bruttogewicht'),var v707->"BAG.FM.Gewicht.Brutt");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Nettogewicht'), var v707->"BAG.FM.Gewicht.Netto");
    Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,'EinsatzmatNr'), var v701->"BAG.IO.Materialnr");
    Lib_XML:GetValueI16(  Lib_Soa:getNode(aXmlPara,'BagFertigung'), var v707->"BAG.FM.Fertigung");
    Lib_XML:GetValue(     Lib_Soa:getNode(aXmlPara,'Lagerplatz'),   var v707->"BAG.FM.Lagerplatz");
    Lib_XML:GetValue(     Lib_Soa:getNode(aXmlPara,'Bemerkung'),    var v707->"BAG.FM.Bemerkung");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'PlanInMenge'),    var v707->"BAG.FM.Menge");
    Lib_XML:GetValue(     Lib_Soa:getNode(aXmlPara,'CustomInput'),  var vCustomInput);
  end else begin
    v701->"BAG.IO.Materialnr"     # a701->"BAG.IO.Materialnr";
    v707->"BAG.FM.Nummer"         # a707->"BAG.FM.Nummer";
    v707->"BAG.FM.Position"       # a707->"BAG.FM.Position";
    v707->"BAG.FM.Fertigung"      # a707->"BAG.FM.Fertigung";
    v707->"BAG.FM.Dicke"          # a707->"BAG.FM.Dicke";
    v707->"BAG.FM.Breite"         # a707->"BAG.FM.Breite";
    v707->"BAG.FM.Länge"          # a707->"BAG.FM.Länge";
    v707->"BAG.FM.RAD"            # a707->"BAG.FM.RAD";
    v707->"BAG.FM.RID"            # a707->"BAG.FM.RID";
    v707->"BAG.FM.Stück"          # a707->"BAG.FM.Stück";
    v707->"BAG.FM.Gewicht.Brutt"  # a707->"BAG.FM.Gewicht.Brutt";
    v707->"BAG.FM.Gewicht.Netto"  # a707->"BAG.FM.Gewicht.Netto";
    v707->"BAG.FM.Lagerplatz"     # a707->"BAG.FM.Lagerplatz";
    v707->"BAG.FM.Bemerkung"      # a707->"BAG.FM.Bemerkung";
    v707->"BAG.FM.Menge"          # a707->"BAG.FM.Menge";
    vCustomInput                  # aCustomInput;
  end
  
   if (WebApp_BagFertigmeldung(v701,v707, vCustomInput) = false) then
    Lib_Error:OutputToText(var vErg);

  RecBufDestroy(v701);
  RecBufDestroy(v707);

  RETURN vErg;
end;



/*=========================================================================
 sub BagArbeitsschritteUpdate                                MR 28.07.2022

  Speichert die aktuell gesetzten Arbeitsschritte
=========================================================================*/
sub BagFertigmeldungPaketieren(
  aXmlPara            : handle;
  opt a707            : int;
  opt a280            : int;
  opt aInputListe     : alpha(8096);
  ):alpha
local begin
  vErg            : alpha(1000);
  v707            : int;
  v280            : int;
  vInputListe     : alpha(8096);
  vVerpackungstyp : alpha(8096);
end
begin
  v707  # RecBufCreate(707);
  v280  # RecBufCreate(280);
  


  // Daten extrahieren
  if (aXmlPara > 0) then begin
  //log(aParentNode->CteRead(_CteSearch | _CteFirst |_CteChildList ,0 , aName));
    // Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,''),      var v707->);
    Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,'BagNummer'),     var v707->"BAG.FM.Nummer");
    Lib_XML:GetValueI16(  Lib_Soa:getNode(aXmlPara,'BagPosition'),   var v707->"BAG.FM.Position");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Breite'),        var v707->"BAG.FM.Breite");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Dicke'),         var v707->"BAG.FM.Dicke");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Laenge'),        var v707->"BAG.FM.Länge");
    Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,'Stueckzahl'),    var v707->"BAG.FM.Stück");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Bruttogewicht'), var v707->"BAG.FM.Gewicht.Brutt");
    Lib_XML:GetValueF(    Lib_Soa:getNode(aXmlPara,'Nettogewicht'),  var v707->"BAG.FM.Gewicht.Netto");
    Lib_XML:GetValueI16(  Lib_Soa:getNode(aXmlPara,'BagFertigung'),  var v707->"BAG.FM.Fertigung");
    Lib_XML:GetValue(     Lib_Soa:getNode(aXmlPara,'Lagerplatz'),    var v707->"BAG.FM.Lagerplatz");
    Lib_XML:GetValue(     Lib_Soa:getNode(aXmlPara,'Bemerkung'),     var v707->"BAG.FM.Bemerkung");
    Lib_XML:GetValueI16(  Lib_Soa:getNode(aXmlPara,'Verwiegungsart'),var v707->"BAG.FM.Verwiegungart");
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'Umverpackung'),  var v280->"Pak.Umverpackung");
    Lib_XML:GetValue(     Lib_Soa:getNode(aXmlPara,'EinsatzList'),   var vInputListe);
  end else begin
    v707->"BAG.FM.Nummer"         # a707->"BAG.FM.Nummer";
    v707->"BAG.FM.Position"       # a707->"BAG.FM.Position";
    v707->"BAG.FM.Fertigung"      # a707->"BAG.FM.Fertigung";
    v707->"BAG.FM.Dicke"          # a707->"BAG.FM.Dicke";
    v707->"BAG.FM.Breite"         # a707->"BAG.FM.Breite";
    v707->"BAG.FM.Länge"          # a707->"BAG.FM.Länge";
    v707->"BAG.FM.Gewicht.Brutt"  # a707->"BAG.FM.Gewicht.Brutt";
    v707->"BAG.FM.Gewicht.Netto"  # a707->"BAG.FM.Gewicht.Netto";
    v707->"BAG.FM.Lagerplatz"     # a707->"BAG.FM.Lagerplatz";
    v707->"BAG.FM.Bemerkung"      # a707->"BAG.FM.Bemerkung";
    v707->"BAG.FM.Verwiegungart"  # a707->"BAG.FM.Verwiegungart";
    v707->"BAG.FM.Stück"          # a707->"BAG.FM.Stück";
    v280->"Pak.Umverpackung"      # a280->"Pak.Umverpackung";
    vInputListe                   # aInputListe;
  end;
 
  
  if (WebApp_BagFertigmeldungPaketieren(v707, v280, vInputListe) = false) then
    Lib_Error:OutputToText(var vErg);

  RecBufDestroy(v707);

  RETURN vErg;
end;




/*=========================================================================
 sub BagArbeitsschritteUpdate                                MR 28.06.2022

  Speichert die aktuell gesetzten Arbeitsschritte
=========================================================================*/
sub BagArbeitsschritteUpdate(
  aXmlPara            : handle;
  opt a706            : int;
  opt aArbeitsschritt : alpha(8096)): alpha
local begin
  vErg            : alpha(1000);
  v706            : int;
  vArbeitsschritt : alpha(8096);
end;
begin
  v706  # RecBufCreate(706);
  debugx(cnvai(BAG.AS.Nummer));
  debugx(cnvai(BAG.AS.Position))
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(Lib_Soa:getNode(aXmlPara,'BagNummer'),    var v706->"BAG.AS.Nummer");
    Lib_XML:GetValueI16(Lib_Soa:getNode(aXmlPara,'BagPosition'),  var v706->"BAG.AS.Position");
    Lib_XML:GetValue(Lib_Soa:getNode(aXmlPara,'Arbeitsschritte'),  var vArbeitsschritt);
  end
  else begin
    v706->"BAG.AS.Nummer"   # a706->"BAG.AS.Nummer";
    v706->"BAG.AS.Position" # a706->"BAG.AS.Position";
    vArbeitsschritt         # aArbeitsschritt;
  end
 
  
 if (WebApp_BagArbeitsschritteUpdate(v706, vArbeitsschritt) = false) then
    Lib_Error:OutputToText(var vErg);

  RecBufDestroy(v706);

  RETURN vErg;
end




//=========================================================================
// sub DruckEtikett(...)
//
//  Druckt ein Materialetikett
//=========================================================================
sub DruckEtikett(
  aXmlPara : handle;
  opt aMats : alpha(4000);
  opt aEtkNr : int;
  ): alpha
local begin
  vErg  : alpha(1000);
  vMats : alpha(4000);
  vEtk : int;
end;
begin

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValueI(    Lib_Soa:getNode(aXmlPara,'EtikettTyp'),  var vEtk);
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'Materialien'),var vMats);
  end else begin
    vMats # aMats;
    vEtk # aEtkNr;
  end;

  if (WebApp_DruckEtikett(vMats,vEtk) = false) then
    Lib_Error:OutputToText(var vErg);
 
  RETURN vErg;
end;



//=========================================================================
// sub RsoKal_UpdateTage(...)
//
//  Aktualiert die angegebenen Kalendertagtypen
//=========================================================================
sub RsoKal_UpdateTage(
  aXmlPara : handle;
  opt aTagTypen : alpha(4000);
  ): alpha
local begin
  vErg      : alpha(1000);
  vTagTypen : alpha(4000);
end;
begin

  // Daten extrahieren
  if (aXmlPara > 0) then begin
    Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara,'KalenderListe'),  var vTagTypen);
  end else begin
    vTagTypen # aTagTypen;
  end;

  if (WebApp_RsoKAl_UpdateTage(vTagtypen) = false) then
    Lib_Error:OutputToText(var vErg);
 
  RETURN vErg;
end;





//=========================================================================
//=========================================================================
//=========================================================================


//========================================================================
//  sub WebApp_SC_DB_Struktur() : logic
//  Erstellt die die Datenstrukturdatei und gibt diese über das übergeben
//  Memobjekt zurück
//========================================================================
sub WebApp_SC_DB_Struktur(var aResponseMemObj : handle;) : logic
local begin
  Erx     : int;
  vJsonCte : handle;
end
begin
  Log('WebApp_SC_DB_Struktur Start');

  vJsonCte # C16_DatenstrukturDif:DatastructureToJson();
  vJsonCte->JsonSave('', _JsonSaveDefault, aResponseMemObj, _CharsetUTF8);
  Lib_Json:CloseJSON(var vJsonCte);

  Log('WebApp_SC_DB_Struktur End');
  RETURN (ErrList = 0);
end;



//========================================================================
//  sub WebApp_SC_Settings() : logic
//  Erstellt eine Jsonstruktur mit Settings und gibt diese über das übergeben
//  Memobjekt zurück
//========================================================================
sub WebApp_SC_Settings(var aResponseMemObj : handle;) : logic
local begin
  Erx     : int;
  vJsonCte : handle;
end
begin
  Log('WebApp_SC_Settings Start');

  vJsonCte # Lib_Json:OpenJSON();
    
  Lib_Json:RecToJson(var vJsonCte , 903, 'Prg.Settings');
  vJsonCte->JsonSave('', _JsonSaveDefault, aResponseMemObj, _CharsetUTF8);
  Lib_Json:CloseJSON(var vJsonCte);

  Log('WebApp_SC_Settings End');
  RETURN (ErrList = 0);
end;


//========================================================================
//  sub WebApp_SC_Settings() : logic
//  Gibt Abteilung für User zurück temporäre Lösung
//========================================================================
sub WebApp_MatDelInfo(aMatNr : int;  var aReturnval : alpha;)  : logic;
local begin
  Erx : int;
end
begin

  Mat.Nummer # aMatNr;
  Erx # RecRead(200,1,0);

  aReturnVal # cnvad("Mat.Lösch.Datum") + '|' +  "Mat.Lösch.User";



end;



//========================================================================
//  sub WebApp_SC_Settings() : logic
//  Gibt Abteilung für User zurück temporäre Lösung
//========================================================================
sub WebApp_UserAbteilung(aUser  : alpha; var aReturnval : alpha) : logic;
local begin
  Erx           : int;
  vQ            : alpha;
  vSelName      : alpha;
  vSel          : int;
  
  vAbtNum       : int;
end
begin

  Log('Start')
  if(aUser <> '') then begin
    Usr.Username # aUser;
    
    Erx # RecRead(800,1,0);
    if (Erx <= _rMultikey) then begin
      if(Usr.Abteilung <> '') then begin
        vQ # '';
        
        Lib_Berechnungen:Int1AusAlpha(Usr.Abteilung ,var vAbtNum)
        if(vAbtNum = 0) then begin
          Lib_Sel:QAlpha(var vQ, 'Abt.Bezeichnung', '=', Usr.Abteilung );

          vSel # SelCreate(821, gKey);
          Erx # vSel->SelDefQuery('', vQ);
          if (Erx<>0) then Lib_Sel:QError(vSel);
          vSelName # Lib_Sel:SaveRun(var vSel, 0);
    
          FOR Erx # RecRead(821 ,vSel, _recFirst | _recLock)
          LOOP Erx # RecRead(821, vSel, _recNext | _recLock)
          WHILE (Erx <= _rLocked) DO BEGIN
          
            vAbtNum # Abt.Nummer;
          
          END
        end
        if(vAbtNum <> 0)then
          aReturnval # 'ok+'+cnvai(vAbtNum)+'|';
        else LogErr('Keine Abteilung gefunden.');
        
      end
      else LogErr('Keine Abteilung angegeben.');
    end
    else begin
      LogErr('User nicht gefunden');
    end
  end
  Log('Ende')
end


//========================================================================
//  sub WebApp_SC_Settings() : logic
//  Gibt Abteilung für User zurück temporäre Lösung
//========================================================================
sub WebApp_ChangePassword(aNewPassword  : alpha(128); var aReturnval : alpha) : logic;
local begin
  Erx           : int;
end
begin

  Log('Start Passwortänderung');
  Usr.Username # gUsername;
  Erx # RecRead(800,1,_RecLock);
  if(Erx > 0) then LogErr('User: ' + gUsername + ' konnte nicht gefunden werden. Erx: ' + cnvai(Erx));
  else begin
    Usr.Passwort # aNewPassword;
    Erx # RekReplace(800);
    if(Erx > 0) then LogErr('Passwort konnte nicht geändert werden. Erx: ' + cnvai(Erx));
    else Log('Passwort erfolgreich geändert');
  end
 
  Log('Ende');
end





//========================================================================
//  sub WebApp_LfsKreditlimit() : logic
//      Prüft das Kredlimit
//========================================================================
sub WebApp_AdrKreditlimit(aAdrNr : int; aZusatzwert : float ) : logic
local begin
  Erx     : int;
  vRet    : alpha(500);
  vKlim   : float;
end
begin
  Log('WebApp_AdrKreditlimit Start');


  if (RunAFX('WebApp.AdrKreditlimit',Aint(aAdrNr)+'|'+Anum(aZusatzwert,2)) <> 0) then begin
       Log('AFX raus');
       RETURN (ErrList = 0);
//    if (AfxRes = 1) then begin
//    Log('Alles Ok raus')
//      RETURN true;
//    end else begin
//      LogErr('Fehler in AFX');
//      RETURN false;
//    end;
  end;

  Log('WebApp_AdrKreditlimit mit Standardfunktionalität');

  // -------------------------------------------------------------------
  //   Argumentprüfung
  // -------------------------------------------------------------------
  Log('Argumenteprüfung...');

  // Adresse lesen
  Adr.Nummer# aAdrNr;
  Erx # RecRead(100,1,0);
  if (erx > _rMultikey) then begin
    LogErr('Adresse nicht gefunden');
    RETURN false;
  end;
  Log('Adresse gelesen: ' + Aint(Adr.Nummer) + ' ' + Adr.Stichwort);

  // ggf. geteiltes Kreditlimit?
  if (Adr.Kreditnummer <> Adr.Nummer) then begin
    Log('Kreditlimitadresse lesen...');

    Adr.Nummer # Adr.Kreditnummer;
    Erx # RecRead(100,1,0);
    if (Erx > _rMultikey) then begin
      LogErr('Adresse nicht gefunden');
      RETURN false;
    end;
    Log('KreditlimitAdresse gelesen: ' + Aint(Adr.Nummer) + ' ' + Adr.Stichwort);
  end;

  Log('Kreditlimitprüfung :  Typ = ' +  "Set.KLP.Auf-Anlage");

  if (Adr_K_Data:Kreditlimit(Adr.KundenNr,"Set.KLP.Auf-Anlage",y, var vKLim, 0, 0,true)=false) then begin
    Lib_Error:OutputToText(var vRet);
    Log('Kreditlimitprüfung sperrt : ' + vRet + ' vLimit:' + aNum(vKLim,2));
  end else begin
    Log('Kreditlimitprüfung ok...Restlimit:' +  aNum(vKLIM,2) + ' abzgl. ' + Anum(aZusatzwert,2));
    if (vKLim < aZusatzwert) then
      LogErr('Kreditlimt überschritten');
  end;

  Log('WebApp_LfsKreditlimit End');

  RETURN (ErrList = 0);
end;






//========================================================================
//  sub WebApp_WE_Werksnummer(aLieferantennr : int; aWerksnr : alpha; aLagerplatz : alpha)
//      Bucht einen Wareneingang über die Externe Werksnummer in
//========================================================================
sub WebApp_WE_QR_SWeP(
  aLieferantennr  : int;
  aLagerplatz     : alpha;
  aQrDaten        : alpha(1000);
  aTransportId    : alpha;
  ) : logic
local begin
  Erx       : int;
  vSweNr    : int;
  v621      : int;
  vErg      : logic;
  vCall     : alpha;
end;
begin

  // Lieferant lesen
  Adr.Lieferantennr # aLieferantennr;
  Erx # RecRead(100,3,0);
  if (Erx > _rMultikey) then begin
    Error(99,'Lieferant nicht gefunden')
    RETURN false;
  end;

  // Sammelwareneingang ermitteln
  if (Cus_Data:Read(100,RecInfo(100,_RecId),cSWeNr) <> _rOK) then begin
    Error(99,'Sammelwareneingangsnummer für den Lieferanten "'+Adr.Stichwort+'" kann nicht ermittelt werden');
    RETURN false;
  end;
  vSweNr # CnvIa(Cus.Inhalt);


  // QR Codepattern je nach Lieferant in Sammelwareneingang Parsen
  RecBufClear(621);

  // --------------------------------------------------
  if (Cus_Data:Read(100,RecInfo(100,_RecId),cCustProc) <> _rOK) then begin
    Error(99,'Customprozedur für den Lieferanten "'+Adr.Stichwort+'" ist nicht konfiguriert');
    RETURN false;
  end;

/*
  try begin
    // Versuchen Customheader
    ErrTryIgnore(_rlocked,_rNoRec);
    ErrTryCatch(_ErrNoProcInfo,y);
    ErrTryCatch(_ErrNoSub,y);
*/
    vCall # Cus.Inhalt + ':SWe_QrParser';
    vErg # Call(vCall,aQrDaten);
/*
  end;
  if (ErrGet() <> _rOK) then begin
    Error(99,'QR Code-Parser für den Lieferanten "'+Adr.Stichwort+'" konnte nicht gestartet werden');
    RETURN false;
  end;
*/
  if (vErg = false) then begin
    Error(99,'QR Code-Parser für den Lieferanten "'+Adr.Stichwort+'" konnte nicht verarbeitet werden');
    RETURN false;
  end;

  if (SWe.P.Werksnummer = '') then begin
    Error(99,'Werksnummer konnte nicht extrahiert werden.');
    RETURN false;
  end;
  v621 # RekSave(621); // Geparste Daten merken



  // -------------------------------------------------------
  // Material schon im Bestand?
  Mat.Werksnummer # v621->SWe.P.Werksnummer;
  FOR   Erx # RecRead(200,8,0);
  LOOP  Erx  # RecRead(200,8,_RecNext);
  WHILE Erx = _rMultikey AND (Mat.Werksnummer = v621->SWe.P.Werksnummer) DO BEGIN
    if (Mat.Lieferant = Adr.Lieferantennr) then begin
      // Material ist schon eingegangen, alles IO,
      Erx # _rOK;
      BREAK;
    end;
  END;
  if (Erx = _rOK) then
    RETURN true;

  // Material nicht in Material gefunden, dann in Sammelwareneingang suchen

  // -------------------------------------------------------
  // Sammelwareneingang schon vorhanden?
  SWe.P.Lieferantennr # Adr.Lieferantennr;
  SWe.P.Werksnummer   # v621->SWe.P.Werksnummer;
  FOR   Erx # RecRead(621,6,0);
  LOOP  Erx # RecRead(621,6,_RecNext);
  WHILE (Erx = _rMultikey) AND (SWe.P.Werksnummer =  v621->SWe.P.Werksnummer) DO BEGIN
    if (SWe.P.AvisYN) AND (SWe.P.EingangYN = false) AND ("SWe.P.Löschmarker" = '')  then begin
      Erx # _rOK;
      BREAK;
    end;
  END;
  if (Erx = _rOK) then begin
    // Sammelwareneingang gefunden, danb keinen neuen anlegen
    RETURN true;
  end;

  // -------------------------------------------------------
  // Keine Sammelwareneingangsposition gefunden, dann eine neue anlegen
  TRANSON;

  RecbufClear(621);
  RecBufCopy(v621,621);   // aus QR Code extrahierte Daten übernehmen
  SWE.P.Nummer # vSweNr;
  RekLink(620,621,1,0); // Kopfdaten lesen

  SWe.P.Lieferantennr   # SWe.Lieferant;
  SWe.P.Lageradresse    # Set.Mat.Lageradresse;
  SWe.P.Lageranschrift  # Set.Mat.Lageranschr;
  SWe.P.Anlage.User     # gUserName;
  SWe.P.AvisYN          # true;
  SWe.P.Anlage.Datum    # Today;
  SWe.P.Anlage.Zeit     # Now;
  SWe.P.Lagerplatz      # aLagerplatz;

  SWe.P.Intrastatnr     # aTransportId;

  REPEAT
    SWe.P.Position      # SWe.P.Position + 1;
    Erx # RekInsert(621,0,'MAN');
  UNTIl (erx=_rOK);

  TRANSOFF;

  // Alles IO, Sammelwareneingangs pos angelegt
  RETURN true;
end;


sub _MatAusFromObfTokens(aSeite : alpha; aObfTokens : alpha) : alpha
local begin
  Erx     : int;
  vRet    : alpha(1000);
  vTokCnt : int;
  vTok    : int;
end
begin
  aObfTokens # Lib_Strings:Strings_ReplaceEachToken(aObfTokens, ';|, /','|');
  vTokCnt # Lib_Strings:Strings_Count(aObfTokens,'|');
  FOR   vTok # 1
  LOOP  inc(vTok)
  WHILE vTok <= vTokCnt DO BEGIN
    // Oberfläche lesen
    RecBufClear(841);
    Obf.Nummer # CnvIa(Str_Token(aObfTokens,'|',vTok));
    Erx # RecRead(841,1,0);
    if (Erx <> _rOK) then
      CYCLE;

    // Obf Eintragen
    Mat.AF.Nummer       # Mat.Nummer;
    Mat.AF.Seite        # aSeite;
    Mat.AF.ObfNr        # Obf.Nummer;
    Mat.AF.Bezeichnung  # Obf.Bezeichnung.L1;
    "Mat.AF.Kürzel"     # "Obf.Kürzel";
    WHILE (RecRead(201,1,_rectest)<=_rLocked) do
      Mat.AF.lfdNr # Mat.AF.LfdNr + 1;

    RekInsert(201,0,'MAN');
  END;
  vRet # Obf_Data:BildeAFString(200,aSeite);
  if (aSeite = '1') AND (vRet<>"Mat.AusführungOben") then begin
    RunAFX('Obf.Changed','200|1');
    vRet # "Mat.AusführungOben";
  end;
  if (aSeite = '2') AND (vRet<>"Mat.AusführungUnten") then begin
    RunAFX('Obf.Changed','200|2');
    vRet # "Mat.AusführungUnten";
  end;

  RETURN vRet;
end;

//========================================================================
//  sub WebApp_WE_EinP_VSB
//    Bucht einen Wareneingang auf VSB
//    Analog zu "Ein_E_Mat_Main:RecSave"  Stand 04.07.2022
//========================================================================
sub WebApp_WE_EinP_VSB(aBuf200 : int; var aReturnval : alpha) : logic;
local begin
  Erx         : int;
  vAfxErg     : int;
  vNr         : int;
  vVsbDatum   : Date;
  v506_VsbEK  : int;
  vMitRes     : logic;
  vVsbMat     : int;
  v203        : int;
  vResAnz     : int;
  vDel        : logic;
  vI          : int;
  vProz       : float;
  vKillRest   : logic;
end
begin
  Log('WebApp_WE_EinP_VSB Start');

  // -------------------------------------------------------------------
  //   Argumentprüfung
  // -------------------------------------------------------------------
  Log('Bestellung lesen..."' + aBuf200->Mat.Bestellnummer + '"');
    
  RecBufClear(506);
  Ein.E.Nummer      # CnvIa( Str_Token(aBuf200->Mat.Bestellnummer, '/',1));
  Ein.E.Position    # CnvIa( Str_Token(aBuf200->Mat.Bestellnummer, '/',2));
  Ein.E.Eingangsnr  # CnvIa( Str_Token(aBuf200->Mat.Bestellnummer, '/',3));
  Erx # RecRead(506,1,0);
  vVsbDatum # Ein.E.VSB_Datum; //2023-02-21  MR 2202/104
  if (Erx > _rMultikey) then begin
    LogErr('VSB EK Eintrag nich gefunden');
    RETURN false;
  end;
  Log('VSB EK Eintrag gelesen');
   
  RekLink(501,506,1,0);   // Ein Pos  lesen
  RekLink(500,506,2,0);   // Ein Kopf Lesen
  
  v506_VsbEK  # RekSave(506); // Buffer für Zugriff auf Daten aus dem VSB EK Eintrag
  
  
  // -------------------------------------------------------------------
  //   Anlage WE Datensatz
  // -------------------------------------------------------------------
  
  // Vorbelegen....
  MatWareneingangMulti_Vorbelegung(aBuf200);

//  Ein.E.Materialnr      # 0;
//  Ein.E.VSByn           # n;
//  Ein.E.VSB_Datum       # 0.0.0;
//  Ein.E.EingangYN       # y;
//  Ein.E.Eingangsnr      # 0;
//  Ein.E.Eingang_Datum   # aBuf200->Mat.Eingangsdatum;
//  if (Ein.E.Eingang_Datum = 0.0.0) then
//    Ein.E.Eingang_Datum # today;
//
//  Ein.E.Lageradresse    # Set.eigeneAdressnr;
//  Ein.E.Lageranschrift  # aBuf200->Mat.Lageranschrift;
  


  // Daten Übernehmen
 
  MatWareneingangMulti_Uebernehmen(aBuf200);
 
//  Ein.E.Lagerplatz      # aBuf200->Mat.Lagerplatz;
//
//  if (aBuf200->Mat.Werksnummer <> '') then
//    Ein.E.Werksnummer     # aBuf200->Mat.Werksnummer;
//
//  if (aBuf200->Mat.Ringnummer <> '') then
//    Ein.E.Ringnummer      # aBuf200->Mat.Ringnummer;
//
//  if (aBuf200->Mat.Coilnummer <> '') then
//    Ein.E.Coilnummer      # aBuf200->Mat.Coilnummer;
//
//  if (aBuf200->Mat.Chargennummer <> '') then
//  Ein.E.Chargennummer   # aBuf200->Mat.Chargennummer;
//
//  if (aBuf200->Mat.Dicke <> 0.0) then
//    Ein.E.Dicke           # aBuf200->Mat.Dicke;
//
//  if (aBuf200->Mat.Breite <> 0.0) then
//    Ein.E.Breite          # aBuf200->Mat.Breite;
//
//  if (aBuf200->"Mat.Länge" <> 0.0) then
//    "Ein.E.Länge"         # aBuf200->"Mat.Länge";
//
//  Ein.E.Dicke.Von       # aBuf200->Mat.Dicke.Von;
//  Ein.E.Dicke.Bis       # aBuf200->Mat.Dicke.Bis;
//  Ein.E.Breite.Von      # aBuf200->Mat.Breite.Von;
//  Ein.E.Breite.Bis      # aBuf200->Mat.Breite.Bis;
//  "Ein.E.Länge.Von"     # aBuf200->"Mat.Länge.Von";
//  "Ein.E.Länge.Bis"     # aBuf200->"Mat.Länge.Bis";
//
//  "Ein.E.Stückzahl"     # aBuf200->Mat.Bestand.Stk;
//  Ein.E.Gewicht         # aBuf200->Mat.Bestand.Gew;
//  Ein.E.Gewicht.Netto   # aBuf200->Mat.Gewicht.Netto;
//  Ein.E.Gewicht.Brutto  # aBuf200->Mat.Gewicht.Brutto;
//  Ein.E.Verwiegungsart  # aBuf200->Mat.Verwiegungsart;
//  "Ein.E.Güte"          # aBuf200->"Mat.Güte";
//  "Ein.E.Gütenstufe"    # aBuf200->"Mat.Gütenstufe";
//  Ein.E.RID             # aBuf200->Mat.Rid;
//  Ein.E.RAD             # aBuf200->Mat.Rad;
//
//  if (aBuf200->Mat.Bemerkung1 <> '') then
//    Ein.E.Bemerkung       # aBuf200->Mat.Bemerkung1;
//
//  if (aBuf200->Mat.Bemerkung2 <> '') then
//    Ein.E.Lieferscheinnr  # aBuf200->Mat.Bemerkung2;
//
//  Ein.E.Warengruppe     # aBuf200->Mat.Warengruppe;
//
//  Ein.E.AusfOben        # Ein.P.AusfOben;         // Erstmal übernahme aus Bestellpos
//  Ein.E.AusfUnten       # Ein.P.AusfUnten;        // Erstmal übernahme aus Bestellpos
//
//  // Übernahme aus Posdaten und generierte Daten
//  Ein.E.Lieferantennr   #  Ein.P.Lieferantennr;
//
//  /* zu Klären
//  Ein.E.Ursprungsland   #
//  */
//
//  if ("Ein.E.Stückzahl" = 0) then
//    "Ein.E.Stückzahl"  # 1;
//
//  EDI_Analysen:_RecCalcEinE();   //
//
//  Ein.E.Anlage.User     # gUserName;
//  Ein.E.Anlage.Datum    # Today;
//  Ein.E.Anlage.Zeit     # Now;
//
//  Ein.E.MEH             # Ein.P.MEH;
//  Ein.E.Artikelnr       # Ein.P.Artikelnr;
//  Ein.E.Kommission      # Ein.P.Kommission;
//  "Ein.E.Währung"       # "Ein.Währung";
//  Ein.E.Intrastatnr     # Ein.P.Intrastatnr;
//
//  Ein.E.AbbindungL        # Ein.P.AbbindungL;
//  Ein.E.AbbindungQ        # Ein.P.AbbindungQ;
//  Ein.E.Zwischenlage      # Ein.P.Zwischenlage;
//  Ein.E.Unterlage         # Ein.P.Unterlage;
//  Ein.E.Umverpackung      # Ein.P.Umverpackung;
//  Ein.E.Wicklung          # Ein.P.Wicklung;
//  Ein.E.StehendYN         # Ein.P.StehendYN;
//  Ein.E.LiegendYN         # Ein.P.LiegendYN;
//  Ein.E.Nettoabzug        # Ein.P.Nettoabzug;
//  "Ein.E.Stapelhöhe"      # "Ein.P.Stapelhöhe";
//  "Ein.E.Stapelhöhenabz"  # "Ein.P.StapelhAbzug";
//  Ein.E.AusfOben          # Ein.P.AusfOben;
//  Ein.E.AusfUnten         # Ein.P.AusfUnten;
//
//
//  Ein.E.Nummer        # Ein.P.Nummer;
//  Ein.E.Anlage.User   # gUserName;
//
  // Ankerfunktion
  if (RunAFX('Ein.E.Mat.RecSave','')<>0) then begin
    Log('Nutze Anker Ein.E.Mat.RecSave');
    if (AfxRes=999) then RETURN true;
    if (AfxRes<>_rOk) then begin
      Log('Fehler AFX Ein.E.Mat.RecSave');
      RETURN False;
    end;
  end;
  

  TRANSON;

  REPEAT
    Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
    Ein.E.VSB_Datum # vVsbDatum;  //2023-02-21  MR 2202/104
    Erx # RekInsert(506,0,'JOB');
  UNTIL (Erx=_rOK);
  Log('WE Datensatz erstellt');
  
  
  FOR   Erx # RecLink(502,501,12,_RecFirst)
  LOOP  Erx # RecLink(502,501,12,_RecNext)
  WHILE Erx = _rOK DO  BEGIN
    RecBufClear(507);
    Ein.E.AF.Nummer       # Ein.AF.Nummer;
    Ein.E.AF.Position     # Ein.AF.Position;
    Ein.E.AF.Eingang      # Ein.E.Eingangsnr;
    Ein.E.AF.Seite        # Ein.AF.Seite;
    Ein.E.AF.lfdNr        # Ein.AF.lfdNr;
    Ein.E.AF.ObfNr        # Ein.AF.ObfNr;
    Ein.E.AF.Bezeichnung  # Ein.AF.Bezeichnung;
    Ein.E.AF.Zusatz       # Ein.AF.Zusatz;
    Ein.E.AF.Bemerkung    # Ein.AF.Bemerkung;
    "Ein.E.AF.Kürzel"     # "Ein.AF.Kürzel";
    
    Erx # RekInsert(507,_recUnlock,'AUTO');
  END;
  Log('Analyse kopiert');

 
  vVSBMat # v506_VsbEK->Ein.E.Materialnr;

  Log('...jetzt Gegenbuchung auf Mat ' + Aint(vVSBMat)+' ...');
    
  if (Ein_E_data:Gegenbuchung(Ein.E.Eingangsnr, v506_VsbEK->Ein.E.Eingangsnr , var vMitRes)=false) then begin
    Log('Fehler bei Gegenbuchung');
    
    // TRANSBRK schon in Sub
    RecBufDestroy(v506_VsbEK);
    RETURN false;
  end;

  RecBufDestroy(v506_VsbEK);

  // Aufräumenarbeiten
  TRANSOFF;

Log('WE verbucht...');


  // -------------------------------------------------------------------
  // bei Gegenbuchung evtl. Reservierungen (wenn Auf/Allgem. oder BA-Input) übernehmen
  if (vMitRes) then begin

Log('Reservierungen übernehmen...');

    // 30.05.2017 AH  : der neue WE hat dann schon Res. d.h. die bisherige mindern/löschen...
    if (AAr.Ein.E.ReservYN) and (Ein.P.Kommission<>'') then begin
      // bin auf VSB Karte
      Mat.Nummer # vVSBMat;
      Erx # RecLink(203,200,13,_RecFirst);  // Reservierungen loopen
      WHILE (Erx<=_rLocked) do begin
        if ("Mat.R.Trägernummer1"=0) then begin
          v203 # RekSave(203);
          RecRead(203,1,_RecLock);
          Mat.R.Gewicht     # Mat.Bestand.Gew
          "Mat.R.Stückzahl" # Mat.Bestand.Stk;
          Mat_Rsv_Data:Update();
          Log('Reservierungen aktualisiert...');
          RekRestore(v203);
          if (RecRead(203,1,0)<=_rLocked) then begin
            Erx # RecLink(203,200,13,_RecNext);
          end
          else begin
            Erx # RecLink(203,200,13,_RecFirst);
          end;
          CYCLE;
        end;
        Erx # RecLink(203,200,13,_RecNext);
      END;
    end
    else begin
    
    // bei Gegenbuchung evtl. Reservierungen übernehmen
    // 07.07.2017 AH: auf jeden Fall LÖSCHEN oder ÜBERNEHMEN
      // Sonderfall. EINE BA-Einsatz-Reservierung:
      if (RecLinkInfo(203,200,13,_RecCount)=1) then begin
        Erx # RecLink(203,200,13,_RecFirst);
        if (Erx<=_rLocked) then begin
          if (Mat_Rsv_Data:Takeover(Mat.R.Reservierungnr, Ein.E.Materialnr, "Mat.R.Stückzahl", Mat.R.Gewicht, 0.0)) then begin
            vResAnz # 1;
            vMitRes # false;
          end;
        end;
      end;
    end;
  end;
  

  // bei Gegenbuchung...
  if (vMitRes) then begin
    // ALLE Reservierungen übernehmen?
    // Bei MDE Import alle Reservierungen mit Übernehmen
    vMitRes # true;    //(Msg(506013,'',0,_WinDialogYesNo,1)=_winidyes);
    Mat.Nummer # vVSBMat;
    Erx # RecLink(203,200,13,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      // Alle AufRes löschen ODER ALLE wenn User sagt "KEINE Übernehmen"
      // 19.10.2018 AH: NICHT für c_Akt_BAInpup
      if (("Mat.R.Trägernummer1"<>0) and ("Mat.R.Trägertyp"<>c_Akt_BAInput)) or
        (vMitRes=false) then begin
        if (Mat_Rsv_Data:Entfernen()=false) then
          BREAK;
        Erx # RecLink(203,200,13,_RecFirst);
        CYCLE;
      end;
      inc(vResAnz);
//      if ("Mat.R.Trägernummer1"=0) then begin
      if (Mat_Rsv_Data:Takeover(Mat.R.Reservierungnr, Ein.E.Materialnr, "Mat.R.Stückzahl", Mat.R.Gewicht, 0.0)=false) then begin
        BREAK;
      end;
      Erx # RecLink(203,200,13,_RecFirst);
      CYCLE;
    END;
    Log('Reservierungen übernommen...');
  end;

  
  Erx # RecLink(200,506,8,_RecFirst);
  Log(cnvai(Mat.Nummer));
  aReturnVal # cnvai(Mat.Nummer);
  // Etikettendruck?
  if (Ein.E.EingangYN) and (Ein.E.Materialnr<>0) and (Set.Ein.WE.Etikett<>0) then begin
    Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen

    Log('Etikettendruck...für ' + Aint(Mat.Nummer));
    
    if (Set.Ein.WE.Etikett=999) then
      Mat_Etikett:Etikett(0,y,1)
    else
      Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1)
  end;


  // 19.10.2018 AH:
  if (vResAnz=1) then begin                   // wenn GENAU eine Res., könnte die zu BA gehören?
    Erx # RecLink(200,506,8,_RecFirst);       // Eingangsmaterial holen
    Erx # RecLink(203,200,13,_RecFirst);      // Res. holen
    if (Erx<=_rLocked) then begin
      if ("Mat.R.Trägertyp"=c_Akt_BAInput) then begin
        Log('BA Reservierung auflösen und übernehmen...');
    
        BAG.IO.Nummer # "Mat.R.TrägerNummer1";
        BAG.IO.ID     # "Mat.R.TrägerNummer2";
        Erx # RecRead(701,1,0);
        if (Erx<=_rLocked) then begin
          if (BAG.IO.Materialtyp=c_IO_Theo) then begin
            Erx # RecLink(700,701,1,_recFirst); // BA-Kopf holen
            Erx # RecLink(702,701,4,_recFirst); // nachPos holen
            Mat_Rsv_Data:Entfernen();
            BA1_IO_I_Data:TheorieWirdEcht(BAG.IO.ID, Mat.Nummer);
            Log('...in BA übernommen THEO->Echt');
                
          end   // Theo
          else if (BAG.IO.Materialtyp=c_IO_VSB) then begin
            Erx # RecLink(700,701,1,_recFirst); // BA-Kopf holen
            Erx # RecLink(702,701,4,_recFirst); // nachPos holen
            if (BAG.P.Aktion<>c_BAG_Fahr) then begin                // 12.04.2022 AH: FAHREN mit VSB hat EIGENE LOGIK !!! Proj. 2335/12
              v203 # RekSave(203);
              Mat_Rsv_Data:Entfernen();
              if (BA1_IO_I_Data:EchtWirdTheorie(BAG.IO.ID)) then begin
                RecBufDestroy(v203);
                Erx # RecLink(200,506,8,_RecFirst);       // Eingangsmaterial holen
                Log('...in BA übernommen VSB->Echt');
                if (BA1_IO_I_Data:TheorieWirdEcht(BAG.IO.ID, Mat.Nummer)) then begin
                end;
              end
              else begin  // konnte nicht Frei werden?
                RekRestore(v203);
                Mat_rsv_data:NeuAnlegen(Mat.R.Reservierungnr,'AUTO');
                Log('...keine Übernahme in BA');
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  Log('BA Einsatz abgeschlossen');
              
    
  RunAFX('Ein.E.Mat.RecSave.Post','');
      
      

  // 21.08.2012 AI
  // Rest als Ausfall? ...........................

  vDel        # y;
  vKillRest   # false;

// ST 2022-07-04    Dies bezieht sich alles auf den Modus NEU und benötigt teilweise Benuterinteraktion
/*
  if (Mode=c_ModeNew) and ($lb.GegenVSB->wpcustom='') and (Ein.p.FM.Rest>0.0) then begin
    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.VSB + Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge);
    if (vProz>="Set.Ein.WEDelEin%") then begin
      vKillRest # y;
      if (Set.Ein.WEDelEinAuto=2) then vKillRest # false;
      if (Set.Ein.WEDelEinAuto=1) then
        if (Msg(506018, anum(Ein.P.FM.Rest, Set.Stellen.Menge)+'|'+Ein.P.MEH.Wunsch,_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then begin
          vKillRest # n;
          vDel      # n;
        end;
    end
    else begin
      vDel # n;
      if (Set.Ein.WE.RstAsflYN) then
        if (Msg(506018, anum(Ein.P.FM.Rest, Set.Stellen.Menge)+'|'+Ein.P.MEH.Wunsch,_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
          vKillRest # y;
          vDel      # y;
        end;
    end;
  end;

  // 21.08.2012 AI
  if (vKillRest) then begin
    vBuf506 # RekSave(506);
    RecInit(n);
    Ein.E.AusfallYN     # y;
    Ein.E.Ausfall_Datum # today;
    Ein.E.EingangYN     # n;
    Ein.E.Eingang_Datum # 0.0.0;

    "Ein.E.Stückzahl"   # Ein.P.FM.Rest.Stk;
    if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
      Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
    end;
    if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
      Ein.E.Menge # Ein.E.Gewicht;
    end;

    if (StrCnv(Ein.E.MEH2,_Strupper)='STK') then begin
      Ein.E.Menge2 # cnvfi("Ein.E.Stückzahl");
    end;
    if (StrCnv(Ein.E.MEH2,_Strupper)='KG') then begin
      Ein.E.Menge2 # Ein.E.Gewicht;
    end;

    if (Ein.E.Gewicht.Brutto=0.0) then
      Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
    if (Ein.E.Gewicht.Netto=0.0) then
      Ein.E.Gewicht.Netto # Ein.E.Gewicht;

    // Ausführungen kopieren
    vNr               # Ein.E.Eingangsnr;
    Ein.E.Nummer      # myTmpNummer;
    Ein.E.Eingangsnr  # vlfd;
    WHILE (RecLink(507,506,13,_RecFirst)=_rOK) do begin
      RecRead(507,1,_RecLock);
      Ein.E.AF.Nummer  # Ein.P.Nummer;
      Ein.E.AF.Eingang # vNr;
      RekReplace(507,_recUnlock,'AUTO');
    END;
    Ein.E.Nummer      # Ein.P.Nummer;
    Ein.E.Eingangsnr  # vNr;


    Ein.E.Nummer        # Ein.P.Nummer;
    Ein.E.Anlage.User   # gUserName;
    vLfd                # Ein.E.Eingangsnr;
    REPEAT
      Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
      Ein.E.Anlage.Datum  # Today;
      Ein.E.Anlage.Zeit   # Now;
      Erx # RekInsert(gFile,0,'MAN');
    UNTIL (erx=_rOK);

    if (Ein_E_Data:Verbuchen(y)=false) then begin
      RekRestore(vBuf506);
      Error(506001,'');
      ErrorOutput;
      RETURN true;
    end;
    RekRestore(vBuf506);
  end;    // ... Rest als Ausfall



  // Pos Löschen?
  if (vDel) and (Mode=c_ModeNew) and ("Ein.P.Löschmarker"='') then begin
    vBuf506 # RekSave(506);
    Erx # RecLink(506,501,14,_recFirst);  // WE loopen
    WHILE (Erx<=_rLocked) and (vDel) do begin
      if (Ein.E.VSBYN) and ("Ein.E.Löschmarker"='') then begin
        vDel # n;
        BREAK;
      end;
      Erx # RecLink(506,501,14,_recNext);
    END;
    RekRestore(vBuf506);
  end;
*/

  Log('Bestellung löschen? vDel = ' + Aint(CnvIl(vDel)));

  // dürfte löschen?
  if (vDel) and (Set.Ein.NoDelWennRsv) then begin
    // 20.01.2021 AH: Wenn noch Res. vorhanden sind, dann NICHT löschen
    vI # 0;
    Erx # RecLink(200,501,13,_recFirst);  // Bestellkarte holen
    if (Erx<=_rLocked) then begin
      vI # RecLinkInfo(203,200,13,_RecCount);
    end;
    if (vI>0) then begin
      vDel # n;
      Log('Bestellung nicht löschen, noch Reservierung vorhanden');
    end;
  end;


  
  // dürfte löschen?
  if (vDel) then begin
    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge);
    vDel # (vProz>="Set.Ein.WEDelEin%");

    Log('Bestellung löschen bei  ' +ANum(vProz, 2)+ '% >= Laut Setting: ' + Anum("Set.Ein.WEDelEin%",2));
    
    // ...% erreicht?
    if (vDel) and (vKillRest=false) then
      if (Set.Ein.WEDelEinAuto=1) then
        vDel # true;

    // Position löschen? 23.02.2016 AH laut HB
    if (vDel) and ("Ein.P.Löschmarker"='') then begin
      if (Ein_P_Subs:ToggleLoeschmarker(n)) then begin
        Log('Löschmarker gesetzt!');
        if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
          Ein_Data:UpdateMaterial();
        end;
      end;
    end;
  end;

  Log('WebApp_WE_EinP_VSB End');
  RETURN false;
end;


//========================================================================
//
//  sub WebApp_WE_EinP                               Neu MR
//    Bucht einen Wareneingang ohne VSB
//========================================================================
sub WebApp_WE_EinP(aBuf200 : int; aEinMenge :alpha; var aReturnval : alpha) : logic;
local begin
  vAfxErg     : int;
  vNr         : int;
  Erx         : int;
  vVsbMat     : int;
  vI          : int;
  vProz       : float;
  vDel        : logic;
  vKillRest   : logic;
end
begin
   Log('WebApp_WE_EinP Start');

  // -------------------------------------------------------------------
  //   Argumentprüfung
  // -------------------------------------------------------------------
  Log('Bestellung lesen..."' + aBuf200->Mat.Bestellnummer + '"');
    
  RecBufClear(501);
  Ein.P.Nummer      # CnvIa( Str_Token(aBuf200->Mat.Bestellnummer, '/',1));
  Ein.P.Position    # CnvIa( Str_Token(aBuf200->Mat.Bestellnummer, '/',2));
  
  Erx # RecRead(501,1,0);
  if (Erx > _rMultikey) then begin
    LogErr('Bestellung nicht gefunden');
    RETURN false;
  end;
  vVSBMat # Ein.P.Materialnr;
  Log('Bestellung gelesen');
   
  /***
  Erx # RekLink(506,501,14,0);   // VSB Einträge wenn vorhanden lesen
  if(Erx <> 0) then
    Log('Keine VSB  Einträge gefunden');
***/
  RecBufClear(506); // neuer leerer Eintrag
  Ein.E.Nummer    # Ein.P.Nummer;
  Ein.E.Position  # Ein.P.Position;
  
  RekLink(500,501,3,0);   // Ein Kopf Lesen
  if(aEinMenge <> '') then
    Ein.E.Menge # cnvfa(aEinMenge, _FmtNumPoint);
  else Ein.E.Menge # aBuf200->Mat.Gewicht.Netto
    
   Log(cnvaf(Ein.E.Menge));
    debugx(cnvaf(Ein.E.Menge));
  // Vorbelegen....
  MatWareneingangMulti_Vorbelegung(aBuf200);
  if(Ein.P.MEH.Preis <> Ein.P.Meh) and
  (Ein.P.MEH.Preis <> 'Stk') and
  (Ein.P.MEH.Preis <> 'kg') and
  (Ein.P.MEH.Preis <> 't') then begin
    Ein.E.MEH2 # Ein.P.MEH.Preis;
  end
  
  
  
  
  
  // Daten Übernehmen
  MatWareneingangMulti_Uebernehmen(aBuf200);
  
  
  // Ankerfunktion
  if (RunAFX('Ein.E.Mat.RecSave','')<>0) then begin
    Log('Nutze Anker Ein.E.Mat.RecSave');
    if (AfxRes=999) then RETURN true;
    if (AfxRes<>_rOk) then begin
      Log('Fehler AFX Ein.E.Mat.RecSave');
      RETURN False;
    end;
  end;
 
  
  TRANSON;

  REPEAT
    Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
    Erx # RekInsert(506,0,'JOB');
  UNTIL (Erx=_rOK);
  Log('WE Datensatz erstellt');
  
  
  FOR   Erx # RecLink(502,501,12,_RecFirst)
  LOOP  Erx # RecLink(502,501,12,_RecNext)
  WHILE Erx = _rOK DO  BEGIN
    RecBufClear(507);
    Ein.E.AF.Nummer       # Ein.AF.Nummer;
    Ein.E.AF.Position     # Ein.AF.Position;
    Ein.E.AF.Eingang      # Ein.E.Eingangsnr;
    Ein.E.AF.Seite        # Ein.AF.Seite;
    Ein.E.AF.lfdNr        # Ein.AF.lfdNr;
    Ein.E.AF.ObfNr        # Ein.AF.ObfNr;
    Ein.E.AF.Bezeichnung  # Ein.AF.Bezeichnung;
    Ein.E.AF.Zusatz       # Ein.AF.Zusatz;
    Ein.E.AF.Bemerkung    # Ein.AF.Bemerkung;
    "Ein.E.AF.Kürzel"     # "Ein.AF.Kürzel";
    
    Erx # RekInsert(507,_recUnlock,'AUTO');
  END;
  Log('Analyse kopiert');

 
  

  //Log('Verbuchung auf Mat ' + Aint(vVSBMat)+' ...');
    
  //if (Ein_E_data:Gegenbuchung(Ein.E.Eingangsnr, v506_VsbEK->Ein.E.Eingangsnr , var vMitRes)=false) then begin
  //artikeltdaten ziehen wenn gefüllt
  if(Ein.E.Artikelnr <> '') then
    Erx # RecLink(250,506,5,_RecFirst);     // Artikel holen
  // neue Karte buchen...
  if (Ein_E_Data:Verbuchen(y,n)=false) then begin
    TRANSBRK;
    LogErr('Fehler bei Verbuchung');
    Return false;
  end;

  // Aufräumenarbeiten
    TRANSOFF;
//    LogErr('wäre Erfolgreich');
//    Return false;
  Log('WE verbucht...');
 
  
  Erx # RecLink(200,506,8,_RecFirst);
  Log(cnvai(Mat.Nummer));
  // Etikettendruck?
  if (Ein.E.EingangYN) and (Ein.E.Materialnr<>0) and (Set.Ein.WE.Etikett<>0) then begin
    Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
   

    Log('Etikettendruck...für ' + Aint(Mat.Nummer));
    
    if (Set.Ein.WE.Etikett=999) then
      Mat_Etikett:Etikett(0,y,1)
    else
      Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1)
  end;
  
  Log('Etikettendruck abgeschlossen...');
  RunAFX('Ein.E.Mat.RecSave.Post','');
      
      

  // 21.08.2012 AI
  // Rest als Ausfall? ...........................

  vDel        # y;
  vKillRest   # false;
  
   Log('Bestellung löschen? vDel = ' + Aint(CnvIl(vDel)));

  // dürfte löschen?
  if (vDel) and (Set.Ein.NoDelWennRsv) then begin
    // 20.01.2021 AH: Wenn noch Res. vorhanden sind, dann NICHT löschen
    vI # 0;
    Erx # RecLink(200,501,13,_recFirst);  // Bestellkarte holen
    if (Erx<=_rLocked) then begin
      vI # RecLinkInfo(203,200,13,_RecCount);
    end;
    if (vI>0) then begin
      vDel # n;
      Log('Bestellung nicht löschen, noch Reservierung vorhanden');
    end;
  end;


  
  // dürfte löschen?
  if (vDel) then begin
    vProz # Lib_Berechnungen:Prozent(Ein.P.FM.Eingang + Ein.P.FM.Ausfall, Ein.P.Menge);
    vDel # (vProz>="Set.Ein.WEDelEin%");

    Log('Bestellung löschen bei  ' +ANum(vProz, 2)+ '% >= Laut Setting: ' + Anum("Set.Ein.WEDelEin%",2));
    
    // ...% erreicht?
    if (vDel) and (vKillRest=false) then
      if (Set.Ein.WEDelEinAuto=1) then
        vDel # true;

    // Position löschen? 23.02.2016 AH laut HB
    if (vDel) and ("Ein.P.Löschmarker"='') then begin
      if (Ein_P_Subs:ToggleLoeschmarker(n)) then begin
        Log('Löschmarker gesetzt!');
        if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
          Ein_Data:UpdateMaterial();
          aReturnVal # cnvai(Mat.Nummer)
        end;
      end;
    end;
  end;
  
  Log('WebApp_WE_EinP End');
end;





//========================================================================
//  sub WebApp_WE_Allgemein
//    Bucht einen allgemeinen Wareneingang
//========================================================================
sub WebApp_WE_Allgemein(aBuf200 : int; var aReturnval : alpha) : logic
local begin
  Erx     : int;
  vAfxErg : int;
  vNr     : int;
end
begin
  Log('WebApp_WE_Allgemein Start');

  // -------------------------------------------------------------------
  //   Buchung
  // -------------------------------------------------------------------
  Log('Buchung...Init...');

  // -------------------------------------------------------------------
  // Init
  RecBufclear(200);
  RecBufCopy(aBuf200,200);

  Mat.Nummer          # myTmpNummer;
  Mat.Status          # c_Status_EKgesperrtBetrieb;
  Mat.Lageradresse    # Set.eigeneAdressnr;
  Mat.MEH             # 'kg';
  RunAFX('Mat.WE.RecInit','');

  // -------------------------------------------------------------------
  // Belegung
  Log('Buchung...Belegung');

  if (Mat.Eingangsdatum=0.0.0) then
    Mat.Eingangsdatum # today;


  // Ausführungen anlegen
  "Mat.AusführungOben"  # _MatAusFromObfTokens('1',"Mat.AusführungOben");
  "Mat.AusführungUnten" # _MatAusFromObfTokens('2',"Mat.AusführungUnten");


  // -------------------------------------------------------------------
  // Pflichtfelder
  Log('Buchung...Pflichtfelder');
  vAfxErg # RunAFX('Mat.WE.RecSave','');
  if (vAfxErg<0) then begin
    if (AfxRes<>_rOK) then begin
      LogErr('Pflichtfeldfehler AFX');
      RETURN false;
    end;
  end
  else begin
    If (Mat.Bestand.Stk=0) then begin
      Error(001200,Translate('Stückzahl'));
      RETURN false;
    end;
    If (Mat.Gewicht.Brutto=0.0) or (Mat.Gewicht.Netto=0.0) then begin
      Error(001200,Translate('Gewicht'));
      RETURN false;
    end;
  end;


  //-------------------------------------------------------------------
  // Speichern
  Log('Buchung...Speichern');

  // Nummernvergabe
  Erx # Lib_SOA:ReadNummer('Material', var vNr); //[+] 07.07.2022 MR Deadlockfix
  if(Erx<>_rOk) then begin
    LogErr('Materialnummer konnte nicht gelesen werden');
    RETURN false;
  end;
  if (vNr<>0) then Lib_SOA:SaveNummer()
  else begin
    LogErr('Materialnummer konnte nicht generiert werden');
    RETURN false;
  end;

  TRANSON;

  // Ausführungen kopieren
  WHILE (RecLink(201,200,11,_RecFirst)=_rOk) do begin
    RecRead(201,1,_recLock);
    Mat.AF.Nummer # vNr;
    Erx # RekReplace(201,_recUnlock,'MAN');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN false;
    end;
  END;

  Mat.Nummer    # vNr;
  Mat.Ursprung  # vNr;

  if (Mat.EigenmaterialYN) then
    "Mat.Übernahmedatum" # Mat.Eingangsdatum;

  Mat_Data:SetStatus(c_Status_EKgesperrtBetrieb);

  Erx # Mat_Data:Insert(_RecUnlock,'MAN', Mat.Eingangsdatum);
  if (Erx<>_rOk) then begin
    TRANSBRK;
    LogErr('Material nicht speicherbar');
    RETURN False;
  end;
  TRANSOFF;


  RunAFX('Mat.RecSave.Post','');
  Log('Buchung...OK');


  Log('Etikettendruck...');
  if (Set.Ein.WE.Etikett<>0) then begin
    Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1);
    Log('Etikettendruck...Initiert');
  end else
    Log('Etikettendruck...nein');

  Log('AFX Mat.WE.RecSave.Post...');
  if (RunAFX('Mat.WE.RecSave.Post','')<0) then begin
    if (AfxRes<>_rOK) then begin
      Log('AFX Mat.WE.RecSave.Post Erg <> _rOK');
      RETURN false;
    end;
  end;
  Log('AFX Mat.WE.RecSave.Post...ok');
  
  aReturnval # Aint(Mat.Nummer);
  Log('aReturnval  =  ' + aReturnval);
 // aReturnval # '';//Aint(Mat.Nummer);
  

  Log('WebApp_WE_Allgemein Ende');
end;




//========================================================================
//  sub WebApp_WE...
//    Bucht einen Wareneingang über die externe Werksnummer in
//    Sammelwareneingängen
//========================================================================
sub WebApp_WE(aBuf200 : int; bestellID : alpha; var aReturnVal : alpha) : logic
local begin
  Erx     : int;
  v621    : int;
  vSweNr  : int;
  vFound  : logic;
end
begin

  Log('WepApp_WE Start');
  // Lieferant lesen
  Adr.Lieferantennr # aBuf200->Mat.Lieferant;
  Erx # RecRead(100,3,0);
  if (Erx > _rMultikey) then begin
    Error(99,'Lieferant nicht gefunden')
    RETURN false;
  end;

  Log('Lieferant gelesen: ' + Aint(Adr.Lieferantennr) + ' ' + Adr.Stichwort);


  // -------------------------------------------------------
  // Material schon im Bestand?
  vFound # false;
  Mat.Werksnummer # aBuf200->Mat.Werksnummer;

  Log('Suche Werksnummer "'+ Mat.Werksnummer +'" Material im Bestand von Lieferant ' + Aint(Adr.Lieferantennr));
  FOR   Erx # RecRead(200,8,0);
  LOOP  Erx # RecRead(200,8,_RecNext);
  WHILE (Erx <= _rMultikey) AND (Mat.Werksnummer = aBuf200->Mat.Werksnummer) DO BEGIN
    Log(' Material: ' + Aint(Mat.Nummer) + '  Mat.Werksnummer= ' + Mat.Werksnummer  + '   Mat.Lieferant = ' + Aint(Mat.Lieferant) + '   Mat.Löschmarker=' + "Mat.Löschmarker");
    if (Mat.Lieferant = Adr.Lieferantennr) AND ("Mat.Löschmarker" = '') then begin
      // Material ist schon eingegangen, alles IO
      Log('  -> Material gefunden');
      vFound # true;
      BREAK;
    end;
  END;
  // Material im Bestand gefunden -> Kein Wareneingang notwendig
  if (vFound) then begin
    LogErr('Material schon vorhanden');
    RETURN false;
  end;

//  // Sammelwareneingang ermitteln
//  if (Cus_Data:Read(100,RecInfo(100,_RecId),cSWeNr) <> _rOK) then begin
//    LogErr('Sammelwareneingangsnummer für den Lieferanten "'+Adr.Stichwort+'" kann nicht ermittelt werden');
//    RETURN false;
//  end;
    vSweNr # CnvIa(Str_Token(bestellId,'/',1));

  
  Log('-----------------------------------------------------------------------');
  Log(' Sammelwareneingang für ' +  Adr.Stichwort + ' = ' + Aint(vSweNr));

  // -------------------------------------------------------
  // Sammelwareneingang schon vorhanden?
  SWe.P.Lieferantennr # Adr.Lieferantennr;
  SWe.P.Werksnummer   # aBuf200->Mat.Werksnummer;
  vFound # false;
  FOR   Erx # RecRead(621,6,0);
  LOOP  Erx # RecRead(621,6,_RecNext);
  WHILE (Erx <= _rMultikey) AND (SWe.P.Werksnummer =  aBuf200->Mat.Werksnummer) DO BEGIN
    RekLink(620,621,1,0); // Kopfdaten lesen
    if (SWe.P.AvisYN) AND (SWe.P.EingangYN = false) AND ("SWe.P.Löschmarker" = '') AND ("SWe.Löschmarker" = '') then begin
      Log(' Sammelwareneingang gefunden ' + Aint(Swe.P.Nummer)+ '/' + Aint(Swe.P.Position));
      vFound  # true;
      BREAK;
    end;
  END;
  
  if(vFound = false ) then begin
    LogErr('Sammelwareneingang nicht gefunden ' + Aint(Swe.P.Nummer)+ '/' + Aint(Swe.P.Position));
    RETURN false;
  end
  
  
//  if (vFound = false) then begin
//
//    Log(' kein Sammelwareneingangavis gefunden, jetzt neu anlegen');
//
//    // Kein passenden Sammelwareneingang gefunden, jetzt Position anlegen
//    TRANSON;
//
//    RecbufClear(621);
//    SWE.P.Nummer        # vSweNr;
//    SWe.P.Eingangsnr    # 1;
//
//    RekLink(620,621,1,0); // Kopfdaten lesen
//
//    SWe.P.Lieferantennr   # SWe.Lieferant;
//    SWe.P.Lageradresse    # Set.Mat.Lageradresse;
//    SWe.P.Lageranschrift  # Set.Mat.Lageranschr;
//    SWe.P.Anlage.User     # gUserName;
//    SWe.P.AvisYN          # true;
//    SWe.P.Anlage.Datum    # Today;
//    SWe.P.Anlage.Zeit     # Now;
//
//    SWe.P.Lagerplatz      # aBuf200->Mat.Lagerplatz;
//    SWe.P.Intrastatnr     # aBuf200->Mat.Intrastatnr;
//
//    SWe.P.Werksnummer     # aBuf200->Mat.Werksnummer;
//    SWe.P.Ringnummer      # aBuf200->Mat.Ringnummer;
//    SWe.P.Chargennummer   # aBuf200->Mat.Chargennummer;
//    SWe.P.Coilnummer      # aBuf200->Mat.Coilnummer;
//
//    SWe.P.Dicke           # aBuf200->Mat.Dicke;
//    SWe.P.Breite          # aBuf200->Mat.Breite;
//   "SWe.P.Länge"          # aBuf200->"Mat.Länge";
//
//    SWe.P.Gewicht         # aBuf200->Mat.Bestand.Gew;
//    SWe.P.Menge           # aBuf200->Mat.Bestand.Gew;
//    SWe.P.Gewicht.Netto   # aBuf200->Mat.Bestand.Gew;
//    SWe.P.Gewicht.Brutto  # aBuf200->Mat.Bestand.Gew;
//
//    SWe.P.MEH             # 'kg';
//    "SWe.P.Stückzahl"     # aBuf200->Mat.Bestand.Stk;
//    "SWe.P.Güte"          # aBuf200->"Mat.Güte";
//    SWe.P.Rid             # aBuf200->Mat.Rid;
//    SWe.P.Rad             # aBuf200->Mat.Rad;
//    SWe.P.Warengruppe     # aBuf200->Mat.Warengruppe;
//    SWe.P.Bemerkung       # aBuf200->Mat.Bemerkung1;
//
//    Log('GÜTE| "SWe.P.Güte" ' +"SWe.P.Güte" + ' aBuf200->"Mat.Güte"; '  +  aBuf200->"Mat.Güte")
//
//    if (Swe.P.Warengruppe = 0) then
//      SWe.P.Warengruppe   # 100;
//
//    // ...
//    // hier die weiteren Daten aus dem Materialpuffer übernehmen
//    ///
//
//    if ("SWe.P.Stückzahl" = 0) then begin
//      TRANSBRK;
//      LogErr('Stückzahl muss angegeben werden');
//      RETURN false;
//    end;
//
//
//    REPEAT
//      SWe.P.Position      # SWe.P.Position + 1;
//      Erx # RekInsert(621,0,'MAN');
//    UNTIl (erx=_rOK);
//
//    TRANSOFF;
//
//    Log(' Sammelwareneingang Avis ' + Aint(SWE.P.Nummer) + '/' + Aint(Swe.P.Position) + ' angelegt');
//
//  end;


  Log('-----------------------------------------------------------------------');
  Log(' Suche Sammelwareneingangs Avis ');

  // SWE Pos ist auf jedenfall da, dann Eingang buchen
  SWe.P.Lieferantennr # Adr.Lieferantennr;
  SWe.P.Werksnummer   # aBuf200->Mat.Werksnummer;
  Log(' SWe.P.Lieferantennr = ' + Aint(SWe.P.Lieferantennr));
  Log(' SWe.P.Werksnummer  = "' + SWe.P.Werksnummer + '"');

  vFound # false;
  FOR   Erx # RecRead(621,6,0);
  LOOP  Erx # RecRead(621,6,_RecNext);
  WHILE (Erx <= _rMultikey) AND (SWe.P.Werksnummer = aBuf200->Mat.Werksnummer) DO BEGIN
    Log(' Prüfe Sammelwareneingang ' + Aint(SWE.P.Nummer) + '/' + Aint(Swe.P.Position) + ' :');
    if (SWe.P.AvisYN) AND (SWe.P.EingangYN = false) AND ("SWe.P.Löschmarker" = '')  then begin
      Log(' GEFUNDEN!!!');
      vFound # true;
      BREAK;
    end;
  END;
  if (vFound = false) then begin
    Log('Keine Lieferavisierung gefunden');
    // Keine Sammelwareneingangsposition gefunden
    Error(99,'Keine Lieferavisierung gefunden');
    RETURN false;
  end;


  Log('-----------------------------------------------------------------------');
  Log(' Verbuche Sammelwareneingang Avis ' + Aint(SWE.P.Nummer) + '/' + Aint(Swe.P.Position));

  TRANSON;

  FOR   Erx # RecRead(621,6,0);
  LOOP  Erx # RecRead(621,6,_RecNext);
  WHILE (Erx <= _rMultikey) AND (SWe.P.Werksnummer = aBuf200->Mat.Werksnummer) DO BEGIN

    Log(' Suche Alle SWeP s für Wersknummer =  '+ aBuf200->Mat.Werksnummer + '  Swep: ' + Aint(SWE.P.Nummer) + '/' + Aint(Swe.P.Position) + ' :');
    RekLink(620,621,1,0); // Kopfdaten lesen

    if (SWe.P.AvisYN) AND (SWe.P.EingangYN = false) AND ("SWe.P.Löschmarker" = '') AND ("SWe.Löschmarker" = '')  then begin
      v621 # RekSave(621);

      Log('  GEFUNDEN Sammelwareneingang ' + Aint(SWE.P.Nummer) + '/' + Aint(Swe.P.Position) + ' :');

      Log('Aktualisiere LieferID und Lagerplatz');
      Erx # RecRead(621,1,_RecLock);
      If (Erx <> _rOK) then begin
        Log('Avis konnte nicht aktualisiert werden. Erg = ' + Aint(Erx));
        Error(99,'Avis konnte nicht aktualisiert werden');
        RETURN false;
      end;

      SWe.P.Lagerplatz      # aBuf200->Mat.Lagerplatz;
      SWe.P.Intrastatnr     # aBuf200->Mat.Intrastatnr;
      SWe.P.Eingang_Datum   # today;
      
     
      
      Erx # RekReplace(621,_RecUnlock,'MAN');
      If (Erx <> _rOK) then begin
        Log('Avis konnte nicht aktualisiert werden. Erg = ' + Aint(Erx));
        Error(99,'Avis konnte nicht aktualisiert werden');
        RETURN false;
      end;

       
      // ----------------------------------------------------
      // Eingang auf Sammelwareneingangavis buchen
      RekLink(620,621,1,0); // Kopfdaten lesen
      SWe.P.Anlage.User     # gUserName;
      SWe.P.AvisYN          # false;
      SWe.P.EingangYN       # true;
      SWe.P.Eingang_Datum   # today;
      SWe.P.Lieferantennr   # aBuf200->Mat.Lieferant;
      SWe.P.Lagerplatz      # aBuf200->Mat.Lagerplatz;
      SWe.P.Intrastatnr     # aBuf200->Mat.Intrastatnr;

      SWe.P.Werksnummer     # aBuf200->Mat.Werksnummer;
      SWe.P.Ringnummer      # aBuf200->Mat.Ringnummer;
      SWe.P.Chargennummer   # aBuf200->Mat.Chargennummer;
      SWe.P.Coilnummer      # aBuf200->Mat.Coilnummer;

      SWe.P.Dicke           # aBuf200->Mat.Dicke;
      SWe.P.Dicke.Von       # aBuf200->Mat.Dicke.Von;
      SWe.P.Dicke.Bis       # aBuf200->Mat.Dicke.Bis;
      SWe.P.Breite          # aBuf200->Mat.Breite;
      SWe.P.Breite.Bis      # aBuf200->Mat.Breite.Von;
      SWe.P.Breite.Von      # aBuf200->Mat.Breite.Bis;
     "SWe.P.Länge"          # aBuf200->"Mat.Länge";
     "SWe.P.Länge.Bis"      # aBuf200->"Mat.Länge.Bis";
     "SWe.P.Länge.Von"      # aBuf200->"Mat.Länge.Von";

      SWe.P.Gewicht         # aBuf200->Mat.Gewicht.Netto;
      SWe.P.Menge           # aBuf200->Mat.Gewicht.Netto; //Nicht ganz richtig
      SWe.P.Gewicht.Netto   # aBuf200->Mat.Gewicht.Netto;
      SWe.P.Gewicht.Brutto  # aBuf200->Mat.Gewicht.Brutto;
      SWe.P.Verwiegungsart  # aBuf200->Mat.Verwiegungsart;

      SWe.P.MEH             # 'kg';
      "SWe.P.Stückzahl"     # aBuf200->Mat.Bestand.Stk;
      "SWe.P.Güte"          # aBuf200->"Mat.Güte";
      "SWe.P.Gütenstufe"    # aBuf200->"Mat.Gütenstufe";
      SWe.P.Rid             # aBuf200->Mat.Rid;
      SWe.P.Rad             # aBuf200->Mat.Rad;
      SWe.P.Warengruppe     # aBuf200->Mat.Warengruppe;
      SWe.P.Bemerkung       # aBuf200->Mat.Bemerkung1;
      SWe.P.Lageranschrift  # aBuf200->Mat.Lageranschrift;
      SWe.P.AusfOben        # aBuf200->"Mat.AusführungOben"
      SWe.P.AusfUnten       # aBuf200->"Mat.AusführungUnten"
      SWe.P.Lieferscheinnr  # aBuf200->Mat.Bemerkung2;
      
       

      REPEAT
        SWe.P.Eingangsnr    # SWe.P.Eingangsnr + 1;
        SWe.P.Anlage.Datum  # Today;
        SWe.P.Anlage.Zeit   # Now;
        Erx # RekInsert(621,0,'MAN');
      UNTIl (erx=_rOK);



      //SWe.P.GesperrtYN      #
      
      

      Log('Eingang angelegt ' + Aint(SWE.P.Nummer) + '/' + Aint(Swe.P.Position) + '/' + Aint(SWe.P.Eingangsnr));

      if (SWe_P_Data:Verbuchen(y)=false) then begin
        TRANSBRK;
        Error(99,'Fehler beim Verbuchen!');
        RETURN false;
      end;

      Log('Eingang Verbucht ' + Aint(SWE.P.Nummer) + '/' + Aint(Swe.P.Position) + '/' + Aint(SWe.P.Eingangsnr) +' Matnr: ' + Aint(Swe.P.Materialnr));

      // Zusaätzliche Materialdaten nachtragen, die nicht Teil vom Sammelwareneingang sind
      if (aBuf200->Mat.Paketnr <> 0) then begin
        Log('Aktualisiere Paketnummer');

        Erx # Mat_Data:Read(Swe.P.Materialnr);
        Log('...Erg = ' + Aint(Erx));
        if (Erx <> 200) then begin
          TRANSBRK;
          Error(99,'Material ' + Aint(Swe.P.Materialnr) + ' konnte nicht zum lesen gesperrt werden!');
          RETURN false;
        end;
        Erx # Recread(200,1,_RecLock);
        if (Erx <> _rOK) then begin
          TRANSBRK;
          Error(99,'Material ' + Aint(Swe.P.Materialnr) + ' konnte nicht gesperrt werden!');
          RETURN false;
        end;
        
        
        Log('Paket Erweiterung ' + Aint(aBuf200->Mat.Paketnr));

        // ggf. Paket anlegen
        Mat.Paketnr # aBuf200->Mat.Paketnr;
        RecbufClear(280);
        Pak.Nummer # Mat.Paketnr;
        RekInsert(280);

        RekLink(281,280,1,_RecLast);
        Pak.P.Nummer   # Pak.Nummer;
        Pak.P.Position # Pak.P.Position + 1;
        Pak.P.Materialnr # Mat.Nummer;
        Erx # RekInsert(281);
        if (Erx <> _rOK) then begin
          Log('Paket '+Aint(Pak.Nummer)+' zu Material ' + Aint(Mat.nummer)+' konnte erweitert werden!');
          TRANSBRK;
          Error(99,'Paket '+Aint(Pak.Nummer)+' zu Material ' + Aint(Mat.nummer)+' konnte erweitert werden!');
          RETURN false;
        end;
        Log('Paket erweitert ' + Aint(aBuf200->Mat.Paketnr) );

        if (RekReplace(200,_RecUnlock) <> _rOK) then begin
          Log('Material ' + Aint(Mat.nummer)+' konnte gespeichert werden!');
          TRANSBRK;
          Error(99,'Material ' + Aint(Mat.nummer)+' konnte gespeichert werden!');
          RETURN false;
        end;
      end;
      Log('Material ' + Aint(Mat.Nummer) + ' aktualisiert');
      
      aReturnVal # cnvai(Mat.Nummer, _FmtNumNoGroup);
      RekRestore(v621);
    end; // Avis gefunden

  END;

  TRANSOFF;

  Log('WepApp_WE Ende');

end;




//========================================================================
//  sub WebApp_Umlagern_Werksnummer(aLieferantennr : int; aWerksnr : alpha; aLagerplatz : alpha)
//      Lagert die  angegebenenm MAerialien um
//========================================================================
sub WebApp_Umlagern(aLagerplatz : alpha;  aMats : alpha(4000);  ) : logic
local begin
  Erx       : int;
  i         : int;
  vMatToken : alpha;
  vMatCnt   : int;
  vMatDelim : alpha;
  vCnt      : int;
end
begin
  Log('WebApp_Umlagern Start');

  if (RunAFX('WebApp.Mat.Umlagern',aLagerplatz+'|'+aMats) <> 0) then begin
    if (AfxRes = 0) then begin
      RETURN true;
    end else begin
      LogErr('Fehler in AFX');
      RETURN false;
    end;
  end;

  Log('WebApp_Umlagern mit Standardfunktionalität');
  if (aLagerplatz = '') then begin
    LogErr('Lagerplatz nicht angegeben');
    RETURN false;
  end;
  Log('Lagerplatz: ' + aLagerplatz);
  Log('Materialien: ' + aMats);

  vMatDelim # ',';
  aMats     # Lib_Strings:Strings_ReplaceEachToken(aMats,'[]','');
  vMatCnt   # Lib_Strings:Strings_Count(aMats,vMatDelim) + 1;

  FOR i # 1
  LOOP inc(i)
  WHILE i <= vMatCnt DO BEGIN
    vMatToken #  Str_Token(aMats,vMatDelim,i);
    Log('... MatToken = ' + vMatToken);
    if (CnvIa(vMatToken) = 0) then
      CYCLE;

    // Material lesen
    Log('Material lesen...');
    Erx # Mat_Data:Read(CnvIa(vMatToken),_RecLock);
    if (Erx <> 200) then begin
      LogErr('Fehler beim Lesen des Materials('+vMatToken+'): Erg =' + Aint(Erx));
      CYCLE;
    end;

    // Speichern + Prokotoll
    PtD_Main:Memorize(200);
    Mat.Lagerplatz # aLagerplatz;
    Erx # Mat_data:Replace(_RecUnlock,'MAN');
    if (Erx <> _rOK) then begin
      PtD_Main:Forget(200);
      LogErr('Fehler beim Speichern des Materials('+vMatToken+'): Erg =' + Aint(Erx));
      CYCLE;
    end;
    PtD_Main:Compare(200);

    inc(vCnt);
  END;
  if (vCnt = 0) then
    LogErr('Keine Materialien verbucht');

  Log('WebApp_Umlagern Ende');
  RETURN (Errlist = 0);
end;



//========================================================================
//  sub WebApp_Umlagern_Lagerplatz(aLieferantennr : int; aWerksnr : alpha; aLagerplatz : alpha)
//      Lagert die  angegebenenm MAerialien um
//========================================================================
sub WebApp_Umlagern_Lagerplaetze(aLagerplatz_Von : alpha;  aLagerplatz_Nach : alpha;  ) : logic
local begin
  Erx       : int;
  i         : int;
  vMatToken : alpha;
  vMatCnt   : int;
  vMatDelim : alpha;
  vCnt      : int;
  vQ        : alpha;
  vSelName  : alpha;
  vSel      : int;
end
begin
  Log('WebApp_Umlagern Start');

  if (RunAFX('WebApp.Mat.UmlagernLagerplaetze',aLagerplatz_Von+'|'+aLagerplatz_Nach) <> 0) then begin
    if (AfxRes = 0) then begin
      RETURN true;
    end else begin
      LogErr('Fehler in AFX');
      RETURN false;
    end;
  end;

  Log('WebApp_Umlagern_Lagerplaetze mit Standardfunktionalität');
  if (aLagerplatz_Von = '' or aLagerplatz_Nach = '') then begin
    LogErr('Lagerplatz nicht angegeben');
    RETURN false;
  end;
  Log('Lagerplatz_Von: ' + aLagerplatz_Von);
  Log('Lagerplatz_Nach: ' + aLagerplatz_Nach);
  
 
  
   vQ # '';
  Lib_Sel:QAlpha(var vQ, 'LPl.Lagerplatz', '=', aLagerplatz_Nach);
  vSel # SelCreate(844, gKey);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

//  Mat.Lagerplatz # aLagerplatz_Von;
//  FOR Erx # RecRead(200,19,_recFirst | _recLock)
//  LOOP Erx # RecRead(200,19,_recNext | _recLock)
//  WHILE (Erx <= _rLocked) DO BEGIN
    
    FOR Erx # RecRead(844 ,vSel, _recFirst | _recLock)
    LOOP Erx # RecRead(844, vSel, _recNext | _recLock)
    WHILE (Erx <= _rLocked) DO BEGIN
       
       Log(Lpl.Lagerplatz);
      
     LPl.InLagerplatz # aLagerplatz_Von;
     
     Erx # RekReplace(844);
     if(Erx <> 0 ) then LogErr('Fehler beim Verbuchen der Lagereinheit.');
     
     break;

//    Log(gUserName);
//    // Speichern + Prokotoll
//    PtD_Main:Memorize(200);
//    Mat.Lagerplatz # aLagerplatz_Nach;
//    Erx # Mat_data:Replace(_RecUnlock,'MAN');
//    PtD_Main:Compare(200);
//    if (Erx <> _rOK) then begin
//      LogErr('Fehler beim Speichern des Materials('+cnvai(Mat.Nummer)+'): Erg =' + Aint(Erx));
//      CYCLE;
//    end;
//
//    inc(vCnt);
  END;
  
  
  
//  vQ # '';
//  Lib_Sel:QAlpha(var vQ, 'Mat.Lagerplatz', '=', aLagerplatz_Von);
//  vSel # SelCreate(200, gKey);
//  Erx # vSel->SelDefQuery('', vQ);
//  if (Erx<>0) then Lib_Sel:QError(vSel);
//  vSelName # Lib_Sel:SaveRun(var vSel, 0);
//
////  Mat.Lagerplatz # aLagerplatz_Von;
////  FOR Erx # RecRead(200,19,_recFirst | _recLock)
////  LOOP Erx # RecRead(200,19,_recNext | _recLock)
////  WHILE (Erx <= _rLocked) DO BEGIN
//
//    FOR Erx # RecRead(200 ,vSel, _recFirst | _recLock)
//    LOOP Erx # RecRead(200, vSel, _recNext | _recLock)
//    WHILE (Erx <= _rLocked) DO BEGIN
//
//    Log(gUserName);
//    // Speichern + Prokotoll
//    PtD_Main:Memorize(200);
//    Mat.Lagerplatz # aLagerplatz_Nach;
//    Erx # Mat_data:Replace(_RecUnlock,'MAN');
//    PtD_Main:Compare(200);
//    if (Erx <> _rOK) then begin
//      LogErr('Fehler beim Speichern des Materials('+cnvai(Mat.Nummer)+'): Erg =' + Aint(Erx));
//      CYCLE;
//    end;
//
//    inc(vCnt);
//  END;

  Log('WebApp_Umlagern Ende');
  RETURN (Errlist = 0);
end;


//========================================================================
//  sub WebApp_Umlagern_Materialnr(aMaterial  : int; aLagerplatz : alpha)
//      Lagert ein vorhandenes Material um
//========================================================================
sub WebApp_Umlagern_Materialnr(aMaterial  : int; aLagerplatz : alpha) : logic
local begin
  Erx : int;
end;
begin

  Erx # Mat_Data:Read(aMaterial);
  if (Erx <> 200) then begin
    LogErr('Material ' + Aint(aMaterial) + 'konnte nicht gelesen werden: Erg = '  + Aint(Erx) );
    RETURN false;
  end;

  TRANSON;

  // Nur Restkarten und Einsatzmaterialen erlauben
  if (Mat.Nummer <> Mat.Ursprung) AND ((Mat.Status < c_Status_BAG) OR  (Mat.Status >c_Status_bisBAG)) then begin
    TRANSBRK;
    LogErr('Material ' + Aint(Mat.Nummer) + ' hat nicht den richtigen Status: '  + Aint(Mat.Status) );
    RETURN false;
  end;

  Log('Starte Umlagerung ' + Aint(Mat.Nummer));

  Erx # RecRead(200,1, _RecLock);
  if (Erx <> _rOK) then begin
    TRANSBRK;
    LogErr('Material konnte nicht gesperrt werden');
    RETURN false;
  end;

  Mat.Lagerplatz # aLagerplatz;

  Erx # Mat_Data:Replace(_RecUnlock, 'MAN');
  If (Erx <> _rOK) then begin
    TRANSBRK;
    LogErr('Material konnte nicht gespeichert werden');
    RETURN false;
  end;

  Log('Umlagerung für Material ' + Aint(Mat.Nummer)+ ' erfolgt')

  if (Mat.Paketnr <> 0) then begin
    Log('Umlagerung für Material ' + Aint(Mat.Nummer)+ ' erfolgt -> auch in Paket ' + Aint(Mat.Paketnr));
    if (WebApp_Umlagern_Paketnr(Mat.Paketnr, aLagerplatz) = false) then begin
      TRANSBRK;
      LogErr('Material konnte nicht gespeichert werden');
      RETURN false;
    end;
  end;

  TRANSOFF;
  RETURN true;
end;



//========================================================================
//  sub WebApp_Umlagern_Paketnr(aPaketnr  : int; aLagerplatz : alpha) : logic
//      Lagert ein Paket um
//========================================================================
sub WebApp_Umlagern_Paketnr(aPaketnr  : int; aLagerplatz : alpha) : logic
local begin
  Erx : int;
end;
begin

  RecBufClear(280);
  Pak.Nummer # aPaketnr;
  Erx # RecRead(280,1,0)
  if (Erx <> _rOk) then begin
    LogErr('Paket ' + Aint(aPAketnr) + 'konnte nicht gelesen werden: Erg = '  + Aint(Erx) );
    RETURN false;
  end;

  if ("Pak.Löschmarker" = '*') then begin
    LogErr('Paket ' + Aint(aPAketnr) + ' ist schon gelöscht');
    RETURN false;
  end;

  if (Pak.Lagerplatz = aLagerplatz) then
    RETURN true;

  TRANSON;


  // ------------------------------------------------
  // Materialien aktualisieren

  Log('Starte Umlagerung ' + Aint(Pak.Nummer));
  FOR   Erx # RecLink(281,280,1,_RecFirst)
  LOOP  Erx # RecLink(281,280,1,_RecNext)
  WHILE Erx <= _rLocked DO BEGIN
    if (Pak.P.MaterialNr = 0) then
      CYCLE;

    Erx # Mat_Data:Read(Pak.P.MaterialNr);
    if (Erx <> 200) then begin
      TRANSBRK;
      LogErr('Paket ' + Aint(aPaketnr) + ':  Material ' + Aint(Pak.P.MaterialNr) + ' ist nicht im Bestand');
      RETURN false;
    end;

    if (Mat.Lagerplatz = aLagerplatz) then
      CYCLE;

    Erx # RecRead(200,1, _RecLock);
    if (Erx <> _rOK) then begin
      TRANSBRK;
      LogErr('Material konnte nicht gesperrt werden');
      RETURN false;
    end;

    Mat.Lagerplatz # aLagerplatz;

    Erx # Mat_Data:Replace(_RecUnlock, 'MAN');
    If (Erx <> _rOK) then begin
      TRANSBRK;
      LogErr('Material konnte nicht gespeichert werden');
      RETURN false;
    end;

    Log('Umlagerungen für Paket ' + Aint(Pak.Nummer)+ ' in Mat : ' + Aint(Mat.Nummer) + ' erfolgt')  ;
  END;

  // ------------------------------------------------
  // Paket aktualisieren
  Erx # RecRead(280,1,_RecLock);
  if (Erx <> _rOK) then begin
    TRANSBRK;
    LogErr('Paket konnte nicht gesperrt werden');
    RETURN false;
  end;

  Pak.Lagerplatz  # aLagerplatz;

  Erx # RekReplace(280);
  if (Erx <> _rOK) then begin
    TRANSBRK;
    LogErr('Paket konnte nicht aktualisiert werden');
    RETURN false;
  end;


  Log('Umlagerungen für Paket ' + Aint(Pak.Nummer)+ ' erfolgt')

  TRANSOFF;
  RETURN true;
end;


//========================================================================
//  sub WebApp_Umlagern_Werksnummer(aLieferantennr : int; aWerksnr : alpha; aLagerplatz : alpha)
//      Lagert ein Material vorhandenes Material um
//========================================================================
sub WebApp_Umlagern_Werksnummer(
  aLieferantennr  : int;
  aWerksnr        : alpha(1000);
  aLagerplatz     : alpha) : logic
local begin
  Erx     : int;
  vOK     : logic;
end
begin
  Log('WebApp_Umlagern_Werksnummer Start');

  // Lieferant lesen
  Adr.Lieferantennr # aLieferantennr;
  Erx # RecRead(100,3,0);
  if (Erx > _rMultikey) then begin
    Error(99,'Lieferant nicht gefunden')
    RETURN false;
  end;
  Log('Lieferant gelesen');

  aWerksnr # StrAdj(aWerksnr,_StrBegin | _StrEnd);
  aWerksnr # StrCnv(aWerksnr,_StrUpper);

  // Werksnummer für Lieferanten suchen
  Log('Werksnummer zur Umlagerung: ' + aWerksnr);

  Mat.Werksnummer # aWerksnr;
  vOK          # false;
  FOR   Erx # RecRead(200,8,0);
  LOOP  Erx # RecRead(200,8,_RecNext);
  WHILE Erx <= _rMultikey AND (Mat.Werksnummer = aWerksnr) DO BEGIN
    if (Mat.Lieferant = Adr.Lieferantennr) AND ("Mat.Löschmarker" = '') then begin
      vOK # true;
      Log('Mindestens ein Material gefunden ' + aint(Mat.Nummer));
      BREAK;
    end;
  END;

  // Material nicht in Material gefunden, dann in Sammelwareneingang suchen
  if (vOK = false) then begin
    Log('Kein Material gefunden');
    Error(99,'Material ist nicht im Bestand');
    RETURN false;
  end;

  //  ---------------------------------------------------------------------------------
  TRANSON;

  Mat.Werksnummer # aWerksnr;
  FOR   Erx # RecRead(200,8,0);
  LOOP  Erx # RecRead(200,8,_RecNext);
  WHILE (Erx <= _rMultikey) AND (Mat.Werksnummer = aWerksnr)  DO BEGIN
    if (Mat.Lieferant <> Adr.Lieferantennr) OR ("Mat.Löschmarker" = '*') then
      CYCLE;

    Log('Material zur Umlagerung gefunden: ' + Aint(Mat.Nummer));

    if (WebApp_Umlagern_Materialnr(Mat.Nummer, aLagerplatz) = false) then begin
      TRANSBRK;
      Log('Material konnte nicht umgelagert werden');
      Error(99,'Material konnte nicht umgelagert werden');
      RETURN false;
    end;

  END;

  TRANSOFF;

  Log('WebApp_Umlagern_Werksnummer Ende');

  // Alles IO
  RETURN true;
end;




//========================================================================
//  sub WebApp_MatSperren(aMatNrListe : alpha(8000); aGrund  : alpha; aEtkNr : int) : logic
//      Sperrt ein Material
//========================================================================
sub WebApp_MatSperren(aMatNrListe : alpha(8000); aGrund  : alpha; aEtkNr : int) : logic
local begin
  Erx       : int;
  vTokCnt   : int;
  vMatNr    : int;
  vTok      : int;
end
begin

  vTokCnt # Lib_Strings:Strings_Count(aMatNrListe,'|');
  log(aMatNrListe);
  log(cnvai(vTokCnt))
  FOR   vTok # 1
  LOOP  inc(vTok)
  WHILE vTok <= vTokCnt DO BEGIN
    
    vMatNr # cnvia(Str_Token(aMatNrListe,'|',vTok));
    
    PtD_Main:Memorize(200);
    Mat.Nummer # vMatNr;
    Erx # RecRead(200,1,_recLock);
    if(Erx > _rMultikey) then begin
      Log('Materialnr'+cnvai(vMatNr) +' konnte nicht gefunden werden');
      CYCLE ;
    end
    // Feldübernahme
    Mat.Status # 900;
    Erx # Mat_data:Replace(_RecUnlock,'MAN');
    PtD_Main:Compare(200);

    // Aktionen anlegen...
    RecBufClear(204);
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Aktionstyp    # c_Akt_Status;
    Mat.A.Aktionsnr     # 900;
    Mat.A.Aktionsdatum  # today;
    Mat.A.Bemerkung     # aGrund;
    Mat_A_Data:Insert(0,'AUTO');
    Log('Materialnr'+cnvai(Mat.Nummer) +' erfolgreich gesperrt.');
    
    if(aEtkNr = 0 ) then CYCLE;
    
    if (WebApp_DruckEtikett(Aint(Mat.Nummer),aEtkNr)) then
      Log('Neus Etikett drucken...ok');
    else
      LogErr('Fehler bei Etikettendruck ' + Aint(Mat.Nummer));
 
  END
  
  return true;
end;




//========================================================================
//  sub WebApp_MatSperren(aMatNrListe : alpha(8000); aGrund  : alpha; aEtkNr : int) : logic
//      Sperrt ein Material
//========================================================================
sub WebApp_MatSplitten(aMatNr : int; aGewBrutto : float; aGewNetto : float; aLaenge :float; aStk : int; aDatum : date; aPrintMatEtikYN : logic ) : logic
local begin
  Erx       : int;
  vTokCnt   : int;
  vMatNr    : int;
  vTok      : int;
  vTim      : time;
  vMenge    : float;
  vNr       : int;
end
begin

  log('Beginne Aufteilung');
  
  Mat.Nummer # aMatNr;
  Erx # RecRead(200,1,0);
  if(Erx>_rMultikey) then begin
    LogErr('Material ' + Aint(Mat.Nummer) + ' konnte nicht gefunden werden.');
    Return false;
  end;
 
 //Custom für Holzrichter
 if(aLaenge != 0.0) then "Mat.Länge" # aLaenge;
 
  
 
  Erx # RecLink(818,200,10,_recFirst);    // Verwiegungsart holen
//  if(Erx>=_rMultikey) then begin
//    LogErr('Verwiegungsart konnte nicht gefunden werden.' + cnvai(Erx));
//    Return false;
//  end;
  
  if (aDatum=today) then vTim # now;
  if (aStk<=0) or (aStk>Mat.Bestand.Stk) then RETURN false;
  if (((aGewNetto<=0.0) or (aGewNetto>Mat.Gewicht.Netto)) and (Mat.Gewicht.Netto > 0.0)) then begin
    LogErr('Nettogewicht ist überschritten');
    Return false;
  end
  if (((aGewBrutto<=0.0) or (aGewBrutto>Mat.Gewicht.Brutto)) and (Mat.Gewicht.Brutto > 0.0))then begin
     LogErr('Bruttogewicht ist überschritten');
    Return false;
  end
  
  vMenge # 0.0;
  if (Mat_Data:Splitten(aStk, aGewNetto, aGewBrutto, vMenge, aDatum, vTim, var vNr,'')=false) then begin
    LogErr('Aufteilung des Materials ist fehlgeschlagen');
    Return false
  end
  
  
  Log('Aufteilung war erfolgreich. Neues Material = ' + cnvai(vNr));
  
  
  
  
  LogErr(cnvai(vNr,_FmtNumNoGroup ) + '/ok');
  
  
  Log('Etikettendruck...');
  Mat.Nummer # vNr;
  Erx # RecRead(200,1,0);
   if(aPrintMatEtikYN) then begin
    Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1);
    Log('Etikettendruck...Initiert');
  end
  else Log('Druck wurde nicht gestartet, Druck wurde per Parameter deaktiviert.')
  

end



sub checkReservierungContainsTraeger () : logic
local begin
  vOk   : logic;
  Erx   : int;
end
begin

  if ("Mat.R.Trägertyp"='') then begin
    vOK # y;
  end
  else if ("Mat.R.TRägertyp"=c_Akt_BAInput) then begin
    vOK # y;
    BAG.IO.Nummer # "Mat.R.TrägerNummer1";
    BAG.IO.ID     # "Mat.R.TrägerNummer2";
    Erx # RecRead(701,1,0);
    if (Erx<=_rLocked) then begin
      Erx # RecLink(702,701,4,_recFirst);   // Nach-Pos holen
      if (Erx<=_rLocked) then begin
        if ("BAG.P.Löschmarker"='') then vOK # n;
      end;
    end;
  end;
  if (vOK=false) then begin
    LogErr('Reservierung besitzt eine Trägernummer.')
  end;


  return vOk

end




//========================================================================
//  sub WebApp_MatUmreservieren(aMatNrListe : alpha(8000); aGrund  : alpha; aEtkNr : int) : logic
//      Umreservierung eines Materials von einem Material auf eins oder mehrere andere
//
// MR  WIP Wenn Tests in orndung kommenteire ich das aus und vereifnache das ganze ...
//========================================================================
sub WebApp_MatUmreservieren(aMatNrListe : alpha(8000); aKommission : alpha(1000);)  : logic
local begin
  Erx           : int;
  vTok          : int;
  vTokCnt       : int;
  vMatNr        : int;
  vChargenNr    : alpha;
  vMatMenge     : float;
  vOldMatMenge  : float;
  vMatStueck    : int;
  vOldKundenNr  : int;
  vOldAufNr     : int;
  vOldAufPos    : int;
  vOldGew       : float;
  vRestMenge    : float;
  vOldStk       : int;
  vOldRsvNr     : int;
  vTmpStk       : int;
  vTmpGew       : float;
  vTmpMenge     : float;
  vVerfGewicht  : float;
  vVerfGewichtConst : float;
  
  vQ            : alpha;
  vSelName      : alpha;
  vSel          : int;
  vBuf203       : int;
  
  vTestMatNr    : int;
  vOK           : logic;
end
begin
  
   Log('Lade Materialdaten');
   
   
   vMatNr # cnvia(Str_Token(aMatNrListe,'|',1));
   vMatMenge # cnvfa(Str_Token(aMatNrListe,'|',2));
   vMatStueck # cnvia(Str_Token(aMatNrListe,'|',3));
   Mat.Nummer # vMatNr;
   
   vTmpStk # vMatStueck;
   vTmpMenge # vMatMenge;
  
   
   Erx # RecRead(200,1,0)
   if(Erx>_rMultikey) then begin
    LogErr('Ausgesuchtes Material' + cnvai(vMatNr) + ' konnte nicht gefunden werden,');
   end
   
   vChargenNr # Mat.Chargennummer
   vVerfGewicht # Mat.Bestand.Gew - Mat.Reserviert.Gew;
   vVerfGewichtConst # vVerfGewicht;
  
  
  if(vChargenNr <> '') then begin
    
    Log('Charge ist nicht leer, schauen ob es Material mit RsvTyp 2 gibt.')
    vQ # '';
    Lib_Sel:QAlpha(var vQ, 'Mat.R.Kommission', '=', aKommission);
    Lib_Sel:QInt(var vQ, 'Mat.R.Typ', '=', 2 );


    vSel # SelCreate(203, gKey);
    Erx # vSel->SelDefQuery('', vQ);
    if (Erx<>0) then Lib_Sel:QError(vSel);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);
    
     FOR Erx # RecRead(203 ,vSel, _recFirst | _recLock)
     LOOP Erx # RecRead(203, vSel, _recFirst | _recLock)
      WHILE (Erx <= _rLocked) DO BEGIN
        vRestMenge # vMatMenge;
        Log(cnvai(Mat.R.Materialnr));
        
       Log('Prüfe Chargennummer')
       if(Mat.Chargennummer <> vChargenNr) then CYCLE
              
                       
        if(checkReservierungContainsTraeger() = false) then CYCLE;
         
         
         vOK # true;
         
        vMatMenge # Mat.R.Menge - vMatMenge
        vMatStueck #  "Mat.R.Stückzahl" - vMatStueck;
       
       
        
        vOldKundenNr # Mat.R.Kundennummer;
        vOldAufNr #  Mat.R.Auftragsnr;
        vOldAufPos # Mat.R.Auftragspos;
        vOldMatMenge # Mat.R.Menge;
        vOldStk # "Mat.R.Stückzahl";
        vOldGew # Mat.R.Gewicht;
        vOldRsvNr # Mat.R.Reservierungnr;
          
        
        if(vMatMenge<=0.0) then begin
          Log('Reservierung löschen')
          if (Mat_Rsv_Data:Entfernen(true)=false) then begin
            Log('Reservierung ' + Aint(Mat.R.Reservierungnr) + ' wurde erfolgreich gelöscht.')
          end;
        end;
        else begin
        
          // Ankerfunktion
          RunAFX('Mat.Rsv.RecSave','EDIT');
           
           Mat.R.Menge # vMatMenge;
           Mat.R.Gewicht # (vOldGew/vOldMatMenge)*vMatMenge;
           "Mat.R.Stückzahl" # vMatStueck
           
          //if(vMatStueck > 0 ) then
            //"Mat.R.Stückzahl" #  "Mat.R.Stückzahl" - vMatStueck; //2023-08-21 MR nullt die Stückzahl
          if (vMatStueck <= 0) then "Mat.R.Stückzahl" # 1;
          else "Mat.R.Stückzahl" #  "Mat.R.Stückzahl";
          
          if (Mat_Rsv_Data:Update()=false) then begin
            LogErr('Fehler beim Update der Reservierungsdaten.');
            Return false;
          end;
          //PtD_Main:Compare(gFile);
          Lib_Workflow:Trigger(203, Mat.R.Workflow, _WOF_KTX_EDIT);
        end
      
        
        
        Log('Neue Reservierungen erstellen');
        Mat.Nummer # vMatNr;
        Erx # RecRead(200,1,0);
        if(Erx>_rMultikey) then begin
          LogErr('Material ' + Aint(Mat.Nummer) + ' konnte nicht gefunden werden.');
          //Return false;
        end;
       
       
        Mat.R.Kundennummer # vOldKundenNr;
        Mat.R.Auftragsnr # vOldAufNr;
        Mat.R.Auftragspos # vOldAufPos;
        if(vMatMenge<=0.0) then begin
          Mat.R.Menge # vTmpMenge;
          "Mat.R.Stückzahl" # vTmpStk;
        end
        else begin
          Mat.R.Menge # Mat.R.Menge - vMatMenge;
          
         if(vMatStueck > 0 ) then
            "Mat.R.Stückzahl" #  vOldStk- vMatStueck;
          else "Mat.R.Stückzahl" #  vOldStk;
        end
        
        Mat.R.Typ # 2;
        
        Mat.R.Workflow # 100;
        
       
        // Ankerfunktion
        RunAFX('Mat.Rsv.RecSave','NEW')

        Mat.R.Anlage.Datum  # Today;
        Mat.R.Anlage.Zeit   # Now;
        gUsername           # 'MDE';
        //if(vMatMenge<=0.0) then begin
          Mat.R.Menge # vTmpMenge;
          "Mat.R.Stückzahl" # vTmpStk;
        //end
        
        Mat.R.Gewicht # ((Mat.Bestand.Gew - Mat.Reserviert.Gew)/"Mat.Verfügbar.Menge")*"Mat.R.Menge";
        
        //(Mat.Bestand.Gew/Mat.Bestand.Menge) * Mat.R.Menge;
        
        Mat.R.Materialnr  # Mat.Nummer
        if (Mat_Rsv_Data:NeuAnlegen(0, 'MAN')=false) then begin
          LogErr('Fehler bei Neuanlegung der Reservierung.');
          //Return False;
        end;
        Lib_Workflow:Trigger(203, Mat.R.Workflow, _WOF_KTX_NEU);
        
        
        BREAK;
        if(vMatMenge < 0.0) then vMatMenge # vMatMenge * (-1.0);
        else begin
          vMatMenge # 0.0;
          BREAK;
        end
        
        if(vMatStueck < 0) then vMatStueck # vMatStueck * (-1);
        else BREAK;
       
        BREAK;
      END
//      FOR Erx # RecRead(203 ,vSel, _recFirst | _recLock)
//      LOOP Erx # RecRead(203, vSel, _recNext | _recLock)
//      WHILE (Erx <= _rLocked) DO BEGIN
//
//        vRestMenge # vMatMenge;
//        Log(cnvai(Mat.R.Materialnr));
//
//
//        Log('Lese Reservierung')
//        Mat.Nummer # Mat.R.Materialnr
//        Erx # RecRead(200,1,0);
//        if(Erx>_rMultikey) then begin
//          LogErr('Material ' + Aint(Mat.Nummer) + ' konnte nicht gefunden werden.');
//          Return false;
//        end;
//
//        Log('Prüfe Chargennummer')
//        if(Mat.Chargennummer <> vChargenNr) then CYCLE
//
//
//
//        if(checkReservierungContainsTraeger() = false) then CYCLE;
//
//        vMatMenge # Mat.R.Menge - vMatMenge;
//        vMatStueck # "Mat.R.Stückzahl" - vMatStueck;
//
//
//
//
//        vOldKundenNr # Mat.R.Kundennummer;
//        vOldAufNr #  Mat.R.Auftragsnr;
//        vOldAufPos # Mat.R.Auftragspos;
//        vOldMatMenge # Mat.R.Menge;
//        vOldStk # "Mat.R.Stückzahl";
//        vOldGew # Mat.R.Gewicht;
//
//
//
//
//
//        if(vMatMenge<=0.0 ) then begin
//          Log('Reservierung löschen')
//          if (Mat_Rsv_Data:Entfernen(true)=false) then begin
//            Log('Reservierung ' + Aint(Mat.R.Reservierungnr) + ' wurde erfolgreich gelöscht.')
//          end;
//        end;
//        else begin
//
//          // Ankerfunktion
//          RunAFX('Mat.Rsv.RecSave','EDIT');
//
//           Mat.R.Menge # vMatMenge;
//           if(vMatStueck > 0 ) then
//            "Mat.R.Stückzahl" #  "Mat.R.Stückzahl" - vMatStueck;
//          else if (vMatStueck <= 0) then "Mat.R.Stückzahl" # 1;
//          else "Mat.R.Stückzahl" #  "Mat.R.Stückzahl";
//
//
//          if (Mat_Rsv_Data:Update()=false) then begin
//            LogErr('Fehler beim Update der Reservierungsdaten.');
//            Return false;
//          end;
//          //PtD_Main:Compare(gFile);
//          Lib_Workflow:Trigger(203, Mat.R.Workflow, _WOF_KTX_EDIT);
//
//        end
//
//        Log('Neue Reservierungen erstellen');
//        Mat.Nummer # vMatNr;
//        Erx # RecRead(200,1,0);
//        if(Erx>_rMultikey) then begin
//          LogErr('Material ' + Aint(Mat.Nummer) + ' konnte nicht gefunden werden.');
//          //Return false;
//        end;
//
//
//        Mat.R.Kundennummer # vOldKundenNr;
//        Mat.R.Auftragsnr # vOldAufNr;
//        Mat.R.Auftragspos # vOldAufPos;
//        if(vMatMenge<=0.0) then begin
//          Mat.R.Menge # vOldMatMenge;
//          "Mat.R.Stückzahl" # vOldStk;
//
//          //Mat.R.Gewicht # ((Mat.Bestand.Gew - Mat.Reserviert.Gew)/(Mat.Bestand.Menge - Mat.Reserviert.Menge))* vOldGew
//
//
//
//          //Mat.R.Gewicht # vOldGew;
//        end
//        else begin
//          Mat.R.Menge # Mat.R.Menge - vMatMenge;
//
//
//          if(vMatStueck > 0 ) then
//            "Mat.R.Stückzahl" #  vOldStk- vMatStueck;
//          else "Mat.R.Stückzahl" #  vOldStk;
//        end
//        Mat.R.Typ # 2
//
//        Mat.R.Workflow # 100;
//
//
//        // Ankerfunktion
//        RunAFX('Mat.Rsv.RecSave','NEW')
//
//        Mat.R.Anlage.Datum  # Today;
//        Mat.R.Anlage.Zeit   # Now;
//        gUsername           # 'MDE';
//        if(vMatMenge <= 0.0) then
//          Mat.R.Menge # vOldMatMenge
//        else Mat.R.Menge # vRestMenge
//        Mat.R.Materialnr  # Mat.Nummer
//        if (Mat_Rsv_Data:NeuAnlegen(0, 'MAN')=false) then begin
//          LogErr('Fehler bei Neuanlegung der Reservierung.');
//          //Return False;
//        end;
//        Lib_Workflow:Trigger(203, Mat.R.Workflow, _WOF_KTX_NEU);
//
//
//        if(vMatMenge < 0.0) then vMatMenge # vMatMenge * (-1.0);
//        else BREAK;
//        if(vMatStueck < 0) then vMatStueck # vMatStueck * (-1);
//        else BREAK;
//
//      END
  end
  
  
  if(vMatMenge >0.0 and vOk= false) then begin
  
    vQ # '';
    Lib_Sel:QAlpha(var vQ, 'Mat.R.Kommission', '=', aKommission);
    Lib_Sel:QInt(var vQ, 'Mat.R.Typ', '<>', 3);


    vSel # SelCreate(203, gKey);
    Erx # vSel->SelDefQuery('', vQ);
    if (Erx<>0) then Lib_Sel:QError(vSel);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);
    
      FOR Erx # RecRead(203 ,vSel, _recFirst | _recLock)
      LOOP Erx # RecRead(203, vSel, _recNext | _recLock)
      WHILE (Erx <= _rLocked) DO BEGIN
        Log(cnvai(Mat.R.Materialnr));
      END
    
    
      FOR Erx # RecRead(203 ,vSel, _recFirst | _recLock)
      LOOP Erx # RecRead(203, vSel, _recFirst | _recLock)
      WHILE (Erx <= _rLocked) DO BEGIN
        vRestMenge # vMatMenge;
        Log(cnvai(Mat.R.Materialnr));
        
       
              
                       
        if(checkReservierungContainsTraeger() = false) then CYCLE;
              
        vMatMenge # Mat.R.Menge - vMatMenge
        vMatStueck #  "Mat.R.Stückzahl" - vMatStueck;
       
       
        
        vOldKundenNr # Mat.R.Kundennummer;
        vOldAufNr #  Mat.R.Auftragsnr;
        vOldAufPos # Mat.R.Auftragspos;
        vOldMatMenge # Mat.R.Menge;
        vOldStk # "Mat.R.Stückzahl";
        vOldGew # Mat.R.Gewicht;
        vOldRsvNr # Mat.R.Reservierungnr;
          
        
        if(vMatMenge<=0.0) then begin
          Log('Reservierung löschen')
          if (Mat_Rsv_Data:Entfernen(true)=false) then begin
            Log('Reservierung ' + Aint(Mat.R.Reservierungnr) + ' wurde erfolgreich gelöscht.')
          end;
        end;
        else begin
        
          // Ankerfunktion
          RunAFX('Mat.Rsv.RecSave','EDIT');
           
           Mat.R.Menge # vMatMenge;
           Mat.R.Gewicht # (vOldGew/vOldMatMenge)*vMatMenge;
           "Mat.R.Stückzahl" # vMatStueck
           
            
            
           
           
           
          //if(vMatStueck > 0 ) then
            "Mat.R.Stückzahl" #  vMatStueck;//2023-08-21 MR Nullt die Stückzahl
          if (vMatStueck <= 0) then "Mat.R.Stückzahl" # 1;
          else "Mat.R.Stückzahl" #  "Mat.R.Stückzahl";
          
          if (Mat_Rsv_Data:Update()=false) then begin
            LogErr('Fehler beim Update der Reservierungsdaten.');
            Return false;
          end;
          //PtD_Main:Compare(gFile);
          Lib_Workflow:Trigger(203, Mat.R.Workflow, _WOF_KTX_EDIT);
        end
      
        
        
        Log('Neue Reservierungen erstellen');
        Mat.Nummer # vMatNr;
        Erx # RecRead(200,1,0);
        if(Erx>_rMultikey) then begin
          LogErr('Material ' + Aint(Mat.Nummer) + ' konnte nicht gefunden werden.');
          //Return false;
        end;
       
       
        Mat.R.Kundennummer # vOldKundenNr;
        Mat.R.Auftragsnr # vOldAufNr;
        Mat.R.Auftragspos # vOldAufPos;
        if(vMatMenge<=0.0) then begin
          Mat.R.Menge # vTmpMenge;
          "Mat.R.Stückzahl" # vTmpStk;
        end
        else begin
          Mat.R.Menge # Mat.R.Menge - vMatMenge;
          
         if(vMatStueck > 0 ) then
            "Mat.R.Stückzahl" #  vOldStk- vMatStueck;
          else "Mat.R.Stückzahl" #  vOldStk;
        end
        
        Mat.R.Typ # 1;
        
        Mat.R.Workflow # 100;
        
       
        // Ankerfunktion
        RunAFX('Mat.Rsv.RecSave','NEW')

        Mat.R.Anlage.Datum  # Today;
        Mat.R.Anlage.Zeit   # Now;
        gUsername           # 'MDE';
        if(vMatMenge <= 0.0) then
          Mat.R.Menge # vTmpMenge
        else Mat.R.Menge # vRestMenge
        
        Mat.R.Gewicht # ((Mat.Bestand.Gew - Mat.Reserviert.Gew)/"Mat.Verfügbar.Menge")*"Mat.R.Menge";
        
        //(Mat.Bestand.Gew/Mat.Bestand.Menge) * Mat.R.Menge;
        
        Mat.R.Materialnr  # Mat.Nummer
        if (Mat_Rsv_Data:NeuAnlegen(0, 'MAN')=false) then begin
          LogErr('Fehler bei Neuanlegung der Reservierung.');
          //Return False;
        end;
        Lib_Workflow:Trigger(203, Mat.R.Workflow, _WOF_KTX_NEU);
        
        
        BREAK;
        if(vMatMenge < 0.0) then vMatMenge # vMatMenge * (-1.0);
        else BREAK;
        if(vMatStueck < 0) then vMatStueck # vMatStueck * (-1);
        else BREAK;
              
      END

  end
  

  Return true;
end





//========================================================================
//  sub _WebApp_LFS_VerbucheVldaw_DelLfsPos() : logic
//      Löscht eine Lieferscheinposition
//========================================================================
sub _WebApp_LFS_VerbucheVldaw_DelLfsPos() : logic
local begin
  Erx     : int;
  vPaket  : int;
  vErg    : int;
end
begin
  TRANSON;

  vPaket # Lfs.P.Paketnr;

  if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<100000000) then begin
    // bisherige VLDAW stornieren
    if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
      TRANSBRK;
      RETURN false;
    end;
  end;

  Erx # RekDelete(441,0,'MAN');
  if (erx<>_rOK) then begin
    TRANSBRK;
    ERROR(441000,AInt(Lfs.P.Position));
    RETURN false;
  end;

  // ggf. andere Positionen von diesem Paket löschen
  if (vPaket <> 0) then begin

    vErg # RecLink(441,440,4,_RecFirst);
    WHILE vErg = _rOK DO BEGIN

        if (Lfs.P.PaketNr <> vPaket) then begin
          vErg # RecLink(441,440,4,_RecNext);
          CYCLE;
        end;

      // bisherige VLDAW stornieren
      if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
        TRANSBRK;
        RETURN false;
      end;

      Erx # RekDelete(441,0,'MAN');
      if (erx<>_rOK) then begin
        TRANSBRK;
        ERROR(441000,AInt(Lfs.P.Position));
        RETURN false;
      end;

      vErg # RecLink(441,440,4,_RecFirst);
    END;     // LFS Loop
  end;

  TRANSOFF;
  RETURN true;
end;

//========================================================================
//  sub WebApp_LFS_VerbucheVldaw(aLfs : int; aMats : alpha(4000)) : logic;
//      Verbucht eine VLDAW zu einem Lieferschein
//========================================================================
sub WebApp_LFS_VerbucheVldaw(aLfs : int; aMats : alpha(4000);aVerbuchen : logic; aBuf440 : int ) : logic;
local begin
  Erx       : int;
  vLfs      : int;
  vAufNr    : int;
  vAufPos   : int;

  i         : int;
  vMatToken : alpha;
  vMatCnt   : int;
  vMatDelim : alpha;
  vLfsPos   : int;


  v400      : int;
  v401      : int;
  v440      : int;
  v441      : int;

  x : int;
end
begin
  Log('WebApp_LFS_VerbucheVldaw START');
//aFahrer+'|' +aSpediteur+ '|'+Aint(aSpediteurNr)+ '|'+aBemerkung+'|'+aReferenzNr+'|'+aKennzeichen+'|'
  if (RunAFX('WebApp.LFS.VerbucheVldaw',Aint(aLfs)+'|'+aMats+'|'+Aint(CnvIl(aVerbuchen)) + '|'+ cnvai(aBuf440)) <> 0) then begin
    if (AfxRes = 0) then begin
//      Log('AFX Aufruf OK');
      RETURN true;
    end else begin
//      Log('AFX Aufruf Nicht OK');
      Error(99,'Fehler in AFX');
      RETURN false;
    end;
  end;

  Log('WebApp_LFS_VerbucheVldaw mit Standardfunktionalität');


  if (aLfs = 0) then begin
    Log('Lieferscheinnummer nicht angegeben');
    Error(99,'VLDAW nicht angegeben');
    RETURN false;
  end;

  Lfs.Nummer # aLfs;
  if (RecRead(440,1,0) <> _rOK) then begin
    Log('Lieferscheinnummer "'+Aint(aLfs)+'" nicht lesbar');
    Error(99,'VLDAW nicht lesbar');
    RETURN false;
  end;

  // Wenn neue Materialnummern angegeben sind, dann wird der Lieferschein neu
  // aufgebaut, mit den Materialien die geliefert wurden
  if (aMats <> '') then begin
    Log('Lieferschein mit neuen Materialnummern:' + aMats);

    Log('Lösche alle Lieferscheinpositionen');
    // Alte Materialien dekommissionieren nd
    FOR   Erx # RecLink(441,440,4,_RecFirst);
    LOOP  Erx # RecLink(441,440,4,_RecFirst);
    WHILE Erx = _rOK DO BEGIN

      // Material von Lfs löschen
      RekLink(401,441,5,0); //  AufPos lesen
      RekLink(200,441,4,0); //  Material lesen
      vAufNr  # Auf.P.Nummer;
      vAufPos # Auf.P.Position;

      Log('Lösche Lieferscheinpos' + Aint(Lfs.P.Position));
      if (_WebApp_LFS_VerbucheVldaw_DelLfsPos() = false) then begin
        LogErr('Fehler beim Löschen der Lieferscheinposition');
        RETURN false;
      end;

  // Material entkommissionieren
      Log('Material ' + Aint(Mat.Nummer)  + ' von ' + Mat.kommission+' entkommissionieren');
      Erx # Mat_Data:SetKommission(Mat.Nummer,0,0,0, 'AUTO');
      if (Erx <> _rOK) then begin
        LogErr('Fehler beim Löschen der Kommission von Mat '+aint(Mat.Nummer)+': Erg =' + Aint(Erx));
        RETURN false;
      end;
      Log('Material ' + Aint(Mat.Nummer)  + ' Kommission nachher:' + Mat.kommission);

    END;

    Log('Lieferscheinpositionen gelöscht, jetzt neue Positionen anlegen');
    Log('neue Kommission lesen:' + Aint(vAufNr) +'/'+Aint(vAufNr));
    Auf_Data:Read(vAufNr, vAufPos , true);
    Log('Kommission gelesen:' + Aint(Auf.P.Nummer) +'/'+Aint(Auf.P.Position));

    vMatDelim # ',';
    aMats # Lib_Strings:Strings_ReplaceEachToken(aMats,'[]','');
    vMatCnt # Lib_Strings:Strings_Count(aMats,vMatDelim) + 1;

    vLfsPos # 1;
    FOR i # 1
    LOOP inc(i)
    WHILE i <= vMatCnt DO BEGIN
      vMatToken #  Str_Token(aMats,vMatDelim,i);
      Log('... MatToken = ' + vMatToken);

      if (CnvIa(vMatToken) = 0) then
        CYCLE;

      // Material lesen
      Log('Material lesen...');
      Erx # Mat_Data:Read(CnvIa(vMatToken));
      if (Erx <> 200) then begin
        LogErr('Fehler beim Löschen der Lieferscheinposition: Erg =' + Aint(Erx));
        RETURN false;
      end;

      // Material gelesen, dann kommissionieren und auf den LFS
      Log('Material gelesen ' + Aint(Mat.Nummer));
      Log('alte Kommission='  + Mat.Kommission);
      if (Mat.Kommission <> '') then begin
        Log('Kommission entfernen');
        Log('Material ' + Aint(Mat.Nummer)  + ' entkommissionieren');
        Erx # Mat_Data:SetKommission(Mat.Nummer,0,0,0, 'AUTO');
        if (Erx <> _rOK) then begin
          LogErr('Fehler beim Löschen der Kommission von Mat '+aint(Mat.Nummer)+': Erg =' + Aint(Erx));
          RETURN false;
        end;
      end;

      // Mateiral kommissionieren
      Log('Neue Kommission= soll'  + Aint(Auf.P.Nummer) + '/' + Aint(Auf.P.Position));
      Erx # Mat_Data:SetKommission(Mat.Nummer,Auf.P.Nummer,Auf.P.Position,0, 'AUTO');
      if (Erx <> _rOK) then begin
        LogErr('Fehler beim Kommissionieren von Material '+Aint(Mat.nummer)+': Erg =' + Aint(Erx));
        RETURN false;
      end;
      Log('Neue Kommission= '  + Mat.Kommission);

  // ggf. von altem Lieferschein löschen
      Log('Prüfung Material auf anderem Lieferschein?');
      v400 # RekSave(400);
      v401 # RekSave(401);
      v440 # RekSave(440);
      v441 # RekSave(441);

      if (RecLink(441,200,27,0) = _rOK) then begin
        Log('Material von Lieferschein ' + Aint(Lfs.P.Nummer) + ' entfernen');

        if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(true)) then begin
          Log('VLDAW entfernt');
          Erx # RekDelete(441,0,'MAN');
          if (erx<>_rOK) then begin
            LogErr('Lfs Position konnte nicht entfernt werden');
            RETURN false;
          end;
        end else begin
          LogErr('VLDAW konnte nicht entfernt werden');
          RETURN false;
        end;

      end else begin
        Log(' nein');

      end;

      RekRestore(v441);
      RekRestore(v440);
      RekRestore(v401);
      RekRestore(v400);

      // Mat auf Lfs
      Log('Auf Lfs hinzufügen');
      if (Auf_Data:VLDAW_Pos_Einfuegen_Mat(Lfs.Nummer,var vLfsPos, 0) = false) then begin
        RecCleanup_LFS();
        LogErr('Fehler bei Erstellung von Lfs Pos für Material '+Aint(Mat.nummer));
        RETURN false;
      end;

      if (aVerbuchen) then begin
        Log('Verladeanweisung verbuchen');
        if (LFS_VLDAW_Data:Pos_VLDAW_Verbuchen(false) = false) then begin
          RecCleanup_LFS();
          LogErr('Fehler bei Erstellung von Lfs Pos für Material '+Aint(Mat.nummer));
          RETURN false;
        end;
      end else begin
        Log('Verladeanweisung nicht verbuchen');
      end;

    END;

    Log('Lieferscheinpositionen erfolgreich aktualisiert');
  end;



  RekLink(441,440,4,0);   // Erste Position lesen

  Log('Beginn Lieferscheinverbuchung ' + aint(aLfs));
  Log('Starte Druck...');
  log('Usergroup: ' + gUsergroup);

  // Lieferschein Drucken und verbuchen
  if (Lfs_Data:Druck_LFS(true)) then begin
    Log('Dokumente gedruckt');

    if (aVerbuchen) then begin

      WinSleep(1000);
      if (Lfs.zuBA.Nummer = 0) then begin

        Log('Lieferschein verbuchen....');
        if (Lfs_Data:Verbuchen(Lfs.Nummer, today, now, true)) then
          Log('Lieferschein erfolgreich verbucht');
        else
          Log('FEHLER bei Lieferscheinverbuchung');

      end else begin

        Log('Fahrauftrag verbuchen....');
        if (Lfs_LFA_Data:GesamtFM(today)) then begin
          Log('Fahrauftrag erfolgreich verbucht');
          Log('Fahrauftrag abschließen...');
          if (BA1_Fertigmelden:AbschlussPos(Lfs.zuBA.Nummer, Lfs.zuBA.Position,today, now, true)) then
            Log('Fahrauftragsabschluss ok');
          else
            Log('Fehler bei Fahrauftragsabschluss');

        end
        else
          Log('FEHLER bei Fahrauftragsverbuchung');

      end;
    end else begin
      Log('ohne Verbuchung');
    end;

  end else begin
    Log('FEHLER bei Dokumentenausgabe');
  end;


  // irgendwas schiefgelaufen (Kredlim, Satzsperre etc)
  if (Errlist <> 0) then
    RETURN false;

  Log('WebApp_LFS_VerbucheVldaw ENDE');
  RETURN true;
end;


//========================================================================
//  sub WebApp_LFS_VerbucheVldawCustom(aLfs : int; aMats : alpha(4000)) : logic;
//      Erzeugt Teilverladungen ist akutell Custom für HWN (2343/73)
//========================================================================
sub WebApp_LFS_VerbucheVldawVsP(aLfs : int; aMats : alpha(8000); aVerbuchen : logic) : logic;
local begin
  Erx       : int;
  vErx      : int;
  vLfs      : int;
  vAufNr    : int;
  vAufPos   : int;
  vVSP      : int;
  vPaket    : int;
  vCount    : int;
  vScdCount : int;

  i         : int;
  vMatToken : alpha;
  vMatCnt   : int;
  vMatDelim : alpha;
  vLfsPos   : int;


  v400      : int;
  v401      : int;
  v440      : int;
  v441      : int;

  x : int;
end
begin
  Log('WebApp_LFS_VerbucheVldaw START');
  if (RunAFX('WebApp.LFS.VerbucheVldaw',Aint(aLfs)+'|'+aMats+'|'+Aint(CnvIl(aVerbuchen))) <> 0) then begin
    if (AfxRes = 0) then begin
//      Log('AFX Aufruf OK');
      RETURN true;
    end else begin
//      Log('AFX Aufruf Nicht OK');
      Error(99,'Fehler in AFX');
      RETURN false;
    end;
  end;

  Log('WebApp_LFS_VerbucheVldaw mit Standardfunktionalität');


  if (aLfs = 0) then begin
    Log('Lieferscheinnummer nicht angegeben');
    Error(99,'VLDAW nicht angegeben');
    RETURN false;
  end;

  Lfs.Nummer # aLfs;
  if (RecRead(440,1,0) <> _rOK) then begin
    Log('Lieferscheinnummer "'+Aint(aLfs)+'" nicht lesbar');
    Error(99,'VLDAW nicht lesbar');
    RETURN false;
  end;

  if (aMats <> '') then begin
  
    vMatDelim # '|';
    aMats # Lib_Strings:Strings_ReplaceEachToken(aMats,'[]','');
    vMatCnt # Lib_Strings:Strings_Count(aMats,vMatDelim) + 1;
    
    FOR i # 1
    LOOP inc(i)
    WHILE i <= vMatCnt DO BEGIN
      vMatToken #  Str_Token(aMats,vMatDelim,i);

      Log('Lösche alle Lieferscheinpositionen');
      // Alte Materialien dekommissionieren nd
      FOR   Erx # RecLink(441,440,4,_RecFirst);
      LOOP  Erx # RecLink(441,440,4,_RecNext);
      WHILE Erx = _rOK DO BEGIN
       
       if(Lfs.P.Versandpoolnr = 0 ) then CYCLE
       
       
        // Material von Lfs löschen
        RekLink(401,441,5,0); //  AufPos lesen
        RekLink(200,441,4,0); //  Material lesen
        
        Log('Check ' + cnvai(Mat.Nummer) + ' == ' + vMatToken )
        
        if(Mat.Nummer <> cnvia(vMatToken)) then CYCLE;
        

        if (lfs.P.Datum.Verbucht<>0.0.0) then begin
          if (Lfs_LFA_Data:Storniere()=false) then begin
            LogErr('Position ' + aint(Lfs.P.Position) + ' konnte nicht gelöscht werden.');
          end;
        end;

         Log('Erfolgreich storniert');

        // Diesen Eintrag wirklich löschen?
 
        if (lfs.zuBA.Nummer=0) then begin
          RekDelete(gFile,0,'MAN');
           Log('RecDelete erfolgreich');
        end
        else begin
          vVSP # Lfs.P.Versandpoolnr;
          Erx # RecLink(702,441,9,_recFirst);     // BA-Position holen
          Erx # RecLink(703,441,10,_recFirst);    // BA-Fertigung holen
          Erx # RecLink(701,441,11,_RecFirst);    // BA-Input holen
          Log('Einsatz Raus ....');
          if (BA1_IO_Data:EinsatzRaus(cnvai(BAG.IO.Nummer)+'/'+cnvai(BAG.IO.ID))=false) then LogErr('EinsatzRaus hat nicht funktioniert ');
          else  Log('Einsatz Raus erfolgreich');

          RekDelete(441,_recUnlock,'MAN');

          // ok...
          if (vVSP<>0) then begin
            VsP_Data:Rest2Pool(vVSP);
          end;
          Log('Löscehn ok');
          
        end;
      END;
    END;
  end;





  // Wenn neue Materialnummern angegeben sind, dann wird der Lieferschein neu
  // aufgebaut, mit den Materialien die geliefert wurden
  if (aMats <> '') then begin
    Log('Lieferscheinpositionen löschen:' + aMats);

    vMatDelim # '|';
    aMats # Lib_Strings:Strings_ReplaceEachToken(aMats,'[]','');
    vMatCnt # Lib_Strings:Strings_Count(aMats,vMatDelim) + 1;
    FOR i # 1
    LOOP inc(i)
    WHILE i <= vMatCnt DO BEGIN
        vMatToken #  Str_Token(aMats,vMatDelim,i);
      // Alte Materialien dekommissionieren nd
      FOR   Erx # RecLink(441,440,4,_RecFirst);
      LOOP  Erx # RecLink(441,440,4,_RecNext);
      WHILE Erx = _rOK DO BEGIN
        
        if(Lfs.P.Versandpoolnr != 0 ) then CYCLE
       
        RekLink(401,441,5,0); //  AufPos lesen
        RekLink(200,441,4,0); //  Material lesen
          
        Log('Check ' + cnvai(Mat.Nummer) + ' == ' + vMatToken )
          
        if(Mat.Nummer <> cnvia(vMatToken)) then CYCLE;
         TRANSON;
         
        // Material entkommissionieren
        Log('Material ' + Aint(Mat.Nummer)  + ' von ' + Mat.kommission+' entkommissionieren');
        Erx # Mat_Data:SetKommission(Mat.Nummer,0,0,0, 'AUTO');
        if (Erx <> _rOK) then begin
          LogErr('Fehler beim Löschen der Kommission von Mat '+aint(Mat.Nummer)+': Erg =' + Aint(Erx));
          RETURN false;
        end;
        Log('Material ' + Aint(Mat.Nummer)  + ' Kommission nachher:' + Mat.kommission);
         

        vPaket # Lfs.P.Paketnr;

        if (Lfs.P.Nummer>0) and (Lfs.P.Nummer<100000000) then begin
          // bisherige VLDAW stornieren
          if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
            TRANSBRK;
            LogErr('VLDAW Verbuchung fehlgeschlagen')
            RETURN False;
          end;

        end;

        Erx # RekDelete(441,0,'MAN');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          Logerr('Position ' + cnvai(Lfs.P.Position) + ' konnte nicht gelöscht werden.');

          RETURN False;
        end;


//         ggf. andere Positionen von diesem Paket löschen
        if (vPaket <> 0) then begin

          vErx # RecLink(441,440,4,_RecFirst);
          WHILE vErx = _rOK DO BEGIN

            if (Lfs.P.PaketNr <> vPaket) then begin
              vErx # RecLink(441,440,4,_RecNext);
              CYCLE;
            end;

            // bisherige VLDAW stornieren
            if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
              TRANSBRK;
              LogErr('Stornierung von bisheriger VLDAW fehlgeschlagen.');
              RETURN False;
            end;

            Erx # RekDelete(441,0,'MAN');
            if (Erx<>_rOK) then begin
              TRANSBRK;
              Logerr('Position ' + cnvai(Lfs.P.Position) + ' konnte nicht gelöscht werden.');
              RETURN False;
            end;

            vErx # RecLink(441,440,4,_RecFirst);
          END;     // LFS Loop
        end;

      END;
      TRANSOFF;
    END;
    
    Log('Lieferscheinpositionen erfolgreich aktualisiert');
  end;

  RekLink(441,440,4,0);   // Erste Position lesen

  Log('Beginn Lieferscheinverbuchung ' + aint(aLfs));
  Log('Starte Druck...');
  log('Usergroup: ' + gUsergroup);

  // Lieferschein Drucken und verbuchen
  if (Lfs_Data:Druck_LFS(true)) then begin
    Log('Dokumente gedruckt');

//    if (aVerbuchen = false) then begin
//
//
//      if (Lfs.zuBA.Nummer = 0) then begin
//
//        Log('Lieferschein verbuchen....');
//        if (Lfs_Data:Verbuchen(Lfs.Nummer, today, now, true)) then
//          Log('Lieferschein erfolgreich verbucht');
//        else
//          Log('FEHLER bei Lieferscheinverbuchung');
//
//      end else begin
//
//        Log('Fahrauftrag verbuchen....');
//        if (Lfs_LFA_Data:GesamtFM(today)) then begin
//          Log('Fahrauftrag erfolgreich verbucht');
//
//        end
//        else
//          Log('FEHLER bei Fahrauftragsverbuchung');
//
//      end;
//    end else begin
//      Log('ohne Verbuchung');
//    end;
//
  end else begin
    Log('FEHLER bei Dokumentenausgabe');
  end;


  // irgendwas schiefgelaufen (Kredlim, Satzsperre etc)
  if (Errlist <> 0) then
    RETURN false;

  Log('WebApp_LFS_VerbucheVldaw ENDE');
  RETURN true;
end;










//========================================================================
//  sub WebApp_LfaFertigmeldungEinzeln(aLfs : int; aMats : alpha(4000)) : logic;
//      Verbuchte einzelne Materialien auf übergebener LFA / LLfs Nr
//========================================================================
sub WebApp_LfaFertigmeldungEinzeln(aLfs : int; aMats : alpha(4000)) : logic;
local begin
  Erx       : int;
  vLfs      : int;
  vAufNr    : int;
  vAufPos   : int;

  i         : int;
  vMatToken : alpha;
  vMatCnt   : int;
  vMatDelim : alpha;
  vLfsPos   : int;


  v400      : int;
  v401      : int;
  v440      : int;
  v441      : int;

  x : int;
end
begin
  Log('WebApp_LfaFertigmeldungEinzeln START');

  if (RunAFX('WebApp.LFA.FertigmeldEinzel',Aint(aLfs)+'|'+aMats) <> 0) then begin
    if (AfxRes = 0) then begin
      RETURN true;
    end else begin
      //Error(99,'Fehler in AFX');
      RETURN false;
    end;
  end;

  Log('WebApp_LfaFertigmeldungEinzeln mit Standardfunktionalität');


  if (aLfs = 0) then begin
    Log('Lieferscheinnummer nicht angegeben');
    Error(99,'VLDAW nicht angegeben');
    RETURN false;
  end;

  Lfs.Nummer # aLfs;
  if (RecRead(440,1,0) <> _rOK) then begin
    Log('Lieferscheinnummer "'+Aint(aLfs)+'" nicht lesbar');
    Error(99,'VLDAW nicht lesbar');
    RETURN false;
  end;

  // Wenn neue Materialnummern angegeben sind, dann wird der Lieferschein neu
  // aufgebaut, mit den Materialien die geliefert wurden
  if (aMats <> '') then begin
    Log('Lieferschein mit neuen Materialnummern:' + aMats);

    vMatDelim # ',';
    aMats # Lib_Strings:Strings_ReplaceEachToken(aMats,'[]','');
    vMatCnt # Lib_Strings:Strings_Count(aMats,vMatDelim) + 1;

    vLfsPos # 1;
    FOR i # 1
    LOOP inc(i)
    WHILE i <= vMatCnt DO BEGIN
      vMatToken #  Str_Token(aMats,vMatDelim,i);
      Log('... MatToken = ' + vMatToken);

      if (CnvIa(vMatToken) = 0) then
        CYCLE;

      // Material lesen
      Log('Material lesen...');
      Erx # Mat_Data:Read(CnvIa(vMatToken));
      if (Erx <> 200) then begin
        LogErr('Fehler beim Löschen der Lieferscheinposition: Erg =' + Aint(Erx));
        RETURN false;
      end;


      Log('Verladeanweisung verbuchen');
      if (LFS_VLDAW_Data:Pos_VLDAW_Verbuchen(false) = false) then begin
        LogErr('Fehler bei Erstellung von Lfs Pos für Material '+Aint(Mat.nummer));
        RETURN false;
      end;

    END;

    Log('Lieferscheinpositionen erfolgreich aktualisiert');
  end;

  RekLink(441,440,4,0);   // Erste Position lesen

  Log('Beginn Lieferscheinverbuchung ' + aint(aLfs));
  Log('Starte Druck...');
  log('Usergroup: ' + gUsergroup);

  // Lieferschein Drucken und verbuchen
  if (Lfs_Data:Druck_LFS(true)) then begin
    Log('Dokumente gedruckt');
  end else begin
    Log('FEHLER bei Dokumentenausgabe');
  end;


  // irgendwas schiefgelaufen (Kredlim, Satzsperre etc)
  if (Errlist <> 0) then
    RETURN false;

  Log('WebApp_LfaFertigmeldungEinzeln ENDE');
  RETURN true;
end;





//========================================================================
//  sub WebApp_LFS_Verbuchen(aLfs : int) : logic;
//      Verbucht einen Lieferschein
//========================================================================
sub WebApp_LFS_Verbuchen(aLfs : int; opt aVerbDatum : date; opt aVerbZeit : time) : logic;
local begin
  vLfs      : int;
  vAufNr    : int;
  vAufPos   : int;

  i         : int;
  vMatToken : alpha;
  vMatCnt   : int;
  vMatDelim : alpha;
  vLfsPos   : int;


  v400      : int;
  v401      : int;
  v440      : int;
  v441      : int;
  
  vToday    : date;
  vNow      : time;

  x : int;
end
begin

  Log('WebApp_LFS_Verbuchen START');

  if (aVerbDatum<>0.0.0) then begin
    vToday # aVerbDatum;
    vNow # aVerbZeit;
    Log('WebApp_LFS_Verbuchen optionale Datum/Zeit erkannt. Verbuchung über Job-Server init..');
    end
    else begin
    vToday # today;
    vNow # now;
    end
 
  


  if (RunAFX('WebApp.LFS.Verbuchen',Aint(aLfs)) <> 0) then begin
    if (AfxRes = 0) then begin
//      Log('AFX Aufruf OK');
      RETURN true;
    end else begin
//      Log('AFX Aufruf Nicht OK');
      Error(99,'Fehler in AFX');
      RETURN false;
    end;
  end;

  Log('WebApp_LFS_Verbuchen mit Standardfunktionalität');


  if (aLfs = 0) then begin
    Log('Lieferscheinnummer nicht angegeben');
    Error(99,'LFS nicht angegeben');
    RETURN false;
  end;

  Lfs.Nummer # aLfs;
  if (RecRead(440,1,0) <> _rOK) then begin
    Log('Lieferscheinnummer "'+Aint(aLfs)+'" nicht lesbar');
    Error(99,'LFS nicht lesbar');
    RETURN false;
  end;


  if (Lfs.Datum.Verbucht <> 0.0.0)then begin
    Log('Lieferscheinnummer "'+Aint(aLfs)+'" ist schon verbucht');
    Error(99,'LFS '+Aint(aLfs)+' ist schon verbucht');
    RETURN false;
  end;


  RekLink(441,440,4,0);   // Erste Position lesen

  Log('Beginn Lieferscheinverbuchung ' + aint(aLfs));

  if (Lfs.zuBA.Nummer = 0) then begin

    Log('Lieferschein verbuchen....');
    if (Lfs_Data:Verbuchen(Lfs.Nummer, vToday, vNow, true)) then
      Log('Lieferschein erfolgreich verbucht');
    else
      Log('FEHLER bei Lieferscheinverbuchung');

  end else begin

    Log('Fahrauftrag verbuchen....');
    if (Lfs_LFA_Data:GesamtFM(vToday)) then begin
      Log('Fahrauftrag erfolgreich verbucht');
      Log('Fahrauftrag abschließen...');
      if (BA1_Fertigmelden:AbschlussPos(Lfs.zuBA.Nummer, Lfs.zuBA.Position,vToday, vNow, true)) then
        Log('Fahrauftragsabschluss ok');
      else
        Log('Fehler bei Fahrauftragsabschluss');

    end
    else
      Log('FEHLER bei Fahrauftragsverbuchung');

  end;

  // irgendwas schiefgelaufen (Kredlim, Satzsperre etc)
  if (Errlist <> 0) then
    RETURN false;

  Log('WebApp_LFS_Verbuchen ENDE');
  RETURN true;
end;


//========================================================================
//  sub _WebApp_Lfs_NeuAusVerladung_Lfs(a440 : int; aKommNode : int) : logic
//  Legt einen Lieferschein für alle MAterialien in der KommNode an
//========================================================================
sub _WebApp_Lfs_NeuAusVerladung_Lfs(aKommNode : int) : logic
local begin
  Erx       : int;
  vMatItem  : int;
  vMat      : int;
  vI        : int;
end
begin

  vI  #  0;
  FOR  vMatItem # aKommNode->CteRead(_CteFirst);
  LOOP vMatItem # aKommNode->CteRead(_CteNext, vMatItem);
  WHILE (vMatItem <> 0) DO BEGIN
    inc(vI);

    vMat  # CnvIa(vMatItem->spCustom);
    Erx # Mat_Data:Read(vMat);
    if (Erx <> 200) then begin
      LogErr('Material ' + Aint(vMAt)+ ' konnte nicht gelesen werden');
      BREAK;
    end;

    Auf_Data:Read(Mat.Auftragsnr, Mat.Auftragspos,true);

    // Add Lfs Pos
    Log('Auf Lfs hinzufügen');
    if (Auf_Data:VLDAW_Pos_Einfuegen_Mat(Lfs.Nummer,var vI, 0) = false) then begin
      LogErr('Fehler bei Erstellung von Lfs Pos für Material '+Aint(Mat.nummer));
      RETURN false;
    end;

  END;

  RETURN (ErrList = 0);
end;




//========================================================================
//  sub WebApp_LFS_VerbucheVldaw(aLfs : int; aMats : alpha(4000)) : logic;
//      Verbucht eine VLDAW zu einem Lieferschein
//========================================================================
sub WebApp_Lfs_NeuAusVerladung(
  aMaterialien : alpha(4000);
  aLieferdat : date;
  aMaxLadung : float;
  aSpediteurNr : int;
  aReferenz : alpha;) : logic;
local begin
  Erx           : int;
  vI , vMatCnt  : int;
  vMatToken     : alpha;
  vMatDelim     : alpha;

  vCteNodeKomMats :  int;
  vCteNodeKom     :  int;
  vCteNodeMats    :  int;
  v440           :  int;

  // Checks
  vKunde        : int;
  vLieferAdr    : int;
  vLieferAns    : int;
end
begin
  Log('WebApp_Lfs_NeuAusVerladung Start');

  if (RunAFX('WebApp.LFS.NeuAusVerladung',aMaterialien+'|'+CnvAd(aLieferdat) + '|' + CnvAf(aMaxLAdung,0)+ '|' + Aint(aSpediteurNr) + '|' +  aReferenz) <> 0) then begin
    if (AfxRes = 0) then begin
      Log('AFX Aufruf OK');
      RETURN true;
    end else begin
      Log('AFX Aufruf Nicht OK');
      Error(99,'Fehler in AFX');
      RETURN false;
    end;
  end;

  Log('WebApp_Lfs_NeuAusVerladung mit Standardfunktionalität');

  Log('Mats: ' + aMaterialien);

  // Pro Auftragskopf ein Lieferschein ein Lieferschein erstellen
  vMatDelim       # ',';
  aMaterialien    # Lib_Strings:Strings_ReplaceEachToken(aMaterialien,'[]','');
  vMatCnt         # Lib_Strings:Strings_Count(aMaterialien,vMatDelim) + 1;
  vCteNodeKomMats # CteOpen(_CteNode);
  FOR vI # 1
  LOOP inc(vI)
  WHILE vI <= vMatCnt DO BEGIN
    vMatToken #  Str_Token(aMaterialien,',',vI);
    Log('... MatToken = ' + vMatToken);
    if (CnvIa(vMatToken) = 0) then
      CYCLE;

    // Material lesen
    Erx # Mat_Data:Read(CnvIa(vMatToken));
    if (Erx <> 200) then begin
      LogErr('Material "' + vMatToken + '" konnte nicht gelesen werden');
      BREAK;
    end;

    Auf.Nummer # Mat.Auftragsnr;
    Erx # RecRead(400,1,0);
    if (Erx <> _rOK) then begin
      LogErr('Material "' + vMatToken + '":  Auftrag '+Aint(Mat.Auftragsnr)+' nicht lesebar Erg:' + Aint(Erx));
      BREAK;
    end;

    // Plausi Check
    if (vKunde  = 0) then begin
      vKunde      # Auf.Kundennr;
      vLieferAdr  # Auf.Lieferadresse;
      vLieferAns  # Auf.Lieferanschrift;
    end;
    if (vKunde      <> Auf.Kundennr) OR
       (vLieferAdr  <> Auf.Lieferadresse) OR
       (vLieferAns  <> Auf.Lieferanschrift) then begin
      LogErr('Abweichender Kunden/Lieferanschrift');
      BREAK;
    end;

    // AUftrag einhängen
    vCteNodeKom # vCteNodeKomMats->CteRead(_CteFirst | _CteSearch, 0, Aint(Auf.Nummer));
    if (vCteNodeKom <= 0) then begin
      // Kommission noch nicht vorhanden, anlegen
      vCteNodeKom # vCteNodeKomMats->CteInsertItem( Aint(Auf.Nummer),Auf.Nummer,Aint(Auf.Nummer));
    end;

    // Mat in Auftrag anhängen
    vCteNodeMats # vCteNodeKom->CteRead(_CteFirst | _CteSearch,Lfs.Nummer,Aint(Lfs.Nummer));
    if (vCteNodeMats  <= 0) then begin
      // Lieferscheinnummer an Kunden hinterlegen
      vCteNodeMats # vCteNodeKom->CteInsertItem(Aint(Mat.Nummer),Mat.Nummer,Aint(Mat.Nummer));
    end;
  END;



  if (ErrList = 0) then begin
    Log('Aufträge einsortiert... ');

    Log('Erstelle Lieferscheine... ');
    // Pro Auftrag einen Lieferschein anlegen
    FOR  vCteNodeKom # vCteNodeKomMats->CteRead(_CteFirst);
    LOOP vCteNodeKom # vCteNodeKomMats->CteRead(_CteNext, vCteNodeKom);
    WHILE (vCteNodeKom <> 0) DO BEGIN

      Auf.Nummer # CnvIa(vCteNodeKom->spCustom);
      Erx # RecRead(400,1,0);
      if (Erx <> _rOK) then begin
        LogErr('Auftrag konnte nicht gelesen werden');
        BREAK;
      end;

      RecBufClear(440);
      Lfs.Nummer          # myTmpNummer;
      Lfs.Anlage.Datum    # today;
      Lfs.Kosten.PEH      # 1000;
      Lfs.Kosten.MEH      # 'kg';
      Lfs.Lieferdatum     # aLieferdat;
      Lfs.Spediteurnr     # aSpediteurNr;
      Lfs.Referenznr      # aReferenz;
      if (aMaxLadung > 0.0) then
        Lfs.Bemerkung   # 'MDE MaxLadung: ' + Anum(aMaxLadung,0) + ' kg';

      Lfs.Kundennummer    # Auf.Kundennr;
      Lfs.Kundenstichwort # Auf.KundenStichwort;
      Lfs.Zieladresse     # Auf.Lieferadresse;
      Lfs.Zielanschrift   # Auf.Lieferanschrift;

      Log('Lieferschein für Auftrag ' + Aint(Auf.Nummer) +' erstellen... ');
      if (_WebApp_Lfs_NeuAusVerladung_Lfs(vCteNodeKom) = false) then begin
        // hier Fehler
        RecCleanup_LFS();
        LogErr('Fehler bei Lieferscheinanlage');
        BREAK;
      end;

      if (Lfs_Data:SaveLFS()) then begin
        Log('Lieferschein ' + Aint(Lfs.Nummer) +' für Auftrag ' +Aint(Auf.Nummer)+ ' erfolgreich erstellt');

      end else begin
        
        RecCleanup_LFS();
        LogErr('Lieferschein konnte nicht gespeichert werden!');
        BREAK;
      end;

    END;
  end;

  // Aufräumarbeiten
  CteClose(vCteNodeKom);
  CteClose(vCteNodeKomMats);

  // irgendwas schiefgelaufen (Kredlim, Satzsperre etc)
  if (Errlist <> 0) then begin
    RecCleanup_LFS();
    RETURN false;
    end;

  Log('WebApp_Lfs_NeuAusVerladung ENDE');
  RETURN true;
end;


//========================================================================
//  sub WebApp_MatAbruf(aBuf800User : int; aMats : alpha(4000); aTermin : alpha; aLieferAdr : alpha) : logic;
//      Legt eine Verladung an
//========================================================================
sub WebApp_MatAbruf(aBuf800User : int; aMats : alpha(4000); aTermin : alpha; aLieferAdr : alpha) : logic;
local begin
  Erx       : int;
  vWunschtermin : caltime;

  vMatDelim : alpha;
  vMatCnt   : int;
  i         : int;
  vMatToken : alpha;

  vTree     : int;
  vTreeKey  : alpha;
  vErr      : alpha(500);

  vLieferAdresse : int;
end
begin
  Log('WebApp_MatAbruf START');

  if (aBuf800User->Usr.zuDatei = 100) or
     (aBuf800User->Usr.zuDatei = 102) then begin

    Adr.Nummer # aBuf800User->Usr.zuNummer1;
  end;


  if (Adr.Nummer = 0) then begin
    LogErr('Adresnummer nicht angegeben');
    RETURN false;
  end;

  if (aTermin = '') then begin
    LogErr('Versandtermin nicht angegeben');
    RETURN false;
  end;

  if (CnvIa(aLieferAdr) <=0) then begin
    LogErr('Lieferadresse nicht angegeben');
    RETURN false;
  end;

  if (aMats = '') OR (StrLen(aMats) < 5) then begin
    LogErr('Keine Materialien angegeben');
    RETURN false;
  end;


  if (RecRead(100,1,0) <> _rOK) then begin
    LogErr('Adressnummer "' + Aint(aBuf800User->Usr.zuNummer1) + '" nicht lesbar');
    RETURN false;
  end;
  Log('Adresse : ' + Adr.Stichwort)


  if (aTermin <> '') then begin
    vWunschtermin->vpDate # CnvDa(aTermin,_FmtDateDMY);
    Log('Wunschtermin: ' + CnvAd(vWunschtermin->vpDate));
  end;

  Log('Starte Markierung zur Kommissionierung für Mats' + aMats);

  vMatDelim # ',';
  aMats # Lib_Strings:Strings_ReplaceEachToken(aMats,'[]','');
  vMatCnt # Lib_Strings:Strings_Count(aMats,vMatDelim) + 1;

  vTree # CteOpen(_CteList);

  FOR i # 1
  LOOP inc(i)
  WHILE i <= vMatCnt DO BEGIN
    vMatToken #  Str_Token(aMats,vMatDelim,i);
    Log('... MatToken = ' + vMatToken);

    if (CnvIa(vMatToken) = 0) then
      CYCLE;

    // Material lesen
    Erx # Mat_Data:Read(CnvIa(vMatToken));
    if (Erx <> 200) then begin
      LogErr('Material "' + vMatToken + '" konnte nicht gelesen werden');
      RETURN false;
    end;

    // Material auch vom gleichen Kunden angeliefert?
    if (Mat.Lieferant <> Adr.Lieferantennr) then begin
      LogErr('Lieferanten stimmen nicht übnerein');
      RETURN false;
    end;

    vTreeKey # cnvai(200)+'/'+cnvai(RecInfo(200,_RecId));
    vTree->CteInsertItem(vTreeKey,RecInfo(200,_RecId),'');

  END;

  Log('Materialien markiert');

  vLieferAdresse # CnvIa(Str_Token(aLieferAdr,'/',1));
  Log('Lieferadresse :' + Aint(vLieferadresse));

/*
  // Verladeauftrag anlegen
  vErr # SFX_MEG_MAT:_ErstelleAuftragVerbuchen(vTree,vWunschtermin->vpDate, true,aBuf800User,vLieferAdresse );
  if (vErr <> '') then begin
    LogErr('FEHLER: ' + vErr);
    Error(99,vErr);
  end;
*/
  Log('WebApp_Abruf ENDE');
  RETURN (Errlist = 0);
end;



//========================================================================
//  sub WebApp_Auf_Zuordnung(...) : logic;
//      Verbucht eine Kommissionierung
//========================================================================
sub WebApp_Auf_Zuordnung(
  aAufNr                      : int;
  aAufPos                     : int;
  aStk                        : int;
  aGew                        : float;
  aMenge                      : float;
  aMat                        : alpha;
  aRsvNr                      : int;
  aKannMehrKommissionierenYN  : logic;
  ) : logic;
local begin
  Erx         : int;
  vChargeInt  : alpha;
  vOK         : logic;
  vMatOld     : int;
end
begin
  
  Log('WebApp_Auf_Zuordnung START');

  if (RunAFX('WebApp.Auf.Zuordnung',Aint(aAufNr)+'|'+Aint(aAufPos)+'|'+aint(aStk)+'|'+ANum(aGew,Set.Stellen.Gewicht) +'|' + ANum(aMenge,"Set.Stellen.Menge") + '|' + aMat) <> 0) then begin
    if (AfxRes = 0) then begin
      RETURN true;
    end else begin
      Error(99,'Fehler in AFX');
      RETURN false;
    end;
  end;

  Log('WebApp_Auf_Zuordnung mit Standardfunktionalität');

  // Auftrag lesen
  Erx # Auf_Data:Read(aAufNr,aAufPos,true);
  if (Erx <> 401) then begin
    LogErr('Auftrag nicht gefunden Erg=' + Aint(Erx));
    RETURN false;
  end;

  // Menge Prüfen
  if (aStk = 0) AND (aGew = 0.0) AND (aMenge = 0.0) then begin
    LogErr('Keine Entnahmemenge angegeben');
    RETURN false;
  end;

  // Material lesen
  if (aMat = '') then begin
    LogErr('Kein Material angegeben');
    RETURN false;
  end;


  // -----------------------------------------------------
  // Daten ab hier IO, Verbuchung vorbereiten
  Log('Argumente vorerst ok ');
  RekLink(819,401,1,0); // Wgr
  Log('Auftrag:'+Aint(Auf.P.Nummer) + '/' + Aint(Auf.P.Position));
  Log('Auftragswarengruppe: ' + Aint(Wgr.Nummer) + '  Dateinr:' + Aint(Wgr.Dateinummer) );

  if (Wgr_Data:IstArt()) then begin
    Log('Artkelcharge zuordnen');

    // Artikel laut Auftrag lesen
    RekLink(250,401,2,0);

    // Charge lesen
    vChargeInt # CnvAi(CnvIa(aMat),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
    Art.C.Charge.Intern # vChargeInt ;
    Erx # RecRead(252,9,0);
    if (Erx > _rMultiKey) OR (Art.C.Charge.Intern <> vChargeInt) then begin
      LogErr('Artikelcharge nicht gefunden');
      RETURN false;
    end;

    // Charge buchen
    vOK # Auf_Data_Buchen:MatzArt(Art.C.ArtikelNr,Art.C.Adressnr,Art.C.Anschriftnr,Art.C.Charge.Intern,
                              false, false,
                              aMenge, aStk, aMenge);
    if (vOK = false) then begin
      LogErr('Fehler bei Chargenzuordnung');
      RETURN false;
    end;
    Log('Charge zugeordnet');
  end
  else begin
    //2022-10-16 MR IstMixMat durch IstMat erstzt
    if (Wgr_Data:IstMixMat() OR Wgr_Data:IstMat() OR Wgr_Data:IstMixArt()) then begin

      Log('MAterial lesen:' + aMat);
      Erx # Mat_Data:Read(CnvIa(aMat));
      if (Erx <> 200) then begin
        LogErr('Material nicht gefunden');
        RETURN false;
      end;


      if(aRsvNr <> 0) then begin
//      Mat.Bestand.Gew # Mat.Bestand.Gew - aGew;
//      Mat.Bestand.Menge # Mat.Bestand.Menge - aMenge;
//      Mat.Bestand.Stk # Mat.Bestand.Stk - aStk;
      
        Mat.Reserviert.Gew # Mat.Reserviert.Gew - aGew;
        Mat.Reserviert.Menge # Mat.Reserviert.Menge - aMenge;
        Mat.Reserviert.Stk # Mat.Reserviert.Stk - aStk;
      
      
        if((Mat.Reserviert.Gew<0.0) or (Mat.Reserviert.Menge<0.0) or (Mat.Reserviert.Stk<0)) then begin
          if(aKannMehrKommissionierenYN) then begin
            Mat.Reserviert.Gew # 0.0;
            Mat.Reserviert.Menge # 0.0;
            Mat.Reserviert.Stk # 0;
          end
          else begin
            LogErr('Zuviel kommissioniert.');
            RETURN false;
          end
        end
    
        Mat_Data:Replace(_recUnlock,'AUTO');
      
      end


      vMatOld # Mat.Nummer;

      Log('Materialnummer zuordnen');
      if (Auf_Data:MatzMat(true, false, aStk, aGew, aGew, aMenge) = false) then begin
        LogErr('Fehler bei Materialzuordnung');
        RETURN false;
      end;

      Log('Material zugeordnet');
     
      Log('Etikettendruck starten???');
      Log('Mat.Nummer = ' +  Aint(Mat.Nummer));
      Log('vMatOld = ' +  Aint(vMatOld));
    
    Erx # Recread(401,1,0);
    
    
    
      if (Mat.Nummer <> vMatOld) then begin
      
        MAt_Data:REad(Mat.Nummer);
        // Splitt durchgeführt, dann neu Etikettieren
        if(Auf.P.Etikettentyp <> 0) then
          Mat_Etikett:Init(Auf.P.Etikettentyp);  // Etikett für Kommissiertes Material
        else Mat_Etikett:Init(Set.BA.FM.Frei.Etk);
      
        
      
      //MR Anpassung WIP
//      Mat.Nummer = vMatOld;
//      Erx # RecRead(200,1,0);
//      Mat.R.Gewicht # Mat.R.Gewicht - aGew;
//      Mat.Gewicht.Brutto # Mat.Gewicht.Brutto - aGew;
//      Mat.Gewicht.Netto # Mat.Gewicht.Brutto - aGew;
//      "Mat.B.Stückzahl" # "Mat.B.Stückzahl" - aG
//      Mat.Bestand.Gew # Mat.Bestand.Gew - aGew
      
        MAt_Data:REad(vMatOld);
        if(Auf.P.Etikettentyp <> 0) then
          Mat_Etikett:Init(Auf.P.Etikettentyp);
        else Mat_Etikett:Init(Set.BA.FM.Frei.Etk); // Etikett für altes Lagermaterial
        
        RunAFX('WebApp.Post.AufZuOrd','');
      end;
      else begin
        Log('Alternativer EtkDruck');
        MAt_Data:REad(vMatOld);
        RunAFX('WebApp.Post.AufZuOrd','');
      end
   
    end;

  end
  // irgendwas schiefgelaufen (Kredlim, Satzsperre etc)
  if (Errlist <> 0) then begin
    Log('Fehlerliste gefüllt');
    RETURN false;
  end;

  Log('Alles IO');
  Log('WebApp_Auf_Zuordnung ENDE');
  RETURN true;
end;


//========================================================================
//  sub WebApp_MarkAufAlsErld(aAufNr  : int;  aAufPos : int;) : logic
//      Löscht Rsv aus Auftrag;
//========================================================================
sub WebApp_MarkAufAlsErld(aAufNr  : int;  aAufPos : int;) : logic
local begin
  Erx     : int;
  vCount  : int;
end
begin
  
  Auf.P.Nummer # aAufNr;
  Auf.P.Position # aAufPos;
  
  Erx # RecRead(401,1,0);
  if(Erx <> _rOk) then begin
    LogErr('Auftrag konnte nicht gefunden werden.');
    Return false;
  end;
  
  FOR Erx # RecLink(203,401,18,_recFirst);
  LOOP Erx # RecLink(203,401,18,_recFirst);
  WHILE Erx <=_rLocked DO BEGIN
    vCount # vCount + 1;
    Log('Lösche Rsv von Material ' + Aint(Mat.R.Materialnr));
  
    if (Mat_Rsv_Data:Entfernen(true)=false) then begin
      Log('Reservierung von ' + Aint(Mat.R.Materialnr) + ' wurde erfolgreich gelöscht.')
    end;
  END
  
  if(vCount = 0 ) then begin
    LogErr('Auftrag hatte keine Reservierungen. Bitte beim Herstellen melden.');
    Return false;
  end;
  
   if (RunAFX('WebApp.Auf.Post.Erledigt',cnvai(aAufNr)+'|'+cnvai(aAufPos)) <> 0) then begin
      Return true;
   end
 
  RETURN (Errlist = 0);

end


//========================================================================
//  sub WebApp_Umlagern_Werksnummer(aLieferantennr : int; aWerksnr : alpha; aLagerplatz : alpha)
//      Lagert die  angegebenenm MAerialien um
//========================================================================
sub WebApp_PaketErstellen(aMats : alpha(2000);  aBeist : alpha(2000);) : logic
local begin
  Erx     : int;
  i       : int;
  vToken  : alpha;
  vCntMax : int;
  vDelim  : alpha;
  vCnt    : int;

  vArtCharge : alpha;
  vMenge  : float;

  vPaketNr : int;
end
begin
  Log('WebApp_PaketErstellen Start');

  if (RunAFX('WebApp.Pak.Erstellen',aMats+'|'+aBeist) <> 0) then begin
    if (AfxRes = 0) then begin
      RETURN true;
    end else begin
      LogErr('Fehler in AFX');
      RETURN false;
    end;
  end;
  Log('WebApp_PaketErstellen mit Standardfunktionalität');

  aBeist # Lib_Strings:Strings_ReplaceAll(aBeist,'&quot;','');
  Log('Materialien: ' + aMats);
  Log('Beistellungen: ' + aBeist);

  // Paket erstellen
  TRANSON;
  Log('Paketnummer generieren...');
  vPaketNr # CnvIa(MatPAketNrNew());
  if (vPaketNr = 0) then begin
    TRANSBRK;
    LogErr('Fehler bei Genereireung der Paketnummer ');
    RETURN false;
  end;
  Log('... Paket: ' + Aint(vPaketNr));

  // Materialien in Paket anhängen
  vDelim # ',';
  aMats # Lib_Strings:Strings_ReplaceEachToken(aMats,'[]','');
  vCntMax # Lib_Strings:Strings_Count(aMats,vDelim) + 1;


  FOR i # 1
  LOOP inc(i)
  WHILE i <= vCntMax DO BEGIN
    vToken #  Str_Token(aMats,vDelim,i);
    Log('... MatToken = ' + vToken);
    if (CnvIa(vToken) = 0) then
      CYCLE;

    // Material lesen
    Log('Material lesen...');
    Erx # Mat_Data:Read(CnvIa(vToken));
    if (Erx <> 200) then begin
      LogErr('Fehler beim Lesen des Materials('+vToken+'): Erg =' + Aint(Erx));
      CYCLE;
    end;

    // Paketnummer anhängen
    RecBufClear(281)
    inc(vCnt);
    Pak.P.Nummer     # vPaketNr;
    Pak.P.Position   # vCnt;
    Pak.P.Typ        # 'MAT';
//    Pak.P.Menge      # Mat.Bestand.Menge;
//    Pak.P.MEH        # Mat.MEH;
    Pak.P.MaterialNr # Mat.Nummer;
    Erx # RekInsert(281);
    if (Erx <> _rOK) then begin
      LogErr('Fehler beim Erweitertn des Pakets ('+Aint(vPaketnr)+'): Erg =' + Aint(Erx));
      CYCLE;
    end;
    Log('Paketpos '+Aint(vCnt)+': ' + Aint(MAt.Nummer) + ' angehängt');

    // Paketnr an Material vererben
    Erx # Pak_P_Data:UpdateMaterial(Mat.Nummer);
    if (Erx <> _rOK) then begin
      LogErr('Fehler beim aktualisieren des Materials ('+Aint(Mat.Nummer)+'): Erg =' + Aint(Erx));
      CYCLE;
    end;
    Log('Material aktualisiert Mat.Nummer=' + Aint(MAt.Nummer) + ' Mat.Paketnr='+Aint(Mat.Paketnr));

  END;

  Log('Beistellungen einfügen...');
  // Beistellungen in Paket anhängen
  vDelim # ',';
  aBeist # Lib_Strings:Strings_ReplaceEachToken(aBeist,'[]"','');
  vCntMax # Lib_Strings:Strings_Count(aBeist,vDelim) + 1;
  FOR i # 1
  LOOP inc(i)
  WHILE i <= vCntMax DO BEGIN
    vToken #  Str_Token(aBeist,vDelim,i);
    Log('... BeistToken = ' + vToken);
    if (CnvIa(vToken) = 0) then
      CYCLE;

    // Material lesen
    Log('Beistellungsartikel lesen...');
    vArtCharge # Str_Token(vToken,':',1);
    vMenge     # CnvFa(Str_Token(vToken,':',2));

    Art.C.Charge.Intern # vArtCharge;
    Log('Art.C.Charge.Intern  = ' + vArtCharge);
    Log('Menge = ' + Anum(vMenge,2));

    Erx # RecRead(252,9,0);
    if (Erx > _rMultikey) OR (Art.C.Charge.Intern <> vArtCharge)  then begin
      LogErr('Interne Charge nicht eindeutig gefunden ('+vArtCharge+'): Erg =' + Aint(Erx));
      CYCLE;
    end;
    RekLink(250,252,1,0);

    // Paketnummer anhängen
    inc(vCnt);
    RecBufClear(281)
    Pak.P.Nummer        # vPaketNr;
    Pak.P.Position      # vCnt;
    Pak.P.Typ           # 'VPG';
//    Pak.P.Menge         # vMenge;
//    Pak.P.MEH           # Art.MEH;
    Pak.P.ArtikelNr     # Art.C.ArtikelNr;
    Pak.P.Art.Adresse   # Art.C.Adressnr;
    Pak.P.Art.Anschrift # Art.C.Anschriftnr;
    Pak.P.Art.Charge    # Art.C.Charge.Intern;
    Erx # RekInsert(281);
    if (Erx <> _rOK) then begin
      LogErr('Fehler beim Erweitertn des Pakets ('+Aint(vPaketnr)+'): Erg =' + Aint(Erx));
      CYCLE;
    end;
    Log('Paketpos '+Aint(vCnt)+': ' + Pak.P.Art.Charge +  ' angehängt');

  END;

  // Paket aktualisieren
  Pak_Data:Refresh(vPaketNr);
  Log('Paketgewicht aktualisiert: '+ Anum(Pak.Gewicht,2));

  if (vCnt = 0) OR (ErrList <> 0) then begin
    TRANSBRK;
    LogErr('Fehler ode keine Materialien gebucht');
    RETURN false;
  end;
  TRANSOFF;

  // Etikett drucken
  RunAFX('WebApp.Pak.EtkDruck',Aint(vPaketNr));
  Log('WebApp_Umlagern Ende');
  RETURN (Errlist = 0);
end;



//========================================================================
//  sub WebApp_PaketAufloesen(aPaketnr : int) : logic
//      Löst ein Materialpaket auf
//========================================================================
sub WebApp_PaketAufloesen(aPaketnr : int; aDruckEtk : logic) : logic
local begin
  Erx     : int;
  i       : int;
  vToken  : alpha;
  vCntMax : int;
  vDelim  : alpha;
  vCnt    : int;

  vArtCharge : alpha;
  vMenge  : float;

  vPaketNr : int;
  vList    : handle;
  vItem    :  handle;
  vTmpMatNr : int;
end
begin
  Log('WebApp_PaketAuflösen Start');

//  if (RunAFX('WebApp.Pak.Del',Aint(aPaketnr)) <> 0) then begin
//    if (AfxRes = 0) then begin
//      RETURN true;
//    end else begin
//      LogErr('Fehler in AFX');
//      RETURN false;
//    end;
//  end;
  Log('WebApp_PaketAuflösen mit Standardfunktionalität');

  Log('Paketnummer: ' + Aint(aPaketnr));
   
   
  // Paket Paket lesen
  Pak.Nummer # aPaketnr;
  Erx # RecRead(280,1,0);
  if (Erx <> _rOK) then begin
    LogErr('Paket nicht gefunden');
    RETURN false;
  end;
  
  
  //2023-01-31 MR Matnummern holen
  vList # CteOpen(_CteList);
  FOR   Erx # RecLink(281,280,1,_RecFirst)
  LOOP  Erx # RecLink(281,280,1,_RecNext)
  WHILE (Erx = _rOK) DO BEGIN

    //vItem -> spName # cnvai(Pak.P.MaterialNr,_FmtNumNoGroup );
    vList->CteInsertItem(cnvai(Pak.P.MaterialNr,_FmtNumNoGroup),Pak.P.MaterialNr, cnvai(Pak.P.MaterialNr,_FmtNumNoGroup));
  END


  // Paket löschen
  TRANSON;
  Log('Paket löschen...');
  Erx # Pak_Data:Delete(_RecUnlock,'MAN');
  if (Erx <> _rOK) then begin
    LogErr('Paket konnte nicht aufgelöst werden. Erg =' + AInt(Erx));
  end;
  Log('...Paket gelöscht');

  if (ErrList <> 0) then begin
    TRANSBRK;
    LogErr('Abbruch mit Fehler');
    RETURN false;
  end;
  TRANSOFF;

  //2023-01-31 MR Etikett drucken
  //2023-07-02 MR 2436/734 P.24
 if (Set.Ein.WE.Etikett <> 0 and aDruckEtk) then begin
    if (RunAFX('WebApp.Pak.Del',Aint(vList)) <> 0) then begin
      Log('Customdruck');
    end;
    else begin
      FOR   vItem # vList->CteRead(_CteFirst)
      LOOP  vItem # vList->CteRead(_CteNext, vItem)
      WHILE (vItem > 0) do begin
        Mat.Nummer # cnvia(vItem->spName);
        Erx # RecRead(200,1,0)
        Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1);
        Log('Etikettendruck...Initiert für ' + vItem->spName );
      END
    end
    vList->CteClose();
    
  end else
    Log('Etikettendruck...nein');
  Log('WebApp_PaketAuflösen Ende');
  RETURN (Errlist = 0);
end;




//========================================================================
//  sub WebApp_MatInventur(aAufnahmetyp : alpha; avEtikettendruckYN : logic, a200 : int; a259 : int) : logic;
//   Verbucht eine WebApp Inventur anfrage
//========================================================================
sub WebApp_MatInventur(aAufnahmetyp : alpha; avEtikettendruckYN : logic; a200 : int; a259 : int) : logic;
local begin
  Erx     : int;
  vNr     : int;
  vMatOld : int;
  
  vNeuesMatEntstanden : logic;
end
begin

  Log('WebApp_MatInventur Start');
  Log('Invneturerg: ' + aAufnahmetyp);
  Log('Inventurdatensatz lesen');
   
  
  vNeuesMatEntstanden  # false;
  // Nur Mengen nachtragen
  Art.Inv.Nummer # a259->Art.Inv.Nummer;
  Erx # RecRead(259,1,0);
  if (Erx = _rOK) then begin
    // Eintrag schon belegt?
    if (Art.Inv.Menge = 0.0) then begin

      // ggf. vorher Material anlegen, falls nicht gefunden
      if (aAufnahmetyp  = 'NoMatNoInv') then begin
        Log('Material neu anlegen');
        RecBufClear(200);
        RecBufCopy(a200,200);   // Übergebene Daten von MDE nutzen

        Mat.Lageradresse    # a259->Art.Inv.Adressnr;
        Mat.Lageranschrift  # a259->Art.Inv.Anschrift;
        Mat.Bestand.Gew     # a259->Art.Inv.Menge;
        Mat.Bestand.Menge   # a259->Art.Inv.Menge;
        Mat.Bestand.Stk     # a259->"Art.Inv.Stückzahl";
        Mat.Lagerplatz      # a259->Art.Inv.Lagerplatz;
        Mat.Bemerkung1      # a259->Art.Inv.Bemerkung;
        Mat.Bemerkung2      # 'Inv MatnrSCan: ' + Aint(a259->Art.Inv.Materialnr);
        Mat.Status          # 998;  // ST 2021-11-08  2222/86/2
        
        //  [+] 07.07.2022 MR Deadlockfix
        Erx # Lib_SOA:ReadNummer('Material', var vNr);
        if(Erx <> _rOk) then begin
          LogErr('Materialnummer konnte nicht generiert werden: ' + Aint(Erx));
          RecBufClear(200);
          Return (Errlist = 0);
        end
        
        if (vNr<>0) then begin
          Lib_SOA:SaveNummer();

          Mat.Nummer # vNr;
          Erx # Mat_Data:Insert(_RecUnlock,'INV',today);
          if (Erx <> _rOK) then begin
            LogErr('Material konnte nicht erstellt werden: ' + Aint(Erx));
            RecBufClear(200);
          end else begin
            Log('Material '+ Aint(MAt.Nummer)+ ' erfolgreich angelegt');
            vNeuesMatEntstanden # true;
          end;


        end else begin
          LogErr('Materialnummer konnte nicht generiert werden: ' + Aint(Erx));
          RecBufClear(200);
        end;
      
      end else begin

        // Material schon gelöscht? Dann neue Karte kopieren und Verweis auf kopie
        Erx # Mat_Data:Read(a259->Art.Inv.Materialnr);
        if (Erx >= 200) AND ("Mat.Löschmarker" = '*') then begin
          Log('Gescanntes Material ' + Aint(a259->Art.Inv.Materialnr) + ' ist schon gelöscht --> Material neu anlegen, aus alter Karte kopieren');

          // 200 hat altes Mat       259 hat neue Mat Daten
          vMatOld # RecBufCreate(200);
          RecBufCopy(200,vMatOld);

          // Inventurdaten in neue Karte schreiben
          "Mat.Löschmarker"   # '';
          "Mat.Lösch.Datum"   # 0.0.0;
          "Mat.Lösch.Grund"   # '';
          "Mat.Lösch.User"    # '';
          "Mat.Lösch.Zeit"    # 0:0;

          Mat.Lageradresse    # a259->Art.Inv.Adressnr;
          Mat.Lageranschrift  # a259->Art.Inv.Anschrift;
          Mat.Bestand.Gew     # a259->Art.Inv.Menge;
          Mat.Bestand.Menge   # a259->Art.Inv.Menge;
          Mat.Bestand.Stk     # a259->"Art.Inv.Stückzahl";
          Mat.Lagerplatz      # a259->Art.Inv.Lagerplatz;
          Mat.Bemerkung1      # a259->Art.Inv.Bemerkung;
          Mat.Bemerkung2      # 'Inv MatnrScan: ' + Aint(a259->Art.Inv.Materialnr);
          Mat.Status          # 998;  // ST 2021-11-08  2222/86/2
          
          //  [+] 07.07.2022 MR Deadlockfix
          Erx # Lib_SOA:ReadNummer('Material', var vNr);
          if(Erx<> _rOK) then begin
            LogErr('Materialnummer konnte nicht generiert werden: ' + Aint(Erx));
            RecBufClear(200);
            RecBufDestroy(vMatOld);
            return (Errlist = 0);
          end
          if (vNr<>0) then begin
            Lib_SOA:SaveNummer();

            Mat.Nummer      # vNr;
            Mat.Ursprung    # vNr;
            "Mat.Vorgänger" # 0;

            Erx # Mat_Data:Insert(_RecUnlock,'INV',today);
            if (Erx <> _rOK) then begin
              LogErr('Material konnte nicht erstellt werden: ' + Aint(Erx));
              RecBufClear(200);
            end else begin
              Log('Material '+ Aint(MAt.Nummer)+ ' erfolgreich angelegt');
              vNeuesMatEntstanden # true;
            end;

          end else begin
            LogErr('Materialnummer konnte nicht generiert werden: ' + Aint(Erx));
            RecBufClear(200);
          end;

          // Material angelegt, jetzt Inventursatz anpassen
          a259->Art.Inv.Bemerkung   # a259->Art.Inv.Bemerkung + ' Aus gel. Mat ' + Aint(vMatOld->Mat.Nummer);
          a259->Art.Inv.Materialnr  # Mat.Nummer;
          RecBufDestroy(vMatOld);
        end;
      end;

    end else
      LogErr('Inventurdaten schon erfasst!');



    // Material angelegt, Inventurdaten nachtragen
    if (ErrList = 0) then begin

      Erx # RecRead(259,1,_RecLock);
      if (Erx = _rOK) then begin
        
        //Art.Inv.Datum       # today;    // ST 2021-12-10 Deaktiviert; Wird beim Verbuchen der Inv gesetzt
        Art.Inv.Bemerkung   # a259->Art.Inv.Bemerkung;
        Art.Inv.Lagerplatz  # a259->Art.Inv.Lagerplatz;
        Art.Inv.Anschrift   # a259->Art.Inv.Anschrift;
        Art.Inv.Menge       # a259->Art.Inv.Menge;
        "Art.Inv.Stückzahl" # a259->"Art.Inv.Stückzahl";

        if (aAufnahmetyp = 'MatInv') then begin

          // Keine Spezialität
        end else
        if (aAufnahmetyp = 'MatNoInv') then begin
          // Material nachtragen
          Art.Inv.Materialnr    # a259->Art.Inv.Materialnr;
          Art.Inv.ChargeFehlte  # true;
        end else
        if (aAufnahmetyp = 'NoMatNoInv') then begin
          // Neu angelegtes Material nachtragen
          Art.Inv.Materialnr    # Mat.Nummer;
          Art.Inv.ChargeFehlte  # true;
        end;

        Erx # RekReplace(259,_RecUnlock);
        if (Erx = _rOK) then begin
          Log('Erfolgreich gebucht');

          // ggf. Etikett drucken
          if (vNeuesMatEntstanden) then begin
            Mat_Data:Read(Art.Inv.Materialnr);
            
            if (Set.Installname = 'BFS') then begin
              Log('BFS Neus Etikett drucken...');
              if (WebApp_DruckEtikett(Aint(Art.Inv.Materialnr),4)) then
                  Log('Neus Etikett drucken...ok');
              else
                LogErr('Fehler bei Etikettendruck ' + Aint(Art.Inv.Materialnr));
            end;
            
          end;

        end else
          LogErr('Inventurdatensatz konnte nicht gespeichert werden: ' + Aint(Erx));
      end else
        LogErr('Inventurdatensatz konnte nicht gesperrt werden : ' + Aint(Erx));

    end;

  end else
    LogErr('Inventurnummer nicht gefunden');

  Log('WebApp_MatInventur Ende');
  RETURN (Errlist = 0);
end;




//========================================================================
//  sub _WebApp_BagAbschluss_CheckFertigmenge() : logic
//   Prüft ob ein Fahrauftrag noch unverbuchte Einsätze hat
//========================================================================
sub _WebApp_BagAbschluss_CheckFertigmenge() : logic
local begin
  Erx           : int;
  vRet          : logic;
  vFail         : logic;
  vFertigBrutto : float;
end;
begin

  Log(' Check Fertigmenge Start BAG.P: ' + Aint(Bag.P.Nummer) + '/' + Aint(Bag.P.Position));

  // Alle Einätze der BAG Position auf Verwiegung prüfen
  vFail # false;
  FOR   Erx # RecLink(701,702,2,_RecFirst)
  LOOP  Erx # RecLink(701,702,2,_RecNext)
  WHILE (Erx = _rOK) AND (vFail = false) DO BEGIN
    if (Rnd(BAG.IO.Ist.In.GewB,0) <> Rnd(BAG.IO.Ist.Out.GewB,0)) then
      vFail # true;
    else
      vFertigBrutto # vFertigBrutto + BAG.IO.Ist.Out.GewB;
  END;

  if (vFail) or (vFertigBrutto = 0.0) then begin
    vRet  # false;

    if (vFail) then
      LogErr('Keine FM zu Mat ' + Aint(BAG.IO.Materialnr));
    else
      LogErr('FM kg Brutto: ' + ANum(vFertigBrutto,0));

  end else begin

    Log('BAG ist ordentlich fertiggemeldet');
    vRet  # true;

  end;

  Log(' Check Fertigmenge ENDE BAG.P: ' + Aint(Bag.P.Nummer) + '/' + Aint(Bag.P.Position));
  RETURN vRet;
end;

//========================================================================
//  sub WebApp_BagAbschluss(a702 : int) : logic;
//   Verbucht einen BAG Abnschluss
//========================================================================
sub WebApp_BagAbschluss(a702 : int) : logic;
local begin
    Erx     : int;
    vNr     : int;
end
begin
  Log('WebApp_BagAbschluss Start');

  Bag.P.Nummer    # a702->BAG.P.Nummer;
  Bag.P.Position  # a702->BAG.P.Position;
  Erx # RecRead(702,1,0);
  if (Erx = _rOK) then begin
    // OK
    Log('Betriebsauftragsposition gelesen ' + Aint(Bag.P.Nummer) + '/' + Aint(Bag.P.Position));

    if (BAG.P.Aktion = c_BAG_Fahr) then begin
        // Lieferschein lesen
        Lfs.zuBA.Nummer     # Bag.P.Nummer;
        Lfs.zuBA.Position   #  BAG.P.Position;
        Erx # RecRead(440,2,0);
        if (Erx <= _rMultiKey) then begin

          // Zusatzplausis bei WebApp Nutzung
          if (_WebApp_BagAbschluss_CheckFertigmenge()) then begin
            //  Alle Mengen sind auf fertiggemeldet
            Log('Fahrauftragsposition erfolgreich abgeschlossen');

            if (Lfs_LFA_Data:Abschluss(today,true)) then begin
              // OK
              Log('Fahrauftragsposition erfolgreich abgeschlossen');
            end else begin
              // Fehler
              LogErr('Fehler bei Fahrauftragabschluss ' + Aint(Bag.P.Nummer) + '/' + Aint(Bag.P.Position));
            end;

          end else begin
            // Fehler
            LogErr('Es sind nicht alle Positionen fertiggemeldet');
          end;

        end else begin
          LogErr('Lieferschein konnte nicht gefunden werden');
        end;

    end else begin

      if (BA1_Fertigmelden:AbschlussPos(Bag.P.Nummer, Bag.P.Position,today,now,true)) then begin
        // OK
        Log('Betriebsauftragsposition erfolgreich abgeschlossen ');
      end else begin
        // Fehler
        LogErr('Fehler bei BA Abschluss ' + Aint(Bag.P.Nummer) + '/' + Aint(Bag.P.Position));
      end;

    end;

  end else begin
    // Fehler
    LogErr('Betriebsauftragsposition konnte nicht gelesen werden: ' + Aint(Erx));
  end;

  Log('WebApp_BagAbschluss ENDE');
  RETURN (Errlist = 0);
end;


//========================================================================
//  sub WebApp_BagFertigmeldungTheo(a702 : int) : logic;
//   Verbucht einen Therotische Fertigmeldung eines Betriebsauftrages
//========================================================================
sub WebApp_BagFertigmeldungTheo(a702 : int) : logic;
local begin
  Erx     : int;
  vNr     : int;
end begin
  Log('WebApp_BagFertigmeldungTheo Start');

  Bag.P.Nummer    # a702->BAG.P.Nummer;
  Bag.P.Position  # a702->BAG.P.Position;
  Erx # RecRead(702,1,0);
  if (Erx = _rOK) then begin
    // OK
    Log('Betriebsauftragsposition gelesen ' + Aint(Bag.P.Nummer) + '/' + Aint(Bag.P.Position));
    if ("BAG.P.Typ.xIn-yOutYN" = false) then begin
      Log('"BAG.P.Typ.xIn-yOutYN" = false');
      RecBufClear(707);
      BAG.FM.Nummer   # BAG.P.Nummer;
      BAG.FM.Position # BAG.P.Position;

      if (BAG.P.Aktion = c_BAG_Fahr) then begin
        // Lieferschein lesen
        Lfs.zuBA.Nummer     # Bag.P.Nummer;
        Lfs.zuBA.Position   #  BAG.P.Position;
        Erx # RecRead(440,2,0);
        if (Erx <= _rMultiKey) then begin
          Log('Fahrauftrag zu Lieferschein ' + Aint(Lfs.Nummer));

          if (Lfs_LFA_Data:GesamtFM(today)) then
            Log('Fahrauftrag erfolgreich fertiggemeldet');
          else
            LogErr('Fehler bei Fahrauftragsfertigmeldung');

        end else begin
          LogErr('Lieferschein konnte nicht gefunden werden');
        end;
      end else begin
        //                                                                Silent,Kein Abschluss
        if (BA1_Fertigmelden:FMTheorie(BAG.FM.Nummer, BAG.FM.Position,today,true,true) ) then
          Log('Betriebsauftragsposition erfolgreich fertiggemeldet');
        else
          LogErr('Fehler bei BA Fertigmeldung ' + Aint(Bag.P.Nummer) + '/' + Aint(Bag.P.Position));
      end

    end else
      LogErr('(702033) ' + 'Diese Position kann nicht theoretisch fertiggemeldet werden,da die Entnahme vom Einsatz zur Fertiung nicht automatisch erkenntlich ist!Bitte manuell fertigmelden!');

  end else begin
    // Fehler
    LogErr('Betriebsauftragsposition konnte nicht gelesen werden: ' + Aint(Erx));
  end;

  Log('WebApp_BagFertigmeldungTheo ENDE');
  RETURN (Errlist = 0);
end;




//========================================================================
//  sub WebApp_BagFertigmeldung(a701 : int; a707 : int) : logic;
//   Verbucht einen Fertigmeldung eines Betriebsauftrages
//========================================================================
sub WebApp_BagFertigmeldung(a701 : int; a707 : int; aCustomInput : alpha(1000)) : logic;
local begin
  Erx         : int;
  vNr         : int;
  v701Output  : int;
end begin
  Log('WebApp_BagFertigmeldung Start');
  
  Log('BAG Daten lesen...');
  v701Output  # RecBufCreate(701);
  if (BA1_FM_Data_SOA:ReadBagData(a701->BAG.IO.Materialnr, a707->BAG.FM.Nummer, a707->BAG.FM.Fertigung, var v701Output) = false) then begin
    LogErr(Translate('Fehler bei Datenermittlung'));
  end else begin
    Log('BAG Daten gelesen:');
    Log(' BAG FM   :' + Aint(BAG.FM.Nummer) + '/' + Aint(BAG.FM.Position) + '/' + Aint(BAG.FM.Fertigung));
    Log(' BAG Outp :' + Aint(v701Output->BAG.IO.ID));
    Log(' Mat/Rest :' + Aint(BAG.IO.Materialnr) +  ' / ' + Aint(BAG.IO.MaterialRstNr));
  
    // BA Daten gelesen, FM Datensatz vorbelegen; Eingabedaten füllem, Berechnungen durchführen
    Log('BAG FM vorbelegen...');
    if (BA1_FM_Data_SOA:FMData_Prepare(var v701Output) = false) then begin
      
      LogErr(Translate('Fehler bei Vorbelegung Fertigmeldedaten'));
    
    end else begin
      Log('BAG FM vorbelegt');
    
      Log('BAG FM Daten einlesen...');
      if (BA1_FM_Data_SOA:FMData_FillFromBuf(var a707) = false) then begin
        
        LogErr(Translate('Fehler beim Einlesen'));
      
      end else begin
        
        //Ergänzung MR Bug (2228/159) ansonsten werden Werte durch Fertigung überschrieben
        BAG.FM.Dicke # a707->BAG.FM.Dicke;
        BAG.FM.Breite # a707->BAG.FM.Breite;
        "BAG.FM.Länge" # a707->"BAG.FM.Länge";
        "BAG.FM.Stück" # a707->"BAG.FM.Stück";
        BAG.FM.Rid # a707->BAG.FM.Rid;
        BAG.FM.Rad # a707->BAG.FM.Rad;
        
        Log('BAG FM Daten eingelesen');
        RunAFX('WebApp.BAG.DataPrep',aCustomInput); // Nur vorübergehende Lösung
        Log('BAG FM Daten validieren...');
        if (BA1_FM_Data_SOA:FMData_Validate() = false) then begin
        
          LogErr(Translate('Fehler bei Validierung'));
        end else begin
          Log('BAG FM Daten validiert');
          
          Log('BAG FM Daten finalisieren...');
          if (BA1_FM_Data_SOA:FMData_Finalize() = false) then begin
            LogErr(Translate('Fehler bei Finalisierung'));
          end else begin
            Log('BAG FM Daten validiert');
            
            Log('Verbuchung Fertigmeldung...mit Etiketten')
            BAG.FM.Menge # a707->BAG.FM.Menge; //2023-08-23 MR 2465/112/1
            if (BA1_Fertigmelden:Verbuchen(true)=false) then begin
              
              LogErr(Translate('Fehler bei Fertigsmeldungsverbuchung'));
            end else begin
              Log('Fertigmeldung erfolgreich verbucht! ')
              
              RunAFX('BAG.FM.Verbuchen.Post','');
              
              // ggf. Abschluss bei Bereitstellen
              if (BAG.P.Aktion=c_BAG_Bereit) then begin
                Log('Bereitstellen abschließen!');
                if (BA1_Fertigmelden:AbschlussPos(BAG.P.Nummer, BAG.P.Position, today, now, true) = false) then begin
                  LogErr(Translate('Fehler bei Abschluss'));
                              
                end else begin
                  Log('Bereitstellen abgeschlossen!');
                  
                end;
                
              end; // EO BEreitstellen Abschluss
               
            end; // EP Verbuchung

          end;  // EO Finalisieren

        end;  // EO Validierung

      end; // EO Einlesen

    end;  // EO Vorbelegen
  
  end; // EO Datgen lesen
 
  RecBufDestroy(v701Output);
  
  Log('WebApp_BagFertigmeldung ENDE');
  
  RETURN (Errlist = 0);
end;


/*
SUB WebApp_BagArbeitsschritteUpdate MR
Fertigmelden für Paketieren
*/
sub WebApp_BagFertigmeldungPaketieren(
  a707          : int;
  a280          : int;
  aInputListe    : alpha(8096);):logic
local begin
  Erx             : int;
  vNr             : int;
  v701Output      : int;
  vTokCnt         : int;
  vTok            : int;
  vTmpString      : alpha;
  vStringBaIoID   : alpha;
  vCteListEinsatz : handle;
  vItem           : handle;
  vStk            : int;
  vFoundMatCnt    : int;
  vMenge          : float;
end
begin
  Log('WebApp_BagFertigmeldung Start');
  
  Log('BAG Daten lesen...');
  //  if (BA1_FM_Data_SOA:ReadBagData(a701->BAG.IO.Materialnr, a707->BAG.FM.Fertigung, var v701Output) = false) then begin
  //    LogErr(Translate('Fehler bei Datenermittlung'));
  //  end else begin
  vCteListEinsatz # CteOpen(_CteTree);
  //Einsatzdaten zusammensetzten
  vTokCnt # Lib_Strings:Strings_Count(aInputListe,'|');
  
  if(vTokCnt >0) then begin
    FOR   vTok # 1
    LOOP  inc(vTok)
    WHILE vTok <= vTokCnt DO BEGIN
      Log('InputListe ' + aInputListe);
      vTmpString # Str_Token(aInputListe,'|',vTok);
      vTmpString # vTmpString + ';';
        
      vItem # CteOpen(_CteItem);
     
      //BAG.IO.Materialnr # cnvia(Str_Token(vTmpString,';',1));
      
      BAG.P.Nummer # a707->"BAG.FM.Nummer"
      BAG.P.Position # a707->"BAG.FM.Position"
      

        
      // Einsatz holen
      FOR Erx # RecLink(701,702,2,_recFirst);
      LOOP Erx # RecLink(701,702,2,_recNext);
      WHILE Erx <=_rLocked DO BEGIN
        Log('Hier bin ich' + cnvai(BAG.IO.Materialnr));
        if(BAG.IO.Materialnr = cnvia(Str_Token(vTmpString,';',1)) ) then begin
          vFoundMatCnt # vFoundMatCnt + 1;
          BREAK;
        end;
       
      END;
      if (vFoundMatCnt = 0) then begin
        LogErr('Materialnr ' + cnvai(BAG.IO.Materialnr) + ' konnte nicht gefunden werden.' + cnvai(Erx));
        Return (Errlist = 0);
      end;
      
     
      vStk # cnvif(cnvfa(Str_Token(vTmpString,';',2)));
      vMenge # cnvfa(Str_Token(vTmpString,';',3), _FmtNumpoint);  // 2023-03-22 AH
//      vMenge # cnvfa(Str_Token(vTmpString,';',3));
      
      vItem->spname   # Aint(BAG.IO.ID);
      vItem->spcustom # AInt(vStk)+'|'+ANum(vMenge, Set.Stellen.Gewicht)+'|'+ANum(vMenge, Set.Stellen.Gewicht);
      vCteListEinsatz->CteInsert(vItem);
    END;
    
    
    
    if(BA1_FM_Data_SOA:ReadBAGDataPaket(a707->"BAG.FM.Fertigung") = false) then begin
      LogErr(Translate('Fehler bei Vorbelegung Fertigmeldedaten'));
      Return (Errlist = 0);
    end
    Log('BAG Daten gelesen:');
    Log(' BAG FM   :' + Aint(BAG.FM.Nummer) + '/' + Aint(BAG.FM.Position) + '/' + Aint(BAG.FM.Fertigung));
    
  
    // BA Daten gelesen, FM Datensatz vorbelegen; Eingabedaten füllem, Berechnungen durchführen
    Log('BAG FM vorbelegen...');
    if (BA1_FM_Data_SOA:FMData_PreparePaket() = false) then begin
      LogErr(Translate('Fehler bei Vorbelegung Fertigmeldedaten'));
    
    end else begin
      Log('BAG FM vorbelegt');
    
      Log('BAG FM Daten einlesen...');
      BAG.FM.Verwiegungart # a707->"BAG.FM.Verwiegungart";
      if (BA1_FM_Data_SOA:FMData_FillFromBuf(var a707) = false) then begin
        
        LogErr(Translate('Fehler beim Einlesen'));
      
      end else begin
        
//        Log('BAG FM Daten eingelesen');
//
//        Log('BAG FM Daten validiert');
//
//        Log('Verbuchung Fertigmeldung...mit Etiketten')
         GV.Alpha.76 # a280->"Pak.Umverpackung";
        if (BA1_Fertigmelden:VerbuchenPaket(0,vCteListEinsatz,true)=false) then begin
          GV.Alpha.76 # '';
          LogErr(Translate('Fehler bei Fertigsmeldungsverbuchung'));
        end else begin
           GV.Alpha.76 # '';
          Log('Fertigmeldung erfolgreich verbucht! ')
              
        end; // EP Verbuchung
      end; // EO Einlesen
    end;  // EO Vorbelegen
  end; // EO Datgen lesen
 
  RecBufDestroy(v701Output);
  
  Log('WebApp_BagFertigmeldung ENDE');
  
  RETURN (Errlist = 0);
end;


/*
SUB WebApp_BagArbeitsschritteUpdate MR
Synct den Stand der Arbeitsschritte zwischen C16 und dem MDE
*/
sub WebApp_BagArbeitsschritteUpdate(
  a706 : int;
  aArbeitsschritt : alpha(8096)) : logic;
local begin
  Erx             : int;
  vTmpString      : alpha(1000);
  vTokCnt         : int;
  vTok            : int;
  vBlockNr        : int;
  vBagNummer      : int;
  vBagPosition    : int;
  vLfdNr          : int;
  vStatus         : int;
  vCheckCnt       : int;
end
begin
  Log('WebApp_BagArbeitsschritteUpdate START');
  vTokCnt # Lib_Strings:Strings_Count(aArbeitsschritt,'|');
  log(aArbeitsschritt);
  log(cnvai(vTokCnt))
  if(vTokCnt >0) then begin
    FOR   vTok # 1
    LOOP  inc(vTok)
    WHILE vTok <= vTokCnt DO BEGIN
      
      vTmpString # Str_Token(aArbeitsschritt,'|',vTok);
      vTmpString # vTmpString + ';';
      vBlockNr # cnvia(Str_Token(vTmpString,';',1));
      vLfdNr # cnvia(Str_Token(vTmpString,';',2));
      vStatus # cnvia(Str_Token(vTmpString,';',3));
      log(cnvai(vStatus));
        
      BAG.AS.Nummer # a706 -> "BAG.AS.Nummer";
      BAG.AS.Position # a706 -> "BAG.AS.Position";
      BAG.AS.Blocknr # vBlockNr;
      BAG.AS.lfdNr # vLfdNr;
     
      Log('Lese Arbeitsschritt' + Aint(BAG.AS.Nummer) + '/' + Aint(BAG.AS.Position) + '/' + Aint(BAG.AS.Blocknr) + '/' + Aint(BAG.AS.lfdNr));
      Erx # RecRead(706,1,0 | _RecLock);
      if (Erx>_rLocked) then begin
        LogErr(Translate('Kein gültiger Arbeitschritt: ' + Aint(BAG.AS.Nummer) + '/' + Aint(BAG.AS.Position) + '/' + Aint(BAG.AS.Blocknr) + '/' + Aint(BAG.AS.lfdNr)));
        BREAK;
      end;
      
      BAG.AS.Status # vStatus;
        
      if(vStatus = 1) then
        vCheckCnt # vCheckCnt +1;
      Log('Verbuche Arbeitsschritt');
      Erx # RekReplace(706,_RecUnlock);
      if (Erx>_rLocked) then begin
        LogErr(Translate('Fehlschlag bei RekReplace.'));
        BREAK;
      end;
    END;
  end;
  
  Log('WebApp_BagArbeitsschritteUpdate ENDE');
  RETURN (ErrList = 0)
end


//========================================================================
//  sub WebApp_DruckEtikett(
//   Druckt ein Etikett für die angegebene Materialnr
//========================================================================
sub WebApp_DruckEtikett(aMats : alpha(4000); aEtk : int;) : logic;
local begin
  Erx     : int;
  i       : int;
    
  vMatsAufEinmal : int;
  vToken  : alpha;
  vCntMax : int;
  vDelim  : alpha;
  vCnt    : int;
  
  vMat    : int;
  vKeys   : alpha(250);
    
end begin
  Log('WebApp_DruckEtikett Start');
  Log('Materialien ' + aMats + '   Etk:' + Aint(aEtk));
  
  Eti.Nummer # aEtk;
  Erx # RecRead(840,1,0);
  if (Erx <> _rOK) then begin
    LogErr('Etikett ' + Aint(aEtk) + ' nicht gefunden');
    RETURN false;
  end;

  vMatsAufEinmal  # 1; ////2023-06-04 MR Multipler Druck bei Holzi gefailed daher zurück auf 1
  Log('Mats auf einmal drucken: ' + Aint(vMatsAufEinmal  ));
 
  vDelim    # ',';
  aMats     # Lib_Strings:Strings_ReplaceEachToken(aMats,'[]{}','');
  vCntMax   # Lib_Strings:Strings_Count(aMats,vDelim) + 1;

  if (RunAFX('WebApp.Etk.Druck',aMats) <> 0) then begin
    Log('Customdruck');
  end;
  else begin
    FOR i # 1
    LOOP inc(i)
    WHILE i <= vCntMax DO BEGIN
      vToken #  Str_Token(aMats,vDelim,i);
      Log('... Mat = ' + vToken);
      if (vToken = '') then
        CYCLE;
              
      Erx # Mat_Data:Read(CnvIa(vToken));
      if (Erx < 200) then begin
        LogErr('Material vToken nicht gefunden');
        RETURN false;
      end;

      Lib_Strings:Append(var vKeys,vToken,',');
      inc(vCnt);
      
      if (vCnt = vMatsAufEinmal) then begin
        Log('Druck...'+vKeys);
        Lib_Dokumente:PrintForm(Eti.Formular.Datei, Eti.Formular.Name, false, '',vKeys);
        vKeys # '';
        vCnt  # 0;
        Winsleep(1000);
      end;
    END;
     if (vKeys <> '') then begin
      Log('Druck.Reste..'+vKeys);
      Lib_Dokumente:PrintForm(Eti.Formular.Datei, Eti.Formular.Name, false, '',vKeys);
    end;
  end;

 

  Log('WebApp_DruckEtikett ENDE');
  RETURN (Errlist = 0);
end;


//========================================================================
//  sub WebApp_RsoKAl_UpdateTage(aTagTypen : alpha(2000);) : logic
//   Aktualisiert Kalendertypeneinträge
//========================================================================
sub WebApp_RsoKAl_UpdateTage(aTagTypen : alpha(4000)) : logic
local begin
  Erx     : int;
  i       : int;
  vToken  : alpha;
  vCntMax : int;
  vDelim  : alpha;
  vCnt    : int;

  vRsoGrp : int;
  vDatum : date;
  vTagTyp : alpha;
end
begin
  Log('WebApp_RsoKAl_UpdateTage Start');

  Log('Tagtypen aktualisieren:' + aTagTypen);

  vDelim    # ';';
  aTagTypen # Lib_Strings:Strings_ReplaceEachToken(aTagTypen,'[]{}','');
  vCntMax   # Lib_Strings:Strings_Count(aTagTypen,vDelim) + 1;

  FOR i # 1
  LOOP inc(i)
  WHILE i <= vCntMax DO BEGIN
    vToken #  Str_Token(aTagTypen,vDelim,i);
    Log('... Tagtyp = ' + vToken);
    if (vToken = '') then
      CYCLE;

    vDatum   # CnvDa(Str_Token(vToken,',',1),_FmtDateYMD);
    vRsoGrp  # CnvIa(Str_Token(vToken,',',2));
    vTagTyp  #       Str_Token(vToken,',',3);
    Log('... Nach Konvertierung: Datum:' + CnvAd(vDatum)  + ' Grp:' + Aint(vRsoGrp)  + ' Typ:'  + vTagTyp);

    Rso.Kal.Gruppe  # vRsoGrp;
    Rso.Kal.Datum   # vDatum;
    Erx # RecRead(163,1,0);
    if (Erx = _rOK) then begin
      Log('Tag erfolgreich gelesen...');
    
      if (vTagTyp <> '') then begin
        Log('....jetzt updaten...');

        // Update Tag
        Erx # RecRead(163,1,_RecLock);
        Rso.Kal.TagTyp # vTagTyp;
             
        Erx # RekReplace(163,_RecUnlock);
        if (Erx <> _rOK) then
          LogErr('Fehler: Tag konnte nicht aktualisiert werden: ' + CnvAd(vDatum) + ' Erg = ' + Aint(Erx));
        else
          Log('Tagtyp gesetzt');
    
      end else begin
         
        Log('....Typ leer, jetzt löschen...');
      
        Erx # RekDelete(163);
        if (Erx <> _rOK) then
          LogErr('Fehler: Tag konnte nicht gelöscht werden: ' + CnvAd(vDatum) + ' Erg = ' + Aint(Erx));
        else
          Log('Tagtyp gelöscht');
                
      end;
    
    end else if (Erx = _rNoKey) then begin
      Log('Tag nicht gefunden ...jetzt inserten');
            
      // Insert Tag
      RecBufClear(163);
      Rso.Kal.Gruppe  # vRsoGrp;
      Rso.Kal.Datum   # vDatum;
      Rso.Kal.TagTyp  # vTagTyp;
      Erx # RekInsert(163,_RecUnlock);
      if (Erx <> _rOK) then
        LogErr('Fehler: Tag konnte nicht eingefügt werden: ' + CnvAd(vDatum) + ' Erg = ' + Aint(Erx));
      else
        Log('Tagtyp eingetragen');
    
    end else begin
      
      LogErr('Fehler: Tag konnte nicht gespeichert werden: ' + CnvAd(vDatum) + ' Erg = ' + Aint(Erx));
    end;
      
  END;

  Log('WebApp_RsoKAl_UpdateTage Ende');
  RETURN (Errlist = 0);
end;




//=========================================================================
//=========================================================================
//=========================================================================