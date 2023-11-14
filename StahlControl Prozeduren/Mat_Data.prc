@A+
//==== Business-Control ==================================================
//
//  Prozedur    Mat_Data
//                      OHNE E_R_G
//  Info
//
//
//  19.11.2003  AI  Erstellung der Prozedur
//  05.11.2010  AI  SetKommission ändert nun Status nicht immer
//  29.06.2012  AI  NEU: ClearAnalyse
//  07.08.2012  AI  "_Add2ArtCharge" setzt auch Lieferant im Letzten EK
//  30.08.2012  ST  _SetRef setzt auch Artikelnr bei Matz und 209er Auftragspod (1326/287)
//  01.10.2012  AI  "SetKommission" löscht VSBMeldung-Datum
//  25.02.2013  ST  Erweiterung der Vererbung um 2. Messung
//  10.04.2013  AI  MatMEH eingebaut
//  14.08.2013  ST  MatMeh aus Artikel wird auf kg gesetzt, wenn der Artikel nicht eglesen werden kann
//  17.09.2013  AH  "_Add2ArtCharge" setzt letzen EK nur bei Neuanlage
//  15.10.2013  AH  "_SetRef" errechnet VSBMengen win RechnungsMEH
//  29.10.2013  AH  Änderung beim "Splitten": (Projekt 1471/6) um Rundungsdifferenzen beim Dreisatz zu vermeiden, ggf. über volle Länge rechnen:
//  12.02.2014  ST  Bugfix: Vererbung der 2. Analyse auch ab 2. Rekursionsschritt (Projekt 1326/384)
//  13.02.2014  AH  Neu: "VererbeDaten" kann LfE
//  22.04.2014  AH  BubFix: "Splitten" setezt Stk nicht auf 1 wenn kein Gewicht mehr vorhanden ist
//  15.05.2014  AH  VSB-Material wird mit Auf.P.MEH.Einsatz in AufAktion geschrieben
//  26.08.2014  AH  Neu: "StatistikBuchen"
//  27.08.2014  AH  Neu: "Foreach_BestandRueckwirkend"
//  20.10.2014  AH  MatSofortInAblage
//  19.11.2014  ST  "sub Read(...)" Restore aus Ablage auch ohne Setting
//  19.11.2014  AH  "Splitten" rechnete bisher MENGE falsch (negiert)
//  27.11.2014  AH  "_Add2ArtCharge" setzt L-EK oder D-EK NIE MEHR
//  28.11.2014  AH  Meu: "SetAktuellenEKPreis"
//  16.12.2014  AH  Bugfix in "Splitten"
//  07.04.2015  AH  Auftrags-SL in Kommission aktiviert
//  16.11.2015  AH  Edit: "SetInventur" bucht Mengenänderungen
//  13.04.2016  AH  BubFix: "Vererbedaten" vererbt auch EK_PreisProMEH
//  01.08.2016  AH  "_SetRef" setzt für VSB die Rechnungsmenge richtig laut Verwiegungsart
//  22.08.2016  AH  Bug: Status "VSBKonsi" wurde nur bem Anlegen von Material nicht richtig gesetzt
//  20.10.2016  AH  VSBEK
//  25.10.2016  AH  "RapairT"
//  17.01.2017  AH  "SetInventur" setzt Lagerplatz auch im Wareneingang (Prj. 1601/65)
//  10.03.2017  AH  "SetUndVererbeEkPreis"
//  14.03.2017  AH  Fix: Tolernazen.Von/Bis werden immer errechnet beim Speichern von Material
//  28.08.2017  ST  "WebApp_WE_Werksnummer" Hinzugefügt
//  14.09.2017  AH  Fix: "SetUndVererbeEkPreiS" kann KOMBI
//  21.06.2018  AH  Fix: "copyAnalyse2Mat" zieht richtige Lyse.Pos
//  25.10.2018  ST  Neu: sub lies1zu1FMAktuell(aMat : int) : int;
//  03.12.2018  AH  Edit: "_SetRef" optional mit aVsbDatum
//  10.01.2019  AH  Vererbeanalyse kann ErweiterteAnalyse
//  26.07.2019  AH  Fix: Statistikverbuchung
//  15.01.2020  AH  Fix: KgMM nicht nullen, wenn kein Gewicht (da sonst BA-Einsatzkarten den kgmm verlieren)
//  05.02.2020  AH  Neu: Mat.Reserviert2 wird per Setting in Artikelsumme anders gerechnet
//  02.03.2021  AH  "Repair_02032021"
//  15.06.2021  ST  "SetAktuellenDurch...EK" für SLC auskommentiert  // ST 2021-06-15 2184/15
//  27.07.2021  AH  ERX
//  31.08.2021  AH  Fix "Read" für ERX
//  28.02.2022  AH  Fix "SetUndVerErbeEkPreis" vererbt auch bei eeren Aktionsterminen Prj. 2333/31
//  03.03.2022  ST  Edit:  "SetUndVerErbeEkPreis" vererbt bei auch Restkarten (ohne Datumsbezug) Prj.  2343/36
//  10.03.2022  AH  "TauscheMats"
//  30.05.2022  AH  SINGLELOCK
//  2022-07-05  AH  DEADLOCK
//  2022-10-27  AH  Neu: AFX "Mat.WirdVkVSB"
//  2023-01-21  AH  KgMehRatio
//  2023-02-27  AH  "_SetInternals" korrigiert Netto/Brutto
//  2023-03-23  AH  "SetUndVererbeEKPreis" braucht MEH, damit es MEH-Wechsel richtig vererben kann (per Ratio)
//
//  Subprozeduren
//    SUB SetUndVererbeEkPreis
//    SUB SetAktuellenEKPreis
//    SUB MengeVorlaeufig
//    SUB _SetInternals
//    SUB _SetRef
//    SUB _Add2ArtCharge
//    SUB _TauscheBmitB
//    SUB _UpdateArtikel
//    SUB CopyAF(aZielMat : int) : logic;
//    SUB Insert(aLock : int; aGrund : alpha; aErzeugrdatum : date; opt aInvDatum : date) : int;
//    SUB Replace(aLock : int; aGrund : alpha) : int;
//    SUB Delete(aLock : int; aGrund : alpha) : int;
//    SUB Read(aMatNr : int) : int;
//    SUB Splitten(aStk : int; aNetto : float; aBrutto : float; var aNeueNr : int; opt aGrund : alpha; opt aDatum :date) : logic
//    SUB ***Copy(aNeuerStamm : logic) : logic;
//    SUB SetStatus(aStatus : int);
//    SUB Bestandsbuch(aStk : int; aGew : float; aPreis : float; aBem : alpha; aDatum : date; aTyp : alpha; opt aT1 : int; opt aT2 : word; opt aT3 : word; opt aT4 : word; opt aFIX : logic);
//    SUB SetKommission(aMatNr  : int; aAufNr  : int; aAufPos : int; aAufPos2 : int; aTyp    : alpha) : logic;
//    SUB CopyAnalyse2Mat();
//    SUB VererbeDaten(aPreis : logic; aAnalyse : logic; opt aAnalyse2 : logic;) : logic;
//    SUB VererbeNeubewertung(aDiff : float; aGrund : alpha; aDat : date; aNachFix : logic) : logic;
//    SUB RecalcAll();
//    SUB SetMatStatus(aMatNr # int; aStatus : int);
//    SUB SetLoeschmarker(aLoeschmarker : alpha; opt aGrund : alpha);
//    SUB Repair_ResetLoeschdatum();
//    SUB SetInventur(aMaterial : int; aLagerplatz : alpha; aInventurDatum : date; aMitMengen : logic; aStk : int; aGew : float; aMenge : float; aFehlte : logic) : logic;
//    SUB ClearAnalyse(aZwei : logic);
//    SUB BewegungenRueckrechnen(aStichtag : date);
//    SUB Foreach_BestandRueckwirkend(aStichtag : date; aProc     : alpha) : int;
//    SUB StatistikBuchen( opt a200  : int; opt aInit : logic; opt aDel  : logic);
//    SUB RepairT();
//    SUB WebApp_WE_Werksnummer(aLieferantennr  : int; aWerksnr : alpha; aLagerplatz : alpha) : logic
//    SUB lies1zu1FMAktuell(aMat : int) : int;
//    SUB HatAnalyse(aNr : int) : logic;
//    SUB TauscheMats(aMat1 : int; aMat2 : int) : logic;
//    SUB Repair_02032021()
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen


declare SetStatus(aStatus : int);
declare Bestandsbuch(aStk : int; aGew : float; aMenge : float; aPreis : float; aPreisPM : float; aBem : alpha(100); aDatum : date; aZeit : time;aTyp : alpha; opt aT1 : int; opt aT2 : word; opt aT3 : word; opt aT4 : word; opt aFIX : logic) : logic
declare StatistikBuchen(opt a200  : int; opt aInit : logic; opt aDel : logic) : int;
declare Read(aMatNr : int; opt aLock : int; opt a200 : int; opt aRestore  : logic) : int;
declare Replace(aLock : int; aGrund : alpha) : int;

//========================================================================
//========================================================================
sub _GetKombiEkSumme(
  aMatNr        : int;
  var aWert     : float;
  var aWertMEH  : float;
//  var aGew      : float;
//  var aMenge    : float;
  ) : logic;
local begin
  Erx       : int;
  v200      : int;
  v200b     : int;
  v204      : int;
  vDatei    : int;
end;
begin
  aWert     # 0.0;
  aWertMEH  # 0.0;
//  aGew      # 0.0;
//  aMenge    # 0.0;

  v200 # RekSave(200);
  v204 # RekSave(204);

  Mat.Nummer # aMatNr;
  FOR Erx # RecLink(204,200,14,_recFirst)
  LOOP Erx # RecLink(204,200,14,_recNext)
  WHILE (Erx<_rLocked) do begin

    if (Mat.A.Aktionstyp<>c_Akt_Mat_Kombi) or (Mat.A.Entstanden<>0) then CYCLE;

    v200b # Reksave(200);
    vDatei # Read(Mat.A.Aktionsmat);  // Vorgänger holen
    if (vDatei<200) then begin
      RecBufDestroy(v200b)
      RekRestore(v200);
      RekRestore(v204);
      RETURN false;
    end;

//    aGew      # aGew + Mat.A.Gewicht;
//    aMenge    # aMenge + Mat.A.Menge;
//debugx('calc '+anum(Mat.EK.Preis,2)+'EK/t * '+anum(Mat.A.Gewicht,2)+'kg');
//debugx('calc '+anum(Mat.EK.PreisProMEH,2)+'EK/meh * '+anum(Mat.A.Menge,2)+Mat.MEH);
    aWert     # aWert + Rnd(Mat.EK.Preis * Mat.A.Gewicht / 1000.0, 2);
    aWertMEH  # aWertMEH + Rnd(Mat.EK.PreisProMEH * Mat.A.Menge, 2);
    Mat.Nummer # aMatNr;
  END;
  RekRestore(v200);
  RekRestore(v204);
  RETURN true;
end;


//========================================================================
//
//========================================================================
sub SetUndVererbeEkPreis(
  aDatei      : int;
  aDat        : date;
  aEK         : float;
  aEKpro      : float;
  aMEH        : alpha;    // 2023-03-23 AH für MEH-Wechsel
  aDiffTxt    : int;
  opt aBagTree : int;
  ) : logic;
local begin
  vMEH        : alpha;
  Erx         : int;
  v202        : int;
  vFix        : logic;
  vAltEk      : float;
  vAltEkPro   : float;
  vVon, vBis  : date;
  vDeltaEk    : float;
  vDeltaEkPro : float;
  vBuf        : int;
  vDatei      : int;
  v204        : int;
  vVkDiff     : float;

  vWert       : float;
  vWertPro    : float;
  vGew        : float;
  vMenge      : float;
  vNeuerEK    : float;
  vNeuerEKPro : float;
  vDat        : date;

  vBagTreeItem  : int;
  vBagTreeKey   : alpha;
end;
begin

  vAltEK    # FldFloat(aDatei,1,57);
  vAltEKpro # FldFloat(aDatei,1,72);
  vMEH      # FldAlpha(aDatei,1,67);

  if (aDatei<>200) and (aDatei<>210) then RETURN false;

//debug('MAT '+aint(Mat.Nummer)+' ***********************************');
  // Bestandsbuch ZURÜCKRECHNEN...
  if (aDatei=210) then RecBufCopy(210,200);

  // 2023-03-21 AH
  if (Mat.MEH<>aMEH) then begin
  // 2m, 6kg = 3Ratio
  // 5€/kg    : wieviel pro M? 5*3 = 15
//debugx('MehWechsel auf '+mat.meh);
    aEkPro # 0.0;
    if (Mat.Ratio.MEHkg<>0.0) then
      aEkPro  # aEK/1000.0 * Mat.Ratio.MehKg;
    aMEH    # '';
  end;
//debugx('set '+anum(aekpro,2));

  Mat_B_Data:EkZumDatum( aDat, var vAltEk, var vAltEkPro);

//debug('Alt: '+anum(vAltEK,2)+' @ '+cnvad(aDat));
  vDeltaEK    # aEk - vAltEK;
  vDeltaEKpro # aEkPro - vAltEKpro;
//debug('Delta: '+anum(vDeltaEK,2));

  // Bestandsbuch loopen...
  FOR Erx # RecLink(202, aDatei,12,_recFirst)
  LOOP Erx # RecLink(202, aDatei,12,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Mat.B.Datum<aDat) then CYCLE;

    // SPÄTERE Schrottnullung?
    if ((Mat.B.Bemerkung=*c_AktBem_BA_Nullung+':*')) then begin
      Erx # RecRead(202,1,_recLock);
      if (Erx=_rOK) then begin
        Mat.B.PreisW1       # -aEk;
        Mat.B.PreisW1proMEH # -aEkPro;
        Erx # RekReplace(202);
      end;
      if (Erx<>_rOK) then RETURN false;   // 2022-07-05 AH DEADLOCK
     
      // Gegenbuchungen suchen...
      v202 # RekSave(202);
      RecBufClear(202);
      "Mat.B.TrägerTyp"     # v202->"Mat.B.TrägerTyp";
      "Mat.B.TrägerNummer1" # v202->"Mat.B.TrägerNummer1";
      "Mat.B.TrägerNummer2" # v202->"Mat.B.TrägerNummer2";
      "Mat.B.TrägerNummer3" # v202->"Mat.B.TrägerNummer3";
      "Mat.B.TrägerNummer4" # v202->"Mat.B.TrägerNummer4";
      Erx # RecRead(202,3,0);
      WHILE (Erx<=_rMultikey) and
        ("Mat.B.TrägerTyp" = v202->"Mat.B.TrägerTyp") and
        ("Mat.B.TrägerNummer1" = v202->"Mat.B.TrägerNummer1") and
        ("Mat.B.TrägerNummer2" = v202->"Mat.B.TrägerNummer2") and
        ("Mat.B.TrägerNummer3" = v202->"Mat.B.TrägerNummer3") and
        ("Mat.B.TrägerNummer4" = v202->"Mat.B.TrägerNummer4") do begin
        if (Mat.B.Bemerkung='>'+v202->Mat.B.Bemerkung) then begin
          Erx # RecRead(202,1,_recSingleLock);
          if (Erx=_rOK) then begin
            Mat.B.PreisW1       # aEK;
            Mat.B.PreisW1proMEH # aEKPro;
            Erx # RekReplace(202);
          end;
          if (erx<>_rOK) then RETURN false;
        end;
        Erx # RecRead(202,3,_recNext);
      END;

      RekRestore(v202);
      RecRead(202,1,0);
      vFix # true;
      BREAK;
    end;

    if (Mat.B.FixYN) then begin
      Erx # RecRead(202,1,_recLock);
      if (Erx=_rOK) then begin
        Mat.B.PreisW1       # Mat.B.PreisW1 - vDeltaEk;
        Mat.B.PreisW1proMEH # Mat.B.PreisW1proMeh - vDeltaEkPro;
        Erx # RekReplace(202);
      end;
      if (Erx<>_rOK) then RETURN false;   // 2022-07-05 AH DEADLOCK
      vFix # true;
      BREAK;
    end;

    aEk    # aEk + Mat.B.PreisW1;
    aEkpro # aEkpro + Mat.B.PreisW1proMEH;
  END;


  // keine SPÄTEREN FEX? -> Karte ändern!
  if (vFix=false) then begin

    // Karte ändern...
    if (aDiffTxt<>0) then begin //and (Mat.VK.Rechnr<>0) then begin
      vVKDiff # Rnd((aEK * Mat.Bestand.Gew / 1000.0) - (Mat.EK.Preis * Mat.Bestand.Gew / 1000.0),2)
      TextAddLine(aDiffTxt,aint(Mat.Nummer)+'|'+anum(vVkDiff,2)+'|'+aint(Mat.VK.RechNr))
    end;

//debug('              SetEK '+anum(aEK,2));
    if (aDatei=200) then begin
      Erx # Recread(200,1,_recSingleLock);
      if (Erx=_rOK) then begin
        Mat.EK.Preis        # aEk;
        Mat.EK.PReisProMEH  # aEKpro;
        Erx # Mat_data:Replace(_recunlock,'MAN');
      end;
      if (Erx<>_rOK) then RETURN false;
    end
    else if (aDatei=210) then begin
      Erx # Recread(210,1,_recSingleLock);
      if (Erx=_rOK) then begin
        "Mat~EK.Preis"        # aEK;
        "Mat~EK.PReisProMEH"  # aEKpro;
        Erx # Mat_Abl_data:ReplaceAblage(_recunlock,'MAN');
      end;
      if (Erx<>_rOK) then RETURN false;
    end;

  end;

//  Bestandsbuch(0, 0.0, 0.0, vDeltaEK, vDeltaEKPro, aGrund, aDat, '',0,0,0,0, aFix);


  // Jetzt alle Kinderaktionen suchen und damaligen EK errechnen und vererben...
  // Alle Aktionen loopen...
  vBuf # Reksave(aDatei);
  FOR Erx # RecLink(204, vBuf, 14,_recFirst)
  LOOP Erx # RecLink(204, vBuf, 14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.A.Entstanden=0) then CYCLE;

    //  28.02.2022 AH, Proj. 2333/31
    if (Mat.A.Aktionsdatum<>0.0.0) then begin
      if (Mat.A.Aktionsdatum<aDat) AND (Mat.A.Aktionstyp <> c_Akt_BA_Rest) then
        CYCLE;

      // ST 2022-03-02 2343/36: Gewünschte "Wertanpassung" ohne Datumsbezug im BA Fall
      // !!! Achtung:  Sollte es zu einer Preisanpassung auf der Restkarte kommen, steht in der Schrottumlage
      //               noch der alte Wert. Um dies zu korrigieren muss mit dem Kunden geklärt werden, wie dieser
      //               seine Betriebsaufträge strukturiert, da verkettete Betriebsaufträge ggf. in der richtigen
      //               Reihenfolge aktuialisiert werden müssen.
      //               Gelösst als Beispiel in dern Sonderprogrammierungen zur Batch-Abwertung von Material bei HWE
      if  (aBagTree > 0) AND  ((Mat.A.Aktionstyp = c_Akt_BA_Rest) OR (Mat.A.Aktionstyp = c_Akt_BA_Fertig)) then begin
        vBagTreeKey # Aint(Mat.A.Aktionsnr) + '/' + Aint(Mat.A.Aktionspos);
        vBagTreeItem # CteRead(aBagTree,_CteFirst | _CteSearch,0,vBagTreeKey);
        if (vBagTreeItem <> 0) then
          CteDelete(aBagTree,vBagTreeItem);
        CteInsertItem(aBagTree,vBagTreeKey,0,'',_CteLast);
      end;

      vDat # Mat.A.Aktionsdatum;
    end
    else begin
      if (Mat.A.Anlage.Datum<aDat) then CYCLE;
      vDat # Mat.A.Anlage.Datum;
    end;

    // Kombination mit anderen Karten ??? ---------
    if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) then begin

      vDatei # Mat_Data:Read(Mat.A.Entstanden);
      if (vDatei<200) then begin
        RekRestore(vBuf);
        RETURN false;
      end;

      // dann EK-Preis der Kombikarte neu summieren und vererben...
      if (_GetKombiEKSumme(Mat.A.Entstanden, var vWert, var vWertPro)=false) then begin
        RekRestore(vBuf);
        RETURN false;
      end;
      Mat_B_Data:BewegungenRueckrechnen(1.1.2000, y);
      vGew    # Mat.Bestand.Gew;
      vMenge  # Mat.Bestand.Menge;
      RecBufCopy(vBuf, aDatei);

//debugx('KOMBISUMME='+anum(vWert,2)+'/t   '+anum(vWertPro,2)+'/'+Mat.MEH+'   bei KG:'+anum(vGew,0));
      vNeuerEK # Rnd(vWert / vGew * 1000.0,2);
      DivOrNull(vNeuerEKPro, vWertPro, vMenge, 2);
//debugx('neuer vKombiEK:'+anum(vNeuerEK,2));
    end
    else begin
      // Bestandsbuch ZURÜCKRECHNEN...
//      RecBufCopy(vBuf,200);
//debugx(anum(vNeuerEkPro,2));
      Mat_B_Data:EkZumDatum(vDat, var vNeuerEK, var vNeuerEkPro);
//debugx(anum(vAltEK,2)+' @ '+cnvad(aDat)+' KEY200');
    end;
//debugx(anum(vNeuerEkPro,2));
    vDatei # Mat_Data:Read(Mat.A.Entstanden);
    if (vDatei<200) then begin
      RekRestore(vBuf);
      RETURN false;
    end;
    v204 # RekSave(204);
// 2023-03-23 AH    if (SetUndVererbeEkPreis(vDatei, vDat, vNeuerEk, vNeuerEkPro, aMEH, aDiffTxt, aBagTree)=false) then begin
    if (SetUndVererbeEkPreis(vDatei, vDat, vNeuerEk, vNeuerEkPro, vMEH, aDiffTxt, aBagTree)=false) then begin
      RekRestore(vBuf);
      RekRestore(v204);
      RETURN false;
    end;
    RekRestore(v204);

    RecBufCopy(vBuf, aDatei);

  END;

  RekRestore(vBuf);


  RETURN true;
end;


//========================================================================
//  SetAktuellenEKPreis
//                  Verändert den EK-Preis unter Beachtung von "Bewertungs.Laut"
//========================================================================
sub SetAktuellenEKPreis(
  aReplace  : logic;
) : logic;
local begin
  Erx     : int;
  vMenge  : float;
  vWert   : float;
end;
begin
  // ST 2021-06-15 2184/15
  if (Set.Installname = 'SLC') then
    RETURN true;

  if (Mat.Bewertung.Laut<>'D') then RETURN true;

  if (Mat.Strukturnr='') then RETURN true;

  if (Mat.Strukturnr<>Art.Nummer) then
    Erx # RekLink(250,200,26,_recFirst);  // Artikel holen

  if (Art_P_Data:FindePreis('Ø-EK', 0, 0.0, '', 1)=false) then RETURN true;

  vMenge # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Art.MEH) ,2);
  vWert  # Rnd(Art.P.PreisW1 * vMenge / Cnvfi(Art.PEH) ,2); // Gesamtwert
//debugx('neuer EK auf Basis: '+anum(vMenge, 2)+Art.MEH+' mit Wert: '+anum(vWert,2));
  if (aReplace) then begin
    Erx # RecRead(200,1,_recSingleLock);
    if (Erx<>_rOK) then RETURN false;
  end;

  Mat.Bewertung.Laut # '';

  if (Mat.Bestand.Gew<>0.0) then
    Mat.EK.Preis # Rnd(vWert / Mat.Bestand.Gew * 1000.0 ,2);
  if (MAt.Bestand.Menge<>0.0) then
    Mat.EK.PreisProMEH # Rnd(vWert / Mat.Bestand.Menge ,2);
  Mat.EK.Effektiv       # Mat.EK.Preis + Mat.Kosten;
  Mat.EK.EffektivProME  # Mat.EK.PreisProMEH  + Mat.KostenProMEH;
  if (aReplace) then begin
    Erx # RekReplace(200,_recunlock,'AUTO');
    if (Erx<>_rOK) then RETURN false;
  end;


  RETURN true;
end;


//========================================================================
//  MengeVorlaeufig
//                  errechnet nit Mat.Menge für Module, die dieses Feld gar nicht kennen
//========================================================================
sub MengeVorlaeufig(
  aStk    : int;
  aNetto  : float;
  aBrutto : float;
) : float;
local begin
  Erx     : int;
  vMenge  : float;
end;
begin

  if (aNetto=aBrutto) then begin
    vMenge  # Rnd(Lib_Einheiten:WandleMEH(200, aStk, aNetto, aNetto, 'kg', Mat.MEH), Set.Stellen.Menge);
    RETURN vMenge;
  end;

  if (VwA.Nummer<>Mat.Verwiegungsart) then begin
    Erx # RekLink(818,200,10,_recfirst);    // Verwiegungsart holen
    if (Erx>_rLocked) then VwA.NettoYN # y;
  end;
  if (VWa.NettoYN) then
    vMenge  # Rnd(Lib_Einheiten:WandleMEH(200, aStk, aNetto, aNetto, 'kg', Mat.MEH), Set.Stellen.Menge);
  else
    vMenge  # Rnd(Lib_Einheiten:WandleMEH(200, aStk, aBrutto, aBrutto, 'kg', Mat.MEH), Set.Stellen.Menge);

  RETURN vMenge;
end;


//========================================================================
//  _SetInternals
//
//========================================================================
sub _SetInternals(aNeu : logic);
local begin
  Erx     : int;
  vA      : alpha;
  vBuf401 : int;
  vBuf411 : int;
  v250    : int;
  vX      : float;
end;
begin

  if (Mat.Dichte=0.0) then begin
    if(Wgr.Nummer<>Mat.Warengruppe) then RekLink(819,200,1,_recFirst);     // Warengruppe holen
    Mat.Dichte # Wgr.Dichte;
  end;

  //Mat.Werkstoffnr # '';
  //MQu.ErsetzenDurch     # "Mat.Güte";
  //Erx # RecRead(832,5,0);
  //IF (Erx<=_rMultikey) then Mat.Werkstoffnr # MQu.Werkstoffnr;
  MQu_Data:Autokorrektur(var "Mat.Güte");
  Mat.Werkstoffnr # MQU.Werkstoffnr;


  if (ReclinkInfo(201,200,11,_RecCount)<>0) then begin
    "Mat.AusführungOben"  # Obf_Data:BildeAFString(200,'1');
    "Mat.AusführungUnten" # Obf_Data:BildeAFString(200,'2');
  end;
// 14.03.2017 AH  if (Mat.DickenTolYN) then begin
//  if (Mat.Dicke<>0.0) then begin
  "Mat.Dickentol" # StrCut(Lib_Berechnungen:Toleranzkorrektur("Mat.Dickentol",Set.Stellen.Dicke),1,16);
  Lib_Berechnungen:ToleranzZuWerten("Mat.Dickentol",var Mat.DickenTol.Von, var Mat.DickenTol.Bis);
  "Mat.DickenTol.Von" # "Mat.DickenTol.Von" + "Mat.Dicke";
  "Mat.DickenTol.Bis" # "Mat.DickenTol.Bis" + "Mat.Dicke";

//14.03.2017 AH  if (Mat.BreitenTolYN) then begin
//  if (Mat.Breite<>0.0) then begin
  "Mat.Breitentol" # StrCut(Lib_Berechnungen:Toleranzkorrektur("Mat.Breitentol",Set.Stellen.Breite),1,16);
  Lib_Berechnungen:ToleranzZuWerten("Mat.Breitentol",var Mat.BreitenTol.Von, var Mat.BreitenTol.Bis);
  "Mat.BreitenTol.Von" # "Mat.BreitenTol.Von" + "Mat.Breite";
  "Mat.BreitenTol.Bis" # "Mat.BreitenTol.Bis" + "Mat.Breite";


//14.03.2017 AH  if ("Mat.LängenTolYN") then begin
//    if ("Mat.Länge"<>0.0) then begin
  "Mat.Längentol" # StrCut(Lib_Berechnungen:Toleranzkorrektur("Mat.Längentol","Set.Stellen.Länge"),1,16);
  Lib_Berechnungen:ToleranzZuWerten("Mat.Längentol",var "Mat.LängenTol.Von", var "Mat.LängenTol.Bis");
  "Mat.LängenTol.Von" # "Mat.LängenTol.Von" + "Mat.Länge";
  "Mat.LängenTol.Bis" # "Mat.LängenTol.Bis" + "Mat.Länge";

  Mat.Gewicht.Brutto # Rnd(Mat.Gewicht.Brutto, Set.Stellen.Gewicht);
  Mat.Gewicht.Netto  # Rnd(Mat.Gewicht.Netto, Set.Stellen.GEwicht);
  Mat.Bestand.Gew    # Rnd(Mat.Bestand.Gew, Set.Stellen.Gewicht);
  Mat.Reserviert.Gew # Rnd(Mat.Reserviert.Gew, Set.Stellen.Gewicht);
  Mat.Reserviert2.Gew # Rnd(Mat.Reserviert2.Gew, Set.Stellen.Gewicht);
  Mat.Bestellt.Gew   # Rnd(Mat.Bestellt.Gew, Set.Stellen.Gewicht);


  // Verwiegungsart holen
//  IMMER die 1. holen, wenn nix vorhanden
  Erx # RecLink(818, 200, 10,_recFirst);//<=_rLocked) then begin
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  if (VWa.NettoYN) then begin
    if (Mat.Bestand.Gew>0.0) then
      Mat.Gewicht.Netto # Mat.Bestand.Gew
    else
      Mat.Bestand.Gew   # Mat.Gewicht.Netto;
    // 2023-02-27 AH
    if (Mat.Gewicht.Brutto<>0.0) then
      Mat.Gewicht.Brutto # Max(Mat.Gewicht.Brutto, Mat.Gewicht.Netto);
  end
  else begin  // Bruttokarte
    if (Mat.Bestand.Gew>0.0) then
      Mat.Gewicht.Brutto  # Mat.Bestand.Gew
    else
      Mat.Bestand.Gew     # Mat.Gewicht.Brutto;
    // 2023-02-27 AH
    if (Mat.Gewicht.Netto<>0.0) then
      Mat.Gewicht.Netto # Min(Mat.Gewicht.Brutto, Mat.Gewicht.Netto);
  end;

  // 10.04.2013:
  if (Mat.MEH='') then begin
    Mat.MEH # 'kg';
    if (Wgr.Nummer<>Mat.Warengruppe) then RekLink(819, 200, 1, _recfirst);     // Wgr holen
    if (Wgr_Data:IstMix()) then begin
      RekLinkB(v250, 200, 26, _recfirst);  // Artikel holen
      Mat.MEH # v250->Art.MEH;
      RecBufDestroy(v250);

      // ST 2013-08-14: Sollte auch der Artikel keine Mengeneinheit halten (oder
      //                der Artikel nicht gefunden werden) dann MEH auf kg stellen.
      if (Mat.MEH = '') then
        Mat.MEH # 'kg';

     end;
  end;
  if (Mat.MEH='kg') then  begin
    Mat.Bestand.Menge     # Mat.Bestand.Gew;
    Mat.Bestellt.Menge    # Mat.Bestellt.Gew;
    Mat.Reserviert.Menge  # Mat.Reserviert.Gew;
  end
  else if (Mat.MEH='Stk') then begin
    Mat.Bestand.Menge     # cnvfi(Mat.Bestand.Stk);
    Mat.Bestellt.Menge    # cnvfi(Mat.Bestellt.Stk);
    Mat.Reserviert.Menge  # cnvfi(Mat.Reserviert.Stk);
  end
  else if (Mat.MEH='t') then begin
    Mat.Bestand.Menge     # Mat.Bestand.Gew / 1000.0;
    Mat.Bestellt.Menge    # Mat.Bestellt.Gew / 1000.0;
    Mat.Reserviert.Menge  # Mat.Reserviert.Gew / 1000.0;
  end
  else begin
    if (Mat.Bestand.Menge=0.0) then begin
      Mat.Bestand.Menge     # Rnd( Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Gew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
    end;

    if (Mat.Bestellt.Menge=0.0) then begin
      Mat.Bestellt.Menge    # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestellt.Stk, Mat.Bestellt.Gew, Mat.Bestellt.Gew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
      // 24.11.2014
      if (Mat.Bestellt.Menge=0.0) and (Mat.Strukturnr<>'') then begin
        Erx # RekLink(250, 200, 26, _recfirst);  // Artikel holen
        if (Erx<=_rLocked) then begin
          Mat.Bestellt.Menge  # Rnd(Lib_Einheiten:WandleMEH(250, Mat.Bestellt.Stk, Mat.Bestellt.Gew, Mat.Bestellt.Gew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
        end;
      end;
    end;

    if (Mat.Reserviert.Menge=0.0) then
      Mat.Reserviert.Menge  # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Reserviert.Stk, Mat.Reserviert.Gew, Mat.Reserviert.Gew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
  end;


  Mat.Bestand.Menge     # Rnd(Mat.Bestand.Menge, Set.Stellen.Menge);
  Mat.Bestellt.Menge    # Rnd(Mat.Bestellt.Menge, Set.Stellen.Menge);
  Mat.Reserviert.Menge  # Rnd(Mat.Reserviert.Menge, Set.Stellen.Menge);
//debugX('KEY200 '+anum(Mat.EK.PreisProMEH,2));
  if (Mat.EK.PreisProMEH=0.0) and (Mat.Bestand.Menge + Mat.Bestellt.Menge<>0.0) then begin
    vX # Mat.EK.preis * (Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0;
//debugx(anum(Mat.EK.preis,2) +' * '+anum((Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0,2));
//debugx(anum(vX,2)+' / '+anum((Mat.Bestand.Menge + Mat.Bestellt.Menge),2));
    Mat.EK.PreisProMEH # Rnd(vX / (Mat.Bestand.Menge + Mat.Bestellt.Menge),2);
//debugX('KEY200 '+anum(Mat.EK.PreisProMEH,2));
  end;
  if (Mat.KostenProMEH=0.0) and (Mat.Bestand.Menge + Mat.Bestellt.Menge<>0.0) then begin
    vX # Mat.Kosten * (Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0;
    Mat.KostenproMEH # Rnd(vX / (Mat.Bestand.Menge + Mat.Bestellt.Menge),2);
//debugX('KEY200 '+anum(Mat.EK.PreisProMEH,2));
  end;
//debugX('KEY200 '+anum(Mat.EK.PreisProMEH,2));

/*** Preis/T ist VORLÄUFIG Leitbetrag
  if (Mat.EK.Preis=0.0) and (Mat.EK.PreisProMEH<>0.0) and (Mat.Bestand.Gew + Mat.Bestellt.Gew<>0.0) then begin
    vX # Mat.EK.preisProMEH * (Mat.Bestand.Menge + Mat.Bestellt.Menge);
    Mat.EK.Preis # Rnd(vX / (Mat.Bestand.Gew + Mat.Bestellt.Gew) * 1000.0 ,2);
  end;
  if (Mat.Kosten=0.0) and (Mat.KostenProMEH<>0.0) and (Mat.Bestand.Gew + Mat.Bestellt.Gew<>0.0) then begin
    vX # Mat.KostenProMEH * (Mat.Bestand.Menge + Mat.Bestellt.Menge);
    Mat.Kosten # Rnd(vX / (Mat.Bestand.Gew + Mat.Bestellt.Gew) * 1000.0 ,2);
  end;
***/

  // Reservierungen vorhanden?
  if (ReclinkInfo(203,200,13,_RecCount)=0) then begin
    Mat.Reserviert.Stk    # 0;
    Mat.Reserviert.Gew    # 0.0;
    Mat.Reserviert2.Stk   # 0;
    Mat.Reserviert2.Gew   # 0.0;
    Mat.Reserviert.Menge  # 0.0;
    Mat.Reserviert2.Meng  # 0.0;
  end;

  "Mat.Verfügbar.Stk"   # Mat.Bestand.Stk + Mat.Bestellt.Stk - Mat.Reserviert.Stk;
  "Mat.Verfügbar.Gew"   # Mat.Bestand.Gew + Mat.Bestellt.Gew - Mat.Reserviert.Gew;
  "Mat.Verfügbar.Menge" # Mat.Bestand.Menge + Mat.Bestellt.Menge - Mat.Reserviert.Menge;

  Mat.EK.Effektiv       # Mat.EK.Preis + Mat.Kosten;
  Mat.EK.EffektivProME  # Mat.EK.PreisProMEH  + Mat.KostenProMEH;

  if (Mat.Kommission='') and (Mat.Auftragsnr<>0) then begin
    Mat.Kommission # AInt(Mat.Auftragsnr)+'/'+AInt(Mat.AuftragsPos);
    if (Mat.Auftragspos2<>0) then
      Mat.Kommission # Mat.Kommission + '/' + AInt(Mat.AuftragsPos2);
  end
  else if (Mat.Kommission<>'') and (Mat.Auftragsnr=0) then begin
    try begin   // 03.12.2020 AH
      ErrTryCatch(_ErrCnv,y);
      ErrTryCatch(_ErrValueOverflow,y);
      vA # Str_Token(Mat.Kommission,'/',1);
      Mat.AuftragsNr # CnvIa(vA);
      vA # Str_Token(Mat.Kommission,'/',2);
      Mat.AuftragsPos # CnviA(vA);
      vA # Str_Token(Mat.Kommission,'/',3);
      Mat.AuftragsPos2 # CnviA(vA);
    end;
    ErrSet(_errOK);
  end;
  if (Mat.Auftragsnr<>0) then begin
    vBuf401 # RecBufCreate(401);
    Erx # RecLink(vBuf401,200,16,_RecFirst);      // Auftrag holen
    if (Erx<=_rLocked) then begin
      Mat.KommKundennr # vBuf401->Auf.P.Kundennr;
    end
    else begin
      vBuf411 # RecBufCreate(411);
      Erx # RecLink(vBuf411,200,17,_RecFirst);      // ~Auftrag holen
      if (Erx<=_rLocked) then begin
        Mat.KommKundennr # vBuf411->"Auf~P.Kundennr";
      end
      else begin
        Mat.KommKundennr # 0;
      end;
      RecBufDestroy(vBuf411);
    end;
    RecBufDestroy(vBuf401);
  end;

  Mat.KommKundenSWort # '';
  if (Mat.KommKundennr<>0) then begin
    Erx # RecLink(100,200,7,0);
    if (Erx<=_rLocked) then Mat.KommKundenSWort # Adr.Stichwort
  end;

  Mat.LieferStichwort # '';
  if (Mat.Lieferant<>0) then begin
    Erx # RecLink(100,200,4,0);
    if (Erx<=_rLocked) then Mat.LieferStichwort # Adr.Stichwort;
  end;

  Mat.LagerStichwort # '';
  if (Mat.Lageranschrift<>0) then begin
    Erx # RecLink(101,200,6,0);
    if (Erx<=_rLocked) then Mat.LagerStichwort # Adr.A.Stichwort;
  end;
  if (Mat.LagerStichwort='') and (Mat.Lageradresse<>0) then begin
    Erx # RecLink(100,200,5,0);
    if (Erx<=_rLocked) then Mat.LagerStichwort # Adr.Stichwort;
  end;

  Mat.Einkaufsnr    # 0;
  Mat.Einkaufspos   # 0;
  if (Mat.Bestellnummer<>'') and (StrFind(Mat.Bestellnummer,'/',0)<>0) then begin
    try begin   // 03.12.2020 AH
      ErrTryCatch(_ErrCnv,y);
      ErrTryCatch(_ErrValueOverflow,y);
      vA # Str_Token(Mat.Bestellnummer,'/',1);
      Mat.Einkaufsnr  # cnvIA(vA);
      vA # Str_Token(Mat.Bestellnummer,'/',2);
      Mat.Einkaufspos # cnvIA(vA);
    end;
    ErrSet(_errOK);
  end;

  if (Mat.Bestand.Gew+Mat.Bestellt.Gew<>0.0) then begin // 15.01.2020
    Mat.KgMM # 0.0;
    if (Wgr.Nummer<>Mat.Warengruppe) then RekLink(819, 200, 1, _recfirst);     // Wgr holen

    // Profil/Rohr(Stab
    if (Wgr.Materialtyp=c_WGRTyp_Profil) or (Wgr.Materialtyp=c_WGRTyp_Rohr) or (Wgr.Materialtyp=c_WGRTyp_Stab) then begin
      // 2022-11-30 AH Fix DIV statt MAL
      if (Mat.MEH='m') then
        DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), (Mat.Bestand.Menge + Mat.Bestellt.Menge) / 1000.0, 5)
      else if (Mat.MEH='dm') then
        DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), (Mat.Bestand.Menge + Mat.Bestellt.Menge) / 100.0, 5)
      else if (Mat.MEH='cm') then
        DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), (Mat.Bestand.Menge + Mat.Bestellt.Menge) / 10.0, 5)
      else if (Mat.MEH='mm') then
        DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), (Mat.Bestand.Menge + Mat.Bestellt.Menge), 5);
      else begin
        DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), ("Mat.Länge" * cnvfi(Mat.Bestand.Stk+Mat.Bestellt.Stk) ), 5)
      end;
    end
    else begin  // Material
      If (Mat.Breite<>0.0) and (Mat.Bestand.Stk+Mat.Bestellt.Stk<>0) then
        Mat.KgMM # Rnd( (Mat.Bestand.Gew+Mat.Bestellt.Gew) / CnvFI(Mat.Bestand.Stk+Mat.Bestellt.Stk) / Mat.Breite, 5);
      If (Mat.Breite<>0.0) and (Mat.Bestand.Stk+Mat.Bestellt.Stk=0) then
        Mat.KgMM # Rnd( (Mat.Bestand.Gew+Mat.Bestellt.Gew) / Mat.Breite, 5);
    end;
  end;
  
  
  // 2023-01-21 AH : RATIO
  if (aNeu) or (Mat.Ratio.MEHKG=0.0) then begin
    DivOrNull(Mat.Ratio.MehKG, (Mat.Bestellt.Gew+Mat.Bestand.Gew), (Mat.Bestellt.Menge+Mat.Bestand.Menge), 5);    // Ratio: 4000kg/4m = 1000   Kosten: 2000/t = 2/kg * 1000ratio = 2000/m
    if (Mat.Ratio.MehKG=0.0) then Mat.Ratio.MehKG # 1.0; // 2023-04-19  AH Wareneingang auf VSB wenn Bestellkarte schon genullt
//debugx('NEW RATIO!');
  end
  else if (Mat.Ratio.MehKG<>0.0) then begin
    Mat.KostenProMEH  # Rnd(Mat.Kosten / 1000.0 * Mat.Ratio.MehKG,2);
  end;

  if (aNeu) then
    RunAFX('Mat.RecSave','NEW')
  else
    RunAFX('Mat.RecSave','EDIT');

end;


//========================================================================
//========================================================================
sub IstVSBStatus(aStatus : int) : logic
begin
  RETURN ((aStatus=c_status_Frei) or (aStatus=c_Status_inVLDAW) or
    (aStatus=c_Status_VSB) or (aStatus=c_Status_VSBKonsi) or
    (aStatus=c_Status_VSBPuffer) or (aStatus=c_Status_VSBRahmen) or
    (aStatus=c_Status_VSBKonsiRahmen) or (Mat.Status=c_Status_Versand) or
    (aStatus=c_Status_EKVSB) or (aStatus=c_Status_EKWE));
end;


//========================================================================
//  _SetRef
//
//========================================================================
sub _SetRef(
  var aWirdVkVsb  : logic;    // 2022-12-20 AH
  opt aVsbDat     : date) : int;
local begin
  Erx       : int;
  vBuf401   : int;
  vBuf404   : int;
  vAlt404   : int;
  vDatei    : int;
  vOK       : logic;
end;
begin

  // VSB-Kommission ggf. anpassen?
//  if (gFile<>4444401) and ("Mat.Löschmarker"='')then begin
  if (gFile<>404) then begin

    vBuf401 # RekSave(401);
    vBuf404 # RekSave(404);

    vAlt404 # RecBufCreate(404);

    TRANSON;

    // BISHERIGE VSB-AKTIONEN ENTFERNEN ***************
    Erx # RecLink(404,200,24,_recFirst);
    WHILE (Erx<=_rMultikey) do begin  // Auf.Aktionen loopen
      if ((Auf.A.Aktionstyp<>c_Akt_VSB) and (Auf.A.Aktionstyp<>c_Akt_VsbPool) and (Auf.A.Aktionstyp<>c_Akt_VSBEK)) or (Auf.A.Rechnungsnr<>0) then begin
        Erx # RecLink(404,200,24,_recNext);
        CYCLE;
      end;

      Erx # RecLink(401,404,1,_recFirst); // AufPos. holen
      if (Erx<=_rLocked) then begin
/*
        Erx # RecLink(411,404,7,_recFirst); // ~AufPos. holen
        if (Erx<>_rOK) then begin
          TRANSBRK;
          RecBufDestroy(vAlt404);
          RekRestore(vBuf401);
          RekRestore(vBuf404);
          Erx # _rNoRec;
          RETURN;
        end;
        RecBufCopy(401,411);
      end;
*/
        // VSB bei diesem Auftrag?? - JA : Satz merken
        if (Auf.A.Nummer=Mat.Auftragsnr) and (Auf.A.Position=Mat.AuftragsPos) and (Auf.A.Position2=Mat.AuftragsPos2) and
          (vAlt404->Auf.A.Aktion=0) then
          RecBufCopy(404,vAlt404);

//debugx(aint(mat.nummer)+' vor del:'+aint(Recinfo(404,_reccount)));
        // alle VSBs erstmal löschen
        if (Auf_A_Data:Entfernen(n)=false) then begin
          TRANSBRK;
          RecBufDestroy(vAlt404);
          RekRestore(vBuf401);
          RekRestore(vBuf404);
          Erx # _rNoRec;
          Erg # Erx;    // TODOERX
          RETURN Erx;
        end;
//debugx(aint(mat.nummer)+' nach del:'+aint(Recinfo(404,_reccount)));

        Erx # RecLink(404,200,24,0);
        Erx # RecLink(404,200,24,0);
      end   // auf ok
      else begin
        Erx # RecLink(404,200,24,_recNext);
      end;
    END;


    // neue Aktion anlegen?
    if (Mat.Auftragsnr<>0) and ("Mat.Löschmarker"='') and (IstVSBStatus(Mat.Status)) then begin
    //=c_status_Frei) or (Mat.Status=c_Status_inVLDAW) or
    //    (Mat.Status=c_Status_VSB) or (Mat.Status=c_Status_VSBKonsi) or
    //    (Mat.Status=c_Status_VSBPuffer) or (Mat.Status=c_Status_VSBRahmen) or
    //    (Mat.Status=c_Status_VSBKonsiRahmen) or
    //    (Mat.Status=c_Status_EKVSB) or (Mat.Status=c_Status_EKWE)) then begin

      vDatei # Auf_Data:Read(Mat.Auftragsnr,Mat.Auftragspos,n);
//      Erx # RecLink(401,200,16,_recFirst);    // Aufpos holen
//      if (Erx<>_rOK) then begin
      if (vDatei<400) then begin
        TRANSBRK;
        RecBufDestroy(vAlt404);
        RekRestore(vBuf401);
        RekRestore(vBuf404);
        Erx # _rNoRec;
        Erg # Erx;    // TODOERX
        RETURN Erx;
      end;

      if (Mat.Auftragspos2<>0) then begin
        Auf.SL.Nummer   # Mat.Auftragsnr;
        Auf.SL.Position # Mat.Auftragspos;
        Auf.SL.lfdNr    # Mat.AuftragsPos2;
        Erx # RecRead(409,1,0);
        if (Erx<>_rOK)  then RecBufClear(409);
      end;


      // VSB-Aktion anlegen
      RecbufClear(404);
      Auf.A.MaterialNr    # Mat.Nummer;
      if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then  // ggf. Artikelnummer für 209er übernehmen
        Auf.A.ArtikelNr # Mat.Strukturnr;

      Auf.A.TheorieYN     # n;
      Auf.A.Aktionsnr     # Auf.P.Nummer;
      Auf.A.AktionsPos    # Auf.P.Position;
      Auf.A.AktionsPos2   # Mat.Auftragspos2;
      //Erx # RecLink(100,200,7,_recFirst);     // Kommissionskunde holen
      //If (Erx>_rLockeD) then RecBufClear(100);
      //Aufx.A.Adressnummer  # Adr.Nummer;
      Auf.A.Dicke         # Mat.Dicke;
      Auf.A.Breite        # Mat.Breite;
      "Auf.A.Länge"       # "Mat.Länge";


// 15.05.2014      Auf.A.MEH           # 'kg';
//      Auf.A.Menge         # "Mat.Verfügbar.Gew";//Mat.Bestand.Gew;
      Auf.A.MEH           # Auf.P.MEH.Einsatz;
      Auf.A.MEH.Preis     # Auf.P.MEH.Preis;

      // Mengen transferieren
      if (Lib_Einheiten:TransferMengen('200>404,VSB')=false) then begin
        TRANSBRK;
        RecBufDestroy(vAlt404);
        RekRestore(vBuf401);
        RekRestore(vBuf404);
        Erx # _rNoRec;
        Erg # Erx;    // TODOERX
        RETURN Erx;
      end;

/***
      "Auf.A.Stückzahl"   # Mat.Bestand.Stk;//"Mat.Verfügbar.Stk";//Mat.Bestand.Stk;
      Auf.A.Gewicht       # Mat.Bestand.Gew;//"Mat.Verfügbar.Gew";//Mat.Bestand.Gew;
      Auf.A.Nettogewicht  # Mat.Gewicht.Netto;
      if (Auf.A.Nettogewicht=0.0) then
        Auf.A.Nettogewicht  # Auf.A.Gewicht;
      // Umrechnen in Berechnungseinheit
      // 15.10.2013 AH
//      Auf.A.Menge.Preis   # Rnd(Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis) ,2);
      Auf.A.Menge.Preis   # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Auf.A.MEH.Preis) ,2);

      // 15.05.2014
      // Umrechnen in Auftragseinheit...
      Auf.A.Menge         # Lib_Einheiten:WandleMEH(200, "Mat.Bestand.Stk", "Mat.Bestand.Gew", "Mat.Bestand.Menge", Mat.MEH, Auf.A.MEH);
***/


      //Auf.A.EKPreisSummeW1  # Rnd(Mat.EK.effektiv * Auf.A.Gewicht / 1000.0,2);
      Auf.A.EKPreisSummeW1    # Rnd(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0,2);
      Auf.A.InterneKostw1   # Rnd(Mat.Kosten * Auf.A.Gewicht/ 1000.0,2);
      // Umrechnen in Berechnungseinheit

      // 15.10.2013 AH
//      Auf.A.Menge.Preis   # Rnd(Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Menge, Auf.A.MEH, Auf.A.MEH.Preis) ,2);
// 01.08.2016 AH schon in der "Transfermengen"
//Auf.A.Menge.Preis   # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Auf.A.MEH.Preis) ,2);

      if (Mat.Status=c_Status_EKVSB) then begin
        Auf.A.AktionsTyp    # c_Akt_VSBEK;
        Auf.A.Bemerkung     # c_AktBem_VSBEK;
      end if (Mat.Status=c_Status_Versand) then begin
        Auf.A.AktionsTyp    # c_Akt_VsbPool;
        Auf.A.Bemerkung     # c_AktBem_VsbPool;
      end
      else begin
        Auf.A.AktionsTyp    # c_Akt_VSB;
        Auf.A.Bemerkung     # c_AktBem_VSB;
      end;
      // 03.12.2018
      if (aVsbDat=0.0.0) then aVsbDat # today;
      Auf.A.AktionsDatum  # aVsbDat;
      Auf.A.TerminStart   # Auf.A.Aktionsdatum;
      Auf.A.TerminEnde    # Auf.A.Aktionsdatum;
//debugx(anum(auf.a.gewicht,2)+' ' +anum(auf.a.nettogewicht,2));
      // 27.11.2014
      if (Mat.Bewertung.Laut='D') then SetAktuellenEKPreis(false);

      // ggf. vorhandene Daten übernehmen
      if (vAlt404->Auf.A.Aktion<>0) then begin
        Auf.A.Aktion # vAlt404->Auf.A.Aktion;

        if (vDatei=401) then begin
//debugx(aint(mat.nummer)+' vor neu:'+aint(Recinfo(404,_reccount)));
          if (Auf_A_Data:NeuAnlegen(Y, (Auf.A.AktionsPos2<>0))<>_rOK) then begin
            TRANSBRK;
            RecBufDestroy(vAlt404);
            RekRestore(vBuf401);
            RekRestore(vBuf404);
            Erx # _rNoRec;
            Erg # Erx;    // TODOERX
            RETURN Erx;
          end;
        end
        else begin
        end;

        Erx # RecRead(404,1,_recLock);
        if (erx=_rOK) then begin
          Auf.A.Anlage.Datum # vAlt404->Auf.A.Anlage.Datum;
          Auf.A.Anlage.Zeit  # vAlt404->Auf.A.Anlage.Zeit;
          Auf.A.Anlage.User  # vAlt404->Auf.A.Anlage.User;
          Erx # RekReplace(404,_recUnlock,'AUTO');
        end;
        if (Erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
          Erx # Erx;    // TODOERX
          RETURN Erx;
        end;
      end
      else begin  // komplett neu anlegen !
//debugx(aint(mat.nummer)+' vor neu:'+aint(Recinfo(404,_reccount)));
        if (Auf_A_Data:NeuAnlegen(n,(Auf.A.Aktionspos2<>0))<>_rOK) then begin
          TRANSBRK;
          RecBufDestroy(vAlt404);
          RekRestore(vBuf401);
          RekRestore(vBuf404);
          Erx # _rNoRec;
          Erg # Erx;    // TODOERX
          RETURN Erx;
        end;
        aWirdVkVsb # true;
//        RunAFX('Mat.WirdVkVSB','');   // 2022-10-27 AH Proj. 2228/160 2022-12-20  AH wird "outer" aufgerufen
      end;
//debugx(aint(mat.nummer)+' nach neu:'+aint(Recinfo(404,_reccount)));


// 22.08.2016
      if (Mat.Status<=c_Status_bisFrei) or (Mat.Status=c_Status_VSB) or (Mat.Status=c_Status_VSBKonsi) or
        (Mat.Status=c_Status_VSBPuffer) or (Mat.Status=c_Status_VSBRahmen) or (Mat.Status=c_Status_VSBKonsiRahmen) then begin
        Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
        if (Erx>_rLocked) then RecBufClear(835);
        if (AAr.KonsiYN=n) then begin
          Erx # RecLink(400,401,3,_recFirst);   // AufKopf holen
          if (Auf.PAbrufYN) then
            SetStatus(c_Status_VSBPuffer)
          else if (Auf.LiefervertragYN) then
            SetStatus(c_Status_VSBRahmen)
          else
            SetStatus(c_Status_VSB);
        end
        else begin
          Erx # RecLink(400,401,3,_recFirst);   // AufKopf holen
          if (Auf.LiefervertragYN) then
            SetStatus(c_Status_VSBKonsiRahmen)
          else
            SetStatus(c_Status_VSBKonsi);
        end;
      end;

    end;  // neue Aktion anlegen


    TRANSOFF;

    RecBufDestroy(vAlt404);
    RekRestore(vBuf401);
    RekRestore(vBuf404);

  end;  // VSB-Aktionen

//debugx(aint(mat.nummer)+' ende:'+aint(Recinfo(404,_reccount)));

  Erx # _rOK;
  Erg # Erx;    // TODOERX
  RETURN Erx;
end;


//========================================================================
//  _Add2ArtCharge
//
//========================================================================
sub _Add2ArtCharge(
  aMengeIst   : float;
  aMengeBest  : float;
  aMengeRes   : float;
  aMengeKom   : float;  // 04.02.2020
  aStkIst     : int;
  aStkBest    : int;
  aStkRes     : int;
  aStkKom     : int;    // 04.02.2020
  aPreis      : float;
  aStatus     : int;
) : int;
local begin
  Erx       : int;
  vWert     : float;
  vBuf501   : int;
  v100      : int;
  vM        : float;
  vStk      : int;
end;
begin

  // Artikel-Summen-Charge lesen + sperren
  RecBufClear(252);
  Art.C.ArtikelNr   # Art.Nummer;
  Art_Data:OpenCharge(y);


  // 07.10.2021 AH: NEU passend zum Mat.Status........
  // Status holen...
  if (aStatus<>Mat.Sta.Nummer) then begin   // 2022-07-06 AH : fix, war "Mat.Status"
    Mat.Sta.Nummer # aStatus;
    RecRead(820,1,0);
  end;
  vM    # aMengeIst + aMengeBest;
  vStk  # aStkIst + aStkBest;
  if (Mat.Sta.ArtSumFormel=*'*IST0*') then begin
    Art.C.Bestand         # Art.C.Bestand +vM;
    Art.C.Bestand.Stk     # Art.C.Bestand.Stk + vStk;
  end;
  if (Mat.Sta.ArtSumFormel=*'*BEST*') then begin
    Art.C.Bestellt        # Art.C.Bestellt + vM;
    Art.C.Bestellt.Stk    # Art.C.Bestellt.Stk + vStk;
  end;
  if (Mat.Sta.ArtSumFormel=*'*VERF*') then begin
    "Art.C.Verfügbar"     # "Art.C.Verfügbar" + vM;
    "Art.C.Verfügbar.Stk" # "Art.C.Verfügbar.Stk" + vStk;
  end;
  if (Mat.Sta.ArtSumFormel=*'*SUM1*') then begin
    Art.C.Frei1           # Art.C.Frei1 + vM;
    Art.C.Frei1.Stk       # Art.C.Frei1.Stk + vStk;
  end;
  if (Mat.Sta.ArtSumFormel=*'*SUM2*') then begin
    Art.C.Frei2           # Art.C.Frei2 + vM;
    Art.C.Frei2.Stk       # Art.C.Frei2.Stk + vStk;
  end;
  if (Mat.Sta.ArtSumFormel=*'*SUM3*') then begin
    Art.C.Frei3           # Art.C.Frei3 + vM;
    Art.C.Frei3.Stk       # Art.C.Frei3.Stk + vStk;
  end;
  if (Mat.Sta.ArtSumFormel=*'*RES*') then begin
    Art.C.Reserviert      # Art.C.Reserviert + vM;
    Art.C.Reserviert.Stk  # Art.C.Reserviert.Stk + vStk;
  end;
  Art.C.Reserviert      # Art.C.Reserviert + aMengeRes;
  Art.C.Reserviert.Stk  # Art.C.Reserviert.Stk + aStkRes;
//  if (Mat.Sta.ArtSumFormel=*'*KOMM*') then begin
//    if (vM>0.0) then begin
//      Art.C.Kommissioniert  # Art.C.Kommissioniert + vM;
//      Art.C.Kommission.Stk  # Art.C.Kommission.Stk + vStk;
//    end
//    else begin
  Art.C.Kommissioniert  # Art.C.Kommissioniert + aMengeKom;
  Art.C.Kommission.Stk  # Art.C.Kommission.Stk + aStkKom;
//    end;
//  end;

  Erx # Art_Data:WriteCharge(n,'',y);
//  if (Art.Nummer='COILS') then
//  debug('KEY200 Ist'+anum(art.c.bestand,0)+' Best'+anum(art.c.bestellt,0)+' Res'+anum(Art.C.Reserviert,0)+' Kom'+anum(Art.C.Kommissioniert,0));
//      if (Erx<>_rOk) then Msg(0,'Artikelsumme nicht angelegt!',0,0,0);
  Erg # Erx;  // TODOERX
  RETURN Erx;

/******************* ALT

//debugx('KEY200 Ist='+aNum(aMengeIst,2)+' Best='+anum(aMengeBest,2)+' Res='+anum(aMengeRes,2)+' Kom='+anum(aMengeKom,2));
  // Artikel-Summen-Charge lesen + sperren
  RecBufClear(252);
  Art.C.ArtikelNr   # Art.Nummer;
  Art_Data:OpenCharge(y);
//todo('add '+aint(mat.nummer)+' '+anum(aMengeist,0));
//if (amengeist>0.0) then
//return _rok;

  // NUR Zugänge MIT Preis in den Preis einrechnen
/*** 27.11.2014 AH
  if (aMengeIst>0.0) and (aPreis<>0.0) and (Art.C.Bestand + aMengeIst<>0.0) then begin
/*
    if (Mat.Einkaufsnr<>0) then begin
      RecBufCreate(501);
      vBuf501->Ein.P.Nummer # Mat.Einkaufsnr;
      vBuf501->Ein.P.Position # Mat.EinkaufsPos;
      Erx # RecRead(vBuf501,1,0);
      if (Erx<=_rLocked) then begin
        Erx # RecLink(835,vBuf501,5,
      end;
    end;
*/
    if (vBuf501=0) then begin
//debug('Preis:'+cnvaf(aPreis)+ '   DS:'+cnvaf(art.c.EKDurchschnitt)+'   ist:'+cnvaf(art.c.bestand)+'   +:'+cnvaf(aMengeIst));
      vWert # (Art.C.EKDurchschnitt * (Art.C.Bestand / CnvFI(Art.PEH)));
      vWert # vWert + (aPreis * (aMengeIst / CnvFI(Art.PEH)))
      Art.C.EKDurchschnitt # vWert / (Art.C.Bestand + aMengeIst) * CnvFI(Art.PEH);
      Art.C.EKLetzter # aPreis;
      // Preise updaten
      Art_P_Data:SetzePreis('Ø-EK', Art.C.EKDurchschnitt, 0);
      v100 # RecbufCreate(100);
      Erx # RecLink(v100,200,4,_recfirst);     // Lieferant holen
      if (Erx>_rLocked) then RecbufClear(v100);
      if (Mode=c_ModeNew) then begin    // neu bei Neuanlge!!! 17.09.2013 AH
        Art_P_Data:SetzePreis('L-EK', Art.C.EKLetzter, v100->Adr.Nummer);  // mit Lieferant am 07.08.2012 AI
      end;
      RecBufDestroy(v100);
    end
    else begin
      RecBufDestroy(vBuf501);
      vBuf501 # 0;
    end;
//debug('dann DS:'+cnvaf(art.c.EKDurchschnitt)+'   wert:'+cnvaf(vwert));
  end;
***/

  Art.C.Bestand         # Art.C.Bestand + aMengeIst;
  Art.C.Bestellt        # Art.C.Bestellt + aMengeBest;
  Art.C.Reserviert      # Art.C.Reserviert + aMengeRes;
  Art.C.Kommissioniert  # Art.C.Kommissioniert + aMengeKom;
  Art.C.Bestand.Stk     # Art.C.Bestand.Stk + aStkIst;
  Art.C.Bestellt.Stk    # Art.C.Bestellt.Stk + aStkBest;
  Art.C.Reserviert.Stk  # Art.C.Reserviert.Stk + aStkRes;
  Art.C.Kommission.Stk  # Art.C.Kommission.Stk + aStkKom;
//debugx('BUCHE '+Art.C.ArtikelNr+' '+anum(aMengeRes,0)+'reserv');
// 07.02.2020  if (Set.Art.AufRst.Rsrv) then begin
//    Art.C.OffeneAuf     # Art.C.OffeneAuf     - aMengeRes2;
//    Art.C.OffeneAuf.Stk # Art.C.OffeneAuf.Stk - aStkRes2;
//  end;

  Erx # Art_Data:WriteCharge(n);
if (Art.Nummer='COILS') and (gUsername='AH') then
debug('KEY200 Ist'+anum(art.c.bestand,0)+' Best'+anum(art.c.bestellt,0)+' Res'+anum(Art.C.Reserviert,0)+' Kom'+anum(Art.C.Kommissioniert,0));

//      if (Erx<>_rOk) then Msg(0,'Artikelsumme nicht angelegt!',0,0,0);
  Erg # Erx;  // TODOERX
  RETURN Erx;
****/
end;


//========================================================================
//  _TauscheBmitB
//
//========================================================================
sub _TauscheBmitB(
  aBuf  : int;
);
local begin
  vX  : float;
  vM  : float;
  vI  : int;
end;
begin
  if (aBuf=0) or (aBuf=200) then begin
    vX # Mat.Bestand.Gew;
    vM # Mat.Bestand.Menge;
    vI # Mat.Bestand.Stk;
    Mat.Bestand.Gew   # Mat.Bestellt.Gew;
    Mat.Bestand.Menge # Mat.Bestellt.Menge;
    MAt.Bestand.Stk   # Mat.Bestellt.Stk;
    Mat.Bestellt.Gew    # vX;
    Mat.Bestellt.Menge  # vM;
    Mat.Bestellt.Stk    # vI;
  end
  else begin
    vX # aBuf->Mat.Bestand.Gew;
    vM # aBuf->Mat.Bestand.Menge;
    vI # aBuf->Mat.Bestand.Stk;
    aBuf->Mat.Bestand.Gew   # aBuf->Mat.Bestellt.Gew;
    aBuf->Mat.Bestand.Menge # aBuf->Mat.Bestellt.Menge;
    aBuf->MAt.Bestand.Stk   # aBuf->Mat.Bestellt.Stk;
    aBuf->Mat.Bestellt.Gew    # vX;
    aBuf->Mat.Bestellt.Menge  # vM;
    aBuf->Mat.Bestellt.Stk    # vI;
  end;
end;


//========================================================================
//  _UpdateArtikel
//
//========================================================================
sub _UpdateArtikel(
  aNeu  : logic;
) : int;
local begin
  Erx         : int;
  vA          : alpha;
  vBuf819     : int;
  vBufALT     : int;
  vDrehVSB    : logic;

  vOK         : logic;
  vMengeIst   : float;
  vMengeRes   : float;
  vMengeKom   : float;
  vMengeBest  : float;
  vStkIst     : int;
  vStkRes     : int;
  vStkKom     : int;
  vStkBest    : int;
  vPreis      : float;

  vBuf200     : int;
  vStatus     : int;
end;
begin

  if (aNeu) then vA # 'Y'
  else vA # 'N';
  if (RunAFX('Mat._UpdateArtikel',vA)<>0) then RETURN AfxRes;

//todo(aint(Mat.nummer)+':');
// 05.02.2020 AH: Suche \"art.c.verfügbar\".*\#

  if (Mat.Status=c_Status_EKVSB) and (Set.Art.Vrfgb.VsbEK=false) then begin
    vDrehVSB # y;
    _TauscheBmitB(200);
//debug('DREHE   bestand:'+anum(MAt.Bestand.Gew,0)+'   ek:'+anum(mat.bestellt.gew,0));
  end;

  // NEUANLAGE ---------------------------------------------------------
  if (aNeu) then begin

    if ("Mat.Löschmarker"='*') then begin
      if (vDrehVSB) then _TauscheBmitB(200);
      RETURN _rOK;
    end;

    TRANSON;

  end  // NEUANLAGE --------------------------------------------------

  else begin  // ÄNDERN ------------------------------------------------

    // alte/ursprungs Materialdaten holen...
    vBufALT # RecBufCreate(200);
    RecRead(vBufALT, 0,0, RecInfo(200,_recID));
    if (vDrehVSB) then _TauscheBmitB(vBufAlt);

    // keine wichtige Änderung?
    if (vBufALT->Mat.Warengruppe=Mat.Warengruppe) and
      (vBufALT->Mat.Strukturnr=Mat.Strukturnr) and
      (vBufALT->"Mat.Löschmarker"="Mat.Löschmarker") and
      (vBufALT->Mat.Bestand.Gew=Mat.Bestand.Gew) and
      (vBufALT->Mat.Bestellt.Gew=Mat.Bestellt.Gew) and

      (vBufALT->Mat.Status=Mat.Status) and    // 07.10.2021

      (vBufALT->"Mat.Länge"="Mat.Länge") and
      (vBufALT->"Mat.Breite"="Mat.Breite") and

      (vBufALT->Mat.Reserviert.Gew=Mat.Reserviert.Gew) and
      (vBufALT->Mat.Reserviert2.Gew=Mat.Reserviert2.Gew) and
      (vBufALT->Mat.Bestand.Stk=Mat.Bestand.Stk) and
      (vBufALT->Mat.Bestellt.Stk=Mat.Bestellt.Stk) and
      (vBufAlt->Mat.Kommission=Mat.Kommission) and
      (vBufALT->Mat.Reserviert2.Stk=Mat.Reserviert2.Stk) and
      (vBufALT->Mat.Reserviert.Stk=Mat.Reserviert.Stk) then begin
      RecBufDestroy(vBufALT);
      if (vDrehVSB) then _TauscheBmitB(200);
      RETURN _rOK;
    end;

    // nur wenn vorher aktiv...
    if (vBufALT->"Mat.Löschmarker"='') then vOK # y;

    if (vOK) then begin
      // "alte" Warengruppe prüfen...
      vBuf819 # RecBufCreate(819);
      Erx # RecLink(vBuf819,vBufALT,1,_recfirst);   // ALTE Warengruppe holen
      if (Erx>_rLocked) or (vBufALT->Mat.Strukturnr='') then vOK # n;

      if (Wgr_Data:IstMix(vBuf819->Wgr.Dateinummer)=false) then vOK # n;
//      if (vBuf819->Wgr.Dateinummer<>c_w_ArtMatMix) then vOK # n;
      if (vOK) then begin
        Erx # RecLink(250,vBufALT,26,_recFirst);  // ALTEN Artikel holen
        if (Erx>_rLocked) then vOK # n;
      end;
      RecBufDestroy(vBuf819);
    end;

    TRANSON;

    // "alten" Artikel abbuchen...
    if (vOK) then begin
      // aktuelle Karte/Artikel bebuchen...
vBuf200 # RekSave(200);
RecBufCopy(vBufALT, 200);
/**
      vMengeIst   # Rnd(Lib_Einheiten:WandleMEH(200, vBufALT->Mat.Bestand.Stk, vBufALT->Mat.Bestand.Gew, vBufALT->Mat.Bestand.Gew, 'kg', Art.MEH) ,Set.Stellen.Menge);
      vMengeBest  # Rnd(Lib_Einheiten:WandleMEH(200, vBufALT->Mat.Bestellt.Stk, vBufALT->Mat.Bestellt.Gew, vBufALT->Mat.Bestellt.Gew, 'kg', Art.MEH) ,Set.Stellen.Menge);
      vMengeRes   # Rnd(Lib_Einheiten:WandleMEH(200, vBufALT->Mat.Reserviert.Stk, vBufALT->Mat.Reserviert.Gew, vBufALT->Mat.Reserviert.Gew, 'kg', Art.MEH) ,Set.Stellen.Menge);
***/
      vMengeIst   # vBufALT->Mat.Bestand.Menge;
      vMengeBest  # vBufALT->Mat.Bestellt.Menge;
      vMengeRes   # vBufALT->Mat.Reserviert.Menge;
      RekRestore(vBuf200);
      vStkIst     # vBufALT->Mat.Bestand.Stk;
      vStkBest    # vBufALT->Mat.Bestellt.Stk;
      vStkRes     # vBufALT->Mat.Reserviert.Stk;
      if (vMengeIst<>0.0) and (Mat.EK.Preis<>-1.0) then begin       // 26.11.2014 für DuEK
        vPreis # Rnd(vBufALT->Mat.Bestand.Gew * "Mat.EK.Preis" / 1000.0 ,2);
        vPreis # vPreis / vMengeIst * cnvfi(Art.PEH);
      end;
      if (vBufALT->Mat.AuftragsNr<>0) then begin
        vMengeRes   # vMengeIst;
        vStkRes     # vStkRes;
        vMengeKom   # vMengeIst;
        vStkKom     # vStkRes;
// 07.10.2021 AH wegen Mat.Status      end
//      else if ((vBufALT->Mat.Status>=c_Status_BAGInput) and (vBufALT->Mat.Status<c_Status_BAGOutput) and (vBufALT->Mat.Status<>c_Status_BAGZumFahren)) then begin
//        vMengeRes   # vMengeIst;
//        vStkRes     # vStkRes;
      end;
      vStatus # vBufALT->Mat.Status;
      RecBufDestroy(vBufALT);
//debugx('Ist:'+anum(-vMengeIst,0)+'  EK:'+anum(-vMengeBest,0));
      // Charge ändern...
      Erx # _Add2ArtCharge(-vMengeIst, -vMengeBest, -vMengeRes, -vMengeKom, -vStkIst, -vStkBest, -vStkRes, -vStkKom, -vPreis, vStatus);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        if (vDrehVSB) then _TauscheBmitB(200);
        Erg # Erx;    // TODOERX
        RETURN Erx;
      end;
    end;

  end;  // ÄNDERN ------------------------------------------------------


  if ("Mat.Löschmarker"<>'') then begin
    TRANSOFF;
    if (vDrehVSB) then _TauscheBmitB(200);
    RETURN _rOK;
  end;

  // "neue" Warengruppe prüfen...
  vOK # y;
  vBuf819 # RecBufCreate(819);
  Erx # RecLink(vBuf819,200,1,_recfirst);   // ALTE Warengruppe holen
  if (Erx>_rLocked) or (Mat.Strukturnr='') then vOK # n;
  if (Wgr_Data:IstMix(vBuf819->Wgr.Dateinummer)=false) then vOK # n;
//  if (vBuf819->Wgr.Dateinummer<>c_W_ArtMatMix) then vOK # n;
  if (vOK) then begin
    Erx # RecLink(250,200,26,_recFirst);  // NEUEN Artikel holen
    if (Erx>_rLocked) then vOK # n;
  end;
  RecBufDestroy(vBuf819);
  if (vOK=false) then begin
    TRANSOFF;
    if (vDrehVSB) then _TauscheBmitB(200);
    RETURN _rOK;
  end;


  // aktuelle Karte/Artikel bebuchen...
/***
  vMengeIst   # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Gew, 'kg', Art.MEH) ,Set.Stellen.Menge);
  vMengeBest  # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestellt.Stk, Mat.Bestellt.Gew, Mat.Bestellt.Gew, 'kg', Art.MEH) ,Set.Stellen.Menge);
  vMengeRes   # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Reserviert.Stk, Mat.Reserviert.Gew, Mat.Reserviert.Gew, 'kg', Art.MEH) ,Set.Stellen.Menge);
***/
  vMengeIst   # Mat.Bestand.Menge;
  vMengeBest  # Mat.Bestellt.Menge;
  vMengeRes   # Mat.Reserviert.Menge;
  vMengeKom   # 0.0;    // 27.09.2021 AH, FIXed
  vStkKom     # 0;

//debug(cnvaf(vMengeIst));
  vStkIst     # Mat.Bestand.Stk;
  vStkBest    # Mat.Bestellt.Stk;
  vStkRes     # Mat.Reserviert.Stk;
  if (vMengeIst<>0.0) and (Mat.EK.Preis<>-1.0) then begin       // 26.11.2014 für DuEK
    vPreis # Rnd(Mat.Bestand.Gew * "Mat.EK.Preis" / 1000.0 ,2);
    vPreis # vPreis / vMengeIst * cnvfi(Art.PEH);
  end;
  if (Mat.AuftragsNr<>0) then begin
    vMengeRes   # vMengeIst;
    vStkRes     # vStkRes;
    vMengeKom   # vMengeIst;
    vStkKom     # vStkRes;
//  end
// 07.10.2021 AH wegen Mat.Status  else if ((Mat.Status>=c_Status_BAGInput) and (Mat.Status<c_Status_BAGOutput) and (Mat.Status<>c_Status_BAGZumFahren)) then begin
//    vMengeRes   # vMengeIst;
//    vStkRes     # vStkRes;
  end;
//debug('KEY200 ist:'+anum(vMengeIst,0)+'  Best:'+anum(vMengeBest,0));
  // Charge ändern...
  Erx # _Add2ArtCharge(vMengeIst, vMengeBest, vMengeRes, vMengeKom, vStkIst, vStkBest, vStkRes, vStkKom, vPreis, Mat.Status);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    if (vDrehVSB) then _TauscheBmitB(200);
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end;

  TRANSOFF;
  if (vDrehVSB) then _TauscheBmitB(200);
  RETURN _rOK;
end;


//========================================================================
//  CopyAF
//
//========================================================================
sub CopyAF(aZielMat : int) : logic;
local begin
  Erx : int;
end;
begin
  // Ausführungen kopieren ********************
  Erx # RecLink(201,200,11,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    Mat.AF.Nummer # aZielMat;
    Erx # RekInsert(201,0,'AUTO');
    if (erx<>_rOK) then RETURN false;

    Mat.AF.Nummer # Mat.Nummer;
    Erx # RecLink(201,200,11,_RecNext);
  END;

  RETURN true;
end;


//========================================================================
//  Insert
//
//========================================================================
sub Insert(
  aLock           : int;
  aGrund          : alpha;
  aErzeugtDatum   : date;
//  aErzeugtZeit    : time;
  opt aInvDatum   : date;
) : int;
local begin
  Erx         : int;
  vWirdVkVsb  : logic;
end;
begin
  _SetInternals(y);

  Erx # _SetRef(var vWirdVkVsb);
  if (erx<>_rOK) then begin
    Erg # Erx; // TODOERX
    RETURN Erx;
  end;

  Mat.InventurDatum     # aInvDatum;
  Mat.Inventur.DruckYN  # n;
  Mat.Abrufdatum        # 0.0.0;
  Mat.Anlage.Datum      # today;
  Mat.Anlage.Zeit       # Now;
  Mat.Anlage.User       # gUsername;
  Mat.Datum.Erzeugt     # aErzeugtDatum;
  //Mat.Zeit.Erzeugt      # aErzeugtZeit;
  Mat.Datum.VSBMeldung  # 0.0.0;
  if (Set.Installname<>'VBS') then begin  // 2022-11-16 AH Proj. 2346/24
    Mat.EK.RechDatum      # 0.0.0;        // 21.03.2022 AH
    Mat.EK.RechNr         # 0;            // 21.03.2022 AH
  end;

  TRANSON;

  // ARTIKELDATEI...
  if (Mat.Strukturnr<>'') then begin
    Erx # _UpdateArtikel(y);  // anlegen
    if (erx<>_rOK) then begin
      TRANSBRK;
      Erg # Erx; // TODOERX
      RETURN Erx;
    end
  end;

  // MATERIALDATEI...
  Erx # RekInsert(200,aLock,aGrund);
  if (erx<>_rOK) then begin
    TRANSBRK;
    Erg # Erx; // TODOERX
    RETURN Erx;
  end;

  if (vWirdVkVsb) then
    RunAFX('Mat.WirdVkVSB','');   // 2022-12-20 AH

  // STATISTIK...
  Erx # StatistikBuchen(0);

Set.Mat.DispoAktivYN # false;   // STD dekativiert!
  if (Set.Mat.DispoAktivYN=n) then begin
    TRANSOFF;
    Erg # Erx; // TODOERX
    RETURN Erx;
  end;


  // DISPODATEI...
  if ("Mat.Löschmarker"='') and (Mat.Status<=c_status_bisFrei) and
    ("Mat.Verfügbar.Gew">0.0) and (Mat.Bestellt.Gew=0.0)then begin
    RecBufClear(240);
    DIB.Datei   # 200;
    DIB.ID1     # Mat.Nummer;
    DIB.ID2     # 0;
    "DiB.Güte"  # "Mat.Güte";
    DiB.Dicke   # Mat.Dicke;
    DiB.Breite  # Mat.Breite;
    "DiB.Länge" # "Mat.Länge";
    Erx # RekInsert(240,0,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Erg # Erx; // TODOERX
      RETURN Erx;
    end;
  end;

  TRANSOFF;

  Erg # Erx; // TODOERX
  RETURN erx;
end;


//========================================================================
//  Replace
//
//========================================================================
sub Replace(
  aLock   : int;
  aGrund  : alpha;
) : int;
local begin
  Erx         : int;
  vErx        : int;
  v200        : int;
  vWirdVkVsb  : logic;
end;
begin

  _SetInternals(n);

  Erx # _SetRef(var vWirdVkVsb);
  Erg # Erx;  // TODOERX
  if (erx<>_rOK) then RETURN Erx;

  TRANSON;

  // ARTIKELDATEI...
  Erx # _UpdateArtikel(n);  // nicht anlegen, nicht löschen = replace
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end;


  // STATISTIK...
  if (ProtokollBuffer[200]<>0) then v200 # ProtokollBuffer[200];
  else begin
    v200  # RecBufCreate(200);
    RecRead(v200,0,_recId, RecInfo(200,_recID));
  end;
  Erx # RekReplace(200, aLock, aGrund);
  if (Erx<>_rOK) then begin
    if (ProtokollBuffer[200]=0) then RecBufDestroy(v200);
    TRANSBRK;
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  if (vWirdVkVsb) then
    RunAFX('Mat.WirdVkVSB','');   // 2022-12-20 AH


  vErx # Erx;
  StatistikBuchen(v200);
  if (ProtokollBuffer[200]=0) then RecBufDestroy(v200);
  Erx # vErx;

// 15.10.2014 AH MatSofortInAblage
  if (Set.Mat.Del.SofortYN) and ("Mat.Löschmarker"='*') then Mat_Abl_Data:MatNachAblage();


Set.Mat.DispoAktivYN # false;   // STD dekativiert!
  if (Set.Mat.DispoAktivYN=n) then begin
    TRANSOFF;
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;
/*** 2022-07-05 AH
  // DISPODATEI...
  vErx # Erx;
  RecBufClear(240);
  DiB.Datei # 200;
  DiB.ID1   # Mat.Nummer;
  DiB.ID2   # 0;
  Erx # RekDelete(240,0,aGrund);
  Erx # vErx;

  if ("Mat.Löschmarker"='') and (Mat.Status<=c_status_bisFrei) and
    ("Mat.Verfügbar.Gew">0.0) and (Mat.Bestellt.Gew=0.0)then begin
    "DiB.Güte"  # "Mat.Güte";
    DiB.Dicke   # Mat.Dicke;
    DiB.Breite  # Mat.Breite;
    "DiB.Länge" # "Mat.Länge";
    Erx # RekInsert(240,0,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
  end;

  TRANSOFF;

  Erg # Erx;    // TODOERX
  RETURN Erx;
***/
end;


//========================================================================
//  Delete
//
//========================================================================
sub Delete(
  aLock   : int;
  aGrund  : alpha;
) : int;
local begin
  Erx     : int;
  vErx    : int;
  v200    : int;
  v201    : int;
end;
begin

  v200 # RekSave(200);
  PtD_Main:Deleted(200,'soll');

  TRANSON;

  // Ausführungen löschen
  Erx # RecLink(201,v200,11,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(201,0,aGrund);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RecBufDestroy(v200);
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
    Erx # RecLink(201,v200,11,_recFirst);
  END;
  if (erx=_rLocked) then begin
    TRANSBRK;
    RecBufDestroy(v200);
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  // Bestandsbuch löschen
  Erx # RecLink(202,v200,12,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(202,0,aGrund);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RecBufDestroy(v200);
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
    Erx # RecLink(202,v200,12,_recFirst);
  END;
  if (erx=_rLocked) then begin
    TRANSBRK;
    RecBufDestroy(v200);
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  // Reservierungen löschen
  Erx # RecLink(203,v200,13,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (Mat_Rsv_Data:Entfernen()=false) then begin
      Erx # _rLocked;
      TRANSBRK;
      RecBufDestroy(v200);
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
    //RekDelete(203,0,aGrund);
    Erx # RecLink(203,v200,13,_recFirst);
  END;
  if (Erx=_rLocked) then begin
    TRANSBRK;
    RecBufDestroy(v200);
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  // Aktionen löschen
  Erx # RecLink(204,v200,14,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(204,0,aGrund);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RecBufDestroy(v200);
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
    erx # RecLink(204,v200,14,_recFirst);
  END;
  if (erx=_rLocked) then begin
    TRANSBRK;
    RecBufDestroy(v200);
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  // Lagerprotokoll löschen
  Erx # RecLink(205,v200,15,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(205,0,aGrund);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RecBufDestroy(v200);
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
    erx # RecLink(205,v200,15,_recFirst);
  END;
  if (erx=_rLocked) then begin
    TRANSBRK;
    RecBufDestroy(v200);
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;


  // ARTIKELDATEI...
  if (Mat.Strukturnr<>'') then begin
    "Mat.Löschmarker" # '*';
    Erx # _UpdateArtikel(n);  // nicht anlegen
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RecBufDestroy(v200);
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
  end;


  // MATERIALDATEI...
  RecBufCopy(v200,200);
  Erx # RekDelete(200,aLock,aGrund);
  if (erx<>_rOK) then begin
    TRANSBRK;
    RecBufDestroy(v200);
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

  // STATISTIK ...
  StatistikBuchen(v200, n, true);
  RecBufDestroy(v200);


Set.Mat.DispoAktivYN # false;   // STD dekativiert!
  if (Set.Mat.DispoAktivYN=n) then begin
    TRANSOFF;
    Erg # Erx;    // TODOERX
    RETURN Erx;
  end;

/***
  // DISPODATEI...
  vErx # Erx;
  RecBufClear(240);
  DiB.Datei # 200;
  DiB.ID1   # Mat.Nummer;
  DiB.ID2   # 0;
  Erx # RekDelete(240,0,aGrund);
  Erx # vErx;

  TRANSOFF;

  Erg # Erx;    // TODOERX
  RETURN Erx;
***/
end;


//========================================================================
//  Read
//        liest ein Material aus dem Bestand ODER Ablage !!!
//========================================================================
sub Read(
  aMatNr        : int;
  opt aLock     : int;
  opt a200      : int;
  opt aRestore  : logic) : int;
local begin
  Erx       : int;
  v210      : int;
end;
begin

  if (a200<>0) then begin
    if (aRestore) then begin
      Erg # _rNoRec;  // TODOERX
      RETURN _rNorec;
    end;
    // Bestand?
    a200->Mat.Nummer # aMatNr;
    Erx # RecRead(a200,1,aLock);
    if (Erx=_rOK) or ((Erx=_rLocked) and (aLock=0)) then begin
      Erg # Erx;  // TODOERX
      RETURN 200;
    end;
    if (Erx=_rLocked) and (aLock<>0) then begin
      Erg # Erx;  // TODOERX
      RETURN 200;
    end;

    v210 # RecBufCreate(210);
    // Ablage?
    v210->"Mat~Nummer" # aMatNr;
    Erx # RecRead(v210,1,aLock);
    if (Erx=_rOK) or ((Erx=_rLocked) and (aLock=0)) then begin
      RecBufCopy(v210,a200);
      RecBufDestroy(v210);
      Erg # Erx;  // TODOERX
      RETURN 210;
    end;
    if (Erx=_rLocked) and (aLock<>0) then begin
      RecBufCopy(v210,a200);
      RecBufDestroy(v210);
      Erg # Erx;  // TODOERX
      RETURN _rLocked;
    end;

    // Nicht da!
    RecBufDestroy(v210);
    RecBufClear(a200);
    Erg # _rNoRec;  // TODOERX
    RETURN _rNoRec;
  end;

  // Bestand?
  Mat.Nummer # aMatNr;
  Erx # RecRead(200,1,aLock);
  if (Erx=_rOK) or ((Erx=_rLocked) and (aLock=0)) then begin
    Erg # Erx;  // TODOERX
    RETURN 200;
  end;
  if (Erx=_rLocked) and (aLock<>0) then begin
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end;

  // Ablage?
  if (aRestore=false) then begin
    "Mat~Nummer" # aMatNr;
    Erx # RecRead(210,1,aLock);
    if (Erx=_rOK) or ((Erx=_rLocked) and (aLock=0)) then begin
      RecBufCopy(210,200);
      Erg # Erx;  // TODOERX
      RETURN 210;
    end;
    if (Erx=_rLocked) and (aLock<>0) then begin
      Erg # Erx;  // TODOERX
      RETURN Erx;
    end;
  end
  else begin
    "Mat~Nummer" # aMatNr;
    Erx # RecRead(210,1,0);
    if (Erx<=_rLocked) then begin
      if (Mat_Abl_Data:RestoreausAblage(aMatNr)=false) then begin
        Erg # Erx;  // TODOERX
        RETURN 99;
      end;
      Mat.Nummer # aMatNr;
      Erx # RecRead(200,1,aLock);
      if (Erx=_rOK) or ((Erx=_rLocked) and (aLock=0)) then begin
        Erg # Erx;  // TODOERX
        RETURN 200;
      end;
      if (Erx=_rLocked) and (aLock<>0) then begin
        Erg # Erx;  // TODOERX
        RETURN Erx;
      end;
    end;
  end;

  // Nicht da!
  RecBufClear(210);
  RecBufClear(200);

  Erx # _rNoRec;
  Erg # Erx;  // TODOERX
  RETURN Erx;
end;


//========================================================================
//  Splitten
//
//========================================================================
sub Splitten(
  aStk        : int;
  aNetto      : float;
  aBrutto     : float;
  aMenge      : float;
  aDatum      : date;
  aZeit       : time;
  var aNeueNr : int;
  opt aGrund  : alpha;
) : logic
local begin
  Erx       : int;
  vMyTrans  : logic;
  vBuf404   : int;
  vBuf441   : int;
  vBuf200   : int;
  vMat      : int;
  vGew      : float;
  vMenge    : float;
  vAfxArg   : alpha;
  vX        : float;
  vDelMatYN : logic;
  vLaenge   : float;
end;
begin
  vLaenge # "Mat.Länge"
  // 10.04.2013 VORLÄUFIG:
  if (aMenge=0.0) then begin
    // 29.10.2013 AH: Projekt 1471/6: um Rundungsdifferenzen beim Dreisatz zu vermeiden, ggf. über volle Länge rechnen:
    if (Mat.MEH='m') and (rnd( ("Mat.Länge" / 1000.0 * cnvfi(Mat.Bestand.Stk)),0) = Rnd(Mat.Bestand.Menge,0)) then begin
      aMenge # vLaenge * cnvfi(aStk) / 1000.0;
    end
    //2023-06-06 MR Berechnet Menge wenn Mengeneinheit 'm' und Gewicht schon berechnet
    else if (Mat.MEH = 'm' and Mat.Strukturnr !=  '') then begin
      Erx # RecLink(250,200,26,_recFirst);
      if(Erx = 0) then begin
        aMenge # vLaenge * cnvfi(aStk) / 1000.0;//rnd(aNetto / Art.GewichtProM)
      end
    end
    else begin
      // über Dreisatz...
      DivOrNull(vX, cnvfi(aStk), cnvfi(Mat.Bestand.Stk), 3);
      if (vX=0.0) then
        DivOrNull(vX, aBrutto, Mat.Gewicht.Brutto, 3);
      if (vX=0.0) then
        DivOrNull(vX, aNetto, Mat.Gewicht.Netto, 3);
      if (vX<>0.0) then begin
        aMenge # Mat.Bestand.Menge * vX;
      end
      else begin
        // sonst errechnen
        aMenge # MengeVorlaeufig(aStk, aNetto, aBrutto);
      end;
    end;

  end;


  if ("Mat.Löschmarker"<>'') or (Mat.Eingangsdatum=0.0.0) or
    (Mat.Ausgangsdatum<>0.0.0) then begin

    // Löschmarker gesetzt, Eingangsdatum ist leer oder Ausgang gefüllt
    if ("Mat.Löschmarker"<>'') then
      Msg(200006,'',0,0,0);
    if (Mat.Eingangsdatum=0.0.0) then
      Msg(200107,'',0,0,0);
    if (Mat.Ausgangsdatum<>0.0.0) then
      Msg(200108,'',0,0,0);

    RETURN false;
  end;

  if (Mat.Bestellt.Gew<>0.0) or (Mat.Bestellt.Stk<>0) then begin
//    (Mat.Reserviert.Gew<>0.0) or (Mat.Reserviert.Stk<>0) then RETURN false;
    // Karte hat ein Bestellmengen
    Msg(200109,'',0,0,0);
    RETURN false;
  end;


  if (TransActive=n) then begin
    TRANSON;
    vMyTrans # y;
  end;

  if (aDatum=0.0.0) then begin
    aDatum  # today;
    aZeit   # now;
  end;

  // aktuelle Karte mindern...
  vMat # Mat.Nummer;
  vBuf200 # RekSave(200);
  PtD_Main:Memorize(200);
  vGew    # Mat.Bestand.Gew;
  vMenge  # Mat.Bestand.Menge;
  Erx # RecRead(200,1,_RecSingleLock);
  if (Erx=_rOK) then begin
    Mat.Bestand.Stk     # Mat.Bestand.Stk - aStk;
    Mat.Bestand.Menge   # Mat.Bestand.Menge - aMenge;
    Mat.Gewicht.Netto   # Mat.Gewicht.Netto  - aNetto;
    Mat.Gewicht.Brutto  # Mat.Gewicht.Brutto - aBrutto;

    
    if(Mat.Bestand.Stk <= 0) then begin
      Mat.Bestand.Menge # 0.0;
      Mat.Gewicht.Netto # 0.0;
      Mat.Gewicht.Brutto # 0.0;
    end

    Erx # RecLink(818,200,10,_recfirst);    // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    if (VWa.NettoYN) then
      Mat.Bestand.Gew # Mat.Gewicht.Netto;
    else
      Mat.Bestand.Gew # Mat.Gewicht.Brutto;





    if (MAt.Bestand.Menge>0.0) or (Mat.Bestand.Gew>0.0) then begin // 22.04.2014 AH
      if (Mat.Bestand.Stk<=0) then Mat.Bestand.Stk  # 1;
    end
    else begin
    vDelMatYN # true;
    Mat.Lagerplatz # '';
   end

    Erx # Replace(_RecUnlock,'AUTO');
  end;
  if (Erx<>_rOK) then begin
    if (vMyTrans) then TRANSBRK;
    RecBufDestroy(vBuf200);
    PtD_Main:Forget(200);

    // Fehler beim Speichern der Materialkarte
    Msg(200106,Aint(Mat.Nummer),0,0,0);
    RETURN false;
  end;
  vGew    # Mat.Bestand.Gew - vGew;
  vMenge  # Mat.Bestand.Menge - vMenge;

  aNeueNr # Lib_Nummern:ReadNummer('Material');
  if (aNeueNr<>0) then begin
    Lib_Nummern:SaveNummer()
  end
  else begin
    if (vMyTrans) then TRANSBRK;
    RecBufDestroy(vBuf200);
    PtD_Main:Forget(200);

    // neue Materialnummer konnte nicht generieret werden
    Msg(200110,'',0,0,0);
    RETURN false;
  end;

  // Ausführungen kopieren ********************
  CopyAF(aNeueNr);

  // Aktionen anlegen...
  RecBufClear(204);
  Mat.A.Aktionsmat    # Mat.Nummer;
  Mat.A.Entstanden    # aNeueNr;
  Mat.A.Aktionstyp    # c_Akt_Split;
  //Mat.A.Aktionspos    # Mat.B.lfdnr;
  Mat.A.Aktionsdatum  # aDatum;
  Mat.A.Aktionszeit   # aZeit;
  Mat.A.Bemerkung     # aGrund;
  if (Mat_A_Data:Insert(0,'AUTO')=_rOK) then Erx # _rOK
  else Erx # _rnoRec;
  if (erx<>_rOK) then begin
    if (vMyTrans) then TRANSBRK;
    RecBufDestroy(vBuf200);
    PtD_Main:Forget(200);

    // Aktionslisteneintrag konnte nicht erstellt werden
    Msg(200111,'',0,0,0);
    RETURN false;
  end;

  RekRestore(vBuf200);

  // Bestandsänderung protokollieren...
  Bestandsbuch(-1 * aStk, vGew, vMenge, 0.0, 0.0, c_Akt_Split, aDatum, aZeit, c_Akt_Split);

  // BestandsbuchID nachtragen in Aktion...
  Erx # RecRead(204,1,_recLock);
  if (Erx=_rOk) then begin
    Mat.A.Aktionspos    # Mat.B.lfdnr;
    Erx # RekReplace(204,_recUnlock,'AUTO');
  end;
  if (Erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
    if (vMyTrans) then TRANSBRK;
    RecBufDestroy(vBuf200);
    PtD_Main:Forget(200);
    Msg(200112,'',0,0,0);
    RETURN false;
  end;

 
    


  // Neue Karte anlegen
  "Mat.Vorgänger"     # Mat.Nummer;
  Mat.Nummer          # aNeueNr;
  if (Mat.Ursprung=0) then Mat.Ursprung # "Mat.Vorgänger";
  Mat.Bestand.Stk     # aStk;
  Mat.Bestand.Menge   # aMenge;   // 17.12.2014 war vMenge
  Mat.Reserviert.Gew  # 0.0;
  Mat.Reserviert.Stk  # 0;
  Mat.Reserviert2.Gew # 0.0;
  Mat.Reserviert2.Stk # 0;
  Mat.Gewicht.Netto   # aNetto;
  Mat.Gewicht.Brutto  # aBrutto;
  Erx # RecLink(818, 200, 10, _recfirst); // Verwiegungsart holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;
  if (VWa.NettoYN) then
    Mat.Bestand.Gew # Mat.Gewicht.Netto;
  else
    Mat.Bestand.Gew # Mat.Gewicht.Brutto;

  if (Mat.Bestand.Stk<=0) then Mat.Bestand.Stk  # 1;

  Erx # Insert(0,'AUTO', aDatum);
  if (erx<>_rOK) then begin
    if (vMyTrans) then TRANSBRK;
    PtD_Main:Forget(200);

    // neue Materialkarte konnte nicht angelegt werden
    Msg(200112,'',0,0,0);
    RETURN false;
  end;


  if (vMyTrans) then TRANSOFF;
  
 
  
  Mat.Nummer # vMat;
  RecRead(200,1,0);
  PtD_Main:Compare(200);

 if(vDelMatYN) then
    Mat_Subs:RecDel(true, false);

  RETURN true;

end;


//========================================================================
//  Copy
//
//========================================================================
/**
sub Copy(aNeuerStamm : logic): logic;
local begin
  vNeueNr : int;
end;
begin

  TRANSON;

  vNeueNr # Lib_Nummern:ReadNummer('Material');
  if (vNeueNr<>0) then begin
    Lib_Nummern:SaveNummer()
  end
  else begin
    TRANSBRK;
    RETURN false;
  end;

  // Ausführungen kopieren ********************
  if (CopyAF(vNeueNr)=false) then begin
    TRANSBRK;
    RETURN false;
  end;


  Mat.Reserviert.Gew # 0.0;
  Mat.Reserviert.Stk # 0;
  "Mat.Verfügbar.Stk" # Mat.Bestand.Stk + Mat.Bestellt.Stk - Mat.Reserviert.Stk;
  "Mat.Verfügbar.Gew" # Mat.Bestand.Gew + Mat.Bestellt.Gew - Mat.Reserviert.Gew;
  Mat.Kommission      # '';
  Mat.Auftragsnr      # 0;
  Mat.Auftragspos     # 0;
  Mat.KommKundennr    # 0;
  Mat.KommKundenSWort # '';
  Mat.Bestellnummer   # '';
  Mat.Einkaufsnr      # 0;
  Mat.Einkaufspos     # 0;
  Mat.BestellABNr     # '';
  Mat.Bestelldatum    # 0.0.0;
  Mat.BestellTermin   # 0.0.0;
  Mat.VK.Kundennr     # 0;
  Mat.VK.Rechnr       # 0;
  Mat.VK.Rechdatum    # 0.0.0;
  Mat.VK.Preis        # 0.0;
  Mat.VK.Gewicht      # 0.0;
  Mat.EK.RechNr       # 0;
  Mat.EK.RechDatum    # 0.0.0;

  if (aNeuerStamm) then begin
    Mat.Nummer      # vNeueNr;
    "Mat.Vorgänger" # 0;
    Mat.Ursprung    # vNeueNr;
  end
  else begin
    "Mat.Vorgänger" # Mat.Nummer;
    Mat.Nummer      # vNeueNr;
  end;
  Insert(0,'MAN', today);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN false
  end;

  TRANSOFF;

  RETURN true;
end;
***/

//========================================================================
//  SetStatus
//
//========================================================================
sub SetStatus(aStatus : int);
local begin
  vErx : int;
end;
begin

  REPEAT
    Mat.Status     # aStatus;
    Mat.Sta.Nummer # aStatus;
    vErx # RecRead(820,1,0);
    if (vErx>=_rLocked) or (Mat.Sta.Nummer=Mat.Sta.neueNummer) then RETURN;
    aStatus # Mat.Sta.neueNummer;
  UNTIl (Mat.Sta.neueNummer=Mat.Sta.Nummer) or (Mat.Sta.neueNummer=0);

end;


//========================================================================
//  Bestandsbuch
//
//========================================================================
sub Bestandsbuch(
  aStk      : int;
  aGew      : float;
  aMenge    : float;
  aPreis    : float;
  aPreisPM  : float;
  aBem      : alpha(100);
  aDatum    : date;
  aZeit     : time;
  aTyp      : alpha;
  opt aT1   : int;
  opt aT2   : word;
  opt aT3   : word;
  opt aT4   : word;
  opt aFIX  : logic;
) : logic;
local begin
  Erx : int;
end;
begin

  // 10.04.2013 VORLÄUFIG:
  if (aMenge=0.0) then aMenge # MengeVorlaeufig(aStk, aGew, aGew);
  if (aPreisPM=0.0) and (aPreis<>0.0) and (aMenge<>0.0) then
    aPreisPM # Rnd((aGew * aPreis / 1000.0) / aMenge, 2);


  if (RecLink(202,200,12,_recLast)>_rLocked) then RecBufClear(202);
  Mat.B.Materialnr    # Mat.Nummer;
  Mat.B.Datum         # aDatum;
  MAt.B.Zeit          # aZeit;
  "Mat.B.Stückzahl"   # aStk;
  Mat.B.Gewicht       # aGew;
  Mat.B.Menge         # aMenge;

  Mat.B.PreisW1       # aPreis;
  Mat.B.PreisW1ProMEH # aPreisPM;
  Mat.B.FixYN         # aFix;
  Mat.B.Bemerkung     # StrCut(aBem,1,32);
  "Mat.B.Trägertyp"   # aTyp;
  "Mat.B.Trägernummer1" # aT1;
  "Mat.B.Trägernummer2" # aT2;
  "Mat.B.Trägernummer3" # aT3;
  "Mat.B.Trägernummer4" # aT4;

  Mat.B.Anlage.Datum  # today;
  Mat.B.Anlage.Zeit   # Now;
  Mat.B.Anlage.User   # gUserName;
  REPEAT
    Mat.B.lfdNr       # Mat.B.lfdNr + 1;
    Erx # RekInsert(202,0,'MAN');
    if (Erx=_rDeadLock) then RETURN false;
  UNTIL (erx=_rOK);
  
  RETURN true;
end;


//========================================================================
//  SetKommission
//
//========================================================================
sub SetKommission(
  aMatNr    : int;
  aAufNr    : int;
  aAufPos   : int;
  aAufPos2  : int;
  aTyp      : alpha;
  ) : int;
local begin
  Erx       : int;
  vFound    : logic;
  vOK       : logic;
  v500      : int;
  v501      : int;
end;
begin

  if (Mat.Nummer<>aMatNr) then begin
    Mat.Nummer # aMatNr;
    Erx # Recread(200,1,0);
    if (Erx<>_rOK) then RETURN 100;
  end;

  if (Mat.Kommission='') and (aAufNr=0) then RETURN 0;
  if (aAufNr<>0) and (Mat.Auftragsnr=aAufNr) and (Mat.Auftragspos=aAufPos) and (Mat.Auftragspos2=aAufPos2) then RETURN 0;
  if (Mat.Kommission<>'') and (aAufNr<>0) then RETURN 101;


  // BISHERIGE KOMMISSION ENTFERNEN ***************
  if (aAufNr=0) then begin
    if (Mat.Auftragsnr<>0) then begin
      Erx # RecLink(401,200,16,_recFirst);  // Aufpos holen
      if (Erx<>_rOK) then RETURN 200;
      Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
    end;

    Erx # Recread(200,1,_recSingleLock);
    if (Erx<>_rOK) then RETURN 201;

    TRANSON;

    // Aus VersandPool ggf. entfernen...
    if (VsP_Data:DelMatAusPool(Mat.Nummer)=false) then begin
      TRANSBRK;
      RETURN 1191;
    end;

    if (aTyp='MAN') then Ptd_Main:Memorize(200);
    Mat.Auftragsnr        # 0;
    Mat.Auftragspos       # 0;
    Mat.Auftragspos2      # 0;
    Mat.Kommission        # '';
    Mat.KommKundenSWort   # '';
    Mat.KommKundennr      # 0;
    Mat.Datum.VSBMeldung  # 0.0.0;
    Mat.KundenArtNr       # '';
    if (Mat.Status=c_status_VSB) or (Mat.Status=c_status_VSBKonsi) or (Mat.Status=c_status_VSBKonsiRahmen) or
      (Mat.Status=c_Status_VSBPuffer) or (Mat.Status=c_Status_VSBRahmen) then
      SetStatus(c_Status_Frei);
    Erx # Replace(_RecUnlock,'MAN');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RETURN 836;
    end;
    if (aTyp='MAN') then Ptd_Main:Compare(200);

    // MATZ-Aktion entfernen ÜBER Mat.REPLACE

  end

  // NEUE KOMMISSION SETZEN ***************
  else begin

    Auf.P.Nummer    # aAufNr;
    Auf.P.Position  # aAufPos;
    Erx # RecRead(401,1,0); // Auftrag holen
    if (Erx<>_rOK) then RETURN 300;

    Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
    if (Erx>_rLocked) then RecBufClear(835);
    Erx # RecLink(400,401,3,_recFirst);   // Kopf holen

    if (Erx<>_rOK) or
      ("Auf.P.Löschmarker"='*') or
      (Auf.Vorgangstyp<>c_AUF) or
      ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false)) then RETURN 301;


    // 22.07.2019 AH: Auftrag + Mat sind geladen:
    if (RunAFX('Mat.SetKommission.Check',aTyp)<>0) then begin
      if (AfxRes<>_rOK) then RETURN 999;
    end;

    Erx # Recread(200,1,_recSingleLock);
    if (Erx<>_rOK) then RETURN 302;

    TRANSON;

    if (aTyp='MAN') then Ptd_Main:Memorize(200);
    Mat.Auftragsnr        # Auf.P.Nummer;
    Mat.Auftragspos       # Auf.P.Position;
    Mat.Auftragspos2      # aAufPos2;
    Mat.KundenArtNr       # Auf.P.KundenArtNr;
    Mat.Kommission        # '';
    Mat.KommKundenSWort   # '';
    Mat.KommKundennr      # 0;
    Mat.Datum.VSBMeldung  # 0.0.0;

    if ((Mat.Status<c_status_Bestellt) or (Mat.Status>c_Status_BisEK)) and
      ((Mat.Status<c_Status_BAG) or (Mat.Status>c_Status_bisBAG)) then begin
      if (AAr.KonsiYN=n) then begin
        Erx # RecLink(400,401,3,_recFirst);   // AufKopf holen
        if (Auf.PAbrufYN) then
          SetStatus(c_Status_VSBPuffer)
        else if (Auf.LiefervertragYN) then
          SetStatus(c_Status_VSBRahmen)
        else
          SetStatus(c_Status_VSB);
      end
      else begin
        Erx # RecLink(400,401,3,_recFirst);   // AufKopf holen
        if (Auf.LiefervertragYN) then
          SetStatus(c_Status_VSBKonsiRahmen)
        else
          SetStatus(c_Status_VSBKonsi);
      end;
    end;
    Erx # Replace(_RecUnlock,'MAN');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      if (aTyp='MAN') then PtD_Main:Forget(200);
      RETURN 873;
    end;
    if (aTyp='MAN') then Ptd_Main:Compare(200);


    // Reservierung prüfen
    if (RecLinkInfo(203,200,13,_recCount)>1) then RETURN 301;
    if (RecLinkInfo(203,200,13,_recCount)=1) then begin
      Erx # RecLink(203,200,13,_recFirst);     // Reservierung holen

      // LFA???
      if ("Mat.R.Trägertyp"=c_Akt_BAInput) then begin
        // weiter unten...
      end
      else begin
        vOK # n;
        if (Mat.R.Auftragsnr=Auf.P.Nummer) and (Mat.R.Auftragspos=Auf.P.Position) then vOK # y;
        if (Mat.R.Auftragsnr=0) and (Mat.R.Kundennummer=Auf.P.Kundennr) then vOK # y;
        if (vOK=false) then begin
          TRANSBRK;
          RETURN 302;
        end;
        if (Mat_Rsv_Data:Entfernen()=false) then begin
          TRANSBRK;
          RETURN 303;
        end;
      end;
    end;

    // MATZ-Aktion anlegen ÜBER MAT.REPLACE !!!

  end;

  // 20.10.2016 AH: Nummer im BA nachtragen...
  if (RecLinkInfo(203,200,13,_recCount)=1) then begin
    Erx # RecLink(203,200,13,_recFirst);     // Reservierung holen
    // LFA???
    if ("Mat.R.Trägertyp"=c_Akt_BAInput) then begin
      BAG.IO.Nummer   # "Mat.R.TrägerNummer1";
      BAG.IO.ID       # "Mat.R.TrägerNummer2";
      Erx # RecRead(701,1,0);
      if (Erx<=_rLocked) then begin
        Erx # RecRead(701,1,_RecLocK);
        if (erx=_rOK) then begin
          BAG.IO.Auftragsnr     # Mat.Auftragsnr;
          BAG.IO.AuftragsPos    # Mat.AuftragsPos;
          BAG.IO.AuftragsFert   # 0;
          Erx # RekReplace(701);
        end;
        if (erx<>_rOK) then begin // 2022-07-05 AH DEADLOCK
          TRANSBRK;
          RETURN 2515;
        end;
      end;
    end
  end;

  // 01.07.2020 AH: ggf. Bestellposition anpassen:
  if (Mat.Bestellt.Gew<>0.0) and (Mat.Einkaufsnr<>0) then begin
    v500 # Reksave(500);
    v501 # Reksave(501);
    Erx # RecLink(501,200,18,_recFirst);   // Bestellpos holen
    if (Erx<=_rLocked) and
      ((Ein.P.KommissionNr<>Mat.Auftragsnr) or
        (Ein.P.KommissionPos<>Mat.Auftragspos) or (Ein.P.KommiKunde<>Mat.KommKundennr)) then begin
      Erx # RecRead(501,1,_recLock);
      if (erx=_rOK) then begin
        Ein.P.KommissionNr  # Mat.Auftragsnr;
        Ein.P.KommissionPos # Mat.Auftragspos;
        Ein.P.Kommission    # Mat.Kommission;
        Ein.P.KommiKunde    # Mat.KommKundennr;
        Erx # RekReplace(501);
      end;
      if (erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
        RekRestore(v500);
        RekRestore(v501);
        TRANSBRK;
        RETURN 2542;
      end;

      Erx # RecLink(500,501,3,_RecFirst);   // BestKopf holen
      if (Ein_Data:VerbuchePos()=false) then begin
        RekRestore(v500);
        RekRestore(v501);
        TRANSBRK;
        RETURN 3232;
      end;
      RekRestore(v501);
      RekRestore(v500);
    end;
  end;

  TRANSOFF;

  RETURN 0;   // alles ok!
end;


//========================================================================
//  CopyAnalyse2Mat
//
//========================================================================
sub CopyAnalyse2Mat();
local begin
  Erx       : int;
end
begin
  if (Mat.Analysenummer=0) then RETURN;

  Erx # RecLink(230,200,21,_recFirst);  // Analyse holen
  If (Erx>_rLocked) then RETURN;

  Erx # RecLink(231,230,1,_recFirst);   // 1. Analysepos holen  21.06.2018 AH

  Erx # RecRead(200,1,_recSingleLock);    // Mat. sperren
  If (Erx>_rLocked) then RETURN;

  Mat.Streckgrenze2     # Lys.Streckgrenze;
  Mat.Zugfestigkeit2    # Lys.Zugfestigkeit;
  Mat.StreckgrenzeB2    # Lys.Streckgrenze2;
  Mat.ZugfestigkeitB2   # Lys.Zugfestigkeit2;
  Mat.DehnungA2         # Lys.DehnungA;
  Mat.DehnungB2         # Lys.DehnungB;
  Mat.DehnungC2         # Lys.DehnungC;
  Mat.RP02_V2           # Lys.RP02_1;
  Mat.RP02_B2           # Lys.RP02_2;
  Mat.RP10_V2           # Lys.RP10_1;
  Mat.RP10_B2           # Lys.RP10_2;
  Mat.RP10_B2           # Lys.RP10_2;
  "Mat.Körnung2"        # "Lys.Körnung";
  "Mat.KörnungB2"       # "Lys.Körnung2";
  "Mat.HärteA2"         # "LYs.Härte1";
  "Mat.HärteB2"         # "Lys.Härte2";
  Mat.RauigkeitA2       # Lys.RauigkeitA1;
  Mat.RauigkeitB2       # Lys.RauigkeitA2;
  Mat.RauigkeitC2       # Lys.RauigkeitB1;
  Mat.RauigkeitD2       # Lys.RauigkeitB2;

  Mat.Chemie.C2         # Lys.Chemie.C;
  Mat.Chemie.Si2        # Lys.Chemie.Si;
  Mat.Chemie.Mn2        # Lys.Chemie.Mn;
  Mat.Chemie.P2         # Lys.Chemie.P;
  Mat.Chemie.S2         # Lys.Chemie.S;
  Mat.Chemie.Al2        # Lys.Chemie.Al;
  Mat.Chemie.Cr2        # Lys.Chemie.Cr;
  Mat.Chemie.V2         # Lys.Chemie.V;
  Mat.Chemie.Nb2        # Lys.Chemie.Nb;
  Mat.Chemie.Ti2        # Lys.Chemie.Ti;
  Mat.Chemie.N2         # Lys.Chemie.N;
  Mat.Chemie.Cu2        # Lys.Chemie.Cu;
  Mat.Chemie.Ni2        # Lys.Chemie.Ni;
  Mat.Chemie.Mo2        # Lys.Chemie.Mo;
  Mat.Chemie.B2         # Lys.Chemie.B;
  Mat.Chemie.Frei1.2    # Lys.Chemie.Frei1;

  Replace(_recUnlock,'AUTO');

end;


//========================================================================
//  VererbeDaten
//
//========================================================================
sub VererbeDaten(
  aPreis        : logic;
  aAnalyse      : logic;
  opt aAnalyse2 : logic;
  opt aLfE      : logic;
) : logic;
local begin
  Erx     : int;
  vBuf200 : int;
  vBuf204 : int;
end;
begin
  if (aPreis=falsE) and (aAnalyse=false) AND (aAnalyse2=false) and (aLFE=false) then RETURN true;

  Erx # RecLink(204,200,14,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Mat.A.Entstanden=0) then begin
      Erx # RecLink(204,200,14,_recNext);
      CYCLE;
    end;

    vBuf200 # RekSave(200);
    vBuf204 # RekSave(204);

    Mat.Nummer # Mat.A.Entstanden;
    Erx # RecRead(200,1,_recSingleLock);
    if (Erx<>_rOK) then begin
      RekRestore(vBuf200);
      RekRestore(vBuf204);
      RETURN false;
    end;


    // Preis vererben...
    if (aPreis) then begin
      Mat.EK.Preis          # vBuf200->Mat.EK.Preis;
      Mat.EK.PreisProMEH    # vBuf200->Mat.EK.PreisProMEH;
      // Bestandsbuch loopen...
      FOR Erx # RecLink(202,200,12,_recFirst)
      LOOP Erx # RecLink(202,200,12,_recNext)
      WHILE (Erx<=_rLocked) do begin
        // if (Mat.B.FixYN=false) and
        if (Mat.B.PreisW1<>0.0) then      Mat.EK.Preis        # Mat.EK.Preis + Mat.B.PreisW1;
        if (Mat.B.PreisW1ProMEH<>0.0) then Mat.EK.PreisProMEH # Mat.EK.PreisProMEH + Mat.B.PreisW1ProMEH;
      END;
    end;

    // LfE vererben...
    if (aLfE) then begin
      Mat.LfENr             # vBuf200->Mat.LfENr;
    end;

    // Analyse vererben...
    if (aAnalyse) then begin
      // 10.01.2019 AH
      if (Set.LyseErweitertYN) then begin
        Mat.Analysenummer # vBuf200->Mat.Analysenummer;
      end
      else begin
        Mat.Streckgrenze1     # vBuf200->Mat.Streckgrenze1;
        Mat.Zugfestigkeit1    # vBuf200->Mat.Zugfestigkeit1;
        Mat.StreckgrenzeB1    # vBuf200->Mat.StreckgrenzeB1;
        Mat.ZugfestigkeitB1   # vBuf200->Mat.ZugfestigkeitB1;
        Mat.DehnungA1         # vBuf200->Mat.DehnungA1;
        Mat.DehnungB1         # vBuf200->Mat.DehnungB1;
        Mat.DehnungC1         # vBuf200->Mat.DehnungC1;
        Mat.RP02_V1           # vBuf200->Mat.RP02_V1;
        Mat.RP02_B1           # vBuf200->Mat.RP02_B1;
        Mat.RP10_V1           # vBuf200->Mat.RP10_V1;
        Mat.RP10_B1           # vBuf200->Mat.RP10_B1;
        "Mat.Körnung1"        # vBuf200->"Mat.Körnung1";
        "Mat.KörnungB1"       # vBuf200->"Mat.KörnungB1";
        Mat.Chemie.C1         # vBuf200->Mat.Chemie.C1;
        Mat.Chemie.Si1        # vBuf200->Mat.Chemie.Si1
        Mat.Chemie.Mn1        # vBuf200->Mat.Chemie.Mn1;
        Mat.Chemie.P1         # vBuf200->Mat.Chemie.P1;
        Mat.Chemie.S1         # vBuf200->Mat.Chemie.S1;
        Mat.Chemie.Al1        # vBuf200->Mat.Chemie.Al1;
        Mat.Chemie.Cr1        # vBuf200->Mat.Chemie.Cr1;
        Mat.Chemie.V1         # vBuf200->Mat.Chemie.V1;
        Mat.Chemie.Nb1        # vBuf200->Mat.Chemie.Nb1;
        Mat.Chemie.Ti1        # vBuf200->Mat.Chemie.Ti1;
        Mat.Chemie.N1         # vBuf200->Mat.Chemie.N1;
        Mat.Chemie.Cu1        # vBuf200->Mat.Chemie.Cu1;
        Mat.Chemie.Ni1        # vBuf200->Mat.Chemie.Ni1;
        Mat.Chemie.Mo1        # vBuf200->Mat.Chemie.Mo1;
        Mat.Chemie.B1         # vBuf200->Mat.Chemie.B1;
        Mat.Chemie.Frei1.1    # vBuf200->Mat.Chemie.Frei1.1;
        Mat.Mech.Sonstiges1   # vBuf200->Mat.Mech.sonstiges1;
        "Mat.HärteB1"         # vBuf200->"Mat.HärteB1";
        "Mat.HärteA1"         # vBuf200->"Mat.HärteA1";
        Mat.RauigkeitA1       # vBuf200->Mat.RauigkeitA1;
        Mat.RauigkeitB1       # vBuf200->Mat.RauigkeitB1;
        Mat.RauigkeitC1       # vBuf200->Mat.RauigkeitC1;
        Mat.RauigkeitD1       # vBuf200->Mat.RauigkeitD1;
      end;
    end;
    // ST 2013-02-25 - 1304/160
    if (aAnalyse2) then begin
      // 10.01.2019 AH
      if (Set.LyseErweitertYN) then begin
        Mat.Analysenummer2# vBuf200->Mat.Analysenummer2
      end
      else begin
        Mat.Streckgrenze2     # vBuf200->Mat.Streckgrenze2;
        Mat.Zugfestigkeit2    # vBuf200->Mat.Zugfestigkeit2;
        Mat.StreckgrenzeB2    # vBuf200->Mat.StreckgrenzeB2;
        Mat.ZugfestigkeitB2   # vBuf200->Mat.ZugfestigkeitB2;
        Mat.DehnungA2         # vBuf200->Mat.DehnungA2;
        Mat.DehnungB2         # vBuf200->Mat.DehnungB2;
        Mat.DehnungC2         # vBuf200->Mat.DehnungC2;
        Mat.RP02_V2           # vBuf200->Mat.RP02_V2;
        Mat.RP02_B2           # vBuf200->Mat.RP02_B2;
        Mat.RP10_V2           # vBuf200->Mat.RP10_V2;
        Mat.RP10_B2           # vBuf200->Mat.RP10_B2;
        "Mat.Körnung2"        # vBuf200->"Mat.Körnung2";
        "Mat.KörnungB2"       # vBuf200->"Mat.KörnungB2";
        Mat.Chemie.C2         # vBuf200->Mat.Chemie.C2;
        Mat.Chemie.Si2        # vBuf200->Mat.Chemie.Si2;
        Mat.Chemie.Mn2        # vBuf200->Mat.Chemie.Mn2;
        Mat.Chemie.P2         # vBuf200->Mat.Chemie.P2;
        Mat.Chemie.S2         # vBuf200->Mat.Chemie.S2;
        Mat.Chemie.Al2        # vBuf200->Mat.Chemie.Al2;
        Mat.Chemie.Cr2        # vBuf200->Mat.Chemie.Cr2;
        Mat.Chemie.V2         # vBuf200->Mat.Chemie.V2;
        Mat.Chemie.Nb2        # vBuf200->Mat.Chemie.Nb2;
        Mat.Chemie.Ti2        # vBuf200->Mat.Chemie.Ti2;
        Mat.Chemie.N2         # vBuf200->Mat.Chemie.N2;
        Mat.Chemie.Cu2        # vBuf200->Mat.Chemie.Cu2;
        Mat.Chemie.Ni2        # vBuf200->Mat.Chemie.Ni2;
        Mat.Chemie.Mo2        # vBuf200->Mat.Chemie.Mo2;
        Mat.Chemie.B2         # vBuf200->Mat.Chemie.B2;
        Mat.Chemie.Frei1.2    # vBuf200->Mat.Chemie.Frei1.2;
        Mat.Mech.Sonstiges2   # vBuf200->Mat.Mech.sonstiges2;
        "Mat.HärteB2"         # vBuf200->"Mat.HärteB2";
        "Mat.HärteA2"         # vBuf200->"Mat.HärteA2";
        Mat.RauigkeitA2       # vBuf200->Mat.RauigkeitA2;
        Mat.RauigkeitB2       # vBuf200->Mat.RauigkeitB2;
        Mat.RauigkeitC2       # vBuf200->Mat.RauigkeitC2;
        Mat.RauigkeitD2       # vBuf200->Mat.RauigkeitD2;
      end;
    end;

    Erx # Mat_data:Replace(_RecUnlock,'AUTO');
    if (erx<>_rOK) then begin
      RekRestore(vBuf200);
      RekRestore(vBuf204);
      RETURN false;
    end;

    // ST 2014-02-12 Bugfix: wenn Analyse2 vererbt werden soll,
    //                       dann auch vererben und nicht nur auf dem Ursprung
    //VererbeDaten(aPreis, aAnalyse);           // alt
    VererbeDaten(aPreis, aAnalyse, aAnalyse2, aLFE);  // neu

    RekRestore(vBuf200);
    RekRestore(vBuf204);

    Erx # RecLink(204,200,14,_recNext);
  END;

  RETURN true;
end;


//========================================================================
//  VererbeNeubewertung
//
//========================================================================
sub VererbeNeubewertung(
  aDiff     : float;
  aDiffPM   : float;
  aGrund    : alpha;
  aDat      : date;
  aTim      : time;
  aNachFix  : logic;
  opt aTyp  : alpha;
  opt aT1   : int;
  opt aT2   : word;
  opt aT3   : word;
  opt aT4   : word;
) : logic;
local begin
  Erx       : int;
  vBuf200   : int;
  vBuf200b  : int;
  vBuf204   : int;
  vOK       : logic;
  vWeiter   : logic;
  vNachFix  : logic;
  vGew      : float;
  vMenge    : float;
  vWert     : float;
  vWertMEH  : float;
  vDiff     : float;
  vDiffPM   : float;
end;
begin

  if (aDiff=0.0) then RETURN true;

//debugx('neubwert : '+anum(aDiff,2)+' bei KEY200');

  // 10.04.2013 VORLÄUFIG:
  if (aDiffPM=0.0) and (aDiff<>0.0) and (Mat.Bestand.Menge<>0.0) then
    aDiffPM # Rnd((Mat.Bestand.Gew * aDiff / 1000.0) / Mat.Bestand.Menge, 2);


  FOR Erx # RecLink(204,200,14,_recFirst)
  LOOP Erx # RecLink(204,200,14,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Mat.A.Entstanden=0) then CYCLE;

    vBuf200 # RekSave(200);
    vBuf204 # RekSave(204);

    vDiff   # aDiff;
    vDiffPM # aDiffPM;

    if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) then begin
      if (_GetKombiEKSumme(Mat.A.Entstanden, var vWert, var vWertMEH)=false) then begin
        RekRestore(vBuf200);
        RekRestore(vBuf204);
        RETURN false;
      end;
      Erx # Read(Mat.A.Entstanden, _recSingleLock, 0, true);
      if (Erx<200) then begin
        RekRestore(vBuf200);
        RekRestore(vBuf204);
        RETURN false;
      end;
      vDiff # Rnd(vWert / vGew * 1000.0,2);
      DivOrNull(vDiffPM, vWertMEH, vMenge, 2);

      vDiff   # vDiff - Mat.EK.Preis;
      vDiffPM # vDiffPM - Mat.Ek.PreisProMEH;
    end
    else begin
      Erx # Read(Mat.A.Entstanden, _recSingleLock, 0, true);
      if (Erx<200) then begin
        RekRestore(vBuf200);
        RekRestore(vBuf204);
        RETURN false;
      end;
    end;

    vWeiter   # n;
    vNachFix  # n;

    // STATISCH/KORREKTURBUCHUNG
    if (aNachFix) then begin

      // Eintrag in Bestandbuch anlegen...
      Bestandsbuch(0, 0.0, 0.0, -vDiff, -vDiffPM, '>'+aGrund, aDat, aTim, aTyp, aT1, aT2, aT3, aT4);

    end
    // DYNAMISCH
    else begin

      vOK # Y;
      // Bestandsbuch loopen...
      FOR Erx # RecLink(202,200,12,_recFirst)
      LOOP Erx # RecLink(202,200,12,_recNext)
      WHILE (Erx<=_rLocked) and (vOK) do begin
        if (Mat.B.FixYN) then vOK # n;
      END;


      // Karte kann verändert werden...
      if (vOK) then begin
        Mat.EK.Preis        # Mat.EK.Preis + vDiff;//vBuf200->Mat.EK.Preis;
        Mat.EK.PreisProMEH  # MAt.EK.PreisProMEH + vDiffPM;
        vWeiter # Y;
      end
      // Karte ist nicht einfach änderbar...
      else begin

        // Eintrag in Bestandbuch anlegen...
        Mat_Data:Bestandsbuch(0, 0.0, 0.0, -vDiff,-vDiffPM, '>'+aGrund, aDat, aTim, '');
        vWeiter   # Y;
        vNachFix  # y;
      end;
    end;

    Erx # Mat_data:Replace(_RecUnlock,'AUTO');
    if (erx<>_rOK) then begin
      RekRestore(vBuf200);
      RekRestore(vBuf204);
      RETURN false;
    end;


    if (vWeiter) then
      VererbeNeubewertung(vDiff, vDiffPM, aGrund, aDat, aTim, n, aTyp, aT1, aT2, aT3, aT4);

    RekRestore(vBuf200);
    RekRestore(vBuf204);

  END;

  RETURN true;
end;


//========================================================================
//  ReCalcAll
//
//========================================================================
sub RecalcAll() : logic;
local begin
  Erx : int;
end;
begin

  Erx # Recread(200,1,_recfirst);   // Material loopen
  WHILE (Erx<=_rLocked) do begin

    // Kosten neu summieren
    Mat_A_Data:AddKosten();

    // Reservierungen neu summieren
    Erx # RecRead(200,1,_recLock);
    if (Erx<>_rOK) then RETURN false;
    Mat.Reserviert.Stk    # 0;
    Mat.Reserviert.Gew    # 0.0;
    Mat.Reserviert.Menge  # 0.0;
    Mat.Reserviert2.Stk   # 0;
    Mat.Reserviert2.Gew   # 0.0;
    Mat.Reserviert2.Meng  # 0.0;
    Erx # RecLink(203,200,13,_recFirst);    // reservierungen loopen
    WHILE (Erx<=_rLocked) do begin
      Mat.Reserviert.Stk      # Mat.Reserviert.Stk + "Mat.R.Stückzahl";
      Mat.Reserviert.Gew      # Mat.Reserviert.Gew + Mat.R.Gewicht;
      Mat.Reserviert.Menge    # Mat.Reserviert.Menge + Mat.R.Menge;
      if ("Mat.R.Trägertyp"='') and (Mat.R.Auftragsnr<>0) then begin
        Mat.Reserviert2.Stk   # Mat.Reserviert2.Stk + "Mat.R.Stückzahl";
        Mat.Reserviert2.Gew   # Mat.Reserviert2.Gew + Mat.R.Gewicht;
        Mat.Reserviert2.Meng  # Mat.Reserviert2.Meng + Mat.R.Menge;
      end;
      Erx # RecLink(203,200,13,_recnext)
    END;
    Erx # Replace(_RecUnlock,'AUTO');
    if (Erx<>_rOK) then RETURN false;

    Erx # Recread(200,1,_recNext);
  END;

end;


//========================================================================
//  SetMatStatus // TM
//
//========================================================================
sub SetMatStatus(
 aMatNr   : int;
 aStatus  : int) : int;
local begin
  Erx : int;
end;
begin
  Erx # Recread(200,1,_recSingleLock);
  if (Erx<>_rOK) then RETURN 201;

  TRANSON;

  Ptd_Main:Memorize(200);

  SetStatus(aStatus);
  Erx # Replace(_RecUnlock,'STA');
  if (Erx<>_rOK) then begin
    PtD_Main:Forget(200);
    TRANSBRK;
    RETURN 200;
  end;


  PtD_Main:Compare(200);
  TRANSOFF;
End;


//========================================================================
//  SetLoeschmarker // TM
//
//========================================================================
sub SetLoeschmarker(
  aLoeschmarker : alpha;
  opt aGrund    : alpha);
begin

  If (aLoeschmarker = '*') then begin
    "Mat.Löschmarker"     # '*';
    "Mat.Lösch.Datum"     # TODAY;
    "Mat.Lösch.Zeit"      # NOW;
    "Mat.Lösch.User"      # gUsername;
    "Mat.Lösch.Grund"     # aGrund;
  end
  else if (aLoeschmarker = '') then begin
    "Mat.Löschmarker"     # '';
    "Mat.Lösch.Datum"  # 0.0.0
    "Mat.Lösch.Zeit"   # 00:00;
    "Mat.Lösch.User"   # ''
  End;

End;


//========================================================================
//  Repair_ResetLoeschdatum           ST 07.08.2009 ProjektPos 1133/145
//    Durchsucht alle nicht gelöschten Materialien und setzt die
//    Löschdaten neu
//========================================================================
sub Repair_ResetLoeschdatum()
local begin
  Erx   : int;
  vFlag : int;
end
begin

  todo('Um ein Protokoll über die geänderten Materialkarten zu bekommen, muss man als Entwickler angemeldet sein!');
  debug('Repair_ResetLoeschdatum  START');
  debug('-----------------------------------------');

  vFlag # _RecFirst;   // Material loopen
  WHILE (RecRead(200,1,vFlag) <= _rLocked) do begin
    vFlag # _RecNext;

    // Nur Materialien im Bestand beachten
    if ("Mat.Löschmarker" = '*') then
      CYCLE;

    // Prüfen, ob das Material trotz Bestand Löschdaten gesetzt hat
    if ("Mat.Lösch.Datum" <> 0.0.0) then begin
      debug('Mat: ' + AInt(Mat.Nummer));

      // Material sperren
      if (RecRead(200,1,_RecLock) = _rLocked) then begin
        debug('FEHLER: Material '+AInt(Mat.Nummer) + ' konnte nicht gesperrt werden');
        CYCLE;
      end;

      // Ändern und Speichern
      "Mat.Lösch.Datum"  # 0.0.0
      "Mat.Lösch.Zeit"   # 00:00;
      "Mat.Lösch.User"   # ''
      Erx # RekReplace(200,_recUnlock,'AUTO');
      if (Erx <> _rOk) then
        debug('FEHLER: Material '+AInt(Mat.Nummer) + ' konnte nicht zurückgespeichert werden');

    end;

  END; // Material loopen

  debug('-----------------------------------------');
  debug('Repair_ResetLoeschdatum  ENDE');
  debug('-----------------------------------------');

  todo('Das Protokoll des Laufes wurde in die Debugdatei geschrieben');
end; // sub Repair_ResetLoeschdatum()


//========================================================================
//  SetInventur // ST 2010-06-2010
//    Setzt die Inventurdaten und prüft in diesem Schritt, ob aus dem Material
//    eine Restkarte entstanden ist und ändert diese gleich mit
//========================================================================
sub SetInventur(
  aMaterial       : int;
  aLagerplatz     : alpha;
  aInventurDatum  : date;
  aMitMengen      : logic;
  opt aStk        : int;    // neuer Bestand
  opt aGew        : float;  // neuer Bestand
  opt aMenge      : float;  // neuer Bestand
  opt aFehlte     : logic;  // Menge als kompletten Zugang ansehen
  opt aAusDatei   : int;    // z.B. ARTINVENTUR = 259
  ) : logic;
local begin
  Erx       : int;
  v200    : handle;
  v204    : handle;
  vNetto  : float;
  vBrutto : float;
  vFak    : float;
  vUmlag  : logic;
end
begin

  // Parameter checken
  if (aMaterial <= 0) then RETURN false;
// 30.11.2015 AH  if (aLagerplatz = '') then RETURN false;

  // Geladene Materialkarte speichern
  v200 # RekSave(200);
  v204 # RekSave(204);

  // Material lesen
  Mat.Nummer  # aMaterial;
  Erx # RecRead(200,1,_recSingleLock);
  if (Erx>=_rLockeD) then begin
    RekRestore(v200);
    RekRestore(v204);
    RETURN false;
  end;

  // Inventurdaten setzen
  if (aLagerplatz<>'') and (Mat.Lagerplatz<>aLagerplatz) then begin
    vUmlag # true;
    Mat.Lagerplatz    # aLagerplatz;
  end;
  Mat.Inventurdatum # aInventurdatum;
  RunAFX('Mat.Inventur.Set',aint(aAusDatei));

  // 16.11.2015
  if (aMitMengen) then begin
    if (aFehlte) then begin   // als komplett neuer Zugang ansehen?
      Bestandsbuch(Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, 0.0, 0.0, Translate('Inventur'), aInventurDatum, 0:0, '');
    end
    else begin
      aStk    # aStk - Mat.Bestand.Stk;
      aGew    # aGew - Mat.Bestand.Gew;
      aMenge  # aMenge - Mat.Bestand.Menge;
      if (aStk<>0) or (aMenge<>0.0) or (aGew<>0.0) then begin
        if (Mat.Bestand.Gew<>0.0) then
          vFak # (Mat.Bestand.Gew + aGew) / Mat.Bestand.Gew;
        Mat.Bestand.Stk     # Mat.Bestand.Stk + aStk;
        Mat.Bestand.Menge   # Mat.Bestand.Menge + aMenge;
        Mat.Bestand.Gew     # Mat.Bestand.Gew + aGew;
        Mat.Gewicht.Netto   # Rnd(Mat.Gewicht.Netto * vFak, Set.Stellen.Gewicht);
        Mat.Gewicht.Brutto  # Rnd(Mat.Gewicht.Brutto * vFak, Set.Stellen.Gewicht);
  //    Mat.Bestand.Gew     # 0.0;  // freimachen zur Berechnung
        Bestandsbuch(aStk, aGew, aMenge, 0.0, 0.0, Translate('Inventur'), aInventurDatum, 0:0, '');
      end;
    end;
  end;
  Erx # Mat_data:Replace(_recunlock,'AUTO');  // 26.08.2014 war RekReplace(200,_RecUnlock,'AUTO');
  if (Erx <> _rOK) then begin
    RekRestore(v200);
    RekRestore(v204);
    RETURN false;
  end;

  // 17.01.2017 AH:
  if (vUmlag) then begin
    Erx # RecLink(506,200,20,_recFirst);  // Wareneingang holen
    if (Erx<=_rLocked) then begin
      Erx # RecRead(506,1,_RecLock);
      if (erx=_rOK) then begin
        Ein.E.Lagerplatz # Mat.Lagerplatz;
        Erx # RekReplace(506);
      end;
      if (Erx <> _rOK) then begin   // 2022-07-05 AH DEADLOCK
        RekRestore(v200);
        RekRestore(v204);
        RETURN false;
      end;
    end;
  end;


  // Wenn Material gelöscht und daraus eine Restkarte entstanden ist,
  // dann Inventurdaten an Restkarte vererben
  if ("Mat.Löschmarker" = '*') then begin
    // Aktionen durchgehen und nach Restkarte suchen
    Erx # RecLink(204,200,14,_recFirst);
    WHILE (Erx<=_rLocked) DO BEGIN
      // ist Restkarte?
      if (Mat.A.Aktionstyp = c_Akt_BA_Rest) then begin
        // dann updaten...

        // Material lesen
        Mat.Nummer # Mat.A.Entstanden;
        Erx # RecRead(200,1,_recSingleLock);
        if (Erx>=_rLockeD) then begin
          RekRestore(v200);
          RekRestore(v204);
          RETURN false;
        end;

        // Inventurdaten setzen
        if (aLagerplatz<>'') then
          Mat.Lagerplatz    # aLagerplatz;
        Mat.Inventurdatum # aInventurdatum;
        RunAFX('Mat.Inventur.Set',aint(aAusDatei));

        // 16.11.2015
        if (aMitMengen) then begin
          if (aFehlte) then begin   // als komplett neuer Zugang ansehen?
            Bestandsbuch(Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, 0.0, 0.0, Translate('Inventur'), aInventurDatum, 0:0, '');
          end
          else begin
            aStk    # aStk - Mat.Bestand.Stk;
            aGew    # aGew - Mat.Bestand.Gew;
            aMenge  # aMenge - Mat.Bestand.Menge;
            if (aStk<>0) or (aMenge<>0.0) or (aGew<>0.0) then begin
              if (Mat.Bestand.Gew<>0.0) then
                vFak # (Mat.Bestand.Gew + aGew) / Mat.Bestand.Gew;
              Mat.Bestand.Stk     # Mat.Bestand.Stk + aStk;
              Mat.Bestand.Menge   # Mat.Bestand.Menge + aMenge;
              Mat.Bestand.Gew     # Mat.Bestand.Gew + aGew;
              Mat.Gewicht.Netto   # Rnd(Mat.Gewicht.Netto * vFak, Set.Stellen.Gewicht);
              Mat.Gewicht.Brutto  # Rnd(Mat.Gewicht.Brutto * vFak, Set.Stellen.Gewicht);
        //    Mat.Bestand.Gew     # 0.0;  // freimachen zur Berechnung
              Bestandsbuch(aStk, aGew, aMenge, 0.0, 0.0, 'Inventur', aInventurDatum, 0:0, '');
            end;
          end;
        end;

        // Speichern
        Erx # Mat_data:Replace(_recunlock,'AUTO');  // 26.08.2014 war RekReplace(200,_RecUnlock,'AUTO');
        if (Erx <> _rOK) then begin
          RekRestore(v200);
          RekRestore(v204);
          RETURN false;
        end;

        // Ein Material kann nur einmal eingesetzt sein, deswegen hier Ende
        BREAK;

      end;

      Erx # RecLink(204,200,14,_recNext);
    END;
  end;

  // Restore und fertig
  RekRestore(v200);
  RekRestore(v204);
  RETURN true;

End; // sub SetInventur


//========================================================================
//  ClearAnalyse
//
//========================================================================
SUB ClearAnalyse(aZwei : logic);
local begin
  vA  : alpha;
  vF  : float;
end;
begin
  if (aZwei) then vA # '2'
  else vA # '1';
  vF # 0.0;
  FldDefByName('Mat.Streckgrenze'+vA,vF);
  FldDefByName('Mat.Streckgrenze'+vA,vF);
  FldDefByName('Mat.StreckgrenzeB'+vA,vF);
  FldDefByName('Mat.Zugfestigkeit'+vA,vF);
  FldDefByName('Mat.ZugfestigkeitB'+vA,vF);
  FldDefByName('Mat.DehnungA'+vA,vF);
  FldDefByName('Mat.DehnungB'+vA,vF);
  FldDefByName('Mat.DehnungC'+vA,vF);
  FldDefByName('Mat.RP02_V'+vA,vF);
  FldDefByName('Mat.RP02_B'+vA,vF);
  FldDefByName('Mat.RP10_V'+vA,vF);
  FldDefByName('Mat.RP10_B'+vA,vF);
  FldDefByName('Mat.Körnung'+vA,vF);
  FldDefByName('Mat.KörnungB'+vA,vF);
  FldDefByName('Mat.HärteA'+vA,vF);
  FldDefByName('Mat.HärteB'+vA,vF);
  FldDefByName('Mat.RauigkeitA'+vA,vF);
  FldDefByName('Mat.RauigkeitB'+vA,vF);
  FldDefByName('Mat.RauigkeitC'+vA,vF);
  FldDefByName('Mat.RauigkeitD'+vA,vF);
  FldDefByName('Mat.Chemie.C'+vA,vF);
  FldDefByName('Mat.Chemie.Si'+vA,vF);
  FldDefByName('Mat.Chemie.Mn'+vA,vF);
  FldDefByName('Mat.Chemie.P'+vA,vF);
  FldDefByName('Mat.Chemie.S'+vA,vF);
  FldDefByName('Mat.Chemie.Al'+vA,vF);
  FldDefByName('Mat.Chemie.Cr'+vA,vF);
  FldDefByName('Mat.Chemie.V'+vA,vF);
  FldDefByName('Mat.Chemie.Nb'+vA,vF);
  FldDefByName('Mat.Chemie.Ti'+vA,vF);
  FldDefByName('Mat.Chemie.N'+vA,vF);
  FldDefByName('Mat.Chemie.Cu'+vA,vF);
  FldDefByName('Mat.Chemie.Ni'+vA,vF);
  FldDefByName('Mat.Chemie.Mo'+vA,vF);
  FldDefByName('Mat.Chemie.B'+vA,vF);
  FldDefByName('Mat.Chemie.Frei1.'+vA,vF);
  FldDefByName('Mat.Mech.Sonstiges'+vA,'');
end;


//========================================================================
//  Foreach_BestandRueckwirkend
//
//========================================================================
sub Foreach_BestandRueckwirkend(
  aStichtag : date;
  aProc     : alpha) : int;
local begin
  Erx         : int;
  vDate       : alpha;
  vQ          : alpha(4000);
  vSel        : int;
  vSelName    : alpha;
  vErr        : int;
end;
begin

  if ( aStichtag = 0.0.0 ) then vDate # '0.0.0' else vDate # CnvAd(aStichtag);

  // BESTAND-Selektion
  vQ  # '';
//vQ # '(Mat.Nummer=4640) AND ';
  vQ  # vQ + '( Mat.Ausgangsdatum >= ' + vDate + ' OR Mat.Ausgangsdatum = 0.0.0 )';
  vQ  # vQ + ' AND ( Mat.Eingangsdatum < ' + vDate + ' AND Mat.Eingangsdatum > 0.0.0 )';

  vSel # SelCreate( 200, 1 );
  Erx # vSel->SelDefQuery( '', vQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  FOR Erx # RecRead(200,vSel, _recFirst)
  LOOP Erx # RecRead(200,vSel, _RecNext)
  WHILE (Erx<=_rLocked) and (vErr=0) do begin
    Mat_B_Data:BewegungenRueckrechnen(aStichtag);
    vErr # Call(aProc, aStichtag);   // mit Errorwert
  END;

  SelClose(vSel);
  SelDelete(200, vSelName);
  vSel # 0;

  if (vErr<>0) then RETURN vErr;


  // ABLAGE-Selektion
  vQ  # '';
//vQ # '("Mat~Nummer"=4640) AND ';
  vQ  # vQ + '( "Mat~Ausgangsdatum" >= ' + vDate + ' OR "Mat~Ausgangsdatum" = 0.0.0 )';
  vQ  # vQ + ' AND ( "Mat~Eingangsdatum" < ' + vDate + ' AND "Mat~Eingangsdatum" > 0.0.0 )';

  vSel # SelCreate( 210, 1 );
  Erx # vSel->SelDefQuery( '', vQ );
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  FOR Erx # RecRead(210,vSel, _recFirst)
  LOOP Erx # RecRead(210,vSel, _RecNext)
  WHILE (Erx<=_rLocked) and (vErr=0) do begin
    RecBufCopy(210,200);
    Mat_B_Data:BewegungenRueckrechnen(aStichtag);
    vErr # Call(aProc, aStichtag);   // mit Errorwert
  END;

  SelClose(vSel);
  SelDelete(210, vSelName);
  vSel # 0;


  if (vErr<>0) then RETURN vErr;

  RETURN _rOK;
end;


//========================================================================
// StatistikBuchen
//
//========================================================================
Sub StatistikBuchen(
  opt a200  : int;
  opt aInit : logic;
  opt aDel  : logic;
) : int;
local begin
  Erx       : int;
  vLocal200 : logic;
  vTyp      : alpha;
  vUmbuchen : logic;
  vDat      : date;
  vVorgang  : alpha;

  vAdr1     : int;
  vWert1    : float;
  vStk1     : int;
  vGew1     : float;
  vMenge1   : float;
  vKonto1   : alpha;
  vKonto2   : alpha;

  vAdr2     : int;
  vWert2    : float;
  vStk2     : int;
  vGew2     : float;
  vMenge2   : float;
  vKurs2    : float;

  vDifWert  : float;
  vDifStk   : int;
  vDifGew   : float;
  vDifMenge : float;
  vDif      : logic;
end;
begin

//RETURN; // DEAKTIVIERT
//debug('');
  if (Mat.Status>=c_Status_Bestellt) or (Mat.Status=c_Status_bestellt_Sperr) or (Mat.Status=0) then RETURN _rOK;    // 26.07.2019

  vDat # today;

  if (aInit) then vDat # "Mat.Eingangsdatum";

  vVorgang # aint(Mat.Nummer);

//debugx('Mat ='+aint(Mat.Nummer)+' '+anum(Mat.Bestand.Gew,0)+'+'+anum(Mat.Bestellt.Gew,0)+' '+aint(Mat.Status));
  if (a200=0) then vTyp # '-'
  else begin
//debugx('BufferMat ='+aint(a200->Mat.Nummer)+' '+anum(a200->Mat.Bestand.Gew,0)+'+'+anum(a200->Mat.Bestellt.Gew,0)+' '+aint(a200->Mat.Status));
    if (a200->"Mat.Löschmarker"='') then vTyp # 'B'
    else vTyp # 'G';
    // Sonderfall: WE 26.07.2019
    //if (a200->Mat.Nummer=Mat.Nummer) then vTyp # '-';
      if (a200->Mat.Status>=c_Status_Bestellt) or (a200->Mat.Status=c_Status_bestellt_Sperr) or (a200->Mat.Status=0) then vTyp # '-';
  end;

  if (aDel)  then vTyp # vTyp + '-'
  else if ("Mat.Löschmarker"='') then vTyp # vTyp + 'B'
  else vTyp # vTyp + 'G';


  if (a200=0) then begin
    vLocal200 # true;
    a200 # RecBufCreate(200);
    RecBufCopy(200,a200);
  end;

// 26.07.2019  vUmbuchen # (a200->Mat.EigenmaterialYN<>Mat.EigenmaterialYN);

  // -----------12345678901234567890123456789012----
  if (a200->Mat.EigenmaterialYN) then
    vKonto1    # 'MAT_EIGEN_BESTAND'
  else
    vKonto1    # 'MAT_FREMD_BESTAND';

  if (Mat.EigenmaterialYN) then
    vKonto2    # 'MAT_EIGEN_BESTAND'
  else
    vKonto2    # 'MAT_FREMD_BESTAND';

  vAdr1 # Set.EigeneAdressnr;
  if (a200->Mat.EigenmaterialYN=false) then begin
    if (Adr.Lieferantennr<>a200->Mat.Lieferant) then Erx # Reklink(100,a200,4,_recFirst);   // Lieferant holen
    vAdr1 # Adr.Nummer;
  end;
  vAdr2 # Set.EigeneAdressnr;
  if (Mat.EigenmaterialYN=false) then begin
    if (Adr.Lieferantennr<>Mat.Lieferant) then Erx # Reklink(100,200,4,_recFirst);   // Lieferant holen
    vAdr2 # Adr.Nummer;
  end;


  vUmbuchen # (vAdr1<>vAdr2) or (vKonto1<>vKonto2) or
            (a200->Mat.Warengruppe<>Mat.Warengruppe) or
            (a200->"Mat.Güte"<>"Mat.Güte");
//if (vUmbuchen) then debugx('UMBUCHEN weil '+aint(vAdr1)+'<>'+aint(vAdr2)+' or '+vKonto1+'<>'+vKonto2+' or '+aint(a200->Mat.Warengruppe)+'<>'+aint(Mat.Warengruppe)+' or '+a200->"Mat.Güte"+'<>'+"Mat.Güte");

/*
Vorher,   Jetzt     =Eingang    =Rest   Typ (Bestand, Storno, Gelöscht)
-,-       ok, 10    = +10       +10     -B*
ok, 10    ok, 13    = +3        +3      BB*
ok, 13    ok, 10    = -3        -3      BB*

-,-       del, 10   = +10       nix     -G*
del, 10   del, 13   = +3        nix     GG*
del, 13   del, 10   = -3        nix     GG*

del, 10   ok, 10    = nix       +10     GB*
del, 10   ok, 13    = +3        +13     GB*
del, 13   ok, 10    = -3        +10     GB*

ok, 10    del, 10   = nix       -10     BG
ok, 10    del, 13   = +3        -10     BG
ok, 13    del, 10   = -3        -13     BG
*/
  // Stack(aTyp, aAdrNr, aVert, aAufArt, aWGr, aArtNr, aGuete, aKst, aWertW1, aStk, aGew, aMenge, aMEH);

  // MATERIALBESTAND ---------------------------------------------------------------------------

  vStk1   # a200->Mat.Bestand.Stk;
  vGew1   # a200->Mat.Bestand.Gew;
  vMenge1 # a200->Mat.Bestand.Menge;
  vWert1  # Rnd(vGew1 * a200->Mat.EK.Effektiv / 1000.0, 2);

  vStk2   # Mat.Bestand.Stk;
  vGew2   # Mat.Bestand.Gew;
  vMenge2 # Mat.Bestand.Menge;
  vWert2  # Rnd(vGew2 * Mat.EK.Effektiv / 1000.0, 2);

  vDifStk   # vStk2 - vStk1;
  vDifGew   # vGew2 - vGew1;
  vDifMenge # vMenge2 - vMenge1;
  vDifWert  # vWert2 - vWert1;
  vDif # (vDifStk<>0) or (vDifGew<>0.0) or (vDifMenge<>0.0) or (vDifWert<>0.0);

//debugx('Statistik Matdif:'+anum(vDifGew,0)+'kg, typ='+vTyp);
//  if (vDif=false) then RETURN;    // 25.07.2019

  case vTyp of
    '-B', 'GB' : begin  // (wie) neu erfasst
      OSt_Data:Stack('+', vKonto2, vVorgang, vAdr2, 0, 0, Mat.Warengruppe, '', "Mat.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Mat.MEH);
    end;

    'BB' : begin  //  verändert mit ggf. Umbuchung
      if (vUmbuchen) then begin
        OSt_Data:Stack('-', vKonto1, vVorgang, vAdr1, 0, 0, a200->Mat.Warengruppe, '', a200->"Mat.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a200->Mat.MEH);
        OSt_Data:Stack('+', vKonto2, vVorgang, vAdr2, 0, 0, Mat.Warengruppe, '', "Mat.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Mat.MEH);
      end
      else begin
        if (vDif) then
          OSt_Data:Stack('', vKonto1, vVorgang, vAdr2, 0, 0, Mat.Warengruppe, '', "Mat.Güte", 0, vDat, vDifWert, vDifStk, vDifGew, vDifMenge, Mat.MEH);
      end
    end;

    'B-', 'BG' : begin  // löschen
      OSt_Data:Stack('-', vKonto1, vVorgang, vAdr1, 0, 0, a200->Mat.Warengruppe, '', a200->"Mat.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a200->Mat.MEH);
    end;

  end;


  if (vLocal200) then RecBufDestroy(a200);

//debug('');
  RETURN _rOK;
end;


//========================================================================
//  Call Mat_data:RepairT
//      Ändert die MEH von T auf KG bei Karten ohne Artikelzuordnung
//========================================================================
Sub RepairT();
local begin
  Erx : int;
end;
begin
  FOR Erx # RecRead(200,1,_recFirst)
  LOOP Erx # RecRead(200,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.MEH<>'t') then CYCLE;
    if (Mat.Strukturnr<>'') then begin
      if (Wgr.Nummer<>Mat.Warengruppe) then
        Erx # RekLink(819,200,1,_RecFIrst); // Warengruppe holen
      if (Wgr.Dateinummer<>209) and (Wgr.Dateinummer<>259) and (Wgr.Dateinummer=250) then CYCLE;
    end;

    RecRead(200,1,_RecLock);
    Mat.MEH               # 'kg';
    Mat.Bestand.Menge     # Mat.Bestand.Gew;
    "Mat.Verfügbar.Menge" # "Mat.Verfügbar.Gew";
    Mat.EK.PreisProMEH    # Mat.EK.Preis;
    Mat.KostenProMEH      # Mat.Kosten;
    Mat.EK.EffektivProME  # Mat.EK.Effektiv;
    RekReplace(200);

  END;
  Msg(999998,'',0,0,0);
end;


//========================================================================
//  sub WEWerksnummer(aLieferantennr : int; aWerksnr : alpha; aLagerplatz : alpha)
//      Bucht einen Wareneingang über die Externe Werksnummer in
//========================================================================
sub WebApp_WE_Werksnummer(
  aLieferantennr  : int;
  aWerksnr        : alpha;
  aLagerplatz     : alpha) : logic
local begin
  Erx       : int;
end
begin

  // Lieferant lesen
  Adr.Lieferantennr # aLieferantennr;
  Erx # RecRead(100,3,0);
  if (Erx > _rMultikey) then begin
    Error(99,'Lieferant nicht gefunden')
    RETURN false;
  end;

  // Gesperrt als Lieferant?
  aWerksnr # StrAdj(aWerksnr,_StrBegin | _StrEnd);

  // Werksnummer für Lieferanten suchen
  Mat.Werksnummer # aWerksnr;
  FOR   Erx # RecRead(200,8,0);
  LOOP  Erx # RecRead(200,8,_RecNext);
  WHILE Erx = _rMultikey AND (Mat.Werksnummer = aWerksnr) DO BEGIN
    if (Mat.Lieferant = Adr.Lieferantennr) then begin
      Erx # _rOK;
      BREAK;
    end;
  END;


  // Material nicht in Material gefunden, dann in Sammelwareneingang suchen
  if (Erx <> _rOK) then begin

    // Sammelwareneingang lesen
    SWe.P.Lieferantennr # Adr.Lieferantennr;
    SWe.P.Werksnummer   # aWerksnr;
    FOR   Erx # RecRead(621,6,0);           // TODO: hier dann Schlüssel für Lieferantennr + Werknummer
    LOOP  Erx # RecRead(621,6,_RecNext);
    WHILE (Erx = _rMultikey) AND (Mat.Werksnummer = aWerksnr) DO BEGIN
      if (SWe.P.AvisYN) AND (SWe.P.EingangYN = false) AND ("SWe.P.Löschmarker" = '')  then begin
        Erx # _rOK;
        BREAK;
      end;
    END;
    if (Erx <> _rOK) then begin
      // Keine Sammelwareneingangsposition gefunden
      Error(99,'Keine gültige Lieferavisierung gefunden');
      RETURN false;
    end;

    // ----------------------------------------------------
    // Eingang auf Sammelwareneingangavis buchen
    TRANSON;
    SWe.P.Anlage.User   # gUserName;
    REPEAT
      SWe.P.Eingangsnr    # SWe.P.Eingangsnr + 1;
      SWe.P.Anlage.Datum  # Today;
      SWe.P.Anlage.Zeit   # Now;
      SWe.P.Lagerplatz    # aLagerplatz;
      Erx # RekInsert(gFile,0,'MAN');
    UNTIl (erx=_rOK);

    if (SWe_P_Data:Verbuchen(y)=false) then begin
      TRANSBRK;
      Error(99,'Fehler beim Verbuchen!');
      RETURN false;
    end;
    TRANSOFF;

  end
  else
  if (Mat.Status = c_Status_EKVSB) then begin

    // ---------------------------------------------------------------------------------
    // Material wurde im Bestand gefunden
    // ---------------------------------------------------------------------------------

    // Bei VSB/EK den Eingang melden

    // Material ist VSB EK, dann Eingang melden
    Error(99,'NOCH NICHT IMPLEMENTIERT');

    RETURN false;

  end else begin
    //  ---------------------------------------------------------------------------------
    //    Material hat nicht Status VSB/EK, dann handelt es sich wohl um eine Umlagerung
    //      Umlagerung über diesen Weg geht nur bei Coils!!!

    TRANSON;

    Mat.Werksnummer # aWerksnr;
    FOR   Erx # RecRead(200,8,0);
    LOOP  Erx # RecRead(200,8,_RecNext);
    WHILE (Erx = _rMultikey) AND
            (Mat.Werksnummer = aWerksnr) AND
              (Mat.Lieferant = Adr.Lieferantennr) DO BEGIN

      // Nur Restkarten und Einsatzmaterialen erlauben
      if (Mat.Nummer <> Mat.Ursprung) AND ((Mat.Status < c_Status_BAG) OR  (Mat.Status >c_Status_bisBAG)) then
        CYCLE;

      Erx # RecRead(200,1, _RecSingleLock);
      if (Erx <> _rOK) then begin
        TRANSBRK;
        Error(99,'Material konnte nicht gesperrt werden');
        RETURN false;
      end;

      Mat.Lagerplatz # aLagerplatz;

      Erx # Mat_Data:Replace(_RecUnlock, 'MAN');
      If (Erx <> _rOK) then begin
        TRANSBRK;
        Error(99,'Material konnte nicht umgelagert werden');
        RETURN false;
      end;

    END;

    TRANSOFF;

  end;


  // Alles IO
  RETURN true;

end;



//========================================================================
//  sub get1zu1FMAktuell(aMat : int) : int;
//  Ermittelt anhand der übergebenen Materiannummer die Ein- und Weiter-
//  verarbeitungen innerhalb eines Betriebsauftrages.
//
//  Sollte ein Einsatz mehrere, nicht stornierte, Wiedereinsätze haben,
//  wird 0 zurückgegeben.
//
//  Wird das das Material 1 zu 1 durch einen BAG verwogen, dann wird die
//  letzte vergebene Materialnr der BAG Kette zurückgegeben.
//
//========================================================================
sub lies1zu1FMAktuell(aMat : int) : int;
local begin
  Erx       : int;
  v701In    : int;
  v701FmOut : int;

  vNachfolger : int;
  vAnzNachfolger : int;

  vNachBag : int;
  vNAchPos : int;
  vNachID  : int;
end
begin

  // Einsatz lesen
  Bag.IO.Materialnr # aMat;
  Erx # RecRead(701,9,0);
  if (Erx > _rMultiKey) then    // Einsatz nicht gefunden, dann ist Mat ok
    RETURN aMat;

  // Entstandene Ausbringungen prüfen
  v701In # RekSave(701);
  Bag.IO.vonBAG       # BAG.IO.NachBAG;
  BAG.IO.VonPosition  # BAG.IO.NachPosition;
  BAG.IO.VonID        # BAG.IO.ID;
  FOR   Erx # RecRead(701,6,0);
  LOOP  Erx # RecRead(701,6,_RecNext);
  WHILE (Erx <= _rMultikey)  AND (vAnzNachfolger <= 1) AND
    (Bag.IO.vonBAG       = v701In->BAG.IO.NachBAG  AND
    BAG.IO.VonPosition  = v701In->BAG.IO.NachPosition AND
    BAG.IO.VonID        = v701In->BAG.IO.ID)
  DO BEGIN
    // Stornierte Verwiegung??
    if (BAG.IO.NachBAG = 0) then
      CYCLE;

    if (vAnzNachfolger = 0) then begin
      // 1. Wiederiensatz gefunden
      v701FmOut # RekSave(701);
      inc(vAnzNachfolger);
    end else begin
      // 2. Verwiegung gefunden -> keine weitere Ermittlungen möglich
      inc(vAnzNachfolger);
    end;
  END;

  RecBufDestroy(v701In);

  if (vAnzNachfolger = 1) AND (v701FmOut <> 0) then begin
    // Genau einen Neueinsatz gefunden, dann diesen auf weitere Einsätze prüfen
    RekRestore(v701FmOut);
    RETURN lies1zu1FMAktuell(BAG.IO.Materialnr);   // hier Rekursion
  end else begin
    // Kein nachfolgenden Einsatz gefunden
    if (vAnzNachfolger = 0) then
      RETURN aMat;

    // Mehr als Einsatz, abräumen und Fehler
    if (v701FmOut <> 0) then
      RecBufDestroy(v701FmOut);

    if (vAnzNachfolger > 1) then
      RETURN 0;
  end;


end;


//========================================================================
sub _RenameMatInDatei(
  aFldName  : alpha;
  aKey      : int;
  aMat1     : int;
  aMat2     : int) : alpha
local begin
  Erx       : int;
  vDatei    : int;
  vTds      : int;
  vFld      : int;
  vBuf      : int;
end;
begin

  if (aMat1=aMat2) then RETURN '';

  if (FldInfoByName(aFldName, _FldExists)<=0) then begin
    RETURN 'Unbekanntes Feld '+aFldName;
  end;
  vDatei # FldInfoByName(aFldName, _FldFileNumber);
  vTds   # FldInfoByName(aFldName, _FldSbrNumber);
  vFld   # FldInfoByName(aFldName, _FldNumber);

  // A wird B ----------------------------------
  vBuf # RekSave(vDatei);
  RecBufClear(vDatei);
  FldDef(vDatei, vTds, vFld, aMat1);
  Erx # RecRead(vDatei,aKey,0);
  WHILE (Erx<=_rMultikey) and (FldInt(vDatei, vTds, vFld)=aMat1) do begin

//debugx('KEY'+aint(vDatei)+' '+aFldName+' '+aint(aMat1)+' -> '+aint(aMat2));
    Erx # RecRead(vDatei,1,_RecLock);
    if (Erx=_ROK) then begin
      FldDef(vDatei, vTds, vFld, aMat2);
      Erx # RekReplace(vDatei);
    end;
    if (erx<>_rOK) then begin
      RekRestore(vBuf);
      RETURN 'Satz nicht änderbar:'+aFldName;
    end;
    FldDef(vDatei, vTds, vFld, aMat1);
    Erx # RecRead(vDatei,aKey,0);
  END;
  RekRestore(vBuf);
  RETURN '';
end;


//========================================================================
//========================================================================
Sub Rename(
  aMat1       : int;
  aMat2       : int;
  var aInvDat : date) : alpha;
local begin
  Erx     : int;
  vErr    : alpha(1000);
end;
begin
// BESSER "TAUSCHEMATS" nutzen  !!!
  REPEAT
    vErr # _RenameMatInDatei('Mat.A.Materialnr', 1, aMat1, aMat2);
    if (vErr<>'') then BREAK;
    vErr # _RenameMatInDatei('Mat.AF.Nummer', 1, aMat1, aMat2);
    if (vErr<>'') then BREAK;
    vErr # _RenameMatInDatei('Mat.B.Materialnr', 1, aMat1, aMat2);
    if (vErr<>'') then BREAK;
    vErr # _RenameMatInDatei('Mat.R.Materialnr', 1, aMat1, aMat2);
    if (vErr<>'') then BREAK;
    vErr # _RenameMatInDatei('Mat.O.Materialnr', 1, aMat1, aMat2);
    if (vErr<>'') then BREAK;

    Mat.Nummer # aMat1;
    Erx # RecRead(200,1,_recSingleLock);
    if (Erx=_rOK) then begin
      Mat.Nummer # aMat2;
      aInvDat # Mat.Inventurdatum;
      Mat.Inventurdatum # 0.0.0;
      Erx # RekReplace(200);
    end;
    if (erx<>_rOK) then vErr # 'Karte nicht änderbar';
  UNTIL (1=1);

  RETURN vErr;
end;


//========================================================================
//========================================================================
sub HatAnalyse(aNr : int) : logic;
begin
  if (aNr=1) then begin
    if (Mat.Streckgrenze1<>0.0) or (Mat.StreckgrenzeB1<>0.0) then RETURN true;
    if (Mat.Zugfestigkeit1<>0.0) or (Mat.ZugfestigkeitB1<>0.0) then RETURN true;
    if (Mat.DehnungA1<>0.0) then RETURN true;
    if (Mat.DehnungB1<>0.0) or (Mat.DehnungC1<>0.0) then RETURN true;
    if (Mat.RP02_V1<>0.0) or (Mat.RP02_B1<>0.0) then RETURN true;
    if (Mat.RP10_V1<>0.0) or (Mat.RP10_B1<>0.0) then RETURN true;
    if ("Mat.Körnung1"<>0.0) or ("Mat.KörnungB1"<>0.0) then RETURN true;
    if ("Mat.HärteA1"<>0.0) or ("Mat.HärteB1"<>0.0) then RETURN true;
    if (Mat.RauigkeitA1<>0.0) or (Mat.RauigkeitB1<>0.0) then RETURN true;
    if (Mat.RauigkeitC1<>0.0) or (Mat.RauigkeitD1<>0.0) then RETURN true;
    if (Mat.Chemie.C1<>0.0) then RETURN true;
    if (Mat.Chemie.Si1<>0.0) then RETURN true;
    if (Mat.Chemie.Mn1<>0.0) then RETURN true;
    if (Mat.Chemie.P1<>0.0) then RETURN true;
    if (Mat.Chemie.S1<>0.0) then RETURN true;
    if (Mat.Chemie.Al1<>0.0) then RETURN true;
    if (Mat.Chemie.Cr1<>0.0) then RETURN true;
    if (Mat.Chemie.V1<>0.0) then RETURN true;
    if (Mat.Chemie.Nb1<>0.0) then RETURN true;
    if (Mat.Chemie.Ti1<>0.0) then RETURN true;
    if (Mat.Chemie.N1<>0.0) then RETURN true;
    if (Mat.Chemie.Cu1<>0.0) then RETURN true;
    if (Mat.Chemie.Ni1<>0.0) then RETURN true;
    if (Mat.Chemie.Mo1<>0.0) then RETURN true;
    if (Mat.Chemie.B1<>0.0) then RETURN true;
    if (Mat.Chemie.Frei1.1<>0.0) then RETURN true;
    RETURN false;
  end;
  if (aNr=2) then begin
    if (Mat.Streckgrenze2<>0.0) or (Mat.StreckgrenzeB2<>0.0) then RETURN true;
    if (Mat.Zugfestigkeit2<>0.0) or (Mat.ZugfestigkeitB2<>0.0) then RETURN true;
    if (Mat.DehnungA2<>0.0) then RETURN true;
    if (Mat.DehnungB2<>0.0) or (Mat.DehnungC2<>0.0) then RETURN true;
    if (Mat.RP02_V2<>0.0) or (Mat.RP02_B2<>0.0) then RETURN true;
    if (Mat.RP10_V2<>0.0) or (Mat.RP10_B2<>0.0) then RETURN true;
    if ("Mat.Körnung2"<>0.0) or ("Mat.KörnungB2"<>0.0) then RETURN true;
    if ("Mat.HärteA2"<>0.0) or ("Mat.HärteB2"<>0.0) then RETURN true;
    if (Mat.RauigkeitA2<>0.0) or (Mat.RauigkeitB2<>0.0) then RETURN true;
    if (Mat.RauigkeitC2<>0.0) or (Mat.RauigkeitD2<>0.0) then RETURN true;
    if (Mat.Chemie.C2<>0.0) then RETURN true;
    if (Mat.Chemie.Si2<>0.0) then RETURN true;
    if (Mat.Chemie.Mn2<>0.0) then RETURN true;
    if (Mat.Chemie.P2<>0.0) then RETURN true;
    if (Mat.Chemie.S2<>0.0) then RETURN true;
    if (Mat.Chemie.Al2<>0.0) then RETURN true;
    if (Mat.Chemie.Cr2<>0.0) then RETURN true;
    if (Mat.Chemie.V2<>0.0) then RETURN true;
    if (Mat.Chemie.Nb2<>0.0) then RETURN true;
    if (Mat.Chemie.Ti2<>0.0) then RETURN true;
    if (Mat.Chemie.N2<>0.0) then RETURN true;
    if (Mat.Chemie.Cu2<>0.0) then RETURN true;
    if (Mat.Chemie.Ni2<>0.0) then RETURN true;
    if (Mat.Chemie.Mo2<>0.0) then RETURN true;
    if (Mat.Chemie.B2<>0.0) then RETURN true;
    if (Mat.Chemie.Frei1.2<>0.0) then RETURN true;
    RETURN false;
  end;
  RETURN false;
end;




//========================================================================
//========================================================================
sub CloseXList(
  aList : int)
local begin
  vItem : int;
end;
begin
  FOR vItem # aList->CteRead(_CteFirst)
  LOOP vItem # aList->CteRead(_CteFirst)
  WHILE (vItem>0) do begin
    RecbufDestroy(vItem->spID);
    aList->CteDelete(vItem);
    CteClose(vItem);
  END;
  CteClose(aList);
end;


//========================================================================
//========================================================================
sub SetXOriKey(aItem : int)
local begin
  Erx     : int;
  vDatei  : int;
end;
begin
  vDatei # cnvia(aItem->spCustom);
  
  case vDatei of
    200 : begin
      Mat.Nummer            # cnvia(aItem->spname);
    end;
    201 : begin
      Mat.AF.Nummer         # cnvia(Str_token(aItem->spname,'|',1));
      Mat.AF.Seite          # Str_token(aItem->spname,'|',2);
      Mat.AF.lfdnr          # cnvia(Str_token(aItem->spname,'|',3));
    end;
    202 : begin
      Mat.B.Materialnr      # cnvia(Str_token(aItem->spname,'|',1));
      Mat.B.lfdNr           # cnvia(Str_token(aItem->spname,'|',2));
    end;
    203 : begin
      Mat.R.Reservierungnr  # cnvia(Str_token(aItem->spname,'|',1));
    end;
    204 : begin
      Mat.A.Materialnr      # cnvia(Str_token(aItem->spname,'|',1));
      Mat.A.Aktion          # cnvia(Str_token(aItem->spname,'|',2));
    end;
  end;

end;


//========================================================================
sub ProcessXList(
  aList : int) : logic
local begin
  Erx     : int;
  vItem   : int;
  vDatei  : int;
  vBuf    : int;
end;
begin

  TRANSON;
  
  FOR vItem # aList->CteRead(_CteFirst)
  LOOP vItem # aList->CteRead(_CteNext, vItem)
  WHILE (vItem>0) do begin
    vDatei # cnvia(vItem->spCustom);
    vBuf   # vItem->spID;

    // Ziel prüfen....
    RecBufCopy(vBuf, vDatei, false);
    Erx # RecRead(vDatei,1,_recTest);
    if (Erx=_rOK) then begin        // Ziel gibt es!
      Erx # RecRead(vDatei, 1, _recSingleLock);
      if (Erx=_rOK) then begin
        RecBufCopy(vBuf, vDatei, false);
        Erx # RekReplace(vDatei);
      end;
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
    end
    else begin                      // Ziel NICHT vorhanden!
      SetXOriKey(vItem);
      Erx # RecRead(vDatei,1,_RecSingleLock);
      if (Erx=_rOK) then begin
        RecBufCopy(vBuf, vDatei, false);
        Erx # RekReplace(vDatei);
      end;
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
    end;
  END;

  TRANSOFF;

  RETURN true;
end;



//========================================================================
sub MemoX(
  aList   : int;
  aDatei  : int;
  aMat1   : int;
  aMat2   : int;
  ) : logic
local begin
  vBuf    : int;
  vItem   : int;
end;
begin

  // vItem : StartKey, BufMitZielDaten, Datei
  case aDatei of
    200 : begin
      vBuf # RekSave(aDatei);
      vBuf->Mat.Nummer # aMat2;
      aList->CteInsertItem(aint(aMat1), vBuf, aint(aDatei));
    end;
    201 : begin
      vBuf # RekSave(aDatei);
      vBuf->Mat.AF.Nummer # aMat2;
      aList->CteInsertItem(aint(aMat1)+'|'+Mat.AF.Seite+'|'+aint(Mat.AF.Lfdnr), vBuf, aint(aDatei));
    end;
    202 : begin
      vBuf # RekSave(aDatei);
      vBuf->Mat.B.Materialnr # aMat2;
      aList->CteInsertItem(aint(aMat1)+'|'+aint(Mat.B.lfdnr), vBuf, aint(aDatei));
    end;
    203 : begin
      vBuf # RekSave(aDatei);
      vBuf->Mat.R.Materialnr # aMat2;
      aList->CteInsertItem(aint(Mat.R.Reservierungnr), vBuf, aint(aDatei));
    end;
    204 : begin
      vBuf # RekSave(aDatei);
      vBuf->Mat.A.Materialnr # aMat2;
      if (vBuf->Mat.A.Aktionsmat=aMat1) then vBuf->Mat.A.Aktionsmat # aMat2;
      aList->CteInsertItem(aint(aMat1)+'|'+aint(Mat.A.Aktion), vBuf, aint(aDatei));
    end;
    otherwise RETURN false;
  end;
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub MemoX200(
  aList : int;
  aMat1 : int;
  aMat2 : int) : logic
local begin
  Erx : int;
end;
begin

  if (MemoX(aList, 200, aMat1, aMat2)=false) then RETURN false;

  FOR Erx # RecLink(201,200,11,_recFirst)
  LOOP Erx # RecLink(201,200,11,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (MemoX(aList, 201, aMat1, aMat2)=false) then RETURN false;
  END;
  

  FOR Erx # RecLink(202,200,12,_recFirst)
  LOOP Erx # RecLink(202,200,12,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (MemoX(aList, 202, aMat1, aMat2)=false) then RETURN false;
  END;
  
  
  FOR Erx # RecLink(203,200,13,_recFirst)
  LOOP Erx # RecLink(203,200,13,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (MemoX(aList, 203, aMat1, aMat2)=false) then RETURN false;
  END;
  
  
  FOR Erx # RecLink(204,200,14,_recFirst)
  LOOP Erx # RecLink(204,200,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (MemoX(aList, 204, aMat1, aMat2)=false) then RETURN false;
  END;
  
  RETURN true;
end;


//========================================================================
// TauscheMats
//    Tauscht zwei Matsätze mit AF, Aktionsliste, BB, Reserv
//========================================================================
sub TauscheMats(
  aMat1 : int;    // FM
  aMat2 : int;    // Vorgänger
) : logic;
local begin
  Erx     : int;
  vList   : int;
end;
begin

  vList # CteOpen(_CteList);

  // EINS
  Mat.Nummer # aMat1;
  Erx # RecRead(200,1,0);
  if (Erx=_rOK) then begin
    if (MemoX200(vList, aMat1, aMat2)=false) then begin
      CloseXList(vList);
      RETURN false;
    end;
  end;

  // ZWEI
  Mat.Nummer # aMat2;
  Erx # RecRead(200,1,0);
  if (Erx=_rOK) then begin
    if (MemoX200(vList, aMat2, aMat1)=false) then begin
      CloseXList(vList);
      RETURN false;
    end;
  end;

  if (ProcessXList(vList)=false) then begin
    CloseXList(vList);
    RETURN false;
  end;
   
  CloseXList(vList);

  RETURN true
end;


//========================================================================
//  Call Mat_data:Repair_02032021
//    machnmal waren VSB-Karten nicht in Auf-Aktionsliste wegen Bug in "BA1_Mat_Data",
//    wo Mat.Status per RekReplace gesetzt wurde
//========================================================================
SUB Repair_02032021()
local begin
  Erx         : int;
  vSel        : int;
  vSelName    : alpha;
  vQ          : alpha(4000);
end;

begin

//    332782+3
debugx('start');
/***/
  // Material loopen...
  FOR Erx # RecRead(200,1,_recFirst)
  LOOP Erx # RecRead(200,1,_recNext)
  //Mat.Nummer # 332782;
  //FOR Erx # Recread(200,1,0)
  //LOOP Erx # _rNoRec
  WHILE (Erx<=_rLocked) and (mat.nummer>-219000) do begin
    if ("Mat.Löschmarker"<>'') or ((Mat.Status<>400) and (Mat.Status<>440)) or (Mat.Auftragsnr=0) then CYCLE;

    RecBufClear(404);
    Auf.A.Aktionsnr     # Mat.Auftragsnr;
    Auf.A.AktionsPos    # Mat.Auftragspos;
    if (Mat.Status=c_Status_EKVSB) then begin
      Auf.A.AktionsTyp    # c_Akt_VSBEK;
    end
    else begin
      Auf.A.AktionsTyp    # c_Akt_VSB;
    end;
    Auf.A.MaterialNr      # Mat.Nummer;
    Erx # RecRead(404,9,0);
    if (Erx<=_rMultikey) then CYCLE;

debugx('fixe KEY200');
    RecRead(200,1,_recLock)
    Replace(_recunlock,'MAN');
  END;
/***/

  Lib_Sel:QAlpha(var vQ, 'Auf.A.Aktionstyp', '=', 'VSB');
  vSel # SelCreate(404, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(404,vSel, _recFirst);
  LOOP Erx # RecRead(404,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    if (Auf.A.MaterialNr=0) then CYCLE;
    Erx # RecLink(200,404,6,_RecFirsT);
    if (Erx>_rLocked) or ("Mat.Löschmarker"<>'') or (IstVSBStatus(Mat.Status)=false) then begin
debugx('remove KEY200');
      RecRead(200,1,_recLock)
      Replace(_recunlock,'MAN');
    end;
  END;
  SelClose(vSel);
  SelDelete(404, vSelName);

  Msg(999998,'',0,0,0);
end;



/*========================================================================
2023-03-21  AH
  call Mat_data:RepairRatio
========================================================================*/
sub RepairRatio()
local begin
  Erx     : int;
  vAlt    : float;
  vNeu    : float;
  vGew    : float;
  vMenge  : float;
end;
begin

  FOR Erx # RecRead(200,1,_recFirst)
  LOOP Erx # RecRead(200,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Mat.Ratio.MehKg<>0.0) then CYCLE;
    if (Mat.Status=500) then CYCLE;
    
    Mat_B_Data:BewegungenRueckrechnen(1.1.2000, y);
    
    vGew    # Mat.Bestand.Gew;
    vMenge  # Mat.Bestand.Menge;
//    if (vGew=0.0) or (vMenge=0.0) then begin
//      _SucheMengen(var vGew, var vMenge, Mat.MEH);
//    end;
    
    // GEWICHT PRO MENGE
    vAlt # Mat.Ratio.MehKg;
    if (Mat.MEH='kg') then
      vNeu # 1.0
    else if (Mat.MEH='t') then
      vNeu # 1000.0
    else
      DivOrNull(vNeu, vGew, vMenge, 5);
      // Ratio: 4000kg/4m = 1000   Kosten: 2000/t = 2/kg * 1000ratio = 2000/m

    if (vNeu=0.0) then begin
debugx('KEY200 bekäme NULL Ratio:'+anum(Mat.Bestand.Gew,2)+'kg / '+anum(Mat.BEstand.Menge,2)+Mat.MEH);
      CYCLE;
    end;
    
    RecRead(200,1,_recLock);
    Mat.Ratio.MehKg # vNeu;
    RekReplace(200);
//    if (vX=0.0) or (Abs(vX-Mat.Ratio.MehKg)<0.1) then CYCLE;
//debugx('KEY200 DIFF alt:'+anum(vX,5)+' wird '+anum(Mat.Ratio.MehKg,5));
    
  END;

  Msg(999998,'',0,0,0);
end;


/*========================================================================
2023-03-21  AH
  call Mat_data:RepairEK
========================================================================*/
sub RepairEK()
local begin
  Erx     : int;
  vAlt    : float;
  vNeu    : float;
  vGew    : float;
  vMenge  : float;
end;
begin

  TRANSON;

  FOR Erx # RecRead(200,1,_recFirst)
  LOOP Erx # RecRead(200,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if ("Mat.Vorgänger"<>0) then CYCLE;
    if (Mat.Status=500) then CYCLE;
//if (Mat.Nummer<>3276) then CYCLE;
    if (SetUndVererbeEkPreis(200, Mat.Datum.Erzeugt, Mat.EK.Preis, Mat.EK.PreisProMEH, Mat.MEH, 0)=false) then begin
      TRANSBRK;
      Msg(99,'Problem mit Karte '+aint(mat.nummer),0,0,0);
      RETURN;
    end;
//BREAK;
  END;
  TRANSOFF;
  
  Msg(999998,'',0,0,0);
end;


/*========================================================================
2023-03-15  AH
========================================================================*/
sub GetBasisKosten(
  aDatei      : int;
  var aBasis  : float;
  var aBasisP : float;
  ) : logic;
local begin
  Erx         : int;
  vBasis      : float;
  vBasisP     : float;
end;
begin

  if (aDatei<>200) and (aDatei<>210) then RETURN false;
  if (aDatei=210) then RecBufCopy(210,200);

  // Bestandsbuch loopen...
  FOR Erx # RecLink(204, aDatei,14,_recFirst)
  LOOP Erx # RecLink(204, aDatei,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    vBasis  # vBasis + (Mat.A.Kosten2W1);
    vBasisP # vBasisP + (Mat.A.Kosten2W1ProME);
  END;
  
  aBasis  # vBasis;
  aBasisP # vBasisP;
end;

//========================================================================
