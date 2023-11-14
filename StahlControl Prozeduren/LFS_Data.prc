@A+
//===== Business-Control =================================================
//
//  Prozedur    Lfs_Data
//                OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  14.04.2010  AI  Art-LFS nimmt Chargen-EK
//  06.05.2010  AI  Artikel Reservierung wird benutzt
//  27.05.2010  AI  Konsi-LFS setzt Lagerort
//  09.11.2010  AI  Autodruck für LFS
//  09.08.2012  AI  "Pos_Verbuchen" löscht die VLDAW-Aktion im Material
//  30.08.2012  ST  Pos_Verbuchen_Mat trägt bei Umwandlung von VLDAW in LFS bei 209er an AufAktion die Artikelnummer mit ein (1326/287)
//  12.10.2012  AI  Neu: Set.LFS.WZDruckKombi
//  19.02.2013  AI  Kosten werden pro Gewicht verteilt, ausser wenn kein Gewicht vorhanden, dann pro Position
//  11.03.2013  AI  LFA-Storno
//  11.04.2013  AI  MatMEH
//  16.04.2013  AI  Rechnungsmenge wird an Auf.Aktion übergeben
//  28.04.2014  AH  Neu: Zielort ändern
//  31.07.2014  ST  Prüfung auf Abschlussdatum bei "Verbuchen" hinzugefügt Projekt 1326/395
//  20.10.2014  AH  MatSofortInAblage
//  07.04.2015  AH  Auftrags-SL in Kommission aktiviert
//  24.04.2015  AH  neues Formular "LIEFERSCHEIN-LFA"
//  29.05.2015  AH  Mat-Sofort-In-Amlage erzeugte falsche Umlage
//  14.07.2015  AH  Auftragsvorkalkulations-Rückstellungen werden als Kosten LFS eingerechnet
//  15.07.2015  AH  bei LFA kommen Kosten NUR beim Abschluss
//  04.11.2015  AH  Rücklieferschein
//  05.02.2016  AH  Bugfix bei Verbuchen vor Artikel ohne Mengenverbuchung
//  06.09.2016  AH  Bugfix bie Storno, wenn Mat gelöscht ist und man "dirket löschen" nutzt
//  05.10.2018  ST  "Druck_LFS" über SOA erweitert
//  28.02.2019  ST  Bugfix bei Storno auf Konsi Lfs -> Materialprüfung auf gelöscht deaktiviert
//  05.07.2019  AH  AFX "Lfs.P.Verbuchen.Check"
//  16.09.2019  AH  Fix: Abweichende Rechnungsmenge wurde nicht in AufAktion geschrieben
//  29.10.2019  AH  AFX "Lfs.P.Verbuchen.Rueck_Mat"
//  25.11.2019  AH  Neu: VPG-LFS Aktion
//  14.01.2020  TM  AFX "Lfs.Print.Freistellung" in Formulardruck Freistellunf eingehängt (1884/150)
//  03.02.2020  AH  Fix: Rückname negiert die Mengen
//  03.06.2020  AH  Fix: Rüchnahme netto/brutto-Gewichte
//  24.11.2020  AH  Neu: LFA trägt Start-End Datum in Auf.Aktion
//  09.02.2021  AH  Neu: WOF für LFS
//  27.07.2021  AH  ERX
//  14.01.2022  AH  "SumAlleLFS"
//  21.02.2022  AH  "Recalc"
//  2022-07-05  AH  DEADLOCK
//  2022-09-05  AH  Fix bei RückLFS
//  2022-12-06  AH  AFX "Lfs.P.Rueck.Verbuchen.Mat.Pre"
//  2022-12-14  AH  ReKor zu RückLFS setzen nicht mehr die Mat.Nr. in die "GUT"-Aktion  Proj. 2346/26
//  2023-02-07  AH  Aktions-Termine verändert
//  2023-04-26  AH  RückLfs reaktiviert bei BFS auch KOPFAUFPREISE Proj. 2333/89
//  2023-07-19  AH  cRueckLfsMitPauschalAufpreisen
//
//  Subprozeduren
//    SUB _PosKosten(aDatei : int; var aGew : float; var aKosten : float) : logic;
//    SUB BerechneLfsKosten(aDatei      : int;  aPauschalOK : logic;  var aKosten : float;) : logic;
//    SUB BerechneEKundKostenAusVorkalkulation(aDatei : int; aPauschalOK : logic; var aEK : float; var aKosten : float; var aEKfound  : logic;) : logic;
//    SUB BestimmeArtikelEKPreis(var aEK : float);
//    SUB Pos_Verbuchen_Rueck_Mat(aDatum : date) : logic;
//    SUB Pos_Verbuchen_Rueck_Art(aDatum : date) : logic;
//    SUB Pos_Verbuchen_Mat(aDatum : date) : logic;
//    SUB Pos_Verbuchen_Art(aDatum : date) : logic;
//    SUB Pos_Verbuchen_Vpg(aDatum : date) : logic;
//    SUB Pos_Verbuchen(aDatum : date) : logic;
//    SUB Pos_Storno_Mat() : logic;
//    SUB Pos_Storno_Art() : logic;
//    SUB Pos_Storno_Vpg() : logic;
//    SUB Pos_Stornieren() : logic;
//    SUB KostenAusLFA() : logic;
//    SUB Verbuchen(aLfs : int; aDatum : date; opt aSilent : logic) : logic;
//    SUB Stornieren(aLfs : int; aDatum : date) : logic;
//    SUB Druck_LFS()
//    SUB Druck_Avis();
//    SUB Druck_Auto();
//    SUB Druck_Freistellung()
//    SUB Druck_Nachweiss()
//    SUB Druck_Werkszeugnis()
//    SUB Druck_VSB()
//    SUB SaveLFS() : logic;
//    SUB SumLFS(); : logic;
//    SUB Check_ChangeZiel(aSilent : logic) : logic;
//    SUB ChangeZiel(aZieladr : int; aZielAnsch : int) : logic;
//    SUB SumAlleLFS();
//    SUB Recalc()
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG
@I:Def_Rights
//@I:SFX_BSP_WebApp

define begin
  cRueckLfsMitKopfAufpreisen : (Set.Installname='BFS')
  cRueckLfsMitPauschalAufpreisen : (Set.Installname='BFS')
end;

declare SumLFS() : logic;


//========================================================================
//  _PosKosten
//
//========================================================================
sub _PosKosten(
  aDatei      : int;
  aPauschalOK : logic;
  var aGew    : float;
  var aKosten : float;) : logic;
local begin
  vM    : float;
  vKost : float;
  vGew  : float;
end;
begin

  vGew # Lib_Einheiten:WandleMEH(aDatei, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Lfs.P.Menge, Lfs.P.MEH, 'kg');
  if (Lfs.Kosten.MEH=Translate('pauschal')) then begin

    if (Lfs.zuBA.Nummer<>0) and (aPauschalOK=false) then RETURN false;

    if (Lfs.Positionsgewicht<>0.0) then
      vKost # Rnd(Lib_Berechnungen:Dreisatz(Lfs.Kosten.Pro, Lfs.Positionsgewicht, Lfs.P.Gewicht.Brutto), 2)
    else
      vKost # Rnd(Lfs.Kosten.Pro / cnvfi(recLinkInfo(441,440,4, _RecCount)),2);

    aKosten # aKosten + vKost;
    aGew    # aGew + vGew;
    RETURN true;
  end;


  vM # Lib_Einheiten:WandleMEH(aDatei, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Lfs.P.Menge, Lfs.P.MEH, Lfs.Kosten.MEH);
//vGew # 0.0;
  // Faktor einbauen falls Gesamtgewicht angegeben ist
  if (Lfs.Gesamtgewicht<>0.0) and
    (Lfs.Positionsgewicht<>0.0) then begin

    vGew # vGew * (Lfs.Gesamtgewicht / Lfs.Positionsgewicht);
    if (Lfs.Kosten.MEH='t') or (Lfs.Kosten.MEH='kg') then
      vM # vM * (Lfs.Gesamtgewicht / Lfs.Positionsgewicht);
  end;

  vKost # Rnd(vM * Lfs.Kosten.Pro / cnvfi(Lfs.Kosten.PEH),2);

  aKosten # aKosten + vKost;
  aGew    # aGew + vGew;

  RETURN true;
end;


//========================================================================
// _PosGesamtGewichtZuKommission
//========================================================================
Sub _PosGesamtGewichtZuKommission(
  aAufNr    : int;
  aAufPos   : int;
  var aGew  : float;
  var aAnz  : int) : logic;
local begin
  Erx       : int;
  v441      : int;
end;
begin
  v441 # RecBufCreate(441);

//debugx('KEY440 hat '+aint(RecLinkInfo(441,440,4,_RecCount))+' Pos    suche:'+aint(aAufNr)+'/'+aint(aAufPos));
  FOR Erx # RecLink(v441,440,4,_RecFirst)
  LOOP Erx # RecLink(v441,440,4,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (v441->Lfs.P.Auftragsnr=aAufNr) and (v441->Lfs.P.AuftragsPos=aAufPos) then begin
      if (VWA.NettoYN) then
        aGew # aGew + v441->Lfs.P.Gewicht.Netto
      else
        aGew # aGew + v441->LFs.P.Gewicht.Brutto;
      aAnz # aAnz + 1;
    end;
  END;
  RecBufDestroy(v441);

  RETURN true;
end;


//========================================================================
// BerechneLfsKosten
//========================================================================
sub BerechneLfsKosten(
  aDatei      : int;
  aPauschalOK : logic;
  var aKosten : float;
) : logic;
local begin
  vTeil   : float;
  vKosten : float;
  vOK     : logic;
end;
begin

  // KOSTEN bei NICHT BA-LFS.... ?????????
  // KOSTEN bei JEDER Art von LFS
//  if (Lfs.zuBA.Nummer=0) then RETURN;
  if (Lfs.Kosten.Pro<>0.0) and (Lfs.Kosten.MEH<>'') and (Lfs.Kosten.PEH<>0) then begin

    vOK # _PosKosten(aDatei, aPauschalOK, var vTeil, var vKosten);

//    if (Lfs.P.Gewicht.Brutto<>0.0) then vKostPro # Rnd(vKosten * 1000.0 / Lfs.P.Gewicht.Brutto,2)
//    else vKostPro # 0.0;
    vKosten # Rnd(vKosten,2)
  end;

  aKosten # aKosten + vKosten;

  RETURN vOK;
end;


//========================================================================
// BecheneEKundKostenAusVorkalkulation
//========================================================================
sub BerechneEKundKostenAusVorkalkulation(
  aDatei        : int;
  aPauschalOK   : logic;
  var aEK       : float;
  var aKosten   : float;
  var aEKfound  : logic;
) : logic;
local begin
  Erx       : int;
  vGew      : float;
  vGew2     : float;
  vEK       : float;
  vKosten   : float;
  vX        : float;
  vAnz      : int;
  vPreisOK  : logic;
end;
begin

  vPreisOK  # true;
  aEKFound  # false;  // 05.02.2016 AH

  // Kalkulationspreis??

  if (aDatei=250) then begin
    if (Wgr.Nummer<>Art.Warengruppe) then
      Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen
    VWA.NettoYN # true;  // Artikel immer Nettogewicht
  end
  else begin
    Erx # RecLink(818,401,9,_recFirst);
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
  end;

  // 14.07.2015 RÜCKSTELLUNGEN einbeziehen....
  FOR Erx # RecLink(405,401,7,_RecFirst)
  LOOP Erx # RecLink(405,401,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.K.PEH=0) then Auf.K.PEH # 1;

    if (aDatei=250) then begin
      // Kalkulationspreis??
      if (WGr.OhneBestandYN) and("Art.ChargenführungYN"=false) then begin
        if (Auf.K.MengenbezugYN) and (Auf.K.MEH=Auf.P.MEH.Preis) and (Auf.K.Bezeichnung=Lfs.P.Artikelnr) then begin
          vX # Lib_Einheiten:WandleMEH(250, "Auf.A.Stückzahl", Auf.A.Nettogewicht, Auf.A.Menge, Auf.A.MEH, Auf.K.MEH);
          vEK # vEK + Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * vX,2);
          aEKfound # y;
          CYCLE;
        end;
      end;
    end;


    if ("Auf.K.RückstellungYN"=false) then CYCLE;

    // Basisartikel?
    if (Auf.K.MengenbezugYN) and (Auf.K.MEH=Auf.P.MEH.Preis) and (Auf.K.Bezeichnung=Lfs.P.Artikelnr) and (Lfs.P.Artikelnr<>'') then CYCLE;

    if (VWA.NettoYN) then
      vGew # Lfs.P.Gewicht.Netto
    else
      vGew # Lfs.P.Gewicht.Brutto;

    if (Auf.K.MengenbezugYN) then begin
      vGew2  # Lib_Einheiten:WandleMEH(aDatei, "Lfs.P.Stück", vGew, Lfs.P.Menge, Lfs.P.MEH, Auf.K.MEH);
      vKosten # vKosten + Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * vGew2,2);
    end
    else begin  // PAUSCHAL?

      if (Lfs.zuBA.Nummer<>0) and (aPauschalOK=false) then vPreisOK # false;

      if (Lfs.zuBA.Nummer=0) or (aPauschalOK) then begin
        vX # Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * Auf.K.Menge,2);
        _PosGesamtGewichtZuKommission(Lfs.P.Auftragsnr, Lfs.P.Auftragspos, var vGew2, var vAnz);
        if (vGew2=0.0) then begin
          vX # Rnd(Lib_Berechnungen:Dreisatz(vX, cnvfi(vAnz), 1.0), 2);
        end
        else begin
          vX # Rnd(Lib_Berechnungen:Dreisatz(vX, vGew2, vGew), 2)
        end;
        vKosten # vKosten + vX;
      end;

    end;

  END;

  Erx # RekLink(814,400,8,_recFirst); // Währung holen
  if ("Auf.WährungFixYN") then
    Wae.VK.Kurs # "Auf.Währungskurs";
  if (Wae.VK.Kurs=0.0) then
    Wae.VK.Kurs # 1.0;
  vEK           # Rnd(vEK / Wae.VK.Kurs,2);
  vKosten       # Rnd(vKosten / Wae.VK.Kurs,2);


  aEK     # vEK;

//debugx('KEY441 add VOK auf '+anum(aKosten,2)+' + ' +anum(vKosten,2));
  aKosten # aKosten + vKosten;

  RETURN vPreisOK;
end;


//========================================================================
// BestimmeArtikelEKPreis
//========================================================================
sub BestimmeArtikelEKPreis(var aEK : float);
local begin
  Erx     : int;
  vMenge  : float;
  vEK     : float;
end;
begin
  // EK-PREIS berechnen...
  RecbufClear(254);   // Preise leeren

  // evtl. Chargenpreis holen...
  if (Lfs.P.Art.Charge<>'') then begin
    Erx # RecLink(252,441,14,_recFirst);    // ArtCharge holen
    if (Erx<=_rLocked) then begin
      Art.P.PEH     # Art.PEH;
      Art.P.MEH     # Art.MEH;
      Art.P.PreisW1 # Art.C.EKDurchschnitt;
    end;
  end;
//debug('Charge:'+art.c.charge.intern+' mit MEH '+Art.P.MEH);
  // sonst EK-Preis aus Tabelle holen...
  if (Art.P.MEH='') then begin
      Art_P_Data:LiesPreis('Ø-EK',0);
    if (Art.P.MEH='') then
//    if (Art.Typ=c_art_PRD) then
//      Art_P_Data:LiesPreis('PRD',0)
//    else
      Art_P_Data:LiesPreis('L-EK',0);
    if (Art.P.MEH='') then
      Art_P_Data:LiesPreis('L-EK',-1);
    if (Art.P.MEH='') then
      Art_P_Data:LiesPreis('EK',0);
  end;

  if (Auf.A.MEH<>Art.P.MEH) and (Art.P.MEH<>'') then begin
    vMenge # Lib_Einheiten:WandleMEH(250, "Auf.A.Stückzahl", Auf.A.Nettogewicht, Auf.A.Menge, Auf.A.MEH, Art.P.MEH);
    vEK # Rnd(Art.P.PreisW1 * vMenge / CnvfI(Art.P.PEH),2);
//debug('Version A mit Menge '+anum(vMenge,0)+' ergibt PReis '+anum(auf.a.ekpreissummeW1,2));
//  TODO('MEH Umrechnung!!!! '+Auf.A.MEH+'<>'+Art.P.MEH);
  end
  else begin
    vEK  # Rnd(Art.P.PreisW1 * Auf.A.Menge / CnvfI(Art.P.PEH),2);
//debug('Version B mit Menge '+anum(Auf.A.Menge,0)+' ergibt PReis '+anum(auf.a.ekpreissummeW1,2));
  end;

  aEK # vEK
end;


//========================================================================
// Pos_Verbuchen_Ruck_Mat  +ERR
//    1. Reservierung löschen
//    2. neues Material anlegen
//    3. Material auf "RUECKNAHME"-Status setzen
//    4. neue Karte in Lieferscheine ersetzen
//    5. Auf- und Mat-Aktion auf RLFS setzen
//========================================================================
sub Pos_Verbuchen_Rueck_Mat(
  aDatum        : date;
  aZeit         : time) : logic;
local begin
  Erx       : int;
  vA        : alpha;
  vOk       : logic;
  vNeueNr   : int;
  vAlteNr   : int;
  vKosten   : float;
  vKostenPRO   : float;
end;
begin
  if ("Lfs.RücknahmeYN"=false) then RETURN false;

  if (aDatum<>0.0.0) then
    vA # cnvad(aDatum);
  if (RunAFX('Lfs.P.Verbuchen.Rueck_Mat',vA)<>0) then RETURN (AfxRes=_rOK);
 
  //Erx # RecLink(200,441,4,_RecFirst);   // Material holen
//  if (Erx>_rLocked) then begin
  Erx # Mat_Data:Read(Lfs.P.Materialnr, 0, 0, TRUE);
  if (Erx<>200) then begin
    Error(010001, AInt(Lfs.P.Position)+'|'+AInt(LFs.P.Materialnr));
    RETURN false;
  end;

  // Reservierung löschen************************
  if (Lfs.P.ReservierungNr<>0) then begin
    Erx # RecLink(203,441,6,_RecFirst);
    if (Erx<>_rOK) then begin
      Error(010004, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;
    if (Mat_Rsv_Data:Entfernen()=false) then begin
      Error(010004, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;
  end;


  vAlteNr # Lfs.P.Materialnr;

  // NEUE Karte anlegen
  Erx # Mat_Data:Read(vAlteNr);
  if (Erx<200) then RETURN false;

  vNeueNr # Lib_Nummern:ReadNummer('Material');
  if (vNeueNr<>0) then begin
    Lib_Nummern:SaveNummer()
  end
  else begin
    RETURN false;
  end;

  // Info über Rücknahme eintragen...
  RecBufClear(204);
  Mat.A.Materialnr      # vAlteNr;
  Mat.A.Aktionsmat      # vAlteNr;
  Mat.A.Aktionstyp      # c_Akt_INFO;
  Mat.A.Bemerkung       # Translate('Rücknahme zu')+' '+aint(vNeueNr);
  Mat.A.Aktionsnr       # vNeueNr;
  Mat.A.Aktionspos      # 0;
  Mat.A.Aktionspos2     # 0;
  Mat.A.Aktionsdatum    # aDatum;
  Mat.A.Aktionszeit     # aZeit;
  Mat.A.TerminStart     # aDatum;
  Erx # Mat_A_Data:Insert(0,'AUTO');
  if (erx<>_rOK) then RETURN false;

  if (Mat_Data:CopyAF(vNeueNr)=false) then RETURN false;  // 06.12.2021 AH laut VBS

  Mat.Eingangsdatum     # aDatum;
  Mat.Gewicht.Netto     # - Lfs.P.Gewicht.Netto;
  Mat.Gewicht.Brutto    # - Lfs.P.Gewicht.Brutto;
  Mat.Bestand.Stk       # - "Lfs.P.Stück";
  Mat.Bestand.Gew       # 0.0;
  Mat.Bestand.Menge     # 0.0;
  "Mat.Löschmarker"     # '';
  Mat.Ausgangsdatum     # 0.0.0;
  Mat.Nummer            # vNeueNr;
  Mat.Ursprung          # vNeueNr;
  "Mat.Vorgänger"       # 0;
  Mat.Datum.VSBMeldung  # 0.0.0;
  Mat.Datum.Lagergeld   # 0.0.0;
  Mat.Datum.Zinsen      # 0.0.0;
  Mat.VK.Rechnr         # 0;
  Mat.VK.Gewicht        # 0.0;
  vKosten               # Mat.Kosten;
  vKostenPro            # Mat.KostenProMEH;
  Mat.EK.Preis          # Mat.EK.Preis + Mat.Kosten;
  Mat.EK.PreisProMEH    # Mat.EK.PreisProMEH + Mat.KostenProMEH;
  Mat.Kosten            # 0.0;
  Mat.KostenProMEH      # 0.0;
  Mat.Kommission        # '';
  Mat.Auftragsnr        # 0;
  Mat.Auftragspos       # 0;
  Mat.KommKundennr      # 0;
  Mat.KommKundenSWort   # '';
  Mat.Lageradresse      # Lfs.Zieladresse;
  Mat.Lageranschrift    # Lfs.Zielanschrift;
  Mat_Data:SetStatus(c_Status_LfsRueck);
  
  RunAfx('Lfs.P.Rueck.Verbuchen.Mat.Pre',anum(vKosten,2));    // 2022-12-06 AH   Proj. 2343/88
  
  Erx # Mat_Data:Insert(_recUnlock,'AUTO', aDatum);
  if (erx<>_rOK) then RETURN false

  // Summe der Kosten eintragen...
  RecBufClear(204);
  Mat.A.Materialnr      # vNeueNr;
  Mat.A.Aktionsmat      # vNeueNr;
  Mat.A.Aktionstyp      # c_Akt_INFO;
  Mat.A.Bemerkung       # Translate('Rücknahme aus')+' '+aint(vAlteNr);
  Mat.A.Aktionsnr       # vAlteNr;
  Mat.A.Aktionspos      # 0;
  Mat.A.Aktionspos2     # 0;
  Mat.A.Aktionsdatum    # aDatum;
  Mat.A.Aktionszeit     # aZeit;
  Mat.A.TerminStart     # aDatum;
  if (Mat.Kosten<>0.0) then begin // 2022-12-06 AH
    Mat.A.KostenW1        # vKosten;
    Mat.A.KostenW1ProMEH  # vKostenPro;
  end
  else begin
    Mat.A.Kosten2W1       # vKosten;
    Mat.A.Kosten2W1ProME  # vKostenPro;
  end;
  Erx # Mat_A_Data:Insert(0,'AUTO');
  if (erx<>_rOK) then RETURN falsE;

  // LfsPosition in LFS umwandeln ******************
  if (vNeueNr<>vAlteNr) then begin
    Erx # RecRead(441,1,_recLock);
    if (erx=_rOK) then begin
      Lfs.P.Materialnr # vNeueNr;
      Erx # RekReplace(441,_recUnlock,'AUTO');
    end;
    if (erx<>_rOK) then begin
      Error(010008, AInt(Lfs.P.Position));
      RETURN false;
    end;
  end;


  // RVLDAW Aktion in RLFS umwandeln ******************
  if (Lfs.P.Auftragsnr<>0) and (Lfs.Kundennummer<>0) then begin
    RecBufClear(404);
    Auf.A.Aktionsnr     # Lfs.P.Nummer;
    Auf.A.Aktionspos    # Lfs.P.Position;
    Auf.A.Aktionspos2   # 0;
    Auf.A.Aktionstyp    # c_Akt_RVLDAW;
    Erx # RecRead(404,2,0);
    if (Erx=_rNoRec) or
      (Auf.A.Aktionsnr<>Lfs.P.Nummer) or
      (Auf.A.AktionsPos<>Lfs.P.Position) or
      (Auf.A.AktionsPos2<>0) or
      (Auf.A.Rechnungsnr<>0) or
      (Auf.A.AktionsTyp<>c_Akt_RVLDAW) then begin
      Error(010009, AInt(Lfs.P.Position)+'|'+c_Akt_RVLDAW);
      RETURN false;
    end;
    Erx # RekDelete(404,0,'AUTO');
    if (erx<>_rOK) then RETURN false;
    
    Auf.A.Aktionstyp    # c_Akt_RLFS;
    Auf.A.Aktionsdatum  # aDatum;
    Auf.A.TerminStart   # aDatum;
    Auf.A.TerminEnde    # aDatum;

    Auf.A.Materialnr      # vNeueNr;
    Erx # RecLink(401,441,5,0);   // AufPos lesen
    if (Erx<>_rOK) then
      RETURN false;

    if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then   // ggf. Artikelnummer für 209er übernehmen
      Auf.A.ArtikelNr # Mat.Strukturnr;

    Auf.A.Aktionstyp      # c_Akt_RLFS;
    Auf.A.TerminEnde      # aDatum;

    Auf.A.EKPreisSummeW1  # 0.0;
    Auf.A.InterneKostW1   # 0.0;

    vOk # Auf_A_Data:NeuAnlegen(y, (Lfs.P.Auftragspos2<>0))=_rOK;
    if (vOK=false) then begin
      Error(010010, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
  end;


  // Mataktion löschen *************
  RecBufClear(204);
  Mat.A.AktionsTyp  # c_Akt_RVLDAW;
  Mat.A.Aktionsnr   # Lfs.P.Nummer;
  Mat.A.AktionsPos  # Lfs.P.Position;
  Erx # RecRead(204,2,0);
  if (Erx=_rOK) or (Erx=_rMultikey) then begin
    Erx # RekDelete(204,0,'AUTO');
    if (Erx<>_rOK) then RETURN false;
  end;

  RecLink(818,200,10,_recFirst);  // Verwiegungsart Material holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  // Mataktion anlegen ***************
  RecBufClear(204);
  Mat.A.Materialnr    # vNeueNr;
  Mat.A.Aktionsmat    # vNeueNr;
  Mat.A.Aktionstyp    # c_Akt_RLFS;
  Mat.A.Aktionsnr     # Lfs.P.Nummer;
  Mat.A.Aktionspos    # Lfs.P.Position;
  Mat.A.Aktionspos2   # 0;
  Mat.A.Aktionsdatum  # aDatum;
  Mat.A.TerminStart   # aDatum;
  Mat.A.Adressnr      # Lfs.Zieladresse;
  "Mat.A.Stückzahl"   # - "Lfs.P.Stück";
  if (VWA.NettoYN) then
    Mat.A.Gewicht     # - Lfs.P.Gewicht.Netto
  else
    Mat.A.Gewicht     # - Lfs.P.Gewicht.Brutto;
  Mat.A.Nettogewicht  # - Lfs.P.Gewicht.Netto;

  // für MATMEH
  if (Mat.MEH=Lfs.P.MEH) then
    Mat.A.Menge       # - Lfs.P.Menge;

  erx # Mat_A_Data:Insert(0,'AUTO');
  if (erx<>_rOK) then RETURN false;

  RETURN true;
end;


//========================================================================
//========================================================================
sub Pos_Verbuchen_Rueck_Art(
  aDatum        : date) : logic;
local begin
  Erx       : int;
  vOk       : logic;
  vMenge    : float;
  vStk      : int;
  vNr       : int;
  vPos1     : int;
  vPos2     : int;
  vEkPreis  : float;
end;
begin
  if ("Lfs.RücknahmeYN"=false) then RETURN false;

  Erx # RecLink(250,441,3,_RecFirst)  // Artikel holen
  if (Erx>_rLocked) then begin
    Error(010001, AInt(Lfs.P.Position)+'|'+(LFs.P.Artikelnr));
    RETURN false;
  end;

  Erx # RecLink(404,441,16,_recFirst);  // ursprüngliche LFS-Aktion holen
  if (Erx>_rLocked) or ((Auf.A.Aktionstyp<>c_Akt_LFS) and (Auf.A.Aktionstyp<>c_Akt_DFAKT)) then begin
    RETURN false;
  end;
  // EkPreis über Dreisatz
  vEkPreis # Lib_Berechnungen:Dreisatz(Auf.A.EKPreisSummeW1 + Auf.A.InterneKostW1, Auf.A.Menge.Preis, cnvfi(Art.PEH));

  vMenge # Lfs.P.Menge.Einsatz;
  vStk   # "Lfs.P.Stück";

  vNr   # Lfs.P.Auftragsnr;
  vPos1 # Lfs.P.Auftragspos;
  vPos2 # Lfs.P.Auftragspos2;

  // Reservierung entfernen
  if (Lfs.P.ReservierungNr<>0) then begin
    vOK # Art_Data:Reservierung(Lfs.P.Artikelnr, Lfs.P.Art.Adresse, LFs.P.Art.Anschrift, Lfs.P.Art.Charge, 0, c_Auf, LFS.P.Auftragsnr, Lfs.P.Auftragspos, Lfs.P.Auftragspos2, -vMenge, -vStk, 0);
    if (vOK=false) then begin
      Error(010004, AInt(Lfs.P.Position));
      RETURN false;
    end;
  end;

  // Artikel ZUBUCHEN
  RecBufClear(252);
  Art.C.ArtikelNr       # Lfs.P.ArtikelNr;
  Art.C.Charge.Intern   # Lfs.P.Art.Charge;
  RecBufClear(253);
  Art.J.Datum           # aDatum;
  Art.J.Bemerkung       # StrCut(Translate('Lieferschein')+' '+AInt(Lfs.P.Nummer)+'/'+AInt(LFs.P.Position)+' '+Lfs.Kundenstichwort,1,64);
  "Art.J.Stückzahl"     # -vStk;
  Art.J.Menge           # -vMenge;
  "Art.J.Trägertyp"     # 'LFS';
  "Art.J.Trägernummer1" # Lfs.P.Nummer;
  "Art.J.Trägernummer2" # Lfs.P.Position;
  "Art.J.Trägernummer3" # 0;

  vOK # Art_Data:Bewegung(vEkPreis, 0.0);
  if (vOK=false) then begin
    Error(010011, AInt(Lfs.P.Position)+'|'+Lfs.P.ArtikelNr);
    RETURN false;
  end;


  // Stückliste ggf. holen
  RecBufClear(409);
  if (Lfs.P.Auftragspos2<>0) then begin
    Auf.SL.Nummer   # LFs.P.AuftragsNr;
    Auf.SL.Position # Lfs.P.Auftragspos;
    Auf.SL.lfdNr    # Lfs.P.AuftragsPos2;
    Erx # RecRead(409,1,0);
    if (Erx<>_rOK) then begin
      Error(010011, AInt(Lfs.P.Position)+'|'+Lfs.P.ArtikelNr);
      RETURN false;
    end;
  end;



  // RVLDAW Aktion in RLFS umwandeln ******************
  if (Lfs.P.Auftragsnr<>0) and (Lfs.Kundennummer<>0) then begin
    RecBufClear(404);
    Auf.A.Aktionsnr     # Lfs.P.Nummer;
    Auf.A.Aktionspos    # Lfs.P.Position;
    Auf.A.Aktionspos2   # 0;
    Auf.A.Aktionstyp    # c_Akt_RVLDAW;
    Erx # RecRead(404,2,0);
    if (Erx=_rNoRec) or
      (Auf.A.Aktionsnr<>Lfs.P.Nummer) or
      (Auf.A.AktionsPos<>Lfs.P.Position) or
      (Auf.A.AktionsPos2<>0) or
      (Auf.A.Rechnungsnr<>0) or
      (Auf.A.AktionsTyp<>c_Akt_RVLDAW) then begin
      Error(010009, AInt(Lfs.P.Position)+'|'+c_Akt_RVLDAW);
      RETURN false;
    end;
    Erx # RekDelete(404,0,'AUTO');
    if (erx<>_rOK) then RETURN false;

    Auf.A.Aktionstyp    # c_Akt_RLFS;
    Auf.A.Aktionsdatum  # aDatum;
    Auf.A.TerminStart   # aDatum;
    Auf.A.TerminEnde    # aDatum;
    Erx # RecLink(401,441,5,0);   // AufPos lesen
    if (Erx<>_rOK) then
      RETURN false;

    Auf.A.Aktionstyp      # c_Akt_RLFS;
    Auf.A.TerminEnde      # aDatum;
/**
//    Auf.A.Materialnr      # vNeueNr;
  Auf.A.Menge         # Lfs.P.Menge.Einsatz;
  Auf.A.MEH           # Lfs.P.MEH.Einsatz;
  Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
  Auf.A.Menge.Preis   # 0.0;

  if (Auf.P.MEH.Preis=Lfs.P.MEH) then
    Auf.A.Menge.Preis # Lfs.P.Menge;

  "Auf.A.Stückzahl"   # "Lfs.P.Stück";
  Auf.A.Gewicht       # Lfs.P.Gewicht.Brutto;
  Auf.A.Nettogewicht  # Lfs.P.Gewicht.Netto;

  Auf.A.ArtikelNr       # Lfs.P.ArtikelNr;
  Auf.A.Charge          # Lfs.P.Art.Charge;
  Auf.A.Charge.Adresse  # Lfs.P.Art.Adresse;
  Auf.A.Charge.Anschr   # Lfs.P.Art.Anschrift;
**/
    Auf.A.Bemerkung       # LFs.P.Bemerkung;
    if (Auf.A.Bemerkung='') then Auf.A.Bemerkung # Art.C.Bezeichnung;

    Auf.A.EKPreisSummeW1  # 0.0;
    Auf.A.InterneKostW1   # 0.0;

    vOk # Auf_A_Data:NeuAnlegen(y, (Lfs.P.Auftragspos2<>0))=_rOK;
    if (vOK=false) then begin
      Error(010010, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
  end;

  // alles ok !

  RETURN true;
end;


//========================================================================
// Pos_Verbuchen_Mat  +ERR
//    1. Reservierung löschen
//    2. ggf. Material splitten (anhand Stückzahl)
//       + ggf. Reservierungen auf Rest verschieben
//    3. Material auf geliefert setzen
//    4. ggf. neue Restkarte in fremde Lieferscheine nachtragen
//    5. Auf- und Mat-Aktion auf LFS setzen
//    6. Versandmenge am Auftrag abziehen
//========================================================================
sub Pos_Verbuchen_Mat(
  aDatum        : date;
  aZeit         : time;
  aPauschalOK   : logic;
  var aPreisOK  : logic;
) : logic;
local begin
  Erx       : int;
  vOk       : logic;
  vMenge    : float;
  vNeueNr   : int;
  vAlteNr   : int;
  vSplit    : logic;
  vGew      : float;
  vX        : float;
  vAnz      : int;

  vTeil     : float;
  vKosten   : float;
  vEK       : float;
end;
begin
  Erx # RecLink(200,441,4,_RecFirst);   // Material holen
  if (Erx>_rLocked) then begin
    Error(010001, AInt(Lfs.P.Position)+'|'+AInt(LFs.P.Materialnr));
    RETURN false;
  end;

  // Material prüfen***************************
  if ("Mat.Löschmarker"='*') then begin
    Error(010002, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
    RETURN false;
  end;
  if (lfs.P.Auftragsnr<>0) and (Mat.Auftragsnr<>0) and (Mat.AuftragsNr<>Lfs.P.Auftragsnr) then begin
    Error(010003, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
    RETURN false;
  end;

  // Reservierung löschen************************
  if (Lfs.P.ReservierungNr<>0) then begin
    Erx # RecLink(203,441,6,_RecFirst);
    if (Erx<>_rOK) then begin
      Error(010004, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;
    if (Mat_Rsv_Data:Entfernen()=false) then begin
      Error(010004, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;
  end;

  // SPLITTEN???
  vNeueNr # Lfs.P.Materialnr;
  vAlteNr # vNeueNr;
  if ("Lfs.P.Stück"<>Mat.Bestand.Stk) then begin
    vSplit # y;
    // Splitten schiebt Reservierungen weiter und setzt VLDAWs um
    if (Mat_Data:Splitten("Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Lfs.P.Gewicht.Brutto, 0.0, aDatum, aZeit, var vNeueNr, '')=false) then begin
      Error(010005, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;

    Mat.Nummer # vAlteNr;
    Erx # RecRead(200,1,_recLock);   // altes Restmateiral holen
    if (Erx=_rOK) then begin
      Mat_Data:SetStatus(c_Status_Frei);
      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    end;
    if (erx<>_rOK) then begin
      Error(010005, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;
   

    Mat.Nummer # vNeueNr;
    Erx # RecRead(200,1,_recLock);   // neues abgeplittetes Material holen
    if (Erx=_rOK) then begin
      Mat.Eingangsdatum   # aDatum;
      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    end;
    if (Erx<>_rOK) then begin
      Error(010005, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;
  end;

  // Materialreservierungen prüfen**************
  //if (RecLinkInfo(203,200,13,_RecCount)<>0) then begin
  //  Error(010006, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
  // RETURN false;
  //end;


  // Materialstatus setzen **********************
  if (Mat.Status<700) or (Mat.Status>799) then begin
    Erx # Mat_Data:Read(vNeueNr,_recLock,0,y);
    if (Erx<>200) then begin
      Error(010005, AInt(Lfs.P.Position)+'|'+AInt(vNeueNr));
      RETURN false;
    end;
    if (Lfs.P.Auftragsnr<>0) and (Lfs.Kundennummer<>0) then begin
      Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
      if (Erx>_rLocked) then RecBufClear(835);
      if (AAr.KonsiYN=n) then begin
        Mat_Data:SetStatus(c_Status_Geliefert);

        // "Mat.Löschmarker"   # '*';
        Mat_Data:SetLoeschmarker('*');

        Mat.Ausgangsdatum   # aDatum;
        Mat.VK.Kundennr     # Lfs.Kundennummer;
        Mat.Auftragsnr      # Lfs.P.Auftragsnr;
        Mat.Auftragspos     # Lfs.P.Auftragspos;
        Mat.KommKundennr    # Lfs.P.Kundennummer;
      end
      else begin  // KONSI
        Mat_Data:SetStatus(c_Status_VSBKonsi);
        Mat.LagerStichwort  # '';
        Mat.Lageradresse    # Lfs.Zieladresse;
        Mat.Lageranschrift  # Lfs.Zielanschrift;
        Mat.VK.Kundennr     # Lfs.Kundennummer;
        Mat.Auftragsnr      # Lfs.P.Auftragsnr;
        Mat.Auftragspos     # Lfs.P.Auftragspos;
        Mat.KommKundennr    # Lfs.P.Kundennummer;
      end;
    end
    else begin
      // 2022-10-25 AH      Proj. 2228/157, damit Ba-FM anderen Status geben kann (um 1000 erhöhen)
      if (Mat.Status<1000) then
        Mat_Data:SetStatus(c_Status_Frei)
      else
        Mat_Data:SetStatus(Mat.Status-1000);
    end;
    Erx # Mat_data:Replace(_RecUnlock,'AUTO');
    if (erx<>_rOK) then begin
      Error(010007, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;
  end;

  // LfsPosition in LFS umwandeln ******************
  if (vNeueNr<>vAlteNr) then begin
    Erx # RecRead(441,1,_recLock);
    if (erx=_rOK) then begin
      Lfs.P.Materialnr # vNeueNr;
      Erx # RekReplace(441,_recUnlock,'AUTO');
    end;
    if (erx<>_rOK) then begin
      Error(010008, AInt(Lfs.P.Position));
      RETURN false;
    end;
  end;

/***
  // KOSTEN bei NICHT BA-LFS....
  if (Lfs.zuBA.Nummer=0) and
    (Lfs.Kosten.Pro<>0.0) and (Lfs.Kosten.MEH<>'') and (Lfs.Kosten.PEH<>0) then begin

    _PosKosten(200, var vTeil, var vKosten);

    if (Lfs.P.Gewicht.Brutto<>0.0) then vKostPro # Rnd(vKosten * 1000.0 / Lfs.P.Gewicht.Brutto,2)
    else vKostPro # 0.0;
    vKosten # Rnd(vKosten,2)
  end;
***/
  // LFS-Kosten bei LFA kommen über BA !!!
  if (Lfs.P.zuBA.Nummer=0) then
    aPreisOK # BerechneLfsKosten(200, aPauschalOK, var vKosten);


  // VLDAW Aktion in LFS umwandeln ******************
  if (Lfs.P.Auftragsnr<>0) and (Lfs.Kundennummer<>0) then begin
    RecBufClear(404);
    Auf.A.Aktionsnr     # Lfs.P.Nummer;
    Auf.A.Aktionspos    # Lfs.P.Position;
    Auf.A.Aktionspos2   # 0;
    Auf.A.Aktionstyp    # c_Akt_VLDAW;
    Erx # RecRead(404,2,0);
    if (Erx=_rNoRec) or
      (Auf.A.Aktionsnr<>Lfs.P.Nummer) or
      (Auf.A.AktionsPos<>Lfs.P.Position) or
      (Auf.A.AktionsPos2<>0) or
      (Auf.A.Rechnungsnr<>0) or
      (Auf.A.AktionsTyp<>c_Akt_VLDAW) then begin
      Error(010009, AInt(Lfs.P.Position)+'|'+c_Akt_VLDAW);
      RETURN false;
    end;
    Erx # RekDelete(404,0,'AUTO');
    if (erx<>_rOK) then RETURN false;
/*
debug('delA : '+cnvai(Auf.A.Aktionsnr)+'/'+cnvai(auf.a.Aktionspos)+'/'+cnvai(auf.a.Aktionspos2)+'/'+Auf.A.Aktionstyp);
debug('delB : '+cnvai(Auf.A.Nummer)+'/'+cnvai(auf.a.position)+'/'+cnvai(auf.a.position2)+'/'+cnvai(auf.a.aktion)+'  Erx');
  "Auf.A.Stückzahl" # Mat.Bestand.Stk;
  Auf.A.Gewicht     # Mat.Bestand.Gew;
  Auf.A.Menge       # Lib_Einheiten:WandleMEH(404, "Auf.A.Stückzahl", Auf.A.Gewicht, Auf.A.Gewicht, Auf.A.MEH , Auf.A.MEH);
*/
    Auf.A.Aktionstyp    # c_Akt_LFS;
    Auf.A.Aktionsdatum  # aDatum;
    Auf.A.TerminStart   # aDatum;
    Auf.A.TerminEnde    # aDatum;

    // 2023-02-07 AH  : war mal für BFS, Proj. 2333/18/1
    if (Set.Installname='BFS') then begin // 2023-03-07 AH
      if (Lfs.Lieferdatum<>0.0.0) then begin
        Auf.A.TerminStart   # Lfs.Lieferdatum;
        Auf.A.TerminEnde    # Lfs.Lieferdatum;
      end;
      // 24.11.2020 AH:
      if (Lfs.zuBA.Nummer<>0) and (BAG.P.Nummer=Lfs.zuBA.Nummer) and
        (BAG.P.Position=Lfs.zuBA.Position) then begin
        if (BAG.P.Plan.Startdat<>0.0.0) then
          Auf.A.TerminStart   # BAG.P.Plan.StartDat;
        if (BAG.P.Plan.Enddat<>0.0.0) then
          Auf.A.TerminEnde    # BAG.P.Plan.EndDat;
      end;
    end;
    
    Auf.A.Materialnr      # vNeueNr;
    RecLink(401,441,5,0);   // AufPos lesen

    if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then   // ggf. Artikelnummer für 209er übernehmen
      Auf.A.ArtikelNr # Mat.Strukturnr;

    Auf.A.EKPreisSummeW1  # Rnd(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0,2);
    // bei LFA kommen Kosten beim ABSCHLUSS
    if (Lfs.P.zuBA.Nummer=0) then
      Auf.A.InterneKostW1   # Rnd(Mat.Kosten * Mat.Bestand.Gew / 1000.0,2);

    // bei LFA kommen Kosten beim ABSCHLUSS
    if (Lfs.P.zuBA.Nummer=0) then
      aPreisOK # BerechneEKundKostenAusVorkalkulation(200, aPauschalOK, var vEK, var vKosten, var vOK);

    if (vOK) then
      Auf.A.EKPreisSummeW1  # Rnd(vEK,2);
    Auf.A.InterneKostW1     # Auf.A.InterneKostW1 + Rnd(vKosten,2);

    if (Auf.A.MEH.Preis='kg') or (Auf.A.MEH.Preis='t') then begin
      // 16.09.2019 AH:
      if (Lfs.P.MEH='kg') then
        Auf.A.Menge.Preis # Lfs.P.Menge;
      if (Lfs.P.MEH='t') then
        Auf.A.Menge.Preis # Lfs.P.Menge * 1000.0;

      if (Auf.A.Menge.Preis=0.0) then begin
        if (VwA.Nummer<>Auf.P.Verwiegungsart) then begin
          Erx # RecLink(818,401,9,_recfirst); // Verwiegungsart holen
          if (Erx>_rLocked) then begin
            RecBufClear(818);
            VWa.NettoYN # Y;
          end;
        end;
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Lfs.P.Gewicht.Netto
        else
          Auf.A.Menge.Preis # Lfs.P.Gewicht.Brutto;
      end;

      if (Auf.A.Menge.Preis=0.0) then begin
        if (VWa.NettoYN) then
          Auf.A.Menge.Preis # Mat.Gewicht.Netto
        else
          Auf.A.Menge.Preis # Mat.Gewicht.Brutto;
      end;

        if (Auf.A.MEH.Preis='t') then
          Auf.A.Menge.Preis # Rnd(Auf.A.Menge.Preis / 1000.0,Set.Stellen.Menge);
    end;


/**
    Erx # RecLink(818,401,9,_recFirst);
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    // 14.07.2015 RÜCKSTELLUNGEN einbeziehen....
    FOR Erx # RecLink(405,401,7,_RecFirst)
    LOOP Erx # RecLink(405,401,7,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if ("Auf.K.RückstellungYN"=false) then CYCLE;

      // Basisartikel?
      if (Auf.K.MengenbezugYN) and (Auf.K.MEH=Auf.P.MEH.Preis) and (Auf.K.Bezeichnung=Lfs.P.Artikelnr) and (Lfs.P.Artikelnr<>'') then CYCLE;

      if (Auf.K.PEH=0) then Auf.K.PEH # 1;
      if (VWA.NettoYN) then
        vGew # Lfs.P.Gewicht.Netto
      else
        vGew # Lfs.P.Gewicht.Brutto;

      if (Auf.K.MengenbezugYN) then begin
        vMenge # Lib_Einheiten:WandleMEH(250, "Lfs.P.Stück", vGew, Lfs.P.Menge, Lfs.P.MEH, Auf.K.MEH);
        vKosten # vKosten + Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * vMenge,2);
      end
      else begin  // PAUSCHAL?
        vX # Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * Auf.K.Menge,2);
        _PosGesamtGewichtZuKommission(Lfs.P.Auftragsnr, Lfs.P.Auftragspos, var vMenge, var vAnz);
        if (vMenge=0.0) then
          vX # Rnd(Lib_Berechnungen:Dreisatz(vX, cnvfi(vAnz), 1.0), 2)
        else
          vX # Rnd(Lib_Berechnungen:Dreisatz(vX, vMenge, vGew), 2)
        vKosten # vKosten + vX;
      end;

    END;

    if (Lfs.P.Gewicht.Brutto<>0.0) then vKostPro # Rnd(vKosten * 1000.0 / Lfs.P.Gewicht.Brutto,2)
    else vKostPro # 0.0;
    vKosten # Rnd(vKosten,2)

    Auf.A.InterneKostW1   # Auf.A.InterneKostW1 + Rnd(vKosten,2);
***/

//debug('aufaktkosten:'+anum(vKosten,2));

    vOk # Auf_A_Data:NeuAnlegen(y, (Lfs.P.Auftragspos2<>0))=_rOK;
    if (vOK=false) then begin
      Error(010010, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
  end;

  // ggf. Differenzen buchen
  if (vSplit=false) then begin
    vMenge # Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Gew, 'kg', Auf.A.MEH);
    Erx # Mat_Data:Read(vNeueNr,_recLock,0,y);
    if (Erx<>200) then begin
      Error(010005, AInt(Lfs.P.Position)+'|'+AInt(vNeueNr));
      RETURN false;
    end;

    vGew # Mat.Bestand.Gew;
    Mat.Gewicht.Netto   # LFS.P.Gewicht.Netto;
    Mat.Gewicht.Brutto  # LFS.P.Gewicht.Brutto;
    Mat.Bestand.Gew     # 0.0;  // freimachen zur Berechnung
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    if  (Erx<>_rOK) then begin
      Error(010005, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;

    vGew # Rnd(Mat.Bestand.Gew - vGew, Set.Stellen.Gewicht);
    if (vGew<>0.0) then begin
      if (Mat_Data:Bestandsbuch(0, vGew, 0.0, 0.0, 0.0, c_akt_lfs+' '+cnvai(LFS.P.Nummer)+'/'+cnvai(LFS.P.Position), aDatum, aZeit, c_akt_lfs,LFS.P.Nummer,LFS.P.Position)=false) then
        RETURN false;
        
      // eigene Schrottumlage...
      if ("Set.Mat.!InternUmlag"=false) then begin
        RecBufClear(204);
        Mat.A.Aktionsmat    # Mat.Nummer;
        Mat.A.Aktionstyp    # c_Akt_Mat_Umlage;
        Mat.A.Bemerkung     # c_AktBem_Mat_Umlage;
        Mat.A.Aktionsdatum  # aDatum;
        Mat.A.Terminstart   # Mat.A.Aktionsdatum;
        Mat.A.Terminende    # Mat.A.Aktionsdatum;
        Mat.A.Adressnr      # 0;
  //debugx('KEY200 : '+anum(vGew,0)+' * '+anum(Mat.EK.Effektiv,2)+'€ / '+anum(Mat.Bestand.Gew,2));
        if (Mat.Bestand.Gew<>0.0) then
          Mat.A.KostenW1      # Rnd(- (vGew * Mat.EK.Effektiv / Mat.Bestand.Gew),2);
        Erx # Mat_A_Data:Insert(0,'AUTO');
        if (Erx<>_rOK) then RETURN false;
        if (Mat_A_Data:Vererben()=false) then RETURN false;
      end;
    end;
  end;


  // Mataktion löschen  09.08.2012 AI
  RecBufClear(204);
  Mat.A.AktionsTyp  # c_Akt_VLDAW;
  Mat.A.Aktionsnr   # Lfs.P.Nummer;
  Mat.A.AktionsPos  # Lfs.P.Position;
  Erx # RecRead(204,2,0);
  if (Erx=_rOK) or (Erx=_rMultikey) then begin
    Erx # RekDelete(204,0,'AUTO');
    if (Erx<>_rOK) then RETURN false;
  end;

  RecLink(818,200,10,_recFirst);  // Verwiegungsart Material holen
  if (Erx>_rLocked) then begin
    RecBufClear(818);
    VwA.NettoYN # y;
  end;

  // Mataktion anlegen ***************
  begin
    RecBufClear(204);
    Mat.A.Materialnr    # vNeueNr;
    Mat.A.Aktionsmat    # vNeueNr;
    Mat.A.Aktionstyp    # c_Akt_LFS;
    Mat.A.Aktionsnr     # Lfs.P.Nummer;
    Mat.A.Aktionspos    # Lfs.P.Position;
    Mat.A.Aktionspos2   # 0;
    Mat.A.Aktionsdatum  # aDatum;
    Mat.A.TerminStart   # aDatum;
    
    // 2023-02-07 AH  : Neu, Proj. 2333/18/1
    Mat.A.TerminEnde    # aDatum;
    if (Set.Installname='BFS') then begin // 2023-03-07 AH
      if (Lfs.Lieferdatum<>0.0.0) then begin
        Mat.A.TerminStart   # Lfs.Lieferdatum;
        Mat.A.TerminEnde    # Lfs.Lieferdatum;
      end;
      if (Lfs.zuBA.Nummer<>0) and (BAG.P.Nummer=Lfs.zuBA.Nummer) and
        (BAG.P.Position=Lfs.zuBA.Position) then begin
        if (BAG.P.Plan.Startdat<>0.0.0) then
          Mat.A.TerminStart   # BAG.P.Plan.StartDat;
        if (BAG.P.Plan.Enddat<>0.0.0) then
          Mat.A.TerminEnde    # BAG.P.Plan.EndDat;
      end;
    end;

    Mat.A.Adressnr      # Lfs.Zieladresse;
    "Mat.A.Stückzahl"   # "Lfs.P.Stück";
    if (VWA.NettoYN) then
      Mat.A.Gewicht # Lfs.P.Gewicht.Netto
    else
      Mat.A.Gewicht # Lfs.P.Gewicht.Brutto;
    Mat.A.Nettogewicht  # Lfs.P.Gewicht.Netto;
    if (Mat.Bestand.Gew<>0.0) then
      Mat.A.KostenW1    # Rnd(vKosten / Mat.Bestand.Gew * 1000.0,2)
//    Mat.A.KostenW1      # Rnd(vKostPro,2)

//debug('mat kosten/t:'+anum(vKostpro,2)+' bei '+anum(mat.a.gewicht,2)+'kg   =  '+anum(vKostpro * mat.a.gewicht / 1000.0,2));
    // für MATMEH
    if (Mat.MEH=Lfs.P.MEH) then
      Mat.A.Menge       # Lfs.P.Menge;

    Erx # Mat_A_Data:Insert(0,'AUTO');
    if  (Erx<>_rOK) then RETURN false;
    if (Mat.A.KostenW1<>0.0) then begin
      if (Mat_A_Data:Vererben()=false) then RETURN false;
    end;
  end;


  RETURN true;
end;


//========================================================================
// Pos_Verbuchen_Art  +ERR
//
//========================================================================
sub Pos_Verbuchen_Art(
  aDatum        : date;
  aPauschalOK   : logic;
  var aPreisOK  : logic;
) : logic;
local begin
  Erx       : int;
  vOk       : logic;
  vMenge    : float;
  vGew      : float;
  vStk      : int;

  vMenge2   : float;
  vGew2     : float;
  vStk2     : int;
  vNr       : int;
  vPos1     : int;
  vPos2     : int;

  vKosten   : float;
  vTeil     : float;
  v441      : int;
  vEK       : float;
  vX        : float;
  vAnz      : int;
end;
begin


  Erx # RecLink(250,441,3,_RecFirst)  // Artikel holen
  if (Erx>_rLocked) then begin
//    RANSBRK;
    Error(010001, AInt(Lfs.P.Position)+'|'+(LFs.P.Artikelnr));
    RETURN false;
  end;

  vMenge # Lfs.P.Menge.Einsatz;
  vStk   # "Lfs.P.Stück";

  vNr   # Lfs.P.Auftragsnr;
  vPos1 # Lfs.P.Auftragspos;
  vPos2 # Lfs.P.Auftragspos2;

// 06.05.2010 AI
  // Reservierung entfernen
  if (Lfs.P.zuBA.Nummer<>0) then begin
    vOK # Art_Data:Reservierung(Lfs.P.Artikelnr, Lfs.P.Art.Adresse, LFs.P.Art.Anschrift, Lfs.P.Art.Charge, 0, c_Akt_BAInput, LFS.P.zuBA.Nummer, Lfs.P.zuBa.InputID, 0, -vMenge, -vStk, 0);
  end
  else begin
    vOK # Art_Data:Reservierung(Lfs.P.Artikelnr, Lfs.P.Art.Adresse, LFs.P.Art.Anschrift, Lfs.P.Art.Charge, 0, c_Auf, LFS.P.Auftragsnr, Lfs.P.Auftragspos, Lfs.P.Auftragspos2, -vMenge, -vStk, 0);
  end;

  if (vOK=false) then begin
//    RANSBRK;
    Error(010004, AInt(Lfs.P.Position));
    RETURN false;
  end;

  // Artikel abbuchen
  RecBufClear(252);
  Art.C.ArtikelNr       # Lfs.P.ArtikelNr;
  Art.C.Charge.Intern   # Lfs.P.Art.Charge;
  RecBufClear(253);
  Art.J.Datum           # aDatum;
  Art.J.Bemerkung       # StrCut(Translate('Lieferschein')+' '+AInt(Lfs.P.Nummer)+'/'+AInt(LFs.P.Position)+' '+Lfs.Kundenstichwort,1,64);
  "Art.J.Stückzahl"     # -vStk;
  Art.J.Menge           # -vMenge;
  "Art.J.Trägertyp"     # 'LFS';
  "Art.J.Trägernummer1" # Lfs.P.Nummer;
  "Art.J.Trägernummer2" # Lfs.P.Position;
  "Art.J.Trägernummer3" # 0;
  vOK # Art_Data:Bewegung(0.0,0.0);
  if (vOK=false) then begin
//    RANSBRK;
    Error(010011, AInt(Lfs.P.Position)+'|'+Lfs.P.ArtikelNr);
    RETURN false;
  end;


  // Stückliste ggf. holen
  RecBufClear(409);
  if (Lfs.P.Auftragspos2<>0) then begin
    Auf.SL.Nummer   # LFs.P.AuftragsNr;
    Auf.SL.Position # Lfs.P.Auftragspos;
    Auf.SL.lfdNr    # Lfs.P.AuftragsPos2;
    Erx # RecRead(409,1,0);
    if (Erx<>_rOK) then begin
//      RANSBRK;
      Error(010011, AInt(Lfs.P.Position)+'|'+Lfs.P.ArtikelNr);
      RETURN false;
    end;
  end;


  // VLDAW Aktion umwandeln
  RecBufClear(404);
  Auf.A.Aktionstyp    # c_Akt_VLDAW;
  Auf.A.Aktionsnr     # Lfs.P.Nummer;
  Auf.A.Aktionspos    # Lfs.P.Position;
  Erx # RecRead(404,2,0);
/*
  if (Erx<>_rNoRec) and (Auf.A.AktionsTyp=c_Akt_VLDAW) and
    (Auf.A.Aktionsnr=Lfs.P.Nummer) and
    (Auf.A.AktionsPos=Lfs.P.Position) then begin
    if (Auf_A_Data:Entfernen()=false) then begin
      RANSBRK;
      Msg(441x103,AInt(Lfs.P.Position),0,0,0);
      RETURN false;
    end;
  end;
*/
  if (Erx=_rNoRec) or (Auf.A.AktionsTyp<>c_Akt_VLDAW) or
    (Auf.A.Aktionsnr<>Lfs.P.Nummer) or
    (Auf.A.Rechnungsnr<>0) or
    (Auf.A.AktionsPos<>Lfs.P.Position) then begin
//    RANSBRK;
    Error(010009, AInt(Lfs.P.Position)+'|'+c_Akt_VLDAW);
    RETURN false;
  end;

/***
  // KOSTEN bei JEDER Art von LFS
//  if (Lfs.zuBA.Nummer=0) and
  if
    (Lfs.Kosten.Pro<>0.0) and (Lfs.Kosten.MEH<>'') and (Lfs.Kosten.PEH<>0) then begin
    _PosKosten(250, var vTeil, var vKosten);
    vKosten # Rnd(vKosten,2)
  end;
***/
  // LFS-Kosten bei LFA kommen über BA !!!
  if (Lfs.P.zuBA.Nummer=0) then
    aPreisOK # BerechneLfsKosten(250, aPauschalOK, var vKosten);

/***
  // Kalkulationspreis??
  vOK # n;
  if (Wgr.Nummer<>Art.Warengruppe) then
    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen
  // 14.07.2015 RÜCKSTELLUNGEN einbeziehen....
  FOR Erx # RecLink(405,401,7,_RecFirst)
  LOOP Erx # RecLink(405,401,7,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Auf.K.PEH=0) then Auf.K.PEH # 1;

    // Kalkulationspreis??
    if (WGr.OhneBestandYN) and("Art.ChargenführungYN"=false) then begin
      if (Auf.K.MengenbezugYN) and (Auf.K.MEH=Auf.P.MEH.Preis) and (Auf.K.Bezeichnung=Lfs.P.Artikelnr) then begin
        vMenge # Lib_Einheiten:WandleMEH(250, "Auf.A.Stückzahl", Auf.A.Nettogewicht, Auf.A.Menge, Auf.A.MEH, Auf.K.MEH);
        vEK # vEK + Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * vMenge,2);
        vOK # y;
      end;
    end;

    if ("Auf.K.RückstellungYN"=false) then CYCLE;

    // Basisartikel?
    if (Auf.K.MengenbezugYN) and (Auf.K.MEH=Auf.P.MEH.Preis) and (Auf.K.Bezeichnung=Lfs.P.Artikelnr) and (Lfs.P.Artikelnr<>'') then CYCLE;

    vGew # Lfs.P.Gewicht.Netto;   // Artikel immer Nettogewicht

    if (Auf.K.MengenbezugYN) then begin
      vMenge # Lib_Einheiten:WandleMEH(250, "Lfs.P.Stück", vGew, Lfs.P.Menge, Lfs.P.MEH, Auf.K.MEH);
      vKosten # vKosten + Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * vMenge,2);
    end
    else begin  // PAUSCHAL?
      vX # Rnd(Auf.K.Preis / CnvFI(Auf.K.PEH) * Auf.K.Menge,2);
      _PosGesamtGewichtZuKommission(Lfs.P.Auftragsnr, Lfs.P.Auftragspos, var vMenge, var vAnz);
      if (vMenge=0.0) then
        vX # Rnd(Lib_Berechnungen:Dreisatz(vX, cnvfi(vAnz), 1.0), 2)
      else
        vX # Rnd(Lib_Berechnungen:Dreisatz(vX, vMenge, vGew), 2)
      vKosten # vKosten + vX;
    end;

  END;
  Erx # RekLink(814,400,8,_recFirst); // Währung holen
  if ("Auf.WährungFixYN") then
    Wae.VK.Kurs # "Auf.Währungskurs";
  if (Wae.VK.Kurs=0.0) then
    Wae.VK.Kurs # 1.0;
  vEK           # Rnd(vEK / Wae.VK.Kurs,2)
***/


  // Aktion anlegen
//  RecBufClear(404);
  Erx # RekDelete(404,0,'AUTO');
  if (erx<>_rOK) then RETURN false;
  
  Auf.A.Aktionstyp    # c_Akt_LFS;
  Auf.A.Aktionsnr     # Lfs.P.Nummer;
  Auf.A.Aktionspos    # Lfs.P.Position;
  Auf.A.Aktionsdatum  # aDatum;
  Auf.A.TerminStart   # aDatum;
  Auf.A.TerminEnde    # aDatum;
  if (Set.Installname='BFS') then begin
    if (Lfs.Lieferdatum<>0.0.0) then begin    // 18.01.2021 AH: dank BFS
      Auf.A.TerminStart   # Lfs.Lieferdatum;
      Auf.A.TerminEnde    # Lfs.Lieferdatum;
    end;
  end;
  //Aufx.A.Adressnummer  # Adr.Nummer;

  Auf.A.Menge         # Lfs.P.Menge.Einsatz;
  Auf.A.MEH           # Lfs.P.MEH.Einsatz;

// LFA-Update
//  Auf.A.Menge.Preis   # Lfs.P.Menge;
//  Auf.A.MEH.Preis     # Lfs.P.MEH;
  Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
  Auf.A.Menge.Preis   # 0.0;
  // 16.04.2013:
  if (Auf.P.MEH.Preis=Lfs.P.MEH) then
    Auf.A.Menge.Preis # Lfs.P.Menge;
//debugx(anum(Auf.A.Menge.Preis,2));

  "Auf.A.Stückzahl"   # "Lfs.P.Stück";
  Auf.A.Gewicht       # Lfs.P.Gewicht.Brutto;
  Auf.A.Nettogewicht  # Lfs.P.Gewicht.Netto;

  Auf.A.ArtikelNr       # Lfs.P.ArtikelNr;
  Auf.A.Charge          # Lfs.P.Art.Charge;
  Auf.A.Charge.Adresse  # Lfs.P.Art.Adresse;
  Auf.A.Charge.Anschr   # Lfs.P.Art.Anschrift;
//  if (Auf.A.Bemerkung='') then Auf.A.Bemerkung # Art.C.Bezeichnung;
  Auf.A.Bemerkung       # LFs.P.Bemerkung;
  if (Auf.A.Bemerkung='') then Auf.A.Bemerkung # Art.C.Bezeichnung;

//  BestimmeArtikelEKPreis(var vEK);

  // bei LFA kommen Kosten beim ABSCHLUSS
  vOK # false;    // 05.02.2016 AH
  if (Lfs.P.zuBA.Nummer=0) then
    aPreisOK # BerechneEKundKostenAusVorkalkulation(250, aPauschalOK, var vEK, var vKosten, var vOK);

  if (vOK=false) then BestimmeArtikelEKPreis(var vEK);

  Auf.A.EKPreisSummeW1  # Rnd(vEK,2);
  Auf.A.InterneKostW1   # Rnd(vKosten,2);

  vOk # Auf_A_Data:NeuAnlegen(y,y)=_rOK;
  if (vOK=false) then begin
//    RANSBRK;
    Error(010010, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;

  // alles ok !
  RETURN true;
end;


//========================================================================
//========================================================================
sub AnAuftragsAufpreis(aDatum : date) : logic;
local begin
  vOK : logic;
end;
begin
  // Aufpreis als KOPFAUFPREIS anlegen
  Auf.Nummer          # Lfs.P.Auftragsnr;
  vOk # n;
  
  if (Lib_Faktura:ErzeugeVpgAktion(Lfs.P.Auftragsnr, Art.Nummer, Art.Stichwort, Lfs.P.MEH, LFs.P.Menge, false)=false) then begin
    Error(010012, AInt(Lfs.P.Position));
    RETURN false;
  end;
/***
  RecBufClear(403);
  Auf.Z.Nummer        # Lfs.P.Auftragsnr;
  Auf.Z.Vpg.ArtikelNr # Lfs.P.ArtikelNr;
  Erx # RecRead(403,3,0);
  WHILE (Erx<=_rMultikey) and (Auf.Z.Nummer=Lfs.P.Auftragsnr) and
    (Auf.Z.Vpg.ArtikelNr=Lfs.P.ArtikelNr) do begin
    if (Auf.Z.Position=0) and (Auf.Z.Vpg.ArtikelNr=Lfs.P.ArtikelNr) and
      (Lfs.P.MEH=Auf.Z.MEH) and (Auf.Z.Rechnungsnr=0) then begin
      vOK # y;  // Aufpreis bereits vorhanden!
      BREAK;
    end;
    Erx # RecRead(403,3,3,_RecNext);
  END;

  if (vOK) then begin
    xRecRead(403,1,_RecLock);
    Auf.Z.Menge     # Auf.Z.Menge + Lfs.P.Menge;
    Auf.Z.Vpg.OKYN  # n;
    Erx # RekReplace(403,_recUnlock,'AUTO');
  end
  else begin
    RecBufClear(403);
    Auf.Z.Nummer        # Lfs.P.Auftragsnr;
    Auf.Z.Position      # 0;
    "Auf.Z.Schlüssel"   # 'VPG';
    Auf.Z.Menge         # Lfs.P.Menge;
    Auf.Z.MEH           # Lfs.P.MEH;
    Auf.Z.PEH           # 1;
    Auf.Z.MengenbezugYN   # n;
    Auf.Z.RabattierbarYN  # n;
    Auf.Z.NeuberechnenYN  # n;
    Auf.Z.Preis         # 0.0;
    Auf.Z.Bezeichnung   # Art.Stichwort;
    Auf.Z.Vpg.ArtikelNr # Lfs.P.Artikelnr
    Auf.Z.Vpg.OKYN      # n;
    Auf.Z.Anlage.Datum  # today;
    Auf.Z.Anlage.Zeit   # now;
    Auf.Z.Anlage.User   # gUserName;
    Auf.Z.lfdNr         # 0;
    REPEAT
      Auf.Z.lfdNr # Auf.Z.lfdNr + 1;
      Erx # RekInsert(403,0,'AUTO');
      if (erx _rDEADLCKK) then FALSE
    UNTIL (Erx=_rOK);
  end;
  if (Erx<>_rOK) then begin
    Error(010012, AInt(Lfs.P.Position));
    RETURN false;
  end;
***/

  // 25.11.2019 Auch als Aktion anlegen -----------------------
  RecBufClear(404);
  Auf.A.Aktionstyp    # c_Akt_LFS_VPG;
  Auf.A.Aktionsnr     # Lfs.P.Nummer;
  Auf.A.Aktionspos    # Lfs.P.Position;
  Auf.A.Aktionsdatum  # aDatum;
  Auf.A.TerminStart   # aDatum;
  Auf.A.TerminEnde    # aDatum;
  if (Set.Installname='BFS') then begin
    if (Lfs.Lieferdatum<>0.0.0) then begin    // 18.01.2021 AH: dank BFS
      Auf.A.TerminStart   # Lfs.Lieferdatum;
      Auf.A.TerminEnde    # Lfs.Lieferdatum;
    end;
  end;
  Auf.A.Menge         # Lfs.P.Menge.Einsatz;
  Auf.A.MEH           # Lfs.P.MEH.Einsatz;
  Auf.A.MEH.Preis     # Auf.Z.MEH;    // <<<<
  Auf.A.Menge.Preis   # 0.0;
  if (Auf.P.MEH.Preis=Lfs.P.MEH) then
    Auf.A.Menge.Preis # Lfs.P.Menge;
  "Auf.A.Stückzahl"   # "Lfs.P.Stück";
  Auf.A.Gewicht       # Lfs.P.Gewicht.Brutto;
  Auf.A.Nettogewicht  # Lfs.P.Gewicht.Netto;

  Auf.A.ArtikelNr       # Lfs.P.ArtikelNr;
  Auf.A.Charge          # Lfs.P.Art.Charge;
  Auf.A.Charge.Adresse  # Lfs.P.Art.Adresse;
  Auf.A.Charge.Anschr   # Lfs.P.Art.Anschrift;
  Auf.A.Bemerkung       # Lfs.P.Bemerkung;
  if (Auf.A.Bemerkung='') then Auf.A.Bemerkung # Art.C.Bezeichnung;
//  Auf.A.EKPreisSummeW1  # Rnd(vEK,2);
//  Auf.A.InterneKostW1   # Rnd(vKosten,2);

//  vOk # Auf_A_Data:NeuAnlegen(y,y);
  vOK # Auf_A_Data:NeuAmKopfAnlegen()=_rOK;
  if (vOK=false) then begin
    Error(010012, AInt(Lfs.P.Position));
    RETURN false;
  end;

  RETURn true;
end;


//========================================================================
// Pos_Verbuchen_Vpg  +ERR
//
//========================================================================
sub Pos_Verbuchen_Vpg(
  aDatum      : date;
//  aKostenGes  : float;
//  aProPosYN   : logic;
) : logic;
local begin
  Erx     : int;
  vOk     : logic;
  vMenge  : float;
end;
begin

  Erx # RecLink(250,441,3,_RecFirst)
  if (Erx>_rLocked) then begin
//    RANSBRK;
    Error(010001, AInt(Lfs.P.Position)+'|'+LFs.P.Artikelnr);
    RETURN false;
  end;

  // Verpackungs-Artikel abbuchen AUS Lager
  RecBufClear(252);
  Art.C.ArtikelNr     # Lfs.P.ArtikelNr;
  Art.C.Charge.Intern # Lfs.P.Art.Charge;
  Art.C.AdressNr      # Lfs.P.Art.Adresse;
  Art.C.AnschriftNr   # Lfs.P.Art.Anschrift;
//  Art.C.Zustand       # Lfs.P.Art.Zustan
  
  RecBufClear(253);
  Art.J.Datum           # aDatum;
  Art.J.Bemerkung       # StrCut(Translate('Lieferschein')+' '+AInt(Lfs.P.Nummer)+'/'+AInt(LFs.P.Position)+' '+Lfs.Kundenstichwort,1,64);
  "Art.J.Stückzahl"     # -"Lfs.P.Stück";
  Art.J.Menge           # -Lfs.P.Menge.Einsatz;
  "Art.J.Trägertyp"     # 'LFS';
  "Art.J.Trägernummer1" # Lfs.P.Nummer;
  "Art.J.Trägernummer2" # Lfs.P.Position;
  "Art.J.Trägernummer3" # 0;
  vOK # Art_Data:Bewegung(0.0,0.0);
  if (vOK=false) then begin
//    RANSBRK;
    Error(010011, AInt(Lfs.P.Position)+'|'+Lfs.P.ArtikelNr);
    RETURN false;
  end;

  if (AnAuftragsAufpreis(aDatum)=false) then begin
    RETURN false;
  end;
  
  RETURN true;
end;


//========================================================================
// Pos_Verbuchen  +ERR
//          Verbucht einen LFS.Position durch Anlage der Lagerbewegungen
//          und Auftrags-Aktionen
//========================================================================
sub Pos_Verbuchen(
  aDatum        : date;
  aZeit         : time;
  aPauschalOK   : logic;
  var aPreisOK  : logic;
//opt  aKostenGes  : float;
//opt  aProPosYN   : logic;
) : logic;
local begin
  Erx     : int;
  vMenge  : float;
  vKostM  : float;
  vKosten : float;
  vA      : alpha;
end;
begin

  if (Lfs.P.Datum.Verbucht<>0.0.0) then begin
    Error(010013, AInt(Lfs.P.Position));
    RETURN false;
  end;

  if (Lfs.Kundennummer<>0) and (Lfs.P.Auftragsnr<>0) then begin
    // Auftragsposition holen
    Erx # RecLink(401,441,5,_RecFirst);
    if (Erx>_rLocked) then begin
      Error(010014, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
    Erx # RecLink(400,401,3,_RecFirst); //Kopf holen
    if (Erx>_rLocked) then begin
      Error(010014, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
    Erx # RecLink(100,400,1,_RecFirst); // Kunde holen
    if (Erx>_rLocked) then begin
      Error(010016, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
  end
  else begin
    RecBufClear(400);
    RecBufClear(401);
    RecBufClear(100);
  end;


  // *****************************
  // Artikellieferung?
  if (Lfs.P.Materialtyp=c_IO_ART) then begin
    if ("Lfs.RücknahmeYN") then begin
      if (Pos_Verbuchen_Rueck_Art(aDatum)=false) then RETURN false;
    end
    else begin
      if (Pos_Verbuchen_Art(aDatum, aPauschalOK, var aPreisOK)=false) then RETURN false;
    end;
  end;

  // *****************************
  // Verpackung?
  if (Lfs.P.Materialtyp=c_IO_VPG) then begin
    if (Pos_Verbuchen_Vpg(aDatum)=false) then RETURN false;
  end;

  // *****************************
  // Materiallieferung?
  if (Lfs.P.Materialtyp=c_IO_Mat) then begin
    if ("Lfs.RücknahmeYN") then begin
      if (Pos_Verbuchen_Rueck_Mat(aDatum, aZeit)=false) then RETURN false;
    end
    else begin
      if (Pos_Verbuchen_Mat(aDatum, aZeit, aPauschalOK, var aPreisOK)=false) then RETURN false;
    end;
  end;


  // 05.07.2019 AH: z.B. Kreditlimit
  vA # cnvad(aDatum)+'|';
  if (aPauschalOK) then vA # vA + 'Y|' else vA # vA + 'N|';
  if (aPreisOK) then vA # vA + 'Y|' else vA # vA + 'N';
  if (RunAFX('Lfs.P.Verbuchen.Check',vA)<>0) then begin
    if (AfxRes<>_rOK) then RETURN false;
  end;


  Erx # RecRead(441,1,_recLock);
  if (erx=_rOK) then begin
    Lfs.P.Datum.Verbucht # aDatum;
    Erx # RekReplace(441,_recUnlock,'AUTO');
  end;
  if (Erx<>_rOK) then begin
    Error(010008, AInt(Lfs.P.Position));
    RETURN false;
  end;

  // Erfolg !
  RETURN true;
end;


//========================================================================
// Pos_Storno_Mat +ERR
//    1. Auf- und Mat-Aktion löschen
//    2. Material wiederherstellen
//========================================================================
sub Pos_Storno_Mat() : logic;
local begin
  Erx : int;
  vOk : logic;
end;
begin

  Erx # Mat_Data:Read(LFS.P.Materialnr,0,0, true);  // Material holen
  if (Erx<>200) then begin
    Error(010001, AInt(Lfs.P.Position)+'|'+AInt(LFs.P.Materialnr));
    RETURN false;
  end;

  // Material prüfen***************************
  if ("Mat.Löschmarker"<>'*') then begin
    // ST 2019-02-28 Bei Stornierung auf Konsi, ist das Material nie gelöscht und darf nicht auf Fehler laufen
    if (Mat.Status < c_Status_VSBKonsi) OR (Mat.Status  > c_Status_VSBKonsiRahmen) then begin
      Error(010002, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
      RETURN false;
    end;
  end;
  if (Mat.Auftragsnr<>Lfs.P.Auftragsnr) or (Mat.Auftragspos<>Lfs.P.Auftragspos) then begin
    Error(010003, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
    RETURN false;
  end;


  // Material wiederherstellen **********************
  Erx # RecRead(200,1,_recLock);
  if (Erx<>_rOK) then begin
    Error(010001, AInt(Lfs.P.Position)+'|'+AInt(LFs.P.Materialnr));
    RETURN false;
  end;

  // LFA-Storno?
  if (lfs.zuBA.Nummer=0) then
    Mat_Data:SetStatus(c_Status_inVLDAW)
  else
    Mat_Data:SetStatus(c_Status_frei);

  // "Mat.Löschmarker"   # '';
  Mat_Data:SetLoeschmarker('');
  Mat.Ausgangsdatum   # 0.0.0;
  Mat.VK.Kundennr     # 0;
  Mat.Auftragsnr      # 0;
  Mat.Auftragspos     # 0;
  Mat.KommKundennr    # 0;
  Erx # Mat_data:Replace(_RecUnlock,'AUTO');
  if (erx<>_rOK) then begin
    Error(010007, AInt(Lfs.P.Position)+'|'+AInt(Mat.Nummer));
    RETURN false;
  end;


  // alte Aktion entfernen **********************
  RecBufClear(404);
  Auf.A.Aktionstyp    # c_Akt_LFS;
  Auf.A.Aktionsnr     # Lfs.P.Nummer;
  Auf.A.Aktionspos    # Lfs.P.Position;
  Erx # RecRead(404,2,0);
  if (Erx<>_rOk) and (Erx<>_rMultikey) then begin
//    RANSBRK;
    Error(010020,AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    if (Erx=_rLocked) then Error(010020,'Auftragsaktion');
    RETURN false;
  end;
  if (Auf.A.Rechnungsnr<>0) then begin
//    RANSBRK;
    Error(010020,AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;

  // Mataktion löschen
  RecBufClear(204);
  Mat.A.Aktionstyp    # Auf.A.Aktionstyp;
  Mat.A.Aktionsnr     # Auf.A.Aktionsnr;
  Mat.A.Aktionspos    # Auf.A.Aktionspos;
  Mat.A.Aktionspos2   # Auf.A.Aktionspos2;
  Erx # RecRead(204,2,0);
  if (Erx=_rOK) or (Erx=_rMultikey) then begin
    Erx # RekDelete(204,0,'AUTO');
  end;
  if (Erx<>_rOK) then begin
//    RANSBRK;
    Error(010019,AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;
  if (Mat.A.KostenW1<>0.0) then begin
    if (Mat_A_Data:Vererben()=false) then RETURN false;
  end;

  if (Auf_A_Data:Entfernen()=false) then begin
//    RANSBRK;
    Error(010019,AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// Pos_Storno_Art +ERR
//
//========================================================================
sub Pos_Storno_Art() : logic;
local begin
  Erx : int;
  vOk : logic;
end;
begin

  Erx # RecLink(250,441,3,_RecFirst)
  if (Erx>_rLocked) then begin
//    RANSBRK;
    Error(010001, AInt(Lfs.P.Position)+'|'+LFs.P.Artikelnr);
    RETURN false;
  end;


  // alte Aktion entfernen
  RecBufClear(404);
  Auf.A.Aktionstyp    # c_Akt_LFS;
  Auf.A.Aktionsnr     # Lfs.P.Nummer;
  Auf.A.Aktionspos    # Lfs.P.Position;
  Erx # RecRead(404,2,0);
  if (Erx<>_rNoRec) and (Auf.A.AktionsTyp=c_Akt_LFS) and
    (Auf.A.Aktionsnr=Lfs.P.Nummer) and
    (Auf.A.AktionsPos=Lfs.P.Position) then begin
    if (Auf_A_Data:Entfernen()=false) then begin
//      RANSBRK;
      Error(010019,AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
      RETURN false;
    end;
  end;

  // Artikel wieder zubuchen
  RecBufClear(252);
  Art.C.ArtikelNr     # Lfs.P.ArtikelNr;
  Art.C.Charge.Intern # LFs.P.Art.Charge;
  RecBufClear(253);
  Art.J.Datum           # today;
  Art.J.Bemerkung       # StrCut(Translate('Stornolieferschein')+' '+AInt(Lfs.P.Nummer)+'/'+AInt(LFs.P.Position)+' '+Lfs.Kundenstichwort,1,64);
  "Art.J.Stückzahl"     # "Lfs.P.STück";
  Art.J.Menge           # Lfs.P.Menge.Einsatz;
  "Art.J.Trägertyp"     # 'LFS';
  "Art.J.Trägernummer1" # Lfs.P.Nummer;
  "Art.J.Trägernummer2" # Lfs.P.Position;
  "Art.J.Trägernummer3" # 0;
  vOK # Art_Data:Bewegung(0.0,0.0);
  if (vOK=false) then begin
//    RANSBRK;
    Error(010011, AInt(Lfs.P.Position)+'|'+Lfs.P.ArtikelNr);
    RETURN false;
  end;

  // VSB-Menge wieder erhöhen...
  if (LFS_VLDAW_Data:Nimm_von_VSB(-Lfs.P.Menge.Einsatz, -"Lfs.P.Stück", -Lfs.P.Gewicht.Netto, -Lfs.P.Gewicht.Brutto, Lfs.P.Artikelnr, Lfs.P.Art.Adresse, Lfs.P.Art.Anschrift, Lfs.P.Art.Charge)=false) then begin
    Error(010023, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;
  // Reservierung wieder erhöhen...
  vOK # Art_Data:Reservierung(Lfs.P.Artikelnr, Lfs.P.Art.Adresse, LFs.P.Art.Anschrift, Lfs.P.Art.Charge, 0, c_Auf, LFS.P.Auftragsnr, Lfs.P.Auftragspos, Lfs.P.Auftragspos2, Lfs.P.Menge.Einsatz, "Lfs.P.Stück", 0);
  if (vOK=false) then begin
    Error(010004, AInt(Lfs.P.Position));
    RETURN false;
  end;


  // Aktion anlegen
  RecBufClear(404);
  Auf.A.Aktionstyp    # c_Akt_VLDAW;
  Auf.A.Aktionsnr     # Lfs.P.Nummer;
  Auf.A.Aktionspos    # Lfs.P.Position;
  Auf.A.Aktionsdatum  # today;
  Auf.A.TerminStart   # today;
  Auf.A.TerminEnde    # Today;
  //Aufx.A.Adressnummer  # Adr.Nummer;
  Auf.A.Menge         # Lfs.P.Menge.Einsatz;
  Auf.A.Menge.Preis   # Lfs.P.Menge;
  Auf.A.MEH           # Lfs.P.MEH.Einsatz;
  Auf.A.MEH.Preis     # Lfs.P.MEH;
  "Auf.A.Stückzahl"   # "Lfs.P.Stück";
  Auf.A.Gewicht       # Lfs.P.Gewicht.Brutto;
  Auf.A.Nettogewicht  # Lfs.P.Gewicht.Netto;

  Auf.A.ArtikelNr       # Lfs.P.ArtikelNr;
  Auf.A.Charge          # Lfs.P.Art.Charge;
  Auf.A.Charge.Adresse  # Lfs.P.Art.Adresse;
  Auf.A.Charge.Anschr   # Lfs.P.Art.Anschrift;

  vOk # Auf_A_Data:NeuAnlegen()=_rOK;
  if (vOK=false) then begin
//    RANSBRK;
    Error(010010, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// Pos_Storno_Vpg +ERR
//
//========================================================================
sub Pos_Storno_Vpg() : logic;
local begin
  Erx : int;
  vOk : logic;
end;
begin

  Erx # RecLink(250,441,3,_RecFirst)
  if (Erx>_rLocked) then begin
//    RANSBRK;
    Error(010001, AInt(Lfs.P.Position)+'|'+(LFs.P.Artikelnr));
    RETURN false;
  end;

  // Verpackungs-Artikel abbuchen AUS Lager
  RecBufClear(252);
  Art.C.ArtikelNr     # Lfs.P.ArtikelNr;
  Art.C.Charge.Intern # LFs.P.Art.Charge;
  RecBufClear(253);
  Art.J.Datum           # today;
  Art.J.Bemerkung       # StrCut(Translate('Stornolieferschein')+' '+AInt(Lfs.P.Nummer)+'/'+AInt(LFs.P.Position)+' '+Lfs.Kundenstichwort,1,64);
  "Art.J.Stückzahl"     # "Lfs.P.STück";
  Art.J.Menge           # Lfs.P.Menge.Einsatz;
  "Art.J.Trägertyp"     # 'LFS';
  "Art.J.Trägernummer1" # Lfs.P.Nummer;
  "Art.J.Trägernummer2" # Lfs.P.Position;
  "Art.J.Trägernummer3" # 0;
  vOK # Art_Data:Bewegung(0.0,0.0);
  if (vOK=false) then begin
//    RANSBRK;
    Error(010011, AInt(Lfs.P.Position)+'|'+Lfs.P.ArtikelNr);
    RETURN false;
  end;


  // Aufpreis als KOPFAUFPREIS anlegen
  Auf.Nummer          # Lfs.P.Auftragsnr;
  vOk # n;
  Erx # RecLink(403,400,13,_RecFirst);
  WHILE (Erx=_rOK) do begin
    if (Auf.Z.Position=0) and (Auf.Z.Vpg.ArtikelNr=Lfs.P.ArtikelNr) and
    (Lfs.P.MEH=Auf.Z.MEH) and (Auf.Z.Rechnungsnr=0) then begin
      vOK # y;  // Aufpreis bereits vorhandne! -> SUBTRAHIEREN
      BREAK;
    end;
    Erx # RecLink(403,400,13,_RecNext);
  END;

  if (vOK) then begin
    Erx # RecRead(403,1,_RecLock);
    if (erx=_rOK) then begin
      Auf.Z.Menge # Auf.Z.Menge - Lfs.P.Menge;
      erx # RekReplace(403,_recUnlock,'AUTO');
    end;
  end
  else begin
    RecBufClear(403);
    Auf.Z.Nummer        # Lfs.P.Auftragsnr;
    Auf.Z.Position      # 0;
    "Auf.Z.Schlüssel"   # 'VPG';
    Auf.Z.Menge         # (-1.0) * Lfs.P.Menge;
    Auf.Z.MEH           # Lfs.P.MEH;
    Auf.Z.PEH           # 1;
    Auf.Z.MengenbezugYN   # n;
    Auf.Z.RabattierbarYN  # n;
    Auf.Z.NeuberechnenYN  # n;
    Auf.Z.Preis         # 0.0;
    Auf.Z.Bezeichnung   # Art.Stichwort;
    Auf.Z.Vpg.ArtikelNr # Lfs.P.Artikelnr
    Auf.Z.Vpg.OKYN      # n;
    Auf.Z.Anlage.Datum  # today;
    Auf.Z.Anlage.Zeit   # now;
    Auf.Z.Anlage.User   # gUserName;
    Auf.Z.lfdNr         # 0;
    REPEAT
      Auf.Z.lfdNr # Auf.Z.lfdNr + 1;
      Erx # RekInsert(403,0,'AUTO');
      if (Erx=_rDeadlock) then BREAK;
    UNTIL (Erx=_rOK);
  end;

  if (Erx<>_rOK) then begin
//    RANSBRK;
    Error(010012, AInt(Lfs.P.Position));
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// Pos_Stornieren +ERR
//          Storniert einen LFS.Position durch Anlage der Lagerbewegungen
//          und Auftrags-Aktionen
//========================================================================
sub Pos_Stornieren() : logic;
local begin
  erx : int;
  vOk : logic;
end;
begin

  // Auftragsposition holen
  Erx # RecLink(401,441,5,_RecFirst);
  if (Erx>_rLocked) then begin
    Error(010014,AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;
  Erx # RecLink(400,401,3,_RecFirst); //Kopf holen
  if (Erx>_rLocked) then begin
    Error(010015,AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;
  Erx # RecLink(100,400,1,_RecFirst); // Kunde holen
  if (Erx>_rLocked) then begin
    Error(010016,AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;


  // *****************************
  // Artikellieferung?
  if (Lfs.P.Materialtyp=c_IO_Art) then begin
    RETURN Pos_Storno_Art();
  end;


  // *****************************
  // Verpackung?
  if (Lfs.P.Materialtyp=c_IO_VPG) then begin
    RETURN Pos_Storno_Vpg();
  end;


  // *****************************
  // Materiallieferung?
  if (Lfs.P.Materialtyp=c_IO_Mat) then begin
    RETURN Pos_Storno_Mat();
  end;

  RETURN true;
end;


//========================================================================
// KostenAusLFA
//
//========================================================================
sub KostenAusLFA() : logic;
local begin
  Erx         : int;
  vVorherEK   : float;
  vVorherKost : float;
  vKosten     : float;
  vEK         : float;
  vPreisFound : logic;
  vPreisKorr  : logic;
end;
begin

  // Positionen durchlaufen & Kosten ermitteln
  FOR Erx # RecLink(441,440,4,_RecFirst)
  LOOP Erx # RecLink(441,440,4,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Lfs.P.Auftragsnr<>0) then begin
      // in LFS-Aktion vererben...
      Auf.A.Aktionsnr     # Lfs.P.Nummer;
      Auf.A.Aktionspos    # Lfs.P.Position;
      Auf.A.Aktionspos2   # 0;
      Auf.A.Aktionstyp    # c_Akt_LFS;
      Erx # RecRead(404,2,0);
      if (Erx<=_rMultikey) and (Auf.A.Aktionsnr=Lfs.P.Nummer) and (Auf.A.AktionsPos=Lfs.P.Position) and
        (Auf.A.AktionsPos2=0) and (Auf.A.AktionsTyp=c_Akt_LFS) then begin
        Auf_Data:read(Auf.A.Nummer, Auf.A.Position, true);
      end
      else begin
        RecbufClear(404);
        RecbufClear(401);
      end;
    end;

    vVorherEK   # Auf.A.EKPreisSummeW1;
    vVorherKost # Auf.A.InterneKostW1;
    vEK     # 0.0;
    vKosten # 0.0;

    if (Lfs.P.Materialtyp=c_IO_ART) and (Auf.A.Nummer<>0) then begin
      // Artikellieferung?
      Erx # RecLink(250,441,3,_RecFirst)      // Artikel holen
      if (Erx>_rLocked) then RETURN false;
//      Erx # RecLink(252,441,14,_recFirst);    // ArtCharge holen
//      if (Erx>_rLocked) then RETURN false;

// SCHON ÜBER BAG      BerechneLfsKosten(250, true, var vKosten);

      vPreisFound # false;
      if (Auf.P.Nummer<>0) then
        BerechneEKundKostenAusVorkalkulation(250, true, var vEK, var vKosten, var vPreisFound);

      if (vPreisFound=false) then BestimmeArtikelEKPreis(var vEK);

      if (vVorherEK<>Rnd(vEK,2)) or (vVorherKost<>Rnd(vKosten,2)) then begin
        Erx # RecRead(404,1,_RecLock);
        if (erx=_rOK) then begin
          Auf.A.EKPreisSummeW1  # Rnd(vEK,2);
          Auf.A.InterneKostW1   # Rnd(vKosten,2);
          Erx # RekReplace(404,_recUnlock,'AUTO');
        end;
        if (erx<>_rOK) then RETURN false;
        if (Auf.A.Rechnungsnr<>0) then vPreisKorr # true;
      end;
    end
    else if (Lfs.P.Materialtyp=c_IO_VPG) then begin
      // Verpackung
    end
    else if (Lfs.P.Materialtyp=c_IO_Mat) and (Lfs.P.Materialnr<>0) then begin
      Erx # Mat_Data:Read(Lfs.P.Materialnr);
      if (Erx<200) then RETURN false;


// SCHON ÜBER BAG      BerechneLfsKosten(200, true, var vKosten);
/***
      // bisherige Kosten des LFS entfernen und neu einrechnen
      FOR Erx # RecLink(204,200,14,_recFirst)
      LOOP Erx # RecLink(204,200,14,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (Mat.A.Aktionstyp=c_Akt_LFS) and (Mat.A.AktionsNr=Lfs.P.Nummer) and (Mat.A.AktionsPos=Lfs.P.Position) then begin
          Mat.Kosten # Mat.Kosten - Mat.A.KostenW1;
        end;
      END;
***/
      Auf.A.EKPreisSummeW1  # Rnd(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0,2);
      Auf.A.InterneKostW1   # Rnd(Mat.Kosten * Mat.Bestand.Gew / 1000.0,2);

      if (Auf.P.Nummer<>0) then
        BerechneEKundKostenAusVorkalkulation(200, true, var vEK, var vKosten, var vPreisFound);
//debugx('matkosten add:'+anum(auf.a.InterneKostw1,2)+' + '+anum(vKosten,2));

      if (vPreisFound) then
        Auf.A.EKPreisSummeW1  # Rnd(vEK,2);
      Auf.A.InterneKostW1     # Auf.A.InterneKostW1 + Rnd(vKosten,2);

      if (vVorherEK<>Rnd(Auf.A.EKPreisSummeW1,2)) or (vVorherKost<>Rnd(Auf.A.InterneKostW1,2)) then begin
        Erx # RecRead(404,1,_recLock | _Recnoload);
        if (erx=_rOK) then
          Erx # RekReplace(404,_recUnlock,'AUTO');
        if (erx<>_rOK) then RETURN false;
        if (Auf.A.Rechnungsnr<>0) then vPreisKorr # true;
      end;
    end;
  END;


  if (vPreisKorr) then begin
    Error(404007,'');
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub Pos_ReKor(
  aDatum        : date;
  var aReKor    : int;
  var aPauschAP : logic) : logic;
local begin
  Erx         : int;
  vKreis      : alpha;
  v401        : int;
  v403        : int;
  vPos        : int;
  vNeu        : logic;
  vMEinsatz   : float;
  vMWunsch    : float;
  vEKGesWert  : float;
  vUrReMenge  : float;
end;
begin
  if (Lfs.P.Auftragsnr=0) then RETURN true;

  // Auftragsposition holen
  Erx # RecLink(401,441,5,_RecFirst);
  if (Erx>_rLocked) then begin
    APPON();
    TRANSBRK;
    Error(010014, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;
  Erx # RecLink(400,401,3,_RecFirst); //Kopf holen
  if (Erx>_rLocked) then begin
    APPON();
    TRANSBRK;
    Error(010014, AInt(Lfs.P.Position)+'|'+AInt(LFS.P.Auftragsnr)+'/'+AInt(Lfs.P.Auftragspos));
    RETURN false;
  end;

  Erx # RekLink(835,401,5,_recFirst);   // Auftragsart holen
  if (AAr.KonsiYN=n) and
    (((AAr.Berechnungsart>=200) and (AAr.Berechnungsart<=209)) or
    ((AAr.Berechnungsart>=250) and (AAr.Berechnungsart<=259))) then begin
    // Lieferung ist eigentlich berechnenbar
  end
  else begin
    RETURN true;
  end;


  Erx # RecLink(404,441,16,_recFirst);  // ursprüngliche LFS-Aktion holen
  if (Erx>_rLocked) or ((Auf.A.Aktionstyp<>c_Akt_LFS) and (Auf.A.Aktionstyp<>c_Akt_DFAKT)) then begin
    RETURN false;
  end;

  vEKGeswert  # Auf.A.EKPreisSummeW1 + Auf.A.InterneKostW1;    // EK smat Kosten merken
  vUrReMenge  # Auf.A.Menge.Preis;

  RecbufClear(451);
  // Rechnungsposition suchen...
  if (Auf.A.Rechnungsnr<>0) then begin
    Erx # RecLink(450,404,9,_recfirst);   // Erlös holen
    if (Erx<=_rLocked) then begin
      FOR Erx # RecLink(451,450,1,_recFirst)  // Konten loopen
      LOOP Erx # RecLink(451,450,1,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (Erl.K.Auftragsnr<>Auf.A.Nummer) or (Erl.K.Auftragspos<>Auf.A.Position) then CYCLE;
        if (Erl.K.Bemerkung<>Translate('Grundpreis')) then CYCLE;
        BREAK;  // gefunden
      END;
      if (Erx>_rLocked) then begin
        RETURN false;
      end;
    end;
  end;


  // neuer Rekor-Kopf?
  if (aReKor=0) then begin
    // AUFTRAGSKOPF anlegen **********************************************
//    RecBufClear(400);
    Auf.Datum             # today;
    Auf.Vorgangstyp       # c_ReKor;
    Auf.Best.Nummer       # c_AKT_RLFS+' '+aint(Lfs.Nummer);
    Auf.AbrufYN           # false;


    vKreis # 'Auftrag';
    if ("Set.Auf.GutBel#SepYN") and
      ((Auf.Vorgangstyp=c_BOGUT) or  (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) or
       (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF)) then
       vKreis # 'Auftrag-Gutschrift/Belastung';
    aReKor # Lib_Nummern:ReadNummer(vKreis);
    if (aReKor<>0) then Lib_Nummern:SaveNummer()
    else begin
      RETURN false;
    end;
    Auf.Nummer            # aReKor;
    Auf.Anlage.Datum      # Today;
    Auf.Anlage.Zeit       # now;
    Auf.Anlage.User       # gUsername;
    Auf.Freigabe.Datum    # 0.0.0;
    Auf.Freigabe.Zeit     # 0:0;
    Auf.Freigabe.User     # '';
    Auf.Freigabe.WertW1   # 0.0;

    Erx # RekInsert(400,0,'AUTO');
    if (Erx<>_rOK) then begin
      RETURN false;
    end;
  end   // neuer Auf-Kopf
  else begin
    Auf.Nummer # aReKor;
    Erx # RecRead(400,1,0);
    if (Erx>_rLocked) then begin
      RETURN false;
    end;
  end;


  v401 # RekSave(401);
  // passende Position suchen...
  vPos # 0;
  vNeu # true;
  FOR Erx # RecLink(401,400,9,_recFirst)
  LOOP Erx # RecLink(401,400,9,_recNext)
  WHILE (Erx<=_rLocked) do begin
    inc(vPos);
    if (Auf.P.Best.Nummer=aint(v401->Auf.P.Nummer)+'/'+aint(v401->Auf.P.Position)) and
      (Auf.P.AbrufAufNr=Erl.K.Rechnungsnr) and (Auf.P.AbrufAufPos=Erl.K.lfdNr) then begin
      vNeu # false;
      BREAK;
    end;
  END;

  if (vNeu) then begin
    inc(vPos);
    // NEUE Position anlegen...
        // Aufpreis kopieren
    FOR Erx # RecLink(403, 401,6,_recFirst)
    LOOP Erx # RecLink(403, 401,6,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (cRueckLfsMitPauschalAufpreisen=false) then begin    // 2023-07-19 AH
        if (Auf.Z.MengenbezugYN=false) then begin
          aPauschAP # true;
          CYCLE;
        end;
      end;
      v403 # RekSave(403);
      Auf.Z.Nummer       # aReKor;
      Auf.Z.Position     # vPos;
      Auf.Z.Rechnungsnr  # 0;
      Erx # RekInsert(403,_recunlock,'AUTO')
      if (erx<>_rOK) then RETURN false;
      RekRestore(v403);
    END;

    // 2023-04-26 AH  Proj. 2333/89
    if (cRueckLfsMitKopfAufpreisen) then begin
      Auf.Nummer # Auf.P.nummer;
      FOR Erx # RecLink(403, 400, 13,_recFirst)
      LOOP Erx # RecLink(403, 400,13,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (Auf.Z.Position<>0) then CYCLE;
  //      if (Auf.Z.MengenbezugYN=false)  then begin
  //        aPauschAP # true;
  //        CYCLE;
  //      end;
        v403 # RekSave(403);
        Auf.Z.Nummer       # aReKor;
        Auf.Z.Position     # 0;
        Auf.Z.Rechnungsnr  # 0;
        Erx # RekInsert(403,_recunlock,'AUTO')
        if (erx<>_rOK) then RETURN false;
        RekRestore(v403);
      END;
    end;


    RekRestore(v401);
    "Auf.P.Löschmarker" # '';
    "Auf.P.Lösch.Zeit"  # 0:0;
    "Auf.P.LÖsch.Datum" # 0.0.0;
    "Auf.P.Lösch.User"  # '';
    Auf.P.StorniertYN   # false;
    Auf.P.Workflow      # 0;


    Auf.P.Anlage.Datum  # Today;
    Auf.P.Anlage.Zeit   # now;
    Auf.P.Anlage.User   # gUsername;

    Auf.P.Best.Nummer   # aint(Auf.P.Nummer)+'/'+aint(Auf.P.Position);
    Auf.P.AbrufAufNr    # Erl.K.Rechnungsnr;
    Auf.P.AbrufAufPos   # Erl.K.lfdNr;


    Auf.P.Nummer        # aReKor;
    Auf.P.Position      # vPos;
    "Auf.P.Stückzahl"   # 0;
    Auf.P.Gewicht       # 0.0;
    Auf.P.Menge.Wunsch  # 0.0;
    Auf.P.Menge         # 0.0;
    Erx # Auf_Data:PosInsert(0,'AUTO');
    if (Erx<>_rOK) then begin
      RETURN false;
    end;

  end
  else begin
    // vorhandene Position erweitern
    RecBufDestroy(v401);
  end;

  // Aktion anlegen...
  RecBufClear(404);
  Erx # RecLink(100,401,4,_Recfirst);   // Kunde holen...
  Auf.A.Nummer        # Auf.P.Nummer;
  Auf.A.Position      # Auf.P.Position;
  Auf.A.Aktion        # 1;
  Auf.A.MEH           # Auf.P.MEH.Preis;
  Auf.A.MEH.Preis     # Auf.P.MEH.Preis;
  Auf.A.Artikelnr     # Auf.P.Artikelnr;
  Auf.A.TerminStart   # Lfs.P.Datum.Verbucht;
  Auf.A.TerminEnde    # Auf.A.TerminStart;
  Auf.A.Aktionsdatum  # Auf.A.TerminStart;

  Auf.A.Aktionstyp    # c_Akt_DFaktGut;
  if (Auf.A.MEH.Preis=Lfs.P.MEH) then begin
    Auf.A.Menge       # Lfs.P.Menge;
    Auf.A.Menge.Preis # Lfs.P.Menge;
  end
  else if (Auf.A.MEH.Preis=Lfs.P.MEH.Einsatz) then begin
    Auf.A.Menge       # Lfs.P.Menge.Einsatz;
    Auf.A.Menge.Preis # Lfs.P.Menge.Einsatz;
  end;
  "Auf.A.Stückzahl"       # "Lfs.P.Stück";
  Auf.A.Gewicht           # Lfs.P.Gewicht.Brutto;
  Auf.A.NettoGewicht      # Lfs.P.Gewicht.Netto;
// 2022-12-14 AH  Auf.A.Materialnr        # Lfs.P.Materialnr;
  Auf.A.Artikelnr         # Lfs.P.Artikelnr;
  Auf.A.Charge            # Lfs.P.Art.Charge;
  Auf.A.Charge.Adresse    # Lfs.P.Art.Adresse;
  Auf.A.Charge.Anschr     # Lfs.P.Art.Anschrift;

  // EK-Werte bestimmen ----------------------------
  if (Auf.A.Materialnr<>0) then begin
    Erx # Mat_Data:Read(Auf.A.Materialnr,0,0,n);
    if (Erx<200) then begin
      RETURN false;
    end;
    vEKGesWert # Rnd(Mat.Bestand.Gew * Mat.EK.Effektiv / 1000.0,2);
  end
  else begin
    // bei Artikeln über Dreisatz
    vEKGesWert # Lib_Berechnungen:Dreisatz(vEKGesWert, 0.0 - vUrReMenge, Auf.A.Menge.Preis);    // 2023-02-01 AH negieren, da Minus * Minus sonst Plus ergibt!
    // bei LFA kommen Kosten beim ABSCHLUSS
//    if (Lfs.P.zuBA.Nummer=0) then
//      aPreisOK # BerechneEKundKostenAusVorkalkulation(250, aPauschalOK, var vEK, var vKosten, var vOK);
//    if (vOK=false) then BestimmeArtikelEKPreis(var vEK);

  end;


  Auf.A.EKPreisSummeW1    # - vEKGesWert;
//debugx('Gesekwert : '+anum(vEKGesWert,2));
// Auf.A.EKPreisSummeW1  # Rnd("Auf.A.RückEinzelEKW1" * Auf.A.Menge / cnvfi(Auf.P.PEH),2);
  if (Auf.A.Menge<>0.0) then
    "Auf.A.RückEinzelEKW1"  # Rnd(Auf.A.EKPreisSummeW1 / Auf.A.Menge * cnvfi(Auf.P.PEH), 2);

  if (Auf_A_Data:NeuAnlegen(n, n)<>_rOK) then begin
    RETURN false;
  end;

  // Position updaten...
  Erx # RecRead(401,1,_recLock);
  if (erx=_rOK) then begin
//debugx(Auf.P.MEH.Wunsch+' '+lfs.p.meh);
// Auf.P.MEH.Einsatz, Auf.P.MEH.Preis, Auf.P.MEH.Wunsch
    if (Auf.P.MEH.Wunsch=Lfs.P.MEH) then
      vMWunsch # Lfs.P.Menge;
    else if (Auf.P.MEH.Wunsch=Lfs.P.MEH.Einsatz) then
      vMWunsch # Lfs.P.Menge.Einsatz;
    else if (Auf.P.MEH.Wunsch='Stk') then
      vMWunsch # cnvfi("Lfs.P.Stück");
    else if (Auf.P.MEH.Wunsch='kg') then
      vMWunsch # Lfs.P.Gewicht.Netto;
    else if (Auf.P.MEH.Wunsch='t') then
      vMWunsch # Rnd(Lfs.P.Gewicht.Netto / 1000.0, Set.Stellen.Gewicht);
    else
      vMWunsch # Lib_Einheiten:WandleMEH(441, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Lfs.P.Menge, Lfs.P.MEH, Auf.P.MEH.Wunsch);

  //debugx(Auf.P.MEH.Einsatz+' '+lfs.p.meh);
    if (Auf.P.MEH.Einsatz=Lfs.P.MEH) then
      vMEinsatz # Lfs.P.Menge;
    else if (Auf.P.MEH.Einsatz=Lfs.P.MEH.Einsatz) then
      vMEinsatz # Lfs.P.Menge.Einsatz;
    else if (Auf.P.MEH.Einsatz='Stk') then
      vMEinsatz # cnvfi("Lfs.P.Stück");
    else if (Auf.P.MEH.Einsatz='kg') then
      vMEinsatz # Lfs.P.Gewicht.Netto;
    else if (Auf.P.MEH.Einsatz='t') then
      vMEinsatz # Rnd(Lfs.P.Gewicht.Netto / 1000.0, Set.Stellen.Gewicht);
    else
      vMEinsatz # Lib_Einheiten:WandleMEH(441, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Lfs.P.Menge, Lfs.P.MEH, Auf.P.MEH.Einsatz);

  //debugx(anum(vMWunsch,2)+'   '+anum(vMEinsatz,2));
    Auf.P.Menge.Wunsch  # Auf.P.Menge.Wunsch  - vMWunsch;
    Auf.P.Menge         # Auf.P.Menge         - vMEinsatz;
    "Auf.P.Stückzahl"   # "Auf.P.Stückzahl"   + "Auf.A.Stückzahl";
  //  Auf.P.Gewicht       # Auf.P.Gewicht       + Auf.A.Gewicht;
    if (VwA.Nummer<>Auf.P.Verwiegungsart) then begin
      Erx # RecLink(818,401,9,_recfirst); // Verwiegungsart holen
      if (Erx>_rLocked) then begin
        RecBufClear(818);
        VWa.NettoYN # Y;
      end;
    end;
    if (VWa.NettoYN) then
      Auf.P.Gewicht # Auf.P.Gewicht + Lfs.P.Gewicht.Netto
    else
      Auf.P.Gewicht # Auf.P.Gewicht + Lfs.P.Gewicht.Brutto;


  //  Auf.P.Menge.Preis   # Auf.P.Menge.Preis + Auf.A.Menge.Preis;

    Auf_P_Subs:CalcMengen();

    Erx # Auf_Data:PosReplace(0,'AUTO');
  end;
  if (erx<>_rOK) then RETURN false;

  RETURN true;
end;


//========================================================================
// Verbuchen +ERR
//          Verbucht einen kompletten Lieferschein durch Aufruf der
//          "Pos_Verbuchen" für jede Position
//========================================================================
sub Verbuchen(
  aLfs        : int;
  aDatum      : date;
  aZeit       : time;
  opt aSilent : logic;
) : logic;
local begin
  Erx         : int;
  vPreisOK    : logic;
  vReKor      : int;
  vAPManCheck : logic;
  vVSD        : logic;
end;
begin
//todox(''); //Auskommentiert, ist durch Update in verschiedene Datenräume gekommen.
  Lfs.Nummer # aLfs;
  Erx # RecRead(440,1,0);
  If (Erx>_rLocked) then begin
    Error(440100,AInt(aLFS));
    RETURN false;
  end
  if (lfs.zuBA.Nummer<>0) then begin  // 05.02.2021 AH
    Error(440106,AInt(aLFS));
    RETURN false;
  end;
  
  if (Lfs.Datum.Verbucht<>0.0.0) then begin
    Error(440101,AInt(aLFS));
    RETURN false;
  end;
  if (Lib_Faktura:Abschlusstest(aDatum) = false) then begin
    Error(001400 ,Translate('Verbuchungsdatum') + '|'+ CnvAd(aDatum));
    RETURN false;
  end;


  // Ankerfunktion:
  if (RunAFX('LFS.Verbuchen.Pre','')<>0) then begin
    if (AfxRes<>_rOK) then RETURN false;
  end;

/***
  // Positionen durchlaufen & Kosten ermitteln
  FOR Erx # RecLink(441,440,4,_RecFirst)
  LOOP Erx # RecLink(441,440,4,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Lfs.P.Materialtyp=c_IO_ART) then begin
      // Artikellieferung?
      Erx # RecLink(250,441,3,_RecFirst)      // Artikel holen
      if (Erx>_rLocked) then begin
        Error(010001,aint(lfs.p.position)+'|'+lfs.p.artikelnr);
        RETURN false;
      end;
      Erx # RecLink(252,441,14,_recFirst);    // ArtCharge holen
      if (Erx>_rLocked) then begin
        Error(010001,aint(lfs.p.position)+'|'+lfs.p.artikelnr+'/'+lfs.p.art.charge);
        RETURN false;
      end;
      _PosKosten(250, true, var vMengeGes, var vKostenGes);
    end
    else if (Lfs.P.Materialtyp=c_IO_VPG) then begin
      // Verpackung
    end
    else if (Lfs.P.Materialtyp=c_IO_Mat) then begin
      // Materiallieferung?
      Erx # RecLink(200,441,4,_recFirst);     // Material holen
      if (Erx<>_rOK) then RETURN false;
      _PosKosten(200, true, var vMengeGes, var vKostenGes);
    end;
  END;


  if (Lfs.Kosten.MEH=Translate('pauschal')) then begin
    vKostenGes # Lfs.Kosten.Pro;
  end
  else begin
    if (Lfs.Gesamtgewicht<>0.0) and (Lfs.Kosten.MEH='kg') then begin
      vKostenGes  # Lfs.Gesamtgewicht * LFs.Kosten.Pro / cnvfi(Lfs.Kosten.PEH)
    end
    else if (Lfs.Gesamtgewicht<>0.0) and (Lfs.Kosten.MEH='t') then begin
      vKostenGes # (Lfs.Gesamtgewicht / 1000.0) * LFs.Kosten.Pro / cnvfi(Lfs.Kosten.PEH)
    end;
  end;
***/

//debugx('Gesmatkosten:'+anum(vKostenGes,2)+' bei Menge:'+anum(vMengeGes,0));

  APPOFF();
  TRANSON;

  Lfs.Nummer # aLfs;
  Erx # RecRead(440,1,0); // 05.02.2021 AH

  // Positionen durchlaufen & verbuchen
  FOR Erx # RecLink(441,440,4,_RecFirst)
  LOOP Erx # RecLink(441,440,4,_RecNext)
  WHILE (Erx=_rOK) do begin

    vVSD # vVSD or (Lfs.P.Versandpoolnr>0);

    if (Lfs.P.Datum.Verbucht<>0.0.0) then begin
      APPON();
      TRANSBRK;
      Error(010013,AInt(Lfs.P.Position));
      RETURN false;
    end;

    // Position verbuchen MIT Pauschalpreisen
//    if (Pos_Verbuchen(aDatum, vKostenGes, (Lfs.Positionsgewicht=0.0) )=false) then begin
    if (Pos_Verbuchen(aDatum, aZeit, TRUE, var vPreisOK)=false) then begin
      APPON();
      TRANSBRK;
      RETURN false;
    end;

  END;
  if (Erx=_rLocked) then begin
    APPON();
    TRANSBRK;
    Error(441100,AInt(Lfs.P.Position));
    RETURN false;
  end;

  // Kopfgewichte addieren...
  SumLFS();

  // Kopf als Verbucht markieren
  Erx # RecRead(440,1,_recLock);
  if (erx=_rOK) then begin
    Lfs.Datum.Verbucht # aDatum;
    Erx # RekReplace(440,_recUnlock,'AUTO');
  end;
  if (erx<>_rOk) then begin
    APPON();
    TRANSBRK;
    Error(440102,'');
    RETURN false;
  end;

  if (vVSD) then VSD_Data:PruefeObAllesErledigtBeiLFS();

  // ggf. Rechnungskorrektur anlegen bei Rücknahmen
  if ("Lfs.RücknahmeYN") then begin
    FOR Erx # RecLink(441,440,4,_RecFirst)
    LOOP Erx # RecLink(441,440,4,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      if (Pos_ReKor(aDatum, var vReKor, var vAPmanCheck)=false) then begin
        APPON();
        TRANSBRK;
        RETURN false;
      end;

    END;
  end;  // Rücknahme


  TRANSOFF;

  // Ankerfunktion: ST 2011-01-18
  RunAFX('LFS.Verbuchen.Post',CnvAi(CnvIl(aSilent)));

  APPON();

  if (aSilent=n) then begin
    if ("Lfs.RücknahmeYN") then begin
      if (vAPmanCheck) then begin
        Error(440901,aint(vReKor));
      end
      else begin
        Error(440900,aint(vReKor));
      end;
    end
    else begin
      Error(440999,''); // Erfolg
    end;
  end;

  RETURN true;
end;


//========================================================================
// Stornieren +ERR
//          Storniert einen kompletten Lieferschein durch Aufruf der
//          "Pos_Stornieren" für jede Position
//========================================================================
sub Stornieren(
  aLfs    : int;
  aDatum  : date;
) : logic;
local begin
  Erx : int;
  vOk : logic;
end;
begin

  Lfs.Nummer # aLfs;
  Erx # RecRead(440,1,0);
  If (Erx>_rLocked) then begin
    Error(440100,AInt(aLFS));
    RETURN false;
  end
  if (Lfs.Datum.Verbucht=0.0.0) then begin
    Error(440104,AInt(aLFS));
    RETURN false;
  end;



  // 19.02.2013
  if (lfs.zuBA.Nummer<>0) then begin
if (gUsername<>'AH') then RETURN false;
//todo('LFA_STORNO für AI');
    Erx # RecLink(702,440,7,_recFirst);     // BA-Position holen
    if (Erx<>_rOK) then RETURN false;

    TRANSON;

    // LFS-Zielort entfernen...
    Erx # RecRead(440,1,_recLock);
    if (erx=_rOK) then begin
      Lfs.Zieladresse     # 0;
      Lfs.Zielanschrift   # 0;
      Lfs.Bemerkung # translate('Storniert');
      Erx # RekReplace(440,_recunlock,'AUTO');
    end;
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;

    // BA-Position zurücksetzen...
    Erx # RecRead(702,1,_recLock);
    if (erx=_rOK) then begin
      BAG.P.Zieladresse   # 0;
      BAG.P.Zielanschrift # 0;
      BAG.P.Zielstichwort # translate('Storniert');
      BAG.P.ZielverkaufYN # false;
      Erx # BA1_P_Data:Replace(_recunlock,'AUTO');
    end;
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;

/**
    // FM loopen...
    FOR Erx # RekLink(707,702,5,_recfirst)
    LOOP Erx # RekLink(707,702,5,_recNext)
    WHILE (Erx<_rLocked) do begin
      Erx # RekLink(701,707,9,_recfirst);     // Input holen
      if (Erx<>_rOk) then begin
        TRANSBRK;
        RETURN false;
      end;
      if (BAG.FM.Materialnr=0) then begin
todo('Artikel storno');
      end
      else begin
        Erx # Reklink(200,707,7,_recFirst);   // Material holen
        if (Erx<>_rOk) then begin
          TRANSBRK;
          RETURN false;
        end;
        if (Mat.VK.RechNr<>0) then begin
          TRANSBRK;
          Error(200113, aint(Mat.Nummer));
          RETURN false;
        end;
      END
**/

      // LFS-Positionen loopen...
      Erx # RekLink(441,440,4,_recFirst);
      WHILE (Erx<_rLocked) do begin

        if (Lfs.P.Datum.Verbucht=0.0.0) then begin
          Erx # RekLink(441,440,4,_recNext);
          CYCLE;
        end;

        vOK # Pos_Stornieren();
        if (vOK=false) then begin
          TRANSBRK;
          RETURN false;
        end;

        Erx # Rekdelete(441,_recunlock,'MAN');
        if (Erx<>_rOK) then begin
          TRANSBRK;
          RETURN false;
        end;

        Erx # RekLink(441,440,4,_recFirst);
    END;

    TRANSOFF;

msg(999998,'',0,0,0);
RETURN false;
  end;



  TRANSON;

  // Kopfgewichte addieren...
  SumLFS();

  // Kopf stornieren
  Erx # RecRead(440,1,_recLock);
  if (erx=_rOK) then begin
    Lfs.Datum.Verbucht # 0.0.0;
    Erx # RekReplace(440,_recUnlock,'AUTO');
  end;
  if (erx<>_rOk) then begin
    TRANSBRK;
    Error(440102,'');
    RETURN false;
  end;

  // Positionen durchlaufen & stornieren
  Erx # RecLink(441,440,4,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Lfs.P.Datum.Verbucht=0.0.0) then begin
      TRANSBRK;
      Error(010026,'');
      RETURN false;
    end;

    vOk # Pos_Stornieren();
    if (vOk=false) then begin
      TRANSBRK;
      RETURN false;
    end;

    // wieder als VLDAW sichern
    if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n)=false) then begin
      TRANSBRK;
      RETURN false;
    end;

    // Positionen als Unverbucht markieren
    Erx # RecRead(441,1,_recLock);
    if (erx=_rOK) then begin
      Lfs.P.Datum.Verbucht # 0.0.0;
      Erx # RekReplace(441,_recUnlock,'AUTO');
    end;
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Error(010008,AInt(Lfs.P.Position));
      RETURN false;
    end;

    Erx # RecLink(441,440,4,_RecNext);
  END;
  if (Erx=_rLocked) then begin
    TRANSBRK;
    Error(441100,AInt(Lfs.P.Position));
    RETURN false;
  end;

  TRANSOFF;

  Error(440998,''); // Erfolg

  RETURN true;
end;


//========================================================================
// Druck_LFS
//      Drucke den Lieferschein
//========================================================================
sub Druck_LFS(opt aErr : logic) : logic
local begin
  Erx   : int;
  vKLim : float;
  vA    : alpha(4000);
  vOK   : logic;
  vTyp  : alpha;
end;
begin
  // LFE
  If (Lfs_Subs:CheckLfE()=false) then RETURN false;

//  if (gUsername = 'SOA_SERVER') then
//    vUserPostFix  # '_SOA';

  // Kreditlimit prüfen [02.06.2010/PW]
  if (aErr) then vA # 'Y';
  if (RunAFX('KLimit.LFS.Druck', vA)<>0) then begin
    if (AfxRes<>_rOK) then RETURN false;
  end
  else begin
    if ( "Set.KLP.LFS-Druck" != '' ) then begin

      if ( Lfs.P.Nummer != Lfs.Nummer ) then
        RecLink( 441, 440, 4, _recFirst ); // erste Position holen

      if (Lfs.P.Auftragsnr <> 0) and (Lfs.P.AuftragsPos <> 0) then begin // MS 28.07.2010 nur pruefen wenn mit Auftrag
        Erx # Auf_Data:Read(Lfs.P.Auftragsnr, Lfs.P.auftragspos, y);
        if (Erx>=400) then begin
          Erx # RecLink(100,400,1,_RecFirst);     // Kunde holen
          if (Adr.SperrKundeYN) then begin
            if (aErr) then
              ERROR(100005,Adr.Stichwort);
            else
              Msg(100005,Adr.Stichwort,0,0,0);
            RETURN false;
          end;

          Erx # RecLink(100,400,4,_recFirst);     // Rechnungsempfänger holen
          if (Adr.SperrKundeYN) then begin
            if (aErr) then
              Error(100005,Adr.Stichwort);
            else
              Msg(100005,Adr.Stichwort,0,0,0);
            RETURN false;
          end;
          vTyp # "Set.KLP.LFS-Druck";
          if (vTyp = 'L') then begin   // 16.04.2021 AH: Proj.2199/4
            vOK # Adr_K_Data:GibtsLfsFreigabe(Lfs.Nummer, Auf.Nummer);
            vTyp # 'S';
          end;
          if (vOK=false) then begin
            if (Adr_K_Data:Kreditlimit( Auf.Rechnungsempf, vTyp, true, var vKLim,0, Auf.Nummer, aErr) = false ) then begin
              if (aErr) then
                //ERROR(100005,Adr.Stichwort);
                Erroroutput;
//              else
//                Msg(100005,Adr.Stichwort,0,0,0);
              RETURN false;
            end;
          end;
        end;

      end;
    end;
  end;


//  if (Lfs.zuBA.Nummer=0) then begin
  RecLink(100,440,2,_RecFirsT);   // Zieladresse holen

  vOK # false;
  if (Lfs.zuBA.Nummer<>0) then begin
    Erx # RecLink(702,440,7,_recFirst);     // BA-Position holen
    if (Erx<=_rLocked) then begin
      if !(BAG.P.ZielVerkaufYN) then begin
//        Frm.Bereich  # 440;
//        Frm.Name     # 'Lieferschein-LFA';
//        if (RecRead(912,1,0) <= _rLocked) then begin
          vOK # y;
//          Lib_Dokumente:Printform(440,'Lieferschein-LFA'+vUserPostFix,(vUserPostFix = ''));
          Lib_Dokumente:Printform(440,'Lieferschein-LFA',true);
//        end;
      end;
    end;
  end;

  if (vOK=false) then // "normalen" LFS drucken
//    Lib_Dokumente:Printform(440,'Lieferschein'+vUserPostFix,(vUserPostFix = ''));
    Lib_Dokumente:Printform(440,'Lieferschein',true);

  // Sonderfunktion:
  RunAFX('LFS.Druck','');
  RETURN true;
end;


//========================================================================
// Druck_Avis
//      Druckt die Lieferavisierung
//========================================================================
sub Druck_Avis()
begin
  RecLink(100,440,2,_RecFirsT);   // Zieladresse holen
  Lib_Dokumente:Printform(440,'Lieferavis',true);
end;


//========================================================================
// Druck_Auto
//
//========================================================================
sub Druck_Auto(opt aWie : alpha);
local begin
  Erx     : int;
  vDat    : date;
  vZeit   : time;
end;
begin

  if (aWie='') then
    aWie # Set.LFS.Verbuchen;

  // normaler Standard Lieferschein?
  if (Lfs.zuBA.Nummer=0) then begin
   if (Druck_LFS()) and (aWie='A') and
      (Lfs.Datum.Verbucht=0.0.0) and
      (Rechte[Rgt_Lfs_Verbuchen]) then begin
      if (Msg(440007,'',_WinIcoQuestion,_WinDialogYesNo,1)=_winIdyes) then begin
        if (Dlg_Standard:Datum(Translate('Verbuchungsdatum'), var vDat, today)=false) then
          RETURN
        if (vDat=todaY) then vZeit # now;
        Verbuchen(Lfs.Nummer, vDat, vZeit);
        ErrorOutput;
      end;
    end;
  end
  else begin
    // NEIN -> dann ein LFA-LFS
    Erx # RecLink(702,440,7,_recFirst);     // BA-Position holen
    if (Erx>_rLocked) then
      RETURN;

    // evtl. gibt es zu einem LFA mehrere LFS...
    Erx # RecLink(440,702,14,_recFirst);    // LFS loopen
    WHILE (Erx<=_rLocked) do begin
     if (Druck_LFS()=false) then begin
      RETURN;
     end;
      Erx # RecLink(440,702,14,_recNext);
    END;
  end;

  Refreshlist(gZLList, _WinLstRecFromRecid | _WinLstRecDoSelect);
//  if (gZLList<>0) then gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect); // Pos. refreshen
  if(gMdi -> wpName = 'Auf.Verwaltung') then // Auftragskoepfe?
    $ZL.Auftraege -> WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect); // Koepfe refreshen
end;


//========================================================================
// Druck_Freistellung
//      Druckt die Freistellungspapiere
//========================================================================
sub Druck_Freistellung()
begin
  if (RunAFX('Lfs.Print.Freistellung','')<0) then RETURN;   // 14.01.2020 TM
  
  Lib_Dokumente:Printform(440,'Freistellung',true);
end;


//========================================================================
// Druck_CMR
//      Drucke den Lieferschein
//========================================================================
sub Druck_CMR()
begin
//  if (Lfs.zuBA.Nummer=0) then begin
    RecLink(100,440,2,_RecFirsT);   // Zieladresse holen
    Lib_Dokumente:Printform(440,'CMRFrachtbrief',true);

//  else
//todo('LFA-Lieferschein');
end;


//========================================================================
// Druck_Nachweiss
//      Druckt den Liefernachweiss
//========================================================================
sub Druck_Nachweiss()
begin
  RecLink(100,440,2,_RecFirsT);   // Zieladresse holen
  Lib_Dokumente:Printform(440,'Nachweiss',true);
end;


//========================================================================
// Druck_Werkszeugnis
//      Druckt die Werkszeugnisse eines LFS
//========================================================================
sub Druck_Werkszeugnis()
local begin
  Erx       : int;
  vTree     : int;
  vSortKey  : alpha;
  vItem     : int;
  vDokNr    : int;
  vStk      : int;
  vGewN     : float;
  vGewB     : float;
  vGew      : float;
end;
begin

  // exisitieren schon WZs?
  vDokNr # Lib_Dokumente:CheckForm(440,'Werkszeugnis');
  if (vDokNr<>0) then begin
    Case Msg(912001,'',_WinIcoQuestion,_WinDialogYesNoCancel,1) of
      _WinIdYes      : begin
        Lib_Dokumente:ShowDok(vDokNr);
        RETURN;
      end;
      _WinIdNo      : begin
        // Weiter im Code unten...
      end;
      _WinIdCancel  : begin
        RETURN
      end;
    end;
  end;

  // Sonderfunktion:
  if (RunAFX('LFS.WZ.Druck','')<>0) then begin
    RETURN;
  end;


  // Rambaum anlegen...
  vTree # CteOpen(_CteTreeCI);
  gFormParaHdl # CteOpen(_CteList);

  FOR Erx # RecLink(441,440,4,_RecFirst)
  LOOP Erx # RecLink(441,440,4,_RecNext)
  WHILE (Erx<=_rLocked ) DO BEGIN

    If (Lfs.P.Materialtyp=c_IO_Mat) then begin
      Erx # RecLink(200,441,4,_recFirst);     // Material holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(210,441,12,_recFirst); // Materialablage holen
        if (Erx>_rLocked) then RecBufClear(210);
        RecBufCopy(210,200);
      end;

      // Material aufnehmen...
      if (Mat.Nummer=0) then CYCLE;

      vSortKey # lfs.P.Kommission + '|' + Mat.Coilnummer + '|' + Mat.Chargennummer;

      // Auftragsposition holen
      Erx # RecLink(401,441,5,_RecFirst);
      if (Erx>_rLocked) then RecBufClear(401);

      if (Auf.P.Zeugnisart<>'') then begin
        // Charge bereits gedruckt??
        vItem # vTree->CteRead(_CteFirst | _CteSearch, 0, vSortKey);
        if (vItem=0) then begin     // NEIN -> Merken und drucken...
          vItem # CteOpen(_CteItem);
          if (vItem<>0) then begin
            vItem->spName   # vSortKey;
            vItem->spID     # RecInfo(441,_RecId);
            vItem->spcustom # aint("Lfs.P.Stück")+'|'+anum(lfs.p.menge, set.stellen.Gewicht)+'|'+anum(lfs.p.Gewicht.Netto,Set.Stellen.Gewicht)+'|'+anum(lfs.p.gewicht.Brutto,Set.Stellen.Gewicht);
            CteInsert(vTree,vItem); // in Baum speichern
            if (Set.LFS.WZDruckKombi=false) then
              Lib_Dokumente:Printform(440,'werkszeugnis',false);
//            else
//              vItem # gFormParaHdl->CteInsertItem('LFS'+aint(lfs.p.nummer)+'/'+aint(lfs.p.position),Mat.Nummer, aint("Lfs.P.Stück")+'|'+anum(lfs.p.Gewicht.Netto,Set.Stellen.Gewicht)+'|'+anum(lfs.p.gewicht.Brutto,Set.Stellen.Gewicht));
          end;
        end
        else begin  // gibt's schon -> summieren
          vStk  # cnvia(Str_Token(vItem->spcustom,'|',1)) + "Lfs.P.Stück";
          vGew  # cnvfa(Str_Token(vItem->spcustom,'|',2)) + Lfs.P.Menge;
          vGewN # cnvfa(Str_Token(vItem->spcustom,'|',3)) + Lfs.P.Gewicht.netto;
          vGewB # cnvfa(Str_Token(vItem->spcustom,'|',4)) + Lfs.P.Gewicht.Brutto;
          vItem->spcustom # aint(vStk)+'|'+anum(vGew, Set.Stellen.Gewicht)+'|'+anum(vGewN,Set.Stellen.Gewicht)+'|'+anum(vGewB,Set.Stellen.Gewicht);
        end;
      end;
    end;
  END;

  if (Set.LFS.WZDruckKombi) then begin
    FOR vItem # CteRead(vTree,_ctefirst)
    LOOP vItem # CteRead(vTree,_ctenext, vItem)
    WHILE (vItem<>0) do begin
      RecRead(441,0,_recId, vItem->spid);
      gFormParaHdl->CteInsertItem('LFS|'+aint(lfs.p.nummer)+'|'+aint(lfs.p.position),Lfs.P.Materialnr, vItem->spcustom);
    END;
    Lib_Dokumente:Printform(440,'werkszeugnis',false);
  end;

//  if (Set.LFS.WZDruckKombi) then
//    Lib_Dokumente:Printform(440,'werkszeugnis',false);

  Sort_KillList(gFormParaHdl);
  gFormParaHdl # 0;

/*
  // RAMBAUM durchlaufen...
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(cnvIA(vItem->spCustom),0,0,vItem->spID);
  END;
*/

  // Löschen des Baums
  Sort_KillList(vTree);
end;


//========================================================================
// Druck_VSB
//      Drucke den Lieferschein
//========================================================================
sub Druck_VSB()
begin
  RecLink(100,440,2,_RecFirsT);   // Zieladresse holen
  Lib_Dokumente:Printform(440,'VSB-Meldung',true);
end;


//========================================================================
// SaveLFS  +Error
//
//========================================================================
sub SaveLFS() : logic;
local begin
  Erx   : int;
  vNr   : int;
  vPos  : int;
  vGew  : float;
  vNGew : float;
end;
begin

  if (RunAFX('LFS.SaveLFS','')<>0) then RETURN (AfxRes=_rOK);

  TRANSON;

  vNr # Lib_Nummern:ReadNummer('Lieferschein');
  if (vNr<>0) then Lib_Nummern:SaveNummer()
  else begin
    TRANSBRK;
    RETURN false;
  end;

  vPos # 1;
  WHILE (RecLink(441,440,4,_RecFirst)=_rOk) do begin

    vGew  # vGew + Lfs.P.Gewicht.Brutto;
    vNGew # vNGew + Lfs.P.Gewicht.Netto;
    
    Erx # RecRead(441,1,_recLock);
    if (erx=_rOK) then begin
      Lfs.P.Nummer # vNr;
      Lfs.P.Position # vPos;
      vPos # vPos + 1;
      erx # Rekreplace(441,_recUnlock,'MAN');
    end;
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Error(440441,AInt(Lfs.p.position));
      RETURN False;
    end;

    if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(n)=false) then begin
      TRANSBRK;
      //ErrorOutput;
      RETURN False;
    end;
  END;

  // Sonderfunktion:
  if (RunAFX('LFS.RecSave','')<>0) then begin
    if (AfxRes<>_rOk) then begin
      TRANSBRK;
      //ErrorOutput;
      RETURN False;
    end;
  end;

  if (Lfs.Zieladresse=0) then begin
    TRANSBRK;
    Error(001000+Erx,gTitle);
    RETURN false;
  end;

  Lfs.Nummer            # vNr;
  Lfs.Anlage.Datum      # today;
  Lfs.Anlage.Zeit       # Now;
  Lfs.Anlage.User       # gUserName;
  Lfs.Positionsgewicht  # vGew;
  Lfs.PosNettogewicht   # vNGew;
  Erx # RekInsert(440,0,'MAN');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Error(001000+Erx,gTitle);
    RETURN False;
  end;

  Lib_Workflow:Trigger(440, 440, _WOF_KTX_NEU);   // 09.02.2021 AH

  TRANSOFF;

  // Ankerfunktion:
  RunAFX('LFS.RecSave.Post','');

  RETURN true;
end;


//========================================================================
//  SumLFS
//          Addiert das Positionsgewicht
//========================================================================
sub SumLFS() : logic;
local begin
  Erx   : int;
  vGew  : float;
  vNGew : float;
end;
begin
  Erx # RecLink(441, 440, 4, _recFirst);
  WHILE(Erx <= _rLocked) DO BEGIN
    vGew # vGew + Lfs.P.Gewicht.Brutto;
    vNGew # vNGew + Lfs.P.Gewicht.Netto;
    Erx # RecLink(441, 440, 4, _recNext);
  END;
  Erx # RecRead(440,1,_recLock);
  if (erx=_rOK) then begin
    Lfs.Positionsgewicht  # vGew;
    Lfs.PosNettogewicht   # vNGew;
    Erx # RekReplace(440,_recUnlock,'AUTO');
  end;
  if (erx<>_rOK) then RETURN false;

  RETURN true;
end;


//========================================================================
//  Check_ChangeZiel
//
//========================================================================
Sub Check_ChangeZiel(aSilent : logic) : logic;
local begin
  Erx : int;
end;
begin

  If ("Lfs.Löschmarker"='*') or (Lfs.Datum.Verbucht<>0.0.0) then begin
    if (aSilent=false) then Msg(440101, aint(Lfs.Nummer),0,0,0);
    RETURN false;
  end;

  // Positionen loopen...
  FOR Erx # RekLink(441,440,4,_recFirst)
  LOOP Erx # RekLink(441,440,4,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lfs.P.Datum.Verbucht<>0.0.0) then begin
      if (aSilent=false) then Msg(440101, aint(Lfs.P.Nummer)+'/'+aint(Lfs.P.Position),0,0,0);
      RETURN False;
    end;
  END;

  RETURN true;
end;


//========================================================================
// ChangeZiel
//
//========================================================================
Sub ChangeZiel(
  aZieladr    : int;
  aZielAnsch  : int;
) : logic;
local begin
  Erx   : int;
  vAuf  : int;
end;
begin

  TRANSON;

  // LFA?
  if (Lfs.zuBA.Nummer<>0) then begin
    Erx # RecLink(702,440,7,_recfirst); // BA-Position holen
    if (Erx>_rLocked) then begin
      TRANSBRK;
      RETURN false;
    end;

    // passt irgendwie nicht?
    if (BAG.P.Zieladresse<>Lfs.Zieladresse) or (BAG.P.Zielanschrift<>Lfs.Zielanschrift) then begin
      TRANSBRK;
      RETURN false;
    end;

    Erx # RecRead(702,1,_recLock);
    if (erx=_rOK) then begin
      BAG.P.Zieladresse   # aZieladr;
      BAG.P.Zielanschrift # aZielAnsch;
      RecLink(101,702,13,_recFirst);    // Anschrift holen
      BAG.P.Zielstichwort # Adr.A.Stichwort;
  //    BAG.P.ZielVerkaufYN
      Erx # BA1_P_Data:Replace(_recunlock,'MAN');
    end;
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;

    // BA-Output updaten...
    if (BA1_F_Data:UpdateOutput(702,y)<>y) then begin
      TRANSBRK;
      RETURN False;
    end;

  end
  // LFS?
  else begin
    // Positionen loopen...
    FOR Erx # RekLink(441,440,4,_recFirst)
    LOOP Erx # RekLink(441,440,4,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (Lfs.P.Auftragsnr<>0) and (vAuf=0) then vAuf # LFs.P.Auftragsnr;
      else if (Lfs.P.Auftragsnr<>0) and (vAuf<Lfs.P.Auftragsnr) then vAuf # -1;
    END;
    // verschiedene Auftragsnummer???
    if (vAuf=-1) then begin
      TRANSBRK;
      RETURN false;
    end;

    if (Auf_Data:ReadKopf(vAuf)<400) then begin
      TRANSBRK;
      RETURN false;
    end;
    if (Auf.Lieferadresse<>aZielAdr) or (Auf.Lieferanschrift<>aZielAnsch) then begin
      TRANSBRK;
      RETURN false;
    end;
  end;

// TODO VERSANDPOOL??? VSD/VSP

  // LFS-Kopf ändern...
  Erx # RecRead(440,1,_recLock);
  if (erx=_rOK) then begin
    if (Check_ChangeZiel(true)=false) then begin
      TRANSBRK;
      RecRead(440,1,_recunlock);
      RETURN false;
    end;
    Lfs.Zieladresse   # aZielAdr;
    Lfs.Zielanschrift # aZielAnsch;
    Erx # RecLink(101,440,3,_recFirst); // Anschrift holen
    if (Erx>_rLockeD) then begin
      TRANSBRK;
      RecRead(440,1,_recunlock);
      RETURN false;
    end;
    Erx # Rekreplace(440,_recunlock, 'MAN');
  end;
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  SumAlleLFS
//========================================================================
sub SumAlleLFS()
local begin
  Erx : int;
end;
begin
  FOR Erx # RecRead(440,1,_recFirst)
  LOOP Erx # RecRead(440,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    SumLFS();
  END;

  Msg(999998,'',0,0,0);
end;


//========================================================================
//  Recalc
//        Kosten neu verbuchen
//========================================================================
SUB Recalc() : logic
local begin
  Erx         : int;
  vPreisOK    : logic;
  aPauschalOK : logic;
  vTxt        : int;
  vI          : int;
  vKosten     : float;
  vMatDatei   : int;
  vOK         : logic;
  vA          : alpha;
end;
begin

  // NUR für VERBUCHTE NICHT LFA
  if (Lfs.Datum.Verbucht=0.0.0) then RETURN false;
  if (Lfs.zuBA.Nummer<>0) then RETURN false;

  vTxt # TextOpen(20);

  // Positionen durchlaufen & Kosten ermitteln
  FOR Erx # RecLink(441,440,4,_RecFirst)
  LOOP Erx # RecLink(441,440,4,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    vKosten # 0.0;
    RecBufClear(404);
    Auf.A.Aktionstyp    # c_Akt_LFS;
    Auf.A.Aktionsnr     # Lfs.P.Nummer;
    Auf.A.Aktionspos    # Lfs.P.Position;
    Erx # RecRead(404,2,0);
    if (Erx>_rMultikey) then CYCLE;
    
    // Wenn schon fakturiert, dann macht die OST-NEU auch Mat.Aktion !
    if (Auf.A.Rechnungsnr<>0) then begin
      vI # Textsearch(vTxt,1,1,_TextSearchCI, '|'+aint(Auf.A.Rechnungsnr)+'|');
      if (vI=0) then TextAddLine(vTxt, '|'+aint(Auf.A.Rechnungsnr)+'|');
    end
    else begin  // Aktionen anpassen VOR Faktura
      // FÜR ARTIKEL TODO !!!
      if (Lfs.P.Materialtyp=c_IO_MAT) then begin
        vMatDatei # Mat_Data:Read(Auf.A.MaterialNr);
        Lfs_Data:BerechneLfsKosten(200, true, var vKosten); // ST/AH 2016-07-07: Auch Kosten des Lieferscheines berücksichtigen
//        Lfs_Data:BerechneEKundKostenAusVorkalkulation(200, true, var vEK, var vKosten, var vPreisFound);
        RecBufClear(204);
        Mat.A.Aktionstyp    # Auf.A.Aktionstyp;
        Mat.A.Aktionsnr     # Auf.A.Aktionsnr;
        Mat.A.Aktionspos    # Auf.A.Aktionspos;
        Mat.A.Aktionspos2   # Auf.A.Aktionspos2;
        Erx # RecRead(204,2,0);
        if (Erx=_rOK) or (Erx=_rMultikey) then begin
          Erx # RecRead(204,1,_recLock | _Recnoload);
          if (erx=_rOK) then begin
            if (Mat.Bestand.Gew<>0.0) then
              Mat.A.KostenW1    # Rnd(vKosten / Mat.Bestand.Gew * 1000.0,2)
            else
              Mat.A.KostenW1    # 0.0;

            Mat.A.KostenW1ProMEH  # 0.0;
            if (Mat.Bestand.Menge + Mat.Bestellt.Menge<>0.0) then
              Mat.A.KostenW1ProMEH # Rnd( (Mat.A.KostenW1 * (Mat.Bestand.Gew + Mat.Bestellt.Gew) / 1000.0) / (Mat.Bestand.Menge + Mat.Bestellt.Menge) ,2);
            Erx # RekReplace(204,_recUnlock,'AUTO');
          end;
          if (Erx<>_rOK) then RETURN false;

          if (vMatDatei=200) then begin
            vOk # Mat_A_Data:Vererben();
          end
          else begin
            vOk # Mat_A_Abl_Data:Abl_Vererben();
            RecBufCopy(210,200);
          end;
          if (vOK=false) then RETURN false;
        end;
        vKosten # Rnd(Mat.Kosten * Mat.Bestand.Gew / 1000.0,2);
   
        Erx # RecRead(404,1,_recLock | _Recnoload);
        if (erx=_rOK) then begin
          Auf.A.interneKostW1  # vKosten;
          Erx # RekReplace(404,_recUnlock,'AUTO');
        end;
        if (erx<>_rOK) then RETURN false;
      end;
      
    end;

  END;

  // betroffene Rechnungne rekalkulieren
  WHILE (TextInfo(vTxt,_textLines)>0) do begin
    vA # TextLineRead(vTxt, 1, _TextLineDelete);
    Ost_Data:RecalcErl(cnvia(vA), true);
  END;

  TextClose(vTxt);

  Msg(999998,'',0,0,0);
end;


//========================================================================