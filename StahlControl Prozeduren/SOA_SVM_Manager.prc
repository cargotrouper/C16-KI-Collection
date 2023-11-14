@A+
//==== Business-Control ===================================================
//
//  Prozedur    SOA_SVM_Manager
//                    OHNE E_R_G
//  Info
//        Implementerung des Servicemangementes
//
//  07.09.2010  ST  Erstellung der Prozedur
//  09.03.2015  ST  "sub init" in "process" umbenannt
//  19.11.2018  ST  Usergruppe "SOA_Server" / Sending User integriert
//
//  Subprozeduren
//    sub process( aRequest : handle; var aResponse : handle) : int
//    sub checkArgs(aArgs : handle) : int
//    sub checkServiceAuth(aSvc : alpha; aUsr : alpha; aKey : alpha) : int
//    sub checkSender(aSender : alpha; var aFile : int) : int
//    sub checkServiceAPI(aArgs : handle; var aResponse : handle) : int
//
//
//=========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA

declare checkArgs(aArgs : handle) : int
declare checkServiceAuth(aSvc : alpha; aUsr : alpha; aKey : alpha) : int
declare checkSender(aSender : alpha; var aFile : int) : int
declare checkServiceAPI(aArgs : handle; var aResponse : handle) : int


//=========================================================================
//  sub process(...) : int
//
//  Initialisiert und führt eine Serviceanfragedurch
//
//  @Param
//    aRequest  : handle     // Handle des Requestobjektes
//    aResponse : handle     // Handle des Responseobjektes
//
//  @Return
//    int                    // Fehlercode
//
//=========================================================================
sub process( aRequest : handle; var aResponse : handle) : int
local begin
  vNodeRequest  : handle; // Node für Requestknoten
  vNodeArgs     : handle; // Node für Argumenteknoten
  vErg          : int;    // Ergebnishandle
end
begin
  // --------------------------------------
  // Argumente Prüfen

  // Knoten lesen
  vNodeRequest  # aRequest->getNode('REQUEST');
  vNodeArgs     # vNodeRequest->getNode('ARGS');

  // Prüfung der Anfrage und Service
  vErg # checkArgs(vNodeArgs);
  if (vErg <> _rOk) then
    return vErg;

  // Service API Prüfen
  vErg # CheckServiceAPI(vNodeArgs, var aResponse);
  if (vErg <> _rOk) then
    return vErg;

  // Service aufrufen
  vErg # Call(SOA.Inv.Prozedur + ':exec',vNodeArgs, var aResponse);
  if (vErg <> _rOk) then
    return vErg;

end; // sub process(...)


//=========================================================================
// execMemory
//        Führt die execMemory Prozedur eines Services aus.
//=========================================================================
sub execMemory ( aRequest : handle; var aMemObj : handle; var aContentType : alpha ) : int
local begin
  vNodeRequest : handle;
  vNodeArgs    : handle;
end
begin
  vNodeRequest # aRequest->getNode( 'REQUEST' );
  vNodeArgs    # vNodeRequest->getNode( 'ARGS' );

  // Service
  RETURN Call( SOA.Inv.Prozedur + ':execMemory', vNodeArgs, var aMemObj, var aContentType );
end;


//=========================================================================
//  sub checkArgs(...)
//
//  Prüft die übergebenen Argumente auf Vollständigkeit und Konformität
//
//  @Param
//    aArgs     : handle      // Handle des Argumentenobjekts
//
//  @Return
//    int                     // Fehlercode
//
//=========================================================================
sub checkArgs(aArgs : handle) : int
local begin
  vService      : alpha;      //  angefragter Service
  vSender       : alpha;      //  Sender der Anfrage
  vKey          : alpha(250); //  Schlüssel der Anfrage
  vFile         : int;        //  Dateinummer des Benutzers (Adresse,Ansprechpartner,Verband/Vertreter)
  vErg          : int;        //  Ergebnishandle
end
begin


//XmlSave(aArgs,Set.Soa.Logdir+'CheckArgs.xml',_XmlSaveDefault);

// XmlSave(aArgs,Set.Soa.Logdir+'CheckArgs.xml',_XmlSaveDefault);


  // -------------------------------------------
  // Service extrahieren
  vService # GetValue(aArgs,'SERVICE');
  // --> Fehlerfall 1: Kein Service angegeben
  if (isEmpty(vService)) then
    return errSVM_noService;

  // -------------------------------------------
  // Sender extrahieren
  vSender # GetValue(aArgs,'SENDER');
  // --> Fehlerfall 1: Kein Sender angegeben
  if (isEmpty(vSender)) then
    return errSVM_noUser;

  // -------------------------------------------
  // Key extrahieren, wird ggf. nicht verwendet
  vKey # GetValue(aArgs,'KEY');

  // Service Überprüfen
  vErg # CheckServiceAuth(vService,vSender,vKey);
  if (vErg <> 0) then
    return vErg;

  // Alles IO
  return _rOk;

end; // sub checkArgs(...)


//=========================================================================
//  sub checkServiceAuth(...) : int
//
//  Überprüft einen vorhandenen Service auf Ausführbarkeit, liest den
//  Servicebenutzer und prüft ggf. die Authorisierung
//
//  @Param
//    aSvc      : alpha      // Name des Services
//    aUsr      : alpha      // Benutzerkennung
//    aKey      : alpha      // Schlüssel des Benutzers
//
//  @Return
//    int                    // Fehlercode
//
//=========================================================================
sub checkServiceAuth(aSvc : alpha; aUsr : alpha; aKey : alpha) : int
local begin
  vFile       : int;
  vKeyCheck   : alpha(250);
  vErg        : int;
end
begin

  // ------------------------------------
  // Service im Inventar suchen
  RecBufClear(960);
  SOA.Inv.Ident # toUpper(aSvc);
  // --> Fehlerfall 1: nicht vorhanden
  if (RecRead(960,1,0) <> _rOK) then
    return errSVM_ServiceUnknown;

  // --> Fehlerfall 2: Service ist inaktiv
  if (!SOA.Inv.AktivJN) then
    return errSVM_ServiceLocked;

  // --> Fehlerfall 3: Service hat keine Prozedur eingetragen
  if (isEmpty(SOA.Inv.Prozedur)) then
    return errSVM_ServiceProc;

  // ------------------------------------
  // Serviceauthorisierung
  vErg # checkSender(aUsr, var vFile);
  // --> Fehlerfall 1: User nicht vorhanden, wird in checkSender abgefragt
  if (vErg <> _rOK) OR (vFile = 0) then
    return vErg;

  // ------------------------------------
  // Service ist nicht öffentlich?
  if !("SOA.Inv.ÖffentlichJN") then begin

    RecBufClear(961);
    SOA.Usr.ServiceIdent # SOA.Inv.Ident;

    // Schlüssel je nach Typ vorbelegen / der entsprechende
    // Puffer für den Key ist schon geladen
    case (vFile) of
      100 : begin
              SOA.Usr.Adressnr      # Adr.Nummer;
              vKeyCheck             # Adr.ServiceKey;
            end;
      102 : begin
              SOA.Usr.Adressnr      # Adr.P.Adressnr;
              SOA.Usr.Ansprechpart  # Adr.P.Nummer;
              vKeyCheck             # Adr.P.ServiceKey;
            end;
      110 : begin
              SOA.Usr.Vertreternr   # Ver.Nummer;
              vKeyCheck             # Ver.ServiceKey;
            end;
    end;

    vErg # RecRead(961,1,0);

    // --> Fehlerfall 1: User nicht berechtigt
    if (vErg >= _rNoRec) then begin
      RecBufClear(960);
      return errSVM_notAllowed;
    end;

    // --> Fehlerfall 2: Kein Key hinterlegt
    if (isEmpty(vKeyCheck)) then begin
      RecBufClear(960);
      return errSVM_noKeySC;
    end;


    // --> Fehlerfall 3: Key stimmt nicht überein
    if (vKeyCheck <> aKey) then begin
      RecBufClear(960);
      return errSVM_AuthFailed;
    end;

  end; // if !("SOA.Inv.ÖffentlichJN")

  // Alles IO
  return _rOK;

end; // sub checkServiceAuth(...)


//=========================================================================
//  sub checkSender(...) : int
//
//  Überprüft ob ein Sender in den Stammdaten vorhanden ist
//
//  DESIGNENTSCHEIDUNG:
//    Sollte ein Fehler bei der Benutzerautorisierung enstehen, wird eine
//    globale Exception geworfen, damit der "Angreifer" keine Informationen
//    über das Anmeldeverfahren enthält.
//
//  @Param
//        aSender : alpha     // Senderkennzeichnung
//    var aFile   : int       // Referenz auf Zieldatei des Nutzers
//
//  @Return
//    int                     // Fehlercode
//
//=========================================================================
sub checkSender(aSender : alpha; var aFile : int) : int
local begin
  vType    : alpha;
end
begin
  // Zieldateipuffer leeren, wird von Methode gefüllt
  RecBufClear(100);
  RecBufClear(102);
  RecBufClear(110);
  aFile # 0;

  // Benutzertyp extrahieren
  if (Strlen(aSender) < 1) then
    // --> Fehlerfall 1: Benutzerangabe zu kurz
    return errSVM_AuthFailed;

  // Benutzertyp extrahieren
  vType # toUpper(StrCut(aSender,1,1));

  // Korrekter Benutzertyp?
  if (vType <> 'A') AND (vType <> 'V')  then
    // --> Fehlerfall 2: Unbekannter Sendertyp
    return errSVM_AuthFailed;

  // Adresse,Anschrechpartner oder Verband,Vertreter?
  if (vType = 'A') then begin
    // Adresse oder Ansprechpartner
    // Ein Ansprechpartner hat nachfolgend der Adressnummer
    // zusätzlich einen '/' angehängt, folgend von seiner indivduellen
    // Ansprechpartner ID
    if (StrFind(aSender,'/',1) > 1) then begin

      // Benutzer ist Ansprechpartner

      // Ansprechpartner ID extrahieren
      Adr.P.Adressnr # CnvIa( Lib_Strings:Strings_Token(aSender,'/',1));
      Adr.P.Nummer   # CnvIa( Lib_Strings:Strings_Token(aSender,'/',2));
      if (RecRead(102,1,0) <= _rLocked) then begin
        // Ansprechpartner gefunden
        aFile # 102;
      end else
        return errSVM_AuthFailed;

    end else begin
      // Benutzer ist eine Adresse
      RecBufClear(100);
      Adr.Nummer # CnvIa(aSender);
      if (RecRead(100,1,0) <= _rLocked) then begin
        // Adresse gefunden
        aFile # 100;
      end else
        return errSVM_AuthFailed;
    end;

  end else begin

    // Vertreter oder Verband lesen
    RecBufClear(110);
    Ver.Nummer # CnvIa(aSender);
    if (RecRead(110,1,0) <= _rLocked) then begin
      // Vertreter oder Verband gefunden
      aFile # 110;
    end else
      return errSVM_AuthFailed;

  end;

  // Alles IO
  return _rOk;

end; // sub checkSender(...)


//=========================================================================
//  sub checkServiceAPI(...) : int
//
//  Überprüft die übergebenen Argumente mit der entsprechenden ServiceAPI
//
//  @Param
//        aArgs     : handle    //  Argumente zur Überprüfung
//    var aResponse : handle    //  Referenz auf Antwortobjekt
//
//  @Return
//    int                       // Fehlercode
//
//=========================================================================
sub checkServiceAPI(aArgs : handle; var aResponse : handle) : int
local begin
  vApi        : handle;       // Handle für Api aus Service
  vErg        : int;
end
begin

  // gegen Serviceapi prüfen (Serviceintrag ist geladen)
  if (isEmpty(SOA.Inv.Prozedur)) then
    return errSVM_ServiceProc;

  // API-Beschreibung lesen
  vApi # Call(SOA.Inv.Prozedur + ':api'); // TODO
  if (vApi = 0) then
    // Fehler beim Lesen der Api
    return errSVL_Allgemein;

  // ---------------------------------------------
  //  Pflichtfeldprüfung
  vErg # SOA_SVM_API:checkPflichtfelder(vApi, aArgs, var aResponse);
  if (vErg <> _rOk) then
    return vErg;

  // ---------------------------------------------
  //  Feldtypen und Wertebereichsprüfung
  vErg # SOA_SVM_API:checkRules(vApi, aArgs, var aResponse);
  if (vErg <> _rOk) then
    return vErg;

  // ---------------------------------------------
  // Keine Fehler gefunden --> API OK
  return _rOK;

end; // sub checkServiceAPI(...)


//=========================================================================
//=========================================================================
//=========================================================================
