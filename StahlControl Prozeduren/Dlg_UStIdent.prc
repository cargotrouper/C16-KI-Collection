@A+
//===== Business-Control =================================================
//
//  Prozedur  Dlg_UStIdent
//                    OHNE E_R_G
//  Info
//
//
//  18.06.2012  MS  Erstellung der Prozedur
//  18.06.2012  MS  Daten aus Adr_Data von ST uebernommen
//
//  Subprozeduren
//    sub _CheckUstIdentGetAbw(aWert : alpha) : alpha
//    sub _CheckUstIdentGetMsg(aErrCode : int; aGueltigAb : alpha; aGueltigBis : alpha) : alpha
//    sub _CheckUstIdentParseRespExtract(aLine : alpha) : alpha
//    sub _CheckUstIdentParseResp(aFile : alpha(4096); var aErgDatum : alpha; var aErgUhrzeit : alpha; var aErgName : alpha; var aErgOrt : alpha; var aErgPlz : alpha; var aErgStrasse : alpha;  var aGueltigAb : alpha;  var aGueltigBis : alpha;) : int
//    sub _SetIcon(aObj : alpha;  aErg : alpha;)
//    sub _ShowErg(aField : alpha; aErg : alpha; aLabel : alpha; aBtn : alpha; opt aErrorTxt : alpha;)
//    sub _SetLabel(aObj : alpha; aField : alpha;  aErg : alpha;)
//    sub EvtInit(aEvt  : event;
//    sub CheckUstIdent() : logic
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

declare CheckUstIdent() : logic
declare _CheckUstIdentParseResp(aFile : alpha(4096); var aErgDatum : alpha; var aErgUhrzeit : alpha;  var aErgName : alpha;
                               var aErgOrt : alpha; var aErgPlz : alpha; var aErgStrasse : alpha;
                               var aGueltigAb : alpha;  var aGueltigBis : alpha; ) : int


//========================================================================
//  sub _CheckUstIdentGetAbw(aWert : alpha) : alpha
//    Gibt je nach Codierung die entsprechende Meldung zurück
//========================================================================
sub _CheckUstIdentGetAbw(aWert : alpha) : alpha
local begin
  vMsg : alpha;
end;
begin
  vMsg # '';
  case (StrCnv(aWert,_StrUpper)) of
    'A':       vMsg # 'stimmt überein';
    'B':       vMsg # 'stimmt nicht überein';
    'C':       vMsg # 'nicht angefragt';
    'D':       vMsg # 'vom EU-Mitgliedsstaat nicht mitgeteilt';
  end;

  RETURN vMsg;
end;


//========================================================================
//  sub _CheckUstIdentGetMsg(aErrCode : int; aGueltigAb : alpha; aGueltigBis : alpha) : alpha
//          Gibt eine Entsprechende Fehlermeldung je Code zurück
//========================================================================
sub _CheckUstIdentGetMsg(aErrCode : int; aGueltigAb : alpha; aGueltigBis : alpha) : alpha
local begin
  vMsg : alpha (1000);
end;
begin
  // Fehlerprüfung laut Schnittstellenbeschreibung
  case (aErrCode) of
    //  _WinIcoError,_WinIcoInformation,_WinIcoWarning
    200 :
      vMsg # '200 - Die angefragte USt-IdNr. ist gültig.';
    201 :
      vMsg # '201 - Die angefragte USt-IdNr. ist ungültig.';
    202 : begin
      vMsg # '202 - Die angefragte USt-IdNr. ist ungültig. Sie ist nicht in der Unternehmerdatei des betreffenden EU-Mitgliedstaates registriert.';
      vMsg # vMsg + ' Hinweis:Ihr Geschäftspartner kann seine gültige USt-IdNr. bei der für ihn zuständigen Finanzbehörde in Erfahrung bringen.';
      vMsg # vMsg + ' Möglicherweise muss er einen Antrag stellen, damit seine USt-IdNr. in die Datenbank aufgenommen wird.'
      end;
    203 :
      vMsg # '203 - Die angefragte USt-IdNr. ist ungültig. Sie ist erst ab dem ' + aGueltigAb +' gültig.';
    204 :
      vMsg # '204 - Die angefragte USt-IdNr. ist ungültig. Sie war im Zeitraum von ' + aGueltigAb +' bis ' + aGueltigBis +' gültig.';
    205 : begin
      vMsg # '205 - Ihre Anfrage kann derzeit durch den angefragten EU-Mitgliedstaat oder aus anderen Gründen nicht beantwortet werden.';
      vMsg # vMsg + ' Bitte versuchen Sie es später noch einmal. Bei wiederholten Problemen wenden Sie sich bitte an das Bundeszentralamt für Steuern - Dienstsitz Saarlouis.';
      end;
    206 :
      vMsg # '206 - Ihre deutsche USt-IdNr. ist ungültig. Eine Bestätigungsanfrage ist daher nicht möglich. Den Grund hierfür können Sie beim Bundeszentralamt für Steuern - Dienstsitz Saarlouis - erfragen.';
    207 :
      vMsg # '207 - Ihnen wurde die deutsche USt-IdNr. ausschliesslich zu Zwecken der Besteuerung des innergemeinschaftlichen Erwerbs erteilt. Sie sind somit nicht berechtigt, Bestätigungsanfragen zu stellen.';
    208 :
      vMsg # '208 - Für die von Ihnen angefragte USt-IdNr. läuft gerade eine Anfrage von einem anderen Nutzer. Eine Bearbeitung ist daher nicht möglich. Bitte versuchen Sie es später noch einmal.';
    209 :
      vMsg # '209 - Die angefragte USt-IdNr. ist ungültig. Sie entspricht nicht dem Aufbau der für diesen EU-Mitgliedstaat gilt. ( Aufbau der USt-IdNr. aller EU-Länder)';
    210 :
      vMsg # '210 - Die angefragte USt-IdNr. ist ungültig. Sie entspricht nicht den Prüfziffernregeln die für diesen EU-Mitgliedstaat gelten.';
    211 :
      vMsg # '211 - Die angefragte USt-IdNr. ist ungültig. Sie enthält unzulässige Zeichen.';
    212 :
      vMsg # '212 - Die angefragte USt-IdNr. ist ungültig. Sie enthält ein unzulässiges Länderkennzeichen.';
    213 :
      vMsg # '213 - Die Abfrage einer deutschen USt-IdNr. ist nicht möglich.';
    214 :
      vMsg # '214 - Ihre deutsche USt-IdNr. ist fehlerhaft. Sie beginnt mit "DE" gefolgt von 9 Ziffern.';
    215 :
      vMsg # '215 - Ihre Anfrage enthält nicht alle notwendigen Angaben für eine einfache Bestätigungsanfrage (Ihre deutsche USt-IdNr. und die ausl. USt-IdNr.) Ihre Anfrage kann deshalb nicht bearbeitet werden.';
    216 : begin
      vMsg # '216 - Ihre Anfrage enthält nicht alle notwendigen Angaben für eine qualifizierte Bestätigungsanfrage (Ihre deutsche USt-IdNr.,';
      vMsg # vMsg + 'die ausl. USt-IdNr., Firmenname einschl. Rechtsform und Ort). Es wurde eine einfache Bestätigungsanfrage durchgeführt mit folgenden Ergebnis: Die angefragte USt-IdNr. ist gültig.';
      end;
    217 :
      vMsg # '217 - Bei der Verarbeitung der Daten aus dem angefragten EU-Mitgliedstaat ist ein Fehler aufgetreten. Ihre Anfrage kann deshalb nicht bearbeitet werden.';
    218 :
      vMsg # '218 - Eine qualifizierte Bestätigung ist zur Zeit nicht möglich. Es wurde eine einfache Bestätigungsanfrage mit folgendem Ergebnis durchgeführt: Die angefragte USt-IdNr. ist gültig.';
    219 :
      vMsg # '219 - Bei der Durchführung der qualifizierten Bestätigungsanfrage ist ein Fehler aufgetreten. Es wurde eine einfache Bestätigungsanfrage mit folgendem Ergebnis durchgeführt: Die angefragte USt-IdNr. ist gültig.';
    220 :
      vMsg # '220 - Bei der Anforderung der amtlichen Bestätigungsmitteilung ist ein Fehler aufgetreten. Sie werden kein Schreiben erhalten.';
    999 :
      vMsg # '999 - Eine Bearbeitung Ihrer Anfrage ist zurzeit nicht möglich. Bitte versuchen Sie es später noch einmal.';

    otherwise begin
      vMsg # 'Ein Unbekannter Fehler ist aufgetreten.';
    end;
  end; // Case
  return vMsg;
end;


//========================================================================
//  sub _CheckUstIdentParseRespExtract(aLine : alpha) : alpha
//          Extrahiert aus einer übergebenen Zeile, unnötige Daten
//========================================================================
sub _CheckUstIdentParseRespExtract(aLine : alpha) : alpha
local begin
  vRet : alpha;
end
begin
  vRet  # Str_ReplaceAll(aLine, '<value><string>','');
  vRet  # Str_ReplaceAll(vRet, '</string></value>','');
  return vRet;
end;


//========================================================================
//  sub _CheckUstIdentParseResp(
//      aFile : alpha;
//     var aErgDatum : alpha;
//     var aErgUhrzeit : alpha;
//     var aErgName : alpha;
//     var aErgOrt : alpha;
//     var aErgPlz : alpha;
//     var aErgStrasse : alpha;
//     var aGueltigAb : alpha;
//     var aGueltigBis : alpha;
//     ) : int
//
//    Liest die Antwort Datei für die UstIdentnr Prüfung ein und liefert
//    die Ergebnisse zurück
//
//========================================================================
sub _CheckUstIdentParseResp(
  aFile : alpha(4096);
  var aErgDatum : alpha;
  var aErgUhrzeit : alpha;
  var aErgName : alpha;
  var aErgOrt : alpha;
  var aErgPlz : alpha;
  var aErgStrasse : alpha;
  var aGueltigAb : alpha;
  var aGueltigBis : alpha;
  ) : int
local begin
  vErrCode  : int;
  vFileHdl  : int;
  vLine     : alpha(4096);
  vLen      : int;

  vValue          : alpha(4096);
end
begin
  vErrCode # 0;
  aErgDatum   # '';
  aErgUhrzeit # '';
  aErgName    # '';
  aErgOrt     # '';
  aErgPlz     # '';
  aErgStrasse # '';
  aGueltigAb  # '';
  aGueltigBis # '';

  vFileHdl # FsiOpen(aFile,_FsiStdRead);
  if (vFileHdl > 0) then begin

    vFileHdl->FsiMark(10);
    REPEAT
      vLen # vFileHdl->FsiRead(vLine);
      if (vLen = 0) then BREAK;

      if (StrFind(vLine,'ErrorCode',1) > 0) then begin
        vLen # vFileHdl->FsiRead(vLine);
        vValue # _CheckUstIdentParseRespExtract(vLine);
        vErrCode # CnvIa(vValue);
        CYCLE;
      end;

      if (StrFind(vLine,'Erg_Name',1) > 0) then begin
        vLen # vFileHdl->FsiRead(vLine);
        aErgName # _CheckUstIdentParseRespExtract(vLine);
        CYCLE;
      end;

      if (StrFind(vLine,'Erg_Str',1) > 0) then begin
        vLen # vFileHdl->FsiRead(vLine);
        aErgStrasse # _CheckUstIdentParseRespExtract(vLine);
        CYCLE;
      end;

      if (StrFind(vLine,'Erg_PLZ',1) > 0) then begin
        vLen # vFileHdl->FsiRead(vLine);
        aErgPlz # _CheckUstIdentParseRespExtract(vLine);
        CYCLE;
      end;

      if (StrFind(vLine,'Erg_Ort',1) > 0) then begin
        vLen # vFileHdl->FsiRead(vLine);
        aErgOrt # _CheckUstIdentParseRespExtract(vLine);
        CYCLE;
      end;

      if (StrFind(vLine,'Datum',1) > 0) then begin
        vLen # vFileHdl->FsiRead(vLine);
        aErgDatum # _CheckUstIdentParseRespExtract(vLine);
        CYCLE;
      end;

      if (StrFind(vLine,'Uhrzeit',1) > 0) then begin
        vLen # vFileHdl->FsiRead(vLine);
        aErgUhrzeit # _CheckUstIdentParseRespExtract(vLine);
        CYCLE;
      end;

      if (StrFind(vLine,'Gueltig_ab',1) > 0) then begin
        vLen # vFileHdl->FsiRead(vLine);
        aGueltigAb # _CheckUstIdentParseRespExtract(vLine);
        CYCLE;
      end;

      if (StrFind(vLine,'Gueltig_bis',1) > 0) then begin
        vLen # vFileHdl->FsiRead(vLine);
        aGueltigBis # _CheckUstIdentParseRespExtract(vLine);
        CYCLE;
      end;

    UNTIL false;

    vFileHdl->FsiClose();
  end else
    RETURN vFileHdl;

  RETURN vErrCode;
end;

//========================================================================
//  sub _SetIcon()
//          Setzt das Icon zum Ergebnis
//========================================================================
sub _SetIcon(aObj : alpha;  aErg : alpha;)
local begin
  vHdl : int;
end
begin
  vHdl # $Dlg.UStIdent -> WinSearch(aObj);
  if(vHdl <> 0) then begin
    if(aErg = 'A') then
      vHdl -> wpImageTile # _WinImgOK;
    else
      vHdl -> wpImageTile # _WinImgCancel;
  end;
end;

//========================================================================
//  sub _SetLabel()
//          Setzt das Label zum Ergebnis
//========================================================================
sub _SetLabel(aObj : alpha; aField : alpha;  aErg : alpha;)
local begin
  vHdl : int;
  vTxt : alpha;
end
begin
  vHdl # $Dlg.UStIdent -> WinSearch(aObj)
  if(vHdl <> 0) then begin
    vTxt # '';
    Lib_Strings:Append(var vTxt, aField, '');
    Lib_Strings:Append(var vTxt, _CheckUstIdentGetAbw(aErg), ' ');
    vHdl -> wpCaption # vTxt;
    vHdl -> WinUpdate();
  end;
end;

//========================================================================
//  sub _ShowErg()
//          Zeigt das Ergebnis fuer das jeweilige Feld an
// Feld - Erg - Label - Btn
//========================================================================
sub _ShowErg(aField : alpha; aErg : alpha; aLabel : alpha; aBtn : alpha; opt aErrorTxt : alpha;)
local begin
  vHdl : int;
end
begin
  _SetLabel(aLabel, aField, aErg)
  _SetIcon(aBtn, aErg);
end;

//========================================================================
//  sub EvtInit()
//
//
//========================================================================
sub EvtInit(aEvt  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
end
begin
  CheckUstIdent();
end;


//========================================================================
//  sub CheckUstIdent()
//          Prüft ob die Adresse mit der Umsatzsteuerident existent ist
//  Webseiten für Doku:
//  <:http://evatr.bff-online.de/eVatR/xmlrpc/aufbau:>
//  <:http://evatr.bff-online.de/eVatR/xmlrpc/http:>
//  <:http://evatr.bff-online.de/eVatR/xmlrpc/schnittstelle:>
//  <:http://evatr.bff-online.de/eVatR/xmlrpc/codes:>
//  <:http://evatr.bff-online.de/eVatR/xmlrpc/beispiel:>
//========================================================================
sub CheckUstIdent() : logic
local begin
  vBuf100         : int;
  vEigeneUst      : alpha;
  vUrl            : alpha(4096);
  vLocalFile      : alpha(4096);
  vErr            : int;
  vResponseData   : int;
  vRespErrorCode  : int;
  vErgDatum       : alpha;
  vErgUhrzeit     : alpha;
  vErgName        : alpha;
  vErgOrt         : alpha;
  vErgPlz         : alpha;
  vErgStrasse     : alpha;
  vGueltigAb      : alpha;
  vGueltigBis     : alpha;
  vMsg            : alpha(1000);
  vImg            : int;

  vHdl            : int;
end
begin
  // eigene USTIdent aus eigener Adresse lesen
  vBuf100 # RekSave(100);
  Adr.Nummer # Set.eigeneAdressNr;
  if (RecRead(100, 1, 0) = _rOk) then
    vEigeneUst # Adr.USIdentNr;
  RekRestore(vBuf100);

  vUrl # vUrl + 'https://evatr.bff-online.de/evatrRPC?';
  // Für einfache Bestätigung
  vUrl # vUrl + '&UstId_1='    + StrAdj(vEigeneUst,_StrAll);     // Eigene UstIdent, Case Sensitive
  vUrl # vUrl + '&UstId_2='    + StrAdj(Adr.USIdentNr,_StrAll);  // UstIdent, Case Sensitive
  // Ab hier für Qualifizierte Bestätigung
  vUrl # vUrl + '&Firmenname=' + StrCnv(Adr.Name,_StrToUri);       //
  vUrl # vUrl + '&Ort='        + StrCnv(Adr.Ort,_StrToUri);        //
  vUrl # vUrl + '&PLZ='        + StrCnv(Adr.PLZ,_StrToUri);        // optional
  vUrl # vUrl + '&Strasse='    + StrCnv("Adr.Straße",_StrToUri);   // optional
//  vUri # vUri + '&Druck='         + 'ja'; // Optional

  vLocalFile # _Sys->spPathTemp + 'ustident.tmp';
  vErr # Lib_HTTP:DownloadFile(vUrl,vLocalFile);
  if (vErr = _rOK) then begin

    // Datei ist geladen, dann einlesen
    vRespErrorCode # _CheckUstIdentParseResp(vLocalFile, var vErgDatum,var vErgUhrzeit ,var vErgName, var vErgOrt,
                            var vErgPlz,  var vErgStrasse, var vGueltigAb, var vGueltigBis);

    _ShowErg(Adr.Name, vErgName, 'lbNameText', 'btName');
    _ShowErg("Adr.Straße", vErgStrasse, 'lbStrasseText', 'btStrasse');
    _ShowErg(Adr.Ort, vErgOrt, 'lbOrtText', 'btOrt');
    _ShowErg(Adr.PLZ, vErgPLZ, 'lbPLZText', 'btPLZ');
    _ShowErg(Adr.PLZ, vErgPLZ, 'lbPLZText', 'btPLZ');

    $lbUStIdentText -> wpCaption  # Adr.USIdentNr;
    if(vRespErrorCode = 200) then // UStIdent gueltig?
      _SetIcon('btUStIdent', 'A');
    else
      _SetIcon('btUStIdent', 'X');
    $lbErrorText -> wpCaption # _CheckUstIdentGetMsg(vRespErrorCode, vGueltigAb, vGueltigBis);


    // GGf. hier die geprüften Daten speichern/archivieren
    FsiDelete(vLocalFile);

  end else begin
     $lbErrorText -> wpCaption # 'Die Verbindung zum Prüfungsserver konnte nicht hergestellt werden.';
  end;

end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt          : event;        // Ereignis
  aFocusObject  : int           // vorheriges Objekt
) : logic
local begin
  vTmp  : int;
end;
begin
  if (aEvt:Obj->Wininfo(_WinType)=_WinTypeCheckbox) then
    aEvt:Obj->wpColBkg # Set.Col.Field.Cursor
  else
    aEvt:Obj->wpColFocusBkg # Set.Col.Field.Cursor;

end;


//========================================================================
//  EvtFocusTerm
//            Fokus von Objekt wegnehmen
//========================================================================
sub EvtFocusTerm (
  aEvt          : event;        // Ereignis
  aFocusObject  : int           // nachfolgendes Objekt
) : logic
begin
  aEvt:Obj->wpColBkg # _WinColParent;
  RETURN true;
end;


//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt        : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  RETURN true;
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt      : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
//  Main
//
//
//========================================================================
MAIN()
local begin
  vHdl  : int;
end
begin
  vHdl # WinOpen('Dlg.UStIdent', _WinOpenDialog);
  WinDialogRun(vHdl, _WinDialogcreatehidden | _WinDialogCenterScreen);
  WinClose(vHdl);
end;



//========================================================================