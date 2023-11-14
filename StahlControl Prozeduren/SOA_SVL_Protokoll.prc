@A+
//==== Business-Control ===================================================
//
//  Prozedur    SOASVL_Protokoll
//                          OHNE E_R_G
//  Info
//        Implementerung der Protokollierung des Servicelayers
//
//  07.09.2010  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    sub prtRequest( aRequest : handle; aSocket : handle; aTask : handle) : int
//    sub prtResponse(aID : int;  aResponse : handle) : int
//    sub prtExec(aID : int;  aError : int; aRuntime : int) : int
//
//
//=========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA

declare prtRequest(aRequest : handle; aSocket : handle; aTask : handle) : int
declare prtResponse(aID : int; aResponse : handle; aRespLength : int;
          aError : int; aRuntime : int; opt aNoXmlOutput : logic): int
declare prtExtern(aID : int; aData : handle; opt aOutput : logic) : int

//=========================================================================
//  sub prtRequest(...) : int
//
//  Protokolliert den Request
//
//  @Param
//    aRequest : handle     // Handle des Requestobjektes
//    aSocket  : handle     // Socket zur Verbindung
//    aTask    : handle     // Task des C16 SOA Servers
//
//  @Return
//    int                   // ID des Protokolleintrages, negativ wenn Fehler
//
//=========================================================================
sub prtRequest( aRequest : handle; aSocket : handle; aTask : handle) : int
local begin
  vErg          : handle; // Ergebnisspeicher
  vRet          : int;    // Rückgabewert der Funktion
  vProtID       : int;    // Id des Protokolleintrages
  vTxt          : handle; // Handle für internen Text
  vNodeRequest  : handle; // Node für Requestknoten
  vNodeHeader   : handle; // Node für Headerknoten
  vNodeArgs     : handle; // Node für Argumenteknoten
end
begin

  // Vorbelegung für allgemeinen Fehlerfall
  vRet # errSVL_Prot;

  // Wichtige Knoten lesen
  vNodeRequest  # aRequest->    CteRead(_CteSearch | _CteFirst ,0, 'REQUEST');
  vNodeHeader   # vNodeRequest->CteRead(_CteSearch | _CteFirst ,0, 'HEADER');
  vNodeArgs     # vNodeRequest->CteRead(_CteSearch | _CteFirst ,0, 'ARGS');

  // Überlauf bei Eval Lizenz verhindern
  if (RecInfo(965,_RecCount) > 999) then begin
    RekDeleteAll(965);
  end;

  // Protokolleintrag erstellen
  vErg # RecRead(965,1,_RecLast)
  vProtID # SOA.Prt.Nummer + 1;         // Neue ID Vergeben
  RecBufClear(965);                     // Puffer für Neuanlage leeren

  // Hauptdaten
  SOA.Prt.Nummer  # vProtID;            // Identifikation des Prot.eintrages
  SOA.Prt.TaskId  # UserId(_UserCurrent);

  // Requestdaten
  SOA.Prt.Req.Datum->vmSystemTime();    // Serverdatum bei Anfrage
  SOA.Prt.Req.Uhrzeit->vmSystemTime();  // Serverzeit bei Anfrage
  SOA.Prt.Req.Service # toUpper(GetValue(vNodeArgs,'SERVICE'));
  SOA.Prt.Req.Method  # GetValue(vNodeHeader,'METHOD');
  // dbg: bei manuellen Testes gibts keine Sockets, später rausbauen
  if (aSocket <> 0) then begin
    SOA.Prt.Req.IP      # aSocket->SckInfo( _sckAddrPeer);
    SOA.Prt.Req.Length  # CnvIA(aSocket->SckInfo( _SckVolRead));
  end;

  // Ausführungsdaten
  SOA.Prt.Ausf.User   # GetValue(vNodeArgs,'SENDER');
  SOA.Prt.Ausf.Key    # GetValue(vNodeArgs,'KEY');

  // Datensatz Speichern
  vErg # RekInsert(965,_RecUnlock,'AUTO');
  if (vErg = _rOK) then begin

    vRet # prtExtern(vProtID, aRequest);
    // Wenn alles erfolgreich war, dann Protokollid zurückgeben
    if (vRet = _rOK) then
      vRet  # vProtID
    else
      vRet # vRet *-1;

  end else
    vRet # errSVL_Prot_Insert * -1;

  return vRet;
end; // sub prtRequest( ...)


//=========================================================================
//  sub prtResponse(...) : int
//
//  Protokolliert den Response
//
//  @Param
//    aID           : int     // ID des Protokolleintrages
//    aResponse     : handle  // Handle des Responsespeicherobjektes
//    aRespLength   : int     // Länge der Antwort in Bytes
//    aError        : int     // Fehlercode der Ausführung
//    aRuntime      : int     // Dauer der Ausführungszeit
//
//  @Return
//    int                     // Fehlercode
//
//=========================================================================
sub prtResponse(
    aID           : int;    // ID des Protokolleintrages
    aResponse     : handle; // Handle des Responsespeicherobjektes
    aRespLength   : int;    // Länge der Antwort in Bytes
    aError        : int;    // Fehlercode der Ausführung
    aRuntime      : int;    // Dauer der Ausführungszeit
    opt aNoXmlOutput : logic; // Falls Ausgabe nicht XML
) : int
local begin
  vRet    :   int;      // Rückgabewert der Funktion
end
begin
  // Vorbelegung für allgemeinen Fehlerfall
  vRet # errSVL_Prot;

  // Protokolleintrag updaten
  Soa.Prt.Nummer # aID;
  if (RecRead(965,1,_RecLock) = _rOk) then begin

    // Responsedaten füllen
    SOA.Prt.Rsp.Datum->vmSystemTime();      // Serverdatum bei Antwort
    SOA.Prt.Rsp.Uhrzeit->vmSystemTime();    // Serverzeit bei Antwort
    SOA.Prt.Rsp.Length  # aRespLength;       // Größe der Antwort

    // Ausführungsdaten füllen
    SOA.Prt.Ausf.Fehler   # aError;         // Fehlercode
    SOA.Prt.Ausf.Laufzei  # aRuntime;       // Laufzeit der Anfrage

    // Datensatz Speichern
    if (RekReplace(965,_RecUnlock,'AUTO') = _rOK) then begin
      //vRet  # _rOK;
      if ( !aNoXmlOutput ) then
        vRet # prtExtern(aID, aResponse, true);
    end
    else
      vRet # errSVL_Prot_Update;

  end else
      vRet # errSVL_Prot_ReadLock;

  return vRet;

end; // prtResponse(...)



//=========================================================================
//  sub prtExtern(...) : int
//
//  Schreibt den Inhalt eines XML Nodes als Prokokollfile
//
//  @Param
//    aID           : int     // ID des Protokolleintrages
//    aData         : handle  // Handle des Datenobjektes
//    opt aOutput   : logic   // Flag ob File mit Response postfix
//
//  @Return
//    int                     // Fehlercode
//
//=========================================================================
sub prtExtern(aID : int; aData : handle; opt aOutput : logic) : int
local begin
  vRet  : int;
  vDirCheck : handle;
  vType : alpha;
  vFile : alpha(1000);
  vPath : alpha;
  vNode : handle;
end;
begin

  // prüfen ob das Log Verzeichnis vorhanden ist
  vPath # Set.Soa.Path+'log\';
  vDirCheck # FsiDirOpen(vPath, _FsiAttrDir);
  if (vDirCheck = 0) then begin

    // Versuchen das Verzeichnis anzulegen
    if (FsiPathCreate(vPath) <> _rOK) then
      vRet # errSVL_Prot_LogFileDir;

  end else begin
    // !!! Verzeichnis ist vorhanden...

    // Postfix wählen
    vType # '_req';
    if (aOutput) then
      vType # '_resp';

    // Dateipad und Namen zusammenbauen
    vFile # vPath + CnvAi(aID,_FmtInternal) + vType+ '.xml';

    // File sichern
    if (XmlSave(aData,vFile,_XmlSaveDefault) = _rOK) then
      vRet # _rOK;
    else
      vRet # errSVL_Prot_LogFile;

  end;

  return vRet;
end; // sub prtExtern(...) : int


//=========================================================================
//=========================================================================
//=========================================================================