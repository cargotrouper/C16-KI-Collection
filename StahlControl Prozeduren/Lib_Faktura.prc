@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Faktura
//                    OHNE E_R_G
//  Info
//
//
//  28.03.2004  AI  Erstellung der Prozedur
//  10.03.2010  AI  Routinen aus Auf_Data gezogen
//  09.11.2010  AI  Faktura-Gewicht nur bei Aufträgen nachrechnen
//  11.02.2011  ST  Anker für Nummernvergabe hinzugefügt
//  30.05.2012  AI  USidentNr in Erlös eingebaut
//  13.12.2012  AI  Formelfunktion
//  14.05.2013  AI  Erlös-Warengruppe kommt ggf. auf Aufpreis
//  25.11.2013  AH  neues Recht: Faktura_ReDatum
//  11.02.2014  AH  Bugfix: Sammelrechnungsempfänger bekommen Gutschriften/Belastungen doch einzeln
//  26.02.2014  AH  ReKor/Bel schreibt sich informativ in die Aktionsliste des ursprünglichen Auftrages (ggf. AufKopf-Aktion)
//  08.08.2014  AH  NEU: Erl.K.Artikelnummer + Erl.K.Güte
//  18.08.2014  AH  Reverse-Charge
//  19.08.2014  AH  Kurrektur Reverse-Charge
//  02.02.2015  AH  BUGFIX: AufAktions-Rechnungspreise wurden über ehrere Positonen summiert !!!
//  26.03.2015  ST  BUGFIX: Fakturierung von MatMix schreibt wieder RE Daten an Materialkarte
//  28.04.2015  AH  "RE_Berbuchen" kann auch Sammelrechnung
//  07.05.2015  AH  Pos-%-Aufpreise sind NICHT immer rabbatierbar
//  15.07.2015  AH  Warnung bei Rechnungn über offene LFA
//  20.07.2015  ST  BUGFIX: AufAktions-Rechnungsspreise werden jetzt auch an Material in der Ablage weitergeben
//  22.09.2015  ST  BUGFIX: Bei RE_Verbuchen wird für Verwiegunsart jetzt auch MatMix abgefragt
//  30.10.2015  AH  Rücklieferschein
//  06.07.2016  AH  Valutadatumprüfung im Dialog
//  30.08.2016  AH  Bug: Mat.VK.Rechnungsdaten nicht gesetzt bei ArtMix
//  15.11.2016  AH  ERe wird sofort inOrdnung
//  16.01.2017  AH  Setting "Set.Wie.Fakt.OhneNK" zum Deaktivieren der Rindungen des VK-Preises in Aktion/Mat/Statistik
//  19.07.2017  AH  Bug: "GBMAT" versprang Kopf/400
//  20.08.2018  AH  "Dlg.Standard" kann Alternativename haben
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  30.01.2019  AH  Edit: Aufpreise, die über Formel kommen, können ggf. doch nicht auf die Rechnungsnr. festgeschrieben werden, wenn die Funktion Mengenbezug = true setzt
//  28.02.2019  AH  Edit: falsche Warengruppen in den Aufpreise bricht Verbuchung ab
//  11.01.2019  ST  Edit: Sub Rechnungsdruck, Afx Auf.Rechnung.pre bekommt VOrschaupara mitübergeben
//  24.10.2019  AH  Neu: AFX "Auf.Rechnung.Verbucht.PreMark"
//  25.11.2019  AH  Neu: VPG-LFS Aktion
//  31.01.2020  AH  Fix: VPG-LFS Aktion
//  10.02.2020  AH  Fix: Aufpreise per Formelfunktion nur EINMAL machen (in Apl_Data:Neuberechnung)
//  22.10.2020  AH  Erlös + Offener Posten mit Projektnumer
//  16.12.2020  AH  Gs/Bel-LF könnnen werden auch OHNE "Nullung" in den Nummernkreis "Gutschrift/Belastung-LF" gebucht. Sonst Kreis auf -1 setzen!
//  07.01.2021  AH  Neu: Aufpreise nutzen "ProRechnungYN"
//  09.02.2021  AH  Neu: AFX "Auf.Rechnung.NachPrintForm"
//  13.02.2021  AH  CO2
//  02.03.2021  AH  CO2 für Lohn
//  27.07.2021  AH  ERX
//  01.08.2022  ST  Edit: Anker "Auf.Rechnung.Post" bekommt erstellte Rechnungsnummer mit
//  2022-08-08  ST  Edit: Co2 Berechnung: CO2 Anteil des Schrottes wird dem CO2 EK zugeschlagen
//  2023-02-10  AH  Check der Auf.A.MEH.Preis gegen Auf.P.MEH.Preis, Proj. 2465/58
//  2023-05-24  AH  "InsertKonto" als Funktion für _rDeadLock
//  2023-05-24  AH  optional Möglichkeit die Kopfaufpeise in den Erlöskontierungen auf Positionen umzulegen
//  2023-06-01  ST  Fix:  Re-Vorbereitung: Zur Sicherheit Auftragskopf erneut lesen, damit möglichge Feldpufferänderungen an der 400 hinfällig werden
//  2023-07-27  AH  AFX "Auf.Rechnung.Vorbereiten.Post"
//
//  Aufpreise Reihenfolge:
//      1. Grundpreis
//      2. + mengenbezogene Positionsaufpreise
//      3. + pauschale (nicht mengenbezogen) Positionsaufpreise
//      4. + prozentuale Positionsaufpreise
//      5. + mengenbezogene Kopfaufpreise
//      -> Positionssumme
//      6. + pauschale Kopfaufpreise
//      7. + prozentuale Kopfaufpreise
//      -> Endsumme
//
//
//  Subprozeduren
//    SUB AbschlussTest(aDatum : date) : logic;
//
//    SUB RE_ABBRUCH
//    SUB RE_HoleReMenge() : float;
//    SUB RE_Verbuchen(aBisLiefDatum : date; opt aSel400 : int) : logic; opt aNurLFS : int) : logic;
//    SUB RE_Vorbereiten(varaReDatum : date; aBisLiefDatum : date; aSkontoDatum : date; aSkontoProzent : float; aZielDatum : date; aValutaDatum : date; aSilent : logic; opt aNurLFS : int) : logic;
//    SUB RE_Eingabemaske(varaReDatum : date; varaBisLiefDatum : date; varaSkontoDatum : date; varaSkontoProzent : float; varaZielDatum : date; var aValutadatum : date) : logic;
//
//    SUB Rechnungsdruck(aVorschau : logic; opt aReDat : date; opt aSilent : logic) : logic;
//
//    SUB SumMwst(aWgrSts : int; aAdrSts : int; aNetto : float; var aS1 : int; var aP1 : float; var aN1 : float; var aS2 : int; var aP2 : float; var aN2 : float);
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_Rights

//@Define Pruefen

define begin
  NEGIEREN(a)   : a # Rnd((-1.0) * a,2);
//  InsertKonto   : WHILE (Erl_data:Insert451(0,'AUTO')<>_rOk) do begin Erl.K.lfdNr # Erl.K.lfdNr + 1; end;
end;

declare SumMwst(aWgrSts : int; aAdrSts : int; aNetto : float; var aS1 : int; var aP1 : float; var aN1 : float; var aS2 : int; var aP2 : float; var aN2 : float);
declare AbschlussTest(aDatum : date) : logic;


//========================================================================
//========================================================================
sub ErzeugeVpgAktion(
  aAufNr  : int;
  aArtNr  : alpha;
  aArtSW  : alpha;
  aMEH    : alpha;
  aMenge  : float;
  aIstFix : logic;
) : logic
local begin
  Erx     : int;
  vOK     : logic;
end;
begin

  RecBufClear(403);
  Auf.Z.Nummer        # aAufNr;
  Auf.Z.Vpg.ArtikelNr # aArtNr;
  Erx # RecRead(403,3,0);
  WHILE (Erx<=_rMultikey) and (Auf.Z.Nummer=aAufNr) and
    (Auf.Z.Vpg.ArtikelNr=aArtNr) do begin
    // 31.01.2020 AH: hier nur FIX, nicht Mengenbezogen!!!
    if (Auf.Z.Position=0) and (Auf.Z.Vpg.ArtikelNr=aArtNr) and (Auf.Z.MengenbezugYN=false) and
      (Auf.Z.MEH=aMEH) and (Auf.Z.Rechnungsnr=0) then begin
      vOK # y;  // Aufpreis bereits vorhanden!
      BREAK;
    end;
    Erx # RecRead(403,3,3,_RecNext);
  END;

  if (vOK) then begin
    RecRead(403,1,_RecLock);
    if (aIstFix) then begin
      Auf.Z.Menge     # aMenge
      Auf.Z.Vpg.OKYN  # y;
    end
    else begin
      Auf.Z.Menge     # Auf.Z.Menge + aMenge;
      Auf.Z.Vpg.OKYN  # n;
    end;
    Erx # RekReplace(403,_recUnlock,'AUTO');
debugx('mod KEY403 RECID403');
  end
  else begin
    RecBufClear(403);
    Auf.Z.Nummer          # aAufNr;
    Auf.Z.Position        # 0;
    "Auf.Z.Schlüssel"     # 'VPG';
    Auf.Z.Menge           # aMenge;
    Auf.Z.MEH             # aMEH;
    Auf.Z.PEH             # 1;
    Auf.Z.MengenbezugYN   # n;
    Auf.Z.RabattierbarYN  # n;
    Auf.Z.NeuberechnenYN  # n;
    Auf.Z.Preis           # 0.0;
    Auf.Z.Bezeichnung     # aArtSW;
    Auf.Z.Vpg.ArtikelNr   # aArtNr;
    Auf.Z.Vpg.OKYN        # aIstFix;
    Auf.Z.Anlage.Datum    # today;
    Auf.Z.Anlage.Zeit     # now;
    Auf.Z.Anlage.User     # gUserName;
    Auf.Z.lfdNr           # 0;
    REPEAT
      Auf.Z.lfdNr # Auf.Z.lfdNr + 1;
      Erx # RekInsert(403,0,'AUTO');
    UNTIL (Erx=_rOK);
  end;
  if (erx<>_rOK) then begin
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  AbschlussTest
//              Prüft, ob das Datum NACH dem Abschlussdatum liegt
//========================================================================
sub AbschlussTest(aDatum : date) : logic;
begin
  if (aDatum<Set.AbschlussDatum) then
    RETURN false
  else
    RETURN true;
end;


//========================================================================
// RE_ABBRUCH
//
//========================================================================
sub RE_ABBRUCH(
  aErx      : int;  // 2023-05-24  AH
  aKontoTxt : int;  // 2023-05-24 AH
  vA        : int;
  vB        : int;
  opt aText : alpha) : logic;
local begin
  vName : alpha;
end;
begin
  if (aKontoTxt<>0) then TextClose(aKontoTxt);

  vName # 'Rechnung';
  if (Auf.Vorgangstyp=c_BOGUT) then         vName # 'Gutschrift/Belastung';
  else if (Auf.Vorgangstyp=c_REKOR) then    vName # 'Gutschrift/Belastung';
  else if (Auf.Vorgangstyp=c_GUT) then      vName # 'Gutschrift/Belastung';
  else if (Auf.Vorgangstyp=c_BEL_KD) then   vName # 'Gutschrift/Belastung';
  else if (Auf.Vorgangstyp=c_BEL_LF) then   vName # 'Gutschrift/Belastung';

  if (aErx<>_rDeadLock) then TRANSBRK;

//  if (lib_Nummern:RestoreNummer(vName, Erl.Rechnungsnr)) then Msg(400096,'',0,0,0) else Msg(400095,'',0,0,0);
  if (lib_Nummern:FreeNummer()) then Msg(400096,'',0,0,0) else Msg(400095,'',0,0,0);
  
  if (aText='') then aText # aint(vB);
  
  WHILE Msg(vA, aText,_winicoerror,_windialogokcancel,1)=_winidOk DO begin
  end;
  RETURN false;
end;


//========================================================================
// RE_HoleReMenge
//
//========================================================================
sub RE_HoleReMenge() : float;
begin

  if (Auf.A.MEH.Preis=Auf.P.MEH.Preis) then
    RETURN Auf.A.Menge.Preis;
  if (Auf.A.MEH=Auf.P.MEH.Preis) then
    RETURN Auf.A.Menge;

//  else if (Auf.P.MEH.Preis='Stk') then
//    RETURN cnvfi("Auf.A.Stückzahl")
//  else RETURN 0.0
  RETURN Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.P.MEH.Preis);
end;


/*========================================================================
2023-05-24  AH
========================================================================*/
sub InsertKonto(
  aKontoTxt         : int;
  opt aErlNettoFW   : float;
) : int;
local begin
  Erx       : int;
  vKey      : alpha;
  vI        : int;
  vWertFW   : float;
  vWertW1   : float;
  vAPWertFW : float;
  vA        : alpha;
end;
begin
  if (aKontoTxt=0) or (Erl.K.Auftragspos<>0) then begin
    REPEAT
      Erx # Erl_data:Insert451(0,'AUTO');
      if (Erx=_rDeadLock) then RETURN Erx;
      if (Erx<>_rOK) then Erl.K.lfdNr # Erl.K.lfdNr + 1;
    UNTIl (erx=_rOK);
//debugx('insert ' +anum(Erl.K.Betrag,2));
  end;
  
  // 2023-05-24 AH Positionswerte addieren:
  if (aKontoTxt<>0) and (Erl.K.Betrag<>0.0) then begin
    vWertFW # Erl.K.Betrag;
    vWertW1 # Erl.K.BetragW1;
    if (Erl.K.Auftragspos<>0) then begin
      vKey # '|' + aint(Erl.K.Auftragsnr) + '|'+ aint(Erl.K.Auftragspos)+'|';
      vI # Textsearch(aKontoTxt, 1, 1, 0, vKey);
      if (vI<>0) then begin
        vA # TextLineRead(aKontoTxt, vI, _TextLineDelete);
        vWertFW # vWertFW + Cnvfa(Str_Token(vA, '|', 4));
        vWertW1 # vWertW1 + Cnvfa(Str_Token(vA, '|', 5));
      end;
      vKey # vKey + anum(vWertFW,2) + '|' + anum(vWertW1,2) + '|' + aint(Erl.K.Rechnungspos) + '|' + aint(Erl.K.Warengruppe);
      TextAddLine(aKontoTxt, vKey);
    end
    else if (aErlNettoFW<>0.0) then begin
//debugx('hier kommt Kopfaufpreis:'+anum(Erl.K.Betrag,2)+'FW   Erlsum:'+anum(aErlNettoFW,2));
      vAPWertFW # Erl.K.Betrag;
      RecbufClear(404);
      // verteile Kopfaufpreis auf Positionen:
      FOR vI # 1
      LOOP inc(vI)
      WHILE (vI<=TextInfo(aKontoTxt, _textLines)) do begin
        vKey # TextLineRead(aKontoTxt, vI, 0);
        if (vKey='') then CYCLE;
        vWertFW # Cnvfa(Str_Token(vKey, '|', 4));
        vWertW1 # Cnvfa(Str_Token(vKey, '|', 5));
        if (vWertFW<>0.0) then begin
          Erl.K.Auftragsnr  # Cnvia(Str_Token(vKey, '|', 2));
          Erl.K.Auftragspos # Cnvia(Str_Token(vKey, '|', 3));
          Erl.K.RechnungsPos  # Cnvia(Str_Token(vKey, '|', 6));   // 2023-06-13 AH
          if (Erl.K.MEH='%') then
            Erl.K.Warengruppe   # Cnvia(Str_Token(vKey, '|', 7));
          Auf.P.Nummer      # Erl.K.Auftragsnr;
          Auf.P.Position    # Erl.K.Auftragspos;
          Erl.K.Betrag      # vAPWertFW / aErlNettoFW * vWertFW;
          Erl.K.BetragW1    # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
          Erx # InsertKonto(0);
          if (Erx<>_rOK) then RETURN Erx;
        end;
      END;
      
    end;
  end;
  
  RETURN Erx;
end;


//========================================================================
// RE_Verbuchen
//        erwartet OFFENE TRANS, macht bei Fehler TRANSBRK
//========================================================================
sub RE_Verbuchen(
  aBisLiefDatum : date;
  opt aSel400   : int;
  opt aNurLFS   : int) : logic;
local begin
  Erx                 : int;
  vMatCO2EK           : float;
  vMatCO2Kost         : float;

  vKopfaufpreis       : float;
  vPosEKPreis         : float;
  vPosInternKost      : float;
  vPosStk             : int;
  vPosGewicht         : float;
  vPosMenge           : float;
  vPosAnzahlAkt       : int;
  vPosCO2EK           : float;
  vPosCO2Kost         : float;
  
  vMwstSatz1          : int;
  vMwstProz1          : float;
  vMwstNetto1         : float;
  vMwstWert1          : float;
  vMwStNettoRabbar1   : float;
  vPosRabbar1         : float;

  vMwstSatz2          : int;
  vMwstProz2          : float;
  vMwstNetto2         : float;
  vMwstWert2          : float;
  vMwStNettoRabbar2   : float;
  vPosRabbar2         : float;
  vPosNetto           : float;

  vMenge              : float;
  vAnzahlPos          : int;
  vOk                 : logic;
  vPreis              : float;
  vGew                : float;

  vTyp                : alpha;

  vBuf450             : int;
  vBuf451             : int;
  vBuf400,vBuf401     : int;
  vI                  : int;

  vAdr                : int;
  vKopfAPExists       : logic;
  vGbMatKg            : float;
  vGbMatPreisProT     : float;
  vDatei              : int;
  vDiffTxt            : int;
  vGbTermin           : date;
  v450                : int;
  v400                : int;
  vPrjNr              : int;
  vX1,vX2             : float;
  vKontoTxt           : int;
  vNettoOhneKopfAP    : float;
end;

begin
  vTyp # Auf.Vorgangstyp;

  vMwStSatz1          # -1;
  vMwStSatz2          # -1;

  // Verpackungsaktionen als fakturiert markieren... 25.11.2019
  FOR Erx # RecLink(404,400,15,_RecFirst)
  LOOP Erx # RecLink(404,400,15,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if ("Auf.A.Löschmarker"='*') or
      (Auf.A.TerminEnde>aBisLiefDatum) or (Auf.A.TerminEnde=0.0.0) or
      (Auf.A.Rechnungsdatum<>0.0.0) then
      CYCLE;
    if (Auf.A.Aktionstyp=c_Akt_LFS_VPG) then begin
      RecRead(404,1,_recLock);
      Auf.A.Rechnungsnr     # Erl.Rechnungsnr;
      Auf.A.Rechnungsdatum  # Erl.Rechnungsdatum;
      RekReplace(404);
    end;
  END;


  // Konten vorbereiten
  RecBufClear(451);
  Erl.K.Rechnungsnr     # Erl.Rechnungsnr;
  Erl.K.Rechnungsdatum  # Erl.Rechnungsdatum;
  "Erl.K.Währung"       # "Erl.Währung";
  "Erl.K.Währungskurs"  # "Erl.Währungskurs";
  Erl.K.Kundennummer    # Erl.Kundennummer;
  Erl.K.lfdNr           # 1;


  // Auftragsköpfe und Auftragspositionen laden..................
  if (aSel400=0) then         // einfache Rechnung
    Erx # RecRead( 400, 1, 0)
  else                        // Sammelrechnung
    Erx # RecRead( 400, aSel400, _recFirst);
  WHILE ( Erx <= _rLocked ) DO BEGIN

    // 26.10.2016 AH:
    if (vTyp=c_GUT) or (vTyp=c_BEL_LF) then begin
      FOR Erx # RecLink(403,400,13,_RecFirst) // Aufpreise loopen
      LOOP Erx # RecLink(403,400,13,_RecNext)
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.Position=0) then begin
          vKopfAPExists # true;
          BREAK;
        end;
      END;
    end;


    vMwStNettoRabbar1   # 0.0;
    vMwStNettoRabbar1   # 0.0;
//    vMwstNetto1         # 0.0;
//    vMwstNetto2         # 0.0;
//    vMwstProz1          # 0.0;
//    vMwstProz2          # 0.0;

    // 2023-05-24 AH    paschale Kopfaufreise anteilig aus Positionen umlegen?
    if (Set.Installname='HOWVFP') or
        (Set.Installname='HOWVVF') or
        (Set.Installname='HOWALL') or
        (Set.Installname='KSP') then
      vKontoTxt # TextOpen(20);


    // Positionen durchlaufen
    Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecFirst);
    WHILE (Erx<=_rLocked) do begin

      if ("Auf.P.Löschmarker"='*') then begin
        Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecNext);
        CYCLE;
      end;

      vPosStk             # 0;
      vPosMenge           # 0.0;
      vPosGewicht         # 0.0;

      vPosAnzahlAkt       # 0;
      vPosEKPreis         # 0.0;
      vPosInternKost      # 0.0;
      vPosCO2EK           # 0.0;
      vPosCO2Kost         # 0.0;
      
      // Warengruppe holen
      Erx # RecLink(819,401,1,_recFirst);
      if (Erx>_rLocked) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,338);

      if (WGr_data:IstMat(Auf.P.Wgr.Dateinr)) OR ((WGr_data:IstMix(Auf.P.Wgr.Dateinr))) then begin
        // Verwiegungsart holen
        Erx # RecLink(818,401,9,_recFirst);
        if (Erx>_rLocked) then begin
          RecBufClear(818);
          VwA.NettoYN # y;
        end;
      end
      else begin  // Artikel haben immer NETTOGEWICHT
        RecBufClear(818);
        VwA.NettoYN # Y;
      end;


      // Aktionen durchlaufen
      vOk # n;  // keine Aktionen bisher
      Erx # RecLink(404,401,12,_RecFirst);
      WHILE (Erx<=_rLocked) do begin

        if ("Auf.A.Löschmarker"='*') or (Auf.A.Rechnungsmark<>'$') or
          (Auf.A.TerminEnde>aBisLiefDatum) or (Auf.A.TerminEnde=0.0.0) or
          (Auf.A.Rechnungsdatum<>0.0.0) then begin
          Erx # RecLink(404,401,12,_RecNext);
          CYCLE;
        end;

        // 11.05.2017 AH
        if (aNurLFS<>0) then begin
          if (Auf.A.Aktionsnr<>aNurLFS) or (Auf.A.Aktionstyp<>c_Akt_Lfs) then begin
            Erx # RecLink(404,401,12,_RecNext);
            CYCLE;
          end;
        end;


        vOk # y;  // Aktion gefunden
        if (Erx=_rLocked) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400002,0);

        vMatCO2EK   # 0.0;
        vMatCO2Kost # 0.0;
        // aktuellen EK-Preis holen...
        // 30.10.2015 : ReKore/Gut darf Rücknahme-Karte nicht weiter betraachten
        if (vTyp<>c_REKOR) and (vTyp<>c_GUT) then begin
//          if ((WGr_data:IstMat(Auf.P.Wgr.Dateinr)) and (Auf.A.Materialnr<>0)) then begin
          if (Auf.A.Materialnr<>0) then begin // 24.02.2021 AH
            Erx # RecLink(200,404,6,_RecFirst);   // Material holen
            if (Erx>_rLocked) then begin
              Erx # RecLink(210,404,8,_RecFirst); // ~Material holen
              if (Erx>_rLocked) then RecBufClear(210);
              RecBufCopy(210,200);
            end;
            Auf.A.EKPreisSummeW1    # Rnd(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0,2);
            Auf.A.interneKostW1     # Rnd(Mat.Kosten * Mat.Bestand.Gew / 1000.0,2);
            
            // ST 2022-08-08 2326/52; Schrott per T soll dem Co2 EK zugeschlagen werden
            //vMatCO2EK   # Rnd(Mat.CO2EinstandProT * Mat.Bestand.Gew / 1000.0,2);
            vMatCO2EK   # Rnd((Mat.CO2EinstandProT + Mat.CO2SchrottProT) * Mat.Bestand.Gew / 1000.0,2);
            
            
// nur INHOUSE            vMatCO2Kost # Rnd((Mat.CO2ZuwachsProT + Mat.CO2SchrottProT) * Mat.Bestand.Gew / 1000.0,2);
            vMatCO2Kost # Rnd(Mat.CO2ZuwachsProT * Mat.Bestand.Gew / 1000.0,2);
          end
          else if (Auf.A.Aktionstyp=c_Akt_BA) then begin    // LOHN?
            BAG.P.Nummer    # Auf.A.Aktionsnr;
            BAG.P.Position  # Auf.A.Aktionspos;
            Erx # RecRead(702,1,0);
            if (Erx<=_rLocked) then
              vMatCO2Kost # Rnd(BAG.P.Kosten.CO2,2);
          end;
        end;

        // Aktion verändern / 19.07.2017 AH. GbMat SPÄTER fakturieren
        if (Auf.A.Aktionstyp<>c_Akt_GbMat) then begin
          RecRead(404,1,_recLock | _Recnoload);
          Auf.A.Rechnungsnr     # Erl.Rechnungsnr;
          Auf.A.Rechnungsdatum  # Erl.Rechnungsdatum;
          Auf.A.Rechnungsmark   # '';
          Erx # RekReplace(404,_recUnlock,'AUTO');
          if (erx<>_rOK) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,373);
        end;


        vPosMenge   # vPosMenge + RE_HoleReMenge();
  //      if (vTyp=c_REKOR) or (vTyp=c_GUT_Lf) then begin
//debugx('add ekpreis :'+anum(vPosEKPreis,2)+' + '+anum(Auf.A.EKPreisSummeW1,2));
        vPosEKPreis     # vPosEKPreis + Auf.A.EKPreisSummeW1;
        vPosInternKost  # vPosInternKost + Auf.A.InterneKostW1;
        vPosCO2EK       # vPosCO2EK + vMatCO2EK;
        vPosCO2Kost     # vPosCO2Kost + vMatCO2Kost;
        
        vPosStk         # vPosStk + "Auf.A.Stückzahl";
        if (VwA.NettoYN) and (Auf.A.Nettogewicht<>0.0) then
          vGew # Auf.A.Nettogewicht
        else
          vGew # Auf.A.Gewicht;
        if (vTyp=c_AUF) then begin
          if (Auf.A.MEH.Preis='kg') then
            vGew # RE_HoleReMenge()
          else if (Auf.A.MEH.Preis='t') then
            vGew # RE_HoleReMenge() * 1000.0;
        end;

        vPosGewicht # vPosGewicht + vGew;

        // Auftragsposition ändern
        Erx # RecRead(401,1,_recLock);
        if (Erx=_rLocked) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400003,0);

        //Auf.P.Prd.Rech      # Auf.P.Prd.Rech      + RE_HoleReMenge();
        if (Auf.A.MEH=Auf.P.MEH.Einsatz) then
          Auf.P.Prd.Rech      # Auf.P.Prd.Rech      + Auf.A.Menge
        else if (Auf.A.MEH.Preis=Auf.P.MEH.Einsatz) then
          Auf.P.Prd.Rech      # Auf.P.Prd.Rech      + Auf.A.Menge.Preis
        else begin
  //debug('wandle '+anum(auf.a.menge,2)+auf.a.meh+'  ->  '+auf.p.meh.preis);
          Auf.P.Prd.Rech      # Auf.P.Prd.Rech      + Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.P.MEH.Preis);
        end;
        Auf.P.Prd.Rech.Gew  # Auf.P.Prd.Rech.Gew  + vGew;
        Auf.P.Prd.Rech.Stk  # Auf.P.Prd.Rech.Stk  + "Auf.A.Stückzahl";
        // 27.10.2016 Auf_Data:PosReplace(_recUnlock,'AUTO');
        Erx # RekReplace(401);
        if (Erx<>_rOK) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,382);

        vPosAnzahlAkt # vPosAnzahlAkt + 1;

        Erx # RecLink(404,401,12,_RecNext);
      END;

      if (vOK=n) then begin // diese Position bringt nichts
        Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecNext);
        CYCLE;
      end;
      vAnzahlPos # vAnzahlPos + 1



      // Positionsmengen stehen ab jetzt fest!!
      vPreis # Rnd((Auf.P.Grundpreis) *  vPosMenge / CnvFI(Auf.P.PEH) ,2);

      RekLink(819,401,1,_recFirst); // Warengruppe holen
      vPosNetto # vPreis;
      SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vMwStNetto1, var vMwstSatz2, var vMwStProz2, var vMwstNetto2);
      SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vPosRabbar1, var vMwstSatz2, var vMwStProz2, var vPosRabbar2);
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vPosRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vPosRabbar2,2)+')');
@endif
  /*
        StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + Erl.Adr.Steuerschl;
        Erx # RecRead(813,1,0);
        if (Erx>_rLocked) then RETURN RE_ABBRUCH(400098,0);
        vPosMwst # StS.Prozent;
  */

      // Steuerkonto bestimmen
      // ...Artikel
      if (WGr_data:IstArt(Auf.P.Wgr.Dateinr)) then begin
        Erx # RecLink(250,401,2,_recFirst);
        if (Erx>_rLocked) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,454);
      end;
      // ...Material
      //if (WGr_data:IstMat(Auf.P.Wgr.Dateinr))
      //end;

      // Erlöskonto anlegen
      Erl.K.Auftragsart     # Auf.P.Auftragsart;
      Erl.K.Projektnr       # Auf.P.Projektnummer;
      if (vPrjNr=0) then vPrjNr # Auf.P.Projektnummer
      else if (vPrjNr<>Auf.P.Projektnummer) then vPrjNR # -1;
      Erl.K.Warengruppe     # Auf.P.Warengruppe;
      Erl.K.Artikelnummer   # Auf.P.Artikelnr;
      "Erl.K.Güte"          # "Auf.P.Güte";
      "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
      Erl.K.Betrag          # vPreis;
      Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
      "Erl.K.Stückzahl"     # vPosStk;
      Erl.K.Gewicht         # vPosGewicht;
      Erl.K.Menge           # vPosMenge;
      Erl.K.EKPreisSummeW1  # vPosEKPreis;
      "Erl.K.CO2Einstand"   # vPosCO2EK;
      "Erl.K.CO2Zuwachs"    # vPosCO2Kost;
      Erl.K.InterneKostW1   # vPosInternKost;
      Erl.K.MEH             # Auf.P.MEH.Preis;
      Erl.K.Bemerkung       # Translate('Grundpreis');
      Erl.K.AufpreisSchl    # '';
      Erl.K.Auftragsnr      # Auf.P.Nummer;
      Erl.K.Auftragspos     # Auf.P.Position;
      Erl.K.Steuerschl      # StS.Nummer;       // durch SumMwst gefüllt
      Erl.K.RechnungsPos    # vAnzahlPos;

      if (vTyp=c_BOGUT) then        Erl.K.Gegen.ReNr  # Auf.P.AbrufAufNr;
      else if (vTyp=c_REKOR) then   Erl.K.Gegen.ReNr  # Auf.P.AbrufAufNr;
      else if (vTyp=c_GUT) then     Erl.K.Gegen.ReNr  # Auf.P.AbrufAufNr;
      else if (vTyp=c_BEL_KD) then  Erl.K.Gegen.ReNr  # Auf.P.AbrufAufNr;
      else if (vTyp=c_BEL_LF) then  Erl.K.Gegen.ReNr  # Auf.P.AbrufAufNr;


      // bei LF-Buchungen nicht anlegen!
      if (Set.Auf.GutBelLFNull=false) or
        ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
        Erx # InsertKonto(vKontoTxt);
        if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
      end;


      // Gutschriften/Belastungen in zugehörigem Rechnungsauftrag eintragen ***************
      if ((vTyp=c_ReKor) or (vTyp=c_Bel_Kd) or (vTyp=c_ReKor))and
        (Auf.P.AbrufAufnr<>0) then begin

        vBuf401 # RekSave(401);
        vBuf400 # RekSave(400);

        vOK # n;

        vBuf451 # RecBufCreate(451);

        if (Auf.P.AbrufAufPos<>0) then begin
          vBuf451->Erl.K.Rechnungsnr  # Auf.P.AbrufAufNr;
          vBuf451->Erl.K.Rechnungspos # Auf.P.AbrufAufPos;
          Erx # RecRead(vBuf451,4,0);                 // Rechnungspos. holen
          if (Erx=_rMultikey) then Erx # _rOK;
        end
        else begin  // keine genaus Auf.Position angegeben? Dann ersten Auftrag suchen...
          vBuf450 # RecBufCreate(450);
          vBuf450->Erl.Rechnungsnr # Auf.P.AbrufAufNr;
          Erx # RecRead(vBuf450,1,0);
          if (Erx<=_rLocked) then begin
            Erx # RekLinkB(vBuf451, vBuf450, 1, _recFirst);
            WHILE (Erx<=_rLocked) and (vBuf451->Erl.K.Auftragspos=0) do
              Erx # RekLinkB(vBuf451, vBuf450, 1, _recNext);
            RecBufDestroy(vBuf450);
          end;
        end;

        if (Erx<=_rLocked) and (vBuf451->Erl.K.Auftragsnr<>0) and (vBuf451->Erl.K.Auftragspos<>0) then begin
          vI # Auf_Data:Read(vBuf451->Erl.K.Auftragsnr, vBuf451->Erl.K.AuftragsPOs,y)
          if (vI=401) then vOK # y
          else if (vI=411) then begin
            if (Auf_Abl_Data:RestoreAusAblage("Auf~P.Nummer")) then begin
              Erx # RecLink(401,vBuf451,8,_recFirst); // nochmal AufPos holen
              if (Erx<=_rLocked) then vOK # y;
            end;
          end;
        end;

        RecBufDestroy(vBuf451);


        // Aktionen anlegen...
        if (vOK) then begin
          RecBufClear(404);
          Auf.A.Aktionstyp    # c_Akt_sieheReKor;
          if (vTyp=c_BEL_KD) then
            Auf.A.Aktionstyp  # c_Akt_sieheBel;
          Auf.A.Aktionsnr     # Erl.Rechnungsnr;
          Auf.A.Aktionspos    # Erl.K.lfdNr;
          Auf.A.Aktionsdatum  # Erl.Rechnungsdatum;
          Auf.A.TerminStart   # Erl.Rechnungsdatum;
          Auf.A.TerminEnde    # Erl.Rechnungsdatum;
          Auf.A.Bemerkung     # c_AktBem_sieheRekor;
          if (vTyp=c_BEL_KD) then
            Auf.A.Bemerkung   # c_AktBem_sieheBel;
          if (vBuf401->Auf.P.AbrufAufPos=0) then
            Erx # Auf_A_Data:NeuamKopfAnlegen()
          else
            Erx # Auf_A_Data:NeuAnlegen();
          if (erx<>_rOk) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 4000099,692);
        end;

        RekRestore(vBuf400);
        RekRestore(vBuf401);
      end;  // ...Gutschrift in Auf.Aktion schreiben




      // Rückstellungen bilden **********************
      Erx # RecLink(405,401,7,_recFirst);
      WHILE (Erx<=_rLocked) do begin
        if ("Auf.K.RückstellungYN") and (Auf.K.Lieferantennr<>0) then begin
          if (Auf.K.MengenbezugYN) then begin
            if (Auf.K.MengenbezugYN) and (Auf.K.MEH<>'%')  then begin
              Auf.K.Menge # Lib_Einheiten:WandleMEH(403, "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Auf.K.MEH);
            end;
            if (Auf.K.MengenbezugYN) and (Auf.K.MEH='%') then begin
              Auf.K.Preis # Erl.K.Betrag;
            end;
  //          vWert  #  Rnd(Auf.K.Preis * vMenge / CnvFI(Auf.K.PEH),2);
          end;

          // Einkaufskontrolle durchführen
          if (EKK_Data:Update(450)=false) then RETURN RE_ABBRUCH(_rNoRec, vKontoTxt, 4000099,547);

        end;
        Erx # RecLink(405,401,7,_recNext);
      END;

      // Aufpreise: fremd MEH-Bezogen
      // Aufpreise: fremd MEH-Bezogen
      // Aufpreise: fremd MEH-Bezogen
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin

        if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
        if (Auf.Z.MengenbezugYN) and
        ((Auf.Z.MEH<>'%') and (Auf.Z.MEH<>Auf.P.MEH.Preis)) then begin
          //vMenge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Wunsch, Auf.Z.MEH)
          vMenge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
          vPreis # Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
          vPosNetto # vPosNetto + vPreis;

          // für Rervers-Charge
          if (Auf.Z.Warengruppe<>0) and (Auf.Z.Warengruppe<>Wgr.Nummer) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx>_rLocked) then
              RETURN RE_ABBRUCH(Erx, vKontoTxt, 400094,0,aint(Auf.Z.Nummer)+'/'+aint(Auf.Z.Position)+'/'+aint(Auf.Z.lfdNr));
          end;
          SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vMwStNetto1, var vMwstSatz2, var vMwStProz2, var vMwstNetto2);
          if (Auf.Z.RabattierbarYN) then begin
            SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vPosRabbar1, var vMwstSatz2, var vMwStProz2, var vPosRabbar2);
          end;
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vPosRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vPosRabbar2,2)+')');
@endif

          // Erlöskonto anlegen
          Erl.K.Auftragsart     # Auf.P.Auftragsart;
          Erl.K.Projektnr       # Auf.P.Projektnummer;
          Erl.K.Warengruppe     # Auf.P.Warengruppe;
          "Erl.K.Güte"          # "Auf.P.Güte";
          "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
          // 14.05.2013: ggf. Warengruppe aus Aufpreis holen
          if (Auf.Z.Warengruppe<>0) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx<=_rLocked) then begin
              Erl.K.Warengruppe     # Auf.Z.Warengruppe;
              "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
            end;
            Erx # RecLink(819,401,1,_recFirst);
          end;
          Erl.K.Artikelnummer   # Auf.P.Artikelnr;
          if (Auf.Z.Vpg.Artikelnr<>'') then
            Erl.K.Artikelnummer   # Auf.Z.Vpg.Artikelnr;


          Erl.K.Betrag          # vPreis;
          Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
          "Erl.K.Stückzahl"     # 0;
          Erl.K.Gewicht         # 0.0;
          Erl.K.Menge           # vMenge;
          Erl.K.EKPreisSummeW1  # 0.0;
          "Erl.K.CO2Einstand"   # 0.0;
          "Erl.K.CO2Zuwachs"    # 0.0;
          Erl.K.InterneKostW1   # 0.0;
          Erl.K.MEH             # Auf.Z.MEH;
          Erl.K.Bemerkung       # Auf.Z.Bezeichnung;
          Erl.K.AufpreisSchl    # "Auf.Z.Schlüssel";
          Erl.K.Auftragsnr      # Auf.P.Nummer;
          Erl.K.Auftragspos     # Auf.P.Position;
          Erl.K.RechnungsPos    # vAnzahlPos;
          Erl.K.Steuerschl      # StS.Nummer; // durch SumMwst gefüllt
          // bei LF-Buchungen nicht anlegen!
          if (Set.Auf.GutBelLFNull=false) or
            ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
            Erx # InsertKonto(vKontoTxt);
            if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
          end;
        end

        Erx # RecLink(403,401,6,_RecNext);
      END;

      // Aufpreise: MEH-Bezogen
      // Aufpreise: MEH-Bezogen
      // Aufpreise: MEH-Bezogen
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH=Auf.P.MEH.Preis) then begin
          // PosMEH in AufpreisMEH umwandeln
          vMenge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
          vPreis # Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
          vPosNetto # vPosNetto + vPreis;

          // für Rervers-Charge
          if (Auf.Z.Warengruppe<>0) and (Auf.Z.Warengruppe<>Wgr.Nummer) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx>_rLocked) then
              RETURN RE_ABBRUCH(Erx, vKontoTxt, 400094,0,aint(Auf.Z.Nummer)+'/'+aint(Auf.Z.Position)+'/'+aint(Auf.Z.lfdNr));
          end;
          SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vMwStNetto1, var vMwstSatz2, var vMwStProz2, var vMwstNetto2);
          if (Auf.Z.RabattierbarYN) then begin
            SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vPosRabbar1, var vMwstSatz2, var vMwStProz2, var vPosRabbar2);
          end;
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vPosRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vPosRabbar2,2)+')');
@endif

          // Erlöskonto anlegen
          Erl.K.Auftragsart     # Auf.P.Auftragsart;
          Erl.K.Projektnr       # Auf.P.Projektnummer;
          Erl.K.Warengruppe     # Auf.P.Warengruppe;
          "Erl.K.Güte"          # "Auf.P.Güte";
          "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
          // 14.05.2013: ggf. Warengruppe aus Aufpreis holen
          if (Auf.Z.Warengruppe<>0) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx<=_rLocked) then begin
              Erl.K.Warengruppe     # Auf.Z.Warengruppe;
              "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
            end;
            Erx # RecLink(819,401,1,_recFirst);
          end;
          Erl.K.Artikelnummer   # Auf.P.Artikelnr;
          if (Auf.Z.Vpg.Artikelnr<>'') then
            Erl.K.Artikelnummer   # Auf.Z.Vpg.Artikelnr;


          Erl.K.Betrag          # vPreis;
          Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
          "Erl.K.Stückzahl"     # 0;
          Erl.K.Gewicht         # 0.0;
          Erl.K.Menge           # vMenge;
          Erl.K.EKPreisSummeW1  # 0.0;
          "Erl.K.CO2Einstand"   # 0.0;
          "Erl.K.CO2Zuwachs"    # 0.0;
          Erl.K.InterneKostW1   # 0.0;
          Erl.K.MEH             # Auf.Z.MEH;
          Erl.K.Bemerkung       # Auf.Z.Bezeichnung;
          Erl.K.AufpreisSchl    # "Auf.Z.Schlüssel";
          Erl.K.Auftragsnr      # Auf.P.Nummer;
          Erl.K.Auftragspos     # Auf.P.Position;
          Erl.K.RechnungsPos    # vAnzahlPos;
          Erl.K.Steuerschl      # StS.Nummer; // durch SumMwst gefüllt
          // bei LF-Buchungen nicht anlegen!
          if (Set.Auf.GutBelLFNull=false) or
            ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
            Erx # InsertKonto(vKontoTxt);
            if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
          end;
        end;
        Erx # RecLink(403,401,6,_RecNext);
      END;

      // Aufpreise: NICHT MEH-Bezogen =FIX
      // Aufpreise: NICHT MEH-Bezogen =FIX
      // Aufpreise: NICHT MEH-Bezogen =FIX
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
        if (Auf.Z.MengenbezugYN=n) and (Auf.Z.MEH<>'%') and (Auf.Z.Rechnungsnr=0) then begin

// 10.02.2020 macht schon die initiale Neuberechnung          if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,401, aBisLiefDatum); // 25.11.2019 NEU: Datum

          if (Auf.Z.Menge<>0.0) then begin
            vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
            if (vTyp=c_BOGUT) or (vTyp=c_REKOR) or (vTyp=c_GUT) then begin
              Negieren(vPreis);
            end;
            vPosNetto # vPosNetto + vPreis;

            // für Rervers-Charge
            if (Auf.Z.Warengruppe<>0) and (Auf.Z.Warengruppe<>Wgr.Nummer) then begin
              Erx # RekLink(819,403,1,_recFirst);
              if (Erx>_rLocked) then
                RETURN RE_ABBRUCH(Erx, vKontoTxt, 400094,0,aint(Auf.Z.Nummer)+'/'+aint(Auf.Z.Position)+'/'+aint(Auf.Z.lfdNr));
            end;
            SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vMwStNetto1, var vMwstSatz2, var vMwStProz2, var vMwstNetto2);
            if (Auf.Z.RabattierbarYN) then begin
              SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vPosRabbar1, var vMwstSatz2, var vMwStProz2, var vPosRabbar2);
            end;
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vPosRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vPosRabbar2,2)+')');
@endif

            if (Auf.Z.MengenbezugYN=n) then begin   // 30.01.2019 AH: wegen Formelfunktion
              RecRead(403,1,_RecLock);
              Auf.Z.Rechnungsnr # Erl.Rechnungsnr;
              RekReplace(403,_recUnlock,'AUTO');
            end;

            // 27.10.2016 AH: REFRESH:
            RecRead(401,1,_recLock);
            Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht);
            RekReplace(401);


            // Erlöskonto anlegen
            Erl.K.Auftragsart     # Auf.P.Auftragsart;
            Erl.K.Projektnr       # Auf.P.Projektnummer;
            Erl.K.Warengruppe     # Auf.P.Warengruppe;
            "Erl.K.Güte"          # "Auf.P.Güte";
            "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
            // 14.05.2013: ggf. Warengruppe aus Aufpreis holen
            if (Auf.Z.Warengruppe<>0) then begin
              Erx # RekLink(819,403,1,_recFirst);
              if (Erx<=_rLocked) then begin
                Erl.K.Warengruppe     # Auf.Z.Warengruppe;
                "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
              end;
              Erx # RecLink(819,401,1,_recFirst);
            end;
            Erl.K.Artikelnummer   # Auf.P.Artikelnr;
            if (Auf.Z.Vpg.Artikelnr<>'') then
              Erl.K.Artikelnummer   # Auf.Z.Vpg.Artikelnr;


            Erl.K.Betrag          # vPreis;
            Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
            "Erl.K.Stückzahl"     # 0;
            Erl.K.Gewicht         # 0.0;
            Erl.K.Menge           # Auf.Z.Menge;
            Erl.K.EKPreisSummeW1  # 0.0;
            "Erl.K.CO2Einstand"   # 0.0;
            "Erl.K.CO2Zuwachs"    # 0.0;
            Erl.K.InterneKostW1   # 0.0;
            Erl.K.MEH             # Auf.Z.MEH;
            Erl.K.Bemerkung       # Auf.Z.Bezeichnung;
            Erl.K.AufpreisSchl    # "Auf.Z.Schlüssel";
            Erl.K.Auftragsnr      # Auf.P.Nummer;
            Erl.K.Auftragspos     # Auf.P.Position;
            Erl.K.RechnungsPos    # vAnzahlPos;
            Erl.K.Steuerschl      # StS.Nummer; // durch SumMwst gefüllt
            // bei LF-Buchungen nicht anlegen!
            if (Set.Auf.GutBelLFNull=false) or
              ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
              Erx # InsertKonto(vKontoTxt);
              if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
            end;
          end;
        end;
        Erx # RecLink(403,401,6,_RecNext);
      END;

      // Aufpreise: %
      // Aufpreise: %
      // Aufpreise: %
      Erx # RecLink(403,401,6,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
  //      if (Auf.Z.MengenbezugYN) and
        if (Auf.Z.MEH='%') then begin

// 07.05.2015 Warum immer??          Auf.Z.RabattierbarYN # y;   // IMMER Rabattierbar

          Auf.Z.Preis # vPosRabbar1;
          Auf.Z.PEH   # 100;
          vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
          vPosNetto # vPosNetto + vPreis;

          if (vPreis<>0.0) then begin
            vMwstNetto1 # vMwstNetto1 + vPreis;
            if (Auf.Z.RabattierbarYN) then
              vPosRabbar1    # vPosRabbar1 + vPreis;
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vPosRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vPosRabbar2,2)+')');
@endif

            // Erlöskonto anlegen
            Erl.K.Auftragsart     # Auf.P.Auftragsart;
            Erl.K.Projektnr       # Auf.P.Projektnummer;
            Erl.K.Warengruppe     # Auf.P.Warengruppe;
            "Erl.K.Güte"          # "Auf.P.Güte";
            "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
            // 14.05.2013: ggf. Warengruppe aus Aufpreis holen
            if (Auf.Z.Warengruppe<>0) then begin
              Erx # RekLink(819,403,1,_recFirst);
              if (Erx<=_rLocked) then begin
                Erl.K.Warengruppe     # Auf.Z.Warengruppe;
                "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
              end;
              Erx # RecLink(819,401,1,_recFirst);
            end;
            Erl.K.Artikelnummer   # Auf.P.Artikelnr;
            if (Auf.Z.Vpg.Artikelnr<>'') then
              Erl.K.Artikelnummer   # Auf.Z.Vpg.Artikelnr;

            Erl.K.Betrag          # vPreis;
            Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
            "Erl.K.Stückzahl"     # 0;
            Erl.K.Gewicht         # 0.0;
            Erl.K.Menge           # Auf.Z.Menge;
            Erl.K.EKPreisSummeW1  # 0.0;
            "Erl.K.CO2Einstand"   # 0.0;
            "Erl.K.CO2Zuwachs"    # 0.0;
            Erl.K.InterneKostW1   # 0.0;
            Erl.K.MEH             # Auf.Z.MEH;
            Erl.K.Bemerkung       # Auf.Z.Bezeichnung;
            Erl.K.AufpreisSchl    # "Auf.Z.Schlüssel";
            Erl.K.Auftragsnr      # Auf.P.Nummer;
            Erl.K.Auftragspos     # Auf.P.Position;
            Erl.K.RechnungsPos    # vAnzahlPos;
            Erl.K.Steuerschl      # vMwStSatz1;
            // bei LF-Buchungen nicht anlegen!
            if (Set.Auf.GutBelLFNull=false) or
              ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
              Erx # InsertKonto(vKontoTxt);
              if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
            end;
          end;  // MwSt1

          // Mwst2
          Auf.Z.Preis # vPosRabbar2;
          Auf.Z.PEH   # 100;
          vPreis # Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
          vPosNetto # vPosNetto + vPreis;

          if (vPreis<>0.0) then begin
            vMwstNetto2 # vMwstNetto2 + vPreis;
            if (Auf.Z.RabattierbarYN) then
              vPosRabbar2    # vPosRabbar2 + vPreis;
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vPosRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vPosRabbar2,2)+')');
@endif

            // Erlöskonto anlegen
            Erl.K.Auftragsart     # Auf.P.Auftragsart;
            Erl.K.Projektnr       # Auf.P.Projektnummer;
            Erl.K.Warengruppe     # Auf.P.Warengruppe;
            "Erl.K.Güte"          # "Auf.P.Güte";
            "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
            // 14.05.2013: ggf. Warengruppe aus Aufpreis holen
            if (Auf.Z.Warengruppe<>0) then begin
              Erx # RekLink(819,403,1,_recFirst);
              if (Erx<=_rLocked) then begin
                Erl.K.Warengruppe     # Auf.Z.Warengruppe;
                "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
              end;
              Erx # RecLink(819,401,1,_recFirst);
            end;
            Erl.K.Artikelnummer   # Auf.P.Artikelnr;
            if (Auf.Z.Vpg.Artikelnr<>'') then
              Erl.K.Artikelnummer   # Auf.Z.Vpg.Artikelnr;

            Erl.K.Betrag          # vPreis;
            Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
            "Erl.K.Stückzahl"     # 0;
            Erl.K.Gewicht         # 0.0;
            Erl.K.Menge           # Auf.Z.Menge;
            "Erl.K.CO2Einstand"   # 0.0;
            "Erl.K.CO2Zuwachs"    # 0.0;
            Erl.K.EKPreisSummeW1  # 0.0;
            Erl.K.InterneKostW1   # 0.0;
            Erl.K.MEH             # Auf.Z.MEH;
            Erl.K.Bemerkung       # Auf.Z.Bezeichnung;
            Erl.K.AufpreisSchl    # "Auf.Z.Schlüssel";
            Erl.K.Auftragsnr      # Auf.P.Nummer;
            Erl.K.Auftragspos     # Auf.P.Position;
            Erl.K.RechnungsPos    # vAnzahlPos;
            Erl.K.Steuerschl      # vMwstSatz2;
            // bei LF-Buchungen nicht anlegen!
            if (Set.Auf.GutBelLFNull=false) or
              ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
              Erx # InsertKonto(vKontoTxt);
              if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
            end;
          end;  // MwSt2

        end;
        Erx # RecLink(403,401,6,_RecNext);
      END;

      // KopfAufpreise: MEH-bezogen
      // KopfAufpreise: MEH-Bezogen
      // KopfAufpreise: MEH-Bezogen
      Erx # RecLink(403,400,13,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
        if (Auf.Z.MengenbezugYN) and (Auf.Z.MEH<>'%') and (Auf.Z.Position=0) then begin
          // PosMEH in AufpreisMEH umwandeln
          vMenge # Lib_Einheiten:WandleMEH(403, vPosStk, vPosGewicht, vPosMenge, Auf.P.MEH.Preis, Auf.Z.MEH)
          vPreis #  Rnd(Auf.Z.Preis * vMenge / CnvFI(Auf.Z.PEH),2);
          vPosNetto # vPosNetto + vPreis;

          // für Rervers-Charge
          if (Auf.Z.Warengruppe<>0) and (Auf.Z.Warengruppe<>Wgr.Nummer) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx>_rLocked) then
              RETURN RE_ABBRUCH(Erx, vKontoTxt, 400094,0,aint(Auf.Z.Nummer)+'/'+aint(Auf.Z.Position)+'/'+aint(Auf.Z.lfdNr));
          end;
          SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vMwStNetto1, var vMwstSatz2, var vMwStProz2, var vMwstNetto2);
          if (Auf.Z.RabattierbarYN) then begin
            SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vPosRabbar1, var vMwstSatz2, var vMwStProz2, var vPosRabbar2);
          end;
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vPosRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vPosRabbar2,2)+')');
@endif

          // Erlöskonto anlegen
          Erl.K.Auftragsart     # Auf.P.Auftragsart;
          Erl.K.Projektnr       # Auf.P.Projektnummer;
          Erl.K.Warengruppe     # Auf.P.Warengruppe;
          "Erl.K.Güte"          # "Auf.P.Güte";
          "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
          // 14.05.2013: ggf. Warengruppe aus Aufpreis holen
          if (Auf.Z.Warengruppe<>0) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx<=_rLocked) then begin
              Erl.K.Warengruppe     # Auf.Z.Warengruppe;
              "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
            end;
            Erx # RecLink(819,401,1,_recFirst);
          end;
          Erl.K.Artikelnummer   # Auf.P.Artikelnr;
          if (Auf.Z.Vpg.Artikelnr<>'') then
            Erl.K.Artikelnummer   # Auf.Z.Vpg.Artikelnr;

          Erl.K.Betrag          # vPreis;
          Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
          "Erl.K.Stückzahl"     # 0;
          Erl.K.Gewicht         # 0.0;
          Erl.K.Menge           # vMenge;
          Erl.K.EKPreisSummeW1  # 0.0;
          "Erl.K.CO2Einstand"   # 0.0;
          "Erl.K.CO2Zuwachs"    # 0.0;
          Erl.K.InterneKostW1   # 0.0;
          Erl.K.MEH             # Auf.Z.MEH;
          Erl.K.Bemerkung       # Auf.Z.Bezeichnung;
          Erl.K.AufpreisSchl    # "Auf.Z.Schlüssel";
          Erl.K.Auftragsnr      # Auf.P.Nummer;
          Erl.K.Auftragspos     # Auf.P.Position;
          Erl.K.RechnungsPos    # vAnzahlPos;
          Erl.K.Steuerschl      # StS.Nummer; // durch SumMwst gefüllt
          // bei LF-Buchungen nicht anlegen!
          if (Set.Auf.GutBelLFNull=false) or
            ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
            Erx # InsertKonto(vKontoTxt);
            if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
          end;
        end;
        Erx # RecLink(403,400,13,_RecNext);
      END;


      // Positionspreis steht ab hier fest!!!
      // Positionspreis steht ab hier fest!!!
      // Positionspreis steht ab hier fest!!!

      // 26.10.2016 AH : ggf. Material umbewerten
      if (vTyp=c_GUT) or (vTyp=c_BEL_LF) then begin
        if (vGbTermin=0.0.0) then vGbTermin # Auf.P.Termin1Wunsch;
        vGbMatKg # 0.0;
        FOR Erx # RecLink(404,401,12,_RecFirst)
        LOOP Erx # RecLink(404,401,12,_RecNext)
        WHILE (Erx<=_rLocked) do begin
//debugx('KEY404   '+auf.a.aktionstyp+'   '+aint(auf.a.rechnungsnr));
          if ("Auf.A.Löschmarker"='') and (Auf.A.Aktionstyp=c_Akt_GbMat) and (Auf.A.Rechnungsnr=0) then begin
            RecRead(404,1,_recLock | _Recnoload);
            Auf.A.Rechnungsnr     # Erl.Rechnungsnr;
            Auf.A.Rechnungsdatum  # Erl.Rechnungsdatum;
            Auf.A.Rechnungsmark   # '';
            Auf.A.Gewicht         # Mat_B_Data:GewichtZumDatum(Auf.A.Materialnr, vGbTermin);  // 17.11.2016
            Erx # RekReplace(404,_recUnlock,'AUTO');
            if (erx<>_rOK) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,894);
            vGbMatKg # vGbMatKg  - Auf.A.Gewicht;    // NEGATIV für Gutschrift
          end;
        END;

        // bei Materialkorrekturen dürfen KEINE Kopfaufpreise existieren
        if (vGbMatKg<>0.0) then begin
          if (vKopfAPExists) then begin
            RE_ABBRUCH(_rExists, vKontoTxt, 400099,918);
          end;
          vGbMatPreisProT # Rnd(vPosNetto / vGbMatKg * 1000.0,2);
          if (vTyp = c_REKOR) or (vTyp = c_Bel_Kd) then
            vGbMatPreisProT # -vGbMatPreisProT;
        end;
      end;  // Gut/Bel_LF


      // Preise in die Aktion schreiben
      Erx # RecLink(404,401,12,_RecFirst);
      WHILE (Erx<=_rLocked) do begin

        // 26.10.2016 AH : ggf. Material umbewerten
        if (vGbMatPreisProT<>0.0) then begin
          if ("Auf.A.Löschmarker"='') and (Auf.A.Aktionstyp=c_Akt_GbMat) and (Auf.A.Rechnungsnr=Erl.Rechnungsnr) then begin
            RecRead(404,1,_recLock | _Recnoload);
            Auf.A.interneKostW1 # Rnd(vGbMatPreisProT * Auf.A.Gewicht / 1000.0,2);
            Erx # RekReplace(404,_recUnlock,'AUTO');
            if (erx<>_rOK) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,373);
          end;
        end;


        if (Auf.A.Rechnungsnr=Erl.Rechnungsnr) and (RE_HoleReMenge()<>0.0) then begin
          RecRead(404,1,_RecLock);
  //        Auf.A.RechPreisW1 # vPosNetto / Auf.A.Menge;
  //debugx('KEY401 '+anum(vMwStNetto1,2)+' '+anum(vMwstNetto2,2)+' '+anum(vPosMenge,0)+' '+anum(RE_HoleReMenge(),2));
          if (vPosMenge=0.0) then
            Auf.A.Rechnungspreis  # 0.0
          else begin
            if (Set.Wie.Fakt.OhneNK) then
              Auf.A.Rechnungspreis  # vPosNetto / vPosMenge * RE_HoleReMenge()
            else
              Auf.A.Rechnungspreis  # Rnd( vPosNetto / vPosMenge * RE_HoleReMenge(),2);   // 02.02.2015 BUGFIX
          end;

          Auf.A.RechPEH           # Auf.P.PEH;
          if (Set.Wie.Fakt.OhneNK) then begin
            Auf.A.RechPreisW1       # Auf.A.Rechnungspreis / "Erl.K.Währungskurs";
            Auf.A.RechGrundPrsW1    # Auf.P.Grundpreis / "Erl.K.Währungskurs";
          end
          else begin
            Auf.A.RechPreisW1       # Rnd(Auf.A.Rechnungspreis / "Erl.K.Währungskurs",2);
            Auf.A.RechGrundPrsW1    # Rnd(Auf.P.Grundpreis / "Erl.K.Währungskurs",2);
          end;
          Erx # RekReplace(404,_recUnlock,'AUTO');
          if (erx<>_rOK) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,504);

          if (Auf.A.AktionsTyp<>c_Akt_GbMat) and
            ( (WGr_data:IstMat(Auf.P.Wgr.Dateinr) OR (WGr_data:IstMix(Auf.P.Wgr.Dateinr)) ) and (Auf.A.Materialnr<>0)) then begin
            Mat.Nummer # Auf.A.MaterialNr;
            Erx # RecRead(200,1,_RecLock);
            if (Erx=_rOK) then begin  // Materialbestand
              Mat.VK.Kundennr   # Erl.Kundennummer;
              Mat.VK.Rechnr     # Erl.Rechnungsnr;
              Mat.VK.Rechdatum  # Erl.Rechnungsdatum;
              if (VwA.NettoYN) then
                Mat.VK.Gewicht  # Auf.A.Nettogewicht
              else
                Mat.VK.Gewicht  # Auf.A.Gewicht;
              Mat.VK.Preis      # Auf.A.RechPreisW1;
              if (Mat.Bestand.Gew<>0.0) then begin
                if (Set.Wie.Fakt.OhneNK) then
                  Mat.VK.Preis      # Mat.VK.Preis / Mat.Bestand.Gew *1000.0
                else
                  Mat.VK.Preis      # Rnd(Mat.VK.Preis / Mat.Bestand.Gew *1000.0,2);
              end;
              Mat_data:Replace(_RecUnlock,'AUTO');
            end
            else begin  // Materialablage
              "Mat~Nummer" # Auf.A.MaterialNr;
              Erx # RecRead(210,1,_RecLock);
              if (Erx>=_rLocked) then begin
                RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,508);
              end;
              "Mat~VK.Kundennr"   # Erl.Kundennummer;
              "Mat~VK.Rechnr"     # Erl.Rechnungsnr;
              "Mat~VK.Rechdatum"  # Erl.Rechnungsdatum;
              if (VwA.NettoYN) then
                "Mat~VK.Gewicht" # Auf.A.Nettogewicht
              else
                "Mat~VK.Gewicht" # Auf.A.Gewicht;

              /* // Alte Variante
              if ("Mat~VK.Gewicht"<>0.0) then
                "Mat~VK.Preis"      # vPosGewicht / "Mat~VK.Gewicht"
              else if (Mat.Bestand.Gew<>0.0) then
                "Mat~VK.Preis"      # vPosGewicht / "Mat~Bestand.Gew"
              else "Mat~VK.Preis" # 0.0;
              */
              // ST 2015-07-20: Neue Variante, Analog zu Bestandsmaterial
              "Mat~VK.Preis"    # Auf.A.RechPreisW1;
              if ("Mat~VK.Gewicht"<>0.0) then begin
                if (Set.Wie.Fakt.OhneNK) then
                  "Mat~VK.Preis"      # "Mat~VK.Preis" / "Mat~VK.Gewicht" *1000.0
                else
                  "Mat~VK.Preis"      # Rnd("Mat~VK.Preis" / "Mat~VK.Gewicht" *1000.0,2);
              end
              else if ("Mat~Bestand.Gew"<>0.0) then begin
                if (Set.Wie.Fakt.OhneNK) then
                  "Mat~VK.Preis"      # "Mat~VK.Preis" / "Mat~Bestand.Gew" *1000.0
                else
                  "Mat~VK.Preis"      # Rnd("Mat~VK.Preis" / "Mat~Bestand.Gew" *1000.0,2);
              end;
              else "Mat~VK.Preis" # 0.0;

              Mat_Abl_data:ReplaceAblage(_RecUnlock,'AUTO');
            end;
          end;
        end;
        Erx # RecLink(404,401,12,_RecNext);
      END;

      Erl.Gewicht         # Erl.Gewicht + vPosGewicht;
      "Erl.Stückzahl"     # "Erl.Stückzahl" + vPosStk;
      Erl.VerpEinheiten   # Erl.VerpEinheiten + vPosAnzahlAkt;
      Erl.CO2Einstand     # Erl.CO2Einstand + vPosCO2EK;
      Erl.CO2Zuwachs      # Erl.CO2Zuwachs + vPosCO2Kost;
      
      // Aktionen neu berechnen...
      Auf_A_Data:RecalcAll();


@Ifdef Pruefen
debugx('=PosRabbar: '+anum(vPosRabbar1,2)+'   '+anum(vPosRabbar2,2));
@endif
      vMwStNettoRabbar1 # vMwStNettoRabbar1 + vPosRabbar1;
      vMwStNettoRabbar2 # vMwStNettoRabbar2 + vPosRabbar2;
      vPosRabbar1       # 0.0;
      vPosRabbar2       # 0.0;

      Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecNext);  // nächste Position
    END;  // Positionen
@Ifdef Pruefen
debugx('=GesmatRabbar: '+anum(vMwStNettoRabbar1,2)+'   '+anum(vMwStNettoRabbar2,2));
@endif


    // 2023-05-24 AH aber hier ALLGEMEINE KOPFAUFPREISE
    vNettoOhneKopfAP # vMwstNetto1 + vMwstNetto2;


    // KopfAufpreise: NICHT MEH-Bezogen =FIX
    // KopfAufpreise: NICHT MEH-Bezogen =FIX
    // KopfAufpreise: NICHT MEH-Bezogen =FIX
    FOR Erx # RecLink(403,400,13,_RecFirst)
    LOOP Erx # RecLink(403,400,13,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if (Auf.Z.PEH=0) then Auf.Z.PEH # 1;
      if (Auf.Z.Position=0) and (Auf.Z.MengenbezugYN=n) and (Auf.Z.MEH<>'%') and ((Auf.Z.Vpg.OKYN) or (Auf.z.Vpg.ArtikelNr='')) and
        (Auf.Z.Rechnungsnr=0) then begin

// 10.02.2020 Macht schon die initiale Neuberechnung        if (Auf.Z.PerFormelYN) and (Auf.Z.FormelFunktion<>'') then Call(Auf.Z.FormelFunktion,400, aBisLiefDatum); // 25.11.2019 NEU: Datum

        if (Auf.Z.Menge<>0.0) then begin
          vPreis #  Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
          if (vTyp=c_BOGUT) or (vTyp=c_REKOR) or (vTyp=c_GUT) then begin
            Negieren(vPreis);
          end;

          // für Rervers-Charge
          if (Auf.Z.Warengruppe<>0) and (Auf.Z.Warengruppe<>Wgr.Nummer) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx>_rLocked) then
              RETURN RE_ABBRUCH(Erx, vKontoTxt, 400094,0,aint(Auf.Z.Nummer)+'/'+aint(Auf.Z.Position)+'/'+aint(Auf.Z.lfdNr));
          end;
          Lib_faktura:SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vMwStNetto1, var vMwstSatz2, var vMwStProz2, var vMwstNetto2);
          if (Auf.Z.RabattierbarYN) then begin
            SumMwSt("Wgr.Steuerschlüssel", "Auf.Steuerschlüssel", vPreis, var vMwstSatz1, var vMwstProz1, var vMwstNettoRabbar1, var vMwstSatz2, var vMwStProz2, var vMwstNettoRabbar2);
          end;
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vMwstNettoRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vMwStNettoRabbar2,2)+')');
@endif

          if (Auf.Z.MengenbezugYN=n) then begin   // 30.01.2019 AH: wegen Formelfunktion
            RecRead(403,1,_RecLock);
            Auf.Z.Rechnungsnr # Erl.Rechnungsnr;
            RekReplace(403,_recUnlock,'AUTO');
          end;

          // Erlöskonto anlegen
          Erl.K.Auftragsart     # 0;
          Erl.K.Projektnr       # 0;
          Erl.K.Warengruppe     # 0;
          "Erl.K.Güte"          # '';
          "Erl.K.Erlöskonto"    # 0;
          // 14.05.2013: ggf. Warengruppe aus Aufpreis holen
          if (Auf.Z.Warengruppe<>0) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx<=_rLocked) then begin
              Erl.K.Warengruppe     # Auf.Z.Warengruppe;
              "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
            end;
            Erx # RecLink(819,401,1,_recFirst);
          end;
          Erl.K.Artikelnummer   # '';
          if (Auf.Z.Vpg.Artikelnr<>'') then
            Erl.K.Artikelnummer   # Auf.Z.Vpg.Artikelnr;

          Erl.K.Betrag          # vPreis;
          Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
          "Erl.K.Stückzahl"     # 0;
          Erl.K.Gewicht         # 0.0;
          Erl.K.Menge           # Auf.Z.Menge;
          Erl.K.EKPreisSummeW1  # 0.0;
          "Erl.K.CO2Einstand"   # 0.0;
          "Erl.K.CO2Zuwachs"    # 0.0;
          Erl.K.InterneKostW1   # 0.0;
          Erl.K.MEH             # Auf.Z.MEH;
          Erl.K.Bemerkung       # Auf.Z.Bezeichnung;
          Erl.K.AufpreisSchl    # "Auf.Z.Schlüssel";
          Erl.K.Auftragspos     # 0;
          Erl.K.RechnungsPos    # 0;
          Erl.K.Steuerschl      # StS.Nummer; // durch SumMwst gefüllt
          // bei LF-Buchungen nicht anlegen!
          if (Set.Auf.GutBelLFNull=false) or
            ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
            Erx # InsertKonto(vKontoTxt, vNettoOhneKopfAP);
            if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
          end;
        end;
      end;
    END;

    // KopfAufpreise: %
    // KopfAufpreise: %
    // KopfAufpreise: %
    Erx # RecLink(403,400,13,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      if (Auf.Z.Position=0) and //(Auf.Z.MengenbezugYN) and
        (Auf.Z.MEH='%') then begin

        Auf.Z.Preis # vMwStNettoRabbar1;
        Auf.Z.PEH   # 100;
        vPreis      #  Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);
        if (vPreis<>0.0) then begin
          vMwstNetto1 # vMwstNetto1 + vPreis;
          if (Auf.Z.RabattierbarYN) then
            vMwStNettoRabbar1    # vMwstNettoRabbar1 + vPreis;
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vMwStNettoRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vMwStNettoRabbar2,2)+')');
@endif
          // Erlöskonto anlegen
          Erl.K.Auftragsart     # 0;
          Erl.K.Projektnr       # 0;
          Erl.K.Warengruppe     # 0;
          "Erl.K.Güte"          # '';
          "Erl.K.Erlöskonto"    # 0;
          // 14.05.2013: ggf. Warengruppe aus Aufpreis holen
          if (Auf.Z.Warengruppe<>0) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx<=_rLocked) then begin
              Erl.K.Warengruppe     # Auf.Z.Warengruppe;
              "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
            end;
            Erx # RecLink(819,401,1,_recFirst);
          end;
          Erl.K.Artikelnummer   # '';
          if (Auf.Z.Vpg.Artikelnr<>'') then
            Erl.K.Artikelnummer   # Auf.Z.Vpg.Artikelnr;


          Erl.K.Betrag          # vPreis;
          Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
          "Erl.K.Stückzahl"     # 0;
          Erl.K.Gewicht         # 0.0;
          Erl.K.Menge           # Auf.Z.Menge;
          Erl.K.EKPreisSummeW1  # 0.0;
          "Erl.K.CO2Einstand"   # 0.0;
          "Erl.K.CO2Zuwachs"    # 0.0;
          Erl.K.InterneKostW1   # 0.0;
          Erl.K.MEH             # Auf.Z.MEH;
          Erl.K.Bemerkung       # Auf.Z.Bezeichnung;
          Erl.K.AufpreisSchl    # "Auf.Z.Schlüssel";
          Erl.K.Auftragspos     # 0;
          Erl.K.RechnungsPos    # 0;
          Erl.K.Steuerschl      # vMwStSatz1;
          // bei LF-Buchungen nicht anlegen!
          if (Set.Auf.GutBelLFNull=false) or
            ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
            Erx # InsertKonto(vKontoTxt, vNettoOhneKopfAP);
            if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
          end;
        end; // MWst1

        // MwSt2
        Auf.Z.Preis # vMwStNettoRabbar2;
        Auf.Z.PEH   # 100;
        vPreis      #  Rnd(Auf.Z.Preis * Auf.Z.Menge / CnvFI(Auf.Z.PEH),2);

        if (vPreis<>0.0) then begin
          vMwstNetto2 # vMwstNetto2 + vPreis;
          if (Auf.Z.RabattierbarYN) then
            vMwStNettoRabbar2    # vMwstNettoRabbar2 + vPreis;
@Ifdef Pruefen
debugx('add '+aNum(vPreis,2)+' : '+anum(vMwStNetto1,2)+'('+anum(vMwStNettoRabbar1,2)+')   '+anum(vMwStNetto2,2)+'('+anum(vMwStNettoRabbar2,2)+')');
@endif
          // Erlöskonto anlegen
          Erl.K.Auftragsart     # 0;
          Erl.K.Projektnr       # 0;
          Erl.K.Warengruppe     # 0;
          "Erl.K.Güte"          # '';
          "Erl.K.Erlöskonto"    # 0;
          // 14.05.2013: ggf. Warengruppe aus Aufpreis holen
          if (Auf.Z.Warengruppe<>0) then begin
            Erx # RekLink(819,403,1,_recFirst);
            if (Erx<=_rLocked) then begin
              Erl.K.Warengruppe     # Auf.Z.Warengruppe;
              "Erl.K.Erlöskonto"    # "Wgr.Erlösgruppe";
            end;
            Erx # RecLink(819,401,1,_recFirst);
          end;
          Erl.K.Artikelnummer   # '';
          if (Auf.Z.Vpg.Artikelnr<>'') then
            Erl.K.Artikelnummer   # Auf.Z.Vpg.Artikelnr;

          Erl.K.Betrag          # vPreis;
          Erl.K.BetragW1        # Rnd(Erl.K.Betrag / "Erl.K.Währungskurs",2)
          "Erl.K.Stückzahl"     # 0;
          Erl.K.Gewicht         # 0.0;
          Erl.K.Menge           # Auf.Z.Menge;
          Erl.K.EKPreisSummeW1  # 0.0;
          "Erl.K.CO2Einstand"   # 0.0;
          "Erl.K.CO2Zuwachs"    # 0.0;
          Erl.K.InterneKostW1   # 0.0;
          Erl.K.MEH             # Auf.Z.MEH;
          Erl.K.Bemerkung       # Auf.Z.Bezeichnung;
          Erl.K.AufpreisSchl    # "Auf.Z.Schlüssel";
          Erl.K.Auftragspos     # 0;
          Erl.K.RechnungsPos    # 0;
          Erl.K.Steuerschl      # vMwStSatz2;
          // bei LF-Buchungen nicht anlegen!
          if (Set.Auf.GutBelLFNull=false) or
            ((vTyp<>c_Gut) and (vTyp<>c_Bel_LF)) then begin
            Erx # InsertKonto(vKontoTxt, vNettoOhneKopfAP);
            if (Erx<>_rok) then RE_ABBRUCH(Erx, vKontoTxt, 400099,__Line__);
          end;
        end; // MWst2

      end;
      Erx # RecLink(403,400,13,_RecNext);
    END;

    if (aSel400=0) then     // normale Rechnung
      Erx # 99
    else                    // Sammelrechnug
      Erx # RecRead( 400, aSel400, _recNext );

  END;  // Köpfe loopen bei Sammelrechnung


  // wiederkehrende Aufpreise kopieren...
  FOR Erx # RecLink(403,400,13,_RecFirst)
  LOOP Erx # RecLink(403,400,13,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.Rechnungsnr=Erl.Rechnungsnr) and (Auf.Z.ProRechnungYN) then begin
      Auf.Z.Rechnungsnr # 0;
      vI # Auf.Z.lfdNr;
      REPEAT
        Auf.Z.lfdNr # Auf.Z.lfdNr + 1;
        Erx # RecRead(403,1,_recTest);
        if (Erx=_rOK) then CYCLE;
        Erx # RekInsert(403);
        if (Erx<>_rOK) then CYCLE;
      UNTIL (Erx=_rOK);
      Auf.Z.LfdNr # vI;
      RecRead(403,1,0);
    end;
  END;


  // Steuern errechnen
  if (vMwStSatz1>0) then begin
    vMwStWert1 # Rnd(vMwstNetto1 * (vMwStProz1/100.0),2)
  end
  else vMwStWert1 # 0.0;
  if (vMwStSatz2>0) then begin
    vMwStWert2 # Rnd(vMwstNetto2 * (vMwStProz2/100.0),2)
  end
  else vMwStWert2 # 0.0;

  // RECHNUNSENDPREIS STEHT AB HIER FEST!!
  // RECHNUNSENDPREIS STEHT AB HIER FEST!!
  // RECHNUNSENDPREIS STEHT AB HIER FEST!!

  // Passt der ausgedruckte Preis zum verbuchten? oder DIFFERENZ?
/*
  if (Erl.Netto<>vGesamtNetto) or (Erl.Steuer<>vGesamtMwSt) then begin
    if (lib_Nummern:RestoreNummer('Rechnung', Erl.Rechnungsnr)) then Msg(400096,'',0,0,0) else Msg(400095,'',0,0,0);
    while Msg(400097,CnvAF(Erl.Netto+Erl.Steuer)+'|'+CnvAF(vGesamtNetto+vGesamtMwSt),_winicoerror,_windialogokcancel,1)=_winidOk do begin end;
    RETURN false;
  end;
*/

/***
if (lib_Nummern:RestoreNummer('Rechnung',Erl.Rechnungsnr)) then Msg(400096,'',0,0,0) else Msg(400095,'',0,0,0);
while Msg(400097,CnvAF(Erl.Netto+Erl.Steuer)+'|'+CnvAF(vGesamtNetto+vGesamtMwSt),_winicoerror,_windialogokcancel,1)=_winidOk do begin end;
RETURN false;
***/

@Ifdef Pruefen
debugx('ENDE VERBUCHUNG');
@endif



  // *************************************************************
  // Erlös/Umsatz anlegen
  // *************************************************************
  Erl.Netto         # Rnd(vMwStNetto1 + vMwStNetto2,2);
  Erl.NettoW1       # Rnd(Erl.Netto / "Erl.Währungskurs",2);
  Erl.Steuer        # Rnd(vMwStWert1 + vMwStWert2,2);
  Erl.SteuerW1      # Rnd(Erl.Steuer / "Erl.Währungskurs",2);
  Erl.Brutto        # Rnd(Erl.Netto + Erl.Steuer,2);
  Erl.BruttoW1      # Rnd(Erl.Brutto / "Erl.Währungskurs",2);
  Erl.Auftragsnr    # Auf.Nummer;
  if (vPrjNr>0) then Erl.Projektnr # vPrjNr;
  
  vBuf450 # RekSave(450);
  // bei LF-Buchungen nicht anlegen...
  if (Set.Auf.GutBelLFNull) and
    ((vTyp=c_Gut) or (vTyp=c_Bel_LF)) then begin
    Erl.Netto         # 0.0;
    Erl.NettoW1       # 0.0;
    Erl.Steuer        # 0.0;
    Erl.SteuerW1      # 0.0;
    Erl.Brutto        # 0.0;
    Erl.BruttoW1      # 0.0;
  end;
  Erx # Erl_Data:Insert(0,'AUTO');
  if (Erx<>_rOK) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,671);
  RekRestore(vBuf450);

  Erx # RecLink(100,450,8,_recFirst);   // Rech.Empf holen
  RecRead(100,1,_recLock);
  Adr.Fin.letzteReAm # today;
  RekReplace(100,_recUnlock,'AUTO');


  // *************************************************************
  // Offenen Posten anlegen
  // *************************************************************
  if (vTyp<>c_GUT) and (vTyp<>c_BEL_LF) then begin
    OfP.Rechnungsnr     # Erl.Rechnungsnr;
    OfP.Netto           # Erl.Netto;
    OfP.NettoW1         # Erl.NettoW1;
    OfP.Steuer          # Erl.Steuer;
    OfP.SteuerW1        # Erl.SteuerW1;
    OfP.Brutto          # Erl.Brutto;
    OfP.BruttoW1        # Erl.BruttoW1;
    OfP.Skonto          # Rnd(OfP.Brutto / 100.0 * OfP.SkontoProzent,2);
    OfP.SkontoW1        # Rnd(OfP.Skonto / "OfP.Währungskurs",2);
    OfP.Rest            # Erl.Brutto;
    OfP.RestW1          # Erl.BruttoW1;
    OfP.Anlage.Datum    # Today;
    OfP.Anlage.Zeit     # now;
    OfP.Anlage.User     # guserName;
    OfP.Wiedervorlage   # OfP_Data:BerechneWiedervorlage(); // ST 2009-02-06 hinzugefügt
    OfP.Projektnr       # Erl.Projektnr;
    Erx # RekInsert(460,0,'AUTO');
    if (erx<>_rOK) then RETURN RE_ABBRUCH(Erx, vkontoTxt, 400099,1038);
  end;

  // *************************************************************
  // Eingangsrechnung anlegen
  // *************************************************************
  if (vTyp=c_GUT) or (vTyp=c_BEL_LF) then begin
    vAdr # ADr.nummer;
    RecBufClear(560);
    ERe.Nummer # Lib_Nummern:ReadNummer('Eingangsrechnung');
    if (ERe.Nummer<>0) then Lib_Nummern:SaveNummer()
    else begin
      Lib_Nummern:FreeNummer();
      WHILE (Msg(400099,aint(1047),_winicoerror,_windialogokcancel,1)=_winidOk) DO begin
      END;
      RETURN false;
    end;
    ERe.Lieferant       # Adr.Lieferantennr;
    ERe.LieferStichwort # Adr.Stichwort;
    ERe.Projektnr       # Auf.P.Projektnummer;
    ERe.Rechnungsnr     # vTyp+' '+cnvai(Erl.Rechnungsnr,_FmtNumNoGroup);
    ERe.Rechnungsdatum  # Erl.Rechnungsdatum;
    ERe.WertstellungsDat # Erl.Rechnungsdatum;
    if (vGbMatKg<>0.0) then
      ERe.WertstellungsDat # vGbTermin;

    ERe.Rechnungstyp    # Erl.Rechnungstyp;
    "ERe.Währung"       # "Erl.Währung";
    "ERe.Währungskurs"  # "Erl.Währungskurs";
    ERe.Valuta          # Ofp.Valutadatum;
    ERe.Zieldatum       # OfP.Zieldatum;
    ERe.Skontodatum     # OfP.Skontodatum;
    ERe.Skontoprozent   # OfP.Skontoprozent;
    ERe.Wiedervorlage   # ERe.Zieldatum
    ERe.Adr.Steuerschl  # Erl.Adr.Steuerschl;
    ERe.LKZ             # Adr.LKZ;
    "ERe.Stückzahl"     # (-1) * "Erl.Stückzahl";
    ERe.Gewicht         # (-1.0) * Erl.Gewicht;
    ERe.Netto           # (-1.0) * Erl.Netto;
    ERe.NettoW1         # (-1.0) * Erl.NettoW1;
    ERe.Steuer          # (-1.0) * Erl.Steuer;
    ERe.SteuerW1        # (-1.0) * Erl.SteuerW1;
    ERe.Brutto          # (-1.0) * Erl.Brutto;
    ERe.BruttoW1        # (-1.0) * Erl.BruttoW1;
    ERe.Skonto          # Rnd(ERe.Brutto / 100.0 * ERe.SkontoProzent,2);
    ERe.SkontoW1        # Rnd(ERe.Skonto / "ERe.Währungskurs",2);
    ERe.Rest            # Rnd(ERe.Brutto - ERe.Zahlungen,2);
    ERe.RestW1          # Rnd(ERe.BruttoW1 - ERe.ZahlungenW1,2);
    ERe.InOrdnung       # true;   // 15.11.2016 AH

    ERe.Anlage.Datum    # Today;
    ERe.Anlage.Zeit     # now;
    ERe.Anlage.User     # guserName;
    Erx # RekInsert(560,0,'AUTO');
    if (erx<>_rOK) then begin
      Lib_Nummern:FreeNummer();
      WHILE Msg(400099,aint(1077),_winicoerror,_windialogokcancel,1)=_winidOk DO begin
      END;
      RETURN false;
    end;


    // 26.10.2016 AH : ggf. Material umbewerten
    v400 # RekSave(400);
    vDiffTxt # TextOpen(20);
    FOR Erx # RecLink(404,400,15,_RecFirst) // Aktionen loopen
    LOOP Erx # RecLink(404,400,15,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if ("Auf.A.Löschmarker"='') and (Auf.A.Aktionstyp=c_Akt_GbMat) and (Auf.A.Rechnungsnr=Erl.Rechnungsnr) and (Auf.A.InterneKostW1<>0.0) then begin
        vDatei # Mat_Data:Read(Auf.A.Materialnr);

        if (Set.Installname='HWE') then begin   // 2022-09-12  AH
          vX1 # Mat.EK.Preis + (Auf.A.InterneKostW1 / Auf.A.Gewicht * 1000.0);
          vX2 # vX1 * Mat.Bestand.Gew / 1000.0;
          if (Mat.Bestand.Menge<>0.0) then
            vX2 # vX2 / Mat.Bestand.Menge;
          if (Mat_Data:SetUndVererbeEkPreis(vDatei, vGBTermin, vX1, vX2, Mat.MEH, vDiffTxt)=false) then begin
            RekRestore(v400);
            RETURN false;
          end;
        end;
        RecBufClear(204);
        Mat.A.Materialnr    # Mat.Nummer;
        Mat.A.Aktionsmat    # Mat.Nummer;
        Mat.A.Aktionstyp    # c_Akt_GbMat;
        Mat.A.Aktionsnr     # Auf.P.Nummer;
        Mat.A.Aktionspos    # Auf.P.Position;
        Mat.A.EK.RechNr     # ERe.Nummer;
        Mat.A.Bemerkung     # c_AktBem_GbMat;
        Mat.A.Aktionsdatum  # vGbTermin;//Erl.Rechnungsdatum;
        Mat.A.Terminstart   # vGbTermin;//Erl.Rechnungsdatum;
        Mat.A.Terminende    # vGbTermin;//Erl.Rechnungsdatum;
        Mat.A.Adressnr      # vAdr;

        if (Set.Installname='HWE') then begin   // 2022-09-12  AH
          Mat.A.Kosten2W1      # Rnd(Auf.A.InterneKostW1 / Auf.A.Gewicht * 1000.0,2);
        end
        else begin
          Mat.A.KostenW1      # Rnd(Auf.A.InterneKostW1 / Auf.A.Gewicht * 1000.0,2);
        end;
        
        Erx # Mat_A_data:Insert(0,'AUTO')
        if (erx<>_rOK) then RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,1398);
        if (vDatei=200) then begin
          if (Mat_A_Data:Vererben('', 200, vDiffTxt)=false) then begin
            //if (Erx<>_rOK) then
            RekRestore(v400);
            RETURN RE_ABBRUCH(Erx, vKontoTxt, 400099,1401);
          end;
        end
        else begin
          if (Mat_A_Data:Vererben('', 210, vDiffTxt)=false) then begin
            //if (Erx<>_rOK) then
            RekRestore(v400);
            RETURN RE_ABBRUCH(_rNoRec, vKontoTxt, 400099,1406);
          end;
        end;
        RecBufCopy(v400, 400);
      end;
    END;
    RecBufDestroy(v400);

//Textwrite(vDifftxt, 'e:\debug\debug2.txt', _textExtern);
    v450 # RekSave(450);
    Erl_Data:ParseDiffText(vDiffTxt, false, 'GUBE');   // NICHT als EK, sondern Kosten
    RekRestore(v450);
    TextClose(vDiffTxt);

  end;


  // Onlinestatistik verbuchen
  OSt_Data:StackErloes();
  if (vTyp=c_BOGUT) or (vTyp=c_REKOR) or (vTyp=c_GUT) then begin
    if (OsT_Data:BucheRechnung('GUT')=False) then RETURN RE_ABBRUCH(-1, vKontoTxt, 400099,1083);
  end
  else if (vTyp=c_BEL_KD) or (vTyp=c_BEL_LF) then begin
    if (OsT_Data:BucheRechnung('BEL')=False) then RETURN RE_ABBRUCH(-1, vKontoTxt, 400099,1086);
  end
  else begin
    if (OsT_Data:BucheRechnung('RE')=False) then RETURN RE_ABBRUCH(-1, vKontoTxt, 400099,1089);
  end;


  if (vKontoTxt<>0) then TextClose(vKontoTxt);


  // *************************************************************
  // ggf.Vorkasse buchen...
  // *************************************************************
  vMenge # Erl.Brutto;
  if (aSel400=0) then         // einfache Rechnung
    Erx # RecRead( 400, 1, 0)
  else                        // Sammelrechnung
    Erx # RecRead( 400, aSel400, _recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(404,400,15,_RecFirst); // Aktionen loopen
    WHILE (Erx<=_rLocked) and (vMenge>0.0) do begin
      if (Auf.A.Aktionstyp=c_Akt_Kasse) and ("Auf.A.Löschmarker"='') and (Auf.A.Menge>0.0) then begin
        RecRead(404,1,_RecLock);
        if (Auf.A.Menge<vMenge) then begin
          Auf.A.Menge # 0.0;
          vMenge # vMenge - Auf.A.Menge;
        end
        else begin
          Auf.A.Menge # Auf.A.Menge - vMenge;
          vMenge # 0.0;
        end;
        Erx # RekReplace(404,_recUnlock,'AUTO');
      end;

      Erx # RecLink(404,400,15,_RecNext);
    END;

    if (aSel400=0) then     // normale Rechnung
      Erx # 99
    else                    // Sammelrechnug
      Erx # RecRead( 400, aSel400, _recNext );
  END;


  // Ankerfunktion
  RunAFX('Auf.Rechnung.Verbucht.PreMark',aint(aSel400));

  
  // Markierungen richtig setzen...
  if (aSel400=0) then         // einfache Rechnung
    Erx # RecRead( 400, 1, 0)
  else                        // Sammelrechnung
    Erx # RecRead( 400, aSel400, _recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecFirst);
    WHILE (Erx<_rLocked) do begin
      RecRead(401,1,_RecLock);
      Auf_Data:Pos_BerechneMarker();
      // 27.10.2016 Auf_Data:PosReplace(_recUnlock,'AUTO');
      Erx # RekReplace(401);
      Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecNext);
    END;
    RecRead(400,1,_RecLock);
    Auf_Data:BerechneMarker();
    Erx # RekReplace(400,_recUnlock,'AUTO');

    if (aSel400=0) then     // normale Rechnung
      Erx # 99
    else                    // Sammelrechnug
      Erx # RecRead( 400, aSel400, _recNext );
  END;

  RETURN true;
end;


//========================================================================
// RE_Vorbereiten
//
//========================================================================
sub RE_Vorbereiten(
  var aReDatum          : date;
  aBisLiefDatum         : date;
  aSkontoDatum          : date;
  aSkontoProzent        : float;
  aZielDatum            : date;
  aValutadatum          : date;
  aSilent               : logic;
  opt aNurLFS           : int;
) : logic;
local begin
  Erx                   : int;
  vLetztesLiefDatum     : date;
  vBuf100               : int;
  vOffenerLFA           : logic;
  vOK                   : logic;
  vM                    : float;
end;
begin

  APPOFF();

  // Lieferdatum merken!!!
  Gv.Datum.01 # aBisLiefDatum;
  Gv.Int.10   # aNurLfs;

  // Aufpreise refreshen
  ApL_Data:Neuberechnen(400, aBisLiefDatum);


  // Aufpreisköpfe durchlaufen und Verpackungen summieren...  25.11.2019
  FOR Erx # RecLink(403,400,13,_recFirst)
  LOOP Erx # RecLink(403,400,13,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.Position<>0) then CYCLE;
    if (Auf.Z.Rechnungsnr<>0) or (Auf.Z.Vpg.ArtikelNr='') then CYCLE;
    if (Auf.Z.MengenbezugYN=false) then CYCLE;

    // Offener, unberechneter Vpg-Artikel-Aufpreis?
    vM # 0.0;
    // passende Aktionen finden...
    FOR Erx # RecLink(404,400,15,_RecFirst)
    LOOP Erx # RecLink(404,400,15,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      if ("Auf.A.Löschmarker"='*') or
        (Auf.A.TerminEnde>aBisLiefDatum) or (Auf.A.TerminEnde=0.0.0) or
        (Auf.A.Rechnungsdatum<>0.0.0) then
        CYCLE;

      if (Auf.A.Aktionstyp=c_Akt_LFS_VPG) and (Auf.A.ArtikelNr=Auf.Z.Vpg.ArtikelNr) then begin
        vM # vM + Auf.A.Menge;
      end;
    END;
    
    if (vM<>Auf.Z.Menge) then begin
      RecRead(403,1,_RecLock);
      Auf.Z.Menge # vM;
      RekReplace(403);
//debugx('MOD KEY403 auf '+anum(auf.z.menge,0)+Auf.Z.MEH);
    end;
  END;

  

  // Positionen durchlaufen
  vLetztesLiefDatum # 0.0.0;
  FOR Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecFirst)
  LOOP Erx # RecLink(401,400,"Set.Auf.Kopf<>PosRel",_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if ("Auf.P.Löschmarker"='*') then CYCLE;

    // Warengruppe holen
    Erx # RecLink(819,401,1,_recFirst);
    if (Erx>_rLocked) then begin
      APPON();
      Msg(001201,Translate('Warengruppe'),0,0,0);
      RETURN false;
    end;

    if (WGr_data:IstMat(Auf.P.Wgr.Dateinr)) then begin
      // Verwiegungsart holen
      Erx # RecLink(818,401,9,_recFirst);
      if (Erx>_rLocked) then begin
        RecBufClear(818);
        VwA.NettoYN # y;
      end;
    end
    else begin  // Artikel haben immer NETTOGEWICHT
      RecBufClear(818);
      VwA.NettoYN # Y;
    end;

    // Aktionen durchlaufen
    vOK # false;
    FOR Erx # RecLink(404,401,12,_RecFirst)
    LOOP Erx # RecLink(404,401,12,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      if ("Auf.A.Löschmarker"='*') or (Auf.A.Rechnungsmark<>'$') or
        (Auf.A.TerminEnde>aBisLiefDatum) or (Auf.A.TerminEnde=0.0.0) or
        (Auf.A.Rechnungsdatum<>0.0.0) then
        CYCLE;

      // 11.05.2017 AH
      if (aNurLFS<>0) then begin
        if (Auf.A.Aktionsnr<>aNurLFS) or (Auf.A.Aktionstyp<>c_Akt_Lfs) then begin
          CYCLE;
        end;
      end;

      // 2023-02-10 AH
      if (Auf.A.MEH.Preis<>Auf.P.MEH.Preis) then begin
        APPON();
        Msg(450012,aint(auf.A.Nummer)+'/'+aInt(Auf.A.Position)+'/'+aint(Auf.A.Aktion),0,0,0);
        RETURN false;
      end;


      vOK # y;
      if (Erx=_rLocked) then begin
        APPON();
        Msg(400002,AInt(Auf.P.Position),0,0,0);
        RETURN false;
      end;
      Erx # RecRead(401,1,0);
      if (Erx=_rLocked) then begin
        APPON();
        Msg(450003,AInt(Auf.P.Position),0,0,0);
        RETURN false;
      end;


      // 15.07.2015
      if (Auf.A.Aktionstyp=c_Akt_LFS) then begin
        Erx # RecLink(440,404,11,_recFirst);  // LFS-Kopf holen
        if (Erx<=_rLocked) and (Lfs.ZuBA.Nummer<>0) and (Lfs.Datum.Verbucht=0.0.0) then
          vOffenerLFA # true;
      end;

      // letztes Lieferdatum bestimmen
      if (Auf.A.TerminEnde>vLetztesLiefDatum) then
        vLetztesLiefDatum # Auf.A.TerminEnde;
    END;  // Aktionen

    // bei ReKor Rechnungsnummer prüfen
    if (vOK) and (Auf.Vorgangstyp=c_REKOR) then begin
      if (Auf.P.AbrufAufNr=0) and
         (DbaLicense(_DbaSrvLicense)<>'TA152658MN') then begin     // nicht bei Holzrichter VFP
        APPON();
        Msg(450011,AInt(Auf.P.Position),0,0,0);
        RETURN false;
      end;
    end;

  END;  // Positionen



  // Keine Aktionen im Zeitraum gefunden?
  if (vLetztesLiefDatum=0.0.0) then begin
    APPON();
    if (aSilent=n) then Msg(400001,CnvAD(aReDatum),0,0,0);
    RETURN false;
  end;

  if (aReDatum=0.0.0) then aReDatum # vLetztesLiefDatum;

  if (ZaB.abLFSDatumYN) then aValutadatum # vLetztesLiefDatum
  else OfP.ValutaDatum  # aReDatum;


  // 15.07.2015
  if (vOffenerLFA) then begin
    APPON();
    if (Msg(450108,'',_WinIcoWarning,_WinDialogYesNo,2)<>_WinidYes) then RETURN false;
    APPOFF();
  end;


  // Rechnungssdatum prüfen
  if (Lib_Faktura:AbschlussTest(aReDatum)=n) then begin
    APPON();
    Msg(450100,CnvAD(aReDatum),0,0,0);
    RETURN false;
  end;

  // Rechnungsempf. holen
  Erx # RecLink(100,400,4,_recFirst);
  if (Erx>_rLocked) then begin
    APPON();
    Msg(001201,Translate('Rechnungsempfänger'),0,0,0);
    RETURN false;
  end;

  // Kunde holen
  Erx # RecLink(100,400,1,_recFirst);
  if (Erx>_rLocked) then begin
    APPON();
    Msg(001201,Translate('Kunde'),0,0,0);
    RETURN false;
  end;

  // Währung holen
  Erx # RecLink(814,400,8,_recFirst);
  if (Erx>_rLocked) then begin
    APPON();
    Msg(001201,Translate('Währung'),0,0,0);
    RETURN false;
  end;

  // Erlösdatei und "Offenen Posten" vorbelegen
  RecBufClear(450);
  RecRead(400,1,0);   //  ST 2023-06-01: Zur Sicherheit Auftragskopf erneut lesen, damit möglichge Feldpufferänderungen an der 400 hinfällig werden
  Erl.Rechnungsdatum  # aReDatum;
 

  if (Auf.Vorgangstyp=c_BOGUT) then
    Erl.Rechnungstyp    # c_Erl_BOGUT
  else if (Auf.Vorgangstyp=c_REKOR) then
    Erl.Rechnungstyp    # c_Erl_REKOR
  else if (Auf.Vorgangstyp=c_GUT) then
    Erl.Rechnungstyp    # c_Erl_Gut
  else if (Auf.Vorgangstyp=c_BEL_Kd) then
    Erl.Rechnungstyp    # c_Erl_Bel_KD
  else if (Auf.Vorgangstyp=c_BEL_LF) then
    Erl.Rechnungstyp    # c_Erl_Bel_LF
  else
    Erl.Rechnungstyp    # c_Erl_VK
  Erl.Kundennummer    # Auf.Kundennr;
  Erl.KundenStichwort # Auf.KundenStichwort;
  Erl.Vertreter       # Auf.Vertreter;
  Erl.Verband         # Auf.Vertreter2;//Adr.Verband;
  "Erl.Währung"       # "Auf.Währung";
  if ("Auf.WährungFixYN") then
    Wae.VK.Kurs       # "Auf.Währungskurs";
  "Erl.Währungskurs"  # Wae.VK.Kurs;
  Erl.Rechnungsempf   # Auf.Rechnungsempf;
  Erl.Zahlungsbed     # Auf.Zahlungsbed;
  vBuf100 # Adr_Data:HoleBufferAdrOderAnschrift(Erl.Rechnungsempf, Auf.Rechnungsanschr);
  if (vBuf100<>0) then begin
    Erl.Adr.USIdentNr   # vBuf100->Adr.USIdentNr;
    Erl.Adr.Steuerschl  # vBuf100->"Adr.Steuerschlüssel";
    RecBufDestroy(vBuf100);
    vBuf100 # 0;
  end;
  Erl.Adr.Steuerschl  # "Auf.Steuerschlüssel";

  // "Offenen Posten" vorbelegen
  RecBufClear(460);
  OfP.Rechnungsdatum  # Erl.Rechnungsdatum;
  OfP.Rechnungstyp    # Erl.Rechnungstyp;

  Erx # RecLink(100,450,8,_recFirst); // Rechnungsempfänger holen
  OfP.Kundennummer    # Erl.Rechnungsempf;
  OfP.KundenStichwort # Adr.Stichwort;
  Erx # RecLink(100,400,1,_recFirst); // Kunde holen

  OfP.Vertreter       # Erl.Vertreter;
  OfP.Verband         # Erl.Verband;
  "OfP.Währung"       # "Erl.Währung";
  "OfP.Währungskurs"  # "Erl.Währungskurs";
  OfP.Lieferbed       # Auf.Lieferbed;
  OfP.Zahlungsbed     # Auf.Zahlungsbed;
  OfP.Auftragsnr      # Auf.Nummer;

  // Skontodaten errechnen & überschreiben
  //OfP_Data:BerechneZielDaten(aReDatum);

  OfP_Data:BerechneZielDaten(aValutadatum);
  if (aZielDatum     != 0.0.0) then
    OfP.Zieldatum     # aZielDatum;
  if (aSkontoDatum   != 0.0.0) then
    OfP.Skontodatum   # aSkontoDatum
  if (aSkontoProzent != 0.0) then
    OfP.Skontoprozent # aSkontoProzent
  //if (aValutadatum   != 0.0.0) then
  //  OfP.Valutadatum   # aValutadatum;

  /*
  if (ZaB.IndividuellYN=y) then begin
    OfP.ZielDatum       # aZielDatum;
    OfP.SkontoDatum     # aSkontoDatum;
    OfP.SkontoProzent   # aSkontoProzent;
    OfP.Valutadatum     # aValutadatum;
  end
  else begin
    // Skontodaten errechnen
    OfP_Data:BerechneZielDaten(aReDatum);
  end;
  */
  Erl.Skontodatum   # OfP.Skontodatum;
  Erl.Skontoprozent # OfP.Skontoprozent;
  Erl.Zieldatum     # OfP.Zieldatum;

  RunAFX('Auf.Rechnung.Vorbereiten.Post',cnvad(aBisLiefDatum)+'|'+abool(aSilent)+'|'+aint(aNurLFS));    // 2023-07-27 AH

  APPON();

  RETURN true;
end;


//========================================================================
// RE_Eingabemaske
//
//========================================================================
sub RE_Eingabemaske(
  var aReDatum            : date;
  var aBisLiefDatum       : date;
  var aSkontoDatum        : date;
  var aSkontoProzent      : float;
  var aZielDatum          : date;
  var aValutadatum        : date;
) : logic;
local begin
  vHdl                : int;
  vErg                : int;
  vPara               : alpha(200);
end;
begin

  // Ankerfunktion
  GV.Datum.01 # today;
  GV.Datum.02 # today;
  GV.Datum.03 # CnvDI(CnvID(today) + "ZaB.Valutatage");
  RunAFX('Auf.Rechnung.Maske','');

  //vHdl # Winopen('Dlg.Rechnung',_WinOpenDialog);
  vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Dlg.Rechnung'),_WinOpenDialog);

  $DE.ReDatum->wpCaptionDate        # GV.Datum.01;
  $DE.LiefDatum->wpCaptiondate      # Gv.Datum.02;
  $DE.ZielDatum->wpCaptionDate      # 0.0.0;
  $DE.SkontoDatum->wpCaptionDate    # 0.0.0;
  $DE.Valuta->wpCaptionDate         # GV.Datum.03;
  $FE.SkontoProzent->wpCaptionFloat # 0.0;

  //$DE.ReDatum->wpdisabled   # true;
  //$DE.LiefDatum->wpdisabled # true;

  if (ZaB.IndividuellYN=n) then begin
    $DE.ZielDatum->wpvisible      # false;
    $DE.SkontoDatum->wpvisible    # false;
    $FE.SkontoProzent->wpvisible  # false;
    $lb.ZielDatum->wpvisible      # false;
    $lb.SkontoDatum->wpvisible    # false;
    $lb.SkontoProzent->wpvisible  # false;
    $lb.Prozent->wpvisible        # false;
  end;

  // PROPIPE NICHT
  if (Set.Installname<>'HOWVVF') and
    (Set.Installname<>'HOWVFP') and
    (DbaLicense(_DbaSrvLicense)<>'CE150464MN') and
    (ZaB.abLFSDatumYN) then begin
    $DE.Valuta->wpReadOnly        # true;
  end;


  if (Rechte[Rgt_Faktura_ReDatum]=false) then
    Lib_Guicom:Disable($DE.ReDatum);


  REPEAT
    vErg # (vHdl->WinDialogRun());
    aReDatum        # $DE.ReDatum->wpCaptionDate;
    aBisLiefDatum   # $DE.LiefDatum->wpCaptionDate;
    aZielDatum      # $DE.ZielDatum->wpCaptionDate;
    aSkontoDatum    # $DE.SkontoDatum->wpCaptionDate;
    aSkontoProzent  # $FE.SkontoProzent->wpCaptionFloat;
    aValutadatum    # $DE.Valuta->wpCaptionDate;;

    if (vErg=_WinIdOk) then begin
      if (aReDatum<Set.AbschlussDatum) or (aReDatum=0.0.0) then begin
        Msg(450099,Adr.Stichwort,0,0,0);
        CYCLE;
      end;
      if (aValutaDatum<aReDatum) then begin
        Msg(450010,'',0,0,0);
        CYCLE;
      end;
      // Ankerfunktion
      if (RunAFX('Auf.Rechnung.Maske.Check',aint(vHdl))<>0) then begin
        if (AfxRes<>_rOK) then CYCLE;
      end;
    end;

  UNTIL (true);

  vHdl->WinClose();

  RETURN (vErg=_WinIdOk);

end;


//========================================================================
// Rechnungsdruck
//    Reihenfolge:
//      1. Grundpreis * MENGE
//      2. + mengenbezogene Positionsaufpreise
//      3. + pauschale (nicht mengenbezogen) Positionsaufpreise
//      4. + prozentuale Positionsaufpreise
//      5. + mengenbezogene Kopfaufpreise
//      -> Positionssumme
//      6. + pauschale Kopfaufpreise
//      7. + prozentuale Kopfaufpreise
//      -> Endsumme
//
//========================================================================
sub Rechnungsdruck(
  aVorschau   : logic;
  opt aRedat  : date;
  opt aSilent : logic;
  opt aNurLFS : int;) : logic;
local begin
  Erx                 : int;
  vTyp                : alpha;
  vHdl                : int;
  vErg                : int;
  vReDatum            : date;
  vBisLiefDatum       : date;
  vSkontoDatum        : date;
  vSkontoProzent      : float;
  vZielDatum          : date;
  vValutadatum        : date;
  vLetztesLiefDatum   : date;
  v903                : int;
  v400                : int;
  vMatCO2EK           : float;
  vMatCO2Kost         : float;
end;

begin
  Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
  if (Erx<>_rOK) then RETURN false;
  vTyp # Auf.Vorgangstyp;

  // Ankerfunktion
  if (RunAFX('Auf.Rechnung.pre',Aint(CnvIl(aVorschau)))<>0) then begin
    if (AfxRes<>_rOK) then RETURN false;
  end;

  // Berechtigung prüfen
  if (vTyp=c_Auf) and (Rechte[Rgt_Auf_Druck_RE]=n) then RETURN false;
  if ((vTyp=c_BOGUT) or (vTyp=c_REKOR) or (vTyp=c_GUT)) and (Rechte[Rgt_Auf_Druck_Gut]=n) then RETURN false;
  if ((vTyp=c_BEL_KD) or (vTyp=c_BEL_LF)) and (Rechte[Rgt_Auf_Druck_Bel]=n) then RETURN false;
  if (Auf.PAbrufYN) then RETURN false;


  Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
  if (Erx<>_rOK) then RETURN false;

  Erx # RecLink(100,400,4,_recFirst);   // Rechnungsempfänger holen
  if (Erx<>_rOK) then RETURN false;
  if (Adr.VK.SammelReYN) and (Auf.Vorgangstyp=c_Auf) then begin
    Msg(450105,Adr.Stichwort,0,0,0);
    RETURN false;
  end;


  // Marker berechnen
  Erx # RecLink(401,400,9,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    RecRead(401,1,_RecNoLoad | _RecLock);
    Auf_Data:Pos_BerechneMarker();
    // 27.10.2016 Auf_Data:PosReplace(_recUnlock,'AUTO');
    Erx # RekReplace(401);
    Erx # RecLink(401,400,9,_RecNext);
  END;
  RecRead(400,1,_RecNoLoad | _RecLock);
  Auf_Data:BerechneMarker();
  RekReplace(400,_recUnlock,'AUTO');

  if (Auf.Aktionsmarker<>'$') then begin
    Msg(400001,'',0,0,0);
    RETURN false;
  end;

  // UST-ID prüfen...
  Erx # RecLink(813,400,19,_recFirst);    // Steuerschlüssel holen
  if (Erx>_rLocked) then begin
    Msg(400098,'',0,0,0);
    RETURN false;
  end;
  if (StS.UstIDPflichtYN) and (Adr.USIdentNr='') then begin
    Msg(400022,'',0,0,0);
    RETURN false;
  end;

  // Aufpreise prüfen ***************************************
  // Verpackungsaktionen als fakturiert markieren... 25.11.2019
  FOR Erx # RecLink(404,400,15,_RecFirst)
  LOOP Erx # RecLink(404,400,15,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if ("Auf.A.Löschmarker"='*') or (Auf.A.Rechnungsdatum<>0.0.0) then CYCLE;
    if (Auf.A.Aktionstyp=c_Akt_LFS_VPG) then begin
      Erx # RecLink(250,404,3,_RecFirst);   // Artikel holen
      if (Erx<=_rLocked) then begin
        if (ErzeugeVpgAktion(Auf.Nummer, Art.Nummer, Art.Stichwort, Auf.A.MEH, Auf.A.Menge, true)=false) then begin
          Msg(400006,'',0,0,0);
          RETURN false;
        end;
      end;
    end;
  END;


  FOR Erx # RecLink(403,400,13,_RecFirst)
  LOOP Erx # RecLink(403,400,13,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.Z.Vpg.ArtikelNr<>'') and (Auf.Z.Vpg.OKYN=n) then begin
      Msg(400006,'',0,0,0);
      RETURN false;
    end;
  END;


  // Zahlungsbedingung holen
  Erx # RecLink(816,400,6,_recFirst);
  if (Erx>_rLocked) then begin
    Msg(001201,Translate('Zahlungsbedingung'),0,0,0);
    RETURN false;
  end;
  if (ZaB.SperreYN) then RETURN false;


  // Eingabemaske aufrufen
  if (aReDat=0.0.0) then begin
    if (RE_Eingabemaske(var vReDatum, var vBisLiefDatum, var vSkontoDatum, var vSkontoProzent, var vZielDatum, var vValutadatum)=false) then
      RETURN false;
  end
  else begin
    vReDatum      # aReDat;
    vBisLiefDatum # aReDat;
    vValutaDatum  # aReDat;
  end;


  // Aktionen durchtesten, OFP & Erlöse vorbelegen
  if (RE_Vorbereiten(var vReDatum, vBisLiefDatum,vSkontoDatum,vSkontoProzent,vZielDatum,vValutaDatum,n, aNurLFS)=false) then
    RETURN false;

  v400 # RekSave(400);

  // Vorschau?
  if (aVorschau) then begin
    Erl.Rechnungsnr     # 0;
/*** MUSS in PS
    // CO2???
    if (Auf.Vorgangstyp<>c_REKOR) and (Auf.Vorgangstyp<>c_GUT) then begin
      FOR Erx # RecLink(404,400,15,_RecFirst) // Aktionen loopen
      LOOP Erx # RecLink(404,400,15,_RecNext)
      WHILE (Erx<=_rLocked) do begin
        if ("Auf.A.Löschmarker"='*') or (Auf.A.Rechnungsmark<>'$') or
          (Auf.A.TerminEnde>vBisLiefDatum) or (Auf.A.TerminEnde=0.0.0) or
          (Auf.A.Rechnungsdatum<>0.0.0) then CYCLE;

        // 11.05.2017 AH
        if (aNurLFS<>0) then begin
          if (Auf.A.Aktionsnr<>aNurLFS) or (Auf.A.Aktionstyp<>c_Akt_Lfs) then CYCLE;
        end;

        if (Auf.A.Materialnr<>0) then begin // 24.02.2021 AH
          Erx # RecLink(200,404,6,_RecFirst);   // Material holen
          if (Erx>_rLocked) then begin
            Erx # RecLink(210,404,8,_RecFirst); // ~Material holen
            if (Erx>_rLocked) then RecBufClear(210);
            RecBufCopy(210,200);
          end;
          vMatCO2EK   # Rnd(Mat.CO2EinstandProT * Mat.Bestand.Gew / 1000.0,2);
// nur INHOUSE          vMatCO2Kost # Rnd((Mat.CO2ZuwachsProT + Mat.CO2SchrottProT) * Mat.Bestand.Gew / 1000.0,2);
          vMatCO2Kost # Rnd(Mat.CO2ZuwachsProT * Mat.Bestand.Gew / 1000.0,2);
        end;
      END;
      Erl.CO2Einstand # Erl.CO2Einstand + vMatCO2EK;
      Erl.CO2Zuwachs  # Erl.CO2Zuwachs  + vMatCO2Kost;
    end;
***/
  end
  else begin

    //*********************************************************************
    // VERBUCHUNG
    //*********************************************************************
    TRANSON;

    // ggf. ersetzende Nummernvergabe aufrufen, sonst Standard mit Settings
    if (RunAFX('Fakt.Nummernvergabe','') = 0) then begin

      v903 # RecbufCreate(903);
      Erx # RecRead(v903,1,_recfirst);
      if (Erx<>_rOK) then begin
        RecBufDestroy(v903);
        TRANSBRK;
        RekRestore(v400);
        RETURN false;
      end;
      "Set.Wie.GutBel#SepYN"  # v903->"Set.Wie.GutBel#SepYN";
//      Set.Auf.GutBelLFNull    # v903->Set.Auf.GutBelLFNull;
      RecBufDestroy(v903);

      if ("Set.Wie.GutBel#SepYN") and
          ((vTyp=c_BOGUT) or (vTyp=c_REKOR) or (vTyp=c_GUT) or (vTyp=c_BEL_KD) or (vTyp=c_BEL_LF)) then begin
//        if (Set.Auf.GutBelLFNull) and   16.12.2020 AH
//          ((vTyp=c_Gut) or (vTyp=c_Bel_LF)) then begin
        if (vTyp=c_Gut) or (vTyp=c_Bel_LF) then begin
          Erl.Rechnungsnr # Lib_Nummern:ReadNummer('Gutschrift/Belastung-LF');
          // 16.12.2020 AH: kein seperater NrKreis für LF? -> Dann GS/BEL nehmen!
          if (Erl.Rechnungsnr<0) then Erl.Rechnungsnr # Lib_Nummern:ReadNummer('Gutschrift/Belastung')
        end
        else begin
          Erl.Rechnungsnr # Lib_Nummern:ReadNummer('Gutschrift/Belastung')
        end;
      end
      else begin
        Erl.Rechnungsnr # Lib_Nummern:ReadNummer('Rechnung');
      end;
    end;


    if (Erl.Rechnungsnr=0) then begin
      TRANSBRK;
      RekRestore(v400);
      RETURN false;
    end;
    Lib_Nummern:SaveNummer()

    // Verbuchen
    APPOFF();
    if (RE_Verbuchen(vBisLiefDatum,0,aNurLFS)=false) then begin
      APPON();
//      TRANSBRK; in SUB
      RekRestore(v400);
      RETURN false;
    end;
    APPON();

    TRANSOFF; // ok

    RekRestore(v400);

    // Ankerfunktion
    RunAFX('Auf.Rechnung.post',Aint(Erl.Rechnungsnr));

    // Fertig !
    if (gUsergroup<>'JOB-SERVER') and (gUsergroup<>'SOA_SERVER') and (aSilent=n) then
      Msg(400005,AInt(Erl.Rechnungsnr),_WinIcoInformation,0,0);
  end;


  //*********************************************************************
  // DRUCK
  //*********************************************************************
  if (aVorschau) then begin
    if (vTyp=c_Auf) then    Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_REKOR) then  Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_BoGut) then  Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_Gut) then    Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_Bel_KD) then Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_Bel_LF) then Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    RunAFX('Auf.Rechnung.NachPrintForm',abool(aVorschau));
    RETURN true;
  end;
  if (vTyp=c_Auf) then    Lib_Dokumente:Printform(450,'Rechnung',true);
  if (vTyp=c_REKOR) then  Lib_Dokumente:Printform(450,'Rechnung',true);
  if (vTyp=c_BOGUT) then  Lib_Dokumente:Printform(450,'Rechnung',true);
  if (vTyp=c_GUT) then    Lib_Dokumente:Printform(450,'Rechnung',true);
  if (vTyp=c_BEL_KD) then Lib_Dokumente:Printform(450,'Rechnung',true);
  if (vTyp=c_BEL_LF) then Lib_Dokumente:Printform(450,'Rechnung',true);

/*** 09.02.2021 AH ???
  RETURN true;

  // Rechnung drucken
  if (aVorschau) then begin
    if (vTyp=c_AUF) then    Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_REKOR) then  Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_BOGUT) then  Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_GUT) then    Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_BEL_KD) then Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    if (vTyp=c_BEL_LF) then Lib_Dokumente:Printform(450,'Rechnungsvorschau',true);
    RETURN true;
  end
  else begin
    Lib_Dokumente:Printform(450,'Rechnung',true);
    if (vTyp=c_REKOR) or (vTyp=c_REKOR) or (vTyp=c_GUT) then begin
      Erl.Netto   # Rnd(0.0 - Erl.Netto,2)
      Erl.Steuer  # Rnd(0.0 - Erl.Steuer,2);
    end;
  end;
***/
  RunAFX('Auf.Rechnung.NachPrintForm','');
  
  RETURN true;
end;


//========================================================================
// SumMwst
//========================================================================
Sub SumMwst(
  aWgrSts : int;
  aAdrSts : int;
  aNetto  : float;
  var aS1 : int;
  var aP1 : float;
  var aN1 : float;
  var aS2 : int;
  var aP2 : float;
  var aN2 : float;
);
local begin
  Erx : int;
end;
begin
  StS.Nummer # (aWgrSts * 100) + aAdrSts;
  Erx # RecRead(813,1,0);
  if (Erx>_rLocked) then RecBufClear(813);
  if (aS1<=0) then begin
    aS1 # Sts.Nummer;
    aN1 # aNetto;
    aP1 # Sts.Prozent;
  end
  else if (aS1=Sts.Nummer) then begin
    aN1 # aN1 + aNetto;
  end
  else if (aS2<=0) then begin
    aS2 # Sts.Nummer;
    aN2 # aNetto;
    aP2 # Sts.Prozent;
  end
  else if (aS2=Sts.Nummer) then begin
    aN2 # aN2 + aNetto;
  end;

end;


//========================================================================