@A+
//===== Business-Control =================================================
//
//  Prozedur    OsT_Data
//
//  Info        Managed die Onlinestatistikdatei
//              ohne E_R_G
//
//  14.04.2004  AI  Erstellung der Prozedur
//  13.10.2010  AI  Recalc nun mit StartDatum
//  18.10.2010  AI  Lieferanten-Erlöse ggf. überspringen
//  24.09.2012  AI  Statistik für Auftragsarten eingebaut
//  11.04.2013  AI  MatMEH
//  24.06.2013  ST  Bugfix RecCalc: Wenn Materialkarte nicht existiert, keine Änderung an Auf.Aktionsliste vornehmen
//  21.01.2014  ST  Bugfix Projekt 1483/23: Ergebnisse der Monatlichen Bestandssummierungen nicht löschen
//  29.07.2014  AH  NEU: Erl.K.Artikelnummer
//  18.09.2014  AH  Bugfix: "_Save" ignoriert "_EINGANG"-Sätze für Quartal und Jahr
//  26.01.2015  AH  Ost.E kann auch "ANG_Eingang"
//  15.07.2015  AH  "Recalc" neue Berechnungslogik für LFS/LFA
//  11.02.2016  AH  "Recalc" hatte Artikel-EKs ggf. gelöscht, wenn keine "gute" Auf-Vorkalkulation existiert
//  11.02.2016  ST  "Recalc" Progress für Statusanzeige eingebaut
//  22.04.2016  AH  Aufpreiserlöse werden NICHT mengenmässig in Statistik gebucht (d.h. NUR "Grundpreis")
//  07.07.2016  ST  "Recalc" Kosten für LFS + Vorkalk werden berücksichtigt
//  25.07.2016  AH  "Recacl" rechnet DOCH ReKor und Gut
//  05.08.2016  AH  Erlöskonten ohne Auftragsart überspringen (Holzrichter "Sonderkonto")
//  15.08.2016  AH  Erlöskorrektur beachten
//  18.08.2016  AH  Rename "BucheRechnungALT" anch "BucheRechnung"
//  22.02.2017  AH  "Repait892"
//  05.12.2018  AH  "Recalc" ignoriert kaputte LFS (früher war das CYCLE)
//  05.06.2020  AH  AFX "OSt.ProcessStack.Unbekannt"
//  12.08.2020  AH  AFX "OSt.ProcessStack.Unbekannt" mit Ergebnisauswertung
//  10.11.2020  AH  BEL-LF wird gebucht
//  24.06.2021  aH  "RecalcErl"
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//    SUB BucheRechnung(aTyp : alpha) : logic;
//    SUB StackErloes() : logic;
//    SUB Stack(aMode : alpha; aTyp : alpha; aVorgang : alpha; aAdrNr : int; aVert : int; aAufArt : int; aWGr : int; aArtNr : alpha; aGuete : alpha; aKst : int; aDat : date;
//              aWert : float; aStk : int; aGew : float; aMenge : float; aMEH : alpha) : logic;
//    SUB ProcessStack() : logic;
//    SUB Hole(aTyp : alpha; aMonat : int; aJahr : int) : logic;
//    SUB HoleExtend(aZeitart : alpha; aZahl : int; aJahr : int; aName1 : alpha; aName2 : alpha) : logic;

//    SUB Recalc(aAbDatum  : date) : logic;
//    SUB RecalcErl(aRenr : int; opt aSilent : logic) : logic
//    SUB Job(aPara : alpha) : logic;
//    SUB Initialize(opt aSilent : logic);
//    SUB MatRueckwirkend_Delegate(aDat : date) : int;
//    SUB UebertrageBestand(aArt : alpha; aZ1 : int; aJ1 : int; aZ2 : int; aJ2 : int);

//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
  cRE   : 'RE'
  cGut  : 'GUT'
  cBel  : 'BEL'
end;

declare _Save890(aName : alpha; aDate : date; aEK : float; aVK : float; aIK : float; aStk : int; aGew : float; aMenge : float; aMEH : alpha; aDeckB1 : float; );
declare _Save892(aName : alpha; aName2 : alpha; aDate : date; aAnz : int; aStk : int; aGew : float; aMenge : float; aMEH : alpha; aBetrag : float; );

/**
ABLÄUFE
  Faktura/Storno:
	  - Ost_Data:StackErloes
		    - _InsertStack -> 891

	  - Ost_Data:BucheRechnung
		    - _Save890 : pro Bereich -> 890
		    - Sta_Data:Verbuchen : pro Bereich -> 899

  Job/ProcessStack:
	  - 891 pro Bereich -> 892 Ost_Erweitert
**/

//========================================================================
//========================================================================
sub _Buche451()
begin
  _Save890('UNTERNEHMEN',Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
          "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
  _Save890('KU:'+CnvAI(Erl.Kundennummer),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
          "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
  _Save890('VERT:'+CnvAI(Erl.Vertreter),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
          "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
  _Save890('VERB:'+CnvAI(Erl.Verband),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
          "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
  if (Erl.K.AuftragsPos=0) then begin // Kopfaufpreis
    _Save890('AUF.K.Z:'+Erl.K.AufpreisSchl,Erl.Rechnungsdatum, 0.0, Erl.K.BetragW1 + Erl.K.KorrekturW1, 0.0,
            "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, 0.0);
    if (Erl.K.Warengruppe<>0) then
    _Save890('WGR:'+cnvai(Erl.K.Warengruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
            "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
  end
  else begin
    RekLink(819,451,4,_recFirst); // Warengruppe holen
    _Save890('WGR:'+cnvai(Erl.K.Warengruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
            "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
    _Save890('AUFART:'+cnvai(Erl.K.Auftragsart),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
          "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
    if (Wgr_Data:IstArt()) then begin  // Artikel?
      RekLink(250,451,12,_recFirst); // Artikel holen
      _Save890('ART:'+StrCnv(Art.Nummer,_strupper),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
              "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
      _Save890('AGR:'+Cnvai(Art.ArtikelGruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
              "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
    end;
  end;
end;


//========================================================================
//  Negiere451
//========================================================================
sub Negiere451()
begin
  Erl.K.EKPreisSummeW1  # Erl.K.EKPreisSummeW1  * -1.0;
  Erl.K.BetragW1        # Erl.K.BetragW1        * -1.0;
  Erl.K.Betrag          # Erl.K.Betrag          * -1.0;
  Erl.K.KorrekturW1     # Erl.K.KorrekturW1     * -1.0;
  Erl.K.Korrektur       # Erl.K.Korrektur       * -1.0;
  Erl.K.InterneKostW1   # Erl.K.InterneKostW1   * -1.0;
  "Erl.K.Stückzahl"     # "Erl.K.Stückzahl"     * -1;
  Erl.K.Gewicht         # Erl.K.Gewicht         * -1.0;
  Erl.K.Menge           # Erl.K.Menge           * -1.0;
  Erl.K.CO2Einstand     # Erl.K.CO2Einstand     * -1.0;
  Erl.K.CO2Zuwachs      # Erl.K.CO2Zuwachs      * -1.0;
end;


//========================================================================
//  BucheRechnung    früher BucheRechnungALT
//            Verbucht einen Vorfall DIREKT in die Statistikfelder
//========================================================================
sub BucheRechnung(
  aTyp        : alpha;
  opt aStorno : logic;
) : logic;
local begin
  Erx     : int;
  vNr     : int;
  vPreis  : float;
  vX      : float;
  vOK     : logic;
end;
begin

  case aTyp of

    cRE : begin            // Rechnung

      // LF-Gutschriften/LF-Belastungen ggf. überspringen
      if (Set.Auf.GutBelLFNull) and
          ((Erl.Rechnungstyp=c_Erl_StornoGut) or (Erl.Rechnungstyp=c_Erl_StornoBel_LF)) or
          ((Erl.Rechnungstyp=c_Erl_Gut) or (Erl.Rechnungstyp=c_Erl_Bel_LF)) then RETURN true;

      vPreis # 0.0;
      FOR Erx # RecLink(451,450,1,_RecFirst)
      LOOP Erx # RecLink(451,450,1,_RecNext)
      WHILE (Erx<=_rLocked) do begin

        if (Erl.K.Steuerschl=0) then CYCLE;  // 05.08.2016 AH: Holzrichters "Sonderkonten" überspringen

        // 22.04.2016 AH: Bei Aufpreise Mengne immer nullen
        if (Erl.K.Bemerkung<>Translate('Grundpreis')) then begin
          "Erl.K.Stückzahl" # 0;
          Erl.K.Gewicht     # 0.0;
          Erl.K.Menge       # 0.0;
        end;
        
        if (aStorno) then Negiere451();

        _Save890('UNTERNEHMEN',Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        _Save890('KU:'+CnvAI(Erl.Kundennummer),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        _Save890('VERT:'+CnvAI(Erl.Vertreter),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        _Save890('VERB:'+CnvAI(Erl.Verband),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        if (Erl.K.AuftragsPos=0) then begin // Kopfaufpreis
          _Save890('AUF.K.Z:'+Erl.K.AufpreisSchl,Erl.Rechnungsdatum, 0.0, Erl.K.BetragW1 + Erl.K.KorrekturW1, 0.0,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, 0.0)
          if (Erl.K.Warengruppe<>0) then
          _Save890('WGR:'+cnvai(Erl.K.Warengruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        end
        else begin
/*
          Auf.P.Nummer    # Erl.K.Auftragsnr;
          Auf.P.Position  # Erl.K.Auftragspos;
          Erx # RecRead(401,1,0);       // Auftragsposition holen
          if (erx>_rLocked) then begin
            "Auf~P.Nummer"    # Erl.K.Auftragsnr;
            "Auf~P.Position"  # Erl.K.Auftragspos;
            Erx # RecRead(411,1,0);       // Ablageposition holen
            if (erx>_rLocked) then begin
              Msg(9999999,'Auftrag nicht gefunden!!!',0,0,0);
              Erx # RecLink(451,450,1,_RecNext);
              CYCLE;
            end;
            RecBufCopy(411,401);
          end;
          RecLink(819,401,1,0);   // Warengruppe holen
*/
          RekLink(819,451,4,_recFirst); // Warengruppe holen

          _Save890('WGR:'+cnvai(Erl.K.Warengruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
          _Save890('AUFART:'+cnvai(Erl.K.Auftragsart),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
//          if (Auf.P.Wgr.Dateinr>=c_Wgr_Artikel) and (Auf.P.Wgr.Dateinr<=c_Wgr_bisArtikel) then begin  // Artikel?
          if (Wgr_Data:IstArt()) then begin  // Artikel?
//            RecLink(250,401,2,_RecFirst); // Artikel holen
            RekLink(250,451,12,_recFirst); // Artikel holen
            // 05.05.2022 AH: Test auf SL-Faktura?
            vOK # true;
            if (Set.Installname='BCS') then begin
              FOR Erx # RecLink(404,450,4,_RecFirst)
              LOOP Erx # RecLink(404,450,4,_RecNext)
              WHILE (erx<=_rLocked) do begin
                if (Auf.A.Nummer<>Erl.K.Auftragsnr) or (Auf.A.Position<>Erl.K.Auftragspos) then CYCLE;
                if (vOK) and (Auf.A.ArtikelNr=Erl.K.Artikelnummer) then BREAK;  // normaler Auftrag OHNE SL
                // STÜCKLISTE
                vOK # false;
//                _Save890('ART:'+StrCnv(Auf.A.ArtikelNr,_strupper),Erl.Rechnungsdatum, Auf.A.EKPreisSummeW1, Auf.A.RechGrundPrsW1 + Auf.A.RechKorrektW1, Auf.A.interneKostW1,
//                        "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.RechGrundPrsW1 + Auf.A.RechKorrektW1 - Auf.A.EKPreisSummeW1 - Auf.A.interneKostW1);
                _Save890('ART:'+StrCnv(Auf.A.ArtikelNr,_strupper),Erl.Rechnungsdatum, 0.0, (Auf.A.RechGrundPrsW1 + Auf.A.RechKorrektW1) * Auf.A.Menge.Preis , Auf.A.interneKostW1,
                        "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, 0.0);
              END;
            end;
            if (vOK) then begin
              _Save890('ART:'+StrCnv(Art.Nummer,_strupper),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                      "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
            end;
            _Save890('AGR:'+Cnvai(Art.ArtikelGruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                    "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
          end;
        end;

      END;  // 451

    end;  // Rechnung


    cGUT : begin            // Gutschrift

      if (Set.Auf.GutBelLFNull) and
          ((Erl.Rechnungstyp=c_Erl_StornoGut) or (Erl.Rechnungstyp=c_Erl_StornoBel_LF)) or
          ((Erl.Rechnungstyp=c_Erl_Gut) or (Erl.Rechnungstyp=c_Erl_Bel_LF)) then RETURN true;

      vPreis # 0.0;
      FOR Erx # RecLink(451,450,1,_RecFirst)
      LOOP Erx # RecLink(451,450,1,_RecNext)
      WHILE (Erx<=_rLocked) do begin

        // reine Wertgutschrift?
        if (Erl.K.Gewicht=0.0) and ("Erl.K.Stückzahl"=0) and (Erl.K.EKPreisSummeW1=0.0) then begin
          // Mengen ausnullen
          Erl.K.Menge         # 0.0;
          "Erl.K.Stückzahl"   # 0;
          Erl.K.Gewicht       # 0.0;
        end;

        // 22.04.2016 AH: Bei Aufpreise Mengne immer nullen
        if (Erl.K.Bemerkung<>Translate('Grundpreis')) then begin
          "Erl.K.Stückzahl" # 0;
          Erl.K.Gewicht     # 0.0;
          Erl.K.Menge       # 0.0;
        end;

        if (aStorno) then Negiere451();

        _Save890('UNTERNEHMEN',Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        _Save890('KU:'+CnvAI(Erl.Kundennummer),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        _Save890('VERT:'+CnvAI(Erl.Vertreter),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        _Save890('VERB:'+CnvAI(Erl.Verband),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        if (Erl.K.AuftragsPos=0) then begin // Kopfaufpreis
          _Save890('AUF.K.Z:'+Erl.K.AufpreisSchl,Erl.Rechnungsdatum, 0.0, Erl.K.BetragW1 + Erl.K.KorrekturW1, 0.0 ,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, 0.0);
          if (Erl.K.Warengruppe<>0) then
          _Save890('WGR:'+cnvai(Erl.K.Warengruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        end
        else begin
/*
          Auf.P.Nummer    # Erl.K.Auftragsnr;
          Auf.P.Position  # Erl.K.Auftragspos;
          Erx # RecRead(401,1,0);       // Auftragsposition holen
          if (erx>_rLocked) then begin
            "Auf~P.Nummer"    # Erl.K.Auftragsnr;
            "Auf~P.Position"  # Erl.K.Auftragspos;
            Erx # RecRead(411,1,0);       // Ablageposition holen
            if (erx>_rLocked) then begin
              Msg(9999999,'Auftrag nicht gefunden!!!',0,0,0);
              Erx # RecLink(451,450,1,_RecNext);
              CYCLE;
            end;
            RecBufCopy(411,401);
          end;
          RecLink(819,401,1,0);   // Warengruppe holen
*/
          RekLink(819,451,4,_recFirst); // Warengruppe holen

          _Save890('WGR:'+cnvai(Erl.K.Warengruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
          _Save890('AUFART:'+cnvai(Erl.K.Auftragsart),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
//          if (Auf.P.Wgr.Dateinr>=c_Wgr_Artikel) and (Auf.P.Wgr.Dateinr<=c_Wgr_bisArtikel) then begin  // Artikel?
//            RecLink(250,401,2,_RecFirst); // Artikel holen
          if (Wgr_Data:IstArt()) then begin  // Artikel?
            RekLink(250,451,12,_recFirst); // Artikel holen
            _Save890('ART:'+StrCnv(Art.Nummer,_strupper),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                    "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
            _Save890('AGR:'+Cnvai(Art.ArtikelGruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                    "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
          end;
        end;

      END;  // 451

    end;    // Gutschrift


    cBEL : begin            // Belastung
    
      if (Set.Auf.GutBelLFNull) then begin
// 10.11.2020 AH: Neue LF-Bel verbuchen...
        if (Erl.Rechnungstyp=c_Erl_Bel_LF) and (Set.Fin.BelLfInStati='A') then begin
          RecBufClear(404);
          RecBufClear(451);
          // Aktionen loopen...
          FOR Erx # RecLink(404,450,4,_recFirst)
          LOOP Erx # RecLink(404,450,4,_recNext)
          WHILE (erx<=_rLocked) do begin
            // bei BEL-LF mit Material, KEINE Statistik buchen, weil das über das Material passiert
            if (Auf.a.Aktionstyp=c_Akt_GbMat) then RETURN true;;
          END;

          // Aktionen loopen...
          FOR Erx # RecLink(404,450,4,_recFirst)
          LOOP Erx # RecLink(404,450,4,_recNext)
          WHILE (erx<=_rLocked) do begin
            if (Auf.A.Aktionstyp<>c_Akt_DfaktBel) then CYCLE;

            Erx # Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, y);
            if (erx<400) then CYCLE;
            
            Erl.K.Auftragsnr      # Auf.A.Nummer;
            Erl.K.Auftragspos     # Auf.A.Position;
            Erl.K.Gewicht         # Auf.A.Gewicht;
            "Erl.K.Stückzahl"     # "Auf.A.Stückzahl";
            Erl.K.Menge           # Auf.A.Menge.Preis;
            if (auf.P.PEH=0) then Auf.P.Peh # 1;
            vX # Auf.A.Menge.Preis / cnvfi(Auf.P.PEH);
            Erl.K.BetragW1        # (Auf.A.RechGrundPrsW1 * vX);
            Erl.K.Rechnungsdatum  # Auf.A.Rechnungsdatum;
            Erl.K.MEH             # Auf.A.MEH.Preis;
            Erl.K.EKPreisSummeW1  # Auf.A.EKPreisSummeW1;
            Erl.K.Rechnungsnr     # Erl.Rechnungsnr;
            Erl.K.Artikelnummer   # Auf.P.Artikelnr;
            Erl.K.Auftragsart     # Auf.P.Auftragsart;
            Erl.K.Warengruppe     # Auf.P.Warengruppe;
            RekLink(819,451,4,_recFirst); // Warengrupppe holen
            Erl.K.Steuerschl      # ("Wgr.Steuerschlüssel" * 100)+"Auf.Steuerschlüssel";
            Erl.K.Betrag          # Rnd(Erl.K.BetragW1 * "Erl.Währungskurs",2)
            
            _Buche451();
            Sta_Data:Verbuchen('BEL-LF-POS');
          END;

          RETURN true;
        end;
      
        if ((Erl.Rechnungstyp=c_Erl_StornoGut) or (Erl.Rechnungstyp=c_Erl_StornoBel_LF)) or
          ((Erl.Rechnungstyp=c_Erl_Gut) or (Erl.Rechnungstyp=c_Erl_Bel_LF)) then RETURN true;
      end;
      
      vPreis # 0.0;
      FOR Erx # RecLink(451,450,1,_RecFirst)
      LOOP Erx # RecLink(451,450,1,_RecNext)
      WHILE (Erx<=_rLocked) do begin

        // Mengen ausnullen
        Erl.K.Menge         # 0.0;
        "Erl.K.Stückzahl"   # 0;
        Erl.K.Gewicht       # 0.0;

        // 22.04.2016 AH: Bei Aufpreise Mengne immer nullen
        if (Erl.K.Bemerkung<>Translate('Grundpreis')) then begin
          "Erl.K.Stückzahl" # 0;
          Erl.K.Gewicht     # 0.0;
          Erl.K.Menge       # 0.0;
        end;

        if (aStorno) then Negiere451();

        _Save890('UNTERNEHMEN',Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        _Save890('KU:'+CnvAI(Erl.Kundennummer),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        _Save890('VERT:'+CnvAI(Erl.Vertreter),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        _Save890('VERB:'+CnvAI(Erl.Verband),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        if (Erl.K.AuftragsPos=0) then begin // Kopfaufpreis
          _Save890('AUF.K.Z:'+Erl.K.AufpreisSchl,Erl.Rechnungsdatum, 0.0, Erl.K.BetragW1 + Erl.K.KorrekturW1, 0.0,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, 0.0);
          if (Erl.K.Warengruppe<>0) then
          _Save890('WGR:'+cnvai(Erl.K.Warengruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
        end
        else begin
          RekLink(819,451,4,_recFirst); // Warengruppe holen  10.11.2020 AH
          _Save890('WGR:'+cnvai(Erl.K.Warengruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                  "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
          _Save890('AUFART:'+cnvai(Erl.K.Auftragsart),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
//          if (Auf.P.Wgr.Dateinr>=c_Wgr_Artikel) and (Auf.P.Wgr.Dateinr<=c_Wgr_bisArtikel) then begin  // Artikel?
//            RecLink(250,401,2,_RecFirst); // Artikel holen
          if (Wgr_Data:IstArt()) then begin  // Artikel?
            RekLink(250,451,12,_recFirst); // Artikel holen
            _Save890('ART:'+StrCnv(Art.Nummer,_strupper),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                    "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
            _Save890('AGR:'+Cnvai(Art.ArtikelGruppe),Erl.Rechnungsdatum, Erl.K.EKPreisSummeW1, Erl.K.BetragW1 + Erl.K.KorrekturW1, Erl.K.InterneKostW1,
                    "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1 + Erl.K.KorrekturW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
          end;
        end;

      END; // 451

    end;    // Belastung


    otherwise TODO('OSt-Typ '+aTyp);

  end;

  RETURN Sta_Data:Verbuchen(aTyp);
end;


//========================================================================
//========================================================================
sub _InitStack(
  aMode     : alpha(1);  // +, -, leer
  aTyp      : alpha;
  aVorgang  : alpha);
local begin
  Erx   : int;
  vNr   : int;
end;
begin
  Erx # RecRead(891,1,_recLast);
  if (Erx<=_rLocked) then vNr # OSt.S.ID
  else vNr # 1;
  RecBufClear(891);
  OSt.S.ID      # vNr;
  OSt.S.Mode    # aMode;
  OSt.S.Typ     # StrCnv(aTyp, _StrUpper);
  OSt.S.Vorgang # aVorgang;
end;


//========================================================================
//========================================================================
sub _InsertStack();
local begin
  Erx : int;
end;
begin
  REPEAT
    Erx # RekInsert(891,_recUnlock,'AUTO');
    if (erx<>_rOK) then OSt.S.ID # OSt.S.ID + 1;
  UNTIL (Erx=_rOK);
end;


//========================================================================
//  StackErloe
//                in 891
//========================================================================
sub StackErloes() : logic;
begin

  // NUR altes System?
  if (Set.OSt.Wie='') then RETURN true;

  _InitStack('+', 'ERLOES', aint(Erl.Rechnungsnr));   // "fix" für alte Version
  OSt.S.Datum # Erl.Rechnungsdatum;
  _InsertStack();

  RETURN true;
end;


//========================================================================
//  StackKontoKorrektur
//                in 891
//========================================================================
sub StackKontoKorrektur(
  aDeltaEK  : float;
  aDeltaIK  : float;
  aDeltaVK  : float;
) : logic;
begin

  // NUR altes System?
  if (Set.OSt.Wie='') then RETURN true;

  _InitStack('+', 'KONTOKORREKTUR', aint(Erl.K.Rechnungsnr)+'/'+aint(Erl.K.lfdNr))
  OSt.S.Datum     # Erl.K.Rechnungsdatum;
  OSt.S.BetragW1  # aDeltaEK;
  OSt.S.Betrag2W1 # aDeltaIK;
  OSt.S.Betrag3W1 # aDeltaVK;
  _InsertStack();

  RETURN true;
end;


//========================================================================
//  Stack
//          für Auftrag, Bestellung etc. in 891
//========================================================================
sub Stack(
  aMode       : alpha;
  aTyp        : alpha;
  aVorgang    : alpha;

  aAdrNr      : int;
  aVert       : int;
  aAufArt     : int;
  aWGr        : int;
  aArtNr      : alpha;
  aGuete      : alpha;
  aKst        : int;
  aDat        : date;

  aWert       : float;
  aStk        : int;
  aGew        : float;
  aMenge      : float;
  aMEH        : alpha;
  ) : logic;
local begin
  Erx     : int;
  vAgr    : int;
end;
begin

  if (Set.OSt.Wie='') then RETURN false;

  if (aArtNr<>'') and (Art.Nummer<>aArtNr) then begin
    Art.Nummer # aArtNr;
    Erx # RecRead(250,1,0);
    if (erx<>_rOK) then
      RecBufClear(250)
    else
      vAGr # Art.Artikelgruppe;
  end;

  _InitStack(aMode, aTyp, aVorgang);
  OSt.S.Datum         # aDat;
  OSt.S.Adressnummer  # aAdrNr;
  OSt.S.Vertreternr   # aVert;
  OSt.S.Warengruppe   # aWgr;
  OSt.S.Artikelgruppe # vAGr;
  OSt.S.Artikelnummer # aArtNr;
  "OSt.S.Güte"        # aGuete;
  OSt.S.Kostenstelle  # aKst;
  OSt.S.Auftragsart   # aAufArt;

  OSt.S.BetragW1      # aWert;
  OSt.S.Menge         # aMenge;
  OSt.S.MEH           # aMEH;
  "OSt.S.Stückzahl"   # aStk;
  OSt.S.Gewicht       # aGew;
  _InsertStack();

//debugx(aTyp+' : '+anum(aGew,0)+'kg   '+anum(aWert,2)+'EUR   ');

  RETURN true;
end;


//========================================================================
//  ProcessStack
//
//========================================================================
sub ProcessStack() : logic;
local begin
  Erx   : int;
  vTyp  : alpha;
  vTyp2 : alpha;
  vDat  : date;
  vAnz  : int;
  vStd  : logic;
  vWin  : int;
  vA    : alpha;
  vI    : int;
end;
begin

  if (RecRead(891,1,_recFirst)>_rLocked) then RETURN true;

  if (gUsergroup<>'JOB-SERVER') then begin
    vWin # Lib_Progress:Init('Berechnung...', RecInfo(891, _recCount ) );
  end;

  Erx # RecRead(891,1,_recFirst|_RecLock);
  WHILE (Erx<=_rOK) do begin

    vWin->Lib_Progress:Step();

    vDat # Ost.S.Datum;
//    vDat # today;
//    if (v

    if (OSt.S.Mode='-') then vAnz # -1
    else if (OSt.S.Mode='+') then vAnz # 1
    else vAnz # 0;

    vA # OSt.S.Typ;
    if (Strcut(vA,1,1)='-') or (Strcut(vA,1,1)='+') then vA # StrCut(vA,2,32);

    case vA of

      'KONTOKORREKTUR' : begin
        Ost.S.Typ # 'ERLOES';
        Erl.K.Rechnungsnr # cnvia(Str_Token(Ost.S.Vorgang,'/',1));
        Erl.K.lfdnr       # cnvia(Str_Token(Ost.S.Vorgang,'/',2));
        Erx # RecRead(451,1,0);   // Kontierung holen
        if (erx<=_rLocked) and (Erl.K.Steuerschl<>0) then begin // Holzrichters "Sonderkonten" überspringen

          vTyp2 # 'ERLOES';
          _Save892(vTyp2, '',                                                vDat, 1, 0, 0.0, 0.0, '', Ost.S.Betrag3W1 - Ost.S.Betrag2W1 - Ost.S.BetragW1);
          _Save892('DB1', '',                                                vDat, 1, 0, 0.0, 0.0, '', Ost.S.Betrag3W1 - Ost.S.Betrag2W1 - Ost.S.BetragW1);
//debugx('korrektur um '+anum(Ost.S.BetragW1,2));
          vStd # false;
        end;
      end;


      // ERLÖSE ------------------------------------------------------------------------------------------------------------------------------------------------------------------
      'ERLOES' : begin
        // Erlös holen...
        Erl.Rechnungsnr # cnvia(OSt.S.Vorgang);
        Erx # RecRead(450,1,0);
        if (erx>_rLocked) then begin
          vWin->Lib_Progress:Term();
todox('Erlös fehlt:'+Ost.S.Vorgang);
          RETURN false;
        end;

//if (Erl.Rechnungsdatum<15.08.2016) then begin
//  RekDelete(891,_recunlock,'AUTO');
//  cycle;
//end;

        case (Erl.Rechnungstyp) of
          c_Erl_VK            : vTyp # '+RECHNUNG';
          c_Erl_SammelVK      : vTyp # '+RECHNUNG';
          c_Erl_StornoVK      : vTyp # '-RECHNUNG';
          c_Erl_REKOR         : vTyp # '+RECHKOR';
          c_Erl_StornoREKOR   : vTyp # '-RECHKOR'
          c_Erl_Bel_KD        : vTyp # '+KD_BELASTUNG';
          c_Erl_StornoBel_KD  : vTyp # '-KD_BELASTUNG';
          c_Erl_Gut           : vTyp # '+GUTSCHRIFT';
          c_Erl_StornoGut     : vTyp # '-GUTSCHRIFT';
          c_Erl_Bel_LF        : vTyp # '+LF_BELASTUNG';
          c_Erl_StornoBel_LF  : vTyp # '-LF_BELASTUNG';
          c_Erl_BoGut         : vTyp # '+BONUSGUT';
          c_erl_StornoBoGut   : vTyp # '-BONUSGUT';

          otherwise begin
            vWin->Lib_Progress:Term();
 todox('unbekannter Rechtyp in Erlös:'+aint(Erl.Rechnungsnr));
            RETURN false;
          end;
        end;

//        vTyp2 # StrCut(vTyp,2,20);
        vTyp2 # 'ERLOES';
        if (Set.Auf.GutBelLFNull) and
          ((Erl.Rechnungstyp=c_Erl_StornoGut) or (Erl.Rechnungstyp=c_Erl_StornoBel_LF)) or
          ((Erl.Rechnungstyp=c_Erl_Gut) or (Erl.Rechnungstyp=c_Erl_Bel_LF)) then begin
          vTyp2 # '';
        end;


        RekLink(100,450,5,_recFirst);     // Kunde holen
        RecBufClear(250);
        if (Erl.K.Artikelnummer<>'') then begin
          RekLink(250,451,12,_recFirst);  // Artikel holen
        end;

        // Konten loopen
        FOR Erx # RecLink(451,450,1,_RecFirst)
        LOOP Erx # RecLink(451,450,1,_RecNext)
        WHILE (Erx<=_rLocked) do begin

          if (Erl.K.Steuerschl=0) then CYCLE;  // 05.08.2016 AH: Holzrichters "Sonderkonten" überspringen

          _Save892(vTyp, '',                                                   vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
          if (vTyp2<>'') then begin
            _Save892(vTyp2, '',                                                vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
            _Save892('DB1', '',                                                vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1);
//debugx('DB1 ändern um '+anum(Erl.K.BetragW1 - Erl.K.EKPreisSummeW1 - Erl.K.InterneKostW1,2));
          end;
/*
          _Save(vTyp, 'ADR:'+aint(Adr.Nummer),                              vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW11);
          _Save(vTyp2, 'ADR:'+aint(Adr.Nummer),                             vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
          if (Erl.Vertreter<>0) then begin
            _Save(vTyp, 'VERT:'+aint(Erl.Vertreter),                        vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
            _Save(vTyp2, 'VERT:'+aint(Erl.Vertreter),                       vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
          end;
          if (Erl.K.Warengruppe<>0) then begin
            _Save(vTyp, 'WGR:'+aint(Erl.K.Warengruppe),                     vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
            _Save(vTyp2, 'WGR:'+aint(Erl.K.Warengruppe),                    vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
          end;
          if (Erl.K.AuftragsArt<>0) then begin
            _Save(vTyp, 'AUFART:'+aint(Erl.K.Auftragsart),                  vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
            _Save(vTyp2, 'AUFART:'+aint(Erl.K.Auftragsart),                 vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
          end;
          if ("Erl.K.Güte"<>'') then begin
            _Save(vTyp, 'Q:'+StrCnv("Erl.K.Güte",_strupper),                vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
            _Save(vTyp2, 'Q:'+StrCnv("Erl.K.Güte",_strupper),               vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
          end;
          if (Erl.K.Artikelnummer<>'') then begin
            _Save(vTyp, 'ART:'+StrCnv(Erl.K.Artikelnummer,_strupper),       vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1);
            _Save(vTyp2, 'ART:'+StrCnv(Erl.K.Artikelnummer,_strupper),      vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, Erl.K.Menge, Erl.K.MEH, Erl.K.BetragW1);
          end;
          if (Art.Artikelgruppe<>0) then begin
            _Save(vTyp, 'AGR:'+aint(Art.Artikelgruppe),                     vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
            _Save(vTyp2, 'AGR:'+aint(Art.Artikelgruppe),                    vDat, 1, "Erl.K.Stückzahl", Erl.K.Gewicht, 0.0, '', Erl.K.BetragW1);
          end;
*/
        END;

        vStd # false;
      end;

      // AUFTRAG -----------------------------------------------------------------------------------------------------------------------------------------------------------------
      // AUFTRAG -----------------------------------------------------------------------------------------------------------------------------------------------------------------
      // AUFTRAG -----------------------------------------------------------------------------------------------------------------------------------------------------------------
      c_Auf+'_EINGANG', c_Auf+'_LV_EINGANG', c_Auf+'_AR_EINGANG' : begin
        vStd # true;
      end;

      c_Auf+'_BESTAND', c_Auf+'_LV_BESTAND', c_Auf+'_AR_BESTAND' : begin
        vStd # true;
      end;

      // -----------------------------------------------------

      c_Ang+'_AR_EINGANG' : begin   // IGNORIEREN - Projekt 1488/95 Hammecke
        vStd # FALSE;
      end;

      // -----------------------------------------------------

      c_Ang+'_EINGANG', c_Ang+'_LV_EINGANG' : begin
        vStd # true;
      end;

      c_Ang+'_BESTAND', c_Ang+'_LV_BESTAND' : begin
        vStd # true;
      end;

      // -----------------------------------------------------

      'GUT-KD_BESTAND',
      c_REKOR+'_BESTAND', c_GUT+'_BESTAND', c_Bel_KD+'_BESTAND', c_Bel_LF+'_BESTAND', c_BoGut+'_BESTAND' : begin
        vStd # true;
      end;

      // -----------------------------------------------------

      'GUT-KD_EINGANG',
      c_REKOR+'_EINGANG', c_GUT+'_EINGANG', c_Bel_KD+'_EINGANG', c_Bel_LF+'_EINGANG', c_BoGut+'_EINGANG' : begin
        vStd # true;
      end;

      // EINKAUF -----------------------------------------------------------------------------------------------------------------------------------------------------------------
      // EINKAUF -----------------------------------------------------------------------------------------------------------------------------------------------------------------
      // EINKAUf -----------------------------------------------------------------------------------------------------------------------------------------------------------------
      c_Bestellung+'_EINGANG', c_Bestellung+'_LV_EINGANG', c_Bestellung+'_AR_EINGANG' : begin
        vStd # true;
      end;

      // -----------------------------------------------------

      c_Bestellung+'_BESTAND', c_Bestellung+'_LV_BESTAND', c_Bestellung+'_AR_BESTAND' : begin
        vStd # true;
      end;

      // -----------------------------------------------------

      c_Anfrage+'_EINGANG', c_Anfrage+'_LV_EINGANG' : begin
        vStd # true;
      end;

      c_Anfrage+'_BESTAND', c_Anfrage+'_LV_BESTAND' : begin
        vStd # true;
      end;

      // MATERIAL ----------------------------------------------------------------------------------------------------------------------------------------------------------------
      // MATERIAL ----------------------------------------------------------------------------------------------------------------------------------------------------------------
      // MATERIAL ----------------------------------------------------------------------------------------------------------------------------------------------------------------
      'MAT_EIGEN_BESTAND' : begin
        vStd # true;
      end;

      'MAT_FREMD_BESTAND' : begin
        vStd # true;
      end;

      // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      otherwise begin
        vI # RunAFX('OSt.ProcessStack.Unbekannt', vA);    // 12.08.2020 AH: Ergebnisauswertung
        if (vI=0) then begin
          vWin->Lib_Progress:Term();
          Msg(99,'unbekannter OSt-Stacktyp : '+Ost.S.Typ,0,0,0);
          RETURN false;
        end;
        if (vI>0) then begin      // AFX erfolgreich...
        end
        else if (vI<0) then begin // AFX hatte Probleme...
          // zum nächsten Satz
          Erx # RecRead(891,1,_recUnlock);
          Erx # RecRead(891,1,_recNext|_RecLock);
          CYCLE;
        end;
      end;
    end;  // case


    if (vStd) then begin
      _Save892(OSt.S.Typ, '',                                            vDat, vAnz, "OSt.S.Stückzahl", OSt.S.Gewicht, 0.0, '', OSt.S.BetragW1);
      if (OSt.S.Adressnummer<>0) then
        _Save892(OSt.S.Typ, 'ADR:'+aint(OSt.S.Adressnummer),               vDat, vAnz, "OSt.S.Stückzahl", OSt.S.Gewicht, 0.0, '', OSt.S.BetragW1);
      if (OST.S.Vertreternr<>0) then
        _Save892(OSt.S.Typ, 'VERT:'+aint(OSt.S.Vertreternr),               vDat, vAnz, "OSt.S.Stückzahl", OSt.S.Gewicht, 0.0, '', OSt.S.BetragW1);
      if (OST.S.Warengruppe<>0) then
        _Save892(OSt.S.Typ, 'WGR:'+aint(OSt.S.Warengruppe),                vDat, vAnz, "OSt.S.Stückzahl", OSt.S.Gewicht, 0.0, '', OSt.S.BetragW1);
      if (OST.S.AuftragsArt<>0) then
        _Save892(OSt.S.Typ, 'AUFART:'+aint(OSt.S.Auftragsart),             vDat, vAnz, "OSt.S.Stückzahl", OSt.S.Gewicht, 0.0, '', OSt.S.BetragW1);
      if (OST.S.Artikelgruppe<>0) then
        _Save892(OSt.S.Typ, 'AGR:'+aint(OSt.S.Artikelgruppe),              vDat, vAnz, "OSt.S.Stückzahl", OSt.S.Gewicht, 0.0, '', OSt.S.BetragW1);
      if ("OST.S.Güte"<>'') then
        _Save892(OSt.S.Typ, 'Q:'+StrCnv("OSt.S.Güte",_strupper),           vDat, vAnz, "OSt.S.Stückzahl", OSt.S.Gewicht, 0.0, '', OSt.S.BetragW1);
      if (OST.S.Artikelnummer<>'') then
        _Save892(OSt.S.Typ, 'ART:'+StrCnv(OSt.S.Artikelnummer,_strupper),  vDat, vAnz, "OSt.S.Stückzahl", OSt.S.Gewicht, OSt.S.Menge, OSt.S.MEH, OSt.S.BetragW1);
      vStd # n;
    end;

    RekDelete(891,_recunlock,'AUTO');
    Erx # RecRead(891,1,_recFirst|_RecLock);  // nächster Satz
  END;

  vWin->Lib_Progress:Term();

  RETURN true;
end;


//========================================================================
//  Hole
//      List den Satz aus der Statistikdatei
//========================================================================
sub Hole(aTyp : alpha; aMonat : int; aJahr : int) : logic;
begin
  if (aJahr>1900) then aJahr # aJahr - 1900;
  Ost.Name  # aTyp;
  Ost.Monat # aMonat;
  Ost.Jahr  # aJahr;
  if (RecRead(890,1,0)=_rOK) then RETURN true;
  RecBufClear(890);
  RETURN false;
end;


//========================================================================
//  HoleExtent
//      List den Satz aus der Statistikdatei ERWEITERT
//========================================================================
sub HoleExtend(
  aZeitart  : alpha;
  aZahl     : int;
  aJahr     : int;
  aName1    : alpha;
  aName2    : alpha) : logic;
begin
  OSt.E.Zeitraum.Art  # aZeitart;
  OSt.E.Name          # aName1;
  OST.E.Name2         # aName2;
  OSt.E.Zeitraum.Zahl # aZahl;
  OST.E.Zeitraum.Jahr # aJahr;
  if (RecRead(892,1,0)=_rOK) then RETURN true;
  RecBufClear(892);
  RETURN false;
end;


//========================================================================
//  _Save890    früher _SaveALT
//
//========================================================================
sub _Save890(
  aName   : alpha;
  aDate   : date;
  aEK     : float;
  aVK     : float;
  aIK     : float;
  aStk    : int;
  aGew    : float;
  aMenge  : float;
  aMEH    : alpha;
  aDeckB1 : float);
local begin
  Erx : int;
end;
begin
  if  (aEK=0.0) and (aVK=0.0) and (aIK=0.0) and (aStk=0) and (aGew=0.0) and (aMenge=0.0) and (aDeckB1=0.0) then
    RETURN;

  REPEAT
    OSt.Name  # aName;
    OSt.Monat # datemonth(aDate);
    OSt.Jahr  # dateyear(aDate);
    Erx # Recread(890,1,_RecLock);
    if (erx=_rLocked) then WinSleep(500);
  UNTIL (Erx<>_rLocked);

  if (Erx=_rOK) then begin
    OSt.EK.Wert         # OSt.EK.Wert + aEK;
    OSt.VK.Wert         # OSt.VK.Wert + aVK;
    OSt.interneKosten   # OSt.InterneKosten + aIK;
    "OSt.VK.Stückzahl"  # "OSt.VK.Stückzahl" + aStk;
    OSt.VK.Gewicht      # OSt.VK.Gewicht + aGew;

    if (OSt.VK.MEH=aMEH) then
      OSt.VK.Menge      # OSt.VK.Menge + aMenge;

    OSt.DeckBeitrag1    # Ost.DeckBeitrag1 + aDeckB1;
    RekReplace(890,_recUnlock,'AUTO');

    if (OSt.EK.Wert=0.0) and (OSt.VK.Wert=0.0) and (OSt.interneKosten=0.0) and
      ("OSt.VK.Stückzahl"=0) and (OSt.VK.Gewicht=0.0) and (OST.VK.Menge=0.0) and (Ost.DeckBeitrag1=0.0) then
      RekDelete(890,0,'AUTO');

  end
  else begin
    OSt.Name            # aName;
    OSt.Monat           # datemonth(aDate);
    OSt.Jahr            # dateyear(aDate);
    OSt.EK.Wert         # aEK;
    OSt.VK.Wert         #  aVK;
    OSt.interneKosten   # aIK;
    "OSt.VK.Stückzahl"  # aStk;
    OSt.VK.Gewicht      # aGew;
    OSt.VK.Menge        # aMenge;
    OSt.VK.MEH          # aMEH;
    Ost.DeckBeitrag1    # aDeckB1;
    RekInsert(890,0,'AUTO');
  end;

end;


//========================================================================
//  _Save892
//
//========================================================================
sub _Save892(
  aName   : alpha;
  aName2  : alpha;
  aDate   : date;
  aAnz    : int;
  aStk    : int;
  aGew    : float;
  aMenge  : float;
  aMEH    : alpha;
  aBetrag : float);
local begin
  Erx     : int;
  vI      : int;
  vZArt   : alpha;
  vZ,vJ   : word;
  vDat    : date;
  vS1,vS2 : int;
end;
begin

  if (aName='') then
    RETURN;

  if (aAnz=0) and (aBetrag=0.0) and (aStk=0) and (aGew=0.0) and (aMenge=0.0) then
    RETURN;

  aName2 # StrAdj(aName2, _StrEnd);   // 22.02.2017

  vDat  # today;

  vS2   # (((vDat->vpyear)-2000) * 12) + vDat->vpmonth;
  if (StrFind(aName,'_EINGANG',0)>0) then vS2 # 0;    // "EINGANG" nicht in Quartal und Jahr einrechnen!!!


  FOR vI # 1 loop inc(vI) WHILE (vI<=4) do begin

    vZArt # '';

    if (vI=1) then begin
CYCLE;  // KW dekativiert
      vZArt # 'W';
      Lib_Berechnungen:KW_Aus_Datum(OSt.S.Datum, var vZ, var vJ);
    end;
    if (vI=2) then begin
      vZArt # 'M';
      vJ # OSt.S.Datum->vpYear;
      vZ # OSt.S.Datum->vpmonth;
    end;
    if (vI=3) then begin
      if (vS2=0) then CYCLE;    // "EINGANG" hier ignorieren
      vZArt # 'Q';
      vJ # OSt.S.Datum->vpYear;
      vZ # OSt.S.Datum->vpmonth;
      if (vZ>=1) and (vZ<=3) then vZ # 1
      else if (vZ>=4) and (vZ<=6) then vZ # 2
      else if (vZ>=7) and (vZ<=9) then vZ # 3
      else vZ # 4;
    end;
    if (vI=4) then begin
      if (vS2=0) then CYCLE;    // "EINGANG" hier ignorieren
      vZArt # 'J';
      vJ    # OSt.S.Datum->vpYear;
      vZ    # 0;
    end;


//    // BESTAND aus früheren Zeiträumen in alle Monate einsortieren
//    REPEAT
      RecBufClear(892);
      REPEAT
        OSt.E.Zeitraum.Art  # vZArt;
        OSt.E.Name          # aName;
        OSt.E.Name2         # aName2;
        OSt.E.Zeitraum.Zahl # vZ;
        OSt.E.Zeitraum.Jahr # vJ;
        Erx # Recread(892,1,_RecLock);
        if (erx=_rLocked) then WinSleep(200);
      UNTIL (Erx<>_rLocked);

      if (Erx=_rOK) then begin
//if (ost.e.name2='') then
//debugx('Add '+ost.e.name+':'+ost.e.name2+':'+Ost.e.zeitraum.art);
        OSt.E.BetragW1      # OSt.E.BetragW1 + aBetrag;
        "OSt.E.Stückzahl"   # "OSt.E.Stückzahl" + aStk;
        OSt.E.Gewicht       # OSt.E.Gewicht + aGew;
        OSt.E.SatzAnzahl    # OSt.E.Satzanzahl + aAnz;
        if (OSt.E.MEH=aMEH) then
          OSt.E.Menge       # OSt.E.Menge + aMenge;
        RekReplace(892,_recUnlock,'AUTO');
//debugx('add KEY892');
        // leere Sätze entfernen
        if (OSt.E.BetragW1=0.0) and ("OSt.E.Stückzahl"=0) and (OSt.E.Gewicht=0.0) and (OSt.E.Menge=0.0) and (OSt.E.SatzAnzahl=0) then
          RekDelete(892,0,'AUTO');

      end
      else begin
        RecBufClear(892);
        OSt.E.Zeitraum.Art  # vZArt;
        OSt.E.Name          # aName;
        OSt.E.Name2         # aName2;
        OSt.E.Zeitraum.Zahl # vZ;
        OSt.E.Zeitraum.Jahr # vJ;

        OSt.E.BetragW1      # aBetrag;
        "OSt.E.Stückzahl"   # aStk;
        OSt.E.Gewicht       # aGew;
        OSt.E.Satzanzahl    # aAnz;
        OSt.E.MEH           # aMEH;
        OSt.E.Menge         # aMenge;
        RekInsert(892,0,'AUTO');
//debugx('NEW '+ost.e.name+':'+ost.e.name2+':'+Ost.e.zeitraum.art);
//debugx('new KEY892');
      end;
/*
      // nur beim Monatsloop bei BESTAND
      if (vS2<>0) and (vI=2) then begin
        inc(vZ);
        if (vZ=13) then begin
          inc(vJ);
          vZ # 1;
        end;
        vS1 # ((vJ-2000) * 12) + vZ;
      end;

    UNTIL (vI<>2) or (vS2=0) or (vS1=vS2);
*/
  END;  // For

end;


//========================================================================
//  sub _RecCalcIgnore() : logic
//    Entscheidet ob der aktuell geladene OST. Eintrag gelöscht werden
//    darf, oder nicht
//========================================================================
sub _RecCalcIgnore() : logic
begin

  case (Str_Token(Ost.Name,':',1)) of
    'SUM_AUF_WGR',
    'SUM_BEST_WGR',
    'SUM_WGR'         : return true;
  end;

  RETURN false;
end;


//========================================================================
//  _ProcessErl
//========================================================================
sub _ProcessErl() : logic
local begin
  Erx         : int;
  vNr         : int;
  
  vErlEK      : float;
  vErlKost    : float;
  vEK         : float;
  vKosten     : float;
  xvHdl        : int;
  vMatDatei   : int;
  vOK         : logic;
  vPreisFound : logic;
end;
begin
    // 30.10.2015 Rekor/Gut nicht beachten
    // 25.07.2016 AH: Doch...
//    if (Erl.Rechnungstyp=c_Erl_Gut) or (Erl.Rechnungstyp=c_Erl_REKOR) or (Erl.Rechnungstyp=c_Erl_BoGut) or
//      (Erl.Rechnungstyp=c_Erl_StornoGut) or (Erl.Rechnungstyp=c_Erl_StornoREKOR) or (Erl.Rechnungstyp=c_Erl_StornoBoGut) then CYCLE;
//if (Erl.Rechnungsnr<>2010135) then RETURN true;
//debugX('KEY450');
    vNr # Erl.Rechnungsnr;

    FOR Erx # RecLink(451,450,1,_recFirst)  // Konten loopen
    LOOP Erx # RecLink(451,450,1,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (Erl.K.Steuerschl=0) then CYCLE;  // 05.08.2016 AH: Holzrichters "Sonderkonten" überspringen (war AufArt)
      
      if (Erl.K.Bemerkung<>Translate('Grundpreis')) then CYCLE;

      RecBufClear(250);
      
      Auf_data:read(Erl.K.Auftragsnr, Erl.K.Auftragspos, y);

      vErlEK   # 0.0;
      vErlKost # 0.0;
      FOR Erx # RecLink(404,451,7,_recfirst)  // Aktionen loopen
      LOOP Erx # RecLink(404,451,7,_recNext)
      WHILE (erx<=_rLocked) do begin

        vEK     # Auf.A.EKPreisSummeW1;
        vKosten # Auf.A.interneKostW1;

        // bei MAterial den aktuellen EK holen und Aktion refreshen....
        if (Auf.A.MaterialNr<>0) then begin
// ST 2013-06-24: Material über Funktion holen und ggf. Fehler protokollieren, falls Material nicht vorhanden ist
/*
          vMatDatei # 200;
          Erx # RecLink(200,404,6,_RecFirst);   // Material holen
          if (erx>_rLocked) then begin
            Erx # RecLink(210,404,8,_RecFirst); // ~Material holen
            if (erx>_rLocked) then RecBufClear(210);
            RecBufCopy(210,200);
            vMatDatei # 210;
          end;
*/
          vMatDatei # Mat_Data:Read(Auf.A.MaterialNr);
          if (vMatDatei <> 200) AND (vMatDatei <> 210) then begin
            debugx('Material ' + AinT(Auf.A.MaterialNr) + ' gibt es nicht! Auftrag' + Aint(Auf.A.Nummer)+ '/'+Aint(Auf.A.Position) );
            CYCLE;
          end;

          // ST 2013-06-24: neu: MAterial muss vorhanden sein, damit es aktualisiert wird
          if (Auf.A.Aktionstyp = c_Akt_LFS) then begin
            Lfs.P.Nummer    # Auf.A.Aktionsnr;
            Lfs.P.Position  # Auf.A.Aktionspos;
            Erx # RecRead(441,1,0);                 // LFS-Pos holen
            if (erx<=_rLocked) then begin
              Erx # RecLink(440,441,1,_recFirst);   // LFS-Kopf holen
              if (erx<=_rLocked) then begin
                vKosten # 0.0;
                vEK     # 0.0;
                if (Lfs.zuBA.Nummer=0) AND (Lfs.Datum.Verbucht<>0.0.0) then begin
    /*
    // über LFA              Lfs_Data:BerechneLfsKosten(200, true, var vKosten);
    */
                  Lfs_Data:BerechneLfsKosten(200, true, var vKosten); // ST/AH 2016-07-07: Auch Kosten des Lieferscheines berücksichtigen
                  Lfs_Data:BerechneEKundKostenAusVorkalkulation(200, true, var vEK, var vKosten, var vPreisFound);
                end;
                RecBufClear(204);
                Mat.A.Aktionstyp    # Auf.A.Aktionstyp;
                Mat.A.Aktionsnr     # Auf.A.Aktionsnr;
                Mat.A.Aktionspos    # Auf.A.Aktionspos;
                Mat.A.Aktionspos2   # Auf.A.Aktionspos2;
                Erx # RecRead(204,2,0);
                if (Erx=_rOK) or (Erx=_rMultikey) then begin
                  RecRead(204,1,_recLock | _Recnoload);

    //                    Mat.A.KostenW1        # vZ;
                  if (Mat.Bestand.Gew<>0.0) then
                    Mat.A.KostenW1    # Rnd(vKosten / Mat.Bestand.Gew * 1000.0,2)
                  else
                    Mat.A.KostenW1    # 0.0;

                  // 10.04.2013 VORLÄUFIG:
                  Mat.A.KostenW1ProMEH  # 0.0;
    //???              if (Mat.A.KostenW1<>0.0) and
                  if (Mat.Bestand.Menge + Mat.Bestellt.Menge<>0.0) then
                    Mat.A.KostenW1ProMEH # Rnd( (Mat.A.KostenW1 * (Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0) / (Mat.Bestand.Menge + Mat.Bestellt.Menge) ,2);
                  RekReplace(204,_recUnlock,'AUTO');
                  if (vMatDatei=200) then begin
                    vOk # Mat_A_Data:Vererben();
                  end
                  else begin
                    vOk # Mat_A_Abl_Data:Abl_Vererben();
                    RecBufCopy(210,200);
                  end;
                  if (vOK=false) then RETURN false;
                end;
                // unverbuchte LFA haben niemals Kosten
              end;
            end;
// 06.02.2017 AH ?????            if (Lfs.zuBA.Nummer<>0) and (Lfs.Datum.Verbucht=0.0.0) then Mat.Kosten # 0.0;
          end // LFS
          else begin
            // 2022-12-08 AH
            if (Auf.A.Aktionstyp = c_Akt_DFakt) or (Auf.A.Aktionstyp = c_Akt_DfaktBel) or (Auf.A.Aktionstyp = c_Akt_DfaktGut) then begin
//debugx('!');
            end;
          end;

          //vX  # Rnd(Mat.EK.effektiv * Mat.Bestand.Gew / 1000.0,2);
          vEK     # Rnd(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0,2);
          vKosten # Rnd(Mat.Kosten * Mat.Bestand.Gew / 1000.0,2);
//debugx(anum(vEK,2));
        end
        Else if (Auf.A.ArtikelNr <> '') then begin

          if (Auf.A.Aktionstyp = c_Akt_LFS) then begin
            Lfs.P.Nummer    # Auf.A.Aktionsnr;
            Lfs.P.Position  # Auf.A.Aktionspos;
            Erx # RecRead(441,1,0);                 // LFS-Pos holen
            if (erx<=_rLocked) then begin
              Erx # ReCLink(440,441,1,_recFirst);     // LFS-Kopf holen
              if (erx<=_rLocked) then begin
                vKosten    # 0.0;
                Erx # RecLink(250, 441,3,_recFirst);    // Artkel holen
                if (erx>_rLocked) then CYCLE;
                vKosten # 0.0;
                vEK     # 0.0;

                if (Lfs.zuBA.Nummer=0) or (Lfs.Datum.Verbucht<>0.0.0) then begin
                  Lfs_Data:BerechneLfsKosten(250, true, var vKosten);
                  Lfs_Data:BerechneEKundKostenAusVorkalkulation(250, true, var vEK, var vKosten, var vPreisFound);
                  // 11.02.2016:
                  // wenn KEINE Vorkaalkulation (bzw. Vorkalkulation ist zu vernachlässigen, da es keein "Artikel ohne Mengenfügrung" ist
                  // lassen wir die Preise UNBERÜHRT
                  if (vPreisFound=false) then begin
                    vEK     # Auf.A.EKPreisSummeW1;
                    vKosten # Auf.A.InterneKostW1;
                  end;
                end;
              end;
            end;
          end;
        end;

//debugX(anum(vEK,2)+'EK');

        // Auf.Aktion ggf. setzen...
        // ??? ST 2013-06-24: neu: MAterial muss vorhanden sein, damit es aktualisiert wird
        if (Auf.A.EKPreisSummeW1<>vEK) or (Auf.A.interneKostW1<>vKosten) then begin
        //) AND (Mat.Nummer <> 0) then begin
          RecRead(404,1,_recLock | _Recnoload);
          Auf.A.EKPreisSummeW1 # vEK;
          Auf.A.interneKostW1  # vKosten;
          RekReplace(404,_recUnlock,'AUTO');
        end;

        vErlEK   # vErlEK + Auf.A.EKPreisSummeW1;
        vErlKost # vErlKost + Auf.A.InterneKostW1;
      END;

      if (vErlEK<>Erl.K.EKPreisSummeW1) or (Erl.K.InterneKostW1<>vErlKost) then begin
        RecRead(451,1,_recLock);
        Erl.K.EKPreisSummeW1  # vErlEK;
        Erl.K.InterneKostW1   # vErlKost;
        Erx # Erl_Data:Replace451(_recUnlock,'AUTO');
      end;

    END;

//debug(aint(erl.rechnungsnr));
    // Onlinestatistik verbuchen
    // 09.12.2014 AH: Stornos gleich behandlen
    if (Erl.Rechnungstyp=c_Erl_Gut) or (Erl.Rechnungstyp=c_Erl_REKOR) or (Erl.Rechnungstyp=c_Erl_BoGut) or
      (Erl.Rechnungstyp=c_Erl_StornoGut) or (Erl.Rechnungstyp=c_Erl_StornoREKOR) or (Erl.Rechnungstyp=c_Erl_StornoBoGut) then
      BucheRechnung('GUT');
    else if (Erl.Rechnungstyp=c_Erl_Bel_LF) or (Erl.Rechnungstyp=c_Erl_Bel_KD) or
      (Erl.Rechnungstyp=c_Erl_StornoBel_LF) or (Erl.Rechnungstyp=c_Erl_StornoBel_KD) then
      BucheRechnung('BEL')
    else
      BucheRechnung('RE');

//debug('-'+aint(erl.rechnungsnr));

//    Erx # RecRead(450,1,_recNext);
//if (erl.Rechnungsnr<>vNr+1) then debug('-------- von '+aint(vNr)+' auf '+aint(Erl.rechnungsnr));
  RETURN true;
end;


//========================================================================
//  Recalc
//
//========================================================================
sub Recalc(
  aAbDatum  : datE;
) : logic;
local begin
  Erx   : int;
  vPrg  : int;
end;
begin
/*
  WinEvtProcessSet(_WinEvtTimer,false);
  if (gMDi<>0) and (gZLList<>0) then begin
    //vHdl # gZLList;
    vHDl # gMDI;
    vHdl->wpdisabled  # true;
    vHdl->wpvisible   # false;
  end;
*/

  // muss der 1. eines Monats sein
  if (DateDay(aAbDatum)<>1) then RETURN false;

  APPOFF();

  Winsleep(500);

  // OST löschen...
  Erx # RecRead(890,1,_recfirst);
  WHILE (erx<=_rLocked) do begin

    // ST 2014-01-21 Projekt 1483/23: Ergebnisse der Monatlichen Bestandssummierungen nicht löschen
    if (_RecCalcIgnore()) then begin
      Erx # RecRead(890,1,_recNext);
      CYCLE;
    end;

    if (Datemake(1,OSt.Monat, Ost.Jahr)>=aAbDatum) then begin
      RekDelete(890,0,'MAN');
      Erx # RecRead(890,1,0);
      Erx # RecRead(890,1,0);
      CYCLE;
    end;
    Erx # RecRead(890,1,_recNext);
  END;

  // STA löschen...
  RecBufClear(899);
  Sta.Re.Datum # aAbDatum;
  Erx # RecRead(899,5,0);
  WHILE (erx<=_rNoKey) and (Sta.Re.Datum>=aAbDatum) do begin
    // wenn es verbuchte Skonto-Einträge sind, dann NICHT löschen! (HOW)
    if (Sta.Zusatzinfo='_Skonto') and (Sta.Lfs.Datum<>0.0.0) then begin
      Erx # RecRead(899,5,_recNext);
      CYCLE;
    end;

    RekDelete(899,0,'MAN');
    Erx # RecRead(899,5,0);
    Erx # RecRead(899,5,0);
  END;


  vPrg # Lib_Progress:Init('', RecInfo(450,_recCount));

  RecBufClear(450);
  Erl.Rechnungsdatum  # aAbDatum;

  FOR Erx # RecRead(450,4,0)                // Erlöse loopen
  LOOP Erx # RecRead(450,4,_recNext)
  WHILE (erx<=_rNokey) and (Erl.Rechnungsdatum>=aAbDatum) do begin

    vPrg->Lib_Progress:Step();
    vPrg->Lib_Progress:SetLabel('Erlös: ' + Aint(Erl.Rechnungsnr) + ' ' + CnvAd(ERl.Rechnungsdatum));
//if (Erl.Rechnungsnr<>70000030) then CYCLE;

    if (_ProcessErl()=false) then begin
      APPON();
      ErrorOutput;
      RETURN false;
    end;

  END;

  vPrg->Lib_Progress:Term();

//  WinEvtProcessSet(_WinEvtTimer,true);
//  if (vHdl<>0) then begin
//    vHdl->wpvisible   # true;
//    vHdl->wpdisabled  # false;
//  end;
  APPON();


//todox('DashboarD!!');

  RETURN true;
end;


//========================================================================
// RecalcErl    für eine einzelen Rechnung
//========================================================================
sub RecalcErl(
  aRenr       : int;
  opt aSilent : logic) : logic
local begin
  Erx   : int;
  vTyp  : alpha;
end;
begin

  //2010141
  Erl.Rechnungsnr # aReNr;
  Erx # RecRead(450,1,0);
  if (Erx>_rLocked) then RETURN false;

  APPOFF();

  Winsleep(50);

  TRANSON;

  // AUSBUCHEN STA
  Sta_Data:StorniereRe(Erl.Rechnungsnr, 0);

  // AUSBUCHEN OST
  if (Erl.Rechnungstyp=c_Erl_StornoBel_KD) or (Erl.Rechnungstyp=c_Erl_StornoBel_LF) then
    vTyp # 'BEL';
  else if (Erl.Rechnungstyp=c_Erl_StornoREKOR) or (Erl.Rechnungstyp=c_Erl_StornoGut) then
    vTyp # 'GUT';
  else
    vTyp # 'RE';
  if (BucheRechnung(vTyp, true)=False) then begin
    TRANSBRK;
    if (aSilent=false) then Msg(450099,'',0,0,0);
    RETURN false;
  end;

  // WIEDER EINBUCHEN
  if (_ProcessErl()=false) then begin
    TRANSBRK;
    APPON();
    ErrorOutput;
    RETURN false;
  end;
  
  TRANSOFF;
  APPON();

  if (aSilent=false) then Msg(999998,'',0,0,0);

  RETURN true;
end;


//========================================================================
//  Job
//
//========================================================================
sub Job(aPara : alpha) : logic;
local begin
  vI        : int;
  vProgress : int;
end;
begin

  if (Set.Ost.Wie<>'J') then RETURN true;

  ProcessStack();

  RETURN true;
end;


//========================================================================
//
//========================================================================
Sub Initialize(
  opt aSilent : logic;
);
local begin
  Erx     : int;
  vDatei  : int;
  vA      : alpha(1000);
  vI,vJ   : int;
  vWin    : int;
  vDat    : date;
  vVon    : int;
  vBis    : int;
  vFirst  : logic;
  vMenge  : float;
end;
begin

  if (aSilent=false) then begin
    if (RecInfo(892,_reccount)+RecInfo(891,_reccount)>0) then begin
      vA # 'Statistik ist bereits gefüllt! Alte Werte können im Nachhinein NICHT KORREKT neu errechnet werden!!!'+StrChar(13)+'Soll die Statistik trotzdem gelöscht werden und "grob" neu errechnet werden?';
      if (Msg(99,vA,_WinIcoWarning,_WinDialogYesNo,2)<>_WinidYes) then RETURN;
    end;
  end;

  // vom 1.1.Vorjahr bis letzten Monat,,,
  vDat  # today;
  vVon  # ((vDat->vpyear-1-2000) * 12 ) + 1;
  vBis  # ((vDat->vpyear-2000) * 12 ) + (vDat->vpmonth);
//debug('von '+aint(vVon)+' bis '+aint(vBis));

  vI # 2 + RecInfo(401, _recCount) + RecInfo(411, _recCount);
  vWin # Lib_Progress:Init('Berechnung...Aufträge', vI);

  RecDeleteAll(891);
  vWin->Lib_Progress:Step();
  RecDeleteAll(892);
  vWin->Lib_Progress:Step();


  // Aufträge einfügen -------------------------------------------------------------------------------------------
  FOR vDatei # 401
  LOOP vDatei # vDatei + 10
  WHILE (vDatei<421) do begin
    FOR Erx # recread(vDatei,1,_recfirst)
    LOOP Erx # recread(vDatei,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      vWin->Lib_Progress:Step();

      if (vDatei=411) then RecBufCopy(411,401);
//if (Auf.P.Nummer<>100698) then CYCLE;

      if (vDatei=401) then begin
        RecLink(400,401,3,_recFirst); // Kopf holen
      end
      else begin
        RecLink(410,411,3,_recFirst); // Kopf holen
        RecbufCopy(410,400);
      end;

      // über alle Monate laufen...
      vFirst # y;
      FOR vI # vVon
      LOOP inc(vI)
      WHILE (vI<=vBis) do begin
        vDat # DateMake(1, 1 + (vI % 12), 2000 + (vI / 12));
        vDat->vmDayModify(-1);

        if (Auf.Datum>vDat) then CYCLE;

        // NUR EINGANG buchen...
        if (vFirst) then begin
//debugx('EINGANG '+cnvad(Auf.Datum)+' : '+anum(auf.P.Gewicht,0)+'kg');
          Auf_P_Subs:StatistikBuchen(0, 0, Auf.Datum, n, y);
          vFirst # false;
        end;

        if ("Auf.P.Lösch.Datum"<>0.0.0) and ("Auf.P.Lösch.Datum"<=vDat) then BREAK;

        // auch als BESTAND buchen...
        if (AAr.Nummer<>Auf.P.Auftragsart) then
          Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
        if (VwA.Nummer<>Auf.P.Verwiegungsart) then begin
          Erx # RecLink(818,401,9,_recFirst);   // Verwiegungsart holen
          if (erx<>_rok) then begin
            RecBufClear(818);
            VWa.NettoYN # Y;
          end;
        end;

        Auf.P.Prd.Rest      # Auf.P.Menge;
        Auf.P.Prd.Rest.Gew  # Auf.P.Gewicht;
        Auf.P.Prd.Rest.Stk  # "Auf.P.Stückzahl";

        // Aktionen loopen...
        FOR Erx # Reclink(404,401,12,_recfirst)
        LOOP Erx # Reclink(404,401,12,_recNext)
        WHILE (erx<=_rLocked) do begin

          // "Lieferungen" etc. rückrechnen
          if (Auf.A.aktionsDatum<=vDat) and ("Auf.A.Löschmarker"='') and
            ((Auf.A.Aktionstyp=c_Akt_DFAKT) or (Auf.A.Aktionstyp=c_Akt_DFAKTGut) or (Auf.A.Aktionstyp=c_Akt_DFAKTBel) or
              (Auf.A.Aktionstyp=c_Akt_LFS) or (Auf.A.Aktionstyp=c_Akt_Abruf) or (Auf.A.Aktionstyp=c_Akt_Prd_Verbrauch)) then begin
              Auf.A.Menge         # -Auf.A.Menge;
              Auf.A.Gewicht       # -Auf.A.Gewicht;
              Auf.A.NettoGewicht  # -Auf.A.NettoGewicht;
              "Auf.A.Stückzahl"   # -"Auf.A.Stückzahl";

            if (AAr.KonsiYN=false) then
              Auf_A_Data:_AddAktion(var Auf.P.Prd.Rest, var Auf.P.Prd.Rest.Stk, var Auf.P.Prd.Rest.Gew);
            if (Auf.P.Prd.Rest<0.0) then      Auf.P.Prd.Rest      # 0.0;
            if (Auf.P.Prd.Rest.Stk<0) then    Auf.P.Prd.Rest.Stk  # 0;
            if (Auf.P.Prd.Rest.Gew<0.0) then  Auf.P.Prd.Rest.Gew  # 0.0;
          end;
        END;
  //debugx('Bestand '+cnvad(vDat)+' : '+ anum(auf.p.prd.rest.gew,0)+'kg');
          if (Auf.P.Prd.Rest>0.0) or (Auf.P.Prd.Rest.Gew>0.0) or (Auf.P.Prd.Rest.Stk>0) then begin
            Auf_P_Subs:StatistikBuchen(0, 0, vDat, y, n);
          end;
      END;

    END;

  END;  // Datei

//  Call OsT_Data:Initialize

  // Bestellungen einfügen ---------------------------------------------------------------------------------------
  vI # RecInfo(501, _recCount) + RecInfo(511, _recCount);
  Lib_Progress:Reset(vWin, 'Berechnung...Bestellung', vI);

  FOR vDatei # 501
  LOOP vDatei # vDatei + 10
  WHILE (vDatei<521) do begin
    FOR Erx # recread(vDatei,1,_recfirst)
    LOOP Erx # recread(vDatei,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      vWin->Lib_Progress:Step();

      if (vDatei=511) then RecBufCopy(511,501);
//if (ein.P.Nummer<>1383) then CYCLE;

      if (vDatei=501) then begin
        RecLink(500,501,3,_recFirst); // Kopf holen
      end
      else begin
        RecLink(510,511,3,_recFirst); // Kopf holen
        RecbufCopy(510,500);
      end;

      // über alle Monate laufen...
      vFirst # y;
      FOR vI # vVon
      LOOP inc(vI)
      WHILE (vI<=vBis) do begin
        vDat # DateMake(1, 1 + (vI % 12), 2000 + (vI / 12));
        vDat->vmDayModify(-1);

        if (Ein.Datum>vDat) then CYCLE;

        // NUR EINGANG buchen...
        if (vFirst) then begin
//debugx('EINGANG '+cnvad(Ein.Datum)+' : '+anum(Ein.P.Gewicht,0)+'kg');
          Ein_P_Subs:StatistikBuchen(0, 0, Ein.Datum, n, y);
          vFirst # false;
        end;

        if ("Ein.P.Lösch.Datum"<>0.0.0) and ("Ein.P.Lösch.Datum"<=vDat) then BREAK;

        // auch als BESTAND buchen...
        Ein.P.FM.Rest      # Ein.P.Menge;
        Ein.P.FM.Rest.Stk  # "Ein.P.Stückzahl";

        // Eingänge loopen...
        FOR Erx # Reclink(506,501,14,_recfirst)
        LOOP Erx # Reclink(506,501,14,_recNext)
        WHILE (erx<=_rLocked) do begin

          // "Lieferungen" etc. rückrechnen
          if ((Ein.E.eingangYN) and (Ein.E.Eingang_Datum<=vDat)) or
            ((Ein.E.VSBYN) and (Ein.E.VSB_Datum<=vDat)) or
            ((Ein.E.AusfallYN) and (Ein.E.Ausfall_Datum<=vDat)) then begin

            if (Ein.P.MEH=Ein.E.MEH) then  vMenge # Ein.E.Menge
            else if (Ein.P.MEH='STK') then  vMenge # CnvFI("Ein.E.Stückzahl")
            else if (Ein.P.MEH='KG') then  vMenge # (Ein.E.Gewicht)
            else if (Ein.P.MEH='T') then   vMenge # (Ein.E.Gewicht) / 1000.0;

            Ein.P.FM.Rest     # Ein.P.FM.Rest - vMenge;
            Ein.P.FM.Rest.Stk # Ein.P.FM.Rest.Stk - "Ein.E.Stückzahl";

            if (Ein.P.FM.Rest<0.0) then      Ein.P.FM.Rest      # 0.0;
            if (Ein.P.Fm.Rest.Stk<0) then    Ein.P.FM.Rest.Stk  # 0;
          end;
        END;
//debugx('Bestand '+cnvad(vDat)+' : '+ anum(Ein.p.FM.rest,0)+'kg');
          if (Ein.P.FM.Rest>0.0) or (Ein.P.FM.Rest.Stk>0) then begin
            Ein_P_Subs:StatistikBuchen(0, 0, vDat, y, n);
          end;
      END;

    END;

  END;  // Datei

/***/

/***
  FOR Erx # recread(501,1,_recfirst)
  LOOP Erx # recread(501,1,_recNext)
  WHILE (erx<=_rLocked) do begin
    vWin->Lib_Progress:Step();
    RecLink(500,501,3,_recFirst); // Kopf holen
    Ein_P_Subs:StatistikBuchen(0,0,y);
  END;
  FOR Erx # recread(511,1,_recfirst)
  LOOP Erx # recread(511,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    vWin->Lib_Progress:Step();
    RecLink(510,511,3,_recFirst); // Kopf holen
    RecbufCopy(510,400);
    RecbufCopy(511,401);
    Ein_P_Subs:StatistikBuchen(0,0,y);
  END;
**/


  // Erlöse einfügen ---------------------------------------------------------------------------------------------
  vI # RecInfo(450, _recCount);
  Lib_Progress:Reset(vWin, 'Berechnung...Erlöse', vI);
  FOR Erx # recread(450,1,_recfirst)
  LOOP Erx # recread(450,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    vWin->Lib_Progress:Step();
//if (erl.rechnungsdatum->vpyear<>2013) then CYCLE;
    _InitStack('+', 'ERLOES', aint(Erl.Rechnungsnr));
    OSt.S.Datum # Erl.Rechnungsdatum;
    _InsertStack();
  END;



  // Materialbestand einfügen ------------------------------------------------------------------------------------
/***/
  Lib_Progress:Reset(vWin, 'Berechnung...Material', vBis-vVon);
  FOR vI # vVon
  LOOP inc(vI)
  WHILE (vI<vBis) do begin
    vWin->Lib_Progress:Step();

    vDat # DateMake(1, 1 + (vI % 12), 2000 + (vI / 12));
//debug('MAT:'+cnvad(vDat));

    Mat_Data:Foreach_BestandRueckwirkend(vDat, here+':MatRueckwirkend_Delegate');
  END;

  Mat_Data:Foreach_BestandRueckwirkend(today, here+':MatRueckwirkend_Delegate');
/***/

  vWin->Lib_Progress:Term();

end;


//========================================================================
// MatRueckwirkend_Delegate(aDat
//========================================================================
sub MatRueckwirkend_Delegate(aDat : date) : int;
begin
//debugx(cnvad(aDat));
  "Mat.Löschmarker" # '';         // ist Bestand
  if (aDat<>today) then aDat->vmdaymodify(-1);
  Mat.Eingangsdatum # aDat;
  Mat_Data:StatistikBuchen(0,y);

  RETURN 0;
end;


//========================================================================
//========================================================================
Sub UebertrageBestand(
  aArt    : alpha;
  aZ1     : int;
  aJ1     : int;
  aZ2     : int;
  aJ2     : int;
);
local begin
  Erx     : int;
  vPrgr   : int;
end;
begin

  vPrgr # Lib_Progress:Init( 'Übetrag '+aArt, RecInfo( 892, _recCount ), true );

  RecBufClear(892);
  OSt.E.Zeitraum.Art   # aArt;
  OSt.E.Zeitraum.Zahl  # aZ1;
  OSt.E.Zeitraum.Jahr  # aJ1;
  FOR Erx # RecRead(892,1,0)
  LOOP Erx # RecRead(892,1,_recNext)
  WHILE (Erx<_rNoRec) and (OSt.E.Zeitraum.Art=aArt) and
    (OSt.E.Zeitraum.Zahl=aZ1) and (OSt.E.Zeitraum.Jahr=aJ1) do begin

    vPrgr->Lib_Progress:Step();

    if (StrFind(OSt.E.Name,'_BESTAND',0)=0) then CYCLE;

    // kopieren
    OSt.E.Zeitraum.Zahl  # aZ2;
    OSt.E.Zeitraum.Jahr  # aJ2;
    RekInsert(892,_recunlock);
//debug('ERG Uebertrag: '+OSt.E.Name+Ost.E.Name2);

    // Restore
    OSt.E.Zeitraum.Zahl  # aZ1;
    OSt.E.Zeitraum.Jahr  # aJ1;
    RecRead(892,1,0);
  END;

  vPrgr->Lib_Progress:Term();

end;


//========================================================================
//  BucheKorrektur
//========================================================================
Sub BucheKorrektur(
  aDeltaEK  : float;
  aDeltaIK  : float;
  aDeltaVK  : float;
  aMatNr    : int;
) : logic;
local begin
  vPreis    : float;
end;
begin
//debug(anum(aDeltaEK,2)+' '+anum(aDeltaIK,2)+' '+anum(aDeltaVK,2));

  // LF-Gutschriften/LF-Belastungen ggf. überspringen
  if (Set.Auf.GutBelLFNull) and
      ((Erl.Rechnungstyp=c_Erl_StornoGut) or (Erl.Rechnungstyp=c_Erl_StornoBel_LF)) or
      ((Erl.Rechnungstyp=c_Erl_Gut) or (Erl.Rechnungstyp=c_Erl_Bel_LF)) then RETURN true;

  if (Erl.K.Steuerschl=0) then RETURN true;  // Holzrichters "Sonderkonten" überspringen

  //aName : alpha; aDate : date; aEK : float; aVK : float; aIK : float; aStk : int; aGew : float; aMenge : float; aMEH : alpha; aDeckB1 : float; );
  _Save890('UNTERNEHMEN',                 Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);

  _Save890('KU:'+CnvAI(Erl.Kundennummer), Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);
  _Save890('VERT:'+CnvAI(Erl.Vertreter),  Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);
  _Save890('VERB:'+CnvAI(Erl.Verband),    Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);
  if (Erl.K.AuftragsPos=0) then begin   // Kopfaufpreis
    _Save890('AUF.K.Z:'+Erl.K.AufpreisSchl,         Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);
    if (Erl.K.Warengruppe<>0) then
    _Save890('WGR:'+cnvai(Erl.K.Warengruppe),       Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);
  end
  else begin
    RekLink(819,451,4,_recFirst);       // Warengruppe holen
    _Save890('WGR:'+cnvai(Erl.K.Warengruppe),       Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);
    _Save890('AUFART:'+cnvai(Erl.K.Auftragsart),    Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);
    if (Wgr_Data:IstArt()) then begin  // Artikel?
      RekLink(250,451,12,_recFirst); // Artikel holen
      _Save890('ART:'+StrCnv(Art.Nummer,_strupper), Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);
      _Save890('AGR:'+Cnvai(Art.ArtikelGruppe),     Erl.Rechnungsdatum, aDeltaEK, aDeltaVK, aDeltaIK, 0, 0.0, 0.0, '', aDeltaVK - aDeltaEK - aDeltaIK);
    end;
  end;

  RETURN Sta_Data:Verbuchen('KORREKTUR', aDeltaEK, aDeltaIK, aDeltaVK, aMatNr);
end;


//========================================================================
//  entfernt 892er mit einem SPACE am Ende vom Namen
// Call Ost_Data:Repair892
//========================================================================
Sub Repair892();
local begin
  Erx     : int;
  vName2  : alpha;
  v892    : int;
  vAnz    : int;
end;
begin

  Erx # Recread(892,1,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    vName2 # StrAdj(OST.E.Name2, _StrEnd);
    if (vName2=OSt.E.Name2) then begin
      Erx # Recread(892,1,_recNext);
      CYCLE;
    end;

    inc(vAnz);
debugx('fix KEY892');
    v892 # RekSave(892);
    RekDelete(892);

    Ost.E.Name2 # vName2;
    Erx # Recread(892,1,_RecTest);
    if (Erx=_rOK) then begin
      RecRead(892,1,_recLock);
      OSt.E.BetragW1      # OSt.E.BetragW1    + v892->OSt.E.BetragW1;
      "OSt.E.Stückzahl"   # "OSt.E.Stückzahl" + v892->"OSt.E.Stückzahl";
      OSt.E.Gewicht       # OSt.E.Gewicht     + v892->OSt.E.Gewicht;
      OSt.E.Satzanzahl    # OSt.E.Satzanzahl  + v892->OSt.E.Satzanzahl;
      OSt.E.Menge         # OSt.E.Menge       + v892->OSt.E.Menge;
      Erx # RekReplace(892);
    end
    else begin
      Erx # RekInsert(892);
    end;
if (erx<>_rOK) then debugx('ERROR KEY892');

    RekRestore(v892);

    Erx # Recread(892,1,0);
    Erx # Recread(892,1,0);
  END;


  Msg(99,aint(vAnz)+' Sätze gelöscht und in andere Sätze integriert',0,0,0);

end;


//========================================================================