@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_000046
//                  OHNE E_R_G
//  Zu Service: EIN_POS_WE_ONVSB
//
//  Info
///  EIN_POS_WE_ONVSB: Legt einen Materialeingang zu einem bestehenden VSB Eintrag an
//
//  02.05.2011  ST  Erstellung der Prozedur
//  28.11.2011  ST  Umstellung der Buchung von VSB->EINGANG Positionen
//  10.04.2013  AI  MEH
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
@I:Def_Aktionen

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
end;

declare _VSB2Eingang(aEingang : int) : logic


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

  // Materialnummer
  vNode # vApi->apiAdd('Materialnr',_TypeInt,true);
  vNode->apiSetDesc('Eindeutige Materialnummer des VSB/EK Eintrages','124102');

  // Bestellnummer
  vNode # vApi->apiAdd('Bestellnummer',_TypeInt,false);
  vNode->apiSetDesc('Bestellnummer zum Materialeingang','123104');

  // Bestellposition
  vNode # vApi->apiAdd('Bestellposition',_TypeInt,false);
  vNode->apiSetDesc('Bestellposition zum Materialeingang','3');

  // Eingangsdatum
  vNode # vApi->apiAdd('Datum',_TypeDate,true);
  vNode->apiSetDesc('Eingangdatum','25.09.2011');

  // Gewicht
  vNode # vApi->apiAdd('Gewicht',_TypeFloat,true);
  vNode->apiSetDesc('Gewicht des Coils','5000.00');

  // Lagerplatz
  vNode # vApi->apiAdd('Lagerplatz',_TypeAlpha,false);
  vNode->apiSetDesc('Lagerplatz des eingegangenen Coils','HALLE1');

  // Dicke IST
  vNode # vApi->apiAdd('DickeIst',_TypeFloat,false);
  vNode->apiSetDesc('Gemessene Coildicke','2.89');

  // Breite IST
  vNode # vApi->apiAdd('BreiteIst',_TypeFloat,false);
  vNode->apiSetDesc('Gemessene Coilbreite','1202.05');


    // ----------------------------------
  // ApiBeschreibung zurückgeben
  return vAPI;

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

  // Ablaufvariablen
  vErg        : int;        // Ergebnishandle
  vTmp        : alpha;
  vErr        : int;
  vOK         : logic;

  // Argument, fachliche Seite
  vMatNr      : int;
  vEinNr      : int;
  vEinPos     : int;
  vDatum      : date;
  vGew        : float;
  vLpl        : alpha;
  vDIst        : float;
  vBIst        : float;

  vEingang  : int;
  // Rückgabedaten
  vErgNode    : handle;     // Handle für Antwort

  // für Gruppe ALLE
  vDatei  : int;
  vTds    : int;
  vTdsCnt : int;
  vFld    : int;
  vFldCnt : int;
  vFldData   : alpha(4096);

  vFldName  : alpha;
  vChkName  : alpha;
  Erx       : int;
end
begin
  Lib_Soa:Allocate();  // Datenbereiche allokieren
  vErr # 0;


  RecBufClear(506);

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  // Materialnummer
  vMatNr    # CnvIA(aArgs->getValue('Materialnr'));
  vEinNr    # CnvIA(aArgs->getValue('Bestellnummer'));
  vEinPos   # CnvIA(aArgs->getValue('Bestellposition'));
  vDatum    # CnvDa(aArgs->getValue('Datum'));
  vGew      # CnvFA(aArgs->getValue('Gewicht'));
  vLpl      #       aArgs->getValue('Lagerplatz');
  vDIst     # CnvFA(aArgs->getValue('DickeIst'));
  vBIst     # CnvFA(aArgs->getValue('BreiteIst'));


  // Material vorhanden?
  RecBufClear(200);
  Mat.Nummer # vMatNr;
  if (RecRead(200,1,0) <> _rOK) then begin
    // Material nicht gefunden
    aResponse->addErrNode(errSVL_Allgemein,'Materialnummer ist unbekannt');
    inc(vErr);
  end;

  // Bestellung vorhanden?
  RecBufClear(501);
  Ein.P.Nummer    # vEinNr;
  Ein.P.Position  # vEinPos;
  if (RecRead(501,1,0) <> _rOK) then begin
    // Bestellung nicht gefunden
    aResponse->addErrNode(errSVL_Allgemein,'Bestellnummer ist nicht im Bestand');
    inc(vErr);
  end;

  // Wareneingangseintrag lesen
  Ein.E.Materialnr  # vMatNr;
  Erx # RecRead(506,2,0);
  if (Erx <> _rOK) AND (Erx <> _rMultiKey) then begin
    aResponse->addErrNode(errSVL_Allgemein,'VSB Eingangseintrag konnte nicht gefunden werden');
    inc(vErr);
  end;

  // Passt Bestellung zum Eingang
  if (Ein.E.Nummer <> Ein.P.Nummer) or (Ein.E.Position <> Ein.P.Position) then begin
    aResponse->addErrNode(errSVL_Allgemein,'Bestellung passt nicht zum VSB-Eingang');
    inc(vErr);
  end;


  if (vErr > 0) then
    RETURN errPrevent;


//  vEingang  # Ein.E.Eingangsnr;
  TRANSON;

  // --------------------------------------------------------------------------
  // Wareneingangsdaten belegen

  RecRead(506,1,0);

  // Bestellung lesen
  RecLink(501,506,1,0);

  Ein.E.EingangYN     # y;
  Ein.E.VSBYN         # n;
  Ein.E.Materialnr    # 0;

  Ein.E.Eingang_Datum   # vDatum;
  Ein.E.EingangYN       # true;
  Ein.E.Eingang_Datum   # vDatum;
  "Ein.E.Stückzahl"     # 1;
  Ein.E.LAgerplatz      # vLpl;
  if (vDIst <> 0.0) then
    Ein.E.Dicke           # vDIst;

  if (vBIst <> 0.0) then
    Ein.E.Breite          # vBIst;

  Ein.E.Gewicht         # vGew;
  Ein.E.Gewicht.Netto   # Ein.E.Gewicht;
  Ein.E.Gewicht.Brutto  # Ein.E.Gewicht;
  Ein.E.Menge           # Ein.E.Gewicht;

  "Ein.E.Menge"     # Lib_Berechnungen:KG_aus_StkDBLWgrArt(
                        "Ein.E.Stückzahl",
                        "Ein.E.Dicke",
                        "Ein.E.Breite",
                        "Ein.E.Länge",
                        "Ein.E.Warengruppe",
                        "Ein.E.Güte",
                        "Ein.E.Artikelnr");


  vOK # _VSB2Eingang(Ein.E.Eingangsnr);
  if (vOK = false) then begin
    TRANSBRK;
    aResponse->addErrNode(errSVL_Allgemein,'Eingang konnte nicht aktualisiert werden');
    RETURN errPrevent;
  end;

  TRANSOFF;

/*
  // ALTE VERSION!!!!!

  TRANSON;

  ProtokollBuffer[506] # RecBufCreate(506);

  RecRead(506,1,_RecLock);

  Ein.E.EingangYN       # true;
  Ein.E.Eingang_Datum   # vDatum;
  Ein.E.Gewicht         # vGew;
  Ein.E.Gewicht.Netto   # Ein.E.Gewicht;
  Ein.E.Gewicht.Brutto  # Ein.E.Gewicht;
  Ein.E.Menge           # Ein.E.Gewicht;
  Ein.E.Lagerplatz      # vLpl;
  "Ein.E.Stückzahl"     # 1;
  Ein.E.Dicke           # vDIst;
  Ein.E.Breite          # vBIst;

  erx RekReplace(506,_recUnlock,'MAN');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    RecBufDestroy(ProtokollBuffer[506]);
    aResponse->addErrNode(errSVL_Allgemein,'Eingang konnte nicht aktualisiert werden');
    RETURN errPrevent;
  end;

  // Vorgang buchen
  if (Ein_E_Data:Verbuchen(n)=false) then begin
    TRANSBRK;
    RecBufDestroy(ProtokollBuffer[506]);
    aResponse->addErrNode(errSVL_Allgemein,'Eingang konnte nicht verbucht werden');
    RETURN errPrevent;
  end;
  RecBufDestroy(ProtokollBuffer[506]);

  TRANSOFF;

*/
  // Alles IO gelaufen, dann Erfolg mit entsprechenden Daten melden
  vNode # aResponse->getNode('DATA');
  vNode->Lib_XML:AppendNode('Ergebnis',  'OK');
  vNode->Lib_XML:AppendNode('Material',  Aint(Ein.E.Materialnr));


  // --------------------------------------------------------------------------
  // Abschlussarbeiten
  // Daten des Services sind angehängt
  return _rOk;

End; // sub exec(...) : int



sub _VSB2Eingang(aEingang : int) : logic
local begin
  vLfd : int;
  vNr : int;
  vNeueKarte  : logic;
  vBuf506 : int;
  vVSBMat : int;
  vMitRes : logic;
  vStk : int;
  vGew    : float;
  vGewN   : float;
  vGewB   : float;
  vMenge  : float;
  vKillVSB : logic;
  vZeit   : time;
  Erx     : int;
end
begin

  TRANSON;

  Ein.E.Nummer        # Ein.P.Nummer;
  Ein.E.Anlage.User   # gUserName;
  vLfd                # Ein.E.Eingangsnr;

  REPEAT
    Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
    Ein.E.Anlage.Datum  # Today;
    Ein.E.Anlage.Zeit   # Now;
    Erx # RekInsert(506,0,'MAN');
  UNTIL (erx=_rOK);
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;

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

  if (Ein.E.Materialnr=0) then vNeueKarte # y;



  // Gegenbuchung!! ----------------------------
  vBuf506 # RekSave(506);
  Ein.E.Eingangsnr # aEingang;
  Erx # RecRead(506,1,_recLock);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RekRestore(vBuf506);
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;
  vVSBMat # Ein.E.Materialnr;
  Mat.Nummer # vVSBMat;

  if (RecLinkInfo(203,200,13,_recCount)>0) then begin
    Erx # RecLink(203,200,13,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      if ("Mat.R.Trägernummer1"=0) then begin
        vMitRes # y;
        BREAK;
      end;
      Erx # RecLink(203,200,13,_RecNext);
    END;
  end;

  RekRestore(vBuf506);

  if (Ein_E_Data:Verbuchen(y,n,vVSBMat)=false) then begin
    TRANSBRK;
    Error(506001,'');
    ErrorOutput;
    RETURN false;
  end;

  vStk    # "Ein.E.Stückzahl";
  vGew    # Ein.E.Gewicht;
  vGewN   # Ein.E.Gewicht.Netto;
  vGewB   # Ein.E.Gewicht.Brutto;
  vMenge  # Ein.E.Menge;

  Ein.E.Eingangsnr # aEingang;
  Erx # RecRead(506,1,_recLock);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;
  PtD_Main:Memorize(506);   // für die Gegenbuchung!!
  "Ein.E.Stückzahl"     # "Ein.E.Stückzahl" - vStk;
  Ein.E.Gewicht         # Ein.E.Gewicht     - vGew;
  Ein.E.Menge           # Ein.E.Menge       - vMenge;
  Ein.E.Gewicht.Netto   # Ein.E.Gewicht.Netto - vGewN;
  Ein.E.Gewicht.Brutto  # Ein.E.Gewicht.Brutto - vGewB;
  if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
    Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
  end;
  if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
    Ein.E.Menge # Ein.E.Gewicht;
  end;
  if ("Ein.E.Stückzahl"<0) then       "Ein.E.Stückzahl"     # 0;
  if (Ein.E.Gewicht<0.0) then         Ein.E.Gewicht         # 0.0;
  if (Ein.E.Gewicht.Netto<0.0) then   Ein.E.Gewicht.Netto   # 0.0;
  if (Ein.E.Gewicht.Brutto<0.0) then  Ein.E.Gewicht.Brutto  # 0.0;
  if (Ein.E.Menge<0.0) then           Ein.E.Menge           # 0.0;

  //*** MS VogelBauer Wunsch
  if (vKillVSB) or
    (("Ein.E.Stückzahl" = 0) and (Ein.E.Gewicht = 0.0) and (Ein.E.Gewicht.Brutto = 0.0) and (Ein.E.Gewicht.Netto = 0.0) and (Ein.E.Menge = 0.0)) then
    "Ein.E.Löschmarker" # '*';
  //*** Wenn Karte genullt, dann Löschmarker setzen
  Erx # RekReplace(506,_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    PtD_Main:Forget(506);
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;

  //   Vorgang buchen
//      if (Ein_E_Data:Verbuchen(n,y, vVSBMat)=false) then begin
  if (Ein_E_Data:Verbuchen(n,y)=false) then begin
    PtD_Main:Forget(506);
    TRANSBRK;
    Error(506001,'');
    ErrorOutput;
    RETURN false;
  end;
  PtD_Main:Forget(506);

  if (Ein.E.Eingang_Datum=today) then vZeit # now;

  // Restore
  Ein.E.Nummer      # Ein.P.Nummer;
  Ein.E.Eingangsnr  # vNr;
  Erx # RecRead(506,1,0);
  if (Erx<=_rLocked) and (Ein.E.Materialnr<>0) then begin
    // 22.04.2010 AI Abgang in Bestandsbuch eintragen
    Mat.Nummer # vVSBMat;
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then
      Mat_Data:Bestandsbuch(-vStk, -vGew, -vMenge, 0.0, 0.0, Translate('WE')+' '+aint(Ein.E.Nummer)+'/'+aint(ein.E.Position)+'/'+aint(ein.e.eingangsnr), Ein.E.Eingang_datum, vZeit, c_Akt_WE, Ein.E.Nummer, ein.E.Position, ein.e.eingangsnr);
    gSelected # Recinfo(506,_RecID);
  end;

  TRANSOFF;


  RETURN true;
end;




//=========================================================================
//=========================================================================
//=========================================================================