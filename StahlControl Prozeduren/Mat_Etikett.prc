@A+
//===== Business-Control =================================================
//
//  Prozedur  Mat_Etikett
//                  OHNE E_R_G
//  Info
//    Steuert den Materialetikettendruck
//
//  16.07.2007  ST  Erstellung der Prozedur
//  07.05.2008  MS  Lieferant->Kunde, BestNr und Guete ausm Auftrag
//  24.07.2008  MS  Ausfuehrung Oben ausgeschrieben (wunsch von Lichtgitter)
//  27.08.2009  MS  GV.Alpha.64 Abmessung mit Laenge aus FM (SLC) (RAUSGENOMMEN)
//  15.12.2009  MS  Erzeugt am Datum hinzugefuegt
//  29.07.2010  ST  Werksnummer hinzugefügt
//  12.10.2011  AI  Init um aKeinDruck erweitert
//  26.09.2012  MS  AFUnten hinzugefuegt
//  03.12.2012  TM  Werksnummer als Barcode in GV.Alpha.70
//  05.05.2014  TM  Verpackungstexte aus FertigungsVpg in GV.Alpha.71 - 76
//  18.02.2015  AH  Bugfix: Etikettenfenster verspringt "WindowBonus"
//  20.05.2021  ST  Bugfix: "sub Init" führt RecBufClear aus Projekt 2195/58#
//  30.09.2021  ST  Edit: opt aKeys hinzugefügt
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    sub Etikett();
//    sub Init(aNuimmer: int; opt aKeinDruck : logic):
//    sub AusEtikett();
//    sub AusEtikettMarkLoop();
//
//
// ---------- Diverses ---- FREIE FELDER
//   => GV.Alpha.77
//   => GV.Num.12
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

declare Init(aNummer : int; opt aKeinDruck : logic; opt aKeys  : alpha(250));

//========================================================================
//  Etikett
//    Fragt den Etikettentyp ab
//========================================================================
sub Etikett(
  opt aNr     : int;
  opt aSilent : logic;
  opt aAnzahl : int;
  opt aMark   : logic;
);
local begin
  vA      : alpha;
  vBonus  : int;
end;
begin

  // Ankerfunktion?
  vA # Aint(aNr) + '|';
  if (aSilent = true) then vA # vA + '1' + '|' + Aint(aAnzahl) + '|'
  else vA # vA + '0' + '|' + Aint(aAnzahl) + '|';
  if (aMark = true) then vA # vA + '1'
  else vA # vA + '0';
  if (RunAFX('Mat.Etikett', vA)<0) then RETURN;


  if (aNr<>0) then begin
    vBonus # VarInfo(WindowBonus);    // 18.02.2015 AH
    Init(aNr);
    if (vBonus<>0) then VarInstance(WindowBonus, vBonus);
    RETURN;
  end;

  if (gUsergroup='MC9090') then RETURN;
  if (gUsergroup='JOB-SERVER') then RETURN;

  // Etikett auswählen
  RecBufClear(840);
  RecBufClear(999);
  if (aMark) then
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Eti.Verwaltung',here+':AusEtikettMarkLoop')
  else
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Eti.Verwaltung',here+':AusEtikett');
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//  Init()
//  Füllt die GV für den Etikettendruck und Startet das entspr. Formular
//========================================================================
sub Init(
  aNummer         : int;
  opt aKeinDruck  : logic;
  opt aKeys       : alpha(250);
);
local begin
  Erx       : int;
  vFound    : logic;
  vMat      : int;
  vAFOben   : alpha(800);
  vAFUnten  : alpha(800);
  vI        : int;

  vBuf100   : int;
  vBuf200   : int;
  vBuf400   : int;
  vBuf401   : int;
  vBuf700   : int;
  vBuf702   : int;
  vBuf703   : int;
  vBuf704   : int;
  vBuf707   : int;
end;
begin

  // Ankerfunktion?
  if (RunAFX('Mat.Etikett.Init',Aint(aNummer))<0) then RETURN;

  // Übergebenes Etikett lesen
  Eti.Nummer # aNummer;
  Erx # RecRead(840,1,0);
  if (Erx > _rLocked) then begin
    // Etikett nicht gefunden
    RecBufClear(840);
//debug('Etikett nicht gefunden');
    RETURN;
  end;

  // ST 2021-05-26 Bugfix Projekt 2195/58
  RecBufClear(999);

  /* -------------------------------------------------------------------
    Hier werden ALLE Daten gelesen, die evtl. auf dem Etikett gedruckt
    werden sollen. Was auf dem Etikett dargestellt werden soll, wird im
    Druckformular angegeben.
    Bei pufferverändernden RecLinks in eine Datei, die mehrfach verwendet
    wird, muss auf die Reihenfolge geachtet und das vorherige
    Ergebnis in eine GV. Variable übergeben werden.

    Z.B. Material -> Adressen
      -> Lieferant (100)
          -> Gv.* = Adr.*
      -> Kunde (100)
        -> Gv.* = Adr.*

    Für die Veränderung von Daten in einem Etikttendialog, müssen
    die Werte vorher unbedingt in die GV Alpha Vars übnergeben werden

  -------------------------------------------------------------------  */
  vBuf100 # RekSave(100);
  vBuf200 # RekSave(200);
  vBuf400 # RekSave(400);
  vBuf401 # RekSave(401);
  vBuf700 # RekSave(700);
  vBuf702 # RekSave(702);
  vBuf703 # RekSave(703);
  vBuf704 # RekSave(704);
  vBuf707 # RekSave(707);

  // Materialkarte lesen
  Erx # RecRead(200,1,0);
  if !(Erx<=_rLocked) then RecBufClear(200);
  vMat # Mat.Nummer;

  // Auftragsposition lesen
  Erx # RecLink(401,200,16,_RecFirst);
  if (Erx>_rLocked) then begin
    Erx # RecLink(411,200,17,_RecFirst);
    if (Erx<=_rLocked) then
      RecBufCopy(411,401)
    else
      RecBufClear(401);
  end;

  // Auftragskopf lesen
  Erx # RecLink(400,401,3,_RecFirst);
  if (Erx>_rLocked) then begin
    Erx # RecLink(410,411,3,_RecFirst);
    if (Erx<=_rLocked) then
      RecBufCopy(410,400)
    else
      RecBufClear(400);
  end;


  // Betriebsauftrag - Fertigmeldung lesen
  // Anhand der Aktion die Fertigmeldung lesen / GGf. Vorgänger prüfen, da die Materialkarte gesplittet sein kann
  vFound # false;
  Erx # RecRead(200,1,0);
  WHILE (Erx<=_rLocked) and (vFound=n) do begin
    Erx # RecLinkInfo(707,200,28, _recCount);
    if(Erx > 0) then
      Erx # RecLink(707,200,28,_RecFirst);

    // Aktionen loopen
    Erx # RecLink(204,200,14,_RecFirst);

    WHILE (Erx <= _rLocked) and (vFound=n) DO begin
      if (Mat.A.Entstanden = Mat.Nummer) then begin
        vFound # true;
        BREAK;
      end else begin
        Erx # RecLink(204,200,14,_RecNext);
      end;
    END;

    // Falls keine entstandene Karte gefunden wurde, dann den Vorgänger prüfen
    if (vFound=n) then begin
      if ("Mat.Vorgänger"<>0) then begin
        Mat.Nummer # "Mat.Vorgänger";
        Erx # RecRead(200,1,0);
        CYCLE;
      end;
      Erx # _rNoRec;
    end;

  END;

  if(vFound = false) then begin
    // Eigentliche Materialkarte lesen
    Mat.Nummer # vMat;
    Erx # RecRead(200,1,0);
    if (Erx > _rLocked) then
      RecBufClear(200);

    // und FM zu dieser holen
    Erx # RecLink(707,200,28,_RecFirst);
    if (Erx > _rLocked) then
      RecBufClear(707);
  end
  else begin
    Erx # RecLink(707,200,28,_RecFirst);
    if (Erx > _rLocked) then
      RecBufClear(707);
  end;

  // Betriebsauftrag - Fertigung lesen
  Erx # RecLink(703,707,3,_RecFirst);
  if (Erx > _rLocked) then
    RecBufClear(703);

  // Betriebsauftrag - Verpackung lesen
  Erx # RecLink(704,703,6,_RecFirst);
  if (Erx > _rLocked) then
    RecBufClear(704);


  // Betriebsauftrag - Verpackung - Etikett lesen
  // Etikettendaten dürfen nicht geladen werden

  // Betriebsauftrag - Position lesen
  Erx # RecLink(702,703,2,_RecFirst);
  if (Erx > _rLocked) then
    RecBufClear(702);

  // Betriebsauftrag - Kopf lesen
  Erx # RecLink(700,703,1,_RecFirst);
  if (Erx > _rLocked) then
    RecBufClear(700);

  // Eigentliche Materialkarte lesen
  Mat.Nummer # vMat;
  Erx # RecRead(200,1,0);
  if !(Erx<=_rLocked) then RecBufClear(200);


  // ----------------   Materialdaten --------------------------------

  // Mat Ausfuehrung holen wurde extra mal von Lichtgitter gewuenscht !
  vAFOben   # '';
  vAFUnten  # '';
  FOR Erx # RecLink(201,200,11,_recFirst);
  LOOP Erx # RecLink(201,200,11,_recNext);
  WHILE (Erx <=  _rLocked) DO BEGIN
    if(Mat.AF.Seite = '1') then // OBEN
      Lib_Strings:Append(var vAFOben, Mat.AF.Bezeichnung, ', ');
    else // UNTEN
      Lib_Strings:Append(var vAFUnten, Mat.AF.Bezeichnung, ', ');
  END;

  // Material Reservierungen zusammen bauen gewünscht von Voelkel und Winkler
  // Belegt GV.Alpha.59 - 61        und GV.Num.09 - 11
  Erx # RecLink(203,200,13,_recFirst)
  WHILE(Erx <= _rLocked) and (vI < 3) DO BEGIN
    if(Mat.R.Kundennummer <> 0) then
      FldDef(999,1,59+vI,'(' + cnvAI(Mat.R.Kundennummer) + ')');

    if(Mat.R.Gewicht <> 0.0) then
      FldDef(999,2,9+vI,Mat.R.Gewicht);

    vI # vI + 1;
    Erx # RecLink(203,200,13,_recNext)
  END;


  // Lieferant Lesen
  Erx # RecLink(100,200,4,_RecFirst);
  if !(Erx<=_rLocked) then RecBufClear(100);


  // Warengruppe lesen
  Erx # RecLink(819,200,1,0);
  if (Erx>_rLocked) then RecBufClear(819);

  // Lieferschein lesen
  Erx # RecLink(441,200,27,_recFirst);
  if(Erx > _rLocked) then
    RecBufClear(441);

  // Status lesen
  Erx # RecLink(820,200,9,_recFirst);
  if(Erx > _rLocked) then
    RecBufClear(820);

  // Status
  GV.Alpha.62 # '(' + cnvAI(Mat.Status) + ') ' + Mat.Sta.Bezeichnung;


  // Werkstoffnummer
  Gv.Alpha.49 # Mat.Werkstoffnr;

  Gv.Int.03 # Lfs.P.Nummer;

  // Lieferant
  Gv.Alpha.01  #  '(' + CnvAi(Adr.LieferantenNr,_FmtNumNoGroup) + ') ' +
                    Adr.Stichwort + ' ' + Adr.Ort;

  Gv.Alpha.56  #  '(' + CnvAi(Adr.LieferantenNr,_FmtNumNoGroup) + ')';

  // Ursprungs LKZ
  Gv.Alpha.43 # Mat.Ursprungsland;

  // Lagerplatz
  Gv.Alpha.02 # Mat.Lagerplatz;

  // Eingangsdatum
  GV.Datum.01 # Mat.Eingangsdatum;

  // Einkaufsnr.
  GV.Int.05   # Mat.Einkaufsnr;


  //Erzeugt am
  GV.Datum.03 # Mat.Datum.Erzeugt;

  // Abmessung Nennmaß
  Gv.ALpha.03 # ANum(Mat.Dicke,Set.Stellen.Dicke)+ ' x ' + ANum(Mat.Breite,Set.Stellen.Breite);
  if ("Mat.Länge" > 0.0) then
    Gv.Alpha.03 # Gv.Alpha.03 + ' x ' + ANum("Mat.Länge","Set.Stellen.Länge");


  // Etikettierung: Abmessung
  if ("Mat.Etk.Länge" > 0.0) OR ("Mat.Etk.Breite" > 0.0) OR ("Mat.Etk.Dicke" > 0.0) then begin
    Gv.ALpha.03 # ANum(Mat.Etk.Dicke,Set.Stellen.Dicke)+ ' x ' + ANum(Mat.Etk.Breite,Set.Stellen.Breite);
    if ("Mat.Etk.Länge" > 0.0) then
      Gv.Alpha.03 # Gv.Alpha.03 + ' x ' + ANum("Mat.Etk.Länge","Set.Stellen.Länge");
  end;



  // Abmessung einzelnt
  if("Mat.Etk.Länge" > 0.0) then begin
    GV.Num.06 # "Mat.Etk.Länge";
    Gv.Alpha.46 # 'Code39N'+ cnvAF(GV.Num.06,_FmtInternal);
  end
  else begin
    GV.Num.06 # "Mat.Länge";
    Gv.Alpha.46 # 'Code39N'+ cnvAF(GV.Num.06,_FmtInternal);
  end
  if(Mat.Etk.Dicke > 0.0) then begin
    GV.Num.07 # Mat.Etk.Dicke;
    Gv.Alpha.47 # 'Code39N'+ cnvAF(GV.Num.07,_FmtInternal);
  end
  else begin
    GV.Num.07 # Mat.Dicke;
    Gv.Alpha.47 # 'Code39N'+ cnvAF(GV.Num.07,_FmtInternal);
  end;
  if(Mat.Etk.Breite > 0.0) then begin
    GV.Num.08 # Mat.Etk.Breite;
    Gv.Alpha.48 # 'Code39N'+ cnvAF(GV.Num.08,_FmtInternal);
  end;
  else begin
    GV.Num.08 # Mat.Breite;
    Gv.Alpha.48 # 'Code39N'+ cnvAF(GV.Num.08,_FmtInternal);
  end;


  // Abmessung Gemessen
  Gv.Alpha.04 # '';
  if((Mat.Dicke.Von + Mat.Dicke.Bis + Mat.Breite.Von + Mat.Breite.Bis) > 0.0) then begin
    Gv.ALpha.04 # ANum(Mat.Dicke.Von,Set.Stellen.Dicke)+ ' - ' + ANum(Mat.Dicke.Bis,Set.Stellen.Dicke) +  ' x ' +
                  ANum(Mat.Breite.Von,Set.Stellen.Breite) + ' - ' + ANum(Mat.Breite.Bis,Set.Stellen.Breite);
    if (("Mat.Länge.Von" + "Mat.Länge.Bis") > 0.0) then
      Gv.Alpha.04 # Gv.Alpha.04  +   ' x ' +
                  ANum("Mat.Länge.Von","Set.Stellen.Länge")+ ' - ' + ANum("Mat.Länge.Bis","Set.Stellen.Länge");
  end;

  // Güte / Stufe
  Gv.Alpha.05  # "Mat.Güte";
  if ("Mat.Gütenstufe" <> '') then
    Gv.Alpha.05 # Gv.ALpha.05 + '/' + "Mat.Gütenstufe";

  // Etikettierung: Güte
  if ("Mat.Etk.Güte" <> '') then
    Gv.Alpha.05  # "Mat.Etk.Güte";

  // Ausführung
  Gv.Alpha.06 # "Mat.AusführungOben";
  Gv.Alpha.07 # "Mat.AusführungUnten";

  // Ausfuehrung Oben ausgeschrieben
  Gv.Alpha.41 # vAFOben;
  Gv.Alpha.69 # vAFUnten;


  // Rid / Rad
  Gv.Num.01 # Mat.Rid;
  Gv.Num.02 # Mat.Rad;

  // Coilnummer
  Gv.Alpha.08 # Mat.Coilnummer;
  Gv.Alpha.16 # 'Code39N'+StrCnv(Mat.Coilnummer,_StrUpper | _StrLetterExt);

  // Materialnr  + Barcode
  Gv.Int.01 # Mat.Nummer;
  Gv.Alpha.09 # 'Code39N'+StrCnv(CnvAi(Mat.Nummer,_FmtNumLeadZero),_StrUpper | _StrLetterExt);

  // Ursprungsnummer
  GV.Int.04 # Mat.Ursprung;


  // Chargennummer
  Gv.ALpha.10 # Mat.Chargennummer;
  Gv.Alpha.17 # 'Code39N'+StrCnv(Mat.Chargennummer,_StrUpper | _StrLetterExt);

  // Ringnummer
  Gv.ALpha.11 # StrAdj(Mat.Ringnummer,_StrAll);
  Gv.Alpha.18 # 'Code39N'+StrCnv(Mat.Ringnummer,_StrUpper | _StrLetterExt);

  // Paketnummer
  Gv.ALpha.19 # StrAdj(CnvAi(Mat.Paketnr,_FmtNumNoGroup | _FmtNumNoZero),_StrAll);
  Gv.Alpha.23 # 'Code39N'+StrCnv(Gv.Alpha.19,_StrUpper | _StrLetterExt);

  // "Paketnummer / Ringnummer"
  Gv.ALpha.40 # Gv.Alpha.19 + ' / ' + Gv.Alpha.11;
  if (Gv.ALpha.40 = ' / ') then
    Gv.Alpha.40 # '';

  // "Mat.Nummer / Ringnummer" fuer SLC
  Gv.Alpha.42 # cnvAI(Mat.Nummer) + ' / ' + Gv.ALpha.11;
  if (Gv.ALpha.42 = ' / ') then
    Gv.Alpha.42 # '';

  // Werksnummer
  Gv.Alpha.65  # Mat.Werksnummer;
  Gv.Alpha.70 # 'Code39N'+StrCnv(Gv.Alpha.65,_StrUpper | _StrLetterExt);

  // Stk
  Gv.Int.02   # Mat.Bestand.Stk;
  GV.Alpha.55 # 'Code39N' + cnvAI(GV.Int.02);

  // Gewichte
  Gv.Num.03 # Mat.Bestand.Gew;
  Gv.Num.04 # Mat.Gewicht.Netto;
  Gv.Alpha.50 # 'Code39N'+cnvAF(Gv.Num.04,_FmtInternal);
  Gv.Num.05 # Mat.Gewicht.Brutto;
  GV.Alpha.58 # cnvAF(Mat.Gewicht.Netto,0,0,Set.Stellen.Gewicht) + ' kg';


  // Kommission
  Gv.ALpha.12 # Mat.Kommission
  GV.Alpha.66 # Mat.Strukturnr;

  // Verpackungstexte
  Gv.Alpha.14 # Auf.P.VpgText1;
  Gv.Alpha.15 # Auf.P.VpgText2;

  // Verpackungstexte aus Fertigungsverpackung
  GV.Alpha.71 # BAG.Vpg.VpgText1;
  GV.Alpha.72 # BAG.Vpg.VpgText2;
  GV.Alpha.73 # BAG.Vpg.VpgText3;
  GV.Alpha.74 # BAG.Vpg.VpgText4;
  GV.Alpha.75 # BAG.Vpg.VpgText5;
  GV.Alpha.76 # BAG.Vpg.VpgText6;



  // ----------------   Auftragsdaten --------------------------------

  // Bestellung
  Gv.ALpha.13 # Auf.P.Best.Nummer;
  Gv.ALpha.59 # Auf.Best.Nummer;

  // Material Bemerkung 1 & 2
  Gv.Alpha.52 # Mat.Bemerkung1;
  Gv.Alpha.53 # Mat.Bemerkung2;

  // Kundenbezugsnummern
  Gv.Alpha.21 # Auf.P.KundenArtNr;    // Kundenartikelnummer
  Gv.Alpha.22 # Auf.P.Best.Nummer;    // Kundenbestellnr
  Gv.Alpha.51 # 'Code39N' +StrCnv(Gv.Alpha.22,_StrUpper | _StrLetterExt);

  // Kunde: (Kndnr) Stichwort Ort
  Erx # RecLink(100,200,7,_RecFirst);
  if (Erx > _rLocked) or (Mat.KommKundennr = 0) then
    RecBufClear(100);


  Gv.Alpha.20 # '(' + CnvAi(Adr.KundenNr,_FmtNumNoGroup) + ') ' +
                    Adr.Stichwort + ' ' + Adr.Ort;

  Gv.Alpha.57 # '(' + CnvAi(Adr.KundenNr,_FmtNumNoGroup) + ')';

  // Kundenadresse einzeln
  Gv.Alpha.24 # Adr.Anrede;
  Gv.Alpha.25 # Adr.Name;
  Gv.Alpha.26 # Adr.Zusatz;
  Gv.Alpha.27 # "Adr.Straße";
  Gv.ALpha.28 # StrAdj(Adr.Plz + ' ' + Adr.Ort,_StrBegin);

  // Lieferanschrift
  Erx # RecLink(101,400,2,_RecFirst);
  if (Erx <= _rlocked) then begin
    // z.B. TKS - Düsseldorf
    Gv.Alpha.29 # Adr.A.Stichwort + ' ' + Adr.A.Ort;

    Gv.Alpha.30 # Adr.A.Anrede;
    Gv.Alpha.31 # Adr.A.Name;
    Gv.Alpha.32 # Adr.A.Zusatz;
    Gv.Alpha.33 # "Adr.A.Straße";
    Gv.ALpha.34 # StrAdj(Adr.A.Plz + ' ' + Adr.A.Ort,_StrBegin);
  end;


  Erx # RecLink(100,200,3,0) // Erzeuger holen
  if(Erx > _rLocked) then
    RecBufClear(100);

  Gv.Alpha.54 # Adr.Stichwort + ' ' + Adr.Ort;
  GV.Alpha.64 # '(' + CnvAi(Adr.LieferantenNr,_FmtNumNoGroup) + ') ' +Adr.Stichwort + ' ' + Adr.Ort;


  // Warengruppe Bezeichnung
  Gv.Alpha.45 # Wgr.Bezeichnung.L1;

  // ----------------   Betriebsauftragsdaten --------------------------------

  // Produktionsdatum / Zeit
  GV.Datum.02 # BAG.FM.Anlage.Datum;
  GV.Zeit.02  # BAG.FM.Anlage.Zeit;

  GV.Alpha.63 # BAG.F.KundenArtNr;

  // Etikettierungen
  // Markierung ohne Bezeichnung (Bezeichnung ist fest als Etikettenbezeichnung hinterlegt)
  Gv.Alpha.35 # StrAdj(BAG.F.Etk.Feld.1,_StrAll);
  Gv.Alpha.36 # StrAdj(BAG.F.Etk.Feld.2,_StrAll);
  Gv.Alpha.37 # StrAdj(BAG.F.Etk.Feld.3,_StrAll);
  Gv.Alpha.38 # StrAdj(BAG.F.Etk.Feld.4,_StrAll);
  Gv.Alpha.39 # StrAdj(BAG.F.Etk.Feld.5,_StrAll);

  Gv.Alpha.44 # BAG.FM.Waagedaten1;
  GV.Alpha.67 # BAG.FM.Waagedaten2;
  GV.Alpha.68 # BAG.FM.Waagedaten3;


  
  

  if (aKeinDruck=False) then
    Lib_Dokumente:PrintForm(Eti.Formular.Datei, Eti.Formular.Name, false,'',aKeys);


  RekRestore(vBuf100);
  RekRestore(vBuf200);
  RekRestore(vBuf400);
  RekRestore(vBuf401);
  RekRestore(vBuf700);
  RekRestore(vBuf702);
  RekRestore(vBuf703);
  RekRestore(vBuf704);
  RekRestore(vBuf707);

end; // EO Init()


//========================================================================
//  AusEtikett
//    Auswahl des Etikettentypes
//========================================================================
sub AusEtikett()
begin
  if (gSelected<>0) then begin

    if (gFile=200) then
      if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

    RecRead(840,0,_RecId,gSelected);
    gSelected # 0;
    Init(Eti.Nummer);
  end;
end; // EO AusEtikett


//========================================================================
//  AusEtikettMarkLoop
//    Auswahl des Etikettentypes
//========================================================================
sub AusEtikettMarkLoop()
local begin
  Erx       : int;
  vMarked   : int;
  vMFile    : int;
  vMID      : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(840,0,_RecId,gSelected);
    gSelected # 0;

    Lib_Dokumente:RekReadFrm(Eti.Formular.Datei, Eti.Formular.Name);
    if ("Frm.Kürzel"='METKS') then begin
      Init(Eti.Nummer);
      RETURN;
    end;

    FOR vMarked # gMarkList->CteRead(_CteFirst);
    LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
    WHILE (vMarked > 0) DO BEGIN
      Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
      if (vMFile=200) then begin
        Erx # RecRead(200, 0, _recId, vMID);
        Init(Eti.Nummer);
      end;
    END;
  end;

end; // EO AusEtikett

//========================================================================